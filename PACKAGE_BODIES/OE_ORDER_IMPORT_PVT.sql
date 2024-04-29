--------------------------------------------------------
--  DDL for Package Body OE_ORDER_IMPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ORDER_IMPORT_PVT" AS
/* $Header: OEXVIMPB.pls 120.16.12010000.6 2009/08/19 06:41:16 amimukhe ship $ */

/* ---------------------------------------------------------------
--  Start of Comments
--  API name    OE_ORDER_IMPORT_PVT
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

/* -----------------------------------------------------------
   Procedure: Import_Order
   -----------------------------------------------------------
*/
PROCEDURE IMPORT_ORDER(
   p_request_id			IN NUMBER
  ,p_order_source_id		IN NUMBER
  ,p_orig_sys_document_ref      IN VARCHAR2
  ,p_sold_to_org_id             IN  NUMBER
  ,p_sold_to_org                IN  VARCHAR2
  ,p_change_sequence      	IN VARCHAR2
  ,p_validate_only		IN VARCHAR2
  ,p_init_msg_list		IN VARCHAR2
  ,p_rtrim_data                 IN VARCHAR2
  ,p_org_id                     IN NUMBER
  ,p_msg_count          OUT NOCOPY NUMBER
  ,p_msg_data           OUT NOCOPY VARCHAR2
  ,p_return_status      OUT NOCOPY VARCHAR2
  ,p_validate_desc_flex         in varchar2 default 'Y' -- bug4343612
) IS

  l_control_rec                 OE_Globals.Control_Rec_Type;

  l_header_adj_rec  		OE_Order_Pub.Header_Adj_Rec_Type;
  l_header_scredit_rec      	OE_Order_Pub.Header_Scredit_Rec_Type;
  l_header_payment_rec          OE_Order_Pub.Header_payment_Rec_Type;
  l_header_price_att_rec        OE_Order_Pub.Header_Price_Att_Rec_Type;
  l_header_adj_att_rec          OE_Order_Pub.Header_Adj_Att_Rec_Type;
  l_header_adj_assoc_rec        OE_Order_Pub.Header_Adj_Assoc_Rec_Type;
  l_line_rec                    OE_Order_Pub.Line_Rec_Type;
  l_line_adj_rec                OE_Order_Pub.Line_Adj_Rec_Type;
  l_line_price_att_rec          OE_Order_Pub.Line_Price_Att_Rec_Type;
  l_line_adj_att_rec            OE_Order_Pub.Line_Adj_Att_Rec_Type;
  l_line_adj_assoc_rec          OE_Order_Pub.Line_Adj_Assoc_Rec_Type;
  l_line_scredit_rec            OE_Order_Pub.Line_Scredit_Rec_Type;
  l_line_payment_rec            OE_Order_Pub.Line_payment_Rec_Type;
  l_lot_serial_rec         	OE_Order_Pub.Lot_Serial_Rec_Type;
  l_reservation_rec         	OE_Order_Pub.Reservation_Rec_Type;
  l_action_request_rec          OE_Order_Pub.Request_Rec_Type;

  l_header_rec                  OE_Order_Pub.Header_Rec_Type;
  l_header_adj_tbl  		OE_Order_Pub.Header_Adj_Tbl_Type;
  l_header_price_att_tbl  	OE_Order_Pub.Header_Price_Att_Tbl_Type;
  l_header_adj_att_tbl  	OE_Order_Pub.Header_Adj_Att_Tbl_Type;
  l_header_adj_assoc_tbl  	OE_Order_Pub.Header_Adj_Assoc_Tbl_Type;
  l_header_scredit_tbl      	OE_Order_Pub.Header_Scredit_Tbl_Type;
  l_header_payment_tbl          OE_Order_Pub.Header_payment_Tbl_Type;
  l_line_tbl                    OE_Order_Pub.Line_Tbl_Type;
  l_line_adj_tbl                OE_Order_Pub.Line_Adj_Tbl_Type;
  l_line_price_att_tbl  	OE_Order_Pub.Line_Price_Att_Tbl_Type;
  l_line_adj_att_tbl  		OE_Order_Pub.Line_Adj_Att_Tbl_Type;
  l_line_adj_assoc_tbl  	OE_Order_Pub.Line_Adj_Assoc_Tbl_Type;
  l_line_scredit_tbl            OE_Order_Pub.Line_Scredit_Tbl_Type;
  l_line_payment_tbl            OE_Order_Pub.Line_payment_Tbl_Type;
  l_lot_serial_tbl         	OE_Order_Pub.Lot_Serial_Tbl_Type;
  l_reservation_tbl         	OE_Order_Pub.Reservation_Tbl_Type;
  l_action_request_tbl	        OE_Order_Pub.Request_Tbl_Type;

  l_header_rec_old              OE_Order_Pub.Header_Rec_Type;
  l_header_adj_tbl_old  	OE_Order_Pub.Header_Adj_Tbl_Type;
  l_header_price_att_tbl_old  	OE_Order_Pub.Header_Price_Att_Tbl_Type;
  l_header_adj_att_tbl_old  	OE_Order_Pub.Header_Adj_Att_Tbl_Type;
  l_header_adj_assoc_tbl_old  	OE_Order_Pub.Header_Adj_Assoc_Tbl_Type;
  l_header_scredit_tbl_old      OE_Order_Pub.Header_Scredit_Tbl_Type;
  l_header_payment_tbl_old      OE_Order_Pub.Header_payment_Tbl_Type;
  l_line_tbl_old                OE_Order_Pub.Line_Tbl_Type;
  l_line_adj_tbl_old            OE_Order_Pub.Line_Adj_Tbl_Type;
  l_line_price_att_tbl_old  	OE_Order_Pub.Line_Price_Att_Tbl_Type;
  l_line_adj_att_tbl_old 	OE_Order_Pub.Line_Adj_Att_Tbl_Type;
  l_line_adj_assoc_tbl_old  	OE_Order_Pub.Line_Adj_Assoc_Tbl_Type;
  l_line_scredit_tbl_old        OE_Order_Pub.Line_Scredit_Tbl_Type;
  l_line_payment_tbl_old        OE_Order_Pub.Line_payment_Tbl_Type;
  l_lot_serial_tbl_old     	OE_Order_Pub.Lot_Serial_Tbl_Type;
  l_action_request_tbl_old      OE_Order_Pub.Request_Tbl_Type;

  l_header_rec_new              OE_Order_Pub.Header_Rec_Type;
  l_header_adj_tbl_new  	OE_Order_Pub.Header_Adj_Tbl_Type;
  l_header_price_att_tbl_new  	OE_Order_Pub.Header_Price_Att_Tbl_Type;
  l_header_adj_att_tbl_new  	OE_Order_Pub.Header_Adj_Att_Tbl_Type;
  l_header_adj_assoc_tbl_new  	OE_Order_Pub.Header_Adj_Assoc_Tbl_Type;
  l_header_scredit_tbl_new      OE_Order_Pub.Header_Scredit_Tbl_Type;
  l_header_payment_tbl_new      OE_Order_Pub.Header_payment_Tbl_Type;
  l_line_tbl_new                OE_Order_Pub.Line_Tbl_Type;
  l_line_adj_tbl_new            OE_Order_Pub.Line_Adj_Tbl_Type;
  l_line_price_att_tbl_new  	OE_Order_Pub.Line_Price_Att_Tbl_Type;
  l_line_adj_att_tbl_new 	OE_Order_Pub.Line_Adj_Att_Tbl_Type;
  l_line_adj_assoc_tbl_new  	OE_Order_Pub.Line_Adj_Assoc_Tbl_Type;
  l_line_scredit_tbl_new        OE_Order_Pub.Line_Scredit_Tbl_Type;
  l_line_payment_tbl_new        OE_Order_Pub.Line_payment_Tbl_Type;
  l_lot_serial_tbl_new     	OE_Order_Pub.Lot_Serial_Tbl_Type;

  l_header_adj_val_rec  	OE_Order_Pub.Header_Adj_Val_Rec_Type;
  l_header_scredit_val_rec      OE_Order_Pub.Header_Scredit_Val_Rec_Type;
  l_header_payment_val_rec      OE_Order_Pub.Header_payment_Val_Rec_Type;
  l_line_val_rec              	OE_Order_Pub.Line_Val_Rec_Type;
  l_line_adj_val_rec  		OE_Order_Pub.Line_Adj_Val_Rec_Type;
  l_line_scredit_val_rec      	OE_Order_Pub.Line_Scredit_Val_Rec_Type;
  l_line_payment_val_rec        OE_Order_Pub.Line_payment_Val_Rec_Type;
  l_lot_serial_val_rec         	OE_Order_Pub.Lot_Serial_Val_Rec_Type;
  l_reservation_val_rec         OE_Order_Pub.Reservation_Val_Rec_Type;

  l_header_val_rec              OE_Order_Pub.Header_Val_Rec_Type;
  l_header_adj_val_tbl  	OE_Order_Pub.Header_Adj_Val_Tbl_Type;
  l_header_scredit_val_tbl      OE_Order_Pub.Header_Scredit_Val_Tbl_Type;
  l_header_payment_val_tbl      OE_Order_Pub.Header_payment_Val_Tbl_Type;
  l_line_val_tbl              	OE_Order_Pub.Line_Val_Tbl_Type;
  l_line_adj_val_tbl  		OE_Order_Pub.Line_Adj_Val_Tbl_Type;
  l_line_scredit_val_tbl      	OE_Order_Pub.Line_Scredit_Val_Tbl_Type;
  l_line_payment_val_tbl        OE_Order_Pub.Line_payment_Val_Tbl_Type;
  l_lot_serial_val_tbl         	OE_Order_Pub.Lot_Serial_Val_Tbl_Type;
  l_reservation_val_tbl         OE_Order_Pub.Reservation_Val_Tbl_Type;

  l_header_val_rec_old          OE_Order_Pub.Header_Val_Rec_Type;
  l_header_adj_val_tbl_old  	OE_Order_Pub.Header_Adj_Val_Tbl_Type;
  l_header_scredit_val_tbl_old  OE_Order_Pub.Header_Scredit_Val_Tbl_Type;
  l_header_payment_val_tbl_old  OE_Order_Pub.Header_payment_Val_Tbl_Type;
  l_line_val_tbl_old          	OE_Order_Pub.Line_Val_Tbl_Type;
  l_line_adj_val_tbl_old  	OE_Order_Pub.Line_Adj_Val_Tbl_Type;
  l_line_scredit_val_tbl_old  	OE_Order_Pub.Line_Scredit_Val_Tbl_Type;
  l_line_payment_val_tbl_old    OE_Order_Pub.Line_payment_Val_Tbl_Type;
  l_lot_serial_val_tbl_old     	OE_Order_Pub.Lot_Serial_Val_Tbl_Type;

  l_header_val_rec_new          OE_Order_Pub.Header_Val_Rec_Type;
  l_header_adj_val_tbl_new  	OE_Order_Pub.Header_Adj_Val_Tbl_Type;
  l_header_scredit_val_tbl_new  OE_Order_Pub.Header_Scredit_Val_Tbl_Type;
  l_header_payment_val_tbl_new  OE_Order_Pub.Header_payment_Val_Tbl_Type;
  l_line_val_tbl_new          	OE_Order_Pub.Line_Val_Tbl_Type;
  l_line_adj_val_tbl_new  	OE_Order_Pub.Line_Adj_Val_Tbl_Type;
  l_line_scredit_val_tbl_new  	OE_Order_Pub.Line_Scredit_Val_Tbl_Type;
  l_line_payment_val_tbl_new    OE_Order_Pub.Line_payment_Val_Tbl_Type;
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
  l_validation_org  NUMBER := OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID', p_org_id);

  l_header_count		NUMBER 		:= 0;
  l_header_adj_count		NUMBER 		:= 0;
  l_header_att_count            NUMBER          := 0;
  l_header_scredit_count	NUMBER 		:= 0;
  l_header_payment_count        NUMBER          := 0;
  l_line_count		        NUMBER 		:= 0;
  l_line_adj_count		NUMBER 		:= 0;
  l_line_att_count              NUMBER          := 0;
  l_line_scredit_count		NUMBER 		:= 0;
  l_line_payment_count          NUMBER          := 0;
  l_lot_serial_count		NUMBER 		:= 0;
  l_reservation_count		NUMBER 		:= 0;
  l_action_request_count        NUMBER 		:= 0;

  l_msg_index              	NUMBER := 0;
  l_msg_context              	VARCHAR2(2000);
  l_msg_data              	VARCHAR2(2000);
  l_tbl_index                   Number;

  l_msg_entity_code             VARCHAR2(30);
  l_msg_entity_ref		VARCHAR2(50);
  l_msg_entity_id               NUMBER;
  l_msg_header_id               NUMBER;
  l_msg_line_id                 NUMBER;
  l_msg_order_source_id         NUMBER;
  l_msg_orig_sys_document_ref   VARCHAR2(50);
  l_msg_change_sequence   	VARCHAR2(50);
  l_msg_orig_sys_line_ref  	VARCHAR2(50);
  l_msg_orig_sys_shipment_ref  	VARCHAR2(50);
  l_msg_sold_to_org_id          NUMBER;
  l_msg_sold_to_org                 VARCHAR2(360);
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

  --{ Start of the variable declaration for the add customer

  l_header_customer_rec       OE_ORDER_IMPORT_SPECIFIC_PVT.Customer_Rec_Type;
  l_line_customer_rec         OE_ORDER_IMPORT_SPECIFIC_PVT.Customer_Rec_Type;
  l_line_customer_tbl         OE_ORDER_IMPORT_SPECIFIC_PVT.Customer_Tbl_Type;

  --End of the variable declaration for the add customer}

  --{ Start of the subinventory Nulling Code variable declartion
  l_revision_code           NUMBER;
  l_lot_code                NUMBER;
  -- End of subinventory Nulling Code variable declartion}

  G_IMPORT_SHIPMENTS        VARCHAR2(3);

  l_order_imported          Varchar2(1);
  l_header_cso_response_flag Varchar2(1);
  l_cso_response_pfile      Varchar2(3);
  l_cho_ack_send_pfile      Varchar2(3);
  l_sold_to_org_id_tmp      NUMBER;

  l_rtrim_data              Varchar2(1) := p_rtrim_data;
  l_status           VARCHAR2(1);  -- Added for the bug 6378240

  l_msg_data_vp   varchar2(2000); -- Added for  bug 7367433
  l_msg_count_vp  number;  -- Added for  bug 7367433


--myerrams, Bug:4724191  l_header_id_temp	    NUMBER;		--myerrams


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
	 , nvl(accounting_rule_duration,	FND_API.G_MISS_NUM)
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
	 , nvl(customer_number,       FND_API.G_MISS_CHAR)
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
	 , nvl(booked_flag,			FND_API.G_MISS_CHAR)
--	 , nvl(closed_flag,			FND_API.G_MISS_CHAR)
	 , nvl(cancelled_flag,			FND_API.G_MISS_CHAR)
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
         , nvl(customer_preference_set_code,    FND_API.G_MISS_CHAR)
      -- { Start add new columns to select for the Add Customer
         , Orig_Sys_Customer_Ref
         , Orig_Ship_Address_Ref
         , Orig_Bill_Address_Ref
         , Orig_Deliver_Address_Ref
         , Sold_to_Contact_Ref
         , Ship_to_Contact_Ref
         , Bill_to_Contact_Ref
         , Deliver_to_Contact_Ref
      -- End add new columns to select for the Add Customer}
         , Xml_Message_Id
         , nvl(ship_to_customer,		FND_API.G_MISS_CHAR)
         , nvl(ship_to_customer_number,		FND_API.G_MISS_CHAR)
         , nvl(ship_to_customer_id,		FND_API.G_MISS_NUM)
         , nvl(invoice_customer,		FND_API.G_MISS_CHAR)
         , nvl(invoice_customer_number,		FND_API.G_MISS_CHAR)
         , nvl(invoice_customer_id,		FND_API.G_MISS_NUM)
         , nvl(deliver_to_customer,	FND_API.G_MISS_CHAR)
         , nvl(deliver_to_customer_number,	FND_API.G_MISS_CHAR)
         , nvl(deliver_to_customer_id,	        FND_API.G_MISS_NUM)
         , xml_transaction_type_code
         , nvl(blanket_number,	                FND_API.G_MISS_NUM)
         , nvl(shipping_method,                 FND_API.G_MISS_CHAR)
         -- Added pricing_date for the bug 3001346
	 , nvl(pricing_date,			FND_API.G_MISS_DATE)
         , response_flag
	 , nvl(sold_to_site_use_id, FND_API.G_MISS_NUM)
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
         -- automatic account creation {
         , sold_to_party_id
         , sold_to_org_contact_id
         , ship_to_party_id
         , ship_to_party_site_id
         , ship_to_party_site_use_id
         , deliver_to_party_id
         , deliver_to_party_site_id
         , deliver_to_party_site_use_id
         , invoice_to_party_id
         , invoice_to_party_site_id
         , invoice_to_party_site_use_id
     -- automatic account creation }
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
       	 , nvl(end_customer_name,		FND_API.G_MISS_CHAR) --mvijayku
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
         , nvl(ib_owner,                        FND_API.G_MISS_CHAR)
         , nvl(ib_current_location,             FND_API.G_MISS_CHAR)
         , nvl(ib_installed_at_location,        FND_API.G_MISS_CHAR)
         , nvl(ib_owner_code,                   FND_API.G_MISS_CHAR)
         , nvl(ib_current_location_code,        FND_API.G_MISS_CHAR)
         , nvl(ib_installed_at_location_code,   FND_API.G_MISS_CHAR)
	 , END_CUSTOMER_PARTY_ID
	 , END_CUSTOMER_ORG_CONTACT_ID
         , END_CUSTOMER_PARTY_SITE_ID
         , END_CUSTOMER_PARTY_SITE_USE_ID
         , END_CUSTOMER_PARTY_NUMBER
     -- Distributer Order related change }
     -- for automatic account creation
         , sold_to_party_number
         , ship_to_party_number
         , invoice_to_party_number
         , deliver_to_party_number
     -- for automatic account creation
         , nvl(deliver_to_address1,               FND_API.G_MISS_CHAR)
         , nvl(deliver_to_address2,               FND_API.G_MISS_CHAR)
         , nvl(deliver_to_address3,               FND_API.G_MISS_CHAR)
         , nvl(deliver_to_address4,               FND_API.G_MISS_CHAR)
         , nvl(deliver_to_state ,                 FND_API.G_MISS_CHAR)
         , nvl(deliver_to_county  ,               FND_API.G_MISS_CHAR)
         , nvl(deliver_to_country ,               FND_API.G_MISS_CHAR)
         , nvl(deliver_to_province,               FND_API.G_MISS_CHAR)
         , nvl(deliver_to_city    ,               FND_API.G_MISS_CHAR)
         , nvl(deliver_to_postal_code ,           FND_API.G_MISS_CHAR)
         , nvl(instrument_security_code,          FND_API.G_MISS_CHAR)    --R12 CVV2
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
   Header Price attribute cursor
   -----------------------------------------------------------
