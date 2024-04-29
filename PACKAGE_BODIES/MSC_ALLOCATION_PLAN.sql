--------------------------------------------------------
--  DDL for Package Body MSC_ALLOCATION_PLAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_ALLOCATION_PLAN" AS
 /*  $Header: MSCALPHB.pls 120.8 2007/01/17 19:29:59 hulu ship $ */

/* group by column */
GY_CUSTOMER CONSTANT INTEGER := 2;
GY_CUSTOMER_SITE CONSTANT INTEGER := 3;
GY_DEMAND_CLASS CONSTANT INTEGER := 4;

/* allocation plan type lookup */

 HZ_UNC_DEMAND            CONSTANT INTEGER := 10;
 HZ_EXP_DEMAND            CONSTANT INTEGER := 20;
 HZ_SUPPLY                CONSTANT INTEGER := 30;
 HZ_FIRM_ALLOC            CONSTANT INTEGER := 40;
 HZ_SUGG_ALLOC            CONSTANT INTEGER := 50;
 HZ_ADJ_ALLOC             CONSTANT INTEGER := 60;
 HZ_EFFECT_ALLOC          CONSTANT INTEGER := 70;
 --HZ_ADJ_CUM_FILL_RATE     CONSTANT INTEGER := 80;
 HZ_CUM_UNC_DEMAND        CONSTANT INTEGER := 90;
 HZ_CUM_EXP_DEMAND        CONSTANT INTEGER := 100;
 HZ_CUM_SUPPLY            CONSTANT INTEGER := 110;
 HZ_CUM_SUGG_ALLOC        CONSTANT INTEGER := 120;
 HZ_CUM_FILL_RATE         CONSTANT INTEGER := 130;

/* offset */

 UNC_DEMAND_OFF            CONSTANT INTEGER := 1;
 EXP_DEMAND_OFF            CONSTANT INTEGER := 2;
 SUPPLY_OFF                CONSTANT INTEGER := 3;
 FIRM_ALLOC_OFF            CONSTANT INTEGER := 4;
 SUGG_ALLOC_OFF            CONSTANT INTEGER := 5;
 ADJ_ALLOC_OFF             CONSTANT INTEGER := 6;
 EFFECT_ALLOC_OFF          CONSTANT INTEGER := 7;
 --ADJ_CUM_ALLOC_OFF         CONSTANT INTEGER := 7;
 --ADJ_CUM_FILL_RATE_OFF     CONSTANT INTEGER := 8;
 CUM_UNC_DEMAND_OFF        CONSTANT INTEGER := 8;
 CUM_EXP_DEMAND_OFF        CONSTANT INTEGER := 9;
 CUM_SUPPLY_OFF            CONSTANT INTEGER := 10;
 CUM_SUGG_ALLOC_OFF        CONSTANT INTEGER := 11;
 CUM_FILL_RATE_OFF         CONSTANT INTEGER := 12;

 NUM_OF_TYPES        CONSTANT INTEGER := 12;

 /* global variable for number of buckets to display for the plan */
 g_num_of_buckets	NUMBER;
 g_error_stmt		VARCHAR2(200);

 TYPE column_number IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
 TYPE calendar_date IS TABLE OF DATE INDEX BY BINARY_INTEGER;
 var_dates           calendar_date;   -- Holds the start dates of buckets
 g_other_text varchar2(200);
 g_total_text varchar2(200);

 Procedure populate_allocation_plan (
			      arg_query_id IN NUMBER,
			      arg_plan_id IN NUMBER,
                              arg_org_id IN NUMBER,
                              arg_instance_id IN NUMBER,
                              arg_item_id IN NUMBER,
                              arg_group_by IN NUMBER,
                              arg_customer_id IN NUMBER DEFAULT NULL,
                              arg_customer_site_id IN NUMBER DEFAULT NULL,
                              arg_customer_list_id IN NUMBER DEFAULT NULL) IS

-- -------------------------------------------------
-- This cursor select number of buckets in the plan.
-- -------------------------------------------------
CURSOR plan_buckets IS
SELECT organization_id, sr_instance_id
FROM msc_plans
WHERE plan_id = arg_plan_id;

-- -------------------------------------------------
-- This cursor selects the dates for the buckets.
-- -------------------------------------------------
g_org_id number;
g_inst_id number;

CURSOR bucket_dates IS
SELECT mab.bkt_start_date, mab.bkt_end_date
FROM msc_allocation_buckets mab
WHERE mab.plan_id = arg_plan_id
and mab.organization_id = g_org_id
and mab.sr_instance_id = g_inst_id
order by mab.bucket_index ;

l_bucket_number		NUMBER := 1;
l_bucket_date		DATE;
l_bkt_end_date		DATE;

last_date       DATE;

