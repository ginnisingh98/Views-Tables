--------------------------------------------------------
--  DDL for Package Body ISC_EDW_BOOKINGS_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_EDW_BOOKINGS_F_C" AS
/* $Header: ISCSCF0B.pls 120.1 2005/09/07 11:55:23 scheung noship $ */

  g_row_count		NUMBER		:= 0;
  g_rows_collected	NUMBER		:= 0;
  g_miss_conv		NUMBER		:= 0;
  g_seq_id_line_1	NUMBER		:= -1;
  g_seq_id_line_2	NUMBER		:= -1;
  g_seq_id_line_3	NUMBER		:= -1;

  g_push_from_date	DATE 		:= NULL;
  g_push_to_date	DATE 		:= NULL;

  g_all_or_nothing_flag	VARCHAR2(5)	:= 'Y';
  g_errbuf		VARCHAR2(2000) 	:= NULL;



      -- -------------
      -- PUSH_TO_LOCAL
      -- -------------

FUNCTION Push_To_Local(p_view_type IN NUMBER, p_seq_id IN NUMBER) RETURN NUMBER IS

BEGIN

  INSERT INTO ISC_EDW_BOOKINGS_FSTG(
	 AGREEMENT_ID,
	 AGREEMENT_TYPE_FK,
	 BILL_TO_CUST_FK,
	 BILL_TO_LOC_FK,
	 BOOKED_DATE,
	 BOOKINGS_PK,
	 CAMPAIGN_ACTL_FK,
	 CAMPAIGN_INIT_FK,
	 CAMPAIGN_STATUS_ACTL_FK,
	 CAMPAIGN_STATUS_INIT_FK,
	 CANCEL_REASON_FK,
	 CONFIGURATION_ITEM_FLAG,
	 CONVERSION_DATE,
	 CONVERSION_RATE,
	 CONVERSION_TYPE,
	 CURRENCY_TRN_FK,
	 CUSTOMER_FK,
	 CUST_PO_NUMBER,
	 DATE_BOOKED_FK,
	 DATE_FULFILLED,
	 DATE_LATEST_PICK,
	 DATE_LATEST_SHIP,
	 DATE_PROMISED_FK,
	 DATE_REQUESTED_FK,
	 DATE_SCHEDULED_FK,
	 DEMAND_CLASS_FK,
	 EVENT_OFFER_ACTL_FK,
	 EVENT_OFFER_INIT_FK,
	 EVENT_OFFER_REG_FK,
	 FULFILLMENT_FLAG,
	 HEADER_ID,
	 INCLUDED_ITEM_FLAG,
	 INSTANCE,
	 INSTANCE_FK,
	 INV_ORG_FK,
	 ITEM_TYPE_CODE,
	 ITEM_ORG_FK,
	 LAST_UPDATE_DATE,
	 LINE_DETAIL_ID,
	 LINE_ID,
	 MARKET_SEGMENT_FK,
	 MEDCHN_ACTL_FK,
	 MEDCHN_INIT_FK,
	 OFFER_HDR_FK,
	 OFFER_LINE_FK,
	 OPERATING_UNIT_FK,
	 ORDER_CATEGORY_FK,
	 ORDER_NUMBER,
	 ORDER_SOURCE_FK,
	 ORDER_TYPE_FK,
	 ORDERED_DATE,
	 PRICE_LIST_ID,
	 PROMISED_DATE,
	 QTY_CANCELLED,
	 QTY_FULFILLED,
	 QTY_INVOICED,
	 QTY_ORDERED,
	 QTY_RESERVED,
	 QTY_RETURNED,
	 QTY_SHIPPED,
	 REQUESTED_DATE,
	 RETURN_REASON_FK,
	 SALES_CHANNEL_FK,
	 SALES_PERSON_FK,
	 SCHEDULED_DATE,
	 SET_OF_BOOKS_FK,
	 SHIPPABLE_FLAG,
	 SHIP_TO_CUST_FK,
	 SHIP_TO_LOC_FK,
	 SOURCE_LIST_FK,
	 TARGET_SEGMENT_ACTL_FK,
	 TARGET_SEGMENT_INIT_FK,
	 TASK_FK,
	 TOP_MODEL_FK,
	 TOTAL_NET_ORDER_VALUE,
	 TRANSACTABLE_FLAG,
	 UNIT_COST_G,
	 UNIT_COST_T,
	 UNIT_LIST_PRC_G,
	 UNIT_LIST_PRC_T,
	 UNIT_SELL_PRC_G,
	 UNIT_SELL_PRC_T,
	 UOM_UOM_FK,
	 USER_ATTRIBUTE1,
	 USER_ATTRIBUTE10,
	 USER_ATTRIBUTE11,
	 USER_ATTRIBUTE12,
	 USER_ATTRIBUTE13,
	 USER_ATTRIBUTE14,
	 USER_ATTRIBUTE15,
	 USER_ATTRIBUTE16,
	 USER_ATTRIBUTE17,
	 USER_ATTRIBUTE18,
	 USER_ATTRIBUTE19,
	 USER_ATTRIBUTE2,
	 USER_ATTRIBUTE20,
	 USER_ATTRIBUTE21,
	 USER_ATTRIBUTE22,
	 USER_ATTRIBUTE23,
	 USER_ATTRIBUTE24,
	 USER_ATTRIBUTE25,
	 USER_ATTRIBUTE3,
	 USER_ATTRIBUTE4,
	 USER_ATTRIBUTE5,
	 USER_ATTRIBUTE6,
	 USER_ATTRIBUTE7,
	 USER_ATTRIBUTE8,
	 USER_ATTRIBUTE9,
	 USER_FK1,
	 USER_FK2,
	 USER_FK3,
	 USER_FK4,
	 USER_FK5,
	 USER_MEASURE1,
	 USER_MEASURE2,
	 USER_MEASURE3,
	 USER_MEASURE4,
	 USER_MEASURE5,
	 OPERATION_CODE,
	 COLLECTION_STATUS)
  SELECT /*+ leading(ISC_EDW_BOOKINGS_F_FCV.ISCBV_BOOKINGS_FCV.ftp) */
         AGREEMENT_ID,
	 AGREEMENT_TYPE_FK,
	 BILL_TO_CUST_FK,
	 BILL_TO_LOC_FK,
	 BOOKED_DATE,
	 BOOKINGS_PK,
	 CAMPAIGN_ACTL_FK,
	 CAMPAIGN_INIT_FK,
	 CAMPAIGN_STATUS_ACTL_FK,
	 CAMPAIGN_STATUS_INIT_FK,
	 CANCEL_REASON_FK,
	 CONFIGURATION_ITEM_FLAG,
	 CONVERSION_DATE,
	 CONVERSION_RATE,
	 CONVERSION_TYPE,
	 CURRENCY_TRN_FK,
	 CUSTOMER_FK,
	 CUST_PO_NUMBER,
	 DATE_BOOKED_FK,
	 DATE_FULFILLED,
	 DATE_LATEST_PICK,
	 DATE_LATEST_SHIP,
	 DATE_PROMISED_FK,
	 DATE_REQUESTED_FK,
	 DATE_SCHEDULED_FK,
	 DEMAND_CLASS_FK,
	 EVENT_OFFER_ACTL_FK,
	 EVENT_OFFER_INIT_FK,
	 EVENT_OFFER_REG_FK,
	 FULFILLMENT_FLAG,
	 HEADER_ID,
	 INCLUDED_ITEM_FLAG,
	 INSTANCE,
	 INSTANCE_FK,
	 INV_ORG_FK,
	 ITEM_TYPE_CODE,
	 ITEM_ORG_FK,
	 LAST_UPDATE_DATE,
	 LINE_DETAIL_ID,
	 LINE_ID,
	 MARKET_SEGMENT_FK,
	 MEDCHN_ACTL_FK,
	 MEDCHN_INIT_FK,
	 OFFER_HDR_FK,
	 OFFER_LINE_FK,
	 OPERATING_UNIT_FK,
	 ORDER_CATEGORY_FK,
	 ORDER_NUMBER,
	 ORDER_SOURCE_FK,
	 ORDER_TYPE_FK,
	 ORDERED_DATE,
	 PRICE_LIST_ID,
	 PROMISED_DATE,
	 QTY_CANCELLED,
	 QTY_FULFILLED,
	 QTY_INVOICED,
	 QTY_ORDERED,
	 QTY_RESERVED,
	 QTY_RETURNED,
	 QTY_SHIPPED,
	 REQUESTED_DATE,
	 RETURN_REASON_FK,
	 SALES_CHANNEL_FK,
	 SALES_PERSON_FK,
	 SCHEDULED_DATE,
	 SET_OF_BOOKS_FK,
	 SHIPPABLE_FLAG,
	 SHIP_TO_CUST_FK,
	 SHIP_TO_LOC_FK,
	 SOURCE_LIST_FK,
	 TARGET_SEGMENT_ACTL_FK,
	 TARGET_SEGMENT_INIT_FK,
	 TASK_FK,
	 TOP_MODEL_FK,
	 TOTAL_NET_ORDER_VALUE,
	 TRANSACTABLE_FLAG,
	 UNIT_COST_G,
	 UNIT_COST_T,
	 UNIT_LIST_PRC_G,
	 UNIT_LIST_PRC_T,
	 UNIT_SELL_PRC_G,
	 UNIT_SELL_PRC_T,
	 UOM_UOM_FK,
	 USER_ATTRIBUTE1,
	 USER_ATTRIBUTE10,
	 USER_ATTRIBUTE11,
	 USER_ATTRIBUTE12,
	 USER_ATTRIBUTE13,
	 USER_ATTRIBUTE14,
	 USER_ATTRIBUTE15,
	 USER_ATTRIBUTE16,
	 USER_ATTRIBUTE17,
	 USER_ATTRIBUTE18,
	 USER_ATTRIBUTE19,
	 USER_ATTRIBUTE2,
	 USER_ATTRIBUTE20,
	 USER_ATTRIBUTE21,
	 USER_ATTRIBUTE22,
	 USER_ATTRIBUTE23,
	 USER_ATTRIBUTE24,
	 USER_ATTRIBUTE25,
	 USER_ATTRIBUTE3,
	 USER_ATTRIBUTE4,
	 USER_ATTRIBUTE5,
	 USER_ATTRIBUTE6,
	 USER_ATTRIBUTE7,
	 USER_ATTRIBUTE8,
	 USER_ATTRIBUTE9,
	 nvl(USER_FK1,'NA_EDW'),
	 nvl(USER_FK2,'NA_EDW'),
	 nvl(USER_FK3,'NA_EDW'),
	 nvl(USER_FK4,'NA_EDW'),
	 nvl(USER_FK5,'NA_EDW'),
	 USER_MEASURE1,
	 USER_MEASURE2,
	 USER_MEASURE3,
	 USER_MEASURE4,
	 USER_MEASURE5,
	 NULL, -- OPERATION_CODE
	 'READY'
    FROM ISC_EDW_BOOKINGS_F_FCV
   WHERE view_type = p_view_type
     AND seq_id    = p_seq_id;

  RETURN(sql%rowcount);

EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in Function Push_To_Local : '||sqlerrm;
    RETURN(-1);
END;



      -- ---------------
      -- IDENTIFY_CHANGE
      -- ---------------

FUNCTION Identify_Change( p_view_type           IN  		NUMBER,
                          p_parent_seq_id	IN  		NUMBER,
			  p_count           	OUT NOCOPY	NUMBER) RETURN NUMBER IS

  l_seq_id	       NUMBER 		:= -1;

BEGIN

  p_count := 0;

  SELECT isc_tmp_pk_s.nextval
    INTO l_seq_id
    FROM dual;

      -- ------------------------------------------
      -- Populate rowid into isc_tmp_pk table based
      -- on last update date
      -- ------------------------------------------

      -- --------------------------------------------
      -- For EVERYTHING BUT INVOICES AND RESERVATIONS
      -- --------------------------------------------
  IF (p_view_type = 1)
    THEN
      INSERT INTO isc_tmp_pk(
	     SEQ_ID,
	     PK1,
	     PK2 )
      SELECT /*+ PARALLEL(h) */
	     l_seq_id,
             to_char(l.line_id),
             to_char(l.line_id)
	FROM oe_order_headers_all 	h,
	     oe_order_lines_all		l
       WHERE h.last_update_date BETWEEN g_push_from_date AND g_push_to_date
	 AND l.header_id = h.header_id
       UNION
      SELECT /*+ PARALLEL(l) */
  	     l_seq_id,
	     to_char(l.line_id),
  	     to_char(l.line_id)
	FROM oe_order_lines_all 	l
       WHERE l.last_update_date BETWEEN g_push_from_date AND g_push_to_date;

  p_count := sql%rowcount;

  UPDATE ISC_TMP_PK
     SET seq_id = l_seq_id
   WHERE seq_id = -10
     AND pk2 NOT IN (SELECT pk2 FROM ISC_TMP_PK WHERE seq_id = l_seq_id) ;

  p_count := p_count + sql%rowcount;

	  DELETE ISC_TMP_PK
	   WHERE seq_id = -10;

      -- ----------------
      -- For RESERVATIONS
      -- ----------------

  ELSIF (p_view_type = 2)
    THEN
      INSERT INTO isc_tmp_pk(
	     SEQ_ID,
	     PK1,
	     PK2)
      SELECT l_seq_id,
	     mtl.reservation_id,
	     mtl.demand_source_line_id
	FROM isc_tmp_pk		isc,
	     mtl_reservations	mtl
       WHERE isc.PK1 = mtl.demand_source_line_id
	 AND isc.seq_ID = p_parent_seq_id
	 AND mtl.reservation_quantity IS NOT NULL
	 AND mtl.reservation_quantity <> 0
       UNION
      SELECT l_seq_id,
	     mtl.reservation_id,
	     mtl.demand_source_line_id
	FROM mtl_reservations mtl
       WHERE mtl.last_update_date BETWEEN g_push_from_date AND g_push_to_date
	 AND mtl.reservation_quantity IS NOT NULL
	 AND mtl.reservation_quantity <> 0;

  p_count := sql%rowcount;

  UPDATE ISC_TMP_PK
     SET seq_id = l_seq_id
   WHERE seq_id = -20
     AND pk2 NOT IN (SELECT pk2 FROM ISC_TMP_PK WHERE SEQ_ID = l_seq_id);

  p_count := p_count + sql%rowcount;

  DELETE ISC_TMP_PK
   WHERE seq_id = -20;

      -- -----------------
      -- For CANCELLATIONS
      -- -----------------

  ELSIF (p_view_type = 3)
    THEN
      INSERT INTO isc_tmp_pk(
	     SEQ_ID,
	     PK1,
	     PK2)
      SELECT l_seq_id,
	     hist.line_id||to_char(hist.hist_creation_date,'SSSSS'),
	     hist.line_id
	FROM isc_tmp_pk isc,
	     oe_order_lines_history hist
       WHERE isc.PK1 = hist.line_id
	 AND isc.seq_ID = p_parent_seq_id
	 AND hist.hist_type_code = 'CANCELLATION'
       UNION
      SELECT l_seq_id,
	     hist.line_id||to_char(hist.hist_creation_date,'SSSSS'),
	     hist.line_id
	FROM oe_order_lines_history hist
       WHERE hist.last_update_date BETWEEN g_push_from_date AND g_push_to_date
	 AND hist.hist_type_code = 'CANCELLATION';

  p_count := sql%rowcount;

  UPDATE ISC_TMP_PK
     SET seq_id = l_seq_id
   WHERE seq_id = -30
     AND pk2 NOT IN (SELECT pk2 FROM ISC_TMP_PK WHERE SEQ_ID = l_seq_id);

  p_count := p_count + sql%rowcount;

  DELETE ISC_TMP_PK
   WHERE seq_id = -30;

  END IF;

  RETURN(l_seq_id);

EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in Function Identify_Change : '||sqlerrm;
    RETURN(-1);
END;


      -- ---------------------
      -- IDENTIFY_MISSING_RATE
      -- ---------------------

FUNCTION Identify_Missing_Rate (p_count OUT NOCOPY NUMBER) RETURN NUMBER IS

BEGIN

  p_count := 0;

  INSERT INTO ISC_EDW_BOOK_MISSING_RATE
		( ID,
		  PK1,
		  PK2,
		  CURR_CONV_DATE,
		  FROM_CURRENCY,
		  TO_CURRENCY,
		  RATE_TYPE,
		  FROM_UOM_CODE,
		  TO_UOM_CODE,
		  INVENTORY_ITEM_ID,
		  ITEM_NAME,
		  STATUS)
  SELECT -- Reports Transaction to Base Conversion Currency Issue
	 g_seq_id_line_1			ID,
	 ftp.pk1				PK1,
	 l.line_id				PK2,
  	 decode( upper(h.conversion_type_code), 'USER',
 		 h.conversion_rate_date,
 		 h.booked_date)			CURR_CONV_DATE,
  	 h.transactional_curr_code		FROM_CURRENCY,
  	 gl.currency_code			TO_CURRENCY,
	 nvl(h.conversion_type_code,
	     edw_param.rate_type)		RATE_TYPE,
	 ''					FROM_UOM_CODE,
	 ''					TO_UOM_CODE,
	 ''					INVENTORY_ITEM_ID,
	 ''					ITEM_NAME,
  	 decode( decode( upper(h.conversion_type_code), 'USER',
 			 h.conversion_rate,
 			 decode( h.transactional_curr_code, gl.currency_code,
 				 1,
 				 GL_CURRENCY_API.get_rate_sql(
 					 h.transactional_curr_code,
 					 gl.currency_code,
 					 h.booked_date,
 					 nvl(h.conversion_type_code, edw_param.rate_type)))),
 		 -1,
 		 'RATE NOT AVAILABLE',
 		 -2,
 		 'INVALID CURRENCY')		STATUS
  FROM	 EDW_LOCAL_SYSTEM_PARAMETERS		edw_param,
  	 ISC_TMP_PK				ftp,
  	 OE_ORDER_LINES_ALL			l,
  	 OE_ORDER_HEADERS_ALL			h,
  	 FINANCIALS_SYSTEM_PARAMS_ALL		fspa,
  	 GL_SETS_OF_BOOKS			gl
   WHERE ftp.pk2 = l.line_id
     AND ftp.seq_id = g_seq_id_line_1
     AND l.org_id = fspa.org_id
     AND l.header_id = h.header_id
     AND fspa.set_of_books_id = gl.set_of_books_id
     AND h.booked_flag = 'Y'
     AND h.booked_date IS NOT NULL
     AND decode( upper(h.conversion_type_code), 'USER',
 		 h.conversion_rate,
 		 decode( h.transactional_curr_code, gl.currency_code,
 			 1,
 			 GL_CURRENCY_API.get_rate_sql(
 				 h.transactional_curr_code,
 				 gl.currency_code,
 				 h.booked_date,
 				 nvl(h.conversion_type_code, edw_param.rate_type)))) < 0
  UNION
  SELECT -- Reports Base to Global Conversion Currency Issue
	 g_seq_id_line_1			ID,
	 ftp.pk1				PK1,
  	 l.line_id				PK2,
  	 decode(upper(h.conversion_type_code), 'USER',
 		 h.conversion_rate_date,
 		 h.booked_date)			CURR_CONV_DATE,
  	 gl.currency_code			FROM_CURRENCY,
  	 edw_param.warehouse_currency_code	TO_CURRENCY,
	 nvl(h.conversion_type_code,
	     edw_param.rate_type)		RATE_TYPE,
	 ''					FROM_UOM_CODE,
	 ''					TO_UOM_CODE,
	 ''					INVENTORY_ITEM_ID,
	 ''					ITEM_NAME,
  	 decode( EDW_CURRENCY.Get_Rate (gl.currency_code,h.booked_date),
 		 -1,
 		 'RATE NOT AVAILABLE',
 		 -2,
 		 'INVALID CURRENCY')		STATUS
    FROM EDW_LOCAL_SYSTEM_PARAMETERS		edw_param,
  	 ISC_TMP_PK				ftp,
  	 OE_ORDER_LINES_ALL			l,
  	 OE_ORDER_HEADERS_ALL			h,
  	 FINANCIALS_SYSTEM_PARAMS_ALL		fspa,
  	 GL_SETS_OF_BOOKS			gl
   WHERE ftp.pk2 = l.line_id
     AND ftp.seq_id = g_seq_id_line_1
     AND l.org_id = fspa.org_id
     AND l.header_id = h.header_id
     AND fspa.set_of_books_id = gl.set_of_books_id
     AND h.booked_flag = 'Y'
     AND h.booked_date IS NOT NULL
     AND EDW_CURRENCY.Get_Rate (gl.currency_code,h.booked_date) < 0
  UNION
  SELECT -- Reports Base to Transaction Conversion Currency Issue
	 g_seq_id_line_1			ID,
	 ftp.pk1				PK1,
	 l.line_id				PK2,
  	 decode(upper(h.conversion_type_code), 'USER',
 		 h.conversion_rate_date,
 		 h.booked_date)			CURR_CONV_DATE,
  	 gl.currency_code			FROM_CURRENCY,
  	 h.transactional_curr_code		TO_CURRENCY,
	 nvl(h.conversion_type_code,
	     edw_param.rate_type)		RATE_TYPE,
	 ''					FROM_UOM_CODE,
	 ''					TO_UOM_CODE,
	 ''					INVENTORY_ITEM_ID,
	 ''					ITEM_NAME,
  	 decode( decode( upper(h.conversion_type_code),'USER',
 			 1/ h.conversion_rate,
 			 decode( h.transactional_curr_code, gl.currency_code,
 				 1,
 				 GL_CURRENCY_API.get_rate_sql (
 					     gl.currency_code,
 					     h.transactional_curr_code,
 					     h.booked_date,
 					     nvl(h.conversion_type_code, edw_param.rate_type)))),
 		 -1,
 		 'RATE NOT AVAILABLE',
 		 -2,
 		 'INVALID CURRENCY')		STATUS
    FROM EDW_LOCAL_SYSTEM_PARAMETERS		edw_param,
  	 ISC_TMP_PK				ftp,
  	 OE_ORDER_LINES_ALL			l,
  	 OE_ORDER_HEADERS_ALL			h,
  	 FINANCIALS_SYSTEM_PARAMS_ALL		fspa,
  	 GL_SETS_OF_BOOKS			gl
   WHERE ftp.pk2 = l.line_id
     AND ftp.seq_id = g_seq_id_line_1
     AND l.org_id = fspa.org_id
     AND l.header_id = h.header_id
     AND fspa.set_of_books_id = gl.set_of_books_id
     AND h.booked_flag = 'Y'
     AND h.booked_date IS NOT NULL
     AND decode( upper(h.conversion_type_code),'USER',
 		 1/ h.conversion_rate,
 		 decode( h.transactional_curr_code, gl.currency_code,
 			 1,
 			 GL_CURRENCY_API.get_rate_sql (
 					 gl.currency_code,
 					 h.transactional_curr_code,
 					 h.booked_date,
 					 nvl(h.conversion_type_code, edw_param.rate_type)))) < 0
  UNION
  SELECT -- Reports "Ship from Org Base" to "Header Org Base" Conversion Currency Issue
	 g_seq_id_line_1			ID,
	 ftp.pk1				PK1,
  	 l.line_id				PK2,
  	 h.booked_date				CURR_CONV_DATE,
  	 gl_cost.currency_code			FROM_CURRENCY,
  	 gl.currency_code			TO_CURRENCY,
	 edw_param.rate_type			RATE_TYPE,
	 ''					FROM_UOM_CODE,
	 ''					TO_UOM_CODE,
	 ''					INVENTORY_ITEM_ID,
	 ''					ITEM_NAME,
  	 decode(GL_CURRENCY_API.get_rate_sql (
 			     gl_cost.currency_code,
 			     gl.currency_code,
 			     h.booked_date,
 			     edw_param.rate_type),
 		 -1,
 		 'RATE NOT AVAILABLE',
 		 -2,
 		 'INVALID CURRENCY')		STATUS
    FROM EDW_LOCAL_SYSTEM_PARAMETERS		edw_param,
	 ISC_TMP_PK				ftp,
	 OE_ORDER_LINES_ALL			l,
	 OE_ORDER_HEADERS_ALL			h,
	 FINANCIALS_SYSTEM_PARAMS_ALL		fspa,
	 GL_SETS_OF_BOOKS			gl,
	 GL_SETS_OF_BOOKS			gl_cost,
	 HR_ORGANIZATION_INFORMATION		hoi
   WHERE ftp.pk2 = l.line_id
     AND ftp.seq_id = g_seq_id_line_1
     AND l.org_id = fspa.org_id
     AND l.header_id = h.header_id
     AND fspa.set_of_books_id = gl.set_of_books_id
     AND l.ship_from_org_id = hoi.organization_id -- if ship_from_org_id is null, don't include row in the missing rates
     AND hoi.org_information_context = 'Accounting Information'
     AND hoi.org_information1 = to_char(gl_cost.set_of_books_id)
     AND h.booked_flag = 'Y'
     AND h.booked_date IS NOT NULL
     AND GL_CURRENCY_API.get_rate_sql (
		gl_cost.currency_code,
		gl.currency_code,
		h.booked_date,
		edw_param.rate_type) < 0;

   p_count := sql%rowcount;

  INSERT INTO ISC_EDW_BOOK_MISSING_RATE(
	 ID,
	 PK1,
	 PK2,
	 CURR_CONV_DATE,
	 FROM_CURRENCY,
	 TO_CURRENCY,
	 RATE_TYPE,
	 FROM_UOM_CODE,
	 TO_UOM_CODE,
	 INVENTORY_ITEM_ID,
	 ITEM_NAME,
	 STATUS)
  SELECT -- Reports UOM Conversion Issue
	 g_seq_id_line_1			ID,
	 ftp.pk1				PK1,
	 l.line_id				PK2,
  	 to_date(NULL)				CURR_CONV_DATE,
  	 ''					FROM_CURRENCY,
  	 ''					TO_CURRENCY,
	 ''					RATE_TYPE,
	 l.order_quantity_uom			FROM_UOM_CODE,
	 EDW_UTIL.Get_Edw_Base_Uom(
		l.order_quantity_uom,
		l.inventory_item_id)		TO_UOM_CODE,
	 l.inventory_item_id			INVENTORY_ITEM_ID,
	 nvl(mtl.segment1,'Item number unavailable')
	   ||' : '||nvl(description,'Description unavailable')
						ITEM_NAME,
  	 'UOM ISSUE'				STATUS
    FROM ISC_TMP_PK				ftp,
  	 OE_ORDER_LINES_ALL			l,
  	 OE_ORDER_HEADERS_ALL			h,
	 MTL_SYSTEM_ITEMS_B			mtl
   WHERE ftp.pk2 = l.line_id
     AND ftp.seq_id = g_seq_id_line_1
     AND l.header_id = h.header_id
     AND h.booked_flag = 'Y'
     AND h.booked_date IS NOT NULL
     AND l.ship_from_org_id = mtl.organization_id
     AND l.inventory_item_id = mtl.inventory_item_id
     AND EDW_UTIL.Get_Uom_Conv_Rate(l.order_quantity_uom,l.inventory_item_id) IS NULL;

  p_count := p_count + sql%rowcount;

  RETURN(p_count);

EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in Function Identify_Missing_Rate : '||sqlerrm;
    RETURN(-1);
END;


      -- -----------------
      -- INSERT_ISC_TMP_PK
      -- -----------------

FUNCTION Insert_Isc_Tmp_Pk (p_count OUT NOCOPY NUMBER) RETURN NUMBER IS

BEGIN

  p_count := 0 ;

  INSERT INTO ISC_TMP_PK (
	 seq_id,
	 pk1,
	 pk2)
  SELECT -10,
	 ftp.pk1,
	 ftp.pk2
    FROM ISC_EDW_BOOK_MISSING_RATE	conv,
	 ISC_TMP_PK 			ftp
   WHERE conv.pk2 = ftp.pk2
     AND ftp.seq_id = g_seq_id_line_1
     AND conv.id = g_seq_id_line_1 ;

  p_count := p_count + sql%rowcount ;

  INSERT INTO ISC_TMP_PK (
	 seq_id,
	 pk1,
	 pk2)
  SELECT -20,
	 ftp.pk1,
	 ftp.pk2
    FROM ISC_EDW_BOOK_MISSING_RATE	conv,
	 ISC_TMP_PK			ftp
   WHERE conv.pk2 = ftp.pk2
     AND ftp.seq_id = g_seq_id_line_2
     AND conv.id = g_seq_id_line_1;

  p_count := p_count + sql%rowcount ;

  INSERT INTO ISC_TMP_PK (
	 seq_id,
	 pk1,
	 pk2)
  SELECT -30,
	 ftp.pk1,
	 ftp.pk2
    FROM ISC_EDW_BOOK_MISSING_RATE	conv,
	 ISC_TMP_PK			ftp
   WHERE conv.pk2 = ftp.pk2
     AND ftp.seq_id = g_seq_id_line_3
     AND conv.id = g_seq_id_line_1;

  p_count := p_count + sql%rowcount ;

  RETURN(p_count);

EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in Function INSERT_ISC_TMP_PK : '||sqlerrm;
    RETURN(-1);
END;


      -- -----------------
      -- DELETION_HANDLING
      -- -----------------

FUNCTION Deletion_Handling RETURN NUMBER IS

  l_stmt			VARCHAR2(20000);
  l_apps_to_apps    		VARCHAR2(100);
  l_edw_apps_to_wh  		VARCHAR2(100);
  l_edw_local_instance		VARCHAR2(100);

BEGIN

  EDW_COLLECTION_UTIL.Get_Dblink_Names(l_apps_to_apps,l_edw_apps_to_wh);
  l_stmt := 'SELECT instance_code FROM EDW_LOCAL_INSTANCE';
  EXECUTE IMMEDIATE l_stmt INTO l_edw_local_instance;

  l_stmt := 'INSERT  INTO ISC_EDW_BOOKINGS_FSTG (
	BOOKINGS_PK,
	COLLECTION_STATUS,
	OPERATION_CODE,
  	AGREEMENT_TYPE_FK,
	BILL_TO_CUST_FK,
	BILL_TO_LOC_FK,
	CAMPAIGN_ACTL_FK,
	CAMPAIGN_INIT_FK,
	CAMPAIGN_STATUS_ACTL_FK,
	CAMPAIGN_STATUS_INIT_FK,
	CANCEL_REASON_FK,
	CURRENCY_TRN_FK,
	CUSTOMER_FK,
	DATE_BOOKED_FK,
	DATE_PROMISED_FK,
	DATE_REQUESTED_FK,
	DATE_SCHEDULED_FK,
	DEMAND_CLASS_FK,
	EVENT_OFFER_ACTL_FK,
	EVENT_OFFER_INIT_FK,
	EVENT_OFFER_REG_FK,
	INSTANCE_FK,
	INV_ORG_FK,
	ITEM_ORG_FK,
	MARKET_SEGMENT_FK,
	MEDCHN_ACTL_FK,
	MEDCHN_INIT_FK,
	OFFER_HDR_FK,
	OFFER_LINE_FK,
	OPERATING_UNIT_FK,
	ORDER_CATEGORY_FK,
	ORDER_SOURCE_FK,
	ORDER_TYPE_FK,
	RETURN_REASON_FK,
	SALES_CHANNEL_FK,
	SALES_PERSON_FK,
	SET_OF_BOOKS_FK,
	SHIP_TO_CUST_FK,
	SHIP_TO_LOC_FK,
	SOURCE_LIST_FK,
	TARGET_SEGMENT_ACTL_FK,
	TARGET_SEGMENT_INIT_FK,
	TASK_FK,
	TOP_MODEL_FK,
	UOM_UOM_FK,
	USER_FK1,
	USER_FK2,
	USER_FK3,
	USER_FK4,
	USER_FK5)
