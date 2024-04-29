--------------------------------------------------------
--  DDL for Package Body MSC_GLOBAL_FORECASTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_GLOBAL_FORECASTING" AS
/*  $Header: MSCPHOGB.pls 120.11.12010000.2 2009/11/30 12:54:49 vkkandul ship $ */

SYS_YES  CONSTANT INTEGER := 1;
SYS_NO   CONSTANT INTEGER := 2;


ORIGINAL            CONSTANT INTEGER := 210;  /* GLOBAL FORECASTING lookup */
CUM_ORIGINAL        CONSTANT INTEGER := 220;
CONSUMED            CONSTANT INTEGER := 230;
CUM_CONSUMED        CONSTANT INTEGER := 240;
FCST_SUBS_IN        CONSTANT INTEGER := 243;
FCST_SUBS_OUT       CONSTANT INTEGER := 246;
CURRENT             CONSTANT INTEGER := 250;
CUM_CURRENT         CONSTANT INTEGER := 260;
EXPIRED             CONSTANT INTEGER := 270;
OVER_CONSUMED       CONSTANT INTEGER := 280; -- not shown
SO_ORIGINAL         CONSTANT INTEGER := 310;
SO_SUBS_IN          CONSTANT INTEGER := 320;
SO_SUBS_OUT         CONSTANT INTEGER := 330;
SO_CURRENT          CONSTANT INTEGER := 340;

ORIGINAL_OFF        CONSTANT INTEGER := 0; /* offsets */
CUM_ORIGINAL_OFF    CONSTANT INTEGER := 1;
CONSUMED_OFF        CONSTANT INTEGER := 2;
CUM_CONSUMED_OFF    CONSTANT INTEGER := 3;
FCST_SUBS_IN_OFF    CONSTANT INTEGER := 4;
FCST_SUBS_OUT_OFF   CONSTANT INTEGER := 5;
CURRENT_OFF         CONSTANT INTEGER := 6;
CUM_CURRENT_OFF     CONSTANT INTEGER := 7;
EXPIRED_OFF         CONSTANT INTEGER := 8;
SO_ORIGINAL_OFF     CONSTANT INTEGER := 9;
SO_SUBS_IN_OFF      CONSTANT INTEGER := 10;
SO_SUBS_OUT_OFF     CONSTANT INTEGER := 11;
SO_CURRENT_OFF      CONSTANT INTEGER := 12;
OVER_CONSUMED_OFF   CONSTANT INTEGER := 13;

NUM_OF_TYPES        CONSTANT INTEGER := 14;

/* global variable for number of buckets to display for the plan */
g_num_of_buckets	NUMBER;

g_error_stmt		VARCHAR2(200);



  NODE_REGULAR_ITEM CONSTANT NUMBER :=0;
  NODE_ITEM_SUPPLIER CONSTANT NUMBER := 1;
  NODE_DEPT_RES CONSTANT NUMBER := 2;
  NODE_LINE CONSTANT NUMBER := 3;
  NODE_TRANS_RES CONSTANT NUMBER := 4;
  NODE_PF_ITEM CONSTANT NUMBER := 5;
  NODE_GL_FORECAST_ITEM CONSTANT NUMBER := 6;

TYPE column_number IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

Procedure populate_horizontal_plan (
                             item_list_id IN NUMBER,
                             arg_plan_id IN NUMBER,
                             arg_plan_organization_id IN NUMBER,
                             arg_plan_instance_id IN NUMBER,
                             arg_cutoff_date IN DATE,
                             enterprize_view IN BOOLEAN,
                             arg_res_level IN NUMBER DEFAULT 1,
                             arg_resval1 IN VARCHAR2 DEFAULT NULL,
                             arg_resval2 IN NUMBER DEFAULT NULL,
                             arg_ep_view_also IN BOOLEAN DEFAULT FALSE) IS

-- -------------------------------------------------
-- This cursor select number of buckets in the plan.
-- -------------------------------------------------
CURSOR plan_buckets IS
SELECT DECODE(arg_plan_id, -1, sysdate, trunc(curr_start_date)),
	DECODE(arg_plan_id, -1, sysdate+365, trunc(curr_cutoff_date))
FROM msc_plans
WHERE plan_id = arg_plan_id;

CURSOR get_plan_type IS
Select plan_type
FROM msc_plans
WHERE plan_id = arg_plan_id;

-- -------------------------------------------------
-- This cursor selects the dates for the buckets.
-- -------------------------------------------------
CURSOR bucket_dates(p_start_date DATE, p_end_date DATE) IS
SELECT cal.calendar_date
FROM msc_calendar_dates cal,
msc_trading_partners tp
WHERE tp.sr_tp_id = arg_plan_organization_id
AND tp.sr_instance_id = arg_plan_instance_id
AND tp.calendar_exception_set_id = cal.exception_set_id
AND tp.partner_type = 3
AND tp.calendar_code = cal.calendar_code
AND tp.sr_instance_id = cal.sr_instance_id
AND cal.calendar_date BETWEEN TRUNC(p_start_date) AND TRUNC(p_end_date)
ORDER BY cal.calendar_date;

l_plan_start_date	DATE;
l_plan_end_date		DATE;

l_bucket_number		NUMBER := 0;
l_bucket_date		DATE;

last_date       DATE;

l_plan_type NUMBER := 1;

-- --------------------------------------------
-- This cursor selects the snapshot activity in
-- MSC_DEMANDS and MSC_SUPPLIES
-- for the items per organizatio for a plan..
-- --------------------------------------------

--  Ship To Values
--  7 Customer Site
--  4 Customer
--  9 Customer Zone
--  8 Zone
-- 10 Demand Class
--  6 Item
--  2 Ship_ID
--  3 Bill_ID

