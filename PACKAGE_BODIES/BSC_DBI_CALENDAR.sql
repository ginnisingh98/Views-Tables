--------------------------------------------------------
--  DDL for Package Body BSC_DBI_CALENDAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_DBI_CALENDAR" AS
/*$Header: BSCDBICB.pls 120.16.12000000.3 2007/05/10 05:32:52 amitgupt ship $*/

function generate_short_name return varchar2 is
begin
  return BSC_PERIODS_UTILITY_PKG.Get_Unique_Short_Name();
end;

function get_calendar_short_name(p_calendar_id number) return varchar2 is
begin
  return BSC_PERIODS_UTILITY_PKG.Get_Calendar_Short_Name(p_calendar_Id);
end;

function get_periodicity_short_name(p_periodicity_id number) return varchar2 is
begin
  return BSC_PERIODS_UTILITY_PKG.Get_Periodicity_Short_Name(p_periodicity_id);
end;


function dimension_exists(p_dim in varchar2) return boolean is
l_val number;
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
begin
  --making it dynamic sql to not intorduce any bis dependency
  open cv for 'select count(1) from bis_dimensions where short_name=:1' using p_dim;
  fetch cv into l_val;
  close cv;
  if (l_val>0) then
    return true;
  end if;
  return false;
end;

function dimension_object_exists(p_dim in varchar2, p_dim_object in varchar2) return boolean is
l_val number;
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_stmt varchar2(1000);
begin
  --making it dynamic sql to not intorduce any bis dependency
  l_stmt := 'select 1 from bis_levels lvl, bis_dimensions dim where lvl.dimension_id=dim.dimension_id and dim.short_name =:1 and lvl.short_name=:2';
  open cv for l_stmt using p_dim, p_dim_object;
  fetch cv into l_val;
  close cv;
  if (l_val=1) then
    return true;
  end if;
  return false;
end;

--7/30/05 for calendar short_name issue
function create_dim_obj(p_dim_obj in varchar2, p_dim in varchar2, p_view_name in varchar2, p_error_msg out nocopy varchar2) return boolean is
x_return_status varchar2(1000);
x_msg_count number;
x_msg_data varchar2(1000);
begin

  --Create dimension object only if it doesnt already exist
  if (dimension_object_exists(p_dim, p_dim_obj)) then
    return true;
  end if;
  BSC_BIS_DIM_OBJ_PUB.Create_Dim_Object
(
        p_commit                  =>  FND_API.G_FALSE
    ,   p_dim_obj_short_name      =>  p_dim_obj
    ,   p_display_name            =>  p_dim_obj
    ,   p_application_id          =>  BSC_PERIODS_UTILITY_PKG.C_BSC_APPLICATION_ID
    ,   p_description             =>  p_dim_obj
    ,   p_data_source             =>  BSC_PERIODS_UTILITY_PKG.C_PMF_DO_TYPE
    ,   p_source_table            =>  p_view_name
    ,   p_where_clause            =>  NULL
    ,   p_comparison_label_code   =>  NULL
    ,   p_table_column            =>  NULL
    ,   p_source_type             =>  BSC_PERIODS_UTILITY_PKG.C_OLTP_DO_TYPE
    ,   p_maximum_code_size       =>  NULL
    ,   p_maximum_name_size       =>  NULL
    ,   p_all_item_text           =>  NULL
    ,   p_comparison_item_text    =>  NULL
    ,   p_prototype_default_value =>  NULL
    ,   p_dimension_values_order  =>  NULL
    ,   p_comparison_order        =>  1
    ,   p_dim_short_names         =>  p_dim
    ,   x_return_status           =>  x_return_status
    ,   x_msg_count               =>  x_msg_count
    ,   x_msg_data                =>  x_msg_data
);
  if (x_return_status= FND_API.G_RET_STS_SUCCESS) then
    return true;
  else
    p_error_msg := x_msg_data;
    return false;
  end if;
  exception when others then
   p_error_msg := x_msg_data;
end;

function create_dim(p_dim in varchar2, p_error_msg out nocopy varchar2) return boolean is
x_return_status varchar2(1000);
x_msg_count number;
x_msg_data varchar2(1000);
begin
  -- create dimension only if doesnt already exist
  if (dimension_exists(p_dim)) then
    return true;
  end if;
  BSC_BIS_DIMENSION_PUB.Create_Dimension
  ( p_commit                => FND_API.G_FALSE
  , p_dim_short_name        => p_dim
  , p_display_name          => p_dim
  , p_description           => p_dim
  , p_dim_obj_short_names   => NULL
  , p_application_id        => BSC_PERIODS_UTILITY_PKG.C_BSC_APPLICATION_ID
  , p_create_view           => 0
  , x_return_status         => x_Return_Status
  , x_msg_count             => x_Msg_Count
  , x_msg_data              => x_Msg_Data
 );
  if (x_return_status= FND_API.G_RET_STS_SUCCESS) then
    return true;
  else
    p_error_msg:= x_msg_data;
    return false;
  end if;
end;

/*
Public API
For PMD. this will load bsc calendar and periodicity so that end to end kpi can be created
*/
procedure load_dbi_cal_metadata(
p_error_message out nocopy varchar2
) is
Begin
  savepoint sp_load_dbi_metadata;
  if is_dbi_cal_metadata_loaded=false then
    init_all;
    if check_for_dbi then
      init_mem_values('full');
      delete_dbi_calendar_metadata;
      load_dbi_ent_cal;
      load_dbi_445_cal;
      load_dbi_greg_cal;
      commit;
    end if;
  end if;
Exception when others then
  rollback to sp_load_dbi_metadata;
  p_error_message:=sqlerrm;
  raise;
End;

/*
Public API. called from RSG
*/
procedure load_dbi_cal_into_bsc(
Errbuf out nocopy varchar2,
Retcode out nocopy varchar2,
p_option_string varchar2
) is
--
l_error_message varchar2(4000);
--
Begin
  --if load_dbi_cal_into_bsc encounters any exception, it will raise
  load_dbi_cal_into_bsc(p_option_string,l_error_message);
Exception when others then
  rollback;
  errbuf:=g_status_message;
  retcode:='2';
  raise;
End;

/*
Public API Called from upgrade
*/
procedure load_dbi_cal_into_bsc(
p_option_string varchar2,
p_error_message out nocopy varchar2
) is
--
l_refresh_mode number;
--
Begin
  p_error_message:=null;
  if BSC_IM_UTILS.parse_values(p_option_string,',',g_options,g_number_options)=false then
    raise g_exception;
  end if;
  init_all;
  if check_for_dbi then
    ----
    if BSC_IM_UTILS.get_option_value(g_options,g_number_options,'FULL REFRESH')='Y' then
      l_refresh_mode:=1;
    else
      l_refresh_mode:=check_for_inc_refresh;
    end if;
    if l_refresh_mode=0 then
      return;
    elsif l_refresh_mode=1 then
      load_dbi_cal_into_bsc_full;
    elsif l_refresh_mode=2 then
      load_dbi_cal_into_bsc_inc;
    end if;
    ----
    if g_db_cal_modified then
      if g_debug then
        write_to_log_file_n('bsc_db_calendar modified. Need to analyze and refresh reporting calendar');
      end if;
      analyze_tables;
      refresh_reporting_calendars(p_error_message);
      --AW_INTEGRATION: Need to load DBI calendars into AW
      load_dbi_calendars_into_aw;
    end if;
    commit;
  end if;
Exception when others then
  rollback;
  p_error_message:=g_status_message;
  write_to_log_file_n('Error in load_dbi_cal_into_bsc '||g_status_message||get_time);
  raise;
End;

procedure refresh_reporting_calendars(p_error_message out nocopy varchar2) is
Begin
  if g_debug then
    write_to_log_file_n('Refresh Ent Reporting Calendar '||get_time);
  end if;
  if BSC_BSC_ADAPTER.load_reporting_calendar(g_ent_cal_id,g_options,g_number_options)=false then
    --bug#3973335
    p_error_message:=BSC_BSC_ADAPTER.g_status_message;
    raise g_exception;
  end if;
  if g_debug then
    write_to_log_file_n('Done Refresh Ent Calendar '||get_time);
  end if;
  --
  if g_debug then
    write_to_log_file_n('Refresh 445 Reporting Calendar '||get_time);
  end if;
  if BSC_BSC_ADAPTER.load_reporting_calendar(g_445_cal_id,g_options,g_number_options)=false then
    --bug#3973335
    p_error_message:=BSC_BSC_ADAPTER.g_status_message;
    raise g_exception;
  end if;
  if g_debug then
    write_to_log_file_n('Done Refresh 445 Calendar '||get_time);
  end if;
  --
  if g_debug then
    write_to_log_file_n('Refresh Greg Reporting Calendar '||get_time);
  end if;
  if BSC_BSC_ADAPTER.load_reporting_calendar(g_greg_cal_id,g_options,g_number_options)=false then
    --bug#3973335
    p_error_message:=BSC_BSC_ADAPTER.g_status_message;
    raise g_exception;
  end if;
  if g_debug then
    write_to_log_file_n('Done Refresh Greg Calendar '||get_time);
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in refresh_reporting_calendars '||g_status_message||get_time);
  raise;
End;

procedure init_mem_values(p_mode varchar2) is
Begin
  if g_init_mem is null or g_init_mem=false then
    get_bsc_greg_fiscal_year;
    init_cal_per_ids;
    if p_mode='full' then
      load_fii_time_day_full;
    else
      load_fii_time_day_inc;
    end if;
    get_ent_cal_start_date(p_mode);
    get_445_cal_start_date(p_mode);
    get_greg_cal_start_date(p_mode);
    g_init_mem:=true;
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in init_mem_values '||sqlerrm||get_time);
  raise;
End;

