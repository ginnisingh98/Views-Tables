--------------------------------------------------------
--  DDL for Package Body BSC_AW_MD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_AW_MD_API" AS
/*$Header: BSCAWMAB.pls 120.22 2006/11/04 10:39:38 amitgupt noship $*/

function is_dim_present(
p_dimension varchar2
)return boolean is
Begin
  g_olap_object.delete;
  get_bsc_olap_object(p_dimension,'dimension',p_dimension,'dimension',g_olap_object);
  if g_olap_object.count>0 then
    return true;
  else
    return false;
  end if;
Exception when others then
  log_n('Exception in is_dim_present '||sqlerrm);
  raise;
End;

procedure get_kpi_for_dim(
p_dim_name varchar2,
p_kpi_list out nocopy dbms_sql.varchar2_table
) is
Begin
  g_olap_object_relation.delete;
  get_bsc_olap_object_relation(null,null,'dimension kpi',p_dim_name,'dimension',g_olap_object_relation);
  for i in 1..g_olap_object_relation.count loop
    p_kpi_list(i):=g_olap_object_relation(i).relation_object;
  end loop;
Exception when others then
  log_n('Exception in get_kpi_for_dim '||sqlerrm);
  raise;
End;

procedure mark_kpi_recreate(p_kpi varchar2) is
Begin
  bsc_aw_md_wrapper.mark_kpi_recreate(p_kpi);
Exception when others then
  log_n('Exception in mark_kpi_recreate '||sqlerrm);
  raise;
End;

/*
returns the name of the olap objects that need to be dropped from aw
*/
procedure get_dim_olap_objects(
p_dim_name varchar2,
p_objects out nocopy bsc_aw_md_wrapper.bsc_olap_object_tb,
p_type varchar2
) is
--
Begin
  if p_type='all' then
    get_bsc_olap_object(null,null,p_dim_name,'dimension',p_objects);
  else
    get_bsc_olap_object(null,p_type,p_dim_name,'dimension',p_objects);
  end if;
Exception when others then
  log_n('Exception in get_dim_olap_objects '||sqlerrm);
  raise;
End;

procedure drop_dim(p_dim_name varchar2) is
Begin
  clear_all_cache;
  bsc_aw_md_wrapper.drop_dim(p_dim_name);
  clear_all_cache;
Exception when others then
  log_n('Exception in drop_dim '||sqlerrm);
  raise;
End;

/*
in this api, we need to loop and search because a level might have been in a diff dim before
so we need to get the list of all cc dim for the levels that are now part of p_dimension
*/
procedure get_ccdim_for_levels(
p_dimension bsc_aw_adapter_dim.dimension_r,
p_dim_list out nocopy dbms_sql.varchar2_table
) is
--
l_dim dbms_sql.varchar2_table;
--
Begin
  p_dim_list.delete;
  if g_debug then
    log_n('CCDIM for levels');
  end if;
  for i in 1..p_dimension.level_groups.count loop
    for j in 1..p_dimension.level_groups(i).levels.count loop
      l_dim.delete;
      get_dims_for_level(p_dimension.level_groups(i).levels(j).level_name,l_dim);
      bsc_aw_utility.merge_array(p_dim_list,l_dim);
    end loop;
  end loop;
Exception when others then
  log_n('Exception in get_ccdim_for_levels '||sqlerrm);
  raise;
End;

/*
given a dim level, find the CC dim
note>>> this only returns the latest un-corrected dim. used in BSCAWAKB.pls, BSCAWLDB.pls
*/
procedure get_dim_for_level(p_level varchar2,p_dim out nocopy varchar2) is
l_oo_dim bsc_aw_md_wrapper.bsc_olap_object_tb;
l_oo_level bsc_aw_md_wrapper.bsc_olap_object_tb;
Begin
  get_bsc_olap_object(p_level,'dimension level',null,null,l_oo_level);
  --there can multiple dim in l_oo_level. only 1 is un-corrected
  for i in 1..l_oo_level.count loop
    if l_oo_level(i).parent_object_type='dimension' then
      l_oo_dim.delete;
      get_bsc_olap_object(l_oo_level(i).parent_object,'dimension',l_oo_level(i).parent_object,'dimension',l_oo_dim);
      if nvl(bsc_aw_utility.get_parameter_value(l_oo_dim(1).property1,'corrected',','),'N')='N' then
        p_dim:=l_oo_dim(1).object;
        return;
      end if;
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_dim_for_level '||sqlerrm);
  raise;
End;

/*
given a dim level, find all CC dims
*/
procedure get_dims_for_level(p_level varchar2,p_dim out nocopy dbms_sql.varchar2_table) is
l_oo_level bsc_aw_md_wrapper.bsc_olap_object_tb;
Begin
  get_bsc_olap_object(p_level,'dimension level',null,null,l_oo_level);
  --there can multiple dim in l_oo_level. only 1 is un-corrected
  for i in 1..l_oo_level.count loop
    if l_oo_level(i).parent_object_type='dimension' then
      p_dim(p_dim.count+1):=l_oo_level(i).parent_object;
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_dims_for_level '||sqlerrm);
  raise;
End;

/*
here we convert from one format to the other, from bsc_aw_adapter_dim.dimension_r to
bsc_aw_md_wrapper.dimension_r
*/
procedure create_dim_objects(
p_dimension bsc_aw_adapter_dim.dimension_r
) is
Begin
  bsc_aw_md_wrapper.create_dim(p_dimension);
  clear_all_cache;
Exception when others then
  log_n('Exception in create_dim_objects '||sqlerrm);
  raise;
End;

/*
get the position of a level. this will be used from the UI module to see the positions of the levels and see
if agg on the fly is reqd
*/
function get_level_position(
p_dim_level varchar2
) return number is
l_position number;
Begin
  g_olap_object.delete;
  get_bsc_olap_object(p_dim_level,'dimension level',null,null,g_olap_object);
  l_position:=bsc_aw_utility.get_parameter_value(g_olap_object(1).property1,'position',',');
  if l_position is null then
    return null;
  else
    return to_number(l_position);
  end if;
Exception when others then
  log_n('Exception in get_level_position '||sqlerrm);
  raise;
End;

procedure drop_kpi(p_kpi varchar2) is
Begin
  clear_all_cache;
  bsc_aw_md_wrapper.drop_kpi(p_kpi);
  clear_all_cache;
Exception when others then
  log_n('Exception in drop_kpi '||sqlerrm);
  raise;
End;

procedure get_kpi_olap_objects(
p_kpi varchar2,
p_objects out nocopy bsc_aw_utility.object_tb,
p_type varchar2
) is
Begin
  g_olap_object.delete;
  if p_type='all' then
    get_bsc_olap_object(null,null,p_kpi,'kpi',g_olap_object);
  else
    get_bsc_olap_object(null,p_type,p_kpi,'kpi',g_olap_object);
  end if;
  for i in 1..g_olap_object.count loop
    if g_olap_object(i).olap_object_type is not null then
      p_objects(p_objects.count+1).object_name:=g_olap_object(i).olap_object;
      p_objects(p_objects.count).object_type:=g_olap_object(i).olap_object_type;
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_kpi_olap_objects '||sqlerrm);
  raise;
End;

/*
calendar is time dim. so it appears in the metadata like a dim
*/
procedure delete_calendar(p_calendar bsc_aw_calendar.calendar_r) is
Begin
  clear_all_cache;
  drop_dim(p_calendar.dim_name);
  clear_all_cache;
Exception when others then
  log_n('Exception in delete_calendar '||sqlerrm);
  raise;
End;

procedure create_calendar(p_calendar bsc_aw_calendar.calendar_r) is
Begin
  bsc_aw_md_wrapper.create_calendar(p_calendar);
  clear_all_cache;
Exception when others then
  log_n('Exception in create_calendar '||sqlerrm);
  raise;
End;

/*
given a dim find out all the properties
from bsc olap metadata
*/
procedure get_dim_properties(p_dim in out nocopy bsc_aw_adapter_kpi.dim_r) is
l_property bsc_aw_utility.value_tb;
Begin
  g_olap_object.delete;
  --get_bsc_olap_object(p_dim.dim_name,'dimension',null,null,g_olap_object);
  get_bsc_olap_object(null,null,p_dim.dim_name,'dimension',g_olap_object);
  for i in 1..g_olap_object.count loop
    if g_olap_object(i).object=p_dim.dim_name and g_olap_object(i).object_type='dimension' then
      if g_olap_object(i).olap_object_type='concat dimension' then
        p_dim.concat:='Y';
      else
        p_dim.concat:='N';
      end if;
      bsc_aw_utility.parse_parameter_values(g_olap_object(i).property1,',',l_property);
      p_dim.property:=bsc_aw_utility.get_parameter_value(l_property,'dimension type'); --normal vs time
      p_dim.recursive:=nvl(bsc_aw_utility.get_parameter_value(l_property,'recursive'),'N'); --Y or N
      p_dim.recursive_norm_hier:=nvl(bsc_aw_utility.get_parameter_value(l_property,'normal hier'),'N');
      p_dim.multi_level:=nvl(bsc_aw_utility.get_parameter_value(l_property,'multi level'),'N'); --Y or N
    elsif g_olap_object(i).object_type='relation' then
      --relation name can be null if there is no rollup on this dim
      p_dim.relation_name:=g_olap_object(i).object;
    elsif g_olap_object(i).object_type='level name dim' then
      p_dim.level_name_dim:=g_olap_object(i).object;
    elsif g_olap_object(i).object_type='base value cube' then
      p_dim.base_value_cube:=g_olap_object(i).object;
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_dim_properties '||sqlerrm);
  raise;