CURSOR  mrp_snapshot_global_activity IS
SELECT  list.number5 item_id,
        list.number6 org_id,
        list.number3 inst_id,
        decode(list.number8, 4,  nvl(to_char(md.customer_id), '-99'),
                             6,  to_char(md.inventory_item_id),
                             7,  nvl(to_char(md.customer_site_id), '-99'),
                             8,  nvl(to_char(md.zone_id),'-99'),
                             9,  decode(md.zone_id, null, '-99',
                                    to_char(md.customer_id)||':'||
                                     to_char(md.zone_id)),
                             2,  nvl(to_char(md.ship_to_site_id),'-99'),
                             3,  nvl(to_char(md.bill_id),'-99'),
                             10, nvl(md.demand_class,'-99'), '-1') ship_to,
        decode(md.origination_type,6, SO_ORIGINAL, 30, SO_ORIGINAL,
               ORIGINAL) row_type,
        decode(md.origination_type,6, SO_ORIGINAL_OFF, 30, SO_ORIGINAL_OFF,
               ORIGINAL_OFF) offset,
        md.using_assembly_demand_date new_date,
        md.using_assembly_demand_date old_date,
        sum(md.using_requirement_quantity) new_quantity,
        sum(nvl(md.UNMET_QUANTITY,0)) unmet_quantity
FROM    msc_form_query      list,
        msc_demands  md
WHERE   md.plan_id = list.number4
AND     md.inventory_item_id = list.number1
AND     md.organization_id = list.number2
AND     md.sr_instance_id = list.number3
AND     list.query_id = item_list_id
and     md.origination_type in (7, 29, 6, 30)
and     trunc(md.using_assembly_demand_date) <= l_plan_end_date
and     list.number7 = NODE_GL_FORECAST_ITEM   -- Select only GF
and     (md.original_item_id is null or
         md.original_item_id = md.inventory_item_id)
GROUP BY
        list.number5,
        list.number6,
        list.number3,
        decode(list.number8, 4,  nvl(to_char(md.customer_id), '-99'),
                             6,  to_char(md.inventory_item_id),
                             7,  nvl(to_char(md.customer_site_id), '-99'),
                             8,  nvl(to_char(md.zone_id),'-99'),
                             9,  decode(md.zone_id, null, '-99',
                                    to_char(md.customer_id)||':'||
                                     to_char(md.zone_id)),
                             2,  nvl(to_char(md.ship_to_site_id),'-99'),
                             3,  nvl(to_char(md.bill_id),'-99'),
                             10, nvl(md.demand_class,'-99'), '-1'),
        decode(md.origination_type,6, SO_ORIGINAL, 30, SO_ORIGINAL,
               ORIGINAL),
        decode(md.origination_type,6, SO_ORIGINAL_OFF, 30, SO_ORIGINAL_OFF,
               ORIGINAL_OFF),
        md.using_assembly_demand_date
UNION ALL
SELECT  list.number5 item_id,
        list.number6 org_id,
        list.number3 inst_id,
        decode(list.number8, 6,  to_char(forecast.inventory_item_id),
                             2,  nvl(to_char(forecast.ship_id),'-99'),
                             3,  nvl(to_char(forecast.bill_id),'-99'),
                             10, nvl(forecast.demand_class,'-99'),
                             MSC_GLOBAL_FORECASTING.get_ship_to(
                                 list.number8,
                                 forecast.plan_id,
                                 forecast.sales_order_id)) ship_to,
        CONSUMED row_type,
        CONSUMED_OFF offset,
        forecast.consumption_date new_date,
        forecast.consumption_date old_date,
        sum(nvl(forecast.consumed_qty,0)) new_quantity,
        0 old_quantity
FROM    msc_form_query      list,
        msc_forecast_updates forecast
where   forecast.organization_id = list.number2
AND     forecast.plan_id = list.number4
AND     forecast.inventory_item_id = list.number1
AND     forecast.sr_instance_id = list.number3
AND     list.query_id = item_list_id
and     trunc(forecast.consumption_date) <= l_plan_end_date
and     list.number7 = NODE_GL_FORECAST_ITEM   -- Select only GF
GROUP BY
        list.number5,
        list.number6,
        list.number3,
        decode(list.number8, 6,  to_char(forecast.inventory_item_id),
                             2,  nvl(to_char(forecast.ship_id),'-99'),
                             3,  nvl(to_char(forecast.bill_id),'-99'),
                             10, nvl(forecast.demand_class,'-99'),
                             MSC_GLOBAL_FORECASTING.get_ship_to(
                                 list.number8,
                                 forecast.plan_id,
                                 forecast.sales_order_id)),
        CONSUMED, CONSUMED_OFF,
        forecast.consumption_date
UNION ALL -- substitution in
SELECT  list.number5 item_id,
        list.number6 org_id,
        list.number3 inst_id,
        decode(list.number8, 4,  nvl(to_char(md.customer_id), '-99'),
                             6,  to_char(md.inventory_item_id),
                             7,  nvl(to_char(md.customer_site_id), '-99'),
                             8,  nvl(to_char(md.zone_id),'-99'),
                             9,  decode(md.zone_id, null, '-99',
                                    to_char(md.customer_id)||':'||
                                     to_char(md.zone_id)),
                             2,  nvl(to_char(md.ship_to_site_id),'-99'),
                             3,  nvl(to_char(md.bill_id),'-99'),
                             10, nvl(md.demand_class,'-99'), '-1') ship_to,
        decode(md.origination_type, 6, SO_SUBS_IN, 30, SO_SUBS_IN,
               FCST_SUBS_IN) row_type,
        decode(md.origination_type, 6, SO_SUBS_IN_OFF, 30, SO_SUBS_IN_OFF,
               FCST_SUBS_IN_OFF) offset,
        md.using_assembly_demand_date new_date,
        md.using_assembly_demand_date old_date,
        sum(nvl(md.using_requirement_quantity,0)) new_quantity,
        sum(nvl(md.UNMET_QUANTITY,0)) unmet_quantity
FROM    msc_form_query      list,
        msc_demands  md
WHERE   md.plan_id = list.number4
AND     md.inventory_item_id = list.number1
AND     md.organization_id = list.number2
AND     md.sr_instance_id = list.number3
AND     list.query_id = item_list_id
and     md.origination_type in (7, 29, 6, 30)
and     trunc(md.using_assembly_demand_date) <= l_plan_end_date
and     md.original_item_id <> md.inventory_item_id
and     list.number7 = NODE_GL_FORECAST_ITEM   -- Select only GF
GROUP BY
        list.number5,
        list.number6,
        list.number3,
        decode(list.number8, 4,  nvl(to_char(md.customer_id), '-99'),
                             6,  to_char(md.inventory_item_id),
                             7,  nvl(to_char(md.customer_site_id), '-99'),
                             8,  nvl(to_char(md.zone_id),'-99'),
                             9,  decode(md.zone_id, null, '-99',
                                    to_char(md.customer_id)||':'||
                                     to_char(md.zone_id)),
                             2,  nvl(to_char(md.ship_to_site_id),'-99'),
                             3,  nvl(to_char(md.bill_id),'-99'),
                             10, nvl(md.demand_class,'-99'), '-1'),
        decode(md.origination_type, 6, SO_SUBS_IN, 30, SO_SUBS_IN,
               FCST_SUBS_IN),
        decode(md.origination_type, 6, SO_SUBS_IN_OFF, 30, SO_SUBS_IN_OFF,
               FCST_SUBS_IN_OFF),
        md.using_assembly_demand_date
