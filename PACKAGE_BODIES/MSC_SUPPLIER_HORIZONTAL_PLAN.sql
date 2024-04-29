--------------------------------------------------------
--  DDL for Package Body MSC_SUPPLIER_HORIZONTAL_PLAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_SUPPLIER_HORIZONTAL_PLAN" AS
/*  $Header: MSCHSPLB.pls 120.9.12010000.2 2009/10/01 09:03:33 vkkandul ship $ */

SYS_YES         CONSTANT INTEGER := 1;
SYS_NO          CONSTANT INTEGER := 2;

NUM_OF_TYPES        CONSTANT INTEGER := 10;

PURCHASE_ORDER      CONSTANT INTEGER := 1;
PURCHASE_REQ        CONSTANT INTEGER := 2;
PLANNED_ORDER       CONSTANT INTEGER := 3;
REQUIRED_HOURS      CONSTANT INTEGER := 4;
AVAILABLE_HOURS     CONSTANT INTEGER := 5;
NET_AVAILABLE       CONSTANT INTEGER := 6;
CUM_AVAILABLE       CONSTANT INTEGER := 7;
UTILIZATION         CONSTANT INTEGER := 8;
CUM_UTILIZATION     CONSTANT INTEGER := 9;
PO_CONSUMPTION      CONSTANT INTEGER := 10;

M_PLANNED_ORDER     CONSTANT INTEGER := 5;
M_PURCHASE_ORDER    CONSTANT INTEGER := 1;
M_PURCHASE_REQ      CONSTANT INTEGER := 2;
M_PLANNED_ARRIVAL   CONSTANT INTEGER := 51;

PROMISE_DATE        CONSTANT INTEGER := 1;

TYPE calendar_date IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE column_number IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE column_char IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
TYPE supplier_activity IS RECORD
    (inventory_item_id NUMBER,
     supplier_id       NUMBER,
     supplier_site_id  NUMBER,
     type              NUMBER,
     start_date        DATE,
     end_date          DATE,
     quantity          NUMBER);

g_bucket_count      NUMBER := 2;
g_num_of_buckets    NUMBER;
g_item_list_id      NUMBER;
g_query_id      NUMBER;
g_org_id        NUMBER;
g_inst_id        NUMBER;
g_plan_start_date   DATE;
g_plan_end_date     DATE;
g_bucket_date       DATE;
g_cutoff_date       DATE;
g_designator        NUMBER;
g_bucket_type       NUMBER;
g_error_stmt        VARCHAR2(50);

g_plan_type number := 2;

g_use_sup_req number :=0;--5449978

g_dates             calendar_date;
bucket_cells        column_number;
activity_rec        supplier_activity;
l_dock_date_prof    number := nvl(FND_PROFILE.Value('MSC_PO_DOCK_DATE_CALC_PREF'),1);


--5220804bugfix, msc_supplier_requirements table added to snapshot to get consumption date

CURSOR supplier_snapshot_activity IS
-- ===================================
-- Supplier Availability
-- ===================================
  SELECT DISTINCT
    list.number8,
    cap.supplier_id,
    cap.supplier_site_id,
    AVAILABLE_HOURS,
    cal.calendar_date,
    null,
    cap.capacity
  FROM
    msc_trading_partners mtp,
    msc_calendar_dates cal,
    msc_supplier_capacities cap,
    msc_item_suppliers items,
    msc_form_query list
  WHERE
        cap.supplier_id = list.number2
  AND   NVL(cap.supplier_site_id,-1) = NVL(list.number5,-1)
  AND   cap.plan_id = g_designator
  AND   cap.inventory_item_id = list.number8
  AND   cap.capacity > 0
  AND   items.plan_id = cap.plan_id
  AND   items.sr_instance_id = g_inst_id
  AND   items.supplier_id = cap.supplier_id
  AND   items.inventory_item_id = cap.inventory_item_id
  AND   nvl(items.supplier_site_id, -1) =  NVL(list.number5,-1)
  AND   cal.calendar_date BETWEEN trunc(cap.from_date) AND trunc(nvl(cap.to_date,g_cutoff_date))
  AND   cal.calendar_date >= decode(g_plan_type, 4, trunc(g_plan_start_date+2), nvl(trunc(items.supplier_lead_time_date+1),trunc(g_plan_start_date+2)))
  AND   cal.calendar_date <= trunc(g_cutoff_date)
  AND   (((items.delivery_calendar_code is not null and cal.seq_num IS NOT NULL)
         or (items.delivery_calendar_code is null and  g_plan_type <> 4))
         or (g_plan_type = 4 and cal.seq_num is not null ))
  AND   mtp.sr_tp_id = g_org_id
  AND   mtp.sr_instance_id = g_inst_id
  AND   cal.calendar_code = nvl(items.delivery_calendar_code,mtp.calendar_code)
  AND   cal.exception_set_id = mtp.calendar_exception_set_id
  AND   cal.sr_instance_id = mtp.sr_instance_id
  AND   list.query_id = g_item_list_id
