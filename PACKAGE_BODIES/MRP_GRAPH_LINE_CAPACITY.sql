--------------------------------------------------------
--  DDL for Package Body MRP_GRAPH_LINE_CAPACITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_GRAPH_LINE_CAPACITY" AS
/* $Header: MRPGLCPB.pls 115.20 2003/09/15 17:42:44 hwenas ship $ */

PROCEDURE LOAD_CAPACITY_RECORDS(p_plan_id IN	NUMBER,
			    p_line_id	 IN	NUMBER,
			    p_org_id	 IN	NUMBER,
			    p_start_date IN	DATE)
IS

   CURSOR DATE_CURSOR(p_org_id NUMBER,
				p_line_id NUMBER,
				p_start_date DATE)
   IS
   SELECT distinct cal.calendar_date
   FROM mtl_parameters mp,
        bom_calendar_dates cal
   WHERE mp.organization_id = p_org_id
   AND cal.calendar_date >= p_start_date
   AND cal.seq_num IS NOT NULL
   AND mp.calendar_exception_set_id = cal.exception_set_id
   AND mp.calendar_code = cal.calendar_code
   UNION ALL
   SELECT distinct cal.calendar_date
   FROM mtl_parameters mp,
        mrp_line_sch_avail_v ls,
        bom_calendar_dates cal
   WHERE mp.organization_id = p_org_id
   AND ls.line_id = p_line_id
   AND cal.calendar_date >= p_start_date
   AND ((ls.planned_quantity - nvl(ls.quantity_completed,0)) > 0 and
        cal.seq_num IS NULL)
   AND cal.calendar_date = ls.scheduled_completion_date
   AND ls.organization_id = p_org_id
   AND mp.calendar_exception_set_id = cal.exception_set_id
   AND mp.calendar_code = cal.calendar_code;


   CURSOR MRP_AVAIL_CAPACITY_CURSOR(p_org_id NUMBER,
				p_dept_id NUMBER,
                                p_res_id NUMBER,
                                p_query_id NUMBER)
   IS
   SELECT bdr.department_id,
          bdr.resource_id,
          -1,			-- line_id
          mfq.number1,
          cal.calendar_date,
          decode(cal.seq_num, NULL, 0,
		nvl(sum(decode(bdr.available_24_hours_flag,1,24,
		((decode(least(shifts.to_time,shifts.from_time),
		shifts.to_time,shifts.to_time + 24*3600,
		shifts.to_time) - shifts.from_time)/3600))),0))
   FROM   bom_calendar_dates cal,
          bom_department_resources bdr,
          bom_resource_shifts brs,
          bom_shift_times shifts,
          mtl_parameters mp,
          mrp_form_query mfq
   WHERE  bdr.department_id = p_dept_id
   AND    bdr.resource_id = p_res_id
   AND    bdr.department_id = brs.department_id(+)
   AND    bdr.resource_id = brs.resource_id(+)
   AND    brs.shift_num = shifts.shift_num(+)
   AND    (mp.calendar_code = shifts.calendar_code
          OR shifts.calendar_code IS NULL)
   AND    cal.seq_num IS NOT NULL
   AND    cal.exception_set_id = mp.calendar_exception_set_id
   AND    cal.calendar_code = mp.calendar_code
   AND    mp.organization_id = p_org_id
   AND    trunc(cal.calendar_date) = mfq.date1
   AND    mfq.query_id = p_query_id
   GROUP BY bdr.department_id,
          bdr.resource_id,
          mfq.number1,
          cal.calendar_date,
          cal.seq_num;

   CURSOR MRP_CAPACITY_CURSOR(p_line_id NUMBER,
				p_org_id NUMBER,
                                p_query_id NUMBER,
				p_uom_class VARCHAR2)
   IS
   SELECT bos.department_id,
          br.resource_id,
          -1,			-- line_id
          mfq.number1,
          cal_start.calendar_date,
          sum(br.usage_rate_or_amount * (nvl(bos1.net_planning_percent, 100)/100) /
	      nvl(bos1.reverse_cumulative_yield, 1) *   /*Fix for bug 2000775*/
              decode(br.basis_type,1,ls.planned_quantity -
                     nvl(ls.quantity_completed,0) , 2, 1))
   FROM   bom_calendar_dates cal_start,
          bom_calendar_dates cal_order,
          mtl_system_items items,
          mtl_parameters mp,
          mrp_form_query mfq,
          bom_operation_resources br,
          bom_operation_sequences bos,
          bom_operation_sequences bos1,
	  bom_resources bre,
	  mtl_units_of_measure muom,
          bom_operational_routings bor,
          mrp_line_sch_avail_v ls
   WHERE  ls.line_id = p_line_id
   AND    ls.organization_id = p_org_id
   AND    nvl(ls.alternate_routing_designator,'@!#')
		 = nvl(bor.alternate_routing_designator,'@!#')
   AND    bor.line_id = ls.line_id
   AND    bor.assembly_item_id = ls.primary_item_id
   AND    bor.organization_id = ls.organization_id
   AND    bos.routing_sequence_id = bor.routing_sequence_id
   AND    bos.operation_type = 1
   AND    bos1.operation_sequence_id = bos.line_op_seq_id
   AND    br.operation_sequence_id = bos.operation_sequence_id
