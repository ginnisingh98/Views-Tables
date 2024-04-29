--------------------------------------------------------
--  DDL for Package Body BSC_AW_BSC_METADATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_AW_BSC_METADATA" AS
/*$Header: BSCAWMDB.pls 120.16 2006/04/20 11:31 vsurendr noship $*/

procedure get_all_parent_child(
p_dim_level_list dbms_sql.varchar2_table,
p_dim_parent_child out nocopy BSC_AW_ADAPTER_DIM.dim_parent_child_tb,
p_dim_levels out nocopy BSC_AW_ADAPTER_DIM.levels_tv
) is
--
l_level_considered dbms_sql.varchar2_table;
--
Begin
  p_dim_parent_child.delete;
  l_level_considered.delete;
  p_dim_levels.delete;
  g_count:=0;--to test infinite recursion
  for i in 1..p_dim_level_list.count loop
    if not bsc_aw_utility.in_array(l_level_considered,p_dim_level_list(i)) then
      get_parent_children(p_dim_level_list(i),l_level_considered,p_dim_parent_child);
    end if;
  end loop;
  --get the level info
  get_all_distinct_levels(l_level_considered,p_dim_levels);
Exception when others then
  log_n('Exception in get_all_parent_child '||sqlerrm);
  raise;
End;

procedure get_parent_children(
p_level varchar2,
p_level_considered in out nocopy dbms_sql.varchar2_table,
p_dim_parent_child in out nocopy BSC_AW_ADAPTER_DIM.dim_parent_child_tb
) is
--
l_parents BSC_AW_ADAPTER_DIM.dim_parent_child_tb;
l_children BSC_AW_ADAPTER_DIM.dim_parent_child_tb;
--
l_count number;
--
Begin
  --p_level is the start level.
  if p_level is null then
    return;
  end if;
  g_count:=g_count+1;
  if g_count>100000 then
    log_n('Infinite loop detected in get_parent_children');
    raise g_exception;
  end if;
  if bsc_aw_utility.in_array(p_level_considered,p_level) then
    return;
  end if;
  p_level_considered(p_level_considered.count+1):=p_level;
  l_parents.delete;
  l_children.delete;
  bsc_metadata.get_parent_level(p_level,l_parents);
  bsc_metadata.get_child_level(p_level,l_children);
  --assume that a parent child pair exists as a unique row in bsc_sys_dim_level_rels
  l_count:=p_dim_parent_child.count;
  --have to handle single level RECURSIVE dimensions. rec dim must have single entry with parent=child
  if l_parents.count=0 then --this is single level dim or top level
    l_count:=l_count+1;
    p_dim_parent_child(l_count).parent_level:=null;
    p_dim_parent_child(l_count).child_level:=p_level;
  else
    for i in 1..l_parents.count loop
      l_count:=l_count+1;
      --l_parents(i) has the parent level, child level, child fk and parent pk
      p_dim_parent_child(l_count):=l_parents(i);
    end loop;
  end if;
  --for each child / parent, call this recursively. do this only for non rec dim
  if l_parents.count=1 and l_parents(1).parent_level=l_parents(1).child_level then
    --this is rec dim
    null;
  else
    --lets assume that there is no circular relation. otherwise, this can get into infinite recursion
    for i in 1..l_parents.count loop
      get_parent_children(l_parents(i).parent_level,p_level_considered,p_dim_parent_child);
    end loop;
    for i in 1..l_children.count loop
      get_parent_children(l_children(i).child_level,p_level_considered,p_dim_parent_child);
    end loop;
  end if;
Exception when others then
  log_n('Exception in get_parent_children '||sqlerrm);
  raise;
End;

procedure get_parent_level(p_level varchar2,p_parents out nocopy dbms_sql.varchar2_table) is
l_parents BSC_AW_ADAPTER_DIM.dim_parent_child_tb;
Begin
  bsc_metadata.get_parent_level(p_level,l_parents);
  for i in 1..l_parents.count loop
    if l_parents(i).parent_level is not null then
      p_parents(p_parents.count+1):=l_parents(i).parent_level;
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_parent_level '||sqlerrm);
  raise;
End;

procedure get_child_level(p_level varchar2,p_children out nocopy dbms_sql.varchar2_table) is
l_children BSC_AW_ADAPTER_DIM.dim_parent_child_tb;
Begin
  bsc_metadata.get_child_level(p_level,l_children);
  for i in 1..l_children.count loop
    if l_children(i).child_level is not null then
      p_children(p_children.count+1):=l_children(i).child_level;
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_child_level '||sqlerrm);
  raise;
End;

/*
position is not set here. its set in the dim adapter
*/
procedure get_all_distinct_levels(
p_levels dbms_sql.varchar2_table,
p_dim_levels out nocopy BSC_AW_ADAPTER_DIM.levels_tv
) is
--
l_level_id number;
l_level_pk varchar2(100);
l_level_pk_datatype varchar2(100);
l_level_source varchar2(100);
--
Begin
  if g_debug then
    log_n('In get_all_distinct_levels '||p_levels.count);
  end if;
  p_dim_levels.delete;
  for i in 1..p_levels.count loop
    --l_level_id: can this be null?
    log_n(p_levels(i));
    bsc_metadata.get_level_pk(p_levels(i),l_level_id,l_level_pk,l_level_pk_datatype,l_level_source);
    p_dim_levels(p_levels(i)).level_name:=p_levels(i);
    p_dim_levels(p_levels(i)).level_id:=l_level_id;
    p_dim_levels(p_levels(i)).pk.pk:=l_level_pk;
    p_dim_levels(p_levels(i)).pk.data_type:=l_level_pk_datatype;
    p_dim_levels(p_levels(i)).level_source:=l_level_source;
  end loop;