End;

/*
given a calenadar find out all the properties
from bsc olap metadata
Input : calendar.aw_dim like bsc_calendar_1 NOT the calendar id
*/
procedure get_calendar_properties(p_calendar in out nocopy bsc_aw_adapter_kpi.calendar_r) is
l_property bsc_aw_utility.value_tb;
Begin
  g_olap_object.delete;
  get_bsc_olap_object(null,null,p_calendar.aw_dim,'dimension',g_olap_object);
  for i in 1..g_olap_object.count loop
    if g_olap_object(i).object=p_calendar.aw_dim and g_olap_object(i).object_type='dimension' then
      p_calendar.calendar:=bsc_aw_utility.get_parameter_value(g_olap_object(i).property1,'calendar',',');
    elsif g_olap_object(i).object_type='relation' then
      p_calendar.relation_name:=g_olap_object(i).object;
    elsif g_olap_object(i).object_type='denorm relation' then
      p_calendar.denorm_relation_name:=g_olap_object(i).object;
    elsif g_olap_object(i).object_type='level name dim' then
      p_calendar.level_name_dim:=g_olap_object(i).object;
    elsif g_olap_object(i).object_type='end period level name dim' then
      p_calendar.end_period_level_name_dim:=g_olap_object(i).object;
    elsif g_olap_object(i).object_type='end period relation' then
      p_calendar.end_period_relation_name:=g_olap_object(i).object;
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_calendar_properties '||sqlerrm);
  raise;
End;

/*
given a dim , get the full hier of the dim
the parent child relations are in bsc metadata. so why do we need an api here?
we need this because we need to see if there is any change to the parent child relation
bsc metadata will only contain the latest info
note>>>this loads parent child without reference to level groups
*/
procedure get_dim_parent_child(p_dim varchar2,p_parent_child out nocopy bsc_aw_adapter_dim.dim_parent_child_tb) is
l_oo bsc_aw_md_wrapper.bsc_olap_object_tb;
l_oor bsc_aw_md_wrapper.bsc_olap_object_relation_tb;
Begin
  l_oo.delete;
  get_bsc_olap_object(null,'dimension level',p_dim,'dimension',l_oo);
  for i in 1..l_oo.count loop
    l_oor.delete;
    get_bsc_olap_object_relation(l_oo(i).object,l_oo(i).object_type,'parent level',p_dim,'dimension',l_oor);
    for j in 1..l_oor.count loop
      p_parent_child(p_parent_child.count+1).child_level:=l_oor(j).object;
      p_parent_child(p_parent_child.count).parent_level:=l_oor(j).relation_object;
      p_parent_child(p_parent_child.count).child_fk:=bsc_aw_utility.get_parameter_value(l_oor(j).property1,'fk',',');
      p_parent_child(p_parent_child.count).parent_pk:=bsc_aw_utility.get_parameter_value(l_oor(j).property1,'pk',',');
    end loop;
  end loop;
Exception when others then
  log_n('Exception in get_dim_parent_child '||sqlerrm);
  raise;
End;

procedure get_bsc_olap_object(
p_object varchar2,
p_type varchar2,
p_parent_object varchar2,
p_parent_type varchar2,
p_bsc_olap_object out nocopy bsc_aw_md_wrapper.bsc_olap_object_tb
) is
--
l_cache_found varchar2(20);
l_bsc_olap_object bsc_aw_md_wrapper.bsc_olap_object_tb;
Begin
  l_cache_found:=get_oo_cache(p_object,p_type,p_parent_object,p_parent_type,l_bsc_olap_object);
  if l_cache_found='N' then
    bsc_aw_md_wrapper.get_bsc_olap_object(p_object,p_type,p_parent_object,p_parent_type,l_bsc_olap_object);
    add_oo_cache(p_object,p_type,p_parent_object,p_parent_type,l_bsc_olap_object);
  end if;
  p_bsc_olap_object:=l_bsc_olap_object;
Exception when others then
  log_n('Exception in get_bsc_olap_object '||sqlerrm);
  raise;
End;

function get_oo_cache(
p_object varchar2,
p_type varchar2,
p_parent_object varchar2,
p_parent_type varchar2,
p_bsc_olap_object out nocopy bsc_aw_md_wrapper.bsc_olap_object_tb
) return varchar2 is
--
l_cache_found varchar2(20);
Begin
  l_cache_found:='N';
  for i in 1..g_oo_cache.count loop
    if nvl(g_oo_cache(i).object,'^')=nvl(p_object,'^')
    and nvl(g_oo_cache(i).object_type,'^')=nvl(p_type,'^')
    and nvl(g_oo_cache(i).parent_object,'^')=nvl(p_parent_object,'^')
    and nvl(g_oo_cache(i).parent_object_type,'^')=nvl(p_parent_type,'^') then
      if g_oo_cache(i).bsc_olap_object.count > 0 then
        p_bsc_olap_object:=g_oo_cache(i).bsc_olap_object;
        l_cache_found:='Y';
      end if;
      exit;
    end if;
  end loop;
  return l_cache_found;
Exception when others then
  log_n('Exception in get_oo_cache '||sqlerrm);
  raise;
End;

procedure add_oo_cache(
p_object varchar2,
p_type varchar2,
p_parent_object varchar2,
p_parent_type varchar2,
p_bsc_olap_object bsc_aw_md_wrapper.bsc_olap_object_tb
) is
--
l_bsc_olap_object bsc_aw_md_wrapper.bsc_olap_object_tb;
Begin
  l_bsc_olap_object:=p_bsc_olap_object;
  g_oo_cache(g_oo_cache.count+1).object:=p_object;
  g_oo_cache(g_oo_cache.count).object_type:=p_type;
  g_oo_cache(g_oo_cache.count).parent_object:=p_parent_object;
  g_oo_cache(g_oo_cache.count).parent_object_type:=p_parent_type;
  g_oo_cache(g_oo_cache.count).bsc_olap_object:=l_bsc_olap_object;
Exception when others then
  log_n('Exception in add_oo_cache '||sqlerrm);
  raise;
End;

procedure get_bsc_olap_object_relation(
p_object varchar2,
p_object_type varchar2,
p_relation_type varchar2,
p_parent_object varchar2,
p_parent_object_type varchar2,
p_bsc_olap_object_relation out nocopy bsc_aw_md_wrapper.bsc_olap_object_relation_tb
) is
--
l_cache_found varchar2(20);
l_bsc_olap_object_relation bsc_aw_md_wrapper.bsc_olap_object_relation_tb;
Begin
  l_cache_found:=get_oor_cache(p_object,p_object_type,p_relation_type,p_parent_object,p_parent_object_type,l_bsc_olap_object_relation);
  if l_cache_found='N' then
    bsc_aw_md_wrapper.get_bsc_olap_object_relation(p_object,p_object_type,p_relation_type,p_parent_object,p_parent_object_type,
    l_bsc_olap_object_relation);
    add_oor_cache(p_object,p_object_type,p_relation_type,p_parent_object,p_parent_object_type,l_bsc_olap_object_relation);
  end if;
  p_bsc_olap_object_relation:=l_bsc_olap_object_relation;
Exception when others then
  log_n('Exception in get_bsc_olap_object_relation '||sqlerrm);
  raise;
End;

function get_oor_cache(
p_object varchar2,
p_object_type varchar2,
p_relation_type varchar2,
p_parent_object varchar2,
p_parent_object_type varchar2,
p_bsc_olap_object_relation out nocopy bsc_aw_md_wrapper.bsc_olap_object_relation_tb
) return varchar2 is
--
l_cache_found varchar2(20);
Begin
  l_cache_found:='N';
  for i in 1..g_oor_cache.count loop
    if nvl(g_oor_cache(i).object,'^')=nvl(p_object,'^')
    and nvl(g_oor_cache(i).object_type,'^')=nvl(p_object_type,'^')
    and nvl(g_oor_cache(i).relation_type,'^')=nvl(p_relation_type,'^')
    and nvl(g_oor_cache(i).parent_object,'^')=nvl(p_parent_object,'^')
    and nvl(g_oor_cache(i).parent_object_type,'^')=nvl(p_parent_object_type,'^')  then
      if g_oor_cache(i).bsc_olap_object_relation.count > 0 then
        p_bsc_olap_object_relation:=g_oor_cache(i).bsc_olap_object_relation;
        l_cache_found:='Y';
      end if;
      exit;
    end if;
  end loop;
  return l_cache_found;
Exception when others then
  log_n('Exception in get_oor_cache '||sqlerrm);
  raise;
End;

procedure add_oor_cache(
p_object varchar2,
p_object_type varchar2,
p_relation_type varchar2,
p_parent_object varchar2,
p_parent_object_type varchar2,
p_bsc_olap_object_relation bsc_aw_md_wrapper.bsc_olap_object_relation_tb
) is
--
l_bsc_olap_object_relation bsc_aw_md_wrapper.bsc_olap_object_relation_tb;
Begin
  l_bsc_olap_object_relation:=p_bsc_olap_object_relation;
  g_oor_cache(g_oor_cache.count+1).object:=p_object;
  g_oor_cache(g_oor_cache.count).object_type:=p_object_type;
  g_oor_cache(g_oor_cache.count).relation_type:=p_relation_type;
  g_oor_cache(g_oor_cache.count).parent_object:=p_parent_object;
  g_oor_cache(g_oor_cache.count).parent_object_type:=p_parent_object_type;
  g_oor_cache(g_oor_cache.count).bsc_olap_object_relation:=l_bsc_olap_object_relation;
