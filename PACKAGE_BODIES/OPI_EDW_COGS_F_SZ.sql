--------------------------------------------------------
--  DDL for Package Body OPI_EDW_COGS_F_SZ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_EDW_COGS_F_SZ" AS
/* $Header: OPIOCGZB.pls 120.3 2006/05/31 23:42:59 julzhang noship $*/

PROCEDURE cnt_rows(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER) IS

CURSOR c_cnt_rows IS
   select sum(cnt)
     from (SELECT  count(*) cnt
	   FROM
	   oe_order_headers_all 	h,
	   oe_order_lines_all 		pl,
	   oe_order_lines_all 		l,
	   wsh_delivery_details		wdd,
	   mtl_transaction_accounts   	mta,
	   mtl_material_transactions  	mmt
	   where mmt.transaction_source_type_id = 2
	   and   mta.transaction_source_type_id = 2
	   and   mmt.transaction_id = mta.transaction_id
	   and   mta.accounting_line_type in (2, 35)
	   and   pl.org_id = l.org_id
	   and   h.org_id = l.org_id
	   and   l.line_id = mmt.trx_source_line_id
	   and   l.line_category_code = 'ORDER'
	   and   pl.line_category_code = 'ORDER'
	   and   pl.line_id = nvl(l.top_model_line_id, l.line_id)
	   and   h.header_id = l.header_id
	   and   h.header_id = pl.header_id
	   and   wdd.delivery_detail_id = mmt.picking_line_id
	   AND   greatest(nvl(l.last_update_date, to_date('01/01/1000 00:00:00','MM/DD/YYYY hh24:mi:ss')),
			  nvl(pl.last_update_date, to_date('01/01/1000 00:00:00','MM/DD/YYYY hh24:mi:ss')),
			  nvl(mta.last_update_date,to_date('01/01/1000 00:00:00','MM/DD/YYYY hh24:mi:ss')),
			  nvl(mmt.last_update_date,to_date('01/01/1000 00:00:00','MM/DD/YYYY hh24:mi:ss')),
			  nvl(h.last_update_date, to_date('01/01/1000 00:00:00','MM/DD/YYYY hh24:mi:ss')))
                 BETWEEN p_from_date and p_to_date
         UNION ALL
           SELECT count(*) cnt
           from
	   oe_order_headers_all            h,
	   oe_order_lines_all              pl,
	   oe_order_lines_all              cl,
	   oe_order_lines_all              l,
	   mtl_transaction_accounts        mta,
	   mtl_material_transactions       mmt
	   where    mmt.transaction_source_type_id = 12
	   and   mta.transaction_source_type_id = 12
	   and   mmt.transaction_id = mta.transaction_id
	   and   mta.accounting_line_type in (2, 35)
	   and   h.org_id = l.org_id
	   and   l.line_id = mmt.trx_source_line_id
	   and   l.line_category_code = 'RETURN'
	   and   cl.line_id (+) = l.link_to_line_id
	   and   pl.line_id (+) = nvl(cl.top_model_line_id, cl.line_id)
	   and   h.header_id = l.header_id
	   AND greatest(nvl(l.last_update_date, to_date('01/01/1000 00:00:00','MM/DD/YYYY hh24:mi:ss')),
			nvl(pl.last_update_date, to_date('01/01/1000 00:00:00','MM/DD/YYYY hh24:mi:ss')),
			nvl(pl.last_update_date, to_date('01/01/1000 00:00:00','MM/DD/YYYY hh24:mi:ss')),
			nvl(mta.last_update_date, to_date('01/01/1000 00:00:00','MM/DD/YYYY hh24:mi:ss')),
			nvl(mmt.last_update_date, to_date('01/01/1000 00:00:00','MM/DD/YYYY hh24:mi:ss')),
			nvl(h.last_update_date, to_date('01/01/1000 00:00:00','MM/DD/YYYY hh24:mi:ss')))
	   BETWEEN p_from_date and p_to_date
         UNION ALL
	   SELECT count(*) cnt
	   FROM
	   oe_order_headers_all            h,
	   oe_order_lines_all              pl,     /*  parent line  */
	   oe_order_lines_all              l,      /*  child line   */
	   ra_customer_trx_lines_all       rcl,
	   ap_invoice_distributions_all    aid,
	   ap_invoices_all                 ai,
       mtl_material_transactions       mmt,
       mtl_parameters                  mp
	   WHERE ai.source = 'Intercompany'
	   AND aid.invoice_id = ai.invoice_id
	   and   aid.org_id = ai.org_id
	   and   rcl.CUSTOMER_TRX_LINE_ID  = to_number(aid.REFERENCE_1)
	   and   aid.line_type_lookup_code = 'ITEM'
	   and   rcl.interface_line_attribute6 = l.line_id
	   and   pl.line_id = nvl(l.top_model_line_id, l.line_id)
	   and   pl.org_id = l.org_id
	   and   h.org_id = l.org_id
	   and   h.header_id = l.header_id
	   and   h.header_id = pl.header_id
	   and   l.line_category_code  = 'ORDER'
	   and   pl.line_category_code = 'ORDER'
       and   rcl.interface_line_attribute7 = mmt.transaction_id
       and   nvl(mmt.logical_transaction,0) <> 1
       and   mmt.organization_id = mp.organization_id
       and   mp.process_enabled_flag <> 'Y'
	   AND greatest(
			nvl(aid.last_update_date, to_date('01/01/1000 00:00:00','MM/DD/YYYY hh24:mi:ss')),
			nvl(ai.last_update_date, to_date('01/01/1000 00:00:00','MM/DD/YYYY hh24:mi:ss')),
			nvl(l.last_update_date, to_date('01/01/1000 00:00:00','MM/DD/YYYY hh24:mi:ss')),
			nvl(pl.last_update_date, to_date('01/01/1000 00:00:00','MM/DD/YYYY hh24:mi:ss')),
			nvl(h.last_update_date, to_date('01/01/1000 00:00:00','MM/DD/YYYY hh24:mi:ss')))
	   BETWEEN p_from_date and p_to_date
	   );

