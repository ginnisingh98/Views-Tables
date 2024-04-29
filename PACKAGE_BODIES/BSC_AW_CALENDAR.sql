--------------------------------------------------------
--  DDL for Package Body BSC_AW_CALENDAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_AW_CALENDAR" AS
/*$Header: BSCAWCAB.pls 120.18 2006/05/31 20:52:09 vsurendr ship $*/

/*
given a calendar id, create the aw objects for the calendar.
This module will directly read the BSC calendars. will not go through bsc_metadata package
This procedure is called when the calendar has to be created...this is first time
or when there is a change to the calendar structure itself.
if the calendar is extended or the start date changes, this procedure is not called. we simply refresh the
calendar load program
*/
procedure create_calendar(p_calendar number,p_options varchar2) is
l_affected_kpi dbms_sql.varchar2_table;
Begin
  create_calendar(p_calendar,p_options,l_affected_kpi);
Exception when others then
  log_n('Exception in create_calendar '||sqlerrm);
  raise;
End;

procedure create_calendar(
p_calendar number,
p_options varchar2,
p_affected_kpi out nocopy dbms_sql.varchar2_table
) is
Begin
  if p_options is not null then
    bsc_aw_utility.parse_parameter_values(p_options,',',bsc_aw_utility.g_options);
    bsc_aw_utility.open_file('TEST');
    bsc_aw_utility.dmp_g_options(bsc_aw_utility.g_options);
  end if;
  init_all;
  attach_workspace(p_options);
  create_calendar(p_calendar,p_affected_kpi);
  --
  bsc_aw_management.commit_aw;
  commit;
  if nvl(bsc_aw_utility.get_parameter_value('NO DETACH WORKSPACE'),'N')='N' then
    bsc_aw_management.detach_workspace;
  end if;
Exception when others then
  bsc_aw_management.detach_workspace;
  log_n('Exception in create_calendar '||sqlerrm);
  raise;
End;

procedure create_calendar(p_calendar number,p_affected_kpi out nocopy dbms_sql.varchar2_table) is
l_calendar calendar_r;
l_create_objects boolean;
l_create_program boolean;
l_recreate varchar2(40);
Begin
  l_create_objects:=false;
  l_create_program:=false;
  l_calendar.calendar_id:=p_calendar;
  get_bsc_calendar_data(l_calendar);
  set_aw_object_names(l_calendar);
  normalize_per_relation(l_calendar);
  get_kpi_for_calendar(l_calendar);
  set_calendar_properties(l_calendar);
  if g_debug then
    dmp_calendar(l_calendar);
  end if;
  check_calendar_create(l_calendar,l_recreate,p_affected_kpi);
  --if there is no change, then l_recreate is null
  if l_recreate='create all' then
    l_create_objects:=true;
    l_create_program:=true;
  elsif l_recreate='create program' then
    l_create_program:=true;
  end if;
  bsc_aw_utility.add_sqlerror(-34340,'ignore',null);
  bsc_aw_utility.add_sqlerror(-36656,'ignore',null);
  if l_create_objects then
    create_calendar_objects(l_calendar);
  end if;
  if l_create_objects or l_create_program then
    create_calendar_program(l_calendar);
  end if;
  if l_create_objects then
    create_calendar_metadata(l_calendar);--create in bsc_olap metadata
  end if;
  bsc_aw_utility.remove_sqlerror(-34340,'ignore');
  bsc_aw_utility.remove_sqlerror(-36656,'ignore');
Exception when others then
  log_n('Exception in create_calendar '||sqlerrm);
  raise;
End;

/*
this sets the properties like dim type=time, multi level etc
*/
procedure set_calendar_properties(p_calendar in out nocopy calendar_r) is
Begin
  p_calendar.property:='calendar='||p_calendar.calendar_id||',dimension type=time,multi level,relation name='||
  p_calendar.relation_name||',denorm relation name='||p_calendar.denorm_relation_name||
  ',end period relation name='||p_calendar.end_period_relation_name||',level name dim='||p_calendar.levels_name;
Exception when others then
  log_n('Exception in set_calendar_properties '||sqlerrm);
  raise;
End;

procedure get_bsc_calendar_data(
p_calendar in out nocopy calendar_r) is
--
cursor c1(p_calendar number) is
select db_column_name,periodicity_id,periodicity_type,source from bsc_sys_periodicities where calendar_id=p_calendar
and periodicity_type not in (11,12);
--
l_count number;
Begin
  l_count:=1;
  open c1(p_calendar.calendar_id);
  loop
    fetch c1 into p_calendar.periodicity(l_count).db_column_name,
    p_calendar.periodicity(l_count).periodicity_id,p_calendar.periodicity(l_count).periodicity_type,
    p_calendar.periodicity(l_count).source;
    exit when c1%notfound;
    l_count:=l_count+1;
  end loop;
Exception when others then
  log_n('Exception in get_bsc_calendar_data '||sqlerrm);
  raise;
End;

procedure set_aw_object_names(p_calendar in out nocopy calendar_r) is
Begin
  for i in 1..p_calendar.periodicity.count loop
    p_calendar.periodicity(i).dim_name:=nvl(lower(p_calendar.periodicity(i).db_column_name),'per')||'_'||
    p_calendar.periodicity(i).periodicity_id||'_cal_'||p_calendar.calendar_id;
  end loop;
  --concat dim
  p_calendar.dim_name:=get_calendar_name(p_calendar.calendar_id);
  p_calendar.relation_name:=get_calendar_name(p_calendar.calendar_id)||'.rel';
  p_calendar.denorm_relation_name:=p_calendar.relation_name||'.denorm';
  p_calendar.end_period_relation_name:=get_calendar_name(p_calendar.calendar_id)||'.rel.end_period';
  p_calendar.levels_name:=get_calendar_name(p_calendar.calendar_id)||'.levels';
  p_calendar.end_period_levels_name:=get_calendar_name(p_calendar.calendar_id)||'.end_period_levels';
  --we create the relations between the bsc periodicities and std periodicities
  for i in 1..p_calendar.periodicity.count loop
    if p_calendar.periodicity(i).periodicity_type=9 then
      p_calendar.periodicity(i).aw_time_dim_name:='aw_day_cal_'||p_calendar.calendar_id;
      p_calendar.periodicity(i).aw_bsc_aw_rel_name:=p_calendar.periodicity(i).dim_name||'.aw_day.rel'; --given bsc, what is aw?
      p_calendar.periodicity(i).aw_aw_bsc_rel_name:='aw_day.bsc_calendar_'||p_calendar.calendar_id||'.rel';--given aw, what is bsc time?
    elsif p_calendar.periodicity(i).periodicity_type=7 then
      p_calendar.periodicity(i).aw_time_dim_name:='aw_week_cal_'||p_calendar.calendar_id;
      p_calendar.periodicity(i).aw_bsc_aw_rel_name:=p_calendar.periodicity(i).dim_name||'.aw_week.rel'; --given bsc, what is aw?
      p_calendar.periodicity(i).aw_aw_bsc_rel_name:='aw_week.bsc_calendar_'||p_calendar.calendar_id||'.rel';--given aw, what is bsc time?
    elsif p_calendar.periodicity(i).periodicity_type=5 then
      p_calendar.periodicity(i).aw_time_dim_name:='aw_month_cal_'||p_calendar.calendar_id;
      p_calendar.periodicity(i).aw_bsc_aw_rel_name:=p_calendar.periodicity(i).dim_name||'.aw_month.rel'; --given bsc, what is aw?
      p_calendar.periodicity(i).aw_aw_bsc_rel_name:='aw_month.bsc_calendar_'||p_calendar.calendar_id||'.rel';--given aw, what is bsc time?
    elsif p_calendar.periodicity(i).periodicity_type=3 then
      p_calendar.periodicity(i).aw_time_dim_name:='aw_quarter_cal_'||p_calendar.calendar_id;
      p_calendar.periodicity(i).aw_bsc_aw_rel_name:=p_calendar.periodicity(i).dim_name||'.aw_quarter.rel'; --given bsc, what is aw?
      p_calendar.periodicity(i).aw_aw_bsc_rel_name:='aw_quarter.bsc_calendar_'||p_calendar.calendar_id||'.rel';--given aw, what is bsc time?
    elsif p_calendar.periodicity(i).periodicity_type=1 then
      p_calendar.periodicity(i).aw_time_dim_name:='aw_year_cal_'||p_calendar.calendar_id;
      p_calendar.periodicity(i).aw_bsc_aw_rel_name:=p_calendar.periodicity(i).dim_name||'.aw_year.rel'; --given bsc, what is aw?
      p_calendar.periodicity(i).aw_aw_bsc_rel_name:='aw_year.bsc_calendar_'||p_calendar.calendar_id||'.rel';--given aw, what is bsc time?
    end if;
  end loop;
  --define cal.period and cal.year. this will be used in the olap table function views
  p_calendar.misc_object(p_calendar.misc_object.count+1).object_name:='period_cal_'||p_calendar.calendar_id;
  p_calendar.misc_object(p_calendar.misc_object.count).object_type:='variable';
  p_calendar.misc_object(p_calendar.misc_object.count).datatype:='number';
  --
  p_calendar.misc_object(p_calendar.misc_object.count+1).object_name:='year_cal_'||p_calendar.calendar_id;
  p_calendar.misc_object(p_calendar.misc_object.count).object_type:='variable';
  p_calendar.misc_object(p_calendar.misc_object.count).datatype:='number';
  --
  p_calendar.misc_object(p_calendar.misc_object.count+1).object_name:='periodicity_cal_'||p_calendar.calendar_id;
  p_calendar.misc_object(p_calendar.misc_object.count).object_type:='variable';
  p_calendar.misc_object(p_calendar.misc_object.count).datatype:='number';
  --