*/
     CURSOR l_header_attrib_cursor IS
     SELECT nvl(orig_sys_atts_ref,   FND_API.G_MISS_CHAR)
          , nvl(change_request_code,     FND_API.G_MISS_CHAR)
          ,  nvl(creation_date	, FND_API.G_MISS_DATE)
          ,  nvl(created_by		,   FND_API.G_MISS_NUM)
          ,  nvl(last_update_date	, FND_API.G_MISS_DATE)
          ,  nvl(last_updated_by		,   FND_API.G_MISS_NUM)
          ,  nvl(last_update_login	,   FND_API.G_MISS_NUM)
          ,  nvl(program_application_id	,   FND_API.G_MISS_NUM)
          ,  nvl(program_id		,   FND_API.G_MISS_NUM)
          ,  nvl(program_update_date,  FND_API.G_MISS_DATE)
          ,  nvl(request_id		,   FND_API.G_MISS_NUM)
          ,  nvl(flex_title		,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_context	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute1	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute2	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute3	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute4	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute5	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute6	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute7	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute8	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute9	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute10	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute11	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute12	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute13	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute14	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute15	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute16	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute17	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute18	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute19	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute20	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute21	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute22	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute23	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute24	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute25	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute26	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute27	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute28	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute29	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute30	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute31	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute32	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute33	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute34	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute35	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute36	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute37	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute38	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute39	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute40	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute41	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute42	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute43	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute44	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute45	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute46	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute47	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute48	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute49	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute50	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute51	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute52	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute53	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute54	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute55	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute56	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute57	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute58	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute59	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute60	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute61	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute62	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute63	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute64	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute65	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute66	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute67	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute68	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute69	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute70	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute71	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute72	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute73	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute74	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute75	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute76	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute77	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute78	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute79	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute80	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute81	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute82	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute83	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute84	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute85	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute86	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute87	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute88	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute89	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute90	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute91	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute92	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute93	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute94	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute95	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute96	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute97	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute98	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute99	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute100	,   FND_API.G_MISS_CHAR)
          ,  nvl(context 		,   FND_API.G_MISS_CHAR)
          ,  nvl(attribute1		,   FND_API.G_MISS_CHAR)
          ,  nvl(attribute2		,   FND_API.G_MISS_CHAR)
          ,  nvl(attribute3		,   FND_API.G_MISS_CHAR)
          ,  nvl(attribute4		,   FND_API.G_MISS_CHAR)
          ,  nvl(attribute5		,   FND_API.G_MISS_CHAR)
          ,  nvl(attribute6		,   FND_API.G_MISS_CHAR)
          ,  nvl(attribute7		,   FND_API.G_MISS_CHAR)
          ,  nvl(attribute8		,   FND_API.G_MISS_CHAR)
          ,  nvl(attribute9		,   FND_API.G_MISS_CHAR)
          ,  nvl(attribute10		,   FND_API.G_MISS_CHAR)
          ,  nvl(attribute11		,   FND_API.G_MISS_CHAR)
          ,  nvl(attribute12		,   FND_API.G_MISS_CHAR)
          ,  nvl(attribute13		,   FND_API.G_MISS_CHAR)
          ,  nvl(attribute14		,   FND_API.G_MISS_CHAR)
          ,  nvl(attribute15		,   FND_API.G_MISS_CHAR)
          ,  nvl(operation_code         ,   OE_GLOBALS.G_OPR_CREATE)
         FROM oe_price_atts_iface_all
         WHERE order_source_id              = l_order_source_id
         AND orig_sys_document_ref        = l_orig_sys_document_ref
         AND nvl(sold_to_org_id,                  FND_API.G_MISS_NUM)
           = nvl(l_sold_to_org_id,                FND_API.G_MISS_NUM)
         AND nvl(sold_to_org,                  FND_API.G_MISS_CHAR)
           = nvl(l_sold_to_org,                FND_API.G_MISS_CHAR)
         AND nvl(  change_sequence,              FND_API.G_MISS_CHAR)
           = nvl(l_change_sequence,       FND_API.G_MISS_CHAR)
         AND nvl(org_id,                          FND_API.G_MISS_NUM)
         = nvl(l_org_id,                        FND_API.G_MISS_NUM)
         AND nvl(orig_sys_line_ref,       FND_API.G_MISS_CHAR)
           =                              FND_API.G_MISS_CHAR
         AND nvl(orig_sys_shipment_ref,   FND_API.G_MISS_CHAR)
           =                              FND_API.G_MISS_CHAR
         AND nvl(  request_id,            FND_API.G_MISS_NUM)
           = nvl(l_request_id,            FND_API.G_MISS_NUM)
  FOR UPDATE NOWAIT
  ORDER  by orig_sys_document_ref;

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
         , nvl(change_reason,           FND_API.G_MISS_CHAR)
         , nvl(change_comments,         FND_API.G_MISS_CHAR)
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
   Multiple Payments: Header payments cursor
   -----------------------------------------------------------
*/
CURSOR l_header_payment_cursor IS
SELECT 	   nvl(orig_sys_payment_ref,	FND_API.G_MISS_CHAR)
	 , nvl(change_request_code,	FND_API.G_MISS_CHAR)
	 , nvl(payment_type_code,	FND_API.G_MISS_CHAR)
	 , nvl(commitment,		FND_API.G_MISS_CHAR)
	 , nvl(payment_trx_id,		FND_API.G_MISS_NUM)
	 , nvl(payment_method,		FND_API.G_MISS_CHAR)
	 , nvl(receipt_method_id,	FND_API.G_MISS_NUM)
	 , nvl(payment_collection_event,FND_API.G_MISS_CHAR)
	 , nvl(payment_set_id,		FND_API.G_MISS_NUM)
	 , nvl(prepaid_amount,		FND_API.G_MISS_NUM)
	 , nvl(credit_card_number,	FND_API.G_MISS_CHAR)
	 , nvl(credit_card_holder_name,	FND_API.G_MISS_CHAR)
	 , nvl(credit_card_expiration_date,FND_API.G_MISS_DATE)
	 , nvl(credit_card_code,	FND_API.G_MISS_CHAR)
	 , nvl(credit_card_approval_code,FND_API.G_MISS_CHAR)
	 , nvl(credit_card_approval_date,FND_API.G_MISS_DATE)
	 , nvl(check_number,		FND_API.G_MISS_CHAR)--6367320
	 , nvl(payment_amount,		FND_API.G_MISS_NUM)
	 , nvl(payment_percentage,	FND_API.G_MISS_NUM)
	 , nvl(creation_date,		FND_API.G_MISS_DATE)
         , nvl(created_by,		FND_API.G_MISS_NUM)
         , nvl(last_update_date,   	FND_API.G_MISS_DATE)
         , nvl(last_updated_by,   	FND_API.G_MISS_NUM)
         , nvl(last_update_login,   	FND_API.G_MISS_NUM)
         , nvl(program_application_id,  FND_API.G_MISS_NUM)
         , nvl(program_id,   		FND_API.G_MISS_NUM)
         , nvl(program_update_date,   	FND_API.G_MISS_DATE)
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
	 , nvl(payment_number,		FND_API.G_MISS_NUM)
	 , nvl(header_id,		FND_API.G_MISS_NUM)
	 , nvl(line_id,			FND_API.G_MISS_NUM)
         , nvl(DEFER_PAYMENT_PROCESSING_FLAG, FND_API.G_MISS_CHAR) -- Added for bug 8478559
	 , nvl(trxn_extension_id,       FND_API.G_MISS_NUM)
         , nvl(instrument_security_code,FND_API.G_MISS_CHAR)  --R12 CVV2
   FROM  oe_payments_iface_all
  WHERE  order_source_id              = l_order_source_id
    AND  orig_sys_document_ref        = l_orig_sys_document_ref
    AND  nvl(  change_sequence,       FND_API.G_MISS_CHAR)
      =  nvl(l_change_sequence,       FND_API.G_MISS_CHAR)
    AND nvl(org_id,                          FND_API.G_MISS_NUM)
         = nvl(l_org_id,                        FND_API.G_MISS_NUM)
    AND  nvl(orig_sys_line_ref,       FND_API.G_MISS_CHAR)
      =                               FND_API.G_MISS_CHAR
    AND  nvl(orig_sys_shipment_ref,   FND_API.G_MISS_CHAR)
      =                               FND_API.G_MISS_CHAR
    AND  nvl(  request_id,            FND_API.G_MISS_NUM)
      =  nvl(l_request_id,            FND_API.G_MISS_NUM)
FOR UPDATE NOWAIT
ORDER BY orig_sys_payment_ref;
-- end of multiple payments: header payment cursor.


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
	 , nvl(drop_ship_flag,		        FND_API.G_MISS_CHAR)
	 , nvl(ship_tolerance_above,		FND_API.G_MISS_NUM)
	 , nvl(ship_tolerance_below,		FND_API.G_MISS_NUM)
	 , nvl(price_list_id,			FND_API.G_MISS_NUM)
	 , nvl(price_list,			FND_API.G_MISS_CHAR)
	 , nvl(pricing_date,			FND_API.G_MISS_DATE)
	 , nvl(unit_list_price,			FND_API.G_MISS_NUM)
	 , nvl(unit_selling_price,		FND_API.G_MISS_NUM)
	 --, nvl(calculate_price_flag,		'Y')		     --commented for BUG#7304558
	 , nvl(calculate_price_flag,		FND_API.G_MISS_CHAR) --added for BUG#7304558
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
	 , nvl(accounting_rule_duration,	FND_API.G_MISS_NUM)
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
          --bug#4063831:
          --FP:11I9-12.0CUST_PRODUCTION_SEQ_NUM IS NOT GETTING POPULATED
          -- DURING ORDER IMPORT
         , nvl(cust_production_seq_num,         FND_API.G_MISS_CHAR)
	 , nvl(customer_line_number,		FND_API.G_MISS_CHAR)
	 , nvl(customer_shipment_number,	FND_API.G_MISS_CHAR)
	 , nvl(customer_item_id,		FND_API.G_MISS_NUM)
	 , nvl(customer_item_id_type,		FND_API.G_MISS_CHAR)
	 , nvl(customer_item_name,		FND_API.G_MISS_CHAR)
--	 , nvl(customer_item_revision,		FND_API.G_MISS_CHAR)
	 , nvl(customer_item_net_price,		FND_API.G_MISS_NUM)
	 , nvl(customer_payment_term_id,	FND_API.G_MISS_NUM)
	 , nvl(customer_payment_term,		FND_API.G_MISS_CHAR)
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
	 , nvl(commitment,		       FND_API.G_MISS_CHAR)
	 , nvl(commitment_id,		       FND_API.G_MISS_NUM)
-- aksingh subinventory
      , nvl(subinventory,                      FND_API.G_MISS_CHAR)
      ,nvl(salesrep,                           FND_API.G_MISS_CHAR)
      ,nvl(salesrep_id,                        FND_API.G_MISS_NUM)
      , nvl(earliest_acceptable_date,          FND_API.G_MISS_DATE)
      , nvl(latest_acceptable_date,            FND_API.G_MISS_DATE)
      , split_from_line_ref --bsadri
      , split_from_shipment_ref
	 , nvl(invoice_to_address1,	       FND_API.G_MISS_CHAR)
	 , nvl(invoice_to_address2,	       FND_API.G_MISS_CHAR)
	 , nvl(invoice_to_address3,	       FND_API.G_MISS_CHAR)
	 , nvl(invoice_to_address4,	       FND_API.G_MISS_CHAR)
	 , nvl(invoice_to_city,		       FND_API.G_MISS_CHAR)
	 , nvl(invoice_to_state,	       FND_API.G_MISS_CHAR)
	 , nvl(invoice_to_postal_code,	       FND_API.G_MISS_CHAR)
	 , nvl(invoice_to_country,	       FND_API.G_MISS_CHAR)
      -- { Start add new columns to select for the Add Customer
         , Orig_Ship_Address_Ref
         , Orig_Bill_Address_Ref
         , Orig_Deliver_Address_Ref
         , Ship_to_Contact_Ref
         , Bill_to_Contact_Ref
         , Deliver_to_Contact_Ref
      -- End add new columns to select for the Add Customer}
         , nvl(Config_Header_Id,               FND_API.G_MISS_NUM)
         , nvl(Config_Rev_Nbr,                 FND_API.G_MISS_NUM)
         , nvl(Configuration_ID,               FND_API.G_MISS_NUM)
         , nvl(ship_to_customer_name,	       FND_API.G_MISS_CHAR)
         , nvl(ship_to_customer_number,	       FND_API.G_MISS_CHAR)
         , nvl(ship_to_customer_id,	       FND_API.G_MISS_NUM)
         , nvl(invoice_to_customer_name,       FND_API.G_MISS_CHAR)
         , nvl(invoice_to_customer_number,     FND_API.G_MISS_CHAR)
         , nvl(invoice_to_customer_id,	       FND_API.G_MISS_NUM)
         , nvl(deliver_to_customer_name,       FND_API.G_MISS_CHAR)
         , nvl(deliver_to_customer_number,     FND_API.G_MISS_CHAR)
         , nvl(deliver_to_customer_id,	       FND_API.G_MISS_NUM)
         , nvl(user_item_description,	       FND_API.G_MISS_CHAR)
         , override_atp_date_code
         , xml_transaction_type_code
         , nvl(blanket_number,	               FND_API.G_MISS_NUM)
         , nvl(blanket_line_number,	       FND_API.G_MISS_NUM)
         , nvl(shipping_method, FND_API.G_MISS_CHAR)
         , nvl(change_sequence, FND_API.G_MISS_CHAR)
         -- automatic account creation {
        , ship_to_party_id
        , ship_to_party_site_id
        , ship_to_party_site_use_id
        , deliver_to_party_id
        , deliver_to_party_site_id
        , deliver_to_party_site_use_id
        , invoice_to_party_id
        , invoice_to_party_site_id
        , invoice_to_party_site_use_id
       -- automatic account creation }
     -- { Distributer Order related change
         , nvl(end_customer_id,                 FND_API.G_MISS_NUM)
         , nvl(end_customer_contact_id,         FND_API.G_MISS_NUM)
         , nvl(end_customer_site_use_id,        FND_API.G_MISS_NUM)
      , nvl(end_customer_name,		FND_API.G_MISS_CHAR) --mvijayku
         , nvl(end_customer_address1,		FND_API.G_MISS_CHAR)
	 , nvl(end_customer_address2,		FND_API.G_MISS_CHAR)
	 , nvl(end_customer_address3,		FND_API.G_MISS_CHAR)
	 , nvl(end_customer_address4,		FND_API.G_MISS_CHAR)
--	 	 , nvl(end_customer_location,		FND_API.G_MISS_CHAR)
	 , nvl(end_customer_city,		        FND_API.G_MISS_CHAR)
	 , nvl(end_customer_state,		        FND_API.G_MISS_CHAR)
	 , nvl(end_customer_postal_code,	        FND_API.G_MISS_CHAR)
	 , nvl(end_customer_country,	                FND_API.G_MISS_CHAR)
	 , nvl(end_customer_contact,			FND_API.G_MISS_CHAR)
         , nvl(end_customer_number,		FND_API.G_MISS_CHAR)
         , nvl(ib_owner,                        FND_API.G_MISS_CHAR)
         , nvl(ib_current_location,             FND_API.G_MISS_CHAR)
         , nvl(ib_installed_at_location,        FND_API.G_MISS_CHAR)
         , nvl(ib_owner_code,                   FND_API.G_MISS_CHAR)
         , nvl(ib_current_location_code,        FND_API.G_MISS_CHAR)
         , nvl(ib_installed_at_location_code,   FND_API.G_MISS_CHAR)
	 , END_CUSTOMER_PARTY_ID
	 , END_CUSTOMER_ORG_CONTACT_ID
         , END_CUSTOMER_PARTY_SITE_ID
         , END_CUSTOMER_PARTY_SITE_USE_ID
         , END_CUSTOMER_PARTY_NUMBER
     -- Distributer Order related change }
     -- for automatic account creation
         , ship_to_party_number
         , invoice_to_party_number
         , deliver_to_party_number
     -- for automatic account creation
         , nvl(deliver_to_address1,               FND_API.G_MISS_CHAR)
         , nvl(deliver_to_address2,               FND_API.G_MISS_CHAR)
         , nvl(deliver_to_address3,               FND_API.G_MISS_CHAR)
         , nvl(deliver_to_address4,               FND_API.G_MISS_CHAR)
         , nvl(deliver_to_state,                 FND_API.G_MISS_CHAR)
         , nvl(deliver_to_county,               FND_API.G_MISS_CHAR)
         , nvl(deliver_to_country,                FND_API.G_MISS_CHAR)
         , nvl(deliver_to_province,               FND_API.G_MISS_CHAR)
         , nvl(deliver_to_city,                   FND_API.G_MISS_CHAR)
         , nvl(deliver_to_postal_code,            FND_API.G_MISS_CHAR)
	 , nvl(planning_priority,                 FND_API.G_MISS_NUM)  --Bug#6924881
      FROM oe_lines_iface_all
     WHERE order_source_id		       = l_order_source_id
       AND orig_sys_document_ref 	       = l_orig_sys_document_ref
       AND nvl(sold_to_org_id,                  FND_API.G_MISS_NUM)
         = nvl(l_sold_to_org_id,                FND_API.G_MISS_NUM)
       AND nvl(sold_to_org,                  FND_API.G_MISS_CHAR)
         = nvl(l_sold_to_org,                FND_API.G_MISS_CHAR)
       AND nvl(  change_sequence,	       FND_API.G_MISS_CHAR)
	 = nvl(l_change_sequence,	       FND_API.G_MISS_CHAR)
       AND nvl(org_id,                          FND_API.G_MISS_NUM)
         = nvl(l_org_id,                        FND_API.G_MISS_NUM)
       AND nvl(  request_id,		       FND_API.G_MISS_NUM)
	 = nvl(l_request_id,		       FND_API.G_MISS_NUM)
       AND nvl(rejected_flag,'N')	       = 'N'
  FOR UPDATE NOWAIT
  ORDER BY operation_code desc, orig_sys_line_ref asc, orig_sys_shipment_ref asc
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
   Line Price attribute cursor
   -----------------------------------------------------------
*/

         CURSOR l_Line_attrib_cursor IS
         SELECT nvl(creation_date	,   FND_API.G_MISS_DATE)
          ,  nvl(created_by	        ,   FND_API.G_MISS_NUM)
          ,  nvl(last_update_date	,   FND_API.G_MISS_DATE)
          ,  nvl(last_updated_by	,   FND_API.G_MISS_NUM)
          ,  nvl(last_update_login	,   FND_API.G_MISS_NUM)
          ,  nvl(program_application_id	,   FND_API.G_MISS_NUM)
          ,  nvl(program_id		,   FND_API.G_MISS_NUM)
          ,  nvl(program_update_date    ,   FND_API.G_MISS_DATE)
          ,  nvl(request_id		,   FND_API.G_MISS_NUM)
          ,  nvl(flex_title		,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_context	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute1	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute2	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute3	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute4	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute5	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute6	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute7	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute8	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute9	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute10	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute11	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute12	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute13	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute14	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute15	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute16	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute17	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute18	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute19	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute20	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute21	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute22	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute23	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute24	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute25	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute26	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute27	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute28	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute29	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute30	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute31	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute32	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute33	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute34	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute35	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute36	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute37	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute38	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute39	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute40	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute41	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute42	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute43	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute44	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute45	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute46	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute47	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute48	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute49	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute50	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute51	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute52	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute53	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute54	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute55	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute56	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute57	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute58	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute59	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute60	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute61	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute62	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute63	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute64	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute65	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute66	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute67	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute68	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute69	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute70	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute71	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute72	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute73	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute74	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute75	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute76	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute77	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute78	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute79	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute80	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute81	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute82	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute83	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute84	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute85	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute86	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute87	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute88	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute89	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute90	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute91	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute92	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute93	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute94	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute95	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute96	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute97	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute98	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute99	,   FND_API.G_MISS_CHAR)
          ,  nvl(pricing_attribute100	,   FND_API.G_MISS_CHAR)
          ,  nvl(context 		,   FND_API.G_MISS_CHAR)
          ,  nvl(attribute1		,   FND_API.G_MISS_CHAR)
          ,  nvl(attribute2		,   FND_API.G_MISS_CHAR)
          ,  nvl(attribute3		,   FND_API.G_MISS_CHAR)
          ,  nvl(attribute4		,   FND_API.G_MISS_CHAR)
          ,  nvl(attribute5		,   FND_API.G_MISS_CHAR)
          ,  nvl(attribute6		,   FND_API.G_MISS_CHAR)
          ,  nvl(attribute7		,   FND_API.G_MISS_CHAR)
          ,  nvl(attribute8		,   FND_API.G_MISS_CHAR)
          ,  nvl(attribute9		,   FND_API.G_MISS_CHAR)
          ,  nvl(attribute10		,   FND_API.G_MISS_CHAR)
          ,  nvl(attribute11		,   FND_API.G_MISS_CHAR)
          ,  nvl(attribute12		,   FND_API.G_MISS_CHAR)
          ,  nvl(attribute13		,   FND_API.G_MISS_CHAR)
          ,  nvl(attribute14		,   FND_API.G_MISS_CHAR)
          ,  nvl(attribute15		,   FND_API.G_MISS_CHAR)
          ,  nvl(operation_code        ,   OE_GLOBALS.G_OPR_CREATE)
          FROM  oe_price_atts_iface_all
          WHERE order_source_id           = l_order_source_id
         AND orig_sys_document_ref        = l_orig_sys_document_ref
         AND nvl(sold_to_org_id,                  FND_API.G_MISS_NUM)
           = nvl(l_sold_to_org_id,                FND_API.G_MISS_NUM)
         AND nvl(sold_to_org,                  FND_API.G_MISS_CHAR)
           = nvl(l_sold_to_org,                FND_API.G_MISS_CHAR)
         AND nvl(  change_sequence,       FND_API.G_MISS_CHAR)
           = nvl(l_change_sequence,       FND_API.G_MISS_CHAR)
         AND nvl(org_id,                          FND_API.G_MISS_NUM)
         = nvl(l_org_id,                        FND_API.G_MISS_NUM)
         AND orig_sys_line_ref            = l_orig_sys_line_ref
         AND nvl(  orig_sys_shipment_ref, FND_API.G_MISS_CHAR)
           = nvl(l_orig_sys_shipment_ref, FND_API.G_MISS_CHAR)
         AND nvl(  request_id,            FND_API.G_MISS_NUM)
           = nvl(l_request_id,            FND_API.G_MISS_NUM)
  FOR UPDATE NOWAIT
  ORDER by orig_sys_line_ref;

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
         , nvl(change_reason,           FND_API.G_MISS_CHAR)
         , nvl(change_comments,         FND_API.G_MISS_CHAR)
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
   Multiple Payments: Line payments cursor
   -----------------------------------------------------------
