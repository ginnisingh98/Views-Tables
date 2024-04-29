--------------------------------------------------------
--  DDL for Package QP_PRICE_BOOK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_PRICE_BOOK_PUB" AUTHID CURRENT_USER AS
/*$Header: QPXPPRBS.pls 120.7 2006/04/27 15:11 rchellam noship $*/

TYPE pb_input_header_rec IS RECORD (
	customer_context 		VARCHAR2(30),
	customer_attribute		VARCHAR2(30),
	customer_attr_value		VARCHAR2(240),
        cust_account_id                 NUMBER,
        currency_code			VARCHAR2(30),
	limit_products_by		VARCHAR2(30),
        product_context			VARCHAR2(30),
        product_attribute		VARCHAR2(30),
        product_attr_value		VARCHAR2(240),
        effective_date 			DATE,
        item_quantity			NUMBER,
        pub_template_code		VARCHAR2(80),
 	pub_language			VARCHAR2(6),
 	pub_territory			VARCHAR2(6),
        pub_output_document_type	VARCHAR2(30),
	dlv_xml_flag			VARCHAR2(1),
        dlv_xml_site_id 		NUMBER,
	dlv_email_flag			VARCHAR2(1),
	dlv_email_addresses		VARCHAR2(240),
	dlv_printer_flag		VARCHAR2(1),
	dlv_printer_name		VARCHAR2(80),
	generation_time_code		VARCHAR2(30),
	gen_schedule_date	 	DATE,
	org_id	 			NUMBER,
	price_book_type_code		VARCHAR2(1),
	price_based_on			VARCHAR2(30),
	pl_agr_bsa_id			NUMBER,
	pricing_perspective_code	VARCHAR2(30),
	publish_existing_pb_flag	VARCHAR2(1),
	overwrite_existing_pb_flag	VARCHAR2(1),
	request_origination_code	VARCHAR2(3),
	request_type_code		VARCHAR2(30),--to be removed later
	price_book_name			VARCHAR2(240),
	pl_agr_bsa_name			VARCHAR2(240),
	pub_template_name		VARCHAR2(240));

TYPE pb_input_lines_rec IS RECORD (
	context 			VARCHAR2(30),
	attribute 			VARCHAR2(30),
	attribute_value			VARCHAR2(240),
	attribute_type 			VARCHAR2(30));

TYPE pb_input_lines_tbl IS TABLE OF pb_input_lines_rec
  INDEX BY BINARY_INTEGER;

TYPE price_book_header_rec IS RECORD (
	price_book_header_id		NUMBER,
   	price_book_type_code		VARCHAR2(1),
   	currency_code			VARCHAR2(30),
   	effective_date			DATE,
   	org_id				NUMBER,
   	customer_id			NUMBER,
        cust_account_id                 NUMBER,
        document_id                     NUMBER,
   	item_category			NUMBER,
   	price_based_on			VARCHAR2(30),
   	pl_agr_bsa_id			NUMBER,
   	pricing_perspective_code	VARCHAR2(30),
   	item_quantity			NUMBER,
   	request_id			NUMBER,
   	request_type_code		VARCHAR2(30),
   	pb_input_header_id		NUMBER,
   	pub_status_code			VARCHAR2(30),
   	price_book_name			VARCHAR2(240),
	pl_agr_bsa_name			VARCHAR2(240),
   	creation_date			DATE,
   	created_by			NUMBER,
   	last_update_date		DATE,
   	last_updated_by			NUMBER,
   	last_update_login		NUMBER,
   	price_book_type			VARCHAR2(80),
   	currency			VARCHAR2(240),
   	operating_unit			VARCHAR2(240),
   	customer_name			VARCHAR2(360));

TYPE price_book_lines_rec IS RECORD (
	price_book_line_id              NUMBER,
 	price_book_header_id		NUMBER,
 	item_number                     NUMBER,
	product_uom_code                VARCHAR2(3),
	list_price			NUMBER,
 	net_price                       NUMBER,
	sync_action_code		VARCHAR2(1),
	line_status_code                VARCHAR2(1),
	creation_date                   DATE,
 	created_by                      NUMBER,
 	last_update_date                DATE,
 	last_updated_by                 NUMBER,
 	last_update_login               NUMBER,
        description			VARCHAR2(240), --Item Description
        customer_item_number		VARCHAR2(50),
        customer_item_desc              VARCHAR2(240),
        display_item_number		VARCHAR2(40),
        sync_action			VARCHAR2(80));

TYPE price_book_lines_tbl IS TABLE OF price_book_lines_rec
  INDEX BY BINARY_INTEGER;

TYPE price_book_line_details_rec IS RECORD (
	price_book_line_det_id		NUMBER,
	price_book_line_id		NUMBER,
	price_book_header_id		NUMBER,
	list_header_id			NUMBER,
	list_line_id			NUMBER,
	list_line_no			VARCHAR2(30),
	list_price			NUMBER,
	modifier_operand		NUMBER,
	modifier_application_method	VARCHAR2(30),
	adjustment_amount	 	NUMBER,
	adjusted_net_price	 	NUMBER,
	list_line_type_code	 	VARCHAR2(30),
	price_break_type_code	 	VARCHAR2(30),
        creation_date			DATE,
        created_by			NUMBER,
        last_update_date		DATE,
        last_updated_by			NUMBER,
        last_update_login		NUMBER,
        list_name			VARCHAR2(240),
        list_line_type			VARCHAR2(80),
        price_break_type		VARCHAR2(80),
        application_method_name		VARCHAR2(80));

TYPE price_book_line_details_tbl IS TABLE OF
     price_book_line_details_rec INDEX BY BINARY_INTEGER;

