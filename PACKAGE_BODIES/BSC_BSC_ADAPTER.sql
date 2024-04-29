--------------------------------------------------------
--  DDL for Package Body BSC_BSC_ADAPTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_BSC_ADAPTER" AS
/*$Header: BSCBSCMB.pls 120.31 2006/09/07 13:32:37 rkumar ship $*/


TYPE cLevelInfoMap IS RECORD(
level_table_name varchar2(100),
short_name       varchar2(100)
);
TYPE tab_cLevelInfoMap is table of cLevelInfoMap index by VARCHAR2(300);

g_level_info tab_cLevelInfoMap;
g_level_info_cached boolean := false;

procedure cache_level_info is
l_count number := 1;
cursor cLevelInfo is
SELECT LEVEL_TABLE_NAME,SHORT_NAME, upper(level_pk_col) level_pk_col
FROM
 BSC_SYS_DIM_LEVELS_B WHERE level_table_name in
(select level_table_name
   from bsc_kpi_dim_levels_b kpi,
        bsc_tmp_opt_ui_kpis gdb
  where gdb.indicator=kpi.indicator
    and gdb.prototype_flag <> 2
    and gdb.process_id = bsc_metadata_optimizer_pkg.g_ProcessId);
begin
  for i in cLevelInfo loop
    g_level_info(i.level_pk_col).level_table_name := i.level_table_name;
    g_level_info(i.level_pk_col).short_name := i.short_name;
  end loop;
end;

procedure cache_calendar_as_loaded(p_calendar_id number) is
begin
  if g_calendars_refreshed.exists(p_calendar_id) then
    null;
  else
    g_calendars_refreshed(p_calendar_id).calendar_id := p_calendar_id;
  end if;
end;

function calendar_already_refreshed(p_calendar_id number) return boolean is
begin
  if g_calendars_refreshed.exists(p_calendar_id) then
    return true;
  else
    return false;
  end if;
end;

procedure drop_and_add_partition(p_calendar_id number, p_rpt_calendar_owner varchar2) is
PRAGMA AUTONOMOUS_TRANSACTION;
l_stmt varchar2(1000);
begin
  l_stmt := 'alter table '||p_rpt_calendar_owner||'.bsc_reporting_calendar drop partition p_'||p_calendar_id;
  --bug 4636259, performance issue, so partitioning;
  begin
    if g_debug then
      write_to_log_file_n(l_stmt);
    end if;
    execute immediate l_stmt;
    exception when others then
      null;
  end;
  l_stmt := 'alter table '||p_rpt_calendar_owner||'.bsc_reporting_calendar add partition p_'||
            p_calendar_id||' values('||p_calendar_id||')';
  if g_debug then
      write_to_log_file_n(l_stmt);
  end if;
  execute immediate l_stmt;
  COMMIT;
end;

function get_b_table_name_for_prj(p_table_name varchar2) return varchar2 is

begin
  if (p_table_name not like 'BSC_B_%PRJ%') then
    return p_table_name;
  end if;
  return substr(p_table_name, 1, instr(p_table_name, '_', -1)-1);
end;

function get_b_prj_table_name(p_b_table_name varchar2) return varchar2 is
begin
  return bsc_dbgen_metadata_reader.get_table_properties(
                           p_b_table_name,
                           bsc_dbgen_std_metadata.bsc_b_prj_table);
end;

function get_measures_by_table(
p_table_name varchar2,
p_measures BSC_IM_UTILS.varchar_tabletype,
p_number_measures number
) return varchar2 is
cursor c1 is select column_name from bsc_db_tables_cols where table_name = p_table_name;
l_column_name VARCHAR2(100);
l_ordered_columns varchar2(32000);
begin
  if p_number_measures= 0 then
    return null;
  end if;
  for i in 1..p_number_measures loop
    open c1;
    loop
      fetch c1 into l_column_name;
      if c1%notfound then
        l_ordered_columns := l_ordered_columns || ' NULL '||upper(p_measures(i))||',';
        exit;
      end if;
      if (upper(l_column_name) = upper( p_measures(i))) THEN
        l_ordered_columns := l_ordered_columns || upper(l_column_name)||',';
        exit;
      end if;
    end loop;
    close c1;
  end loop;
  l_ordered_columns:=substr(l_ordered_columns,1,length(l_ordered_columns)-1);
  if g_debug then
    write_to_log_file('get_measures_by_table for '|| p_table_name||' returning ... '||l_ordered_columns);
  end if;
  return l_ordered_columns;
end;

function get_prj_union_clause(p_b_table_name varchar2, p_add_alias boolean default true) return varchar2 is
cursor c1 is select column_name from bsc_db_tables_cols where table_name=p_b_table_name
order by column_type desc;
l_stmt varchar2(32000);
l_prj_table varchar2(100);
begin
  l_prj_table := get_b_prj_table_name(p_b_table_name);
  if l_prj_table is null then
    write_to_log_file('get_prj_union_clause for '|| p_b_table_name||' returning ...'||p_b_table_name);
    return p_b_table_name;
  end if;
  l_stmt := 'select ';
  for i in c1 loop
    l_stmt := l_stmt || i.column_name||',';
  end loop;
  l_stmt := substr(l_stmt, 1, length(l_stmt)-1)||',year, period, type, periodicity_id from ';
  l_stmt := l_stmt || p_b_table_name|| ' union all '||l_stmt ||l_prj_table;
  l_stmt := '('||l_stmt||')';
  if (p_add_alias) then
    l_stmt := l_stmt||' '||p_b_table_name;
  end if;
   if g_debug then
    write_to_log_file('get_prj_union_clause for '|| p_b_table_name||' returning ... '|| l_stmt);
  end if;
  return l_stmt;
end;


function load_metadata_for_indicators(
p_indicator varchar2,
p_options BSC_IM_UTILS.varchar_tabletype,
p_number_options number
)return boolean is
l_indicators BSC_IM_UTILS.number_tabletype;
l_number_indicators number;
l_final_dimensions BSC_IM_UTILS.varchar_tabletype;
l_number_final_dimensions number;
Begin
  g_options:=p_options;
  g_number_options:=p_number_options;
  if init_all=false then
    return false;
  end if;
  l_number_indicators:=1;
  l_indicators(l_number_indicators):=p_indicator;
  if read_metadata(l_indicators,l_number_indicators,l_final_dimensions,
    l_number_final_dimensions)=false then
    return false;
  end if;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in load_metadata_for_indicators '||sqlerrm);
  return false;
End;

function read_metadata(
p_indicators BSC_IM_UTILS.number_tabletype,
p_number_indicators number,
p_final_dimensions out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_final_dimensions out nocopy number
) return boolean is
l_indicator_ids BSC_IM_UTILS.number_tabletype;
l_indicators BSC_IM_UTILS.varchar_tabletype;
Begin
  for i in 1..p_number_indicators loop
    l_indicator_ids(i):=p_indicators(i);
    l_indicators(i):=p_indicators(i);
    write_to_debug_n('Id for '||l_indicators(i)||'='||l_indicator_ids(i));
  end loop;
  /*
  after talking to mauricio 4/24/03 we have decided to turn off the dim read part for now.
  the dim metadata had circular relations. this started causing infinite loops etc.
  right now, we go for simple approach.
  */
  /*
  if read_levels_required(l_indicator_ids,p_number_indicators,p_final_dimensions,
    p_number_final_dimensions)=false then
    return false;
  end if;
  */
  if read_kpi_required(l_indicator_ids,l_indicators,p_number_indicators)=false then
    return false;
  end if;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in read_metadata '||sqlerrm);
  return false;
End;

function read_kpi_required(
p_indicators BSC_IM_UTILS.number_tabletype,
p_indicator_names BSC_IM_UTILS.varchar_tabletype,
p_number_indicators number
) return boolean is
-----------------------------------------------------------------
l_stmt varchar2(5000);
l_periodicity BSC_IM_UTILS.number_tabletype;
l_number_periodicity number;
-----------------------------------------------------------------
Begin
  write_to_debug_n('In read_kpi_required '||get_time);
  for i in 1..p_number_indicators loop
    l_number_periodicity:=1;
    if get_kpi_periodicity(p_indicators(i),l_periodicity,l_number_periodicity)=false then
      return false;
    end if;
    if read_kpi_map_info(
      p_indicators(i),
      l_periodicity,
      l_number_periodicity
      )=false then
      return false;
    end if;
  end loop;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in read_kpi_required '||sqlerrm);
  return false;
End;

/*
this api for XTD supported MV
*/
function read_kpi_map_info(
p_indicator number,
p_periodicity BSC_IM_UTILS.number_tabletype,
p_number_periodicity number
)return boolean is
-----------------------------------------------------------------
l_map_name varchar2(200);
l_zero_code_map_name varchar2(200);
l_lang varchar2(200);
-----------------------------------------------------------------
l_mv_name varchar2(200);
l_zero_code_mv_name varchar2(200);
-----------------------------------------------------------------
l_s_tables BSC_IM_UTILS.varchar_tabletype;
l_periodicity BSC_IM_UTILS.number_tabletype;
l_number_s_tables number;
-----------------------------------------------------------------
l_distinct_list BSC_IM_UTILS.varchar_tabletype;
l_number_distinct_list number;
-----------------------------------------------------------------
l_temp_var BSC_IM_UTILS.varchar_tabletype;
l_number_temp_var number;
-----------------------------------------------------------------
ll_s_tables BSC_IM_UTILS.varchar_tabletype;
ll_number_s_tables number;
-----------------------------------------------------------------

-- added 02/13/2006 by Arun
-- P1 5034426
cursor cReportingCalCheck(p_calendar_id number) is
select 1 from bsc_sys_periodicities
where
calendar_id = p_calendar_id
and (period_type_id is null or record_type_id is null )
  --ignoring xtd pattern due to PMD bug 4503527 not having an upgrade script yet
  --or xtd_pattern is null )
and periodicity_type not in (11,12);
l_dummy number;
p_options BSC_IM_UTILS.varchar_tabletype;
l_calendar_id number;

Begin
  if g_debug then
    write_to_log_file_n('In read_kpi_map_info '||get_time);
  end if;

  -- need this to fix bug 5034426
  -- mv creation fails if period_type_ids are not populated
  select calendar_id into l_calendar_id from bsc_kpis_vl where indicator=p_indicator;
  if g_debug then
     write_to_log_file_n('Checking if any of the periodicities of objective '||p_indicator||
     ' , calendar = '||l_calendar_id||' are missing period_type_id, record_type_id or xtd_pattern '||get_time  );
  end if;
  open cReportingCalCheck(l_calendar_id);
  fetch cReportingCalCheck into l_dummy;
  if cReportingCalCheck%FOUND then -- call load_reporting_calendar for this calendar
    if NOT calendar_already_refreshed(l_calendar_id) then
      if g_debug then
        write_to_log_file_n('Need to load reporting calendar for calendar_id='||l_calendar_id);
      end if;
      p_options.delete;
      if g_debug then
        p_options(1) := 'DEBUG LOG';
      end if;
      if load_reporting_calendar(l_calendar_id, p_options, p_options.count) then
        null;
      end if;
      cache_calendar_as_loaded(l_calendar_id);
    end if;
  end if;
  close cReportingCalCheck;

  /*
    look at
    1. 0 code calculations, type=4
    2. merging columns (tables_rels, relation_type=0)
    3. merging rows (2 inp tables, same columns, month and week for example)
    4. targets at different levels (tables_rels, relation_type=5)
  */
  --we need to loop over each set of summary data
  --l_base_tables are the B tables
  --for each S table, find the set (all periodicities)
  --SB tables are considered in the same league as the S tables
  --MV are created for the SB tables.
  l_lang:=BSC_IM_UTILS.get_lang;
  ----------------------
  --create the metadata for KPI
  if BSC_IM_INT_MD.create_cube(p_indicator,p_indicator,0,'BSC',p_indicator,null)=false then
    return false;
  end if;
  ----------------------
  if get_s_sb_tables(p_indicator,l_s_tables,l_periodicity,l_number_s_tables)=false then
    return false;
  end if;
  l_number_distinct_list:=0;
  for i in 1..l_number_s_tables loop
    if BSC_IM_UTILS.in_array(l_distinct_list,l_number_distinct_list,substr(l_s_tables(i),1,
      instr(l_s_tables(i),'_',-1)-1))=false then
      l_number_distinct_list:=l_number_distinct_list+1;
      l_distinct_list(l_number_distinct_list):=substr(l_s_tables(i),1,instr(l_s_tables(i),'_',-1)-1);
    end if;
  end loop;
  if g_debug then
    write_to_log_file_n('The distinct list of summary data');
    for i in 1..l_number_distinct_list loop
      write_to_log_file(l_distinct_list(i));
    end loop;
  end if;
  --for each of this distinct list, create the maps
  for i in 1..l_number_distinct_list loop
    l_map_name:=l_distinct_list(i)||'_MAP';
    l_mv_name:=l_distinct_list(i)||'_MV';
    l_zero_code_mv_name:=l_distinct_list(i)||'_ZMV';
    l_zero_code_map_name:=l_distinct_list(i)||'_ZMAP';
    --get all the summary tables for l_distinct_list(i)
    ll_number_s_tables:=0;
    for j in 1..l_number_s_tables loop
      if substr(l_s_tables(j),1,instr(l_s_tables(j),'_',-1)-1)=l_distinct_list(i) then
        ll_number_s_tables:=ll_number_s_tables+1;
        ll_s_tables(ll_number_s_tables):=l_s_tables(j);
      end if;
    end loop;
    if g_debug then
      write_to_log_file_n('*********************************************');
      write_to_log_file('Going to look at ');
      write_to_log_file('*********************************************');
      for j in 1..ll_number_s_tables loop
        write_to_log_file(ll_s_tables(j));
      end loop;
    end if;
    if g_debug then
        write_to_log_file_n('In read_kpi_map_info--Going to look at s tables '||get_time);
    end if;
    if ll_number_s_tables>0 then
      --------------------------------------------
      --int metadata for the mv for this kpi
      if BSC_IM_INT_MD.create_object(
        l_mv_name,
        'SUMMARY MV',
        'BSC',
        p_indicator,
        null,
        'SUMMARY MV')=false then
        return false;
      end if;
      --------------------------------------------
      if create_kpi_map_info(
        p_indicator,
        l_map_name,
        l_mv_name,
        l_zero_code_mv_name,
        l_zero_code_map_name,
        ll_s_tables,
        ll_number_s_tables)=false then
        return false;
      end if;
    else
      if g_debug then
        write_to_log_file_n('Number of S tables <=0. Cannot process '||l_mv_name);
      end if;
    end if;
    if g_debug then
           write_to_log_file_n('In read_kpi_map_info--After look look at s tables '||get_time);
    end if;
  end loop;--for each set of S tables for this KPI
  if g_debug then
      write_to_log_file_n('Returning from read_kpi_map_info '||get_time);
  end if;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in read_kpi_map_info '||sqlerrm);
  return false;
End;

--bug 3867313
function get_distinct_list(p_parameter IN BSC_IM_UTILS.varchar_tabletype, l_number_parameters IN NUMBER) return number is
l_final_list BSC_IM_UTILS.varchar_tabletype;
l_final_counter number := 0;
bFound boolean := false;
begin
  for i in 1..l_number_parameters loop
    bFound := false;
    for j in 1..l_final_counter loop
      if (p_parameter(i) = l_final_list(j)) then
        bFound := true;
        exit;
      end if;
    end loop;
    if (NOT bFound) then
      l_final_counter := l_final_counter + 1;
      l_final_list(l_final_counter) := p_parameter(i);
    end if;
  end loop;
  return l_final_counter;
end;

function create_kpi_map_info(
p_indicator number,
p_map_name varchar2,
p_mv_name varchar2,
p_zero_code_mv_name varchar2,
p_zero_code_map_name varchar2,
p_s_tables BSC_IM_UTILS.varchar_tabletype,
p_number_s_tables number
)return boolean is
---------------s table info-------------------------------------
l_fk BSC_IM_UTILS.varchar_tabletype;
l_number_fk number;
l_measures BSC_IM_UTILS.varchar_tabletype;
l_number_measures number;
---------------src table info-------------------------------------
l_tables BSC_IM_UTILS.varchar_tabletype;
l_source_tables BSC_IM_UTILS.varchar_tabletype;
l_relation_type BSC_IM_UTILS.varchar_tabletype;
l_source_sql BSC_IM_UTILS.varchar_tabletype;
l_table_periodicity BSC_IM_UTILS.number_tabletype;
l_table_period_type_id BSC_IM_UTILS.number_tabletype;
l_periodicity_id_stmt varchar2(20000);
l_eliminate BSC_IM_UTILS.varchar_tabletype;--these are for S tables with SB as src, to have not exists(..)
l_group BSC_IM_UTILS.number_tabletype;
l_number_source_tables number;
---------------group column info---------------------------------
--used in the algo to come up with the min number of union all statements
l_group_number BSC_IM_UTILS.number_tabletype;--grp number
l_group_column_formula BSC_IM_UTILS.varchar_tabletype;
l_group_column BSC_IM_UTILS.varchar_tabletype;
l_number_group_column number;
-----------S table columns--------------------------------------
l_col_table BSC_IM_UTILS.varchar_tabletype;
l_cols BSC_IM_UTILS.varchar_tabletype;
l_col_type BSC_IM_UTILS.varchar_tabletype;
l_col_formula BSC_IM_UTILS.varchar_tabletype;
l_col_source BSC_IM_UTILS.varchar_tabletype;
l_number_cols number;
------------for 0 code ------------------------------------------
l_calculation_table BSC_IM_UTILS.varchar_tabletype;
l_calculation_type BSC_IM_UTILS.varchar_tabletype;
l_parameter1 BSC_IM_UTILS.varchar_tabletype;
l_parameter2 BSC_IM_UTILS.varchar_tabletype;
l_parameter3 BSC_IM_UTILS.varchar_tabletype;
l_parameter4 BSC_IM_UTILS.varchar_tabletype;
l_parameter5 BSC_IM_UTILS.varchar_tabletype;
l_number_parameters number;
-----------------------------------------------------------------
l_select_sql varchar2(32000);
l_select_sql_inc varchar2(32000);--for incremental mv sql
l_eliminate_sql varchar2(32000);
l_from_sql varchar2(32000);
l_where_sql varchar2(32000);
l_group_by_sql varchar2(32000);
l_hint_sql varchar2(32000);
l_select_basic varchar2(32000);
l_select_no_aggregation varchar2(32000);
b_no_agg boolean;
-----------------------------------------------------------------
l_filter_from BSC_IM_UTILS.varchar_tabletype;
l_filter_where BSC_IM_UTILS.varchar_tabletype;
l_number_filter number;
l_filter_first_level BSC_IM_UTILS.varchar_tabletype;
l_filter_first_level_alias BSC_IM_UTILS.varchar_tabletype;
l_filter_first_level_fk BSC_IM_UTILS.varchar_tabletype;
l_num_filter_first_level number;
-----------------------------------------------------------------
--for zero code
--there may be more than 1 fk for rollup. we need to have a union for each
--of the fks with rollup and then one more union with zero code for all the keys
--combined
l_rollup_select_sql BSC_IM_UTILS.varchar_tabletype;
l_rollup_from_sql BSC_IM_UTILS.varchar_tabletype;
l_rollup_where_sql BSC_IM_UTILS.varchar_tabletype;
l_rollup_group_by_sql BSC_IM_UTILS.varchar_tabletype;
l_number_rollup_sql number;
----------
--l_rollup... will contain stmts with union all. these are used to create fast refresh mv
-- but in the case where we cannot have fast refresh mv, we need to go for full refresh mv.
--in the case of full refresh mv, we dont want union all, but we prefer rollup(...)
l_rollup_full_select_sql varchar2(32000);
l_rollup_full_from_sql varchar2(32000);
l_rollup_full_where_sql varchar2(32000);
l_rollup_full_group_by_sql varchar2(32000);
l_rollup_full_having_sql varchar2(32000);
-----------------------------------------------------------------
l_db_version varchar2(200);
-----------------------------------------------------------------
--used for dummy MV creation.
--dummy MV are created for snapshot log maintenance
l_b_tables BSC_IM_UTILS.varchar_tabletype;
l_number_b_tables number;
l_dim_level_tables BSC_IM_UTILS.varchar_tabletype;
l_number_dim_level_tables number;
-----------------------------------------------------------------
l_base_table_stmt varchar2(20000);--this is the stmt that will be used for snapshot log creation
l_dim_level_stmt varchar2(20000);--this will be used to create snapshot log on the dim level
-----------------------------------------------------------------
l_full_zero_code_map_name varchar2(200);
-----------------------------------------------------------------
l_lowest_s_table varchar2(200);
l_bt_tables BSC_IM_UTILS.varchar_tabletype;
l_number_bt_tables number;
-----------------------------------------------------------------
l_return_var varchar2(10);
l_number_keys number :=0;


l_b_prj_table varchar2(100);