Exception when others then
  log_n('Exception in set_aw_object_names '||sqlerrm);
  raise;
End;

procedure create_calendar_objects(
p_calendar in out nocopy calendar_r) is
--
Begin
  --create the objects
  --create the aw std periodicities
  g_stmt:='dfn aw_day_cal_'||p_calendar.calendar_id||' dimension day';
  bsc_aw_dbms_aw.execute(g_stmt);
  g_stmt:='dfn aw_week_cal_'||p_calendar.calendar_id||' dimension week ending sunday';
  bsc_aw_dbms_aw.execute(g_stmt);
  g_stmt:='dfn aw_month_cal_'||p_calendar.calendar_id||' dimension month';
  bsc_aw_dbms_aw.execute(g_stmt);
  g_stmt:='dfn aw_quarter_cal_'||p_calendar.calendar_id||' dimension quarter';
  bsc_aw_dbms_aw.execute(g_stmt);
  g_stmt:='dfn aw_year_cal_'||p_calendar.calendar_id||' dimension year';
  bsc_aw_dbms_aw.execute(g_stmt);
  --
  for i in 1..p_calendar.periodicity.count loop
    g_stmt:='dfn '||p_calendar.periodicity(i).dim_name||' dimension text';
    bsc_aw_dbms_aw.execute(g_stmt);
  end loop;
  --
  g_stmt:='dfn '||p_calendar.dim_name||' dimension concat(';
  for i in 1..p_calendar.periodicity.count loop
    g_stmt:=g_stmt||p_calendar.periodicity(i).dim_name||',';
  end loop;
  g_stmt:=substr(g_stmt,1,length(g_stmt)-1)||')';
  bsc_aw_dbms_aw.execute(g_stmt);
  --to merge new periodicities
  for i in 1..p_calendar.periodicity.count loop
    g_stmt:='CHGDFN '||p_calendar.dim_name||' base add '||p_calendar.periodicity(i).dim_name;
    bsc_aw_dbms_aw.execute(g_stmt); --we have added ORA-36656 to ignore list
  end loop;
  g_stmt:='dfn '||p_calendar.levels_name||' dimension text';
  bsc_aw_dbms_aw.execute(g_stmt);
  --we need to add levels names as parent.child
  for i in 1..p_calendar.parent_child.count loop
    if p_calendar.parent_child(i).parent is not null and p_calendar.parent_child(i).child is not null then
      g_stmt:='maintain '||p_calendar.levels_name||' merge '''||p_calendar.parent_child(i).parent_dim_name||'.'||
      p_calendar.parent_child(i).child_dim_name||'''';
      bsc_aw_dbms_aw.execute(g_stmt);
    end if;
  end loop;
  --
  g_stmt:='dfn '||p_calendar.end_period_levels_name||' dimension text';
  bsc_aw_dbms_aw.execute(g_stmt);
  for i in 1..p_calendar.periodicity.count loop
    g_stmt:='maintain '||p_calendar.end_period_levels_name||' merge '''||
    p_calendar.periodicity(i).dim_name||'''';
    bsc_aw_dbms_aw.execute(g_stmt);
  end loop;
  --
  g_stmt:='dfn '||p_calendar.relation_name||' relation '||p_calendar.dim_name||' <'||p_calendar.dim_name||' '||p_calendar.levels_name||'>';
  bsc_aw_dbms_aw.execute(g_stmt);
  g_stmt:='dfn '||p_calendar.denorm_relation_name||' relation '||p_calendar.dim_name||' <'||p_calendar.dim_name||' '||
  p_calendar.end_period_levels_name||'>'; --end_period_levels_name is simply the level dim names
  bsc_aw_dbms_aw.execute(g_stmt);
  g_stmt:='dfn '||p_calendar.end_period_relation_name||' relation '||p_calendar.dim_name||' <'||p_calendar.dim_name||' '||
  p_calendar.end_period_levels_name||'>';
  bsc_aw_dbms_aw.execute(g_stmt);
  --also define a temp variable that all aggregations with balance type measures will use
  g_stmt:='dfn '||p_calendar.end_period_relation_name||'.temp TEXT <'||p_calendar.dim_name||' '||p_calendar.end_period_levels_name||'>';
  bsc_aw_dbms_aw.execute(g_stmt);
  --
  for i in 1..p_calendar.periodicity.count loop
    if p_calendar.periodicity(i).aw_time_dim_name is not null then
      g_stmt:='dfn '||p_calendar.periodicity(i).aw_bsc_aw_rel_name||' relation '||p_calendar.periodicity(i).aw_time_dim_name||
      '<'||p_calendar.periodicity(i).dim_name||'>';
      bsc_aw_dbms_aw.execute(g_stmt);
      g_stmt:='dfn '||p_calendar.periodicity(i).aw_aw_bsc_rel_name||' relation bsc_calendar_'||p_calendar.calendar_id||
      '<'||p_calendar.periodicity(i).aw_time_dim_name||'>';
      bsc_aw_dbms_aw.execute(g_stmt);
    end if;
  end loop;
  --
  for i in 1..p_calendar.misc_object.count loop
    g_stmt:='dfn '||p_calendar.misc_object(i).object_name||' '||p_calendar.misc_object(i).datatype||' <'||p_calendar.dim_name||'>';
    bsc_aw_dbms_aw.execute(g_stmt);
  end loop;
Exception when others then
  log_n('Exception in create_calendar_objects '||sqlerrm);
  raise;
End;

procedure create_calendar_program(
p_calendar in out nocopy calendar_r
) is
--
l_name varchar2(300);
l_lower_periodicities periodicity_tb;
l_upper_periodicities periodicity_tb;
--
Begin
  --
  p_calendar.load_program:='load_cal_'||p_calendar.calendar_id;
  g_commands.delete;
  bsc_aw_utility.add_g_commands(g_commands,'dfn '||p_calendar.load_program||' program');
  bsc_aw_utility.add_g_commands(g_commands,'allstat');
  for i in 1..p_calendar.periodicity.count loop
    --to populate end_period_relation_name
    l_name:='prev_'||p_calendar.periodicity(i).db_column_name;
    bsc_aw_utility.add_g_commands(g_commands,'if exists(\'''||l_name||'\'') eq false');
    bsc_aw_utility.add_g_commands(g_commands,'then do');
    bsc_aw_utility.add_g_commands(g_commands,'dfn prev_'||p_calendar.periodicity(i).db_column_name||' TEXT session');
    bsc_aw_utility.add_g_commands(g_commands,'doend');
  end loop;
  --4566074 : these variables must be initialized since sessions are used, else old values get pulled in
  for i in 1..p_calendar.periodicity.count loop
    bsc_aw_utility.add_g_commands(g_commands,'prev_'||p_calendar.periodicity(i).db_column_name||'=NA');
  end loop;
  --
  for i in 1..p_calendar.periodicity.count loop
    if p_calendar.periodicity(i).aw_time_dim_name is not null then
      bsc_aw_utility.add_g_commands(g_commands,'maintain '||p_calendar.periodicity(i).aw_time_dim_name||' merge arg(1)');
      bsc_aw_utility.add_g_commands(g_commands,'maintain '||p_calendar.periodicity(i).aw_time_dim_name||' merge arg(2)');
    end if;
  end loop;
  --
  bsc_aw_utility.add_g_commands(g_commands,'sql declare c1 cursor for select --');
  for i in 1..p_calendar.periodicity.count loop
    bsc_aw_utility.add_g_commands(g_commands,p_calendar.periodicity(i).db_column_name||'||\''.\''||year, --');
  end loop;
  for i in 1..p_calendar.periodicity.count loop
    if p_calendar.periodicity(i).periodicity_type=1 then --this is yearly. then we  hardcode 0 this is what iviewer wants to see
      bsc_aw_utility.add_g_commands(g_commands,'0 '||p_calendar.periodicity(i).db_column_name||', --');
    else
      bsc_aw_utility.add_g_commands(g_commands,p_calendar.periodicity(i).db_column_name||', --');
    end if;
  end loop;
  for i in 1..p_calendar.periodicity.count loop
    bsc_aw_utility.add_g_commands(g_commands,'year year'||i||', --');
  end loop;
  for i in 1..p_calendar.periodicity.count loop
    bsc_aw_utility.add_g_commands(g_commands,p_calendar.periodicity(i).periodicity_id||' per_'||
    p_calendar.periodicity(i).periodicity_id||', --');
  end loop;
  /*
  earlier we were using month||\'' \''||day30||\'' \''||year. got error
  Exception in load_calendar ORA-35758: (VCTODT03) '2 29 1997' is not a valid date because 29 is out of range for a day of the month.
  this is because month is fiscal month, not calendar month. so corrected to calendar month, day and year
  */
  for i in 1..p_calendar.periodicity.count loop
    if p_calendar.periodicity(i).aw_time_dim_name is not null then
      if bsc_aw_utility.get_db_version>=10 then
        bsc_aw_utility.add_g_commands(g_commands,'to_date(calendar_month||\'' \''||calendar_day||\'' \''||calendar_year,\''MM DD YYYY\'') aw_day_'||p_calendar.periodicity(i).db_column_name||', --');
      else
        bsc_aw_utility.add_g_commands(g_commands,'calendar_month||\'' \''||calendar_day||\'' \''||calendar_year aw_day_'||p_calendar.periodicity(i).db_column_name||', --');
      end if;
    end if;
  end loop;
  bsc_aw_utility.trim_g_commands(g_commands,4,' --');
  bsc_aw_utility.add_g_commands(g_commands,'from bsc_db_calendar where calendar_id='||p_calendar.calendar_id||' order by calendar_year,calendar_month,calendar_day');
  bsc_aw_utility.add_g_commands(g_commands,'sql open c1');
  bsc_aw_utility.add_g_commands(g_commands,'sql fetch c1 loop into --');
  for i in 1..p_calendar.periodicity.count loop
    bsc_aw_utility.add_g_commands(g_commands,':append '||p_calendar.periodicity(i).dim_name||' --');
  end loop;
  for i in 1..p_calendar.periodicity.count loop
    bsc_aw_utility.add_g_commands(g_commands,':period_cal_'||p_calendar.calendar_id||'('||p_calendar.dim_name||' '||
    p_calendar.periodicity(i).dim_name||') --');
  end loop;
  for i in 1..p_calendar.periodicity.count loop
    bsc_aw_utility.add_g_commands(g_commands,':year_cal_'||p_calendar.calendar_id||'('||p_calendar.dim_name||' '||
    p_calendar.periodicity(i).dim_name||') --');
  end loop;
  for i in 1..p_calendar.periodicity.count loop
    bsc_aw_utility.add_g_commands(g_commands,':periodicity_cal_'||p_calendar.calendar_id||'('||p_calendar.dim_name||' '||
    p_calendar.periodicity(i).dim_name||') --');
  end loop;
  for i in 1..p_calendar.periodicity.count loop
    if p_calendar.periodicity(i).aw_time_dim_name is not null then
      bsc_aw_utility.add_g_commands(g_commands,':'||p_calendar.periodicity(i).aw_bsc_aw_rel_name||' --');
    end if;
  end loop;
  bsc_aw_utility.add_g_commands(g_commands,'then --');
  --
  --add the code for populating end_period_relation_name
  for i in 1..p_calendar.periodicity.count loop
    bsc_aw_utility.add_g_commands(g_commands,'if prev_'||p_calendar.periodicity(i).db_column_name||' EQ NA --');
    bsc_aw_utility.add_g_commands(g_commands,'then do --');
    bsc_aw_utility.add_g_commands(g_commands,'prev_'||p_calendar.periodicity(i).db_column_name||' = '||p_calendar.periodicity(i).dim_name||' --');
    bsc_aw_utility.add_g_commands(g_commands,'doend --');
    --if this is not the lowest level , ie. day level then...
    --for day, source is null
    if p_calendar.periodicity(i).source is not null then
      --get all the lower periodicities
      l_lower_periodicities.delete;
      get_all_lower_periodicities(p_calendar.periodicity(i),p_calendar,l_lower_periodicities);
      if l_lower_periodicities.count>0 then
        bsc_aw_utility.add_g_commands(g_commands,'else do --');
        bsc_aw_utility.add_g_commands(g_commands,'if prev_'||p_calendar.periodicity(i).db_column_name||' NE '||p_calendar.periodicity(i).dim_name||' --');
        bsc_aw_utility.add_g_commands(g_commands,'then do --');
        for j in 1..l_lower_periodicities.count loop
          bsc_aw_utility.add_g_commands(g_commands,p_calendar.end_period_relation_name||'('||p_calendar.periodicity(i).dim_name||' '||
          'prev_'||p_calendar.periodicity(i).db_column_name||' '||p_calendar.end_period_levels_name||' \'''||l_lower_periodicities(j).dim_name||'\'')='||
          p_calendar.dim_name||'('||l_lower_periodicities(j).dim_name||' prev_'||l_lower_periodicities(j).db_column_name||') --');
        end loop;
        bsc_aw_utility.add_g_commands(g_commands,'doend --');
        bsc_aw_utility.add_g_commands(g_commands,'doend --');
      end if;
    end if;
  end loop;
  for i in 1..p_calendar.periodicity.count loop
    bsc_aw_utility.add_g_commands(g_commands,'if prev_'||p_calendar.periodicity(i).db_column_name||' NE '||p_calendar.periodicity(i).dim_name||' --');
    bsc_aw_utility.add_g_commands(g_commands,'then do --');
    bsc_aw_utility.add_g_commands(g_commands,'prev_'||p_calendar.periodicity(i).db_column_name||' = '||p_calendar.periodicity(i).dim_name||' --');
    bsc_aw_utility.add_g_commands(g_commands,'doend --');
  end loop;
  ----------
  --code to populate denorm relation
  for i in 1..p_calendar.periodicity.count loop
    l_upper_periodicities.delete;
    get_all_upper_periodicities(p_calendar.periodicity(i),p_calendar,l_upper_periodicities);
    if l_upper_periodicities.count>0 then
      for j in 1..l_upper_periodicities.count loop
        bsc_aw_utility.add_g_commands(g_commands,p_calendar.denorm_relation_name||'('||p_calendar.dim_name||' '||p_calendar.periodicity(i).dim_name||
        ' '||p_calendar.end_period_levels_name||' \'''||l_upper_periodicities(j).dim_name||'\'')='||p_calendar.dim_name||'('||
        p_calendar.dim_name||' '||l_upper_periodicities(j).dim_name||') --');
      end loop;
    end if;
  end loop;
  ----------
  --code to populate the other relations
  for i in 1..p_calendar.parent_child.count loop
    if p_calendar.parent_child(i).parent is not null and p_calendar.parent_child(i).child is not null then
      l_name:=p_calendar.parent_child(i).child_dim_name;
      bsc_aw_utility.add_g_commands(g_commands,p_calendar.relation_name||'('||p_calendar.dim_name||' '||l_name||' '||
      p_calendar.levels_name||' \'''||p_calendar.parent_child(i).parent_dim_name||'.'||p_calendar.parent_child(i).child_dim_name
      ||'\'')='||
      p_calendar.dim_name||'('||p_calendar.dim_name||' '||p_calendar.parent_child(i).parent_dim_name||') --');
    end if;
  end loop;
  for i in 1..p_calendar.periodicity.count loop
    if p_calendar.periodicity(i).aw_time_dim_name is not null then
      bsc_aw_utility.add_g_commands(g_commands,p_calendar.periodicity(i).aw_aw_bsc_rel_name||'('||p_calendar.periodicity(i).aw_time_dim_name||' '||
      p_calendar.periodicity(i).aw_bsc_aw_rel_name||')='||p_calendar.dim_name||'('||p_calendar.periodicity(i).dim_name||' '||
      p_calendar.periodicity(i).dim_name||') --');
    end if;
  end loop;
  bsc_aw_utility.trim_g_commands(g_commands,3,null);
  bsc_aw_utility.add_g_commands(g_commands,'sql close c1');
  bsc_aw_utility.add_g_commands(g_commands,'sql cleanup');
  --part II----------------------
  /*
  we have an issue where if 2004 is the last year, then data in calendar will not go to 2005. this means for the last periods in 2004,
  like year 2004, qtr 4 2004, semester 2 2004, we will not have if prev_YEAR NE year_1_cal_1 - so we are not populating end period rel
  for relation. we have to add this last data to the relation. pick the last row in the calendar, then assign it as the end period rel
  for year 2004, day 366.2004 is the end period rel etc
  */
  bsc_aw_utility.add_g_commands(g_commands,'sql declare c1 cursor for select --');
  for i in 1..p_calendar.periodicity.count loop
    bsc_aw_utility.add_g_commands(g_commands,p_calendar.periodicity(i).db_column_name||'||\''.\''||year, --');
  end loop;
  bsc_aw_utility.trim_g_commands(g_commands,4,' --');
  bsc_aw_utility.add_g_commands(g_commands,'from (select * from bsc_db_calendar where calendar_id='||p_calendar.calendar_id||
  ' order by calendar_year desc,calendar_month desc,calendar_day desc) where rownum=1');
  bsc_aw_utility.add_g_commands(g_commands,'sql open c1');
  bsc_aw_utility.add_g_commands(g_commands,'sql fetch c1 loop into --');
  for i in 1..p_calendar.periodicity.count loop
    bsc_aw_utility.add_g_commands(g_commands,':match '||p_calendar.periodicity(i).dim_name||' --');
  end loop;
  --add the code for populating end_period_relation_name
  for i in 1..p_calendar.periodicity.count loop
    if p_calendar.periodicity(i).source is not null then
      --get all the lower periodicities
      l_lower_periodicities.delete;
      get_all_lower_periodicities(p_calendar.periodicity(i),p_calendar,l_lower_periodicities);
      if l_lower_periodicities.count>0 then
        for j in 1..l_lower_periodicities.count loop
          bsc_aw_utility.add_g_commands(g_commands,p_calendar.end_period_relation_name||'('||p_calendar.periodicity(i).dim_name||' '||
          p_calendar.periodicity(i).dim_name||' '||p_calendar.end_period_levels_name||' \'''||l_lower_periodicities(j).dim_name||'\'')='||
          p_calendar.dim_name||'('||l_lower_periodicities(j).dim_name||' '||l_lower_periodicities(j).dim_name||') --');
        end loop;
      end if;
    end if;
  end loop;
  bsc_aw_utility.trim_g_commands(g_commands,3,null);
  --
  bsc_aw_utility.exec_program_commands(p_calendar.load_program,g_commands);
Exception when others then
  log_n('Exception in create_calendar_program '||sqlerrm);
  raise;
End;

/*
given a periodicity, gets all the lower periodicities, ie denormalizes
used to fill in end_period_relation_name in create_calendar_program
called recursively
*/
procedure get_all_lower_periodicities(
p_periodicity periodicity_r,
p_calendar calendar_r,
p_lower_periodicities in out nocopy periodicity_tb
) is
--
l_lower_periodicities periodicity_tb;
l_flag boolean;
Begin
  get_child_periodicities(p_periodicity,p_calendar,l_lower_periodicities);
  for i in 1..l_lower_periodicities.count loop
    get_all_lower_periodicities(l_lower_periodicities(i),p_calendar,p_lower_periodicities);
  end loop;
  for i in 1..l_lower_periodicities.count loop
    --must add only distinct list
    l_flag:=false;
    for j in 1..p_lower_periodicities.count loop
      if p_lower_periodicities(j).periodicity_id=l_lower_periodicities(i).periodicity_id then
        l_flag:=true;
        exit;
      end if;
    end loop;
    if l_flag=false then
      p_lower_periodicities(p_lower_periodicities.count+1):=l_lower_periodicities(i);
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_all_lower_periodicities '||sqlerrm);
  raise;
End;

/*
given a periodicity, gets all the upper periodicities, ie denormalizes
used to fill in denorm_relation in create_calendar_program called recursively
*/
procedure get_all_upper_periodicities(
p_periodicity periodicity_r,
p_calendar calendar_r,
p_upper_periodicities in out nocopy periodicity_tb
) is
--
l_upper_periodicities periodicity_tb;
l_flag boolean;
Begin
  get_parent_periodicities(p_periodicity,p_calendar,l_upper_periodicities);
  for i in 1..l_upper_periodicities.count loop
    get_all_upper_periodicities(l_upper_periodicities(i),p_calendar,p_upper_periodicities);
  end loop;
  for i in 1..l_upper_periodicities.count loop
    --must add only distinct list
    l_flag:=false;
    for j in 1..p_upper_periodicities.count loop
      if p_upper_periodicities(j).periodicity_id=l_upper_periodicities(i).periodicity_id then
        l_flag:=true;
        exit;
      end if;
    end loop;
    if l_flag=false then
      p_upper_periodicities(p_upper_periodicities.count+1):=l_upper_periodicities(i);
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_all_upper_periodicities '||sqlerrm);
  raise;
End;

/*given a calendar name, it reads cal info from olap metadata. NOTE...not all info is read
*/
procedure get_calendar(p_calendar_name varchar2,p_calendar out nocopy calendar_r) is
l_oo bsc_aw_md_wrapper.bsc_olap_object_tb;
l_oor bsc_aw_md_wrapper.bsc_olap_object_relation_tb;
Begin
  bsc_aw_md_api.get_bsc_olap_object(null,null,p_calendar_name,'dimension',l_oo);
  bsc_aw_md_api.get_bsc_olap_object_relation(null,null,null,p_calendar_name,'dimension',l_oor);
  --
  p_calendar.dim_name:=p_calendar_name;
  for i in 1..l_oo.count loop
    if l_oo(i).object=p_calendar_name and l_oo(i).object_type='dimension' then
      p_calendar.calendar_id:=bsc_aw_utility.get_parameter_value(l_oo(i).property1,'calendar',',');
      p_calendar.property:=l_oo(i).property1;
    elsif l_oo(i).object_type='relation' then
      p_calendar.relation_name:=l_oo(i).object;
    elsif l_oo(i).object_type='denorm relation' then
      p_calendar.denorm_relation_name:=l_oo(i).object;
    elsif l_oo(i).object_type='end period relation' then
      p_calendar.end_period_relation_name:=l_oo(i).object;
    elsif l_oo(i).object_type='level name dim' then
      p_calendar.levels_name:=l_oo(i).object;
    elsif l_oo(i).object_type='end period level name dim' then
      p_calendar.end_period_levels_name:=l_oo(i).object;
    --
    elsif l_oo(i).object_type='dimension level' then
      p_calendar.periodicity(p_calendar.periodicity.count+1).dim_name:=l_oo(i).object;
      p_calendar.periodicity(p_calendar.periodicity.count).periodicity_id:=bsc_aw_utility.get_parameter_value(l_oo(i).property1,'periodicity',',');
      p_calendar.periodicity(p_calendar.periodicity.count).db_column_name:=bsc_aw_utility.get_parameter_value(l_oo(i).property1,'db_column_name',',');
    end if;
  end loop;
  --parent child relation
  for i in 1..l_oor.count loop
    if l_oor(i).relation_type='parent level' then
      p_calendar.parent_child(p_calendar.parent_child.count+1).parent_dim_name:=l_oor(i).relation_object;
      p_calendar.parent_child(p_calendar.parent_child.count).parent:=to_number(bsc_aw_utility.get_parameter_value(l_oor(i).property1,'parent periodicity',','));
      p_calendar.parent_child(p_calendar.parent_child.count).child_dim_name:=l_oor(i).object;
      p_calendar.parent_child(p_calendar.parent_child.count).child:=to_number(bsc_aw_utility.get_parameter_value(l_oor(i).property1,'child periodicity',','));
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_calendar '||sqlerrm);
  raise;
End;

/*
given a periodicity, gets all the child periodicities
 main procedure get_all_lower_periodicities
*/
procedure get_child_periodicities(
p_periodicity periodicity_r,
p_calendar calendar_r,
p_lower_periodicities out nocopy periodicity_tb
) is
Begin
  for i in 1..p_calendar.parent_child.count loop
    if p_calendar.parent_child(i).parent=p_periodicity.periodicity_id and p_calendar.parent_child(i).child is not null then
      p_lower_periodicities(p_lower_periodicities.count+1):=get_periodicity_r(p_calendar.parent_child(i).child,p_calendar.periodicity);
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_child_periodicities '||sqlerrm);
  raise;
End;

procedure get_parent_periodicities(
p_periodicity periodicity_r,
p_calendar calendar_r,
p_upper_periodicities out nocopy periodicity_tb
) is
Begin
  for i in 1..p_calendar.parent_child.count loop
    if p_calendar.parent_child(i).child=p_periodicity.periodicity_id and p_calendar.parent_child(i).parent is not null then
      p_upper_periodicities(p_upper_periodicities.count+1):=get_periodicity_r(p_calendar.parent_child(i).parent,p_calendar.periodicity);
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_parent_periodicities '||sqlerrm);
  raise;
End;

/*
given a periodicity_id, get the periodicity_r object
*/
function get_periodicity_r(
p_periodicity_id number,
p_periodicities periodicity_tb
) return periodicity_r is
Begin
  for i in 1..p_periodicities.count loop
    if p_periodicities(i).periodicity_id=p_periodicity_id then
      return p_periodicities(i);
    end if;
  end loop;
  return null;
Exception when others then
  log_n('Exception in get_periodicity_r '||sqlerrm);
  raise;
End;


--given a periodicity_id, what is the name of the corresponding aw dim?
function get_periodicity_dim_name(p_periodicity periodicity_tb, p_periodicity_id number) return varchar2 is
Begin
  for i in 1..p_periodicity.count loop
    if p_periodicity(i).periodicity_id=p_periodicity_id then
      return p_periodicity(i).dim_name;
    end if;
  end loop;
  return null;
Exception when others then
  log_n('Exception in get_periodicity_dim_name '||sqlerrm);
  raise;
End;


/*
this api will normalize a denorm relation of the periodicities
first parse the source periodicities out.
then normalize them
*/
procedure normalize_per_relation(p_calendar in out nocopy calendar_r) is
l_relation bsc_aw_utility.parent_child_tb;
l_source bsc_aw_utility.value_tb;
l_count number;
Begin
  l_count:=0;
  for i in 1..p_calendar.periodicity.count loop
    if p_calendar.periodicity(i).source is not null then
      --we are just reusing bsc_aw_utility.parse_parameter_values
      l_source.delete;
      bsc_aw_utility.parse_parameter_values(p_calendar.periodicity(i).source,',',l_source);
      for j in 1..l_source.count loop
        l_count:=l_count+1;
        l_relation(l_count).parent:=p_calendar.periodicity(i).periodicity_id;
        l_relation(l_count).child:=l_source(j).parameter;
      end loop;
    else
      l_count:=l_count+1;
      l_relation(l_count).parent:=p_calendar.periodicity(i).periodicity_id;
    end if;
  end loop;
  bsc_aw_utility.normalize_denorm_relation(l_relation);
  --l_relation is now normalized
  for i in 1..l_relation.count loop
    p_calendar.parent_child(i).parent:=to_number(l_relation(i).parent);
    p_calendar.parent_child(i).parent_dim_name:=get_periodicity_dim_name(p_calendar.periodicity,
    p_calendar.parent_child(i).parent);
    p_calendar.parent_child(i).child:=to_number(l_relation(i).child);
    p_calendar.parent_child(i).child_dim_name:=get_periodicity_dim_name(p_calendar.periodicity,
    p_calendar.parent_child(i).child);
  end loop;
Exception when others then
  log_n('Exception in normalize_per_relation '||sqlerrm);
  raise;
End;

procedure dmp_calendar(p_calendar calendar_r) is
Begin
  log_n('Calendar Dmp :-');
  log(p_calendar.calendar_id);
  log('Periodicity:-');
  for i in 1..p_calendar.periodicity.count loop
    log(p_calendar.periodicity(i).db_column_name||' perid='||p_calendar.periodicity(i).periodicity_id||' pertype='||
    p_calendar.periodicity(i).periodicity_type||' source='||p_calendar.periodicity(i).source||' '||
    'property='||p_calendar.periodicity(i).property);
  end loop;
  log('Periodicity Relations:-');
  for i in 1..p_calendar.parent_child.count loop
    log(p_calendar.parent_child(i).parent||' '||p_calendar.parent_child(i).child);
  end loop;
Exception when others then
  log_n('Exception in dmp_calendar '||sqlerrm);
  raise;
End;

procedure create_calendar_metadata(p_calendar calendar_r) is
Begin
  bsc_aw_md_api.delete_calendar(p_calendar);
  bsc_aw_md_api.create_calendar(p_calendar);
Exception when others then
  log_n('Exception in create_calendar_metadata '||sqlerrm);
  raise;
End;

procedure get_kpi_for_calendar(p_calendar in out nocopy calendar_r) is
Begin
  bsc_aw_bsc_metadata.get_kpi_for_calendar(p_calendar);
Exception when others then
  log_n('Exception in get_kpi_for_calendar '||sqlerrm);
  raise;
End;

procedure attach_workspace(p_options varchar2) is
l_options varchar2(8000);
Begin
  l_options:='create workspace,'||p_options;
  bsc_aw_management.get_workspace_lock('rw',l_options);
Exception when others then
  log_n('Exception in attach_workspace '||sqlerrm);
  raise;
End;

/*
returns the current year of this calendar
*/
procedure get_calendar_current_year(p_calendar number,p_year out nocopy number) is
--
cursor c1 is select current_year from bsc_sys_calendars_b where calendar_id=p_calendar;
Begin
  open c1;
  fetch c1 into p_year;
  close c1;
Exception when others then
  log_n('Exception in get_calendar_current_year '||sqlerrm);
  raise;
End;

/*
see if the calendar is already loaded in AW
*/
function check_calendar_loaded(p_calendar number) return varchar2 is
--
l_dim varchar2(300);
l_bsc_olap_object bsc_aw_md_wrapper.bsc_olap_object_tb;
Begin
  l_dim:=get_calendar_name(p_calendar);
  bsc_aw_md_api.get_bsc_olap_object(l_dim,'dimension',l_dim,'dimension',l_bsc_olap_object);
  if l_bsc_olap_object(1).operation_flag is not null and l_bsc_olap_object(1).operation_flag='loaded' then
    return 'Y';
  else
    return 'N';
  end if;
Exception when others then
  log_n('Exception in check_calendar_loaded '||sqlerrm);
  raise;
End;

procedure load_calendar(p_calendar number,p_options varchar2) is
Begin
  bsc_aw_utility.g_options.delete;
  bsc_aw_utility.parse_parameter_values(p_options,',',bsc_aw_utility.g_options);
  bsc_aw_utility.open_file('TEST');
  bsc_aw_utility.dmp_g_options(bsc_aw_utility.g_options);
  init_all;
  lock_calendar_objects(p_calendar);
  load_calendar(p_calendar);
  --
  bsc_aw_management.commit_aw;
  commit;
  bsc_aw_management.detach_workspace;
Exception when others then
  bsc_aw_management.detach_workspace;
  log_n('Exception in load_calendar '||sqlerrm);
  raise;
End;

--in bsc_aw_load_kpi, we have a call to this procedure from load_calendar_if_needed
procedure load_calendar(p_calendar number) is
--
--4604538 we select min and max of calendar year
cursor c1 is select min(calendar_year)-1,max(calendar_year)+1 from bsc_db_calendar where calendar_id=p_calendar;
l_min number;
l_max number;
--
l_pgm varchar2(300);
l_dim varchar2(300);
l_bsc_olap_object bsc_aw_md_wrapper.bsc_olap_object_tb;
l_stmt varchar2(3000);
Begin
  --
  open c1;
  fetch c1 into l_min,l_max;
  close c1;
  --
  l_dim:=get_calendar_name(p_calendar);
  --purge_calendar(p_calendar); there is no need to purge the calendar when loading it
  l_bsc_olap_object.delete;
  bsc_aw_md_api.get_bsc_olap_object(null,'dml program',l_dim,'dimension',l_bsc_olap_object);
  for i in 1..l_bsc_olap_object.count loop
    if l_bsc_olap_object(i).olap_object_type='dml program initial load' then
      l_pgm:=l_bsc_olap_object(i).object;
      exit;
    end if;
  end loop;
  l_stmt:='call '||l_pgm||'(''01 01 '||l_min||''',''01 01 '||l_max||''')';
  if g_debug then
    log_n(l_stmt||bsc_aw_utility.get_time);
  end if;
  bsc_aw_dbms_aw.execute(l_stmt);
  if g_debug then
    log('Finished '||bsc_aw_utility.get_time);
  end if;
  --update bsc_olap_object saying operation_flag='loaded'
  bsc_aw_md_api.update_olap_object(l_dim,'dimension',l_dim,'dimension',null,null,'operation_flag','loaded');