UNION ALL -- substitution out
SELECT  list.number5 item_id,
        list.number6 org_id,
        list.number3 inst_id,
        decode(list.number8, 4,  nvl(to_char(md.customer_id), '-99'),
                             6,  to_char(list.number1),
                             7,  nvl(to_char(md.customer_site_id), '-99'),
                             8,  nvl(to_char(md.zone_id),'-99'),
                             9,  decode(md.zone_id, null, '-99',
                                    to_char(md.customer_id)||':'||
                                     to_char(md.zone_id)),
                             2,  nvl(to_char(md.ship_to_site_id),'-99'),
                             3,  nvl(to_char(md.bill_id),'-99'),
                             10, nvl(md.demand_class,'-99'), '-1') ship_to,
        decode(md.origination_type, 6, SO_SUBS_OUT, 30, SO_SUBS_OUT,
               FCST_SUBS_OUT) row_type,
        decode(md.origination_type, 6, SO_SUBS_OUT_OFF, 30, SO_SUBS_OUT_OFF,
               FCST_SUBS_OUT_OFF) offset,
        md.using_assembly_demand_date new_date,
        md.using_assembly_demand_date old_date,
        sum(nvl(md.using_requirement_quantity,0)) new_quantity,
        sum(nvl(md.UNMET_QUANTITY,0)) unmet_quantity
FROM    msc_form_query      list,
        msc_demands  md
WHERE   md.plan_id = list.number4
AND     md.original_item_id = list.number1
AND     md.organization_id = list.number2
AND     md.sr_instance_id = list.number3
AND     list.query_id = item_list_id
and     md.origination_type in (7, 29, 6, 30)
and     trunc(md.using_assembly_demand_date) <= l_plan_end_date
and     md.original_item_id <> md.inventory_item_id
and     list.number7 = NODE_GL_FORECAST_ITEM   -- Select only GF
GROUP BY
        list.number5,
        list.number6,
        list.number3,
        decode(list.number8, 4,  nvl(to_char(md.customer_id), '-99'),
                             6,  to_char(list.number1),
                             7,  nvl(to_char(md.customer_site_id), '-99'),
                             8,  nvl(to_char(md.zone_id),'-99'),
                             9,  decode(md.zone_id, null, '-99',
                                    to_char(md.customer_id)||':'||
                                     to_char(md.zone_id)),
                             2,  nvl(to_char(md.ship_to_site_id),'-99'),
                             3,  nvl(to_char(md.bill_id),'-99'),
                             10, nvl(md.demand_class,'-99'), '-1'),
        decode(md.origination_type, 6, SO_SUBS_OUT, 30, SO_SUBS_OUT,
               FCST_SUBS_OUT) ,
        decode(md.origination_type, 6, SO_SUBS_OUT_OFF, 30, SO_SUBS_OUT_OFF,
               FCST_SUBS_OUT_OFF) ,
        md.using_assembly_demand_date
UNION ALL
--------------------------------------------------------------------
-- This select will ensure that all selected items get into cursor
-- even though they do not have any activity
---------------------------------------------------------------------
SELECT  list.number5,
        list.number6,
        list.number3,
        '0',
        ORIGINAL,
        ORIGINAL_OFF,
        to_date(1, 'J'),
        to_date(1, 'J'),
        0,
        0
FROM    msc_form_query list
WHERE   list.query_id = item_list_id
ORDER BY
     1, 2,4,7;

TYPE mrp_activity IS RECORD
     (item_id      NUMBER,
      org_id       NUMBER,
      inst_id       NUMBER,
      ship_to      VARCHAR2(200),
      row_type     NUMBER,
      offset       NUMBER,
      new_date     DATE,
      old_date     DATE,
      new_quantity NUMBER,
      unmet_quantity NUMBER);

activity_rec     mrp_activity;

TYPE calendar_date IS TABLE OF DATE INDEX BY BINARY_INTEGER;

TYPE column_char   IS TABLE OF VARCHAR2(255) INDEX BY BINARY_INTEGER;

var_dates           calendar_date;   -- Holds the start dates of buckets
bucket_cells_tab    column_number;       -- Holds the quantities per bucket
ep_bucket_cells_tab    column_number;
last_item_id        NUMBER := -2;

last_org_id        NUMBER := -2;
last_inst_id        NUMBER := -2;
last_ship_to        varchar2(200) := '-2';

bucket_counter BINARY_INTEGER := 0; -- Id of the current bucket
counter        BINARY_INTEGER := 0;

-- =============================================================================
--
-- add_to_plan add the 'quantity' to the correct cell of the current bucket.
--
-- =============================================================================

PROCEDURE add_to_plan(bucket IN NUMBER,
                      offset IN NUMBER,
                      quantity IN NUMBER,
                      p_enterprise IN boolean default false) IS
location NUMBER;
BEGIN
  g_error_stmt := 'Debug - add_to_plan - 10 '||offset||','||bucket||','||quantity;
/*
 if offset = CONSUMED_OFF then
   dbms_output.put_line(bucket||','||quantity);
 end if;
*/
  if quantity = 0 then
     return;
  end if;

  IF p_enterprise then
     location := (bucket - 1) + offset;
         ep_bucket_cells_tab(location) :=
             NVL(ep_bucket_cells_tab(location),0) + quantity;
  ELSE  -- not enterprize view
     location := ((bucket - 1) * NUM_OF_TYPES) + offset;
     bucket_cells_tab(location) :=
         NVL(bucket_cells_tab(location),0) + quantity;
  END IF;

END;

-- =============================================================================
--
-- flush_item_plan inserts into MRP_MATERIAL_PLANS
--
-- =============================================================================

