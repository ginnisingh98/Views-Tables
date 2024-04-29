--------------------------------------------------------
--  DDL for Package Body MSC_NETCHANGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_NETCHANGE_PKG" AS
/*  $Header: MSCNETCB.pls 120.2 2005/07/01 08:41:01 eychen noship $ */

    TYPE number_arr IS TABLE OF number;
    TYPE date_arr IS TABLE OF date;
    TYPE char_arr IS TABLE OF varchar2(250);
    TYPE long_char_arr IS TABLE OF varchar2(500);

    NOT_COMPARED CONSTANT INTEGER :=1;
    IN_PROGRESS CONSTANT INTEGER :=2;
    NEED_RECOMPARE CONSTANT INTEGER :=3;
    AVAILABLE INTEGER :=4;

g_options_query_id number;
g_excp_query_id number;
g_from_plan number;
g_to_plan number;
g_cat_set number;
g_cat_set_name varchar2(30);
g_yes varchar2(10);
g_no varchar2(10);
g_misc char_arr;
g_need_insert_temp boolean;
g_long_query boolean;

Procedure compare_plans(from_plan number,
                       to_plan number,
                       options_flag number,
                       p_folder_id number,
                       exception_list varchar2,
                       p_criteria_id number,
                       option_query_id out nocopy number,
                       exception_query_id out nocopy number
                       )  IS
    item_where_clause varchar2(32000);
    res_where_clause varchar2(32000);
    p_all_excp_list varchar2(500):=',1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,';
    p_excp_list varchar2(500);
    p_group_by_id number;
    p_options_flag number := 1;
    one_rec varchar2(400);
    p_operator varchar2(30);

    CURSOR criteria_c IS
     select mnc.group_by_id,
            mnc.exception_type,
            mnc.options_flag
       from msc_net_change_criteria mnc
      where mnc.criteria_id = p_criteria_id
        and mnc.user_id = fnd_global.user_id;

    CURSOR filter_c IS
     select msc.field_name,
            msc.hidden_from_field,
            msc.condition,
            msc.from_field,
            msc.to_field,
            msc.field_type,
            mc.data_set,
            msc.folder_object
       from msc_selection_criteria msc,
            msc_criteria mc
      where msc.folder_id = p_folder_id
        and msc.folder_object in ('MSC_NET_ITEM','MSC_NET_RESOURCE')
        and msc.folder_object = mc.folder_object
        and msc.field_name = mc.field_name;

     item_rec filter_c%ROWTYPE;
     a number;
BEGIN
     option_query_id :=0;
     exception_query_id :=0;
     g_from_plan := from_plan;
     g_to_plan := to_plan;

     if options_flag is null then
        OPEN criteria_c;
        FETCH criteria_c INTO p_group_by_id, p_excp_list, p_options_flag;
        CLOSE criteria_c;

     else
        p_options_flag := options_flag;
        p_excp_list := exception_list;
     end if;
     g_need_insert_temp := false;
     g_long_query := false;

 if p_excp_list is null then
    p_excp_list := p_all_excp_list;
 end if;

 if length(p_excp_list) < length(p_all_excp_list) then
     g_need_insert_temp := true;
 end if;

 if p_folder_id is not null then
     OPEN filter_c;
     LOOP
        FETCH filter_c INTO item_rec;
        EXIT WHEN filter_c%NOTFOUND;
        if item_rec.field_name not in
           ('ITEM_NAME','ITEM_NAME2','PLANNER_CODE') then
           g_long_query := true;
        end if;
        if item_rec.field_name in ('ITEM_NAME','ITEM_NAME2') then
           item_rec.field_name := 'med.char1';
        elsif item_rec.field_name = 'PLANNER_CODE' then
           item_rec.field_name := 'med.char2';
        elsif item_rec.field_name = 'DEPARTMENT_CODE' then
           item_rec.field_name := 'medv.DEPARTMENT_LINE_CODE';
        else
           item_rec.field_name := 'medv.'||item_rec.field_name;
        end if;

        if item_rec.condition = 1 then
           if item_rec.data_set is not null and
              item_rec.hidden_from_field is not null and
              item_rec.field_name not in ('med.char1','med.char2') then
              one_rec := 'medv.'||item_rec.data_set ||' = '||
                      item_rec.hidden_from_field;
           else
              one_rec := item_rec.field_name ||' = '||''''||
                      item_rec.from_field||'''';
           end if;
        elsif item_rec.condition in (2,3,4,5,6) then
           p_operator := convert_condition(item_rec.condition);
           one_rec := item_rec.field_name || p_operator ||''''||
                      item_rec.from_field||'''';
        elsif item_rec.condition in (9,10) then
           p_operator := convert_condition(item_rec.condition);
           one_rec := item_rec.field_name || p_operator;
        elsif item_rec.condition in (7,8) then
           p_operator := convert_condition(item_rec.condition);
           one_rec := item_rec.field_name || p_operator ||''''||
                      item_rec.from_field || ''''||' AND '||''''||
                      item_rec.to_field||'''';
        end if;
        if item_rec.folder_object = 'MSC_NET_ITEM' then
           item_where_clause := item_where_clause || ' AND '||
                                one_rec;
        else
           res_where_clause := res_where_clause || ' AND '||
                             one_rec;
        end if;
     END LOOP;
     CLOSE filter_c;

  end if;

     if p_options_flag = 1 then

        select substr(meaning,1,10)
          into g_yes
          from mfg_lookups
         where lookup_type = 'SYS_YES_NO'
           and lookup_code = 1;

        select substr(meaning,1,10)
          into g_no
          from mfg_lookups
         where lookup_type = 'SYS_YES_NO'
           and lookup_code = 2;

        select substr(meaning,1,35)
          bulk collect into g_misc
          from mfg_lookups
         where lookup_type = 'MSC_NC_MISC_PROMPTS'
          order by lookup_code;

        select msc_form_query_s.nextval
          into g_options_query_id
          from dual;

       option_query_id :=g_options_query_id;
       compare_options;
       compare_aggregate;
       compare_optimize;
       compare_goalprog;
       compare_constraints;
       compare_orgs;
       compare_schedules;
     end if;

     if p_excp_list is not null then

        compare_exceptions(
                                                p_excp_list,
                                                item_where_clause,
                                                res_where_clause);
        exception_query_id :=g_excp_query_id;
     end if;

END compare_plans;

Function convert_condition(operator number) RETURN varchar2 IS
  translated_op  varchar2(30);
BEGIN
  IF operator = 1 THEN
    translated_op := ' = ';
  ELSIF operator = 2 THEN
    translated_op := ' <> ';
  ELSIF operator = 3 THEN
    translated_op := ' < ';
  ELSIF operator = 4 THEN
    translated_op := ' <= ';
  ELSIF operator = 5 THEN
    translated_op := ' >= ';
  ELSIF operator = 6 THEN
    translated_op := ' > ';
  ELSIF operator = 7 THEN
    translated_op := ' BETWEEN ';
  ELSIF operator = 8 THEN
    translated_op := ' NOT BETWEEN ';
  ELSIF operator = 9 THEN
    translated_op := ' IS NULL ';
  ELSIF operator = 10 THEN
    translated_op := ' IS NOT NULL ';
  END IF;
  return translated_op;

END convert_condition;

function calculate_start_date (p_org_id               IN NUMBER,
                               p_sr_instance_id       IN    NUMBER,
                               p_plan_start_date      IN    DATE,
                               p_daily_cutoff_bucket  IN    NUMBER,
                               p_weekly_cutoff_bucket IN    NUMBER,
                               p_period_cutoff_bucket IN    NUMBER)
                          return varchar2 is
l_daily_start_date   DATE;
l_weekly_start_date  DATE;
l_period_start_date  DATE;
l_curr_cutoff_date   DATE;

l_retval varchar2(150);
begin
   msc_snapshot_pk.calculate_start_date(p_org_id,
                               p_sr_instance_id,
                               p_plan_start_date,
                               p_daily_cutoff_bucket,
                               p_weekly_cutoff_bucket,
                               p_period_cutoff_bucket,
                               l_daily_start_date,
                               l_weekly_start_date,
                               l_period_start_date,
                               l_curr_cutoff_date);
   l_retval := fnd_date.date_to_chardate(l_daily_start_date)  ||' Days, '||
               fnd_date.date_to_chardate(l_weekly_start_date) ||' Weeks, '||
               fnd_date.date_to_chardate(l_period_start_date) ||' Periods ';
   return l_retval;
exception
   when others then
     return null;
end ;


