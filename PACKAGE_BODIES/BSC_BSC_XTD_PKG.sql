--------------------------------------------------------
--  DDL for Package Body BSC_BSC_XTD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_BSC_XTD_PKG" AS
/*$Header: BSCRPTCB.pls 120.12 2006/02/14 11:56:38 vsurendr noship $*/

--public
procedure create_rpt_key_table(
p_user_id number,
p_table_name out nocopy varchar2,
p_error_message out nocopy varchar2
)is
l_stmt varchar2(2000);
l_col_list varchar2(1000);
Begin
  --clear cache, added for bug 4652655
  if g_num_kpi_xtd is not null and g_num_kpi_xtd>0 then
    g_kpi_xtd.delete;
  end if;
  g_num_kpi_xtd:=0;
  --Changed by Arun, 10/14/2005 due to perf. concerns raised by Mandar, Bug 4676527
  p_table_name := 'bsc_rpt_keys';

Exception when others then
  if sqlcode=-00955 then
    --do nothing
    return;
  end if;
  g_status_message:=sqlerrm;
  g_status:=-1;
  p_error_message:=g_status_message;
  if g_file and g_debug then
    BSC_im_utils.write_to_log_file_n('Error in create_rpt_key_table '||g_status_message);
  end if;
End;

--public
procedure drop_rpt_key_table(
p_user_id number,
p_error_message out nocopy varchar2
)is
l_stmt varchar2(1000);
cursor c1 is SELECT TABLE_NAME FROM ALL_TABLES WHERE TABLE_NAME LIKE 'BSC_RPT_KEYS_%' AND TEMPORARY='Y' AND OWNER = BSC_APPS.get_user_schema;
l_table varchar2(100);
Begin
  -- Changed by Arun for bug/enh 4676527
  delete bsc_rpt_keys;
  --clear cache, added for bug 4652655
  if g_num_kpi_xtd is not null and g_num_kpi_xtd>0 then
    g_kpi_xtd.delete;
  end if;
  g_num_kpi_xtd:=0;
Exception when others then
  null;
End;

--public
procedure delete_rpt_keys(
p_table_name varchar2,
p_session_id number,
p_error_message out nocopy varchar2
)is
Begin
  if g_file and g_debug then
    BSC_im_utils.write_to_log_file_n('delete '||p_table_name||' where session_id='||p_session_id||get_time);
  end if;
  execute immediate 'delete '||p_table_name||' where session_id=:1' using p_session_id;
  if g_file and g_debug then
    BSC_im_utils.write_to_log_file_n('Deleted '||sql%rowcount||' rows '||get_time);
  end if;
  if g_num_kpi_xtd is not null and g_num_kpi_xtd>0 then
    g_kpi_xtd.delete;
  end if;
  g_num_kpi_xtd:=0;
  if g_file and g_debug then
    BSC_im_utils.write_to_log_file_n('---------------------------------------');
  end if;
Exception when others then
  if sqlcode=-06531 then
    null;
  else
    g_status_message:=sqlerrm;
    p_error_message:=g_status_message;
    if g_file and g_debug then
      BSC_im_utils.write_to_log_file_n(g_status_message);
    end if;
  end if;
End;

/*
---------------------------------
Public api. called from front end tools like iviewer and pmv
backward compatibility. no rolling supported, only xtd
---------------------------------
*/
procedure populate_rpt_keys(
p_table_name varchar2,
p_session_id number,
p_kpi number,
p_report_date varchar2,
p_xtd_period varchar2,
p_xtd_year varchar2,
p_xtd_periodicity number,
p_option_string varchar2,
p_error_message out nocopy varchar2
)is
Begin
  populate_rpt_keys(p_table_name,p_session_id,p_kpi,p_report_date,p_xtd_period,p_xtd_year,p_xtd_periodicity,
  'XTD',p_option_string,p_error_message);
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=-1;
  p_error_message:=g_status_message;
  rollback;
  if g_file and g_debug then
    BSC_im_utils.write_to_log_file_n(p_error_message);
  end if;
End;
/*
---------------------------------
Public api. called from front end tools like iviewer and pmv
rolling vs std xtd specified
---------------------------------
*/
procedure populate_rpt_keys(
p_table_name varchar2,
p_session_id number,
p_kpi number,
p_report_date varchar2,
p_xtd_period varchar2,
p_xtd_year varchar2,
p_xtd_periodicity number,
p_xtd_type varchar2,--ROLLING vs XTD
p_option_string varchar2,
p_error_message out nocopy varchar2
)is
---------------------
l_report_date date_tabletype;
l_xtd_period number_tabletype;
l_xtd_year number_tabletype;
l_num_report_date number;
ll_report_date varchar_tabletype;--temp
ll_num_report_date number;--temp
ll_report_date_flag boolean_tabletype;
---------------------
e_error EXCEPTION;
l_num number;
---------------------
Begin
  g_session_id:=p_session_id;
  g_option_string:=p_option_string;
  g_status:=0;
  if g_num_kpi_xtd is null then
    g_num_kpi_xtd:=0;
  end if;
  init;
  if g_file and g_debug then
    BSC_im_utils.write_to_log_file_n('populate_rpt_keys p_table_name='||p_table_name||',p_session_id='||p_session_id||
    ',p_kpi='||p_kpi||','||'p_report_date='||p_report_date||',p_xtd_period='||p_xtd_period||',p_xtd_year='||
    p_xtd_year||',p_xtd_periodicity='||p_xtd_periodicity||',p_xtd_type='||p_xtd_type||
    ',g_option_string='||g_option_string||get_time);
  end if;

  --parse the dates out
  if parse_values(p_report_date,':',ll_report_date,ll_num_report_date)=false then
    raise e_error;
  end if;
  if parse_values(p_xtd_period,':',l_xtd_period,l_num)=false then
    raise e_error;
  end if;
  if l_num<ll_num_report_date then
    for i in l_num+1..ll_num_report_date loop
      l_xtd_period(i):=l_xtd_period(i-1);
    end loop;
  end if;
  if parse_values(p_xtd_year,':',l_xtd_year,l_num)=false then
    raise e_error;
  end if;
  if l_num<ll_num_report_date then
    for i in l_num+1..ll_num_report_date loop
      l_xtd_year(i):=l_xtd_year(i-1);
    end loop;
  end if;
  --first see if data is already cached
  for i in 1..ll_num_report_date loop
    ll_report_date_flag(i):=true;
    for j in 1..g_num_kpi_xtd loop
      if g_kpi_xtd(j).session_id=p_session_id and g_kpi_xtd(j).kpi=p_kpi
        and g_kpi_xtd(j).report_date=to_date(ll_report_date(i),'MM/DD/YYYY')
        and g_kpi_xtd(j).xtd_periodicity=p_xtd_periodicity then
        ll_report_date_flag(i):=false;
        exit;
      end if;
    end loop;
  end loop;
  l_num_report_date:=0;
  for i in 1..ll_num_report_date loop
    if ll_report_date_flag(i) then
      l_num_report_date:=l_num_report_date+1;
      l_report_date(l_num_report_date):=to_date(ll_report_date(i),'MM/DD/YYYY');
      l_xtd_period(l_num_report_date):=l_xtd_period(i);
      l_xtd_year(l_num_report_date):=l_xtd_year(i);
    end if;
  end loop;
  if g_file and g_debug then
    BSC_im_utils.write_to_log_file_n('Looking at the following dates, periods and year');
    for i in 1..l_num_report_date loop
      BSC_im_utils.write_to_log_file(l_report_date(i)||' '||l_xtd_period(i)||' '||l_xtd_year(i));
    end loop;
  end if;
  if l_num_report_date>0 then
    if populate_rpt_keys(
      p_table_name,
      p_session_id,
      p_kpi,
      l_report_date,
      l_num_report_date,
      l_xtd_period,
      l_xtd_year,
      p_xtd_periodicity,
      p_xtd_type
      )=false then
      raise e_error;
    end if;
  end if;
  --Reverting back enh. after discussion b/w Arun/Kiran/Pramod/Venu
  --added by arun for enh 4708622
  --if g_debug then
  --  copy_to_debug_table;
  --end if;
  if g_file and g_debug then
    BSC_im_utils.write_to_log_file_n('---------------------------------------');
  end if;