BEGIN

  OPEN c_cnt_rows;
       FETCH c_cnt_rows INTO p_num_rows;
  CLOSE c_cnt_rows;

END;  -- procedure cnt_rows.


PROCEDURE est_row_len(p_from_date DATE,
                      p_to_date DATE,
                      p_avg_row_len OUT NOCOPY NUMBER) IS
 x_date                 number := 7;
 x_total                number := 0;
 x_constant             number := 6;

 CURSOR c_mmt IS
    SELECT  avg(nvl(vsize(transaction_id), 0)) txn_id,
      avg(nvl(vsize(transaction_uom), 0)) uom,
      avg(nvl(vsize(currency_code), 0))   currency,
      avg(nvl(vsize(subinventory_code), 0)) sub_code,
      avg(nvl(vsize(locator_id), 0))        locator,
      avg(nvl(vsize(primary_quantity), 0))  qty,
      avg(nvl(vsize(inventory_item_id), 0)) item_id
      FROM mtl_material_transactions
      WHERE last_update_date between p_from_date  and  p_to_date;

 CURSOR c_mta IS
    SELECT  avg(nvl(vsize(cost_element_id), 0)) cost_element_id,
      avg(nvl(vsize(transaction_value), 0))    transaction_value,
      avg(nvl(vsize(reference_account), 0))    account
      FROM mtl_transaction_accounts
      WHERE last_update_date between p_from_date  and  p_to_date;

 CURSOR c_line IS
    SELECT avg(nvl(vsize(line_id), 0))    line_id,
      avg(nvl(vsize(project_id), 0))      project_id,
      avg(nvl(vsize(task_id), 0))         task_id,
      avg(nvl(vsize(source_type_code), 0)) source_type_code,
      avg(nvl(vsize(marketing_source_code_id), 0)) marketing_source_code_id
      FROM oe_order_lines_all
      WHERE last_update_date between p_from_date  and  p_to_date;

 CURSOR c_header IS
    SELECT avg(nvl(vsize(sales_channel_code), 0))  channel_code,
      avg(nvl(vsize(salesrep_id), 0))              salesrep_id,
      avg(nvl(vsize(order_category_code), 0))      order_category_code,
      avg(nvl(vsize(header_id), 0))                header_id,
      avg(nvl(vsize(order_number), 0))             order_number
      FROM oe_order_headers_all
      WHERE last_update_date between p_from_date  and  p_to_date;

 CURSOR c_lookup IS
    select  avg(nvl(vsize(lookup_code_pk), 0))
      from edw_lookup_code_fkv;

 CURSOR c_wdd IS
    SELECT avg(nvl(vsize(lot_number), 0))	LOT,
      avg(nvl(vsize(revision), 0))              REVISION,
      avg(nvl(vsize(serial_number), 0)) 	SERIAL_NUMBER
      FROM wsh_delivery_details
      WHERE last_update_date between p_from_date  and  p_to_date;

 CURSOR c_wnd IS
    SELECT  avg(nvl(vsize(waybill), 0))    waybill
      FROM wsh_new_deliveries
      WHERE last_update_date between p_from_date  and  p_to_date;

 CURSOR c_instance IS
    SELECT
      avg(nvl(vsize(instance_code), 0))
      FROM	EDW_LOCAL_INSTANCE ;

 CURSOR c_org IS
    SELECT avg(nvl(Vsize(organization_id), 0)) org_id,
      avg(nvl(Vsize(organization_code), 0))    org_code
      FROM mtl_parameters;

 CURSOR c_act_usage IS
    SELECT AVG(Nvl(Vsize(primary_quantity), 0))
      FROM wip_transactions
      WHERE last_update_date between p_from_date  and  p_to_date;

 CURSOR c_avail IS
    SELECT   AVG(Nvl(Vsize(24*capacity_units), 0))
      FROM bom_department_resources
      WHERE last_update_date between p_from_date  and  p_to_date;

 CURSOR c_trx_date_fk IS
    SELECT AVG(Nvl(Vsize(EDW_TIME_PKG.CAL_DAY_FK(Sysdate, set_of_books_id) ),0))
      FROM gl_sets_of_books;

 CURSOR c_offer IS
    SELECT AVG(Nvl(Vsize(activity_offer_id), 0))
      FROM ams_act_offers
      WHERE last_update_date between p_from_date  and  p_to_date;

 CURSOR c_target IS
    SELECT AVG(Nvl(Vsize(cell_code), 0))
      FROM ams_list_entries
      WHERE last_update_date between p_from_date  and  p_to_date;

 CURSOR c_campaign IS
    SELECT AVG(Nvl(Vsize(user_status_id), 0))
      FROM ams_campaigns_all_b
      WHERE last_update_date between p_from_date  and  p_to_date;

 x_trx_date_fk NUMBER;
 x_instance_fk NUMBER;

 l_mmt       c_mmt%ROWTYPE;
 l_mta       c_mta%ROWTYPE;
 l_line      c_line%ROWTYPE;
 l_header    c_header%ROWTYPE;
 l_wdd       c_wdd%ROWTYPE;
 l_org       c_org%ROWTYPE;

 x_offer          NUMBER;
 x_target         NUMBER;
 x_campaign       NUMBER;
 x_wnd            NUMBER;
 x_lookup         NUMBER;