CURSOR  allocation_plan_activity IS
 SELECT
        SUPPLY_OFF  offset,
        'total' char1, -- only shown in total
        1 sequence,
        nvl(ms.firm_date,ms.new_schedule_date) new_date,
	sum(nvl(ms.firm_quantity,ms.new_order_quantity)) quantity,
        0 quantity2
FROM    msc_supplies ms,
        msc_form_query      mfq
WHERE   ms.plan_id = mfq.number4
AND     ms.inventory_item_id = mfq.number1
AND     ms.organization_id = mfq.number2
AND     ms.sr_instance_id = mfq.number3
AND     mfq.query_id = arg_query_id
AND     (mfq.number6 <> -1 or
         ( mfq.number6 = -1 and ms.order_type <> 51)) -- no internal shipments in all org
GROUP BY
        nvl(ms.firm_date,ms.new_schedule_date)
UNION ALL
SELECT  UNC_DEMAND_OFF  offset,
        nvl(decode(md.demand_source_type, 8, -- internal sales order
                      to_char(md.source_organization_id),
                   decode(arg_group_by,  -- other demand types
                             GY_CUSTOMER, to_char(md.customer_id),
                             GY_CUSTOMER_SITE, to_char(md.customer_site_id),
                             GY_DEMAND_CLASS, md.demand_class)),
                      nvl(to_char(md.source_organization_id), '-2')) char1,
        decode(md.demand_source_type, 8, --internal sales order
                      9,                -- displayed as an org
                   decode(decode(arg_group_by,
                             GY_CUSTOMER, to_char(md.customer_id),
                             GY_CUSTOMER_SITE, to_char(md.customer_site_id),
                             GY_DEMAND_CLASS, md.demand_class),
                             null, -- if no customer_id/...
                             decode(md.source_organization_id, null, 8, 9),
                                     arg_group_by)) sequence,
        nvl(md.old_using_assembly_demand_date,
               md.using_assembly_demand_date) new_date,
        SUM(DECODE(md.origination_type, 29,nvl(md.probability,1),1) *
                nvl(old_using_requirement_quantity,
                        using_requirement_quantity)) quantity,
        sum(md.unmet_quantity) quantity2
FROM    msc_demands  md,
        msc_form_query      mfq
WHERE   md.plan_id = mfq.number4
AND     md.inventory_item_id = mfq.number1
AND     md.organization_id = mfq.number2
AND     md.sr_instance_id = mfq.number3
AND     md.origination_type in (1,24,29,30)
AND     mfq.query_id = arg_query_id
AND     nvl(md.customer_id,-1) = nvl(arg_customer_id,
                                     nvl(md.customer_id,-1))
AND     nvl(md.customer_site_id,-1) = nvl(arg_customer_site_id,
                                          nvl(md.customer_site_id,-1))
AND     (arg_customer_list_id is null or
         ( arg_customer_list_id is not null and
             ((md.customer_id, md.customer_site_id) in (
                select source_type, object_type
                from msc_pq_types
                where query_id = arg_customer_list_id
                  and object_type <> 0) or
             md.customer_id in (
                select source_type
                from msc_pq_types
                where query_id = arg_customer_list_id
                  and object_type = 0) or
             md.customer_id is null)
          )
        )
GROUP BY
        nvl(md.old_using_assembly_demand_date,
               md.using_assembly_demand_date),
        nvl(decode(md.demand_source_type, 8,
                      to_char(md.source_organization_id),
                   decode(arg_group_by,
                             GY_CUSTOMER, to_char(md.customer_id),
                             GY_CUSTOMER_SITE, to_char(md.customer_site_id),
                             GY_DEMAND_CLASS, md.demand_class)),
                      nvl(to_char(md.source_organization_id), '-2')),
        decode(md.demand_source_type, 8,
                      9,
                   decode(decode(arg_group_by,
                             GY_CUSTOMER, to_char(md.customer_id),
                             GY_CUSTOMER_SITE, to_char(md.customer_site_id),
                             GY_DEMAND_CLASS, md.demand_class),
                             null,
                             decode(md.source_organization_id, null, 8, 9),
                                arg_group_by))
UNION ALL
SELECT
        SUGG_ALLOC_OFF offset,
        nvl(decode(md.demand_source_type, 8, -- internal sales order
                      to_char(md.source_organization_id),
                   decode(arg_group_by,  -- other demand types
                             GY_CUSTOMER, to_char(md.customer_id),
                             GY_CUSTOMER_SITE, to_char(md.customer_site_id),
                             GY_DEMAND_CLASS, md.demand_class)),
                      nvl(to_char(md.source_organization_id), '-2')) char1,
        decode(md.demand_source_type, 8, --internal sales order
                     9,                -- displayed in last rows
                   decode(decode(arg_group_by,
                             GY_CUSTOMER, to_char(md.customer_id),
                             GY_CUSTOMER_SITE, to_char(md.customer_site_id),
                             GY_DEMAND_CLASS, md.demand_class),
                             null,
                             decode(md.source_organization_id, null, 8, 9),
                                     arg_group_by)) sequence,
        ms.new_schedule_date new_date,
        SUM(mslp.quantity) quantity,
        0 quantity2