UNION ALL
-- ============================================
-- Supplier Requirements
-- ============================================
  SELECT
    list.number8,
    DECODE(mr.order_type,M_PLANNED_ORDER,mr.source_supplier_id,
        M_PLANNED_ARRIVAL, mr.source_supplier_id,
        mr.supplier_id),
    DECODE(mr.order_type,M_PLANNED_ORDER,mr.source_supplier_site_id,
        M_PLANNED_ARRIVAL, mr.source_supplier_site_id,
        mr.supplier_site_id),
    decode(mr.order_type,
        M_PLANNED_ORDER, PLANNED_ORDER,
        M_PLANNED_ARRIVAL, PLANNED_ORDER,
        M_PURCHASE_ORDER, PURCHASE_ORDER,
        M_PURCHASE_REQ, PURCHASE_REQ),
    decode(g_use_sup_req,
            0,mr.new_dock_date,
            1,msr.consumption_date),
    null,
   decode(g_use_sup_req,
                    0,  sum(mr.new_order_quantity),
                    1,  sum(msr.consumed_quantity)
         )
  FROM  msc_form_query list,
        msc_supplies mr,
        msc_supplier_requirements msr,
        msc_trading_partner_sites mtp
  WHERE mr.order_type in (M_PLANNED_ORDER, M_PURCHASE_ORDER, M_PURCHASE_REQ, M_PLANNED_ARRIVAL)
  AND   mr.disposition_status_type <> 2
  AND   decode(mtp.shipping_control,'BUYER',mr.new_ship_date,mr.new_dock_date) <= trunc(g_cutoff_date)
  AND   decode(mtp.shipping_control,'BUYER',mr.new_ship_date,mr.new_dock_date) >= trunc(g_plan_start_date+1)
  AND   mr.plan_id = g_designator
  AND   DECODE(mr.order_type,M_PLANNED_ORDER,mr.source_supplier_id,
                M_PLANNED_ARRIVAL,mr.source_supplier_id,
		mr.supplier_id) = list.number2
  AND   DECODE(mr.order_type,
                M_PLANNED_ORDER,NVL(mr.source_supplier_site_id,-1),
                M_PLANNED_ARRIVAL,NVL(mr.source_supplier_site_id,-1),
		NVL(mr.supplier_site_id,-1)) = NVL(list.number5,-1)
  AND   mr.inventory_item_id = list.number1
  AND   list.query_id = g_item_list_id
  AND   mtp.partner_site_id =
          DECODE(mr.order_type,M_PLANNED_ORDER,mr.source_supplier_site_id,
                               M_PLANNED_ARRIVAL,mr.source_supplier_site_id,
          mr.supplier_site_id)
  AND mr.plan_id = msr.plan_id(+)
  AND mr.sr_instance_id = msr.sr_instance_id(+)
  AND mr.transaction_id = msr.supply_id(+)
  GROUP BY list.number8,
           DECODE(mr.order_type,M_PLANNED_ORDER,mr.source_supplier_id,
                  M_PLANNED_ARRIVAL, mr.source_supplier_id,
                  mr.supplier_id),
           DECODE(mr.order_type,M_PLANNED_ORDER,mr.source_supplier_site_id,
                  M_PLANNED_ARRIVAL, mr.source_supplier_site_id,
                  mr.supplier_site_id),
           DECODE(mr.order_type,
                  M_PLANNED_ORDER, PLANNED_ORDER,
                  M_PLANNED_ARRIVAL, PLANNED_ORDER,
                  M_PURCHASE_ORDER, PURCHASE_ORDER,
                  M_PURCHASE_REQ, PURCHASE_REQ),
           DECODE(g_use_sup_req,
                  0,mr.new_dock_date,
                  1,msr.consumption_date)