PROCEDURE flush_item_plan(p_item_id IN NUMBER,
                          p_org_id IN NUMBER,
                          p_inst_id IN NUMBER,
                          p_ship_to IN VARCHAR2) IS
loop_counter BINARY_INTEGER := 1;

l_org_cum NUMBER := 0;
l_consumed_cum NUMBER :=0;
l_current_cum NUMBER := 0;
l_current NUMBER := 0;

  TYPE bkt_data_rec IS RECORD(
       qty1 column_number,
       qty2 column_number,
       qty3 column_number,
       qty4 column_number,
       qty5 column_number,
       qty6 column_number,
       qty7 column_number,
       qty8 column_number,
       qty9 column_number,
       qty10 column_number,
       qty11 column_number,
       qty12 column_number,
       qty13 column_number);

  bkt_data bkt_data_rec;

BEGIN

  IF NOT enterprize_view THEN

    FOR loop IN 1..g_num_of_buckets LOOP

 --   ----------------------------
 --   Calculate Cumulative Original
 --   -----------------------------

   -- original qty is after subs out, needs to add them back

    add_to_plan(loop,
          ORIGINAL_OFF,
          bucket_cells_tab(((loop-1) * NUM_OF_TYPES) + FCST_SUBS_OUT_OFF)) ;

    add_to_plan(loop,
          ORIGINAL_OFF,
          bucket_cells_tab(((loop-1) * NUM_OF_TYPES) + CONSUMED_OFF)) ;

    add_to_plan(loop,
          SO_ORIGINAL_OFF,
          bucket_cells_tab(((loop-1) * NUM_OF_TYPES) + SO_SUBS_OUT_OFF)) ;


    l_org_cum := l_org_cum +
                 bucket_cells_tab(((loop-1) * NUM_OF_TYPES) + ORIGINAL_OFF);

               add_to_plan(loop,
               CUM_ORIGINAL_OFF,
               l_org_cum);

 --   ----------------------------
 --   Calculate Cumulative Consumed
 --   -----------------------------

    l_consumed_cum := l_consumed_cum +
               bucket_cells_tab(((loop-1) * NUM_OF_TYPES) + CONSUMED_OFF);

               add_to_plan(loop,
               CUM_CONSUMED_OFF,
               l_consumed_cum);


 --   ----------------------------
 --   Calculate Current    current = Origina  -  (consumed + over consumed)
 --   -----------------------------


               add_to_plan(loop,
               CURRENT_OFF,
               bucket_cells_tab(((loop-1) * NUM_OF_TYPES) + ORIGINAL_OFF) -
               bucket_cells_tab(((loop-1) * NUM_OF_TYPES) + CONSUMED_OFF) +
               bucket_cells_tab(((loop-1) * NUM_OF_TYPES) + FCST_SUBS_IN_OFF) -
               bucket_cells_tab(((loop-1) * NUM_OF_TYPES) + FCST_SUBS_OUT_OFF)
) ;

               add_to_plan(loop,
               SO_CURRENT_OFF,
               bucket_cells_tab(((loop-1) * NUM_OF_TYPES) + SO_ORIGINAL_OFF) +
               bucket_cells_tab(((loop-1) * NUM_OF_TYPES) + SO_SUBS_IN_OFF) -
               bucket_cells_tab(((loop-1) * NUM_OF_TYPES) + SO_SUBS_OUT_OFF)) ;

 --   ----------------------------
 --   Calculate Cumulative Current
 --   -----------------------------

    l_current_cum := l_current_cum +
               bucket_cells_tab(((loop-1) * NUM_OF_TYPES) + CURRENT_OFF);

               add_to_plan(loop,
               CUM_CURRENT_OFF,
               l_current_cum);

      g_error_stmt := 'Debug - flush_item_plan - 30 - loop'||loop;

   END LOOP;

    g_error_stmt := 'Debug - flush_item_plan - 70';
    FOR bkt IN 1..g_num_of_buckets LOOP
      bkt_data.qty1(bkt) :=
        bucket_cells_tab(NUM_OF_TYPES * (bkt - 1) + 0);
      bkt_data.qty2(bkt) :=
        bucket_cells_tab(NUM_OF_TYPES * (bkt - 1) + 1);
      bkt_data.qty3(bkt) :=
        bucket_cells_tab(NUM_OF_TYPES * (bkt - 1) + 2);
      bkt_data.qty4(bkt) :=
        bucket_cells_tab(NUM_OF_TYPES * (bkt - 1) + 3);
      bkt_data.qty5(bkt) :=
        bucket_cells_tab(NUM_OF_TYPES * (bkt - 1) + 4);
      bkt_data.qty6(bkt) :=
        bucket_cells_tab(NUM_OF_TYPES * (bkt - 1) + 5);
      bkt_data.qty7(bkt) :=
        bucket_cells_tab(NUM_OF_TYPES * (bkt - 1) + 6);
      bkt_data.qty8(bkt) :=
        bucket_cells_tab(NUM_OF_TYPES * (bkt - 1) + 7);
      bkt_data.qty9(bkt) :=
        bucket_cells_tab(NUM_OF_TYPES * (bkt - 1) + 8);
      bkt_data.qty10(bkt) :=
        bucket_cells_tab(NUM_OF_TYPES * (bkt - 1) + 9);
      bkt_data.qty11(bkt) :=
        bucket_cells_tab(NUM_OF_TYPES * (bkt - 1) + 10);
      bkt_data.qty12(bkt) :=
        bucket_cells_tab(NUM_OF_TYPES * (bkt - 1) + 11);
      bkt_data.qty13(bkt) :=
        bucket_cells_tab(NUM_OF_TYPES * (bkt - 1) + 12);
    END LOOP;

    FORALL bkt in 1..nvl(bkt_data.qty1.last,0)
      INSERT INTO msc_material_plans(
        query_id,
        organization_id,
        sr_instance_id,
        plan_id,
        plan_organization_id,
        plan_instance_id,
        inventory_item_id,
        horizontal_plan_type,
        horizontal_plan_type_text,
        item_segments, -- store ship_to_level
        bucket_type,
        bucket_date,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        quantity1,  quantity2,  quantity3,  quantity4,
        quantity5,  quantity6,  quantity7,  quantity8,
        quantity9,  quantity10,  quantity11,  quantity12,
        quantity13)
      VALUES (
        item_list_id,
        p_org_id,
        p_inst_id,
        arg_plan_id,
        arg_plan_organization_id,
        arg_plan_instance_id,
        p_item_id,
        1,
        'GLOBAL',
        p_ship_to,
        1,
        var_dates(bkt),
        SYSDATE,
        -1,
        SYSDATE,
        -1,
        bkt_data.qty1(bkt),
        bkt_data.qty2(bkt),
        bkt_data.qty3(bkt),
        bkt_data.qty4(bkt),
        bkt_data.qty5(bkt),
        bkt_data.qty6(bkt),
        bkt_data.qty7(bkt),
        bkt_data.qty8(bkt),
        bkt_data.qty9(bkt),
        bkt_data.qty10(bkt),
        bkt_data.qty11(bkt),
        bkt_data.qty12(bkt),
        bkt_data.qty13(bkt));

  END IF; -- not enterprize view

  IF enterprize_view or arg_ep_view_also then -- enterprise view

    INSERT INTO msc_material_plans(
      query_id,
      organization_id,
      sr_instance_id,
      plan_id,
      plan_organization_id,
      plan_instance_id,
      inventory_item_id,
      horizontal_plan_type,
      horizontal_plan_type_text,
      item_segments, -- store ship_to_level
      bucket_type,
      bucket_date,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      quantity1,  quantity2,  quantity3,  quantity4,
      quantity5,  quantity6,  quantity7,  quantity8,
      quantity9,  quantity10,  quantity11,  quantity12,
      quantity13)
    VALUES (
      item_list_id,
      p_org_id,
      p_inst_id,
      arg_plan_id,
      arg_plan_organization_id,
      arg_plan_instance_id,
      p_item_id,
      10,
      'GLOBAL',
      p_ship_to,
      1,
      sysdate,
      SYSDATE,
      -1,
      SYSDATE,
      -1,
    ep_bucket_cells_tab(0),
    ep_bucket_cells_tab(1),
    ep_bucket_cells_tab(2),
    ep_bucket_cells_tab(3),
    ep_bucket_cells_tab(4),
--    ep_bucket_cells_tab(0) - ep_bucket_cells_tab(2),
    ep_bucket_cells_tab(5),
    ep_bucket_cells_tab(6),
    ep_bucket_cells_tab(7),
    ep_bucket_cells_tab(8),
    ep_bucket_cells_tab(9),
    ep_bucket_cells_tab(10),
    ep_bucket_cells_tab(11),
    ep_bucket_cells_tab(12));
  END IF;