Exception
  when e_error then
    g_status:=-1;
    p_error_message:=g_status_message;
    rollback;
  when others then
  g_status_message:=sqlerrm;
  g_status:=-1;
  p_error_message:=g_status_message;
  rollback;
  if g_file and g_debug then
    BSC_im_utils.write_to_log_file_n(p_error_message);
  end if;
End;

function populate_rpt_keys(
p_table_name varchar2,--name of the rpt_cal_keys table
p_session_id number,
p_kpi number,
p_report_date date_tabletype,
p_num_report_date number,
p_xtd_period number_tabletype,--use p_num_report_date for count
p_xtd_year number_tabletype,--use p_num_report_date for count
p_xtd_periodicity number,
p_xtd_type varchar2
)return boolean is
------
cursor c1(p_kpi number) is
select bsc_kpi_periodicities.periodicity_id,calendar_id,period_type_id,db_column_name,num_of_periods
from bsc_kpi_periodicities ,bsc_sys_periodicities
where indicator=p_kpi and bsc_kpi_periodicities.periodicity_id=bsc_sys_periodicities.periodicity_id
order by indicator,display_order desc;
cursor c2(p_xtd_periodicity number) is
select xtd_pattern from bsc_sys_periodicities where periodicity_id=p_xtd_periodicity;
cursor c3(p_calendar_id number) is
select decode(edw_calendar_id,1001,decode(edw_calendar_type_id,1,'DBI-ENT',null),null) from bsc_sys_calendars_b
where calendar_id=p_calendar_id;
------
l_periodicity number_tabletype;
l_period_type_id number_tabletype;
l_period_column_name varchar_tabletype;
l_period_num_of_periods number_tabletype;--needed for rolling
l_num_periodicity number;
--
--3919980
l_orig_periodicity number_tabletype;
l_orig_period_type_id number_tabletype;
l_orig_period_column_name varchar_tabletype;
l_orig_period_num_of_periods number_tabletype;--needed for rolling
l_orig_num_periodicity number;
--
l_periodicity_string varchar2(200);
l_xtd_pattern varchar2(4000);
l_xtd_pattern_value number;--this is what is used to BITAND
l_hier varchar2(4000);
l_calendar_id number;
l_pattern varchar_tabletype;
l_num_pattern number;
------
l_index number;
l_start number;
l_end number;
l_num number;
l_count number;
l_max_count number:=200;
l_found boolean;
l_found2 boolean;
------
l_pattern_period_pattern number_tabletype;
l_pattern_period_periodicity number_tabletype;
l_pattern_period_missing boolean_tabletype;
l_num_pattern_period number;
l_use_pattern boolean;
l_pattern_to_use number;
l_periodicity_missing boolean;
------
--just temp storage
ll_temp_period_pattern number_tabletype;--pattern number
ll_temp_period_periodicity number_tabletype;--the periodicity in the pattern
ll_temp_period_missing boolean_tabletype;--missing or not
ll_num_temp_pattern_period number:=0;
------
l_rank number_tabletype;
l_max_rank number;
l_min_rank number;
l_max_rank_index number;
l_min_rank_index number;
----
--support for rolling xtd
l_xtd_count number;
l_roll_count number;
----
e_error exception;
l_cal_type varchar2(40);
Begin
  --if this is first time
  l_periodicity_missing:=false;
  l_num_periodicity:=1;
  l_periodicity_string:=null;
  open c1(p_kpi);
  loop
    fetch c1 into l_periodicity(l_num_periodicity),l_calendar_id,l_period_type_id(l_num_periodicity),
    l_period_column_name(l_num_periodicity),l_period_num_of_periods(l_num_periodicity);
    exit when c1%notfound;
    l_num_periodicity:=l_num_periodicity+1;
  end loop;
  close c1;
  l_num_periodicity:=l_num_periodicity-1;
  if g_file and g_debug then
    BSC_im_utils.write_to_log_file_n('The kpi periodicities for '||p_kpi||' (calendar='||l_calendar_id||')');
    for i in 1..l_num_periodicity loop
      BSC_im_utils.write_to_log_file(l_periodicity(i)||' '||l_period_type_id(i)||' '||
      l_period_column_name(i)||' '||l_period_num_of_periods(i));
    end loop;
  end if;
  /*
  4449784: we do not need Day to date. if p_xtd_periodicity is daily, we just need the key to the days record in the MV,
  not all the keys that can give day to date
  we can either fix the xtd pattern or the code here. its best we fix it here. xtd pattern can be saved if someone really
  needs day to date. if daily periodicity, we simply insert one row for this day.
  open issue: is this functionality needed for the lowest level periodicity. say a kpi is monthly, quarterly, yearly. user chooses
  MTD. do they expect to see non xtd value, ie, just the month aggregation? for now, we do this only for daily periodicity
  */
  if is_daily_periodicity(p_xtd_periodicity) then
    populate_rpt_keys_daily(p_table_name,p_session_id,l_calendar_id,p_report_date,p_num_report_date,p_xtd_period,p_xtd_year,p_xtd_periodicity,p_xtd_type);
  else
    --3919980
    if p_xtd_type='ROLLING' then
      l_orig_periodicity:=l_periodicity;
      l_orig_period_type_id:=l_period_type_id;
      l_orig_period_column_name:=l_period_column_name;
      l_orig_period_num_of_periods:=l_period_num_of_periods;
      l_orig_num_periodicity:=l_num_periodicity;
    end if;
    --see if this is a avg measure.
    if instr(g_option_string,'AVG MEASURE')>0 then
      --this is an avg column. this means we can only have daily periodicity in the reporting
      --table
      --in this case we only perserve 2 periodicities, the xtd and daily
      declare
        ll_periodicity number_tabletype;
        ll_period_type_id number_tabletype;
        ll_period_column_name varchar_tabletype;
        ll_num_periodicity number;
      begin
        ll_num_periodicity:=0;
        for i in 1..l_num_periodicity loop
          if l_periodicity(i)=p_xtd_periodicity then
            ll_num_periodicity:=ll_num_periodicity+1;
            ll_periodicity(ll_num_periodicity):=l_periodicity(i);
            ll_period_type_id(ll_num_periodicity):=l_period_type_id(i);
            ll_period_column_name(ll_num_periodicity):=l_period_column_name(i);
            exit;
          end if;
        end loop;
        for i in 1..l_num_periodicity loop
          if l_period_type_id(i)=1 and l_periodicity(i)<>p_xtd_periodicity then --this is daily
            ll_num_periodicity:=ll_num_periodicity+1;
            ll_periodicity(ll_num_periodicity):=l_periodicity(i);
            ll_period_type_id(ll_num_periodicity):=l_period_type_id(i);
            ll_period_column_name(ll_num_periodicity):=l_period_column_name(i);
            exit;
          end if;
        end loop;
        l_num_periodicity:=ll_num_periodicity;
        l_periodicity:=ll_periodicity;
        l_period_type_id:=ll_period_type_id;
        l_period_column_name:=ll_period_column_name;
        if g_file and g_debug then
          BSC_im_utils.write_to_log_file_n('This is avg column. The kpi periodicities');
          for i in 1..l_num_periodicity loop
            BSC_im_utils.write_to_log_file(l_periodicity(i)||' '||l_period_type_id(i)||' '||
            l_period_column_name(i));
          end loop;
        end if;
      end;
    end if;
    if l_num_periodicity=0 then
      g_status_message:='No periodicities found for KPI '||p_kpi;
      g_status:=-1;
      return false;
    end if;
    for i in 1..l_num_periodicity loop
      l_periodicity_string:=l_periodicity_string||l_periodicity(i)||',';
    end loop;
    l_periodicity_string:=','||l_periodicity_string;
    open c2(p_xtd_periodicity);
    fetch c2 into l_xtd_pattern;
    close c2;
    if l_xtd_pattern is null then
      g_status_message:='No XTD pattern found for periodicity '||p_xtd_periodicity;
      g_status:=-1;
      return false;
    end if;
    if g_file and g_debug then
      BSC_im_utils.write_to_log_file_n('The XTD pattern for xtd periodicity '||p_xtd_periodicity);
      BSC_im_utils.write_to_log_file(l_xtd_pattern);
    end if;
    --3919980
    if p_xtd_type='ROLLING' and instr(g_option_string,'AVG MEASURE')>0 then
      open c3(l_calendar_id);
      fetch c3 into l_cal_type;
      if l_cal_type='DBI-ENT' then
        l_xtd_pattern:=substr(l_xtd_pattern,instr(l_xtd_pattern,';',-1,2)+1);
      end if;
      if g_file and g_debug then
        BSC_im_utils.write_to_log_file_n('The XTD pattern after filtering for DBI-ENT '||l_xtd_pattern);
      end if;
    end if;
    if parse_values(l_xtd_pattern,';',l_pattern,l_num_pattern)=false then
      g_status:=-1;
      return false;
    end if;
    l_xtd_pattern_value:=null;
    --first try the fast way
    for i in 1..l_num_pattern loop
      l_index:=instr(l_pattern(i),l_periodicity_string);
      if l_index>0 then
        l_start:=instr(l_pattern(i),':',l_index)+1;
        l_end:=length(l_pattern(i))+1;
        l_xtd_pattern_value:=substr(l_pattern(i),l_start,l_end-l_start);
        l_hier:=substr(l_pattern(i),1,l_start-2);
        exit;
      end if;
    end loop;
    if g_file and g_debug then
      BSC_im_utils.write_to_log_file_n('XTD pattern value for BITAND '||l_xtd_pattern_value||',l_hier='||l_hier);
    end if;
    if l_xtd_pattern_value is null then
      --Bug 3294193----------------------------------------
      --try the more complex approach.
      declare
        l_period_parsed number;
        l_pattern_periodicity number_tabletype;--the periodicities in a pattern
        l_num_pattern_periodicity number;
      begin
        if g_file and g_debug then
          BSC_im_utils.write_to_log_file_n('Try more complex approach...');
        end if;
        for i in 1..l_num_pattern loop
          l_rank(i):=0;
          l_index:=0;
          l_index:=instr(l_pattern(i),','||p_xtd_periodicity||',');
          l_num_pattern_periodicity:=0;
          if l_index>0 then
            --parse out all the periodicities in the pattern starting from p_xtd_periodicity
            l_start:=l_index+1;
            loop
              l_count:=l_count+1;
              if l_count>l_max_count then
                BSC_im_utils.write_to_log_file_n('Infinite loop detected');
                g_status_message:='Infinite loop detected';
                return false;
              end if;
              l_start:=instr(l_pattern(i),',',l_start);
              if l_start<=0 then
                exit;
              end if;
              l_start:=l_start+1;
              l_end:=instr(l_pattern(i),',',l_start);
              if l_end>0 then
                l_num_pattern_periodicity:=l_num_pattern_periodicity+1;
                l_pattern_periodicity(l_num_pattern_periodicity):=substr(l_pattern(i),l_start,l_end-l_start);
              else
                exit;
              end if;
            end loop;
            if g_file and g_debug then
              BSC_im_utils.write_to_log_file_n('periodicities parsed out from '||l_pattern(i)||' are ');
              for j in 1..l_num_pattern_periodicity loop
                BSC_im_utils.write_to_log_file(l_pattern_periodicity(j));
              end loop;
            end if;
          end if;
          --for each pattern, check the periodicities in the kpi and see if they exist and give the rank
          if l_num_pattern_periodicity > 0 then
            for j in 1..l_num_pattern_periodicity loop
              l_found:=false;
              for k in 1..l_num_periodicity loop
                if l_periodicity(k)=l_pattern_periodicity(j) then
                  l_found:=true;
                  exit;
                end if;
              end loop;
              if l_found then
                l_rank(i):=l_rank(i)+1;
              else
                l_rank(i):=0;
                exit;
              end if;
            end loop;
          end if;
          --now we have all the ranks. see which one is the largest
        end loop;
        if g_file and g_debug then
          BSC_im_utils.write_to_log_file_n('The ranks');
          for i in 1..l_num_pattern loop
            BSC_im_utils.write_to_log_file(l_pattern(i)||' '||l_rank(i));
          end loop;
        end if;
        l_max_rank:=0;
        l_max_rank_index:=0;
        for i in 1..l_num_pattern loop
          if l_rank(i)>l_max_rank then
            l_max_rank:=l_rank(i);
            l_max_rank_index:=i;
          end if;
        end loop;
        if l_max_rank_index>0 then
          l_start:=instr(l_pattern(l_max_rank_index),':')+1;
          l_end:=length(l_pattern(l_max_rank_index))+1;
          l_xtd_pattern_value:=substr(l_pattern(l_max_rank_index),l_start,l_end-l_start);
          l_hier:=substr(l_pattern(l_max_rank_index),1,l_start-2);
        end if;
        if g_file and g_debug then
          BSC_im_utils.write_to_log_file_n('XTD pattern value for BITAND '||l_xtd_pattern_value||',l_hier='||l_hier);
        end if;
      end;
    end if;
    -----------------------------------------------------
    if l_xtd_pattern_value is null then
      /*due to 2 reasons.
      1. the periodicities arranged in some other order
      2. missing periodicity
      */
      --see if periodicity is arranged in some other order
      if g_file and g_debug then
        BSC_im_utils.write_to_log_file_n('See if periodicities are in random order...');
      end if;
      l_found:=false;
      l_num_pattern_period:=0;
      for i in 1..l_num_pattern loop
        l_start:=2;
        l_count:=0;
        loop
          l_end:=instr(l_pattern(i),',',l_start);
          if l_end<=0 then
            exit;
          end if;
          l_num:=substr(l_pattern(i),l_start,l_end-l_start);
          --l_num_pattern_period will only be used in the section for missing
          --periodicity
          l_num_pattern_period:=l_num_pattern_period+1;
          l_pattern_period_pattern(l_num_pattern_period):=i;
          l_pattern_period_periodicity(l_num_pattern_period):=l_num;
          l_pattern_period_missing(l_num_pattern_period):=false;
          l_found2:=false;--we have to look at at contigous pattern
          for j in 1..l_num_periodicity loop
            if l_periodicity(j)=l_num then
              l_count:=l_count+1;
              l_found2:=true;
              exit;
            end if;
          end loop;
          if l_found2=false then
            l_count:=0;
          end if;
          if l_count=l_num_periodicity then
            --contigous periodicities found. end of search
            l_start:=instr(l_pattern(i),':',l_end)+1;
            l_end:=length(l_pattern(i))+1;
            l_xtd_pattern_value:=substr(l_pattern(i),l_start,l_end-l_start);
            l_hier:=substr(l_pattern(i),1,l_start-2);
            l_found:=true;
            exit;
          end if;
          l_start:=l_end+1;
        end loop;
        if l_found then
          exit;
        end if;
      end loop;
      if g_file and g_debug then
        BSC_im_utils.write_to_log_file_n('After looking for periodicities in different order '||
        'XTD pattern value for BITAND '||l_xtd_pattern_value||',l_hier='||l_hier);
      end if;
    end if;
    ---------------------------------------
    --find the missing periodicities
    --need more complex logic due to Bug 3294193
    if l_xtd_pattern_value is null then
      --there is missing periodicity
      --l_period_missing
      if g_file and g_debug then
        BSC_im_utils.write_to_log_file_n('Check for missing periodicity...');
      end if;
      l_periodicity_missing:=true;--this is used as a main flag to indiate that there is missing periodicity
      if g_file and g_debug then
        BSC_im_utils.write_to_log_file_n('The denormalized array of pattern and the periodicity in it');
        for i in 1..l_num_pattern_period loop
          BSC_im_utils.write_to_log_file(l_pattern_period_pattern(i)||' '||l_pattern_period_periodicity(i));
        end loop;
      end if;
      for i in 1..l_num_pattern loop
        l_rank(i):=0;
        if instr(l_pattern(i),','||p_xtd_periodicity||',')>0 then
          l_found:=false;
          for j in 1..l_num_pattern_period loop
            if l_pattern_period_pattern(j)=i then
              if l_found then --this starts only after we are past p_xtd_periodicity in the de-norm array
                l_found2:=false;
                for k in 1..l_num_periodicity loop
                  if l_pattern_period_periodicity(j)=l_periodicity(k) then
                    l_found2:=true;
                    exit;
                  end if;
                end loop;
                if l_found2=false then
                  l_rank(i):=l_rank(i)+1;
                end if;
              end if;
              if l_pattern_period_periodicity(j)=p_xtd_periodicity then
                l_found:=true;
              end if;
            end if;
          end loop;
        end if;
        if g_file and g_debug then
          BSC_im_utils.write_to_log_file_n('The rank for pattern '||l_pattern(i)||' '||l_rank(i));
        end if;
      end loop;
      --find min rank
      l_min_rank:=1000000;
      l_min_rank_index:=0;
      for i in 1..l_num_pattern loop
        if l_rank(i)>0 and l_rank(i)<l_min_rank then
          l_min_rank:=l_rank(i);
          l_min_rank_index:=i;
        end if;
      end loop;
      if l_min_rank_index=0 then
        g_status_message:='Could not find any pattern to use. Min rank=0 ';
        BSC_im_utils.write_to_log_file_n(g_status_message);
        return false;
      end if;
      if g_file and g_debug then
        BSC_im_utils.write_to_log_file_n('Min rank '||l_min_rank||' and min rank pattern '||
        l_pattern(l_min_rank_index));
      end if;
      l_pattern_to_use:=l_min_rank_index;
      l_xtd_pattern_value:=substr(l_pattern(l_pattern_to_use),instr(l_pattern(l_pattern_to_use),':')+1,length(
      l_pattern(l_pattern_to_use)));
      l_hier:=substr(l_pattern(l_pattern_to_use),1,instr(l_pattern(l_pattern_to_use),':')-1);
      if g_file and g_debug then
        BSC_im_utils.write_to_log_file_n('After looking for Missing periodicities  '||
        'XTD pattern value for BITAND '||l_xtd_pattern_value||',l_hier='||l_hier);
      end if;
      --find missing periodicities
      for i in 1..l_num_pattern_period loop
        if l_pattern_period_pattern(i)=l_pattern_to_use then
          l_pattern_period_missing(i):=true;
          for j in 1..l_num_periodicity loop
            if l_periodicity(j)=l_pattern_period_periodicity(i) then
              l_pattern_period_missing(i):=false;
              exit;
            end if;
          end loop;
        end if;
      end loop;
      for i in 1..l_num_pattern_period loop
        if l_pattern_period_pattern(i)=l_pattern_to_use then
          ll_num_temp_pattern_period:=ll_num_temp_pattern_period+1;
          ll_temp_period_pattern(ll_num_temp_pattern_period):=l_pattern_period_pattern(i);
          ll_temp_period_periodicity(ll_num_temp_pattern_period):=l_pattern_period_periodicity(i);
          ll_temp_period_missing(ll_num_temp_pattern_period):=l_pattern_period_missing(i);
        end if;
      end loop;
      if g_file and g_debug then
        BSC_im_utils.write_to_log_file_n('Missing periodicities');
        for i in 1..l_num_pattern_period loop
          if l_pattern_period_pattern(i)=l_pattern_to_use and l_pattern_period_missing(i) then
            BSC_im_utils.write_to_log_file(l_pattern_period_periodicity(i));
          end if;
        end loop;
      end if;
    end if;--if l_xtd_pattern_value is null then
    ---------------------------------------
    --missing periodicities handled inside insert_rpt_cal_keys
    for i in 1..p_num_report_date loop
      if insert_rpt_cal_keys(
        p_table_name,
        p_report_date(i),
        p_report_date(i),--this is inserted into report_date col in bsc_rpt_keys_table
        p_xtd_periodicity,
        p_xtd_period(i),
        p_xtd_year(i),
        l_hier,
        l_xtd_pattern_value,
        l_calendar_id,
        'N',
        l_periodicity_missing,
        ll_temp_period_periodicity,
        ll_temp_period_missing,
        ll_num_temp_pattern_period
        )=false then
        return false;
      end if;
    end loop;
    if p_xtd_type='ROLLING' then
      if populate_rolling_rpt_keys(
        p_table_name,
        p_session_id,
        l_hier,
        l_xtd_pattern_value,
        l_calendar_id,
        p_report_date,
        p_num_report_date,
        p_xtd_period,
        p_xtd_year,
        p_xtd_periodicity,
        l_orig_periodicity,--3919980
        l_orig_period_num_of_periods,--3919980
        l_orig_num_periodicity,--3919980
        l_periodicity_missing,
        ll_temp_period_periodicity,
        ll_temp_period_missing,
        ll_num_temp_pattern_period
        )=false then
        raise e_error;
      end if;
    end if;
  end if;
  --add to the global variables
  for i in 1..p_num_report_date loop
    if g_num_kpi_xtd=0 then
      g_kpi_xtd:=xtd_record_table();
    end if;
    g_num_kpi_xtd:=g_num_kpi_xtd+1;
    g_kpi_xtd.extend;
    g_kpi_xtd(g_num_kpi_xtd).session_id:=p_session_id;
    g_kpi_xtd(g_num_kpi_xtd).kpi:=p_kpi;
    g_kpi_xtd(g_num_kpi_xtd).report_date:=p_report_date(i);
    g_kpi_xtd(g_num_kpi_xtd).xtd_periodicity:=p_xtd_periodicity;
    /*
    here we are not caching if its xtd or rolling xtd. we dont want to have a situation
    where there is rolling xtd and xtd for the same as of date
    pmv is not filtering on the bsc_rpt_keys table with rolling_flag
    so if pmv wants to go from rolling xtd on a as of date to xtd on the same as of date, they
    must first clean up the table
    */
  end loop;
  return true;