FROM    msc_demands    md,
        msc_supplies ms,
        msc_single_lvl_peg mslp,
        msc_form_query      mfq
WHERE   ms.organization_id = mfq.number2
AND     ms.sr_instance_id = mfq.number3
AND     ms.plan_id = mfq.number4
AND     ms.inventory_item_id = mfq.number1
AND     mfq.query_id = arg_query_id
and     mslp.plan_id = ms.plan_id
and     mslp.pegging_type = 2 -- supply to parent demand
and     mslp.child_id = ms.transaction_id
and     md.plan_id = mslp.plan_id
and     md.demand_id = mslp.parent_id
AND     nvl(md.customer_id,-1) = nvl(arg_customer_id,
                                     nvl(md.customer_id,-1))
AND     nvl(md.customer_site_id,-1) = nvl(arg_customer_site_id,
                                          nvl(md.customer_site_id,-1))
AND     (arg_customer_list_id is null or
         ( arg_customer_list_id is not null and
             ((md.customer_id, md.customer_site_id) in (
                select source_type, object_type
                from msc_pq_types
                where query_id = arg_customer_list_id
                  and object_type <> 0) or
               md.customer_id in (
                select source_type
                from msc_pq_types
                where query_id = arg_customer_list_id
                  and object_type = 0) or
             md.customer_id is null)
          )
        )
GROUP BY ms.new_schedule_date,
        nvl(decode(md.demand_source_type, 8,
                      to_char(md.source_organization_id),
                   decode(arg_group_by,
                             GY_CUSTOMER, to_char(md.customer_id),
                             GY_CUSTOMER_SITE, to_char(md.customer_site_id),
                             GY_DEMAND_CLASS, md.demand_class)),
                      nvl(to_char(md.source_organization_id), '-2')),
        decode(md.demand_source_type, 8,
                      9,
                   decode(decode(arg_group_by,
                             GY_CUSTOMER, to_char(md.customer_id),
                             GY_CUSTOMER_SITE, to_char(md.customer_site_id),
                             GY_DEMAND_CLASS, md.demand_class),
                             null,
                             decode(md.source_organization_id, null, 8, 9),
                                   arg_group_by))
UNION ALL
 SELECT
        FIRM_ALLOC_OFF  offset,
        to_char(ms.organization_id) char1,
        9 sequence,
        nvl(ms.firm_ship_date,ms.new_ship_date) new_date,
	sum(nvl(ms.firm_quantity,ms.new_order_quantity)) quantity,
        0 quantity2
FROM    msc_supplies ms,
        msc_form_query      mfq
WHERE   ms.plan_id = mfq.number4
AND     ms.inventory_item_id = mfq.number1
AND     ms.source_organization_id = mfq.number2
AND     ms.source_sr_instance_id = mfq.number3
AND     mfq.query_id = arg_query_id
AND     ms.firm_planned_type = 1
AND     ms.source_organization_id <> ms.organization_id
GROUP BY to_char(ms.organization_id),
        nvl(ms.firm_ship_date,ms.new_ship_date)
UNION ALL
--------------------------------------------------------------------
-- This select will ensure that all selected items get into cursor
-- even though they do not have any activity
---------------------------------------------------------------------
SELECT  UNC_DEMAND_OFF offset,
        'dummy' char1,
        -1 sequence,
        to_date(1, 'J') new_date,
        0 quantity,
        0 quantity2
FROM    msc_form_query mfq
WHERE   mfq.query_id = arg_query_id
ORDER BY 3,2,4;

TYPE alloc_activity IS RECORD
     (offset       NUMBER,
      char1        varchar2(80),
      sequence     NUMBER,
      new_date     DATE,
      quantity     NUMBER,
      quantity2    NUMBER);

activity_rec     alloc_activity;


last_char1        VARCHAR2(80) := '-1';
last_sequence number :=-2;

TYPE row_rec IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

row_detail row_rec;  -- for each customer/site/priority/demand class/org
total_row row_rec; -- for summary row
row_header_type column_number;

bucket_counter BINARY_INTEGER := 0; -- Id of the current bucket
old_bucket_counter BINARY_INTEGER := 0;
counter        BINARY_INTEGER := 0;

FUNCTION get_offset_location(offset IN NUMBER,
                      bucket IN NUMBER) RETURN number IS
BEGIN
  return (offset -1) * g_num_of_buckets + bucket;
END get_offset_location;