--   AND    br.schedule_flag <> 2
   AND    br.resource_id = bre.resource_id
   AND    bre.unit_of_measure = muom.uom_code
   AND    muom.uom_class = p_uom_class
   AND 	  cal_start.exception_set_id = cal_order.exception_set_id
   AND    cal_start.calendar_code = cal_order.calendar_code
   AND    cal_start.seq_num = (cal_order.prior_seq_num -
                        CEIL((1 - NVL(br.resource_offset_percent,0)) *
		 	(NVL(items.fixed_lead_time,0) +
			(NVL(items.variable_lead_time,0) *
			NVL(ls.planned_quantity,0)))))
   AND    cal_order.exception_set_id = mp.calendar_exception_set_id
   AND    cal_order.calendar_code = mp.calendar_code
   AND    cal_order.calendar_date = trunc(ls.scheduled_completion_date)
   AND    mp.organization_id = ls.organization_id
   AND    items.organization_id = ls.organization_id
   AND    items.inventory_item_id = ls.primary_item_id
   AND    trunc(ls.scheduled_completion_date) = mfq.date1
   AND    mfq.query_id = p_query_id
   GROUP BY bos.department_id,
          br.resource_id,
          mfq.number1,
          cal_start.calendar_date
   UNION
   SELECT -1,			-- department_id
	-1,			-- resource_id
	ls.line_id,
        mfq.number1,
	mfq.date1,
	sum(ls.planned_quantity - nvl(ls.quantity_completed,0))
   FROM mrp_form_query mfq,
	mrp_line_sch_avail_v ls
   WHERE ls.organization_id = p_org_id
   AND ls.line_id = p_line_id
   AND    trunc(ls.scheduled_completion_date) = mfq.date1
   AND    mfq.query_id = p_query_id
   GROUP BY -1,-1,
	ls.line_id,
        mfq.number1,
	mfq.date1;

  -- Fix bug 939061, add 24 hrs to stop_time if stop_time <= start_time
  CURSOR LINE_CURSOR IS
  SELECT NVL(maximum_rate * ((decode(least(stop_time,start_time),stop_time,stop_time+24*3600,stop_time)-start_time)/3600),0)
  FROM wip_lines
  WHERE line_id = p_line_id
  AND organization_id = p_org_id;

  l_last_dept_id	NUMBER := -5;
  l_last_res_id		NUMBER := -5;
  l_last_line_id	NUMBER := -5;
  l_max_rate		NUMBER := 0;
  l_bucket_number	NUMBER := 0;
  l_bucket_date		DATE;
  l_query_id		NUMBER;
  temp_uom              VARCHAR2(3);/* Fix for bug 2000775*/
  temp_conv_rate        NUMBER := 1;
  temp_base_uom         VARCHAR2(3);
  capacity_rec  	MRP_CAPACITY;
  capacity_rec2  	MRP_CAPACITY;
  qty_cells_tab 	BUCKET_NUMBER;  -- Holds the quantities for each bucket
  date_cells_tab 	BUCKET_DATE;    -- Holds the dates for each bucket

  l_uom_code	VARCHAR2(3);
  l_uom_class	VARCHAR2(10);