Procedure compare_options IS
      p_plan_id number;

    cursor option_c is
    select ml.meaning, --0 plan_type
           decode(mp.CURR_PART_INCLUDE_TYPE,  --1 Planned items
                   1, g_misc(5), -- 'All planned items',
                   2, g_misc(6), -- 'Demand scheduled items only',
                   3, g_misc(7), -- 'Supply scheduled items only',
                   4, g_misc(8)), -- 'Demand and Supply scheduled items'),
           MAS.ASSIGNMENT_SET_NAME,  --2
           decode(mp.CURR_OPERATION_SCHEDULE_TYPE, --3 Material Scheduling Method
                       1, g_misc(9), --'Operation Start Date',
                       2, g_misc(10)), -- 'Order Start Date'),
           msc_get_name.dmd_priority_rule(mp.CURR_DEM_PRIORITY_RULE_ID), --4
           mp.SUBSTITUTION_DESIGNATOR, --5
           decode(mp.CURR_OVERWRITE_OPTION,  --6
                   1, g_misc(13), --'All',
                   2, g_misc(14), -- 'Outside planning time fence',
                   3, g_misc(4)), -- 'None'),
           msc_get_name.demand_class(mp.sr_instance_id,
                                     mp.organization_id,
                                     mp.compile_designator),--7
           nvl(decode(mp.CURR_DEMAND_TIME_FENCE_FLAG,1,g_yes,g_no),g_no),  --8
           nvl(decode(mp.CURR_APPEND_PLANNED_ORDERS,1,g_yes,g_no),g_no), --9
           nvl(decode(mp.CURR_PLANNING_TIME_FENCE_FLAG,1,g_yes,g_no),g_no), --10
           nvl(decode(mp.plan_inventory_point,1,g_yes,g_no),g_no), --11
           nvl(decode(mp.lot_for_lot,1,g_yes,g_no),g_no), --12
           null, -- 13 Default Forecast Consumption Days '
           mp.curr_backward_days, --14
           mp.curr_forward_days, --15
           nvl(decode(mp.CURR_FULL_PEGGING,1,g_yes,g_no),g_no), --16 enable pegging
           nvl(decode(mp.curr_closest_qty_peg,1,g_yes,g_no),g_no), --17 peg to closest qty
           decode(mp.CURR_RESERVATION_LEVEL,  --18 reservation level
                   1, g_misc(1), -- 'Planning Group',
                   2, g_misc(2), --'Project',
                   3, g_misc(3), -- 'Project-Task',
                   4, g_misc(4)),  --'None'),
           nvl(decode(mp.curr_priority_pegging,1,g_yes,g_no),g_no), --19
           decode(mp.CURR_HARD_PEGGING_LEVEL, --3
                   1,g_misc(2), -- 'Project',
                   2, g_misc(3), --'Project-Task',
                   3, g_misc(4))  --'None')
    from msc_plans mp,
         mfg_lookups ml,
         msc_assignment_sets mas
    where mp.plan_id = p_plan_id
      and ml.lookup_type = 'MRP_PLAN_TYPE'
      and ml.lookup_code = mp.curr_plan_type
      and mas.assignment_set_id (+) = mp.CURR_ASSIGNMENT_SET_ID;

  TYPE CharTab  IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
   plan_a_rec CharTab;
   plan_b_rec CharTab;
   a number;
Begin

    p_plan_id := g_from_plan;
    OPEN option_c;
    FETCH option_c INTO plan_a_rec(0),
                        plan_a_rec(1),
                        plan_a_rec(2),
                        plan_a_rec(3),
                        plan_a_rec(4),
                        plan_a_rec(5),
                        plan_a_rec(6),
                        plan_a_rec(7),
                        plan_a_rec(8),
                        plan_a_rec(9),
                        plan_a_rec(10),
                        plan_a_rec(11),
                        plan_a_rec(12),
                        plan_a_rec(13),
                        plan_a_rec(14),
                        plan_a_rec(15),
                        plan_a_rec(16),
                        plan_a_rec(17),
                        plan_a_rec(18),
                        plan_a_rec(19),
                        plan_a_rec(20);
    CLOSE option_c;

    p_plan_id := g_to_plan;
    OPEN option_c;
    FETCH option_c INTO plan_b_rec(0),
                        plan_b_rec(1),
                        plan_b_rec(2),
                        plan_b_rec(3),
                        plan_b_rec(4),
                        plan_b_rec(5),
                        plan_b_rec(6),
                        plan_b_rec(7),
                        plan_b_rec(8),
                        plan_b_rec(9),
                        plan_b_rec(10),
                        plan_b_rec(11),
                        plan_b_rec(12),
                        plan_b_rec(13),
                        plan_b_rec(14),
                        plan_b_rec(15),
                        plan_b_rec(16),
                        plan_b_rec(17),
                        plan_b_rec(18),
                        plan_b_rec(19),
                        plan_b_rec(20);
    CLOSE option_c;

    for a in 0 .. plan_a_rec.count-1 loop
/*
       if  plan_a_rec(a) <> plan_b_rec(a) or
          (plan_a_rec(a) is null and plan_b_rec(a) is not null) or
          (plan_a_rec(a) is not null and plan_b_rec(a) is null) then
*/
               insert into msc_form_query
                        (QUERY_ID,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
                        NUMBER1,
                        NUMBER2,
                        char1,
                        char2)
               select
                        g_options_query_id,
                        sysdate,
                        -1,
                        sysdate,
                        -1,
                        -1,
                        1, -- options
                        a,
                        plan_a_rec(a),
                        plan_b_rec(a)
               from dual;
--        end if;
     end loop;

End compare_options;

Procedure compare_aggregate IS

    p_plan_id number;

    cursor option_c is
      select
           mp.CURR_START_DATE,  -- start aggregate
           mp.CURR_CUTOFF_DATE,
           calculate_start_date(mp.organization_id,
                                mp.sr_instance_id,
                                mp.CURR_START_DATE,
                                mp.DAILY_CUTOFF_BUCKET,
                                mp.WEEKLY_CUTOFF_BUCKET,
                                mp.PERIOD_CUTOFF_BUCKET),
           mp.DAILY_CUTOFF_BUCKET ||' '||g_misc(15)||', '||--' days, '||
           mp.WEEKLY_CUTOFF_BUCKET ||' '||g_misc(16)||', '||--' weeks, '||
           mp.PERIOD_CUTOFF_BUCKET ||' '||g_misc(17),--' periods ',
           decode(mp.DAILY_ITEM_AGGREGATION_LEVEL,
                      1, g_misc(18), --'Items',
                      2, g_misc(19))||', '|| --'Product Family') || ','||
           decode(mp.WEEKLY_ITEM_AGGREGATION_LEVEL,
                      1, g_misc(18), --'Items',
                      2, g_misc(19))||', '|| --'Product Family') ||','||
           decode(mp.PERIOD_ITEM_AGGREGATION_LEVEL,
                      1, g_misc(18), --'Items',
                      2, g_misc(19)), --'Product Family'),
           decode(mp.DAILY_RES_AGGREGATION_LEVEL,
                      1, g_misc(20), --'Individual',
                      2, g_misc(21))||', '|| --'Aggregate')||','||
           decode(mp.WEEKLY_RES_AGGREGATION_LEVEL,
                      1, g_misc(20), --'Individual',
                      2, g_misc(21))||', '|| --'Aggregate') ||','||
           decode(mp.PERIOD_RES_AGGREGATION_LEVEL,
                      1, g_misc(20), --'Individual',
                      2, g_misc(21)), --'Aggregate'),
           decode(mp.DAILY_RTG_AGGREGATION_LEVEL,
                      1,g_misc(22), --'Routings',
                      2, g_misc(22))||', '|| --'BOR') ||','||
           decode(mp.WEEKLY_RTG_AGGREGATION_LEVEL,
                      1,g_misc(22), --'Routings',
                      2,g_misc(22))||', '|| -- 'BOR') ||','||
           decode(mp.PERIOD_RTG_AGGREGATION_LEVEL,
                      1,g_misc(22), --'Routings',
                      2,g_misc(22)) -- 'BOR')
    from msc_plans mp
    where mp.plan_id = p_plan_id;

   TYPE CharTab  IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
   plan_a_rec CharTab;
   plan_b_rec CharTab;
   a number;

Begin

    p_plan_id := g_from_plan;
    OPEN option_c;
    FETCH option_c INTO plan_a_rec(1),
                        plan_a_rec(2),
                        plan_a_rec(3),
                        plan_a_rec(4),
                        plan_a_rec(5),
                        plan_a_rec(6),
                        plan_a_rec(7);
    CLOSE option_c;

    p_plan_id := g_to_plan;
    OPEN option_c;
    FETCH option_c INTO plan_b_rec(1),
                        plan_b_rec(2),
                        plan_b_rec(3),
                        plan_b_rec(4),
                        plan_b_rec(5),
                        plan_b_rec(6),
                        plan_b_rec(7);
    CLOSE option_c;

    for a in 1 .. plan_a_rec.count loop
               insert into msc_form_query
                        (QUERY_ID,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
                        NUMBER1,
                        NUMBER2,
                        char1,
                        char2)
               select
                        g_options_query_id,
                        sysdate,
                        -1,
                        sysdate,
                        -1,
                        -1,
                        2, -- aggregate
                        a,
                        plan_a_rec(a),
                        plan_b_rec(a)
               from dual;
     end loop;

End compare_aggregate;

Procedure compare_optimize IS
    p_plan_id number;

    cursor option_c is
      select
           decode(mp.OPTIMIZE_FLAG,1, g_yes, g_no), -- start optimize
           decode(mp.CURR_ENFORCE_SRC_CONSTRAINTS,1, g_yes, g_no),
           null, -- dummy field for objective
           mp.OBJECTIVE_WEIGHT_1,
           mp.OBJECTIVE_WEIGHT_2,
           mp.OBJECTIVE_WEIGHT_4,
           null, -- dummy field for plan level defaults
           mp.SUPPLIER_CAP_OVER_UTIL_COST,
           mp.TRANSPORT_CAP_OVER_UTIL_COST,
           mp.RESOURCE_OVER_UTIL_COST,
           mp.DMD_LATENESS_PENALTY_COST -- end optimize
    from msc_plans mp
    where mp.plan_id = p_plan_id;


  TYPE CharTab  IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
   plan_a_rec CharTab;
   plan_b_rec CharTab;
   a number;