*/
CURSOR l_line_payment_cursor IS
SELECT 	   nvl(orig_sys_payment_ref,	FND_API.G_MISS_CHAR)
	 , nvl(change_request_code,	FND_API.G_MISS_CHAR)
	 , nvl(payment_type_code,	FND_API.G_MISS_CHAR)
	 , nvl(commitment,		FND_API.G_MISS_CHAR)
	 , nvl(payment_trx_id,		FND_API.G_MISS_NUM)
	 , nvl(payment_method,		FND_API.G_MISS_CHAR)
	 , nvl(receipt_method_id,	FND_API.G_MISS_NUM)
	 , nvl(payment_collection_event,FND_API.G_MISS_CHAR)
	 , nvl(payment_set_id,		FND_API.G_MISS_NUM)
	 , nvl(prepaid_amount,		FND_API.G_MISS_NUM)
	 , nvl(credit_card_number,	FND_API.G_MISS_CHAR)
	 , nvl(credit_card_holder_name,	FND_API.G_MISS_CHAR)
	 , nvl(credit_card_expiration_date,FND_API.G_MISS_DATE)
	 , nvl(credit_card_code,	FND_API.G_MISS_CHAR)
	 , nvl(credit_card_approval_code,FND_API.G_MISS_CHAR)
	 , nvl(credit_card_approval_date,FND_API.G_MISS_DATE)
	 , nvl(check_number,		FND_API.G_MISS_CHAR)--6367320
	 , nvl(payment_amount,		FND_API.G_MISS_NUM)
	 , nvl(payment_percentage,	FND_API.G_MISS_NUM)
	 , nvl(creation_date,		FND_API.G_MISS_DATE)
         , nvl(created_by,		FND_API.G_MISS_NUM)
         , nvl(last_update_date,   	FND_API.G_MISS_DATE)
         , nvl(last_updated_by,   	FND_API.G_MISS_NUM)
         , nvl(last_update_login,   	FND_API.G_MISS_NUM)
         , nvl(program_application_id,  FND_API.G_MISS_NUM)
         , nvl(program_id,   		FND_API.G_MISS_NUM)
         , nvl(program_update_date,   	FND_API.G_MISS_DATE)
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
	 , nvl(payment_number,		FND_API.G_MISS_NUM)
	 , nvl(header_id,		FND_API.G_MISS_NUM)
	 , nvl(line_id,			FND_API.G_MISS_NUM)
         , nvl(DEFER_PAYMENT_PROCESSING_FLAG, FND_API.G_MISS_CHAR) -- Added for bug 8478559
	 , nvl(trxn_extension_id,	FND_API.G_MISS_NUM)
         , nvl(instrument_security_code,FND_API.G_MISS_CHAR)  --R12 CVV2
   FROM  oe_payments_iface_all
  WHERE  order_source_id              = l_order_source_id
    AND  orig_sys_document_ref        = l_orig_sys_document_ref
    AND  nvl(  change_sequence,       FND_API.G_MISS_CHAR)
      =  nvl(l_change_sequence,       FND_API.G_MISS_CHAR)
    AND nvl(org_id,                          FND_API.G_MISS_NUM)
         = nvl(l_org_id,                        FND_API.G_MISS_NUM)
    AND  orig_sys_line_ref 		= l_orig_sys_line_ref
    AND  nvl(  orig_sys_shipment_ref,	FND_API.G_MISS_CHAR)
      =  nvl(l_orig_sys_shipment_ref,	FND_API.G_MISS_CHAR)
    AND  nvl(  request_id,            FND_API.G_MISS_NUM)
      =  nvl(l_request_id,            FND_API.G_MISS_NUM)
FOR UPDATE NOWAIT
ORDER BY orig_sys_payment_ref;
-- end of multiple payments: line payment cursor.

/* -----------------------------------------------------------
   Line Lot Serials cursor
   -----------------------------------------------------------
*/
    CURSOR l_lot_serial_cursor IS
    SELECT nvl(orig_sys_lotserial_ref,	FND_API.G_MISS_CHAR)
	 , nvl(change_request_code,	FND_API.G_MISS_CHAR)
	 , nvl(lot_number,		FND_API.G_MISS_CHAR)
   --      , nvl(sublot_number,		FND_API.G_MISS_CHAR) -- OPM 3322359 INVCONV
	 , nvl(from_serial_number,	FND_API.G_MISS_CHAR)
	 , nvl(to_serial_number,	FND_API.G_MISS_CHAR)
	 , nvl(quantity,		FND_API.G_MISS_NUM)
	 , nvl(quantity2,		FND_API.G_MISS_NUM) -- OPM 3322359
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
      FROM oe_lotserials_iface_all
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
  ORDER BY orig_sys_lotserial_ref
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
	 , quantity2 -- INVCONV
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


/* -----------------------------------------------------------
   Action Requests cursor
   -----------------------------------------------------------
*/
    CURSOR l_action_request_header_cursor IS
    SELECT nvl(orig_sys_line_ref,	FND_API.G_MISS_CHAR)
         , nvl(orig_sys_shipment_ref,	FND_API.G_MISS_CHAR)
	 , hold_id
	 , hold_type_code
	 , hold_type_id
	 , hold_until_date
	 , release_reason_code
	 , comments
	 , context
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
	 , operation_code
	 , error_flag
	 , status_flag
	 , interface_status
--myerrams, start, added the following fields to the cursor for Customer Acceptance
	 , char_param1
	 , char_param2
	 , char_param3
	 , char_param4
	 , char_param5
	 , date_param1
	 , date_param2
	 , date_param3
	 , date_param4
	 , date_param5
--myerrams, end
      FROM oe_actions_iface_all
     WHERE order_source_id 		= l_order_source_id
       AND orig_sys_document_ref 	= l_orig_sys_document_ref
       AND nvl(sold_to_org_id,                  FND_API.G_MISS_NUM)
         = nvl(l_sold_to_org_id,                FND_API.G_MISS_NUM)
       AND nvl(sold_to_org,                  FND_API.G_MISS_CHAR)
         = nvl(l_sold_to_org,                FND_API.G_MISS_CHAR)
       AND nvl(org_id,                          FND_API.G_MISS_NUM)
         = nvl(l_org_id,                        FND_API.G_MISS_NUM)
       AND nvl(orig_sys_line_ref,       FND_API.G_MISS_CHAR)
         =                              FND_API.G_MISS_CHAR
       AND nvl(  change_sequence,	FND_API.G_MISS_CHAR)
	 = nvl(l_change_sequence,	FND_API.G_MISS_CHAR)
       AND nvl(  request_id,		FND_API.G_MISS_NUM)
	 = nvl(l_request_id,		FND_API.G_MISS_NUM)
  FOR UPDATE NOWAIT
;
/*bsadri the actions at line level has to have its own cursor so
  we can pass the line_index to it at the main loop.like other lines*/

    CURSOR l_action_request_line_cursor IS
    SELECT nvl(orig_sys_line_ref,	FND_API.G_MISS_CHAR)
         , nvl(orig_sys_shipment_ref,	FND_API.G_MISS_CHAR)
	 , hold_id
	 , hold_type_code
	 , hold_type_id
	 , hold_until_date
	 , release_reason_code
	 , comments
	 , context
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
	 , operation_code
         , fulfillment_set_name
	 , error_flag
	 , status_flag
	 , interface_status
--myerrams, start, added the following fields to the cursor for Customer Acceptance
	 , char_param1
	 , char_param2
	 , char_param3
	 , char_param4
	 , char_param5
	 , date_param1
	 , date_param2
	 , date_param3
	 , date_param4
	 , date_param5
--myerrams, end
      FROM oe_actions_iface_all
     WHERE order_source_id 		= l_order_source_id
       AND orig_sys_document_ref 	= l_orig_sys_document_ref
       AND nvl(sold_to_org_id,                  FND_API.G_MISS_NUM)
         = nvl(l_sold_to_org_id,                FND_API.G_MISS_NUM)
       AND nvl(sold_to_org,                  FND_API.G_MISS_CHAR)
         = nvl(l_sold_to_org,                FND_API.G_MISS_CHAR)
       AND orig_sys_line_ref            = l_orig_sys_line_ref
       AND nvl(  change_sequence,	FND_API.G_MISS_CHAR)
	 = nvl(l_change_sequence,	FND_API.G_MISS_CHAR)
       AND nvl(org_id,                          FND_API.G_MISS_NUM)
         = nvl(l_org_id,                        FND_API.G_MISS_NUM)
       AND nvl(  request_id,		FND_API.G_MISS_NUM)
	 = nvl(l_request_id,		FND_API.G_MISS_NUM)
  FOR UPDATE NOWAIT
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
      oe_debug_pub.add('trim data = '||l_rtrim_data);
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
  l_header_payment_rec          := OE_Order_Pub.G_MISS_HEADER_payment_REC;
  l_header_payment_tbl          := OE_Order_Pub.G_MISS_HEADER_payment_TBL;
  l_header_payment_tbl_old      := OE_Order_Pub.G_MISS_HEADER_payment_TBL;
  l_header_payment_tbl_new      := OE_Order_Pub.G_MISS_HEADER_payment_TBL;

  /* 1433292   */
  l_header_price_att_rec        := OE_Order_Pub.G_MISS_HEADER_PRICE_ATT_REC;
  l_header_price_att_tbl        := OE_Order_Pub.G_MISS_HEADER_PRICE_ATT_TBL;
  l_header_price_att_tbl_old    := OE_Order_Pub.G_MISS_HEADER_PRICE_ATT_TBL;
  l_header_price_att_tbl_new    := OE_Order_Pub.G_MISS_HEADER_PRICE_ATT_TBL;
  l_header_adj_att_rec          := OE_Order_Pub.G_MISS_HEADER_ADJ_ATT_REC;
  l_header_adj_att_tbl          := OE_Order_Pub.G_MISS_HEADER_ADJ_ATT_TBL;
  l_header_adj_att_tbl_old      := OE_Order_Pub.G_MISS_HEADER_ADJ_ATT_TBL;
  l_header_adj_att_tbl_new      := OE_Order_Pub.G_MISS_HEADER_ADJ_ATT_TBL;
  l_header_adj_assoc_rec        := OE_Order_Pub.G_MISS_HEADER_ADJ_ASSOC_REC;
  l_header_adj_assoc_tbl        := OE_Order_Pub.G_MISS_HEADER_ADJ_ASSOC_TBL;
  l_header_adj_assoc_tbl_old    := OE_Order_Pub.G_MISS_HEADER_ADJ_ASSOC_TBL;
  l_header_adj_assoc_tbl_new    := OE_Order_Pub.G_MISS_HEADER_ADJ_ASSOC_TBL;

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
  l_header_payment_val_rec      := OE_Order_Pub.G_MISS_HEADER_payment_VAL_REC;
  l_header_payment_val_tbl      := OE_Order_Pub.G_MISS_HEADER_payment_VAL_TBL;
  l_header_payment_val_tbl_old  := OE_Order_Pub.G_MISS_HEADER_payment_VAL_TBL;
  l_header_payment_val_tbl_new  := OE_Order_Pub.G_MISS_HEADER_payment_VAL_TBL;

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
  l_line_payment_rec            := OE_Order_Pub.G_MISS_LINE_payment_REC;
  l_line_payment_tbl            := OE_Order_Pub.G_MISS_LINE_payment_TBL;
  l_line_payment_tbl_old        := OE_Order_Pub.G_MISS_LINE_payment_TBL;
  l_line_payment_tbl_new        := OE_Order_Pub.G_MISS_LINE_payment_TBL;
  l_reservation_rec 		:= OE_Order_Pub.G_MISS_RESERVATION_REC;
  l_reservation_tbl 		:= OE_Order_Pub.G_MISS_RESERVATION_TBL;
  /* 1433292 */
  l_line_price_att_rec        := OE_Order_Pub.G_MISS_LINE_PRICE_ATT_REC;
  l_line_price_att_tbl        := OE_Order_Pub.G_MISS_LINE_PRICE_ATT_TBL;
  l_line_price_att_tbl_old    := OE_Order_Pub.G_MISS_LINE_PRICE_ATT_TBL;
  l_line_price_att_tbl_new    := OE_Order_Pub.G_MISS_LINE_PRICE_ATT_TBL;
  l_line_adj_att_rec          := OE_Order_Pub.G_MISS_LINE_ADJ_ATT_REC;
  l_line_adj_att_tbl          := OE_Order_Pub.G_MISS_LINE_ADJ_ATT_TBL;
  l_line_adj_att_tbl_old      := OE_Order_Pub.G_MISS_LINE_ADJ_ATT_TBL;
  l_line_adj_att_tbl_new      := OE_Order_Pub.G_MISS_LINE_ADJ_ATT_TBL;
  l_line_adj_assoc_rec        := OE_Order_Pub.G_MISS_LINE_ADJ_ASSOC_REC;
  l_line_adj_assoc_tbl        := OE_Order_Pub.G_MISS_LINE_ADJ_ASSOC_TBL;
  l_line_adj_assoc_tbl_old    := OE_Order_Pub.G_MISS_LINE_ADJ_ASSOC_TBL;
  l_line_adj_assoc_tbl_new    := OE_Order_Pub.G_MISS_LINE_ADJ_ASSOC_TBL;

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
  l_line_payment_val_rec        := OE_Order_Pub.G_MISS_LINE_payment_VAL_REC;
  l_line_payment_val_tbl        := OE_Order_Pub.G_MISS_LINE_payment_VAL_TBL;
  l_line_payment_val_tbl_old    := OE_Order_Pub.G_MISS_LINE_payment_VAL_TBL;
  l_line_payment_val_tbl_new    := OE_Order_Pub.G_MISS_LINE_payment_VAL_TBL;
  l_reservation_val_rec 	:= OE_Order_Pub.G_MISS_RESERVATION_VAL_REC;
  l_reservation_val_tbl 	:= OE_Order_Pub.G_MISS_RESERVATION_VAL_TBL;

  l_lot_serial_rec 		:= OE_Order_Pub.G_MISS_LOT_SERIAL_REC;
  l_lot_serial_tbl 		:= OE_Order_Pub.G_MISS_LOT_SERIAL_TBL;
  l_lot_serial_tbl_old 		:= OE_Order_Pub.G_MISS_LOT_SERIAL_TBL;
  l_lot_serial_tbl_new 		:= OE_Order_Pub.G_MISS_LOT_SERIAL_TBL;

  l_action_request_rec 		:= OE_Order_Pub.G_MISS_REQUEST_REC;
  l_action_request_tbl 		:= OE_Order_Pub.G_MISS_REQUEST_TBL;
  l_action_request_tbl_old 	:= OE_Order_Pub.G_MISS_REQUEST_TBL;

  p_return_status		:= FND_API.G_RET_STS_SUCCESS; -- Success

  fnd_profile.get('ONT_IMP_MULTIPLE_SHIPMENTS', G_IMPORT_SHIPMENTS);
  G_IMPORT_SHIPMENTS := nvl(G_IMPORT_SHIPMENTS, 'NO');

  FND_PROFILE.GET('ONT_3A7_RESPONSE_REQUIRED', l_cso_response_pfile);
  l_cso_response_pfile := nvl(l_cso_response_pfile, 'N');

  FND_PROFILE.GET('ONT_3A8_RESPONSE_ACK', l_cho_ack_send_pfile);
  l_cho_ack_send_pfile := nvl(l_cho_ack_send_pfile, 'N');

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
	 , l_header_rec.accounting_rule_duration
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
	 , l_header_rec.attribute16  -- For bug 2184255
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
         , l_header_rec.customer_preference_set_code
      -- { Start add new columns to select for the Add Customer
         , l_header_customer_rec.Orig_Sys_Customer_Ref
         , l_header_customer_rec.Orig_Ship_Address_Ref
         , l_header_customer_rec.Orig_Bill_Address_Ref
         , l_header_customer_rec.Orig_Deliver_Address_Ref
         , l_header_customer_rec.Sold_to_Contact_Ref
         , l_header_customer_rec.Ship_to_Contact_Ref
         , l_header_customer_rec.Bill_to_Contact_Ref
         , l_header_customer_rec.Deliver_to_Contact_Ref
      -- End add new columns to select for the Add Customer}
         , l_header_rec.xml_message_id
         , l_header_val_rec.ship_to_customer_name_oi
         , l_header_val_rec.ship_to_customer_number_oi
         , l_header_rec.ship_to_customer_id
         , l_header_val_rec.invoice_to_customer_name_oi
         , l_header_val_rec.invoice_to_customer_number_oi
         , l_header_rec.invoice_to_customer_id
         , l_header_val_rec.deliver_to_customer_name_oi
         , l_header_val_rec.deliver_to_customer_number_oi
         , l_header_rec.deliver_to_customer_id
         , l_header_rec.xml_transaction_type_code
         , l_header_rec.blanket_number
         , l_header_val_rec.shipping_method
         -- Added pricing_date for the bug 3001346
	 , l_header_rec.pricing_date
         , l_header_cso_response_flag
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
         -- automatic account creation {
        , l_header_rec.sold_to_party_id
        , l_header_rec.sold_to_org_contact_id
        , l_header_rec.ship_to_party_id
        , l_header_rec.ship_to_party_site_id
        , l_header_rec.ship_to_party_site_use_id
        , l_header_rec.deliver_to_party_id
        , l_header_rec.deliver_to_party_site_id
        , l_header_rec.deliver_to_party_site_use_id
        , l_header_rec.invoice_to_party_id
        , l_header_rec.invoice_to_party_site_id
        , l_header_rec.invoice_to_party_site_use_id
         -- automatic account creation }
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
        ,l_header_val_rec.end_customer_name  --mvijayku
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
        , l_header_val_rec.ib_owner_dsp
        , l_header_val_rec.ib_current_location_dsp
        , l_header_val_rec.ib_installed_at_location_dsp
        , l_header_rec.ib_owner
        , l_header_rec.ib_current_location
        , l_header_rec.ib_installed_at_location
        , l_header_rec.END_CUSTOMER_PARTY_ID
	 ,l_header_rec.END_CUSTOMER_ORG_CONTACT_ID
         ,l_header_rec.END_CUSTOMER_PARTY_SITE_ID
         ,l_header_rec.END_CUSTOMER_PARTY_SITE_USE_ID
         ,l_header_rec.END_CUSTOMER_PARTY_NUMBER
     -- Distributer Order related change }
     -- Automatic Account Creation
        , l_header_rec.sold_to_party_number
        , l_header_rec.ship_to_party_number
        , l_header_rec.invoice_to_party_number
        , l_header_rec.deliver_to_party_number
     -- Automatic Account Creation
         , l_header_val_rec.deliver_to_address1
         , l_header_val_rec.deliver_to_address2
         , l_header_val_rec.deliver_to_address3
         , l_header_val_rec.deliver_to_address4
         , l_header_val_rec.deliver_to_state
         , l_header_val_rec.deliver_to_county
         , l_header_val_rec.deliver_to_country
         , l_header_val_rec.deliver_to_province
         , l_header_val_rec.deliver_to_city
         , l_header_val_rec.deliver_to_zip
         , l_header_rec.instrument_security_code  --R12 CVV2
;
      --EXIT WHEN l_header_cursor%NOTFOUND;

      l_header_count := l_header_count + 1;

      l_order_source_id 	:= l_header_rec.order_source_id;
      l_orig_sys_document_ref 	:= l_header_rec.orig_sys_document_ref;
      l_sold_to_org_id          := l_header_rec.sold_to_org_id;
      l_sold_to_org             := l_header_val_rec.sold_to_org;
      l_change_sequence 	:= l_header_rec.change_sequence;

      IF l_header_rec.operation  = 'INSERT' THEN
         l_header_rec.operation := 'CREATE';
      END IF;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ORDER SOURCE ID: ' || L_ORDER_SOURCE_ID ) ;

          oe_debug_pub.add(  'ORIG SYS REFERENCE: '|| L_ORIG_SYS_DOCUMENT_REF ) ;
	  oe_debug_pub.add(  'SOLD_TO_ORG passed in: ' || P_SOLD_TO_ORG ) ;
	  oe_debug_pub.add(  'SOLD_TO_ORG_ID passed in: ' || P_SOLD_TO_ORG_ID ) ;
	  oe_debug_pub.add(  'SOLD_TO_ORG: from record' || L_SOLD_TO_ORG ) ;
	  oe_debug_pub.add(  'SOLD_TO_ORG_ID: from record' || L_SOLD_TO_ORG_ID ) ;

          oe_debug_pub.add(  'CHANGE SEQUENCE: ' || L_CHANGE_SEQUENCE ) ;
          oe_debug_pub.add('sarita: booked flag: '|| l_header_rec.booked_flag);


      END IF;



 IF OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510' THEN

/*    If l_sold_to_org_id is null attempt to populate it based on
          l_sold_to_org.

*/
      -- bug 3392678
      OE_GLOBALS.G_XML_TXN_CODE := NULL;
      IF l_header_rec.order_source_id = OE_Acknowledgment_Pub.G_XML_ORDER_SOURCE_ID
         AND nvl(l_header_rec.xml_transaction_type_code, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
         OE_GLOBALS.G_XML_TXN_CODE := l_header_rec.xml_transaction_type_code;
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SET GLOBAL TXN CODE TO '||OE_GLOBALS.G_XML_TXN_CODE ) ;
         END IF;
      END IF;

      IF l_header_rec.order_source_id NOT IN (OE_Acknowledgment_Pub.G_XML_ORDER_SOURCE_ID,
                                              OE_Globals.G_ORDER_SOURCE_EDI)
         AND l_header_rec.xml_message_id IS NULL THEN
         SELECT oe_xml_message_seq_s.nextval
           INTO l_header_rec.xml_message_id
           FROM DUAL;
      END IF;

     if l_sold_to_org_id = FND_API.G_MISS_NUM then
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'header level sold to org id is g_miss_num, so it was not populated' ) ;
        END IF;

      if (l_sold_to_org IS NOT NULL) AND
         (l_sold_to_org <> FND_API.G_MISS_CHAR) THEN

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'sold to org is populated:' || l_sold_to_org) ;
        END IF;

         l_sold_to_org_id_tmp   := OE_VALUE_TO_ID.sold_to_org(
					    p_sold_to_org => l_sold_to_org,
					    p_customer_number => null);

         if (l_sold_to_org_id_tmp <> FND_API.G_MISS_NUM) AND
            (l_sold_to_org_id_tmp IS NOT NULL) THEN
            IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'returned value for sold_to_org_id was ' || l_sold_to_org_id_tmp) ;
            END IF;
          l_header_rec.sold_to_org_id := l_sold_to_org_id_tmp;
         end if;

       end if;

     end if;