Exception when others then
  log_n('Exception in get_all_distinct_levels '||sqlerrm);
  raise;
End;

/*
we need to get the levels of the dim, then pass the levels to get the kpi involved
returns a kpi if a kpi has any of the levels as its dim. we also return the dim set
in which the dim levels are involved
*/
procedure get_kpi_for_dim(
p_dim in out nocopy bsc_aw_adapter_dim.dimension_r
) is
--
l_kpi dbms_sql.varchar2_table;
l_dimset dbms_sql.varchar2_table;
l_kpi_flag boolean;
l_dimset_flag boolean;
l_kpi_index number;
--
Begin
  for i in 1..p_dim.level_groups.count loop
    for j in 1..p_dim.level_groups(i).levels.count loop
      --NOTE!!! if a dim is std, then all kpi implemented in aw have this dim
      if p_dim.dim_type='std' then
        get_all_kpi_in_aw(l_kpi,l_dimset);
      else
        bsc_metadata.get_kpi_for_dim(p_dim.level_groups(i).levels(j).level_name,l_kpi,l_dimset);
      end if;
      --if both kpi+dimset already exists, do not add it. else add it.
      for k in 1..l_kpi.count loop
        l_kpi_flag:=false;
        l_dimset_flag:=false;
        l_kpi_index:=0;
        for m in 1..p_dim.kpi_for_dim.count loop
          if p_dim.kpi_for_dim(m).kpi=l_kpi(k) then
            l_kpi_flag:=true;
            l_kpi_index:=m;
            --does the dimset also exist?
            for n in 1..p_dim.kpi_for_dim(m).dim_set.count loop
              if p_dim.kpi_for_dim(m).dim_set(n)=l_dimset(k) then
                l_dimset_flag:=true;
                exit;
              end if;
            end loop;
            exit;
          end if;
        end loop;
        if l_kpi_flag and l_dimset_flag=false then
          p_dim.kpi_for_dim(l_kpi_index).dim_set(p_dim.kpi_for_dim(l_kpi_index).dim_set.count+1):=l_dimset(k);
        elsif l_kpi_flag=false and l_dimset_flag=false then
          p_dim.kpi_for_dim(p_dim.kpi_for_dim.count+1).kpi:=l_kpi(k);
          p_dim.kpi_for_dim(p_dim.kpi_for_dim.count).dim_set(p_dim.kpi_for_dim(p_dim.kpi_for_dim.count).dim_set.count+1):=l_dimset(k);
        end if;
      end loop;
    end loop;
  end loop;
Exception when others then
  log_n('Exception in get_kpi_for_dim '||sqlerrm);
  raise;
End;

--given a list of kpi, get the list of all dim levels that are referenced by the kpi
procedure get_dims_for_kpis(
p_kpi_list dbms_sql.varchar2_table,
p_dim_list out nocopy dbms_sql.varchar2_table
) is
Begin
  bsc_metadata.get_dims_for_kpis(p_kpi_list,p_dim_list);
Exception when others then
  log_n('Exception in get_dims_for_kpis '||sqlerrm);
  raise;
End;

/*
for DBI rec dim. we will have to get the info we need from static package or optimizer std output.
for any dim, there can be only 1 data source for all the levels. if there are 2 levels, then the data
source will be like
(select level1, level2 from ...)
*/
procedure create_rec_data_source(
p_dimension in out nocopy bsc_aw_adapter_dim.dimension_r
) is
Begin
  create_data_source(p_dimension);
  --if rec dim, also set the denorm data source
  --rec dim have only 1 level
  if p_dimension.recursive='Y' then
    bsc_metadata.get_denorm_data_source(
    p_dimension.level_groups(1).levels(1).level_name,
    p_dimension.level_groups(1).data_source.child_col,
    p_dimension.level_groups(1).data_source.parent_col,
    p_dimension.level_groups(1).data_source.position_col,
    p_dimension.level_groups(1).data_source.denorm_data_source,
    p_dimension.level_groups(1).data_source.denorm_change_data_source);
  end if;
Exception when others then
  log_n('Exception in create_rec_data_source '||sqlerrm);
  raise;
End;

/*
This procedure creates the data source for non rec dbi dimensions
*/
procedure create_data_source(
p_dimension in out nocopy bsc_aw_adapter_dim.dimension_r
) is
l_level_list dbms_sql.varchar2_table;
l_level_pk_col dbms_sql.varchar2_table;
Begin
  for i in 1..p_dimension.level_groups(1).levels.count loop
    l_level_list(i):=p_dimension.level_groups(1).levels(i).level_name;
  end loop;
  bsc_metadata.get_dim_data_source(l_level_list,l_level_pk_col,
  p_dimension.level_groups(1).data_source.data_source,p_dimension.level_groups(1).data_source.inc_data_source);
  --for bsc dimensions, p_dimension.level_groups(1).data_source.data_source will be null
  --it will be non null only foR DBI dimensions
  if p_dimension.level_groups(1).data_source.data_source is not null then
    for i in 1..p_dimension.level_groups(1).levels.count loop
      p_dimension.level_groups(1).data_source.dim_name(i):=p_dimension.level_groups(1).levels(i).level_name;
      p_dimension.level_groups(1).data_source.pk_col(i):=l_level_pk_col(i);
    end loop;
  end if;
