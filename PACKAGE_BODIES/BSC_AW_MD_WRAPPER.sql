--------------------------------------------------------
--  DDL for Package Body BSC_AW_MD_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_AW_MD_WRAPPER" AS
/*$Header: BSCAWMWB.pls 120.20 2006/04/20 11:47 vsurendr noship $*/

procedure set_context(p_context varchar2) is
Begin
  g_context:=p_context;
Exception when others then
  log_n('Exception in set_context '||sqlerrm);
  raise;
End;

procedure default_context_if_null is
Begin
  if g_context is null then
    g_context:='AW';
  end if;
Exception when others then
  log_n('Exception in default_context_if_null '||sqlerrm);
  raise;
End;

procedure mark_kpi_recreate(
p_kpi varchar2
) is
Begin
  default_context_if_null;
  update bsc_olap_object set operation_flag='recreate' where object=p_kpi and object_type='kpi' and context=g_context;
Exception when others then
  log_n('Exception in mark_kpi_recreate '||sqlerrm);
  raise;
End;

procedure drop_dim(p_dim_name varchar2) is
Begin
  default_context_if_null;
  if g_debug then
    log('Drop metadata for Dim '||p_dim_name);
  end if;
  delete bsc_olap_object_relation where parent_object_type='dimension' and parent_object=p_dim_name and context=g_context;
  --with the concept of level groups, we do not remove snowflake implementation
  --delete bsc_olap_object_relation where parent_object_type='dimension' and parent_object in (select object from
  --bsc_olap_object where object_type='dimension level' and parent_object_type='dimension' and parent_object=p_dim_name
  --and context=g_context)
  --and context=g_context;
  --delete bsc_olap_object where parent_object_type='dimension' and parent_object in (select object from
  --bsc_olap_object where object_type='dimension level' and parent_object_type='dimension' and parent_object=p_dim_name
  --and context=g_context)
  --and context=g_context;
  delete bsc_olap_object where parent_object_type='dimension' and parent_object=p_dim_name and context=g_context;
Exception when others then
  log_n('Exception in drop_dim '||sqlerrm);
  raise;
End;

/*
create the following
dim
levels
zero levels
rec levels
level relations : only for real levels
register the program names : we need this since we will need to drop the programs when we drop the dim
we assume that the dimension entry is clean. this means we dont try a delete here
*/
procedure create_dim(p_dimension bsc_aw_adapter_dim.dimension_r) is
--
l_position varchar2(400);
l_property varchar2(4000);
l_dim_type varchar2(100);
--
Begin
  default_context_if_null;
  if p_dimension.concat='Y' then
    l_dim_type:='concat dimension';
  else
    l_dim_type:='dimension';--for TYPE, PROJECTION
  end if;
  --property1 will hold info on recursive dim or normal vs time, multi level
  insert_olap_object(p_dimension.dim_name,'dimension',p_dimension.dim_name,l_dim_type,p_dimension.dim_name,'dimension',p_dimension.property);
  --dim related objects
  if p_dimension.relation_name is not null then
    insert_olap_object(p_dimension.relation_name,'relation',p_dimension.relation_name,'relation',
    p_dimension.dim_name,'dimension',null);
  end if;
  if p_dimension.level_name_dim is not null then
    insert_olap_object(p_dimension.level_name_dim,'level name dim',p_dimension.level_name_dim,'dimension',
    p_dimension.dim_name,'dimension',null);
  end if;
  if p_dimension.filter_variable is not null then
    insert_olap_object(p_dimension.filter_variable,'filter cube',p_dimension.filter_variable,'variable',
    p_dimension.dim_name,'dimension',null);
  end if;
  if p_dimension.limit_variable is not null then
    insert_olap_object(p_dimension.limit_variable,'limit cube',p_dimension.limit_variable,'variable',
    p_dimension.dim_name,'dimension',null);
  end if;
  if p_dimension.rec_level_position_cube is not null then
    insert_olap_object(p_dimension.rec_level_position_cube,'rec level position cube',p_dimension.rec_level_position_cube,'variable',
    p_dimension.dim_name,'dimension',null);
  end if;
  if p_dimension.base_value_cube is not null then
    insert_olap_object(p_dimension.base_value_cube,'base value cube',p_dimension.base_value_cube,'variable',
    p_dimension.dim_name,'dimension',null);
  end if;
  --enter the level group info
  for i in 1..p_dimension.level_groups.count loop
    insert_olap_object(p_dimension.level_groups(i).level_group_name,'level group',null,null,p_dimension.dim_name,'dimension',null);
  end loop;
  --populate the levels
  for i in 1..p_dimension.level_groups.count loop
    for j in 1..p_dimension.level_groups(i).levels.count loop
      l_property:='level group='||p_dimension.level_groups(i).level_group_name||',position='||p_dimension.level_groups(i).levels(j).position||
      ',pk='||p_dimension.level_groups(i).levels(j).pk.pk||',level source='||p_dimension.level_groups(i).levels(j).level_source;
      insert_olap_object(p_dimension.level_groups(i).levels(j).level_name,'dimension level',p_dimension.level_groups(i).levels(j).level_name,'dimension',
      p_dimension.dim_name,'dimension',l_property);
    end loop;
  end loop;
  --
  --snow flake. to support kpi when they reference independent levels. look at bsc_aw_adapter_kpi.identify_standalone_levels
  --since the same level can come from diff dim, we need to merge the entries in
  --if this is the metadata of the corrected dim, do not touch the snowflake implementation. corrected dim cannot have new dim levels
  if p_dimension.dim_type <> 'std' and p_dimension.corrected='N' then
    for i in 1..p_dimension.level_groups.count loop
      for j in 1..p_dimension.level_groups(i).levels.count loop
        l_property:='dimension type=normal,zero code,relation name='||p_dimension.level_groups(i).levels(j).relation_name||',level name dim='||
        p_dimension.level_groups(i).levels(j).level_name_dim||',pk='||p_dimension.level_groups(i).levels(j).pk.pk||',';
        merge_olap_object(p_dimension.level_groups(i).levels(j).level_name,'dimension',p_dimension.level_groups(i).levels(j).level_name,'dimension',
        p_dimension.level_groups(i).levels(j).level_name,'dimension',l_property);
        --also insert row for relation and level name dim
        merge_olap_object(p_dimension.level_groups(i).levels(j).relation_name,'relation',p_dimension.level_groups(i).levels(j).relation_name,'relation',
        p_dimension.level_groups(i).levels(j).level_name,'dimension',l_property);
        merge_olap_object(p_dimension.level_groups(i).levels(j).level_name_dim,'level name dim',p_dimension.level_groups(i).levels(j).level_name_dim,
        'dimension',p_dimension.level_groups(i).levels(j).level_name,'dimension',l_property);
        --related objects for each level
        merge_olap_object(p_dimension.level_groups(i).levels(j).filter_variable,'filter cube',p_dimension.level_groups(i).levels(j).filter_variable,
        'variable',p_dimension.level_groups(i).levels(j).level_name,'dimension',l_property);
        merge_olap_object(p_dimension.level_groups(i).levels(j).limit_variable,'limit cube',p_dimension.level_groups(i).levels(j).limit_variable,
        'variable',p_dimension.level_groups(i).levels(j).level_name,'dimension',l_property);
      end loop;
    end loop;
  end if;
  --
  if p_dimension.limit_variable is not null then
    insert_olap_object_relation(p_dimension.dim_name,'dimension',p_dimension.limit_variable,
    'dim limit cube','dim limit cube',p_dimension.dim_name,'dimension',null);
  end if;
  --also insert in olap relation the level and its corresponding zero code level
  for i in 1..p_dimension.level_groups.count loop
    for j in 1..p_dimension.level_groups(i).zero_levels.count loop
      l_property:='level group='||p_dimension.level_groups(i).level_group_name;
      insert_olap_object_relation(p_dimension.level_groups(i).zero_levels(j).child_level_name,'dimension level',
      p_dimension.level_groups(i).zero_levels(j).level_name,'zero code level','zero code level',p_dimension.dim_name,'dimension',l_property);
      --insert this zero code also as a relation for the dim of each level (snow flake levels)
      if p_dimension.dim_type <> 'std' and p_dimension.corrected='N' then
        l_property:=null;--no level group since snow flake
        merge_olap_object_relation(p_dimension.level_groups(i).zero_levels(j).child_level_name,'dimension level',
        p_dimension.level_groups(i).zero_levels(j).level_name,'zero code level','zero code level',
        p_dimension.level_groups(i).zero_levels(j).child_level_name,'dimension',l_property);
      end if;
    end loop;
  end loop;
  --rec levels
  for i in 1..p_dimension.level_groups.count loop
    for j in 1..p_dimension.level_groups(i).rec_levels.count loop
      l_property:='level group='||p_dimension.level_groups(i).level_group_name;
      insert_olap_object(p_dimension.level_groups(i).rec_levels(j).level_name,'recursive level',p_dimension.level_groups(i).rec_levels(j).level_name,
      'dimension',p_dimension.dim_name,'dimension',l_property);
    end loop;
    --also insert into olap relation
    for j in 1..p_dimension.level_groups(i).rec_levels.count loop
      l_property:='level group='||p_dimension.level_groups(i).level_group_name;
      insert_olap_object_relation(p_dimension.level_groups(i).rec_levels(j).child_level_name,'dimension level',
      p_dimension.level_groups(i).rec_levels(j).level_name,
      'recursive parent level','recursive parent level',p_dimension.dim_name,'dimension',l_property);
    end loop;
  end loop;
  --level relations
  --pk and fk info will be used in creating data source for base tables. if base table is at city level and the kpi is at country
  --level, we need to join to the city and state view. we need to know how to join
  for i in 1..p_dimension.level_groups.count loop
    for j in 1..p_dimension.level_groups(i).parent_child.count loop
      insert_olap_object_relation(p_dimension.level_groups(i).parent_child(j).child_level,'dimension level',
      p_dimension.level_groups(i).parent_child(j).parent_level,
      'dimension level','parent level',p_dimension.dim_name,'dimension','level group='||p_dimension.level_groups(i).level_group_name||
      ',pk='||p_dimension.level_groups(i).parent_child(j).parent_pk||',fk='||p_dimension.level_groups(i).parent_child(j).child_fk);
    end loop;
  end loop;
  --register the program names
  if p_dimension.initial_load_program is not null then
    insert_olap_object(p_dimension.initial_load_program,'dml program',p_dimension.initial_load_program,'dml program initial load',
    p_dimension.dim_name,'dimension',null);
  end if;
  --inc refresh program
  if p_dimension.inc_load_program is not null then
    insert_olap_object(p_dimension.inc_load_program,'dml program',p_dimension.inc_load_program,'dml program inc load',
    p_dimension.dim_name,'dimension',null);
  end if;
  --insert dep kpi info
  for i in 1..p_dimension.kpi_for_dim.count loop
    --insert_olap_object_relation(p_dimension.dim_name,'dimension',p_dimension.kpi_for_dim(i).kpi,'kpi','dimension kpi',p_dimension.dim_name,'dimension',
    --null);
    --when we delete a kpi, we must delete this entry. for perf reasons, we keep the object as kpi
    insert_olap_object_relation(p_dimension.kpi_for_dim(i).kpi,'kpi',p_dimension.kpi_for_dim(i).kpi,'kpi','dimension kpi',p_dimension.dim_name,'dimension',
    null);
  end loop;