END IF;  -- code control check


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

      IF l_header_adj_rec.operation  = 'INSERT' THEN
         l_header_adj_rec.operation := 'CREATE';
      END IF;

      IF(l_header_adj_count > 0) THEN
        IF(l_header_adj_rec.orig_sys_discount_ref = l_header_adj_tbl(l_header_adj_count).orig_sys_discount_ref) THEN
          --duplicate
          p_return_status := FND_API.G_RET_STS_ERROR;
          l_validate_only := FND_API.G_TRUE;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'YOU ARE ENTERING A DUPLICATE ORIG_SYS_DISCOUNT_REF FOR THE SAME ORDER' ) ;
          END IF;

          FND_MESSAGE.SET_NAME('ONT','OE_OI_DUPLICATE_REF');
          FND_MESSAGE.SET_TOKEN('DUPLICATE_REF','orig_sys_discount_ref');
          OE_MSG_PUB.Add;

        END IF;
      END IF;

      l_header_adj_count := l_header_adj_count + 1;
      l_header_adj_tbl     (l_header_adj_count) := l_header_adj_rec;
      l_header_adj_val_tbl (l_header_adj_count) := l_header_adj_val_rec;

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'HEADER ADJ REF ( '||L_HEADER_ADJ_COUNT||' ) : '|| L_HEADER_ADJ_TBL ( L_HEADER_ADJ_COUNT ) .ORIG_SYS_DISCOUNT_REF ) ;
		END IF;

  END LOOP;
  CLOSE l_header_adj_cursor;


/* -----------------------------------------------------------
   Header Price Attribs
   -----------------------------------------------------------
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE HEADER ATTRIBS LOOP' ) ;
   END IF;

  l_header_att_count := 0;

  OPEN l_header_attrib_cursor;
 LOOP
  FETCH l_header_attrib_cursor
  INTO l_header_price_att_rec.orig_sys_atts_ref
    , l_header_price_att_rec.change_request_code
    , l_header_price_att_rec.creation_date
    , l_header_price_att_rec.created_by
    , l_header_price_att_rec.last_update_date
    , l_header_price_att_rec.last_updated_by
    , l_header_price_att_rec.last_update_login
    , l_header_price_att_rec.program_application_id
    , l_header_price_att_rec.program_id
    , l_header_price_att_rec.program_update_date
    , l_header_price_att_rec.request_id
    , l_header_price_att_rec.flex_title
    , l_header_price_att_rec.pricing_context
    , l_header_price_att_rec.pricing_attribute1
    , l_header_price_att_rec.pricing_attribute2
    , l_header_price_att_rec.pricing_attribute3
    , l_header_price_att_rec.pricing_attribute4
    , l_header_price_att_rec.pricing_attribute5
    , l_header_price_att_rec.pricing_attribute6
    , l_header_price_att_rec.pricing_attribute7
    , l_header_price_att_rec.pricing_attribute8
    , l_header_price_att_rec.pricing_attribute9
    , l_header_price_att_rec.pricing_attribute10
    , l_header_price_att_rec.pricing_attribute11
    , l_header_price_att_rec.pricing_attribute12
    , l_header_price_att_rec.pricing_attribute13
    , l_header_price_att_rec.pricing_attribute14
    , l_header_price_att_rec.pricing_attribute15
    , l_header_price_att_rec.pricing_attribute16
    , l_header_price_att_rec.pricing_attribute17
    , l_header_price_att_rec.pricing_attribute18
    , l_header_price_att_rec.pricing_attribute19
    , l_header_price_att_rec.pricing_attribute20
    , l_header_price_att_rec.pricing_attribute21
    , l_header_price_att_rec.pricing_attribute22
    , l_header_price_att_rec.pricing_attribute23
    , l_header_price_att_rec.pricing_attribute24
    , l_header_price_att_rec.pricing_attribute25
    , l_header_price_att_rec.pricing_attribute26
    , l_header_price_att_rec.pricing_attribute27
    , l_header_price_att_rec.pricing_attribute28
    , l_header_price_att_rec.pricing_attribute29
    , l_header_price_att_rec.pricing_attribute30
    , l_header_price_att_rec.pricing_attribute31
    , l_header_price_att_rec.pricing_attribute32
    , l_header_price_att_rec.pricing_attribute33
    , l_header_price_att_rec.pricing_attribute34
    , l_header_price_att_rec.pricing_attribute35
    , l_header_price_att_rec.pricing_attribute36
    , l_header_price_att_rec.pricing_attribute37
    , l_header_price_att_rec.pricing_attribute38
    , l_header_price_att_rec.pricing_attribute39
    , l_header_price_att_rec.pricing_attribute40
    , l_header_price_att_rec.pricing_attribute41
    , l_header_price_att_rec.pricing_attribute42
    , l_header_price_att_rec.pricing_attribute43
    , l_header_price_att_rec.pricing_attribute44
    , l_header_price_att_rec.pricing_attribute45
    , l_header_price_att_rec.pricing_attribute46
    , l_header_price_att_rec.pricing_attribute47
    , l_header_price_att_rec.pricing_attribute48
    , l_header_price_att_rec.pricing_attribute49
    , l_header_price_att_rec.pricing_attribute50
    , l_header_price_att_rec.pricing_attribute51
    , l_header_price_att_rec.pricing_attribute52
    , l_header_price_att_rec.pricing_attribute53
    , l_header_price_att_rec.pricing_attribute54
    , l_header_price_att_rec.pricing_attribute55
    , l_header_price_att_rec.pricing_attribute56
    , l_header_price_att_rec.pricing_attribute57
    , l_header_price_att_rec.pricing_attribute58
    , l_header_price_att_rec.pricing_attribute59
    , l_header_price_att_rec.pricing_attribute60
    , l_header_price_att_rec.pricing_attribute61
    , l_header_price_att_rec.pricing_attribute62
    , l_header_price_att_rec.pricing_attribute63
    , l_header_price_att_rec.pricing_attribute64
    , l_header_price_att_rec.pricing_attribute65
    , l_header_price_att_rec.pricing_attribute66
    , l_header_price_att_rec.pricing_attribute67
    , l_header_price_att_rec.pricing_attribute68
    , l_header_price_att_rec.pricing_attribute69
    , l_header_price_att_rec.pricing_attribute70
    , l_header_price_att_rec.pricing_attribute71
    , l_header_price_att_rec.pricing_attribute72
    , l_header_price_att_rec.pricing_attribute73
    , l_header_price_att_rec.pricing_attribute74
    , l_header_price_att_rec.pricing_attribute75
    , l_header_price_att_rec.pricing_attribute76
    , l_header_price_att_rec.pricing_attribute77
    , l_header_price_att_rec.pricing_attribute78
    , l_header_price_att_rec.pricing_attribute79
    , l_header_price_att_rec.pricing_attribute80
    , l_header_price_att_rec.pricing_attribute81
    , l_header_price_att_rec.pricing_attribute82
    , l_header_price_att_rec.pricing_attribute83
    , l_header_price_att_rec.pricing_attribute84
    , l_header_price_att_rec.pricing_attribute85
    , l_header_price_att_rec.pricing_attribute86
    , l_header_price_att_rec.pricing_attribute87
    , l_header_price_att_rec.pricing_attribute88
    , l_header_price_att_rec.pricing_attribute89
    , l_header_price_att_rec.pricing_attribute90
    , l_header_price_att_rec.pricing_attribute91
    , l_header_price_att_rec.pricing_attribute92
    , l_header_price_att_rec.pricing_attribute93
    , l_header_price_att_rec.pricing_attribute94
    , l_header_price_att_rec.pricing_attribute95
    , l_header_price_att_rec.pricing_attribute96
    , l_header_price_att_rec.pricing_attribute97
    , l_header_price_att_rec.pricing_attribute98
    , l_header_price_att_rec.pricing_attribute99
    , l_header_price_att_rec.pricing_attribute100
    , l_header_price_att_rec.context
    , l_header_price_att_rec.attribute1
    , l_header_price_att_rec.attribute2
    , l_header_price_att_rec.attribute3
    , l_header_price_att_rec.attribute4
    , l_header_price_att_rec.attribute5
    , l_header_price_att_rec.attribute6
    , l_header_price_att_rec.attribute7
    , l_header_price_att_rec.attribute8
    , l_header_price_att_rec.attribute9
    , l_header_price_att_rec.attribute10
    , l_header_price_att_rec.attribute11
    , l_header_price_att_rec.attribute12
    , l_header_price_att_rec.attribute13
    , l_header_price_att_rec.attribute14
    , l_header_price_att_rec.attribute15
    , l_header_price_att_rec.operation;

    EXIT WHEN l_header_attrib_cursor%NOTFOUND;

    IF( l_header_price_att_rec.operation = 'INSERT') THEN
       l_header_price_att_rec.operation := 'CREATE';
    END IF;
    l_header_price_att_rec.flex_title := 'QP_ATTR_DEFNS_QUALIFIER'; --bug#5679839
 IF( l_header_att_count > 0 ) THEN
   IF (l_header_price_att_rec.orig_sys_atts_ref =l_header_price_att_tbl(l_header_att_count).orig_sys_atts_ref) THEN
     -- duplicate
     p_return_status := FND_API.G_RET_STS_ERROR;
     l_validate_only := FND_API.G_TRUE;
     IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'YOU ARE ENTERING A DUPLICATE ORIG_SYS_ATTS_REF FOR THE SAME ORDER' ) ;
     END IF;
          FND_MESSAGE.SET_NAME('ONT','OE_OI_DUPLICATE_REF');
          FND_MESSAGE.SET_TOKEN('DUPLICATE_REF','orig_sys_ats_ref');
          OE_MSG_PUB.Add;
   END IF;
  END IF;
  l_header_att_count := l_header_att_count +1;
  l_header_price_att_tbl(l_header_att_count) := l_header_price_att_rec;

END LOOP;

CLOSE l_header_attrib_cursor;

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
         , l_header_scredit_rec.change_reason
         , l_header_scredit_rec.change_comments
;
      EXIT WHEN l_header_scredit_cursor%NOTFOUND;

      IF l_header_scredit_rec.operation  = 'INSERT' THEN
         l_header_scredit_rec.operation := 'CREATE';
      END IF;

      IF(l_header_scredit_count > 0) THEN
        IF(l_header_scredit_rec.orig_sys_credit_ref = l_header_scredit_tbl(l_header_scredit_count).orig_sys_credit_ref) THEN
          --duplicate
          p_return_status := FND_API.G_RET_STS_ERROR;
          l_validate_only := FND_API.G_TRUE;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'YOU ARE ENTERING A DUPLICATE ORIG_SYS_CREDIT_REF FORTHE SAME ORDER' ) ;
          END IF;
          FND_MESSAGE.SET_NAME('ONT','OE_OI_DUPLICATE_REF');
          FND_MESSAGE.SET_TOKEN('DUPLICATE_REF','orig_sys_credit_ref');
          OE_MSG_PUB.Add;
        END IF;
      END IF;

      l_header_scredit_count := l_header_scredit_count + 1;
      l_header_scredit_tbl     (l_header_scredit_count) := l_header_scredit_rec;
      l_header_scredit_val_tbl (l_header_scredit_count) := l_header_scredit_val_rec;

      	IF l_debug_level  > 0 THEN
      	    oe_debug_pub.add(  'HEADER SALESCREDIT ( '|| L_HEADER_SCREDIT_COUNT||' ) : '|| L_HEADER_SCREDIT_TBL ( L_HEADER_SCREDIT_COUNT ) .ORIG_SYS_CREDIT_REF ) ;
      	END IF;

  END LOOP;
  CLOSE l_header_scredit_cursor;

/* -----------------------------------------------------------
   Multiple Payments: Header PAYMENTs
   -----------------------------------------------------------
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE HEADER PAYMENTS LOOP' ) ;
   END IF;

  l_header_payment_count := 0;

  OPEN l_header_payment_cursor;
  LOOP
     FETCH l_header_payment_cursor
     INTO  l_header_payment_rec.orig_sys_payment_ref
	 , l_header_payment_rec.change_request_code
	 , l_header_payment_rec.payment_type_code
	 , l_header_payment_val_rec.commitment
	 , l_header_payment_rec.payment_trx_id
	 , l_header_payment_val_rec.receipt_method
	 , l_header_payment_rec.receipt_method_id
	 , l_header_payment_rec.payment_collection_event
	 , l_header_payment_rec.payment_set_id
	 , l_header_payment_rec.prepaid_amount
	 , l_header_payment_rec.credit_card_number
	 , l_header_payment_rec.credit_card_holder_name
	 , l_header_payment_rec.credit_card_expiration_date
	 , l_header_payment_rec.credit_card_code
	 , l_header_payment_rec.credit_card_approval_code
	 , l_header_payment_rec.credit_card_approval_date
	 , l_header_payment_rec.check_number
	 , l_header_payment_rec.payment_amount
	 , l_header_payment_val_rec.payment_percentage
	 , l_header_payment_rec.creation_date
         , l_header_payment_rec.created_by
         , l_header_payment_rec.last_update_date
         , l_header_payment_rec.last_updated_by
         , l_header_payment_rec.last_update_login
         , l_header_payment_rec.program_application_id
         , l_header_payment_rec.program_id
         , l_header_payment_rec.program_update_date
	 , l_header_payment_rec.context
	 , l_header_payment_rec.attribute1
	 , l_header_payment_rec.attribute2
	 , l_header_payment_rec.attribute3
	 , l_header_payment_rec.attribute4
	 , l_header_payment_rec.attribute5
	 , l_header_payment_rec.attribute6
	 , l_header_payment_rec.attribute7
	 , l_header_payment_rec.attribute8
	 , l_header_payment_rec.attribute9
	 , l_header_payment_rec.attribute10
	 , l_header_payment_rec.attribute11
	 , l_header_payment_rec.attribute12
	 , l_header_payment_rec.attribute13
	 , l_header_payment_rec.attribute14
	 , l_header_payment_rec.attribute15
	 , l_header_payment_rec.operation
	 , l_header_payment_rec.status_flag
	 , l_header_payment_rec.payment_number
	 , l_header_payment_rec.header_id
	 , l_header_payment_rec.line_id
         , l_header_payment_rec.DEFER_PAYMENT_PROCESSING_FLAG -- Added for bug 8478559
	 , l_header_payment_rec.trxn_extension_id
         , l_header_payment_rec.instrument_security_code  --R12 CVV2
;
      EXIT WHEN l_header_payment_cursor%NOTFOUND;

      IF l_header_payment_rec.operation  = 'INSERT' THEN
         l_header_payment_rec.operation := 'CREATE';
      END IF;

      IF l_header_payment_rec.operation = 'CREATE' THEN
      -- set it to miss num, so payment number will be generated internally.
         l_header_payment_rec.payment_number :=  FND_API.G_MISS_NUM;
      END IF;

      IF(l_header_payment_count > 0) THEN
        IF(l_header_payment_rec.orig_sys_payment_ref = l_header_payment_tbl(l_header_payment_count).orig_sys_payment_ref) THEN
          --duplicate

          l_validate_only := FND_API.G_TRUE;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'YOU ARE ENTERING A DUPLICATE ORIG_SYS_payment_REF FORTHE SAME ORDER' ) ;
          END IF;
          FND_MESSAGE.SET_NAME('ONT','OE_OI_DUPLICATE_REF');
          FND_MESSAGE.SET_TOKEN('DUPLICATE_REF','orig_sys_payment_ref');
          OE_MSG_PUB.Add;

        END IF;
      END IF;

      l_header_payment_count := l_header_payment_count + 1;
      l_header_payment_tbl     (l_header_payment_count) := l_header_payment_rec;
      l_header_payment_val_tbl (l_header_payment_count) := l_header_payment_val_rec;

      	IF l_debug_level  > 0 THEN
      	    oe_debug_pub.add(  'HEADER PAYMENT ( '|| L_HEADER_PAYMENT_COUNT||' ) : '|| L_HEADER_payment_TBL ( L_HEADER_payment_COUNT ) .ORIG_SYS_payment_REF ) ;
      	END IF;


  END LOOP;
  CLOSE l_header_payment_cursor;
-- end of multiple payments: fetching header payment.

/* myerrams, Bug:4724191
--myerrams, start
select header_id into l_header_id_temp
	from oe_order_headers_all
	where orig_sys_document_ref = l_orig_sys_document_ref;
--myerrams, end
*/

  l_action_request_count := 0;
  OPEN l_action_request_header_cursor;
  LOOP
     FETCH l_action_request_header_cursor
      INTO l_action_rec.orig_sys_line_ref
         , l_action_rec.orig_sys_shipment_ref
	 , l_action_rec.hold_id
	 , l_action_rec.hold_type_code
	 , l_action_rec.hold_type_id
	 , l_action_rec.hold_until_date
	 , l_action_rec.release_reason_code
	 , l_action_rec.comments
	 , l_action_rec.context
	 , l_action_rec.attribute1
	 , l_action_rec.attribute2
	 , l_action_rec.attribute3
	 , l_action_rec.attribute4
	 , l_action_rec.attribute5
	 , l_action_rec.attribute6
	 , l_action_rec.attribute7
	 , l_action_rec.attribute8
	 , l_action_rec.attribute9
	 , l_action_rec.attribute10
	 , l_action_rec.attribute11
	 , l_action_rec.attribute12
	 , l_action_rec.attribute13
	 , l_action_rec.attribute14
	 , l_action_rec.attribute15
	 , l_action_rec.operation_code
	 , l_action_rec.error_flag
	 , l_action_rec.status_flag
	 , l_action_rec.interface_status
--myerrams,start, modified the fetch statement to fetch newly introduced
--fields in oe_actions_interface for Customer Acceptance
	 , l_action_rec.char_param1
	 , l_action_rec.char_param2
	 , l_action_rec.char_param3
	 , l_action_rec.char_param4
	 , l_action_rec.char_param5
	 , l_action_rec.date_param1
	 , l_action_rec.date_param2
	 , l_action_rec.date_param3
	 , l_action_rec.date_param4
	 , l_action_rec.date_param5
--myerrams, end
;
      EXIT WHEN l_action_request_header_cursor%NOTFOUND;
      l_action_request_rec.request_type := l_action_rec.operation_code;

      l_action_request_rec.entity_code := OE_Globals.G_ENTITY_HEADER;
      --l_action_request_rec.entity_id   := l_header_rec_new.header_id;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ACTION CODE: '|| L_ACTION_REQUEST_REC.REQUEST_TYPE , 1 ) ;

          oe_debug_pub.add(  'ENTITY CODE: '|| L_ACTION_REQUEST_REC.ENTITY_CODE , 1 ) ;

          oe_debug_pub.add(  'ENTITY ID : '|| L_ACTION_REQUEST_REC.ENTITY_ID , 1 ) ;
      END IF;

      IF l_action_rec.operation_code = OE_Globals.G_APPLY_HOLD THEN
	 l_action_request_rec.param1  := l_action_rec.hold_id;
	 l_action_request_rec.param2  := nvl(l_action_rec.hold_type_code,'O');
	 l_action_request_rec.param3  := nvl(l_action_rec.hold_type_id,
					     l_action_request_rec.entity_id);
	 l_action_request_rec.param4  := l_action_rec.comments;
	 l_action_request_rec.date_param1  := l_action_rec.hold_until_date;
	 l_action_request_rec.param10 := l_action_rec.context;
	 l_action_request_rec.param11 := l_action_rec.attribute1;
	 l_action_request_rec.param12 := l_action_rec.attribute2;
	 l_action_request_rec.param13 := l_action_rec.attribute3;
	 l_action_request_rec.param14 := l_action_rec.attribute4;
	 l_action_request_rec.param15 := l_action_rec.attribute5;
	 l_action_request_rec.param16 := l_action_rec.attribute6;
	 l_action_request_rec.param17 := l_action_rec.attribute7;
	 l_action_request_rec.param18 := l_action_rec.attribute8;
	 l_action_request_rec.param19 := l_action_rec.attribute9;
	 l_action_request_rec.param20 := l_action_rec.attribute10;
	 l_action_request_rec.param21 := l_action_rec.attribute11;
	 l_action_request_rec.param22 := l_action_rec.attribute12;
	 l_action_request_rec.param23 := l_action_rec.attribute13;
	 l_action_request_rec.param24 := l_action_rec.attribute14;
	 l_action_request_rec.param25 := l_action_rec.attribute15;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'PARAM1/HOLD_ID: ' || L_ACTION_REQUEST_REC.PARAM1 , 1 ) ;

          oe_debug_pub.add(  'PARAM2/HOLD_ENT_CD: '|| L_ACTION_REQUEST_REC.PARAM2 , 1 ) ;

          oe_debug_pub.add(  'PARAM3/HOLD_ENT_ID: '|| L_ACTION_REQUEST_REC.PARAM3 , 1 ) ;

          oe_debug_pub.add(  'PARAM4/HOLD_CMNTS: ' || L_ACTION_REQUEST_REC.PARAM4 , 1 ) ;
      END IF;

      ELSIF l_action_rec.operation_code = OE_Globals.G_RELEASE_HOLD THEN
	 l_action_request_rec.param1  := l_action_rec.hold_id;
	 l_action_request_rec.param2  := nvl(l_action_rec.hold_type_code,'O');
	 l_action_request_rec.param3  := nvl(l_action_rec.hold_type_id,
					     l_action_request_rec.entity_id);
	 l_action_request_rec.param4  := l_action_rec.release_reason_code;
	 l_action_request_rec.param5  := l_action_rec.comments;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'PARAM1/HOLD_ID: ' || L_ACTION_REQUEST_REC.PARAM1 , 1 ) ;

          oe_debug_pub.add(  'PARAM2/HOLD_ENT_CD: '|| L_ACTION_REQUEST_REC.PARAM2 , 1 ) ;

          oe_debug_pub.add(  'PARAM3/HOLD_ENT_ID: '|| L_ACTION_REQUEST_REC.PARAM3 , 1 ) ;

          oe_debug_pub.add(  'PARAM4/REL_REASON: ' || L_ACTION_REQUEST_REC.PARAM4 , 1 ) ;

          oe_debug_pub.add(  'PARAM5/REL_COMMNTS: '|| L_ACTION_REQUEST_REC.PARAM5 , 1 ) ;
      END IF;

