--------------------------------------------------------
--  DDL for Package Body MSC_VERTICAL_PLAN_SC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_VERTICAL_PLAN_SC" AS
/*  $Header: MSCVERPB.pls 115.15 2004/05/26 16:16:42 eychen ship $ */

Procedure populate_bucketed_quantity (
                             arg_plan_id IN NUMBER,
                             arg_instance_id IN NUMBER,
                             arg_org_id IN NUMBER,
                             arg_item_id IN NUMBER,
                             arg_cutoff_date IN DATE,
                             arg_bucket_type IN VARCHAR2,
                             p_quantity_string OUT NOCOPY VARCHAR2,
                             p_period_string OUT NOCOPY VARCHAR2,
                             p_period_count  OUT NOCOPY NUMBER) IS
g_param varchar2(3):=':';
-- ----------------------------------------
-- This cursor selects the activity for
-- current data
-- ----------------------------------------
CURSOR  mrp_vertical_plan IS
SELECT
        new_due_date new_date,
        inventory_item_id item_id,
        organization_id org_id,
        sum(quantity_rate) new_quantity
from    msc_vertical_plan_v plan
where   plan.inventory_item_id = arg_item_id
and     plan.organization_id = arg_org_id
and     plan.plan_id = arg_plan_id
and     plan.sr_instance_id = arg_instance_id
-- and     plan.new_due_date < arg_cutoff_date
GROUP BY
        new_due_date,
        organization_id,
        inventory_item_id
ORDER BY
     1, 2, 3;

activity_rec     mrp_vertical_plan%ROWTYPE;

TYPE calendar_date IS TABLE OF DATE INDEX BY BINARY_INTEGER;
-- TYPE column_number IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE column_char   IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;

var_dates           calendar_date;   -- Holds the start dates of buckets
bucket_cells_tab    column_number;   -- Holds the quantities per bucket
v_period            column_char;     -- holds the period name
last_item_id        NUMBER := -1;
last_org_id        NUMBER := -1;
last_plan          VARCHAR2(10) := '-1';
last_org           VARCHAR2(10);
last_item          VARCHAR2(20);

bucket_counter BINARY_INTEGER := 0; -- Id of the current bucket
counter        BINARY_INTEGER := 0;
g_num_of_buckets    NUMBER;
-- =============================================================================
--
-- add_to_plan add the 'quantity' to the correct cell of the current bucket.
--
-- =============================================================================
PROCEDURE add_to_plan(location IN NUMBER,
                      quantity IN NUMBER) IS
BEGIN
  bucket_cells_tab(location) := NVL(bucket_cells_tab(location),0) + quantity;

END;


PROCEDURE flush_item_plan IS
BEGIN

  FOR counter in 1..g_num_of_buckets LOOP
    IF counter > 1 THEN -- calculate the running total

     bucket_cells_tab(counter) := bucket_cells_tab(counter)+
                                 bucket_cells_tab(counter-1);
    END IF;

    p_quantity_string:=  p_quantity_string
       ||g_param||
         fnd_number.number_to_canonical(bucket_cells_tab(counter));
  END LOOP;

  bucket_counter := 2;

  FOR counter IN 1..g_num_of_buckets LOOP
            bucket_cells_tab(counter) := 0;
  END LOOP;

END flush_item_plan;

PROCEDURE get_bucket_dates IS

   CURSOR day_bucket IS
     SELECT to_char(mpsd.calendar_date,'DD-MM-RR'),
                mpsd.calendar_date
     FROM   msc_trading_partners tp,
            msc_calendar_dates mpsd,
            msc_plans mp
     WHERE  mpsd.calendar_code = tp.calendar_code
     and mpsd.sr_instance_id = tp.sr_instance_id
     and mpsd.exception_set_id = tp.calendar_exception_set_id
     and mpsd.seq_num is not null
     and tp.sr_instance_id = arg_instance_id
     and tp.sr_tp_id = arg_org_id
     and tp.partner_type =3
     and mp.plan_id = arg_plan_id
     and mpsd.calendar_date between mp.data_start_date
                                 and mp.cutoff_date
--     and rownum <30
     order by mpsd.calendar_date;

   CURSOR week_bucket IS
     SELECT to_char(mpsd.week_start_date,'DD-MM-RR'), mpsd.week_start_date
     FROM   msc_trading_partners tp,
            msc_cal_week_start_dates mpsd,
            msc_plans mp
     WHERE  mpsd.calendar_code = tp.calendar_code
     and mpsd.sr_instance_id = tp.sr_instance_id
     and mpsd.exception_set_id = tp.calendar_exception_set_id
     and tp.sr_instance_id = nvl(arg_instance_id, tp.sr_instance_id)
     and tp.sr_tp_id = arg_org_id
     and tp.partner_type =3
     and mp.plan_id = arg_plan_id
     and (mpsd.week_start_date between mp.data_start_date
                                 and mp.cutoff_date
         or mpsd.next_date between mp.data_start_date and
                                   mp.cutoff_date)
     order by mpsd.week_start_date;

   CURSOR period_bucket IS
     SELECT mpsd.period_name, mpsd.period_start_date
     FROM   msc_trading_partners tp,
            msc_period_start_dates mpsd,
            msc_plans mp
     WHERE  mpsd.calendar_code = tp.calendar_code
     and mpsd.sr_instance_id = tp.sr_instance_id
     and mpsd.exception_set_id = tp.calendar_exception_set_id
     and tp.sr_instance_id = nvl(arg_instance_id, tp.sr_instance_id)
     and tp.sr_tp_id = arg_org_id
     and tp.partner_type =3
     and mp.plan_id = arg_plan_id
     and (mpsd.period_start_date between mp.data_start_date
                                 and mp.cutoff_date
         or mpsd.next_date between mp.data_start_date and
                                   mp.cutoff_date)
     order by mpsd.period_start_date;