FUNCTION get_row_detail(offset IN NUMBER,
                        bucket IN NUMBER) RETURN NUMBER IS
  location number;
BEGIN
  location := get_offset_location(offset ,bucket);
  g_error_stmt := 'Debug - get_row_detail '||offset||','||bucket||','||location;
   return row_detail(location);

END get_row_detail;

FUNCTION get_total_row(offset IN NUMBER,
                        bucket IN NUMBER) RETURN NUMBER IS
  location number;
BEGIN
  location := get_offset_location(offset ,bucket);
  g_error_stmt := 'Debug - get_total_row ,'||offset||','||bucket||','||location;
   return total_row(location);

END get_total_row;

PROCEDURE add_to_plan(bucket IN NUMBER,
                      offset IN NUMBER,
                      quantity IN NUMBER) IS
 location number;
BEGIN
  g_error_stmt := 'Debug - add_to_plan - '||bucket||','||quantity;

  if nvl(quantity,0) = 0 or offset is null then
     return;
  end if;

  location := get_offset_location(offset ,bucket);
  row_detail(location) :=
          row_detail(location) + quantity;


  if offset not in
     (CUM_FILL_RATE_OFF ) then
      total_row(location) :=
          total_row(location) + quantity;
  end if;
END add_to_plan;

PROCEDURE calculate_cum_rows(bkt number) IS
BEGIN
      if bkt = 1 then

         add_to_plan(bkt,
                CUM_UNC_DEMAND_OFF,
                get_row_detail(UNC_DEMAND_OFF,bkt));
         add_to_plan(bkt,
                CUM_EXP_DEMAND_OFF,
                get_row_detail(EXP_DEMAND_OFF,bkt));
         add_to_plan(bkt,
                CUM_SUPPLY_OFF,
                get_row_detail(SUPPLY_OFF,bkt));
         add_to_plan(bkt,
                CUM_SUGG_ALLOC_OFF,
                get_row_detail(SUGG_ALLOC_OFF,bkt));

      else

         add_to_plan(bkt,
                CUM_UNC_DEMAND_OFF,
                get_row_detail(CUM_UNC_DEMAND_OFF,bkt -1)+
                get_row_detail(UNC_DEMAND_OFF,bkt));
         add_to_plan(bkt,
                CUM_EXP_DEMAND_OFF,
                get_row_detail(CUM_EXP_DEMAND_OFF,bkt-1)+
                get_row_detail(EXP_DEMAND_OFF,bkt));
         add_to_plan(bkt,
                CUM_SUPPLY_OFF,
                get_row_detail(CUM_SUPPLY_OFF,bkt-1)+
                get_row_detail(SUPPLY_OFF,bkt));
         add_to_plan(bkt,
                CUM_SUGG_ALLOC_OFF,
                get_row_detail(CUM_SUGG_ALLOC_OFF,bkt-1)+
                get_row_detail(SUGG_ALLOC_OFF,bkt));

      end if;

      if get_row_detail(CUM_UNC_DEMAND_OFF,bkt) <> 0 then
         add_to_plan(bkt,
                CUM_FILL_RATE_OFF,
                get_row_detail(CUM_SUGG_ALLOC_OFF,bkt)/
                get_row_detail(CUM_UNC_DEMAND_OFF,bkt)*100);
      end if;

      add_to_plan(bkt,
                 EFFECT_ALLOC_OFF,
                 greatest(get_row_detail(SUGG_ALLOC_OFF,bkt),
                          get_row_detail(FIRM_ALLOC_OFF,bkt)));

END calculate_cum_rows;


PROCEDURE flush_item_plan(p_char1 VARCHAR2, p_sequence NUMBER) IS
   p_text varchar2(300);
   p_id number;
BEGIN

  g_error_stmt := 'Debug - flush_item_plan - 10, for '||p_char1;

    FOR bkt IN 1..g_num_of_buckets LOOP

      calculate_cum_rows(bkt);

      if p_sequence = 1 then
         -- calcuate TOTAL for total row
        if bkt = 1 then
           total_row(get_offset_location(CUM_SUPPLY_OFF ,bkt)) :=
                     get_total_row(SUPPLY_OFF ,bkt);
        else
           total_row(get_offset_location(CUM_SUPPLY_OFF ,bkt)) :=
                     get_total_row(SUPPLY_OFF ,bkt)+
                            get_total_row(CUM_SUPPLY_OFF ,bkt-1);
        end if;

        if get_total_row(CUM_UNC_DEMAND_OFF,bkt) <> 0 then
           total_row(get_offset_location(CUM_FILL_RATE_OFF ,bkt)) :=
                get_total_row(CUM_SUGG_ALLOC_OFF,bkt)/
                get_total_row(CUM_UNC_DEMAND_OFF,bkt)*100;
        end if;

      end if;

      -- get the text for group by column
      begin

         if p_sequence not in (GY_DEMAND_CLASS,1) then
            p_id := to_number(p_char1);
         else
            p_id :=-2;
            if p_sequence = GY_DEMAND_CLASS and p_char1 <> '-2' then
               p_id := -1;
            end if;
         end if;

         if p_char1 = '-2' then -- null column
            p_text := g_other_text;
         elsif p_sequence = GY_CUSTOMER then
            p_text := msc_get_name.customer(p_char1);
         elsif p_sequence = GY_CUSTOMER_SITE then
            p_text := msc_get_name.customer_site(p_char1);
         elsif p_sequence in (8,9) then -- an org
               p_text := msc_get_name.org_code(p_char1,arg_instance_id);
               if p_sequence = 8 then -- forecast without customer
                  p_text := p_text ||' - '||g_other_text;
               end if;
         elsif p_sequence = 1 then -- total
               p_text := g_total_text;
         else
               p_text := p_char1;
         end if;



            if p_text is null then
