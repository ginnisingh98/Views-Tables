--------------------------------------------------------
--  DDL for Package Body BSC_MV_ADAPTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_MV_ADAPTER" AS
/*$Header: BSCMVLDB.pls 120.10 2006/07/10 07:58:52 rkumar ship $*/

function get_partition_clause(p_keys in varchar2) return varchar2 is
l_num_partitions number;
l_partition_stmt varchar2(1000);
begin

  l_num_partitions := bsc_dbgen_metadata_reader.get_max_partitions;
  if (l_num_partitions > 2 and p_keys is not null) then
    l_partition_stmt := 'partition by hash('||p_keys||') partitions '||l_num_partitions;
  else
    l_partition_stmt := null;
  end if;
  if g_debug then
    write_to_log_file_n('In get_partition_clause, returning '||l_partition_stmt);
  end if;
  return l_partition_stmt;
end;

/*
This API can create MV or View
*/
function create_mv_normal(
p_kpi varchar2,
p_mv_name varchar2,
p_mv_owner varchar2,
p_child_mv BSC_IM_UTILS.varchar_tabletype,
p_number_child_mv number,
p_options BSC_IM_UTILS.varchar_tabletype,
p_number_options number,
p_apps_origin varchar2,
p_type varchar2,
p_create_non_unique_index boolean
)return boolean is
--------------------------------------
l_mv_stmt varchar2(32000);
l_fast_refresh_mv boolean;
--------------------------------------
--map info
l_map_name BSC_IM_UTILS.varchar_tabletype;
l_map_type BSC_IM_UTILS.varchar_tabletype;
l_object_name BSC_IM_UTILS.varchar_tabletype;
l_map_property BSC_IM_UTILS.varchar_tabletype;
l_detail_property BSC_IM_UTILS.varchar_tabletype;
l_chosen_map BSC_IM_UTILS.boolean_tabletype;
l_number_mapping number;
--------------------------------------
--map details
l_line BSC_IM_UTILS.varchar_tabletype;
l_line_type BSC_IM_UTILS.varchar_tabletype;
l_number_map_detail number;
--------------------------------------
--manage snapshot log creation on the mv
l_snplog_created BSC_IM_UTILS.boolean_tabletype;
--------------------------------------
l_b_tables BSC_IM_UTILS.varchar_tabletype;
l_base_snplog_created BSC_IM_UTILS.boolean_tabletype;
l_number_b_tables number;
--------------------------------------
l_level_tables BSC_IM_UTILS.varchar_tabletype;
l_level_snplog_created BSC_IM_UTILS.boolean_tabletype;
l_number_level_tables number;
--------------------------------------
l_tablespace varchar2(400);
l_storage varchar2(800);
l_index_tablespace varchar2(400);
l_index_storage varchar2(800);
--------------------------------------
l_db_version varchar2(80);
l_status varchar2(200);
--------------------------------------
l_keys varchar2(10000);
Begin
  if g_debug then
    write_to_log_file_n('In create_mv_normal '||p_mv_name||' '||p_mv_owner||', p_type='||p_type||' p_kpi='||p_kpi) ;
    if ( p_create_non_unique_index) then
         write_to_log_file_n('p_create_non_unique_index=true');
    end if;
  end if;
  g_kpi:=p_kpi;
  l_db_version:=BSC_IM_UTILS.get_db_version;
  if p_type='MV' then
    if BSC_IM_UTILS.get_option_value(p_options,p_number_options,'FULL REFRESH')='Y' then
      l_fast_refresh_mv:=false;
    else
      l_fast_refresh_mv:=true;
    end if;
  else
    l_fast_refresh_mv:=false; --view
  end if;
  ----------------------------------------------------
  --l_status:=check_old_mv_view(p_mv_name,p_mv_owner,p_type,p_options,p_number_options);
  l_status:=check_old_mv_view(p_mv_name,null,p_type,p_options,p_number_options);
  if l_status='ALREADY PRESENT' then
    return true;
  elsif l_status='ERROR' then
    --error
    return false;
  end if;
  --if none of the above, continue processing
  ----------------------------------------------------
  l_tablespace:=BSC_IM_UTILS.get_option_value(p_options,p_number_options,'TABLESPACE');
  l_storage:=BSC_IM_UTILS.get_option_value(p_options,p_number_options,'STORAGE');
  l_index_tablespace:=BSC_IM_UTILS.get_option_value(p_options,p_number_options,'INDEX TABLESPACE');
  l_index_storage:=BSC_IM_UTILS.get_option_value(p_options,p_number_options,'INDEX STORAGE');
  if l_tablespace is not null then
    if instr(lower(l_tablespace),'tablespace')<=0 then
      l_tablespace:=' tablespace '||l_tablespace;
    end if;
  end if;
  if l_storage is not null then
    if instr(lower(l_storage),'storage')<=0 then
      l_storage:=' storage '||l_storage;
    end if;
  end if;
  --------
  if l_index_tablespace is null then
    l_index_tablespace:=l_tablespace;
  else
    if instr(lower(l_index_tablespace),'tablespace')<=0 then
      l_index_tablespace:=' tablespace '||l_index_tablespace;
    end if;
  end if;
  if l_index_storage is null  then
    l_index_storage:=l_storage;
  else
    if instr(lower(l_index_storage),'storage')<=0 then
      l_index_storage:=' storage '||l_index_storage;
    end if;
  end if;
  ----------------------------------------------------
  --see if we need to create any snapshot logs
  for i in 1..p_number_child_mv loop
    l_snplog_created(i):=false;
  end loop;
  --p_number_child_mv is only the list of mv.
  if p_type='MV' and l_fast_refresh_mv then
    for i in 1..p_number_child_mv loop
      if create_mv_log_on_table(
        p_child_mv(i),
        p_apps_origin,
        p_options,
        p_number_options,
        l_snplog_created(i))=false then
        return false;
      end if;
    end loop;
  end if;
  --------------------------------------------
  --get the mapping info
  if BSC_IM_INT_MD.get_mapping(
    p_mv_name,
    p_apps_origin,
    l_map_name,
    l_map_type,
    l_object_name,
    l_map_property,
    l_number_mapping)=false then
    return false;
  end if;
  if g_debug then
    write_to_log_file_n('The maps read');
    for i in 1..l_number_mapping loop
      write_to_log_file(l_map_name(i)||' '||l_map_type(i)||' '||l_object_name(i)||' '||l_map_property(i));
    end loop;
  end if;
  --------------------------------------------
  --from the property, get the list of B tables. we have to create dummy MV on these B tables if this
  --MV gets created as full refresh
  declare
    ll_string varchar2(10000);
    ll_b_tables BSC_IM_UTILS.varchar_tabletype;
    ll_number_b_tables number;
  begin
    l_number_b_tables:=0;
    for i in 1..l_number_mapping loop
      ll_string:=null;
      ll_number_b_tables:=0;
      ll_string:=BSC_IM_UTILS.get_option_value(l_map_property(i),',','BASE TABLES');
      if ll_string is not null then
        if BSC_IM_UTILS.parse_values(ll_string,'+',ll_b_tables,ll_number_b_tables)=false then
          return false;
        end if;
        for j in 1..ll_number_b_tables loop
          if BSC_IM_UTILS.in_array(l_b_tables,l_number_b_tables,ll_b_tables(j))=false then
            l_number_b_tables:=l_number_b_tables+1;
            l_b_tables(l_number_b_tables):=ll_b_tables(j);
            l_base_snplog_created(l_number_b_tables):=false;
          end if;
        end loop;
      end if;
    end loop;
    if g_debug then
      write_to_log_file_n('The Base Tables for which we may need to create snapshot logs');
      for i in 1..l_number_b_tables loop
        write_to_log_file(l_b_tables(i));
      end loop;
    end if;
    if p_type='MV' and l_fast_refresh_mv then
      --create mv log on these base tables for inc mv
      for i in 1..l_number_b_tables loop
        if create_mv_log_on_table(
          l_b_tables(i),
          p_apps_origin,
          p_options,
          p_number_options,
          l_base_snplog_created(i))=false then
          return false;
        end if;
      end loop;
    end if;
  end;
  --------------------------------------------
  --from the property, get the list of level tables. we have to create snp log on these level tables if this
  --MV gets created as full refresh
  declare
    ll_string varchar2(10000);
    ll_level_tables BSC_IM_UTILS.varchar_tabletype;
    ll_number_level_tables number;
  begin
    l_number_level_tables:=0;
    for i in 1..l_number_mapping loop
      ll_string:=null;
      ll_number_level_tables:=0;
      ll_string:=BSC_IM_UTILS.get_option_value(l_map_property(i),',','DIM LEVELS');
      if ll_string is not null then
        if BSC_IM_UTILS.parse_values(ll_string,'+',ll_level_tables,ll_number_level_tables)=false then
          return false;
        end if;
        for j in 1..ll_number_level_tables loop
          if BSC_IM_UTILS.in_array(l_level_tables,l_number_level_tables,ll_level_tables(j))=false then
            l_number_level_tables:=l_number_level_tables+1;
            l_level_tables(l_number_level_tables):=ll_level_tables(j);
            l_level_snplog_created(l_number_level_tables):=false;
          end if;
        end loop;
      end if;
    end loop;
    if g_debug then
      write_to_log_file_n('The Dim Level Tables for which we may need to create snapshot logs');
      for i in 1..l_number_level_tables loop
        write_to_log_file(l_level_tables(i));
      end loop;
    end if;
    if p_type='MV' and l_fast_refresh_mv then
      --create mv log on these base tables for inc mv
      for i in 1..l_number_level_tables loop
        if create_mv_log_on_table(
          l_level_tables(i),
          p_apps_origin,
          p_options,
          p_number_options,
          l_level_snplog_created(i))=false then
          return false;
        end if;
      end loop;
    end if;
  end;
  ------------------------------------------------
  --create the MV in the BSC user.
  <<start_mv_create>>
  if g_debug then
    if l_fast_refresh_mv then
      write_to_log_file_n('Try with FAST Refresh');
    else
      write_to_log_file_n('Try with FULL Refresh');
    end if;
  end if;
  --------------------------------------------
  --find out what maps to look at
  declare
  begin
    --ran into an error with 8i instance : ORA-30489 Cannot have more than one rollup/cube expression list
    --cannot have rollup(fk1),rollup(fk2)
    --so for 8i, we never go for full refresh mapping
    for i in 1..l_number_mapping loop
      l_chosen_map(i):=true;
      if l_fast_refresh_mv then
        --if this is a fast refresh mv and there is full refresh specified, ignore the part
        if BSC_IM_UTILS.parse_and_find(l_map_property(i),',','FULL REFRESH') then
          l_chosen_map(i):=false;
        else
          l_chosen_map(i):=true;
        end if;
      else --this is full refresh
        if BSC_IM_UTILS.parse_and_find(l_map_property(i),',','FAST REFRESH') then
          l_chosen_map(i):=false;
        else
          l_chosen_map(i):=true;
        end if;
      end if;
    end loop;
    if g_debug then
      write_to_log_file_n('List of maps being looked at and ignored');
      for i in 1..l_number_mapping loop
        if l_chosen_map(i) then
          write_to_log_file(l_map_name(i)||' YES');
        else
          write_to_log_file(l_map_name(i)||' NO');
        end if;
      end loop;
    end if;
  end;
  --------------------------------------------
  /*
  have to use ad_mv api to create mv. pre-req patch 3050839
  ad_mv.create_mv(<MV_NAME>,
       ' create materialized view <MV NAME>'||
       ' tablespace '||ad_mv.g_mv_data_tablespace||
       ' INITRANS 4 MAXTRANS 255'||
       ' storage(INITIAL 4K NEXT .. '||
       '     MINEXTENTS 1 MAXEXTENTS UNLIMITED PCTINCREASE 0)'||
       ' build <DEFERRED|IMMEDIATE>'||
       ' using index tablespace '||ad_mv.g_mv_index_tablespace||
       ' storage (INITIAL 4K NEXT .. '||
       '     MAXEXTENTS UNLIMITED PCTINCREASE 0) '||
       ' refresh <FAST|COMPLETE> ON DEMAND'||
       ' with <rowid|primary key> '||
       ' <ENABLE|DISABLE QUERY REWRITE>'||
       ' as <sub-query qualifying table references with schema name...>');

  */
  if p_type='MV' then
    --l_mv_stmt:='create materialized view '||p_mv_owner||'.'||p_mv_name;
    --create the MV in the apps schema
    l_mv_stmt:='create materialized view '||p_mv_name;
    l_mv_stmt:=l_mv_stmt||' '||l_tablespace||' INITRANS 4 MAXTRANS 255 '||l_storage||' ';
    l_mv_stmt := l_mv_stmt || '<PARTITION_CLAUSE>';
    l_mv_stmt:=l_mv_stmt||' BUILD DEFERRED ';
    if l_tablespace is not null then
      l_mv_stmt:=l_mv_stmt||' using index '||l_tablespace||' '||l_storage;
    end if;
    if l_fast_refresh_mv then
      l_mv_stmt:=l_mv_stmt||' REFRESH FAST ON DEMAND ';
    end if;
    l_mv_stmt:=l_mv_stmt||' DISABLE QUERY REWRITE ';
  elsif p_type='VIEW' then
    l_mv_stmt:='create view '||p_mv_name;
  else
    if g_debug then
      write_to_log_file_n('Unknown type '||p_type||'. Error.');
      return false;
    end if;
  end if;
  l_mv_stmt:=l_mv_stmt||' AS ';
  ---------------------------------
  --get the mapping details
  begin
    for i in 1..l_number_mapping loop
      if l_chosen_map(i) then
        if g_debug then
          write_to_log_file_n('Process map '||l_map_name(i));
        end if;
        if BSC_IM_INT_MD.get_mapping_detail(
          l_map_name(i),
          p_apps_origin,
          l_line,
          l_line_type,
          l_detail_property,
          l_number_map_detail)=false then
          return false;
        end if;
        if g_debug then
          write_to_log_file_n('The map details read');
          for i in 1..l_number_map_detail loop
            write_to_log_file(l_line(i)||' '||l_line_type(i)||' '||l_detail_property(i));
          end loop;
        end if;
        for j in 1..l_number_map_detail loop
          if l_line_type(j)='SELECT' then
            if j=1 then
              l_mv_stmt:=l_mv_stmt||l_line(j);
            else
              l_mv_stmt:=l_mv_stmt||' UNION ALL '||l_line(j);
            end if;
          elsif l_line_type(j)='SELECT INC' then
            if l_fast_refresh_mv then
              l_mv_stmt:=l_mv_stmt||l_line(j);
            end if;
          elsif l_line_type(j)='FROM' then
            l_mv_stmt:=l_mv_stmt||l_line(j);
          elsif l_line_type(j)='WHERE' then
            l_mv_stmt:=l_mv_stmt||l_line(j);
          elsif l_line_type(j)='GROUP BY' then
            l_mv_stmt:=l_mv_stmt||l_line(j);
          elsif l_line_type(j)='KEYS' then
            l_keys := l_line(j);
          end if;
        end loop;
        l_mv_stmt:=l_mv_stmt||' UNION ALL ';
      else
        if g_debug then
          write_to_log_file_n('Not looking at this map '||l_map_name(i));
        end if;
      end if;
    end loop;
    --we were running into an error where the string is so long, it was beyond 32000 bytes.
    --in that case, go for full refresh mv with small stmt
    l_mv_stmt:=substr(l_mv_stmt,1,length(l_mv_stmt)-10);

    -- replace the partition clause
    l_mv_stmt := replace(l_mv_stmt, '<PARTITION_CLAUSE>', get_partition_clause(l_keys));
    if g_debug then
      write_to_log_file_n('l_mv_stmt='||l_mv_stmt);
    end if;
    --------------------------
    --create the mv
    execute immediate l_mv_stmt;
  exception when others then
    BSC_IM_UTILS.g_status_message:=sqlerrm;
    if g_debug then
      write_to_log_file_n('Error creating MV '||sqlerrm);
    end if;
    if l_fast_refresh_mv then
      l_fast_refresh_mv:=false;
      ------------------------------
      for i in 1..p_number_child_mv loop
        --if the mv log got created for this mv, drop the mv logs
        if l_snplog_created(i) then
          if g_debug then
            write_to_log_file_n('Going to drop the snapshot log and constraint on '||p_child_mv(i));
          end if;
          if BSC_IM_UTILS.drop_mv_log(p_child_mv(i),null)=false then
            null;
          end if;
          --if BSC_IM_UTILS.drop_constraint(p_child_mv(i),null,p_child_mv(i)||'_PK')=false then
            --null;
          --end if;
        end if;
      end loop;
      -----------------------------
      --drop the mv logs on the base tables
      for i in 1..l_number_b_tables loop
        if l_base_snplog_created(i) then
          if g_debug then
            write_to_log_file_n('Going to drop the snapshot log and constraint on '||l_b_tables(i));
          end if;
          if BSC_IM_UTILS.drop_mv_log(l_b_tables(i),null)=false then
            null;
          end if;
          --if BSC_IM_UTILS.drop_constraint(l_b_tables(i),null,l_b_tables(i)||'_PK')=false then
            --null;
          --end if;
        end if;
      end loop;
      -----------------------------
      --drop the mv logs on the dim levels
      for i in 1..l_number_level_tables loop
        if l_level_snplog_created(i) then
          if g_debug then
            write_to_log_file_n('Going to drop the snapshot log and constraint on '||l_level_tables(i));
          end if;
          if BSC_IM_UTILS.drop_mv_log(l_level_tables(i),null)=false then
            null;
          end if;
          --if BSC_IM_UTILS.drop_constraint(l_level_tables(i),null,l_level_tables(i)||'_PK')=false then
            --null;
          --end if;
        end if;
      end loop;
      -----------------------------
      --dont create dummy mv for now
      /*if create_dummy_mv(l_b_tables,l_number_b_tables,p_mv_name,p_mv_owner)=false then
        --we have to consider cases where the base tables may not have snapshot logs or pk constraints
        null;
      end if;*/
      goto start_mv_create;
    else
      raise;
    end if;
  end;
  if p_type='MV' then
    --MV are created in the apps schema
    --if create_mv_synonym(p_mv_name,p_mv_name,p_mv_owner)=false then
      --null;
    --end if;
    if create_mv_index(p_mv_name,null,p_kpi,p_apps_origin,l_index_tablespace,l_index_storage,
      p_create_non_unique_index)=false then
      return false;
    end if;
  end if;
  BSC_IM_UTILS.write_to_log_file_n(p_type||' '||p_mv_name||' Created');
  if l_fast_refresh_mv then
    if p_type='MV' then
      BSC_IM_UTILS.write_to_log_file_n(' -> FAST REFRESH');
    end if;
  else
    if p_type='MV' then
      BSC_IM_UTILS.write_to_log_file_n(' -> FULL REFRESH');
    end if;
  end if;
  BSC_IM_UTILS.write_to_log_file_n(' ');
  --------------------------------------------
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in create_mv_normal '||sqlerrm);
  return false;
