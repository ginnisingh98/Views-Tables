--------------------------------------------------------
--  DDL for Package Body BSC_DIMENSION_KEYS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_DIMENSION_KEYS_PKG" AS
/* $Header: BSCDKEYB.pls 120.0 2005/09/15 23:40 appldev noship $ */


g_keys_table  varchar2(100);
g_session_id  number;
-- Non XTD
g_periodicities BIS_PMV_PAGE_PARAMETER_TBL;
-- XTD specific
g_xtd_type varchar2(100);
g_xtd_periodicity number;
g_xtd_date  dbms_sql.varchar2_table;
g_xtd_period  dbms_sql.number_table;
g_xtd_year  dbms_sql.number_table;

g_dimensions BIS_PMV_PAGE_PARAMETER_TBL;
g_measures BIS_PMV_PAGE_PARAMETER_TBL;
g_user_periods TabTimePeriods;

PROCEDURE initialize_parameters(
p_parameters IN BIS_PMV_PAGE_PARAMETER_TBL) IS
BEGIN
  g_periodicities := BIS_PMV_PAGE_PARAMETER_TBL();
  g_periodicities.delete;
  g_dimensions := BIS_PMV_PAGE_PARAMETER_TBL();
  g_dimensions.delete;
  g_measures := BIS_PMV_PAGE_PARAMETER_TBL();
  g_measures.delete;

  FOR i IN 1..p_parameters.count LOOP
    if p_parameters(i).Parameter_name='PERIODICITY' then
      --dbms_output.put_line('g_periodicities:start');
      g_periodicities.extend;
      g_periodicities(g_periodicities.last):=p_parameters(i);
      --dbms_output.put_line('g_periodicities:added'||g_periodicities.last);
    elsif p_parameters(i).Parameter_name='KEYS TABLE' then
      --dbms_output.put_line('keys table');
      g_keys_table := p_parameters(i).parameter_value;
      --dbms_output.put_line('g_keys_table added:'||g_keys_table);
    elsif p_parameters(i).Parameter_name='SESSION ID' then
      --dbms_output.put_line('g_session_id:start');
      g_session_id := nvl(p_parameters(i).parameter_id, to_number(p_parameters(i).parameter_value));
      --dbms_output.put_line('g_session_id:'||g_session_id);
    elsif p_parameters(i).Parameter_name='XTD DATE' then
      --dbms_output.put_line('g_xtd_date start');
      g_xtd_date(g_xtd_date.count+1) := p_parameters(i).parameter_value;
      --dbms_output.put_line('g_xtd_date:'||g_xtd_date(g_xtd_date.count));
    elsif p_parameters(i).Parameter_name='XTD PERIOD' then
      --dbms_output.put_line('g_xtd_period start');
      g_xtd_period(g_xtd_period.count+1) := nvl(p_parameters(i).parameter_id, p_parameters(i).parameter_value);
      --dbms_output.put_line('g_xtd_period end');
	elsif p_parameters(i).Parameter_name='XTD YEAR' then
	  --dbms_output.put_line('g_xtd_year start');
      g_xtd_year(g_xtd_year.count+1) := nvl(p_parameters(i).parameter_id, p_parameters(i).parameter_value);
      --dbms_output.put_line('g_xtd_year end');
    elsif p_parameters(i).Parameter_name='XTD TYPE' then
      --dbms_output.put_line('g_xtd_type start');
      g_xtd_type := p_parameters(i).parameter_value;
      --dbms_output.put_line('g_xtd_type end');
    elsif p_parameters(i).Parameter_name='XTD PERIODICITY' then
      --dbms_output.put_line('g_xtd_periodicity start');
      g_xtd_periodicity := nvl(p_parameters(i).parameter_id, p_parameters(i).parameter_value);
      --dbms_output.put_line('g_xtd_periodicity end');
    elsif p_parameters(i).Parameter_name='DIMENSION'then
      --dbms_output.put_line('Dimension start');
      g_dimensions.extend;
      g_dimensions(g_dimensions.last):=p_parameters(i);
      --dbms_output.put_line('Dimension end '||g_dimensions.last);
    elsif p_parameters(i).Parameter_name='MEASURE'then
      --dbms_output.put_line('Measure start');
      g_measures.extend;
      g_measures(g_measures.last):=p_parameters(i);
      --dbms_output.put_line('Measure end '||g_measures.last);
    end if;
  END LOOP;
  exception when others then
    --dbms_output.put_line('Exception in initialize_parameters:'||sqlerrm);
    raise;