Exception
 when e_error then
   g_status_message:=sqlerrm;
   if g_file and g_debug then
     BSC_im_utils.write_to_log_file_n(g_status_message);
   end if;
   raise;
 when others then
   g_status_message:=sqlerrm;
   if g_file and g_debug then
     BSC_im_utils.write_to_log_file_n(g_status_message);
   end if;
  raise;
End;

/*
Bug 4449784
*/
function is_daily_periodicity(p_periodicity number) return boolean is
l_period_type_id number;
Begin
  select period_type_id into l_period_type_id from bsc_sys_periodicities where periodicity_id=p_periodicity;
  if l_period_type_id=1 then
    return true;
  else
    return false;
  end if;
Exception when others then
  if g_file and g_debug then
    BSC_im_utils.write_to_log_file_n('Error in is_daily_periodicity '||sqlerrm);
  end if;
  raise;
End;
/*
Bug 4449784
*/
procedure populate_rpt_keys_daily(
p_table_name varchar2,--name of the rpt_cal_keys table
p_session_id number,
p_calendar_id number,
p_report_date date_tabletype,
p_num_report_date number,
p_xtd_period number_tabletype,--use p_num_report_date for count
p_xtd_year number_tabletype,--use p_num_report_date for count
p_xtd_periodicity number,
p_xtd_type varchar2
) is
l_stmt varchar2(10000);
Begin
  for i in 1..p_num_report_date loop
    l_stmt:='insert into bsc_rpt_keys(session_id,report_date,xtd_periodicity,'||
    'xtd_period,xtd_year,period,year,period_type_id,periodicity_id,period_flag,day_count,rolling_flag,last_update_date) '||
    'select :1,:2,:3,:4,:5,max(period),max(year),1,:6,1,1,''N'',sysdate from bsc_reporting_calendar where '||
    'calendar_id=:7 and report_date=:8 and period_type_id=1 and rolling_flag=''N''';
    if g_file and g_debug then
      BSC_im_utils.write_to_log_file(l_stmt||' using '||
      p_session_id||' '||p_report_date(i)||' '||p_xtd_periodicity||' '||p_xtd_period(i)||' '||p_xtd_year(i)||' '||p_xtd_periodicity||' '||
      p_calendar_id||' '||p_report_date(i));
    end if;
    execute immediate l_stmt using p_session_id,p_report_date(i),p_xtd_periodicity,p_xtd_period(i),p_xtd_year(i),p_xtd_periodicity,
    p_calendar_id,p_report_date(i);
    if g_file and g_debug then
      BSC_im_utils.write_to_log_file_n('Inserted(Daily) '||sql%rowcount||' rows '||get_time);
    end if;
  end loop;