Exception when others then
  log_n('Exception in create_data_source '||sqlerrm);
  raise;
End;

procedure set_dim_recursive(p_dimension in out nocopy bsc_aw_adapter_dim.dimension_r) is
Begin
  --in rec dim, there is only 1 level
  p_dimension.recursive:=bsc_metadata.is_dim_recursive(p_dimension.level_groups(1).levels(1).level_name);
  if p_dimension.recursive='Y' then
    p_dimension.recursive_norm_hier:='Y'; --implement rec dim as normal by default
  end if;
Exception when others then
  log_n('Exception in set_dim_recursive '||sqlerrm);
  raise;
End;

procedure get_kpi_for_calendar(p_calendar in out nocopy bsc_aw_calendar.calendar_r) is
l_kpi_list dbms_sql.varchar2_table;
Begin
  bsc_metadata.get_kpi_for_calendar(p_calendar.calendar_id,l_kpi_list);
  for i in 1..l_kpi_list.count loop
    p_calendar.kpi_for_dim(i).kpi:=l_kpi_list(i);
  end loop;
Exception when others then
  log_n('Exception in get_kpi_for_calendar '||sqlerrm);
  raise;
End;

/*
gets
calendar kpi belongs to
*/
procedure get_kpi_properties(p_kpi in out nocopy bsc_aw_adapter_kpi.kpi_r) is
l_calendar number;
Begin
  bsc_metadata.get_kpi_calendar(p_kpi.kpi,l_calendar);
  p_kpi.calendar:=l_calendar;
Exception when others then
  log_n('Exception in get_kpi_properties '||sqlerrm);
  raise;
End;

/*
given a kpi find out
1. dim sets
*/
procedure get_kpi_dim_sets(p_kpi in out nocopy bsc_aw_adapter_kpi.kpi_r) is
l_dim_set dbms_sql.varchar2_table;
Begin
  bsc_metadata.get_kpi_dim_sets(p_kpi.kpi,l_dim_set);
  --l_dim_set will be numbers like 1,2 etc to make the name unique, append with kpi
  for i in 1..l_dim_set.count loop
    p_kpi.dim_set(i).dim_set:=l_dim_set(i);
    p_kpi.dim_set(i).dim_set_name:='dimset_'||l_dim_set(i)||'_'||p_kpi.kpi;
  end loop;
Exception when others then
  log_n('Exception in get_kpi_dim_sets '||sqlerrm);
  raise;
End;

/*
a dim set will have dim levels from diff dimensions. it can have city,state,product,prod category and customer
the info that city and state belong to geog dim is in bsc olap objects. this package does not access bsc_olap_objects
its a one way access to bsc metadata. so this procedure returns the list of dim levels to kpi adapter. the kpi adapter
will access bsc olap metadata to group these dim levels into Concat dims
*/
procedure get_dim_set_dims(
p_kpi varchar2,
p_dim_set varchar2,
p_dim_level out nocopy dbms_sql.varchar2_table,
p_mo_dim_group out nocopy dbms_sql.varchar2_table,
p_skip_level out nocopy dbms_sql.varchar2_table
) is
Begin
  bsc_metadata.get_dim_set_dims(p_kpi,p_dim_set,p_dim_level,p_mo_dim_group,p_skip_level);
Exception when others then
  log_n('Exception in get_dim_set_dims '||sqlerrm);
  raise;
End;

/*
given a dim set, find out all info about the measures
unlike get_dim_set_dims, we directly set the dim_set data structure with the measure properties
measures belong to kpi and dim sets within the kpi
*/
procedure get_dim_set_measures(
p_kpi varchar2,
p_dim_set varchar2,
p_measure in out nocopy bsc_aw_adapter_kpi.measure_tb
) is
l_measure dbms_sql.varchar2_table;
l_measure_type dbms_sql.varchar2_table;
l_data_type dbms_sql.varchar2_table;
l_agg_formula dbms_sql.varchar2_table;
l_projection dbms_sql.varchar2_table;
l_property dbms_sql.varchar2_table;
Begin
  p_measure.delete;
  bsc_metadata.get_dim_set_measures(p_kpi,p_dim_set,l_measure,l_measure_type,l_data_type,l_agg_formula,l_projection,l_property);
  for i in 1..l_measure.count loop
    p_measure(i).measure:=l_measure(i);
    p_measure(i).measure_type:=l_measure_type(i);
    p_measure(i).data_type:=l_data_type(i);
    p_measure(i).agg_formula.agg_formula:=l_agg_formula(i);
    p_measure(i).agg_formula.sql_agg_formula:=l_agg_formula(i);
    if upper(p_measure(i).agg_formula.sql_agg_formula)='AVERAGE' then /*database avg function is AVG */
      p_measure(i).agg_formula.sql_agg_formula:='AVG';
    end if;
    p_measure(i).agg_formula.std_aggregation:=bsc_aw_utility.is_std_aggregation_function(l_agg_formula(i));--Y N
    p_measure(i).agg_formula.avg_aggregation:=bsc_aw_utility.is_avg_aggregation_function(l_agg_formula(i));--Y N
    p_measure(i).sql_aggregated:='N';/*default */
    p_measure(i).forecast:=l_projection(i);
    p_measure(i).forecast_method:=null;--for now, we dont implement projection in aw
    bsc_aw_utility.merge_property(p_measure(i).property,l_property(i),',');/*if BALANCE LAST VALUE, this can contain balance loaded Y/N column name */
  end loop;
