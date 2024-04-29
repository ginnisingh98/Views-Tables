--------------------------------------------------------
--  DDL for Package Body OE_BATCH_PRICING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_BATCH_PRICING" AS
/* $Header: OEXBPRIB.pls 120.0.12010000.4 2008/11/28 09:31:15 smanian noship $ */

PROCEDURE PRICE
(
  ERRBUF			OUT NOCOPY	VARCHAR2,
  RETCODE			OUT NOCOPY	VARCHAR2,
  p_preview_mode		IN		VARCHAR2,
  p_pricing_level		IN		VARCHAR2,
  p_dummy			IN		VARCHAR2,
  p_org_id			IN		NUMBER,
  p_order_number_low		IN		NUMBER,
  p_order_number_high		IN		NUMBER,
  p_order_type_id		IN		NUMBER,
  p_line_type_id		IN		NUMBER,
  p_customer_id			IN		NUMBER,
  p_ship_to_org_id		IN		NUMBER,
  p_invoice_to_org_id		IN		NUMBER,
  p_customer_class_code		IN		VARCHAR2,
  p_salesrep_id			IN		NUMBER,
  p_price_list_id		IN		NUMBER,
  p_inventory_item_id		IN		NUMBER,
  p_item_category_id		IN		NUMBER,
  p_ship_from_org_id		IN		NUMBER,
  p_order_date_low		IN		VARCHAR2,
  p_order_date_high		IN		VARCHAR2,
  p_order_creation_date_low	IN		VARCHAR2,
  p_order_creation_date_high	IN		VARCHAR2,
  p_line_creation_date_low	IN		VARCHAR2,
  p_line_creation_date_high	IN		VARCHAR2,
  p_booked_date_low		IN		VARCHAR2,
  p_booked_date_high		IN		VARCHAR2,
  p_pricing_date_low		IN		VARCHAR2,
  p_pricing_date_high		IN		VARCHAR2,
  p_schedule_ship_date_low	IN		VARCHAR2,
  p_schedule_ship_date_high	IN		VARCHAR2,
  p_booked_orders		IN		VARCHAR2,
  p_header_id			IN		NUMBER	DEFAULT NULL,
  p_line_count			IN		NUMBER  DEFAULT NULL,
  p_line_list			IN		VARCHAR2 DEFAULT NULL
)
IS
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

	l_lines_count	NUMBER := 0;
	l_lines_list	VARCHAR2(4000);
	l_submit_request BOOLEAN := FALSE;

	l_child_request number;
	l_req_data               VARCHAR2(10);
	l_req_data_counter       NUMBER :=0;


	l_request_id	number;
	l_user_id	number;
	l_resp_id	number;
	l_resp_appl_id	number;

	l_return_status	VARCHAR2(1);
	l_msg_count	NUMBER;
	l_msg_data	VARCHAR2(4000);

	l_order_date_low DATE;
	l_order_date_high DATE;
	l_order_creation_date_low DATE;
	l_order_creation_date_high DATE;
	l_line_creation_date_low DATE;
	l_line_creation_date_high DATE;
	l_booked_date_low DATE;
	l_booked_date_high DATE;
	l_pricing_date_low DATE;
	l_pricing_date_high DATE;
	l_schedule_ship_date_low DATE;
	l_schedule_ship_date_high DATE;


	l_preview	varchar2(1000);
	l_subtotal	number;
	l_discount	number;
	l_charges	number;
	l_tax		number;


	/* Main cursor query to fetch the orders matching input criteria */
	CURSOR C_ORDERS
	IS
	select	h.org_id, h.header_id, 0 line_id, 0 line_number, 0 shipment_number, h.order_number, party.party_name account_name, tt.name order_type, h.transactional_curr_code
	from	oe_order_headers h,
           	hz_parties party,
		hz_cust_accounts cust,
		oe_transaction_types_tl tt
	where	h.open_flag = 'Y'
	and	h.order_number between nvl(p_order_number_low, h.order_number) and nvl(p_order_number_high, h.order_number)
	and	h.order_type_id = nvl(p_order_type_id, h.order_type_id)
	and	NVL(h.sold_to_org_id,-1) = nvl(p_customer_id, NVL(h.sold_to_org_id,-1))
	and	nvl(h.ship_to_org_id, -1) = nvl(p_ship_to_org_id, nvl(h.ship_to_org_id, -1))
	and	nvl(h.invoice_to_org_id, -1) = nvl(p_invoice_to_org_id, nvl(h.invoice_to_org_id, -1))
	and	nvl(h.salesrep_id, -1) = nvl(p_salesrep_id, nvl(h.salesrep_id, -1))
	and	h.ordered_date between nvl(l_order_date_low, h.ordered_date) and nvl(l_order_date_high, h.ordered_date)
	and	h.creation_date between nvl(l_order_creation_date_low, h.creation_date) and nvl(l_order_creation_date_high, h.creation_date)
	and	nvl(h.booked_date, sysdate) between nvl(l_booked_date_low, nvl(h.booked_date, sysdate)) and nvl(l_booked_date_high, nvl(h.booked_date, sysdate))
	and	h.booked_flag = decode(p_booked_orders, 'Y', 'Y', 'N', 'N', NULL, h.booked_flag)
        and	h.sold_to_org_id        =  cust.cust_account_id(+)
       	and     cust.party_id           = party.party_id (+)
	and	nvl(cust.customer_class_code, '-1') = nvl(p_customer_class_code, nvl(cust.customer_class_code, '-1'))
	and	NVL(h.price_list_id,-1) = nvl(p_price_list_id, NVL(h.price_list_id,-1))
	and	tt.transaction_type_id = h.order_type_id
	and	tt.language = userenv('LANG')
	order by h.org_id, h.header_id;

	/* Main cursor query to fetch the lines matching input criteria */
	CURSOR C_LINES
	IS
	select	l.org_id, l.header_id, l.line_id, l.line_number, l.shipment_number, h.order_number, party.party_name account_name, tt.name order_type, h.transactional_curr_code
	from	oe_order_headers h,
		oe_order_lines l,
		mtl_item_categories ic,
		mtl_default_category_sets cs,
		hz_cust_accounts cust,
		hz_parties party,
		oe_transaction_types_tl tt
	where	h.open_flag = 'Y'
	and	h.order_number between nvl(p_order_number_low, h.order_number) and nvl(p_order_number_high, h.order_number)
	and	h.order_type_id = nvl(p_order_type_id, h.order_type_id)
	and	NVL(h.sold_to_org_id,-1) = nvl(p_customer_id, NVL(h.sold_to_org_id,-1))
	and	h.ordered_date between nvl(l_order_date_low, h.ordered_date) and nvl(l_order_date_high, h.ordered_date)
	and	h.creation_date between nvl(l_order_creation_date_low, h.creation_date) and nvl(l_order_creation_date_high, h.creation_date)
	and	nvl(h.booked_date, sysdate) between nvl(l_booked_date_low, nvl(h.booked_date, sysdate)) and nvl(l_booked_date_high, nvl(h.booked_date, sysdate))
	and	h.booked_flag = decode(p_booked_orders, 'Y', 'Y', 'N', 'N', NULL, h.booked_flag)
	and	l.header_id = h.header_id
	and	l.line_type_id = nvl(p_line_type_id, l.line_type_id)
	and	l.open_flag = 'Y'
	and	NVL(l.price_list_id,-1) = nvl(p_price_list_id, NVL(l.price_list_id,-1))
	and	nvl(l.ship_to_org_id, -1) = nvl(p_ship_to_org_id, nvl(l.ship_to_org_id, -1))
	and	nvl(l.invoice_to_org_id, -1) = nvl(p_invoice_to_org_id, nvl(l.invoice_to_org_id, -1))
	and	nvl(l.salesrep_id, -1) = nvl(p_salesrep_id, nvl(l.salesrep_id, -1))
	and	NVL(l.ship_from_org_id,-1) = nvl(p_ship_from_org_id, NVL(l.ship_from_org_id,-1))
	and	l.inventory_item_id = nvl(p_inventory_item_id, l.inventory_item_id)
	and	l.creation_date between nvl(l_line_creation_date_low, l.creation_date) and nvl(l_line_creation_date_high, l.creation_date)
	and	nvl(l.pricing_date, sysdate) between nvl(l_pricing_date_low, nvl(l.pricing_date, sysdate)) and nvl(l_pricing_date_high, nvl(l.pricing_date, sysdate))
	and	nvl(l.schedule_ship_date, sysdate) between nvl(l_schedule_ship_date_low, nvl(l.schedule_ship_date, sysdate)) and nvl(l_schedule_ship_date_high, nvl(l.schedule_ship_date, sysdate))
	and	ic.organization_id = oe_sys_parameters.Value('MASTER_ORGANIZATION_ID',l.org_id)
	and	ic.inventory_item_id = l.inventory_item_id
	and	ic.category_set_id = cs.category_set_id
	and	ic.category_id = nvl(p_item_category_id, ic.category_id)
	and	cs.functional_area_id = 7
	and	nvl(cust.customer_class_code, '-1') = nvl(p_customer_class_code, nvl(cust.customer_class_code, '-1'))
	and	h.sold_to_org_id        =  cust.cust_account_id(+)
        and     cust.party_id           = party.party_id (+)
	and	tt.transaction_type_id = h.order_type_id
	and	tt.language = userenv('LANG')
	order by l.org_id, l.header_id, l.line_number, l.shipment_number, l.option_number;

	TYPE hdr_lines_tbl_type IS TABLE OF C_LINES%rowtype INDEX BY BINARY_INTEGER;

	l_hdr_lines_tbl hdr_lines_tbl_type;