BEGIN
   OPEN c_instance;
   FETCH c_instance INTO  x_instance_fk;
   CLOSE c_instance;

   OPEN c_mmt;
   FETCH c_mmt INTO l_mmt;
   CLOSE c_mmt;

   OPEN c_mta;
   FETCH c_mta INTO l_mta;
   CLOSE c_mta;

   OPEN c_line;
   FETCH c_line INTO l_line;
   CLOSE c_line;

   OPEN c_header;
   FETCH c_header INTO l_header;
   CLOSE c_header;

   OPEN c_lookup;
   FETCH c_lookup INTO x_lookup;
   CLOSE c_lookup;

   OPEN c_wdd;
   FETCH c_wdd INTO l_wdd;
   CLOSE c_wdd;

   OPEN c_wnd;
   FETCH c_wnd INTO x_wnd;
   CLOSE c_wnd;

   OPEN c_org;
   FETCH c_org INTO l_org;
   CLOSE c_org;

   OPEN c_trx_date_fk;
   FETCH c_trx_date_fk INTO x_trx_date_fk;
   CLOSE c_trx_date_fk;

   OPEN c_offer;
   FETCH c_offer INTO x_offer;
   CLOSE c_offer;

   OPEN c_target;
   FETCH c_target INTO x_target;
   CLOSE c_target;

   OPEN c_campaign;
   FETCH c_campaign INTO x_campaign;
   CLOSE c_campaign;

   x_total := 3 + x_total
     -- COGS_PK
     + Ceil( l_mmt.txn_id + l_mta.cost_element_id + l_line.line_id
	     + x_instance_fk + 7 + 1)
     -- INSTANCE_FK
     + Ceil( x_instance_fk + 1)
     -- TOP_MODEL_ITEM_FK  ITEM_ORG_FK
     + 2 * Ceil( l_mmt.item_id + l_org.org_id + x_instance_fk + 7 +1)
     -- OPERATING_UNIT_FK  INV_ORG_FK
     + 2* Ceil( l_org.org_id + x_instance_fk + 1)
     -- CUSTOMER_FK
     + Ceil(l_org.org_id + x_instance_fk+ 16+ 1)
     -- SALES_CHANNEL_FK
     + Ceil( l_header.channel_code + x_instance_fk + 1 +1)
     -- PRIM_SALES_REP_FK
     + Ceil( l_header.salesrep_id + x_instance_fk + 16 +1);

   x_total := x_total
     -- BILL_TO_LOC_FK  SHIP_TO_LOC_FK
     + 2* Ceil(l_org.org_id + x_instance_fk + 12 + 1)
     -- PROJECT_FK
     + Ceil(l_line.project_id + x_instance_fk + 8 + 1)
     -- TASK_FK
     + Ceil(l_line.task_id + x_instance_fk + 1 + 1)
     -- BASE_UOM_FK
     + Ceil( l_mmt.uom + 1)
     -- TRX_CURRENCY_FK  BASE_CURRENCY_FK
     + Ceil( l_mmt.currency + 1)
     -- ORDER_CATEGORY_FK   ORDER_TYPE_FK  ORDER_SOURCE_FK
     + 3 *Ceil( x_lookup + 1)
     -- BILL_TO_SITE_FK   SHIP_TO_SITE_FK
     + 2* Ceil(l_org.org_id + x_instance_fk + 15 +1)
     -- MONTH_BOOKED_FK  DATE_BOOKED_FK  DATE_PROMISED_FK
     -- DATE_REQUESTED_FK  DATE_SCHEDULED_FK   DATE_SHIPPED_FK COGS_DATE_FK
     + 7* Ceil( x_trx_date_fk + 1)
     -- LOCATOR_FK
     + Ceil(l_mmt.sub_code + l_org.org_code + x_instance_fk + 7 +1)
     -- SET_OF_BOOKS_FK
     + Ceil( 3 + x_instance_fk + 1);

   -- this section is to handle marketing team FKs
   --

   x_total := x_total
     -- OFFER_HDR_FK    OFFER_LINE_FK
     + 2* Ceil( Nvl(x_offer,0) + x_instance_fk + 1)
     -- TARGET_SEGMENT_INIT_FK  TARGET_SEGMENT_ACTL_FK
     + 2* Ceil( Nvl(x_target,0) + x_instance_fk + 1)
     -- CAMPAIGN_STATUS_ACTL_FK  CAMPAIGN_STATUS_INIT_FK
     + 2* Ceil( Nvl(x_campaign,0) + x_instance_fk + 1);

   x_total := x_total
     -- ORDER_LINE_ID
     + Ceil(l_line.line_id + x_instance_fk + 1 + 1)
     -- SHIP_INV_LOCATOR_FK
     + Ceil(l_org.org_code + x_instance_fk +6 + 1)
     -- COGS_DATE  ORDER_DATE
     + 2 * x_date
     -- PROM_EARLY_COUNT  PROM_LATE_COUNT  REQ_EARLY_COUNT  REQ_LATE_COUNT
     + 4 * 2
     -- PROM_EARLY_VAL_G  PROM_LATE_VAL_G  REQ_EARLY_VAL_G  REQ_LATE_VAL_G
     + 4 * Ceil( l_mta.transaction_value)
     -- REQUEST_LEAD_TIME  PROMISE_LEAD_TIME  ORDER_LEAD_TIME
     + 3 * 3
     -- SHIPPED_QTY_B   RMA_QTY_B ICAP_QTY_B
     + 3 * Ceil(l_mmt.qty + 1)
     -- COGS_T  COGS_B COGS_G  RMA_VAL_T  RMA_VAL_G
     + 5 * Ceil(l_mta.transaction_value + 1)
     -- LAST_UPDATE_DATE,
     + x_date
     -- cost_element_id
     + Ceil(l_mta.cost_element_id + 1)
     -- ACCOUNT
     + Ceil(l_mta.account + 1)
     -- ORDER_NUMBER
     + Ceil(l_header.order_number + 1)
     -- WAYBILL_NUMBER
     + Ceil(x_wnd + 1)
     -- LOT
     + Ceil(l_wdd.lot + 1)
     -- REVISION
     + Ceil(l_wdd.revision + 1)
     -- SERIAL_NUMBER
     + Ceil(l_wdd.serial_number + 1);

   -- dbms_output.put_line('1 x_total is ' || x_total );

   p_avg_row_len := x_total;


  END;  -- procedure est_row_len.

END;  -- package body OPI_EDW_OPI_RES_UTIL_F_SZ

/