Begin
  if g_debug then
    write_to_log_file_n('In create_kpi_map_info '||p_map_name||' '||p_mv_name);
    write_to_log_file_n('In Create_kpi_map_info'||' '||get_time);
  end if;
  l_number_source_tables:=0;
  l_db_version:=BSC_IM_UTILS.get_db_version;
  l_number_parameters:=0;
  l_full_zero_code_map_name:=p_zero_code_map_name||'_FULL';
  --get the fk of the summary tables
  --if get_table_fks(p_s_tables,p_number_s_tables,l_fk,l_number_fk)=false then
  --for perf, we look at only 1 of the S tables
  if get_table_fks(p_s_tables(1),l_fk,l_number_fk)=false then
    return false;
  end if;
  --if get_table_measures(p_s_tables,p_number_s_tables,l_measures,l_number_measures)=false then
  if get_table_measures(p_s_tables(1),l_measures,l_number_measures)=false then
    return false;
  end if;
  -----------------------------------------
  --add int metadata for the fk and measures. useful for snapshot log creation
  if g_debug then
      write_to_log_file_n('In Create_kpi_map_info--Before Loop Create_Fks'||' '||get_time);
  end if;
  for i in 1..l_number_fk loop
    if BSC_IM_INT_MD.create_fk(
      l_fk(i),
      'SUMMARY MV',
      p_mv_name,
      null,
      null,
      null,
      'BSC',
      'SUMMARY MV')=false then
      return false;
    end if;
  end loop;
  ------------------
  --int metadata for the measures
  for i in 1..l_number_measures loop
    if BSC_IM_INT_MD.create_column(
      l_measures(i),
      'A',
      null,
      'BSC',
      null,
      null,
      null,
      p_mv_name,
      null)=false then
      return false;
    end if;
  end loop;

  -----------------------------------------

  for i in 1..p_number_s_tables loop

    if get_table_relations(
      p_s_tables(i),
      l_tables,
      l_source_tables,
      l_relation_type,
      l_number_source_tables)=false then
      return false;
    end if;
    --get the column information
    if get_table_cols(
      p_s_tables(i),
      l_col_table,
      l_cols,
      l_col_type,
      l_col_source,
      l_col_formula,
      l_number_cols)=false then
      return false;
    end if;
    --get 0 code calculations
    l_return_var := BSC_IM_UTILS.get_option_value(g_options,g_number_options,'NO ROLLUP');

    if l_return_var='Y' then
      if g_debug then
        write_to_log_file_n('No rollup specified');
      end if;
    else
      if get_db_calculation(
        p_indicator,
        p_s_tables(i),
        4,--zero code
        l_calculation_table,
        l_calculation_type,
        l_parameter1,
        l_parameter2,
        l_parameter3,
        l_parameter4,
        l_parameter5,
        l_number_parameters)=false then
        return false;
      end if;
      -- bug 3835059, to support any number of keys and not hang while creating the mv
      if (l_return_var <> 'N') then
      	-- bug 3867313, l_number_parameters is incremented per periodicity and hence we shd
        l_number_keys := get_distinct_list(l_parameter1, l_number_parameters);
        if g_debug then
          write_to_log_file_n('l_number_keys = '||l_number_keys||' max allowed = '||l_return_var );
    	end if;
      	if (l_number_keys > to_number(l_return_var) ) then
      	  l_number_parameters :=0;
      	end if;
      end if;
    end if;
  end loop;

  --------------------------------------------------------------------------
  l_number_b_tables:=0;
  l_number_dim_level_tables:=0;
  for i in 1..l_number_source_tables loop
    if BSC_IM_UTILS.is_like(l_source_tables(i),'BSC_B_') then
      if BSC_IM_UTILS.in_array(l_b_tables,l_number_b_tables,l_source_tables(i))=false then
        l_number_b_tables:=l_number_b_tables+1;
        l_b_tables(l_number_b_tables):=l_source_tables(i);
      end if;
    end if;
  end loop;
  if g_debug then
    write_to_log_file_n('Process the T tables');
  end if;
  l_periodicity_id_stmt:=' periodicity_id in (';
  for i in 1..l_number_source_tables loop
    if BSC_IM_UTILS.is_like(l_source_tables(i),'BSC_T_') then --this is a T table
      --construct the sql
      --we need to get the level tables also here because snp logs need to be created on level tables too
      --do we need to get the filter to the base tables for T?
      if get_table_sql(l_source_tables(i),l_source_sql(i),l_b_tables,l_number_b_tables,
        l_dim_level_tables,l_number_dim_level_tables)=false then
        return false;
      end if;
    else
      l_source_sql(i):=null;
    end if;
    --assign the table periodicity
    l_table_periodicity(i):=get_table_periodicity(l_tables(i));
    --l_table_period_type_id(i):=get_period_type_id_for_period(l_table_periodicity(i));
    --period type id assigned further down

    -- added by arun, if periodicity id already exists, ignore duplicate
    if (instr(l_periodicity_id_stmt, '('||l_table_periodicity(i)||',' )>0
        OR instr(l_periodicity_id_stmt, ','||l_table_periodicity(i)||',') > 0) then
      null;
    else
      l_periodicity_id_stmt:=l_periodicity_id_stmt||l_table_periodicity(i)||',';
    end if;
  end loop;
  l_periodicity_id_stmt:=substr(l_periodicity_id_stmt,1,length(l_periodicity_id_stmt)-1)||')';
  if g_debug then
    write_to_log_file_n('periodicity_id stmt='||l_periodicity_id_stmt);
    write_to_log_file_n('ALL the B tables');
    for i in 1..l_number_b_tables loop
      write_to_log_file(l_b_tables(i));
    end loop;
  end if;
  -----------------------------------
  --load the base table column info also into int metadata for snapshot log
  declare
    ll_fk BSC_IM_UTILS.varchar_tabletype;
    ll_number_fk number;
    ll_measures BSC_IM_UTILS.varchar_tabletype;
    ll_number_measures number;
  begin
    for i in 1..l_number_b_tables loop
      if get_table_fks(l_b_tables(i),ll_fk,ll_number_fk)=false then
        return false;
      end if;
      if get_table_measures(l_b_tables(i),ll_measures,ll_number_measures)=false then
        return false;
      end if;
      --insert into int metadata
      for j in 1..ll_number_fk loop
        if BSC_IM_INT_MD.create_fk(
          ll_fk(j),
          'BASE TABLE',
          l_b_tables(i),
          null,
          null,
          null,
          'BSC',
          'BASE TABLE')=false then
          return false;
        end if;
      end loop;
      for j in 1..ll_number_measures loop
        if BSC_IM_INT_MD.create_column(
          ll_measures(j),
          'A',
          null,
          'BSC',
          null,
          null,
          null,
          l_b_tables(i),
          null)=false then
          return false;
        end if;
      end loop;
    end loop;
  end;
  ----------------------------------------------------
  --we construct the base table stmt to later put into "property for mapping. BISMVLDB will use this
  --info to create snapshot logs
  if l_number_b_tables>0 then
    l_base_table_stmt:='BASE TABLES=';
    for i in 1..l_number_b_tables loop
      l_base_table_stmt:=l_base_table_stmt||l_b_tables(i)||'+';
    end loop;
    l_base_table_stmt:=substr(l_base_table_stmt,1,length(l_base_table_stmt)-1);
  else
    l_base_table_stmt:=null;
  end if;
  l_dim_level_stmt:='DIM LEVELS=';
  if g_debug then
    write_to_log_file_n('Base table stmt '||l_base_table_stmt);
  end if;
  --------------------------------------------------------------------------
  /*
  talked with mauricio 6/30/03
  if this set is loaded from B tables, we need to make sure that for all higher levels in periodicity,
  we use the same formula as  the lowest S table.
  */
  declare
    -----------------------------------
    ll_col BSC_IM_UTILS.varchar_tabletype;
    ll_col_formula BSC_IM_UTILS.varchar_tabletype;
    ll_number_col number;
    ll_index number;
    -----------------------------------
    ll_rollup_found boolean;
    ll_table BSC_IM_UTILS.varchar_tabletype;
    ll_number_table number;
    ll_calculation_type BSC_IM_UTILS.varchar_tabletype;
    ll_parameter1 BSC_IM_UTILS.varchar_tabletype;
    ll_parameter2 BSC_IM_UTILS.varchar_tabletype;
    ll_parameter3 BSC_IM_UTILS.varchar_tabletype;
    ll_parameter4 BSC_IM_UTILS.varchar_tabletype;
    ll_parameter5 BSC_IM_UTILS.varchar_tabletype;
    ll_number_parameters number;
    -----------------------------------
  begin
    for i in 1..l_number_source_tables loop
      if BSC_IM_UTILS.is_like(l_source_tables(i),'BSC_T_') or
        BSC_IM_UTILS.is_like(l_source_tables(i),'BSC_B_') then --this is a T or B table
        l_lowest_s_table:=l_tables(i);
        exit;
      end if;
    end loop;
    if l_lowest_s_table is not null then
      if g_debug then
        write_to_log_file_n('This set of S tables is loaded from B or T tables, need to set the higher level '||
        'formulas as the lowest level S table');
        write_to_log_file('Lowest S table='||l_lowest_s_table);
      end if;
      ------------------------------
      --get the measures for the lowest level
      ll_number_col:=0;
      for i in 1..l_number_cols loop
        if l_col_table(i)=l_lowest_s_table then
          ll_number_col:=ll_number_col+1;
          ll_col(ll_number_col):=l_cols(i);
          ll_col_formula(ll_number_col):=l_col_formula(i);
        end if;
      end loop;
      --set the higher levels
      for i in  1..l_number_cols loop
        if l_col_table(i) <> l_lowest_s_table then
          ll_index:=0;
          ll_index:=BSC_IM_UTILS.get_index(ll_col,ll_number_col,l_cols(i));
          if ll_index>0 then
            if l_col_formula(i) <> ll_col_formula(ll_index) then
              if g_debug then
                write_to_log_file('For '||l_col_table(i)||', changing '||l_col_formula(i)||' to '||
                ll_col_formula(ll_index));
              end if;
              l_col_formula(i):=ll_col_formula(ll_index);
            end if;
          end if;
        end if;
      end loop;
      if g_debug then
        write_to_log_file_n('After re-assigning the formulas for the columns');
        for i in 1..l_number_cols loop
          write_to_log_file(l_col_table(i)||' '||l_cols(i)||' '||l_col_type(i)||' '||l_col_source(i)||' '||
          l_col_formula(i));
        end loop;
      end if;
      --------------------------------------------
      --do the same for rollups
      --if the higher levels have no rollups and the lowest level has them, create it for higher levels
      --if the higher levels have rollups and the formula is different, make it same as lowest level
      ll_number_parameters:=0;
      if l_number_parameters>0 then
        --------------------------------
        --for the lowest level, change the rollup formula to the formula for the column
        if g_debug then
          write_to_log_file_n('For the lowest level, make sure that the rollup formula is same as col formula');
        end if;
        for i in 1..l_number_parameters loop
          if l_calculation_table(i)=l_lowest_s_table then
            ll_index:=0;
            ll_index:=BSC_IM_UTILS.get_index(l_cols,l_number_cols,l_parameter3(i));
            if ll_index>0 then
              if g_debug then
                write_to_log_file('Changing '||l_parameter5(i)||' to '||l_col_formula(ll_index));
              end if;
              l_parameter5(i):=l_col_formula(ll_index);
            end if;
          end if;
        end loop;
        if g_debug then
          write_to_log_file_n('-------------------------------------------');
        end if;
        --------------------------------
        if g_debug then
          write_to_log_file_n('For zero code, if zero code does not exist for higher level, create it');
          write_to_log_file('If zero code does exist, make sure the formulas match that of the lowest level');
        end if;
        for i in 1..l_number_parameters loop
          if l_calculation_table(i)=l_lowest_s_table then
            ll_number_parameters:=ll_number_parameters+1;
            ll_calculation_type(ll_number_parameters):=l_calculation_type(i);
            ll_parameter1(ll_number_parameters):=l_parameter1(i);
            ll_parameter2(ll_number_parameters):=l_parameter2(i);
            ll_parameter3(ll_number_parameters):=l_parameter3(i);
            ll_parameter4(ll_number_parameters):=l_parameter4(i);
            ll_parameter5(ll_number_parameters):=l_parameter5(i);
          end if;
        end loop;
        --for all the s tables that are not the lowest level, if rollup does not exist, create one
        ll_number_table:=0;--for which tables we need to create zero code rollups
        for i in 1..p_number_s_tables loop
          if p_s_tables(i) <> l_lowest_s_table then
            ll_rollup_found:=false;
            for j in 1..l_number_parameters loop
              if l_calculation_table(j)=p_s_tables(i) then
                ll_rollup_found:=true;
                ll_index:=0;
                ll_index:=BSC_IM_UTILS.get_index(ll_parameter3,ll_number_parameters,l_parameter3(j));
                if ll_index>0 then
                  if l_parameter5(j)<>ll_parameter5(ll_index) then
                    if g_debug then
                      write_to_log_file('For '||l_calculation_table(j)||', changing '||l_parameter5(j)||
                      'to '||ll_parameter5(ll_index));
                    end if;
                    l_parameter5(j):=ll_parameter5(ll_index);
                  end if;
                end if;
              end if;
            end loop;
            if ll_rollup_found=false then
              ll_number_table:=ll_number_table+1;
              ll_table(ll_number_table):=p_s_tables(i);
              if g_debug then
                write_to_log_file_n('For table '||ll_table(ll_number_table)||', zero code rollup not defined '||
                'in metadata');
              end if;
            end if;
          end if;--if p_s_tables(i) <> l_lowest_s_table then
        end loop;--for i in 1..l_number_parameters loop
        if ll_number_table>0 then
          for i in 1..ll_number_table loop
            if g_debug then
              write_to_log_file_n('Going to create zero code rollups for '||ll_table(i));
            end if;
            for j in 1..ll_number_parameters loop
              l_number_parameters:=l_number_parameters+1;
              l_calculation_table(l_number_parameters):=ll_table(i);
              l_calculation_type(l_number_parameters):=l_calculation_type(j);
              l_parameter1(l_number_parameters):=l_parameter1(j);
              l_parameter2(l_number_parameters):=l_parameter2(j);
              l_parameter3(l_number_parameters):=l_parameter3(j);
              l_parameter4(l_number_parameters):=l_parameter4(j);
              l_parameter5(l_number_parameters):=l_parameter5(j);
            end loop;
          end loop;
        end if;
        if g_debug then
          write_to_log_file_n('After re-assigning the zero code rollups');
          for i in 1..l_number_parameters loop
            write_to_log_file(l_calculation_table(i)||' '||l_calculation_type(i)||' '||l_parameter1(i)||' '||
            l_parameter2(i)||' '||l_parameter3(i)||' '||l_parameter4(i)||' '||l_parameter5(i));
          end loop;
        end if;
      end if;--if l_number_parameters>0 then
      ------------------------------
    end if;--if l_lowest_s_table is not null then
  end;
  -----------------------------------------------------------------------
  if g_debug then
    write_to_log_file_n('Going to process this info to create the maps');
  end if;
  --if there are more than 1 b table or t table then we need to consolidate the b and t and
  --make one source.
  --see if we need to resolve the source. if the relation is B1,B2-> 24_5 -> 24_3 -> 24_1
  --then we need to make B1,B2-> 24_5 B1,B2-> 24_3 B1,B2-> 24_1
  declare
    ll_tables BSC_IM_UTILS.varchar_tabletype;
    ll_source_tables BSC_IM_UTILS.varchar_tabletype;
    ll_relation_type BSC_IM_UTILS.varchar_tabletype;
    ll_source_sql BSC_IM_UTILS.varchar_tabletype;
    ll_table_periodicity BSC_IM_UTILS.number_tabletype;
    ll_number_source_tables number;
    ------------------------------------------
    ll_list BSC_IM_UTILS.varchar_tabletype;
    ll_list_2 BSC_IM_UTILS.varchar_tabletype;
    ll_number_list number;
    ll_found boolean;
    ll_count integer;
    -----------------------------------------
    ll_bt_measures BSC_IM_UTILS.varchar_tabletype;
    ll_number_bt_measures number;
    ll_column_merge_group BSC_IM_UTILS.varchar_tabletype;
    ll_column_merge_group_sql BSC_IM_UTILS.varchar_tabletype;
    ll_number_column_merge_group number;
    ll_column_merge_sql BSC_IM_UTILS.varchar_tabletype; --uses p_number_s_tables
    ll_merge_sql varchar2(32000);

    ll_bt_measures_by_table VARCHAR2(32000);
    -----------------------------------------
    ll_prj_table_name varchar2(100);
  begin
    ll_number_source_tables:=0;
    l_number_bt_tables:=0;
    --first we need to consolidate the B tables and the T tables
    --the B tables and T tables only feed the first level summary table
    ll_number_column_merge_group:=0;
    --there is a difference between l_number_bt_tables and l_number_b_tables
    --l_number_bt_tables sees how many B and T tables feed this base the first level summary
    --l_number_b_tables goes recursively down and sees all the B tables involved.
    for i in 1..l_number_source_tables loop
      if BSC_IM_UTILS.is_like(l_source_tables(i),'BSC_B_')
        or BSC_IM_UTILS.is_like(l_source_tables(i),'BSC_T_') then
        l_number_bt_tables:=l_number_bt_tables+1;
        l_bt_tables(l_number_bt_tables):=l_source_tables(i);
      end if;
    end loop;
    if g_debug then
      write_to_log_file_n('The list of B tables and T tables that are sources');
      for i in 1..l_number_bt_tables loop
        write_to_log_file(l_bt_tables(i));
      end loop;
    end if;
    if g_debug then
      write_to_log_file_n('Process B and T tables which are sources');
    end if;
    --get the filter stmt.
    --had a discussion with mauricio and deb. it was decided that we will go for filter only in the case
    --for the lowest level of summary. when this data rolls to higher levels, the data is automatically
    --correctly filtered.
    --if there are more than 1 B tables then the filter stmt must be inside the union stmt
    --if there is only 1 base table, then the filter is a part of the normal from clause
    l_number_filter:=0;
    if g_debug then
      write_to_log_file_n('In Create_kpi_map_info--before get_filter_stmt'||' '||get_time);
    end if;
    if l_number_bt_tables>0 then
      if get_filter_stmt(
        p_indicator,
        l_lowest_s_table,
        l_filter_from,
        l_filter_where,
        l_number_filter,
        l_dim_level_tables,
        l_number_dim_level_tables,
        l_filter_first_level,
        l_filter_first_level_alias,
        l_filter_first_level_fk,
        l_num_filter_first_level
        )=false then
        return false;
      end if;
    end if;
    if l_number_bt_tables>1 then
      if g_debug then
        write_to_log_file_n('Going to merge the B tables and T tables together');
      end if;
      --the merging can be union or a column merge or both
      for i in 1..p_number_s_tables loop
        ll_number_list:=0;
        ll_column_merge_sql(i):=null;
        ll_number_column_merge_group:=0;
        for j in 1..l_number_source_tables loop
          if l_tables(j)=p_s_tables(i) and (
            BSC_IM_UTILS.is_like(l_source_tables(j),'BSC_B_')
            or BSC_IM_UTILS.is_like(l_source_tables(j),'BSC_T_')) then
            ll_number_list:=ll_number_list+1;
            ll_list(ll_number_list):=l_source_tables(j);
            ll_list_2(ll_number_list):=l_source_sql(j);
          end if;
        end loop;
        if ll_number_list>0 then
          for j in 1..ll_number_list loop
            ll_number_column_merge_group:=ll_number_column_merge_group+1;
            ll_column_merge_group(ll_number_column_merge_group):=ll_list(j);
            ll_column_merge_group_sql(ll_number_column_merge_group):=ll_list_2(j);
          end loop;
        end if;

        if g_debug then
          write_to_log_file_n('The B and T tables for column merge');
          for j in 1..ll_number_column_merge_group loop
            write_to_log_file(ll_column_merge_group(j)||' '||ll_column_merge_group_sql(j));
          end loop;
        end if;
        if ll_number_column_merge_group>0 then
          ll_column_merge_sql(i):='select ';
          for j in 1..l_number_fk loop
            if ll_number_column_merge_group=1 then
              ll_column_merge_sql(i):=ll_column_merge_sql(i)||l_fk(j)||',';
            else
              ll_column_merge_sql(i):=ll_column_merge_sql(i)||'prim.'||l_fk(j)||',';
            end if;
          end loop;
          ll_number_list:=0;
          ll_number_bt_measures:=0;
          --need to take common columns
          if get_table_measures(ll_column_merge_group,ll_number_column_merge_group,ll_list,
            ll_number_list)=false then
            return false;
          end if;
          for j in 1..ll_number_list loop
            if BSC_IM_UTILS.in_array(l_measures,l_number_measures,ll_list(j)) then
              ll_number_bt_measures:=ll_number_bt_measures+1;
              ll_bt_measures(ll_number_bt_measures):=ll_list(j);
            end if;
          end loop;
          for j in 1..ll_number_bt_measures loop
            ll_column_merge_sql(i):=ll_column_merge_sql(i)||ll_bt_measures(j)||',';
          end loop;
          ll_column_merge_sql(i):=substr(ll_column_merge_sql(i),1,length(ll_column_merge_sql(i))-1)||' from ';

          if ll_number_column_merge_group=1 then
            --if there is only one base table then we dont need to find prim etc
            if ll_column_merge_group_sql(1) is null then
              --ll_column_merge_sql(i):=ll_column_merge_sql(i)||ll_column_merge_group(1);
              -- if B table, then union with PRJ
              if (instr(ll_column_merge_group(1), 'BSC_B_')=1) then
                ll_column_merge_sql(i):=ll_column_merge_sql(i)||get_prj_union_clause(ll_column_merge_group(1));
              end if;
            else
              ll_column_merge_sql(i):=ll_column_merge_sql(i)||'('||ll_column_merge_group_sql(1)||') '||ll_column_merge_group(1);
            end if;
            if l_number_filter>0 then
              for j in 1..l_number_filter loop
                ll_column_merge_sql(i):=ll_column_merge_sql(i)||','||l_filter_from(j);
              end loop;
              ll_column_merge_sql(i):=ll_column_merge_sql(i)||' where '||l_periodicity_id_stmt;
              for j in 1..l_num_filter_first_level loop
                ll_column_merge_sql(i):=ll_column_merge_sql(i)||' and '||ll_column_merge_group(1)||'.'||
                l_filter_first_level_fk(j)||'='||l_filter_first_level_alias(j)||'.code ';
                --3613094
                if bsc_im_utils.is_column_in_object(l_filter_first_level(j),'LANGUAGE') then
                  ll_column_merge_sql(i):=ll_column_merge_sql(i)||' and '||
                  l_filter_first_level_alias(j)||'.language='''||BSC_IM_UTILS.get_lang||'''';
                end if;
              end loop;
              for j in 1..l_number_filter loop
                ll_column_merge_sql(i):=ll_column_merge_sql(i)||' '||l_filter_where(j);
              end loop;
            else
              ll_column_merge_sql(i):=ll_column_merge_sql(i)||' where '||l_periodicity_id_stmt;
            end if;
          else
            --ll_column_merge_sql(i):=ll_column_merge_sql(i)||'(';
            ll_column_merge_sql(i):='(';
            for j in 1..ll_number_column_merge_group loop
              --ll_column_merge_sql(i):=ll_column_merge_sql(i)||'select ';
              ll_column_merge_sql(i):=ll_column_merge_sql(i)||'select /*+ full('||ll_column_merge_group(j)||') */';
              -- periodicity_id, year, period, type are returned as fks
              for k in 1..l_number_fk loop
                ll_column_merge_sql(i):=ll_column_merge_sql(i)||l_fk(k)||',';
              end loop;
              ll_bt_measures_by_table := get_measures_by_table(ll_column_merge_group(j), ll_bt_measures, ll_number_bt_measures);
              if ( ll_bt_measures_by_table is not null) then
              	ll_column_merge_sql(i):=ll_column_merge_sql(i)||ll_bt_measures_by_table||',';
              end if;
              ll_column_merge_sql(i):=substr(ll_column_merge_sql(i),1,length(ll_column_merge_sql(i))-1);
              if ll_column_merge_group_sql(j) is null then
                -- Handle B_PRJ
                ll_prj_table_name := get_b_prj_table_name(ll_column_merge_group(j));
                if (ll_prj_table_name is null) then
                  ll_column_merge_sql(i):=ll_column_merge_sql(i)||' from '||ll_column_merge_group(j);
                else
                  -- ll_column_merge_sql(i):=ll_column_merge_sql(i)||', year, type, period from ';
                  -- ll_column_merge_sql(i):='('||ll_column_merge_sql(i)||ll_column_merge_group(j)||
                    --                       ' union all '||ll_column_merge_sql(i)|| ll_prj_table_name||') '||ll_column_merge_group(j);*/
                    ll_column_merge_sql(i):=ll_column_merge_sql(i)||' from '||get_prj_union_clause( ll_column_merge_group(j));
                end if;
              else
                ll_column_merge_sql(i):=ll_column_merge_sql(i)||' from ('||
                                         ll_column_merge_group_sql(j)||') '||ll_column_merge_group(j);
              end if;
              if l_number_filter>0 then
                for k in 1..l_number_filter loop
                  ll_column_merge_sql(i):=ll_column_merge_sql(i)||','||l_filter_from(k);
                end loop;
                ll_column_merge_sql(i):=ll_column_merge_sql(i)||' where '||l_periodicity_id_stmt;
                for k in 1..l_num_filter_first_level loop
                  ll_column_merge_sql(i):=ll_column_merge_sql(i)||' and '||ll_column_merge_group(j)||'.'||
                  l_filter_first_level_fk(k)||'='||l_filter_first_level_alias(k)||'.code ';
                  --3613094
                  if bsc_im_utils.is_column_in_object(l_filter_first_level(k),'LANGUAGE') then
                    ll_column_merge_sql(i):=ll_column_merge_sql(i)||' and '||
                    l_filter_first_level_alias(k)||'.language='''||BSC_IM_UTILS.get_lang||''' ';
                  end if;
                end loop;
                for k in 1..l_number_filter loop
                  ll_column_merge_sql(i):=ll_column_merge_sql(i)||' '||l_filter_where(k);
                end loop;
              else
                ll_column_merge_sql(i):=ll_column_merge_sql(i)||' where '||l_periodicity_id_stmt;
              end if;

              ll_column_merge_sql(i):=ll_column_merge_sql(i)||' union all ';
              if g_debug then
                write_to_log_file('ll_column_merge_sql('||i||')='||ll_column_merge_sql(i));
              end if;
            end loop;
            ll_column_merge_sql(i):=substr(ll_column_merge_sql(i),1,length(ll_column_merge_sql(i))-10);
            --ll_column_merge_sql(i):=ll_column_merge_sql(i)||') prim ';
            ll_column_merge_sql(i):=ll_column_merge_sql(i)||')  ';
          end if;
        end if;
        if g_debug then
          write_to_log_file_n('Column merge sql 1 '||ll_column_merge_sql(i));
        end if;
      end loop;--for i in 1..p_number_s_tables loop
      ll_merge_sql:=null;
      for i in 1..p_number_s_tables loop
        if ll_column_merge_sql(i) is not null then
          ll_merge_sql:=ll_merge_sql||ll_column_merge_sql(i)||' union all ';
        end if;
      end loop;
      ll_merge_sql:=substr(ll_merge_sql,1,length(ll_merge_sql)-10);
      if g_debug then
        write_to_log_file_n('The merge sql '||ll_merge_sql);
      end if;
      ll_merge_sql := ' (<SELECT DELIMITER> from ('||ll_merge_sql||') bsc_b <GROUP BY DELIMITER>)';
      b_no_agg := true;
      --now correct the pl/sql records for src info
      for i in 1..l_number_source_tables loop
        if BSC_IM_UTILS.is_like(l_source_tables(i),'BSC_B_')
          or BSC_IM_UTILS.is_like(l_source_tables(i),'BSC_T_') then
          l_source_tables(i):='BSC_B';
          l_source_sql(i):=ll_merge_sql;
        end if;
      end loop;
      --take distinct combination of target and source
      --we need this because there could have been multiple B and T tables. they all become the
      --consolidated src, BSC_B.
      ll_number_source_tables:=0;
      for i in 1..l_number_source_tables loop
        if BSC_IM_UTILS.in_array(ll_tables,ll_source_tables,ll_number_source_tables,
          l_tables(i),l_source_tables(i))=false then
          ll_number_source_tables:=ll_number_source_tables+1;
          ll_tables(ll_number_source_tables):=l_tables(i);
          ll_source_tables(ll_number_source_tables):=l_source_tables(i);
          ll_relation_type(ll_number_source_tables):=l_relation_type(i);
          ll_source_sql(ll_number_source_tables):=l_source_sql(i);
          ll_table_periodicity(ll_number_source_tables):=l_table_periodicity(i);
        end if;
      end loop;
      l_tables:=ll_tables;
      l_source_tables:=ll_source_tables;
      l_relation_type:=ll_relation_type;
      l_source_sql:=ll_source_sql;
      l_table_periodicity:=ll_table_periodicity;
      l_number_source_tables:=ll_number_source_tables;
      if g_debug then
        write_to_log_file_n('After substituting the B tables and T tables, the pl/sql records TSRSP');
        for i in 1..l_number_source_tables loop
          write_to_log_file(l_tables(i)||' '||l_source_tables(i)||' '||l_relation_type(i)||' '||
          l_source_sql(i)||' '||l_table_periodicity(i));
        end loop;
      end if;
    end if;--if l_number_bt_tables>1 then
    --if we have something like S_5->S_3->S_1, then the src for S_3 will be S_5. we need to change that to the
    --src for S_5. if BSC_B is the src for S_5, we need to make the src for S_3 BSC_B or BSC_B->S_5
    ll_count:=0;
    if g_debug then
      write_to_log_file_n('Modify the sources for higher periodicity table if the src is lower periodicity table');
    end if;
    if g_debug then
      write_to_log_file_n('The table of records');
      for i in 1..l_number_source_tables loop
        write_to_log_file(l_tables(i)||' '||l_source_tables(i)||' '||l_relation_type(i)||' '||
        l_source_sql(i)||' '||l_table_periodicity(i));
      end loop;
    end if;
    loop
      ll_count:=ll_count+1;
      if g_debug then
        write_to_log_file_n('Pass '||ll_count);
      end if;
      ll_found:=false;
      ll_number_source_tables:=0;
      for i in 1..l_number_source_tables loop
        ll_number_list:=0;
        for j in 1..l_number_source_tables loop
          if l_source_tables(i)=l_tables(j) then
            ll_found:=true;
            ll_number_list:=ll_number_list+1;
            ll_list(ll_number_list):=l_source_tables(j);
            ll_list_2(ll_number_list):=l_source_sql(j);
          end if;
        end loop;
        if ll_number_list=0 then
          ll_number_source_tables:=ll_number_source_tables+1;
          ll_tables(ll_number_source_tables):=l_tables(i);
          ll_source_tables(ll_number_source_tables):=l_source_tables(i);
          ll_relation_type(ll_number_source_tables):=l_relation_type(i);
          ll_source_sql(ll_number_source_tables):=l_source_sql(i);
          ll_table_periodicity(ll_number_source_tables):=l_table_periodicity(i);
        else
          for j in 1..ll_number_list loop
            ll_number_source_tables:=ll_number_source_tables+1;
            ll_tables(ll_number_source_tables):=l_tables(i);
            ll_source_tables(ll_number_source_tables):=ll_list(j);
            ll_relation_type(ll_number_source_tables):=l_relation_type(i);
            ll_source_sql(ll_number_source_tables):=ll_list_2(j);
            ll_table_periodicity(ll_number_source_tables):=l_table_periodicity(i);
          end loop;
        end if;
      end loop;
      l_tables:=ll_tables;
      l_source_tables:=ll_source_tables;
      l_relation_type:=ll_relation_type;
      l_source_sql:=ll_source_sql;
      l_table_periodicity:=ll_table_periodicity;
      l_number_source_tables:=ll_number_source_tables;
      if g_debug then
        write_to_log_file_n('After reassigning the sources, the table of records pass '||ll_count);
        for i in 1..l_number_source_tables loop
          write_to_log_file(l_tables(i)||' '||l_source_tables(i)||' '||l_relation_type(i)||' '||
          l_source_sql(i)||' '||l_table_periodicity(i));
        end loop;
      end if;
      if ll_found=false then
        exit;
      end if;
    end loop;
  end;
  --check to see if we can make a single sql or we need a union all
  --update the src table to MV
  for i in 1..l_number_source_tables loop
    if BSC_IM_UTILS.is_like(l_source_tables(i),'BSC_S_')
      or BSC_IM_UTILS.is_like(l_source_tables(i),'BSC_SB_') then
      l_source_tables(i):=substr(l_source_tables(i),1,instr(l_source_tables(i),'_',-1)-1)||'_MV';
    end if;
  end loop;
  if g_debug then
    write_to_log_file_n('After assigning the MV as sources, the table of records');
    for i in 1..l_number_source_tables loop
      write_to_log_file(l_tables(i)||' '||l_source_tables(i)||' '||l_relation_type(i)||' '||
      l_source_sql(i)||' '||l_table_periodicity(i));
    end loop;
  end if;
  for i in 1..l_number_source_tables loop
    l_eliminate(i):=null;
  end loop;
  --if S tables have SB as source, we need to have not exists clause to remove the target info from
  --non SB source
  for i in 1..l_number_source_tables loop
    if BSC_IM_UTILS.is_like(l_source_tables(i),'BSC_SB_') then
      for j in 1..l_number_source_tables loop
        if l_tables(j)=l_tables(i) and not(BSC_IM_UTILS.is_like(l_source_tables(j),'BSC_SB_')) then
          l_eliminate(j):=l_source_tables(i);
        end if;
      end loop;
    end if;
  end loop;
  if g_debug then
    write_to_log_file_n('After assigning the MV as sources, the table of records, eliminate is the last column');
    for i in 1..l_number_source_tables loop
      write_to_log_file(l_tables(i)||' '||l_source_tables(i)||' '||l_relation_type(i)||' '||
      l_source_sql(i)||' '||l_table_periodicity(i)||' '||l_eliminate(i));
    end loop;
  end if;
  -------------------------------------------------------
  --if there is a SB table that is feeding say periodicity 3,1 but not feeding say periodicity 5,
  --then we need to make sure that we put SB in the eliminate for 5
  declare
    ll_eliminate varchar2(200);
  begin
    for i in 1..l_number_source_tables loop
      if not(BSC_IM_UTILS.is_like(l_source_tables(i),'BSC_SB_')) and l_eliminate(i) is not null then
        ll_eliminate:=l_eliminate(i);
        for j in 1..l_number_source_tables loop
          if i<>j then
            if l_source_tables(j)=l_source_tables(i) and l_eliminate(j) is null then
              l_eliminate(j):=ll_eliminate;
            end if;
          end if;
        end loop;
      end if;
    end loop;
  end;
  if g_debug then
    write_to_log_file_n('After correcting eliminate info, the table of records, eliminate is the last column');
    for i in 1..l_number_source_tables loop
      write_to_log_file(l_tables(i)||' '||l_source_tables(i)||' '||l_relation_type(i)||' '||
      l_source_sql(i)||' '||l_table_periodicity(i)||' '||l_eliminate(i));
    end loop;
  end if;
  -------------------------------------------------------
  --add int metadata for MV relations, useful for summary mv reresh to decide the order
  for i in 1..l_number_source_tables loop
    if BSC_IM_UTILS.is_like(l_source_tables(i),'BSC_S_')
      or BSC_IM_UTILS.is_like(l_source_tables(i),'BSC_SB_') then
      if g_debug then
      	  write_to_log_file_n('In Create_kpi_map_info--Before BSC_IM_INT_MD.create_object'||' '||get_time);
      end if;
      if BSC_IM_INT_MD.create_object(
        l_source_tables(i),
        'SUMMARY MV',
        'BSC',
        p_mv_name,
        null,
        'MV DEPENDENCY')=false then
        if g_debug then
	  	  write_to_log_file_n('In Create_kpi_map_info--After BSC_IM_INT_MD.create_object'||' '||get_time);
        end if;
        return false;
      end if;
      if g_debug then
          write_to_log_file_n('In Create_kpi_map_info--After BSC_IM_INT_MD.create_object'||' '||get_time);
      end if;
    end if;
  end loop;
  -------------------------------------------------------
  /*make groups of the tables. we do this to make the sql efficient.
  we look at
  1. column source formula
  2. rollup formula
  3. is eliminate there?
  4. is the src table different?
  */
  declare
    -------------------------------------
    ll_groups BSC_IM_UTILS.varchar_tabletype;
    ll_number_groups number;
    -------------------------------------
    ll_table_grp BSC_IM_UTILS.varchar_tabletype;
    ll_table BSC_IM_UTILS.varchar_tabletype;
    ll_source BSC_IM_UTILS.varchar_tabletype;
    ll_number_table_grp number;
    -------------------------------------
    ll_column_grp BSC_IM_UTILS.varchar_tabletype;
    ll_column_formula BSC_IM_UTILS.varchar_tabletype;
    ll_column BSC_IM_UTILS.varchar_tabletype;
    ll_number_column_grp number;
    -------------------------------------
    ll_rollup_grp BSC_IM_UTILS.varchar_tabletype;
    ll_rollup_formula BSC_IM_UTILS.varchar_tabletype;
    ll_rollup_column BSC_IM_UTILS.varchar_tabletype;
    ll_number_rollup_grp number;
    -------------------------------------
    ll_eliminate_grp BSC_IM_UTILS.varchar_tabletype;
    ll_eliminate BSC_IM_UTILS.varchar_tabletype;
    ll_number_eliminate_grp number;
    -------------------------------------
    ll_new_reqd boolean;
    -------------------------------------
    ll_measure BSC_IM_UTILS.varchar_tabletype;
    ll_measure_formula BSC_IM_UTILS.varchar_tabletype;
    ll_number_measure number;
    -------------------------------------
  begin
    ll_number_groups:=0;
    ll_number_table_grp:=0;
    ll_number_column_grp:=0;
    ll_number_rollup_grp:=0;
    ll_number_eliminate_grp:=0;
    --go through the S tables
    for i in 1..l_number_source_tables loop
      ll_new_reqd:=false;
      if ll_number_groups=0 then
        ll_new_reqd:=true;
      else
        --see if new is required / or find the group to put this in
        for j in 1..ll_number_groups loop
          ll_new_reqd:=false;
          ---------------------------------------------
          --check the source
          if ll_new_reqd=false then
            for k in 1..ll_number_table_grp loop
              if ll_table_grp(k)=ll_groups(j) and ll_source(k)<>l_source_tables(i) then
                ll_new_reqd:=true;
                exit;
              end if;
            end loop;
          end if;
          ---------------------------------------------
          --check eliminate
          if ll_new_reqd=false then
            for k in 1..ll_number_eliminate_grp loop
              if ll_eliminate_grp(k)=ll_groups(j) and nvl(ll_eliminate(k),'abc')<>nvl(l_eliminate(i),'abc') then
                ll_new_reqd:=true;
                exit;
              end if;
            end loop;
          end if;
          ---------------------------------------------
          --check column formula
          if ll_new_reqd=false then
            ll_number_measure:=0;
            for k in 1..l_number_cols loop
              if l_col_table(k)=l_tables(i) and l_col_formula(k) is not null then
                ll_number_measure:=ll_number_measure+1;
                ll_measure(ll_number_measure):=l_cols(k);
                ll_measure_formula(ll_number_measure):=l_col_formula(k);
              end if;
            end loop;
            for k in 1..ll_number_column_grp loop
              if ll_column_grp(k)=ll_groups(j) then
                for m in 1..ll_number_measure loop
                  if ll_measure(m)=ll_column(k) and ll_measure_formula(m)<>ll_column_formula(k) then
                    ll_new_reqd:=true;
                    exit;
                  end if;
                end loop;
              end if;
              if ll_new_reqd then
                exit;
              end if;
            end loop;
          end if;
          ---------------------------------------------
          --check the rollup info
          if ll_new_reqd=false then
            ll_number_measure:=0;
            for k in 1..l_number_parameters loop
              if l_calculation_table(k)=l_tables(i) then
                ll_number_measure:=ll_number_measure+1;
                ll_measure(ll_number_measure):=l_parameter3(k);
                ll_measure_formula(ll_number_measure):=l_parameter5(k);
              end if;
            end loop;
            for k in 1..ll_number_rollup_grp loop
              if ll_rollup_grp(k)=ll_groups(j) then
                for m in 1..ll_number_measure loop
                  if ll_measure(m)=ll_rollup_column(k) and ll_measure_formula(m)<>ll_rollup_formula(k) then
                    ll_new_reqd:=true;
                    exit;
                  end if;
                end loop;
              end if;
              if ll_new_reqd then
                exit;
              end if;
            end loop;
          end if;
          ---------------------------------------------
          if ll_new_reqd=false then
            --matching group found
            l_group(i):=ll_groups(j);
            exit;
          end if;
        end loop;
      end if;
      if ll_new_reqd then
        --add the new group and the table, column,eliminate and rollup info
        ll_number_groups:=ll_number_groups+1;
        ll_groups(ll_number_groups):=ll_number_groups;
        ---------------------------------------------
        ll_number_table_grp:=ll_number_table_grp+1;
        ll_table_grp(ll_number_table_grp):=ll_groups(ll_number_groups);
        ll_table(ll_number_table_grp):=l_tables(i);
        ll_source(ll_number_table_grp):=l_source_tables(i);
        l_group(i):=ll_groups(ll_number_groups);
        ---------------------------------------------
        for j in 1..l_number_cols loop
          --no need to add the fk. just add the measures
          if l_col_table(j)=l_tables(i) and l_col_formula(j) is not null then
            ll_number_column_grp:=ll_number_column_grp+1;
            ll_column_grp(ll_number_column_grp):=ll_groups(ll_number_groups);
            ll_column_formula(ll_number_column_grp):=l_col_formula(j);
            ll_column(ll_number_column_grp):=l_cols(j);
          end if;
        end loop;
        ---------------------------------------------
        --add rollup agg
        for j in 1..l_number_parameters loop
          if l_calculation_table(j)=l_tables(i) then
            ll_number_rollup_grp:=ll_number_rollup_grp+1;
            ll_rollup_grp(ll_number_rollup_grp):=ll_groups(ll_number_groups);
            ll_rollup_formula(ll_number_rollup_grp):=l_parameter5(j);
            ll_rollup_column(ll_number_rollup_grp):=l_parameter3(j);
          end if;
        end loop;
        ---------------------------------------------
        --eliminate info
        ll_number_eliminate_grp:=ll_number_eliminate_grp+1;
        ll_eliminate_grp(ll_number_eliminate_grp):=ll_groups(ll_number_groups);
        ll_eliminate(ll_number_eliminate_grp):=l_eliminate(i);
        ---------------------------------------------
      end if;
    end loop;
  end;
  if g_debug then
    write_to_log_file_n('After assigning the Groups, the table of records, group is the last column');
    for i in 1..l_number_source_tables loop
      write_to_log_file(l_tables(i)||' '||l_source_tables(i)||' '||l_relation_type(i)||' '||
      l_source_sql(i)||' '||l_table_periodicity(i)||' '||l_eliminate(i)||' '||l_group(i));
    end loop;
  end if;
  -------------------------------------------------------
  --now generate the sql for each group. SB is last
  l_select_sql:=null;
  l_eliminate_sql:=null;
  l_select_sql_inc:=null;
  l_from_sql:=null;
  l_where_sql:=null;
  l_group_by_sql:=null;
  l_hint_sql := null;
  declare
    ------------------------------------------------------
    ll_distinct_groups BSC_IM_UTILS.varchar_tabletype;
    ll_number_distinct_groups number;
    ------------------------------------------------------
    ll_index number;
    ll_fk_index number;
    ll_col_index number;
    ll_temp varchar2(8000);
    ll_temp_alias varchar2(200);
    ll_dim_src_object varchar2(20000);
    ll_dim_src_object_type varchar2(100);
    ll_rec_dim boolean;
    ll_rec_dim_key varchar2(100);
    ------------------------------------------------------
    ll_zero_separate boolean;
    ------------------------------------------------------
    ll_rollup_fk BSC_IM_UTILS.varchar_tabletype;
    ll_rollup_fk_value BSC_IM_UTILS.varchar_tabletype;
    ll_number_rollup_fk number;
    ------------------------------------------------------
    ll_periodicity BSC_IM_UTILS.number_tabletype;
    ll_number_periodicity number;
    ------------------------------------------------------
     ll_keys_stmt varchar2(10000);
     ll_prj_table_name varchar2(100);
  begin
    --get the distinct groups
    ll_number_distinct_groups:=0;
    for i in 1..l_number_source_tables loop
      if BSC_IM_UTILS.in_array(ll_distinct_groups,ll_number_distinct_groups,l_group(i))=false then
        ll_number_distinct_groups:=ll_number_distinct_groups+1;
        ll_distinct_groups(ll_number_distinct_groups):=l_group(i);
      end if;
    end loop;
    if g_debug then
      write_to_log_file_n('Going to look at these distinct groups');
      for i in 1..ll_number_distinct_groups loop
        write_to_log_file(ll_distinct_groups(i));
      end loop;
    end if;
    for i in 1..ll_number_distinct_groups loop
      ll_index:=0;
      for j in 1..l_number_source_tables loop
        if l_group(j)=ll_distinct_groups(i) then
          ll_index:=j;
          exit;
        end if;
      end loop;
      ll_number_periodicity:=0;
      --assign the period type id
      for j in 1..l_number_source_tables loop
        l_table_period_type_id(j):=get_period_type_id_for_period(l_table_periodicity(j));
      end loop;
      for j in 1..l_number_source_tables loop
        if l_group(j)=ll_distinct_groups(i) then
          ll_number_periodicity:=ll_number_periodicity+1;
          ll_periodicity(ll_number_periodicity):=l_table_periodicity(j);
        end if;
      end loop;
      --we are sure of the following in a group
      --same col formula, same source and same rollup and same filter
      --make the select clause
      if ll_index>0 then
        l_select_sql:='select ';
        l_from_sql:=' from ';
        l_where_sql:=' where '||l_source_tables(ll_index)||'.periodicity_id in (';
        l_group_by_sql:=null;
        l_select_sql_inc:=null;
        l_hint_sql := '/*+ use_hash(';
		--l_hint_sql := l_hint_sql||')*/';
        for j in 1..ll_number_periodicity loop
          l_where_sql:=l_where_sql||ll_periodicity(j)||',';
        end loop;
        l_where_sql:=substr(l_where_sql,1,length(l_where_sql)-1)||')';
        if l_source_sql(ll_index) is not null then
          l_from_sql:=l_from_sql||' ('||l_source_sql(ll_index)||') ';
          l_from_sql:=l_from_sql||l_source_tables(ll_index)||' ';
          --here, l_source_tables(ll_index) will be BSC_B
          l_hint_sql := l_hint_sql||l_source_tables(ll_index)||' ';
        else
          if l_source_tables(ll_index)<>'BSC_B' then
            -- handle b_prj, P1 5214589
            if BSC_IM_UTILS.is_like(l_source_tables(ll_index),'BSC_B_') then
              ll_prj_table_name := get_b_prj_table_name(l_source_tables(ll_index));
              if (ll_prj_table_name is not null) then
                l_from_sql:=l_from_sql||get_prj_union_clause(l_source_tables(ll_index));
              else
                l_from_sql:=l_from_sql||bsc_im_utils.get_table_owner(l_source_tables(ll_index))
                  ||'.'||l_source_tables(ll_index)||
                  ' '||l_source_tables(ll_index);
              end if;
            else
              l_from_sql:=l_from_sql||bsc_im_utils.get_table_owner(l_source_tables(ll_index))
                  ||'.'||l_source_tables(ll_index)||
                  ' '||l_source_tables(ll_index);
            end if;
          else
            --for safety. code must not come here
            l_from_sql:=l_from_sql||l_source_tables(ll_index)||' ';
          end if;
          l_hint_sql := l_hint_sql||l_source_tables(ll_index)||' ';
        end if;
        ----------------------------------------------------------
        --0 code we need to calculate this early to properly form group_by and select
        ll_number_rollup_fk:=0;
        if l_db_version='8i' then
          ll_zero_separate:=true;
        else
          ll_zero_separate:=false;
        end if;
        -------------------------------
        --change for zero code. after discussion with deb it was decided to use
        --union all for the zero code mv. this way we can get fast refresh mv.
        --so ll_zero_separate is true even for 9i
        --in 9i, if there is partial rollup, we dont get fast refresh
        ll_zero_separate:=true;
        -------------------------------
        if not(BSC_IM_UTILS.is_like(l_source_tables(ll_index),'BSC_SB_')) then
          if ll_zero_separate=false then --this is 9i
            --see if the 0 code aggregations are different from the normal aggregations
            --if the target is S and src table is SB, no zero code
            if BSC_IM_UTILS.is_like(l_tables(ll_index),'BSC_S_')
              and BSC_IM_UTILS.is_like(l_source_tables(ll_index),'BSC_SB_') then
              if g_debug then
                write_to_log_file_n('No zero code when target is S and src is SB');
              end if;
            else
              for j in 1..l_number_parameters loop
                if l_calculation_table(j)=l_tables(ll_index) then
                  ll_col_index:=0;
                  ll_col_index:=BSC_IM_UTILS.get_index(l_col_table,l_cols,l_number_cols,l_tables(ll_index),
                  l_parameter3(j));
                  if ll_col_index>0 then
                    if l_parameter5(j)<>l_col_formula(ll_col_index) then
                      ll_zero_separate:=true;
                      exit;
                    end if;
                  else
                    ll_zero_separate:=true;
                    exit;
                  end if;
                end if;
              end loop;
            end if;
          end if;
        end if;--if l_source_tables(ll_index) not like 'BSC_SB_%' then
        --------------------------------------------------------
        ll_keys_stmt := null;
        write_to_log_file('Now fks');
        --then the fks
        for j in 1..l_number_fk loop
          ll_fk_index:=BSC_IM_UTILS.get_index(l_col_table,l_cols,l_number_cols,l_tables(ll_index),
          l_fk(j));
          if ll_fk_index>0 then
            --S B ok --rollup to higher level in the dimension
            --S S ok --rollup to higher level in the dimension
            --SB SB ok --rollup to higher level in the dimension
            --S SB not ok
            ll_keys_stmt := ll_keys_stmt||l_cols(ll_fk_index)||',';
            if BSC_IM_UTILS.is_like(l_tables(ll_index),'BSC_S_')
              and BSC_IM_UTILS.is_like(l_source_tables(ll_index),'BSC_SB_') then
              l_select_sql:=l_select_sql||l_source_tables(ll_index)||'.'||l_cols(ll_fk_index)||' '||
              l_cols(ll_fk_index)||',';
              l_group_by_sql:=l_group_by_sql||l_source_tables(ll_index)||'.'||l_cols(ll_fk_index)||',';
              if l_eliminate(ll_index) is not null then
                l_eliminate_sql:=l_eliminate_sql||l_eliminate(ll_index)||'.'||l_fk(j)||'='||
                l_source_tables(ll_index)||'.'||l_cols(ll_fk_index)||' and ';
              end if;
            else
              if upper(l_cols(ll_fk_index))<>upper(l_col_source(ll_fk_index)) then
                /*
                ll_dim_src_object is the name of the materialized dim table  from dbi. this table belongs
                to the bsc schema. this table is required to get over the issue of complex views and to have
                fast refresh MV
                */
                --ll_temp is the level alias
                --ll_dim_src_object is the table or inline sql
                if get_level_for_pk(l_col_source(ll_fk_index),ll_temp,ll_dim_src_object,ll_dim_src_object_type,
                  ll_rec_dim,ll_rec_dim_key)=false then
                  return false;
                end if;
                ---------------------
                /*
                BSC 5.2 E2E
                support for complex views
                to support complex views and to get fast refresh mv , we had to materialize the dbi dimension views.
                BSCDDIMB.pls has the static class weith info on the table name etc
                we must make the MV join with the table we have created.
                we assume that the table is a reflection of the dim level view. the table has the code column and
                higher level codes. if its date tracked, it can have code and parent code
                currently (7/13/04), none of the dim levels have parent levels. they are all single level dim, including
                the date tracked dim levels
                */
                ----------
                --l_dim_level_stmt:=l_dim_level_stmt||ll_temp||'+';
                ll_temp_alias:=substr(ll_temp,1,30-length(j))||j;
                if ll_dim_src_object_type='none' then
                  if BSC_IM_UTILS.in_array(l_dim_level_tables,l_number_dim_level_tables,ll_dim_src_object)=false then
                    l_number_dim_level_tables:=l_number_dim_level_tables+1;
                    l_dim_level_tables(l_number_dim_level_tables):=ll_dim_src_object;
                  end if;
                end if;
                ----------
                if ll_rec_dim then
                  -- ONLY FIRST LEVEL OF RECURSIVE DIMENSION SHD BE DIFFERENT
                  if  BSC_IM_UTILS.is_like(l_source_tables(ll_index),'BSC_S_') then -- higher level rec dim
                    l_select_sql:=l_select_sql||l_source_tables(ll_index)||'.'||l_cols(ll_fk_index)||' '||l_cols(ll_fk_index)||',';
                    l_group_by_sql:=l_group_by_sql||l_source_tables(ll_index)||'.'||l_cols(ll_fk_index)||',';
                  else
                    l_select_sql:=l_select_sql||'nvl('||ll_temp_alias||'.'||ll_rec_dim_key||','||
                    l_source_tables(ll_index)||'.'||l_cols(ll_fk_index)||') '||l_cols(ll_fk_index)||',';
                    l_group_by_sql:=l_group_by_sql||'nvl('||ll_temp_alias||'.'||ll_rec_dim_key||','||
                    l_source_tables(ll_index)||'.'||l_cols(ll_fk_index)||'),';
                  end if;
                else
                  l_select_sql:=l_select_sql||ll_temp_alias||'.'||l_cols(ll_fk_index)||' '||l_cols(ll_fk_index)||',';
                  l_group_by_sql:=l_group_by_sql||ll_temp_alias||'.'||l_cols(ll_fk_index)||',';
                end if;
                if ll_dim_src_object_type='inline' then
                  l_from_sql:=l_from_sql||','||ll_dim_src_object||' '||ll_temp_alias;
                else
                  if ll_dim_src_object_type ='recursive' and  BSC_IM_UTILS.is_like(l_source_tables(ll_index),'BSC_S_') then
                    null;
                  else
                  l_from_sql:=l_from_sql||','||bsc_im_utils.get_table_owner(ll_dim_src_object)||'.'||ll_dim_src_object||' '||ll_temp_alias;
                  end if;
                end if;
                l_hint_sql := l_hint_sql||ll_temp_alias||' ';
                if ll_rec_dim and ll_dim_src_object_type<>'recursive' then
                  l_where_sql:=l_where_sql||' and '||ll_temp_alias||'.CODE(+)='||l_source_tables(ll_index)||'.'||
                  l_col_source(ll_fk_index)||' ';
                else
                  l_where_sql:=l_where_sql||' and '||ll_temp_alias||'.CODE='||l_source_tables(ll_index)||'.'||
                  l_col_source(ll_fk_index)||' ';
                end if;
                --3613094
                if bsc_im_utils.is_column_in_object(ll_dim_src_object,'LANGUAGE') then
                  l_where_sql:=l_where_sql||' and '||ll_temp_alias||'.LANGUAGE='''||BSC_IM_UTILS.get_lang||''' ';
                end if;
                if l_eliminate(ll_index) is not null then
                  l_eliminate_sql:=l_eliminate_sql||l_eliminate(ll_index)||'.'||l_fk(j)||'='||
                  ll_temp_alias||'.'||l_cols(ll_fk_index)||' and ';
                end if;
                ------------------------------------------
              else --if l_cols(ll_fk_index)<>l_col_source(ll_fk_index) then  its the same level here
                /*
                for 5.2 we need to make a change where we join to the dim level no matter what
                this is because by joining to the dim level like DBI mv, we can automatically handle the
                changes to the dim levels like dim deletes, dim updates etc
                these dim levels are also added to l_dim_level_tables so mv logs can be created on them
                here, l_cols(ll_fk_index)=l_col_source(ll_fk_index)
                */
                /*
                please see the above section on E2E kpi and need for materializing the dbi views
                */
                --ll_dim_src_object does not have the language column.
                --it has code, maybe parent code and effective dates etc
                if get_level_for_pk(l_cols(ll_fk_index),ll_temp,ll_dim_src_object,ll_dim_src_object_type,
                  ll_rec_dim,ll_rec_dim_key)=false then
                  return false;
                end if;
                --l_dim_level_stmt:=l_dim_level_stmt||ll_temp||'+';
                ----------
                ll_temp_alias:=substr(ll_temp,1,30-length(j))||j;
                if ll_dim_src_object_type='none' then
                  if BSC_IM_UTILS.in_array(l_dim_level_tables,l_number_dim_level_tables,ll_dim_src_object)=false then
                    l_number_dim_level_tables:=l_number_dim_level_tables+1;
                    l_dim_level_tables(l_number_dim_level_tables):=ll_dim_src_object;
                  end if;
                end if;
                if ll_rec_dim and NOT BSC_IM_UTILS.is_like(l_source_tables(ll_index),'BSC_S_') then
                  if ll_dim_src_object_type<>'recursive' then -- DBI recursive
                    l_select_sql:=l_select_sql||'nvl('||ll_temp_alias||'.'||ll_rec_dim_key||','||
                      l_source_tables(ll_index)||'.'||l_cols(ll_fk_index)||') '||l_cols(ll_fk_index)||',';
                    l_group_by_sql:=l_group_by_sql||'nvl('||ll_temp_alias||'.'||ll_rec_dim_key||','||
                      l_source_tables(ll_index)||'.'||l_cols(ll_fk_index)||'),';
                  else  -- BSC Recursive
                    l_select_sql:=l_select_sql||ll_temp_alias||'.'||ll_rec_dim_key ||' '||l_cols(ll_fk_index)||',';
                    l_group_by_sql:=l_group_by_sql||ll_temp_alias||'.'||ll_rec_dim_key||',';
                  end if;
                else
                  l_select_sql:=l_select_sql||l_source_tables(ll_index)||'.'||l_cols(ll_fk_index)||' '||
                  l_cols(ll_fk_index)||',';
                  l_group_by_sql:=l_group_by_sql||l_source_tables(ll_index)||'.'||l_cols(ll_fk_index)||',';
                end if;
                if ll_dim_src_object_type='inline' then
                  l_from_sql:=l_from_sql||','||ll_dim_src_object||' '||ll_temp_alias;
                else
                  if ll_dim_src_object_type='recursive' and  BSC_IM_UTILS.is_like(l_source_tables(ll_index),'BSC_S_') then
                    null;
                  else
                    l_from_sql:=l_from_sql||','||bsc_im_utils.get_table_owner(ll_dim_src_object)||'.'||ll_dim_src_object||' '||ll_temp_alias;
                  end if;
                end if;
                l_hint_sql := l_hint_sql||ll_temp_alias||' ';
                if ll_rec_dim and ll_dim_src_object_type<>'recursive'  then
                  l_where_sql:=l_where_sql||' and '||ll_temp_alias||'.CODE(+)='||l_source_tables(ll_index)||'.'||
                  l_cols(ll_fk_index)||' ';
                else
                  -- for recursive dim. higher levels, we dont include the dimension
                  if ll_rec_dim and BSC_IM_UTILS.is_like(l_source_tables(ll_index),'BSC_S_') then --
                    null;
                  else
                    l_where_sql:=l_where_sql||' and '||ll_temp_alias||'.CODE='||l_source_tables(ll_index)||'.'||
                    l_cols(ll_fk_index)||' ';
                  end if;
                end if;
                --3613094
                if bsc_im_utils.is_column_in_object(ll_dim_src_object,'LANGUAGE') then
                  l_where_sql:=l_where_sql||' and '||ll_temp_alias||'.LANGUAGE='''||BSC_IM_UTILS.get_lang||''' ';
                end if;
                if l_eliminate(ll_index) is not null then
                  l_eliminate_sql:=l_eliminate_sql||l_eliminate(ll_index)||'.'||l_fk(j)||'='||
                  l_source_tables(ll_index)||'.'||l_cols(ll_fk_index)||' and ';
                end if;
              end if;
            end if;
          else
            --PERIOD,YEAR,TYPE
            l_select_sql:=l_select_sql||l_source_tables(ll_index)||'.'||l_fk(j)||' '||l_fk(j)||',';
            l_group_by_sql:=l_group_by_sql||l_source_tables(ll_index)||'.'||l_fk(j)||',';
            if l_eliminate(ll_index) is not null then
              l_eliminate_sql:=l_eliminate_sql||l_eliminate(ll_index)||'.'||l_fk(j)||'='||
              l_source_tables(ll_index)||'.'||l_fk(j)||' and ';
            end if;
          end if;
        end loop;
        ----------------------------------------------------------
        write_to_log_file('now measures');
        --second the measures
        declare
          lll_agg_columns BSC_IM_UTILS.varchar_tabletype;
          lll_number_agg_columns number;
          lll_list BSC_IM_UTILS.varchar_tabletype;
          lll_number_list number;
          lll_fk_index number;
        begin
          lll_number_agg_columns:=0;
          l_select_no_aggregation := l_select_sql;
          for j in 1..l_number_cols loop
            if l_col_table(j)=l_tables(ll_index) and l_col_type(j)='A' then
              if b_no_agg then
                l_select_no_aggregation := l_select_no_aggregation||' '||l_cols(j)||',';
                write_to_log_file(' adding to no agg select :'|| l_select_no_aggregation);
              end if;
              l_select_sql:=l_select_sql||l_col_formula(j)||' '||l_cols(j)||',';
              --find_aggregation_columns, needed for inv refresh MV
              lll_number_list:=0;
              if BSC_IM_UTILS.find_aggregation_columns(l_col_formula(j),lll_list,
                lll_number_list)=false then
                lll_number_list:=0;
              end if;
              for k in 1..lll_number_list loop
                if BSC_IM_UTILS.in_array(lll_agg_columns,lll_number_agg_columns,lll_list(k))=false then
                  lll_number_agg_columns:=lll_number_agg_columns+1;
                  lll_agg_columns(lll_number_agg_columns):=lll_list(k);
                end if;
              end loop;
            end if;
          end loop;
          for j in 1..lll_number_agg_columns loop
            l_select_sql_inc:=l_select_sql_inc||',count('||lll_agg_columns(j)||') '||
            substr('cnt_'||lll_agg_columns(j),1,27)||'_'||j;
          end loop;
          l_select_sql_inc:=l_select_sql_inc||',count(*) count_all';
        end;
        -------------------------------------------------------
        if b_no_agg then
          l_select_no_aggregation := substr(l_select_no_aggregation,1, length(l_select_no_aggregation)-1);
          l_select_no_aggregation := l_select_no_aggregation||',decode('||l_source_tables(ll_index)||'.periodicity_id,';
        end if;
         l_select_sql:=substr(l_select_sql,1,length(l_select_sql)-1);
        --period_type_id for XTD
        l_select_sql:=l_select_sql||',decode('||l_source_tables(ll_index)||'.periodicity_id,';
        for j in 1..l_number_source_tables loop
          l_select_sql:=l_select_sql||l_table_periodicity(j)||','||l_table_period_type_id(j)||',';
          l_select_no_aggregation := l_select_no_aggregation|| l_table_periodicity(j)||','||l_table_period_type_id(j)||',';
        end loop;
        l_select_sql:=l_select_sql||'null) period_type_id';
        l_select_no_aggregation := l_select_no_aggregation||'null) period_type_id';
        --l_select_sql:=l_select_sql||',decode('||l_source_tables(ll_index)||'.periodicity_id,9,1,7,16,5,32,4,2048,'||
        --'3,64,2,4096,1,128,null) period_type_id';
        l_group_by_sql:=substr(l_group_by_sql,1,length(l_group_by_sql)-1);
        if l_eliminate(ll_index) is not null then
          l_eliminate_sql:=substr(l_eliminate_sql,1,length(l_eliminate_sql)-4);
        end if;
        l_select_basic := l_select_sql;
        ----------------------------------------------------------
        --process filter
        --if there is only 1 base table then the filter is a part of the normal from clause
        if l_number_bt_tables=1 then
          if l_number_filter>0 then
            for j in 1..l_number_filter loop
              l_from_sql:=l_from_sql||','||l_filter_from(j);
              l_hint_sql := l_hint_sql||l_filter_from(j)||' ';
            end loop;
            for j in 1..l_num_filter_first_level loop
              l_where_sql:=l_where_sql||' and '||l_source_tables(ll_index)||'.'||
              l_filter_first_level_fk(j)||'='||l_filter_first_level_alias(j)||'.code ';
              --3613094
              if bsc_im_utils.is_column_in_object(l_filter_first_level(j),'LANGUAGE') then
                l_where_sql:=l_where_sql||' and '||l_filter_first_level_alias(j)||'.language='''||BSC_IM_UTILS.get_lang||''' ';
              end if;
            end loop;
            for j in 1..l_number_filter loop
              l_where_sql:=l_where_sql||' '||l_filter_where(j);
            end loop;
          end if;
        end if;
        ----------------------------------------------------------
        --process eliminate
        --write_to_log_file('process eliminate');
        if l_eliminate(ll_index) is not null then
          l_where_sql:=l_where_sql||' and not exists (select 1 from '||l_eliminate(ll_index)||' where '||
          l_eliminate_sql||')';
        end if;--if l_eliminate(ll_index) is not null then
        ----------------------------------------------------------
        --correct the stmts if required
        if l_where_sql=' where 1=1' then
          l_where_sql:=null;
        end if;
        if l_group_by_sql is not null then
          l_group_by_sql:=' group by '||l_group_by_sql;
        end if;
        ----------------------------------------------------------
        if b_no_agg then
          l_from_sql := replace(l_from_sql, '<SELECT DELIMITER>', l_select_basic);
          l_from_sql := replace(l_from_sql, '<GROUP BY DELIMITER>', l_group_by_sql);
        end if;
        if g_debug then
          write_to_log_file_n('select no agg = '||l_select_no_aggregation);
          write_to_log_file_n('select sql='||l_select_sql);
          write_to_log_file_n('select sql inc='||l_select_sql_inc);
          write_to_log_file_n('from sql='||l_from_sql);
          write_to_log_file_n('where sql='||l_where_sql);
          write_to_log_file_n('group by sql='||l_group_by_sql);
          write_to_log_file_n('hint sql='||l_hint_sql);
          write_to_log_file_n('keys='||ll_keys_stmt);
        end if;
        ---------------------------------------------------------------------
        --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        --LOAD Intermediate metadata

        -- Add l_hint_sql to l_select_sql;
        l_select_sql := 'select '||l_hint_sql||')*/ '||substr(l_select_sql, 7, length(l_select_sql));
        if (b_no_agg) then
          l_select_sql := 'select '||l_hint_sql||')*/ '||substr(l_select_no_aggregation, 7, length(l_select_no_aggregation));
          l_group_by_sql := null;
          --if (g_debug) then
            --write_to_log_file_n('select sql after no agg changes='||l_select_sql);
          --end if;
        end if;

        if BSC_IM_INT_MD.create_mapping_detail(p_map_name,'BSC',l_select_sql,'SELECT',null)=false then
          return false;
        end if;
        if BSC_IM_INT_MD.create_mapping_detail(p_map_name,'BSC',l_select_sql_inc,'SELECT INC',null)=false then
          return false;
        end if;
        if (ll_keys_stmt is not null) then
          ll_keys_stmt := substr(ll_keys_stmt, 1, length(ll_keys_stmt)-1);
          if BSC_IM_INT_MD.create_mapping_detail(p_map_name,'BSC',ll_keys_stmt,'KEYS',null)=false then
            return false;
          end if;
        end if;
        if BSC_IM_INT_MD.create_mapping_detail(p_map_name,'BSC',l_from_sql,'FROM',null)=false then
          return false;
        end if;
        if BSC_IM_INT_MD.create_mapping_detail(p_map_name,'BSC',l_where_sql,'WHERE',null)=false then
          return false;
        end if;
        if BSC_IM_INT_MD.create_mapping_detail(p_map_name,'BSC',l_group_by_sql,'GROUP BY',null)=false then
          return false;
        end if;

        ---------------------------------------------------------------------
      else
        if g_debug then
          write_to_log_file_n('ll_index=0. Some problem. ID 1');
        end if;
      end if;--if ll_index>0 then
    end loop;--for i in 1..ll_number_distinct_groups loop
    ---------------------------------------------------------------
    ---------------------------------------------------------------
    -------------  ZERO CODE CALCULATIONS -------------------------
    ---------------------------------------------------------------
    declare
      ----------------------
      ll_union_creator BSC_IM_UTILS.number_tabletype;--does 3C1+3C2+3C3 etc
      ll_start number;
      ll_run number;
      ll_pointer number;
      ----------------------
      --what union has what keys
      ll_union_table BSC_IM_UTILS.number_tabletype;
      ll_union_keys BSC_IM_UTILS.varchar_tabletype;
      ll_union_key_values BSC_IM_UTILS.varchar_tabletype;
      ll_number_union_table number;
      ll_union_number number;
      ----------------------
      ll_count number;
      ----------------------
      ll_max_rollup_keys_for_union number;
      ll_use_union_for_rollup boolean;
      ----------------------
      ll_keys varchar2(10000);
    begin
      ll_number_rollup_fk:=0;
      ll_use_union_for_rollup:=true;
      ll_max_rollup_keys_for_union:=3;--hardcoding it to 3 for now.
      if g_debug then
        write_to_log_file_n('-------------------------------------------');
        write_to_log_file('PROCESSING ZERO CODE');
        write_to_log_file('-------------------------------------------');
        write_to_log_file('no. of parameters='||l_number_parameters);
      end if;
      for j in 1..l_number_parameters loop
        if l_calculation_table(j)=l_tables(ll_index) then
          if BSC_IM_UTILS.in_array(ll_rollup_fk,ll_number_rollup_fk,l_parameter1(j))=false then
            ll_number_rollup_fk:=ll_number_rollup_fk+1;
            ll_rollup_fk(ll_number_rollup_fk):=l_parameter1(j);
            ll_rollup_fk_value(ll_number_rollup_fk):=l_parameter2(j);
          end if;
        end if;
      end loop;
      if g_debug then
        write_to_log_file_n('The FK for zero code and value');
        for j in 1..ll_number_rollup_fk loop
          write_to_log_file(ll_rollup_fk(j)||' '||ll_rollup_fk_value(j));
        end loop;
      end if;
      if ll_number_rollup_fk>0 then
        --see if we want to use union all or we want to only go for cube
        if ll_number_rollup_fk>ll_max_rollup_keys_for_union then
          ll_use_union_for_rollup:=false;
          if g_debug then
            write_to_log_file_n('Not using union all as number of rollup keys > '||ll_max_rollup_keys_for_union);
          end if;
        else
          ll_use_union_for_rollup:=true;
          if g_debug then
            write_to_log_file_n('Using union for zero code mv');
          end if;
        end if;
        --first make the entries for the unions
        --we need to have a array as
        /*
        The union array and the keys
        1 CODE_CSO
        2 CODE_DIVISION
        3 CODE_WAREHOUSE
        4 CODE_CSO
        4 CODE_DIVISION
        5 CODE_CSO
        5 CODE_WAREHOUSE
        6 CODE_DIVISION
        6 CODE_WAREHOUSE
        7 CODE_CSO
        7 CODE_DIVISION
        7 CODE_WAREHOUSE

        1,2,3 = 1 at a time
        4,5,6 = 2 at a time
        7     = 3 at a time
        */
        ll_number_union_table:=0;
        ll_union_number:=0;
        for j in 1..ll_number_rollup_fk loop --keys at a time looking at
          for k in 1..j loop
            ll_union_creator(k):=k;
          end loop;
          ll_pointer:=j;--the last element
          -----------
          --add the keys into the union pl/sql table
          --ll_union_number BSC_IM_UTILS.number_tabletype;
          --ll_union_keys BSC_IM_UTILS.varchar_tabletype;
          --ll_number_union_table number;
          loop
            ll_union_number:=ll_union_number+1;
            for k in 1..j loop
              ll_number_union_table:=ll_number_union_table+1;
              ll_union_table(ll_number_union_table):=ll_union_number;
              ll_union_keys(ll_number_union_table):=ll_rollup_fk(ll_union_creator(k));
              ll_union_key_values(ll_number_union_table):=ll_rollup_fk_value(ll_union_creator(k));
            end loop;
            if ll_union_creator(ll_pointer)+1 > ll_number_rollup_fk then
              <<pointer_start>>
              ll_pointer:=ll_pointer-1;
              if ll_pointer<1 then
                exit;
              else
                loop
                  ll_union_creator(ll_pointer):=ll_union_creator(ll_pointer)+1;
                  ll_count:=0;
                  for m in ll_pointer+1..j loop
                    ll_count:=ll_count+1;
                    ll_union_creator(m):=ll_union_creator(ll_pointer)+ll_count;
                  end loop;
                  if ll_union_creator(j)>ll_number_rollup_fk then
                    goto pointer_start;
                  else
                    ll_pointer:=j;
                    exit;--from the inner loop
                  end if;
                end loop;
              end if;
            else
              ll_union_creator(ll_pointer):=ll_union_creator(ll_pointer)+1;
            end if;
          end loop;
          -----------
        end loop;
        if g_debug then
          write_to_log_file_n('The union array and the keys');
          for j in 1..ll_number_union_table loop
            write_to_log_file(ll_union_table(j)||' '||ll_union_keys(j)||' '||ll_union_key_values(j));
          end loop;
        end if;
        -------------------------------------------
        --at this point, we have the info on union for 1 at a time, 2 at a time etc
        l_rollup_full_select_sql:=' select ';
        l_rollup_full_from_sql:=' from '||bsc_im_utils.get_table_owner(p_mv_name)||'.'||p_mv_name||' '||p_mv_name;
        l_rollup_full_where_sql:=null;
        l_rollup_full_group_by_sql:=' group by ';
        --loop for each union
        for j in 1..ll_union_number loop
          l_rollup_select_sql(j):=' select ';
          l_rollup_from_sql(j):=' from '||p_mv_name;
          l_rollup_where_sql(j):=null;
          l_rollup_group_by_sql(j):=' group by ';
        end loop;
        -------first the FKs--------------------------
        if g_debug then
          write_to_log_file_n('going to process the keys');
        end if;
        declare
          ll_index number;
          ll_fk_cube BSC_IM_UTILS.varchar_tabletype;
          ll_number_fk_cube number;
        begin
          if ll_use_union_for_rollup then
            for j in 1..ll_union_number loop
              for k in 1..l_number_fk loop
                ll_index:=0;
                ll_index:=BSC_IM_UTILS.get_index(ll_union_keys,ll_union_table,ll_number_union_table,l_fk(k),j);
                if ll_index>0 then --this key is in the rollup
                  l_rollup_select_sql(j):=l_rollup_select_sql(j)||ll_union_key_values(ll_index)||' '||
                  ll_union_keys(ll_index)||',';
                else
                  l_rollup_select_sql(j):=l_rollup_select_sql(j)||l_fk(k)||',';
                  l_rollup_group_by_sql(j):=l_rollup_group_by_sql(j)||l_fk(k)||',';
                end if;
              end loop;
            end loop;
          end if;
          --the full refresh sql------------------------
          ----------------------------------------------
          if g_debug then
            write_to_log_file_n('going to process full refresh keys');
          end if;
          ll_number_fk_cube:=0;
          for k in 1..l_number_fk loop
            ll_index:=0;
            ll_index:=BSC_IM_UTILS.get_index(ll_rollup_fk,ll_number_rollup_fk,l_fk(k));
            if ll_index>0 then --this key is in the rollup
              l_rollup_full_select_sql:=l_rollup_full_select_sql||'decode(grouping('||ll_rollup_fk(ll_index)||'),'||
              '1,'||ll_rollup_fk_value(ll_index)||','||ll_rollup_fk(ll_index)||') '||ll_rollup_fk(ll_index)||',';
              ll_number_fk_cube:=ll_number_fk_cube+1;
              ll_fk_cube(ll_number_fk_cube):=l_fk(k);
            else
              l_rollup_full_select_sql:=l_rollup_full_select_sql||l_fk(k)||',';
              l_rollup_full_group_by_sql:=l_rollup_full_group_by_sql||l_fk(k)||',';
            end if;
            ll_keys := ll_keys||l_fk(k)||',';
          end loop;
          l_rollup_full_group_by_sql:=l_rollup_full_group_by_sql||' CUBE(';
          for k in 1..ll_number_fk_cube loop
            l_rollup_full_group_by_sql:=l_rollup_full_group_by_sql||ll_fk_cube(k)||',';
          end loop;
          l_rollup_full_group_by_sql:=substr(l_rollup_full_group_by_sql,1,length(l_rollup_full_group_by_sql)-1)||') ';
          --having...
          l_rollup_full_group_by_sql:=l_rollup_full_group_by_sql||' having (';
          for k in 1..ll_number_fk_cube loop
            l_rollup_full_group_by_sql:=l_rollup_full_group_by_sql||' grouping('||ll_fk_cube(k)||')=1 or';
          end loop;
          l_rollup_full_group_by_sql:=substr(l_rollup_full_group_by_sql,1,length(l_rollup_full_group_by_sql)-2)||
          ')';
        end;
        ----------------------------------------
        --second the measures------------------------
        if g_debug then
          write_to_log_file_n('going to process the measures');
        end if;
        declare
          ll_looked_at BSC_IM_UTILS.varchar_tabletype;
          ll_number_looked_at number;
        begin
          if ll_use_union_for_rollup then
            for j in 1..ll_union_number loop
              ll_number_looked_at:=0;
              for k in 1..l_number_cols loop
                if l_col_type(k)='A' then
                  for m in 1..l_number_parameters loop
                    if lower(l_parameter3(m))=lower(l_cols(k)) then
                      if BSC_IM_UTILS.in_array(ll_looked_at,ll_number_looked_at,l_parameter3(m))=false then
                        l_rollup_select_sql(j):=l_rollup_select_sql(j)||
                        l_parameter5(m)||' '||l_parameter3(m)||',';
                        l_rollup_select_sql(j):=l_rollup_select_sql(j)||'count('||l_parameter3(m)||') '||
                        substr('cnt_'||l_parameter3(m),1,30)||',';
                        ll_number_looked_at:=ll_number_looked_at+1;
                        ll_looked_at(ll_number_looked_at):=l_parameter3(m);
                      end if;
                      exit;
                    end if;
                  end loop;--for m in 1..l_number_parameters loop
                end if;
              end loop;--for k in 1..l_number_cols loop
            end loop;--for j in 1..ll_union_number loop
          end if;
          --the full refresh sql------------------------
          ----------------------------------------------
          if g_debug then
            write_to_log_file_n('going to process rollup measures');
          end if;
          ll_number_looked_at:=0;
          for k in 1..l_number_cols loop
            if l_col_type(k)='A' then
              for m in 1..l_number_parameters loop
                if lower(l_parameter3(m))=lower(l_cols(k)) then
                  if BSC_IM_UTILS.in_array(ll_looked_at,ll_number_looked_at,l_parameter3(m))=false then
                    l_rollup_full_select_sql:=l_rollup_full_select_sql||
                    l_parameter5(m)||' '||l_parameter3(m)||',';
                    ll_number_looked_at:=ll_number_looked_at+1;
                    ll_looked_at(ll_number_looked_at):=l_parameter3(m);
                  end if;
                  exit;
                end if;
              end loop;--for m in 1..l_number_parameters loop
            end if;
          end loop;--for k in 1..l_number_cols loop
        end;
        ----------------------------------------------------
        if ll_use_union_for_rollup then
          for j in 1..ll_union_number loop
            l_rollup_select_sql(j):=l_rollup_select_sql(j)||' count(*) count_all,'||j||' u_marker,';
            l_rollup_select_sql(j):=l_rollup_select_sql(j)||'decode(periodicity_id,';
            for k in 1..l_number_source_tables loop
              l_rollup_select_sql(j):=l_rollup_select_sql(j)||l_table_periodicity(k)||','||
              l_table_period_type_id(k)||',';
            end loop;
            l_rollup_select_sql(j):=l_rollup_select_sql(j)||'null) period_type_id';
            --'decode(periodicity_id,9,1,7,16,5,32,4,2048,3,64,2,4096,1,128,null) period_type_id';
            l_rollup_group_by_sql(j):=substr(l_rollup_group_by_sql(j),1,length(l_rollup_group_by_sql(j))-1);
          end loop;
        end if;
        l_rollup_full_select_sql:=l_rollup_full_select_sql||'decode(periodicity_id,';
        for j in 1..l_number_source_tables loop
          l_rollup_full_select_sql:=l_rollup_full_select_sql||l_table_periodicity(j)||','||
          l_table_period_type_id(j)||',';
        end loop;
        l_rollup_full_select_sql:=l_rollup_full_select_sql||'null) period_type_id';
        --l_rollup_full_select_sql:=l_rollup_full_select_sql||
        --'decode(periodicity_id,9,1,7,16,5,32,4,2048,3,64,2,4096,1,128,null) period_type_id';
        ---------------------------------------------
        if g_debug then
          write_to_log_file_n('The rollup select from where and group by');
          if ll_use_union_for_rollup then
            for j in 1..ll_union_number loop
              write_to_log_file('Union '||j);
              write_to_log_file('select - '||l_rollup_select_sql(j));
              write_to_log_file('from - '||l_rollup_from_sql(j));
              write_to_log_file('where - '||l_rollup_where_sql(j));
              write_to_log_file('group by - '||l_rollup_group_by_sql(j));
            end loop;
          end if;
          write_to_log_file_n('The FULL rollup select from where and group by');
          write_to_log_file('FULL select - '||l_rollup_full_select_sql);
          write_to_log_file('FULL from - '||l_rollup_full_from_sql);
          write_to_log_file('FULL where - '||l_rollup_full_where_sql);
          write_to_log_file('FULL group by - '||l_rollup_full_group_by_sql);
          write_to_log_file('keys= '||ll_keys);
        end if;
        ------------------------------------------------------------
        ---------create INT metadata entry for rollups
        ------------------------------------------------------------
        if (ll_keys_stmt like '%,') then
          ll_keys_stmt := substr(ll_keys_stmt, 1, length(ll_keys_stmt)-1);
        end if;
        if ll_use_union_for_rollup then
          --only if union all is allowed for zero code mv do we write this to the int metadata
          --if there are too many keys will rollup, then we want to go over cube(...)
          for j in 1..ll_union_number loop
            if BSC_IM_INT_MD.create_mapping_detail(p_zero_code_map_name,'BSC',l_rollup_select_sql(j),'SELECT',null)=false then
              return false;
            end if;
            if BSC_IM_INT_MD.create_mapping_detail(p_zero_code_map_name,'BSC',l_rollup_from_sql(j),'FROM',null)=false then
              return false;
            end if;
            if BSC_IM_INT_MD.create_mapping_detail(p_zero_code_map_name,'BSC',l_rollup_where_sql(j),'WHERE',null)=false then
              return false;
            end if;
            if BSC_IM_INT_MD.create_mapping_detail(p_zero_code_map_name,'BSC',l_rollup_group_by_sql(j),'GROUP BY',null)=false then
              return false;
            end if;
          end loop;
          if BSC_IM_INT_MD.create_mapping_detail(p_zero_code_map_name,'BSC',ll_keys_stmt,'KEYS',null)=false then
            return false;
          end if;
        else
          if BSC_IM_INT_MD.create_mapping_detail(p_zero_code_map_name,'BSC',l_rollup_full_select_sql,
            'SELECT',null)=false then
            return false;
          end if;
          if BSC_IM_INT_MD.create_mapping_detail(p_zero_code_map_name,'BSC',l_rollup_full_from_sql,
            'FROM',null)=false then
            return false;
          end if;
          if BSC_IM_INT_MD.create_mapping_detail(p_zero_code_map_name,'BSC',l_rollup_full_where_sql,
            'WHERE',null)=false then
            return false;
          end if;
          if BSC_IM_INT_MD.create_mapping_detail(p_zero_code_map_name,'BSC',l_rollup_full_group_by_sql,
            'GROUP BY',null)=false then
            return false;
          end if;
          if BSC_IM_INT_MD.create_mapping_detail(p_zero_code_map_name,'BSC',ll_keys_stmt,'KEYS',null)=false then
            return false;
          end if;
        end if;
        if BSC_IM_INT_MD.create_mapping_detail(l_full_zero_code_map_name,'BSC',l_rollup_full_select_sql,
          'SELECT',null)=false then
          return false;
        end if;
        if BSC_IM_INT_MD.create_mapping_detail(l_full_zero_code_map_name,'BSC',l_rollup_full_from_sql,
          'FROM',null)=false then
          return false;
        end if;
        if BSC_IM_INT_MD.create_mapping_detail(l_full_zero_code_map_name,'BSC',l_rollup_full_where_sql,
          'WHERE',null)=false then
          return false;
        end if;
        if BSC_IM_INT_MD.create_mapping_detail(l_full_zero_code_map_name,'BSC',l_rollup_full_group_by_sql,
          'GROUP BY',null)=false then
          return false;
        end if;
        if BSC_IM_INT_MD.create_mapping_detail(l_full_zero_code_map_name,'BSC',ll_keys_stmt,'KEYS',null)=false then
          return false;
        end if;

      end if;--if ll_number_rollup_fk>0 then
    end;
    --create INT Metadata for mapping
    --for zero code mv
    declare
    begin
      if g_debug then
        write_to_log_file_n('In Create_kpi_map_info--Before Create_object ZEro Code MVs'||' '||get_time);
        write_to_log_file_n('ll_number_rollup_fk='||ll_number_rollup_fk);
      end if;
      if ll_number_rollup_fk>0 and ll_zero_separate then
        if BSC_IM_INT_MD.create_object(
          p_zero_code_mv_name,
          'ZERO CODE MV',
          'BSC',
          p_indicator,
          null,
          'ZERO CODE MV')=false then
          return false;
        end if;
        if BSC_IM_INT_MD.create_mapping(p_zero_code_map_name,'BSC','ZERO CODE MV',p_zero_code_mv_name,
          'FAST REFRESH')=false then
          return false;
        end if;
        if BSC_IM_INT_MD.create_mapping(l_full_zero_code_map_name,'BSC','ZERO CODE MV',p_zero_code_mv_name,
          'FULL REFRESH')=false then
          return false;
        end if;
        --create the fk, this is reqd for index creation
        for i in 1..l_number_fk loop
          if BSC_IM_INT_MD.create_fk(
            l_fk(i),
            'ZERO CODE MV',
            p_zero_code_mv_name,
            null,
            null,
            null,
            'BSC',
            'ZERO CODE MV')=false then
            return false;
          end if;
        end loop;
        --create the mv dependency. this is for snapshot log creation
        if BSC_IM_INT_MD.create_object(
          p_mv_name,
          'ZERO CODE MV',
          'BSC',
          p_zero_code_mv_name,
          null,
          'MV DEPENDENCY')=false then
          return false;
        end if;
        if g_debug then
	      write_to_log_file_n('In Create_kpi_map_info--Before Create_object ZEro Code MVs'||' '||get_time);
        end if;
      end if;
    end;
    -----------------------------------------------------
    --create the fk and columns for dim levels. this info will be used for snapshot log creation.
    --we need snapshot logs also on the dim level tables for inc refresh
    --l_number_dim_level_tables
    declare
      ll_level_columns BSC_IM_UTILS.varchar_tabletype;
      ll_level_column_type BSC_IM_UTILS.varchar_tabletype;
      ll_number_level_columns number;
    begin
      for i in 1..l_number_dim_level_tables loop
        if get_dim_level_cols(
          l_dim_level_tables(i),
          ll_level_columns,
          ll_level_column_type,
          ll_number_level_columns)=false then
          return false;
        end if;
        if ll_number_level_columns>0 then
          if BSC_IM_INT_MD.create_fk('CODE','LEVEL TABLE',l_dim_level_tables(i),null,null,null,'BSC',
            'LEVEL TABLE')=false then
            return false;
          end if;
          --3613094
          if bsc_im_utils.is_column_in_object(l_dim_level_tables(i),'LANGUAGE') then
            if BSC_IM_INT_MD.create_fk('LANGUAGE','LEVEL TABLE',l_dim_level_tables(i),null,null,null,'BSC',
              'LEVEL TABLE')=false then
              return false;
            end if;
          end if;
          for j in 1..ll_number_level_columns loop
            if upper(ll_level_columns(j))<>'CODE' and upper(ll_level_columns(j))<>'LANGUAGE' then
              if BSC_IM_INT_MD.create_column(ll_level_columns(j),'A',null,'BSC',null,null,null,l_dim_level_tables(i),
                null)=false then
                return false;
              end if;
            end if;
          end loop;
        end if;
      end loop;
      --if there is filter, make an entry also for the filter table
      if l_number_filter>0 then
        if BSC_IM_INT_MD.create_fk('SOURCE_TYPE','LEVEL TABLE','BSC_SYS_FILTERS',null,null,null,'BSC',
          'LEVEL TABLE')=false then
          return false;
        end if;
        if BSC_IM_INT_MD.create_fk('SOURCE_CODE','LEVEL TABLE','BSC_SYS_FILTERS',null,null,null,'BSC',
          'LEVEL TABLE')=false then
          return false;
        end if;
        if BSC_IM_INT_MD.create_fk('DIM_LEVEL_ID','LEVEL TABLE','BSC_SYS_FILTERS',null,null,null,'BSC',
          'LEVEL TABLE')=false then
          return false;
        end if;
        if BSC_IM_INT_MD.create_fk('DIM_LEVEL_VALUE','LEVEL TABLE','BSC_SYS_FILTERS',null,null,null,'BSC',
          'LEVEL TABLE')=false then
          return false;
        end if;
        if BSC_IM_UTILS.in_array(l_dim_level_tables,l_number_dim_level_tables,'BSC_SYS_FILTERS')=false then
          l_number_dim_level_tables:=l_number_dim_level_tables+1;
          l_dim_level_tables(l_number_dim_level_tables):='BSC_SYS_FILTERS';
        end if;
      end if;
    end;
    ----------------------------------------------------
    declare
      ll_property varchar2(10000);
    begin
      for i in 1..l_number_dim_level_tables loop
        l_dim_level_stmt:=l_dim_level_stmt||l_dim_level_tables(i)||'+';
      end loop;
      if g_debug then
        write_to_log_file_n('dim level stmt '||l_dim_level_stmt);
      end if;
      if l_dim_level_stmt='DIM LEVELS=' then --these are used to create snp logs on the dim levels
        l_dim_level_stmt:=null;
      else
        l_dim_level_stmt:=substr(l_dim_level_stmt,1,length(l_dim_level_stmt)-1);
      end if;
      if l_base_table_stmt is not null and l_dim_level_stmt is not null then
        ll_property:=l_base_table_stmt||','||l_dim_level_stmt;
      else
        ll_property:=l_base_table_stmt||l_dim_level_stmt;
      end if;
      if BSC_IM_INT_MD.create_mapping(p_map_name,'BSC','SUMMARY MV',p_mv_name,ll_property)=false then
        return false;
      end if;
    end;
    -----------------------------------------------------
  end;
  -------------------------------------------------------
  if g_debug then
         write_to_log_file_n('Returning from Create_kpi_map_info'||' '||get_time);
  end if;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in create_kpi_map_info '||sqlerrm);
  return false;
End;

--used for T table. will go recursively all the way back to the B table and generate the sql.
function get_table_sql(
p_table varchar2,
p_table_sql out nocopy varchar2,
p_b_tables in out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_b_tables in out nocopy number,
p_dim_level_tables in out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_dim_level_tables in out nocopy number
)return boolean is
-----------------------------------------------------------------
l_tables BSC_IM_UTILS.varchar_tabletype;
l_source_tables BSC_IM_UTILS.varchar_tabletype;
l_relation_type BSC_IM_UTILS.varchar_tabletype;
l_source_sql BSC_IM_UTILS.varchar_tabletype;
l_number_source_tables number;
-----------T table columns--------------------------------------
l_col_table BSC_IM_UTILS.varchar_tabletype;
l_cols BSC_IM_UTILS.varchar_tabletype;
l_col_type BSC_IM_UTILS.varchar_tabletype;
l_col_formula BSC_IM_UTILS.varchar_tabletype;
l_col_source BSC_IM_UTILS.varchar_tabletype;
l_number_cols number;
-----------------------------------------------------------------
l_fk BSC_IM_UTILS.varchar_tabletype;
l_fk_source BSC_IM_UTILS.varchar_tabletype;
l_number_fk number;
l_measures BSC_IM_UTILS.varchar_tabletype;
l_number_measures number;
-----------------------------------------------------------------
l_column_merge_sql varchar2(32000);
l_column_merge_group BSC_IM_UTILS.varchar_tabletype;
l_column_merge_group_sql BSC_IM_UTILS.varchar_tabletype;
l_number_column_merge_group number;
l_merge_sql varchar2(32000);
-----------------------------------------------------------------
l_table_measures BSC_IM_UTILS.varchar_tabletype;
l_number_table_measures number;
l_index number;
-----------------------------------------------------------------
l_from_sql varchar2(32000);
l_where_sql varchar2(32000);
l_group_by_sql varchar2(32000);
-----------------------------------------------------------------
l_temp varchar2(4000);
l_temp_alias varchar2(200);
l_dim_src_object varchar2(20000);
l_dim_src_object_type varchar2(100);
l_rec_dim boolean;
l_rec_dim_key varchar2(100);
-----------------------------------------------------------------
Begin
  if g_debug then
    write_to_log_file_n('In get_table_sql '||p_table);
  end if;
  if get_table_fks(p_table,l_fk,l_number_fk)=false then
    return false;
  end if;
  if get_table_measures(p_table,l_measures,l_number_measures)=false then
    return false;
  end if;
  l_number_source_tables:=null;
  if get_table_relations(
    p_table,
    l_tables,
    l_source_tables,
    l_relation_type,
    l_number_source_tables)=false then
    return false;
  end if;
  for i in 1..l_number_source_tables loop
    if BSC_IM_UTILS.is_like(l_source_tables(i),'BSC_T_') then --this is T table
      --construct the sql. recursive call
      if get_table_sql(l_source_tables(i),l_source_sql(i),p_b_tables,p_number_b_tables,
        p_dim_level_tables,p_number_dim_level_tables)=false then
        return false;
      end if;
    else
      l_source_sql(i):=null;
    end if;
  end loop;
  for i in 1..l_number_source_tables loop
    if BSC_IM_UTILS.is_like(l_source_tables(i),'BSC_B_') and BSC_IM_UTILS.in_array(p_b_tables,p_number_b_tables,
      l_source_tables(i))=false then
      p_number_b_tables:=p_number_b_tables+1;
      p_b_tables(p_number_b_tables):=l_source_tables(i);
    end if;
  end loop;
  --get the column information
  l_number_cols:=null;
  if get_table_cols(
    p_table,
    l_col_table,
    l_cols,
    l_col_type,
    l_col_source,
    l_col_formula,
    l_number_cols)=false then
    return false;
  end if;
  /*P1 3649545
  when T table rolls up, we cannot use l_fk() in l_column_merge_sql. l_fk is the fk
  of the higher level. we need to get the source of l_fk and use it
  */
  for i in 1..l_number_fk loop
    l_index:=BSC_IM_UTILS.get_index(l_cols,l_number_cols,l_fk(i));
    if l_index>0 then
      l_fk_source(i):=l_col_source(l_index);
    else
      l_fk_source(i):=l_fk(i);
    end if;
  end loop;
  if g_debug then
    write_to_log_file_n('The fk source');
    for i in 1..l_number_fk loop
      write_to_log_file(l_fk(i)||' '||l_fk_source(i));
    end loop;
  end if;
  ----------------------
  l_column_merge_sql:=null;
  l_merge_sql:=null;
  l_number_column_merge_group:=0;
  l_from_sql:=null;
  l_where_sql:=null;
  l_group_by_sql:=null;
  --for T tables, there is only column merge!!
  if l_number_source_tables>1 then
    for i in 1..l_number_source_tables loop
      l_number_column_merge_group:=l_number_column_merge_group+1;
      l_column_merge_group(l_number_column_merge_group):=l_source_tables(i);
      l_column_merge_group_sql(l_number_column_merge_group):=l_source_sql(i);
    end loop;
    if g_debug then
      write_to_log_file_n('The column merge tables');
      for i in 1..l_number_column_merge_group loop
        write_to_log_file(l_column_merge_group(i)||' '||l_column_merge_group_sql(i));
      end loop;
    end if;
    if l_number_column_merge_group>0 then
      l_column_merge_sql:='select ';
      for i in 1..l_number_fk loop
        --l_column_merge_sql:=l_column_merge_sql||'prim.'||l_fk_source(i)||',';
        l_column_merge_sql:=l_column_merge_sql||'prim.'||l_fk(i)||',';
      end loop;
      for i in 1..l_number_measures loop
        l_column_merge_sql:=l_column_merge_sql||l_measures(i)||',';
      end loop;
      l_column_merge_sql:=substr(l_column_merge_sql,1,length(l_column_merge_sql)-1)||' from (';
      for i in 1..l_number_column_merge_group loop
        l_column_merge_sql:=l_column_merge_sql||'select ';
        for j in 1..l_number_fk loop
          --l_column_merge_sql:=l_column_merge_sql||l_fk_source(j)||',';
          l_column_merge_sql:=l_column_merge_sql||l_fk_source(j)||' '||l_fk(j)||',';
        end loop;
        l_column_merge_sql:=substr(l_column_merge_sql,1,length(l_column_merge_sql)-1);
        if l_column_merge_group_sql(i) is null then
          l_column_merge_sql:=l_column_merge_sql||' from '||l_column_merge_group(i)||' union ';
        else
          l_column_merge_sql:=l_column_merge_sql||' from ('||
          l_column_merge_group_sql(i)||') '||l_column_merge_group(i)||' union ';
        end if;
      end loop;
      l_column_merge_sql:=substr(l_column_merge_sql,1,length(l_column_merge_sql)-6);
      l_column_merge_sql:=l_column_merge_sql||') prim ';
      for i in 1..l_number_column_merge_group loop
        if l_column_merge_group_sql(i) is null then
          l_column_merge_sql:=l_column_merge_sql||','||l_column_merge_group(i);
        else
          l_column_merge_sql:=l_column_merge_sql||',('||l_column_merge_group_sql(i)||') '||
          l_column_merge_group(i);
        end if;
      end loop;
      l_column_merge_sql:=l_column_merge_sql||' where ';
      for i in 1..l_number_column_merge_group loop
        for j in 1..l_number_fk loop
          --l_column_merge_sql:=l_column_merge_sql||'prim.'||l_fk_source(j)||'='||l_column_merge_group(i)||'.'||
          --l_fk_source(j)||'(+) and ';
          l_column_merge_sql:=l_column_merge_sql||'prim.'||l_fk(j)||'='||l_column_merge_group(i)||'.'||
          l_fk_source(j)||'(+) and ';
        end loop;
      end loop;
      l_column_merge_sql:=substr(l_column_merge_sql,1,length(l_column_merge_sql)-4);
    end if;
    if g_debug then
      write_to_log_file_n('Column merge sql 2 '||l_column_merge_sql);
    end if;
    l_merge_sql:=l_column_merge_sql;
    if g_debug then
     write_to_log_file_n('The merge sql '||l_merge_sql);
    end if;
    l_from_sql:=' from ('||l_merge_sql||') prim_table';
  else --if l_number_source_tables>1 then
    if l_source_sql(l_number_source_tables) is null then
      l_from_sql:=' from ';
      if (instr(l_source_tables(l_number_source_tables), 'BSC_B_')=1) then
        -- Bug 5073442
        -- get prj union clause will return (B union B_PRJ) aliased as B
        -- for T tables, we should remove this alias as we're going to use the prim_table alias
        l_from_sql:= l_from_sql||get_prj_union_clause(l_source_tables(l_number_source_tables), false);
      else
        l_from_sql := l_from_sql||bsc_im_utils.get_table_owner(l_source_tables(l_number_source_tables))
                                ||'.'||l_source_tables(l_number_source_tables);
      end if;
      l_from_sql := l_from_sql||' prim_table';
    else
      l_from_sql:=' from ('||l_source_sql(l_number_source_tables)||') prim_table';
    end if;
  end if;--if l_number_source_tables>1 then
  p_table_sql:='select ';
  l_where_sql:=' where 1=1';
  for i in 1..l_number_fk loop
    if l_fk_source(i)<>l_fk(i) then --there is a rollup
      --search for get_level_for_pk. you can see an explanation for why we need l_dim_src_object
      --l_dim_src_object is the name of the materialized dim table
      if get_level_for_pk(l_fk_source(i),l_temp,l_dim_src_object,l_dim_src_object_type,
        l_rec_dim,l_rec_dim_key)=false then
        return false;
      end if;
      l_temp_alias:=substr(l_temp,1,30-length(i))||i;
      p_table_sql:=p_table_sql||l_temp_alias||'.'||l_fk(i)||',';
      if l_dim_src_object_type='inline' then
        l_from_sql:=l_from_sql||','||l_dim_src_object||' '||l_temp_alias;
      else
        l_from_sql:=l_from_sql||','||bsc_im_utils.get_table_owner(l_dim_src_object)||'.'||l_dim_src_object||' '||l_temp_alias;
      end if;
      if l_number_source_tables=1 then
        l_where_sql:=l_where_sql||' and '||l_temp_alias||'.CODE=prim_table.'||l_fk_source(i);
      else
        l_where_sql:=l_where_sql||' and '||l_temp_alias||'.CODE=prim_table.'||l_fk(i);
      end if;
      --bug 3344807
      --when the dimension has multiple languages, we must filter by language
      --3613094
      if bsc_im_utils.is_column_in_object(l_dim_src_object,'LANGUAGE') then
        l_where_sql:=l_where_sql||' and '||l_temp_alias||'.LANGUAGE='''||BSC_IM_UTILS.get_lang||''' ';
      end if;
      l_group_by_sql:=l_group_by_sql||l_temp_alias||'.'||l_fk(i)||',';--l_fk(i)=l_cols(l_index)
      if l_dim_src_object_type='none' then
        if BSC_IM_UTILS.in_array(p_dim_level_tables,p_number_dim_level_tables,l_dim_src_object)=false then
          p_number_dim_level_tables:=p_number_dim_level_tables+1;
          p_dim_level_tables(p_number_dim_level_tables):=l_dim_src_object;
        end if;
      end if;
    else
      p_table_sql:=p_table_sql||'prim_table.'||l_fk(i)||',';
      l_group_by_sql:=l_group_by_sql||'prim_table.'||l_fk(i)||',';
    end if;
  end loop;--for i in 1..l_number_fk loop
  l_group_by_sql:=substr(l_group_by_sql,1,length(l_group_by_sql)-1);
  for i in 1..l_number_measures loop
    l_index:=0;
    l_index:=BSC_IM_UTILS.get_index(l_cols,l_number_cols,l_measures(i));
    if l_index>0 then
      p_table_sql:=p_table_sql||l_col_formula(l_index)||' '||l_measures(i)||',';
    end if;
  end loop;
  p_table_sql:=substr(p_table_sql,1,length(p_table_sql)-1);
  -------------------------------------------------------
  --correct stmts if reqd
  if l_where_sql=' where 1=1' then
    l_where_sql:=null;
  end if;
  -------------------------------------------------------
  if g_debug then
    write_to_log_file_n('p_table_sql='||p_table_sql);
    write_to_log_file_n('l_from_sql='||l_from_sql);
    write_to_log_file_n('l_where_sql='||l_where_sql);
    write_to_log_file_n('l_group_by_sql='||l_group_by_sql);
  end if;
  p_table_sql:=p_table_sql||l_from_sql||l_where_sql||' group by '||l_group_by_sql;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in get_table_sql '||sqlerrm);
  return false;
End;

function get_filter_stmt(
p_indicator number,
p_table varchar2,
p_filter_from out nocopy BSC_IM_UTILS.varchar_tabletype,
p_filter_where out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_filter out nocopy number,
p_dim_level_tables in out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_dim_level_tables in out nocopy number,
p_filter_first_level out nocopy BSC_IM_UTILS.varchar_tabletype,
p_filter_first_level_alias out nocopy BSC_IM_UTILS.varchar_tabletype, --this will be the alias L1
p_filter_first_level_fk out nocopy BSC_IM_UTILS.varchar_tabletype,
p_num_filter_first_level out nocopy number
) return boolean is
--------------------------
l_stmt varchar2(5000);
--------------------------
l_dim_set_id number;
l_indicator_id number;
l_pk_col BSC_IM_UTILS.varchar_tabletype;
l_level_view BSC_IM_UTILS.varchar_tabletype;
l_number_pk_col number;
l_view_owner varchar2(200);
--------------------------
cursor c1(p_indicator number,p_dim_set_id number,p_status number,p_table_name varchar2,p_column_type varchar2) is
SELECT d.level_pk_col, d.level_view_name FROM bsc_kpi_dim_levels_b d, bsc_db_tables_cols c
WHERE d.indicator = p_indicator AND d.dim_set_id = p_dim_set_id AND d.status = p_status AND d.level_view_name <> (
SELECT level_view_name FROM bsc_sys_dim_levels_b s WHERE d.level_pk_col = s.level_pk_col)
AND c.table_name = p_table_name AND c.column_name = d.level_pk_col AND
c.column_type = p_column_type;

cursor c2(p_indicator number,p_set_id number) is
select level_table_name,level_pk_col,parent_level_rel from bsc_kpi_dim_levels_b
where indicator=p_indicator and dim_set_id=p_set_id;
--------------------------
Begin
  if g_debug then
    write_to_log_file_n('In get_filter_stmt '||p_table);
  end if;
  p_number_filter:=0;
  p_num_filter_first_level:=0;
  --logic taken from BSC_UPDATE_CALC.apply_filters(x_table_name); 115.21 2003/03/25
  begin
    SELECT indicator, dim_set_id into l_indicator_id,l_dim_set_id
    FROM bsc_kpi_data_tables_v WHERE (table_name = p_table OR
    table_name = (SELECT DISTINCT table_name FROM bsc_db_calculations WHERE
    parameter1 = p_table AND calculation_type = 5)) and rownum=1;
  exception when NO_DATA_FOUND then
    l_indicator_id:=null;
    l_dim_set_id:=null;
  end;
  if g_debug then
    write_to_log_file('Result '||l_indicator_id||' '||l_dim_set_id);
  end if;
  if l_indicator_id is not null and l_dim_set_id is not null then
    if g_debug then
      l_stmt:='SELECT d.level_pk_col, d.level_view_name FROM bsc_kpi_dim_levels_b d, bsc_db_tables_cols c '||
      'WHERE d.indicator = :1 AND d.dim_set_id = :2 AND d.status = :3 AND d.level_view_name <> ( '||
      'SELECT level_view_name FROM bsc_sys_dim_levels_b s WHERE d.level_pk_col = s.level_pk_col) '||
      'AND c.table_name = :4 AND c.column_name = d.level_pk_col AND '||
      'c.column_type = :5';
      write_to_log_file_n(l_stmt||' '||l_indicator_id||' '||l_dim_set_id||' 2 '||p_table||' P');
    end if;
    open c1(l_indicator_id,l_dim_set_id,2,p_table,'P');
    l_number_pk_col:=1;
    loop
      fetch c1 into l_pk_col(l_number_pk_col),l_level_view(l_number_pk_col);
      exit when c1%notfound;
      l_number_pk_col:=l_number_pk_col+1;
    end loop;
    close c1;
    l_number_pk_col:=l_number_pk_col-1;
    if g_debug then
      write_to_log_file('Results');
      for i in 1..l_number_pk_col loop
        write_to_log_file(l_pk_col(i)||' '||l_level_view(i));
      end loop;
    end if;
    if l_number_pk_col>0 then
      declare
        ll_level_table_name BSC_IM_UTILS.varchar_tabletype;
        ll_level_pk_col BSC_IM_UTILS.varchar_tabletype;
        ll_parent_level_pk_col BSC_IM_UTILS.varchar_tabletype;
        ll_number_level number;
        ---------------------
        ll_index number;
        ---------------------
        ll_pk_col varchar2(200);
        ll_from_stmt varchar2(20000);
        ll_where_stmt varchar2(20000);
        ll_count number;
        ll_level_count number;
        ---------------------
      begin
        if g_debug then
          l_stmt:='select level_table_name,level_pk_col,parent_level_rel'||
          ' from bsc_kpi_dim_levels_b where indicator=:1 and dim_set_id=:2';
          write_to_log_file_n(l_stmt||' '||l_indicator_id||' '||l_dim_set_id);
        end if;
        ll_number_level:=1;
        open c2(l_indicator_id,l_dim_set_id);
        loop
          fetch c2 into ll_level_table_name(ll_number_level),ll_level_pk_col(ll_number_level),
          ll_parent_level_pk_col(ll_number_level);
          exit when c2%notfound;
          ll_number_level:=ll_number_level+1;
        end loop;
        close c2;
        ll_number_level:=ll_number_level-1;
        if g_debug then
          write_to_log_file_n('Results');
          for i in 1..ll_number_level loop
            write_to_log_file(ll_level_table_name(i)||' '||ll_level_pk_col(i)||' '||
            ll_parent_level_pk_col(i));
          end loop;
        end if;
        ll_from_stmt:=null;
        ll_where_stmt:=null;
        g_rec_count:=0;
        ll_count:=0;
        ll_level_count:=0;
        for i in 1..l_number_pk_col loop
          ll_pk_col:=l_pk_col(i);
          if ll_pk_col is not null then
            ll_index:=0;
            ll_index:=BSC_IM_UTILS.get_index(ll_level_pk_col,ll_number_level,ll_pk_col);
            if ll_index>0 then
              p_num_filter_first_level:=p_num_filter_first_level+1;
              ll_level_count:=ll_level_count+1;
              p_filter_first_level(p_num_filter_first_level):=ll_level_table_name(ll_index);
              p_filter_first_level_alias(p_num_filter_first_level):='L'||ll_level_count;
              p_filter_first_level_fk(p_num_filter_first_level):=ll_pk_col;
              if get_filter_stmt_rec(p_indicator, ll_level_table_name(ll_index),ll_pk_col,ll_count,ll_level_count,
                ll_from_stmt,ll_where_stmt, l_pk_col)=false then
                return false;
              end if;
            end if;
          end if;
        end loop;--for i in 1..l_number_pk_col loop
        ll_from_stmt:=substr(ll_from_stmt,1,length(ll_from_stmt)-1);
        if g_debug then
          write_to_log_file_n('The filter from '||ll_from_stmt);
          write_to_log_file_n('The filter where '||ll_where_stmt);
        end if;
        p_number_filter:=p_number_filter+1;
        p_filter_from(p_number_filter):=ll_from_stmt;
        p_filter_where(p_number_filter):=ll_where_stmt;
      end;
    end if;--if l_number_pk_col>0 then
  end if;--if l_indicator_id is not null and l_dim_set_id is not null then
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in get_filter_stmt '||sqlerrm);
  return false;
End;

--bug 3394315
function get_filter_stmt_rec(
p_indicator number,
p_child_level varchar,
p_child_level_pk varchar,
p_count in out nocopy number,
p_level_count in out nocopy number,
p_from_stmt in out nocopy varchar2,
p_where_stmt in out nocopy varchar2,
--added by arun
p_pk_cols BSC_IM_UTILS.varchar_tabletype
) return boolean is
--------------------------------
l_level_fk BSC_IM_UTILS.varchar_tabletype;
l_parent_level BSC_IM_UTILS.varchar_tabletype;
l_num_parent_levels number;
--------------------------------
l_source_type number;
l_source_code number;
l_dim_level_id number;
--------------------------------
l_res number;
l_parent_level_count number;
--------------------------------
Begin
  g_rec_count:=g_rec_count+1;
  if g_debug then
    write_to_log_file_n('In get_filter_stmt_rec '||p_child_level||' '||p_child_level_pk||' '||g_rec_count);
  end if;
  if g_rec_count>10000 then --some issue, prevent infinite loop
    return false;
  end if;
  l_res:=get_filter_view_params(p_indicator, p_child_level,l_source_type,l_source_code,l_dim_level_id);
  if l_res=1 then
    --there is a filter at this level. use it
    p_count:=p_count+1;
    p_from_stmt:=p_from_stmt||bsc_im_utils.get_table_owner(p_child_level)||'.'||p_child_level||' L'||p_level_count||
    ','||bsc_im_utils.get_table_owner('BSC_SYS_FILTERS')||'.bsc_sys_filters f'||p_count||',';
    p_where_stmt:=p_where_stmt||' and f'||p_count||'.source_code='||l_source_code||
    ' and f'||p_count||'.source_type='||l_source_type||
    ' and f'||p_count||'.dim_level_id='||l_dim_level_id||
    ' and f'||p_count||'.dim_level_value=L'||p_level_count||'.code ';
    --bug 3404374
    --' and '||p_child_level||'.language='''||BSC_IM_UTILS.get_lang||'''';
  else
    if get_parent_level(p_child_level,l_level_fk,l_parent_level,l_num_parent_levels)=false then
      return false;
    end if;
    if l_num_parent_levels>0 then
      for i in 1..l_num_parent_levels loop
        l_res:=get_filter_view_params(p_indicator, l_parent_level(i),l_source_type,l_source_code,l_dim_level_id);
        if l_source_type is not null and
           bsc_im_utils.get_index(p_pk_cols, p_pk_cols.count, l_parent_level(i)) <1 then
          --there is a filter view on this level
          l_parent_level_count:=p_level_count+1;
          p_from_stmt:=p_from_stmt||bsc_im_utils.get_table_owner(p_child_level)||'.'||p_child_level||
          ' L'||p_level_count||',';
          p_where_stmt:=p_where_stmt||' and L'||p_level_count||'.'||l_level_fk(i)||'=L'||l_parent_level_count||
          '.code';
          --3613094
          if bsc_im_utils.is_column_in_object(l_parent_level(i),'LANGUAGE') then
            p_where_stmt:=p_where_stmt||' and L'||l_parent_level_count||'.language='''||BSC_IM_UTILS.get_lang||'''';
          end if;
          p_level_count:=p_level_count+1;
          if get_filter_stmt_rec(p_indicator, l_parent_level(i),l_level_fk(i),p_count,p_level_count,
            p_from_stmt,p_where_stmt, p_pk_cols)=false then
            return false;
          end if;
        end if;
      end loop;
    end if;
  end if;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in get_filter_stmt_rec '||sqlerrm);
  return false;
End;

function get_filter_view_params(
p_indicator number,
p_level varchar2,
p_source_type out nocopy number,
p_source_code out nocopy number,
p_dim_level_id out nocopy number
) return number is
----
cursor c3(p_ind number, p_table_name varchar2) is
select source_type,source_code,dim_level_id from bsc_sys_filters_views where
level_table_name=p_table_name
and source_code in (select tab_id from bsc_tab_indicators where indicator=p_ind);
----
cursor c4(p_type number,p_code number,p_id number) is
select 1 from bsc_sys_filters where source_type=p_type and source_code=p_code
and dim_level_id=p_id and rownum=1;
----
l_res number;
l_stmt varchar2(8000);
--------------------------------
Begin
  if g_debug then
    l_stmt:='select source_type,source_code,dim_level_id from bsc_sys_filters_views where '||
    'level_table_name=:1 and source_code in (select tab_id from bsc_tab_indicators where indicator=:2';
    write_to_log_file_n(l_stmt||' '||p_level||' '||p_indicator);
  end if;
  open c3(p_indicator, p_level);
  fetch c3 into p_source_type,p_source_code,p_dim_level_id;
  close c3;
  if g_debug then
    write_to_log_file(p_source_type||' '||p_source_code||' '||p_dim_level_id);
  end if;
  if g_debug then
    l_stmt:='select 1 from bsc_sys_filters where source_type=:1 and source_code=:2 '||
    'and dim_level_id=:3 and rownum=1';
    write_to_log_file_n(l_stmt||' '||p_source_type||' '||p_source_code||' '||p_dim_level_id);
  end if;
  l_res:=null;
  open c4(p_source_type,p_source_code,p_dim_level_id);
  fetch c4 into l_res;
  close c4;
  if g_debug then
    write_to_log_file('l_res='||l_res);
  end if;
  return l_res;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in get_filter_view_params '||sqlerrm);
  return -1;
End;

function get_parent_level(
p_child_level varchar2,
p_level_fk out nocopy BSC_IM_UTILS.varchar_tabletype,
p_parent_level out nocopy BSC_IM_UTILS.varchar_tabletype,
p_num_parent_levels out nocopy number
) return boolean is
-------------
cursor c1(p_level varchar2) is
select
par_lvl.level_table_name,
rel.relation_col
from
bsc_sys_dim_levels_b lvl,
bsc_sys_dim_levels_b par_lvl,
bsc_sys_dim_level_rels rel
where
lvl.level_table_name=p_level
and lvl.dim_level_id=rel.dim_level_id
and rel.relation_type=1
and par_lvl.dim_level_id=rel.parent_dim_level_id;
-------------
Begin
  if g_debug then
    write_to_log_file_n('select par_lvl.level_table_name,rel.relation_col from bsc_sys_dim_levels_b lvl,'||
    'bsc_sys_dim_levels_b par_lvl,bsc_sys_dim_level_rels rel where lvl.level_table_name='''||p_child_level||''''||
    'and lvl.dim_level_id=rel.dim_level_id and rel.relation_type=1 and par_lvl.dim_level_id=rel.parent_dim_level_id');
  end if;
  p_num_parent_levels:=1;
  open c1(p_child_level);
  loop
    fetch c1 into p_parent_level(p_num_parent_levels),p_level_fk(p_num_parent_levels);
    exit when c1%notfound;
    p_num_parent_levels:=p_num_parent_levels+1;
  end loop;
  p_num_parent_levels:=p_num_parent_levels-1;
  close c1;
  if g_debug then
    for i in 1..p_num_parent_levels loop
      write_to_log_file(p_parent_level(i)||' '||p_level_fk(i));
    end loop;
  end if;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in get_parent_level '||sqlerrm);
  return false;
End;

function is_recursive_dim(p_child_level in varchar2, p_result OUT NOCOPY boolean) return boolean is
l_level_fk BSC_IM_UTILS.varchar_tabletype;
l_parent_level BSC_IM_UTILS.varchar_tabletype;
l_num_parent_levels number;

begin
  p_result := false;
  if get_parent_level(p_child_level,l_level_fk,l_parent_level,l_num_parent_levels)=false then
     return false;
  end if;
  if (l_parent_level.count=0) then
    p_result := false;
  elsif (p_child_level=l_parent_level(l_parent_level.first)) then
    p_result := true;
  end if;
  return true;
end;

function create_denorm_table(p_dim_level varchar2, p_level_pk varchar2) return varchar2 is
l_denorm_table varchar2(100);
l_stmt varchar2(1000);
l_owner varchar2(100);
l_data_type varchar2(100);
l_reverse varchar2(1000);

CURSOR cDataType(p_owner in varchar2) is
select decode(data_length, null, data_type, data_type||'('||data_length||')') data_type
from all_tab_columns
where owner=p_owner
and table_name=p_dim_level
and column_name = p_level_pk;

cursor c_short_name is
select short_name from bsc_sys_dim_levels_b
where level_table_name=p_dim_level;
l_short_name varchar2(300);

begin
  open c_short_name;
  fetch c_short_name into l_short_name;
  close c_short_name;
  l_denorm_table := BSC_DBGEN_METADATA_READER.get_denorm_dimension_table(l_short_name);
  l_owner := bsc_im_utils.get_table_owner(p_dim_level);

  open cDataType(l_owner);
  fetch cDataType into l_data_type;
  close cDataType;

  l_stmt := 'create table '||l_denorm_table||'(parent_code '||l_data_type||', code '||l_data_type||', child_level number, parent_level number)';

  begin
  BSC_APPS.Do_DDL(l_stmt, AD_DDL.CREATE_TABLE, l_denorm_table);
  l_stmt := 'create index '||l_denorm_table||'_N1 on '||l_denorm_table||'(CODE)';

  BSC_APPS.Do_DDL(l_stmt, AD_DDL.CREATE_INDEX, l_denorm_table||'_N1');
  exception when others then
   if sqlcode = -955 then -- already exists
     null;
   else
     raise;
   end if;
  end;

  l_stmt := 'create materialized view log on '||g_bsc_owner||'.'||l_denorm_table||' with sequence,rowid(code, parent_code, 	 child_level, parent_level) including new values';
  begin
  execute immediate l_stmt;
  exception when others then
    if sqlcode=-12000 then -- snapshot log already exists
      null;
    else
      raise;
    end if;
  end;
  return l_denorm_table;

Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in create_denorm_table: p_dim_level='||p_dim_level||', pk='||p_level_pk||', stmt='||l_stmt||', error='||sqlerrm);
  if (l_data_type is null) then
    write_to_log_file('PK Column '||p_level_pk||' specified in bsc_sys_dim_levels_b does not exist in '||p_dim_level);
  end if;
  raise;
end;

function get_level_for_pk(
p_level_pk varchar2,
p_level out nocopy varchar2,
p_src_object out nocopy varchar2, --only populated if this is a DBI dimension
p_special_dim out nocopy varchar2,
p_rec_dim out nocopy boolean,
p_rec_dim_key out nocopy varchar2
)return boolean is
l_stmt varchar2(5000);
--------------------------------------------
cursor c1(p_col varchar2) is select level_table_name,short_name from bsc_sys_dim_levels_b where upper(level_pk_col)=upper(p_col);
--------------------------------------------
l_name varchar2(200);
l_dbi_dim_data BSC_UPDATE_DIM.t_dbi_dim_data;

Begin
  if NOT g_level_info_cached then
    cache_level_info;
    g_level_info_cached := true;
  end if;
  if g_debug then
    write_to_log_file_n('In get_level_for_pk'||' '||get_time);
    l_stmt:='select level_table_name,short_name from bsc_sys_dim_levels_b where level_pk_col=:1';
    write_to_log_file_n(l_stmt||' '||p_level_pk);
  end if;

  if g_level_info.exists(upper(p_level_pk)) then
    p_level := g_level_info(upper(p_level_pk)).level_table_name;
    l_name := g_level_info(upper(p_level_pk)).short_name;
  else
    open c1(p_level_pk);
    fetch c1 into p_level,l_name;
    close c1;
  end if;
  if g_debug then
    write_to_log_file('Result : '||p_level||','||l_name);
  end if;
  p_special_dim:='none';
  p_src_object:=p_level;
  p_rec_dim:=false;
  p_rec_dim_key:=null;

  --BSC E2E : see if this is a dbi dimension and see if there is table associated with this level

  BSC_UPDATE_DIM.Get_Dbi_Dim_Data(l_name,l_dbi_dim_data);
  if  l_dbi_dim_data.table_name is null then
    -- Check if this is a non-DBI recursive dimension
    if is_recursive_dim(p_level, p_rec_dim)=false then
      return false;
    end if;
    if (p_rec_dim) then
      write_to_log_file_n(p_level||' is a recursive BSC Dimension');
    else
       write_to_log_file_n(p_level||' is not recursive');
    end if;
    if (p_rec_dim=true) then
      p_src_object := create_denorm_table(p_level, p_level_pk);
      p_rec_dim_key := 'PARENT_CODE';
      p_special_dim := 'recursive';
      return true;
    end if;
  else
  --  if l_dbi_dim_data.table_name is not null then
    if create_dbi_dim_tables=false then --try to create the dim tables(e2e) tables the first time they are encountered
      return false;
    end if;
    if g_debug then
      write_to_log_file_n('Finished create_dbi_dim_tables');
      write_to_log_file('short name='||l_dbi_dim_data.short_name||', table name='||
      l_dbi_dim_data.table_name);
      write_to_log_file('code='||l_dbi_dim_data.code_col||', from '||l_dbi_dim_data.from_clause||', '||
      'where '||l_dbi_dim_data.where_clause);
    end if;
    if l_dbi_dim_data.top_n_levels_in_mv>0 then --this is a rec dim
      --ENI_ITEM_VBH_CAT ENI_ITEM_ITM_CAT HRI_PER_USRDR_H PJI_ORGANIZATIONS
      if g_debug then
        write_to_log_file_n('Recursive dim');
      end if;
      p_src_object:='(Select '||l_dbi_dim_data.child_col||' code,'||l_dbi_dim_data.parent_col||' parent_code from '||
      l_dbi_dim_data.denorm_table||' where ('||l_dbi_dim_data.parent_level_col||'<='||
      l_dbi_dim_data.top_n_levels_in_mv||') ';
      --3948748
      p_src_object:=p_src_object||' or ('||l_dbi_dim_data.parent_col||'='||l_dbi_dim_data.child_col||' and '||
      l_dbi_dim_data.parent_level_col||'>'||l_dbi_dim_data.top_n_levels_in_mv||')';
      p_src_object:=p_src_object||')';
      p_rec_dim:=true;
      p_rec_dim_key:='parent_code';
      p_special_dim:='inline';
    elsif l_dbi_dim_data.short_name='ENI_ITEM_VBH_CAT' then
      p_src_object:='(Select '||l_dbi_dim_data.code_col||' CODE from '||l_dbi_dim_data.from_clause||
      l_dbi_dim_data.where_clause||') ';
      p_special_dim:='inline';
    elsif l_dbi_dim_data.short_name='ENI_ITEM_ORG' then
      p_src_object:='(Select '||l_dbi_dim_data.code_col||' CODE from '||l_dbi_dim_data.from_clause||
      l_dbi_dim_data.where_clause||') ';
      p_special_dim:='inline';
    else
      p_src_object:=l_dbi_dim_data.table_name;
    end if;
  end if;
  if g_debug then
    write_to_log_file_n('src object='||p_src_object||' type='||p_special_dim);
    write_to_log_file_n('Returning from get_level_for_pk'||' '||get_time);
  end if;
  ---
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in get_level_for_pk '||sqlerrm);
  return false;
End;

function get_table_cols(
p_table_name varchar2,
p_col_table in out nocopy BSC_IM_UTILS.varchar_tabletype,
p_cols in out nocopy BSC_IM_UTILS.varchar_tabletype,
p_col_type in out nocopy BSC_IM_UTILS.varchar_tabletype,
p_source_column in out nocopy BSC_IM_UTILS.varchar_tabletype,
p_source_formula in out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_cols in out nocopy number
) return boolean is
l_stmt varchar2(5000);
---------------------------------------------
cursor c1(p_table varchar2) is
select table_name,upper(column_name),column_type,source_formula,source_column
from bsc_db_tables_cols where table_name=p_table
order by column_name;
---------------------------------------------
l_table_name varchar2(100);
Begin
  if p_table_name like 'BSC_B_%PRJ%' then
    l_table_name := get_b_table_name_for_prj(p_table_name);
  else
    l_table_name := p_table_name;
  end if;
  if g_debug then
    l_stmt:='select table_name,upper(column_name),column_type,source_formula,upper(source_column) '||
    'from bsc_db_tables_cols where table_name=:1';
    write_to_log_file_n(l_stmt||' '||l_table_name);
  end if;
  if p_number_cols is null then
    p_number_cols:=1;
  else
    p_number_cols:=p_number_cols+1;
  end if;
  open c1(l_table_name);
  loop
    fetch c1 into p_col_table(p_number_cols),p_cols(p_number_cols),p_col_type(p_number_cols),
    p_source_formula(p_number_cols),p_source_column(p_number_cols);
    exit when c1%notfound;
    p_number_cols:=p_number_cols+1;
  end loop;
  close c1;
  p_number_cols:=p_number_cols-1;
  if g_debug then
    write_to_log_file_n('Results');
    for i in 1..p_number_cols loop
      write_to_log_file(p_col_table(i)||' '||p_cols(i)||' '||p_col_type(i)||' '||p_source_formula(i)||' '||
      p_source_column(i));
    end loop;
  end if;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in get_table_cols '||sqlerrm);
  return false;
End;

function get_table_periodicity(p_table_name varchar2) return number is
l_stmt varchar2(5000);
l_id number;
---------------------------------------
cursor c1 (p_table varchar2)
is select periodicity_id from bsc_db_tables where table_name=p_table;
---------------------------------------
l_table_name varchar2(100);
Begin
  if (p_table_name like 'BSC_B%PRJ%') then
    l_table_name := get_b_table_name_for_prj(p_table_name);
  else
    l_table_name := p_table_name;
  end if;
  if g_debug then
    l_stmt:='select periodicity_id from bsc_db_tables where table_name=:1';
    write_to_log_file_n(l_stmt||' '||l_table_name);
  end if;
  open c1(l_table_name);
  fetch c1 into l_id;
  close c1;
  if g_debug then
    write_to_log_file('Result: '||l_id);
  end if;
  return l_id;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in get_table_periodicity '||sqlerrm);
  return -1;
End;

function init_all return boolean is
Begin
  g_status:=true;
  if BSC_IM_UTILS.get_db_user('APPS',g_apps_owner)=false then
    return null;
  end if;
  if g_apps_owner is null then
    return null;
  end if;
  g_prod_owner:='BSC';
  if BSC_IM_UTILS.get_db_user(g_prod_owner,g_bsc_owner)=false then
    return null;
  end if;
  if g_debug then
    write_to_log_file_n('Apps DB User is '||g_apps_owner||', '||g_prod_owner||' user is '||g_bsc_owner||'  '||get_time);
  end if;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in init_all '||sqlerrm);
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

procedure set_globals(p_debug boolean) is
Begin
  g_debug:=p_debug;
  BSC_IM_UTILS.set_globals(g_debug);
  BSC_IM_INT_MD.set_globals(g_debug);
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  null;
End;

function get_table_fks(
p_s_tables BSC_IM_UTILS.varchar_tabletype,
p_number_s_tables number,
p_fk out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_fk out nocopy number
) return boolean is
l_fk BSC_IM_UTILS.varchar_tabletype;
l_number_fk number;
Begin
  p_number_fk:=0;
  for i in 1..p_number_s_tables loop
    if get_table_fks(p_s_tables(i),l_fk,l_number_fk)=false then
      return false;
    end if;
    for j in 1..l_number_fk loop
      if BSC_IM_UTILS.in_array(p_fk,p_number_fk,l_fk(j))=false then
        p_number_fk:=p_number_fk+1;
        p_fk(p_number_fk):=l_fk(j);
      end if;
    end loop;
  end loop;
  if g_debug then
    write_to_log_file_n('Results');
    for i in 1..p_number_fk loop
      write_to_log_file(p_fk(i));
    end loop;
  end if;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in get_table_fks '||sqlerrm);
  return false;
End;

function get_table_fks(
p_table varchar2,
p_fk out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_fk out nocopy number
) return boolean is
l_stmt varchar2(5000);
--------------------------------------------------
--for S tables
cursor c0 (p_table varchar2)
is select distinct bsc_db_tables_cols.column_name,bsc_kpi_dim_levels_b.dim_level_index from
bsc_kpi_data_tables,
bsc_db_tables_cols,
bsc_kpi_dim_levels_b
where
bsc_kpi_data_tables.table_name=bsc_db_tables_cols.table_name
and bsc_db_tables_cols.table_name =p_table
and bsc_db_tables_cols.column_type='P'
and bsc_kpi_data_tables.indicator=bsc_kpi_dim_levels_b.indicator
and bsc_db_tables_cols.column_name=bsc_kpi_dim_levels_b.level_pk_col
and bsc_kpi_data_tables.dim_set_id=bsc_kpi_dim_levels_b.dim_set_id
order by bsc_kpi_dim_levels_b.dim_level_index;
--
--for the B tables
cursor c1 (p_table varchar2,p_owner varchar2)
is select distinct bsc_db_tables_cols.column_name,all_tab_columns.column_id
from
bsc_db_tables_cols ,
all_tab_columns
where bsc_db_tables_cols.table_name =p_table
and bsc_db_tables_cols.column_type='P'
and all_tab_columns.table_name(+)=p_table
and all_tab_columns.column_name(+)=bsc_db_tables_cols.column_name
and all_tab_columns.owner(+)=p_owner
order by all_tab_columns.column_id;
----
l_owner varchar2(200);
l_order BSC_IM_UTILS.number_tabletype;
--------------------------------------------------
l_table_name varchar2(100);
Begin
  p_number_fk:=1;
  if g_debug then
    write_to_log_file_n('distinct bsc_db_tables_cols.column_name,bsc_kpi_dim_levels_b.dim_level_index fr...');
  end if;
  if (p_table like 'BSC_B_%PRJ%') then
    l_table_name := get_b_table_name_for_prj(p_table);
  else
    l_table_name := p_table;
  end if;
  open c0(l_table_name);
  loop
    fetch c0 into p_fk(p_number_fk),l_order(p_number_fk);
    exit when c0%notfound;
    p_number_fk:=p_number_fk+1;
  end loop;
  -- Fix bug#3899842 : close cursor
  close c0;
  p_number_fk:=p_number_fk-1;
  --
  if p_number_fk=0 then
    --either there are no fk or this could be a table without entries in bsc_kpi_data_tables...like B tables
    if g_debug then
      write_to_log_file_n('is select distinct bsc_db_tables_cols.column_name,all_tab_columns.column_id...');
    end if;
    l_owner:=bsc_im_utils.get_table_owner(l_table_name);
    p_number_fk:=p_number_fk+1;
    open c1(l_table_name,l_owner);
    loop
      fetch c1 into p_fk(p_number_fk),l_order(p_number_fk);
      exit when c1%notfound;
      p_number_fk:=p_number_fk+1;
    end loop;
    close c1;
    p_number_fk:=p_number_fk-1;
  end if;
  for i in 1..BSC_IM_UTILS.g_number_global_dimension loop
    if BSC_IM_UTILS.g_global_dimension(i)<>'PERIOD' and BSC_IM_UTILS.g_global_dimension(i)<>'TYPE' then
      p_number_fk:=p_number_fk+1;
      p_fk(p_number_fk):=BSC_IM_UTILS.g_global_dimension(i);
    end if;
  end loop;
  for i in 1..BSC_IM_UTILS.g_number_global_dimension loop
    if BSC_IM_UTILS.g_global_dimension(i)='PERIOD' or BSC_IM_UTILS.g_global_dimension(i)='TYPE' then
      p_number_fk:=p_number_fk+1;
      p_fk(p_number_fk):=BSC_IM_UTILS.g_global_dimension(i);
    end if;
  end loop;
  if g_debug then
    write_to_log_file_n('Results');
    for i in 1..p_number_fk loop
      write_to_log_file(p_fk(i));
    end loop;
  end if;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in get_table_fks '||sqlerrm);
  return false;
End;

function get_table_measures(
p_s_tables BSC_IM_UTILS.varchar_tabletype,
p_number_s_tables number,
p_measures out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_measures out nocopy number
) return boolean is
l_measures BSC_IM_UTILS.varchar_tabletype;
l_number_measures number;
Begin
  p_number_measures:=0;
  for i in 1..p_number_s_tables loop
    l_number_measures:=0;
    if get_table_measures(p_s_tables(i),l_measures,l_number_measures)=false then
      return false;
    end if;
    for j in 1..l_number_measures loop
      if BSC_IM_UTILS.in_array(p_measures,p_number_measures,l_measures(j))=false then
        p_number_measures:=p_number_measures+1;
        p_measures(p_number_measures):=l_measures(j);
      end if;
    end loop;
  end loop;
  if g_debug then
    write_to_log_file_n('Results');
    for i in 1..p_number_measures loop
      write_to_log_file(p_measures(i));
    end loop;
  end if;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in get_s_table_measures '||sqlerrm);
  return false;
End;

function get_table_measures(
p_table varchar2,
p_measures out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_measures out nocopy number
) return boolean is
l_stmt varchar2(5000);
-----------------------------------------
cursor c1 (p_table_name varchar2)
is select distinct column_name from bsc_db_tables_cols where table_name =p_table_name and
column_type='A' order by column_name;
-----------------------------------------
l_table_name varchar2(100);
Begin
  if (p_table like 'BSC_B_%PRJ%') then
    l_table_name := get_b_table_name_for_prj(p_table);
  else
    l_table_name := p_table;
  end if;
  if g_debug then
    l_stmt:='select distinct column_name from bsc_db_tables_cols where table_name =:1 and '||
    'column_type=''A''';
    write_to_log_file_n(l_stmt||' '||p_table);
  end if;
  p_number_measures:=1;
  open c1(l_table_name);
  loop
    fetch c1 into p_measures(p_number_measures);
    exit when c1%notfound;
    p_number_measures:=p_number_measures+1;
  end loop;
  close c1;
  p_number_measures:=p_number_measures-1;
  if g_debug then
    write_to_log_file_n('Results');
    for i in 1..p_number_measures loop
      write_to_log_file(p_measures(i));
    end loop;
  end if;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in get_s_table_measures '||sqlerrm);
  return false;