Begin
    p_plan_id := g_from_plan;
    OPEN option_c;
    FETCH option_c INTO plan_a_rec(1),
                        plan_a_rec(2),
                        plan_a_rec(3),
                        plan_a_rec(4),
                        plan_a_rec(5),
                        plan_a_rec(6),
                        plan_a_rec(7),
                        plan_a_rec(8),
                        plan_a_rec(9),
                        plan_a_rec(10),
                        plan_a_rec(11);
    CLOSE option_c;

    p_plan_id := g_to_plan;
    OPEN option_c;
    FETCH option_c INTO plan_b_rec(1),
                        plan_b_rec(2),
                        plan_b_rec(3),
                        plan_b_rec(4),
                        plan_b_rec(5),
                        plan_b_rec(6),
                        plan_b_rec(7),
                        plan_b_rec(8),
                        plan_b_rec(9),
                        plan_b_rec(10),
                        plan_b_rec(11);
    CLOSE option_c;

    for a in 1 .. plan_a_rec.count loop

               insert into msc_form_query
                        (QUERY_ID,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
                        NUMBER1,
                        NUMBER2,
                        char1,
                        char2)
               select
                        g_options_query_id,
                        sysdate,
                        -1,
                        sysdate,
                        -1,
                        -1,
                        3, -- optimize
                        a,
                        plan_a_rec(a),
                        plan_b_rec(a)
               from dual;

     end loop;

End compare_optimize;

Procedure compare_constraints IS
  p_plan_id number;

    cursor option_c is
      select
           mp.CURR_START_DATE,  -- start aggregate
           mp.CURR_CUTOFF_DATE,
           decode(nvl(mp.DAILY_RESOURCE_CONSTRAINTS, 2)||
           nvl(mp.WEEKLY_RESOURCE_CONSTRAINTS,2)||
           nvl(mp.PERIOD_RESOURCE_CONSTRAINTS,2)||
           nvl(mp.DAILY_MATERIAL_CONSTRAINTS, 2)||
           nvl(mp.WEEKLY_MATERIAL_CONSTRAINTS,2)||
           nvl(mp.PERIOD_MATERIAL_CONSTRAINTS,2),'222222',g_no,g_yes),
           nvl(decode(mp.CURR_ENFORCE_DEM_DUE_DATES,1,g_yes,g_no),g_no),
           nvl(decode(mp.CURR_ENFORCE_CAP_CONSTRAINTS,1,g_yes,g_no),g_no),
           calculate_start_date(mp.organization_id,
                                mp.sr_instance_id,
                                mp.CURR_START_DATE,
                                mp.DAILY_CUTOFF_BUCKET,
                                mp.WEEKLY_CUTOFF_BUCKET,
                                mp.PERIOD_CUTOFF_BUCKET),
           mp.DAILY_CUTOFF_BUCKET ||' '||g_misc(15)||', '||--' days, '||
           mp.WEEKLY_CUTOFF_BUCKET ||' '||g_misc(16)||', '||--' weeks, '||
           mp.PERIOD_CUTOFF_BUCKET ||' '||g_misc(17),--' periods ',
          nvl(
           decode(mp.DAILY_RESOURCE_CONSTRAINTS, 1, g_misc(15)) ||
           decode(mp.WEEKLY_RESOURCE_CONSTRAINTS, 1, ', '||g_misc(16))||
           decode(mp.PERIOD_RESOURCE_CONSTRAINTS, 1, ', '||g_misc(17)),g_misc(4)),
          nvl(
           decode(mp.DAILY_MATERIAL_CONSTRAINTS, 1, g_misc(15)) ||
           decode(mp.WEEKLY_MATERIAL_CONSTRAINTS, 1, ', '||g_misc(16))||
           decode(mp.PERIOD_MATERIAL_CONSTRAINTS, 1, ', '||g_misc(17)),g_misc(4)),
           --decode(mp.SCHEDULE_FLAG,1, g_yes, g_no),
           null, --scheduling prompt
           mp.MIN_CUTOFF_BUCKET,
           mp.HOUR_CUTOFF_BUCKET,
           null, --days cutoff bucket
           decode(mp.CURR_PLAN_CAPACITY_FLAG,1, g_yes, g_no),
           decode(mp.CURR_PLANNED_RESOURCES,
                       1, g_misc(11), -- 'All Resources',
                       2, g_misc(12)), --'Bottleneck Resources'),
           mp.CURR_BOTTLENECK_RES_GROUP
    from msc_plans mp
    where mp.plan_id = p_plan_id;
  TYPE CharTab  IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
   plan_a_rec CharTab;
   plan_b_rec CharTab;
   a number;
Begin
    p_plan_id := g_from_plan;
    OPEN option_c;
    FETCH option_c INTO plan_a_rec(1),
                        plan_a_rec(2),
                        plan_a_rec(3),
                        plan_a_rec(4),
                        plan_a_rec(5),
                        plan_a_rec(6),
                        plan_a_rec(7),
                        plan_a_rec(8),
                        plan_a_rec(9),
                        plan_a_rec(10),
                        plan_a_rec(11),
                        plan_a_rec(12),
                        plan_a_rec(13),
                        plan_a_rec(14),
                        plan_a_rec(15),
                        plan_a_rec(16);

    CLOSE option_c;

    p_plan_id := g_to_plan;
    OPEN option_c;
    FETCH option_c INTO plan_b_rec(1),
                        plan_b_rec(2),
                        plan_b_rec(3),
                        plan_b_rec(4),
                        plan_b_rec(5),
                        plan_b_rec(6),
                        plan_b_rec(7),
                        plan_b_rec(8),
                        plan_b_rec(9),
                        plan_b_rec(10),
                        plan_b_rec(11),
                        plan_b_rec(12),
                        plan_b_rec(13),
                        plan_b_rec(14),
                        plan_b_rec(15),
                        plan_b_rec(16);
    CLOSE option_c;

    for a in 1 .. plan_a_rec.count loop


               insert into msc_form_query
                        (QUERY_ID,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
                        NUMBER1,
                        NUMBER2,
                        char1,
                        char2)
               select
                        g_options_query_id,
                        sysdate,
                        -1,
                        sysdate,
                        -1,
                        -1,
                        7, -- constraints
                        a,
                        plan_a_rec(a),
                        plan_b_rec(a)
               from dual;

     end loop;

end compare_constraints;

Procedure compare_goalprog IS
  p_plan_id number;

    cursor option_c is
        select nvl(decode(mp.USE_END_ITEM_SUBSTITUTIONS,1,g_yes,g_no),g_no),
        nvl(decode(mp.USE_ALTERNATE_RESOURCES,1,g_yes,g_no),g_no),
        nvl(decode(mp.USE_SUBSTITUTE_COMPONENTS,1,g_yes,g_no),g_no),
        nvl(decode(mp.USE_ALTERNATE_BOM_ROUTING,1,g_yes,g_no),g_no),
        nvl(decode(mp.USE_ALTERNATE_SOURCES,1,g_yes,g_no),g_no)
    from msc_plans mp
    where mp.plan_id = p_plan_id;

  TYPE CharTab  IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
   plan_a_rec CharTab;
   plan_b_rec CharTab;
   a number;
Begin
    p_plan_id := g_from_plan;
    OPEN option_c;
    FETCH option_c INTO plan_a_rec(1),
                        plan_a_rec(2),
                        plan_a_rec(3),
                        plan_a_rec(4),
                        plan_a_rec(5);
    CLOSE option_c;

    p_plan_id := g_to_plan;
    OPEN option_c;
    FETCH option_c INTO plan_b_rec(1),
                        plan_b_rec(2),
                        plan_b_rec(3),
                        plan_b_rec(4),
                        plan_b_rec(5);
    CLOSE option_c;

    for a in 1 .. plan_a_rec.count loop

               insert into msc_form_query
                        (QUERY_ID,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
                        NUMBER1,
                        NUMBER2,
                        char1,
                        char2)
               select
                        g_options_query_id,
                        sysdate,
                        -1,
                        sysdate,
                        -1,
                        -1,
                        8, -- optimize
                        a,
                        plan_a_rec(a),
                        plan_b_rec(a)
               from dual;
     end loop;

end compare_goalprog;

Procedure compare_orgs IS

Begin
               insert into msc_form_query
                        (QUERY_ID,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
                        char1,
                        char2,
                        char3,
                        number1,
                        char6,
                        char7,
                        char8,
                        char9,
                        char4,
                        char5,
                        char10)
               select
g_options_query_id,
sysdate,
-1,
sysdate,
-1,
-1,
mp.compile_designator,
    PT.ORGANIZATION_CODE
, PT.PARTNER_NAME
, 4
, nvl(decode(MPO.NET_WIP,1,g_yes,g_no),g_no)
, nvl(decode(MPO.NET_RESERVATIONS,1,g_yes,g_no),g_no)
, nvl(decode(MPO.NET_PURCHASING,1,g_yes,g_no),g_no)
, nvl(decode(MPO.PLAN_SAFETY_STOCK,1,g_yes,g_no),g_no)
, MPO.SIMULATION_SET
, MPO.BILL_OF_RESOURCES
, nvl(decode(MPO.INCLUDE_SALESORDER,1,g_yes,g_no),g_no)
FROM
    MSC_TRADING_PARTNERS PT,
    MSC_PLAN_ORGANIZATIONS MPO,
    msc_plans mp
where  MPO.SR_INSTANCE_ID = PT.SR_INSTANCE_ID
 AND  MPO.ORGANIZATION_ID = PT.SR_TP_ID
 AND  PT.partner_type =3
 and mp.plan_id = mpo.plan_id
 and mpo.plan_id = g_from_plan
