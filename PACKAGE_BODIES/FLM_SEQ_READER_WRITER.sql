--------------------------------------------------------
--  DDL for Package Body FLM_SEQ_READER_WRITER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FLM_SEQ_READER_WRITER" AS
/* $Header: FLMSQRWB.pls 120.3.12010000.2 2008/08/08 07:39:44 bgaddam ship $ */


/******************************************************************
 * To get a list of working days for a period (start, end)        *
 * and put them in a global pl/sql table - g_days                 *
 * The day will be in Julian format                               *
 ******************************************************************/
PROCEDURE Init_Working_Days(p_organization_id IN NUMBER,
			    p_start_date IN NUMBER,
			    p_end_date IN NUMBER,
			    x_err_code OUT NOCOPY NUMBER,
			    x_err_msg OUT NOCOPY VARCHAR
			    ) IS
   l_cnt NUMBER := 0;
   l_start_date DATE;
   l_end_date DATE;
   l_date DATE;

Begin

   x_err_code := 0;

   l_start_date := wip_datetimes.float_to_dt(p_start_date);
   l_end_date := wip_datetimes.float_to_dt(p_end_date);

   if (not flm_timezone.is_init) then
     flm_timezone.init_timezone(p_organization_id);
   end if;

   l_start_date := flm_timezone.server_to_calendar(l_start_date);
   l_end_date := flm_timezone.server_to_calendar(l_end_date);

   l_start_date := MRP_CALENDAR.NEXT_WORK_DAY(p_organization_id, 1, l_start_date);

   l_cnt := MRP_CALENDAR.DAYS_BETWEEN(p_organization_id,
				      1,
				      l_start_date,
				      l_end_date
				      );
   l_cnt := l_cnt + 1;

   l_date := l_start_date-1;

   FOR l_index IN 1..l_cnt LOOP
      l_date := MRP_CALENDAR.NEXT_WORK_DAY(p_organization_id, 1, l_date+1);
      g_days(l_index) := wip_datetimes.dt_to_float(l_date);
   END LOOP;

   g_days_index := 1;
   x_err_code := l_cnt;

EXCEPTION
   WHEN OTHERS THEN
      x_err_msg := 'Unexpected SQL Error: '||sqlerrm;
      x_err_code := -1;

End Init_Working_Days;



/******************************************************************
 * To get a working day list at a size of p_batch_size            *
 ******************************************************************/
PROCEDURE Get_Working_Days(
			   p_batch_size IN NUMBER,
			   x_days OUT NOCOPY number_tbl_type,
			   x_found IN OUT NOCOPY NUMBER,
			   x_done_flag OUT NOCOPY INTEGER,
			   x_err_code OUT NOCOPY NUMBER,
			   x_err_msg OUT NOCOPY VARCHAR
			   ) IS
  l_size NUMBER := 0;
Begin

  x_err_code := 0;
  x_found := 0;
  x_done_flag := 0;

  WHILE (g_days_index <= g_days.COUNT and l_size < p_batch_size) LOOP
    x_days(l_size+1) := g_days(g_days_index);
    g_days_index := g_days_index + 1;
    l_size := l_size + 1;
  END LOOP;

  x_found := l_size;

  if (g_days_index > g_days.COUNT) then
    x_done_flag := 1;
  end if;

EXCEPTION
   WHEN OTHERS THEN
      x_err_msg := 'Unexpected SQL Error: '||sqlerrm;
      x_err_code := -1;

End Get_Working_Days;



/******************************************************************
 * To get available build sequence range for a period (start,end) *
 * The range (start_seq, end_seq) is an open interval (exclusive) *
 ******************************************************************/
PROCEDURE Get_BuildSeq_Range(p_line_id IN NUMBER,
			     p_organization_id IN NUMBER,
			     p_start_date IN NUMBER,
			     p_end_date IN NUMBER,
			     x_start_seq OUT NOCOPY NUMBER,
			     x_end_seq OUT NOCOPY NUMBER,
			     x_err_code OUT NOCOPY NUMBER,
			     x_err_msg OUT NOCOPY VARCHAR
			     ) IS

   l_min NUMBER;
   l_max NUMBER;

   l_date1 DATE;
   l_date2 DATE;

   l_start_date DATE;
   l_end_date DATE;

   l_found INTEGER;
   l_days INTEGER;

   CURSOR max_seq_cursor IS
      SELECT
	max(BUILD_SEQUENCE)
      FROM
	WIP_FLOW_SCHEDULES
      WHERE
        ORGANIZATION_ID = p_organization_id AND
        LINE_ID = p_line_id AND
	SCHEDULED_COMPLETION_DATE <= l_date1;

   CURSOR min_seq_cursor IS
      SELECT
	min(BUILD_SEQUENCE)
      FROM
	WIP_FLOW_SCHEDULES
      WHERE
        ORGANIZATION_ID = p_organization_id AND
        LINE_ID = p_line_id AND
	SCHEDULED_COMPLETION_DATE > l_date2;


Begin

   x_err_code := 0;
   x_start_seq := -1;
   x_end_seq := -1;

   l_start_date := wip_datetimes.float_to_dt(p_start_date);
   l_date1 := l_start_date;


   l_found := 0;

   OPEN max_seq_cursor;

   FETCH max_seq_cursor INTO l_max;

   if (max_seq_cursor%FOUND and l_max is not null) then
      l_found := 1;
   end if;

   CLOSE max_seq_cursor;

   if (l_found <> 0 and l_max is not null) then
      x_start_seq := l_max;
   else
      x_start_seq := -1;
   end if;

   l_end_date := wip_datetimes.float_to_dt(p_end_date);
   l_date2 := l_end_date;


   l_found := 0;

   OPEN min_seq_cursor;

   FETCH min_seq_cursor INTO l_min;

   if (min_seq_cursor%FOUND and l_min is not null) then
      l_found := 1;
   end if;

   CLOSE min_seq_cursor;

   if (l_found <> 0 and l_min is not null) then
      x_end_seq := l_min;
   else
      x_end_seq := -1;
   end if;


EXCEPTION
   WHEN OTHERS THEN
      x_err_msg := 'Unexpected SQL Error: '||sqlerrm;
      x_err_code := -1;
      x_start_seq := -1;
      x_end_seq := -1;

End Get_BuildSeq_Range;

/******************************************************************
 * To initialize globals used by db writer                        *
 ******************************************************************/