Exception when others then
  log_n('Exception in get_dim_set_measures '||sqlerrm);
  raise;
End;

/*
given a dimset, get all the S views and their properties
gets both ZMV and regular MV
*/
procedure get_s_views(p_kpi varchar2,p_dim_set in out nocopy bsc_aw_adapter_kpi.dim_set_r) is
l_s_views dbms_sql.varchar2_table;
l_levels dbms_sql.varchar2_table;
l_sview_level bsc_aw_adapter_kpi.level_r;
Begin
  --get_s_views will return only regular MV not ZMV
  bsc_metadata.get_s_views(p_kpi,p_dim_set.dim_set,l_s_views);
  --for each s view get the level info
  for i in 1..l_s_views.count loop
    l_levels.delete;
    bsc_metadata.get_s_view_levels(l_s_views(i),l_levels);
    p_dim_set.s_view(p_dim_set.s_view.count+1).s_view:=l_s_views(i);
    p_dim_set.s_view(p_dim_set.s_view.count).id:='MV_'||i;
    for j in 1..l_levels.count loop
      --note>>>a level can be in 1 dim only, even in the case of standalone levels
      p_dim_set.s_view(p_dim_set.s_view.count).dim(j):=bsc_aw_adapter_kpi.get_kpi_level_dim_r(p_dim_set,l_levels(j));
      l_sview_level:=bsc_aw_adapter_kpi.get_dim_level_r(p_dim_set.s_view(p_dim_set.s_view.count).dim(j),l_levels(j));
      p_dim_set.s_view(p_dim_set.s_view.count).dim(j).levels.delete; --only hold the s view level info
      p_dim_set.s_view(p_dim_set.s_view.count).dim(j).levels(1):=l_sview_level;
    end loop;
  end loop;
  --get the ZMV
  l_s_views.delete;
  bsc_metadata.get_z_s_views(p_kpi,p_dim_set.dim_set,l_s_views);
  for i in 1..l_s_views.count loop
    l_levels.delete;
    bsc_metadata.get_s_view_levels(l_s_views(i),l_levels);
    p_dim_set.z_s_view(p_dim_set.z_s_view.count+1).s_view:=l_s_views(i);
    p_dim_set.z_s_view(p_dim_set.z_s_view.count).id:='ZMV_'||i;
    for j in 1..l_levels.count loop
      p_dim_set.z_s_view(p_dim_set.z_s_view.count).dim(j):=bsc_aw_adapter_kpi.get_kpi_level_dim_r(p_dim_set,l_levels(j));
      l_sview_level:=bsc_aw_adapter_kpi.get_dim_level_r(p_dim_set.z_s_view(p_dim_set.z_s_view.count).dim(j),l_levels(j));
      p_dim_set.z_s_view(p_dim_set.z_s_view.count).dim(j).levels.delete;
      p_dim_set.z_s_view(p_dim_set.z_s_view.count).dim(j).levels(1):=l_sview_level;
    end loop;
  end loop;
Exception when others then
  log_n('Exception in get_s_views '||sqlerrm);
  raise;
End;

function is_target_at_higher_level(p_kpi varchar2,p_dim_set varchar2) return varchar2 is
Begin
  return bsc_metadata.is_target_at_higher_level(p_kpi,p_dim_set);
Exception when others then
  log_n('Exception in is_target_at_higher_level '||sqlerrm);
  raise;
End;

--this api called only when there are targets at higher levels
procedure get_target_dim_levels(p_kpi varchar2,p_target_dim_set in out nocopy bsc_aw_adapter_kpi.dim_set_r) is
l_levels dbms_sql.varchar2_table;
l_dim bsc_aw_adapter_kpi.dim_tb;--just temp backup
Begin
  --backup dim and level info
  l_dim:=p_target_dim_set.dim;
  --delete all level info
  for i in 1..p_target_dim_set.dim.count loop
    p_target_dim_set.dim(i).levels.delete;
  end loop;
  bsc_metadata.get_target_levels(p_kpi,p_target_dim_set.dim_set,l_levels);
  --now for these levels, fill in the dim info
  for i in 1..l_dim.count loop
    for j in 1..l_dim(i).levels.count loop
      if bsc_aw_utility.in_array(l_levels,l_dim(i).levels(j).level_name) then
        p_target_dim_set.dim(i).levels(p_target_dim_set.dim(i).levels.count+1):=l_dim(i).levels(j);
      end if;
    end loop;
  end loop;
  --get the filter at the lowest level for the target
  --levels(1) is the lowest level of the target
  for i in 1..p_target_dim_set.dim.count loop
    get_dim_level_filter(p_kpi,p_target_dim_set.dim(i).levels(1));
  end loop;
Exception when others then
  log_n('Exception in get_target_dim_levels '||sqlerrm);
  raise;
End;