and not exists ( select 1
  from MSC_PLAN_ORGANIZATIONS MPO2
  where MPO2.plan_id = g_to_plan
    and MPO2.organization_id = MPO.organization_id
    and MPO2.sr_instance_id = MPO.sr_instance_id
    and nvl(MPO2.NET_WIP,0) = nvl(MPO.NET_WIP,0)
    and nvl(MPO2.NET_RESERVATIONS,0) = nvl(MPO.NET_RESERVATIONS,0)
    and nvl(MPO2.NET_PURCHASING,0) = nvl(MPO.NET_PURCHASING,0)
    and nvl(MPO2.PLAN_SAFETY_STOCK,0) = nvl(MPO.PLAN_SAFETY_STOCK,0)
    and nvl(MPO2.SIMULATION_SET,'0') = nvl(MPO.SIMULATION_SET,'0')
    and nvl(MPO2.BILL_OF_RESOURCES,'0') = nvl(MPO.BILL_OF_RESOURCES,'0')
    and nvl(MPO2.INCLUDE_SALESORDER,0) = nvl(MPO.INCLUDE_SALESORDER,0))
;

               insert into msc_form_query
                        (QUERY_ID,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
                        char1,
                        char2,
                        char3,
                        number1,
                        char6,
                        char7,
                        char8,
                        char9,
                        char4,
                        char5,
                        char10)
               select
g_options_query_id,
sysdate,
-1,
sysdate,
-1,
-1,
mp.compile_designator,
    PT.ORGANIZATION_CODE
, PT.PARTNER_NAME
, 4 -- org
, nvl(decode(MPO.NET_WIP,1,g_yes,g_no),g_no)
, nvl(decode(MPO.NET_RESERVATIONS,1,g_yes,g_no),g_no)
, nvl(decode(MPO.NET_PURCHASING,1,g_yes,g_no),g_no)
, nvl(decode(MPO.PLAN_SAFETY_STOCK,1,g_yes,g_no),g_no)
, MPO.SIMULATION_SET
, MPO.BILL_OF_RESOURCES
, nvl(decode(MPO.INCLUDE_SALESORDER,1,g_yes,g_no),g_no)
FROM
    MSC_TRADING_PARTNERS PT,
    MSC_PLAN_ORGANIZATIONS MPO,
    msc_plans mp
where  MPO.SR_INSTANCE_ID = PT.SR_INSTANCE_ID
 AND  MPO.ORGANIZATION_ID = PT.SR_TP_ID
 AND  PT.partner_type =3
 and mpo.plan_id = g_to_plan
 and mp.plan_id = mpo.plan_id
and not exists ( select 1
  from MSC_PLAN_ORGANIZATIONS MPO2
  where MPO2.plan_id = g_from_plan
    and MPO2.organization_id = MPO.organization_id
    and MPO2.sr_instance_id = MPO.sr_instance_id
    and nvl(MPO2.NET_WIP,0) = nvl(MPO.NET_WIP,0)
    and nvl(MPO2.NET_RESERVATIONS,0) = nvl(MPO.NET_RESERVATIONS,0)
    and nvl(MPO2.NET_PURCHASING,0) = nvl(MPO.NET_PURCHASING,0)
    and nvl(MPO2.PLAN_SAFETY_STOCK,0) = nvl(MPO.PLAN_SAFETY_STOCK,0)
    and nvl(MPO2.SIMULATION_SET,'0') = nvl(MPO.SIMULATION_SET,'0')
    and nvl(MPO2.BILL_OF_RESOURCES,'0') = nvl(MPO.BILL_OF_RESOURCES,'0')
    and nvl(MPO2.INCLUDE_SALESORDER,0) = nvl(MPO.INCLUDE_SALESORDER,0))
;

               insert into msc_form_query
                        (QUERY_ID,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
                        char1,
                        char2,
                        char3,
                        number1,
                        char6,
                        char7,
                        char8,
                        char9,
                        char4,
                        char5,
                        char10)
               select
g_options_query_id,
sysdate,
-1,
sysdate,
-1,
-1,
mp.compile_designator||'&'||mp2.compile_designator,
    PT.ORGANIZATION_CODE
, PT.PARTNER_NAME
, 4 -- org
, nvl(decode(MPO.NET_WIP,1,g_yes,g_no),g_no)
, nvl(decode(MPO.NET_RESERVATIONS,1,g_yes,g_no),g_no)
, nvl(decode(MPO.NET_PURCHASING,1,g_yes,g_no),g_no)
, nvl(decode(MPO.PLAN_SAFETY_STOCK,1,g_yes,g_no),g_no)
, MPO.SIMULATION_SET
, MPO.BILL_OF_RESOURCES
, nvl(decode(MPO.INCLUDE_SALESORDER,1,g_yes,g_no),g_no)
FROM
    MSC_TRADING_PARTNERS PT,
    MSC_PLAN_ORGANIZATIONS MPO,
    MSC_PLAN_ORGANIZATIONS MPO2,
    msc_plans mp,
    msc_plans mp2
where  MPO.SR_INSTANCE_ID = PT.SR_INSTANCE_ID
 AND  MPO.ORGANIZATION_ID = PT.SR_TP_ID
 AND  PT.partner_type =3
 and mpo.plan_id = g_to_plan
 and mp.plan_id = mpo.plan_id
 and mp2.plan_id = mpo2.plan_id
 and MPO2.plan_id = g_from_plan
    and MPO2.organization_id = MPO.organization_id
    and MPO2.sr_instance_id = MPO.sr_instance_id
    and nvl(MPO2.NET_WIP,0) = nvl(MPO.NET_WIP,0)
    and nvl(MPO2.NET_RESERVATIONS,0) = nvl(MPO.NET_RESERVATIONS,0)
    and nvl(MPO2.NET_PURCHASING,0) = nvl(MPO.NET_PURCHASING,0)
    and nvl(MPO2.PLAN_SAFETY_STOCK,0) = nvl(MPO.PLAN_SAFETY_STOCK,0)
    and nvl(MPO2.SIMULATION_SET,'0') = nvl(MPO.SIMULATION_SET,'0')
    and nvl(MPO2.BILL_OF_RESOURCES,'0') = nvl(MPO.BILL_OF_RESOURCES,'0')
    and nvl(MPO2.INCLUDE_SALESORDER,0) = nvl(MPO.INCLUDE_SALESORDER,0)
;


End compare_orgs;

Procedure compare_schedules IS

Begin

               insert into msc_form_query
                        (QUERY_ID,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
                        char1,
                        char2,
                        char3,
                        number1,
                        number2,
                        char5,
                        number4,
                        number5,
                        number6,
                        char4)
               select
g_options_query_id,
sysdate,
-1,
sysdate,
-1,
-1,
    PT.ORGANIZATION_CODE
, DESIG.DESIGNATOR
, DESIG.DESCRIPTION
, 5 -- schedule
, MPS.DESIGNATOR_TYPE
, nvl(decode(MPS.INTERPLANT_DEMAND_FLAG,1,g_yes,g_no),g_no)
, MPS.SCENARIO_SET
, MPS.PROBABILITY
, MPS.input_type
, mp.compile_designator
FROM
    MSC_TRADING_PARTNERS PT,
   MSC_DESIGNATORS DESIG,
   MSC_PLAN_SCHEDULES MPS,
   msc_plans mp
  WHERE MPS.INPUT_SCHEDULE_ID = DESIG.DESIGNATOR_ID
  and mp.plan_id = mps.plan_id
 AND MPS.DESIGNATOR_TYPE <> 7
 and  MPS.SR_INSTANCE_ID = PT.SR_INSTANCE_ID
 AND  MPS.ORGANIZATION_ID = PT.SR_TP_ID
 AND  PT.partner_type =3
 and mps.plan_id = g_from_plan
and not exists ( select 1
  from MSC_PLAN_SCHEDULES MPS2
  where MPS2.plan_id = g_to_plan
    and MPS2.organization_id = MPS.organization_id
    and MPS2.sr_instance_id = MPS.sr_instance_id
    and mps2.input_type = mps.input_type
    and mps2.INPUT_SCHEDULE_ID = mps.INPUT_SCHEDULE_ID
    and nvl(mps2.INTERPLANT_DEMAND_FLAG,2) =
         nvl(mps.INTERPLANT_DEMAND_FLAG,2)
    and nvl(MPS2.SCENARIO_SET,0) =nvl(MPS.SCENARIO_SET,0)
    and nvl(MPS2.PROBABILITY,0) = nvl(MPS.PROBABILITY,0)
    )
;

               insert into msc_form_query
                        (QUERY_ID,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
                        char1,
                        char2,
                        char3,
                        number1,
                        number2,
                        char5,
                        number4,
                        number5,
                        number6,
                        char4)
               select
g_options_query_id,
sysdate,
-1,
sysdate,
-1,
-1,
    PT.ORGANIZATION_CODE
, DESIG.DESIGNATOR
, DESIG.DESCRIPTION
, 5 -- schedule
, MPS.DESIGNATOR_TYPE
, nvl(decode(MPS.INTERPLANT_DEMAND_FLAG,1,g_yes,g_no),g_no)
, MPS.SCENARIO_SET
, MPS.PROBABILITY
, MPS.input_type
, mp.compile_designator
FROM
    MSC_TRADING_PARTNERS PT,
   MSC_DESIGNATORS DESIG,
   MSC_PLAN_SCHEDULES MPS,
   msc_plans mp
  WHERE MPS.INPUT_SCHEDULE_ID = DESIG.DESIGNATOR_ID
 and mp.plan_id = mps.plan_id
 AND MPS.DESIGNATOR_TYPE <> 7
 and  MPS.SR_INSTANCE_ID = PT.SR_INSTANCE_ID
 AND  MPS.ORGANIZATION_ID = PT.SR_TP_ID
 AND  PT.partner_type =3
 and mps.plan_id = g_to_plan