PROCEDURE flush_dept_res_rec(p_dept_id IN NUMBER,
				p_res_id IN NUMBER,
				p_local_line_id IN NUMBER,
				p_supply_demand IN NUMBER) IS

BEGIN

  INSERT INTO MRP_MATERIAL_PLANS (
	plan_id,			-- unique identifier
	plan_organization_id,		-- line_id
        inventory_item_id,		-- resource_id
        organization_id,		-- department_id
        item_segments,			-- description
	horizontal_plan_type,		-- type
	last_update_date,
	last_updated_by,
	creation_date,
	created_by,
	quantity1, quantity2, quantity3, quantity4, quantity5, quantity6,
	quantity7, quantity8, quantity9, quantity10, quantity11, quantity12,
	quantity13, quantity14, quantity15, quantity16, quantity17, quantity18,
 	quantity19, quantity20, quantity21, quantity22, quantity23, quantity24,
	quantity25, quantity26, quantity27, quantity28, quantity29, quantity30,
	quantity31, quantity32, quantity33, quantity34, quantity35, quantity36,
	compile_designator,		-- not used
 	bucket_type			-- not used
  ) values (
        p_plan_id,
	p_local_line_id,
	p_res_id,
	p_dept_id,
	' ',
	p_supply_demand,
	sysdate,
	-1,
	sysdate,
	-1,
	qty_cells_tab(1), qty_cells_tab(2), qty_cells_tab(3),
	qty_cells_tab(4), qty_cells_tab(5), qty_cells_tab(6),
	qty_cells_tab(7), qty_cells_tab(8), qty_cells_tab(9),
	qty_cells_tab(10), qty_cells_tab(11), qty_cells_tab(12),
	qty_cells_tab(13), qty_cells_tab(14), qty_cells_tab(15),
	qty_cells_tab(16), qty_cells_tab(17), qty_cells_tab(18),
	qty_cells_tab(19), qty_cells_tab(20), qty_cells_tab(21),
	qty_cells_tab(22), qty_cells_tab(23), qty_cells_tab(24),
	qty_cells_tab(25), qty_cells_tab(26), qty_cells_tab(27),
	qty_cells_tab(28), qty_cells_tab(29), qty_cells_tab(30),
	qty_cells_tab(31), qty_cells_tab(32), qty_cells_tab(33),
	qty_cells_tab(34), qty_cells_tab(35), qty_cells_tab(36),
	' ',
	0
	);

END flush_dept_res_rec;