procedure get_target_dim_periodicity(p_kpi varchar2,p_target_dim_set in out nocopy bsc_aw_adapter_kpi.dim_set_r) is
--
l_periodicities dbms_sql.number_table;
l_calendar bsc_aw_adapter_kpi.calendar_r;
Begin
  --backup
  l_calendar:=p_target_dim_set.calendar;
  p_target_dim_set.calendar.periodicity.delete;
  --bsc_metadata.get_target_periodicity will only return lowest periodicity for targets
  bsc_metadata.get_target_periodicity(p_kpi,p_target_dim_set.dim_set,l_periodicities);
  for i in 1..l_calendar.periodicity.count loop
    if bsc_aw_utility.in_array(l_periodicities,l_calendar.periodicity(i).periodicity) then
      p_target_dim_set.calendar.periodicity(p_target_dim_set.calendar.periodicity.count+1):=l_calendar.periodicity(i);
      p_target_dim_set.calendar.periodicity(p_target_dim_set.calendar.periodicity.count).lowest_level:='Y'; --these are lowest level for targets
    end if;
  end loop;
  --NOTE!! the periodicity we have added for targets is the lowest periodicity only. we have to add the upper periodicities
  --l_calendar has the parent child relations in it
  for i in 1..p_target_dim_set.calendar.periodicity.count loop
    fill_in_target_periodicity(p_target_dim_set.calendar,l_calendar,p_target_dim_set.calendar.periodicity(i).aw_dim);
  end loop;
Exception when others then
  log_n('Exception in get_target_dim_periodicity '||sqlerrm);
  raise;
End;

/*
fill in higher periodicities for targets
*/
procedure fill_in_target_periodicity(
p_target_calendar in out nocopy bsc_aw_adapter_kpi.calendar_r,
p_source_calendar bsc_aw_adapter_kpi.calendar_r,
p_periodicity varchar2
) is
--
l_flag boolean;
l_periodicity bsc_aw_adapter_kpi.periodicity_r;
Begin
  if p_periodicity is not null then
    l_flag:=false;
    for i in 1..p_target_calendar.periodicity.count loop
      if p_target_calendar.periodicity(i).aw_dim=p_periodicity then
        l_flag:=true;
      end if;
    end loop;
    if l_flag=false then
      p_target_calendar.periodicity(p_target_calendar.periodicity.count+1):=bsc_aw_adapter_kpi.get_periodicity_r(p_source_calendar.periodicity,
      p_periodicity);
    end if;
    for i in 1..p_source_calendar.parent_child.count loop
      if p_source_calendar.parent_child(i).child_dim_name=p_periodicity then
      --and p_source_calendar.parent_child(i).parent_dim_name is not null then
        --only if the parent periodicity is a part of the kpi calendar
        l_flag:=false;
        for j in 1..p_source_calendar.periodicity.count loop
          if p_source_calendar.periodicity(j).aw_dim=p_source_calendar.parent_child(i).parent_dim_name then
            l_flag:=true;
            exit;
          end if;
        end loop;
        if l_flag then
          fill_in_target_periodicity(p_target_calendar,p_source_calendar,p_source_calendar.parent_child(i).parent_dim_name);
        end if;
      end if;
    end loop;
  end if;
Exception when others then
  log_n('Exception in fill_in_target_periodicity '||sqlerrm);
  raise;
End;

/*
given a kpi and the dim set, find out the levels and their dim where there is zero code
*/
procedure check_dim_zero_code(p_kpi varchar2,p_dim_set in out nocopy bsc_aw_adapter_kpi.dim_set_r) is
l_levels dbms_sql.varchar2_table;
Begin
  bsc_metadata.get_zero_code_levels(p_kpi,p_dim_set.dim_set,l_levels);
  for i in 1..p_dim_set.dim.count loop
    for j in 1..p_dim_set.dim(i).levels.count loop
      if bsc_aw_utility.in_array(l_levels,p_dim_set.dim(i).levels(j).level_name) then
        --we can say there is zero code only if there is zero code level for this level
        --we can do this since check_dim_zero_code comes after get_dim_properties in bsc_aw_adapter_kpi
        if p_dim_set.dim(i).levels(j).zero_code_level is not null then
          p_dim_set.dim(i).levels(j).zero_code:='Y';
          p_dim_set.dim(i).zero_code:='Y';
        end if;
      end if;
    end loop;
  end loop;
Exception when others then
  log_n('Exception in check_dim_zero_code '||sqlerrm);
  raise;
End;

/*
for each level get the pk,fk, datatype info
*/
procedure get_dim_level_properties(p_kpi varchar2,p_dim in out nocopy bsc_aw_adapter_kpi.dim_r) is
Begin
  for i in 1..p_dim.levels.count loop
    p_dim.levels(i).level_type:=p_dim.property; --normal or time
    bsc_metadata.get_dim_level_properties(p_dim.levels(i).level_name,
    p_dim.levels(i).pk,p_dim.levels(i).fk,p_dim.levels(i).data_type,p_dim.levels(i).level_source);
  end loop;
  --get the filter for the lowest level in the kpi
  get_dim_level_filter(p_kpi,p_dim.levels(1));
Exception when others then
  log_n('Exception in get_dim_level_properties '||sqlerrm);
  raise;
End;

procedure get_dim_level_filter(p_kpi varchar2,p_level in out nocopy bsc_aw_adapter_kpi.level_r) is
Begin
  bsc_metadata.get_dim_level_filter(p_kpi,p_level.level_name,p_level.filter);