END flush_item_plan;

-- =============================================================================

BEGIN

  g_error_stmt := 'Debug - populate_horizontal_plan - 10';

  OPEN plan_buckets;
  FETCH plan_buckets into l_plan_start_date, l_plan_end_date;
  CLOSE plan_buckets;

  OPEN  get_plan_type;
  FETCH get_plan_type into l_plan_type;
  CLOSE get_plan_type;

  g_num_of_buckets := (l_plan_end_date + 1) - (l_plan_start_date - 1);

  g_error_stmt := 'Debug - populate_horizontal_plan - 20';
  -- ---------------------------------
  -- Initialize the bucket cells to 0.
  -- ---------------------------------
  IF enterprize_view or arg_ep_view_also THEN
    FOR counter IN 0..NUM_OF_TYPES LOOP
      ep_bucket_cells_tab(counter) := 0;
    END LOOP;
    last_date := arg_cutoff_date;
  END IF;

  IF not (enterprize_view) THEN
    FOR counter IN 0..(NUM_OF_TYPES * g_num_of_buckets) LOOP
      bucket_cells_tab(counter) := 0;
    END LOOP;

    g_error_stmt := 'Debug - populate_horizontal_plan - 30';
    -- --------------------
    -- Get the bucket dates
    -- --------------------
    OPEN bucket_dates(l_plan_start_date-1, l_plan_end_date+1);
    LOOP
      FETCH bucket_dates INTO l_bucket_date;
      EXIT WHEN BUCKET_DATES%NOTFOUND;
      l_bucket_number := l_bucket_number + 1;
      var_dates(l_bucket_number) := l_bucket_date;
    END LOOP;
    CLOSE bucket_dates;

    last_date := arg_cutoff_date;
  END IF;

  g_error_stmt := 'Debug - populate_horizontal_plan - 40';
  bucket_counter := 2;
     activity_rec.item_id := 0;
     activity_rec.ship_to := '0';
     activity_rec.org_id := 0;
     activity_rec.inst_id := 0;
     activity_rec.row_type := 0;
     activity_rec.offset := 0;
     activity_rec.new_date := sysdate;
     activity_rec.old_date := sysdate;
     activity_rec.new_quantity := 0;
     activity_rec.unmet_quantity := 0;

--dbms_output.put_line(' before loop');

  OPEN mrp_snapshot_global_activity;
  LOOP
        FETCH mrp_snapshot_global_activity INTO  activity_rec;