SELECT  /*+ INDEX(del ISC_EDW_BOOK_DEL_N1)*/
	del.BOOKINGS_PK,
	''READY'',
	''DELETE'',
 	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW''
  FROM ISC_EDW_BOOK_DEL@'||l_edw_apps_to_wh||' del
 WHERE del.inst_name = '''||l_edw_local_instance|| '''
   AND NOT EXISTS ( SELECT l.line_id
		      FROM OE_ORDER_LINES_ALL l
		     WHERE l.line_id = del.line_id)
UNION ALL
SELECT  /*+ INDEX(del ISC_EDW_BOOK_DEL_N1)*/
	del.BOOKINGS_PK,
	''READY'',
	''DELETE'',
 	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW'',
	''NA_EDW''
  FROM ISC_EDW_BOOK_DEL@'||l_edw_apps_to_wh||' del
 WHERE del.inst_name = '''||l_edw_local_instance|| '''
     	 AND substr(del.bookings_pk,1,3) = ''RES''
   	 AND NOT EXISTS (SELECT demand_source_line_id
     	       	          FROM MTL_RESERVATIONS res
			  WHERE res.demand_source_line_id = del.line_id
			  and del.bookings_pk= ''RES-''||res.reservation_id||''-'||l_edw_local_instance||''')';

  EXECUTE IMMEDIATE l_stmt;

  RETURN(sql%rowcount);

EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in Function Deletion_Handling : '||sqlerrm;
    RETURN(-1);
END;


      -- -----------------
      -- DELETE_ISC_TMP_PK
      -- -----------------

FUNCTION Delete_Isc_Tmp_Pk RETURN NUMBER IS

BEGIN

  DELETE FROM ISC_TMP_PK
  	WHERE pk2 IN ( SELECT pk2
			 FROM ISC_EDW_BOOK_MISSING_RATE
		        WHERE id = g_seq_id_line_1 )
	  AND seq_id >0 ;

  RETURN(sql%rowcount);

EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in Function Delete_Isc_Tmp_Pk : '||sqlerrm;
    RETURN(-1);
END;


      -- -----------------
      -- PUBLIC PROCEDURES
      -- -----------------

      -- --------------
      -- PROCEDURE PUSH
      -- --------------

Procedure Push(	errbuf		IN OUT NOCOPY VARCHAR2,
                retcode		IN OUT NOCOPY VARCHAR2,
                p_from_date	IN	VARCHAR2,
                p_to_date	IN	VARCHAR2,
		p_coll_flag	IN	VARCHAR2) IS  -- 'Yes' = All or Nothing , 'No' = Collect >0 rows only

 l_fact_name		VARCHAR2(30)	:= 'ISC_EDW_BOOKINGS_F'  ;

 l_from_date		DATE		:= NULL;
 l_to_date	   	DATE		:= NULL;

 l_row_count		NUMBER		:= 0;

 l_failure		EXCEPTION;

 CURSOR Missing_Currency_Conversion IS
 SELECT DISTINCT trunc(curr_conv_date) curr_conv_date,
	from_currency,
 	to_currency,
	rate_type,
 	status
   FROM ISC_EDW_BOOK_MISSING_RATE
  WHERE status NOT IN ('UOM ISSUE')
  ORDER BY status,from_currency,trunc(curr_conv_date);

 CURSOR Missing_UOM_Conversion IS
 SELECT DISTINCT from_uom_code,
	to_uom_code,
	inventory_item_id item_id,
	substr(item_name,0,50) item_name
   FROM ISC_EDW_BOOK_MISSING_RATE
  WHERE status = 'UOM ISSUE'
  ORDER BY item_name,from_uom_code;


      -- -------------------------------------------
      -- Put any additional developer variables here
      -- -------------------------------------------
BEGIN

  errbuf  := NULL;
  retcode := '0';

  l_from_date := to_date(p_from_date,'YYYY/MM/DD HH24:MI:SS');
  l_to_date   := to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS');

  g_all_or_nothing_flag := upper(p_coll_flag);

  IF (NOT EDW_COLLECTION_UTIL.Setup(l_fact_name))
    THEN
      g_errbuf := 'Error in function Setup : '||fnd_message.get;
      RAISE l_failure;
  END IF;

  ISC_EDW_BOOKINGS_F_C.G_Push_From_Date := nvl(l_from_date,
	EDW_COLLECTION_UTIL.G_Local_Last_Push_Start_Date - EDW_COLLECTION_UTIL.G_Offset);

  ISC_EDW_BOOKINGS_F_C.G_Push_To_Date := nvl(l_to_date,
	EDW_COLLECTION_UTIL.G_Local_Curr_Push_Start_Date);

  EDW_LOG.Put_Line( 'The collection range is from '||
	to_char(g_push_from_date,'MM/DD/YYYY HH24:MI:SS')||' to '||
	to_char(g_push_to_date,'MM/DD/YYYY HH24:MI:SS'));
  EDW_LOG.Put_Line(' ');


      -- ---------------------------------------
      -- Identify Change for Booked Orders Lines
      -- ---------------------------------------

  EDW_LOG.Put_Line('Identifying changed Booked orders lines');

FII_UTIL.Start_Timer;

  g_seq_id_line_1 := Identify_Change(1,-1 , l_row_count);

FII_UTIL.Stop_Timer;
FII_UTIL.Print_Timer('Identified '||l_row_count||' changed records in ');

  IF (g_seq_id_line_1 = -1)
    THEN RAISE l_failure;
  END IF;


      -- -----------------------------------
      -- Identify Change for Reserved Orders
      -- -----------------------------------

  EDW_LOG.Put_Line(' ');
  EDW_LOG.Put_Line('Identifying changed for reserved orders');

FII_UTIL.Start_Timer;

  g_seq_id_line_2 := Identify_Change(2, g_seq_id_line_1, l_row_count);

FII_UTIL.Stop_Timer;
FII_UTIL.Print_Timer('Identified '||l_row_count||' changed records in ');

  IF (g_seq_id_line_2 = -1)
    THEN RAISE l_failure;
  END IF;


      -- -------------------------------------------------
      -- Identify Change for Multiple-Cancellations Orders
      -- -------------------------------------------------

  EDW_LOG.Put_Line(' ');
  EDW_LOG.Put_Line('Identifying changed for Multi-Cancellations orders');

FII_UTIL.Start_Timer;

  g_seq_id_line_3 := Identify_Change(3, g_seq_id_line_1, l_row_count);