Exception when others then
  log_n('Exception in get_dim_level_filter '||sqlerrm);
  raise;
End;

/*
get base tables involved in the dim set
for each base table, get the level at which it is
get the measures the base table feeds
get the formula for each measure
--
each base table is a data source
get_base_table_levels : gets all the levels of the base table
we need all the levels because we need to know if the base table has more levels than the dim set
get_base_table_measures : gets the measures relevant to this dim set
--
consider this: dimset is at month,week...both lowest levels. 2 base tables. both at day level. due to this, datasource
periodicity was null.
(we were doing if p_dim_set.data_source(i).base_tables(1).periodicity.periodicity=p_dim_set.calendar.periodicity(j).periodicity then)
new logic: if the base table periodicity is not the same as any of the lowest periodicities, we create as many datasources for
each lowest level periodicity
more correction. in bsc, B table to S table mapping is stored. this means a day level B table may feed only week and another
day level B table feeds month.
if the B table is at a lower periodicity, we need to check which periodicity it feeds
*/
procedure get_dim_set_data_source(p_kpi varchar2,p_dim_set in out nocopy bsc_aw_adapter_kpi.dim_set_r) is
l_base_tables dbms_sql.varchar2_table;
l_data_source bsc_aw_adapter_kpi.data_source_r;
l_ds_periodicity bsc_aw_adapter_kpi.periodicity_tb;
l_ds_copy bsc_aw_adapter_kpi.data_source_r;
l_feed_periodicity dbms_sql.number_table;
Begin
  if p_dim_set.dim_set_type='actual' then
    bsc_metadata.get_dim_set_base_tables(p_kpi,p_dim_set.dim_set,l_base_tables);
  else
    bsc_metadata.get_dim_set_target_base_tables(p_kpi,p_dim_set.dim_set,l_base_tables);
  end if;
  --every base table is a data source
  for i in 1..l_base_tables.count loop
    l_data_source:=null;
    get_base_table_data_source(p_kpi,p_dim_set.dim_set,l_base_tables(i),l_data_source);
    set_measure_properties(p_dim_set,l_data_source);
    l_ds_periodicity.delete;
    for j in 1..p_dim_set.calendar.periodicity.count loop
      if p_dim_set.calendar.periodicity(j).lowest_level='Y'
      and p_dim_set.calendar.periodicity(j).periodicity=l_data_source.base_tables(1).periodicity.periodicity then
        l_ds_periodicity(l_ds_periodicity.count+1):=p_dim_set.calendar.periodicity(j);
        exit;
      end if;
    end loop;
    if l_ds_periodicity.count=0 then --B table lower periodicity
      l_feed_periodicity.delete;
      get_B_table_feed_periodicity(p_kpi,p_dim_set.dim_set,l_base_tables(i),l_feed_periodicity);
      for j in 1..p_dim_set.calendar.periodicity.count loop
        if p_dim_set.calendar.periodicity(j).lowest_level='Y'
        and bsc_aw_utility.in_array(l_feed_periodicity,p_dim_set.calendar.periodicity(j).periodicity) then
          l_ds_periodicity(l_ds_periodicity.count+1):=p_dim_set.calendar.periodicity(j);
        end if;
      end loop;
    end if;
    if l_ds_periodicity.count=0 then --B table at higher periodicity
      for j in 1..l_feed_periodicity.count loop
        for k in 1..p_dim_set.calendar.periodicity.count loop
          if p_dim_set.calendar.periodicity(k).periodicity=l_feed_periodicity(j) then
            l_ds_periodicity(l_ds_periodicity.count+1):=p_dim_set.calendar.periodicity(k);
            exit;
          end if;
        end loop;
      end loop;
    end if;
    if l_ds_periodicity.count=0 then --problem...
      log('No target periodicity for B table '||l_base_tables(i)||' could be determined. Fatal...');
      raise bsc_aw_utility.g_exception;
    end if;
    for j in 1..l_ds_periodicity.count loop
      if g_debug then
        log('Create datasource for B table '||l_base_tables(i)||' and periodicity '||l_ds_periodicity(j).periodicity);
      end if;
      p_dim_set.data_source(p_dim_set.data_source.count+1):=l_data_source; --copy B table info
      p_dim_set.data_source(p_dim_set.data_source.count).ds_type:='initial';
      p_dim_set.data_source(p_dim_set.data_source.count).std_dim:=p_dim_set.std_dim;
      p_dim_set.data_source(p_dim_set.data_source.count).dim:=p_dim_set.dim;
      p_dim_set.data_source(p_dim_set.data_source.count).calendar:=p_dim_set.calendar;
      p_dim_set.data_source(p_dim_set.data_source.count).calendar.periodicity.delete;
      p_dim_set.data_source(p_dim_set.data_source.count).calendar.periodicity(1):=l_ds_periodicity(j);
      /*starting from the periodicity of the ds as the lowest level, get the upper part of cal hier*/
      get_ds_relevant_cal_hier(p_dim_set.data_source(p_dim_set.data_source.count).calendar);
      --copy this info into the inc data source
      --later the data_source_stmt is populated differently for data source and inc data source
      l_ds_copy:=p_dim_set.data_source(p_dim_set.data_source.count);
      p_dim_set.inc_data_source(p_dim_set.data_source.count):=l_ds_copy;
      p_dim_set.inc_data_source(p_dim_set.data_source.count).ds_type:='inc';
    end loop;
  end loop;