/*
UNION ALL
-- ============================================
-- Purchase Orders Consumption
-- ============================================
  SELECT
    list.number8,
	mr.supplier_id,
	mr.supplier_site_id,
    PO_CONSUMPTION,
    mr.new_dock_date,
    null,
    to_number(
    decode ( mr.order_type,
             M_PURCHASE_ORDER, decode ( l_dock_date_prof,
                                        PROMISE_DATE, decode ( mr.promised_date,
                                                               NULL, mr.new_order_quantity,
                                                               0),
                                        0 ),
             0)) po_consumption_quantity
  FROM  msc_form_query list,
    msc_supplies mr,
        msc_trading_partner_sites mtp
  WHERE mr.order_type = M_PURCHASE_ORDER
  AND   mr.disposition_status_type <> 2
  AND   decode(mtp.shipping_control,'BUYER',mr.new_ship_date,mr.new_dock_date)  <= trunc(g_cutoff_date)
  AND   decode(mtp.shipping_control,'BUYER',mr.new_ship_date,mr.new_dock_date) >= trunc(g_plan_start_date+1)
  AND   mr.plan_id = g_designator
  AND   mr.supplier_id = list.number2
  AND   NVL(mr.supplier_site_id,-1) = NVL(list.number5,-1)
  AND   mr.inventory_item_id = list.number1
  AND   list.query_id = g_item_list_id
  AND   mtp.partner_site_id = mr.supplier_site_id
*/
UNION ALL
  SELECT
    list.number8,
    list.number2,
    list.number5,
    AVAILABLE_HOURS,
    g_plan_start_date,
    null,
    0
  FROM msc_form_query list
  WHERE list.query_id = g_item_list_id
ORDER BY 1,2,3,5,4;

-- =============================================================================
-- Name: initialize
-- Desc: initializes most of the global variables in the package
--       g_date() - is the structure that holds the beginning of each bucket
-- =============================================================================
PROCEDURE initialize IS
  -- -----------------------------------------
  -- This cursor selects row type information.
  -- -----------------------------------------
  v_sid         NUMBER;
  v_counter     NUMBER;

  CURSOR plan_buckets IS
  SELECT DECODE(g_designator, -1, trunc(sysdate), trunc(curr_start_date)) - 1,
         DECODE(g_designator, -1, trunc(sysdate+365), trunc(curr_cutoff_date))
  FROM msc_plans
  WHERE plan_id = g_designator;

  CURSOR bucket_dates(p_start_date DATE, p_end_date DATE) IS
  SELECT cal.calendar_date
  FROM msc_trading_partners tp,
       msc_calendar_dates cal
  WHERE tp.sr_tp_id = g_org_id
   AND tp.sr_instance_id = g_inst_id
   AND tp.calendar_exception_set_id = cal.exception_set_id
   AND tp.partner_type = 3
   AND tp.calendar_code = cal.calendar_code
   AND tp.sr_instance_id = cal.sr_instance_id
   AND cal.calendar_date BETWEEN p_start_date AND p_end_date
  ORDER BY cal.calendar_date;

  l_bucket_date         DATE;
  l_bucket_number       NUMBER := 0;

BEGIN

  -- --------------------------
  -- initialize query id
  -- --------------------------
  g_error_stmt := 'Debug - initialize - 10';
  SELECT msc_supplier_plans_s.nextval
  INTO   g_query_id
  FROM   dual;

  -- --------------------------------------------------------
  -- Start and End date of plan, find total number of buckets
  -- --------------------------------------------------------
  g_error_stmt := 'Debug - initialize - 20';
  OPEN plan_buckets;
  FETCH plan_buckets into g_plan_start_date, g_plan_end_date;
  CLOSE plan_buckets;

  g_num_of_buckets := (g_plan_end_date + 1) - g_plan_start_date;


  -- --------------------
  -- Get the bucket dates
  -- --------------------
  g_error_stmt := 'Debug - initialize - 30';
  OPEN bucket_dates(g_plan_start_date, g_plan_end_date+1);
  LOOP
    FETCH bucket_dates INTO l_bucket_date;
    EXIT WHEN BUCKET_DATES%NOTFOUND;
    l_bucket_number := l_bucket_number + 1;
    g_dates(l_bucket_number) := l_bucket_date;
  END LOOP;
  CLOSE bucket_dates;

  -- ----------------------------------
  -- Initialize the bucket cells to 0.
  -- ----------------------------------
  g_error_stmt := 'Debug - initialize - 50';
  FOR v_counter IN 1..(NUM_OF_TYPES * g_num_of_buckets) LOOP
    bucket_cells(v_counter) := 0;
  END LOOP;

  g_error_stmt := 'Debug - initialize - 80';

END initialize;

-- =============================================================================
-- Name: add_to_plan
-- Desc: adds 'quantity' to the correct type and correct bucket cell.
--   If the end_date of the record is populated, then the qty is assumed
--       to have daily rather than total qty. We calculate # of workdays in each
--   bucket in the range of start_date-end_date, and populate each
--   bucket accordingly
-- =============================================================================
PROCEDURE add_to_plan IS
  v_location        NUMBER;
  v_bucket_start    DATE;
  v_counter     NUMBER;
  v_bucket_size     NUMBER;
  v_res_cost        NUMBER := 0;