FUNCTION initialize_globals return NUMBER IS
l_return_status NUMBER;
BEGIN
  g_job_prefix := substr(FND_PROFILE.value('WIP_JOB_PREFIX'),1,20);
  g_login_id := FND_GLOBAL.login_id;
  g_user_id := FND_GLOBAL.user_id;
  sch_rec_tbl.DELETE;
  g_cto_line_tbl.DELETE;

  BEGIN
    MRP_WFS_Form_Flow_Schedule.get_default_dff(l_return_status,
      g_attribute1,g_attribute2,g_attribute3,
      g_attribute4,g_attribute5,g_attribute6,
      g_attribute7,g_attribute8,g_attribute9,
      g_attribute10,g_attribute11,g_attribute12,
      g_attribute13,g_attribute14,g_attribute15);
  EXCEPTION
    when others then
      null;
  END;

  return 0;

EXCEPTION
  when others then
    return 1;

END;


/******************************************************************
 * To add a schedule in schedules table and return wip_id and     *
 * schedule number                                                *
 ******************************************************************/
PROCEDURE add_sch_rec(i_org_id NUMBER,
                      i_primary_item_id NUMBER,
                      i_line_id NUMBER,
                      i_sch_start_date DATE,
                      i_sch_completion_date DATE,
                      i_planned_quantity NUMBER,
                      i_alt_rtg_designator VARCHAR2,
                      i_build_sequence NUMBER,
                      i_schedule_group_id NUMBER,
                      i_demand_type NUMBER,
                      i_demand_id NUMBER,
                      x_wip_entity_id IN OUT NOCOPY NUMBER,
                      x_schedule_number IN OUT NOCOPY VARCHAR2,
                      o_return_code OUT NOCOPY NUMBER
                      )IS
l_index NUMBER;
l_wip_entity_id NUMBER;
l_schedule_number VARCHAR2(30);

l_schedule_group_id NUMBER;
BEGIN
  o_return_code := 0;

  --get the current number of elements in table
  l_index := sch_rec_tbl.COUNT;

  --get the position to insert current record
  l_index := l_index + 1;

  if( i_schedule_group_id = -1 ) then
    l_schedule_group_id := null;
  else
    l_schedule_group_id := i_schedule_group_id;
  end if;

  sch_rec_tbl(l_index).org_id := i_org_id;
  sch_rec_tbl(l_index).primary_item_id := i_primary_item_id;
  sch_rec_tbl(l_index).line_id := i_line_id;
  sch_rec_tbl(l_index).planned_quantity := i_planned_quantity;
  sch_rec_tbl(l_index).alt_rtg_designator := i_alt_rtg_designator;
  sch_rec_tbl(l_index).sch_start_date := i_sch_start_date;
  sch_rec_tbl(l_index).sch_completion_date := i_sch_completion_date;
  sch_rec_tbl(l_index).sch_group_id := l_schedule_group_id;
  sch_rec_tbl(l_index).build_sequence := i_build_sequence;
  sch_rec_tbl(l_index).demand_type := i_demand_type;
  sch_rec_tbl(l_index).demand_id := i_demand_id;

  --get the wip_entity_id and schedule_number for current schedule
  get_wip_id_and_sch_num(l_wip_entity_id, l_schedule_number);

  --populate current record with wip_id and schedule_number
  sch_rec_tbl(l_index).wip_entity_id := l_wip_entity_id;
  sch_rec_tbl(l_index).schedule_number := l_schedule_number;

  --prepare out values with wip_id and schdule_number for this schedule
  x_wip_entity_id := l_wip_entity_id;
  x_schedule_number := l_schedule_number;

  o_return_code := 0;
  return;

  EXCEPTION
  when others then
    o_return_code := 1;
    return;

END add_sch_rec;


/******************************************************************
 * To default the schedule columns and inserting the schedules    *
 ******************************************************************/
PROCEDURE create_schedules (o_return_code OUT NOCOPY NUMBER) IS
l_return_code NUMBER;
l_sch_tbl_to_insert wip_flow_schedule_tbl;
BEGIN
  o_return_code := 0;

  default_attributes(sch_rec_tbl, l_sch_tbl_to_insert, l_return_code);
  if(l_return_code = 1) then
    o_return_code := 1;
    return;
  end if;

  insert_schedules(l_sch_tbl_to_insert, l_return_code);
  if(l_return_code = 1) then
    o_return_code := 1;
    return;
  end if;

  explode_all_items(l_sch_tbl_to_insert,l_return_code);
  if(l_return_code = 1) then
    o_return_code := 1;
    return;
  end if;

  update_mrp_recommendations(l_sch_tbl_to_insert,l_return_code);
  if(l_return_code = 1) then
    o_return_code := 1;
    return;
  end if;

  call_cto_api(l_return_code);
  if(l_return_code = 1) then
    o_return_code := 1;
    return;
  end if;

  o_return_code := 0;
  return;

EXCEPTION
  WHEN OTHERS THEN
    o_return_code := 1;
    return;

END create_schedules;


/******************************************************************
 * To default/derive the attribute which are not passed for this  *
 * schedule and copy the attributes which are passed              *
 ******************************************************************/
PROCEDURE default_attributes(sch_rec_tbl IN OUT NOCOPY schedule_rec_tbl_type,
                             l_sch_tbl_to_insert IN OUT NOCOPY wip_flow_schedule_tbl,
                             o_return_code OUT NOCOPY NUMBER) IS
  l_index NUMBER;
  l_wip_entity_id NUMBER;
  l_sch_number VARCHAR2(30);
  l_class_code VARCHAR2(10);