End;

function get_kpi_periodicity(
p_indicator_id number,
p_periodicity out nocopy BSC_IM_UTILS.number_tabletype,
p_number_periodicity out nocopy number
)return boolean is
l_stmt varchar2(5000);
-------------------------------------------
cursor c1 (p_indicator number)
is select periodicity_id from bsc_kpi_periodicities where  indicator=p_indicator;
-------------------------------------------
Begin
  if g_debug then
    l_stmt:='select periodicity_id from bsc_kpi_periodicities where  indicator=:1';
    write_to_log_file_n(l_stmt||' '||p_indicator_id||'    '||get_time);
  end if;
  p_number_periodicity:=1;
  open c1(p_indicator_id);
  loop
    fetch c1 into p_periodicity(p_number_periodicity);
    exit when c1%notfound;
    p_number_periodicity:=p_number_periodicity+1;
  end loop;
  close c1;
  p_number_periodicity:=p_number_periodicity-1;
  if g_debug then
    write_to_debug_n('Results');
    for i in 1..p_number_periodicity loop
      write_to_debug(p_periodicity(i));
    end loop;
  end if;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in get_kpi_periodicity '||sqlerrm);
  return false;
End;

function get_s_sb_tables(
p_indicator_id number,
p_s_tables out nocopy BSC_IM_UTILS.varchar_tabletype,
p_s_periodicity out nocopy BSC_IM_UTILS.number_tabletype,
p_number_s_tables out nocopy number
)return boolean is
l_stmt varchar2(5000);
l_mv_object_string varchar2(5000);
l_mv_object BSC_IM_UTILS.varchar_tabletype;
l_number_mv_object number;
---------------------------------------------------