--dbms_output.put_line('no text for '||p_char1||','||p_sequence);
               p_text := p_char1;
            end if;

      exception when others then
         p_text := p_char1;
      end;

      p_text := replace(p_text, '*', '&');
      FOR a in 1 .. NUM_OF_TYPES LOOP
          INSERT INTO msc_drp_hori_plans(
             query_id,
             organization_id,
             sr_instance_id,
             inventory_item_id,
             row_type,
             char1,
             sub_org_id,
             horizontal_plan_type,
             bucket_date,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             quantity)
           VALUES (
             arg_query_id,
             arg_org_id,
             arg_instance_id,
             arg_item_id,
             row_header_type(a), -- row_type
             p_text,
             p_id, -- store customer_id, customer_site_id, priority, to org id
             p_sequence,
             var_dates(bkt),
             SYSDATE,
             -1,
             SYSDATE,
             -1,
             decode(p_sequence, 1,
                    total_row(bkt + (a-1)*g_num_of_buckets),
                    row_detail(bkt + (a-1)*g_num_of_buckets)));
      END LOOP;

    END LOOP; -- end of FOR bkt IN

    g_error_stmt := 'Debug - flush_item_plan - 80';

END flush_item_plan;

BEGIN

  g_error_stmt := 'Debug - populate_horizontal_plan - 10';

  if g_other_text is null then
     fnd_message.set_name('MSC', 'MSC_OTHER');
     g_other_text := fnd_message.get;
     fnd_message.set_name('MSC', 'MSC_TOTAL');
     g_total_text := fnd_message.get;
  end if;

  OPEN plan_buckets;
  FETCH plan_buckets into g_org_id, g_inst_id;
  CLOSE plan_buckets;

    -- --------------------
    -- Get the bucket dates
    -- --------------------
    OPEN bucket_dates;
    LOOP
      FETCH bucket_dates INTO l_bucket_date, l_bkt_end_date;
      EXIT WHEN BUCKET_DATES%NOTFOUND;
      var_dates(l_bucket_number) := l_bucket_date;
      l_bucket_number := l_bucket_number + 1;
    END LOOP;
    CLOSE bucket_dates;
    var_dates(l_bucket_number) := l_bkt_end_date +1;

  g_num_of_buckets := var_dates.count -1;
--dbms_output.put_line('g_num_of_buckets='||g_num_of_buckets);
  g_error_stmt := 'Debug - populate_horizontal_plan - 20';

  -- Initialize the bucket cells to 0.

          FOR a IN 1..(NUM_OF_TYPES*g_num_of_buckets) LOOP
               row_detail(a) := 0;
               total_row(a) := 0;
          END LOOP;
--dbms_output.put_line('total rows='||total_row.count);
  -- associate offset with rowtype

    row_header_type(UNC_DEMAND_OFF) := HZ_UNC_DEMAND;
    row_header_type(EXP_DEMAND_OFF) := HZ_EXP_DEMAND;
    row_header_type(SUPPLY_OFF) :=  HZ_SUPPLY;
    row_header_type(FIRM_ALLOC_OFF) := HZ_FIRM_ALLOC;
    row_header_type(SUGG_ALLOC_OFF) := HZ_SUGG_ALLOC;
    row_header_type(ADJ_ALLOC_OFF) := HZ_ADJ_ALLOC;
    row_header_type(EFFECT_ALLOC_OFF) := HZ_EFFECT_ALLOC;
