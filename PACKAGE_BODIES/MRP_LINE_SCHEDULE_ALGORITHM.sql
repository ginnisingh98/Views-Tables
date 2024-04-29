--------------------------------------------------------
--  DDL for Package Body MRP_LINE_SCHEDULE_ALGORITHM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_LINE_SCHEDULE_ALGORITHM" AS
/* $Header: MRPLSCHB.pls 120.1.12010000.4 2009/12/02 06:48:46 adasa ship $ */

-- Global Variable to hold min wip_entity Id
  G_WIP_ENTITY_ID NUMBER;

-- This cursor is a list of unique items in the flow schedules to be scheduled on
-- the specified line.

  CURSOR item_list (p_org_id NUMBER) IS
    SELECT DISTINCT primary_item_id
    FROM   wip_flow_schedules
    WHERE  request_id = USERENV('SESSIONID')
      AND  organization_id = p_org_id
      AND wip_entity_id >= G_WIP_ENTITY_ID;

-- This cursor is a list of unique schedule groups in the flow schedules to be
-- scheduled on the specified line.

  CURSOR schedule_group_list (p_org_id NUMBER) IS
    SELECT DISTINCT schedule_group_id schedule_group
    FROM   wip_flow_schedules
    WHERE  request_id = USERENV('SESSIONID')
      AND  organization_id = p_org_id
      AND wip_entity_id >= G_WIP_ENTITY_ID;

/* Fix for bug 2977987: Added columns primary_item_id, bom_revision_date
   and routing_revision_date to be selected by the sursor. */
  CURSOR fs_list (p_line_id NUMBER, p_org_id NUMBER) IS
    SELECT wip_entity_id, schedule_group_id, scheduled_completion_date,
           primary_item_id, bom_revision_date, routing_revision_date
    FROM   wip_flow_schedules
    WHERE  request_id = USERENV('SESSIONID')
      AND  line_id = p_line_id
      AND  organization_id = p_org_id
      AND  scheduled_flag = C_YES
      AND  wip_entity_id >= G_WIP_ENTITY_ID
    ORDER BY scheduled_completion_date;

-- This cursor is used in the level daily rate algorithm.  It retrieves the items
-- to be scheduled, ordered in descending order the fraction from calculation of
-- the production plan for each item.  This is used for rounding.

  CURSOR production_round (p_date NUMBER, p_query_id IN NUMBER) IS
    SELECT number1, number2,number3
    FROM   mrp_form_query
    WHERE  date1 = to_date(p_date,'J')
    AND    query_id = p_query_id
    ORDER BY number3 DESC;

-- This cursor is a list of existing flow schedules ordered by schedule group
-- and build sequence so that time stamps can be assigned to them.
-- hwenas: query never used, so decided to not change for bug#3783650
  CURSOR flow_schedule_list (p_line_id NUMBER, p_org_id NUMBER, p_date NUMBER)
  IS
    SELECT  wip_entity_id,planned_quantity,quantity_completed,
	    schedule_group_id,build_sequence,primary_item_id
    FROM    wip_flow_schedules
    WHERE   to_number(to_char(scheduled_completion_date,'J'))
		= p_date
      AND   line_id = p_line_id
      AND   organization_id = p_org_id
      AND   scheduled_flag = C_YES
    ORDER BY schedule_group_id,build_sequence;

-- This procedure constructs the main select cursor and returns
-- a handle to the calling functions

FUNCTION Create_Cursor( p_rule_id IN NUMBER,
			p_org_id IN NUMBER,
		        p_line_id IN NUMBER,
			p_order IN NUMBER,
			p_type IN NUMBER,
			p_item_id IN NUMBER)
RETURN INTEGER
IS
  v_select 		VARCHAR2(5000);
  dummy                 INTEGER;
  cursor_name           INTEGER;
  v_seq_criteria	VARCHAR2(500);
  fs_select_rec	        fs_select_type;

BEGIN
  V_PROCEDURE_NAME := 'Create_Cursor';
  V_ERROR_LINE := 1;

  v_seq_criteria := order_scheduling_rule(p_rule_id, p_order);

  v_select := 'SELECT '||
         ' fs.wip_entity_id wip_entity, '||
	 ' sol.creation_date creation_date, '||
        ' NVL(sol.schedule_ship_date,fs.scheduled_completion_date) schedule_date,'||
         ' sol.promise_date promise_date, '||
         ' sol.request_date request_date, '||
         ' sol.planning_priority planning_priority, '||
         ' fs.primary_item_id primary_item_id, '||
	 ' fs.planned_quantity planned_quantity, '||
	 ' fs.schedule_group_id schedule_group_id '||
  ' FROM   oe_order_lines_all sol,wip_flow_schedules fs  '||
  ' WHERE  fs.request_id = :v_session_id '||
    ' AND  fs.organization_id = :p_org_id '||
    ' AND  fs.line_id = :p_line_id '||
    ' AND  sol.line_id(+) = fs.demand_source_line '||
    ' AND  fs.scheduled_flag = 3 '||
    ' AND  :p_item_id > 0 ';

  IF p_type <> C_NORM THEN
    v_select := v_select || ' AND fs.primary_item_id = :p_item_id ';
  END IF;

  v_select := v_select || ' ORDER BY '|| v_seq_criteria;

  cursor_name := dbms_sql.open_cursor;
  dbms_sql.parse(cursor_name, v_select, dbms_sql.v7);
  dbms_sql.bind_variable(cursor_name, ':v_session_id', USERENV('SESSIONID'));
  dbms_sql.bind_variable(cursor_name, ':p_org_id', p_org_id);
  dbms_sql.bind_variable(cursor_name, ':p_line_id', p_line_id);
  dbms_sql.bind_variable(cursor_name, ':p_item_id', p_item_id);

  dbms_sql.define_column(cursor_name,1, fs_select_rec.wip_entity);
  dbms_sql.define_column(cursor_name,2, fs_select_rec.creation_date);
  dbms_sql.define_column(cursor_name,3, fs_select_rec.schedule_date);
  dbms_sql.define_column(cursor_name,4, fs_select_rec.promise_date);
  dbms_sql.define_column(cursor_name,5, fs_select_rec.request_date);
  dbms_sql.define_column(cursor_name,6, fs_select_rec.planning_priority);
  dbms_sql.define_column(cursor_name,7, fs_select_rec.primary_item_id);
  dbms_sql.define_column(cursor_name,8, fs_select_rec.planned_quantity);
  dbms_sql.define_column(cursor_name,9, fs_select_rec.schedule_group_id);
  dummy := dbms_sql.execute(cursor_name);

  return(cursor_name);

EXCEPTION
  WHEN OTHERS THEN
    IF (dbms_sql.is_open(cursor_name)) THEN
      dbms_sql.close_cursor(cursor_name);
    END IF;

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(
	V_PKG_NAME,V_PROCEDURE_NAME||': Line '||to_char(V_ERROR_LINE));
    END IF;

    RETURN NULL;
END Create_Cursor;

FUNCTION get_flex_tolerance( p_org_id IN NUMBER,
                             p_line_id IN NUMBER,
                             p_date IN NUMBER) RETURN NUMBER
IS
  v_days_out NUMBER;
  v_fence_days NUMBER;
  v_tol_percent NUMBER;
BEGIN

  v_days_out := mrp_calendar.DAYS_BETWEEN(p_org_id,1,sysdate,to_date(p_date,'J'));

  select nvl(max(FENCE_DAYS),-1)
  into v_fence_days
  from bom_resource_flex_fences
  where fence_days <= v_days_out
    and department_id = p_line_id;

  if v_fence_days > -1 then
    select max(tolerance_percentage)
    into v_tol_percent
    from bom_resource_flex_fences
    where fence_days = v_fence_days
      and department_id = p_line_id;
  else
    return 0;
  end if;

  return ( v_tol_percent/100);
END get_flex_tolerance;


-- This procedure calculates the daily net available capacity on the line
-- by subtracting the line rate by the capacity used by existing work orders.

PROCEDURE calculate_linecap(
				p_line_id IN NUMBER,
				p_org_id IN NUMBER,
				p_flex_tolerance IN NUMBER,
                                p_cap_tab IN OUT NOCOPY CapTabTyp,
                                p_time_tab IN TimeTabTyp,
                                p_schedule_start_date IN NUMBER,
                                p_schedule_start_time IN NUMBER,
                                p_schedule_end_date IN NUMBER,
                                p_schedule_end_time IN NUMBER
)
IS

  v_cal_code	VARCHAR2(10);
  v_excep_code	NUMBER;
  v_line_rate 	NUMBER;
  v_sum_dj	NUMBER;
  v_sum_fs	NUMBER;
  v_sum_rs	NUMBER;
  v_date	DATE;
  v_capacity    NUMBER;
  v_hr_rate	NUMBER;
  v_line_start_time	NUMBER;
  v_line_stop_time 	NUMBER;
  v_start_time	NUMBER;
  v_stop_time 	NUMBER;
  v_current_date NUMBER;
  v_current_date2 NUMBER;
  v_qty_to_sched NUMBER;
  v_add_capacity NUMBER;
  v_adj_add_capacity NUMBER;
  v_flex_tol NUMBER;
  v_line_rate_cur NUMBER;
  v_line_rate_new NUMBER;

  v_current_date_in_client00 DATE;  --fix bug#3783650

BEGIN

  V_PROCEDURE_NAME := 'calculate_linecap';
  V_ERROR_LINE := 1;

  SELECT calendar_code,calendar_exception_set_id
  INTO   v_cal_code,v_excep_code
  FROM   mtl_parameters
  WHERE  organization_id = p_org_id;

  V_ERROR_LINE := 2;

  -- For each work day, loop through all the dates and initialize the capacity to the
  -- line rate. Calculate the sum of all existing work orders, discrete jobs,
  -- repetitive schedules, and flow schedules and decrement the sum from the line rate
  -- for each day.

  -- Fix bug 939061, add 24 hrs to stop_time if stop_time <= start_time
  SELECT maximum_rate, start_time, stop_time
  INTO   v_hr_rate, v_line_start_time, v_line_stop_time
  FROM   wip_lines
  WHERE  line_id = p_line_id
  AND    organization_id = p_org_id;

  if (v_line_stop_time <= v_line_start_time) then
    v_line_stop_time := v_line_stop_time + 24*3600;
  end if;

  v_line_rate := v_hr_rate * (v_line_stop_time - v_line_start_time)/3600;

  V_ERROR_LINE := 3;

  -- Get total_quantity to be scheduled
  select sum(planned_quantity)
  into v_qty_to_sched
  from wip_flow_schedules
  where request_id = USERENV('SESSIONID')
    and line_id = p_line_id
    and organization_id = p_org_id
    and scheduled_flag = C_NO
    and wip_entity_id >= G_WIP_ENTITY_ID;

  v_current_date := p_time_tab.FIRST;

  LOOP

    p_cap_tab(v_current_date).capacity := v_line_rate;

    --fix bug#3783650
    v_date := to_date(v_current_date,'J');
    v_current_date_in_client00 := flm_timezone.client00_in_server(v_date+(v_line_start_time/86400));
    --end of fix bug#3783650

    SELECT NVL(SUM(NVL(start_quantity,0)
		- NVL(quantity_completed,0)
                - NVL(quantity_scrapped,0)),0)
    INTO   v_sum_dj
    FROM   wip_discrete_jobs
    WHERE  line_id = p_line_id
    AND    organization_id = p_org_id
    --fix bug#3783650
    --AND    to_number(to_char(scheduled_completion_date,'J'))
    --       = v_current_date;
    AND    scheduled_completion_date BETWEEN v_current_date_in_client00
    AND    v_current_date_in_client00+1-(1/86400);
    --end of fix bug#3783650

    V_ERROR_LINE := 4;

    --fix bug#3783650: move up    v_date := to_date(v_current_date,'J');

    IF (v_sum_dj > 0) THEN

      p_cap_tab(v_current_date).capacity :=
		p_cap_tab(v_current_date).capacity - v_sum_dj;
    END IF;

    SELECT NVL(SUM(NVL(planned_quantity,0)
                -NVL(quantity_completed,0)),0)
    INTO   v_sum_fs
    FROM   wip_flow_schedules
    WHERE  line_id = p_line_id
    AND    organization_id = p_org_id
    --fix bug#3783650
    --AND    to_number(to_char(scheduled_completion_date,'J'))
    -- 	     = v_current_date
    AND    scheduled_completion_date BETWEEN v_current_date_in_client00
    AND    v_current_date_in_client00+1-(1/86400)
    AND    scheduled_flag = C_YES;
    --end of fix bug#3783650

    V_ERROR_LINE := 5;

    IF (v_sum_fs > 0) THEN

      p_cap_tab(v_current_date).capacity :=
	 	p_cap_tab(v_current_date).capacity - v_sum_fs;

    END IF;

    SELECT NVL(SUM(NVL(MRP_HORIZONTAL_PLAN_SC.compute_daily_rate_t(
		v_cal_code,
		v_excep_code,
		wip_repetitive_schedules.daily_production_rate,
		wip_repetitive_schedules.quantity_completed,
		wip_repetitive_schedules.first_unit_completion_date,
		to_date(v_current_date,'J')),0)),0)
    INTO   v_sum_rs
    FROM   wip_repetitive_schedules
    WHERE  line_id = p_line_id
    AND    organization_id = p_org_id
    --fix bug#3783650
    --AND    v_current_date BETWEEN
    --       to_number(to_char(first_unit_completion_date,'J'))
    --AND to_number(to_char(last_unit_completion_date,'J'));
    AND    v_current_date_in_client00 BETWEEN
 		flm_timezone.client00_in_server(first_unit_completion_date)
    AND flm_timezone.client00_in_server(last_unit_completion_date+1)-1/86400;
    --end of fix bug#3783650

    V_ERROR_LINE := 6;

    IF (v_sum_rs > 0) THEN

      p_cap_tab(v_current_date).capacity :=
      p_cap_tab(v_current_date).capacity - v_sum_rs;

    END IF;

    v_capacity := v_hr_rate * (p_time_tab(v_current_date).end_completion_time -
                  p_time_tab(v_current_date).start_completion_time) / 3600;
    -- if v_capacity < 0 means that schedule_end_time is less than line start time
    if (v_capacity < 0) then
      v_capacity := 0;
    end if;
    if (v_capacity < p_cap_tab(v_current_date).capacity) then
      p_cap_tab(v_current_date).capacity := v_capacity;
    end if;

    -- The capacity left in the line will be used  to fulfill the quantity to
    -- be scheduled. Thus, we reduce the quantity to be scheduled with the
    -- capacity left in the line.
    if (v_qty_to_sched > 0) then
      v_qty_to_sched := v_qty_to_sched -
                        p_cap_tab(v_current_date).capacity;
    end if;

    exit when p_time_tab.LAST = v_current_date;
    v_current_date := p_time_tab.NEXT(v_current_date);
  END LOOP;

  -- This variable hold the additional capacity that can be used.
  -- It's the different between previous line rate and current line rate.
  v_add_capacity := 0;

  -- If there is quantity to be scheduled, it means that the system can't
  -- schedule all quantity using the capacity defined for that line.
  -- Then it will use flex tolerances if any, to increase the line capacity
  -- that will be used to schedule the remaining quantity.
  -- The line capacity will be increased in steps. It will use the
  -- flex tolerance starting from the start schedule date to the
  -- end schedule date. Using the tolerance from day X (which start from
  -- start schedule date to end schedule date), it will increase the
  -- line capacity from day X till end schedule date. At any point, it
  -- will exit, if the capacity is enough for scheduling the remaining
  -- quantity. Then it will use the flex tolerance from day X+1 to
  -- increase the line capacity from day X+1 till end schedule date.
  -- Remember that this capacity increase should be the increment from
  -- the previous capacity increase. e.g : in day X. the flex tolerance = 10
  -- , and in day X+1, the flex tolerance = 15, the capacity increase
  -- in day X+1 must be 5 (15-10).

  if (p_flex_tolerance = 1 and v_qty_to_sched > 0) then

    -- Start the loop to get the day from schedule start date to
    -- schedule end date.
    v_current_date := p_cap_tab.FIRST;
    v_line_rate_cur := v_line_rate;

    loop

      -- Get the flex tolerance for a given day
      v_flex_tol := get_flex_tolerance(p_org_id, p_line_id, v_current_date);
      v_line_rate_new := round(v_line_rate * (1+v_flex_tol));

      -- The additional capacity that can be added to the line is the
      -- increment between previous line rate (v_line_rate_cur) and
      -- the new line rate v_line_rate_new
      v_add_capacity := v_line_rate_new - v_line_rate_cur;

      -- Set the current line rate to the new line rate
      v_line_rate_cur := v_line_rate_new;

      v_current_date2 := v_current_date;

      loop
        -- Adjust the additional capacity with over capacity on the current schedule.
        if (p_cap_tab(v_current_date2).capacity < 0) then
          v_adj_add_capacity := v_add_capacity + p_cap_tab(v_current_date2).capacity;
        else
          v_adj_add_capacity := v_add_capacity;
        end if;

        v_start_time := v_line_start_time;
        v_stop_time := v_line_stop_time;
        if (v_current_date2 = p_schedule_start_date and p_schedule_start_time > v_start_time) then
          v_start_time := p_schedule_start_time;
        elsif (v_current_date2 = p_schedule_end_date and p_schedule_end_time < v_stop_time) then
          v_stop_time := p_schedule_end_time;
        end if;

        -- To adjust the capacity based on the user defined schedule start and end time.
        v_adj_add_capacity := round((v_stop_time-v_start_time)/
                              (v_line_stop_time-v_line_start_time)*v_adj_add_capacity);

        if (v_adj_add_capacity > 0) then
          -- If all the remaning quantity can be fulfill by the addition
          -- of the capacity, increase line capacity on that day with the
          -- remaning quantity. Then we complete.
          -- Otherwise, increase the line capacity with the additional
          -- capacity. Also need to decrease the quantity to be scheduled with
          -- additional capacity, because some portion of that quantity can
          -- be fulfilled with this additional capacity
          if (v_qty_to_sched <= v_adj_add_capacity) then
            p_cap_tab(v_current_date2).capacity := p_cap_tab(v_current_date2).capacity + v_qty_to_sched;
            return;
          else
            p_cap_tab(v_current_date2).capacity := p_cap_tab(v_current_date2).capacity + v_adj_add_capacity;
            v_qty_to_sched := v_qty_to_sched - v_adj_add_capacity;
          end if;
        end if;
        exit when v_current_date2 = p_cap_tab.LAST;
        v_current_date2 := p_cap_tab.NEXT(v_current_date2);
      end loop;

      exit when v_current_date = p_cap_tab.LAST;
      v_current_date := p_cap_tab.NEXT(v_current_date);

    end loop;

  end if;

  -- Set the capacity to 0 for any negative value on the capacity
  v_current_date := p_cap_tab.FIRST;
  loop
    if (p_cap_tab(v_current_date).capacity < 0) then
      p_cap_tab(v_current_date).capacity := 0;
    end if;
    exit when v_current_date = p_cap_tab.LAST;
    v_current_date := p_cap_tab.NEXT(v_current_date);
  end loop;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN;

  WHEN OTHERS THEN

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(
	V_PKG_NAME,V_PROCEDURE_NAME||': Line '||to_char(V_ERROR_LINE));
    END IF;

    return;

END calculate_linecap;

-- This function returns a string containing the sequencing criteria of a scheduling
-- rule, ordered by the priority of each criteria.

FUNCTION order_scheduling_rule(p_rule_id IN NUMBER,
			       p_order IN NUMBER) RETURN VARCHAR2
IS
  v_ordered_criteria 	VARCHAR2(500);
  v_source_type	 	NUMBER;
  i			NUMBER;

  CURSOR criteria_select IS
    SELECT usage_code
    FROM mrp_scheduling_rules
    WHERE rule_id = p_rule_id
    AND   NVL(user_defined,C_USER_DEFINE_NO) = C_USER_DEFINE_NO
    ORDER BY sequence_number;

BEGIN
  V_PROCEDURE_NAME := 'order_scheduling_rule';
  V_ERROR_LINE := 1;

  -- Determine if flow schedules originate from sales orders or planned orders
  SELECT demand_source_type
  INTO   v_source_type
  FROM   wip_flow_schedules
  WHERE  request_id = USERENV('SESSIONID')
    AND  scheduled_flag = C_NO
    AND  rownum = 1
    AND  wip_entity_id >= G_WIP_ENTITY_ID;

  V_ERROR_LINE := 2;

  IF v_source_type = C_PLANNED_ORDER THEN
    v_ordered_criteria := 'fs.scheduled_completion_date';

    RETURN(v_ordered_criteria);

  ELSIF v_source_type IN (C_EXT_SALES_ORDER, C_INT_SALES_ORDER) THEN

    v_ordered_criteria := NULL;

    i := 1;

    FOR criteria_select_rec IN criteria_select LOOP

      IF i > 1 THEN
        v_ordered_criteria := v_ordered_criteria ||',';
      END IF;

      IF criteria_select_rec.usage_code = 1 THEN
        v_ordered_criteria := v_ordered_criteria || 'sol.request_date';

      ELSIF criteria_select_rec.usage_code = 2 THEN
        v_ordered_criteria := v_ordered_criteria || 'sol.schedule_ship_date';

      ELSIF criteria_select_rec.usage_code = 3 THEN
        v_ordered_criteria := v_ordered_criteria || 'sol.promise_date';

      ELSIF criteria_select_rec.usage_code = 4 THEN
        v_ordered_criteria := v_ordered_criteria || 'sol.creation_date';

      ELSIF criteria_select_rec.usage_code = 5 THEN
        v_ordered_criteria := v_ordered_criteria || 'sol.planning_priority';

      ELSIF criteria_select_rec.usage_code = 7 THEN
        v_ordered_criteria := v_ordered_criteria || 'sol.cust_production_seq_num';

      ELSIF criteria_select_rec.usage_code = 8 THEN
        v_ordered_criteria := v_ordered_criteria || 'sol.cust_production_seq_num desc';

      END IF;

      IF p_order = C_DESC THEN
	v_ordered_criteria := v_ordered_criteria || ' DESC';
      END IF;

      i := i + 1;

    END LOOP;

    IF v_ordered_criteria IS NULL THEN
      v_ordered_criteria := 'fs.scheduled_completion_date';
    END IF;
    RETURN(v_ordered_criteria);

  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN(NULL);

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(
	V_PKG_NAME,V_PROCEDURE_NAME||': Line '||to_char(V_ERROR_LINE));
    END IF;

  return(NULL);

