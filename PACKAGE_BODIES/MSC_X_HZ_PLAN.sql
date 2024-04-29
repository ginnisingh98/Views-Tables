--------------------------------------------------------
--  DDL for Package Body MSC_X_HZ_PLAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_X_HZ_PLAN" AS
/*  $Header: MSCXHZPB.pls 120.7.12010000.2 2008/08/11 13:04:02 hbinjola ship $ */

   NOT_SELECTED CONSTANT NUMBER(1) := 0;
   SALES_FORECAST   CONSTANT NUMBER(1) := 1;
   ORDER_FORECAST_CST CONSTANT NUMBER(1) := 2;
   SUPPLY_COMMIT CONSTANT NUMBER(1) := 3; -- SUPPLY COMMIT
   G_RETURNS_FORECAST CONSTANT NUMBER(2) := 50; -- bug#6893383
   G_DEFECTIVE_OUTBOUND_SHIPMENT  CONSTANT NUMBER(2) := 51; -- bug#6893383
   HISTORICAL_SALES CONSTANT NUMBER(1) := 4;
   SELL_THRU_FORECAST CONSTANT NUMBER(1) := 5;
   NEGOTIATED_CAPACITY  CONSTANT NUMBER(1) := 6;
   SAFETY_STOCK     CONSTANT NUMBER(1)  := 7;
   PROJ_SAFETY_STOCK CONSTANT NUMBER(1) := 8;
   ALLOCATED_ONHAND CONSTANT NUMBER(1) := 9;
   UNALLOCATED_ONHAND CONSTANT NUMBER(2) := 10;
   PROJ_UNALOC_AVL_BAL CONSTANT NUMBER(2) := 11;
   PROJ_ALLOC_AVL_BAL CONSTANT NUMBER(2) := 12;
   PURCHASE_ORDER CONSTANT NUMBER(2) := 13;
   SALES_ORDER CONSTANT NUMBER(2) := 14;
   ASN CONSTANT NUMBER(2) := 15;
   SHIPMENT_RECEIPT CONSTANT NUMBER(2) := 16;
   INTRANSIT CONSTANT NUMBER(2) := 17;
   WORK_ORDER CONSTANT NUMBER(2) := 45;
   PO_ACK CONSTANT NUMBER(2) := 21;
   REPLENISHMENT CONSTANT NUMBER(2) := 19;
   REQUISITION CONSTANT NUMBER(2) := 20;
   RUN_TOT_SUPPLY CONSTANT NUMBER(2) := 46;
   RUN_TOT_DEMAND CONSTANT NUMBER(2) := 47;
   PO_FROM_PLAN CONSTANT NUMBER(2) := 22;
   RELEASED_PLAN CONSTANT NUMBER(2) := 23;
   PLANNED_ORDER CONSTANT NUMBER(2) := 24;
   PROJ_AVAIL_BAL     CONSTANT NUMBER(2)  := 27;

   DAY_BUCKET CONSTANT NUMBER(1) := 1;
   WEEK_BUCKET CONSTANT NUMBER(1) := 2;
   MONTH_BUCKET CONSTANT NUMBER(1) := 3;
   SELECTED     CONSTANT NUMBER(2) := 99;
   v_temp_cnt number := 0;

   module CONSTANT VARCHAR2(24) := 'msc.plsql.MSC_X_HZ_PLAN.';



   /**
    * The following procedure
    * calculates the buckets and aggregates the quantites
    * into appropriate buckets for display on the HZ View.
    */
   Procedure populate_bucketed_quantity(
                             arg_query_id     OUT NOCOPY NUMBER,
                             arg_next_link    OUT NOCOPY VARCHAR2,
                             arg_num_rowset   OUT NOCOPY NUMBER,
                             arg_err_msg      OUT NOCOPY VARCHAR2,
                             arg_default_pref OUT NOCOPY NUMBER,
                             arg_pref_name    IN  VARCHAR2, -- DEFAULT NULL,
                             arg_start_row    IN  NUMBER, -- DEFAULT 1,
                             arg_end_row      IN  NUMBER, -- DEFAULT 25,
                             arg_item_sort    IN  VARCHAR2, -- DEFAULT 'ASC',
                             arg_from_date    IN  DATE, -- DEFAULT sysdate,
                             arg_where_clause IN  VARCHAR2, -- DEFAULT NULL,
                             arg_plan_under   IN  VARCHAR2, -- DEFAULT 'N',
                             arg_plan_over    IN  VARCHAR2, -- DEFAULT 'N',
                             arg_actual_under IN  VARCHAR2, -- DEFAULT 'N',
                             arg_actual_over  IN  VARCHAR2 -- DEFAULT 'N'
                             )
   IS

      TYPE num IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
      TYPE temp_cursor IS REF CURSOR;
      TYPE calendar_date IS TABLE OF DATE INDEX BY BINARY_INTEGER;
      TYPE small_string IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
      TYPE string IS TABLE OF VARCHAR2(255) INDEX BY BINARY_INTEGER;
      TYPE big_string IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;

      ORG_AGG CONSTANT NUMBER(1) := 0;
      COMPANY_AGG CONSTANT NUMBER(1) := 1;
      ALL_AGG CONSTANT NUMBER(1) := 2;
      ITEM_AGG CONSTANT NUMBER(1) := 0;

      THIRD_PARTY CONSTANT NUMBER(1) := 0;

      error VARCHAR2(2000) ;
      v_pref VARCHAR2(100);
      v_graphtype NUMBER(1);
      v_category VARCHAR2(250);
      v_graphtitle VARCHAR2(250);
      v_past_due_hdr VARCHAR2(250);
      v_user_company VARCHAR2(250);
   v_default_cal_code VARCHAR2(250);
      v_calendar_code VARCHAR2(250);
      v_customer_id NUMBER;
      v_customer_site_id NUMBER;
      v_supplier_id NUMBER;
      v_supplier_site_id NUMBER;
      g_multiple_sites NUMBER := -1;
      v_sr_instance_id NUMBER;


      v_lookup_name VARCHAR2(250);

      record_cnt number ;
      k number;

      osce_bucketed_plan temp_cursor;
      --  variables for the orders selected in the user prefs

      v_sales_forecast NUMBER(2) := 0;
      v_order_forecast NUMBER(2) := 0;
      v_supply_commit NUMBER(2) := 0;
      v_returns_forecast NUMBER(2) := 0; -- bug#6893383
      v_def_outbound_shipment NUMBER(2) := 0; -- bug#6893383
      v_hist_sales NUMBER(2) := 0;
      v_sell_thru_fcst NUMBER(2) := 0;
      v_negotiated_capacity NUMBER(2) := 0;
      v_safety_stock NUMBER(2) := 0;
      v_proj_safety_stock NUMBER(2) := 0;
      v_alloc_onhand NUMBER(2) := 0;
      v_unalloc_onhand NUMBER(2) := 0;
      v_proj_unalloc_avl_bal NUMBER(2) := 0;
      v_proj_alloc_avl_bal NUMBER(2) := 0;
      v_purchase_order NUMBER(2) := 0;
      v_sales_order NUMBER(2) := 0;
      v_asn NUMBER(2) := 0;
      v_shipment_receipt NUMBER(2) := 0;
      v_intransit NUMBER(2) := 0;
      v_work_order NUMBER(2) := 0;
      v_po_ack NUMBER(2) := 0;
      v_replenishment NUMBER(2) := 0;
      v_requisition NUMBER(2) := 0;
      v_run_tot_supply NUMBER(2) := 0;
      v_run_tot_demand NUMBER(2) := 0;
      v_po_from_plan NUMBER(2) := 0;
      v_released_plan NUMBER(2) := 0;
      v_planned_order NUMBER(2) := 0;
      v_proj_avail_bal NUMBER(2) := 0;

      v_shift_days NUMBER := 0;

      -- Net forecast and total supply summary lines
      v_net_forecast NUMBER(2) := 0;
      v_total_supply NUMBER(2) := 0;
      v_delete_purchase_order BOOLEAN := FALSE;
      v_delete_requisition BOOLEAN := FALSE;

      --  variables for the aggregation of item . co and tp
      prod_agg NUMBER(1) := 0;
      myco_agg NUMBER(1) := 0;
      tpco_agg NUMBER(1) := 0;

      daily_bucket_count NUMBER(2) := 0;
      weekly_bucket_count NUMBER(2) := 0;
      period_bucket_count NUMBER(2) := 0;

      --  variables for the orde ranking selected in the user prefs
      v_o_seller_forecast  NUMBER(2) := 0;
      v_o_forecast         NUMBER(2) := 0;
      v_o_supply_commit    NUMBER(2) := 0;
      v_o_returns_forecast NUMBER(2) := 0; -- bug#6893383
      v_o_def_outbound_shipment NUMBER(2) := 0; -- bug#6893383
      v_o_hist_sales       NUMBER(2) := 0;
      v_o_sell_thro_fcst   NUMBER(2) := 0;
      v_o_negcap           NUMBER(2) := 0;
      v_o_ss               NUMBER(2) := 0;
      v_o_pab              NUMBER(2) := 0;
      v_o_projected_ss     NUMBER(2) := 0;
      v_o_alct_onhand      NUMBER(2) := 0;
      v_o_unalct_onhand    NUMBER(2) := 0;
      v_o_po               NUMBER(2) := 0;
      v_o_work_order       NUMBER(2) := 0;
      v_o_po_ack           NUMBER(2) := 0;
      v_o_sales_orders     NUMBER(2) := 0;
      v_o_asn              NUMBER(2) := 0;
      v_o_receiving        NUMBER(2) := 0;
      v_o_transit          NUMBER(2) := 0;
      v_o_wip              NUMBER(2) := 0;
      v_o_req              NUMBER(2) := 0;
      v_o_replenishment    NUMBER(2) := 0;
      v_o_run_tot_supply   NUMBER(2) := 0;
      v_o_run_tot_demand   NUMBER(2) := 0;
      v_o_unalct_prjt_avl_bal NUMBER(2) := 0;
      v_o_alcat_prjt_avl_bal  NUMBER(2) := 0;
      v_o_gross_requirements  NUMBER(2) := 0;
      v_o_po_from_plan    NUMBER(2) := 0;
      v_o_released_plan    NUMBER(2) := 0;
      v_o_planned_order    NUMBER(2) := 0;

      firstrec NUMBER(2) := 0;
      unbucketed_flag number := -1;
      g_statement VARCHAR2(4000);
      curr_date date;

      rec_counter NUMBER := 1;
      calc_past_due boolean := TRUE;
      tot_rec number := 1;
      pagesize number := 1;

      v_last_bkt_date date;
      p_start_date date;


      var_dates  calendar_date ;   -- Holds the start dates of buckets

      var_item_id num;
      var_next_item num;
      var_order num;
      var_order_rank num;
      var_qty_nobkt num;
      var_past_due_qty num;


      var_pub_id1 number := 0;
      var_pub_id2 number := 0;
      var_pub_id3 number := 0;
      var_pub_id4 number := 0;
      var_pub_id5 number := 0;
      var_pub_id6 number := 0;
      var_pub_id7 number := 0;
      var_pub_id8 number := 0;
      var_pub_id9 number := 0;
      var_pub_id10 number := 0;
      var_pub_id11 number := 0;
      var_pub_id12 number := 0;
      var_pub_id13 number := 0;
      var_pub_id14 number := 0;
      var_pub_id15 number := 0;
      var_pub_id16 number := 0;
      var_pub_id17 number := 0;
      var_pub_id18 number := 0;
      var_pub_id19 number := 0;
      var_pub_id20 number := 0;
      var_pub_id21 number := 0;
      var_pub_id22 number := 0;
      var_pub_id23 number := 0;
      var_pub_id24 number := 0;
      var_pub_id25 number := 0;
      var_pub_id26 number := 0;
      var_pub_id27 number := 0;
      var_pub_id28 number := 0;
      var_pub_id29 number := 0;
      var_pub_id30 number := 0;
      var_pub_id31 number := 0;
      var_pub_id32 number := 0;
      var_pub_id33 number := 0;
      var_pub_id34 number := 0;
      var_pub_id35 number := 0;
      var_pub_id36 number := 0;


      var_temp_qty1 number := 0;
      var_temp1 number := 0;
      var_temp_qty2 number := 0;
      var_temp2 number := 0;
      var_temp_qty3 number := 0;
      var_temp3 number := 0;
      var_temp_qty4 number := 0;
      var_temp4 number := 0;
      var_temp_qty5 number := 0;
      var_temp5 number := 0;
      var_temp_qty6 number := 0;
      var_temp6 number := 0;
      var_temp_qty7 number := 0;
      var_temp7 number := 0;
      var_temp_qty8 number := 0;
      var_temp8 number := 0;
      var_temp_qty9 number := 0;
      var_temp9 number := 0;
      var_temp_qty10 number := 0;
      var_temp10 number := 0;
      var_temp_qty11 number := 0;
      var_temp11 number := 0;
      var_temp_qty12 number := 0;
      var_temp12 number := 0;
      var_temp_qty13 number := 0;
      var_temp13 number := 0;
      var_temp_qty14 number := 0;
      var_temp14 number := 0;
      var_temp_qty15 number := 0;
      var_temp15 number := 0;
      var_temp_qty16 number := 0;
      var_temp16 number := 0;
      var_temp_qty17 number := 0;
      var_temp17 number := 0;
      var_temp_qty18 number := 0;
      var_temp18 number := 0;
      var_temp_qty19 number := 0;
      var_temp19 number := 0;
      var_temp_qty20 number := 0;
      var_temp20 number := 0;
      var_temp_qty21 number := 0;
      var_temp21 number := 0;
      var_temp_qty22 number := 0;
      var_temp22 number := 0;
      var_temp_qty23 number := 0;
      var_temp23 number := 0;
      var_temp_qty24 number := 0;
      var_temp24 number := 0;
      var_temp_qty25 number := 0;
      var_temp25 number := 0;
      var_temp_qty26 number := 0;
      var_temp26 number := 0;
      var_temp_qty27 number := 0;
      var_temp27 number := 0;
      var_temp_qty28 number := 0;
      var_temp28 number := 0;
      var_temp_qty29 number := 0;
      var_temp29 number := 0;
      var_temp_qty30 number := 0;
      var_temp30 number := 0;
      var_temp_qty31 number := 0;
      var_temp31 number := 0;
      var_temp_qty32 number := 0;
      var_temp32 number := 0;
      var_temp_qty33 number := 0;
      var_temp33 number := 0;
      var_temp_qty34 number := 0;
      var_temp34 number := 0;
      var_temp_qty35 number := 0;
      var_temp35 number := 0;
      var_temp_qty36 number := 0;
      var_temp36 number := 0;



 var_flag1 BOOLEAN := TRUE;
        var_flag2 BOOLEAN := TRUE;
        var_flag3 BOOLEAN := TRUE;
        var_flag4 BOOLEAN := TRUE;
        var_flag5 BOOLEAN := TRUE;
        var_flag6 BOOLEAN := TRUE;
 var_flag7 BOOLEAN := TRUE;
        var_flag8 BOOLEAN := TRUE;
        var_flag9 BOOLEAN := TRUE;
        var_flag10 BOOLEAN := TRUE;
 var_flag11 BOOLEAN := TRUE;
        var_flag12 BOOLEAN := TRUE;
        var_flag13 BOOLEAN := TRUE;
        var_flag14 BOOLEAN := TRUE;
        var_flag15 BOOLEAN := TRUE;
        var_flag16 BOOLEAN := TRUE;
 var_flag17 BOOLEAN := TRUE;
        var_flag18 BOOLEAN := TRUE;
        var_flag19 BOOLEAN := TRUE;
        var_flag20 BOOLEAN := TRUE;
 var_flag21 BOOLEAN := TRUE;
        var_flag22 BOOLEAN := TRUE;
        var_flag23 BOOLEAN := TRUE;
        var_flag24 BOOLEAN := TRUE;
        var_flag25 BOOLEAN := TRUE;
        var_flag26 BOOLEAN := TRUE;
 var_flag27 BOOLEAN := TRUE;
        var_flag28 BOOLEAN := TRUE;
        var_flag29 BOOLEAN := TRUE;
        var_flag30 BOOLEAN := TRUE;
 var_flag31 BOOLEAN := TRUE;
        var_flag32 BOOLEAN := TRUE;
        var_flag33 BOOLEAN := TRUE;
        var_flag34 BOOLEAN := TRUE;
        var_flag35 BOOLEAN := TRUE;
        var_flag36 BOOLEAN := TRUE;


 var_temp_order_type1 number := 0;
 var_temp_order_type2 number := 0;
 var_temp_order_type3 number := 0;
 var_temp_order_type4 number := 0;
 var_temp_order_type5 number := 0;
 var_temp_order_type6 number := 0;
 var_temp_order_type7 number := 0;
 var_temp_order_type8 number := 0;
 var_temp_order_type9 number := 0;
 var_temp_order_type10 number := 0;
 var_temp_order_type11 number := 0;
 var_temp_order_type12 number := 0;
 var_temp_order_type13 number := 0;
 var_temp_order_type14 number := 0;
 var_temp_order_type15 number := 0;
 var_temp_order_type16 number := 0;
 var_temp_order_type17 number := 0;
 var_temp_order_type18 number := 0;
 var_temp_order_type19 number := 0;
 var_temp_order_type20 number := 0;
 var_temp_order_type21 number := 0;
 var_temp_order_type22 number := 0;
 var_temp_order_type23 number := 0;
 var_temp_order_type24 number := 0;
 var_temp_order_type25 number := 0;
 var_temp_order_type26 number := 0;
 var_temp_order_type27 number := 0;
 var_temp_order_type28 number := 0;
 var_temp_order_type29 number := 0;
 var_temp_order_type30 number := 0;
 var_temp_order_type31 number := 0;
 var_temp_order_type32 number := 0;
 var_temp_order_type33 number := 0;
 var_temp_order_type34 number := 0;
 var_temp_order_type35 number := 0;
 var_temp_order_type36 number := 0;




      var_qty1 num;
      var_qty2 num;
      var_qty3 num;
      var_qty4 num;
      var_qty5 num;
      var_qty6 num;
      var_qty7 num;
      var_qty8 num;
      var_qty9 num;
      var_qty10 num;
      var_qty11 num;
      var_qty12 num;
      var_qty13 num;
      var_qty14 num;
      var_qty15 num;
      var_qty16 num;
      var_qty17 num;
      var_qty18 num;
      var_qty19 num;
      var_qty20 num;
      var_qty21 num;
      var_qty22 num;
      var_qty23 num;
      var_qty24 num;
      var_qty25 num;
      var_qty26 num;
      var_qty27 num;
      var_qty28 num;
      var_qty29 num;
      var_qty30 num;
      var_qty31 num;
      var_qty32 num;
      var_qty33 num;
      var_qty34 num;
      var_qty35 num;
      var_qty36 num;
      var_day_bkt num;
      var_week_bkt num;
      var_month_bkt num;

      var_bkt_type num;
      var_pub_id num;
      var_pub_site_id num;

      var_relation big_string;
      var_order_relation big_string;
      var_supplier_id big_string;
      var_customer_id big_string;
      var_supplier_site_id big_string;
      var_customer_site_id big_string;
      var_from_co_name string;
      var_item_name string;
      var_item_name_desc string;
      var_supplier string;
      var_customer string;

      var_from_org_name small_string;
      var_supplier_org small_string;
      var_customer_org small_string;
      var_order_desc small_string;
      var_ship_ctrl small_string;
      var_uom small_string;

      -- variables reqd for updating the owner item etc.
      v_line_id num;
      v_cust_name string;
      v_sup_name string;
      v_item_id num ;
      v_order num;
      v_pub_name string;

      v_owner_item varchar2(250);
      v_sup_item varchar2(250);
      v_cust_item varchar2(250);
      v_tp_uom varchar2(3);
      v_uom_code varchar2(3);
      v_owner_item_desc varchar2(240);
      v_sup_item_desc varchar2(240);
      v_cust_item_desc varchar2(240);

      var_line_id num;
      var_owner_item string;
      var_cust_item string;
      var_sup_item string;
      var_owner_item_desc string;
      var_cust_item_desc string;
      var_sup_item_desc string;
      var_tp_uom small_string;
      var_uom_code small_string;

      temp_sup_site num;
      temp_cust_site num;
      temp_sup num;
      temp_cust num;

      var_edit_flag num;

      TYPE mrp_activity IS RECORD
           (relation      VARCHAR2(2000),
            order_relation VARCHAR2(2000),
            from_co_name  VARCHAR2(255),
            from_org_name VARCHAR2(40),
            item_id       NUMBER,
            item_name     VARCHAR2(250),
            item_desc     VARCHAR2(240),
	    supplier_item_name VARCHAR2(250),
            order_rank    NUMBER,
            order_type    NUMBER,
            order_desc    VARCHAR2(80),
            shipping_control VARCHAR2(35),
            new_date      DATE,
            uom           VARCHAR2(3),
            new_quantity  NUMBER,
            qty_nobucket  NUMBER,
            supplier_id   NUMBER,
            customer_id   NUMBER,
            supp_site_id  NUMBER,
            cust_site_id  NUMBER,
            supplier_name VARCHAR2(250),
            customer_name VARCHAR2(250),
            supplier_org  VARCHAR2(40),
            customer_org  VARCHAR2(40),
            third_party_flag NUMBER,
            viewer_co     VARCHAR2(255),
            tp_co         VARCHAR2(255),
            bucket_type   NUMBER(1),
            publisher_id  NUMBER,
            publisher_site_id NUMBER
           );

      activity_rec  mrp_activity;
      previous_rec  mrp_activity;

      curr_rel   VARCHAR2(2000);
      curr_item  VARCHAR2(750);

      last_rel  VARCHAR2(2000);
      last_item VARCHAR2(750);

      curr_ot   NUMBER;
      last_ot   NUMBER;

      curr_ship_ctrl VARCHAR2(30);
      last_ship_ctrl VARCHAR2(30);


      g_num_of_buckets INTEGER := 0;

      i INTEGER := 0;




      CURSOR c_total(ARG_ORDER_TYPE IN NUMBER)
      IS
         SELECT RELATION_GROUP,ORDER_RELATION_GROUP,FROM_COMPANY_NAME,FROM_ORG_CODE,ITEM_NAME,ITEM_DESCRIPTION,
                SUPPLIER_NAME,CUSTOMER_NAME,SUPPLIER_ORG_CODE,CUSTOMER_ORG_CODE,UOM,
                SUPPLIER_ID,CUSTOMER_ID,SUPPLIER_SITE_ID,CUSTOMER_SITE_ID,INVENTORY_ITEM_ID,
                ROUND( sum(UNBUCKETED_QTY), 6)  q_0,ROUND( sum(QTY_BUCKET1), 6)  q_1,
                ROUND( sum(QTY_BUCKET2), 6)  q_2,ROUND( sum(QTY_BUCKET3), 6)  q_3, ROUND( sum(QTY_BUCKET4), 6)  q_4,
                ROUND( sum(QTY_BUCKET5), 6)  q_5,ROUND( sum(QTY_BUCKET6), 6)  q_6,ROUND( sum(QTY_BUCKET7), 6)  q_7,
                ROUND( sum(QTY_BUCKET8), 6)  q_8,ROUND( sum(QTY_BUCKET9), 6)  q_9,ROUND( sum(QTY_BUCKET10), 6)  q_10,
                ROUND( sum(QTY_BUCKET11), 6)  q_11,ROUND( sum(QTY_BUCKET12), 6)  q_12,ROUND( sum(QTY_BUCKET13), 6)  q_13,
                ROUND( sum(QTY_BUCKET14), 6)  q_14,ROUND( sum(QTY_BUCKET15), 6)  q_15,ROUND( sum(QTY_BUCKET16), 6)  q_16,
                ROUND( sum(QTY_BUCKET17), 6)  q_17,ROUND( sum(QTY_BUCKET18), 6)  q_18,ROUND( sum(QTY_BUCKET19), 6)  q_19,
                ROUND( sum(QTY_BUCKET20), 6)  q_20,ROUND( sum(QTY_BUCKET21), 6)  q_21,ROUND( sum(QTY_BUCKET22), 6)  q_22,
                ROUND( sum(QTY_BUCKET23), 6)  q_23,ROUND( sum(QTY_BUCKET24), 6)  q_24,ROUND( sum(QTY_BUCKET25), 6)  q_25,
                ROUND( sum(QTY_BUCKET26), 6)  q_26,ROUND( sum(QTY_BUCKET27), 6)  q_27,ROUND( sum(QTY_BUCKET28), 6)  q_28,
                ROUND( sum(QTY_BUCKET29), 6)  q_29,ROUND( sum(QTY_BUCKET30), 6)  q_30,ROUND( sum(QTY_BUCKET31), 6)  q_31,
                ROUND( sum(QTY_BUCKET32), 6)  q_32,ROUND( sum(QTY_BUCKET33), 6)  q_33,ROUND( sum(QTY_BUCKET34), 6)  q_34,
                ROUND( sum(QTY_BUCKET35), 6)  q_35,ROUND( sum(QTY_BUCKET36), 6)  q_36
           FROM msc_hz_ui_lines
          WHERE ORDER_TYPE = nvl(arg_order_type,NOT_SELECTED)
            AND query_id = arg_query_id
         GROUP BY RELATION_GROUP,ORDER_RELATION_GROUP, FROM_COMPANY_NAME,FROM_ORG_CODE,ITEM_NAME,ITEM_DESCRIPTION,
                SUPPLIER_NAME,CUSTOMER_NAME,SUPPLIER_ORG_CODE,CUSTOMER_ORG_CODE,UOM,
                SUPPLIER_ID,CUSTOMER_ID,SUPPLIER_SITE_ID,CUSTOMER_SITE_ID,INVENTORY_ITEM_ID;

      CURSOR c_runTotal(arg_order_type IN NUMBER)
      IS
         SELECT RELATION_GROUP,ORDER_RELATION_GROUP,FROM_COMPANY_NAME,FROM_ORG_CODE,ITEM_NAME,ITEM_DESCRIPTION,
            SUPPLIER_NAME,CUSTOMER_NAME,SUPPLIER_ORG_CODE,CUSTOMER_ORG_CODE,UOM,
            SUPPLIER_ID,CUSTOMER_ID,SUPPLIER_SITE_ID,CUSTOMER_SITE_ID,INVENTORY_ITEM_ID,
            ROUND( sum(UNBUCKETED_QTY), 6)  q_0,ROUND( sum(QTY_BUCKET1), 6)  q_1,ROUND( sum(QTY_BUCKET1+QTY_BUCKET2), 6)  q_2,
            ROUND( sum(QTY_BUCKET1+QTY_BUCKET2+QTY_BUCKET3), 6)  q_3,
            ROUND( sum(QTY_BUCKET1+QTY_BUCKET2+QTY_BUCKET3+QTY_BUCKET4), 6)  q_4,
            ROUND( sum(QTY_BUCKET1+QTY_BUCKET2+QTY_BUCKET3+QTY_BUCKET4+QTY_BUCKET5), 6)  q_5,
            ROUND( sum(QTY_BUCKET1+QTY_BUCKET2+QTY_BUCKET3+QTY_BUCKET4+QTY_BUCKET5+QTY_BUCKET6), 6)  q_6,
            ROUND( sum(QTY_BUCKET1+QTY_BUCKET2+QTY_BUCKET3+QTY_BUCKET4+QTY_BUCKET5+QTY_BUCKET6
                +QTY_BUCKET7), 6)  q_7,
            ROUND( sum(QTY_BUCKET1+QTY_BUCKET2+QTY_BUCKET3+QTY_BUCKET4+QTY_BUCKET5+QTY_BUCKET6
                +QTY_BUCKET7+QTY_BUCKET8), 6)  q_8,
            ROUND( sum(QTY_BUCKET1+QTY_BUCKET2+QTY_BUCKET3+QTY_BUCKET4+QTY_BUCKET5+QTY_BUCKET6
                +QTY_BUCKET7+QTY_BUCKET8+QTY_BUCKET9), 6)  q_9,
            ROUND( sum(QTY_BUCKET1+QTY_BUCKET2+QTY_BUCKET3+QTY_BUCKET4+QTY_BUCKET5+QTY_BUCKET6
                +QTY_BUCKET7+QTY_BUCKET8+QTY_BUCKET9+QTY_BUCKET10), 6)  q_10,
            ROUND( sum(QTY_BUCKET1+QTY_BUCKET2+QTY_BUCKET3+QTY_BUCKET4+QTY_BUCKET5+QTY_BUCKET6
                +QTY_BUCKET7+QTY_BUCKET8+QTY_BUCKET9+QTY_BUCKET10+QTY_BUCKET11), 6)  q_11,
            ROUND( sum(QTY_BUCKET1+QTY_BUCKET2+QTY_BUCKET3+QTY_BUCKET4+QTY_BUCKET5+QTY_BUCKET6
                +QTY_BUCKET7+QTY_BUCKET8+QTY_BUCKET9+QTY_BUCKET10+QTY_BUCKET11
                +QTY_BUCKET12), 6)  q_12,
            ROUND( sum(QTY_BUCKET1+QTY_BUCKET2+QTY_BUCKET3+QTY_BUCKET4+QTY_BUCKET5
                +QTY_BUCKET6+QTY_BUCKET7+QTY_BUCKET8+QTY_BUCKET9+QTY_BUCKET10
                +QTY_BUCKET11+QTY_BUCKET12+QTY_BUCKET13), 6)  q_13,
            ROUND( sum(QTY_BUCKET1+QTY_BUCKET2+QTY_BUCKET3+QTY_BUCKET4+QTY_BUCKET5+QTY_BUCKET6
                +QTY_BUCKET7+QTY_BUCKET8+QTY_BUCKET9+QTY_BUCKET10+QTY_BUCKET11+QTY_BUCKET12
                +QTY_BUCKET13+QTY_BUCKET14), 6)  q_14,
            ROUND( sum(QTY_BUCKET1+QTY_BUCKET2+QTY_BUCKET3+QTY_BUCKET4+QTY_BUCKET5+QTY_BUCKET6
                +QTY_BUCKET7+QTY_BUCKET8+QTY_BUCKET9+QTY_BUCKET10+QTY_BUCKET11+QTY_BUCKET12
                +QTY_BUCKET13+QTY_BUCKET14+QTY_BUCKET15), 6)  q_15,
            ROUND( sum(QTY_BUCKET1+QTY_BUCKET2+QTY_BUCKET3+QTY_BUCKET4+QTY_BUCKET5+QTY_BUCKET6
                +QTY_BUCKET7+QTY_BUCKET8+QTY_BUCKET9+QTY_BUCKET10+QTY_BUCKET11+QTY_BUCKET12
                +QTY_BUCKET13+QTY_BUCKET14+QTY_BUCKET15+QTY_BUCKET16), 6)  q_16,
            ROUND( sum(QTY_BUCKET1+QTY_BUCKET2+QTY_BUCKET3+QTY_BUCKET4+QTY_BUCKET5+QTY_BUCKET6
                +QTY_BUCKET7+QTY_BUCKET8+QTY_BUCKET9+QTY_BUCKET10+QTY_BUCKET11+QTY_BUCKET12
                +QTY_BUCKET13+QTY_BUCKET14+QTY_BUCKET15+QTY_BUCKET16+QTY_BUCKET17), 6)  q_17,
            ROUND( sum(QTY_BUCKET1+QTY_BUCKET2+QTY_BUCKET3+QTY_BUCKET4+QTY_BUCKET5+QTY_BUCKET6
                +QTY_BUCKET7+QTY_BUCKET8+QTY_BUCKET9+QTY_BUCKET10+QTY_BUCKET11+QTY_BUCKET12
                +QTY_BUCKET13+QTY_BUCKET14+QTY_BUCKET15+QTY_BUCKET16+QTY_BUCKET17+QTY_BUCKET18), 6)  q_18,
            ROUND( sum(QTY_BUCKET1+QTY_BUCKET2+QTY_BUCKET3+QTY_BUCKET4+QTY_BUCKET5+QTY_BUCKET6
                +QTY_BUCKET7+QTY_BUCKET8+QTY_BUCKET9+QTY_BUCKET10+QTY_BUCKET11+QTY_BUCKET12
                +QTY_BUCKET13+QTY_BUCKET14+QTY_BUCKET15+QTY_BUCKET16+QTY_BUCKET17+QTY_BUCKET18
                +QTY_BUCKET19), 6)  q_19,
            ROUND( sum(QTY_BUCKET1+QTY_BUCKET2+QTY_BUCKET3+QTY_BUCKET4+QTY_BUCKET5+QTY_BUCKET6
                +QTY_BUCKET7+QTY_BUCKET8+QTY_BUCKET9+QTY_BUCKET10+QTY_BUCKET11+QTY_BUCKET12
                +QTY_BUCKET13+QTY_BUCKET14+QTY_BUCKET15+QTY_BUCKET16+QTY_BUCKET17+QTY_BUCKET18
                +QTY_BUCKET19+QTY_BUCKET20), 6)  q_20,
            ROUND( sum(QTY_BUCKET1+QTY_BUCKET2+QTY_BUCKET3+QTY_BUCKET4+QTY_BUCKET5+QTY_BUCKET6+QTY_BUCKET7
                +QTY_BUCKET8+QTY_BUCKET9+QTY_BUCKET10+QTY_BUCKET11+QTY_BUCKET12+QTY_BUCKET13
                +QTY_BUCKET14+QTY_BUCKET15+QTY_BUCKET16+QTY_BUCKET17+QTY_BUCKET18+QTY_BUCKET19
                +QTY_BUCKET20+QTY_BUCKET21), 6)  q_21,
            ROUND( sum(QTY_BUCKET1+QTY_BUCKET2+QTY_BUCKET3+QTY_BUCKET4+QTY_BUCKET5+QTY_BUCKET6+QTY_BUCKET7
                +QTY_BUCKET8+QTY_BUCKET9+QTY_BUCKET10+QTY_BUCKET11+QTY_BUCKET12+QTY_BUCKET13
                +QTY_BUCKET14+QTY_BUCKET15+QTY_BUCKET16+QTY_BUCKET17+QTY_BUCKET18+QTY_BUCKET19
                +QTY_BUCKET20+QTY_BUCKET21+QTY_BUCKET22), 6)  q_22,
            ROUND( sum(QTY_BUCKET1+QTY_BUCKET2+QTY_BUCKET3+QTY_BUCKET4+QTY_BUCKET5+QTY_BUCKET6+QTY_BUCKET7
                +QTY_BUCKET8+QTY_BUCKET9+QTY_BUCKET10+QTY_BUCKET11+QTY_BUCKET12+QTY_BUCKET13
                +QTY_BUCKET14+QTY_BUCKET15+QTY_BUCKET16+QTY_BUCKET17+QTY_BUCKET18+QTY_BUCKET19
                +QTY_BUCKET20+QTY_BUCKET21+QTY_BUCKET22+QTY_BUCKET23), 6)  q_23,
            ROUND( sum(QTY_BUCKET1+QTY_BUCKET2+QTY_BUCKET3+QTY_BUCKET4+QTY_BUCKET5+QTY_BUCKET6+QTY_BUCKET7
                +QTY_BUCKET8+QTY_BUCKET9+QTY_BUCKET10+QTY_BUCKET11+QTY_BUCKET12+QTY_BUCKET13
                +QTY_BUCKET14+QTY_BUCKET15+QTY_BUCKET16+QTY_BUCKET17+QTY_BUCKET18+QTY_BUCKET19
                +QTY_BUCKET20+QTY_BUCKET21+QTY_BUCKET22+QTY_BUCKET23+QTY_BUCKET24), 6)  q_24,
            ROUND( sum(QTY_BUCKET1+QTY_BUCKET2+QTY_BUCKET3+QTY_BUCKET4+QTY_BUCKET5+QTY_BUCKET6+QTY_BUCKET7
                +QTY_BUCKET8+QTY_BUCKET9+QTY_BUCKET10+QTY_BUCKET11+QTY_BUCKET12+QTY_BUCKET13
                +QTY_BUCKET14+QTY_BUCKET15+QTY_BUCKET16+QTY_BUCKET17+QTY_BUCKET18+QTY_BUCKET19
                +QTY_BUCKET20+QTY_BUCKET21+QTY_BUCKET22+QTY_BUCKET23+QTY_BUCKET24+QTY_BUCKET25), 6)  q_25,
            ROUND( sum(QTY_BUCKET1+QTY_BUCKET2+QTY_BUCKET3+QTY_BUCKET4+QTY_BUCKET5+QTY_BUCKET6+QTY_BUCKET7
                +QTY_BUCKET8+QTY_BUCKET9+QTY_BUCKET10+QTY_BUCKET11+QTY_BUCKET12+QTY_BUCKET13
                +QTY_BUCKET14+QTY_BUCKET15+QTY_BUCKET16+QTY_BUCKET17+QTY_BUCKET18+QTY_BUCKET19
                +QTY_BUCKET20+QTY_BUCKET21+QTY_BUCKET22+QTY_BUCKET23+QTY_BUCKET24+QTY_BUCKET25
                +QTY_BUCKET26), 6)  q_26,
            ROUND( sum(QTY_BUCKET1+QTY_BUCKET2+QTY_BUCKET3+QTY_BUCKET4+QTY_BUCKET5+QTY_BUCKET6+QTY_BUCKET7
                +QTY_BUCKET8+QTY_BUCKET9+QTY_BUCKET10+QTY_BUCKET11+QTY_BUCKET12+QTY_BUCKET13
                +QTY_BUCKET14+QTY_BUCKET15+QTY_BUCKET16+QTY_BUCKET17+QTY_BUCKET18+QTY_BUCKET19
                +QTY_BUCKET20+QTY_BUCKET21+QTY_BUCKET22+QTY_BUCKET23+QTY_BUCKET24+QTY_BUCKET25
                +QTY_BUCKET26+QTY_BUCKET27), 6)  q_27,
            ROUND( sum(QTY_BUCKET1+QTY_BUCKET2+QTY_BUCKET3+QTY_BUCKET4+QTY_BUCKET5+QTY_BUCKET6+QTY_BUCKET7
                +QTY_BUCKET8+QTY_BUCKET9+QTY_BUCKET10+QTY_BUCKET11+QTY_BUCKET12+QTY_BUCKET13
                +QTY_BUCKET14+QTY_BUCKET15+QTY_BUCKET16+QTY_BUCKET17+QTY_BUCKET18+QTY_BUCKET19
                +QTY_BUCKET20+QTY_BUCKET21+QTY_BUCKET22+QTY_BUCKET23+QTY_BUCKET24+QTY_BUCKET25
                +QTY_BUCKET26+QTY_BUCKET27+QTY_BUCKET28), 6)  q_28,
            ROUND( sum(QTY_BUCKET1+QTY_BUCKET2+QTY_BUCKET3+QTY_BUCKET4+QTY_BUCKET5+QTY_BUCKET6+QTY_BUCKET7
                +QTY_BUCKET8+QTY_BUCKET9+QTY_BUCKET10+QTY_BUCKET11+QTY_BUCKET12+QTY_BUCKET13
                +QTY_BUCKET14+QTY_BUCKET15+QTY_BUCKET16+QTY_BUCKET17+QTY_BUCKET18+QTY_BUCKET19
                +QTY_BUCKET20+QTY_BUCKET21+QTY_BUCKET22+QTY_BUCKET23+QTY_BUCKET24+QTY_BUCKET25
                +QTY_BUCKET26+QTY_BUCKET27+QTY_BUCKET28+QTY_BUCKET29), 6)  q_29,
            ROUND( sum(QTY_BUCKET1+QTY_BUCKET2+QTY_BUCKET3+QTY_BUCKET4+QTY_BUCKET5+QTY_BUCKET6+QTY_BUCKET7
                +QTY_BUCKET8+QTY_BUCKET9+QTY_BUCKET10+QTY_BUCKET11+QTY_BUCKET12+QTY_BUCKET13
                +QTY_BUCKET14+QTY_BUCKET15+QTY_BUCKET16+QTY_BUCKET17+QTY_BUCKET18+QTY_BUCKET19
                +QTY_BUCKET20+QTY_BUCKET21+QTY_BUCKET22+QTY_BUCKET23+QTY_BUCKET24+QTY_BUCKET25
                +QTY_BUCKET26+QTY_BUCKET27+QTY_BUCKET28+QTY_BUCKET29+QTY_BUCKET30), 6)  q_30,
            ROUND( sum(QTY_BUCKET1+QTY_BUCKET2+QTY_BUCKET3+QTY_BUCKET4+QTY_BUCKET5+QTY_BUCKET6+QTY_BUCKET7
                +QTY_BUCKET8+QTY_BUCKET9+QTY_BUCKET10+QTY_BUCKET11+QTY_BUCKET12+QTY_BUCKET13
                +QTY_BUCKET14+QTY_BUCKET15+QTY_BUCKET16+QTY_BUCKET17+QTY_BUCKET18+QTY_BUCKET19
                +QTY_BUCKET20+QTY_BUCKET21+QTY_BUCKET22+QTY_BUCKET23+QTY_BUCKET24+QTY_BUCKET25
                +QTY_BUCKET26+QTY_BUCKET27+QTY_BUCKET28+QTY_BUCKET29+QTY_BUCKET30+QTY_BUCKET31), 6)  q_31,
            ROUND( sum(QTY_BUCKET1+QTY_BUCKET2+QTY_BUCKET3+QTY_BUCKET4+QTY_BUCKET5+QTY_BUCKET6+QTY_BUCKET7
                +QTY_BUCKET8+QTY_BUCKET9+QTY_BUCKET10+QTY_BUCKET11+QTY_BUCKET12+QTY_BUCKET13
                +QTY_BUCKET14+QTY_BUCKET15+QTY_BUCKET16+QTY_BUCKET17+QTY_BUCKET18+QTY_BUCKET19
                +QTY_BUCKET20+QTY_BUCKET21+QTY_BUCKET22+QTY_BUCKET23+QTY_BUCKET24+QTY_BUCKET25
                +QTY_BUCKET26+QTY_BUCKET27+QTY_BUCKET28+QTY_BUCKET29+QTY_BUCKET30+QTY_BUCKET31
                +QTY_BUCKET32), 6)  q_32,
            ROUND( sum(QTY_BUCKET1+QTY_BUCKET2+QTY_BUCKET3+QTY_BUCKET4+QTY_BUCKET5+QTY_BUCKET6+QTY_BUCKET7
                +QTY_BUCKET8+QTY_BUCKET9+QTY_BUCKET10+QTY_BUCKET11+QTY_BUCKET12+QTY_BUCKET13
                +QTY_BUCKET14+QTY_BUCKET15+QTY_BUCKET16+QTY_BUCKET17+QTY_BUCKET18+QTY_BUCKET19
                +QTY_BUCKET20+QTY_BUCKET21+QTY_BUCKET22+QTY_BUCKET23+QTY_BUCKET24+QTY_BUCKET25
                +QTY_BUCKET26+QTY_BUCKET27+QTY_BUCKET28+QTY_BUCKET29+QTY_BUCKET30+QTY_BUCKET31
                +QTY_BUCKET32+QTY_BUCKET33), 6)  q_33,
            ROUND( sum(QTY_BUCKET1+QTY_BUCKET2+QTY_BUCKET3+QTY_BUCKET4+QTY_BUCKET5+QTY_BUCKET6+QTY_BUCKET7
                +QTY_BUCKET8+QTY_BUCKET9+QTY_BUCKET10+QTY_BUCKET11+QTY_BUCKET12+QTY_BUCKET13
                +QTY_BUCKET14+QTY_BUCKET15+QTY_BUCKET16+QTY_BUCKET17+QTY_BUCKET18+QTY_BUCKET19
                +QTY_BUCKET20+QTY_BUCKET21+QTY_BUCKET22+QTY_BUCKET23+QTY_BUCKET24+QTY_BUCKET25
                +QTY_BUCKET26+QTY_BUCKET27+QTY_BUCKET28+QTY_BUCKET29+QTY_BUCKET30+QTY_BUCKET31
                +QTY_BUCKET32+QTY_BUCKET33+QTY_BUCKET34), 6)  q_34,
            ROUND( sum(QTY_BUCKET1+QTY_BUCKET2+QTY_BUCKET3+QTY_BUCKET4+QTY_BUCKET5+QTY_BUCKET6+QTY_BUCKET7
                +QTY_BUCKET8+QTY_BUCKET9+QTY_BUCKET10+QTY_BUCKET11+QTY_BUCKET12+QTY_BUCKET13
                +QTY_BUCKET14+QTY_BUCKET15+QTY_BUCKET16+QTY_BUCKET17+QTY_BUCKET18+QTY_BUCKET19
                +QTY_BUCKET20+QTY_BUCKET21+QTY_BUCKET22+QTY_BUCKET23+QTY_BUCKET24+QTY_BUCKET25
                +QTY_BUCKET26+QTY_BUCKET27+QTY_BUCKET28+QTY_BUCKET29+QTY_BUCKET30+QTY_BUCKET31
                +QTY_BUCKET32+QTY_BUCKET33+QTY_BUCKET34+QTY_BUCKET35), 6)  q_35,
            ROUND( sum(QTY_BUCKET1+QTY_BUCKET2+QTY_BUCKET3+QTY_BUCKET4+QTY_BUCKET5+QTY_BUCKET6+QTY_BUCKET7
                +QTY_BUCKET8+QTY_BUCKET9+QTY_BUCKET10+QTY_BUCKET11+QTY_BUCKET12+QTY_BUCKET13
                +QTY_BUCKET14+QTY_BUCKET15+QTY_BUCKET16+QTY_BUCKET17+QTY_BUCKET18+QTY_BUCKET19
                +QTY_BUCKET20+QTY_BUCKET21+QTY_BUCKET22+QTY_BUCKET23+QTY_BUCKET24+QTY_BUCKET25
                +QTY_BUCKET26+QTY_BUCKET27+QTY_BUCKET28+QTY_BUCKET29+QTY_BUCKET30+QTY_BUCKET31
                +QTY_BUCKET32+QTY_BUCKET33+QTY_BUCKET34+QTY_BUCKET35+QTY_BUCKET36), 6)  q_36
           FROM msc_hz_ui_lines
          WHERE ORDER_TYPE = nvl(arg_order_type,NOT_SELECTED)
            AND query_id = arg_query_id
         GROUP BY RELATION_GROUP, ORDER_RELATION_GROUP, FROM_COMPANY_NAME,FROM_ORG_CODE,ITEM_NAME,ITEM_DESCRIPTION,
                SUPPLIER_NAME,CUSTOMER_NAME,SUPPLIER_ORG_CODE,CUSTOMER_ORG_CODE,UOM,
                SUPPLIER_ID,CUSTOMER_ID,SUPPLIER_SITE_ID,CUSTOMER_SITE_ID,INVENTORY_ITEM_ID ;


      /**
       * The foll procedure gets the preference set if
       *    chosen by the user.
       * If the user has not chosen a specific preference st
       *    then the default preference set is picked
       * If no preference set is designated as default then
       *    default values are assigned.
       */
      PROCEDURE set_default_prefs IS
      BEGIN
         -- set the default buckets
         daily_bucket_count := 0;
         weekly_bucket_count := 15;
         period_bucket_count := 0;

         v_graphtype := 0;
         v_category := '';

         -- set default order types in the foll order PO, SO, Order Forecast, Supply Commit
         v_purchase_order := PURCHASE_ORDER;
         v_sales_order := SALES_ORDER;
         v_order_forecast := ORDER_FORECAST_CST;
         v_supply_commit := SUPPLY_COMMIT;

         v_o_po := 1;
         v_o_sales_orders := 2;
         v_o_forecast := 3;
         v_o_supply_commit := 4;

         -- set the aggregation
         myco_agg := COMPANY_AGG;
         tpco_agg := COMPANY_AGG;

         arg_default_pref := 1;

      END set_default_prefs;

  /**
    * Bug 4200004
    * The following function returns
    * the correct bucket qty based on teh order type.
    * @return number the qty.
    */