BEGIN

  g_error_stmt := 'Debug - add_to_plan - 10';
  IF (activity_rec.start_date >= g_dates(g_bucket_count)) THEN
    -- -------------------------------------------------------
    -- We got an activity which falls after the current bucket. So we
    -- will move the bucket counter forward until we find the
    -- bucket where this activity falls.  Note that we should
    -- not advance the counter beyond g_num_of_buckets.
    -- --------------------------------------------------------
    WHILE ((activity_rec.start_date >= g_dates(g_bucket_count)) AND
       (g_bucket_count <= g_num_of_buckets))
    LOOP
      g_bucket_count := g_bucket_count + 1;
    END LOOP;

    ---------------------------------------------------------------
    --- If the activity start date is outside the last bucket there
    --- is no need to add this activity to any bucket.
    ---------------------------------------------------------------
    if(activity_rec.start_date >= g_dates(g_bucket_count)) THEN
        return;
    end if;

  END IF;


  IF (activity_rec.end_date is null) THEN
    -- -------------------------------------------------------
    -- end date is null,  we assume that the quantity
    -- stands for total quantity and we dump the total
    -- quantity on the first bucket
    -- --------------------------------------------------------
    g_error_stmt := 'Debug - add_to_plan - 20';
    v_location := ((activity_rec.type-1) * g_num_of_buckets) +
        g_bucket_count - 1;
    bucket_cells(v_location) := bucket_cells(v_location) +
        activity_rec.quantity;
  END IF;

END add_to_plan;



-- =============================================================================
-- Name: calculate_cum
-- Desc: Some types of data need to be calculated or cumulated across dates. This
--       procedure takes care of that
-- =============================================================================
PROCEDURE calculate_cum IS

  v_loop        BINARY_INTEGER := 1;
  v_cum_net_available   NUMBER := 0;
  v_cum_available   NUMBER := 0;
  v_cum_required    NUMBER := 0;
BEGIN

  -- ---------------------------------
  -- The following will be calculated:
  --  REQUIRED_HOURS
  --  NET_AVAILABLE
  --  CUM_AVAILABLE
  --  UTILIZATION
  --  CUM_UTILIZATION
  -- -----------------------------
  v_cum_available   := 0;
  v_cum_required    := 0;

  g_error_stmt := 'Debug - calculate_cum - 10';
  FOR v_loop IN 1..g_num_of_buckets LOOP
    -- -------------------
    -- Required Hours
    -- -------------------
    g_error_stmt := 'Debug - calculate_cum - 20 - loop'||to_char(v_loop);
    bucket_cells((REQUIRED_HOURS-1)*g_num_of_buckets+v_loop) :=
        bucket_cells((PLANNED_ORDER-1)*g_num_of_buckets+v_loop) +
        -- bucket_cells((PO_CONSUMPTION-1)*g_num_of_buckets+v_loop) +
        bucket_cells((PURCHASE_ORDER-1)*g_num_of_buckets+v_loop) +
        bucket_cells((PURCHASE_REQ-1)*g_num_of_buckets+v_loop);

    -- -------------------
    -- Net Available Hours
    -- -------------------
    g_error_stmt := 'Debug - calculate_cum - 30 - loop'||to_char(v_loop);
    bucket_cells((NET_AVAILABLE-1)*g_num_of_buckets+v_loop) :=
        bucket_cells((AVAILABLE_HOURS-1)*g_num_of_buckets+v_loop) -
        bucket_cells((REQUIRED_HOURS-1)*g_num_of_buckets+v_loop);

    -- ----------------------------
    -- Cumulatitive Available Hours
    -- ----------------------------
    v_cum_net_available := v_cum_net_available +
        bucket_cells((NET_AVAILABLE-1)*g_num_of_buckets+v_loop);
    bucket_cells((CUM_AVAILABLE-1)*g_num_of_buckets+v_loop) := v_cum_net_available;

    -- ----------------------------
    -- Capacity Utilization
    -- ----------------------------
    g_error_stmt := 'Debug - calculate_cum - 40 - loop'||to_char(v_loop);
    IF (bucket_cells((AVAILABLE_HOURS-1)*g_num_of_buckets+v_loop) <= 0) THEN
      bucket_cells((UTILIZATION-1)*g_num_of_buckets+v_loop) := NULL;
    ELSE
      bucket_cells((UTILIZATION-1)*g_num_of_buckets+v_loop) := 100 *
        bucket_cells((REQUIRED_HOURS-1)*g_num_of_buckets+v_loop) /
        bucket_cells((AVAILABLE_HOURS-1)*g_num_of_buckets+v_loop);
    END IF;

    -- ----------------------------
    -- Cum Capacity Utilization
    -- ----------------------------
    g_error_stmt := 'Debug - calculate_cum - 50 - loop'||to_char(v_loop);
    v_cum_required  := v_cum_required +
                     bucket_cells((REQUIRED_HOURS-1)*g_num_of_buckets+v_loop);
    v_cum_available := v_cum_available +
                     bucket_cells((AVAILABLE_HOURS-1)*g_num_of_buckets+v_loop);

    IF (v_cum_available <= 0) THEN
      bucket_cells((CUM_UTILIZATION-1)*g_num_of_buckets+v_loop) := NULL;
    ELSE
      bucket_cells((CUM_UTILIZATION-1)*g_num_of_buckets+v_loop) := 100 *
        v_cum_required / v_cum_available;
    END IF;

  END LOOP;