--myerrams, introduced the following check for Customer Acceptance.
      ELSIF l_action_rec.operation_code = OE_Globals.G_ACCEPT_FULFILLMENT  OR l_action_rec.operation_code = OE_Globals.G_REJECT_FULFILLMENT THEN
         IF (OE_SYS_PARAMETERS.VALUE('ENABLE_FULFILLMENT_ACCEPTANCE',p_org_id) = 'Y')
	 THEN
        -- Customer Comments
	 l_action_request_rec.param1  := l_action_rec.char_param1;
        -- Customer Signature
	 l_action_request_rec.param2  := l_action_rec.char_param2;
        -- Reference Document
	 l_action_request_rec.param3  := l_action_rec.char_param3;
        -- Implicit Acceptance Flag
	 l_action_request_rec.param4  := l_action_rec.char_param4;
--myerrams, Bug:4724191	 l_action_request_rec.param5  := l_header_id_temp;
        -- Customer Signature Date
	 l_action_request_rec.date_param1  := l_action_rec.date_param1;
         ELSE
--display a message saying Customer Acceptance is not enabled
	       FND_MESSAGE.Set_Name('ONT', 'ONT_CUST_ACC_DISABLED');
	       OE_MSG_PUB.add;
	 END IF;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'PARAM2/CUSTOMER_COMMENTS: ' || L_ACTION_REQUEST_REC.PARAM2 , 1 ) ;

          oe_debug_pub.add(  'PARAM3/CUSTOMER_SIGNATURE: '|| L_ACTION_REQUEST_REC.PARAM3 , 1 ) ;

          oe_debug_pub.add(  'PARAM4/REFERENCE_DOCUMENT: '|| L_ACTION_REQUEST_REC.PARAM4 , 1 ) ;

          oe_debug_pub.add(  'PARAM5/IMPLICIT ACCEPTANCE FLAG: ' || L_ACTION_REQUEST_REC.PARAM5 , 1 ) ;

          oe_debug_pub.add(  'DATE_PARAM1/SIGNATURE_DATE: '|| L_ACTION_REQUEST_REC.DATE_PARAM1 , 1 ) ;
      END IF;
--myerrams, end
      END IF;

      l_action_request_count := l_action_request_count+1;
      l_action_request_tbl(l_action_request_count) := l_action_request_rec;

  END LOOP;
  CLOSE l_action_request_header_cursor;

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
   /* end OPM variables */
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
          --bug#4063831:
          --FP:11I9-12.0CUST_PRODUCTION_SEQ_NUM IS NOT GETTING POPULATED
          -- DURING ORDER IMPORT
         , l_line_rec.cust_production_seq_num
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
      -- { Start add new columns to select for the Add Customer
         , l_line_customer_rec.Orig_Ship_Address_Ref
         , l_line_customer_rec.Orig_Bill_Address_Ref
         , l_line_customer_rec.Orig_Deliver_Address_Ref
         , l_line_customer_rec.Ship_to_Contact_Ref
         , l_line_customer_rec.Bill_to_Contact_Ref
         , l_line_customer_rec.Deliver_to_Contact_Ref
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
         , l_line_rec.change_sequence
	-- automatic account creation {
        , l_line_rec.ship_to_party_id
        , l_line_rec.ship_to_party_site_id
        , l_line_rec.ship_to_party_site_use_id
        , l_line_rec.deliver_to_party_id
        , l_line_rec.deliver_to_party_site_id
        , l_line_rec.deliver_to_party_site_use_id
        , l_line_rec.invoice_to_party_id
        , l_line_rec.invoice_to_party_site_id
        , l_line_rec.invoice_to_party_site_use_id
	-- automatic account creation }
     -- { Distributer Order related change
        , l_line_rec.end_customer_id
        , l_line_rec.end_customer_contact_id
        , l_line_rec.end_customer_site_use_id
        ,l_line_val_rec.end_customer_name  --mvijayku
          , l_line_val_rec.end_customer_site_address1
	 , l_line_val_rec.end_customer_site_address2
	 , l_line_val_rec.end_customer_site_address3
	 , l_line_val_rec.end_customer_site_address4
--	   , l_line_val_rec.end_customer_site_location
	 , l_line_val_rec.end_customer_site_city
	 , l_line_val_rec.end_customer_site_state
	 , l_line_val_rec.end_customer_site_postal_code
	 , l_line_val_rec.end_customer_site_country
	, l_line_val_rec.end_customer_contact
         , l_line_val_rec.end_customer_number
        , l_line_val_rec.ib_owner_dsp
        , l_line_val_rec.ib_current_location_dsp
        , l_line_val_rec.ib_installed_at_location_dsp
        , l_line_rec.ib_owner
        , l_line_rec.ib_current_location
        , l_line_rec.ib_installed_at_location
        , l_line_rec.END_CUSTOMER_PARTY_ID
	 ,l_line_rec.END_CUSTOMER_ORG_CONTACT_ID
         ,l_line_rec.END_CUSTOMER_PARTY_SITE_ID
         ,l_line_rec.END_CUSTOMER_PARTY_SITE_USE_ID
         ,l_line_rec.END_CUSTOMER_PARTY_NUMBER
     -- Distributer Order related change }
     -- Automatic Account Creation
        , l_line_rec.ship_to_party_number
        , l_line_rec.invoice_to_party_number
        , l_line_rec.deliver_to_party_number
     -- Automatic Account Creation
         , l_line_val_rec.deliver_to_address1
         , l_line_val_rec.deliver_to_address2
         , l_line_val_rec.deliver_to_address3
         , l_line_val_rec.deliver_to_address4
         , l_line_val_rec.deliver_to_state
         , l_line_val_rec.deliver_to_county
         , l_line_val_rec.deliver_to_country
         , l_line_val_rec.deliver_to_province
         , l_line_val_rec.deliver_to_city
         , l_line_val_rec.deliver_to_zip
	 , l_line_rec.planning_priority           --Bug#6924881
;
      EXIT WHEN l_line_cursor%NOTFOUND;

    IF l_line_rec.operation  = 'INSERT' THEN
       l_line_rec.operation := 'CREATE';
    END IF;

    --added for BUG#7304558

         IF l_line_rec.operation = 'CREATE' THEN
         	IF l_line_rec.calculate_price_flag IS NULL or l_line_rec.calculate_price_flag = FND_API.G_MISS_CHAR THEN
         		l_line_rec.calculate_price_flag := 'Y';
         	end if;
         ELSE
         BEGIN
         IF l_debug_level  > 0 THEN
    	oe_debug_pub.add(  'OPERATION CODE :'||l_line_rec.operation, 5);
    	oe_debug_pub.add(  'CALCULATE PRICE FLAG'||l_line_rec.calculate_price_flag, 5) ;
    	oe_debug_pub.add(  'UNIT SELLING PRICE'||l_line_rec.unit_selling_price, 5) ;
    	oe_debug_pub.add(  'UNIT LIST PRICE'||l_line_rec.unit_list_price, 5) ;
    	oe_debug_pub.add(  'ORIG_SYS_SHIPMENT_REF'||l_line_rec.orig_sys_shipment_ref, 5) ;
         END IF;
         IF l_line_rec.orig_sys_shipment_ref IS NULL or l_line_rec.orig_sys_shipment_ref = FND_API.G_MISS_CHAR then
         	IF l_line_rec.calculate_price_flag IS NULL or l_line_rec.calculate_price_flag = FND_API.G_MISS_CHAR then
         		--populate calculate_price_flag from lines table
         		SELECT calculate_price_flag
    		INTO   l_line_rec.calculate_price_flag
    		FROM   OE_ORDER_LINES_ALL
    		WHERE  orig_sys_document_ref = l_line_rec.orig_sys_document_ref
    		AND    orig_sys_line_ref = l_line_rec.orig_sys_line_ref;

    		IF l_debug_level  > 0 THEN
    		oe_debug_pub.add(  'CALCULATE PRICE FLAG'||l_line_rec.calculate_price_flag, 5) ;
         		END IF;

         		if l_line_rec.calculate_price_flag in ('P', 'N') then

         			if (l_line_rec.unit_selling_price is null or l_line_rec.unit_selling_price = FND_API.G_MISS_NUM)
         			   AND (l_line_rec.unit_list_price is null or l_line_rec.unit_list_price = FND_API.G_MISS_NUM)
         			THEN
         				SELECT unit_selling_price,unit_list_price
    				INTO   l_line_rec.unit_selling_price,l_line_rec.unit_list_price
    				FROM   OE_ORDER_LINES_ALL
    				WHERE  orig_sys_document_ref = l_line_rec.orig_sys_document_ref
    				AND    orig_sys_line_ref = l_line_rec.orig_sys_line_ref;

    				IF l_debug_level  > 0 THEN
    				oe_debug_pub.add(  'UNIT SELLING PRICE/UNIT LIST PRICE'||l_line_rec.unit_selling_price||'/'||l_line_rec.unit_list_price, 5);
    				END IF;

         			end if;

         		end if;
         --//added to handle the case when user will populate CPF
         	ELSIF l_line_rec.calculate_price_flag in ('P', 'N') then

    		if (l_line_rec.unit_selling_price is null or l_line_rec.unit_selling_price = FND_API.G_MISS_NUM)
    		    AND (l_line_rec.unit_list_price is null or l_line_rec.unit_list_price = FND_API.G_MISS_NUM)
    		THEN
    			SELECT unit_selling_price,unit_list_price
    			INTO   l_line_rec.unit_selling_price,l_line_rec.unit_list_price
    			FROM   OE_ORDER_LINES_ALL
    			WHERE  orig_sys_document_ref = l_line_rec.orig_sys_document_ref
    			AND    orig_sys_line_ref = l_line_rec.orig_sys_line_ref;

    			IF l_debug_level  > 0 THEN
    			oe_debug_pub.add(  'UNIT SELLING PRICE/UNIT LIST PRICE'||l_line_rec.unit_selling_price||'/'||l_line_rec.unit_list_price, 5);
    			END IF;
         	       end if;
         --//added to handle the case when user will populate CPF
         	END IF;
         ELSE --if orig_sys_shipment_ref is populated(split line case)
           	  IF l_line_rec.calculate_price_flag IS NULL or l_line_rec.calculate_price_flag = FND_API.G_MISS_CHAR then
    	   --populate calculate_price_flag from lines table
    		SELECT calculate_price_flag
    		INTO   l_line_rec.calculate_price_flag
    		FROM   OE_ORDER_LINES_ALL
    		WHERE  orig_sys_document_ref = l_line_rec.orig_sys_document_ref
    		AND    orig_sys_line_ref = l_line_rec.orig_sys_line_ref
    		AND    orig_sys_shipment_ref = l_line_rec.orig_sys_shipment_ref;

    		IF l_debug_level  > 0 THEN
    		oe_debug_pub.add(  'CALCULATE PRICE FLAG'||l_line_rec.calculate_price_flag, 5) ;
    		END IF;

    		if l_line_rec.calculate_price_flag in ('P', 'N') then

    			if (l_line_rec.unit_selling_price is null or l_line_rec.unit_selling_price = FND_API.G_MISS_NUM)
    			   AND (l_line_rec.unit_list_price is null or l_line_rec.unit_list_price = FND_API.G_MISS_NUM)
    			THEN
    				SELECT unit_selling_price,unit_list_price
    				INTO   l_line_rec.unit_selling_price,l_line_rec.unit_list_price
    				FROM   OE_ORDER_LINES_ALL
    				WHERE  orig_sys_document_ref = l_line_rec.orig_sys_document_ref
    				AND    orig_sys_line_ref = l_line_rec.orig_sys_line_ref
    				AND    orig_sys_shipment_ref = l_line_rec.orig_sys_shipment_ref;

    				IF l_debug_level  > 0 THEN
    				oe_debug_pub.add(  'UNIT SELLING PRICE/UNIT LIST PRICE'||l_line_rec.unit_selling_price||'/'||l_line_rec.unit_list_price, 5);
    				END IF;

    			end if;

    		end if;
         --//added to handle the case when user will populate CPF
    	ELSIF l_line_rec.calculate_price_flag in ('P', 'N') then

    		if (l_line_rec.unit_selling_price is null or l_line_rec.unit_selling_price = FND_API.G_MISS_NUM)
    		    AND (l_line_rec.unit_list_price is null or l_line_rec.unit_list_price = FND_API.G_MISS_NUM)
    		THEN
    			SELECT unit_selling_price,unit_list_price
    			INTO   l_line_rec.unit_selling_price,l_line_rec.unit_list_price
    			FROM   OE_ORDER_LINES_ALL
    			WHERE  orig_sys_document_ref = l_line_rec.orig_sys_document_ref
    			AND    orig_sys_line_ref = l_line_rec.orig_sys_line_ref
    			AND    orig_sys_shipment_ref = l_line_rec.orig_sys_shipment_ref;

    			IF l_debug_level  > 0 THEN
    			oe_debug_pub.add(  'UNIT SELLING PRICE/UNIT LIST PRICE'||l_line_rec.unit_selling_price||'/'||l_line_rec.unit_list_price, 5);
    			END IF;

    	       end if;
         --//added to handle the case when user will populate CPF
         	END IF;
         END IF; --end of orig_sys_shipment_ref check
    	EXCEPTION
    	WHEN NO_DATA_FOUND THEN
    	IF l_debug_level  > 0 THEN
    		oe_debug_pub.add(  'CALCULATE_PRICE_FLAG/UNIT SELLING PRICE/UNIT LIST PRICE NOT FOUND', 5) ;
    	END IF;
    	WHEN TOO_MANY_ROWS THEN
    	IF l_debug_level  > 0 THEN
    		oe_debug_pub.add(  'TOO MANY ROWS ERROR: '||SQLERRM) ;
    	END IF;
    	WHEN OTHERS THEN
    	IF l_debug_level  > 0 THEN
    		oe_debug_pub.add(  'UNEXPECTED ERROR: '||SQLERRM ) ;
    	END IF;
    	END;
        END IF;

       --added for BUG#7304558

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



    IF(l_line_count > 0) THEN
     IF OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110508' THEN
      IF (l_line_rec.orig_sys_line_ref = l_line_tbl(l_line_count).orig_sys_line_ref) AND
         (l_line_rec.orig_sys_shipment_ref = l_line_tbl(l_line_count).orig_sys_shipment_ref) AND
         (G_IMPORT_SHIPMENTS = 'YES') THEN
        --duplicate
        p_return_status := FND_API.G_RET_STS_ERROR;
        l_validate_only := FND_API.G_TRUE;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'YOU ARE ENTERING EITHER A DUPLICATE ORIG_SYS_LINE_REF OR ORIG_SYS_SHIPMENT_REF FOR THE SAME ORDER' ) ;
        END IF;
        FND_MESSAGE.SET_NAME('ONT','OE_OI_DUPLICATE_REF');
        FND_MESSAGE.SET_TOKEN('DUPLICATE_REF','orig_sys_line_ref and orig_sys_shipment_ref');
        OE_MSG_PUB.Add;
      ELSIF
        (l_line_rec.orig_sys_line_ref = l_line_tbl(l_line_count).orig_sys_line_ref) AND
        (G_IMPORT_SHIPMENTS = 'NO') THEN
        p_return_status := FND_API.G_RET_STS_ERROR;
        l_validate_only := FND_API.G_TRUE;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'YOU ARE ENTERING A DUPLICATE ORIG_SYS_LINE_REF FOR THE SAME ORDER' ) ;
        END IF;
        FND_MESSAGE.SET_NAME('ONT','OE_OI_DUPLICATE_REF');
        FND_MESSAGE.SET_TOKEN('DUPLICATE_REF','orig_sys_line_ref');
        OE_MSG_PUB.Add;
      END IF;
     ELSIF
       OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL < '110508' THEN
       IF (l_line_rec.orig_sys_line_ref = l_line_tbl(l_line_count).orig_sys_line_ref) THEN
         p_return_status := FND_API.G_RET_STS_ERROR;
         l_validate_only := FND_API.G_TRUE;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'YOU ARE ENTERING A DUPLICATE ORIG_SYS_LINE_REF FOR THESAME ORDER' ) ;
         END IF;
         FND_MESSAGE.SET_NAME('ONT','OE_OI_DUPLICATE_REF');
         FND_MESSAGE.SET_TOKEN('DUPLICATE_REF','orig_sys_line_ref');
         OE_MSG_PUB.Add;
       END IF;
     END IF;
    END IF;

     -- BUG 1282873
    IF OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL < '110509' THEN
    -- do not allow the override atp flag before Pack I
       l_line_rec.override_atp_date_code := NULL;
    END IF;

    IF OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510' THEN
       IF l_line_rec.order_source_id = OE_Acknowledgment_Pub.G_XML_ORDER_SOURCE_ID
          AND l_line_rec.xml_transaction_type_code = OE_Acknowledgment_Pub.G_TRANSACTION_CHO THEN
          l_line_rec.cso_response_flag := l_header_cso_response_flag;
          IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'Populated line response flag with :' ||  l_header_cso_response_flag
                                || 'for line ref : ' || l_line_rec.orig_sys_line_ref);
          END IF;
       END IF;
    END IF;

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

	     oe_debug_pub.add(  'ORG_ID = '||L_LINE_REC.ORG_ID ) ;

	     oe_debug_pub.add(  'VALIDATION_ORG_ID = '||L_VALIDATION_ORG ) ;

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
           p_return_status := FND_API.G_RET_STS_ERROR;
	   l_validate_only := FND_API.G_TRUE;
	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add('failure message = ' || substr ( failure_message , 1 , 50 ) ) ;
	       oe_debug_pub.add('failure message = ' || substr ( failure_message , 51 , 50 ) ) ;
	       oe_debug_pub.add('failure message = ' || substr ( failure_message , 101 , 50 ) ) ;
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
  	p_return_status := FND_API.G_RET_STS_ERROR;
	l_validate_only := FND_API.G_TRUE;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'CANNOT IMPORT ORDER AS BOTH INVENTORY_ITEM_ID AND INVENTORY_ITEM_SEGMENTS ARE POPULATED' ) ;

	    oe_debug_pub.add(  'ORDER NO: '||L_ORIG_SYS_DOCUMENT_REF ) ;

	    oe_debug_pub.add(  'ORDER SOURCE: '||L_ORDER_SOURCE_ID ) ;
	END IF;

  END IF;

  -- { Start of fix for bug 2664600
  --  Following code is commented out as the process order no longer error
  --  out if the subinventory is present and it is not able to reserve
  --  because of some error. To check the code here take out the previous version

  -- { Start of the fix to NULL out the subinventory information if
  --   the item has lower level of details defined in mtl_system_items_b
  --   This is required as PO is now not going to send the reservation
  --   record and process order fails, for the mention condition. This
  --   Code will NULL out the subinventory, so the process order does
  --   not fail, and order import behaves in the same way(order imported
  --   even if the reservations fails).
  --   Fixed Bug# 2049995

  -- End of the subinventory related change}
  -- End of fix for bug 2664600 }


    l_line_rec.service_reference_order :=
      nvl(l_line_rec.service_reference_order, FND_API.G_MISS_CHAR);
    l_line_rec.service_reference_line :=
      nvl(l_line_rec.service_reference_line, FND_API.G_MISS_CHAR);

      -- Ignore the fulfilment_set name populated on the lines interface
      -- table if the operation is update

      IF l_line_rec.operation = 'UPDATE' AND
         ((l_line_rec.fulfillment_set IS NOT NULL AND
            l_line_rec.fulfillment_set <> FND_API.G_MISS_CHAR) OR
              (l_line_rec.fulfillment_set_id IS NOT NULL AND
                 l_line_rec.fulfillment_set_id <> FND_API.G_MISS_NUM)) AND
         OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
         oe_debug_pub.add('Ignoring : '|| l_line_rec.fulfillment_set, 1 ) ;
         l_line_rec.fulfillment_set    := NULL;
         l_line_rec.fulfillment_set_id := NULL;
         FND_MESSAGE.Set_Name('ONT','ONT_FULSET_NAME_IGNORED');
         OE_MSG_PUB.Add;
      END IF;



  -- Assign record to line table
    l_line_tbl    (l_line_count) := l_line_rec;
    l_line_val_tbl(l_line_count) := l_line_val_rec;

    --{ Start of the Add customer
    l_line_customer_tbl(l_line_count) := l_line_customer_rec;
    --End of the Add customer}

    if l_line_val_tbl(l_line_count).sold_to_org = FND_API.G_MISS_CHAR then
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'L_LINE_TBL.SERVICE_REFERENCE_ORDER ' || ASCII ( L_LINE_TBL ( L_LINE_COUNT ) .SERVICE_REFERENCE_ORDER ) ) ;

        oe_debug_pub.add(  'L_LINE_VAL_TBL.SOLD_TO_ORG ' || ASCII ( L_LINE_VAL_TBL ( L_LINE_COUNT ) .SOLD_TO_ORG ) ) ;
    END IF;
    end if;

    l_orig_sys_line_ref     := l_line_rec.orig_sys_line_ref;
    l_orig_sys_shipment_ref := l_line_rec.orig_sys_shipment_ref;

	                 IF l_debug_level  > 0 THEN
	                     oe_debug_pub.add(  'ORIG SYS LINE REF ( '||L_LINE_COUNT||' ) : '|| L_LINE_TBL ( L_LINE_COUNT ) .ORIG_SYS_LINE_REF ) ;

			     oe_debug_pub.add(  'ORIG SYS SHIPMENT REF ( '||L_LINE_COUNT||' ) : '|| L_LINE_TBL ( L_LINE_COUNT ) .ORIG_SYS_SHIPMENT_REF ) ;