--if activity_rec.row_type = CONSUMED then
--dbms_output.put_line( activity_rec.item_id || ' ' || activity_rec.org_id || ' ' || activity_rec.inst_id || ' ' || activity_rec.ship_to || ' ' || activity_rec.row_type || ' ' || activity_rec.new_date || ' '  || activity_rec.new_quantity);
--end if;
--dbms_output.put_line( 'LAST ' || last_item_id || ' ' || last_org_id || '  ' || last_inst_id || ' ' || last_ship_to || ' '  );

        IF ((mrp_snapshot_global_activity%NOTFOUND) OR
            (activity_rec.item_id <> last_item_id) OR
            (activity_rec.org_id  <> last_org_id) OR
            (activity_rec.inst_id <> last_inst_id) OR
            (activity_rec.ship_to <> last_ship_to)) AND
             last_item_id <> -2 THEN

        -- --------------------------
        -- Need to flush the plan for
        -- the previous item.
        -- --------------------------

     -- dbms_output.put_line (' IN SIDE LOOP   ' );

        flush_item_plan(last_item_id,
                        last_org_id,
                        last_inst_id,
                        last_ship_to);

        bucket_counter := 2;
        -- ------------------------------------
        -- Initialize the bucket cells to 0.
        -- ------------------------------------
        IF enterprize_view or arg_ep_view_also THEN
          FOR counter IN 0..NUM_OF_TYPES LOOP
            ep_bucket_cells_tab(counter) := 0;
          END LOOP;
        END IF;
        IF not (enterprize_view) then
          FOR counter IN 0..(NUM_OF_TYPES * g_num_of_buckets) LOOP
            bucket_cells_tab(counter) := 0;
          END LOOP;
        END IF;
      END IF;  -- end of activity_rec.item_id <> last_item_id

      EXIT WHEN mrp_snapshot_global_activity%NOTFOUND;

    IF enterprize_view or arg_ep_view_also THEN
      add_to_plan(activity_rec.offset + 1 , 0,
      activity_rec.new_quantity,true);
      if activity_rec.row_type = ORIGINAL then
          add_to_plan(EXPIRED_OFF + 1 , 0,
                      activity_rec.unmet_quantity,true);
      end if;
    END IF;

    IF not(enterprize_view) THEN

       IF  (bucket_counter <= g_num_of_buckets AND
            activity_rec.new_date >= var_dates(bucket_counter)) THEN

        -- -------------------------------------------------------
        -- We got an activity falls after the current bucket. So we
        -- will move the bucket counter forward until we find the
        -- bucket where this activity falls.  Note that we should
        -- not advance the counter bejond g_num_of_buckets.
        -- --------------------------------------------------------
        WHILE  (bucket_counter < g_num_of_buckets AND
                 activity_rec.new_date >= var_dates(bucket_counter)) LOOP

             bucket_counter := bucket_counter + 1;

        END LOOP;
      END IF;

       IF  (bucket_counter <= g_num_of_buckets AND
            activity_rec.new_date <= var_dates(bucket_counter)) THEN

        add_to_plan(bucket_counter - 1,
            activity_rec.offset,
                    activity_rec.new_quantity);
        if activity_rec.row_type = ORIGINAL then

          add_to_plan(bucket_counter - 1,
                      EXPIRED_OFF,
                      activity_rec.unmet_quantity);
        end if;
      END IF;

    END IF;  -- if not enterprise view

    last_item_id := activity_rec.item_id;
    last_ship_to := activity_rec.ship_to;
    last_org_id := activity_rec.org_id;
    last_inst_id := activity_rec.inst_id;
  END LOOP;


  g_error_stmt := 'Debug - populate_horizontal_plan - 50';
  CLOSE mrp_snapshot_global_activity;

EXCEPTION

  WHEN OTHERS THEN
    null;
--    dbms_output.put_line(g_error_stmt);
    raise;

END populate_horizontal_plan;


PROCEDURE query_list(
		p_query_id IN NUMBER,
                p_plan_id IN NUMBER,
                p_item_list IN VARCHAR2,
                p_org_list IN VARCHAR2) IS

  p_item_id column_number;
  p_org_id column_number;
  p_inst_id column_number;

  a number :=0;
  l_len number;
  one_record varchar2(100);
  startPos number;
  endPos number;
  p_all_org_string varchar2(80) :='Global Org';

  p_node_type number := NODE_GL_FORECAST_ITEM;
  p_ship_to_level number :=0;

  cursor ship_level is
    select mps.ship_to
      from msc_plan_schedules mps
     where mps.plan_id = p_plan_id
       and mps.organization_id =-1
       and mps.ship_to is not null;


  cursor local_forecasting(p_org number, p_inst number, p_item number) is
    select mde.update_type
    from msc_designators mde,
         msc_demands md
    where md.plan_id = p_plan_id
    and   md.organization_id = p_org
    and   md.sr_instance_id = p_inst
    and   md.inventory_item_id = p_item
    and   md.schedule_designator_id = mde.designator_id;

   cursor org_c is
    select organization_id, sr_instance_id
      from msc_plan_organizations
     where plan_id = p_plan_id;

   p_display_org_id number;
   p_display_org varchar2(100);
BEGIN


 if p_org_list is null then
    -- view item across orgs
     OPEN org_c;
     FETCH org_c BULK COLLECT INTO p_org_id, p_inst_id;
     CLOSE org_c;
  else
     l_len := length(p_org_list);
     WHILE l_len > 0 LOOP
        a := a+1;
        one_record := substr(p_org_list,instr(p_org_list,'(',1,a)+1,
                           instr(p_org_list,')',1,a)-instr(p_org_list,'(',1,a)-1);

        p_inst_id(a) := to_number(substr(one_record,1,instr(one_record,',')-1));
        p_org_id(a) := to_number(substr(one_record,instr(one_record,',')+1));
        l_len := l_len - length(one_record)-3;

     END LOOP;
  end if; -- p_org_list is null

--   dbms_output.put_line(' given item list is ' || p_item_list);

  a :=1;
  startPos :=1;
  endPos := instr(p_item_list||',', ',',1,a);
  while endPos >0 loop
           l_len := endPos - startPos;
        p_item_id(a) := to_number(substr(p_item_list||',',startPos, l_len));
        a := a+1;
        startPos := endPos+1;
        endPos := instr(p_item_list||',', ',',1,a);
  end loop;
/*
dbms_output.put_line(' total items ' || p_item_id.count);
dbms_output.put_line(' org id count '|| p_org_id.count);
dbms_output.put_line(' item id count '|| p_item_id.count);
*/

--  Check if its Global or Local Forecasting

          OPEN ship_level;
          FETCH ship_level INTO p_ship_to_level;
          CLOSE ship_level;
-- dbms_output.put_line(' ship to ' || p_ship_to_level);

if p_ship_to_level = 0 then
     -- no global demand sch is present, this is Local case

  for a in 1..p_org_id.count loop
      if p_org_list is null then
         -- view item across all orgs
         p_display_org_id := -1;
         p_display_org := p_all_org_string ||' (Local Forecasting)';
      else
         p_display_org_id := p_org_id(a);
         p_display_org :=
            msc_get_name.org_code(p_org_id(a), p_inst_id(a)) ||
           ' (Local Forecasting)';
      end if;
  for b in 1..p_item_id.count loop

        OPEN  local_forecasting(p_org_id(a), p_inst_id(a), p_item_id(b));
        FETCH local_forecasting INTO p_ship_to_level;
        CLOSE local_forecasting;