-- overcome issue with large data in bsc_kpi_data_tables, use db_tables_rels instead
--cursor c1 (p_indicator number)
--is select distinct upper(table_name),periodicity_id from bsc_kpi_data_tables where indicator=p_indicator
--and table_name is not null;

cursor c1 (p_indicator number)is
select distinct upper(table_name), substr(table_name, instr(table_name, '_', -1, 1)+1) periodicity_id  from bsc_db_tables_rels
where instr(table_name, 'BSC_S_'||p_indicator||'_') =1 or instr(table_name, 'BSC_SB_'||p_indicator||'_') =1;

/*
5009697
c2 will add duplicate data to c1
cursor c2 (p_indicator number)
is select distinct rel.source_table_name, tab.periodicity_id
from bsc_db_tables_rels rel, bsc_db_tables tab
where rel.table_name in
(select distinct upper(table_name) from bsc_kpi_data_tables where indicator=p_indicator)
and rel.source_table_name like 'BSC_SB_%'
and rel.source_table_name=tab.table_name ;
*/
---------------------------------------------------
Begin
  if g_debug then
    l_stmt:='select distinct upper(table_name),periodicity_id from bsc_kpi_data_tables where indicator=:1 '||
    'and table_name is not null';
    write_to_log_file_n(l_stmt||' '||p_indicator_id);
  end if;
  p_number_s_tables:=1;
  open c1(p_indicator_id);
  loop
    fetch c1 into p_s_tables(p_number_s_tables),p_s_periodicity(p_number_s_tables);
    exit when c1%notfound;
    p_number_s_tables:=p_number_s_tables+1;
  end loop;
  close c1;
  /*
  5009697
  if g_debug then
    l_stmt:='select distinct rel.source_table_name, tab.periodicity_id '||
    'from bsc_db_tables_rels rel, bsc_db_tables tab '||
    'where rel.table_name in  '||
    '(select distinct upper(table_name) from bsc_kpi_data_tables where indicator=:1) '||
    'and rel.source_table_name like ''BSC_SB_%'' '||
    'and rel.source_table_name=tab.table_name ';
    write_to_log_file_n(l_stmt||' '||p_indicator_id);
  end if;

  open c2(p_indicator_id);
  loop
    fetch c2 into p_s_tables(p_number_s_tables),p_s_periodicity(p_number_s_tables);
    exit when c2%notfound;
    p_number_s_tables:=p_number_s_tables+1;
  end loop;
  close c2;
  */
  p_number_s_tables:=p_number_s_tables-1;
  if g_debug then
    write_to_debug_n('S tables and SB from bsc_kpi_data_tables are ');
    for i in 1..p_number_s_tables loop
      write_to_debug(p_s_tables(i)||' '||p_s_periodicity(i));
    end loop;
  end if;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in get_s_sb_tables '||sqlerrm);
  return false;