Exception when others then
  log_n('Exception in create_dim '||sqlerrm);
  raise;
End;

procedure drop_kpi(p_kpi varchar2) is
Begin
  default_context_if_null;
  if g_debug then
    log('drop kpi metadata '||p_kpi||bsc_aw_utility.get_time);
  end if;
  if p_kpi is not null then
    delete bsc_olap_object_relation where parent_object_type='kpi' and parent_object=p_kpi and context=g_context;
    delete bsc_olap_object_relation where object=p_kpi and object_type='kpi' and relation_object=p_kpi and relation_object_type='kpi' and
    relation_type='dimension kpi';
    delete bsc_olap_object where parent_object_type='kpi' and parent_object=p_kpi and context=g_context;
  end if;
Exception when others then
  log_n('Exception in drop_kpi '||sqlerrm);
  raise;
End;

procedure create_calendar(p_calendar bsc_aw_calendar.calendar_r) is
l_property varchar2(4000);
Begin
  default_context_if_null;
  insert_olap_object(p_calendar.dim_name,'dimension',p_calendar.dim_name,'concat dimension',
  p_calendar.dim_name,'dimension',p_calendar.property);
  --related objects of the dim
  insert_olap_object(p_calendar.relation_name,'relation',p_calendar.relation_name,'relation',
  p_calendar.dim_name,'dimension',null);
  insert_olap_object(p_calendar.denorm_relation_name,'denorm relation',p_calendar.denorm_relation_name,'relation',
  p_calendar.dim_name,'dimension',null);
  insert_olap_object(p_calendar.end_period_relation_name,'end period relation',p_calendar.end_period_relation_name,'relation',
  p_calendar.dim_name,'dimension',null);
  --there is also the end_period.temp variable
  insert_olap_object(p_calendar.end_period_relation_name||'.temp','end period temp variable',
  p_calendar.end_period_relation_name||'.temp','variable',p_calendar.dim_name,'dimension',null);
  --
  insert_olap_object(p_calendar.levels_name,'level name dim',p_calendar.levels_name,'dimension',
  p_calendar.dim_name,'dimension',null);
  insert_olap_object(p_calendar.end_period_levels_name,'end period level name dim',p_calendar.end_period_levels_name,'dimension',
  p_calendar.dim_name,'dimension',null);
  --misc objects
  for i in 1..p_calendar.misc_object.count loop
    insert_olap_object(p_calendar.misc_object(i).object_name,p_calendar.misc_object(i).object_type,
    p_calendar.misc_object(i).object_name,p_calendar.misc_object(i).object_type,p_calendar.dim_name,'dimension',null);
  end loop;
  --populate the levels
  for i in 1..p_calendar.periodicity.count loop
    insert_olap_object(p_calendar.periodicity(i).dim_name,'dimension level',p_calendar.periodicity(i).dim_name,'dimension',
    p_calendar.dim_name,'dimension','periodicity='||p_calendar.periodicity(i).periodicity_id||',db_column_name='||
    p_calendar.periodicity(i).db_column_name||',periodicity_type='||p_calendar.periodicity(i).periodicity_type);
    --related objects for each periodicity
    if p_calendar.periodicity(i).aw_time_dim_name is not null then
      insert_olap_object(p_calendar.periodicity(i).aw_time_dim_name,'aw time dim level',p_calendar.periodicity(i).aw_time_dim_name,'dimension',
      p_calendar.dim_name,'dimension','periodicity='||p_calendar.periodicity(i).periodicity_id);
      insert_olap_object(p_calendar.periodicity(i).aw_bsc_aw_rel_name,'bsc aw time relation',
      p_calendar.periodicity(i).aw_bsc_aw_rel_name,'relation',
      p_calendar.dim_name,'dimension','periodicity='||p_calendar.periodicity(i).periodicity_id);
      insert_olap_object(p_calendar.periodicity(i).aw_aw_bsc_rel_name,'aw bsc time relation',
      p_calendar.periodicity(i).aw_aw_bsc_rel_name,'relation',
      p_calendar.dim_name,'dimension','periodicity='||p_calendar.periodicity(i).periodicity_id);
    end if;
  end loop;
  --register the program names
  insert_olap_object(p_calendar.load_program,'dml program',p_calendar.load_program,'dml program initial load',
  p_calendar.dim_name,'dimension',null);
  --fill dep kpi info
  for i in 1..p_calendar.kpi_for_dim.count loop
    --insert_olap_object_relation(p_calendar.dim_name,'dimension',p_calendar.kpi_for_dim(i).kpi,'kpi','dimension kpi',p_calendar.dim_name,'dimension',
    --null);
    insert_olap_object_relation(p_calendar.kpi_for_dim(i).kpi,'kpi',p_calendar.kpi_for_dim(i).kpi,'kpi','dimension kpi',p_calendar.dim_name,'dimension',
    null);
  end loop;
  --
  --insert the parent child relations
  for i in 1..p_calendar.parent_child.count loop
    l_property:='parent periodicity='||p_calendar.parent_child(i).parent||',child periodicity='||p_calendar.parent_child(i).child||',';
    insert_olap_object_relation(p_calendar.parent_child(i).child_dim_name,'dimension level',
    p_calendar.parent_child(i).parent_dim_name,'dimension level','parent level',p_calendar.dim_name,'dimension',l_property);
  end loop;
Exception when others then
  log_n('Exception in create_calendar '||sqlerrm);
  raise;
End;

