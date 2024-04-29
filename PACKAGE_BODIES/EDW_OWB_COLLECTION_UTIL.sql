--------------------------------------------------------
--  DDL for Package Body EDW_OWB_COLLECTION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_OWB_COLLECTION_UTIL" AS
/*$Header: EDWCOLUB.pls 120.7 2007/08/20 10:27:45 karthmoh ship $*/

l_mapping_id number;
l_mapping_name varchar2(200);
l_dim_usage_id number;
l_dim_id number;

--primary src
l_primary_src varchar2(300);
l_primary_src_ru number;

l_child_level varcharTableType;
l_child_level_fk varcharTableType;
l_parent_level varcharTableType;
l_parent_level_pk varcharTableType;
l_parent_map   numberTableType;
l_parent_primary_src numberTableType;
l_parent_primary_target numberTableType;
l_number_children number:=1;

--these hold the final ranks
l_hier		varcharTableType;
l_number_levels_hier numberTableType;
l_relation_level varcharTableType;
l_relation_level_status varcharTableType;
l_relation_number_of_children numberTableType;
l_relation_map  numberTableType;--the mapping id
l_running_count number;
l_relation_child_levels varcharTableType;
l_relation_child_fks varcharTableType;
l_relation_parent_pks   varcharTableType;
l_relation_primary_src numberTableType;
l_relation_primary_target numberTableType;
l_relation_number_of_levels number;

--the mapping attributes
l_dim_col  varcharTableType;
l_level_name varcharTableType;
l_level_col varcharTableType;
l_number_mapping integer;




--not checked
cursor c0(p_dim_name varchar2) is
select
	b.mapping_id,
	c.target_usage_id,
	a.dim_id,
    ltc.name,
    ltc.elementid
from
    edw_dimensions_md_v a,
    edw_tables_md_v ltc,
    edw_pvt_map_properties_md_v b,
    edw_pvt_map_targets_md_v c
where
    a.dim_name =p_dim_name
and b.primary_target=a.dim_id
and c.mapping_id=b.mapping_id
and c.target_id=a.dim_id
and ltc.elementid=b.primary_source;
--not checked
cursor c2II(p_dim_id number) is
select distinct
    child_relation.name,
    parent_relation.name,
    child_fk_item.column_name,
    parent_pk_item.column_name,
    nvl(parent_map.mapping_id,0),
    nvl(parent_map.primary_source,0),
    nvl(parent_map.primary_target,0)
from
    edw_levels_md_v lvl_child,
    edw_levels_md_v lvl_parent,
    edw_foreign_keys_md_v child_fk,
    edw_pvt_key_columns_md_v child_fk_set_usage,
    edw_pvt_columns_md_v     child_fk_item,
    edw_unique_keys_md_v  parent_pk,
    edw_pvt_key_columns_md_v parent_pk_set_usage,
    edw_pvt_columns_md_v           parent_pk_item,
    edw_tables_md_v child_relation,
    edw_tables_md_v parent_relation,
    edw_pvt_level_relation_md_v lvl_rel,
    edw_hierarchies_md_v hier,
    edw_pvt_map_properties_md_v parent_map
where
    hier.dim_id=p_dim_id
and lvl_rel.hierarchy_id=hier.hier_id
and lvl_child.level_id=lvl_rel.child_level_id
and lvl_parent.level_id=lvl_rel.parent_level_id
and child_fk.entity_id=child_relation.elementid
and child_fk.key_id=parent_pk.key_id
and child_fk_set_usage.key_id=child_fk.foreign_key_id
and child_fk_item.column_id=child_fk_set_usage.column_id
and child_fk_item.parent_object_id=child_relation.elementid
and parent_pk.entity_id=parent_relation.elementid
and parent_pk_set_usage.key_id=parent_pk.key_id
and parent_pk_item.column_id=parent_pk_set_usage.column_id
and parent_pk_item.parent_object_id=parent_relation.elementid
and parent_relation.name=lvl_parent.level_name||'_LTC'
and child_relation.name=lvl_child.level_name||'_LTC'
and parent_map.primary_target(+)=parent_relation.elementid;
--not checked
--for single level dims
cursor c2II_I(p_dim_id number) is
select distinct
    child_relation.name,
    null,
    null,
    parent_pk_item.column_name,--actually child pk
    parent_map.mapping_id, --actually child map
    nvl(parent_map.primary_source,0),
    nvl(parent_map.primary_target,0)
from
    edw_levels_md_v lvl_child,
    edw_unique_keys_md_v  parent_pk,
    edw_pvt_key_columns_md_v parent_pk_set_usage,
    edw_pvt_columns_md_v           parent_pk_item,
    edw_tables_md_v child_relation,
    edw_pvt_level_relation_md_v lvl_rel,
    edw_hierarchies_md_v hier,
    edw_pvt_map_properties_md_v parent_map
where
    hier.dim_id=p_dim_id
and lvl_rel.hierarchy_id=hier.hier_id
and lvl_child.level_id=lvl_rel.child_level_id
and parent_pk.entity_id=child_relation.elementid
and parent_pk_set_usage.key_id=parent_pk.key_id
and parent_pk_item.column_id=parent_pk_set_usage.column_id
and parent_pk_item.parent_object_id=child_relation.elementid
and child_relation.name=lvl_child.level_name||'_LTC'
and parent_map.primary_target(+)=child_relation.elementid;

--not checked
--get the attribute mapping
cursor c3(p_dimUsageId number, p_mapping_id number) is
select
    upper(dim_item.column_name),
    upper(relation.name),
    upper(level_item.column_name)
from
    edw_pvt_map_properties_md_v map_properties,
    edw_pvt_map_sources_md_v map_sources,
    (select * from edw_pvt_map_columns_md_v where mapping_id=p_mapping_id) map_columns,
    edw_tables_md_v relation,
    edw_pvt_columns_md_v	dim_item,
    edw_pvt_columns_md_v	level_item
where
  map_properties.mapping_id=p_mapping_id
  and map_sources.mapping_id=map_properties.mapping_id
  and map_columns.Target_column_id=dim_item.column_id
  and map_columns.source_column_id=level_item.column_id
  and relation.elementid=map_sources.source_id
  and map_columns.Source_usage_id=map_sources.Source_usage_id;

--get the rowid mappings
cursor c4(p_dim_id number) is
select
    lvl.level_prefix||'_'||item.column_name||'_ROWID',
    lvl.level_name||'_LTC',
    'ROWID'
from
    edw_levels_md_v lvl,
    edw_pvt_level_columns_md_v  item
where
    lvl.dim_id=p_dim_id
and item.level_id=lvl.level_id
and item.column_name like '%_PK';

--not checked
cursor c5(p_target_relation varchar2) IS
select
    	map.mapping_id,
        nvl(map.primary_source,0),
        nvl(map.primary_target,0)
from
	edw_pvt_map_properties_md_v map,
	edw_relations_md_v	relation
where
	map.primary_target=relation.relation_id
and	relation.relation_name=p_target_relation;

--misc veriables
t_parent_level varchar2(300);
l_top_level varchar2(300);
l_top_index number;
l_found boolean:=TRUE;
l_child_true boolean;
l_child_found boolean:=false;
l_one_level_dim boolean:=false;
l_count integer;
l_start integer;
l_end integer;




PROCEDURE set_up(p_dimension_name in varchar2) IS
Begin
l_found:=true;
l_child_found:=false;
l_one_level_dim:=false;
l_dim_id:=null;
l_dim_usage_id:=null;
l_mapping_id:=null;
open c0(p_dimension_name);
fetch c0 into l_mapping_id, l_dim_usage_id, l_dim_id,
    g_lowest_level, g_lowest_level_id;
close c0;
l_number_children:=1;
l_relation_number_of_levels:=1;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in set_up '||sqlerrm||get_time);
end;--procedure set_up(p_dimension_name in varchar2) IS

procedure get_lowest_level(
 p_level out NOCOPY varchar2,
 p_level_id out NOCOPY number) is
begin
  p_level:=g_lowest_level;
  p_level_id:=g_lowest_level_id;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_lowest_level '||sqlerrm||get_time);
end;--procedure get_lowest_level


procedure Get_Level_Relations(
	p_levels out NOCOPY varcharTableType,
	p_level_status out NOCOPY varcharTableType,
	p_child_level_number out NOCOPY numberTableType,
	p_child_levels out NOCOPY varcharTableType,
	p_child_fk out NOCOPY varcharTableType,
        p_parent_pk out NOCOPY varcharTableType,
        p_number_levels out NOCOPY integer) IS
begin
l_found:=true;
l_child_found:=false;
l_one_level_dim:=false;
p_number_levels:=0;
if l_dim_id is null OR l_dim_usage_id is null OR  l_mapping_id is null then
 return;
end if;
if g_debug then
  write_to_log_file_n('Opening c2II using '||l_dim_id);
end if;
open c2II(l_dim_id);
loop
  fetch c2II into
    l_child_level(l_number_children),
    l_parent_level(l_number_children),
    l_child_level_fk(l_number_children),
    l_parent_level_pk(l_number_children),
    l_parent_map(l_number_children),
    l_parent_primary_src(l_number_children),
    l_parent_primary_target(l_number_children);
  exit when c2II%NOTFOUND;
  l_number_children:=l_number_children+1;
end loop;
l_number_children:=l_number_children-1;
close c2II;
if g_debug then
  write_to_log_file_n('Processed c2II');
end if;
if g_debug then
  write_to_log_file_n('The results of cursor c2II, number of children is '||l_number_children);
  write_to_log_file('l_child_level  l_parent_level   l_child_level_fk  l_parent_level_pk '||
                ' l_parent_map  l_parent_primary_src  l_parent_primary_target ');
  for i in 1..l_number_children loop
    write_to_log_file(l_child_level(i)||'   '||l_parent_level(i)||'  '||l_child_level_fk(i)||'   '||
        l_parent_level_pk(i)||'   '||l_parent_map(i)||'   '||l_parent_primary_src(i)||'  '||
        l_parent_primary_target(i));
  end loop;
end if;
if l_number_children=0 then --this could be a single level dim
  write_to_log_file_n('This is a single level dimension');
  l_number_children:=1;
  l_one_level_dim:=true;
  open c2II_I(l_dim_id);--for single level dim
  loop
    fetch c2II_I into
    l_child_level(l_number_children),
    l_parent_level(l_number_children),
    l_child_level_fk(l_number_children),
    l_parent_level_pk(l_number_children),
    l_parent_map(l_number_children),
    l_parent_primary_src(l_number_children),
    l_parent_primary_target(l_number_children);
    exit when c2II_I%NOTFOUND;
    l_number_children:=l_number_children+1;
  end loop;
  l_number_children:=l_number_children-1;
  close c2II_I;
  l_relation_map(1):=l_parent_map(l_number_children);
  l_relation_primary_src(1):=l_parent_primary_src(l_number_children);
  l_relation_primary_target(1):=l_parent_primary_target(l_number_children);
  if g_debug then
    write_to_log_file_n('The results of cursor c2II_I, number of children is '||l_number_children);
    write_to_log_file('l_child_level  l_parent_level   l_child_level_fk  l_parent_level_pk '||
                  ' l_parent_map  l_parent_primary_src  l_parent_primary_target ');
    for i in 1..l_number_children loop
      write_to_log_file(l_child_level(i)||'   '||l_parent_level(i)||'  '||l_child_level_fk(i)||'   '||
          l_parent_level_pk(i)||'   '||l_parent_map(i)||'   '||l_parent_primary_src(i)||'  '||
          l_parent_primary_target(i));
    end loop;
  end if;
end if;--if l_number_children=0

if l_number_children=0 then -- we have a problem here
  if g_debug then
    write_to_log_file_n('l_number_children=0. this is a fatal issue. No levels found');
  end if;
  p_levels:=l_relation_level;
  p_level_status:=l_relation_level_status;
  p_child_level_number:=l_relation_number_of_children;
  p_child_levels:=l_relation_child_levels;
  p_child_fk:=l_relation_child_fks;
  p_parent_pk:=l_relation_parent_pks;
  p_number_levels:=0;
  return ;
end if;

if l_one_level_dim = false then
  --logic to give the rank
  --find the parent level
  for i in 1..l_number_children loop
      --find out NOCOPY the child that is never a parent
      t_parent_level:=l_parent_level(i);
      l_found:=FALSE;
      for j in 1..l_number_children loop
          if t_parent_level=l_child_level(j) then
              l_found:=true;
              exit;
          end if;
      end loop;
      if l_found=false then
          l_top_level:=t_parent_level;
          l_top_index:=i;
          exit;
      end if;
  end loop;

  l_count:=1;
  l_start:=1;
  l_end:=1;
  l_relation_level(1):=l_parent_level(l_top_index);
  l_relation_map(1):=l_parent_map(l_top_index);
  l_relation_primary_src(1):=l_parent_primary_src(l_top_index);
  l_relation_primary_target(1):=l_parent_primary_target(l_top_index);
  l_running_count:=0;
  while true loop
  l_relation_number_of_children(l_start):=0;

  if l_start=1 then
      l_relation_level_status(l_start):='P';
  else
      l_relation_level_status(l_start):='I';
  end if;

  l_child_true:=true;--first assume that this is a child
  for i in 1..l_number_children loop
      if l_parent_level(i)=l_relation_level(l_start) then
	  l_child_true:=false;
          -- add the child
          l_relation_map(l_start):=l_parent_map(i);
          l_relation_primary_src(l_start):=l_parent_primary_src(i);
    	  l_relation_primary_target(l_start):=l_parent_primary_target(i);
          l_relation_number_of_children(l_start):=l_relation_number_of_children(l_start)+1;
          l_running_count:=l_running_count+1;
          l_relation_child_levels(l_running_count):=l_child_level(i);
          l_relation_child_fks(l_running_count):=l_child_level_fk(i);
          l_relation_parent_pks(l_running_count):=l_parent_level_pk(i);
        --if it exists, do not add it
        l_found:=false;
        for j in 1..l_end loop
            if l_relation_level(j)=l_child_level(i) then
                l_found:=true;
                exit;
            end if;
       end loop;
       if l_found=false then
        l_end:=l_end+1;
        l_relation_level(l_end):=l_child_level(i);
        l_count:=l_count+1;
       end if;
    end if;
   end loop;--for i in 1..l_number_children loop
  if l_child_true=true AND l_child_found=false then
     l_child_found:=true;
     --this is the child
      l_relation_number_of_children(l_start):=0;
      l_relation_level_status(l_start):='C';
      --l_running_count:=l_running_count+1;
      --l_relation_child_levels(l_running_count):=' ';
      --l_relation_child_fks(l_running_count):=' ';
      --l_relation_parent_pks(l_running_count):=' ';
      open c5(l_relation_level(l_start));
      fetch c5 into
    	l_relation_map(l_start),
    	l_relation_primary_src(l_start),
    	l_relation_primary_target(l_start);
      close c5;
  end if;--if l_child_true=true then

  if l_start>=l_end AND l_child_found=true then
    exit;--all set
  end if;
  l_start:=l_start+1;

 end loop;--while true loop

 l_relation_number_of_levels:=l_count;

else --if l_number_children=1
 l_relation_level:=l_child_level;
 l_relation_level_status(1):='P';
 l_relation_number_of_children(1):=0;
 l_relation_child_levels(1):='';
 l_relation_child_fks(1):='';
 l_relation_parent_pks:=l_parent_level_pk;
 l_relation_number_of_levels:=1;

end if;

--now assign the outputs

p_levels:=l_relation_level;
p_level_status:=l_relation_level_status;
p_child_level_number:=l_relation_number_of_children;
p_child_levels:=l_relation_child_levels;
p_child_fk:=l_relation_child_fks;
p_parent_pk:=l_relation_parent_pks;
p_number_levels:=l_relation_number_of_levels;

Exception when others then
 g_status_message:=sqlerrm;
 write_to_log_file_n('Error in Get_Level_Relations '||sqlerrm);
end; --THE procedure

--get the mapping ids
PROCEDURE Get_mapping_ids(
	p_level_map_id out NOCOPY numberTableType,
	p_level_primary_src out NOCOPY numberTableType,
	p_level_primary_target out NOCOPY numberTableType) IS
Begin

p_level_map_id:=l_relation_map;
p_level_primary_src:=l_relation_primary_src;
p_level_primary_target:=l_relation_primary_target;

End;--PROCEDURE Get_mapping_ids

--get the mapping
PROCEDURE Get_lvl_dim_mapping(
    p_dim_col out NOCOPY varcharTableType,
    p_level_name out NOCOPY varcharTableType,
    p_level_col out NOCOPY varcharTableType,
    p_number_mapping out NOCOPY integer,
    p_flag in integer) IS
Begin
--if p_flag is 0, find out NOCOPY the rowid also.
--if p_flag is 1 then dont find the rowid
open c3(l_dim_usage_id, l_mapping_id);
l_number_mapping:=1;
loop
    fetch c3 into
    l_dim_col(l_number_mapping),
    l_level_name(l_number_mapping),
    l_level_col(l_number_mapping);
    exit when c3%NOTFOUND;
    l_number_mapping:=l_number_mapping+1;
end loop;
close c3;
l_number_mapping:=l_number_mapping-1;
if p_flag = 0 then
  l_number_mapping:=l_number_mapping+1;--this is imp
  --find all the rowid mapping
  open c4(l_dim_id);
  loop
    fetch c4 into
	l_dim_col(l_number_mapping),
	l_level_name(l_number_mapping),
	l_level_col(l_number_mapping);
    exit when c4%NOTFOUND;
    l_number_mapping:=l_number_mapping+1;
  end loop;
  close c4;
  l_number_mapping:=l_number_mapping-1;
end if;
p_dim_col:=l_dim_col;
p_level_name:=l_level_name;
p_level_col:=l_level_col;
p_number_mapping:=l_number_mapping;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in Util.Get_lvl_dim_mapping '||sqlerrm||get_time);
End;-- PROCEDURE Get_lvl_dim_mapping

PROCEDURE Get_Fact_Ids(
	p_fact_name in varchar2,
	p_fact_map_id out NOCOPY number,
	p_fact_src out NOCOPY number,
	p_fact_target out NOCOPY number) IS

Begin
--not checked
select
  fact_map.mapping_id,
  fact_map.primary_source,
  fact_map.primary_target
  into
  p_fact_map_id,
  p_fact_src,
  p_fact_target
from
  edw_facts_md_v fact,
  edw_pvt_map_properties_md_v fact_map
where
    fact.fact_name=p_fact_name
and fact_map.primary_target=fact.fact_id;

Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in Get_Fact_Ids '||sqlerrm||get_time);
End;--PROCEDURE Get_Fact_Ids(p_fact_name in varchar2)

function get_log_for_table(p_table varchar2, p_log varchar2) return varchar2 is
l_stmt varchar2(5000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_log_desc varchar2(400);
l_log_table varchar2(400);
Begin
  if g_debug then
    write_to_log_file_n('In get_log_for_table. param1='||p_table||' and param2='||p_log);
  end if;
  if p_log='SNAPSHOT-LOG' then
    write_to_log_file_n('Going to call get_table_snapshot_log');
    return get_table_snapshot_log(p_table);
  end if;
  l_log_desc :=p_log;
  l_log_table:=null;
  --p_table is the fact name
  l_stmt:='select rel.name from edw_tables_md_v rel, edw_facts_md_v fact, edw_foreign_keys_md_v fk, '||
  'edw_unique_keys_md_v pk where fact.fact_name=:a and fk.entity_id=rel.elementid '||
  'and pk.entity_id=fact.fact_id and fk.key_id=pk.key_id  '||
  'and fk.foreign_key_name like ''%_DLOG''';
  open cv for l_stmt using p_table;
  fetch cv into l_log_table;
  close cv;
  if l_log_table is null then
    l_stmt:='select rel.RELATION_NAME from edw_relations_md_v rel, edw_facts_md_v fact, edw_foreign_keys_md_v fk, '||
    'edw_unique_keys_md_v pk where fact.fact_name=:a and fk.entity_id=rel.RELATION_ID '||
    'and pk.entity_id=fact.fact_id and fk.key_id=pk.key_id  '||
    'and rel.description=:b';
    open cv for l_stmt using p_table,l_log_desc;
    fetch cv into l_log_table;
    close cv;
  end if;
  return l_log_table;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in get_ilog_for_table '||sqlerrm);
  return null;
End;

function get_columns_for_table(
    p_table varchar2,
    p_columns out NOCOPY varcharTableType,
    p_number_columns out NOCOPY number) return boolean is
l_stmt varchar2(5000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  if g_debug then
    write_to_log_file_n('In get_columns_for_table, Input params is '||p_table);
  end if;
  p_number_columns:=1;
  l_stmt:='select col.column_name from edw_pvt_columns_md_v col, edw_relations_md_v rel where rel.relation_name=:s and '||
            ' col.parent_object_id=rel.relation_id ';
  open cv for l_stmt using p_table;
  loop
    fetch cv into p_columns(p_number_columns);
    exit when cv%notfound;
    p_number_columns:=p_number_columns+1;
  end loop;
  close cv;
  p_number_columns:=p_number_columns-1;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  p_number_columns:=0;
  return false;
End;

function get_db_columns_for_table(
    p_table varchar2,
    p_columns out NOCOPY varcharTableType,
    p_number_columns out NOCOPY number,
    p_owner varchar2) return boolean is
l_data_type varcharTableType;
l_data_length varcharTableType;
l_num_distinct numberTableType;
l_num_nulls numberTableType;
l_avg_col_length numberTableType;
Begin
  return get_db_columns_for_table(p_table,p_columns,l_data_type,l_data_length,l_num_distinct,
  l_num_nulls,l_avg_col_length,p_number_columns,p_owner);
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  p_number_columns:=0;
  return false;
End;

function get_db_columns_for_table(
    p_table varchar2,
    p_columns out NOCOPY varcharTableType,
    p_data_type out NOCOPY varcharTableType,
    p_number_columns out NOCOPY number,
    p_owner varchar2) return boolean is
l_data_length varcharTableType;
l_num_distinct numberTableType;
l_num_nulls numberTableType;
l_avg_col_length numberTableType;
Begin
  return get_db_columns_for_table(p_table,p_columns,p_data_type,l_data_length,l_num_distinct,
  l_num_nulls,l_avg_col_length,p_number_columns,p_owner);
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  p_number_columns:=0;
  return false;
End;

function get_db_columns_for_table(
    p_table varchar2,
    p_columns out NOCOPY varcharTableType,
    p_data_type out NOCOPY varcharTableType,
    p_data_length out NOCOPY varcharTableType,
    p_num_distinct out NOCOPY numberTableType,
    p_num_nulls out NOCOPY numberTableType,
    p_avg_col_length out NOCOPY numberTableType,
    p_number_columns out NOCOPY number,
    p_owner varchar2) return boolean is
cursor cv(p_table varchar2,p_owner varchar2) is
select column_name,data_type,data_length,num_distinct,num_nulls,avg_col_len from all_tab_columns
where table_name=p_table and owner=p_owner;
l_table varchar2(80);
l_owner varchar2(80);
Begin
  if g_debug then
    write_to_log_file_n('In get_db_columns_for_table, Input params is '||p_table||
    ' and owner '||p_owner);
  end if;
  l_owner:=p_owner;
  if instr(p_table,'.')<>0 then
    l_table:=substr(p_table,instr(p_table,'.')+1,length(p_table));
  else
    l_table:=p_table;
  end if;
  if l_owner is null then
    l_owner:=get_table_owner(l_table);
  end if;
  p_number_columns:=1;
  if g_debug then
    write_to_log_file_n('select column_name,data_type,data_length,num_distinct,num_nulls,'||
    'avg_col_len from all_tab_columns where table_name='||l_table||' and owner='||l_owner);
  end if;
  open cv(l_table,l_owner);
  loop
    fetch cv into p_columns(p_number_columns),
    p_data_type(p_number_columns),
    p_data_length(p_number_columns),
    p_num_distinct(p_number_columns),
    p_num_nulls(p_number_columns),
    p_avg_col_length(p_number_columns);
    exit when cv%notfound;
    p_number_columns:=p_number_columns+1;
  end loop;
  p_number_columns:=p_number_columns-1;
  close cv;
  if g_debug then
    write_to_log_file_n('Result');
    for i in 1..p_number_columns loop
      write_to_log_file(p_columns(i)||' '||p_data_type(i)||' '||p_data_length(i)||' '||
      p_num_distinct(i)||' '||p_num_nulls(i)||' '||p_avg_col_length(i));
    end loop;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  p_number_columns:=0;
  return false;
End;

function get_fks_for_table(
    p_table varchar2,
    p_fks out NOCOPY varcharTableType,
    p_number_fks out NOCOPY number) return boolean is
l_stmt varchar2(5000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  if g_debug then
    write_to_log_file_n('In get_fks_for_table, Input params is '||p_table);
  end if;
  p_number_fks:=1;
  l_stmt:='select col.column_name from edw_pvt_columns_md_v col, edw_relations_md_v rel, edw_foreign_keys_md_v fk, '||
  'edw_pvt_key_columns_md_v fku where rel.relation_name=:a and fk.entity_id=rel.relation_id and  '||
  'fku.key_id=fk.foreign_key_id and col.column_id=fku.column_id and col.parent_object_id=rel.relation_id';
  open cv for l_stmt using p_table;
  loop
    fetch cv into p_fks(p_number_fks);
    exit when cv%notfound;
    p_number_fks:=p_number_fks+1;
  end loop;
  close cv;
  p_number_fks:=p_number_fks-1;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in get_fks_for_table '||sqlerrm);
  return false;
End;

function get_fks_for_table(
    p_table varchar2,
    p_parent_table out NOCOPY varcharTableType,
    p_fks out NOCOPY varcharTableType,
    p_number_fks out NOCOPY number) return boolean is
l_stmt varchar2(5000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  if g_debug then
    write_to_log_file_n('In get_fks_for_table, Input params is '||p_table);
  end if;
  p_number_fks:=1;
  l_stmt:='select fk_item.column_name,p_rel.relation_name '||
  'from  '||
  'edw_relations_md_v rel,  '||
  'edw_foreign_keys_md_v fk,  '||
  'edw_pvt_key_columns_md_v fkisu,  '||
  'edw_pvt_columns_md_v fk_item,  '||
  'edw_relations_md_v p_rel,  '||
  'edw_unique_keys_md_v pk  '||
  'where  '||
  'rel.relation_name=:a  '||
  'and fk.entity_id=rel.relation_id '||
  'and fkisu.key_id=fk.foreign_key_id '||
  'and fk_item.column_id=fkisu.column_id '||
  'and fk_item.parent_object_id=rel.relation_id '||
  'and pk.key_id=fk.key_id '||
  'and p_rel.relation_id=pk.entity_id';
  open cv for l_stmt using p_table;
  loop
    fetch cv into p_fks(p_number_fks),p_parent_table(p_number_fks);
    exit when cv%notfound;
    p_number_fks:=p_number_fks+1;
  end loop;
  close cv;
  p_number_fks:=p_number_fks-1;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;


function get_table_snapshot_log(p_table varchar2) return varchar2 is
l_stmt varchar2(5000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_var varchar2(400);
l_table_owner varchar2(30);
begin
 if g_debug then
   write_to_log_file_n('In  get_table_snapshot_log, input param is '||p_table);
 end if;
 --rkumar:bug#4905343
 l_stmt:='select table_owner from user_synonyms where table_name=:a';
 open cv for l_stmt using p_table;
 fetch cv into l_table_owner;
 close cv;

 l_stmt:='select log_table from all_snapshot_logs where master=:a and log_owner=:b'; --rkumar:bug#4905343

 open cv for l_stmt using p_table, l_table_owner;

 fetch cv into  l_var;
 close cv;
 if g_debug then
   write_to_log_file_n('The snapshot log found for '||p_table||' is '||l_var);
 end if;
 return l_var;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in get_table_snapshot_log '||sqlerrm);
  return null;
End;

function delete_table(p_table varchar2) return boolean is
l_stmt varchar2(1000);
begin
  l_stmt:='delete '||p_table;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt);
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n('Deleted '||sql%rowcount||' records from '||p_table);
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in delete_table '||sqlerrm);
  return false;
End;

function truncate_table(p_table varchar2) return boolean is
Begin
  return truncate_table(p_table,null);
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in truncate_table '||sqlerrm);
  return false;
End;

function truncate_table(p_table varchar2, p_owner varchar2) return boolean is
l_stmt varchar2(1000);
l_owner varchar2(200);
Begin
  if g_debug then
    write_to_log_file_n('In Util.truncate_table, p_table='||p_table||', p_owner='||p_owner);
  end if;
  if p_owner is null or instr(p_table,'.')<>0 then
  --if p_owner is null then
    if instr(p_table,'.')<>0 then
      l_stmt:='truncate table '||p_table;
    else
      l_owner:=get_table_owner(p_table);
      l_stmt:='truncate table '||l_owner||'.'||p_table;
    end if;
  else
    l_stmt:='truncate table '||p_owner||'.'||p_table;
  end if;
  execute immediate l_stmt;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in truncate_table '||sqlerrm);
  return false;
End;


function value_in_table(
    p_table varcharTableType,
    l_number_table number,
    p_value varchar2) return boolean is
Begin
  if p_value is null or l_number_table <=0 then
    return false;
  end if;
  for i in 1..l_number_table loop
    if p_table(i)=p_value then
      return true;
    end if;
  end loop;
  return false;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in value_in_table '||sqlerrm);
  return false;
End;

function value_in_table(
    p_table numberTableType,
    l_number_table number,
    p_value number) return boolean is
Begin
  if p_value is null or l_number_table <=0 then
    return false;
  end if;
  for i in 1..l_number_table loop
    if p_table(i)=p_value then
      return true;
    end if;
  end loop;
  return false;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in value_in_table '||sqlerrm);
  return false;
End;

function value_in_table(
    p_table1 varcharTableType,
    p_table2 varcharTableType,
    l_number_table number,
    p_value1 varchar2,
    p_value2 varchar2) return boolean is
Begin
  if l_number_table <=0 then
    return false;
  end if;
  for i in 1..l_number_table loop
    if p_table1(i)=p_value1 and p_table2(i)=p_value2 then
      return true;
    end if;
  end loop;
  return false;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in value_in_table '||sqlerrm);
  return false;
End;

function index_in_table(
    p_table varcharTableType,
    l_number_table number,
    p_value varchar2) return number is
Begin
  if p_value is null or l_number_table <=0 then
    return 0;
  end if;
  for i in 1..l_number_table loop
    if p_table(i)=p_value then
      return i;
    end if;
  end loop;
  return 0;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in index_in_table '||sqlerrm);
  return -1;
End;

function index_in_table(
    p_table1 varcharTableType,
    p_table2 varcharTableType,
    l_number_table number,
    p_value1 varchar2,
    p_value2 varchar2) return number is
Begin
  if l_number_table <=0 then
    return 0;
  end if;
  for i in 1..l_number_table loop
    if p_table1(i)=p_value1 and p_table2(i)=p_value2 then
      return i;
    end if;
  end loop;
  return 0;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in index_in_table '||sqlerrm);
  return -1;
End;

procedure setup_conc_program_log is
begin
  g_conc_log_index:=0;
  g_file:=null;
  g_file_flag:=false;
  g_status:=true;
End;--procedure setup_conc_program_log is

procedure setup_conc_program_log(p_object_name varchar2) is
l_dir varchar2(300);
begin
  g_conc_program_id:=FND_GLOBAL.Conc_request_id;--my conc id
  l_dir:=null;
  l_dir := fnd_profile.value('UTL_FILE_LOG');
  if l_dir is  null  then
    l_dir := fnd_profile.value('EDW_LOGFILE_DIR');
    if l_dir is  null  then
      l_dir:='/sqlcom/log';
    end if;
  end if;
  g_conc_log_index:=0;
  g_status:=true;
  --REMOVE comments
  FND_FILE.PUT_NAMES(p_object_name||'.log',p_object_name||'.out',l_dir);
  g_file_flag:=true;
  if g_version_GT_1159 is null then
    g_version_GT_1159:=is_oracle_apps_GT_1159;
  end if;
Exception when others then
g_status_message:=sqlerrm;
g_file:=null;
g_file_flag:=false;
End;--procedure setup_conc_program_log is

procedure set_conc_program_id(p_conc_program_id number) is
Begin
  g_conc_program_id:=p_conc_program_id;
Exception when others then
g_status_message:=sqlerrm;
g_file:=null;
g_file_flag:=false;
End;
PROCEDURE Write_to_conc_prog_log(
		p_conc_id number,
		p_conc_name varchar2,
		p_object_type varchar2,
		p_conc_status varchar2,
		p_conc_message varchar2) IS
Begin
  if g_file_flag then
    FND_FILE.PUT_LINE(FND_FILE.LOG,p_conc_status||'   '||p_conc_message);
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  null;
End;

procedure commit_conc_program_log is
begin
 commit;
 if g_debug then
   write_to_log_file_n('commit');
 end if;
Exception when others then
  g_status_message:=sqlerrm;
  null;
End;--procedure commit_conc_program_log is

--only writes to the conc request log file
procedure write_to_conc_log_file(p_message varchar2) is
l_len number;
l_start number:=1;
l_end number:=1;
last_reached boolean:=false;
Begin
  if p_message is null or p_message='' then
    return;
  end if;
  l_len:=nvl(length(p_message),0);
  if l_len <=0 then
    return;
  end if;
  while true loop
    l_end:=l_start+250;
    if l_end >= l_len then
     l_end:=l_len;
     last_reached:=true;
    end if;
    if g_file_flag then
      FND_FILE.PUT_LINE(FND_FILE.LOG,substr(p_message, l_start, 250));
    end if;
    l_start:=l_start+250;
    if last_reached then
      exit;
    end if;
  end loop;
Exception when others then
  null;
End;

procedure write_to_log_file(p_message varchar2) is
l_severity number;
Begin
  write_to_conc_log_file(p_message);
  l_severity:=FND_LOG.LEVEL_STATEMENT;
  if l_severity>=FND_LOG.G_CURRENT_RUNTIME_LEVEL and g_version_GT_1159 then --this is for perf
    write_to_fnd_log(p_message,l_severity);
  end if;
Exception when others then
  null;
End;--procedure write_to_log_file(p_message varchar2) is

procedure write_to_log_file(p_message varchar2,p_severity number) is
Begin
  write_to_conc_log_file(p_message);
  if p_severity>=FND_LOG.G_CURRENT_RUNTIME_LEVEL and g_version_GT_1159 then --this is for perf
    write_to_fnd_log(p_message,p_severity);
  end if;
Exception when others then
  null;
End;--procedure write_to_log_file(p_message varchar2) is

procedure write_to_log_file_n(p_message varchar2) is
begin
  write_to_log_file('  ');
  write_to_log_file(p_message);
Exception when others then
  null;
end;
procedure write_to_log_file_n(p_message varchar2,p_severity number) is
begin
  write_to_log_file('  ',p_severity);
  write_to_log_file(p_message,p_severity);
Exception when others then
  null;
end;

procedure write_to_out_file(p_message varchar2) is
 l_len number;
 l_start number:=1;
 l_end number:=1;
 last_reached boolean:=false;
Begin
  if p_message is null or p_message='' then
    return;
  end if;
  l_len:=nvl(length(p_message),0);
  if l_len <=0 then
    return;
  end if;
  while true loop
    l_end:=l_start+250;
    if l_end >= l_len then
      --l_end:=l_len;
      last_reached:=true;
    end if;
    if g_file_flag then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,substr(p_message, l_start, 250));
    end if;
    l_start:=l_start+250;
    if last_reached then
      exit;
     end if;
  end loop;
Exception when others then
  null;
End;--procedure write_to_out_file(p_message varchar2) is

/*
for 11.5.10. log messages must be written to fnd log
*/
procedure write_to_fnd_log(
p_message varchar2,
p_severity number) is
l_len number;
l_start number:=1;
l_end number:=1;
last_reached boolean:=false;
Begin
  if p_message is null or p_message='' then
    return;
  end if;
  if g_fnd_log_module is null then
    g_fnd_log_module:='BIS';--default
    g_fnd_log_module:=g_fnd_log_module||'.EDW';
  end if;
  l_len:=nvl(length(p_message),0);
  if l_len <=0 then
    return;
  end if;
  while true loop
    l_end:=l_start+3990;
    if l_end>=l_len then
      --l_end:=l_len;
      last_reached:=true;
    end if;
    if p_severity>=FND_LOG.G_CURRENT_RUNTIME_LEVEL then --this is for perf
      FND_LOG.STRING(p_severity,g_fnd_log_module,substr(p_message, l_start,3990));
    end if;
    l_start:=l_start+3990;
    if last_reached then
      exit;
    end if;
  end loop;
Exception when others then
  write_to_conc_log_file('Error in write_to_fnd_log '||g_status_message);
End;

procedure print_stmt(l_stmt in varchar2) IS

l_len number;
l_start number:=1;
l_end number:=1;
last_reached boolean:=false;
begin

l_len:=length(l_stmt);
--dbms_output.put_line(l_len);

while true loop

l_end:=l_start+250;

if l_end >= l_len then
	l_end:=l_len;
	last_reached:=true;
end if;

--dbms_output.put_line(substr(l_stmt, l_start, 250));
null;

l_start:=l_start+250;

if last_reached then
	exit;
end if;

end loop;

end;

procedure set_debug(p_debug boolean) is
begin
 g_debug:=p_debug;
End;

function get_time return varchar2 is
begin
  return ' '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS');
Exception when others then
  null;
End;

FUNCTION get_wh_language return VARCHAR2 IS
l_lang VARCHAR2(240);
BEGIN
    SELECT edw_language_code INTO l_lang
    FROM edw_system_parameters;
    RETURN l_lang;
EXCEPTION WHEN OTHERS THEN
  return 'US';
END;

FUNCTION get_wh_lookup_value(p_lookup_type IN VARCHAR2,
                                p_lookup_code in varchar2) return VARCHAR2 IS
l_meaning VARCHAR2(100);
l_lang          VARCHAR2(240);
BEGIN

   return p_lookup_code;
   /*
     the below code was there when we thought that we need to translate before inserting into the
     log tables. now its decided that the conversion needs to happen in the form. so the below portion is
     not needed.
   */

   l_lang := get_wh_language;
  SELECT
    meaning
  INTO
    l_meaning
  FROM fnd_lookup_values
  WHERE lookup_code= p_lookup_code
    AND lookup_type= p_lookup_type
    AND language = l_lang;
 return l_meaning;
EXCEPTION WHEN OTHERS THEN
   return null;
END;


/*
     NEW LOGGING collection log and collection detail log
*/

function write_to_collection_log(
        p_object varchar2,
        p_object_id number,
        p_object_type varchar2,
        p_conc_program_id number,
        p_start_date date,
        p_end_date date,
        p_rows_ready number,
        p_rows_processed number,
        p_rows_collected number,/*not same as p_rows_processed when duplicate collect is yes*/
        p_number_insert number,
        p_number_update number,
        p_number_delete number,
        p_collection_message varchar2,
        p_status varchar2,
        p_load_pk number) return boolean is
l_stmt varchar2(10000);
l_collection_status varchar2(400);
l_insert_flag boolean;
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_num number:=null;
Begin
  if g_debug then
    write_to_log_file_n('In write_to_collection_log');
  end if;
  l_collection_status:=p_status;
  l_stmt:='select 1 from edw_collection_detail_log where load_pk=:a';
  open cv for l_stmt using p_load_pk;
  fetch cv into l_num;
  close cv;
  if l_num is null then
    l_insert_flag:=true;
  else
    l_insert_flag:=false;
  end if;
  if l_insert_flag then
    l_stmt:='insert into edw_collection_detail_log(load_pk,object_name, object_id,object_type,COLLECTION_CONCURRENT_ID, '||
          'COLLECTION_START_DATE,COLLECTION_END_DATE, '||
          ' NO_ACTUALLY_COLLECTED,NO_OF_READY_RECORDS,NO_OF_SUCC_PROCESSED_RECORDS, NUMBER_INSERT,'||
          ' NUMBER_UPDATE,NUMBER_DELETE,COLLECTION_STATUS, COLLECTION_EXCEPTION_MESSAGE,CREATION_DATE,'||
          'CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,LAST_UPDATE_BY) '||
          ' values (:a1,:a2,:a3,:a4,:a5,:a6,:a7,:a8,:a9,:a10,:a11,:a12,:a13,:a14,:a15,:a16,:a17,:a18,:a19,:a20) ';
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt);
      write_to_log_file(p_load_pk||','||p_object||','||p_object_id||','||p_object_type||','||p_conc_program_id||','||p_start_date||
       ','||p_end_date||','||p_rows_collected||','||p_rows_ready||','||
       p_rows_processed||','||p_number_insert||','||p_number_update||','||p_number_delete||','||
       l_collection_status||','||p_collection_message||','||sysdate||','||
       p_conc_program_id||','||sysdate||','||p_conc_program_id||','||p_conc_program_id);
    end if;
    execute immediate l_stmt using  p_load_pk,p_object,p_object_id,p_object_type,p_conc_program_id,p_start_date,p_end_date,
    p_rows_collected,p_rows_ready,p_rows_processed,p_number_insert,p_number_update,p_number_delete,
    l_collection_status,p_collection_message,sysdate,
    p_conc_program_id,sysdate,p_conc_program_id,p_conc_program_id;
    write_to_log_file_n('Inserted '||sql%rowcount||' record into edw_collection_detail_log');
  else
    l_stmt:='update edw_collection_detail_log set COLLECTION_END_DATE=:a1, '||
          ' NO_ACTUALLY_COLLECTED=:a2,NO_OF_READY_RECORDS=:a3,NO_OF_SUCC_PROCESSED_RECORDS=:a4, '||
          'NUMBER_INSERT=:a5,NUMBER_UPDATE=:a6,NUMBER_DELETE=:a7, '||
          'COLLECTION_STATUS=:a8, COLLECTION_EXCEPTION_MESSAGE=:a9,LAST_UPDATE_DATE=:a10,'||
          'LAST_UPDATE_LOGIN=:a11,LAST_UPDATE_BY=:a12 where load_pk=:a13';
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt);
      write_to_log_file(p_end_date||','||p_rows_collected||','||p_rows_ready||','||
       p_rows_processed||','||p_number_insert||','||p_number_update||','||p_number_delete||','||
       l_collection_status||','||p_collection_message||','||sysdate||','||
       p_conc_program_id||','||p_conc_program_id||','||p_load_pk);
    end if;
    execute immediate l_stmt using  p_end_date,p_rows_collected,p_rows_ready,p_rows_processed,
    p_number_insert,p_number_update,p_number_delete,
    l_collection_status,p_collection_message,sysdate,p_conc_program_id,p_conc_program_id,p_load_pk;
    write_to_log_file_n('Updated '||sql%rowcount||' record in edw_collection_detail_log');
  end if;
   return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function write_to_general_log
        (OBJECT_NAME     VARCHAR2,
         OBJECT_TYPE    VARCHAR2,
         LOG_TYPE  VARCHAR2,
         CONCURRENT_ID   NUMBER,
         START_DATE DATE,
         END_DATE DATE,
         MESSAGE   VARCHAR2,
         STATUS   VARCHAR2) return boolean is
l_stmt varchar2(4000);
Begin
    if g_debug then
      write_to_log_file_n('In UTIL.write_to_general_log');
      write_to_log_file(OBJECT_NAME||'     '||OBJECT_TYPE||'     '||LOG_TYPE||'     '||
        CONCURRENT_ID||'     '||START_DATE||'     '||END_DATE||'     '||
        MESSAGE||'     '||STATUS);
    end if;
    l_stmt:='insert into edw_general_log (OBJECT_NAME,OBJECT_TYPE,LOG_TYPE,CONCURRENT_ID,START_DATE, '||
    ' END_DATE,MESSAGE,STATUS )'||
             ' values (:a1,:a2,:a3,:a4,:a5,:a6,:a7,:a8) ';
    execute immediate l_stmt using OBJECT_NAME,OBJECT_TYPE,LOG_TYPE,CONCURRENT_ID,START_DATE,END_DATE,
        MESSAGE,STATUS;
    write_to_log_file_n('Inserted '||sql%rowcount||' records into edw_general_log');
    return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in write_to_general_log '||sqlerrm||get_time);
  return false;
End;

function write_to_error_log
        (OBJECT_NAME     VARCHAR2,
         OBJECT_TYPE    VARCHAR2,
         ERROR_TYPE  VARCHAR2,
         CONCURRENT_ID   NUMBER,
         START_DATE DATE,
         END_DATE DATE,
         MESSAGE   VARCHAR2,
         STATUS   VARCHAR2,
         RESP_ID NUMBER) return boolean is
l_stmt varchar2(4000);
Begin
    if g_debug then
      write_to_log_file_n('In UTIL.write_to_error_log');
      write_to_log_file(OBJECT_NAME||'     '||OBJECT_TYPE||'     '||ERROR_TYPE||'     '||
        CONCURRENT_ID||'     '||START_DATE||'     '||END_DATE||'     '||
        MESSAGE||'     '||STATUS);
    end if;
    l_stmt:='insert into edw_error_log (OBJECT_NAME,OBJECT_TYPE,ERROR_TYPE,CONCURRENT_ID,START_DATE, '||
    ' END_DATE,MESSAGE,STATUS ,LAST_UPDATE_DATE,LAST_UPDATED_BY,CREATION_DATE,CREATED_BY, '||
    ' LAST_UPDATE_LOGIN,RESP_ID)'||
             ' values (:a1,:a2,:a3,:a4,:a5,:a6,:a7,:a8,:a9,:a10,:a11,:a12,:a13,:a14) ';
    execute immediate l_stmt using OBJECT_NAME,OBJECT_TYPE,ERROR_TYPE,CONCURRENT_ID,START_DATE,END_DATE,
        MESSAGE,STATUS,sysdate,CONCURRENT_ID,sysdate,CONCURRENT_ID,CONCURRENT_ID,RESP_ID;
    write_to_log_file_n('Inserted '||sql%rowcount||' records into edw_error_log');
    return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in write_to_error_log '||sqlerrm||get_time);
  return false;
End;

/*
   the temp logging reqd so that we can have commit after each level collection
   the function should be called only for the lowest level
*/
function insert_temp_log_table(
        p_object_name varchar2,
        p_object_type varchar2,
        p_concurrent_req_id number,
        p_ins_instance_name varcharTableType,
        p_ins_request_id_table numberTableType,
        p_ins_rows_ready numberTableType,
        p_ins_rows_processed numberTableType,
        p_ins_rows_collected numberTableType,
        p_ins_rows_dangling numberTableType,
        p_ins_rows_duplicate numberTableType,
        p_ins_rows_error numberTableType,
        p_number_ready number,
        p_number_insert number,
        p_number_update number,
        p_number_delete number,
        p_number_ins_req_coll number) return boolean is
l_stmt varchar2(10000);
Begin
  if g_debug then
    write_to_log_file_n('In EDW_OWB_COLLECTION_UTIL.insert_temp_log_table');
    write_to_log_file('Object '||p_object_name||', object type '||p_object_type||' req '||p_concurrent_req_id);
    write_to_log_file('instance   reqid  ready  processed  collected  dangling  duplicate error number_ready '||
    'number_insert number_update number_delete');
    for i in 1..p_number_ins_req_coll loop
      write_to_log_file(p_ins_instance_name(i)||'   '||p_ins_request_id_table(i)||'   '||p_ins_rows_ready(i)
        ||'   '||p_ins_rows_processed(i)||'   '||p_ins_rows_collected(i)||'   '||p_ins_rows_dangling(i)
        ||'   '||p_ins_rows_duplicate(i)||'    '||p_ins_rows_error(i)||' '||p_number_ready||' '||p_number_insert
        ||' '||p_number_update||' '||p_number_delete);
    end loop;
  end if;
  for i in 1..p_number_ins_req_coll loop
    l_stmt:='insert into edw_temp_collection_log(object_name, object_type, concurrent_id,instance, request_id, rows_ready, '||
          ' rows_processed, rows_collected, rows_dangling, rows_duplicate, rows_error, status,number_ready,'||
          'number_insert,number_update,number_delete) values '||
          '(:a1,:a2,:a3,:a4,:a5,:a6,:a7,:a8,:a9,:a10,:a11,:a12,:a13,:a14,:a15,:a16)';
    if g_debug then
      write_to_log_file_n('Going to execute parameter number '||i);
    end if;
    execute immediate l_stmt using p_object_name,p_object_type,p_concurrent_req_id,p_ins_instance_name(i),
        p_ins_request_id_table(i),p_ins_rows_ready(i),
        p_ins_rows_processed(i),p_ins_rows_collected(i),p_ins_rows_dangling(i),
        p_ins_rows_duplicate(i),p_ins_rows_error(i),'OPEN',p_number_ready,
        p_number_insert,p_number_update,p_number_delete;
  end loop;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in insert_temp_log_table '||sqlerrm||get_time);
  return false;
End;

/*
does the table or view exist in the database?
called when EDW_ALL_COLLECT is making sure that all objects exist in the database
*/
function check_table(p_table varchar2) return boolean is
Begin
  return check_table(p_table,null);
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in  check_table '||sqlerrm||' '||get_time);
  return false;
End;

function check_table(p_table varchar2, p_owner varchar2) return boolean is
l_stmt varchar2(10000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  if g_debug then
    write_to_log_file_n('In UTIL.check_table for '||p_table||' and owner '||p_owner);
  end if;
  begin
    if p_owner is null then
      l_stmt:='select 1 from '||p_table||' where rownum=1';
    else
      l_stmt:='select 1 from '||p_owner||'.'||p_table||' where rownum=1';
    end if;
    open cv for l_stmt;
    close cv;
    if g_debug then
      write_to_log_file('Table found');
    end if;
    return true;
  exception when others then
    g_status_message:=sqlerrm;
    if g_debug then
      write_to_log_file('Table NOT found');
    end if;
    return false;
  end;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in  check_table '||sqlerrm||' '||get_time);
  return false;
End;

/*
 given an IV, make sure that the trigger is in valid state
 again called from EDW_ALL_COLLECT as a part of the initial check
*/
function check_iv_trigger(p_iv varchar2) return boolean is
l_stmt varchar2(2000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_str varchar2(400);
l_trigger varchar2(400);
l_table_owner varchar2(30); --bug#4905343
begin
  if g_debug then
    write_to_log_file_n('In check_iv_trigger for '||p_iv);
  end if;
  l_str:=null;

  l_stmt:='select table_owner from user_synonyms where table_name=:a';
  open cv for l_stmt using p_iv;
     fetch cv into l_table_owner;
  close cv;

  l_stmt:='select trg.trigger_name, trg.status from all_triggers trg where trg.table_name=:a '||
  'and trg.owner=:b'; --rkumar:4905343
     open cv for l_stmt using p_iv, l_table_owner;
  fetch cv into l_trigger, l_str;
  close cv;
  if l_str is null then
    write_to_log_file_n('The instead of view Trigger does not exist for the view '||p_iv);
    return false;
  elsif l_str<> 'ENABLED' then
    write_to_log_file_n('The instead of view Trigger '||l_trigger||' for the view '||p_iv||' is not ENABLED');
    return false;
  else
   if g_debug then
     write_to_log_file_n('Instead of view Trigger '||l_trigger||' is valid ');
   end if;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in  check_iv_trigger '||sqlerrm||' '||get_time);
  return false;
End;

/****************************************************************************
    FOR DERIVED FACTS
****************************************************************************/

/*
is this base fact a source for the derived fact with inc refresh implemented
*/
function is_source_for_inc_derived_fact(p_fact varchar2) return number is
l_stmt varchar2(10000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_var number:=null;
l_is_name varchar2(40);
l_derv_facts numberTableType;
l_number_derv_facts number;
Begin
  if g_debug then
    write_to_log_file_n('In is_source_for_inc_derived_fact, input param='||p_fact);
  end if;
  if g_read_cfig_options then
    --not checked
    l_stmt:='select df.fact_id from edw_facts_md_v df, edw_facts_md_v fact, '||
    'edw_pvt_map_properties_md_v map  '||
    'where fact.fact_name=:a and map.primary_source=fact.fact_id and df.fact_id=map.primary_target ';
    if g_debug then
      write_to_log_file_n(l_stmt||' '||p_fact);
    end if;
    l_number_derv_facts:=1;
    open cv for l_stmt using p_fact;
    loop
      fetch cv into l_derv_facts(l_number_derv_facts);
      exit when cv%notfound;
      l_number_derv_facts:=l_number_derv_facts+1;
    end loop;
    l_number_derv_facts:=l_number_derv_facts-1;
    close cv;
    if l_number_derv_facts>0 then
      for i in 1..l_number_derv_facts loop
        l_is_name:=null;
        if edw_option.get_warehouse_option(null,l_derv_facts(i),'INCREMENTAL',l_is_name)=false then
          null;
        end if;
        if l_is_name='Y' then
          l_var:=1;
          exit;
        end if;
      end loop;
    else
      l_var:=0;
    end if;
  else
    --not checked
    l_stmt:='select 1 from edw_facts_md_v df, edw_facts_md_v fact, '||
    'edw_pvt_map_properties_md_v map, edw_attribute_sets_md_v sis  '||
    'where fact.fact_name=:a and map.primary_source=fact.fact_id and df.fact_id=map.primary_target '||
    'and sis.entity_id=df.fact_id and sis.attribute_group_name=''EDW_INC_REFRESH''';
    if g_debug then
      write_to_log_file_n(l_stmt||' '||p_fact);
    end if;
    open cv for l_stmt using p_fact;
    fetch cv into l_var;
    close cv;
  end if;
  if l_var = 1 then
    return 1;
  else
    return 0;
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in  is_source_for_inc_derived_fact '||sqlerrm||' '||get_time);
  return -1;
End;

function get_all_derived_facts(
    p_object varchar2,
    p_derived_facts out NOCOPY varcharTableType,
    p_derived_fact_ids out NOCOPY numberTableType,
    p_map_id  out NOCOPY numberTableType,
    p_number_derived_facts out NOCOPY number) return boolean is
l_stmt varchar2(10000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  if g_debug then
    write_to_log_file_n('In get_all_derived_facts, input param='||p_object);
  end if;
  --not checked
  l_stmt:='select df.fact_name, df.fact_id, map.mapping_id  from edw_facts_md_v df, edw_facts_md_v fact, '||
  'edw_pvt_map_properties_md_v map  '||
  'where fact.fact_name=:a and map.primary_source=fact.fact_id and df.fact_id=map.primary_target';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||' using '||p_object);
  end if;
  p_number_derived_facts:=1;
  open cv for l_stmt using p_object;
  loop
    fetch cv into
        p_derived_facts(p_number_derived_facts),
        p_derived_fact_ids(p_number_derived_facts),
        p_map_id(p_number_derived_facts);
    exit when cv%notfound;
    p_number_derived_facts:=p_number_derived_facts+1;
  end loop;
  p_number_derived_facts:=p_number_derived_facts-1;
  close cv;
  if g_debug then
    write_to_log_file('Query resulted in '||p_number_derived_facts||' rows');
    for i in 1..p_number_derived_facts loop
      write_to_log_file(p_derived_facts(i)||' '||p_derived_fact_ids(i)||' '||p_map_id(i));
    end loop;
  end if;

  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in  get_all_derived_facts '||sqlerrm||' '||get_time);
  return false;
End;

/*
function to create a table when passed the table name, cols etc
*/
function create_table(
    p_table_name varchar2,
    p_table_owner varchar2,
    p_table_cols varcharTableType,
    p_table_data_type varcharTableType,
    p_number_table_cols number,
    p_table_storage varchar2) return boolean is
l_stmt varchar2(30000);
Begin
  if g_debug then
    write_to_log_file_n('In Util.create_table');
    write_to_log_file('Input parameters:');
    write_to_log_file('p_table_name='||p_table_name);
    write_to_log_file('p_table_owner='||p_table_owner);
    write_to_log_file('p_table_storage='||p_table_storage);
    write_to_log_file('p_number_table_cols='||p_number_table_cols);
    write_to_log_file('Table columns');
    for i in 1..p_number_table_cols loop
      write_to_log_file(p_table_cols(i)||'  '||p_table_data_type(i));
    end loop;
  end if;
  if p_table_owner is null then
    l_stmt:='create table '||p_table_name||'(';
  else
    l_stmt:='create table '||p_table_owner||'.'||p_table_name||'(';
  end if;
  for i in 1..p_number_table_cols loop
    l_stmt:=l_stmt||p_table_cols(i)||' '||p_table_data_type(i)||',';
  end loop;
  l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
  l_stmt:=l_stmt||')';
  if p_table_storage is not null then
    l_stmt:=l_stmt||' '||p_table_storage;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt);
  end if;
  execute immediate l_stmt;
  return  true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in Util.create_table '||sqlerrm);
  return false;
End;

function drop_table(p_table_name varchar2) return boolean is
Begin
  return drop_table(p_table_name,null);
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in drop_table '||sqlerrm);
  return false;
End;

function drop_table (
    p_table_name varchar2,
    p_owner varchar2) return boolean is
l_stmt varchar2(4000);
l_owner varchar2(400);
Begin
  if p_owner is null then
    if instr(p_table_name,'.')<>0 then
      l_stmt:='drop table '||p_table_name;
      execute immediate l_stmt;
    else
      l_owner:=get_table_owner(p_table_name);
      l_stmt:='drop table '||l_owner||'.'||p_table_name;
      execute immediate l_stmt;
      l_stmt:='drop synonym '||p_table_name;
      begin
        execute immediate l_stmt;
      exception when others then
        null;
      end;
    end if;
  else
    l_stmt:='drop table '||p_owner||'.'||p_table_name;
    execute immediate l_stmt;
  end if;
  return  true;
Exception when others then
  g_status_message:=sqlerrm;
  g_sqlcode:=sqlcode;
  if g_debug then
    write_to_log_file_n('Error in Util.drop_table '||p_table_name||' '||sqlerrm);
  end if;
  return false;
End;

/*
given the product, returns the schema
*/
function get_db_user(p_product varchar2) return varchar2 is
l_dummy1 varchar2(2000);
l_dummy2 varchar2(2000);
l_schema varchar2(400);
Begin
  if g_debug then
    write_to_log_file_n('In Util.get_db_user, param is '||p_product);
  end if;
  if FND_INSTALLATION.GET_APP_INFO(p_product,l_dummy1, l_dummy2,l_schema) = false then
    write_to_log_file_n('FND_INSTALLATION.GET_APP_INFO returned with error');
    return null;
  end if;
  return l_schema;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_db_user '||sqlerrm);
  return null;
End;

function get_table_owner(p_table varchar2) return varchar2 is
l_owner varchar2(400);
l_stmt  varchar2(4000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  if g_debug then
    write_to_log_file_n('In get_table_owner');
  end if;
  if instr(p_table,'.')<>0 then
    l_owner:=substr(p_table,1,instr(p_table,'.')-1);
    return l_owner;
  end if;
  l_stmt:='select table_owner from user_synonyms where synonym_name=:a';
  open cv for l_stmt using p_table;
  fetch cv into l_owner;
  close cv;

  if l_owner is null then
    l_stmt:='select table_owner from user_synonyms where table_name=:a'; --rkumar:bug#4905343
    open cv for l_stmt using p_table;
       fetch cv into l_owner;
    close cv;
    l_stmt:='select owner from all_tables where table_name=:a '||
            ' and owner=:b'; --rkumar:bug#4905343
    open cv for l_stmt using p_table,l_owner;
        fetch cv into l_owner;
    close cv;
  end if;
  if g_debug then
    write_to_log_file_n('Owner for '||p_table||' is '||l_owner);
  end if;
  return l_owner;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_table_owner '||sqlerrm);
  return null;
End;

procedure analyze_table_stats(p_table varchar2) is
Begin
  analyze_table_stats(p_table,null,null);
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in analyze_table_stats '||sqlerrm);
End;
procedure analyze_table_stats(p_table varchar2, p_owner varchar2) is
Begin
  analyze_table_stats(p_table,p_owner,null);
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in analyze_table_stats '||sqlerrm);
End;
procedure analyze_table_stats(p_table varchar2, p_owner varchar2,p_percentage number) is
errbuf varchar2(2000);
retcode varchar2(200);
l_owner varchar2(400);
l_percentage number;
l_table varchar2(400);
Begin
  l_percentage:=p_percentage;
  if l_percentage is null then
    l_percentage:=1; --default 1%
  end if;
  if instr(p_table,'.')<>0 then
    l_table:=substr(p_table,instr(p_table,'.')+1,length(p_table));
  else
    l_table:=p_table;
  end if;
  l_owner:=p_owner;
  if l_owner is null then
    l_owner:=get_table_owner(p_table);
    if g_debug then
      write_to_log_file_n('l_owner is '||l_owner);
    end if;
    if l_owner is null then
      write_to_log_file_n('Owner for table '||p_table||' not found');
      return;
    end if;
  end if;
  if g_debug then
    write_to_log_file_n('In analyze_table_stats. table is '||l_table||' and p_owner is '||
    l_owner||' '||p_percentage||get_time);
  end if;
  if g_parallel is null then
    dbms_stats.gather_table_stats(ownname=>l_owner,tabname=>l_table,estimate_percent=>l_percentage,
    degree=>1);
    --FND_STATS.GATHER_TABLE_STATS (errbuf, retcode, l_owner, l_table,l_percentage,1);
  else
    dbms_stats.gather_table_stats(ownname=>l_owner,tabname=>l_table,estimate_percent=>l_percentage,
    degree=>g_parallel);
    --FND_STATS.GATHER_TABLE_STATS (errbuf, retcode, l_owner, l_table,l_percentage,g_parallel);
  end if;
  if g_debug then
    write_to_log_file('Done '||get_time);
  end if;
  /*if retcode <> '0' then
    write_to_log_file_n('FND_STATS.GATHER_TABLE_STATS status message is '||errbuf);
  end if;*/
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in analyze_table_stats '||sqlerrm);
End;

function record_coll_progress(
    p_object_name varchar2,
    p_object_type varchar2,
    p_number_rows_processed number,
    p_status varchar2,
    p_action varchar2) return boolean is
l_stmt varchar2(4000);
Begin
  if g_debug then
    write_to_log_file_n('In record_coll_progress ');
    write_to_log_file('p_object_name='||p_object_name);
    write_to_log_file('p_object_type='||p_object_type);
    write_to_log_file('p_number_rows_processed='||p_number_rows_processed);
    write_to_log_file('p_status='||p_status);
    write_to_log_file('p_action='||p_action);
  end if;
  if p_action='INSERT' then
    l_stmt:='insert into edw_coll_progress_log(object_name,object_type,status,number_processed, '||
        'last_update_date,last_update_login,creation_date,created_by,last_update_by ) values ( '||
        ' :a1,:a2,:a3,:a4,:a5,:a6,:a7,:a8,:a9) ';
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt);
    end if;
    execute immediate l_stmt using p_object_name, p_object_type,p_status,p_number_rows_processed,
        sysdate,g_conc_program_id,sysdate,g_conc_program_id,g_conc_program_id;
  elsif p_action='UPDATE' then
    l_stmt:='update edw_coll_progress_log set status=:c,number_processed=:d, '||
        'last_update_date=:e,last_update_login=:f,last_update_by=:g where object_name=:a and '||
        ' object_type=:b ';
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt);
    end if;
    execute immediate l_stmt using p_status,p_number_rows_processed,sysdate,
        g_conc_program_id,g_conc_program_id,p_object_name,p_object_type;
  elsif p_action='DELETE' then
    l_stmt:='delete edw_coll_progress_log where object_name=:a and object_type=:b ';
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt);
    end if;
    execute immediate l_stmt using p_object_name,p_object_type;
  end if;
  if g_debug then
    write_to_log_file_n('Processed '||sql%rowcount||' records in edw_coll_progress_log');
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in record_coll_progress '||sqlerrm);
  return false;
End;

/*
is_another_coll_running
return values:
0: function error
1: still running
2: not running
*/
function is_another_coll_running(p_object_name varchar2, p_object_type varchar2) return number is
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_stmt varchar2(4000);
l_var number:=null;
l_phase varchar2(400);
l_status varchar2(400);
l_dev_phase  varchar2(400);
l_dev_status varchar2(400);
l_message varchar2(4000);

Begin
  if g_debug then
    write_to_log_file_n('In Util.is_another_coll_running');
    write_to_log_file('p_object_name='||p_object_name);
    write_to_log_file('p_object_type='||p_object_type);
  end if;
  l_stmt:='select last_update_by from edw_coll_progress_log where object_name=:a and object_type=:b';
  open cv for l_stmt using p_object_name, p_object_type;
  fetch cv into l_var;
  close cv;
  if g_debug then
    write_to_log_file_n('last update by found from edw_coll_progress_log is '||l_var);
  end if;
  if l_var is null then
    --first insert a row
    if record_coll_progress(p_object_name,p_object_type,0,'PROCESSING','INSERT') = false then
      return 0;
    end if;
    return 2;--this is where it must return most of the time
  end if;
  --if yes, check fnd status
  if FND_CONCURRENT.get_request_status(l_var,null,null,l_phase,l_status,
    l_dev_phase,l_dev_status,l_message)=false then
    write_to_log_file_n('FND_CONCURRENT.get_request_status returned with false');
    write_to_log_file(FND_MESSAGE.get);
    return 2;
    /*if record_coll_progress(p_object_name,p_object_type,0,'PROCESSING','INSERT') = false then
      return 0;
    end if;
    return 2;*/
  end if;
  if g_debug then
    write_to_log_file_n('The results found from fnd get req status are ');
    write_to_log_file('l_phase='||l_phase);
    write_to_log_file('l_status='||l_status);
    write_to_log_file('l_dev_phase='||l_dev_phase);
    write_to_log_file('l_dev_status='||l_dev_status);
    write_to_log_file('l_message='||l_message);
  end if;

  /*if l_phase <> 'Completed' then*/
  if l_dev_phase is not null and l_dev_phase <> 'COMPLETE' then
    return 1;
  else
    if record_coll_progress(p_object_name,p_object_type,null,null,'DELETE') = false then
      return 0;
    end if;
    if record_coll_progress(p_object_name,p_object_type,0,'PROCESSING','INSERT') = false then
      return 0;
    end if;
    commit;
    return 2;
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in is_another_coll_running '||sqlerrm);
  return 0;
End;

procedure alter_session(p_param varchar2) is
Begin
  alter_session(p_param,null);
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in alter_session '||sqlerrm);
End;
procedure alter_session(p_param varchar2,p_value varchar2) is
l_stmt varchar2(2000);
Begin
  if p_param ='PARALLEL' then
    l_stmt:='alter session enable parallel dml';
    execute immediate l_stmt;
    write_to_log_file_n('Session made parallel dml enabled');
  elsif p_param ='NO-PARALLEL' then
    l_stmt:='alter session disable parallel dml';
    execute immediate l_stmt;
    write_to_log_file_n('Session made parallel dml disabled');
  elsif p_param ='HASH_AREA_SIZE' then
    l_stmt:='alter session set hash_area_size='||p_value;
    write_to_log_file_n(l_stmt);
    execute immediate l_stmt;
  elsif p_param ='SORT_AREA_SIZE' then
    l_stmt:='alter session set sort_area_size='||p_value;
    write_to_log_file_n(l_stmt);
    execute immediate l_stmt;
  elsif p_param='TRACE' then
    execute immediate 'alter session set tracefile_identifier=LOADER_ENGINE';
    execute immediate 'alter session set sql_trace=true';
    execute immediate 'alter session set events=''10046 trace name context forever, level 12''';
    write_to_log_file_n('alter session with trace file identifier as LOADER_ENGINE, level 12');
  end if;
  commit;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in alter_session '||sqlerrm);
End;

/*
called when being run as a job
*/
function set_session_parameters(
p_hash_area_size number,
p_sort_area_size number,
p_trace boolean,
p_parallel number
 )return boolean is
Begin
  if p_hash_area_size>0 then
    alter_session('HASH_AREA_SIZE',p_hash_area_size);
  end if;
  if p_sort_area_size>0 then
    alter_session('SORT_AREA_SIZE',p_sort_area_size);
  end if;
  if p_trace then
    alter_session('TRACE');
  end if;
  if p_parallel is not null then
    alter_session('PARALLEL');
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in set_session_parameters '||g_status_message);
  return false;
End;


/*
does_table_have_data :
0 : Error
1: no data
2: data present
*/
function does_table_have_data(p_table varchar2) return number is
Begin
  return does_table_have_data(p_table,null);
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in does_table_have_data '||sqlerrm);
  return 0;
End;
function does_table_have_data(p_table varchar2, p_where varchar2) return number is
l_stmt varchar2(2000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_res number:=null;
Begin
  if g_debug then
    write_to_log_file_n('In does_table_have_data , table is '||p_table||' and where clause is '||p_where);
  end if;
  if p_where is null then
    l_stmt:='select 1 from '||p_table||' where rownum=1';
  else
    l_stmt:='select 1 from '||p_table||' where '||p_where||' and rownum=1';
  end if;
  open cv for l_stmt;
  fetch cv into l_res;
  close cv;
  if l_res is null then
    if g_debug then
      write_to_log_file('No');
    end if;
    return 1;
  end if;
  if g_debug then
    write_to_log_file('Yes');
  end if;
  return 2;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in does_table_have_data '||sqlerrm);
  return 0;
End;

function is_object_a_source(p_object_name varchar2)  return boolean is
l_stmt varchar2(2000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_res number:=null;
Begin
  if g_debug then
    write_to_log_file_n('In Util.is_object_a_source, p_object_name='||p_object_name);
  end if;
  --not checked
  l_stmt:='select 1 from edw_pvt_map_properties_md_v map, edw_relations_md_v rel where rel.relation_name=:a and '||
          ' map.primary_source=rel.relation_id and rownum=1';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||' using '||p_object_name);
  end if;
  open cv for l_stmt using p_object_name;
  fetch cv into l_res;
  close cv;
  if l_res is null then
    return false;
  else
    return true;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

function create_dim_key_lookup(p_dim_name varchar2, p_dim_user_pk varchar2, p_dim_pk varchar2,
          p_lookup_table varchar2, p_parallel number,p_mode varchar2,p_op_table_space varchar2)
          return boolean is
l_stmt varchar2(4000);
Begin
  if g_debug then
    write_to_log_file_n('In create_dim_key_lookup');
    write_to_log_file('p_dim_name='||p_dim_name||',p_dim_user_pk='||p_dim_user_pk||',p_dim_pk='||
                      p_dim_pk||',p_lookup_table='||p_lookup_table||', p_parallel='||p_parallel);
  end if;
  if drop_table(p_lookup_table)=false then
    null;
  end if;
  l_stmt:='create table '||p_lookup_table;
  if p_op_table_space is not null then
    l_stmt:=l_stmt||' tablespace '||p_op_table_space;
  end if;
  if p_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||p_parallel||') ';
  end if;
  l_stmt:=l_stmt||' as select ';
  if p_parallel is not null then
    l_stmt:=l_stmt||'/*+PARALLEL ('||p_dim_name||','||p_parallel||')*/ ';
  end if;
  if p_mode='MAX' then
    l_stmt:=l_stmt||p_dim_user_pk||',max('||p_dim_pk||') '||p_dim_pk||' from '||p_dim_name||
      ' group by '||p_dim_user_pk;
  else
    l_stmt:=l_stmt||p_dim_user_pk||','||p_dim_pk||' from '||p_dim_name;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt);
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n(p_lookup_table||' created with '||sql%rowcount||' rows');
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

procedure set_g_read_cfig_options(p_read_cfig_options boolean) is
Begin
  g_read_cfig_options:=p_read_cfig_options;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
End;

function is_slow_change_implemented(p_dim_name varchar2) return boolean is
Begin
  return is_slow_change_implemented(p_dim_name,null);
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;
function is_slow_change_implemented(p_dim_name varchar2,p_is_name varchar2) return boolean is
l_is_name varchar2(40);
l_dim_id number;
l_stmt varchar2(4000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_res number:=null;
Begin
  if g_debug then
    write_to_log_file_n('In is_slow_change_implemented, p_dim_name is '||p_dim_name);
  end if;
  l_is_name:=null;
  l_dim_id:=get_dim_id(p_dim_name);
  if g_read_cfig_options then
    if edw_option.get_warehouse_option(null,l_dim_id,'SLOWDIM',l_is_name)=false then
      null;
    end if;
  else
    l_stmt:='select 1 from edw_dimensions_md_v dim,edw_attribute_sets_md_v sis where sis.attribute_group_name=:a '||
    ' and sis.entity_id=dim.dim_id and dim.dim_name=:b';
    l_is_name:=p_is_name;
    if l_is_name is null then
      l_is_name:='DIMENSION_HISTORY';
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||' using '||l_is_name||','||p_dim_name);
    end if;
    open cv for l_stmt using l_is_name,p_dim_name;
    fetch cv into l_res;
    close cv;
    if g_debug then
      write_to_log_file('l_res='||l_res);
    end if;
    if l_res=1 then
      l_is_name:='Y';
    else
      l_is_name:='N';
    end if;
  end if;
  if l_is_name='Y' then
    return true;
  else
    return false;
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

function get_dims_slow_change(p_dim_names varcharTableType,p_number_dims number,
          p_dim_list out NOCOPY varcharTableType ,p_number_dim_list out NOCOPY number)
          return boolean is
Begin
  return get_dims_slow_change(p_dim_names,p_number_dims,p_dim_list,p_number_dim_list,null);
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;
function get_dims_slow_change(p_dim_names varcharTableType,p_number_dims number,
          p_dim_list out NOCOPY varcharTableType ,p_number_dim_list out NOCOPY number,
          p_is_name varchar2) return boolean is
l_is_name varchar2(40);
l_dim_id number;
l_stmt varchar2(20000);
l_in_clause varchar2(10000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  if g_debug then
    write_to_log_file_n('In get_dims_slow_change');
  end if;
  p_number_dim_list:=0;
  if p_number_dims=0 then
    return true;
  end if;
  if g_read_cfig_options then
    for i in 1..p_number_dims loop
      l_is_name:=null;
      l_dim_id:=get_dim_id(p_dim_names(i));
      if edw_option.get_warehouse_option(null,l_dim_id,'SLOWDIM',l_is_name)=false then
        null;
      end if;
      if l_is_name='Y' then
        p_number_dim_list:=p_number_dim_list+1;
        p_dim_list(p_number_dim_list):=p_dim_names(i);
      end if;
    end loop;
  else
    l_in_clause:=null;
    for i in 1..p_number_dims loop
      l_in_clause:=l_in_clause||''''||p_dim_names(i)||''',';
    end loop;
    l_in_clause:=substr(l_in_clause,1,length(l_in_clause)-1);
    if g_debug then
      write_to_log_file_n('in clause is '||l_in_clause);
    end if;
    l_is_name:=p_is_name;
    if l_is_name is null then
      l_is_name:='DIMENSION_HISTORY';
    end if;
    l_stmt:='select dim.dim_name from edw_dimensions_md_v dim,edw_attribute_sets_md_v sis where sis.attribute_group_name=:a '||
    ' and sis.entity_id=dim.dim_id and dim.dim_name in ('||l_in_clause||')';
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||' using '||l_is_name);
    end if;
    open cv for l_stmt using l_is_name;
    p_number_dim_list:=1;
    loop
      fetch cv into p_dim_list(p_number_dim_list);
      exit when cv%notfound;
      p_number_dim_list:=p_number_dim_list+1;
    end loop;
    close cv;
    p_number_dim_list:=p_number_dim_list-1;
  end if;
  if g_debug then
    write_to_log_file_n('The number of dime with slow change '||p_number_dim_list);
    for i in 1..p_number_dim_list loop
      write_to_log_file(p_dim_list(i));
    end loop;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

function execute_stmt(p_stmt varchar2) return boolean is
Begin
  if g_debug then
    write_to_log_file_n('In execute_stmt. Going to execute ');
    write_to_log_file(p_stmt||' '||get_time);
  end if;
  execute immediate p_stmt;
  if g_debug then
    write_to_log_file_n('Executed with '||sql%rowcount||' row creation'||get_time);
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  write_to_log_file('Problem stmt '||p_stmt);
  g_status:=false;
  return false;
End;

/*
0: error
1: more or less than n row
2: only n row
*/
function does_table_have_only_n_row(p_table varchar2,p_row_count number) return number is
Begin
  return does_table_have_only_n_row(p_table,null,p_row_count);
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return 0;
End;
function does_table_have_only_n_row(p_table varchar2,p_where varchar2,p_row_count number) return number is
l_stmt varchar2(2000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_res number:=null;
l_count number:=0;
Begin
  if g_debug then
    write_to_log_file_n('In does_table_have_only_n_row '||p_table||' '||p_where||' '||p_row_count);
  end if;
  l_stmt:='select 1 from '||p_table;
  if p_where is not null then
    l_stmt:=l_stmt||' where '||p_where;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt);
  end if;
  open cv for l_stmt;
  loop
    fetch cv into l_res;
    exit when cv%notfound;
    l_count:=l_count+1;
    if l_count>p_row_count then
      exit;
    end if;
  end loop;
  close cv;
  if l_count=p_row_count then
    if g_debug then
      write_to_log_file_n('Yes');
    end if;
    return 2;
  else
    if g_debug then
      write_to_log_file_n('No');
    end if;
    return 1;
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return 0;
End;

function get_table_surr_pk(p_table varchar2, p_pk out NOCOPY varchar2) return boolean is
l_stmt varchar2(4000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  if g_debug then
    write_to_log_file_n('In get_table_surr_pk');
    write_to_log_file('p_table='||p_table);
  end if;
  l_stmt:='select pk_item.column_name from edw_unique_keys_md_v pk,edw_pvt_columns_md_v pk_item,edw_relations_md_v rel, '||
  'edw_pvt_key_columns_md_v isu where rel.relation_name=:a and pk.entity_id=rel.relation_id '||
  'and isu.key_id=pk.key_id and pk_item.column_id=isu.column_id and pk_item.column_name like ''%_KEY'' '||
  'and pk_item.parent_object_id=rel.relation_id';
  open cv for l_stmt using p_table;
  fetch cv into p_pk;
  close cv;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

function get_user_key(p_key varchar2) return varchar2 is
Begin
  return substr(p_key,1,instr(p_key,'_KEY')-1);
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return null;
End;

function is_inc_refresh_implemented(p_fact varchar2) return boolean is
l_stmt varchar2(4000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_res number:=null;
l_is_name varchar2(40):=null;
Begin
  if g_debug then
    write_to_log_file_n('In is_inc_refresh_implemented '||p_fact);
  end if;
  if g_read_cfig_options then
    if edw_option.get_warehouse_option(p_fact,null,'INCREMENTAL',l_is_name)=false then
      null;
    end if;
    if l_is_name='Y' then
      l_res:=1;
    else
      l_res:=0;
    end if;
  else
    l_stmt:='select 1 from edw_facts_md_v fact, edw_attribute_sets_md_v sis '||
     ' where fact.fact_name=:a and sis.entity_id=fact.fact_id and sis.attribute_group_name=''EDW_INC_REFRESH''';
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt);
    end if;
    open cv for l_stmt using p_fact;
    fetch cv into l_res;
    close cv;
  end if;
  if l_res =1 then
    if g_debug then
      write_to_log_file('Yes');
    end if;
    return true;
  else
    if g_debug then
      write_to_log_file('No');
    end if;
    return false;
  end if;
  return false;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;


function is_push_down_implemented(p_dim varchar2) return boolean is
l_stmt varchar2(10000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_res number:=null;
Begin
  if g_debug then
    write_to_log_file_n('In is_push_down_implemented '||p_dim);
  end if;
  l_stmt:='select 1 from edw_dimensions_md_v dim, edw_attribute_sets_md_v sis '||
     ' where dim.dim_name=:a and sis.entity_id=dim.dim_id '||
     'and sis.attribute_group_name=''EDW_LEVEL_PUSH_DOWN''';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt);
  end if;
  open cv for l_stmt using p_dim;
  fetch cv into l_res;
  close cv;
  if l_res =1 then
    if g_debug then
      write_to_log_file('Yes');
    end if;
    return true;
  else
    if g_debug then
      write_to_log_file('No');
    end if;
    return false;
  end if;
  return false;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

procedure set_parallel(p_parallel number) is
begin
  g_parallel:=p_parallel;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
End;

function is_delete_trigger_imp(p_object varchar2, p_owner varchar2) return boolean is
l_stmt varchar2(10000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_type varchar2(400):=null;
Begin
  if g_debug then
    write_to_log_file_n('In is_delete_trigger_imp');
    write_to_log_file('p_object='||p_object);
    write_to_log_file('p_owner='||p_owner);
  end if;
  l_stmt:='select triggering_event from all_triggers where table_name =:a and table_owner=:b';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt);
  end if;
  open cv for l_stmt using p_object,p_owner;
  fetch cv into l_type;
  close cv;
  if l_type='DELETE' then
    return true;
  else
    return false;
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return true;--for safety
End;

function insert_into_coll_progress(
  OBJECT_NAME                              VARCHAR2
, OBJECT_TYPE                              VARCHAR2
, STATUS                                   VARCHAR2
, NUMBER_PROCESSED                         NUMBER ) return boolean is
l_stmt varchar2(4000);
Begin
--g_conc_program_id
  if g_debug then
    write_to_log_file_n('In insert_into_coll_progress');
  end if;
  l_stmt:='insert into edw_coll_progress_log(OBJECT_NAME,OBJECT_TYPE,STATUS, '||
          ' NUMBER_PROCESSED,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,CREATION_DATE, '||
          ' CREATED_BY,LAST_UPDATE_BY) values (:a1,:a2,:a3,:a4,:a5,:a6,:a7,:a8,:a9)';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt);
    write_to_log_file('Parameter '||OBJECT_NAME||','||OBJECT_TYPE||','||STATUS||','||NUMBER_PROCESSED||','||
    sysdate||','||g_conc_program_id||','||sysdate||','||g_conc_program_id||','||g_conc_program_id);
  end if;
  execute immediate l_stmt using OBJECT_NAME,OBJECT_TYPE,STATUS,NUMBER_PROCESSED,
    sysdate,g_conc_program_id,sysdate,g_conc_program_id,g_conc_program_id;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

/* API that returns the sec sources and fk-pk constraints for the sec sources given a mapping id */
function get_sec_source_info(
    p_map_id number,
    p_sec_source out NOCOPY varcharTableType,
    p_sec_source_id out NOCOPY numberTableType,
    p_sec_source_child out NOCOPY varcharTableType,
    p_sec_source_child_id out NOCOPY numberTableType,
    p_pk  out NOCOPY varcharTableType,
    p_fk  out NOCOPY varcharTableType,
    p_sec_source_usage out NOCOPY numberTableType,
    p_sec_source_usage_name out NOCOPY varcharTableType,
    p_sec_source_child_usage out NOCOPY numberTableType,
    p_sec_source_number out NOCOPY number) return boolean is
l_stmt varchar2(10000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  if g_debug then
    write_to_log_file_n('In Util.get_sec_source_info');
  end if;
  p_sec_source_number:=0;
  l_stmt:=' select '||
  'sec_relation.relation_name,  '||
  'sec_relation.relation_id,  '||
  'sec_relation_child.relation_name, '||
  'sec_relation_child.relation_id,  '||
  'pk_item.column_name,  '||
  'fk_item.column_name,  '||
  'sec_relation_usage.source_usage_id,  '||
  'sec_relation_usage.source_alias,  '||
  'sec_relation_child_usage.source_usage_id  '||
  'from  '||
  'edw_pvt_map_sources_md_v        sec_relation_usage,  '||
  'edw_relations_md_v               sec_relation,  '||
  'edw_pvt_map_sources_md_v        sec_relation_child_usage,  '||
  'edw_relations_md_v               sec_relation_child,  '||
  'edw_pvt_map_key_usages_md_v      fk_usage,  '||
  'edw_pvt_key_columns_md_v         fk_isu,  '||
  'edw_pvt_columns_md_v                   fk_item,  '||
  'edw_pvt_key_columns_md_v         pk_isu,  '||
  'edw_pvt_columns_md_v                   pk_item  '||
  'where  '||
  ' sec_relation_usage.mapping_id=:a '||
  'and sec_relation.relation_id=sec_relation_usage.source_id '||
  'and sec_relation_child_usage.mapping_id=sec_relation_usage.mapping_id '||
  'and sec_relation_child.relation_id=sec_relation_child_usage.source_id '||
  'and fk_usage.source_usage_id=sec_relation_child_usage.source_usage_id '||
  'and fk_usage.Parent_table_usage_id=sec_relation_usage.source_usage_id '||
  'and fk_usage.mapping_id=sec_relation_usage.mapping_id '||
  'and fk_isu.key_id=fk_usage.foreign_key_id '||
  'and fk_item.column_id=fk_isu.column_id '||
  'and fk_item.parent_object_id=sec_relation_child.relation_id '||
  'and pk_isu.key_id=fk_usage.unique_key_id '||
  'and pk_item.column_id=pk_isu.column_id '||
  'and pk_item.parent_object_id=sec_relation.relation_id '||
  'order by sec_relation_usage.source_usage_id';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||' using '||p_map_id);
  end if;
  open cv for l_stmt using p_map_id;
  p_sec_source_number:=1;
  loop
    fetch cv into
      p_sec_source(p_sec_source_number),
      p_sec_source_id(p_sec_source_number),
      p_sec_source_child(p_sec_source_number),
      p_sec_source_child_id(p_sec_source_number),
      p_pk(p_sec_source_number),
      p_fk(p_sec_source_number),
      p_sec_source_usage(p_sec_source_number),
      p_sec_source_usage_name(p_sec_source_number),
      p_sec_source_child_usage(p_sec_source_number);
    exit when cv%notfound;
    p_sec_source_number:=p_sec_source_number+1;
  end loop;
  close cv;
  p_sec_source_number:=p_sec_source_number-1;
  if g_debug then
    write_to_log_file('Results');
    for i in 1..p_sec_source_number loop
      write_to_log_file(p_sec_source(i)||' '||p_sec_source_id(i)||' '||p_sec_source_child(i)||' '||
        p_sec_source_child_id(i)||' '||p_pk(i)||' '||p_fk(i)||' '||p_sec_source_usage(i)||' '||
        p_sec_source_usage_name(i)||' '||p_sec_source_child_usage(i));
    end loop;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

function bubble_sort(p_input numberTableType,p_input_number number, p_output out NOCOPY numberTableType)
 return boolean is
l_temp number;
Begin
  if p_input_number<=0 then
    return true;
  end if;
  if p_input_number=1 then
    p_output(1):=p_input(1);
  end if;
  for i in 1..p_input_number loop
    p_output(i):=p_input(i);
  end loop;
  for i in 1..p_input_number-1 loop
    for j in 1..p_input_number-i loop
      if p_output(j+1)<p_output(j) then
        l_temp:=p_output(j);
        p_output(j):=p_output(j+1);
        p_output(j+1):=l_temp;
      end if;
    end loop;
  end loop;
  if g_debug then
    write_to_log_file_n('Before and after sort');
    for i in 1..p_input_number loop
      write_to_log_file(p_input(i)||'   '||p_output(i));
    end loop;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

/*
make_transforms_rec is a recursive function that will find out NOCOPY the nested transforms, construct the
statement and return it.
this is called for any transform. what is passed first is the derived fact id
this is called only for 2 cases. first, if there is a transform on the target, the target calls it first
then its called only for nested transformations
*/
/*
logic for aggregation
if this level has aggregation then
  if not a transform or constant apply aggregation
  if hild level reports no aggregation then apply aggregation
if this level has no aggregation then
  if the child level reports aggregation then
    apply aggregation to columns.
    if any transform reports no aggregation, apply aggregation
*/
function make_transforms_rec(
  p_hold_func varcharTableType,
  p_hold_func_category varcharTableType,
  p_hold_item varcharTableType,
  p_hold_item_id numberTableType,
  p_hold_item_is_fk booleanTableType,
  p_hold_relation numberTableType,
  p_hold_relation_usage numberTableType,
  p_hold_item_usage numberTableType,
  p_hold_aggregatefunction varcharTableType,
  p_hold_is_distinct numberTableType,
  p_hold_relation_name varcharTableType,
  p_hold_func_usage numberTableType,
  p_hold_func_position numberTableType,
  p_hold_func_dvalue varcharTableType,
  p_sec_sources  varcharTableType,
  p_number_sec_sources number,
  p_target_id number,
  p_src_object varchar2,
  p_hold_number number,
  p_index  number,
  p_agg_flag out NOCOPY varchar2
) return varchar2 is
l_func_usage number;
l_index number:=null;
l_transform varchar2(20000);
l_ind_transform varcharTableType; --individual transforms
l_ind_transform_position numberTableType;
l_ind_agg  varcharTableType; --whether there is agg or not
l_ind_type varcharTableType; --type, col or constant or transform etc
l_ind_transform_number number;
l_agg_flag boolean;
l_aggregation_value varchar2(200); --used for p_agg_flag
l_is_groupby_flag boolean:=false;
Begin
  if g_debug then
    write_to_log_file_n('In make_transforms_rec');
    write_to_log_file('p_index='||p_index);
  end if;
  p_agg_flag:='NO-AGGREGATION';
  l_aggregation_value:=null;
  l_agg_flag:=false;
  --see if the object is the target table (ex derived fact)
  if p_hold_relation(p_index)=p_target_id then
    l_func_usage:=p_hold_func_usage(p_index);
    l_index:=p_index;
  else
    --search for the same occurance of the item
    declare
      l_found boolean;
      l_max number;
    begin
      for i in 1..p_hold_number loop
        if i <> p_index and p_hold_item_id(p_index)=p_hold_item_id(i) then
          /*
            we are looking for p_hold_item_id(p_index) being the output and not the input so
            logic is
            look at the position. if its 0, this is the output
          */
          if p_hold_func_position(i)=0 then
            l_index:=i;
            l_func_usage:=p_hold_func_usage(l_index);
            exit;
          end if;
        end if;
      end loop;
    exception when others then
      g_status_message:=sqlerrm;
      g_status:=false;
      write_to_log_file_n(g_status_message);
      write_to_log_file('Failed for '||p_hold_item_id(p_index));
      return null;
    end;
  end if;
  if g_debug then
    write_to_log_file_n('l_index='||l_index);
    write_to_log_file('l_func_usage='||l_func_usage);
  end if;
  if l_index is null then
    return null;
  end if;
  --build the transform
  if lower(p_hold_func_category(l_index)) <> 'basic' and
     lower(p_hold_func_category(l_index)) <> 'character' and
     lower(p_hold_func_category(l_index)) <> 'conversion' and
     lower(p_hold_func_category(l_index)) <> 'date' and
     lower(p_hold_func_category(l_index)) <> 'numeric' and
     upper(p_hold_func_category(l_index)) not like 'EDW_STAND_ALONE%' and
     upper(p_hold_func_category(l_index)) <> 'EDW_STANDARD_TRANSFORMS' then
    if p_hold_func(l_index)='GROUP_BY' then
      l_is_groupby_flag:=true;
      l_transform:='';
      p_agg_flag:='AGGREGATION';
    else
      l_transform:=p_hold_func_category(l_index)||'.'||p_hold_func(l_index)||'(';
    end if;
  else
    if p_hold_func(l_index)='GROUP_BY' then
      l_is_groupby_flag:=true;
      l_transform:='';
      p_agg_flag:='AGGREGATION';
    else
      if p_hold_func(l_index)='COUNT' then
        l_transform:=p_hold_func(l_index)||'(';
        p_agg_flag:='AGGREGATION';
      else
        if instr(p_hold_func(l_index),'_')=length(p_hold_func(l_index)) then
          l_transform:=substr(p_hold_func(l_index),1,length(p_hold_func(l_index))-1)||'(';
        else
          l_transform:=p_hold_func(l_index)||'(';
        end if;
      end if;
    end if;
  end if;
  --first see if there is any aggregation
  if l_agg_flag=false then
    for i in 1..p_hold_number loop
      if p_hold_func_usage(l_index)=p_hold_func_usage(i) then
        if p_hold_aggregatefunction(i) is not null then
          l_agg_flag:=true;
          p_agg_flag:='AGGREGATION';
          exit;
        end if;
      end if;
    end loop;
  end if;
  if g_debug then
    if l_agg_flag then
      write_to_log_file_n('aggregate function implemented');
    else
      write_to_log_file_n('aggregate function NOT implemented');
    end if;
  end if;
  l_ind_transform_number:=0;
  for i in 1..p_hold_number loop
    if i <> l_index then
      if p_hold_func_usage(i) = l_func_usage then
        --see if the object is the base fact or a sec source
        if p_hold_relation_name(i)=p_src_object or value_in_table(p_sec_sources,
           p_number_sec_sources,p_hold_relation_name(i)) then
          if g_debug then
            write_to_log_file_n('src object or sec source ,p_hold_item(i)='||p_hold_item(i)||',relation='||
            p_hold_relation_name(i));
          end if;
          l_ind_transform_number:=l_ind_transform_number+1;
          l_ind_type(l_ind_transform_number):='COLUMN';
          --make the transform
          if l_agg_flag then
            l_ind_agg(l_ind_transform_number):='AGGREGATION';
            if p_hold_aggregatefunction(i) is not null then
              if p_hold_is_distinct(i)=1 then
                l_ind_transform(l_ind_transform_number):=p_hold_aggregatefunction(i)||'(DISTINCT('||
                p_hold_item(i)||'))';
              else
                l_ind_transform(l_ind_transform_number):=p_hold_aggregatefunction(i)||'('||p_hold_item(i)||')';
              end if;
              l_ind_transform_position(l_ind_transform_number):=p_hold_func_position(i);
            else
              l_ind_transform(l_ind_transform_number):='SUM('||p_hold_item(i)||')';
              l_ind_transform_position(l_ind_transform_number):=p_hold_func_position(i);
            end if;
          else --there is no aggregation
            l_ind_agg(l_ind_transform_number):='NO-AGGREGATION';
            l_ind_transform(l_ind_transform_number):=p_hold_item(i);
            l_ind_transform_position(l_ind_transform_number):=p_hold_func_position(i);
          end if;
        elsif p_hold_func_dvalue(i) is not null then --constant parameters
          if g_debug then
            write_to_log_file_n('constant parameter ,p_hold_item(i)='||p_hold_item(i));
          end if;
          l_ind_transform_number:=l_ind_transform_number+1;
          l_ind_type(l_ind_transform_number):='CONSTANT';
          l_ind_agg(l_ind_transform_number):='NO-AGGREGATION';
          l_ind_transform(l_ind_transform_number):=p_hold_func_dvalue(i);
          l_ind_transform_position(l_ind_transform_number):=p_hold_func_position(i);
        else
          --recursion needed here
          if g_debug then
            write_to_log_file_n('recursion needed ,p_hold_item(i)='||p_hold_item(i));
          end if;
          l_ind_transform_number:=l_ind_transform_number+1;
          l_ind_type(l_ind_transform_number):='TRANSFORMATION';
          l_ind_transform_position(l_ind_transform_number):=p_hold_func_position(i);
          l_ind_transform(l_ind_transform_number):=make_transforms_rec(
            p_hold_func,
            p_hold_func_category,
            p_hold_item,
            p_hold_item_id,
            p_hold_item_is_fk,
            p_hold_relation,
            p_hold_relation_usage,
            p_hold_item_usage,
            p_hold_aggregatefunction,
            p_hold_is_distinct,
            p_hold_relation_name,
            p_hold_func_usage,
            p_hold_func_position,
            p_hold_func_dvalue,
            p_sec_sources,
            p_number_sec_sources,
            p_target_id,
            p_src_object,
            p_hold_number,
            i,
            l_aggregation_value);
          if l_ind_transform(l_ind_transform_number) is null then
            write_to_log_file_n('l_ind_transform('||l_ind_transform_number||') is null. Error');
            return null;
          end if;
          l_ind_agg(l_ind_transform_number):=l_aggregation_value;
          if l_agg_flag then
            if l_aggregation_value='AGGREGATION' then
              null;
            else
              l_ind_transform(l_ind_transform_number):='SUM('||l_ind_transform(l_ind_transform_number)||')';
            end if;
          else--this level has no agg
            null;
          end if;
        end if;
      end if;
    end if;
  end loop;
  if l_agg_flag=false then --this level has no agg
    for i in 1..l_ind_transform_number loop
      if l_ind_type(i)='TRANSFORMATION' and l_ind_agg(i)='AGGREGATION' then
        p_agg_flag:='AGGREGATION';
        for j in 1..l_ind_transform_number loop
          if l_ind_type(i)='COLUMN' then
            l_ind_transform(l_ind_transform_number):='SUM('||l_ind_transform(l_ind_transform_number)||')';
          elsif l_ind_type(i)='TRANSFORMATION' and l_ind_agg(i)='NO-AGGREGATION' then
            l_ind_transform(l_ind_transform_number):='SUM('||l_ind_transform(l_ind_transform_number)||')';
          end if;
        end loop;
        exit;
      end if;
    end loop;
  end if;

  if g_debug then
    write_to_log_file_n('The func inputs and position and type and aggregation');
    for i in 1..l_ind_transform_number loop
      write_to_log_file(l_ind_transform(i)||'  '||l_ind_transform_position(i)||' '||
        l_ind_type(i)||' '||l_ind_agg(i));
    end loop;
  end if;
  declare
    l_pos number:=0;
    l_pos_flag boolean:=false;
    l_output_pos  numberTableType;
    l_sign varchar2(100); --this is the multiply sign *, divide sign / etc
  begin
    --make the transformation
    --first see if position is implemented
    for i in 1..l_ind_transform_number loop
      if l_ind_transform_position(i) is not null then
        l_pos_flag:=true;
        --if there are nulls, make them all 0
        for j in 1..l_ind_transform_number loop
          if l_ind_transform_position(j) is null then
            --l_ind_transform_position(j):=0;
            l_pos:=l_pos+1;
          end if;
        end loop;
        if l_pos>0 then
          for j in 1..l_ind_transform_number loop
            l_ind_transform_position(j):=nvl(l_ind_transform_position(j),0)+l_pos;
          end loop;
        end if;
        exit;
      end if;
    end loop;
    --l_transform
    if l_pos_flag then
      --get a sort of the positions
      if bubble_sort(l_ind_transform_position,
        l_ind_transform_number,l_output_pos)=false then
        g_status_message:=sqlerrm;
        write_to_log_file_n(g_status_message);
        g_status:=false;
        return null;
      end if;
    end if;
    --l_output_pos has the ascending order of ranks
    --see if the function is a standard function implementation
    if upper(p_hold_func_category(l_index))='EDW_STANDARD_TRANSFORMS' or
    upper(p_hold_func_category(l_index)) like 'EDW_STAND_ALONE%' then
      --these are MULTIPLY, DIVIDE, ADD, SUBTRACT etc
      if p_hold_func(l_index)='MULTIPLY' then
        l_sign:='*';
      elsif p_hold_func(l_index)='DIVIDE' then
        l_sign:='/';
      elsif p_hold_func(l_index)='ADD' or p_hold_func(l_index)='SUM' then
        l_sign:='+';
      elsif p_hold_func(l_index)='SUBTRACT' then
        l_sign:='-';
      else
        l_sign:=',';
      end if;
      --if l_sign is a ',' then its a function
      if l_sign<> ',' then
        l_transform:='(';
      end if;
      if l_pos_flag = false then
        for i in 1..l_ind_transform_number loop
          l_transform:=l_transform||l_ind_transform(i)||l_sign;
        end loop;
      else
        for i in 1..l_ind_transform_number loop
          for j in 1..l_ind_transform_number loop
            if l_ind_transform_position(j)=l_output_pos(i) then
              l_transform:=l_transform||l_ind_transform(j)||l_sign;
            end if;
          end loop;
        end loop;
      end if;
    else
      if l_pos_flag = false then
        for i in 1..l_ind_transform_number loop
          l_transform:=l_transform||l_ind_transform(i)||',';
        end loop;
      else
        for i in 1..l_ind_transform_number loop
          for j in 1..l_ind_transform_number loop
            if l_ind_transform_position(j)=l_output_pos(i) then
              l_transform:=l_transform||l_ind_transform(j)||',';
            end if;
          end loop;
        end loop;
      end if;
    end if;
    if l_is_groupby_flag then
      l_transform:=substr(l_transform,1,length(l_transform)-1);
    else
      l_transform:=substr(l_transform,1,length(l_transform)-1)||')';
    end if;
  exception when others then
    g_status_message:=sqlerrm;
    g_status:=false;
    write_to_log_file_n(g_status_message);
    return null;
  end;
  return l_transform;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return null;
End;

procedure insert_into_load_progress(p_load_fk number,p_object_name varchar2,p_object_id number,
  p_load_progress varchar2,p_start_date date,p_end_date date,p_category varchar2, p_operation varchar2,
  p_seq_id varchar2,p_flag varchar2,p_obj_id number) is
l_stmt varchar2(2000);
l_sysdate date;
Begin
  l_sysdate:=sysdate;
  if p_flag='U' then
    --update
    l_stmt:='update edw_load_progress_log set end_date=:a1,last_update_date=:a2 '||
    'where load_fk=:a3 and seq_id=:a4 and obj_id=:a5';
    execute immediate l_stmt using p_end_date,l_sysdate,p_load_fk,p_seq_id,p_obj_id;
  else
    l_stmt:='insert into edw_load_progress_log(load_fk,seq_id,obj_id,object_name,object_id,load_progress,start_date,end_date,'||
    'category,operation,creation_date,last_update_date,created_by,last_update_by,last_update_login) '||
    'values(:a1,:a2,:a3,:a4,:a5,:a6,:a7,:a8,:a9,:a10,:a11,:a12,:a13,:a14,:a15)';
    execute immediate l_stmt using p_load_fk,p_seq_id,p_obj_id,p_object_name,p_object_id,p_load_progress,
    p_start_date,p_end_date,p_category,p_operation,l_sysdate,l_sysdate,g_conc_program_id,g_conc_program_id,
    g_conc_program_id;
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
End;

function get_item_set_cols(p_cols out NOCOPY varcharTableType, p_number_cols out NOCOPY number,
p_object varchar2,p_item_set varchar2) return boolean is
l_stmt varchar2(5000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_count number;
Begin
  if g_debug then
    write_to_log_file_n('In get_item_set_cols');
  end if;
  l_stmt:='select item.column_name from edw_attribute_sets_md_v sis, edw_attribute_set_columns_md_v isu, '||
  'edw_pvt_columns_md_v item, '||
  'edw_relations_md_v rel where rel.relation_name=:a and sis.entity_id=rel.relation_id '||
  'and sis.attribute_group_name=:b and isu.attribute_group_id=sis.attribute_group_id and '||
  'item.column_id=isu.column_id and item.parent_object_id=rel.relation_id';
  p_number_cols:=0;
  l_count:=1;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||' using '||p_object||','||p_item_set);
  end if;
  open cv for l_stmt using p_object,p_item_set;
  loop
    fetch cv into p_cols(l_count);
    exit when cv%notfound;
    l_count:=l_count+1;
  end loop;
  close cv;
  l_count:=l_count-1;
  p_number_cols:=l_count;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_item_set_cols '||sqlerrm);
  return false;
End;


function get_level_prefix(p_level varchar2) return varchar2 is
l_prefix varchar2(40);
l_stmt varchar2(1000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  l_stmt:='select level_prefix from edw_levels_md_v where level_name=:a';
  if g_debug then
    write_to_log_file_n(l_stmt||' '||p_level);
  end if;
  open cv for l_stmt using p_level;
  fetch cv into l_prefix;
  close cv;
  return l_prefix;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_level_prefix '||sqlerrm);
  return null;
End;

--only for COPY mapping
function get_obj_obj_map_details(p_src_object varchar2,p_tgt_object varchar2,p_map_name varchar2,
p_src_cols out NOCOPY varcharTableType, p_tgt_cols out NOCOPY varcharTableType, p_number_cols out NOCOPY number) return boolean is
l_stmt varchar2(5000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_number_cols number;
l_mapping_id number;
Begin
  if g_debug then
    write_to_log_file_n('In EDW_OWB_COLLECTION_UTIL.get_obj_obj_map_details');
    write_to_log_file('p_src_object='||p_src_object||',p_tgt_object='||p_tgt_object||',p_map_name='||p_map_name);
  end if;
  p_number_cols:=0;
  l_mapping_id:=get_target_map(null,p_tgt_object);
  if p_map_name is null then
    l_stmt:='select src_it.column_name,tgt_it.column_name '||
    'from '||
    'edw_relations_md_v src_rel, '||
    'edw_relations_md_v tgt_rel, '||
    'edw_pvt_map_sources_md_v map_sources, '||
    '(select * from edw_pvt_map_columns_md_v where mapping_id=:1) map_columns, '||
    'edw_pvt_map_properties_md_v map, '||
    'edw_pvt_columns_md_v tgt_it, '||
    'edw_pvt_columns_md_v src_it '||
    'where '||
    'tgt_rel.relation_name=:a '||
    'and src_rel.relation_name=:b '||
    'and map.primary_target=tgt_rel.relation_id '||
    'and map_sources.mapping_id=map.mapping_id '||
    'and map_sources.source_id=src_rel.relation_id '||
    'and map_columns.source_usage_id=map_sources.source_usage_id '||
    'and tgt_it.column_id=map_columns.Target_column_id '||
    'and src_it.column_id=map_columns.source_column_id '||
    'and tgt_it.parent_object_id=tgt_rel.relation_id '||
    'and src_it.parent_object_id=src_rel.relation_id ';
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||' using '||l_mapping_id||','||
      p_tgt_object||','||p_src_object);
    end if;
    open cv for l_stmt using l_mapping_id,p_tgt_object,p_src_object;
  else
    l_stmt:='select src_it.column_name,tgt_it.column_name '||
    'from '||
    'edw_relations_md_v src_rel, '||
    'edw_relations_md_v tgt_rel, '||
    'edw_pvt_map_sources_md_v map_sources, '||
    '(select * from edw_pvt_map_columns_md_v where mapping_id=:1) map_columns, '||
    'edw_pvt_map_properties_md_v map, '||
    'edw_pvt_columns_md_v tgt_it, '||
    'edw_pvt_columns_md_v src_it, '||
    'edw_pvt_mappings_md_v model '||
    'where '||
    'tgt_rel.relation_name=:a '||
    'and src_rel.relation_name=:b '||
    'and model.mapping_name=:c '||
    'and map.primary_target=tgt_rel.relation_id '||
    'and model.mapping_id=map.mapping_id '||
    'and map_sources.mapping_id=map.mapping_id '||
    'and map_sources.source_id=src_rel.relation_id '||
    'and map_columns.source_usage_id=map_sources.source_usage_id '||
    'and tgt_it.column_id=map_columns.Target_column_id '||
    'and src_it.column_id=map_columns.source_column_id '||
    'and tgt_it.parent_object_id=tgt_rel.relation_id '||
    'and src_it.parent_object_id=src_rel.relation_id ';
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||' using '||l_mapping_id||','||
      p_tgt_object||','||p_src_object||','||
      p_map_name);
    end if;
    open cv for l_stmt using l_mapping_id,p_tgt_object,p_src_object,p_map_name;
  end if;
  l_number_cols:=1;
  loop
    fetch cv into p_src_cols(l_number_cols),p_tgt_cols(l_number_cols);
    exit when cv%notfound;
    l_number_cols:=l_number_cols+1;
  end loop;
  close cv;
  l_number_cols:=l_number_cols-1;
  p_number_cols:=l_number_cols;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_obj_obj_map_details '||sqlerrm);
  return false;
End;


/************************************************************
     for VBH
************************************************************/
function get_vbh_mapping(
		p_src_name varchar2,
        p_tgt_name varchar2,
		p_map varchar2,
		p_src_table out NOCOPY varcharTableType,
		p_src_col out NOCOPY varcharTableType,
		p_tgt_table out NOCOPY varcharTableType,
		p_tgt_col out NOCOPY varcharTableType,
		p_number_maps out NOCOPY number,
        p_debug boolean) return boolean is
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_stmt varchar2(30000);
l_map_id number;
l_tgt_id number;
l_src_id number;
Begin
  p_number_maps:=0;
  l_stmt:='select map.mapping_id,map.primary_target, map.primary_source '||
  'from  edw_pvt_map_properties_md_v map, edw_relations_md_v src, edw_relations_md_v tgt, '||
  'edw_pvt_mappings_md_v model where map.primary_target=tgt.relation_id and '||
  'map.primary_source=src.relation_id and tgt.relation_name=:a and src.relation_name=:b and '||
  'model.mapping_name=:c and model.mapping_id=map.mapping_id';
  if p_debug then
    write_to_log_file_n('Going to execute '||l_stmt||' using '||p_tgt_name||'  '||
	p_src_name||'   '||p_map);
  end if;
  open cv for l_stmt using p_tgt_name, p_src_name, p_map;
  fetch cv into l_map_id, l_tgt_id,l_src_id;
  close cv;
  l_stmt:='select '||
	'src.relation_name, '||
	'src_col.column_name, '||
	'tgt.relation_name, '||
	'tgt_col.column_name '||
	'from '||
    'edw_relations_md_v src, '||
    'edw_relations_md_v tgt, '||
    'edw_pvt_columns_md_v src_col, '||
    'edw_pvt_columns_md_v tgt_col, '||
    'edw_pvt_map_properties_md_v map, '||
    'edw_pvt_map_sources_md_v map_source, '||
    '(select * from edw_pvt_map_columns_md_v where mapping_id=:1) map_columns '||
    'where '||
    'map.mapping_id=:a '||
    'and map_source.mapping_id=map.mapping_id '||
    'and map_source.source_id=src.relation_id '||
    'and map_columns.source_usage_id=map_source.source_usage_id '||
    'and map.primary_target=tgt.relation_id '||
    'and map.primary_source=src.relation_id '||
    'and src_col.column_id=map_columns.Source_column_id '||
    'and tgt_col.column_id=map_columns.target_column_id '||
    'and tgt_col.parent_object_id=tgt.relation_id '||
    'and src_col.parent_object_id=src.relation_id ';
  open cv for l_stmt using l_map_id,l_map_id;
  p_number_maps:=1;
  loop
   fetch cv into
     p_src_table(p_number_maps),p_src_col(p_number_maps),
     p_tgt_table(p_number_maps),p_tgt_col(p_number_maps);
     exit when cv%notfound;
     p_number_maps:=p_number_maps+1;
  end loop;
  close cv;
  p_number_maps:=p_number_maps-1;
  write_to_log_file('The number of detailed mappings found for dim '||p_tgt_name||'= '||p_number_maps);
  if p_debug then
    write_to_log_file('  ');
    write_to_log_file('Src Table    Src column    Tgt Table    Tgt Column');
    write_to_log_file('  ');
    for i in 1..p_number_maps loop
      write_to_log_file(p_src_table(i)||'   '||p_src_col(i)||'    '||
        p_tgt_table(i)||'   '||p_tgt_col(i));
    end loop;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_vbh_mapping '||sqlerrm);
  return false;
End;

/**************************************************************/


/******************************************************************
        FOR VIKAS
*******************************************************************/
function is_slowly_changing_dimension(p_dim_name varchar2) return varchar2 is
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_stmt varchar2(5000);
l_sis_name varchar2(200);
l_var number;
begin
  if g_debug then
    write_to_log_file_n('In is_slowly_changing_dimension , dim is '||p_dim_name);
  end if;
  l_sis_name:='DIMENSION_HISTORY';
  l_var:=null;
  l_stmt:='select 1 from edw_dimensions_md_v dim, edw_attribute_sets_md_v sis '||
        ' where dim.dim_name=:a and sis.entity_id=dim.dim_id and sis.attribute_group_name=:b ';
  open cv for l_stmt using p_dim_name, l_sis_name;
  fetch cv into l_var;
  close cv;
  if l_var is null then
    return 'FALSE';
  else
    return 'TRUE';
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in is_slowly_changing_dimension for '||p_dim_name||'  '||sqlerrm);
  return 'FALSE';
End;

/**********************************************************************/
function get_table_index_col(
p_table varchar2,
p_owner varchar2,
p_index out NOCOPY varcharTableType,
p_ind_col out NOCOPY varcharTableType,
p_ind_col_pos out NOCOPY numberTableType,
p_number_index out NOCOPY number) return boolean is
l_stmt varchar2(2000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  p_number_index:=0;
  l_stmt:='select index_name, column_name,column_position from all_ind_columns where table_name=:a and TABLE_OWNER=:b';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||' using '||p_table||','||p_owner);
  end if;
  p_number_index:=1;
  open cv for l_stmt using p_table,p_owner;
  loop
    fetch cv into p_index(p_number_index),p_ind_col(p_number_index),p_ind_col_pos(p_number_index);
    exit when cv%notfound;
    p_number_index:=p_number_index+1;
  end loop;
  close cv;
  p_number_index:=p_number_index-1;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

/*
is there an index with just this column?
*/
function check_index_on_column(
p_table varchar2,
p_owner varchar2,
p_column varchar2
)return boolean is
l_index varcharTableType;
l_ind_col varcharTableType;
l_ind_col_pos numberTableType;
l_number_index number;
l_found boolean;
Begin
  if g_debug then
    write_to_log_file_n('In check_index_on_column '||p_table||' '||p_owner||' '||p_column);
  end if;
  if get_table_index_col(
    p_table,
    p_owner,
    l_index,
    l_ind_col,
    l_ind_col_pos,
    l_number_index)=false then
    return false;
  end if;
  l_found:=false;
  for i in 1..l_number_index loop
    if l_ind_col(i)=p_column then
      l_found:=true;
      for j in 1..l_number_index loop
        if i<>j and l_index(i)=l_index(j) then
          l_found:=false;
          exit;
        end if;
      end loop;
      if l_found then
        if g_debug then
          write_to_log_file_n('Index found '||l_index(i)||' with only column '||p_column);
        end if;
        exit;
      end if;
    end if;
  end loop;
  return l_found;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;


function get_object_id(p_object varchar2) return number is
l_stmt varchar2(2000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_obj_id number;
Begin
  l_stmt:='select relation_id from edw_relations_md_v where relation_name=:a';
  open cv for l_stmt using p_object;
  fetch cv into l_obj_id;
  close cv;
  return l_obj_id;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return -1;
End;

function get_dim_id(p_object varchar2) return number is
l_stmt varchar2(2000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_obj_id number;
Begin
  l_stmt:='select dim_id from edw_dimensions_md_v where dim_name=:a';
  open cv for l_stmt using p_object;
  fetch cv into l_obj_id;
  close cv;
  return l_obj_id;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return -1;
End;

function last_analyzed_date(p_table varchar2) return date is
Begin
  return last_analyzed_date(p_table,null);
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return null;
End;

function last_analyzed_date(p_table varchar2,p_owner varchar2) return date is
l_stmt varchar2(2000);
l_table_owner varchar2(30);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_var date;
Begin
  if p_owner is not null then
    l_stmt:='select last_analyzed from all_tables where table_name=:a and owner=:b';
    open cv for l_stmt using p_table,p_owner;
  else
      l_stmt:='select table_owner from user_synonyms where table_name=:a';
      open cv for l_stmt using p_table;
      	     fetch cv into l_table_owner;
      close cv;
     l_stmt:='select last_analyzed from all_tables where table_name=:a and owner=:b';--rkumar:bug#4905343
    open cv for l_stmt using p_table, l_table_owner;
  end if;
  fetch cv into l_var;
  close cv;  --bug#4905343
  return l_var;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return null;
End;

function get_table_count(p_table varchar2) return number is
Begin
  return get_table_count(p_table,null);
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return -1;
End;
function get_table_count(p_table varchar2,p_where varchar2) return number is
l_stmt varchar2(2000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_count number;
Begin
  l_stmt:='select ';
  if g_parallel is not null then
    l_stmt:=l_stmt||' /*+PARALLEL('||p_table||','||g_parallel||')*/ ';
  end if;
  if p_where is null then
    l_stmt:=l_stmt||' count(*) from '||p_table;
  else
    l_stmt:=l_stmt||' count(*) from '||p_table||' where '||p_where;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  open cv for l_stmt;
  fetch cv into l_count;
  close cv;
  return l_count;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return -1;
End;

function get_table_avg_row_len(p_table varchar2,p_owner varchar2,p_avg_row_len out NOCOPY number)
return boolean is
l_table_space varchar2(400);
l_initial_extent number;
l_next_extent number;
l_pct_free number;
l_pct_used number;
l_pct_increase number;
l_max_extents number;
Begin
  return get_table_storage(p_table,p_owner,l_table_space,l_initial_extent,l_next_extent,l_pct_free,l_pct_used,
  l_pct_increase,l_max_extents,p_avg_row_len);
Exception when others then
  write_to_log_file_n(sqlerrm);
  return false;
End;


function get_table_storage(p_table varchar2,p_owner varchar2,p_table_space out NOCOPY varchar2,
p_initial_extent out NOCOPY number,p_next_extent out NOCOPY number,p_pct_free out NOCOPY number,p_pct_used out NOCOPY number,
p_pct_increase out NOCOPY number, p_max_extents out NOCOPY number,p_avg_row_len out NOCOPY number
) return boolean is
l_stmt varchar2(2000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  l_stmt:='select tablespace_name,initial_extent,next_extent,pct_free,pct_used,pct_increase,max_extents,'||
  'avg_row_len from '||
  'all_tables where table_name=:a and owner=:b';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||' using '||p_table||','||p_owner);
  end if;
  open cv for l_stmt using p_table,p_owner;
  fetch cv into p_table_space,p_initial_extent,p_next_extent,p_pct_free,p_pct_used,p_pct_increase,p_max_extents,
  p_avg_row_len;
  close cv;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function get_table_next_extent(p_table varchar2,p_owner varchar2,p_next_extent out NOCOPY number) return boolean is
l_stmt varchar2(2000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  l_stmt:='select next_extent from all_tables where table_name=:a and owner=:b';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||' using '||p_table||','||p_owner);
  end if;
  open cv for l_stmt using p_table,p_owner;
  fetch cv into p_next_extent;
  close cv;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function get_user_pk(p_table varchar2) return varchar2 is
l_stmt varchar2(2000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_pk varchar2(400);
Begin
  l_stmt:='select '||
  'pk_item.column_name  '||
  'from '||
  'edw_relations_md_v rel ,  '||
  'edw_unique_keys_md_v pk,  '||
  'edw_pvt_key_columns_md_v isu,   '||
  'edw_pvt_columns_md_v pk_item '||
  'where  '||
  'rel.relation_name=:a '||
  'and pk.entity_id=rel.relation_id '||
  'and pk.primarykey <> 1  '||
  'and isu.key_id=pk.key_id '||
  'and pk_item.column_id=isu.column_id '||
  'and pk_item.parent_object_id=rel.relation_id '||
  'and pk_item.data_type<>''NUMBER''';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||' using '||p_table);
  end if;
  open cv for l_stmt using p_table;
  fetch cv into l_pk;
  close cv;
  return l_pk;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return null;
End;

function is_column_in_table(p_table varchar2,p_column varchar2) return boolean is
Begin
  return is_column_in_table(p_table,p_column,null);
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;
function is_column_in_table(p_table varchar2,p_column varchar2,p_owner varchar2) return boolean is
l_stmt varchar2(2000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_res number;
l_table varchar2(200);
l_owner varchar2(200);
Begin
  l_table:=upper(p_table);
  l_owner:=upper(p_owner);
  if instr(p_table,'.')>0 then
    l_table:=substr(p_table,instr(p_table,'.')+1,length(p_table));
    if l_owner is null then
      l_owner:=substr(p_table,1,instr(p_table,'.')-1);
    end if;
  end if;
  if l_owner is null then
    l_owner:=get_table_owner(l_table);
  end if;
  if l_owner is not null then
    l_stmt:='select 1 from all_tab_columns where table_name=:a and column_name=:b and owner=:c';
    if g_debug then
      write_to_log_file_n(l_stmt||' '||l_table||' '||upper(p_column)||' '||l_owner);
    end if;
    open cv for l_stmt using l_table,upper(p_column),l_owner;
  else
    l_stmt:='select 1 from all_tab_columns,user_synonyms syn where all_tab_columns.table_name=:a '||
    'and column_name=:b and syn.table_name=all_tab_columns.table_name and syn.table_owner=all_tab_columns.owner';
    if g_debug then
      write_to_log_file_n(l_stmt||' '||l_table||' '||upper(p_column));
    end if;
    open cv for l_stmt using l_table,upper(p_column);
  end if;
  fetch cv into l_res;
  if l_res is null then
    return false;
  else
    return true;
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function get_table_space(p_owner varchar2) return varchar2 is
l_stmt varchar2(2000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_ts varchar2(200);
Begin
  l_stmt:='select default_tablespace from dba_users where username=:a';
  if g_debug then
    write_to_log_file_n(l_stmt||' using '||p_owner);
  end if;
  open cv for l_stmt using p_owner;
  fetch cv into l_ts;
  close cv;
  return l_ts;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return null;
End;

function index_present(p_table varchar2,p_owner varchar2,p_key varchar2,p_type varchar2) return boolean is
l_stmt varchar2(4000);
l_owner varchar2(400);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_var number;
Begin
  if g_debug then
    write_to_log_file_n('In index_present p_table='||p_table||',p_owner='||p_owner||',p_key='||
    p_key||',p_type='||p_type);
  end if;
  if p_owner is null then
    l_owner:=get_table_owner(p_table);
  else
    l_owner:=p_owner;
  end if;
  if p_type='UNIQUE' then
    l_stmt:='select 1 '||
    'from all_indexes a,all_ind_columns b '||
    'where '||
    'a.index_name=b.index_name '||
    'and a.owner=b.index_owner '||
    'and a.uniqueness=''UNIQUE'' '||
    'and a.table_name=:a '||
    'and a.table_owner=:b '||
    'and a.index_name in  '||
    '(select c.index_name from all_ind_columns c '||
    'where a.index_name=c.index_name '||
    'and a.owner=c.index_owner '||
    'and c.column_name=:c) '||
    'having count(*)=1 '||
    'group by b.index_name ';
  else
    l_stmt:='select 1 from all_ind_columns where table_name=:a and table_owner=:b and column_name=:c';
  end if;
  if g_debug then
    write_to_log_file_n(l_stmt||' using '||p_table||' '||l_owner||' '||p_key);
  end if;
  open cv for l_stmt using p_table,l_owner,p_key;
  fetch cv into l_var;
  close cv;
  if l_var is not null then
    return true;
  else
    return false;
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function get_mapping_details(
 p_mapping_id number
,p_hold_func out NOCOPY varcharTableType
,p_hold_func_category out NOCOPY varcharTableType
,p_hold_item out NOCOPY varcharTableType
,p_hold_item_id out NOCOPY numberTableType
,p_hold_item_usage out NOCOPY numberTableType
,p_hold_aggregatefunction out NOCOPY varcharTableType
,p_hold_is_distinct out NOCOPY numberTableType
,p_hold_relation out NOCOPY numberTableType
,p_hold_relation_name out NOCOPY varcharTableType
,p_hold_relation_usage out NOCOPY numberTableType
,p_hold_relation_type out NOCOPY varcharTableType
,p_hold_func_usage out NOCOPY numberTableType
,p_hold_func_position out NOCOPY numberTableType
,p_hold_func_dvalue out NOCOPY varcharTableType
,p_hold_number out NOCOPY number
,p_metedata_version varchar2
) return boolean is
l_stmt varchar2(10000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_metedata_version varchar2(80);
Begin
  l_metedata_version:=p_metedata_version;
  if l_metedata_version is null then
    l_metedata_version:=find_metadata_version;
  end if;
  if l_metedata_version='OWB 2.1.1' or l_metedata_version='OWB 3i' then
    l_stmt:='select '||
    'func_name,'||
    'category_name,'||
    'column_name,'||
    'column_id,'||
    'column_usage_id ,'||
    'aggregation,'||
    'is_distinct,'||
    'relation_id,'||
    'relation_name,'||
    'relation_usage_id,'||
    'relation_type,'||
    'func_usage_id,'||
    'attribute_position,'||
    'func_default_value '||
    'from   '||
    'edw_pvt_map_func_md_v map '||
    'where '||
    'map.mapping_id=:a ';
  else
    write_to_log_file_n('could not find right metadata type');
    return false;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt);
  end if;
  p_hold_number:=1;
  open cv for l_stmt using p_mapping_id;
  loop
    fetch cv into
        p_hold_func(p_hold_number),
        p_hold_func_category(p_hold_number),
        p_hold_item(p_hold_number),
        p_hold_item_id(p_hold_number),
        p_hold_item_usage(p_hold_number),
        p_hold_aggregatefunction(p_hold_number),
        p_hold_is_distinct(p_hold_number),
        p_hold_relation(p_hold_number),
        p_hold_relation_name(p_hold_number),
        p_hold_relation_usage(p_hold_number),
        p_hold_relation_type(p_hold_number),
        p_hold_func_usage(p_hold_number),
        p_hold_func_position(p_hold_number),
        p_hold_func_dvalue(p_hold_number);
    exit when cv%notfound;
    p_hold_number:=p_hold_number+1;
  end loop;
  p_hold_number:=p_hold_number-1;
  close cv;
  --for owb 9i, we have perf issues with edw_pvt_map_func_md_v. edw_pvt_map_func_md_v only contains
  --functions that are not copy.
  if l_metedata_version='OWB 3i' then
    l_stmt:='select '||
    '''COPY'' func_name, '||
    '''Basic'' category_name, '||
    'col.column_name column_name, '||
    'col.column_id, '||
    'map_col.target_column_usage_id column_usage_id , '||
    'null, '||
    'null, '||
    'rel.relation_id, '||
    'rel.relation_name, '||
    'map_col.target_usage_id relation_usage_id, '||
    'rel.relation_type, '||
    'map_col.func_usage_id, '||
    '1 attribute_position, '||
    'null '||
    'from '||
    '(select * from edw_pvt_map_columns_md_v where mapping_id=:1) map_col, '||
    'edw_relations_md rel, '||
    'edw_pvt_columns_md col, '||
    'edw_pvt_map_targets_md tgt '||
    'where '||
    'rel.relation_id=tgt.target_id '||
    'and tgt.mapping_id=map_col.mapping_id '||
    'and tgt.target_usage_id=map_col.target_usage_id '||
    'and col.column_id=map_col.target_column_id ';
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||' using '||p_mapping_id||get_time);
    end if;
    p_hold_number:=p_hold_number+1;
    open cv for l_stmt using p_mapping_id;
    loop
      fetch cv into
        p_hold_func(p_hold_number),
        p_hold_func_category(p_hold_number),
        p_hold_item(p_hold_number),
        p_hold_item_id(p_hold_number),
        p_hold_item_usage(p_hold_number),
        p_hold_aggregatefunction(p_hold_number),
        p_hold_is_distinct(p_hold_number),
        p_hold_relation(p_hold_number),
        p_hold_relation_name(p_hold_number),
        p_hold_relation_usage(p_hold_number),
        p_hold_relation_type(p_hold_number),
        p_hold_func_usage(p_hold_number),
        p_hold_func_position(p_hold_number),
        p_hold_func_dvalue(p_hold_number);
      exit when cv%notfound;
      p_hold_number:=p_hold_number+1;
    end loop;
    p_hold_number:=p_hold_number-1;
    close cv;
    l_stmt:='select '||
    '''COPY'' func_name, '||
    '''Basic'' category_name, '||
    'nvl(col.column_name,''NEXTVAL'') column_name, '||
    'col.column_id, '||
    'map_col.source_column_usage_id column_usage_id , '||
    'null, '||
    'null, '||
    'rel.relation_id, '||
    'rel.relation_name, '||
    'map_col.source_usage_id relation_usage_id, '||
    'rel.relation_type, '||
    'map_col.func_usage_id, '||
    '1 attribute_position, '||
    'null '||
    'from '||
    '(select * from edw_pvt_map_columns_md_v where mapping_id=:1) map_col, '||
    'edw_relations_md rel, '||
    'edw_pvt_columns_md col, '||
    'edw_pvt_map_sources_md src '||
    'where '||
    'rel.relation_id=src.source_id '||
    'and src.mapping_id=map_col.mapping_id '||
    'and src.source_usage_id=map_col.source_usage_id '||
    'and col.column_id(+)=map_col.source_column_id ';
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||' using '||p_mapping_id||get_time);
    end if;
    p_hold_number:=p_hold_number+1;
    open cv for l_stmt using p_mapping_id;
    loop
      fetch cv into
        p_hold_func(p_hold_number),
        p_hold_func_category(p_hold_number),
        p_hold_item(p_hold_number),
        p_hold_item_id(p_hold_number),
        p_hold_item_usage(p_hold_number),
        p_hold_aggregatefunction(p_hold_number),
        p_hold_is_distinct(p_hold_number),
        p_hold_relation(p_hold_number),
        p_hold_relation_name(p_hold_number),
        p_hold_relation_usage(p_hold_number),
        p_hold_relation_type(p_hold_number),
        p_hold_func_usage(p_hold_number),
        p_hold_func_position(p_hold_number),
        p_hold_func_dvalue(p_hold_number);
      exit when cv%notfound;
      p_hold_number:=p_hold_number+1;
    end loop;
    p_hold_number:=p_hold_number-1;
    close cv;
  end if;
  if g_debug then
    write_to_log_file_n('Dump from get_mapping_details');
    for i in 1..p_hold_number loop
      write_to_log_file(p_hold_func(i)||' '||p_hold_func_category(i)||' '||p_hold_item(i)||' '||
      p_hold_item_id(i)||' '||p_hold_item_usage(i)||' '||p_hold_aggregatefunction(i)||' '||
      p_hold_is_distinct(i)||' '||p_hold_relation(i)||' '||p_hold_relation_name(i)||' '||
      p_hold_relation_usage(i)||' '||p_hold_relation_type(i)||' '||p_hold_func_usage(i)||' '||
      p_hold_func_position(i)||' '||p_hold_func_dvalue(i));
    end loop;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function get_mapid_dim_in_derv_map(
p_dim varchar2,
p_mapid out NOCOPY numberTableType,
p_derv_fact_id out NOCOPY numberTableType,
p_src_fact_id out NOCOPY numberTableType,
p_number_mapid out NOCOPY number,
p_type varchar2) return boolean is
l_mapid  numberTableType;
l_derv_fact_id  numberTableType;
l_src_fact_id  numberTableType;
l_number_mapid  number;
l_stmt varchar2(1000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_is_name varchar2(40);
Begin
  p_number_mapid:=0;
  if p_type='INC' and g_read_cfig_options=false then
    l_stmt:='select '||
    'distinct map.mapping_id,  '||
    'tgt.fact_id,  '||
    'src.fact_id  '||
    'from  '||
    'edw_pvt_map_sources_md_v ru,  '||
    'edw_dimensions_md_v rel,  '||
    'edw_pvt_map_properties_md_v map,  '||
    'edw_facts_md_v src,  '||
    'edw_facts_md_v tgt,  '||
    'edw_attribute_sets_md_v sis  '||
    'where  '||
    'ru.mapping_id=map.mapping_id '||
    'and rel.dim_id=ru.source_id '||
    'and rel.dim_name=:a '||
    'and map.primary_source=src.fact_id '||
    'and map.primary_target=tgt.fact_id '||
    'and sis.attribute_group_name=''EDW_INC_REFRESH'' '||
    'and sis.entity_id=tgt.fact_id';
  else
    l_stmt:='select '||
    'distinct map.mapping_id,  '||
    'tgt.fact_id,  '||
    'src.fact_id  '||
    'from  '||
    'edw_pvt_map_sources_md_v ru,  '||
    'edw_dimensions_md_v rel,  '||
    'edw_pvt_map_properties_md_v map,  '||
    'edw_facts_md_v src,  '||
    'edw_facts_md_v tgt '||
    'where  '||
    'ru.mapping_id=map.mapping_id '||
    'and rel.dim_id=ru.source_id '||
    'and rel.dim_name=:a '||
    'and map.primary_source=src.fact_id '||
    'and map.primary_target=tgt.fact_id ';
  end if;
  l_number_mapid:=1;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||' using '||p_dim);
  end if;
  open cv for l_stmt using p_dim;
  loop
    fetch cv into l_mapid(l_number_mapid),l_derv_fact_id(l_number_mapid),l_src_fact_id(l_number_mapid);
    exit when cv%notfound;
    l_number_mapid:=l_number_mapid+1;
  end loop;
  l_number_mapid:=l_number_mapid-1;
  close cv;
  if p_type='INC' and g_read_cfig_options then
    for i in 1..l_number_mapid loop
      l_is_name:=null;
      if edw_option.get_warehouse_option(null,l_derv_fact_id(i),'INCREMENTAL',l_is_name)=false then
        null;
      end if;
      if l_is_name='Y' then
        p_number_mapid:=p_number_mapid+1;
        p_mapid(p_number_mapid):=l_mapid(i);
        p_derv_fact_id(p_number_mapid):=l_derv_fact_id(i);
        p_src_fact_id(p_number_mapid):=l_src_fact_id(i);
      end if;
    end loop;
  else
    p_mapid:=l_mapid;
    p_derv_fact_id:=l_derv_fact_id;
    p_src_fact_id:=l_src_fact_id;
    p_number_mapid:=l_number_mapid;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

/*
for a sumamry fact and dim, look at the fk and if its pointing to a higher level, get the pk_key of that level
from the dim table
*/
function get_dim_fk_summary_fact(
p_fact_id number,
p_dim_id number,
p_dim_fk out NOCOPY varcharTableType,
p_number_dim_fk out NOCOPY number
) return boolean is
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_stmt varchar2(4000);
Begin
  l_stmt:='select lvl.level_prefix||''_''||item.column_name '||
  'from  '||
  'edw_foreign_keys_md_v fk,  '||
  'edw_unique_keys_md_v pk,  '||
  'edw_dimensions_md_v dim,  '||
  'edw_levels_md_v lvl,  '||
  'edw_tables_md_v ltc,  '||
  'edw_unique_keys_md_v ltc_pk,  '||
  'edw_pvt_columns_md_v item,  '||
  'edw_pvt_key_columns_md_v isu '||
  'where  '||
  'fk.entity_id=:a  '||
  'and fk.key_id=pk.key_id '||
  'and dim.dim_id=pk.entity_id '||
  'and dim.dim_id=:b  '||
  'and lvl.dim_id=dim.dim_id '||
  'and lvl.level_prefix=substr(fk.foreign_key_name,instr(fk.foreign_key_name,''_'',-1)+1,length(fk.foreign_key_name)) '||
  'and ltc.name=lvl.level_name||''_LTC'' '||
  'and ltc_pk.entity_id=ltc.elementid '||
  'and isu.key_id=ltc_pk.key_id '||
  'and isu.column_id=item.column_id '||
  'and item.parent_object_id=ltc.elementid '||
  'and item.data_type=''NUMBER''';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||' using '||p_fact_id||','||p_dim_id);
  end if;
  p_number_dim_fk:=1;
  open cv for l_stmt using p_fact_id,p_dim_id;
  loop
    fetch cv into p_dim_fk(p_number_dim_fk);
    exit when cv%notfound;
    p_number_dim_fk:=p_number_dim_fk+1;
  end loop;
  p_number_dim_fk:=p_number_dim_fk-1;
  close cv;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function get_object_name(p_object_id number) return varchar2 is
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_stmt varchar2(1000);
l_name varchar2(400);
Begin
  l_stmt:='select relation_name from edw_relations_md_v where relation_id=:a';
  open cv for l_stmt using p_object_id;
  fetch cv into l_name;
  close cv;
  return l_name;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return null;
End;

function inc_g_load_pk return number is
l_stmt varchar2(400);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_load_pk number;
Begin
  l_stmt:='select edw_load_s.nextval from dual';
  open cv for l_stmt;
  fetch cv into l_load_pk;
  close cv;
  return l_load_pk;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return null;
End;

function get_column_stats(
p_owner varchar2,
p_object varchar2,
p_fk varchar2,
p_distcnt out NOCOPY number,
p_density out NOCOPY number,
p_nullcnt out NOCOPY number,
p_srec out NOCOPY DBMS_STATS.StatRec,
p_avgclen out NOCOPY number
) return boolean is
Begin
  DBMS_STATS.GET_COLUMN_STATS (
    p_owner,
    p_object,
    p_fk,
    NULL,
    NULL,
    NULL,
    p_distcnt,
    p_density,
    p_nullcnt,
    p_srec,
    p_avgclen,
    NULL);
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function get_table_stats(
p_owner varchar2,
p_object varchar2,
p_numrows out NOCOPY number,
p_numblks out NOCOPY number,
p_avgrlen out NOCOPY number
) return boolean is
Begin
 if g_debug then
   write_to_log_file_n('call DBMS_STATS.GET_TABLE_STATS with '||p_owner||','||p_object);
 end if;
 DBMS_STATS.GET_TABLE_STATS(
   p_owner,
   p_object,
   NULL,
   NULL,
   NULL,
   p_numrows,
   p_numblks,
   p_avgrlen,
   NULL);
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function get_fk_pk(p_child number,p_parent number,p_map_id number,
p_fk out NOCOPY varcharTableType,p_pk out NOCOPY varcharTableType,
p_number_fk out NOCOPY number) return boolean is
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_stmt varchar2(8000);
Begin
  if p_map_id is not null then
    l_stmt:='select pk_item.column_name, fk_item.column_name '||
    'from  '||
    'edw_pvt_map_properties_md_v map, '||
    'edw_pvt_map_sources_md_v map_sources_dim, '||
    'edw_pvt_map_sources_md_v map_sources_fact, '||
    'edw_pvt_map_key_usages_md_v map_key_usage, '||
    'edw_pvt_key_columns_md_v fk_key_column, '||
    'edw_pvt_columns_md_v fk_item, '||
    'edw_pvt_key_columns_md_v pk_key_column, '||
    'edw_pvt_columns_md_v pk_item '||
    'where '||
    'map_sources_dim.source_id=:a '||
    'and map_sources_fact.source_id=:b '||
    'and map.mapping_id=:c     '||
    'and map_sources_dim.mapping_id=map.mapping_id '||
    'and map_sources_fact.mapping_id=map.mapping_id '||
    'and map_key_usage.source_usage_id=map_sources_fact.source_usage_id '||
    'and map_key_usage.mapping_id=map.mapping_id '||
    'and fk_key_column.key_id=map_key_usage.foreign_key_id '||
    'and fk_item.column_id=fk_key_column.column_id '||
    'and fk_item.parent_object_id=map_sources_fact.source_id '||
    'and pk_key_column.key_id=map_key_usage.unique_key_id '||
    'and pk_item.column_id=pk_key_column.column_id '||
    'and pk_item.parent_object_id=map_sources_dim.source_id ';
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||' using '||p_parent||','||p_child||','||p_map_id);
    end if;
    open cv for l_stmt using p_parent,p_child,p_map_id;
  else
    l_stmt:='select pk_item.column_name,fk_item.column_name '||
    'from  '||
    'edw_foreign_keys_md_v fk, '||
    'edw_unique_keys_md_v pk, '||
    'edw_pvt_key_columns_md_v fk_use, '||
    'edw_pvt_key_columns_md_v pk_use, '||
    'edw_pvt_columns_md_v fk_item, '||
    'edw_pvt_columns_md_v pk_item '||
    'where  '||
    '    pk.entity_id=:a  '||
    'and fk.entity_id=:b  '||
    'and fk_use.key_id=fk.foreign_key_id '||
    'and fk_item.column_id=fk_use.column_id '||
    'and fk_item.parent_object_id=fk.entity_id '||
    'and pk.key_id=fk.key_id '||
    'and pk_use.key_id=pk.key_id '||
    'and pk_item.column_id=pk_use.column_id '||
    'and pk_item.parent_object_id=pk.entity_id ';
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||' using '||p_parent||','||p_child);
    end if;
    open cv for l_stmt using p_parent,p_child;
  end if;
  p_number_fk:=1;
  loop
    fetch cv into p_pk(p_number_fk),p_fk(p_number_fk);
    exit when cv%notfound;
    p_number_fk:=p_number_fk+1;
  end loop;
  p_number_fk:=p_number_fk-1;
  close cv;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  p_number_fk:=0;
  return false;
End;

function create_prot_table(p_table varchar2,p_op_table_space varchar2) return boolean is
l_stmt varchar2(1000);
Begin
  if drop_table(p_table)=false then
    null;
  end if;
  if p_op_table_space is not null then
    l_stmt:='create table '||p_table||'(row_id rowid) tablespace '||p_op_table_space;
  else
    l_stmt:='create table '||p_table||'(row_id rowid)';
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt);
  end if;
  execute immediate l_stmt;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

function drop_prot_table(p_table varchar2) return boolean is
l_stmt varchar2(1000);
Begin
  if drop_table(p_table)=false then
    null;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

function get_all_maps_for_tgt(p_object_id number,p_maps out NOCOPY numberTableType,p_number_maps out NOCOPY number)
return boolean is
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_stmt varchar2(1000);
Begin
  l_stmt:='select mapping_id from edw_pvt_map_properties_md_v where primary_target=:a';
  open cv for l_stmt using p_object_id;
  p_number_maps:=1;
  loop
    fetch cv into p_maps(p_number_maps);
    exit when cv%notfound;
    p_number_maps:=p_number_maps+1;
  end loop;
  close cv;
  p_number_maps:=p_number_maps-1;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

function create_table(p_table varchar2,p_stmt varchar2,p_count out NOCOPY number) return boolean is
Begin
  p_count:=0;
  if drop_table(p_table) = false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||p_stmt||get_time);
  end if;
  execute immediate p_stmt;
  p_count:=sql%rowcount;
  if g_debug then
    write_to_log_file_n('Created '||p_table||' with '||p_count||' rows '||get_time);
  end if;
  analyze_table_stats(substr(p_table,instr(p_table,'.')+1,
  length(p_table)),substr(p_table,1,instr(p_table,'.')-1));
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function is_itemset_implemented(p_object_name varchar2,
p_item_set varchar2) return varchar2 is
Begin
  return is_itemset_implemented(p_object_name,p_item_set,null);
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return null;
End;
function is_itemset_implemented(p_object_name varchar2,p_item_set varchar2,p_object_id number) return varchar2 is
l_stmt varchar2(2000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_res number:=null;
Begin
  if g_debug then
    write_to_log_file_n('In is_itemset_implemented '||p_object_name||' '||p_item_set||' '||p_object_id);
  end if;
  if p_object_id is null then
    l_stmt:='select 1 from edw_relations_md_v rel,edw_attribute_sets_md_v sis where sis.attribute_group_name=:a '||
          ' and sis.entity_id=rel.relation_id and rel.relation_name=:b';
  else
    l_stmt:='select 1 from edw_attribute_sets_md_v sis where sis.attribute_group_name=:a and sis.entity_id=:b';
  end if;
  --if g_debug then
    --write_to_log_file_n('Going to execute '||l_stmt);
  --end if;
  if p_object_id is null then
    open cv for l_stmt using p_item_set,p_object_name;
  else
    open cv for l_stmt using p_item_set,p_object_id;
  end if;
  fetch cv into l_res;
  close cv;
  if l_res is null then
    if g_debug then
      write_to_log_file('Itemset not implemented');
    end if;
    return 'N';
  else
    if g_debug then
      write_to_log_file('Itemset implemented');
    end if;
    return 'Y';
  end if;
  return 'N';
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return null;
End;

function get_DA_table(p_object varchar2) return varchar2 is
Begin
  return get_DA_table(p_object,null);
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return null;
End;
function get_DA_table(p_object varchar2,p_owner varchar2) return varchar2 is
l_table varchar2(200);
Begin
  l_table:=p_object||'DA';
  if check_table(l_table)=false then
    if p_owner is null then
      l_table:=get_table_owner(p_object)||'.'||p_object||'DA';
    else
      l_table:=p_owner||'.'||p_object||'DA';
    end if;
  end if;
  return l_table;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return null;
End;

function get_PP_table(p_object varchar2) return varchar2 is
Begin
  return get_PP_table(p_object,null);
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return null;
End;
function get_PP_table(p_object varchar2,p_owner varchar2) return varchar2 is
l_table varchar2(200);
Begin
  l_table:=p_object||'PP';
  if check_table(l_table)=false then
    if p_owner is null then
      l_table:=get_table_owner(p_object)||'.'||p_object||'PP';
    else
      l_table:=p_owner||'.'||p_object||'PP';
    end if;
  end if;
  return l_table;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return null;
End;

function get_master_instance(p_object_name varchar2) return varchar2 is
l_master varchar2(400):=null;
l_stmt  varchar2(2000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_res number:=null;
Begin
  if g_read_cfig_options then
    if edw_option.get_warehouse_option(p_object_name,null,'MASTER_INSTANCE',l_master)=false then
      null;
    end if;
  else
    l_stmt:='select instr(lower(description),''master instance'') from edw_relations_md_v where relation_name=:a';
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||' using '||p_object_name||get_time);
    end if;
    open cv for l_stmt using p_object_name;
    fetch cv into l_res;
    close cv;
    if l_res =0 then
      return null;
    end if;
    l_stmt:='select rtrim(ltrim(substr(upper(description),instr(lower(description),''master instance'')+16,'||
    'length(description)))) from edw_relations_md_v where relation_name=:a';
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||' using '||p_object_name||get_time);
    end if;
    open cv for l_stmt using p_object_name;
    fetch cv into l_master;
    close cv;
  end if;
  if g_debug then
    write_to_log_file('Result '||l_master);
  end if;
  return l_master;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return null;
End;

function log_into_cdi_results_table(
p_object varchar2
,p_object_type  varchar2
,p_object_id number
,p_interface_table varchar2
,p_interface_table_id number
,p_interface_table_pk varchar2
,p_interface_table_pk_id number
,p_interface_table_fk varchar2
,p_interface_table_fk_id number
,p_parent_table varchar2
,p_parent_table_id number
,p_parent_table_pk varchar2
,p_parent_table_pk_id number
,p_number_dangling number
,p_number_duplicate number
,p_number_error number
,p_total_records number
,p_error_type varchar2) return boolean is
l_stmt varchar2(4000);
Begin
  l_stmt:='insert into EDW_CDI_RESULTS('||
    'OBJECT_NAME '||
   ',OBJECT_ID   '||
   ',OBJECT_TYPE '||
   ',INTERFACE_TABLE '||
   ',INTERFACE_TABLE_ID '||
   ',INTERFACE_TABLE_PK '||
   ',INTERFACE_TABLE_PK_ID '||
   ',INTERFACE_TABLE_FK '||
   ',INTERFACE_TABLE_FK_ID '||
   ',PARENT_TABLE  '||
   ',PARENT_TABLE_ID '||
   ',PARENT_TABLE_PK '||
   ',PARENT_TABLE_PK_ID '||
   ',NUMBER_DANGLING '||
   ',NUMBER_DUPLICATE '||
   ',NUMBER_ERROR   '||
   ',TOTAL_RECORDS   '||
   ',ERROR_TYPE      '||
   ',CREATED_BY      '||
   ',LAST_UPDATE_BY  '||
   ',LAST_UPDATE_LOGIN '||
   ',CREATION_DATE     '||
   ',LAST_UPDATE_DATE) '||
   'values (:a1,:a2,:a3,:a4,:a5,:a6,:a7,:a8,:a9,:a10,:a11,:a12,:a13,:a14,:a15,:a16,:a17,:a18,:a19,:a20,'||
   ':a21,:a22,:a23)';
   if g_debug then
     write_to_log_file_n('Going to execute '||l_stmt||' Using ');
     write_to_log_file(p_object||','||p_object_id||','||p_object_type||','||p_interface_table||','||
     p_interface_table_id||','||p_interface_table_pk||','||p_interface_table_pk_id||','||
     p_interface_table_fk||','||p_interface_table_fk_id||','||p_parent_table||','||
     p_parent_table_id||','||p_parent_table_pk||','||p_parent_table_pk_id||','||p_number_dangling||','||
     p_number_duplicate||','||p_number_error||','||p_total_records||','||p_error_type||','||g_conc_program_id||','||
     g_conc_program_id||','||g_conc_program_id||','||sysdate||','||sysdate);
   end if;
   execute immediate l_stmt using p_object,p_object_id,p_object_type,p_interface_table,
   p_interface_table_id,p_interface_table_pk,p_interface_table_pk_id,p_interface_table_fk,p_interface_table_fk_id,
   p_parent_table,p_parent_table_id,p_parent_table_pk,p_parent_table_pk_id,p_number_dangling,p_number_duplicate,
   p_number_error,p_total_records,p_error_type,g_conc_program_id,g_conc_program_id,g_conc_program_id,sysdate,sysdate;
   commit;
  return true;
Exception when others then
 write_to_log_file_n('Error in log_into_cdi_results_table '||sqlerrm);
 return false;
End;

function log_into_cdi_dang_table(p_key_id number,p_table_id number,p_parent_table_id number,
p_key_value varchar2,p_number_key_value number,p_instance varchar2,p_bad_key varchar2) return boolean is
l_stmt varchar2(4000);
Begin
  l_stmt:='insert into edw_cdi_key_values (key_id,table_id,parent_table_id,instance,key_value,number_key_value,'||
  'bad_key) values(:a1,:a2,:a3,:a4,:a5,:a6,:a7)';
  execute immediate l_stmt using p_key_id,p_table_id,p_parent_table_id,p_instance,p_key_value,p_number_key_value,
  p_bad_key;
  return true;
Exception when others then
 write_to_log_file_n('Error in log_into_cdi_dang_table '||sqlerrm);
 return false;
End;

function get_column_id(p_column varchar2,p_table varchar2) return number is
l_stmt  varchar2(2000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_res number:=null;
Begin
  l_stmt:='select item.column_id from edw_pvt_columns_md_v item, edw_relations_md_v rel where rel.relation_name=:a '||
  'and item.column_name=:b and item.parent_object_id=rel.relation_id and item.parent_object_id=rel.relation_id';
  open cv for l_stmt using p_table,p_column;
  fetch cv into l_res;
  close cv;
  return l_res;
Exception when others then
 write_to_log_file_n('Error in get_column_id '||sqlerrm);
 return null;
End;

function get_instance_col(p_table varchar2) return varchar2 is
l_stmt  varchar2(2000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_res varchar2(200);
Begin
  l_stmt:='select fk_item.column_name from  edw_relations_md_v rel, edw_foreign_keys_md_v fk, '||
  'edw_pvt_key_columns_md_v fkisu,edw_pvt_columns_md_v fk_item,edw_dimensions_md_v p_rel,edw_unique_keys_md_v pk '||
  'where rel.relation_name=:a and fk.entity_id=rel.relation_id and fkisu.key_id=fk.foreign_key_id '||
  'and fk_item.column_id=fkisu.column_id and fk_item.parent_object_id=rel.relation_id and pk.key_id=fk.key_id and '||
  'p_rel.dim_id=pk.entity_id and p_rel.dim_name=''EDW_INSTANCE_M''';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||' using '||p_table);
  end if;
  open cv for l_stmt using p_table;
  fetch cv into l_res;
  close cv;
  if l_res is null then
    l_stmt:='select item.column_name from edw_pvt_columns_md_v item, edw_relations_md_v rel where '||
    'item.parent_object_id=rel.relation_id and rel.relation_name=:a and item.column_name '||
    'in (''INSTANCE'',''INSTANCE_CODE'') and item.parent_object_id=rel.relation_id';
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||' using '||p_table);
    end if;
    open cv for l_stmt using p_table;
    fetch cv into l_res;
    close cv;
  end if;
  return l_res;
Exception when others then
 write_to_log_file_n('Error in get_instance_col '||sqlerrm);
 return null;
End;

function create_synonym(p_synonym varchar2,p_table varchar2) return boolean is
l_stmt varchar2(4000);
Begin
  l_stmt:='drop synonym '||p_synonym;
  begin
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt);
    end if;
    execute immediate l_stmt;
  exception when others then
    write_to_log_file_n('Synonym '||p_synonym||' does not exist');
  end;
  l_stmt:='create synonym '||p_synonym||' for '||p_table;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt);
  end if;
  execute immediate l_stmt;
  return true;
Exception when others then
 write_to_log_file_n('Error in create_synonym '||sqlerrm);
 return false;
End;

procedure create_bad_key_table(p_table varchar2,p_op_table_space varchar2,p_wh_parallel number) is
l_stmt varchar2(4000);
Begin
  l_stmt:='create table '||p_table||'(key_value varchar2(800)) '; --tablespace '||p_op_table_space;
  if p_wh_parallel is not null then
    l_stmt:=l_stmt||' parallel degree('||p_wh_parallel||') ';
  end if;
  l_stmt:=l_stmt||' tablespace '||p_op_table_space;
  if drop_table(p_table)=false then
    null;
  end if;
  g_status_message:=sqlerrm;
  execute immediate l_stmt;
Exception when others then
  g_status:=false;
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
End;

function is_src_of_custom_inc_derv_fact(p_fact varchar2) return number is
l_stmt varchar2(10000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_var number:=null;
Begin
  if g_debug then
    write_to_log_file_n('In is_src_of_custom_inc_derv_fact, input param='||p_fact);
  end if;
  l_stmt:='select 1 from edw_facts_md_v df, edw_facts_md_v fact, '||
           'edw_pvt_map_properties_md_v map, edw_attribute_sets_md_v sis  '||
           'where fact.fact_name=:a and map.primary_source=fact.fact_id and df.fact_id=map.primary_target '||
           'and sis.entity_id=df.fact_id and sis.attribute_group_name=''EDW_CUSTOM_INC_REFRESH''';
  open cv for l_stmt using p_fact;
  fetch cv into l_var;
  close cv;
  if l_var = 1 then
    return 1;
  else
    return 0;
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in  is_src_of_custom_inc_derv_fact '||sqlerrm||' '||get_time);
  return -1;
End;

function get_pk_view(p_dim varchar2,p_db_link varchar2) return varchar2 is
l_view varcharTableType;
l_number_view number;
l_stmt varchar2(4000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_res number;
l_pkg varchar2(1000);
Begin
  l_stmt:='select vw.view_name '||
  'from  '||
  'edw_pvt_md_views_v vw,  '||
  'edw_dimensions_md_v dim,  '||
  'edw_foreign_keys_md_v fk,  '||
  'edw_unique_keys_md_v pk  '||
  'where fk.entity_id=vw.view_id '||
  'and pk.entity_id=dim.dim_id '||
  'and fk.key_id=pk.key_id '||
  'and instr(fk.foreign_key_name,''_PK_VIEW'')<>0  '||
  'and dim.dim_name=:a ';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||' using '||p_dim);
  end if;
  l_number_view:=1;
  open cv for l_stmt using p_dim;
  loop
    fetch cv into l_view(l_number_view);
    exit when cv%notfound;
    l_number_view:=l_number_view+1;
  end loop;
  close cv;
  l_number_view:=l_number_view-1;
  if g_debug then
    write_to_log_file_n('Result');
    for i in 1..l_number_view loop
      write_to_log_file(l_view(i));
    end loop;
  end if;
  --see if a package exists
  /*for i in 1..l_number_view loop
    l_pkg:=l_view(i)||'_PKG.CREATE_PK_VIEW@'||p_db_link;
    l_stmt:='select '||l_pkg||' from dual';
    begin
      if g_debug then
        write_to_log_file_n('Going to execute '||l_stmt);
      end if;
      open cv for l_stmt;
      fetch cv into l_res;
      close cv;
      if l_res=-1 then
        g_status_message:=sqlerrm;
        g_status:=false;
        write_to_log_file_n(g_status_message);
        return null;
      end if;
      return l_view(i);
    exception when others then
      if g_debug then
        write_to_log_file_n('Package not found');
      end if;
    end;
  end loop;*/
  for i in 1..l_number_view loop
    l_stmt:='select 1 from '||l_view(i)||'@'||p_db_link||' where rownum=1';
    begin
      if g_debug then
        write_to_log_file_n('Going to execute '||l_stmt);
      end if;
      execute immediate l_stmt;
      return l_view(i);
    exception when others then
      if g_debug then
        write_to_log_file_n('View not found');
      end if;
    end;
  end loop;
  return null;
Exception when others then
  g_status:=false;
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return null;
End;

function get_logical_name(p_obj_id number) return varchar2 is
l_name varchar2(400);
l_stmt varchar2(2000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  l_stmt:='select relation_long_name from edw_relations_md_v where relation_id=:a';
  open cv for l_stmt using p_obj_id;
  fetch cv into l_name;
  close cv;
  return l_name;
Exception when others then
  g_status:=false;
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return null;
End;

function parse_names(p_list varchar2,p_names out NOCOPY varcharTableType,p_number_names out NOCOPY number)
return boolean is
Begin
  if parse_names(p_list,',',p_names,p_number_names)=false then
    return false;
  end if;
  return true;
Exception when others then
 write_to_conc_log_file('Error in parse_names '||sqlerrm);
 return false;
End;

function parse_names(
p_list varchar2,
p_separator varchar2,
p_names out NOCOPY varcharTableType,
p_number_names out NOCOPY number)
return boolean is
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
 write_to_conc_log_file('Error in parse_names '||sqlerrm);
 return false;
End;

function get_status_message return varchar2 is
Begin
  return g_status_message;
Exception when others then
 write_to_log_file_n('Error in get_status_message '||sqlerrm);
 return null;
End;

procedure set_rollback(p_rollback varchar2) is
Begin
  if p_rollback is not null then
    execute immediate 'SET TRANSACTION USE ROLLBACK SEGMENT '||p_rollback;
  end if;
Exception when others then
  write_to_log_file_n('Error in set_rollback '||sqlerrm);
End;

function get_ltc_fact_unique_key(p_object_id number,p_object_name varchar2,
p_unique_key out NOCOPY varchar2,p_pk_key out NOCOPY varchar2) return boolean is
l_stmt varchar2(10000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_object_id number;
l_uk varchar2(400);
l_pk varchar2(400);
l_mapping_id number;
Begin
  l_object_id:=p_object_id;
  if l_object_id is null then
    l_object_id:=get_object_id(p_object_name);
  end if;
  l_mapping_id:=get_target_map(l_object_id,null);
  l_stmt:='select '||
  'tgt_column.column_name '||
  'from '||
  'edw_pvt_map_properties_md_v map_properties, '||
  'edw_pvt_map_sources_md_v map_sources, '||
  'edw_pvt_map_targets_md_v map_targets, '||
  'edw_tables_md_v src_table, '||
  'edw_relations_md_v tgt_relation, '||
  'edw_unique_keys_md_v pk, '||
  'edw_pvt_key_columns_md_v key_usage, '||
  'edw_pvt_columns_md_v pk_col, '||
  '(select * from edw_pvt_map_columns_md_v where mapping_id=:1) map_columns, '||
  'edw_pvt_columns_md_v tgt_column '||
  'where '||
  '  map_sources.source_id=map_properties.primary_source '||
  'and map_targets.target_id=map_properties.primary_target '||
  'and map_properties.mapping_id=:a '||
  'and map_sources.mapping_id=map_properties.mapping_id '||
  'and src_table.elementid=map_sources.source_id '||
  'and map_targets.mapping_id=map_properties.mapping_id '||
  'and tgt_relation.relation_id=map_targets.target_id '||
  'and pk.entity_id=map_properties.primary_source '||
  'and key_usage.key_id=pk.key_id '||
  'and pk_col.column_id=key_usage.column_id '||
  'and pk_col.parent_object_id=src_table.elementid '||
  'and map_columns.mapping_id=map_properties.mapping_id '||
  'and map_columns.Source_usage_id=map_sources.source_usage_id '||
  'and map_columns.Source_column_id=pk_col.column_id '||
  'and map_columns.Target_column_id=tgt_column.column_id '||
  'and tgt_column.parent_object_id=tgt_relation.relation_id ';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||' using '||l_mapping_id);
  end if;
  open cv for l_stmt using l_mapping_id,l_mapping_id;
  fetch cv into l_uk;
  close cv;
  l_pk:=l_uk||'_KEY';
  p_unique_key:=l_uk;
  p_pk_key:=l_pk;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

function get_col_col_in_map(
p_map_id number,
p_object varchar2,
p_src_tables out NOCOPY varcharTableType,
p_src_cols out NOCOPY varcharTableType,
p_tgt_tables out NOCOPY varcharTableType,
p_tgt_cols out NOCOPY varcharTableType,
p_number_cols out NOCOPY number) return boolean is
l_stmt varchar2(10000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_map_id number;
Begin
  l_map_id:=p_map_id;
  if p_map_id is null then
    l_stmt:='select map.mapping_id '||
    'from edw_pvt_map_properties_md_v map, '||
    'edw_relations_md_v rel '||
    'where rel.relation_name=:a '||
    'and map.primary_target=rel.relation_id ';
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||' using '||p_object);
    end if;
    open cv for l_stmt using p_object;
    fetch cv into l_map_id;
    close cv;
  end if;
  l_stmt:='select '||
	'src.relation_name, '||
	'src_col.column_name, '||
	'tgt.relation_name, '||
	'tgt_col.column_name '||
	'from '||
    'edw_relations_md_v src, '||
    'edw_relations_md_v tgt, '||
    'edw_pvt_columns_md_v src_col, '||
    'edw_pvt_columns_md_v tgt_col, '||
    'edw_pvt_map_properties_md_v map, '||
    'edw_pvt_map_sources_md_v map_source, '||
    '(select * from edw_pvt_map_columns_md_v where mapping_id=:1) map_columns '||
    'where '||
    'map.mapping_id=:a '||
    'and map_source.mapping_id=map.mapping_id '||
    'and map_columns.mapping_id=map.mapping_id '||
    'and map_source.source_id=src.relation_id '||
    'and map_columns.source_usage_id=map_source.source_usage_id '||
    'and map.primary_target=tgt.relation_id '||
    'and src_col.column_id=map_columns.Source_column_id '||
    'and tgt_col.column_id=map_columns.target_column_id '||
    'and src_col.parent_object_id=src.relation_id '||
    'and tgt_col.parent_object_id=tgt.relation_id ';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||' using '||l_map_id);
  end if;
  p_number_cols:=1;
  open cv for l_stmt using l_map_id,l_map_id;
  loop
    fetch cv into p_src_tables(p_number_cols),p_src_cols(p_number_cols),
    p_tgt_tables(p_number_cols),p_tgt_cols(p_number_cols);
    exit when cv%notfound;
    p_number_cols:=p_number_cols+1;
  end loop;
  p_number_cols:=p_number_cols-1;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

--given a tgt, what are the fks used in the map
function get_fks_in_map(p_tgt varchar2,p_src out NOCOPY varcharTableType,
p_fk out NOCOPY varcharTableType,p_number_src out NOCOPY number) return boolean is
l_stmt varchar2(4000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  l_stmt:='select '||
  'ltc.relation_name, '||
  'fk_item.column_name  '||
  'from  '||
  'edw_pvt_map_sources_md_v        ltc_ru,  '||
  'edw_relations_md_v               ltc,  '||
  'edw_pvt_map_key_usages_md_v      fk_usage, '||
  'edw_pvt_key_columns_md_v         fk_isu,  '||
  'edw_pvt_columns_md_v                   fk_item,  '||
  'edw_pvt_map_properties_md_v        map,  '||
  'edw_relations_md_v               tgt  '||
  'where  '||
  'tgt.relation_name=:a '||
  'and map.primary_target=tgt.relation_id '||
  'and ltc_ru.mapping_id=map.mapping_id '||
  'and ltc.relation_id=ltc_ru.source_id  '||
  'and fk_usage.source_usage_id=ltc_ru.source_usage_id '||
  'and fk_usage.mapping_id=map.mapping_id '||
  'and fk_isu.key_id=fk_usage.foreign_key_id '||
  'and fk_item.column_id=fk_isu.column_id '||
  'and fk_item.parent_object_id=ltc_ru.source_id';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||' using '||p_tgt);
  end if;
  p_number_src:=1;
  open cv for l_stmt using p_tgt;
  loop
    fetch cv into p_src(p_number_src),p_fk(p_number_src);
    exit when cv%notfound;
    p_number_src:=p_number_src+1;
  end loop;
  p_number_src:=p_number_src-1;
  close cv;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

--given a tgt, what are the fks used in the dim
function get_fks_in_dim(p_tgt varchar2,p_src out NOCOPY varcharTableType,
p_fk out NOCOPY varcharTableType,p_number_src out NOCOPY number) return boolean is
l_stmt varchar2(4000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  l_stmt:='select '||
  'rel.name,  '||
  'fk_item.column_name  '||
  'from  '||
  'edw_tables_md_v rel,  '||
  'edw_foreign_keys_md_v fk, '||
  'edw_pvt_key_columns_md_v fkisu,  '||
  'edw_pvt_columns_md_v fk_item,  '||
  'edw_dimensions_md_v dim,  '||
  'edw_levels_md_v lvl  '||
  'where  '||
  'dim.dim_name=:a  '||
  'and lvl.dim_id=dim.dim_id '||
  'and rel.name=lvl.level_name||''_LTC'' '||
  'and fk.entity_id=rel.elementid '||
  'and fkisu.key_id=fk.foreign_key_id '||
  'and fk_item.column_id=fkisu.column_id '||
  'and fk_item.parent_object_id=rel.elementid';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||' using '||p_tgt);
  end if;
  p_number_src:=1;
  open cv for l_stmt using p_tgt;
  loop
    fetch cv into p_src(p_number_src),p_fk(p_number_src);
    exit when cv%notfound;
    p_number_src:=p_number_src+1;
  end loop;
  p_number_src:=p_number_src-1;
  close cv;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

function get_app_version(p_instance varchar2) return varchar2 is
Begin
  return get_app_version(p_instance,null);
Exception when others then
  g_status_message:=sqlerrm;
  write_to_conc_log_file(g_status_message);
  g_status:=false;
  return null;
End;
function get_app_version(p_instance varchar2,p_db_link varchar2) return varchar2 is
l_stmt varchar2(4000);
l_db_link varchar2(1000);
l_release_name varchar2(200);
l_version_name varchar2(200);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  l_db_link:=p_db_link;
  if l_db_link is null and p_instance is not null then
    l_db_link:=get_db_link_for_instance(p_instance);
  end if;
  if l_db_link is null then
    l_stmt:='select release_name from fnd_product_groups';
  else
    l_stmt:='select release_name from fnd_product_groups@'||l_db_link;
  end if;
  if g_debug then
    write_to_conc_log_file(l_stmt);
  end if;
  open cv for l_stmt;
  fetch cv into l_release_name;
  close cv;
  l_version_name:=substr(l_release_name,1,instr(l_release_name,'.')+1);
  g_oracle_apps_version:=l_release_name;
  write_to_conc_log_file('l_release_name='||l_release_name);
  write_to_conc_log_file('l_version_name='||l_version_name);
  return l_version_name;
Exception when others then
  write_to_conc_log_file(g_status_message);
  return null;
End;

function check_table_column(p_table varchar2,p_col varchar2) return boolean is
l_stmt varchar2(1000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  if g_debug then
    write_to_log_file_n('Check column '||p_col||' in '||p_table);
  end if;
  begin
    l_stmt:='select '||p_col||' from '||p_table||' where rownum=1';
    open cv for l_stmt;
  exception when others then
    if g_debug then
      write_to_log_file('Not Found');
    end if;
    return false;
  end;
  if g_debug then
    write_to_log_file('Yes Found');
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

function check_table_column(p_table varchar2,p_owner varchar2,p_col varchar2) return boolean is
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_var number;
l_owner varchar2(80);
Begin
  if g_debug then
    write_to_log_file_n('Check column '||p_col||' in '||p_table);
  end if;
  l_owner:=p_owner;
  if l_owner is null then
    l_owner:=get_table_owner(p_table);
  end if;
  g_stmt:='select 1 from all_tab_columns where table_name=:1 and owner=:2 and column_name=:3';
  if g_debug then
    write_to_log_file_n(g_stmt||' '||p_table||' '||l_owner||' '||p_col);
  end if;
  open cv for g_stmt using p_table,l_owner,p_col;
  fetch cv into l_var;
  close cv;
  if l_var=1 then
    return true;
  else
    return false;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

function add_column_to_table(p_table varchar2,p_owner varchar2,p_col varchar2,p_datatype varchar2) return boolean is
l_stmt varchar2(1000);
l_owner varchar2(400);
Begin
  l_owner:=p_owner;
  if l_owner is null then
    l_owner:=get_table_owner(p_table);
  end if;
  l_stmt:='alter table '||l_owner||'.'||p_table||' add('||p_col||' '||p_datatype||')';
  if g_debug then
    write_to_log_file_n(l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

function check_pk_pkkey_index(p_table varchar2,p_owner varchar2,p_pk varchar2,p_pk_key varchar2) return boolean is
l_owner varchar2(200);
index_found boolean:=false;
l_index varcharTableType;
l_ind_col varcharTableType;
l_ind_col_pos numberTableType;
l_number_index number;
Begin
  l_owner:=p_owner;
  if l_owner is null then
    l_owner:=get_table_owner(p_table);
  end if;
  l_number_index:=0;
  index_found:=false;
  if g_debug then
    write_to_log_file_n('Check index for '||l_owner||'.'||p_table||'('||p_pk||','||p_pk_key||')');
  end if;
  if get_table_index_col(p_table,l_owner,l_index,l_ind_col,l_ind_col_pos,l_number_index)=true then
    for j in 1..l_number_index loop
      if l_ind_col(j)=p_pk and l_ind_col_pos(j)=1 then
        for k in 1..l_number_index loop
          if j<>k and l_index(k)=l_index(j) and l_ind_col(k)=p_pk_key then
            index_found:=true;
            exit;
          end if;
        end loop;
      end if;
      if index_found then
        exit;
      end if;
    end loop;
  end if;
  return index_found;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in check_pk_pkkey_index '||g_status_message);
  return false;
End;

function check_load_status(p_object varchar2) return boolean is
l_stmt varchar2(1000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_date1 date;
l_date2 date;
Begin
  l_stmt:='select max(last_update_date) from edw_collection_detail_log where object_name=:a';
  if g_debug then
    write_to_log_file_n(l_stmt||' using '||p_object||get_time);
  end if;
  open cv for l_stmt using p_object;
  fetch cv into l_date1;
  close cv;
  l_stmt:='select max(last_update_date) from edw_collection_detail_log where object_name=:a '||
  'and collection_status=''ERROR''';
  if g_debug then
    write_to_log_file_n(l_stmt||' using '||p_object||get_time);
  end if;
  open cv for l_stmt using p_object;
  fetch cv into l_date2;
  close cv;
  if l_date1=l_date2 then
    return false;
  else
    return true;
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in check_load_status '||g_status_message);
  return false;
End;

function get_message(p_message  varchar2) return varchar2 is
Begin
  return get_message(p_message,null);
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_message '||g_status_message);
  return null;
End;
function get_message(p_message  varchar2,p_product varchar2) return varchar2 is
l_product varchar2(200);
Begin
  l_product:=p_product;
  if l_product is null then
    l_product:='BIS';
  end if;
  FND_MESSAGE.SET_NAME(l_product,p_message);
   return FND_MESSAGE.GET;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_message '||g_status_message);
  return null;
End;


function get_object_type(p_object_name varchar2) return varchar2 is
l_stmt varchar2(1000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_res number;
Begin
  l_stmt:='select 1 from edw_dimensions_md_v where dim_name=:a';
  open cv for l_stmt using p_object_name;
  fetch cv into l_res;
  close cv;
  if l_res=1 then
    return 'DIMENSION';
  end if;
  l_stmt:='select 1 from edw_facts_md_v where fact_name=:a';
  open cv for l_stmt using p_object_name;
  fetch cv into l_res;
  close cv;
  if l_res=1 then
    return 'FACT';
  end if;
  l_stmt:='select 1 from edw_tables_md_v where name=:a';
  open cv for l_stmt using p_object_name;
  fetch cv into l_res;
  close cv;
  if l_res=1 then
    return 'TABLE';
  end if;
  return 'UNKNOWN';
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_object_type '||g_status_message);
  return null;
End;

function get_ltc_lstg(p_object_name varchar2,p_lstg out NOCOPY varcharTableType,
p_ltc out NOCOPY varcharTableType,p_number_ltc out NOCOPY number) return boolean is
l_stmt varchar2(3000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  l_stmt:='select ltc.name,lstg.name '||
  'from  '||
  'edw_tables_md_v ltc,  '||
  'edw_tables_md_v lstg,  '||
  'edw_pvt_map_properties_md_v map,  '||
  'edw_dimensions_md_v dim,  '||
  'edw_levels_md_v lvl  '||
  'where dim.dim_name=:a  '||
  'and lvl.dim_id=dim.dim_id '||
  'and ltc.name=lvl.level_name||''_LTC'' '||
  'and map.primary_target(+)=ltc.elementid '||
  'and lstg.elementid(+)=map.primary_source';
  if g_debug then
    write_to_log_file_n(l_stmt||' using '||p_object_name||get_time);
  end if;
  p_number_ltc:=1;
  open cv for l_stmt using p_object_name;
  loop
    fetch cv into p_ltc(p_number_ltc),p_lstg(p_number_ltc);
    exit when cv%notfound;
    p_number_ltc:=p_number_ltc+1;
  end loop;
  p_number_ltc:=p_number_ltc-1;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_ltc_lstg '||g_status_message);
  return false;
End;

function is_auto_dang_implemented(p_dim_name varchar2) return boolean is
l_dim_id number;
l_is_name varchar2(40);
Begin
  if g_read_cfig_options then
    l_dim_id:=get_dim_id(p_dim_name);
    if edw_option.get_warehouse_option(null,l_dim_id,'AUTODANG',l_is_name)=false then
      null;
    end if;
    if l_is_name='Y' then
      return true;
    end if;
  else
    if fnd_profile.value('EDW_AUTO_DANG_RECOVERY')='Y' then
      return true;
    end if;
  end if;
  return false;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in is_auto_dang_implemented '||g_status_message);
  return false;
End;

function create_auto_dang_table(p_dim_auto_dang_table varchar2,
p_pk_cols varcharTableType,p_number_pk_cols number) return boolean is
l_stmt varchar2(3000);
Begin
  l_stmt:='create table '||p_dim_auto_dang_table||'(level_table number,value varchar2(800)';
  for i in 1..p_number_pk_cols loop
    if p_pk_cols(i)<>'INST' then
      l_stmt:=l_stmt||','||p_pk_cols(i)||' varchar2(800) ';
    end if;
  end loop;
  l_stmt:=l_stmt||')';
  if g_debug then
    write_to_log_file_n(l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  if instr(p_dim_auto_dang_table,'.')<>0 then
    --2881055
    begin
      l_stmt:='drop view '||substr(p_dim_auto_dang_table,instr(p_dim_auto_dang_table,'.')+1);
      if g_debug then
        write_to_log_file_n(l_stmt);
      end if;
      execute immediate l_stmt;
    exception when others then
      null;
    end;
    if create_synonym(substr(p_dim_auto_dang_table,instr(p_dim_auto_dang_table,'.')+1),
      p_dim_auto_dang_table)=false then
      null;
    end if;
  end if;
  return true;
Exception when others then
  if sqlcode=-00955 then
    if g_debug then
      write_to_log_file_n('Table '||p_dim_auto_dang_table||' exists. Returning TRUE');
    end if;
    return true;
  end if;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in create_auto_dang_table '||g_status_message);
  return false;
End;

function get_lowest_level_table(p_dim varchar2,p_lowest_level_table out NOCOPY varchar2,
p_lowest_level_table_id out NOCOPY number) return boolean is
l_stmt varchar2(3000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  l_stmt:='select ltc.name,ltc.elementid '||
  'from  '||
  'edw_levels_md_v lvl,  '||
  'edw_tables_md_v ltc,  '||
  'edw_dimensions_md_v dim  '||
  'where lvl.dim_id=dim.dim_id '||
  'and ltc.name=lvl.level_name||''_LTC'' '||
  'and dim.dim_name=:a '||
  'and not exists(  '||
  'select 1  from  '||
  'edw_pvt_level_relation_md_v lvl_rel,  '||
  'edw_hierarchies_md_v hier  '||
  'where  '||
  'lvl_rel.hierarchy_id=hier.hier_id '||
  'and hier.dim_id=dim.dim_id '||
  'and lvl_rel.parent_level_id=lvl.level_id) ';
  if g_debug then
    write_to_log_file_n(l_stmt||get_time);
  end if;
  open cv for l_stmt using p_dim;
  fetch cv into p_lowest_level_table,p_lowest_level_table_id;
  close cv;
  if g_debug then
    write_to_log_file_n('Result '||p_lowest_level_table||','||p_lowest_level_table_id);
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_lowest_level_table '||g_status_message);
  return false;
End;

function get_lowest_level_table(p_dim varchar2) return varchar2 is
Begin
  return get_lowest_level_table(p_dim,null);
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_lowest_level_table '||g_status_message);
  return null;
End;
function get_lowest_level_table(p_dim varchar2,p_dim_id number) return varchar2 is
l_stmt varchar2(3000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_lowest_level varchar2(400);
l_dim_id number;
Begin
  l_dim_id:=p_dim_id;
  if l_dim_id is null then
    l_dim_id:=get_dim_id(p_dim);
  end if;
  l_stmt:='select ltc.name '||
  'from  '||
  'edw_levels_md_v lvl,  '||
  'edw_tables_md_v ltc,  '||
  'edw_dimensions_md_v dim  '||
  'where lvl.dim_id=dim.dim_id '||
  'and ltc.name=lvl.level_name||''_LTC'' '||
  'and dim.dim_name=:a '||
  'and not exists(  '||
  'select 1  from  '||
  'edw_pvt_level_relation_md_v lvl_rel,  '||
  'edw_hierarchies_md_v hier  '||
  'where  '||
  'lvl_rel.hierarchy_id=hier.hier_id '||
  'and hier.dim_id=dim.dim_id '||
  'and lvl_rel.parent_level_id=lvl.level_id) ';
  open cv for l_stmt using l_dim_id;
  fetch cv into l_lowest_level;
  close cv;
  return l_lowest_level;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_lowest_level_table '||g_status_message);
  return null;
End;

function get_all_lowest_level_tables(
p_dim_in varchar2,
p_dim out NOCOPY varcharTableType,
p_level_table out NOCOPY varcharTableType,
p_level_table_id out NOCOPY numberTableType,
p_number_dim out NOCOPY number) return boolean is
l_stmt varchar2(3000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  p_number_dim:=0;
  l_stmt:='select dim.dim_name,ltc.elementid,ltc.name '||
  'from  '||
  'edw_levels_md_v lvl,  '||
  'edw_tables_md_v ltc,  '||
  'edw_dimensions_md_v dim  '||
  'where lvl.dim_id=dim.dim_id  '||
  'and ltc.name=lvl.level_name||''_LTC'' ';
  if p_dim_in is not null then
    l_stmt:=l_stmt||'and dim.dim_name in ('||p_dim_in||') ';
  end if;
  l_stmt:=l_stmt||'and not exists( '||
  'select 1  from  '||
  'edw_pvt_level_relation_md_v lvl_rel,  '||
  'edw_hierarchies_md_v hier  '||
  'where  '||
  'lvl_rel.hierarchy_id=hier.hier_id  '||
  'and hier.dim_id=dim.dim_id  '||
  'and lvl_rel.parent_level_id=lvl.level_id) ';
  if g_debug then
    write_to_log_file_n(l_stmt||get_time);
  end if;
  p_number_dim:=1;
  open cv for l_stmt;
  loop
    fetch cv into p_dim(p_number_dim),p_level_table_id(p_number_dim),p_level_table(p_number_dim);
    exit when cv%notfound;
    p_number_dim:=p_number_dim+1;
  end loop;
  close cv;
  p_number_dim:=p_number_dim-1;
  if g_debug then
    write_to_log_file_n('Result');
    for i in 1..p_number_dim loop
      write_to_log_file(p_dim(i)||','||p_level_table(i)||'('||p_level_table_id(i)||')');
    end loop;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_all_lowest_level_tables '||g_status_message);
  return false;
End;

function get_dim_pk_structure(p_parent_table_name varchar2,p_instance varchar2,
p_dim_pk_structure out NOCOPY varcharTableType,p_number_dim_pk_structure out NOCOPY number) return boolean is
l_db_link varchar2(300);
l_db_link_stmt varchar2(300);
l_pk_structure varchar2(800);
l_stmt varchar2(3000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_profile_options varcharTableType;
l_number_profile_options number;
Begin
  p_number_dim_pk_structure:=0;
  l_db_link:=get_db_link_for_instance(p_instance);
  if l_db_link is not null then
    l_db_link_stmt:='@'||l_db_link;
    if test_db_link(l_db_link)=false then
      if g_debug then
        write_to_log_file_n(l_db_link||' not valid db link. Cannot parse PK');
        return true;
      end if;
    end if;
  else
    l_db_link_stmt:=null;
  end if;
  l_number_profile_options:=1;
  l_stmt:='select profile_option_name from fnd_profile_options'||l_db_link_stmt||' where profile_option_name '||
  ' like '''||p_parent_table_name||'_PS%''';
  if g_debug then
    write_to_log_file_n(l_stmt||get_time);
  end if;
  open cv for l_stmt;
  loop
    fetch cv into l_profile_options(l_number_profile_options);
    exit when cv%notfound;
    l_number_profile_options:=l_number_profile_options+1;
  end loop;
  close cv;
  l_number_profile_options:=l_number_profile_options-1;
  if g_debug then
    write_to_log_file_n('The profile options found'||get_time);
    for i in 1..l_number_profile_options loop
      write_to_log_file(l_profile_options(i));
    end loop;
  end if;
  for i in 1..l_number_profile_options loop
    l_pk_structure:=null;
    begin
      l_stmt:='select fnd_profile.value'||l_db_link_stmt||'('''||l_profile_options(i)||''') from dual';
      if g_debug then
        write_to_log_file_n(l_stmt);
      end if;
      open cv for l_stmt;
      fetch cv into l_pk_structure;
      close cv;
    exception when others then
      if g_debug then
        write_to_log_file_n(sqlerrm);
      end if;
      l_pk_structure:=null;
    end;
    if l_pk_structure is null then
      l_stmt:='select B.profile_option_value from fnd_profile_options'||l_db_link_stmt||' A, '||
      'fnd_profile_option_values'||l_db_link_stmt||' B '||
      'where A.profile_option_id=B.profile_option_id '||
      'and A.profile_option_name=:a';
      if g_debug then
        write_to_log_file_n(l_stmt);
      end if;
      open cv for l_stmt using l_profile_options(i);
      fetch cv into l_pk_structure;
      close cv;
    end if;
    p_number_dim_pk_structure:=p_number_dim_pk_structure+1;
    p_dim_pk_structure(p_number_dim_pk_structure):=l_pk_structure;
  end loop;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_dim_pk_structure '||g_status_message);
  return false;
End;

function get_db_link_for_instance(p_instance varchar2) return varchar2 is
l_db_link varchar2(300);
l_stmt varchar2(3000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  l_stmt:='select warehouse_to_instance_link from edw_source_instances where instance_code=:a';
  if g_debug then
    write_to_conc_log_file(l_stmt||get_time);
  end if;
  open cv for l_stmt using p_instance;
  fetch cv into l_db_link;
  close cv;
  return l_db_link;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_conc_log_file('Error in get_db_link_for_instance '||g_status_message);
  return null;
End;

function test_db_link(p_db_link varchar2) return boolean is
l_stmt varchar2(3000);
l_date date;
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  if g_debug then
    write_to_log_file_n('Check '||p_db_link);
  end if;
  l_stmt:='select sysdate from dual@'||p_db_link;
  if g_debug then
    write_to_log_file_n(l_stmt||get_time);
  end if;
  open cv for l_stmt;
  fetch cv into l_date;
  close cv;
  return true;
Exception when others then
  write_to_log_file_n('Error in test_db_link '||sqlerrm);
  return false;
End;


function parse_pk_structure(p_dim_pk_structure varchar2,p_pk_cols out NOCOPY varcharTableType,
p_number_pk_cols out NOCOPY number) return boolean is
l_start number;
l_end number;
l_length number;
l_col varchar2(200);
Begin
  p_number_pk_cols:=0;
  if p_dim_pk_structure is null then
    return true;
  end if;
  l_start:=1;
  l_end:=1;
  l_length:=length(p_dim_pk_structure);
  loop
    l_end:=instr(p_dim_pk_structure,'-',l_start);
    if l_end=0 then
      l_end:=l_length+1;
    end if;
    l_col:=substr(p_dim_pk_structure,l_start,(l_end-l_start));
    p_number_pk_cols:=p_number_pk_cols+1;
    p_pk_cols(p_number_pk_cols):=l_col;
    if l_end>l_length then
      exit;
    end if;
    l_start:=l_end+1;
  end loop;
  if g_debug then
    write_to_log_file_n('The columns paresed from pk structure '||p_dim_pk_structure);
    for i in 1..p_number_pk_cols loop
      write_to_log_file(p_pk_cols(i));
    end loop;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in parse_pk_structure '||g_status_message);
  return false;
End;

function get_dim_pk(p_dim_name varchar2) return varchar2 is
Begin
  return get_dim_pk(p_dim_name,null);
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_dim_pk '||g_status_message);
  return null;
End;
function get_dim_pk(p_dim_name varchar2,p_dim_id number) return varchar2 is
l_dim_id number;
l_stmt varchar2(3000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_pk varchar2(200);
Begin
  l_dim_id:=p_dim_id;
  if l_dim_id is null then
    l_dim_id:=get_dim_id(p_dim_name);
  end if;
  l_stmt:='select pk_item.column_name '||
  'from '||
  'edw_unique_keys_md_v pk, '||
  'edw_pvt_key_columns_md_v isu, '||
  'edw_pvt_columns_md_v pk_item '||
  'where '||
  'pk.entity_id=:a '||
  'and pk.primarykey=1 '||
  'and isu.key_id=pk.key_id '||
  'and pk_item.column_id=isu.column_id '||
  'and pk_item.parent_object_id=pk.entity_id';
  if g_debug then
    write_to_log_file_n(l_stmt||' using '||l_dim_id);
  end if;
  open cv for l_stmt using l_dim_id;
  fetch cv into l_pk;
  close cv;
  return l_pk;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_dim_pk '||g_status_message);
  return null;
End;

procedure truncate_table(p_table varchar2) is
l_stmt varchar2(1000);
l_owner varchar2(200);
Begin
  l_owner:=get_table_owner(p_table);
  l_stmt:='truncate table '||l_owner||'.'||p_table;
  execute immediate l_stmt;
Exception when others then
  write_to_log_file_n('Exception in truncate_table '||sqlerrm);
End;

function get_dim_lvl_pk_keys(p_dim_name varchar2,p_dim_id number,
p_pk_key out NOCOPY varcharTableType,
p_number_pk_key out NOCOPY number) return boolean is
l_stmt varchar2(3000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_dim_id number;
Begin
  l_dim_id:=p_dim_id;
  p_number_pk_key:=0;
  if l_dim_id is null then
    l_dim_id:=get_dim_id(p_dim_name);
  end if;
  l_stmt:='select '||
  'lvl.level_prefix||''_''||pk_item.column_name '||
  'from  '||
  'edw_tables_md_v rel,  '||
  'edw_unique_keys_md_v pk,  '||
  'edw_pvt_key_columns_md_v isu,  '||
  'edw_pvt_columns_md_v pk_item,  '||
  'edw_levels_md_v lvl '||
  'where  '||
  ' lvl.dim_id=:a '||
  'and rel.name=lvl.level_name||''_LTC'' '||
  'and pk.entity_id=rel.elementid '||
  'and isu.key_id=pk.key_id '||
  'and pk_item.column_id=isu.column_id '||
  'and pk_item.data_type=''NUMBER'' '||
  'and pk_item.parent_object_id=rel.elementid';
  if g_debug then
    write_to_log_file_n(l_stmt||' using '||l_dim_id);
  end if;
  p_number_pk_key:=1;
  open cv for l_stmt using l_dim_id;
  loop
    fetch cv into p_pk_key(p_number_pk_key);
    exit when cv%notfound;
    p_number_pk_key:=p_number_pk_key+1;
  end loop;
  p_number_pk_key:=p_number_pk_key-1;
  close cv;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_dim_lvl_pk_keys '||g_status_message);
  return false;
End;

function get_dim_lvl_name_cols(p_dim_name varchar2,p_dim_id number,
p_name out NOCOPY varcharTableType,
p_number_name out NOCOPY number) return boolean is
l_stmt varchar2(3000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_dim_id number;
Begin
  l_dim_id:=p_dim_id;
  p_number_name:=0;
  if l_dim_id is null then
    l_dim_id:=get_dim_id(p_dim_name);
  end if;
  l_stmt:='select '||
  'lvl.level_prefix||''_NAME'' '||
  'from '||
  'edw_levels_md_v lvl '||
  'where '||
  ' lvl.dim_id=:a ';
  if g_debug then
    write_to_log_file_n(l_stmt||' using '||l_dim_id);
  end if;
  p_number_name:=1;
  open cv for l_stmt using l_dim_id;
  loop
    fetch cv into p_name(p_number_name);
    exit when cv%notfound;
    p_number_name:=p_number_name+1;
  end loop;
  p_number_name:=p_number_name-1;
  close cv;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_dim_lvl_name_cols '||g_status_message);
  return false;
End;

function get_table_seq(p_table varchar2,p_table_id number) return varchar2 is
l_seq varchar2(200);
l_stmt varchar2(3000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_table_id number;
Begin
  l_table_id:=p_table_id;
  if l_table_id is null then
    l_table_id:=get_object_id(p_table);
  end if;
  l_stmt:='select '||
  'sec_relation.sequence_name  '||
  'from   '||
  'edw_pvt_map_sources_md_v  sec_relation_usage,   '||
  'edw_pvt_sequences_md_v  sec_relation,   '||
  'edw_pvt_map_properties_md_v map  '||
  'where   '||
  'map.primary_target=:a '||
  'and  sec_relation_usage.mapping_id=map.mapping_id '||
  'and sec_relation.sequence_id=sec_relation_usage.source_id';
  if g_debug then
    write_to_log_file_n(l_stmt||' using '||l_table_id);
  end if;
  open cv for l_stmt using l_table_id;
  fetch cv into l_seq;
  close cv;
  return l_seq;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_table_seq '||g_status_message);
  return null;
End;

function get_lookup_code(p_lookup_type varchar2,p_lookup_code out NOCOPY varcharTableType,
p_number_lookup_code out NOCOPY number) return boolean is
l_stmt varchar2(4000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  l_stmt:='select lookup_code from fnd_common_lookups where lookup_type=:a';
  if g_debug then
    write_to_log_file_n(l_stmt||' using '||p_lookup_type);
  end if;
  p_number_lookup_code:=1;
  open cv for l_stmt using p_lookup_type;
  loop
    fetch cv into p_lookup_code(p_number_lookup_code);
    exit when cv%notfound;
    p_number_lookup_code:=p_number_lookup_code+1;
  end loop;
  p_number_lookup_code:=p_number_lookup_code-1;
  close cv;
  return true;
Exception when others then
  g_status:=false;
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function get_object_unique_key(p_object varchar2,p_object_id number,
p_pk out NOCOPY varcharTableType,p_number_pk out NOCOPY number) return boolean is
l_stmt varchar2(4000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_object_id number;
Begin
  l_object_id:=p_object_id;
  if l_object_id is null then
    l_object_id:=get_object_id(p_object);
  end if;
  l_stmt:='select pk_item.column_name '||
  'from '||
  'edw_unique_keys_md_v pk, '||
  'edw_pvt_key_columns_md_v isu, '||
  'edw_pvt_columns_md_v pk_item '||
  'where '||
  'pk.entity_id=:a '||
  'and isu.key_id=pk.key_id '||
  'and pk_item.column_id=isu.column_id '||
  'and pk_item.parent_object_id=pk.entity_id';
  if g_debug then
    write_to_log_file_n(l_stmt);
  end if;
  p_number_pk:=1;
  open cv for l_stmt using l_object_id;
  loop
    fetch cv into p_pk(p_number_pk);
    exit when cv%notfound;
    p_number_pk:=p_number_pk+1;
  end loop;
  p_number_pk:=p_number_pk-1;
  close cv;
  return true;
Exception when others then
  g_status:=false;
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function get_table_count_stats(p_table varchar2,p_owner varchar2) return number is
l_stmt varchar2(4000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_owner varchar2(200);
l_res number;
l_table varchar2(200);
Begin
  l_owner:=upper(p_owner);
  l_table:=upper(p_table);
  if instr(l_table,'.')>0 then
    l_table:=substr(l_table,instr(l_table,'.')+1,length(l_table));
  end if;
  if l_owner is null then
    l_owner:=get_table_owner(l_table);
  end if;
  l_stmt:='select round(nvl(num_rows,0)) from all_tables where table_name=:a and owner=:b';
  open cv for l_stmt using l_table,l_owner;
  fetch cv into l_res;
  close cv;
  return l_res;
Exception when others then
  write_to_log_file_n(sqlerrm);
  return -1;
End;

/*
lstg to ltc mapping or
fstg to fact mapping ONLY!!!
this is the main function.
this function does not consider the fk
*/
function get_src_tgt_map_details(
p_mapping_id number,
p_primary_target number,
p_primary_src number,
p_factPKNameKey varchar2,
p_dimTableName varcharTableType,
p_numberOfDimTables number,
p_fact_mapping_columns out NOCOPY varcharTableType,
p_fstg_mapping_columns out NOCOPY varcharTableType,
p_num_ff_map_cols out NOCOPY number,
p_groupby_cols out NOCOPY varcharTableType,
p_number_groupby_cols out NOCOPY number,
p_instance_column out NOCOPY varchar2,
p_groupby_on out NOCOPY boolean,
p_pk_key_seq_pos out NOCOPY number,
p_pk_key_seq out NOCOPY varchar2) return boolean is
Begin
  if g_metedata_version is null then
    g_metedata_version:=find_metadata_version;
  end if;
  if g_metedata_version='EDW' then
    if get_src_tgt_map_details_edw(
      p_mapping_id,
      p_primary_target,
      p_primary_src,
      p_factPKNameKey ,
      p_dimTableName,
      p_numberOfDimTables,
      p_fact_mapping_columns,
      p_fstg_mapping_columns,
      p_num_ff_map_cols,
      p_groupby_cols,
      p_number_groupby_cols,
      p_instance_column,
      p_groupby_on,
      p_pk_key_seq_pos,
      p_pk_key_seq)=false then
      return false;
    end if;
  elsif g_metedata_version='OWB 2.1.1' or g_metedata_version='OWB 3i' then
    if get_src_tgt_map_details_owb(
      p_mapping_id,
      p_primary_target,
      p_primary_src,
      p_factPKNameKey ,
      p_dimTableName,
      p_numberOfDimTables,
      p_fact_mapping_columns,
      p_fstg_mapping_columns,
      p_num_ff_map_cols,
      p_groupby_cols,
      p_number_groupby_cols,
      p_instance_column,
      p_groupby_on,
      p_pk_key_seq_pos,
      p_pk_key_seq,
      g_metedata_version)=false then
      return false;
    end if;
  else
    write_to_log_file_n('Could not get metadata version');
    return false;
  end if;
  return true;
Exception when others then
  g_status:=false;
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

/*
lstg to ltc mapping or
fstg to fact mapping
for 2.1.1 owb metadata or 3i owb metadata
*/
function get_src_tgt_map_details_owb(
p_mapping_id number,
p_primary_target number,
p_primary_src number,
p_factPKNameKey varchar2,
p_dimTableName varcharTableType,
p_numberOfDimTables number,
p_fact_mapping_columns out NOCOPY varcharTableType,
p_fstg_mapping_columns out NOCOPY varcharTableType,
p_num_ff_map_cols out NOCOPY number,
p_groupby_cols out NOCOPY varcharTableType,
p_number_groupby_cols out NOCOPY number,
p_instance_column out NOCOPY varchar2,
p_groupby_on out NOCOPY boolean,
p_pk_key_seq_pos out NOCOPY number,
p_pk_key_seq out NOCOPY varchar2,
p_metedata_version varchar2) return boolean is
l_hold_func varcharTableType;
l_hold_func_category varcharTableType;
l_hold_item varcharTableType; --this is table.item
l_hold_item_org varcharTableType; --this one is the pure col name
l_hold_item_id numberTableType;
l_hold_relation numberTableType;
l_hold_item_usage numberTableType;
l_hold_aggregatefunction varcharTableType;
l_hold_relation_name varcharTableType;
l_hold_relation_type varcharTableType;
l_hold_relation_usage numberTableType;
l_hold_func_usage numberTableType;
l_hold_is_distinct numberTableType;
l_hold_func_position numberTableType;
l_hold_func_dvalue varcharTableType;
l_count number:=1;
l_func_id number;
l_func_name varchar2(400);
l_src_col_count numberTableType;
l_found boolean:=false;
Begin
  if g_debug then
    write_to_log_file_n('In get_src_tgt_map_details_owb');
  end if;
  p_num_ff_map_cols:=0;
  p_number_groupby_cols:=0;
  p_pk_key_seq_pos:=0;
  p_pk_key_seq:=null;
  p_instance_column:=null;
  p_groupby_on:=false;
  if get_mapping_details(
     p_mapping_id
    ,l_hold_func
    ,l_hold_func_category
    ,l_hold_item
    ,l_hold_item_id
    ,l_hold_item_usage
    ,l_hold_aggregatefunction
    ,l_hold_is_distinct
    ,l_hold_relation
    ,l_hold_relation_name
    ,l_hold_relation_usage
    ,l_hold_relation_type
    ,l_hold_func_usage
    ,l_hold_func_position
    ,l_hold_func_dvalue
    ,l_count
    ,p_metedata_version)=false then
    return false;
  end if;
  for i in 1..l_count loop
    l_hold_item_org(i):=l_hold_item(i);
  end loop;
  for i in 1..l_count loop
    if l_hold_relation(i)<>p_primary_target then
      if l_hold_aggregatefunction(i) is not null then
        p_groupby_on:=true;
        l_hold_item(i):=l_hold_relation_name(i)||'.'||l_hold_item(i);
        l_hold_item(i):=l_hold_aggregatefunction(i)||'('||l_hold_item(i)||')';
      else
        if value_in_table(p_dimTableName,p_numberOfDimTables,l_hold_relation_name(i))=false then
          p_number_groupby_cols:=p_number_groupby_cols+1;
          p_groupby_cols(p_number_groupby_cols):=l_hold_item(i);
          /*
            p_groupby_cols and p_groupby_stmt should be used only when p_groupby_on =true!!
          */
          l_hold_item(i):=l_hold_relation_name(i)||'.'||l_hold_item(i);
        end if;
      end if;
      --find the instance col
      if p_instance_column is null then
        if l_hold_relation(i)=p_primary_src then
          if l_hold_item_org(i)='INSTANCE' OR l_hold_item_org(i)='INSTANCE_CODE' then
            p_instance_column:= l_hold_item_org(i);
          end if;
        end if;
      end if;
    end if;
  end loop;
  if p_groupby_on then
    write_to_log_file_n('Group by on, the columns are ');
    for i in 1..p_number_groupby_cols loop
      write_to_log_file(p_groupby_cols(i));
    end loop;
  end if;
  p_pk_key_seq_pos:=0;
  p_pk_key_seq:=null;
  for i in 1..l_count loop
    if l_hold_relation(i)=p_primary_target then --this is the fact
      --if this is from the dim, skip this
      l_found:=false; --needed to see if this is a dim table. then skip...
      l_func_id:=l_hold_func_usage(i);--need to hold the func usage
      for j in 1..l_count loop
        if l_func_id=l_hold_func_usage(j) and l_hold_relation(j)<>p_primary_target then
          --if this is a secondary source, goto loopend\
          --this is imp here because the secondary sources are only considered for
          --key translation
          if value_in_table(p_dimTableName,p_numberOfDimTables,l_hold_relation_name(j)) then
            goto loopend;
          end if;
        end if;
      end loop;
      --now look at the proper cols
      p_num_ff_map_cols:=p_num_ff_map_cols+1;
      p_fact_mapping_columns(p_num_ff_map_cols):=l_hold_item(i);
      --now get the src
      l_func_id:=l_hold_func_usage(i);--need to hold the func usage
      l_func_name:=l_hold_func(i);
      l_src_col_count(p_num_ff_map_cols):=0;--how many src cols there are for this
      p_fstg_mapping_columns(p_num_ff_map_cols):=null; --was ''
      if l_func_name <> 'COPY' then
        if l_hold_func_category(i) <> 'Basic' and
           l_hold_func_category(i) <> 'Character' and
           l_hold_func_category(i) <> 'Conversion' and
           l_hold_func_category(i) <> 'Date' and
           l_hold_func_category(i) <> 'Numeric' and
           l_hold_func_category(i) <> 'EDW_STAND_ALONE' then
           p_fstg_mapping_columns(p_num_ff_map_cols):=l_hold_func_category(i)||'.'||l_func_name||'(';
        else
          p_fstg_mapping_columns(p_num_ff_map_cols):=l_func_name||'(';
        end if;
      end if;
      for j in 1..l_count loop
        --first get the mapping for the src table
        --if l_hold_func_usage(j)=l_func_id AND l_hold_relation(j)= p_primary_src then
        if l_hold_func_usage(j)=l_func_id AND l_hold_relation(j)<> p_primary_target then
          if p_fact_mapping_columns(p_num_ff_map_cols)=p_factPKNameKey then
            if l_hold_relation_type(j)='CMPWBSequence' or l_hold_relation_type(j)='SEQUENCE' then
              p_pk_key_seq_pos:=p_num_ff_map_cols;
              p_pk_key_seq:=l_hold_relation_name(j);
            end if;
          end if;
          l_src_col_count(p_num_ff_map_cols):=l_src_col_count(p_num_ff_map_cols)+1;
          if l_src_col_count(p_num_ff_map_cols)=1 then
            p_fstg_mapping_columns(p_num_ff_map_cols):=p_fstg_mapping_columns(p_num_ff_map_cols)||' '||
            l_hold_item(j);
          else
            if l_func_name <> 'COPY' then
              p_fstg_mapping_columns(p_num_ff_map_cols):=p_fstg_mapping_columns(p_num_ff_map_cols)||', '||l_hold_item(j);
            end if;
          end if;
        end if;
      end loop;
      if l_func_name <> 'COPY' then
        p_fstg_mapping_columns(p_num_ff_map_cols):=p_fstg_mapping_columns(p_num_ff_map_cols)||')';
      end if;
    end if;
    <<loopend>>
    null;
  end loop;
  return true;
Exception when others then
  g_status:=false;
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

/*
lstg to ltc mapping or
fstg to fact mapping
for EDW metadata
*/
function get_src_tgt_map_details_edw(
p_mapping_id number,
p_primary_target number,
p_primary_src number,
p_factPKNameKey varchar2,
p_dimTableName varcharTableType,
p_numberOfDimTables number,
p_fact_mapping_columns out NOCOPY varcharTableType,
p_fstg_mapping_columns out NOCOPY varcharTableType,
p_num_ff_map_cols out NOCOPY number,
p_groupby_cols out NOCOPY varcharTableType,
p_number_groupby_cols out NOCOPY number,
p_instance_column out NOCOPY varchar2,
p_groupby_on out NOCOPY boolean,
p_pk_key_seq_pos out NOCOPY number,
p_pk_key_seq out NOCOPY varchar2) return boolean is
Begin
  if g_debug then
    write_to_log_file_n('In get_src_tgt_map_details_edw');
  end if;
  return true;
Exception when others then
  g_status:=false;
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function find_metadata_version return varchar2 is
l_stmt varchar2(1000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_view_text varchar2(10000);
l_version varchar2(100);
Begin
  l_stmt:='select text from user_views where view_name=:a';
  if g_debug then
    write_to_log_file_n(l_stmt);
  end if;
  open cv for l_stmt using 'EDW_DIMENSIONS_MD_V';
  fetch cv into l_view_text;
  close cv;
  l_view_text:=lower(l_view_text);
  if g_debug then
    write_to_log_file_n(l_view_text);
  end if;
  if instr(l_view_text,'cmpwbdimension_v')<>0 then
    l_version:='OWB 2.1.1';
  else
    l_version:='OWB 3i';
  end if;
  if g_debug then
    write_to_log_file_n('metadata version '||l_version);
  end if;
  return l_version;
Exception when others then
  write_to_log_file_n(sqlerrm);
  return null;
End;

function get_metadata_version return varchar2 is
Begin
  if g_metedata_version is null then
    g_metedata_version:=find_metadata_version;
  end if;
  return g_metedata_version;
Exception when others then
  write_to_log_file_n(sqlerrm);
  return null;
End;


/*
called from derived fact loading.
*/
function get_derv_mapping_details(
p_mapping_id number,
p_src_object_id number,
p_number_skip_cols number,
p_skip_cols varcharTableType,
p_fact_fks varcharTableType,
p_number_fact_fks number,
p_src_fks varcharTableType,
p_number_src_fks number,
p_fact_id number,
p_src_object varchar2,
p_temp_fact_name_temp in out NOCOPY varchar2,
p_number_sec_sources out NOCOPY number,
p_sec_sources out NOCOPY varcharTableType,
p_sec_sources_alias out NOCOPY varcharTableType,
p_number_sec_key out NOCOPY number,
p_sec_sources_pk out NOCOPY varcharTableType,
p_sec_sources_fk out NOCOPY varcharTableType,
p_groupby_stmt out NOCOPY varchar2,
p_hold_number out NOCOPY number,
p_number_group_by_cols out NOCOPY number,
p_hold_relation out NOCOPY varcharTableType,
p_hold_item out NOCOPY varcharTableType,
p_group_by_cols out NOCOPY varcharTableType,
p_output_group_by_cols out NOCOPY varcharTableType,
p_number_input_params out NOCOPY number,
p_output_params out NOCOPY varcharTableType,
p_input_params out NOCOPY varcharTableType,
p_filter_stmt out NOCOPY varchar2
) return boolean is
Begin
  if g_metedata_version is null then
    g_metedata_version:=find_metadata_version;
  end if;
  if g_metedata_version='EDW' then
    if get_derv_mapping_details_edw(
      p_mapping_id,
      p_src_object_id,
      p_number_skip_cols,
      p_skip_cols,
      p_fact_fks,
      p_number_fact_fks,
      p_src_fks,
      p_number_src_fks,
      p_fact_id,
      p_src_object,
      p_temp_fact_name_temp,
      p_number_sec_sources,
      p_sec_sources,
      p_sec_sources_alias,
      p_number_sec_key,
      p_sec_sources_pk,
      p_sec_sources_fk,
      p_groupby_stmt,
      p_hold_number,
      p_number_group_by_cols,
      p_hold_relation,
      p_hold_item,
      p_group_by_cols,
      p_output_group_by_cols,
      p_number_input_params,
      p_output_params,
      p_input_params,
      p_filter_stmt)=false then
      return false;
    end if;
  elsif g_metedata_version='OWB 2.1.1' or g_metedata_version='OWB 3i' then
    if get_derv_mapping_details_owb(
      p_mapping_id,
      p_src_object_id,
      p_number_skip_cols,
      p_skip_cols,
      p_fact_fks,
      p_number_fact_fks,
      p_src_fks,
      p_number_src_fks,
      p_fact_id,
      p_src_object,
      p_temp_fact_name_temp,
      p_number_sec_sources,
      p_sec_sources,
      p_sec_sources_alias,
      p_number_sec_key,
      p_sec_sources_pk,
      p_sec_sources_fk,
      p_groupby_stmt,
      p_hold_number,
      p_number_group_by_cols,
      p_hold_relation,
      p_hold_item,
      p_group_by_cols,
      p_output_group_by_cols,
      p_number_input_params,
      p_output_params,
      p_input_params,
      p_filter_stmt,
      g_metedata_version)=false then
      return false;
    end if;
  else
    write_to_log_file_n('Could not get metadata version');
    return false;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_mapping_details(main) '||sqlerrm||' '||get_time);
  return false;
End;

function get_derv_mapping_details_owb(
p_mapping_id number,
p_src_object_id number,
p_number_skip_cols number,
p_skip_cols varcharTableType,
p_fact_fks varcharTableType,
p_number_fact_fks number,
p_src_fks varcharTableType,
p_number_src_fks number,
p_fact_id number,
p_src_object varchar2,
p_temp_fact_name_temp in out NOCOPY varchar2,
p_number_sec_sources out NOCOPY number,
p_sec_sources out NOCOPY varcharTableType,
p_sec_sources_alias out NOCOPY varcharTableType,
p_number_sec_key out NOCOPY number,
p_sec_sources_pk out NOCOPY varcharTableType,
p_sec_sources_fk out NOCOPY varcharTableType,
p_groupby_stmt out NOCOPY varchar2,
p_hold_number out NOCOPY number,
p_number_group_by_cols out NOCOPY number,
p_hold_relation out NOCOPY varcharTableType,
p_hold_item out NOCOPY varcharTableType,
p_group_by_cols out NOCOPY varcharTableType,
p_output_group_by_cols out NOCOPY varcharTableType,
p_number_input_params out NOCOPY number,
p_output_params out NOCOPY varcharTableType,
p_input_params out NOCOPY varcharTableType,
p_filter_stmt out NOCOPY varchar2,
p_metedata_version varchar2
) return boolean is
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_stmt varchar2(20000);
l_hold_func varcharTableType;
l_hold_func_category varcharTableType;
l_hold_item varcharTableType;
l_hold_item_id numberTableType;
l_hold_item_is_fk booleanTableType;
l_hold_relation numberTableType;
l_hold_relation_usage numberTableType;
l_hold_item_usage numberTableType;
l_hold_aggregatefunction varcharTableType;
l_hold_is_distinct numberTableType;
l_hold_relation_name varcharTableType;
l_hold_relation_type varcharTableType;
l_hold_func_usage numberTableType;
l_hold_func_position numberTableType;
l_hold_func_dvalue varcharTableType;
l_hold_number number;
l_ip_aggregate  varcharTableType;
l_ip_previous varchar2(400);
l_ip_param_agg boolean:=false;
l_ip_agg_func varchar2(400);
l_sec_source  varcharTableType;
l_sec_source_id  numberTableType;
l_sec_source_child  varcharTableType;
l_sec_source_child_id  numberTableType;
l_pk   varcharTableType;
l_fk   varcharTableType;
l_sec_source_usage  numberTableType;
l_sec_source_usage_name  varcharTableType;
l_sec_source_child_usage  numberTableType;
l_sec_source_number  number;
l_sec_sources_child_alias  varcharTableType;
l_sec_source_name_index  varcharTableType;
l_sec_source_index  numberTableType;
l_sec_source_index_number number;
l_ind number;
l_aggregation_value varchar2(400);
--skipping items
l_output_params varcharTableType;
l_input_params varcharTableType;
l_number_input_params number;
begin
  if g_debug then
    write_to_log_file_n('In util.get_mapping_details_owb');
  end if;
  p_number_sec_sources:=0;
  p_number_sec_key:=0;
  p_groupby_stmt:=null;
  p_hold_number:=0;
  p_number_group_by_cols:=0;
  p_number_input_params:=0;
  p_filter_stmt:=null;
  l_hold_number:=1;
  if get_mapping_details(
     p_mapping_id
    ,l_hold_func
    ,l_hold_func_category
    ,l_hold_item
    ,l_hold_item_id
    ,l_hold_item_usage
    ,l_hold_aggregatefunction
    ,l_hold_is_distinct
    ,l_hold_relation
    ,l_hold_relation_name
    ,l_hold_relation_usage
    ,l_hold_relation_type
    ,l_hold_func_usage
    ,l_hold_func_position
    ,l_hold_func_dvalue
    ,l_hold_number
    ,p_metedata_version)=false then
    g_status_message:=g_status_message;
    return false;
  end if;
  if g_debug  then
    write_to_log_file_n('The result of get_mapping_details, l_hold_number is '||l_hold_number);
    write_to_log_file_n('l_hold_func l_hold_item l_hold_item_id l_hold_relation l_hold_item_usage
        l_hold_aggregatefunction l_hold_is_distinct l_hold_relation_name l_hold_func_usage');
    for i in 1..l_hold_number loop
      write_to_log_file(l_hold_func(i)||' '||l_hold_func_category(i)||' '||l_hold_item(i)||' '||
      l_hold_item_id(i)||' '||l_hold_relation(i)||' '||
      l_hold_item_usage(i)||' '||l_hold_aggregatefunction(i)||' '||l_hold_is_distinct(i)||' '||
      l_hold_relation_name(i)||' '||l_hold_relation_usage(i)||'  '||l_hold_func_usage(i)||' '||
      l_hold_func_position(i)||' '||l_hold_func_dvalue(i));
    end loop;
  end if;
  --first do this only for the base fact columns. for the sec sources, we will need to
  --find the aliases first
  for i in 1..l_hold_number loop
    l_hold_item_is_fk(i):=false;
    if l_hold_relation(i)=p_src_object_id then
      --we cannot have l_hold_relation(i)<>g_fact_id because secondary sources have aliasing issue
      l_hold_item(i):=l_hold_relation_name(i)||'.'||l_hold_item(i);
    end if;
  end loop;
  if get_sec_source_info(
    p_mapping_id,
    l_sec_source,
    l_sec_source_id ,
    l_sec_source_child ,
    l_sec_source_child_id,
    l_pk,
    l_fk,
    l_sec_source_usage,
    l_sec_source_usage_name,
    l_sec_source_child_usage,
    l_sec_source_number) = false then
    g_status_message:=g_status_message;
    return false;
  end if;
  p_number_sec_sources:=0;
  if l_sec_source_number>0 then
    --first generate the alias
    if g_debug then
      write_to_log_file_n('Going to generate alias');
    end if;
    for i in 1..l_sec_source_number loop
      p_number_sec_sources :=p_number_sec_sources +1;
      p_sec_sources(p_number_sec_sources):=l_sec_source(i);
      p_sec_sources_alias(p_number_sec_sources):=l_sec_source_usage_name(i);
    end loop;
    declare
      l_sec_number  varcharTableType;
      l_last_num number;
    begin
      for i in 1..l_sec_source_number loop
        l_sec_number(i):=-1;
      end loop;
      --logic to derive the name of the sec source
      for i in 1..l_sec_source_number loop
        if l_sec_number(i)=-1 then
          l_sec_number(i):=0;
        end if;
        l_last_num:=0;
        for j in 1..l_sec_source_number loop
          if i<>j and l_sec_source(i)=l_sec_source(j) and l_sec_source(i)=l_sec_source_usage_name(j)  then
            if l_sec_number(j)=-1 then
              l_last_num:=l_last_num+1;
              l_sec_number(j):=l_last_num;
            end if;
          end if;
        end loop;
      end loop;
      for i in 1..l_sec_source_number loop
        if l_sec_number(i) > 0 then
          p_sec_sources_alias(i):=p_sec_sources_alias(i)||'$'||l_sec_number(i);
        end if;
      end loop;
    exception when others then
      g_status_message:=sqlerrm;
      write_to_log_file_n(g_status_message);
      return false;
    end;
    --l_sec_sources_child_alias
    for i in 1..l_sec_source_number loop
      l_sec_sources_child_alias(i):=l_sec_source_child(i);
      for j in 1..l_sec_source_number loop
        if l_sec_source_usage(j)=l_sec_source_child_usage(i) then
          l_sec_sources_child_alias(i):=p_sec_sources_alias(j);
          exit;
        end if;
      end loop;
    end loop;
    if g_debug then
      write_to_log_file_n('The sec sources , its alias, and child alias');
      for i in 1..p_number_sec_sources loop
        write_to_log_file(p_sec_sources(i)||' '||p_sec_sources_alias(i)||' '||l_sec_sources_child_alias(i));
      end loop;
    end if;
    --assign the keys
    /*g_number_sec_key is actually=g_number_sec_sources. but keeping them separate for now*/
    p_number_sec_key:=0;
    for i in 1..l_sec_source_number loop
      p_number_sec_key:=p_number_sec_key+1;
      p_sec_sources_pk(p_number_sec_key):=p_sec_sources_alias(i)||'.'||l_pk(i);
      p_sec_sources_fk(p_number_sec_key):=l_sec_sources_child_alias(i)||'.'||l_fk(i);
    end loop;
    if g_debug then
      write_to_log_file_n('The secondary sources keys');
      for i in 1..p_number_sec_key loop
        write_to_log_file(p_sec_sources_pk(i)||' '||p_sec_sources_fk(i));
      end loop;
    end if;
    --assign the secondary source column maps
    for i in 1..l_hold_number loop
      l_ind:=0;
      if l_hold_relation(i)<> p_src_object_id and l_hold_relation(i)<> p_fact_id then
        for j in 1..p_number_sec_sources loop
          if l_sec_source_usage(j)=l_hold_relation_usage(i) then
            l_ind:=j;
            exit;
          end if;
        end loop;
        if l_ind>0 then
          l_hold_item(i):=p_sec_sources_alias(l_ind)||'.'||l_hold_item(i);
        else
          l_hold_item(i):=l_hold_relation_name(i)||'.'||l_hold_item(i);
        end if;
      end if;
    end loop;
    if g_debug then
      write_to_log_file_n('The secondary source col maps');
      for i in 1..l_hold_number loop
        if l_hold_relation(i)<> p_src_object_id and l_hold_relation(i)<> p_fact_id then
          write_to_log_file(l_hold_item(i));
        end if;
      end loop;
    end if;
  else
    p_temp_fact_name_temp:=p_src_object;
    if g_debug then
      write_to_log_file_n('No secondary sources');
    end if;
  end if;
  p_groupby_stmt:=null;
  p_hold_number:=l_hold_number;
  p_number_group_by_cols:=0;--no group by to start with unless common keys found
  --find the fks that are directly mapped from the base to the derived
  for i in 1..l_hold_number loop
    p_hold_relation(i):=l_hold_relation(i);
    p_hold_item(i):=l_hold_item(i);
    if l_hold_relation(i)=p_fact_id and l_hold_func(i) ='COPY' then
      for j in 1..l_hold_number loop
        if l_hold_func_usage(j) = l_hold_func_usage(i) AND l_hold_relation(j) <> p_fact_id then
          if is_src_fk(l_hold_item(j),p_src_fks,p_number_src_fks)= true then
            l_hold_item_is_fk(j):=true;
            p_number_group_by_cols:=p_number_group_by_cols+1;
            p_group_by_cols(p_number_group_by_cols):=l_hold_item(j);
          end if;
        end if;
      end loop;
    end if;
  end loop;
  for i in 1..p_number_group_by_cols loop
    for j in 1..l_hold_number loop
      if l_hold_item(j)=p_group_by_cols(i) and l_hold_relation(j)<>p_fact_id and l_hold_func(j) ='COPY' then
        for k in 1..l_hold_number loop
          if l_hold_func_usage(j) = l_hold_func_usage(k) AND l_hold_relation(k) = p_fact_id then
            p_output_group_by_cols(i):=l_hold_item(k);
            exit;
          end if;
        end loop;
        exit;
      end if;
    end loop;
  end loop;
  --make the funcs
  p_number_input_params:=0;
  for i in 1..l_hold_number loop
    if l_hold_relation(i)=p_fact_id then
      p_number_input_params:=p_number_input_params+1;
      p_output_params(p_number_input_params):=l_hold_item(i);
      --p_input_params_is_fk(p_number_input_params):=false; --make the input param not key by default
      if l_hold_func(i) = 'COPY' then
        for j in 1..l_hold_number loop
          if l_hold_func_usage(j) = l_hold_func_usage(i) AND l_hold_relation(j) <> p_fact_id then
            if l_hold_aggregatefunction(j) is not null then
              if l_hold_is_distinct(j)=1 then
                l_hold_item(j):=l_hold_aggregatefunction(j)||'(DISTINCT('||l_hold_item(j)||'))';
              else
                l_hold_item(j):=l_hold_aggregatefunction(j)||'('||l_hold_item(j)||')';
              end if;
            else
               --if this is a group by, do not sum
               if l_hold_item_is_fk(j)=false and value_in_table(p_group_by_cols,p_number_group_by_cols,
                 l_hold_item(j))=false then
                 l_hold_item(j):='SUM('||l_hold_item(j)||')';
               end if;
            end if;
            p_input_params(p_number_input_params):=l_hold_item(j);
            --if the cols is a fk, then we need group by this col
            exit;
          end if;
        end loop;
      else
        p_input_params(p_number_input_params):=make_transforms_rec(
            l_hold_func,
            l_hold_func_category,
            l_hold_item,
            l_hold_item_id,
            l_hold_item_is_fk,
            l_hold_relation,
            l_hold_relation_usage,
            l_hold_item_usage,
            l_hold_aggregatefunction,
            l_hold_is_distinct,
            l_hold_relation_name,
            l_hold_func_usage,
            l_hold_func_position,
            l_hold_func_dvalue,
            p_sec_sources,
            p_number_sec_sources,
            p_fact_id,
            p_src_object,
            l_hold_number,
            i,
            l_aggregation_value);
        if l_aggregation_value='AGGREGATION' then
          null;
        else
          p_input_params(p_number_input_params):='SUM('||p_input_params(p_number_input_params)||')';
        end if;
      end if;
    end if;
  end loop;
  --p_output_group_by_cols
  --i need to know what are the derived fact col corresponding to the base fact group by cols
  --p_output_group_by_cols
  --i need to know what are the derived fact col corresponding to the base fact group by cols
  --group by of cols is implemented as a transformation GROUP_BY .
  --bug 2564723. added or l_hold_func_category(i) = 'OPI_EDW_TRANSFORM_PKG') then
  for i in 1..l_hold_number loop
    if l_hold_relation(i)=p_fact_id and l_hold_func(i) = 'GROUP_BY' and
      (l_hold_func_category(i) like 'EDW_STAND_ALONE%'
      or l_hold_func_category(i) = 'OPI_EDW_TRANSFORM_PKG') then
      for j in 1..p_number_input_params loop
        if p_output_params(j)=l_hold_item(i) then
          p_number_group_by_cols:=p_number_group_by_cols+1;
          p_group_by_cols(p_number_group_by_cols):=p_input_params(j);
          p_output_group_by_cols(p_number_group_by_cols):=p_output_params(j);
          exit;
        end if;
      end loop;
    end if;
  end loop;
  if g_debug then
    write_to_log_file_n('The input and output groupby columns');
    for i in 1..p_number_group_by_cols loop
      write_to_log_file(p_group_by_cols(i)||'   '||p_output_group_by_cols(i));
    end loop;
  end if;
  if p_number_skip_cols>0 then
    if g_debug then
      write_to_log_file_n('The input and output params BEFORE SKIPPING');
      for i in 1..p_number_input_params loop
        write_to_log_file(p_input_params(i)||'         '||p_output_params(i));
      end loop;
    end if;
    --skip items
    l_number_input_params:=0;
    for i in 1..p_number_input_params loop
      if value_in_table(p_skip_cols,p_number_skip_cols,p_output_params(i))=false or
        value_in_table(p_fact_fks,p_number_fact_fks,p_output_params(i)) then
        l_number_input_params:=l_number_input_params+1;
        l_output_params(l_number_input_params):=p_output_params(i);
        l_input_params(l_number_input_params):=p_input_params(i);
      end if;
    end loop;
    p_number_input_params:=l_number_input_params;
    p_input_params:=l_input_params;
    p_output_params:=l_output_params;
  end if;
  if g_debug then
    write_to_log_file_n('The final input and output params');
    for i in 1..p_number_input_params loop
      write_to_log_file(p_input_params(i)||'         '||p_output_params(i));
    end loop;
  end if;
  --get filter
  --p_filter_stmt
  p_filter_stmt:=null;
  l_stmt:='select text from edw_pvt_map_properties_md_v where mapping_id=:a and text_type=''Filter''';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||' using '||p_mapping_id);
  end if;
  open cv for l_stmt using p_mapping_id;
  fetch cv into p_filter_stmt;
  close cv;
  if g_debug then
    write_to_log_file_n('p_filter_stmt='||p_filter_stmt);
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_mapping_details_owb '||sqlerrm||' '||get_time);
  return false;
End;

function get_derv_mapping_details_edw(
p_mapping_id number,
p_src_object_id number,
p_number_skip_cols number,
p_skip_cols varcharTableType,
p_fact_fks varcharTableType,
p_number_fact_fks number,
p_src_fks varcharTableType,
p_number_src_fks number,
p_fact_id number,
p_src_object varchar2,
p_temp_fact_name_temp in out NOCOPY varchar2,
p_number_sec_sources out NOCOPY number,
p_sec_sources out NOCOPY varcharTableType,
p_sec_sources_alias out NOCOPY varcharTableType,
p_number_sec_key out NOCOPY number,
p_sec_sources_pk out NOCOPY varcharTableType,
p_sec_sources_fk out NOCOPY varcharTableType,
p_groupby_stmt out NOCOPY varchar2,
p_hold_number out NOCOPY number,
p_number_group_by_cols out NOCOPY number,
p_hold_relation out NOCOPY varcharTableType,
p_hold_item out NOCOPY varcharTableType,
p_group_by_cols out NOCOPY varcharTableType,
p_output_group_by_cols out NOCOPY varcharTableType,
p_number_input_params out NOCOPY number,
p_output_params out NOCOPY varcharTableType,
p_input_params out NOCOPY varcharTableType,
p_filter_stmt out NOCOPY varchar2
) return boolean is
Begin
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_mapping_details_edw '||sqlerrm||' '||get_time);
  return false;
End;

function is_src_fk(p_fk varchar2,p_src_fks varcharTableType,p_number_src_fks number) return boolean is
l_fk varchar2(400);
begin
  if g_debug then
    write_to_log_file_n('in is_src_fk,p_fk='||p_fk);
  end if;
  --if the fk is abc.xyz then parse the xyz out
  if instr(p_fk,'.') <> 0 then
    l_fk:=substr(p_fk,instr(p_fk,'.')+1,length(p_fk));
  else
    l_fk:=p_fk;
  end if;
  if g_debug then
    write_to_log_file('l_fk='||l_fk);
  end if;
  for i in 1..p_number_src_fks loop
    if l_fk=p_src_fks(i) then
      return true;
    end if;
  end loop;
  return false;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in is_src_fk for '||p_fk||' '||sqlerrm||get_time);
  return false;
End;

function get_dim_hier_levels(p_dim_name varchar2,
p_hier out NOCOPY varcharTableType,
p_parent_ltc out NOCOPY varcharTableType,
p_parent_ltc_id out NOCOPY numberTableType,
p_child_ltc out NOCOPY varcharTableType,
p_child_ltc_id out NOCOPY numberTableType,
p_number_hier out NOCOPY number) return boolean is
l_stmt varchar2(4000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  p_number_hier:=1;
  l_stmt:='select '||
  'parent_ltc.name,  '||
  'parent_ltc.elementid, '||
  'child_ltc.name,  '||
  'child_ltc.elementid, '||
  'hier.HIER_NAME '||
  'from  '||
  'edw_pvt_level_relation_md_v lvl_rel,  '||
  'edw_hierarchies_md_v hier,  '||
  'edw_dimensions_md_v dim,  '||
  'edw_levels_md_v child_level,  '||
  'edw_levels_md_v parent_level,  '||
  'edw_tables_md_v parent_ltc,  '||
  'edw_tables_md_v child_ltc  '||
  'where  '||
  'dim.dim_name=:a '||
  'and hier.DIM_ID=dim.DIM_ID  '||
  'and lvl_rel.HIERARCHY_ID=hier.HIER_ID '||
  'and child_level.LEVEL_ID=lvl_rel.CHILD_LEVEL_ID  '||
  'and parent_level.LEVEL_ID=lvl_rel.PARENT_LEVEL_ID  '||
  'and parent_ltc.name=parent_level.LEVEL_NAME||''_LTC'' '||
  'and child_ltc.name=child_level.LEVEL_NAME||''_LTC'' ';
  if g_debug then
    write_to_log_file_n(l_stmt);
  end if;
  open cv for l_stmt using p_dim_name;
  loop
    fetch cv into p_parent_ltc(p_number_hier),p_parent_ltc_id(p_number_hier),
    p_child_ltc(p_number_hier),p_child_ltc_id(p_number_hier),p_hier(p_number_hier);
    exit when cv%notfound;
    p_number_hier:=p_number_hier+1;
  end loop;
  p_number_hier:=p_number_hier-1;
  close cv;
  return true;
Exception when others then
  g_status:=false;
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function get_target_map(p_object_id number,p_object_name varchar2) return number is
l_stmt varchar2(4000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_mapping_id number;
Begin
  if p_object_name is null then
    l_stmt:='select mapping_id from edw_pvt_map_properties_md_v where primary_target=:a';
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||' using '||p_object_id);
    end if;
    open cv for l_stmt using p_object_id;
    fetch cv into l_mapping_id;
    close cv;
  else
    l_stmt:='select map.mapping_id from edw_pvt_map_properties_md_v map,edw_relations_md_v rel where '||
    'rel.relation_name=:a and map.primary_target=rel.relation_id ';
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||' using '||p_object_name);
    end if;
    open cv for l_stmt using p_object_name;
    fetch cv into l_mapping_id;
    close cv;
  end if;
  if g_debug then
    write_to_log_file_n('l_mapping_id='||l_mapping_id);
  end if;
  return l_mapping_id;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return -1;
End;

function get_last_analyzed_date(p_table varchar2) return date is
Begin
  return get_last_analyzed_date(p_table,null);
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return null;
End;
function get_last_analyzed_date(p_table varchar2, p_owner varchar2) return date is
l_stmt varchar2(1000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_owner varchar2(200);
l_date date;
Begin
  l_owner:=p_owner;
  if l_owner is null then
    l_owner:=get_table_owner(p_table);
  end if;
  l_stmt:='select last_analyzed from all_tables where table_name=:1 and owner=:2';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||' using '||p_table||','||l_owner);
  end if;
  open cv for l_stmt using p_table,l_owner;
  fetch cv into l_date;
  close cv;
  return l_date;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return null;
End;

function create_load_input_table(
  p_table_name varchar2,
  p_object_name varchar2,
  p_mapping_id number,
  p_map_type varchar2,
  p_primary_src number,
  p_primary_target number,
  p_primary_target_name varchar2,
  p_object_type varchar2,
  p_conc_id number,
  p_conc_program_name varchar2,
  p_fact_audit boolean,
  p_net_change boolean,
  p_fact_audit_name varchar2,
  p_net_change_name varchar2,
  p_fact_audit_is_name varchar2,
  p_net_change_is_name varchar2,
  p_debug boolean,
  p_duplicate_collect boolean,
  p_execute_flag boolean,
  p_request_id number,
  p_collection_size number,
  p_parallel number,
  p_table_owner varchar2,
  p_bis_owner  varchar2,
  p_temp_log boolean,
  p_forall_size number,
  p_update_type varchar2,
  p_mode varchar2,
  p_explain_plan_check boolean,
  p_fact_dlog varchar2,
  p_key_set number,
  p_instance_type varchar2,
  p_load_pk number,
  p_skip_cols EDW_OWB_COLLECTION_UTIL.varcharTableType,
  p_number_skip_cols number,
  p_fresh_restart boolean,
  p_op_table_space varchar2,
  p_da_cols EDW_OWB_COLLECTION_UTIL.varcharTableType,
  p_number_da_cols number,
  p_da_table varchar2,
  p_pp_table varchar2,
  p_master_instance varchar2,
  p_rollback varchar2,
  p_skip_levels EDW_OWB_COLLECTION_UTIL.varcharTableType,
  p_number_skip_levels number,
  p_smart_update boolean,
  p_fk_use_nl number,
  p_fact_smart_update number,
  p_auto_dang_table_extn varchar2,
  p_log_dang_keys boolean,
  p_create_parent_table_records boolean,
  p_smart_update_cols EDW_OWB_COLLECTION_UTIL.varcharTableType,
  p_number_smart_update_cols number,
  p_check_fk_change boolean,
  p_stg_join_nl_percentage number,
  p_ok_switch_update number,
  p_stg_make_copy_percentage number,
  p_ok_table varchar2,
  p_hash_area_size number,
  p_sort_area_size number,
  p_trace boolean,
  p_read_cfig_options boolean,
  p_job_status_table varchar2,
  p_max_round number,
  p_update_dlog_lookup_table varchar2,
  p_dlog_has_data boolean,
  p_sleep_time number,
  p_parallel_drill_down boolean
  ) return boolean is
l_fact_audit varchar2(2);
l_net_change varchar2(2);
l_debug varchar2(2);
l_duplicate_collect varchar2(2);
l_execute_flag varchar2(2);
l_temp_log varchar2(2);
l_explain_plan_check varchar2(2);
l_fresh_restart varchar2(2);
l_smart_update varchar2(2);
l_log_dang_keys varchar2(2);
l_create_parent_table_records varchar2(2);
l_check_fk_change varchar2(2);
l_dlog_has_data varchar2(2);
l_skip_cols_table varchar2(80);
l_skip_levels_table varchar2(80);
l_smart_update_table varchar2(80);
l_trace varchar2(2);
l_read_cfig_options varchar2(2);
l_da_cols_table varchar2(80);
l_parallel_drill_down varchar2(10);
Begin
  if g_debug then
    write_to_log_file_n('In create_load_input_table ');
  end if;
  l_skip_cols_table:=p_table_name||'_SC';
  l_skip_levels_table:=p_table_name||'_SL';
  l_smart_update_table:=p_table_name||'_SU';
  l_da_cols_table:=p_table_name||'_DC';
  if drop_table(p_table_name)=false then
    null;
  end if;
  if drop_table(l_skip_cols_table)=false then
    null;
  end if;
  if drop_table(l_skip_levels_table)=false then
    null;
  end if;
  if drop_table(l_smart_update_table)=false then
    null;
  end if;
  if drop_table(l_da_cols_table)=false then
    null;
  end if;
  g_stmt:='create table '||p_table_name||'('||
  'object_name varchar2(80),'||
  'mapping_id number,'||
  'map_type varchar2(80),'||
  'primary_src number,'||
  'primary_target number,'||
  'primary_target_name varchar2(80),'||
  'object_type varchar2(80),'||
  'conc_id number,'||
  'conc_program_name varchar2(80),'||
  'fact_audit varchar2(2),'||
  'net_change varchar2(2),'||
  'fact_audit_name varchar2(80),'||
  'net_change_name varchar2(80),'||
  'fact_audit_is_name varchar2(80),'||
  'net_change_is_name varchar2(80),'||
  'debug varchar2(2),'||
  'duplicate_collect varchar2(2),'||
  'execute_flag varchar2(2),'||
  'request_id number,'||
  'collection_size number,'||
  'parallel number,'||
  'table_owner varchar2(80),'||
  'bis_owner  varchar2(80),'||
  'temp_log varchar2(2),'||
  'forall_size number,'||
  'update_type varchar2(80),'||
  'p_mode varchar2(80),'||
  'explain_plan_check varchar2(2),'||
  'fact_dlog varchar2(80),'||
  'key_set number,'||
  'instance_type varchar2(80),'||
  'load_pk number,'||
  'fresh_restart varchar2(2),'||
  'op_table_space varchar2(80),'||
  'da_table varchar2(80),'||
  'pp_table varchar2(80),'||
  'master_instance varchar2(80),'||
  'rollback varchar2(80),'||
  'smart_update varchar2(2),'||
  'fk_use_nl number,'||
  'fact_smart_update number,'||
  'auto_dang_table_extn varchar2(80),'||
  'log_dang_keys varchar2(2),'||
  'create_parent_table_records varchar2(2),'||
  'check_fk_change varchar2(2),'||
  'stg_join_nl_percentage number,'||
  'ok_switch_update number,'||
  'stg_make_copy_percentage number,'||
  'ok_table varchar2(80),'||
  'hash_area_size number,'||
  'sort_area_size number,'||
  'trace_mode varchar2(2),'||
  'read_cfig_options varchar2(2),'||
  'job_status_table varchar2(80),'||
  'max_round number,'||
  'update_dlog_lookup_table varchar2(80),'||
  'dlog_has_data varchar2(2),'||
  'total_records number,'||
  'stg_copy_table_flag varchar2(10),'||
  'sleep_time number,'||
  'parallel_drill_down varchar2(10)'||
  ') tablespace '||p_op_table_space;
  if g_debug then
    write_to_log_file_n('Going to execute '||g_stmt||' '||get_time);
  end if;
  execute immediate g_stmt;
  l_fact_audit:='N';
  l_net_change:='N';
  l_debug:='N';
  l_duplicate_collect:='N';
  l_execute_flag:='N';
  l_temp_log:='N';
  l_explain_plan_check:='N';
  l_fresh_restart:='N';
  l_smart_update:='N';
  l_log_dang_keys:='N';
  l_create_parent_table_records:='N';
  l_check_fk_change:='N';
  l_trace:='N';
  l_read_cfig_options:='N';
  l_dlog_has_data:='N';
  l_parallel_drill_down:='N';
  if p_fact_audit then
    l_fact_audit:='Y';
  end if;
  if p_net_change then
    l_net_change:='Y';
  end if;
  if p_debug then
    l_debug:='Y';
  end if;
  if p_duplicate_collect then
    l_duplicate_collect:='Y';
  end if;
  if p_execute_flag then
    l_execute_flag:='Y';
  end if;
  if p_temp_log then
    l_temp_log:='Y';
  end if;
  if p_explain_plan_check then
    l_explain_plan_check:='Y';
  end if;
  if p_fresh_restart then
    l_fresh_restart:='Y';
  end if;
  if p_smart_update then
    l_smart_update:='Y';
  end if;
  if p_log_dang_keys then
    l_log_dang_keys:='Y';
  end if;
  if p_create_parent_table_records then
    l_create_parent_table_records:='Y';
  end if;
  if p_check_fk_change then
    l_check_fk_change:='Y';
  end if;
  if p_trace then
    l_trace:='Y';
  end if;
  if p_read_cfig_options then
    l_read_cfig_options:='Y';
  end if;
  if p_dlog_has_data then
    l_dlog_has_data:='Y';
  end if;
  if p_parallel_drill_down then
    l_parallel_drill_down:='Y';
  end if;
  g_stmt:='insert into '||p_table_name||'('||
  'object_name,'||
  'mapping_id,'||
  'map_type,'||
  'primary_src ,'||
  'primary_target ,'||
  'primary_target_name,'||
  'object_type,'||
  'conc_id ,'||
  'conc_program_name,'||
  'fact_audit,'||
  'net_change,'||
  'fact_audit_name,'||
  'net_change_name,'||
  'fact_audit_is_name,'||
  'net_change_is_name,'||
  'debug,'||
  'duplicate_collect,'||
  'execute_flag,'||
  'request_id ,'||
  'collection_size ,'||
  'parallel ,'||
  'table_owner,'||
  'bis_owner ,'||
  'temp_log,'||
  'forall_size ,'||
  'update_type,'||
  'p_mode,'||
  'explain_plan_check,'||
  'fact_dlog,'||
  'key_set ,'||
  'instance_type,'||
  'load_pk ,'||
  'fresh_restart,'||
  'op_table_space,'||
  'da_table,'||
  'pp_table,'||
  'master_instance,'||
  'rollback,'||
  'smart_update,'||
  'fk_use_nl ,'||
  'fact_smart_update ,'||
  'auto_dang_table_extn,'||
  'log_dang_keys,'||
  'create_parent_table_records,'||
  'check_fk_change,'||
  'stg_join_nl_percentage ,'||
  'ok_switch_update ,'||
  'stg_make_copy_percentage,'||
  'ok_table, '||
  'hash_area_size,'||
  'sort_area_size,'||
  'trace_mode,'||
  'read_cfig_options, '||
  'job_status_table, '||
  'max_round,'||
  'update_dlog_lookup_table,'||
  'dlog_has_data,'||
  'sleep_time,'||
  'parallel_drill_down'||
  ') values ('||
  ':1,:2,:3,:4,:5,:6,:7,:8,:9,:10,'||
  ':11,:12,:13,:14,:15,:16,:17,:18,:19,:20,'||
  ':21,:22,:23,:24,:25,:26,:27,:28,:29,:30,'||
  ':31,:32,:33,:34,:35,:36,:37,:38,:39,:40,'||
  ':41,:42,:43,:44,:45,:46,:47,:48,:49,:50,'||
  ':51,:52,:53,:54,:55,:56,:57,:58,:59)';
  if g_debug then
    write_to_log_file_n('Going to execute '||g_stmt||' '||get_time);
  end if;
  execute immediate g_stmt using
  p_object_name ,
  p_mapping_id ,
  p_map_type ,
  p_primary_src ,
  p_primary_target ,
  p_primary_target_name ,
  p_object_type ,
  p_conc_id ,
  p_conc_program_name ,
  l_fact_audit ,
  l_net_change ,
  p_fact_audit_name ,
  p_net_change_name ,
  p_fact_audit_is_name ,
  p_net_change_is_name ,
  l_debug ,
  l_duplicate_collect ,
  l_execute_flag ,
  p_request_id ,
  p_collection_size ,
  p_parallel ,
  p_table_owner ,
  p_bis_owner  ,
  l_temp_log ,
  p_forall_size ,
  p_update_type ,
  p_mode ,
  l_explain_plan_check ,
  p_fact_dlog ,
  p_key_set ,
  p_instance_type ,
  p_load_pk ,
  l_fresh_restart ,
  p_op_table_space ,
  p_da_table ,
  p_pp_table ,
  p_master_instance ,
  p_rollback ,
  l_smart_update ,
  p_fk_use_nl ,
  p_fact_smart_update ,
  p_auto_dang_table_extn ,
  l_log_dang_keys ,
  l_create_parent_table_records ,
  l_check_fk_change ,
  p_stg_join_nl_percentage ,
  p_ok_switch_update ,
  p_stg_make_copy_percentage,
  p_ok_table,
  p_hash_area_size,
  p_sort_area_size,
  l_trace,
  l_read_cfig_options,
  p_job_status_table,
  p_max_round,
  p_update_dlog_lookup_table,
  l_dlog_has_data,
  p_sleep_time,
  l_parallel_drill_down;
  commit;
  g_stmt:='create table '||l_skip_cols_table||'('||
  'col_name varchar2(80)) tablespace '||p_op_table_space;
  if g_debug then
    write_to_log_file_n('Going to execute '||g_stmt||' '||get_time);
  end if;
  execute immediate g_stmt;
  if p_number_skip_cols>0 then
    g_stmt:='insert into '||l_skip_cols_table||'(col_name) values(:1)';
    if g_debug then
      write_to_log_file_n('Going to execute '||g_stmt||' '||get_time);
    end if;
    for i in 1..p_number_skip_cols loop
      execute immediate g_stmt using p_skip_cols(i);
    end loop;
  end if;
  commit;
  g_stmt:='create table '||l_skip_levels_table||'('||
  'col_name varchar2(80)) tablespace '||p_op_table_space;
  if g_debug then
    write_to_log_file_n('Going to execute '||g_stmt||' '||get_time);
  end if;
  execute immediate g_stmt;
  if p_number_skip_levels>0 then
    g_stmt:='insert into '||l_skip_levels_table||'(col_name) values(:1)';
    if g_debug then
      write_to_log_file_n('Going to execute '||g_stmt||' '||get_time);
    end if;
    for i in 1..p_number_skip_levels loop
      execute immediate g_stmt using p_skip_levels(i);
    end loop;
  end if;
  commit;
  g_stmt:='create table '||l_smart_update_table||'('||
  'col_name varchar2(80)) tablespace '||p_op_table_space;
  if g_debug then
    write_to_log_file_n('Going to execute '||g_stmt||' '||get_time);
  end if;
  execute immediate g_stmt;
  if p_number_smart_update_cols>0 then
    g_stmt:='insert into '||l_smart_update_table||'(col_name) values(:1)';
    if g_debug then
      write_to_log_file_n('Going to execute '||g_stmt||' '||get_time);
    end if;
    for i in 1..p_number_smart_update_cols loop
      execute immediate g_stmt using p_smart_update_cols(i);
    end loop;
  end if;
  commit;
  g_stmt:='create table '||l_da_cols_table||'('||
  'col_name varchar2(80),stg_col_name varchar2(80)) tablespace '||p_op_table_space;
  if g_debug then
    write_to_log_file_n('Going to execute '||g_stmt||' '||get_time);
  end if;
  execute immediate g_stmt;
  if p_number_da_cols>0 then
    g_stmt:='insert into '||l_da_cols_table||'(col_name) values(:1)';
    if g_debug then
      write_to_log_file_n('Going to execute '||g_stmt||' '||get_time);
    end if;
    for i in 1..p_number_da_cols loop
      execute immediate g_stmt using p_da_cols(i);
    end loop;
  end if;
  commit;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in create_load_input_table '||g_status_message);
  return false;
End;

function create_da_load_input_table(
p_da_cols_table varchar2,
p_op_table_space varchar2,
p_da_cols EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_stg_da_cols EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_number_da_cols number
) return boolean is
Begin
  if g_debug then
    write_to_log_file_n('In create_da_load_input_table ');
  end if;
  if drop_table(p_da_cols_table)=false then
    null;
  end if;
  g_stmt:='create table '||p_da_cols_table||'('||
  'col_name varchar2(80),stg_col_name varchar2(80)) tablespace '||p_op_table_space;
  if g_debug then
    write_to_log_file_n('Going to execute '||g_stmt||' '||get_time);
  end if;
  execute immediate g_stmt;
  if p_number_da_cols>0 then
    g_stmt:='insert into '||p_da_cols_table||'(col_name,stg_col_name) values(:1,:2)';
    if g_debug then
      write_to_log_file_n('Going to execute '||g_stmt||' '||get_time);
    end if;
    for i in 1..p_number_da_cols loop
      execute immediate g_stmt using p_da_cols(i),p_stg_da_cols(i);
    end loop;
  end if;
  commit;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in create_load_input_table '||g_status_message);
  return false;
End;

function update_load_input_table(
  p_table_name varchar2,
  p_ok_table varchar2,
  p_max_round number,
  p_update_dlog_lookup_table varchar2,
  p_dlog_has_data boolean,
  p_total_records number,
  p_stg_copy_table_flag boolean
)return boolean is
l_dlog_has_data varchar2(10);
l_stg_copy_table_flag varchar2(10);
Begin
  if g_debug then
    write_to_log_file_n('In update_load_input_table ');
  end if;
  l_dlog_has_data:='N';
  l_stg_copy_table_flag:='N';
  if p_dlog_has_data then
    l_dlog_has_data:='Y';
  end if;
  if p_stg_copy_table_flag then
    l_stg_copy_table_flag:='Y';
  end if;
  g_stmt:='update '||p_table_name||' set ok_table=:1,max_round=:2,update_dlog_lookup_table=:3,dlog_has_data=:4,'||
  'total_records=:5,stg_copy_table_flag=:6';
  if g_debug then
    write_to_log_file_n('Going to execute '||g_stmt||' using '||p_ok_table||' '||p_max_round||' '||
    p_update_dlog_lookup_table||' '||l_dlog_has_data||' '||p_total_records||' '||l_stg_copy_table_flag);
  end if;
  execute immediate g_stmt using p_ok_table,p_max_round,p_update_dlog_lookup_table,l_dlog_has_data,
  p_total_records,l_stg_copy_table_flag;
  commit;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in update_load_input_table '||g_status_message);
  return false;
End;

function check_job_status(p_job_id number) return varchar2 is
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_var number;
Begin
  g_stmt:='select 1 from all_jobs where job=:1';
  open cv for g_stmt using p_job_id;
  fetch cv into l_var;
  close cv;
  if l_var=1 then
    return 'Y';--job running
  else
    return 'N';
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in check_job_status '||g_status_message);
  return null;
End;

function get_job_execute_time(p_job_id number) return varchar2 is
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_var number;
Begin
  g_stmt:='select total_time from all_jobs where job=:1';
  open cv for g_stmt using p_job_id;
  fetch cv into l_var;
  close cv;
  return l_var;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_job_execute_time '||g_status_message);
  return null;
End;

function wait_on_jobs(
p_job_id number,
p_sleep_time number,
p_thread_type varchar2
) return boolean is
--
l_job_id numberTableType;
l_number_jobs number;
--
Begin
  l_number_jobs:=1;
  l_job_id(1):=p_job_id;
  if wait_on_jobs(l_job_id,l_number_jobs,p_sleep_time,p_thread_type)=false then
    return false;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in wait_on_jobs '||g_status_message);
  return false;
End;
function wait_on_jobs(
p_job_id numberTableType,
p_number_jobs number,
p_sleep_time number,
p_thread_type varchar2
) return boolean is
l_found boolean;
l_status varchar2(2);
l_job_status varcharTableType;
Begin
  if g_debug then
    write_to_log_file_n('In wait_on_jobs sleep time='||p_sleep_time||' theread type='||p_thread_type);
  end if;
  if p_number_jobs<=0 then
    return true;
  end if;
  for i in 1..p_number_jobs loop
    l_job_status(i):='Y';
  end loop;
  loop
    l_found:=false;
    DBMS_LOCK.SLEEP(p_sleep_time);
    for i in 1..p_number_jobs loop
      if l_job_status(i)='Y' then
        if p_thread_type='JOB' then
          l_status:=check_job_status(p_job_id(i));
        else
          l_status:=check_conc_process_status(p_job_id(i));
        end if;
      end if;
      if l_status is null then
        return false;
      elsif l_status='Y' then
        l_found:=true;
      else
        if l_job_status(i)='Y' then
          if g_debug then
            write_to_log_file_n('Job '||p_job_id(i)||' has terminated '||get_time);
          end if;
          l_job_status(i):='N';
        end if;
      end if;
    end loop;
    if l_found=false then
      exit;
    end if;
  end loop;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in wait_on_jobs '||g_status_message);
  return false;
End;

function terminate_jobs(
p_job_id numberTableType,
p_number_jobs number
)return boolean is
l_sid number;
l_serial number;
Begin
  if p_number_jobs<=0 then
    return true;
  end if;
  for i in 1..p_number_jobs loop
    if terminate_job(p_job_id(i))=false then
      return false;
    end if;
  end loop;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in terminate_jobs '||g_status_message);
  return false;
End;

function terminate_job(p_job_id number) return boolean is
l_sid number;
l_serial number;
Begin
  if p_job_id is not null then
    l_sid:=get_sid_for_job(p_job_id);
    if l_sid is not null then
      if get_session_parameters(l_sid,l_serial) then
        if kill_session(l_sid,l_serial)=false then
          if g_debug then
            write_to_log_file_n('Could not kill job='||p_job_id||' sid='||l_sid||' serial='||l_serial);
          end if;
        end if;
      end if;
    end if;
    if remove_job(p_job_id)=false then
      if g_debug then
        write_to_log_file_n('Could not remove job '||p_job_id);
      end if;
    end if;
    if g_debug then
      write_to_log_file_n('Job '||p_job_id||' terminate '||get_time);
    end if;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in terminate_jobs '||g_status_message);
  return false;
End;

function get_sid_for_job(p_job_id number) return number is
l_sid number;
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  g_stmt:='SELECT lock_table.SID FROM V$LOCK lock_table WHERE lock_table.TYPE=''JQ'' and lock_table.ID2=:1';
  if g_debug then
    write_to_log_file_n(g_stmt||' '||p_job_id);
  end if;
  open cv for g_stmt using p_job_id;
  fetch cv into l_sid;
  close cv;
  return l_sid;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_sid_for_job '||g_status_message);
  return null;
End;

function get_session_parameters(
p_sid number,
p_serial out nocopy number
) return boolean is
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  g_stmt:='select ses.SERIAL# from v$session ses where ses.SID=:1';
  if g_debug then
    write_to_log_file_n(g_stmt||' '||p_sid);
  end if;
  open cv for g_stmt using p_sid;
  fetch cv into p_serial;
  close cv;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_session_parameters '||g_status_message);
  return false;
End;

function kill_session(
p_sid number,
p_serial number
)return boolean is
Begin
  g_stmt:='alter system kill session '''||p_sid||','||p_serial||'''';
  if g_debug then
    write_to_log_file_n(g_stmt);
  end if;
  execute immediate g_stmt;
  commit;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in kill_session '||g_status_message);
  return false;
End;

function remove_job(p_job_id number) return boolean is
Begin
  DBMS_JOB.REMOVE(p_job_id);
  commit;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in remove_job '||g_status_message);
  return false;
End;

procedure dummy_proc is
Begin
  null;
End;

function find_ok_distribution(
p_ok_table varchar2,
p_table_owner varchar2,
p_max_threads number,
p_min_job_load_size number,
p_ok_low_end out NOCOPY EDW_OWB_COLLECTION_UTIL.numberTableType,
p_ok_high_end out NOCOPY EDW_OWB_COLLECTION_UTIL.numberTableType,
p_ok_end_count out NOCOPY integer
) return boolean is
l_ok_size number;
l_chunk_size integer;
l_running_count integer;
Begin
  if g_debug then
    write_to_log_file_n('In find_ok_distribution');
  end if;
  --bug 3472891. we have to change get_table_count_stats to get_table_count
  l_ok_size:=get_table_count(p_ok_table);
  if g_debug then
    write_to_log_file_n('l_ok_size='||l_ok_size);
  end if;
  p_ok_end_count:=0;
  if l_ok_size<=p_min_job_load_size then
    p_ok_end_count:=1;
    p_ok_low_end(p_ok_end_count):=1;
    p_ok_high_end(p_ok_end_count):=l_ok_size;
  else
    if (p_min_job_load_size*p_max_threads) > l_ok_size then
      p_ok_end_count:=trunc(l_ok_size/p_min_job_load_size);
      l_chunk_size:=p_min_job_load_size;
    else
      p_ok_end_count:=p_max_threads;
      l_chunk_size:=trunc(l_ok_size/p_max_threads);
    end if;
    if g_debug then
      write_to_log_file_n('p_ok_end_count='||p_ok_end_count);
      write_to_log_file_n('l_chunk_size='||l_chunk_size);
    end if;
    l_running_count:=0;
    for i in 1..p_ok_end_count loop
      if i=1 then
        p_ok_low_end(i):=1;
      else
        p_ok_low_end(i):=p_ok_high_end(i-1)+1;
      end if;
      if i=p_ok_end_count then
        p_ok_high_end(i):=l_ok_size;
      else
        p_ok_high_end(i):=i*l_chunk_size;
      end if;
    end loop;
    if g_debug then
      write_to_log_file_n('The low and high ends');
      for i in 1..p_ok_end_count loop
        write_to_log_file(p_ok_low_end(i)||' '||p_ok_high_end(i));
      end loop;
    end if;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

function create_job_status_table(
p_table varchar2,
p_op_table_space varchar2
) return boolean is
Begin
  g_stmt:='create table '||p_table||'(object_name varchar2(100),id number,job_id number,status varchar2(40),'||
  'message varchar2(4000),measure1 number,measure2 number,measure3 number,measure4 number,measure5 number) '||
  'tablespace '||p_op_table_space;
  if g_debug then
    write_to_log_file_n(g_stmt);
  end if;
  if drop_table(p_table)=false then
    null;
  end if;
  execute immediate g_stmt;
  if g_debug then
    write_to_log_file_n('Table created');
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

function get_join_nl(
p_load_size number,
p_total_records number,
p_cut_off_percentage number
) return boolean is
l_percentage number;
l_stg_join_nl boolean;
Begin
  if g_debug then
    write_to_log_file_n('In get_join_nl '||p_load_size||' '||p_total_records||' '||p_cut_off_percentage);
  end if;
  l_stg_join_nl:=true;
  if p_cut_off_percentage=0 then
    l_stg_join_nl:=false;
    if g_debug then
      write_to_log_file_n('l_stg_join_nl made FALSE');
    end if;
  elsif p_cut_off_percentage=100 then
    l_stg_join_nl:=true;
    if g_debug then
      write_to_log_file_n('l_stg_join_nl made TRUE');
    end if;
  else
    if p_load_size>0 then
      if p_total_records>0 then
        l_percentage:=round(100*(p_load_size/p_total_records));
        if g_debug then
          write_to_log_file_n('l_percentage='||l_percentage);
        end if;
        if l_percentage<=p_cut_off_percentage then
          l_stg_join_nl:=true;
          if g_debug then
            write_to_log_file_n('l_stg_join_nl made TRUE');
          end if;
        else
          l_stg_join_nl:=false;
          if g_debug then
            write_to_log_file_n('l_stg_join_nl made FALSE');
          end if;
        end if;
      end if;
    end if;
  end if;
  return l_stg_join_nl;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_join_nl '||g_status_message);
  return false;
End;

function log_into_job_status_table(
p_table varchar2,
p_object_name varchar2,
p_id number,
p_status varchar2,
p_message varchar2
)return boolean is
Begin
  if g_debug then
    write_to_log_file_n('In log_into_job_status_table '||p_table);
  end if;
  if log_into_job_status_table(p_table,p_object_name,p_id,p_status,p_message,null,null,null,null,null)=false then
    return false;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in log_into_job_status_table '||g_status_message);
  return false;
End;

function log_into_job_status_table(
p_table varchar2,
p_object_name varchar2,
p_id number,
p_status varchar2,
p_message varchar2,
p_measure1 number,
p_measure2 number,
p_measure3 number,
p_measure4 number,
p_measure5 number
)return boolean is
Begin
  g_stmt:='insert into '||p_table||'(object_name,id,status,message,measure1,measure2,measure3,measure4,measure5) '||
  'values(:1,:2,:3,:4,:5,:6,:7,:8,:9)';
  if g_debug then
    write_to_log_file_n(g_stmt||' '||p_object_name||' '||p_id||' '||p_status||' '||p_message||' '||
    p_measure1||' '||p_measure2||' '||p_measure3||' '||p_measure4||' '||p_measure5);
  end if;
  execute immediate g_stmt using p_object_name,p_id,p_status,p_message,p_measure1,p_measure2,p_measure3,
  p_measure4,p_measure5;
  commit;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in log_into_job_status_table '||g_status_message);
  return false;
End;

function check_all_child_jobs(
p_job_status_table varchar2,
p_job_id numberTableType,
p_number_jobs number,
p_object_name varchar2
) return boolean is
l_id numberTableType;
l_job_id numberTableType;
l_status varcharTableType;
l_message varcharTableType;
l_number_jobs number;
Begin
  if get_child_job_status(
    p_job_status_table,
    p_object_name,
    l_id,
    l_job_id,
    l_status,
    l_message,
    l_number_jobs)=false then
    return false;
  end if;
  for i in 1..l_number_jobs loop
    if l_status(i)='ERROR' then
      return false;
    end if;
  end loop;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in check_all_child_jobs '||g_status_message);
  return false;
End;

function get_child_job_status(
p_job_status_table varchar2,
p_object_name varchar2,
p_id out nocopy numberTableType,
p_job_id out nocopy numberTableType,
p_status out nocopy varcharTableType,
p_message out nocopy varcharTableType,
p_number_jobs out nocopy number
)return boolean is
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  if p_object_name is null then
    g_stmt:='select id,job_id,status,message from '||p_job_status_table;
  else
    g_stmt:='select id,job_id,status,message from '||p_job_status_table||' where object_name=:1';
  end if;
  p_number_jobs:=1;
  if g_debug then
    write_to_log_file_n(g_stmt||' '||p_object_name);
  end if;
  if p_object_name is null then
    open cv for g_stmt;
  else
    open cv for g_stmt using p_object_name;
  end if;
  loop
    fetch cv into p_id(p_number_jobs),p_job_id(p_number_jobs),
    p_status(p_number_jobs),p_message(p_number_jobs);
    exit when cv%notfound;
    p_number_jobs:=p_number_jobs+1;
  end loop;
  close cv;
  p_number_jobs:=p_number_jobs-1;
  if g_debug then
    write_to_log_file_n('The job status');
    for i in 1..p_number_jobs loop
      write_to_log_file(p_id(i)||' '||p_job_id(i)||' '||p_status(i)||' '||p_message(i));
    end loop;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_child_job_status '||g_status_message);
  return false;
End;

function create_dim_load_input_table(
    p_dim_name varchar2,
    p_table varchar2,
    p_conc_id number,
    p_conc_name varchar2,
    p_levels varcharTableType,
    p_child_level_number numberTableType,
    p_child_levels varcharTableType,
    p_child_fk varcharTableType,
    p_parent_pk varcharTableType,
    p_level_snapshot_logs varcharTableType,
    p_number_levels number,
    p_debug boolean,
    p_exec_flag boolean,
    p_bis_owner varchar2,
    p_parallel number,
    p_collection_size number,
    p_table_owner varchar2,
    p_forall_size number,
    p_update_type varchar2,
    p_level_order varcharTableType,
    p_skip_cols varcharTableType,
    p_number_skip_cols number,
    p_load_pk number,
    p_fresh_restart boolean,
    p_op_table_space varchar2,
    p_rollback varchar2,
    p_ltc_merge_use_nl boolean,
    p_dim_inc_refresh_derv boolean,
    p_check_fk_change boolean,
    p_ok_switch_update number,
    p_join_nl_percentage number,
    p_max_threads number,
    p_min_job_load_size number,
    p_sleep_time number,
    p_job_status_table varchar2,
    p_hash_area_size number,
    p_sort_area_size number,
    p_trace boolean,
    p_read_cfig_options boolean,
    p_max_fk_density number
    ) return boolean is
l_debug varchar2(2);
l_exec_flag varchar2(2);
l_fresh_restart varchar2(2);
l_ltc_merge_use_nl varchar2(2);
l_dim_inc_refresh_derv varchar2(2);
l_check_fk_change varchar2(2);
l_trace varchar2(2);
l_read_cfig_options varchar2(2);
l_level_table varchar2(80);
l_level_child_table varchar2(80);
l_skip_table varchar2(80);
l_run number;
Begin
  if g_debug then
    write_to_log_file_n('In create_dim_load_input_table ');
  end if;
  l_level_table:=p_table||'_LT';
  l_level_child_table:=p_table||'_CT';
  l_skip_table:=p_table||'_SK';
  g_stmt:='create table '||p_table||'('||
  'conc_id number,'||
  'conc_name varchar2(200),'||
  'debug varchar2(2),'||
  'exec_flag varchar2(2),'||
  'bis_owner varchar2(200),'||
  'parallel number,'||
  'collection_size number,'||
  'table_owner varchar2(200),'||
  'forall_size number,'||
  'update_type varchar2(200),'||
  'load_pk number,'||
  'fresh_restart varchar2(2),'||
  'op_table_space varchar2(200),'||
  'rollback varchar2(200),'||
  'ltc_merge_use_nl varchar2(2),'||
  'dim_inc_refresh_derv varchar2(2),'||
  'check_fk_change varchar2(2),'||
  'ok_switch_update number,'||
  'join_nl_percentage number,'||
  'max_threads number,'||
  'min_job_load_size number,'||
  'sleep_time number,'||
  'job_status_table varchar2(200),'||
  'hash_area_size number,'||
  'sort_area_size number,'||
  'trace varchar2(2),'||
  'read_cfig_options varchar2(2),'||
  'ilog_table  varchar2(80),'||
  'skip_ilog_update varchar2(2),'||
  'level_change varchar2(2),'||
  'dim_empty_flag varchar2(2),'||
  'before_update_table_final varchar2(80),'||
  'error_rec_flag varchar2(2),'||
  'max_fk_density number'||
  ') tablespace '||p_op_table_space;
  if drop_table(p_table)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n(g_stmt);
  end if;
  execute immediate g_stmt;
  g_stmt:='create table '||l_level_table||'('||
  'level_number number,'||
  'levels varchar2(200),'||
  'child_level_number number,'||
  'level_snapshot_logs varchar2(200),'||
  'level_order varchar2(200),'||
  'consider_snapshot varchar2(2),'||
  'levels_I varchar2(80),'||
  'use_ltc_ilog varchar2(2)'||
  ') tablespace '||p_op_table_space;
  if drop_table(l_level_table)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n(g_stmt);
  end if;
  execute immediate g_stmt;
  g_stmt:='create table '||l_level_child_table||'('||
  'run_number number,'||
  'child_levels varchar2(200),'||
  'child_fk varchar2(200),'||
  'parent_pk varchar2(200)'||
  ') tablespace '||p_op_table_space;
  if drop_table(l_level_child_table)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n(g_stmt);
  end if;
  execute immediate g_stmt;
  g_stmt:='create table '||l_skip_table||'('||
  'skip_cols varchar2(200)'||
  ') tablespace '||p_op_table_space;
  if drop_table(l_skip_table)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n(g_stmt);
  end if;
  execute immediate g_stmt;
  l_debug:='N';
  l_exec_flag:='N';
  l_fresh_restart:='N';
  l_ltc_merge_use_nl:='N';
  l_dim_inc_refresh_derv:='N';
  l_check_fk_change:='N';
  l_trace:='N';
  l_read_cfig_options:='N';
  if g_debug then
    l_debug:='Y';
  end if;
  if p_exec_flag then
    l_exec_flag:='Y';
  end if;
  if p_fresh_restart then
    l_fresh_restart:='Y';
  end if;
  if p_ltc_merge_use_nl then
    l_ltc_merge_use_nl:='Y';
  end if;
  if p_dim_inc_refresh_derv then
    l_dim_inc_refresh_derv:='Y';
  end if;
  if p_check_fk_change then
    l_check_fk_change:='Y';
  end if;
  if p_trace then
    l_trace:='Y';
  end if;
  if p_read_cfig_options then
    l_read_cfig_options:='Y';
  end if;
  g_stmt:='insert into '||p_table||'('||
  'conc_id, '||
  'conc_name,'||
  'debug,'||
  'exec_flag,'||
  'bis_owner,'||
  'parallel,'||
  'collection_size,'||
  'table_owner,'||
  'forall_size,'||
  'update_type,'||
  'load_pk,'||
  'fresh_restart,'||
  'op_table_space,'||
  'rollback,'||
  'ltc_merge_use_nl,'||
  'dim_inc_refresh_derv,'||
  'check_fk_change,'||
  'ok_switch_update,'||
  'join_nl_percentage,'||
  'max_threads,'||
  'min_job_load_size,'||
  'sleep_time,'||
  'job_status_table,'||
  'hash_area_size,'||
  'sort_area_size,'||
  'trace,'||
  'read_cfig_options,'||
  'max_fk_density'||
  ') values ('||
  ':1,:2,:3,:4,:5,:6,:7,:8,:9,:10,'||
  ':11,:12,:13,:14,:15,:16,:17,:18,:19,:20,'||
  ':21,:22,:23,:24,:25,:26,:27,:28'||
  ')';
  if g_debug then
    write_to_log_file_n('Going to execute '||g_stmt||' '||get_time);
  end if;
  /*
  write_to_log_file('p_conc_id='||p_conc_id);
  write_to_log_file('p_conc_name='||p_conc_name);
  write_to_log_file('l_debug='||l_debug);
  write_to_log_file('l_exec_flag='||l_exec_flag);
  write_to_log_file('p_bis_owner='||p_bis_owner);
  write_to_log_file('p_parallel='||p_parallel);
  write_to_log_file('p_collection_size='||p_collection_size);
  write_to_log_file('p_table_owner='||p_table_owner);
  write_to_log_file('p_forall_size='||p_forall_size);
  write_to_log_file('p_update_type='||p_update_type);
  write_to_log_file('p_load_pk='||p_load_pk);
  write_to_log_file('l_fresh_restart='||l_fresh_restart);
  write_to_log_file('p_op_table_space='||p_op_table_space);
  write_to_log_file('p_rollback='||p_rollback);
  write_to_log_file('l_ltc_merge_use_nl='||l_ltc_merge_use_nl);
  write_to_log_file('l_dim_inc_refresh_derv='||l_dim_inc_refresh_derv);
  write_to_log_file('l_check_fk_change='||l_check_fk_change);
  write_to_log_file('p_ok_switch_update='||p_ok_switch_update);
  write_to_log_file('p_join_nl_percentage='||p_join_nl_percentage);
  write_to_log_file('p_max_threads='||p_max_threads);
  write_to_log_file('p_min_job_load_size='||p_min_job_load_size);
  write_to_log_file('p_sleep_time='||p_sleep_time);
  write_to_log_file('p_job_status_table='||p_job_status_table);
  write_to_log_file('p_hash_area_size='||p_hash_area_size);
  write_to_log_file('p_sort_area_size='||p_sort_area_size);
  write_to_log_file('l_trace='||l_trace);
  write_to_log_file('l_read_cfig_options='||l_read_cfig_options);*/
  execute immediate g_stmt using
  p_conc_id,
  p_conc_name,
  l_debug,
  l_exec_flag,
  p_bis_owner,
  p_parallel,
  p_collection_size,
  p_table_owner,
  p_forall_size,
  p_update_type,
  p_load_pk,
  l_fresh_restart,
  p_op_table_space,
  p_rollback,
  l_ltc_merge_use_nl,
  l_dim_inc_refresh_derv,
  l_check_fk_change,
  p_ok_switch_update,
  p_join_nl_percentage,
  p_max_threads,
  p_min_job_load_size,
  p_sleep_time,
  p_job_status_table,
  p_hash_area_size,
  p_sort_area_size,
  l_trace,
  l_read_cfig_options,
  p_max_fk_density;
  commit;
  g_stmt:='insert into '||l_level_table||'('||
  'level_number,'||
  'levels,'||
  'child_level_number,'||
  'level_snapshot_logs,'||
  'level_order'||
  ') values('||
  ':1,:2,:3,:4,:5'||
  ')';
  if g_debug then
    write_to_log_file_n('Going to execute '||g_stmt||' '||get_time);
  end if;
  for i in 1..p_number_levels loop
    execute immediate g_stmt using i,p_levels(i),p_child_level_number(i),
    p_level_snapshot_logs(i),p_level_order(i);
  end loop;
  commit;
  g_stmt:='insert into '||l_level_child_table||'('||
  'run_number,'||
  'child_levels,'||
  'child_fk,'||
  'parent_pk'||
  ') values('||
  ':1,:2,:3,:4'||
  ')';
  if g_debug then
    write_to_log_file_n('Going to execute '||g_stmt||' '||get_time);
  end if;
  l_run:=0;
  for i in 1..p_number_levels loop
    for j in 1..p_child_level_number(i) loop
      l_run:=l_run+1;
      execute immediate g_stmt using l_run,p_child_levels(l_run),p_child_fk(l_run),p_parent_pk(l_run);
    end loop;
  end loop;
  commit;
  g_stmt:='insert into '||l_skip_table||'('||
  'skip_cols'||
  ') values('||
  ':1'||
  ')';
  if g_debug then
    write_to_log_file_n('Going to execute '||g_stmt||' '||get_time);
  end if;
  for i in 1..p_number_skip_cols loop
    execute immediate g_stmt using p_skip_cols(i);
  end loop;
  commit;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in create_dim_load_input_table '||g_status_message);
  return false;
End;

function update_dim_load_input_table(
p_input_table varchar2,
p_ilog_table varchar2,
p_skip_ilog_update boolean,
p_level_change boolean,
p_dim_empty_flag boolean,
p_before_update_table_final varchar2,
p_error_rec_flag boolean,
p_consider_snapshot booleanTableType,
p_levels_I varcharTableType,
p_use_ltc_ilog booleanTableType,
p_number_levels number
)return boolean is
l_skip_ilog_update varchar2(2);
l_level_change varchar2(2);
l_dim_empty_flag varchar2(2);
l_error_rec_flag varchar2(2);
l_use_ltc_ilog varchar2(2);
l_level_table varchar2(80);
Begin
  if g_debug then
    write_to_log_file_n('In update_dim_load_input_table');
  end if;
  l_level_table:=p_input_table||'_LT';
  l_skip_ilog_update:='N';
  l_level_change:='N';
  l_dim_empty_flag:='N';
  l_error_rec_flag:='N';
  if p_skip_ilog_update then
    l_skip_ilog_update:='Y';
  end if;
  if p_level_change then
    l_level_change:='Y';
  end if;
  if p_dim_empty_flag then
    l_dim_empty_flag:='Y';
  end if;
  if p_error_rec_flag then
    l_error_rec_flag:='Y';
  end if;
  g_stmt:='update '||p_input_table||' set ilog_table=:1,skip_ilog_update=:2,level_change=:3,'||
  'dim_empty_flag=:4,before_update_table_final=:5,error_rec_flag=:6';
  if g_debug then
    write_to_log_file_n(g_stmt);
  end if;
  execute immediate g_stmt using p_ilog_table,l_skip_ilog_update,l_level_change,l_dim_empty_flag,
  p_before_update_table_final,l_error_rec_flag;
  commit;
  g_stmt:='update '||l_level_table||' set consider_snapshot=:1,levels_I=:2,use_ltc_ilog=:3 where level_number=:4';
  if g_debug then
    write_to_log_file_n(g_stmt);
  end if;
  for i in  1..p_number_levels loop
    if p_use_ltc_ilog(i) then
      l_use_ltc_ilog:='Y';
    else
      l_use_ltc_ilog:='N';
    end if;
    if p_consider_snapshot(i) then
      execute immediate g_stmt using 'Y',p_levels_I(i),l_use_ltc_ilog,i;
    else
      execute immediate g_stmt using 'N',p_levels_I(i),l_use_ltc_ilog,i;
    end if;
  end loop;
  commit;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in update_dim_load_input_table '||g_status_message);
  return false;
End;

function create_derv_fact_inp_table(
p_fact_name varchar2,
p_input_table varchar2,
p_fact_id number,
p_mapping_id number,
p_src_object varchar2,
p_src_object_id number,
p_fact_fks varcharTableType,
p_higher_level booleanTableType,
p_parent_dim varcharTableType,
p_parent_level varcharTableType,
p_level_prefix varcharTableType,
p_level_pk varcharTableType,
p_level_pk_key varcharTableType,
p_dim_pk_key varcharTableType,
p_number_fact_fks number,
p_conc_id number,
p_conc_program_name varchar2,
p_debug boolean,
p_collection_size number,
p_parallel number,
p_bis_owner varchar2,
p_table_owner  varchar2,
p_full_refresh boolean,
p_forall_size number,
p_update_type varchar2,
p_fact_dlog varchar2,
p_skip_cols varcharTableType,
p_number_skip_cols number,
p_load_fk number,
p_fresh_restart boolean,
p_op_table_space varchar2,
p_bu_tables varcharTableType,--before update tables.prop dim change to derv
p_bu_dimensions varcharTableType,
p_number_bu_tables number,
p_bu_src_fact varchar2,--what table to look at as the src fact. if null, scan full the src fact
p_load_mode varchar2,
p_rollback varchar2,
p_src_join_nl_percentage number,
p_max_threads number,
p_min_job_load_size number,
p_sleep_time number,
p_job_status_table varchar2,
p_hash_area_size number,
p_sort_area_size number,
p_trace boolean,
p_read_cfig_options boolean
) return boolean is
l_fk_table varchar2(80);
l_skip_table varchar2(80);
l_bu_table varchar2(80);
l_debug varchar2(2);
l_full_refresh varchar2(2);
l_fresh_restart varchar2(2);
l_trace varchar2(2);
l_read_cfig_options varchar2(2);
l_higher_level varchar2(2);
Begin
  if g_debug then
    write_to_log_file_n('In create_derv_fact_inp_table ');
  end if;
  l_fk_table:=p_input_table||'_FK';
  l_skip_table:=p_input_table||'_SK';
  l_bu_table:=p_input_table||'_BU';
  if drop_table(p_input_table)=false then
    null;
  end if;
  if drop_table(l_fk_table)=false then
    null;
  end if;
  if drop_table(l_skip_table)=false then
    null;
  end if;
  if drop_table(l_bu_table)=false then
    null;
  end if;
  g_stmt:='create table '||p_input_table||'('||
  'fact_id number,'||
  'mapping_id number,'||
  'src_object varchar2(80),'||
  'src_object_id number,'||
  'conc_id number,'||
  'conc_program_name varchar2(80),'||
  'debug varchar2(2),'||
  'collection_size number,'||
  'parallel number,'||
  'bis_owner varchar2(80),'||
  'table_owner  varchar2(80),'||
  'full_refresh varchar2(2),'||
  'forall_size number,'||
  'update_type varchar2(80),'||
  'fact_dlog varchar2(80),'||
  'load_fk number,'||
  'fresh_restart varchar2(2),'||
  'op_table_space varchar2(80),'||
  'bu_src_fact varchar2(80),'||
  'load_mode varchar2(80),'||
  'rollback varchar2(80),'||
  'src_join_nl_percentage number,'||
  'max_threads number,'||
  'min_job_load_size number,'||
  'sleep_time number,'||
  'job_status_table varchar2(80),'||
  'hash_area_size number,'||
  'sort_area_size number,'||
  'trace varchar2(2),'||
  'read_cfig_options varchar2(2),'||
  'ilog_table varchar2(80),'||
  'dlog_table varchar2(80),'||
  'skip_ilog_update varchar2(2),'||
  'skip_dlog_update varchar2(2),'||
  'skip_ilog varchar2(2),'||
  'src_object_ilog varchar2(80),'||
  'src_object_dlog varchar2(80),'||
  'src_snplog_has_pk varchar2(2),'||
  'err_rec_flag varchar2(2),'||
  'err_rec_flag_d varchar2(2),'||
  'dbms_job_id number '||
  ') tablespace '||p_op_table_space;
  if g_debug then
    write_to_log_file_n(g_stmt);
  end if;
  execute immediate g_stmt;
  l_debug:='N';
  l_full_refresh:='N';
  l_fresh_restart:='N';
  l_trace:='N';
  l_read_cfig_options:='N';
  if p_debug then
    l_debug:='Y';
  end if;
  if p_full_refresh then
    l_full_refresh:='Y';
  end if;
  if p_fresh_restart then
    l_fresh_restart:='Y';
  end if;
  if p_trace then
    l_trace:='Y';
  end if;
  if p_read_cfig_options then
    l_read_cfig_options:='Y';
  end if;
  g_stmt:='insert into '||p_input_table||'('||
  'fact_id,'||
  'mapping_id,'||
  'src_object,'||
  'src_object_id,'||
  'conc_id,'||
  'conc_program_name,'||
  'debug,'||
  'collection_size,'||
  'parallel,'||
  'bis_owner,'||
  'table_owner ,'||
  'full_refresh,'||
  'forall_size,'||
  'update_type,'||
  'fact_dlog,'||
  'load_fk,'||
  'fresh_restart,'||
  'op_table_space,'||
  'bu_src_fact,'||
  'load_mode,'||
  'rollback,'||
  'src_join_nl_percentage,'||
  'max_threads,'||
  'min_job_load_size,'||
  'sleep_time,'||
  'job_status_table,'||
  'hash_area_size,'||
  'sort_area_size,'||
  'trace,'||
  'read_cfig_options'||
  ') values('||
  ':1,:2,:3,:4,:5,:6,:7,:8,:9,:10,'||
  ':11,:12,:13,:14,:15,:16,:17,:18,:19,:20,'||
  ':21,:22,:23,:24,:25,:26,:27,:28,:29,:30 '||
  ')';
  if g_debug then
    write_to_log_file_n(g_stmt);
  end if;
  execute immediate g_stmt using
  p_fact_id,
  p_mapping_id,
  p_src_object,
  p_src_object_id,
  p_conc_id,
  p_conc_program_name,
  l_debug,
  p_collection_size,
  p_parallel,
  p_bis_owner,
  p_table_owner ,
  l_full_refresh,
  p_forall_size,
  p_update_type,
  p_fact_dlog,
  p_load_fk,
  l_fresh_restart,
  p_op_table_space,
  p_bu_src_fact,
  p_load_mode,
  p_rollback,
  p_src_join_nl_percentage,
  p_max_threads,
  p_min_job_load_size,
  p_sleep_time,
  p_job_status_table,
  p_hash_area_size,
  p_sort_area_size,
  l_trace,
  l_read_cfig_options;
  commit;
  g_stmt:='create table '||l_fk_table||'('||
  'fact_fks varchar2(200),'||
  'higher_level varchar2(2),'||
  'parent_dim varchar2(200),'||
  'parent_level varchar2(200),'||
  'level_prefix varchar2(200),'||
  'level_pk varchar2(200),'||
  'level_pk_key varchar2(200),'||
  'dim_pk_key varchar2(200)'||
  ') tablespace '||p_op_table_space;
  if g_debug then
    write_to_log_file_n(g_stmt);
  end if;
  execute immediate g_stmt;
  g_stmt:='insert into '||l_fk_table||'('||
  'fact_fks,'||
  'higher_level,'||
  'parent_dim,'||
  'parent_level,'||
  'level_prefix,'||
  'level_pk,'||
  'level_pk_key,'||
  'dim_pk_key'||
  ') values('||
  ':1,:2,:3,:4,:5,:6,:7,:8'||
  ')';
  for i in 1..p_number_fact_fks loop
    if p_higher_level(i) then
      l_higher_level:='Y';
    else
      l_higher_level:='N';
    end if;
    execute immediate g_stmt using
    p_fact_fks(i),
    l_higher_level,
    p_parent_dim(i),
    p_parent_level(i),
    p_level_prefix(i),
    p_level_pk(i),
    p_level_pk_key(i),
    p_dim_pk_key(i);
  end loop;
  commit;
  g_stmt:='create table '||l_skip_table||'('||
  'skip_cols varchar2(80)'||
  ') tablespace '||p_op_table_space;
  if g_debug then
    write_to_log_file_n(g_stmt);
  end if;
  execute immediate g_stmt;
  g_stmt:='insert into '||l_skip_table||'('||
  'skip_cols'||
  ') values('||
  ':1'||
  ')';
  if g_debug then
    write_to_log_file_n(g_stmt);
  end if;
  for i in 1..p_number_skip_cols loop
    execute immediate g_stmt using p_skip_cols(i);
  end loop;
  commit;
  g_stmt:='create table '||l_bu_table||'('||
  'bu_tables varchar2(80),'||
  'bu_dimensions varchar2(80)'||
  ') tablespace '||p_op_table_space;
  if g_debug then
    write_to_log_file_n(g_stmt);
  end if;
  execute immediate g_stmt;
  g_stmt:='insert into '||l_bu_table||'('||
  'bu_tables,'||
  'bu_dimensions'||
  ') values('||
  ':1,:2'||
  ')';
  if g_debug then
    write_to_log_file_n(g_stmt);
  end if;
  for i in 1..p_number_bu_tables loop
    execute immediate g_stmt using p_bu_tables(i),p_bu_dimensions(i);
  end loop;
  commit;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in create_derv_fact_inp_table '||g_status_message);
  return false;
End;

function update_derv_fact_input_table(
p_input_table varchar2,
p_ilog_table varchar2,
p_dlog_table varchar2,
p_skip_ilog_update boolean,
p_skip_dlog_update boolean,
p_skip_ilog boolean,
p_load_mode varchar2,
p_full_refresh boolean,
p_src_object_ilog varchar2,
p_src_object_dlog varchar2,
p_src_snplog_has_pk boolean,
p_err_rec_flag boolean,
p_err_rec_flag_d boolean
) return boolean is
l_skip_ilog_update varchar2(2);
l_skip_dlog_update varchar2(2);
l_skip_ilog varchar2(2);
l_full_refresh varchar2(2);
l_src_snplog_has_pk varchar2(2);
l_err_rec_flag varchar2(2);
l_err_rec_flag_d varchar2(2);
Begin
  if g_debug then
    write_to_log_file_n('In update_derv_fact_input_table');
  end if;
  l_skip_ilog_update:='N';
  l_skip_dlog_update:='N';
  l_skip_ilog:='N';
  l_full_refresh:='N';
  l_src_snplog_has_pk:='N';
  l_err_rec_flag:='N';
  l_err_rec_flag_d:='N';
  if p_skip_ilog_update then
    l_skip_ilog_update:='Y';
  end if;
  if p_skip_dlog_update then
    l_skip_dlog_update:='Y';
  end if;
  if p_skip_ilog then
    l_skip_ilog:='Y';
  end if;
  if p_full_refresh then
    l_full_refresh:='Y';
  end if;
  if p_src_snplog_has_pk then
    l_src_snplog_has_pk:='Y';
  end if;
  if p_err_rec_flag then
    l_err_rec_flag:='Y';
  end if;
  if p_err_rec_flag_d then
    l_err_rec_flag_d:='Y';
  end if;
  g_stmt:='update '||p_input_table||' set '||
  'ilog_table=:1,'||
  'dlog_table=:2,'||
  'skip_ilog_update=:3,'||
  'skip_dlog_update=:4,'||
  'skip_ilog=:5,'||
  'load_mode=:6,'||
  'full_refresh=:7,'||
  'src_object_ilog=:8,'||
  'src_object_dlog=:9,'||
  'src_snplog_has_pk=:10,'||
  'err_rec_flag=:11,'||
  'err_rec_flag_d=:12';
  if g_debug then
    write_to_log_file_n(g_stmt);
  end if;
  execute immediate g_stmt using
  p_ilog_table,
  p_dlog_table,
  l_skip_ilog_update,
  l_skip_dlog_update,
  l_skip_ilog,
  p_load_mode,
  l_full_refresh,
  p_src_object_ilog,
  p_src_object_dlog,
  l_src_snplog_has_pk,
  l_err_rec_flag,
  l_err_rec_flag_d;
  commit;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in update_derv_fact_input_table '||g_status_message);
  return false;
End;

function merge_all_prot_tables(
p_prot_table varchar2,
p_prot_table_extn varchar2,
p_op_table_space varchar2,
p_bis_owner varchar2,
p_parallel number
)return boolean is
Begin
  if g_debug then
    write_to_log_file_n('In merge_all_prot_tables p_prot_table '||p_prot_table||', p_prot_table_extn '||
    p_prot_table_extn);
  end if;
  return merge_all_ilog_tables(p_prot_table,p_prot_table,null,p_prot_table_extn,p_op_table_space,p_bis_owner,
  p_parallel);
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in merge_all_prot_tables '||g_status_message);
  return false;
End;

function merge_all_ilog_tables (
p_ilog_pattern varchar2,
p_ilog_table varchar2,
p_ilog_table2 varchar2,
p_ilog_table_extn varchar2,
p_op_table_space varchar2,
p_bis_owner varchar2,
p_parallel number
)return boolean is
l_ilog_tables EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_ilog_tables number;
Begin
  if g_debug then
    write_to_log_file_n('In merge_all_ilog_tables p_ilog_pattern '||p_ilog_pattern||
    ' p_ilog_table '||p_ilog_table||', p_ilog_table_extn '||p_ilog_table_extn);
  end if;
  if get_ilog_tables_from_db(p_ilog_pattern,p_ilog_table_extn,p_bis_owner,l_ilog_tables,
    l_number_ilog_tables)=false then
    return false;
  end if;
  if l_number_ilog_tables>0 then --only if the prev run was  multi threaded
    /*
    if these small ok tables exist, then g_ok_rowid_table cannot exist
    */
    if EDW_OWB_COLLECTION_UTIL.drop_table(p_ilog_table)=false then
      null;
    end if;
    --just for safety
    if p_ilog_table2 is not null then
      if EDW_OWB_COLLECTION_UTIL.drop_table(p_ilog_table2)=false then
        null;
      end if;
    end if;
    g_stmt:='create table '||p_ilog_table||' tablespace '||p_op_table_space;
    g_stmt:=g_stmt||' storage (initial 4M next 4M pctincrease 0) ';
    if p_parallel is not null then
      g_stmt:=g_stmt||' parallel (degree '||p_parallel||') ';
    end if;
    g_stmt:=g_stmt||' as ';
    for i in 1..l_number_ilog_tables loop
      g_stmt:=g_stmt||' select * from '||l_ilog_tables(i)||' union all ';
    end loop;
    g_stmt:=substr(g_stmt,1,length(g_stmt)-10);
    if g_debug then
      write_to_log_file_n(g_stmt||get_time);
    end if;
    execute immediate g_stmt;
    if g_debug then
      write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
    end if;
    for i in 1..l_number_ilog_tables loop
      if drop_table(l_ilog_tables(i))=false then
        null;
      end if;
    end loop;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in merge_all_ilog_tables '||g_status_message);
  return false;
End;

function drop_prot_tables(
p_prot_table varchar2,
p_prot_table_extn varchar2,
p_bis_owner varchar2
) return boolean is
Begin
  return drop_ilog_tables(p_prot_table,p_prot_table_extn,p_bis_owner);
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in drop_prot_tables '||g_status_message);
  return false;
End;

function drop_ilog_tables(
p_ilog_table varchar2,
p_ilog_table_extn varchar2,
p_bis_owner varchar2
) return boolean is
l_ilog_tables EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_ilog_tables number;
Begin
  if g_debug then
    write_to_log_file_n('In drop_ilog_tables');
  end if;
  if get_ilog_tables_from_db(p_ilog_table,p_ilog_table_extn,p_bis_owner,l_ilog_tables,
    l_number_ilog_tables)=false then
    return false;
  end if;
  if l_number_ilog_tables>0 then
    for i in 1..l_number_ilog_tables loop
      if drop_table(l_ilog_tables(i))=false then
        null;
      end if;
    end loop;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in drop_ilog_tables '||g_status_message);
  return false;
End;

function get_ilog_tables_from_db(
p_ilog_table varchar2,
p_ilog_table_extn varchar2,
p_bis_owner varchar2,
p_ilog_tables out nocopy EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_number_ilog_tables out nocopy number
)return boolean is
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_search_string varchar2(80);
l_ilog_table_extn varchar2(30);
l_ilog_table varchar2(80);
Begin
  if g_debug then
    write_to_log_file_n('In get_ilog_tables_from_db');
  end if;
  l_ilog_table:=p_ilog_table;
  if instr(l_ilog_table,'.')>0 then
    l_ilog_table:=substr(p_ilog_table,instr(p_ilog_table,'.')+1,length(p_ilog_table));
  end if;
  if p_ilog_table_extn is null then
    l_ilog_table_extn:=substr(l_ilog_table,instr(l_ilog_table,'_',-1)+1,length(l_ilog_table));
  else
    l_ilog_table_extn:=p_ilog_table_extn;
  end if;
  l_search_string:=substr(l_ilog_table,1,instr(l_ilog_table,'_'||l_ilog_table_extn)-1);
  g_stmt:='select table_name from all_tables where (table_name like '''||l_search_string||'_%_'||
  l_ilog_table_extn||''' or table_name like '''||l_search_string||'_%_'||l_ilog_table_extn||'A'') '||
  'and owner='''||p_bis_owner||'''';
  if g_debug then
    write_to_log_file_n(g_stmt);
  end if;
  p_number_ilog_tables:=1;
  open cv for g_stmt;
  loop
    fetch cv into p_ilog_tables(p_number_ilog_tables);
    exit when cv%notfound;
    p_number_ilog_tables:=p_number_ilog_tables+1;
  end loop;
  close cv;
  p_number_ilog_tables:=p_number_ilog_tables-1;
  for i in 1..p_number_ilog_tables loop
    p_ilog_tables(i):=p_bis_owner||'.'||p_ilog_tables(i);
  end loop;
  if g_debug then
    write_to_log_file_n('The tables');
    for i in 1..p_number_ilog_tables loop
      write_to_log_file(p_ilog_tables(i));
    end loop;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_ilog_tables_from_db '||g_status_message);
  return false;
End;

function put_rownum_in_ilog_table(
p_ilog varchar2,
p_ilog_old varchar2,
p_op_table_space varchar2,
p_parallel number
)return boolean is
Begin
  if g_debug then
    write_to_log_file_n('In put_rownum_in_ilog_table p_ilog='||p_ilog||',p_ilog_old='||p_ilog_old);
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(p_ilog)=false then
    null;
  end if;
  g_stmt:='create table '||p_ilog||' tablespace '||p_op_table_space;
  g_stmt:=g_stmt||' storage (initial 4M next 4M pctincrease 0) ';
  if p_parallel is not null then
    g_stmt:=g_stmt||' parallel (degree '||p_parallel||') ';
  end if;
  g_stmt:=g_stmt||' as select '||p_ilog_old||'.*, rownum row_num from '||p_ilog_old;
  if g_debug then
    write_to_log_file_n(g_stmt||get_time);
  end if;
  execute immediate g_stmt;
  if g_debug then
    write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
  end if;
  create_rownum_index_ilog(p_ilog,p_op_table_space,p_parallel);
  if EDW_OWB_COLLECTION_UTIL.drop_table(p_ilog_old)=false then
    null;
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(p_ilog,instr(p_ilog,'.')+1,
  length(p_ilog)),substr(p_ilog,1,instr(p_ilog,'.')-1));
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in put_rownum_in_ilog_table '||g_status_message);
  return false;
End;

procedure create_rownum_index_ilog(
p_ilog varchar2,
p_op_table_space varchar2,
p_parallel number
) is
Begin
  --create the index
  g_stmt:='create unique index '||p_ilog||'u on '||p_ilog||'(row_num) '||
  'tablespace '||p_op_table_space;
  if p_parallel is not null then
    g_stmt:=g_stmt||' parallel '||p_parallel;
  end if;
  if g_debug then
    write_to_log_file_n(g_stmt||get_time);
  end if;
  execute immediate g_stmt;
  if g_debug then
    write_to_log_file_n('Created index '||get_time);
  end if;
Exception when others then
  write_to_log_file_n('Error in create_rownum_index_ilog '||sqlerrm);
End;

function check_conc_process_status(p_conc_id number) return varchar2 is
l_phase varchar2(400);
l_status varchar2(400);
l_dev_phase  varchar2(400);
l_dev_status varchar2(400);
l_message varchar2(4000);
l_conc_id number;
Begin
  l_conc_id:=p_conc_id;
  if FND_CONCURRENT.get_request_status(l_conc_id,null,null,l_phase,l_status,
    l_dev_phase,l_dev_status,l_message)=false then
    write_to_log_file_n('FND_CONCURRENT.get_request_status returned with false');
    write_to_log_file(FND_MESSAGE.get);
    return 'N';
  end if;
  if l_dev_phase is null or l_dev_phase='COMPLETE' then
    return 'N';--there is no more this process
  else
    return 'Y';--still running
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in check_conc_process_status '||g_status_message);
  return null;
End;

function update_inp_table_jobid(
p_input_table varchar2,
p_job_id number
)return boolean is
Begin
  g_stmt:='update '||p_input_table||' set dbms_job_id=:1';
  if g_debug then
    write_to_log_file_n(g_stmt||' '||p_job_id);
  end if;
  execute immediate g_stmt using p_job_id;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in update_inp_table_jobid '||sqlerrm||' '||get_time);
  return false;
End;

function update_inp_table_concid(
p_input_table varchar2,
p_conc_id number
)return boolean is
Begin
  g_stmt:='update '||p_input_table||' set conc_id=:1';
  if g_debug then
    write_to_log_file_n(g_stmt||' '||p_conc_id);
  end if;
  execute immediate g_stmt using p_conc_id;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in update_inp_table_concid '||sqlerrm||' '||get_time);
  return false;
End;

function find_skip_attributes(
p_object_name varchar2,
p_object_type varchar2,
p_skip_cols out NOCOPY varcharTableType,
p_number_skip_cols out NOCOPY number
) return boolean is
l_nc_columns varcharTableType;
l_number_nc_columns number;
l_ltc_in_map varcharTableType;
l_ltc_col_in_map varcharTableType;
l_tgt_in_map varcharTableType;--dummy
l_tgt_col_in_map varcharTableType;
l_number_ltc_in_map number;
l_ltc_used varcharTableType;
l_ltc_col_used varcharTableType;
l_number_ltc_used number;
l_index number;
l_distinct_ltc_used varcharTableType;
l_number_distinct_ltc_used number;
l_pk varcharTableType;
l_number_pk number;
l_fk varcharTableType;
l_parent_table varcharTableType;
l_number_fk number;
l_columns varcharTableType;
l_number_columns number;
l_prefix varcharTableType;
l_col_to_add varchar2(200);
Begin
  p_number_skip_cols:=0;
  l_number_nc_columns:=0;
  l_number_ltc_in_map:=0;
  l_number_ltc_used:=0;
  l_number_distinct_ltc_used:=0;
  if get_lookup_code('LC_'||p_object_name,l_nc_columns,l_number_nc_columns)=false then
    return false;
  end if;
  if g_debug then
    write_to_log_file_n('The columns that need to be loaded from lookup type LC_'||p_object_name);
    for i in 1..l_number_nc_columns loop
      write_to_log_file(l_nc_columns(i));
    end loop;
  end if;
  if l_number_nc_columns=0 then
    if g_debug then
      write_to_log_file_n('No columns defined in lookup type. So getting skipped columns from metadata');
    end if;
    if get_item_set_cols(p_skip_cols,p_number_skip_cols,p_object_name,'SKIP_LOAD_SET')=false then
      return false;
    end if;
  else
    if g_debug then
      write_to_log_file_n('Finding the skipped columns');
    end if;
    if p_object_type='DIMENSION' then
      if get_col_col_in_map(null,p_object_name,l_ltc_in_map,l_ltc_col_in_map,l_tgt_in_map,l_tgt_col_in_map,
        l_number_ltc_in_map)=false then
        return false;
      end if;
      for i in 1..l_number_nc_columns loop
        l_index:=index_in_table(l_tgt_col_in_map,l_number_ltc_in_map,l_nc_columns(i));
        if l_index>0 then
          l_number_ltc_used:=l_number_ltc_used+1;
          l_ltc_used(l_number_ltc_used):=l_ltc_in_map(l_index);
          l_ltc_col_used(l_number_ltc_used):=l_ltc_col_in_map(l_index);
        end if;
      end loop;
      if g_debug then
        write_to_log_file_n('LTC and columns needed');
        for i in 1..l_number_ltc_used loop
          write_to_log_file(l_ltc_used(i)||'('||l_ltc_col_used(i)||')');
        end loop;
      end if;
      for i in 1..l_number_ltc_used loop
        if value_in_table(l_distinct_ltc_used,l_number_distinct_ltc_used,l_ltc_used(i))=false then
          l_number_distinct_ltc_used:=l_number_distinct_ltc_used+1;
          l_distinct_ltc_used(l_number_distinct_ltc_used):=l_ltc_used(i);
        end if;
      end loop;
      for i in 1..l_number_distinct_ltc_used loop
        l_prefix(i):=get_level_prefix(substr(l_distinct_ltc_used(i),1,
        instr(l_distinct_ltc_used(i),'_LTC',-1)-1));
      end loop;
      if g_debug then
        write_to_log_file_n('Distinct LTC');
        for i in 1..l_number_distinct_ltc_used loop
          write_to_log_file(l_distinct_ltc_used(i)||'('||l_prefix(i)||')');
        end loop;
      end if;
      if get_columns_for_table(p_object_name,l_columns,l_number_columns)=false then
        return false;
      end if;
      for i in 1..l_number_distinct_ltc_used loop
        l_number_pk:=0;
        l_number_fk:=0;
        if get_object_unique_key(l_distinct_ltc_used(i),null,
        l_pk,l_number_pk)=false then
          return false;
        end if;
        if g_debug then
          write_to_log_file_n('PK for '||l_distinct_ltc_used(i));
          for j in 1..l_number_pk loop
            write_to_log_file(l_pk(j));
          end loop;
        end if;
        for j in 1..l_number_pk loop
          l_index:=index_in_table(l_ltc_in_map,l_ltc_col_in_map,l_number_ltc_in_map,
          l_distinct_ltc_used(i),l_pk(j));
          if l_index<=0 then
            l_index:=index_in_table(l_columns,l_number_columns,l_prefix(i)||'_'||l_pk(j));
            if l_index>0 then
              l_col_to_add:=l_columns(l_index);
            end if;
          else
            l_col_to_add:=l_tgt_col_in_map(l_index);
          end if;
          if l_index>0 then
            if value_in_table(l_nc_columns,l_number_nc_columns,l_col_to_add)=false then
              if g_debug then
                write_to_log_file_n('Column '||l_pk(j)||' of '||l_distinct_ltc_used(i)||
                ' missing in needec col list');
                write_to_log_file('Adding '||l_col_to_add);
              end if;
              l_number_nc_columns:=l_number_nc_columns+1;
              l_nc_columns(l_number_nc_columns):=l_col_to_add;
            end if;
          end if;
        end loop;
        if get_fks_for_table(l_distinct_ltc_used(i),l_parent_table,l_fk,l_number_fk)=false then
          return false;
        end if;
        if g_debug then
          write_to_log_file_n('FK for '||l_distinct_ltc_used(i));
          for j in 1..l_number_fk loop
            write_to_log_file(l_fk(j)||'('||l_parent_table(j)||')');
          end loop;
        end if;
        for j in 1..l_number_fk loop
          if value_in_table(l_distinct_ltc_used,l_number_distinct_ltc_used,l_parent_table(j)) then
            l_index:=index_in_table(l_ltc_in_map,l_ltc_col_in_map,l_number_ltc_in_map,
            l_distinct_ltc_used(i),l_fk(j));
            if l_index<=0 then
              l_index:=index_in_table(l_columns,l_number_columns,l_prefix(i)||'_'||l_fk(j));
              if l_index>0 then
                l_col_to_add:=l_columns(l_index);
              end if;
            else
              l_col_to_add:=l_tgt_col_in_map(l_index);
            end if;
            if l_index>0 then
              if value_in_table(l_nc_columns,l_number_nc_columns,l_col_to_add)=false then
                if g_debug then
                  write_to_log_file_n('Column '||l_fk(j)||' of '||l_distinct_ltc_used(i)||
                  ' missing in needec col list');
                  write_to_log_file('Adding '||l_col_to_add);
                end if;
                l_number_nc_columns:=l_number_nc_columns+1;
                l_nc_columns(l_number_nc_columns):=l_col_to_add;
              end if;
            end if;
          end if;
        end loop;
      end loop;
      if g_debug then
        write_to_log_file_n('All the needed columns of the dimension');
        for i in 1..l_number_nc_columns loop
          write_to_log_file(l_nc_columns(i));
        end loop;
      end if;
      for i in 1..l_number_ltc_in_map loop
        if value_in_table(l_nc_columns,l_number_nc_columns,l_tgt_col_in_map(i))=false then
          p_number_skip_cols:=p_number_skip_cols+1;
          p_skip_cols(p_number_skip_cols):=l_tgt_col_in_map(i);
        end if;
      end loop;
    else --this is a fact
      l_number_pk:=0;
      if get_object_unique_key(p_object_name,null,l_pk,l_number_pk)=false then
        return false;
      end if;
      if g_debug then
        write_to_log_file_n('PK for '||p_object_name);
        for j in 1..l_number_pk loop
          write_to_log_file(l_pk(j));
        end loop;
      end if;
      for i in 1..l_number_pk loop
        if value_in_table(l_nc_columns,l_number_nc_columns,l_pk(i))=false then
          l_number_nc_columns:=l_number_nc_columns+1;
          l_nc_columns(l_number_nc_columns):=l_pk(i);
        end if;
      end loop;
      if g_debug then
        write_to_log_file_n('All the needed columns of the fact');
        for i in 1..l_number_nc_columns loop
          write_to_log_file(l_nc_columns(i));
        end loop;
      end if;
      if get_columns_for_table(p_object_name,l_columns,l_number_columns)=false then
        return false;
      end if;
      for i in 1..l_number_columns loop
        if value_in_table(l_nc_columns,l_number_nc_columns,l_columns(i))=false then
          p_number_skip_cols:=p_number_skip_cols+1;
          p_skip_cols(p_number_skip_cols):=l_columns(i);
        end if;
      end loop;
    end if;
  end if;
  if g_debug then
    write_to_log_file_n('The skipped columns('||p_number_skip_cols||')');
    for i in 1..p_number_skip_cols loop
      write_to_log_file(p_skip_cols(i));
    end loop;
  end if;
  return true;
Exception when others then
  g_status_message:='Error in find_skip_attributes_fk '||sqlerrm||get_time;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

function log_collection_start(
p_object_name varchar2,
p_object_id number,
p_object_type varchar2,
p_start_date date,
p_conc_program_id number,
p_load_pk number
) return boolean is
l_stmt varchar2(2000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_message varchar2(2000);
l_load_pk number;
Begin
  --first, if there are any with status of processing, make it 'ERROR'
  l_load_pk:=null;
  l_stmt:='select load_pk from edw_collection_detail_log where COLLECTION_STATUS=:a and object_name=:b '||
  'and object_type=:c';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||' using ''PROCESSING'','||p_object_name||','||p_object_type);
  end if;
  open cv for l_stmt using 'PROCESSING',p_object_name,p_object_type;
  fetch cv into l_load_pk;
  close cv;
  if l_load_pk is not null then
    if g_debug then
      write_to_log_file_n('Found '||l_load_pk||' with PROCESSING, making it ERROR');
    end if;
    l_message:='Terminated';
    if write_to_collection_log(
      p_object_name,
      p_object_id,
      p_object_type,
      p_conc_program_id,
      p_start_date,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      l_message,
      'ERROR',
      l_load_pk)=false then
      write_to_log_file_n('write_to_collection_log returned with error');
      return false;
    end if;
  end if;
  l_load_pk:=p_load_pk;
  write_to_log_file_n('Load PK='||l_load_pk);
  if write_to_collection_log(
        p_object_name,
        p_object_id,
        p_object_type,
        p_conc_program_id,
        p_start_date,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        'PROCESSING',
        l_load_pk)=false then
    write_to_log_file_n('write_to_collection_log returned with error');
    return false;
  end if;
  commit;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n(g_status_message);
  return false;
End;

function get_temp_log_data(
p_object_name varchar2,
p_object_type varchar2,
p_load_pk number,
p_ins_rows_ready out nocopy number,
p_ins_rows_processed out nocopy number,
p_ins_rows_collected out nocopy number,
p_ins_rows_dangling out nocopy number,
p_ins_rows_duplicate out nocopy number,
p_ins_rows_error out nocopy number,
p_ins_rows_insert out nocopy number,
p_ins_rows_update out nocopy number,
p_ins_rows_delete out nocopy number,
p_ins_instance_name out nocopy varchar2,
p_ins_request_id_table out nocopy varchar2
) return boolean is
l_stmt varchar2(10000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_object_type varchar2(400);
Begin
  if g_debug then
    write_to_log_file_n('In get_temp_log_data '||p_object_name||'   '||p_object_type);
  end if;
  if p_load_pk is null then
    l_stmt:='select nvl(sum(nvl(rows_ready,0)),0), '||
    ' nvl(sum(nvl(rows_collected,0)),0), nvl(sum(nvl(rows_dangling,0)),0), '||
    'nvl(sum(nvl(rows_duplicate,0)),0), nvl(sum(nvl(rows_error,0)),0),nvl(sum(nvl(number_insert,0)),0),'||
    'nvl(sum(nvl(number_update,0)),0),nvl(sum(nvl(number_delete,0)),0) '||
    ' from edw_temp_collection_log where object_name=:a and object_type=:b and status=:c ';
     open cv for l_stmt using p_object_name,p_object_type,'OPEN';
  else
    l_stmt:='select nvl(sum(nvl(rows_ready,0)),0), '||
    ' nvl(sum(nvl(rows_collected,0)),0), nvl(sum(nvl(rows_dangling,0)),0), '||
    'nvl(sum(nvl(rows_duplicate,0)),0), nvl(sum(nvl(rows_error,0)),0),nvl(sum(nvl(number_insert,0)),0),'||
    'nvl(sum(nvl(number_update,0)),0),nvl(sum(nvl(number_delete,0)),0) '||
    ' from edw_temp_collection_log where request_id=:1';
    open cv for l_stmt using p_load_pk;
  end if;
  fetch cv into
    p_ins_rows_processed,p_ins_rows_collected,p_ins_rows_dangling,p_ins_rows_duplicate,
    p_ins_rows_error,p_ins_rows_insert,p_ins_rows_update,p_ins_rows_delete;
  close cv;
  p_ins_rows_ready:=null;
  l_stmt:='select max(NUMBER_READY) from edw_temp_collection_log where object_name=:a and object_type=:b '||
  'and status=:c';
  open cv for l_stmt using p_object_name,p_object_type,'OPEN';
  fetch cv into p_ins_rows_ready;
  close cv;
  if p_ins_rows_ready is null then
    p_ins_rows_ready:=p_ins_rows_processed; --for derived facts
  end if;
  p_ins_instance_name:=null;
  p_ins_request_id_table:=null;
  if g_debug then
    write_to_log_file_n('The results of query of the table edw_temp_collection_log');
    write_to_log_file('Instance   request id   ready  processed    collected  dangling  duplicate  error '||
    'insert update delete');
    write_to_log_file(p_ins_instance_name||' '||p_ins_request_id_table||' '||
    p_ins_rows_ready||' '||p_ins_rows_processed||' '||
    p_ins_rows_collected||' '||p_ins_rows_dangling||' '||
    p_ins_rows_duplicate||' '||p_ins_rows_error||' '||p_ins_rows_insert||' '||p_ins_rows_update
    ||' '||p_ins_rows_delete);
  end if;
  l_stmt:='delete edw_temp_collection_log where object_name=:a and object_type=:b and status=:c';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||' using '||p_object_name||'  '||p_object_type||' OPEN');
  end if;
  execute immediate l_stmt using p_object_name,p_object_type,'OPEN';
  return true;
EXCEPTION when others then
  g_status:=false;
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function get_job_queue_processes return number is
Begin
  return get_parameter_value('job_queue_processes');
EXCEPTION when others then
  write_to_log_file_n(g_status_message);
  return null;
End;

function get_app_long_name(
p_app_name varchar2,
p_app_long_name out nocopy varchar2
) return boolean is
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  g_stmt:='select application_name from fnd_application_vl where application_short_name=:1';
  if g_debug then
    write_to_log_file_n(g_stmt||' '||p_app_name);
  end if;
  open cv for g_stmt using p_app_name;
  fetch cv into p_app_long_name;
  close cv;
  if g_debug then
    write_to_log_file('p_app_long_name='||p_app_long_name);
  end if;
  return true;
EXCEPTION when others then
  write_to_log_file_n('Error in get_app_long_name '||sqlerrm);
  return false;
End;

function get_max_in_array(p_array numberTableType,p_number_array number,
p_index out nocopy number) return number is
l_max number;
Begin
  for i in 1..p_number_array loop
    if l_max is null or (p_array(i)>l_max) then
      l_max:=p_array(i);
      p_index:=i;
    end if;
  end loop;
  if g_debug then
    write_to_log_file_n('l_max='||l_max||', p_index='||p_index);
  end if;
  return l_max;
EXCEPTION when others then
  write_to_log_file_n('Error in get_max_in_array '||sqlerrm);
  return null;
End;

function get_min_in_array(p_array numberTableType,p_number_array number,
p_index out nocopy number) return number is
l_min number;
Begin
  for i in 1..p_number_array loop
    if l_min is null or (p_array(i)<l_min) then
      l_min:=p_array(i);
      p_index:=i;
    end if;
  end loop;
  if g_debug then
    write_to_log_file_n('l_min='||l_min||', p_index='||p_index);
  end if;
  return l_min;
EXCEPTION when others then
  write_to_log_file_n('Error in get_max_in_array '||sqlerrm);
  return null;
End;

function create_input_table_push_down(
  p_input_table varchar2,
  p_dim_name varchar2,
  p_dim_id number,
  p_levels varcharTableType,
  p_child_level_number numberTableType,
  p_child_levels varcharTableType,
  p_child_fk varcharTableType,
  p_parent_pk varcharTableType,
  p_number_levels number,
  p_level_order varcharTableType,
  p_level_snapshot_logs varcharTableType,
  p_level_ilog varcharTableType,
  p_level_consider booleanTableType,
  p_level_full_insert booleanTableType,
  p_debug boolean,
  p_parallel number,
  p_collection_size number,
  p_bis_owner  varchar2,
  p_table_owner varchar2,
  p_full_refresh boolean,
  p_forall_size number,
  p_update_type varchar2,
  p_load_pk number,
  p_op_table_space varchar2,
  p_rollback varchar2,
  p_max_threads number,
  p_min_job_load_size number,
  p_sleep_time number,
  p_hash_area_size number,
  p_sort_area_size number,
  p_trace boolean,
  p_read_cfig_options boolean,
  p_join_nl_percentage number
) return boolean is
l_level_table varchar2(80);
l_level_child_table varchar2(80);
l_level_consider varchar2(10);
l_level_full_insert varchar2(10);
l_debug varchar2(10);
l_full_refresh varchar2(10);
l_trace varchar2(10);
l_read_cfig_options varchar2(10);
l_run number;
Begin
  if g_debug then
    write_to_log_file_n('In create_input_table_push_down');
  end if;
  l_level_table:=p_input_table||'_LT';
  l_level_child_table:=p_input_table||'_LC';
  g_stmt:='create table '||p_input_table||'('||
  'dim_name varchar2(200),'||
  'dim_id number,'||
  'debug varchar2(10),'||
  'parallel number,'||
  'collection_size number,'||
  'bis_owner  varchar2(200),'||
  'table_owner varchar2(200),'||
  'full_refresh varchar2(10),'||
  'forall_size number,'||
  'update_type varchar2(200),'||
  'load_pk number,'||
  'op_table_space varchar2(200),'||
  'rollback varchar2(200),'||
  'max_threads number,'||
  'min_job_load_size number,'||
  'sleep_time number,'||
  'hash_area_size number,'||
  'sort_area_size number,'||
  'trace varchar2(10),'||
  'read_cfig_options varchar2(10),'||
  'join_nl_percentage number'||
  ') tablespace '||p_op_table_space;
  if drop_table(p_input_table)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n(g_stmt);
  end if;
  execute immediate g_stmt;
  l_debug:='N';
  l_full_refresh:='N';
  l_trace:='N';
  l_read_cfig_options:='N';
  if p_debug then
    l_debug:='Y';
  end if;
  if p_full_refresh then
    l_full_refresh:='Y';
  end if;
  if p_trace then
    l_trace:='Y';
  end if;
  if p_read_cfig_options then
    l_read_cfig_options:='Y';
  end if;
  g_stmt:='insert into '||p_input_table||'('||
  'dim_name'||
  ',dim_id'||
  ',debug'||
  ',parallel'||
  ',collection_size'||
  ',bis_owner'||
  ',table_owner'||
  ',full_refresh'||
  ',forall_size'||
  ',update_type'||
  ',load_pk'||
  ',op_table_space'||
  ',rollback'||
  ',max_threads'||
  ',min_job_load_size'||
  ',sleep_time'||
  ',hash_area_size'||
  ',sort_area_size'||
  ',trace'||
  ',read_cfig_options'||
  ',join_nl_percentage'||
  ') values('||
  ':1,:2,:3,:4,:5,:6,:7,:8,:9,:10,'||
  ':11,:12,:13,:14,:15,:16,:17,:18,:19,:20,'||
  ':21'||
  ')';
  if g_debug then
    write_to_log_file_n(g_stmt);
  end if;
  execute immediate g_stmt using
  p_dim_name,
  p_dim_id,
  l_debug,
  p_parallel,
  p_collection_size,
  p_bis_owner,
  p_table_owner,
  l_full_refresh,
  p_forall_size,
  p_update_type,
  p_load_pk,
  p_op_table_space,
  p_rollback,
  p_max_threads,
  p_min_job_load_size,
  p_sleep_time,
  p_hash_area_size,
  p_sort_area_size,
  l_trace,
  l_read_cfig_options,
  p_join_nl_percentage;
  commit;
  g_stmt:='create table '||l_level_table||'('||
  'level_number number,'||
  'levels varchar2(200),'||
  'child_level_number number,'||
  'child_levels varchar2(200),'||
  'child_fk varchar2(200),'||
  'parent_pk varchar2(200),'||
  'level_order varchar2(200),'||
  'level_snapshot_logs varchar2(200),'||
  'level_ilog varchar2(200),'||
  'level_consider varchar2(10),'||
  'level_full_insert varchar2(10)'||
  ') tablespace '||p_op_table_space;
  if drop_table(l_level_table)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n(g_stmt);
  end if;
  execute immediate g_stmt;
  g_stmt:='insert into '||l_level_table||'('||
  'level_number'||
  ',levels'||
  ',child_level_number'||
  ',level_order'||
  ',level_snapshot_logs'||
  ',level_ilog'||
  ',level_consider'||
  ',level_full_insert'||
  ') values ('||
  ':1,:2,:3,:4,:5,:6,:7,:8'||
  ')';
  if g_debug then
    write_to_log_file_n(g_stmt);
  end if;
  for i in 1..p_number_levels loop
    l_level_consider:='N';
    if p_level_consider(i) then
      l_level_consider:='Y';
    end if;
    l_level_full_insert:='N';
    if p_level_full_insert(i) then
      l_level_full_insert:='Y';
    end if;
    execute immediate g_stmt using
    i
    ,p_levels(i)
    ,p_child_level_number(i)
    ,p_level_order(i)
    ,p_level_snapshot_logs(i)
    ,p_level_ilog(i)
    ,l_level_consider
    ,l_level_full_insert;
  end loop;
  commit;
  g_stmt:='create table '||l_level_child_table||'('||
  'run_number number,'||
  'child_levels varchar2(200),'||
  'child_fk varchar2(200),'||
  'parent_pk varchar2(200)'||
  ') tablespace '||p_op_table_space;
  if drop_table(l_level_child_table)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n(g_stmt);
  end if;
  execute immediate g_stmt;
  g_stmt:='insert into '||l_level_child_table||'('||
  'run_number,'||
  'child_levels,'||
  'child_fk,'||
  'parent_pk'||
  ') values('||
  ':1,:2,:3,:4'||
  ')';
  if g_debug then
    write_to_log_file_n('Going to execute '||g_stmt||' '||get_time);
  end if;
  l_run:=0;
  for i in 1..p_number_levels loop
    for j in 1..p_child_level_number(i) loop
      l_run:=l_run+1;
      execute immediate g_stmt using l_run,p_child_levels(l_run),p_child_fk(l_run),p_parent_pk(l_run);
    end loop;
  end loop;
  commit;
  return true;
EXCEPTION when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_app_long_name '||sqlerrm);
  return false;
End;

function make_ilog_from_main_ilog(
p_ilog_rowid_table varchar2,
p_ilog_table varchar2,
p_low_end number,
p_high_end number,
p_op_table_space varchar2,
p_bis_owner varchar2,
p_parallel number,
p_ilog_rowid_number out nocopy number
) return boolean is
l_cols varcharTableType;
l_number_cols number;
l_table varchar2(80);
Begin
  if g_debug then
    write_to_log_file_n('In make_ilog_from_main_ilog '||p_ilog_table||' '||p_low_end||' '||p_high_end);
  end if;
  if get_db_columns_for_table(
    p_ilog_table,
    l_cols,
    l_number_cols,
    p_bis_owner)=false then
    return false;
  end if;
  p_ilog_rowid_number:=0;
  if g_debug then
    write_to_log_file('The ILOG columns');
    for i in 1..l_number_cols loop
      write_to_log_file(l_cols(i));
    end loop;
  end if;
  g_stmt:='create table '||p_ilog_rowid_table||' tablespace '||p_op_table_space;
  g_stmt:=g_stmt||' storage (initial 4M next 4M pctincrease 0) ';
  if g_parallel is not null then
    g_stmt:=g_stmt||' parallel (degree '||p_parallel||') ';
  end if;
  g_stmt:=g_stmt||' as select ';
  for i in 1..l_number_cols loop
    if l_cols(i)<>'ROW_NUM' then
      g_stmt:=g_stmt||l_cols(i)||',';
    end if;
  end loop;
  g_stmt:=substr(g_stmt,1,length(g_stmt)-1);
  g_stmt:=g_stmt||' from '||p_ilog_table||' where row_num between '||
  p_low_end||' and '||p_high_end;
  if EDW_OWB_COLLECTION_UTIL.drop_table(p_ilog_rowid_table)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n(g_stmt||get_time);
  end if;
  execute immediate g_stmt;
  p_ilog_rowid_number:=sql%rowcount;
  if g_debug then
    write_to_log_file_n('Created with '||p_ilog_rowid_number||' rows '||get_time);
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(p_ilog_rowid_table,instr(p_ilog_rowid_table,'.')+1,
  length(p_ilog_rowid_table)),substr(p_ilog_rowid_table,1,instr(p_ilog_rowid_table,'.')-1));
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in make_ilog_from_main_ilog '||g_status_message);
  return false;
End;

procedure create_status_table(p_table varchar2,p_op_table_space varchar2,
p_status varchar2,p_count number) is
Begin
  g_stmt:='create table '||p_table||' tablespace '||p_op_table_space||
  ' as select '''||p_status||''' status,'||p_count||' count from dual';
  if drop_table(p_table)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n(g_stmt);
  end if;
  execute immediate g_stmt;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in create_status_table '||g_status_message);
End;

function create_sequence(
p_seq varchar2,
p_owner varchar2,
p_start_with number,
p_flag varchar2
) return boolean is
l_owner varchar2(80);
l_num number;
l_seq_flag boolean;--create or not to create the seq
Begin
  if g_debug then
    write_to_log_file_n('In create_sequence '||p_seq||' '||p_owner||' '||p_start_with||get_time);
  end if;
  l_owner:=p_owner;
  l_seq_flag:=true;
  <<start_seq_creation>>
  if l_owner is null then
    l_owner:=get_table_owner(p_seq);
  end if;
  if p_flag<>'FORCE' then
    begin
      l_num:=get_seq_nextval(p_seq);
      if l_num is not null then
        if l_num<p_start_with then
          if drop_seq(p_seq,l_owner)=false then
            null;
          end if;
        else
          l_seq_flag:=false;
        end if;
      end if;
    exception when others then
      write_to_log_file_n('This error mesg '||sqlerrm);
    end;
  end if;
  if l_seq_flag then
    if l_owner is null then
      g_stmt:='create sequence '||p_seq||' start with '||(p_start_with+1);
    else
      g_stmt:='create sequence '||l_owner||'.'||p_seq||' start with '||(p_start_with+1);
    end if;
    begin
      if g_debug then
        write_to_log_file_n(g_stmt);
      end if;
      execute immediate g_stmt;
    exception when others then
      if p_flag<>'FORCE' then
        if sqlcode=-00955 then
          if g_debug then
            write_to_log_file_n('Sequence already created!');
          end if;
          goto start_seq_creation;
        end if;
      end if;
    end;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in create_sequence '||g_status_message);
  return false;
End;

function drop_seq(p_seq varchar2,p_owner varchar2) return boolean is
l_owner varchar2(80);
Begin
  l_owner:=p_owner;
  if l_owner is null then
    l_owner:=get_table_owner(p_seq);
  end if;
  if l_owner is not null then
    g_stmt:='drop sequence '||l_owner||'.'||p_seq;
  else
    g_stmt:='drop sequence '||p_seq;
  end if;
  if g_debug then
    write_to_log_file_n(g_stmt);
  end if;
  execute immediate g_stmt;
  return true;
Exception when others then
  write_to_log_file_n('Error in drop_seq '||g_status_message);
  return false;
End;

function get_seq_nextval(p_seq varchar2) return number is
l_num number;
l_stmt varchar2(200);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  l_stmt:='select '||p_seq||'.NEXTVAL from dual';
  if g_debug then
    write_to_log_file_n(l_stmt);
  end if;
  open cv for l_stmt;
  fetch cv into l_num;
  close cv;
  if g_debug then
    write_to_log_file(l_num);
  end if;
  return l_num;
Exception when others then
  write_to_log_file_n('Error in get_seq_nextval '||g_status_message);
  return null;
End;

function get_max_value(p_table varchar2,p_col varchar2) return number is
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_max number;
Begin
  g_stmt:='select max('||p_col||') from '||p_table;
  if g_debug then
    write_to_log_file_n(g_stmt||get_time);
  end if;
  open cv for g_stmt;
  fetch cv into l_max;
  if g_debug then
    write_to_log_file_n('l_max='||l_max||get_time);
  end if;
  return l_max;
Exception when others then
  write_to_log_file_n('Error in get_max_value '||g_status_message);
  return null;
End;

--FSTG or LSTG map fk details ONLY
function get_stg_map_fk_details(
p_fstg_usage_id number,
p_fstg_id number,
p_mapping_id number,
p_job_id number,
p_op_tablespace varchar2,
p_bis_owner varchar2,
p_dimTableName out nocopy varcharTableType,
p_dim_row_count out nocopy numberTableType,
p_dimTableId out nocopy numberTableType,
p_dimUserPKName out nocopy varcharTableType,
p_fstgUserFKName out nocopy varcharTableType,
p_factFKName out nocopy varcharTableType,
p_numberOfDimTables out nocopy number
)return boolean is
------------------------------------------------------------
--Added for bug#6129040

CURSOR getRows(p_mapping_id NUMBER,p_fstg_usage_id NUMBER) is
select
    dim.relation_name,
    dim.relation_id,
    dim_pk_item.column_name dim_col,
    fstg_item.column_name fstg_col,
    fact_item.column_name fact_col
    from
    (select Source_usage_id,Target_column_id from edw_pvt_map_columns_md_v
    where mapping_id=p_mapping_id) map_columns,
    (select edw_pvt_map_key_usages_md_v.Source_usage_id,
    edw_pvt_map_key_usages_md_v.Unique_key_id,
    edw_pvt_map_key_usages_md_v.foreign_key_id,
    edw_pvt_map_key_usages_md_v.Parent_table_usage_id
    from
    edw_pvt_map_key_usages_md_v,edw_pvt_map_sources_md_v
    where edw_pvt_map_sources_md_v.source_usage_id=edw_pvt_map_key_usages_md_v.parent_table_usage_id
    and edw_pvt_map_key_usages_md_v.Source_usage_id=p_fstg_usage_id
    and edw_pvt_map_key_usages_md_v.mapping_id=p_mapping_id
    and edw_pvt_map_sources_md_v.mapping_id=p_mapping_id
    ) key_usage,
    edw_pvt_key_columns_md_v key_col,
    edw_pvt_key_columns_md_v fk_key_col,
    edw_unique_keys_md_v dim_pk,
    edw_relations_md_v dim,
    edw_pvt_columns_md_v dim_pk_item,
    edw_pvt_columns_md_v fstg_item,
    edw_pvt_columns_md_v fact_item
    where
    dim_pk.key_id=key_usage.Unique_key_id
    and dim.relation_id=dim_pk.entity_id
    and key_col.key_id=dim_pk.key_id
    and dim_pk_item.column_id=key_col.column_id
    and fk_key_col.key_id=key_usage.foreign_key_id
    and fstg_item.column_id=fk_key_col.column_id
    and map_columns.Source_usage_id=key_usage.Parent_table_usage_id
    and map_columns.Target_column_id=fact_item.column_id ;
------------------------------------------------------------
l_rows_with_problem booleanTableType;
l_rows_with_problem_found boolean;
------------------------------------------------------------
l_stmt VARCHAR2(200);

rowCount NUMBER;
l_relation_name VARCHAR2(255);
l_relation_id NUMBER(9);
l_dim_col VARCHAR2(255);
l_fstg_col VARCHAR2(255);
l_fact_col VARCHAR2(255);


------------------------------------------------------------
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_found boolean;
------------------------------------------------------------
l_stg_fk varcharTableType;
l_stg_dim varcharTableType;
l_number_stg number;
------------------------------------------------------------
l_table1 varchar2(200);
l_table2 varchar2(200);
l_table3 varchar2(200);
l_table4 varchar2(200);
l_table5 varchar2(200);
------------------------------------------------------------
Begin
  if g_debug then
    write_to_log_file_n('In get_stg_map_fk_details '||p_fstg_usage_id||' '||p_fstg_id||' '||
    p_mapping_id);
  end if;
  --l_table1:=p_bis_owner||'.TAB_'||p_mapping_id||'_'||p_job_id||'_GET_FK_1';
  --l_table2:=p_bis_owner||'.TAB_'||p_mapping_id||'_'||p_job_id||'_GET_FK_2';
  --l_table3:=p_bis_owner||'.TAB_'||p_mapping_id||'_'||p_job_id||'_GET_FK_3';
  --l_table4:=p_bis_owner||'.TAB_'||p_mapping_id||'_'||p_job_id||'_GET_FK_4';
  --l_table5:=p_bis_owner||'.TAB_'||p_mapping_id||'_'||p_job_id||'_GET_FK_5';
  l_table1:=p_bis_owner||'.TAB_'||p_mapping_id||'__GET_FK_1';
  l_table2:=p_bis_owner||'.TAB_'||p_mapping_id||'__GET_FK_2';
  l_table3:=p_bis_owner||'.TAB_'||p_mapping_id||'__GET_FK_3';
  l_table4:=p_bis_owner||'.TAB_'||p_mapping_id||'__GET_FK_4';
  l_table5:=p_bis_owner||'.TAB_'||p_mapping_id||'__GET_FK_5';--dependence on drop_stg_map_fk_details
  if p_job_id is null then --this is the main process
    if drop_table(l_table1)=false then
      null;
    end if;
    if drop_table(l_table2)=false then
      null;
    end if;
    if drop_table(l_table3)=false then
      null;
    end if;
    if drop_table(l_table4)=false then
      null;
    end if;
    if drop_table(l_table5)=false then
      null;
    end if;
    --Added for 6129040, Instead of inserting directly into the table using a select statement, here a cursor is used and inserted row by row
   -- into the table to avoid multiple inserts into the table in parallel.
    g_stmt:='create table  '||l_table1||
    ' (relation_name VARCHAR(255),'||
    ' relation_id NUMBER(9),'||
    ' dim_col VARCHAR(255),'||
    ' fstg_col VARCHAR(255),'||
    ' fact_col VARCHAR(255)) tablespace '||p_op_tablespace;

    if g_debug then
      write_to_log_file_n(g_stmt||get_time);
    end if;
    execute immediate g_stmt;
      write_to_log_file_n('Executed '||g_stmt||' '||get_time);
    l_stmt := 'INSERT INTO '||l_table1||' VALUES(:1,:2,:3,:4,:5)';
    rowCount := 0;
    write_to_log_file('Mapping id : '||p_mapping_id||' Fstg Usage Id:'||p_fstg_usage_id);
    OPEN getRows(p_mapping_id,p_fstg_usage_id);
    LOOP
      FETCH getRows INTO l_relation_name,l_relation_id,l_dim_col,l_fstg_col,l_fact_col;
      EXIT when getRows%NOTFOUND;
      EXECUTE IMMEDIATE l_stmt USING l_relation_name,l_relation_id,l_dim_col,l_fstg_col,l_fact_col;
      rowCount := rowCount + 1;
    END LOOP;
    CLOSE getRows;
    if g_debug then
      write_to_log_file_n('Created using cursors->'||rowCount||' <-rows '||get_time);
    end if;
    g_stmt:='create table '||l_table2||' tablespace '||p_op_tablespace||
    ' as select distinct relation_name from '||l_table1;
    if g_debug then
      write_to_log_file_n(g_stmt||get_time);
    end if;
    execute immediate g_stmt;
    if g_debug then
      write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
    end if;
    g_stmt:='create table '||l_table3||' tablespace '||p_op_tablespace||
    ' as select syn.table_owner,tab.relation_name from user_synonyms syn,'||l_table2||' tab '||
    'where tab.relation_name=syn.synonym_name(+)';
    if g_debug then
      write_to_log_file_n(g_stmt||get_time);
    end if;
    execute immediate g_stmt;
    if g_debug then
      write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
    end if;
    g_stmt:='create table '||l_table4||' tablespace '||p_op_tablespace||
    ' as select syn.table_owner,tab.* from '||l_table3||' syn,'||l_table1||' tab '||
    'where tab.relation_name=syn.relation_name';
    if g_debug then
      write_to_log_file_n(g_stmt||get_time);
    end if;
    execute immediate g_stmt;
    if g_debug then
      write_to_log_file_n('Created table4 with  '||sql%rowcount||' rows '||get_time);
    end if;
    g_stmt:='create table '||l_table5||' tablespace '||p_op_tablespace||
    ' as select all_tab.NUM_ROWS,tab.table_owner,tab.relation_name,tab.relation_id,'||
    'tab.dim_col,tab.fstg_col,tab.fact_col from '||l_table4||' tab, all_tables all_tab '||
    'where all_tab.table_name=tab.relation_name and all_tab.owner=tab.table_owner '||
    'and tab.table_owner is not null '||
    'union all '||
    'select 0,tab.table_owner,tab.relation_name,tab.relation_id,'||
    'tab.dim_col,tab.fstg_col,tab.fact_col from '||l_table4||' tab where tab.table_owner is null ';
    execute immediate g_stmt;
    if g_debug then
      write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
    end if;
  end if;

  g_stmt:='select relation_name,num_rows,relation_id,dim_col,fstg_col,fact_col from '||l_table5||
  ' order by num_rows,relation_name';
  p_numberOfDimTables:=1;
  if g_debug then
    write_to_log_file_n(g_stmt||get_time);
  end if;
  open cv for g_stmt;
  loop
    fetch cv into
    p_dimTableName(p_numberOfDimTables),
    p_dim_row_count(p_numberOfDimTables),
    p_dimTableId(p_numberOfDimTables),
    p_dimUserPKName(p_numberOfDimTables),
    p_fstgUserFKName(p_numberOfDimTables),
    p_factFKName(p_numberOfDimTables);
    exit when cv%notfound;
    l_rows_with_problem(p_numberOfDimTables):=false;
    p_numberOfDimTables:=p_numberOfDimTables+1;
  end loop;
  p_numberOfDimTables:=p_numberOfDimTables-1;
  if g_debug then
    write_to_log_file_n('The results of the FK read '||get_time);
    for i in 1..p_numberOfDimTables loop
      write_to_log_file(p_fstgUserFKName(i)||' '||p_dimTableName(i)||'('||p_dim_row_count(i)||') '||
      p_dimUserPKName(i)||' '||p_factFKName(i));
    end loop;
  end if;
  if p_job_id is null then
    if drop_table(l_table1)=false then
      null;
    end if;
    if drop_table(l_table2)=false then
      null;
    end if;
    if drop_table(l_table3)=false then
      null;
    end if;
    if drop_table(l_table4)=false then
      null;
    end if;
    --table preserved for child processes
    --if drop_table(l_table5)=false then
      --null;
    --end if;
  end if;
  --see if any correction is reqd for this metadata read.
  --this comes from bug 2739489
  --sometimes input group names clash in the src and tgt rep. during import the metadata gets messed up
  --go through the fact names and fstg names. if there is a descripency, then go into the stg table and
  --see the fk names
  if g_debug then
    write_to_log_file_n('Scan the FK to see if there is any problem');
  end if;
  l_rows_with_problem_found:=false;
  for i in 1..p_numberOfDimTables loop
    if instr(p_factFKName(i),p_fstgUserFKName(i))=0 then --there is no match in name
      if g_debug then
        write_to_log_file('Problem for '||p_factFKName(i)||' '||p_fstgUserFKName(i));
      end if;
      l_rows_with_problem(i):=true;
      l_rows_with_problem_found:=true;
    end if;
  end loop;
  if l_rows_with_problem_found then
    g_stmt:='select '||
    'fk_col.column_name, '||
    'p_table.relation_name '||
    'from '||
    'edw_relations_md_v fstg, '||
    'edw_foreign_keys_md_v fk, '||
    'EDW_PVT_KEY_COLUMNS_MD_V fku, '||
    'edw_pvt_columns_md_v fk_col, '||
    'edw_relations_md_v p_table, '||
    'edw_unique_keys_md_v pk '||
    'where '||
    'fstg.relation_id=fk.entity_id '||
    'and fk.foreign_key_id=fku.key_id '||
    'and fk_col.column_id=fku.column_id '||
    'and fk_col.parent_object_id=fstg.relation_id '||
    'and pk.key_id=fk.key_id '||
    'and pk.entity_id=p_table.relation_id '||
    'and fstg.relation_id=:1 ';
    l_number_stg:=1;
    if g_debug then
      write_to_log_file_n(g_stmt||' '||p_fstg_id||' '||get_time);
    end if;
    open cv for g_stmt using p_fstg_id;
    loop
      fetch cv into l_stg_fk(l_number_stg),l_stg_dim(l_number_stg);
      exit when cv%notfound;
      l_number_stg:=l_number_stg+1;
    end loop;
    l_number_stg:=l_number_stg-1;
    if g_debug then
      write_to_log_file_n('Staging fk');
      for i in 1..l_number_stg loop
        write_to_log_file(l_stg_fk(i)||' '||l_stg_dim(i));
      end loop;
    end if;
    for i in 1..p_numberOfDimTables loop
      if l_rows_with_problem(i) then
        l_found:=false;
        for j in 1..l_number_stg loop
          if l_stg_dim(j)=p_dimTableName(i) then
            if instr(p_factFKName(i),l_stg_fk(j))=1 then --found a match
              p_fstgUserFKName(i):=l_stg_fk(j);
              l_found:=true;
              exit;
            end if;
          end if;
        end loop;
        if l_found=false then
          if g_debug then
            write_to_log_file_n('For key '||p_factFKName(i)||' could not get a corresponding fk from '||
            'staging table');
          end if;
        end if;
      end if;
    end loop;
    if g_debug then
      write_to_log_file_n('After Corrections the FK Info '||get_time);
      for i in 1..p_numberOfDimTables loop
        write_to_log_file(p_fstgUserFKName(i)||' '||p_dimTableName(i)||'('||p_dim_row_count(i)||') '||
        p_dimUserPKName(i)||' '||p_factFKName(i));
      end loop;
    end if;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_stg_map_fk_details '||g_status_message);
  return false;
End;

function drop_stg_map_fk_details(
p_bis_owner varchar2,
p_mapping_id number
)return boolean is
Begin
  if drop_table(p_bis_owner||'.TAB_'||p_mapping_id||'__GET_FK_5')=false then
    null;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in drop_stg_map_fk_details '||g_status_message);
  return false;
End;

function get_stg_map_pk_params(
p_mapping_id number,
p_fstgTableUsageId out nocopy number,
p_fstgTableId out nocopy number,
p_fstgTableName out nocopy varchar2,
p_factTableUsageId out nocopy number,
p_factTableId out nocopy number,
p_factTableName out nocopy varchar2,
p_fstgPKName out nocopy varchar2,
p_factPKName out nocopy varchar2
) return boolean is
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  if g_debug then
    write_to_log_file_n('In get_stg_map_pk_params '||p_mapping_id);
  end if;
  g_stmt:='select '||
  'map_sources.source_usage_id, '||
  'map_sources.source_id, '||
  'src_table.name, '||
  'map_targets.target_usage_id, '||
  'map_targets.target_id, '||
  'tgt_relation.relation_name, '||
  'pk_col.column_name, '||
  'tgt_column.column_name '||
  'from '||
  'edw_pvt_map_properties_md_v map_properties, '||
  'edw_pvt_map_sources_md_v map_sources, '||
  'edw_pvt_map_targets_md_v map_targets, '||
  'edw_tables_md_v src_table, '||
  'edw_relations_md_v tgt_relation, '||
  'edw_unique_keys_md_v pk, '||
  'edw_pvt_key_columns_md_v key_usage, '||
  'edw_pvt_columns_md_v pk_col, '||
  '(select * from edw_pvt_map_columns_md_v where mapping_id=:1) map_columns, '||
  'edw_pvt_columns_md_v tgt_column '||
  'where '||
  'map_properties.mapping_id=:2 '||
  'and map_sources.source_id=map_properties.primary_source '||
  'and map_targets.target_id=map_properties.primary_target '||
  'and map_sources.mapping_id=map_properties.mapping_id '||
  'and src_table.elementid=map_sources.source_id '||
  'and map_targets.mapping_id=map_properties.mapping_id '||
  'and tgt_relation.relation_id=map_targets.target_id '||
  'and pk.entity_id=map_properties.primary_source '||
  'and key_usage.key_id=pk.key_id '||
  'and pk_col.column_id=key_usage.column_id '||
  'and map_columns.Source_usage_id=map_sources.source_usage_id '||
  'and map_columns.Source_column_id=pk_col.column_id '||
  'and map_columns.Target_column_id=tgt_column.column_id ';
  if g_debug then
    write_to_log_file_n(g_stmt||' '||p_mapping_id||' '||get_time);
  end if;
  open cv for g_stmt using p_mapping_id,p_mapping_id;
  fetch cv into
  p_fstgTableUsageId,
  p_fstgTableId,
  p_fstgTableName,
  p_factTableUsageId,
  p_factTableId,
  p_factTableName,
  p_fstgPKName,
  p_factPKName;
  close cv;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_stg_map_pk_params '||sqlerrm);
  return false;
End;

function create_conc_program(
p_conc_name varchar2,
p_conc_short_name varchar2,
p_exe_name varchar2,
p_exe_file_name varchar2,
p_bis_short_name varchar2,
p_parameter varcharTableType,
p_parameter_value_set varcharTableType,
p_number_parameters number
) return boolean is
l_bis_long_name varchar2(240);
l_parameter EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_parameter_value_set EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_parameters number;
Begin
  if g_debug then
    write_to_log_file_n('In create_conc_program '||get_time);
    write_to_log_file(p_conc_name||' '||p_conc_short_name ||' '||p_exe_name||' '||
    p_exe_file_name||' '||p_bis_short_name);
    write_to_log_file('Parameters');
    for i in 1..p_number_parameters loop
      write_to_log_file(p_parameter(i)||' '||p_parameter_value_set(i));
    end loop;
  end if;
  if get_app_long_name(p_bis_short_name,l_bis_long_name)=false then
    g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
    return false;
  end if;
  if delete_conc_program(p_conc_short_name,p_exe_name,l_bis_long_name,'LONG')=false then
    null;
  end if;
  FND_PROGRAM.executable(
    executable=>p_exe_name,
    application=>l_bis_long_name,
    short_name=>p_exe_name,
    description=>p_exe_name,
    execution_method=>'PL/SQL Stored Procedure',
    execution_file_name=>p_exe_file_name
    );
  if g_debug then
    write_to_log_file_n('Created executable '||p_exe_name);
  end if;
  FND_PROGRAM.REGISTER(
    program=>p_conc_name,
    application=>l_bis_long_name,
    enabled=>'Y',
    short_name=>p_conc_short_name,
    description=>p_conc_name,
    executable_short_name=>p_exe_name,
    executable_application=>l_bis_long_name,
    use_in_srs=>'Y',
    allow_disabled_values=>'Y'
    );
  if g_debug then
    write_to_log_file_n('Created program '||p_conc_name);
  end if;
  for i in 1..p_number_parameters loop
    FND_PROGRAM.PARAMETER(
    program_short_name=>p_conc_short_name,
    application=>l_bis_long_name,
    sequence=>i,
    parameter=>p_parameter(i),
    description=>p_parameter(i),
    enabled=>'Y',
    value_set=>p_parameter_value_set(i),
    default_type=>null,
    default_value=>null,
    required=>'Y',
    enable_security=>'N',
    range=>null,
    display=>'N',
    display_size=>10,
    description_size=>10,
    concatenated_description_size=>10,
    prompt=>p_parameter(i)
    );
  end loop;
  if g_debug then
    write_to_log_file_n('Created Parameters Complete!!');
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in create_conc_program '||g_status_message);
  write_to_log_file_n('FND_PROGRAM.MESSAGE='||FND_PROGRAM.MESSAGE);
  return false;
End;

function delete_conc_program(
p_conc_name varchar2,
p_exe_name varchar2,
p_bis_name varchar2,
p_name_type varchar2
) return boolean is
l_bis_long_name varchar2(400);
Begin
  if g_debug then
    write_to_log_file_n('In delete_conc_program');
  end if;
  if p_name_type='LONG' then
    l_bis_long_name:=p_bis_name;
  else
    if get_app_long_name(p_bis_name,l_bis_long_name)=false then
      null;
    end if;
  end if;
  FND_PROGRAM.DELETE_PROGRAM(p_conc_name,l_bis_long_name);
  FND_PROGRAM.DELETE_EXECUTABLE(p_exe_name,l_bis_long_name);
  if g_debug then
    write_to_log_file_n('Deleted '||p_conc_name||' '||p_exe_name);
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in delete_conc_program '||g_status_message);
  write_to_log_file_n('FND_PROGRAM.MESSAGE='||FND_PROGRAM.MESSAGE);
  return false;
End;

---------------------------------------------
function is_oracle_apps_GT_1159 return boolean is
l_list varcharTableType;
l_number_list number;
l_version_GT_1159 boolean;
Begin
  if get_app_version(null,null)=null then --this sets the global variable g_oracle_apps_version
    return false;
  end if;
  if parse_names(g_oracle_apps_version,'.',l_list,l_number_list)=false then
    return false;
  end if;
  if to_number(l_list(1))>11 then
    l_version_GT_1159:=true;
  elsif to_number(l_list(2))>5 then
    l_version_GT_1159:=true;
  elsif to_number(l_list(3))>9 then
    l_version_GT_1159:=true;
  else
    l_version_GT_1159:=false;
  end if;
  if l_version_GT_1159 then
    write_to_conc_log_file('Oracle Apps version > 11.5.9');
  else
    write_to_conc_log_file('Oracle Apps version NOT > 11.5.9');
  end if;
  return l_version_GT_1159;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_conc_log_file('Error in is_oracle_apps_GT_1159 '||g_status_message);
  return false;
End;

procedure init_all(
p_object_name varchar2,
p_debug boolean,
p_fnd_log_module varchar2
)is
Begin
  if p_object_name is not null then
    setup_conc_program_log(p_object_name);
  end if;
  if p_debug is not null then
    set_debug(p_debug);
  end if;
  if p_fnd_log_module is not null then
    g_fnd_log_module:=p_fnd_log_module;
  end if;
Exception when others then
  null;
End;

function get_parameter_value(
p_name varchar2
)return varchar2 is
l_var varchar2(200);
cursor cv(p_name varchar2) is select param.value from v$parameter param where param.name=p_name;
Begin
  if g_debug then
    write_to_log_file_n('select param.value from v$parameter param where param.name=:1 '||p_name);
  end if;
  open cv(p_name);
  fetch cv into l_var;
  close cv;
  if g_debug then
    write_to_log_file('value='||l_var);
  end if;
  return l_var;
EXCEPTION when others then
  write_to_log_file_n(g_status_message);
  return null;
End;

function get_db_version return varchar2 is
l_compatibility varchar2(40);
Begin
  if g_db_version is null then
    DBMS_UTILITY.DB_VERSION(g_db_version,l_compatibility);
  end if;
  if g_debug then
    write_to_log_file_n('DB version '||g_db_version);
  end if;
  return g_db_version;
EXCEPTION when others then
  write_to_log_file_n(g_status_message);
  return null;
End;

function is_db_version_gt(p_db_version varchar2,p_version varchar2) return boolean is
l_db_version varcharTableType;
l_num_db_version number;
l_version varcharTableType;
l_num_version number;
l_min number;
Begin
  if g_debug then
    write_to_log_file_n('is_db_version_gt, is '||p_db_version||' > '||p_version||'?');
  end if;
  if parse_names(p_db_version,'.',l_db_version,l_num_db_version)=false then
    return false;
  end if;
  if parse_names(p_version,'.',l_version,l_num_version)=false then
    return false;
  end if;
  if l_num_version>l_num_db_version then
    l_min:=l_num_db_version;
  else
    l_min:=l_num_version;
  end if;
  for i in 1..l_min loop
    if to_number(l_db_version(i))>to_number(l_version(i)) then
      if g_debug then
        write_to_log_file('Yes');
      end if;
      return true;
    end if;
    if to_number(l_db_version(i))<to_number(l_version(i)) then
      if g_debug then
        write_to_log_file('No');
      end if;
      return false;
    end if;
  end loop;
  if g_debug then
    write_to_log_file('Yes');
  end if;
  return true;
EXCEPTION when others then
  write_to_log_file_n(g_status_message);
  return false;
End;

--a generic table query api
function query_table_cols(
p_table varchar2,
p_col varchar2,
p_where varchar2,
p_output out nocopy varcharTableType,
p_num_output out nocopy number
) return boolean is
l_stmt varchar2(4000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  p_num_output:=1;
  l_stmt:='select '||p_col||' from '||p_table||' '||p_where;
  if g_debug then
    write_to_log_file_n(l_stmt||get_time);
  end if;
  open cv for l_stmt;
  loop
    fetch cv into p_output(p_num_output);
    exit when cv%notfound;
    p_num_output:=p_num_output+1;
  end loop;
  p_num_output:=p_num_output-1;
  if g_debug then
    write_to_log_file('Result');
    for i in 1..p_num_output loop
      write_to_log_file(p_output(i));
    end loop;
  end if;
  return true;
EXCEPTION when others then
  write_to_log_file_n(sqlerrm);
  return false;
End;

procedure dump_mem_stats is
l_stmt varchar2(2000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
---
l_sid number;
l_name varchar2(200);
l_mem number;
---
Begin
  if g_session_id is null then
    g_session_id:=USERENV('SESSIONID');
  end if;
  --for dbms jobs g_session_id=0
  if g_session_id>0 then
    l_stmt:='select ses.sid,sy.name,round(ss.value/1048576,2) from v$sesstat ss,v$sysstat sy,v$session ses '||
    'where sy.statistic#=ss.statistic# and ss.sid = ses.sid and ses.audsid=:1 and '||
    'sy.name in (''session pga memory'',''session pga memory max'',''session uga memory'',''session uga memory max'')';
    if g_debug then
      write_to_log_file_n('Mem stats '||get_time);
    end if;
    open cv for l_stmt using g_session_id;
    loop
      fetch cv into l_sid,l_name,l_mem;
      exit when cv%notfound;
      write_to_log_file(l_sid||' '||l_name||' '||l_mem);
    end loop;
    close cv;
  end if;
EXCEPTION when others then
  write_to_log_file_n('Error in dump_mem_stats '||sqlerrm);
End;

procedure dump_parallel_stats is
l_stmt varchar2(2000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
---
l_name varchar2(300);
l_query number;
l_total number;
---
Begin
  l_stmt:='select pq.statistic,pq.last_query,pq.session_total from v$pq_sesstat pq';
  if g_debug then
    write_to_log_file_n('Parellel stats '||get_time);
  end if;
  open cv for l_stmt;
  loop
    fetch cv into l_name,l_query,l_total;
    exit when cv%notfound;
    write_to_log_file(l_name||' '||l_query||' '||l_total);
  end loop;
EXCEPTION when others then
  write_to_log_file_n('Error in dump_parallel_stats '||sqlerrm);
End;

function check_and_wait_for_job(
p_job_id number,
p_status_table varchar2,
p_where varchar2,
p_sleep_time number,
p_status out nocopy varchar2,
p_message out nocopy varchar2
)return boolean is
---
l_status varcharTableType;
l_num_status number;
l_job_id numberTableType;
---
Begin
  if g_debug then
    write_to_log_file_n('In check_and_wait_for_job job_id='||p_job_id||',status_table='||p_status_table||
    'where='||p_where||get_time);
  end if;
  if p_job_id is null then
    p_status:='NO JOB';
    return true;
  end if;
  if query_table_cols(p_status_table,'status||''+++''||message',p_where,l_status,l_num_status)=false then
    --this means that the job did not start, kill the job
    if edw_owb_collection_util.terminate_job(p_job_id)=false then
      return false;
    end if;
    p_status:='NO JOB';
    return true;
  else
    if g_debug then
      write_to_log_file_n('No rows in '||p_status_table||', process dead or running');
    end if;
    if l_num_status=0 then
      --this means that there are no rows in the status table. process still running or process crashed
      if check_job_status(p_job_id)='Y' then
        --wait on job
        l_job_id(1):=p_job_id;
        if wait_on_jobs(
          l_job_id,
          1,
          p_sleep_time,
          'JOB')=false then
          return false;
        end if;
        --read the status again
        if query_table_cols(p_status_table,'status||''+++''||message',p_where,
          l_status,l_num_status)=false then
          return false;
        end if;
      else
        --process has crashed. we have to redo the steps.
        if g_debug then
          write_to_log_file_n('Child Process dead');
        end if;
        p_status:='NO JOB';
        return true;
      end if;
    end if;
  end if;
  p_status:=substr(l_status(1),1,instr(l_status(1),'+++')-1);
  p_message:=substr(l_status(1),instr(l_status(1),'+++')+3);
  return true;
EXCEPTION when others then
  write_to_log_file_n('Error in check_and_wait_for_job '||sqlerrm);
  return false;
End;

function get_tables_matching_pattern(
p_pattern varchar2,
p_owner varchar2,
p_table in out nocopy varcharTableType,
p_num_table in out nocopy number
)return boolean is
--
cursor c1(p_pattern varchar2,p_owner varchar2) is
select table_name from all_tables where table_name like p_pattern and owner=p_owner;
--
Begin
  if p_num_table is null then
    p_num_table:=0;
  end if;
  if g_debug then
    write_to_log_file_n('select table_name from all_tables where table_name like '||p_pattern||
    ' and owner='||p_owner);
  end if;
  open c1(p_pattern,p_owner);
  loop
    fetch c1 into p_table(p_num_table+1);
    exit when c1%notfound;
    p_num_table:=p_num_table+1;
  end loop;
  close c1;
  if g_debug then
    for i in 1..p_num_table loop
      write_to_log_file(p_table(i));
    end loop;
  end if;
  return true;
EXCEPTION when others then
  write_to_log_file_n('Error in get_tables_matching_pattern '||sqlerrm);
  return false;
End;

function update_status_table(
p_table varchar2,
p_col varchar2,
p_value varchar2,
p_where varchar2
) return boolean is
--
l_stmt varchar2(4000);
--
Begin
  l_stmt:='update '||p_table||' set '||p_col||'=:1 '||p_where;
  if g_debug then
    write_to_log_file_n(l_stmt||' '||p_value);
  end if;
  execute immediate l_stmt using p_value;
  return true;
EXCEPTION when others then
  write_to_log_file_n('Error in update_status_table '||sqlerrm);
  return false;
End;

function create_dd_status_table(
p_table varchar2,
p_level_order varcharTableType,
p_number_levels number
) return boolean is
--
cursor c1(p_ltc varchar2) is
select distinct
lvl.LEVEL_TABLE_ID,
rel.CHIL_LVLTBL_NAME,
rel.CHILD_LVLTBL_ID
from
edw_levels_md_v lvl,
edw_level_relations_md_v rel
where
lvl.LEVEL_TABLE_NAME=p_ltc
and rel.PARENT_LVL_ID(+)=lvl.level_id;
--
l_stmt varchar2(2000);
--
l_parent_id numberTableType;
l_ltc varcharTableType;
l_ltc_id numberTableType;
l_num_ltc number;
l_child_count number;
l_count number;
--
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
--
Begin
  if g_debug then
    write_to_log_file_n('In create_dd_status_table p_number_levels='||p_number_levels);
  end if;
  l_stmt:='create table '||p_table||'(level_order number,parent_ltc varchar2(200),'||
  'parent_ltc_id number,child_ltc varchar2(200),child_ltc_id number,job_id number,status varchar2(4000),'||
  'message varchar2(4000))';
  if g_debug then
    write_to_log_file_n(l_stmt);
  end if;
  if drop_table(p_table)=false then
    null;
  end if;
  execute immediate l_stmt;
  --
  if p_number_levels is not null then
    l_count:=0;
    for i in 1..p_number_levels loop
      if g_debug then
        write_to_log_file_n('select distinct rel.PARENT_LVLTBL_ID,rel.CHIL_LVLTBL_NAME,rel.CHILD_LVLTBL_ID '||
        'from edw_levels_md_v lvl,edw_level_relations_md_v rel where lvl.LEVEL_TABLE_NAME='||p_level_order(i)||
        ' and rel.PARENT_LVL_ID=lvl.level_id');
      end if;
      l_num_ltc:=1;
      open c1(p_level_order(i));
      loop
        fetch c1 into l_parent_id(l_num_ltc),l_ltc(l_num_ltc),l_ltc_id(l_num_ltc);
        exit when c1%notfound;
        l_num_ltc:=l_num_ltc+1;
      end loop;
      l_num_ltc:=l_num_ltc-1;
      close c1;
      if g_debug then
        for j in 1..l_num_ltc loop
          write_to_log_file(l_parent_id(j)||' '||l_ltc(j)||' '||l_ltc_id(j));
        end loop;
      end if;
      if l_num_ltc=1 and l_ltc_id(1) is null then
        --lowest level
        l_count:=l_count+1;
        l_stmt:='insert into '||p_table||'(level_order,parent_ltc,parent_ltc_id)'||
        ' values(:1,:2,:3)';
        execute immediate l_stmt using l_count,p_level_order(i),l_parent_id(1);
      else --parent levels
        l_child_count:=0;
        for j in 1..p_number_levels loop
          for k in 1..l_num_ltc loop
            if l_ltc(k)=p_level_order(j) then
              l_count:=l_count+1;
              l_child_count:=l_child_count+1;
              l_stmt:='insert into '||p_table||'(level_order,parent_ltc,parent_ltc_id,child_ltc,child_ltc_id)'||
              ' values(:1,:2,:3,:4,:5)';
              execute immediate l_stmt using l_count,p_level_order(i),l_parent_id(k),l_ltc(k),l_ltc_id(k);
            end if;
          end loop;
        end loop;
      end if;
    end loop;
  end if;
  commit;
  return true;
EXCEPTION when others then
  write_to_log_file_n('Error in create_dd_status_table '||sqlerrm);
  return false;
End;

function is_table_partitioned(p_table varchar2,p_owner varchar2) return varchar2 is
--
cursor c1(p_table varchar2,p_owner varchar2) is
select PARTITIONED from all_tables where table_name=p_table and owner=p_owner;
--
l_res varchar2(40);
Begin
  if g_debug then
    write_to_log_file_n('select PARTITIONED from all_tables where table_name='||p_table||' and owner='||
    p_owner);
  end if;
  open c1(p_table,p_owner);
  fetch c1 into l_res;
  close c1;
  if g_debug then
    write_to_log_file(l_res);
  end if;
  return l_res;
EXCEPTION when others then
  write_to_log_file_n('Error in is_table_partitioned '||sqlerrm);
  return null;
End;

function drop_level_UL_tables(
p_dim_id number,
p_bis_owner varchar2
) return boolean is
--
cursor c1(p_dim_id number) is
select LEVEL_TABLE_ID from edw_levels_md_v where dim_id=p_dim_id;
--
l_ltc_id number;
--
Begin
  open c1(p_dim_id);
  loop
    fetch c1 into l_ltc_id;
    exit when c1%notfound;
    if drop_table(p_bis_owner||'.TAB_'||l_ltc_id||'_UL')=false then
      null;
    end if;
  end loop;
  return true;
EXCEPTION when others then
  write_to_log_file_n('Error in drop_level_UL_tables '||sqlerrm);
  return false;
End;

function is_source_for_fast_refresh_mv(
p_object varchar2,
p_owner varchar2
) return number is
--
cursor c1(p_object varchar2,p_owner varchar2) is
select 1
from
ALL_MVIEWS mv,
ALL_MVIEW_DETAIL_RELATIONS rel
where
rel.mview_name=mv.mview_name
and mv.owner=rel.owner
and mv.fast_refreshable<>'NO'
and rel.detailobj_name=upper(p_object)
and rel.detailobj_owner=upper(p_owner)
and rownum=1;
--
l_res number;
--
Begin
  if g_debug then
    write_to_log_file_n('In is_source_for_fast_refresh_mv');
    write_to_log_file('select 1 from ALL_MVIEWS mv, ALL_MVIEW_DETAIL_RELATIONS rel '||
    ' where rel.mview_name=mv.mview_name and mv.owner=rel.owner and mv.fast_refreshable<>''NO'''||
    ' and rel.detailobj_name='||p_object||' and rel.detailobj_owner='||p_owner);
  end if;
  open c1(p_object,p_owner);
  fetch c1 into l_res;
  close c1;
  if l_res=1 then
    if g_debug then
      write_to_log_file('YES');
    end if;
  else
    if g_debug then
      write_to_log_file('NO');
    end if;
  end if;
  return l_res;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in is_source_for_fast_refresh_mv '||sqlerrm);
  return -1;
End;

function drop_tables_like(p_string varchar2,p_owner varchar2)return boolean is
--
cursor c1(p_string varchar2,p_owner varchar2) is
select table_name from all_tables where table_name like p_string and owner=p_owner;
--
l_table varchar2(100);
l_string varchar2(4000);
--
Begin
  l_string:=p_string;
  if instr(l_string,'.')>0 then
    l_string:=substr(l_string,instr(l_string,'.')+1);
  end if;
  if g_debug then
    write_to_log_file_n('In drop_tables_like, select table_name from all_tables where '||
    'table_name like '||l_string||' and owner='||p_owner);
  end if;
  open c1(l_string,p_owner);
  loop
    fetch c1 into l_table;
    exit when c1%notfound;
    if g_debug then
      write_to_log_file('Drop '||p_owner||'.'||l_table);
    end if;
    if drop_table(l_table,p_owner)=false then
      null;
    end if;
  end loop;
  return true;
EXCEPTION when others then
  write_to_log_file_n('Error in drop_tables_like '||sqlerrm);
  return false;
End;

--3529591
function get_all_derived_facts_inc(
p_object varchar2,
p_derived_facts out NOCOPY varcharTableType,
p_derived_fact_ids out NOCOPY numberTableType,
p_map_id  out NOCOPY numberTableType,
p_number_derived_facts out NOCOPY number) return boolean is
--
l_derived_facts varcharTableType;
l_derived_fact_ids numberTableType;
l_map_ids numberTableType;
l_number_derived_facts number;
--
Begin
  if g_debug then
    write_to_log_file_n('In get_all_derived_facts_inc ');
  end if;
  if get_all_derived_facts(p_object,l_derived_facts,l_derived_fact_ids,l_map_ids,l_number_derived_facts)=false then
    return false;
  end if;
  p_number_derived_facts:=0;
  for i in 1..l_number_derived_facts loop
    if is_inc_refresh_implemented(l_derived_facts(i))=true then
      p_number_derived_facts:=p_number_derived_facts+1;
      p_derived_facts(p_number_derived_facts):=l_derived_facts(i);
      p_derived_fact_ids(p_number_derived_facts):=l_derived_fact_ids(i);
      p_map_id(p_number_derived_facts):=l_map_ids(i);
    end if;
  end loop;
  if g_debug then
    write_to_log_file_n('INC Derived facts');
    for i in 1..p_number_derived_facts loop
      write_to_log_file(p_derived_facts(i)||' '||p_derived_fact_ids(i)||' '||p_map_id(i));
    end loop;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in  get_all_derived_facts_inc '||sqlerrm||' '||get_time);
  return false;
End;

--3529591
function get_fact_dfact_ilog(
p_bis_owner varchar2,
p_src_fact_id number,
p_derived_fact_id number) return varchar2 is
Begin
  return p_bis_owner||'.I_'||p_src_fact_id||'_'||p_derived_fact_id;
Exception when others then
  write_to_log_file_n('Exception in  get_fact_dfact_ilog '||sqlerrm||' '||get_time);
  return null;
End;

--3529591
function get_fact_dfact_dlog(
p_bis_owner varchar2,
p_src_fact_id number,
p_derived_fact_id number) return varchar2 is
Begin
  return p_bis_owner||'.D_'||p_src_fact_id||'_'||p_derived_fact_id;
Exception when others then
  write_to_log_file_n('Exception in  get_fact_dfact_dlog '||sqlerrm||' '||get_time);
  return null;
End;

/*
3529591
for a base fact that has a fast refresh mv on it.
after we refresh derived facts, we cannot clean the mv log and the ilog/dlog.
we can clean them only in the next round of load if the mv log is truncated.
mv log is truncated if mv refresh did run.
*/
function clean_ilog_dlog_base_fact(
p_fact varchar2,
p_owner varchar2,
p_bis_owner varchar2,
p_fact_id number,
p_fact_dlog varchar2
)return boolean is
--
l_derived_facts varcharTableType;
l_derived_fact_ids numberTableType;
l_map_id  numberTableType;
l_number_derived_facts number;
l_snplog varchar2(200);
l_ilog varchar2(200);
l_dlog varchar2(200);
--
Begin
  if g_debug then
    write_to_log_file_n('In clean_ilog_dlog_base_fact '||get_time);
  end if;
  if is_source_for_inc_derived_fact(p_fact)=1 and is_source_for_fast_refresh_mv(p_fact,p_owner)=1 then
    l_snplog:=get_table_snapshot_log(p_fact);
    if l_snplog is not null then
      if does_table_have_data(p_owner||'.'||l_snplog)=1 then
        --the mv log is empty. clean up the ilogs and dlogs and -DLOG table
        if instr(p_fact_dlog,'.')<>0 then
          if drop_table(p_fact_dlog)=false then
            return false;
          end if;
        else
          if truncate_table(p_fact_dlog,p_owner)=false then
            null;
          end if;
        end if;
        if get_all_derived_facts_inc(p_fact,l_derived_facts,l_derived_fact_ids,
          l_map_id,l_number_derived_facts)=false then
          g_status_message:=g_status_message;
          return false;
        end if;
        if l_number_derived_facts>0 then
          for i in 1..l_number_derived_facts loop
            l_ilog:=get_fact_dfact_ilog(p_bis_owner,p_fact_id,l_derived_fact_ids(i));
            l_dlog:=get_fact_dfact_dlog(p_bis_owner,p_fact_id,l_derived_fact_ids(i));
            if drop_table(l_ilog)=false then
              null;
            end if;
            if drop_table(l_ilog||'A')=false then
              null;
            end if;
            if drop_table(l_dlog)=false then
              null;
            end if;
            if drop_table(l_dlog||'A')=false then
              null;
            end if;
            if drop_ilog_tables(l_ilog||'_IL',null,p_bis_owner)=false then
              null;
            end if;
            if drop_ilog_tables(l_dlog||'_DL',null,p_bis_owner)=false then
              null;
            end if;
          end loop;
        end if;
      end if;
    end if;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in clean_ilog_dlog_base_fact '||g_status_message);
  return false;
End;

--4161164 : remove IOT , replace with ordinary table and index
procedure create_iot_index(
p_table varchar2,
p_column varchar2,
p_tablespace varchar2,
p_parallel number) is
--
l_stmt varchar2(20000);
Begin
  l_stmt:='create unique index '||p_table||'u on '||p_table||'('||p_column||') tablespace '||p_tablespace;
  if p_parallel is not null then
    l_stmt:=l_stmt||' parallel '||p_parallel;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file('Created '||get_time);
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in create_iot_index '||g_status_message);
  raise;
End;

FUNCTION get_apps_schema_name RETURN VARCHAR2 IS
  l_apps_schema_name VARCHAR2(30);
  CURSOR c_apps_schema_name IS
  SELECT oracle_username
  FROM fnd_oracle_userid WHERE oracle_id
  BETWEEN 900 AND 999 AND read_only_flag = 'U';
BEGIN
  OPEN c_apps_schema_name;
  FETCH c_apps_schema_name INTO l_apps_schema_name;
  CLOSE c_apps_schema_name;
  RETURN l_apps_schema_name;
EXCEPTION
  WHEN OTHERS THEN
  RETURN NULL;
END get_apps_schema_name;

END EDW_OWB_COLLECTION_UTIL;

/