BEGIN
  o_return_code := 0;
  l_index := sch_rec_tbl.FIRST;

  if(sch_rec_tbl.COUNT > 0) then LOOP
    --first copy the passed parameters
    l_sch_tbl_to_insert(l_index).primary_item_id :=
      sch_rec_tbl(l_index).primary_item_id;

    l_sch_tbl_to_insert(l_index).organization_id :=
      sch_rec_tbl(l_index).org_id;

    l_sch_tbl_to_insert(l_index).planned_quantity :=
      sch_rec_tbl(l_index).planned_quantity;

    l_sch_tbl_to_insert(l_index).alternate_routing_designator :=
      sch_rec_tbl(l_index).alt_rtg_designator;

    l_sch_tbl_to_insert(l_index).scheduled_start_date :=
      sch_rec_tbl(l_index).sch_start_date;

    l_sch_tbl_to_insert(l_index).scheduled_completion_date :=
      sch_rec_tbl(l_index).sch_completion_date;

    l_sch_tbl_to_insert(l_index).schedule_group_id :=
      sch_rec_tbl(l_index).sch_group_id;

    if(sch_rec_tbl(l_index).build_sequence = -1) then
      l_sch_tbl_to_insert(l_index).build_sequence := null;
    else
      l_sch_tbl_to_insert(l_index).build_sequence :=
        sch_rec_tbl(l_index).build_sequence;
    end if;

    l_sch_tbl_to_insert(l_index).line_id :=
      sch_rec_tbl(l_index).line_id;

    l_sch_tbl_to_insert(l_index).demand_source_type :=
      sch_rec_tbl(l_index).demand_type;

    if( (sch_rec_tbl(l_index).demand_type = g_demand_type_SO ) OR
        (sch_rec_tbl(l_index).demand_type = g_demand_type_PO ) ) then
      l_sch_tbl_to_insert(l_index).demand_source_line :=
        to_char(sch_rec_tbl(l_index).demand_id);
    end if;

    l_sch_tbl_to_insert(l_index).wip_entity_id :=
      sch_rec_tbl(l_index).wip_entity_id;

    l_sch_tbl_to_insert(l_index).schedule_number :=
      sch_rec_tbl(l_index).schedule_number;

    --default who_columns
    l_sch_tbl_to_insert(l_index).last_update_date := sysdate;
    l_sch_tbl_to_insert(l_index).last_updated_by := g_user_id;
    l_sch_tbl_to_insert(l_index).creation_date := sysdate;
    l_sch_tbl_to_insert(l_index).created_by := g_user_id;
    l_sch_tbl_to_insert(l_index).last_update_login := g_login_id;

    --default columns with constant values
    l_sch_tbl_to_insert(l_index).scheduled_flag := 1;
    l_sch_tbl_to_insert(l_index).status := 1;
    l_sch_tbl_to_insert(l_index).quantity_completed := 0;
    l_sch_tbl_to_insert(l_index).quantity_scrapped := 0;

    --default columns which will be null
    l_sch_tbl_to_insert(l_index).date_closed := null;
   /* Commented out for bug 6358519 .
     This would be derived from the demand
    l_sch_tbl_to_insert(l_index).project_id := null;
    l_sch_tbl_to_insert(l_index).task_id := null;*/
    l_sch_tbl_to_insert(l_index).kanban_card_id := null;

    --default the descriptive flex columns
    l_sch_tbl_to_insert(l_index).attribute1 := g_attribute1;
    l_sch_tbl_to_insert(l_index).attribute2 := g_attribute2;
    l_sch_tbl_to_insert(l_index).attribute3 := g_attribute3;
    l_sch_tbl_to_insert(l_index).attribute4 := g_attribute4;
    l_sch_tbl_to_insert(l_index).attribute5 := g_attribute5;
    l_sch_tbl_to_insert(l_index).attribute6 := g_attribute6;
    l_sch_tbl_to_insert(l_index).attribute7 := g_attribute7;
    l_sch_tbl_to_insert(l_index).attribute8 := g_attribute8;
    l_sch_tbl_to_insert(l_index).attribute9 := g_attribute9;
    l_sch_tbl_to_insert(l_index).attribute10 := g_attribute10;
    l_sch_tbl_to_insert(l_index).attribute11 := g_attribute11;
    l_sch_tbl_to_insert(l_index).attribute12 := g_attribute12;
    l_sch_tbl_to_insert(l_index).attribute13 := g_attribute13;
    l_sch_tbl_to_insert(l_index).attribute14 := g_attribute14;
    l_sch_tbl_to_insert(l_index).attribute15 := g_attribute15;

    --get class code
    l_class_code := get_class_code(l_sch_tbl_to_insert(l_index).organization_id,
                                   l_sch_tbl_to_insert(l_index).primary_item_id);
    l_sch_tbl_to_insert(l_index).class_code := l_class_code;

    --once class code is obtained, get account_ids
    get_account_ids (l_sch_tbl_to_insert(l_index).organization_id,
                     l_sch_tbl_to_insert(l_index).class_code,
                     l_sch_tbl_to_insert(l_index).material_account,
                     l_sch_tbl_to_insert(l_index).material_overhead_account,
                     l_sch_tbl_to_insert(l_index).resource_account,
                     l_sch_tbl_to_insert(l_index).outside_processing_account,
                     l_sch_tbl_to_insert(l_index).material_variance_account,
                     l_sch_tbl_to_insert(l_index).resource_variance_account,
                     l_sch_tbl_to_insert(l_index).outside_proc_variance_account,
                     l_sch_tbl_to_insert(l_index).std_cost_adjustment_account,
                     l_sch_tbl_to_insert(l_index).overhead_account,
                     l_sch_tbl_to_insert(l_index).overhead_variance_account);

    --get the bom_revision and bom_revision_date
    get_bom_rev_and_date(l_sch_tbl_to_insert(l_index).organization_id,
                         l_sch_tbl_to_insert(l_index).primary_item_id,
                         l_sch_tbl_to_insert(l_index).scheduled_completion_date,
                         l_sch_tbl_to_insert(l_index).bom_revision,
                         l_sch_tbl_to_insert(l_index).bom_revision_date);

    --get the routing_revision and routing_revision_date
    get_rtg_rev_and_date(l_sch_tbl_to_insert(l_index).organization_id,
                         l_sch_tbl_to_insert(l_index).primary_item_id,
                         l_sch_tbl_to_insert(l_index).scheduled_completion_date,
                         l_sch_tbl_to_insert(l_index).routing_revision,
                         l_sch_tbl_to_insert(l_index).routing_revision_date);

    --get the alternate bom_designator
    get_alt_bom_designator(l_sch_tbl_to_insert(l_index).organization_id,
                           l_sch_tbl_to_insert(l_index).primary_item_id,
                           l_sch_tbl_to_insert(l_index).alternate_routing_designator,
                           l_sch_tbl_to_insert(l_index).alternate_bom_designator);

    --fix bug#4045737 (forward port of bug#4011166)
    --added missing defaulting
    --get the completion subinventory and locator
    get_completion_subinv_and_loc(l_sch_tbl_to_insert(l_index).organization_id,
                                  l_sch_tbl_to_insert(l_index).primary_item_id,
                                  l_sch_tbl_to_insert(l_index).alternate_routing_designator,
                                  l_sch_tbl_to_insert(l_index).completion_subinventory,
                                  l_sch_tbl_to_insert(l_index).completion_locator_id);
    --end of fix bug#4045737

    --get the demand class and demand header
    get_demand_class(sch_rec_tbl(l_index).demand_type,
                     sch_rec_tbl(l_index).demand_id,
                     l_sch_tbl_to_insert(l_index).demand_class,
                     l_sch_tbl_to_insert(l_index).demand_source_header_id);

    -- bug 6358519
    -- Added this method to get the project and task
    -- get the project and task
    get_project_task(sch_rec_tbl(l_index).demand_type ,
                     sch_rec_tbl(l_index).demand_id,
                     l_sch_tbl_to_insert(l_index).project_id,
                     l_sch_tbl_to_insert(l_index).task_id);
     --end of fix bug#6358519

    l_sch_tbl_to_insert(l_index).request_id := USERENV('SESSIONID');

    EXIT WHEN l_index = sch_rec_tbl.LAST;
    l_index := sch_rec_tbl.next(l_index);

    END LOOP;
  end if;