and not exists ( select 1
  from MSC_PLAN_SCHEDULES MPS2
  where MPS2.plan_id = g_from_plan
    and MPS2.organization_id = MPS.organization_id
    and MPS2.sr_instance_id = MPS.sr_instance_id
    and mps2.input_type = mps.input_type
    and mps2.INPUT_SCHEDULE_ID = mps.INPUT_SCHEDULE_ID
    and nvl(mps2.INTERPLANT_DEMAND_FLAG,2) =
         nvl(mps.INTERPLANT_DEMAND_FLAG,2)
    and nvl(MPS2.SCENARIO_SET,0) =nvl(MPS.SCENARIO_SET,0)
    and nvl(MPS2.PROBABILITY,0) = nvl(MPS.PROBABILITY,0)
    )
;

               insert into msc_form_query
                        (QUERY_ID,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
                        char1,
                        char2,
                        char3,
                        number1,
                        number2,
                        char5,
                        number4,
                        number5,
                        number6,
                        char4)
               select
g_options_query_id,
sysdate,
-1,
sysdate,
-1,
-1,
    PT.ORGANIZATION_CODE
, DESIG.DESIGNATOR
, DESIG.DESCRIPTION
, 5 -- schedule
, MPS.DESIGNATOR_TYPE
, nvl(decode(MPS.INTERPLANT_DEMAND_FLAG,1,g_yes,g_no),g_no)
, MPS.SCENARIO_SET
, MPS.PROBABILITY
, MPS.input_type
, mp.compile_designator||'&'||mp2.compile_designator
FROM
    MSC_TRADING_PARTNERS PT,
   MSC_DESIGNATORS DESIG,
   MSC_PLAN_SCHEDULES MPS,
   MSC_PLAN_SCHEDULES MPS2,
   msc_plans mp,
   msc_plans mp2
  WHERE MPS.INPUT_SCHEDULE_ID = DESIG.DESIGNATOR_ID
 and mp.plan_id = mps.plan_id
 AND MPS.DESIGNATOR_TYPE <> 7
 and  MPS.SR_INSTANCE_ID = PT.SR_INSTANCE_ID
 AND  MPS.ORGANIZATION_ID = PT.SR_TP_ID
 AND  PT.partner_type =3
 and mps.plan_id = g_to_plan
 and mp2.plan_id = mps2.plan_id
 and MPS2.plan_id = g_from_plan
    and MPS2.organization_id = MPS.organization_id
    and MPS2.sr_instance_id = MPS.sr_instance_id
    and mps2.input_type = mps.input_type
    and mps2.INPUT_SCHEDULE_ID = mps.INPUT_SCHEDULE_ID
    and nvl(mps2.INTERPLANT_DEMAND_FLAG,2) =
         nvl(mps.INTERPLANT_DEMAND_FLAG,2)
    and nvl(MPS2.SCENARIO_SET,0) =nvl(MPS.SCENARIO_SET,0)
    and nvl(MPS2.PROBABILITY,0) = nvl(MPS.PROBABILITY,0)
;

End compare_schedules;

Procedure compare_exceptions(
                       exception_list varchar2,
                       item_where_clause varchar2,
                       resource_where_clause varchar2) IS

    p_exc_type number;
    sql_statement varchar2(2000);
   where_clause varchar2(32000);
   i number :=1;
   v_len number;
   one_len number;

   CURSOR cat_set_name(v_category_set_id number) IS
     SELECT category_set_name
     FROM msc_category_sets
     where category_set_id = v_category_set_id;


   cursor plan_type_c(v_plan_id number) is
   select curr_plan_type
   from msc_plans
   where plan_id = v_plan_id;

   p_plan_status number;
   p_report_id number;
   l_plan_type number;
   l_def_pref_id number;

Begin

  open plan_type_c(g_from_plan);
  fetch plan_type_c into l_plan_type;
  close plan_type_c;

  l_def_pref_id := msc_get_name.get_default_pref_id(fnd_global.user_id);
  g_cat_set:= msc_get_name.GET_preference('CATEGORY_SET_ID',l_def_pref_id, l_plan_type);

    OPEN cat_set_name(g_cat_set);
    FETCH cat_set_name INTO g_cat_set_name;
    CLOSE cat_set_name;

    checkPlanStatus(g_from_plan, g_to_plan,p_plan_status,p_report_id);

    if g_need_insert_temp then
       select msc_form_query_s.nextval
            into g_excp_query_id
            from dual;
    else
       g_excp_query_id := p_report_id;
    end if;

    -- parse the exception_list, the format is ',1,2,3,14,'
    v_len := length(exception_list);
    while v_len > 1 loop
      one_len := instr(exception_list,',',1,i+1)-
                               instr(exception_list,',',1,i)-1;
      p_exc_type := to_number(
                      substr(exception_list,
                             instr(exception_list,',',1,i)+1,one_len));

    if p_exc_type in (21,22,23,35,36,38,39,40,45,46,50,51) then
       where_clause := resource_where_clause;
    else
       if item_where_clause is not null then
          if g_long_query then
             where_clause := item_where_clause||' and medv.category_set_id='
              || g_cat_set;
          else
             where_clause := item_where_clause;
          end if;
       end if;
    end if;
    if g_need_insert_temp then
       filter_data(p_report_id, p_exc_type, where_clause);
    end if;

    i := i+1;
    v_len := v_len - one_len-1;

 END LOOP;

    if g_need_insert_temp then

         -- insert summary rows which are grouped by exc_type
            insert into msc_nec_exc_dtl_temp(
                              query_id,
                              status,
                              plan_id,
                              exception_type,
                              exception_group,
                              from_plan,
                              match_id, -- to store exception count
                              LAST_UPDATE_DATE,
                              LAST_UPDATED_BY,
                              CREATION_DATE,
                              CREATED_BY,
                              LAST_UPDATE_LOGIN)
                      select  query_id,
                              status,
                              plan_id,
                              exception_type,
                              exception_group,
                              from_plan,
                              count(*),
                              trunc(sysdate),
                              -1,
                              trunc(sysdate),
                              -1,
                              -1
                      from msc_nec_exc_dtl_temp
                      where query_id = g_excp_query_id
                       and exception_detail_id is not null
                       group by  query_id,
                              status,
                              plan_id,
                              exception_type,
                              exception_group,
                              from_plan,
                              trunc(sysdate),
                              -1,
                              trunc(sysdate),
                              -1,
                              -1 ;

         -- insert summary rows which are grouped by exc_group
            insert into msc_nec_exc_dtl_temp(
                              query_id,
                              status,
                              plan_id,
                              exception_group,
                              from_plan,
                              match_id, -- to store exception count
                              LAST_UPDATE_DATE,
                              LAST_UPDATED_BY,
                              CREATION_DATE,
                              CREATED_BY,
                              LAST_UPDATE_LOGIN)
                      select  query_id,
                              status,
                              plan_id,
                              exception_group,
                              from_plan,
                              sum(match_id),
                              trunc(sysdate),
                              -1,
                              trunc(sysdate),
                              -1,
                              -1
                      from msc_nec_exc_dtl_temp
                      where query_id = g_excp_query_id
                        and exception_detail_id is null
                       group by  query_id,
                              status,
                              plan_id,
                              exception_group,
                              from_plan,
                              trunc(sysdate),
                              -1,
                              trunc(sysdate),
                              -1,
                              -1 ;
    end if;

End compare_exceptions;

Procedure populate_all_exceptions(p_plan_id number,p_report_id number) IS
  p_mask varchar2(20) :='MM/DD/RR HH24:MI';
Begin

  -- over commit, rep var, no act, neg on hand
  -- item with exc/shortage, below safety, supplier cap.
  -- sourcing split violation
  insert into msc_nec_exc_dtl_compare(
          report_id,
          status,
          exception_detail_id,
          plan_id,
          exception_type,
          exception_group,
          from_plan,
          id_key,
          compare_key,
          char1,
          char2,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN)
  select  p_report_id,
          0,
          med.exception_detail_id,
          med.plan_id,
          med.exception_type,
          decode(med.exception_type,
                                 2, 3, 3, 3, 20, 3,
                                 28, 6,
                                 17, 8, 18, 8,1) ,
          decode(med.plan_id,g_from_plan,1,2),
          med.organization_id||':'||med.sr_instance_id||':'||
          med.inventory_item_id||':'||med.supplier_id||':'||
          med.supplier_site_id||':'||
          decode(med.exception_type,
              17, med.number1||':'||med.number2, -- project_id/task_id
              18, med.number1||':'||med.number2,
              48, med.number2), -- supplier or source org
          to_char(med.date1, p_mask)||':'||to_char(med.date2, p_mask)||':'||
          med.quantity ||':'||
          decode(med.exception_type,48,med.number1), -- actual %
          msi.item_name,
          msi.planner_code,
          trunc(sysdate),
          -1,
          trunc(sysdate),
          -1,
          -1
     from msc_exception_details med,
          msc_system_items msi
    where med.plan_id = p_plan_id
      and med.exception_type in (1,2,3,4,5,11,17,18,20,28,29,30,48)
      and msi.plan_id = med.plan_id
      and msi.organization_id = med.organization_id
      and msi.sr_instance_id = med.sr_instance_id
      and msi.inventory_item_id = med.inventory_item_id