End;

function get_db_calculation(
p_indicator number,
p_s_table varchar2,
p_type number,
p_calculation_table in out nocopy BSC_IM_UTILS.varchar_tabletype,
p_calculation_type in out nocopy BSC_IM_UTILS.varchar_tabletype,
p_parameter1 in out nocopy BSC_IM_UTILS.varchar_tabletype,
p_parameter2 in out nocopy BSC_IM_UTILS.varchar_tabletype,
p_parameter3 in out nocopy BSC_IM_UTILS.varchar_tabletype,
p_parameter4 in out nocopy BSC_IM_UTILS.varchar_tabletype,
p_parameter5 in out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_parameters in out nocopy number
) return boolean is
l_stmt varchar2(4000);
l_agg_func BSC_IM_UTILS.varchar_tabletype;
----------------------------------------------------------
cursor c1 (p_table varchar2)
is select table_name,calculation_type,parameter1,'''0''',upper(parameter3),parameter4,parameter5
from bsc_db_calculations where table_name=p_table
order by upper(parameter3),parameter1;

cursor c2 (p_table varchar2,p_type number)
is select table_name,calculation_type,parameter1,'''0''',upper(parameter3),parameter4,parameter5
from bsc_db_calculations where table_name=p_table
and calculation_type=p_type
order by upper(parameter3),parameter1;

--  bug 3866554, dont assume that the datatype in the above sql is always VARCHAR2
cursor c3 (p_column varchar2)
is select cols.data_type
from all_tab_columns cols,
bsc_kpi_dim_levels_b dim
where cols.table_name = dim.level_table_name
and cols.column_name = 'CODE'
and dim.indicator = p_indicator
and dim.level_pk_col = p_column
and cols.owner = bsc_im_utils.get_table_owner(dim.level_table_name) ;

----------------------------------------------------------
l_calculation_table BSC_IM_UTILS.varchar_tabletype;
l_calculation_type BSC_IM_UTILS.varchar_tabletype;
l_parameter1 BSC_IM_UTILS.varchar_tabletype;
l_parameter2 BSC_IM_UTILS.varchar_tabletype;
l_parameter3 BSC_IM_UTILS.varchar_tabletype;
l_parameter4 BSC_IM_UTILS.varchar_tabletype;
l_parameter5 BSC_IM_UTILS.varchar_tabletype;
l_number_parameters number;
l_fk_datatype varchar2(100);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
----------------------------------------------------------
Begin
  if g_debug then
    write_to_log_file_n('IN get_db_calculation'||' '||get_time);
    l_stmt:='select table_name,calculation_type,parameter1,0,upper(parameter3),parameter4,parameter5 '||
    'from bsc_db_calculations where table_name=:1 ';
    if p_type is not null then
      l_stmt:=l_stmt||' and calculation_type='||p_type;
    end if;
    l_stmt:=l_stmt||' order by upper(parameter3),parameter1';
    write_to_log_file_n(l_stmt||' '||p_s_table);
  end if;
  --
  if p_number_parameters is null then
    p_number_parameters:=1;
  else
    p_number_parameters:=p_number_parameters+1;
  end if;
  --
 l_stmt:=' select cols.data_type from '||bsc_olap_main.g_col_type_table_name||' cols,
            bsc_kpi_dim_levels_b dim where dim.indicator = :1
            and dim.level_pk_col = :2 and cols.level_table_name = dim.level_table_name';

  l_number_parameters:=1;
  if p_type is not null then
    open c2(p_s_table,p_type);
    fetch c2 bulk collect into l_calculation_table, l_calculation_type, l_parameter1, l_parameter2,
                               l_parameter3, l_parameter4, l_parameter5;
    close c2;
    l_number_parameters := l_number_parameters + l_calculation_table.count-1;
    for i in 1..l_number_parameters loop
      -- bug 3866554, dont assume that the datatype for the FK is always VARCHAR2,
      -- instead get it from the level
      -- table name's CODE column
      --Bug 3878968 use the tmp table to get the datatype
      open cv for l_stmt using p_indicator,l_parameter1(i);
      fetch cv into l_fk_datatype ;
      close cv;
      if (l_fk_datatype = 'NUMBER') then
  	l_parameter2(i) := '0'; --rkumar: bugfix5458512
      end if;
      --l_number_parameters:=l_number_parameters+1;
    end loop;
  else
    open c1(p_s_table);
    loop
      fetch c1 into l_calculation_table(l_number_parameters),l_calculation_type(l_number_parameters),
      l_parameter1(l_number_parameters),l_parameter2(l_number_parameters),l_parameter3(l_number_parameters),
      l_parameter4(l_number_parameters),l_parameter5(l_number_parameters);
      exit when c1%notfound;
      --  bug 3866554, dont assume that the datatype for the FK is always VARCHAR2, instead get it from the level
      -- table name's CODE column
      open c3(l_parameter1(l_number_parameters));
      fetch c3 into l_fk_datatype;
      close c3;
      if (l_fk_datatype = 'NUMBER') then
        l_parameter2(l_number_parameters) := '0';
      end if;
      l_number_parameters:=l_number_parameters+1;
    end loop;
    close c1;
    l_number_parameters:=l_number_parameters-1;
  end if;
  if g_debug then
    write_to_log_file_n('Cursor Results');
    for i in 1..l_number_parameters loop
      write_to_log_file(l_calculation_table(i)||' '||l_calculation_type(i)||' '||l_parameter1(i)||' '||
      l_parameter2(i)||' '||l_parameter3(i)||' '||l_parameter4(i)||' '||l_parameter5(i));
    end loop;
  end if;
  -----------------------
  --for E2E, for recursive dimensions,we need to turn off rec dim keys from zero code calculations
  --for rec dim, the data at the top levels are aggregated data. so if we take a parent level
  --whose level=1, i.e top node, the value we see is the total or zero code value from the base MV
  if p_type=4 then
    declare
      l_level varchar2(100);
      l_src_object varchar2(20000);
      l_special_dim varchar2(100);
      l_rec_dim boolean;
      l_rec_dim_key varchar2(100);
    begin
      for i in 1..l_number_parameters loop
        if get_level_for_pk(l_parameter1(i),l_level,l_src_object,l_special_dim,
          l_rec_dim,l_rec_dim_key)=false then
          return false;
        end if;
        --if l_rec_dim=false then
          write_to_log_file_n(l_level||' is not a recursive dim, so add parameters');
          p_calculation_table(p_number_parameters):=l_calculation_table(i);
          p_calculation_type(p_number_parameters):=l_calculation_type(i);
          p_parameter1(p_number_parameters):=l_parameter1(i);
          p_parameter2(p_number_parameters):=l_parameter2(i);
          p_parameter3(p_number_parameters):=l_parameter3(i);
          p_parameter4(p_number_parameters):=l_parameter4(i);
          p_parameter5(p_number_parameters):=l_parameter5(i);
          p_number_parameters:=p_number_parameters+1;
        --end if;
      end loop;
      p_number_parameters:=p_number_parameters-1;
    end;
  else
    for i in 1..l_number_parameters loop
      p_calculation_table(p_number_parameters):=l_calculation_table(i);
      p_calculation_type(p_number_parameters):=l_calculation_type(i);
      p_parameter1(p_number_parameters):=l_parameter1(i);
      p_parameter2(p_number_parameters):=l_parameter2(i);
      p_parameter3(p_number_parameters):=l_parameter3(i);
      p_parameter4(p_number_parameters):=l_parameter4(i);
      p_parameter5(p_number_parameters):=l_parameter5(i);
      p_number_parameters:=p_number_parameters+1;
    end loop;
    p_number_parameters:=p_number_parameters-1;
  end if;
  if g_debug then
    write_to_log_file_n('In End of get_db_calculation'||' '||get_time);
    write_to_log_file_n('After Reassigning, Results');
    for i in 1..p_number_parameters loop
      write_to_log_file(p_calculation_table(i)||' '||p_calculation_type(i)||' '||p_parameter1(i)||' '||
      p_parameter2(i)||' '||p_parameter3(i)||' '||p_parameter4(i)||' '||p_parameter5(i));
    end loop;
  end if;
  -----------------------
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in get_db_calculation '||sqlerrm);
  return false;