Exception when others then
  log_n('Exception in add_oor_cache '||sqlerrm);
  raise;
End;

procedure create_kpi(p_kpi bsc_aw_adapter_kpi.kpi_r) is
Begin
  bsc_aw_md_wrapper.create_kpi(p_kpi);
  clear_all_cache;
Exception when others then
  log_n('Exception in create_kpi '||sqlerrm);
  raise;
End;

/*
given a kpi, find the dims
will be used in the ui module
*/
procedure get_dim_for_kpi(
p_kpi varchar2,
p_dim_list out nocopy dbms_sql.varchar2_table
) is
Begin
  g_olap_object_relation.delete;
  get_bsc_olap_object_relation(p_kpi,'kpi','kpi dimension',p_kpi,'kpi',g_olap_object_relation);
  for i in 1..g_olap_object_relation.count loop
    p_dim_list(i):=g_olap_object_relation(i).relation_object;
  end loop;
Exception when others then
  log_n('Exception in get_dim_for_kpi '||sqlerrm);
  raise;
End;

--set the relation name, periodicity aw name and also the parent child info
procedure get_dim_set_calendar(
p_kpi bsc_aw_adapter_kpi.kpi_r,
p_dim_set in out nocopy bsc_aw_adapter_kpi.dim_set_r
) is
--
l_periodicity dbms_sql.varchar2_table;
l_periodicity_type dbms_sql.varchar2_table;
l_olap_object_relation bsc_aw_md_wrapper.bsc_olap_object_relation_tb;
l_oo bsc_aw_md_wrapper.bsc_olap_object_tb;
Begin
  --get the relation name
  l_oo.delete;
  get_bsc_olap_object(p_dim_set.calendar.aw_dim,'dimension',p_dim_set.calendar.aw_dim,'dimension',l_oo);
  get_calendar_properties(p_dim_set.calendar);
  --from bsc olap metadata, get the properties of the periodicities
  l_oo.delete;
  get_bsc_olap_object(null,'dimension level',p_dim_set.calendar.aw_dim,'dimension',l_oo);
  for i in 1..l_oo.count loop
    l_periodicity(i):=null;
    l_periodicity_type(i):=null;
    l_periodicity(i):=bsc_aw_utility.get_parameter_value(l_oo(i).property1,'periodicity',',');
    l_periodicity_type(i):=bsc_aw_utility.get_parameter_value(l_oo(i).property1,'periodicity_type',',');
  end loop;
  for i in 1..p_dim_set.calendar.periodicity.count loop
    if p_dim_set.calendar.periodicity(i).aw_dim is null then
      for j in 1..l_periodicity.count loop
        if to_number(l_periodicity(j))=p_dim_set.calendar.periodicity(i).periodicity then
          p_dim_set.calendar.periodicity(i).aw_dim:=l_oo(j).object;
          p_dim_set.calendar.periodicity(i).periodicity_type:=l_periodicity_type(j);
          exit;
        end if;
      end loop;
    elsif p_dim_set.calendar.periodicity(i).periodicity is null then
      for j in 1..l_oo.count loop
        if p_dim_set.calendar.periodicity(i).aw_dim=l_oo(j).object then
          p_dim_set.calendar.periodicity(i).periodicity:=to_number(l_periodicity(j));
          exit;
        end if;
      end loop;
    end if;
  end loop;
  --
  --fill parent child info
  l_olap_object_relation.delete;
  p_dim_set.calendar.parent_child.delete;
  get_bsc_olap_object_relation(null,null,'parent level',p_dim_set.calendar.aw_dim,'dimension',l_olap_object_relation);
  for i in 1..l_olap_object_relation.count loop
    p_dim_set.calendar.parent_child(p_dim_set.calendar.parent_child.count+1).parent_dim_name:=l_olap_object_relation(i).relation_object;
    p_dim_set.calendar.parent_child(p_dim_set.calendar.parent_child.count).child_dim_name:=l_olap_object_relation(i).object;
    p_dim_set.calendar.parent_child(p_dim_set.calendar.parent_child.count).parent:=to_number(
    bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,'parent periodicity',','));
    p_dim_set.calendar.parent_child(p_dim_set.calendar.parent_child.count).child:=to_number(
    bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,'child periodicity',','));
  end loop;
Exception when others then
  log_n('Exception in get_dim_set_calendar '||sqlerrm);
  raise;
End;

function is_kpi_present(
p_kpi varchar2
)return boolean is

Begin
  g_olap_object.delete;
  get_bsc_olap_object(p_kpi,'kpi',p_kpi,'kpi',g_olap_object);
  if g_olap_object.count>0 then
    return true;
  else
    return false;
  end if;
Exception when others then
  log_n('Exception in is_kpi_present '||sqlerrm);
  raise;
End;

procedure get_kpi_dimset(
p_kpi varchar2,
p_bsc_olap_object out nocopy bsc_aw_md_wrapper.bsc_olap_object_tb
) is
Begin
  get_bsc_olap_object(null,'kpi dimension set',p_kpi,'kpi',p_bsc_olap_object);
Exception when others then
  log_n('Exception in get_kpi_dimset '||sqlerrm);
  raise;
End;

--only Actual dimset not targets
procedure get_kpi_dimset_actual(
p_kpi varchar2,
p_bsc_olap_object out nocopy bsc_aw_md_wrapper.bsc_olap_object_tb
) is
--
l_bsc_olap_object bsc_aw_md_wrapper.bsc_olap_object_tb;
Begin
  get_kpi_dimset(p_kpi,l_bsc_olap_object);
  for i in 1..l_bsc_olap_object.count loop
    if bsc_aw_utility.get_parameter_value(l_bsc_olap_object(i).property1,'dim set type',',')='actual' then
      p_bsc_olap_object(p_bsc_olap_object.count+1):=l_bsc_olap_object(i);
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_kpi_dimset_actual '||sqlerrm);
  raise;
End;

/*
given a kpi and a dimset, get all the base table loading the dimset
*/
procedure get_dimset_base_table(
p_kpi varchar2,
p_dimset varchar2,
p_base_table_type varchar2,--"base table dim set"
p_olap_object_relation out nocopy bsc_aw_md_wrapper.bsc_olap_object_relation_tb
) is
Begin
  g_olap_object_relation.delete;
  --get full relations for the kpi. then find out the base tables for the dimset
  get_bsc_olap_object_relation(null,null,null,p_kpi,'kpi',g_olap_object_relation);
  if p_base_table_type is not null then
    for i in 1..g_olap_object_relation.count loop
      if g_olap_object_relation(i).object_type='base table' and g_olap_object_relation(i).relation_type=p_base_table_type
      and g_olap_object_relation(i).relation_object=p_dimset then
        p_olap_object_relation(p_olap_object_relation.count+1):=g_olap_object_relation(i);
      end if;
    end loop;
  else
    for i in 1..g_olap_object_relation.count loop
      if g_olap_object_relation(i).object_type='base table' and g_olap_object_relation(i).relation_type='base table dim set'
      and g_olap_object_relation(i).relation_object=p_dimset then
        p_olap_object_relation(p_olap_object_relation.count+1):=g_olap_object_relation(i);
      end if;
    end loop;
  end if;
Exception when others then
  log_n('Exception in get_dimset_base_table '||sqlerrm);
  raise;
End;

/*
given a kpi and a base table, find out all the dimsets using the base table
*/
procedure get_base_table_dimset(
p_kpi varchar2,
p_base_table varchar2,
p_base_table_type varchar2,--"base table dim set"
p_olap_object_relation out nocopy bsc_aw_md_wrapper.bsc_olap_object_relation_tb
) is
Begin
  g_olap_object_relation.delete;
  --get full relations for the kpi. then find out the dimsets for the base table
  get_bsc_olap_object_relation(null,null,null,p_kpi,'kpi',g_olap_object_relation);
  if p_base_table_type is not null then
    for i in 1..g_olap_object_relation.count loop
      if g_olap_object_relation(i).object_type='base table' and g_olap_object_relation(i).relation_type=p_base_table_type
        and g_olap_object_relation(i).object=p_base_table then
        p_olap_object_relation(p_olap_object_relation.count+1):=g_olap_object_relation(i);
      end if;
    end loop;
  else
    for i in 1..g_olap_object_relation.count loop
      if g_olap_object_relation(i).object_type='base table' and g_olap_object_relation(i).relation_type='base table dim set'
      and g_olap_object_relation(i).object=p_base_table then
        p_olap_object_relation(p_olap_object_relation.count+1):=g_olap_object_relation(i);
      end if;
    end loop;
  end if;
Exception when others then
  log_n('Exception in get_base_table_dimset '||sqlerrm);
  raise;
End;