Exception when others then
  log_n('Exception in load_calendar '||sqlerrm);
  raise;
End;

/*
clean up
aw time dim level
dim level
dimension
*/
procedure purge_calendar(p_calendar number,p_options varchar2) is
Begin
  purge_calendar(p_calendar);
  bsc_aw_management.commit_aw;
  commit;
Exception when others then
  log_n('Exception in purge_calendar '||sqlerrm);
  raise;
End;

procedure purge_calendar(p_calendar number) is
--
l_dim varchar2(300);
l_olap_object bsc_aw_md_wrapper.bsc_olap_object_tb;
Begin
  l_dim:=get_calendar_name(p_calendar);
  bsc_aw_md_api.get_bsc_olap_object(null,null,l_dim,'dimension',l_olap_object);
  --
  for i in 1..l_olap_object.count loop
    if l_olap_object(i).object_type='aw time dim level' then
      bsc_aw_dbms_aw.execute('maintain '||l_olap_object(i).object||' delete all');
    end if;
  end loop;
  --
  for i in 1..l_olap_object.count loop
    if l_olap_object(i).object_type='dimension level' then
      bsc_aw_dbms_aw.execute('maintain '||l_olap_object(i).object||' delete all');
    end if;
  end loop;
  --update bsc_olap_object saying operation_flag='purged'
  bsc_aw_md_api.update_olap_object(l_dim,'dimension',l_dim,'dimension',null,null,'operation_flag','purged');