Exception when others then
  if g_file and g_debug then
    BSC_im_utils.write_to_log_file_n('Error in populate_rpt_keys_daily '||sqlerrm);
  end if;
  raise;
End;

function insert_rpt_cal_keys(
p_table_name varchar2,
p_report_date date,--used to join with bsc_reporting_calendar
p_report_date_insert date,--used to insert into bsc_rpt_keys table
p_xtd_periodicity number,
p_xtd_period number,
p_xtd_year number,
p_hier varchar2,
p_xtd_pattern number,
p_calendar_id number,
p_roll_flag varchar2,
p_periodicity_missing boolean,
p_period_periodicity number_tabletype,
p_period_missing boolean_tabletype,
p_num_pattern_period number
)return boolean is
----------
l_status number;
l_stmt varchar2(4000);
----------
l_start number;
--
Begin
  if g_file and g_debug then
    BSC_im_utils.write_to_log_file_n('In insert_rpt_cal_keys p_xtd_periodicity='||
    p_xtd_periodicity||',p_hier='||p_hier||
    ',p_xtd_pattern='||p_xtd_pattern||',p_calendar_id='||p_calendar_id||',p_roll_flag='||p_roll_flag||get_time);
    BSC_im_utils.write_to_log_file(p_report_date||' '||p_report_date_insert||' '||p_xtd_period||' '||p_xtd_year);
    if p_periodicity_missing then
      BSC_im_utils.write_to_log_file('p_periodicity_missing=TRUE');
    else
      BSC_im_utils.write_to_log_file('p_periodicity_missing=FALSE');
    end if;
    for i in 1..p_num_pattern_period loop
      BSC_im_utils.write_to_log_file('p_period_periodicity(i)='||p_period_periodicity(i));
      if p_period_missing(i) then
        BSC_im_utils.write_to_log_file('p_period_missing(i)=TRUE');
      end if;
    end loop;
  end if;
  --with the global g_kpi_xtd, check_rpt_cal_keys is really not reqd.
  --we keep it here for added security
  if l_status=-1 then
    return false;
  end if;
  if l_status is null then
    --need to load into the cal keys table
    if g_file and g_debug then
      BSC_im_utils.write_to_log_file_n('insert into bsc_rpt_keys(session_id,report_date,'||
      'xtd_periodicity,xtd_period,xtd_year,period,year,period_type_id,periodicity_id,day_count,rolling_flag,last_update_date) '||
      'select '||g_session_id||',p_report_date_insert,'||p_xtd_periodicity||',p_xtd_period,p_xtd_year,'||
      'period,year,period_type_id,periodicity_id,day_count,rolling_flag,sysdate from bsc_reporting_calendar where '||
      'calendar_id='||p_calendar_id||' and report_date=p_report_date and hierarchy='||p_hier||
      'and rolling_flag='||p_roll_flag||' and bitand(record_type_id,'||p_xtd_pattern||')=record_type_id');
      BSC_im_utils.write_to_log_file(p_report_date||' '||p_report_date_insert||' '||p_xtd_period||' '||p_xtd_year);
    end if;
    --need to make compatible with 8i. cannot have forall stmt. 8i does not allow execute immediate inside forall
    --forall i in 1..p_num_report_date
    execute immediate 'insert into bsc_rpt_keys(session_id,report_date,xtd_periodicity,'||
    'xtd_period,xtd_year,period,year,period_type_id,periodicity_id,period_flag,day_count,rolling_flag,last_update_date) '||
    'select :1,:2,:3,:4,:5,period,year,period_type_id,periodicity_id,0,day_count,rolling_flag,'||
    'sysdate from bsc_reporting_calendar where '||
    'calendar_id=:6 and report_date=:7 and hierarchy=:8 and rolling_flag=:9 '||
    'and bitand(record_type_id,:10)=record_type_id'
    using g_session_id,p_report_date_insert,p_xtd_periodicity,p_xtd_period,p_xtd_year,p_calendar_id,
    p_report_date,p_hier,p_roll_flag,p_xtd_pattern;
    if g_file and g_debug then
      BSC_im_utils.write_to_log_file_n('Inserted '||sql%rowcount||' rows '||get_time);
    end if;
    if p_roll_flag<>'Y' then
      --update the period flag for the current day
      --get the max of the period where the period_type_id is 1 or daily
      --period_type_id of 1 is daily
      l_stmt:='update '||p_table_name||' set period_flag=1 '||
      'where session_id=:1 '||
      'and report_date=:2 '||
      'and xtd_periodicity=:3 '||
      'and period_type_id=1 '||
      'and rolling_flag=:4 '||
      'and period=(select max(period) '||
      'from '||p_table_name||' where session_id=:5 '||
      'and report_date=:6 '||
      'and xtd_periodicity=:7 and period_type_id=1 and rolling_flag=:8)';
      if g_file and g_debug then
        BSC_im_utils.write_to_log_file_n(l_stmt||' using '||g_session_id||',p_report_date_insert,'||p_xtd_periodicity||
        p_roll_flag||','||g_session_id||',p_report_date_insert,'||p_xtd_periodicity||','||p_roll_flag);
      end if;
      --need to make compatible with 8i. cannot have forall stmt. 8i does not allow execute immediate inside forall
      --forall i in 1..p_num_report_date
      execute immediate l_stmt using g_session_id,p_report_date_insert,p_xtd_periodicity,p_roll_flag,
      g_session_id,p_report_date_insert,p_xtd_periodicity,p_roll_flag;
      if g_file and g_debug then
        BSC_im_utils.write_to_log_file_n('Updated '||sql%rowcount||' rows '||get_time);
      end if;
    end if;
    if p_periodicity_missing then
      --we need to do post processing
      /*
      two aspects to keep in mind
      - p_xtd_periodicity cannot be outside the periodicity of the kpi
      - all kpi periodicity must be in the periodicity of the pattern
      */
      l_start:=1;
      for i in 1..p_num_pattern_period loop
        if p_period_periodicity(i)=p_xtd_periodicity then
          l_start:=i+1;
          exit;
        end if;
      end loop;
      for i in l_start..p_num_pattern_period loop
        if p_period_missing(i) then
          for j in i+1..p_num_pattern_period loop
            if p_period_missing(j)=false then
              if correct_rpt_cal_keys(
                p_table_name,
                p_report_date_insert,
                p_xtd_periodicity,
                p_period_periodicity(i),--missing
                p_period_periodicity(j),--present
                p_calendar_id,
                p_roll_flag)=false then
                --'N')=false then --3919980
                return false;
              end if;
              exit;
            end if;
          end loop;
        end if;
      end loop;
    end if;
  else
    if g_file and g_debug then
      BSC_im_utils.write_to_log_file_n('Data already in rpt cal keys.');
    end if;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=-1;
  if g_file and g_debug then
    BSC_im_utils.write_to_log_file_n(g_status_message);
  end if;
  return false;