--dbms_output.put_line(p_org_id(a)||','|| p_inst_id(a)||','|| p_item_id(b)||','||p_ship_to_level||','||p_display_org_id);
     begin
        INSERT INTO msc_form_query (
        query_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        number1,  -- item_id
        number2,
        number3,
        number4,  -- plan_id
        number5,  -- displayed item_id
        number6,  -- displayed org_id
        number7,  -- node type
        number8,  -- ship_to_level
        char1,
        char2)
        SELECT p_query_id,
        sysdate,
        1,
        sysdate,
        1,
        1,
        inventory_item_id,
        organization_id,
        sr_instance_id,
        p_plan_id,
        inventory_item_id,
        p_display_org_id,
        p_node_type,
        nvl(p_ship_to_level,0),
        p_display_org,
        item_name
        FROM msc_system_items
        where plan_id = p_plan_id
          and organization_id = p_org_id(a)
          and sr_instance_id = p_inst_id(a)
          and inventory_item_id = p_item_id(b);

   exception when no_data_found then
     null;
   end;

   p_ship_to_level := 0;

end loop; -- p_item_id.count
end loop; -- p_ord_id.count

else  -- GLOBAL FORECASTING CASE

   forall b in 1..p_item_id.count
        INSERT INTO msc_form_query (
        query_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        number1,  -- item_id
        number2,
        number3,
        number4,  -- plan_id
        number5,  -- displayed item_id
        number6,  -- displayed org_id
        number7,  -- node type
        number8,  -- ship_to_level
        char1,
        char2)
        SELECT p_query_id,
        sysdate,
        1,
        sysdate,
        1,
        1,
        p_item_id(b),
        -1, -- organization_id,
        p_inst_id(1),
        p_plan_id,
        p_item_id(b),
        -1, -- displayed org_id
        p_node_type,
        nvl(p_ship_to_level,0),
        p_all_org_string,
        msc_get_name.item_name(p_item_id(b), null,null,null)
        FROM dual;

End if; -- if p_ship_to_level = 0 then


END query_list;

PROCEDURE get_detail_records(p_query_id IN NUMBER,
                p_node_type IN NUMBER,
		p_plan_id IN NUMBER,
                p_org_id IN NUMBER,
                p_inst_id IN NUMBER,
                p_item_id IN NUMBER,
                p_rowtype IN NUMBER,
                p_ship_level IN NUMBER,
                p_ship_id IN VARCHAR2,
                p_start_date IN DATE,
                p_end_date IN DATE) IS

  sql_stmt	VARCHAR2(32000);
  sql_stmt2	VARCHAR2(32000);
  l_ship_stmt varchar2(5000);
BEGIN

       if(p_ship_level = 4) then --  4 Customer
         if (p_ship_id = '-99' ) then
          l_ship_stmt := ' and md.customer_id is null ';
         else
          l_ship_stmt := ' and md.customer_id   = ' || p_ship_id ;
         end if;
       elsif(p_ship_level = 2) then --  2 ship to
         if (p_ship_id = '-99' ) then
          l_ship_stmt := ' and md.ship_to_site_id is null ';
         else
          l_ship_stmt := ' and md.ship_to_site_id = ' || p_ship_id ;
         end if;
       elsif(p_ship_level = 3) then --  3 bill to
         if (p_ship_id = '-99' ) then
          l_ship_stmt := ' and md.bill_id is null ';
         else
          l_ship_stmt := ' and md.bill_id = ' || p_ship_id ;
         end if;
