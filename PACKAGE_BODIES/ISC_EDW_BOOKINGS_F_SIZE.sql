--------------------------------------------------------
--  DDL for Package Body ISC_EDW_BOOKINGS_F_SIZE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_EDW_BOOKINGS_F_SIZE" AS
/* $Header: ISCSGF0B.pls 120.2 2006/03/31 09:54:51 abhdixi noship $ */

   /* ------------------------------------------
      PROCEDURE NAME   : cnt_rows
      INPUT PARAMETERS : p_from_date, p_to_date
      OUTPUT PARAMETERS: p_num_rows
      DESCRIPTION      : Count the number of rows
      ------------------------------------------- */

   PROCEDURE cnt_rows(p_from_date DATE,
                      p_to_date DATE,
                      p_num_rows OUT NOCOPY NUMBER) IS
   l_num_rows1 		NUMBER;
   l_num_rows2 		NUMBER;
   l_num_rows3 		NUMBER;
   l_num_rows4		NUMBER;

   BEGIN

      SELECT count(*)
        INTO l_num_rows1
        FROM OE_ORDER_LINES_ALL		l,
             OE_ORDER_HEADERS_ALL	h
       WHERE l.header_id = h.header_id
         AND h.booked_date IS NOT NULL
	 AND (h.last_update_date between p_from_date and p_to_date
     	      OR l.last_update_date between p_from_date and p_to_date);

      SELECT count(*)
	INTO l_num_rows2
        FROM RA_CUSTOMER_TRX_LINES_ALL	ra,
             OE_ORDER_HEADERS_ALL	h,
             OE_ORDER_LINES_ALL		l
       WHERE l.line_id = ra.interface_line_attribute6
	 AND l.header_id = h.header_id
         AND h.booked_date IS NOT NULL
         AND ra.interface_line_context = 'ORDER ENTRY'
         AND (ra.last_update_date between p_from_date and p_to_date
              OR l.last_update_date between p_from_date and p_to_date
	      OR h.last_update_date between p_from_date and p_to_date);

      SELECT count(*)
 	INTO l_num_rows3
        FROM MTL_RESERVATIONS		mtl,
             OE_ORDER_HEADERS_ALL	h,
             OE_ORDER_LINES_ALL	l
       WHERE l.line_id = mtl.demand_source_line_id
	 AND l.header_id = h.header_id
         AND h.booked_date IS NOT NULL
       	 AND mtl.reservation_quantity is not null
       	 AND mtl.reservation_quantity <> 0
	 AND (mtl.last_update_date between p_from_date and p_to_date
     	      OR l.last_update_date between p_from_date and p_to_date
	      OR h.last_update_date between p_from_date and p_to_date);

      SELECT count(*)
 	INTO l_num_rows4
        FROM oe_order_lines_history 	hist,
             OE_ORDER_HEADERS_ALL	h,
             OE_ORDER_LINES_ALL		l
       WHERE hist.line_id = l.line_id
	 AND l.header_id = h.header_id
         AND h.booked_date IS NOT NULL
         AND hist.hist_type_code = 'CANCELLATION'
	 AND (hist.last_update_date between p_from_date and p_to_date
     	      OR l.last_update_date between p_from_date and p_to_date
	      OR h.last_update_date between p_from_date and p_to_date);

   p_num_rows := l_num_rows1 + l_num_rows2 + l_num_rows3 + l_num_rows4;

   Exception When others then
      rollback;

   END;


   /* ------------------------------------------
      PROCEDURE NAME   : est_row_len
      INPUT PARAMETERS : p_from_date, p_to_date
      OUTPUT PARAMETERS: p_avg_row_len
      DESCRIPTION      : Estimate input_f
      ------------------------------------------ */

   PROCEDURE est_row_len(p_from_date DATE,
                         p_to_date DATE,
                         p_avg_row_len OUT NOCOPY NUMBER) IS

    x_date		number := 7;
    x_total		number := 0;
    x_AGREEMENT_ID			NUMBER;
    x_AGREEMENT_TYPE_FK			NUMBER;
    x_BILL_TO_CUST_FK			NUMBER;
    x_BILL_TO_LOC_FK			NUMBER;
    x_BOOKED_DATE			NUMBER;
    x_BOOKINGS_PK			NUMBER;
    -- Bug 5066532 : Removing BIM object dependency
    -- x_CAMPAIGN_ACTL_FK		NUMBER;
    -- x_CAMPAIGN_INIT_FK		NUMBER;
    x_CAMPAIGN_STATUS_ACTL_FK		NUMBER;
    x_CAMPAIGN_STATUS_INIT_FK		NUMBER;
    x_CANCEL_REASON_FK			NUMBER;
    x_CONVERSION_DATE			NUMBER;
    x_CONVERSION_RATE			NUMBER;
    x_CONVERSION_TYPE			NUMBER;
    x_CURRENCY_TRN_FK			NUMBER;
    x_CUSTOMER_FK			NUMBER;
    x_CUST_PO_NUMBER			NUMBER;
    x_DATE_BOOKED_FK			NUMBER;
    x_DATE_FULFILLED			NUMBER;
    x_DATE_LATEST_PICK			NUMBER;
    x_DATE_LATEST_SHIP			NUMBER;
    x_DATE_PROMISED_FK			NUMBER;
    x_DATE_REQUESTED_FK			NUMBER;
    x_DATE_SCHEDULED_FK			NUMBER;
    x_DEMAND_CLASS_FK			NUMBER;
    -- Bug 5066532 : Removing BIM object dependency
    -- x_EVENT_OFFER_ACTL_FK		NUMBER;
    -- x_EVENT_OFFER_INIT_FK		NUMBER;
    -- x_EVENT_OFFER_REG_FK		NUMBER;
    x_FULFILLMENT_FLAG			NUMBER;
    x_HEADER_ID				NUMBER;
    x_INV_ORG_FK			NUMBER;
    x_ITEM_ORG_FK			NUMBER;
    x_ITEM_TYPE_CODE			NUMBER;
    x_LAST_UPDATE_DATE			NUMBER;
    x_LINE_ID				NUMBER;
    x_MARKET_SEGMENT_FK			NUMBER;
    -- Bug 5066532 : Removing BIM object dependency
    -- x_MEDCHN_ACTL_FK			NUMBER;
    -- x_MEDCHN_INIT_FK			NUMBER;
    x_OFFER_HDR_FK			NUMBER;
    x_OFFER_LINE_FK			NUMBER;
    x_OPERATING_UNIT_FK			NUMBER;
    x_ORDER_CATEGORY_FK			NUMBER;
    x_ORDER_NUMBER			NUMBER;
    x_ORDER_SOURCE_FK			NUMBER;
    x_ORDER_TYPE_FK			NUMBER;
    x_ORDERED_DATE			NUMBER;
    x_PRICE_LIST_ID			NUMBER;
    x_PROMISED_DATE			NUMBER;
    x_QTY_CANCELLED			NUMBER;
    x_QTY_FULFILLED			NUMBER;
    x_QTY_INVOICED			NUMBER;
    x_QTY_ORDERED			NUMBER;
    x_QTY_RESERVED			NUMBER;
    x_QTY_RETURNED			NUMBER;
    x_QTY_SHIPPED			NUMBER;
    x_REQUESTED_DATE			NUMBER;
    x_RETURN_REASON_FK			NUMBER;
    x_SALES_CHANNEL_FK			NUMBER;
    x_SALES_PERSON_FK			NUMBER;
    x_SCHEDULED_DATE			NUMBER;
    x_SET_OF_BOOKS_FK			NUMBER;
    x_SHIPPABLE_FLAG			NUMBER;
    x_SHIP_TO_CUST_FK			NUMBER;
    x_SHIP_TO_LOC_FK			NUMBER;
    x_SOURCE_LIST_FK			NUMBER;
    x_TARGET_SEGMENT_ACTL_FK		NUMBER;
    x_TARGET_SEGMENT_INIT_FK		NUMBER;
    x_TASK_FK				NUMBER;
    x_TOP_MODEL_FK			NUMBER;
    x_TOTAL_NET_ORDER_VALUE		NUMBER;
    x_UNIT_COST_G			NUMBER;
    x_UNIT_COST_T			NUMBER;
    x_UNIT_LIST_PRC_G			NUMBER;
    x_UNIT_LIST_PRC_T			NUMBER;
    x_UNIT_SELL_PRC_G			NUMBER;
    x_UNIT_SELL_PRC_T			NUMBER;
    x_UOM_UOM_FK			NUMBER;

      CURSOR c_1 IS
         SELECT nvl(avg(nvl(vsize(agreement_id),0)),0),
		nvl(avg(nvl(vsize(line_id),0)),0),
		nvl(avg(nvl(vsize(sold_to_org_id),0)),0),
  		nvl(avg(nvl(vsize(cust_po_number),0)),0),
  		nvl(avg(nvl(vsize(demand_class_code),0)),0),
  		nvl(avg(nvl(vsize(fulfilled_flag),0)),0),
  		nvl(avg(nvl(vsize(ship_from_org_id),0)),0),
  		nvl(avg(nvl(vsize(inventory_item_id),0)),0) + nvl(avg(nvl(vsize(ship_from_org_id),0)),0),
  		nvl(avg(nvl(vsize(org_id),0)),0),
  		nvl(avg(nvl(vsize(line_category_code),0)),0),
  		nvl(avg(nvl(vsize(price_list_id),0)),0),
  		nvl(avg(nvl(vsize(cancelled_quantity),0)),0),
  		nvl(avg(nvl(vsize(fulfilled_quantity),0)),0),
  		nvl(avg(nvl(vsize(ordered_quantity),0)),0),
  		nvl(avg(nvl(vsize(shipped_quantity),0)),0),
		nvl(avg(nvl(vsize(return_reason_code),0)),0),
		nvl(avg(nvl(vsize(salesrep_id),0)),0) + nvl(avg(nvl(vsize(org_id),0)),0),
		nvl(avg(nvl(vsize(shippable_flag),0)),0),
		nvl(avg(nvl(vsize(ship_to_org_id),0)),0),
		nvl(avg(nvl(vsize(task_id),0)),0),
		nvl(avg(nvl(vsize(unit_list_price),0)),0),
		nvl(avg(nvl(vsize(unit_selling_price),0)),0),
		nvl(avg(nvl(vsize(fulfillment_date),0)),0),
		nvl(avg(nvl(vsize(actual_shipment_date),0)),0),
		nvl(avg(nvl(vsize(last_update_date),0)),0),
		nvl(avg(nvl(vsize(promise_date),0)),0),
		nvl(avg(nvl(vsize(request_date),0)),0),
		nvl(avg(nvl(vsize(schedule_ship_date),0)),0),
		nvl(avg(nvl(vsize(item_type_code),0)),0)
	 FROM OE_ORDER_LINES_ALL
         WHERE last_update_date BETWEEN p_from_date AND p_to_date;

      CURSOR c_2 IS
	 SELECT nvl(avg(nvl(vsize(agreement_type_code),0)),0)
	 FROM OE_AGREEMENTS_B;

      CURSOR c_3 IS
	 SELECT nvl(avg(nvl(vsize(invoice_to_org_id),0)),0),
		nvl(avg(nvl(vsize(conversion_type_code),0)),0),
		nvl(avg(nvl(vsize(transactional_curr_code),0)),0),
		nvl(avg(nvl(vsize(header_id),0)),0),
		nvl(avg(nvl(vsize(order_number),0)),0),
		nvl(avg(nvl(vsize(sales_channel_code),0)),0),
                nvl(avg(nvl(vsize(sold_to_org_id),0)),0),
                nvl(avg(nvl(vsize(booked_date),0)),0),
                nvl(avg(nvl(vsize(ordered_date),0)),0)
	 FROM OE_ORDER_HEADERS_ALL;

    -- Bug 5066532 : Removing BIM object dependency
    -- CURSOR c_4 IS
    --   SELECT nvl(avg(nvl(vsize(campaign_fk),0)),0),
    --		nvl(avg(nvl(vsize(event_fk),0)),0),
    --		nvl(avg(nvl(vsize(media_channel_fk),0)),0)
    --	 FROM EDW_BIM_SOURCE_CODE_DETAILS;

      CURSOR c_5 IS
	 SELECT nvl(avg(nvl(vsize(conversion_rate),0)),0)
	 FROM GL_DAILY_RATES;

      CURSOR c_6 IS
	 SELECT nvl(avg(nvl(vsize(period_set_name),0)),0) + nvl(avg(nvl(vsize(accounted_period_type),0)),0)
	 FROM GL_SETS_OF_BOOKS;

      CURSOR c_7 IS
	 SELECT nvl(avg(nvl(vsize(cell_code),0)),0)
	 FROM ams_cells_all_b;

      CURSOR c_8 IS
	 SELECT nvl(avg(nvl(vsize(activity_offer_id),0)),0)
	 FROM ams_act_offers;

      CURSOR c_9 IS
	 SELECT nvl(avg(nvl(vsize(name),0)),0)
	 FROM OE_ORDER_SOURCES;

      CURSOR c_10 IS
	 SELECT nvl(avg(nvl(vsize(name),0)),0)
	 FROM OE_TRANSACTION_TYPES_TL;

      CURSOR c_11 IS
	 SELECT nvl(avg(nvl(vsize(quantity_invoiced),0)),0)
	 FROM RA_CUSTOMER_TRX_LINES_ALL;

      CURSOR c_12 IS
	 SELECT nvl(avg(nvl(vsize(reservation_quantity),0)),0)
	 FROM MTL_RESERVATIONS;

      CURSOR c_13 IS
	 SELECT nvl(avg(nvl(vsize(set_of_books_id),0)),0)
	 FROM FINANCIALS_SYSTEM_PARAMS_ALL;

      CURSOR c_14 IS
	 SELECT nvl(avg(nvl(vsize(cell_code),0)),0)
	 FROM ams_list_entries;

      CURSOR c_15 IS
	 SELECT nvl(avg(nvl(vsize(item_cost),0)),0)
	 FROM cst_item_costs;

      CURSOR c_16 IS
	 SELECT nvl(avg(nvl(vsize(UOM_EDW_BASE_UOM),0)),0)
	 FROM EDW_MTL_LOCAL_UOM_M;

      CURSOR c_17 IS
	 SELECT nvl(avg(nvl(vsize(user_status_id),0)),0)
	 FROM ams_campaigns_all_b;

   BEGIN

      OPEN c_1;
        FETCH c_1 INTO x_AGREEMENT_ID, x_BOOKINGS_PK, x_CUSTOMER_FK,
		  x_CUST_PO_NUMBER, x_DEMAND_CLASS_FK, x_FULFILLMENT_FLAG,
		  x_INV_ORG_FK, x_ITEM_ORG_FK, x_OPERATING_UNIT_FK,
		  x_ORDER_CATEGORY_FK, x_PRICE_LIST_ID, x_QTY_CANCELLED,
		  x_QTY_FULFILLED, x_QTY_ORDERED, x_QTY_SHIPPED,
		  x_RETURN_REASON_FK, x_SALES_PERSON_FK, x_SHIPPABLE_FLAG,
		  x_SHIP_TO_CUST_FK, x_TASK_FK, x_UNIT_LIST_PRC_T,
		  x_UNIT_SELL_PRC_T, x_DATE_FULFILLED, x_DATE_LATEST_SHIP,
		  x_LAST_UPDATE_DATE, x_PROMISED_DATE, x_REQUESTED_DATE,
		  x_SCHEDULED_DATE, x_ITEM_TYPE_CODE;
      CLOSE c_1;

      x_LINE_ID := x_BOOKINGS_PK;
      x_SHIP_TO_LOC_FK := x_SHIP_TO_CUST_FK;
      x_QTY_RETURNED := x_QTY_ORDERED;
      x_TOP_MODEL_FK := x_ITEM_ORG_FK;
      x_UNIT_LIST_PRC_G := x_UNIT_LIST_PRC_T * 2;
      x_UNIT_SELL_PRC_G := x_UNIT_SELL_PRC_T * 2;

      x_total := 3 + x_total + ceil(x_AGREEMENT_ID + 1) + ceil(x_BOOKINGS_PK + 1) +
	   	 ceil(x_CUSTOMER_FK + 1) + ceil(x_CUST_PO_NUMBER + 1) +
		 ceil(x_DEMAND_CLASS_FK + 1) + ceil(x_FULFILLMENT_FLAG + 1) +
		 ceil(x_INV_ORG_FK + 1) + ceil(x_ITEM_ORG_FK + 1) +
		 ceil(x_OPERATING_UNIT_FK + 1) + ceil(x_ORDER_CATEGORY_FK + 1) +
		 ceil(x_PRICE_LIST_ID + 1) + ceil(x_QTY_CANCELLED + 1) +
		 ceil(x_QTY_FULFILLED + 1) + ceil(x_QTY_ORDERED + 1) +
		 ceil(x_QTY_SHIPPED + 1) + ceil(x_RETURN_REASON_FK + 1) +
		 ceil(x_SALES_PERSON_FK + 1) + ceil(x_SHIPPABLE_FLAG + 1) +
		 ceil(x_SHIP_TO_CUST_FK + 1) + ceil(x_TASK_FK + 1) +
		 ceil(x_UNIT_LIST_PRC_T + 1) + ceil(x_UNIT_SELL_PRC_T + 1) +
		 ceil(x_LINE_ID + 1) + ceil(x_SHIP_TO_LOC_FK + 1) +
		 ceil(x_DATE_FULFILLED + 1) + ceil(x_DATE_LATEST_SHIP + 1) +
		 ceil(x_LAST_UPDATE_DATE + 1) + ceil(x_QTY_RETURNED + 1) +
		 ceil(x_TOP_MODEL_FK + 1) + ceil(x_UNIT_LIST_PRC_G + 1) +
		 ceil(x_UNIT_SELL_PRC_G + 1) + ceil(x_PROMISED_DATE + 1) +
		 ceil(x_REQUESTED_DATE + 1) + ceil(x_SCHEDULED_DATE + 1) +
		 ceil(x_ITEM_TYPE_CODE + 1);

      OPEN c_2;
        FETCH c_2 INTO x_AGREEMENT_TYPE_FK;
      CLOSE c_2;

         x_total := x_total + ceil(x_AGREEMENT_TYPE_FK + 1);

      OPEN c_3;
        FETCH c_3 INTO x_BILL_TO_CUST_FK, x_CONVERSION_TYPE, x_CURRENCY_TRN_FK,
		       x_HEADER_ID, x_ORDER_NUMBER, x_SALES_CHANNEL_FK,
		       x_SOURCE_LIST_FK, x_BOOKED_DATE, x_ORDERED_DATE;
      CLOSE c_3;

      x_BILL_TO_LOC_FK := x_BILL_TO_CUST_FK;
      x_CONVERSION_DATE := x_date;

      x_total := x_total + ceil(x_BILL_TO_CUST_FK + 1) + ceil(x_CONVERSION_TYPE + 1) +
		 ceil(x_CURRENCY_TRN_FK + 1) + ceil(x_HEADER_ID + 1) +
		 ceil(x_ORDER_NUMBER + 1) + ceil(x_SALES_CHANNEL_FK + 1) +
		 ceil(x_BILL_TO_LOC_FK + 1) + ceil(x_CONVERSION_DATE + 1) +
		 ceil(x_SOURCE_LIST_FK + 1) + ceil(x_BOOKED_DATE + 1) +
		 ceil(x_ORDERED_DATE + 1);

    -- Bug 5066532 : Removing BIM object dependency
    --  OPEN c_4;
    --    FETCH c_4 INTO x_CAMPAIGN_ACTL_FK, x_EVENT_OFFER_ACTL_FK, x_MEDCHN_ACTL_FK;
    --  CLOSE c_4;

    --  x_CAMPAIGN_INIT_FK := x_CAMPAIGN_ACTL_FK;
    --  x_EVENT_OFFER_INIT_FK := x_EVENT_OFFER_ACTL_FK;
    --  x_EVENT_OFFER_REG_FK := x_EVENT_OFFER_ACTL_FK;
    --  x_MEDCHN_INIT_FK := x_MEDCHN_ACTL_FK;

    --  x_total := x_total + ceil(x_CAMPAIGN_ACTL_FK + 1) + ceil(x_EVENT_OFFER_ACTL_FK + 1) +
    --		 ceil(x_MEDCHN_ACTL_FK + 1) + ceil(x_CAMPAIGN_INIT_FK + 1) +
    --		 ceil(x_EVENT_OFFER_INIT_FK + 1) + ceil(x_EVENT_OFFER_REG_FK + 1) +
    --		 ceil(x_MEDCHN_INIT_FK + 1);

      OPEN c_5;
        FETCH c_5 INTO x_CONVERSION_RATE;
      CLOSE c_5;

      x_TOTAL_NET_ORDER_VALUE := x_UNIT_SELL_PRC_T + x_QTY_ORDERED + x_CONVERSION_RATE;
      x_total := x_total + ceil(x_CONVERSION_RATE + 1) + ceil(x_TOTAL_NET_ORDER_VALUE + 1);

      OPEN c_6;
        FETCH c_6 INTO x_DATE_BOOKED_FK;
      CLOSE c_6;

      x_DATE_LATEST_PICK := x_date;
      x_DATE_PROMISED_FK := x_DATE_BOOKED_FK;
      x_DATE_REQUESTED_FK := x_DATE_BOOKED_FK;
      x_DATE_SCHEDULED_FK := x_DATE_BOOKED_FK;

      x_total := x_total + ceil(x_DATE_BOOKED_FK + 1) + ceil(x_DATE_LATEST_PICK + 1) +
		 ceil(x_DATE_PROMISED_FK + 1) + ceil(x_DATE_REQUESTED_FK + 1) +
		 ceil(x_DATE_SCHEDULED_FK + 1);

      OPEN c_7;
        FETCH c_7 INTO x_MARKET_SEGMENT_FK;
      CLOSE c_7;

      x_total := x_total + ceil(x_MARKET_SEGMENT_FK + 1);

      OPEN c_8;
        FETCH c_8 INTO x_OFFER_HDR_FK;
      CLOSE c_8;

      x_OFFER_LINE_FK := x_OFFER_HDR_FK;

      x_total := x_total + ceil(x_OFFER_HDR_FK + 1) + ceil(x_OFFER_LINE_FK + 1);

      OPEN c_9;
        FETCH c_9 INTO x_ORDER_SOURCE_FK;
      CLOSE c_9;

      x_total := x_total + ceil(x_ORDER_SOURCE_FK + 1);

      OPEN c_10;
        FETCH c_10 INTO x_ORDER_TYPE_FK;
      CLOSE c_10;

      x_total := x_total + ceil(x_ORDER_TYPE_FK + 1);

      OPEN c_11;
        FETCH c_11 INTO x_QTY_INVOICED;
      CLOSE c_11;

      x_total := x_total + ceil(x_QTY_INVOICED + 1);

      OPEN c_12;
        FETCH c_12 INTO x_QTY_RESERVED;
      CLOSE c_12;

      x_total := x_total + ceil(x_QTY_RESERVED + 1);

      OPEN c_13;
        FETCH c_13 INTO x_SET_OF_BOOKS_FK;
      CLOSE c_13;

      x_total := x_total + ceil(x_SET_OF_BOOKS_FK + 1);

      OPEN c_14;
        FETCH c_14 INTO x_TARGET_SEGMENT_ACTL_FK;
      CLOSE c_14;

      x_TARGET_SEGMENT_INIT_FK := x_TARGET_SEGMENT_ACTL_FK;

      x_total := x_total + ceil(x_TARGET_SEGMENT_ACTL_FK + 1) + ceil(x_TARGET_SEGMENT_INIT_FK + 1);

      OPEN c_15;
        FETCH c_15 INTO x_UNIT_COST_G;
      CLOSE c_15;

      x_UNIT_COST_T := x_UNIT_COST_G;

      x_total := x_total + ceil(x_UNIT_COST_G + 1) + ceil(x_UNIT_COST_T + 1);

      OPEN c_16;
        FETCH c_16 INTO x_UOM_UOM_FK;
      CLOSE c_16;

      x_total := x_total + ceil(x_UOM_UOM_FK + 1);

      OPEN c_17;
        FETCH c_17 INTO x_CAMPAIGN_STATUS_ACTL_FK;
      CLOSE c_17;

      x_CAMPAIGN_STATUS_INIT_FK := x_CAMPAIGN_STATUS_ACTL_FK;

      x_total := x_total + ceil(x_CAMPAIGN_STATUS_ACTL_FK + 1) + ceil(x_CAMPAIGN_STATUS_INIT_FK + 1);

      p_avg_row_len := x_total;

   Exception When others then
      rollback;

   END;

END ISC_EDW_BOOKINGS_F_SIZE;

/