Exception when others then
  log_n('Exception in purge_calendar '||sqlerrm);
  raise;
End;

procedure check_calendar_create(
p_calendar calendar_r,
p_recreate out nocopy varchar2,
p_affected_kpi out nocopy dbms_sql.varchar2_table) is
--
Begin
  if bsc_aw_md_api.is_dim_present(p_calendar.dim_name) then
    --check to see if the calendar matches the calendar in the olap metadata
    if bsc_aw_utility.get_parameter_value('RECREATE CALENDAR')='Y' then
      if g_debug then
        log('RECREATE CALENDAR specified. Drop and recreate');
      end if;
      p_recreate:='create all';
      drop_calendar_objects(p_calendar.dim_name,null,p_affected_kpi);
    elsif bsc_aw_utility.get_parameter_value('REIMPLEMENT CALENDAR')='Y' then
      if g_debug then
        log('REIMPLEMENT CALENDAR specified. Merge create all');
      end if;
      p_recreate:='create all';
    elsif bsc_aw_utility.get_parameter_value('RECREATE PROGRAM')='Y' then
      if g_debug then
        log('RECREATE PROGRAM specified');
      end if;
      p_recreate:='create program';
    else
      correct_calendar(p_calendar,p_recreate);
    end if;
  else --cal not present
    if g_debug then
      log('New Calendar '||p_calendar.dim_name);
    end if;
    p_recreate:='create all';
  end if;
  if g_debug then
    log('For calendar '||p_calendar.dim_name||', recreate option='||p_recreate);
  end if;