End;

function get_table_relations(
p_table varchar2,
p_tables in out nocopy BSC_IM_UTILS.varchar_tabletype,
p_source_tables in out nocopy BSC_IM_UTILS.varchar_tabletype,
p_relation_type in out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_tables in out nocopy number
) return boolean is
l_stmt varchar2(32000);
------------------------------------------------
cursor c1 (p_table_name varchar2)
is select table_name,source_table_name,relation_type from bsc_db_tables_rels where
table_name=p_table_name;
------------------------------------------------
l_table_name varchar2(100);
Begin
  if (p_table like 'BSC_B_%PRJ%') then
    l_table_name := get_b_table_name_for_prj(p_table);
  else
    l_table_name := p_table;
  end if;
  if g_debug then
    write_to_log_file_n('In get_table_relations');
  end if;
  if p_number_tables is null then
    p_number_tables:=1;
  else
    p_number_tables:=p_number_tables+1;
  end if;
  if g_debug then
    l_stmt:='select table_name,source_table_name,relation_type from bsc_db_tables_rels where '||
    'table_name=:1';
    write_to_log_file_n(l_stmt||' '||l_table_name);
  end if;
  open c1(l_table_name);
  loop
    fetch c1 into p_tables(p_number_tables),p_source_tables(p_number_tables),
    p_relation_type(p_number_tables);
    exit when c1%notfound;
    p_number_tables:=p_number_tables+1;
  end loop;
  p_number_tables:=p_number_tables-1;
  close c1;
  if g_debug then
    write_to_log_file_n('Results');
    for i in 1..p_number_tables loop
      write_to_log_file(p_tables(i)||' '||p_source_tables(i)||' '||p_relation_type(i));
    end loop;
  end if;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in get_table_relations '||sqlerrm);
  return false;
End;

function get_calendar_for_periodicity(p_periodicity number) return number is
l_cal number;
l_stmt varchar2(1000);
---------------------------------------------
cursor c1 (p_id number)
is select calendar_id from bsc_sys_periodicities where periodicity_id=p_id;
---------------------------------------------
Begin
  if g_debug then
    l_stmt:='select calendar_id from bsc_sys_periodicities where periodicity_id=:1';
    write_to_log_file_n(l_stmt||' '||p_periodicity);
  end if;
  open c1(p_periodicity);
  fetch c1 into l_cal;
  close c1;
  return l_cal;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in get_calendar_for_periodicity '||sqlerrm);
  return null;
End;

function get_summarize_calendar(
p_periodicity number,
p_calendar out nocopy varchar2,
p_calendar_tables out nocopy varchar2,
p_calendar_alias out nocopy varchar2,
p_calendar_join_1 out nocopy varchar2,
p_calendar_join_2 out nocopy varchar2
)return boolean is
-------------------------------------------------------
l_periodicity_id BSC_IM_UTILS.number_tabletype;
l_source BSC_IM_UTILS.varchar_tabletype;
l_db_column_name BSC_IM_UTILS.varchar_tabletype;
l_number_periodicity number;
-------------------------------------------------------
l_values BSC_IM_UTILS.varchar_tabletype;
l_number_values number;
l_index number;
-------------------------------------------------------
l_cal_column BSC_IM_UTILS.varchar_tabletype;
l_cal_periodicity BSC_IM_UTILS.number_tabletype;
l_number_cal_column number;
l_calendar_id number;
-------------------------------------------------------
cursor c1 is select periodicity_id,source,db_column_name from bsc_sys_periodicities;
-------------------------------------------------------
Begin

  l_number_periodicity:=1;
  if g_debug then
    g_stmt:='select periodicity_id,source,db_column_name from bsc_sys_periodicities';
    write_to_log_file_n(g_stmt);
  end if;
  open c1;
  loop
    fetch c1 into l_periodicity_id(l_number_periodicity),l_source(l_number_periodicity),
    l_db_column_name(l_number_periodicity);
    exit when c1%notfound;
    l_number_periodicity:=l_number_periodicity+1;
  end loop;
  l_number_periodicity:=l_number_periodicity-1;
  close c1;
  if g_debug then
    write_to_log_file('Result');
    for i in 1..l_number_periodicity loop
      write_to_log_file(l_periodicity_id(i)||' '||l_source(i)||' '||l_db_column_name(i));
    end loop;
  end if;
  l_calendar_id:=get_calendar_for_periodicity(p_periodicity);
  if g_debug then
    write_to_log_file_n('The calendar id for periodicity '||p_periodicity||'='||l_calendar_id);
  end if;
  l_number_cal_column:=1;
  l_cal_periodicity(l_number_cal_column):=p_periodicity;
  l_cal_column(l_number_cal_column):=null;
  for i in 1..l_number_periodicity loop
    if l_periodicity_id(i)=p_periodicity then
      l_cal_column(l_number_cal_column):=l_db_column_name(i);
      exit;
    end if;
  end loop;
  for i in 1..l_number_periodicity loop
    l_number_values:=0;
    if BSC_IM_UTILS.parse_values(l_source(i),',',l_values,l_number_values)=false then
      return false;
    end if;
    for j in 1..l_number_values loop
      if l_values(j)=p_periodicity then
        if BSC_IM_UTILS.in_array(l_cal_column,l_number_cal_column,l_db_column_name(i))=false then
          l_number_cal_column:=l_number_cal_column+1;
          l_cal_periodicity(l_number_cal_column):=l_periodicity_id(i);
          l_cal_column(l_number_cal_column):=l_db_column_name(i);
        end if;
      end if;
    end loop;
  end loop;
  if g_debug then
    write_to_log_file_n('The cal columns');
    for i in 1..l_number_cal_column loop
      write_to_log_file(l_cal_column(i)||' '||l_cal_periodicity(i));
    end loop;
  end if;
  p_calendar:='(select distinct ';
  for i in 1..l_number_cal_column loop
    if l_cal_column(i) is not null then
      p_calendar:=p_calendar||l_cal_column(i)||',';
    end if;
  end loop;
  p_calendar:=substr(p_calendar,1,length(p_calendar)-1);
  p_calendar:=p_calendar||' from BSC_DB_CALENDAR ';
  if l_calendar_id is not null then
    p_calendar:=p_calendar||'where calendar_id='||l_calendar_id;
  end if;
  p_calendar:=p_calendar||')';
  p_calendar_tables:='BSC_DB_CALENDAR';
  p_calendar_alias:='BSC_DB_CALENDAR';
  p_calendar_join_1:=l_cal_column(1);
  p_calendar_join_2:='YEAR';
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in get_summarize_calendar '||sqlerrm);
  return false;
End;

function get_columns_in_formula(
p_expression varchar2,
p_measure BSC_IM_UTILS.varchar_tabletype,
p_number_measure number,
p_table out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_table out nocopy number
)return boolean is
Begin
  p_number_table:=0;
  for i in 1..p_number_measure loop
    if instr(upper(p_expression),upper(p_measure(i)))>0 then
      if BSC_IM_UTILS.in_array(p_table,p_number_table,p_measure(i))=false then
        p_number_table:=p_number_table+1;
        p_table(p_number_table):=p_measure(i);
      end if;
    end if;
  end loop;
  if g_debug then
    write_to_log_file_n('Columns parsed out of '||p_expression||' :');
    for i in 1..p_number_table loop
      write_to_log_file(p_table(i));
    end loop;
  end if;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in get_columns_in_formula '||sqlerrm);
  return false;
End;

function get_period_type_id(p_level varchar2) return number is
l_period_type_id number;
Begin
  if p_level='DAY' or p_level='DAY365' then
    l_period_type_id:=1;
  elsif p_level='WEEK' or p_level='WEEK52' then
    l_period_type_id:=16;
  elsif p_level='MONTH' then
    l_period_type_id:=32;
  elsif p_level='QUARTER' then
    l_period_type_id:=64;
  elsif p_level='YEAR' then
    l_period_type_id:=128;
  end if;
  return l_period_type_id;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in get_period_type_id '||sqlerrm);
  return null;
End;

function find_xtd_levels(
p_periodicity number,
p_xtd_levels out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_xtd_levels out nocopy number
)return boolean is
l_stmt varchar2(2000);
l_period_col_name varchar2(200);
l_level varchar2(200);
--------------------------------------
cursor c1 (p_id number)
is select db_column_name,period_col_name from bsc_sys_periodicities where periodicity_id=p_id;
--------------------------------------
Begin
  p_number_xtd_levels:=0;
  if g_debug then
    l_stmt:='select db_column_name,period_col_name from bsc_sys_periodicities where periodicity_id=:1';
    write_to_log_file_n(l_stmt||' '||p_periodicity);
  end if;
  open c1(p_periodicity);
  fetch c1 into l_level,l_period_col_name;
  close c1;
  if g_debug then
    write_to_log_file(l_level||' '||l_period_col_name);
  end if;
  if l_level='DAY' or l_level='DAY365' then
    p_xtd_levels(1):='WEEK52';
    p_xtd_levels(2):='MONTH';
    p_xtd_levels(3):='QUARTER';
    p_xtd_levels(4):='YEAR';
    p_number_xtd_levels:=4;
  elsif l_level='WEEK' or l_level='WEEK52' then
    p_xtd_levels(1):='YEAR';
    p_number_xtd_levels:=1;
  elsif l_level='MONTH' then
    p_xtd_levels(1):='QUARTER';
    p_xtd_levels(2):='YEAR';
    p_number_xtd_levels:=2;
  elsif l_level='QUARTER' then
    p_xtd_levels(1):='YEAR';
    p_number_xtd_levels:=1;
  elsif l_level='YEAR' then
    null;
  end if;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in find_xtd_levels '||sqlerrm);
  return false;
End;

function load_reporting_calendar(
p_options BSC_IM_UTILS.varchar_tabletype,
p_number_options number
)return boolean is
----------------
--1001 is DBI ent calendar
cursor c1 is select calendar_id,decode(edw_calendar_type_id,null,0,1,decode(edw_calendar_id,1001,2,1))
from bsc_sys_calendars_b;
---------------
l_calendar_id BSC_IM_UTILS.number_tabletype;
l_calendar_type BSC_IM_UTILS.number_tabletype;
l_number_calendar_id number;
---------------
l_calendar_data cal_record_table;
l_number_calendar_data number;
l_periodicity_data cal_periodicity_table;
l_number_periodicity_data number;
l_hier BSC_IM_UTILS.varchar_tabletype;
l_hier_type BSC_IM_UTILS.varchar_tabletype;
l_number_hier number;
---------------
l_rpt_calendar varchar2(200);
l_rpt_calendar_owner varchar2(200);
---------------
Begin
  if g_debug then
    write_to_log_file_n('In load_reporting_calendar '||get_time);
  end if;
  --Bug#3973335
  if BSC_IM_UTILS.get_option_value(g_options,g_number_options,'DEBUG LOG')='Y' then
    g_debug:=true;
  end if;
  l_rpt_calendar:='BSC_REPORTING_CALENDAR';
  l_rpt_calendar_owner:=BSC_IM_UTILS.get_table_owner(l_rpt_calendar);
  /*if BSC_IM_UTILS.truncate_table(l_rpt_calendar,l_rpt_calendar_owner)=false then
    null;
  end if;*/
  --get the list of calendars
  if g_debug then
    write_to_log_file_n('select calendar_id from bsc_sys_calendars_b');
  end if;
  l_number_calendar_id:=1;
  open c1;
  loop
    fetch c1 into l_calendar_id(l_number_calendar_id),l_calendar_type(l_number_calendar_id);
    exit when c1%notfound;
    drop_and_add_partition(l_calendar_id(l_number_calendar_id), l_rpt_calendar_owner);
    l_number_calendar_id:=l_number_calendar_id+1;
  end loop;
  close c1;
  l_number_calendar_id:=l_number_calendar_id-1;
  if g_debug then
    for i in 1..l_number_calendar_id loop
      write_to_log_file(l_calendar_id(i)||' '||l_calendar_type(i));
    end loop;
  end if;
  --------------create the temp table-----
  /*l_temp_table:='BSC_CAL_TEMP';
  l_stmt:='create global temporary table '||l_temp_table||'(record_type_id number,'||
  'period_type_id number,period number,year number) on commit preserve rows';
  BSC_APPS.Do_DDL(l_stmt, AD_DDL.CREATE_TABLE, l_temp_table);*/
  ----------------------------------------
  ------------------------
  /*for each calendar, get the periodicities to fetch from bsc_db_calendar
  find out the relations between the periodicities, see if they are the std
  periodicities. if yes, assign the period_type_id etc. if custom, generate
  the period_type_id etc. then come up with the hierarchies to load into the
  reporting calendar.
  then for each of the hier, load the rpt cal
  */
  for i in 1..l_number_calendar_id loop
    if g_debug then
      write_to_log_file_n('Processing calendar '||l_calendar_id(i));
    end if;
    if get_calendar_data(l_calendar_id(i),l_calendar_data,l_number_calendar_data)=false then
      return false;
    end if;
    if get_periodicity_data(l_calendar_id(i),l_calendar_type(i),l_periodicity_data,l_number_periodicity_data)=false then
      return false;
    end if;
    if built_hier(l_calendar_id(i),l_calendar_type(i),l_periodicity_data,l_number_periodicity_data,l_hier,l_hier_type,
      l_number_hier)=false then
      return false;
    end if;
    if l_calendar_type(i)=0 then
      if set_xtd_pattern(l_calendar_id(i),l_periodicity_data,l_number_periodicity_data,l_hier,l_hier_type,
        l_number_hier)=false then
        return false;
      end if;
    end if;
    -------------------------
    for j in 1..l_number_hier loop
      if l_hier_type(j)='Std' or l_hier_type(j)='Custom' then
        if load_reporting_calendar(
          l_calendar_id(i),
          null,
          l_hier(j),
          l_hier_type(j),
          l_periodicity_data,
          l_number_periodicity_data)=false then
          return false;
        end if;
      elsif l_hier_type(j)='DBI' then
        if load_reporting_calendar_DBI(
          l_calendar_id(i),
          null,
          l_hier(j),
          l_hier_type(j),
          l_calendar_data,
          l_number_calendar_data,
          l_periodicity_data,
          l_number_periodicity_data)=false then
          return false;
        end if;
        if load_rpt_cal_DBI_rolling(
          l_calendar_id(i),
          null,
          l_hier(j),
          l_hier_type(j),
          l_calendar_data,
          l_number_calendar_data,
          l_periodicity_data,
          l_number_periodicity_data)=false then
          return false;
        end if;
      end if;
    end loop;
    -------------------------
  end loop;
  if BSC_IM_UTILS.get_option_value(p_options,p_number_options,'ANALYZE')='Y' then
    BSC_IM_UTILS.analyze_object(l_rpt_calendar,l_rpt_calendar_owner,null,null,null);
  end if;

  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in load_reporting_calendar '||sqlerrm);
  return false;
End;

--Fix bug#4027813 This function created to load reporting calendar only for the specified
--calendar id
function load_reporting_calendar(
p_calendar_id number,
p_options BSC_IM_UTILS.varchar_tabletype,
p_number_options number
)return boolean is
----------------
--1001 is DBI ent calendar
cursor c1 is select decode(edw_calendar_type_id,null,0,1,decode(edw_calendar_id,1001,2,1))
from bsc_sys_calendars_b
where calendar_id = p_calendar_id;
---------------
l_calendar_type number;
---------------
l_calendar_data cal_record_table;
l_number_calendar_data number;
l_periodicity_data cal_periodicity_table;
l_number_periodicity_data number;
l_hier BSC_IM_UTILS.varchar_tabletype;
l_hier_type BSC_IM_UTILS.varchar_tabletype;
l_number_hier number;
---------------
l_rpt_calendar varchar2(200);
l_rpt_calendar_owner varchar2(200);
---------------
l_stmt varchar2(1000);
Begin
  if g_debug then
    write_to_log_file_n('In load_reporting_calendar '||get_time);
  end if;
  if calendar_already_refreshed(p_calendar_id) then
    return true;
  end if;
  --Bug#3973335
  if BSC_IM_UTILS.get_option_value(g_options,g_number_options,'DEBUG LOG')='Y' then
    g_debug:=true;
  end if;
  l_rpt_calendar:='BSC_REPORTING_CALENDAR';
  l_rpt_calendar_owner:=BSC_IM_UTILS.get_table_owner(l_rpt_calendar);
  drop_and_add_partition(p_calendar_id, l_rpt_calendar_owner);
  --bug 4636259, performance issue, so partitioning;

  if g_debug then
    write_to_log_file_n('dropping and adding calendars for '||p_calendar_id);
  end if;
  --get the calendar type
  if g_debug then
    write_to_log_file_n('select decode(edw_calendar_type_id,null,0,1,decode(edw_calendar_id,1001,2,1))'||
                        ' from bsc_sys_calendars_b where calendar_id=p_calendar_id');
  end if;
  open c1;
  fetch c1 into l_calendar_type;
  close c1;
  --------------create the temp table-----
  /*l_temp_table:='BSC_CAL_TEMP';
  l_stmt:='create global temporary table '||l_temp_table||'(record_type_id number,'||
  'period_type_id number,period number,year number) on commit preserve rows';
  BSC_APPS.Do_DDL(l_stmt, AD_DDL.CREATE_TABLE, l_temp_table);*/
  ----------------------------------------
  ------------------------
  /*for this calendar, get the periodicities to fetch from bsc_db_calendar
  find out the relations between the periodicities, see if they are the std
  periodicities. if yes, assign the period_type_id etc. if custom, generate
  the period_type_id etc. then come up with the hierarchies to load into the
  reporting calendar.
  then for each of the hier, load the rpt cal
  */
  if g_debug then
    write_to_log_file_n('Processing calendar '||p_calendar_id);
  end if;
  if get_calendar_data(p_calendar_id,l_calendar_data,l_number_calendar_data)=false then
    return false;
  end if;
  if get_periodicity_data(p_calendar_id,l_calendar_type,l_periodicity_data,l_number_periodicity_data)=false then
    return false;
  end if;
  if built_hier(p_calendar_id,l_calendar_type,l_periodicity_data,l_number_periodicity_data,l_hier,l_hier_type,
    l_number_hier)=false then
    return false;
  end if;
  if l_calendar_type=0 then
    if set_xtd_pattern(p_calendar_id,l_periodicity_data,l_number_periodicity_data,l_hier,l_hier_type,
      l_number_hier)=false then
      return false;
    end if;
  end if;
  -------------------------
  for j in 1..l_number_hier loop
    if l_hier_type(j)='Std' or l_hier_type(j)='Custom' then
      if load_reporting_calendar(
        p_calendar_id,
        null,
        l_hier(j),
        l_hier_type(j),
        l_periodicity_data,
        l_number_periodicity_data)=false then
        return false;
      end if;
    elsif l_hier_type(j)='DBI' then
      if load_reporting_calendar_DBI(
        p_calendar_id,
        null,
        l_hier(j),
        l_hier_type(j),
        l_calendar_data,
        l_number_calendar_data,
        l_periodicity_data,
        l_number_periodicity_data)=false then
        return false;
      end if;
      if load_rpt_cal_DBI_rolling(
        p_calendar_id,
        null,
        l_hier(j),
        l_hier_type(j),
        l_calendar_data,
        l_number_calendar_data,
        l_periodicity_data,
        l_number_periodicity_data)=false then
        return false;
      end if;
    end if;
  end loop;
  -------------------------
  if BSC_IM_UTILS.get_option_value(p_options,p_number_options,'ANALYZE')='Y' then
    BSC_IM_UTILS.analyze_object(l_rpt_calendar,l_rpt_calendar_owner,null,null,'p_'||p_calendar_id);
  end if;
  cache_calendar_as_loaded(p_calendar_id);
  if g_debug then
    write_to_log_file_n('Completed load_reporting_calendar '||get_time);
    write_to_log_file_n('--------------------------------------------');
  end if;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in load_reporting_calendar '||sqlerrm);
  return false;
End;

function get_calendar_data(
p_calendar_id number,
p_calendar_data out nocopy cal_record_table,
p_number_calendar_data out nocopy number
) return boolean is
cursor c1 (p_calendar_id number)
is select calendar_year,calendar_month,calendar_day,year,semester,bimester,quarter,month,
week52,day365,custom_1,custom_2,custom_3,custom_4,custom_5,custom_6,custom_7,
custom_8,custom_9,custom_10,custom_11,custom_12,custom_13,custom_14,custom_15,
custom_16,custom_17,custom_18,custom_19,custom_20 from bsc_db_calendar where calendar_id=p_calendar_id
order by calendar_year,calendar_month,calendar_day;
Begin
  if g_debug then
    write_to_log_file_n('select calendar_year,calendar_month,calendar_day,year,semester,bimester,quarter,month, '||
    'week52,day365,custom_1,custom_2,custom_3,custom_4,custom_5,custom_6,custom_7, '||
    'custom_8,custom_9,custom_10,custom_11,custom_12,custom_13,custom_14,custom_15, '||
    'custom_16,custom_17,custom_18,custom_19,custom_20 from bsc_db_calendar where calendar_id='||p_calendar_id||
    'order by calendar_year,calendar_month,calendar_day');
  end if;
  p_number_calendar_data:=1;
  p_calendar_data:=cal_record_table();
  p_calendar_data.extend;
  open c1(p_calendar_id);
  loop
    fetch c1 into
    p_calendar_data(p_number_calendar_data).calendar_year,
    p_calendar_data(p_number_calendar_data).calendar_month,
    p_calendar_data(p_number_calendar_data).calendar_day,
    p_calendar_data(p_number_calendar_data).year,
    p_calendar_data(p_number_calendar_data).semester,
    p_calendar_data(p_number_calendar_data).bimester,
    p_calendar_data(p_number_calendar_data).quarter,
    p_calendar_data(p_number_calendar_data).month,
    p_calendar_data(p_number_calendar_data).week52,
    p_calendar_data(p_number_calendar_data).day365,
    p_calendar_data(p_number_calendar_data).custom_1,
    p_calendar_data(p_number_calendar_data).custom_2,
    p_calendar_data(p_number_calendar_data).custom_3,
    p_calendar_data(p_number_calendar_data).custom_4,
    p_calendar_data(p_number_calendar_data).custom_5,
    p_calendar_data(p_number_calendar_data).custom_6,
    p_calendar_data(p_number_calendar_data).custom_7,
    p_calendar_data(p_number_calendar_data).custom_8,
    p_calendar_data(p_number_calendar_data).custom_9,
    p_calendar_data(p_number_calendar_data).custom_10,
    p_calendar_data(p_number_calendar_data).custom_11,
    p_calendar_data(p_number_calendar_data).custom_12,
    p_calendar_data(p_number_calendar_data).custom_13,
    p_calendar_data(p_number_calendar_data).custom_14,
    p_calendar_data(p_number_calendar_data).custom_15,
    p_calendar_data(p_number_calendar_data).custom_16,
    p_calendar_data(p_number_calendar_data).custom_17,
    p_calendar_data(p_number_calendar_data).custom_18,
    p_calendar_data(p_number_calendar_data).custom_19,
    p_calendar_data(p_number_calendar_data).custom_20;
    exit when c1%notfound;
    p_number_calendar_data:=p_number_calendar_data+1;
    p_calendar_data.extend;
  end loop;
  p_number_calendar_data:=p_number_calendar_data-1;
  close c1;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in get_calendar_data '||sqlerrm);
  return false;
End;

function get_periodicity_data(
p_calendar_id number,
p_calendar_type number,
p_periodicity_data out nocopy cal_periodicity_table,
p_number_periodicity_data out nocopy number
)return boolean is
--------------------------
cursor c1(p_calendar_id number) is
select periodicity_id,source,db_column_name,periodicity_type,
period_type_id,record_type_id,xtd_pattern from bsc_sys_periodicities
where calendar_id=p_calendar_id and periodicity_type not in (11,12);
--------------------------
l_custom_count number;
--------------------------

Begin

  if g_debug then
    write_to_log_file_n('select periodicity_id,source,db_column_name,periodicity_type,'||
    'period_type_id,record_type_id,xtd_pattern from bsc_sys_periodicities '||
    'where calendar_id='||p_calendar_id||' and periodicity_type not in (11,12)');
  end if;
  l_custom_count:=0;
  open c1(p_calendar_id);
  p_number_periodicity_data:=1;
  p_periodicity_data:=cal_periodicity_table();
  p_periodicity_data.extend;
  loop
    fetch c1 into
    p_periodicity_data(p_number_periodicity_data).periodicity_id,
    p_periodicity_data(p_number_periodicity_data).source,
    p_periodicity_data(p_number_periodicity_data).db_column_name,
    p_periodicity_data(p_number_periodicity_data).periodicity_type,
    p_periodicity_data(p_number_periodicity_data).period_type_id,
    p_periodicity_data(p_number_periodicity_data).record_type_id,
    p_periodicity_data(p_number_periodicity_data).xtd_pattern;
    exit when c1%notfound;
    p_number_periodicity_data:=p_number_periodicity_data+1;
    p_periodicity_data.extend;
  end loop;
  p_number_periodicity_data:=p_number_periodicity_data-1;
  close c1;
  g_periodicity_id_for_type(1):=get_periodicity_for_type(1,p_periodicity_data,p_number_periodicity_data);
  g_periodicity_id_for_type(2):=get_periodicity_for_type(2,p_periodicity_data,p_number_periodicity_data);
  g_periodicity_id_for_type(3):=get_periodicity_for_type(3,p_periodicity_data,p_number_periodicity_data);
  g_periodicity_id_for_type(4):=get_periodicity_for_type(4,p_periodicity_data,p_number_periodicity_data);
  g_periodicity_id_for_type(5):=get_periodicity_for_type(5,p_periodicity_data,p_number_periodicity_data);
  g_periodicity_id_for_type(7):=get_periodicity_for_type(7,p_periodicity_data,p_number_periodicity_data);
  g_periodicity_id_for_type(9):=get_periodicity_for_type(9,p_periodicity_data,p_number_periodicity_data);
  ---------------------------------------------------------------------
  if p_calendar_type=0 then --this is BSC calendar
    for i in 1..p_number_periodicity_data loop
      if p_periodicity_data(i).periodicity_type=1 then
        p_periodicity_data(i).period_type_id:=128;
        p_periodicity_data(i).record_type_id:=1024;
        p_periodicity_data(i).xtd_pattern:=null;
      elsif p_periodicity_data(i).periodicity_type=2 then
        p_periodicity_data(i).period_type_id:=8192;
        p_periodicity_data(i).record_type_id:=8192;
        p_periodicity_data(i).xtd_pattern:=null;
      elsif p_periodicity_data(i).periodicity_type=3 then
        p_periodicity_data(i).period_type_id:=64;
        p_periodicity_data(i).record_type_id:=64;
        p_periodicity_data(i).xtd_pattern:=null;
      elsif p_periodicity_data(i).periodicity_type=4 then
        p_periodicity_data(i).period_type_id:=4096;
        p_periodicity_data(i).record_type_id:=4096;
        p_periodicity_data(i).xtd_pattern:=null;
      elsif p_periodicity_data(i).periodicity_type=5 then
        p_periodicity_data(i).period_type_id:=32;
        p_periodicity_data(i).record_type_id:=32;
        p_periodicity_data(i).xtd_pattern:=null;
      elsif p_periodicity_data(i).periodicity_type=7 then
        p_periodicity_data(i).period_type_id:=16;
        p_periodicity_data(i).record_type_id:=16;
        p_periodicity_data(i).xtd_pattern:=null;
      elsif p_periodicity_data(i).periodicity_type=9 then
        p_periodicity_data(i).period_type_id:=1;
        p_periodicity_data(i).record_type_id:=1;
        p_periodicity_data(i).xtd_pattern:=null;
      else --custom periodicities
        --algo to find the record type and pattern
        l_custom_count:=l_custom_count+1;
        p_periodicity_data(i).period_type_id:=16384*l_custom_count;
        p_periodicity_data(i).record_type_id:=p_periodicity_data(i).period_type_id;
        p_periodicity_data(i).xtd_pattern:=null;
      end if;
    end loop;
  end if;
  if g_debug then
    for i in 1..p_number_periodicity_data loop
      write_to_log_file(p_periodicity_data(i).periodicity_id||' '||p_periodicity_data(i).source||' '||
      p_periodicity_data(i).db_column_name||' '||p_periodicity_data(i).periodicity_type||' '||
      p_periodicity_data(i).period_type_id||' '||p_periodicity_data(i).record_type_id||' '||
      p_periodicity_data(i).xtd_pattern);
    end loop;
  end if;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in get_periodicity_data '||sqlerrm);
  return false;
End;

function set_xtd_pattern(
p_calendar_id number,
p_periodicity_data in out nocopy cal_periodicity_table,
p_number_periodicity_data number,
p_hier BSC_IM_UTILS.varchar_tabletype,
p_hier_type BSC_IM_UTILS.varchar_tabletype,
p_number_hier number
)return boolean is
l_pattern BSC_IM_UTILS.varchar_tabletype;
l_dbi_hier varchar2(400);
l_pattern_sum number;
Begin
  if g_debug then
    write_to_log_file_n('In set_xtd_pattern');
  end if;
  --first: set the pattern for each std and custom periodicity
  for i in 1..p_number_periodicity_data loop
    l_pattern(i):=null;
    for j in 1..p_number_hier loop
      if p_hier_type(j)='Std' or p_hier_type(j)='Custom' then
        l_pattern_sum:=get_xtd_pattern(p_periodicity_data(i).periodicity_id,p_hier(j),
        p_periodicity_data,p_number_periodicity_data);
        if l_pattern_sum is not null and l_pattern_sum>0 then
          l_pattern(i):=l_pattern(i)||','||p_hier(j)||',:'||l_pattern_sum||';';
        end if;
      end if;
    end loop;
  end loop;
  for i in 1..p_number_hier loop
    if p_hier_type(i)='DBI' then
      l_dbi_hier:=','||p_hier(i)||',';
      exit;
    end if;
  end loop;
  --DBI hier goes last
  --there is no entry for semester or bimester
  for i in 1..p_number_periodicity_data loop
    if p_periodicity_data(i).periodicity_type=1 then
      l_pattern(i):=l_pattern(i)||l_dbi_hier||':119;';
    elsif p_periodicity_data(i).periodicity_type=3 then
      l_pattern(i):=l_pattern(i)||l_dbi_hier||':55;';
    elsif p_periodicity_data(i).periodicity_type=5 then
      l_pattern(i):=l_pattern(i)||l_dbi_hier||':23;';
    elsif p_periodicity_data(i).periodicity_type=7 then
      l_pattern(i):=l_pattern(i)||l_dbi_hier||':11;';
    elsif p_periodicity_data(i).periodicity_type=9 then
      l_pattern(i):=l_pattern(i)||l_dbi_hier||':1143;';
    end if;
  end loop;
  for i in 1..p_number_periodicity_data loop
    p_periodicity_data(i).xtd_pattern:=l_pattern(i);
  end loop;
  --update bsc_sys_periodicities table
  for i in 1..p_number_periodicity_data loop
    execute immediate 'update bsc_sys_periodicities set period_type_id=:1,'||
    'record_type_id=:2,xtd_pattern=:3 '||
    'where calendar_id=:4 and periodicity_id=:5' using p_periodicity_data(i).period_type_id,
    p_periodicity_data(i).record_type_id,p_periodicity_data(i).xtd_pattern,p_calendar_id,
    p_periodicity_data(i).periodicity_id;
  end loop;
  commit;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in set_xtd_pattern '||sqlerrm);
  return false;
End;

function get_xtd_pattern(
p_periodicity_id number,
p_hier varchar2,
p_periodicity_data cal_periodicity_table,
p_number_periodicity_data number
) return number is
l_pattern_sum number;
l_periodicity BSC_IM_UTILS.number_tabletype;
l_number_periodicity number;
--
l_start number;
Begin

  --see if the periodicity is in the hier, then look at the periodicities below and calculate the pattern
  l_pattern_sum:=0;
  if BSC_IM_UTILS.parse_values(p_hier,',',l_periodicity,l_number_periodicity)=false then
    return null;
  end if;
  for i in 1..l_number_periodicity loop
    if l_periodicity(i)=p_periodicity_id then
      if i=l_number_periodicity then --this is day, we need inception to date
        l_start:=1;
      else
        l_start:=i+1;
      end if;
      for j in l_start..l_number_periodicity loop
        for k in 1..p_number_periodicity_data loop
          if p_periodicity_data(k).periodicity_id=l_periodicity(j) then
            l_pattern_sum:=l_pattern_sum+p_periodicity_data(k).record_type_id;
            exit;
          end if;
        end loop;
      end loop;
      exit;
    end if;
  end loop;
  return l_pattern_sum;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('In get_xtd_pattern, p_periodicity_id='||p_periodicity_id||',p_hier='||p_hier);
  write_to_log_file_n('Exception in get_xtd_pattern '||sqlerrm);
  return null;