End;

function correct_rpt_cal_keys(
p_table_name varchar2,
p_report_date date,
p_xtd_periodicity number,
p_periodicity_missing number,
p_periodicity_present number,
p_calendar_id number,
p_roll_flag varchar2
)return boolean is
--------
cursor c1(p_periodicity_id number) is
select period_type_id,periodicity_id,db_column_name from bsc_sys_periodicities where periodicity_id=p_periodicity_id;
--------
l_pid_missing number;
l_periodicity_missing number;
l_db_column_missing varchar2(200);
l_pid_present number;
l_periodicity_present number;
l_db_column_present varchar2(200);
-----
l_stmt varchar2(8000);
-----
--
Begin
  if g_file and g_debug then
    BSC_im_utils.write_to_log_file_n('In correct_rpt_cal_keys,p_xtd_periodicity='||p_xtd_periodicity||
    ',p_periodicity_missing='||p_periodicity_missing||',p_periodicity_present='||p_periodicity_present||
    ',p_calendar_id='||p_calendar_id);
  end if;
  open c1(p_periodicity_missing);
  fetch c1 into l_pid_missing,l_periodicity_missing,l_db_column_missing;
  close c1;
  open c1(p_periodicity_present);
  fetch c1 into l_pid_present,l_periodicity_present,l_db_column_present;
  close c1;
  if g_file and g_debug then
    BSC_im_utils.write_to_log_file_n('Missing period type id and db column name');
    BSC_im_utils.write_to_log_file(l_pid_missing||' '||l_periodicity_missing||' '||l_db_column_missing);
    BSC_im_utils.write_to_log_file_n('Present period type id and db column name');
    BSC_im_utils.write_to_log_file(l_pid_present||' '||l_periodicity_present||' '||l_db_column_present);
  end if;
  l_stmt:='insert into bsc_rpt_keys(session_id,report_date,xtd_periodicity,xtd_period,xtd_year,period,year,'||
  --'period_type_id,periodicity_id,period_flag,period_day_count,last_update_date) '||
  'period_type_id,periodicity_id,period_flag,day_count,rolling_flag,last_update_date) '||
  'select rpt.session_id,rpt.report_date,rpt.xtd_periodicity,'||
  'rpt.xtd_period,rpt.xtd_year,cal.'||l_db_column_present||',rpt.year,:2,:3,0,cal.day_count,rpt.rolling_flag,:4 from '||
  '(select '||l_db_column_present||','||l_db_column_missing||',year,count(*) day_count from bsc_db_calendar where '||
  'calendar_id=:5 group by '||l_db_column_present||','||l_db_column_missing||',year) cal,'||
  p_table_name||' rpt where cal.'||l_db_column_missing||'='||
  'rpt.period and cal.year=rpt.year and rpt.period_type_id=:6 and rpt.report_date=:7 and rpt.session_id=:8 and '||
  'rpt.xtd_periodicity=:9 and rpt.rolling_flag=:10';
  if g_file and g_debug then
    BSC_im_utils.write_to_log_file_n(l_stmt||' using '||l_pid_present||','||l_periodicity_present||',sysdate,'||
    p_calendar_id||','||l_pid_missing||','||p_report_date||','||g_session_id||','||p_xtd_periodicity||','||p_roll_flag);
    BSC_im_utils.write_to_log_file(p_report_date);
  end if;
  --need to make compatible with 8i. cannot have forall stmt. 8i does not allow execute immediate inside forall
  --forall i in 1..p_num_report_date
  execute immediate l_stmt using l_pid_present,l_periodicity_present,sysdate,p_calendar_id,
  l_pid_missing,p_report_date,g_session_id,p_xtd_periodicity,p_roll_flag;
  if g_file and g_debug then
    BSC_im_utils.write_to_log_file_n('Inserted '||sql%rowcount||' rows '||get_time);
  end if;
  l_stmt:='delete '||p_table_name||' where session_id=:1 and report_date=:2 and xtd_periodicity=:3 and '||
  'period_type_id=:4 and rolling_flag=:5';
  if g_file and g_debug then
    BSC_im_utils.write_to_log_file_n(l_stmt||' '||g_session_id||',p_report_date,'||p_xtd_periodicity||
    l_pid_missing||','||p_roll_flag);
    BSC_im_utils.write_to_log_file(p_report_date);
  end if;
  --need to make compatible with 8i. cannot have forall stmt. 8i does not allow execute immediate inside forall
  --forall i in 1..p_num_report_date
  execute immediate l_stmt using g_session_id,p_report_date,p_xtd_periodicity,l_pid_missing,p_roll_flag;
  if g_file and g_debug then
    BSC_im_utils.write_to_log_file_n('Deleted '||sql%rowcount||' rows '||get_time);
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=-1;
  if g_file and g_debug then
    BSC_im_utils.write_to_log_file_n(g_status_message);
  end if;
  return false;