/* -----------------------------------------------------------
   Line Discounts/Price adjustments
   -----------------------------------------------------------
*/
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
-- Price Adjustment related changes bug# 1220921 (End)
;
      EXIT WHEN l_line_adj_cursor%NOTFOUND;

      l_line_adj_rec.line_index := l_line_count;

      IF l_line_adj_rec.operation  = 'INSERT' THEN
         l_line_adj_rec.operation := 'CREATE';
      END IF;

      l_line_adj_count := l_line_adj_count + 1;
      l_line_adj_tbl     (l_line_adj_count) := l_line_adj_rec;
      l_line_adj_val_tbl (l_line_adj_count) := l_line_adj_val_rec;

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'LINE ADJUSTMENT REF ( '||L_LINE_ADJ_COUNT||' ) : '|| L_LINE_ADJ_TBL ( L_LINE_ADJ_COUNT ) .ORIG_SYS_DISCOUNT_REF ) ;
		END IF;

  END LOOP;
  CLOSE l_line_adj_cursor;


/* -----------------------------------------------------------
   Line Price attribs
   -----------------------------------------------------------
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE LINE ATTRIBS LOOP' ) ;
   END IF;

  OPEN l_line_attrib_cursor;
  LOOP
     FETCH l_line_attrib_cursor
     INTO l_line_price_att_rec.creation_date
    , l_line_price_att_rec.created_by
    , l_line_price_att_rec.last_update_date
    , l_line_price_att_rec.last_updated_by
    , l_line_price_att_rec.last_update_login
    , l_line_price_att_rec.program_application_id
    , l_line_price_att_rec.program_id
    , l_line_price_att_rec.program_update_date
    , l_line_price_att_rec.request_id
    , l_line_price_att_rec.flex_title
    , l_line_price_att_rec.pricing_context
    , l_line_price_att_rec.pricing_attribute1
    , l_line_price_att_rec.pricing_attribute2
    , l_line_price_att_rec.pricing_attribute3
    , l_line_price_att_rec.pricing_attribute4
    , l_line_price_att_rec.pricing_attribute5
    , l_line_price_att_rec.pricing_attribute6
    , l_line_price_att_rec.pricing_attribute7
    , l_line_price_att_rec.pricing_attribute8
    , l_line_price_att_rec.pricing_attribute9
    , l_line_price_att_rec.pricing_attribute10
    , l_line_price_att_rec.pricing_attribute11
    , l_line_price_att_rec.pricing_attribute12
    , l_line_price_att_rec.pricing_attribute13
    , l_line_price_att_rec.pricing_attribute14
    , l_line_price_att_rec.pricing_attribute15
    , l_line_price_att_rec.pricing_attribute16
    , l_line_price_att_rec.pricing_attribute17
    , l_line_price_att_rec.pricing_attribute18
    , l_line_price_att_rec.pricing_attribute19
    , l_line_price_att_rec.pricing_attribute20
    , l_line_price_att_rec.pricing_attribute21
    , l_line_price_att_rec.pricing_attribute22
    , l_line_price_att_rec.pricing_attribute23
    , l_line_price_att_rec.pricing_attribute24
    , l_line_price_att_rec.pricing_attribute25
    , l_line_price_att_rec.pricing_attribute26
    , l_line_price_att_rec.pricing_attribute27
    , l_line_price_att_rec.pricing_attribute28
    , l_line_price_att_rec.pricing_attribute29
    , l_line_price_att_rec.pricing_attribute30
    , l_line_price_att_rec.pricing_attribute31
    , l_line_price_att_rec.pricing_attribute32
    , l_line_price_att_rec.pricing_attribute33
    , l_line_price_att_rec.pricing_attribute34
    , l_line_price_att_rec.pricing_attribute35
    , l_line_price_att_rec.pricing_attribute36
    , l_line_price_att_rec.pricing_attribute37
    , l_line_price_att_rec.pricing_attribute38
    , l_line_price_att_rec.pricing_attribute39
    , l_line_price_att_rec.pricing_attribute40
    , l_line_price_att_rec.pricing_attribute41
    , l_line_price_att_rec.pricing_attribute42
    , l_line_price_att_rec.pricing_attribute43
    , l_line_price_att_rec.pricing_attribute44
    , l_line_price_att_rec.pricing_attribute45
    , l_line_price_att_rec.pricing_attribute46
    , l_line_price_att_rec.pricing_attribute47
    , l_line_price_att_rec.pricing_attribute48
    , l_line_price_att_rec.pricing_attribute49
    , l_line_price_att_rec.pricing_attribute50
    , l_line_price_att_rec.pricing_attribute51
    , l_line_price_att_rec.pricing_attribute52
    , l_line_price_att_rec.pricing_attribute53
    , l_line_price_att_rec.pricing_attribute54
    , l_line_price_att_rec.pricing_attribute55
    , l_line_price_att_rec.pricing_attribute56
    , l_line_price_att_rec.pricing_attribute57
    , l_line_price_att_rec.pricing_attribute58
    , l_line_price_att_rec.pricing_attribute59
    , l_line_price_att_rec.pricing_attribute60
    , l_line_price_att_rec.pricing_attribute61
    , l_line_price_att_rec.pricing_attribute62
    , l_line_price_att_rec.pricing_attribute63
    , l_line_price_att_rec.pricing_attribute64
    , l_line_price_att_rec.pricing_attribute65
    , l_line_price_att_rec.pricing_attribute66
    , l_line_price_att_rec.pricing_attribute67
    , l_line_price_att_rec.pricing_attribute68
    , l_line_price_att_rec.pricing_attribute69
    , l_line_price_att_rec.pricing_attribute70
    , l_line_price_att_rec.pricing_attribute71
    , l_line_price_att_rec.pricing_attribute72
    , l_line_price_att_rec.pricing_attribute73
    , l_line_price_att_rec.pricing_attribute74
    , l_line_price_att_rec.pricing_attribute75
    , l_line_price_att_rec.pricing_attribute76
    , l_line_price_att_rec.pricing_attribute77
    , l_line_price_att_rec.pricing_attribute78
    , l_line_price_att_rec.pricing_attribute79
    , l_line_price_att_rec.pricing_attribute80
    , l_line_price_att_rec.pricing_attribute81
    , l_line_price_att_rec.pricing_attribute82
    , l_line_price_att_rec.pricing_attribute83
    , l_line_price_att_rec.pricing_attribute84
    , l_line_price_att_rec.pricing_attribute85
    , l_line_price_att_rec.pricing_attribute86
    , l_line_price_att_rec.pricing_attribute87
    , l_line_price_att_rec.pricing_attribute88
    , l_line_price_att_rec.pricing_attribute89
    , l_line_price_att_rec.pricing_attribute90
    , l_line_price_att_rec.pricing_attribute91
    , l_line_price_att_rec.pricing_attribute92
    , l_line_price_att_rec.pricing_attribute93
    , l_line_price_att_rec.pricing_attribute94
    , l_line_price_att_rec.pricing_attribute95
    , l_line_price_att_rec.pricing_attribute96
    , l_line_price_att_rec.pricing_attribute97
    , l_line_price_att_rec.pricing_attribute98
    , l_line_price_att_rec.pricing_attribute99
    , l_line_price_att_rec.pricing_attribute100
    , l_line_price_att_rec.context
    , l_line_price_att_rec.attribute1
    , l_line_price_att_rec.attribute2
    , l_line_price_att_rec.attribute3
    , l_line_price_att_rec.attribute4
    , l_line_price_att_rec.attribute5
    , l_line_price_att_rec.attribute6
    , l_line_price_att_rec.attribute7
    , l_line_price_att_rec.attribute8
    , l_line_price_att_rec.attribute9
    , l_line_price_att_rec.attribute10
    , l_line_price_att_rec.attribute11
    , l_line_price_att_rec.attribute12
    , l_line_price_att_rec.attribute13
    , l_line_price_att_rec.attribute14
    , l_line_price_att_rec.attribute15
    , l_line_price_att_rec.operation;

   EXIT WHEN l_line_attrib_cursor%NOTFOUND;
    l_line_price_att_rec.line_index := l_line_count;

    IF l_line_price_att_rec.operation = 'INSERT' THEN
      l_line_price_att_rec.operation  := 'CREATE';
    END IF;
    --bug#5679839
   IF l_line_price_att_rec.flex_title = 'QP_ATTR_DEFNS_PRICING' or
      l_line_price_att_rec.flex_title = 'QP_ATTR_DEFNS_QUALIFIER' THEN
      null;
   ELSE
      l_line_price_att_rec.flex_title := 'QP_ATTR_DEFNS_PRICING';
   END IF;
   --bug#5679839
/*
    IF  ( l_line_att_count > 0) THEN
     IF(l_line_price_att_rec.orig_sys_line_ref = l_line_price_att_tbl(l_line_att_count).orig_sys_line_ref) AND
       (l_line_rec.orig_sys_line_ref = l_line_tbl(l_line_count).orig_sys_line_ref )  THEN
       --duplicate
       p_return_status := FND_API.G_RET_STS_ERROR;
       l_validate_only := FND_API.G_TRUE;
       oe_debug_pub.add('You are entering a duplicate orig_sys_att_refat the line level for the same order');
       FND_MESSAGE.SET_NAME('ONT','OE_OI_DUPLICATE_REF');
       FND_MESSAGE.SET_TOKEN('DUPLICATE_REF','orig_sys_price_att_ref');
       OE_MSG_PUB.Add;
     END IF;
    END IF;
*/
        l_line_att_count := l_line_att_count+1;
        l_line_price_att_tbl (l_line_att_count):=l_line_price_att_rec;
--      oe_debug_pub.add('Line Price ATT ('||l_line_att_count||'):'||l_line_price_att_tbl(l_line_att_count).orig_sys_line_ref);

END LOOP;
  CLOSE l_line_attrib_cursor;

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
         , l_line_scredit_rec.change_reason
         , l_line_scredit_rec.change_comments
;
      EXIT WHEN l_line_scredit_cursor%NOTFOUND;

      l_line_scredit_rec.line_index := l_line_count;

      IF l_line_scredit_rec.operation  = 'INSERT' THEN
         l_line_scredit_rec.operation := 'CREATE';
      END IF;

      l_line_scredit_count := l_line_scredit_count + 1;
      l_line_scredit_tbl     (l_line_scredit_count) := l_line_scredit_rec;
      l_line_scredit_val_tbl (l_line_scredit_count) := l_line_scredit_val_rec;

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'LINE SALESCREDITS REF ( '||L_LINE_SCREDIT_COUNT||' ) : '|| L_LINE_SCREDIT_TBL ( L_LINE_SCREDIT_COUNT ) .ORIG_SYS_CREDIT_REF ) ;
		END IF;

  END LOOP;
  CLOSE l_line_scredit_cursor;


/* -----------------------------------------------------------
   Multiple Payments: Line Payments
   -----------------------------------------------------------
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE LINE PAYMENTS LOOP' ) ;
   END IF;

   --l_line_payment_count := 0;     Commented for the Bug3419970

  OPEN l_line_payment_cursor;
  LOOP
     FETCH l_line_payment_cursor
     INTO  l_line_payment_rec.orig_sys_payment_ref
	 , l_line_payment_rec.change_request_code
	 , l_line_payment_rec.payment_type_code
	 , l_line_payment_val_rec.commitment
	 , l_line_payment_rec.payment_trx_id
	 , l_line_payment_val_rec.receipt_method
	 , l_line_payment_rec.receipt_method_id
	 , l_line_payment_rec.payment_collection_event
	 , l_line_payment_rec.payment_set_id
	 , l_line_payment_rec.prepaid_amount
	 , l_line_payment_rec.credit_card_number
	 , l_line_payment_rec.credit_card_holder_name
	 , l_line_payment_rec.credit_card_expiration_date
	 , l_line_payment_rec.credit_card_code
	 , l_line_payment_rec.credit_card_approval_code
	 , l_line_payment_rec.credit_card_approval_date
	 , l_line_payment_rec.check_number
	 , l_line_payment_rec.payment_amount
	 , l_line_payment_val_rec.payment_percentage
	 , l_line_payment_rec.creation_date
         , l_line_payment_rec.created_by
         , l_line_payment_rec.last_update_date
         , l_line_payment_rec.last_updated_by
         , l_line_payment_rec.last_update_login
         , l_line_payment_rec.program_application_id
         , l_line_payment_rec.program_id
         , l_line_payment_rec.program_update_date
	 , l_line_payment_rec.context
	 , l_line_payment_rec.attribute1
	 , l_line_payment_rec.attribute2
	 , l_line_payment_rec.attribute3
	 , l_line_payment_rec.attribute4
	 , l_line_payment_rec.attribute5
	 , l_line_payment_rec.attribute6
	 , l_line_payment_rec.attribute7
	 , l_line_payment_rec.attribute8
	 , l_line_payment_rec.attribute9
	 , l_line_payment_rec.attribute10
	 , l_line_payment_rec.attribute11
	 , l_line_payment_rec.attribute12
	 , l_line_payment_rec.attribute13
	 , l_line_payment_rec.attribute14
	 , l_line_payment_rec.attribute15
	 , l_line_payment_rec.operation
	 , l_line_payment_rec.status_flag
	 , l_line_payment_rec.payment_number
	 , l_line_payment_rec.header_id
	 , l_line_payment_rec.line_id
         , l_line_payment_rec.DEFER_PAYMENT_PROCESSING_FLAG -- Added for bug 8478559
	 , l_line_payment_rec.trxn_extension_id
         , l_line_payment_rec.instrument_security_code  --R12 CVV2
;
      EXIT WHEN l_line_payment_cursor%NOTFOUND;

      l_line_payment_rec.line_index := l_line_count;

      IF l_line_payment_rec.operation  = 'INSERT' THEN
         l_line_payment_rec.operation := 'CREATE';
      END IF;

      IF l_line_payment_rec.operation = 'CREATE' THEN
      -- set it to miss num, so payment number will be generated internally.
         l_line_payment_rec.payment_number :=  FND_API.G_MISS_NUM;
      END IF;

      l_line_payment_count := l_line_payment_count + 1;
      l_line_payment_tbl     (l_line_payment_count) := l_line_payment_rec;
      l_line_payment_val_tbl (l_line_payment_count) := l_line_payment_val_rec;

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'LINE PAYMENT REF ( '||L_LINE_payment_COUNT||' ) : '|| L_LINE_payment_TBL ( L_LINE_payment_COUNT ) .ORIG_SYS_PAYMENT_REF ) ;
		END IF;

  END LOOP;
  CLOSE l_line_payment_cursor;
-- end of multiple payments: fetching line payments.

/* -----------------------------------------------------------
   Line Lot Serials
   -----------------------------------------------------------
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE LINE LOT SERIALS LOOP' ) ;
   END IF;

  OPEN l_lot_serial_cursor;
  LOOP
     FETCH l_lot_serial_cursor
      INTO l_lot_serial_rec.orig_sys_lotserial_ref
	 , l_lot_serial_rec.change_request_code
	 , l_lot_serial_rec.lot_number
--	 , l_lot_serial_rec.sublot_number -- OPM 3322359 INVCONV
	 , l_lot_serial_rec.from_serial_number
	 , l_lot_serial_rec.to_serial_number
	 , l_lot_serial_rec.quantity
	 , l_lot_serial_rec.quantity2 -- OPM 3322359
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
	 , l_lot_serial_rec.status_flag
;
      EXIT WHEN l_lot_serial_cursor%NOTFOUND;

      l_lot_serial_rec.line_index := l_line_count;

      IF l_lot_serial_rec.operation  = 'INSERT' THEN
         l_lot_serial_rec.operation := 'CREATE';
      END IF;

      l_lot_serial_count := l_lot_serial_count + 1;
      l_lot_serial_tbl (l_lot_serial_count) := l_lot_serial_rec;

	        IF l_debug_level  > 0 THEN
	            oe_debug_pub.add(  'LINE LOT SERIAL REF ( '||L_LOT_SERIAL_COUNT||' ) : '|| L_LOT_SERIAL_TBL ( L_LOT_SERIAL_COUNT ) .ORIG_SYS_LOTSERIAL_REF ) ;
	        END IF;

  END LOOP;
  CLOSE l_lot_serial_cursor;


/* -----------------------------------------------------------
   Line Reservation Details
   -----------------------------------------------------------
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE LINE RESERVATIONS LOOP' ) ;
   END IF;

  OPEN l_reservation_cursor;
  LOOP
     FETCH l_reservation_cursor
      INTO l_reservation_rec.orig_sys_reservation_ref
	 , l_reservation_rec.revision
	 , l_reservation_rec.lot_number_id
	 , l_reservation_val_rec.lot_number
	 , l_reservation_rec.subinventory_id
	 , l_reservation_val_rec.subinventory_code
	 , l_reservation_rec.locator_id
	 , l_reservation_rec.quantity
	 , l_reservation_rec.quantity2 -- INVCONV
	 , l_reservation_rec.attribute_category
	 , l_reservation_rec.attribute1
	 , l_reservation_rec.attribute2
	 , l_reservation_rec.attribute3
	 , l_reservation_rec.attribute4
	 , l_reservation_rec.attribute5
	 , l_reservation_rec.attribute6
	 , l_reservation_rec.attribute7
	 , l_reservation_rec.attribute8
	 , l_reservation_rec.attribute9
	 , l_reservation_rec.attribute10
	 , l_reservation_rec.attribute11
	 , l_reservation_rec.attribute12
	 , l_reservation_rec.attribute13
	 , l_reservation_rec.attribute14
	 , l_reservation_rec.attribute15
	 , l_reservation_rec.operation
;
      EXIT WHEN l_reservation_cursor%NOTFOUND;

      l_reservation_rec.line_index := l_line_count;

      IF l_reservation_rec.operation  = 'INSERT' THEN
         l_reservation_rec.operation := 'CREATE';
      END IF;

      l_reservation_count := l_reservation_count + 1;
      l_reservation_tbl     (l_reservation_count) := l_reservation_rec;
      l_reservation_val_tbl (l_reservation_count) := l_reservation_val_rec;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'LINE RESERVATION REF ( '||L_RESERVATION_COUNT||' ) : '|| L_RESERVATION_TBL ( L_RESERVATION_COUNT ) .ORIG_SYS_RESERVATION_REF ) ;
        END IF;

  END LOOP;
  CLOSE l_reservation_cursor;

--bsadri
  --l_action_request_count := 0;

  OPEN l_action_request_line_cursor;
  LOOP
     FETCH l_action_request_line_cursor
      INTO l_action_rec.orig_sys_line_ref
         , l_action_rec.orig_sys_shipment_ref
	 , l_action_rec.hold_id
	 , l_action_rec.hold_type_code
	 , l_action_rec.hold_type_id
	 , l_action_rec.hold_until_date
	 , l_action_rec.release_reason_code
	 , l_action_rec.comments
	 , l_action_rec.context
	 , l_action_rec.attribute1
	 , l_action_rec.attribute2
	 , l_action_rec.attribute3
	 , l_action_rec.attribute4
	 , l_action_rec.attribute5
	 , l_action_rec.attribute6
	 , l_action_rec.attribute7
	 , l_action_rec.attribute8
	 , l_action_rec.attribute9
	 , l_action_rec.attribute10
	 , l_action_rec.attribute11
	 , l_action_rec.attribute12
	 , l_action_rec.attribute13
	 , l_action_rec.attribute14
	 , l_action_rec.attribute15
	 , l_action_rec.operation_code
         , l_action_rec.fulfillment_set_name
	 , l_action_rec.error_flag
	 , l_action_rec.status_flag
	 , l_action_rec.interface_status
--myerrams,start, modified the fetch statement to fetch newly introduced
--fields in oe_actions_interface for Customer Acceptance
	 , l_action_rec.char_param1
	 , l_action_rec.char_param2
	 , l_action_rec.char_param3
	 , l_action_rec.char_param4
	 , l_action_rec.char_param5
	 , l_action_rec.date_param1
	 , l_action_rec.date_param2
	 , l_action_rec.date_param3
	 , l_action_rec.date_param4
	 , l_action_rec.date_param5
--myerrams, end
;
      EXIT WHEN l_action_request_line_cursor%NOTFOUND;

      l_action_request_rec.request_type := l_action_rec.operation_code;

      IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' AND
         (l_action_rec.operation_code = OE_GLOBALS.G_ADD_FULFILLMENT_SET OR
          l_action_rec.operation_code = OE_GLOBALS.G_REMOVE_FULFILLMENT_SET) THEN

          l_action_request_rec.param5 :=  l_action_rec.fulfillment_set_name;
      END IF;

      l_action_request_rec.entity_code := OE_Globals.G_ENTITY_LINE;
      l_action_request_rec.entity_index := l_line_count;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ACTION CODE: '|| L_ACTION_REQUEST_REC.REQUEST_TYPE , 1 ) ;

          oe_debug_pub.add(  'ENTITY CODE: '|| L_ACTION_REQUEST_REC.ENTITY_CODE , 1 ) ;

          oe_debug_pub.add(  'ENTITY ID : '|| L_ACTION_REQUEST_REC.ENTITY_ID , 1 ) ;
      END IF;

      IF l_action_rec.operation_code = OE_Globals.G_APPLY_HOLD THEN
	 l_action_request_rec.param1  := l_action_rec.hold_id;
	 l_action_request_rec.param2  := nvl(l_action_rec.hold_type_code,'O');
	 l_action_request_rec.param3  := nvl(l_action_rec.hold_type_id,
					     l_action_request_rec.entity_id);
	 l_action_request_rec.param4  := l_action_rec.comments;
	 l_action_request_rec.date_param1  := l_action_rec.hold_until_date;
	 l_action_request_rec.param10 := l_action_rec.context;
	 l_action_request_rec.param11 := l_action_rec.attribute1;
	 l_action_request_rec.param12 := l_action_rec.attribute2;
	 l_action_request_rec.param13 := l_action_rec.attribute3;
	 l_action_request_rec.param14 := l_action_rec.attribute4;
	 l_action_request_rec.param15 := l_action_rec.attribute5;
	 l_action_request_rec.param16 := l_action_rec.attribute6;
	 l_action_request_rec.param17 := l_action_rec.attribute7;
	 l_action_request_rec.param18 := l_action_rec.attribute8;
	 l_action_request_rec.param19 := l_action_rec.attribute9;
	 l_action_request_rec.param20 := l_action_rec.attribute10;
	 l_action_request_rec.param21 := l_action_rec.attribute11;
	 l_action_request_rec.param22 := l_action_rec.attribute12;
	 l_action_request_rec.param23 := l_action_rec.attribute13;
	 l_action_request_rec.param24 := l_action_rec.attribute14;
	 l_action_request_rec.param25 := l_action_rec.attribute15;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'PARAM1/HOLD_ID: ' || L_ACTION_REQUEST_REC.PARAM1 , 1 ) ;

          oe_debug_pub.add(  'PARAM2/HOLD_ENT_CD: '|| L_ACTION_REQUEST_REC.PARAM2 , 1 ) ;

          oe_debug_pub.add(  'PARAM3/HOLD_ENT_ID: '|| L_ACTION_REQUEST_REC.PARAM3 , 1 ) ;

          oe_debug_pub.add(  'PARAM4/HOLD_CMNTS: ' || L_ACTION_REQUEST_REC.PARAM4 , 1 ) ;
      END IF;

      ELSIF l_action_rec.operation_code = OE_Globals.G_RELEASE_HOLD THEN
	 l_action_request_rec.param1  := l_action_rec.hold_id;
	 l_action_request_rec.param2  := nvl(l_action_rec.hold_type_code,'O');
	 l_action_request_rec.param3  := nvl(l_action_rec.hold_type_id,
					     l_action_request_rec.entity_id);
	 l_action_request_rec.param4  := l_action_rec.release_reason_code;
	 l_action_request_rec.param5  := l_action_rec.comments;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'PARAM1/HOLD_ID: ' || L_ACTION_REQUEST_REC.PARAM1 , 1 ) ;

          oe_debug_pub.add(  'PARAM2/HOLD_ENT_CD: '|| L_ACTION_REQUEST_REC.PARAM2 , 1 ) ;

          oe_debug_pub.add(  'PARAM3/HOLD_ENT_ID: '|| L_ACTION_REQUEST_REC.PARAM3 , 1 ) ;

          oe_debug_pub.add(  'PARAM4/REL_REASON: ' || L_ACTION_REQUEST_REC.PARAM4 , 1 ) ;

          oe_debug_pub.add(  'PARAM5/REL_COMMNTS: '|| L_ACTION_REQUEST_REC.PARAM5 , 1 ) ;
      END IF;

--myerrams, introduced the following check for Customer Acceptance.
      ELSIF  l_action_rec.operation_code = OE_Globals.G_ACCEPT_FULFILLMENT OR l_action_rec.operation_code = OE_Globals.G_REJECT_FULFILLMENT THEN
         IF (OE_SYS_PARAMETERS.VALUE('ENABLE_FULFILLMENT_ACCEPTANCE',p_org_id) = 'Y')
	 THEN
        -- Customer Comments
	 l_action_request_rec.param1  := l_action_rec.char_param1;
        -- Customer Signature
	 l_action_request_rec.param2  := l_action_rec.char_param2;
        -- Reference Document
	 l_action_request_rec.param3  := l_action_rec.char_param3;
        -- Implicit Acceptance Flag
	 l_action_request_rec.param4  := l_action_rec.char_param4;
        -- Customer Signature Date
	 l_action_request_rec.date_param1  := l_action_rec.date_param1;

--myerrams, Bug:4724191	 l_action_request_rec.param5 := l_header_id_temp;

         ELSE
--display a message saying Customer Acceptance is not enabled
   	       FND_MESSAGE.Set_Name('ONT', 'ONT_CUST_ACC_DISABLED');
	       OE_MSG_PUB.add;
	 END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'PARAM2/CUSTOMER_COMMENTS: ' || L_ACTION_REQUEST_REC.PARAM2 , 1 ) ;

          oe_debug_pub.add(  'PARAM3/CUSTOMER_SIGNATURE: '|| L_ACTION_REQUEST_REC.PARAM3 , 1 ) ;

          oe_debug_pub.add(  'PARAM4/REFERENCE_DOCUMENT: '|| L_ACTION_REQUEST_REC.PARAM4 , 1 ) ;

          oe_debug_pub.add(  'PARAM5/IMPLICIT ACCEPTANCE FLAG: ' || L_ACTION_REQUEST_REC.PARAM5 , 1 ) ;

          oe_debug_pub.add(  'DATE_PARAM1/SIGNATURE_DATE: '|| L_ACTION_REQUEST_REC.DATE_PARAM1 , 1 ) ;
      END IF;
--myerrams, end
      END IF;

      l_action_request_count := l_action_request_count+1;
      l_action_request_tbl(l_action_request_count) := l_action_request_rec;

  END LOOP;
  CLOSE l_action_request_line_cursor;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'LINES L_ACTION_REQUEST_COUNT : '||L_ACTION_REQUEST_COUNT ) ;
  END IF;

  END LOOP;			/* Lines cursor */
  CLOSE l_line_cursor;