procedure calculate_bucket_qty_ss_pab(arg_flag in out NOCOPY boolean,
       arg_prev_publisher_site_id in out NOCOPY NUMBER,
       arg_qty in out NOCOPY number,
       arg_prev_temp in out NOCOPY number,
       arg_prev_temp_qty in out NOCOPY number,
       arg_prev_temp_order_type in out NOCOPY number)
is
var_return_qty number := 0 ;

begin

   --check for SS/PAB order type
   if(activity_rec.order_type = SAFETY_STOCK OR activity_rec.order_type = PROJ_AVAIL_BAL) then
    --check for pref set aggregation level
    if(myco_agg = ORG_AGG) then
     --if agg is by ind org
      --always show the last record
      arg_qty := activity_rec.new_quantity ;

    elsif(myco_agg = COMPANY_AGG) then
     --if agg is across the entire company

     --foll logic is added so that the last bucket records across the sites be added

     --check for the boolean flag
     --this is just to see if this is the first record for the bucket
     if(arg_flag ) then
      arg_prev_publisher_site_id := activity_rec.publisher_site_id;
      arg_prev_temp_qty := activity_rec.new_quantity ;
      arg_flag := false;
     end if;

     --additional logic -when the order type is changes, then initialize the variables.
     if(activity_rec.order_type <> arg_prev_temp_order_type) then
      arg_qty := 0;
      arg_prev_temp := 0;
      arg_prev_temp_qty := 0;

     end if;

     --if the org changes then store that quantity and add it to the previous bucket's last qty
     if(activity_rec.publisher_site_id <> arg_prev_publisher_site_id) then
      arg_prev_temp := arg_prev_temp +  arg_prev_temp_qty;
     end if;

     --this is the final qty
     --foll logic is there so as to take care of the cases where the qty record doesn't exist for a particular SS
     if(arg_prev_temp = -99999999 and activity_rec.new_quantity = -99999999) then
      arg_qty := -99999999;
     elsif(arg_prev_temp = -99999999 and activity_rec.new_quantity <> -99999999) then
      arg_qty := activity_rec.new_quantity ;
     elsif(arg_prev_temp <> -99999999 and arg_prev_temp <> 0 and activity_rec.new_quantity = -99999999) then
      arg_qty := arg_prev_temp ;
     else
      arg_qty := arg_prev_temp + activity_rec.new_quantity;
     end if;

     --temp variable to store the current qty
     arg_prev_temp_qty := activity_rec.new_quantity ;

    end if;

    --temp variable to store the current site
    arg_prev_publisher_site_id := activity_rec.publisher_site_id;

    arg_prev_temp_order_type := activity_rec.order_type;


   else
    --if the order type is neither SS nor PAB
    arg_qty := arg_qty + activity_rec.new_quantity;
   end if;