--    row_header_type(ADJ_CUM_FILL_RATE_OFF) := HZ_ADJ_CUM_FILL_RATE;
    row_header_type(CUM_UNC_DEMAND_OFF) := HZ_CUM_UNC_DEMAND;
    row_header_type(CUM_EXP_DEMAND_OFF) := HZ_CUM_EXP_DEMAND;
    row_header_type(CUM_SUPPLY_OFF) := HZ_CUM_SUPPLY;
    row_header_type(CUM_SUGG_ALLOC_OFF) := HZ_CUM_SUGG_ALLOC;
    row_header_type(CUM_FILL_RATE_OFF) := HZ_CUM_FILL_RATE;


  g_error_stmt := 'Debug - populate_horizontal_plan - 40';
  bucket_counter := 2;
  old_bucket_counter := 2;
     activity_rec.offset := 0;
     activity_rec.char1 := '0';
     activity_rec.new_date := sysdate;
     activity_rec.quantity := 0;
     activity_rec.quantity2 := 0;

  OPEN allocation_plan_activity;
  LOOP
        FETCH allocation_plan_activity INTO  activity_rec;
        IF (allocation_plan_activity%NOTFOUND OR
            activity_rec.char1 <> last_char1 OR
            activity_rec.sequence <> last_sequence) and
            last_char1 <> '-1' THEN

        if last_char1 not in ('total','dummy') then
           -- don't flush for summary row yet
--dbms_output.put_line('flush '||last_char1||','||activity_rec.sequence||','||last_sequence);
           flush_item_plan(last_char1, last_sequence);
        end if;

        -- ------------------------------------
        -- Initialize the bucket cells to 0.
        -- ------------------------------------
          bucket_counter := 2;
          old_bucket_counter := 2;
          FOR a IN 1..(NUM_OF_TYPES*g_num_of_buckets) LOOP
               row_detail(a) := 0;
          END LOOP;

      END IF;  -- end of activity_rec.item_id <> last_item_id
        EXIT WHEN allocation_plan_activity%NOTFOUND;
--dbms_output.put_line('char1='||activity_rec.char1||','||activity_rec.new_date||','||activity_rec.quantity||','||activity_rec.offset||','||activity_rec.sequence );
      -- find the correct bucket
      IF activity_rec.new_date >= var_dates(bucket_counter) THEN
        WHILE activity_rec.new_date >= var_dates(bucket_counter) AND
              bucket_counter <= g_num_of_buckets LOOP
          bucket_counter := bucket_counter + 1;
        END LOOP;
      END IF;

      add_to_plan(bucket_counter -1,
                     activity_rec.offset,
                     activity_rec.quantity);

      IF activity_rec.offset = UNC_DEMAND_OFF THEN

         add_to_plan(bucket_counter -1,
                     EXP_DEMAND_OFF,
                     activity_rec.quantity2);

      END IF;

      g_error_stmt := 'Debug - populate_horizontal_plan - 42';
/*
      IF activity_rec.offset = TOTAL_DEMAND_OFF and
         activity_rec.quantity2 <> 0 then
        WHILE activity_rec.new_date2 >= var_dates(old_bucket_counter) AND
             old_bucket_counter <= g_num_of_buckets LOOP
          -- ----------
          -- move back.
          -- ----------
          old_bucket_counter := old_bucket_counter + 1;

        END LOOP;

        WHILE activity_rec.new_date2 < var_dates(old_bucket_counter - 1)  AND
              old_bucket_counter > 2  LOOP
          -- -------------
          -- move forward.
          -- -------------
          old_bucket_counter := old_bucket_counter  - 1;
        END LOOP;
        IF activity_rec.new_date2 < var_dates(old_bucket_counter) THEN
          add_to_plan(old_bucket_counter - 1,
                      MNUL_ALLOC_OFF,
                      activity_rec.quantity2);
          add_to_plan(old_bucket_counter - 1,
                      PRIOR_ALLOC_OFF,
                      activity_rec.quantity3);
        END IF;
      END IF;
*/
    last_char1 := activity_rec.char1;
    last_sequence := activity_rec.sequence;

  END LOOP;

  g_error_stmt := 'Debug - populate_horizontal_plan - 50';
  CLOSE allocation_plan_activity;

  flush_item_plan('total', 1); -- flush the summary row now

EXCEPTION

  WHEN OTHERS THEN
--    dbms_output.put_line(g_error_stmt);
    raise;

END populate_allocation_plan;

FUNCTION send_dates RETURN varchar2 IS
  p_dates varchar2(30000);
BEGIN
    FOR bkt IN 1..g_num_of_buckets LOOP
        p_dates := p_dates ||'|'||fnd_date.date_to_displaydate(var_dates(bkt));
    END LOOP;
  p_dates := g_num_of_buckets||p_dates;
  return p_dates;
END send_dates;