/*
3990678
when 445 calendar and ent cal starts on diff dates, we had an issue with weeks.
when ent cal year starts, week will not reset to 1 . it crosses through the
boundary of ent year. the difficulty is that in BSC, we expect all periodicities
to reset at year boundary. if we look at bsc_db_calendar, all periodicities have the
same year. this means the same period value of week cannot cross across ent year.
to solve this issue, we have to create ent week. we are going to start the week from 1
at the start of the year. there is no impact because the periods of the week are only
internal representation. if we look at bsc_sys_periods_tl, the week display fields will
still say 05-APR-1997 etc. in DBI, 05-APR-1997 may be week 14 of year 1997. in BSC, this will
be week 1, 1998.
*/
procedure correct_ent_week(p_mode varchar2) is
--
cursor c1(p_calendar number) is
select to_date(calendar_year||'/'||calendar_month||'/'||calendar_day,'YYYY/MM/DD'),week52,year from bsc_db_calendar where calendar_id=p_calendar
order by calendar_year desc,calendar_month desc,calendar_day desc;
--
l_stmt varchar2(20000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
--
l_index number;
l_max_date date;
l_prev_week number;--ent week for week
l_prev_year number;--ent year for week
l_prev_fii_week varchar2(40);
l_week_change boolean;
l_week_last_yr number;
l_ent_start_date date;
l_ent_yr_index number;
--
Begin
  if g_debug then
    write_to_log_file_n('In correct_ent_week'||get_time);
  end if;

  --bug fix 5461356
  --get first year start date from fii_ent_year
  l_ent_yr_index :=1;
  l_ent_start_date:= g_dbi_ent_year(l_ent_yr_index).start_date;

  --if initial, then assume that cal start date is part of g_dbi_cal_record
  if p_mode='full' then
    --count the number of weeks in the last year bug 5461356
    --I am counting this so that while setting the week ids in reverse order,
    --I can initialize week counter properly, I can not assume how many weeks will be there in
    -- first incomplete year
    l_week_last_yr :=1;
    l_prev_week :=g_dbi_cal_record(1).week_id;
    for i in 1..g_num_dbi_cal_record loop
      -- increment week counter when the week changes
      -- bug 5461356
      if g_dbi_cal_record(i).week_id<>l_prev_week then
          l_prev_week:=g_dbi_cal_record(i).week_id;
          l_week_last_yr := l_week_last_yr+1;
      end if;
      -- do not assume that start date is same for every year
      if to_char(l_ent_start_date,'MM/DD/YYYY')=to_char(g_dbi_cal_record(i).report_date,'MM/DD/YYYY') then
        l_index:=i;
        exit;
      end if;
    end loop;

    if g_debug then
      write_to_log_file_n('l_index='||l_index);
    end if;
    if l_index is null then
      write_to_log_file_n('could not locate start month/date');
      raise g_exception;
    end if;
    l_index:=l_index-1;    --set to one day prior to start, 31 mar 1997
    if l_index>0 then
      -- bug 5461356
      -- I can not assume number of weeks in the last incomplete year, it could be 54 also
      -- as DBI year is 365+/- 14
      if(l_week_last_yr> 53) then
        l_prev_week :=  l_week_last_yr;
      else
        l_prev_week:=53;
      end if;
      l_prev_year:=substr(g_dbi_cal_record(l_index).ent_period_id,1,4);
      l_prev_fii_week:=g_dbi_cal_record(l_index).week_id;
      update_dbi_445_ent_week(l_prev_fii_week,l_prev_week,l_prev_year);
      for i in reverse 1..l_index loop
        if g_dbi_cal_record(i).week_id<>l_prev_fii_week then
          l_prev_week:=l_prev_week-1;
          l_prev_year:=substr(g_dbi_cal_record(i).ent_period_id,1,4);
          l_prev_fii_week:=g_dbi_cal_record(i).week_id;
          update_dbi_445_ent_week(l_prev_fii_week,l_prev_week,l_prev_year);
        end if;
        g_dbi_cal_record(i).ent_week_id:=l_prev_week;
      end loop;
    end if;
    l_index:=l_index+1;--reset it to the start of  the ent year, 01 apr 1997
    l_prev_week:=53;--prev week
    if l_index=1 then --only when the start date of the ent year is the first record in g_dbi_cal_record
      l_prev_fii_week:=g_dbi_cal_record(l_index).week_id;
      l_prev_year:=substr(g_dbi_cal_record(l_index).ent_period_id,1,4);
    else
      l_prev_fii_week:=g_dbi_cal_record(l_index-1).week_id;
      l_prev_year:=substr(g_dbi_cal_record(l_index-1).ent_period_id,1,4);
    end if;
    update_dbi_445_ent_week(l_prev_fii_week,l_prev_week,l_prev_year);
  else
    --get the max date from bsc_sys_periods
    --INCREMENTAL
    if g_debug then
      write_to_log_file_n('select to_date(calendar_year,calendar_month,calendar_day,week52,year from bsc_db_calendar where calendar_id=p_calendar
      order by calendar_year desc,calendar_month desc,calendar_day desc using '||g_ent_cal_id);
    end if;
    open c1(g_ent_cal_id);
    fetch c1 into l_max_date,l_prev_week,l_prev_year;
    close c1;
    if g_debug then
      write_to_log_file_n('l_max_date='||l_max_date||', l_prev_week='||l_prev_week||', l_prev_year='||l_prev_year);
    end if;
    l_stmt:='select week_id from fii_time_week where week_id in (select week_id from fii_time_day where report_date=:1)';
    if g_debug then
      write_to_log_file_n(l_stmt);
    end if;
    open cv for l_stmt using l_max_date;
    fetch cv into l_prev_fii_week;
    if g_debug then
      write_to_log_file_n('l_prev_fii_week='||l_prev_fii_week);
    end if;
    l_index:=1;
    --assume dates are consequetive, this means that the first date in g_dbi_cal_record is l_max_date +1
  end if;
  if g_debug then
    write_to_log_file_n('Going to correct data. ');
    write_to_log_file('l_prev_week='||l_prev_week);
    write_to_log_file('l_prev_year='||l_prev_year);
    write_to_log_file('l_prev_fii_week='||l_prev_fii_week);
    write_to_log_file('l_index='||l_index);
  end if;
  g_num_ent_week:=0;
  for i in l_index..g_num_dbi_cal_record loop
    l_week_change:=false;
    if g_dbi_cal_record(i).week_id<>l_prev_fii_week then
      l_prev_week:=l_prev_week+1; --this can become 54 if this date is ent year start. will be reset to 1 in the next if...
      l_prev_year:=substr(g_dbi_cal_record(i).ent_period_id,1,4);
      l_prev_fii_week:=g_dbi_cal_record(i).week_id;
      update_dbi_445_ent_week(l_prev_fii_week,l_prev_week,l_prev_year);
      l_week_change:=true;
    end if;
    --don't assume that every year start on same date bug 5461356
    if to_char(l_ent_start_date,'MM/DD/YYYY')=to_char(g_dbi_cal_record(i).report_date,'MM/DD/YYYY') then
      -- will not change the following logic for bug 5461356, as this is already agreed upon format
      --if there is no week change as we cross the ent boundary, have to create a record for this week end in bsc sys periods
      --g_ent_week holds only the additional weeks at ent year boundary we need to create
      if l_week_change=false and i>1 then
        g_num_ent_week:=g_num_ent_week+1;
        g_ent_week(g_num_ent_week).week_id:=null;
        g_ent_week(g_num_ent_week).year_id:=get_dbi_445_year(l_prev_fii_week);--not used anywhere
        g_ent_week(g_num_ent_week).sequence:=l_prev_week;
        g_ent_week(g_num_ent_week).name:=to_char(g_dbi_cal_record(i-1).report_date,'dd-Mon-rr');--week end date
        g_ent_week(g_num_ent_week).ent_week_id:=l_prev_week;
        g_ent_week(g_num_ent_week).ent_year_id:=substr(g_dbi_cal_record(i-1).ent_period_id,1,4);
        /* 4992925 earlier we had a check on if g_ent_week(g_num_ent_week).year_id is null then
        since year_id is not used we stop this check*/
      end if;
      l_prev_week:=1;
      l_prev_year:=substr(g_dbi_cal_record(i).ent_period_id,1,4);
      update_dbi_445_ent_week(l_prev_fii_week,l_prev_week,l_prev_year);
      /*
      there is an issue here. (soln is the code above of creating records in g_ent_week)
      imagine that the 445 week is going across the ent year boundary
      29-mar   30-mar   31-mar  1-apr  2apr
      13        14       14      14     14
      now, the ent week is going to be
      29-mar   30-mar   31-mar  1-apr  2apr
      51        52       52      1     1
      in bsc_sys_periods, there is an entry for the week ending 29 mar. this is week 51
      for the week ending 05-apr, the entry will say ent week of 1
      but, this week now only has 5 days, 01-apr to 05-apr. when the user will see weekly
      aggregation, the data for 30-mar and 31-mar will not be seen. the MV has the agg for
      these 2 dates. but, there is no entry in bsc_sys_periods for week 52.
      Solutions:
      1 do we create a row in bsc sys periods tl for week 52? what if the language is chinese? we cannot assume 01-apr-2003 format
      2 do we ask fii team to see how they generate the name?
        checked FII_TIME_C. they have hard coded the format
        insert into fii_time_week ...
        name,
        ...)
       values
       (...
       to_char(l_week_end,'dd-Mon-rr'),
       );
       Can we also hard code the format

       Asked patricia is its ok for us to create a row for the week ending on the fiscal year boundary. so in bsc sys periods
       user sees week ending 29 mar, another week ending 31 mar and then another week ending 05 apr. in DBI, they will
       not see the week ending 31 mar. patricia said this is ok since even now, users are used to this behavior in bsc
       regarding the format, asked fii team. it seems the upper management in fii team has approved the format. its not
       multi lingual
      */
       --find next year start date
       l_ent_yr_index :=l_ent_yr_index+1;
       if(l_ent_yr_index<=g_num_dbi_ent_year) then
         l_ent_start_date:= g_dbi_ent_year(l_ent_yr_index).start_date;
       else
         l_ent_start_date:= g_ent_start_date;
       end if;
    end if;
    g_dbi_cal_record(i).ent_week_id:=l_prev_week;
  end loop;
  if g_debug then
    write_to_log_file_n('Output from g_dbi_445_week');
    for i in 1..g_num_dbi_445_week loop
      write_to_log_file(g_dbi_445_week(i).week_id||' '||g_dbi_445_week(i).sequence||' '||g_dbi_445_week(i).ent_week_id||' '||
      g_dbi_445_week(i).ent_year_id);
    end loop;
    write_to_log_file_n('Output from g_ent_week, the Extra weeks created');
    for i in 1..g_num_ent_week loop
      write_to_log_file(g_ent_week(i).ent_year_id||' '||g_ent_week(i).sequence||' '||g_ent_week(i).ent_week_id||' '||g_ent_week(i).name);
    end loop;
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in correct_ent_week '||sqlerrm||get_time);
  raise;
End;

procedure update_dbi_445_ent_week(
p_prev_fii_week varchar2,
p_prev_week number,
p_prev_year number) is
Begin
  --if g_debug then
    --write_to_log_file_n('In update_dbi_445_ent_week '||p_prev_fii_week||' '||p_prev_week);
  --end if;
  for i in 1..g_num_dbi_445_week loop
    if g_dbi_445_week(i).week_id=p_prev_fii_week then
      g_dbi_445_week(i).ent_week_id:=p_prev_week;
      g_dbi_445_week(i).ent_year_id:=p_prev_year;
      exit;
    end if;
  end loop;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in update_dbi_445_ent_week '||sqlerrm||get_time);
  raise;
End;

function get_dbi_445_year(p_prev_fii_week varchar2) return number is
Begin
  for i in 1..g_num_dbi_445_week loop
    if g_dbi_445_week(i).week_id=p_prev_fii_week then
      return g_dbi_445_week(i).year_id;
    end if;
  end loop;
  return null;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_dbi_445_year '||sqlerrm||get_time);
  raise;
End;

/*
return status
0 no refresh reqd
1 full refresh reqd
2 inc refresh
*/
function check_for_inc_refresh return number is
--
/*cursor c1 is select 1 from bsc_db_calendar,bsc_sys_calendars_b where edw_calendar_type_id=1 and edw_calendar_id =1001
and bsc_db_calendar.calendar_id=bsc_sys_calendars_b.calendar_id and rownum=1;
cursor c2 is select 1 from mlog$_fii_time_day where rownum=1;
cursor c3 is select 1 from mlog$_fii_time_day where dmltype$$ <>'I' and rownum=1;
*/
--
l_stmt varchar2(20000);
TYPE CurTyp IS REF CURSOR;
c1   CurTyp;
c2   CurTyp;
c3   CurTyp;
l_res number;
Begin
  l_res:=null;
  l_stmt:='select 1 from bsc_db_calendar,bsc_sys_calendars_b where edw_calendar_type_id=1 and edw_calendar_id =1001
  and bsc_db_calendar.calendar_id=bsc_sys_calendars_b.calendar_id and rownum=1';
  if g_debug then
    write_to_log_file_n(l_stmt);
  end if;
  open c1 for l_stmt;
  fetch c1 into l_res;
  close c1;
  if l_res is null then
    if g_debug then
      write_to_log_file_n('DBI calendar not brought in. Full refresh');
    end if;
    return 1;
  end if;
  --see if mlog$_fii_time_day has only insert rows
  /*4769746
  checking mlog of fii_time_day has the following disadvantage. if a dependent mv never refreshes, this code may always find the same entries
  in the mv log and do a full refresh (when there are complex changes)
  a possible approach around this is to have our dummy mv with mv log on top of this. we refresh our mv and look at our mv's snapshot log
  if fii mvlog has 1000 entries and they do not change from t1 to t2, our mv log will be empty.
  however, using a mv ontop of fii time day table has the disadv that unless this mv is refreshed, fii time day mv log will keep growing. this can be
  a potential issue.
  another approach is to get some max date from mv log and save it somewhere and next time see if there are records beyond this max date. SNAPTIME
  is always set to jan 4000. so we cannot use this, since t1 and t2 will see jan 4000. using such hidden columns can also be dangerous since
  server team may modify its behavior
  the perf gain of full vs inc is small. in prod systems, the chances that mv log for fii time day will have data in it that is not cleaned up
  is small. even if we keep doing full refresh each time, its fine. note> the max time is in refreshing the reporting calendar. this table has to
  be refreshed fully in full or inc mode. so no big diff between the two
  putting the right value for fiscal change is very imp. fiscal change=1 will trigger data cleanup of dependent kpis
  we have g_ent_fiscal_change, g_445_fiscal_change and g_greg_fiscal_change to handle this now
  */
  l_res:=null;
  l_stmt:='select 1 from mlog$_fii_time_day where rownum=1';
  if g_debug then
    write_to_log_file_n(l_stmt);
  end if;
  open c2 for l_stmt;
  fetch c2 into l_res;
  close c2;
  if l_res is null then
    if g_debug then
      write_to_log_file_n('No inc change in mlog$_fii_time_day');
    end if;
    return 0;
  end if;
  l_res:=null;
  l_stmt:='select 1 from mlog$_fii_time_day where dmltype$$ <>''I'' and rownum=1';
  if g_debug then
    write_to_log_file_n(l_stmt);
  end if;
  open c3 for l_stmt;
  fetch c3 into l_res;
  close c3;
  if l_res is null then
    if g_debug then
      write_to_log_file_n('Only insert rows. Inc change');
    end if;
    return 2;
  else
    if g_debug then
      write_to_log_file_n('Complex change...full refresh');
    end if;
    --g_fiscal_change:=1;
    return 1;
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in check_for_inc_refresh '||g_status_message||get_time);
  raise;
End;

/*
Private API
*/

procedure load_dbi_cal_into_bsc_full is
--
l_error varchar2(4000);
--
Begin
  --bsc_sys_calendars_b,bsc_sys_calendars_tl,bsc_sys_periods,bsc_sys_periods_tl,bsc_sys_periodicities
  if g_debug then
    write_to_log_file_n('In load_dbi_cal_into_bsc_full '||get_time);
  end if;
  --get the dbi cal info into memory
  init_mem_values('full');
  loadmem_ent_full;
  loadmem_445_full;
  loadmem_greg_full;
  -----------
  --3990678
  --correct the week info
  correct_ent_week('full');
  calculate_day365('full',g_ent_cal_id);
  calculate_day365('full',g_greg_cal_id);
  calculate_day365_445('full');
  if g_debug then
    dmp_g_dbi_cal_record;
  end if;
  -----------
  /*5461356 . we were deleting the metadata first. this means bsc_sys_periodicities got cleaned. then when we did
  delete bsc_sys_periods where periodicity_id in bsc_sys_periodicities, it did not clean bsc_sys_periods and so there was unique
  constraint error. soln-> first delete bsc_sys_periods and db calendar (delete_dbi_calendars), then periodicities and sys calendar */
  delete_dbi_calendars;
  delete_dbi_calendar_metadata;
  load_dbi_ent_cal;
  load_dbi_445_cal;
  load_dbi_greg_cal;
  --
  --loadmem_ent_full; --old place
  --loadmem_445_full; --old place
  --loadmem_greg_full; --old place
  ----
  load_dbi_ent_cal_data;
  --
  load_dbi_445_cal_data;
  --
  load_dbi_greg_cal_data;
  --
  if g_debug then
    write_to_log_file_n('Done load_dbi_cal_into_bsc_full '||get_time);
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in load_dbi_cal_into_bsc_full '||g_status_message||get_time);
  raise;
End;

procedure load_dbi_cal_into_bsc_inc is
--
--
Begin
  --bsc_sys_calendars_b,bsc_sys_calendars_tl,bsc_sys_periods,bsc_sys_periods_tl,bsc_sys_periodicities
  if g_debug then
    write_to_log_file_n('In load_dbi_cal_into_bsc_inc '||get_time);
  end if;
  --get the dbi cal info into memory
  --looks like mlog$_fii_time_day has no column for greg month_id. this means that we
  --cannot extend the greg calendar.
  init_mem_values('inc');
  --
  loadmem_ent_inc;
  loadmem_445_inc;
  ---bug fix 5461356 if thr are no records don't process anything
  if g_num_dbi_cal_record=0 then
     return ;
  end if;
  -----------
  --3990678
  --correct the week info
  correct_ent_week('inc');
  calculate_day365('inc',g_ent_cal_id);
  calculate_day365('inc',g_greg_cal_id);
  calculate_day365_445('inc');
  if g_debug then
    dmp_g_dbi_cal_record;
  end if;
  -----------
  if g_num_dbi_cal_record>0 then
    ----
    load_dbi_ent_cal_data;
    --
    load_dbi_445_cal_data;
  end if;
  if g_debug then
    write_to_log_file_n('Done load_dbi_cal_into_bsc_inc '||get_time);
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in load_dbi_cal_into_bsc_inc '||g_status_message||get_time);
  raise;
End;


procedure get_bsc_greg_fiscal_year is
--
l_stmt varchar2(20000);
l_max_year number;
l_min_year number;
l_current_year number;
--
TYPE CurTyp IS REF CURSOR;
c1   CurTyp;
--
Begin
  --fix bug#4607690: Currently we are reading the fiscal year from the bsc gregorian calendar.
  -- Now we are going to take the year of SYSDATE. If this year is not available in FII_TIME_DAY
  -- then we will use max(year) from FII_TIME_DAY.
  l_stmt := 'select max(ent_year_id), min(ent_year_id), to_number(to_char(sysdate,''YYYY'')) from fii_time_day';
  if g_debug then
    write_to_log_file_n('cursor c1 is '||l_stmt||';'||get_time);
  end if;
  open c1 for l_stmt;
  fetch c1 into l_max_year, l_min_year, l_current_year;
  close c1;
  if g_debug then
    write_to_log_file_n('l_max_year='||l_max_year||' '||get_time);
    write_to_log_file_n('l_min_year='||l_min_year||' '||get_time);
    write_to_log_file_n('l_current_year='||l_current_year||' '||get_time);
  end if;
  if (l_current_year >= l_min_year) and (l_current_year <= l_max_year) then
    g_bsc_greg_fiscal_year:=l_current_year;
  else
    g_bsc_greg_fiscal_year:=l_max_year;
  end if;
  if g_debug then
    write_to_log_file_n('Finaly g_bsc_greg_fiscal_year='||g_bsc_greg_fiscal_year);
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_bsc_greg_fiscal_year '||g_status_message||get_time);
  raise;
End;

procedure init_cal_per_ids is
--
cursor c1(p_cal_id number) is select bsc_sys_periodicities.calendar_id,
bsc_sys_periodicities.periodicity_id,bsc_sys_periodicities.period_type_id ,
bsc_sys_calendars_b.short_name, bsc_sys_periodicities.short_name,bsc_sys_calendars_b.fiscal_change
from bsc_sys_periodicities ,bsc_sys_calendars_b
where bsc_sys_periodicities.calendar_id=bsc_sys_calendars_b.calendar_id
and bsc_sys_calendars_b.edw_calendar_type_id=1 and bsc_sys_calendars_b.edw_calendar_id=p_cal_id;
--
l_cal_id number;
l_cal_short_name varchar2(100);
l_per_id number;
l_per_short_name varchar2(100);
l_per_type_id number;
l_fiscal_change number;
--
Begin
  if g_debug then
    write_to_log_file_n('select bsc_sys_periodicities.periodicity_id,bsc_sys_periodicities.period_type_id '||
    'from bsc_sys_periodicities ,bsc_sys_calendars_b '||
    'where bsc_sys_periodicities.calendar_id=bsc_sys_calendars_b.calendar_id '||
    'and bsc_sys_calendars_b.edw_calendar_type_id=1 and bsc_sys_calendars_b.edw_calendar_id=1001/1002/1003 ');
  end if;
  open c1(1001);
  loop
    fetch c1 into l_cal_id,l_per_id,l_per_type_id, l_cal_short_name, l_per_short_name,l_fiscal_change;
    exit when c1%notfound;
    g_ent_cal_id:=l_cal_id;
    g_ent_fiscal_change:=l_fiscal_change;
    if l_per_type_id=1 then
      g_ent_day_per_id:=l_per_id;
    elsif l_per_type_id=16 then
      g_ent_week_per_id:=l_per_id;
    elsif l_per_type_id=32 then
      g_ent_period_per_id:=l_per_id;
    elsif l_per_type_id=64 then
      g_ent_qtr_per_id:=l_per_id;
    elsif l_per_type_id=128 then
      g_ent_year_per_id:=l_per_id;
    end if;
  end loop;
  close c1;
  if g_ent_cal_id is null then
    g_ent_cal_id:=get_calendar_nextval;
    g_ent_fiscal_change:=0;
    g_ent_day_per_id:=get_periodicity_nextval;
    g_ent_week_per_id:=get_periodicity_nextval;
    g_ent_period_per_id:=get_periodicity_nextval;
    g_ent_qtr_per_id:=get_periodicity_nextval;
    g_ent_year_per_id:=get_periodicity_nextval;
  end if;
  ---
  open c1(1002);
  loop
    fetch c1 into l_cal_id,l_per_id,l_per_type_id, l_cal_short_name, l_per_short_name,l_fiscal_change;
    exit when c1%notfound;
    g_445_cal_id:=l_cal_id;
    g_445_fiscal_change:=l_fiscal_change;
    g_445_cal_short_name := l_cal_short_name;
    if l_per_type_id=1 then
      g_445_day_per_id:=l_per_id;
      g_445_day_short_name := l_per_short_name;
    elsif l_per_type_id=16 then
      g_445_week_per_id:=l_per_id;
      g_445_week_short_name := l_per_short_name;
    elsif l_per_type_id=32 then
      g_445_p445_per_id:=l_per_id;
      g_445_p445_short_name := l_per_short_name;
    elsif l_per_type_id=128 then
      g_445_year_per_id:=l_per_id;
      g_445_year_short_name := l_per_short_name;
    end if;
  end loop;
  close c1;
  if g_445_cal_id is null then
    g_445_cal_id:=get_calendar_nextval;
    g_445_fiscal_change:=0;
    g_445_day_per_id:=get_periodicity_nextval;
    g_445_week_per_id:=get_periodicity_nextval;
    g_445_p445_per_id:=get_periodicity_nextval;
    g_445_year_per_id:=get_periodicity_nextval;
  end if;
  ---
  open c1(1003);
  loop
    fetch c1 into l_cal_id,l_per_id,l_per_type_id, l_cal_short_name, l_per_short_name,l_fiscal_change;
    exit when c1%notfound;
    g_greg_cal_id:=l_cal_id;
    g_greg_fiscal_change:=l_fiscal_change;
    g_greg_cal_short_name := l_cal_short_name;
    if l_per_type_id=1 then
      g_greg_day_per_id:=l_per_id;
      g_greg_day_short_name := l_per_short_name;
    elsif l_per_type_id=32 then
      g_greg_period_per_id:=l_per_id;
      g_greg_period_short_name := l_per_short_name;
    elsif l_per_type_id=64 then
      g_greg_qtr_per_id:=l_per_id;
      g_greg_qtr_short_name := l_per_short_name;
    elsif l_per_type_id=128 then
      g_greg_year_per_id:=l_per_id;
      g_greg_year_short_name := l_per_short_name;
    end if;
  end loop;
  close c1;
  if g_greg_cal_id is null then
    g_greg_cal_id:=get_calendar_nextval;
    g_greg_fiscal_change:=0;
    g_greg_day_per_id:=get_periodicity_nextval;
    g_greg_period_per_id:=get_periodicity_nextval;
    g_greg_qtr_per_id:=get_periodicity_nextval;
    g_greg_year_per_id:=get_periodicity_nextval;
  end if;
  if g_debug then
    write_to_log_file_n('Ent periodicities');
    write_to_log_file('g_ent_cal_id='||g_ent_cal_id);
    write_to_log_file('g_ent_fiscal_change='||g_ent_fiscal_change);
    write_to_log_file('g_ent_day_per_id='||g_ent_day_per_id);
    write_to_log_file('g_ent_week_per_id='||g_ent_week_per_id);
    write_to_log_file('g_ent_period_per_id='||g_ent_period_per_id);
    write_to_log_file('g_ent_qtr_per_id='||g_ent_qtr_per_id);
    write_to_log_file('g_ent_year_per_id='||g_ent_year_per_id);
    write_to_log_file_n('445 periodicities');
    write_to_log_file('g_445_cal_id='||g_445_cal_id);
    write_to_log_file('g_445_fiscal_change='||g_445_fiscal_change);
    write_to_log_file('g_445_cal_short_name='||g_445_cal_short_name);
    write_to_log_file('g_445_day_per_id='||g_445_day_per_id);
    write_to_log_file('g_445_day__short_name='||g_445_day_short_name);
    write_to_log_file('g_445_week_per_id='||g_445_week_per_id);
    write_to_log_file('g_445_week_short_name='||g_445_week_short_name);
    write_to_log_file('g_445_p445_per_id='||g_445_p445_per_id);
    write_to_log_file('g_445_p445_short_name='||g_445_p445_short_name);
    write_to_log_file('g_445_year_per_id='||g_445_year_per_id);
    write_to_log_file('g_445_year_short_name='||g_445_year_short_name);
    write_to_log_file_n('Greg periodicities');
    write_to_log_file('g_greg_cal_id='||g_greg_cal_id);
    write_to_log_file('g_greg_fiscal_change='||g_greg_fiscal_change);
    write_to_log_file('g_greg_cal_short_name='||g_greg_cal_short_name);
    write_to_log_file('g_greg_day_per_id='||g_greg_day_per_id);
    write_to_log_file('g_greg_day_short_name='||g_greg_day_short_name);
    write_to_log_file('g_greg_period_per_id='||g_greg_period_per_id);
    write_to_log_file('g_greg_period_short_name='||g_greg_period_short_name);
    write_to_log_file('g_greg_qtr_per_id='||g_greg_qtr_per_id);
    write_to_log_file('g_greg_qtr_short_name='||g_greg_qtr_short_name);
    write_to_log_file('g_greg_year_per_id='||g_greg_year_per_id);
    write_to_log_file('g_greg_year_short='||g_greg_year_short_name);
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in init_cal_per_ids '||g_status_message||get_time);
  raise;
End;

procedure load_fii_time_day_full is
l_stmt varchar2(20000);
TYPE CurTyp IS REF CURSOR;
c_dbi   CurTyp;
Begin
  l_stmt:='select report_date,to_char(report_date,''DD''),to_char(report_date,''MM''),to_char(report_date,''YYYY''),
  month_id,ent_period_id,week_id, start_date, end_date from fii_time_day order by report_date';
  if g_debug then
    write_to_log_file_n(l_stmt);
  end if;
  g_num_dbi_cal_record:=1;
  open c_dbi for l_stmt;
  loop
    fetch c_dbi into g_dbi_cal_record(g_num_dbi_cal_record).report_date,
    g_dbi_cal_record(g_num_dbi_cal_record).cal_day,
    g_dbi_cal_record(g_num_dbi_cal_record).cal_month,
    g_dbi_cal_record(g_num_dbi_cal_record).cal_year,
    g_dbi_cal_record(g_num_dbi_cal_record).month_id,
    g_dbi_cal_record(g_num_dbi_cal_record).ent_period_id,
    g_dbi_cal_record(g_num_dbi_cal_record).week_id,
    g_dbi_cal_record(g_num_dbi_cal_record).start_date,
    g_dbi_cal_record(g_num_dbi_cal_record).end_date;
    exit when c_dbi%notfound;
    g_dbi_cal_record(g_num_dbi_cal_record).row_num:=g_num_dbi_cal_record;
    g_num_dbi_cal_record:=g_num_dbi_cal_record+1;
  end loop;
  close c_dbi;
  g_num_dbi_cal_record:=g_num_dbi_cal_record-1;
  if g_debug then
    write_to_log_file_n('g_num_dbi_cal_record='||g_num_dbi_cal_record);
  end if;
  /*if g_debug then
    for i in 1..g_num_dbi_cal_record loop
      write_to_log_file(g_dbi_cal_record(i).report_date||' '||g_dbi_cal_record(i).cal_day||' '||
      g_dbi_cal_record(i).cal_month||' '||g_dbi_cal_record(i).cal_year||' '||
      g_dbi_cal_record(i).month_id||' '||g_dbi_cal_record(i).ent_period_id||' '||
      g_dbi_cal_record(i).week_id||' '||g_dbi_cal_record(i).row_num);
    end loop;
  end if;*/
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in load_fii_time_day_full '||g_status_message||get_time);
  raise;
End;

procedure load_fii_time_day_inc is
l_stmt varchar2(20000);
TYPE CurTyp IS REF CURSOR;
c_dbi   CurTyp;
Begin
  l_stmt:='select report_date,to_char(report_date,''DD''),to_char(report_date,''MM''),to_char(report_date,''YYYY''),
  ent_period_id,week_id from mlog$_fii_time_day
  where not exists (select 1 from bsc_sys_periods where
  periodicity_id=:1 and time_fk=to_char(report_date,''MM/DD/YYYY''))
  order by report_date';
  if g_debug then
    write_to_log_file_n(l_stmt||' '||g_ent_day_per_id);
  end if;
  g_num_dbi_cal_record:=1;
  open c_dbi for l_stmt using g_ent_day_per_id;
  loop
    fetch c_dbi into g_dbi_cal_record(g_num_dbi_cal_record).report_date,
    g_dbi_cal_record(g_num_dbi_cal_record).cal_day,
    g_dbi_cal_record(g_num_dbi_cal_record).cal_month,
    g_dbi_cal_record(g_num_dbi_cal_record).cal_year,
    g_dbi_cal_record(g_num_dbi_cal_record).ent_period_id,
    g_dbi_cal_record(g_num_dbi_cal_record).week_id;
    exit when c_dbi%notfound;
    g_dbi_cal_record(g_num_dbi_cal_record).row_num:=g_num_dbi_cal_record;
    g_num_dbi_cal_record:=g_num_dbi_cal_record+1;
  end loop;
  close c_dbi;
  g_num_dbi_cal_record:=g_num_dbi_cal_record-1;
  if g_debug then
    write_to_log_file_n('g_num_dbi_cal_record='||g_num_dbi_cal_record);
  end if;
  /*if g_debug then
    for i in 1..g_num_dbi_cal_record loop
      write_to_log_file(g_dbi_cal_record(i).report_date||' '||g_dbi_cal_record(i).cal_day||' '||
      g_dbi_cal_record(i).cal_month||' '||g_dbi_cal_record(i).cal_year||' '||
      g_dbi_cal_record(i).month_id||' '||g_dbi_cal_record(i).ent_period_id||' '||
      g_dbi_cal_record(i).week_id||' '||g_dbi_cal_record(i).row_num);
    end loop;
  end if;*/
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in load_fii_time_day_inc '||g_status_message||get_time);
  raise;
End;

procedure loadmem_ent_full is
l_stmt varchar2(20000);
TYPE CurTyp IS REF CURSOR;
c1   CurTyp;
c2   CurTyp;
c3   CurTyp;
Begin
  g_num_dbi_ent_period:=1;
  g_num_dbi_ent_qtr:=1;
  g_num_dbi_ent_year:=1;
  ---period
  l_stmt:='select ent_period_id,ent_year_id,sequence,name, start_date, end_date from FII_TIME_ENT_PERIOD order by ent_period_id';
  if g_debug then
    write_to_log_file_n(l_stmt);
  end if;
  open c1 for l_stmt;
  loop
    fetch c1 into
      g_dbi_ent_period(g_num_dbi_ent_period).ent_period_id,
      g_dbi_ent_period(g_num_dbi_ent_period).ent_year_id,
      g_dbi_ent_period(g_num_dbi_ent_period).sequence,
      g_dbi_ent_period(g_num_dbi_ent_period).name,
      g_dbi_ent_period(g_num_dbi_ent_period).start_date,
      g_dbi_ent_period(g_num_dbi_ent_period).end_date;
    exit when c1%notfound;
    g_num_dbi_ent_period:=g_num_dbi_ent_period+1;
  end loop;
  close c1;
  g_num_dbi_ent_period:=g_num_dbi_ent_period-1;
  if g_debug then
    write_to_log_file_n('g_num_dbi_ent_period='||g_num_dbi_ent_period);
  end if;
  ---qtr
  l_stmt:='select ent_qtr_id,ent_year_id,sequence,name, start_date, end_date from FII_TIME_ENT_QTR order by ent_qtr_id';
  if g_debug then
    write_to_log_file_n(l_stmt);
  end if;
  open c2 for l_stmt;
  loop
    fetch c2 into
      g_dbi_ent_qtr(g_num_dbi_ent_qtr).ent_qtr_id,
      g_dbi_ent_qtr(g_num_dbi_ent_qtr).ent_year_id,
      g_dbi_ent_qtr(g_num_dbi_ent_qtr).sequence,
      g_dbi_ent_qtr(g_num_dbi_ent_qtr).name,
      g_dbi_ent_qtr(g_num_dbi_ent_qtr).start_date,
      g_dbi_ent_qtr(g_num_dbi_ent_qtr).end_date;
    exit when c2%notfound;
    g_num_dbi_ent_qtr:=g_num_dbi_ent_qtr+1;
  end loop;
  close c2;
  g_num_dbi_ent_qtr:=g_num_dbi_ent_qtr-1;
  if g_debug then
    write_to_log_file_n('g_num_dbi_ent_qtr='||g_num_dbi_ent_qtr);
  end if;
  ---year
  l_stmt:='select ent_year_id,sequence,name, start_date, end_date from FII_TIME_ENT_YEAR order by ent_year_id';
  if g_debug then
    write_to_log_file_n(l_stmt);
  end if;
  open c3 for l_stmt;
  loop
    fetch c3 into
      g_dbi_ent_year(g_num_dbi_ent_year).ent_year_id,
      g_dbi_ent_year(g_num_dbi_ent_year).sequence,
      g_dbi_ent_year(g_num_dbi_ent_year).name,
      g_dbi_ent_year(g_num_dbi_ent_year).start_date,
      g_dbi_ent_year(g_num_dbi_ent_year).end_date;
    exit when c3%notfound;
    g_num_dbi_ent_year:=g_num_dbi_ent_year+1;
  end loop;
  close c3;
  g_num_dbi_ent_year:=g_num_dbi_ent_year-1;
  if g_debug then
    write_to_log_file_n('g_num_dbi_ent_year='||g_num_dbi_ent_year);
  end if;
  ---
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in loadmem_ent_full '||g_status_message||get_time);
  raise;
End;

procedure loadmem_ent_inc is
l_stmt varchar2(20000);
TYPE CurTyp IS REF CURSOR;
c1   CurTyp;
c2   CurTyp;
c3   CurTyp;
Begin
  g_num_dbi_ent_period:=1;
  g_num_dbi_ent_qtr:=1;
  g_num_dbi_ent_year:=1;
  ---period
  l_stmt:='select ent_period_id,ent_year_id,sequence,name,start_date, end_date from FII_TIME_ENT_PERIOD
  where ent_period_id not in (select to_number(time_fk) from bsc_sys_periods where periodicity_id=:1)
  order by ent_period_id';
  if g_debug then
    write_to_log_file_n(l_stmt||' '||g_ent_period_per_id);
  end if;
  open c1 for l_stmt using g_ent_period_per_id;
  loop
    fetch c1 into
      g_dbi_ent_period(g_num_dbi_ent_period).ent_period_id,
      g_dbi_ent_period(g_num_dbi_ent_period).ent_year_id,
      g_dbi_ent_period(g_num_dbi_ent_period).sequence,
      g_dbi_ent_period(g_num_dbi_ent_period).name,
      g_dbi_ent_period(g_num_dbi_ent_period).start_date,
      g_dbi_ent_period(g_num_dbi_ent_period).end_date;
    exit when c1%notfound;
    g_num_dbi_ent_period:=g_num_dbi_ent_period+1;
  end loop;
  close c1;
  g_num_dbi_ent_period:=g_num_dbi_ent_period-1;
  if g_debug then
    write_to_log_file_n('g_num_dbi_ent_period='||g_num_dbi_ent_period);
  end if;
  ---qtr
  l_stmt:='select ent_qtr_id,ent_year_id,sequence,name, start_date, end_date from FII_TIME_ENT_QTR
  where ent_qtr_id not in (select to_number(time_fk) from bsc_sys_periods where periodicity_id=:1)
  order by ent_qtr_id';
  if g_debug then
    write_to_log_file_n(l_stmt||' '||g_ent_qtr_per_id);
  end if;
  open c2 for l_stmt using g_ent_qtr_per_id;
  loop
    fetch c2 into
      g_dbi_ent_qtr(g_num_dbi_ent_qtr).ent_qtr_id,
      g_dbi_ent_qtr(g_num_dbi_ent_qtr).ent_year_id,
      g_dbi_ent_qtr(g_num_dbi_ent_qtr).sequence,
      g_dbi_ent_qtr(g_num_dbi_ent_qtr).name,
      g_dbi_ent_qtr(g_num_dbi_ent_qtr).start_date,
      g_dbi_ent_qtr(g_num_dbi_ent_qtr).end_date;
    exit when c2%notfound;
    g_num_dbi_ent_qtr:=g_num_dbi_ent_qtr+1;
  end loop;
  close c2;
  g_num_dbi_ent_qtr:=g_num_dbi_ent_qtr-1;
  if g_debug then
    write_to_log_file_n('g_num_dbi_ent_qtr='||g_num_dbi_ent_qtr);
  end if;
  ---year
  l_stmt:='select ent_year_id,sequence,name, start_date, end_date from FII_TIME_ENT_YEAR
  where ent_year_id not in (select to_number(time_fk) from bsc_sys_periods where periodicity_id=:1)
  order by ent_year_id';
  if g_debug then
    write_to_log_file_n(l_stmt||' '||g_ent_year_per_id);
  end if;
  open c3 for l_stmt using g_ent_year_per_id;
  loop
    fetch c3 into
      g_dbi_ent_year(g_num_dbi_ent_year).ent_year_id,
      g_dbi_ent_year(g_num_dbi_ent_year).sequence,
      g_dbi_ent_year(g_num_dbi_ent_year).name,
      g_dbi_ent_year(g_num_dbi_ent_year).start_date,
      g_dbi_ent_year(g_num_dbi_ent_year).end_date;
    exit when c3%notfound;
    g_num_dbi_ent_year:=g_num_dbi_ent_year+1;
  end loop;
  close c3;
  g_num_dbi_ent_year:=g_num_dbi_ent_year-1;
  if g_debug then
    write_to_log_file_n('g_num_dbi_ent_year='||g_num_dbi_ent_year);
  end if;
  ---
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in loadmem_ent_inc '||g_status_message||get_time);
  raise;
End;

procedure loadmem_445_full is
l_stmt varchar2(20000);
TYPE CurTyp IS REF CURSOR;
c1   CurTyp;
c2   CurTyp;
c3   CurTyp;
Begin
  ---week
  g_num_dbi_445_week:=1;
  g_num_dbi_445_p445:=1;
  g_num_dbi_445_year:=1;
  --Added start_date, end_date for bug 4482933
  l_stmt:='select week_id,substr(week_id,1,4),substr(week_id,1,4),sequence,name, start_date, end_date from FII_TIME_WEEK order by week_id';
  if g_debug then
    write_to_log_file_n(l_stmt);
  end if;
  open c1 for l_stmt;
  loop
    fetch c1 into
      g_dbi_445_week(g_num_dbi_445_week).week_id,
      g_dbi_445_week(g_num_dbi_445_week).year_id,
      g_dbi_445_week(g_num_dbi_445_week).ent_year_id,
      g_dbi_445_week(g_num_dbi_445_week).sequence,
      g_dbi_445_week(g_num_dbi_445_week).name,
      g_dbi_445_week(g_num_dbi_445_week).start_date,
      g_dbi_445_week(g_num_dbi_445_week).end_date;
    exit when c1%notfound;
    g_num_dbi_445_week:=g_num_dbi_445_week+1;
  end loop;
  close c1;
  g_num_dbi_445_week:=g_num_dbi_445_week-1;
  if g_debug then
    write_to_log_file_n('g_num_dbi_445_week='||g_num_dbi_445_week);
  end if;
  ---p445
  l_stmt:='select period445_id,year445_id,sequence,name, start_date, end_date from fii_time_p445 order by period445_id';
  if g_debug then
    write_to_log_file_n(l_stmt);
  end if;
  open c2 for l_stmt;
  loop
    fetch c2 into
      g_dbi_445_p445(g_num_dbi_445_p445).period445_id,
      g_dbi_445_p445(g_num_dbi_445_p445).year445_id,
      g_dbi_445_p445(g_num_dbi_445_p445).sequence,
      g_dbi_445_p445(g_num_dbi_445_p445).name,
      g_dbi_445_p445(g_num_dbi_445_p445).start_date,
      g_dbi_445_p445(g_num_dbi_445_p445).end_date;
    exit when c2%notfound;
    g_num_dbi_445_p445:=g_num_dbi_445_p445+1;
  end loop;
  close c2;
  g_num_dbi_445_p445:=g_num_dbi_445_p445-1;
  if g_debug then
    write_to_log_file_n('g_num_dbi_445_p445='||g_num_dbi_445_p445);
  end if;
  ---year
  l_stmt:='select year445_id col1,year445_id col2,name, start_date, end_date from fii_time_year445 order by year445_id';
  if g_debug then
    write_to_log_file_n(l_stmt);
  end if;
  open c3 for l_stmt;
  loop
    fetch c3 into
      g_dbi_445_year(g_num_dbi_445_year).year445_id,
      g_dbi_445_year(g_num_dbi_445_year).sequence,
      g_dbi_445_year(g_num_dbi_445_year).name,
      g_dbi_445_year(g_num_dbi_445_year).start_date,
      g_dbi_445_year(g_num_dbi_445_year).end_date;
    exit when c3%notfound;
    g_num_dbi_445_year:=g_num_dbi_445_year+1;
  end loop;
  close c3;
  g_num_dbi_445_year:=g_num_dbi_445_year-1;
  if g_debug then
    write_to_log_file_n('g_num_dbi_445_year='||g_num_dbi_445_year);
  end if;
  ---
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in loadmem_445_full '||g_status_message||get_time);
  raise;
End;

procedure loadmem_445_inc is
l_stmt varchar2(20000);
TYPE CurTyp IS REF CURSOR;
c1   CurTyp;
c2   CurTyp;
c3   CurTyp;
Begin
  ---week
  g_num_dbi_445_week:=1;
  g_num_dbi_445_p445:=1;
  g_num_dbi_445_year:=1;
  l_stmt:='select week_id,substr(week_id,1,4),substr(week_id,1,4),sequence,name, start_date, end_date from FII_TIME_WEEK
  where week_id not in (select to_number(time_fk) from bsc_sys_periods where periodicity_id=:1)
  order by week_id';
  if g_debug then
    write_to_log_file_n(l_stmt||' '||g_445_week_per_id);
  end if;
  open c1 for l_stmt using g_445_week_per_id;
  loop
    fetch c1 into
      g_dbi_445_week(g_num_dbi_445_week).week_id,
      g_dbi_445_week(g_num_dbi_445_week).year_id,
      g_dbi_445_week(g_num_dbi_445_week).ent_year_id,
      g_dbi_445_week(g_num_dbi_445_week).sequence,
      g_dbi_445_week(g_num_dbi_445_week).name,
      g_dbi_445_week(g_num_dbi_445_week).start_date,
      g_dbi_445_week(g_num_dbi_445_week).end_date;
    exit when c1%notfound;
    g_num_dbi_445_week:=g_num_dbi_445_week+1;
  end loop;
  close c1;
  g_num_dbi_445_week:=g_num_dbi_445_week-1;
  if g_debug then
    write_to_log_file_n('g_num_dbi_445_week='||g_num_dbi_445_week);
  end if;
  ---p445
  l_stmt:='select period445_id,year445_id,sequence,name, start_date, end_date from fii_time_p445
  where period445_id not in (select to_number(time_fk) from bsc_sys_periods where periodicity_id=:1)
  order by period445_id';
  if g_debug then
    write_to_log_file_n(l_stmt||' '||g_445_p445_per_id);
  end if;
  open c2 for l_stmt using g_445_p445_per_id;
  loop
    fetch c2 into
      g_dbi_445_p445(g_num_dbi_445_p445).period445_id,
      g_dbi_445_p445(g_num_dbi_445_p445).year445_id,
      g_dbi_445_p445(g_num_dbi_445_p445).sequence,
      g_dbi_445_p445(g_num_dbi_445_p445).name,
      g_dbi_445_p445(g_num_dbi_445_p445).start_date,
      g_dbi_445_p445(g_num_dbi_445_p445).end_date;
    exit when c2%notfound;
    g_num_dbi_445_p445:=g_num_dbi_445_p445+1;
  end loop;
  close c2;
  g_num_dbi_445_p445:=g_num_dbi_445_p445-1;
  if g_debug then
    write_to_log_file_n('g_num_dbi_445_p445='||g_num_dbi_445_p445);
  end if;
  ---year
  l_stmt:='select year445_id col1,year445_id col2,name, start_date, end_date from fii_time_year445
  where year445_id not in (select to_number(time_fk) from bsc_sys_periods where periodicity_id=:1)
  order by year445_id';
  if g_debug then
    write_to_log_file_n(l_stmt||' '||g_445_year_per_id);
  end if;
  open c3 for l_stmt using g_445_year_per_id;
  loop
    fetch c3 into
      g_dbi_445_year(g_num_dbi_445_year).year445_id,
      g_dbi_445_year(g_num_dbi_445_year).sequence,
      g_dbi_445_year(g_num_dbi_445_year).name,
      g_dbi_445_year(g_num_dbi_445_year).start_date,
      g_dbi_445_year(g_num_dbi_445_year).end_date;
    exit when c3%notfound;
    g_num_dbi_445_year:=g_num_dbi_445_year+1;
  end loop;
  close c3;
  g_num_dbi_445_year:=g_num_dbi_445_year-1;
  if g_debug then
    write_to_log_file_n('g_num_dbi_445_year='||g_num_dbi_445_year);
  end if;
  ---
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in loadmem_445_inc '||g_status_message||get_time);
  raise;
End;

procedure loadmem_greg_full is
/*cursor c1 is select month_id,substr(month_id,1,4),substr(month_id,6),name from FII_TIME_MONTH order by month_id;
cursor c2 is select quarter_id,year_id,substr(quarter_id,5),name from fii_time_qtr order by quarter_id;
cursor c3 is select year_id col1,year_id col2,name from fii_time_year order by year_id;*/
l_stmt varchar2(20000);
TYPE CurTyp IS REF CURSOR;
c1   CurTyp;
c2   CurTyp;
c3   CurTyp;
Begin
  ---month
  g_num_dbi_greg_period:=1;
  g_num_dbi_greg_qtr:=1;
  g_num_dbi_greg_year:=1;
  l_stmt:='select month_id,substr(month_id,1,4),substr(month_id,6),name, start_date, end_date from FII_TIME_MONTH order by month_id';
  if g_debug then
    write_to_log_file_n(l_stmt);
  end if;
  open c1 for l_stmt;
  loop
    fetch c1 into
      g_dbi_greg_period(g_num_dbi_greg_period).month_id,
      g_dbi_greg_period(g_num_dbi_greg_period).year_id,
      g_dbi_greg_period(g_num_dbi_greg_period).sequence,
      g_dbi_greg_period(g_num_dbi_greg_period).name,
      g_dbi_greg_period(g_num_dbi_greg_period).start_date,
      g_dbi_greg_period(g_num_dbi_greg_period).end_date;
    exit when c1%notfound;
    g_num_dbi_greg_period:=g_num_dbi_greg_period+1;
  end loop;
  close c1;
  g_num_dbi_greg_period:=g_num_dbi_greg_period-1;
  if g_debug then
    write_to_log_file_n('g_num_dbi_greg_period='||g_num_dbi_greg_period);
  end if;
  ---qtr
  l_stmt:='select quarter_id,year_id,substr(quarter_id,5),name, start_date, end_date from fii_time_qtr order by quarter_id';
  if g_debug then
    write_to_log_file_n(l_stmt);
  end if;
  open c2 for l_stmt;
  loop
    fetch c2 into
      g_dbi_greg_qtr(g_num_dbi_greg_qtr).quarter_id,
      g_dbi_greg_qtr(g_num_dbi_greg_qtr).year_id,
      g_dbi_greg_qtr(g_num_dbi_greg_qtr).sequence,
      g_dbi_greg_qtr(g_num_dbi_greg_qtr).name,
      g_dbi_greg_qtr(g_num_dbi_greg_qtr).start_date,
      g_dbi_greg_qtr(g_num_dbi_greg_qtr).end_date;
    exit when c2%notfound;
    g_num_dbi_greg_qtr:=g_num_dbi_greg_qtr+1;
  end loop;
  close c2;
  g_num_dbi_greg_qtr:=g_num_dbi_greg_qtr-1;
  if g_debug then
    write_to_log_file_n('g_num_dbi_greg_qtr='||g_num_dbi_greg_qtr);
  end if;
  ---year
  l_stmt:='select year_id col1,year_id col2,name, start_date, end_date from fii_time_year order by year_id';
  if g_debug then
    write_to_log_file_n(l_stmt);
  end if;
  open c3 for l_stmt;
  loop
    fetch c3 into
      g_dbi_greg_year(g_num_dbi_greg_year).year_id,
      g_dbi_greg_year(g_num_dbi_greg_year).sequence,
      g_dbi_greg_year(g_num_dbi_greg_year).name,
      g_dbi_greg_year(g_num_dbi_greg_year).start_date,
      g_dbi_greg_year(g_num_dbi_greg_year).end_date;
    exit when c3%notfound;
    g_num_dbi_greg_year:=g_num_dbi_greg_year+1;
  end loop;
  close c3;
  g_num_dbi_greg_year:=g_num_dbi_greg_year-1;
  if g_debug then
    write_to_log_file_n('g_num_dbi_greg_year='||g_num_dbi_greg_year);
  end if;
  ---
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in loadmem_greg_full '||g_status_message||get_time);
  raise;
End;

procedure loadmem_greg_inc is
/*cursor c1 is select month_id,substr(month_id,1,4),substr(month_id,6),name from FII_TIME_MONTH
where month_id not in (select to_number(time_fk) from bsc_sys_periods where periodicity_id=g_greg_period_per_id)
order by month_id;
cursor c2 is select quarter_id,year_id,substr(quarter_id,5),name from fii_time_qtr
where quarter_id not in (select to_number(time_fk) from bsc_sys_periods where periodicity_id=g_greg_qtr_per_id)
order by quarter_id;
cursor c3 is select year_id col1,year_id col2,name from fii_time_year
where year_id not in (select to_number(time_fk) from bsc_sys_periods where periodicity_id=g_greg_year_per_id)
order by year_id;*/
l_stmt varchar2(20000);
TYPE CurTyp IS REF CURSOR;
c1   CurTyp;
c2   CurTyp;
c3   CurTyp;
Begin
  ---month
  g_num_dbi_greg_period:=1;
  g_num_dbi_greg_qtr:=1;
  g_num_dbi_greg_year:=1;
  l_stmt:='select month_id,substr(month_id,1,4),substr(month_id,6),name, start_date, end_date from FII_TIME_MONTH
  where month_id not in (select to_number(time_fk) from bsc_sys_periods where periodicity_id=:1)
  order by month_id';
  if g_debug then
    write_to_log_file_n(l_stmt||' '||g_greg_period_per_id);
  end if;
  open c1 for l_stmt using g_greg_period_per_id;
  loop
    fetch c1 into
      g_dbi_greg_period(g_num_dbi_greg_period).month_id,
      g_dbi_greg_period(g_num_dbi_greg_period).year_id,
      g_dbi_greg_period(g_num_dbi_greg_period).sequence,
      g_dbi_greg_period(g_num_dbi_greg_period).name,
      g_dbi_greg_period(g_num_dbi_greg_period).start_date,
      g_dbi_greg_period(g_num_dbi_greg_period).end_date;
    exit when c1%notfound;
    g_num_dbi_greg_period:=g_num_dbi_greg_period+1;
  end loop;
  close c1;
  g_num_dbi_greg_period:=g_num_dbi_greg_period-1;
  if g_debug then
    write_to_log_file_n('g_num_dbi_greg_period='||g_num_dbi_greg_period);
  end if;
  ---qtr
  l_stmt:='select quarter_id,year_id,substr(quarter_id,5),name, start_date, end_date from fii_time_qtr
  where quarter_id not in (select to_number(time_fk) from bsc_sys_periods where periodicity_id=:1)
  order by quarter_id';
  if g_debug then
    write_to_log_file_n(l_stmt||' '||g_greg_qtr_per_id);
  end if;
  open c2 for l_stmt using g_greg_qtr_per_id;
  loop
    fetch c2 into
      g_dbi_greg_qtr(g_num_dbi_greg_qtr).quarter_id,
      g_dbi_greg_qtr(g_num_dbi_greg_qtr).year_id,
      g_dbi_greg_qtr(g_num_dbi_greg_qtr).sequence,
      g_dbi_greg_qtr(g_num_dbi_greg_qtr).name,
      g_dbi_greg_qtr(g_num_dbi_greg_qtr).start_date,
      g_dbi_greg_qtr(g_num_dbi_greg_qtr).end_date;
    exit when c2%notfound;
    g_num_dbi_greg_qtr:=g_num_dbi_greg_qtr+1;
  end loop;
  close c2;
  g_num_dbi_greg_qtr:=g_num_dbi_greg_qtr-1;
  if g_debug then
    write_to_log_file_n('g_num_dbi_greg_qtr='||g_num_dbi_greg_qtr);
  end if;
  ---year
  l_stmt:='select year_id col1,year_id col2,name, start_date, end_date from fii_time_year
  where year_id not in (select to_number(time_fk) from bsc_sys_periods where periodicity_id=:1)
  order by year_id';
  if g_debug then
    write_to_log_file_n(l_stmt||' '||g_greg_year_per_id);
  end if;
  open c3 for l_stmt using g_greg_year_per_id;
  loop
    fetch c3 into
      g_dbi_greg_year(g_num_dbi_greg_year).year_id,
      g_dbi_greg_year(g_num_dbi_greg_year).sequence,
      g_dbi_greg_year(g_num_dbi_greg_year).name,
      g_dbi_greg_year(g_num_dbi_greg_year).start_date,
      g_dbi_greg_year(g_num_dbi_greg_year).end_date;
    exit when c3%notfound;
    g_num_dbi_greg_year:=g_num_dbi_greg_year+1;
  end loop;
  close c3;
  g_num_dbi_greg_year:=g_num_dbi_greg_year-1;
  if g_debug then
    write_to_log_file_n('g_num_dbi_greg_year='||g_num_dbi_greg_year);
  end if;
  ---
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in loadmem_greg_inc '||g_status_message||get_time);
  raise;
End;

/*
we need to make week also a part of the ent calendar.
Ent calendar is treated unique
DBi hier is built into this calendar
reporting calendar module will treat any hier with
*/
procedure load_dbi_ent_cal is
----
l_ent_current_year number;
l_ent_start_month number;
l_ent_start_day number;
--
l_year number;
l_qtr number;
l_period number;
----
l_xtd_pattern varchar2(4000);
----
--all these translated
l_cal_name varchar2(400);
l_name varchar2(400);
l_source_lang varchar2(100);
---
Begin
  if g_debug then
    write_to_log_file_n('In load_dbi_ent_cal'||get_time);
  end if;
  l_ent_current_year:=to_number(to_char(g_ent_start_date,'YYYY'));
  l_ent_start_month:=to_number(to_char(g_ent_start_date,'MM'));
  l_ent_start_day:=to_number(to_char(g_ent_start_date,'DD'));
  if g_debug then
    write_to_log_file_n('l_ent_current_year='||l_ent_current_year||',l_ent_start_month='||
    l_ent_start_month||',l_ent_start_day='||l_ent_start_day);
  end if;
  --cal
  --for ENT calendar, the EDW_CALENDAR_TYPE_ID is set to 2.
  --for period 445 and greg , this flag is set to 1
  insert into bsc_sys_calendars_b(CALENDAR_ID,EDW_FLAG,EDW_CALENDAR_ID,EDW_CALENDAR_TYPE_ID,
  FISCAL_YEAR,FISCAL_CHANGE,RANGE_YR_MOD,CURRENT_YEAR,START_MONTH,START_DAY,CREATED_BY,CREATION_DATE,
  LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN, short_name) values (
  g_ent_cal_id,0,1001,1,g_bsc_greg_fiscal_year,g_ent_fiscal_change,0,l_ent_current_year,
  l_ent_start_month,l_ent_start_day,g_who,sysdate,g_who,sysdate,g_who, 'TIME');
  --cal TL
  l_cal_name:=get_lookup_value('BSC_DBI_CAL_NAME','ENT_CALENDAR_NAME',g_src_lang,l_source_lang);
  --FND_MESSAGE.SET_NAME('BSC','BSC_DBI_ENT_CALENDAR_NAME');
  --l_cal_name:=FND_MESSAGE.GET;
  if g_debug then
    write_to_log_file_n('cal name='||l_cal_name);
  end if;
  for i in 1..g_num_lang loop
    l_cal_name:=get_lookup_value('BSC_DBI_CAL_NAME','ENT_CALENDAR_NAME',g_lang(i),l_source_lang); --BugFix#4043934
    insert into bsc_sys_calendars_tl(CALENDAR_ID,LANGUAGE,SOURCE_LANG,NAME,HELP,
    CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
    values(g_ent_cal_id,g_lang(i),l_source_lang,l_cal_name,l_cal_name,g_who,sysdate,g_who,sysdate,g_who);
  end loop;
  /*
  need to fill later
  */
  --bsc_sys_periodicity
  l_xtd_pattern:=','||g_ent_year_per_id||','||g_ent_qtr_per_id||','||g_ent_period_per_id||','||
  g_ent_day_per_id||',:225;';
  l_xtd_pattern:=l_xtd_pattern||','||g_ent_year_per_id||','||g_ent_qtr_per_id||','||g_ent_period_per_id||','||
  g_ent_week_per_id||','||g_ent_day_per_id||',:1143;';
  insert into bsc_sys_periodicities(PERIODICITY_ID,NUM_OF_PERIODS,SOURCE,NUM_OF_SUBPERIODS,
  PERIOD_COL_NAME,SUBPERIOD_COL_NAME,YEARLY_FLAG,EDW_FLAG,CALENDAR_ID,EDW_PERIODICITY_ID,
  CUSTOM_CODE,DB_COLUMN_NAME,PERIODICITY_TYPE,PERIOD_TYPE_ID,RECORD_TYPE_ID,XTD_PATTERN, short_name) values (
  g_ent_day_per_id,365,null,0,'PERIOD',null,0,0,g_ent_cal_id,0,1,'DAY365',9,1,1,l_xtd_pattern, 'FII_TIME_DAY');
  --FND_MESSAGE.SET_NAME('BSC','BSC_DBI_ENT_DAY_NAME');
  l_name:=get_bis_dim_long_name('FII_TIME_DAY',g_src_lang,l_source_lang);
  if g_debug then
    write_to_log_file_n('periodicity name DBI ent day='||l_name);
  end if;
  for i in 1..g_num_lang loop
    l_name:=get_bis_dim_long_name('FII_TIME_DAY',g_lang(i),l_source_lang);
    insert into bsc_sys_periodicities_tl(PERIODICITY_ID,LANGUAGE,SOURCE_LANG,NAME,CREATED_BY,
    CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
    values(g_ent_day_per_id,g_lang(i),l_source_lang,l_name,g_who,sysdate,g_who,sysdate,g_who);
  end loop;
  --
  --week
  l_xtd_pattern:=','||g_ent_year_per_id||','||g_ent_qtr_per_id||','||g_ent_period_per_id||','||
  g_ent_day_per_id||',:1;';
  l_xtd_pattern:=l_xtd_pattern||','||g_ent_year_per_id||','||g_ent_qtr_per_id||','||g_ent_period_per_id||','||
  g_ent_week_per_id||','||g_ent_day_per_id||',:11;';
  insert into bsc_sys_periodicities(PERIODICITY_ID,NUM_OF_PERIODS,SOURCE,NUM_OF_SUBPERIODS,
  PERIOD_COL_NAME,SUBPERIOD_COL_NAME,YEARLY_FLAG,EDW_FLAG,CALENDAR_ID,EDW_PERIODICITY_ID,
  CUSTOM_CODE,DB_COLUMN_NAME,PERIODICITY_TYPE,PERIOD_TYPE_ID,RECORD_TYPE_ID,XTD_PATTERN, short_name) values (
  g_ent_week_per_id,52,g_ent_day_per_id,0,'PERIOD',null,0,0,g_ent_cal_id,0,2,'WEEK52',7,16,16,l_xtd_pattern, 'FII_TIME_WEEK');
  --FND_MESSAGE.SET_NAME('BSC','BSC_DBI_ENT_WEEK_NAME');
  l_name:=get_bis_dim_long_name('FII_TIME_WEEK',g_src_lang,l_source_lang);
  if g_debug then
    write_to_log_file_n('periodicity name DBI ent week='||l_name);
  end if;
  for i in 1..g_num_lang loop
    l_name:=get_bis_dim_long_name('FII_TIME_WEEK',g_lang(i),l_source_lang);
    insert into bsc_sys_periodicities_tl(PERIODICITY_ID,LANGUAGE,SOURCE_LANG,NAME,CREATED_BY,
    CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
    values(g_ent_week_per_id,g_lang(i),l_source_lang,l_name,g_who,sysdate,g_who,sysdate,g_who);
  end loop;
  --
  --period
  l_xtd_pattern:=','||g_ent_year_per_id||','||g_ent_qtr_per_id||','||g_ent_period_per_id||','||
  g_ent_day_per_id||',:1;';
  l_xtd_pattern:=l_xtd_pattern||','||g_ent_year_per_id||','||g_ent_qtr_per_id||','||g_ent_period_per_id||','||
  g_ent_week_per_id||','||g_ent_day_per_id||',:23;';
  insert into bsc_sys_periodicities(PERIODICITY_ID,NUM_OF_PERIODS,SOURCE,NUM_OF_SUBPERIODS,
  PERIOD_COL_NAME,SUBPERIOD_COL_NAME,YEARLY_FLAG,EDW_FLAG,CALENDAR_ID,EDW_PERIODICITY_ID,
  CUSTOM_CODE,DB_COLUMN_NAME,PERIODICITY_TYPE,PERIOD_TYPE_ID,RECORD_TYPE_ID,XTD_PATTERN, short_name) values (
  g_ent_period_per_id,12,g_ent_day_per_id,0,'PERIOD',null,0,0,g_ent_cal_id,0,2,'MONTH',5,32,32,l_xtd_pattern, 'FII_TIME_ENT_PERIOD');
  --FND_MESSAGE.SET_NAME('BSC','BSC_DBI_ENT_PERIOD_NAME');
  l_name:=get_bis_dim_long_name('FII_TIME_ENT_PERIOD',g_src_lang,l_source_lang);
  if g_debug then
    write_to_log_file_n('periodicity name DBI ent period='||l_name);
  end if;
  for i in 1..g_num_lang loop
    l_name:=get_bis_dim_long_name('FII_TIME_ENT_PERIOD',g_lang(i),l_source_lang);
    insert into bsc_sys_periodicities_tl(PERIODICITY_ID,LANGUAGE,SOURCE_LANG,NAME,CREATED_BY,
    CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
    values(g_ent_period_per_id,g_lang(i),l_source_lang,l_name,g_who,sysdate,g_who,sysdate,g_who);
  end loop;
  --
  l_xtd_pattern:=','||g_ent_year_per_id||','||g_ent_qtr_per_id||','||g_ent_period_per_id||','||
  g_ent_day_per_id||',:33;';
  l_xtd_pattern:=l_xtd_pattern||','||g_ent_year_per_id||','||g_ent_qtr_per_id||','||g_ent_period_per_id||','||
  g_ent_week_per_id||','||g_ent_day_per_id||',:55;';
  insert into bsc_sys_periodicities(PERIODICITY_ID,NUM_OF_PERIODS,SOURCE,NUM_OF_SUBPERIODS,
  PERIOD_COL_NAME,SUBPERIOD_COL_NAME,YEARLY_FLAG,EDW_FLAG,CALENDAR_ID,EDW_PERIODICITY_ID,
  CUSTOM_CODE,DB_COLUMN_NAME,PERIODICITY_TYPE,PERIOD_TYPE_ID,RECORD_TYPE_ID,XTD_PATTERN, short_name) values (
  g_ent_qtr_per_id,4,g_ent_period_per_id,0,'PERIOD',null,0,0,g_ent_cal_id,0,2,'QUARTER',3,64,64,l_xtd_pattern, 'FII_TIME_ENT_QTR');
  --FND_MESSAGE.SET_NAME('BSC','BSC_DBI_ENT_QTR_NAME');
  l_name:=get_bis_dim_long_name('FII_TIME_ENT_QTR',g_src_lang,l_source_lang);
  if g_debug then
    write_to_log_file_n('periodicity name DBI ent qtr='||l_name);
  end if;
  for i in 1..g_num_lang loop
    l_name:=get_bis_dim_long_name('FII_TIME_ENT_QTR',g_lang(i),l_source_lang);
    insert into bsc_sys_periodicities_tl(PERIODICITY_ID,LANGUAGE,SOURCE_LANG,NAME,CREATED_BY,
    CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
    values(g_ent_qtr_per_id,g_lang(i),l_source_lang,l_name,g_who,sysdate,g_who,sysdate,g_who);
  end loop;
  --
  l_xtd_pattern:=','||g_ent_year_per_id||','||g_ent_qtr_per_id||','||g_ent_period_per_id||','||
  g_ent_day_per_id||',:97;';
  l_xtd_pattern:=l_xtd_pattern||','||g_ent_year_per_id||','||g_ent_qtr_per_id||','||g_ent_period_per_id||','||
  g_ent_week_per_id||','||g_ent_day_per_id||',:119;';
  insert into bsc_sys_periodicities(PERIODICITY_ID,NUM_OF_PERIODS,SOURCE,NUM_OF_SUBPERIODS,
  PERIOD_COL_NAME,SUBPERIOD_COL_NAME,YEARLY_FLAG,EDW_FLAG,CALENDAR_ID,EDW_PERIODICITY_ID,
  CUSTOM_CODE,DB_COLUMN_NAME,PERIODICITY_TYPE,PERIOD_TYPE_ID,RECORD_TYPE_ID,XTD_PATTERN, short_name) values (
  g_ent_year_per_id,1,g_ent_qtr_per_id,0,'PERIOD',null,1,0,g_ent_cal_id,0,2,'YEAR',1,128,128,l_xtd_pattern, 'FII_TIME_ENT_YEAR');
  --FND_MESSAGE.SET_NAME('BSC','BSC_DBI_ENT_YEAR_NAME');
  l_name:=get_bis_dim_long_name('FII_TIME_ENT_YEAR',g_src_lang,l_source_lang);
  if g_debug then
    write_to_log_file_n('periodicity name DBI ent year='||l_name);
  end if;
  for i in 1..g_num_lang loop
    l_name:=get_bis_dim_long_name('FII_TIME_ENT_YEAR',g_lang(i),l_source_lang);
    insert into bsc_sys_periodicities_tl(PERIODICITY_ID,LANGUAGE,SOURCE_LANG,NAME,CREATED_BY,
    CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
    values(g_ent_year_per_id,g_lang(i),l_source_lang,l_name,g_who,sysdate,g_who,sysdate,g_who);
  end loop;
  --
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in load_dbi_ent_cal '||g_status_message||get_time);
  raise;
End;

procedure load_dbi_ent_cal_data is
l_prev_qtr number;
l_prev_period number;
--
l_days_in_year number;
l_year number;
l_qtr number;
l_period number;
l_day number;
l_week number;
--l_week_past_52 boolean;
--l_week_year_change boolean;
--
Begin
  --bsc_sys_periods
  --ent day info
  --l_day:=get_day365(g_ent_start_date,g_dbi_cal_record(1).report_date)-1; ---1 because we inc day before insert
  --if l_day is null then
    --raise g_exception;
  --end if;
  --populate bsc_sys_periods and bsc_db_calendar for DAY
  l_prev_qtr:=0;
  l_prev_period:=0;
  --3990678 the fix for this bug has made l_week_past_52 and l_week_year_change obsolete
  --l_week_past_52:=false;
  --l_week_year_change:=false;
  for i in 1..g_num_dbi_cal_record loop
    l_year:=substr(g_dbi_cal_record(i).ent_period_id,1,4);
    l_qtr:=substr(g_dbi_cal_record(i).ent_period_id,5,1);
    l_period:=substr(g_dbi_cal_record(i).ent_period_id,6);
    --l_week:=substr(g_dbi_cal_record(i).week_id,7);
    --3990678
    l_week:=g_dbi_cal_record(i).ent_week_id;
    l_day:=g_dbi_cal_record(i).ent_day;
    --if l_week=52 then
      --l_week_past_52:=true;
    --end if;
    --if l_prev_period<>0 and l_prev_qtr<>0 and
      --l_period=1 and l_period<>l_prev_period and l_qtr=1 and l_qtr<>l_prev_qtr then
      --l_day:=1;
      --l_week_past_52:=false;
      --l_week_year_change:=true;
    --else
      --l_day:=l_day+1;
    --end if;
    --correct_ent_week has obsoleted the need for l_week_year_change and l_week_past_52
    --if l_week_past_52 and l_week=1 then
      --l_week:=53;
    --end if;
    --if l_week_year_change and l_week<52 then
      --l_week_year_change:=false;
    --end if;
    --if l_week_year_change and l_week>=52 then
      --l_week:=1;
    --end if;
    --insert into bsc_sys_periods
    --time_fk is in MM/DD/YYYY format
    insert into bsc_sys_periods(PERIODICITY_ID,YEAR,PERIOD_ID,START_DATE,END_DATE,START_PERIOD,
    END_PERIOD,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,TIME_FK)
    values(g_ent_day_per_id,l_year,l_day, g_dbi_cal_record(i).start_date, g_dbi_cal_record(i).end_date, null,null,g_who,sysdate,g_who,sysdate,g_who,
    g_dbi_cal_record(i).cal_month||'/'||g_dbi_cal_record(i).cal_day||'/'||g_dbi_cal_record(i).cal_year);
    for j in 1..g_num_lang loop
      insert into bsc_sys_periods_tl(YEAR,PERIODICITY_ID,PERIOD_ID,MONTH,LANGUAGE,SOURCE_LANG,NAME,SHORT_NAME)
      values(l_year,g_ent_day_per_id,l_day,1,g_lang(j),g_src_lang,g_dbi_cal_record(i).report_date,null);
    end loop;
    --insert into bsc_db_calendar
    g_db_cal_modified:=true;
    insert into bsc_db_calendar(CALENDAR_YEAR,CALENDAR_MONTH,CALENDAR_DAY,YEAR,SEMESTER,
    QUARTER,BIMESTER,MONTH,WEEK52,WEEK4,DAY365,DAY30,HOLYDAY_FLAG,WORKDAY_FLAG,CALENDAR_ID)
    values(g_dbi_cal_record(i).cal_year,g_dbi_cal_record(i).cal_month,g_dbi_cal_record(i).cal_day,
    l_year,0,l_qtr,0,l_period,l_week,0,l_day,0,null,null,g_ent_cal_id);
    --CUSTOM_1,CUSTOM_2,CUSTOM_3,CUSTOM_4)
    --l_day,l_week,l_period,l_qtr);
    ----
    l_prev_qtr:=l_qtr;
    l_prev_period:=l_period;
  end loop;
  --
  --populate bsc_sys_periods for WEEK. for week, we dont populate bsc_db_calendar
  for i in 1..g_num_dbi_445_week loop
    --3990678
    insert into bsc_sys_periods(PERIODICITY_ID,YEAR,PERIOD_ID,START_DATE,END_DATE,START_PERIOD,
    END_PERIOD,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,TIME_FK)
    values(g_ent_week_per_id,g_dbi_445_week(i).ent_year_id,g_dbi_445_week(i).ent_week_id, g_dbi_445_week(i).start_date, g_dbi_445_week(i).end_date, null,null,
    g_who,sysdate,g_who,sysdate,g_who,g_dbi_445_week(i).week_id);
    --values(g_ent_week_per_id,g_dbi_445_week(i).year_id,g_dbi_445_week(i).sequence,null,null,null,null,
    --g_who,sysdate,g_who,sysdate,g_who,g_dbi_445_week(i).week_id);
    for j in 1..g_num_lang loop
      insert into bsc_sys_periods_tl(YEAR,PERIODICITY_ID,PERIOD_ID,MONTH,LANGUAGE,SOURCE_LANG,NAME,SHORT_NAME)
      values(g_dbi_445_week(i).ent_year_id,g_ent_week_per_id,g_dbi_445_week(i).ent_week_id,1,g_lang(j),
      g_src_lang,g_dbi_445_week(i).name,null);
    end loop;
  end loop;
  --3990678
  --insert the extra weeks
  if g_num_ent_week is not null and g_num_ent_week>0 then
    for i in 1..g_num_ent_week loop
      insert into bsc_sys_periods(PERIODICITY_ID,YEAR,PERIOD_ID,START_DATE,END_DATE,START_PERIOD,
      END_PERIOD,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,TIME_FK)
      values(g_ent_week_per_id,g_ent_week(i).ent_year_id,g_ent_week(i).ent_week_id, g_ent_week(i).start_date, g_ent_week(i).end_date, null,null,
      g_who,sysdate,g_who,sysdate,g_who,g_ent_week(i).week_id);
      for j in 1..g_num_lang loop
        insert into bsc_sys_periods_tl(YEAR,PERIODICITY_ID,PERIOD_ID,MONTH,LANGUAGE,SOURCE_LANG,NAME,SHORT_NAME)
        values(g_ent_week(i).ent_year_id,g_ent_week_per_id,g_ent_week(i).ent_week_id,1,g_lang(j),
        g_src_lang,g_ent_week(i).name,null);
        end loop;
    end loop;
  end if;
  --
  --populate bsc_sys_periods for PERIOD. for period, we dont populate bsc_db_calendar
  --cursor c1 is select ent_period_id,ent_year_id,sequence from FII_TIME_ENT_PERIOD order by ent_period_id;
  for i in 1..g_num_dbi_ent_period loop
    insert into bsc_sys_periods(PERIODICITY_ID,YEAR,PERIOD_ID,START_DATE,END_DATE,START_PERIOD,
    END_PERIOD,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,TIME_FK)
    values(g_ent_period_per_id,g_dbi_ent_period(i).ent_year_id,g_dbi_ent_period(i).sequence,
    g_dbi_ent_period(i).start_date, g_dbi_ent_period(i).end_date,null,null,
    g_who,sysdate,g_who,sysdate,g_who,g_dbi_ent_period(i).ent_period_id);
    for j in 1..g_num_lang loop
      insert into bsc_sys_periods_tl(YEAR,PERIODICITY_ID,PERIOD_ID,MONTH,LANGUAGE,SOURCE_LANG,NAME,SHORT_NAME)
      values(g_dbi_ent_period(i).ent_year_id,g_ent_period_per_id,g_dbi_ent_period(i).sequence,1,
      g_lang(j),g_src_lang,g_dbi_ent_period(i).name,null);
    end loop;
  end loop;
  --populate bsc_sys_periods for QTR. for qtr, we dont populate bsc_db_calendar
  --cursor c2 is select ent_qtr_id,ent_year_id,sequence from FII_TIME_ENT_QTR order by ent_qtr_id;
  for i in 1..g_num_dbi_ent_qtr loop
    insert into bsc_sys_periods(PERIODICITY_ID,YEAR,PERIOD_ID,START_DATE,END_DATE,START_PERIOD,
    END_PERIOD,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,TIME_FK)
    values(g_ent_qtr_per_id,g_dbi_ent_qtr(i).ent_year_id,g_dbi_ent_qtr(i).sequence, g_dbi_ent_qtr(i).start_date, g_dbi_ent_qtr(i).end_date, null,null,
    g_who,sysdate,g_who,sysdate,g_who,g_dbi_ent_qtr(i).ent_qtr_id);
    for j in 1..g_num_lang loop
      insert into bsc_sys_periods_tl(YEAR,PERIODICITY_ID,PERIOD_ID,MONTH,LANGUAGE,SOURCE_LANG,NAME,SHORT_NAME)
      values(g_dbi_ent_qtr(i).ent_year_id,g_ent_qtr_per_id,g_dbi_ent_qtr(i).sequence,1,
      g_lang(j),g_src_lang,g_dbi_ent_qtr(i).name,null);
    end loop;
  end loop;
  --populate bsc_sys_periods for YEAR. for year, we dont populate bsc_db_calendar
  --cursor c3 is select ent_year_id,sequence from FII_TIME_ENT_YEAR order by ent_year_id;
  for i in 1..g_num_dbi_ent_year loop
    insert into bsc_sys_periods(PERIODICITY_ID,YEAR,PERIOD_ID,START_DATE,END_DATE,START_PERIOD,
    END_PERIOD,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,TIME_FK)
    values(g_ent_year_per_id,g_dbi_ent_year(i).sequence,g_dbi_ent_year(i).sequence, g_dbi_ent_year(i).start_date, g_dbi_ent_year(i).end_date, null,null,
    g_who,sysdate,g_who,sysdate,g_who,g_dbi_ent_year(i).ent_year_id);
    for j in 1..g_num_lang loop
      insert into bsc_sys_periods_tl(YEAR,PERIODICITY_ID,PERIOD_ID,MONTH,LANGUAGE,SOURCE_LANG,NAME,SHORT_NAME)
      values(g_dbi_ent_year(i).sequence,g_ent_year_per_id,g_dbi_ent_year(i).sequence,1,
      g_lang(j),g_src_lang,g_dbi_ent_year(i).name,null);
    end loop;
  end loop;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in load_dbi_ent_cal_data '||g_status_message||get_time);
  raise;
End;

procedure load_dbi_445_cal is
----
l_445_current_year number;
l_445_start_month number;
l_445_start_day number;
----
l_year number;
l_p445 number;
l_week number;
--
l_xtd_pattern varchar2(4000);
----
l_cal_name varchar2(400);
l_name varchar2(400);
l_source_lang varchar2(100);
---
 x_Return_Status varchar2(1000);
 x_msg_count number;
 x_msg_data varchar2(1000);
Begin
  if g_debug then
    write_to_log_file_n('In load_dbi_445_cal'||get_time);
  end if;
  --Enh 4530872
  if (g_445_cal_short_name is null) then
    g_445_cal_short_name := generate_short_name;
    if create_dim(g_445_cal_short_name, x_msg_data) then
      null;
    else
      g_status_message := 'Unable to create TIME_445 dimension:'||g_445_cal_short_name||':'||x_msg_data;
      raise g_exception;
    end if;
  end if;
  -- Get short name of 445 day
  if (g_445_day_short_name is null) then
    g_445_day_short_name := generate_short_name;
    if create_dim_obj(g_445_day_short_name, g_445_cal_short_name, 'FII_TIME_DAY_V', x_msg_data) then
      null;
    else
      g_status_message := 'Unable to create TIME_DAY_445 level:'||g_445_day_short_name||':'||x_msg_data;
      raise g_exception;
    end if;
  end if;

  if (g_445_week_short_name is null) then
    g_445_week_short_name := generate_short_name;
    if create_dim_obj(g_445_week_short_name, g_445_cal_short_name, 'FII_TIME_WEEK_V', x_msg_data) then
      null;
    else
      g_status_message := 'Unable to create TIME_WEEK445 level:'||g_445_week_short_name||':'||x_msg_data;
      raise g_exception;
    end if;
  end if;

  if (g_445_p445_short_name is null) then
    g_445_p445_short_name := generate_short_name;
    if create_dim_obj( g_445_p445_short_name , g_445_cal_short_name, 'FII_TIME_P445_V', x_msg_data) then
      null;
    else
      g_status_message := 'Unable to create TIME_P445 level:'||g_445_cal_short_name||':'||x_msg_data;
      raise g_exception;
    end if;
  end if;

  if (g_445_year_short_name is null) then
    g_445_year_short_name := generate_short_name;
    if create_dim_obj(g_445_year_short_name, g_445_cal_short_name, 'FII_TIME_YEAR445_V', x_msg_data) then
      null;
    else
      g_status_message := 'Unable to create TIME_YEAR445 level:'||g_445_year_short_name||':'||x_msg_data;
      raise g_exception;
    end if;
  end if;

  l_445_current_year:=to_number(to_char(g_445_start_date,'YYYY'));
  l_445_start_month:=to_number(to_char(g_445_start_date,'MM'));
  l_445_start_day:=to_number(to_char(g_445_start_date,'DD'));
  if g_debug then
    write_to_log_file_n('l_445_current_year='||l_445_current_year||',l_445_start_month='||
    l_445_start_month||',l_445_start_day='||l_445_start_day);
  end if;

  /* CREATE 445 CALENDAR */

  insert into bsc_sys_calendars_b(CALENDAR_ID,EDW_FLAG,EDW_CALENDAR_ID,EDW_CALENDAR_TYPE_ID,
  FISCAL_YEAR,FISCAL_CHANGE,RANGE_YR_MOD,CURRENT_YEAR,START_MONTH,START_DAY,CREATED_BY,CREATION_DATE,
  LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN, SHORT_NAME) values (
  g_445_cal_id,0,1002,1,g_bsc_greg_fiscal_year,g_445_fiscal_change,0,l_445_current_year,
  l_445_start_month,l_445_start_day,g_who,sysdate,g_who,sysdate,g_who, g_445_cal_short_name);
  --cal TL
  l_cal_name:=get_lookup_value('BSC_DBI_CAL_NAME','P445_CALENDAR_NAME',g_src_lang,l_source_lang);
  --FND_MESSAGE.SET_NAME('BSC','BSC_DBI_445_CALENDAR_NAME');
  --l_cal_name:=FND_MESSAGE.GET;
  if g_debug then
    write_to_log_file_n('cal name='||l_cal_name);
  end if;
  for i in 1..g_num_lang loop
    l_cal_name:=get_lookup_value('BSC_DBI_CAL_NAME','P445_CALENDAR_NAME',g_lang(i),l_source_lang);
    insert into bsc_sys_calendars_tl(CALENDAR_ID,LANGUAGE,SOURCE_LANG,NAME,HELP,
    CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
    values(g_445_cal_id,g_lang(i),l_source_lang,l_cal_name,l_cal_name,g_who,sysdate,g_who,sysdate,g_who);
  end loop;
  /*
  need to fill later
  */
  --bsc_sys_periodicity
  l_xtd_pattern:=','||g_445_year_per_id||','||g_445_p445_per_id||','||g_445_week_per_id||','||
  g_445_day_per_id||',:177;';

  /* INSERT 445 DAY PERIODICITY */

  insert into bsc_sys_periodicities(PERIODICITY_ID,NUM_OF_PERIODS,SOURCE,NUM_OF_SUBPERIODS,
  PERIOD_COL_NAME,SUBPERIOD_COL_NAME,YEARLY_FLAG,EDW_FLAG,CALENDAR_ID,EDW_PERIODICITY_ID,
  CUSTOM_CODE,DB_COLUMN_NAME,PERIODICITY_TYPE,PERIOD_TYPE_ID,RECORD_TYPE_ID,XTD_PATTERN, short_name) values (
  g_445_day_per_id,365,null,0,'PERIOD',null,0,0,g_445_cal_id,0,1,'CUSTOM_1',9,1,1,l_xtd_pattern, g_445_day_short_name);
  --FND_MESSAGE.SET_NAME('BSC','BSC_DBI_445_DAY_NAME');
  l_name:=get_bis_dim_long_name('FII_TIME_DAY',g_src_lang,l_source_lang);
  if g_debug then
    write_to_log_file_n('periodicity name DBI 445 day='||l_name);
  end if;
  for i in 1..g_num_lang loop
    l_name:=get_bis_dim_long_name('FII_TIME_DAY',g_lang(i),l_source_lang);
    insert into bsc_sys_periodicities_tl(PERIODICITY_ID,LANGUAGE,SOURCE_LANG,NAME,CREATED_BY,
    CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
    values(g_445_day_per_id,g_lang(i),l_source_lang,l_name,g_who,sysdate,g_who,sysdate,g_who);
  end loop;
  --
  l_xtd_pattern:=','||g_445_year_per_id||','||g_445_p445_per_id||','||g_445_week_per_id||','||
  g_445_day_per_id||',:1;';

  insert into bsc_sys_periodicities(PERIODICITY_ID,NUM_OF_PERIODS,SOURCE,NUM_OF_SUBPERIODS,
  PERIOD_COL_NAME,SUBPERIOD_COL_NAME,YEARLY_FLAG,EDW_FLAG,CALENDAR_ID,EDW_PERIODICITY_ID,
  CUSTOM_CODE,DB_COLUMN_NAME,PERIODICITY_TYPE,PERIOD_TYPE_ID,RECORD_TYPE_ID,XTD_PATTERN, short_name) values (
  g_445_week_per_id,52,g_445_day_per_id,0,'PERIOD',null,0,0,g_445_cal_id,0,2,'CUSTOM_2',0,16,16,l_xtd_pattern, g_445_week_short_name);
  --FND_MESSAGE.SET_NAME('BSC','BSC_DBI_445_WEEK_NAME');
  l_name:=get_bis_dim_long_name('FII_TIME_WEEK',g_src_lang,l_source_lang);
  if g_debug then
    write_to_log_file_n('periodicity name DBI 445 week='||l_name);
  end if;
  for i in 1..g_num_lang loop
    l_name:=get_bis_dim_long_name('FII_TIME_WEEK',g_lang(i),l_source_lang);
    insert into bsc_sys_periodicities_tl(PERIODICITY_ID,LANGUAGE,SOURCE_LANG,NAME,CREATED_BY,
    CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
    values(g_445_week_per_id,g_lang(i),l_source_lang,l_name,g_who,sysdate,g_who,sysdate,g_who);
  end loop;
  --
  l_xtd_pattern:=','||g_445_year_per_id||','||g_445_p445_per_id||','||g_445_week_per_id||','||
  g_445_day_per_id||',:17;';

  insert into bsc_sys_periodicities(PERIODICITY_ID,NUM_OF_PERIODS,SOURCE,NUM_OF_SUBPERIODS,
  PERIOD_COL_NAME,SUBPERIOD_COL_NAME,YEARLY_FLAG,EDW_FLAG,CALENDAR_ID,EDW_PERIODICITY_ID,
  CUSTOM_CODE,DB_COLUMN_NAME,PERIODICITY_TYPE,PERIOD_TYPE_ID,RECORD_TYPE_ID,XTD_PATTERN, short_name) values (
  g_445_p445_per_id,12,g_445_week_per_id,0,'PERIOD',null,0,0,g_445_cal_id,0,2,'CUSTOM_3',0,32,32,l_xtd_pattern, g_445_p445_short_name);

  l_name:=get_bis_dim_long_name('FII_TIME_P445',g_src_lang,l_source_lang);
  if g_debug then
    write_to_log_file_n('periodicity name DBI 445 p445='||l_name);
  end if;
  for i in 1..g_num_lang loop
    l_name:=get_bis_dim_long_name('FII_TIME_P445',g_lang(i),l_source_lang);
    insert into bsc_sys_periodicities_tl(PERIODICITY_ID,LANGUAGE,SOURCE_LANG,NAME,CREATED_BY,
    CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
    values(g_445_p445_per_id,g_lang(i),l_source_lang,l_name,g_who,sysdate,g_who,sysdate,g_who);
  end loop;
  --
  l_xtd_pattern:=','||g_445_year_per_id||','||g_445_p445_per_id||','||g_445_week_per_id||','||
  g_445_day_per_id||',:49;';

  insert into bsc_sys_periodicities(PERIODICITY_ID,NUM_OF_PERIODS,SOURCE,NUM_OF_SUBPERIODS,
  PERIOD_COL_NAME,SUBPERIOD_COL_NAME,YEARLY_FLAG,EDW_FLAG,CALENDAR_ID,EDW_PERIODICITY_ID,
  CUSTOM_CODE,DB_COLUMN_NAME,PERIODICITY_TYPE,PERIOD_TYPE_ID,RECORD_TYPE_ID,XTD_PATTERN, short_name) values (
  g_445_year_per_id,1,g_445_p445_per_id,0,'PERIOD',null,1,0,g_445_cal_id,0,2,'YEAR',1,128,128,l_xtd_pattern, g_445_year_short_name);
  l_name:=get_bis_dim_long_name('FII_TIME_YEAR445',g_src_lang,l_source_lang);
  if g_debug then
    write_to_log_file_n('periodicity name DBI 445 year='||l_name);
  end if;
  for i in 1..g_num_lang loop
    l_name:=get_bis_dim_long_name('FII_TIME_YEAR445',g_lang(i),l_source_lang);
    insert into bsc_sys_periodicities_tl(PERIODICITY_ID,LANGUAGE,SOURCE_LANG,NAME,CREATED_BY,
    CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
    values(g_445_year_per_id,g_lang(i),l_source_lang,l_name,g_who,sysdate,g_who,sysdate,g_who);
  end loop;
  -----


Exception when others then
  g_status_message:=g_status_message||' '||sqlerrm;
  write_to_log_file_n('Error in load_dbi_445_cal '||g_status_message||get_time);
  raise;
End;

procedure load_dbi_445_cal_data is
--
l_prev_p445 number;
l_prev_week number;
l_days_in_year number;
l_year number;
l_p445 number;
l_week number;
l_day number;
--
Begin
  --l_day:=get_day365(g_445_start_date,g_dbi_cal_record(1).report_date)-1;
  --if l_day is null then
    --raise g_exception;
  --end if;
  --populate bsc_sys_periods and bsc_db_calendar for DAY
  l_prev_p445:=0;
  l_prev_week:=0;
  for i in 1..g_num_dbi_cal_record loop
    l_year:=substr(g_dbi_cal_record(i).week_id,1,4);
    l_p445:=substr(g_dbi_cal_record(i).week_id,5,2);
    l_week:=substr(g_dbi_cal_record(i).week_id,7);
    l_day:=g_dbi_cal_record(i).p445_day;
    --if l_prev_week<>0 and l_prev_p445<>0 and
      --l_week=1 and l_week<>l_prev_week and l_p445=1 and l_p445<>l_prev_p445 then
      --l_day:=1;
   --else
      --l_day:=l_day+1;
    --end if;
    --insert into bsc_sys_periods
    --time_fk is in MM/DD/YYYY format
    insert into bsc_sys_periods(PERIODICITY_ID,YEAR,PERIOD_ID,START_DATE,END_DATE,START_PERIOD,
    END_PERIOD,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,TIME_FK)
    values(g_445_day_per_id,l_year,l_day, g_dbi_cal_record(i).start_date, g_dbi_cal_record(i).end_date, null,null,g_who,sysdate,g_who,sysdate,g_who,
    g_dbi_cal_record(i).cal_month||'/'||g_dbi_cal_record(i).cal_day||'/'||g_dbi_cal_record(i).cal_year);
    for j in 1..g_num_lang loop
      insert into bsc_sys_periods_tl(YEAR,PERIODICITY_ID,PERIOD_ID,MONTH,LANGUAGE,SOURCE_LANG,NAME,SHORT_NAME)
      values(l_year,g_445_day_per_id,l_day,1,g_lang(j),g_src_lang,g_dbi_cal_record(i).report_date,null);
    end loop;
    g_db_cal_modified:=true;
    --insert into bsc_db_calendar
    insert into bsc_db_calendar(CALENDAR_YEAR,CALENDAR_MONTH,CALENDAR_DAY,YEAR,SEMESTER,
    QUARTER,BIMESTER,MONTH,WEEK52,WEEK4,DAY365,DAY30,HOLYDAY_FLAG,WORKDAY_FLAG,CALENDAR_ID,
    CUSTOM_1,CUSTOM_2,CUSTOM_3)
    values(g_dbi_cal_record(i).cal_year,g_dbi_cal_record(i).cal_month,g_dbi_cal_record(i).cal_day,
    l_year,0,0,0,0,0,0,0,0,null,null,g_445_cal_id,l_day,l_week,l_p445);
    ----
    l_prev_p445:=l_p445;
    l_prev_week:=l_week;
  end loop;
  --populate bsc_sys_periods for PERIOD. for period, we dont populate bsc_db_calendar
  --cursor c1 is select week_id,substr(week_id,1,4),sequence from FII_TIME_WEEK order by week_id;
  for i in 1..g_num_dbi_445_week loop
    insert into bsc_sys_periods(PERIODICITY_ID,YEAR,PERIOD_ID,START_DATE,END_DATE,START_PERIOD,
    END_PERIOD,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,TIME_FK)
    values(g_445_week_per_id,g_dbi_445_week(i).year_id,g_dbi_445_week(i).sequence, g_dbi_445_week(i).start_date, g_dbi_445_week(i).end_date, null,null,
    g_who,sysdate,g_who,sysdate,g_who,g_dbi_445_week(i).week_id);
    for j in 1..g_num_lang loop
      insert into bsc_sys_periods_tl(YEAR,PERIODICITY_ID,PERIOD_ID,MONTH,LANGUAGE,SOURCE_LANG,NAME,SHORT_NAME)
      values(g_dbi_445_week(i).year_id,g_445_week_per_id,g_dbi_445_week(i).sequence,1,g_lang(j),g_src_lang,
      g_dbi_445_week(i).name,null);
    end loop;
  end loop;
  --populate bsc_sys_periods for QTR. for qtr, we dont populate bsc_db_calendar
  --cursor c2 is select period445_id,year445_id,sequence from fii_time_p445 order by period445_id;
  for i in 1..g_num_dbi_445_p445 loop
    insert into bsc_sys_periods(PERIODICITY_ID,YEAR,PERIOD_ID,START_DATE,END_DATE,START_PERIOD,
    END_PERIOD,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,TIME_FK)
    values(g_445_p445_per_id,g_dbi_445_p445(i).year445_id,g_dbi_445_p445(i).sequence, g_dbi_445_p445(i).start_date, g_dbi_445_p445(i).end_date, null,null,
    g_who,sysdate,g_who,sysdate,g_who,g_dbi_445_p445(i).period445_id);
    for j in 1..g_num_lang loop
      insert into bsc_sys_periods_tl(YEAR,PERIODICITY_ID,PERIOD_ID,MONTH,LANGUAGE,SOURCE_LANG,NAME,SHORT_NAME)
      values(g_dbi_445_p445(i).year445_id,g_445_p445_per_id,g_dbi_445_p445(i).sequence,1,g_lang(j),g_src_lang,
      g_dbi_445_p445(i).name,null);
    end loop;
  end loop;
  --populate bsc_sys_periods for YEAR. for year, we dont populate bsc_db_calendar
  --cursor c3 is select year445_id,year445_id from fii_time_year445;
  for i in 1..g_num_dbi_445_year loop
    insert into bsc_sys_periods(PERIODICITY_ID,YEAR,PERIOD_ID,START_DATE,END_DATE,START_PERIOD,
    END_PERIOD,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,TIME_FK)
    values(g_445_year_per_id,g_dbi_445_year(i).sequence,g_dbi_445_year(i).sequence, g_dbi_445_year(i).start_date, g_dbi_445_year(i).end_date, null,null,
    g_who,sysdate,g_who,sysdate,g_who,g_dbi_445_year(i).year445_id);
    for j in 1..g_num_lang loop
      insert into bsc_sys_periods_tl(YEAR,PERIODICITY_ID,PERIOD_ID,MONTH,LANGUAGE,SOURCE_LANG,NAME,SHORT_NAME)
      values(g_dbi_445_year(i).sequence,g_445_year_per_id,g_dbi_445_year(i).sequence,1,g_lang(j),g_src_lang,
      g_dbi_445_year(i).name,null);
    end loop;
  end loop;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in load_dbi_445_cal_data '||g_status_message||get_time);
  raise;
End;

procedure load_dbi_greg_cal is
----
l_greg_current_year number;
l_greg_start_month number;
l_greg_start_day number;
----
l_year number;
l_qtr number;
l_period number;
l_xtd_pattern varchar2(4000);
----
l_cal_name varchar2(400);
l_name varchar2(400);
l_source_lang varchar2(100);
---
x_msg_data varchar2(1000);

Begin
  if g_debug then
    write_to_log_file_n('In load_dbi_greg_cal'||get_time);
  end if;

  --Enh 4530872
  /*  Get short name of calendar, create dimension corresponding to calendar if it doesnt exist */
  if (g_greg_cal_short_name is null) then
    g_greg_cal_short_name := generate_short_name;
    if create_dim(g_greg_cal_short_name, x_msg_data) then
      null;
    else
      g_status_message := 'Unable to create Gregorian calendar:'||g_greg_cal_short_name||' dimension, '||x_msg_data;
      raise g_exception;
    end if;
  end if;

  /* Get short name of Greg day, create level/dim object if it doesnt exist */

  if (g_greg_day_short_name is null) then
    g_greg_day_short_name := generate_short_name;
    if create_dim_obj(g_greg_day_short_name, g_greg_cal_short_name, 'FII_TIME_DAY_V', x_msg_data) then
      null;
    else
      g_status_message := 'Unable to create TIME_DAYGREG level:'||g_greg_day_short_name||':'||x_msg_data;
      raise g_exception;
    end if;
  end if;

  -- Get short name of Greg month
  if (g_greg_period_short_name is null) then
    g_greg_period_short_name := generate_short_name;
    if create_dim_obj(g_greg_period_short_name, g_greg_cal_short_name, 'FII_TIME_MONTH_V', x_msg_data) then
      null;
    else
      g_status_message := 'Unable to create TIME_MONTHGREG level:'||g_greg_period_short_name||':'||x_msg_data;
      raise g_exception;
    end if;
  end if;

  -- Get short name of Greg quarter
  if (g_greg_qtr_short_name is null) then
    g_greg_qtr_short_name := generate_short_name;
    if create_dim_obj(g_greg_qtr_short_name, g_greg_cal_short_name, 'FII_TIME_QTR_V', x_msg_data) then
      null;
    else
      g_status_message := 'Unable to create TIME_QTRGREG level:'||g_greg_qtr_short_name||':'||x_msg_data;
      raise g_exception;
    end if;
  end if;

  -- Get short name of Greg year
  if (g_greg_year_short_name is null) then
    g_greg_year_short_name := generate_short_name;
    if create_dim_obj(g_greg_year_short_name, g_greg_cal_short_name, 'FII_TIME_YEAR_V', x_msg_data) then
      null;
    else
      g_status_message := 'Unable to create TIME_YEARGREG level:'||g_greg_year_short_name||':'||x_msg_data;
      raise g_exception;
    end if;
  end if;

  l_greg_current_year:=to_number(to_char(g_greg_start_date,'YYYY'));
  l_greg_start_month:=to_number(to_char(g_greg_start_date,'MM'));
  l_greg_start_day:=to_number(to_char(g_greg_start_date,'DD'));
  if g_debug then
    write_to_log_file_n('l_greg_current_year='||l_greg_current_year||',l_greg_start_month='||
    l_greg_start_month||',l_greg_start_day='||l_greg_start_day);
  end if;
  --cal
  insert into bsc_sys_calendars_b(CALENDAR_ID,EDW_FLAG,EDW_CALENDAR_ID,EDW_CALENDAR_TYPE_ID,
  FISCAL_YEAR,FISCAL_CHANGE,RANGE_YR_MOD,CURRENT_YEAR,START_MONTH,START_DAY,CREATED_BY,CREATION_DATE,
  LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN, SHORT_NAME) values (
  g_greg_cal_id,0,1003,1,g_bsc_greg_fiscal_year,g_greg_fiscal_change,0,l_greg_current_year,
  l_greg_start_month,l_greg_start_day,g_who,sysdate,g_who,sysdate,g_who, g_greg_cal_short_name);
  --cal TL
  l_cal_name:=get_lookup_value('BSC_DBI_CAL_NAME','GREG_CALENDAR_NAME',g_src_lang,l_source_lang);
  --FND_MESSAGE.SET_NAME('BSC','BSC_DBI_GREG_CALENDAR_NAME');
  --l_cal_name:=FND_MESSAGE.GET;
  if g_debug then
    write_to_log_file_n('cal name='||l_cal_name);
  end if;
  for i in 1..g_num_lang loop
    l_cal_name:=get_lookup_value('BSC_DBI_CAL_NAME','GREG_CALENDAR_NAME',g_lang(i),l_source_lang);
    insert into bsc_sys_calendars_tl(CALENDAR_ID,LANGUAGE,SOURCE_LANG,NAME,HELP,
    CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
    values(g_greg_cal_id,g_lang(i),l_source_lang,l_cal_name,l_cal_name,g_who,sysdate,g_who,sysdate,g_who);
  end loop;
  /*
  need to fill later
  */
  --bsc_sys_periodicity
  l_xtd_pattern:=','||g_greg_year_per_id||','||g_greg_qtr_per_id||','||g_greg_period_per_id||','||
  g_greg_day_per_id||',:225;';

  /* INSERT GREGORIAN DAY PERIODICITY */

  insert into bsc_sys_periodicities(PERIODICITY_ID,NUM_OF_PERIODS,SOURCE,NUM_OF_SUBPERIODS,
  PERIOD_COL_NAME,SUBPERIOD_COL_NAME,YEARLY_FLAG,EDW_FLAG,CALENDAR_ID,EDW_PERIODICITY_ID,
  CUSTOM_CODE,DB_COLUMN_NAME,PERIODICITY_TYPE,PERIOD_TYPE_ID,RECORD_TYPE_ID,XTD_PATTERN, short_name) values (
  g_greg_day_per_id,365,null,0,'PERIOD',null,0,0,g_greg_cal_id,0,1,'CUSTOM_1',9,1,1,l_xtd_pattern, g_greg_day_short_name);
  --FND_MESSAGE.SET_NAME('BSC','BSC_DBI_GREG_DAY_NAME');
  l_name:=get_bis_dim_long_name('FII_TIME_DAY',g_src_lang,l_source_lang);
  if g_debug then
    write_to_log_file_n('periodicity name DBI greg day='||l_name);
  end if;
  for i in 1..g_num_lang loop
    l_name:=get_bis_dim_long_name('FII_TIME_DAY',g_lang(i),l_source_lang);
    insert into bsc_sys_periodicities_tl(PERIODICITY_ID,LANGUAGE,SOURCE_LANG,NAME,CREATED_BY,
    CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
    values(g_greg_day_per_id,g_lang(i),l_source_lang,l_name,g_who,sysdate,g_who,sysdate,g_who);
  end loop;
  --
  l_xtd_pattern:=','||g_greg_year_per_id||','||g_greg_qtr_per_id||','||g_greg_period_per_id||','||
  g_greg_day_per_id||',:1;';

  /* INSERT GREGORIAN MONTH PERIODICITY */

  insert into bsc_sys_periodicities(PERIODICITY_ID,NUM_OF_PERIODS,SOURCE,NUM_OF_SUBPERIODS,
  PERIOD_COL_NAME,SUBPERIOD_COL_NAME,YEARLY_FLAG,EDW_FLAG,CALENDAR_ID,EDW_PERIODICITY_ID,
  CUSTOM_CODE,DB_COLUMN_NAME,PERIODICITY_TYPE,PERIOD_TYPE_ID,RECORD_TYPE_ID,XTD_PATTERN, short_name) values (
  g_greg_period_per_id,12,g_greg_day_per_id,0,'PERIOD',null,0,0,g_greg_cal_id,0,2,'CUSTOM_2',0,32,32,l_xtd_pattern, g_greg_period_short_name);
  --FND_MESSAGE.SET_NAME('BSC','BSC_DBI_GREG_PERIOD_NAME');
  l_name:=get_bis_dim_long_name('FII_TIME_MONTH',g_src_lang,l_source_lang);
  if g_debug then
    write_to_log_file_n('periodicity name DBI greg period='||l_name);
  end if;
  for i in 1..g_num_lang loop
    l_name:=get_bis_dim_long_name('FII_TIME_MONTH',g_lang(i),l_source_lang);
    insert into bsc_sys_periodicities_tl(PERIODICITY_ID,LANGUAGE,SOURCE_LANG,NAME,CREATED_BY,
    CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
    values(g_greg_period_per_id,g_lang(i),l_source_lang,l_name,g_who,sysdate,g_who,sysdate,g_who);
  end loop;
  --
  l_xtd_pattern:=','||g_greg_year_per_id||','||g_greg_qtr_per_id||','||g_greg_period_per_id||','||
  g_greg_day_per_id||',:33;';

  /* INSERT GREGORIAN QUARTER PERIODICITY */

  insert into bsc_sys_periodicities(PERIODICITY_ID,NUM_OF_PERIODS,SOURCE,NUM_OF_SUBPERIODS,
  PERIOD_COL_NAME,SUBPERIOD_COL_NAME,YEARLY_FLAG,EDW_FLAG,CALENDAR_ID,EDW_PERIODICITY_ID,
  CUSTOM_CODE,DB_COLUMN_NAME,PERIODICITY_TYPE,PERIOD_TYPE_ID,RECORD_TYPE_ID,XTD_PATTERN, short_name) values (
  g_greg_qtr_per_id,4,g_greg_period_per_id,0,'PERIOD',null,0,0,g_greg_cal_id,0,2,'CUSTOM_3',0,64,64,l_xtd_pattern, g_greg_qtr_short_name);
  --FND_MESSAGE.SET_NAME('BSC','BSC_DBI_GREG_QTR_NAME');
  l_name:=get_bis_dim_long_name('FII_TIME_QTR',g_src_lang,l_source_lang);
  if g_debug then
    write_to_log_file_n('periodicity name DBI greg qtr='||l_name);
  end if;
  for i in 1..g_num_lang loop
    l_name:=get_bis_dim_long_name('FII_TIME_QTR',g_lang(i),l_source_lang);
    insert into bsc_sys_periodicities_tl(PERIODICITY_ID,LANGUAGE,SOURCE_LANG,NAME,CREATED_BY,
    CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
    values(g_greg_qtr_per_id,g_lang(i),l_source_lang,l_name,g_who,sysdate,g_who,sysdate,g_who);
  end loop;
  --
  l_xtd_pattern:=','||g_greg_year_per_id||','||g_greg_qtr_per_id||','||g_greg_period_per_id||','||
  g_greg_day_per_id||',:97;';

  /* INSERT GREGORIAN YEAR PERIODICITY */

  insert into bsc_sys_periodicities(PERIODICITY_ID,NUM_OF_PERIODS,SOURCE,NUM_OF_SUBPERIODS,
  PERIOD_COL_NAME,SUBPERIOD_COL_NAME,YEARLY_FLAG,EDW_FLAG,CALENDAR_ID,EDW_PERIODICITY_ID,
  CUSTOM_CODE,DB_COLUMN_NAME,PERIODICITY_TYPE,PERIOD_TYPE_ID,RECORD_TYPE_ID,XTD_PATTERN, short_name) values (
  g_greg_year_per_id,1,g_greg_qtr_per_id,0,'PERIOD',null,1,0,g_greg_cal_id,0,2,'YEAR',1,128,128,l_xtd_pattern, g_greg_year_short_name);
  --FND_MESSAGE.SET_NAME('BSC','BSC_DBI_GREG_YEAR_NAME');
  l_name:=get_bis_dim_long_name('FII_TIME_YEAR',g_src_lang,l_source_lang);
  if g_debug then
    write_to_log_file_n('periodicity name DBI greg year='||l_name);
  end if;
  for i in 1..g_num_lang loop
    l_name:=get_bis_dim_long_name('FII_TIME_YEAR', g_lang(i),l_source_lang);
    insert into bsc_sys_periodicities_tl(PERIODICITY_ID,LANGUAGE,SOURCE_LANG,NAME,CREATED_BY,
    CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
    values(g_greg_year_per_id,g_lang(i),l_source_lang,l_name,g_who,sysdate,g_who,sysdate,g_who);
  end loop;

Exception when others then
  g_status_message:= g_status_message||' '||sqlerrm;
  write_to_log_file_n('Error in load_dbi_greg_cal '||g_status_message||get_time);
  raise;
End;

procedure load_dbi_greg_cal_data is
--
l_prev_qtr number;
l_prev_period number;
l_days_in_year number;
l_year number;
l_qtr number;
l_period number;
l_day number;
--
Begin
  --l_day:=get_day365(g_greg_start_date,g_dbi_cal_record(1).report_date)-1;
  --if l_day is null then
    --raise g_exception;
  --end if;
  --populate bsc_sys_periods and bsc_db_calendar for DAY
  l_prev_qtr:=0;
  l_prev_period:=0;
  for i in 1..g_num_dbi_cal_record loop
    l_year:=substr(g_dbi_cal_record(i).month_id,1,4);
    l_qtr:=substr(g_dbi_cal_record(i).month_id,5,1);
    l_period:=substr(g_dbi_cal_record(i).month_id,6);
    l_day:=g_dbi_cal_record(i).greg_day;
    --insert into bsc_sys_periods
    --time_fk is in MM/DD/YYYY format
    insert into bsc_sys_periods(PERIODICITY_ID,YEAR,PERIOD_ID,START_DATE,END_DATE,START_PERIOD,
    END_PERIOD,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,TIME_FK)
    values(g_greg_day_per_id,l_year,l_day, g_dbi_cal_record(i).start_date, g_dbi_cal_record(i).end_date, null,null,g_who,sysdate,g_who,sysdate,g_who,
    g_dbi_cal_record(i).cal_month||'/'||g_dbi_cal_record(i).cal_day||'/'||g_dbi_cal_record(i).cal_year);
    for j in 1..g_num_lang loop
      insert into bsc_sys_periods_tl(YEAR,PERIODICITY_ID,PERIOD_ID,MONTH,LANGUAGE,SOURCE_LANG,NAME,SHORT_NAME)
      values(l_year,g_greg_day_per_id,l_day,1,g_lang(j),g_src_lang,g_dbi_cal_record(i).report_date,null);
    end loop;
    --insert into bsc_db_calendar
    g_db_cal_modified:=true;
    insert into bsc_db_calendar(CALENDAR_YEAR,CALENDAR_MONTH,CALENDAR_DAY,YEAR,SEMESTER,
    QUARTER,BIMESTER,MONTH,WEEK52,WEEK4,DAY365,DAY30,HOLYDAY_FLAG,WORKDAY_FLAG,CALENDAR_ID,
    CUSTOM_1,CUSTOM_2,CUSTOM_3)
    values(g_dbi_cal_record(i).cal_year,g_dbi_cal_record(i).cal_month,g_dbi_cal_record(i).cal_day,
    l_year,0,0,0,0,0,0,0,0,null,null,g_greg_cal_id,l_day,l_period,l_qtr);
    ----
    l_prev_qtr:=l_qtr;
    l_prev_period:=l_period;
  end loop;
  --populate bsc_sys_periods for PERIOD. for period, we dont populate bsc_db_calendar
  --cursor c1 is select month_id,substr(month_id,1,4),substr(month_id,6) from FII_TIME_MONTH order by month_id;
  for i in 1..g_num_dbi_greg_period loop
    insert into bsc_sys_periods(PERIODICITY_ID,YEAR,PERIOD_ID,START_DATE,END_DATE,START_PERIOD,
    END_PERIOD,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,TIME_FK)
    values(g_greg_period_per_id,g_dbi_greg_period(i).year_id,g_dbi_greg_period(i).sequence, g_dbi_greg_period(i).start_date, g_dbi_greg_period(i).end_date, null,null,
    g_who,sysdate,g_who,sysdate,g_who,g_dbi_greg_period(i).month_id);
    for j in 1..g_num_lang loop
      insert into bsc_sys_periods_tl(YEAR,PERIODICITY_ID,PERIOD_ID,MONTH,LANGUAGE,SOURCE_LANG,NAME,SHORT_NAME)
      values(g_dbi_greg_period(i).year_id,g_greg_period_per_id,g_dbi_greg_period(i).sequence,1,g_lang(j),
      g_src_lang,g_dbi_greg_period(i).name,null);
    end loop;
  end loop;
  --populate bsc_sys_periods for QTR. for qtr, we dont populate bsc_db_calendar
  --cursor c2 is select quarter_id,year_id,substr(quarter_id,5) from fii_time_quarter order by quarter_id;
  for i in 1..g_num_dbi_greg_qtr loop
    insert into bsc_sys_periods(PERIODICITY_ID,YEAR,PERIOD_ID,START_DATE,END_DATE,START_PERIOD,
    END_PERIOD,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,TIME_FK)
    values(g_greg_qtr_per_id,g_dbi_greg_qtr(i).year_id,g_dbi_greg_qtr(i).sequence, g_dbi_greg_qtr(i).start_date, g_dbi_greg_qtr(i).end_date, null,null,
    g_who,sysdate,g_who,sysdate,g_who,g_dbi_greg_qtr(i).quarter_id);
    for j in 1..g_num_lang loop
      insert into bsc_sys_periods_tl(YEAR,PERIODICITY_ID,PERIOD_ID,MONTH,LANGUAGE,SOURCE_LANG,NAME,SHORT_NAME)
      values(g_dbi_greg_qtr(i).year_id,g_greg_qtr_per_id,g_dbi_greg_qtr(i).sequence,1,g_lang(j),g_src_lang,
      g_dbi_greg_qtr(i).name,null);
    end loop;
  end loop;
  --populate bsc_sys_periods for YEAR. for year, we dont populate bsc_db_calendar
  --cursor c3 is select year_id,year_id from fii_time_year order by year_id;
  for i in 1..g_num_dbi_greg_year loop
    insert into bsc_sys_periods(PERIODICITY_ID,YEAR,PERIOD_ID,START_DATE,END_DATE,START_PERIOD,
    END_PERIOD,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,TIME_FK)
    values(g_greg_year_per_id,g_dbi_greg_year(i).sequence,g_dbi_greg_year(i).sequence, g_dbi_greg_year(i).start_date, g_dbi_greg_year(i).end_date, null,null,
    g_who,sysdate,g_who,sysdate,g_who,g_dbi_greg_year(i).year_id);
    for j in 1..g_num_lang loop
      insert into bsc_sys_periods_tl(YEAR,PERIODICITY_ID,PERIOD_ID,MONTH,LANGUAGE,SOURCE_LANG,NAME,SHORT_NAME)
      values(g_dbi_greg_year(i).sequence,g_greg_year_per_id,g_dbi_greg_year(i).sequence,1,g_lang(j),g_src_lang,
      g_dbi_greg_year(i).name,null);
    end loop;
  end loop;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in load_dbi_greg_cal_data '||g_status_message||get_time);
  raise;
End;

procedure delete_dbi_calendar_metadata is
---
cursor c1 is select calendar_id from bsc_sys_calendars_b where edw_calendar_type_id in (1) and
edw_calendar_id in (1001,1002,1003);
---
l_calendar_id number;
Begin
  if g_debug then
    write_to_log_file_n('In delete_dbi_calendar_metadata'||get_time);
  end if;
  if g_debug then
    write_to_log_file_n('select calendar_id from bsc_sys_calendars_b where edw_calendar_type_id in (1) and
    edw_calendar_id in (1001,1002,1003)');
  end if;
  open c1;
  loop
    fetch c1 into l_calendar_id;
    exit when c1%notfound;
    if g_debug then
      write_to_log_file_n('delete bsc_sys_periodicities_tl where periodicity_id in '||
      '(select periodicity_id from bsc_sys_periodicities  where calendar_id='||l_calendar_id||')'||get_time);
    end if;
    delete bsc_sys_periodicities_tl where periodicity_id in
    (select periodicity_id from bsc_sys_periodicities  where calendar_id=l_calendar_id);
    if g_debug then
      write_to_log_file_n('Deleted '||sql%rowcount||' rows '||get_time);
    end if;
    if g_debug then
      write_to_log_file_n('delete bsc_sys_periodicities where calendar_id='||l_calendar_id||';'||get_time);
    end if;
    delete bsc_sys_periodicities where calendar_id=l_calendar_id;
    if g_debug then
      write_to_log_file_n('Deleted '||sql%rowcount||' rows '||get_time);
    end if;
    if g_debug then
      write_to_log_file_n('delete bsc_sys_calendars_tl where calendar_id='||l_calendar_id||');'||get_time);
    end if;
    delete bsc_sys_calendars_tl where calendar_id=l_calendar_id;
    if g_debug then
      write_to_log_file_n('Deleted '||sql%rowcount||' rows '||get_time);
    end if;
    if g_debug then
      write_to_log_file_n('delete bsc_sys_calendars_b where calendar_id='||l_calendar_id||');'||get_time);
    end if;
    delete bsc_sys_calendars_b where calendar_id=l_calendar_id;
    if g_debug then
      write_to_log_file_n('Deleted '||sql%rowcount||' rows '||get_time);
    end if;
  end loop;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in delete_dbi_calendar_metadata '||g_status_message||get_time);
  raise;
End;

procedure delete_dbi_calendars
is
---
cursor c1 is select calendar_id from bsc_sys_calendars_b where edw_calendar_type_id in (1) and
edw_calendar_id in (1001,1002,1003);
---
l_calendar_id number;
Begin
  if g_debug then
    write_to_log_file_n('In delete_dbi_calendars'||get_time);
  end if;
  if g_debug then
    write_to_log_file_n('select calendar_id from bsc_sys_calendars_b where edw_calendar_type_id in (1) and
    edw_calendar_id in (1001,1002,1003)');
  end if;
  open c1;
  loop
    fetch c1 into l_calendar_id;
    exit when c1%notfound;
    if g_debug then
      write_to_log_file_n('delete bsc_sys_periods where periodicity_id in (select periodicity_id '||
      'from bsc_sys_periodicities where calendar_id='||l_calendar_id||');'||get_time);
    end if;
    delete bsc_sys_periods where periodicity_id in (select periodicity_id from bsc_sys_periodicities
    where calendar_id=l_calendar_id);
    if g_debug then
      write_to_log_file_n('Deleted '||sql%rowcount||' rows '||get_time);
    end if;
    if g_debug then
      write_to_log_file_n('delete bsc_sys_periods_tl where periodicity_id in (select periodicity_id '||
      'from bsc_sys_periodicities where calendar_id='||l_calendar_id||');'||get_time);
    end if;
    delete bsc_sys_periods_tl where periodicity_id in (select periodicity_id from bsc_sys_periodicities
    where calendar_id=l_calendar_id);
    if g_debug then
      write_to_log_file_n('Deleted '||sql%rowcount||' rows '||get_time);
    end if;
    if g_debug then
      write_to_log_file_n('delete bsc_db_calendar where calendar_id='||l_calendar_id||');'||get_time);
    end if;
    delete bsc_db_calendar where calendar_id=l_calendar_id;
    if g_debug then
      write_to_log_file_n('Deleted '||sql%rowcount||' rows '||get_time);
    end if;
    /*
    reporting calendar is always truncated and full refreshed in
    BSC_BSC_ADAPTER.load_reporting_calendar
    if g_debug then
      write_to_log_file_n('delete bsc_reporting_calendar where calendar_id='||l_calendar_id||');'||get_time);
    end if;
    delete bsc_reporting_calendar where calendar_id=l_calendar_id;
    if g_debug then
      write_to_log_file_n('Deleted '||sql%rowcount||' rows '||get_time);
    end if;
    */
  end loop;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in delete_dbi_calendars '||g_status_message||get_time);
  raise;
End;

procedure analyze_tables is
l_owner varchar2(200);
Begin
  if g_debug then
    write_to_log_file_n('In analyze_tables'||get_time);
  end if;
  l_owner:=BSC_IM_UTILS.get_bsc_owner;
  BSC_IM_UTILS.analyze_object('BSC_SYS_PERIODS',l_owner,null,null,null);
  BSC_IM_UTILS.analyze_object('BSC_DB_CALENDAR',l_owner,null,null,null);
  if g_debug then
    write_to_log_file_n('Done analyze_tables'||get_time);
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in analyze_tables '||g_status_message||get_time);
  raise;
End;

procedure init_all is
cursor c1 is select language_code from FND_LANGUAGES where INSTALLED_FLAG in ('I', 'B');
Begin
  g_who:=0;
  if BSC_IM_UTILS.get_option_value(g_options,g_number_options,'DEBUG LOG')='Y' then
    g_debug:=true;
    BSC_IM_UTILS.open_file('TEST');
  end if;
  g_debug:=true;
  g_src_lang:=USERENV('LANG');
  g_num_lang:=1;
  open c1;
  loop
    fetch c1 into g_lang(g_num_lang);
    exit when c1%notfound;
    g_num_lang:=g_num_lang+1;
  end loop;
  g_num_lang:=g_num_lang-1;
  if g_debug then
    write_to_log_file_n('source language='||g_src_lang);
    write_to_log_file('Installed languages');
    for i in 1..g_num_lang loop
      write_to_log_file(g_lang(i));
    end loop;
  end if;
  g_db_cal_modified:=false;
  g_ent_fiscal_change:=0;
  g_445_fiscal_change:=0;
  g_greg_fiscal_change:=0;
Exception when others then
  g_status_message:=sqlerrm;
  raise;
End;

procedure write_to_log_file(p_message varchar2) is
Begin
  BSC_IM_UTILS.write_to_log_file(p_message);
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  null;
End;

procedure write_to_log_file_n(p_message varchar2) is
begin
  write_to_log_file('  ');
  write_to_log_file(p_message);
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  null;
end;

function get_time return varchar2 is
begin
  return BSC_IM_UTILS.get_time;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  null;
End;

function get_periodicity_nextval return number is
l_seqval number;
Begin
  select bsc_sys_periodicity_id_s.nextval into l_seqval from dual;
  return l_seqval;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  raise;
End;

function get_calendar_nextval return number is
l_seqval number;
Begin
  select bsc_sys_calendar_id_s.nextval into l_seqval from dual;
  return l_seqval;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  raise;
End;

/*
given a start date of the calendar and a particular date, this api tells you
what is the day365 value of this date
*/
--this function is obsolete...superseded by calculate_day365 and calculate_day365_445
function get_day365(
p_cal_start_date date,
p_this_date date
)return number is
--
l_this_year number;
l_start_date date;
l_day365 number;
l_days_in_year number;
--
Begin
  l_this_year:=to_number(to_char(p_this_date,'YYYY'));
  if mod(l_this_year,4)=0 then --leap year
    l_days_in_year:=366;
  else
    l_days_in_year:=365;
  end if;
  l_start_date:=to_date(to_char(p_cal_start_date,'MM/DD')||'/'||l_this_year,'MM/DD/YYYY');
  if l_start_date>p_this_date then
    l_day365:=l_days_in_year-(l_start_date-p_this_date)+1;
  else
    l_day365:=p_this_date-l_start_date+1;
  end if;
  return l_day365;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  raise;
End;

procedure calculate_day365(p_mode varchar2,p_cal_id number) is
--
cursor c1(p_cal_id number) is select day365 from bsc_db_calendar where calendar_id=p_cal_id
order by calendar_year desc,calendar_month desc,calendar_day desc;
--
l_index number;
l_prev_day number;
l_cal_start_date date;
l_ent_yr_index number;
l_yr_compare_fmt VARCHAR2(100);
--
Begin
  if g_debug then
    write_to_log_file_n('In calculate_day365 '||p_mode||', cal='||p_cal_id||get_time);
  end if;

  -- Fix: in condition to check year change; we should also include YYYY part in date comparison
  -- added for bug 6014462, separated the logic for enterprise and gregorian calendar
  -- because enterprise calendar can start at different date every year
  -- for gregorian the year start date is same for every year so here we do not
  -- need dd/mm/yyyy comparison simpel dd/mm comparision will do.
  l_yr_compare_fmt := 'MM/DD/YYYY';

  if p_cal_id=g_ent_cal_id then
    --bug 5461356 don't assume that start date will be same for every year
    -- for enterprise and 445 calendar
    l_ent_yr_index :=1;
    l_cal_start_date:=g_dbi_ent_year(l_ent_yr_index).start_date;
  else
    l_cal_start_date:=g_greg_start_date;
    l_yr_compare_fmt := 'MM/DD';
  end if;
  if p_mode='full' then
    for i in 1..g_num_dbi_cal_record loop
      if to_char(l_cal_start_date,l_yr_compare_fmt)=to_char(g_dbi_cal_record(i).report_date,l_yr_compare_fmt) then
        l_index:=i;
        exit;
      end if;
    end loop;
    if g_debug then
      write_to_log_file_n('l_index='||l_index);
    end if;
    if l_index is null then
      write_to_log_file_n('could not locate start month/date');
      raise g_exception;
    end if;
    l_index:=l_index-1;
    if l_index>0 then
      -- bug5461356
      -- we can not assume that an year will have max 365 or 366 days..
      -- in dbi it can be 365+/-14
      if(l_index>366) then
        l_prev_day:=l_index;
      else
        l_prev_day:=366;
      end if;
      for i in reverse 1..l_index loop
        if p_cal_id=g_ent_cal_id then
          g_dbi_cal_record(i).ent_day:=l_prev_day;
        else
          g_dbi_cal_record(i).greg_day:=l_prev_day;
        end if;
        l_prev_day:=l_prev_day-1;
      end loop;
    end if;
    l_index:=l_index+1;
    l_prev_day:=0;
  else
    --INCREMENTAL
    if g_debug then
      write_to_log_file_n('select day365 from bsc_db_calendar where calendar_id=:1
      order by calendar_year desc,calendar_month desc,calendar_day desc using '||p_cal_id);
    end if;
    open c1(p_cal_id);
    fetch c1 into l_prev_day;
    close c1;
    l_index:=1;
    --assume dates are consequetive, this means that the first date in g_dbi_cal_record is l_max_date +1
  end if;
  if g_debug then
    write_to_log_file_n('l_prev_day='||l_prev_day||', l_index='||l_index);
  end if;
  for i in l_index..g_num_dbi_cal_record loop
    if to_char(l_cal_start_date,l_yr_compare_fmt)=to_char(g_dbi_cal_record(i).report_date,l_yr_compare_fmt) then
      if p_cal_id=g_ent_cal_id then
        l_ent_yr_index:=l_ent_yr_index+1;
        if(l_ent_yr_index<=g_num_dbi_ent_year) then
           l_cal_start_date := g_dbi_ent_year(l_ent_yr_index).start_date;
        else
           l_cal_start_date := g_ent_start_date;
        end if;
      end if;
      l_prev_day:=1;
    else
      l_prev_day:=l_prev_day+1;
    end if;
    if p_cal_id=g_ent_cal_id then
      g_dbi_cal_record(i).ent_day:=l_prev_day;
    else
      g_dbi_cal_record(i).greg_day:=l_prev_day;
    end if;
  end loop;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in calculate_day365 '||sqlerrm||get_time);
  raise;
End;

procedure calculate_day365_445(p_mode varchar2) is
--
cursor c1(p_cal_id number) is select day365 from bsc_db_calendar where calendar_id=p_cal_id
order by calendar_year desc,calendar_month desc,calendar_day desc;
--
l_index number;
l_prev_day number;
l_cal_start_date date;
l_week number;
l_p445 number;
l_flag boolean;
--
Begin
  if g_debug then
    write_to_log_file_n('In calculate_day365_445 '||p_mode||get_time);
  end if;
  l_cal_start_date:=g_445_start_date;
  if p_mode='full' then
    for i in 1..g_num_dbi_cal_record loop
      l_p445:=substr(g_dbi_cal_record(i).week_id,5,2);
      l_week:=substr(g_dbi_cal_record(i).week_id,7);
      if l_p445=1 and l_week=1 then
        l_index:=i;
        exit;
      end if;
    end loop;
    if g_debug then
      write_to_log_file_n('l_index='||l_index);
    end if;
    if l_index is null then
      write_to_log_file_n('could not locate start month/date');
      raise g_exception;
    end if;
    l_index:=l_index-1;
    if l_index>0 then
      -- bug5461356
      -- we can not assume that an year will have max 365 or 366 days..
      -- in dbi it can be 365+/-14
      if(l_index>366) then
        l_prev_day:=l_index;
      else
        l_prev_day:=366;
      end if;
      l_prev_day:=366;
      for i in reverse 1..l_index loop
        g_dbi_cal_record(i).p445_day:=l_prev_day;
        l_prev_day:=l_prev_day-1;
      end loop;
    end if;
    l_index:=l_index+1;
    l_prev_day:=0;
  else
    --INCREMENTAL
    if g_debug then
      write_to_log_file_n('select day365 from bsc_db_calendar where calendar_id=:1
      order by calendar_year desc,calendar_month desc,calendar_day desc using '||g_445_cal_id);
    end if;
    open c1(g_445_cal_id);
    fetch c1 into l_prev_day;
    close c1;
    l_index:=1;
    --assume dates are consequetive, this means that the first date in g_dbi_cal_record is l_max_date +1
  end if;
  if g_debug then
    write_to_log_file_n('l_prev_day='||l_prev_day||', l_index='||l_index);
  end if;
  l_flag:=true;
  for i in l_index..g_num_dbi_cal_record loop
    l_p445:=substr(g_dbi_cal_record(i).week_id,5,2);
    l_week:=substr(g_dbi_cal_record(i).week_id,7);
    if l_week=1 and l_p445=1 then
      if l_flag then
        l_prev_day:=1;
        l_flag:=false;
      else
        l_prev_day:=l_prev_day+1;
      end if;
    else
      l_prev_day:=l_prev_day+1;
      l_flag:=true;
    end if;
    g_dbi_cal_record(i).p445_day:=l_prev_day;
  end loop;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in calculate_day365_445 '||sqlerrm||get_time);
  raise;
End;

procedure dmp_g_dbi_cal_record is
Begin
  write_to_log_file_n('Output from g_dbi_cal_record');
  for i in 1..g_num_dbi_cal_record loop
    write_to_log_file(g_dbi_cal_record(i).report_date||' '||g_dbi_cal_record(i).cal_day||' '||g_dbi_cal_record(i).cal_month||' '||
    g_dbi_cal_record(i).cal_year||' '||g_dbi_cal_record(i).month_id||' '||g_dbi_cal_record(i).ent_period_id||' '||
    g_dbi_cal_record(i).week_id||' '||g_dbi_cal_record(i).ent_week_id||' '||g_dbi_cal_record(i).row_num||' '||
    g_dbi_cal_record(i).ent_day||' '||g_dbi_cal_record(i).p445_day||' '||g_dbi_cal_record(i).greg_day);
  end loop;
Exception when others then
  write_to_log_file_n('Error in dmp_g_dbi_cal_record '||sqlerrm||get_time);
End;

procedure get_ent_cal_start_date(p_mode varchar2) is
--
cursor c1 is select start_month||'/'||start_day||'/'||current_year from bsc_sys_calendars_b
where edw_calendar_type_id=1 and edw_calendar_id=1001;
l_start_date date;
l_year number;
l_qtr number;
l_period number;
l_cal_start_date varchar2(200);
--
Begin
  if g_debug then
    write_to_log_file_n('select to_date(start_month||''/''||start_day||''/''||current_year,''MM/DD/YYYY'') '||
    'from bsc_sys_calendars_b where edw_calendar_type_id=1 and edw_calendar_id=1001');
  end if;
  open c1;
  fetch c1 into l_cal_start_date;
  close c1;
  if l_cal_start_date is null or l_cal_start_date='//' then
    g_ent_start_date:=null;
  else
    g_ent_start_date:=to_date(l_cal_start_date,'MM/DD/YYYY');
  end if;
  if g_ent_start_date is null or p_mode='full' then
    if g_debug then
      write_to_log_file_n('Check mem data from fii_time_day');
    end if;
    l_start_date:=null;
    for i in 1..g_num_dbi_cal_record loop
      l_year:=substr(g_dbi_cal_record(i).ent_period_id,1,4);
      l_qtr:=substr(g_dbi_cal_record(i).ent_period_id,5,1);
      l_period:=substr(g_dbi_cal_record(i).ent_period_id,6);
      if l_year=g_bsc_greg_fiscal_year and l_qtr=1 and l_period=1 then
        l_start_date:=to_date(g_dbi_cal_record(i).cal_month||'/'||g_dbi_cal_record(i).cal_day||'/'||
        g_dbi_cal_record(i).cal_year,'MM/DD/YYYY');
        exit;
      end if;
    end loop;
    if l_start_date is null then
      /*issue ling reported. fii_time_day is populated with this filter where  adjustment_period_flag='N' . this means that periods need not start
      from 1 if period 1 is an adjusting period.*/
      for i in 1..g_num_dbi_cal_record loop
        l_year:=substr(g_dbi_cal_record(i).ent_period_id,1,4);
        if l_year=g_bsc_greg_fiscal_year then /*as soon as we touch the fiscal year, set this as the ent start date */
          l_start_date:=to_date(g_dbi_cal_record(i).cal_month||'/'||g_dbi_cal_record(i).cal_day||'/'||
          g_dbi_cal_record(i).cal_year,'MM/DD/YYYY');
          exit;
        end if;
      end loop;
    end if;
    --
    if g_debug then
      write_to_log_file_n('g_ent_start_date='||g_ent_start_date||', l_start_date='||l_start_date);
    end if;
    /*4995603 we need to check only the month and day to see if there is a change in start date the year is upto BSC */
    if g_ent_start_date is not null and to_char(g_ent_start_date,'MM/DD')<>to_char(l_start_date,'MM/DD') then
      g_ent_fiscal_change:=1;
    end if;
    g_ent_start_date:=l_start_date;
  end if;
  if g_debug then
    write_to_log_file_n('g_ent_start_date='||g_ent_start_date);
  end if;
  if g_ent_start_date is null then
    write_to_log_file_n('g_ent_start_date NULL. fatal...');
    raise g_exception;
  end if;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_ent_cal_start_date '||g_status_message||get_time);
  raise;
End;

procedure get_445_cal_start_date(p_mode varchar2) is
--
cursor c1 is select start_month||'/'||start_day||'/'||current_year from bsc_sys_calendars_b
where edw_calendar_type_id=1 and edw_calendar_id=1002;
--
l_start_date date;
l_year number;
l_p445 number;
l_week number;
l_cal_start_date varchar2(200);
--
Begin
  if g_debug then
    write_to_log_file_n('select to_date(start_month||''/''||start_day||''/''||current_year,''MM/DD/YYYY'') '||
    'from bsc_sys_calendars_b where edw_calendar_type_id=1 and edw_calendar_id=1002');
  end if;
  open c1;
  fetch c1 into l_cal_start_date;
  close c1;
  if l_cal_start_date is null or l_cal_start_date='//' then
    g_445_start_date:=null;
  else
    g_445_start_date:=to_date(l_cal_start_date,'MM/DD/YYYY');
  end if;
  if g_445_start_date is null or p_mode='full' then
    if g_debug then
      write_to_log_file_n('Check mem data from fii_time_day');
    end if;
    for i in 1..g_num_dbi_cal_record loop
      l_year:=substr(g_dbi_cal_record(i).week_id,1,4);
      l_p445:=substr(g_dbi_cal_record(i).week_id,5,2);
      l_week:=substr(g_dbi_cal_record(i).week_id,7);
      if l_year=g_bsc_greg_fiscal_year and l_p445=1 and l_week=1 then
        --g_445_start_date:=to_date(g_dbi_cal_record(i).cal_month||'/'||g_dbi_cal_record(i).cal_day||'/'||
        --g_dbi_cal_record(i).cal_year,'MM/DD/YYYY');
        --3872505
        --now, when the fiscal year changes say from 1997 to 1998, all periodicities are reset inclusing week
        --in that case, start day must always be 1
        l_start_date:=to_date(g_dbi_cal_record(i).cal_month||'/'||g_dbi_cal_record(i).cal_day||'/'||
        g_dbi_cal_record(i).cal_year,'MM/DD/YYYY');
        if g_debug then
          write_to_log_file_n('g_445_start_date='||g_445_start_date||', l_start_date='||l_start_date);
        end if;
        /*4995603 we need to check only the month and day to see if there is a change in start date the year is upto BSC */
        if g_445_start_date is not null and to_char(g_445_start_date,'MM/DD')<>to_char(l_start_date,'MM/DD') then
          g_445_fiscal_change:=1;
        end if;
        g_445_start_date:=l_start_date;
        exit;
      end if;
    end loop;
  end if;
  if g_debug then
    write_to_log_file_n('g_445_start_date='||g_445_start_date);
  end if;
  if g_445_start_date is null then
    write_to_log_file_n('g_445_start_date NULL. fatal...');
    raise g_exception;
  end if;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_445_cal_start_date '||g_status_message||get_time);
  raise;
End;

procedure get_greg_cal_start_date(p_mode varchar2)  is
--
cursor c1 is select start_month||'/'||start_day||'/'||current_year from bsc_sys_calendars_b
where edw_calendar_type_id=1 and edw_calendar_id=1003;
--
l_start_date date;
l_year number;
l_qtr number;
l_period number;
l_cal_start_date varchar2(200);
--
Begin
  if g_debug then
    write_to_log_file_n('select to_date(start_month||''/''||start_day||''/''||current_year,''MM/DD/YYYY'') '||
    'from bsc_sys_calendars_b where edw_calendar_type_id=1 and edw_calendar_id=1003');
  end if;
  open c1;
  fetch c1 into l_cal_start_date;
  close c1;
  if l_cal_start_date is null or l_cal_start_date='//' then
    g_greg_start_date:=null;
  else
    g_greg_start_date:=to_date(l_cal_start_date,'MM/DD/YYYY');
  end if;
  if g_greg_start_date is null or p_mode='full' then
    if g_debug then
      write_to_log_file_n('Check mem data from fii_time_day');
    end if;
    for i in 1..g_num_dbi_cal_record loop
      l_year:=substr(g_dbi_cal_record(i).month_id,1,4);
      l_qtr:=substr(g_dbi_cal_record(i).month_id,5,1);
      l_period:=substr(g_dbi_cal_record(i).month_id,6);
      if l_year=g_bsc_greg_fiscal_year and l_qtr=1 and l_period=1 then
        l_start_date:=to_date(g_dbi_cal_record(i).cal_month||'/'||g_dbi_cal_record(i).cal_day||'/'||
        g_dbi_cal_record(i).cal_year,'MM/DD/YYYY');
        if g_debug then
          write_to_log_file_n('g_greg_start_date='||g_greg_start_date||', l_start_date='||l_start_date);
        end if;
        /*4995603 we need to check only the month and day to see if there is a change in start date the year is upto BSC */
        if g_greg_start_date is not null and to_char(g_greg_start_date,'MM/DD')<>to_char(l_start_date,'MM/DD') then
          g_greg_fiscal_change:=1;
        end if;
        g_greg_start_date:=l_start_date;
        exit;
      end if;
    end loop;
  end if;
  if g_debug then
    write_to_log_file_n('g_greg_start_date='||g_greg_start_date);
  end if;
  if g_greg_start_date is null then
    write_to_log_file_n('g_greg_start_date NULL. fatal...');
    raise g_exception;
  end if;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_greg_cal_start_date '||g_status_message||get_time);
  raise;
End;

function get_bis_dim_long_name(p_dim varchar2, p_lang varchar2, p_source_lang out nocopy varchar2) return varchar2 is
--
--cursor c1(p_dim varchar2) is select name from bis_levels_vl where short_name=p_dim;
  cursor c1 is select name, source_lang from bis_levels_tl tl, bis_levels l
  where l.short_name = p_dim and
  l.level_id = tl.level_id and
  tl.language = p_lang;
--
l_name varchar2(4000);
Begin
  if g_debug then
    write_to_log_file_n('select name from bis_levels_vl where short_name='||p_dim);
  end if;
  open c1;
  fetch c1 into l_name,p_source_lang;
  close c1;
  if g_debug then
    write_to_log_file('l_name='||l_name);
  end if;
  return l_name;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_bis_dim_long_name '||g_status_message||get_time);
  raise;
End;

function get_lookup_value(p_lookup_type varchar2,p_lookup_code varchar2,p_lang varchar2,p_source_lang out nocopy varchar2)
return varchar2 is
--
cursor c1 is select meaning, source_lang from fnd_lookup_values where lookup_type=p_lookup_type
and lookup_code=p_lookup_code
and language=p_lang;
--
l_var varchar2(4000);
--
Begin
  if g_debug then
    write_to_log_file_n('get_lookup_value '||p_lookup_type||' '||p_lookup_code);
  end if;
  open c1;
  fetch c1 into l_var, p_source_lang;
  close c1;
  if l_var is null then
    l_var:=p_lookup_code;
  end if;
  return l_var;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_lookup_value '||g_status_message||get_time);
  raise;
End;

/*
This api is needed by pmd. given a time level name, they need to know the
bsc periodicity. time level comes from
SELECT distinct attribute2
 from ak_region_items
 where attribute1 ='DIMENSION LEVEL'
 and  attribute2 like 'TIME+%';
*/

/* Original API removed by Arun for bug 4482933, this is replaced by the simpler api logic that follows*/

function get_bsc_Periodicity(
p_time_level_name varchar2,
x_periodicity_id out nocopy number,
x_calendar_id out nocopy number,
x_message out nocopy varchar2
)return boolean is
--
cursor c1 is
select periodicity_id, calendar_id from bsc_sys_periodicities where short_name= p_time_level_name;
--
Begin

  open c1;
  fetch c1 into x_periodicity_id, x_calendar_id;
  close c1;
  if (x_periodicity_id is not null) then
    return true;
  else
    return false;
  end if;
Exception when others then
  x_message:=sqlerrm;
  return false;
End;


--for PMV
procedure get_bsc_Periodicity_jdbc(
p_time_level_name varchar2,
x_periodicity_id out nocopy number,
x_calendar_id out nocopy number,
x_status out nocopy number,
x_message out nocopy varchar2
) is
BEGIN
  if (get_bsc_Periodicity ( p_time_level_name,
    x_periodicity_id ,
    x_calendar_id ,
    x_message )) then
    x_status := 0;
  else
    x_status := 1;
  end if;
Exception when others then
  x_message:=sqlerrm;
  x_status := 1;
END;

function is_dbi_cal_metadata_loaded return boolean is
cursor c1 is select 1 from bsc_sys_calendars_b where edw_calendar_type_id=1 and edw_calendar_id =1001;
l_res number;
Begin
  open c1;
  fetch c1 into l_res;
  close c1;
  if l_res=1 then
    return true;
  else
    return false;
  end if;
Exception when others then
  raise;
End;

function check_for_dbi return boolean is
cursor c1 is select 1 from user_objects where object_name='FII_TIME_DAY';
l_sql varchar2(2000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_res number;
Begin
  open c1;
  fetch c1 into l_res;
  close c1;
  if l_res=1 then
    if g_debug then
      write_to_log_file_n('DBI Implemented');
    end if;

    -- Fix bug#4027766: If fii_time_day is empty we return false. nothing to import
    l_sql:='select 1 from fii_time_day where rownum=1';
    open cv for l_sql;
    fetch cv into l_res;
    if cv%notfound then
      close cv;
      if g_debug then
        write_to_log_file_n('fii_time_day is empty. DBI NOT Implemented');
      end if;
      return false;
    else
      close cv;
      if g_debug then
        write_to_log_file_n('fii_time_day has data. DBI Implemented');
      end if;
      return true;
    end if;
  else
    if g_debug then
      write_to_log_file_n('DBI NOT Implemented');
    end if;
    return false;
  end if;
Exception when others then
  raise;
End;

--AW_INTEGRATION: New procedure
procedure load_dbi_calendars_into_aw is
--
cursor c1 is select calendar_id from bsc_sys_calendars_b where edw_calendar_type_id = 1;
l_calendar_id number;
--
l_dim varchar2(200);
l_oo bsc_aw_md_wrapper.bsc_olap_object_tb;
Begin
  if g_debug then
    write_to_log_file_n('In load_dbi_calendars_into_aw '||get_time);
    write_to_log_file_n('cursor c1 is select calendar_id from bsc_sys_calendars_b where edw_calendar_type_id = 1;'||get_time);
  end if;
  open c1;
  loop
      fetch c1 into l_calendar_id;
      exit when c1%notfound;
      /*5350867. first, do not create the calendar here. if calendar is already installed, only then do we try to refresh it */
      l_dim:=bsc_aw_calendar.get_calendar_name(l_calendar_id);
      l_oo.delete;
      bsc_aw_md_api.get_bsc_olap_object(l_dim,'dimension',l_dim,'dimension',l_oo);
      if l_oo.count>0 then
        /*bsc_aw_calendar.create_calendar(p_calendar => l_calendar_id,p_options => 'DEBUG LOG, RECREATE');
        do not create calendar here
        */
        bsc_aw_calendar.load_calendar(p_calendar => l_calendar_id,p_options => 'DEBUG LOG');
      end if;
  end loop;
  close c1;
  if g_debug then
    write_to_log_file_n('Done load_dbi_calendars_into_aw '||get_time);
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in load_dbi_calendars_into_aw '||g_status_message||get_time);
  raise;
End;

END BSC_DBI_CALENDAR;

/