Exception when others then
  log_n('Exception in get_dim_set_data_source '||sqlerrm);
  raise;
End;

/*set the measure properties from dimset into datasource (In get_base_table_data_source only the measure name is set)*/
procedure set_measure_properties(p_dim_set bsc_aw_adapter_kpi.dim_set_r,p_data_source in out nocopy bsc_aw_adapter_kpi.data_source_r) is
Begin
  for i in 1..p_data_source.measure.count loop
    for j in 1..p_dim_set.measure.count loop
      if lower(p_dim_set.measure(j).measure)=lower(p_data_source.measure(i).measure) then
        p_data_source.measure(i).measure_type:=p_dim_set.measure(j).measure_type;
        p_data_source.measure(i).data_type:=p_dim_set.measure(j).data_type;
        /*we do not set the formulas. formula is a DS property, not a dimset property*/
        p_data_source.measure(i).forecast:=p_dim_set.measure(j).forecast;
        p_data_source.measure(i).forecast_method:=p_dim_set.measure(j).forecast_method;
        p_data_source.measure(i).cube:=p_dim_set.measure(j).cube;--null at this point
        p_data_source.measure(i).countvar_cube:=p_dim_set.measure(j).countvar_cube;--null at this point
        p_data_source.measure(i).fcst_cube:=p_dim_set.measure(j).fcst_cube;--null at this point
        p_data_source.measure(i).property:=p_dim_set.measure(j).property;
        exit;
      end if;
    end loop;
  end loop;
Exception when others then
  log_n('Exception in set_measure_properties '||sqlerrm);
  raise;
End;

/*the DS is at some higher level. get just the upper part of the cal hier */
procedure get_ds_relevant_cal_hier(p_calendar in out nocopy bsc_aw_adapter_kpi.calendar_r) is
l_upper_hier bsc_aw_adapter_kpi.cal_parent_child_tb;
Begin
  bsc_aw_adapter_kpi.get_upper_cal_hier(p_calendar.parent_child,p_calendar.periodicity(1).aw_dim,l_upper_hier);
  p_calendar.parent_child.delete;
  for i in 1..l_upper_hier.count loop
    p_calendar.parent_child(p_calendar.parent_child.count+1):=l_upper_hier(i);
  end loop;
Exception when others then
  log_n('Exception in get_ds_relevant_cal_hier '||sqlerrm);
  raise;
End;

--given a B table, what are the target periodicities it feeds
procedure get_B_table_feed_periodicity(p_kpi varchar2,p_dim_set varchar2,p_base_table varchar2,p_feed_periodicity out nocopy dbms_sql.number_table) is
Begin
  bsc_metadata.get_B_table_feed_periodicity(p_kpi,p_dim_set,p_base_table,p_feed_periodicity);
Exception when others then
  log_n('Exception in get_B_table_feed_periodicity '||sqlerrm);
  raise;
End;

/*
for a base table, finds the levels and measures and formula involved
for now, we are saying a data source has 1 base table
also find the periodicity of the base table
*/
procedure get_base_table_data_source(
p_kpi varchar2,
p_dim_set varchar2,
p_base_table varchar2,
p_data_source in out nocopy bsc_aw_adapter_kpi.data_source_r) is
--
l_bt_levels dbms_sql.varchar2_table;
l_bt_feed_levels dbms_sql.varchar2_table;
l_bt_level_fks dbms_sql.varchar2_table; --contains the fk like city_code etc from the base table
l_bt_level_pks dbms_sql.varchar2_table;
l_ds_measures dbms_sql.varchar2_table;--data source measures , same as dim set measures
l_formula dbms_sql.varchar2_table;
l_level bsc_aw_adapter_kpi.level_r;
l_prj_table varchar2(100);
l_partition bsc_aw_utility.object_partition_r;
l_bt_copy bsc_aw_adapter_kpi.base_table_r;
Begin
  bsc_metadata.get_base_table_levels(p_kpi,p_dim_set,p_base_table,l_bt_levels,l_bt_level_fks,l_bt_level_pks,l_bt_feed_levels);
  bsc_metadata.get_base_table_measures(p_kpi,p_dim_set,p_base_table,l_ds_measures,l_formula);
  bsc_metadata.get_base_table_periodicity(p_base_table,p_data_source.base_tables(1).periodicity.periodicity);
  bsc_metadata.get_base_table_properties(p_base_table,l_prj_table,l_partition);
  --
  p_data_source.base_tables(1).base_table_name:=p_base_table;
  p_data_source.base_tables(1).projection_table:=l_prj_table;
  p_data_source.base_tables(1).table_partition:=l_partition;
  for i in 1..l_bt_levels.count loop
    p_data_source.base_tables(1).levels(i).level_name:=l_bt_levels(i);
    p_data_source.base_tables(1).levels(i).fk:=l_bt_level_fks(i);
    p_data_source.base_tables(1).levels(i).pk:=l_bt_level_pks(i);
    p_data_source.base_tables(1).feed_levels(i):=l_bt_feed_levels(i); --Y or N
  end loop;
  for i in 1..l_ds_measures.count loop
    p_data_source.measure(i).measure:=l_ds_measures(i);
    p_data_source.measure(i).formula:=l_formula(i);
  end loop;
  /*if there is prj table, we add the prj table as another B table for the DS
  */
  if l_prj_table is not null then
    l_bt_copy:=p_data_source.base_tables(1);
    l_bt_copy.base_table_name:=l_prj_table;
    l_bt_copy.projection_table:=null;
    p_data_source.base_tables(p_data_source.base_tables.count+1):=l_bt_copy;
  end if;