BEGIN

	FND_PROFILE.Get('CONC_REQUEST_ID', l_request_id);
	l_req_data := fnd_conc_global.request_data;

	IF l_debug_level > 0 THEN
		oe_debug_pub.add('REQUEST ID : '|| l_request_id, 1);
		oe_debug_pub.add('Request Data : ' || nvl(l_req_data, -99), 1);
	END IF;

	/* l_req_data is NULL means this is the Parent Request, being executed for first time.

	   l_req_data is NOT NULL, means this is the second time the Parent Request is being executed,
	   when being re-invoked from Paused status. This happens after all the child requests complete
	   their execution. l_req_data will represent the number of child requests that were submitted.
	   In this case, we need to simply exit the program without doing anything, as all the child
	   requests have completed their execution and no further processing needs to be done.


	   When Parent Request is submitted, the p_header_id parameter will be NULL.
	   When we submit the Child Request, we always pass the p_header_id value.
	   This will help us in distinguishing if this is a Parent Request call or  Child Request call,
	   we can base our processing logic accordingly.

	   We are submitting one child request for each Header, to optimally use the built in
	   parallel processing logic of the Concurrent Manager.

	*/

	if (l_req_data is null and p_header_id IS NULL) then
	/* Header Id is NULL, means this is the parent request */

		fnd_file.put_line(FND_FILE.OUTPUT, 'Request Id: '|| to_char(l_request_id));

		IF l_debug_level > 0 THEN
			oe_debug_pub.add('Entering OE_BATCH_PRICING.PRICE', 1);
		END IF;

		ERRBUF  := 'Batch Pricing Request completed successfully';
		RETCODE := 0;

		IF l_debug_level > 0 THEN
			oe_debug_pub.add('Parameters are : ', 5);
			oe_debug_pub.add('...Pricing Level : ' || p_pricing_level, 5);
			oe_debug_pub.add('...Preview Mode : ' || p_preview_mode, 5);
			oe_debug_pub.add('...Operating Unit : ' || p_org_id, 5);
			oe_debug_pub.add('...Order Number (Low) : ' || p_order_number_low, 5);
			oe_debug_pub.add('...Order Number (High) : ' || p_order_number_high, 5);
			oe_debug_pub.add('...Order Type : ' || p_order_type_id, 5);
			oe_debug_pub.add('...Line Type : ' || p_line_type_id, 5);
			oe_debug_pub.add('...Customer : ' || p_customer_id, 5);
			oe_debug_pub.add('...Ship To Location : ' || p_ship_to_org_id, 5);
			oe_debug_pub.add('...Bill To Location : ' || p_invoice_to_org_id, 5);
			oe_debug_pub.add('...Customer Class : ' || p_customer_class_code, 5);
			oe_debug_pub.add('...Salesrep : ' || p_salesrep_id, 5);
			oe_debug_pub.add('...Pricelist : ' || p_price_list_id, 5);
			oe_debug_pub.add('...Inventory Item : ' || p_inventory_item_id, 5);
			oe_debug_pub.add('...Item Category : ' || p_item_category_id, 5);
			oe_debug_pub.add('...Warehouse : ' || p_ship_from_org_id, 5);
			oe_debug_pub.add('...Order Date (Low) : ' || p_order_date_low, 5);
			oe_debug_pub.add('...Order Date (High) : ' || p_order_date_high, 5);
			oe_debug_pub.add('...Order Creation Date (Low) : ' || p_order_creation_date_low, 5);
			oe_debug_pub.add('...Order Creation Date (High) : ' || p_order_creation_date_high, 5);
			oe_debug_pub.add('...Line Creation Date (Low) : ' || p_line_creation_date_low, 5);
			oe_debug_pub.add('...Line Creation Date (High) : ' || p_line_creation_date_high, 5);
			oe_debug_pub.add('...Booked Date (Low) : ' || p_booked_date_low, 5);
			oe_debug_pub.add('...Booked Date (High) : ' || p_booked_date_high, 5);
			oe_debug_pub.add('...Pricing Date (Low) : ' || p_pricing_date_low, 5);
			oe_debug_pub.add('...Pricing Date (High) : ' || p_pricing_date_high, 5);
			oe_debug_pub.add('...Schedule Ship Date (Low) : ' || p_schedule_ship_date_low, 5);
			oe_debug_pub.add('...Schedule Ship Date (High) : ' || p_schedule_ship_date_high, 5);
			oe_debug_pub.add('...Booked Orders : ' || p_booked_orders, 5);
		END IF;

		fnd_file.put_line(FND_FILE.OUTPUT, 'Parameters are : ');
		fnd_file.put_line(FND_FILE.OUTPUT, '...Pricing Level : ' || p_pricing_level);
		fnd_file.put_line(FND_FILE.OUTPUT, '...Preview Mode : ' || p_preview_mode);
		fnd_file.put_line(FND_FILE.OUTPUT, '...Operating Unit : ' || p_org_id);
		fnd_file.put_line(FND_FILE.OUTPUT, '...Order Number (Low) : ' || p_order_number_low);
		fnd_file.put_line(FND_FILE.OUTPUT, '...Order Number (High) : ' || p_order_number_high);
		fnd_file.put_line(FND_FILE.OUTPUT, '...Order Type : ' || p_order_type_id);
		fnd_file.put_line(FND_FILE.OUTPUT, '...Line Type : ' || p_line_type_id);
		fnd_file.put_line(FND_FILE.OUTPUT, '...Customer : ' || p_customer_id);
		fnd_file.put_line(FND_FILE.OUTPUT, '...Ship To Location : ' || p_ship_to_org_id);
		fnd_file.put_line(FND_FILE.OUTPUT, '...Bill To Location : ' || p_invoice_to_org_id);
		fnd_file.put_line(FND_FILE.OUTPUT, '...Customer Class : ' || p_customer_class_code);
		fnd_file.put_line(FND_FILE.OUTPUT, '...Salesrep : ' || p_salesrep_id);
		fnd_file.put_line(FND_FILE.OUTPUT, '...Pricelist : ' || p_price_list_id);
		fnd_file.put_line(FND_FILE.OUTPUT, '...Inventory Item : ' || p_inventory_item_id);
		fnd_file.put_line(FND_FILE.OUTPUT, '...Item Category : ' || p_item_category_id);
		fnd_file.put_line(FND_FILE.OUTPUT, '...Warehouse : ' || p_ship_from_org_id);
		fnd_file.put_line(FND_FILE.OUTPUT, '...Order Date (Low) : ' || p_order_date_low);
		fnd_file.put_line(FND_FILE.OUTPUT, '...Order Date (High) : ' || p_order_date_high);
		fnd_file.put_line(FND_FILE.OUTPUT, '...Order Creation Date (Low) : ' || p_order_creation_date_low);
		fnd_file.put_line(FND_FILE.OUTPUT, '...Order Creation Date (High) : ' || p_order_creation_date_high);
		fnd_file.put_line(FND_FILE.OUTPUT, '...Line Creation Date (Low) : ' || p_line_creation_date_low);
		fnd_file.put_line(FND_FILE.OUTPUT, '...Line Creation Date (High) : ' || p_line_creation_date_high);
		fnd_file.put_line(FND_FILE.OUTPUT, '...Booked Date (Low) : ' || p_booked_date_low);
		fnd_file.put_line(FND_FILE.OUTPUT, '...Booked Date (High) : ' || p_booked_date_high);
		fnd_file.put_line(FND_FILE.OUTPUT, '...Pricing Date (Low) : ' || p_pricing_date_low);
		fnd_file.put_line(FND_FILE.OUTPUT, '...Pricing Date (High) : ' || p_pricing_date_high);
		fnd_file.put_line(FND_FILE.OUTPUT, '...Schedule Ship Date (Low) : ' || p_schedule_ship_date_low);
		fnd_file.put_line(FND_FILE.OUTPUT, '...Schedule Ship Date (High) : ' || p_schedule_ship_date_high);
		fnd_file.put_line(FND_FILE.OUTPUT, '...Booked Orders : ' || p_booked_orders);

		IF l_debug_level > 0 THEN
			oe_debug_pub.add('Before converting Canonical to Date', 5);
		END IF;

		/* Convert Strings to Dates */
		select	FND_DATE.Canonical_To_Date(p_order_date_low),
			FND_DATE.Canonical_To_Date(p_order_date_high),
			FND_DATE.Canonical_To_Date(p_order_creation_date_low),
			FND_DATE.Canonical_To_Date(p_order_creation_date_high),
			FND_DATE.CHARDT_TO_DATE(p_line_creation_date_low),
			FND_DATE.CHARDT_TO_DATE(p_line_creation_date_high),
			FND_DATE.Canonical_To_Date(p_booked_date_low),
			FND_DATE.Canonical_To_Date(p_booked_date_high),
			FND_DATE.CHARDT_TO_DATE(p_pricing_date_low),
			FND_DATE.CHARDT_TO_DATE(p_pricing_date_high),
			FND_DATE.CHARDT_TO_DATE(p_schedule_ship_date_low),
			FND_DATE.CHARDT_TO_DATE(p_schedule_ship_date_high)
		into	l_order_date_low,
			l_order_date_high,
			l_order_creation_date_low,
			l_order_creation_date_high,
			l_line_creation_date_low,
			l_line_creation_date_high,
			l_booked_date_low,
			l_booked_date_high,
			l_pricing_date_low,
			l_pricing_date_high,
			l_schedule_ship_date_low,
			l_schedule_ship_date_high
		from	dual;

		IF l_debug_level > 0 THEN
			oe_debug_pub.add('After converting Canonical to Date', 5);
		END IF;

		IF l_debug_level > 0 THEN
			oe_debug_pub.add('Fetching data from cursor', 5);
		END IF;

		IF p_pricing_level = 'ORDER' THEN
			/* Fetch the orders matching criteria */
			OPEN C_ORDERS;
			FETCH C_ORDERS BULK COLLECT INTO l_hdr_lines_tbl;
			CLOSE C_ORDERS;
		ELSIF p_pricing_level = 'LINE' THEN
			/* Fetch the lines matching criteria */
			OPEN C_LINES;
			FETCH C_LINES BULK COLLECT INTO l_hdr_lines_tbl;
			CLOSE C_LINES;
		END IF;

		IF l_debug_level > 0 THEN
			oe_debug_pub.add('No of records fetched : ' || l_hdr_lines_tbl.count, 1);
		END IF;

		fnd_file.put_line(FND_FILE.OUTPUT, 'No of Order(s) / Line(s) effected : ' || l_hdr_lines_tbl.count);

		IF l_hdr_lines_tbl.count > 0 THEN

			IF p_preview_mode = 'Y' THEN
				fnd_file.put_line(FND_FILE.OUTPUT, '');
				fnd_file.put_line(FND_FILE.OUTPUT, '');
				fnd_file.put_line(FND_FILE.OUTPUT, '');
				fnd_file.put_line(FND_FILE.OUTPUT, 'Following Order(s) / Line(s) will get effected due to this Batch Pricing request :');
				fnd_file.put_line(FND_FILE.OUTPUT, '');

				IF p_pricing_level = 'ORDER' THEN
					l_preview := 	lpad('Order Number', 15, ' ') || '  ' ||
							rpad('Order Type', 30, ' ') || '  ' ||
							lpad('Org Id', 6, ' ') || '  ' ||
							rpad('Customer Name', 35, ' ') || '  ' ||
							lpad('Order Amount', 30, ' ');
				ELSIF p_pricing_level = 'LINE' THEN
					l_preview := 	lpad('Order Number', 15, ' ') || '  ' ||
							rpad('Order Type', 30, ' ') || '  ' ||
							lpad('Org Id', 6, ' ') || '  ' ||
							rpad('Customer Name', 35, ' ') || '  ' ||
							rpad('Line Number', 12, ' ') || '  ' ||
							lpad('Line Amount', 30, ' ');
				END IF;

				fnd_file.put_line(FND_FILE.OUTPUT, l_preview);
			END IF;

			for i in l_hdr_lines_tbl.first .. l_hdr_lines_tbl.last loop

				IF p_pricing_level = 'ORDER' THEN
					IF p_preview_mode = 'Y' THEN

						OE_OE_TOTALS_SUMMARY.Order_Totals
									      (
									      p_header_id=>l_hdr_lines_tbl(i).header_id,
									      p_subtotal =>l_subtotal,
									      p_discount =>l_discount,
									      p_charges  =>l_charges,
									      p_tax      =>l_tax
									      );


						l_preview := 	lpad(l_hdr_lines_tbl(i).order_number, 15, ' ') || '  ' ||
								rpad(l_hdr_lines_tbl(i).order_type, 30, ' ') || '  ' ||
								lpad(l_hdr_lines_tbl(i).org_id, 6, ' ') || '  ' ||
								rpad(NVL(substr(l_hdr_lines_tbl(i).account_name, 1, 30),'   '), 35, ' ') || '  ' ||
								lpad(to_char(l_subtotal + l_charges + l_tax, 'FM999999999999999999D00'), 30, ' ') || ' ' ||
								l_hdr_lines_tbl(i).transactional_curr_code;
						fnd_file.put_line(FND_FILE.OUTPUT, l_preview);
					END IF;

					l_submit_request := TRUE;

				ELSIF p_pricing_level = 'LINE' THEN

					l_lines_count := l_lines_count + 1;

					if l_lines_count = 1 then
						IF p_preview_mode = 'Y' THEN
							l_subtotal := OE_OE_TOTALS_SUMMARY.LINE_TOTAL(
										l_hdr_lines_tbl(i).header_id,
										l_hdr_lines_tbl(i).line_id,
										l_hdr_lines_tbl(i).line_number,
										l_hdr_lines_tbl(i).shipment_number
										);
							l_preview := 	lpad(l_hdr_lines_tbl(i).order_number, 15, ' ') || '  ' ||
									rpad(l_hdr_lines_tbl(i).order_type, 30, ' ') || '  ' ||
									lpad(l_hdr_lines_tbl(i).org_id, 6, ' ') || '  ' ||
									rpad(NVL(substr(l_hdr_lines_tbl(i).account_name, 1, 30),'   '), 35, ' ') || '  ' ||
									rpad(OE_ORDER_MISC_PUB.GET_CONCAT_LINE_NUMBER(l_hdr_lines_tbl(i).line_id), 12, ' ') || '  ' ||
									lpad(to_char(l_subtotal, 'FM999999999999999999D00'), 30, ' ') || ' ' ||
									l_hdr_lines_tbl(i).transactional_curr_code;
							fnd_file.put_line(FND_FILE.OUTPUT, l_preview);
						END IF;

						l_lines_list := l_hdr_lines_tbl(i).line_id;

					else
						IF p_preview_mode = 'Y' THEN
							l_subtotal := OE_OE_TOTALS_SUMMARY.LINE_TOTAL(
										l_hdr_lines_tbl(i).header_id,
										l_hdr_lines_tbl(i).line_id,
										l_hdr_lines_tbl(i).line_number,
										l_hdr_lines_tbl(i).shipment_number
										);
							l_preview := 	lpad(' ', 15, ' ') || '  ' ||
									rpad(' ', 30, ' ') || '  ' ||
									lpad(' ', 6, ' ') || '  ' ||
									rpad(' ', 35, ' ') || '  ' ||
									rpad(OE_ORDER_MISC_PUB.GET_CONCAT_LINE_NUMBER(l_hdr_lines_tbl(i).line_id), 12, ' ') || '  ' ||
									lpad(to_char(l_subtotal, 'FM999999999999999999D00'), 30, ' ') || ' ' ||
									l_hdr_lines_tbl(i).transactional_curr_code;
							fnd_file.put_line(FND_FILE.OUTPUT, l_preview);
						END IF;

						l_lines_list := l_lines_list || ',' || l_hdr_lines_tbl(i).line_id;

					end if; -- l_lines_count = 1

					if i <>  l_hdr_lines_tbl.last then
						if l_hdr_lines_tbl(i).header_id <> l_hdr_lines_tbl(i+1).header_id then
							l_submit_request := TRUE;
						end if;
					else
						l_submit_request := TRUE;
					end if; -- i <>  l_hdr_lines_tbl.last

				END IF; -- p_pricing_level

				if (l_submit_request) then
					/* Submit Child Request only if Preview Mode is No */

					IF p_preview_mode <> 'Y' THEN

						l_req_data_counter := l_req_data_counter + 1;

						l_child_request := FND_REQUEST.SUBMIT_REQUEST('ONT', 'OMBATCHPRICE', 'Batch Pricing Child Request For Order : ' || to_char(l_hdr_lines_tbl(i).order_number) || ' ' || to_char(l_req_data_counter),
												NULL, TRUE,
												p_preview_mode,			-- p_preview_mode,
												p_pricing_level,		-- p_pricing_level,
												p_dummy,			-- p_dummy,
												l_hdr_lines_tbl(i).org_id,	-- p_org_id,
												null,				-- p_order_number_low,
												null,				-- p_order_number_high,
												null,				-- p_order_type_id,
												null,				-- p_line_type_id,
												null,				-- p_customer_id,
												null,				-- p_ship_to_org_id,
												null,				-- p_invoice_to_org_id,
												null,				-- p_customer_class_code,
												null,				-- p_salesrep_id,
												null,				-- p_price_list_id,
												null,				-- p_inventory_item_id,
												null,				-- p_item_category_id,
												null,				-- p_ship_from_org_id,
												null,				-- p_order_date_low,
												null,				-- p_order_date_high,
												null,				-- p_order_creation_date_low,
												null,				-- p_order_creation_date_high,
												null,				-- p_line_creation_date_low,
												null,				-- p_line_creation_date_high,
												null,				-- p_booked_date_low,
												null,				-- p_booked_date_high,
												null,				-- p_pricing_date_low,
												null,				-- p_pricing_date_high,
												null,				-- p_schedule_ship_date_low,
												null,				-- p_schedule_ship_date_high,
												null,				-- p_booked_orders,
												l_hdr_lines_tbl(i).header_id,	-- p_header_id,
												l_lines_count,			-- p_line_count,
												l_lines_list			-- p_line_list
												);

						if l_debug_level > 0 then
							oe_debug_pub.add('Submitted Child Request Id : ' || l_child_request || ', for Order : ' || l_hdr_lines_tbl(i).order_number, 1);
						end if;

						fnd_file.put_line(FND_FILE.OUTPUT, 'Submitted Child Request Id : ' || l_child_request || ', for Order : ' || l_hdr_lines_tbl(i).order_number);

					END IF; -- p_preview_mode <> 'Y'

					/* Reset Loop Variables */
					l_lines_count := 0;
					l_lines_list := null;
					l_submit_request := FALSE;
				end if; -- l_submit_request

			end loop; -- PL/SQL Table Loop

			-- Set the status of parent request to Paused only if a child request has been submitted.
			-- If preview mode is Yes, then child requests are not submitted, hence no need to pause the parent request.
			if l_req_data_counter > 0 then
				fnd_conc_global.set_req_globals(conc_status  => 'PAUSED', request_data => to_char(l_req_data_counter));
			end if;

			errbuf  := 'Sub-Request ' || to_char(l_req_data_counter) || 'submitted!';
			retcode := 0;

			if l_debug_level > 0 then
				oe_debug_pub.add('No of child requests submitted : ' || l_req_data_counter, 1);
			end if;

			fnd_file.put_line(FND_FILE.OUTPUT, '');
			fnd_file.put_line(FND_FILE.OUTPUT, 'No of child requests submitted : ' || l_req_data_counter);

		END IF; -- IF l_hdr_lines_tbl.count > 0

		commit;

		IF l_debug_level > 0 THEN
			oe_debug_pub.add('Exiting OE_BATCH_PRICING.PRICE', 1);
		END IF;
	ELSIF p_header_id is not null THEN
	/* p_header_id is not null means, this is the child request */

		IF l_debug_level > 0 THEN
			oe_debug_pub.add('Entering OE_BATCH_PRICING.PRICE FOR CHILD_REQUEST', 1);
		END IF;

		ERRBUF  := 'Batch Pricing Child Request completed successfully';
		RETCODE := 0;

		IF l_debug_level > 0 THEN
			oe_debug_pub.add('Fetching current user/resp context', 5);
		END IF;

		FND_PROFILE.Get('USER_ID', l_user_id);
		FND_PROFILE.Get('RESP_ID', l_resp_id);
		FND_PROFILE.Get('RESP_APPL_ID', l_resp_appl_id);

		IF l_debug_level > 0 THEN
			oe_debug_pub.add('... Request ID : ' || l_request_id || '; USER_ID : ' || l_user_id || '; RESP_ID : ' || l_resp_id || '; APPL_ID : ' || l_resp_appl_id, 5);
		END IF;

		fnd_global.apps_initialize(FND_GLOBAL.USER_ID, FND_GLOBAL.RESP_ID, FND_GLOBAL.RESP_APPL_ID);

		IF p_org_id IS NOT NULL THEN
			MO_GLOBAL.set_policy_context(p_access_mode => 'S', p_org_id  => p_org_id);
		END IF;

		IF l_debug_level > 0 THEN
			oe_debug_pub.add('Before calling OE_ORDER_ADJ_PVT.Price_Action', 1);
			oe_debug_pub.add('...Pricing Level : ' || p_pricing_level, 5);
			oe_debug_pub.add('...Operating Unit : ' || p_org_id, 5);
			oe_debug_pub.add('...Header Id : ' || p_header_id, 5);
			oe_debug_pub.add('...Lines Count :' || p_line_count || '; List : ' || p_line_list, 5);
		END IF;

		IF p_pricing_level = 'ORDER' THEN
			OE_ORDER_ADJ_PVT.price_action
			(
				p_header_count          =>      1,
				p_header_list           =>      p_header_id,
				p_line_count            =>      0,
				p_line_list             =>      NULL,
				p_price_level           =>      p_pricing_level,
				x_return_status         =>      l_return_status,
				x_msg_count             =>      l_msg_count,
				x_msg_data              =>      l_msg_data
			);
		ELSIF p_pricing_level = 'LINE' THEN
			OE_ORDER_ADJ_PVT.price_action
			(
				p_header_count          =>      0,
				p_header_list           =>      null,
				p_line_count            =>      p_line_count,
				p_line_list             =>      p_line_list,
				p_price_level           =>      p_pricing_level,
				x_return_status         =>      l_return_status,
				x_msg_count             =>      l_msg_count,
				x_msg_data              =>      l_msg_data
			);
		END IF; -- p_pricing_level

		IF l_debug_level > 0 THEN
			oe_debug_pub.add('After calling OE_ORDER_ADJ_PVT.Price_Action; Status : ' || l_return_status, 1);
		END IF;

		IF l_return_status = 'S' THEN
			commit;
		ELSE
			rollback;
		END IF;

		IF l_debug_level > 0 THEN
			oe_debug_pub.add('Exiting OE_BATCH_PRICING.PRICE FOR CHILD_REQUEST', 1);
		END IF;

	END IF;	-- Child Request
Exception
When OTHERS Then
	oe_debug_pub.add('Others error in OE_BATCH_PRICING.PRICE : ' || SQLERRM, 1);
	rollback;

END PRICE;

END OE_BATCH_PRICING;

/