PROCEDURE flush_date_rec IS
BEGIN

  INSERT INTO MRP_WORKBENCH_BUCKET_DATES(
	organization_id,	-- plan_id
	compile_designator,	-- not used
	bucket_type,		-- not used
	last_update_date, last_updated_by, creation_date, created_by,
	date1, date2, date3, date4, date5, date6, date7, date8, date9,
	date10, date11, date12, date13, date14, date15, date16, date17, date18,
	date19, date20, date21, date22, date23, date24, date25, date26, date27,
	date28, date29, date30, date31, date32, date33, date34, date35, date36
  ) VALUES (
	p_plan_id,
	' ',
	1,
	sysdate, -1, sysdate, -1,
	date_cells_tab(1), date_cells_tab(2), date_cells_tab(3),
	date_cells_tab(4), date_cells_tab(5), date_cells_tab(6),
	date_cells_tab(7), date_cells_tab(8), date_cells_tab(9),
	date_cells_tab(10), date_cells_tab(11), date_cells_tab(12),
	date_cells_tab(13), date_cells_tab(14), date_cells_tab(15),
	date_cells_tab(16), date_cells_tab(17), date_cells_tab(18),
	date_cells_tab(19), date_cells_tab(20), date_cells_tab(21),
	date_cells_tab(22), date_cells_tab(23), date_cells_tab(24),
	date_cells_tab(25), date_cells_tab(26), date_cells_tab(27),
	date_cells_tab(28), date_cells_tab(29), date_cells_tab(30),
	date_cells_tab(31), date_cells_tab(32), date_cells_tab(33),
	date_cells_tab(34), date_cells_tab(35), date_cells_tab(36)
  );

END flush_date_rec;

PROCEDURE initialize_counter IS
BEGIN

  -- ------------------------------------------
  -- Initialize bucket cells to 0
  -- ------------------------------------------
  FOR counter IN 1..NUM_OF_COLUMNS LOOP
    qty_cells_tab(counter) := 0;
  END LOOP;

END initialize_counter;

PROCEDURE initialize_dates IS
BEGIN

  -- ------------------------------------------
  -- Initialize bucket cells to NULL
  -- ------------------------------------------
  FOR counter IN 1..NUM_OF_COLUMNS LOOP
    date_cells_tab(counter) := NULL;
  END LOOP;

END initialize_dates;

PROCEDURE get_resource_avail(l_org_id NUMBER,
				l_dept_id NUMBER,
				l_res_id NUMBER,
				l_query_id NUMBER) IS
temp_cap_units number ;/*fix for bug 2000775*/
BEGIN

  OPEN MRP_AVAIL_CAPACITY_CURSOR(l_org_id, l_dept_id, l_res_id, l_query_id);

  LOOP
    FETCH MRP_AVAIL_CAPACITY_CURSOR INTO capacity_rec2;
    EXIT WHEN MRP_AVAIL_CAPACITY_CURSOR%ROWCOUNT = 0;

    IF mrp_avail_capacity_cursor%NOTFOUND
    THEN

      -- ------------------------------------------
      -- Flush the record for the previous dept/res
      -- ------------------------------------------
      flush_dept_res_rec(l_dept_id,
			l_res_id,
			-1,
			1);

    END IF;

    -- --------------------------------------------
    -- Set the value for the bucket
    -- --------------------------------------------
   /* Fix for bug 2000775*/
    select capacity_units
    into temp_cap_units
    from bom_department_resources
    where department_id = l_dept_id
        and resource_id = l_res_id;

    qty_cells_tab(capacity_rec2.bucket_number) := capacity_rec2.bucket_qty *
    temp_cap_units;

    EXIT WHEN MRP_AVAIL_CAPACITY_CURSOR%NOTFOUND;

  END LOOP;

  CLOSE MRP_AVAIL_CAPACITY_CURSOR;

END get_resource_avail;