Exception when others then
  log_n('Exception in get_base_table_data_source '||sqlerrm);
  raise;
End;

procedure get_dim_set_calendar(p_kpi varchar2,p_dim_set in out nocopy bsc_aw_adapter_kpi.dim_set_r) is
l_periodicity dbms_sql.number_table;
Begin
  bsc_metadata.get_kpi_periodicities(p_kpi,p_dim_set.dim_set,l_periodicity);
  for i in 1..l_periodicity.count loop
    p_dim_set.calendar.periodicity(p_dim_set.calendar.periodicity.count+1).periodicity:=l_periodicity(i);
  end loop;
Exception when others then
  log_n('Exception in get_dim_set_calendar '||sqlerrm);
  raise;
End;

/*
given a calendar and periodicity, get the column name from bsc_db_calendar
*/
function get_db_calendar_column(p_calendar number,p_periodicity number) return varchar2 is
Begin
  return bsc_metadata.get_db_calendar_column(p_calendar,p_periodicity);
Exception when others then
  log_n('Exception in get_db_calendar_column '||sqlerrm);
  raise;
End;

/*
this procedure gives the period in which there is a mix of forecast and real data
we need the following
kpi and periodicity : we use this to hit bsc_db_tables that will indicate the current period
calendar : with this, we will get the current year.
then we can say make the period

called from bsc_aw_load_kpi
*/
procedure get_forecast_current_period(
p_kpi varchar2,
p_calendar number,
p_periodicity number,
p_period out nocopy varchar2
) is
--
l_year number;
l_period number;
Begin
  --bsc_aw_calendar.get_calendar_current_year(p_calendar,l_year);
  --we do not want to call bsc_aw_calendar.get_calendar_current_year. what if in the future, each kpi has its own
  --current year?
  bsc_metadata.get_kpi_current_period(p_kpi,p_periodicity,l_period,l_year);
  p_period:=l_period||'.'||l_year;
Exception when others then
  log_n('Exception in get_forecast_current_period '||sqlerrm);
  raise;
End;

/* period is in period.year format. periodicity is not specified or returned in this api.
we can later have caching
we may pass PRJ table which can have null current period*/
procedure get_table_current_period(p_table varchar2,p_period out nocopy varchar2) is
l_year number;
l_period number;
Begin
  bsc_metadata.get_table_current_period(p_table,l_period,l_year);
  if l_period is not null and l_year is not null then
    p_period:=l_period||'.'||l_year;
  end if;
Exception when others then
  log_n('Exception in get_table_current_period '||sqlerrm);
  raise;
End;

procedure get_all_kpi_in_aw(
p_kpi out nocopy dbms_sql.varchar2_table,
p_kpi_dimset out nocopy dbms_sql.varchar2_table
) is
--
l_kpi dbms_sql.varchar2_table;
l_dimset dbms_sql.varchar2_table;
Begin
  bsc_metadata.get_all_kpi_in_aw(l_kpi);
  for i in 1..l_kpi.count loop
    l_dimset.delete;
    bsc_metadata.get_kpi_dim_sets(l_kpi(i),l_dimset);
    for j in 1..l_dimset.count loop
      p_kpi(p_kpi.count+1):=l_kpi(i);
      p_kpi_dimset(p_kpi_dimset.count+1):=l_dimset(j);
    end loop;
  end loop;
Exception when others then
  log_n('Exception in get_all_kpi_in_aw '||sqlerrm);
  raise;
End;

/*
4486476
Issue is that PMV uses the short names for dimensions and measures. we use the dim table name and measure name from bsc
so we decided to do the lookup for them.
get_measures_for_short_names and get_dim_levels_for_short_names
*/
procedure get_measures_for_short_names(
p_short_name dbms_sql.varchar2_table,
p_measure_name out nocopy dbms_sql.varchar2_table
) is
Begin
  bsc_metadata.get_measures_for_short_names(p_short_name,p_measure_name);
Exception when others then
  log_n('Exception in get_measures_for_short_names '||sqlerrm);
  raise;
End;

procedure get_dim_levels_for_short_names(
p_short_name dbms_sql.varchar2_table,
p_dim_level_name out nocopy dbms_sql.varchar2_table
) is
Begin
  bsc_metadata.get_dim_levels_for_short_names(p_short_name,p_dim_level_name);
Exception when others then
  log_n('Exception in get_dim_levels_for_short_names '||sqlerrm);
  raise;
End;

function is_level_used_by_aw_kpi(p_level varchar2) return boolean is
Begin
  return bsc_metadata.is_level_used_by_aw_kpi(p_level);
Exception when others then
  log_n('Exception in is_level_used_by_aw_kpi '||sqlerrm);
  raise;
End;

--------------------------
procedure init_all is
Begin
  g_debug:=bsc_aw_utility.g_debug;
  g_count:=0;
Exception when others then
  null;
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

END BSC_AW_BSC_METADATA;

/