END order_scheduling_rule;

-- This procedure takes each item that has unscheduled flow schedules on the
-- line and calculates the acceptable order quantities depending on the order
-- modifiers associated with the item.

PROCEDURE calculate_order_quantities(
					p_org_id  IN NUMBER,
					p_order_mod_tab IN OUT NOCOPY OrderModTabTyp)
IS
  v_fixed_qty	   NUMBER;
  v_lot_multiple   NUMBER;
  v_min_qty	   NUMBER;
  v_max_qty	   NUMBER;

BEGIN

  V_PROCEDURE_NAME := 'Calculate_Order_Quantities';
  V_ERROR_LINE := 1;

  -- From the order modifiers for each item, find out what order quantities can be
  -- used.  The order modifier columns are fixed_order_qty, fixed_lot_multiplier,
  -- min_qty, and max_qty.

  -- The calculated order quantities are stored in a pl/sql table.

  FOR item_list_rec IN item_list(p_org_id) LOOP

    SELECT NVL(fixed_order_quantity,0), NVL(fixed_lot_multiplier,0),
           NVL(minimum_order_quantity,0), NVL(maximum_order_quantity,0)
    INTO   v_fixed_qty, v_lot_multiple, v_min_qty, v_max_qty
    FROM   mtl_system_items
    WHERE  inventory_item_id = item_list_rec.primary_item_id
      AND  organization_id = p_org_id;

    V_ERROR_LINE := 2;

    -- If fixed order quantity exists for the item, then that will simply be
    -- the order quantity

    IF v_fixed_qty > 0 THEN

      p_order_mod_tab(item_list_rec.primary_item_id).minVal := v_fixed_qty;
      p_order_mod_tab(item_list_rec.primary_item_id).maxVal := v_fixed_qty;

    -- If the fixed order quantity does not exist for the item, and the fixed lot
    -- multiplier exists, make sure that the fixed lot multiple quantity is between
    -- the minimum and maximum values.

    ELSIF v_lot_multiple > 0 THEN

      IF (v_lot_multiple >= v_min_qty AND (v_lot_multiple <= v_max_qty OR v_max_qty = 0
      /*Bugfix:8531808.Added OR condition to consider case where minimum order quantity       is not null and maximum order quantity is null */)) OR
	(v_min_qty = 0 AND v_max_qty = 0) THEN

	p_order_mod_tab(item_list_rec.primary_item_id).minVal := v_lot_multiple;
	p_order_mod_tab(item_list_rec.primary_item_id).maxVal := v_lot_multiple;

      ELSIF v_lot_multiple < v_min_qty THEN
        p_order_mod_tab(item_list_rec.primary_item_id).minVal := v_min_qty;
        p_order_mod_tab(item_list_rec.primary_item_id).maxVal := v_min_qty;

      ELSIF v_lot_multiple > v_max_qty THEN
        p_order_mod_tab(item_list_rec.primary_item_id).minVal := v_max_qty;
        p_order_mod_tab(item_list_rec.primary_item_id).maxVal := v_max_qty;
      END IF;

    -- If only the minimum and maximum order quantities exist, both values
    -- will be stored.  However, at this point, we will only consider the
    -- minimum value.  In the future, we need to figure out a way to consider
    -- the maximum value so that order quantities can take different values as
    -- long as they fall within the minimum and maximum values.

    ELSIF (v_min_qty > 0) AND (v_max_qty > 0) THEN
      	  p_order_mod_tab(item_list_rec.primary_item_id).minVal := v_min_qty;
	  p_order_mod_tab(item_list_rec.primary_item_id).maxVal := v_max_qty;

    -- If only the minimum or maximum order quantity is defined:

    ELSIF (v_min_qty > 0) THEN
      p_order_mod_tab(item_list_rec.primary_item_id).minVal := v_min_qty;
      p_order_mod_tab(item_list_rec.primary_item_id).maxVal := v_min_qty;

    ELSIF (v_max_qty > 0) THEN
      p_order_mod_tab(item_list_rec.primary_item_id).minVal := v_max_qty;
      p_order_mod_tab(item_list_rec.primary_item_id).maxVal := v_max_qty;

    -- If there are no order modifier values, then no order modifier constraints exist.
    ELSE
      p_order_mod_tab(item_list_rec.primary_item_id).minVal := 0;
      p_order_mod_tab(item_list_rec.primary_item_id).maxVal := 0;
    END IF;

  END LOOP;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN;

  WHEN OTHERS THEN

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(
	V_PKG_NAME,V_PROCEDURE_NAME||': Line '||to_char(V_ERROR_LINE));
    END IF;

    return;

END calculate_order_quantities;

-- This procedure obtains the highest build sequence for each schedule group and
-- populates that information in a pl/sql table.

PROCEDURE calculate_build_sequences (
				p_org_id  IN NUMBER,
				p_line_id IN NUMBER,
				p_build_seq_tab IN OUT NOCOPY BuildSeqTabTyp)
IS

v_null_build_seq NUMBER;

BEGIN

  V_PROCEDURE_NAME := 'Calculate_Build_Sequences';
  V_ERROR_LINE := 1;

  FOR schedule_group_rec IN schedule_group_list(p_org_id) LOOP

    IF schedule_group_rec.schedule_group IS NOT NULL THEN
      SELECT NVL(MAX(build_sequence),0)
      INTO   p_build_seq_tab(schedule_group_rec.schedule_group).buildseq
      FROM   wip_flow_schedules fs
      WHERE  fs.schedule_group_id = schedule_group_rec.schedule_group
        AND  fs.line_id = p_line_id
        AND  fs.organization_id = p_org_id
        AND  scheduled_flag = C_YES;

      V_ERROR_LINE := 2;

    ELSE

      SELECT NVL(MAX(build_sequence),0)
      INTO   v_null_build_seq
      FROM   wip_flow_schedules fs
      WHERE  fs.schedule_group_id IS NULL
	AND  fs.line_id = p_line_id
	AND  fs.organization_id = p_org_id
        AND  scheduled_flag = C_YES;

      V_ERROR_LINE := 3;

    END IF;
  END LOOP;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN;

  WHEN OTHERS THEN

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(
	V_PKG_NAME,V_PROCEDURE_NAME||': Line '||to_char(V_ERROR_LINE));
    END IF;

    return;

END calculate_build_sequences;

-- This procedure time stamps all existing flow schedules on the line for all valid
-- days within the scheduling window before scheduling new flow schedules on the line.

PROCEDURE time_existing_fs(
				p_org_id  IN NUMBER,
				p_line_id IN NUMBER,
                                p_schedule_start_date IN NUMBER,
                                p_schedule_start_time IN NUMBER,
                                p_schedule_end_date IN NUMBER,
                                p_schedule_end_time IN NUMBER,
				p_time_tab IN OUT NOCOPY TimeTabTyp)
IS

/* Performance fix for Bug No #2720049
Description : Changed the sql so that index on calendar_date could be used. */

  CURSOR valid_dates(l_cal_code IN VARCHAR2, l_excep_code IN NUMBER,
  l_schedule_start_date IN NUMBER, l_schedule_end_date IN NUMBER) IS
    SELECT to_number(to_char(bom_cal.calendar_date,'J')) workday
    FROM   bom_calendar_dates bom_cal
    WHERE  bom_cal.calendar_code = l_cal_code
    AND    bom_cal.exception_set_id = l_excep_code
    AND    bom_cal.calendar_date between to_date(l_schedule_start_date,'j') and
	   to_date(l_schedule_end_date,'j')
--  AND    to_number(to_char(bom_cal.calendar_date,'J'))
--               between l_schedule_start_date and l_schedule_end_date
    AND    bom_cal.seq_num is NOT NULL
    ORDER BY bom_cal.calendar_date;

  v_date		NUMBER;
  v_hr_line_rate	NUMBER;
  v_line_rate		NUMBER;
  v_start_time		NUMBER;
  v_end_time		NUMBER;
  v_required_time 	NUMBER;
  v_begin_time		DATE;
  v_completion_time	DATE;
  v_final_time		NUMBER;
  l_fixed_lead_time	NUMBER;
  l_variable_lead_time	NUMBER;
  l_lead_time		NUMBER;
  l_cal_code    VARCHAR2(10);
  l_excep_code  NUMBER;
  l_last_comp_time	NUMBER;
  l_last_comp_date	DATE;
  l_user_start_time	NUMBER;
  l_sec			NUMBER;
  l_schedule_start_time	NUMBER;
  l_schedule_start_date	NUMBER;

BEGIN

  V_PROCEDURE_NAME := 'Time_Existing_fs';
  V_ERROR_LINE := 1;

  l_schedule_start_date := p_schedule_start_date;
  l_schedule_start_time := p_schedule_start_time;

  -- Obtain information on the hourly line rate, start time and end time of the line.

  SELECT maximum_rate, start_time, stop_time
  INTO   v_hr_line_rate, v_start_time, v_end_time
  FROM   wip_lines
  WHERE  line_id = p_line_id
    AND  organization_id = p_org_id;

  V_ERROR_LINE := 2;

  -- The line rate per day is the hourly line rate multiplied by the number of hours
  -- in a day.

  -- Fix bug 939061, add 24 hrs to stop_time if stop_time <= start_time
  if (v_end_time <= v_start_time) then
    if (p_schedule_start_time < v_end_time ) then
      l_schedule_start_date := l_schedule_start_date - 1;
      l_schedule_start_time := l_schedule_start_time + 24*3600;
    end if;
    v_end_time := v_end_time + 24*3600;
  end if;

  SELECT calendar_code,calendar_exception_set_id
  INTO   l_cal_code,l_excep_code
  FROM   mtl_parameters
  WHERE  organization_id = p_org_id;

  FOR valid_dates_rec IN valid_dates(l_cal_code,l_excep_code,
        l_schedule_start_date,p_schedule_end_date) LOOP

    v_date := valid_dates_rec.workday;

    -- The value of v_end_time can be one of the following :
    -- 1. line_end_time if the date is not schedule end date
    -- 2. if the date is schedule end date :
    --    a. schedule_end_time if schedule_end_time in between line start and stop time
    --    b. line start time if schedule_end_time is smaller than line start time
    --    c. line end time if schedule_end_time is higher than line start time
    if (v_date = p_schedule_end_date) then
      if (p_schedule_end_time < v_end_time and p_schedule_end_time > v_start_time) then
        v_end_time := p_schedule_end_time;
      elsif (p_schedule_end_time < v_start_time) then
        v_end_time := v_start_time;
      end if;
    end if;
    v_line_rate := TRUNC(v_hr_line_rate * (v_end_time - v_start_time)/3600);

    SELECT max(scheduled_completion_date)
    INTO l_last_comp_date
    FROM wip_flow_schedules
    WHERE scheduled_completion_date >= to_date(v_date,'J')+v_start_time/86400
      AND scheduled_completion_date <= to_date(v_date,'J')+v_end_time/86400
      AND line_id = p_line_id
      AND organization_id = p_org_id
      AND scheduled_flag = C_YES;

    if (l_last_comp_date IS NOT NULL) then
      l_last_comp_time := to_char(l_last_comp_date,'SSSSS');
      if (trunc(l_last_comp_date) > to_date(v_date,'J')) then
        l_last_comp_time := l_last_comp_time + 24*3600;
      end if;
      if l_last_comp_time < v_start_time then
        l_last_comp_time := v_start_time;
      end if;
    else
      l_last_comp_time := v_start_time;
    end if;

    if (v_date = l_schedule_start_date) then
      if (l_schedule_start_time > v_end_time) then
        l_last_comp_time := v_end_time;
      elsif (l_schedule_start_time > l_last_comp_time) then
        l_sec := 3600/v_hr_line_rate; -- Time to produce 1 qty in seconds
        l_last_comp_time := v_start_time+
          ceil((l_schedule_start_time-v_start_time)/l_sec) * l_sec;
        l_last_comp_time := l_last_comp_time - l_sec;
      end if;
    end if;

    p_time_tab(v_date).start_completion_time := l_last_comp_time;
    p_time_tab(v_date).end_completion_time := v_end_time;

  END LOOP;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN;

  WHEN OTHERS THEN

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(
	V_PKG_NAME,V_PROCEDURE_NAME||': Line '||to_char(V_ERROR_LINE));
    END IF;

    return;
END time_existing_fs;

-- This procedure calculates the total demand for each item and populates these
-- values into the PL/SQL table.  The procedure also calculates the global demand
-- across all items and populates this value into the pl/sql table.  The table also
-- contains the round type of the item.

PROCEDURE calculate_demand(
				    p_line_id IN NUMBER,
				    p_org_id IN NUMBER,
				    p_demand_tab IN OUT NOCOPY DemandTabTyp)
IS

-- Define Variables and Cursors

  v_demand_total 	NUMBER;

BEGIN

  V_PROCEDURE_NAME := 'Calculate_Demand';
  V_ERROR_LINE := 1;

  -- Calculate total demand for each item and populate into PS/SQL table indexed
  -- by the item id.  Also, calculate the global demand across all items.

  v_demand_total := 0;

  FOR item_list_rec IN item_list(p_org_id) LOOP

    -- Find the round type of the item and populate into table.

    SELECT NVL(rounding_control_type,2)
    INTO   p_demand_tab(item_list_rec.primary_item_id).roundType
    FROM   mtl_system_items
    WHERE  inventory_item_id = item_list_rec.primary_item_id
    AND    organization_id = p_org_id;

    V_ERROR_LINE := 2;

    p_demand_tab(item_list_rec.primary_item_id).sequence := 0;

--   For each item, calculate the total demand from flow schedules to be scheduled.

    SELECT NVL(SUM(NVL(planned_quantity,0)
                -NVL(quantity_completed,0)),0)
    INTO   p_demand_tab(item_list_rec.primary_item_id).totalDemand
    FROM   wip_flow_schedules fs
    WHERE  fs.request_id = USERENV('SESSIONID')
      AND  fs.primary_item_id = item_list_rec.primary_item_id
      AND  fs.line_id = p_line_id
      AND  fs.organization_id = p_org_id
      AND  fs.scheduled_flag = C_NO
      AND  wip_entity_id >= G_WIP_ENTITY_ID;

    V_ERROR_LINE := 3;

    v_demand_total := v_demand_total +
	p_demand_tab(item_list_rec.primary_item_id).totalDemand;

  END LOOP;

  V_GLOBAL_DEMAND := v_demand_total;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN;
  WHEN OTHERS THEN

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(
	V_PKG_NAME,V_PROCEDURE_NAME||': Line '||to_char(V_ERROR_LINE));
    END IF;

END calculate_demand;

-- This procedure calculates the total demand for each item and populates this
-- information into a pl/sql table ordered by the value of the demand.

PROCEDURE calculate_demand_mix (
				    p_line_id IN NUMBER,
				    p_org_id IN NUMBER,
				    p_item_demand_tab IN OUT NOCOPY ItemDemandTabTyp)
IS

-- Define Variables and Cursors
  v_item_id	    	NUMBER;
  v_quantity		NUMBER;
  v_fixed_lead_time	NUMBER;
  v_var_lead_time	NUMBER;
  i			NUMBER;

  CURSOR item_demand_cursor IS
    SELECT primary_item_id, SUM(TRUNC(NVL(planned_quantity,0)
               -NVL(quantity_completed,0)-0.00000001)+1) quantity
    FROM   wip_flow_schedules fs
    WHERE  fs.request_id = USERENV('SESSIONID')
      AND  fs.line_id = p_line_id
      AND  fs.organization_id = p_org_id
      AND  fs.scheduled_flag = C_NO
      AND  wip_entity_id >= G_WIP_ENTITY_ID
    GROUP BY primary_item_id
    ORDER BY quantity;

BEGIN

  V_PROCEDURE_NAME := 'Calculate_Demand_Mix';
  V_ERROR_LINE := 1;

  -- Calculate total demand for each item and populate into PS/SQL table.
  -- Populate the item column and the demand column for the item.

  i := 1;

  OPEN item_demand_cursor;
  LOOP

    FETCH item_demand_cursor INTO v_item_id, v_quantity;
    EXIT WHEN item_demand_cursor%NOTFOUND;

    SELECT NVL(fixed_lead_time, 0), NVL(variable_lead_time, 0)
    INTO   v_fixed_lead_time, v_var_lead_time
    FROM   MTL_SYSTEM_ITEMS
    WHERE  inventory_item_id = v_item_id
    AND    organization_id = p_org_id;

    p_item_demand_tab(i).item := v_item_id;

    p_item_demand_tab(i).qty := v_quantity;

    p_item_demand_tab(i).fixed_lead_time := v_fixed_lead_time;

    p_item_demand_tab(i).var_lead_time := v_var_lead_time;

    i := i + 1;

  END LOOP;
  CLOSE item_demand_cursor;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN;
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(
	V_PKG_NAME,V_PROCEDURE_NAME||': Line '||to_char(V_ERROR_LINE));
    END IF;

END calculate_demand_mix;

-- This procedure establishes the manufacturing pattern for the mix model
-- scheduling algorithm.

FUNCTION mix_model (
			p_item_demand_tab IN ItemDemandTabTyp) RETURN LONG
IS

-- Define Variables and Cursors
  mmm_tab1  ItemDemandTabTyp;
  mmm_tab2  ItemDemandTabTyp;
  curr_total_pattern  long;
  final_total_pattern  long;
  tmp_total_pattern  long;
  num_pos Number := -1;
  new_num_pos Number;
  curr_pos Number;
  occur_num Number;
  curr_sub_cnt Number ;
  tmp_cnt Number;
  curr_qty Number;
  curr_ind_qty Number;
  curr_ind Number :=1;
  next_ind Number;

BEGIN

  V_PROCEDURE_NAME := 'mix_model';

  mmm_tab1 := p_item_demand_tab;

  FOR i in 1..mmm_tab1.COUNT Loop
    mmm_tab2(i).item := mmm_tab1(i).item;
--    dbms_output.put_line('The index is: '||to_char(i));
--    dbms_output.put_line('The item is: '||to_char(mmm_tab2(i).item));
    mmm_tab2(i).qty := mmm_tab1(i).qty;
--    dbms_output.put_line(mmm_tab2(i).qty);

  END LOOP;

/*  FOR i in 1..3 Loop
    mmm_tab2(i).item := i;
    mmm_tab2(i).qty := 10;
  END LOOP;
  mmm_tab2(4).item := 4;
    mmm_tab2(4).qty := 30;*/
  Loop
   declare
    curr_pat_tab pat_tab_type;
    curr_pattern  long;
    curr_sub_pattern  long;
   BEGIN
--      dbms_output.put_line('curr_pat_tab count: '||to_char(curr_pat_tab.COUNT));
--      dbms_output.put_line('curr_ind: '||to_char(curr_ind));
--      dbms_output.put_line('mmm_tab2 count: '||to_char(mmm_tab2.COUNT));
     curr_pattern := null;
     curr_sub_pattern := null;
     for i in REVERSE curr_ind..mmm_tab2.COUNT LOOP
       if (i <> curr_ind ) then
         curr_sub_pattern := curr_sub_pattern || to_char(i)|| '*';
       else
         curr_sub_pattern := curr_sub_pattern || to_char(i);
       end if;
     end loop;
--      dbms_output.put_line('curr_sub_pattern: '||curr_sub_pattern);
     if (num_pos = -1 ) then
        curr_pat_tab(1).curr_pattern := curr_sub_pattern;
        num_pos := 1;
        FOR i in 1..mmm_tab2(curr_ind).qty Loop
          curr_total_pattern := curr_total_pattern || '*-'||curr_sub_pattern ;
          num_pos := num_pos +1;
        end loop;
        curr_total_pattern := curr_total_pattern || '*-' ;
--        dbms_output.put_line('initial curr_total_pattern: '||curr_total_pattern);
--       dbms_output.put_line('initial num_pos: '||to_char(num_pos));
     else
--     dbms_output.put_line('curr_qty: '||to_char(mmm_tab2(curr_ind).qty));
        if (mmm_tab2(curr_ind).qty > num_pos) then

          curr_qty := mmm_tab2(curr_ind).qty;
          tmp_cnt := 1;
          Loop
           curr_sub_cnt := ceil(curr_qty / (num_pos-tmp_cnt+1));
--        dbms_output.put_line('i am here '||to_char(curr_sub_cnt));
           curr_pattern:=null;
           FOR i in 1..curr_sub_cnt Loop
              if (curr_pattern is null) then
                 curr_pattern := curr_sub_pattern;
              else
                 curr_pattern := curr_pattern ||'*'|| curr_sub_pattern;
              end if;
           end loop;