EXCEPTION
  WHEN OTHERS THEN
    o_return_code := 1;
    return;

END default_attributes;


/******************************************************************
 * gets the wip_entity_id and schedule_number from sequence       *
 ******************************************************************/
PROCEDURE get_wip_id_and_sch_num (o_wip_entity_id OUT NOCOPY NUMBER,
                                  o_schedule_number OUT NOCOPY VARCHAR2)IS
l_wip_entity_id NUMBER;
l_schedule_number_out VARCHAR2(30);
l_error NUMBER;

BEGIN
  SELECT wip_entities_s.nextval
  INTO   l_wip_entity_id
  FROM   dual;

  o_wip_entity_id := l_wip_entity_id;

  l_schedule_number_out := NULL;
  l_error := wip_flow_derive.schedule_number(l_schedule_number_out);
  if (l_error = 1) then
    o_schedule_number := l_schedule_number_out;
  else
    raise NO_DATA_FOUND;
  end if;

EXCEPTION when others then
  raise;



END get_wip_id_and_sch_num;


/******************************************************************
 * gets the demand class based on demand type                     *
 ******************************************************************/
PROCEDURE get_demand_class(i_demand_type NUMBER,
                           i_demand_id NUMBER,
                           o_demand_class IN OUT NOCOPY VARCHAR2,
                           o_demand_header IN OUT NOCOPY NUMBER ) IS
l_demand_class VARCHAR2(30) := NULL;
l_demand_header NUMBER;
l_header NUMBER;
BEGIN
    /*
    for planned order: can pass null for class code
    for sales order: get oe_order_lines_all.demand_class_code
    for existing:
    */
  if(i_demand_type = g_demand_type_SO) then
    SELECT demand_class_code,header_id
    INTO   l_demand_class, l_demand_header
    FROM   OE_ORDER_LINES_ALL
    WHERE  line_id = i_demand_id;

    if(l_demand_header IS NOT NULL) then
      l_header := inv_salesorder.get_salesorder_for_oeheader(l_demand_header);
    end if;
    o_demand_class := l_demand_class;
    o_demand_header := l_header;
  end if;

END get_demand_class;

/******************************************************************
 * gets the project id based on demand id  Added for Bug 6358519  *
 ******************************************************************/
PROCEDURE get_project_task(i_demand_type NUMBER,
                           i_demand_id NUMBER,
                           o_project_id IN OUT NOCOPY NUMBER,
                           o_task_id IN OUT NOCOPY NUMBER ) IS
l_project_id NUMBER;
l_task_id NUMBER;

BEGIN

  if(i_demand_type = g_demand_type_SO) then
    SELECT project_id,task_id
    INTO   l_project_id, l_task_id
    FROM   OE_ORDER_LINES_ALL
    WHERE  line_id = i_demand_id;

    o_project_id := l_project_id;
    o_task_id := l_task_id;

  end if;

  EXCEPTION
   WHEN NO_DATA_FOUND THEN

    o_project_id := NULL;
    o_task_id := NULL;

END get_project_task;

/******************************************************************
 * To get the completion subinventory and locator                 *
 ******************************************************************/
PROCEDURE get_completion_subinv_and_loc (i_org_id NUMBER,
                                         i_primary_item_id NUMBER,
                                         i_alt_rtg_designator VARCHAR2,
                                         o_completion_subinv OUT NOCOPY VARCHAR2,
                                         o_completion_locator_id OUT NOCOPY NUMBER) IS
l_alt_routing           VARCHAR(10) := NULL;
l_subinventory          VARCHAR(10) := NULL;
l_locator_id            NUMBER := NULL;
l_error_number          NUMBER := 1;
BEGIN

  IF(i_alt_rtg_designator IS NULL)
  THEN
    l_alt_routing := NULL;
  ELSE
    l_alt_routing := i_alt_rtg_designator;
  END IF;

  l_error_number := WIP_FLOW_DERIVE.Routing_Completion_Sub_Loc(
                         l_subinventory,
                         l_locator_id,
                         i_primary_item_id,
                         i_org_id,
                         l_alt_routing
                          );

  IF(l_error_number = 1) THEN
    o_completion_subinv := l_subinventory;
    o_completion_locator_id := l_locator_id;
  END IF;

END get_completion_subinv_and_loc;


/******************************************************************
 * To get alternate bom designator                                *
 ******************************************************************/
PROCEDURE get_alt_bom_designator(i_org_id NUMBER,
                                 i_primary_item_id NUMBER,
                                 i_alt_rtg_designator VARCHAR2,
                                 o_alt_bom_designator OUT NOCOPY VARCHAR2) IS
l_bill_count NUMBER;
BEGIN

  IF(i_alt_rtg_designator IS NULL) THEN
    o_alt_bom_designator := NULL;
  ELSE
    SELECT count(bill_sequence_id)
    INTO   l_bill_count
    FROM   BOM_BILL_OF_MATERIALS
    WHERE  organization_id = i_org_id AND
           assembly_item_id = i_primary_item_id AND
           alternate_bom_designator = i_alt_rtg_designator;
    IF (l_bill_count > 0) THEN
      o_alt_bom_designator := i_alt_rtg_designator;
    ELSE
      o_alt_bom_designator := NULL;
    END IF;
  END IF;
