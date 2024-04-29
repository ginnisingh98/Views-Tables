--------------------------------------------------------
--  DDL for Package Body IBU_ORDER_CAPTURE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBU_ORDER_CAPTURE" AS
/* $Header: ibuordrb.pls 115.43.1159.1 2003/05/23 22:21:46 appldev ship $ */
-- ---------------------------------------------------------
-- Define global variables and types
-- ---------------------------------------------------------
	G_PKG_NAME  CONSTANT                VARCHAR2(100) := 'IBU_ORDER_CAPTURE';

PROCEDURE CREATE_RETURN (
	p_api_version_number     IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
        p_commit       IN VARCHAR          := FND_API.G_FALSE,
	p_header_id    IN	NUMBER,
	HEADER_REC IN HEADER_REC_TYPE,
	HEADER_SHIPMENT_REC IN HEADER_SHIPMENT_REC_TYPE,
	LINE_TBL	IN LINE_TBL_TYPE,
	LINE_DTL_TBL	IN LINE_DTL_TBL_TYPE,
	LINE_SHIPMENT_TBL	IN LINE_SHIPMENT_TBL_TYPE,
	X_MSG_COUNT	OUT     NOCOPY NUMBER,
        X_MSG_DATA	OUT     NOCOPY VARCHAR2,
  	X_RETURN_STATUS	OUT     NOCOPY VARCHAR2,
	X_RETURN_HEADER_REC	OUT	   NOCOPY RETURN_HEADER_REC_TYPE,
	X_RETURN_LINE_TBL	OUT 	   NOCOPY RETURN_LINE_TBL_TYPE
)

AS
	l_api_name			VARCHAR2 (30):= 'CREATE_RETURN';

	l_qte_header_rec	  	ASO_QUOTE_PUB.Qte_Header_Rec_Type;
	l_qte_line_tbl		  	ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
	l_qte_line_dtl_tbl	  	ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
	l_header_shipment_tbl     	ASO_QUOTE_PUB.Shipment_Tbl_Type;
	l_line_shipment_tbl	  	ASO_QUOTE_PUB.Shipment_Tbl_Type;
	l_return_header_rec		ASO_ORDER_INT.Order_Header_Rec_Type;
	l_return_line_tbl		ASO_ORDER_INT.Order_Line_Tbl_type;
	l_control_rec            	ASO_ORDER_INT.Control_Rec_Type;
	l_header_payment_tbl		ASO_QUOTE_PUB.Payment_Tbl_Type;
	l_header_tax_detail_tbl		ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;


	l_header_cursor		  	NUMBER;
	l_header_cursor_stmt	  	VARCHAR2(4000);

	l_dummy_id			NUMBER;

	l_source_document_id	  	NUMBER:= NULL;
	l_org_id			NUMBER:= FND_API.G_MISS_NUM;
	l_source_document_type_id	NUMBER:= NULL;
	l_pricelist_id			NUMBER:= FND_API.G_MISS_NUM;
	l_transaction_curr_code		VARCHAR2 (15):=FND_API.G_MISS_CHAR;
	l_quote_source_code		VARCHAR2(240):=NULL;

	l_line_cursor			NUMBER;
	l_line_cursor_stmt		VARCHAR2(4000);

	l_line_org_id			NUMBER := FND_API.G_MISS_NUM;
	l_ship_from_org_id		NUMBER := FND_API.G_MISS_NUM;
	l_inventory_item_id		NUMBER := FND_API.G_MISS_NUM;
	l_ordered_quantity_uom		VARCHAR2(3) :=FND_API.G_MISS_CHAR;
	l_line_price_list_id		NUMBER :=FND_API.G_MISS_NUM;
	l_unit_list_price		NUMBER :=FND_API.G_MISS_NUM;
	l_unit_selling_price		NUMBER :=FND_API.G_MISS_NUM;

	l_ibu_ret_error_msg		VARCHAR2(4000);
	l_aso_debug_file		VARCHAR2(1000);
	l_ibu_ret_header_info		VARCHAR2(8000);
	l_ibu_ret_header_prpt_info	VARCHAR2(8000);
	l_ibu_ret_head_ship_info	VARCHAR2(8000);
	l_ibu_ret_head_ship_prpt_info	VARCHAR2(8000);
	l_ibu_ret_line_info		VARCHAR2(8000);
	l_ibu_ret_line_dtl_info	VARCHAR2(8000);
	l_ibu_ret_line_prpt_info	VARCHAR2(8000);
	l_ibu_ret_line_dtl_prpt_info	VARCHAR2(8000);

	 l_booked_profile_value		VARCHAR2(100);
	 l_salesrep_id 		NUMBER :=FND_API.G_MISS_NUM;
	 l_person_id 			NUMBER :=FND_API.G_MISS_NUM;

      Cursor Get_order_salesrep_id (p_header_id NUMBER) IS
		select salesrep_id
		from OE_ORDER_HEADERS_ALL
		where header_id = p_header_id;

      Cursor Get_person_id (p_salesrep_id NUMBER) IS
		select person_id
		from ra_salesreps
		where salesrep_id = p_salesrep_id;

	--debug
	 l_x_msg_count			NUMBER;