;

   -- reschedule in/out, cancel, past due, compress, expired lot
   -- schedule to next inventory point
  insert into msc_nec_exc_dtl_compare(
          report_id,
          status,
          exception_detail_id,
          plan_id,
          exception_type,
          exception_group,
          from_plan,
          id_key,
          compare_key,
          char1,
          char2,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN)
  select  p_report_id,
          0,
          med.exception_detail_id,
          med.plan_id,
          med.exception_type,
          decode(med.exception_type, 12, 1, 4),
          decode(med.plan_id,g_from_plan,1,2),
          med.organization_id||':'||med.sr_instance_id||':'||
          med.inventory_item_id||':'||
          decode(ms.order_type,
             5,ms.new_schedule_date ||':'||ms.new_order_quantity ||':'||
               ms.supplier_id||':'||ms.supplier_site_id||':'||
               ms.source_organization_id ||':'||ms.source_sr_instance_id,
             ms.order_number||':'||ms.purch_line_num),
          decode(med.exception_type,
             9, to_char(ms.schedule_compress_days),
             12, ms.lot_number,
             47, to_char(med.number2), -- planned inventory point
             to_char(ms.reschedule_days)),
          msi.item_name,
          msi.planner_code,
          trunc(sysdate),
          -1,
          trunc(sysdate),
          -1,
          -1
     from msc_exception_details med,
          msc_system_items msi,
          msc_supplies ms
    where med.plan_id = p_plan_id
      and med.exception_type in (6,7,8,9,10,12,47)
      and ms.plan_id=med.plan_id
      and ms.transaction_id=med.number1
      and ms.sr_instance_id=med.sr_instance_id
      and msi.plan_id = med.plan_id
      and msi.organization_id = med.organization_id
      and msi.sr_instance_id = med.sr_instance_id
      and msi.inventory_item_id = med.inventory_item_id;

  -- alternate
  insert into msc_nec_exc_dtl_compare(
          report_id,
          status,
          exception_detail_id,
          plan_id,
          exception_type,
          exception_group,
          from_plan,
          id_key,
          compare_key,
          char1,
          char2,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN)
  select  p_report_id,
          0,
          med.exception_detail_id,
          med.plan_id,
          med.exception_type,
          2,
          decode(med.plan_id,g_from_plan,1,2),
          med.organization_id||':'||med.sr_instance_id||':'||
          med.inventory_item_id||':'||
          decode(ms.order_type,
             5,ms.new_schedule_date ||':'||ms.new_order_quantity ||':'||
               ms.supplier_id||':'||ms.supplier_site_id||':'||
               ms.source_organization_id ||':'||ms.source_sr_instance_id,
             ms.order_number||':'||ms.purch_line_num),
          decode(med.exception_type,
                 34, med.department_id ||':'||med.resource_id,
                 43, med.number2 ||':'|| med.number3 ,
                 44, med.supplier_id,
                 med.number2),
          msi.item_name,
          msi.planner_code,
          trunc(sysdate),
          -1,
          trunc(sysdate),
          -1,
          -1
     from msc_exception_details med,
          msc_system_items msi,
          msc_supplies ms
    where med.plan_id = p_plan_id
      and med.exception_type in (31,32,33,34,43,44)
      and ms.plan_id=med.plan_id
      and ms.transaction_id=med.number1
      and ms.sr_instance_id=med.sr_instance_id
      and msi.plan_id = ms.plan_id
      and msi.organization_id = ms.organization_id
      and msi.sr_instance_id = ms.sr_instance_id
      and msi.inventory_item_id = ms.inventory_item_id;

-- resource/material constraint
  insert into msc_nec_exc_dtl_compare(
          report_id,
          status,
          exception_detail_id,
          plan_id,
          exception_type,
          exception_group,
          from_plan,
          id_key,
          compare_key,
          char1,
          char2,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN)
  select  p_report_id,
          0,
          med.exception_detail_id,
          med.plan_id,
          med.exception_type,
          decode(med.exception_type,36, 6, 37, 6, 40,7, 61,7,
                 62, 4,63, 4, 64, 4, 65, 4, 66, 4, 71, 4, 11),
          decode(med.plan_id,g_from_plan,1,2),
          med.organization_id||':'||med.sr_instance_id||':'||
          med.inventory_item_id||':'||med.department_id ||':'||
          med.resource_id ||':'||
          decode(ms.order_type,
             5,ms.new_schedule_date ||':'||ms.new_order_quantity ||':'||
               ms.supplier_id||':'||ms.supplier_site_id||':'||
               ms.source_organization_id ||':'||ms.source_sr_instance_id||':'||
               ms.ship_method,
             ms.order_number||':'||ms.purch_line_num)||':'||
          decode(med.exception_type, 36, med.number2||';'||med.number3,
               53, med.number2||';'||med.number3,
               58, med.number2||';'||med.number3,
               60, med.number2||';'||med.number3,
               63, med.number3||';'||med.number4,
               65, med.number3||';'||med.number4),
          to_char(med.date1, p_mask)||':'||
             to_char(med.date2, p_mask)||':'||med.quantity,
          msi.item_name,
          msi.planner_code,
          trunc(sysdate),
          -1,
          trunc(sysdate),
          -1,
          -1
     from msc_exception_details med,
          msc_system_items msi,
          msc_supplies ms
    where med.plan_id = p_plan_id
      and med.exception_type in (36,37,40,53,54,55,56,57,58,59,60,61,62,63,64,65,66,71,72)
      and ms.plan_id=med.plan_id
      and ms.transaction_id=med.number1
      and ms.sr_instance_id=med.sr_instance_id
      and msi.plan_id = ms.plan_id
      and msi.organization_id = ms.organization_id
      and msi.sr_instance_id = ms.sr_instance_id
      and msi.inventory_item_id = ms.inventory_item_id;

 -- late/early, past due sales order/forecast
 -- SO/FC at risk, demand qty not satisfied, SO overcommit
 -- SO changes, alt ship method used
  insert into msc_nec_exc_dtl_compare(
          report_id,
          status,
          exception_detail_id,
          plan_id,
          exception_type,
          exception_group,
          from_plan,
          id_key,
          compare_key,
          char1,
          char2,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN)
  select  p_report_id,
          0,
          med.exception_detail_id,
          med.plan_id,
          med.exception_type,
          decode(med.exception_type, 67, 11, 70, 4, 71, 4, 5),
          decode(med.plan_id,g_from_plan,1,2),
          med.organization_id||':'||med.sr_instance_id||':'||
          med.inventory_item_id||':'||md.using_assembly_demand_date||':'||
          md.using_requirement_quantity ||':'|| md.customer_id ||':'||
          md.customer_site_id ||':'||md.demand_class||':'||
          md.order_number||':'||md.sales_order_line_id,
          decode(med.exception_type, 52, null,
                 67,med.quantity,
                 to_char(md.dmd_satisfied_date, p_mask)),
          msi.item_name,
          msi.planner_code,
          trunc(sysdate),
          -1,
          trunc(sysdate),
          -1,
          -1
     from msc_exception_details med,
          msc_system_items msi,
          msc_demands md
    where med.plan_id = p_plan_id
      and med.exception_type in (13,14,24,25,26,27,52,67,68,70,71)
      and md.plan_id=med.plan_id
      and md.demand_id=med.number1
      and md.sr_instance_id=med.sr_instance_id
      and msi.plan_id = md.plan_id
      and msi.organization_id = md.organization_id
      and msi.sr_instance_id = md.sr_instance_id
      and msi.inventory_item_id = md.inventory_item_id;

--- demand using item substitute
  insert into msc_nec_exc_dtl_compare(
          report_id,
          status,
          exception_detail_id,
          plan_id,
          exception_type,
          exception_group,
          from_plan,
          id_key,
          compare_key,
          char1,
          char2,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN)
  select  p_report_id,
          0,
          med.exception_detail_id,
          med.plan_id,
          med.exception_type,
          2,
          decode(med.plan_id,g_from_plan,1,2),
          med.organization_id||':'||med.sr_instance_id||':'||
          med.inventory_item_id||':'||md.using_assembly_demand_date||':'||
          md.using_requirement_quantity ||':'|| md.customer_id ||':'||
          md.customer_site_id ||':'||md.demand_class||':'||
          md.order_number||':'||md.sales_order_line_id,
          med.number1||':'|| -- substitute item
          med.number2||':'|| -- substitute org
          med.quantity, -- substitute qty
          msi.item_name,
          msi.planner_code,
          trunc(sysdate),
          -1,
          trunc(sysdate),
          -1,
          -1
     from msc_exception_details med,
          msc_system_items msi,
          msc_demands md
    where med.plan_id = p_plan_id
      and med.exception_type =49
      and md.plan_id=med.plan_id
      and md.demand_id=med.supplier_id
      and md.sr_instance_id=med.sr_instance_id
      and msi.plan_id = md.plan_id
      and msi.organization_id = md.organization_id
      and msi.sr_instance_id = md.sr_instance_id
      and msi.inventory_item_id = md.inventory_item_id;

