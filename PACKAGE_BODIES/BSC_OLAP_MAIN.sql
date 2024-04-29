--------------------------------------------------------
--  DDL for Package Body BSC_OLAP_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_OLAP_MAIN" AS
/*$Header: BSCMAINB.pls 120.5 2006/10/30 23:24:55 amitgupt noship $*/

--Bug 3878968
--Procedure added to drop table storing CODE datatype
procedure drop_tmp_col_type_table is
l_stmt varchar2(200);
begin
   --drop table
   bsc_apps.init_bsc_apps;
   b_table_col_type_created:=false;
   l_stmt:= 'drop table '||g_col_type_table_name;
   BSC_APPS.Do_DDL(l_stmt, ad_ddl.drop_table, g_col_type_table_name);

Exception when others then
  null;
end;

procedure init_tbs_clause is
begin
  g_summary_table_tbs_name := BSC_APPS.get_tablespace_name(BSC_APPS.summary_table_tbs_type);
  g_summary_index_tbs_name := BSC_APPS.get_tablespace_name(BSC_APPS.summary_index_tbs_type);
  if (g_summary_table_tbs_name is not null) then
    g_summary_table_tbs_clause := ' TABLESPACE '|| g_summary_table_tbs_name;
  end if;
  if (g_summary_index_tbs_name is not null) then
    g_summary_index_tbs_clause := ' TABLESPACE '|| g_summary_index_tbs_name;
  end if;
end;