/*
get bsc olap object table data given the parent object and parent type
access paths
1. par obj specified. par obj type specified. obj not specified. obj type not specified.
2. par obj specified. par obj type specified. obj type specified. obj not specified
3. obj specified. obj type specified
4. obj specified. obj type specified. parent obj type specified
5. obj specified. obj type specified. parent obj specified. parent obj type specified
6. obj null, obj type not null, parent obj null, par obj type not null
*/
procedure get_bsc_olap_object(
p_object varchar2,
p_type varchar2,
p_parent_object varchar2,
p_parent_type varchar2,
p_bsc_olap_object out nocopy bsc_olap_object_tb
) is
--
cursor c1 is select * from bsc_olap_object where parent_object=p_parent_object and parent_object_type=p_parent_type
and context=g_context order by object_type;
cursor c2 is select * from bsc_olap_object where parent_object=p_parent_object and parent_object_type=p_parent_type
and object_type=p_type and context=g_context order by object_type;
cursor c3 is select * from bsc_olap_object where object=p_object and object_type=p_type
and context=g_context order by object_type;
cursor c4 is select * from bsc_olap_object where object=p_object and object_type=p_type and parent_object_type=p_parent_type
and context=g_context order by object_type;
cursor c5 is select * from bsc_olap_object where object=p_object and object_type=p_type and parent_object=p_parent_object
and parent_object_type=p_parent_type and context=g_context order by object_type;
cursor c6 is select * from bsc_olap_object where object_type=p_type and parent_object_type=p_parent_type and context=g_context;
Begin
  default_context_if_null;
  if g_debug and bsc_aw_utility.g_debug_level='all' then
    log('    get_bsc_olap_object object='||p_object||' type='||p_type||' parent_object='||p_parent_object||' po_type='||
    p_parent_type);
  end if;
  if p_object is null and p_type is null and p_parent_object is not null and p_parent_type is not null then --given the parent, get the objects
    open c1;
    loop
      fetch c1 bulk collect into p_bsc_olap_object;
      exit when c1%notfound;
    end loop;
    close c1;
  elsif p_object is null and p_type is not null and p_parent_object is not null and p_parent_type is not null then
    open c2;
    loop
      fetch c2 bulk collect into p_bsc_olap_object;
      exit when c2%notfound;
    end loop;
    close c2;
  elsif p_object is not null and p_type is not null and p_parent_object is null and p_parent_type is null then
    open c3;
    loop
      fetch c3 bulk collect into p_bsc_olap_object;
      exit when c3%notfound;
    end loop;
    close c3;
  elsif p_object is not null and p_type is not null and p_parent_object is null and p_parent_type is not null then
    open c4;
    loop
      fetch c4 bulk collect into p_bsc_olap_object;
      exit when c4%notfound;
    end loop;
    close c4;
  elsif p_object is not null and p_type is not null and p_parent_object is not null and p_parent_type is not null then
    open c5;
    loop
      fetch c5 bulk collect into p_bsc_olap_object;
      exit when c5%notfound;
    end loop;
    close c5;
  elsif p_object is null and p_type is not null and p_parent_object is null and p_parent_type is not null then
    open c6;
    loop
      fetch c6 bulk collect into p_bsc_olap_object;
      exit when c6%notfound;
    end loop;
    close c6;
  end if;
Exception when others then
  log_n('Exception in get_bsc_olap_object '||sqlerrm);
  raise;
End;

/*
access paths:
obj specified. rel type not specified. par obj specified
obj specified. rel type specified. par obj specified
obj specified. rel type specified. par obj not specified
obj not specified. rel type not specified. par obj specified
obj not specified. rel type specified. par obj specified
obj specified. rel type not specified. par obj not specified
*/
procedure get_bsc_olap_object_relation(
p_object varchar2,
p_object_type varchar2,
p_relation_type varchar2,
p_parent_object varchar2,
p_parent_object_type varchar2,
p_bsc_olap_object_relation out nocopy bsc_olap_object_relation_tb
) is
--
cursor c1 is select * from bsc_olap_object_relation where object=p_object and object_type=p_object_type
and parent_object=p_parent_object and parent_object_type=p_parent_object_type
and context=g_context;
cursor c2 is select * from bsc_olap_object_relation where object=p_object and object_type=p_object_type
and parent_object=p_parent_object and parent_object_type=p_parent_object_type
and relation_type=p_relation_type and context=g_context;
cursor c3 is select * from bsc_olap_object_relation where object=p_object and object_type=p_object_type
and relation_type=p_relation_type and context=g_context;
cursor c4 is select * from bsc_olap_object_relation where parent_object=p_parent_object
and parent_object_type=p_parent_object_type
and context=g_context;
cursor c5 is select * from bsc_olap_object_relation where relation_type=p_relation_type
and parent_object=p_parent_object and parent_object_type=p_parent_object_type
and context=g_context;
cursor c6 is select * from bsc_olap_object_relation where object=p_object and object_type=p_object_type
and context=g_context;
--
Begin
  default_context_if_null;
  if g_debug and bsc_aw_utility.g_debug_level='all' then
    log('    get_bsc_olap_object_relation object='||p_object||' type='||p_object_type||' rel_type='||
    p_relation_type||' par_obj='||p_parent_object||' par_obj_type='||p_parent_object_type);
  end if;
  if p_object is not null and p_relation_type is null and p_parent_object is not null then
    open c1;
    loop
      fetch c1 bulk collect into p_bsc_olap_object_relation;
      exit when c1%notfound;
    end loop;
    close c1;
  elsif p_object is not null and p_relation_type is not null and p_parent_object is not null then
    open c2;
    loop
      fetch c2 bulk collect into p_bsc_olap_object_relation;
      exit when c2%notfound;
    end loop;
    close c2;
  elsif p_object is not null and p_relation_type is not null and p_parent_object is null then
    open c3;
    loop
      fetch c3 bulk collect into p_bsc_olap_object_relation;
      exit when c3%notfound;
    end loop;
    close c3;
  elsif p_object is null and p_relation_type is null and p_parent_object is not null then
    open c4;
    loop
      fetch c4 bulk collect into p_bsc_olap_object_relation;
      exit when c4%notfound;
    end loop;
    close c4;
  elsif p_object is null and p_relation_type is not null and p_parent_object is not null then
    open c5;
    loop
      fetch c5 bulk collect into p_bsc_olap_object_relation;
      exit when c5%notfound;
    end loop;
    close c5;
  elsif p_object is not null and p_relation_type is null and p_parent_object is null then
    open c6;
    loop
      fetch c6 bulk collect into p_bsc_olap_object_relation;
      exit when c6%notfound;
    end loop;
    close c6;
  end if;
Exception when others then
  log_n('Exception in get_bsc_olap_object_relation '||sqlerrm);
  raise;
End;

procedure create_kpi(p_kpi bsc_aw_adapter_kpi.kpi_r) is
Begin
  default_context_if_null;
  if g_debug then
    log('create kpi metadata '||p_kpi.kpi||bsc_aw_utility.get_time);
  end if;
  --=======bsc olap objects====================
  insert_olap_object(p_kpi.kpi,'kpi',null,null,p_kpi.kpi,'kpi','calendar='||p_kpi.calendar||',parent kpi='||p_kpi.parent_kpi);
  for i in 1..p_kpi.dim_set.count loop
    create_kpi(p_kpi.kpi,p_kpi.dim_set(i));
  end loop;
  --targets
  for i in 1..p_kpi.target_dim_set.count loop
    if p_kpi.target_dim_set(i).dim_set is not null then
      create_kpi(p_kpi.kpi,p_kpi.target_dim_set(i));
    end if;
  end loop;
Exception when others then
  log_n('Exception in create_kpi '||sqlerrm);
  raise;
End;