procedure get_dimset_measure(
p_kpi varchar2,
p_dimset varchar2,
p_measure out nocopy bsc_aw_adapter_kpi.measure_tb
) is
--
l_olap_object_relation bsc_aw_md_wrapper.bsc_olap_object_relation_tb;
l_values bsc_aw_utility.value_tb;
l_property varchar2(2000);
Begin
  get_bsc_olap_object_relation(p_dimset,'kpi dimension set','dim set measure',p_kpi,'kpi',l_olap_object_relation);
  --l_agg_formula:=bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,'agg formula',',');
  for i in 1..l_olap_object_relation.count loop
    p_measure(p_measure.count+1).measure:=l_olap_object_relation(i).relation_object;
    p_measure(p_measure.count).measure_type:=bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,'measure type',',');
    p_measure(p_measure.count).forecast:=bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,'forecast',',');
    p_measure(p_measure.count).forecast_method:=bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,'forecast method',',');
    p_measure(p_measure.count).sql_aggregated:=nvl(bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,'sql aggregated',','),'N');
    p_measure(p_measure.count).agg_formula.agg_formula:=bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,'agg formula',',');
    p_measure(p_measure.count).agg_formula.std_aggregation:=bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,'std agg',',');
    p_measure(p_measure.count).agg_formula.avg_aggregation:=bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,'avg agg',',');
    l_values.delete;
    bsc_aw_utility.parse_parameter_values(bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,
    'agg formula cubes',','),'+',l_values);
    if l_values.count>0 then
      for j in 1..l_values.count loop
        p_measure(p_measure.count).agg_formula.cubes(p_measure(p_measure.count).agg_formula.cubes.count+1):=l_values(j).parameter;
      end loop;
    end if;
    l_values.delete;
    bsc_aw_utility.parse_parameter_values(bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,
    'agg formula measures',','),'+',l_values);
    if l_values.count>0 then
      for j in 1..l_values.count loop
        p_measure(p_measure.count).agg_formula.measures(p_measure(p_measure.count).agg_formula.measures.count+1):=l_values(j).parameter;
      end loop;
    end if;
    --cannot change get_parameter_value to scanning bsc_olap_object even though bsc_olap_object has the cube and fcst cube etc
    --in bsc_olap_object, we cannot know which measure belongs to which dimset
    p_measure(p_measure.count).cube:=bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,'cube',',');
    p_measure(p_measure.count).fcst_cube:=bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,'fcst cube',',');
    p_measure(p_measure.count).countvar_cube:=bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,'countvar cube',',');
    p_measure(p_measure.count).display_cube:=bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,'display cube',',');
    l_property:=bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,'balance loaded column',',');
    if l_property is not null then
      bsc_aw_utility.merge_property(p_measure(p_measure.count).property,'balance loaded column',null,l_property);
    end if;
    l_property:=bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,'year cube',',');
    if l_property is not null then
      bsc_aw_utility.merge_property(p_measure(p_measure.count).property,'year cube',null,l_property);
    end if;
    l_property:=bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,'period cube',',');
    if l_property is not null then
      bsc_aw_utility.merge_property(p_measure(p_measure.count).property,'period cube',null,l_property);
    end if;
    --in 10g we have composites per measure
  end loop;
Exception when others then
  log_n('Exception in get_dimset_measure '||sqlerrm);
  raise;
End;

/*
this procedure reads all metadata for a dimset from olap metadata
loads all info of a dimset
this api is important. will be used by kpi data loading, forecasting, aggregations etc
for now, we will keep this only for aggregation and forecasting
this means we are not concerned about the data source

when we aggregate , we dont need the agg maps defined per dim . we need the agg maps defined per
dim only when we aggregate in the UI
*/
procedure get_kpi_dimset_md(
p_kpi varchar2,
p_dimset_name varchar2,
p_dimset out nocopy bsc_aw_adapter_kpi.dim_set_r
) is
--
l_olap_object bsc_aw_md_wrapper.bsc_olap_object_tb;
l_olap_object_relation bsc_aw_md_wrapper.bsc_olap_object_relation_tb;
l_num number;
Begin
  --get all properties of the kpi. then loop through
  get_bsc_olap_object(p_dimset_name,'kpi dimension set',p_kpi,'kpi',l_olap_object);
  get_bsc_olap_object_relation(null,null,null,p_kpi,'kpi',l_olap_object_relation);
  p_dimset.dim_set_name:=p_dimset_name;
  --dimset properties
  p_dimset.dim_set:=bsc_aw_utility.get_parameter_value(l_olap_object(1).property1,'dim set',',');
  p_dimset.dim_set_type:=bsc_aw_utility.get_parameter_value(l_olap_object(1).property1,'dim set type',',');
  p_dimset.base_dim_set:=bsc_aw_utility.get_parameter_value(l_olap_object(1).property1,'base dim set',',');
  p_dimset.targets_higher_levels:=nvl(bsc_aw_utility.get_parameter_value(l_olap_object(1).property1,'targets',','),'N');
  p_dimset.measurename_dim:=bsc_aw_utility.get_parameter_value(l_olap_object(1).property1,'measurename dim',',');
  p_dimset.partition_dim:=bsc_aw_utility.get_parameter_value(l_olap_object(1).property1,'partition dim',',');
  p_dimset.cube_design:=bsc_aw_utility.get_parameter_value(l_olap_object(1).property1,'cube design',',');
  p_dimset.number_partitions:=bsc_aw_utility.get_parameter_value(l_olap_object(1).property1,'number partitions',',');
  p_dimset.partition_type:=bsc_aw_utility.get_parameter_value(l_olap_object(1).property1,'partition type',',');
  p_dimset.compressed:=bsc_aw_utility.get_parameter_value(l_olap_object(1).property1,'compressed',',');
  p_dimset.pre_calculated:=nvl(bsc_aw_utility.get_parameter_value(l_olap_object(1).property1,'pre calculated',','),'N');
  --we are not looking at agg maps defined per dim
  --agg_map_average is usedfor AVERAGE aggregation
  --agg_map_notime is used for balance measures
  for i in 1..l_olap_object_relation.count loop
    if l_olap_object_relation(i).object=p_dimset_name and l_olap_object_relation(i).relation_type='dim set agg map' then
      p_dimset.agg_map.agg_map:=l_olap_object_relation(i).relation_object;
      p_dimset.agg_map.created:='Y';
    elsif l_olap_object_relation(i).object=p_dimset_name and l_olap_object_relation(i).relation_type='dim set agg map notime' then
      p_dimset.agg_map_notime.agg_map:=l_olap_object_relation(i).relation_object;
      p_dimset.agg_map_notime.created:='Y';
    elsif l_olap_object_relation(i).object=p_dimset_name and l_olap_object_relation(i).relation_type='agg map measure dim' then
      p_dimset.aggmap_operator.measure_dim:=l_olap_object_relation(i).relation_object;
    elsif l_olap_object_relation(i).object=p_dimset_name and l_olap_object_relation(i).relation_type='agg map opvar' then
      p_dimset.aggmap_operator.opvar:=l_olap_object_relation(i).relation_object;
    elsif l_olap_object_relation(i).object=p_dimset_name and l_olap_object_relation(i).relation_type='agg map argvar' then
      p_dimset.aggmap_operator.argvar:=l_olap_object_relation(i).relation_object;
    elsif l_olap_object_relation(i).object=p_dimset_name and l_olap_object_relation(i).relation_type='aggregate marker program' then
      p_dimset.aggregate_marker_program:=l_olap_object_relation(i).relation_object;
    elsif l_olap_object_relation(i).object=p_dimset_name and l_olap_object_relation(i).relation_type='LB resync program' then
      p_dimset.LB_resync_program:=l_olap_object_relation(i).relation_object;
    end if;
  end loop;
  --get the dim
  get_kpi_dimset_dim_md(p_kpi,p_dimset_name,p_dimset.dim,p_dimset.std_dim);
  --get calendar metadata
  get_kpi_dimset_calendar_md(p_kpi,p_dimset_name,p_dimset.calendar);
  --get the partition and composite info
  get_dimset_comp_PT(p_kpi,p_dimset_name,p_dimset.partition_template,p_dimset.composite);
  --get the cube info
  get_dimset_cube_set(p_kpi,p_dimset_name,p_dimset.cube_set);
  --get the measure information
  get_dimset_measure(p_kpi,p_dimset_name,p_dimset.measure);
Exception when others then
  log_n('Exception in get_kpi_dimset_md '||sqlerrm);
  raise;
End;