--        dbms_output.put_line('i am here curr_pattern '||curr_pattern);
           curr_pat_tab(tmp_cnt).curr_pattern := curr_pattern;
           curr_qty := curr_qty - curr_sub_cnt;
           exit when curr_qty <= 0;
           tmp_cnt := tmp_cnt +1;
          end Loop;
        elsif (mmm_tab2(curr_ind).qty < num_pos) then
         -- need to choose positions
           FOR i in 1..mmm_tab2(curr_ind).qty Loop
             curr_pat_tab(i).curr_pattern := curr_sub_pattern;
           end loop;
        else
           FOR i in 1..mmm_tab2(curr_ind).qty Loop
             curr_pat_tab(i).curr_pattern := curr_sub_pattern;
           end loop;
        end if;
       -- insert strings into positions
        occur_num := 1;
        new_num_pos := num_pos;
--      dbms_output.put_line('mid curr_pat_tab count: '||to_char(curr_pat_tab.COUNT));

        For i in 1..curr_pat_tab.COUNT Loop
          curr_pos := instr(curr_total_pattern,'-',1,occur_num);
--    dbms_output.put_line('in loop curr_pattern: '||curr_pat_tab(i).curr_pattern);
          curr_total_pattern := substr(curr_total_pattern,1,curr_pos) || curr_pat_tab(i).curr_pattern || '*'||substr(curr_total_pattern,curr_pos);
--    dbms_output.put_line('curr_total_pattern: '||curr_total_pattern);
--    dbms_output.put_line('tmp_total_pattern: '||tmp_total_pattern);
          new_num_pos := new_num_pos +1;
          num_pos := new_num_pos;
          occur_num := occur_num +2;
         /*  if (occur_num > num_pos) then
--            dbms_output.put_line('error condition ');
            exit;
          end if; */
        end Loop;
        -- curr_total_pattern := tmp_total_pattern;
--   dbms_output.put_line('final curr_total_pattern: '||curr_total_pattern);
        num_pos := new_num_pos;
--      dbms_output.put_line('new num_pos: '||to_char(num_pos));
        -- curr_pat_tab :=  NULL;
     end if;
--      dbms_output.put_line('i am here curr_pattern: '||curr_pattern);
     next_ind := null;
     curr_ind_qty := mmm_tab2(curr_ind).qty;
     For i in 1..mmm_tab2.COUNT Loop
--      dbms_output.put_line('i am here22 curr_pattern: '||curr_pattern);
       mmm_tab2(i).qty :=mmm_tab2(i).qty - curr_ind_qty;
       if (mmm_tab2(i).qty > 0 and next_ind is null) then
         next_ind := i;
       end if;
     end loop;
     exit when next_ind is null;
     curr_ind := next_ind;
--      dbms_output.put_line('next_ind: '||to_char(next_ind));
--      dbms_output.put_line(' ENDcurr_pat_tab count: '||to_char(curr_pat_tab.COUNT));
   END;
  END Loop;
  final_total_pattern := replace(curr_total_pattern,'-');
--  dbms_output.put_line('The pattern in mix model: '||final_total_pattern);

  tmp_cnt :=  ceil(length(curr_total_pattern) / 255);
--   for i in 1..tmp_cnt Loop
--    dbms_output.put_line(substr(curr_total_pattern,255*(i-1),255));
--  end loop;
--  dbms_output.put_line('length: '||to_char(length(curr_total_pattern)));
--  dbms_output.put_line('actual length: '||to_char(length(replace(replace(curr_total_pattern,'-'),'*'))));

--  dbms_output.put_line('FINAL PATTERN:');
--  tmp_cnt :=  ceil(length(final_total_pattern) / 255);
--  for i in 1..tmp_cnt Loop
--    dbms_output.put_line(substr(final_total_pattern,255*(i-1),255));
--  end loop;
--  dbms_output.put_line('The pattern in mix model: '||final_total_pattern);

  RETURN final_total_pattern;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
  WHEN OTHERS THEN

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(V_PKG_NAME, V_PROCEDURE_NAME);
    END IF;

END mix_model;

-- This procedure converts flow schedules of type planned order into new flow
-- schedules that respect the order modifiers of the items.  After the conversion,
-- the flow schedules can be scheduled on the line.

PROCEDURE create_po_fs(
				p_org_id  IN NUMBER,
				p_line_id IN NUMBER,
				p_rule_id IN NUMBER,
				p_orderMod_tab IN OUT NOCOPY OrderModTabTyp)

IS

  v_order_quantity	NUMBER;
  v_temp		NUMBER;
  v_num_flow		NUMBER;
  v_itemQty_tab		ItemQtyTabTyp;
  fs_select_rec	fs_select_type;
  cursor_name           INTEGER;
  v_last_wip		NUMBER;
  v_schedule_number	VARCHAR2(30);
  to_schedule_qty	NUMBER;
  v_planned_quantity	NUMBER;

BEGIN

  V_PROCEDURE_NAME := 'Create_Po_Fs';
  V_ERROR_LINE := 1;

  cursor_name := Create_Cursor(p_rule_id,p_org_id,p_line_id,C_ASC,C_NORM,C_NORM);