procedure create_kpi(p_kpi varchar2,p_dim_set bsc_aw_adapter_kpi.dim_set_r) is
l_property varchar2(4000);
l_comp_added dbms_sql.varchar2_table; --so we insert into oo distinct composite names
l_dimset_name_property varchar2(400);
l_bsc_olap_object_relation bsc_olap_object_relation_tb;
Begin
  default_context_if_null;
  --=======bsc olap objects====================
  --we need to have all the objects entered in bsc_olap_object that needs to be dropped
  --dimension set
  --we just need to knoow if there are targets or not, if there are targets we load, aggregate, load targets and again aggregate
  --base dim set will be useful for target dimsets, for regular dimsets, this is will be null.
  --in BSCAWLKB.pls, we have to see the base dim set for a target dimset. only then can we copy data from target cubes to actual cubes
  l_dimset_name_property:='dim set name='||p_dim_set.dim_set_name||',';
  l_property:='dim set='||p_dim_set.dim_set||',dim set type='||p_dim_set.dim_set_type||',base dim set='||p_dim_set.base_dim_set||',';
  if p_dim_set.targets_higher_levels='Y' then
    l_property:=l_property||'targets,';
  end if;
  l_property:=l_property||'measurename dim='||p_dim_set.measurename_dim||',partition dim='||p_dim_set.partition_dim||',cube design='||
  p_dim_set.cube_design||',number partitions='||p_dim_set.number_partitions||',partition type='||p_dim_set.partition_type||
  ',compressed='||p_dim_set.compressed||',pre calculated='||p_dim_set.pre_calculated;
  insert_olap_object(p_dim_set.dim_set_name,'kpi dimension set',null,null,p_kpi,'kpi',l_property);
  /*
  insert the partition, composite info
  */
  for i in 1..p_dim_set.partition_template.count loop
    l_property:=l_dimset_name_property;
    l_property:=l_property||',template type='||p_dim_set.partition_template(i).template_type||',template use='||p_dim_set.partition_template(i).template_use||
    ',template dim='||p_dim_set.partition_template(i).template_dim;
    insert_olap_object(p_dim_set.partition_template(i).template_name,'partition template',
    p_dim_set.partition_template(i).template_name,'partition template',p_kpi,'kpi',l_property);
  end loop;
  --register the measurename_dim...it also must be dropped
  insert_olap_object(p_dim_set.measurename_dim,'measurename dim',p_dim_set.measurename_dim,'dimension',p_kpi,'kpi',l_property);
  --composite name
  --in 10g, this composite will not exist. each cube has its own
  --we do not create an entry for dimension set composite. in 9i also, measure composite will create entry for the composite name
  for i in 1..p_dim_set.composite.count loop
    l_property:=l_dimset_name_property;
    l_property:=l_property||',composite type='||p_dim_set.composite(i).composite_type;
    insert_olap_object(p_dim_set.composite(i).composite_name,'measure composite',
    p_dim_set.composite(i).composite_name,'composite',p_kpi,'kpi',l_property);
  end loop;
  --cubes
  for i in 1..p_dim_set.cube_set.count loop
    l_property:=l_dimset_name_property;
    l_property:=l_property||',cube set type='||p_dim_set.cube_set(i).cube_set_type||',measurename dim='||p_dim_set.cube_set(i).measurename_dim;
    insert_olap_object(p_dim_set.cube_set(i).cube.cube_name,'data cube',p_dim_set.cube_set(i).cube.cube_name,'cube',
    p_kpi,'kpi',l_property||',cube type='||p_dim_set.cube_set(i).cube.cube_type||',cube data type='||p_dim_set.cube_set(i).cube.cube_datatype);
    if p_dim_set.cube_set(i).countvar_cube.cube_name is not null then
      insert_olap_object(p_dim_set.cube_set(i).countvar_cube.cube_name,'countvar cube',p_dim_set.cube_set(i).countvar_cube.cube_name,'cube',
      p_kpi,'kpi',l_property||',cube type='||p_dim_set.cube_set(i).countvar_cube.cube_type||',cube data type='||
      p_dim_set.cube_set(i).countvar_cube.cube_datatype);
    end if;
    if p_dim_set.cube_set(i).display_cube.cube_name is not null then
      insert_olap_object(p_dim_set.cube_set(i).display_cube.cube_name,'display cube',p_dim_set.cube_set(i).display_cube.cube_name,'cube',
      p_kpi,'kpi',l_property||',cube type='||p_dim_set.cube_set(i).display_cube.cube_type||',cube data type='||
      p_dim_set.cube_set(i).display_cube.cube_datatype);
    end if;
    /*
    right now, we do not create the fcst cube. so we do not register it in olap pbjects. if we register it there, in 10g, lock acquire
    fails with Exception in get_lock ORA-34492: Analytic workspace object BUGLOG_2_4014_FCST does not exist.
    */
  end loop;
  --formulas. we need it in the case where we use datacube design
  for i in 1..p_dim_set.measure.count loop
    if p_dim_set.measure(i).aw_formula.formula_name is not null then
      l_property:=l_dimset_name_property;
      insert_olap_object(p_dim_set.measure(i).aw_formula.formula_name,'measure formula',p_dim_set.measure(i).aw_formula.formula_name,'formula',
      p_kpi,'kpi',l_property||',measure='||p_dim_set.measure(i).measure);
    end if;
  end loop;
  --agg maps
  insert_olap_object(p_dim_set.aggmap_operator.measure_dim,'agg map measure dim',p_dim_set.aggmap_operator.measure_dim,
  'dimension',p_kpi,'kpi',l_dimset_name_property||'agg map');
  insert_olap_object(p_dim_set.aggmap_operator.opvar,'agg map opvar',p_dim_set.aggmap_operator.opvar,
  'variable',p_kpi,'kpi',l_dimset_name_property||'agg map');
  insert_olap_object(p_dim_set.aggmap_operator.argvar,'agg map argvar',p_dim_set.aggmap_operator.argvar,
  'variable',p_kpi,'kpi',l_dimset_name_property||'agg map');
  --
  if p_dim_set.agg_map.created='Y' then
    insert_olap_object(p_dim_set.agg_map.agg_map,'agg map',p_dim_set.agg_map.agg_map,'agg map',p_kpi,'kpi',l_dimset_name_property||'agg map');
  end if;
  if p_dim_set.agg_map_notime.created='Y' then
    insert_olap_object(p_dim_set.agg_map_notime.agg_map,'agg map',p_dim_set.agg_map_notime.agg_map,'agg map',p_kpi,'kpi',
    l_dimset_name_property||'agg map notime');
  end if;
  --limit cubes of the dim
  for i in 1..p_dim_set.dim.count loop
    if p_dim_set.dim(i).limit_cube_composite is not null then
      insert_olap_object(p_dim_set.dim(i).limit_cube_composite,'limit cube composite',p_dim_set.dim(i).limit_cube_composite,
      'composite',p_kpi,'kpi',l_dimset_name_property);
    end if;
    if p_dim_set.dim(i).limit_cube is not null then
      insert_olap_object(p_dim_set.dim(i).limit_cube,'dim limit cube',p_dim_set.dim(i).limit_cube,
      'variable',p_kpi,'kpi',l_dimset_name_property);
    end if;
    if p_dim_set.dim(i).aggregate_marker is not null then
      insert_olap_object(p_dim_set.dim(i).aggregate_marker,'dim aggregate marker',p_dim_set.dim(i).aggregate_marker,
      'variable',p_kpi,'kpi',l_dimset_name_property);
    end if;
    if p_dim_set.dim(i).reset_cube is not null then
      insert_olap_object(p_dim_set.dim(i).reset_cube,'dim reset cube',p_dim_set.dim(i).reset_cube,
      'variable',p_kpi,'kpi',l_dimset_name_property);
    end if;
  end loop;
  for i in 1..p_dim_set.std_dim.count loop
    if p_dim_set.std_dim(i).limit_cube_composite is not null then
      insert_olap_object(p_dim_set.std_dim(i).limit_cube_composite,'limit cube composite',p_dim_set.std_dim(i).limit_cube_composite,
      'composite',p_kpi,'kpi',l_dimset_name_property);
    end if;
    if p_dim_set.std_dim(i).limit_cube is not null then
      insert_olap_object(p_dim_set.std_dim(i).limit_cube,'dim limit cube',p_dim_set.std_dim(i).limit_cube,
      'variable',p_kpi,'kpi',l_dimset_name_property);
    end if;
    --std dim and calendar do not have reset cubes
  end loop;
  --calendar limit cube
  if p_dim_set.calendar.limit_cube_composite is not null then
    insert_olap_object(p_dim_set.calendar.limit_cube_composite,'limit cube composite',p_dim_set.calendar.limit_cube_composite,
    'composite',p_kpi,'kpi',l_dimset_name_property);
  end if;
  if p_dim_set.calendar.limit_cube is not null then
    insert_olap_object(p_dim_set.calendar.limit_cube,'dim limit cube',p_dim_set.calendar.limit_cube,
    'variable',p_kpi,'kpi',l_dimset_name_property);
  end if;
  if p_dim_set.calendar.aggregate_marker is not null then
    insert_olap_object(p_dim_set.calendar.aggregate_marker,'dim aggregate marker',p_dim_set.calendar.aggregate_marker,
    'variable',p_kpi,'kpi',l_dimset_name_property);
  end if;
  --dim agg maps
  for i in 1..p_dim_set.dim.count loop
    if p_dim_set.dim(i).agg_map.agg_map is not null then
      insert_olap_object(p_dim_set.dim(i).agg_map.agg_map,'dim agg map',p_dim_set.dim(i).agg_map.agg_map,
      'agg map',p_kpi,'kpi',l_dimset_name_property);
    end if;
  end loop;
  /*calendar aggmap */
  if p_dim_set.calendar.agg_map.agg_map is not null then
    insert_olap_object(p_dim_set.calendar.agg_map.agg_map,'calendar agg map',p_dim_set.calendar.agg_map.agg_map,'agg map',p_kpi,'kpi',
    l_dimset_name_property);
  end if;
  --program
  insert_olap_object(p_dim_set.initial_load_program.program_name,'dml program',p_dim_set.initial_load_program.program_name,'dml program initial load',
  p_kpi,'kpi',l_dimset_name_property||'DS='||p_dim_set.initial_load_program.ds_base_tables);
  insert_olap_object(p_dim_set.inc_load_program.program_name,'dml program',p_dim_set.inc_load_program.program_name,'dml program inc load',p_kpi,'kpi',
  l_dimset_name_property||'DS='||p_dim_set.inc_load_program.ds_base_tables);
  if p_dim_set.initial_load_program_parallel.program_name is not null then
    insert_olap_object(p_dim_set.initial_load_program_parallel.program_name,'dml program',p_dim_set.initial_load_program_parallel.program_name,
    'dml program initial load parallel',p_kpi,'kpi',l_dimset_name_property||'DS='||p_dim_set.initial_load_program_parallel.ds_base_tables);
  end if;
  if p_dim_set.inc_load_program_parallel.program_name is not null then
    insert_olap_object(p_dim_set.inc_load_program_parallel.program_name,'dml program',p_dim_set.inc_load_program_parallel.program_name,
    'dml program inc load parallel',p_kpi,'kpi',l_dimset_name_property||'DS='||p_dim_set.inc_load_program_parallel.ds_base_tables);
  end if;
  if p_dim_set.LB_resync_program is not null then
    insert_olap_object(p_dim_set.LB_resync_program,'LB resync program',p_dim_set.LB_resync_program,
    'program',p_kpi,'kpi',l_dimset_name_property);
  end if;
  if p_dim_set.aggregate_marker_program is not null then
    insert_olap_object(p_dim_set.aggregate_marker_program,'aggregate marker program',p_dim_set.aggregate_marker_program,'program',p_kpi,'kpi',
    l_dimset_name_property);
  end if;
  --the relational types and views
  for i in 1..p_dim_set.s_view.count loop
    if p_dim_set.s_view(i).type_name is not null then
      insert_olap_object(p_dim_set.s_view(i).type_name,'relational type',null,null,p_kpi,'kpi',l_dimset_name_property);
    end if;
    if p_dim_set.s_view(i).s_view is not null then
      insert_olap_object(p_dim_set.s_view(i).s_view,'relational view',null,null,p_kpi,'kpi',l_dimset_name_property);
    end if;
  end loop;
  --zero code mviews
  for i in 1..p_dim_set.z_s_view.count loop
    if p_dim_set.z_s_view(i).type_name is not null then
      insert_olap_object(p_dim_set.z_s_view(i).type_name,'relational type',null,null,p_kpi,'kpi',l_dimset_name_property||'zero code');
    end if;
    if p_dim_set.z_s_view(i).s_view is not null then
      insert_olap_object(p_dim_set.z_s_view(i).s_view,'relational view',null,null,p_kpi,'kpi',l_dimset_name_property||'zero code');
    end if;
  end loop;
  --
  --=======bsc olap object relations===========
  /*
  we enter the following
  given a dim set, the dimensions. for each dim, the levels. for each dim set, the cubes and the programs.
  we also say if the level has zero code
  to make objects unique, we will do obj+dimset.
  otherwise there will be confusion. example
  BSC_CCDIM_100 dimension AW dim set dim level HRI_PER dimension level lowest level,zero code=,
  BSC_CCDIM_100 dimension AW dim set dim level HRI_PER dimension level lowest level,zero code=,
  these are the dim entries for 2 dim sets. one dim set may have geog with 2 levels. another with 3 levels. if we know only the dim name,
  we cannot know how many levels are in this dim set
  */
  for i in 1..p_dim_set.partition_template.count loop
    l_property:='template type='||p_dim_set.partition_template(i).template_type||',template use='||p_dim_set.partition_template(i).template_use||
    ',template dim='||p_dim_set.partition_template(i).template_dim;
    insert_olap_object_relation(p_dim_set.dim_set_name,'kpi dimension set',p_dim_set.partition_template(i).template_name,'partition name',
    'dim set partition template',p_kpi,'kpi',l_property);
  end loop;
  --partition template partition info
  for i in 1..p_dim_set.partition_template.count loop
    for j in 1..p_dim_set.partition_template(i).template_partitions.count loop
      l_property:='partition dim value='||p_dim_set.partition_template(i).template_partitions(j).partition_dim_value;
      insert_olap_object_relation(p_dim_set.partition_template(i).template_name,'partition template',
      p_dim_set.partition_template(i).template_partitions(j).partition_name,'partition name',
      'partition template partition',p_kpi,'kpi',l_property);
    end loop;
  end loop;
  --composites
  for i in 1..p_dim_set.composite.count loop
    l_property:='composite type='||p_dim_set.composite(i).composite_type;
    insert_olap_object_relation(p_dim_set.dim_set_name,'kpi dimension set',p_dim_set.composite(i).composite_name,'measure composite',
    'dim set measure composite',p_kpi,'kpi',l_property);
  end loop;
  --cube sets
  for i in 1..p_dim_set.cube_set.count loop
    l_property:='cube set type='||p_dim_set.cube_set(i).cube_set_type||',measurename dim='||p_dim_set.cube_set(i).measurename_dim;
    insert_olap_object_relation(p_dim_set.dim_set_name,'kpi dimension set',p_dim_set.cube_set(i).cube_set_name,'cube set',
    'dim set cube set',p_kpi,'kpi',l_property);
  end loop;
  --cubes in the cube set
  for i in 1..p_dim_set.cube_set.count loop
    l_property:='cube type='||p_dim_set.cube_set(i).cube.cube_type||',cube datatype='||p_dim_set.cube_set(i).cube.cube_datatype;
    insert_olap_object_relation(p_dim_set.cube_set(i).cube_set_name,'cube set',p_dim_set.cube_set(i).cube.cube_name,'measure cube',
    'cube set measure cube',p_kpi,'kpi',l_property);
    if p_dim_set.cube_set(i).countvar_cube.cube_name is not null then
      l_property:='cube type='||p_dim_set.cube_set(i).countvar_cube.cube_type||',cube datatype='||
      p_dim_set.cube_set(i).countvar_cube.cube_datatype;
      insert_olap_object_relation(p_dim_set.cube_set(i).cube_set_name,'cube set',p_dim_set.cube_set(i).countvar_cube.cube_name,'countvar cube',
      'cube set countvar cube',p_kpi,'kpi',l_property);
    end if;
    if p_dim_set.cube_set(i).display_cube.cube_name is not null then
      l_property:='cube type='||p_dim_set.cube_set(i).display_cube.cube_type||',cube datatype='||
      p_dim_set.cube_set(i).display_cube.cube_datatype;
      insert_olap_object_relation(p_dim_set.cube_set(i).cube_set_name,'cube set',p_dim_set.cube_set(i).display_cube.cube_name,'display cube',
      'cube set display cube',p_kpi,'kpi',l_property);
    end if;
    /*
    right now, we do not create the fcst cube. so we do not register it in olap pbjects. if we register it there, in 10g, lock acquire
    fails with Exception in get_lock ORA-34492: Analytic workspace object BUGLOG_2_4014_FCST does not exist.
    */
  end loop;
  --cube info
  for i in 1..p_dim_set.cube_set.count loop
    for j in 1..p_dim_set.cube_set(i).cube.cube_axis.count loop
      l_property:='axis type='||p_dim_set.cube_set(i).cube.cube_axis(j).axis_type;
      insert_olap_object_relation(p_dim_set.cube_set(i).cube.cube_name,'cube',
      p_dim_set.cube_set(i).cube.cube_axis(j).axis_name,'axis name','cube axis',p_kpi,'kpi',l_property);
      --
      if p_dim_set.cube_set(i).countvar_cube.cube_name is not null then
        l_property:='axis type='||p_dim_set.cube_set(i).countvar_cube.cube_axis(j).axis_type;
        insert_olap_object_relation(p_dim_set.cube_set(i).countvar_cube.cube_name,'cube',
        p_dim_set.cube_set(i).countvar_cube.cube_axis(j).axis_name,'axis name','cube axis',p_kpi,'kpi',l_property);
      end if;
    end loop;
    if p_dim_set.cube_set(i).display_cube.cube_name is not null then
      for j in 1..p_dim_set.cube_set(i).display_cube.cube_axis.count loop
        l_property:='axis type='||p_dim_set.cube_set(i).display_cube.cube_axis(j).axis_type;
        insert_olap_object_relation(p_dim_set.cube_set(i).display_cube.cube_name,'cube',
        p_dim_set.cube_set(i).display_cube.cube_axis(j).axis_name,'axis name','cube axis',p_kpi,'kpi',l_property);
      end loop;
    end if;
  end loop;
  --for each dim set, enter the dim
  for i in 1..p_dim_set.dim.count loop
    l_property:='limit cube='||p_dim_set.dim(i).limit_cube||',limit cube composite='||p_dim_set.dim(i).limit_cube_composite||
    ',aggregate marker='||p_dim_set.dim(i).aggregate_marker||',agg map='||p_dim_set.dim(i).agg_map.agg_map||',agg level='||
    p_dim_set.dim(i).agg_level||',';
    insert_olap_object_relation(p_dim_set.dim_set_name,'kpi dimension set',p_dim_set.dim(i).dim_name,'dimension',
    'dim set dim',p_kpi,'kpi',l_property);
    --we need the levels to know which levels to aggregate to
    for j in 1..p_dim_set.dim(i).levels.count loop
      l_property:=null;
      if j=1 then --lowest level
        l_property:='lowest level,';
      end if;
      l_property:=l_property||'zero code='||p_dim_set.dim(i).levels(j).zero_code||',position='||p_dim_set.dim(i).levels(j).position||','||
      'aggregated='||p_dim_set.dim(i).levels(j).aggregated||',zero_aggregated='||p_dim_set.dim(i).levels(j).zero_aggregated||',';
      insert_olap_object_relation(p_dim_set.dim(i).dim_name||'+'||p_dim_set.dim_set_name,'dimension',
      p_dim_set.dim(i).levels(j).level_name,'dimension level','dim set dim level',p_kpi,'kpi',l_property);
    end loop;
    --we need to register the limit cube with object as the dim. this is for bsc_aw_load_dim.set_kpi_limit_variables
    --we also register the aggregate markers
    l_property:='dim set type='||p_dim_set.dim_set_type||',';
    insert_olap_object_relation(p_dim_set.dim(i).dim_name,'dimension',p_dim_set.dim(i).limit_cube,'kpi limit cube','kpi limit cube',
    p_kpi,'kpi',l_property);
    if p_dim_set.dim(i).aggregate_marker is not null then
      insert_olap_object_relation(p_dim_set.dim(i).dim_name,'dimension',p_dim_set.dim(i).aggregate_marker,'kpi aggregate marker','kpi aggregate marker',
      p_kpi,'kpi',l_property);
    end if;
    if p_dim_set.dim(i).reset_cube is not null then
      insert_olap_object_relation(p_dim_set.dim(i).dim_name,'dimension',p_dim_set.dim(i).reset_cube,'kpi reset cube','kpi reset cube',
      p_kpi,'kpi',l_property);
    end if;
    --need to register the kpi as belonging to the dim
    merge_olap_object_relation(p_kpi,'kpi',p_kpi,'kpi','dimension kpi',p_dim_set.dim(i).dim_name,'dimension',null);
  end loop;
  --target dim
  --we dont need limit cubes or agg maps here. targets will have the same dim as actuals, levels though are diff. but when we
  --load targets, the limit cubes will correctly catch the level and when we aggregate, only those levels are aggregated up
  --say target is at state. when we aggregate after loading targets, we aggregate from state upwards
  --std dimensions
  --we dont need agg maps for std dim since they are single level dim
  for i in 1..p_dim_set.std_dim.count loop
    l_property:='limit cube='||p_dim_set.std_dim(i).limit_cube||',limit cube composite='||p_dim_set.std_dim(i).limit_cube_composite||
    ',agg level='||p_dim_set.std_dim(i).agg_level||',';
    insert_olap_object_relation(p_dim_set.dim_set_name,'kpi dimension set',p_dim_set.std_dim(i).dim_name,'dimension',
    'dim set std dim',p_kpi,'kpi',l_property);
    --we need the levels to know which levels to aggregate to
    for j in 1..p_dim_set.std_dim(i).levels.count loop
      l_property:=null;
      if j=1 then --lowest level
        l_property:='lowest level,';
      end if;
      --initially we had "dim set std dim level". this is not reqd. type and projection are std dim. levels within them are
      --just levels of a dim
      insert_olap_object_relation(p_dim_set.std_dim(i).dim_name||'+'||p_dim_set.dim_set_name,'dimension',
      p_dim_set.std_dim(i).levels(j).level_name,'dimension level','dim set dim level',p_kpi,'kpi',l_property);
    end loop;
  end loop;
  --for each dim set, enter calendar info
  --we need calendar info since we need to aggregate on time
  l_property:='calendar='||p_dim_set.calendar.calendar||',limit cube='||p_dim_set.calendar.limit_cube||','||
  'limit cube composite='||p_dim_set.calendar.limit_cube_composite||',aggregate marker='||p_dim_set.calendar.aggregate_marker||',agg map='||
  p_dim_set.calendar.agg_map.agg_map;
  insert_olap_object_relation(p_dim_set.dim_set_name,'kpi dimension set',p_dim_set.calendar.aw_dim,'calendar',
  'dim set calendar', p_kpi,'kpi',l_property);
  --note>>> we are not adding an entry for "kpi aggregate marker" for calendar because hier changes in calendar always result in full
  --refresh of the calendar. so we dont track hier changes in calendar
  for i in 1..p_dim_set.calendar.periodicity.count loop
    l_property:='periodicity='||p_dim_set.calendar.periodicity(i).periodicity||',';
    --if i=1 then --lowest periodicity
    if p_dim_set.calendar.periodicity(i).lowest_level='Y' then
      l_property:=l_property||'lowest level,';
    end if;
    if p_dim_set.calendar.periodicity(i).missing_level='Y' then
      l_property:=l_property||'missing level,';
    end if;
    l_property:=l_property||'aggregated='||p_dim_set.calendar.periodicity(i).aggregated||',periodicity_type='||
    p_dim_set.calendar.periodicity(i).periodicity_type;
    insert_olap_object_relation(p_dim_set.dim_set_name,'kpi dimension set',p_dim_set.calendar.periodicity(i).aw_dim,
    'periodicity','dim set periodicity',p_kpi,'kpi',l_property);
  end loop;
  --log the agg map info
  l_property:=null;
  if p_dim_set.agg_map.agg_map is not null then
    if p_dim_set.agg_map.created='Y' then
      insert_olap_object_relation(p_dim_set.dim_set_name,'kpi dimension set',p_dim_set.agg_map.agg_map,'agg map','dim set agg map',
      p_kpi,'kpi',l_property);
    end if;
    l_property:=null;
    if p_dim_set.agg_map_notime.created='Y' then
      insert_olap_object_relation(p_dim_set.dim_set_name,'kpi dimension set',p_dim_set.agg_map_notime.agg_map,'agg map',
      'dim set agg map notime',p_kpi,'kpi',l_property);
    end if;
    --aggmap_operator properties
    l_property:=null;
    insert_olap_object_relation(p_dim_set.dim_set_name,'kpi dimension set',p_dim_set.aggmap_operator.measure_dim,
    'agg map measure dim','agg map measure dim',p_kpi,'kpi',l_property);
    l_property:=null;
    insert_olap_object_relation(p_dim_set.dim_set_name,'kpi dimension set',p_dim_set.aggmap_operator.opvar,
    'agg map opvar','agg map opvar',p_kpi,'kpi',l_property);
    l_property:=null;
    insert_olap_object_relation(p_dim_set.dim_set_name,'kpi dimension set',p_dim_set.aggmap_operator.argvar,
    'agg map argvar','agg map argvar',p_kpi,'kpi',l_property);
  end if;
  --dim set cubes
  for i in 1..p_dim_set.measure.count loop
    l_property:='agg formula='||p_dim_set.measure(i).agg_formula.agg_formula||',std agg='||p_dim_set.measure(i).agg_formula.std_aggregation||','||
    'avg agg='||p_dim_set.measure(i).agg_formula.avg_aggregation||',sql aggregated='||p_dim_set.measure(i).sql_aggregated||
    ',forecast='||p_dim_set.measure(i).forecast||',forecast method='||p_dim_set.measure(i).forecast_method||',';
    l_property:=l_property||'cube='||p_dim_set.measure(i).cube||',fcst cube='||
    p_dim_set.measure(i).fcst_cube||',countvar cube='||p_dim_set.measure(i).countvar_cube||','||
    'display cube='||p_dim_set.measure(i).display_cube||','||
    'measure type='||p_dim_set.measure(i).measure_type||',';
    if p_dim_set.measure(i).aw_formula.formula_name is not null then
      l_property:=l_property||'aw formula='||p_dim_set.measure(i).aw_formula.formula_name||',';
    end if;
    --for non std aggregation, insert the agg formula cubes
    if p_dim_set.measure(i).agg_formula.cubes.count>0 then
      l_property:=l_property||'agg formula cubes=';
      for j in 1..p_dim_set.measure(i).agg_formula.cubes.count loop
        l_property:=l_property||p_dim_set.measure(i).agg_formula.cubes(j)||'+';
      end loop;
      l_property:=l_property||',';
    end if;
    if p_dim_set.measure(i).agg_formula.measures.count>0 then
      l_property:=l_property||'agg formula measures=';
      for j in 1..p_dim_set.measure(i).agg_formula.measures.count loop
        l_property:=l_property||p_dim_set.measure(i).agg_formula.measures(j)||'+';
      end loop;
      l_property:=l_property||',';
    end if;
    l_property:=l_property||bsc_aw_utility.get_property_string(p_dim_set.measure(i).property);
    insert_olap_object_relation(p_dim_set.dim_set_name,'kpi dimension set',p_dim_set.measure(i).measure,'measure',
    'dim set measure',p_kpi,'kpi',l_property);
  end loop;
  --programs
  insert_olap_object_relation(p_dim_set.dim_set_name,'kpi dimension set',p_dim_set.initial_load_program.program_name,'dml program',
  'dml program initial load',p_kpi,'kpi',null);
  insert_olap_object_relation(p_dim_set.dim_set_name,'kpi dimension set',p_dim_set.inc_load_program.program_name,'dml program',
  'dml program inc load',p_kpi,'kpi',null);
  --
  if p_dim_set.initial_load_program_parallel.program_name is not null then
    insert_olap_object_relation(p_dim_set.dim_set_name,'kpi dimension set',p_dim_set.initial_load_program_parallel.program_name,'dml program',
    'dml program initial load parallel',p_kpi,'kpi',null);
  end if;
  if p_dim_set.inc_load_program_parallel.program_name is not null then
    insert_olap_object_relation(p_dim_set.dim_set_name,'kpi dimension set',p_dim_set.inc_load_program_parallel.program_name,'dml program',
    'dml program inc load parallel',p_kpi,'kpi',null);
  end if;
  if p_dim_set.LB_resync_program is not null then
    insert_olap_object_relation(p_dim_set.dim_set_name,'kpi dimension set',p_dim_set.LB_resync_program,'LB resync program',
    'LB resync program',p_kpi,'kpi',null);
  end if;
  --
  if p_dim_set.aggregate_marker_program is not null then
    insert_olap_object_relation(p_dim_set.dim_set_name,'kpi dimension set',p_dim_set.aggregate_marker_program,'aggregate marker program',
    'aggregate marker program',p_kpi,'kpi',null);
  end if;
  -------------------
  --given base tables, find the dimension sets they impact
  --this is imp because, if we need to load a base table, we need tofind the dim set they impact and then load them
  --data sources can share base tables. so first get the distinct list...this is not imp.  if base table -> dim set repeats,
  --its ok
  bsc_aw_utility.init_is_new_value(1);
  for i in 1..p_dim_set.inc_data_source.count loop
    for j in 1..p_dim_set.inc_data_source(i).base_tables.count loop
      if bsc_aw_utility.is_new_value(p_dim_set.inc_data_source(i).base_tables(j).base_table_name,1) then
        --note>>>load kpi module (api load_kpi_dimset_base_table) has dependency on how property looks like.
        --if l_property needs to be changed, make the change in load kpi module also
        l_property:='base table periodicity='||p_dim_set.inc_data_source(i).base_tables(j).periodicity.periodicity||
        ',current change vector=0,measures=';
        for k in 1..p_dim_set.inc_data_source(i).measure.count loop
          l_property:=l_property||p_dim_set.inc_data_source(i).measure(k).measure||'+';
        end loop;
        insert_olap_object_relation(p_dim_set.inc_data_source(i).base_tables(j).base_table_name,'base table',
        p_dim_set.dim_set_name,'dimension set','base table dim set',p_kpi,'kpi',l_property);
        --for each base table, create an entry that will hold the current load set id (in change_vector column)
        l_bsc_olap_object_relation.delete;
        get_bsc_olap_object_relation(p_dim_set.inc_data_source(i).base_tables(j).base_table_name,'base table','base table change vector',
        p_dim_set.inc_data_source(i).base_tables(j).base_table_name,'base table',l_bsc_olap_object_relation);
        --if the entry is new, create one, we enter 0 as the current change vector value
        --these base table entries need to be periodically validated and cleaned up. a base table may no longer be used
        if l_bsc_olap_object_relation.count=0 then
          insert_olap_object_relation(p_dim_set.inc_data_source(i).base_tables(j).base_table_name,'base table',
          '0','change vector','base table change vector',p_dim_set.inc_data_source(i).base_tables(j).base_table_name,'base table',null);
        end if;
      end if;
    end loop;
  end loop;