/*
get the partition template and composite info
*/
procedure get_dimset_comp_PT(
p_kpi varchar2,
p_dimset_name varchar2,
p_partition_template out nocopy bsc_aw_adapter_kpi.partition_template_tb,
p_composite out nocopy bsc_aw_adapter_kpi.composite_tb) is
--
l_olap_object_relation bsc_aw_md_wrapper.bsc_olap_object_relation_tb;
Begin
  get_bsc_olap_object_relation(null,null,null,p_kpi,'kpi',l_olap_object_relation);
  for i in 1..l_olap_object_relation.count loop
    if l_olap_object_relation(i).object=p_dimset_name and l_olap_object_relation(i).relation_type='dim set partition template' then
      p_partition_template(p_partition_template.count+1).template_name:=l_olap_object_relation(i).relation_object;
      p_partition_template(p_partition_template.count).template_type:=bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,
      'template type',',');
      p_partition_template(p_partition_template.count).template_use:=bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,
      'template use',',');
      p_partition_template(p_partition_template.count).template_dim:=bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,
      'template dim',',');
      --now, the template partitions
      for j in 1..l_olap_object_relation.count loop
        if l_olap_object_relation(j).object=p_partition_template(p_partition_template.count).template_name and
        l_olap_object_relation(j).relation_type='partition template partition' then
          p_partition_template(p_partition_template.count).template_partitions(
          p_partition_template(p_partition_template.count).template_partitions.count+1).partition_name:=l_olap_object_relation(j).relation_object;
          p_partition_template(p_partition_template.count).template_partitions(
          p_partition_template(p_partition_template.count).template_partitions.count).partition_dim_value:=
          bsc_aw_utility.get_parameter_value(l_olap_object_relation(j).property1,'partition dim value',',');
        end if;
      end loop;
      --we are not loading the partition axis info here. this info is not really reqd
    end if;
  end loop;
  --get the composite info
  for i in 1..l_olap_object_relation.count loop
    if l_olap_object_relation(i).object=p_dimset_name and l_olap_object_relation(i).relation_type='dim set measure composite' then
      p_composite(p_composite.count+1).composite_name:=l_olap_object_relation(i).relation_object;
      p_composite(p_composite.count).composite_type:=bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,'composite type',',');
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_dimset_comp_PT '||sqlerrm);
  raise;
End;

/*
procedure to get the cube info
*/
procedure get_dimset_cube_set(
p_kpi varchar2,
p_dimset_name varchar2,
p_cube_set out nocopy bsc_aw_adapter_kpi.cube_set_tb) is
--
l_olap_object_relation bsc_aw_md_wrapper.bsc_olap_object_relation_tb;
Begin
  get_bsc_olap_object_relation(null,null,null,p_kpi,'kpi',l_olap_object_relation);
  for i in 1..l_olap_object_relation.count loop
    if l_olap_object_relation(i).object=p_dimset_name and l_olap_object_relation(i).relation_type='dim set cube set' then
      p_cube_set(p_cube_set.count+1).cube_set_name:=l_olap_object_relation(i).relation_object;
      p_cube_set(p_cube_set.count).cube_set_type:=bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,'cube set type',',');
      p_cube_set(p_cube_set.count).measurename_dim:=bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,'measurename dim',',');
      --cubes
      get_dimset_cube(p_kpi,p_dimset_name,p_cube_set(p_cube_set.count).cube_set_name,'cube set measure cube',
      p_cube_set(p_cube_set.count).cube);
      get_dimset_cube(p_kpi,p_dimset_name,p_cube_set(p_cube_set.count).cube_set_name,'cube set countvar cube',
      p_cube_set(p_cube_set.count).countvar_cube);
      get_dimset_cube(p_kpi,p_dimset_name,p_cube_set(p_cube_set.count).cube_set_name,'cube set display cube',
      p_cube_set(p_cube_set.count).display_cube);
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_dimset_cube_set '||sqlerrm);
  raise;
End;

/*
p_cube_type is cube set measure cube and cube set countvar cube
*/
procedure get_dimset_cube(
p_kpi varchar2,
p_dimset_name varchar2,
p_cube_set_name varchar2,
p_cube_type varchar2,
p_cube out nocopy bsc_aw_adapter_kpi.cube_r) is
--
l_olap_object_relation bsc_aw_md_wrapper.bsc_olap_object_relation_tb;
Begin
  get_bsc_olap_object_relation(null,null,null,p_kpi,'kpi',l_olap_object_relation);
  for i in 1..l_olap_object_relation.count loop
    if l_olap_object_relation(i).object=p_cube_set_name and l_olap_object_relation(i).relation_type=p_cube_type then
      p_cube.cube_name:=l_olap_object_relation(i).relation_object;
      p_cube.cube_type:=bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,'cube type',',');
      p_cube.cube_datatype:=bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,'cube datatype',',');
    end if;
  end loop;
  --get the axis
  for i in 1..l_olap_object_relation.count loop
    if l_olap_object_relation(i).object=p_cube.cube_name and l_olap_object_relation(i).relation_type='cube axis' then
      p_cube.cube_axis(p_cube.cube_axis.count+1).axis_name:=l_olap_object_relation(i).relation_object;
      p_cube.cube_axis(p_cube.cube_axis.count).axis_type:=bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,'axis type',',');
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_dimset_cube '||sqlerrm);
  raise;
End;

/*
get dimset dim properties
*/
procedure get_kpi_dimset_dim_md(
p_kpi varchar2,
p_dimset_name varchar2,
p_dim out nocopy bsc_aw_adapter_kpi.dim_tb,
p_std_dim out nocopy bsc_aw_adapter_kpi.dim_tb
) is
--
l_olap_object_relation bsc_aw_md_wrapper.bsc_olap_object_relation_tb;
Begin
  get_bsc_olap_object_relation(null,null,null,p_kpi,'kpi',l_olap_object_relation);
  for i in 1..l_olap_object_relation.count loop
    if l_olap_object_relation(i).object=p_dimset_name and l_olap_object_relation(i).relation_type='dim set dim' then
      p_dim(p_dim.count+1).dim_name:=l_olap_object_relation(i).relation_object;
      get_kpi_dimset_dim_md(p_kpi,p_dimset_name,p_dim(p_dim.count),l_olap_object_relation(i).relation_type,
      'dim set dim level');
    elsif l_olap_object_relation(i).object=p_dimset_name and l_olap_object_relation(i).relation_type='dim set std dim' then
      p_std_dim(p_std_dim.count+1).dim_name:=l_olap_object_relation(i).relation_object;
      get_kpi_dimset_dim_md(p_kpi,p_dimset_name,p_std_dim(p_std_dim.count),l_olap_object_relation(i).relation_type,
      'dim set dim level');
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_kpi_dimset_dim_md '||sqlerrm);
  raise;
End;

/*
given a dim, get the properties and levels
p_dim.dim_name is known
p_dim.limit_cube:=bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,'limit cube',',') is reqd since in
bsc_olap_object we do not know which limit cube is tied to which dim

zero code is stored at the dim level, not at the dim level
p_level_type is "dim set dim level"
*/
procedure get_kpi_dimset_dim_md(
p_kpi varchar2,
p_dimset_name varchar2,
p_dim in out nocopy bsc_aw_adapter_kpi.dim_r,
p_dim_type varchar2,
p_level_type varchar2
) is
--
l_olap_object_relation bsc_aw_md_wrapper.bsc_olap_object_relation_tb;
l_oor_zero_code bsc_aw_md_wrapper.bsc_olap_object_relation_tb;
l_oor_rec_level bsc_aw_md_wrapper.bsc_olap_object_relation_tb;
l_index number;
Begin
  get_dim_properties(p_dim);--property,rec,multi level,leven name dim
  --get the levels
  --limit cube=kpi_3014_2_BSC_CCDIM_100.limit.bool,agg map=aggmap_BSC_CCDIM_100_2_3014
  get_bsc_olap_object_relation(null,null,null,p_kpi,'kpi',l_olap_object_relation);
  for i in 1..l_olap_object_relation.count loop
    if l_olap_object_relation(i).relation_type=p_dim_type
    and l_olap_object_relation(i).relation_object=p_dim.dim_name and l_olap_object_relation(i).object=p_dimset_name then
      p_dim.limit_cube:=bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,'limit cube',',');
      p_dim.limit_cube_composite:=bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,'limit cube composite',',');
      p_dim.aggregate_marker:=bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,'dim aggregate marker',',');
      p_dim.agg_map.agg_map:=bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,'agg map',',');
      p_dim.agg_level:=bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,'agg level',',');
      exit;
    end if;
  end loop;
  --get the levels
  --need only level name and position
  --no...we also need the parent child relations...the issue of diamond hierarchies and the need to specify the
  --correct parent.child when limiting level name dim
  --first gte the lowest level
  p_dim.levels.delete;
  p_dim.levels(p_dim.levels.count+1).level_name:=null;--init
  for i in 1..l_olap_object_relation.count loop
    if l_olap_object_relation(i).relation_type=p_level_type
    and l_olap_object_relation(i).object=p_dim.dim_name||'+'||p_dimset_name then
      if instr(l_olap_object_relation(i).property1,'lowest level')>0 then
        l_index:=1;
      else
        l_index:=p_dim.levels.count+1;--start with a min of 2
      end if;
      p_dim.levels(l_index).level_name:=l_olap_object_relation(i).relation_object;
      --p_dim.levels(l_index).position:=nvl(get_level_position(p_dim.levels(l_index).level_name),1);
      p_dim.levels(l_index).position:=nvl(to_number(bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,'position',',')),1);
      p_dim.levels(l_index).aggregated:=nvl(bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,'aggregated',','),'Y');
      p_dim.levels(l_index).zero_aggregated:=nvl(bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,'zero_aggregated',','),'Y');
      /*nvl(Y) for zero_aggregated for backward compatibility */
      p_dim.levels(l_index).zero_code:=nvl(bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,'zero code',','),'N'); --Y or N
      if p_dim.levels(l_index).zero_code='Y' then
        l_oor_zero_code.delete;
        get_bsc_olap_object_relation(p_dim.levels(l_index).level_name,'dimension level','zero code level',p_dim.dim_name,'dimension',l_oor_zero_code);
        p_dim.levels(l_index).zero_code_level:=l_oor_zero_code(1).relation_object;
      end if;
      if p_dim.recursive='Y' then
        l_oor_rec_level.delete;
        get_bsc_olap_object_relation(p_dim.levels(l_index).level_name,'dimension level','recursive parent level',p_dim.dim_name,'dimension',l_oor_rec_level);
        p_dim.levels(l_index).rec_parent_level:=l_oor_rec_level(1).relation_object;
      end if;
    end if;
  end loop;
  --
  l_olap_object_relation.delete;
  get_bsc_olap_object_relation(null,null,'parent level',p_dim.dim_name,'dimension',l_olap_object_relation);
  for i in 1..l_olap_object_relation.count loop
    --we add the parent child relation if both the parent and the child are levels of the kpi
    if is_level_in_dim(p_dim,l_olap_object_relation(i).relation_object) and
    is_level_in_dim(p_dim,l_olap_object_relation(i).object) then
      p_dim.parent_child(p_dim.parent_child.count+1).parent_level:=l_olap_object_relation(i).relation_object;
      p_dim.parent_child(p_dim.parent_child.count).child_level:=l_olap_object_relation(i).object;
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_kpi_dimset_dim_md '||sqlerrm);
  raise;