END calculate_cum;




-- =============================================================================
-- Name: flush_crp_plan
-- Desc: It inserts the date for 1 dept/res or line into CRP_CAPACITY_PLANS
-- =============================================================================
PROCEDURE flush_crp_plan(
        p_item_id       NUMBER,
        p_sup_id        NUMBER,
        p_sup_site_id   NUMBER) IS
  v_loop        BINARY_INTEGER := 1;
  v_supplier_name VARCHAR2(100);
  v_item_name     VARCHAR2(250);

  TYPE bkt_data_rec IS RECORD(
       qty1 column_number,
       qty2 column_number,
       qty3 column_number,
       qty4 column_number,
       qty5 column_number,
       qty6 column_number,
       qty7 column_number,
       qty8 column_number,
       qty9 column_number);

  bkt_data bkt_data_rec;

BEGIN

  g_error_stmt := 'Debug - flush_crp_plan - 5';
  SELECT partner_name
  INTO   v_supplier_name
  FROM   msc_trading_partners
  WHERE  partner_id = p_sup_id;

  SELECT item_name
  INTO   v_item_name
  FROM   msc_items
  WHERE  inventory_item_id = p_item_id;


  g_error_stmt := 'Debug - flush_crp_plan - 10';

  FOR bkt IN 1..g_num_of_buckets LOOP
      bkt_data.qty1(bkt) :=
         bucket_cells(bkt+g_num_of_buckets*0);
      bkt_data.qty2(bkt) :=
         bucket_cells(bkt+g_num_of_buckets*1);
      bkt_data.qty3(bkt) :=
         bucket_cells(bkt+g_num_of_buckets*2);
      bkt_data.qty4(bkt) :=
         bucket_cells(bkt+g_num_of_buckets*3);
      bkt_data.qty5(bkt) :=
         bucket_cells(bkt+g_num_of_buckets*4);
      bkt_data.qty6(bkt) :=
         bucket_cells(bkt+g_num_of_buckets*5);
      bkt_data.qty7(bkt) :=
         bucket_cells(bkt+g_num_of_buckets*6);
      bkt_data.qty8(bkt) :=
         bucket_cells(bkt+g_num_of_buckets*7);
      bkt_data.qty9(bkt) :=
         bucket_cells(bkt+g_num_of_buckets*8);
  END LOOP;

  FORALL bkt in 1..nvl(bkt_data.qty1.last,0)
    INSERT INTO msc_supplier_plans(
    query_id,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login,
    organization_id,
    sr_instance_id,
    supplier_id,
    supplier_site_id,
    inventory_item_id,
    supplier_name,
    item_name,
    bucket_type,
    bucket_date,
    quantity1,    quantity2,    quantity3,    quantity4,
    quantity5,    quantity6,    quantity7,    quantity8,
    quantity9)
    VALUES (
    g_query_id,
    SYSDATE,
    -1,
    SYSDATE,
    -1,
    -1,
    NULL,
    NULL,
    p_sup_id,
    p_sup_site_id,
    p_item_id,
    v_supplier_name,
    v_item_name,
    g_bucket_type,
    g_dates(bkt),
    bkt_data.qty1(bkt),
    bkt_data.qty2(bkt),
    bkt_data.qty3(bkt),
    bkt_data.qty4(bkt),
    bkt_data.qty5(bkt),
    bkt_data.qty6(bkt),
    bkt_data.qty7(bkt),
    bkt_data.qty8(bkt),
    bkt_data.qty9(bkt));

END flush_crp_plan;


-- =============================================================================
-- Name: re_initialize
-- Desc: This is called everytime we work on a new dept/resource
--       Initializes cost information as well as calendar code
-- =============================================================================
PROCEDURE re_initialize IS
v_overhead      NUMBER;
BEGIN

      g_bucket_count := 2;

      g_error_stmt := 'Debug - re_initialize - 10';
      -- ----------------------------------
      -- Initialize the bucket cells to 0.
      -- dbms_output.put_line(g_error_stmt);
      -- ----------------------------------
      FOR v_cnt IN 1..NUM_OF_TYPES*g_num_of_buckets LOOP
      bucket_cells(v_cnt) := 0;
      END LOOP;

      g_error_stmt := 'Debug - re_initialize - 20';