BEGIN

	-- Turn on ASO debugging
	aso_debug_pub.SetDebugLevel(10);
     	aso_debug_pub.Initialize;
	l_aso_debug_file := ASO_DEBUG_PUB.Set_Debug_Mode('FILE');
     	aso_debug_pub.debug_on;
	l_aso_debug_file := 'debug=' || l_aso_debug_file;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
	    null;
            FND_MSG_PUB.initialize;
	    FND_MSG_PUB.initialize;
        END IF;
	X_Return_Status := FND_API.G_RET_STS_SUCCESS;

	FND_MESSAGE.SET_NAME('IBU','IBU_MESSAGE');
	FND_MESSAGE.SET_TOKEN ('TOKEN', l_aso_debug_file);
	FND_MSG_PUB.Add;


	l_header_cursor_stmt := 'select ord.source_document_id, ord.org_id, ord.source_document_type_id, ord.price_list_id, ord.transactional_curr_code, ord_src.name ';
	l_header_cursor_stmt := l_header_cursor_stmt  || ' from oe_order_headers_all ord, OE_ORDER_SOURCES ord_src  where header_id = :v_a_header_id  and ord.source_document_type_id= ord_src.order_source_id(+)' ;
	l_header_cursor := dbms_sql.open_cursor;
	dbms_sql.parse(l_header_cursor, l_header_cursor_stmt , dbms_sql.NATIVE);

	dbms_sql.bind_variable( l_header_cursor, ':v_a_header_id', p_header_id);

	dbms_sql.define_column (l_header_cursor, 1, l_source_document_id);
	dbms_sql.define_column (l_header_cursor, 2, l_org_id);
	dbms_sql.define_column (l_header_cursor, 3, l_source_document_type_id);
	dbms_sql.define_column (l_header_cursor, 4, l_pricelist_id);
	dbms_sql.define_column (l_header_cursor, 5, l_transaction_curr_code, 15);
	dbms_sql.define_column (l_header_cursor, 6, l_quote_source_code, 240 );



	l_dummy_id :=  dbms_sql.execute (l_header_cursor);

	if ( dbms_sql.fetch_rows(l_header_cursor)>0 ) then
		dbms_sql.column_value(l_header_cursor, 1, l_source_document_id);
		dbms_sql.column_value (l_header_cursor, 2, l_org_id);
		dbms_sql.column_value (l_header_cursor, 3, l_source_document_type_id);
		dbms_sql.column_value (l_header_cursor, 4, l_pricelist_id);
		dbms_sql.column_value (l_header_cursor, 5, l_transaction_curr_code);
		dbms_sql.column_value (l_header_cursor, 6, l_quote_source_code);


	else
		X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('IBU','IBU_RET_REF_ORD_INVALID');
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	end if;

	-- validate org_id, pricelist_id, transaction_curr_code
	if (l_org_id is null OR l_org_id = FND_API.G_MISS_NUM OR l_pricelist_id is null OR l_pricelist_id =   FND_API.G_MISS_NUM OR l_transaction_curr_code is null OR l_transaction_curr_code=  FND_API.G_MISS_CHAR) then
		X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('IBU','IBU_RET_REF_ORD_INVALID');
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	end if;

	--fill l_qte_header_rec

	l_qte_header_rec.quote_header_id := l_source_document_id;
	l_qte_header_rec.org_id := l_org_id;
	l_qte_header_rec.quote_source_code := l_quote_source_code;
	l_qte_header_rec.party_id := HEADER_REC.PARTY_ID;
	l_qte_header_rec.cust_account_id :=  HEADER_REC.CUST_ACCOUNT_ID;
	l_qte_header_rec.org_contact_id :=  HEADER_REC.ORG_CONTACT_ID;
	l_qte_header_rec.invoice_to_party_site_id := HEADER_REC.INVOICE_TO_PARTY_SITE_ID;
	l_qte_header_rec.order_type_id :=  FND_PROFILE.VALUE_WNPS('ASO_ORDER_TYPE_ID'); --1436
	l_qte_header_rec.quote_category_code := 'RETURN';
	l_qte_header_rec.ordered_date := sysdate;
	l_qte_header_rec.price_list_id := l_pricelist_id;
	l_qte_header_rec.currency_code := l_transaction_curr_code;

	-- if/else added by mukhan
	-- obtaining person id from ra_salesreps since Order Capture
	-- internally translates person id to salesrep id

	OPEN Get_order_salesrep_id (p_header_id);
	FETCH Get_order_salesrep_id into l_salesrep_id;
	CLOSE Get_order_salesrep_id ;

	if l_salesrep_id is NULL or l_salesrep_id =  FND_API.G_MISS_NUM then
		if FND_PROFILE.VALUE_WNPS('ASO_DEFAULT_PERSON_ID') is not NULL then
			OPEN Get_person_id ( FND_PROFILE.VALUE_WNPS('ASO_DEFAULT_PERSON_ID'));
			FETCH Get_person_id into l_person_id;
			CLOSE Get_person_id ;
		end if;
	else
          OPEN Get_person_id (l_salesrep_id);
          FETCH Get_person_id into l_person_id;
          CLOSE Get_person_id ;
	end if;

	l_qte_header_rec.employee_person_id := l_person_id;

	l_header_shipment_tbl(1).request_date := sysdate;
	l_header_shipment_tbl(1).schedule_ship_date := HEADER_SHIPMENT_REC.SCHEDULE_SHIP_DATE;
	l_header_shipment_tbl(1).ship_to_party_site_id := 	HEADER_SHIPMENT_REC.SHIP_TO_PARTY_SITE_ID;
	l_header_shipment_tbl(1).freight_carrier_code := HEADER_SHIPMENT_REC.FREIGHT_CARRIER_CODE;

	l_ibu_ret_header_prpt_info := 'l_qte_header_rec::';
	aso_debug_pub.add('IBU: l_qte_header_rec::', 1, 'Y');

	if (l_qte_header_rec.quote_header_id <> FND_API.G_MISS_NUM) then
		l_ibu_ret_header_info := 'quote_header_id = ' || l_qte_header_rec.quote_header_id || ' , ';
	else
		l_ibu_ret_header_info := 'quote_header_id = ';
	end if;
	aso_debug_pub.add  ('IBU:  quote_header_id = ' || l_qte_header_rec.quote_header_id  , 1, 'Y');

	if (l_qte_header_rec.org_id <> FND_API.G_MISS_NUM) then
		l_ibu_ret_header_info := 'org_id = ' || l_qte_header_rec.org_id || ' , ';
	else
		l_ibu_ret_header_info := 'org_id = ';
	end if;

	aso_debug_pub.add  ('IBU: org_id = ' || l_qte_header_rec.org_id , 1, 'Y');

	if ( l_qte_header_rec.quote_source_code <> FND_API.G_MISS_CHAR) then
		l_ibu_ret_header_info := 'quote_source_code = ' || l_qte_header_rec.quote_source_code || ' , ';
	else
		l_ibu_ret_header_info := 'quote_source_code = ';
	end if;
	aso_debug_pub.add  ('IBU:  quote_source_code = ' || l_qte_header_rec.quote_source_code  , 1, 'Y');

	if ( l_qte_header_rec.party_id <> FND_API.G_MISS_NUM ) then
		l_ibu_ret_header_info := 'party_id = ' || l_qte_header_rec.party_id || ' , ';
	else
		l_ibu_ret_header_info := 'party_id =  ';
	end if;
	aso_debug_pub.add  ('IBU:  party_id = ' || l_qte_header_rec.party_id  , 1, 'Y');

	if ( l_qte_header_rec.cust_account_id  <> FND_API.G_MISS_NUM ) then
		l_ibu_ret_header_info :=  'cust_account_id = ' || l_qte_header_rec.cust_account_id || ' , ';
	else
		l_ibu_ret_header_info :=  'cust_account_id = ';
	end if;
	aso_debug_pub.add  ('IBU: cust_account_id = ' || l_qte_header_rec.cust_account_id , 1, 'Y');


	if ( l_qte_header_rec.org_contact_id <> FND_API.G_MISS_NUM ) then
		l_ibu_ret_header_info :=  'org_contact_id = ' || l_qte_header_rec.org_contact_id || ' , ';
	else
		l_ibu_ret_header_info :=  'org_contact_id = ';
	end if;
	aso_debug_pub.add  ('IBU: org_contact_id = ' || l_qte_header_rec.org_contact_id  , 1, 'Y');

	if ( l_qte_header_rec.invoice_to_party_site_id <> FND_API.G_MISS_NUM ) then
		l_ibu_ret_header_info :=  'inv_to_py_site_id= ' || l_qte_header_rec.invoice_to_party_site_id || ' , ';
	else
		l_ibu_ret_header_info :=  'inv_to_py_site_id= ';
	end if;
	aso_debug_pub.add  ('IBU: inv_to_py_site_id= ' || l_qte_header_rec.invoice_to_party_site_id  , 1, 'Y');

	if (  l_qte_header_rec.order_type_id  <> FND_API.G_MISS_NUM ) then
		l_ibu_ret_header_info :=  'order_type_id = ' || l_qte_header_rec.order_type_id || ' , ';
	else
		l_ibu_ret_header_info :=  'order_type_id = ';
	end if;
	aso_debug_pub.add  ('IBU: order_type_id = ' || l_qte_header_rec.order_type_id   , 1, 'Y');

	if ( l_qte_header_rec.quote_category_code  <> FND_API.G_MISS_CHAR ) then
		l_ibu_ret_header_info := 'quote_ca_code = ' || l_qte_header_rec.quote_category_code || ' , ';
	else
		l_ibu_ret_header_info := 'quote_ca_code = ';
	end if;

	aso_debug_pub.add  ('IBU: quote_ca_code = ' || l_qte_header_rec.quote_category_code   , 1, 'Y');

	if ( l_qte_header_rec.ordered_date <>  FND_API.G_MISS_DATE ) then
		l_ibu_ret_header_info := 'ordered_date = ' || l_qte_header_rec.ordered_date || ' , ';
	else
		l_ibu_ret_header_info := 'ordered_date = ';
	end if;

	aso_debug_pub.add  ('IBU:ordered_date = ' || l_qte_header_rec.ordered_date    , 1, 'Y');



	if (  l_qte_header_rec.employee_person_id <> FND_API.G_MISS_NUM ) then
		l_ibu_ret_header_info :=  'emp_person_id = ' || l_qte_header_rec.employee_person_id || ' , ';
	else
		l_ibu_ret_header_info :=  'emp_person_id = ';
	end if;
	aso_debug_pub.add  ('IBU: emp_person_id = ' || l_qte_header_rec.employee_person_id    , 1, 'Y');

	if ( l_qte_header_rec.price_list_id <> FND_API.G_MISS_NUM ) then
		l_ibu_ret_header_info :=  'price_list_id = ' || l_qte_header_rec.price_list_id || ' , ';
	else
		l_ibu_ret_header_info :=  'price_list_id = ';
	end if;
	aso_debug_pub.add  ('IBU: price_list_id = ' || l_qte_header_rec.price_list_id    , 1, 'Y');

	if ( l_qte_header_rec.currency_code  <> FND_API.G_MISS_CHAR) then
		l_ibu_ret_header_info :=  'currency_code = ' || l_qte_header_rec.currency_code || ' , ';
	else
		l_ibu_ret_header_info :=  'currency_code = ';
	end if;
	aso_debug_pub.add  ('IBU: currency_code = ' || l_qte_header_rec.currency_code   , 1, 'Y');

	l_ibu_ret_head_ship_prpt_info := 'l_header_shipment_tbl(1)::';
	aso_debug_pub.add  ('IBU:l_header_shipment_tbl(1)::'   , 1, 'Y');

	if ( l_header_shipment_tbl(1).request_date <> FND_API.G_MISS_DATE) then
		l_ibu_ret_head_ship_info :=  'request_date = ' || l_header_shipment_tbl(1).request_date || ' , ';
	else
		l_ibu_ret_head_ship_info :=  'request_date = ';
	end if;
	aso_debug_pub.add  ('IBU: request_date = ' || l_header_shipment_tbl(1).request_date   , 1, 'Y');

	if ( l_header_shipment_tbl(1).schedule_ship_date <> FND_API.G_MISS_DATE ) then
		l_ibu_ret_head_ship_info :=  'sch_ship_date = ' || l_header_shipment_tbl(1).schedule_ship_date || ' , ';
	else
		l_ibu_ret_head_ship_info :=  'sch_ship_date = ';
	end if;
	aso_debug_pub.add  ('IBU: sch_ship_date = ' || l_header_shipment_tbl(1).schedule_ship_date  , 1, 'Y');

	if ( l_header_shipment_tbl(1).ship_to_party_site_id <> FND_API.G_MISS_NUM) then
	l_ibu_ret_head_ship_info :=  'ship_to_py_site_id = ' || l_header_shipment_tbl(1).ship_to_party_site_id || ' , ';
	else
	 l_ibu_ret_head_ship_info :=  'ship_to_py_site_id = ';
	end if;
	aso_debug_pub.add  ('IBU: ship_to_py_site_id = ' || l_header_shipment_tbl(1).ship_to_party_site_id  , 1, 'Y');

	if ( l_header_shipment_tbl(1).freight_carrier_code <> FND_API.G_MISS_CHAR) then
		l_ibu_ret_head_ship_info :=  'freigt_carr_code = ' || l_header_shipment_tbl(1).freight_carrier_code || ' , ';
	else
		l_ibu_ret_head_ship_info :=  'freigt_carr_code = ';
	end if;
	aso_debug_pub.add  ('IBU: freigt_carr_code = ' || l_header_shipment_tbl(1).freight_carrier_code , 1, 'Y');

	if (LINE_TBL.count > 0) then
	for i in LINE_TBL.FIRST..LINE_TBL.LAST loop

		l_line_cursor_stmt := 'select org_id, ship_from_org_id, inventory_item_id, order_quantity_uom, price_list_id, unit_list_price, unit_selling_price from oe_order_lines_all where line_id=:v_line_id';
		l_line_cursor := dbms_sql.open_cursor;
		dbms_sql.parse(l_line_cursor,l_line_cursor_stmt , dbms_sql.NATIVE);

		dbms_sql.define_column (l_line_cursor, 1, l_line_org_id );
		dbms_sql.define_column (l_line_cursor, 2, l_ship_from_org_id );
		dbms_sql.define_column (l_line_cursor, 3, l_inventory_item_id);
		dbms_sql.define_column (l_line_cursor, 4, l_ordered_quantity_uom,  3);
		dbms_sql.define_column (l_line_cursor, 5, l_line_price_list_id);
		dbms_sql.define_column (l_line_cursor, 6, l_unit_list_price);
		dbms_sql.define_column (l_line_cursor, 7, l_unit_selling_price);



		dbms_sql.bind_variable(l_line_cursor, ':v_line_id', LINE_TBL(i).LINE_ID) ;

		l_dummy_id :=  dbms_sql.execute (l_line_cursor);

		if ( dbms_sql.fetch_rows(l_line_cursor) > 0) then
			dbms_sql.column_value(l_line_cursor, 1, l_line_org_id);
			dbms_sql.column_value (l_line_cursor, 2, l_ship_from_org_id );
			dbms_sql.column_value (l_line_cursor, 3, l_inventory_item_id);
			dbms_sql.column_value (l_line_cursor, 4, l_ordered_quantity_uom);
			dbms_sql.column_value (l_line_cursor, 5, l_line_price_list_id);
			dbms_sql.column_value (l_line_cursor, 6, l_unit_list_price);
			dbms_sql.column_value (l_line_cursor, 7, l_unit_selling_price);


		else
			X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
			FND_MESSAGE.SET_NAME('IBU','IBU_RET_REF_LINE_INVALID)');
			FND_MSG_PUB.Add;
			RAISE FND_API.G_EXC_ERROR;
		end if;

		-- validate line_org_id, ship_from_org_id, inventory_item_id, rdered_quantity_uom, line_pricelist_id, unit_list_price, unit_selling_price
		if (l_line_org_id is null OR l_line_org_id = FND_API.G_MISS_NUM  or l_inventory_item_id is null or l_inventory_item_id = FND_API.G_MISS_NUM) then
		X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('IBU','IBU_RET_REF_LINE_INVALID)');
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
		end if;

		if (l_ordered_quantity_uom is null or l_ordered_quantity_uom = FND_API.G_MISS_CHAR or l_line_price_list_id is null or l_line_price_list_id =  FND_API.G_MISS_NUM) then
		X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('IBU','IBU_RET_REF_LINE_INVALID)');
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
		end if;

		if (l_unit_list_price is null or l_unit_list_price = FND_API.G_MISS_NUM or l_unit_selling_price is null or l_unit_selling_price = FND_API.G_MISS_NUM) then
		X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('IBU','IBU_RET_REF_LINE_INVALID)');
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
		end if;

		--fill in the line related table values

		l_qte_line_tbl (i).operation_code := 'CREATE';
		l_qte_line_tbl (i).org_id := l_line_org_id;
		l_qte_line_tbl (i).line_category_code := 'RETURN';

		--l_qte_line_tbl (i).order_line_type_id := FND_PROFILE.VALUE_WNPS('IBU_ORDER_LINE_TYPE_ID');
		l_qte_line_tbl (i).invoice_to_party_site_id := LINE_TBL(i).INVOICE_TO_PARTY_SITE_ID;
		l_qte_line_tbl (i).inventory_item_id := l_inventory_item_id;
		l_qte_line_tbl (i).quantity := LINE_TBL(i).QUANTITY;
		l_qte_line_tbl (i).uom_code := l_ordered_quantity_uom;
		l_qte_line_tbl (i).price_list_id := l_line_price_list_id;
		l_qte_line_tbl (i).line_list_price := l_unit_list_price;
		l_qte_line_tbl (i).line_quote_price := l_unit_selling_price;

		l_qte_line_dtl_tbl (i).operation_code := 'CREATE';
		l_qte_line_dtl_tbl (i).qte_line_index := i;
		l_qte_line_dtl_tbl (i).return_ref_type  := 'SALES ORDER';
		l_qte_line_dtl_tbl (i).return_ref_header_id  := p_header_id;
		l_qte_line_dtl_tbl (i).return_ref_line_id  := LINE_TBL(i).LINE_ID;
		l_qte_line_dtl_tbl (i).return_attribute1  := p_header_id;
		l_qte_line_dtl_tbl (i).return_attribute2  := LINE_TBL(i).LINE_ID;

		l_qte_line_dtl_tbl (i).return_reason_code := LINE_DTL_TBL(i).RETURN_REASON_CODE;

		l_line_shipment_tbl (i).operation_code := 'CREATE';
		l_line_shipment_tbl (i).qte_line_index := i;
		l_line_shipment_tbl (i).quantity := LINE_SHIPMENT_TBL (i).QUANTITY;
		l_line_shipment_tbl (i).freight_carrier_code := LINE_SHIPMENT_TBL (i).FREIGHT_CARRIER_CODE;
		l_line_shipment_tbl (i).schedule_ship_date := LINE_SHIPMENT_TBL (i).SCHEDULE_SHIP_DATE;
		l_line_shipment_tbl (i).request_date := sysdate;
		l_line_shipment_tbl (i).ship_to_party_site_id := LINE_SHIPMENT_TBL (i).SHIP_TO_PARTY_SITE_ID;

		l_ibu_ret_line_prpt_info := 'l_qte_line_tbl(' || i || '): ';
		aso_debug_pub.add  ('IBU: l_qte_line_tbl(' || i || '): '  , 1, 'Y');


		l_ibu_ret_line_prpt_info := '';

		if ( l_qte_line_tbl (i).operation_code <> FND_API.G_MISS_CHAR ) then
		l_ibu_ret_line_info := l_ibu_ret_line_prpt_info || 'operation_code = ' || l_qte_line_tbl (i).operation_code || ' , ';
		else
		l_ibu_ret_line_info := l_ibu_ret_line_prpt_info || 'operation_code = ';
		end if;
		aso_debug_pub.add  ('IBU: operation_code = ' || l_qte_line_tbl (i).operation_code   , 1, 'Y');

		if ( l_qte_line_tbl (i).org_id <> FND_API.G_MISS_NUM ) then
		l_ibu_ret_line_info := l_ibu_ret_line_prpt_info || 'org_id = ' || l_qte_line_tbl (i).org_id || ' , ';
		else
		l_ibu_ret_line_info := l_ibu_ret_line_prpt_info || 'org_id = ' ;
		end if;
		aso_debug_pub.add  ('IBU: org_id = ' || l_qte_line_tbl (i).org_id   , 1, 'Y');

		if ( l_qte_line_tbl (i).line_category_code <> FND_API.G_MISS_CHAR ) then
		l_ibu_ret_line_info := l_ibu_ret_line_prpt_info || 'line_category_code = ' || l_qte_line_tbl (i).line_category_code || ' , ';
		else
		l_ibu_ret_line_info := l_ibu_ret_line_prpt_info || 'line_category_code = ';
		end if;
		aso_debug_pub.add  ('IBU: line_category_code = ' || l_qte_line_tbl (i).line_category_code , 1, 'Y');

		if ( l_qte_line_tbl (i).order_line_type_id <> FND_API.G_MISS_NUM) then
		l_ibu_ret_line_info := l_ibu_ret_line_prpt_info || 'ord_li_tp_id = ' || l_qte_line_tbl (i).order_line_type_id || ',';
		else
		l_ibu_ret_line_info := l_ibu_ret_line_prpt_info || 'ord_li_tp_id = ';
		end if;
		aso_debug_pub.add  ('IBU: ord_li_tp_id = ' || l_qte_line_tbl (i).order_line_type_id , 1, 'Y');

		if ( l_qte_line_tbl (i).invoice_to_party_site_id <> FND_API.G_MISS_NUM) then
		l_ibu_ret_line_info := l_ibu_ret_line_prpt_info || 'inv_to_pty_site_id = ' || l_qte_line_tbl (i).invoice_to_party_site_id || ' , ';
		else
		l_ibu_ret_line_info := l_ibu_ret_line_prpt_info || 'inv_to_pty_site_id = ';
		end if;
		aso_debug_pub.add  ('IBU: inv_to_pty_site_id = ' || l_qte_line_tbl (i).invoice_to_party_site_id , 1, 'Y');

		if ( l_qte_line_tbl (i).inventory_item_id <>  FND_API.G_MISS_NUM) then
		l_ibu_ret_line_info := l_ibu_ret_line_prpt_info || 'inv_item_id = ' || l_qte_line_tbl (i).inventory_item_id || ' , ';
		else
		l_ibu_ret_line_info := l_ibu_ret_line_prpt_info || 'inv_item_id = ';
		end if;
		aso_debug_pub.add  ('IBU: inv_item_id = ' || l_qte_line_tbl (i).inventory_item_id   , 1, 'Y');

		if ( l_qte_line_tbl (i).quantity <>  FND_API.G_MISS_NUM) then
		l_ibu_ret_line_info := l_ibu_ret_line_prpt_info || 'quantity = ' || l_qte_line_tbl (i).quantity || ' , ';
		else
		l_ibu_ret_line_info := l_ibu_ret_line_prpt_info || 'quantity =  ';
		end if;
		aso_debug_pub.add  ('IBU: quantity = ' || l_qte_line_tbl (i).quantity  , 1, 'Y');

		if (  l_qte_line_tbl (i).uom_code <>  FND_API.G_MISS_CHAR ) then
		l_ibu_ret_line_info := l_ibu_ret_line_prpt_info || 'uom_code = ' || l_qte_line_tbl (i).uom_code || ' , ';
		else
		l_ibu_ret_line_info := l_ibu_ret_line_prpt_info || 'uom_code = ';
		end if;
		aso_debug_pub.add  ('IBU: uom_code = ' || l_qte_line_tbl (i).uom_code   , 1, 'Y');

		if (  l_qte_line_tbl (i).price_list_id <>  FND_API.G_MISS_NUM ) then
		l_ibu_ret_line_info := l_ibu_ret_line_prpt_info || 'price_list_id = ' || l_qte_line_tbl (i).price_list_id || ' , ';
		else
		l_ibu_ret_line_info := l_ibu_ret_line_prpt_info || 'price_list_id = ';
		end if;
		aso_debug_pub.add  ('IBU: price_list_id = ' || l_qte_line_tbl (i).price_list_id  , 1, 'Y');

		if  (  l_qte_line_tbl (i).line_list_price <> FND_API.G_MISS_NUM ) then
		l_ibu_ret_line_info := l_ibu_ret_line_prpt_info || 'line_list_price = ' || l_qte_line_tbl (i).line_list_price || ' , ';
		else
		l_ibu_ret_line_info := l_ibu_ret_line_prpt_info || 'line_list_price = ' ;
		end if;
		aso_debug_pub.add  ('IBU: line_list_price = ' || l_qte_line_tbl (i).line_list_price  , 1, 'Y');

		if (  l_qte_line_tbl (i).line_quote_price <> FND_API.G_MISS_NUM ) then
		l_ibu_ret_line_info := l_ibu_ret_line_prpt_info || 'line_quote_price = ' || l_qte_line_tbl (i).line_quote_price || ' , ';
		else
		l_ibu_ret_line_info := l_ibu_ret_line_prpt_info || 'line_quote_price = ';
		end if;
		aso_debug_pub.add  ('IBU: line_quote_price = ' || l_qte_line_tbl (i).line_quote_price  , 1, 'Y');

		l_ibu_ret_line_dtl_prpt_info := 'l_qte_line_dtl_tbl(' || i || '): ';
		aso_debug_pub.add  ('IBU: l_qte_line_dtl_tbl(' || i || '): '   , 1, 'Y');

		l_ibu_ret_line_dtl_prpt_info := '';
		if ( l_qte_line_dtl_tbl (i).operation_code <> FND_API.G_MISS_CHAR ) then
		l_ibu_ret_line_dtl_info := l_ibu_ret_line_dtl_prpt_info || 'operation_code = ' || l_qte_line_dtl_tbl (i).operation_code || ' , ';
		else
		l_ibu_ret_line_dtl_info := l_ibu_ret_line_dtl_prpt_info || 'operation_code = ';
		end if;
		aso_debug_pub.add  ('IBU: operation_code = ' || l_qte_line_dtl_tbl (i).operation_code  , 1, 'Y');

		if ( l_qte_line_dtl_tbl (i).qte_line_index  <> FND_API.G_MISS_NUM) then
		l_ibu_ret_line_dtl_info := l_ibu_ret_line_dtl_prpt_info || 'qte_line_index = ' || l_qte_line_dtl_tbl (i).qte_line_index || ' , ';
		else
		l_ibu_ret_line_dtl_info := l_ibu_ret_line_dtl_prpt_info || 'qte_line_index = ' ;
		end if;
		aso_debug_pub.add  ('IBU: qte_line_index = ' || l_qte_line_dtl_tbl (i).qte_line_index  , 1, 'Y');

		if ( l_qte_line_dtl_tbl (i).return_ref_type <> FND_API.G_MISS_CHAR ) then
		l_ibu_ret_line_dtl_info := l_ibu_ret_line_dtl_prpt_info || 'ret_ref_type = ' || l_qte_line_dtl_tbl (i).return_ref_type || ' , ';
		else
		l_ibu_ret_line_dtl_info := l_ibu_ret_line_dtl_prpt_info || 'ret_ref_type = ';
		end if;
		aso_debug_pub.add  ('IBU: ret_ref_type = ' || l_qte_line_dtl_tbl (i).return_ref_type   , 1, 'Y');

		if ( l_qte_line_dtl_tbl (i).return_attribute1 <> FND_API.G_MISS_CHAR) then
		l_ibu_ret_line_dtl_info := l_ibu_ret_line_dtl_prpt_info || 'return_att1 = ' || l_qte_line_dtl_tbl (i).return_attribute1 || ' , ';
		else
		l_ibu_ret_line_dtl_info := l_ibu_ret_line_dtl_prpt_info || 'return_att1 = ';
		end if;
		aso_debug_pub.add  ('IBU: return_att1 = ' || l_qte_line_dtl_tbl (i).return_attribute1    , 1, 'Y');

		if ( l_qte_line_dtl_tbl (i).return_attribute2 <>  FND_API.G_MISS_CHAR) then
		l_ibu_ret_line_dtl_info := l_ibu_ret_line_dtl_prpt_info || 'return_att2 = ' || l_qte_line_dtl_tbl (i).return_attribute2 || ' , ';
		else
		l_ibu_ret_line_dtl_info := l_ibu_ret_line_dtl_prpt_info || 'return_att2 = ';
		end if;
		aso_debug_pub.add  ('IBU: return_att2 = ' || l_qte_line_dtl_tbl (i).return_attribute2    , 1, 'Y');

		if ( l_qte_line_dtl_tbl (i).return_ref_header_id <>  FND_API.G_MISS_NUM) then
		l_ibu_ret_line_dtl_info := l_ibu_ret_line_dtl_prpt_info || 'ret_head_id_ = ' || l_qte_line_dtl_tbl (i).return_ref_header_id || ' , ';
		else
		l_ibu_ret_line_dtl_info := l_ibu_ret_line_dtl_prpt_info || 'ret_head_id_ = ' ;
		end if;
		aso_debug_pub.add  ('IBU: ret_head_id_ = ' || l_qte_line_dtl_tbl (i).return_ref_header_id   , 1, 'Y');

		if ( l_qte_line_dtl_tbl (i).return_ref_line_id <> FND_API.G_MISS_NUM) then
		l_ibu_ret_line_dtl_info := l_ibu_ret_line_dtl_prpt_info || 'ret_line_id = ' || l_qte_line_dtl_tbl (i).return_ref_line_id || ' , ';
		else
		l_ibu_ret_line_dtl_info := l_ibu_ret_line_dtl_prpt_info || 'ret_line_id = ';
		end if;
		aso_debug_pub.add  ('IBU: ret_line_id = ' || l_qte_line_dtl_tbl (i).return_ref_line_id   , 1, 'Y');


		if ( l_qte_line_dtl_tbl (i).return_reason_code <> FND_API.G_MISS_CHAR) then
		l_ibu_ret_line_dtl_info := l_ibu_ret_line_dtl_prpt_info || 're_reas_code = ' || l_qte_line_dtl_tbl (i).return_reason_code || ' , ';
		else
		l_ibu_ret_line_dtl_info := l_ibu_ret_line_dtl_prpt_info || 're_reas_code = ';
		end if;
		aso_debug_pub.add  ('IBU: re_reas_code = ' || l_qte_line_dtl_tbl (i).return_reason_code  , 1, 'Y');



		l_ibu_ret_line_dtl_prpt_info :=  'l_line_shipment_tbl(' || i || '): ';
		aso_debug_pub.add  ('IBU: l_line_shipment_tbl(' || i || '): '   , 1, 'Y');


		l_ibu_ret_line_dtl_prpt_info :='';

		if ( l_line_shipment_tbl (i).operation_code  <> FND_API.G_MISS_CHAR ) then

		l_ibu_ret_line_dtl_info := l_ibu_ret_line_dtl_prpt_info || 'op_code  = ' || l_line_shipment_tbl (i).operation_code  || ' , ';
		else
		l_ibu_ret_line_dtl_info := l_ibu_ret_line_dtl_prpt_info || 'op_code  = ';
		end if;
		aso_debug_pub.add  ('IBU: op_code  = ' || l_line_shipment_tbl (i).operation_code   , 1, 'Y');

		if ( l_line_shipment_tbl (i).qte_line_index <> FND_API.G_MISS_NUM ) then
		l_ibu_ret_line_dtl_info := l_ibu_ret_line_dtl_prpt_info || 'qte_line_index  = ' || l_line_shipment_tbl (i).qte_line_index  || ' , ';
		else
		l_ibu_ret_line_dtl_info := l_ibu_ret_line_dtl_prpt_info || 'qte_line_index  = ';
		end if;
		aso_debug_pub.add  ('IBU: qte_line_index  = ' || l_line_shipment_tbl (i).qte_line_index  , 1, 'Y');

		if ( l_line_shipment_tbl (i).quantity <> FND_API.G_MISS_NUM ) then
		l_ibu_ret_line_dtl_info := l_ibu_ret_line_dtl_prpt_info || 'quantity  = ' || l_line_shipment_tbl (i).quantity  || ' , ';
		else
		l_ibu_ret_line_dtl_info := l_ibu_ret_line_dtl_prpt_info || 'quantity  = ';
		end if;
		aso_debug_pub.add  ('IBU: quantity  = ' || l_line_shipment_tbl (i).quantity   , 1, 'Y');

		if (  l_line_shipment_tbl (i).freight_carrier_code <> FND_API.G_MISS_CHAR) then
		l_ibu_ret_line_dtl_info := l_ibu_ret_line_dtl_prpt_info || 'freight_car_code  = ' || l_line_shipment_tbl (i).freight_carrier_code  || ' , ';
		else
		l_ibu_ret_line_dtl_info := l_ibu_ret_line_dtl_prpt_info || 'freight_car_code  = ';
		end if;
		aso_debug_pub.add  ('IBU: freight_car_code  = ' || l_line_shipment_tbl (i).freight_carrier_code   , 1, 'Y');


		if ( l_line_shipment_tbl (i).schedule_ship_date  <> FND_API.G_MISS_DATE) then
		l_ibu_ret_line_dtl_info := l_ibu_ret_line_dtl_prpt_info || 'sche_ship_date  = ' || l_line_shipment_tbl (i).schedule_ship_date  || ' , ';
		else
		l_ibu_ret_line_dtl_info := l_ibu_ret_line_dtl_prpt_info || 'sche_ship_date  = ' ;
		end if;
		aso_debug_pub.add  ('IBU: sche_ship_date  = ' || l_line_shipment_tbl (i).schedule_ship_date  , 1, 'Y');

		if ( l_line_shipment_tbl (i).request_date  <> FND_API.G_MISS_DATE) then
		l_ibu_ret_line_dtl_info := l_ibu_ret_line_dtl_prpt_info || 'request_date  = ' || l_line_shipment_tbl (i).request_date  || ' , ';
		else
		l_ibu_ret_line_dtl_info := l_ibu_ret_line_dtl_prpt_info || 'request_date  = ' ;
		end if;
		aso_debug_pub.add  ('IBU: request_date  = ' || l_line_shipment_tbl (i).request_date , 1, 'Y');

		if ( l_line_shipment_tbl (i).ship_to_party_site_id <> FND_API.G_MISS_NUM) then
		l_ibu_ret_line_dtl_info := l_ibu_ret_line_dtl_prpt_info || 'ship_to_pty_site_id  = ' || l_line_shipment_tbl (i).ship_to_party_site_id  || ' , ';
		else
		l_ibu_ret_line_dtl_info := l_ibu_ret_line_dtl_prpt_info || 'ship_to_pty_site_id  = ';
		end if;
		aso_debug_pub.add  ('IBU: ship_to_pty_site_id  = ' || l_line_shipment_tbl (i).ship_to_party_site_id  , 1, 'Y');

	end loop;
	end if;
     l_booked_profile_value :=  FND_PROFILE.VALUE_WNPS('ASO_DEFAULT_ORDER_STATE');
     if ( l_booked_profile_value = 'BOOKED' ) then
         l_control_rec.book_flag := FND_API.G_TRUE;
     else
	 l_control_rec.book_flag :=  FND_API.G_FALSE;
     end if;

     l_ibu_ret_header_prpt_info := 'bk_flg='|| l_control_rec.book_flag ;

	aso_debug_pub.add  ('IBU: ' || l_ibu_ret_header_prpt_info  , 1, 'Y');

     aso_order_int.create_order (
 	p_api_version_number    => 1.0,
	p_init_msg_list		=> FND_API.G_FALSE,
	p_commit		=> FND_API.G_FALSE,
    	p_qte_rec               => l_qte_header_rec,
    	p_header_shipment_tbl   => l_header_shipment_tbl,
    	p_qte_line_tbl		=> l_qte_line_tbl,
	p_qte_line_dtl_tbl	=> l_qte_line_dtl_tbl,
	p_line_shipment_tbl	=> l_line_shipment_tbl,
	p_control_rec		=> l_control_rec,
	x_order_header_rec	=> l_return_header_rec,
	x_order_line_tbl	=> l_return_line_tbl,
	x_return_status		=> X_RETURN_STATUS,
	x_msg_count		=> X_MSG_COUNT,
	x_msg_data		=> X_MSG_DATA );



    if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then

	RAISE FND_API.G_EXC_ERROR;
    end if;

     X_RETURN_HEADER_REC.ORDER_NUMBER := l_return_header_rec.order_number;
     X_RETURN_HEADER_REC.ORDER_HEADER_ID := l_return_header_rec.order_header_id;
     X_RETURN_HEADER_REC.STATUS := l_return_header_rec.status;

     if ( l_return_line_tbl.count > 0) then
     for i in l_return_line_tbl.first..l_return_line_tbl.last loop
	X_RETURN_LINE_TBL (i).ORDER_LINE_ID := l_return_line_tbl (i).order_line_id;
	X_RETURN_LINE_TBL (i).ORDER_HEADER_ID := l_return_line_tbl (i).order_header_id;
	X_RETURN_LINE_TBL (i).STATUS := l_return_line_tbl (i).status;
     end loop;
     end if;

     -- Standard check of p_commit.
     IF FND_API.To_Boolean( p_commit ) THEN
          COMMIT WORK;
     END IF;
     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
          (p_count => x_msg_count ,
           p_data => x_msg_data
          );


