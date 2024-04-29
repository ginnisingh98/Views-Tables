--------------------------------------------------------
--  DDL for Package Body ISC_EDW_BACKLOGS_F_SIZE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_EDW_BACKLOGS_F_SIZE" AS
/* $Header: ISCSGF1B.pls 115.3 2002/12/19 00:46:33 scheung ship $ */

   /* ------------------------------------------
      PROCEDURE NAME   : cnt_rows
      INPUT PARAMETERS : p_from_date, p_to_date
      OUTPUT PARAMETERS: p_num_rows
      DESCRIPTION      : Count the number of rows
      ------------------------------------------- */

   PROCEDURE cnt_rows(p_from_date DATE,
                      p_to_date DATE,
                      p_num_rows OUT NOCOPY NUMBER) IS

   BEGIN

      SELECT count(distinct backlogs_pk)
        INTO p_num_rows
        FROM (SELECT trunc(sysdate,'DD')
      		     ||'-'|| inst.instance_code
		     ||'-'|| l.order_quantity_uom
		     ||'-'|| nvl( pl.inventory_item_id,l.inventory_item_id)
		     ||'-'|| decode( pl.ship_from_org_id, NULL,
		     		pl.inventory_item_id||'-'||pl.org_id,
		     		pl.inventory_item_id||'-'||pl.ship_from_org_id)
		     ||'-'|| decode(	l.ship_from_org_id, NULL,
		     		l.inventory_item_id||'-'||l.org_id,
		     		l.inventory_item_id||'-'||l.ship_from_org_id)
		     ||'-'|| nvl( l.ship_from_org_id,h.ship_from_org_id)
		     ||'-'|| l.org_id
		     ||'-'|| l.sold_to_org_id
		     ||'-'|| h.sales_channel_code
		     ||'-'|| l.salesrep_id
		     ||'-'|| l.task_id
		     ||'-'|| h.invoice_to_org_id
		     ||'-'|| l.ship_to_org_id
		     ||'-'|| nvl( l.demand_class_code,h.demand_class_code)
		     ||'-'|| h.transactional_curr_code
		     ||'-'|| l.line_category_code
		     ||'-'|| ot.transaction_type_id
		     ||'-'|| nvl( os_2.order_source_id, os_1.order_source_id)
		     ||'-'|| fspa.set_of_books_id			BACKLOGS_PK
                FROM edw_local_instance 		inst,
		     oe_transaction_types_tl		ot,
		     oe_order_lines_all			pl,
		     oe_order_headers_all 		h,
		     oe_order_lines_all			l,
		     oe_order_sources			os_1,
	       	     oe_order_sources			os_2,
		     mtl_system_items_b                 p_mtl,
      		     mtl_system_items_b			mtl,
      		     financials_system_params_all	fspa,
      		     gl_sets_of_books			gl
      	       WHERE (h.last_update_date between p_from_date and p_to_date
		      OR l.last_update_date between p_from_date and p_to_date)
      	         AND h.open_flag = 'Y'
     	         AND h.booked_flag = 'Y'
	         AND nvl(l.ordered_quantity,0) > 0
     		 AND nvl(l.source_document_type_id,0) <> 10
		 AND l.line_category_code =  ('ORDER')
		 AND l.header_id = h.header_id
		 AND h.header_id = pl.header_id
		 AND nvl(l.top_model_line_id, l.line_id) = pl.line_id
		 AND h.order_type_id = ot.transaction_type_id
		 AND ot.language = userenv('LANG')
		 AND l.order_source_id = os_1.order_source_id (+)
		 AND l.source_document_type_id = os_2.order_source_id (+)
		 AND l.org_id = fspa.org_id
		 AND fspa.set_of_books_id = gl.set_of_books_id
		 AND l.inventory_item_id = mtl.inventory_item_id(+)
		 AND l.ship_from_org_id = mtl.organization_id(+)
		 AND pl.inventory_item_id = p_mtl.inventory_item_id(+)
		 AND pl.ship_from_org_id = p_mtl.organization_id(+));

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
    x_l_inv		number := 0;
    x_salesrep_id	number := 0;
    x_mtl_inv		number := 0;
    x_mtl_org_id	number := 0;
    x_h_salesrep_id	number := 0;
    x_cate_code		number := 0;
    x_set_of_books_id	number := 0;
    x_BACKLOGS_PK			NUMBER;
    x_BASE_UOM_FK			NUMBER;
    x_BILL_TO_CUST_FK			NUMBER;
    x_BILL_TO_LOCATION_FK		NUMBER;
    x_CUSTOMER_FK			NUMBER;
    x_DATE_BALANCE_FK			NUMBER;
    x_DEMAND_CLASS_FK			NUMBER;
    x_GL_BOOK_FK			NUMBER;
    x_INV_ORG_FK			NUMBER;
    x_ITEM_ORG_FK			NUMBER;
    x_OPERATING_UNIT_FK			NUMBER;
    x_ORDER_CATEGORY_FK			NUMBER;
    x_ORDER_SOURCE_FK			NUMBER;
    x_ORDER_TYPE_FK			NUMBER;
    x_SALES_CHANNEL_FK			NUMBER;
    x_SALES_PERSON_FK			NUMBER;
    x_SHIP_TO_CUST_FK			NUMBER;
    x_SHIP_TO_LOCATION_FK		NUMBER;
    x_TASK_FK				NUMBER;
    x_TOP_MODEL_ITEM_FK			NUMBER;
    x_TRX_CURRENCY_FK			NUMBER;
    x_BILL_BKLG_REV_T			NUMBER;

      CURSOR c_1 IS
         SELECT nvl(avg(nvl(vsize(sold_to_org_id),0)),0),
		nvl(avg(nvl(vsize(demand_class_code),0)),0),
		nvl(avg(nvl(vsize(ship_from_org_id),0)),0),
		nvl(avg(nvl(vsize(inventory_item_id),0)),0),
		nvl(avg(nvl(vsize(org_id),0)),0),
		nvl(avg(nvl(vsize(line_category_code),0)),0),
		nvl(avg(nvl(vsize(salesrep_id),0)),0),
		nvl(avg(nvl(vsize(ship_to_org_id),0)),0),
		nvl(avg(nvl(vsize(task_id),0)),0)
	 FROM OE_ORDER_LINES_ALL
         WHERE last_update_date BETWEEN p_from_date AND p_to_date;

      CURSOR c_2 IS
	 SELECT nvl(avg(nvl(vsize(UOM_EDW_BASE_UOM),0)),0)
	 FROM EDW_MTL_LOCAL_UOM_M;

      CURSOR c_3 IS
	 SELECT nvl(avg(nvl(vsize(invoice_to_org_id),0)),0),
		nvl(avg(nvl(vsize(sales_channel_code),0)),0),
		nvl(avg(nvl(vsize(transactional_curr_code),0)),0),
		nvl(avg(nvl(vsize(salesrep_id),0)),0),
		nvl(avg(nvl(vsize(order_category_code),0)),0)
	 FROM OE_ORDER_HEADERS_ALL
         WHERE last_update_date BETWEEN p_from_date AND p_to_date;

      CURSOR c_4 IS
	 SELECT nvl(avg(nvl(vsize(party_site_id),0)),0)
	 FROM HZ_CUST_ACCT_SITES_ALL;

      CURSOR c_5 IS
	 SELECT nvl(avg(nvl(vsize(period_set_name),0)),0) + nvl(avg(nvl(vsize(accounted_period_type),0)),0)
	 FROM GL_SETS_OF_BOOKS;

      CURSOR c_6 IS
	 SELECT nvl(avg(nvl(vsize(name),0)),0)
	 FROM OE_ORDER_SOURCES;

      CURSOR c_7 IS
	 SELECT nvl(avg(nvl(vsize(name),0)),0)
	 FROM OE_TRANSACTION_TYPES_TL;

      CURSOR c_8 IS
	 SELECT nvl(avg(nvl(vsize(to_char(set_of_books_id)),0)),0),
		nvl(avg(nvl(vsize(set_of_books_id),0)),0)
	 FROM FINANCIALS_SYSTEM_PARAMS_ALL;

      CURSOR c_9 IS
	 SELECT nvl(avg(nvl(vsize(inventory_item_id),0)),0),
		nvl(avg(nvl(vsize(organization_id),0)),0)
	 FROM mtl_system_items_b;

      CURSOR c_10 IS
	 SELECT nvl(avg(nvl(vsize(nvl(l.unit_selling_price,0)
			      *(nvl(l.ordered_quantity,0)-nvl(l.invoiced_quantity,0))
			      *nvl(EDW_CONVERSION_RATE,0)),0)),0)
	   FROM oe_order_lines_all l,
		OPI_EDW_LOCAL_UOM_CONV_F;

   BEGIN

      OPEN c_1;
        FETCH c_1 INTO x_CUSTOMER_FK, x_DEMAND_CLASS_FK, x_INV_ORG_FK,
		       x_l_inv, x_OPERATING_UNIT_FK, x_ORDER_CATEGORY_FK,
		       x_salesrep_id, x_SHIP_TO_CUST_FK, x_TASK_FK;
      CLOSE c_1;

      x_ITEM_ORG_FK := x_INV_ORG_FK + x_l_inv;
      x_SALES_PERSON_FK := x_salesrep_id + x_OPERATING_UNIT_FK;
      x_TOP_MODEL_ITEM_FK := x_ITEM_ORG_FK;

      x_total := 3 + x_total + ceil(x_CUSTOMER_FK + 1) + ceil(x_DEMAND_CLASS_FK + 1) +
		 ceil(x_INV_ORG_FK + 1) + ceil(x_ITEM_ORG_FK + 1) +
		 ceil(x_OPERATING_UNIT_FK + 1)  + ceil(x_ORDER_CATEGORY_FK + 1) +
		 ceil(x_SALES_PERSON_FK + 1) + ceil(x_SHIP_TO_CUST_FK + 1) +
		 ceil(x_TASK_FK + 1) + ceil(x_TOP_MODEL_ITEM_FK + 1);

      OPEN c_2;
        FETCH c_2 INTO x_BASE_UOM_FK;
      CLOSE c_2;

         x_total := x_total + ceil(x_BASE_UOM_FK+ 1);

      OPEN c_3;
        FETCH c_3 INTO x_BILL_TO_CUST_FK, x_SALES_CHANNEL_FK, x_TRX_CURRENCY_FK, x_h_salesrep_id, x_cate_code;
      CLOSE c_3;

      x_total := x_total + ceil(x_BILL_TO_CUST_FK + 1) + ceil(x_SALES_CHANNEL_FK + 1) +
		 ceil(x_TRX_CURRENCY_FK + 1);

      OPEN c_4;
        FETCH c_4 INTO x_BILL_TO_LOCATION_FK;
      CLOSE c_4;

      x_SHIP_TO_LOCATION_FK := x_BILL_TO_LOCATION_FK;
      x_total := x_total + ceil(x_BILL_TO_LOCATION_FK + 1) + ceil(x_SHIP_TO_LOCATION_FK + 1);

      OPEN c_5;
        FETCH c_5 INTO x_DATE_BALANCE_FK;
      CLOSE c_5;

      x_total := x_total + ceil(x_DATE_BALANCE_FK + 1);

      OPEN c_6;
        FETCH c_6 INTO x_ORDER_SOURCE_FK;
      CLOSE c_6;

      x_total := x_total + ceil(x_ORDER_SOURCE_FK + 1);

      OPEN c_7;
        FETCH c_7 INTO x_ORDER_TYPE_FK;
      CLOSE c_7;

      x_total := x_total + ceil(x_ORDER_TYPE_FK + 1);

      OPEN c_8;
        FETCH c_8 INTO x_GL_BOOK_FK, x_set_of_books_id;
      CLOSE c_8;

      x_total := x_total + ceil(x_GL_BOOK_FK + 1);

      OPEN c_9;
        FETCH c_9 INTO x_mtl_inv, x_mtl_org_id;
      CLOSE c_9;

      x_BACKLOGS_PK := x_l_inv + x_INV_ORG_FK + x_mtl_inv +  x_mtl_org_id +
		       x_OPERATING_UNIT_FK + x_CUSTOMER_FK + x_SALES_CHANNEL_FK +
		       x_h_salesrep_id + x_TASK_FK + x_INV_ORG_FK +
		       x_BILL_TO_CUST_FK + x_SHIP_TO_CUST_FK + x_DEMAND_CLASS_FK +
		       x_TRX_CURRENCY_FK + x_cate_code + x_ORDER_TYPE_FK +
		       x_ORDER_SOURCE_FK + x_set_of_books_id;

      x_total := x_total + ceil(x_BACKLOGS_PK + 1);

      OPEN c_10;
        FETCH c_10 INTO x_BILL_BKLG_REV_T;
      CLOSE c_10;

      x_total := x_total + 28 * ceil(x_BILL_BKLG_REV_T + 1);

      p_avg_row_len := x_total;

   Exception When others then
      rollback;

   END;

END ISC_EDW_BACKLOGS_F_SIZE;

/