-- late supply pegged to so/forecast
-- order at risk due to res/mat shortage/demand affected by res/mat constraint
-- Late Replenishment for DRP/MPS Demands
  insert into msc_nec_exc_dtl_compare(
          report_id,
          status,
          exception_detail_id,
          plan_id,
          exception_type,
          exception_group,
          from_plan,
          id_key,
          compare_key,
          char1,
          char2,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN)
  select  p_report_id,
          0,
          med.exception_detail_id,
          med.plan_id,
          med.exception_type,
          5,
          decode(med.plan_id,g_from_plan,1,2),
          med.organization_id||':'||med.sr_instance_id||':'||
          med.inventory_item_id||':'||md.using_assembly_demand_date||':'||
          md.using_requirement_quantity ||':'|| md.customer_id ||':'||
          md.customer_site_id ||':'||md.demand_class||':'||
          md.order_number||':'||md.sales_order_line_id,
          to_char(med.date1, p_mask)||':'||
             to_char(med.date2, p_mask)||':'||med.quantity,
          msi.item_name,
          msi.planner_code,
          trunc(sysdate),
          -1,
          trunc(sysdate),
          -1,
          -1
     from msc_exception_details med,
          msc_system_items msi,
          msc_demands md,
          msc_full_pegging mfp
    where med.plan_id = p_plan_id
      and med.exception_type in (15,16,23,35,41,42,69)
      and md.plan_id=med.plan_id
      and mfp.pegging_id=med.number2
      and md.sr_instance_id=med.sr_instance_id
      and md.plan_id=mfp.plan_id
      and md.demand_id=mfp.demand_id
      and md.sr_instance_id=mfp.sr_instance_id
      and msi.plan_id = md.plan_id
      and msi.organization_id = md.organization_id
      and msi.sr_instance_id = md.sr_instance_id
      and msi.inventory_item_id = md.inventory_item_id;

-- cross project
  insert into msc_nec_exc_dtl_compare(
          report_id,
          status,
          exception_detail_id,
          plan_id,
          exception_type,
          exception_group,
          from_plan,
          id_key,
          compare_key,
          char1,
          char2,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN)
  select  p_report_id,
          0,
          med.exception_detail_id,
          med.plan_id,
          med.exception_type,
          8,
          decode(med.plan_id,g_from_plan,1,2),
          med.organization_id||':'||med.sr_instance_id||':'||
          med.inventory_item_id||':'||
          ms.project_id||':'||ms.task_id||':'||
          md.project_id||':'||md.task_id,
          to_char(med.date1, p_mask)||':'||
             to_char(med.date2, p_mask)||':'||med.quantity,
          msi.item_name,
          msi.planner_code,
          trunc(sysdate),
          -1,
          trunc(sysdate),
          -1,
          -1
     from msc_exception_details med,
          msc_system_items msi,
          msc_demands md,
          msc_supplies ms,
          msc_full_pegging mfp
    where med.plan_id = p_plan_id
      and med.exception_type = 19
      and md.plan_id=med.plan_id
      and mfp.pegging_id=med.number2
      and md.sr_instance_id=med.sr_instance_id
      and md.plan_id=mfp.plan_id
      and md.demand_id=mfp.demand_id
      and md.sr_instance_id=mfp.sr_instance_id
      and ms.plan_id=med.plan_id
      and ms.transaction_id=med.number1
      and ms.sr_instance_id=med.sr_instance_id
      and msi.plan_id = ms.plan_id
      and msi.organization_id = ms.organization_id
      and msi.sr_instance_id = ms.sr_instance_id
      and msi.inventory_item_id = ms.inventory_item_id;

-- (trans) res over/under, max/min batch
  insert into msc_nec_exc_dtl_compare(
          report_id,
          status,
          exception_detail_id,
          plan_id,
          exception_type,
          exception_group,
          from_plan,
          id_key,
          compare_key,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN)
  select  p_report_id,
          0,
          med.exception_detail_id,
          med.plan_id,
          med.exception_type,
          decode(med.exception_type, 38, 7, 39, 7, 50, 7, 51, 7, 6),
          decode(med.plan_id,g_from_plan,1,2),
          med.organization_id||':'||med.sr_instance_id||':'||
          med.department_id||':'||med.resource_id,
          to_char(med.date1, p_mask)||':'||to_char(med.date2, p_mask)||':'||
              med.quantity,
          trunc(sysdate),
          -1,
          trunc(sysdate),
          -1,
          -1
     from msc_exception_details med
    where med.plan_id = p_plan_id
      and med.exception_type in (21,22,38,39,45,46,50,51);

END populate_all_exceptions;

Procedure checkPlanStatus(p_from_plan in number,
                            p_to_plan in number,
                            p_status out nocopy number,
                            p_report_id out nocopy number) is

  v_dummy number;
  v_need_recompare boolean;
  v_start date;
  v_end date;
  p_excp_id number;

   cursor compare_exist is
     select compare_completion_date,
            compare_start_date,
            report_id
       from msc_nec_compare_plans
         where ((from_plan = p_from_plan and to_plan = p_to_plan) or
                (from_plan = p_to_plan and to_plan = p_from_plan));

    CURSOR exc_c(p_plan_id number) is
       select exception_detail_id
         from MSC_NEC_EXC_DTL_COMPARE
        where plan_id = p_plan_id
          and report_id = p_report_id
          and rownum =1
          and exception_detail_id is not null;

     CURSOR need_recompare_c(p_plan_id number) is
       select 1
         from msc_exception_details med
        where med.plan_id = p_plan_id
          and med.exception_detail_id = p_excp_id;

begin


  OPEN compare_exist;
  FETCH compare_exist INTO v_start, v_end, p_report_id;
  CLOSE compare_exist;

  IF p_report_id is null then
        p_status := NOT_COMPARED;
  elsIF v_start is null then
        p_status := NEED_RECOMPARE;
  elsif v_start is not null and v_end is null then
        p_status := IN_PROGRESS;
  else

        OPEN exc_c(p_from_plan);
        FETCH exc_c INTO p_excp_id;
        CLOSE exc_c;

        if p_excp_id is null then
           p_status := NEED_RECOMPARE;
           return;
        else

           OPEN need_recompare_c(p_from_plan);
           FETCH need_recompare_c INTO v_dummy;
           CLOSE need_recompare_c;

           if v_dummy is null then
              p_status := NEED_RECOMPARE;
              return;
           end if;
         end if;

        p_excp_id :=null;
        v_dummy := null;

        OPEN exc_c(p_to_plan);
        FETCH exc_c INTO p_excp_id;
        CLOSE exc_c;

        if p_excp_id is null then
           p_status := NEED_RECOMPARE;
           return;
        else

           OPEN need_recompare_c(p_to_plan);
           FETCH need_recompare_c INTO v_dummy;
           CLOSE need_recompare_c;

           if v_dummy is null then
              p_status := NEED_RECOMPARE;
              return;
           end if;
         end if;

         p_status := AVAILABLE;

  end if;

end checkPlanStatus;

Procedure compare_all_exceptions(errbuf             OUT NOCOPY VARCHAR2,
                                 retcode            OUT NOCOPY NUMBER,
                                 p_from_plan         IN  NUMBER,
                                 p_to_plan          IN  NUMBER) is
  p_report_id number;
  p_plan_status number;
  p_plan_id number;
begin
  g_from_plan := p_from_plan;
  g_to_plan := p_to_plan;
  checkPlanStatus(p_from_plan, p_to_plan,p_plan_status,p_report_id);
  if p_plan_status = NOT_COMPARED then
               select msc_nec_compare_plans_s.nextval
               into p_report_id
               from dual;

               insert into msc_nec_compare_plans
                          (report_id,
                           from_plan,
                           to_plan,
                           compare_start_date,
                           LAST_UPDATE_DATE,
                           LAST_UPDATED_BY,
                           CREATION_DATE,
                           CREATED_BY,
                           LAST_UPDATE_LOGIN)
                    values(p_report_id,
                           p_from_plan,
                           p_to_plan,
                           sysdate,
                           sysdate,
                           -1,
                           sysdate,
                           -1,
                           -1);
        commit;
  elsif p_plan_status = IN_PROGRESS then
         -- some one else is running compare plans now
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Someone else is running the plan comparsion reports for the same plans.');
        return;
  elsif p_plan_status = AVAILABLE then
        FND_FILE.PUT_LINE(FND_FILE.LOG,
                   'No need to recompare plans.');
        return;
  elsif p_plan_status = NEED_RECOMPARE then
           update msc_nec_compare_plans
           set compare_completion_date = to_date(null),
               compare_start_date = sysdate
           where report_id = p_report_id;
           commit;
  end if;

      delete from msc_nec_exc_dtl_compare
        where report_id = p_report_id;

      populate_all_exceptions(p_from_plan,p_report_id);
      populate_all_exceptions(p_to_plan,p_report_id);

      compare_each_exception(p_report_id);

         -- insert summary rows which are grouped by exc_type
            insert into msc_nec_exc_dtl_compare(
                              report_id,
                              status,
                              plan_id,
                              exception_type,
                              exception_group,
                              from_plan,
                              match_id, -- to store exception count
                              LAST_UPDATE_DATE,
                              LAST_UPDATED_BY,
                              CREATION_DATE,
                              CREATED_BY,
                              LAST_UPDATE_LOGIN)
                      select  report_id,
                              status,
                              plan_id,
                              exception_type,
                              exception_group,
                              from_plan,
                              count(*),
                              trunc(sysdate),
                              -1,
                              trunc(sysdate),
                              -1,
                              -1
                      from msc_nec_exc_dtl_compare
                      where report_id = p_report_id
                       and exception_detail_id is not null
                       group by  report_id,
                              status,
                              plan_id,
                              exception_type,
                              exception_group,
                              from_plan,
                              trunc(sysdate),
                              -1,
                              trunc(sysdate),
                              -1,
                              -1 ;

         -- insert summary rows which are grouped by exc_group
            insert into msc_nec_exc_dtl_compare(
                              report_id,
                              status,
                              plan_id,
                              exception_group,
                              from_plan,
                              match_id, -- to store exception count
                              LAST_UPDATE_DATE,
                              LAST_UPDATED_BY,
                              CREATION_DATE,
                              CREATED_BY,
                              LAST_UPDATE_LOGIN)
                      select  report_id,
                              status,
                              plan_id,
                              exception_group,
                              from_plan,
                              sum(match_id),
                              trunc(sysdate),
                              -1,
                              trunc(sysdate),
                              -1,
                              -1
                      from msc_nec_exc_dtl_compare
                      where report_id = p_report_id
                        and exception_detail_id is null
                       group by  report_id,
                              status,
                              plan_id,
                              exception_group,
                              from_plan,
                              trunc(sysdate),
                              -1,
                              trunc(sysdate),
                              -1,
                              -1 ;

        update msc_nec_compare_plans
           set compare_completion_date = sysdate
           where report_id = p_report_id;

        commit;

     fnd_stats.gather_table_stats(ownname=>'MSC',
                                  tabname=>'MSC_NEC_EXC_DTL_COMPARE');