EXCEPTION

  	WHEN FND_API.G_EXC_ERROR THEN
	  FND_MESSAGE.SET_NAME('IBU',  'IBU Return Failed' );
	  FND_MSG_PUB.Add;
          FND_MSG_PUB.Count_And_Get
                  (p_count => x_msg_count ,
                   p_data => x_msg_data
                  );
/*
  	WHEN OTHERS THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
               FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);

          END IF;
	  FND_MESSAGE.SET_NAME('IBU',  'IBU_RET_FAILED' );
	  FND_MSG_PUB.Add;
          FND_MSG_PUB.Count_And_Get
               (p_count => x_msg_count ,
                p_data => x_msg_data
               );
          raise;
*/
END CREATE_RETURN;

PROCEDURE Get_Messages (
p_message_count IN  NUMBER,
x_msgs          OUT NOCOPY VARCHAR2)
IS
      l_msg_list        VARCHAR2(8000) := '
';
      l_temp_msg        VARCHAR2(2000);
      l_appl_short_name  VARCHAR2(20) ;
      l_message_name    VARCHAR2(30) ;

      l_id              NUMBER;
      l_message_num     NUMBER;

	 l_msg_count       NUMBER;
	 l_msg_data        VARCHAR2(2000);

      Cursor Get_Appl_Id (x_short_name VARCHAR2) IS
        SELECT  application_id
        FROM    fnd_application_vl
        WHERE   application_short_name = x_short_name;

      Cursor Get_Message_Num (x_msg VARCHAR2, x_id NUMBER, x_lang_id NUMBER) IS
        SELECT  msg.message_number
        FROM    fnd_new_messages msg, fnd_languages_vl lng
        WHERE   msg.message_name = x_msg
          and   msg.application_id = x_id
          and   lng.LANGUAGE_CODE = msg.language_code
          and   lng.language_id = x_lang_id;