--       elsif(p_ship_level = 6) then --  6 Item
--          l_ship_stmt := ' and md.inventory_item_id   = ' || p_ship_id ;
       elsif(p_ship_level = 7) then -- 7 Customer Site
         if (p_ship_id = '-99' ) then
          l_ship_stmt := ' and md.customer_site_id is null ';
         else
          l_ship_stmt := ' and md.customer_site_id   = ' || p_ship_id ;
         end if;

       elsif(p_ship_level in (8,9) ) then -- 8 Zone, 9 Customer Zone
         if (p_ship_id = '-99' ) then
           if p_rowtype = CONSUMED then
             -- consumed will show Sales Order which won't have zone
              l_ship_stmt := ' and mfu.zone_id is null ';
           else
              l_ship_stmt := ' and md.zone_id is null ';
           end if;
         else
           if p_rowtype = CONSUMED then
              l_ship_stmt := ' and mfu.zone_id   = ' || p_ship_id ;
           else
              l_ship_stmt := ' and md.zone_id   = ' || p_ship_id ;
           end if;
         end if;
       elsif(p_ship_level = 10 ) then -- 10 Demand Class
         if (p_ship_id = '-99' ) then
          l_ship_stmt := ' and md.demand_class is null ';
         else
          l_ship_stmt := ' and md.demand_class   = ''' || p_ship_id || '''';
         end if;
       end if;

      sql_stmt := 'INSERT INTO msc_form_query ( '||
        'query_id, '||
        'last_update_date, '||
        'last_updated_by, '||
        'creation_date, '||
        'created_by, '||
        'last_update_login, '||
        'number1) ' ||
	'SELECT distinct :p_query_id,' ||
	' sysdate, '||
	' 1, '||
	' sysdate, '||
	' 1, '||
	' 1, ';

  IF p_rowtype = CONSUMED THEN  --  Forecast Consumed Row

      sql_stmt := sql_stmt ||
        ' md.demand_id '||
        ' FROM msc_forecast_updates mfu, msc_demands md'||
        ' WHERE mfu.plan_id = :p_plan_id' ||
        ' AND mfu.sr_instance_id = :p_inst_id'||
        ' and mfu.organization_id =:p_org_id '||
        ' and mfu.inventory_item_id = :p_item_id' ||
        ' and mfu.plan_id = md.plan_id' ||
        ' and mfu.consumed_qty > 0'||
        ' and trunc(mfu.consumption_date) BETWEEN '''||
            p_start_date||''' AND '''|| p_end_date|| '''';

  ELSIF p_rowtype in (ORIGINAL, SO_ORIGINAL,FCST_SUBS_OUT, SO_SUBS_OUT,
                      FCST_SUBS_IN, SO_SUBS_IN) THEN
     if p_org_id = -1 then
       sql_stmt := sql_stmt ||
        ' md2.demand_id '||
        ' FROM msc_demands md,'||
             ' msc_demands md2 '||
        ' WHERE md.plan_id = :p_plan_id' ||
        ' AND md.sr_instance_id = :p_inst_id'||
        ' and md.organization_id =:p_org_id '||
        ' and trunc(md.using_assembly_demand_date) BETWEEN '''||
            p_start_date||''' AND '''|| p_end_date|| ''''||
        ' and md2.plan_id = md.plan_id '||
        ' and nvl(md2.original_demand_id,md2.demand_id) = md.demand_id ';

     else

       sql_stmt := sql_stmt ||
             ' md.demand_id ' ||
        ' FROM msc_demands md'||
        ' WHERE md.plan_id = :p_plan_id' ||
        ' AND md.sr_instance_id = :p_inst_id'||
        ' and md.organization_id =:p_org_id '||
        ' and trunc(md.using_assembly_demand_date) BETWEEN '''||
            p_start_date||''' AND '''|| p_end_date|| '''';
     end if;
     IF p_rowtype in (ORIGINAL, SO_ORIGINAL) THEN
        sql_stmt := sql_stmt ||
        ' and ((md.inventory_item_id = :p_item_id and' ||
             ' (md.original_item_id is null or '||
              ' md.original_item_id = md.inventory_item_id)) OR' ||
             ' (md.original_item_id = :p_item_id and '||
             '  md.original_item_id <> md.inventory_item_id )) ';

     ELSIF p_rowtype in (FCST_SUBS_OUT, SO_SUBS_OUT) THEN
        sql_stmt := sql_stmt ||
        ' and md.original_item_id = :p_item_id' ||
        ' and md.original_item_id <> md.inventory_item_id ';

     ELSIF p_rowtype in (FCST_SUBS_IN, SO_SUBS_IN) THEN
        sql_stmt := sql_stmt ||
        ' and md.inventory_item_id = :p_item_id' ||
        ' and md.original_item_id <> md.inventory_item_id ';

     END IF;

  ELSIF p_rowtype in (CURRENT, SO_CURRENT) THEN  --  Current Row
     IF p_org_id = -1 then
      sql_stmt := sql_stmt ||
        ' orig_md.demand_id ' ||
        ' FROM msc_demands md,'||
             ' msc_demands orig_md'||
        ' WHERE md.plan_id = :p_plan_id' ||
        ' and md.sr_instance_id = :p_inst_id' ||
        ' and md.organization_id =:p_org_id '||
        ' and md.inventory_item_id = :p_item_id' ||
        ' and trunc(md.using_assembly_demand_date) BETWEEN '''||
            p_start_date||''' AND '''|| p_end_date|| ''''||
        ' and md.plan_id = orig_md.plan_id '||
        ' and md.demand_id = nvl(orig_md.original_demand_id, orig_md.demand_id) ';
     ELSE --  IF p_org_id <> -1 then
      sql_stmt := sql_stmt ||
        ' md.demand_id ' ||
        ' FROM msc_demands md'||
        ' WHERE md.plan_id = :p_plan_id' ||
        ' and md.sr_instance_id = :p_inst_id' ||
        ' and md.organization_id =:p_org_id '||
        ' and md.inventory_item_id = :p_item_id' ||
        ' and trunc(md.using_assembly_demand_date) BETWEEN '''||
            p_start_date||''' AND '''|| p_end_date|| '''';

     END IF; --  IF p_org_id = -1 then

  END IF; -- IF p_rowtype in (CURRENT, SO_CURRENT) THEN

     IF p_rowtype in (ORIGINAL, CURRENT, FCST_SUBS_IN, FCST_SUBS_OUT)  THEN
          -- Forecast
        sql_stmt := sql_stmt ||
           ' and md.origination_type in (7, 29) ';
     ELSIF p_rowtype <> CONSUMED then  -- Sales Order won't have consume row
        sql_stmt := sql_stmt ||
           ' and md.origination_type in (6,30) ';
     END IF;

      sql_stmt := sql_stmt || l_ship_stmt;
/*
dbms_output.put_line(substr(sql_stmt,1,240));
dbms_output.put_line(substr(sql_stmt,241,240));
dbms_output.put_line(substr(sql_stmt,481,240));
dbms_output.put_line(substr(sql_stmt,721,240));
*/

IF  p_rowtype = CONSUMED THEN
    sql_stmt2 := sql_stmt;
    sql_stmt := sql_stmt || ' and mfu.sales_order_id = md.demand_id ';
END IF;

IF p_rowtype in (ORIGINAL, SO_ORIGINAL) THEN

       EXECUTE IMMEDIATE sql_stmt using p_query_id,p_plan_id,p_inst_id,
                                        p_org_id,p_item_id,p_item_id;
ELSE
       EXECUTE IMMEDIATE sql_stmt using p_query_id,p_plan_id,p_inst_id,
                                        p_org_id,p_item_id;
END IF;

IF  p_rowtype = CONSUMED THEN
    sql_stmt := sql_stmt2 ||
                ' and mfu.sales_order_id = md.original_demand_id ';
    EXECUTE IMMEDIATE sql_stmt using p_query_id,p_plan_id,p_inst_id,
                                        p_org_id,p_item_id;
END IF;


exception when others then
   null;
END get_detail_records;

FUNCTION get_ship_to(p_ship_to_level number,
                     p_plan_id number,
                     p_sales_order_id number) return varchar2 IS

   CURSOR ship_to_c IS
     select to_char(md.customer_id),
            to_char(md.customer_site_id),
            to_char(md.zone_id)
      from msc_demands md
     where plan_id = p_plan_id
       and demand_id = p_sales_order_id;

   v_customer varchar2(100);
   v_customer_site varchar2(100);
   v_zone varchar2(100);
BEGIN

   OPEN ship_to_c;
   FETCH ship_to_c INTO v_customer, v_customer_site, v_zone;
   CLOSE ship_to_c;

   if p_ship_to_level = 4 then
      return nvl(v_customer, '-99');
   elsif p_ship_to_level = 7 then
      return nvl(v_customer_site, '-99');
   elsif p_ship_to_level = 8 then
      return nvl(v_zone, '-99');
   elsif p_ship_to_level = 9 then
      if v_zone is not null then
         return v_customer||':'||v_zone;
      else
         return '-99';
      end if;
   end if;

   return  '-1';
END get_ship_to;

END MSC_GLOBAL_FORECASTING;

/