End;

function create_dummy_mv(
p_b_tables BSC_IM_UTILS.varchar_tabletype,
p_number_b_tables number,
p_mv_name varchar2,
p_mv_owner varchar2
)return boolean is
l_mv_name varchar2(200);
l_stmt varchar2(8000);
Begin
  if g_debug then
    write_to_log_file_n('In create_dummy_mv '||p_mv_name||' '||p_mv_owner);
  end if;
  if g_bsc_owner is null then
    g_bsc_owner:=BSC_IM_UTILS.get_bsc_owner;
  end if;
  if p_number_b_tables>0 then
    for i in 1..p_number_b_tables loop
      --create dummy MV on as many base tables as possible
      l_mv_name:=substr(substr(p_mv_name,1,length(p_mv_name)-3),1,24)||'_D'||i||'MV';
      if BSC_IM_UTILS.drop_mv(l_mv_name,null)=false then
        null;
      end if;
      if BSC_IM_UTILS.drop_synonym(l_mv_name)=false then
        null;
      end if;
      --create the mv on the apps schema
      l_stmt:='CREATE MATERIALIZED VIEW '||l_mv_name||' BUILD DEFERRED REFRESH FAST ON '||
      'DEMAND AS SELECT '||p_b_tables(i)||'.*,'||p_b_tables(i)||'.rowid row_id from '||
      g_bsc_owner||'.'||p_b_tables(i)||' '||p_b_tables(i)||
      ' where 1=2';
      if g_debug then
        write_to_log_file_n(l_stmt);
      end if;
      begin
        execute immediate l_stmt;
      exception when others then
        BSC_IM_UTILS.g_status_message:=sqlerrm;
        if g_debug then
          write_to_log_file_n('Could not create dummy mv on '||p_b_tables(i)||' '||sqlerrm);
        end if;
      end;
    end loop;
  end if;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in create_dummy_mv '||sqlerrm);
  return false;
End;
function zmv_exists_for_mv(
p_mv_name varchar2,
p_mv_owner varchar2,
p_kpi varchar2,
p_apps_origin varchar2) return boolean
is
 l_zmv varchar2(100);
 -------------------------------------------------------------------------