END re_initialize;




-- =============================================================================
-- Name:populate_horizontal_plan
-- This is the main procedure. It retrieves data from database and calls
-- private procedures to summarize them into user defined buckets.
-- The argument p_current_data tells us whether to use current data
-- or snapshoted data for bucketing.
-- The p_bucket_type tells us what kind of buckets to use for summarization.
--  p_bucket_type   1   -   ??daily buckets??
--          2   -   ??weekly buckets??
--          3   -   ??periodic buckets??
--  p_current_data  1   -   Use current data
--          2   -   Use snapshot data
--
-- =============================================================================
FUNCTION populate_horizontal_plan(
            p_item_list_id      IN NUMBER,
            p_org_id        IN NUMBER,
            p_inst_id        IN NUMBER,
            p_plan_id    IN NUMBER,
            p_bucket_type       IN NUMBER,
            p_cutoff_date       IN DATE,
            p_current_data      IN NUMBER DEFAULT 2) RETURN NUMBER IS
  v_no_rows         BOOLEAN;
  v_last_sup_id        NUMBER := -2;
  v_last_sup_site_id   NUMBER := -2;
  v_last_item_id         NUMBER := -2;
  v_cnt             NUMBER;


   CURSOR get_plan_type(p_plan_id NUMBER) IS
    select plan_type,
     decode(enforce_sup_cap_constraints,1,1,0),
     decode(daily_material_constraints,1, 1, 0) --ascp_supplier_constraints
    from   msc_plans
   where  plan_id = p_plan_id;

l_constraints number:=0;
l_enforce_sup_cap_constraints number:=0;
l_val varchar2(2000);
BEGIN
/*
dbms_output.put_line(p_org_id||','||
            p_inst_id        ||','||
            p_plan_id    ||','||
            p_bucket_type       ||','||
            p_cutoff_date       ||','||
            p_current_data);
*/
  -- ----------------------------
  -- Initialize Global variables
  -- ----------------------------
  g_error_stmt := 'Debug - populate_horizontal_plan - 10';
  g_item_list_id := p_item_list_id;
  g_org_id := p_org_id;
  g_inst_id := p_inst_id;
  g_designator :=p_plan_id;
  g_bucket_type := p_bucket_type;
  g_cutoff_date := p_cutoff_date;

  initialize;
   --dbms_output.put_line(g_error_stmt);

--bug5449978
  OPEN  get_plan_type(p_plan_id);
  FETCH get_plan_type INTO g_plan_type, l_enforce_sup_cap_constraints, l_constraints;
  CLOSE get_plan_type;

--bug5449978--if plan is drp or unconstrained ascp or any plan where enforce_supplier capacity constraints is off, fallback to msc_supplies
--BUG5609299--modified previous fix so that we use msc_supplies for unconstrained DRP or unconstrained ASCP plans.
    if (g_plan_type=5) or (g_plan_type=1 and l_constraints=0)  then
        g_use_sup_req:=0; -- do not use msc_supplier_requirements
    else
        g_use_sup_req:=1; -- use msc_supplier_requirements
    end if;

  g_error_stmt := 'Debug - populate_horizontal_plan - 20';
  -- dbms_output.put_line(g_error_stmt);

  OPEN supplier_snapshot_activity;

  -- ----------------------------
  -- Fetch rows from cursor
  -- and process them one by one
  -- ----------------------------
  LOOP
    v_no_rows := FALSE;
    g_error_stmt := 'Debug - populate_horizontal_plan - 30';
    -- dbms_output.put_line(g_error_stmt);

    FETCH supplier_snapshot_activity INTO activity_rec;
    IF (supplier_snapshot_activity%NOTFOUND) THEN
      v_no_rows := TRUE;
    END IF;