Exception when others then
  log_n('Exception in create_kpi '||sqlerrm);
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
  default_context_if_null;
  if p_object is not null then
    insert into bsc_olap_object(object,object_type,olap_object,olap_object_type,property1,parent_object,parent_object_type,
    CREATION_DATE,LAST_UPDATE_DATE,CREATED_BY,LAST_UPDATED_BY,LAST_UPDATE_LOGIN,CONTEXT)
    values (p_object,p_object_type,p_olap_object,p_olap_object_type,p_property1,p_parent_object,p_parent_object_type,
    sysdate,sysdate,g_who,g_who,g_who,g_context);
  end if;
Exception when others then
  log_n('Exception in insert_olap_object '||sqlerrm);
  raise;
End;

/*
check
p_object varchar2,
p_object_type varchar2,
p_parent_object varchar2,
p_parent_object_type varchar2,
then insert if needed. later we will see if update is needed else.
we do not match olap_object also since given an object and object type, we must not have multiple olap objects for the same entity
*/
procedure merge_olap_object(
p_object varchar2,
p_object_type varchar2,
p_olap_object varchar2,
p_olap_object_type varchar2,
p_parent_object varchar2,
p_parent_object_type varchar2,
p_property1 varchar2
) is
--
l_bsc_olap_object bsc_olap_object_tb;
Begin
  default_context_if_null;
  get_bsc_olap_object(p_object,p_object_type,p_parent_object,p_parent_object_type,l_bsc_olap_object);
  if l_bsc_olap_object.count>0 then
    null;
    /*update is risky here. we can have multiple rows of data in  l_bsc_olap_object. so which rows do we update here?*/
  else
    insert_olap_object(p_object,p_object_type,p_olap_object,p_olap_object_type,p_parent_object,p_parent_object_type,p_property1);
  end if;