End;

function is_level_in_dim(
p_dim bsc_aw_adapter_kpi.dim_r,
p_level varchar2) return boolean is
Begin
  for i in 1..p_dim.levels.count loop
    if p_dim.levels(i).level_name=p_level then
      return true;
    end if;
  end loop;
  return false;
Exception when others then
  log_n('Exception in is_level_in_dim '||sqlerrm);
  raise;
End;

/*
given a dimset, get all the calendar metadata
*/
procedure get_kpi_dimset_calendar_md(
p_kpi varchar2,
p_dimset_name varchar2,
p_calendar out nocopy bsc_aw_adapter_kpi.calendar_r
) is
--
l_olap_object_relation bsc_aw_md_wrapper.bsc_olap_object_relation_tb;
l_olap_object bsc_aw_md_wrapper.bsc_olap_object_tb;
l_index number;
Begin
  --dim set calendar
  --
  get_bsc_olap_object_relation(null,null,null,p_kpi,'kpi',l_olap_object_relation);
  for i in 1..l_olap_object_relation.count loop
    if l_olap_object_relation(i).object=p_dimset_name and l_olap_object_relation(i).relation_type='dim set calendar' then
      p_calendar.aw_dim:=l_olap_object_relation(i).relation_object;
      get_calendar_properties(p_calendar);
      p_calendar.limit_cube:=bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,'limit cube',',');
      p_calendar.limit_cube_composite:=bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,'limit cube composite',',');
      p_calendar.aggregate_marker:=bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,'dim aggregate marker',',');
      p_calendar.agg_map.agg_map:=bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,'agg map',',');
      exit;
    end if;
  end loop;
  --get the level name dim
  get_bsc_olap_object(p_calendar.aw_dim,'dimension',p_calendar.aw_dim,'dimension',l_olap_object);
  get_calendar_properties(p_calendar);
  --get the periodicities
  --remember...for periodicities, lowest level is not periodicity(1). its indicated by the property lowest level only
  for i in 1..l_olap_object_relation.count loop
    if l_olap_object_relation(i).object=p_dimset_name and l_olap_object_relation(i).relation_type='dim set periodicity' then
      p_calendar.periodicity(p_calendar.periodicity.count+1).aw_dim:=l_olap_object_relation(i).relation_object;
      p_calendar.periodicity(p_calendar.periodicity.count).periodicity:=to_number(bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,
      'periodicity',','));
      p_calendar.periodicity(p_calendar.periodicity.count).lowest_level:=nvl(bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,
      'lowest level',','),'N');
      p_calendar.periodicity(p_calendar.periodicity.count).missing_level:=nvl(bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,
      'missing level',','),'N');
      p_calendar.periodicity(p_calendar.periodicity.count).aggregated:=nvl(bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,
      'aggregated',','),'Y');
      p_calendar.periodicity(p_calendar.periodicity.count).periodicity_type:=bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,
      'periodicity_type',',');
    end if;
  end loop;
  --load the periodicity relations
  l_olap_object_relation.delete;
  p_calendar.parent_child.delete;
  get_bsc_olap_object_relation(null,null,'parent level',p_calendar.aw_dim,'dimension',l_olap_object_relation);
  for i in 1..l_olap_object_relation.count loop
    if is_periodicity_in_dim(p_calendar,l_olap_object_relation(i).relation_object) and
    is_periodicity_in_dim(p_calendar,l_olap_object_relation(i).object) then
      p_calendar.parent_child(p_calendar.parent_child.count+1).parent_dim_name:=l_olap_object_relation(i).relation_object;
      p_calendar.parent_child(p_calendar.parent_child.count).child_dim_name:=l_olap_object_relation(i).object;
      p_calendar.parent_child(p_calendar.parent_child.count).parent:=to_number(
      bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,'parent periodicity',','));
      p_calendar.parent_child(p_calendar.parent_child.count).child:=to_number(
      bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,'child periodicity',','));
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_kpi_dimset_calendar_md '||sqlerrm);
  raise;
End;

function is_periodicity_in_dim(
p_calendar bsc_aw_adapter_kpi.calendar_r,
p_periodicty_dim varchar2
)return boolean is
Begin
  for i in 1..p_calendar.periodicity.count loop
    if p_calendar.periodicity(i).aw_dim=p_periodicty_dim then
      return true;
    end if;
  end loop;
  return false;
Exception when others then
  log_n('Exception in is_periodicity_in_dim '||sqlerrm);
  raise;
End;

/*
this procedure sets the aggregation_r datatype in bsc_aw_load_kpi
input : kpi
find out all the dimsets for the kpi.
the dimsets will include both actuals and targets
*/
procedure get_aggregation_r(p_aggregation in out nocopy bsc_aw_load_kpi.aggregation_r) is
--
l_kpi bsc_aw_adapter_kpi.kpi_r;
Begin
  l_kpi.kpi:=p_aggregation.kpi;
  get_kpi(l_kpi);
  --
  p_aggregation.parent_kpi:=l_kpi.parent_kpi;
  --
  for i in 1..l_kpi.dim_set.count loop
    p_aggregation.dim_set(p_aggregation.dim_set.count+1):=l_kpi.dim_set(i);
  end loop;
  for i in 1..l_kpi.target_dim_set.count loop
    p_aggregation.dim_set(p_aggregation.dim_set.count+1):=l_kpi.target_dim_set(i);
  end loop;
Exception when others then
  log_n('Exception in get_aggregation_r '||sqlerrm);
  raise;
End;

/*input is the kpi name. all other metadata is populated
*/
procedure get_kpi(p_kpi in out nocopy bsc_aw_adapter_kpi.kpi_r) is
l_oo bsc_aw_md_wrapper.bsc_olap_object_tb;
l_dim_set varchar2(300);
Begin
  --get kpi properties
  if g_debug then
    log('In get_kpi '||p_kpi.kpi);
  end if;
  get_bsc_olap_object(p_kpi.kpi,'kpi',p_kpi.kpi,'kpi',l_oo);
  if l_oo.count=0 then
    log('Could not find kpi info');
    raise bsc_aw_utility.g_exception;
  end if;
  p_kpi.parent_kpi:=bsc_aw_utility.get_parameter_value(l_oo(1).property1,'parent kpi',','); --could be null
  p_kpi.calendar:=bsc_aw_utility.get_parameter_value(l_oo(1).property1,'calendar',',');
  --now the dimsets
  l_oo.delete;
  get_kpi_dimset(p_kpi.kpi,l_oo);
  for i in 1..l_oo.count loop
    if bsc_aw_utility.get_parameter_value(l_oo(i).property1,'dim set type',',')='actual' then
      l_dim_set:=l_oo(i).object;
      get_kpi_dimset_md(p_kpi.kpi,l_dim_set,p_kpi.dim_set(p_kpi.dim_set.count+1));
    end if;
  end loop;
  --targets
  for i in 1..l_oo.count loop
    if bsc_aw_utility.get_parameter_value(l_oo(i).property1,'dim set type',',')='target' then
      l_dim_set:=l_oo(i).object;
      get_kpi_dimset_md(p_kpi.kpi,l_dim_set,p_kpi.target_dim_set(p_kpi.target_dim_set.count+1));
    end if;
  end loop;
  --
Exception when others then
  log_n('Exception in get_kpi '||sqlerrm);
  raise;
End;

-----------------------------
procedure create_workspace(p_name varchar2) is
Begin
  bsc_aw_md_wrapper.create_workspace(p_name);
Exception when others then
  log_n('Exception in create_workspace '||sqlerrm);
  raise;
End;

procedure drop_workspace(p_name varchar2) is
Begin
  clear_all_cache;
  bsc_aw_md_wrapper.drop_workspace(p_name);
  clear_all_cache;
Exception when others then
  log_n('Exception in create_workspace '||sqlerrm);
  raise;
End;

function check_workspace(p_workspace_name varchar2) return varchar2 is
l_olap_object bsc_aw_md_wrapper.bsc_olap_object_tb;
Begin
  get_bsc_olap_object(p_workspace_name,'aw workspace','BSC','APPS',l_olap_object);
  if l_olap_object.count>0 then
    return 'Y';
  else
    return 'N';
  end if;
Exception when others then
  log_n('Exception in check_workspace '||sqlerrm);
  raise;
End;