END get_alt_bom_designator;



/******************************************************************
 * To get bom revision and bom revision date                      *
 ******************************************************************/
PROCEDURE get_bom_rev_and_date (i_org_id NUMBER,
                                i_primary_item_id NUMBER,
                                i_sch_completion_date DATE,
                                o_bom_revision OUT NOCOPY VARCHAR,
                                o_bom_revision_date OUT NOCOPY DATE) IS

l_bom_revision          VARCHAR(3) := NULL;
l_revision              VARCHAR(3) := NULL;
l_error_number          NUMBER := 1;
l_revision_date         DATE := NULL;
BEGIN
  l_error_number := WIP_FLOW_DERIVE.Bom_Revision(
                                l_bom_revision,
                                l_revision,
                                l_revision_date,
                                i_primary_item_id,
                                i_sch_completion_date,
                                i_org_id
                          );

  IF(l_error_number = 1) THEN
    o_bom_revision := l_bom_revision;
    o_bom_revision_date := l_revision_date;
  END IF;

END get_bom_rev_and_date;


/******************************************************************
 * To get routing revision and routing revision date              *
 ******************************************************************/
PROCEDURE get_rtg_rev_and_date (i_org_id NUMBER,
                                i_primary_item_id NUMBER,
                                i_sch_completion_date DATE,
                                o_rtg_revision OUT NOCOPY VARCHAR,
                                o_rtg_revision_date OUT NOCOPY DATE) IS

l_rtg_revision          VARCHAR(3) := NULL;
l_error_number          NUMBER := 1;
l_revision_date         DATE := NULL;
BEGIN
  l_error_number := WIP_FLOW_DERIVE.Routing_Revision(
                                l_rtg_revision,
                                l_revision_date,
                                i_primary_item_id,
                                i_sch_completion_date,
                                i_org_id
                          );
  IF(l_error_number = 1) THEN
    o_rtg_revision := l_rtg_revision;
    o_rtg_revision_date := l_revision_date;
  END IF;

END get_rtg_rev_and_date;


/******************************************************************
 * To get all account id based on class code                      *
 ******************************************************************/
PROCEDURE get_account_ids (i_org_id NUMBER, i_class_code VARCHAR2,
                           i_material_act IN OUT NOCOPY NUMBER,
                           i_material_overhead_act IN OUT NOCOPY NUMBER,
                           i_resource_act IN OUT NOCOPY NUMBER,
                           i_outside_processing_act IN OUT NOCOPY NUMBER,
                           i_material_variance_act IN OUT NOCOPY NUMBER,
                           i_resource_variance_act IN OUT NOCOPY NUMBER,
                           i_outside_proc_variance_act IN OUT NOCOPY NUMBER,
                           i_std_cost_adjustment_act IN OUT NOCOPY NUMBER,
                           i_overhead_act IN OUT NOCOPY NUMBER,
                           i_overhead_variance_act IN OUT NOCOPY NUMBER) IS
  l_material_act NUMBER;
  l_material_overhead_act NUMBER;
  l_resource_act NUMBER;
  l_outside_processing_act NUMBER;
  l_material_variance_act NUMBER;
  l_resource_variance_act  NUMBER;
  l_outside_proc_variance_act NUMBER;
  l_std_cost_adjustment_act NUMBER;
  l_overhead_act NUMBER;
  l_overhead_variance_act NUMBER;

BEGIN
  SELECT MATERIAL_ACCOUNT, MATERIAL_OVERHEAD_ACCOUNT,
         RESOURCE_ACCOUNT, OUTSIDE_PROCESSING_ACCOUNT,
         MATERIAL_VARIANCE_ACCOUNT, RESOURCE_VARIANCE_ACCOUNT,
         OUTSIDE_PROC_VARIANCE_ACCOUNT, STD_COST_ADJUSTMENT_ACCOUNT,
         OVERHEAD_ACCOUNT, OVERHEAD_VARIANCE_ACCOUNT
  INTO
         l_material_act, l_material_overhead_act,
         l_resource_act, l_outside_processing_act,
         l_material_variance_act, l_resource_variance_act,
         l_outside_proc_variance_act, l_std_cost_adjustment_act,
         l_overhead_act, l_overhead_variance_act
  FROM   WIP_ACCOUNTING_CLASSES
  WHERE  ORGANIZATION_ID = i_org_id AND
         CLASS_CODE = i_class_code;

  i_material_act := l_material_act;
  i_material_overhead_act := l_material_overhead_act;
  i_resource_act := l_resource_act;
  i_outside_processing_act := l_outside_processing_act;
  i_material_variance_act := l_material_variance_act;
  i_resource_variance_act := l_resource_variance_act;
  i_outside_proc_variance_act := l_outside_proc_variance_act;
  i_std_cost_adjustment_act := l_std_cost_adjustment_act;
  i_overhead_act := l_overhead_act;
  i_overhead_variance_act := l_overhead_variance_act;

  EXCEPTION when others then
    return;

END get_account_ids;


/******************************************************************
 * To get class code based on item and organization               *
 ******************************************************************/
FUNCTION get_class_code(i_org_id NUMBER, i_item_id NUMBER )RETURN VARCHAR IS
l_error_number NUMBER := 1;
l_error_mesg VARCHAR2(80) := null;
l_class_code VARCHAR2(10) := null;
BEGIN
  l_error_number := WIP_FLOW_DERIVE.Class_Code(l_class_code,
                      l_error_mesg,
                      i_org_id,
                      i_item_id,
                      4,    --entity_type
                      null);

  if(l_error_number <> 1) then
    SELECT default_discrete_class
    INTO   l_class_code
    FROM   wip_parameters
    WHERE  organization_id = i_org_id;
  end if;

  return l_class_code;

END get_class_code;


/******************************************************************
 * To explode the item bom                                        *
 ******************************************************************/
PROCEDURE explode_items (i_item_id    IN NUMBER,
                         i_org_id     IN NUMBER,
                         i_alt_bom    IN VARCHAR2,
                         x_error_msg  IN OUT NOCOPY VARCHAR2,
                         x_error_code IN OUT NOCOPY NUMBER) IS