Exception when others then
  log_n('Exception in merge_olap_object '||sqlerrm);
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
  default_context_if_null;
  if p_object is not null then
    insert into bsc_olap_object_relation(object,object_type,relation_object,relation_object_type,
    relation_type,parent_object,parent_object_type,property1,
    CREATION_DATE,LAST_UPDATE_DATE,CREATED_BY,LAST_UPDATED_BY,LAST_UPDATE_LOGIN,CONTEXT)
    values (p_object,p_object_type,p_relation_object,p_relation_object_type,
    p_relation_type,p_parent_object,p_parent_object_type,p_property1,
    sysdate,sysdate,g_who,g_who,g_who,g_context);
  end if;
Exception when others then
  log_n('Exception in insert_olap_object_relation '||sqlerrm);
  raise;
End;

/*
check
p_object varchar2,
p_object_type varchar2,
p_relation_object varchar2,
p_relation_object_type varchar2,
p_relation_type varchar2,
p_parent_object varchar2,
p_parent_object_type varchar2,
then insert...later update?
*/
procedure merge_olap_object_relation(
p_object varchar2,
p_object_type varchar2,
p_relation_object varchar2,
p_relation_object_type varchar2,
p_relation_type varchar2,
p_parent_object varchar2,
p_parent_object_type varchar2,
p_property1 varchar2
) is
--
l_bsc_olap_object_relation bsc_olap_object_relation_tb;
Begin
  default_context_if_null;
  get_bsc_olap_object_relation(p_object,p_object_type,p_relation_type,p_parent_object,p_parent_object_type,l_bsc_olap_object_relation);
  if l_bsc_olap_object_relation.count>0 then
    null;
  else
    insert into bsc_olap_object_relation(object,object_type,relation_object,relation_object_type,
    relation_type,parent_object,parent_object_type,property1,
    CREATION_DATE,LAST_UPDATE_DATE,CREATED_BY,LAST_UPDATED_BY,LAST_UPDATE_LOGIN,CONTEXT)
    values (p_object,p_object_type,p_relation_object,p_relation_object_type,
    p_relation_type,p_parent_object,p_parent_object_type,p_property1,
    sysdate,sysdate,g_who,g_who,g_who,g_context);
  end if;