End;

function built_hier(
p_calendar_id number,
p_calendar_type number,
p_periodicity_data cal_periodicity_table,
p_number_periodicity_data number,
p_hier out nocopy BSC_IM_UTILS.varchar_tabletype,
p_hier_type out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_hier out nocopy number
)return boolean is
--------------------------
l_parent_hier BSC_IM_UTILS.number_tabletype;
l_child_hier BSC_IM_UTILS.number_tabletype;
l_parent_type BSC_IM_UTILS.varchar_tabletype;
l_looked_at BSC_IM_UTILS.boolean_tabletype;
l_number_hier number;
--------------------------
l_num_table BSC_IM_UTILS.number_tabletype;
l_number_num_table number;
--------------------------
l_custom_periodicity BSC_IM_UTILS.number_tabletype;
l_number_custom_periodicity number;
l_custom_parent BSC_IM_UTILS.number_tabletype;
l_custom_child BSC_IM_UTILS.number_tabletype;
l_custom_flag BSC_IM_UTILS.boolean_tabletype;
l_number_custom_hier number;
--------------------------
l_seed number;
--------------------------
Begin
  ---------------------------------------------------------------------
  --for all these periodicities, construct the hierarchies
  p_number_hier:=0;
  l_number_hier:=0;
  --make the std parent child relations
  --p_calendar_type=1 means DBI time calendar, 0 means BSC
  if p_calendar_type=0 then
    l_parent_hier(1):=g_periodicity_id_for_type(1);
    l_child_hier(1):=g_periodicity_id_for_type(3);
    l_parent_type(1):='Std';
    l_parent_hier(2):=g_periodicity_id_for_type(1);
    l_child_hier(2):=g_periodicity_id_for_type(2);
    l_parent_type(2):='Std';
    l_parent_hier(3):=g_periodicity_id_for_type(1);
    l_child_hier(3):=g_periodicity_id_for_type(7);
    l_parent_type(3):='Std';
    l_parent_hier(4):=g_periodicity_id_for_type(2);
    l_child_hier(4):=g_periodicity_id_for_type(3);
    l_parent_type(4):='Std';
    l_parent_hier(5):=g_periodicity_id_for_type(2);
    l_child_hier(5):=g_periodicity_id_for_type(4);
    l_parent_type(5):='Std';
    l_parent_hier(6):=g_periodicity_id_for_type(3);
    l_child_hier(6):=g_periodicity_id_for_type(5);
    l_parent_type(6):='Std';
    l_parent_hier(7):=g_periodicity_id_for_type(4);
    l_child_hier(7):=g_periodicity_id_for_type(5);
    l_parent_type(7):='Std';
    l_parent_hier(8):=g_periodicity_id_for_type(5);
    l_child_hier(8):=g_periodicity_id_for_type(9);
    l_parent_type(8):='Std';
    l_parent_hier(9):=g_periodicity_id_for_type(7);
    l_child_hier(9):=g_periodicity_id_for_type(9);
    l_parent_type(9):='Std';
    l_number_hier:=9;
  end if;
  l_number_custom_periodicity:=0;
  --p_calendar_type=2 is DBI ent calendar
  for i in 1..p_number_periodicity_data loop
    if (p_calendar_type=0 and p_periodicity_data(i).periodicity_type=0) or p_calendar_type in(1,2) then --custom periodicity
      l_number_hier:=l_number_hier+1;
      l_parent_hier(l_number_hier):=p_periodicity_data(i).periodicity_id;
      l_child_hier(l_number_hier):=p_periodicity_data(i).source;
      l_parent_type(l_number_hier):='Custom';
      l_number_custom_periodicity:=l_number_custom_periodicity+1;
      l_custom_periodicity(l_number_custom_periodicity):=p_periodicity_data(i).periodicity_id;
    end if;
  end loop;
  if g_debug then
    write_to_log_file_n('The parent child periodicities before bringing in full custom relations');
    for i in 1..l_number_hier loop
      write_to_log_file(l_parent_hier(i)||'('||l_parent_type(i)||') '||l_child_hier(i));
    end loop;
  end if;
  --for custom periodicities, we need to set the parent correctly
  l_number_custom_hier:=0;
  for i in 1..p_number_periodicity_data loop
    if p_periodicity_data(i).periodicity_type<>0 then
      for j in 1..l_number_custom_periodicity loop
        if BSC_IM_UTILS.parse_and_find(p_periodicity_data(i).source,',',l_custom_periodicity(j)) then
          l_number_custom_hier:=l_number_custom_hier+1;
          l_custom_parent(l_number_custom_hier):=p_periodicity_data(i).periodicity_id;
          l_custom_child(l_number_custom_hier):=l_custom_periodicity(j);
          l_custom_flag(l_number_custom_hier):=true;
        end if;
      end loop;
    end if;
  end loop;
  if g_debug then
    write_to_log_file_n('The custom parent child');
    for i in 1..l_number_custom_hier loop
      write_to_log_file(l_custom_parent(i)||' '||l_custom_child(i));
    end loop;
  end if;
  --now see if we can eliminate some
  for i in 1..l_number_custom_hier loop
    if BSC_IM_UTILS.in_array(l_child_hier,l_number_hier,l_custom_child(i)) then
      l_custom_flag(i):=false;
    else
      for j in 1..l_number_custom_hier loop
        if i<>j and l_custom_child(i)=l_custom_child(j) and l_custom_parent(i)<l_custom_parent(j) then
          l_custom_flag(i):=false;
        end if;
      end loop;
    end if;
  end loop;
  if g_debug then
    write_to_log_file_n('After eliminate, the custom parent child');
    for i in 1..l_number_custom_hier loop
      if l_custom_flag(i) then
        write_to_log_file(l_custom_parent(i)||' '||l_custom_child(i));
      end if;
    end loop;
  end if;
  for i in 1..l_number_custom_hier loop
    if l_custom_flag(i) then
      l_number_hier:=l_number_hier+1;
      l_parent_hier(l_number_hier):=l_custom_parent(i);
      l_child_hier(l_number_hier):=l_custom_child(i);
      l_parent_type(l_number_hier):='Std';
    end if;
  end loop;
  --build the hier
  --first get the seed
  l_seed:=0;
  if p_calendar_type=0 then
    l_seed:=l_parent_hier(1);
  else
    for i in 1..p_number_periodicity_data loop
      if p_periodicity_data(i).periodicity_type<>0 then
        if p_periodicity_data(i).periodicity_id>l_seed then
          l_seed:=p_periodicity_data(i).periodicity_id;
        end if;
      end if;
    end loop;
  end if;
  if g_debug then
    write_to_log_file_n('seed='||l_seed);
  end if;
  if built_hier_rec(
    l_seed,
    l_parent_hier,
    l_child_hier,
    l_parent_type,
    l_number_hier,
    p_hier,
    p_hier_type,
    p_number_hier)=false then
    return false;
  end if;
  if g_debug then
    write_to_log_file_n('The hierarchies generated recursively');
    for i in 1..p_number_hier loop
      write_to_log_file(p_hier(i)||' '||p_hier_type(i));
    end loop;
  end if;
  if p_calendar_type=0 then
    p_number_hier:=p_number_hier+1;
    p_hier_type(p_number_hier):='DBI';
    p_hier(p_number_hier):=g_periodicity_id_for_type(1)||','||
    g_periodicity_id_for_type(3)||','||g_periodicity_id_for_type(5)||','||g_periodicity_id_for_type(7)||','||
    g_periodicity_id_for_type(9);
  elsif p_calendar_type=2 then --DBI ent calendar
    p_number_hier:=p_number_hier+1;
    p_hier_type(p_number_hier):='DBI';
    p_hier(p_number_hier):=g_periodicity_id_for_type(1)||','||
    g_periodicity_id_for_type(3)||','||g_periodicity_id_for_type(5)||','||g_periodicity_id_for_type(7)||','||
    g_periodicity_id_for_type(9);
  end if;
  if g_debug then
    write_to_log_file_n('The Final list of hierarchies');
    for i in 1..p_number_hier loop
      write_to_log_file(p_hier(i)||' '||p_hier_type(i));
    end loop;
  end if;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in built_hier '||sqlerrm);
  return false;
End;

function built_hier_rec(
p_parent number,
p_parent_hier BSC_IM_UTILS.number_tabletype,
p_child_hier BSC_IM_UTILS.number_tabletype,
p_parent_type BSC_IM_UTILS.varchar_tabletype,
p_number_rel number,
p_hier out nocopy BSC_IM_UTILS.varchar_tabletype,
p_hier_type out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_hier out nocopy number
)return boolean is
-------
l_hier BSC_IM_UTILS.varchar_tabletype;
l_hier_type BSC_IM_UTILS.varchar_tabletype;
l_number_hier number;
----
l_found boolean;
----
Begin
  p_number_hier:=0;
  l_found:=false;
  for i in 1..p_number_rel loop
    if p_parent_hier(i)=p_parent then
      l_found:=true;
      if built_hier_rec(p_child_hier(i),p_parent_hier,p_child_hier,p_parent_type,p_number_rel,l_hier,l_hier_type,
        l_number_hier)=false then
        return false;
      end if;
      for j in 1..l_number_hier loop
        p_number_hier:=p_number_hier+1;
        if l_hier(j) is not null then
          p_hier(p_number_hier):=p_parent||','||l_hier(j);
        else
          p_hier(p_number_hier):=p_parent;
        end if;
        if p_parent_type(i)='Custom' or l_hier_type(j)='Custom' then
          p_hier_type(p_number_hier):='Custom';
        else
          p_hier_type(p_number_hier):='Std';
        end if;
      end loop;
    end if;
  end loop;
  if l_found=false then --for day level
    p_number_hier:=p_number_hier+1;
    p_hier(p_number_hier):=p_parent;
    p_hier_type(p_number_hier):='Std';
  end if;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in built_hier_rec '||sqlerrm);
  return false;
End;


function get_periodicity_for_type(
p_periodicity_type number,
p_periodicity_data cal_periodicity_table,
p_number_periodicity_data number
)return number is
Begin
  for i in 1..p_number_periodicity_data loop
    if p_periodicity_data(i).periodicity_type=p_periodicity_type then
      return p_periodicity_data(i).periodicity_id;
    end if;
  end loop;
  return null;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in get_periodicity_for_type '||sqlerrm);
  return null;
End;

function get_period_type_id_for_period(
p_periodicity_id number,
p_periodicity_data cal_periodicity_table,
p_number_periodicity_data number
)return number is
Begin
  for i in 1..p_number_periodicity_data loop
    if p_periodicity_data(i).periodicity_id=p_periodicity_id then
      return p_periodicity_data(i).period_type_id;
    end if;
  end loop;
  return null;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in get_period_type_id_for_period '||sqlerrm);
  return null;
End;

function get_period_type_id_for_period(
p_periodicity_id number
)return number is
cursor c1(p_periodicity number) is select period_type_id from bsc_sys_periodicities where
periodicity_id=p_periodicity;
l_period_type_id number;
Begin
  if g_debug then
    write_to_log_file_n('select period_type_id from bsc_sys_periodicities where periodicity_id='||
    p_periodicity_id);
  end if;
  open c1(p_periodicity_id);
  fetch c1 into l_period_type_id;
  close c1;
  return l_period_type_id;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in get_period_type_id_for_period '||sqlerrm);
  return null;
End;



/*
This is for all hierarchies that rollup.
Cannot be used for Y Q M W D. W does not rollup to M.
*/
function load_reporting_calendar(
p_calendar_id number,
p_calendar_type varchar2,
p_hierarchy varchar2,
p_hierarchy_type varchar2,
p_periodicity_data cal_periodicity_table,
p_number_periodicity_data number
)return boolean is
-----------------------------
l_periods BSC_IM_UTILS.number_tabletype;
l_period_record_type BSC_IM_UTILS.number_tabletype;
l_period_period_type BSC_IM_UTILS.number_tabletype;
l_period_periodicity_id BSC_IM_UTILS.number_tabletype;
l_period_column BSC_IM_UTILS.varchar_tabletype;
l_number_periods number;
-----------------------------
l_stmt varchar2(32750);
randomString varchar2(20);
l_count number;
newline varchar2(10);
-----------------------------
Begin
  newline:='