BEGIN
  BOM_OE_EXPLODER_PKG.be_exploder(
        arg_org_id            => i_org_id,
        arg_starting_rev_date => sysdate - 3,
        arg_expl_type         => 'ALL',
        arg_order_by          => 1,
        arg_levels_to_explode => 20,
        arg_item_id           => i_item_id,
        arg_comp_code         => '',
        arg_user_id           => 0,
        arg_err_msg           => x_error_msg,
        arg_error_code        => x_error_code,
        arg_alt_bom_desig     => i_alt_bom
  );

  if x_error_code = 9998 then
    -- Do nothing, there was just no bill to explode
     x_error_code := 0;
  elsif x_error_code <> 0 then
    return;
  end if;

END explode_items;


/******************************************************************
 * This procedure loops through schedules table, find out         *
 * unique item and alternate bom combinations, and call           *
 * explode for each unique combination                            *
 ******************************************************************/
PROCEDURE explode_all_items(i_schedules_tbl IN OUT NOCOPY
                               wip_flow_schedule_tbl,
                            o_return_code OUT NOCOPY NUMBER) IS
l_index NUMBER;
l_item_tbl_to_explode wip_flow_schedule_tbl;
item_alt_already_exist BOOLEAN;
l_error_msg VARCHAR2(2000);
l_error_code NUMBER;
iLine NUMBER;

BEGIN
  o_return_code := 0;

  FOR i in i_schedules_tbl.FIRST .. i_schedules_tbl.LAST
  LOOP
    item_alt_already_exist := false;

    if(l_item_tbl_to_explode.COUNT > 1) then
      for j in l_item_tbl_to_explode.FIRST .. l_item_tbl_to_explode.LAST
      LOOP
        if(
            (l_item_tbl_to_explode(j).organization_id =
               i_schedules_tbl(i).organization_id) AND
            (l_item_tbl_to_explode(j).primary_item_id =
               i_schedules_tbl(i).primary_item_id) AND
            (nvl(l_item_tbl_to_explode(j).alternate_bom_designator,'$$$') =
               nvl(i_schedules_tbl(i).alternate_bom_designator,'$$$') )
          )  then
          item_alt_already_exist := true;
        end if;
      END LOOP;
    end if;

    if(item_alt_already_exist = false) then
      --get the current number of elements in items table
      l_index := l_item_tbl_to_explode.COUNT;
      --get the position to insert current record
      l_index := l_index + 1;
      l_item_tbl_to_explode(l_index).organization_id :=
        i_schedules_tbl(i).organization_id;
      l_item_tbl_to_explode(l_index).primary_item_id :=
        i_schedules_tbl(i).primary_item_id;
      l_item_tbl_to_explode(l_index).alternate_bom_designator :=
        i_schedules_tbl(i).alternate_bom_designator;
    end if;

   --while looping to find out unique items, we also build the
   --table for unique so line, that will be used for call to CTO
   if(i_schedules_tbl(i).demand_source_type = g_demand_type_SO) then
     if(i_schedules_tbl(i).demand_source_line is not null) then
       g_cto_line_tbl(to_number(i_schedules_tbl(i).demand_source_line)).
         demand_source_line := i_schedules_tbl(i).demand_source_line;
       g_cto_line_tbl(to_number(i_schedules_tbl(i).demand_source_line)).
         primary_item_id := i_schedules_tbl(i).primary_item_id;
       g_cto_line_tbl(to_number(i_schedules_tbl(i).demand_source_line)).
         organization_id := i_schedules_tbl(i).organization_id;
     end if;
   end if;

  END LOOP;

  --now all the unique item, alternate combination have been identified
  --call explode for each combination
  if(l_item_tbl_to_explode.COUNT > 0) then
    for k in l_item_tbl_to_explode.FIRST .. l_item_tbl_to_explode.LAST
    LOOP
      explode_items (l_item_tbl_to_explode(k).primary_item_id,
                     l_item_tbl_to_explode(k).organization_id,
                     l_item_tbl_to_explode(k).alternate_bom_designator,
                     l_error_msg,
                     l_error_code);
      if(l_error_code <> 0) then
        o_return_code := 1;
      end if;
    END LOOP;
  end if;

EXCEPTION
  WHEN OTHERS THEN
    o_return_code := 1;
    return;

END explode_all_items;


/******************************************************************
 * To call the CTO API for each so line                           *
 ******************************************************************/
PROCEDURE call_cto_api(o_return_code IN OUT NOCOPY NUMBER) IS
  TYPE item_detail_rec_type IS RECORD
    (
     primary_item_id NUMBER,
     organization_id NUMBER,
     replenish_to_order_flag VARCHAR2(1),
     build_in_wip_flag VARCHAR2(1)
    );
  TYPE item_detail_tbl_type IS TABLE OF item_detail_rec_type INDEX BY BINARY_INTEGER;

  l_item_dtl_tbl item_detail_tbl_type;
  iLine NUMBER;
  l_primary_item_id NUMBER;
  l_replenish_to_order_flag VARCHAR2(1);
  l_build_in_wip_flag VARCHAR2(1);
  l_org_id NUMBER;
  l_return_status       VARCHAR2(1);
  l_msg_data            VARCHAR2(240);
  l_msg_count           NUMBER;

BEGIN
  o_return_code := 0;

  IF(g_cto_line_tbl.COUNT > 0) THEN
    iLine := g_cto_line_tbl.FIRST;
    WHILE iLine IS NOT NULL LOOP
      l_build_in_wip_flag := 'N';
      l_replenish_to_order_flag := 'N';

      l_primary_item_id := g_cto_line_tbl(iLine).primary_item_id;
      l_org_id := g_cto_line_tbl(iLine).organization_id;

      --find out if this item and attributes already exist in local pls table
      --if exist use those,
      --if not exist, then query and save the record in local pls table for further use
      if(l_item_dtl_tbl.EXISTS(l_primary_item_id)) then
        l_replenish_to_order_flag :=
          l_item_dtl_tbl(l_primary_item_id).replenish_to_order_flag;
        l_build_in_wip_flag :=
          l_item_dtl_tbl(l_primary_item_id).build_in_wip_flag;
      else
        select msi.build_in_wip_flag, msi.replenish_to_order_flag
        into   l_build_in_wip_flag, l_replenish_to_order_flag
        from   mtl_system_items msi
        where  msi.inventory_item_id = l_primary_item_id
               and msi.organization_id = l_org_id;
        l_item_dtl_tbl(l_primary_item_id).primary_item_id := l_primary_item_id;
        l_item_dtl_tbl(l_primary_item_id).replenish_to_order_flag :=
         l_replenish_to_order_flag;
        l_item_dtl_tbl(l_primary_item_id).build_in_wip_flag :=
         l_build_in_wip_flag;
      end if;

      if( (l_build_in_wip_flag = 'Y') AND (l_replenish_to_order_flag = 'Y')) then
        CTO_WIP_WORKFLOW_API_PK.flow_creation(g_cto_line_tbl(iLine).demand_source_line,
                                              l_return_status,
                                              l_msg_count,
                                              l_msg_data);
      end if;

      iLine := g_cto_line_tbl.NEXT(iLine);
    END LOOP;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    o_return_code := 1;
    return;