TYPE price_book_attributes_rec IS RECORD (
	price_book_attribute_id		NUMBER,
   	price_book_line_det_id		NUMBER,
   	price_book_line_id		NUMBER,
   	price_book_header_id		NUMBER,
   	pricing_prod_context		VARCHAR2(30),
   	pricing_prod_attribute		VARCHAR2(30),
   	comparison_operator_code	VARCHAR2(30),
   	pricing_prod_attr_value_from	VARCHAR2(240),
   	pricing_attr_value_to		VARCHAR2(240),
  	pricing_prod_attr_datatype	VARCHAR2(30),
   	attribute_type			VARCHAR2(30),
   	creation_date			DATE,
   	created_by			NUMBER,
   	last_update_date		DATE,
   	last_updated_by			NUMBER,
   	last_update_login		NUMBER,
   	context_name			VARCHAR2(240),
   	attribute_name			VARCHAR2(80),
   	attribute_value_name		VARCHAR2(30),
   	attribute_value_to_name 	VARCHAR2(30),
   	comparison_operator_name 	VARCHAR2(80));

TYPE price_book_attributes_tbl IS TABLE OF price_book_attributes_rec
  INDEX BY BINARY_INTEGER;

TYPE price_book_break_lines_rec IS RECORD (
	price_book_break_line_id	NUMBER,
   	price_book_header_id		NUMBER,
   	price_book_line_id		NUMBER,
   	price_book_line_det_id		NUMBER,
	pricing_context			VARCHAR2(30),
   	pricing_attribute		VARCHAR2(30),
   	comparison_operator_code	VARCHAR2(30),
   	pricing_attr_value_from		VARCHAR2(240),
   	pricing_attr_value_to		VARCHAR2(240),
   	pricing_attribute_datatype	VARCHAR2(30),
   	operand				NUMBER,
   	application_method		VARCHAR2(30),
        recurring_value                 NUMBER,
 	creation_date			DATE,
   	created_by			NUMBER,
   	last_update_date		DATE,
   	last_updated_by			NUMBER,
   	last_update_login		NUMBER,
	context_name			VARCHAR2(240),
   	attribute_name			VARCHAR2(80),
   	attribute_value_name		VARCHAR2(30),
   	attribute_value_to_name		VARCHAR2(30),
   	comparison_operator_name	VARCHAR2(80),
   	application_method_name 	VARCHAR2(80));

TYPE price_book_break_lines_tbl IS TABLE OF price_book_break_lines_rec
  INDEX BY BINARY_INTEGER;

TYPE price_book_messages_tbl IS TABLE OF qp_price_book_messages%ROWTYPE
  INDEX BY BINARY_INTEGER;

TYPE documents_rec IS RECORD (
        document_id                     NUMBER,
        document_content                BLOB,
 	document_content_type           VARCHAR2(240),
   	document_name                   VARCHAR2(240),
   	creation_date                   DATE,
   	created_by                      NUMBER,
   	last_update_date                DATE,
   	last_updated_by                 NUMBER,
   	last_update_login               NUMBER);

TYPE VARCHAR_TBL IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;

/*****************************************************************************
 Public API to Create and Publish Full/Delta Price Book
*****************************************************************************/
PROCEDURE Create_Publish_Price_Book(
	p_pb_input_header_rec      IN  pb_input_header_rec,
	p_pb_input_lines_tbl       IN  pb_input_lines_tbl,
	x_request_id               OUT NOCOPY NUMBER,
	x_return_status            OUT NOCOPY VARCHAR2,
	x_retcode                  OUT NOCOPY NUMBER,
	x_err_buf                  OUT NOCOPY VARCHAR2,
	x_price_book_messages_tbl  OUT NOCOPY price_book_messages_tbl);

/*****************************************************************************
 Public API to Query an existing Full/Delta Price Book
*****************************************************************************/
PROCEDURE Get_Price_Book(
    p_price_book_name                IN VARCHAR2,
    p_customer_id                    IN NUMBER,
    p_price_book_type_code           IN VARCHAR2,
    x_price_book_header_rec          OUT NOCOPY price_book_header_rec,
    x_price_book_lines_tbl           OUT NOCOPY price_book_lines_tbl,
    x_price_book_line_details_tbl    OUT NOCOPY price_book_line_details_tbl,
    x_price_book_attributes_tbl      OUT NOCOPY price_book_attributes_tbl,
    x_price_book_break_lines_tbl     OUT NOCOPY price_book_break_lines_tbl,
    x_price_book_messages_tbl        OUT NOCOPY price_book_messages_tbl,
    x_return_status                  OUT NOCOPY VARCHAR2,
    x_query_messages                 OUT NOCOPY VARCHAR_TBL);

/*****************************************************************************
 Overloaded Public API to Query an existing Full/Delta Price Book along with
 the attached formatted (.pdf, etc.) document
*****************************************************************************/
PROCEDURE Get_Price_Book(
    p_price_book_name                IN VARCHAR2,
    p_customer_id                    IN NUMBER,
    p_price_book_type_code           IN VARCHAR2,
    x_price_book_header_rec          OUT NOCOPY price_book_header_rec,
    x_price_book_lines_tbl           OUT NOCOPY price_book_lines_tbl,
    x_price_book_line_details_tbl    OUT NOCOPY price_book_line_details_tbl,
    x_price_book_attributes_tbl      OUT NOCOPY price_book_attributes_tbl,
    x_price_book_break_lines_tbl     OUT NOCOPY price_book_break_lines_tbl,
    x_price_book_messages_tbl        OUT NOCOPY price_book_messages_tbl,
    x_documents_rec                  OUT NOCOPY documents_rec,
    x_return_status                  OUT NOCOPY VARCHAR2,
    x_query_messages                 OUT NOCOPY VARCHAR_TBL);

END QP_PRICE_BOOK_PUB;

 

/