';
  if g_debug then
    write_to_log_file_n('In load_reporting_calendar, p_calendar_id='||p_calendar_id||','||
    'p_calendar_type='||p_calendar_type||',p_hierarchy='||p_hierarchy||',p_hierarchy_type='||p_hierarchy_type||
    get_time);
  end if;
  if BSC_im_utils.parse_values(p_hierarchy,',',l_periods,l_number_periods)=false then
    return false;
  end if;
  --for these periods get the record_type_id
  --for each periodicity, there is one record type id which is the same as
  --periodicity_id
  for i in 1..l_number_periods loop
    for j in 1..p_number_periodicity_data loop
      if p_periodicity_data(j).periodicity_id=l_periods(i) then
        l_period_column(i):=p_periodicity_data(j).db_column_name;
        l_period_record_type(i):=p_periodicity_data(j).record_type_id;
        l_period_period_type(i):=p_periodicity_data(j).period_type_id;
        l_period_periodicity_id(i):=p_periodicity_data(j).periodicity_id;
        exit;
      end if;
    end loop;
  end loop;
  if g_debug then
    write_to_log_file_n('periods record_type and db_column_name');
    for i in 1..l_number_periods loop
      write_to_log_file(l_periods(i)||' '||l_period_record_type(i)||' '||l_period_column(i));
    end loop;
  end if;
  -------------------------
  --we need to create a function dynamically and execute it.
  select to_char(systimestamp, 'HHMISSFF') into randomString from dual; --Bug 4027813
  l_stmt:='create or replace procedure ld_rpt_cal_'||randomString||' as
  type cal_record is record(calendar_year number,calendar_month number,calendar_day number'||newline;
  for i in 1..l_number_periods loop
    l_stmt:=l_stmt||','||l_period_column(i)||' number';
  end loop;
  l_stmt:=l_stmt||');'||newline||
  'type cal_record_table is table of cal_record;'||newline||'l_cal_records cal_record_table;'||newline||
  'l_number_cal_records number;'||newline||
  'cursor c1 is select calendar_year,calendar_month,calendar_day'||newline;
  for i in 1..l_number_periods loop
    l_stmt:=l_stmt||','||l_period_column(i);
  end loop;
  l_stmt:=l_stmt||'
  from bsc_db_calendar where calendar_id='||p_calendar_id||' order by calendar_year,calendar_month,calendar_day;'||
  newline;
  --build the variables that will be something like quarter for YTD, month for YTD and day for YTD etc
  for i in 1..l_number_periods loop
    l_stmt:=l_stmt||'l_'||l_period_column(1)||'_'||l_period_column(i)||' BSC_IM_UTILS.number_tabletype;'||newline;
    l_stmt:=l_stmt||'l_num_'||l_period_column(1)||'_'||l_period_column(i)||' number:=0;'||newline;
    l_stmt:=l_stmt||'l_prev_'||l_period_column(1)||'_'||l_period_column(i)||' number:=null;'||newline;
    l_stmt:=l_stmt||'l_'||l_period_column(i)||'_period_count BSC_IM_UTILS.number_tabletype;'||newline;
  end loop;
  l_stmt:=l_stmt||'l_final_report_date BSC_IM_UTILS.date_tabletype;
  l_final_period BSC_IM_UTILS.number_tabletype;
  l_final_year BSC_IM_UTILS.number_tabletype;
  l_final_period_type_id BSC_IM_UTILS.number_tabletype;
  l_final_periodicity_id BSC_IM_UTILS.number_tabletype;
  l_final_period_flag BSC_IM_UTILS.number_tabletype;
  l_final_period_count BSC_IM_UTILS.number_tabletype;
  l_num_final number:=0;
  -------------------
  begin
  l_number_cal_records:=1;
  l_cal_records:=cal_record_table();
  l_cal_records.extend;
  open c1;
  loop
  fetch c1 into l_cal_records(l_number_cal_records).calendar_year,
  l_cal_records(l_number_cal_records).calendar_month,l_cal_records(l_number_cal_records).calendar_day'||newline;
  for i in 1..l_number_periods loop
    l_stmt:=l_stmt||',l_cal_records(l_number_cal_records).'||l_period_column(i);
  end loop;
  l_stmt:=l_stmt||';
  exit when c1%notfound;
  l_number_cal_records:=l_number_cal_records+1;
  l_cal_records.extend;
  end loop;
  l_number_cal_records:=l_number_cal_records-1;
  close c1;
  l_num_final:=0; '||newline;
  for i in 1..l_number_periods loop
    l_stmt:=l_stmt||'l_'||l_period_column(i)||'_period_count(1):=0;'||newline;
  end loop;
  l_stmt:=l_stmt||'for i in 1..l_number_cal_records loop '||newline;
  l_count:=0;
  /*
  because these periodicities rollup, we need to do all the calculations only for YTD.
  QTD, MTD etc are already a part of it and all we need is the correct pattern to get
  the XTD value
  */
  for i in 1..l_number_periods-1 loop
    --for each of : Q of YTD, M of YTD
    if l_count=0 then
      l_count:=l_count+1;
      l_stmt:=l_stmt||'if ';
    else
      l_stmt:=l_stmt||'elsif ';
    end if;
    l_stmt:=l_stmt||'l_prev_'||l_period_column(1)||'_'||l_period_column(i)||' is not null and '||
    'l_prev_'||l_period_column(1)||'_'||l_period_column(i)||'<>l_cal_records(i).'||l_period_column(i)||' then'||newline;
    --add the new periodicity to the contribution
    l_stmt:=l_stmt||'l_num_'||l_period_column(1)||'_'||l_period_column(i)||':='||
    'l_num_'||l_period_column(1)||'_'||l_period_column(i)||'+1;'||newline||
    'l_'||l_period_column(1)||'_'||l_period_column(i)||'('||'l_num_'||l_period_column(1)||'_'||l_period_column(i)||
    '):=l_prev_'||l_period_column(1)||'_'||l_period_column(i)||';'||newline;
    l_stmt:=l_stmt||'l_'||l_period_column(i)||'_period_count(l_num_'||l_period_column(1)||'_'||l_period_column(i)||
    '+1):=0;'||newline;
    for j in i+1..l_number_periods loop
      --if Q is not the same for YTD, reset M for YTD
      l_stmt:=l_stmt||'l_'||l_period_column(1)||'_'||l_period_column(j)||'.delete;'||newline;
      l_stmt:=l_stmt||'l_num_'||l_period_column(1)||'_'||l_period_column(j)||':=0;'||newline;
      l_stmt:=l_stmt||'l_'||l_period_column(j)||'_period_count.delete;'||newline;
      l_stmt:=l_stmt||'l_'||l_period_column(j)||'_period_count(1):=0;'||newline;
    end loop;
  end loop;----for each of the periodicity say in Y Q M D
  if l_count>0 then
    l_stmt:=l_stmt||'end if;'||newline;
  end if;
  --increment the day
  l_stmt:=l_stmt||'--add period day counts'||newline;
  for i in 1..l_number_periods-1 loop
    l_stmt:=l_stmt||'l_'||l_period_column(i)||'_period_count('||
    'l_num_'||l_period_column(1)||'_'||l_period_column(i)||'+1):='||
    'l_'||l_period_column(i)||'_period_count('||
    'l_num_'||l_period_column(1)||'_'||l_period_column(i)||'+1)+1;'||newline;
  end loop;
  --for day, day count is always 1
  l_stmt:=l_stmt||'l_'||l_period_column(l_number_periods)||'_period_count('||
    'l_num_'||l_period_column(1)||'_'||l_period_column(l_number_periods)||'+1):=1;'||newline;
  l_stmt:=l_stmt||'--------------------'||newline;
  l_stmt:=l_stmt||'l_num_'||l_period_column(1)||'_'||l_period_column(l_number_periods)||':='||
  'l_num_'||l_period_column(1)||'_'||l_period_column(l_number_periods)||'+1;'||newline||
  'l_'||l_period_column(1)||'_'||l_period_column(l_number_periods)||'('||
  'l_num_'||l_period_column(1)||'_'||l_period_column(l_number_periods)||'):=l_cal_records(i).'||
  l_period_column(l_number_periods)||';'||newline;
  l_stmt:=l_stmt||'--------------------'||newline;
  --add the contribution of each period to the XTD
  --i starts from 2. 1 is year. dont add year contribution.
  for i in 2..l_number_periods loop
    l_stmt:=l_stmt||'for j in 1..l_num_'||l_period_column(1)||'_'||l_period_column(i)||' loop '||newline||
    'l_num_final:=l_num_final+1;'||newline;
    l_stmt:=l_stmt||'l_final_report_date(l_num_final):=to_date('||
    'l_cal_records(i).calendar_month||''/''||l_cal_records(i).calendar_day||''/''||'||
    'l_cal_records(i).calendar_year,'''||
    'MM/DD/YYYY'');'||newline;
    l_stmt:=l_stmt||'l_final_period(l_num_final):=l_'||l_period_column(1)||'_'||l_period_column(i)||
    '(j);'||newline;
    l_stmt:=l_stmt||'l_final_year(l_num_final):=l_cal_records(i).year;'||newline;
    l_stmt:=l_stmt||'l_final_period_type_id(l_num_final):='||l_period_period_type(i)||';'||newline;
    l_stmt:=l_stmt||'l_final_periodicity_id(l_num_final):='||l_period_periodicity_id(i)||';'||newline;
    l_stmt:=l_stmt||'l_final_period_count(l_num_final):=l_'||l_period_column(i)||'_period_count(j);'||newline;
    if i=l_number_periods then
      l_stmt:=l_stmt||'if j=l_num_'||l_period_column(1)||'_'||l_period_column(i)||' then '||newline;
      l_stmt:=l_stmt||'  l_final_period_flag(l_num_final):=1;'||newline;
      l_stmt:=l_stmt||'else '||newline||' l_final_period_flag(l_num_final):=0;'||newline;
      l_stmt:=l_stmt||'end if;'||newline;
    else
      l_stmt:=l_stmt||'l_final_period_flag(l_num_final):=0;'||newline;
    end if;
    l_stmt:=l_stmt||'end loop;'||newline;
    l_stmt:=l_stmt||'---------'||newline;
  end loop;
  --set the prev periods
  for i in 1..l_number_periods loop
    l_stmt:=l_stmt||'l_prev_'||l_period_column(1)||'_'||l_period_column(i)||':='||
    'l_cal_records(i).'||l_period_column(i)||';'||newline;
  end loop;
  l_stmt:=l_stmt||'---========================'||newline;
  l_stmt:=l_stmt||'end loop;--across each cal day'||newline;
  --insert into the reporting calendar table
  l_stmt:=l_stmt||'-------------------------'||newline||'---Insert into Reporting Calendar Table'||newline;
  --'record_type_id,periodicity_id,period_flag,period_day_count,hierarchy,created_by,last_update_by,'||
  l_stmt:=l_stmt||'forall i in 1..l_num_final'||newline||
  'insert into BSC_REPORTING_CALENDAR(calendar_id,calendar_type,report_date,period,year,period_type_id,'||newline||
  'record_type_id,periodicity_id,hierarchy,day_count,rolling_flag,created_by,last_update_by,'||newline||
  'last_update_login,creation_date,'||
  'last_update_date) values ('||newline||
  p_calendar_id||',''BSC'',l_final_report_date(i),l_final_period(i),l_final_year(i),'||
  'l_final_period_type_id(i),l_final_period_type_id(i),l_final_periodicity_id(i),'||
  ''','||p_hierarchy||','',l_final_period_count(i),''N'','||
  '0,0,0,sysdate,sysdate);'||newline;
  l_stmt:=l_stmt||'END;'||newline;
  if g_debug then
    write_to_log_file_n(l_stmt);
    write_to_log_file_n('length='||length(l_stmt));
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n('Load Reporting Calendar for calendar '||p_calendar_id||' and Hierarchy '||p_hierarchy||
    get_time);
  end if;
  begin
    l_stmt:='begin ld_rpt_cal_'||randomString||';end;';
    if g_debug then
      write_to_log_file_n(l_stmt);
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Loaded '||get_time);
    end if;
    commit;

  exception when others then
    BSC_IM_UTILS.g_status_message:=sqlerrm;
    g_status_message:=sqlerrm;
    write_to_log_file_n('Exception in load_reporting_calendar '||sqlerrm);
    return false;
  end;
  --drop the procedure
  l_stmt:='drop procedure ld_rpt_cal_'||randomString;
  if g_debug then
    write_to_log_file_n(l_stmt);
  end if;
  execute immediate l_stmt;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in load_reporting_calendar '||sqlerrm);
  return false;
End;

/*
This is for the DBI style reporting calendar hier. here we have Y Q M W D
*/
function load_reporting_calendar_DBI(
p_calendar_id number,
p_calendar_type varchar2,
p_hierarchy varchar2,
p_hierarchy_type varchar2,
p_calendar_data cal_record_table,
p_number_calendar_data number,
p_periodicity_data cal_periodicity_table,
p_number_periodicity_data number
)return boolean is
--------------------
l_year_year BSC_IM_UTILS.number_tabletype;
l_year_day_count BSC_IM_UTILS.number_tabletype;--number of days in year
l_prev_year_year number;
l_num_year_year number:=0;
l_year_year_PTD number;
l_year_year_PID number;
l_year_year_RTD number;
--
l_year_quarter BSC_IM_UTILS.number_tabletype;
l_quarter_day_count BSC_IM_UTILS.number_tabletype;
l_prev_year_quarter number;
l_num_year_quarter number:=0;
l_year_quarter_PTD number;
l_year_quarter_PID number;
l_year_quarter_RTD number;
--
l_year_month BSC_IM_UTILS.number_tabletype;
l_month_day_count BSC_IM_UTILS.number_tabletype;
l_prev_year_month number;
l_num_year_month number:=0;
l_year_month_PTD number;
l_year_month_PID number;
l_year_month_RTD number;
--
l_year_week BSC_IM_UTILS.number_tabletype;
l_week_day_count BSC_IM_UTILS.number_tabletype;
l_prev_year_week number;
l_num_year_week number:=0;
l_year_week_PTD number;
l_year_week_PID number;
l_year_week_RTD number;
--
l_year_day BSC_IM_UTILS.number_tabletype;
l_prev_year_day number;
l_num_year_day number:=0;
l_year_day_PTD number;
l_year_day_PID number;
l_year_day_RTD number;
--
--for week to date
l_week_day BSC_IM_UTILS.number_tabletype;
l_prev_week_day number;
l_num_week_day number:=0;
l_week_day_PTD number;
l_week_day_PID number;
l_week_day_RTD number;
-----
l_month_day BSC_IM_UTILS.number_tabletype; --carries record type id of 4 i.e mtd only
l_num_month_day number:=0;
-----
l_final_report_date BSC_IM_UTILS.date_tabletype;
l_final_period BSC_IM_UTILS.number_tabletype;
l_final_year BSC_IM_UTILS.number_tabletype;
l_final_period_type_id BSC_IM_UTILS.number_tabletype;
l_final_periodicity_id BSC_IM_UTILS.number_tabletype;
l_final_record_type_id BSC_IM_UTILS.number_tabletype;
l_final_day_count BSC_IM_UTILS.number_tabletype;
l_final_period_flag BSC_IM_UTILS.number_tabletype;
l_num_final number:=0;
--
Begin
  if g_debug then
    write_to_log_file_n('In load_reporting_calendar_DBI, p_calendar_id='||p_calendar_id||','||
    'p_calendar_type='||p_calendar_type||',p_hierarchy='||p_hierarchy||',p_hierarchy_type='||p_hierarchy_type||
    get_time);
  end if;
  --set the PTD and RTD
  for i in 1..p_number_periodicity_data loop
    if p_periodicity_data(i).periodicity_type=1 then
      l_year_year_PTD:=p_periodicity_data(i).period_type_id;
      l_year_year_PID:=p_periodicity_data(i).periodicity_id;
      l_year_year_RTD:=p_periodicity_data(i).record_type_id;
    elsif p_periodicity_data(i).periodicity_type=3 then
      l_year_quarter_PTD:=p_periodicity_data(i).period_type_id;
      l_year_quarter_PID:=p_periodicity_data(i).periodicity_id;
      l_year_quarter_RTD:=p_periodicity_data(i).record_type_id;
    elsif p_periodicity_data(i).periodicity_type=5 then
      l_year_month_PTD:=p_periodicity_data(i).period_type_id;
      l_year_month_PID:=p_periodicity_data(i).periodicity_id;
      l_year_month_RTD:=p_periodicity_data(i).record_type_id;
    elsif p_periodicity_data(i).periodicity_type=7 then
      l_year_week_PTD:=p_periodicity_data(i).period_type_id;
      l_year_week_PID:=p_periodicity_data(i).periodicity_id;
      l_year_week_RTD:=p_periodicity_data(i).record_type_id;
    elsif p_periodicity_data(i).periodicity_type=9 then
      l_year_day_PTD:=p_periodicity_data(i).period_type_id;
      l_year_day_PID:=p_periodicity_data(i).periodicity_id;
      l_year_day_RTD:=p_periodicity_data(i).record_type_id;
    end if;
  end loop;
  l_year_day_count(1):=0;
  l_quarter_day_count(1):=0;
  l_month_day_count(1):=0;
  l_week_day_count(1):=0;
  for i in 1..p_number_calendar_data loop
    if l_prev_year_year is not null and l_prev_year_year<>p_calendar_data(i).year then
      l_num_year_year:=l_num_year_year+1;
      l_year_year(l_num_year_year):=l_prev_year_year;
      l_year_day_count(l_num_year_year+1):=0;
      l_year_quarter.delete;
      l_quarter_day_count.delete;
      l_quarter_day_count(1):=0;
      l_num_year_quarter:=0;
      l_year_month.delete;
      l_month_day_count.delete;
      l_month_day_count(1):=0;
      l_num_year_month:=0;
      l_year_week.delete;
      l_week_day_count.delete;
      l_week_day_count(1):=0;
      l_num_year_week:=0;
      l_year_day.delete;
      l_num_year_day:=0;
      l_month_day.delete;
      l_num_month_day:=0;
    elsif l_prev_year_quarter is not null and l_prev_year_quarter<>p_calendar_data(i).quarter then
      l_num_year_quarter:=l_num_year_quarter+1;
      l_year_quarter(l_num_year_quarter):=l_prev_year_quarter;
      l_quarter_day_count(l_num_year_quarter+1):=0;
      l_year_month.delete;
      l_month_day_count.delete;
      l_month_day_count(1):=0;
      l_num_year_month:=0;
      l_year_week.delete;
      l_week_day_count.delete;
      l_week_day_count(1):=0;
      l_num_year_week:=0;
      l_year_day.delete;
      l_num_year_day:=0;
      l_month_day.delete;
      l_num_month_day:=0;
    elsif l_prev_year_month is not null and l_prev_year_month<>p_calendar_data(i).month then
      l_num_year_month:=l_num_year_month+1;
      l_year_month(l_num_year_month):=l_prev_year_month;
      l_month_day_count(l_num_year_month+1):=0;
      l_year_week.delete;
      l_week_day_count.delete;
      l_week_day_count(1):=0;
      l_num_year_week:=0;
      l_year_day.delete;
      l_num_year_day:=0;
      l_month_day.delete;
      l_num_month_day:=0;
    elsif l_prev_year_week is not null and l_prev_year_week<>p_calendar_data(i).week52 then
      --when week changes we dont reset l_year_day
      --we can include this week's contribution only if this week has all 7 days in it.
      if l_num_year_day>=7 then
        l_num_year_week:=l_num_year_week+1;
        l_year_week(l_num_year_week):=l_prev_year_week;
        l_week_day_count(l_num_year_week+1):=0;
        l_year_day.delete;
        l_num_year_day:=0;
      else
        l_num_month_day:=l_num_year_day;--these will carry record type of 4
        l_month_day:=l_year_day;
        l_year_day.delete;
        l_num_year_day:=0;
      end if;
    end if;
    if l_prev_year_week is not null and l_prev_year_week<>p_calendar_data(i).week52 then
      l_week_day.delete;
      l_num_week_day:=0;
      l_week_day_count(l_num_year_week+1):=0;
    end if;
    --load the previous years. this will actually work for all hierarchies
    for j in 1..l_num_year_year loop
      l_num_final:=l_num_final+1;
      l_final_report_date(l_num_final):=to_date(p_calendar_data(i).calendar_month||'/'||
      p_calendar_data(i).calendar_day||'/'||p_calendar_data(i).calendar_year,'MM/DD/YYYY');
      l_final_period(l_num_final):=l_year_year(j);
      l_final_year(l_num_final):=l_year_year(j);
      l_final_period_type_id(l_num_final):=l_year_year_PTD;
      l_final_periodicity_id(l_num_final):=l_year_year_PID;
      l_final_record_type_id(l_num_final):=l_year_year_RTD;
      l_final_period_flag(l_num_final):=0;
      l_final_day_count(l_num_final):=l_year_day_count(j);
    end loop;
    for j in 1..l_num_year_quarter loop
      l_num_final:=l_num_final+1;
      l_final_report_date(l_num_final):=to_date(p_calendar_data(i).calendar_month||'/'||
      p_calendar_data(i).calendar_day||'/'||p_calendar_data(i).calendar_year,'MM/DD/YYYY');
      l_final_period(l_num_final):=l_year_quarter(j);
      l_final_year(l_num_final):=p_calendar_data(i).year;
      l_final_period_type_id(l_num_final):=l_year_quarter_PTD;
      l_final_periodicity_id(l_num_final):=l_year_quarter_PID;
      l_final_record_type_id(l_num_final):=l_year_quarter_RTD;
      l_final_period_flag(l_num_final):=0;
      l_final_day_count(l_num_final):=l_quarter_day_count(j);
    end loop;
    for j in 1..l_num_year_month loop
      l_num_final:=l_num_final+1;
      l_final_report_date(l_num_final):=to_date(p_calendar_data(i).calendar_month||'/'||
      p_calendar_data(i).calendar_day||'/'||p_calendar_data(i).calendar_year,'MM/DD/YYYY');
      l_final_period(l_num_final):=l_year_month(j);
      l_final_year(l_num_final):=p_calendar_data(i).year;
      l_final_period_type_id(l_num_final):=l_year_month_PTD;
      l_final_periodicity_id(l_num_final):=l_year_month_PID;
      l_final_record_type_id(l_num_final):=l_year_month_RTD;
      l_final_period_flag(l_num_final):=0;
      l_final_day_count(l_num_final):=l_month_day_count(j);
    end loop;
    for j in 1..l_num_year_week loop
      l_num_final:=l_num_final+1;
      l_final_report_date(l_num_final):=to_date(p_calendar_data(i).calendar_month||'/'||
      p_calendar_data(i).calendar_day||'/'||p_calendar_data(i).calendar_year,'MM/DD/YYYY');
      l_final_period(l_num_final):=l_year_week(j);
      l_final_year(l_num_final):=p_calendar_data(i).year;
      l_final_period_type_id(l_num_final):=l_year_week_PTD;
      l_final_periodicity_id(l_num_final):=l_year_week_PID;
      l_final_record_type_id(l_num_final):=l_year_week_RTD;
      l_final_period_flag(l_num_final):=0;
      l_final_day_count(l_num_final):=l_week_day_count(j);
    end loop;
    /*
    29 M
    30 Tue
    31 Wed
    1 Th
    2 Fri
    3 Sat
    4 Sun
    5 Mon
    6 Tue
    in this case, when we are at 1, Th, 29,30,31,1 will contribute to wtd, 1 will contribute to wtd and mtd.
    when we are at 6, tue, 6 will contribute to wtd while 1,2,3,4,5 and 6 will contribute to mtd
    */
    for j in 1..l_num_year_day loop
      l_num_final:=l_num_final+1;
      l_final_report_date(l_num_final):=to_date(p_calendar_data(i).calendar_month||'/'||
      p_calendar_data(i).calendar_day||'/'||p_calendar_data(i).calendar_year,'MM/DD/YYYY');
      l_final_period(l_num_final):=l_year_day(j);
      l_final_year(l_num_final):=p_calendar_data(i).year;
      l_final_period_type_id(l_num_final):=l_year_day_PTD;
      l_final_periodicity_id(l_num_final):=l_year_day_PID;
      l_final_record_type_id(l_num_final):=2;
      l_final_period_flag(l_num_final):=0;
      l_final_day_count(l_num_final):=1;
    end loop;
    --now the week and month contributions
    for j in 1..l_num_week_day loop
      if BSC_IM_UTILS.in_array(l_year_day,l_num_year_day,l_week_day(j))=false then
        l_num_final:=l_num_final+1;
        l_final_report_date(l_num_final):=to_date(p_calendar_data(i).calendar_month||'/'||
        p_calendar_data(i).calendar_day||'/'||p_calendar_data(i).calendar_year,'MM/DD/YYYY');
        l_final_period(l_num_final):=l_week_day(j);
        l_final_year(l_num_final):=p_calendar_data(i).year;
        l_final_period_type_id(l_num_final):=l_year_day_PTD;
        l_final_periodicity_id(l_num_final):=l_year_day_PID;
        l_final_record_type_id(l_num_final):=8;--only contribute to WTD
        l_final_period_flag(l_num_final):=0;
        l_final_day_count(l_num_final):=1;
      end if;
    end loop;
    for j in 1..l_num_month_day loop
      l_num_final:=l_num_final+1;
      l_final_report_date(l_num_final):=to_date(p_calendar_data(i).calendar_month||'/'||
      p_calendar_data(i).calendar_day||'/'||p_calendar_data(i).calendar_year,'MM/DD/YYYY');
      l_final_period(l_num_final):=l_month_day(j);
      l_final_year(l_num_final):=p_calendar_data(i).year;
      l_final_period_type_id(l_num_final):=l_year_day_PTD;
      l_final_periodicity_id(l_num_final):=l_year_day_PID;
      l_final_record_type_id(l_num_final):=4;--only contribute to MTD
      l_final_period_flag(l_num_final):=0;
      l_final_day_count(l_num_final):=1;
    end loop;
    --add the day's contribution to year, qtr etc
    l_year_day_count(l_num_year_year+1):=l_year_day_count(l_num_year_year+1)+1;
    l_quarter_day_count(l_num_year_quarter+1):=l_quarter_day_count(l_num_year_quarter+1)+1;
    l_month_day_count(l_num_year_month+1):=l_month_day_count(l_num_year_month+1)+1;
    l_week_day_count(l_num_year_week+1):=l_week_day_count(l_num_year_week+1)+1;
    -----
    --add this day
    l_num_year_day:=l_num_year_day+1;
    l_year_day(l_num_year_day):=p_calendar_data(i).day365;
    ------
    l_num_final:=l_num_final+1;
    l_final_report_date(l_num_final):=to_date(p_calendar_data(i).calendar_month||'/'||
    p_calendar_data(i).calendar_day||'/'||p_calendar_data(i).calendar_year,'MM/DD/YYYY');
    l_final_period(l_num_final):=l_year_day(l_num_year_day);
    l_final_year(l_num_final):=p_calendar_data(i).year;
    l_final_period_type_id(l_num_final):=l_year_day_PTD;
    l_final_periodicity_id(l_num_final):=l_year_day_PID;
    l_final_record_type_id(l_num_final):=l_year_day_RTD;
    l_final_period_flag(l_num_final):=1;
    l_final_day_count(l_num_final):=1;
    ---------------------
    l_prev_year_year:=p_calendar_data(i).year;
    l_prev_year_quarter:=p_calendar_data(i).quarter;
    l_prev_year_month:=p_calendar_data(i).month;
    l_prev_year_week:=p_calendar_data(i).week52;
    l_prev_year_day:=p_calendar_data(i).day365;
    --
    --set the wtd parameters
    l_num_week_day:=l_num_week_day+1;
    l_week_day(l_num_week_day):=p_calendar_data(i).day365;
    --insert into the reporting calendar
  end loop;
  --dynamic sql to be compatible with 5.0.2
  --we need to make compatible with 8i.so have to have static sql. no need to
  --worry about 5.0.2
  forall i in 1..l_num_final
    execute immediate
    'insert into BSC_REPORTING_CALENDAR(calendar_id,calendar_type,report_date,
    period,year,period_type_id,record_type_id,periodicity_id,hierarchy,rolling_flag,day_count,
    created_by,last_update_by,last_update_login,creation_date,last_update_date) values(
    :1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11, :12, :13, :14, :15, :16)'
    using  p_calendar_id,'BSC',l_final_report_date(i),l_final_period(i),l_final_year(i),
    l_final_period_type_id(i),l_final_record_type_id(i),l_final_periodicity_id(i),
    ','||p_hierarchy||',','N',l_final_day_count(i),0,0,0,sysdate,sysdate;
  commit;

  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in load_reporting_calendar_DBI '||sqlerrm);
  return false;
End;

/*
This for supporting rolling XTD
Logic:
*/
function load_rpt_cal_DBI_rolling(
p_calendar_id number,
p_calendar_type varchar2,
p_hierarchy varchar2,
p_hierarchy_type varchar2,
p_calendar_data cal_record_table,
p_number_calendar_data number,
p_periodicity_data cal_periodicity_table,
p_number_periodicity_data number
)return boolean is
--------------------
l_rolling_flag varchar2(40);
--------------------
l_year_year BSC_IM_UTILS.number_tabletype;
l_year_day_count BSC_IM_UTILS.number_tabletype;--number of days in year
l_prev_year_year number;
l_num_year_year number:=0;
l_year_year_PTD number;
l_year_year_PID number;
l_year_year_RTD number;
--
l_year_quarter BSC_IM_UTILS.number_tabletype;
l_quarter_day_count BSC_IM_UTILS.number_tabletype;
l_prev_year_quarter number;
l_num_year_quarter number:=0;
l_year_quarter_PTD number;
l_year_quarter_PID number;
l_year_quarter_RTD number;
--
l_year_month BSC_IM_UTILS.number_tabletype;
l_month_day_count BSC_IM_UTILS.number_tabletype;
l_prev_year_month number;
l_num_year_month number:=0;
l_year_month_PTD number;
l_year_month_PID number;
l_year_month_RTD number;
--
l_year_week BSC_IM_UTILS.number_tabletype;
l_week_day_count BSC_IM_UTILS.number_tabletype;
l_prev_year_week number;
l_num_year_week number:=0;
l_year_week_PTD number;
l_year_week_PID number;
l_year_week_RTD number;
--
l_year_day BSC_IM_UTILS.number_tabletype;
l_prev_year_day number;
l_num_year_day number:=0;
l_year_day_PTD number;
l_year_day_PID number;
l_year_day_RTD number;
--
--for week to date
l_week_day BSC_IM_UTILS.number_tabletype;
l_prev_week_day number;
l_num_week_day number:=0;
l_week_day_PTD number;
l_week_day_PID number;
l_week_day_RTD number;
-----
l_month_day BSC_IM_UTILS.number_tabletype; --carries record type id of 4 i.e mtd only
l_num_month_day number:=0;
-----
l_final_report_date BSC_IM_UTILS.date_tabletype;
l_final_period BSC_IM_UTILS.number_tabletype;
l_final_year BSC_IM_UTILS.number_tabletype;
l_final_period_type_id BSC_IM_UTILS.number_tabletype;
l_final_periodicity_id BSC_IM_UTILS.number_tabletype;
l_final_record_type_id BSC_IM_UTILS.number_tabletype;
l_final_day_count BSC_IM_UTILS.number_tabletype;
l_final_period_flag BSC_IM_UTILS.number_tabletype;
l_num_final number:=0;
--
Begin
  if g_debug then
    write_to_log_file_n('In load_rpt_cal_DBI_rolling, p_calendar_id='||p_calendar_id||','||
    'p_calendar_type='||p_calendar_type||',p_hierarchy='||p_hierarchy||',p_hierarchy_type='||p_hierarchy_type||
    get_time);
  end if;
  l_rolling_flag:='Y';
  --set the PTD and RTD
  for i in 1..p_number_periodicity_data loop
    if p_periodicity_data(i).periodicity_type=1 then
      l_year_year_PTD:=p_periodicity_data(i).period_type_id;
      l_year_year_PID:=p_periodicity_data(i).periodicity_id;
      l_year_year_RTD:=p_periodicity_data(i).record_type_id;
    elsif p_periodicity_data(i).periodicity_type=3 then
      l_year_quarter_PTD:=p_periodicity_data(i).period_type_id;
      l_year_quarter_PID:=p_periodicity_data(i).periodicity_id;
      l_year_quarter_RTD:=p_periodicity_data(i).record_type_id;
    elsif p_periodicity_data(i).periodicity_type=5 then
      l_year_month_PTD:=p_periodicity_data(i).period_type_id;
      l_year_month_PID:=p_periodicity_data(i).periodicity_id;
      l_year_month_RTD:=p_periodicity_data(i).record_type_id;
    elsif p_periodicity_data(i).periodicity_type=7 then
      l_year_week_PTD:=p_periodicity_data(i).period_type_id;
      l_year_week_PID:=p_periodicity_data(i).periodicity_id;
      l_year_week_RTD:=p_periodicity_data(i).record_type_id;
    elsif p_periodicity_data(i).periodicity_type=9 then
      l_year_day_PTD:=p_periodicity_data(i).period_type_id;
      l_year_day_PID:=p_periodicity_data(i).periodicity_id;
      l_year_day_RTD:=p_periodicity_data(i).record_type_id;
    end if;
  end loop;
  l_year_day_count(1):=0;
  l_quarter_day_count(1):=0;
  l_month_day_count(1):=0;
  l_week_day_count(1):=0;
  --start from the last cal day and go to the first
  for i in reverse 1..p_number_calendar_data loop
    if l_prev_year_year is not null and l_prev_year_year<>p_calendar_data(i).year then
      l_num_year_year:=l_num_year_year+1;
      l_year_year(l_num_year_year):=l_prev_year_year;
      l_year_day_count(l_num_year_year+1):=0;
      l_year_quarter.delete;
      l_quarter_day_count.delete;
      l_quarter_day_count(1):=0;
      l_num_year_quarter:=0;
      l_year_month.delete;
      l_month_day_count.delete;
      l_month_day_count(1):=0;
      l_num_year_month:=0;
      l_year_week.delete;
      l_week_day_count.delete;
      l_week_day_count(1):=0;
      l_num_year_week:=0;
      l_year_day.delete;
      l_num_year_day:=0;
      l_month_day.delete;
      l_num_month_day:=0;
    elsif l_prev_year_quarter is not null and l_prev_year_quarter<>p_calendar_data(i).quarter then
      l_num_year_quarter:=l_num_year_quarter+1;
      l_year_quarter(l_num_year_quarter):=l_prev_year_quarter;
      l_quarter_day_count(l_num_year_quarter+1):=0;
      l_year_month.delete;
      l_month_day_count.delete;
      l_month_day_count(1):=0;
      l_num_year_month:=0;
      l_year_week.delete;
      l_week_day_count.delete;
      l_week_day_count(1):=0;
      l_num_year_week:=0;
      l_year_day.delete;
      l_num_year_day:=0;
      l_month_day.delete;
      l_num_month_day:=0;
    elsif l_prev_year_month is not null and l_prev_year_month<>p_calendar_data(i).month then
      l_num_year_month:=l_num_year_month+1;
      l_year_month(l_num_year_month):=l_prev_year_month;
      l_month_day_count(l_num_year_month+1):=0;
      l_year_week.delete;
      l_week_day_count.delete;
      l_week_day_count(1):=0;
      l_num_year_week:=0;
      l_year_day.delete;
      l_num_year_day:=0;
      l_month_day.delete;
      l_num_month_day:=0;
    elsif l_prev_year_week is not null and l_prev_year_week<>p_calendar_data(i).week52 then
      --when week changes we dont reset l_year_day
      --we can include this week's contribution only if this week has all 7 days in it.
      if l_num_year_day>=7 then
        l_num_year_week:=l_num_year_week+1;
        l_year_week(l_num_year_week):=l_prev_year_week;
        l_week_day_count(l_num_year_week+1):=0;
        l_year_day.delete;
        l_num_year_day:=0;
      else
        l_num_month_day:=l_num_year_day;--these will carry record type of 4
        l_month_day:=l_year_day;
        l_year_day.delete;
        l_num_year_day:=0;
      end if;
    end if;
    if l_prev_year_week is not null and l_prev_year_week<>p_calendar_data(i).week52 then
      l_week_day.delete;
      l_num_week_day:=0;
      l_week_day_count(l_num_year_week+1):=0;
    end if;
    for j in 1..l_num_year_quarter loop
      l_num_final:=l_num_final+1;
      l_final_report_date(l_num_final):=to_date(p_calendar_data(i).calendar_month||'/'||
      p_calendar_data(i).calendar_day||'/'||p_calendar_data(i).calendar_year,'MM/DD/YYYY');
      l_final_period(l_num_final):=l_year_quarter(j);
      l_final_year(l_num_final):=p_calendar_data(i).year;
      l_final_period_type_id(l_num_final):=l_year_quarter_PTD;
      l_final_periodicity_id(l_num_final):=l_year_quarter_PID;
      l_final_record_type_id(l_num_final):=l_year_quarter_RTD;
      l_final_period_flag(l_num_final):=0;
      l_final_day_count(l_num_final):=l_quarter_day_count(j);
    end loop;
    for j in 1..l_num_year_month loop
      l_num_final:=l_num_final+1;
      l_final_report_date(l_num_final):=to_date(p_calendar_data(i).calendar_month||'/'||
      p_calendar_data(i).calendar_day||'/'||p_calendar_data(i).calendar_year,'MM/DD/YYYY');
      l_final_period(l_num_final):=l_year_month(j);
      l_final_year(l_num_final):=p_calendar_data(i).year;
      l_final_period_type_id(l_num_final):=l_year_month_PTD;
      l_final_periodicity_id(l_num_final):=l_year_month_PID;
      l_final_record_type_id(l_num_final):=l_year_month_RTD;
      l_final_period_flag(l_num_final):=0;
      l_final_day_count(l_num_final):=l_month_day_count(j);
    end loop;
    for j in 1..l_num_year_week loop
      l_num_final:=l_num_final+1;
      l_final_report_date(l_num_final):=to_date(p_calendar_data(i).calendar_month||'/'||
      p_calendar_data(i).calendar_day||'/'||p_calendar_data(i).calendar_year,'MM/DD/YYYY');
      l_final_period(l_num_final):=l_year_week(j);
      l_final_year(l_num_final):=p_calendar_data(i).year;
      l_final_period_type_id(l_num_final):=l_year_week_PTD;
      l_final_periodicity_id(l_num_final):=l_year_week_PID;
      l_final_record_type_id(l_num_final):=l_year_week_RTD;
      l_final_period_flag(l_num_final):=0;
      l_final_day_count(l_num_final):=l_week_day_count(j);
    end loop;
    /*
    29 M
    30 Tue
    31 Wed
    1 Th
    2 Fri
    3 Sat
    4 Sun
    5 Mon
    6 Tue
    in this case, when we are at 1, Th, 29,30,31,1 will contribute to wtd, 1 will contribute to wtd and mtd.
    when we are at 6, tue, 6 will contribute to wtd while 1,2,3,4,5 and 6 will contribute to mtd
    */
    for j in 1..l_num_year_day loop
      l_num_final:=l_num_final+1;
      l_final_report_date(l_num_final):=to_date(p_calendar_data(i).calendar_month||'/'||
      p_calendar_data(i).calendar_day||'/'||p_calendar_data(i).calendar_year,'MM/DD/YYYY');
      l_final_period(l_num_final):=l_year_day(j);
      l_final_year(l_num_final):=p_calendar_data(i).year;
      l_final_period_type_id(l_num_final):=l_year_day_PTD;
      l_final_periodicity_id(l_num_final):=l_year_day_PID;
      l_final_record_type_id(l_num_final):=2;
      l_final_period_flag(l_num_final):=0;
      l_final_day_count(l_num_final):=1;
    end loop;
    --now the week and month contributions
    for j in 1..l_num_week_day loop
      if BSC_IM_UTILS.in_array(l_year_day,l_num_year_day,l_week_day(j))=false then
        l_num_final:=l_num_final+1;
        l_final_report_date(l_num_final):=to_date(p_calendar_data(i).calendar_month||'/'||
        p_calendar_data(i).calendar_day||'/'||p_calendar_data(i).calendar_year,'MM/DD/YYYY');
        l_final_period(l_num_final):=l_week_day(j);
        l_final_year(l_num_final):=p_calendar_data(i).year;
        l_final_period_type_id(l_num_final):=l_year_day_PTD;
        l_final_periodicity_id(l_num_final):=l_year_day_PID;
        l_final_record_type_id(l_num_final):=8;--only contribute to WTD
        l_final_period_flag(l_num_final):=0;
        l_final_day_count(l_num_final):=1;
      end if;
    end loop;
    for j in 1..l_num_month_day loop
      l_num_final:=l_num_final+1;
      l_final_report_date(l_num_final):=to_date(p_calendar_data(i).calendar_month||'/'||
      p_calendar_data(i).calendar_day||'/'||p_calendar_data(i).calendar_year,'MM/DD/YYYY');
      l_final_period(l_num_final):=l_month_day(j);
      l_final_year(l_num_final):=p_calendar_data(i).year;
      l_final_period_type_id(l_num_final):=l_year_day_PTD;
      l_final_periodicity_id(l_num_final):=l_year_day_PID;
      l_final_record_type_id(l_num_final):=4;--only contribute to MTD
      l_final_period_flag(l_num_final):=0;
      l_final_day_count(l_num_final):=1;
    end loop;
    --add the day's contribution to year, qtr etc
    l_year_day_count(l_num_year_year+1):=l_year_day_count(l_num_year_year+1)+1;
    l_quarter_day_count(l_num_year_quarter+1):=l_quarter_day_count(l_num_year_quarter+1)+1;
    l_month_day_count(l_num_year_month+1):=l_month_day_count(l_num_year_month+1)+1;
    l_week_day_count(l_num_year_week+1):=l_week_day_count(l_num_year_week+1)+1;
    -----
    --add this day
    l_num_year_day:=l_num_year_day+1;
    l_year_day(l_num_year_day):=p_calendar_data(i).day365;
    ------
    l_num_final:=l_num_final+1;
    l_final_report_date(l_num_final):=to_date(p_calendar_data(i).calendar_month||'/'||
    p_calendar_data(i).calendar_day||'/'||p_calendar_data(i).calendar_year,'MM/DD/YYYY');
    l_final_period(l_num_final):=l_year_day(l_num_year_day);
    l_final_year(l_num_final):=p_calendar_data(i).year;
    l_final_period_type_id(l_num_final):=l_year_day_PTD;
    l_final_periodicity_id(l_num_final):=l_year_day_PID;
    l_final_record_type_id(l_num_final):=l_year_day_RTD;
    l_final_period_flag(l_num_final):=1;
    l_final_day_count(l_num_final):=1;
    ---------------------
    l_prev_year_year:=p_calendar_data(i).year;
    l_prev_year_quarter:=p_calendar_data(i).quarter;
    l_prev_year_month:=p_calendar_data(i).month;
    l_prev_year_week:=p_calendar_data(i).week52;
    l_prev_year_day:=p_calendar_data(i).day365;
    --
    --set the wtd parameters
    l_num_week_day:=l_num_week_day+1;
    l_week_day(l_num_week_day):=p_calendar_data(i).day365;
    --insert into the reporting calendar
  end loop;
  --dynamic sql to be compatible with 5.0.2
  --we need to make compatible with 8i.so have to have static sql. no need to
  --worry about 5.0.2
  forall i in 1..l_num_final
    execute immediate
    'insert into BSC_REPORTING_CALENDAR(calendar_id,calendar_type,report_date,
    period,year,period_type_id,record_type_id,periodicity_id,hierarchy,rolling_flag,day_count,
    created_by,last_update_by,last_update_login,creation_date,last_update_date) values(
    :1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11, :12, :13, :14, :15, :16)'
    using
    p_calendar_id,'BSC',l_final_report_date(i),l_final_period(i),l_final_year(i),
    l_final_period_type_id(i),l_final_record_type_id(i),l_final_periodicity_id(i),
    ','||p_hierarchy||',',l_rolling_flag,l_final_day_count(i),0,0,0,sysdate,sysdate;
  commit;

  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in load_rpt_cal_DBI_rolling '||sqlerrm);
  return false;
End;

function get_reporting_calendar_name return varchar2 is
Begin
  return upper('bsc_db_report_struct');
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in get_reporting_calendar_name '||sqlerrm);
  return null;
End;

function get_dim_level_cols(
p_level varchar2,
p_columns out nocopy BSC_IM_UTILS.varchar_tabletype,
p_column_type out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_columns out nocopy number
)return boolean is
l_stmt varchar2(5000);
---------------------------------------------
cursor c1 (p_level_table_name varchar2)
is select column_name,column_type
from bsc_sys_dim_level_cols ,bsc_sys_dim_levels_b
where level_table_name=p_level_table_name
and bsc_sys_dim_level_cols.dim_level_id=bsc_sys_dim_levels_b.dim_level_id;
---------------------------------------------
Begin
  if g_debug then
    l_stmt:='select column_name,column_type '||
    'from bsc_sys_dim_level_cols ,bsc_sys_dim_levels_b '||
    'where level_table_name=:1 '||
    'and bsc_sys_dim_level_cols.dim_level_id=bsc_sys_dim_levels_b.dim_level_id ';
    write_to_log_file_n(l_stmt||' '||p_level);
  end if;
  p_number_columns:=1;
  open c1(p_level);
  loop
    fetch c1 into p_columns(p_number_columns),p_column_type(p_number_columns);
    exit when c1%notfound;
    p_number_columns:=p_number_columns+1;
  end loop;
  p_number_columns:=p_number_columns-1;
  close c1;
  if g_debug then
    write_to_log_file_n('Result');
    for i in 1..p_number_columns loop
      write_to_log_file(p_columns(i)||' '||p_column_type(i));
    end loop;
  end if;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in get_dim_level_cols '||sqlerrm);
  return false;
End;

function get_s_tables_for_mv(
p_mv varchar2,
p_s_tables out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_s_tables out nocopy number
)return boolean is
l_stmt varchar2(5000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
-----------------------------------
--Fix bug#3899842: use distinct
--cursor c1 (p_mv_name varchar2)
--is select distinct table_name from bsc_kpi_data_tables where mv_name=p_mv_name;
cursor c1 (p_mv_name_pattern varchar2)
is select distinct table_name from bsc_db_tables_rels
where substr(table_name, 1, length(p_mv_name_pattern))= p_mv_name_pattern;
-----------------------------------
l_pattern varchar2(100);
Begin
  p_number_s_tables:=1;
  if g_debug then
    l_stmt:='select table_name from bsc_kpi_data_tables where mv_name=:1';
    write_to_log_file_n(l_stmt||' using '||p_mv);
  end if;
  --open c1(p_mv);
  l_pattern := substr(p_mv, 1, instr(p_mv, '_', -1, 1));
  open c1(l_pattern);
  loop
    fetch c1 into p_s_tables(p_number_s_tables);
    exit when c1%notfound;
    p_number_s_tables:=p_number_s_tables+1;
  end loop;
  p_number_s_tables:=p_number_s_tables-1;
  close c1;
  if g_debug then
    write_to_log_file_n('Results');
    for i in 1..p_number_s_tables loop
      write_to_log_file(p_s_tables(i));
    end loop;
  end if;
  if p_number_s_tables=0 then
    p_number_s_tables:=1;
    l_stmt:='select table_name from bsc_db_tables where table_name like substr(:1,1,
    length(:2)-3)||''%''';
    if g_debug then
      write_to_log_file_n(l_stmt||' using '||p_mv||','||p_mv);
    end if;
    open cv for l_stmt using p_mv,p_mv;
    loop
      fetch cv into p_s_tables(p_number_s_tables);
      exit when cv%notfound;
      p_number_s_tables:=p_number_s_tables+1;
    end loop;
    p_number_s_tables:=p_number_s_tables-1;
    close cv;
    if g_debug then
      write_to_log_file_n('Results');
      for i in 1..p_number_s_tables loop
        write_to_log_file(p_s_tables(i));
      end loop;
    end if;
  end if;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in get_s_tables_for_mv '||sqlerrm);
  return false;
End;

--given the table name, get the short name of the level
function get_level_short_name(p_table_name varchar2) return varchar2 is
--
cursor c1(p_table varchar2) is select short_name from bsc_sys_dim_levels_b where level_table_name=p_table;
--
l_name varchar2(200);
Begin
  if g_debug then
    write_to_log_file_n('In get_level_short_name->select short_name from bsc_sys_dim_levels_b where level_table_name='||
    p_table_name);
  end if;
  open c1(p_table_name);
  fetch c1 into l_name;
  close c1;
  return l_name;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in get_level_short_name '||sqlerrm);
  return null;
End;

function create_dbi_dim_tables return boolean is
l_error_message varchar2(4000);
Begin
  if g_debug then
    write_to_log_file_n('In create_dbi_dim_tables');
  end if;
  if g_create_dbi_dim_tables is null or g_create_dbi_dim_tables=false then
    if g_debug then
      write_to_log_file_n('Going to call bsc_update_dim.Create_Dbi_Dim_Tables');
    end if;
    if bsc_update_dim.Create_Dbi_Dim_Tables(l_error_message)=false then
      BSC_IM_UTILS.g_status_message:=l_error_message;
      g_status_message:=l_error_message;
      write_to_log_file_n('Error bsc_update_dim.Create_Dbi_Dim_Tables '||l_error_message);
      return false;
    end if;
    g_create_dbi_dim_tables:=true; --create these tables only once
  end if;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in create_dbi_dim_tables '||sqlerrm);
  return false;
End;

/*
      For PMV
*/
procedure get_list_of_rec_dim(
p_dim_list out nocopy bsc_varchar2_table_type,
p_num_dim_list out nocopy number,
p_error_message out nocopy varchar2) is
--
l_dbi_dim_data BSC_UPDATE_DIM.t_array_dbi_dim_data;
l_num_dbi_dim_data number;
--
Begin
  --p_dim_list.delete;
  p_num_dim_list:=0;
  BSC_UPDATE_DIM.Get_All_Dbi_Dim_Data(l_dbi_dim_data);
  l_num_dbi_dim_data:=l_dbi_dim_data.count;
  p_dim_list:=bsc_varchar2_table_type();
  for i in 1..l_num_dbi_dim_data loop
    if l_dbi_dim_data(i).top_n_levels is not null and l_dbi_dim_data(i).top_n_levels>0 then
      p_num_dim_list:=p_num_dim_list+1;
      p_dim_list.extend;
      p_dim_list(p_num_dim_list):=l_dbi_dim_data(i).short_name;
    end if;
  end loop;
Exception when others then
  p_error_message:=sqlerrm;
  write_to_log_file_n('Exception in get_list_of_rec_dim '||sqlerrm);
  raise;
End;

--internal API
procedure get_list_of_rec_dim(
p_dim_list out nocopy BSC_UPDATE_DIM.t_array_dbi_dim_data
) is
--
l_dbi_dim_data BSC_UPDATE_DIM.t_array_dbi_dim_data;
l_num_dbi_dim_data number;
l_count number;
--
Begin
  p_dim_list.delete;
  BSC_UPDATE_DIM.Get_All_Dbi_Dim_Data(l_dbi_dim_data);
  l_num_dbi_dim_data:=l_dbi_dim_data.count;
  l_count:=0;
  for i in 1..l_num_dbi_dim_data loop
    if l_dbi_dim_data(i).top_n_levels is not null and l_dbi_dim_data(i).top_n_levels>0 then
      l_count:=l_count+1;
      p_dim_list(l_count):=l_dbi_dim_data(i);
    end if;
  end loop;
Exception when others then
  write_to_log_file_n('Exception in get_list_of_rec_dim '||sqlerrm);
  raise;
End;

procedure set_and_get_dim_sql(
p_dim_level_short_name bsc_varchar2_table_type,
p_dim_level_value bsc_varchar2_table_type,
p_num_dim_level number,
p_dim_level_sql out nocopy bsc_varchar2_table_type,
p_error_message out nocopy varchar2
) is
--
l_num_dim_level number;
--
l_stmt varchar2(2000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_level varchar2(40);
--
Begin
  if g_rec_dbi_dim.count=0 then --cache once
    get_list_of_rec_dim(g_rec_dbi_dim);
  end if;
  l_num_dim_level:=p_num_dim_level;
  p_dim_level_sql:=bsc_varchar2_table_type();
  if l_num_dim_level>0 then
    for i in 1..l_num_dim_level loop
      p_dim_level_sql.extend;
      p_dim_level_sql(i):=null;
      for j in 1..g_rec_dbi_dim.count loop
        if p_dim_level_short_name(i)=g_rec_dbi_dim(j).short_name then
          --this is a rec dim
          --see if the value is in the denorm table
          l_level:=null;
          if p_dim_level_value(i)='0' then
            --if zeco code, we first see if the top levels are materialized. if yes, we return the sql to
            --hit all the top levels
            --PMV will bind and put the brackets
            if g_rec_dbi_dim(j).top_n_levels_in_mv>0 then
              p_dim_level_sql(i):='select distinct '||g_rec_dbi_dim(j).parent_col||' from '||g_rec_dbi_dim(j).denorm_table||' where '||
              g_rec_dbi_dim(j).parent_level_col||'=1';
              exit;
            end if;
          else
            l_stmt:='select '||g_rec_dbi_dim(j).parent_level_col||' from '||g_rec_dbi_dim(j).denorm_table||
            ' where '||g_rec_dbi_dim(j).parent_col||'=:1 and rownum=1';
            open cv for l_stmt using p_dim_level_value(i);
            fetch cv into l_level;
            close cv;
            if to_number(l_level)>g_rec_dbi_dim(j).top_n_levels_in_mv then
              --value not in MV
              p_dim_level_sql(i):='select '||g_rec_dbi_dim(j).child_col||' from '||g_rec_dbi_dim(j).denorm_table||' where '||
              g_rec_dbi_dim(j).parent_col||' ';
              exit;
            end if;
          end if;
        end if;
      end loop;
    end loop;
  end if;
Exception when others then
  p_error_message:=sqlerrm;
  write_to_log_file_n('Exception in set_and_get_dim_sql '||sqlerrm);
  raise;
End;

procedure create_int_md_fk(
p_mv_name varchar2
) is
--
l_s_tables BSC_IM_UTILS.varchar_tabletype;
l_number_s_tables number;
l_fk BSC_IM_UTILS.varchar_tabletype;
l_number_fk number;
l_exception exception;
--
Begin
  if get_s_tables_for_mv(p_mv_name,l_s_tables,l_number_s_tables)=false then
    raise l_exception;
  end if;
  if get_table_fks(l_s_tables(1),l_fk,l_number_fk)=false then
    raise l_exception;
  end if;
  for i in 1..l_number_fk loop
    if BSC_IM_INT_MD.create_fk(
      l_fk(i),
      'SUMMARY MV',
      p_mv_name,
      null,
      null,
      null,
      'BSC',
      'SUMMARY MV')=false then
      raise l_exception;
    end if;
  end loop;
Exception
  when l_exception then
  raise;
  when others then
  write_to_log_file_n('Exception in create_int_md_fk '||sqlerrm);
  raise;
End;

/*
**************************************************************************************************
*/

END BSC_BSC_ADAPTER;

/