end calculate_bucket_qty_ss_pab;
      /**
       * get the user_preferences data for the user.
       * If a user preference is not defined
       * then use the system default
       * identified by sce_user_id = -1 and user_id = -1
       * and named_set = "MSCX_SYSTEM_PREFERENCE"
       * @param the preference set name
       History      BUG      BY        CHANGES
       07-July-2008 6893383  HBINJOLA  Added two new order type (Returns Forecast and Defective Outbound Shipment)
       */
      PROCEDURE get_user_prefs( v_pref_name IN VARCHAR2 -- DEFAULT NULL
                              ) IS

        CURSOR c_public_pref_set IS
            SELECT named_set, show_graph, category_name,
                   decode(summary_seller_forecast,'Y',SALES_FORECAST,NOT_SELECTED ),
                   decode(summary_forecast,'Y',ORDER_FORECAST_CST,NOT_SELECTED ),
                   decode(summary_allocated_supply,'Y',SUPPLY_COMMIT,NOT_SELECTED ),
                   decode(summary_returns_forecast,'Y',G_RETURNS_FORECAST,NOT_SELECTED ), --bug#6893383
                   decode(summary_def_outbound_shipment,'Y',G_DEFECTIVE_OUTBOUND_SHIPMENT,NOT_SELECTED ),--bug#6893383
                   decode(summary_hist_sales,'Y',HISTORICAL_SALES,NOT_SELECTED ),
                   decode(summary_sell_thro_fcst,'Y',SELL_THRU_FORECAST,NOT_SELECTED ),
                   decode(summary_suppcap,'Y',NEGOTIATED_CAPACITY,NOT_SELECTED ),
                   decode(summary_ss,'Y',SAFETY_STOCK,NOT_SELECTED ),
                   decode(summary_pab,'Y',PROJ_AVAIL_BAL,NOT_SELECTED ),
                   decode(summary_projected_ss,'Y',PROJ_SAFETY_STOCK,NOT_SELECTED ),
                   decode(summary_allocated_onhand,'Y',ALLOCATED_ONHAND,NOT_SELECTED ),
                   decode(summary_unallocated_onhand,'Y',UNALLOCATED_ONHAND,NOT_SELECTED ),
                   decode(summary_unalct_prjt_avl_bal,'Y',PROJ_UNALOC_AVL_BAL,NOT_SELECTED ),
                   decode(summary_alcat_prjt_avl_bal,'Y',PROJ_ALLOC_AVL_BAL,NOT_SELECTED ),
                   decode(summary_po,'Y',PURCHASE_ORDER,NOT_SELECTED ),
                   decode(summary_sales_orders,'Y',SALES_ORDER,NOT_SELECTED ),
                   decode(summary_asn,'Y',ASN,NOT_SELECTED ),
                   decode(summary_receiving,'Y',SHIPMENT_RECEIPT,NOT_SELECTED ),
                   decode(summary_transit,'Y',INTRANSIT,NOT_SELECTED ),
                   decode(summary_wip,'Y',WORK_ORDER,NOT_SELECTED ),
                   decode(summary_po_ack,'Y',PO_ACK,NOT_SELECTED ),
                   decode(summary_replenishment,'Y',REPLENISHMENT,NOT_SELECTED ),
                   decode(summary_req,'Y',REQUISITION,NOT_SELECTED ),
                   decode(summary_purchase_plan, 'Y' , PO_FROM_PLAN, NOT_SELECTED),
                   decode(summary_release_plan, 'Y', RELEASED_PLAN, NOT_SELECTED),
                   decode(summary_plan, 'Y', PLANNED_ORDER, NOT_SELECTED),
                   decode(running_total_supply,'Y',RUN_TOT_SUPPLY,NOT_SELECTED ),
                   decode(running_total_demand,'Y',RUN_TOT_DEMAND,NOT_SELECTED ),
                   ORDER_SELLER_FORECAST,ORDER_FORECAST,ORDER_ALLOCATED_SUPPLY,
                   RETURNS_FORECAST, DEF_OUTBOUND_SHIPMENT, --bug#6893383
                   ORDER_HIST_SALES,ORDER_SELL_THRO_FCST,ORDER_SUPPCAP,ORDER_SS, ORDER_PAB,
                   ORDER_PROJECTED_SS,ORDER_ALLOCATED_ONHAND,ORDER_UNALLOCATED_ONHAND,
                   ORDER_UNALCT_PRJT_AVL_BAL,ORDER_ALCAT_PRJT_AVL_BAL,ORDER_PO, ORDER_WIP, ORDER_PO_ACK,
                   ORDER_SALES_ORDERS,ORDER_ASN,ORDER_RECEIVING,ORDER_TRANSIT,
                   ORDER_WIP,ORDER_REPLENISHMENT,ORDER_REQ,ORDER_PURCHASE_PLAN,ORDER_RELEASE_PLAN, ORDER_PLAN,
                   ORDER_RUNNING_TOTAL_SUPPLY,ORDER_RUNNING_TOTAL_DEMAND,
                   NVL(prod_sum_level,ITEM_AGG),NVL(org_sum_level,COMPANY_AGG),
                   NVL(org_sum_level_tp,COMPANY_AGG),NVL(summary_display_days,NOT_SELECTED),
                   NVL(summary_display_weeks,NOT_SELECTED),
                   NVL(summary_display_periods,NOT_SELECTED)
                   , NVL(shift_days, 0)
                   , decode(net_forecast, 'Y', SELECTED, NOT_SELECTED)
                   , decode(total_supply, 'Y', SELECTED, NOT_SELECTED)
               FROM msc_workbench_display_options
               WHERE public_flag = 'Y'
               ORDER BY named_set ASC
               ;

        CURSOR c_private_pref_set IS
            SELECT named_set, show_graph, category_name,
                   decode(summary_seller_forecast,'Y',SALES_FORECAST,NOT_SELECTED ),
                   decode(summary_forecast,'Y',ORDER_FORECAST_CST,NOT_SELECTED ),
                   decode(summary_allocated_supply,'Y',SUPPLY_COMMIT,NOT_SELECTED ),
                   decode(summary_returns_forecast,'Y',G_RETURNS_FORECAST,NOT_SELECTED ), --bug#6893383
                   decode(summary_def_outbound_shipment,'Y',G_DEFECTIVE_OUTBOUND_SHIPMENT,NOT_SELECTED ),--bug#6893383
                   decode(summary_hist_sales,'Y',HISTORICAL_SALES,NOT_SELECTED ),
                   decode(summary_sell_thro_fcst,'Y',SELL_THRU_FORECAST,NOT_SELECTED ),
                   decode(summary_suppcap,'Y',NEGOTIATED_CAPACITY,NOT_SELECTED ),
                   decode(summary_ss,'Y',SAFETY_STOCK,NOT_SELECTED ),
                   decode(summary_pab,'Y',PROJ_AVAIL_BAL,NOT_SELECTED ),
                   decode(summary_projected_ss,'Y',PROJ_SAFETY_STOCK,NOT_SELECTED ),
                   decode(summary_allocated_onhand,'Y',ALLOCATED_ONHAND,NOT_SELECTED ),
                   decode(summary_unallocated_onhand,'Y',UNALLOCATED_ONHAND,NOT_SELECTED ),
                   decode(summary_unalct_prjt_avl_bal,'Y',PROJ_UNALOC_AVL_BAL,NOT_SELECTED ),
                   decode(summary_alcat_prjt_avl_bal,'Y',PROJ_ALLOC_AVL_BAL,NOT_SELECTED ),
                   decode(summary_po,'Y',PURCHASE_ORDER,NOT_SELECTED ),
                   decode(summary_sales_orders,'Y',SALES_ORDER,NOT_SELECTED ),
                   decode(summary_asn,'Y',ASN,NOT_SELECTED ),
                   decode(summary_receiving,'Y',SHIPMENT_RECEIPT,NOT_SELECTED ),
                   decode(summary_transit,'Y',INTRANSIT,NOT_SELECTED ),
                   decode(summary_wip,'Y',WORK_ORDER,NOT_SELECTED ),
                   decode(summary_po_ack,'Y',PO_ACK,NOT_SELECTED ),
                   decode(summary_replenishment,'Y',REPLENISHMENT,NOT_SELECTED ),
                   decode(summary_req,'Y',REQUISITION,NOT_SELECTED ),
                   decode(summary_purchase_plan, 'Y' , PO_FROM_PLAN, NOT_SELECTED),
                   decode(summary_release_plan, 'Y', RELEASED_PLAN, NOT_SELECTED),
                   decode(summary_plan, 'Y', PLANNED_ORDER, NOT_SELECTED),
                   decode(running_total_supply,'Y',RUN_TOT_SUPPLY,NOT_SELECTED ),
                   decode(running_total_demand,'Y',RUN_TOT_DEMAND,NOT_SELECTED ),
                   ORDER_SELLER_FORECAST,ORDER_FORECAST,ORDER_ALLOCATED_SUPPLY,
                   RETURNS_FORECAST, DEF_OUTBOUND_SHIPMENT, --bug#6893383
                   ORDER_HIST_SALES,ORDER_SELL_THRO_FCST,ORDER_SUPPCAP,ORDER_SS, ORDER_PAB,
                   ORDER_PROJECTED_SS,ORDER_ALLOCATED_ONHAND,ORDER_UNALLOCATED_ONHAND,
                   ORDER_UNALCT_PRJT_AVL_BAL,ORDER_ALCAT_PRJT_AVL_BAL,ORDER_PO, ORDER_WIP, ORDER_PO_ACK,
                   ORDER_SALES_ORDERS,ORDER_ASN,ORDER_RECEIVING,ORDER_TRANSIT,
                   ORDER_WIP,ORDER_REPLENISHMENT,ORDER_REQ,ORDER_PURCHASE_PLAN,ORDER_RELEASE_PLAN, ORDER_PLAN,
                   ORDER_RUNNING_TOTAL_SUPPLY,ORDER_RUNNING_TOTAL_DEMAND,
                   NVL(prod_sum_level,ITEM_AGG),NVL(org_sum_level,COMPANY_AGG),
                   NVL(org_sum_level_tp,COMPANY_AGG),NVL(summary_display_days,NOT_SELECTED),
                   NVL(summary_display_weeks,NOT_SELECTED),
                   NVL(summary_display_periods,NOT_SELECTED)
                   , NVL(shift_days, 0)
                   , decode(net_forecast, 'Y', SELECTED, NOT_SELECTED)
                   , decode(total_supply, 'Y', SELECTED, NOT_SELECTED)
               FROM msc_workbench_display_options
               WHERE NVL(public_flag, 'N') <> 'Y'
               AND NVL(default_set, 'N') <> 'Y'
               ORDER BY named_set ASC
               ;

      BEGIN
         arg_default_pref := 0;

       BEGIN
         if v_pref_name is not null then
            SELECT named_set, show_graph, category_name,
                   decode(summary_seller_forecast,'Y',SALES_FORECAST,NOT_SELECTED ),
                   decode(summary_forecast,'Y',ORDER_FORECAST_CST,NOT_SELECTED ),
                   decode(summary_allocated_supply,'Y',SUPPLY_COMMIT,NOT_SELECTED ),
                   decode(summary_returns_forecast,'Y',G_RETURNS_FORECAST,NOT_SELECTED ), --bug#6893383
                   decode(summary_def_outbound_shipment,'Y',G_DEFECTIVE_OUTBOUND_SHIPMENT,NOT_SELECTED ),--bug#6893383
                   decode(summary_hist_sales,'Y',HISTORICAL_SALES,NOT_SELECTED ),
                   decode(summary_sell_thro_fcst,'Y',SELL_THRU_FORECAST,NOT_SELECTED ),
                   decode(summary_suppcap,'Y',NEGOTIATED_CAPACITY,NOT_SELECTED ),
                   decode(summary_ss,'Y',SAFETY_STOCK,NOT_SELECTED ),
                   decode(summary_pab,'Y',PROJ_AVAIL_BAL,NOT_SELECTED ),
                   decode(summary_projected_ss,'Y',PROJ_SAFETY_STOCK,NOT_SELECTED ),
                   decode(summary_allocated_onhand,'Y',ALLOCATED_ONHAND,NOT_SELECTED ),
                   decode(summary_unallocated_onhand,'Y',UNALLOCATED_ONHAND,NOT_SELECTED ),
                   decode(summary_unalct_prjt_avl_bal,'Y',PROJ_UNALOC_AVL_BAL,NOT_SELECTED ),
                   decode(summary_alcat_prjt_avl_bal,'Y',PROJ_ALLOC_AVL_BAL,NOT_SELECTED ),
                   decode(summary_po,'Y',PURCHASE_ORDER,NOT_SELECTED ),
                   decode(summary_sales_orders,'Y',SALES_ORDER,NOT_SELECTED ),
                   decode(summary_asn,'Y',ASN,NOT_SELECTED ),
                   decode(summary_receiving,'Y',SHIPMENT_RECEIPT,NOT_SELECTED ),
                   decode(summary_transit,'Y',INTRANSIT,NOT_SELECTED ),
                   decode(summary_wip,'Y',WORK_ORDER,NOT_SELECTED ),
                   decode(summary_po_ack,'Y',PO_ACK,NOT_SELECTED ),
                   decode(summary_replenishment,'Y',REPLENISHMENT,NOT_SELECTED ),
                   decode(summary_req,'Y',REQUISITION,NOT_SELECTED ),
                   decode(summary_purchase_plan, 'Y' , PO_FROM_PLAN, NOT_SELECTED),
                   decode(summary_release_plan, 'Y', RELEASED_PLAN, NOT_SELECTED),
                   decode(summary_plan, 'Y', PLANNED_ORDER, NOT_SELECTED),
                   decode(running_total_supply,'Y',RUN_TOT_SUPPLY,NOT_SELECTED ),
                   decode(running_total_demand,'Y',RUN_TOT_DEMAND,NOT_SELECTED ),
                   ORDER_SELLER_FORECAST,ORDER_FORECAST,ORDER_ALLOCATED_SUPPLY,
                   RETURNS_FORECAST, DEF_OUTBOUND_SHIPMENT, --bug#6893383
                   ORDER_HIST_SALES,ORDER_SELL_THRO_FCST,ORDER_SUPPCAP,ORDER_SS, ORDER_PAB,
                   ORDER_PROJECTED_SS,ORDER_ALLOCATED_ONHAND,ORDER_UNALLOCATED_ONHAND,
                   ORDER_UNALCT_PRJT_AVL_BAL,ORDER_ALCAT_PRJT_AVL_BAL,ORDER_PO, ORDER_WIP, ORDER_PO_ACK,
                   ORDER_SALES_ORDERS,ORDER_ASN,ORDER_RECEIVING,ORDER_TRANSIT,
                   ORDER_WIP,ORDER_REPLENISHMENT,ORDER_REQ,ORDER_PURCHASE_PLAN,ORDER_RELEASE_PLAN, ORDER_PLAN,
                   ORDER_RUNNING_TOTAL_SUPPLY,ORDER_RUNNING_TOTAL_DEMAND,
                   NVL(prod_sum_level,ITEM_AGG),NVL(org_sum_level,COMPANY_AGG),
                   NVL(org_sum_level_tp,COMPANY_AGG),NVL(summary_display_days,NOT_SELECTED),
                   NVL(summary_display_weeks,NOT_SELECTED),
                   NVL(summary_display_periods,NOT_SELECTED)
                   , NVL(shift_days, 0)
                   , decode(net_forecast, 'Y', SELECTED, NOT_SELECTED)
                   , decode(total_supply, 'Y', SELECTED, NOT_SELECTED)
              INTO v_pref, v_graphtype, v_category, v_sales_forecast,
                   v_order_forecast, v_supply_commit,v_returns_forecast,v_def_outbound_shipment, -- bug#6893383
                   v_hist_sales,v_sell_thru_fcst, v_negotiated_capacity, v_safety_stock,v_proj_avail_bal,
                   v_proj_safety_stock,v_alloc_onhand, v_unalloc_onhand, v_proj_unalloc_avl_bal,
                   v_proj_alloc_avl_bal,v_purchase_order, v_sales_order,v_asn,
                   v_shipment_receipt, v_intransit,v_work_order, v_po_ack, v_replenishment,
                   v_requisition, v_po_from_plan, v_released_plan, v_planned_order, v_run_tot_supply, v_run_tot_demand,
                   v_o_seller_forecast,v_o_forecast,v_o_supply_commit,
                   v_o_returns_forecast,v_o_def_outbound_shipment, -- bug#6893383
                   v_o_hist_sales,v_o_sell_thro_fcst,v_o_negcap,v_o_ss,v_o_pab,
                   v_o_projected_ss,v_o_alct_onhand,v_o_unalct_onhand,
                   v_o_unalct_prjt_avl_bal,v_o_alcat_prjt_avl_bal,v_o_po, v_o_work_order, v_o_po_ack,
                   v_o_sales_orders,v_o_asn,v_o_receiving,v_o_transit,
                   v_o_wip,v_o_replenishment,v_o_req,v_o_po_from_plan, v_o_released_plan, v_o_planned_order,
                   v_o_run_tot_supply,v_o_run_tot_demand,
                   prod_agg,myco_agg,tpco_agg,daily_bucket_count,weekly_bucket_count,
                   period_bucket_count
                   , v_shift_days
                   , v_net_forecast
                   , v_total_supply
              FROM msc_workbench_display_options
             WHERE rtrim(ltrim(named_set)) = rtrim(ltrim(v_pref_name))
               AND rownum < 2
               AND ( SCE_USER_ID = FND_GLOBAL.user_id
                   OR PUBLIC_FLAG = 'Y' )
                   ;

         else
         SELECT named_set, show_graph, category_name,
                   decode(summary_seller_forecast,'Y',SALES_FORECAST,NOT_SELECTED ),
                   decode(summary_forecast,'Y',ORDER_FORECAST_CST,NOT_SELECTED ),
                   decode(summary_allocated_supply,'Y',SUPPLY_COMMIT,NOT_SELECTED ),
                   decode(summary_returns_forecast,'Y',G_RETURNS_FORECAST,NOT_SELECTED ), --bug#6893383
                   decode(summary_def_outbound_shipment,'Y',G_DEFECTIVE_OUTBOUND_SHIPMENT,NOT_SELECTED ),--bug#6893383
                   decode(summary_hist_sales,'Y',HISTORICAL_SALES,NOT_SELECTED ),
                   decode(summary_sell_thro_fcst,'Y',SELL_THRU_FORECAST,NOT_SELECTED ),
                   decode(summary_suppcap,'Y',NEGOTIATED_CAPACITY,NOT_SELECTED ),
                   decode(summary_ss,'Y',SAFETY_STOCK,NOT_SELECTED ),
                   decode(summary_pab,'Y',PROJ_AVAIL_BAL,NOT_SELECTED ),
                   decode(summary_projected_ss,'Y',PROJ_SAFETY_STOCK,NOT_SELECTED ),
                   decode(summary_allocated_onhand,'Y',ALLOCATED_ONHAND,NOT_SELECTED ),
                   decode(summary_unallocated_onhand,'Y',UNALLOCATED_ONHAND,NOT_SELECTED ),
                   decode(summary_unalct_prjt_avl_bal,'Y',PROJ_UNALOC_AVL_BAL,NOT_SELECTED ),
                   decode(summary_alcat_prjt_avl_bal,'Y',PROJ_ALLOC_AVL_BAL,NOT_SELECTED ),
                   decode(summary_po,'Y',PURCHASE_ORDER,NOT_SELECTED ),
                   decode(summary_sales_orders,'Y',SALES_ORDER,NOT_SELECTED ),
                   decode(summary_asn,'Y',ASN,NOT_SELECTED ),
                   decode(summary_receiving,'Y',SHIPMENT_RECEIPT,NOT_SELECTED ),
                   decode(summary_transit,'Y',INTRANSIT,NOT_SELECTED ),
                   decode(summary_wip,'Y',WORK_ORDER,NOT_SELECTED ),
                   decode(summary_po_ack,'Y',PO_ACK,NOT_SELECTED ),
                   decode(summary_replenishment,'Y',REPLENISHMENT,NOT_SELECTED ),
                   decode(summary_req,'Y',REQUISITION,NOT_SELECTED ),
                   decode(summary_purchase_plan, 'Y' , PO_FROM_PLAN, NOT_SELECTED),
                   decode(summary_release_plan, 'Y', RELEASED_PLAN, NOT_SELECTED),
                   decode(summary_plan, 'Y', PLANNED_ORDER, NOT_SELECTED),
                   decode(running_total_supply,'Y',RUN_TOT_SUPPLY,NOT_SELECTED ),
                   decode(running_total_demand,'Y',RUN_TOT_DEMAND,NOT_SELECTED ),
                   ORDER_SELLER_FORECAST,ORDER_FORECAST,ORDER_ALLOCATED_SUPPLY,
                   RETURNS_FORECAST, DEF_OUTBOUND_SHIPMENT, --bug#6893383
                   ORDER_HIST_SALES,ORDER_SELL_THRO_FCST,ORDER_SUPPCAP,ORDER_SS, ORDER_PAB,
                   ORDER_PROJECTED_SS,ORDER_ALLOCATED_ONHAND,ORDER_UNALLOCATED_ONHAND,
                   ORDER_UNALCT_PRJT_AVL_BAL,ORDER_ALCAT_PRJT_AVL_BAL,ORDER_PO, ORDER_WIP, ORDER_PO_ACK,
                   ORDER_SALES_ORDERS,ORDER_ASN,ORDER_RECEIVING,ORDER_TRANSIT,
                   ORDER_WIP,ORDER_REPLENISHMENT,ORDER_REQ,ORDER_PURCHASE_PLAN,ORDER_RELEASE_PLAN, ORDER_PLAN,
                   ORDER_RUNNING_TOTAL_SUPPLY,ORDER_RUNNING_TOTAL_DEMAND,
                   NVL(prod_sum_level,ITEM_AGG),NVL(org_sum_level,COMPANY_AGG),
                   NVL(org_sum_level_tp,COMPANY_AGG),NVL(summary_display_days,NOT_SELECTED),
                   NVL(summary_display_weeks,NOT_SELECTED),
                   NVL(summary_display_periods,NOT_SELECTED)
                   , NVL(shift_days, 0)
                   , decode(net_forecast, 'Y', SELECTED, NOT_SELECTED)
                   , decode(total_supply, 'Y', SELECTED, NOT_SELECTED)
              INTO v_pref, v_graphtype, v_category,v_sales_forecast,
                   v_order_forecast, v_supply_commit,v_returns_forecast,v_def_outbound_shipment, -- bug#6893383
                   v_hist_sales,v_sell_thru_fcst, v_negotiated_capacity, v_safety_stock,v_proj_avail_bal,
                   v_proj_safety_stock,v_alloc_onhand, v_unalloc_onhand, v_proj_unalloc_avl_bal,
                   v_proj_alloc_avl_bal,v_purchase_order, v_sales_order,v_asn,
                   v_shipment_receipt, v_intransit,v_work_order, v_po_ack, v_replenishment,
                   v_requisition,v_po_from_plan, v_released_plan, v_planned_order, v_run_tot_supply, v_run_tot_demand,
                   v_o_seller_forecast,v_o_forecast,v_o_supply_commit,
                   v_o_returns_forecast,v_o_def_outbound_shipment, -- bug#6893383
                   v_o_hist_sales,v_o_sell_thro_fcst,v_o_negcap,v_o_ss, v_o_pab,
                   v_o_projected_ss,v_o_alct_onhand,v_o_unalct_onhand,
                   v_o_unalct_prjt_avl_bal,v_o_alcat_prjt_avl_bal,v_o_po, v_o_work_order, v_o_po_ack,
                   v_o_sales_orders,v_o_asn,v_o_receiving,v_o_transit,
                   v_o_wip,v_o_replenishment,v_o_req,v_o_po_from_plan, v_o_released_plan, v_o_planned_order,
                   v_o_run_tot_supply,v_o_run_tot_demand,
                   prod_agg,myco_agg,tpco_agg,daily_bucket_count,weekly_bucket_count,
                   period_bucket_count
                   , v_shift_days
                   , v_net_forecast
                   , v_total_supply
              FROM msc_workbench_display_options
             WHERE upper(default_set) = 'Y'
               AND rownum < 2
               AND SCE_USER_ID = FND_GLOBAL.user_id ;
       end if;
       EXCEPTION
         WHEN no_data_found THEN
         if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module || 'get_user_prefs','No preference set found');
         end if;
            -- v_pref := null;
            -- set_default_prefs;
       END;
         IF v_pref is null OR SQL%NOTFOUND then

            OPEN c_public_pref_set;
              FETCH c_public_pref_set
              INTO v_pref, v_graphtype, v_category,
                   v_sales_forecast, v_order_forecast,v_supply_commit,v_returns_forecast,v_def_outbound_shipment, -- bug#6893383
                   v_hist_sales,v_sell_thru_fcst, v_negotiated_capacity, v_safety_stock,v_proj_avail_bal,
                   v_proj_safety_stock,v_alloc_onhand, v_unalloc_onhand, v_proj_unalloc_avl_bal,
                   v_proj_alloc_avl_bal,v_purchase_order, v_sales_order,v_asn,
                   v_shipment_receipt, v_intransit,v_work_order, v_po_ack, v_replenishment,
                   v_requisition,v_po_from_plan, v_released_plan, v_planned_order, v_run_tot_supply, v_run_tot_demand,
                   v_o_seller_forecast,v_o_forecast,v_o_supply_commit,
                   v_o_returns_forecast,v_o_def_outbound_shipment, -- bug#6893383
                   v_o_hist_sales,v_o_sell_thro_fcst,v_o_negcap,v_o_ss, v_o_pab,
                   v_o_projected_ss,v_o_alct_onhand,v_o_unalct_onhand,
                   v_o_unalct_prjt_avl_bal,v_o_alcat_prjt_avl_bal,v_o_po, v_o_work_order, v_o_po_ack,
                   v_o_sales_orders,v_o_asn,v_o_receiving,v_o_transit,
                   v_o_wip,v_o_replenishment,v_o_req,v_o_po_from_plan, v_o_released_plan, v_o_planned_order,
                   v_o_run_tot_supply,v_o_run_tot_demand,
                   prod_agg,myco_agg,tpco_agg,daily_bucket_count,weekly_bucket_count,
                   period_bucket_count
                   , v_shift_days
                   , v_net_forecast
                   , v_total_supply
                   ;

            IF (c_public_pref_set%NOTFOUND) THEN
              OPEN c_private_pref_set;
              FETCH c_private_pref_set
              INTO v_pref, v_graphtype, v_category,
                   v_sales_forecast, v_order_forecast, v_supply_commit,v_returns_forecast,v_def_outbound_shipment, -- bug#6893383
                   v_hist_sales,v_sell_thru_fcst, v_negotiated_capacity, v_safety_stock,v_proj_avail_bal,
                   v_proj_safety_stock,v_alloc_onhand, v_unalloc_onhand, v_proj_unalloc_avl_bal,
                   v_proj_alloc_avl_bal,v_purchase_order, v_sales_order,v_asn,
                   v_shipment_receipt, v_intransit,v_work_order, v_po_ack, v_replenishment,
                   v_requisition, v_po_from_plan, v_released_plan, v_planned_order, v_run_tot_supply, v_run_tot_demand,
                   v_o_seller_forecast,v_o_forecast,v_o_supply_commit,
                   v_o_returns_forecast,v_o_def_outbound_shipment, -- bug#6893383
                   v_o_hist_sales,v_o_sell_thro_fcst,v_o_negcap,v_o_ss, v_o_pab,
                   v_o_projected_ss,v_o_alct_onhand,v_o_unalct_onhand,
                   v_o_unalct_prjt_avl_bal,v_o_alcat_prjt_avl_bal,v_o_po, v_o_work_order, v_o_po_ack,
                   v_o_sales_orders,v_o_asn,v_o_receiving,v_o_transit,
                   v_o_wip,v_o_replenishment,v_o_req, v_o_po_from_plan, v_o_released_plan, v_o_planned_order,
                   v_o_run_tot_supply,v_o_run_tot_demand,
                   prod_agg,myco_agg,tpco_agg,daily_bucket_count,weekly_bucket_count,
                   period_bucket_count
                   , v_shift_days
                   , v_net_forecast
                   , v_total_supply
                   ;

              IF (c_private_pref_set%NOTFOUND) THEN
                set_default_prefs ;
              END IF;
              CLOSE c_private_pref_set;
            END IF;

            CLOSE c_public_pref_set;

         END IF;


      EXCEPTION
         when no_data_found then
            if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
             FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module || 'get_user_prefs','No preference set found');
            end if;
            v_pref := null;
            set_default_prefs;

         when others then
            if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
             FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module || 'get_user_prefs',' Other ' || SQLERRM);
            end if;
            v_pref := null;
            set_default_prefs;


      END get_user_prefs;


      /**
       * The following procedure sets the calendar code to be used
       * while calculating the bucket dates
       * @param the start date.
       */
      PROCEDURE get_bucket_dates(arg_start_date IN DATE,
                    p_cal_code IN VARCHAR2
                   ) IS

      DAY_BUCKET_FOUND boolean;
      WEEK_BUCKET_FOUND boolean;
      MONTH_BUCKET_FOUND boolean;
      v_cal_code VARCHAR2(14) := p_cal_code;
      daily_bucket_dates calendar_date;
      weekly_bucket_dates calendar_date;
      monthly_bucket_dates calendar_date;
      v_temp_bucket_start_date date;
      v_month_bkt_start_date date;
      counter INTEGER := 0;

      v_temp_date date;
      k INTEGER := 0;


      BEGIN

       -- initialize the dates array.
       for k in 1..36 loop
      var_dates(k) := null;
    end loop;

        /** if user entered a start date, use it
       * set the start date
       */

         IF arg_start_date IS NULL THEN
            if daily_bucket_count <> 0 then  -- from the user prefs
                p_start_date := trunc(sysdate) + v_shift_days;
            elsif weekly_bucket_count <> 0 then
                select week_start_date into p_start_date
                from msc_cal_week_start_dates
        where calendar_code = v_cal_code
        and exception_set_id = -1
        and week_start_date <= SYSDATE + v_shift_days
        and next_date > SYSDATE + v_shift_days;
      else -- period_bucket_count
        select period_start_date into p_start_date
        from msc_period_start_dates
        where calendar_code = v_cal_code
        and exception_set_id = -1
        and period_start_date <= SYSDATE + v_shift_days
        and next_date > SYSDATE + v_shift_days;
            end if;

         ELSE
            p_start_date := trunc(arg_start_date) + v_shift_days;
         END IF;


    /**
    * get the daily buckets
    * the fist bucket is the start date or the sysdate
    * if the last daily bucket falls in the middle of a week
    * then get additional daily buckets until the start of
    * next weekly or monthly bucket.
     */
     v_temp_date := p_start_date;
    IF (daily_bucket_count <> 0 ) THEN
     IF (weekly_bucket_count <> 0 ) THEN
      SELECT
         day.calendar_date
      BULK COLLECT INTO
         daily_bucket_dates
      FROM msc_calendar_dates day, msc_cal_week_start_dates week
      WHERE day.calendar_code = v_cal_code
      and day.exception_set_id = -1
      and day.calendar_date >= p_start_date
      and day.calendar_date < week.next_date
      and week.calendar_code = v_cal_code
      and week.exception_set_id = -1
      and week.week_start_date <=  p_start_date + daily_bucket_count - 1
      and week.next_date > p_start_date + daily_bucket_count - 1
      order by day.calendar_date asc;

      daily_bucket_count := daily_bucket_dates.COUNT;

     ELSIF (period_bucket_count <> 0) THEN
      SELECT
       day.calendar_date
      BULK COLLECT INTO
       daily_bucket_dates
      FROM msc_calendar_dates day, msc_period_start_dates month
      WHERE day.calendar_code = v_cal_code
      and day.exception_set_id = -1
      and day.calendar_date >= p_start_date
      and day.calendar_date < month.next_date
      and month.calendar_code = v_cal_code
      and month.exception_set_id = -1
      and month.period_start_date <=  p_start_date + daily_bucket_count - 1
      and month.next_date > p_start_date + daily_bucket_count - 1
      order by day.calendar_date asc;

      daily_bucket_count := daily_bucket_dates.COUNT;

     ELSE
      SELECT
       calendar_date
      BULK COLLECT INTO
       daily_bucket_dates
      FROM msc_calendar_dates
      WHERE calendar_code = v_cal_code
      and exception_set_id = -1
      and calendar_date >= p_start_date
      and calendar_date < p_start_date + daily_bucket_count
      order by calendar_date asc;
     END IF;
     v_temp_date := daily_bucket_dates(daily_bucket_dates.COUNT);
    END IF;

    /**
    * get the weekly buckets.
    * simple case - days buckets found and added.
    * next case -- no day buckets then
    *      start date is sysdate or arg_start_Date
    *      this has to be the first bucket
    *      and then get each bucket + the number of buckets needed
    *    for padding until the next monthly bucket.
    */

    IF (weekly_bucket_count <> 0 ) THEN
     IF (period_bucket_count <> 0) THEN
      IF (daily_bucket_count <> 0 ) THEN
       SELECT
          week.week_start_date
       BULK COLLECT INTO
          weekly_bucket_dates
       FROM msc_cal_week_start_dates week, msc_period_start_dates month
       WHERE week.calendar_code = v_cal_code
       and week.exception_set_id = -1
       and week.week_start_date >= v_temp_date
       and week.week_start_date < month.next_date
       and month.calendar_code = v_cal_code
       and month.exception_set_id = -1
       and month.period_start_date <= v_temp_date + 7*weekly_bucket_count
       and month.next_date > v_temp_date + 7*weekly_bucket_count
       order by week.week_start_date asc;

       weekly_bucket_count := weekly_bucket_dates.COUNT;
      ELSE
       SELECT week.week_start_date into v_temp_bucket_start_date
       from msc_cal_week_start_dates week
       where week.calendar_code = v_cal_code
       and week.exception_set_id = -1
       and week.week_start_date <= p_start_date
       and week.next_date > p_start_date
       order by week.week_start_date asc;

       SELECT
          week.week_start_date
       BULK COLLECT INTO
          weekly_bucket_dates
       FROM msc_cal_week_start_dates week, msc_period_start_dates month
       WHERE week.calendar_code = v_cal_code
       and week.exception_set_id = -1
       and week.next_date > v_temp_bucket_start_date
       and month.calendar_code = v_cal_code
       and month.exception_set_id = -1
       and month.period_start_date < v_temp_bucket_start_date + 7*weekly_bucket_count
       and month.next_date >= v_temp_bucket_start_date + 7*weekly_bucket_count
       and week.week_start_date < month.next_date
       order by week.week_start_date asc;

       weekly_bucket_count := weekly_bucket_dates.COUNT;
      END IF;
     ELSE
      IF (daily_bucket_count <> 0) THEN
       SELECT
          week_start_date
       BULK COLLECT INTO
          weekly_bucket_dates
       FROM msc_cal_week_start_dates
       WHERE calendar_code = v_cal_code
       and exception_set_id = -1
       and week_start_date > v_temp_date
       and week_start_date <= v_temp_date + 7*weekly_bucket_count
       order by week_start_date asc;
      ELSE
       SELECT
          week_start_date
       BULK COLLECT INTO
          weekly_bucket_dates
       FROM msc_cal_week_start_dates
       WHERE calendar_code = v_cal_code
       and exception_set_id = -1
       and next_date > p_start_date
       and next_date <= p_start_date + 7*weekly_bucket_count
       order by week_start_date asc;
      END IF;
     END IF;
    END IF;

    IF (daily_bucket_count > 36) THEN
     daily_bucket_count := 36;
     weekly_bucket_count := 0;
     period_bucket_count := 0;
    ELSE
     IF (daily_bucket_count + weekly_bucket_count > 36) THEN
      weekly_bucket_count := 36 - daily_bucket_count;
      period_bucket_count := 0;
     ELSE
      IF (daily_bucket_count + weekly_bucket_count + period_bucket_count > 36) THEN
       period_bucket_count := 36 - weekly_bucket_count - daily_bucket_count;
      END IF;
     END IF;
    END IF;


    /**
    * get the monthly buckets.
    * simple case - days buckets found or week_buckets found and added.
    * next case -- no day buckets or week buckets then
    *      start date is sysdate or arg_start_Date
    *      this has to be the first bucket
    *      and then add 1 calendar month for each bucket thereafter for # of monthly buckets.
    */

    IF (period_bucket_count <> 0) THEN

     IF (weekly_bucket_count <> 0) THEN
      v_month_bkt_start_date := weekly_bucket_dates(weekly_bucket_count) + 7;
     ELSIF (daily_bucket_count <> 0) THEN
      v_month_bkt_start_date := daily_bucket_dates(daily_bucket_count) + 1;
     ELSE
      select month.period_start_date into v_month_bkt_start_date
      from msc_period_start_dates month
      where month.calendar_code = v_cal_code
      and month.exception_set_id = -1
      and month.period_start_date <= p_start_date
      and month.next_date > p_start_date
      order by month.period_start_date asc;
     END IF;

     select period_start_date
     BULK COLLECT INTO
          monthly_bucket_dates
     from msc_period_start_dates
     where calendar_code = v_cal_code
     and exception_set_id = -1
     and level <= period_bucket_count
     start with period_start_date <= v_month_bkt_start_date
     and next_date > v_month_bkt_start_date
     connect by (
     PRIOR calendar_code = calendar_code
     and PRIOR exception_set_id = exception_set_id
     and PRIOR sr_instance_id = sr_instance_id
     and PRIOR next_date = period_start_date
     and PRIOR period_start_date < period_start_date
     )
     order by period_start_date asc;
    END IF;

    counter := 0;

    if daily_bucket_count = 0 then  -- from the user prefs
            DAY_BUCKET_FOUND := FALSE ;
        else
         FOR i IN 1..daily_bucket_count LOOP
          counter := counter + 1;
         var_dates(counter) := daily_bucket_dates(i);
         if counter > 36 then
       exit;
            end if;
         END LOOP;
        end if;

    if counter > 36 then
     v_last_bkt_date := var_dates(37);
          return;
        end if;

         if weekly_bucket_count = 0 then
            WEEK_BUCKET_FOUND := FALSE;
         else
            FOR i IN 1..weekly_bucket_count LOOP
        counter := counter + 1;
        var_dates(counter) := weekly_bucket_dates(i);
        if counter > 36 then
        exit;
        end if;
            END LOOP;
         end if;

         if counter > 36 then
            v_last_bkt_date := var_dates(37);
            return;
         end if;


    if period_bucket_count = 0 then
     MONTH_BUCKET_FOUND := FALSE;
    else
     FOR i IN 1..period_bucket_count LOOP
      counter := counter + 1;
      var_dates(counter) := monthly_bucket_dates(i);
      if counter > 36 then
       exit;
      end if;
     END LOOP;
    end if;

    if counter = 0 then
     v_last_bkt_date := p_start_date;
    else
     v_last_bkt_date := var_dates(counter);
    end if;


    if period_bucket_count = 0 then
     if weekly_bucket_count = 0 then
       v_last_bkt_date := v_last_bkt_date + 1;
     else
       v_last_bkt_date := v_last_bkt_date + 7;
     end if;
    else
     select next_date into v_last_bkt_date
     from msc_period_start_dates
     where calendar_code = v_cal_code
     and exception_set_id = -1
     and period_start_date = var_dates(counter);
    end if;

       g_num_of_buckets := least(counter,36) ;

      Exception
         when NO_DATA_FOUND then
            arg_err_msg := arg_err_msg || ' Bkt gen' || SQLERRM;
            if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
             FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module || 'get_bucket_dates',' Bkt gen ' || SQLERRM);
            end if;

            return ;

      END get_bucket_dates;

   /**
    * The following function checks to see
    * if multiple sites were found in the horizon.
    * The bucket dates are already populated with default calendar.
    * @return number 1 for multiple sites and 0 for single site.
    */
   Function check_for_multiple_sites(v_order IN NUMBER) RETURN NUMBER
   IS
     l_statement VARCHAR2(4000);
     l_sel_count VARCHAR2(100);
     l_sel_cust_site VARCHAR2(100);
     l_sel_sup_site VARCHAR2(100);
     l_orders    VARCHAR2(50);

     l_date      VARCHAR2(20) := to_char(trunc(nvl(arg_from_date, p_start_date)),'MM-DD-YYYY');
     l_last      VARCHAR2(20) := to_char(trunc(nvl(v_last_bkt_date, sysdate)), 'MM-DD-YYYY');
     l_cust_count NUMBER := 0;
     l_sup_count NUMBER := 0;
     l_multiple_sites NUMBER := 1;



   BEGIN

    l_orders := v_sales_forecast || ',' || v_order_forecast || ',' || v_supply_commit ;
    l_orders := l_orders || ',' || v_returns_forecast ||',' || v_def_outbound_shipment ; -- bug#6893383
    l_orders := l_orders || ',' || v_hist_sales || ',' || v_sell_thru_fcst || ',' || v_negotiated_capacity ;
    l_orders := l_orders || ',' || v_safety_stock || ',' || v_proj_avail_bal || ',' || v_proj_safety_stock ;
    l_orders := l_orders || ',' || v_alloc_onhand || ',' || v_unalloc_onhand ;
    l_orders := l_orders || ',' || v_proj_unalloc_avl_bal || ',' || v_proj_alloc_avl_bal ;
    l_orders := l_orders || ',' || v_purchase_order || ',' || v_sales_order || ',' || v_asn ;
    l_orders := l_orders || ',' || v_shipment_receipt || ',' || v_intransit || ',' || v_work_order ;
    l_orders := l_orders || ',' || v_replenishment || ',' || v_requisition ;

    l_sel_count   := ' SELECT COUNT(distinct customer_site_id), COUNT(distinct supplier_site_id) ';
    l_sel_cust_site := ' SELECT distinct customer_site_id, customer_id ';
    l_sel_sup_site  := ' SELECT distinct supplier_site_id, supplier_id ';
    l_statement    := ' FROM msc_sup_dem_entries_ui_v';
    l_statement     := l_statement || ' WHERE plan_id = -1 AND PUBLISHER_ORDER_TYPE IN (';
    l_statement     := l_statement || l_orders;
    l_statement     := l_statement || ') ' ;
    l_statement     := l_statement || ' AND NVL(KEY_DATE, SYSDATE + 99999) >= to_date(''' || l_date || ''', ''MM-DD-YYYY'') ';
    l_statement     := l_statement || ' AND NVL(KEY_DATE, SYSDATE - 99999) < to_date(''' || l_last || ''', ''MM-DD-YYYY'') ';

     if arg_where_clause is not null then
      -- here remove the reading clause from the arg where clause if it is OR

      if instr(arg_where_clause, 'OR') > 0 and instr(arg_where_clause, 'OR')  < 5 then
        l_statement := l_statement || ' AND (' || substr(arg_where_clause, instr(arg_where_clause, 'OR') + 2) || ')';
      else
        l_statement := l_statement || ' ' || arg_where_clause;
      end if;
     end if;

     OPEN osce_bucketed_plan FOR l_sel_count || l_statement;
     LOOP
      FETCH osce_bucketed_plan INTO
       l_cust_count, l_sup_count;
      EXIT WHEN osce_bucketed_plan%NOTFOUND;
     END LOOP;
     CLOSE osce_bucketed_plan;


     /** if the result set contains only one customer site
     *   get the customer id and customer site id
     *
     * else if the result set contains only one supplier site
     *   get the supplier id and supplier site id
     */

     IF l_cust_count = 1 THEN
     l_multiple_sites := 0;
     v_supplier_id := null;
     v_supplier_site_id := null;
     OPEN osce_bucketed_plan FOR l_sel_cust_site || l_statement || ' AND ROWNUM <= 1 ';
     LOOP
      FETCH osce_bucketed_plan INTO
       v_customer_site_id, v_customer_id;
      EXIT WHEN osce_bucketed_plan%NOTFOUND;
      END LOOP;
      CLOSE osce_bucketed_plan;
       IF l_sup_count = 1 THEN
     OPEN osce_bucketed_plan FOR l_sel_sup_site || l_statement || ' AND ROWNUM <= 1 ';
     LOOP
      FETCH osce_bucketed_plan INTO
       v_supplier_site_id, v_supplier_id;
      EXIT WHEN osce_bucketed_plan%NOTFOUND;
     END LOOP;
     CLOSE osce_bucketed_plan;
                                   END IF;

     ELSE
     l_multiple_sites := 1;
     v_supplier_id := null;
     v_supplier_site_id := null;
     v_customer_id := null;
     v_customer_site_id := null;
     END IF;

     return l_multiple_sites;

   EXCEPTION
     WHEN OTHERS THEN
      arg_err_msg := ' check_for_multiple_sites ' || SQLERRM || ' ' || l_statement;
      if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module || 'check_for_multiple_sites', SQLERRM);
      end if;
      raise;
   END check_for_multiple_sites  ;


      /*
       * The following procedure initializes the pl/sql tables
       * for a given counter.
       * This is called before adding a row into the PL/sql table
       * @param the counter.
       */
      PROCEDURE initialize(cnt IN NUMBER) IS

         k INTEGER := cnt;

      BEGIN
         var_qty1(k) := 0;
         var_qty2(k) := 0;
         var_qty3(k) := 0;
         var_qty4(k) := 0;
         var_qty5(k) := 0;
         var_qty6(k) := 0;
         var_qty7(k) := 0;
         var_qty8(k) := 0;
         var_qty9(k) := 0;
         var_qty10(k) := 0;
         var_qty11(k) := 0;
         var_qty12(k) := 0;
         var_qty13(k) := 0;
         var_qty14(k) := 0;
         var_qty15(k) := 0;
         var_qty16(k) := 0;
         var_qty17(k) := 0;
         var_qty18(k) := 0;
         var_qty19(k) := 0;
         var_qty20(k) := 0;
         var_qty21(k) := 0;
         var_qty22(k) := 0;
         var_qty23(k) := 0;
         var_qty24(k) := 0;
         var_qty25(k) := 0;
         var_qty26(k) := 0;
         var_qty27(k) := 0;
         var_qty28(k) := 0;
         var_qty29(k) := 0;
         var_qty30(k) := 0;
         var_qty31(k) := 0;
         var_qty32(k) := 0;
         var_qty33(k) := 0;
         var_qty34(k) := 0;
         var_qty35(k) := 0;
         var_qty36(k) := 0;
         var_qty_nobkt(k) := 0;
         var_past_due_qty(k) := 0;
         var_day_bkt(k) := 0;
         var_week_bkt(k) := 0;
         var_month_bkt(k) := 0;

         var_supplier_id(k) := '';
         var_customer_id(k) := '';
         var_supplier_site_id(k) := '';
         var_customer_site_id(k) := '';
         var_item_id(k) := -1;
         var_next_item(k) := -1;

         var_relation(k) := '';
         var_order_relation(k) := '';
         var_from_co_name(k) := '';
         var_from_org_name(k) := '';
         var_item_name(k) := '';
         var_item_name_desc(k) := '';
	 var_sup_item(k):='';
         var_uom(k) := '';
         var_order_desc(k) := '';
         var_supplier(k) := '' ;
         var_customer(k) := '';
         var_supplier_org(k) := '';
         var_customer_org(k) := '';
         var_edit_flag(k) := 0;

         IF temp_sup_site.COUNT > 0 THEN
            for k in temp_sup_site.FIRST..temp_sup_site.LAST loop
               temp_sup_site(k) := 0 ;
            end loop ;
         END IF;

         IF temp_cust_site.COUNT > 0 THEN
            for k in temp_cust_site.FIRST..temp_cust_site.LAST LOOP
               temp_cust_site(k) := 0;
            end loop;
         END IF;

         IF temp_sup.COUNT > 0 THEN
            for k in temp_sup.FIRST..temp_sup.LAST loop
               temp_sup(k) := 0;
            end loop;
         END IF;

         IF temp_cust.COUNT > 0 THEN
            for k in temp_cust.FIRST..temp_cust.LAST loop
               temp_cust(k) := 0 ;
            end loop;
         END IF;

      EXCEPTION
         when others then
            arg_err_msg := arg_err_msg || ' initialize ' || SQLERRM;
            if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
             FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module || 'initialize', SQLERRM);
            end if;
            raise ;
      END initialize ;


      /**
       * The following procedure sets the date buckets
       * into individual variables.
       * This is required to insert into the headers table.
       */
      PROCEDURE set_date_variables IS

         k INTEGER := 0;

      BEGIN
         if g_num_of_buckets < 36 then
            k := var_dates.COUNT;

            for k in (var_dates.COUNT+1)..36 loop

               var_dates(k) := null;

            end loop;
         end if;

      EXCEPTION
         when others then
            arg_err_msg := arg_err_msg || ' set dates ' || SQLERRM;
            if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
             FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module || 'set_date_variables', SQLERRM);
            end if;
            return ;
      END set_date_variables ;


      /**
       * The following procedure is for debug purposes
       * - prints the query to the screen.
       * NOTE: uncomment the --dbms_output and set serveroutput on
       *       before running this procedure.
       */
      PROCEDURE print_query IS
         j INTEGER := 1;
         v_query VARCHAR2(4000) ;

      BEGIN
         while j < length(g_statement) loop
            v_query := v_query || substr(g_statement,j,200) ;
            --dbms_output.put_line(substr(g_statement,j,200));
            j := j+ 200;
         end loop;

      EXCEPTION
         when others then
            arg_err_msg := arg_err_msg || 'print_query ' || SQLERRM ;
            if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
             FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module || 'print_query', SQLERRM);
            end if;
            raise;
      END print_query ;


      /**
       * The following function returns the ranking of the order types.
       * as defined in the user_preference.
       * These ranking order variables are populated during the
       * get_user_prefs() method.
       * This function is called when inserting records into the lines table
       *
       * @param the order type.
       * @return the order rank
       */
      FUNCTION get_order_rank (arg_order_type IN NUMBER) RETURN NUMBER
      IS
      BEGIN

         if arg_order_type = SALES_FORECAST then
            return v_o_seller_forecast;
         elsif arg_order_type = ORDER_FORECAST_CST then
            return v_o_forecast ;
         elsif arg_order_type = SUPPLY_COMMIT then
            return v_o_supply_commit ;
         elsif arg_order_type = G_RETURNS_FORECAST then
            return v_o_returns_forecast ; -- bug#6893383
         elsif arg_order_type = G_DEFECTIVE_OUTBOUND_SHIPMENT then
            return v_o_def_outbound_shipment ; -- bug#6893383
         elsif arg_order_type = HISTORICAL_SALES then
            return v_o_hist_sales ;
         elsif arg_order_type = SELL_THRU_FORECAST then
            return v_o_sell_thro_fcst ;
         elsif arg_order_type = NEGOTIATED_CAPACITY then
            return v_o_negcap;
         elsif arg_order_type = SAFETY_STOCK then
            return v_o_ss;
         elsif arg_order_type = PROJ_AVAIL_BAL then
            return v_o_pab;
         elsif arg_order_type = PROJ_SAFETY_STOCK then
            return v_o_projected_ss;
         elsif arg_order_type = ALLOCATED_ONHAND then
            return v_o_alct_onhand ;
         elsif arg_order_type = UNALLOCATED_ONHAND then
            return v_o_unalct_onhand ;
         elsif arg_order_type = PURCHASE_ORDER then
            return v_o_po ;
         elsif arg_order_type = PROJ_UNALOC_AVL_BAL then
            return v_o_unalct_prjt_avl_bal ;
         elsif arg_order_type = PROJ_ALLOC_AVL_BAL then
            return v_o_alcat_prjt_avl_bal ;
         elsif arg_order_type = SALES_ORDER then
            return v_o_sales_orders ;
         elsif arg_order_type = ASN then
            return v_o_asn ;
         elsif arg_order_type = SHIPMENT_RECEIPT then
            return v_o_receiving ;
         elsif arg_order_type = INTRANSIT then
            return v_o_transit ;
         elsif arg_order_type = WORK_ORDER then
            return v_o_wip ;
         elsif arg_order_type = PO_ACK then
            return v_o_po_ack ;
         elsif arg_order_type = REPLENISHMENT then
            return v_o_replenishment ;
         elsif arg_order_type = REQUISITION then
            return v_o_req ;
         elsif arg_order_type = PO_FROM_PLAN then
            return v_o_po_from_plan ;
         elsif arg_order_type = RELEASED_PLAN then
            return v_o_released_plan ;
         elsif arg_order_type = PLANNED_ORDER then
            return v_o_planned_order ;
         elsif arg_order_type = RUN_TOT_SUPPLY then
            return v_o_run_tot_supply ;
         elsif arg_order_type = RUN_TOT_DEMAND then
            return v_o_run_tot_demand ;
         else
            return 0;
         end if;

      END get_order_rank ;


      /**
       * The following procedure converts an array into a string
       * This is used to convert the array that holds cust/sup ids
       * into a comma delimited string to store in the lines table.
       *
       * @param number array of ids
       * @param string
       * @return - a comma delimited string of ids.
       */
      FUNCTION convert_to_string(v_array IN num, ret_str IN OUT NOCOPY VARCHAR2) RETURN VARCHAR2
      IS
         l NUMBER;
         cnt number := 0;
      BEGIN
         if v_array.COUNT > 0 then
            FOR l IN v_array.FIRST..v_array.LAST LOOP

               if v_array(l) <> 0 then

                  cnt := cnt + 1;
                  if cnt = 1 then
                     ret_str := v_array(l);
                  else
                     ret_str := ret_str || ',' || v_array(l) ;
                  end if;

               end if;
            END LOOP;
         end if;

         return ret_str;
      EXCEPTION
         when no_data_found then
            if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
             FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module || 'convert_to_string', 'No data found');
            end if;
            return null;

         when others then
            if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
             FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module || 'convert_to_string', SQLERRM);
            end if;
            return null;
      END;

      /**
       * The foll function adds a value to an existing array.
       * This is used to add sup/cust ids to an array when the aggregation is
       * at a higher level.
       *
       * @param the array to which the value is to be added
       * @param value to add to the array
       * @return the array.
       */
      FUNCTION add_to_array(v_array IN OUT NOCOPY num, v_value IN NUMBER) RETURN num
      IS
         l NUMBER;
         add_value NUMBER := 0;
         v_temp_cnt NUMBER := 0;
      BEGIN
         if v_array.COUNT > 0 then
            FOR l IN v_array.FIRST..v_array.LAST LOOP
               if v_array(l) = v_value then
                  add_value := 1;
                  exit;
               end if;
            END LOOP;
         end if;

         if add_value <> 1 then
            v_temp_cnt := v_array.COUNT + 1;
            v_array(v_temp_cnt) := v_value;
         end if;

         return v_array;
      EXCEPTION
         when no_data_found then
            if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
             FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module || 'add_to_array', 'No data found');
            end if;
            return v_array;

         when others then
            if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
             FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module || 'add_to_array', SQLERRM);
            end if;
            return v_array;
      END;


      /**
       * The following procedure sets the editable flag of the row
       * The row is editable if
       *    - the order type is order forecast, sales forecast, supply commit,
       *          historical sales, sell through forecast and negotiated capacity
       *    - the user company is the document owner (publisher)
       *    - the user preference aggregation is at site for myco and tpco.
       *    - the user preferences are homogeneous
       *    - the buckets fo the data are homogeneous
       *    - the data buckets is equal to or lower than the user prefs bucket.
       * The values are
       *    0 - editable
       *    1 - not editable
       */
      PROCEDURE set_editable_row(arg_pos IN NUMBER) IS

         c number := arg_pos;
         -- re-fix for bug#4111132 can lead to bug when aggregation at higher level
         -- var_cust/supp_site can be list of id concatenated by ',' eg '34,45'
         cursor security_check
         is     select 1
         from   msc_sup_dem_update_security_v a --,
                --msc_sup_dem_entries_ui_v b
         where  --a.transaction_id = b.transaction_id
             a.customer_id = previous_rec.customer_id
         and    a.customer_site_id = previous_rec.cust_site_id
         and    a.supplier_id = previous_rec.supplier_id
         and    a.supplier_site_id = previous_rec.supp_site_id
         and    a.publisher_order_type = var_order(arg_pos)
         and    a.inventory_item_id = var_item_id(arg_pos);

         l_sec  number := 0;

      BEGIN

         v_user_company := sys_context('MSC','COMPANY_NAME');
         var_edit_flag(c) := 1;  -- not editable

         -- order types

         if var_order(c) in (ORDER_FORECAST_CST,SUPPLY_COMMIT,HISTORICAL_SALES,
                             SELL_THRU_FORECAST,NEGOTIATED_CAPACITY,SALES_FORECAST )
         --   AND -- re-fix for bug#4111132
         --      l_sec = 1 -- replace publisher logic w/ sec rules (bug 4111132)
               -- user has to be publisher of doc
               -- var_from_co_name(c) = v_user_company
            AND -- user pref has homogeneous buckets
               (
                ( daily_bucket_count > 0 and weekly_bucket_count = 0 and period_bucket_count = 0) OR
                ( daily_bucket_count = 0 and weekly_bucket_count > 0 and period_bucket_count = 0) OR
                ( daily_bucket_count = 0 and weekly_bucket_count = 0 and period_bucket_count > 0 )
               )
            AND -- user aggregation is at site
               ( myco_agg = ORG_AGG and tpco_agg = ORG_AGG )
            AND -- data bkt has to be homogeneous
               (
                (var_day_bkt(c) > 0 and var_week_bkt(c) = 0 and var_month_bkt(c) = 0) or
                (var_day_bkt(c) = 0 and var_week_bkt(c) > 0 and var_month_bkt(c) = 0) or
                (var_day_bkt(c) = 0 and var_week_bkt(c) = 0 and var_month_bkt(c) > 0 )
               )
            AND -- user prefs bkt shoudl be equal to the data bkt
               ( (period_bucket_count > 0 and var_week_bkt(c) = 0 and var_day_bkt(c) = 0) OR -- cannot be week and day
                 ( weekly_bucket_count > 0 and var_month_bkt(c) = 0 and var_day_bkt(c) = 0) OR -- cannot be month and day
                 ( daily_bucket_count > 0 and var_month_bkt(c) = 0 and var_week_bkt(c) = 0) -- cannot be month and week
               )
            THEN

               OPEN security_check;
               FETCH security_check into l_sec;
               CLOSE security_check;

               IF l_sec = 1 THEN
                var_edit_flag(c) := 0; -- editable.
               END IF;
         end if;

         -- set the bucket type for the row.
         if var_day_bkt(c) > 0 and (var_week_bkt(c) = 0 and var_month_bkt(c) = 0) then
            var_bkt_type(c) := DAY_BUCKET;

         elsif var_day_bkt(c) = 0 and (var_week_bkt(c) > 0 and var_month_bkt(c) = 0) then
            var_bkt_type(c) := WEEK_BUCKET;

         elsif var_day_bkt(c) = 0 and (var_week_bkt(c) = 0 and var_month_bkt(c) > 0)  then
            var_bkt_type(c) := MONTH_BUCKET;

         else
            var_bkt_type(c) := 0;

         end if;

      EXCEPTION
         WHEN OTHERS THEN
            if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
             FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module || 'set_editable_row', SQLERRM);
            end if;
            null;
      END set_editable_row ;

      /**
       * The following procedure sets the non qty variables
       * into the appropriate position in the respective pl/sql table
       * @param the position.
       */
      PROCEDURE set_non_qty_data(arg_pos IN NUMBER) IS
         counter number := arg_pos ;
         temp_str VARCHAR2(2000);
         l number ;
      BEGIN

         var_relation(counter) := nvl(previous_rec.relation,'NA') ;
         var_order_relation(counter) := nvl(previous_rec.order_relation,'NA') ;
         var_from_co_name(counter) := nvl(previous_rec.from_co_name,'NA' );
         var_from_org_name(counter) := nvl(previous_rec.from_org_name,'NA' );

         var_item_name(counter) := previous_rec.item_name;
         var_order(counter) := nvl(previous_rec.order_type,-1) ;
         var_order_rank(counter) := nvl(get_order_rank(previous_rec.order_type),0);
         var_order_desc(counter) := nvl(previous_rec.order_desc,var_order(counter) );
         var_uom(counter) := nvl(previous_rec.uom,'Ea');
	 var_item_name_desc(counter) := previous_rec.item_desc;
	 var_sup_item(counter):=previous_rec.supplier_item_name;

         var_supplier(counter) := previous_rec.supplier_name;
         var_customer(counter) := previous_rec.customer_name;
         var_supplier_org(counter) := previous_rec.supplier_org;
         var_customer_org(counter) := previous_rec.customer_org;
         var_item_id(counter) := previous_rec.item_id;

         var_pub_id(counter) := previous_rec.publisher_id;
         var_pub_site_id(counter) := previous_rec.publisher_site_id;


         temp_str := NULL;
         if temp_sup is null then
            var_supplier_id(counter) := to_char(previous_rec.supplier_id);
         else
            temp_str := convert_to_string(temp_sup, temp_str) ;
            var_supplier_id(counter) := temp_str;
         end if;

         temp_str := NULL;
         if temp_cust is null then
            var_customer_id(counter) := to_char(previous_rec.customer_id);
         else
            temp_str := convert_to_string(temp_cust, temp_str) ;
            var_customer_id(counter) := temp_str;
         end if;

         temp_str := NULL;
         if temp_sup_site is null then
            var_supplier_site_id(counter) := to_char(previous_rec.supp_site_id);
         else
            temp_str := convert_to_string(temp_sup_site, temp_str) ;
            var_supplier_site_id(counter) := temp_str;
         end if;

         temp_str := NULL;
         if temp_cust_site is null then
            var_customer_site_id(counter) := to_char(previous_rec.cust_site_id);
         else
            temp_str := convert_to_string(temp_cust_site, temp_str) ;
            var_customer_site_id(counter) := temp_str;
         end if;

         -- set the ditable falg for the row.
         set_editable_row(arg_pos);

      EXCEPTION
         when others then
            arg_err_msg :=  arg_err_msg || ' set data' || SQLERRM ;
            if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
             FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module || 'set_non_qty_data', SQLERRM);
            end if;
            raise;
      END set_non_qty_data;


      /**
       * The following function calculates and returns the past due qty
       * for the current order type PO, SO or ASN.
       *
       * @param order type.
       */
      Function calc_past_due_qty(v_order IN NUMBER) RETURN NUMBER
      IS
       v_past_due_qty NUMBER := 0;
       v_viewer_id number := -1;
       l_base_qty number := 0;
       l_config_qty number := 0;
      BEGIN

    select sys_context('MSC','COMPANY_ID') into v_viewer_id from dual;

    if tpco_agg = ORG_AGG THEN

     if myco_agg = ORG_AGG THEN

      select nvl(sum(decode (sys_context('MSC','COMPANY_ID'), publisher_id,primary_quantity,
                    customer_id, tp_quantity,
                    supplier_id, tp_quantity, quantity)),0) into l_base_qty
      from msc_sup_dem_entries_ui_v
      where base_item_id = activity_rec.item_id
      and customer_id = activity_rec.customer_id
      and customer_site_id = activity_rec.cust_site_id
      and supplier_id = activity_rec.supplier_id
      and supplier_site_id = activity_rec.supp_site_id
      and publisher_order_type = activity_rec.order_type
      and key_date < p_start_date;


      select nvl(sum(decode (sys_context('MSC','COMPANY_ID'), publisher_id,primary_quantity,
                    customer_id, tp_quantity,
                    supplier_id, tp_quantity, quantity)),0) into l_config_qty
      from msc_sup_dem_entries_ui_v
      where inventory_item_id = activity_rec.item_id
      and customer_id = activity_rec.customer_id
      and customer_site_id = activity_rec.cust_site_id
      and supplier_id = activity_rec.supplier_id
      and supplier_site_id = activity_rec.supp_site_id
      and publisher_order_type = activity_rec.order_type
      and key_date < p_start_date;

      v_past_due_qty := l_base_qty + l_config_qty;

     elsif myco_agg = COMPANY_AGG THEN

      if(v_viewer_id = activity_rec.customer_id) then

       select nvl(sum(decode (sys_context('MSC','COMPANY_ID'), publisher_id,primary_quantity,
                    customer_id, tp_quantity,
                    supplier_id, tp_quantity, quantity)),0) into l_base_qty
       from msc_sup_dem_entries_ui_v
       where base_item_id= activity_rec.item_id
       and customer_id = activity_rec.customer_id
       and supplier_id = activity_rec.supplier_id
       and supplier_site_id = activity_rec.supp_site_id
       and publisher_order_type = activity_rec.order_type
       and key_date < p_start_date;

       select nvl(sum(decode (sys_context('MSC','COMPANY_ID'), publisher_id,primary_quantity,
                    customer_id, tp_quantity,
                    supplier_id, tp_quantity, quantity)),0) into l_config_qty
       from msc_sup_dem_entries_ui_v
       where inventory_item_id = activity_rec.item_id
       and customer_id = activity_rec.customer_id
       and supplier_id = activity_rec.supplier_id
       and supplier_site_id = activity_rec.supp_site_id
       and publisher_order_type = activity_rec.order_type
       and key_date < p_start_date;

        v_past_due_qty := l_base_qty + l_config_qty;

      elsif(v_viewer_id = activity_rec.supplier_id) then

       select nvl(sum(decode (sys_context('MSC','COMPANY_ID'), publisher_id,primary_quantity,
                    customer_id, tp_quantity,
                    supplier_id, tp_quantity, quantity)),0) into l_base_qty
       from msc_sup_dem_entries_ui_v
       where base_item_id = activity_rec.item_id
       and customer_id = activity_rec.customer_id
       and customer_site_id = activity_rec.cust_site_id
       and supplier_id = activity_rec.supplier_id
       and publisher_order_type = activity_rec.order_type
       and key_date < p_start_date;

       select nvl(sum(decode (sys_context('MSC','COMPANY_ID'), publisher_id,primary_quantity,
                    customer_id, tp_quantity,
                    supplier_id, tp_quantity, quantity)),0) into l_config_qty
       from msc_sup_dem_entries_ui_v
       where inventory_item_id = activity_rec.item_id
       and customer_id = activity_rec.customer_id
       and customer_site_id = activity_rec.cust_site_id
       and supplier_id = activity_rec.supplier_id
       and publisher_order_type = activity_rec.order_type
       and key_date < p_start_date;

        v_past_due_qty := l_base_qty + l_config_qty;
      end if;

     end if;

    elsif tpco_agg = COMPANY_AGG THEN

     if myco_agg = ORG_AGG THEN

      if(v_viewer_id = activity_rec.supplier_id) then

       select nvl(sum(decode (sys_context('MSC','COMPANY_ID'), publisher_id,primary_quantity,
                    customer_id, tp_quantity,
                    supplier_id, tp_quantity, quantity)),0) into l_base_qty
       from msc_sup_dem_entries_ui_v
       where base_item_id = activity_rec.item_id
       and customer_id = activity_rec.customer_id
       and supplier_id = activity_rec.supplier_id
       and supplier_site_id = activity_rec.supp_site_id
       and publisher_order_type = activity_rec.order_type
       and key_date < p_start_date;

       select nvl(sum(decode (sys_context('MSC','COMPANY_ID'), publisher_id,primary_quantity,
                    customer_id, tp_quantity,
                    supplier_id, tp_quantity, quantity)),0) into l_config_qty
       from msc_sup_dem_entries_ui_v
       where inventory_item_id = activity_rec.item_id
       and customer_id = activity_rec.customer_id
       and supplier_id = activity_rec.supplier_id
       and supplier_site_id = activity_rec.supp_site_id
       and publisher_order_type = activity_rec.order_type
       and key_date < p_start_date;

        v_past_due_qty := l_base_qty + l_config_qty;

      elsif(v_viewer_id = activity_rec.customer_id) then

       select nvl(sum(decode (sys_context('MSC','COMPANY_ID'), publisher_id,primary_quantity,
                    customer_id, tp_quantity,
                    supplier_id, tp_quantity, quantity)),0) into l_base_qty
       from msc_sup_dem_entries_ui_v
       where base_item_id = activity_rec.item_id
       and customer_id = activity_rec.customer_id
       and customer_site_id = activity_rec.cust_site_id
       and supplier_id = activity_rec.supplier_id
       and publisher_order_type = activity_rec.order_type
       and key_date < p_start_date;

       select nvl(sum(decode (sys_context('MSC','COMPANY_ID'), publisher_id,primary_quantity,
                    customer_id, tp_quantity,
                    supplier_id, tp_quantity, quantity)),0) into l_config_qty
       from msc_sup_dem_entries_ui_v
       where inventory_item_id = activity_rec.item_id
       and customer_id = activity_rec.customer_id
       and customer_site_id = activity_rec.cust_site_id
       and supplier_id = activity_rec.supplier_id
       and publisher_order_type = activity_rec.order_type
       and key_date < p_start_date;

        v_past_due_qty := l_base_qty + l_config_qty;
      end if;


     elsif myco_agg = COMPANY_AGG THEN

       select nvl(sum(decode (sys_context('MSC','COMPANY_ID'), publisher_id,primary_quantity,
                    customer_id, tp_quantity,
                    supplier_id, tp_quantity, quantity)),0) into l_base_qty
       from msc_sup_dem_entries_ui_v
       where base_item_id = activity_rec.item_id
       and customer_id = activity_rec.customer_id
       and supplier_id = activity_rec.supplier_id
       and publisher_order_type = activity_rec.order_type
       and key_date < p_start_date;

       select nvl(sum(decode (sys_context('MSC','COMPANY_ID'), publisher_id,primary_quantity,
                    customer_id, tp_quantity,
                    supplier_id, tp_quantity, quantity)),0) into l_config_qty
       from msc_sup_dem_entries_ui_v
       where inventory_item_id = activity_rec.item_id
       and customer_id = activity_rec.customer_id
       and supplier_id = activity_rec.supplier_id
       and publisher_order_type = activity_rec.order_type
       and key_date < p_start_date;

        v_past_due_qty := l_base_qty + l_config_qty;

     end if;


    elsif tpco_agg = ALL_AGG THEN

     if myco_agg = ORG_AGG THEN

      if(v_viewer_id = activity_rec.customer_id) then

       select nvl(sum(decode (sys_context('MSC','COMPANY_ID'), publisher_id,primary_quantity,
                    customer_id, tp_quantity,
                    supplier_id, tp_quantity, quantity)),0) into l_base_qty
       from msc_sup_dem_entries_ui_v
       where base_item_id = activity_rec.item_id
       and customer_id = activity_rec.customer_id
       and customer_site_id = activity_rec.cust_site_id
       and publisher_order_type = activity_rec.order_type
       and key_date < p_start_date;


       select nvl(sum(decode (sys_context('MSC','COMPANY_ID'), publisher_id,primary_quantity,
                    customer_id, tp_quantity,
                    supplier_id, tp_quantity, quantity)),0) into l_config_qty
       from msc_sup_dem_entries_ui_v
       where inventory_item_id = activity_rec.item_id
       and customer_id = activity_rec.customer_id
       and customer_site_id = activity_rec.cust_site_id
       and publisher_order_type = activity_rec.order_type
       and key_date < p_start_date;

        v_past_due_qty := l_base_qty + l_config_qty;

      elsif(v_viewer_id = activity_rec.supplier_id) then

       select nvl(sum(decode (sys_context('MSC','COMPANY_ID'), publisher_id,primary_quantity,
                    customer_id, tp_quantity,
                    supplier_id, tp_quantity, quantity)),0) into l_base_qty
       from msc_sup_dem_entries_ui_v
       where base_item_id = activity_rec.item_id
       and supplier_id = activity_rec.supplier_id
       and supplier_site_id = activity_rec.supp_site_id
       and publisher_order_type = activity_rec.order_type
       and key_date < p_start_date;

       select nvl(sum(decode (sys_context('MSC','COMPANY_ID'), publisher_id,primary_quantity,
                    customer_id, tp_quantity,
                    supplier_id, tp_quantity, quantity)),0) into l_config_qty
       from msc_sup_dem_entries_ui_v
       where inventory_item_id = activity_rec.item_id
       and supplier_id = activity_rec.supplier_id
       and supplier_site_id = activity_rec.supp_site_id
       and publisher_order_type = activity_rec.order_type
       and key_date < p_start_date;

        v_past_due_qty := l_base_qty + l_config_qty;
      end if;


     elsif myco_agg = COMPANY_AGG THEN

      if(v_viewer_id = activity_rec.customer_id) then

       select nvl(sum(decode (sys_context('MSC','COMPANY_ID'), publisher_id,primary_quantity,
                    customer_id, tp_quantity,
                    supplier_id, tp_quantity, quantity)),0) into l_base_qty
       from msc_sup_dem_entries_ui_v
       where base_item_id = activity_rec.item_id
       and customer_id = activity_rec.customer_id
       and publisher_order_type = activity_rec.order_type
       and key_date < p_start_date;


       select nvl(sum(decode (sys_context('MSC','COMPANY_ID'), publisher_id,primary_quantity,
                    customer_id, tp_quantity,
                    supplier_id, tp_quantity, quantity)),0) into l_config_qty
       from msc_sup_dem_entries_ui_v
       where inventory_item_id = activity_rec.item_id
       and customer_id = activity_rec.customer_id
       and publisher_order_type = activity_rec.order_type
       and key_date < p_start_date;

        v_past_due_qty := l_base_qty + l_config_qty;
      elsif(v_viewer_id = activity_rec.supplier_id) then

       select nvl(sum(decode (sys_context('MSC','COMPANY_ID'), publisher_id,primary_quantity,
                    customer_id, tp_quantity,
                    supplier_id, tp_quantity, quantity)),0) into l_base_qty
       from msc_sup_dem_entries_ui_v
       where base_item_id = activity_rec.item_id
       and supplier_id = activity_rec.supplier_id
       and publisher_order_type = activity_rec.order_type
       and key_date < p_start_date;

       select nvl(sum(decode (sys_context('MSC','COMPANY_ID'), publisher_id,primary_quantity,
                    customer_id, tp_quantity,
                    supplier_id, tp_quantity, quantity)),0) into l_config_qty
       from msc_sup_dem_entries_ui_v
       where inventory_item_id = activity_rec.item_id
       and supplier_id = activity_rec.supplier_id
       and publisher_order_type = activity_rec.order_type
       and key_date < p_start_date;

        v_past_due_qty := l_base_qty + l_config_qty;

      end if;

     end if;

    end if;

       return v_past_due_qty;

       EXCEPTION
            WHEN OTHERS THEN
               arg_err_msg := ' calculate_past_due_quantity ' || SQLERRM;
               if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module || 'calculate_past_due_quantity', SQLERRM);
               end if;
               raise;
      END calc_past_due_qty  ;

      /**
       * The following procedure calculates the bucket qty
       * from the current record.
       * It aggregates/adds the current qty based on teh date into the appropriate
       * bucket pl/sql table.
       *
       * @param the position.
       */
      PROCEDURE calculate_bucket_data(arg_pos IN NUMBER) IS
         curr_cnt number := arg_pos;

         v_nextbkt number := 0;


      BEGIN

         -- check the onhand asn etc first.
         -- the order type is intransit or onhand then unbucketed value
         -- set the new_date to null
         -- NOTE : HERE NEED TO TAKE ONLY OPEN ASN's for intransit.
         IF (v_intransit > 0 AND activity_rec.order_type = INTRANSIT) OR
          --  (v_asn > 0 AND activity_rec.order_type = ASN) OR  --- Commented for Bug # 6147428
            (v_alloc_onhand > 0 AND activity_rec.order_type = ALLOCATED_ONHAND) OR
            (v_unalloc_onhand > 0 AND activity_rec.order_type = UNALLOCATED_ONHAND)  THEN


            var_qty_nobkt(curr_cnt) := var_qty_nobkt(curr_cnt) + activity_rec.new_quantity;
            unbucketed_flag := 1 ;
            activity_rec.new_date := null ;

         END IF;


         -- check the bucket types of the record.
         if  activity_rec.bucket_type = DAY_BUCKET then
            var_day_bkt(curr_cnt) := nvl(var_day_bkt(curr_cnt),0) + 1 ;

         elsif  activity_rec.bucket_type = WEEK_BUCKET then
            var_week_bkt(curr_cnt) := nvl(var_week_bkt(curr_cnt),0) + 1 ;

         elsif  activity_rec.bucket_type = MONTH_BUCKET then
            var_month_bkt(curr_cnt) := nvl(var_month_bkt(curr_cnt),0) + 1 ;

         end if;

         i := 0;


         if g_num_of_buckets > 0 and activity_rec.new_date is not null then
            for i in var_dates.FIRST..g_num_of_buckets loop

               curr_date := var_dates(i);
               v_nextbkt := 0;



               -- now if th value is less and if it is not th first record then
               -- add to the var_quantity (i-1).
               -- NOTE: if this is the first then there is no 0 record.
               IF i <> g_num_of_buckets THEN
                  if activity_rec.new_date <> var_dates(i)   AND
                    activity_rec.new_date <> var_dates(i+1) THEN

                    if activity_rec.new_date > var_dates(i) AND
                     activity_rec.new_date between var_dates(i) AND var_dates(i+1) THEN

                        v_nextbkt := 1;
                    end if;
                  end if;
               -- for the last bucket check to see if the key_date falls between the last bucket start and end date
               -- NOTE : v_last_bkt_date has starting date of last+1 bucket.
               ELSIF i = g_num_of_buckets THEN
                 if activity_rec.new_date > var_dates(i) AND
                   activity_rec.new_date between var_dates(i) AND v_last_bkt_date THEN

                   v_nextbkt := 1;
                     end if;
                END IF;

               -- if the dates are equal
               -- or if the above flag is set then
               -- add to theappropriate bucket
               -- for safety stock and PAB, do not aggregate (since it represents a level)
               -- for ss and pab, display the latest ss/pab value in that bucket.
        --Modifying the logic for not aggregating the PAB/SS Records..Bug 4200004



               IF activity_rec.new_date = var_dates(i) OR v_nextbkt > 0 THEN
                  if i = 1 then

                     calculate_bucket_qty_ss_pab(var_flag1,var_pub_id1,var_qty1(curr_cnt),var_temp1,var_temp_qty1,var_temp_order_type1 );

                  elsif i = 2 then

                     calculate_bucket_qty_ss_pab(var_flag2,var_pub_id2,var_qty2(curr_cnt),var_temp2,var_temp_qty2,var_temp_order_type2 );

                  elsif i = 3 then

                     calculate_bucket_qty_ss_pab(var_flag3,var_pub_id3,var_qty3(curr_cnt),var_temp3,var_temp_qty3,var_temp_order_type3 );

                  elsif i = 4 then

  calculate_bucket_qty_ss_pab(var_flag4,var_pub_id4,var_qty4(curr_cnt),var_temp4,var_temp_qty4,var_temp_order_type4 );

                  elsif i = 5 then

                   calculate_bucket_qty_ss_pab(var_flag5,var_pub_id5,var_qty5(curr_cnt),var_temp5,var_temp_qty5,var_temp_order_type5 );


                  elsif i = 6 then

                    calculate_bucket_qty_ss_pab(var_flag6,var_pub_id6,var_qty6(curr_cnt),var_temp6,var_temp_qty6,var_temp_order_type6 );

                  elsif i = 7 then

                     calculate_bucket_qty_ss_pab(var_flag7,var_pub_id7,var_qty7(curr_cnt),var_temp7,var_temp_qty7,var_temp_order_type7 );

                  elsif i = 8 then

                     calculate_bucket_qty_ss_pab(var_flag8,var_pub_id8,var_qty8(curr_cnt),var_temp8,var_temp_qty8,var_temp_order_type8 );

                  elsif i = 9 then

                     calculate_bucket_qty_ss_pab(var_flag9,var_pub_id9,var_qty9(curr_cnt),var_temp9,var_temp_qty9,var_temp_order_type9 );

                  elsif i = 10 then

                    calculate_bucket_qty_ss_pab(var_flag10,var_pub_id10,var_qty10(curr_cnt),var_temp10,var_temp_qty10,var_temp_order_type10 );

                  elsif i = 11 then

                     calculate_bucket_qty_ss_pab(var_flag11,var_pub_id11,var_qty11(curr_cnt),var_temp11,var_temp_qty11,var_temp_order_type11 );

                  elsif i = 12 then

                     calculate_bucket_qty_ss_pab(var_flag12,var_pub_id12,var_qty12(curr_cnt),var_temp12,var_temp_qty12,var_temp_order_type12 );

                  elsif i = 13 then

                    calculate_bucket_qty_ss_pab(var_flag13,var_pub_id13,var_qty13(curr_cnt),var_temp13,var_temp_qty13,var_temp_order_type13 );

                  elsif i = 14 then

                     calculate_bucket_qty_ss_pab(var_flag14,var_pub_id14,var_qty14(curr_cnt),var_temp14,var_temp_qty14,var_temp_order_type14 );
                  elsif i = 15 then

                     calculate_bucket_qty_ss_pab(var_flag15,var_pub_id15,var_qty15(curr_cnt),var_temp15,var_temp_qty15,var_temp_order_type15 );
                  elsif i = 16 then

                     calculate_bucket_qty_ss_pab(var_flag16,var_pub_id16,var_qty16(curr_cnt),var_temp16,var_temp_qty16,var_temp_order_type16 );
                  elsif i = 17 then

                     calculate_bucket_qty_ss_pab(var_flag17,var_pub_id17,var_qty17(curr_cnt),var_temp17,var_temp_qty17,var_temp_order_type17 );
                  elsif i = 18 then

                     calculate_bucket_qty_ss_pab(var_flag18,var_pub_id18,var_qty18(curr_cnt),var_temp18,var_temp_qty18,var_temp_order_type18 );
                  elsif i = 19 then

                     calculate_bucket_qty_ss_pab(var_flag19,var_pub_id19,var_qty19(curr_cnt),var_temp19,var_temp_qty19,var_temp_order_type19 );
                  elsif i = 20 then

                    calculate_bucket_qty_ss_pab(var_flag20,var_pub_id20,var_qty20(curr_cnt),var_temp20,var_temp_qty20,var_temp_order_type20 );
                  elsif i = 21 then

                     calculate_bucket_qty_ss_pab(var_flag21,var_pub_id21,var_qty21(curr_cnt),var_temp21,var_temp_qty21,var_temp_order_type21 );
                  elsif i = 22 then

                     calculate_bucket_qty_ss_pab(var_flag22,var_pub_id22,var_qty22(curr_cnt),var_temp22,var_temp_qty22,var_temp_order_type22 );
                  elsif i = 23 then

                    calculate_bucket_qty_ss_pab(var_flag23,var_pub_id23,var_qty23(curr_cnt),var_temp23,var_temp_qty23,var_temp_order_type23 );
                  elsif i = 24 then

                     calculate_bucket_qty_ss_pab(var_flag24,var_pub_id24,var_qty24(curr_cnt),var_temp24,var_temp_qty24,var_temp_order_type24 );
                  elsif i = 25 then

                    calculate_bucket_qty_ss_pab(var_flag25,var_pub_id25,var_qty25(curr_cnt),var_temp25,var_temp_qty25,var_temp_order_type25 );
                  elsif i = 26 then

                     calculate_bucket_qty_ss_pab(var_flag26,var_pub_id26,var_qty26(curr_cnt),var_temp26,var_temp_qty26,var_temp_order_type26 );
                  elsif i = 27 then

                     calculate_bucket_qty_ss_pab(var_flag27,var_pub_id27,var_qty27(curr_cnt),var_temp27,var_temp_qty27,var_temp_order_type27 );
                  elsif i = 28 then

                     calculate_bucket_qty_ss_pab(var_flag28,var_pub_id28,var_qty28(curr_cnt),var_temp28,var_temp_qty28,var_temp_order_type28 );

                  elsif i = 29 then

                    calculate_bucket_qty_ss_pab(var_flag29,var_pub_id29,var_qty29(curr_cnt),var_temp29,var_temp_qty29,var_temp_order_type29 );
                 elsif i = 30 then

                    calculate_bucket_qty_ss_pab(var_flag30,var_pub_id30,var_qty30(curr_cnt),var_temp30,var_temp_qty30,var_temp_order_type30 );
                  elsif i = 31 then

                     calculate_bucket_qty_ss_pab(var_flag31,var_pub_id31,var_qty31(curr_cnt),var_temp31,var_temp_qty31,var_temp_order_type31 );
                  elsif i = 32 then

                     calculate_bucket_qty_ss_pab(var_flag32,var_pub_id32,var_qty32(curr_cnt),var_temp32,var_temp_qty32,var_temp_order_type32 );
                  elsif i = 33 then

                     calculate_bucket_qty_ss_pab(var_flag33,var_pub_id33,var_qty33(curr_cnt),var_temp33,var_temp_qty33,var_temp_order_type33 );
                  elsif i = 34 then

                     calculate_bucket_qty_ss_pab(var_flag34,var_pub_id34,var_qty34(curr_cnt),var_temp34,var_temp_qty34,var_temp_order_type34 );
                  elsif i = 35 then

                     calculate_bucket_qty_ss_pab(var_flag35,var_pub_id35,var_qty35(curr_cnt),var_temp35,var_temp_qty35,var_temp_order_type35 );
                  elsif i = 36 then

                     calculate_bucket_qty_ss_pab(var_flag36,var_pub_id36,var_qty36(curr_cnt),var_temp36,var_temp_qty36,var_temp_order_type36 );

                  end if;
               END IF;

            end loop;
         end if;

 -- commit;
      EXCEPTION
         when others then
            arg_err_msg := arg_err_msg || ' calc bkt data' || SQLERRM;
            if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
             FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module || 'calculate_bucket_data', SQLERRM);
            end if;
            raise;
      END calculate_bucket_data;

      /**
       * The following function builds the sql statement
       * that fetches the data from the sup_dem table via the hz_v.
       * This is a dynamic sql
       *
       * @param the order type
       * @return the sql string
       */
      Function prepare_sql(v_order IN NUMBER) RETURN VARCHAR2
      IS
         l_statement   VARCHAR2(4000);
         l_comcom      VARCHAR2(125);
         l_orgorg      VARCHAR2(275);
         l_orders      VARCHAR2(100);

         l_date        VARCHAR2(20) := to_char(trunc(nvl(arg_from_date, p_start_date)),'MM-DD-YYYY');
         l_last        VARCHAR2(20) := to_char(trunc(nvl(v_last_bkt_date, sysdate)), 'MM-DD-YYYY');
         l_order_group  VARCHAR2(1000);
         l_item_id      NUMBER;
         l_query_id     NUMBER;
         l_sup_site     VARCHAR2(300);

          CURSOR category_items(arg_category_name VARCHAR2)
     IS
       SELECT distinct inventory_item_id
       FROM msc_item_categories
       where category_name = arg_category_name
       and category_set_id = FND_PROFILE.VALUE('MSCX_CP_HZ_CATEGORY_SET');

      BEGIN


        -- insert all the items of the category into temp table msc_form_query.
        -- store all the item ids in number1 column of msc_form_query temp table.
        if (v_category is not null) then
      select msc_form_query_s.nextval into l_query_id from dual;
      OPEN category_items(v_category);
      LOOP
       FETCH category_items into l_item_id;
       EXIT WHEN category_items%NOTFOUND;
        INSERT INTO msc_form_query
        (
         QUERY_ID,LAST_UPDATE_DATE,LAST_UPDATED_BY,CREATION_DATE,CREATED_BY,LAST_UPDATE_LOGIN,
         DATE1,DATE2,DATE3,DATE4,DATE5,DATE6,DATE7,DATE8,NUMBER1,NUMBER2,NUMBER3,NUMBER4,NUMBER5,
         NUMBER6,NUMBER7,NUMBER8,NUMBER9,NUMBER10,NUMBER11,NUMBER12,NUMBER13,NUMBER14,NUMBER15,
         REQUEST_ID,CHAR1,CHAR2,CHAR3,CHAR4,CHAR5,CHAR6,CHAR7,CHAR8,CHAR9,PROGRAM_UPDATE_DATE,
         PROGRAM_APPLICATION_ID,PROGRAM_ID,NUMBER16,CHAR10,CHAR11,CHAR12,CHAR13,CHAR14,CHAR15                                                 )
        VALUES
        (
         l_query_id,sysdate,fnd_profile.value('USER_ID'),sysdate,fnd_profile.value('USER_ID'),null,
         null,null,null,null,null,null,null,null, l_item_id,null,null,null,null,
         null,null,null,null,null,null,null,null,null,null,
         null,null,null,null,null,null,null,null,null,null,null,
         null,null,null,null,null,null,null,null,null
        );
      END LOOP;
      CLOSE category_items;
    end if;

         if v_order IS NULL or v_order = 0 then
            l_orders := v_sales_forecast || ',' || v_order_forecast || ',' || v_supply_commit ;
            l_orders := l_orders || ',' || v_returns_forecast ||',' || v_def_outbound_shipment ; -- bug#6893383
            l_orders := l_orders || ',' || v_hist_sales || ',' || v_sell_thru_fcst || ',' || v_negotiated_capacity ;
            l_orders := l_orders || ',' || v_safety_stock || ',' || v_proj_avail_bal  || ',' || v_proj_safety_stock ;
            l_orders := l_orders || ',' || v_alloc_onhand || ',' || v_unalloc_onhand ;
            l_orders := l_orders || ',' || v_proj_unalloc_avl_bal || ',' || v_proj_alloc_avl_bal ;
            l_orders := l_orders || ',' || v_purchase_order || ',' || v_sales_order || ',' || v_asn ;
            l_orders := l_orders || ',' || v_shipment_receipt || ',' || v_intransit || ',' || v_work_order || ',' || v_po_ack ;
            l_orders := l_orders || ',' || v_replenishment || ',' || v_requisition ;
            l_orders := l_orders || ',' || v_po_from_plan || ',' || v_released_plan || ',' || v_planned_order ;
         else
            l_orders := v_order ;
         end if;

         l_statement := 'SELECT  nvl(';
         -- publisher name should not be used in order by relation_group.
         l_order_group := ' nvl(';

   /* -- Bug# 4199827 -- Added nvl to tp_company and tp_site so that viewer can view data according to
   sites based on Preference Set  for OnHand , SS, PAB */

         if tpco_agg = ORG_AGG THEN

            if myco_agg = ORG_AGG THEN

               l_statement := l_statement || 'decode(third_party_flag,0,';
               l_statement := l_statement ||     'least(viewer_company||viewer_site,nvl(tp_company,-1)||nvl(tp_site,-1))|| ' ;
               l_statement := l_statement ||          'greatest(viewer_company||viewer_site,nvl(tp_company,-1)||nvl(tp_site,-1)),';
               l_statement := l_statement ||     'viewer_company||viewer_site||nvl(tp_company,-1)||nvl(tp_site,-1)|| decode(publisher_order_type, 1, publisher_name, ''''))';

               l_order_group := l_order_group || 'decode(third_party_flag,0,';
               l_order_group := l_order_group ||     'least(viewer_company||viewer_site,nvl(tp_company,-1)||nvl(tp_site,-1))|| ' ;
               l_order_group := l_order_group ||          'greatest(viewer_company||viewer_site,nvl(tp_company,-1)||nvl(tp_site,-1)),';
               l_order_group := l_order_group ||     'viewer_company||viewer_site||nvl(tp_company,-1)||nvl(tp_site,-1))';

            elsif myco_agg = COMPANY_AGG THEN
               l_statement := l_statement || 'decode(third_party_flag,0,';
               l_statement := l_statement ||     'least(viewer_company,nvl(tp_company,-1)||nvl(tp_site,-1))||';
               l_statement := l_statement ||              'greatest(viewer_company,nvl(tp_company,-1)||nvl(tp_site,-1)) ';
               l_statement := l_statement ||     ',viewer_company||nvl(tp_company,-1)||nvl(tp_site,-1)||decode(publisher_order_type, 1, publisher_name, ''''))';

               l_order_group := l_order_group || 'decode(third_party_flag,0,';
               l_order_group := l_order_group ||     'least(viewer_company,nvl(tp_company,-1)||nvl(tp_site,-1))||';
               l_order_group := l_order_group ||              'greatest(viewer_company,nvl(tp_company,-1)||nvl(tp_site,-1)) ';
               l_order_group := l_order_group ||     ',viewer_company||nvl(tp_company,-1)||nvl(tp_site,-1))';
            end if;

         elsif tpco_agg = COMPANY_AGG THEN

            if myco_agg = ORG_AGG THEN
               l_statement := l_statement || 'decode(third_party_flag,0,';
               l_statement := l_statement ||     'least(viewer_company||viewer_site,nvl(tp_company,-1))||';
               l_statement := l_statement ||              'greatest(viewer_company||viewer_site,nvl(tp_company,-1)),';
               l_statement := l_statement ||     'viewer_company||viewer_site||nvl(tp_company,-1)||decode(publisher_order_type, 1, publisher_name, ''''))';

               l_order_group := l_order_group || 'decode(third_party_flag,0,';
               l_order_group := l_order_group ||     'least(viewer_company||viewer_site,nvl(tp_company,-1))||';
               l_order_group := l_order_group ||              'greatest(viewer_company||viewer_site,nvl(tp_company,-1)),';
               l_order_group := l_order_group ||     'viewer_company||viewer_site||nvl(tp_company,-1))';

            elsif myco_agg = COMPANY_AGG THEN
               l_statement := l_statement || 'decode(third_party_flag,0,';
               l_statement := l_statement ||     'least(viewer_company,nvl(tp_company,-1))||';
               l_statement := l_statement ||              'greatest(viewer_company,nvl(tp_company,-1)),';
               l_statement := l_statement ||     'viewer_company||nvl(tp_company,-1)||decode(publisher_order_type, 1, publisher_name, ''''))';

               l_order_group := l_order_group || 'decode(third_party_flag,0,';
               l_order_group := l_order_group ||     'least(viewer_company,nvl(tp_company,-1))||';
               l_order_group := l_order_group ||              'greatest(viewer_company,nvl(tp_company,-1)),';
               l_order_group := l_order_group ||     'viewer_company||nvl(tp_company,-1))';
            end if;


         elsif tpco_agg = ALL_AGG THEN

            if myco_agg = ORG_AGG THEN
               l_statement := l_statement || 'decode(third_party_flag,0,least(viewer_company||viewer_site, ';
               l_statement := l_statement ||     'FND_MESSAGE.GET_STRING(''MSC'',''MSC_X_HZ_TP_ALL''))|| ';
               l_statement := l_statement ||           'greatest(viewer_company||viewer_site,';
               l_statement := l_statement ||     'FND_MESSAGE.GET_STRING(''MSC'',''MSC_X_HZ_TP_ALL'')),';
               l_statement := l_statement ||     'decode(viewer_company, customer_name, viewer_company||viewer_site||FND_MESSAGE.GET_STRING(''MSC'',''MSC_X_HZ_TP_ALL'')';
               l_statement := l_statement ||     ', FND_MESSAGE.GET_STRING(''MSC'',''MSC_X_HZ_TP_ALL'')||viewer_company||viewer_site))';

               l_order_group := l_order_group || 'decode(third_party_flag,0,least(viewer_company||viewer_site, ';
               l_order_group := l_order_group ||     'FND_MESSAGE.GET_STRING(''MSC'',''MSC_X_HZ_TP_ALL''))|| ';
               l_order_group := l_order_group ||           'greatest(viewer_company||viewer_site,';
               l_order_group := l_order_group ||     'FND_MESSAGE.GET_STRING(''MSC'',''MSC_X_HZ_TP_ALL'')),';
               l_order_group := l_order_group ||     'decode(viewer_company, customer_name, viewer_company||viewer_site||FND_MESSAGE.GET_STRING(''MSC'',''MSC_X_HZ_TP_ALL'')';
               l_order_group := l_order_group ||     ', FND_MESSAGE.GET_STRING(''MSC'',''MSC_X_HZ_TP_ALL'')||viewer_company||viewer_site))';

            elsif myco_agg = COMPANY_AGG THEN
               l_statement := l_statement || 'decode(third_party_flag,0,least(viewer_company,';
               l_statement := l_statement ||     'FND_MESSAGE.GET_STRING(''MSC'',''MSC_X_HZ_TP_ALL''))|| ';
               l_statement := l_statement ||           'greatest(viewer_company,';
               l_statement := l_statement ||     'FND_MESSAGE.GET_STRING(''MSC'',''MSC_X_HZ_TP_ALL'')),';
               l_statement := l_statement ||     'decode(viewer_company, customer_name, viewer_company||FND_MESSAGE.GET_STRING(''MSC'',''MSC_X_HZ_TP_ALL'')';
               l_statement := l_statement ||     ', FND_MESSAGE.GET_STRING(''MSC'',''MSC_X_HZ_TP_ALL'')||viewer_company))';

               l_order_group := l_order_group || 'decode(third_party_flag,0,least(viewer_company,';
               l_order_group := l_order_group ||     'FND_MESSAGE.GET_STRING(''MSC'',''MSC_X_HZ_TP_ALL''))|| ';
               l_order_group := l_order_group ||           'greatest(viewer_company,';
               l_order_group := l_order_group ||     'FND_MESSAGE.GET_STRING(''MSC'',''MSC_X_HZ_TP_ALL'')),';
               l_order_group := l_order_group ||     'decode(viewer_company, customer_name, viewer_company||FND_MESSAGE.GET_STRING(''MSC'',''MSC_X_HZ_TP_ALL'')';
               l_order_group := l_order_group ||     ', FND_MESSAGE.GET_STRING(''MSC'',''MSC_X_HZ_TP_ALL'')||viewer_company))';
            end if;

         end if;

         l_statement := l_statement || ', ''NA'') REL,';
         l_order_group := l_order_group || ', ''NA'') ORDER_REL,';
         l_statement := l_statement || l_order_group ;
         l_statement := l_statement || 'PUBLISHER_NAME,PUBLISHER_SITE_NAME, '; -- INVENTORY_ITEM_ID,';
         l_statement := l_statement || ' decode (publisher_order_type, 13, NVL(BASE_ITEM_ID, INVENTORY_ITEM_ID), ';
         l_statement := l_statement || ' 14, NVL(BASE_ITEM_ID, INVENTORY_ITEM_ID),';
         l_statement := l_statement || ' 20, NVL(BASE_ITEM_ID, INVENTORY_ITEM_ID),';
         l_statement := l_statement || ' 22, NVL(BASE_ITEM_ID, INVENTORY_ITEM_ID),';
         l_statement := l_statement || ' 23, NVL(BASE_ITEM_ID, INVENTORY_ITEM_ID),';
         l_statement := l_statement || ' 24, NVL(BASE_ITEM_ID, INVENTORY_ITEM_ID),';
         l_statement := l_statement ||     'INVENTORY_ITEM_ID) INVENTORY_ITEM_ID,';

         -- for order types : po, so, req, po from plan, released plan and planned order
         -- aggregate by the base item name (at the model level) and for the rest of the
         -- order types aggregate at the config or item level.
         l_statement := l_statement || 'decode (publisher_order_type, 13, NVL(BASE_ITEM_NAME, ITEM_NAME), ';
         l_statement := l_statement || '14, NVL(BASE_ITEM_NAME, ITEM_NAME),';
         l_statement := l_statement || '20, NVL(BASE_ITEM_NAME, ITEM_NAME),';
         l_statement := l_statement || '22, NVL(BASE_ITEM_NAME, ITEM_NAME),';
         l_statement := l_statement || '23, NVL(BASE_ITEM_NAME, ITEM_NAME),';
         l_statement := l_statement || '24, NVL(BASE_ITEM_NAME, ITEM_NAME),';
         l_statement := l_statement ||     'ITEM_NAME) ITEM_NAME,';
         --l_statement := l_statement || 'NVL(ITEM_NAME,INVENTORY_ITEM_ID) ITEM_NAME, ';
         l_statement := l_statement ||     ' ITEM_DESCRIPTION,SUPPLIER_ITEM_NAME, ';
         l_statement := l_statement || 'SUPPLIER_NAME,CUSTOMER_NAME,';
         l_statement := l_statement || 'SUPPLIER_SITE_NAME,CUSTOMER_SITE_NAME,';
         l_statement := l_statement || 'PUBLISHER_ORDER_TYPE,PUBLISHER_ORDER_TYPE_DESC,';
         l_statement := l_statement || 'SHIPPING_CONTROL,';
         l_statement := l_statement || 'decode(sys_context(''MSC'',''COMPANY_ID''),publisher_id,nvl(primary_uom,uom_code),';
         l_statement := l_statement ||    'customer_id,tp_uom_code,supplier_id,tp_uom_code,uom_code) UOM,';
         l_statement := l_statement || 'decode(sys_context(''MSC'',''COMPANY_ID''),publisher_id,decode(publisher_order_type, 7, decode(primary_quantity, 0, -99999999, primary_quantity), ';
         l_statement := l_statement ||    '27, decode(primary_quantity, 0, -99999999, primary_quantity), primary_quantity),';
         l_statement := l_statement ||    'customer_id,decode(publisher_order_type, 7, decode(tp_quantity, 0, -99999999, tp_quantity), ';
         l_statement := l_statement ||    '27, decode(tp_quantity, 0, -99999999, tp_quantity), tp_quantity), ' ;
         l_statement := l_statement ||    'supplier_id,decode(publisher_order_type, 7, decode(tp_quantity, 0, -99999999, tp_quantity), ';
         l_statement := l_statement ||    '27, decode(tp_quantity, 0, -99999999, tp_quantity), tp_quantity), ';
         l_statement := l_statement ||    'decode(publisher_order_type, 7, decode(quantity, 0, -99999999, quantity), ';
         l_statement := l_statement ||    '27, decode(quantity, 0, -99999999, quantity), quantity)) QUANTITY,';
         l_statement := l_statement || 'KEY_DATE,SUPPLIER_ID,CUSTOMER_ID,';
         l_statement := l_statement || 'SUPPLIER_SITE_ID,CUSTOMER_SITE_ID,';
         l_statement := l_statement || 'THIRD_PARTY_FLAG,VIEWER_COMPANY,nvl(TP_COMPANY,-1),';
         l_statement := l_statement || 'nvl(BUCKET_TYPE,' || DAY_BUCKET || ')';
         l_statement := l_statement || ',PUBLISHER_ID,PUBLISHER_SITE_ID';
         l_statement := l_statement || ' FROM msc_sup_dem_entries_ui_v';
         l_statement := l_statement || ' WHERE plan_id = -1 AND PUBLISHER_ORDER_TYPE IN (';
         l_statement := l_statement || l_orders;
         l_statement := l_statement || ') ' ;
         l_statement := l_statement || ' AND KEY_DATE >= decode(publisher_order_type, 13, KEY_DATE, 14, KEY_DATE, 15, KEY_DATE, to_date(''' || l_date || ''', ''MM-DD-YYYY'')) ';
         l_statement := l_statement || ' AND KEY_DATE < decode(publisher_order_type, 13, KEY_DATE+1, 14, KEY_DATE+1, 15, KEY_DATE+1, to_date(''' || l_last || ''', ''MM-DD-YYYY'')) ';

         if arg_where_clause is not null then
            -- here remove the reading clause from the arg where clause if it is OR
            if instr(arg_where_clause, 'OR') > 0 and instr(arg_where_clause, 'OR')  < 5 then
               l_statement := l_statement || ' AND (' || substr(arg_where_clause, instr(arg_where_clause, 'OR') + 2) || ')';
            else
               l_statement := l_statement || ' ' || arg_where_clause;
            end if;
         end if;

         if (v_category is not null) then
     l_statement := l_statement || ' and inventory_item_id in (select number1 from msc_form_query where query_id = ' || l_query_id || ')';
         end if;

         l_statement := l_statement || ' ORDER BY ITEM_NAME ' || arg_item_sort || ' , REL ,';
         l_statement := l_statement ||   'PUBLISHER_ORDER_TYPE,PUBLISHER_NAME,PUBLISHER_SITE_NAME,';
         l_statement := l_statement ||   'nvl(TP_COMPANY,-1),nvl(TP_SITE,-1),KEY_DATE ';

         return l_statement;

      EXCEPTION
         WHEN OTHERS THEN
            arg_err_msg := ' prepare_sql ' || SQLERRM || ' ' || l_statement;
            if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
             FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module || 'prepare_sql', SQLERRM);
            end if;
            raise;
      END prepare_sql  ;


      /**
       * the following procedure adds the companion row if required.
       * 1. check if both the order forecast and supply commit are chosen in the user prefs.
       * 2. select for each item if an order forecast is present where the user company
       *    is not the doc owner.
       * 3. check if corresponding supply commit is present.
       * 4. if not add an editable row with 0 as the value for all columns
       *    and user company as the publisher of the doc.
       * 5. set editable flag to editable.
       */
      PROCEDURE add_companion_row(arg_query_id IN NUMBER) IS

         v_name VARCHAR2(250);
         v_next_item number;

      BEGIN


         if (v_supply_commit > 0 AND v_order_forecast > 0)
            AND -- user pref has homogeneous buckets
               (
                ( daily_bucket_count > 0 and weekly_bucket_count = 0 and period_bucket_count = 0) OR
                ( daily_bucket_count = 0 and weekly_bucket_count > 0 and period_bucket_count = 0) OR
                ( daily_bucket_count = 0 and weekly_bucket_count = 0 and period_bucket_count > 0 )
               )
            AND -- user aggregation is at site
               ( myco_agg = ORG_AGG and tpco_agg = ORG_AGG )
         THEN

            -- check if there are any supply commmits for which no order forecast has been posted.
            -- where user is the customer.
            -- want to insert OF where user is customer and supplier has posted supply commit.
            BEGIN
               SELECT a.relation_group,a.order_relation_group,a.inventory_item_id,a.item_name,a.item_description,
                      a.supplier_id,a.customer_id,a.supplier_site_id,a.customer_site_id,
                      a.supplier_name,a.customer_name,a.supplier_org_code,a.customer_org_code,
                      a.order_type_rank,a.uom,a.cust_item,a.sup_item,a.cust_item_desc,
                      a.sup_item_desc,a.tp_uom,a.owner_item,a.owner_item_desc
                 BULK COLLECT INTO
                      var_relation, var_order_relation,var_item_id, var_item_name, var_item_name_desc,
                      var_supplier_id, var_customer_id, var_supplier_site_id,
                      var_customer_site_id, var_supplier, var_customer, var_supplier_org,
                      var_customer_org, var_order_rank, var_uom, var_cust_item, var_sup_item,
                      var_cust_item_desc, var_sup_item_desc, var_tp_uom, var_owner_item,
                      var_owner_item_desc
                 FROM msc_hz_ui_lines a
                 WHERE a.query_id = arg_query_id
                  AND a.order_type = SUPPLY_COMMIT
                  AND a.customer_id = sys_context('MSC','COMPANY_ID')
                  AND a.bucket_type <> 0
                  AND (  period_bucket_count > 0
                         OR ( weekly_bucket_count > 0 and a.bucket_type <> MONTH_BUCKET ) -- cannot be month
                         OR ( daily_bucket_count > 0 and a.bucket_type not in (MONTH_BUCKET, WEEK_BUCKET) )
                  )
                  AND not exists
                  (select * from msc_sup_dem_entries b
                         where b.publisher_order_type = ORDER_FORECAST_CST
                           and b.inventory_item_id = a.inventory_item_id
                           and b.supplier_id = a.supplier_id
                           and b.customer_id = a.customer_id
                           -- make companion row to the site level
                           and b.supplier_site_id = a.supplier_site_id
                           and b.customer_site_id = a.customer_site_id
                           and b.publisher_name = a.customer_name
                           and b.key_date >= p_start_date
                           and b.key_date <= v_last_bkt_date

                       )
                ORDER BY a.item_name,a.relation_group ;

               -- if the above is not null then add data into the pl/sql tables
               --    from (publisher) is the customer (user's company)
               --    order type is order forecast
               --    order type desc is ORDER_FORECAST
               --    customer, item and supplier remain the same.
               --    the order type rank is  order type rank +1

               v_name := get_lookup_name('MSC_X_ORDER_TYPE',ORDER_FORECAST_CST) ;

               if var_relation is not null and var_relation.COUNT > 0 then

                  if v_o_forecast > v_o_supply_commit then
                     v_next_item := 2;
                  else
                     v_next_item := 1;
                  end if;

                  forall i in var_relation.FIRST..var_relation.LAST

                     INSERT INTO msc_hz_ui_lines
                       (LINE_ID,QUERY_ID,RELATION_GROUP,ORDER_RELATION_GROUP,FROM_COMPANY_NAME,FROM_ORG_CODE,
                        ITEM_NAME,ITEM_DESCRIPTION,ORDER_TYPE_RANK,ORDER_TYPE,ORDER_TYPE_DESC,
                        UOM,SUPPLIER_NAME,CUSTOMER_NAME,SUPPLIER_ORG_CODE,CUSTOMER_ORG_CODE,
                        SUPPLIER_ID,CUSTOMER_ID,SUPPLIER_SITE_ID,CUSTOMER_SITE_ID,
                        INVENTORY_ITEM_ID,SUP_ITEM,CUST_ITEM,SUP_ITEM_DESC,CUST_ITEM_DESC,
                        OWNER_ITEM,OWNER_ITEM_DESC,TP_UOM,UOM_CODE,
                        QTY_BUCKET1,QTY_BUCKET2,QTY_BUCKET3,QTY_BUCKET4,
                        QTY_BUCKET5,QTY_BUCKET6,QTY_BUCKET7,QTY_BUCKET8,QTY_BUCKET9,
                        QTY_BUCKET10,QTY_BUCKET11,QTY_BUCKET12,QTY_BUCKET13,QTY_BUCKET14,
                        QTY_BUCKET15,QTY_BUCKET16,QTY_BUCKET17,QTY_BUCKET18,QTY_BUCKET19,
                        QTY_BUCKET20,QTY_BUCKET21,QTY_BUCKET22,QTY_BUCKET23,QTY_BUCKET24,
                        QTY_BUCKET25,QTY_BUCKET26,QTY_BUCKET27,QTY_BUCKET28,QTY_BUCKET29,
                        QTY_BUCKET30,QTY_BUCKET31,QTY_BUCKET32,QTY_BUCKET33,QTY_BUCKET34,
                        QTY_BUCKET35,QTY_BUCKET36,OLD_QTY1,OLD_QTY2,OLD_QTY3,OLD_QTY4,
                        OLD_QTY5,OLD_QTY6,OLD_QTY7,OLD_QTY8,OLD_QTY9,OLD_QTY10,OLD_QTY11,
                        OLD_QTY12,OLD_QTY13,OLD_QTY14,OLD_QTY15,OLD_QTY16,OLD_QTY17,
                        OLD_QTY18,OLD_QTY19,OLD_QTY20,OLD_QTY21,OLD_QTY22,OLD_QTY23,
                        OLD_QTY24,OLD_QTY25,OLD_QTY26,OLD_QTY27,OLD_QTY28,OLD_QTY29,
                        OLD_QTY30,OLD_QTY31,OLD_QTY32,OLD_QTY33,OLD_QTY34,OLD_QTY35,
                        OLD_QTY36,EDITABLE_FLAG,BUCKET_TYPE,PUBLISHER_ID,PUBLISHER_SITE_ID,
                        next_item,unbucketed_qty)
                     VALUES
                       (msc_x_hz_ui_line_id_s.nextval,arg_query_id,nvl(var_relation(i),'NA'),nvl(var_order_relation(i),'NA'),
                        sys_context('MSC','COMPANY_NAME'),var_customer_org(i), var_item_name(i),
                        var_item_name_desc(i),v_o_forecast, ORDER_FORECAST_CST, v_name,
                        var_tp_uom(i), var_supplier(i), var_customer(i), var_supplier_org(i),
                        var_customer_org(i),var_supplier_id(i),var_customer_id(i),
                        var_supplier_site_id(i),var_customer_site_id(i), var_item_id(i),
                        var_sup_item(i),var_cust_item(i),var_sup_item_desc(i),var_cust_item_desc(i),
                        var_owner_item(i), var_owner_item_desc(i),var_uom(i), var_tp_uom(i),
                        null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
                        null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
                        null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
                        null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
                        0,decode(period_bucket_count,0,
                                    (decode(weekly_bucket_count,0,DAY_BUCKET,WEEK_BUCKET)),
                                    MONTH_BUCKET),
                        var_customer_id(i),var_customer_site_id(i),v_next_item,0) ;
                end if;
            EXCEPTION
               when others then
                  arg_err_msg := arg_err_msg ||  ' Add companion row ' || SQLERRM;
                  if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                   FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module || 'add_companion_row', SQLERRM);
                  end if;
               null;
            END ;


            -- check if there are any order forecast with no supply commit posted.
            -- where user is the supplier
            -- want to insert Supply Commit where user is supplier and customer has posted OF.
            BEGIN
               SELECT a.relation_group,a.order_relation_group,a.inventory_item_id,a.item_name,a.item_description,
                      a.supplier_id,a.customer_id,a.supplier_site_id,a.customer_site_id,
                      a.supplier_name,a.customer_name,a.supplier_org_code,a.customer_org_code,
                      a.order_type_rank,a.uom,a.cust_item,a.sup_item,a.cust_item_desc,
                      a.sup_item_desc,a.tp_uom,a.owner_item,a.owner_item_desc
                 BULK COLLECT INTO
                      var_relation, var_order_relation,var_item_id, var_item_name, var_item_name_desc,
                      var_supplier_id, var_customer_id, var_supplier_site_id,
                      var_customer_site_id, var_supplier, var_customer, var_supplier_org,
                      var_customer_org, var_order_rank, var_uom, var_cust_item, var_sup_item,
                      var_cust_item_desc, var_sup_item_desc, var_tp_uom, var_owner_item,
                      var_owner_item_desc
                 FROM msc_hz_ui_lines a
                WHERE a.query_id = arg_query_id
                  AND a.order_type = ORDER_FORECAST_CST
                  AND a.supplier_id = sys_context('MSC','COMPANY_ID')
                  AND a.bucket_type <> 0
                  AND (  period_bucket_count > 0
                         OR ( weekly_bucket_count > 0 and a.bucket_type <> MONTH_BUCKET ) -- cannot be month
                         OR ( daily_bucket_count > 0 and a.bucket_type not in (MONTH_BUCKET, WEEK_BUCKET) )
                  )
                  AND not exists
                       (select * from msc_sup_dem_entries b
                         where b.publisher_order_type = SUPPLY_COMMIT
                           and b.inventory_item_id = a.inventory_item_id
                           and b.supplier_id = a.supplier_id
                           and b.customer_id = a.customer_id
                           -- make companion row to the site level
                           and b.supplier_site_id = a.supplier_site_id
                           and b.customer_site_id = a.customer_site_id
                           and b.publisher_name = a.supplier_name
                           and b.key_date >= p_start_date
                           and b.key_date <= v_last_bkt_date
                       )
                ORDER BY a.item_name,a.relation_group ;

               -- if the above is not null then add data into the pl/sql tables
               --    from (publisher) is the customer (user's company)
               --    order type is order forecast
               --    order type desc is SUPPLY_COMMIT
               --    customer, item and supplier remain the same.
               --    the order type rank is  order type rank +1

               v_name := get_lookup_name('MSC_X_ORDER_TYPE',SUPPLY_COMMIT) ;

               if var_relation is not null and var_relation.COUNT > 0 then

                  if v_o_forecast > v_o_supply_commit then
                     v_next_item := 1;
                  else
                     v_next_item := 2;
                  end if;

                  forall i in var_relation.FIRST..var_relation.LAST
                     INSERT INTO msc_hz_ui_lines
                       (LINE_ID,QUERY_ID,RELATION_GROUP,ORDER_RELATION_GROUP,FROM_COMPANY_NAME,FROM_ORG_CODE,
                        ITEM_NAME,ITEM_DESCRIPTION,ORDER_TYPE_RANK,ORDER_TYPE,ORDER_TYPE_DESC,
                        UOM,SUPPLIER_NAME,CUSTOMER_NAME,SUPPLIER_ORG_CODE,CUSTOMER_ORG_CODE,
                        SUPPLIER_ID,CUSTOMER_ID,SUPPLIER_SITE_ID,CUSTOMER_SITE_ID,
                        INVENTORY_ITEM_ID,SUP_ITEM,CUST_ITEM,SUP_ITEM_DESC,CUST_ITEM_DESC,
                        OWNER_ITEM,OWNER_ITEM_DESC,TP_UOM,UOM_CODE,
                        QTY_BUCKET1,QTY_BUCKET2,QTY_BUCKET3,QTY_BUCKET4,
                        QTY_BUCKET5,QTY_BUCKET6,QTY_BUCKET7,QTY_BUCKET8,QTY_BUCKET9,
                        QTY_BUCKET10,QTY_BUCKET11,QTY_BUCKET12,QTY_BUCKET13,QTY_BUCKET14,
                        QTY_BUCKET15,QTY_BUCKET16,QTY_BUCKET17,QTY_BUCKET18,QTY_BUCKET19,
                        QTY_BUCKET20,QTY_BUCKET21,QTY_BUCKET22,QTY_BUCKET23,QTY_BUCKET24,
                        QTY_BUCKET25,QTY_BUCKET26,QTY_BUCKET27,QTY_BUCKET28,QTY_BUCKET29,
                        QTY_BUCKET30,QTY_BUCKET31,QTY_BUCKET32,QTY_BUCKET33,QTY_BUCKET34,
                        QTY_BUCKET35,QTY_BUCKET36,OLD_QTY1,OLD_QTY2,OLD_QTY3,OLD_QTY4,
                        OLD_QTY5,OLD_QTY6,OLD_QTY7,OLD_QTY8,OLD_QTY9,OLD_QTY10,OLD_QTY11,
                        OLD_QTY12,OLD_QTY13,OLD_QTY14,OLD_QTY15,OLD_QTY16,OLD_QTY17,
                        OLD_QTY18,OLD_QTY19,OLD_QTY20,OLD_QTY21,OLD_QTY22,OLD_QTY23,
                        OLD_QTY24,OLD_QTY25,OLD_QTY26,OLD_QTY27,OLD_QTY28,OLD_QTY29,
                        OLD_QTY30,OLD_QTY31,OLD_QTY32,OLD_QTY33,OLD_QTY34,OLD_QTY35,
                        OLD_QTY36,EDITABLE_FLAG,BUCKET_TYPE,PUBLISHER_ID,PUBLISHER_SITE_ID,
                        next_item, unbucketed_qty)
                     VALUES
                       (msc_x_hz_ui_line_id_s.nextval,arg_query_id,nvl(var_relation(i),'NA'),nvl(var_order_relation(i),'NA'),
                        sys_context('MSC','COMPANY_NAME'),var_supplier_org(i), var_item_name(i),
                        var_item_name_desc(i),v_o_supply_commit, SUPPLY_COMMIT, v_name,
                        var_tp_uom(i),var_supplier(i),var_customer(i),var_supplier_org(i),
                        var_customer_org(i),var_supplier_id(i),var_customer_id(i),
                        var_supplier_site_id(i),var_customer_site_id(i), var_item_id(i),
                        var_sup_item(i), var_cust_item(i),var_sup_item_desc(i),var_cust_item_desc(i),
                        var_owner_item(i),var_owner_item_desc(i),var_uom(i), var_tp_uom(i),
                        null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
                        null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
                        null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
                        null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
                        0,decode(period_bucket_count,0,
                                    (decode(weekly_bucket_count,0,DAY_BUCKET,WEEK_BUCKET)),
                                    MONTH_BUCKET),
                        var_supplier_id(i),var_supplier_site_id(i),v_next_item,0) ;
                end if;
             EXCEPTION
               when others then
                  if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                   FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module || 'add_companion_row', SQLERRM);
                  end if;
                  null;
             END ;

         end if;


      EXCEPTION
         when others then
            if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
             FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module || 'add_companion_row', SQLERRM);
            end if;

      END add_companion_row ;


      /**
       * The foll procedure check if the prev item and the curr item
       * are one and the same.
       * values
       *   2 - if the current item is the same as the prev one
       *   1 - if the current item is not the same as the prev one.
       *
       * This value is used on the UI to not display the item name
       * redundantly .
       *
       * @param the query id of the result set.
       */
      PROCEDURE correct_next_item(arg_query_id IN NUMBER) IS
         i number := 0;
         var_line_id num;
      BEGIN
         SELECT a.inventory_item_id, a.line_id
           BULK COLLECT INTO var_item_id, var_line_id
           FROM msc_hz_ui_lines a
          WHERE a.query_id = arg_query_id
          ORDER BY item_name, order_relation_group, order_type_rank ;

         FOR i in var_item_id.FIRST..var_item_id.LAST loop

            if i = var_item_id.FIRST then
               var_next_item(i) := 1;
            else
               if var_item_id(i) = var_item_id(i-1) then
                  var_next_item(i) := 2;
               else
                  var_next_item(i) := 1;
               end if;
            end if;

         END LOOP;

         -- now do bulk update
         FORALL i in var_line_id.FIRST..var_line_id.LAST
            UPDATE msc_hz_ui_lines
               SET next_item = var_next_item(i)
             WHERE query_id = arg_query_id
               AND line_id = var_line_id(i);
      EXCEPTION
         when others then
            if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
             FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module || 'correct_next_item', SQLERRM);
            end if;
      END correct_next_item;

      /**
       * the foll procedure inserts the total into the temp tables.
       * NOTE: currently this is not being used on the UI.
       *
       * @param the order type.
       */
      PROCEDURE insert_total(v_order IN NUMBER) IS
         v_name VARCHAR2(250);
      BEGIN
         v_name := get_lookup_name('MSC_X_ORDER_TYPE',v_order) ;
         OPEN c_total(v_order) ;
         FETCH c_total BULK COLLECT INTO
            var_relation,var_order_relation,var_from_co_name,var_from_org_name,var_item_name,
            var_item_name_desc,var_supplier,var_customer,var_supplier_org,
            var_customer_org,var_uom,var_supplier_id,var_customer_id,var_supplier_site_id,
            var_customer_site_id,var_item_id,var_qty_nobkt,var_qty1,var_qty2,
            var_qty3,var_qty4,var_qty5,var_qty6,var_qty7,var_qty8,var_qty9,var_qty10,
            var_qty11,var_qty12,var_qty13,var_qty14,var_qty15,var_qty16,var_qty17,
            var_qty18,var_qty19,var_qty20,var_qty21,var_qty22,var_qty23,var_qty24,
            var_qty25,var_qty26,var_qty27,var_qty28,var_qty29,var_qty30,var_qty31,
            var_qty32,var_qty33,var_qty34,var_qty35,var_qty36 ;
         CLOSE c_total;

         if var_relation is not null and var_relation.COUNT > 0 then
            FORALL i IN var_relation.FIRST..var_relation.LAST
               INSERT INTO msc_hz_ui_lines
                 (LINE_ID,QUERY_ID,RELATION_GROUP,ORDER_RELATION_GROUP,FROM_COMPANY_NAME,FROM_ORG_CODE,
                  ITEM_NAME,ITEM_DESCRIPTION,ORDER_TYPE_RANK,ORDER_TYPE,ORDER_TYPE_DESC,
                  UOM,SUPPLIER_NAME,CUSTOMER_NAME,SUPPLIER_ORG_CODE,CUSTOMER_ORG_CODE,
                  SUPPLIER_ID,CUSTOMER_ID,SUPPLIER_SITE_ID,CUSTOMER_SITE_ID,INVENTORY_ITEM_ID,
                  UNBUCKETED_QTY,QTY_BUCKET1,QTY_BUCKET2,QTY_BUCKET3,QTY_BUCKET4,
                  QTY_BUCKET5,QTY_BUCKET6,QTY_BUCKET7,QTY_BUCKET8,QTY_BUCKET9,
                  QTY_BUCKET10,QTY_BUCKET11,QTY_BUCKET12,QTY_BUCKET13,QTY_BUCKET14,
                  QTY_BUCKET15,QTY_BUCKET16,QTY_BUCKET17,QTY_BUCKET18,QTY_BUCKET19,
                  QTY_BUCKET20,QTY_BUCKET21,QTY_BUCKET22,QTY_BUCKET23,QTY_BUCKET24,
                  QTY_BUCKET25,QTY_BUCKET26,QTY_BUCKET27,QTY_BUCKET28,QTY_BUCKET29,
                  QTY_BUCKET30,QTY_BUCKET31,QTY_BUCKET32,QTY_BUCKET33,QTY_BUCKET34,
                  QTY_BUCKET35,QTY_BUCKET36,OLD_QTY1,OLD_QTY2,OLD_QTY3,OLD_QTY4,
                  OLD_QTY5,OLD_QTY6,OLD_QTY7,OLD_QTY8,OLD_QTY9,OLD_QTY10,OLD_QTY11,
                  OLD_QTY12,OLD_QTY13,OLD_QTY14,OLD_QTY15,OLD_QTY16,OLD_QTY17,
                  OLD_QTY18,OLD_QTY19,OLD_QTY20,OLD_QTY21,OLD_QTY22,OLD_QTY23,
                  OLD_QTY24,OLD_QTY25,OLD_QTY26,OLD_QTY27,OLD_QTY28,OLD_QTY29,
                  OLD_QTY30,OLD_QTY31,OLD_QTY32,OLD_QTY33,OLD_QTY34,OLD_QTY35,
                  OLD_QTY36,EDITABLE_FLAG)
               VALUES
                 (msc_x_hz_ui_line_id_s.nextval,arg_query_id,nvl(var_relation(i),'NA'),nvl(var_order_relation(i),'NA'),
                  nvl(var_from_co_name(i),'NA'),var_from_org_name(i),var_item_name(i),
                  var_item_name_desc(i),0,v_order ,v_name,var_uom(i),
                  var_supplier(i),var_customer(i),var_supplier_org(i),
                  var_customer_org(i),var_supplier_id(i),var_customer_id(i),
                  var_supplier_site_id(i),var_customer_site_id(i),var_item_id(i),
                  var_qty_nobkt(i),var_qty1(i),var_qty2(i),
                  var_qty3(i),var_qty4(i),var_qty5(i),var_qty6(i),var_qty7(i),
                  var_qty8(i),var_qty9(i),var_qty10(i),var_qty11(i),var_qty12(i),
                  var_qty13(i),var_qty14(i),var_qty15(i),var_qty16(i),var_qty17(i),
                  var_qty18(i),var_qty19(i),var_qty20(i),var_qty21(i),var_qty22(i),
                  var_qty23(i),var_qty24(i),var_qty25(i),var_qty26(i),var_qty27(i),
                  var_qty28(i),var_qty29(i),var_qty30(i),var_qty31(i),var_qty32(i),
                  var_qty33(i),var_qty34(i),var_qty35(i),var_qty36(i),
                  var_qty1(i),var_qty2(i),var_qty3(i),var_qty4(i),var_qty5(i),
                  var_qty6(i),var_qty7(i),var_qty8(i),var_qty9(i),var_qty10(i),
                  var_qty11(i),var_qty12(i),var_qty13(i),var_qty14(i),var_qty15(i),
                  var_qty16(i),var_qty17(i),var_qty18(i),var_qty19(i),var_qty20(i),
                  var_qty21(i),var_qty22(i),var_qty23(i),var_qty24(i),var_qty25(i),
                  var_qty26(i),var_qty27(i),var_qty28(i),var_qty29(i),var_qty30(i),
                  var_qty31(i),var_qty32(i),var_qty33(i),var_qty34(i),var_qty35(i),var_qty36(i),1) ;

         end if;
      EXCEPTION
         when others then
            arg_err_msg := arg_err_msg || ' insert total ' ||  SQLERRM;
            if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
             FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module || 'insert_total', SQLERRM);
            end if;
            if c_Total%ISOPEN then
               CLOSE c_Total;
            end if;
      END ;

     PROCEDURE invert_quantities(arg_query_id NUMBER, p_order_type NUMBER)
     IS
     BEGIN
        UPDATE msc_hz_ui_lines
          SET UNBUCKETED_QTY = -UNBUCKETED_QTY,
                QTY_BUCKET1 = -QTY_BUCKET1,
                QTY_BUCKET2 = -QTY_BUCKET2,
                QTY_BUCKET3 = -QTY_BUCKET3,
                QTY_BUCKET4 = -QTY_BUCKET4,
                QTY_BUCKET5 = -QTY_BUCKET5,
                QTY_BUCKET6 = -QTY_BUCKET6,
                QTY_BUCKET7 = -QTY_BUCKET7,
                QTY_BUCKET8 = -QTY_BUCKET8,
                QTY_BUCKET9 = -QTY_BUCKET9,
                QTY_BUCKET10 = -QTY_BUCKET10,
                QTY_BUCKET11 = -QTY_BUCKET11,
                QTY_BUCKET12 = -QTY_BUCKET12,
                QTY_BUCKET13 = -QTY_BUCKET13,
                QTY_BUCKET14 = -QTY_BUCKET14,
                QTY_BUCKET15 = -QTY_BUCKET15,
                QTY_BUCKET16 = -QTY_BUCKET16,
                QTY_BUCKET17 = -QTY_BUCKET17,
                QTY_BUCKET18 = -QTY_BUCKET18,
                QTY_BUCKET19 = -QTY_BUCKET19,
                QTY_BUCKET20 = -QTY_BUCKET20,
                QTY_BUCKET21 = -QTY_BUCKET21,
                QTY_BUCKET22 = -QTY_BUCKET22,
                QTY_BUCKET23 = -QTY_BUCKET23,
                QTY_BUCKET24 = -QTY_BUCKET24,
                QTY_BUCKET25 = -QTY_BUCKET25,
                QTY_BUCKET26 = -QTY_BUCKET26,
                QTY_BUCKET27 = -QTY_BUCKET27,
                QTY_BUCKET28 = -QTY_BUCKET28,
                QTY_BUCKET29 = -QTY_BUCKET29,
                QTY_BUCKET30 = -QTY_BUCKET30,
                QTY_BUCKET31 = -QTY_BUCKET31,
                QTY_BUCKET32 = -QTY_BUCKET32,
                QTY_BUCKET33 = -QTY_BUCKET33,
                QTY_BUCKET34 = -QTY_BUCKET34,
                QTY_BUCKET35 = -QTY_BUCKET35,
                QTY_BUCKET36 = -QTY_BUCKET36
        WHERE order_type = p_order_type
            AND query_id = arg_query_id;

     END;

      PROCEDURE delete_order_type(arg_query_id NUMBER, p_order_type NUMBER)
     IS
     BEGIN

        DELETE FROM msc_hz_ui_lines
          WHERE order_type = p_order_type
          AND query_id = arg_query_id;

     EXCEPTION
        WHEN OTHERS THEN
          NULL;
     END;


      PROCEDURE insert_net_forecast(arg_query_id NUMBER)
     IS

         CURSOR c_net_forecast
         IS
            SELECT ORDER_RELATION_GROUP,FROM_COMPANY_NAME,FROM_ORG_CODE,ITEM_NAME,ITEM_DESCRIPTION,
                   SUPPLIER_NAME,CUSTOMER_NAME,SUPPLIER_ORG_CODE,CUSTOMER_ORG_CODE,UOM,
                   SUPPLIER_ID,CUSTOMER_ID,INVENTORY_ITEM_ID,
                   ROUND( sum(UNBUCKETED_QTY), 6)  q_0,ROUND( sum(QTY_BUCKET1), 6)  q_1,
                   ROUND( sum(QTY_BUCKET2), 6)  q_2,ROUND( sum(QTY_BUCKET3), 6)  q_3, ROUND( sum(QTY_BUCKET4), 6)  q_4,
                   ROUND( sum(QTY_BUCKET5), 6)  q_5,ROUND( sum(QTY_BUCKET6), 6)  q_6,ROUND( sum(QTY_BUCKET7), 6)  q_7,
                   ROUND( sum(QTY_BUCKET8), 6)  q_8,ROUND( sum(QTY_BUCKET9), 6)  q_9,ROUND( sum(QTY_BUCKET10), 6)  q_10,
                   ROUND( sum(QTY_BUCKET11), 6)  q_11,ROUND( sum(QTY_BUCKET12), 6)  q_12,ROUND( sum(QTY_BUCKET13), 6)  q_13,
                   ROUND( sum(QTY_BUCKET14), 6)  q_14,ROUND( sum(QTY_BUCKET15), 6)  q_15,ROUND( sum(QTY_BUCKET16), 6)  q_16,
                   ROUND( sum(QTY_BUCKET17), 6)  q_17,ROUND( sum(QTY_BUCKET18), 6)  q_18,ROUND( sum(QTY_BUCKET19), 6)  q_19,
                   ROUND( sum(QTY_BUCKET20), 6)  q_20,ROUND( sum(QTY_BUCKET21), 6)  q_21,ROUND( sum(QTY_BUCKET22), 6)  q_22,
                   ROUND( sum(QTY_BUCKET23), 6)  q_23,ROUND( sum(QTY_BUCKET24), 6)  q_24,ROUND( sum(QTY_BUCKET25), 6)  q_25,
                   ROUND( sum(QTY_BUCKET26), 6)  q_26,ROUND( sum(QTY_BUCKET27), 6)  q_27,ROUND( sum(QTY_BUCKET28), 6)  q_28,
                   ROUND( sum(QTY_BUCKET29), 6)  q_29,ROUND( sum(QTY_BUCKET30), 6)  q_30,ROUND( sum(QTY_BUCKET31), 6)  q_31,
                   ROUND( sum(QTY_BUCKET32), 6)  q_32,ROUND( sum(QTY_BUCKET33), 6)  q_33,ROUND( sum(QTY_BUCKET34), 6)  q_34,
                   ROUND( sum(QTY_BUCKET35), 6)  q_35,ROUND( sum(QTY_BUCKET36), 6)  q_36
              FROM msc_hz_ui_lines
             WHERE ORDER_TYPE IN (ORDER_FORECAST_CST, REQUISITION,PURCHASE_ORDER)
               AND query_id = arg_query_id
            GROUP BY ORDER_RELATION_GROUP, FROM_COMPANY_NAME,FROM_ORG_CODE,ITEM_NAME,ITEM_DESCRIPTION,
                   SUPPLIER_NAME,CUSTOMER_NAME,SUPPLIER_ORG_CODE,CUSTOMER_ORG_CODE,UOM,
                   SUPPLIER_ID,CUSTOMER_ID,INVENTORY_ITEM_ID
            HAVING sum(decode(order_type, ORDER_FORECAST_CST, 1, 0)) > 0;

         v_calculation_name VARCHAR2(255) := fnd_message.get_string('MSC','MSC_X_HZ_NET_FORECAST') ;

     BEGIN
         invert_quantities(arg_query_id, REQUISITION);
       invert_quantities(arg_query_id, PURCHASE_ORDER);

         OPEN c_net_forecast;
         FETCH c_net_forecast BULK COLLECT INTO
            var_order_relation,var_from_co_name,var_from_org_name,var_item_name,
            var_item_name_desc,var_supplier,var_customer,var_supplier_org,
            var_customer_org,var_uom,var_supplier_id,var_customer_id,
            var_item_id,var_qty_nobkt,var_qty1,var_qty2,
            var_qty3,var_qty4,var_qty5,var_qty6,var_qty7,var_qty8,var_qty9,var_qty10,
            var_qty11,var_qty12,var_qty13,var_qty14,var_qty15,var_qty16,var_qty17,
            var_qty18,var_qty19,var_qty20,var_qty21,var_qty22,var_qty23,var_qty24,
            var_qty25,var_qty26,var_qty27,var_qty28,var_qty29,var_qty30,var_qty31,
            var_qty32,var_qty33,var_qty34,var_qty35,var_qty36 ;
         CLOSE c_net_forecast;

         invert_quantities(arg_query_id, REQUISITION);
       invert_quantities(arg_query_id, PURCHASE_ORDER);

         if var_order_relation is not null and var_order_relation.COUNT > 0 then
            FORALL i IN var_order_relation.FIRST..var_order_relation.LAST
               INSERT INTO msc_hz_ui_lines
                 (LINE_ID,QUERY_ID,RELATION_GROUP,ORDER_RELATION_GROUP,FROM_COMPANY_NAME,FROM_ORG_CODE,
                  ITEM_NAME,ITEM_DESCRIPTION,ORDER_TYPE_RANK,ORDER_TYPE,ORDER_TYPE_DESC,
                  UOM,SUPPLIER_NAME,CUSTOMER_NAME,SUPPLIER_ORG_CODE,CUSTOMER_ORG_CODE,
                  SUPPLIER_ID,CUSTOMER_ID,SUPPLIER_SITE_ID,CUSTOMER_SITE_ID,INVENTORY_ITEM_ID,
                  UNBUCKETED_QTY,QTY_BUCKET1,QTY_BUCKET2,QTY_BUCKET3,QTY_BUCKET4,
                  QTY_BUCKET5,QTY_BUCKET6,QTY_BUCKET7,QTY_BUCKET8,QTY_BUCKET9,
                  QTY_BUCKET10,QTY_BUCKET11,QTY_BUCKET12,QTY_BUCKET13,QTY_BUCKET14,
                  QTY_BUCKET15,QTY_BUCKET16,QTY_BUCKET17,QTY_BUCKET18,QTY_BUCKET19,
                  QTY_BUCKET20,QTY_BUCKET21,QTY_BUCKET22,QTY_BUCKET23,QTY_BUCKET24,
                  QTY_BUCKET25,QTY_BUCKET26,QTY_BUCKET27,QTY_BUCKET28,QTY_BUCKET29,
                  QTY_BUCKET30,QTY_BUCKET31,QTY_BUCKET32,QTY_BUCKET33,QTY_BUCKET34,
                  QTY_BUCKET35,QTY_BUCKET36,OLD_QTY1,OLD_QTY2,OLD_QTY3,OLD_QTY4,
                  OLD_QTY5,OLD_QTY6,OLD_QTY7,OLD_QTY8,OLD_QTY9,OLD_QTY10,OLD_QTY11,
                  OLD_QTY12,OLD_QTY13,OLD_QTY14,OLD_QTY15,OLD_QTY16,OLD_QTY17,
                  OLD_QTY18,OLD_QTY19,OLD_QTY20,OLD_QTY21,OLD_QTY22,OLD_QTY23,
                  OLD_QTY24,OLD_QTY25,OLD_QTY26,OLD_QTY27,OLD_QTY28,OLD_QTY29,
                  OLD_QTY30,OLD_QTY31,OLD_QTY32,OLD_QTY33,OLD_QTY34,OLD_QTY35,
                  OLD_QTY36,EDITABLE_FLAG)
               VALUES
                 (msc_x_hz_ui_line_id_s.nextval,arg_query_id,'NA',nvl(var_order_relation(i),'NA'),
                  nvl(var_from_co_name(i),'NA'),var_from_org_name(i),var_item_name(i),
                  var_item_name_desc(i),39,-1,v_calculation_name,var_uom(i),var_supplier(i),
                  var_customer(i),var_supplier_org(i),var_customer_org(i),
                  var_supplier_id(i),var_customer_id(i),'NA',
                  'NA',var_item_id(i),var_qty_nobkt(i),var_qty1(i),var_qty2(i),
                  var_qty3(i),var_qty4(i),var_qty5(i),var_qty6(i),var_qty7(i),
                  var_qty8(i),var_qty9(i),var_qty10(i),var_qty11(i),var_qty12(i),
                  var_qty13(i),var_qty14(i),var_qty15(i),var_qty16(i),var_qty17(i),
                  var_qty18(i),var_qty19(i),var_qty20(i),var_qty21(i),var_qty22(i),
                  var_qty23(i),var_qty24(i),var_qty25(i),var_qty26(i),var_qty27(i),
                  var_qty28(i),var_qty29(i),var_qty30(i),var_qty31(i),var_qty32(i),
                  var_qty33(i),var_qty34(i),var_qty35(i),var_qty36(i),var_qty1(i),var_qty2(i),
                  var_qty3(i),var_qty4(i),var_qty5(i),var_qty6(i),var_qty7(i),
                  var_qty8(i),var_qty9(i),var_qty10(i),var_qty11(i),var_qty12(i),
                  var_qty13(i),var_qty14(i),var_qty15(i),var_qty16(i),var_qty17(i),
                  var_qty18(i),var_qty19(i),var_qty20(i),var_qty21(i),var_qty22(i),
                  var_qty23(i),var_qty24(i),var_qty25(i),var_qty26(i),var_qty27(i),
                  var_qty28(i),var_qty29(i),var_qty30(i),var_qty31(i),var_qty32(i),
                  var_qty33(i),var_qty34(i),var_qty35(i),var_qty36(i),1) ;

         end if;
      EXCEPTION
         when others then
            arg_err_msg := arg_err_msg || ' insert running total ' || SQLERRM;
            if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
             FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module || 'insert_running_total', SQLERRM);
            end if;
            if c_runTotal%ISOPEN then
               CLOSE c_runTotal;
            end if;
      END insert_net_forecast;

   -- post processing for safety stock and PAB.
   -- in the case where ss/pab are 0's for a particular bucket
   -- display the ss/pab value of the previous bucket.
   PROCEDURE fill_ss_pab_empty_buckets IS
   default_ss NUMBER := 0;
   default_pab NUMBER := 0;
   i NUMBER := 1;
   BEGIN


  -- safety stock

   FOR i in var_relation.FIRST..var_relation.LAST LOOP
  if(var_order(i) = SAFETY_STOCK or var_order(i) = PROJ_AVAIL_BAL) then
       BEGIN
    select quantity into default_ss
    from msc_sup_dem_entries_ui_v
    where nvl(base_item_id,inventory_item_id) = var_item_id(i)
    and publisher_order_type = 7
    and publisher_id = var_pub_id(i)
    and publisher_site_id = var_pub_site_id(i)
    and key_date < p_start_date
    and rownum < 2
    order by key_date asc;

    EXCEPTION
      WHEN no_data_found THEN
     default_ss := 0;
     END;
       BEGIN
    select quantity into default_pab
    from msc_sup_dem_entries_ui_v
    where nvl(base_item_id,inventory_item_id) = var_item_id(i)
    and publisher_order_type = 8
    and publisher_id = var_pub_id(i)
    and publisher_site_id = var_pub_site_id(i)
    and key_date < p_start_date
    and rownum < 2
    order by key_date asc;

    EXCEPTION
      WHEN no_data_found THEN
     default_pab := 0;
       END;
    if var_order(i) = SAFETY_STOCK then
     if var_qty1(i) = 0 then
      var_qty1(i) := default_ss;
     elsif var_qty1(i) = -99999999 then
      var_qty1(i) := 0;
     end if;
    elsif var_order(i) = PROJ_AVAIL_BAL then
     if var_qty1(i) = 0 then
      var_qty1(i) := default_pab;
     elsif var_qty1(i) = -99999999 then
      var_qty1(i) := 0;
     end if;
    end if;

    if var_qty2(i) = 0 then
     var_qty2(i) := var_qty1(i);
    elsif var_qty2(i) = -99999999 then
     var_qty2(i) := 0;
    end if;

    if var_qty3(i) = 0 then
     var_qty3(i) := var_qty2(i);
    elsif var_qty3(i) = -99999999 then
     var_qty3(i) := 0;
    end if;

    if var_qty4(i) = 0 then
     var_qty4(i) := var_qty3(i);
    elsif var_qty4(i) = -99999999 then
     var_qty4(i) := 0;
    end if;

    if var_qty5(i) = 0 then
     var_qty5(i) := var_qty4(i);
    elsif var_qty5(i) = -99999999 then
     var_qty5(i) := 0;
    end if;

    if var_qty6(i) = 0 then
     var_qty6(i) := var_qty5(i);
    elsif var_qty6(i) = -99999999 then
     var_qty6(i) := 0;
    end if;

    if var_qty7(i) = 0 then
     var_qty7(i) := var_qty6(i);
    elsif var_qty7(i) = -99999999 then
     var_qty7(i) := 0;
    end if;

    if var_qty8(i) = 0 then
     var_qty8(i) := var_qty7(i);
    elsif var_qty8(i) = -99999999 then
     var_qty8(i) := 0;
    end if;

    if var_qty9(i) = 0 then
     var_qty9(i) := var_qty8(i);
    elsif var_qty9(i) = -99999999 then
     var_qty9(i) := 0;
    end if;

    if var_qty10(i) = 0 then
     var_qty10(i) := var_qty9(i);
    elsif var_qty10(i) = -99999999 then
     var_qty10(i) := 0;
    end if;

    if var_qty11(i) = 0 then
     var_qty11(i) := var_qty10(i);
    elsif var_qty11(i) = -99999999 then
     var_qty11(i) := 0;
    end if;

    if var_qty12(i) = 0 then
     var_qty12(i) := var_qty11(i);
    elsif var_qty12(i) = -99999999 then
     var_qty12(i) := 0;
    end if;

    if var_qty13(i) = 0 then
     var_qty13(i) := var_qty12(i);
    elsif var_qty13(i) = -99999999 then
     var_qty13(i) := 0;
    end if;

    if var_qty14(i) = 0 then
     var_qty14(i) := var_qty13(i);
    elsif var_qty14(i) = -99999999 then
     var_qty14(i) := 0;
    end if;

    if var_qty15(i) = 0 then
     var_qty15(i) := var_qty14(i);
    elsif var_qty15(i) = -99999999 then
     var_qty15(i) := 0;
    end if;

    if var_qty16(i) = 0 then
     var_qty16(i) := var_qty15(i);
    elsif var_qty16(i) = -99999999 then
     var_qty16(i) := 0;
    end if;

    if var_qty17(i) = 0 then
     var_qty17(i) := var_qty16(i);
    elsif var_qty17(i) = -99999999 then
     var_qty17(i) := 0;
    end if;

    if var_qty18(i) = 0 then
     var_qty18(i) := var_qty17(i);
    elsif var_qty18(i) = -99999999 then
     var_qty18(i) := 0;
    end if;

    if var_qty19(i) = 0 then
     var_qty19(i) := var_qty18(i);
    elsif var_qty19(i) = -99999999 then
     var_qty19(i) := 0;
    end if;

    if var_qty20(i) = 0 then
     var_qty20(i) := var_qty19(i);
    elsif var_qty20(i) = -99999999 then
     var_qty20(i) := 0;
    end if;

    if var_qty21(i) = 0 then
     var_qty21(i) := var_qty20(i);
    elsif var_qty21(i) = -99999999 then
     var_qty21(i) := 0;
    end if;

    if var_qty22(i) = 0 then
     var_qty22(i) := var_qty21(i);
    elsif var_qty22(i) = -99999999 then
     var_qty22(i) := 0;
    end if;

    if var_qty23(i) = 0 then
     var_qty23(i) := var_qty22(i);
    elsif var_qty23(i) = -99999999 then
     var_qty23(i) := 0;
    end if;

    if var_qty24(i) = 0 then
     var_qty24(i) := var_qty23(i);
    elsif var_qty24(i) = -99999999 then
     var_qty24(i) := 0;
    end if;

    if var_qty25(i) = 0 then
     var_qty25(i) := var_qty24(i);
    elsif var_qty25(i) = -99999999 then
     var_qty25(i) := 0;
    end if;

    if var_qty26(i) = 0 then
     var_qty26(i) := var_qty25(i);
    elsif var_qty26(i) = -99999999 then
     var_qty26(i) := 0;
    end if;

    if var_qty27(i) = 0 then
     var_qty27(i) := var_qty26(i);
    elsif var_qty27(i) = -99999999 then
     var_qty27(i) := 0;
    end if;

    if var_qty28(i) = 0 then
     var_qty28(i) := var_qty27(i);
    elsif var_qty28(i) = -99999999 then
     var_qty28(i) := 0;
    end if;

    if var_qty29(i) = 0 then
     var_qty29(i) := var_qty28(i);
    elsif var_qty29(i) = -99999999 then
     var_qty29(i) := 0;
    end if;

    if var_qty30(i) = 0 then
     var_qty30(i) := var_qty29(i);
    elsif var_qty30(i) = -99999999 then
     var_qty30(i) := 0;
    end if;

    if var_qty31(i) = 0 then
     var_qty31(i) := var_qty30(i);
    elsif var_qty31(i) = -99999999 then
     var_qty31(i) := 0;
    end if;

    if var_qty32(i) = 0 then
     var_qty32(i) := var_qty31(i);
    elsif var_qty32(i) = -99999999 then
     var_qty32(i) := 0;
    end if;

    if var_qty33(i) = 0 then
     var_qty33(i) := var_qty32(i);
    elsif var_qty33(i) = -99999999 then
     var_qty33(i) := 0;
    end if;

    if var_qty34(i) = 0 then
     var_qty34(i) := var_qty33(i);
    elsif var_qty34(i) = -99999999 then
     var_qty34(i) := 0;
    end if;

    if var_qty35(i) = 0 then
     var_qty35(i) := var_qty34(i);
    elsif var_qty35(i) = -99999999 then
     var_qty35(i) := 0;
    end if;

    if var_qty36(i) = 0 then
     var_qty36(i) := var_qty35(i);
    elsif var_qty36(i) = -99999999 then
     var_qty36(i) := 0;
    end if;
   end if;

   END LOOP;

   END;

      PROCEDURE insert_total_supply(arg_query_id NUMBER)
     IS

         CURSOR c_total_supply
         IS
            SELECT ORDER_RELATION_GROUP,FROM_COMPANY_NAME,FROM_ORG_CODE,ITEM_NAME,ITEM_DESCRIPTION,
                   SUPPLIER_NAME,CUSTOMER_NAME,SUPPLIER_ORG_CODE,CUSTOMER_ORG_CODE,UOM,
                   SUPPLIER_ID,CUSTOMER_ID,INVENTORY_ITEM_ID,
                   ROUND( sum(UNBUCKETED_QTY), 6)  q_0,ROUND( sum(QTY_BUCKET1), 6)  q_1,
                   ROUND( sum(QTY_BUCKET2), 6)  q_2,ROUND( sum(QTY_BUCKET3), 6)  q_3, ROUND( sum(QTY_BUCKET4), 6)  q_4,
                   ROUND( sum(QTY_BUCKET5), 6)  q_5,ROUND( sum(QTY_BUCKET6), 6)  q_6,ROUND( sum(QTY_BUCKET7), 6)  q_7,
                   ROUND( sum(QTY_BUCKET8), 6)  q_8,ROUND( sum(QTY_BUCKET9), 6)  q_9,ROUND( sum(QTY_BUCKET10), 6)  q_10,
                   ROUND( sum(QTY_BUCKET11), 6)  q_11,ROUND( sum(QTY_BUCKET12), 6)  q_12,ROUND( sum(QTY_BUCKET13), 6)  q_13,
                   ROUND( sum(QTY_BUCKET14), 6)  q_14,ROUND( sum(QTY_BUCKET15), 6)  q_15,ROUND( sum(QTY_BUCKET16), 6)  q_16,
                   ROUND( sum(QTY_BUCKET17), 6)  q_17,ROUND( sum(QTY_BUCKET18), 6)  q_18,ROUND( sum(QTY_BUCKET19), 6)  q_19,
                   ROUND( sum(QTY_BUCKET20), 6)  q_20,ROUND( sum(QTY_BUCKET21), 6)  q_21,ROUND( sum(QTY_BUCKET22), 6)  q_22,
                   ROUND( sum(QTY_BUCKET23), 6)  q_23,ROUND( sum(QTY_BUCKET24), 6)  q_24,ROUND( sum(QTY_BUCKET25), 6)  q_25,
                   ROUND( sum(QTY_BUCKET26), 6)  q_26,ROUND( sum(QTY_BUCKET27), 6)  q_27,ROUND( sum(QTY_BUCKET28), 6)  q_28,
                   ROUND( sum(QTY_BUCKET29), 6)  q_29,ROUND( sum(QTY_BUCKET30), 6)  q_30,ROUND( sum(QTY_BUCKET31), 6)  q_31,
                   ROUND( sum(QTY_BUCKET32), 6)  q_32,ROUND( sum(QTY_BUCKET33), 6)  q_33,ROUND( sum(QTY_BUCKET34), 6)  q_34,
                   ROUND( sum(QTY_BUCKET35), 6)  q_35,ROUND( sum(QTY_BUCKET36), 6)  q_36
              FROM msc_hz_ui_lines
             WHERE ORDER_TYPE IN (SUPPLY_COMMIT,SALES_ORDER)
               AND query_id = arg_query_id
            GROUP BY ORDER_RELATION_GROUP, FROM_COMPANY_NAME,FROM_ORG_CODE,ITEM_NAME,ITEM_DESCRIPTION,
                   SUPPLIER_NAME,CUSTOMER_NAME,SUPPLIER_ORG_CODE,CUSTOMER_ORG_CODE,UOM,
                   SUPPLIER_ID,CUSTOMER_ID,INVENTORY_ITEM_ID;

         v_calculation_name VARCHAR2(255) := fnd_message.get_string('MSC','MSC_X_HZ_TOTAL_SUPPLY') ;

     BEGIN
         OPEN c_total_supply;
         FETCH c_total_supply BULK COLLECT INTO
            var_order_relation,var_from_co_name,var_from_org_name,var_item_name,
            var_item_name_desc,var_supplier,var_customer,var_supplier_org,
            var_customer_org,var_uom,var_supplier_id,var_customer_id,
            var_item_id,var_qty_nobkt,var_qty1,var_qty2,
            var_qty3,var_qty4,var_qty5,var_qty6,var_qty7,var_qty8,var_qty9,var_qty10,
            var_qty11,var_qty12,var_qty13,var_qty14,var_qty15,var_qty16,var_qty17,
            var_qty18,var_qty19,var_qty20,var_qty21,var_qty22,var_qty23,var_qty24,
            var_qty25,var_qty26,var_qty27,var_qty28,var_qty29,var_qty30,var_qty31,
            var_qty32,var_qty33,var_qty34,var_qty35,var_qty36 ;
         CLOSE c_total_supply;

         IF var_order_relation is not null and var_order_relation.COUNT > 0 THEN
            FORALL i IN var_order_relation.FIRST..var_order_relation.LAST
               INSERT INTO msc_hz_ui_lines
                 (LINE_ID,QUERY_ID,RELATION_GROUP,ORDER_RELATION_GROUP,FROM_COMPANY_NAME,FROM_ORG_CODE,
                  ITEM_NAME,ITEM_DESCRIPTION,ORDER_TYPE_RANK,ORDER_TYPE,ORDER_TYPE_DESC,
                  UOM,SUPPLIER_NAME,CUSTOMER_NAME,SUPPLIER_ORG_CODE,CUSTOMER_ORG_CODE,
                  SUPPLIER_ID,CUSTOMER_ID,SUPPLIER_SITE_ID,CUSTOMER_SITE_ID,INVENTORY_ITEM_ID,
                  UNBUCKETED_QTY,QTY_BUCKET1,QTY_BUCKET2,QTY_BUCKET3,QTY_BUCKET4,
                  QTY_BUCKET5,QTY_BUCKET6,QTY_BUCKET7,QTY_BUCKET8,QTY_BUCKET9,
                  QTY_BUCKET10,QTY_BUCKET11,QTY_BUCKET12,QTY_BUCKET13,QTY_BUCKET14,
                  QTY_BUCKET15,QTY_BUCKET16,QTY_BUCKET17,QTY_BUCKET18,QTY_BUCKET19,
                  QTY_BUCKET20,QTY_BUCKET21,QTY_BUCKET22,QTY_BUCKET23,QTY_BUCKET24,
                  QTY_BUCKET25,QTY_BUCKET26,QTY_BUCKET27,QTY_BUCKET28,QTY_BUCKET29,
                  QTY_BUCKET30,QTY_BUCKET31,QTY_BUCKET32,QTY_BUCKET33,QTY_BUCKET34,
                  QTY_BUCKET35,QTY_BUCKET36,OLD_QTY1,OLD_QTY2,OLD_QTY3,OLD_QTY4,
                  OLD_QTY5,OLD_QTY6,OLD_QTY7,OLD_QTY8,OLD_QTY9,OLD_QTY10,OLD_QTY11,
                  OLD_QTY12,OLD_QTY13,OLD_QTY14,OLD_QTY15,OLD_QTY16,OLD_QTY17,
                  OLD_QTY18,OLD_QTY19,OLD_QTY20,OLD_QTY21,OLD_QTY22,OLD_QTY23,
                  OLD_QTY24,OLD_QTY25,OLD_QTY26,OLD_QTY27,OLD_QTY28,OLD_QTY29,
                  OLD_QTY30,OLD_QTY31,OLD_QTY32,OLD_QTY33,OLD_QTY34,OLD_QTY35,
                  OLD_QTY36,EDITABLE_FLAG)
               VALUES
                 (msc_x_hz_ui_line_id_s.nextval,arg_query_id,'NA',nvl(var_order_relation(i),'NA'),
                  nvl(var_from_co_name(i),'NA'),var_from_org_name(i),var_item_name(i),
                  var_item_name_desc(i),41,-1,v_calculation_name,var_uom(i),var_supplier(i),
                  var_customer(i),var_supplier_org(i),var_customer_org(i),
                  var_supplier_id(i),var_customer_id(i),'NA',
                  'NA',var_item_id(i),var_qty_nobkt(i),var_qty1(i),var_qty2(i),
                  var_qty3(i),var_qty4(i),var_qty5(i),var_qty6(i),var_qty7(i),
                  var_qty8(i),var_qty9(i),var_qty10(i),var_qty11(i),var_qty12(i),
                  var_qty13(i),var_qty14(i),var_qty15(i),var_qty16(i),var_qty17(i),
                  var_qty18(i),var_qty19(i),var_qty20(i),var_qty21(i),var_qty22(i),
                  var_qty23(i),var_qty24(i),var_qty25(i),var_qty26(i),var_qty27(i),
                  var_qty28(i),var_qty29(i),var_qty30(i),var_qty31(i),var_qty32(i),
                  var_qty33(i),var_qty34(i),var_qty35(i),var_qty36(i),var_qty1(i),var_qty2(i),
                  var_qty3(i),var_qty4(i),var_qty5(i),var_qty6(i),var_qty7(i),
                  var_qty8(i),var_qty9(i),var_qty10(i),var_qty11(i),var_qty12(i),
                  var_qty13(i),var_qty14(i),var_qty15(i),var_qty16(i),var_qty17(i),
                  var_qty18(i),var_qty19(i),var_qty20(i),var_qty21(i),var_qty22(i),
                  var_qty23(i),var_qty24(i),var_qty25(i),var_qty26(i),var_qty27(i),
                  var_qty28(i),var_qty29(i),var_qty30(i),var_qty31(i),var_qty32(i),
                  var_qty33(i),var_qty34(i),var_qty35(i),var_qty36(i),1) ;

         END IF;
      EXCEPTION
         when others then
            arg_err_msg := arg_err_msg || ' insert running total ' || SQLERRM;
            if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
             FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module || 'insert_running_total', SQLERRM);
            end if;
            if c_runTotal%ISOPEN then
               CLOSE c_runTotal;
            end if;
      END insert_total_supply;

      /**
       * the foll procedure inserts the running total row into the temp tables.
       * NOTE: currently this is being used on the UI for
       * only order forecast and supply commit
       *
       * @param the order type.
       */
      PROCEDURE insert_running_total(v_order_type IN NUMBER) IS
         v_name VARCHAR2(250);
      BEGIN
         if v_order_type = ORDER_FORECAST_CST then
            v_name := fnd_message.get_string('MSC','MSC_X_HZ_RUN_DEMAND') ;
         elsif v_order_type = SUPPLY_COMMIT then
            v_name := fnd_message.get_string('MSC','MSC_X_HZ_RUN_SUPPLY') ;
         end if;

         OPEN c_runTotal(v_order_type) ;
         FETCH c_runTotal BULK COLLECT INTO
            var_relation,var_order_relation,var_from_co_name,var_from_org_name,var_item_name,
            var_item_name_desc,var_supplier,var_customer,var_supplier_org,
            var_customer_org,var_uom,var_supplier_id,var_customer_id,var_supplier_site_id,
            var_customer_site_id,var_item_id,var_qty_nobkt,var_qty1,var_qty2,
            var_qty3,var_qty4,var_qty5,var_qty6,var_qty7,var_qty8,var_qty9,var_qty10,
            var_qty11,var_qty12,var_qty13,var_qty14,var_qty15,var_qty16,var_qty17,
            var_qty18,var_qty19,var_qty20,var_qty21,var_qty22,var_qty23,var_qty24,
            var_qty25,var_qty26,var_qty27,var_qty28,var_qty29,var_qty30,var_qty31,
            var_qty32,var_qty33,var_qty34,var_qty35,var_qty36 ;
         CLOSE c_runTotal;

         if var_relation is not null and var_relation.COUNT > 0 then
            FORALL i IN var_relation.FIRST..var_relation.LAST
               INSERT INTO msc_hz_ui_lines
                 (LINE_ID,QUERY_ID,RELATION_GROUP,ORDER_RELATION_GROUP,FROM_COMPANY_NAME,FROM_ORG_CODE,
                  ITEM_NAME,ITEM_DESCRIPTION,ORDER_TYPE_RANK,ORDER_TYPE,ORDER_TYPE_DESC,
                  UOM,SUPPLIER_NAME,CUSTOMER_NAME,SUPPLIER_ORG_CODE,CUSTOMER_ORG_CODE,
                  SUPPLIER_ID,CUSTOMER_ID,SUPPLIER_SITE_ID,CUSTOMER_SITE_ID,INVENTORY_ITEM_ID,
                  UNBUCKETED_QTY,QTY_BUCKET1,QTY_BUCKET2,QTY_BUCKET3,QTY_BUCKET4,
                  QTY_BUCKET5,QTY_BUCKET6,QTY_BUCKET7,QTY_BUCKET8,QTY_BUCKET9,
                  QTY_BUCKET10,QTY_BUCKET11,QTY_BUCKET12,QTY_BUCKET13,QTY_BUCKET14,
                  QTY_BUCKET15,QTY_BUCKET16,QTY_BUCKET17,QTY_BUCKET18,QTY_BUCKET19,
                  QTY_BUCKET20,QTY_BUCKET21,QTY_BUCKET22,QTY_BUCKET23,QTY_BUCKET24,
                  QTY_BUCKET25,QTY_BUCKET26,QTY_BUCKET27,QTY_BUCKET28,QTY_BUCKET29,
                  QTY_BUCKET30,QTY_BUCKET31,QTY_BUCKET32,QTY_BUCKET33,QTY_BUCKET34,
                  QTY_BUCKET35,QTY_BUCKET36,OLD_QTY1,OLD_QTY2,OLD_QTY3,OLD_QTY4,
                  OLD_QTY5,OLD_QTY6,OLD_QTY7,OLD_QTY8,OLD_QTY9,OLD_QTY10,OLD_QTY11,
                  OLD_QTY12,OLD_QTY13,OLD_QTY14,OLD_QTY15,OLD_QTY16,OLD_QTY17,
                  OLD_QTY18,OLD_QTY19,OLD_QTY20,OLD_QTY21,OLD_QTY22,OLD_QTY23,
                  OLD_QTY24,OLD_QTY25,OLD_QTY26,OLD_QTY27,OLD_QTY28,OLD_QTY29,
                  OLD_QTY30,OLD_QTY31,OLD_QTY32,OLD_QTY33,OLD_QTY34,OLD_QTY35,
                  OLD_QTY36,EDITABLE_FLAG)
               VALUES
                 (msc_x_hz_ui_line_id_s.nextval,arg_query_id,nvl(var_relation(i),'NA'),nvl(var_order_relation(i),'NA'),
                  nvl(var_from_co_name(i),'NA'),var_from_org_name(i),var_item_name(i),
                  var_item_name_desc(i),40,-1,v_name,var_uom(i),var_supplier(i),
                  var_customer(i),var_supplier_org(i),var_customer_org(i),
                  var_supplier_id(i),var_customer_id(i),var_supplier_site_id(i),
                  var_customer_site_id(i),var_item_id(i),var_qty_nobkt(i),var_qty1(i),var_qty2(i),
                  var_qty3(i),var_qty4(i),var_qty5(i),var_qty6(i),var_qty7(i),
                  var_qty8(i),var_qty9(i),var_qty10(i),var_qty11(i),var_qty12(i),
                  var_qty13(i),var_qty14(i),var_qty15(i),var_qty16(i),var_qty17(i),
                  var_qty18(i),var_qty19(i),var_qty20(i),var_qty21(i),var_qty22(i),
                  var_qty23(i),var_qty24(i),var_qty25(i),var_qty26(i),var_qty27(i),
                  var_qty28(i),var_qty29(i),var_qty30(i),var_qty31(i),var_qty32(i),
                  var_qty33(i),var_qty34(i),var_qty35(i),var_qty36(i),var_qty1(i),var_qty2(i),
                  var_qty3(i),var_qty4(i),var_qty5(i),var_qty6(i),var_qty7(i),
                  var_qty8(i),var_qty9(i),var_qty10(i),var_qty11(i),var_qty12(i),
                  var_qty13(i),var_qty14(i),var_qty15(i),var_qty16(i),var_qty17(i),
                  var_qty18(i),var_qty19(i),var_qty20(i),var_qty21(i),var_qty22(i),
                  var_qty23(i),var_qty24(i),var_qty25(i),var_qty26(i),var_qty27(i),
                  var_qty28(i),var_qty29(i),var_qty30(i),var_qty31(i),var_qty32(i),
                  var_qty33(i),var_qty34(i),var_qty35(i),var_qty36(i),1) ;

         end if;
      EXCEPTION
         when others then
            arg_err_msg := arg_err_msg || ' insert running total ' || SQLERRM;
            if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
             FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module || 'insert_running_total', SQLERRM);
            end if;
            if c_runTotal%ISOPEN then
               CLOSE c_runTotal;
            end if;
      END;

   -- ============================================================================= end declare block

   /**
    * Begin the main procedure
    *
    * loop though the plans.
    * get dates.
    * get the number of buckets to be displayed.
    * insert the buckets into the msc_hz_ui_headers table.
    */


   BEGIN
      arg_next_link := 'N';
      arg_query_id := -1;

      v_pref := rtrim(ltrim(arg_pref_name));

      BEGIN
         get_user_prefs(v_pref);
      EXCEPTION
         when others then
            if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
             FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module || 'populate_bucketed_quantity', 'user prefs' || SQLERRM);
            end if;
            set_default_prefs;
      END;

      if v_pref IS NOT NULL OR arg_default_pref = 1 then

         -- get the graph title from the fnd_lookup_values table
         if v_graphtype <> 0 then
            v_graphtitle := get_lookup_name('MSC_X_GRAPH_OPTION', v_graphtype);
         end if;

         --get the default calendar
         v_default_cal_code := FND_PROFILE.VALUE('MSC_X_DEFAULT_CALENDAR');
         --v_default_cal_code := 'CP-Mon-70';


         -- get the buckets with default calendar and initialise the array
         get_bucket_dates(arg_from_date, v_default_cal_code);

         --check multiple sites are found with the default calendar
         g_multiple_sites := check_for_multiple_sites(null);

         if (g_multiple_sites = 0 ) then
          -- call the api to get cust site's recieving calendar
          msc_x_util.get_calendar_code(v_supplier_id, v_supplier_site_id, v_customer_id, v_customer_site_id, v_calendar_code, v_sr_instance_id); --'CP-Mon-70';

          if (v_calendar_code <> v_default_cal_code ) then

      BEGIN
        get_user_prefs(v_pref);
      EXCEPTION
        when others then
           if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
             FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module || 'populate_bucketed_quantity', 'user prefs' || SQLERRM);
            end if;
         set_default_prefs;
      END;
      get_bucket_dates(arg_from_date, v_calendar_code);
     end if;
         end if;

         set_date_variables();

         --initialize the first array
         initialize(tot_rec) ;

         -- If we need to show a net forecast, include these order types for
         -- summary purposes and delete them again later from the lines table
         IF v_net_forecast > 0 THEN
            IF v_requisition = NOT_SELECTED THEN
               v_delete_requisition := TRUE;
               v_requisition := REQUISITION;
            END IF;

            IF v_purchase_order = NOT_SELECTED THEN
               v_delete_purchase_order := TRUE;
               v_purchase_order := PURCHASE_ORDER;
            END IF;
         END IF;

         --get the past due column header
         v_past_due_hdr := FND_MESSAGE.GET_STRING('MSC','MSC_X_HZ_PAST_DUE');

         --massage ss and pab data
         --fill_ss_pab_empty_buckets;
         -- get the query id first
         SELECT msc_x_hz_ui_query_id_s.nextval INTO arg_query_id FROM Dual;

         -- insert the header
         INSERT INTO msc_hz_ui_headers
           (QUERY_ID,NO_OF_BUCKETS,PROD_SUM_LEVEL, ORG_SUM_LEVEL, ORG_SUM_LEVEL_TP,
            BUCKET1,BUCKET2,BUCKET3,BUCKET4,BUCKET5,BUCKET6,BUCKET7,BUCKET8,BUCKET9,
            BUCKET10,BUCKET11,BUCKET12,BUCKET13,BUCKET14,BUCKET15,BUCKET16,BUCKET17,
            BUCKET18,BUCKET19,BUCKET20,BUCKET21,BUCKET22,BUCKET23,BUCKET24,BUCKET25,
            BUCKET26,BUCKET27,BUCKET28,BUCKET29,BUCKET30,BUCKET31,BUCKET32,BUCKET33,
            BUCKET34,BUCKET35,BUCKET36,UNDATED_BUCKET_FLAG,USER_PREFERENCE,GRAPH_TYPE,
            GRAPH_TITLE,LAST_BUCKET)
         VALUES
           (arg_query_id,g_num_of_buckets,prod_agg, myco_agg, tpco_agg,
            var_dates(1),var_dates(2),var_dates(3),var_dates(4),var_dates(5),
            var_dates(6),var_dates(7),var_dates(8),var_dates(9),var_dates(10),
            var_dates(11),var_dates(12),var_dates(13),var_dates(14),var_dates(15),
            var_dates(16),var_dates(17),var_dates(18),var_dates(19),var_dates(20),
            var_dates(21),var_dates(22),var_dates(23),var_dates(24),var_dates(25),
            var_dates(26),var_dates(27),var_dates(28),var_dates(29),var_dates(30),
            var_dates(31),var_dates(32),var_dates(33),var_dates(34),var_dates(35),
            var_dates(36),'Y',v_pref,v_graphtype,v_graphtitle,v_last_bkt_date ) ;

         -- Now get all the data using the params.
         g_statement := prepare_sql(null);


         print_query (); -- can be used for debug purposes.


         OPEN osce_bucketed_plan FOR g_statement;

         LOOP
            FETCH osce_bucketed_plan INTO
                 activity_rec.RELATION,
                 activity_rec.ORDER_RELATION,
                 activity_rec.FROM_CO_NAME,
                 activity_rec.FROM_ORG_NAME,
                 activity_rec.ITEM_ID,
                 activity_rec.ITEM_NAME,
                 activity_rec.ITEM_DESC,
		             activity_rec.SUPPLIER_ITEM_NAME,
                 activity_rec.SUPPLIER_NAME,
                 activity_rec.CUSTOMER_NAME,
                 activity_rec.SUPPLIER_ORG,
                 activity_rec.CUSTOMER_ORG,
                 activity_rec.ORDER_TYPE,
                 activity_rec.ORDER_DESC,
                 activity_rec.SHIPPING_CONTROL,
                 activity_rec.UOM,
                 activity_rec.NEW_QUANTITY,
                 activity_rec.NEW_DATE,
                 activity_rec.SUPPLIER_ID,
                 activity_rec.CUSTOMER_ID,
                 activity_rec.SUPP_SITE_ID,
                 activity_rec.CUST_SITE_ID,
                 activity_rec.THIRD_PARTY_FLAG,
                 activity_rec.VIEWER_CO,
                 activity_rec.TP_CO,
                 activity_rec.BUCKET_TYPE,
                 activity_rec.PUBLISHER_ID,
                 activity_rec.PUBLISHER_SITE_ID
            ;

            EXIT WHEN osce_bucketed_plan%NOTFOUND;
            activity_rec.new_date := trunc(activity_rec.new_date);

            curr_date := trunc(nvl(arg_from_date, p_start_date));


      -- commented out for the past due calculation.
            --IF activity_rec.new_date >= curr_date THEN


               curr_rel := activity_rec.RELATION;
               curr_item := activity_rec.ITEM_NAME;
               curr_ot := activity_rec.ORDER_TYPE;
               curr_ship_ctrl := activity_rec.SHIPPING_CONTROL;

               /**
               * basic logic:
               * if the date is = curr date store qty there
               * if the date is greater then compare with the next bucket
               * if it is less than the next bucket then put is in prev bucket.
               * for the combination of relation(buyer/seller),item, order type
               * LOOP THROUGH THE RESULT SET FORM MSC_SUP_DEM_ENTRIES
               *   curr_relation = msc_supdem.currrecord.relation
               *   curr_item = msc_supdem.currrecord.item_id
               *   curr_order_type = msc_supdem.currrecord.order_type
               *   if curr_relation <> last_relation AND
               *      curr_item     <> last_item     AND
               *      curr_order    <> last_order    THEN
               *     I N S E R T into the lines table.
               *     S E T the buckets to 0.
               *   end if;
               *   FOR i IN var_dates.FIRST TO var_dates.LAST LOOP
               *   --  loop though the buckets array (var_dates)
               *   --  check msc_supdem.currrecord.new_date with var_dates(i)
               *     if new_date = var_dates(i) then
               *       add the quantity to the quantity(i) bucket
               *       i.e. quantity(i) = quantity(i) + quantity.
               *     end if;
               *     if new_date > var_dates(i) and new_date < var_dates(i+1) then
               *       add the quantity to the quantity(i) bucket
               *       i.e. quantity(i) = quantity(i) + quantity.
               *     end if;
               *   END LOOP;
               */


               -- get the correct starting point of the records.
               -- this will where the unique combination of the
               -- relation and item (START_COUNTER = the starting point and START_COUNTER < ending point)
               -- if STARTING_COUNTER has reached the ending point then exit the loop.
               -- till the START_COUNTER reaches the starting point do not start the calculation.
               -- set calculate past due boolean to true

               IF curr_rel <> last_rel OR curr_item <> last_item OR curr_ot <> last_ot THEN
                 rec_counter := rec_counter + 1;
                 calc_past_due := TRUE;
                 last_ship_ctrl := curr_ship_ctrl;

               END IF;


               if (activity_rec.SHIPPING_CONTROL is not null) then
         var_ship_ctrl(rec_counter) := ' (' || activity_rec.SHIPPING_CONTROL || ') ';
       elsif (activity_rec.SHIPPING_CONTROL is null) then
         var_ship_ctrl(rec_counter) := null;
        end if;

       IF((curr_ship_ctrl <> last_ship_ctrl) OR (myco_agg <> ORG_AGG) OR (tpco_agg <> ORG_AGG)) THEN
        var_ship_ctrl(rec_counter) := null;
       END IF;

       IF(curr_ot = ASN) THEN --If order type is asn nullify shipping control
          var_ship_ctrl(rec_counter) := null;
       END IF;  ---Bug # 6147428

               -- here if the end row limit has been reached
               -- set the next link to true for the UI.
               -- then exit the loop

               --Commneted out for bug#4445912
               --IF rec_counter >= 1 and rec_counter <= 200 THEN

                  -- if the very first record set the prev to the curr rec.
                  -- initialize all the buckets to 0
                  if firstrec = 0 then

                     -- set the prev and the current to be the same
                     -- so that the combination start is the same
                     previous_rec:= activity_rec;

                     -- increase the value of prev_rec
                     -- so that this loop wont be entered again
                     firstrec := firstrec + 1;

                  end if;

                  -- if the combination has changed then insert the prev record.

                  if previous_rec.relation <> activity_rec.relation     or
                     previous_rec.item_name <> activity_rec.item_name       or
                     previous_rec.order_type <> activity_rec.order_type -- or
                  then

                     set_non_qty_data(tot_rec);

                     previous_rec := activity_rec;

                     tot_rec := tot_rec + 1;
                     initialize(tot_rec);


                     -- if curr item is same as prev then curr item is 2

                     if tot_rec > 1 AND var_item_id(tot_rec-1) = activity_rec.item_id then
                        var_next_item(tot_rec) := 2;
                     else
                        var_next_item(tot_rec) := 1;
                     end if;
                  end if;

                  temp_sup_site := add_to_array(temp_sup_site, activity_rec.supp_site_id) ;
                  temp_sup := add_to_array(temp_sup, activity_rec.supplier_id);
                  temp_cust_site := add_to_array(temp_cust_site, activity_rec.cust_site_id);
                  temp_cust := add_to_array(temp_cust, activity_rec.customer_id);


                  calculate_bucket_data(tot_rec);



         -- calculate past due quantity only when the record changed.
         if(calc_past_due = TRUE) then

          -- calculate past due quantity for PO, SO and ASN
          IF (v_asn > 0 AND activity_rec.order_type = ASN) OR
           (v_purchase_order > 0 AND activity_rec.order_type = PURCHASE_ORDER) OR
           (v_sales_order > 0 AND activity_rec.order_type = SALES_ORDER) THEN

           var_past_due_qty(rec_counter) := calc_past_due_qty(activity_rec.order_type);
           pagesize := pagesize + 1;
          END IF;
          calc_past_due := FALSE;
         end if;


               --END IF; -- end of rec_counter >= start and <= end


               -- assign the current relation and item to the last ones
               last_rel := curr_rel;
               last_item := curr_item;
               last_ot := curr_ot;
               last_ship_ctrl := curr_ship_ctrl;

         END LOOP;   -- end loop of the FETCH into

         -- handle last record.
         set_non_qty_data(tot_rec);
         if tot_rec > 1 AND var_item_id(tot_rec-1) = var_item_id(tot_rec) then
            var_next_item(tot_rec) := 2;
         else
            var_next_item(tot_rec) := 1;
         end if;

         close osce_bucketed_plan;

         -- clean up records
         -- check if the headers has buckets - else just remove all
         --  records from the relation array
         BEGIN
            SELECT nvl(no_of_buckets,NOT_SELECTED)
              INTO record_cnt
              FROM msc_hz_ui_headers
             WHERE query_id = arg_query_id ;

         EXCEPTION
            when no_data_found then
               if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module||'populate_bucketed_quantity','Get rec cnt '||SQLERRM);
               end if;
               record_cnt := 0;

            when others then
               if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module||'populate_bucketed_quantity','Get rec cnt '||SQLERRM);
               end if;
               record_cnt :=0;
         END;

         if record_cnt = 0 then
            var_relation.delete;
            var_order_relation.delete;
         end if;

         /**
          * clean up invalid records
          */
         BEGIN
            if var_relation is not null and var_relation.COUNT > 0 then
               i := 0;
               FOR i IN var_relation.FIRST..var_relation.LAST LOOP

                  if ((var_relation(i) = 'NA' or
                      var_relation(i) = null) and
                     var_order(i) = -1 and
                     var_supplier_id(i) is null and
                     var_customer_id(i) is null)
                  then
                     var_relation.delete(i);
                     var_order_relation.delete(i);
                     var_item_name.delete(i);
                     var_item_name.delete(i);
                     var_supplier_id.delete(i);
                     var_customer_id.delete(i);
                     var_order.delete(i);
                  end if;
               END LOOP ;

            end if;
         EXCEPTION
            when others then
               arg_err_msg := arg_err_msg || ' cleanup ' || SQLERRM;
               if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module||'populate_bucketed_quantity','Cleanup '||SQLERRM);
               end if;

         END;

         --massage ss and pab data
         fill_ss_pab_empty_buckets;


         -- bulk insert;
         BEGIN
            if var_relation is not null and var_relation.COUNT > 0 then
               i := 0;
               FORALL i IN var_relation.FIRST..var_relation.LAST
                  INSERT INTO msc_hz_ui_lines
                    (LINE_ID,QUERY_ID,RELATION_GROUP,ORDER_RELATION_GROUP,FROM_COMPANY_NAME,FROM_ORG_CODE,
                     ITEM_NAME,ITEM_DESCRIPTION,SUPPLIER_NAME,CUSTOMER_NAME,
                     SUPPLIER_ORG_CODE,CUSTOMER_ORG_CODE,ORDER_TYPE_RANK,
                     ORDER_TYPE,ORDER_TYPE_DESC,shipping_control,UOM,SUPPLIER_ID,CUSTOMER_ID,
                     SUPPLIER_SITE_ID,CUSTOMER_SITE_ID,INVENTORY_ITEM_ID,PAST_DUE_QTY, UNBUCKETED_QTY,
                     QTY_BUCKET1,QTY_BUCKET2,QTY_BUCKET3,QTY_BUCKET4,QTY_BUCKET5,
                     QTY_BUCKET6,QTY_BUCKET7,QTY_BUCKET8,QTY_BUCKET9,QTY_BUCKET10,
                     QTY_BUCKET11,QTY_BUCKET12,QTY_BUCKET13,QTY_BUCKET14,QTY_BUCKET15,
                     QTY_BUCKET16,QTY_BUCKET17,QTY_BUCKET18,QTY_BUCKET19,QTY_BUCKET20,
                     QTY_BUCKET21,QTY_BUCKET22,QTY_BUCKET23,QTY_BUCKET24,QTY_BUCKET25,
                     QTY_BUCKET26,QTY_BUCKET27,QTY_BUCKET28,QTY_BUCKET29,QTY_BUCKET30,
                     QTY_BUCKET31,QTY_BUCKET32,QTY_BUCKET33,QTY_BUCKET34,QTY_BUCKET35,
                     QTY_BUCKET36,EDITABLE_FLAG,OLD_QTY1,OLD_QTY2,OLD_QTY3,OLD_QTY4,
                     OLD_QTY5,OLD_QTY6,OLD_QTY7,OLD_QTY8,OLD_QTY9,OLD_QTY10,OLD_QTY11,
                     OLD_QTY12,OLD_QTY13,OLD_QTY14,OLD_QTY15,OLD_QTY16,OLD_QTY17,
                     OLD_QTY18,OLD_QTY19,OLD_QTY20,OLD_QTY21,OLD_QTY22,OLD_QTY23,
                     OLD_QTY24,OLD_QTY25,OLD_QTY26,OLD_QTY27,OLD_QTY28,OLD_QTY29,
                     OLD_QTY30,OLD_QTY31,OLD_QTY32,OLD_QTY33,OLD_QTY34,OLD_QTY35,OLD_QTY36,
                     BUCKET_TYPE,PUBLISHER_ID,PUBLISHER_SITE_ID,NEXT_ITEM,SUP_ITEM)
                  VALUES
                    (msc_x_hz_ui_line_id_s.nextval,arg_query_id,var_relation(i),var_order_relation(i),
                     var_from_co_name(i),var_from_org_name(i),var_item_name(i),
                     var_item_name_desc(i),var_supplier(i),var_customer(i),
                     var_supplier_org(i),var_customer_org(i),var_order_rank(i),
                     var_order(i),var_order_desc(i),var_ship_ctrl(i),var_uom(i),var_supplier_id(i),
                     var_customer_id(i),var_supplier_site_id(i),var_customer_site_id(i),
                     var_item_id(i),var_past_due_qty(i),var_qty_nobkt(i),var_qty1(i),var_qty2(i),var_qty3(i),
                     var_qty4(i),var_qty5(i),var_qty6(i),var_qty7(i),var_qty8(i),var_qty9(i),
                     var_qty10(i),var_qty11(i),var_qty12(i),var_qty13(i),var_qty14(i),
                     var_qty15(i),var_qty16(i),var_qty17(i),var_qty18(i),var_qty19(i),
                     var_qty20(i),var_qty21(i),var_qty22(i),var_qty23(i),var_qty24(i),
                     var_qty25(i),var_qty26(i),var_qty27(i),var_qty28(i),var_qty29(i),
                     var_qty30(i),var_qty31(i),var_qty32(i),var_qty33(i),var_qty34(i),
                     var_qty35(i),var_qty36(i),var_edit_flag(i),var_qty1(i),var_qty2(i),var_qty3(i),
                     var_qty4(i),var_qty5(i),var_qty6(i),var_qty7(i),var_qty8(i),var_qty9(i),
                     var_qty10(i),var_qty11(i),var_qty12(i),var_qty13(i),var_qty14(i),
                     var_qty15(i),var_qty16(i),var_qty17(i),var_qty18(i),var_qty19(i),
                     var_qty20(i),var_qty21(i),var_qty22(i),var_qty23(i),var_qty24(i),
                     var_qty25(i),var_qty26(i),var_qty27(i),var_qty28(i),var_qty29(i),
                     var_qty30(i),var_qty31(i),var_qty32(i),var_qty33(i),var_qty34(i),
                     var_qty35(i),var_qty36(i),var_bkt_type(i),var_pub_id(i),var_pub_site_id(i),
                     var_next_item(i),var_sup_item(i));
            end if;
         EXCEPTION
            when others then
               arg_err_msg := arg_err_msg || ' insert records ' || SQLERRM ;
               if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module||'populate_bucketed_quantity','Insert record '||SQLERRM);
               end if;
               raise;

         END ;

                     SELECT count(*)
               INTO arg_num_rowset
               FROM msc_hz_ui_lines
              WHERE query_id = arg_query_id
              AND order_type_desc <> fnd_message.get_string('MSC','MSC_X_HZ_RUN_DEMAND')
              AND order_type_desc <> fnd_message.get_string('MSC','MSC_X_HZ_RUN_SUPPLY')
              ;

         /**
          * Update other reqd fields.
          * update owner item, sup item, cust item, and uom for
          * all the editable records.
          */
         if myco_agg = ORG_AGG and tpco_agg = ORG_AGG THEN
            BEGIN
               SELECT line_id, customer_name,supplier_name,inventory_item_id,
                      order_type,from_company_name
                 BULK COLLECT INTO v_line_id, v_cust_name, v_sup_name,
                      v_item_id,v_order,v_pub_name
                 FROM msc_hz_ui_lines
                WHERE editable_flag = 0
                  AND query_id = arg_query_id  -- this is required to avoid the comp row disappearing act.
                   OR order_type in (ORDER_FORECAST_CST, SUPPLY_COMMIT) ;

               if v_line_id.COUNT > 0 then
                  FOR i in v_line_id.FIRST..v_line_id.LAST LOOP

                     BEGIN

                        SELECT owner_item_name,supplier_item_name,customer_item_name,
                               uom_code,nvl(tp_uom_code, uom_code) ,owner_item_description,
                               supplier_item_description,customer_item_description
                          INTO v_owner_item,v_sup_item,v_cust_item,v_uom_code,v_tp_uom,
                               v_owner_item_desc,v_sup_item_desc,v_cust_item_desc
                          FROM msc_sup_dem_entries_ui_v
                         WHERE inventory_item_id = v_item_id(i)
                           AND publisher_order_type = v_order(i)
                           AND publisher_name = v_pub_name(i)
                           AND customer_name = v_cust_name(i)
                           AND supplier_name = v_sup_name(i)
                           AND ROWNUM < 2 ;

                        if sql%rowcount > 0 then

                           k := var_line_id.COUNT + 1;

                           var_line_id(k) := v_line_id(i) ;
                           var_owner_item(k) := v_owner_item;
                           var_cust_item(k) := v_cust_item ;
                           var_sup_item(k) := v_sup_item ;
                           var_owner_item_desc(k) := v_owner_item_desc ;
                           var_cust_item_desc(k) := v_cust_item_desc ;
                           var_sup_item_desc(k) := v_sup_item_desc ;
                           var_tp_uom(k) := v_tp_uom ;
                           var_uom_code(k) := v_uom_code ;

                        end if;
                     EXCEPTION
                        when others then
                           null;
                     END ;

                  END LOOP;

               end if;

               if var_line_id.COUNT > 0 then

                  FORALL k in var_line_id.FIRST..var_line_id.LAST
                     UPDATE msc_hz_ui_lines
                        SET owner_item = var_owner_item(k),
                            cust_item = var_cust_item(k),
                            sup_item = var_sup_item(k),
                            owner_item_desc = var_owner_item_desc(k),
                            sup_item_desc = var_sup_item_desc(k),
                            cust_item_desc = var_cust_item_desc(k),
                            tp_uom = var_tp_uom(k),
                            uom_code = var_uom_code(k)
                      WHERE query_id = arg_query_id
                        AND line_id = var_line_id(k);

               end if;

            EXCEPTION
               when others then
                  arg_err_msg := arg_err_msg || ' Upd owner item etc. ' || SQLERRM;
                  if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                   FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module||'populate_bucketed_quantity','Upd owner item '||SQLERRM);
                  end if;
            END ;
         end if;


                     SELECT count(*)
               INTO arg_num_rowset
               FROM msc_hz_ui_lines
              WHERE query_id = arg_query_id
              AND order_type_desc <> fnd_message.get_string('MSC','MSC_X_HZ_RUN_DEMAND')
              AND order_type_desc <> fnd_message.get_string('MSC','MSC_X_HZ_RUN_SUPPLY')
              ;

         /**
          * Companion row
          * check if a companion row is required
          *   - if order forecast and supply commit are chosen
          *   - if user company is the publisher of one of the above
          *        and both orders are not present then insert a record with
          *        the tp as the publisher, and the qty_bucket(X) value
          *        defaulted to the companion rows values
          *        but the old_qty(X) is still 0.
          */
         BEGIN
            add_companion_row(arg_query_id);
         EXCEPTION
            when others then
               arg_err_msg := arg_err_msg || ' companion row ' || SQLERRM;
               if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module||'populate_bucketed_quantity',' companion row '||SQLERRM);
               end if;
         END;



                     SELECT count(*)
               INTO arg_num_rowset
               FROM msc_hz_ui_lines
              WHERE query_id = arg_query_id
              AND order_type_desc <> fnd_message.get_string('MSC','MSC_X_HZ_RUN_DEMAND')
              AND order_type_desc <> fnd_message.get_string('MSC','MSC_X_HZ_RUN_SUPPLY')
              ;

         /**
          * Clean-Up
          * clean up bad records like item = -1 , document owner = -1 etc.
          * if the data is 3rd party then do not display the sites
          * if the agg is company do not display sites.
          */
         BEGIN

            v_user_company := sys_context('MSC','COMPANY_NAME');

            -- remove site if agg is at company level
            if myco_agg = COMPANY_AGG and tpco_AGG = COMPANY_AGG then

               UPDATE msc_hz_ui_lines
                  SET FROM_ORG_CODE = null,SUPPLIER_ORG_CODE = NULL,
                      CUSTOMER_ORG_CODE = NULL
                WHERE query_id = arg_query_id ;
            end if;

            if myco_agg = COMPANY_AGG and tpco_AGG = ORG_AGG then
               -- delete site only where user co id is not the id
               UPDATE msc_hz_ui_lines
                  SET FROM_ORG_CODE = null
                WHERE FROM_COMPANY_NAME = v_user_company
                  AND query_id = arg_query_id ;

               UPDATE msc_hz_ui_lines
                  SET SUPPLIER_ORG_CODE = null
                WHERE SUPPLIER_NAME = v_user_company  -- user is the supplier
                  AND query_id = arg_query_id ;

               UPDATE msc_hz_ui_lines
               SET CUSTOMER_ORG_CODE = null
               WHERE CUSTOMER_NAME = v_user_company  -- user is the customer
                 AND query_id = arg_query_id ;

            end if;

            if myco_agg = ORG_AGG and tpco_AGG = COMPANY_AGG then
               -- delete site only where user co id is not the id
               UPDATE msc_hz_ui_lines
                  SET FROM_ORG_CODE = null
                WHERE FROM_COMPANY_NAME <> v_user_company
                  AND query_id = arg_query_id ;

               UPDATE msc_hz_ui_lines
                  SET SUPPLIER_ORG_CODE = null
                WHERE CUSTOMER_NAME = v_user_company  -- user is the customer
                  AND query_id = arg_query_id ;

               UPDATE msc_hz_ui_lines
                  SET CUSTOMER_ORG_CODE = null
                WHERE SUPPLIER_NAME = v_user_company  -- user is the customer
                  AND query_id = arg_query_id ;

               -- third party
               UPDATE msc_hz_ui_lines
                  SET FROM_ORG_CODE = null,SUPPLIER_ORG_CODE = NULL,
                      CUSTOMER_ORG_CODE = NULL
                WHERE SUPPLIER_NAME <> v_user_company and CUSTOMER_NAME <> v_user_company ;

            end if;

            if tpco_agg = ALL_AGG then

               -- third party - remove site for all
               UPDATE msc_hz_ui_lines
                  SET FROM_ORG_CODE = null,SUPPLIER_ORG_CODE = NULL,
                      CUSTOMER_ORG_CODE = NULL
                WHERE SUPPLIER_NAME <> v_user_company
                  AND CUSTOMER_NAME <> v_user_company
                  AND query_id = arg_query_id ;

               -- if doc owner is not user then set it to null for ALL agg.
               UPDATE msc_hz_ui_lines
                  SET FROM_COMPANY_NAME = null, FROM_ORG_CODE = null
                WHERE FROM_COMPANY_NAME <> v_user_company
                  AND (SUPPLIER_NAME = v_user_company OR CUSTOMER_NAME = v_user_company )
                  AND query_id = arg_query_id ;

               UPDATE msc_hz_ui_lines
                  SET customer_name = FND_MESSAGE.GET_STRING('MSC','MSC_X_HZ_TP_ALL'),
                      customer_org_code = NULL
                      --,customer_site_id = NULL
                WHERE SUPPLIER_NAME = v_user_company -- user is supplier
                  AND query_id = arg_query_id ;

               UPDATE msc_hz_ui_lines
                  SET SUPPLIER_NAME = FND_MESSAGE.GET_STRING('MSC','MSC_X_HZ_TP_ALL'),
                      SUPPLIER_ORG_CODE = NULL
                WHERE CUSTOMER_NAME = v_user_company -- user is customer
                  AND query_id = arg_query_id ;

               if myco_agg = COMPANY_AGG then

                  UPDATE msc_hz_ui_lines
                     SET supplier_org_code = null
                   WHERE SUPPLIER_NAME = v_user_company -- user is supplier
                     AND query_id = arg_query_id ;

                  UPDATE msc_hz_ui_lines
                     SET customer_org_code = null
                   WHERE CUSTOMER_NAME = v_user_company -- user is customer
                     AND query_id = arg_query_id ;

                  UPDATE msc_hz_ui_lines
                     SET FROM_ORG_CODE = null
                   WHERE FROM_COMPANY_NAME <> v_user_company
                     AND query_id = arg_query_id ;

               end if;

            end if;

         EXCEPTION
            when no_data_found then
               arg_err_msg := arg_err_msg || ' update ' || SQLERRM;
               if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module||'populate_bucketed_quantity','Update '||SQLERRM);
               end if;

            when others then
               -- do nothing
               arg_err_msg := arg_err_msg || ' update-2' || SQLERRM;
               if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module||'populate_bucketed_quantity','Update '||SQLERRM);
               end if;

         END;

         -- NOW HANDLE THE NEW RECORDS FOR RUNNING/TOTAL DEMAND RUNNING/TOTAL SUPPLY

         /**
          * Running totals
          *
          * basic logic

          * for TOTAL demand/supply
          * select from the temp table and insert into temp table

          * for running total demad/supply
          * current total + running_total of prev bucket
          * select the same as below then loop through
          *  curr bucket qty (var_qty) := running_total + curr_total
          */
         -- NOW HANDLE RUNNING TOTAL.
         BEGIN

            if v_run_tot_demand > 0 then

               -- open the cursor pass the query id and the order types where clause.
               -- bulk insert
               insert_running_total(ORDER_FORECAST_CST);
            end if;

            if v_run_tot_supply > 0 then
              -- open the cursor pass the query id and the order types where clause.
              -- bulk insert
               insert_running_total(SUPPLY_COMMIT);

            end if;
         EXCEPTION
            when others then
               if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module||'populate_bucketed_quantity', 'Run tot '||SQLERRM);
               end if;
               null;
         END;


                       SELECT count(*)
                 INTO arg_num_rowset
                 FROM msc_hz_ui_lines
                WHERE query_id = arg_query_id
                AND order_type_desc <> fnd_message.get_string('MSC','MSC_X_HZ_RUN_DEMAND')
                AND order_type_desc <> fnd_message.get_string('MSC','MSC_X_HZ_RUN_SUPPLY')
                ;


         -- NOW HANDLE NET FORECAST
         BEGIN

            IF v_net_forecast > 0 THEN
               insert_net_forecast(arg_query_id);

               -- If we need to show a net forecast, we included these order types for
             -- summary purposes and need to delete them now from the lines table
                IF v_delete_requisition = TRUE THEN
                  v_requisition := NOT_SELECTED;
              delete_order_type(arg_query_id, REQUISITION);
             END IF;

             IF v_delete_purchase_order = TRUE THEN
               v_purchase_order := NOT_SELECTED;
              delete_order_type(arg_query_id, PURCHASE_ORDER);
             END IF;
         END IF;

         EXCEPTION
            WHEN others THEN
               if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module||'net_forecast', 'Net Forecast '||SQLERRM);
               end if;
         END;


                     SELECT count(*)
               INTO arg_num_rowset
               FROM msc_hz_ui_lines
              WHERE query_id = arg_query_id
              AND order_type_desc <> fnd_message.get_string('MSC','MSC_X_HZ_RUN_DEMAND')
              AND order_type_desc <> fnd_message.get_string('MSC','MSC_X_HZ_RUN_SUPPLY')
              ;

         -- NOW HANDLE TOTAL SUPPLY
         BEGIN

            IF v_total_supply > 0 THEN
               insert_total_supply(arg_query_id);
         END IF;

         EXCEPTION
            WHEN others THEN
               if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module||'total_supply', 'Total Supply '||SQLERRM);
               end if;
         END;


                     SELECT count(*)
               INTO arg_num_rowset
               FROM msc_hz_ui_lines
              WHERE query_id = arg_query_id
              AND order_type_desc <> fnd_message.get_string('MSC','MSC_X_HZ_RUN_DEMAND')
              AND order_type_desc <> fnd_message.get_string('MSC','MSC_X_HZ_RUN_SUPPLY')
              ;

         BEGIN
            -- now update the undated_buckets value int the header
            if unbucketed_flag > 0 then
               UPDATE msc_hz_ui_headers
                 SET undated_bucket_flag = 'Y'
               WHERE query_id = arg_query_id;
            else
               UPDATE msc_hz_ui_headers
                 SET undated_bucket_flag = 'N'
               WHERE query_id = arg_query_id;

            end if;

            correct_next_item(arg_query_id);

--            SELECT count(distinct relation_group||item_name)
            SELECT count(*)
             INTO arg_num_rowset
             FROM msc_hz_ui_lines
            WHERE query_id = arg_query_id
            AND order_type_desc <> fnd_message.get_string('MSC','MSC_X_HZ_RUN_DEMAND')
            AND order_type_desc <> fnd_message.get_string('MSC','MSC_X_HZ_RUN_SUPPLY')
            ;

            if arg_num_rowset = 0 then
               arg_query_id := -1;
            end if;
         EXCEPTION
            when no_data_found then
               if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module||'populate_bucketed_quantity','Upd Bkt flag '||SQLERRM);
               end if;

            when others then
               if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module||'populate_bucketed_quantity','Upd Bkt flag '||SQLERRM);
               end if;

         END ;

      end if;

      if arg_query_id = -1 then
         arg_err_msg := arg_err_msg || fnd_message.get_string('MSC','MSC_X_HZ_NODATA');
         arg_num_rowset := 0 ;
      end if;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
           FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module || 'populate_bucketed_quantity', SQLERRM);
          end if;
         arg_query_id :=-1;
         arg_num_rowset := 0 ;
         arg_err_msg := arg_err_msg || fnd_message.get_string('MSC','MSC_X_HZ_NODATA');

         if (osce_bucketed_plan%ISOPEN) then
            close osce_bucketed_plan;
         end if;

      WHEN OTHERS THEN
         if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
           FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module || 'populate_bucketed_quantity', SQLERRM);
          end if;
         arg_query_id :=-1;
         arg_err_msg := arg_err_msg || fnd_message.get_string('MSC','MSC_X_HZ_NODATA');
         arg_num_rowset := 0 ;

         if (osce_bucketed_plan%ISOPEN) then
            close osce_bucketed_plan;
         end if;

   END;

   /**
    * The foll function retrieves the meaning for different
    * lookup types and codes from teh fnd_lookup_values table.
    */
   FUNCTION get_lookup_name(v_lookup_type IN VARCHAR2, v_lookup_code IN NUMBER) RETURN VARCHAR2
   IS
      v_name VARCHAR2(250) := '';
   BEGIN
      SELECT meaning INTO v_name
        FROM fnd_lookup_values
       WHERE lookup_type =  v_lookup_type
         AND lookup_code = nvl(v_lookup_code,-1)
         AND language = userenv('lang');

      return v_name;
   EXCEPTION
      when no_data_found then
         if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module || 'get_lookup', SQLERRM);
         end if;
         return null;

      when others then
         if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module || 'get_lookup', SQLERRM);
         end if;
         return null;
   END;






END MSC_X_HZ_PLAN;

/