l_object_type BSC_IM_UTILS.varchar_tabletype;
l_description BSC_IM_UTILS.varchar_tabletype;
l_zero_code_mv BSC_IM_UTILS.varchar_tabletype;
l_number_zero_code_mv number;
l_owner varchar2(100);
cursor cZMV(p_owner varchar2, p_zmv_name varchar2) is
select count(1) from all_objects where
owner=p_owner and object_name=p_zmv_name
and object_type = 'MATERIALIZED VIEW';
begin
  l_zmv := upper(substr(p_mv_name, 1, instr(p_mv_name, '_MV', -1)))||'ZMV';
  --write_to_log_file('zmv_exists_for_mv, we are searching for l_zmv ='||l_zmv);
  if BSC_IM_INT_MD.get_object(
    p_kpi,
    p_apps_origin,
    'ZERO CODE MV',
    l_zero_code_mv,
    l_object_type,
    l_description,
    l_number_zero_code_mv)=false then
    return false;
  end if;
  for i in 1..l_number_zero_code_mv loop
    write_to_log_file('Comparing '||l_zmv||' to '||l_zero_code_mv(i));
    if (upper(l_zero_code_mv(i)) = l_zmv) then
      return true;
    end if;
  end loop;
  -- could be called from mv refresh
  l_owner:=bsc_im_utils.get_table_owner(p_mv_name);
  open cZMV(l_owner, l_zmv);
  fetch cZMV into l_number_zero_code_mv;
  close cZMV;
  if (l_number_zero_code_mv>0) then
    return true;
  end if;
  return false;

end;

function is_higher_mv_a_view(p_mv_name varchar2) return boolean
is
begin

  return false;
end;

function index_already_exists(p_index_name varchar2, p_mv_name varchar2, p_mv_owner varchar2) return boolean is
cursor cIndexExists is
select count(1) from user_indexes where index_name=p_index_name
and table_name = p_mv_name and table_owner=p_mv_owner;
l_index_exists number;
begin
  open cIndexExists;
  fetch cIndexExists into l_index_exists;
  close cIndexExists;
  if l_index_exists > 0  then
    return true;
  end if;
  return false;
end;

/*---------------------------------------------------------
New Index strategy
Time index for every mv (periodicity_id, year, period)

Other indexes
Case 1: No views above
MV and ZMV: periodicity_id, zkeys, nonzkeys, type

Case 2: Views above, zmv exists
MV: periodicity_id, zkeys, nonzkeys, type
ZMV: periodicity_id, zkeys, type
     periodicity_id, nonzkey1
         .
         .
     periodicity_id, nonzkeyn

Case 3: Views above, no zmv
MV: periodicity_id, nonzkey1
         .
         .
    periodicity_id, nonzkeyn
---------------------------------------------------------*/
function create_mv_index(
p_mv_name varchar2,
p_mv_owner varchar2,
p_kpi varchar2,
p_apps_origin varchar2,
p_tablespace varchar2,
p_storage varchar2,
p_create_non_unique_index boolean,
p_called_from_refresh boolean default false
)return boolean is
------------------------------------------------------------
l_fk_name BSC_IM_UTILS.varchar_tabletype;
l_fk_type BSC_IM_UTILS.varchar_tabletype;
l_uk_name BSC_IM_UTILS.varchar_tabletype;
l_uk_parent_name BSC_IM_UTILS.varchar_tabletype;
l_fk_property BSC_IM_UTILS.varchar_tabletype;
l_description BSC_IM_UTILS.varchar_tabletype;
l_number_fk number;
------------------------------------------------------------
l_stmt varchar2(8000);
--l_db_version varchar2(80);
l_trans varchar2(200);
------------------------------------------------------------
l_create_non_unique_index boolean;
l_owner varchar2(200);
------------------------------------------------------------
l_zero_code_cols dbms_sql.varchar2_table;
-----
l_higher_level_view_exists boolean ;
l_time_columns VARCHAR2(100):= '(PERIODICITY_ID, YEAR, PERIOD)';
l_index_counter number := 1;
l_nonzero_code_cols dbms_sql.varchar2_table;
l_is_zmv boolean;
l_zmv_exists_for_mv boolean;
l_mv_name_for_zmv varchar2(100);
---------------------------------

l_s_tables BSC_IM_UTILS.varchar_tabletype;
l_number_s_tables number;

Begin
  --get the fks
  g_kpi:=p_kpi;
  l_owner:=p_mv_owner;
  if l_owner is null then
    l_owner:=bsc_im_utils.get_table_owner(p_mv_name);
  end if;
  l_create_non_unique_index:=p_create_non_unique_index;
  -- Get the FKS differently for refresh and GDB run
  if (p_called_from_refresh) then
    if BSC_BSC_ADAPTER.get_s_tables_for_mv(p_mv_name,l_s_tables,l_number_s_tables)=false then
      return false;
    end if;
    if l_number_s_tables=0 then
      if g_debug then
        write_to_log_file_n('No s tables found for '||p_mv_name||'. Do Validations to do...');
      end if;
      return true;
    end if;
    if BSC_BSC_ADAPTER.get_table_fks(l_s_tables,l_number_s_tables,l_fk_name,l_number_fk)=false then
      return false;
    end if;
  else
    if BSC_IM_INT_MD.get_fk(
      p_mv_name,
      p_apps_origin,
      l_fk_name,
      l_fk_type,
      l_uk_name,
      l_uk_parent_name,
      l_description,
      l_fk_property,
      l_number_fk)=false then
      return false;
    end if;
  end if;


  if (g_debug) then
    write_to_log_file('In create_mv_index for '||p_mv_name);
  end if;
  l_zmv_exists_for_mv := false;

  if (p_mv_name like '%_ZMV') then
    l_is_zmv := true;
    if (g_debug) then
      write_to_log_file(', l_is_zmv=true');
    end if;
    l_mv_name_for_zmv := substr(p_mv_name, 1, instr(p_mv_name, '_ZMV', -1))||'MV';
  else
    l_is_zmv := false;
    l_mv_name_for_zmv := p_mv_name;
    if (g_debug) then
      write_to_log_file(', l_is_zmv=false');
    end if;
    if zmv_exists_for_mv(p_mv_name, p_mv_owner, p_kpi, p_apps_origin) then
      l_zmv_exists_for_mv := true;
      if (g_debug) then
        write_to_log_file(', l_zmv_exists_for_mv=true');
      end if;
    else
      l_zmv_exists_for_mv := false;
      if (g_debug) then
        write_to_log_file(', l_zmv_exists_for_mv=false');
      end if;
    end if;
  end if;

  --l_db_version:=BSC_IM_UTILS.get_db_version;
  l_trans:=' PCTFREE 5 INITRANS 11 MAXTRANS 255 ';

  -- New MV Strategy, enh 4195212
  -- Every MV has a time index
  -- Enh#4239064: create index in parallel
  l_stmt:='create index '||l_owner||'.'||p_mv_name||'N'||l_index_counter||' on '||l_owner||'.'||p_mv_name||l_time_columns;
  l_stmt:=l_stmt||' '||p_tablespace||' '||p_storage||l_trans||' parallel';



  if index_already_exists(p_mv_name||'N'||l_index_counter, p_mv_name, p_mv_owner)=false then
    if BSC_IM_UTILS.create_index(l_stmt,null)=false then
      return false;
    end if;
  end if;
  -- Enh#4239064: set to noparallel
  execute immediate 'alter index '||l_owner||'.'||p_mv_name||'N'||l_index_counter||' noparallel';

  l_index_counter := l_index_counter + 1;

  if p_create_non_unique_index OR BSC_IM_UTILS.is_parent_of_type_present(l_mv_name_for_zmv,'VIEW') then
    l_higher_level_view_exists := true;
    if (g_debug) then
      write_to_log_file(' l_higher_level_view_exists := true');
    end if;
  else
    l_higher_level_view_exists := false;
    if (g_debug) then
      write_to_log_file(' l_higher_level_view_exists := false');
    end if;
  end if;
  if l_number_fk>0 then
    l_zero_code_cols.delete;
    l_nonzero_code_cols.delete;
    for i in 1..l_number_fk loop
      if (l_fk_name(i) not in ('PERIODICITY_ID', 'YEAR', 'PERIOD', 'TYPE')) then
        if(BSC_IM_UTILS.needs_zero_code_mv(p_mv_name, p_kpi, l_fk_name(i))) then
          write_to_log_file(l_fk_name(i)||' is a zero code col');
          l_zero_code_cols(l_zero_code_cols.count+1) := l_fk_name(i);
        else
          write_to_log_file(l_fk_name(i)||' is a non zero code col');
          l_nonzero_code_cols(l_nonzero_code_cols.count+1) :=l_fk_name(i);
        end if;
      end if;
    end loop;
  end if;

  -- Case 1 both MV/ZMV and MV only for Case 2
  -- Case 1: No views above
  -- MV and ZMV: periodicity_id, zkeys, nonzkeys, type
  -- Case 2: Views above, zmv exists
  -- MV: periodicity_id, zkeys, nonzkeys, type

  l_stmt := 'create index '||l_owner||'.'||p_mv_name||'N'||l_index_counter||' on '||l_owner||'.'||p_mv_name||'(PERIODICITY_ID,';
  if (l_higher_level_view_exists=false OR
     (l_higher_level_view_exists=true AND l_is_zmv=false AND l_zmv_exists_for_mv=true)-- CASE2 for MV
	  ) then
	if (g_debug) then
          write_to_log_file('Case1 and Case 2a');
        end if;
    if l_number_fk>0 then
      if (l_zero_code_cols.count>0) then
	    for i in l_zero_code_cols.first..l_zero_code_cols.last loop
	      l_stmt := l_stmt ||l_zero_code_cols(i)||',';
	    end loop;
	  end if;
	  if (l_nonzero_code_cols.count>0) then
	    for i in l_nonzero_code_cols.first..l_nonzero_code_cols.last loop
	      l_stmt := l_stmt ||l_nonzero_code_cols(i)||',';
	    end loop;
	  end if;
      -- Enh#4239064: create index in parallel
      l_stmt:=l_stmt||' TYPE) '||p_tablespace||' '||p_storage||l_trans||' parallel';
      if index_already_exists(p_mv_name||'N'||l_index_counter, p_mv_name, p_mv_owner)=false then
        if BSC_IM_UTILS.create_index(l_stmt,null)=false then
          return false;
        end if;
      end if;
      -- Enh#4239064: set to noparallel
      execute immediate 'alter index '||l_owner||'.'||p_mv_name||'N'||l_index_counter||' noparallel';
    end if;
    return true;
  end if;
  -- There are views above, so its either Case 2 for ZMV or Case 3 for MV
  --First handle Case 2 ZMV
  --ZMV:
  -- periodicity_id, zkeys, type
  -- periodicity_id, nonzkey1
  --       .
  --       .
  -- periodicity_id, nonzkeyn
  if (l_is_zmv) then
    if (g_debug) then
      write_to_log_file('Case 2b');
    end if;

    if l_number_fk>0 then
      l_stmt := 'create index '||l_owner||'.'||p_mv_name||'N'||l_index_counter||' on '||l_owner||'.'||p_mv_name||'(PERIODICITY_ID,';
      if (l_zero_code_cols.count>0) then
	    for i in l_zero_code_cols.first..l_zero_code_cols.last loop
	      l_stmt := l_stmt ||l_zero_code_cols(i)||',';
	    end loop;
        -- Enh#4239064: create index in parallel
        l_stmt:=l_stmt||' TYPE) '||p_tablespace||' '||p_storage||l_trans||' parallel';
        if index_already_exists(p_mv_name||'N'||l_index_counter, p_mv_name, p_mv_owner)=false then
          if BSC_IM_UTILS.create_index(l_stmt,null)=false then
            write_to_log_file_n('Exception in create_mv_index, stmt='||l_stmt);
            return false;
          end if;
        end if;
        -- Enh#4239064: set to noparallel
        execute immediate 'alter index '||l_owner||'.'||p_mv_name||'N'||l_index_counter||' noparallel';
        l_index_counter := l_index_counter+1;
      end if;
      if (l_nonzero_code_cols.count>0) then
        for i in l_nonzero_code_cols.first..l_nonzero_code_cols.last loop
          l_stmt := 'create index '||l_owner||'.'||p_mv_name||'N'||l_index_counter||' on '||l_owner||'.'||p_mv_name||'(PERIODICITY_ID,';
          -- Enh#4239064: create index in parallel
          l_stmt := l_stmt ||l_nonzero_code_cols(i)||') '||p_tablespace||' '||p_storage||l_trans||' parallel';
          if index_already_exists(p_mv_name||'N'||l_index_counter, p_mv_name, p_mv_owner)=false then
            if BSC_IM_UTILS.create_index(l_stmt,null)=false then
              write_to_log_file_n('Exception in create_mv_index, stmt='||l_stmt);
              return false;
            end if;
          end if;
          -- Enh#4239064: set to noparallel
          execute immediate 'alter index '||l_owner||'.'||p_mv_name||'N'||l_index_counter||' noparallel';
          l_index_counter := l_index_counter+1;
	    end loop;
	  end if;
    end if;
    return true;
  end if;

  --Case 3: Views above, no zmv
  ---------------------------
  -- MV:
  -- periodicity_id, nonzkey1
  --       .
  --       .
  -- periodicity_id, nonzkeyn
  if (g_debug) then
    write_to_log_file('Case3');
  end if;

  if (l_nonzero_code_cols.count>0) then
    for i in l_nonzero_code_cols.first..l_nonzero_code_cols.last loop
      l_stmt := 'create index '||l_owner||'.'||p_mv_name||'N'||l_index_counter||' on '||l_owner||'.'||p_mv_name||'(PERIODICITY_ID,';
      -- Enh#4239064: create index in parallel
      l_stmt := l_stmt ||l_nonzero_code_cols(i)||') '||p_tablespace||' '||p_storage||l_trans||' parallel';
      if index_already_exists(p_mv_name||'N'||l_index_counter, p_mv_name, p_mv_owner)=false then
        if BSC_IM_UTILS.create_index(l_stmt,null)=false then
          return false;
        end if;
      end if;
      -- Enh#4239064: set to noparallel
      execute immediate 'alter index '||l_owner||'.'||p_mv_name||'N'||l_index_counter||' noparallel';
      l_index_counter := l_index_counter+1;
    end loop;
  end if;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in create_mv_index, stmt='||l_stmt);
  write_to_log_file_n(sqlerrm);
  return false;