Exception when others then
  log_n('Exception in insert_olap_object_relation '||sqlerrm);
  raise;
End;

/*
input:
p_object varchar2,
p_object_type varchar2,
p_relation_type varchar2,
p_parent_object varchar2,
p_parent_object_type varchar2,

update:
p_relation_object varchar2,
p_relation_object_type varchar2,
p_property varchar2
*/
procedure update_olap_object_relation(
p_object varchar2,
p_object_type varchar2,
p_relation_type varchar2,
p_parent_object varchar2,
p_parent_object_type varchar2,
p_match_columns dbms_sql.varchar2_table,
p_match_values dbms_sql.varchar2_table,
p_set_columns dbms_sql.varchar2_table,
p_set_values dbms_sql.varchar2_table
) is
--
l_stmt varchar2(8000);
Begin
  default_context_if_null;
  l_stmt:='update bsc_olap_object_relation set ';
  for i in 1..p_set_columns.count loop
    l_stmt:=l_stmt||p_set_columns(i)||'='''||p_set_values(i)||''',';
  end loop;
  l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
  l_stmt:=l_stmt||' where object=:1 and object_type=:2 and relation_type=:3 and parent_object=:4 and parent_object_type=:5 and context=:6';
  for i in 1..p_match_columns.count loop
    l_stmt:=l_stmt||' and '||p_match_columns(i)||'='''||p_match_values(i)||'''';
  end loop;
  if g_debug then
    log(l_stmt||' using '||p_object||','||p_object_type||','||p_relation_type||','||p_parent_object||','||p_parent_object_type||','||
    g_context);
  end if;
  execute immediate l_stmt using p_object,p_object_type,p_relation_type,p_parent_object,p_parent_object_type,g_context;
  if g_debug then
    log('Updated '||sql%rowcount||' rows');
  end if;
Exception when others then
  log_n('Exception in update_olap_object_relation '||sqlerrm);
  raise;
End;

/*
input :
p_object varchar2,
p_object_type varchar2,
p_parent_object varchar2,
p_parent_object_type varchar2

update
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
p_match_columns dbms_sql.varchar2_table,
p_match_values dbms_sql.varchar2_table,
p_set_columns dbms_sql.varchar2_table,
p_set_values dbms_sql.varchar2_table
) is
--
l_stmt varchar2(8000);
Begin
  default_context_if_null;
  l_stmt:='update bsc_olap_object set ';
  for i in 1..p_set_columns.count loop
    l_stmt:=l_stmt||p_set_columns(i)||'='''||p_set_values(i)||''',';
  end loop;
  l_stmt:=l_stmt||'last_update_date=sysdate';
  l_stmt:=l_stmt||' where object=:1 and object_type=:2 and parent_object=:3 and parent_object_type=:4 and context=:5';
  for i in 1..p_match_columns.count loop
    l_stmt:=l_stmt||' and '||p_match_columns(i)||'='''||p_match_values(i)||'''';
  end loop;
  if g_debug then
    log(l_stmt||' using '||p_object||','||p_object_type||','||p_parent_object||','||p_parent_object_type||','||g_context);
  end if;
  execute immediate l_stmt using p_object,p_object_type,p_parent_object,p_parent_object_type,g_context;
  if g_debug then
    log('Updated '||sql%rowcount||' rows');
  end if;
Exception when others then
  log_n('Exception in update_olap_object '||sqlerrm);
  raise;
End;

/*
delete oor
any parameter can be null. if all are null, full delete happens
*/
procedure delete_olap_object_relation(
p_object varchar2,
p_object_type varchar2,
p_relation_type varchar2,
p_relation_object varchar2,
p_relation_object_type varchar2,
p_parent_object varchar2,
p_parent_object_type varchar2) is
--
Begin
  default_context_if_null;
  if g_debug then
    log('delete_olap_object_relation:object='||p_object||', object_type='||p_object_type||
    ', p_relation_type='||p_relation_type||', p_relation_object='||p_relation_object||
    ', p_relation_object_type='||p_relation_object_type||', p_parent_object='||p_parent_object||
    ', p_parent_object_type='||p_parent_object_type||bsc_aw_utility.get_time);
  end if;
  delete bsc_olap_object_relation
  where object=nvl(p_object,object)
  and object_type=nvl(p_object_type,object_type)
  and relation_type=nvl(p_relation_type,relation_type)
  and relation_object=nvl(p_relation_object,relation_object)
  and relation_object_type=nvl(p_relation_object_type,relation_object_type)
  and parent_object=nvl(p_parent_object,parent_object)
  and parent_object_type=nvl(p_parent_object_type,parent_object_type)
  and context=g_context;
  if g_debug then
    log('Deleted '||sql%rowcount||' rows'||bsc_aw_utility.get_time);
  end if;
Exception when others then
  log_n('Exception in delete_olap_object_relation '||sqlerrm);
  raise;
End;

procedure delete_olap_object(
p_object varchar2,
p_object_type varchar2,
p_olap_object varchar2,
p_olap_object_type varchar2,
p_parent_object varchar2,
p_parent_object_type varchar2) is
--
Begin
  default_context_if_null;
  if g_debug then
    log('delete_olap_object:object='||p_object||', object_type='||p_object_type||
    ', p_olap_object='||p_olap_object||', p_olap_object_type='||p_olap_object_type||
    ', p_parent_object='||p_parent_object||', p_parent_object_type='||p_parent_object_type||bsc_aw_utility.get_time);
  end if;
  delete bsc_olap_object
  where object=nvl(p_object,object)
  and object_type=nvl(p_object_type,object_type)
  and olap_object=nvl(p_olap_object,olap_object)
  and olap_object_type=nvl(p_olap_object_type,olap_object_type)
  and parent_object=nvl(p_parent_object,parent_object)
  and parent_object_type=nvl(p_parent_object_type,parent_object_type)
  and context=g_context;
  if g_debug then
    log('Deleted '||sql%rowcount||' rows'||bsc_aw_utility.get_time);
  end if;
Exception when others then
  log_n('Exception in delete_olap_object '||sqlerrm);
  raise;
End;

-------------------------------
---workspace metadata
procedure create_workspace(p_name varchar2) is
Begin
  default_context_if_null;
  insert into bsc_olap_object(object,object_type,olap_object,olap_object_type,property1,parent_object,parent_object_type,
  CREATION_DATE,LAST_UPDATE_DATE,CREATED_BY,LAST_UPDATED_BY,LAST_UPDATE_LOGIN,CONTEXT)
  values (p_name,'aw workspace',p_name,'aw workspace','BSC AW Workspace','BSC','APPS',
  sysdate,sysdate,g_who,g_who,g_who,g_context);
Exception when others then
  log_n('Exception in create_workspace '||sqlerrm);
  raise;
End;

procedure drop_workspace(p_name varchar2) is
Begin
  default_context_if_null;
  delete bsc_olap_object where object=p_name;
Exception when others then
  log_n('Exception in drop_workspace '||sqlerrm);
  raise;
End;

/*
managing info on loads, aggregations, locks etc
in bsc_olap_object, we will use property9 and 10 (9 for now) to store the load start time, end time
session id etc. it will be stored as
load+start time=01:01:2000:12:12:12+end time=01:01:2000:12:12:12+session id=1022,aggregation+..
groups are separated by comma. elements in each group are separated by +.
this is read into a table of records format. then we can update, insert etc.
its then saved back into this format
we have 2 api
get_runtime_parameters(obj,objtype,par obj,par objtype,table of records  (output))
update_runtime_parameters(table of records (input))
table of records has obj,type,par obj and par obj type so we can update
*/
/*
types of input
obj yes, obj type yes, par obj yes, par obj type yes
obj yes, obj type yes, par obj no, par obj type no
obj no, obj type no, par obj yes, par obj type yes
obj no, obj type no, par obj no, par obj type no

procedure get_runtime_parameters(
object varchar2,
object_type varchar2,
parent_object varchar2,
parent_object_type varchar2,
p_parameters out nocopy bsc_runtime_tb
) is
--
--
Begin
  null;
Exception when others then
  log_n('Exception in get_runtime_parameters '||sqlerrm);
  raise;
End;

will implement at a later date
*/

procedure analyze_md_tables is
Begin
  bsc_aw_utility.analyze_table('BSC_OLAP_OBJECT',60);
  bsc_aw_utility.analyze_table('BSC_OLAP_OBJECT_RELATION',60);
Exception when others then
  log_n('Exception in analyze_md_tables '||sqlerrm);
  raise;
End;

-------------------------------
procedure init_all is
Begin
  g_context:='AW';--default
  g_who:=bsc_aw_utility.get_who;
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

END BSC_AW_MD_WRAPPER;

/