--  dbms_output.put_line('Looping through each planned order flow schedule
--  and creating new flow schedules with order modifier quantities.');

  LOOP
    if dbms_sql.fetch_rows(cursor_name) > 0 then
       dbms_sql.column_value(cursor_name,1, fs_select_rec.wip_entity);
       dbms_sql.column_value(cursor_name,7, fs_select_rec.primary_item_id);
       dbms_sql.column_value(cursor_name,8, fs_select_rec.planned_quantity);
       dbms_sql.column_value(cursor_name,9, fs_select_rec.schedule_group_id);
    end if;

    IF v_last_wip = fs_select_rec.wip_entity THEN
      EXIT;
    END IF;

    v_last_wip := fs_select_rec.wip_entity;

--    dbms_output.put_line('Current flow schedule is: '||
--    to_char(fs_select_rec.wip_entity));
--    dbms_output.put_line('Current item is: '||
--    to_char(fs_select_rec.primary_item_id));

    -- Check the item quantity table to see what the remaining quantity of the
    -- newest flow schedule is.  If the remaining quantity is greater than the
    -- quantity we are trying to schedule,then leave the flow schedule as is.

    -- If the remaining quantity is less than the quantity we need to
    -- schedule, then split the flow schedule into multiple flow schedules
    -- to correspond to the original flow schedule.
    -- Update the item quantity table.

    IF v_itemQty_tab.EXISTS(fs_select_rec.primary_item_id) = FALSE THEN
      v_itemQty_tab(fs_select_rec.primary_item_id).remainQty := 0;
    END IF;

--  dbms_output.put_line('Remain Qty in ItemQty table is '||to_char
--    (v_itemQty_tab(fs_select_rec.primary_item_id).remainQty));

--  dbms_output.put_line('Planned quantity is '||
--	to_char(fs_select_rec.planned_quantity));

    IF v_itemQty_tab(fs_select_rec.primary_item_id).remainQty >=
		fs_select_rec.planned_quantity THEN

      v_itemQty_tab(fs_select_rec.primary_item_id).remainQty :=
        v_itemQty_tab(fs_select_rec.primary_item_id).remainQty - fs_select_rec.planned_quantity;

--    dbms_output.put_line('Enough quantity remaining for allocation...');
--    dbms_output.put_line('Remaining quantity = '||
--	to_char(v_itemQty_tab(fs_select_rec.primary_item_id).remainQty));

    ELSIF v_itemQty_tab(fs_select_rec.primary_item_id).remainQty <
		fs_select_rec.planned_quantity THEN
--      dbms_output.put_line('NOT enough quantity remaining for allocation.');

      IF  p_orderMod_tab(fs_select_rec.primary_item_id).minVal = 0 AND
	p_orderMod_tab(fs_select_rec.primary_item_id).maxVal = 0 THEN

--	dbms_output.put_line('no meaningful values for min and max values!!');
--	dbms_output.put_line('Order quantity = planned quantity');

	v_order_quantity := fs_select_rec.planned_quantity;

      ELSIF p_orderMod_tab(fs_select_rec.primary_item_id).minVal > 0 THEN

--	dbms_output.put_line('minimum value exists and = order quantity!!');

	v_order_quantity := p_orderMod_tab(fs_select_rec.primary_item_id).minVal;

	-- We need to find a way to include the maximum in the future.
      END IF;

      V_ERROR_LINE := 2;

      SELECT TRUNC((fs_select_rec.planned_quantity -
		v_itemQty_tab(fs_select_rec.primary_item_id).remainQty)/
	v_order_quantity-0.000000001)+1
      INTO v_num_flow
      FROM DUAL;

      V_ERROR_LINE := 3;

      UPDATE wip_flow_schedules
      SET    planned_quantity =
		v_itemQty_tab(fs_select_rec.primary_item_id).remainQty
      WHERE  wip_entity_id = fs_select_rec.wip_entity
      AND    organization_id = p_org_id;

      V_ERROR_LINE := 4;

--      dbms_output.put_line('We need to create this number of new flow schedules:'
--	||v_num_flow);

      to_schedule_qty := fs_select_rec.planned_quantity -
	v_itemQty_tab(fs_select_rec.primary_item_id).remainQty;

      FOR i IN 1..v_num_flow LOOP

        -- Create a new flow schedule to carry over the unscheduled quantity
        SELECT wip_entities_s.nextval
        INTO   v_temp
        FROM   dual;

        V_ERROR_LINE := 5;

	IF to_schedule_qty >= v_order_quantity THEN
          v_planned_quantity := v_order_quantity;
 	ELSE
	  v_planned_quantity := to_schedule_qty;
  	END IF;

        --Bug 6122344
        --v_schedule_number := NVL(substr(FND_PROFILE.value('WIP_JOB_PREFIX'),1,20),'X')
	--		|| to_char(v_temp);
        v_schedule_number := 'FLM-INTERNAL'|| to_char(v_temp);

	INSERT INTO wip_flow_schedules(
				scheduled_flag,
				wip_entity_id,
				organization_id,
				last_update_date,
				last_updated_by,
				creation_date,
				created_by,
				class_code,
				line_id,
				primary_item_id,
				scheduled_start_date,
				planned_quantity,
				quantity_completed,
				quantity_scrapped,
				scheduled_completion_date,
				schedule_group_id,
				status,
				schedule_number,
				demand_source_header_id,
				demand_source_line,
				demand_source_delivery,
				demand_source_type,
				project_id,
				task_id,
				end_item_unit_number,
                                request_id,
                                attribute1,
                                attribute2,
                                attribute3,
                                attribute4,
                                attribute5,
                                attribute6,
                                attribute7,
                                attribute8,
                                attribute9,
                                attribute10,
                                attribute11,
                                attribute12,
                                attribute13,
                                attribute14,
                                attribute15,
                                material_account,
                                material_overhead_account,
                                resource_account,
                                outside_processing_account,
                                material_variance_account,
                                resource_variance_account,
                                outside_proc_variance_account,
                                std_cost_adjustment_account,
                                overhead_account,
                                overhead_variance_account,
                                bom_revision,      /* Added for bug 2185087 */
                                routing_revision,
                                bom_revision_date,
                                routing_revision_date,
                                alternate_bom_designator,
                                alternate_routing_designator,
                                completion_subinventory,
                                completion_locator_id,
                                demand_class,
                                attribute_category,
                                kanban_card_id)
	SELECT		   	C_NO,
				v_temp,
				p_org_id,
				SYSDATE,
				fs.last_updated_by,
				SYSDATE,
				fs.created_by,
				fs.class_code,
				fs.line_id,
				fs.primary_item_id,
				fs.scheduled_completion_date,
				v_planned_quantity,
				0,
				0,
				fs.scheduled_completion_date,
				fs.schedule_group_id,
				fs.status,
				v_schedule_number,
				fs.demand_source_header_id,
			       	fs.demand_source_line,
			     	fs.demand_source_delivery,
				fs.demand_source_type,
				fs.project_id,
				fs.task_id,
				fs.end_item_unit_number,
                                USERENV('SESSIONID'),
                                fs.attribute1,
                                fs.attribute2,
                                fs.attribute3,
                                fs.attribute4,
                                fs.attribute5,
                                fs.attribute6,
                                fs.attribute7,
                                fs.attribute8,
                                fs.attribute9,
                                fs.attribute10,
                                fs.attribute11,
                                fs.attribute12,
                                fs.attribute13,
                                fs.attribute14,
                                fs.attribute15,
                                fs.material_account,
                                fs.material_overhead_account,
                                fs.resource_account,
                                fs.outside_processing_account,
                                fs.material_variance_account,
                                fs.resource_variance_account,
                                fs.outside_proc_variance_account,
                                fs.std_cost_adjustment_account,
                                fs.overhead_account,
                                fs.overhead_variance_account,
                                fs.bom_revision,      /* Added for bug 2185087 */
                                fs.routing_revision,
                                fs.bom_revision_date,
                                fs.routing_revision_date,
                                fs.alternate_bom_designator,
                                fs.alternate_routing_designator,
                                fs.completion_subinventory,
                                fs.completion_locator_id,
                                fs.demand_class,
                                fs.attribute_category,
                                fs.kanban_card_id
	FROM  wip_flow_schedules fs
	WHERE fs.wip_entity_id = fs_select_rec.wip_entity
	AND   line_id = p_line_id
        AND organization_id = p_org_id;

	V_ERROR_LINE := 6;

	to_schedule_qty := to_schedule_qty - v_planned_quantity;

--	dbms_output.put_line('Number '||to_char(i)||'flow schedule created!!!');
--	dbms_output.put_line('Planned quantity = '||to_char(v_planned_quantity));

      END LOOP;

      -- Calculate the remaining quantity that can be scheduled in the newest
      -- flow schedule for the item.

      v_itemQty_tab(fs_select_rec.primary_item_id).remainQty :=
	v_order_quantity - v_planned_quantity;

      v_itemQty_tab(fs_select_rec.primary_item_id).wip_id := fs_select_rec.wip_entity;

--      dbms_output.put_line('Remain quantity is:'||
--		to_char(v_itemQty_tab(fs_select_rec.primary_item_id).remainQty));

    END IF;
  END LOOP;

  FOR item_list_rec IN item_list(p_org_id) LOOP
    IF v_itemQty_tab(item_list_rec.primary_item_id).remainQty > 0 THEN

      V_ERROR_LINE := 7;

      SELECT wip_entities_s.nextval
      INTO   v_temp
      FROM   dual;

      V_ERROR_LINE := 8;

      --Bug 6122344
      --v_schedule_number := NVL(substr(FND_PROFILE.value('WIP_JOB_PREFIX'),1,20),'X')
      --		|| to_char(v_temp);
      v_schedule_number := 'FLM-INTERNAL'|| to_char(v_temp);

      INSERT INTO wip_flow_schedules(
				scheduled_flag,
				wip_entity_id,
				organization_id,
				last_update_date,
				last_updated_by,
				creation_date,
				created_by,
				class_code,
				line_id,
				primary_item_id,
				scheduled_start_date,
				planned_quantity,
				quantity_completed,
				quantity_scrapped,
				scheduled_completion_date,
				schedule_group_id,
				status,
				schedule_number,
				demand_source_header_id,
				demand_source_line,
				demand_source_delivery,
				demand_source_type,
				project_id,
				task_id,
				end_item_unit_number,
                                request_id,
                                attribute1,
                                attribute2,
                                attribute3,
                                attribute4,
                                attribute5,
                                attribute6,
                                attribute7,
                                attribute8,
                                attribute9,
                                attribute10,
                                attribute11,
                                attribute12,
                                attribute13,
                                attribute14,
                                attribute15,
                                material_account,
                                material_overhead_account,
                                resource_account,
                                outside_processing_account,
                                material_variance_account,
                                resource_variance_account,
                                outside_proc_variance_account,
                                std_cost_adjustment_account,
                                overhead_account,
                                overhead_variance_account,
                                bom_revision,  /* Added for bug 2185087 */
                                routing_revision,
                                bom_revision_date,
                                routing_revision_date,
                                alternate_bom_designator,
                                alternate_routing_designator,
                                completion_subinventory,
                                completion_locator_id,
                                demand_class,
                                attribute_category,
                                kanban_card_id)


      SELECT		   	C_NO,
				v_temp,
				p_org_id,
				SYSDATE,
				fs.last_updated_by,
				SYSDATE,
				fs.created_by,
				fs.class_code,
				fs.line_id,
				fs.primary_item_id,
				fs.scheduled_completion_date,
				v_itemQty_tab(item_list_rec.primary_item_id).remainQty,
				0,
				0,
				fs.scheduled_completion_date,
				fs.schedule_group_id,
				fs.status,
				v_schedule_number,
				fs.demand_source_header_id,
			       	fs.demand_source_line,
			     	fs.demand_source_delivery,
				fs.demand_source_type,
				fs.project_id,
				fs.task_id,
				fs.end_item_unit_number,
                                USERENV('SESSIONID'),
                                fs.attribute1,
                                fs.attribute2,
                                fs.attribute3,
                                fs.attribute4,
                                fs.attribute5,
                                fs.attribute6,
                                fs.attribute7,
                                fs.attribute8,
                                fs.attribute9,
                                fs.attribute10,
                                fs.attribute11,
                                fs.attribute12,
                                fs.attribute13,
                                fs.attribute14,
                                fs.attribute15,
                                fs.material_account,
                                fs.material_overhead_account,
                                fs.resource_account,
                                fs.outside_processing_account,
                                fs.material_variance_account,
                                fs.resource_variance_account,
                                fs.outside_proc_variance_account,
                                fs.std_cost_adjustment_account,
                                fs.overhead_account,
                                fs.overhead_variance_account,
                                fs.bom_revision,    /* Added for bug 2185087 */
                                fs.routing_revision,
                                fs.bom_revision_date,
                                fs.routing_revision_date,
                                fs.alternate_bom_designator,
                                fs.alternate_routing_designator,
                                fs.completion_subinventory,
                                fs.completion_locator_id,
                                fs.demand_class,
                                fs.attribute_category,
                                fs.kanban_card_id
      FROM  wip_flow_schedules fs
      WHERE fs.wip_entity_id = v_itemQty_tab(item_list_rec.primary_item_id).wip_id
      AND   line_id = p_line_id
      AND   organization_id = p_org_id;

      V_ERROR_LINE := 9;

    END IF;
  END LOOP;

  DELETE
  FROM	  wip_flow_schedules
  WHERE   planned_quantity = 0
  AND     line_id = p_line_id
  AND     organization_id = p_org_id;


  IF (dbms_sql.is_open(cursor_name)) THEN
    dbms_sql.close_cursor(cursor_name);
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
--    dbms_output.put_line('i did not find data');
    IF (dbms_sql.is_open(cursor_name)) THEN
    dbms_sql.close_cursor(cursor_name);
  END IF;
    RETURN;
  WHEN OTHERS THEN

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(
	V_PKG_NAME,V_PROCEDURE_NAME||': Line '||to_char(V_ERROR_LINE));
    END IF;

    IF (dbms_sql.is_open(cursor_name)) THEN
      dbms_sql.close_cursor(cursor_name);
    END IF;
--    dbms_output.put_line('!!!ERROR!!!:' || to_char(sqlcode) ||
--            substr(sqlerrm,1,60));
    RETURN;

END create_po_fs;

-- This procedure rounds up the planned quantity of all flow schedules
-- that have fractional quantities with item rounding attribute set to yes
-- Excess is trimmed off from flow schedules starting from the end of the sequence.

PROCEDURE rounding_process(
				p_org_id IN NUMBER,
				p_line_id IN NUMBER,
				p_rule_id IN NUMBER,
				p_demand_tab IN OUT NOCOPY DemandTabTyp)
IS

  cursor_name   INTEGER;
  fs_select_rec	fs_select_type;
  v_last_wip    NUMBER;
  v_round_total	NUMBER;
  v_round_qty	NUMBER;

BEGIN

  V_PROCEDURE_NAME := 'Rounding_Process';
  V_ERROR_LINE := 1;

   v_last_wip := 0;
      v_round_total := 0;

  FOR item_list_rec IN item_list(p_org_id) LOOP

    IF p_demand_tab(item_list_rec.primary_item_id).roundType = C_ROUND_TYPE THEN

      V_ERROR_LINE := 2;
      cursor_name := Create_Cursor(p_rule_id,p_org_id,p_line_id,C_ASC,C_ITEM,
	item_list_rec.primary_item_id);

      V_ERROR_LINE := 3;

      LOOP
        if dbms_sql.fetch_rows(cursor_name) > 0 then
          dbms_sql.column_value(cursor_name,1, fs_select_rec.wip_entity);
          dbms_sql.column_value(cursor_name,7, fs_select_rec.primary_item_id);
          dbms_sql.column_value(cursor_name,8, fs_select_rec.planned_quantity);
        end if;

        IF v_last_wip = fs_select_rec.wip_entity THEN
          EXIT;
        END IF;

        v_round_qty := TRUNC(fs_select_rec.planned_quantity-0.0000000001) + 1;

        IF v_round_qty > fs_select_rec.planned_quantity THEN

	  v_round_total := v_round_total +
		(v_round_qty - fs_select_rec.planned_quantity);

	  UPDATE wip_flow_schedules fs
          SET    planned_quantity = v_round_qty
      	  WHERE  fs.wip_entity_id = fs_select_rec.wip_entity
	  AND    organization_id = p_org_id;

          V_ERROR_LINE := 4;

        END IF;

        v_last_wip := fs_select_rec.wip_entity;

      END LOOP;

      v_round_total := TRUNC(v_round_total);

      v_last_wip := 0;

      V_ERROR_LINE := 5;

      cursor_name := Create_Cursor(p_rule_id,p_org_id,p_line_id,C_DESC,C_ITEM,
	item_list_rec.primary_item_id);

      V_ERROR_LINE := 6;



      LOOP
        if dbms_sql.fetch_rows(cursor_name) > 0 then
          dbms_sql.column_value(cursor_name,1, fs_select_rec.wip_entity);
          dbms_sql.column_value(cursor_name,7, fs_select_rec.primary_item_id);
          dbms_sql.column_value(cursor_name,8, fs_select_rec.planned_quantity);
        end if;

        IF v_last_wip = fs_select_rec.wip_entity THEN
          EXIT;
        END IF;

        IF fs_select_rec.planned_quantity > v_round_total THEN

          V_ERROR_LINE := 7;

	  UPDATE wip_flow_schedules fs
          SET    planned_quantity = fs_select_rec.planned_quantity -
		  v_round_total
      	  WHERE  fs.wip_entity_id = fs_select_rec.wip_entity
	  AND    organization_id = p_org_id;

	  V_ERROR_LINE := 8;

	  v_round_total := 0;

        ELSE
	  v_round_total := v_round_total - fs_select_rec.planned_quantity;

          V_ERROR_LINE := 9;

	  DELETE
	  FROM    wip_flow_schedules
	  WHERE   wip_entity_id = fs_select_rec.wip_entity
	  AND     organization_id = p_org_id;

  	  V_ERROR_LINE := 10;

        END IF;

        IF v_round_total = 0 THEN
	  EXIT;
        END IF;

        v_last_wip := fs_select_rec.wip_entity;

      END LOOP;
    END IF;
  END LOOP;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
--    IF (dbms_sql.is_open(cursor_name)) THEN
--    dbms_sql.close_cursor(cursor_name);
--    END IF;

  RETURN;

  WHEN OTHERS THEN

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(
	V_PKG_NAME,V_PROCEDURE_NAME||': Line '||to_char(V_ERROR_LINE));
    END IF;

    IF (dbms_sql.is_open(cursor_name)) THEN
      dbms_sql.close_cursor(cursor_name);
    end IF;

    return;

END rounding_process;


-- This procedure sequences the unscheduled flow schedules on the line using
-- the specified criteria and then schedules them on the line.

PROCEDURE schedule_orders (
				p_line_id IN NUMBER,
				p_org_id IN NUMBER,
				p_rule_id IN NUMBER,
				p_cap_tab IN CapTabTyp,
				p_demand_tab IN DemandTabTyp,
				p_time_tab IN OUT NOCOPY TimeTabTyp)
IS

  v_current_date	NUMBER;
  v_current_cap		NUMBER;
  v_remain_qty		NUMBER;
  v_current_wip		NUMBER;
  v_build_seq		NUMBER;
  v_temp		NUMBER;
  v_null_build_seq	NUMBER;
  v_build_seq_tab  BuildSeqTabTyp;
  v_start_time		NUMBER;
  v_end_time		NUMBER;
  v_hr_line_rate	NUMBER;
  v_line_rate		NUMBER;
  v_required_time	NUMBER;
  v_begin_time		DATE;
  v_completion_time	DATE;
  v_final_time		NUMBER;
  fs_select_rec	fs_select_type;
  cursor_name           INTEGER;
  v_last_wip	   	NUMBER;
  v_schedule_number	VARCHAR2(30);
  v_current_item	NUMBER;
  qty_temp		NUMBER;
  date_temp		date;
  trans_temp		number;
  l_fixed_lead_time	NUMBER;
  l_variable_lead_time	NUMBER;
  l_lead_time		NUMBER;

BEGIN

  V_PROCEDURE_NAME := 'Schedule_Orders';
  V_ERROR_LINE := 1;

  -- Set current date to be the first valid date in the scheduling window.
  -- This is the first index in the capacity table.

  v_current_date := p_cap_tab.FIRST;
  v_current_cap := p_cap_tab(v_current_date).capacity;

-- dbms_output.put_line('First valid date in scheduling window is:' ||
--	to_date(v_current_date,'J'));
--dbms_output.put_line('Available capacity on this date is:' ||
--   	to_char(v_current_cap));

--  dbms_output.put_line('Calculating max build sequences');
  -- Obtain the maximum build sequence for each schedule group from scheduled
  -- flow schedules on the line.

  calculate_build_sequences(p_org_id, p_line_id, v_build_seq_tab);

--dbms_output.put_line('AFTER the Schedule group loop!!!');
--    dbms_output.put_line('AFTER the Schedule group loop!!!');

   -- Obtain the maximum sequence for the null schedule group
    SELECT NVL(MAX(build_sequence),0)
    INTO   v_null_build_seq
    FROM   wip_flow_schedules fs
    WHERE  fs.schedule_group_id IS NULL
      AND  fs.line_id = p_line_id
      AND  fs.organization_id = p_org_id
      AND  scheduled_flag = C_YES;

    V_ERROR_LINE := 2;

--  dbms_output.put_line('The max sequence for the null schedule group is: '||
--	to_char(v_null_build_seq));

  -- Obtain information on the start time and end time of the line for
  -- time stamping flow schedules.

  SELECT maximum_rate, start_time, stop_time
  INTO   v_hr_line_rate, v_start_time, v_end_time
  FROM   wip_lines
  WHERE  line_id = p_line_id
    AND  organization_id = p_org_id;

  V_ERROR_LINE := 3;

  -- Fix bug 939061, add 24 hrs to stop_time if stop_time <= start_time
  if (v_end_time <= v_start_time) then
    v_end_time := v_end_time+24*3600;
  end if;

  v_line_rate := TRUNC(v_hr_line_rate * (v_end_time - v_start_time)/3600);

--  dbms_output.put_line('Maximum rate = '||to_char(v_line_rate));
--  dbms_output.put_line('Start time = '||to_char(v_start_time));
--  dbms_output.put_line('Maximum rate = '||to_char(v_end_time));

  -- New and existing flow schedules will be time stamped and
  -- scheduled before existing wip jobs and repetitive schedules.

  -- Order the existing flow schedules by schedule group id and build sequence
  -- and assign the appropriate time stamps to these flow schedules first.
--  dbms_output.put_line('Putting time stamps on existing flow schedules');

--  time_existing_fs(p_org_id, p_line_id, p_cap_tab, v_time_tab);

  V_ERROR_LINE := 4;

  cursor_name := Create_Cursor(p_rule_id,p_org_id,p_line_id,C_ASC,C_NORM,C_NORM);

  V_ERROR_LINE := 5;

  LOOP
    if dbms_sql.fetch_rows(cursor_name) > 0 then
       dbms_sql.column_value(cursor_name,1, fs_select_rec.wip_entity);
       dbms_sql.column_value(cursor_name,2, fs_select_rec.creation_date);
       dbms_sql.column_value(cursor_name,3, fs_select_rec.schedule_date);
       dbms_sql.column_value(cursor_name,4, fs_select_rec.promise_date);
       dbms_sql.column_value(cursor_name,5, fs_select_rec.request_date);
       dbms_sql.column_value(cursor_name,6, fs_select_rec.planning_priority);
       dbms_sql.column_value(cursor_name,7, fs_select_rec.primary_item_id);
       dbms_sql.column_value(cursor_name,8, fs_select_rec.planned_quantity);
       dbms_sql.column_value(cursor_name,9, fs_select_rec.schedule_group_id);

    end if;


    SELECT NVL(fixed_lead_time, 0), NVL(variable_lead_time, 0)
    INTO   l_fixed_lead_time, l_variable_lead_time
    FROM   MTL_SYSTEM_ITEMS
    WHERE  inventory_item_id = fs_select_rec.primary_item_id
    AND    organization_id = p_org_id;


--  dbms_output.put_line('INSIDE the FLOW SCHEDULE CURSOR loop!!!');

    IF v_last_wip = fs_select_rec.wip_entity THEN
      RETURN;
    END IF;

    v_last_wip := fs_select_rec.wip_entity;
    v_remain_qty := fs_select_rec.planned_quantity;
    v_current_wip := fs_select_rec.wip_entity;

    select scheduled_completion_date, demand_source_line
    into date_temp, trans_temp
    from wip_flow_schedules
    where  wip_entity_id = v_current_wip
    and    organization_id = p_org_id;

    -- LOOP used for making sure that all quantity of the flow schedule has
    -- been scheduled.

--    dbms_output.put_line('Inside the flow schedule loop');

    WHILE v_remain_qty > 0  LOOP



--    dbms_output.put_line('The current flow schedule is:  ' ||to_char
--	(v_current_wip));
--      dbms_output.put_line('Remain quantity for current flow schedule ' ||
--	to_char(v_current_wip)||' is ' ||to_char(v_remain_qty));

      -- Get the next build sequence for the schedule group of the current
      -- flow schedule.

      IF fs_select_rec.schedule_group_id IS NOT NULL THEN
        v_build_seq :=
        v_build_seq_tab(fs_select_rec.schedule_group_id).buildseq + 1;
        v_build_seq_tab(fs_select_rec.schedule_group_id).buildseq := v_build_seq;
      ELSE
        v_build_seq := v_null_build_seq + 1;
	v_null_build_seq := v_build_seq;
      END IF;

--    dbms_output.put_line('The next build sequence is '||to_char
--	(v_build_seq)|| 'for schedule group '||
--	to_char(fs_select_rec.schedule_group_id));

      -- If the capacity of the current date is 0, get the next valid work
      -- date and set the capacity to the capacity of this new date.
      -- If there is no next valid work date, we are at the end of the
      -- scheduling window and we are finished with scheduling.

      WHILE v_current_cap = 0 LOOP
--      dbms_output.put_line('0 capacity on '||to_date(v_current_date,'J'));

	IF v_current_date = p_cap_tab.LAST THEN
--        dbms_output.put_line(to_date(v_current_date,'J')||'was the last day
--	  of the scheduling window.  scheduling is completed. exiting ...');
	  RETURN;
	ELSE
	  v_current_date := p_cap_tab.NEXT(v_current_date);
          v_current_cap := p_cap_tab(v_current_date).capacity;

--	  dbms_output.put_line('Next valid work date is: '||
--	  to_date(v_current_date,'J'));
--	  dbms_output.put_line('Capacity available = '||to_char(v_current_cap));

        END IF;
      END LOOP;

      -- If there is no entry in the completion time table for the date
      -- initialize it with the start time

      IF p_time_tab.EXISTS(v_current_date) = FALSE THEN
        SELECT start_time
        INTO   v_final_time
        FROM   wip_lines
        WHERE  line_id = p_line_id
          AND  organization_id = p_org_id;

        V_ERROR_LINE := 6;

	p_time_tab(v_current_date).start_completion_time := v_final_time;

--      dbms_output.put_line('Initialization:
--	For '||to_date(v_current_date,'J')||',the completion time is '||
--	 to_char(p_time_tab(v_current_date).start_time));
      END IF;

      -- After scheduling, set the completion date to today's date and
      -- set the scheduled flag to yes.  Update the build sequence of the
      -- flow schedule.

      IF v_remain_qty <= v_current_cap THEN
--	dbms_output.put_line(to_char(v_current_wip)||'can be scheduled');

	v_required_time := TRUNC(v_remain_qty * 3600/v_hr_line_rate);
        if (p_time_tab(v_current_date).start_completion_time+v_required_time > p_time_tab(v_current_date).end_completion_time) then
          v_required_time := p_time_tab(v_current_date).end_completion_time -
                             p_time_tab(v_current_date).start_completion_time;
        end if;

	v_completion_time := to_date(v_current_date,'J') +
	((p_time_tab(v_current_date).start_completion_time+v_required_time)/86400);

	l_lead_time := l_fixed_lead_time +
		      (l_variable_lead_time * (v_remain_qty-1));

        IF l_lead_time = 0 THEN
          v_begin_time := v_completion_time;
        ELSE
	  v_begin_time := mrp_line_schedule_algorithm.calculate_begin_time(
				p_org_id,
				v_completion_time,
				l_lead_time,
				v_start_time,
				v_end_time);
        END IF;


	UPDATE wip_flow_schedules
	SET    scheduled_start_date = v_begin_time,
	       scheduled_completion_date = v_completion_time,
	       scheduled_flag = C_YES,
	       build_sequence = v_build_seq
	WHERE  wip_entity_id = v_current_wip
	AND    organization_id = p_org_id;

	select planned_quantity
	into   qty_temp
	from   wip_flow_schedules
 	where  wip_entity_id = v_current_wip
	and    organization_id = p_org_id;

        V_ERROR_LINE := 7;

        p_time_tab(v_current_date).start_completion_time :=
	p_time_tab(v_current_date).start_completion_time + v_required_time;

	-- Decrement capacity on the line for the current date by the scheduled
	-- quantity.

	v_current_cap := v_current_cap - v_remain_qty;

--	  dbms_output.put_line('Capacity on '||to_date(v_current_date,'J')||' = '||
--	  to_char(v_current_cap));

	-- The entire flow schedule has been scheduled and the
	-- remaining quantity = 0

	v_remain_qty := 0;

      ELSIF (v_remain_qty > v_current_cap) THEN
--	dbms_output.put_line(to_char(v_current_wip)||'can not be scheduled');
--	dbms_output.put_line('Capacity on '||to_date(v_current_date,'J')||' = '||
--	  to_char(v_current_cap));

	SELECT primary_item_id
	INTO   v_current_item
	FROM   wip_flow_schedules
	WHERE  wip_entity_id = v_current_wip
	AND    organization_id = p_org_id;

	V_ERROR_LINE := 8;

	IF p_demand_tab(v_current_item).roundType = 1 THEN
	  v_current_cap := TRUNC(v_current_cap);

	  WHILE v_current_cap = 0 LOOP

	    IF v_current_date = p_cap_tab.LAST THEN
	      RETURN;
	    ELSE
	      v_current_date := p_cap_tab.NEXT(v_current_date);
              v_current_cap := p_cap_tab(v_current_date).capacity;
	      v_current_cap := TRUNC(v_current_cap);
	    END IF;
 	  END LOOP;
	END IF;

--	dbms_output.put_line('current date is: '||to_char(v_current_date));
--        dbms_output.put_line('Current cap is: '||to_char(v_current_cap));

	IF v_current_cap < v_remain_qty THEN
	  -- If there is no entry in the completion time table for the date
          -- initialize it with the start time

          IF p_time_tab.EXISTS(v_current_date) = FALSE THEN
            SELECT start_time
            INTO   v_final_time
            FROM   wip_lines
            WHERE  line_id = p_line_id
            AND  organization_id = p_org_id;

	    V_ERROR_LINE := 9;

	    p_time_tab(v_current_date).start_completion_time := v_final_time;
          END IF;

          v_required_time := TRUNC(v_current_cap * 3600/v_hr_line_rate);

          if (p_time_tab(v_current_date).start_completion_time+v_required_time > p_time_tab(v_current_date).end_completion_time) then
            v_required_time := p_time_tab(v_current_date).end_completion_time -
                               p_time_tab(v_current_date).start_completion_time;
          end if;

          v_completion_time := to_date(v_current_date,'J') +
          ((p_time_tab(v_current_date).start_completion_time+v_required_time)/86400);

	  l_lead_time := l_fixed_lead_time +
		        (l_variable_lead_time * (v_current_cap-1));

          IF l_lead_time = 0 THEN
            v_begin_time := v_completion_time;
          ELSE
  	    v_begin_time := mrp_line_schedule_algorithm.calculate_begin_time(
				p_org_id,
				v_completion_time,
				l_lead_time,
				v_start_time,
				v_end_time);
          END IF;


	  UPDATE wip_flow_schedules
	  SET    scheduled_start_date = v_begin_time,
	         scheduled_completion_date = v_completion_time,
	         planned_quantity = v_current_cap,
	         scheduled_flag = C_YES,
	         build_sequence = v_build_seq
	  WHERE  wip_entity_id = v_current_wip
	  AND  organization_id = p_org_id;

	  select planned_quantity
	  into   qty_temp
	  from   wip_flow_schedules
 	  where  wip_entity_id = v_current_wip
	  and    organization_id = p_org_id;

	  V_ERROR_LINE := 10;

          p_time_tab(v_current_date).start_completion_time :=
	    p_time_tab(v_current_date).start_completion_time + v_required_time;

	  -- Create a new flow schedule to carry over the unscheduled quantity
          SELECT wip_entities_s.nextval
          INTO   v_temp
          FROM   dual;

	  V_ERROR_LINE := 11;

          --Bug 6122344
   	  --v_schedule_number := NVL(substr(FND_PROFILE.value('WIP_JOB_PREFIX'),1,20),'X') || to_char(v_temp);
          v_schedule_number := 'FLM-INTERNAL'|| to_char(v_temp);

   	  INSERT INTO wip_flow_schedules(
				scheduled_flag,
				wip_entity_id,
				organization_id,
				last_update_date,
				last_updated_by,
				creation_date,
				created_by,
				class_code,
				line_id,
				primary_item_id,
				scheduled_start_date,
				planned_quantity,
				quantity_completed,
				quantity_scrapped,
				scheduled_completion_date,
				schedule_group_id,
				status,
				schedule_number,
				demand_source_header_id,
				demand_source_line,
				demand_source_delivery,
				demand_source_type,
				project_id,
				task_id,
				end_item_unit_number,
                                request_id,
                                attribute1,
                                attribute2,
                                attribute3,
                                attribute4,
                                attribute5,
                                attribute6,
                                attribute7,
                                attribute8,
                                attribute9,
                                attribute10,
                                attribute11,
                                attribute12,
                                attribute13,
                                attribute14,
                                attribute15,
                                material_account,
                                material_overhead_account,
                                resource_account,
                                outside_processing_account,
                                material_variance_account,
                                resource_variance_account,
                                outside_proc_variance_account,
                                std_cost_adjustment_account,
                                overhead_account,
                                overhead_variance_account,
                                bom_revision,  /* Added for bug 2185087 */
                                routing_revision,
                                bom_revision_date,
                                routing_revision_date,
                                alternate_bom_designator,
                                alternate_routing_designator,
                                completion_subinventory,
                                completion_locator_id,
                                demand_class,
                                attribute_category,
                                kanban_card_id)

	  SELECT		C_NO,
				v_temp,
				p_org_id,
				SYSDATE,
				fs.last_updated_by,
				SYSDATE,
				fs.created_by,
				fs.class_code,
				fs.line_id,
				fs.primary_item_id,
				to_date(v_current_date,'J'),
				v_remain_qty - v_current_cap,
				0,
				0,
				to_date(v_current_date,'J'),
				fs.schedule_group_id,
				fs.status,
				v_schedule_number,
				fs.demand_source_header_id,
			       	fs.demand_source_line,
			     	fs.demand_source_delivery,
				fs.demand_source_type,
				fs.project_id,
				fs.task_id,
				fs.end_item_unit_number,
				USERENV('SESSIONID'),
                                fs.attribute1,
                                fs.attribute2,
                                fs.attribute3,
                                fs.attribute4,
                                fs.attribute5,
                                fs.attribute6,
                                fs.attribute7,
                                fs.attribute8,
                                fs.attribute9,
                                fs.attribute10,
                                fs.attribute11,
                                fs.attribute12,
                                fs.attribute13,
                                fs.attribute14,
                                fs.attribute15,
                                fs.material_account,
                                fs.material_overhead_account,
                                fs.resource_account,
                                fs.outside_processing_account,
                                fs.material_variance_account,
                                fs.resource_variance_account,
                                fs.outside_proc_variance_account,
                                fs.std_cost_adjustment_account,
                                fs.overhead_account,
                                fs.overhead_variance_account,
                                fs.bom_revision,  /* Added for bug 2185087 */
                                fs.routing_revision,
                                fs.bom_revision_date,
                                fs.routing_revision_date,
                                fs.alternate_bom_designator,
                                fs.alternate_routing_designator,
                                fs.completion_subinventory,
                                fs.completion_locator_id,
                                fs.demand_class,
                                fs.attribute_category,
                                fs.kanban_card_id
	  FROM  wip_flow_schedules fs
	  WHERE fs.wip_entity_id = fs_select_rec.wip_entity
	  AND organization_id = p_org_id;

 	  V_ERROR_LINE := 12;

	  -- Reset the remaining quantity to be scheduled as the
	  -- left over quantity from the last flow schedule.

	  v_remain_qty := v_remain_qty - v_current_cap;

	  -- Set the capacity for current date to 0.

	  v_current_cap := 0;

	  -- Point to the newly created flow schedule in order to
	  -- schedule the quantity.

	  v_current_wip := v_temp;
        END IF;
      END IF;
    END LOOP;
  END LOOP;

  IF (dbms_sql.is_open(cursor_name)) THEN
    dbms_sql.close_cursor(cursor_name);
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (dbms_sql.is_open(cursor_name)) THEN
    dbms_sql.close_cursor(cursor_name);
    END IF;
  RETURN;

  WHEN OTHERS THEN

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(
	V_PKG_NAME,V_PROCEDURE_NAME||': Line '||to_char(V_ERROR_LINE));
    END IF;

    IF (dbms_sql.is_open(cursor_name)) THEN
    dbms_sql.close_cursor(cursor_name);
    end IF;
--  dbms_output.put_line('!!!ERROR!!!:' || to_char(sqlcode) ||
--              substr(sqlerrm,1,60));
    return;

END schedule_orders;

-- This procedure calculates the production plan for each item for each date
-- between the first date to the calculated end date in the scheduling window.

PROCEDURE calculate_production_plan(
				p_org_id IN NUMBER,
				p_line_id IN NUMBER,
				p_first_date IN DATE,
				p_last_date IN DATE,
				p_cap_tab IN CapTabTyp,
				p_demand_tab IN OUT NOCOPY DemandTabTyp)
IS
  v_begin_date 		NUMBER;
  v_finish_date		NUMBER;
  v_current_date	NUMBER;
  v_ratio		NUMBER;
  v_production		NUMBER;
  v_trunc_sum		NUMBER;
  v_cap_diff		NUMBER;
  v_item_id		NUMBER;
  v_quantity		NUMBER;
  v_max_diff		NUMBER;
  v_decrement_qty	NUMBER;
  v_finish_flag		NUMBER;
  v_round_type		NUMBER;
  v_item_round		NUMBER;
  v_item_round_qty	NUMBER;

  -- Cursor used to determine if any items of no rounding exists.
  CURSOR no_round_cursor IS
    SELECT number1,number2
    FROM   mrp_form_query mfq, mtl_system_items mtl
    WHERE  mfq.date1 = to_date(v_current_date,'J')
    AND    mfq.query_id = v_query_id
    AND    mfq.number1 = mtl.inventory_item_id
    AND    NVL(mtl.rounding_control_type,2) <> C_ROUND_TYPE
    AND    mtl.organization_id = p_org_id
    ORDER BY number2;

BEGIN

  V_PROCEDURE_NAME := 'Calculate_Production_Plan';
  V_ERROR_LINE := 1;

  v_begin_date := to_number(to_char(p_first_date,'J'));
  v_finish_date := to_number(to_char(p_last_date,'J'));

  SELECT mrp_form_query_s.nextval
  INTO v_query_id
  FROM DUAL;

  V_ERROR_LINE := 2;

  FOR i in v_begin_date..v_finish_date LOOP

    v_current_date := i;

--    dbms_output.put_line('The date is: '||to_date(v_current_date,'J'));

    IF p_cap_tab.EXISTS(v_current_date)AND
	p_cap_tab(v_current_date).capacity > 0 THEN

--      dbms_output.put_line('The capacity is: '||
--	to_char(p_cap_tab(v_current_date).capacity));

      FOR item_list_rec IN item_list(p_org_id) LOOP

--	dbms_output.put_line('The item is: '||to_char(item_list_rec.primary_item_id));
	v_ratio := p_demand_tab(item_list_rec.primary_item_id).totalDemand/
			V_GLOBAL_DEMAND;

--	dbms_output.put_line('The ratio is: '||to_char(v_ratio));

	-- Use whole number for line capacity

	v_production := TRUNC((v_ratio *
		p_cap_tab(v_current_date).capacity),2);

--	dbms_output.put_line('The production is: '||to_char(v_production));

	INSERT INTO MRP_FORM_QUERY (
			QUERY_ID,
			LAST_UPDATE_DATE,
			LAST_UPDATED_BY,
			CREATION_DATE,
			CREATED_BY,
			DATE1,
			NUMBER1,
			NUMBER2,
			NUMBER3)
	VALUES (
			v_query_id,
			SYSDATE,
			1,
			SYSDATE,
			1,
			to_date(v_current_date,'J'),
			item_list_rec.primary_item_id,
			TRUNC(v_production),
			v_production - TRUNC(v_production));

      	-- If the item is of no round type, then we don't want to round.
	-- Therefore, we use the original production plan and we set
	-- the difference between production and truncated production to 0.

	IF p_demand_tab(item_list_rec.primary_item_id).roundType <> C_ROUND_TYPE THEN

--dbms_output.put_line('Item '||to_char(item_list_rec.primary_item_id)||'is not a round item');

	  UPDATE MRP_FORM_QUERY
	  SET    number2 = v_production,
	         number3 = 0
	  WHERE  number1 = item_list_rec.primary_item_id
	  AND    query_id = v_query_id
	  AND    date1 = to_date(v_current_date,'J');

	END IF;

	V_ERROR_LINE := 3;

--      dbms_output.put_line('The diff for item is: '||
--	to_char(v_production - TRUNC(v_production)));

      END LOOP;

      -- Find the sum of all production for the current date.

      SELECT SUM(number2)
      INTO   v_trunc_sum
      FROM   mrp_form_query
      WHERE  query_id = v_query_id
      AND    date1 = to_date(v_current_date,'J');

      V_ERROR_LINE := 4;

--      dbms_output.put_line('The planned sum is: '||to_char(v_trunc_sum));

      -- Find the difference between line capacity and sum of all planned
      -- production.

      v_cap_diff := p_cap_tab(v_current_date).capacity - v_trunc_sum;

--      dbms_output.put_line('The diff is: '||to_char(v_cap_diff));

      FOR production_round_rec IN production_round(v_current_date,v_query_id)
	LOOP

	IF v_cap_diff = 0 THEN
	  EXIT;

	ELSIF v_cap_diff < 1 THEN

	  OPEN no_round_cursor;
  	  FETCH no_round_cursor INTO v_item_round, v_item_round_qty;
	  IF no_round_cursor%NOTFOUND THEN
	    CLOSE no_round_cursor;
	    EXIT;

	  ELSE

	    UPDATE mrp_form_query
	    SET    number2 = v_item_round_qty + v_cap_diff
	    WHERE  number1 = v_item_round
 	    AND    date1 = to_date(v_current_date,'J')
	    AND    query_id = v_query_id;
	    CLOSE no_round_cursor;
	    EXIT;
	  END IF;

     	ELSE

--	  dbms_output.put_line('Updating ...'||to_char(production_round_rec.number1));

	  UPDATE mrp_form_query
	  SET    number2 =(SELECT number2 +1
			 FROM   mrp_form_query
			 WHERE  date1 = to_date(v_current_date,'J')
			 AND    query_id = v_query_id
			 AND    number1 = production_round_rec.number1)
	  WHERE date1 = to_date(v_current_date,'J')
	  AND   query_id = v_query_id
	  AND   number1 = production_round_rec.number1;

     	  V_ERROR_LINE := 5;

	  v_cap_diff := v_cap_diff - 1 ;

--	dbms_output.put_line('Max item is: '||to_char(v_item_id));
--	dbms_output.put_line('Quantity of item is: '||to_char(v_quantity));
--	dbms_output.put_line('Max diff is: '||to_char(v_max_diff));
	END IF;
      END LOOP;

      -- Update the total demand for each item as well as the global demand
      -- to reflect what has been allocated.
      FOR item_list_rec IN item_list(p_org_id) LOOP

	v_finish_flag := -1;

	SELECT number2
        INTO   v_decrement_qty
	FROM   mrp_form_query
	WHERE  query_id = v_query_id
	AND    number1 = item_list_rec.primary_item_id
	AND    date1 = to_date(v_current_date,'J');

 	V_ERROR_LINE := 6;

	-- If the current production plan is greater than the demand left
	-- for the item, then the decrement quantity is the demand itself.

	IF p_demand_tab(item_list_rec.primary_item_id).totalDemand -
		v_decrement_qty < 0 THEN
	  v_decrement_qty :=
		p_demand_tab(item_list_rec.primary_item_id).totalDemand;
	END IF;

	p_demand_tab(item_list_rec.primary_item_id).totalDemand :=
	p_demand_tab(item_list_rec.primary_item_id).totalDemand -
		v_decrement_qty;

	V_GLOBAL_DEMAND := V_GLOBAL_DEMAND - v_decrement_qty;
--	dbms_output.put_line('GLOBAL DEMAND IS: '||to_char(V_GLOBAL_DEMAND));

	-- If the global demand becomes 0, then the production allocation
	-- process is finished.

	IF V_GLOBAL_DEMAND > 0 THEN
	  v_finish_flag := 1;
	END IF;

      END LOOP;
    ELSE
      FOR item_list_rec IN item_list(p_org_id) LOOP
        INSERT INTO MRP_FORM_QUERY (
			QUERY_ID,
			LAST_UPDATE_DATE,
			LAST_UPDATED_BY,
			CREATION_DATE,
			CREATED_BY,
			DATE1,
			NUMBER1,
			NUMBER2,
			NUMBER3)
	VALUES (
			v_query_id,
			SYSDATE,
			1,
			SYSDATE,
			1,
			to_date(v_current_date,'J'),
			item_list_rec.primary_item_id,
			0,
			0);
      END LOOP;
    END IF;

    IF v_finish_flag = -1 THEN
--    dbms_output.put_line('ALL FINISHED!!!');
      RETURN;
    END IF;

    -- Roll the date forward to next date
    IF v_current_date = p_cap_tab.LAST THEN
	return;
    END IF;

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(
	V_PKG_NAME,V_PROCEDURE_NAME||': Line '||to_char(V_ERROR_LINE));
    END IF;

    RETURN;

END calculate_production_plan;

-- This procedure schedules the flow schedules on the line using the level
-- daily rate algorithm

PROCEDURE schedule_orders_level(
				p_line_id IN NUMBER,
				p_org_id  IN NUMBER,
				p_rule_id IN NUMBER,
				p_cap_tab IN CapTabTyp,
                                p_time_tab IN OUT NOCOPY TimeTabTyp)

IS

  v_demand_tab		DemandTabTyp;
  v_build_seq_tab 	BuildSeqTabTyp;
  v_null_build_seq	NUMBER;
  v_hr_line_rate	NUMBER;
  v_line_rate		NUMBER;
  v_start_time		NUMBER;
  v_end_time		NUMBER;
  v_item_alloc_tab	ItemAllocTabTyp;
  v_remain_qty 		NUMBER;
  v_current_wip 	NUMBER;
  v_current_date 	NUMBER;
  v_alloc_qty 		NUMBER;
  v_build_seq		NUMBER;
  v_final_time		NUMBER;
  v_required_time	NUMBER;
  v_completion_time	DATE;
  v_begin_time		DATE;
  v_temp		NUMBER;
  fs_select_rec	fs_select_type;
  cursor_name           INTEGER;
  v_last_wip		NUMBER;
  v_schedule_number	VARCHAR2(30);
  v_end_date 		DATE;
  v_first_date		DATE;
  v_finish_flag		NUMBER;
  l_fixed_lead_time	NUMBER;
  l_variable_lead_time	NUMBER;
  l_lead_time		NUMBER;

BEGIN

  V_PROCEDURE_NAME := 'Schedule_Orders_Level';
  V_ERROR_LINE := 1;

  -- Calculate total demand and demand ratio for each item
  calculate_demand(p_line_id, p_org_id, v_demand_tab);

  -- Obtain information on the start time and end time of the line for
  -- time stamping flow schedules.

  SELECT maximum_rate, start_time, stop_time
  INTO   v_hr_line_rate, v_start_time, v_end_time
  FROM   wip_lines
  WHERE  line_id = p_line_id
    AND  organization_id = p_org_id;

  if (v_end_time <= v_start_time) then
    v_end_time := v_end_time+24*3600;
  end if;

  V_ERROR_LINE := 2;

  -- Calculate the production plan for each item on each date from the first
  -- date of the scheduling horizon to the date where all demand has been
  -- met or until the end of the scheduling window.

  v_first_date := to_date(p_cap_tab.FIRST,'J');
  v_end_date := to_date(p_cap_tab.LAST,'J');

--  dbms_output.put_line('Calculating production plan ...');

  calculate_production_plan(p_org_id, p_line_id, v_first_date, v_end_date,
	p_cap_tab, v_demand_tab);

--  dbms_output.put_line('Finished calculating production plan ...');

  -- New and existing flow schedules will be time stamped and
  -- scheduled before existing wip jobs and repetitive schedules.
  -- Order the existing flow schedules by schedule group id and build sequence
  -- and assign the appropriate time stamps to these flow schedules first.

--  time_existing_fs(p_org_id, p_line_id, p_cap_tab, v_time_tab);

  V_ERROR_LINE := 3;

  cursor_name := Create_Cursor(p_rule_id, p_org_id, p_line_id, C_ASC,
	C_NORM,C_NORM);

  V_ERROR_LINE := 4;

  -- Set initial current date

  v_current_date := p_cap_tab.FIRST;

  UPDATE mrp_form_query
  SET    number4 = C_DATE_ON
  WHERE  query_id = v_query_id
  AND    date1 = to_date(v_current_date,'J');

  V_ERROR_LINE := 5;

  LOOP
    IF dbms_sql.fetch_rows(cursor_name) > 0 THEN
      dbms_sql.column_value(cursor_name,1, fs_select_rec.wip_entity);
      dbms_sql.column_value(cursor_name,2, fs_select_rec.creation_date);
      dbms_sql.column_value(cursor_name,3, fs_select_rec.schedule_date);
      dbms_sql.column_value(cursor_name,4, fs_select_rec.promise_date);
      dbms_sql.column_value(cursor_name,5, fs_select_rec.request_date);
      dbms_sql.column_value(cursor_name,6, fs_select_rec.planning_priority);
      dbms_sql.column_value(cursor_name,7, fs_select_rec.primary_item_id);
      dbms_sql.column_value(cursor_name,8, fs_select_rec.planned_quantity);
      dbms_sql.column_value(cursor_name,9, fs_select_rec.schedule_group_id);
    END IF;


    SELECT NVL(fixed_lead_time, 0), NVL(variable_lead_time, 0)
    INTO   l_fixed_lead_time, l_variable_lead_time
    FROM   MTL_SYSTEM_ITEMS
    WHERE  inventory_item_id = fs_select_rec.primary_item_id
    AND    organization_id = p_org_id;


    IF v_last_wip = fs_select_rec.wip_entity THEN
      EXIT;
    END IF;

    v_last_wip := fs_select_rec.wip_entity;

    SELECT number2, to_number(to_char(date1,'J'))
    INTO   v_alloc_qty, v_current_date
    FROM   mrp_form_query
    WHERE  query_id = v_query_id
    AND    number1 = fs_select_rec.primary_item_id
    AND    number4 = C_DATE_ON;

    V_ERROR_LINE := 6;

    v_remain_qty := fs_select_rec.planned_quantity;
    v_current_wip := fs_select_rec.wip_entity;

    WHILE v_remain_qty > 0 LOOP

      SELECT number5
      INTO   v_finish_flag
      FROM   mrp_form_query
      WHERE  number1 = fs_select_rec.primary_item_id
      AND    number4 = C_DATE_ON
      AND    query_id = v_query_id;

      V_ERROR_LINE := 7;

      IF v_finish_flag = C_COMPLETE THEN
	EXIT;
      END IF;

      -- If the remaining planned production of the current date is 0,
      -- get the planned production of the next valid work date until
      -- a date that allows a quantity for planned production greater
      -- than 0 for the item.

      -- If we reach the last date of the scheduling window, we are finished
      -- and may exit the procedure.

      WHILE v_alloc_qty = 0 LOOP

	SELECT number5
        INTO   v_finish_flag
	FROM   mrp_form_query
        WHERE  number1 = fs_select_rec.primary_item_id
        AND    number4 = C_DATE_ON
        AND    query_id = v_query_id;

	V_ERROR_LINE := 8;

        IF v_finish_flag = C_COMPLETE THEN
	  EXIT;
        END IF;

	IF v_current_date = p_cap_tab.LAST THEN

	  UPDATE mrp_form_query
	  SET    number5 = C_COMPLETE
	  WHERE  number4 = C_DATE_ON
    	  AND    query_id = v_query_id
    	  AND    number1 = fs_select_rec.primary_item_id;

	  V_ERROR_LINE := 9;

	ELSE

	  UPDATE mrp_form_query
  	  SET    number4 = NULL
	  WHERE  date1 = to_date(v_current_date,'J')
    	  AND    query_id = v_query_id
    	  AND    number1 = fs_select_rec.primary_item_id;

	  V_ERROR_LINE := 10;

	  v_current_date := p_cap_tab.NEXT(v_current_date);

	  UPDATE mrp_form_query
  	  SET    number4 = C_DATE_ON
	  WHERE  date1 = to_date(v_current_date,'J')
    	  AND    query_id = v_query_id
    	  AND    number1 = fs_select_rec.primary_item_id;

	  V_ERROR_LINE := 11;

	  SELECT number2
    	  INTO   v_alloc_qty
    	  FROM   mrp_form_query
    	  WHERE  query_id = v_query_id
    	  AND    number1 = fs_select_rec.primary_item_id
    	  AND    number4 = C_DATE_ON;

	  V_ERROR_LINE := 12;

	END IF;
      END LOOP;

      SELECT number5
      INTO   v_finish_flag
      FROM   mrp_form_query
      WHERE  number1 = fs_select_rec.primary_item_id
      AND    number4 = C_DATE_ON
      AND    query_id = v_query_id;

      V_ERROR_LINE := 13;

      IF v_finish_flag = C_COMPLETE THEN
	EXIT;
      END IF;

      -- If there is no entry in the completion time table for the date
      -- initialize it with the start time

      IF p_time_tab.EXISTS(v_current_date) = FALSE THEN
        SELECT start_time
        INTO   v_final_time
        FROM   wip_lines
        WHERE  line_id = p_line_id
          AND  organization_id = p_org_id;

	V_ERROR_LINE := 14;

	p_time_tab(v_current_date).start_completion_time := v_final_time;

      END IF;

      IF v_remain_qty <= v_alloc_qty THEN

	v_required_time := TRUNC(v_remain_qty * 3600/v_hr_line_rate);
        if (p_time_tab(v_current_date).start_completion_time+v_required_time > p_time_tab(v_current_date).end_completion_time) then
          v_required_time := p_time_tab(v_current_date).end_completion_time -
                             p_time_tab(v_current_date).start_completion_time;
        end if;

        v_completion_time := to_date(v_current_date,'J') +
        ((p_time_tab(v_current_date).start_completion_time+v_required_time)/86400);

	l_lead_time := l_fixed_lead_time +
		      (l_variable_lead_time * (v_remain_qty-1));

        IF l_lead_time = 0 THEN
          v_begin_time := v_completion_time;
        ELSE
	  v_begin_time := mrp_line_schedule_algorithm.calculate_begin_time(
				p_org_id,
				v_completion_time,
				l_lead_time,
				v_start_time,
				v_end_time);
        END IF;


	UPDATE wip_flow_schedules
	SET    scheduled_start_date = v_begin_time,
	           scheduled_completion_date = v_completion_time,
	           scheduled_flag = C_YES
	WHERE  wip_entity_id = v_current_wip
	  AND  organization_id = p_org_id;

	V_ERROR_LINE := 15;

        p_time_tab(v_current_date).start_completion_time :=
	p_time_tab(v_current_date).start_completion_time + v_required_time;

	-- Decrement remaining allocation quantity for the date by the
	-- scheduled quantity

	UPDATE mrp_form_query
  	SET    number2 = (SELECT number2 - v_remain_qty
			  FROM   mrp_form_query
			  WHERE  date1 = to_date(v_current_date,'J')
			  AND    query_id = v_query_id
			  AND    number1 = fs_select_rec.primary_item_id)
	WHERE  date1 = to_date(v_current_date,'J')
    	AND    query_id = v_query_id
    	AND    number1 = fs_select_rec.primary_item_id;

	V_ERROR_LINE := 16;

	-- The entire flow schedule has been scheduled and the
	-- remaining quantity = 0

	v_remain_qty := 0;

      ELSIF v_remain_qty > v_alloc_qty THEN
	v_required_time := TRUNC(v_alloc_qty * 3600/v_hr_line_rate);
        if (p_time_tab(v_current_date).start_completion_time+v_required_time > p_time_tab(v_current_date).end_completion_time) then
          v_required_time := p_time_tab(v_current_date).end_completion_time -
                             p_time_tab(v_current_date).start_completion_time;
        end if;

        v_completion_time := to_date(v_current_date,'J') +
        ((p_time_tab(v_current_date).start_completion_time+v_required_time)/86400);

	l_lead_time := l_fixed_lead_time +
		      (l_variable_lead_time * (v_alloc_qty-1));

        IF l_lead_time = 0 THEN
          v_begin_time := v_completion_time;
        ELSE
	  v_begin_time := mrp_line_schedule_algorithm.calculate_begin_time(
				p_org_id,
				v_completion_time,
				l_lead_time,
				v_start_time,
				v_end_time);
        END IF;


	UPDATE wip_flow_schedules
	SET      scheduled_start_date = v_begin_time,
	           scheduled_completion_date = v_completion_time,
	           planned_quantity = v_alloc_qty,
	           scheduled_flag = C_YES
	WHERE  wip_entity_id = v_current_wip
	  AND  organization_id = p_org_id;

	V_ERROR_LINE := 17;

        p_time_tab(v_current_date).start_completion_time :=
	  p_time_tab(v_current_date).start_completion_time + v_required_time;

	-- Create a new flow schedule to carry over the unscheduled quantity
        SELECT wip_entities_s.nextval
        INTO   v_temp
        FROM   dual;

	V_ERROR_LINE := 18;

        --Bug 6122344
        --v_schedule_number := NVL(substr(FND_PROFILE.value('WIP_JOB_PREFIX'),1,20),'X')
	--		|| to_char(v_temp);
        v_schedule_number := 'FLM-INTERNAL'|| to_char(v_temp);

   	INSERT INTO wip_flow_schedules(
				scheduled_flag,
				wip_entity_id,
				organization_id,
				last_update_date,
				last_updated_by,
				creation_date,
				created_by,
				class_code,
				line_id,
				primary_item_id,
				scheduled_start_date,
				planned_quantity,
				quantity_completed,
				quantity_scrapped,
				scheduled_completion_date,
				schedule_group_id,
				status,
				schedule_number,
				demand_source_header_id,
				demand_source_line,
				demand_source_delivery,
				demand_source_type,
				project_id,
				task_id,
				end_item_unit_number,
                                request_id,
                                attribute1,
                                attribute2,
                                attribute3,
                                attribute4,
                                attribute5,
                                attribute6,
                                attribute7,
                                attribute8,
                                attribute9,
                                attribute10,
                                attribute11,
                                attribute12,
                                attribute13,
                                attribute14,
                                attribute15,
                                material_account,
                                material_overhead_account,
                                resource_account,
                                outside_processing_account,
                                material_variance_account,
                                resource_variance_account,
                                outside_proc_variance_account,
                                std_cost_adjustment_account,
                                overhead_account,
                                overhead_variance_account,
                                bom_revision,   /* Added for bug 2185087 */
                                routing_revision,
                                bom_revision_date,
                                routing_revision_date,
                                alternate_bom_designator,
                                alternate_routing_designator,
                                completion_subinventory,
                                completion_locator_id,
                                demand_class,
                                attribute_category,
                                kanban_card_id)

	SELECT			C_NO,
				v_temp,
				p_org_id,
				SYSDATE,
				fs.last_updated_by,
				SYSDATE,
				fs.created_by,
				fs.class_code,
				fs.line_id,
				fs.primary_item_id,
				to_date(v_current_date,'J'),
				v_remain_qty - v_alloc_qty,
				0,
				0,
				to_date(v_current_date,'J'),
				fs.schedule_group_id,
				fs.status,
				v_schedule_number,
				fs.demand_source_header_id,
			       	fs.demand_source_line,
			     	fs.demand_source_delivery,
				fs.demand_source_type,
				fs.project_id,
				fs.task_id,
				fs.end_item_unit_number,
				USERENV('SESSIONID'),
                                fs.attribute1,
                                fs.attribute2,
                                fs.attribute3,
                                fs.attribute4,
                                fs.attribute5,
                                fs.attribute6,
                                fs.attribute7,
                                fs.attribute8,
                                fs.attribute9,
                                fs.attribute10,
                                fs.attribute11,
                                fs.attribute12,
                                fs.attribute13,
                                fs.attribute14,
                                fs.attribute15,
                                fs.material_account,
                                fs.material_overhead_account,
                                fs.resource_account,
                                fs.outside_processing_account,
                                fs.material_variance_account,
                                fs.resource_variance_account,
                                fs.outside_proc_variance_account,
                                fs.std_cost_adjustment_account,
                                fs.overhead_account,
                                fs.overhead_variance_account,
                                fs.bom_revision,  /* added for bug 2185087 */
                                fs.routing_revision,
                                fs.bom_revision_date,
                                fs.routing_revision_date,
                                fs.alternate_bom_designator,
                                fs.alternate_routing_designator,
                                fs.completion_subinventory,
                                fs.completion_locator_id,
                                fs.demand_class,
                                fs.attribute_category,
                                fs.kanban_card_id
	FROM  wip_flow_schedules fs
	WHERE fs.wip_entity_id = fs_select_rec.wip_entity
	  AND organization_id = p_org_id;

	V_ERROR_LINE := 19;

	-- Reset the remaining quantity to be scheduled as the
	-- left over quantity from the last flow schedule.

	v_remain_qty := v_remain_qty - v_alloc_qty;

	-- Set the remaining allocation for current date to 0.

	v_alloc_qty := 0;

	-- Point to the newly created flow schedule in order to
	-- schedule the quantity.

	v_current_wip := v_temp;
      END IF;
    END LOOP;

  END LOOP;

  IF (dbms_sql.is_open(cursor_name)) THEN
    dbms_sql.close_cursor(cursor_name);
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (dbms_sql.is_open(cursor_name)) THEN
      dbms_sql.close_cursor(cursor_name);
    END IF;
  RETURN;

  WHEN OTHERS THEN

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(
	V_PKG_NAME,V_PROCEDURE_NAME||': Line '||to_char(V_ERROR_LINE));
    END IF;

    IF (dbms_sql.is_open(cursor_name)) THEN
      dbms_sql.close_cursor(cursor_name);
    END IF;

    return;

END schedule_orders_level;

PROCEDURE update_buildseq(
			p_line_id IN NUMBER,
			p_org_id  IN NUMBER)

IS

  v_build_seq 	NUMBER;
  v_null_build_seq NUMBER;
  v_build_seq_tab BuildSeqTabTyp;

BEGIN

  V_PROCEDURE_NAME := 'Update_Buildseq';
  V_ERROR_LINE := 1;

  -- Obtain the maximum build sequence for each schedule group from scheduled
  -- flow schedules on the line.
  calculate_build_sequences(p_org_id, p_line_id, v_build_seq_tab);

  -- Obtain the maximum sequence for the null schedule group
  SELECT NVL(MAX(build_sequence),0)
  INTO   v_null_build_seq
  FROM   wip_flow_schedules fs
  WHERE  fs.schedule_group_id IS NULL
    AND  fs.line_id = p_line_id
    AND  fs.organization_id = p_org_id
    AND  scheduled_flag = C_YES;

  V_ERROR_LINE := 2;

--  dbms_output.put_line('The max build sequence for null schedule group is: '||
--	to_char(v_null_build_seq));

  FOR fs_list_rec IN fs_list(p_line_id,p_org_id) LOOP
    -- Get the next build sequence for the schedule group of the current
      -- flow schedule.

--      dbms_output.put_line('The flow schedule is: '||
--	to_char(fs_list_rec.wip_entity_id));
--      dbms_output.put_line('The schedule group id is: '||
--	to_char(fs_list_rec.schedule_group_id));

      IF fs_list_rec.schedule_group_id IS NOT NULL THEN
	v_build_seq :=
	v_build_seq_tab(fs_list_rec.schedule_group_id).buildseq + 1;
	v_build_seq_tab(fs_list_rec.schedule_group_id).buildseq := v_build_seq;

--	dbms_output.put_line('The build sequence is: '||to_char(v_build_seq));
      ELSE
--	dbms_output.put_line('The schedule group is null.');
	v_build_seq := v_null_build_seq + 1;
	v_null_build_seq := v_build_seq;
--  	dbms_output.put_line('The build sequence is: '||to_char(v_build_seq));

      END IF;

      UPDATE wip_flow_schedules
	SET    build_sequence = v_build_seq
	WHERE  wip_entity_id = fs_list_rec.wip_entity_id
	  AND  organization_id = p_org_id;

      V_ERROR_LINE := 3;

  END LOOP;

EXCEPTION

  WHEN OTHERS THEN

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(
	V_PKG_NAME,V_PROCEDURE_NAME||': Line '||to_char(V_ERROR_LINE));
    END IF;

    return;

END update_buildseq;

-- This procedure schedules the flow schedules using the mix model algorithm.
-- The flow schedules are first temporarily populated in a pl/sql table
-- and then written to the wip_flow_schedules table.

PROCEDURE schedule_mix_model(
				p_line_id IN NUMBER,
				p_org_id  IN NUMBER,
				p_rule_id IN NUMBER,
				p_cap_tab IN CapTabTyp,
				p_demand_tab IN OUT NOCOPY DemandTabTyp,
				p_item_demand_tab IN ItemDemandTabTyp,
                                p_time_tab IN OUT NOCOPY TimeTabTyp)


IS

  v_hr_line_rate  	NUMBER;
  v_start_time	  	NUMBER;
  v_end_time	  	NUMBER;
  v_line_rate	  	NUMBER;
  v_build_seq_tab  	BuildSeqTabTyp;
  v_pattern	 	LONG;
  v_current_num	  	NUMBER;
  v_current_date	NUMBER;
  v_current_wip	   	NUMBER;
  v_position	  	NUMBER;
  fs_select_rec	  	fs_select_type;
  cursor_name     	INTEGER;
  v_last_wip		NUMBER;
  v_min_build_seq	NUMBER;
  v_current_cap		NUMBER;
  v_schedule_number	VARCHAR2(30);
  v_schedule_group	NUMBER;
  v_sequence		NUMBER;
  v_flow_schedule_tab	FlowScheduleTabTyp;
  v_update_date		DATE;
  v_updated_by		NUMBER;
  v_creation_date	DATE;
  v_created_by		NUMBER;
  v_class_code		VARCHAR2(10);
  v_status		NUMBER;
  v_schedule		VARCHAR2(30);
  v_header_id 		NUMBER;
  v_source_line		VARCHAR2(30);
  v_source_delivery	VARCHAR2(30);
  v_current_schedule	NUMBER;
  v_build_seq	   	NUMBER;
  v_null_build_seq 	NUMBER;
  v_planned_quantity 	NUMBER;
  v_final_time	   	NUMBER;
  v_required_time  	NUMBER;
  v_completion_time 	DATE;
  v_begin_time	    	DATE;
  v_source_type	   	NUMBER;
  v_project_id		NUMBER;
  v_task_id		NUMBER;
  v_end_item_unit_number VARCHAR2(30);
  v_temp	   	NUMBER;
  v_finish		NUMBER;
  l_fixed_lead_time	NUMBER;
  l_variable_lead_time	NUMBER;
  l_lead_time		NUMBER;
  v_attribute1          VARCHAR2(150);
  v_attribute2          VARCHAR2(150);
  v_attribute3          VARCHAR2(150);
  v_attribute4          VARCHAR2(150);
  v_attribute5          VARCHAR2(150);
  v_attribute6          VARCHAR2(150);
  v_attribute7          VARCHAR2(150);
  v_attribute8          VARCHAR2(150);
  v_attribute9          VARCHAR2(150);
  v_attribute10         VARCHAR2(150);
  v_attribute11         VARCHAR2(150);
  v_attribute12         VARCHAR2(150);
  v_attribute13         VARCHAR2(150);
  v_attribute14         VARCHAR2(150);
  v_attribute15         VARCHAR2(150);
  v_material_account            NUMBER;
  v_material_overhead_account   NUMBER;
  v_resource_account            NUMBER;
  v_outside_processing_account  NUMBER;
  v_material_variance_account   NUMBER;
  v_resource_variance_account   NUMBER;
  v_outside_proc_var_account    NUMBER;
  v_std_cost_adjustment_account NUMBER;
  v_overhead_account            NUMBER;
  v_overhead_variance_account   NUMBER;
  v_bom_revision             VARCHAR2(3);  /* Added for bug 2185087 */
  v_routing_revision         VARCHAR2(3);
  v_bom_revision_date     DATE ;
  v_routing_revision_date DATE ;
  v_alternate_bom_designator  VARCHAR2(10);
  v_alternate_routing_designator VARCHAR2(10);
  v_completion_subinventory      VARCHAR2(10);
  v_completion_locator_id        NUMBER;
  v_demand_class              VARCHAR2(30);
  v_attribute_category        VARCHAR2(30);
  v_kanban_card_id            NUMBER;


BEGIN

  V_PROCEDURE_NAME := 'Schedule_mix_model';
  V_ERROR_LINE := 1;

--  dbms_output.put_line('Beginning of mix model procedure ...');

  -- Obtain information on the start time and end time of the line for
  -- time stamping flow schedules.

  SELECT maximum_rate, start_time, stop_time
  INTO   v_hr_line_rate, v_start_time, v_end_time
  FROM   wip_lines
  WHERE  line_id = p_line_id
    AND  organization_id = p_org_id;

  V_ERROR_LINE := 2;

  -- Fix bug 939061, add 24 hrs to stop_time if stop_time <= start_time
  if (v_end_time <= v_start_time) then
    v_end_time := v_end_time+24*3600;
  end if;
  v_line_rate := TRUNC(v_hr_line_rate * (v_end_time - v_start_time)/3600);

  -- New and existing flow schedules will be time stamped and
  -- scheduled before existing wip jobs and repetitive schedules.

  -- Order the existing flow schedules by schedule group id and build sequence
  -- and assign the appropriate time stamps to these flow schedules first.

--    dbms_output.put_line('Time stamping existing flow schedules');

--    MRP_UTIL.MRP_TIMING('Before taking care of existing flow schedules');
--  time_existing_fs(p_org_id, p_line_id, p_cap_tab, v_time_tab);

--     MRP_UTIL.MRP_TIMING('After taking care of existing flow schedules');
--    dbms_output.put_line('Establishing the mix model pattern');

--    MRP_UTIL.MRP_TIMING('Before establishing mix model');
  v_pattern := mix_model(p_item_demand_tab);

--    MRP_UTIL.MRP_TIMING('After establishing mix model');
--  dbms_output.put_line('After establishing mix model');

--    dbms_output.put_line('The pattern is: '||v_pattern);

    -- Trim off the first asterisk
  v_pattern := LTRIM(v_pattern,'*');
--    dbms_output.put_line('The pattern is now: '||v_pattern);

  V_ERROR_LINE := 3;

--    MRP_UTIL.MRP_TIMING('Before establishing main cursor');
  cursor_name := Create_Cursor(p_rule_id, p_org_id, p_line_id, C_ASC,
	C_NORM, C_NORM);

--    MRP_UTIL.MRP_TIMING('After creating main cursor');

  V_ERROR_LINE := 4;

    -- In this loop, populate build sequences of all flow schedules to
    -- be scheduled.

  LOOP
    IF dbms_sql.fetch_rows(cursor_name) > 0 THEN
        dbms_sql.column_value(cursor_name,1, fs_select_rec.wip_entity);
        dbms_sql.column_value(cursor_name,6, fs_select_rec.planning_priority);
        dbms_sql.column_value(cursor_name,7, fs_select_rec.primary_item_id);
        dbms_sql.column_value(cursor_name,8, fs_select_rec.planned_quantity);
        dbms_sql.column_value(cursor_name,9, fs_select_rec.schedule_group_id);
    END IF;



    IF v_last_wip = fs_select_rec.wip_entity THEN
      EXIT;
    END IF;

    v_last_wip := fs_select_rec.wip_entity;

--      dbms_output.put_line('Inside the cursor loop');

      -- Order the flow schedules by the item id by populating the order in
      -- the build sequence column.  The latest sequence for the item is stored
      -- in the v_item_demand_tab table.

    v_sequence :=
	p_demand_tab(fs_select_rec.primary_item_id).sequence + 1;
	p_demand_tab(fs_select_rec.primary_item_id).sequence := v_sequence;

--      dbms_output.put_line('The item is: '||to_char(fs_select_rec.primary_item_id));
--      dbms_output.put_line('The sequence is: '||to_char(v_sequence));

--      MRP_UTIL.MRP_TIMING('Inside cursor loop, BEGIN update flow schedule');

    UPDATE wip_flow_schedules
    SET    build_sequence = v_sequence
    WHERE  wip_entity_id = fs_select_rec.wip_entity
    AND    organization_id = p_org_id;

--      MRP_UTIL.MRP_TIMING('Inside cursor loop, FINISH update flow schedule');

    V_ERROR_LINE := 5;

  END LOOP;

  -- Reset sequence of all item to 1 to be used for keeping track of latest
  -- sequence for an item to be scheduled.

  FOR item_list_rec IN item_list(p_org_id) LOOP
    p_demand_tab(item_list_rec.primary_item_id).sequence := 1;
  END LOOP;

  IF (dbms_sql.is_open(cursor_name)) THEN
    dbms_sql.close_cursor(cursor_name);
  END IF;

  -- Set current date to be the first valid date in the scheduling window.
  -- This is the first index in the capacity table.

  v_current_date := p_cap_tab.FIRST;
  v_current_cap := p_cap_tab(v_current_date).capacity;

--     dbms_output.put_line('First valid date in scheduling window is:' ||
--    	to_date(v_current_date,'J'));
--     dbms_output.put_line('Available capacity on this date is:' ||
--       	to_char(v_current_cap));

  -- Obtain the maximum build sequence for each schedule group from scheduled
  -- flow schedules on the line.
  calculate_build_sequences(p_org_id, p_line_id, v_build_seq_tab);

  -- Obtain the maximum sequence for the null schedule group
  SELECT NVL(MAX(build_sequence),0)
  INTO   v_null_build_seq
  FROM   wip_flow_schedules fs
  WHERE  fs.schedule_group_id IS NULL
  AND    fs.line_id = p_line_id
  AND    fs.organization_id = p_org_id
  AND    scheduled_flag = C_YES;

--    MRP_UTIL.MRP_TIMING('BEGIN OF GOING THROUGH MIX MODEL PATTERN');
  WHILE instr(v_pattern,'*') <> 0 LOOP
--      MRP_UTIL.MRP_TIMING('Find out pattern');
    IF v_finish = 1 THEN
--    MRP_UTIL.MRP_TIMING('Finished');
      EXIT;
    END IF;

    WHILE v_current_cap = 0 LOOP

      IF v_current_date = p_cap_tab.LAST THEN
--	  MRP_UTIL.MRP_TIMING('This is last day of scheduling window.');
        V_FINISH := 1;
	EXIT;
      ELSE
	v_current_date := p_cap_tab.NEXT(v_current_date);
        v_current_cap := p_cap_tab(v_current_date).capacity;
      END IF;
    END LOOP;

    IF v_finish = 1 THEN
	EXIT;
    END IF;

    -- Find out the item that is to be scheduled next.

    v_position := instr(v_pattern,'*');
    v_current_num := TO_NUMBER(RTRIM(SUBSTR(v_pattern,1,v_position),'*'));
    v_pattern := SUBSTR(v_pattern,v_position+1);
    v_sequence := p_demand_tab(p_item_demand_tab(v_current_num).item).sequence;

--     MRP_UTIL.MRP_TIMING('Inside pattern, BEGIN select statement');

    SELECT wip_entity_id,planned_quantity,schedule_group_id
    INTO   v_current_wip,v_planned_quantity,v_schedule_group
    FROM   wip_flow_schedules
    WHERE  primary_item_id = p_item_demand_tab(v_current_num).item
    AND    organization_id = p_org_id
    AND    line_id = p_line_id
    AND    scheduled_flag = C_NO
    AND    build_sequence = v_sequence
    AND    request_id = USERENV('SESSIONID')
    AND    rownum = 1
    AND    wip_entity_id >= G_WIP_ENTITY_ID;

    l_fixed_lead_time := p_item_demand_tab(v_current_num).fixed_lead_time;
    l_variable_lead_time := p_item_demand_tab(v_current_num).var_lead_time;

--      MRP_UTIL.MRP_TIMING('Inside pattern, FINISH select statement');

    V_ERROR_LINE := 6;

    -- Get the next build sequence for the schedule group of the current
    -- flow schedule.

    IF v_schedule_group IS NOT NULL THEN
      v_build_seq :=
      v_build_seq_tab(v_schedule_group).buildseq + 1;
      v_build_seq_tab(v_schedule_group).buildseq := v_build_seq;

    ELSE
      v_build_seq := v_null_build_seq + 1;
      v_null_build_seq := v_build_seq;
    END IF;

    -- If the flow schedule has 1 or less than 1 unit to be scheduled
    IF v_planned_quantity <= 1 THEN

      -- If the capacity is less than what needs to be scheduled

      WHILE v_current_cap < v_planned_quantity LOOP
	IF v_current_date = p_cap_tab.LAST THEN
	  V_FINISH := 1;
	  EXIT;
        ELSE
	  v_current_date := p_cap_tab.NEXT(v_current_date);
	  v_current_cap := p_cap_tab(v_current_date).capacity;
        END IF;
      END LOOP;

      IF v_finish = 1 THEN
	  EXIT;
      END IF;

      -- If there is no entry in the completion time table for the date
      -- initialize it with the start time

      IF p_time_tab.EXISTS(v_current_date) = FALSE THEN
        SELECT start_time
        INTO   v_final_time
        FROM   wip_lines
        WHERE  line_id = p_line_id
        AND  organization_id = p_org_id;

	V_ERROR_LINE := 8;

	p_time_tab(v_current_date).start_completion_time := v_final_time;
      END IF;

      v_required_time := v_planned_quantity*TRUNC(3600/v_hr_line_rate);
      if (p_time_tab(v_current_date).start_completion_time+v_required_time > p_time_tab(v_current_date).end_completion_time) then
        v_required_time := p_time_tab(v_current_date).end_completion_time -
                           p_time_tab(v_current_date).start_completion_time;
      end if;


      v_completion_time := to_date(v_current_date,'J') +
      ((p_time_tab(v_current_date).start_completion_time+v_required_time)/86400);

      l_lead_time := l_fixed_lead_time +
		    (l_variable_lead_time * (v_planned_quantity-1));

      IF l_lead_time = 0 THEN
        v_begin_time := v_completion_time;
      ELSE
        v_begin_time := mrp_line_schedule_algorithm.calculate_begin_time(
				p_org_id,
				v_completion_time,
				l_lead_time,
				v_start_time,
				v_end_time);
      END IF;


      p_time_tab(v_current_date).start_completion_time :=
      p_time_tab(v_current_date).start_completion_time + v_required_time;

--	MRP_UTIL.MRP_TIMING('BEGIN select information');

      SELECT last_update_date, last_updated_by, creation_date, created_by,
	     class_code, status, schedule_number, demand_source_header_id,
	     demand_source_line, demand_source_delivery, demand_source_type,
	     project_id, task_id, end_item_unit_number, attribute1, attribute2, attribute3, attribute4,
             attribute5, attribute6, attribute7, attribute8, attribute9, attribute10,
             attribute11, attribute12, attribute13, attribute14, attribute15,
             material_account, material_overhead_account, resource_account,
             outside_processing_account, material_variance_account, resource_variance_account,
             outside_proc_variance_account, std_cost_adjustment_account, overhead_account,
             overhead_variance_account,bom_revision,routing_revision,/*Added for bug2185087*/
             bom_revision_date, routing_revision_date,
             alternate_bom_designator, alternate_routing_designator,
             completion_subinventory,completion_locator_id,
             demand_class, attribute_category, kanban_card_id
      INTO   v_update_date, v_updated_by, v_creation_date, v_created_by,
	       v_class_code, v_status, v_schedule, v_header_id, v_source_line,
	       v_source_delivery, v_source_type, v_project_id, v_task_id, v_end_item_unit_number, v_attribute1,
             v_attribute2, v_attribute3, v_attribute4,
             v_attribute5, v_attribute6, v_attribute7, v_attribute8, v_attribute9, v_attribute10,
             v_attribute11, v_attribute12, v_attribute13, v_attribute14, v_attribute15,
             v_material_account, v_material_overhead_account, v_resource_account,
             v_outside_processing_account, v_material_variance_account, v_resource_variance_account,
             v_outside_proc_var_account, v_std_cost_adjustment_account, v_overhead_account,
             v_overhead_variance_account,v_bom_revision,v_routing_revision, /* 2185087*/
             v_bom_revision_date, v_routing_revision_date,
             v_alternate_bom_designator,v_alternate_routing_designator,
             v_completion_subinventory, v_completion_locator_id,
             v_demand_class, v_attribute_category,v_kanban_card_id
      FROM   wip_flow_schedules
      WHERE  wip_entity_id = v_current_wip
      AND    organization_id = p_org_id
      AND    request_id = userenv('sessionid')
      AND    wip_entity_id >= G_WIP_ENTITY_ID;

--	MRP_UTIL.MRP_TIMING('BEGIN Insert');


      -- Insert into pl/sql table
      v_flow_schedule_tab(v_current_wip).scheduled_flag := C_YES;
      v_flow_schedule_tab(v_current_wip).organization_id := p_org_id;
      v_flow_schedule_tab(v_current_wip).last_update_date := v_update_date;
      v_flow_schedule_tab(v_current_wip).last_updated_by := v_updated_by;
      v_flow_schedule_tab(v_current_wip).creation_date := v_creation_date;
      v_flow_schedule_tab(v_current_wip).created_by := v_created_by;
      v_flow_schedule_tab(v_current_wip).class_code := v_class_code;
      v_flow_schedule_tab(v_current_wip).line_id := p_line_id;
      v_flow_schedule_tab(v_current_wip).primary_item_id
		:= p_item_demand_tab(v_current_num).item;
      v_flow_schedule_tab(v_current_wip).scheduled_start_date := v_begin_time;
      v_flow_schedule_tab(v_current_wip).planned_quantity := v_planned_quantity;
      v_flow_schedule_tab(v_current_wip).quantity_completed := 0;
      v_flow_schedule_tab(v_current_wip).scheduled_completion_date := v_completion_time;
      v_flow_schedule_tab(v_current_wip).schedule_group_id := v_schedule_group;
      v_flow_schedule_tab(v_current_wip).build_sequence := v_build_seq;
      v_flow_schedule_tab(v_current_wip).status := v_status;
      v_flow_schedule_tab(v_current_wip).schedule_number := v_schedule;
      v_flow_schedule_tab(v_current_wip).demand_source_header_id := v_header_id;
      v_flow_schedule_tab(v_current_wip).demand_source_line := v_source_line;
      v_flow_schedule_tab(v_current_wip).demand_source_delivery := v_source_delivery;
      v_flow_schedule_tab(v_current_wip).demand_source_type := v_source_type;
      v_flow_schedule_tab(v_current_wip).project_id := v_project_id;
      v_flow_schedule_tab(v_current_wip).task_id := v_task_id;
      v_flow_schedule_tab(v_current_wip).end_item_unit_number := v_end_item_unit_number;
      v_flow_schedule_tab(v_current_wip).request_id := userenv('sessionid');
      v_flow_schedule_tab(v_current_wip).attribute1 := v_attribute1;
      v_flow_schedule_tab(v_current_wip).attribute2 := v_attribute2;
      v_flow_schedule_tab(v_current_wip).attribute3 := v_attribute3;
      v_flow_schedule_tab(v_current_wip).attribute4 := v_attribute4;
      v_flow_schedule_tab(v_current_wip).attribute5 := v_attribute5;
      v_flow_schedule_tab(v_current_wip).attribute6 := v_attribute6;
      v_flow_schedule_tab(v_current_wip).attribute7 := v_attribute7;
      v_flow_schedule_tab(v_current_wip).attribute8 := v_attribute8;
      v_flow_schedule_tab(v_current_wip).attribute9 := v_attribute9;
      v_flow_schedule_tab(v_current_wip).attribute10 := v_attribute10;
      v_flow_schedule_tab(v_current_wip).attribute11 := v_attribute11;
      v_flow_schedule_tab(v_current_wip).attribute12 := v_attribute12;
      v_flow_schedule_tab(v_current_wip).attribute13 := v_attribute13;
      v_flow_schedule_tab(v_current_wip).attribute14 := v_attribute14;
      v_flow_schedule_tab(v_current_wip).attribute15 := v_attribute15;
      v_flow_schedule_tab(v_current_wip).material_account := v_material_account;
      v_flow_schedule_tab(v_current_wip).material_overhead_account := v_material_overhead_account;
      v_flow_schedule_tab(v_current_wip).resource_account := v_resource_account;
      v_flow_schedule_tab(v_current_wip).outside_processing_account := v_outside_processing_account;
      v_flow_schedule_tab(v_current_wip).material_variance_account := v_material_variance_account;
      v_flow_schedule_tab(v_current_wip).resource_variance_account := v_resource_variance_account;
      v_flow_schedule_tab(v_current_wip).outside_proc_var_account := v_outside_proc_var_account;
      v_flow_schedule_tab(v_current_wip).std_cost_adjustment_account := v_std_cost_adjustment_account;
      v_flow_schedule_tab(v_current_wip).overhead_account := v_overhead_account;
      v_flow_schedule_tab(v_current_wip).overhead_variance_account := v_overhead_variance_account;
     /* Added for bug 2185087 */
      v_flow_schedule_tab(v_current_wip).bom_revision := v_bom_revision;
      v_flow_schedule_tab(v_current_wip).routing_revision := v_routing_revision;
      v_flow_schedule_tab(v_current_wip).bom_revision_date := v_bom_revision_date;
      v_flow_schedule_tab(v_current_wip).routing_revision_date := v_routing_revision_date;
      v_flow_schedule_tab(v_current_wip).alternate_bom_designator := v_alternate_bom_designator;
      v_flow_schedule_tab(v_current_wip).alternate_routing_designator := v_alternate_routing_designator;
      v_flow_schedule_tab(v_current_wip).completion_subinventory := v_completion_subinventory;
      v_flow_schedule_tab(v_current_wip).completion_locator_id := v_completion_locator_id;
      v_flow_schedule_tab(v_current_wip).demand_class := v_demand_class;
      v_flow_schedule_tab(v_current_wip).attribute_category := v_attribute_category;
      v_flow_schedule_tab(v_current_wip).kanban_card_id := v_kanban_card_id;

--	MRP_UTIL.MRP_TIMING('END insert');

      DELETE
      FROM   wip_flow_schedules
      WHERE  wip_entity_id = v_current_wip
      AND    organization_id = p_org_id;

      V_ERROR_LINE := 9;

      v_current_cap := v_current_cap - v_planned_quantity;
      p_demand_tab(p_item_demand_tab(v_current_num).item).sequence :=
        p_demand_tab(p_item_demand_tab(v_current_num).item).sequence + 1;

    ELSE

      -- Create a new flow schedule since the flow schedule has quantity greater than 1.

      -- If the capacity of the current date is less than 1, then check
      -- capacity of subsequent dates
      WHILE v_current_cap < 1 LOOP
	IF v_current_date = p_cap_tab.LAST THEN
	  V_FINISH := 1;
	  EXIT;
	ELSE
	  v_current_date := p_cap_tab.NEXT(v_current_date);
	  v_current_cap := p_cap_tab(v_current_date).capacity;
	END IF;
      END LOOP;

      IF v_finish = 1 THEN
       	EXIT;
      END IF;

      -- If there is no entry in the completion time table for the date
      -- initialize it with the start time

      IF p_time_tab.EXISTS(v_current_date) = FALSE THEN
        SELECT start_time
        INTO   v_final_time
        FROM   wip_lines
        WHERE  line_id = p_line_id
        AND  organization_id = p_org_id;

	V_ERROR_LINE := 10;

	p_time_tab(v_current_date).start_completion_time := v_final_time;
      END IF;

      v_required_time := TRUNC(3600/v_hr_line_rate);
      if (p_time_tab(v_current_date).start_completion_time+v_required_time > p_time_tab(v_current_date).end_completion_time) then
        v_required_time := p_time_tab(v_current_date).end_completion_time -
                           p_time_tab(v_current_date).start_completion_time;
      end if;

      v_completion_time := to_date(v_current_date,'J') +
      ((p_time_tab(v_current_date).start_completion_time+v_required_time)/86400);

      -- planned quantity will be '1'
      l_lead_time := l_fixed_lead_time ;

      IF l_lead_time = 0 THEN
        v_begin_time := v_completion_time;
      ELSE
        v_begin_time := mrp_line_schedule_algorithm.calculate_begin_time(
				p_org_id,
				v_completion_time,
				l_lead_time,
				v_start_time,
				v_end_time);
      END IF;


      p_time_tab(v_current_date).start_completion_time :=
	p_time_tab(v_current_date).start_completion_time + v_required_time;

      SELECT wip_entities_s.nextval
      INTO   v_temp
      FROM   dual;

      V_ERROR_LINE := 11;

      --Bug 6122344
      --v_schedule_number := NVL(substr(FND_PROFILE.value('WIP_JOB_PREFIX'),1,20),'X')
      --	|| to_char(v_temp);
      v_schedule_number := 'FLM-INTERNAL'|| to_char(v_temp);


--        dbms_output.put_line('The schedule number is: '||v_schedule_number);


--	MRP_UTIL.MRP_TIMING('BEGIN select information');
      SELECT last_update_date, last_updated_by, creation_date, created_by,
	     class_code, status, schedule_number, demand_source_header_id,
	     demand_source_line, demand_source_delivery, demand_source_type,
	     project_id, task_id, end_item_unit_number, attribute1, attribute2, attribute3, attribute4,
             attribute5, attribute6, attribute7, attribute8, attribute9, attribute10,
             attribute11, attribute12, attribute13, attribute14, attribute15,
             material_account, material_overhead_account, resource_account,
             outside_processing_account, material_variance_account, resource_variance_account,
             outside_proc_variance_account, std_cost_adjustment_account, overhead_account,
             overhead_variance_account,bom_revision,routing_revision , /*2185087 */
             bom_revision_date, routing_revision_date,
             alternate_bom_designator, alternate_routing_designator,
             completion_subinventory, completion_locator_id,
             demand_class,attribute_category, kanban_card_id
      INTO   v_update_date, v_updated_by, v_creation_date, v_created_by,
	       v_class_code, v_status, v_schedule, v_header_id, v_source_line,
	       v_source_delivery, v_source_type, v_project_id, v_task_id, v_end_item_unit_number,
             v_attribute1, v_attribute2, v_attribute3, v_attribute4,
             v_attribute5, v_attribute6, v_attribute7, v_attribute8, v_attribute9, v_attribute10,
             v_attribute11, v_attribute12, v_attribute13, v_attribute14, v_attribute15,
             v_material_account, v_material_overhead_account, v_resource_account,
             v_outside_processing_account, v_material_variance_account, v_resource_variance_account,
             v_outside_proc_var_account, v_std_cost_adjustment_account, v_overhead_account,
             v_overhead_variance_account,v_bom_revision,v_routing_revision, /*2185087*/
             v_bom_revision_date, v_routing_revision_date,
             v_alternate_bom_designator,v_alternate_routing_designator,
             v_completion_subinventory, v_completion_locator_id,
             v_demand_class, v_attribute_category, v_kanban_card_id
      FROM   wip_flow_schedules
      WHERE  wip_entity_id = v_current_wip
      AND    organization_id = p_org_id;

--	MRP_UTIL.MRP_TIMING('BEGIN insert');

      -- Insert into pl/sql table

      v_flow_schedule_tab(v_temp).scheduled_flag := C_YES;
      v_flow_schedule_tab(v_temp).organization_id := p_org_id;
      v_flow_schedule_tab(v_temp).last_update_date := v_update_date;
      v_flow_schedule_tab(v_temp).last_updated_by := v_updated_by;
      v_flow_schedule_tab(v_temp).creation_date := v_creation_date;
      v_flow_schedule_tab(v_temp).created_by := v_created_by;
      v_flow_schedule_tab(v_temp).class_code := v_class_code;
      v_flow_schedule_tab(v_temp).line_id := p_line_id;
      v_flow_schedule_tab(v_temp).primary_item_id := p_item_demand_tab(v_current_num).item;
      v_flow_schedule_tab(v_temp).scheduled_start_date := v_begin_time;
      v_flow_schedule_tab(v_temp).planned_quantity := 1;
      v_flow_schedule_tab(v_temp).quantity_completed := 0;
      v_flow_schedule_tab(v_temp).scheduled_completion_date := v_completion_time;
      v_flow_schedule_tab(v_temp).schedule_group_id := v_schedule_group;
      v_flow_schedule_tab(v_temp).build_sequence := v_build_seq;
      v_flow_schedule_tab(v_temp).status := v_status;
      v_flow_schedule_tab(v_temp).schedule_number := v_schedule_number;
      v_flow_schedule_tab(v_temp).demand_source_header_id := v_header_id;
      v_flow_schedule_tab(v_temp).demand_source_line := v_source_line;
      v_flow_schedule_tab(v_temp).demand_source_delivery := v_source_delivery;
      v_flow_schedule_tab(v_temp).demand_source_type := v_source_type;
      v_flow_schedule_tab(v_temp).project_id := v_project_id;
      v_flow_schedule_tab(v_temp).task_id := v_task_id;
      v_flow_schedule_tab(v_temp).end_item_unit_number := v_end_item_unit_number;
      v_flow_schedule_tab(v_temp).request_id := userenv('sessionid');
      v_flow_schedule_tab(v_temp).attribute1 := v_attribute1;
      v_flow_schedule_tab(v_temp).attribute2 := v_attribute2;
      v_flow_schedule_tab(v_temp).attribute3 := v_attribute3;
      v_flow_schedule_tab(v_temp).attribute4 := v_attribute4;
      v_flow_schedule_tab(v_temp).attribute5 := v_attribute5;
      v_flow_schedule_tab(v_temp).attribute6 := v_attribute6;
      v_flow_schedule_tab(v_temp).attribute7 := v_attribute7;
      v_flow_schedule_tab(v_temp).attribute8 := v_attribute8;
      v_flow_schedule_tab(v_temp).attribute9 := v_attribute9;
      v_flow_schedule_tab(v_temp).attribute10 := v_attribute10;
      v_flow_schedule_tab(v_temp).attribute11 := v_attribute11;
      v_flow_schedule_tab(v_temp).attribute12 := v_attribute12;
      v_flow_schedule_tab(v_temp).attribute13 := v_attribute13;
      v_flow_schedule_tab(v_temp).attribute14 := v_attribute14;
      v_flow_schedule_tab(v_temp).attribute15 := v_attribute15;
      v_flow_schedule_tab(v_temp).material_account := v_material_account;
      v_flow_schedule_tab(v_temp).material_overhead_account := v_material_overhead_account;
      v_flow_schedule_tab(v_temp).resource_account := v_resource_account;
      v_flow_schedule_tab(v_temp).outside_processing_account := v_outside_processing_account;
      v_flow_schedule_tab(v_temp).material_variance_account := v_material_variance_account;
      v_flow_schedule_tab(v_temp).resource_variance_account := v_resource_variance_account;
      v_flow_schedule_tab(v_temp).outside_proc_var_account := v_outside_proc_var_account;
      v_flow_schedule_tab(v_temp).std_cost_adjustment_account := v_std_cost_adjustment_account;
      v_flow_schedule_tab(v_temp).overhead_account := v_overhead_account;
      v_flow_schedule_tab(v_temp).overhead_variance_account := v_overhead_variance_account;
      v_flow_schedule_tab(v_temp).bom_revision := v_bom_revision; /*2185087 */
      v_flow_schedule_tab(v_temp).routing_revision := v_routing_revision;
      v_flow_schedule_tab(v_temp).bom_revision_date := v_bom_revision_date;
      v_flow_schedule_tab(v_temp).routing_revision_date := v_routing_revision_date;
      v_flow_schedule_tab(v_temp).alternate_bom_designator := v_alternate_bom_designator;
      v_flow_schedule_tab(v_temp).alternate_routing_designator := v_alternate_routing_designator;
      v_flow_schedule_tab(v_temp).completion_subinventory := v_completion_subinventory;
      v_flow_schedule_tab(v_temp).completion_locator_id := v_completion_locator_id;
      v_flow_schedule_tab(v_temp).demand_class := v_demand_class;
      v_flow_schedule_tab(v_temp).attribute_category := v_attribute_category;
      v_flow_schedule_tab(v_temp).kanban_card_id := v_kanban_card_id;



--	MRP_UTIL.MRP_TIMING('end insert');

      UPDATE wip_flow_schedules
      SET    planned_quantity = planned_quantity - 1
      WHERE  wip_entity_id = v_current_wip
      AND    organization_id = p_org_id;

--	MRP_UTIL.MRP_TIMING('end update');

      V_ERROR_LINE := 12;

    -- Decrement capacity on the line for the current date by the scheduled quantity.

    v_current_cap := v_current_cap - 1;

    END IF;


--    dbms_output.put_line('Capacity on '||to_date(v_current_date,'J')||' = '||
--	  to_char(v_current_cap));

  END LOOP;

  -- Insert flow schedules from pl/sql table to wip flow schedules table.

  v_current_schedule := v_flow_schedule_tab.FIRST;

--    MRP_UTIL.MRP_TIMING('BEGIN INSERTING INTO wip flow schedules table');

  WHILE v_current_schedule IS NOT NULL LOOP

--    MRP_UTIL.MRP_TIMING('Begin insert');

    INSERT INTO wip_flow_schedules(
				scheduled_flag,
				wip_entity_id,
				organization_id,
				last_update_date,
				last_updated_by,
				creation_date,
				created_by,
				class_code,
				line_id,
				primary_item_id,
				scheduled_start_date,
				planned_quantity,
				quantity_completed,
				quantity_scrapped,
				scheduled_completion_date,
				schedule_group_id,
				build_sequence,
				status,
				schedule_number,
				demand_source_header_id,
				demand_source_line,
				demand_source_delivery,
				demand_source_type,
				project_id,
				task_id,
				end_item_unit_number,
                                request_id,
                                attribute1,
                                attribute2,
                                attribute3,
                                attribute4,
                                attribute5,
                                attribute6,
                                attribute7,
                                attribute8,
                                attribute9,
                                attribute10,
                                attribute11,
                                attribute12,
                                attribute13,
                                attribute14,
                                attribute15,
                                material_account,
                                material_overhead_account,
                                resource_account,
                                outside_processing_account,
                                material_variance_account,
                                resource_variance_account,
                                outside_proc_variance_account,
                                std_cost_adjustment_account,
                                overhead_account,
                                overhead_variance_account,
                                bom_revision,   /* 2185087 */
                                routing_revision,
                                bom_revision_date,
                                routing_revision_date,
                                alternate_bom_designator,
                                alternate_routing_designator,
                                completion_subinventory,
                                completion_locator_id,
                                demand_class,
                                attribute_category,
                                kanban_card_id)
    VALUES (
				v_flow_schedule_tab(v_current_schedule).scheduled_flag,
				v_current_schedule,
				v_flow_schedule_tab(v_current_schedule).organization_id,
				v_flow_schedule_tab(v_current_schedule).last_update_date,
				v_flow_schedule_tab(v_current_schedule).last_updated_by,
				v_flow_schedule_tab(v_current_schedule).creation_date,
				v_flow_schedule_tab(v_current_schedule).created_by,
				v_flow_schedule_tab(v_current_schedule).class_code,
				v_flow_schedule_tab(v_current_schedule).line_id,
				v_flow_schedule_tab(v_current_schedule).primary_item_id,
				v_flow_schedule_tab(v_current_schedule).scheduled_start_date,
				v_flow_schedule_tab(v_current_schedule).planned_quantity,
				v_flow_schedule_tab(v_current_schedule).quantity_completed,
				0,
				v_flow_schedule_tab(v_current_schedule).scheduled_completion_date,
				v_flow_schedule_tab(v_current_schedule).schedule_group_id,
				v_flow_schedule_tab(v_current_schedule).build_sequence,
				v_flow_schedule_tab(v_current_schedule).status,
				v_flow_schedule_tab(v_current_schedule).schedule_number,
				v_flow_schedule_tab(v_current_schedule).demand_source_header_id,
				v_flow_schedule_tab(v_current_schedule).demand_source_line,
				v_flow_schedule_tab(v_current_schedule).demand_source_delivery,
				v_flow_schedule_tab(v_current_schedule).demand_source_type,
				v_flow_schedule_tab(v_current_schedule).project_id,						   v_flow_schedule_tab(v_current_schedule).task_id,
				v_flow_schedule_tab(v_current_schedule).end_item_unit_number,
                                userenv('sessionid'),
                                v_flow_schedule_tab(v_current_schedule).attribute1,
                                v_flow_schedule_tab(v_current_schedule).attribute2,
                                v_flow_schedule_tab(v_current_schedule).attribute3,
                                v_flow_schedule_tab(v_current_schedule).attribute4,
                                v_flow_schedule_tab(v_current_schedule).attribute5,
                                v_flow_schedule_tab(v_current_schedule).attribute6,
                                v_flow_schedule_tab(v_current_schedule).attribute7,
                                v_flow_schedule_tab(v_current_schedule).attribute8,
                                v_flow_schedule_tab(v_current_schedule).attribute9,
                                v_flow_schedule_tab(v_current_schedule).attribute10,
                                v_flow_schedule_tab(v_current_schedule).attribute11,
                                v_flow_schedule_tab(v_current_schedule).attribute12,
                                v_flow_schedule_tab(v_current_schedule).attribute13,
                                v_flow_schedule_tab(v_current_schedule).attribute14,
                                v_flow_schedule_tab(v_current_schedule).attribute15,
                                v_flow_schedule_tab(v_current_schedule).material_account,
                                v_flow_schedule_tab(v_current_schedule).material_overhead_account,
                                v_flow_schedule_tab(v_current_schedule).resource_account,
                                v_flow_schedule_tab(v_current_schedule).outside_processing_account,
                                v_flow_schedule_tab(v_current_schedule).material_variance_account,
                                v_flow_schedule_tab(v_current_schedule).resource_variance_account,
                                v_flow_schedule_tab(v_current_schedule).outside_proc_var_account,
                                v_flow_schedule_tab(v_current_schedule).std_cost_adjustment_account,
                                v_flow_schedule_tab(v_current_schedule).overhead_account,
                                v_flow_schedule_tab(v_current_schedule).overhead_variance_account,
                                v_flow_schedule_tab(v_current_schedule).bom_revision, /*2185087*/
                                v_flow_schedule_tab(v_current_schedule).routing_revision,
                                v_flow_schedule_tab(v_current_schedule).bom_revision_date,
                                v_flow_schedule_tab(v_current_schedule).routing_revision_date,
                                v_flow_schedule_tab(v_current_schedule).alternate_bom_designator,
                                v_flow_schedule_tab(v_current_schedule).alternate_routing_designator,
                                v_flow_schedule_tab(v_current_schedule).completion_subinventory,
                                v_flow_schedule_tab(v_current_schedule).completion_locator_id,
                                v_flow_schedule_tab(v_current_schedule).demand_class,
                                v_flow_schedule_tab(v_current_schedule).attribute_category,
                                v_flow_schedule_tab(v_current_schedule).kanban_card_id

);
--      MRP_UTIL.MRP_TIMING('End of insert into wip flow schedules.');

    v_current_schedule := v_flow_schedule_tab.NEXT(v_current_schedule);

  END LOOP;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (dbms_sql.is_open(cursor_name)) THEN
    dbms_sql.close_cursor(cursor_name);
    END IF;

    RETURN;

  WHEN OTHERS THEN

    IF (dbms_sql.is_open(cursor_name)) THEN
      dbms_sql.close_cursor(cursor_name);
    END IF;

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(
	V_PKG_NAME,V_PROCEDURE_NAME||': Line '||to_char(V_ERROR_LINE));
    END IF;

    return;

END schedule_mix_model;

-- This procedure schedules the new flow schedules created from
-- unscheduled orders on the line within the defined scheduling window.

PROCEDURE Schedule(
	             p_rule_id  IN NUMBER,
             	     p_line_id  IN NUMBER,
             	     p_org_id   IN NUMBER,
             	     p_scheduling_start_date IN DATE,
             	     p_scheduling_end_date   IN DATE,
             	     p_flex_tolerance   IN NUMBER,
		     x_return_status OUT NOCOPY VARCHAR2,
		     x_msg_count OUT NOCOPY NUMBER,
  		     x_msg_data  OUT NOCOPY VARCHAR2)
IS

  v_algorithm      	NUMBER;
  v_start_date     	NUMBER;
  v_end_date       	NUMBER;
  v_cap_tab        	CapTabTyp;
  v_itemQty_tab	   	ItemQtyTabTyp;
  v_orderMod_tab   	OrderModTabTyp;
  v_item_alloc_tab 	ItemAllocTabTyp;
  v_early_date	   	DATE;
  v_num_flow       	NUMBER;
  v_item_id	   	NUMBER;
  v_order_quantity 	NUMBER;
  i 		   	NUMBER;
  v_source_type	   	NUMBER;
  v_current_item   	NUMBER;
  v_remain_qty	   	NUMBER;
  v_alloc_qty	   	NUMBER;
  v_item_demand_tab 	ItemDemandTabTyp;
  v_demand_tab	   	DemandTabTyp;
  v_time_tab            TimeTabTyp;
  v_start_time		NUMBER;
  v_end_time		NUMBER;
  v_bom_rev             VARCHAR2(3); /* Added for bug 2977987 */
  v_bom_rev_date        DATE;
  v_rout_rev            VARCHAR2(3);
  v_rout_rev_date       DATE;

BEGIN

  SAVEPOINT MRP_begin_PVT;

  V_PROCEDURE_NAME := 'Schedule';
  V_ERROR_LINE := 1;

  -- Lets convert the schedule dates to julian format
  SELECT to_number(to_char(p_scheduling_start_date,'J')),
         to_number(to_char(p_scheduling_end_date,'J')),
         to_char(p_scheduling_start_date,'SSSSS'),
         to_char(p_scheduling_end_date,'SSSSS')
  INTO   v_start_date, v_end_date, v_start_time, v_end_time
  FROM   dual;

  -- Get the minimum wip_entity_id that having request id

  SELECT MIN(wip_entity_id)
  INTO G_WIP_ENTITY_ID
  FROM wip_flow_schedules
  WHERE line_id = p_line_id
    and organization_id = p_org_id
    and request_id =  USERENV('SESSIONID');

  -- Time stamp the existing flow schedules
  time_existing_fs(p_org_id, p_line_id, v_start_date, v_start_time,
                   v_end_date, v_end_time,  v_time_tab);

  -- First off, lets find the net capacity of the line in question
  -- Note that this procedure populates the plsql table

--  MRP_UTIL.MRP_TIMING('Before calculating line capacity ...');

  calculate_linecap(
        p_line_id,
        p_org_id,
        p_flex_tolerance,
        v_cap_tab,
        v_time_tab,
	v_start_date,
	v_start_time,
	v_end_date,
	v_end_time);

--  dbms_output.put_line('Hi there!!!');

--  MRP_UTIL.MRP_TIMING('After calculating line capacity ...');

  --Check the algorithm associated with the scheduling rule

  SELECT DISTINCT heuristic_code
  INTO   v_algorithm
  FROM   mrp_scheduling_rules
  WHERE  rule_id = p_rule_id
  AND    NVL(user_defined,C_USER_DEFINE_NO) = C_USER_DEFINE_NO ;

  V_ERROR_LINE := 2;

  -- Check for the mode of operation or type of unscheduled orders,
  -- Sales Orders or Planned Orders

  SELECT demand_source_type
    INTO   v_source_type
    FROM   wip_flow_schedules
    WHERE  request_id = USERENV('SESSIONID')
      AND  organization_id = p_org_id
      AND  scheduled_flag = C_NO
      AND  rownum = 1
      AND  wip_entity_id >= G_WIP_ENTITY_ID;

  V_ERROR_LINE := 3;

--  MRP_UTIL.MRP_TIMING('Before calculating demand and round type for each item');
  -- Calculate demand and find round type for all items

  calculate_demand(p_line_id, p_org_id, v_demand_tab);

--  MRP_UTIL.MRP_TIMING('After calculating demand and round type for each item');

  IF v_algorithm = C_NO_LEVEL_LOAD THEN
--   dbms_output.put_line('Algorithm is no level load');

    -- If source type is sales orders

    IF v_source_type IN (C_INT_SALES_ORDER,C_EXT_SALES_ORDER) THEN
--      dbms_output.put_line('Source type is SALES ORDERS');

      -- round up planned quantities of all flow schedules which are fractional
      -- with round attribute = yes.

      rounding_process(p_org_id, p_line_id, p_rule_id, v_demand_tab);

--      dbms_output.put_line('Scheduling...');
      schedule_orders(p_line_id, p_org_id, p_rule_id, v_cap_tab, v_demand_tab,
			v_time_tab);

    END IF;

    -- IF demand source of the flow schedules is planned orders, order modifiers
    -- will be applied.

    IF v_source_type = C_PLANNED_ORDER THEN

--	Find round type for all items
	calculate_demand(p_line_id, p_org_id, v_demand_tab);

--      dbms_output.put_line('Source type is PLANNED ORDERS');

      -- Calculate the order quantities for each item based on order modifiers
      -- that have associated unscheduled flow schedules.

--      dbms_output.put_line('Calculating order quantities...');
      calculate_order_quantities(p_org_id, v_orderMod_tab);

      -- Create new flow schedules to replace the original ones to respect order
      -- modifiers.

--      dbms_output.put_line('Creating new flow schedules with order modifiers');
      create_po_fs(p_org_id, p_line_id, p_rule_id, v_orderMod_tab);

      -- round up planned quantities of all flow schedules which are fractional
      -- with round attribute = yes.

      rounding_process(p_org_id, p_line_id, p_rule_id, v_demand_tab);

      -- NOW, we need to sequence the flow schedules and then schedule them.
      -- The algorithm used here is same as that used for sales orders.
--      dbms_output.put_line('Scheduling...');

       schedule_orders(p_line_id, p_org_id, p_rule_id, v_cap_tab, v_demand_tab,
			v_time_tab);

    END IF;
  ELSIF v_algorithm = C_LEVEL_LOAD THEN
--    dbms_output.put_line('Algorithm is level load');

    IF v_source_type IN (C_INT_SALES_ORDER,C_EXT_SALES_ORDER) THEN
--      dbms_output.put_line('Source type is SALES ORDERS');

      -- round up planned quantities of all flow schedules which are fractional
      -- with round attribute = yes.
--      dbms_output.put_line('Rounding...');
      rounding_process(p_org_id, p_line_id, p_rule_id, v_demand_tab);

      -- Schedule sales orders to match the production rate by updating
      -- the scheduled completion date and the build sequence for the
      -- schedule group.  If only a partial flow schedule quantity is
      -- required to fill the production rate, then the flow schedule
      -- will be split into more than one flow schedules.

--      dbms_output.put_line('Scheduling...');
      schedule_orders_level(p_line_id, p_org_id, p_rule_id, v_cap_tab,
				v_time_tab);

--      dbms_output.put_line('updatiing build sequences...');
      update_buildseq(p_line_id, p_org_id);

    ELSIF v_source_type = C_PLANNED_ORDER THEN

--      dbms_output.put_line('Source type is PLANNED ORDERS');

      -- Calculate the order quantities for each item based on order modifiers
      -- that have associated unscheduled flow schedules.

--      dbms_output.put_line('Calculating order modifier quantities...');
--      dbms_output.put_line('Calculating order modifier quantities...');

      calculate_order_quantities(p_org_id, v_orderMod_tab);

      -- Create new flow schedules to replace the original ones to respect order
      -- modifiers.

--      dbms_output.put_line('Creating new flow schedules with order modifier quantities.');

--      dbms_output.put_line('Creating new flow schedules with order modifier quantities.');
      create_po_fs(p_org_id, p_line_id, p_rule_id, v_orderMod_tab);

      -- round up planned quantities of all flow schedules which are fractional
      -- with round attribute = yes.

      rounding_process(p_org_id, p_line_id, p_rule_id, v_demand_tab);
--      dbms_output.put_line('Scheduling ...');
      schedule_orders_level(p_line_id, p_org_id, p_rule_id, v_cap_tab, v_time_tab);

--     dbms_output.put_line('updateing build sequences...');
     update_buildseq(p_line_id, p_org_id);

    END IF;
  ELSIF v_algorithm = C_MIXED_MODEL THEN

--    MRP_UTIL.MRP_TIMING('Beginning of MIX MODEL ALGORITHM');

--    dbms_output.put_line('Algorithm is mixed model');

    -- In the mixed model algorithm, flow schedules from sales orders and
    -- planned orders are manipulated in the same manner.  A manufacturing
    -- pattern of items is first established based on the demand of each
    -- item with respect to the total demand of all unscheduled flow schedules.
    -- The flow schedules are then scheduled respecting this pattern and
    -- the order of the flow schedules which is established using the user-
    -- chosen criteria.

    -- Round up planned quantities of all flow schedules which are fractional
    -- with round attribute = yes for the item.

--    MRP_UTIL.MRP_TIMING('Before Rounding Process');

    rounding_process(p_org_id, p_line_id, p_rule_id, v_demand_tab);

    -- Calculate total demand for each item

--    MRP_UTIL.MRP_TIMING('Before Calculating total demand for each item');

    calculate_demand_mix(p_line_id, p_org_id, v_item_demand_tab);

--    MRP_UTIL.MRP_TIMING('After Calculating total demand for each item');
    schedule_mix_model(p_line_id, p_org_id, p_rule_id, v_cap_tab, v_demand_tab,
		v_item_demand_tab, v_time_tab);

  END IF;

  -- Delete all flow schedules which have not been scheduled within the
  -- scheduling window.

  DELETE
  FROM   wip_flow_schedules
  WHERE  scheduled_flag = C_NO
    AND  request_id = USERENV('SESSIONID')
    AND  organization_id = p_org_id
    AND  wip_entity_id >= G_WIP_ENTITY_ID;


  /* Start of fix for bug 2977987: We get each flow schedule record
     scheduled in the present run, set bom and routing revision dates
     to its scheduled_completion_date and then re-calculate the
     effective bom and routing revisions active on that date */

   FOR fs_list_rec IN fs_list(p_line_id,p_org_id) LOOP

     v_bom_rev_date := NULL;
     v_bom_rev := NULL;
     v_rout_rev_date := NULL;
     v_rout_rev := NULL;
     v_item_id := fs_list_rec.primary_item_id;

     if (fs_list_rec.bom_revision_date is not null) then

       v_bom_rev_date := fs_list_rec.scheduled_completion_date;

       BOM_REVISIONS.Get_Revision(
         type          => 'PART',
         eco_status    => 'EXCLUDE_OPEN_HOLD',
         examine_type  => 'ALL',
         org_id        => p_org_id,
         item_id       => v_item_id,
         rev_date      => v_bom_rev_date,
         itm_rev       => v_bom_rev);

     end if;

     if (fs_list_rec.routing_revision_date is not null) then

       v_rout_rev_date := fs_list_rec.scheduled_completion_date;

       BOM_REVISIONS.Get_Revision(
         type          => 'PROCESS',
         eco_status    => 'EXCLUDE_OPEN_HOLD',
         examine_type  => 'ALL',
         org_id        => p_org_id,
         item_id       => v_item_id,
         rev_date      => v_rout_rev_date,
         itm_rev       => v_rout_rev);

     end if;

     UPDATE wip_flow_schedules
        SET bom_revision = v_bom_rev,
            bom_revision_date = v_bom_rev_date,
            routing_revision = v_rout_rev,
            routing_revision_date = v_rout_rev_date
      WHERE wip_entity_id = fs_list_rec.wip_entity_id
        AND organization_id = p_org_id;

  END LOOP;

  /* End of fix for bug 2977987 */

  V_ERROR_LINE := 4;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

--  dbms_output.put_line('End of Scheduling...');

--  MRP_UTIL.MRP_TIMING('End of Scheduling');

EXCEPTION

  WHEN OTHERS THEN
    ROLLBACK TO MRP_begin_PVT;

--    dbms_output.put_line('There is an error!!!!');

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(
	V_PKG_NAME,V_PROCEDURE_NAME||': Line '||to_char(V_ERROR_LINE));
    END IF;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--    dbms_output.put_line('!!!ERROR!!!:' || to_char(sqlcode) ||
--              substr(sqlerrm,1,60));
    FND_MSG_PUB.Count_And_Get
		(p_count 	=>	x_msg_count,
		 p_data		=>	x_msg_data
		);
    return;
END Schedule;


-- This function calculates proper schedule start time
-- based on completion_date, completion_time, and lead_time.
-- All time formats are Julian calendar format.
FUNCTION calculate_begin_time(
		p_org_id	IN NUMBER,
		p_completion_date IN DATE,
		p_lead_time	IN NUMBER,
		p_start_time	IN NUMBER,
		p_end_time	IN NUMBER) RETURN DATE IS
  l_completion_time NUMBER;
  l_completion_date DATE;
  l_begin_date	 DATE;
  l_working_time NUMBER;
  l_lead_time	 NUMBER;
  l_offset_time	 NUMBER;
  l_temp_date	 DATE;
  l_end_time     NUMBER;
BEGIN


  l_completion_date := trunc(p_completion_date);
  l_completion_time := to_char(p_completion_date,'SSSSS');

  l_end_time := p_end_time;
  if (p_end_time <= p_start_time) then
    if (l_completion_time < l_end_time ) then
      l_completion_date := trunc(p_completion_date)-1;
      l_completion_time := to_char(p_completion_date,'SSSSS')+24*3600;
    end if;
    l_end_time := l_end_time + 24*3600;
  end if;


  -- total working hrs in workday
  l_working_time := l_end_time - p_start_time;



  -- exclude workable time in completion_date from lead_time
  l_lead_time := (p_lead_time*l_working_time) - (l_completion_time-p_start_time);
  if (l_lead_time <= 0) then
    l_lead_time := p_lead_time*l_working_time;
    l_temp_date := trunc(l_completion_date);
    l_end_time := l_completion_time;
  else
    -- find out the schedule start_date based on the offset
    -- first, we find out the offset date and then use MOD function
    -- to find out the offset time
    l_temp_date := mrp_calendar.date_offset(
                        p_org_id,
                        1,  -- daily bucket
                        l_completion_date,
                        -ceil(l_lead_time/l_working_time));
  end if;


  -- find out specific time to start
  -- exception case, when lead_time is same as working_hrs
  -- MOD function will return '0', thus, offset_time should be start_time
  /*Bugfix:8785150.Changed below if condition to include the cases when l_lead_time is multiple of l_working_time */
  IF /* l_lead_time = l_working_time */ (mod(l_lead_time,l_working_time) = 0) THEN
    l_offset_time := p_start_time;
  ELSE
    l_offset_time := l_end_time - mod(l_lead_time, l_working_time);

  END IF;

  l_begin_date := l_temp_date + l_offset_time/86400;

  return l_begin_date;

END calculate_begin_time;

FUNCTION calculate_completion_time(
		p_org_id	IN NUMBER,
		p_item_id	IN NUMBER,
		p_qty		IN NUMBER,
		p_line_id	IN NUMBER,
		p_start_date	IN DATE) RETURN DATE IS
  l_lead_time	NUMBER;
  l_fixed_time	NUMBER;
  l_variable_time NUMBER;/*Added for bugfix:7211657 */
  l_line_start_time 	NUMBER;
  l_line_end_time 	NUMBER;
  l_working_time NUMBER;
  l_time 	NUMBER;
  l_date DATE;
  l_offset_time NUMBER;
  l_offset_day NUMBER;
  l_remain_time NUMBER;
  l_start_time NUMBER;
  l_start_date DATE;
  l_sec_rate NUMBER; -- time to produce 1 quantity in seconds
BEGIN

  l_start_date := trunc(p_start_date);
  l_start_time := to_char(p_start_date,'SSSSS');

  select start_time, stop_time, 3600/maximum_rate
  into l_line_start_time, l_line_end_time, l_sec_rate
  from wip_lines
  where organization_id = p_org_id
    and line_id = p_line_id;

  if (l_line_end_time <= l_line_start_time) then
    l_line_end_time := l_line_end_time + 24*3600;
  end if;

  l_working_time := l_line_end_time - l_line_start_time;

  /*Changed the query to fetch variable_lead_time also for bug fix 7211657 */

  select NVL(fixed_lead_time,0)*l_working_time,NVL(variable_lead_time,0)*l_working_time
  into l_fixed_time,l_variable_time
  from mtl_system_items
  where organization_id = p_org_id
    and inventory_item_id = p_item_id;

 -- l_lead_time := l_fixed_time;
 /*Changed lead time calculation for bugfix:7211657 */
    l_lead_time := l_fixed_time + ((p_qty-1)*l_variable_time);
  -- l_date and l_time to store the possible start date and time

  -- get the first workday. If it's not the same as p_start_date, need
  -- to move it to next workday and also set the l_time to start of line
  l_date := mrp_calendar.next_work_day(p_org_id,1,p_start_date);
  if (trunc(l_start_date) <>  trunc(l_date)) then
    l_time := l_line_start_time;
  else
    l_time := l_start_time;
    if (l_time > l_line_start_time) then
      l_time := l_line_start_time + ceil((l_time-l_line_start_time)/l_sec_rate)*l_sec_rate;
    end if;
  end if;

  -- If the l_time greater than the end time of line, move it to the
  -- workday at the line start time
  -- If l_time less than the start of line, move the start time to
  -- line start time of the day.
  -- If it's between start and end time of line, use up the line and
  -- move to next workday.
  if (l_time > l_line_end_time) then
    l_date := mrp_calendar.next_work_day(p_org_id,1,l_date+1);
    l_time := l_line_start_time;
  elsif (l_time < l_line_start_time) then
    l_time := l_line_start_time;
  else
    l_remain_time := l_line_end_time-l_time;
    if (l_lead_time - l_remain_time > 0) then
      l_lead_time := l_lead_time - l_remain_time;
      l_date := mrp_calendar.next_work_day(p_org_id,1,l_date+1);
      l_time := l_line_start_time;
    end if;
  end if;


  if l_lead_time = l_working_time then
    l_offset_time := l_line_end_time;
    l_offset_day := l_lead_time/l_working_time - 1;
  else
    l_offset_time := l_time + mod(l_lead_time, l_working_time);
    l_offset_day := floor(l_lead_time/l_working_time);
  end if;

  l_date := mrp_calendar.date_offset(
                        p_org_id,
                        1,  -- daily bucket
                        l_date,
                        l_offset_day);


  if (l_offset_time = l_line_start_time and l_fixed_time <> 0) then
    l_date := mrp_calendar.prev_work_day(p_org_id,1,l_date-1);
    l_offset_time := l_line_end_time;
  end if;

  return ( l_date + l_offset_time/86400 );

END calculate_completion_time;

END;

/