/*
p_object varchar2,
p_object_type varchar2,
p_parent_object varchar2,
p_parent_object_type varchar2,
are mandatory
optional (match or set)
p_olap_object varchar2,
p_olap_object_type varchar2,
p_property varchar2,
p_operation_flag varchar2
*/
procedure update_olap_object(
p_object varchar2,
p_object_type varchar2,
p_parent_object varchar2,
p_parent_object_type varchar2,
p_match_columns varchar2, --comma separated
p_match_values varchar2, --comma separated
p_set_columns varchar2, --comma separated
p_set_values varchar2 --^ separated. since values can contain , inside
) is
--
l_match_columns dbms_sql.varchar2_table;
l_match_values dbms_sql.varchar2_table;
l_set_columns dbms_sql.varchar2_table;
l_set_values dbms_sql.varchar2_table;
Begin
  clear_all_cache;
  bsc_aw_utility.parse_parameter_values(p_match_columns,',',l_match_columns);
  bsc_aw_utility.parse_parameter_values(p_match_values,',',l_match_values);
  bsc_aw_utility.parse_parameter_values(p_set_columns,',',l_set_columns);
  bsc_aw_utility.parse_parameter_values(p_set_values,'^',l_set_values);
  bsc_aw_md_wrapper.update_olap_object(p_object,p_object_type,p_parent_object,p_parent_object_type,
  l_match_columns,l_match_values,l_set_columns,l_set_values);
  --invalidate cache
  clear_all_cache;
Exception when others then
  log_n('Exception in update_olap_object '||sqlerrm);
  raise;
End;

/*
p_object varchar2,
p_object_type varchar2,
p_relation_type varchar2,
p_parent_object varchar2,
p_parent_object_type varchar2,
are mandatory
optional (match or set)
relation object, relation object type, property
*/
procedure update_olap_object_relation(
p_object varchar2,
p_object_type varchar2,
p_relation_type varchar2,
p_parent_object varchar2,
p_parent_object_type varchar2,
p_match_columns varchar2, --comma separated
p_match_values varchar2, --comma separated
p_set_columns varchar2, --comma separated
p_set_values varchar2 --^ separated
) is
--
l_match_columns dbms_sql.varchar2_table;
l_match_values dbms_sql.varchar2_table;
l_set_columns dbms_sql.varchar2_table;
l_set_values dbms_sql.varchar2_table;
Begin
  clear_all_cache;
  bsc_aw_utility.parse_parameter_values(p_match_columns,',',l_match_columns);
  bsc_aw_utility.parse_parameter_values(p_match_values,',',l_match_values);
  bsc_aw_utility.parse_parameter_values(p_set_columns,',',l_set_columns);
  bsc_aw_utility.parse_parameter_values(p_set_values,'^',l_set_values);
  bsc_aw_md_wrapper.update_olap_object_relation(p_object,p_object_type,p_relation_type,p_parent_object,p_parent_object_type,
  l_match_columns,l_match_values,l_set_columns,l_set_values);
  clear_all_cache;
Exception when others then
  log_n('Exception in update_olap_object_relation '||sqlerrm);
  raise;
End;

procedure insert_olap_object(
p_object varchar2,
p_object_type varchar2,
p_olap_object varchar2,
p_olap_object_type varchar2,
p_parent_object varchar2,
p_parent_object_type varchar2,
p_property1 varchar2
) is
Begin
  /*insert has no cache invalidation */
  bsc_aw_md_wrapper.insert_olap_object(p_object,p_object_type,p_olap_object,p_olap_object_type,p_parent_object,p_parent_object_type,p_property1);
Exception when others then
  log_n('Exception in insert_olap_object '||sqlerrm);
  raise;
End;

procedure insert_olap_object_relation(
p_object varchar2,
p_object_type varchar2,
p_relation_object varchar2,
p_relation_object_type varchar2,
p_relation_type varchar2,
p_parent_object varchar2,
p_parent_object_type varchar2,
p_property1 varchar2
) is
Begin
  /*insert has no cache invalidation */
  bsc_aw_md_wrapper.insert_olap_object_relation(p_object,p_object_type,p_relation_object,p_relation_object_type,p_relation_type,
  p_parent_object,p_parent_object_type,p_property1);
Exception when others then
  log_n('Exception in insert_olap_object_relation '||sqlerrm);
  raise;
End;


/*
we store current change vector value for a base table. called from top loader pack bscawlob.pls
3 api. one to create metadata entry, one to get the current value. one to update to a new value
get_base_table_change_vector will return null if the base table is not in olap object relation
also creates an entry for current period
*/
procedure create_bt_change_vector(p_base_table varchar2) is
l_cv_value number;
Begin
  l_cv_value:=get_bt_change_vector(p_base_table);
  if l_cv_value is null then --create entry
    bsc_aw_md_wrapper.insert_olap_object_relation(p_base_table,'base table','0','change vector','base table change vector',
    p_base_table,'base table',null);
    bsc_aw_md_wrapper.insert_olap_object_relation(p_base_table,'base table',null,'current period','base table current period',
    p_base_table,'base table',null);
  end if;
  clear_all_cache;
Exception when others then
  log_n('Exception in create_bt_change_vector '||sqlerrm);
  raise;
End;

procedure drop_bt_change_vector(p_base_table varchar2) is
Begin
  clear_all_cache;
  bsc_aw_md_wrapper.delete_olap_object_relation(p_base_table,'base table','base table change vector',null,null,p_base_table,'base table');
  bsc_aw_md_wrapper.delete_olap_object_relation(p_base_table,'base table','base table current period',null,null,p_base_table,'base table');
  clear_all_cache;
Exception when others then
  log_n('Exception in drop_bt_change_vector '||sqlerrm);
  raise;
End;

function get_bt_change_vector(p_base_table varchar2) return number is
l_bsc_olap_object_relation bsc_aw_md_wrapper.bsc_olap_object_relation_tb;
Begin
  get_bsc_olap_object_relation(p_base_table,'base table','base table change vector',p_base_table,'base table',l_bsc_olap_object_relation);
  if l_bsc_olap_object_relation.count=0 then
    return null;
  else
    return to_number(l_bsc_olap_object_relation(1).relation_object);
  end if;
Exception when others then
  log_n('Exception in get_bt_change_vector '||sqlerrm);
  raise;
End;

function get_bt_current_period(p_base_table varchar2) return varchar2 is
l_bsc_olap_object_relation bsc_aw_md_wrapper.bsc_olap_object_relation_tb;
Begin
  get_bsc_olap_object_relation(p_base_table,'base table','base table current period',p_base_table,'base table',l_bsc_olap_object_relation);
  if l_bsc_olap_object_relation.count=0 then
    return null;
  else
    return l_bsc_olap_object_relation(1).relation_object;
  end if;
Exception when others then
  log_n('Exception in get_bt_current_period '||sqlerrm);
  raise;
End;

procedure update_bt_change_vector(p_base_table varchar2, p_value number) is
Begin
  update_olap_object_relation(p_base_table,'base table','base table change vector',p_base_table,'base table',
  null,null,'relation_object',to_char(p_value));
Exception when others then
  log_n('Exception in update_bt_change_vector '||sqlerrm);
  raise;
End;

/*to set the current period of the B table , p_value is period.year format at the periodicity of the B table
we need this value to set projection and balance aggregations on time to null when the cp moves forward*/
procedure update_bt_current_period(p_base_table varchar2,p_value varchar2) is
Begin
  update_olap_object_relation(p_base_table,'base table','base table current period',p_base_table,'base table',
  null,null,'relation_object',p_value);
Exception when others then
  log_n('Exception in update_bt_current_period '||sqlerrm);
  raise;
End;

/*
given a bsc_olap_object_relation_tb and a relation type, get all the relation objects
*/
procedure get_relation_object(
p_olap_object_relation bsc_aw_md_wrapper.bsc_olap_object_relation_tb,
p_relation_type varchar2,
p_relation_object in out nocopy dbms_sql.varchar2_table
) is
Begin
  for i in 1..p_olap_object_relation.count loop
    if p_olap_object_relation(i).relation_type=p_relation_type then
      p_relation_object(p_relation_object.count+1):=p_olap_object_relation(i).relation_object;
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_relation_object '||sqlerrm);
  raise;
End;

procedure clear_all_cache is
Begin
  g_oo_cache.delete;
  g_oor_cache.delete;
Exception when others then
  log_n('Exception in clear_all_cache '||sqlerrm);
  raise;
End;