BEGIN

  -- Load and flush the dates
  initialize_dates;

  -- Get the query_id
  SELECT mrp_form_query_s.nextval
  INTO l_query_id
  FROM dual;

   -- We want to show all valid working days and non-working days
   -- with quantities.  Use the cursor to get the correct dates
   -- and load them into the array for updating.
  OPEN DATE_CURSOR(p_org_id, p_line_id, p_start_date);

  LOOP
    FETCH DATE_CURSOR INTO l_bucket_date;
    EXIT WHEN DATE_CURSOR%NOTFOUND;

    l_bucket_number := l_bucket_number + 1;

    -- Load the dates into mrp_workbench_bucket_dates so that the
    -- form can select them into the flat file.
    date_cells_tab(l_bucket_number) := l_bucket_date;

    -- Insert the dates into mrp_form_query so that we can join
    -- to it in MRP_CAPACITY_CURSOR to get the appropriate bucket
    -- numbers.
    INSERT INTO MRP_FORM_QUERY(QUERY_ID, LAST_UPDATE_DATE,
	LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, DATE1,
	NUMBER1)
    VALUES(l_query_id, sysdate, -1, sysdate, -1,
	l_bucket_date, l_bucket_number);

    EXIT WHEN l_bucket_number = 36;
  END LOOP;

  CLOSE DATE_CURSOR;

  flush_date_rec;

  -- Load line availability

  initialize_counter;

  OPEN LINE_CURSOR;

  FETCH LINE_CURSOR INTO l_max_rate;

  -- Set each bucket to the max rate
  FOR counter IN 1..NUM_OF_COLUMNS LOOP
    qty_cells_tab(counter) := l_max_rate;
  END LOOP;

  CLOSE LINE_CURSOR;

  -- Flush the record
  l_last_line_id := p_line_id;

  flush_dept_res_rec(-1,
			-1,
			l_last_line_id,
			1);

  -- Reinitialize variables and load line and dept/res demand
  l_last_line_id := -5;
  l_last_dept_id := -5;
  l_last_res_id	 := -5;
  initialize_counter;

  l_uom_code := FND_PROFILE.value('BOM:HOUR_UOM_CODE');
  select uom_class
  into l_uom_class
  from mtl_units_of_measure
  where uom_code = l_uom_code;
  OPEN MRP_CAPACITY_CURSOR(p_line_id, p_org_id, l_query_id, l_uom_class);

  LOOP
    FETCH MRP_CAPACITY_CURSOR
    INTO capacity_rec;
    IF (MRP_CAPACITY_CURSOR%ROWCOUNT = 0 and l_last_line_id = -5) THEN
      -- Enter a line record with all zeros
      flush_dept_res_rec(-1,
				-1,
				p_line_id,
				2);
    END IF;
    EXIT WHEN MRP_CAPACITY_CURSOR%ROWCOUNT = 0;

    IF ((mrp_capacity_cursor%NOTFOUND) OR
	(capacity_rec.department_id <> l_last_dept_id) OR
	(capacity_rec.resource_id <> l_last_res_id) OR
	(capacity_rec.line_id <> l_last_line_id)) AND
	l_last_dept_id <> -5 AND l_last_res_id <> -5 AND
        l_last_line_id <> -5
    THEN

      -- ------------------------------------------
      -- Flush the record for the previous dept/res
      -- ------------------------------------------
      flush_dept_res_rec(l_last_dept_id,
			l_last_res_id,
			l_last_line_id,
			2);

      initialize_counter;

      -- --------------------------------------------
      -- Create availability record for this dept/res
      -- --------------------------------------------
      get_resource_avail(p_org_id, l_last_dept_id,
			l_last_res_id, l_query_id);

      initialize_counter;
    END IF;

    -- --------------------------------------------
    -- Set the value for the bucket
    -- --------------------------------------------
   /*fix for bug 2000775*/
    l_last_res_id := capacity_rec.resource_id;
    IF (l_last_res_id <> -1 ) Then
      select unit_of_measure into temp_uom from bom_resources
      where resource_id = l_last_res_id;
      FND_PROFILE.get('BOM:HOUR_UOM_CODE',temp_base_uom);
      inv_convert.inv_um_conversion(temp_uom,temp_base_uom,0,temp_conv_rate);
    END IF;
    qty_cells_tab(capacity_rec.bucket_number) := capacity_rec.bucket_qty * temp_conv_rate ;
    l_last_dept_id := capacity_rec.department_id;
    l_last_line_id := capacity_rec.line_id;

    EXIT WHEN MRP_CAPACITY_CURSOR%NOTFOUND;

  END LOOP;

  CLOSE MRP_CAPACITY_CURSOR;

END LOAD_CAPACITY_RECORDS;

END MRP_GRAPH_LINE_CAPACITY;

/