PROCEDURE create_planned_arrival(
                       p_plan_id in number, p_org_id in number,
                       p_inst_id in number, p_item_id in number,
                       p_source_org in number, p_source_inst in number,
                       p_bkt_start_date in date,
                       p_allocate_qty in number) IS
  cursor org_c is
    select ship_method,avg_transit_lead_time
      from msc_item_sourcing mis
     where mis.plan_id = p_plan_id
       and mis.inventory_item_id =  p_item_id
       and mis.source_organization_id = p_source_org
       and mis.sr_instance_id2 = p_source_inst
       and mis.organization_id = p_org_id
       and mis.sr_instance_id = p_inst_id
     order by rank,allocation_percent desc,avg_transit_lead_time;

  p_due_date date;
  p_dock_date date;
  p_ship_date date  := p_bkt_start_date;
  p_lead_time number;
  p_deliver_calendar varchar2(20);
  p_receive_calendar varchar2(20);
  p_ship_calendar varchar2(20);
  p_ship_method varchar2(30);
  v_pp_lead_time number;
  l_user_id  number := fnd_global.user_id;
  l_transaction_id number;
  p_associate_type number;
  supply_columns msc_undo.changeRGType;
  x_return_sts VARCHAR2(20);
  x_msg_count NUMBER;
  x_msg_data VARCHAR2(2000);

BEGIN

  OPEN org_c;
  FETCH org_c INTO p_ship_method, p_lead_time;
  CLOSE org_c;

--dbms_output.put_line(p_ship_method||', '|| p_lead_time);
  msc_drp_util.offset_dates('SHIP_DATE',
                   p_plan_id,
                   p_source_org,
                   p_org_id,
                   p_inst_id,
                   p_item_id,
                   p_ship_method,
                   p_lead_time, p_ship_calendar,
                   p_deliver_calendar, p_receive_calendar,
                   p_ship_date,
                   p_dock_date,
                   p_due_date);

--dbms_output.put_line('dock date='||p_dock_date);
  select msc_supplies_s.nextval into l_transaction_id from dual;
--dbms_output.put_line('id ='||l_transaction_id);
  insert into msc_supplies(
              transaction_id,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              inventory_item_id,
              organization_id,
              sr_instance_id,
              plan_id,
              new_schedule_date,
              order_type,
              new_order_quantity,
              new_dock_date,
              new_ship_date,
              status,
              applied,
              firm_planned_type,
              firm_date,
              firm_ship_date,
              firm_quantity,
              source_organization_id,
	      source_sr_instance_id,
              ship_method,
              intransit_lead_time,
              ship_calendar,
              intransit_calendar,
              receiving_calendar)
              values (
              l_transaction_id,
              sysdate,
              l_user_id,
              sysdate,
              l_user_id,
              l_user_id,
              p_item_id,
              p_org_id,
              p_inst_id,
              p_plan_id,
              p_due_date,
              51,
              0,
              p_dock_date,
              p_ship_date,
              0,
              2,
              1,
              p_due_date,
              p_ship_date,
              p_allocate_qty,
              p_source_org,
              p_source_inst,
              p_ship_method,
              p_lead_time,
              p_ship_calendar,
              p_deliver_calendar,
              p_receive_calendar);
    -- mark undo

   msc_undo.store_undo(1, --table_changed
                1,     --insert or update
                l_transaction_id,
                p_plan_id,
                p_inst_id,
                NULL,
                supply_columns,
                x_return_sts,
                x_msg_count,
                x_msg_data,
                null);

exception when others then
  raise;
END create_planned_arrival;

PROCEDURE query_list(
		p_query_id IN NUMBER,
                p_plan_id IN NUMBER,
                p_org_id IN NUMBER,
                p_inst_id IN NUMBER,
                p_category_set IN NUMBER,
                p_category_name IN VARCHAR2) IS

  sql_stmt 	VARCHAR2(5000);
  p_org_code    varchar2(80);
BEGIN
  sql_stmt := 'INSERT INTO msc_form_query ( '||
        'query_id, '||
        'last_update_date, '||
        'last_updated_by, '||
        'creation_date, '||
        'created_by, '||
        'last_update_login, '||
        'number1, '|| -- item_id
        'number2, '|| -- org_id
        'number3, '|| -- inst_id
        'number4, '|| -- plan_id
        'number5, '|| -- displayed item_id
        'number6, '|| -- displayed org_id
        'number7, '|| -- node type
        'number8, '|| -- org sequence
        'char1, '||
        'char2) '||
  ' SELECT DISTINCT :p_query_id, '||
        'sysdate, '||
        '1, '||
        'sysdate, '||
        '1, '||
        '1, '||
        'msi.inventory_item_id, '||
        'msi.organization_id, '||
        'msi.sr_instance_id, '||
        'msi.plan_id, '||
        '-1,'||
        ' :p_org_id, '||
        ' 0, ' || -- NODE_REGULAR_ITEM
        ' 1, '||  -- org seq
        ' :p_org_code,'||
        'mic.category_name '||
  ' FROM msc_system_items msi, msc_item_categories mic' ||
  ' WHERE mic.organization_id = msi.organization_id ' ||
        'AND     mic.sr_instance_id = msi.sr_instance_id ' ||
        'AND     mic.inventory_item_id = msi.inventory_item_id ' ||
        'AND     mic.category_set_id = :p_category_set '||
        'AND     mic.category_name = :p_category_name '||
        'AND     msi.plan_id = :p_plan_id ';

   if p_org_id <> -1 then
     sql_stmt := sql_stmt ||
        ' and msi.sr_instance_id = :p_inst_id '||
        ' and msi.organization_id = :p_org_list ';
        p_org_code := msc_get_name.org_code(p_org_id, p_inst_id);
   else  -- item across all orgs
     sql_stmt := sql_stmt ||
        ' and -1 = :p_inst_id '||
        ' and -1 = :p_org_list ';
        p_org_code := 'All Orgs for this Plan';
   end if;