FII_UTIL.Stop_Timer;
FII_UTIL.Print_Timer('Identified '||l_row_count||' changed records in ');

  IF (g_seq_id_line_3 = -1)
    THEN RAISE l_failure;
  END IF;


      -- ----------------------------------------------------------
      -- Identify Missing Rate into ISC_EDW_BOOK_MISSING_RATE table
      -- ----------------------------------------------------------

  EDW_LOG.Put_Line(' ');
  EDW_LOG.Put_Line('Identifying the missing conversion rates (currency and UoM)');

FII_UTIL.Start_Timer;

  g_miss_conv := Identify_Missing_Rate (l_row_count);

FII_UTIL.Stop_Timer;

  IF (g_miss_conv = -1)
    THEN RAISE l_failure;
  END IF;

  FII_UTIL.Print_Timer('Inserted '||g_miss_conv||' rows into the ISC_EDW_BOOK_MISSING_RATE table in ');
  EDW_LOG.Put_Line(' ');


      -- --------------------------------------------------------------------
      -- Inserting into ISC_TMP_PK rows having missing rate (with seq_id < 0)
      -- --------------------------------------------------------------------

  EDW_LOG.Put_Line(' ');
  EDW_LOG.Put_Line('Inserting into ISC_TMP_PK with < 0 seq_id the rows having missing conversion rates (currency and UoM)');

FII_UTIL.Start_Timer;

  g_row_count := Insert_Isc_Tmp_Pk (l_row_count);

FII_UTIL.Stop_Timer;

  IF (g_row_count = -1)
    THEN RAISE l_failure;
  END IF;

  FII_UTIL.Print_Timer('Inserted '||l_row_count||' rows into the ISC_TMP_PK table in ');
  EDW_LOG.Put_Line(' ');


      -- --------------------------------------------
      -- Deleting ISC_TMP_PK rows having missing rate
      -- --------------------------------------------

  EDW_LOG.Put_Line(' ');
  EDW_LOG.Put_Line('Deleting the ISC_TMP_PK rows having a missing conversion rates before collecting (currency and UoM)');

FII_UTIL.Start_Timer;

  g_row_count := Delete_Isc_Tmp_Pk ;

FII_UTIL.Stop_Timer;

  IF (g_row_count = -1)
    THEN RAISE l_failure;
  END IF;

  FII_UTIL.Print_Timer('Deleted '||g_row_count||' rows from the ISC_TMP_PK table in ');
  EDW_LOG.Put_Line(' ');


  IF NOT ((g_all_or_nothing_flag = 'Y') and (g_miss_conv > 0))  -- collect except when this condition applies
    THEN
      BEGIN -- IF NOT ((g_all_or_nothing_flag = 'Y') and (g_miss_conv > 0))

      -- -------------------------------------------
      -- Push to Local staging table for view type 1
      -- -------------------------------------------

	EDW_LOG.Put_Line(' ');
	EDW_LOG.Put_Line('Pushing data to local staging with the view type = 1');

	EDW_LOG.Put_Line( 'The collection range is from '||
		to_char(g_push_from_date,'MM/DD/YYYY HH24:MI:SS')||' to '||
		to_char(g_push_to_date,'MM/DD/YYYY HH24:MI:SS'));

FII_UTIL.Start_Timer;

	g_row_count := Push_To_Local(1,g_seq_id_line_1);

FII_UTIL.Stop_Timer;

	IF (g_row_count = -1)
	  THEN RAISE l_failure;
	END IF;

	g_rows_collected := g_row_count;

	FII_UTIL.Print_Timer('Inserted '||g_row_count||' rows with view type = 1 into the local staging table in ');
	EDW_LOG.Put_Line(' ');


      -- -------------------------------------------
      -- Push to Local staging table for view type 2
      -- -------------------------------------------

	EDW_LOG.Put_Line(' ');
	EDW_LOG.Put_Line('Pushing data to local staging with the view type = 2');

	EDW_LOG.Put_Line(' ');
	EDW_LOG.Put_Line( 'The collection range is from '||
		to_char(g_push_from_date,'MM/DD/YYYY HH24:MI:SS')||' to '||
		to_char(g_push_to_date,'MM/DD/YYYY HH24:MI:SS'));
	EDW_LOG.Put_Line(' ');

FII_UTIL.Start_Timer;

	g_row_count := Push_To_Local(2,g_seq_id_line_2);

FII_UTIL.Stop_Timer;

	IF (g_row_count = -1)
	  THEN RAISE l_failure;
	END IF;

	g_rows_collected := g_rows_collected + g_row_count;

	FII_UTIL.Print_Timer('Inserted '||g_row_count||' rows with view type = 2 into the local staging table in ');
	EDW_LOG.Put_Line(' ');


      -- -------------------------------------------
      -- Push to Local staging table for view type 3
      -- -------------------------------------------

	EDW_LOG.Put_Line(' ');
	EDW_LOG.Put_Line('Pushing data to local staging with the view type = 3');
	EDW_LOG.Put_Line(' ');

FII_UTIL.Start_Timer;

	g_row_count := Push_To_Local(3,g_seq_id_line_3);

FII_UTIL.Stop_Timer;

	IF (g_row_count = -1)
	  THEN RAISE l_failure;
	END IF;

	g_rows_collected := g_rows_collected + g_row_count;

	FII_UTIL.Print_Timer('Inserted '||g_row_count||' rows with view type = 3 into the local staging table in ');
	EDW_LOG.Put_Line(' ');

	EDW_LOG.Put_Line(' ');
	EDW_LOG.Put_Line('Marking rows to be deleted from the Fact (rows having beeing deleted from the source instance table)');
	EDW_LOG.Put_Line(' ');

FII_UTIL.Start_Timer;

	g_row_count := Deletion_Handling;