/* -----------------------------------------------------------
   Action Requests header
   -----------------------------------------------------------
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE ACTION REQUEST HEADER LOOP' ) ;
   END IF;

  --l_action_request_count := 0;


/* -----------------------------------------------------------
   Call Order Import Pre-Process
   -----------------------------------------------------------
*/
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'BEFORE CALLING ORDERIMPORT PRE-PROCESS' ) ;
     END IF;


     OE_ORDER_IMPORT_SPECIFIC_PVT.Pre_Process(
   	 p_x_header_rec			=> l_header_rec
  	,p_x_header_adj_tbl		=> l_header_adj_tbl
        ,p_x_header_price_att_tbl       => l_header_price_att_tbl
        ,p_x_header_adj_att_tbl         => l_header_adj_att_tbl
        ,p_x_header_adj_assoc_tbl      => l_header_adj_assoc_tbl
  	,p_x_header_scredit_tbl		=> l_header_scredit_tbl
  	,p_x_header_payment_tbl		=> l_header_payment_tbl
  	,p_x_line_tbl			=> l_line_tbl
  	,p_x_line_adj_tbl		=> l_line_adj_tbl
        ,p_x_line_price_att_tbl         => l_line_price_att_tbl
        ,p_x_line_adj_att_tbl           => l_line_adj_att_tbl
        ,p_x_line_adj_assoc_tbl         => l_line_adj_assoc_tbl
  	,p_x_line_scredit_tbl		=> l_line_scredit_tbl
  	,p_x_line_payment_tbl		=> l_line_payment_tbl
  	,p_x_lot_serial_tbl		=> l_lot_serial_tbl
  	,p_x_reservation_tbl		=> l_reservation_tbl
        ,p_x_action_request_tbl         => l_action_request_tbl
--put back the action table for booked order processing
  	,p_x_header_val_rec		=> l_header_val_rec
  	,p_x_header_adj_val_tbl		=> l_header_adj_val_tbl
  	,p_x_header_scredit_val_tbl	=> l_header_scredit_val_tbl
  	,p_x_header_payment_val_tbl	=> l_header_payment_val_tbl
  	,p_x_line_val_tbl		=> l_line_val_tbl
  	,p_x_line_adj_val_tbl		=> l_line_adj_val_tbl
  	,p_x_line_scredit_val_tbl	=> l_line_scredit_val_tbl
  	,p_x_line_payment_val_tbl	=> l_line_payment_val_tbl
  	,p_x_lot_serial_val_tbl		=> l_lot_serial_val_tbl
  	,p_x_reservation_val_tbl	=> l_reservation_val_tbl

  --{ Start of the variable declaration for the add customer
        ,p_header_customer_rec          => l_header_customer_rec
        ,p_line_customer_tbl            => l_line_customer_tbl
  --End of the variable declaration for the add customer}
  	,p_return_status		=> l_return_status_oi_pre

	);

/* -----------------------------------------------------------
   Set Return Status
   -----------------------------------------------------------
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'PRE-PROCESS RETURN STATUS: '||L_RETURN_STATUS_OI_PRE ) ;
   END IF;

   IF    l_return_status_oi_pre IN (FND_API.G_RET_STS_ERROR)
   AND   p_return_status    NOT IN (FND_API.G_RET_STS_ERROR,
			                     FND_API.G_RET_STS_UNEXP_ERROR)
   THEN  p_return_status :=         FND_API.G_RET_STS_ERROR;
   ELSIF l_return_status_oi_pre IN (FND_API.G_RET_STS_UNEXP_ERROR)
   AND   p_return_status    NOT IN (FND_API.G_RET_STS_ERROR,
			            FND_API.G_RET_STS_UNEXP_ERROR)
   THEN  p_return_status :=         FND_API.G_RET_STS_UNEXP_ERROR;
   END IF;

-- aksingh
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'P_RETURN_STATUS AFTER PRE-PROCESS : '|| P_RETURN_STATUS ) ;

/* -----------------------------------------------------------
   Set control flags for Process_Order
   -----------------------------------------------------------
*/
       oe_debug_pub.add(  'BEFORE SETTING UP CONTROL FLAGS' ) ;
   END IF;

   l_init_msg_list := FND_API.G_FALSE;

/* -----------------------------------------------------------
   If the Order Import validation failed, we still want the
   Process_Order to do the validation but not import.
   -----------------------------------------------------------
*/
   IF l_return_status_oi_pre <> FND_API.G_RET_STS_SUCCESS THEN
-- aksingh
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'PRE-PROCESS FAILED SETTTING L_VALIDATE_ONLY TO TRUE' ) ;
      END IF;
      l_validate_only := FND_API.G_TRUE;
   END IF;

/* -----------------------------------------------------------
   Set the api service level to Validate_only for Process_Order
   -----------------------------------------------------------
*/
   IF l_validate_only = FND_API.G_TRUE THEN
-- aksingh
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SETTTING L_API_SERVICE_LEVEL TO VALIDATE_ONLY' ) ;
      END IF;
      l_api_service_level := OE_GLOBALS.G_VALIDATION_ONLY;
-- Following is added to fix the bug# 1267887
-- It will allow the processing of all the line if API is called in
-- validate only mode
   --   l_control_rec.process_partial := TRUE;
      l_control_rec.controlled_operation := TRUE;
   END IF;
   l_control_rec.controlled_operation := TRUE; -- Bug #1913056
   l_control_rec.process_partial := TRUE;

   -- bug 3636884, set require_reason to true
   l_control_rec.require_reason := TRUE;

/* -----------------------------------------------------------
   This procedure sets the global G_RESET_APPS_CONTEXT to FALSE
   by doing OE_STANDARD_WF.G_RESET_APPS_CONTEXT := FALSE
   -----------------------------------------------------------
*/
   OE_STANDARD_WF.Reset_Apps_Context_Off;
   -- Following line added to fix the code for bug 2756895
   OE_STANDARD_WF.Save_Messages_Off;


/* -----------------------------------------------------------
   Call Process_Order
   -----------------------------------------------------------
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE CALLING PROCESS_ORDER' ) ;

       oe_debug_pub.add(  'BEFORE L_HEADER.OPERATION ' || L_HEADER_REC.OPERATION ) ;
       oe_debug_pub.add('trim data = '||l_rtrim_data);
   END IF;

   If l_action_request_tbl.count > 0 then
       oe_debug_pub.add('action table count = '|| l_action_request_tbl.count);
       l_action_request_tbl_old := l_action_request_tbl;
       oe_debug_pub.add('action table old count = '|| l_action_request_tbl_old.count);

   End If;

   OE_GLOBALS.G_FAIL_ORDER_IMPORT := FALSE; /* Bug # 4036765 */

   OE_GLOBALS.G_ORDER_IMPORT_CALL := TRUE; -- Bug 7367433

      OE_Order_Grp.Process_Order(
	     p_api_version_number 		=> 1
        ,p_init_msg_list 		=> l_init_msg_list
        ,p_validation_level 		=> l_validation_level
        ,p_return_values 		=> l_return_values
        ,p_commit 			=> l_commit
        ,p_api_service_level 		=> l_api_service_level
    	,p_control_rec 			=> l_control_rec
        ,p_header_rec 			=> l_header_rec
        ,p_header_adj_tbl		=> l_header_adj_tbl
        ,p_header_price_att_tbl		=> l_header_price_att_tbl
        ,p_header_adj_att_tbl		=> l_header_adj_att_tbl
        ,p_header_adj_assoc_tbl		=> l_header_adj_assoc_tbl
        ,p_header_Scredit_tbl		=> l_header_scredit_tbl
        ,p_header_payment_tbl		=> l_header_payment_tbl
        ,p_line_tbl 			=> l_line_tbl
        ,p_line_adj_tbl			=> l_line_adj_tbl
        ,p_line_price_att_tbl		=> l_line_price_att_tbl
        ,p_line_adj_att_tbl		=> l_line_adj_att_tbl
        ,p_line_adj_assoc_tbl		=> l_line_adj_assoc_tbl
        ,p_line_scredit_tbl		=> l_line_scredit_tbl
        ,p_line_payment_tbl		=> l_line_payment_tbl
        ,p_lot_serial_tbl		=> l_lot_serial_tbl
	,p_action_request_tbl 		=> l_action_request_tbl_old
        ,p_header_val_rec 		=> l_header_val_rec
        ,p_header_adj_val_tbl		=> l_header_adj_val_tbl
        ,p_header_Scredit_val_tbl	=> l_header_scredit_val_tbl
        ,p_header_payment_val_tbl	=> l_header_payment_val_tbl
        ,p_line_val_tbl 		=> l_line_val_tbl
        ,p_line_adj_val_tbl		=> l_line_adj_val_tbl
        ,p_line_scredit_val_tbl		=> l_line_scredit_val_tbl
        ,p_line_payment_val_tbl		=> l_line_payment_val_tbl
        ,p_lot_serial_val_tbl		=> l_lot_serial_val_tbl
        ,p_old_header_rec 		=> l_header_rec_old
        ,p_old_header_adj_tbl 		=> l_header_adj_tbl_old
        ,p_old_header_price_att_tbl 	=> l_header_price_att_tbl_old
        ,p_old_header_adj_att_tbl 	=> l_header_adj_att_tbl_old
        ,p_old_header_adj_assoc_tbl 	=> l_header_adj_assoc_tbl_old
        ,p_old_header_Scredit_tbl 	=> l_header_scredit_tbl_old
        ,p_old_header_payment_tbl 	=> l_header_payment_tbl_old
        ,p_old_line_tbl 		=> l_line_tbl_old
        ,p_old_line_adj_tbl 		=> l_line_adj_tbl_old
        ,p_old_line_price_att_tbl 	=> l_line_price_att_tbl_old
        ,p_old_line_adj_att_tbl 	=> l_line_adj_att_tbl_old
        ,p_old_line_adj_assoc_tbl 	=> l_line_adj_assoc_tbl_old
        ,p_old_line_scredit_tbl 	=> l_line_scredit_tbl_old
        ,p_old_line_payment_tbl 	=> l_line_payment_tbl_old
        ,p_old_lot_serial_tbl		=> l_lot_serial_tbl_old
        ,p_old_header_val_rec 		=> l_header_val_rec_old
        ,p_old_header_adj_val_tbl	=> l_header_adj_val_tbl_old
        ,p_old_header_Scredit_val_tbl	=> l_header_scredit_val_tbl_old
        ,p_old_header_payment_val_tbl	=> l_header_payment_val_tbl_old
        ,p_old_line_val_tbl 		=> l_line_val_tbl_old
        ,p_old_line_adj_val_tbl		=> l_line_adj_val_tbl_old
        ,p_old_line_scredit_val_tbl	=> l_line_scredit_val_tbl_old
        ,p_old_line_payment_val_tbl	=> l_line_payment_val_tbl_old
        ,p_old_lot_serial_val_tbl	=> l_lot_serial_val_tbl_old
        ,p_rtrim_data                   => l_rtrim_data
        ,x_header_rec 			=> l_header_rec_new
        ,x_header_adj_tbl 		=> l_header_adj_tbl_new
        ,x_header_price_att_tbl 	=> l_header_price_att_tbl_new
        ,x_header_adj_att_tbl 		=> l_header_adj_att_tbl_new
        ,x_header_adj_assoc_tbl 	=> l_header_adj_assoc_tbl_new
        ,x_header_scredit_tbl 		=> l_header_scredit_tbl_new
        ,x_header_payment_tbl 		=> l_header_payment_tbl_new
        ,x_line_tbl 			=> l_line_tbl_new
        ,x_line_adj_tbl         	=> l_line_adj_tbl_new
        ,x_line_price_att_tbl 		=> l_line_price_att_tbl_new
        ,x_line_adj_att_tbl 		=> l_line_adj_att_tbl_new
        ,x_line_adj_assoc_tbl 		=> l_line_adj_assoc_tbl_new
        ,x_line_scredit_tbl		=> l_line_Scredit_tbl_new
        ,x_line_payment_tbl		=> l_line_payment_tbl_new
        ,x_lot_serial_tbl		=> l_lot_serial_tbl_new
	,x_action_request_tbl   	=> l_action_request_tbl
        ,x_header_val_rec 		=> l_header_val_rec_new
        ,x_header_adj_val_tbl		=> l_header_adj_val_tbl_new
        ,x_header_Scredit_val_tbl	=> l_header_scredit_val_tbl_new
        ,x_header_payment_val_tbl	=> l_header_payment_val_tbl_new
        ,x_line_val_tbl 		=> l_line_val_tbl_new
        ,x_line_adj_val_tbl		=> l_line_adj_val_tbl_new
        ,x_line_scredit_val_tbl		=> l_line_scredit_val_tbl_new
        ,x_line_payment_val_tbl		=> l_line_payment_val_tbl_new
        ,x_lot_serial_val_tbl		=> l_lot_serial_val_tbl_new
        ,x_return_status 		=> l_return_status_po
        ,x_msg_count 			=> p_msg_count
        ,x_msg_data 			=> p_msg_data
	,p_validate_desc_flex           => p_validate_desc_flex --bug 4343612
	);

   OE_GLOBALS.G_ORDER_IMPORT_CALL := FALSE; -- Bug 7367433

   -- For Actions call is directly made to delayed request
   -- Process_Order_Action, which is changed from the calling
   -- process_order group appi twice
   -- once for normal processing and next for processing actions
   -- Right now call to the process order is commented down
   -- will be removed later

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'PROCESS_ORDER RETURN STATUS BEFORE ACTION : '||L_RETURN_STATUS_PO , 1 ) ;
      END IF;

   /* Bug # 4036765 */
   IF OE_GLOBALS.G_FAIL_ORDER_IMPORT THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'G_FAIL_ORDER_IMPORT WAS SET TO TRUE.  SETTING PROCESS_ORDER RETURN STATUS TO FAILURE' , 1 ) ;
      END IF;
      l_return_status_po := FND_API.G_RET_STS_ERROR;
   END IF;

   IF l_return_status_po IN (FND_API.G_RET_STS_ERROR,
                                 FND_API.G_RET_STS_UNEXP_ERROR) THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'PROCESS ORDER FAILED. NO NEED TO CALL FOR ACTIONS' , 1 ) ;
      END IF;
   ELSE --{
      l_header_rec 			:= OE_Order_Pub.G_MISS_HEADER_REC;
      l_header_rec            := l_header_rec_new;
  END IF; -- return status error }

   For i in 1..l_action_request_tbl.count
   Loop
     If l_action_request_tbl(i).return_status <>
        FND_API.G_RET_STS_SUCCESS
     Then
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'FAILED TO PERFORM ACTION REQUEST ' || L_ACTION_REQUEST_TBL ( I ) .REQUEST_TYPE , 1 ) ;
        END IF;
       fnd_file.put_line(FND_FILE.OUTPUT,
        'Failed to perform Action Request ' ||
        l_action_request_tbl(i).request_type);
     End If;
   End Loop;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'AFTER CALLING PROCESS_ORDER' , 3 ) ;