End;

/*
  if rolling is specified, further processing needed
  logic...
  get xtd_count (from day_count)
  if xtd_count=g_roll_count  --30 day of month for rolling month etc
     XTD
  else
    load RTD
    get roll_count
    if xtd_count<g_roll_count --most of the time
      XTD+RTD
    elsif xtd_count>g_roll_count and roll_count<=g_roll_count --31 of month
      RTD
    else --very few cases. only 91 day for qtr
      --complicated...need to subtract
      break up all periodicities to days and then subtract
    end if;
  end if;
*/
function populate_rolling_rpt_keys(
p_table_name varchar2,--name of the rpt_cal_keys table
p_session_id number,
p_hier varchar2,
p_xtd_pattern varchar2,
p_calendar_id number,
p_report_date date_tabletype,
p_num_report_date number,
p_xtd_period number_tabletype,--use p_num_report_date for count
p_xtd_year number_tabletype,--use p_num_report_date for count
p_xtd_periodicity number,
p_periodicity number_tabletype,
p_period_num_of_periods number_tabletype,
p_num_periodicity number,
p_periodicity_missing boolean,
p_period_periodicity number_tabletype,
p_period_missing boolean_tabletype,
p_num_pattern_period number
)return boolean is
--
l_xtd_count number;
l_rtd_count number;
--
----
l_num_periods number;
l_roll_range number;
l_roll_date date;
----
Begin
  if g_file and g_debug then
    BSC_im_utils.write_to_log_file_n('In populate_rolling_rpt_keys');
  end if;
  --get xtd count
  if g_debug then
    BSC_im_utils.write_to_log_file_n('p_xtd_periodicity='||p_xtd_periodicity);
    for i in 1..p_num_periodicity loop
      BSC_im_utils.write_to_log_file('p_periodicity(i)='||p_periodicity(i)||',p_period_num_of_periods(i)='||p_period_num_of_periods(i));
    end loop;
  end if;
  for i in 1..p_num_periodicity loop
    if p_xtd_periodicity=p_periodicity(i) then
      l_num_periods:=p_period_num_of_periods(i);
      exit;
    end if;
  end loop;
  if l_num_periods is null then
    null;
  end if;
  if g_debug then
    BSC_im_utils.write_to_log_file_n('l_num_periods ='||l_num_periods);
  end if;
  ---------hard coded part------------------
  if l_num_periods=1 then --rolling year
    l_roll_range:=g_roll_year_range;
  elsif l_num_periods=4 then
    l_roll_range:=g_roll_qtr_range;
  elsif l_num_periods=12 then
    l_roll_range:=g_roll_period_range;
  elsif l_num_periods>=52 and l_num_periods<=55 then
    l_roll_range:=g_roll_week_range;
  else
    return false;
  end if;
  if g_file and g_debug then
    BSC_im_utils.write_to_log_file('l_roll_range='||l_roll_range);
  end if;
  ------------------------------------------
  for i in 1..p_num_report_date loop
    --
    l_xtd_count:=get_day_count(p_table_name,p_session_id,p_report_date(i),'N');
    --
    if l_xtd_count=l_roll_range then
      --XTD
      if g_file and g_debug then
        BSC_im_utils.write_to_log_file_n('Only XTD');
      end if;
      return true;
    else
      l_roll_date:=p_report_date(i)-l_roll_range+1;
      if g_file and g_debug then
        BSC_im_utils.write_to_log_file('l_roll_date='||l_roll_date);
      end if;
      --load RTD
      --for rolling, there should be no missing periodicities since the calendar will have all
      --the periodicities, daily,weekly,montly,quarterly and yearly
      if insert_rpt_cal_keys(
        p_table_name,
        l_roll_date,
        p_report_date(i),--this is inserted in report_date col of bsc_rpt_keys table
        p_xtd_periodicity,
        p_xtd_period(i),
        p_xtd_year(i),
        p_hier,
        p_xtd_pattern,
        p_calendar_id,
        'Y',--'Y'
        p_periodicity_missing,
        p_period_periodicity,
        p_period_missing,
        p_num_pattern_period
        )=false then
        return false;
      end if;
      if l_xtd_count<l_roll_range then
        --xtd+rtd. this will be most common case
        if g_file and g_debug then
          BSC_im_utils.write_to_log_file_n('XTD+RTD...most common case');
        end if;
        --if the type is rolling and this is week, need to make sure that
        --l_rtd_count+l_xtd_count=7. we need to test for this only if
        --l_roll_date is between 26 dec and 31 dec
        --3919980
        -----------------
        /*ideally we can check generically to see if xtd count + rtd count matches the roll range. but for perf, since only few cases will need the
        test, we will check specifically these cases . the api correct_rolling_data is generic though*/
        if l_roll_range=g_roll_week_range then
          if l_roll_date > to_date('12/25/'||to_char(l_roll_date,'YYYY'),'MM/DD/YYYY') then
            if g_file and g_debug then
              BSC_im_utils.write_to_log_file_n('WTD and l_roll_date >= 26 dec');
            end if;
            l_rtd_count:=get_day_count(p_table_name,p_session_id,p_report_date(i),'Y');
            if l_xtd_count+l_rtd_count < g_roll_week_range then
              if g_debug then
                BSC_im_utils.write_to_log_file('l_xtd_count('||l_xtd_count||')+l_rtd_count('||l_rtd_count||') < '||
                'g_roll_week_range('||g_roll_week_range||')');
              end if;
              --4968072
              correct_rolling_data(p_table_name,p_session_id,p_report_date(i),l_roll_date,p_xtd_periodicity,p_xtd_period(i),
              p_xtd_year(i),p_hier,p_xtd_pattern,p_calendar_id,p_periodicity_missing,p_period_periodicity,p_period_missing,p_num_pattern_period);
            end if;
          end if;
        elsif l_roll_range=g_roll_period_range then /*mtd and march 1 and feb contains 28 days. we skip the test for feb 28 days */
          if l_roll_date = to_date('01/31/'||to_char(l_roll_date,'YYYY'),'MM/DD/YYYY') then
            if g_file and g_debug then
              BSC_im_utils.write_to_log_file_n('MTD and l_roll_date = 31 Jan');
            end if;
            l_rtd_count:=get_day_count(p_table_name,p_session_id,p_report_date(i),'Y');
            if l_xtd_count+l_rtd_count < g_roll_period_range then
              if g_debug then
                BSC_im_utils.write_to_log_file('l_xtd_count('||l_xtd_count||')+l_rtd_count('||l_rtd_count||') < '||
                'g_roll_period_range('||g_roll_period_range||')');
              end if;
              --4968072
              correct_rolling_data(p_table_name,p_session_id,p_report_date(i),l_roll_date,p_xtd_periodicity,p_xtd_period(i),
              p_xtd_year(i),p_hier,p_xtd_pattern,p_calendar_id,p_periodicity_missing,p_period_periodicity,p_period_missing,p_num_pattern_period);
            end if;
          end if;
        end if;
        -----------------
      else
        --now, get the RTD count
        l_rtd_count:=get_day_count(p_table_name,p_session_id,p_report_date(i),'Y');
        if g_file and g_debug then
          BSC_im_utils.write_to_log_file_n('RTD count='||l_rtd_count);
        end if;
        if l_rtd_count<=l_roll_range then --like 31 mar or 92 day of qtr, 366 day of year
          --only RTD, delete XTD
          if g_file and g_debug then
            BSC_im_utils.write_to_log_file_n('Only RTD');
          end if;
          delete_table(p_table_name,p_session_id,p_report_date(i),'N');
        else
          --l_xtd_count>l_roll_range and l_rtd_count>l_roll_range
          --complex case. very few. like 91 day of a 92 day qtr. neither fully xtd or rtd
          --first, delete the RTD
          if g_file and g_debug then
            BSC_im_utils.write_to_log_file_n('Complex...XTD + Delete OR RTD + Delete');
          end if;
          correct_rolling_data_92_91(p_table_name);
        end if;
      end if;
    end if;
  end loop;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=-1;
  if g_file and g_debug then
    BSC_im_utils.write_to_log_file_n(g_status_message);
  end if;
  return false;