/*
for a dim, load the dimension_r structure
*/
procedure get_dim_md(p_dim_name varchar2,p_dimension out nocopy bsc_aw_adapter_dim.dimension_r) is
l_oo bsc_aw_md_wrapper.bsc_olap_object_tb;
l_oor bsc_aw_md_wrapper.bsc_olap_object_relation_tb;
l_lg_index bsc_aw_utility.number_table; --level group
l_rl_index bsc_aw_utility.number_table;--rec level
l_lg varchar2(200);
l_default_lg_name varchar2(200);
l_level_name_dim varchar2(300);
Begin
  get_bsc_olap_object(null,null,p_dim_name,'dimension',l_oo);
  get_bsc_olap_object_relation(null,null,null,p_dim_name,'dimension',l_oor);
  l_default_lg_name:=bsc_aw_adapter_dim.get_default_lg_name;
  --dim properties
  p_dimension.dim_name:=p_dim_name;
  for i in 1..l_oo.count loop
    if l_oo(i).object=p_dim_name and l_oo(i).object_type='dimension' then
      if l_oo(i).olap_object_type='concat dimension' then
        p_dimension.concat:='Y';
      else
        p_dimension.concat:='N';
      end if;
      p_dimension.property:=l_oo(i).property1;
      p_dimension.dim_type:=bsc_aw_utility.get_parameter_value(l_oo(i).property1,'dimension source type',',');
      p_dimension.corrected:=nvl(bsc_aw_utility.get_parameter_value(l_oo(i).property1,'corrected',','),'N');
      p_dimension.recursive:=nvl(bsc_aw_utility.get_parameter_value(l_oo(i).property1,'recursive',','),'N');
      p_dimension.recursive_norm_hier:=nvl(bsc_aw_utility.get_parameter_value(l_oo(i).property1,'normal hier',','),'N');
      p_dimension.relation_name:=bsc_aw_utility.get_parameter_value(l_oo(i).property1,'relation name',',');
      p_dimension.level_name_dim:=bsc_aw_utility.get_parameter_value(l_oo(i).property1,'level name dim',',');
    elsif l_oo(i).object_type='filter cube' then
      p_dimension.filter_variable:=l_oo(i).object;
    elsif l_oo(i).object_type='limit cube' then
      p_dimension.limit_variable:=l_oo(i).object;
    elsif l_oo(i).object_type='rec level position cube' then
      p_dimension.rec_level_position_cube:=l_oo(i).object;
    elsif l_oo(i).object_type='base value cube' then
      p_dimension.base_value_cube:=l_oo(i).object;
    elsif l_oo(i).object_type='dml program' and l_oo(i).olap_object_type='dml program initial load' then
      p_dimension.initial_load_program:=l_oo(i).object;
    elsif l_oo(i).object_type='dml program' and l_oo(i).olap_object_type='dml program inc load' then
      p_dimension.inc_load_program:=l_oo(i).object;
      --bug fix 5636695
    elsif l_oo(i).object_type='level name dim' then
      l_level_name_dim:=l_oo(i).object;
    end if;
  end loop;
  --bug fix 5636695
  -- if in property1 level name dim is null, we will get it differently.
  -- I have also fixed the issue where we are putting null value for level dim name in property1
  -- But the following code is added for already existing dimension
  if  p_dimension.level_name_dim is null then
    p_dimension.level_name_dim := l_level_name_dim;
  end if;
  --level groups
  for i in 1..l_oo.count loop
    if l_oo(i).object_type='level group' then
      p_dimension.level_groups(p_dimension.level_groups.count+1).level_group_name:=l_oo(i).object;
      l_lg_index(l_oo(i).object):=p_dimension.level_groups.count;
    end if;
  end loop;
  if p_dimension.level_groups.count=0 then --backward compatibility
    p_dimension.level_groups(p_dimension.level_groups.count+1).level_group_name:=l_default_lg_name;
    l_lg_index(l_default_lg_name):=p_dimension.level_groups.count;
  end if;
  --get level group levels, relations, data source
  for i in 1..l_oo.count loop
    if l_oo(i).object_type='dimension level' then
      l_lg:=nvl(bsc_aw_utility.get_parameter_value(l_oo(i).property1,'level group',','),l_default_lg_name);
      p_dimension.level_groups(l_lg_index(l_lg)).levels(p_dimension.level_groups(l_lg_index(l_lg)).levels.count+1).level_name:=l_oo(i).object;
      p_dimension.level_groups(l_lg_index(l_lg)).levels(p_dimension.level_groups(l_lg_index(l_lg)).levels.count).position:=
      to_number(bsc_aw_utility.get_parameter_value(l_oo(i).property1,'position',','));
      p_dimension.level_groups(l_lg_index(l_lg)).levels(p_dimension.level_groups(l_lg_index(l_lg)).levels.count).pk.pk:=
      bsc_aw_utility.get_parameter_value(l_oo(i).property1,'pk',',');
    elsif l_oo(i).object_type='recursive level' then
      l_lg:=nvl(bsc_aw_utility.get_parameter_value(l_oo(i).property1,'level group',','),l_default_lg_name);
      p_dimension.level_groups(l_lg_index(l_lg)).rec_levels(p_dimension.level_groups(l_lg_index(l_lg)).rec_levels.count+1).level_name:=
      l_oo(i).object;
      l_rl_index(l_oo(i).object):=p_dimension.level_groups(l_lg_index(l_lg)).rec_levels.count;
    end if;
  end loop;
  --olap object relations
  for i in 1..l_oor.count loop
    if l_oor(i).relation_type='dimension kpi' then
      p_dimension.kpi_for_dim(p_dimension.kpi_for_dim.count+1).kpi:=l_oor(i).relation_object;
    elsif l_oor(i).relation_type='zero code level' then
      l_lg:=nvl(bsc_aw_utility.get_parameter_value(l_oor(i).property1,'level group',','),l_default_lg_name);
      p_dimension.level_groups(l_lg_index(l_lg)).zero_levels(p_dimension.level_groups(l_lg_index(l_lg)).zero_levels.count+1).level_name:=
      l_oor(i).relation_object;
      p_dimension.level_groups(l_lg_index(l_lg)).zero_levels(p_dimension.level_groups(l_lg_index(l_lg)).zero_levels.count).child_level_name:=
      l_oor(i).object;
    elsif l_oor(i).relation_type='recursive parent level' then
      l_lg:=nvl(bsc_aw_utility.get_parameter_value(l_oor(i).property1,'level group',','),l_default_lg_name);
      p_dimension.level_groups(l_lg_index(l_lg)).rec_levels(l_rl_index(l_oor(i).relation_object)).child_level_name:=l_oor(i).object;
    elsif l_oor(i).relation_type='parent level' then
      l_lg:=nvl(bsc_aw_utility.get_parameter_value(l_oor(i).property1,'level group',','),l_default_lg_name);
      p_dimension.level_groups(l_lg_index(l_lg)).parent_child(p_dimension.level_groups(l_lg_index(l_lg)).parent_child.count+1).child_level:=
      l_oor(i).object;
      p_dimension.level_groups(l_lg_index(l_lg)).parent_child(p_dimension.level_groups(l_lg_index(l_lg)).parent_child.count).parent_level:=
      l_oor(i).relation_object;
      p_dimension.level_groups(l_lg_index(l_lg)).parent_child(p_dimension.level_groups(l_lg_index(l_lg)).parent_child.count).parent_pk:=
      bsc_aw_utility.get_parameter_value(l_oor(i).property1,'pk',',');
      p_dimension.level_groups(l_lg_index(l_lg)).parent_child(p_dimension.level_groups(l_lg_index(l_lg)).parent_child.count).child_fk:=
      bsc_aw_utility.get_parameter_value(l_oor(i).property1,'fk',',');
    end if;
  end loop;
  --get the snowflake info also
  for i in 1..p_dimension.level_groups.count loop
    for j in 1..p_dimension.level_groups(i).levels.count loop
      l_oo.delete;
      get_bsc_olap_object(null,'dimension',p_dimension.level_groups(i).levels(j).level_name,'dimension',l_oo);
      p_dimension.level_groups(i).levels(j).relation_name:=bsc_aw_utility.get_parameter_value(l_oo(1).property1,'relation name',',');
      p_dimension.level_groups(i).levels(j).level_name_dim:=bsc_aw_utility.get_parameter_value(l_oo(1).property1,'level name dim',',');
    end loop;
  end loop;
Exception when others then
  log_n('Exception in get_dim_md '||sqlerrm);
  raise;
End;

procedure analyze_md_tables is
Begin
  bsc_aw_md_wrapper.analyze_md_tables;
Exception when others then
  log_n('Exception in analyze_md_tables '||sqlerrm);
  raise;
End;

function get_upgrade_version return number is
l_oo bsc_aw_md_wrapper.bsc_olap_object_tb;
Begin
  bsc_aw_md_api.get_bsc_olap_object('bsc aw version','bsc aw version','bsc aw version','bsc aw version',l_oo);
  if l_oo.count>0 then
    return to_number(l_oo(1).olap_object);
  else
    return 0;
  end if;
Exception when others then
  log_n('Exception in get_upgrade_version '||sqlerrm);
  raise;
End;

procedure set_upgrade_version(p_version number) is
l_oo bsc_aw_md_wrapper.bsc_olap_object_tb;
Begin
  bsc_aw_md_api.get_bsc_olap_object('bsc aw version','bsc aw version','bsc aw version','bsc aw version',l_oo);
  if l_oo.count>0 then
    update_olap_object('bsc aw version','bsc aw version','bsc aw version','bsc aw version',
    null,null,'olap_object,olap_object_type',bsc_aw_utility.g_upgrade_version||'^bsc aw version');
  else /*first time*/
    insert_olap_object('bsc aw version','bsc aw version',to_char(bsc_aw_utility.g_upgrade_version),'bsc aw version','bsc aw version',
    'bsc aw version',null);
  end if;
Exception when others then
  log_n('Exception in set_upgrade_version '||sqlerrm);
  raise;
End;

-----------------------------
procedure init_all is
Begin
  bsc_aw_md_wrapper.set_context('AW');
  g_debug:=bsc_aw_utility.g_debug;
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

END BSC_AW_MD_API;

/