END call_cto_api;


/******************************************************************
 * To update the mrp_recommendations based on schedules inserted  *
 ******************************************************************/
PROCEDURE update_mrp_recommendations(i_schedules_tbl IN  wip_flow_schedule_tbl,
                                     o_return_code IN OUT NOCOPY NUMBER) IS

l_index NUMBER;
l_item_tbl_to_update_rec wip_flow_schedule_tbl;
item_already_exist BOOLEAN;
l_error_msg VARCHAR2(2000);
l_error_code NUMBER;
BEGIN
  o_return_code := 0;

  FOR i in i_schedules_tbl.FIRST .. i_schedules_tbl.LAST
  LOOP
    item_already_exist := false;
    if(l_item_tbl_to_update_rec.COUNT > 1) then
      for j in l_item_tbl_to_update_rec.FIRST .. l_item_tbl_to_update_rec.LAST
      LOOP
        if(
            (l_item_tbl_to_update_rec(j).organization_id =
               i_schedules_tbl(i).organization_id) AND
            (l_item_tbl_to_update_rec(j).demand_source_line =
               i_schedules_tbl(i).demand_source_line) AND
            (i_schedules_tbl(i).demand_source_header_id IS NULL )
          )  then
          l_item_tbl_to_update_rec(j).planned_quantity :=
            l_item_tbl_to_update_rec(j).planned_quantity +
            i_schedules_tbl(i).planned_quantity;
          item_already_exist := true;
        end if;
      END LOOP;
    end if;

    if( (item_already_exist = false) AND
        ( i_schedules_tbl(i).demand_source_header_id IS NULL)
      ) then

      --get the current number of elements in items table
      l_index := l_item_tbl_to_update_rec.COUNT;
      --get the position to insert current record
      l_index := l_index + 1;
      l_item_tbl_to_update_rec(l_index).organization_id :=
        i_schedules_tbl(i).organization_id;
      l_item_tbl_to_update_rec(l_index).demand_source_line :=
        i_schedules_tbl(i).demand_source_line;
      l_item_tbl_to_update_rec(l_index).planned_quantity :=
        i_schedules_tbl(i).planned_quantity;
    end if;

  END LOOP;
  if(l_item_tbl_to_update_rec.COUNT > 0) then
    for k in l_item_tbl_to_update_rec.FIRST .. l_item_tbl_to_update_rec.LAST
    LOOP
      UPDATE mrp_recommendations
      SET quantity_in_process =
          nvl(quantity_in_process,0) + l_item_tbl_to_update_rec(k).planned_quantity
      WHERE transaction_id = l_item_tbl_to_update_rec(k).demand_source_line;
    END LOOP;
  end if;

EXCEPTION
  WHEN OTHERS THEN
    o_return_code := 1;
    return;

END update_mrp_recommendations;


/******************************************************************
 * Used to insert all the schedule in the table                   *
 ******************************************************************/
PROCEDURE insert_schedules (
        i_schedules_tbl       IN      wip_flow_schedule_tbl,
        o_return_code           OUT NOCOPY     NUMBER) IS
l_index NUMBER;

BEGIN

  if(i_schedules_tbl.COUNT > 0) then
    l_index := i_schedules_tbl.FIRST;
    LOOP
     insert into wip_flow_schedules
     (
       scheduled_flag,
       wip_entity_id,
       organization_id,
       last_update_date,
       last_updated_by,
       creation_date,
       created_by,
       last_update_login,
       request_id,
       program_application_id,
       program_id,
       program_update_date,
       primary_item_id,
       class_code,
       scheduled_start_date,
       date_closed,
       planned_quantity,
       quantity_completed,
       mps_scheduled_completion_date,
       mps_net_quantity,
       bom_revision,
       routing_revision,
       bom_revision_date,
       routing_revision_date,
       alternate_bom_designator,
       alternate_routing_designator,
       completion_subinventory,
       completion_locator_id,
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
       demand_class,
       scheduled_completion_date,
       schedule_group_id,
       build_sequence,
       line_id,
       project_id,
       task_id,
       status,
       schedule_number,
       attribute_category,
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
       demand_source_header_id,
       demand_source_line,
       demand_source_delivery,
       demand_source_type,
       kanban_card_id,
       quantity_scrapped
     )
     values
     (
       i_schedules_tbl(l_index).scheduled_flag,
       i_schedules_tbl(l_index).wip_entity_id,
       i_schedules_tbl(l_index).organization_id,
       i_schedules_tbl(l_index).last_update_date,
       i_schedules_tbl(l_index).last_updated_by,
       i_schedules_tbl(l_index).creation_date,
       i_schedules_tbl(l_index).created_by,
       i_schedules_tbl(l_index).last_update_login,
       i_schedules_tbl(l_index).request_id,
       i_schedules_tbl(l_index).program_application_id,
       i_schedules_tbl(l_index).program_id,
       i_schedules_tbl(l_index).program_update_date,
       i_schedules_tbl(l_index).primary_item_id,
       i_schedules_tbl(l_index).class_code,
       i_schedules_tbl(l_index).scheduled_start_date,
       i_schedules_tbl(l_index).date_closed,
       i_schedules_tbl(l_index).planned_quantity,
       i_schedules_tbl(l_index).quantity_completed,
       i_schedules_tbl(l_index).mps_scheduled_completion_date,
       i_schedules_tbl(l_index).mps_net_quantity,
       i_schedules_tbl(l_index).bom_revision,
       i_schedules_tbl(l_index).routing_revision,
       i_schedules_tbl(l_index).bom_revision_date,
       i_schedules_tbl(l_index).routing_revision_date,
       i_schedules_tbl(l_index).alternate_bom_designator,
       i_schedules_tbl(l_index).alternate_routing_designator,
       i_schedules_tbl(l_index).completion_subinventory,
       i_schedules_tbl(l_index).completion_locator_id,
       i_schedules_tbl(l_index).material_account,
       i_schedules_tbl(l_index).material_overhead_account,
       i_schedules_tbl(l_index).resource_account,
       i_schedules_tbl(l_index).outside_processing_account,
       i_schedules_tbl(l_index).material_variance_account,
       i_schedules_tbl(l_index).resource_variance_account,
       i_schedules_tbl(l_index).outside_proc_variance_account,
       i_schedules_tbl(l_index).std_cost_adjustment_account,
       i_schedules_tbl(l_index).overhead_account,
       i_schedules_tbl(l_index).overhead_variance_account,
       i_schedules_tbl(l_index).demand_class,
       i_schedules_tbl(l_index).scheduled_completion_date,
       i_schedules_tbl(l_index).schedule_group_id,
       i_schedules_tbl(l_index).build_sequence,
       i_schedules_tbl(l_index).line_id,
       i_schedules_tbl(l_index).project_id,
       i_schedules_tbl(l_index).task_id,
       i_schedules_tbl(l_index).status,
       i_schedules_tbl(l_index).schedule_number,
       i_schedules_tbl(l_index).attribute_category,
       i_schedules_tbl(l_index).attribute1,
       i_schedules_tbl(l_index).attribute2,
       i_schedules_tbl(l_index).attribute3,
       i_schedules_tbl(l_index).attribute4,
       i_schedules_tbl(l_index).attribute5,
       i_schedules_tbl(l_index).attribute6,
       i_schedules_tbl(l_index).attribute7,
       i_schedules_tbl(l_index).attribute8,
       i_schedules_tbl(l_index).attribute9,
       i_schedules_tbl(l_index).attribute10,
       i_schedules_tbl(l_index).attribute11,
       i_schedules_tbl(l_index).attribute12,
       i_schedules_tbl(l_index).attribute13,
       i_schedules_tbl(l_index).attribute14,
       i_schedules_tbl(l_index).attribute15,
       i_schedules_tbl(l_index).demand_source_header_id,
       i_schedules_tbl(l_index).demand_source_line,
       i_schedules_tbl(l_index).demand_source_delivery,
       i_schedules_tbl(l_index).demand_source_type,
       i_schedules_tbl(l_index).kanban_card_id,
       i_schedules_tbl(l_index).quantity_scrapped
     );
     EXIT WHEN l_index = i_schedules_tbl.LAST;
     l_index := i_schedules_tbl.next(l_index);
   END LOOP;
   end if;
   o_return_code := 0;
   return;