End;

procedure correct_rolling_data_92_91(
p_table_name varchar2
) is
--
l_stmt varchar2(4000);
--
Begin
  --delete the row for month Sep for roll=Y
  l_stmt:='delete '||p_table_name||' where period_type_id=32 and rolling_flag=''Y'' and period in '||
  '(select max(period) from '||p_table_name||' where period_type_id=32 and rolling_flag=''Y'')';
  if g_file and g_debug then
    BSC_im_utils.write_to_log_file_n(l_stmt);
  end if;
  execute immediate l_stmt;
  --delete the row for month Aug for roll=Y. aug is present for roll=N
  l_stmt:='delete '||p_table_name||' where period_type_id=32 and rolling_flag=''Y'' and period in '||
  '(select max(period) from '||p_table_name||' where period_type_id=32 and rolling_flag=''Y'')';
  if g_file and g_debug then
    BSC_im_utils.write_to_log_file_n(l_stmt);
  end if;
  execute immediate l_stmt;
  --delete the row for July for roll=N
  l_stmt:='delete '||p_table_name||' where period_type_id=32 and rolling_flag=''N'' and period in '||
  '(select min(period) from '||p_table_name||' where period_type_id=32 and rolling_flag=''N'')';
  if g_file and g_debug then
    BSC_im_utils.write_to_log_file_n(l_stmt);
  end if;
  execute immediate l_stmt;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=-1;
  if g_file and g_debug then
    BSC_im_utils.write_to_log_file_n('Error in correct_rolling_data_92_91 '||g_status_message);
  end if;
  raise;
End;