BEGIN

   counter :=1;
   IF arg_bucket_type = 'DAY' THEN
      OPEN day_bucket;
   ELSIF arg_bucket_type = 'WEEK' THEN
      OPEN week_bucket;
   ELSIF arg_bucket_type = 'PERIOD' THEN
      OPEN period_bucket;
   END IF;
   LOOP
   IF arg_bucket_type = 'DAY' THEN
     FETCH day_bucket into v_period(counter),var_dates(counter);
     EXIT WHEN day_bucket%NOTFOUND;
   ELSIF arg_bucket_type = 'WEEK' THEN
     FETCH week_bucket into v_period(counter),var_dates(counter);
     EXIT WHEN week_bucket%NOTFOUND;
   ELSIF arg_bucket_type = 'PERIOD' THEN
     FETCH period_bucket into v_period(counter),var_dates(counter);
     EXIT WHEN period_bucket%NOTFOUND;
   END IF;

   counter := counter +1;
   END LOOP;
   IF arg_bucket_type = 'DAY' THEN
      CLOSE day_bucket;
   ELSIF arg_bucket_type = 'WEEK' THEN
      CLOSE week_bucket;
   ELSIF arg_bucket_type = 'PERIOD' THEN
      CLOSE period_bucket;
   END IF;
--dbms_output.put_line('counter='||counter);
   g_num_of_buckets := counter-1;
   p_period_count := counter-1;
END get_bucket_dates;

-- =============================================================================
BEGIN

   get_bucket_dates;

  -- ---------------------------------
  -- Initialize the bucket cells to 0.
  -- ---------------------------------
    FOR counter IN 1..g_num_of_buckets LOOP
      bucket_cells_tab(counter) := 0;
      p_period_string := p_period_string ||g_param||v_period(counter);
    END LOOP;

--  last_date :=var_dates(g_num_of_buckets);

  bucket_counter := 2;

  OPEN mrp_vertical_plan;
  LOOP
  FETCH mrp_vertical_plan INTO  activity_rec;
      IF (mrp_vertical_plan%NOTFOUND) and
         (mrp_vertical_plan%ROWCOUNT =0) THEN
         flush_item_plan;
      END IF;

      IF ((mrp_vertical_plan%NOTFOUND) OR
          (activity_rec.item_id <> last_item_id) OR
          ( activity_rec.org_id  <> last_org_id)) AND
         last_item_id <> -1 THEN

        -- --------------------------
        -- Need to flush the plan for
        -- the previous item.
        -- --------------------------

        flush_item_plan;


      END IF;

      EXIT WHEN mrp_vertical_plan%NOTFOUND;
      IF activity_rec.new_date >= var_dates(bucket_counter) THEN
       WHILE activity_rec.new_date >= var_dates(bucket_counter) AND
              bucket_counter <= g_num_of_buckets LOOP
          bucket_counter := bucket_counter + 1;
       END LOOP;
      END IF;

      IF activity_rec.new_date < var_dates(bucket_counter) THEN
        add_to_plan(bucket_counter - 1,
                    activity_rec.new_quantity);
      END IF;

    last_item_id := activity_rec.item_id;
    last_org_id := activity_rec.org_id;
  END LOOP;

  CLOSE mrp_vertical_plan;

  EXCEPTION WHEN NO_DATA_FOUND THEN
--dbms_output.put_line('no data found');
    flush_item_plan;
    close mrp_vertical_plan;
END;

FUNCTION get_exception_group(l_where varchar2) RETURN column_number IS
   statement varchar2(4000);
   TYPE cur IS REF CURSOR;
   group_cursor cur;
   exception_group column_number;
   i number;
BEGIN
  i := 1;
  OPEN group_cursor FOR l_where;
  LOOP
  FETCH group_cursor into exception_group(i);
  EXIT WHEN group_cursor%NOTFOUND;
  i := i+1;
  END LOOP;
  CLOSE group_cursor;

  return exception_group;
END get_exception_group;

PROCEDURE flush_multi_return ( p_sd_table in msc_vertical_plan_sc.sd_tbl_type) IS
BEGIN
  FORALL j IN 1..p_sd_table.p_query_id.COUNT
    insert into msc_form_query (query_id, number1,
          last_update_date, last_updated_by,
          creation_date, created_by, last_update_login)
    values (p_sd_table.p_query_id(j),
            p_sd_table.p_number_1(j),
            sysdate,-1,
            sysdate,-1,-1);

END flush_multi_return;


END Msc_VERTICAL_PLAN_SC;

/