END compare_all_exceptions;

Procedure compare_each_exception(p_report_id number) IS
    a_excp_id number;
    a_exc_type number;
    a_id varchar2(500);
    a_compare varchar2(500);
    b_excp_id number;

    p_from_plan number := 1;
    p_to_plan number :=2;
    p_from_plan_id number := g_from_plan;
    p_to_plan_id number :=g_to_plan;

    CURSOR from_plan_c IS
    SELECT
           exception_detail_id,
           exception_type,
           id_key,
           compare_key
     FROM msc_nec_exc_dtl_compare
    WHERE from_plan = p_from_plan
      AND report_id = p_report_id
      AND status =0;

    CURSOR same_exc_c IS
    SELECT
           exception_detail_id
     FROM msc_nec_exc_dtl_compare
    WHERE from_plan = p_to_plan
      AND report_id = p_report_id
      AND status =0
      and exception_type = a_exc_type
      and id_key = a_id
      and compare_key = a_compare;

    CURSOR change_exc_c IS
    SELECT
           exception_detail_id
     FROM msc_nec_exc_dtl_compare
    WHERE from_plan = p_to_plan
      AND report_id = p_report_id
      AND status =0
      and exception_type = a_exc_type
      and id_key = a_id;

 from_plan_count number;
 to_plan_count number;
Begin

   select sum(decode(from_plan,1,1,0)), sum(decode(from_plan,2,1,0))
    into from_plan_count, to_plan_count
     from msc_nec_exc_dtl_compare
   where report_id = p_report_id
     and status =0;

   if from_plan_count > to_plan_count then
      p_from_plan := 2;
      p_to_plan :=1;
      p_from_plan_id := g_to_plan;
      p_to_plan_id :=g_from_plan;
   end if;

   OPEN from_plan_c;
   LOOP
   FETCH from_plan_c INTO
          a_excp_id,
          a_exc_type,
          a_id,
          a_compare;
   EXIT WHEN from_plan_c%NOTFOUND;

      b_excp_id := null;
      OPEN same_exc_c;
      FETCH same_exc_c INTO
          b_excp_id;
      CLOSE same_exc_c;

      if b_excp_id is not null then -- found the same excp
         update msc_nec_exc_dtl_compare
            set status = 1,
                match_id = b_excp_id
          where plan_id = p_from_plan_id
            and exception_detail_id = a_excp_id
            and report_id = p_report_id;

         update msc_nec_exc_dtl_compare
            set status = 1,
                match_id = a_excp_id
          where plan_id = p_to_plan_id
            and exception_detail_id = b_excp_id
            and report_id = p_report_id;
       end if;
   end loop;
   CLOSE from_plan_c;

   OPEN from_plan_c;
   LOOP
   FETCH from_plan_c INTO
          a_excp_id,
          a_exc_type,
          a_id,
          a_compare;
   EXIT WHEN from_plan_c%NOTFOUND;
      b_excp_id := null;
      OPEN change_exc_c;
      FETCH change_exc_c INTO
          b_excp_id;
      CLOSE change_exc_c;
      if b_excp_id is not null then -- found the change excp
         update msc_nec_exc_dtl_compare
            set status = 2,
                match_id = b_excp_id
          where plan_id = p_from_plan_id
            and exception_detail_id = a_excp_id
            and report_id = p_report_id;

         update msc_nec_exc_dtl_compare
            set status = 2,
                match_id = a_excp_id
          where plan_id = p_to_plan_id
            and exception_detail_id = b_excp_id
            and report_id = p_report_id;
       end if;
   end loop;

   CLOSE from_plan_c;

End compare_each_exception;

Procedure filter_data(p_report_id number,
                              p_excp_type number,
                              where_clause varchar2) is
   sql_statement varchar2(32000);
begin

        sql_statement :=
                ' insert into msc_nec_exc_dtl_temp( '||
                             ' query_id, '||
                             ' status, '||
                             ' exception_detail_id,' ||
                             ' plan_id,' ||
                             ' exception_group,'||
                             ' exception_type,'||
                             ' from_plan,'||
                             ' match_id,'||
                             ' char1, '||
                             ' char2,' ||
                             ' LAST_UPDATE_DATE,'||
                             ' LAST_UPDATED_BY, '||
                             ' CREATION_DATE, '||
                             ' CREATED_BY, '||
                             ' LAST_UPDATE_LOGIN) '||
                     ' select  :query_id, '||
                             ' med.status,'||
                             ' med.exception_detail_id, '||
                             ' med.plan_id, '||
                             ' med.exception_group,'||
                             ' med.exception_type, '||
                             ' med.from_plan, '||
                             ' med.match_id,'||
                             ' med.char1, '||
                             ' med.char2, '||
                             ' trunc(sysdate), '||
                             ' -1, '||
                             ' trunc(sysdate), '||
                             ' -1, '||
                             ' -1 ';
        if g_long_query or
             (where_clause is not null and p_excp_type in
             (21,22,23,35,36,38,39,40,45,46,50,51)) then
           sql_statement := sql_statement ||
                     ' from msc_nec_exc_dtl_compare med, '||
                          ' msc_exception_details_v medv '||
                     ' where med.report_id = :p_report_id '||
                       ' and med.exception_type = :p_excp '||
                       ' and med.exception_detail_id is not null '||
                       ' and med.plan_id = medv.plan_id ' ||
                       ' and med.exception_detail_id = '||
                             ' medv.exception_id ' ||
                       where_clause;
         else
            sql_statement := sql_statement ||
                     ' from msc_nec_exc_dtl_compare med '||
                     ' where med.report_id = :p_report_id '||
                       ' and med.exception_type = :p_excp '||
                       ' and med.exception_detail_id is not null '||
                       where_clause;
         end if;
               EXECUTE IMMEDIATE sql_statement USING g_excp_query_id,
                                        p_report_id,
                                        p_excp_type;

end filter_data;

Procedure compare_plan_need_refresh(p_plan_id number) is
   v_report_id number_arr;
begin
           select report_id
             bulk collect into v_report_id
             from msc_nec_compare_plans
            where from_plan = p_plan_id or
                 to_plan = p_plan_id
            for update of compare_completion_date nowait;

        forall a in 1..v_report_id.count
           update msc_nec_compare_plans
           set compare_completion_date = to_date(null),
               compare_start_date = to_date(null)
           where report_id = v_report_id(a);

           commit;
exception when no_data_found then
            null;
          when app_exception.record_lock_exception then
              MSC_UTIL.msc_debug('can not lock msc_nec_compare_plans table for update');
END compare_plan_need_refresh;

Function category_name(p_org_id number, p_instance_id number,
                       p_item_id number,
                       p_plan_id number) return varchar2 is

   v_cat_name varchar2(250);
   l_plan_type number;
   l_def_pref_id number;

  cursor plan_type_c(v_plan_id number) is
  select curr_plan_type
  from msc_plans
  where plan_id = v_plan_id;

   CURSOR cat_name_cur(v_category_set_id number) IS
     SELECT category_set_name
     FROM msc_category_sets
     where category_set_id = v_category_set_id;
begin

    if p_item_id is null then
       return null;
    end if;

  open plan_type_c(p_plan_id);
  fetch plan_type_c into l_plan_type;
  close plan_type_c;

  l_def_pref_id := msc_get_name.get_default_pref_id(fnd_global.user_id);
  g_cat_set:= msc_get_name.GET_preference('CATEGORY_SET_ID',l_def_pref_id, l_plan_type);

    OPEN cat_name_cur(g_cat_set);
    FETCH cat_name_cur INTO v_cat_name;
    CLOSE cat_name_cur;

    return v_cat_name;

end category_name;

Procedure purge_plan(errbuf  OUT NOCOPY VARCHAR2,
                     retcode OUT NOCOPY NUMBER,
                     p_plan_id IN NUMBER) is

  cursor compare_c is
   select report_id
     from msc_nec_compare_plans
    where from_plan = p_plan_id or
            to_plan = p_plan_id;
  p_report_id number;
begin
   retcode :=0;

   open compare_c;
   loop
   fetch compare_c INTO p_report_id;
   exit when compare_c%NOTFOUND;

       delete msc_nec_compare_plans
         where report_id = p_report_id;

       delete msc_nec_exc_dtl_compare
         where report_id = p_report_id;
   end loop;

   close compare_c;

   commit;
exception when others then
   null;
end purge_plan;

END Msc_Netchange_PKG;

/