--Function added to create tmp table to store CODE datatype and index
--Bug 3878968
function create_tmp_col_type_table(
p_error_message out nocopy varchar2)
return boolean is
l_stmt varchar2(5000);
l_cur_run_kpis varchar2(2000);
l_counter number;
begin
  if g_debug then
    write_to_log_file_n('Start of create_tmp_col_type_table '||get_time);
  end if;
  drop_tmp_col_type_table ;
  if (g_summary_table_tbs_name is null) then
    init_tbs_clause;
  end if;
  -- bug 5458512
  -- If we are running GDB in all objective mode then we will consider all the
  -- indicators in the system while populating that temp table.
  -- If we are running GDB in incremental/selective mode then we will consider
  -- kpis only in prototype mode or being processed in current run.
  --create table
  l_stmt:= 'create table '||g_col_type_table_name||' (level_table_name varchar2(100), data_type varchar2(100))'|| g_summary_table_tbs_clause;
  BSC_APPS.Do_DDL(l_stmt, ad_ddl.create_table, g_col_type_table_name);

  if bsc_metadata_optimizer_pkg.gGAA_RUN_MODE=0 then
   --if running in all objective mode then consider all indicators
   l_stmt := ' insert into '||g_col_type_table_name||'(level_table_name, data_type)
              select distinct dim.level_table_name,col.data_type
              from
              bsc_kpi_dim_levels_b dim,
              all_tab_columns col
              where
              dim.level_table_name=col.table_name
              and col.column_name=:1
              and col.owner=:2
              union all
              select distinct dim.level_table_name,col.data_type
              from
              all_tab_columns col,
              bsc_kpi_dim_levels_b dim
              where
              dim.level_table_name=col.table_name
              and col.column_name=:3
              and col.owner =:4';
  else --if incremental or seletive then consider production mode indicators and
       -- indictors in current mode
     l_cur_run_kpis:=BSC_MO_HELPER_PKG.Get_New_Big_In_Cond_Number( 20, 'KPI.INDICATOR');
     l_counter := BSC_METADATA_OPTIMIZER_PKG.gIndicators.first;
     if BSC_METADATA_OPTIMIZER_PKG.gIndicators.count <> 0 then
       loop
         BSC_MO_HELPER_PKG.Add_Value_Big_In_Cond_Number(20, BSC_METADATA_OPTIMIZER_PKG.gindicators(l_counter).code);
         EXIT WHEN l_counter=BSC_METADATA_OPTIMIZER_PKG.gIndicators.last;
         l_counter := BSC_METADATA_OPTIMIZER_PKG.gIndicators.next(l_counter);
       end loop;
     end if;

    l_stmt := 'insert into '||g_col_type_table_name||'(level_table_name, data_type)
            select distinct dim.level_table_name,col.data_type
              from
              all_tab_columns col,
			  bsc_kpi_dim_levels_b dim,
              bsc_kpis_vl kpi
              where
                  (kpi.prototype_flag not in (1,2,3,4) OR '||
              l_cur_run_kpis||
              ') and kpi.indicator=dim.indicator
              and dim.level_table_name=col.table_name
              and col.column_name=:1
              and col.owner =:2
	      union all
	      select distinct dim.level_table_name,col.data_type
              from
              all_tab_columns col,
              bsc_kpi_dim_levels_b dim,
              bsc_kpis_vl kpi
              where
                  (kpi.prototype_flag not in (1,2,3,4) OR '||
              l_cur_run_kpis||
              ')and kpi.indicator=dim.indicator
              and dim.level_table_name=col.table_name
              and col.column_name=:3
              and col.owner =:4';

  END IF;
  execute immediate l_stmt using 'CODE', bsc_apps.get_user_schema('BSC'), 'CODE', bsc_apps.get_user_schema('APPS')  ;
  --create index on table
  l_stmt := 'create unique index '||g_col_type_table_name||'_u1 on '||g_col_type_table_name||'(level_table_name)'||g_summary_index_tbs_clause;
  BSC_APPS.Do_DDL(l_stmt, ad_ddl.create_index, g_col_type_table_name||'_u1');
  if g_debug then
    write_to_log_file_n('End of create_tmp_col_type_table '||get_time);
  end if;
  return true;
  Exception when others then
    p_error_message:=sqlerrm;
    write_to_log_file_n('Error in create_tmp_col_type_table '||sqlerrm);
    return false;
end;

function implement_bsc_mv(
p_kpi varchar2,
p_option_string varchar2,
p_error_message out nocopy varchar2)return boolean is
Begin
  open_file;
  reset;
  --Bug 3878968
  --check if the temp table for col datatype has already been created
  --if false drop the table and create it again
  if(b_table_col_type_created=false)then
     drop_tmp_col_type_table;
     if(create_tmp_col_type_table(p_error_message)) then
     	b_table_col_type_created := true;
     else
     	return false;
     end if;
  end if;

  if BSC_IM_UTILS.parse_values(p_option_string,',',g_options,g_number_options)=false then
    p_error_message:=BSC_IM_UTILS.g_status_message;
    return false;
  end if;
  if init_all(g_options,g_number_options)=false then
    p_error_message:=BSC_IM_UTILS.g_status_message;
    return false;
  end if;
  if g_debug then
    write_to_log_file_n('================================================');
    write_to_log_file('Implement BSC MV '||p_kpi);
    write_to_log_file_n('================================================');
  end if;
  if BSC_BSC_ADAPTER.load_metadata_for_indicators(p_kpi,g_options,g_number_options)=false then
    p_error_message:=BSC_IM_UTILS.g_status_message;
    return false;
  end if;
  if BSC_MV_ADAPTER.create_mv_kpi(p_kpi,'BSC',g_options,g_number_options)=false then
    p_error_message:=BSC_IM_UTILS.g_status_message;
    return false;
  end if;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  write_to_log_file_n('Error in implement_bsc_mv '||sqlerrm);
  p_error_message:=BSC_IM_UTILS.g_status_message;
  return false;
End;

----------------------------------------------------------
function drop_bsc_mv(
p_kpi varchar2,
p_option_string varchar2,
p_error_message out nocopy varchar2)return boolean is
Begin
  open_file;
  reset;
  if BSC_IM_UTILS.parse_values(p_option_string,',',g_options,g_number_options)=false then
    p_error_message:=BSC_IM_UTILS.g_status_message;
    return false;
  end if;
  if init_all(g_options,g_number_options)=false then
    p_error_message:=BSC_IM_UTILS.g_status_message;
    return false;
  end if;
  if BSC_BSC_ADAPTER.load_metadata_for_indicators(p_kpi,g_options,g_number_options)=false then
    p_error_message:=BSC_IM_UTILS.g_status_message;
    return false;
  end if;
  if BSC_MV_ADAPTER.drop_mv_kpi(p_kpi,'BSC',g_options,g_number_options)=false then
    p_error_message:=BSC_MV_ADAPTER.g_status_message;
  end if;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  write_to_log_file_n('Error in drop_bsc_mv '||sqlerrm);
  p_error_message:=BSC_IM_UTILS.g_status_message;
  return false;
End;

function drop_summary_mv(
p_mv varchar2,
p_option_string varchar2,
p_error_message out nocopy varchar2)return boolean is
Begin
  if BSC_IM_UTILS.parse_values(p_option_string,',',g_options,g_number_options)=false then
    p_error_message:=BSC_IM_UTILS.g_status_message;
    return false;
  end if;
  if BSC_MV_ADAPTER.drop_mv(p_mv,g_options,g_number_options)=false then
    p_error_message:=BSC_MV_ADAPTER.g_status_message;
  end if;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  write_to_log_file_n('Error in drop_bsc_mv '||sqlerrm);
  p_error_message:=BSC_IM_UTILS.g_status_message;
  return false;
End;
----------------------------------------------------------

----------------------------------------------------------
function refresh_bsc_mv(
p_kpi varchar2,
p_option_string varchar2,
p_error_message out nocopy varchar2)return boolean is
Begin
  open_file;
  reset;
  if BSC_IM_UTILS.parse_values(p_option_string,',',g_options,g_number_options)=false then
    p_error_message:=BSC_IM_UTILS.g_status_message;
    return false;
  end if;
  if init_all(g_options,g_number_options)=false then
    p_error_message:=BSC_IM_UTILS.g_status_message;
    return false;
  end if;
  if g_debug then
    write_to_log_file_n('================================================');
    write_to_log_file('Refresh BSC MV '||p_kpi);
    write_to_log_file_n('================================================');
  end if;
  if BSC_BSC_ADAPTER.load_metadata_for_indicators(p_kpi,g_options,g_number_options)=false then
    p_error_message:=BSC_IM_UTILS.g_status_message;
    return false;
  end if;
  if BSC_MV_ADAPTER.refresh_mv_kpi(p_kpi,'BSC',g_options,g_number_options)=false then
    p_error_message:=BSC_MV_ADAPTER.g_status_message;
    return false;
  end if;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  write_to_log_file_n('Error in refresh_bsc_mv '||sqlerrm);
  p_error_message:=BSC_IM_UTILS.g_status_message;
  return false;
End;

function refresh_summary_mv(
p_mv varchar2,
p_kpi varchar2,
p_option_string varchar2,
p_error_message out nocopy varchar2)return boolean is
Begin
  open_file;
  if BSC_IM_UTILS.parse_values(p_option_string,',',g_options,g_number_options)=false then
    p_error_message:=BSC_IM_UTILS.g_status_message;
    return false;
  end if;
  if init_all(g_options,g_number_options)=false then
    p_error_message:=BSC_IM_UTILS.g_status_message;
    return false;
  end if;
  if g_debug then
    write_to_log_file_n('================================================');
    write_to_log_file('Refresh Summary MV '||p_mv||' '||p_kpi);
    write_to_log_file_n('================================================');
  end if;
  -- Bug#3899842: Performance fix: Comment out these lines.
  --Instead call BSC_BSC_ADAPTER.create_int_md_fk(p_mv)
  /*
  if BSC_IM_UTILS.is_cube_present(p_kpi,'BSC')=false then
    --see if any cube is present.
    if BSC_IM_UTILS.is_cube_present(null,'BSC') then
      reset;
    end if;
    --populate the int metadata
    if BSC_BSC_ADAPTER.load_metadata_for_indicators(p_kpi,g_options,g_number_options)=false then
      p_error_message:=BSC_IM_UTILS.g_status_message;
      return false;
    end if;
  end if;
  */
  BSC_BSC_ADAPTER.create_int_md_fk(p_mv);
  if BSC_MV_ADAPTER.refresh_mv(p_mv,p_kpi,g_options,g_number_options)=false then
    p_error_message:=BSC_MV_ADAPTER.g_status_message;
    return false;
  end if;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  write_to_log_file_n('Error in refresh_bsc_mv '||sqlerrm);
  p_error_message:=BSC_IM_UTILS.g_status_message;
  return false;
End;
------------------------------------------
--------=====================================
---------   Load Reporting Calendar
function load_reporting_calendar(
p_apps varchar2,
p_option_string varchar2,
p_error_message out nocopy varchar2)return boolean is
Begin
  open_file;
  reset;
  if BSC_IM_UTILS.parse_values(p_option_string,',',g_options,g_number_options)=false then
    p_error_message:=BSC_IM_UTILS.g_status_message;
    return false;
  end if;
  if init_all(g_options,g_number_options)=false then
    p_error_message:=BSC_IM_UTILS.g_status_message;
    return false;
  end if;
  if g_debug then
    write_to_log_file_n('================================================');
    write_to_log_file('Load Reporting Calendar, Apps='||p_apps);
    write_to_log_file_n('================================================');
  end if;
  if p_apps='BSC' then
    if BSC_BSC_ADAPTER.load_reporting_calendar(g_options,g_number_options)=false then
      p_error_message:=BSC_IM_UTILS.g_status_message;
      return false;
    end if;
  end if;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  write_to_log_file_n('Error in load_reporting_calendar '||sqlerrm);
  p_error_message:=BSC_IM_UTILS.g_status_message;
  return false;
End;

--Fix bug#4027813: Added this function to load reporting calendar for only
--the specified calendar id
function load_reporting_calendar(
p_calendar_id number,
p_apps varchar2,
p_option_string varchar2,
p_error_message out nocopy varchar2)return boolean is
Begin
  open_file;
  reset;
  if BSC_IM_UTILS.parse_values(p_option_string,',',g_options,g_number_options)=false then
    p_error_message:=BSC_IM_UTILS.g_status_message;
    return false;
  end if;
  if init_all(g_options,g_number_options)=false then
    p_error_message:=BSC_IM_UTILS.g_status_message;
    return false;
  end if;
  if g_debug then
    write_to_log_file_n('================================================');
    write_to_log_file('Load Reporting Calendar, calendar id='||p_calendar_id||' Apps='||p_apps);
    write_to_log_file_n('================================================');
  end if;
  if p_apps='BSC' then
    if BSC_BSC_ADAPTER.load_reporting_calendar(p_calendar_id, g_options,g_number_options)=false then
      p_error_message:=BSC_IM_UTILS.g_status_message;
      return false;
    end if;
  end if;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  write_to_log_file_n('Error in load_reporting_calendar '||sqlerrm);
  p_error_message:=BSC_IM_UTILS.g_status_message;
  return false;
End;
--------=====================================

------------------------------------------
--------=====================================
---------   Support for PMV for Recursive Dimensions
procedure get_list_of_rec_dim(
p_dim_list out nocopy bsc_varchar2_table_type,
p_num_dim_list out nocopy number,
p_error_message out nocopy varchar2) is
Begin
  bsc_bsc_adapter.get_list_of_rec_dim(p_dim_list,p_num_dim_list,p_error_message);
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  p_error_message:=BSC_IM_UTILS.g_status_message;
  raise;
End;

procedure set_and_get_dim_sql(
p_dim_level_short_name bsc_varchar2_table_type,
p_dim_level_value bsc_varchar2_table_type,
p_num_dim_level number,
p_dim_level_sql out nocopy bsc_varchar2_table_type,
p_error_message out nocopy varchar2
) is
Begin
  bsc_bsc_adapter.set_and_get_dim_sql(p_dim_level_short_name,p_dim_level_value,p_num_dim_level,
  p_dim_level_sql,p_error_message);
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  p_error_message:=BSC_IM_UTILS.g_status_message;
  raise;
End;

--------=====================================
--reset
procedure reset is
Begin
  write_to_log_file_n('Intermediate metadata reset');
  BSC_IM_INT_MD.reset_int_metadata;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  write_to_log_file_n('Error in reset '||sqlerrm);
  raise;
End;

procedure open_file is
Begin
  BSC_IM_UTILS.open_file('TEST');
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  write_to_log_file_n('Error in open_file '||sqlerrm);
  raise;
End;

------------------------------------------
function init_all(
p_options BSC_IM_UTILS.varchar_tabletype,
p_number_options number) return boolean is
Begin
  g_init_all:='set';
  g_status:=true;
  g_debug:=false;
  if BSC_IM_UTILS.get_option_value(p_options,p_number_options,'DEBUG LOG')='Y' then
    g_debug:=true;
  end if;
  if BSC_IM_UTILS.get_option_value(p_options,p_number_options,'TRACE')='Y' then
    BSC_IM_UTILS.set_trace;
  end if;
  BSC_IM_UTILS.set_globals(g_debug);
  if BSC_IM_UTILS.set_global_dimensions=false then
    return false;
  end if;
  BSC_BSC_ADAPTER.set_globals(g_debug);
  BSC_IM_INT_MD.set_globals(g_debug);
  BSC_MV_ADAPTER.set_globals(g_debug);
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  write_to_log_file_n('Error in init_all '||sqlerrm);
  return false;
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

procedure write_to_debug_n(p_message varchar2) is
begin
  if g_debug then
    write_to_log_file_n(p_message);
  end if;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  null;
end;

procedure write_to_debug(p_message varchar2) is
begin
  if g_debug then
    write_to_log_file(p_message);
  end if;
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

END BSC_OLAP_MAIN;

/