BEGIN

      FOR l_count in 1..NVL(p_message_count,0) LOOP
	 if l_count = 1 then
	   l_temp_msg := fnd_msg_pub.get(fnd_msg_pub.g_first, fnd_api.g_true);
	else
          l_temp_msg := fnd_msg_pub.get(fnd_msg_pub.g_next, fnd_api.g_true);
        end if ;
	  fnd_message.parse_encoded(l_temp_msg, l_appl_short_name, l_message_name);
          OPEN Get_Appl_Id (l_appl_short_name);
          FETCH Get_Appl_Id into l_id;
          CLOSE Get_Appl_Id;

          l_message_num := NULL;
          IF l_id is not NULL
          THEN
              OPEN Get_Message_Num (l_message_name, l_id,
                        to_number(NVL(FND_PROFILE.Value('LANGUAGE'), '0')));
              FETCH Get_Message_Num into l_message_num;
              CLOSE Get_Message_Num;
          END IF;

          l_temp_msg := fnd_msg_pub.get(fnd_msg_pub.g_previous, fnd_api.g_true);

          IF NVL(l_message_num, 0) <> 0
          THEN
            l_temp_msg := 'APP-' || to_char(l_message_num) || ': ';
          ELSE
            l_temp_msg := NULL;
          END IF;

          IF l_count = 1
          THEN
              l_msg_list := l_msg_list || l_temp_msg ||
                        fnd_msg_pub.get(fnd_msg_pub.g_first, fnd_api.g_false);
          ELSE
              l_msg_list := l_msg_list || l_temp_msg ||
                        fnd_msg_pub.get(fnd_msg_pub.g_next, fnd_api.g_false);
          END IF;

          l_msg_list := l_msg_list || '