END;

Procedure populate_xtd_keys(
p_kpi varchar2,
p_dim_set varchar2,
p_option_string varchar2,
p_error_message OUT nocopy varchar2) is
begin
  for i in 1..g_xtd_date.count loop
    bsc_bsc_xtd_pkg.populate_rpt_keys(
                                g_keys_table,
                                g_session_id,
                                p_kpi,
                                g_xtd_date(i),
                                g_xtd_period(i),
                                g_xtd_year(i),
                                g_xtd_periodicity,
                                g_xtd_type,
                                p_option_string,
                                p_error_message);
  end loop;
  --dbms_output.put_line('Completed populate_xtd_keys:'||p_error_message);
  exception when others then
    --dbms_output.put_line('Exception in populate_xtd_keys:'||sqlerrm);
    raise;
end;

function get_periodicity_info(p_periodicity_id number,
  p_calendar_id OUT NOCOPY NUMBER,
  p_custom OUT NOCOPY number,
  p_db_column_name OUT NOCOPY VARCHAR2,
  p_error_message OUT NOCOPY VARCHAR2)
  return boolean is
cursor cType IS
select calendar_id, custom_code, db_column_name from bsc_sys_periodicities
where periodicity_id=p_periodicity_id
-- ignore these type of periodicities, they are std periodicites but dont have a db_column_name
and periodicity_type not in (11,12);
begin
  open cType;
  fetch cType into p_calendar_id, p_custom, p_db_column_name;
  close cType;
  if (p_custom is null or p_db_column_name is null) then
    p_error_message := 'Invalid Periodicity id '||p_periodicity_id;
    return false;
  end if;
  return true;
  exception when others then
    --dbms_output.put_line('Exception in get_periodicity_info:'||sqlerrm);
    raise;
end;

procedure split_string (p_string varchar2, p_separator varchar2, p_first out nocopy varchar2, p_second out nocopy varchar2) is
l_position number;
begin
  p_first := p_string;
  p_second := p_string;
  l_position := instr(p_string, p_separator);
  if (l_position > 0) then
    p_first := substr(p_string, 1, l_position-1);
    if instr(p_string, p_separator, l_position+length(p_separator)+1)>0 then
      raise reporting_keys_exception;
    end if;
    p_second := substr(p_string, l_position+length(p_separator), length(p_string));
  else  -- single value like 100.2004 with no TO
    p_first := p_string;
    p_second := p_string;
  end if;
  exception when others then
    --dbms_output.put_line('Exception in split_string:'||sqlerrm);
    raise;
end;

function get_parsed_periodicities(p_index number) return TimePeriod IS
l_value varchar2(1000);
l_from varchar2(1000);
l_to varchar2(1000);
l_to_position number;
l_time_period TimePeriod;
l_start_period varchar2(100);
l_start_year varchar2(100);
l_end_period varchar2(100);
l_end_year varchar2(100);

begin
  l_value := g_periodicities(p_index).parameter_value;
  split_string(l_value, ' TO ', l_from, l_to);
  split_string(l_from, '.', l_start_period, l_start_year);
  split_string(l_to, '.', l_end_period, l_end_year);
  --dbms_output.put_line('start period='||l_start_period||', start_year='||l_start_year||', end period='||l_end_period||', end year='||l_end_year);
  l_time_period.start_period := to_number(l_start_period);
  l_time_period.start_year := to_number(l_start_year);
  l_time_period.end_period := to_number(l_end_period);
  l_time_period.end_year := to_number(l_end_year);
  return l_time_period;
  exception when others then
    --dbms_output.put_line('Exception in get_parsed_periodicities:'||sqlerrm);
    raise;
end;

Function parse_periods return TabTimePeriods is

l_period TimePeriod;

l_create_new_period boolean;
l_periods TabTimePeriods;

begin
  for i in 1..g_periodicities.count loop
    l_periods (l_periods .count+1) := get_parsed_periodicities(i);
  end loop;
  return l_periods;
  exception when others then
    --dbms_output.put_line('Exception in parse_periods:'||sqlerrm);
    raise;
end;

Procedure populate_nonxtd_keys(
p_kpi varchar2,
p_dim_set varchar2,
p_option_string varchar2,
p_error_message OUT nocopy varchar2) is
l_periodicity_id number;
l_custom number;
l_db_column_name varchar2(100);
l_calendar_id number;