--dbms_output.put_line(activity_rec.inventory_item_id||','||activity_rec.supplier_id||','||activity_rec.type||','||activity_rec.start_date||','||activity_rec.quantity);
    g_error_stmt := 'Debug - populate_horizontal_plan - 40';
    -- dbms_output.put_line(g_error_stmt);
    IF ((v_no_rows OR
     v_last_item_id <> activity_rec.inventory_item_id OR
     v_last_sup_id <> activity_rec.supplier_id OR
     v_last_sup_site_id <> activity_rec.supplier_site_id) AND
    v_last_sup_id <> -2) THEN
      -- ==================================================
      -- snapshoting for the last dept/res has finished
      -- We therefore calculate cumulative information,
      -- flush the previous set of data and then
      -- re-initialized for the current dept/res
      -- ==================================================
      g_error_stmt := 'Debug - populate_horizontal_plan - 50';
      calculate_cum;

      g_error_stmt := 'Debug - populate_horizontal_plan - 60';
      flush_crp_plan(v_last_item_id,v_last_sup_id, v_last_sup_site_id);

      g_error_stmt := 'Debug - populate_horizontal_plan - 70';
      re_initialize;
    END IF;

    EXIT WHEN v_no_rows;

    g_error_stmt := 'Debug - populate_horizontal_plan - 85';
    -- ---------------------------------------------------------
    -- Add the retrieved activity to the plan
    -- dbms_output.put_line(g_error_stmt);
    -- ---------------------------------------------------------
    add_to_plan;

    v_last_item_id := activity_rec.inventory_item_id;
    v_last_sup_id := activity_rec.supplier_id;
    v_last_sup_site_id := activity_rec.supplier_site_id;
  END LOOP;

  g_error_stmt := 'Debug - populate_horizontal_plan - 90';
  -- dbms_output.put_line(g_error_stmt);
  CLOSE supplier_snapshot_activity;

  return g_query_id;

EXCEPTION WHEN others THEN
  -- dbms_output.put_line(g_error_stmt);
  IF (supplier_snapshot_activity%ISOPEN) THEN
    close supplier_snapshot_activity;
  END IF;
  raise;
END populate_horizontal_plan;

PROCEDURE query_list(p_query_id IN NUMBER,
                p_plan_id IN NUMBER,
                p_item_list IN VARCHAR2,
                p_org_list IN VARCHAR2,
                p_supplier_list IN VARCHAR2,
                p_supplier_site_list IN VARCHAR2) IS

  sql_stmt      VARCHAR2(4000);
  sql_stmt1      VARCHAR2(4000);
  orig_stmt      VARCHAR2(4000);

  l_supplier_site  VARCHAR2(1000);
  NODE_ITEM_SUPPLIER CONSTANT NUMBER := 1;
  a                    number :=0;
  startPos             number;
  endPos               number;
  p_item_id            column_number;
  p_supplier_id        column_number;
  l_base_item          NUMBER;
  v_item_id            NUMBER;
  l_len                NUMBER;

    cursor   base_item  is
    select   decode(bom_item_type,  4, NVL(base_item_id, inventory_item_id),
                                       inventory_item_id  )
    from     msc_system_items
    where    plan_id = p_plan_id
    and      inventory_item_id = v_item_id;

    cursor   config_list (p_base_item NUMBER,
                          l_supplier_id NUMBER)is
    select   distinct i.inventory_item_id
    from     msc_system_items i,
             msc_item_suppliers s
    where    i.base_item_id  = p_base_item
    and      i.plan_id = p_plan_id
    and      i.bom_item_type = 4
    and      i.inventory_item_id = s.inventory_item_id
    and      i.plan_id          = s.plan_id
    and      i.sr_instance_id   = s.sr_instance_id
    and      i.organization_id  = s.organization_id
    and      s.supplier_id      = l_supplier_id;

    cursor   base_Model_exists( p_base_item NUMBER) is
    select   1
    from     msc_form_query
    where    number8 = p_base_item
    and      query_id = p_query_id;

    model_exists NUMBER:= 2;
    l_item_list VARCHAR2(5000);
    l_config    VARCHAR2(80);

 debug_item   NUMBER;
 debug_count  NUMBER;

 l_order_date_type VARCHAR2(10) := '';

BEGIN

  IF p_supplier_site_list IS NULL THEN
    l_supplier_site := '-1';
  ELSE
    l_supplier_site := p_supplier_site_list;
  END IF;

  -- Need to  go  one by one through all items.
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


  a :=1;
  startPos :=1;
  endPos := instr(p_supplier_list||','  ,   ','  ,1,a);
  while endPos >0 loop
           l_len := endPos - startPos;
        p_supplier_id(a) :=
              to_number(substr(p_supplier_list||',',startPos, l_len));

        a := a+1;
        startPos := endPos+1;
        endPos := instr(p_supplier_list||',', ',',1,a);
  end loop;


    sql_stmt1 := 'INSERT INTO msc_form_query ( '||
        'query_id, '||
        'last_update_date, '||
        'last_updated_by, '||
        'creation_date, '||
        'created_by, '||
        'last_update_login, '||
        'number1, '|| -- store for standards - inv_item_id, for ato -model_id
        'number2, '||
        'number5, '||
        'number7, '||
        'number8, '|| -- store inv_item_id
        'char1, '||
        'char2) '||
  ' SELECT distinct
        '|| p_query_id || ', '||
        'sysdate, '||
        '1, '||
        'sysdate, '||
        '1, '||
        '1, ';