--3919980
/*4968072 : the earlier logic of inserting
for i in 1..(p_reqd_count-p_current_count) loop
  execute immediate l_stmt using l_period+i...
is not correct. consider jan 2 2006. we want rolling wtd. week starts on jan 2. jan 2 - 6 gives dec 27. we do wtd as of jan 2 and
then rwtd as of dec 27. we miss out jan 1. earlier logic was assuming that we are considering the case where week in 2005 is ending before
dec 31.
best soln is to have a generic day filler given 2 dates. this can be expensive because we have to go to db calendar
this api is called only in the year boundary for weeks on rolling mtd for mar 1 (missing out feb completely). so the api will be specific
--
after thinking through, this algo will be implented
xtd date =A and Rtd=B
--|-----|-----||----|----|---
  B    Bs     YB    As   A
or
--|-----|---------|----|---
  B    Bs        As   A
or
--|-----|--------|---
  B    Bs=As     A

Bs=start period for B. As=start period for A.
we get daycount for A. subtract to get As. we get daycount for B, add to get Bs
we follow this logic
Bs=Bs+1
if Bs<As
  loop
    RTD(Bs)
    get daycount for Bs=Ds
    Bs=Bs+Ds
    if Bs>=As
      exit
    end if
  end loop
end if
This makes the api absolutely generic. given 2 dates, it fill any missing values
*/
procedure correct_rolling_data(
p_table_name varchar2,
p_session_id number,
p_xtd_report_date date,
p_rtd_report_date date,
p_xtd_periodicity number,
p_xtd_period number,
p_xtd_year number,
p_hier varchar2,
p_xtd_pattern number,
p_calendar_id number,
p_periodicity_missing boolean,
p_period_periodicity number_tabletype,
p_period_missing boolean_tabletype,
p_num_pattern_period number
) is
--
l_prev_day_count number;
l_day_count number;
l_Bs_date date;
l_As_date date;
Begin
  if g_file and g_debug then
    BSC_im_utils.write_to_log_file_n('In correct_rolling_data xtd date='||to_char(p_xtd_report_date,'MM/DD/YYYY')||
    ', rtd date='||to_char(p_rtd_report_date,'MM/DD/YYYY')||' and periodicity='||p_xtd_periodicity);
  end if;
  l_day_count:=get_day_count(p_table_name,p_session_id,p_xtd_report_date,'N');
  l_As_date:=p_xtd_report_date-l_day_count+1;
  l_day_count:=get_day_count(p_table_name,p_session_id,p_xtd_report_date,'Y');
  l_prev_day_count:=l_day_count;
  l_Bs_date:=p_rtd_report_date+l_day_count-1;
  if g_file and g_debug then
    BSC_im_utils.write_to_log_file('l_As_date='||to_char(l_As_date,'MM/DD/YYYY')||', l_Bs_date='||to_char(l_Bs_date,'MM/DD/YYYY'));
  end if;
  l_Bs_date:=l_Bs_date+1;
  if l_Bs_date<l_As_date then
    loop
      if insert_rpt_cal_keys(
        p_table_name,
        l_Bs_date,
        p_xtd_report_date,--this is inserted in report_date col of bsc_rpt_keys table
        p_xtd_periodicity,
        p_xtd_period,
        p_xtd_year,
        p_hier,
        p_xtd_pattern,
        p_calendar_id,
        'Y',
        p_periodicity_missing,
        p_period_periodicity,
        p_period_missing,
        p_num_pattern_period
        )=false then
        raise g_exception;
      end if;
      l_day_count:=get_day_count(p_table_name,p_session_id,p_xtd_report_date,'Y');
      l_day_count:=l_day_count-l_prev_day_count;
      if g_file and g_debug then
        BSC_im_utils.write_to_log_file('Loop done , day count='||l_day_count);
      end if;
      if l_day_count>0 then
        l_prev_day_count:=l_prev_day_count+l_day_count;
        l_Bs_date:=l_Bs_date+l_day_count;
        if g_file and g_debug then
          BSC_im_utils.write_to_log_file('New l_Bs_date='||to_char(l_Bs_date,'MM/DD/YYYY'));
        end if;
        if l_Bs_date>=l_As_date then
          exit;
        end if;
      else
        exit;
      end if;
    end loop;
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=-1;
  if g_file and g_debug then
    BSC_im_utils.write_to_log_file_n('Error in correct_rolling_data '||g_status_message);
  end if;
  raise;
End;

function get_day_count(
p_table_name varchar2,
p_session_id number,
p_report_date date,
p_roll_flag varchar2) return number is
--
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_stmt varchar2(5000);
--
l_xtd_count number;
Begin
  l_stmt:='select sum(day_count) from '||p_table_name||' where session_id=:1 and report_date=:2 and rolling_flag=:3';
  if g_file and g_debug then
    BSC_im_utils.write_to_log_file_n(l_stmt||' '||p_session_id||' '||p_report_date||' '||p_roll_flag);
  end if;
  open cv for l_stmt using p_session_id,p_report_date,p_roll_flag;
  fetch cv into l_xtd_count;
  close cv;
  if g_file and g_debug then
    BSC_im_utils.write_to_log_file('l_xtd_count='||l_xtd_count);
  end if;
  return l_xtd_count;
Exception when others then
  if g_file and g_debug then
    BSC_im_utils.write_to_log_file_n(sqlerrm);
  end if;
  return null;
End;

procedure delete_table(
p_table_name varchar2,
p_session_id number,
p_report_date date,
p_roll_flag varchar2) is
--
l_stmt varchar2(5000);
--
Begin
  l_stmt:='delete '||p_table_name||' where session_id=:1 and report_date=:2 and rolling_flag=:3';
  if g_file and g_debug then
    BSC_im_utils.write_to_log_file_n(l_stmt||' '||p_session_id||' '||p_report_date||' '||p_roll_flag);
  end if;
  execute immediate l_stmt using p_session_id,p_report_date,p_roll_flag;
  if g_file and g_debug then
    BSC_im_utils.write_to_log_file_n('Deleted '||sql%rowcount||' rows ');
  end if;
Exception when others then
  if g_file and g_debug then
    BSC_im_utils.write_to_log_file_n(sqlerrm);
  end if;
  raise;
End;

function parse_values(
p_list varchar2,
p_separator varchar2,
p_names out nocopy number_tabletype,
p_number_names out nocopy number) return boolean is
l_names varchar_tabletype;
Begin
  if parse_values(p_list,p_separator,l_names,p_number_names)=false then
    return false;
  end if;
  for i in 1..p_number_names loop
    p_names(i):=l_names(i);
  end loop;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  return false;
End;
function parse_values(
p_list varchar2,
p_separator varchar2,
p_names out nocopy varchar_tabletype,
p_number_names out nocopy number) return boolean is
l_start number;
l_end number;
l_len number;
Begin
  p_number_names:=0;
  if p_list is null then
    return true;
  end if;
  l_len:=length(p_list);
  if l_len<=0 then
    return true;
  end if;
  if instr(p_list,p_separator)=0 then
    p_number_names:=1;
    p_names(p_number_names):=ltrim(rtrim(p_list));
    return true;
  end if;
  l_start:=1;
  loop
    l_end:=instr(p_list,p_separator,l_start);
    if l_end=0 then
      l_end:=l_len+1;
    end if;
    p_number_names:=p_number_names+1;
    p_names(p_number_names):=ltrim(rtrim(substr(p_list,l_start,(l_end-l_start))));
    l_start:=l_end+1;
    if l_end>=l_len then
      exit;
    end if;
  end loop;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  return false;
End;

procedure open_file is
Begin
  BSC_IM_UTILS.open_file('TEST');
Exception when others then
  raise;
End;

function get_time return varchar2 is
begin
  return ' '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS');
Exception when others then
  null;
End;

procedure get_bsc_fnd_owner is
l_status varchar2(2000);
l_industry varchar2(2000);
e_error exception;
Begin
  if FND_INSTALLATION.Get_App_Info('BSC',l_status, l_industry, g_bsc_owner)=false then
    raise e_error;
  end if;
  if FND_INSTALLATION.Get_App_Info('FND',l_status, l_industry, g_fnd_owner)=false then
    raise e_error;
  end if;
Exception
  when e_error then
    raise;
  when others then
    g_status_message:=sqlerrm;
    raise;
End;

procedure init is
Begin
  if g_file is null then
    if instr(g_option_string,'DEBUG LOG')>0 then
      open_file;
      g_file:=true;
      g_debug:=true;
    else
      g_file:=false;
      g_debug:=false;
    end if;
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  raise;
End;
END BSC_BSC_XTD_PKG;

/