EXCEPTION
  WHEN OTHERS THEN
    o_return_code := 1;

END insert_schedules;


/******************************************************************
 * To get component availability of a sequencing task             *
 ******************************************************************/
PROCEDURE Init_Component_Avail(p_seq_task_id IN NUMBER,
			       p_organization_id IN NUMBER,
			       p_from_date IN DATE,
			       p_to_date IN DATE,
			       x_err_code OUT NOCOPY NUMBER,
			       x_err_msg OUT NOCOPY VARCHAR
			       ) IS
   l_status VARCHAR2(2);
   l_msg_count NUMBER;
   l_msg_data VARCHAR2(240);
   l_index NUMBER:=1;
   l_ignore_line_id_tbl flm_supply_demand.number_tbl_type;

    -- Modified for Lot Based Material Support.
    -- We read the list of component in this procedure and pass
    -- the list of component to flm_supply_demand.read_comp_avail.
    -- Cursor for getting component_id for CONSTRAINT_TYPE = 7
    -- (Component Availability constraint)
    CURSOR item_list IS
    SELECT distinct(ATTRIBUTE_VALUE1_NUM) inventory_item_id
    FROM FLM_SEQ_TASK_CONSTRAINTS
    WHERE SEQ_TASK_ID = p_seq_task_id
      AND ORGANIZATION_ID = p_organization_id
      AND CONSTRAINT_TYPE = 7;

    CURSOR line_id_list IS
    SELECT line_id
    FROM FLM_SEQ_TASK_LINES
    WHERE SEQ_TASK_ID = p_seq_task_id;

Begin
    x_err_code := 0;

    l_index := 1;
    FOR item_list_rec in item_list LOOP
       g_components(l_index) := item_list_rec.inventory_item_id;
       l_index := l_index+1;
    END LOOP;

    -- Added to ignore demand that comes from the given line_id.
    l_index := 1;
    FOR line_id_list_rec IN line_id_list LOOP
       l_ignore_line_id_tbl(l_index) := line_id_list_rec.line_id;
       l_index := l_index+1;
    END LOOP;

    flm_supply_demand.read_comp_avail(
	g_components,
	p_organization_id,
	p_from_date,
	p_to_date,
        l_ignore_line_id_tbl,
	g_qtys,
	l_status,
	l_msg_count,
	l_msg_data
    );

    g_components_index := 1;

EXCEPTION
   WHEN OTHERS THEN
      x_err_msg := 'Unexpected SQL Error: '||sqlerrm;
      x_err_code := -1;

End Init_Component_Avail;



/******************************************************************
 * To get component availability list at a size of p_batch_size   *
 ******************************************************************/
PROCEDURE Get_Component_Avail(
			      p_batch_size IN NUMBER,
			      x_ids OUT NOCOPY number_tbl_type,
			      x_qtys OUT NOCOPY number_tbl_type,
			      x_found IN OUT NOCOPY NUMBER,
			      x_done_flag OUT NOCOPY INTEGER,
			      x_err_code OUT NOCOPY NUMBER,
			      x_err_msg OUT NOCOPY VARCHAR
			      ) IS
  l_size NUMBER := 0;
Begin
  x_err_code := 0;
  x_found := 0;
  x_done_flag := 0;

  WHILE (g_components_index <= g_components.COUNT and l_size < p_batch_size) LOOP
    x_ids(l_size+1) := g_components(g_components_index);
    x_qtys(l_size+1) := g_qtys(g_components_index);
    g_components_index := g_components_index + 1;
    l_size := l_size + 1;
  END LOOP;

  x_found := l_size;

  if (g_components_index > g_components.COUNT) then
    x_done_flag := 1;
  end if;

EXCEPTION
   WHEN OTHERS THEN
      x_err_msg := 'Unexpected SQL Error: '||sqlerrm;
      x_err_code := -1;

End Get_Component_Avail;


END flm_seq_reader_writer;

/