Exception when others then
  log_n('Exception in check_calendar_create '||sqlerrm);
  raise;
End;

/*
check to see if the olap metadata and the current calendar metadata are in sync
right now, see if there are new periodicities or dropped periodicities
*/
procedure correct_calendar(p_calendar calendar_r,p_recreate out nocopy varchar2) is
l_oo bsc_aw_md_wrapper.bsc_olap_object_tb;
l_oor bsc_aw_md_wrapper.bsc_olap_object_relation_tb;
l_periodicities dbms_sql.varchar2_table;
l_olap_periodicities dbms_sql.varchar2_table;
l_level_name_dim varchar(200);
l_olap_periodicity_dim dbms_sql.varchar2_table;
l_pc parent_child_tb;
--
Begin
  bsc_aw_md_api.get_bsc_olap_object(null,null,p_calendar.dim_name,'dimension',l_oo);
  bsc_aw_md_api.get_bsc_olap_object_relation(null,null,null,p_calendar.dim_name,'dimension',l_oor);
  if l_oo.count=0 then
    return;
  end if;
  for i in 1..p_calendar.periodicity.count loop
    l_periodicities(l_periodicities.count+1):=p_calendar.periodicity(i).periodicity_id;
  end loop;
  for i in 1..l_oo.count loop
    if l_oo(i).object_type='dimension level' then
      l_olap_periodicities(l_olap_periodicities.count+1):=bsc_aw_utility.get_parameter_value(l_oo(i).property1,'periodicity',',');
      l_olap_periodicity_dim(l_olap_periodicity_dim.count+1):=l_oo(i).object;
    elsif l_oo(i).object_type='level name dim' then
      l_level_name_dim:=l_oo(i).object;
    end if;
  end loop;
  --level name dim
  for i in 1..l_olap_periodicities.count loop
    if bsc_aw_utility.in_array(l_periodicities,l_olap_periodicities(i))=false then
      p_recreate:='create all';
      for j in 1..l_oor.count loop
        if l_oor(j).relation_type='parent level' then
          if l_oor(j).object=l_olap_periodicity_dim(i) or l_oor(j).relation_object=l_olap_periodicity_dim(i) then
            bsc_aw_dbms_aw.execute('maintain '||l_level_name_dim||' delete '''||l_oor(j).relation_object||'.'||l_oor(j).object||'''');
          end if;
        end if;
      end loop;
    end if;
  end loop;
  --see if there are new periodicities we need to add
  if p_recreate is null then
    for i in 1..l_periodicities.count loop
      if bsc_aw_utility.in_array(l_olap_periodicities,l_periodicities(i))=false then
        p_recreate:='create all';
        exit;
      end if;
    end loop;
  end if;
  --see if any existing relation changed. 4602290
  if p_recreate is null then
    l_pc.delete;
    for i in 1..l_oor.count loop
      if l_oor(i).relation_type='parent level' then
        l_pc(l_pc.count+1).parent_dim_name:=l_oor(i).relation_object;
        l_pc(l_pc.count).child_dim_name:=l_oor(i).object;
      end if;
    end loop;
    if compare_pc_relations(p_calendar.parent_child,l_pc)<>0 then
      if g_debug then
        log('Parent child relation diff between old and new');
      end if;
      p_recreate:='create all';
    end if;
  end if;
  --recreate the program
  if p_recreate is null then
    p_recreate:='create program';
  end if;
Exception when others then
  log_n('Exception in correct_calendar '||sqlerrm);
  raise;
End;

function compare_pc_relations(p_pc_1 parent_child_tb,p_pc_2 parent_child_tb) return number is
--
l_pc_1 bsc_aw_utility.parent_child_tb;
l_pc_2 bsc_aw_utility.parent_child_tb;
Begin
  for i in 1..p_pc_1.count loop
    l_pc_1(i).parent:=p_pc_1(i).parent_dim_name;
    l_pc_1(i).child:=p_pc_1(i).child_dim_name;
  end loop;
  for i in 1..p_pc_2.count loop
    l_pc_2(i).parent:=p_pc_2(i).parent_dim_name;
    l_pc_2(i).child:=p_pc_2(i).child_dim_name;
  end loop;
  return bsc_aw_utility.compare_pc_relations(l_pc_1,l_pc_2);
Exception when others then
  log_n('Exception in compare_pc_relations '||sqlerrm);
  raise;
End;

--p_object_type is null or all or dml program
procedure drop_calendar_objects(p_calendar_name varchar2,p_object_type varchar2,p_affected_kpi out nocopy dbms_sql.varchar2_table) is
--
l_bsc_olap_object bsc_aw_md_wrapper.bsc_olap_object_tb;
l_flag dbms_sql.varchar2_table;
Begin
  --first drop all dependent kpi ... if needed
  if p_object_type is null or p_object_type='all' then
    bsc_aw_md_api.get_kpi_for_dim(p_calendar_name,p_affected_kpi);
    for i in 1..p_affected_kpi.count loop
      bsc_aw_adapter_kpi.drop_kpi_objects(p_affected_kpi(i));
    end loop;
  end if;
  bsc_aw_md_api.get_bsc_olap_object(null,p_object_type,p_calendar_name,'dimension',l_bsc_olap_object);
  --order : drop all relations, variables etc, drop concat dim, then all others
  for i in 1..l_bsc_olap_object.count loop
    l_flag(i):='N';
  end loop;
  if l_bsc_olap_object.count>0 then
    for i in 1..l_bsc_olap_object.count loop
      if l_flag(i)='N' and (l_bsc_olap_object(i).olap_object_type ='relation' or l_bsc_olap_object(i).olap_object_type ='variable') then
        bsc_aw_utility.delete_aw_object(l_bsc_olap_object(i).olap_object);
        l_flag(i):='Y';
      end if;
    end loop;
    for i in 1..l_bsc_olap_object.count loop
      if l_flag(i)='N' and l_bsc_olap_object(i).olap_object_type='concat dimension' then
        bsc_aw_utility.delete_aw_object(l_bsc_olap_object(i).olap_object);
        l_flag(i):='Y';
      end if;
    end loop;
    for i in 1..l_bsc_olap_object.count loop
      if l_flag(i)='N' and l_bsc_olap_object(i).olap_object_type='dimension' then
        bsc_aw_utility.delete_aw_object(l_bsc_olap_object(i).olap_object);
        l_flag(i):='Y';
      end if;
    end loop;
    --all other objects
    for i in 1..l_bsc_olap_object.count loop
      if l_flag(i)='N' then
        bsc_aw_utility.delete_aw_object(l_bsc_olap_object(i).olap_object);
        l_flag(i):='Y';
      end if;
    end loop;
  end if;
Exception when others then
  log_n('Exception in drop_calendar_objects '||sqlerrm);
  raise;
End;

function get_calendar_name(p_calendar number) return varchar2 is
Begin
  return 'bsc_calendar_'||p_calendar;
Exception when others then
  log_n('Exception in get_calendar_name '||sqlerrm);
  raise;
End;

/*
this procedure finds out the missing levels. it also marks lowest level.
input : periodicity dims
output : missing periodicity dim added.
also : lowest periodicity marked

logic:
for each level, see if a child level is present. if yes, this is not a hanging level
if no child, 2 possibilities
1. lowest level
2. hanging level : must find missing level
find out like this: drill down and see if at any time, a periodicity of the kpi is showing up. if yes, stop.
if no, lowest level
II
then do the same for parent levels
for each child, see if any immediate parent is present. if no, either top level or missing levels
*/
procedure get_missing_periodicity(
p_calendar_dim varchar2,
p_periodicity_dim in out nocopy dbms_sql.varchar2_table,
p_lowest_level out nocopy dbms_sql.varchar2_table
) is
--
l_missing_levels dbms_sql.varchar2_table;
l_found boolean;
l_parent_child_calendar parent_child_tb;
Begin
  --get calendar properties
  get_calendar_parent_child(p_calendar_dim,l_parent_child_calendar);
  --see if a child level is present for the kpi periodicities
  for i in 1..p_periodicity_dim.count loop
    p_lowest_level(i):='N';
    if is_child_present(p_periodicity_dim(i),p_periodicity_dim,l_parent_child_calendar)=false then
      --lowest level or hanging level
      --drill down hier. if any of the children is present in p_periodicity_dim, this is hanging level
      l_missing_levels.delete;
      l_found:=false;
      get_missing_level_down(p_periodicity_dim(i),p_periodicity_dim,l_parent_child_calendar,l_missing_levels,l_missing_levels,l_found); --false is starting seed value
      if l_found and l_missing_levels.count>0 then
        for j in 1..l_missing_levels.count loop
          if bsc_aw_utility.in_array(p_periodicity_dim,l_missing_levels(j))=false then
            p_periodicity_dim(p_periodicity_dim.count+1):=l_missing_levels(j);
            p_lowest_level(p_periodicity_dim.count):='N';
          end if;
        end loop;
      else
        p_lowest_level(i):='Y';
      end if;
    end if;
  end loop;
  --
  for i in 1..p_periodicity_dim.count loop
    if is_parent_present(p_periodicity_dim(i),p_periodicity_dim,l_parent_child_calendar)=false then
      --lowest level or hanging level
      --drill down hier. if any of the children is present in p_periodicity_dim, this is hanging level
      l_missing_levels.delete;
      l_found:=false;
      get_missing_level_up(p_periodicity_dim(i),p_periodicity_dim,l_parent_child_calendar,l_missing_levels,l_missing_levels,l_found); --false is starting seed value
      if l_found and l_missing_levels.count>0 then
        for j in 1..l_missing_levels.count loop
          if bsc_aw_utility.in_array(p_periodicity_dim,l_missing_levels(j))=false then
            p_periodicity_dim(p_periodicity_dim.count+1):=l_missing_levels(j);
            p_lowest_level(p_periodicity_dim.count):='N';
          end if;
        end loop;
      end if;
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_missing_periodicity '||sqlerrm);
  raise;
End;

function is_child_present(
p_parent varchar2,
p_periodicity_dim dbms_sql.varchar2_table,
p_parent_child parent_child_tb) return boolean is
Begin
  for i in 1..p_parent_child.count loop
    if p_parent_child(i).parent_dim_name=p_parent and bsc_aw_utility.in_array(p_periodicity_dim,p_parent_child(i).child_dim_name) then
      return true;
    end if;
  end loop;
  return false;
Exception when others then
  log_n('Exception in is_child_present '||sqlerrm);
  raise;
End;

function is_parent_present(
p_child varchar2,
p_periodicity_dim dbms_sql.varchar2_table,
p_parent_child parent_child_tb) return boolean is
Begin
  for i in 1..p_parent_child.count loop
    if p_parent_child(i).child_dim_name=p_child and bsc_aw_utility.in_array(p_periodicity_dim,p_parent_child(i).parent_dim_name) then
      return true;
    end if;
  end loop;
  return false;
Exception when others then
  log_n('Exception in is_parent_present '||sqlerrm);
  raise;
End;

--recursively called
procedure get_missing_level_down(
p_parent varchar2,
p_periodicity_dim dbms_sql.varchar2_table,
p_parent_child parent_child_tb,
p_missing_levels_in dbms_sql.varchar2_table,
p_missing_levels_out out nocopy dbms_sql.varchar2_table,
p_found in out nocopy boolean --indicates if child is found and its time to stop
) is
--
l_missing_levels dbms_sql.varchar2_table;
Begin
  if p_found=false then
    if is_child_present(p_parent,p_periodicity_dim,p_parent_child) then
      p_missing_levels_out:=p_missing_levels_in;
      p_found:=true;
    else
      for i in 1..p_parent_child.count loop
        if p_parent_child(i).parent_dim_name=p_parent then
          l_missing_levels.delete;
          l_missing_levels:=p_missing_levels_in;
          l_missing_levels(l_missing_levels.count+1):=p_parent_child(i).child_dim_name;
          get_missing_level_down(p_parent_child(i).child_dim_name,p_periodicity_dim,p_parent_child,l_missing_levels,p_missing_levels_out,p_found);
          if p_found then --stop
            exit;
          end if;
        end if;
      end loop;
    end if;
  end if;
Exception when others then
  log_n('Exception in get_missing_level_down '||sqlerrm);
  raise;
End;

--recursively called
procedure get_missing_level_up(
p_child varchar2,
p_periodicity_dim dbms_sql.varchar2_table,
p_parent_child parent_child_tb,
p_missing_levels_in dbms_sql.varchar2_table,
p_missing_levels_out out nocopy dbms_sql.varchar2_table,
p_found in out nocopy boolean --indicates if child is found and its time to stop
) is
--
l_missing_levels dbms_sql.varchar2_table;
Begin
  if p_found=false then
    if is_parent_present(p_child,p_periodicity_dim,p_parent_child) then
      p_missing_levels_out:=p_missing_levels_in;
      p_found:=true;
    else
      for i in 1..p_parent_child.count loop
        if p_parent_child(i).child_dim_name=p_child then
          l_missing_levels.delete;
          l_missing_levels:=p_missing_levels_in;
          l_missing_levels(l_missing_levels.count+1):=p_parent_child(i).parent_dim_name;
          get_missing_level_up(p_parent_child(i).parent_dim_name,p_periodicity_dim,p_parent_child,l_missing_levels,p_missing_levels_out,p_found);
          if p_found then --stop
            exit;
          end if;
        end if;
      end loop;
    end if;
  end if;
Exception when others then
  log_n('Exception in get_missing_level_up '||sqlerrm);
  raise;
End;

procedure get_calendar_parent_child(p_calendar_dim varchar2,p_parent_child out nocopy parent_child_tb) is
l_calendar calendar_r;
Begin
  get_calendar(p_calendar_dim,l_calendar);
  for i in 1..l_calendar.parent_child.count loop
    p_parent_child(p_parent_child.count+1):=l_calendar.parent_child(i);
  end loop;
Exception when others then
  log_n('Exception in get_calendar_parent_child '||sqlerrm);
  raise;
End;

procedure get_calendar_periodicities(p_calendar_dim varchar2,p_periodicity out nocopy periodicity_tb) is
l_calendar calendar_r;
Begin
  get_calendar(p_calendar_dim,l_calendar);
  for i in 1..l_calendar.periodicity.count loop
    p_periodicity(p_periodicity.count+1):=l_calendar.periodicity(i);
  end loop;
Exception when others then
  log_n('Exception in get_calendar_periodicities '||sqlerrm);
  raise;
End;

procedure lock_calendar_objects(p_calendar number) is
--
l_lock_objects dbms_sql.varchar2_table;
Begin
  get_calendar_objects_to_lock(p_calendar,l_lock_objects);
  bsc_aw_management.get_workspace_lock(l_lock_objects,null);
Exception when others then
  log_n('Exception in lock_calendar_objects '||sqlerrm);
  raise;
End;

/*
in 10g, when calendar is loaded, we want to lock only the calendar objects, not get an exclusive lock on the system
we cannot lock concat dim. got error
acquire BSC_CCDIM_100_101_102_103  (S: 04/13/2005 17:34:10
Exception in execute acquire BSC_CCDIM_100_101_102_103 ORA-37018:Multiwriter operations are not supported for object BSC_AW!BSC_CCDIM_100_101_102_103.
--
we have to acquire locks and update in a certain order . else we get
ORA-37023: (XSMLTUPD01) Object workspace object cannot be updated without dimension workspace object.
we cannot update a relation before a dim. so when we get locks, we first get dim, then relations, then variables
*/
procedure get_calendar_objects_to_lock(p_calendar number,p_lock_objects out nocopy dbms_sql.varchar2_table) is
l_dim varchar2(300);
l_bsc_olap_object bsc_aw_md_wrapper.bsc_olap_object_tb;
l_objects dbms_sql.varchar2_table;
Begin
  l_dim:=get_calendar_name(p_calendar);
  bsc_aw_md_api.get_bsc_olap_object(null,null,l_dim,'dimension',l_bsc_olap_object);
  for i in 1..l_bsc_olap_object.count loop
    if l_bsc_olap_object(i).olap_object_type is not null and l_bsc_olap_object(i).olap_object_type='dimension' then
      l_objects(l_objects.count+1):=l_bsc_olap_object(i).olap_object;
    end if;
  end loop;
  for i in 1..l_bsc_olap_object.count loop
    if l_bsc_olap_object(i).olap_object_type is not null and l_bsc_olap_object(i).olap_object_type='relation' then
      l_objects(l_objects.count+1):=l_bsc_olap_object(i).olap_object;
    end if;
  end loop;
  for i in 1..l_bsc_olap_object.count loop
    if l_bsc_olap_object(i).olap_object_type is not null and l_bsc_olap_object(i).olap_object_type='variable' then
      l_objects(l_objects.count+1):=l_bsc_olap_object(i).olap_object;
    end if;
  end loop;
  --there are no limit cubes here like dim.?
  --
  for i in 1..l_objects.count loop
    if bsc_aw_utility.in_array(p_lock_objects,l_objects(i))=false then
      p_lock_objects(p_lock_objects.count+1):=l_objects(i);
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_calendar_objects_to_lock '||sqlerrm);
  raise;
End;

/*upgrade
we start from latest version and move downwards. actions already done are marked off as false
if p_new_version>=2 then
  if action('1') then
    ...
    action('1')=false
  end if;
  if action('2') then
  ...
...
end if;
if p_new_version>=1 then
  if action('2') then
    ...
    action('2')=false
  end if;
  if action('3') then
    ...
end if;*/
procedure upgrade(p_new_version number,p_old_version number) is
l_action bsc_aw_utility.boolean_table;
Begin
  if g_debug then
    log('Calendar upgrade New='||p_new_version||', Old='||p_old_version||bsc_aw_utility.get_time);
  end if;
  init_all;
  if p_new_version>p_old_version then
    /*init all actions */
    l_action('reimplement calendar'):=true;
    /*version by version inc upgrade */
    if p_old_version<3 then
      if l_action('reimplement calendar') then
        reimplement_all_calendars;
        l_action('reimplement calendar'):=false;
      end if;
    end if;
  end if;
  if g_debug then
    log('End upgrade calendar '||bsc_aw_utility.get_time);
  end if;
Exception when others then
  log_n('Exception in upgrade '||sqlerrm);
  raise;
End;

procedure reimplement_all_calendars is
l_oo bsc_aw_md_wrapper.bsc_olap_object_tb;
l_calendar dbms_sql.number_table;
l_year number;
l_cal_id number;
Begin
  bsc_aw_md_api.get_bsc_olap_object(null,'dimension',null,'dimension',l_oo);
  for i in 1..l_oo.count loop
    if instr(l_oo(i).property1,'dimension type=time')>0 then
      /*5017796. see if this calendar is still a valid implemented calendar in BSC */
      l_cal_id:=null;
      l_year:=null;
      l_cal_id:=to_number(bsc_aw_utility.get_parameter_value(l_oo(i).property1,'calendar',','));
      get_calendar_current_year(l_cal_id,l_year);
      if l_year is not null then
        bsc_aw_utility.merge_value(l_calendar,l_cal_id);
      end if;
    end if;
  end loop;
  bsc_aw_utility.add_option('REIMPLEMENT CALENDAR',null,',');
  for i in 1..l_calendar.count loop
    reimplement_calendar(l_calendar(i));
  end loop;
Exception when others then
  log_n('Exception in reimplement_all_calendars '||sqlerrm);
  raise;
End;

procedure reimplement_calendar(p_calendar_id number) is
l_affected_kpi dbms_sql.varchar2_table;
l_dim varchar2(100);
Begin
  if g_debug then
    log('Reimplement calendar '||p_calendar_id||bsc_aw_utility.get_time);
  end if;
  create_calendar(p_calendar_id,l_affected_kpi);
  l_dim:=get_calendar_name(p_calendar_id);
  bsc_aw_md_api.update_olap_object(l_dim,'dimension',l_dim,'dimension',null,null,'operation_flag','empty');
Exception when others then
  log_n('Exception in reimplement_all_calendars '||sqlerrm);
  raise;
End;

------------------------------
procedure init_all is
Begin
  if g_init is null or g_init=false then
    g_init:=true;
    /*5258418 we need to see if the temp tables and perm tables are created. serialize entry here */
    bsc_aw_utility.get_db_lock('bsc_aw_table_create_lock');
    bsc_aw_utility.create_temp_tables;
    bsc_aw_utility.create_perm_tables;
    bsc_aw_utility.release_db_lock('bsc_aw_table_create_lock');
    /* */
    if bsc_aw_utility.get_parameter_value(bsc_aw_utility.g_options,'DEBUG LOG')='Y'
    or bsc_aw_utility.g_log_level>=FND_LOG.G_CURRENT_RUNTIME_LEVEL then
      g_debug:=true;
    else
      g_debug:=false;
    end if;
    bsc_aw_utility.init_all(g_debug);
    bsc_aw_dbms_aw.init_all;
    bsc_aw_md_api.init_all;
    bsc_aw_md_wrapper.init_all;
    bsc_aw_bsc_metadata.init_all;
    bsc_metadata.init_all;
    bsc_aw_management.init_all;
  end if;
Exception when others then
  log_n('Exception in init_all '||sqlerrm);
  raise;
End;

procedure log(p_message varchar2) is
Begin
  bsc_aw_utility.log(p_message);
Exception when others then
  null;
End;

procedure log_n(p_message varchar2) is
Begin
  log('  ');
  log(p_message);
Exception when others then
  null;
End;

END BSC_AW_CALENDAR;

/