-- dbms_output.put_line(p_inst_id||','||p_org_id||','||p_category_name);
   EXECUTE IMMEDIATE sql_stmt using p_query_id,p_org_id,p_org_code,
                       p_category_set, p_category_name, p_plan_id,
                       p_inst_id,p_org_id;

END query_list;

FUNCTION flush_suggAlloc_drillDown(p_item_query_id number,
                                   p_sub_type number,
                                   p_start_date date, p_end_date date)
                                  return NUMBER IS
p_query_id number;
BEGIN

  SELECT msc_form_query_s.nextval
  INTO p_query_id
  FROM dual;

if p_sub_type in (1,9) then -- total, reqular org
   insert into msc_form_query(
        query_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        number1)
        SELECT distinct p_query_id,
         sysdate,
         1,
         sysdate,
         1,
         1,
         mslp.parent_id
   from msc_supplies ms,
        msc_supplies parent,
        msc_single_lvl_peg mslp,
        msc_form_query mfq
 where  ms.organization_id = mfq.number2
    AND ms.sr_instance_id = mfq.number3
    and ms.plan_id = mfq.number4
    and ms.inventory_item_id = mfq.number1
    and mslp.plan_id = ms.plan_id
    and mslp.pegging_type = 1 -- supply to parent supply
    and mslp.child_id = ms.transaction_id
    and mslp.parent_id = parent.transaction_id
    and mslp.plan_id = parent.plan_id
    and parent.order_type = 51
    and ms.new_schedule_date between p_start_date and p_end_date
    and mfq.query_id = p_item_query_id;

   insert into msc_form_query(
        query_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        number1)
        SELECT distinct p_query_id,
         sysdate,
         1,
         sysdate,
         1,
         1,
         md.demand_id
   from msc_supplies ms,
        msc_supplies parent,
        msc_demands md,
        msc_single_lvl_peg mslp,
        msc_form_query mfq
 where  ms.organization_id = mfq.number2
    AND ms.sr_instance_id = mfq.number3
    and ms.plan_id = mfq.number4
    and ms.inventory_item_id = mfq.number1
    and mslp.plan_id = ms.plan_id
    and mslp.pegging_type = 1 -- supply to parent supply
    and mslp.child_id = ms.transaction_id
    and mslp.parent_id = parent.transaction_id
    and mslp.plan_id = parent.plan_id
    and parent.order_type = 2
    and md.plan_id = parent.plan_id
    and md.disposition_id = parent.transaction_id
    and ms.new_schedule_date between p_start_date and p_end_date
    and mfq.query_id = p_item_query_id;
 end if; -- if p_sub_type in (1,9) then

 if p_sub_type <> 9 then -- not a reqular org
   insert into msc_form_query(
        query_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        number1)
        SELECT distinct p_query_id,
         sysdate,
         1,
         sysdate,
         1,
         1,
         mslp.parent_id
   from msc_supplies ms,
        msc_single_lvl_peg mslp,
        msc_demands    md,
        msc_form_query mfq
 where  ms.organization_id = mfq.number2
    AND ms.sr_instance_id = mfq.number3
    and ms.plan_id = mfq.number4
    and ms.inventory_item_id = mfq.number1
    and mslp.plan_id = ms.plan_id
    and mslp.pegging_type = 2 -- supply to parent demand
    and mslp.child_id = ms.transaction_id
    and md.plan_id = mslp.plan_id
    and md.demand_id = mslp.parent_id
    and md.origination_type in (24,29,30)
    and nvl(md.demand_source_type,0) <> 8
    and ms.new_schedule_date between p_start_date and p_end_date
    and mfq.query_id = p_item_query_id;
end if; -- if p_sub_type <> 9 then -- not a reqular org

 return p_query_id;
EXCEPTION when others THEN
 return p_query_id;
END flush_suggAlloc_drillDown;

END MSC_ALLOCATION_PLAN;

/