l_period_start_period dbms_sql.number_table;
l_period_start_year dbms_sql.number_table;
l_period_end_period dbms_sql.number_table;
l_period_end_year dbms_sql.number_table;
l_stmt varchar2(1000);

begin
  l_periodicity_id := g_periodicities(1).parameter_id;
  if (get_periodicity_info(l_periodicity_id, l_calendar_id, l_custom, l_db_column_name, p_error_message)=false) then
    --dbms_output.put_line('get_periodicity_info returned false : '||p_error_message);
    raise reporting_keys_exception;
  end if;
  g_user_periods := parse_periods;
  for i in 1..g_user_periods.count loop
    l_period_start_period(i) := g_user_periods(i).start_period;
	l_period_start_year(i) := g_user_periods(i).start_year;
    l_period_end_period(i) := g_user_periods(i).end_period;
	l_period_end_year(i) := g_user_periods(i).end_year;
  end loop;

  if (l_custom=0) then -- std periodicites, goto db calendar
    l_stmt := 'INSERT into '||g_keys_table||'(
               SESSION_ID,
               REPORT_DATE,
               XTD_PERIOD,
               XTD_YEAR,
               XTD_PERIODICITY,
               PERIOD,
               YEAR,
               PERIOD_TYPE_ID,
               PERIODICITY_ID,
               PERIOD_FLAG,
               DAY_COUNT,
               ROLLING_FLAG,
               LAST_UPDATE_DATE)
              select
                :1,
                null,
                null,
                null,
                null, '||
                l_db_column_name||
                ', year,
                null,
                :2,
                null,
                null,
                :3,
                sysdate
              from bsc_db_calendar
             where year between :4 and :5
               and '||l_db_column_name||' between :6 and :7
               and calendar_id = :8';
    forall i in 1..g_user_periods.count
      execute immediate l_stmt using g_session_id, l_periodicity_id, 'N',
      l_period_start_year(i), l_period_end_year(i), l_period_start_period(i),
      l_period_end_period(i), l_calendar_id;
  else -- custom periodicitie, goto bsc_sys_periods
      l_stmt := 'INSERT into '||g_keys_table||'(
               SESSION_ID,
               REPORT_DATE,
               XTD_PERIOD,
               XTD_YEAR,
               XTD_PERIODICITY,
               PERIOD,
               YEAR,
               PERIOD_TYPE_ID,
               PERIODICITY_ID,
               PERIOD_FLAG,
               DAY_COUNT,
               ROLLING_FLAG,
               LAST_UPDATE_DATE)
              select
                :1,
                null,
                period_id,
                year,
                :2,
                period_id,
                year,
                null,
                :3,
                 0,
                 null,
                :4,
                sysdate
              from bsc_sys_periods
             where
              year between :5 and :6
               and period_id between :7 and :8
               and periodicity_id = :9';
    forall i in 1..g_user_periods.count
      execute immediate l_stmt using g_session_id, l_periodicity_id, l_periodicity_id, 'N',
      l_period_start_year(i), l_period_end_year(i), l_period_start_period(i), l_period_end_period(i), l_periodicity_id;
  end if;
  -- mark the last period as 1
  execute immediate 'update '||g_keys_table||' set period_flag=1 where period = (select max(period) from '||g_keys_table||' group by periodicity_id)';
  exception when others then
    --dbms_output.put_line('Exception in populate_nonxtd_keys:'||sqlerrm);
    raise;
end;

function is_measure_short_name(p_measure varchar2) return boolean is
l_count number;
begin
  select count(1) into l_count from bsc_sys_measures where short_name=p_measure;
  if (l_count > 0) then
    return true;
  end if;
  return false;
end;

Procedure Limit_AW(p_kpi varchar2, p_dim_set number) is

