--------------------------------------------------------
--  DDL for Package Body MSC_DS_SCHEDULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_DS_SCHEDULE" AS
/* $Header: MSCDSSB.pls 120.0 2005/05/25 18:26:26 appldev noship $  */

  procedure getScheduleSummary(p_plan_id number, p_cat_set_id number, p_recom_days number,
    p_late_supply_total out nocopy number, p_res_cons_total out nocopy number,
    p_mat_cons_total out nocopy number, p_exc_setup_total out nocopy number,
    p_resched_total out nocopy number, p_release_total out nocopy number) is

    -- 87 Late Supply
    -- 36 Resource constraint
    -- 37 Material constraint
    -- 90 Excessive Setups
    -- 6,7 Orders to be Rescheduled In" and "Orders to be Rescheduled Out"
    cursor c_exc_summary  is
    select exception_type, count(*) exc_count
    from msc_exception_details_v
    where plan_id = p_plan_id
      and nvl(category_set_id, p_cat_set_id) = p_cat_set_id
      and exception_type in (87, 36, 37, 90, 6, 7)
    group by exception_type;

    cursor c_release is
    select count(*) rel_count
    from msc_orders_v
    where plan_id = p_plan_id
    and source_table = 'MSC_SUPPLIES'
    and order_type = 3
    and nvl(release_status,2) = 2
    and nvl(category_set_id, p_cat_set_id) = p_cat_set_id
    and new_order_date <= (select p.plan_start_date + p_recom_days
    from msc_plans p
    where p.plan_id = p_plan_id );

  begin
    p_resched_total := 0;
    p_release_total := 0;

    for exc_summary_row in c_exc_summary
    loop
      if (exc_summary_row.exception_type = 87) then
        p_late_supply_total := exc_summary_row.exc_count;
      elsif (exc_summary_row.exception_type = 36) then
        p_res_cons_total := exc_summary_row.exc_count;
      elsif (exc_summary_row.exception_type = 37) then
        p_mat_cons_total := exc_summary_row.exc_count;
      elsif (exc_summary_row.exception_type = 90) then
        p_exc_setup_total := exc_summary_row.exc_count;
      elsif (exc_summary_row.exception_type in (6,7)) then
        p_resched_total := p_resched_total + exc_summary_row.exc_count;
      end if;
     end loop;

     open c_release;
     fetch c_release into p_release_total;
     close c_release;

  end getScheduleSummary;

  procedure getLateSupplySummary(p_plan_id number, p_cat_set_id number,
    p_round_val number, p_total_supply out nocopy number, p_late_supply out nocopy number,
    p_avg_days_late out nocopy number, p_past_due_supply out nocopy number) is

    cursor c_late_supply is
    select round(sum(total_supply_count),p_round_val),
      round(sum(late_supply_count),p_round_val),
      round(avg(total_days_late),p_round_val)
    from msc_bis_plan_summary_kpi
    where plan_id = p_plan_id;

    cursor c_pas_due is
    select count(*)
    from msc_exception_details_v
    where plan_id = p_plan_id
      and exception_type = 10
      and nvl(category_set_id, p_cat_set_id) = p_cat_set_id;

  begin
    open c_late_supply;
    fetch c_late_supply into p_total_supply, p_late_supply, p_avg_days_late;
    close c_late_supply;

    open c_pas_due;
    fetch c_pas_due into p_past_due_supply;
    close c_pas_due;

  end getLateSupplySummary;

  procedure getLateSupplyDetails(p_plan_id number, p_cat_set_id number,
    p_round_val number, p_name_data in out nocopy msc_ds_schedule.maxCharTbl) is

    cursor c_late_supplies is
    select to_date(key_date,'J') detail_date,
      round(nvl(total_supply_count,0), p_round_val) total_supply_count,
      round(nvl(late_supply_count,0), p_round_val) late_supply_count,
      round(nvl(total_days_late,0), p_round_val) total_days_late
    from msc_bis_plan_summary_kpi
    where plan_id = p_plan_id
    order by to_date(key_date,'J');

    i number := 1;
    j number := 0;
    k number := 1;

    l_one_record varchar2(300);
    oneBigRecord maxCharTbl := maxCharTbl(0);
    l_max_len number;
    rowCount number;

  begin
    rowCount := 0;
    oneBigRecord.delete;
    oneBigRecord.extend;
    j := 1;
    for c_late_supplies_row in c_late_supplies
    loop
        rowCount := rowCount + 1;

	l_one_record := to_char(c_late_supplies_row.detail_date, FORMAT_MASK)
	  || FIELD_SEPERATOR ||to_char(c_late_supplies_row.total_supply_count)
	  || FIELD_SEPERATOR ||to_char(c_late_supplies_row.late_supply_count)
	  || FIELD_SEPERATOR ||to_char(c_late_supplies_row.total_days_late);

        l_max_len := nvl(length(oneBigRecord(j)),0) + nvl(length(l_one_record),0);
        if l_max_len > 30000 then
          j := j+1;
          oneBigRecord.extend;
        end if;
        if ( oneBigRecord(j) is null ) then
          oneBigRecord(j) := l_one_record;
        else
          oneBigRecord(j) := oneBigRecord(j) || record_seperator ||l_one_record;
        end if;
    end loop;

    p_name_data.delete;
    p_name_data.extend;
    j := 1;
    p_name_data(k) := rowCount || record_seperator||oneBigRecord(1);

    for j in 2.. oneBigRecord.count loop
      p_name_data.extend;
      k := k+1;
      p_name_data(k) := oneBigRecord(j);
    end loop;

  end getLateSupplyDetails;

  procedure getResUtilDetails(p_plan_id number, p_resource_basis number,
    p_round_val number, p_name_data in out nocopy msc_ds_schedule.maxCharTbl) is

    cursor c_util_details is
    select mbrs.resource_date detail_date,
      round(avg(nvl(mbrs.utilization,0)),p_round_val) run_util,
      round(avg(nvl(mbrs.utilization,0)),p_round_val) setup_util -- pabram..need to change later
    from msc_bis_res_summary mbrs,
    msc_department_resources mdr
    where mbrs.plan_id = mdr.plan_id
      and mbrs.sr_instance_id = mdr.sr_instance_id
      and mbrs.organization_id = mdr.organization_id
      and mbrs.department_id = mdr.department_id
      and mbrs.resource_id = mdr.resource_id
      and mbrs.plan_id = p_plan_id
    group by mbrs.resource_date
    order by resource_date;
    i number := 1;
    j number := 0;
    k number := 1;

    l_one_record varchar2(300);
    oneBigRecord maxCharTbl := maxCharTbl(0);
    l_max_len number;
    rowCount number;

  begin
    rowCount := 0;
    oneBigRecord.delete;
    oneBigRecord.extend;
    j := 1;
    for c_util_details_row in c_util_details
    loop
        rowCount := rowCount + 1;

	l_one_record := to_char(c_util_details_row.detail_date, FORMAT_MASK)
	  || FIELD_SEPERATOR ||to_char(c_util_details_row.run_util)
	  || FIELD_SEPERATOR ||to_char(c_util_details_row.setup_util);

        l_max_len := nvl(length(oneBigRecord(j)),0) + nvl(length(l_one_record),0);
        if l_max_len > 30000 then
          j := j+1;
          oneBigRecord.extend;
        end if;
        if ( oneBigRecord(j) is null ) then
          oneBigRecord(j) := l_one_record;
        else
          oneBigRecord(j) := oneBigRecord(j) || record_seperator ||l_one_record;
        end if;
    end loop;

    p_name_data.delete;
    p_name_data.extend;
    j := 1;
    p_name_data(k) := rowCount || record_seperator||oneBigRecord(1);

    for j in 2.. oneBigRecord.count loop
      p_name_data.extend;
      k := k+1;
      p_name_data(k) := oneBigRecord(j);
    end loop;
  end getResUtilDetails;

  procedure getResUtilSummary(p_plan_id number, p_resource_basis number,
    p_round_val number, p_actual_util out nocopy number, p_setup_util out nocopy number) is

    cursor c_util_summary is
    select round(avg(nvl(mbrs.utilization,0)),p_round_val) actual_util,
      round(avg(nvl(mbrs.utilization,0)),p_round_val) setup_util  -- pabram..need to change later
    from msc_bis_res_summary mbrs,
    msc_department_resources mdr
    where mbrs.plan_id = mdr.plan_id
      and mbrs.sr_instance_id = mdr.sr_instance_id
      and mbrs.organization_id = mdr.organization_id
      and mbrs.department_id = mdr.department_id
      and mbrs.resource_id = mdr.resource_id
      and mbrs.plan_id = p_plan_id
      and ( ( p_resource_basis = 1 )
          or  ( p_resource_basis = 2 and bottleneck_flag = 1));
  begin
    open c_util_summary;
    fetch c_util_summary into p_actual_util, p_setup_util;
    close c_util_summary;
  end getResUtilSummary;

end msc_ds_schedule;

/