FOR a in 1..p_item_id.count LOOP
  v_item_id := p_item_id(a);
  OPEN  base_item;
  FETCH base_item INTO l_base_item;
  CLOSE base_item;

    IF  a > 1 THEN

   -- when I go through the loop for the second + times
   -- I need to make sure that we do not insert records
   -- for configs of the same models
   -- Let us say on the tree we have
   -- Supplier A
       -- Model 1
       -- Config M11
       -- Config M12
       -- Model 2
       -- Config M21
       -- Config M22
   -- when a = 2   (Config M11) , I do not need to insert any records
   -- since I have already inserted the whole list of all configs
   -- for Model 1 at a = 1

    open base_Model_exists(l_base_item);
    fetch base_Model_exists INTO model_exists;
    close base_Model_exists;

   end if;

 if  model_exists = 1 THEN
      null; -- do not insert anything in msc_form_query
 else

     -- This cursor will get  me the list of all config/preconfigs which
     -- have l_base_item as a base_item_id

   l_item_list := '';
 FOR a in 1..p_supplier_id.count LOOP
   OPEN config_list(l_base_item, p_supplier_id(a));
    LOOP
        FETCH config_list INTO l_config;
        EXIT WHEN config_list%NOTFOUND;
        l_item_list := l_config|| ', '||l_item_list;
    END LOOP;
   CLOSE config_list;
 END LOOP;

   IF  l_item_list is not NULL THEN
   l_item_list := l_item_list || l_base_item;
   ELSE
   l_item_list := to_char(l_base_item);
   END IF;


  sql_stmt :=   sql_stmt1 ||
               'inventory_item_id, '||
               'supplier_id, '||
               'supplier_site_id, '||
                NODE_ITEM_SUPPLIER ||' , ' ||
                l_base_item||  -- base_ato in case of config
--               ',msc_get_name.supplier(supplier_id) || msc_supplier_horizontal_plan.get_order_type_label('||l_supplier_site || '), '||
               ',msc_get_name.supplier(supplier_id) || msc_supplier_horizontal_plan.get_order_type_label(supplier_site_id ), '||
               'msc_get_name.item_name(' ||l_base_item|| ' ,null,null,null) '||
               'FROM msc_item_suppliers '||
               'WHERE inventory_item_id in ('||l_item_list||') ' ||
               'AND supplier_id in ('||p_supplier_list||') ' ||
--               'AND NVL(supplier_site_id,-1) in ('||l_supplier_site||') ' ||
               'and using_organization_id = -1 AND plan_id = '||p_plan_id;

  orig_stmt := sql_stmt;

  IF (p_org_list IS NOT NULL ) THEN
   sql_stmt := sql_stmt ||
              ' AND (sr_instance_id,organization_id) in ('||p_org_list||') ' ;
  END IF;

  IF l_supplier_site <> '-2' then
   sql_stmt := sql_stmt ||
           'AND NVL(supplier_site_id,-1) in ('||l_supplier_site||') ' ;
  END IF;
/*
dbms_output.put_line(substr(sql_stmt,1,240));
dbms_output.put_line(substr(sql_stmt,241,240));
dbms_output.put_line(substr(sql_stmt,481,240));
dbms_output.put_line(substr(sql_stmt,721,240));
*/
  EXECUTE IMMEDIATE sql_stmt;

  if SQL%ROWCOUNT =0 then
     EXECUTE IMMEDIATE orig_stmt;
  end if;

 model_exists := 2;
 end if; -- if model_exists

END loop;


END query_list;

FUNCTION get_order_type_label (p_supplier_site_id NUMBER)
	RETURN VARCHAR2 is

   l_supplier_site_label	VARCHAR2(240);
   l_shipping_control    mfg_lookups.meaning%Type;

   CURSOR SUPPLIER_SITE_LABEL_C(p_supplier_site_id NUMBER) IS
   select meaning,tp_site_code
   from   msc_trading_partner_sites,mfg_lookups
   where  partner_site_id=p_supplier_site_id
   and    lookup_type = 'MSC_ORDER_DATE_TYPE'
   and    lookup_code = decode(shipping_control,'BUYER',1,2);

BEGIN
	OPEN SUPPLIER_SITE_LABEL_C(p_supplier_site_id);
	FETCH SUPPLIER_SITE_LABEL_C into
	l_shipping_control,l_supplier_site_label;
	CLOSE SUPPLIER_SITE_LABEL_C;
	FND_MESSAGE.set_name('MSC','MSC_Order_date_type');
	return  '('||FND_MESSAGE.get||': '||l_shipping_control||')';
END;

END msc_supplier_horizontal_plan;

/