End;
-- bug 4180632, PMD does not populate bsc_sys_dim_level_cols with the parent FKs
-- add the column only if it is not there in the list of FKs
FUNCTION get_parent_fk_columns(
p_object IN varchar2,
p_already_included IN BSC_IM_UTILS.varchar_tabletype,
p_included_count IN NUMBER,
p_columns IN OUT nocopy BSC_IM_UTILS.varchar_tabletype,
p_num_columns IN OUT nocopy number
) RETURN boolean
IS
CURSOR cColumns IS
select relation_col
 from bsc_sys_dim_level_rels rels ,bsc_sys_dim_levels_b levels
 where levels.level_table_name=p_object
 and rels.dim_level_id=levels.dim_level_id;
begin
  FOR i IN cColumns LOOP
    IF bsc_im_utils.in_array(p_already_included, p_included_count, i.relation_col)=FALSE AND
	   bsc_im_utils.in_array(p_columns, p_num_columns, i.relation_col)=FALSE THEN
      p_columns(p_columns.count+1) := i.relation_col;
      p_num_columns := p_num_columns +1;
      --write_to_log_file('Adding fk column  '||i.relation_col);
    END IF;
  END LOOP;
  RETURN TRUE;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in get_parent_fk_columns, '||sqlerrm);
  write_to_log_file_n(sqlerrm);
  RETURN FALSE;
End;

function create_mv_log_on_table(
p_object varchar2,
p_apps_origin varchar2,
p_options BSC_IM_UTILS.varchar_tabletype,
p_number_options number,
p_snplog_created out nocopy boolean
)return boolean is
l_column_name BSC_IM_UTILS.varchar_tabletype;
l_column_type BSC_IM_UTILS.varchar_tabletype;
l_column_data_type BSC_IM_UTILS.varchar_tabletype;
l_column_origin BSC_IM_UTILS.varchar_tabletype;
l_aggregation_type BSC_IM_UTILS.varchar_tabletype;
l_description BSC_IM_UTILS.varchar_tabletype;
l_property BSC_IM_UTILS.varchar_tabletype;
l_number_columns number;
------------------------------------------------------------
l_fk_name BSC_IM_UTILS.varchar_tabletype;
l_fk_type BSC_IM_UTILS.varchar_tabletype;
l_uk_name BSC_IM_UTILS.varchar_tabletype;
l_uk_parent_name BSC_IM_UTILS.varchar_tabletype;
l_fk_property BSC_IM_UTILS.varchar_tabletype;
l_number_fk number;
------------------------------------------------------------
l_dim number;
Begin
  if g_debug then
    write_to_log_file_n('In create_mv_log_on_table '||p_object);
  end if;
  p_snplog_created:=false;
  l_number_columns := 0;
  select count(1) into l_dim from bsc_sys_dim_levels_b where level_table_name=p_object;
  if(l_dim=0) then -- not dimension
    if BSC_IM_INT_MD.get_column(
      p_object,
      p_apps_origin,
      l_column_name,
      l_column_type,
      l_column_data_type,
      l_column_origin,
      l_aggregation_type,
      l_description,
      l_property,
      l_number_columns)=false then
      return false;
    end if;
  end if;
  --get the fks
  if BSC_IM_INT_MD.get_fk(
    p_object,
    p_apps_origin,
    l_fk_name,
    l_fk_type,
    l_uk_name,
    l_uk_parent_name,
    l_description,
    l_fk_property,
    l_number_fk)=false then
    return false;
  end if;
  if (l_dim<>0) then -- dimension, get parent fk cols
    -- bug 4180632, PMD does not populate bsc_sys_dim_level_cols with the parent FKs
    if get_parent_fk_columns(
      p_object,
      l_fk_name,--we shouldnt add fk cols again
      l_number_fk, --# of fk cols
	  l_column_name,
	  l_number_columns)=false then
      return false;
    end if;
  end if;
  if BSC_IM_UTILS.create_mv_log_on_table(
    p_object,
    null,
    p_options,
    p_number_options,
    l_fk_name,
    l_number_fk,
    l_column_name,
    l_number_columns,
    p_snplog_created
    )=false then
    return false;
  end if;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in create_mv_log_on_table '||sqlerrm);
  return false;
End;

function create_mv_synonym(
p_level varchar2,
p_mv_name varchar2,
p_mv_owner varchar2
)return boolean is
Begin
  g_stmt:='create synonym '||p_level||' for '||p_mv_owner||'.'||p_mv_name;
  write_to_debug_n(g_stmt);
  if BSC_IM_UTILS.drop_synonym(p_level)=false then
    null;
  end if;
  execute immediate g_stmt;
  write_to_debug('Created synonym');
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in create_mv_synonym '||sqlerrm);
  return false;
End;

function alter_mv_to_refresh_demand(
p_mv_name varchar2,
p_mv_owner varchar2
)return boolean is
l_owner varchar2(200);
Begin
  l_owner:=p_mv_owner;
  if l_owner is null then
    l_owner:=bsc_im_utils.get_table_owner(p_mv_name);
  end if;
  g_stmt:='ALTER MATERIALIZED VIEW '||l_owner||'.'||p_mv_name||' REFRESH ON DEMAND';
  write_to_debug_n(g_stmt);
  execute immediate g_stmt;
  write_to_debug('MV altered');
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in alter_mv_to_refresh_demand '||sqlerrm);
  return false;
End;