l_parameters BIS_PMV_PAGE_PARAMETER_TBL;
l_parameter BIS_PMV_PAGE_PARAMETER_REC;
b_pmv_measure boolean;
begin
  l_parameters := BIS_PMV_PAGE_PARAMETER_TBL();
  -- rearrange data for AW call
  --dbms_output.put_line('going to check dimensions');
  --dbms_output.put_line('count='||g_dimensions.count );
  for i in 1..g_dimensions.count loop
    --dbms_output.put_line('0');
    l_parameter := g_dimensions(i);
    l_parameters.extend;
    --dbms_output.put_line('1 '||g_dimensions(i).dimension);
    l_parameter.parameter_name := g_dimensions(i).dimension;
    --dbms_output.put_line('2');
    l_parameter.parameter_id :=  g_dimensions(i).parameter_id;
    --dbms_output.put_line('3');
    l_parameter.parameter_value := g_dimensions(i).parameter_value;
    --dbms_output.put_line('4');
    l_parameter.dimension := g_dimensions(i).parameter_name;--'DIMENSION'
    l_parameters(l_parameters.last) := l_parameter;
  end loop;
   --dbms_output.put_line('going to check measures');
  for i in 1..g_measures.count loop
    l_parameter := g_measures(i);
    l_parameters.extend;
    if (i=1) then
      b_pmv_measure := is_measure_short_name(g_measures(i).parameter_value);
    end if;
    l_parameter.parameter_name := g_measures(i).parameter_value;
    l_parameter.parameter_id :=  g_measures(i).parameter_id;
    l_parameter.parameter_value := g_measures(i).parameter_value;
    l_parameter.dimension := g_measures(i).parameter_name;--'MEASURE'
    l_parameters(l_parameters.last) := l_parameter;
  end loop;
  -- xtd parameters
  if (g_xtd_type is not null) then -- XTD query
    l_parameters.extend;
    l_parameter.parameter_name := g_keys_table;
    l_parameter.parameter_id :=  null;
    l_parameter.parameter_value := null;
    l_parameter.dimension := 'XTD KEYS TABLE';
    l_parameters(l_parameters.last) := l_parameter;
    l_parameters.extend;
    l_parameter.parameter_name := g_session_id;
    l_parameter.parameter_id :=  null;
    l_parameter.parameter_value := null;
    l_parameter.dimension := 'XTD SESSION ID';
    l_parameters(l_parameters.last) := l_parameter;
    for i in 1..g_xtd_date.count loop
      l_parameters.extend;
      l_parameter.parameter_name := g_xtd_date(i);
      l_parameter.parameter_id :=  null;
      l_parameter.parameter_value := null;
      l_parameter.dimension := 'XTD REPORT DATE';
      l_parameters(l_parameters.last) := l_parameter;
    end loop;
  else-- non XTD query
    for i in 1..g_periodicities.count loop
      l_parameters.extend;
      l_parameter.parameter_name := g_periodicities(i).parameter_id;
      l_parameter.parameter_id :=  null;
      l_parameter.parameter_value := g_periodicities(i).parameter_value;
      l_parameter.dimension := g_periodicities(i).parameter_value;
      l_parameters(l_parameters.last) := l_parameter;
    end loop;
  end if;
  --dbms_output.put_line('Calling aw_read.limit :'||bsc_mo_helper_pkg.get_time);
  if (b_pmv_measure) then
    bsc_aw_read.limit_dimensions_pmv(p_kpi, p_dim_set, l_parameters);
  else
    bsc_aw_read.limit_dimensions(p_kpi, p_dim_set, l_parameters);
  end if;
  --dbms_output.put_line('Calling aw_read.limit :'||bsc_mo_helper_pkg.get_time);

end;

Procedure initialize_query (
p_kpi varchar2,
p_dim_set varchar2,
p_parameters BIS_PMV_PAGE_PARAMETER_TBL,
p_option_string varchar2,
p_error_message out nocopy varchar2
) is
--
l_status varchar2(400);
l_start number;
l_end number;
Begin
  --dbms_output.put_line('Initialize Query :'||bsc_mo_helper_pkg.get_time);
  l_start := dbms_utility.get_time;
  initialize_parameters(p_parameters);
  if (g_xtd_type is not null) then -- XTD query
    populate_xtd_keys(p_kpi, p_dim_set, p_option_string, p_error_message);
  else
    populate_nonxtd_keys(p_kpi, p_dim_set, p_option_string, p_error_message);
  end if;
  l_end := dbms_utility.get_time;
  --dbms_output.put_line('calling internal limit api, time so far = '||(l_end-l_start));
   l_start := dbms_utility.get_time;
  limit_aw(p_kpi, p_dim_set);
   l_end := dbms_utility.get_time;
   --dbms_output.put_line('completed internal limit api, time so far = '||(l_end-l_start));
exception when others then
    --dbms_output.put_line('Exception in initialize_query:'||sqlerrm);
    raise;
End;
END BSC_DIMENSION_KEYS_PKG;

/