/* -----------------------------------------------------------
   Set Return Status
   -----------------------------------------------------------
*/
       oe_debug_pub.add(  'PROCESS_ORDER RETURN STATUS: '||L_RETURN_STATUS_PO , 3 ) ;
   END IF;

   IF    l_return_status_po  IN (FND_API.G_RET_STS_ERROR)
   AND   p_return_status NOT IN (FND_API.G_RET_STS_ERROR,
			                  FND_API.G_RET_STS_UNEXP_ERROR)
   THEN  p_return_status :=      FND_API.G_RET_STS_ERROR;
   ELSIF l_return_status_po  IN (FND_API.G_RET_STS_UNEXP_ERROR)
   AND   p_return_status NOT IN (FND_API.G_RET_STS_ERROR,
			                  FND_API.G_RET_STS_UNEXP_ERROR)
   THEN  p_return_status :=      FND_API.G_RET_STS_UNEXP_ERROR;
   END IF;


   -- aksingh
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'P_RETURN_STATUS '||P_RETURN_STATUS , 3 ) ;
   END IF;

/* -----------------------------------------------------------
   Check Process_Order Results
   -----------------------------------------------------------
*/
   IF p_msg_count = 0 THEN
      IF l_return_status_po = FND_API.G_RET_STS_ERROR THEN
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'PROCESS ORDER FAILED WITH ERRORS BUT RETURNED NO MESSAGE' ) ;
	 END IF;
	 FND_MESSAGE.SET_NAME('ONT','OE_OI_PO_ERROR');
         OE_MSG_PUB.Add;
      ELSIF l_return_status_po = FND_API.G_RET_STS_UNEXP_ERROR THEN
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'PROCESS ORDER FAILED WITH UNEXPECTED ERRORS BUT RETURNED NO MESSAGE... ' ) ;
	 END IF;
	 FND_MESSAGE.SET_NAME('ONT','OE_OI_PO_UNEXP_ERROR');
         OE_MSG_PUB.Add;
      END IF;
   END IF;

   IF l_header_rec.operation IN ('INSERT', 'CREATE') AND
      l_return_status_po = FND_API.G_RET_STS_SUCCESS
   THEN
				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'HEADER ID GENERATED: '|| TO_CHAR ( L_HEADER_REC_NEW.HEADER_ID ) ) ;

				    oe_debug_pub.add(  'ORDER NUMBER GENERATED: '|| TO_CHAR ( L_HEADER_REC_NEW.ORDER_NUMBER ) ) ;
				END IF;
   END IF;


/* -----------------------------------------------------------
   Call Order Import Post-Process
   -----------------------------------------------------------
*/
   IF l_return_status_po = FND_API.G_RET_STS_SUCCESS THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE CALLING ORDERIMPORT POST-PROCESS' ) ;
      END IF;

      OE_ORDER_IMPORT_SPECIFIC_PVT.Post_Process(
   	 p_x_header_rec			=> l_header_rec_new
  	,p_x_header_adj_tbl		=> l_header_adj_tbl_new
        ,p_x_header_price_att_tbl       => l_header_price_att_tbl_new
        ,p_x_header_adj_att_tbl         => l_header_adj_att_tbl_new
        ,p_x_header_adj_assoc_tbl       => l_header_adj_assoc_tbl_new
  	,p_x_header_scredit_tbl		=> l_header_scredit_tbl_new
  	,p_x_line_tbl			=> l_line_tbl_new
  	,p_x_line_adj_tbl		=> l_line_adj_tbl_new
        ,p_x_line_price_att_tbl         => l_line_price_att_tbl_new
        ,p_x_line_adj_att_tbl           => l_line_adj_att_tbl_new
        ,p_x_line_adj_assoc_tbl         => l_line_adj_assoc_tbl_new
  	,p_x_line_scredit_tbl		=> l_line_scredit_tbl_new
  	,p_x_lot_serial_tbl		=> l_lot_serial_tbl_new

  	,p_x_header_val_rec		=> l_header_val_rec_new
  	,p_x_header_adj_val_tbl		=> l_header_adj_val_tbl_new
  	,p_x_header_scredit_val_tbl	=> l_header_scredit_val_tbl_new
  	,p_x_line_val_tbl		=> l_line_val_tbl_new
  	,p_x_line_adj_val_tbl		=> l_line_adj_val_tbl_new
  	,p_x_line_scredit_val_tbl	=> l_line_scredit_val_tbl_new
  	,p_x_lot_serial_val_tbl		=> l_lot_serial_val_tbl_new

   	,p_x_header_rec_old		=> l_header_rec
  	,p_x_header_adj_tbl_old		=> l_header_adj_tbl
  	,p_x_header_scredit_tbl_old	=> l_header_scredit_tbl
  	,p_x_line_tbl_old		=> l_line_tbl
  	,p_x_line_adj_tbl_old		=> l_line_adj_tbl
        ,p_x_line_price_att_tbl_old     => l_line_price_att_tbl
  	,p_x_line_scredit_tbl_old	=> l_line_scredit_tbl
  	,p_x_lot_serial_tbl_old		=> l_lot_serial_tbl

  	,p_x_header_val_rec_old		=> l_header_val_rec
  	,p_x_header_adj_val_tbl_old	=> l_header_adj_val_tbl
  	,p_x_header_scredit_val_tbl_old	=> l_header_scredit_val_tbl
  	,p_x_line_val_tbl_old		=> l_line_val_tbl
  	,p_x_line_adj_val_tbl_old	=> l_line_adj_val_tbl
  	,p_x_line_scredit_val_tbl_old	=> l_line_scredit_val_tbl
  	,p_x_lot_serial_val_tbl_old	=> l_lot_serial_val_tbl

  	,p_x_reservation_tbl		=> l_reservation_tbl
  	,p_x_reservation_val_tbl	=> l_reservation_val_tbl

  	,p_return_status		=> l_return_status_oi_pst
	);
   END IF;


/* -----------------------------------------------------------
   Set Return Status
   -----------------------------------------------------------
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'POST-PROCESS RETURN STATUS: '||L_RETURN_STATUS_OI_PST ) ;
   END IF;

   IF    l_return_status_oi_pst IN (FND_API.G_RET_STS_ERROR)
   AND   p_return_status    NOT IN (FND_API.G_RET_STS_ERROR,
			                     FND_API.G_RET_STS_UNEXP_ERROR)
   THEN  p_return_status :=         FND_API.G_RET_STS_ERROR;
   ELSIF l_return_status_oi_pst IN (FND_API.G_RET_STS_UNEXP_ERROR)
   AND   p_return_status    NOT IN (FND_API.G_RET_STS_ERROR,
			                     FND_API.G_RET_STS_UNEXP_ERROR)
   THEN  p_return_status :=         FND_API.G_RET_STS_UNEXP_ERROR;
   END IF;


  --END LOOP;			/* Headers cursor */
  CLOSE l_header_cursor;

/* -----------------------------------------------------------
   Delete order from interface tables
   -----------------------------------------------------------
*/
   -- aksingh
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add('l_validate_only '||l_validate_only ) ;
       oe_debug_pub.add('p_return_status '||p_return_status ) ;
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


      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE CALLING DELETE OF CUSTOMER INFO' ) ;
      END IF;
      OE_INLINE_CUSTOMER_PUB.Delete_Customer_Info(
            p_header_customer_rec   => l_header_customer_rec,
            p_line_customer_tbl     => l_line_customer_tbl
           );
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'AFTER CALLING DELETE OF CUSTOMER INFO' ) ;


/* -----------------------------------------------------------
      Set Return Status
   -----------------------------------------------------------
*/
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
          -- For Bug 7367433
          -- From Order Import we will make a call to Verfify Payment, only after committing the data.
          -- The call to Verify Payment from Booking code is suppressed for Order Import flow.
          -- This change is only for Verify Payment call that is triggered as part of Booking.
          IF nvl(OE_GLOBALS.G_PAYMENT_PROCESSED, 'N') = 'O' THEN
           BEGIN
             SAVEPOINT VERIFY_PAYMENT;

             if l_debug_level > 5 then
               oe_debug_pub.add('Calling Verify Payment from Order Import, after committing data', 5);
             end if;
             OE_Verify_Payment_PUB.Verify_Payment
                  ( p_header_id           => l_header_rec_new.header_id
                  , p_calling_action      => 'BOOKING'
                  , p_msg_count           => l_msg_count_vp
                  , p_msg_data            => l_msg_data_vp
                  , p_return_status       => l_return_status
                  );
            EXCEPTION WHEN OTHERS THEN
              l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            END;

            if l_debug_level > 0 then
              oe_debug_pub.add('After Verify Payment from Order Import Status : ' || l_return_status, 5);
            end if;

             IF l_return_status = FND_API.G_RET_STS_ERROR OR l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 ROLLBACK TO SAVEPOINT VERIFY_PAYMENT;
             END IF;
          END IF;
        -- End of Bug 7367433

   ELSE
      /* Code changes for the bug 6378240 */
      oe_schedule_util.call_mrp_rollback(x_return_status => l_return_status);

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
            SET error_flag = 'Y', xml_message_id = nvl(xml_message_id, l_header_rec.xml_message_id)
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
/* Fixing Bug #2026177 and processing the out nocopy table from process order */

      BEGIN
         FOR I in 1..l_header_adj_tbl_new.count
         LOOP
  	   IF l_debug_level  > 0 THEN
  	       oe_debug_pub.add(  'BEFORE UPDATING ERROR FLAG FOR HEADER PRICE ADJUSTMENTS' ) ;
  	   END IF;
   	   IF l_header_adj_tbl_new(I).return_status IN (
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
	          = nvl(l_header_adj_tbl_new(I).orig_sys_discount_ref,
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

/* 1433292  */
      BEGIN
         FOR I in 1..l_header_price_att_tbl_new.count
         LOOP
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'BEFORE UPDATING ERROR FLAG FOR HEADER PRICE ATT' ) ;
           END IF;
           IF l_header_price_att_tbl_new(I).return_status IN (
                                        FND_API.G_RET_STS_ERROR,
                                        FND_API.G_RET_STS_UNEXP_ERROR)
           THEN
           BEGIN
             UPDATE oe_price_atts_interface
                SET error_flag = 'Y'
              WHERE order_source_id             = l_order_source_id
                AND orig_sys_document_ref       = l_orig_sys_document_ref
                AND nvl(sold_to_org_id,                  FND_API.G_MISS_NUM)
                  = nvl(l_sold_to_org_id,                FND_API.G_MISS_NUM)
                AND nvl(sold_to_org,                  FND_API.G_MISS_CHAR)
                  = nvl(l_sold_to_org,                FND_API.G_MISS_CHAR)
                AND nvl(  change_sequence,      FND_API.G_MISS_CHAR)
                  = nvl(l_change_sequence,      FND_API.G_MISS_CHAR)
                AND nvl(  request_id,           FND_API.G_MISS_NUM)
                  = nvl(l_request_id,           FND_API.G_MISS_NUM);
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
         FOR I in 1..l_header_scredit_tbl_new.count
         LOOP
  	   IF l_debug_level  > 0 THEN
  	       oe_debug_pub.add(  'BEFORE UPDATING ERROR FLAG FOR HEADER SALES CREDITS' ) ;
  	   END IF;
   	   IF l_header_scredit_tbl_new(I).return_status IN (
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
	          = nvl(l_header_scredit_tbl_new(I).orig_sys_credit_ref,
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

      -- multiple payments: header payments start...

      BEGIN
         FOR I in 1..l_header_payment_tbl_new.count
         LOOP
  	   IF l_debug_level  > 0 THEN
  	       oe_debug_pub.add(  'BEFORE UPDATING ERROR FLAG FOR HEADER PAYMENTS' ) ;
  	   END IF;
   	   IF l_header_payment_tbl_new(I).return_status IN (
					FND_API.G_RET_STS_ERROR,
		  	          	FND_API.G_RET_STS_UNEXP_ERROR)
   	   THEN
           BEGIN
	     UPDATE oe_payments_interface
                SET error_flag = 'Y'
              WHERE order_source_id		= l_order_source_id
                AND orig_sys_document_ref 	= l_orig_sys_document_ref
       	        AND nvl(  change_sequence,	FND_API.G_MISS_CHAR)
	          = nvl(l_change_sequence,	FND_API.G_MISS_CHAR)
                AND nvl(  request_id,		FND_API.G_MISS_NUM)
	          = nvl(l_request_id,		FND_API.G_MISS_NUM)
                AND nvl(orig_sys_payment_ref,	FND_API.G_MISS_CHAR)
	          = nvl(l_header_payment_tbl_new(I).orig_sys_payment_ref,
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
      -- end of multiple payments: header payments.


      BEGIN
         FOR I in 1..l_line_tbl_new.count
         LOOP
  	   IF l_debug_level  > 0 THEN
  	       oe_debug_pub.add(  'BEFORE UPDATING ERROR FLAG FOR LINES' ) ;
  	   END IF;
   	   IF l_line_tbl_new(I).return_status IN (
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
	         = nvl(l_line_tbl_new(I).orig_sys_line_ref,    FND_API.G_MISS_CHAR)
               AND nvl(orig_sys_shipment_ref,              FND_API.G_MISS_CHAR)
	         = nvl(l_line_tbl_new(I).orig_sys_shipment_ref,FND_API.G_MISS_CHAR);
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
/*
        l_tbl_index := oe_msg_pub.g_msg_tbl.FIRST;
        LOOP
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'L_TBL_INDEX = '||L_TBL_INDEX ) ;
          END IF;
          If oe_msg_pub.g_msg_tbl(l_tbl_index).entity_code = 'OI_INL_CUSTSUCC'
          Then
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'BEFORE DELETING OI_INL_ADDCUST MSG' ) ;
             END IF;
             --oe_msg_pub.g_msg_tbl(l_tbl_index).message := Null;
             --oe_msg_pub.g_msg_tbl(l_tbl_index).message_text := Null;
             oe_msg_pub.Delete_Msg(p_msg_index => l_tbl_index);
          End If;
          Exit When l_tbl_index = oe_msg_pub.g_msg_tbl.LAST;
          l_tbl_index := oe_msg_pub.g_msg_tbl.NEXT(l_tbl_index);
        End Loop;
*/

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
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'COMMITING' ) ;
         END IF;
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
     l_tbl_index := oe_msg_pub.g_msg_tbl.FIRST;

     LOOP
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'BEFORE CALLING GET' ) ;
       END IF;
       l_msg_order_source_id 		:= '';
       l_msg_orig_sys_document_ref 	:= '';
       l_msg_orig_sys_line_ref     	:= '';
       l_msg_orig_sys_shipment_ref 	:= '';
       l_msg_sold_to_org_id       	:= '';
       l_msg_sold_to_org  	     	:= '';
       l_msg_change_sequence       	:= '';
       l_msg_entity_code	        := '';
       l_msg_entity_ref 	        := '';

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'BEFORE CALLING GET_MSG_CONTEXT' ) ;
       END IF;
       oe_msg_pub.get_msg_context (
     		 p_msg_index                    => l_tbl_index
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

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'AFTER CALLING GET_MSG_CONTEXT' ) ;
        END IF;
	IF oe_msg_pub.g_msg_tbl(l_tbl_index).message_text IS NULL THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'IN INDEX.MESSAGE_TEXT IS NULL' ) ;
          END IF;
    	   p_msg_data := oe_msg_pub.get(l_tbl_index, 'F');
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
			 ', ' || 'Customer Name: '|| rtrim(l_msg_sold_to_org);
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
           ELSIF l_msg_entity_code IN ('HEADER_PAYMENT', 'LINE_PAYMENT') THEN
                 l_msg_context := l_msg_context || ', ' || 'Payment: ';
	   ELSIF l_msg_entity_code IN ('LOT_SERIAL') THEN
	         l_msg_context := l_msg_context || ', ' || 'Lot: ';
	   ELSIF l_msg_entity_code IN ('RESERVATION') THEN
	         l_msg_context := l_msg_context || ', ' || 'Rsrvtn: ';
	   END IF;
	         l_msg_context := l_msg_context || rtrim(l_msg_entity_ref);
	END IF;
	l_msg_data := 'Msg-'||l_tbl_index||' for '||l_msg_context||': '||p_msg_data;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  L_MSG_DATA ) ;
        END IF;
	--bug 4195533
        IF p_return_status = FND_API.G_RET_STS_SUCCESS
           AND l_header_rec.header_id <> FND_API.G_MISS_NUM THEN
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'Header id updated in msg stack:' || l_header_rec.header_id ) ;
           END IF;
           oe_msg_pub.g_msg_tbl(l_tbl_index).header_id := l_header_rec.header_id;
        END IF;
	--bug 4195533
        Exit When l_tbl_index = oe_msg_pub.g_msg_tbl.LAST;
        l_tbl_index := oe_msg_pub.g_msg_tbl.NEXT(l_tbl_index);

     END LOOP;
   END IF;

/* -----------------------------------------------------------
   Delete messages from the database table
   -----------------------------------------------------------
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE DELETING OLD MESSAGES FROM THE DATABASE TABLE' ) ;
   END IF;

/* Commmenting the call to delete message bug 2467558

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


   -- Call to raise the appropriate event for XML transactions
   -- This should only be raised when the profile is set to ASYNCHRONOUS

    -- {Start If for raising event for XML Trans
    If l_header_rec.order_source_id = Oe_Acknowledgment_Pub.G_XML_ORDER_SOURCE_ID Then
       OE_GLOBALS.G_XML_TXN_CODE := NULL;
       IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SET GLOBAL TXN CODE TO NULL' ) ;
       END IF;

     -- Check if Order is Imported
     -- Else Ack will have to be sent from the Inf tables.
     If p_return_status In (FND_API.G_RET_STS_ERROR, FND_API.G_RET_STS_UNEXP_ERROR) Then
       l_order_imported := 'N';
     Else
       l_order_imported := 'Y';
     End If;
     -- raise the appropriate event
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'BEFORE CALLING RAISE_EVENT_FROM_OEOI' ) ;

         oe_debug_pub.add(  'REF = '||L_HEADER_REC.ORIG_SYS_DOCUMENT_REF ) ;
         oe_debug_pub.add('3A8 ACK SEND PROFILE ' || l_cho_ack_send_pfile);
         oe_debug_pub.add('3A7 RESP PROFILE ' || l_cso_response_pfile);
         oe_debug_pub.add('3A8 RESP MSG TYPE ' || l_header_cso_response_flag);
         oe_debug_pub.add('XML TXN CODE ' || l_header_rec.xml_transaction_type_code);
     END IF;

     IF NOT (nvl(l_header_rec.xml_transaction_type_code, FND_API.G_MISS_CHAR) = OE_Acknowledgment_Pub.G_TRANSACTION_CHO
        AND nvl(l_header_cso_response_flag, 'N') = 'Y'
        AND l_cho_ack_send_pfile = 'N'
        AND l_cso_response_pfile = 'Y') THEN

        Oe_Acknowledgment_Pub.Raise_Event_From_Oeoi(
           p_transaction_type       =>  l_header_rec.xml_transaction_type_code,
           p_orig_sys_document_ref  =>  l_header_rec.orig_sys_document_ref,
           p_request_id             =>  l_header_rec.request_id,
           p_order_imported         =>  l_order_imported,
           p_sold_to_org_id         =>  l_header_rec.sold_to_org_id,
           p_change_sequence        =>  l_header_rec.change_sequence,
           p_xml_message_id         =>  l_header_rec.xml_message_id,
           p_org_id                 =>  l_header_rec.org_id,
           x_return_status          =>  l_return_status);

        If p_return_status NOT IN (FND_API.G_RET_STS_ERROR) And
           l_return_status     IN (FND_API.G_RET_STS_ERROR, FND_API.G_RET_STS_UNEXP_ERROR) Then
           p_return_status := l_return_status;
        End If;
     END IF;

   End If;
   -- End If for raising event for XML Trans}
   -- we raise the event in all cases except Synchronous Order Import for XML
   If OE_Code_Control.Code_Release_Level >= '110510' Then
          OE_Acknowledgment_Pub.Raise_Event_XMLInt (
             p_order_source_id        =>  l_header_rec.order_source_id,
             p_partner_document_num   =>  l_header_rec.orig_sys_document_ref,
             p_sold_to_org_id         =>  l_header_rec.sold_to_org_id,
             p_transaction_type       =>  Oe_Acknowledgment_Pub.G_TRANSACTION_TYPE,
             p_transaction_subtype    =>  l_header_rec.xml_transaction_type_code,
             p_itemtype               =>  NULL,
             p_itemkey                =>  NULL,
             p_message_text           =>  NULL,
             p_xmlg_icn               =>  l_header_rec.xml_message_id,
             p_document_num           =>  l_header_rec.order_number,
             p_order_type_id          =>  l_header_rec.order_type_id,
             p_doc_status             =>  p_return_status,
             p_change_sequence        =>  l_header_rec.change_sequence,
             p_org_id                 =>  l_header_rec.org_id,
             p_conc_request_id        =>  l_header_rec.request_id,
             p_header_id              =>  l_header_rec.header_id,
             p_response_flag          =>  l_header_cso_response_flag,
             x_return_status          =>  l_return_status);
          Commit; -- to raise the business event
   End If;

/*-----------------------------------------------------------
  End of Order Import
  -----------------------------------------------------------
*/
--oe_debug_pub.add('End of Order Import');


  EXCEPTION
  WHEN OTHERS THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'UNEXPECTED ERROR: '||SQLERRM ) ;
       END IF;
       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Import_Order');
       END IF;
       p_msg_count := p_msg_count + 1;
       p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

       OE_GLOBALS.G_ORDER_IMPORT_CALL := FALSE; -- Bug 7367433

END IMPORT_ORDER;

END OE_ORDER_IMPORT_PVT;

/