function create_mv_kpi(
p_kpi varchar2,
p_apps_origin varchar2,
p_options BSC_IM_UTILS.varchar_tabletype,
p_number_options number
) return boolean is
-------------------------------------------------------------------------
l_summary_mv BSC_IM_UTILS.varchar_tabletype;
l_object_type BSC_IM_UTILS.varchar_tabletype;
l_description BSC_IM_UTILS.varchar_tabletype;
l_property BSC_IM_UTILS.varchar_tabletype;
l_number_summary_mv number;
-------------------------------------------------------------------------
l_parent_summary_mv BSC_IM_UTILS.varchar_tabletype;
l_child_summary_mv BSC_IM_UTILS.varchar_tabletype;
l_number_pc_mv number;
-------------------------------------------------------------------------
l_ordered_summary_mv BSC_IM_UTILS.varchar_tabletype;
l_ordered_summary_mv_rank BSC_IM_UTILS.number_tabletype;
l_number_ordered_summary_mv number;
-------------------------------------------------------------------------
l_max_rank number;
l_min_rank number;
l_bsc_owner varchar2(200);
-------------------------------------------------------------------------
l_child_mv BSC_IM_UTILS.varchar_tabletype;
l_number_child_mv number;
-------------------------------------------------------------------------
--users may say they only want three levels of mv.
l_max_mv_levels number;
l_summary_views varchar2(20);
l_type varchar2(20);
-------------------------------------------------------------------------
l_create_non_unique_index boolean;
-------------------------------------------------------------------------
Begin
  if g_debug then
    write_to_log_file_n('++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
    write_to_log_file('In create_mv_fact '||p_kpi||' '||get_time);
    write_to_log_file('++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
  end if;
  g_kpi:=p_kpi;
  BSC_IM_UTILS.write_to_log_file_n('++++++++++++++++++++++++++++++++++++++++++++++++++++++');
  BSC_IM_UTILS.write_to_log_file_n('Create MV/Views for KPI '||p_kpi);
  BSC_IM_UTILS.write_to_log_file_n('++++++++++++++++++++++++++++++++++++++++++++++++++++++');
  if g_bsc_owner is null then
    g_bsc_owner:=BSC_IM_UTILS.get_bsc_owner;
  end if;
  l_bsc_owner:=g_bsc_owner;
  ------------------------------------------------
  --get the ordered list of mv
  if get_ordered_mv_list(
    p_kpi,
    p_apps_origin,
    l_parent_summary_mv,
    l_child_summary_mv,
    l_number_pc_mv,
    l_ordered_summary_mv,
    l_ordered_summary_mv_rank,
    l_number_ordered_summary_mv,
    l_max_rank
    )=false then
    return false;
  end if;
  ------------------------------------------------
  --call the create MV. should be called according to the rank
  l_max_mv_levels:=BSC_IM_UTILS.get_option_value(p_options,p_number_options,'MV LEVELS');
  l_summary_views:=BSC_IM_UTILS.get_option_value(p_options,p_number_options,'SUMMARY VIEWS');
  if g_debug then
    write_to_log_file_n('Max levels of MV='||l_max_mv_levels);
    write_to_log_file('Summary Views='||l_summary_views);
  end if;
  l_min_rank:=1000;
  --rkumar: bug5335536 calculate min_rank
  for i in 1..l_number_ordered_summary_mv loop
    if l_ordered_summary_mv_rank(i) < l_min_rank then
      l_min_rank:=l_ordered_summary_mv_rank(i);
    end if;
  end loop;
  write_to_log_file('MinRank is: '||l_min_rank);
  --3534805
  /*
  if the first level is not a BSC_S_ mv but instead say  BSC_SB_ mv, then
  we set the rank for the SB mv as -1 this is because, if we have something like
  B1 -> SB -> S_0_0_MV -> S_0_1_MV
  B2 -------> S_0_0_MV -> S_0_1_MV
  and levels=2, we want S_0_0_MV and S_0_1_MV to be mv. earlier, S_0_1_MV became a
  view as it was viewed as third level
  */
  --rank starts from 0. so we need l_max_mv_levels-1
  /*
  go through the list of MV, if there are SB with rank 0, look at the corresponding S MV.
  if the S MV does not have rank 0, reduce the rank of the SB MV
  */
--rkumar:5335536 Commeting out the logic for rank modification. No longer required after the bugfix.
/*  declare
    l_name varchar2(100);
    l_pattern varchar2(100);
    l_pattern_len number;
    l_sb_pattern varchar2(100);
    l_sb_pattern_len number;
    l_rank number;
  begin
    for i in 1..l_number_ordered_summary_mv loop
      if substr(l_ordered_summary_mv(i),1,7)='BSC_SB_' and l_ordered_summary_mv_rank(i)=0 then
        l_pattern:=substr(l_ordered_summary_mv(i),1,instr(l_ordered_summary_mv(i),'_',1,4));
        l_sb_pattern:=l_pattern;
        l_sb_pattern_len:=length(l_sb_pattern);
        l_pattern:=replace(l_pattern,'BSC_SB_','BSC_S_');
        l_pattern_len:=length(l_pattern);
        l_name:=replace(l_ordered_summary_mv(i),'BSC_SB_','BSC_S_');
        for j in 1..l_number_ordered_summary_mv loop
          if l_ordered_summary_mv(j)=l_name then
            if l_ordered_summary_mv_rank(j)<>0 then
              l_rank:=l_ordered_summary_mv_rank(j);
              --first reduce the rank of the S
              for k in 1..l_number_ordered_summary_mv loop
                --write_to_log_file(substr(l_ordered_summary_mv(k),1,l_pattern_len)||' '||l_pattern);
                if substr(l_ordered_summary_mv(k),1,l_pattern_len)=l_pattern then
                  l_ordered_summary_mv_rank(k):=l_ordered_summary_mv_rank(k)-l_rank;
                  if l_min_rank>l_ordered_summary_mv_rank(k) then
                    l_min_rank:=l_ordered_summary_mv_rank(k);
                  end if;
                end if;
                --for SB also
                if substr(l_ordered_summary_mv(k),1,l_sb_pattern_len)=l_sb_pattern then
                  l_ordered_summary_mv_rank(k):=l_ordered_summary_mv_rank(k)-l_rank;
                  if l_min_rank>l_ordered_summary_mv_rank(k) then
                    l_min_rank:=l_ordered_summary_mv_rank(k);
                  end if;
                end if;
              end loop;
            end if;
            exit;
          end if;
        end loop;
      end if;
    end loop;
    if g_debug then
      write_to_log_file_n('After rank modifications');
      for i in 1..l_number_ordered_summary_mv loop
        write_to_log_file(l_ordered_summary_mv(i)||' '||l_ordered_summary_mv_rank(i));
      end loop;
      write_to_log_file_n('Min Rank='||l_min_rank);
    end if;
  end;
*/
  --------------------------
  if l_max_rank>l_max_mv_levels-1 then
    g_all_levels_mv:=false;
    if g_debug then
      write_to_log_file_n('NOT ALL Levels MV');
    end if;
  else
    g_all_levels_mv:=true;
    if g_debug then
      write_to_log_file_n('ALL Levels MV');
    end if;
  end if;
  for i in l_min_rank..l_max_rank loop
    --l_mv_level_count:=l_mv_level_count+1;
    l_type:='MV';
    if i>l_max_mv_levels-1 then
      if l_summary_views='Y' then
        l_type:='VIEW';
      else
        exit;
      end if;
    end if;
    for j in 1..l_number_ordered_summary_mv loop
      if l_ordered_summary_mv_rank(j)=i then
        l_number_child_mv:=0;
        for k in 1..l_number_pc_mv loop
          if l_parent_summary_mv(k)=l_ordered_summary_mv(j) then
            l_number_child_mv:=l_number_child_mv+1;
            l_child_mv(l_number_child_mv):=l_child_summary_mv(k);
          end if;
        end loop;
        if g_all_levels_mv=false and l_ordered_summary_mv_rank(j)=l_max_mv_levels-1 then
          --this is the highest level of the mv. beyond this, they are all views.
          l_create_non_unique_index:=true;
        else
          l_create_non_unique_index:=false;
        end if;
        if create_mv_normal(
          p_kpi,
          l_ordered_summary_mv(j),
          l_bsc_owner,
          l_child_mv,
          l_number_child_mv,
          p_options,
          p_number_options,
          p_apps_origin,
          l_type,
          l_create_non_unique_index
          )=false then
          return false;
        end if;
      end if;
    end loop;
  end loop;

  ---------------------------------------------
  if create_zero_code_mv_kpi(
    p_kpi,
    p_apps_origin,
    p_options,
    p_number_options,
    l_max_rank,
    l_bsc_owner,
    l_max_mv_levels,
    l_ordered_summary_mv,
    l_ordered_summary_mv_rank,
    l_number_ordered_summary_mv
    )=false then
    return false;
  end if;
  ---------------------------------------------
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in create_mv_fact '||sqlerrm);
  return false;
End;


function create_zero_code_mv_kpi(
p_kpi varchar2,
p_apps_origin varchar2,
p_options BSC_IM_UTILS.varchar_tabletype,
p_number_options number,
p_max_rank number,
p_bsc_owner varchar2,
p_max_mv_levels number,
p_ordered_summary_mv BSC_IM_UTILS.varchar_tabletype,
p_ordered_summary_mv_rank BSC_IM_UTILS.number_tabletype,
p_number_ordered_summary_mv number
) return boolean is
-------------------------------------------------------------------------
l_object_type BSC_IM_UTILS.varchar_tabletype;
l_description BSC_IM_UTILS.varchar_tabletype;
-------------------------------------------------------------------------
l_child_mv BSC_IM_UTILS.varchar_tabletype;
l_number_child_mv number;
-------------------------------------------------------------------------
--users may say they only want three levels of mv.
l_mv_level_count number;
l_type varchar2(20);
-------------------------------------------------------------------------
l_zero_code_mv BSC_IM_UTILS.varchar_tabletype;
l_number_zero_code_mv number;
-------------------------------------------------------------------------
--to grab the dependency info
l_dep_summary_mv BSC_IM_UTILS.varchar_tabletype;
l_dep_zero_code_mv BSC_IM_UTILS.varchar_tabletype;
l_number_dep_mv number;
-------------------------------------------------------------------------
l_index number;
l_status varchar2(200);
-------------------------------------------------------------------------
l_max_rank number;
l_min_rank number;
l_create_non_unique_index boolean;
Begin
  --zero code MV
    if g_debug then
    write_to_log_file_n('++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
    write_to_log_file('In create_zero_code_mv_kpi '||p_kpi||' '||get_time);
    write_to_log_file('++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
  end if;
  g_kpi:=p_kpi;
  if BSC_IM_INT_MD.get_object(
    p_kpi,
    p_apps_origin,
    'ZERO CODE MV',
    l_zero_code_mv,
    l_object_type,
    l_description,
    l_number_zero_code_mv)=false then
    return false;
  end if;
  if l_number_zero_code_mv>0 then
    l_number_dep_mv:=0;
    declare
      --to grab the dependency info
      ll_dep_object_name BSC_IM_UTILS.varchar_tabletype;
      ll_dep_object_type BSC_IM_UTILS.varchar_tabletype;
      ll_dep_object_desc BSC_IM_UTILS.varchar_tabletype;
      ll_number_dep_objects number;
    begin
      for i in 1..l_number_zero_code_mv loop
        if BSC_IM_INT_MD.get_object(
          l_zero_code_mv(i),
          p_apps_origin,
          'MV DEPENDENCY',
          ll_dep_object_name,
          ll_dep_object_type,
          ll_dep_object_desc,
          ll_number_dep_objects)=false then
          return false;
        end if;
        for j in 1..ll_number_dep_objects loop
          if BSC_IM_UTILS.in_array(l_dep_zero_code_mv,l_dep_summary_mv,l_number_dep_mv,
            l_zero_code_mv(i),ll_dep_object_name(j))=false then
            l_number_dep_mv:=l_number_dep_mv+1;
            l_dep_zero_code_mv(l_number_dep_mv):=l_zero_code_mv(i);
            l_dep_summary_mv(l_number_dep_mv):=ll_dep_object_name(j);
          end if;
        end loop;
      end loop;
    end;
    if g_debug then
      write_to_log_file_n('The zero code MV and the corresponding summary MV');
      for i in 1..l_number_dep_mv loop
        write_to_log_file(l_dep_zero_code_mv(i)||' '||l_dep_summary_mv(i));
      end loop;
    end if;
    -- bug 3867313
    l_min_rank:=1000000;
    for i in 1..p_number_ordered_summary_mv loop
      if substr(p_ordered_summary_mv(i),1,6)='BSC_S_' and
        p_ordered_summary_mv_rank(i)<l_min_rank then
        l_min_rank:=p_ordered_summary_mv_rank(i);
      end if;
    end loop;
    l_mv_level_count:=0;
    l_max_rank:=l_min_rank+p_max_rank;
    for i in 1..p_number_ordered_summary_mv loop
      write_to_log_file(p_ordered_summary_mv(i)||' '||p_ordered_summary_mv_rank(i));
    end loop;
    -- bug 3867313
    for i in l_min_rank..l_max_rank loop
      l_mv_level_count:=l_mv_level_count+1;
      /*
      3534805
      for zero code, using l_mv_level_count is fine.
      */
      l_type:='MV';
      for j in 1..p_number_ordered_summary_mv loop
        if p_ordered_summary_mv_rank(j)=i then
          --p_ordered_summary_mv_rank(j) is the child mv. for this mv, get the zero code mv by looking at the
          --mv dependency
          l_number_child_mv:=1;
          l_child_mv(l_number_child_mv):=p_ordered_summary_mv(j);
          --get the zero code mv
          l_index:=BSC_IM_UTILS.get_index(l_dep_summary_mv,l_number_dep_mv,p_ordered_summary_mv(j));
          if l_index>0 then
            --for zero code mv, we never need to create non unique indexes since there are no views
            --on the zero code mv
            if p_max_mv_levels is not null and l_mv_level_count>p_max_mv_levels then
              l_type:='VIEW';
              if g_debug then
                write_to_log_file_n('Max levels of MV reached.p_max_mv_levels='||p_max_mv_levels||
                ', l_mv_level_count='||l_mv_level_count);
              end if;
              --l_status:=check_old_mv_view(l_dep_zero_code_mv(l_index),p_bsc_owner,l_type,p_options,p_number_options);
              l_status:=check_old_mv_view(l_dep_zero_code_mv(l_index),null,l_type,p_options,p_number_options);
              --check_old_mv_view will drop the MV/View if it already exists and the option in RESET MV LEVELS
            else
              if g_all_levels_mv=false and p_max_mv_levels-1=p_ordered_summary_mv_rank(j) then
              --this is the highest level of the mv. beyond this, they are all views.
                l_create_non_unique_index:=true;
                write_to_log_file('p_max_mv_levels='||p_max_mv_levels||' p_ordered_summary_mv_rank='||p_ordered_summary_mv_rank(j));
                if l_create_non_unique_index and g_debug then
                  write_to_log_file('p_create_non_unique_index=true');
                 end if;
              else
                l_create_non_unique_index:=false;
              end if;
              l_type:='MV';
              if create_mv_normal(
                p_kpi,
                l_dep_zero_code_mv(l_index),
                p_bsc_owner,
                l_child_mv,
                l_number_child_mv,
                p_options,
                p_number_options,
                p_apps_origin,
                l_type,
                l_create_non_unique_index
                )=false then
                return false;
              end if;
            end if;
          else
            if g_debug then
              write_to_log_file_n('Could not find p_ordered_summary_mv(j) in list of dep between zero code mv'||
              ' and summary mv. Could not create zero code mv');
            end if;
          end if;
          --------------------------
        end if;
      end loop;
    end loop;
  else
    if g_debug then
      write_to_log_file_n('No zero code MV to create');
    end if;
  end if;--if l_number_zero_code_mv>0 then
  ------------------------------------------
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in create_zero_code_mv_kpi '||sqlerrm);
  return false;
End;

function get_ordered_mv_list(
p_kpi varchar2,
p_apps_origin varchar2,
p_parent_summary_mv out nocopy BSC_IM_UTILS.varchar_tabletype,
p_child_summary_mv out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_pc_mv out nocopy number,
p_ordered_summary_mv out nocopy BSC_IM_UTILS.varchar_tabletype,
p_ordered_summary_mv_rank out nocopy BSC_IM_UTILS.number_tabletype,
p_number_ordered_summary_mv out nocopy number,
p_max_rank out nocopy number
)return boolean is
-------------------------------------------------------------------------
l_summary_mv BSC_IM_UTILS.varchar_tabletype;
l_object_type BSC_IM_UTILS.varchar_tabletype;
l_description BSC_IM_UTILS.varchar_tabletype;
l_property BSC_IM_UTILS.varchar_tabletype;
l_number_summary_mv number;
-------------------------------------------------------------------------
Begin
  if g_debug then
    write_to_log_file_n('In get_ordered_mv_list '||p_kpi||' '||p_apps_origin);
  end if;
  g_kpi:=p_kpi;
  if BSC_IM_INT_MD.get_object(
    p_kpi,
    p_apps_origin,
    'SUMMARY MV',
    l_summary_mv,
    l_object_type,
    l_description,
    l_number_summary_mv)=false then
    return false;
  end if;
  if g_debug then
    write_to_log_file_n('The summary MV for this KPI');
    for i in 1..l_number_summary_mv loop
      write_to_log_file(l_summary_mv(i)||' '||l_object_type(i));
    end loop;
  end if;
  ------------------------------------------------
  --get the relationship between these objects
  declare
    ll_object_name BSC_IM_UTILS.varchar_tabletype;
    ll_object_type BSC_IM_UTILS.varchar_tabletype;
    ll_description BSC_IM_UTILS.varchar_tabletype;
    ll_property BSC_IM_UTILS.varchar_tabletype;
    ll_number_object number;
  begin
    p_number_pc_mv:=0;
    for i in 1..l_number_summary_mv loop
      ll_number_object:=0;
      if BSC_IM_INT_MD.get_object(
        l_summary_mv(i),
        p_apps_origin,
        'MV DEPENDENCY',
        ll_object_name,
        ll_object_type,
        ll_description,
        ll_number_object)=false then
        return false;
      end if;
      for j in 1..ll_number_object loop
        p_number_pc_mv:=p_number_pc_mv+1;
        p_parent_summary_mv(p_number_pc_mv):=l_summary_mv(i);
        p_child_summary_mv(p_number_pc_mv):=ll_object_name(j);
      end loop;
    end loop;
    if g_debug then
      write_to_log_file_n('The parent child relations: parent child');
      for i in 1..p_number_pc_mv loop
        write_to_log_file(p_parent_summary_mv(i)||' '||p_child_summary_mv(i));
      end loop;
    end if;
    if BSC_IM_UTILS.get_rank(
      p_parent_summary_mv,
      p_child_summary_mv,
      p_number_pc_mv,
      p_ordered_summary_mv,
      p_ordered_summary_mv_rank,
      p_number_ordered_summary_mv,
      p_max_rank)=false then
      return false;
    end if;
    for i in 1..l_number_summary_mv loop
      if BSC_IM_UTILS.in_array(p_ordered_summary_mv,p_number_ordered_summary_mv,l_summary_mv(i))=false then
        p_number_ordered_summary_mv:=p_number_ordered_summary_mv+1;
        p_ordered_summary_mv(p_number_ordered_summary_mv):=l_summary_mv(i);
        p_ordered_summary_mv_rank(p_number_ordered_summary_mv):=0;
      end if;
    end loop;
    if g_debug then
      write_to_log_file_n('The ordered summary MV list');
      for i in 1..p_number_ordered_summary_mv loop
        write_to_log_file(p_ordered_summary_mv(i)||' '||p_ordered_summary_mv_rank(i));
      end loop;
    end if;
  end;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in get_ordered_mv_list '||sqlerrm);
  return false;
End;

function init_all return boolean is
Begin
  g_status:=true;
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

procedure set_globals(
p_debug boolean) is
Begin
  g_debug:=p_debug;
  BSC_IM_UTILS.set_globals(g_debug);
  BSC_IM_INT_MD.set_globals(g_debug);
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  null;
End;

--------------------------------------------------------------------------
function refresh_mv_kpi(
p_kpi varchar2,
p_apps_origin varchar2,
p_options BSC_IM_UTILS.varchar_tabletype,
p_number_options number
) return boolean is
-------------------------------------------------------------------------
l_parent_summary_mv BSC_IM_UTILS.varchar_tabletype;
l_child_summary_mv BSC_IM_UTILS.varchar_tabletype;
l_number_pc_mv number;
-------------------------------------------------------------------------
l_ordered_summary_mv BSC_IM_UTILS.varchar_tabletype;
l_ordered_summary_mv_rank BSC_IM_UTILS.number_tabletype;
l_number_ordered_summary_mv number;
-------------------------------------------------------------------------
l_max_rank number;
l_bsc_owner varchar2(200);
-------------------------------------------------------------------------
l_dummy_mv BSC_IM_UTILS.varchar_tabletype;
l_number_dummy_mv number;
-------------------------------------------------------------------------
l_zero_code_mv BSC_IM_UTILS.varchar_tabletype;
l_object_type BSC_IM_UTILS.varchar_tabletype;
l_description BSC_IM_UTILS.varchar_tabletype;
l_number_zero_code_mv number;
-------------------------------------------------------------------------
l_start_time varchar2(200);
l_end_time varchar2(200);
-------------------------------------------------------------------------
Begin
  if g_debug then
    write_to_log_file_n('In refresh_mv_kpi for kpi '||p_kpi||get_time);
  end if;
  g_kpi:=p_kpi;
  if g_bsc_owner is null then
    g_bsc_owner:=BSC_IM_UTILS.get_bsc_owner;
  end if;
  l_bsc_owner:=g_bsc_owner;
  ------------------------------------------------------------
  --find all the ordered list of MV to refresh
  ------------------------------------------------
  --get the ordered list of mv
  if get_ordered_mv_list(
    p_kpi,
    p_apps_origin,
    l_parent_summary_mv,
    l_child_summary_mv,
    l_number_pc_mv,
    l_ordered_summary_mv,
    l_ordered_summary_mv_rank,
    l_number_ordered_summary_mv,
    l_max_rank
    )=false then
    return false;
  end if;
  ------------------------------------------------
  for i in 0..l_max_rank loop
    for j in 1..l_number_ordered_summary_mv loop
      if l_ordered_summary_mv_rank(j)=i then
        if BSC_IM_UTILS.is_mview(l_ordered_summary_mv(j),null) then
          l_start_time:=BSC_IM_UTILS.get_time;
          if BSC_IM_UTILS.refresh_mv(l_ordered_summary_mv(j),null,p_kpi,p_options,p_number_options)=false then
            g_status_message:=BSC_IM_UTILS.g_status_message;
            return false;
          end if;
          if g_debug then
            write_to_log_file_n('MV Refresh Complete '||get_time);
          end if;
          if object_index_validation(l_ordered_summary_mv(j),null,p_kpi,p_apps_origin,
            p_options,p_number_options,null)=false then
            return false;
          end if;
          ----------------
        else
          if g_debug then
            write_to_log_file_n('Object '||l_ordered_summary_mv(j)||' not a MV');
          end if;
        end if;
        --------------------------------------------
      end if;
    end loop;
  end loop;
  --------------------------------------------
  --the zero code mv
  if BSC_IM_INT_MD.get_object(
    p_kpi,
    p_apps_origin,
    'ZERO CODE MV',
    l_zero_code_mv,
    l_object_type,
    l_description,
    l_number_zero_code_mv)=false then
    return false;
  end if;
  if l_number_zero_code_mv>0 then
    for i in 1..l_number_zero_code_mv loop
      if BSC_IM_UTILS.is_mview(l_zero_code_mv(i),null) then
        l_start_time:=BSC_IM_UTILS.get_time;
        if BSC_IM_UTILS.refresh_mv(l_zero_code_mv(i),null,p_kpi,p_options,p_number_options)=false then
          g_status_message:=BSC_IM_UTILS.g_status_message;
          return false;
        end if;
        if g_debug then
          write_to_log_file_n('MV Refresh Complete '||get_time);
        end if;
        if object_index_validation(l_zero_code_mv(i),null,p_kpi,p_apps_origin,
          p_options,p_number_options,null)=false then
          return false;
        end if;
      else
        if g_debug then
          write_to_log_file_n('Object '||l_zero_code_mv(i)||' not a MV');
        end if;
      end if;
    end loop;
  end if;
  --------------------------------------------
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in refresh_mv_kpi '||sqlerrm||get_time);
  return false;
End;

--if user needs to  refresh just an MV
function refresh_mv(
p_mv varchar2,
p_kpi varchar2,
p_options BSC_IM_UTILS.varchar_tabletype,
p_number_options number
) return boolean is
l_bsc_owner varchar2(200);
-------------------------------------------------------------------------
Begin
  g_kpi:=p_kpi;
  if BSC_IM_UTILS.get_option_value(p_options,p_number_options,'DEBUG LOG')='Y' then
    g_debug:=true;
  end if;
  if BSC_IM_UTILS.get_option_value(p_options,p_number_options,'TRACE')='Y' then
    BSC_IM_UTILS.set_trace;
  end if;
  if g_debug then
    write_to_log_file_n('In refresh_mv '||p_mv||get_time);
  end if;
  if g_bsc_owner is null then
    g_bsc_owner:=BSC_IM_UTILS.get_bsc_owner;
  end if;
  l_bsc_owner:=g_bsc_owner;
  --first see if this is an MV. if not, no need to process
  if BSC_IM_UTILS.is_mview(p_mv,null)=false then
    if g_debug then
      write_to_log_file_n('Not an MV. Cannot do MV refresh');
    end if;
    return true;
  end if;
  /*
  we need to get the index info of the mv from the database. if there is a full refresh
  then we need to
  1. grab the index info into memory (BSC_im_utils.refresh_mv)
  2. drop the indexes (BSC_im_utils.refresh_mv)
  3. mv full refresh (BSC_im_utils.refresh_mv)
  4. re-create the indexes back (BSC_im_utils.refresh_mv)
  5. validate the indexes.(BSC_IM_UTILS.object_index_validation)
  6. if there are missing indexes, create them with default storage
     and tablespace(BSC_IM_UTILS.object_index_validation)
  */
  if BSC_IM_UTILS.refresh_mv(p_mv,null,p_kpi,p_options,p_number_options)=false then
    g_status_message:=BSC_IM_UTILS.g_status_message;
    return false;
  end if;
  if g_debug then
    write_to_log_file_n('MV Refresh Complete '||get_time);
  end if;
  --now do the index validation. for the mv make sure that all indexes are in place
  if object_index_validation(p_mv,null,p_kpi,'BSC',p_options,p_number_options,null)=false then
    return false;
  end if;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in refresh_mv '||sqlerrm||get_time);
  return false;
End;
------------------------------------------------------------------------

function get_dummy_mv(
p_mv_name varchar2,
p_mv_owner varchar2,
p_dummy_mv out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_dummy_mv out nocopy number
)return boolean is
l_mv_name varchar2(200);
i integer;
Begin
  if g_debug then
    write_to_log_file_n('In get_dummy_mv');
  end if;
  p_number_dummy_mv:=0;
  i:=1;
  loop
    l_mv_name:=substr(substr(p_mv_name,1,length(p_mv_name)-3),1,24)||'_D'||i||'MV';
    if BSC_IM_UTILS.check_mv(l_mv_name,null)=false then
      exit;
    else
      p_number_dummy_mv:=p_number_dummy_mv+1;
      p_dummy_mv(p_number_dummy_mv):=l_mv_name;
      i:=i+1;
    end if;
  end loop;
  if g_debug then
    write_to_log_file_n('Dummy MVs');
    for i in 1..p_number_dummy_mv loop
      write_to_log_file(p_dummy_mv(i));
    end loop;
  end if;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in get_dummy_mv '||sqlerrm||get_time);
  return false;
End;

---------------------------------------------------------------
function drop_mv_kpi(
p_kpi varchar2,
p_apps_origin varchar2,
p_options BSC_IM_UTILS.varchar_tabletype,
p_number_options number
) return boolean is
-------------------------------------------------------------------------
l_parent_summary_mv BSC_IM_UTILS.varchar_tabletype;
l_child_summary_mv BSC_IM_UTILS.varchar_tabletype;
l_number_pc_mv number;
-------------------------------------------------------------------------
l_ordered_summary_mv BSC_IM_UTILS.varchar_tabletype;
l_ordered_summary_mv_rank BSC_IM_UTILS.number_tabletype;
l_number_ordered_summary_mv number;
-------------------------------------------------------------------------
l_max_rank number;
l_bsc_owner varchar2(200);
-------------------------------------------------------------------------
l_zero_code_mv BSC_IM_UTILS.varchar_tabletype;
l_object_type BSC_IM_UTILS.varchar_tabletype;
l_description BSC_IM_UTILS.varchar_tabletype;
l_number_zero_code_mv number;
-------------------------------------------------------------------------
Begin
  if g_debug then
    write_to_log_file_n('In drop_mv_kpi for kpi '||p_kpi||get_time);
  end if;
  g_kpi:=p_kpi;
  if g_bsc_owner is null then
    g_bsc_owner:=BSC_IM_UTILS.get_bsc_owner;
  end if;
  l_bsc_owner:=g_bsc_owner;
  --get the ordered list of mv
  if get_ordered_mv_list(
    p_kpi,
    p_apps_origin,
    l_parent_summary_mv,
    l_child_summary_mv,
    l_number_pc_mv,
    l_ordered_summary_mv,
    l_ordered_summary_mv_rank,
    l_number_ordered_summary_mv,
    l_max_rank
    )=false then
    return false;
  end if;
  ------------------------------------------------------
  --the zero code mv
  if BSC_IM_INT_MD.get_object(
    p_kpi,
    p_apps_origin,
    'ZERO CODE MV',
    l_zero_code_mv,
    l_object_type,
    l_description,
    l_number_zero_code_mv)=false then
    return false;
  end if;
  if l_number_zero_code_mv>0 then
    for i in 1..l_number_zero_code_mv loop
      if BSC_IM_UTILS.drop_object(l_zero_code_mv(i),null)=false then
        null;
      end if;
      if BSC_IM_UTILS.drop_synonym(l_zero_code_mv(i))=false then
        null;
      end if;
    end loop;
  end if;
  ------------------------------------------------------
  for i in 0..l_max_rank loop
    for j in 1..l_number_ordered_summary_mv loop
      if l_ordered_summary_mv_rank(j)=l_max_rank-i then
        if g_debug then
          write_to_log_file_n('Drop '||l_ordered_summary_mv(j));
        end if;
        if BSC_IM_UTILS.drop_object(l_ordered_summary_mv(j),null)=false then
          null;
        end if;
        if BSC_IM_UTILS.drop_synonym(l_ordered_summary_mv(j))=false then
          null;
        end if;
      end if;
    end loop;
  end loop;
  --------------------------------------------------
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in drop_mv_kpi '||sqlerrm||get_time);
  return false;
End;

function drop_mv(
p_mv varchar2,
p_options BSC_IM_UTILS.varchar_tabletype,
p_number_options number
)return boolean is
l_bsc_owner varchar2(200);
Begin
  if g_bsc_owner is null then
    g_bsc_owner:=BSC_IM_UTILS.get_bsc_owner;
  end if;
  l_bsc_owner:=g_bsc_owner;
  if BSC_IM_UTILS.is_mview(p_mv,null) then
    if BSC_IM_UTILS.drop_mv(p_mv,null)=false then
      null;
    end if;
    if BSC_IM_UTILS.drop_synonym(p_mv)=false then
      null;
    end if;
  else
    if BSC_IM_UTILS.drop_view(p_mv,null)=false then
      null;
    end if;
  end if;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in drop_mv '||sqlerrm||get_time);
  return false;
End;
---------------------------------------------------------------

function drop_summary_objects(
p_mv_list varchar2,
p_synonym_list varchar2,
p_options varchar2,
p_error_message out nocopy varchar2
) return boolean is
l_method varchar2(200);
l_mv BSC_IM_UTILS.varchar_tabletype;
l_mv_owner BSC_IM_UTILS.varchar_tabletype;
l_s_table BSC_IM_UTILS.varchar_tabletype;
l_number_mv number;
l_list varchar2(32000);
l_options BSC_IM_UTILS.varchar_tabletype;
l_number_options number;
Begin
  p_error_message:=null;
  l_number_options:=0;
  if BSC_IM_UTILS.parse_values(p_options,',',l_options,l_number_options)=false then
    return false;
  end if;
  if BSC_IM_UTILS.get_option_value(l_options,l_number_options,'DEBUG LOG')='Y' then
    g_debug:=true;
    set_globals(g_debug);
  end if;
  if BSC_IM_UTILS.get_option_value(l_options,l_number_options,'TRACE')='Y' then
    BSC_IM_UTILS.set_trace;
  end if;
  if g_debug then
    write_to_log_file_n('In drop_summary_objects '||get_time);
    write_to_log_file('p_mv_list='||p_mv_list);
    write_to_log_file('p_synonym_list='||p_synonym_list);
    write_to_log_file('p_options='||p_options);
  end if;
  l_number_mv:=0;
  if BSC_IM_UTILS.parse_values(p_mv_list,',',l_mv,l_number_mv)=false then
    return false;
  end if;
  if BSC_IM_UTILS.parse_values(p_synonym_list,',',l_s_table,l_number_mv)=false then
    return false;
  end if;
  for i in 1..l_number_mv loop
    l_mv_owner(i):=BSC_IM_UTILS.get_table_owner(l_mv(i));
  end loop;
  if g_debug then
    write_to_log_file_n('The MV, S table and the owner');
    for i in 1..l_number_mv loop
      write_to_log_file(l_mv(i)||' '||l_s_table(i)||' '||l_mv_owner(i));
    end loop;
  end if;
  --drop the table, mv and the synonym
  for i in 1..l_number_mv loop
    if BSC_IM_UTILS.drop_mv(l_mv(i),l_mv_owner(i))=false then
      null;
    end if;
    if BSC_IM_UTILS.drop_synonym(l_mv(i))=false then
      null;
    end if;
    if BSC_IM_UTILS.drop_table(l_s_table(i),l_mv_owner(i))=false then
      null;
    end if;
    if BSC_IM_UTILS.drop_synonym(l_s_table(i))=false then
      null;
    end if;
  end loop;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  p_error_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in drop_summary_objects '||sqlerrm||get_time);
  return false;
End;

/*
check to make sure that all indexes are present in the database.
if any are missing, create them
This API is actually used for error handling. In the initial refresh,
we drop the MV indexes, the MV refresh could have succeeded but the
index creation could have failed. Next time around, we should correct
this problem and create the missing indexes.
*/
function object_index_validation(
p_object varchar2,
p_owner varchar2,
p_kpi varchar2,
p_apps_origin varchar2,
p_options BSC_IM_UTILS.varchar_tabletype,
p_number_options number,
p_create_non_unique_index boolean
)return boolean is
l_apps_origin varchar2(200);
l_owner varchar2(200);
---BSC----------------------
l_s_tables BSC_IM_UTILS.varchar_tabletype;
l_number_s_tables number;
l_fk BSC_IM_UTILS.varchar_tabletype;
l_number_fk number;
-------------------------------------------------------------------------
l_index BSC_IM_UTILS.varchar_tabletype;
l_uniqueness  BSC_IM_UTILS.varchar_tabletype;
l_tablespace  BSC_IM_UTILS.varchar_tabletype;
l_initial_extent  BSC_IM_UTILS.number_tabletype;
l_next_extent  BSC_IM_UTILS.number_tabletype;
l_max_extents  BSC_IM_UTILS.number_tabletype;
l_pct_increase   BSC_IM_UTILS.number_tabletype;
l_number_index  number;
------
l_ind_name  BSC_IM_UTILS.varchar_tabletype;
l_ind_col  BSC_IM_UTILS.varchar_tabletype;
l_number_ind_col  number;
-------------------------------------------------------------------------
l_stmt varchar2(20000);
l_index_tablespace varchar2(200);
l_index_storage varchar2(2000);
-------------------------------------------------------------------------
l_create_non_unique_index boolean;
-------------------------------------------------------------------------

l_zero_code_cols dbms_sql.varchar2_table;
-----
l_higher_level_view_exists boolean ;
l_time_columns VARCHAR2(100):= '(PERIODICITY_ID, YEAR, PERIOD)';
l_index_counter number := 1;
l_nonzero_code_cols dbms_sql.varchar2_table;
l_is_zmv boolean;
l_zmv_exists_for_mv boolean;
l_mv_name_for_zmv varchar2(100);

Begin
  return true;
  -- this is not required as we are calling create_mv_index already from refresh
  if g_debug then
    write_to_log_file_n('In object_index_validation for '||p_object||' '||p_owner||' p_apps_origin '||p_apps_origin||
    ' p_kpi '||p_kpi);
  end if;
  g_kpi:=p_kpi;
  l_create_non_unique_index:=p_create_non_unique_index ;
  l_apps_origin:=p_apps_origin;
  l_owner:=p_owner;
  if l_owner is null then
    l_owner:=bsc_im_utils.get_table_owner(p_object);
    if g_debug then
      write_to_log_file('l_owner='||l_owner);
    end if;
  end if;
  -----------------
  l_index_tablespace:=BSC_IM_UTILS.get_option_value(p_options,p_number_options,'INDEX TABLESPACE');
  l_index_storage:=BSC_IM_UTILS.get_option_value(p_options,p_number_options,'INDEX STORAGE');
  if l_index_tablespace is not null then
    if instr(lower(l_index_tablespace),'tablespace')<=0 then
      l_index_tablespace:=' tablespace '||l_index_tablespace;
    end if;
  end if;
  if l_index_storage is not null then
    if instr(lower(l_index_storage),'storage')<=0 then
      l_index_storage:=' storage '||l_index_storage;
    end if;
  end if;
  -----------------
  if l_apps_origin='BSC' then
    if BSC_BSC_ADAPTER.get_s_tables_for_mv(p_object,l_s_tables,l_number_s_tables)=false then
      return false;
    end if;
    if l_number_s_tables=0 then
      if g_debug then
        write_to_log_file_n('No s tables found for '||p_object||'. Do Validations to do...');
      end if;
      return true;
    end if;
    if BSC_BSC_ADAPTER.get_table_fks(l_s_tables,l_number_s_tables,l_fk,l_number_fk)=false then
      return false;
    end if;
    --first get the index info from the database
    if BSC_IM_UTILS.get_table_indexes(
      p_object,
      l_owner,
      l_index,
      l_uniqueness,
      l_tablespace,
      l_initial_extent,
      l_next_extent,
      l_max_extents,
      l_pct_increase,
      l_number_index,
      l_ind_name,
      l_ind_col,
      l_number_ind_col)=false then
      return false;
    end if;
    if create_mv_index(p_object,
       p_owner,
       p_kpi,
       p_apps_origin,
       l_index_tablespace,
       l_index_storage,
       p_create_non_unique_index,
       true-- called from refresh
      )= false then
      return false;
    else
     return true;
    end if;


    --quick check
    /*if l_number_index>=l_number_fk-3 then
      if g_debug then
        write_to_log_file_n('All indexes present.');
      end if;
    else
      --need to create missing indexes
      if g_debug then
        write_to_log_file_n('Going to create missing indexes');
      end if;
      if l_create_non_unique_index is null then
        --if the parent of this mv is a view, then create the non-unique indexes
        if BSC_IM_UTILS.is_parent_of_type_present(p_object,'VIEW') then
          l_create_non_unique_index:=true;
        else
          l_create_non_unique_index:=false;
        end if;
      end if;
      if l_create_non_unique_index then
        --try the non unique ones
        for i in 1..l_number_fk loop
          if l_fk(i)<>'PERIOD' and l_fk(i)<>'TYPE' and l_fk(i)<>'PERIODICITY_ID' and
            l_fk(i)<>'YEAR' then
            l_stmt:='create index '||l_owner||'.'||p_object||'N'||i||' on '||l_owner||'.'||p_object||'(';
            l_stmt:=l_stmt||l_fk(i)||',PERIODICITY_ID,YEAR,PERIOD)';
            --Enh#4239064: create index in parallel
            l_stmt:=l_stmt||l_index_tablespace||' '||l_index_storage||' parallel';
            if BSC_IM_UTILS.create_index(l_stmt,null)=false then
              return false;
            end if;
            --Enh#4239064: set to noparallel
            execute immediate 'alter index '||l_owner||'.'||p_object||'N'||i||' noparallel';
          end if;
        end loop;
      end if;
    end if;
    */
  end if;--if l_apps_origin='BSC' then

  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in object_index_validation '||sqlerrm);
  return false;
End;

function check_old_mv_view(
p_mv_name varchar2,
p_mv_owner varchar2,
p_type varchar2,
p_options BSC_IM_UTILS.varchar_tabletype,
p_number_options number
)return varchar2 is
l_status varchar2(200);
Begin
  l_status:='CONTINUE';
  --check to see if MV RECREATE flag is off and MV already exists. then no need to do anything
  if BSC_IM_UTILS.get_option_value(p_options,p_number_options,'RECREATE')='Y' then
    if g_debug then
      write_to_log_file_n('MV RECREATE flag TRUE. Dropping the MV/View first first');
    end if;
    --p_mv_owner
    if drop_mv(p_mv_name,p_options,0)=false then
      null;
    end if;
  elsif BSC_IM_UTILS.get_option_value(p_options,p_number_options,'RESET MV LEVELS')='Y' then
    if p_type='MV' then
      if BSC_IM_UTILS.check_mv(p_mv_name,null) then
        if g_debug then
          write_to_log_file_n('MV '||p_mv_name||' already present');
        end if;
        return 'ALREADY PRESENT';
      else
        if g_debug then
          write_to_log_file_n(p_mv_name||' is a view...dropping');
        end if;
        if BSC_IM_UTILS.drop_view(p_mv_name,null)=false then
          null;
        end if;
      end if;
    elsif p_type='VIEW' then
      if BSC_IM_UTILS.check_view(p_mv_name,null) then
        if g_debug then
          write_to_log_file_n('View '||p_mv_name||' already present');
        end if;
        return 'ALREADY PRESENT';
      else
        if g_debug then
          write_to_log_file_n(p_mv_name||' is a MV...dropping');
        end if;
        if drop_mv(p_mv_name,p_options,0)=false then
          null;
        end if;
      end if;
    end if;
  else
    if p_type='MV' then
      if BSC_IM_UTILS.check_mv(p_mv_name,null) then
        if g_debug then
          write_to_log_file_n('MV RECREATE flag FALSE. MV already exists. No need to create the MV');
        end if;
        return 'ALREADY PRESENT';
      end if;
    elsif p_type='VIEW' then
      if BSC_IM_UTILS.check_view(p_mv_name,null) then
        if g_debug then
          write_to_log_file_n('MV RECREATE flag FALSE. View already exists. No need to create the View');
        end if;
        return 'ALREADY PRESENT';
      end if;
    end if;
  end if;
  return l_status;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in check_old_mv_view '||sqlerrm);
  return 'ERROR';
End;

END BSC_MV_ADAPTER;

/