';
	  EXIT WHEN length(l_msg_list) > 8000;
      END LOOP;

      x_msgs := substr(l_msg_list, 0, 8000);


/*     l_msg_list:=' ';
     for l_count in 1..NVL(p_message_count,0) loop
	  l_temp_msg := fnd_msg_pub.get( p_msg_index => l_count,
			   p_encoded => 'F'  );
	  l_msg_list := l_msg_list || l_temp_msg;
	            l_msg_list := l_msg_list || '
';
	  EXIT WHEN length(l_msg_list) > 8000;
     end loop;
     x_msgs := substr(l_msg_list, 0, 8000);
*/
END Get_Messages;

FUNCTION GET_RETURN_LINES_TOTAL(
	P_HEADER_ID    IN	NUMBER)
	RETURN NUMBER
IS
	l_Total NUMBER := FND_API.G_MISS_NUM;

	CURSOR ALL_HEADER_LINES (c_header_id NUMBER) IS
	SELECT LINE_ID, LINE_NUMBER
	FROM ASO_I_OE_ORDER_LINES_V
	WHERE LINE_CATEGORY_CODE = 'RETURN'
	AND HEADER_ID = c_header_id;

	l_line_id	number;
	l_line_no number;

BEGIN
	OPEN ALL_HEADER_LINES(P_HEADER_ID);
	LOOP
		FETCH ALL_HEADER_LINES INTO l_line_id, l_line_no;
		EXIT WHEN ALL_HEADER_LINES%NOTFOUND;

		IF (l_Total = FND_API.G_MISS_NUM) THEN
			l_Total := 0;
		END IF;

		l_Total := l_Total + OE_OE_TOTALS_SUMMARY.LINE_TOTAL(
			P_HEADER_ID,
			l_line_id,
		        l_line_no,
			NULL
		);

	END LOOP;

	RETURN (l_Total);

	EXCEPTION
	     WHEN no_data_found THEN
		     l_Total := FND_API.G_MISS_NUM;

		     IF ALL_HEADER_LINES%ISOPEN then
			    CLOSE ALL_HEADER_LINES;
		     END IF;
     		     return FND_API.G_MISS_NUM;

		WHEN too_many_rows THEN
			--RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		     IF ALL_HEADER_LINES%ISOPEN then
			    CLOSE ALL_HEADER_LINES;
		     END IF;
     		     return FND_API.G_MISS_NUM;
		WHEN others THEN
			--RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		     IF ALL_HEADER_LINES%ISOPEN then
			    CLOSE ALL_HEADER_LINES;
		     END IF;
		     return FND_API.G_MISS_NUM;


END GET_RETURN_LINES_TOTAL;

END IBU_ORDER_CAPTURE;


/