FII_UTIL.Stop_Timer;

	IF (g_row_count = -1)
	  THEN RAISE l_failure;
	END IF;

	FII_UTIL.Print_Timer('Marked '||g_row_count||' rows to be deleted from the Fact in ');
	EDW_LOG.Put_Line(' ');

      END;
  END IF; -- IF NOT ((g_all_or_nothing_flag = 'Y') and (g_miss_conv > 0))


      -- -----------------
      -- Delete ISC_TMP_PK
      -- -----------------

  DELETE FROM isc_tmp_pk
	WHERE seq_id IN (g_seq_id_line_1, g_seq_id_line_2, g_seq_id_line_3);


      -- -------------------------------------------
      -- Reporting of the missing currencies and UoM
      -- -------------------------------------------

  IF g_miss_conv > 0
    THEN
      BEGIN  -- begin IF g_miss_conv > 0

      IF g_all_or_nothing_flag = 'N' -- We collected and report missing conversions
        THEN
	  retcode := 1;
	  EDW_LOG.Put_Line(' ');
	  EDW_LOG.Put_Line('Collection finished with a CONVERSION RATE WARNING.');
	  EDW_LOG.Put_Line(' ');
      ELSIF g_all_or_nothing_flag = 'Y'  -- We did not collect and report missing conversions
        THEN
	  retcode := -1;
	  EDW_LOG.Put_Line(' ');
	  EDW_LOG.Put_Line('Collection finished with a CONVERSION RATE ERROR.');
	  EDW_LOG.Put_Line('Collection aborted because there are missing conversion rates.');
	  EDW_LOG.Put_Line(' ');
      END IF; --g_all_or_nothing_flag = 'N'

      EDW_LOG.Put_Line('Below is the list of the missing conversions.');
      EDW_LOG.Put_Line('Enter the missing currency rates in Oracle General Ledger.');
      EDW_LOG.Put_Line('To fix the missing UOM please refer to the EDW implementation guide - UOM Setup');
      EDW_LOG.Put_Line(' ');

      EDW_LOG.Put_Line('+---------------------------------------------------------------------------+');
      EDW_LOG.Put_Line('		REPORT FOR THE MISSING CURRENCY CONVERSION RATES');
      EDW_LOG.Put_Line('');
      EDW_LOG.Put_Line('CONV. DATE - FROM CURR. - TO CURR. - CONV. TYPE CODE - STATUS');
      EDW_LOG.Put_Line('---------- - ---------- - -------- - --------------- - ----------------------');

      l_row_count := 0;

      FOR line IN Missing_Currency_Conversion
	LOOP
	  l_row_count := l_row_count + 1;
	  EDW_LOG.Put_Line( RPAD(line.curr_conv_date,10,' ')
			      ||' - '||RPAD(line.from_currency,10,' ')
			      ||' - '||RPAD(line.to_currency,8,' ')
			      ||' - '||RPAD(line.rate_type,15)
			      ||' - '||RPAD(line.status,20));
	END LOOP;

      IF l_row_count = 0
	THEN
	  EDW_LOG.Put_Line('');
	  EDW_LOG.Put_Line('           THERE IS NO MISSING CURRENCY CONVERSION RATE        ');
	  EDW_LOG.Put_Line('');
      END IF;

      EDW_LOG.Put_Line('+---------------------------------------------------------------------------+');
      EDW_LOG.Put_Line('');
      EDW_LOG.Put_Line('');
      EDW_LOG.Put_Line('');
      EDW_LOG.Put_Line('+---------------------------------------------------------------------------+');
      EDW_LOG.Put_Line('		REPORT FOR THE MISSING UNIT OF MEASURE CONVERSION RATES');
      EDW_LOG.Put_Line('');
      EDW_LOG.Put_Line('FROM UOM - TO UOM   - ITEM_ID  - ITEM NUMBER : ITEM DESCRIPTION');
      EDW_LOG.Put_Line('-------- - -------- - -------- - --------------------------------------------');

      l_row_count := 0;

      FOR line IN Missing_UOM_Conversion
        LOOP
	  l_row_count := l_row_count + 1;
	  EDW_LOG.Put_Line( RPAD(line.from_uom_code,8,' ')
			      ||' - '||RPAD(line.to_uom_code,8,' ')
			      ||' - '||RPAD(line.item_id,8,' ')
			      ||' - '||RPAD(line.item_name,42));
	END LOOP;

      IF l_row_count = 0
	THEN
	  EDW_LOG.Put_Line('');
	  EDW_LOG.Put_Line('           THERE IS NO MISSING UOM CONVERSION RATE        ');
	  EDW_LOG.Put_Line('');
      END IF;
      EDW_LOG.Put_Line('+---------------------------------------------------------------------------+');
      END; -- begin IF g_miss_conv > 0
  END IF; -- IF g_miss_conv > 0



      -- ------------------------------------------------------
      -- We are cleaning the table containing the missing rates
      -- ------------------------------------------------------


  DELETE FROM ISC_EDW_BOOK_MISSING_RATE
	WHERE id = g_seq_id_line_1;

      -- ----------------------------------------------
      -- No exception raised so far.  Successful.  Call
      -- Wrapup to commit and insert messages into logs
      -- ----------------------------------------------

  EDW_LOG.Put_Line(' ');
  EDW_LOG.Put_Line('Inserted '||g_rows_collected||' rows into the local staging table');
  EDW_LOG.Put_Line(' ');
  EDW_LOG.Put_Line('+---------------------------------------------------------------------------+');
  EDW_LOG.Put_Line(' ');
  EDW_LOG.Put_Line('Start of the Wrapup section ');
  EDW_LOG.Put_Line(' ');


  IF retcode = -1
    THEN
      EDW_COLLECTION_UTIL.Wrapup(
	FALSE,
	g_rows_collected,
	NULL,
	ISC_EDW_BOOKINGS_F_C.G_Push_From_Date,
	ISC_EDW_BOOKINGS_F_C.G_Push_To_Date);
    ELSE
      EDW_COLLECTION_UTIL.Wrapup(
	TRUE,
	g_rows_collected,
	NULL,
	ISC_EDW_BOOKINGS_F_C.G_Push_From_Date,
	ISC_EDW_BOOKINGS_F_C.G_Push_To_Date);
  END IF;

  COMMIT;


      -- --------------------------------------------------
      -- END OF Collection , Developer Customizable Section
      -- --------------------------------------------------

EXCEPTION

  WHEN L_FAILURE THEN
    ROLLBACK;
    EDW_LOG.Put_Line(g_errbuf);
    retcode := -1;
    EDW_COLLECTION_UTIL.Wrapup(
	FALSE,
	g_rows_collected,
	NULL,
	ISC_EDW_BOOKINGS_F_C.G_Push_From_Date,
	ISC_EDW_BOOKINGS_F_C.G_Push_To_Date);
  WHEN OTHERS THEN
    ROLLBACK;
    g_errbuf  := sqlerrm ||' - '|| sqlcode;
    EDW_LOG.Put_Line('Other errors : '|| g_errbuf);
    retcode := -1;
    EDW_COLLECTION_UTIL.Wrapup(
	FALSE,
	g_rows_collected,
	NULL,
	ISC_EDW_BOOKINGS_F_C.G_Push_From_Date,
	ISC_EDW_BOOKINGS_F_C.G_Push_To_Date);
END;
END ISC_EDW_BOOKINGS_F_C;

/
