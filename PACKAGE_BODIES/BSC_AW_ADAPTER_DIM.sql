--------------------------------------------------------
--  DDL for Package Body BSC_AW_ADAPTER_DIM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_AW_ADAPTER_DIM" AS
/*$Header: BSCAWADB.pls 120.20 2006/11/04 10:54:24 amitgupt noship $*/

--given a array of dim, first get the full list of dim as parent child
--and then group them into dim
--p_dim_level_list is a set of BSC dim levels
procedure create_dim(p_dim_level_list dbms_sql.varchar2_table) is
l_affected_kpi dbms_sql.varchar2_table;
Begin
  create_dim(p_dim_level_list,l_affected_kpi);
Exception when others then
  log_n('Exception in create_dim '||sqlerrm);
  raise;
End;

/*
if create_dim has to end up re-creating a dim, then the affected kpi are returned. these affected kpi have been
dropped so the dim can be recreated. mostly, p_affected_kpi should be empty
*/
procedure create_dim(
p_dim_level_list dbms_sql.varchar2_table,
p_affected_kpi in out nocopy dbms_sql.varchar2_table
) is
--
l_dim_parent_child dim_parent_child_tb;
l_dim_levels levels_tv;
--
Begin
  get_all_dim_levels(p_dim_level_list,l_dim_parent_child,l_dim_levels);
  --l_dim_levels contains the level name and id. will be used to generate the dim name
  group_levels_into_sets(l_dim_parent_child);
  create_dim(l_dim_parent_child,l_dim_levels,g_dimensions);
  create_std_dim(g_dimensions); --this creates the type and projection dim
  if g_debug then
    dmp_g_dimensions(g_dimensions);
  end if;
  implement_dim_aw(g_dimensions,p_affected_kpi);
  if g_debug then
    log_n('create_dim complete '||bsc_aw_utility.get_time);
  end if;
Exception when others then
  log_n('Exception in create_dim '||sqlerrm);
  raise;
End;

--get the parent child level relation and the properties of the levels
--excluding the position
--position is later calculated
--needs to be reset later
procedure get_all_dim_levels(
p_dim_level_list dbms_sql.varchar2_table,
p_dim_parent_child out nocopy dim_parent_child_tb,
p_dim_levels out nocopy levels_tv
) is
Begin
  if g_debug then
    log_n('In get_all_dim_levels'||bsc_aw_utility.get_time);
  end if;
  --get all the parent child relations for the levels
  bsc_aw_bsc_metadata.get_all_parent_child(p_dim_level_list,p_dim_parent_child,p_dim_levels);
  if g_debug then
    log_n('p_dim_parent_child');
    for i in 1..p_dim_parent_child.count loop
      log(p_dim_parent_child(i).parent_level||'('||p_dim_parent_child(i).parent_pk||') '||
      p_dim_parent_child(i).child_level||'('||p_dim_parent_child(i).child_fk||')');
    end loop;
  end if;
Exception when others then
  log_n('Exception in get_all_dim_levels '||sqlerrm);
  raise;
End;

procedure group_levels_into_sets(
p_dim_parent_child in out nocopy dim_parent_child_tb
) is
--
l_level_considered dbms_sql.varchar2_table;
l_set number;
l_flag boolean;
l_level varchar2(100);
--
Begin
  l_level_considered.delete;
  l_set:=0;
  --loop completed when there are no more parent child combinations that need a set number assigned
  loop
    --get the first empty set
    l_flag:=false;
    for i in 1..p_dim_parent_child.count loop
      if p_dim_parent_child(i).level_set is null then
        l_level:=p_dim_parent_child(i).child_level;
        l_flag:=true;
        exit;
      end if;
    end loop;
    --see if we can exit
    if l_flag=false then
      --all work complete
      exit;
    end if;
    l_set:=l_set+1;
    assign_set_to_level(p_dim_parent_child,l_level_considered,l_level,l_set);
  end loop;
Exception when others then
  log_n('Exception in group_levels_into_sets '||sqlerrm);
  raise;
End;

--assign a set number to this level (p_level). then for each parent and child, see if a set is already assigned.
--if not, call this procedure recursively for those levels
procedure assign_set_to_level(
p_dim_parent_child in out nocopy dim_parent_child_tb,
p_level_considered in out nocopy dbms_sql.varchar2_table,
p_level varchar2,
p_set number
) is
Begin
  if bsc_aw_utility.in_array(p_level_considered,p_level) then
    return;
  end if;
  for i in 1..p_dim_parent_child.count loop
    if p_dim_parent_child(i).child_level=p_level then
      p_dim_parent_child(i).level_set:=p_set;
      p_level_considered(p_level_considered.count+1):=p_level;
    end if;
  end loop;
  --for each parent, set the level_set number
  for i in 1..p_dim_parent_child.count loop
    if p_dim_parent_child(i).child_level=p_level then
      if p_dim_parent_child(i).parent_level is not null and p_dim_parent_child(i).parent_level<>p_dim_parent_child(i).child_level then
        assign_set_to_level(p_dim_parent_child,p_level_considered,p_dim_parent_child(i).parent_level,p_set);
      end if;
    end if;
  end loop;
  --for each child, set the level_set number
  for i in 1..p_dim_parent_child.count loop
    if p_dim_parent_child(i).parent_level=p_level then
      if p_dim_parent_child(i).child_level is not null and p_dim_parent_child(i).parent_level<>p_dim_parent_child(i).child_level then
        --child cannot be null...still no harm
        assign_set_to_level(p_dim_parent_child,p_level_considered,p_dim_parent_child(i).child_level,p_set);
      end if;
    end if;
  end loop;
Exception when others then
  log_n('Exception in assign_set_to_level '||sqlerrm);
  raise;
End;

/*
create_dim is passed an array of information. this api first creates the dim structure in memory
by using the level set info
*/
procedure create_dim(
p_dim_parent_child dim_parent_child_tb,
p_dim_levels levels_tv,
p_dimensions out nocopy dimension_tb
) is
--
l_max_set number;
l_level varchar2(100);
l_id number;
l_count number;
l_dim dimension_r;
--
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
--
Begin
  l_max_set:=0;
  for i in 1..p_dim_parent_child.count loop
    if p_dim_parent_child(i).level_set>l_max_set then
      l_max_set:=p_dim_parent_child(i).level_set;
    end if;
  end loop;
  --l_max_set is the number of dimensions
  for i in 1..l_max_set loop
    l_count:=0;
    --bug fix 5636695
    -- we have used a new public var here, so as to take an empty structure and fill in
    -- the issue here was we had level values and parent child values retained from the previous
    -- kpi run p_dimensions... which was causing problem
    --- this will clear the previous entries from the structure
    l_dim.level_groups.delete;
    bsc_aw_utility.delete_table('bsc_aw_temp_vn',null);
    for j in 1..p_dim_parent_child.count loop
      if p_dim_parent_child(j).level_set=i then
        l_level:=p_dim_parent_child(j).child_level;
        l_id:=p_dim_levels(l_level).level_id;
        execute immediate 'insert into bsc_aw_temp_vn(name,id) values(:1,:2)' using l_level,l_id;
        l_count:=l_count+1;
        l_dim.level_groups(1).parent_child(l_count):=p_dim_parent_child(j);
      end if;
    end loop;
    l_count:=0;
    g_stmt:='select distinct name,id from bsc_aw_temp_vn order by id';
    open cv for g_stmt;
    loop
      fetch cv into l_level,l_id;
      exit when cv%notfound;
      l_count:=l_count+1;
      l_dim.level_groups(1).levels(l_count):=p_dim_levels(l_level);
      --p_dim_levels will have the level name, id, position(set_level_position api), pk, fk etc
      --new dim all have default 1 level group
    end loop;
    close cv;
    --all dim have at-least 2 levels. the top level is zero code level. this means all dim are concat dim
    --if this is a single level dim vs multi level dim
    --the name of the concat dim does not contain the zero codes or the rec levels
    /*
    we ran into an error where the name of the object ran to greater than 64 chars and AW errored creating the object
    AW allows max of 64 chars in a name. so we use the string of all level ids and then create a hash value and use the
    hash value. the hash value is starting from 100 to 1073741824
    we trust that the hash value for a given string does not change from db version to version. tested on 9i and 10g.
    its consistent.
    */
    p_dimensions(i) := l_dim;
    p_dimensions(i).corrected:='N';
    p_dimensions(i).concat:='Y';
    make_dim_name(p_dimensions(i),get_dim_name_hash_string(p_dimensions(i)));
    p_dimensions(i).dim_type:='custom';
    p_dimensions(i).relation_name:=p_dimensions(i).dim_name||'.rel';
    p_dimensions(i).level_groups(1).level_group_name:=get_default_lg_name;
    --set the level position. level positions are useful to see if we need to aggregate on the fly
    set_level_position(p_dimensions(i));
    --if a dim is a recursive dim, we have no zero code level. the reason is that the top node is zero code
    set_dim_recursive(p_dimensions(i));
    get_kpi_for_dim(p_dimensions(i));
    if p_dimensions(i).recursive='Y' then
      set_rec_dim_properties(p_dimensions(i));--sets normal hier as default implementation
      create_virtual_rec_level(p_dimensions(i));
      create_rec_data_source(p_dimensions(i));
    else
      create_virtual_zero_code_level(p_dimensions(i));--simply creating the metadata
      create_data_source(p_dimensions(i));
    end if;
    --set the dim properties
    set_dim_properties(p_dimensions(i));
  end loop;
Exception when others then
  log_n('Exception in create_dim '||sqlerrm);
  raise;
End;

function get_dim_name_hash_string(p_dimension dimension_r) return varchar2 is
l_hash_string varchar2(4000);
Begin
  l_hash_string:='DIM';
  for i in 1..p_dimension.level_groups.count loop
    for j in 1..p_dimension.level_groups(i).levels.count loop
      l_hash_string:=l_hash_string||'.'||p_dimension.level_groups(i).levels(j).level_id;
    end loop;
  end loop;
  --add the time to make it unique
  l_hash_string:=l_hash_string||'.'||bsc_aw_utility.get_dbms_time;
  return l_hash_string;
Exception when others then
  log_n('Exception in get_dim_name_hash_string '||sqlerrm);
  raise;
End;

procedure make_dim_name(p_dimension in out nocopy dimension_r,p_hash_string varchar2) is
l_hash_value varchar2(200);
Begin
  p_dimension.dim_name:='BSC_CC';
  l_hash_value:=bsc_aw_utility.get_hash_value(p_hash_string,100,1073741824);
  p_dimension.dim_name:=p_dimension.dim_name||'_'||l_hash_value;
Exception when others then
  log_n('Exception in make_dim_name '||sqlerrm);
  raise;
End;

procedure set_dim_properties(p_dim in out nocopy dimension_r) is
Begin
  if p_dim.dim_type<>'std' and p_dim.level_groups(1).data_source.data_source is not null then --DBI dim
    p_dim.dim_type:='dbi';
  end if;
  --here dim are normal. in bsc_aw_calendar module, we have time dim being created
  p_dim.property:='dimension type=normal,dimension source type='||p_dim.dim_type||',corrected='||p_dim.corrected||',';
  --as old dim ages, the corrected flag is set to yes
  if p_dim.recursive='Y' then
    p_dim.property:=p_dim.property||'recursive,';
    if p_dim.recursive_norm_hier='Y' then
      p_dim.property:=p_dim.property||'normal hier,';
      --also the denorm source, child col and parent col. we need it in the load dim module to load
      --norm hier into bsc_aw_temp_pc
      --note>>>the denorm_data_source is like (select a,b from CC). it has comma inside. if in bscawldb.pls, we try
      --to bsc_aw_utility.get_parameter_value(l_dim_property,'denorm source',','), we will get (select a  since the stmt
      --is cutoff at the first , so we will replace the , with *^ and later, in bscawldb.pls, replace the *^ with ,
      --note>>>p_dim.level_groups(1).data_source.data_source and p_dim.level_groups(1).data_source.denorm_data_source go together
      if p_dim.level_groups(1).data_source.data_source is not null then
        p_dim.property:=p_dim.property||'denorm source='||replace(p_dim.level_groups(1).data_source.denorm_data_source,',','*^')||',';
        p_dim.property:=p_dim.property||'child col='||p_dim.level_groups(1).data_source.child_col||',parent col='||
        p_dim.level_groups(1).data_source.parent_col||',';
      end if;
    end if;
  end if;
  if p_dim.level_groups.count>1 or p_dim.level_groups(1).levels.count>1 then
    p_dim.property:=p_dim.property||'multi level,';
  end if;
  for i in 1..p_dim.level_groups.count loop
    if p_dim.level_groups(i).zero_levels.count>0 then
      p_dim.property:=p_dim.property||'zero code,';
      exit;
    end if;
  end loop;
  p_dim.property:=p_dim.property||'relation name='||p_dim.relation_name||',';
  p_dim.property:=p_dim.property||'level name dim='||p_dim.level_name_dim||',';
Exception when others then
  log_n('Exception in set_dim_properties '||sqlerrm);
  raise;
End;

procedure reset_dimension_r(p_dim in out nocopy dimension_r) is
Begin
  p_dim.level_groups(1).levels.delete;
  p_dim.level_groups(1).parent_child.delete;
  p_dim.level_groups(1).zero_levels.delete;
  p_dim.level_groups(1).rec_levels.delete;
  p_dim.recursive:='N';
  p_dim.recursive_norm_hier:='N';
  p_dim.kpi_for_dim.delete;
Exception when others then
  log_n('Exception in reset_dimension_r '||sqlerrm);
  raise;
End;

procedure set_level_position(
p_dimension in out nocopy dimension_r
) is
--
l_flag boolean;
--
Begin
  if p_dimension.level_groups(1).levels.count=1 then
    --single level and recursive dim
    p_dimension.level_groups(1).levels(1).position:=1;
  else
    --multi level dim
    --get the lowest levels. they are the seed levels. then set the positions
    for i in 1..p_dimension.level_groups(1).levels.count loop
      --for each level, see if its a child. if its a child, start setting the position
      l_flag:=false;
      for j in 1..p_dimension.level_groups(1).parent_child.count loop
        if p_dimension.level_groups(1).parent_child(j).parent_level=p_dimension.level_groups(1).levels(i).level_name then
          l_flag:=true;
          exit;
        end if;
      end loop;
      if l_flag=false then
        set_level_position(p_dimension,p_dimension.level_groups(1).levels(i).level_name,1);
      end if;
    end loop;
  end if;
Exception when others then
  log_n('Exception in set_level_position '||sqlerrm);
  raise;
End;

/*
consider this
1 - 2 - 3
8 - 7 - 6 - 5 - 4 - 3
8 - 9 - 10
8 - 9 - 3

lowest level have position 1. we also need to handle rec dim
rec dim are handled like this:
say only first 2 levels are pre-agg, larry and john wookey. the reports asks for cliff. then all we need to do it to limit the relation
dim.level to the value of cliff and call the aggregation. the entry for cliff has all the denorm values of employees under cliff in it.
so setting the position is not reqd for rec dim
*/
procedure set_level_position(
p_dimension in out nocopy dimension_r,
p_level varchar2,
p_position number
) is
--
l_level_index number;
--
Begin
  --set the position
  if g_debug then
    log_n('In set_level_position, p_level='||p_level||' p_position='||p_position);
  end if;
  if p_level is null then
    return;
  end if;
  for i in 1..p_dimension.level_groups(1).levels.count loop
    if p_dimension.level_groups(1).levels(i).level_name=p_level then
      l_level_index:=i;
      exit;
    end if;
  end loop;
  if p_dimension.level_groups(1).levels(l_level_index).position is not null
  and p_dimension.level_groups(1).levels(l_level_index).position>=p_position then
    return;
  end if;
  p_dimension.level_groups(1).levels(l_level_index).position:=p_position;
  --call the routine recursively for all parents
  for i in 1..p_dimension.level_groups(1).parent_child.count loop
    if p_dimension.level_groups(1).parent_child(i).child_level=p_level
    and p_dimension.level_groups(1).parent_child(i).parent_level is not null
    and p_dimension.level_groups(1).parent_child(i).parent_level<>p_dimension.level_groups(1).parent_child(i).child_level then
      set_level_position(p_dimension,p_dimension.level_groups(1).parent_child(i).parent_level,p_position+1);
    end if;
  end loop;
Exception when others then
  log_n('Exception in set_level_position '||sqlerrm);
  raise;
End;

/*
find all the kpi implemented in AW that have this dim
this reads BSC metadata. so its giving an idea of kpi that maynot be implemented as yet
but will be. this means there may be some kpi already implemented that no longer has this dim.
this kpi will not be picked up since we are reading bsc metadata
kpi_for_dim_r holds the kpi and dimset info
*/
procedure get_kpi_for_dim(p_dimension in out nocopy dimension_r) is
Begin
  bsc_aw_bsc_metadata.get_kpi_for_dim(p_dimension);
Exception when others then
  log_n('Exception in get_kpi_for_dim '||sqlerrm);
  raise;
End;

/*
zero code level are virtual levels that are going to be created
its the top levels for any dim
if we have
comp >- prod >- prod family
comp >- prod >- manager
we will have 2 zero code levels. final hierarchy is
comp >- prod >- prod family >- prod family zero
comp >- prod >- manager >- manager zero

This api is not invoked for recursive dimensions

new:
we do not need zero code levels. this will cause huge problems in olap table fn views. if we have zero code level
and regular level, on which will the olap table fn be based? we hit the zero code mv for zero values and regular
values.

zero code is implemented as simply a virtual level. the name is in dim.level_groups(1).levels. in the relation we will have for the
top level
    |
zero|               country(0)  country(0)...
    |
    ----------------country---------------------->

New: we need zero code levels for all levels. imagine that a kpi has only city dim. in this case, we will have zero code
for city level since its the top level.

city zero| city(0)...
         |
ctry zero|               country(0)  country(0)...
         |
         ---city-------------country---------------------->

*/
procedure create_virtual_zero_code_level(
p_dimension in out nocopy dimension_r
)is
Begin
  for i in 1..p_dimension.level_groups(1).levels.count loop
    p_dimension.level_groups(1).zero_levels(p_dimension.level_groups(1).zero_levels.count+1).level_name:=p_dimension.level_groups(1).levels(i).level_name||'_ZERO';
    p_dimension.level_groups(1).zero_levels(p_dimension.level_groups(1).zero_levels.count).child_level_name:=p_dimension.level_groups(1).levels(i).level_name;
  end loop;
Exception when others then
  log_n('Exception in create_virtual_zero_code_level '||sqlerrm);
  raise;
End;

/*
called only for rec dim
creates a parent level. this level contains all entries of the child level. child level will maintain fact data for each
dim level value, like expense for each employee. the rolled up value = sum of all child values + its own value
*/
procedure create_virtual_rec_level(
p_dimension in out nocopy dimension_r
)is
Begin
  p_dimension.level_groups(1).rec_levels(1).level_name:=p_dimension.level_groups(1).levels(1).level_name||'_PARENT';
  p_dimension.level_groups(1).rec_levels(1).child_level_name:=p_dimension.level_groups(1).levels(1).level_name;
Exception when others then
  log_n('Exception in create_virtual_rec_level '||sqlerrm);
  raise;
End;

/*if this is a bsc rec dim, we cannot have denorm implementation. only norm impl
*/
procedure set_rec_dim_properties(p_dimension in out nocopy dimension_r) is
Begin
  p_dimension.recursive_norm_hier:='Y'; --default
Exception when others then
  log_n('Exception in set_rec_dim_properties '||sqlerrm);
  raise;
End;

/*
rec dim have one level. 2 data sources are necessary. one for the key, like employee. the other is the relation
in a denorm fashion, employee,manager
we have inc program same as initial program for now
rec data source can be null if this is native bsc rec dim
*/
procedure create_rec_data_source(
p_dimension in out nocopy dimension_r
) is
Begin
  bsc_aw_bsc_metadata.create_rec_data_source(p_dimension);
  p_dimension.initial_load_program:='load_'||p_dimension.dim_name||'.initial';
  p_dimension.inc_load_program:='load_'||p_dimension.dim_name||'.initial';
Exception when others then
  log_n('Exception in create_rec_data_source '||sqlerrm);
  raise;
End;

/*
this procedure creates the data source for dbi dimensions
*/
procedure create_data_source(
p_dimension in out nocopy dimension_r
) is
Begin
  bsc_aw_bsc_metadata.create_data_source(p_dimension);
  p_dimension.initial_load_program:='load_'||p_dimension.dim_name||'.initial';
  p_dimension.inc_load_program:='load_'||p_dimension.dim_name||'.inc';
Exception when others then
  log_n('Exception in create_data_source '||sqlerrm);
  raise;
End;

/*
updates the metadata and then creates the aw objects for new dim
the logic is as follows:

*/
procedure implement_dim_aw(
p_dimensions in out nocopy dimension_tb,
p_affected_kpi in out nocopy dbms_sql.varchar2_table
) is
--
--
Begin
  if g_debug then
    log_n('In implement_dim_aw');
  end if;
  for i in 1..p_dimensions.count loop
    implement_dim_aw(p_dimensions(i),p_affected_kpi);
  end loop;
Exception when others then
  log_n('Exception in implement_dim_aw '||sqlerrm);
  raise;
End;

procedure implement_dim_aw(
p_dimension in out nocopy dimension_r,
p_affected_kpi in out nocopy dbms_sql.varchar2_table
) is
--
l_dim_create varchar2(100);
l_recreate_option varchar2(100);
--
Begin
  if g_debug then
    log_n('In implement_dim_aw dimension='||p_dimension.dim_name||', dim type='||p_dimension.dim_type);
  end if;
  --see if the dim already exists, or any old dim needs correction
  if p_dimension.dim_type<>'std' then
    correct_old_dim(p_dimension,l_dim_create);
  else
    if g_debug then
      log('This is std dim. Check to see if dim exists...');
    end if;
    if bsc_aw_md_api.is_dim_present(p_dimension.dim_name)=false then
      l_dim_create:='create all';
    end if;
  end if;
  --
  if p_dimension.dim_type='std' then
    l_recreate_option:='RECREATE STD DIM';
  else
    l_recreate_option:='RECREATE DIM';
  end if;
  if bsc_aw_utility.get_parameter_value(bsc_aw_utility.g_options,l_recreate_option)='Y' then
    if g_debug then
      log('Dim needs to be force recreated');
    end if;
    l_dim_create:='create all';
  elsif bsc_aw_utility.get_parameter_value(bsc_aw_utility.g_options,'RECREATE PROGRAM')='Y' then
    if g_debug then
      log('Dim needs to be force recreated');
    end if;
    l_dim_create:='create all';
  end if;
  if l_dim_create='create all' then
    if p_dimension.dim_type<>'std' then
      check_dim_name_conflict(p_dimension);--change the dim name if there is clash
    end if;
    create_dim_objects(p_dimension);
  else
    if g_debug then
      log('Noop for dimension '||p_dimension.dim_name);
    end if;
  end if;
Exception when others then
  log_n('Exception in implement_dim_aw '||sqlerrm);
  raise;
End;

/*
we will keep this api around. what if we need to drop and recreate kpi in some case?
*/
procedure drop_kpi_objects_for_dim(p_dim_name varchar2,p_affected_kpi in out nocopy dbms_sql.varchar2_table) is
--
l_kpi_list dbms_sql.varchar2_table;
--
Begin
  --get_kpi_for_dim gives the list of kpi already implemented in AW for this dim
  bsc_aw_md_api.get_kpi_for_dim(p_dim_name,l_kpi_list);
  bsc_aw_utility.merge_array(p_affected_kpi,l_kpi_list);
  for i in 1..l_kpi_list.count loop
    bsc_aw_adapter_kpi.drop_kpi_objects(l_kpi_list(i));
    bsc_aw_md_api.mark_kpi_recreate(l_kpi_list(i));
  end loop;
Exception when others then
  log_n('Exception in drop_kpi_objects_for_dim '||sqlerrm);
  raise;
End;

/*
have to drop in this order
1. relations and variables
2. concat dim
3. dim levels
4. others like programs
*/
procedure drop_dim(p_dim_name varchar2) is
--
l_objects bsc_aw_md_wrapper.bsc_olap_object_tb;
l_flag dbms_sql.varchar2_table;
--
Begin
  bsc_aw_md_api.get_dim_olap_objects(p_dim_name,l_objects,'all');
  for i in 1..l_objects.count loop
    if l_objects(i).olap_object_type is null then
      l_flag(i):='Y';
    else
      l_flag(i):='N';
    end if;
  end loop;
  --do not drop dim levels. with the concept of level groups, the dim levels are not blown away
  for i in 1..l_objects.count loop
    if l_objects(i).object_type='dimension level' then
      l_flag(i):='Y'; -- do not drop dim levels. they are standalone dim for snow flaks. they are shared across concat dim
    end if;
  end loop;
  for i in 1..l_objects.count loop
    if l_flag(i)='N' and (l_objects(i).olap_object_type='relation' or l_objects(i).olap_object_type='variable') then
      bsc_aw_utility.delete_aw_object(l_objects(i).object);
      l_flag(i):='Y';
    end if;
  end loop;
  for i in 1..l_objects.count loop
    if l_flag(i)='N' and l_objects(i).object_type='concat dimension' then
      bsc_aw_utility.delete_aw_object(l_objects(i).object);
      l_flag(i):='Y';
    end if;
  end loop;
  for i in 1..l_objects.count loop
    if l_flag(i)='N' and l_objects(i).object_type='dimension' then
      bsc_aw_utility.delete_aw_object(l_objects(i).object);
      l_flag(i):='Y';
    end if;
  end loop;
  for i in 1..l_objects.count loop
    if l_flag(i)='N' then
      bsc_aw_utility.delete_aw_object(l_objects(i).object);
      l_flag(i):='Y';
    end if;
  end loop;
  bsc_aw_md_api.drop_dim(p_dim_name);--this will delete all child objects in metadata
Exception when others then
  log_n('Exception in drop_dim '||sqlerrm);
  raise;
End;

/*see if any of the levels have a cc dim . if yes, drop them. for the levels, find the old cc dim,
for the ccdim, find the kpi drop the kpi structures, mark kpi for recreate, drop old cc dim
This is a specialized api. used only to drop the old cc dim for the levels
*/
procedure drop_old_dim_for_level(p_dimension dimension_r,p_affected_kpi in out nocopy dbms_sql.varchar2_table) is
--
l_dim_list dbms_sql.varchar2_table;
--
Begin
  --for single level dim, there is one level, itself
  --its best to have same structure for all dim. single level dim also have concat dimensions
  if g_debug then
    log('In drop_old_dim_for_level '||p_dimension.dim_name);
  end if;
  bsc_aw_md_api.get_ccdim_for_levels(p_dimension,l_dim_list);
  if g_debug then
    for i in 1..l_dim_list.count loop
      log('Old CC Dim to be dropped are '||l_dim_list(i));
    end loop;
  end if;
  for i in 1..l_dim_list.count loop
    drop_kpi_objects_for_dim(l_dim_list(i),p_affected_kpi);
    drop_dim(l_dim_list(i));
  end loop;
Exception when others then
  log_n('Exception in drop_old_dim_for_level '||sqlerrm);
  raise;
End;

/*
to create a dim
create the level dim
if level count> 1
  create the cc dim
  create the dim with the level names
  create relation
endif
create initial load program
create inc refresh program
*/
procedure create_dim_objects(p_dimension in out nocopy dimension_r) is
Begin
  bsc_aw_utility.add_sqlerror(-34340,'ignore',null);
  bsc_aw_utility.add_sqlerror(-36656,'ignore',null);
  --all info to create a dim should be in p_dimension
  create_dim_for_levels(p_dimension);
  --if there is only 1 level and this level=dim name then we dont create cc dim or relations
  --this is true for TYPE and PROJECTION dim
  if not(p_dimension.level_groups(1).levels.count=1 and p_dimension.level_groups(1).levels(1).level_name=p_dimension.dim_name) then
    create_ccdim(p_dimension);
    create_level_name_dim(p_dimension);
    create_relation(p_dimension);
  end if;
  create_dim_program(p_dimension);
  --bug fix 5636695
  -- calling this api here will fill the correct values in property attribute
  -- including level name dim
  set_dim_properties(p_dimension);
  bsc_aw_md_api.create_dim_objects(p_dimension);
  bsc_aw_utility.remove_sqlerror(-34340,'ignore');
  bsc_aw_utility.remove_sqlerror(-36656,'ignore');
Exception when others then
  log_n('Exception in create_dim_objects '||sqlerrm);
  raise;
End;

/*
create dim
create filter and limit bool variables
create the first value "0"
*/
procedure create_dim_for_levels(p_dimension in out nocopy dimension_r) is
--
l_dim_data_type varchar2(100);
--
Begin
  for i in 1..p_dimension.level_groups(1).levels.count loop
    --in the prototype in gsitst, we found that dim must be text always for performance
    --dim datatype is always text. we ran perf prototype and found that with text, we have the
    --best aggregation perf
    l_dim_data_type:='TEXT';
    g_stmt:='dfn '||p_dimension.level_groups(1).levels(i).level_name||' dimension '||l_dim_data_type;
    bsc_aw_dbms_aw.execute(g_stmt);
    p_dimension.level_groups(1).levels(i).filter_variable:=p_dimension.level_groups(1).levels(i).level_name||'.filter.bool';
    p_dimension.level_groups(1).levels(i).limit_variable:=p_dimension.level_groups(1).levels(i).level_name||'.LB';
    g_stmt:='dfn '||p_dimension.level_groups(1).levels(i).filter_variable||' variable boolean <'||
    p_dimension.level_groups(1).levels(i).level_name||'>';
    bsc_aw_dbms_aw.execute(g_stmt);
    g_stmt:='dfn '||p_dimension.level_groups(1).levels(i).limit_variable||' variable boolean <'||
    p_dimension.level_groups(1).levels(i).level_name||'>';
    bsc_aw_dbms_aw.execute(g_stmt);
    --if std dim, do not add 0
    if p_dimension.dim_type<>'std' then
      g_stmt:='maintain '||p_dimension.level_groups(1).levels(i).level_name||' merge ''0''';
      bsc_aw_dbms_aw.execute(g_stmt);
    end if;
    --see if there are seed values to enter
    --if seed value is a text, it will be entered as '''seedvalue''' . see  create_projection_dim
    for j in 1..p_dimension.level_groups(1).levels(i).seed_values.count loop
      g_stmt:='maintain '||p_dimension.level_groups(1).levels(i).level_name||' merge '||p_dimension.level_groups(1).levels(i).seed_values(j);
      bsc_aw_dbms_aw.execute(g_stmt);
    end loop;
  end loop;
  --for the recursive levels
  for i in 1..p_dimension.level_groups(1).rec_levels.count loop
    g_stmt:='dfn '||p_dimension.level_groups(1).rec_levels(i).level_name||' dimension '||l_dim_data_type;
    bsc_aw_dbms_aw.execute(g_stmt);
  end loop;
Exception when others then
  log_n('Exception in create_dim_for_levels '||sqlerrm);
  raise;
End;

procedure create_ccdim(p_dimension in out nocopy dimension_r) is
l_levels dbms_sql.varchar2_table;
Begin
  g_stmt:='dfn '||p_dimension.dim_name||' dimension concat(';
  --normal levels
  for i in 1..p_dimension.level_groups(1).levels.count loop
    g_stmt:=g_stmt||p_dimension.level_groups(1).levels(i).level_name||',';
    l_levels(l_levels.count+1):=p_dimension.level_groups(1).levels(i).level_name;
  end loop;
  --rec levels
  for i in 1..p_dimension.level_groups(1).rec_levels.count loop
    g_stmt:=g_stmt||p_dimension.level_groups(1).rec_levels(i).level_name||',';
    l_levels(l_levels.count+1):=p_dimension.level_groups(1).rec_levels(i).level_name;
  end loop;
  g_stmt:=substr(g_stmt,1,length(g_stmt)-1);
  g_stmt:=g_stmt||')';
  bsc_aw_dbms_aw.execute(g_stmt);
  --add the levels. this is reqd when dim merge happens
  for i in 1..l_levels.count loop
    g_stmt:='CHGDFN '||p_dimension.dim_name||' base add '||l_levels(i);
    bsc_aw_dbms_aw.execute(g_stmt); --we have added ORA-36656 to ignore list
  end loop;
  p_dimension.filter_variable:=p_dimension.dim_name||'.filter.bool';
  p_dimension.limit_variable:=p_dimension.dim_name||'.LB';
  p_dimension.base_value_cube:=p_dimension.dim_name||'.BV';
  g_stmt:='dfn '||p_dimension.filter_variable||' variable boolean <'||p_dimension.dim_name||'>';
  bsc_aw_dbms_aw.execute(g_stmt);
  g_stmt:='dfn '||p_dimension.limit_variable||' variable boolean <'||p_dimension.dim_name||'>';
  bsc_aw_dbms_aw.execute(g_stmt);
  g_stmt:='dfn '||p_dimension.base_value_cube||' variable TEXT <'||p_dimension.dim_name||'>';
  bsc_aw_dbms_aw.execute(g_stmt);
Exception when others then
  log_n('Exception in create_ccdim '||sqlerrm);
  raise;
End;

/*
when creating the level names, for zero code, we add the names of each zero code level
instead of just one "ZERO". the reason is that we may have more than 1 zero code level and
we may wish to aggregate on only one of them

Rec dim have 2 imp. denorm imp and norm imp
for denorm imp:
for rec dim, the level name dim will contain the values of  the dim
if we look at the relation, the X axis is cc dim values.
the Y axis is the individual level values, ex: employee

for norm imp:
we have the relation which stores the self relation and norm relation
      a
   b      c
 d  e
 is represented as
rel:  A  B  C  D   E    A  A  B  B
dim:  a  b  c  d   e    B  C  D  E
we have one more axis in normal hier of rec dim. this axis contains level_name_dim and has values '1', '2' etc
depending on how many parents a child has. this extra dim is to take care of cases when a child can have multiple parents
if in a dim, the max parents a child has is 3, level_name_dim contains '1', '2' and '3'
for non rec dim, the Y axis is the name of the level
*/
procedure create_level_name_dim(p_dimension in out nocopy dimension_r) is
Begin
  p_dimension.level_name_dim:=p_dimension.dim_name||'.levels';
  g_stmt:='dfn '||p_dimension.level_name_dim||' dimension text';
  bsc_aw_dbms_aw.execute(g_stmt);
  if p_dimension.recursive='Y' then
    if p_dimension.recursive_norm_hier='N' then
      --we create the cube that is used to store the position of the level values
      --larry will have 1, john wookey 2 etc. before agg we do limit .levels to .levels.position LE adv_sum_profile
      --this name .position is assumes in bsc_aw_load_kpi.limit_dim_levels
      p_dimension.rec_level_position_cube:=p_dimension.dim_name||'.levels.position';
      g_stmt:='dfn '||p_dimension.rec_level_position_cube||' number<'||p_dimension.level_name_dim||'>';
      bsc_aw_dbms_aw.execute(g_stmt);
    else
      g_stmt:='maintain '||p_dimension.level_name_dim||' merge ''1'''; --default
      bsc_aw_dbms_aw.execute(g_stmt);
    end if;
  else
    for i in 1..p_dimension.level_groups(1).parent_child.count loop
      if p_dimension.level_groups(1).parent_child(i).parent_level is not null
      and p_dimension.level_groups(1).parent_child(i).child_level is not null then
        g_stmt:='maintain '||p_dimension.level_name_dim||' merge '''||p_dimension.level_groups(1).parent_child(i).parent_level||'.'||
        p_dimension.level_groups(1).parent_child(i).child_level||'''';
        bsc_aw_dbms_aw.execute(g_stmt);
      end if;
    end loop;
    --zero code
    for i in 1..p_dimension.level_groups(1).zero_levels.count loop
      g_stmt:='maintain '||p_dimension.level_name_dim||' merge '''||p_dimension.level_groups(1).zero_levels(i).level_name||'.'||
      p_dimension.level_groups(1).zero_levels(i).child_level_name||'''';
      bsc_aw_dbms_aw.execute(g_stmt);
    end loop;
  end if;
  --create level name dim for each level
  if p_dimension.dim_type <> 'std' then
    for i in 1..p_dimension.level_groups(1).levels.count loop
      p_dimension.level_groups(1).levels(i).level_name_dim:=p_dimension.level_groups(1).levels(i).level_name||'.levels';
      g_stmt:='dfn '||p_dimension.level_groups(1).levels(i).level_name_dim||' dimension text';
      bsc_aw_dbms_aw.execute(g_stmt);
      g_stmt:='maintain '||p_dimension.level_groups(1).levels(i).level_name_dim||' merge '''||
      get_zero_level(p_dimension,p_dimension.level_groups(1).levels(i).level_name).level_name||'.'||
      p_dimension.level_groups(1).levels(i).level_name||'''';
      bsc_aw_dbms_aw.execute(g_stmt);
    end loop;
  end if;
  --
Exception when others then
  log_n('Exception in create_level_name_dim '||sqlerrm);
  raise;
End;

/*for normal rec hier, level name dim contains ''1'' ''2'' etc. for denorm, its the level values themselves
*/
procedure create_relation(p_dimension in out nocopy dimension_r) is
Begin
  g_stmt:='dfn '||p_dimension.relation_name||' relation '||p_dimension.dim_name||'<'||p_dimension.dim_name||' '||p_dimension.level_name_dim||'>';
  bsc_aw_dbms_aw.execute(g_stmt);
  --create each level's relation
  if p_dimension.dim_type <> 'std' then
    for i in 1..p_dimension.level_groups(1).levels.count loop
      p_dimension.level_groups(1).levels(i).relation_name:=p_dimension.level_groups(1).levels(i).level_name||'.rel';
      g_stmt:='dfn '||p_dimension.level_groups(1).levels(i).relation_name||' relation '||p_dimension.level_groups(1).levels(i).level_name||'<'||
      p_dimension.level_groups(1).levels(i).level_name||' '||p_dimension.level_groups(1).levels(i).level_name_dim||'>';
      bsc_aw_dbms_aw.execute(g_stmt);
    end loop;
  end if;
Exception when others then
  log_n('Exception in create_relation '||sqlerrm);
  raise;
End;

procedure create_dim_program(p_dimension dimension_r) is
Begin
  --recursive dim do not have initial and inc programs. they only have initial program. the delta data is
  --prepared in bsc loader in temp tables.
  if p_dimension.recursive='Y' then
    if p_dimension.recursive_norm_hier='N' then --denorm implementation
      create_dim_program_rec(p_dimension,'initial');
    else --norm hier normalization
      create_dim_program_rec_norm(p_dimension,'initial');
    end if;
  else
    create_dim_program(p_dimension,'initial');
    create_dim_program(p_dimension,'inc');
  end if;
Exception when others then
  log_n('Exception in create_dim_program '||sqlerrm);
  raise;
End;

/*
This api is only called for NON rec dims
*/
procedure create_dim_program(p_dimension dimension_r,p_mode varchar2) is
--
l_pgm varchar2(300);
--
Begin
  --when this api is called, there must not be a program in the workspace
  g_commands.delete;
  if p_mode='initial' then
    l_pgm:=p_dimension.initial_load_program;
  else
    l_pgm:=p_dimension.inc_load_program;
  end if;
  if l_pgm is not null then
    bsc_aw_utility.add_g_commands(g_commands,'dfn '||l_pgm||' program');
    bsc_aw_utility.add_g_commands(g_commands,'allstat');
    bsc_aw_utility.add_g_commands(g_commands,p_dimension.dim_name||'.LB=false');
    for i in 1..p_dimension.level_groups.count loop
      create_dim_program(p_dimension,p_dimension.level_groups(i),p_mode);
    end loop;
    --base value
    --base value cubes will be used in the olap table functions for the kpi
    if p_dimension.base_value_cube is not null then
      bsc_aw_utility.add_g_commands(g_commands,p_dimension.base_value_cube||'=baseval('||p_dimension.dim_name||')');
    end if;
    --
    bsc_aw_utility.exec_program_commands(l_pgm,g_commands);
  end if;
Exception when others then
  log_n('Exception in create_dim_program '||sqlerrm);
  raise;
End;

procedure create_dim_program(p_dimension dimension_r,p_level_group level_group_r,p_mode varchar2) is
--
l_levels levels_tb;
l_parent_child dim_parent_child_tb;
l_zero_levels zero_levels_tb;
l_snowflake_levels levels_tb;
Begin
  --if p_level_group.data_source.data_source is not null, then p_level_group.data_source.inc_data_source is also not null
  if p_level_group.data_source.data_source is not null then
    bsc_aw_utility.add_g_commands(g_commands,'sql declare c1 cursor for select --');
    --this is where we cannot assume that the data source has the same name as the levels.
    --this is for DBI dimensions (non rec)
    --we will assume that in data_source.pk_col the order is an exact match to p_level_group.levels
    l_levels.delete;
    l_parent_child.delete;
    l_zero_levels.delete;
    l_snowflake_levels.delete;
    --
    l_levels:=p_level_group.levels;
    if p_dimension.dim_type <> 'std' then
      l_snowflake_levels:=p_level_group.levels;
    end if;
    l_zero_levels:=p_level_group.zero_levels;
    for i in 1..p_level_group.parent_child.count loop
      if p_level_group.parent_child(i).parent_level is not null and p_level_group.parent_child(i).child_level is not null then
        l_parent_child(l_parent_child.count+1):=p_level_group.parent_child(i);
      end if;
    end loop;
    for i in 1..p_level_group.data_source.pk_col.count loop
      bsc_aw_utility.add_g_commands(g_commands,p_level_group.data_source.pk_col(i)||', --');
    end loop;
    bsc_aw_utility.trim_g_commands(g_commands,4,' --');
    bsc_aw_utility.add_g_commands(g_commands,'from --');
    if p_mode='initial' then
      bsc_aw_utility.add_g_commands(g_commands,p_level_group.data_source.data_source);
    else
      bsc_aw_utility.add_g_commands(g_commands,p_level_group.data_source.inc_data_source);
    end if;
    --there is no where clause. the where clause is in the data_source
    create_dim_program(p_dimension,l_levels,l_parent_child,l_zero_levels,l_snowflake_levels);
  else
    --default construction of the data source. this is for bsc dimensions.
    for i in 1..p_level_group.levels.count loop
      l_levels.delete;
      l_parent_child.delete;
      l_zero_levels.delete;
      l_snowflake_levels.delete;
      --
      l_levels(l_levels.count+1):=p_level_group.levels(i);
      if p_dimension.dim_type <> 'std' then
        l_snowflake_levels(l_snowflake_levels.count+1):=p_level_group.levels(i);
      end if;
      bsc_aw_utility.add_g_commands(g_commands,'sql declare c1 cursor for select --');
      bsc_aw_utility.add_g_commands(g_commands,nvl(p_level_group.levels(i).level_name||'.'||p_level_group.levels(i).pk.pk,'CODE')||', --');
      for j in 1..p_level_group.parent_child.count loop
        if p_level_group.parent_child(j).child_level=p_level_group.levels(i).level_name and p_level_group.parent_child(j).parent_level is not null then
          l_parent_child(l_parent_child.count+1):=p_level_group.parent_child(j);
          l_levels(l_levels.count+1):=get_level(p_dimension,p_level_group.parent_child(j).parent_level);
          bsc_aw_utility.add_g_commands(g_commands,p_level_group.parent_child(j).child_level||'.'||p_level_group.parent_child(j).child_fk||', --');
        end if;
      end loop;
      bsc_aw_utility.trim_g_commands(g_commands,4,' --');
      bsc_aw_utility.add_g_commands(g_commands,'from --');
      bsc_aw_utility.add_g_commands(g_commands,p_level_group.levels(i).level_name);
      for j in 1..p_level_group.zero_levels.count loop
        if p_level_group.zero_levels(j).child_level_name=p_level_group.levels(i).level_name and p_level_group.zero_levels(j).level_name is not null then
          l_zero_levels(l_zero_levels.count+1):=p_level_group.zero_levels(j);
        end if;
      end loop;
      create_dim_program(p_dimension,l_levels,l_parent_child,l_zero_levels,l_snowflake_levels);
    end loop;
  end if;
  --setting the kpi limit cubes is now done outside the program in bsc_aw_load_dim.set_kpi_limit_variables
  --
  /*deletes for dimensions
  delete are handled in the following way
  delete table has 2 columns. dim_level and delete_value. say we have geog dim. city,state,country
  we want to delete all cities in ca and ca
  the table has
  'city'    'SF'
  'city'    'LA'
  'state'   'CA'
  for each level in the dim, we see if there are delete values. if there are we do the following
  mark limit cubes for the parent value for re-agg.
  in our case, we will mark state of ca and country of usa for re-agg
  the dim values are deleted in dim load module
  */
  --p_level_group.levels(i).level_name
  bsc_aw_utility.add_g_commands(g_commands,'allstat');
  if p_level_group.levels.count>1 then
    for i in 1..p_level_group.levels.count loop
      --we only need these for levels that have parents.
      if level_has_parents(p_level_group.parent_child,p_level_group.levels(i).level_name) then
        bsc_aw_utility.add_g_commands(g_commands,'sql declare c1 cursor for select delete_value from bsc_aw_dim_delete '||
        ' where dim_level=\'''||p_level_group.levels(i).level_name||'\''');
        bsc_aw_utility.add_g_commands(g_commands,'sql open c1');
        bsc_aw_utility.add_g_commands(g_commands,'sql fetch c1 loop into --');
        /*5064802. we need to handle the case where the dim value in bsc_aw_dim_delete does not exist in aw dim. go on append mode. then
        dim loader delete will delete them */
        bsc_aw_utility.add_g_commands(g_commands,':append '||p_level_group.levels(i).level_name||' --');
        bsc_aw_utility.add_g_commands(g_commands,'then --');
        for j in 1..p_level_group.parent_child.count loop
          if p_level_group.parent_child(j).child_level=p_level_group.levels(i).level_name
          and p_level_group.parent_child(j).parent_level is not null then
            bsc_aw_utility.add_g_commands(g_commands,p_dimension.dim_name||'.LB('||p_dimension.dim_name||' '||
            p_dimension.relation_name||'('||p_dimension.dim_name||' '||p_level_group.parent_child(j).child_level||' '||
            p_dimension.level_name_dim||' \'''||p_level_group.parent_child(j).parent_level||'.'||
            p_level_group.parent_child(j).child_level||
            '\''))=TRUE --');
            --setting of kpi limit cubes is done in bsc_aw_load_dim.set_kpi_limit_variables
          end if;
        end loop;
        bsc_aw_utility.trim_g_commands(g_commands,3,null);
        bsc_aw_utility.add_g_commands(g_commands,'sql close c1');
        bsc_aw_utility.add_g_commands(g_commands,'sql cleanup');
      end if;
    end loop;
  end if;
Exception when others then
  log_n('Exception in create_dim_program '||sqlerrm);
  raise;
End;

procedure create_dim_program(
p_dimension dimension_r,
p_levels levels_tb,
p_parent_child dim_parent_child_tb,
p_zero_levels zero_levels_tb,
p_snowflake_levels levels_tb
) is
Begin
  bsc_aw_utility.add_g_commands(g_commands,'sql open c1');
  bsc_aw_utility.add_g_commands(g_commands,'sql fetch c1 loop into --');
  for i in 1..p_levels.count loop
    bsc_aw_utility.add_g_commands(g_commands,':append '||p_levels(i).level_name||' --');
  end loop;
  /*
  initial hier was A>- B>- C, it changed to A>- C
  in this case, we need to reaggregate for A and B
  the bottom relation part is true for BSC as well as a non rec dbi dim
  there was a bug here. we were marking A and B. this will reagg for A and C correctly, but not for B. we had to mark the
  children for B, only then data is aggregated for B correctly. the way around this is to mark the parents only. B and C.
  after we load the dim, we setthe kpi limit cubes. there, we today to limit dim to dim.LB, then for all the kpi limit cubes
  set kpi.LB=true. instead, we will have limit dim to dim.LB, then limit dim to children using dim.rel, then we set the kpi
  limit cubes
  */
  if p_parent_child.count>0 or p_zero_levels.count>0 or p_snowflake_levels.count>0 then
    bsc_aw_utility.add_g_commands(g_commands,'then --');
    --see if the relations have any change
    for i in 1..p_parent_child.count loop
      if p_parent_child(i).parent_level is not null then
        bsc_aw_utility.add_g_commands(g_commands,'if '||p_dimension.relation_name||'('||p_dimension.dim_name||' '||p_parent_child(i).child_level||' '||
        p_dimension.level_name_dim||' \'''||p_parent_child(i).parent_level||'.'||p_parent_child(i).child_level||'\'') ne NA --');
        bsc_aw_utility.add_g_commands(g_commands,'AND '||p_dimension.relation_name||'('||p_dimension.dim_name||' '||p_parent_child(i).child_level||' '||
        p_dimension.level_name_dim||' \'''||p_parent_child(i).parent_level||'.'||p_parent_child(i).child_level||
        '\'') ne '||p_dimension.dim_name||'('||
        p_parent_child(i).parent_level||' '||p_parent_child(i).parent_level||') --');
        bsc_aw_utility.add_g_commands(g_commands,'then do --');
        bsc_aw_utility.add_g_commands(g_commands,p_dimension.dim_name||'.LB('||p_dimension.dim_name||' '||p_dimension.relation_name||'('||
        p_dimension.dim_name||' '||p_parent_child(i).child_level||' '||p_dimension.level_name_dim||' \'''||
        p_parent_child(i).parent_level||'.'||p_parent_child(i).child_level||'\''))=TRUE --');
        --bug fix.initially, it was p_parent_child(i).child_level||')=TRUE --');
        bsc_aw_utility.add_g_commands(g_commands,p_dimension.dim_name||'.LB('||p_dimension.dim_name||' '||p_parent_child(i).parent_level||')=TRUE --');
        bsc_aw_utility.add_g_commands(g_commands,'doend --');
      end if;
    end loop;
    --now, assign the new values to the rel
    for i in 1..p_parent_child.count loop
      if p_parent_child(i).parent_level is not null then
        bsc_aw_utility.add_g_commands(g_commands,p_dimension.relation_name||'('||p_dimension.dim_name||' '||p_parent_child(i).child_level||' '||
        p_dimension.level_name_dim||' \'''||p_parent_child(i).parent_level||'.'||p_parent_child(i).child_level||
        '\'')='||p_dimension.dim_name||'('||
        p_parent_child(i).parent_level||' '||p_parent_child(i).parent_level||') --');
      end if;
    end loop;
    --add the relations for zero code
    if p_zero_levels.count>0 then
      for i in 1..p_zero_levels.count loop
        --we have to make sure we eliminate circular relation. all the levels contain one row that is the zero row. for example city's 0
        --rolls to state 0 which rolls to country 0. we need to make sure that 0 is not the parent of zero
        /* error looks like this:
        ORA-36036: (XSMHIERCK01) One or more loops have been detected in relationship BSC_AW!BSC_CCDIM_100_101_102_103.REL over
        BSC_AW!BSC_CCDIM_100_101_102_103. The 1 items involved are <BSC_D_PRODUCT_FAMILY_AW: 0>.
        */
        bsc_aw_utility.add_g_commands(g_commands,'if '||p_zero_levels(i).child_level_name||' NE \''0\'' --');
        bsc_aw_utility.add_g_commands(g_commands,'then do --');
        bsc_aw_utility.add_g_commands(g_commands,p_dimension.relation_name||'('||p_dimension.dim_name||' '||p_zero_levels(i).child_level_name||' '||
        p_dimension.level_name_dim||' \'''||p_zero_levels(i).level_name||'.'||p_zero_levels(i).child_level_name||
        '\'')='||p_dimension.dim_name||'('||
        p_zero_levels(i).child_level_name||' \''0\'') --');
        bsc_aw_utility.add_g_commands(g_commands,'doend --');
      end loop;
    end if;
    --snowflake relation. we need to populate the levels's relation that maps the levels to the zero code
    --in the future we may need to see if we need to create relations with other levels
    --but zero code will still be there.
    for i in 1..p_snowflake_levels.count loop
      if p_snowflake_levels(i).relation_name is not null then
        bsc_aw_utility.add_g_commands(g_commands,'if '||p_snowflake_levels(i).level_name||' NE \''0\'' --');
        bsc_aw_utility.add_g_commands(g_commands,'then do --');
        bsc_aw_utility.add_g_commands(g_commands,p_snowflake_levels(i).relation_name||'('||p_snowflake_levels(i).level_name_dim||
        ' \'''||get_zero_level(p_dimension,p_snowflake_levels(i).level_name).level_name||'.'||p_snowflake_levels(i).level_name||'\'')='||
        p_snowflake_levels(i).level_name||'('||p_snowflake_levels(i).level_name||' \''0\'') --');
        bsc_aw_utility.add_g_commands(g_commands,'doend --');
      end if;
    end loop;
  end if;
  bsc_aw_utility.trim_g_commands(g_commands,3,null);
  bsc_aw_utility.add_g_commands(g_commands,'sql close c1');
  bsc_aw_utility.add_g_commands(g_commands,'sql cleanup');
Exception when others then
  log_n('Exception in create_dim_program '||sqlerrm);
  raise;
End;

function level_has_parents(
p_parent_child dim_parent_child_tb,
p_level_name varchar2) return boolean is
Begin
  for i in 1..p_parent_child.count loop
    if p_parent_child(i).child_level=p_level_name and p_parent_child(i).parent_level is not null then
      return true;
    end if;
  end loop;
  return false;
Exception when others then
  log_n('Exception in level_has_parents '||sqlerrm);
  raise;
End;

/*This api is only called for rec dims ONLY implemented in denorm way
denorm implementation possible only for dbi based rec dim
*/
procedure create_dim_program_rec(p_dimension dimension_r,p_mode varchar2) is
l_pgm varchar2(300);
Begin
  g_commands.delete;
  if p_dimension.initial_load_program is not null then
    l_pgm:=p_dimension.initial_load_program;
    bsc_aw_utility.add_g_commands(g_commands,'dfn '||l_pgm||' program');
    bsc_aw_utility.add_g_commands(g_commands,'allstat');
    bsc_aw_utility.add_g_commands(g_commands,p_dimension.dim_name||'.LB=false');
    bsc_aw_utility.add_g_commands(g_commands,'sql declare c1 cursor for select --');
    --in rec dim, there must be only ONE real level. then there is a virtual rec level
    --we select twice since we append to the real and virtual dim
    bsc_aw_utility.add_g_commands(g_commands,p_dimension.level_groups(1).data_source.pk_col(1)||' code1, --');
    bsc_aw_utility.add_g_commands(g_commands,p_dimension.level_groups(1).data_source.pk_col(1)||' code2 --');
    bsc_aw_utility.add_g_commands(g_commands,'from --');
    --for rec dim, we full refresh each time
    bsc_aw_utility.add_g_commands(g_commands,p_dimension.level_groups(1).data_source.data_source);
    bsc_aw_utility.add_g_commands(g_commands,'sql open c1');
    bsc_aw_utility.add_g_commands(g_commands,'sql fetch c1 loop into --');
    bsc_aw_utility.add_g_commands(g_commands,':append '||p_dimension.level_groups(1).levels(1).level_name||' --');
    bsc_aw_utility.add_g_commands(g_commands,':append '||p_dimension.level_groups(1).rec_levels(1).level_name||' ');
    bsc_aw_utility.add_g_commands(g_commands,'sql close c1');
    bsc_aw_utility.add_g_commands(g_commands,'sql cleanup');
    --now, the child parent relations
    --we select parent_col twice for the virtual dim and also the name dim.
    bsc_aw_utility.add_g_commands(g_commands,'sql declare c1 cursor for select --');
    bsc_aw_utility.add_g_commands(g_commands,p_dimension.level_groups(1).data_source.child_col||','||
    p_dimension.level_groups(1).data_source.parent_col||','||
    p_dimension.level_groups(1).data_source.parent_col||','||p_dimension.level_groups(1).data_source.position_col||' --');
    bsc_aw_utility.add_g_commands(g_commands,'from --');
    --relation fully refreshed each time. see notes
    --this does not mean kpi will need full agg. dim load will figure out if there is hier change
    bsc_aw_utility.add_g_commands(g_commands,p_dimension.level_groups(1).data_source.denorm_data_source);
    bsc_aw_utility.add_g_commands(g_commands,'sql open c1');
    bsc_aw_utility.add_g_commands(g_commands,'sql fetch c1 loop into --');
    bsc_aw_utility.add_g_commands(g_commands,':match '||p_dimension.level_groups(1).levels(1).level_name||' --');
    bsc_aw_utility.add_g_commands(g_commands,':match '||p_dimension.level_groups(1).rec_levels(1).level_name||' --');
    bsc_aw_utility.add_g_commands(g_commands,':append '||p_dimension.level_name_dim||' --');
    bsc_aw_utility.add_g_commands(g_commands,':'||p_dimension.rec_level_position_cube||' --');
    bsc_aw_utility.add_g_commands(g_commands,'then '||p_dimension.relation_name||'('||p_dimension.dim_name||' '||
    p_dimension.level_groups(1).levels(1).level_name||')='||
    p_dimension.dim_name||'('||p_dimension.level_groups(1).rec_levels(1).level_name||' '||p_dimension.level_groups(1).rec_levels(1).level_name||')');
    bsc_aw_utility.add_g_commands(g_commands,'sql close c1');
    bsc_aw_utility.add_g_commands(g_commands,'sql cleanup');
    --set the value of the old relations to NA. these parent child relations no longer exist
    bsc_aw_utility.add_g_commands(g_commands,'sql declare c1 cursor for select --');
    bsc_aw_utility.add_g_commands(g_commands,p_dimension.level_groups(1).data_source.parent_col||', --');
    bsc_aw_utility.add_g_commands(g_commands,'1, --');
    bsc_aw_utility.add_g_commands(g_commands,p_dimension.level_groups(1).data_source.child_col||', --');
    bsc_aw_utility.add_g_commands(g_commands,'1, --');
    bsc_aw_utility.add_g_commands(g_commands,p_dimension.level_groups(1).data_source.parent_col||' --');
    bsc_aw_utility.add_g_commands(g_commands,'from --');
    bsc_aw_utility.add_g_commands(g_commands,p_dimension.level_groups(1).data_source.denorm_change_data_source);
    bsc_aw_utility.add_g_commands(g_commands,'sql open c1');
    bsc_aw_utility.add_g_commands(g_commands,'sql fetch c1 loop into --');
    bsc_aw_utility.add_g_commands(g_commands,':match '||p_dimension.level_groups(1).levels(1).level_name||' --');
    bsc_aw_utility.add_g_commands(g_commands,':'||p_dimension.dim_name||'.LB('||
    p_dimension.dim_name||' '||p_dimension.level_groups(1).levels(1).level_name||') --');
    --we set kpi limit cubes in bsc_aw_load_dim.set_kpi_limit_variables
    --mark change for managers
    bsc_aw_utility.add_g_commands(g_commands,':match '||p_dimension.level_groups(1).levels(1).level_name||' --');
    bsc_aw_utility.add_g_commands(g_commands,':'||p_dimension.dim_name||'.LB('||
    p_dimension.dim_name||' '||p_dimension.level_groups(1).levels(1).level_name||') --');
    --mark change for employees
    bsc_aw_utility.add_g_commands(g_commands,':match '||p_dimension.level_name_dim||' --');
    bsc_aw_utility.add_g_commands(g_commands,'then '||p_dimension.relation_name||'('||p_dimension.dim_name||' '||
    p_dimension.level_groups(1).levels(1).level_name||')=NA ');
    --base value cubes will be used in the olap table functions for the kpi
    if p_dimension.base_value_cube is not null then
      bsc_aw_utility.add_g_commands(g_commands,p_dimension.base_value_cube||'=baseval('||p_dimension.dim_name||')');
    end if;
    bsc_aw_utility.exec_program_commands(l_pgm,g_commands);
  end if;
Exception when others then
  log_n('Exception in create_dim_program_rec '||sqlerrm);
  raise;
End;

/*if the rec dim is implemented with normal hier. this is the default implementation
*/
procedure create_dim_program_rec_norm(p_dimension dimension_r,p_mode varchar2) is
l_pgm varchar2(300);
Begin
  --if the temp variable does not exist, create it.
  bsc_aw_dbms_aw.execute_ne('dfn temp_text text');
  g_commands.delete;
  if p_dimension.initial_load_program is not null then
    l_pgm:=p_dimension.initial_load_program;
    bsc_aw_utility.add_g_commands(g_commands,'dfn '||l_pgm||' program');
    bsc_aw_utility.add_g_commands(g_commands,'allstat');
    bsc_aw_utility.add_g_commands(g_commands,p_dimension.dim_name||'.LB=false');
    bsc_aw_utility.add_g_commands(g_commands,'sql declare c1 cursor for select --');
    --in rec dim, there must be only ONE real level. then there is a virtual rec level
    --we select twice since we append to the real and virtual dim
    if p_dimension.level_groups(1).data_source.data_source is not null then --dbi dimension
      bsc_aw_utility.add_g_commands(g_commands,p_dimension.level_groups(1).data_source.pk_col(1)||' code1, --');
      bsc_aw_utility.add_g_commands(g_commands,p_dimension.level_groups(1).data_source.pk_col(1)||' code2 --');
    else
      bsc_aw_utility.add_g_commands(g_commands,p_dimension.level_groups(1).levels(1).pk.pk||' code1, --');
      bsc_aw_utility.add_g_commands(g_commands,p_dimension.level_groups(1).levels(1).pk.pk||' code2 --');
    end if;
    bsc_aw_utility.add_g_commands(g_commands,'from --');
    --for rec dim, we full refresh each time
    if p_dimension.level_groups(1).data_source.data_source is not null then
      bsc_aw_utility.add_g_commands(g_commands,p_dimension.level_groups(1).data_source.data_source);
    else
      bsc_aw_utility.add_g_commands(g_commands,p_dimension.level_groups(1).levels(1).level_name);
    end if;
    bsc_aw_utility.add_g_commands(g_commands,'sql open c1');
    bsc_aw_utility.add_g_commands(g_commands,'sql fetch c1 loop into --');
    bsc_aw_utility.add_g_commands(g_commands,':append '||p_dimension.level_groups(1).levels(1).level_name||' --');
    bsc_aw_utility.add_g_commands(g_commands,':append '||p_dimension.level_groups(1).rec_levels(1).level_name||' --');
    bsc_aw_utility.add_g_commands(g_commands,'then --');
    bsc_aw_utility.add_g_commands(g_commands,p_dimension.relation_name||'('||
    p_dimension.dim_name||' '||p_dimension.level_groups(1).levels(1).level_name||' '||p_dimension.level_name_dim||' \''1\'')='||
    p_dimension.dim_name||'('||p_dimension.level_groups(1).rec_levels(1).level_name||' '||p_dimension.level_groups(1).rec_levels(1).level_name||')');
    bsc_aw_utility.add_g_commands(g_commands,'sql close c1');
    bsc_aw_utility.add_g_commands(g_commands,'sql cleanup');
    --now, the child parent relations
    bsc_aw_utility.add_g_commands(g_commands,'sql declare c1 cursor for select --');
    if p_dimension.level_groups(1).data_source.data_source is not null then
      bsc_aw_utility.add_g_commands(g_commands,'child,parent,to_char(id) from bsc_aw_temp_pc');
    else
      --chil fk is the parent col and parent pk is the child col
      bsc_aw_utility.add_g_commands(g_commands,p_dimension.level_groups(1).parent_child(1).parent_pk||','||
      p_dimension.level_groups(1).parent_child(1).child_fk||',to_char(rank() over(partition by '||p_dimension.level_groups(1).parent_child(1).parent_pk||' '||
      'order by '||p_dimension.level_groups(1).parent_child(1).child_fk||')) id --');
      bsc_aw_utility.add_g_commands(g_commands,'from '||p_dimension.level_groups(1).levels(1).level_name||' where '||
      p_dimension.level_groups(1).parent_child(1).child_fk||' is not null');
    end if;
    bsc_aw_utility.add_g_commands(g_commands,'sql open c1');
    bsc_aw_utility.add_g_commands(g_commands,'sql fetch c1 loop into --');
    bsc_aw_utility.add_g_commands(g_commands,':match '||p_dimension.level_groups(1).rec_levels(1).level_name||' --');
    bsc_aw_utility.add_g_commands(g_commands,':temp_text --');
    bsc_aw_utility.add_g_commands(g_commands,':append '||p_dimension.level_name_dim||' --');
    bsc_aw_utility.add_g_commands(g_commands,'then --');
    bsc_aw_utility.add_g_commands(g_commands,'if '||p_dimension.relation_name||'('||
    p_dimension.dim_name||' '||p_dimension.level_groups(1).rec_levels(1).level_name||') NE NA AND '||
    p_dimension.relation_name||'('||
    p_dimension.dim_name||' '||p_dimension.level_groups(1).rec_levels(1).level_name||') NE '||
    p_dimension.dim_name||'('||p_dimension.level_groups(1).rec_levels(1).level_name||' temp_text) --');
    bsc_aw_utility.add_g_commands(g_commands,'then do --');
    bsc_aw_utility.add_g_commands(g_commands,p_dimension.dim_name||'.LB('||p_dimension.dim_name||' '||
    p_dimension.relation_name||'('||p_dimension.dim_name||' '||p_dimension.level_groups(1).rec_levels(1).level_name||'))=TRUE --');
    bsc_aw_utility.add_g_commands(g_commands,p_dimension.dim_name||'.LB('||
    p_dimension.level_groups(1).rec_levels(1).level_name||' temp_text)=TRUE --');
    bsc_aw_utility.add_g_commands(g_commands,'doend --');
    bsc_aw_utility.add_g_commands(g_commands,p_dimension.relation_name||'('||
    p_dimension.dim_name||' '||p_dimension.level_groups(1).rec_levels(1).level_name||')='||
    p_dimension.dim_name||'('||p_dimension.level_groups(1).rec_levels(1).level_name||' temp_text)');
    bsc_aw_utility.add_g_commands(g_commands,'sql close c1');
    bsc_aw_utility.add_g_commands(g_commands,'sql cleanup');
    --handle dim delete. this is just like for normal dim
    --if there are deletes, we have to mark the parents for these values for re-agg
    --for rec, dim the delete values are loaded into bsc_aw_dim_delete with the real level name, not the virtual parent
    --level name
    bsc_aw_utility.add_g_commands(g_commands,'sql declare c1 cursor for select --');
    bsc_aw_utility.add_g_commands(g_commands,'delete_value from bsc_aw_dim_delete '||
    ' where dim_level=\'''||p_dimension.level_groups(1).levels(1).level_name||'\''');
    bsc_aw_utility.add_g_commands(g_commands,'sql open c1');
    bsc_aw_utility.add_g_commands(g_commands,'sql fetch c1 loop into --');
    bsc_aw_utility.add_g_commands(g_commands,':match '||p_dimension.level_groups(1).rec_levels(1).level_name||' --');
    bsc_aw_utility.add_g_commands(g_commands,'then --');
    bsc_aw_utility.add_g_commands(g_commands,p_dimension.dim_name||'.LB('||p_dimension.dim_name||' '||
    p_dimension.relation_name||'('||p_dimension.dim_name||' '||p_dimension.level_groups(1).rec_levels(1).level_name||'))=TRUE ');
    --base value cubes will be used in the olap table functions for the kpi
    if p_dimension.base_value_cube is not null then
      bsc_aw_utility.add_g_commands(g_commands,p_dimension.base_value_cube||'=baseval('||p_dimension.dim_name||')');
    end if;
    bsc_aw_utility.exec_program_commands(l_pgm,g_commands);
  end if;
Exception when others then
  log_n('Exception in create_dim_program_rec_norm '||sqlerrm);
  raise;
End;

procedure dmp_g_dimensions(p_dimensions dimension_tb) is
Begin
  log('----------------------');
  for i in 1..p_dimensions.count loop
    dmp_dimension(p_dimensions(i));
  end loop;
Exception when others then
  log_n('Exception in dmp_g_dimensions '||sqlerrm);
  raise;
End;

procedure dmp_dimension(p_dim dimension_r) is
Begin
  log('====');
  log('Dimension dmp');
  log('Dimension : '||p_dim.dim_name||' Rel:'||p_dim.relation_name||' rec:'||p_dim.recursive||
  ' Imp with Norm Hier:'||p_dim.recursive_norm_hier);
  log('Property: '||p_dim.property);
  for i in 1..p_dim.level_groups.count loop
    dmp_level_group(p_dim.level_groups(i));
  end loop;
  log('KPI for dim:-');
  for i in 1..p_dim.kpi_for_dim.count loop
    log(p_dim.kpi_for_dim(i).kpi);
    log('  KPI Dimsets for KPI:-');
    for j in 1..p_dim.kpi_for_dim(i).dim_set.count loop
      log('  '||p_dim.kpi_for_dim(i).dim_set(j));
    end loop;
  end loop;
  log('====');
Exception when others then
  log_n('Exception in dmp_dimension '||sqlerrm);
  raise;
End;

procedure dmp_level_group(p_level_group level_group_r) is
Begin
  log('Level group '||p_level_group.level_group_name);
  log('Levels:-');
  for i in 1..p_level_group.levels.count loop
    log(p_level_group.levels(i).level_name||' id='||p_level_group.levels(i).level_id||' position='||
    p_level_group.levels(i).position||' property='||p_level_group.levels(i).property||' pk='||
    p_level_group.levels(i).pk.pk||' datatype='||p_level_group.levels(i).pk.data_type);
  end loop;
  log('Zero Levels:-');
  for i in 1..p_level_group.zero_levels.count loop
    log(p_level_group.zero_levels(i).level_name||' child level name='||
    p_level_group.zero_levels(i).child_level_name);
  end loop;
  log('Recursive Levels:-');
  for i in 1..p_level_group.rec_levels.count loop
    log(p_level_group.rec_levels(i).level_name);
  end loop;
  log('Parent Child:-');
  for i in 1..p_level_group.parent_child.count loop
    log(p_level_group.parent_child(i).parent_level||'('||p_level_group.parent_child(i).parent_pk||') '||
    p_level_group.parent_child(i).child_level||'('||p_level_group.parent_child(i).child_fk||') '||
    p_level_group.parent_child(i).level_set);
  end loop;
  log('Data Source:-');
  for i in 1..p_level_group.data_source.dim_name.count loop
    log(p_level_group.data_source.pk_col(i)||' -> '||p_level_group.data_source.dim_name(i));
  end loop;
  log('Initial data source='||p_level_group.data_source.data_source);
  log('Inc data source='||p_level_group.data_source.inc_data_source);
  log('denorm child col='||p_level_group.data_source.child_col||', denorm parent col='||
  p_level_group.data_source.parent_col||', denorm position col='||p_level_group.data_source.position_col);
  log('Initial denorm data source='||p_level_group.data_source.denorm_data_source);
  log('Change denorm data source='||p_level_group.data_source.denorm_change_data_source);
  log('---');
Exception when others then
  log_n('Exception in dmp_level_group '||sqlerrm);
  raise;
End;

/*
this creates the std dim
TYPE
PROJECTION
these dim are part of every kpi. in the kpi adapter, each kpi is also given these 2 dimensions
*/
procedure create_std_dim(p_dimensions in out nocopy dimension_tb) is
Begin
  create_type_dim(p_dimensions);
  create_projection_dim(p_dimensions);
Exception when others then
  log_n('Exception in create_std_dim '||sqlerrm);
  raise;
End;

--creates std type dim to the data structure
procedure create_type_dim(p_dimensions in out nocopy dimension_tb) is
l_dim dimension_r;
Begin
  --bug fix 5636695
  -- we have used a new public var l_dim  here, so as to take an empty structure and fill in
  -- the issue here was we had level values and parent child values retained from the previous
  -- kpi run p_dimensions... which was causing problem
  --- this will clear the previous entries from the structure
  l_dim.dim_name:='TYPE';
  l_dim.corrected:='N';
  l_dim.concat:='N';
  l_dim.dim_type:='std';
  l_dim.relation_name:=null;--not going to be used. type is single level dim
  l_dim.recursive:='N';
  l_dim.recursive_norm_hier:='N';
  l_dim.initial_load_program:='load_type.initial';
  l_dim.inc_load_program:='load_type.inc';
  --
  l_dim.level_groups(1).levels(1).level_name:='TYPE';
  l_dim.level_groups(1).levels(1).level_id:=1;
  l_dim.level_groups(1).levels(1).position:=1;
  l_dim.level_groups(1).levels(1).property:=null;
  l_dim.level_groups(1).levels(1).pk.pk:='type';
  l_dim.level_groups(1).levels(1).pk.data_type:='text';
  --
  l_dim.level_groups(1).parent_child(1).parent_level:=null;
  l_dim.level_groups(1).parent_child(1).child_level:='TYPE';
  l_dim.level_groups(1).parent_child(1).parent_pk:=null;
  l_dim.level_groups(1).parent_child(1).child_fk:=null;
  --
  l_dim.level_groups(1).data_source.dim_name(1):='TYPE';
  l_dim.level_groups(1).data_source.pk_col(1):='data_type';
  l_dim.level_groups(1).data_source.data_source:='(select distinct data_type from bsc_sys_benchmarks_b)';
  l_dim.level_groups(1).data_source.inc_data_source:='(select distinct data_type from bsc_sys_benchmarks_b)';
  --
  p_dimensions(p_dimensions.count+1):= l_dim;
  get_kpi_for_dim(p_dimensions(p_dimensions.count));
  set_dim_properties(p_dimensions(p_dimensions.count));
Exception when others then
  log_n('Exception in create_type_dim '||sqlerrm);
  raise;
End;

--creates std projection dim to the data structure
procedure create_projection_dim(p_dimensions in out nocopy dimension_tb) is
l_dim dimension_r;
Begin
  --bug fix 5636695
  -- we have used a new public var l_dim  here, so as to take an empty structure and fill in
  -- the issue here was we had level values and parent child values retained from the previous
  -- kpi run p_dimensions... which was causing problem
  --- this will clear the previous entries from the structure
  l_dim.dim_name:='PROJECTION';
  l_dim.corrected:='N';
  l_dim.concat:='N';
  l_dim.dim_type:='std';
  l_dim.relation_name:=null;--not going to be used. type is single level dim
  l_dim.recursive:='N';
  l_dim.recursive_norm_hier:='N';
  l_dim.initial_load_program:=null;--projection dim has 2 values, Y or N
  l_dim.inc_load_program:=null;
  --
  l_dim.level_groups(1).levels(1).level_name:='PROJECTION';
  l_dim.level_groups(1).levels(1).level_id:=1;
  l_dim.level_groups(1).levels(1).position:=1;
  l_dim.level_groups(1).levels(1).seed_values(1):='''Y''';
  l_dim.level_groups(1).levels(1).seed_values(2):='''N''';
  l_dim.level_groups(1).levels(1).property:=null;
  l_dim.level_groups(1).levels(1).pk.pk:='projection';
  l_dim.level_groups(1).levels(1).pk.data_type:='text';
  --
  l_dim.level_groups(1).parent_child(1).parent_level:=null;
  l_dim.level_groups(1).parent_child(1).child_level:='PROJECTION';
  l_dim.level_groups(1).parent_child(1).parent_pk:=null;
  l_dim.level_groups(1).parent_child(1).child_fk:=null;
  --
  --projection has no data source
  --
  p_dimensions(p_dimensions.count+1):= l_dim;
  get_kpi_for_dim(p_dimensions(p_dimensions.count));
  set_dim_properties(p_dimensions(p_dimensions.count));
Exception when others then
  log_n('Exception in create_projection_dim '||sqlerrm);
  raise;
End;

procedure create_dmp_program(p_dim_level varchar2,p_name varchar2) is
Begin
  g_commands.delete;
  bsc_aw_utility.add_g_commands(g_commands,'dfn '||p_name||' program');
  bsc_aw_utility.add_g_commands(g_commands,'allstat');
  bsc_aw_utility.add_g_commands(g_commands,'sql prepare c1 from --');
  bsc_aw_utility.add_g_commands(g_commands,'insert into bsc_aw_dim_data values (\'''||p_dim_level||'\'',:'||p_dim_level||') DIRECT=YES');
  bsc_aw_utility.add_g_commands(g_commands,'for '||p_dim_level);
  bsc_aw_utility.add_g_commands(g_commands,'do');
  bsc_aw_utility.add_g_commands(g_commands,'sql execute c1');
  bsc_aw_utility.add_g_commands(g_commands,'if sqlcode ne 0');
  bsc_aw_utility.add_g_commands(g_commands,'then break');
  bsc_aw_utility.add_g_commands(g_commands,'doend');
  bsc_aw_utility.exec_program_commands(p_name,g_commands);
Exception when others then
  log_n('Exception in create_dmp_program '||sqlerrm);
  raise;
End;

function get_zero_level(p_dimension dimension_r,p_level varchar2) return zero_levels_r is
l_zero_level zero_levels_r;
Begin
  for i in 1..p_dimension.level_groups.count loop
    l_zero_level:=get_zero_level(p_dimension.level_groups(i),p_level);
    if l_zero_level.level_name is not null then
      return l_zero_level;
    end if;
  end loop;
  return null;
Exception when others then
  log_n('Exception in get_zero_level '||sqlerrm);
  raise;
End;

function get_zero_level(p_level_group level_group_r,p_level varchar2) return zero_levels_r is
Begin
  for i in 1..p_level_group.zero_levels.count loop
    if p_level_group.zero_levels(i).child_level_name=p_level then
      return p_level_group.zero_levels(i);
    end if;
  end loop;
  return null;
Exception when others then
  log_n('Exception in get_zero_level '||sqlerrm);
  raise;
End;

/*
given a dim, what are the kpi limit cubes. called in dim load
*/
procedure get_dim_kpi_limit_cubes(
p_dim varchar2,
p_limit_cubes out nocopy dbms_sql.varchar2_table,
p_aggregate_marker out nocopy dbms_sql.varchar2_table,
p_reset_cubes out nocopy dbms_sql.varchar2_table
) is
--
l_olap_object_relation bsc_aw_md_wrapper.bsc_olap_object_relation_tb;
Begin
  l_olap_object_relation.delete;
  bsc_aw_md_api.get_bsc_olap_object_relation(p_dim,'dimension',null,null,null,l_olap_object_relation);
  for i in  1..l_olap_object_relation.count loop
    --do this only if the limit cube is "actual" limit cube. not if its target limit cube
    if bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,'dim set type',',')='actual' then
      if l_olap_object_relation(i).relation_type='kpi limit cube' then
        p_limit_cubes(p_limit_cubes.count+1):=l_olap_object_relation(i).relation_object;
      elsif l_olap_object_relation(i).relation_type='kpi aggregate marker' then
        p_aggregate_marker(p_aggregate_marker.count+1):=l_olap_object_relation(i).relation_object;
      elsif l_olap_object_relation(i).relation_type='kpi reset cube' then
        p_reset_cubes(p_reset_cubes.count+1):=l_olap_object_relation(i).relation_object;
      end if;
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_dim_kpi_limit_cubes '||sqlerrm);
  raise;
End;

/*
this procedure needs to see if there are existing dim for the levels and then to see if
1. we can merge into an existing dim
2. we need to correct the existing dim
p_dim is the new image of the dim
for each level in p_dim, check to see the existing dim.
if not already processed
  see if we can merge.
  if all the old dim levels are in new dim
    if each relation of old dim is in new dim
      if old dim.number of levels<new dim.number of levels and old dim.corrected='N'
        merge
      endif
    endif
  endif
  if merge
    merge_dim(old dim, new dim)
  else
    correct dim(old dim,p_flag) p_flag is corrected or noop
  endif
endif
--
correct dim:
  invalidate any level not used by aw kpi
  invalidate any non existent relation
  if any of the above 2 happens
    create level groups
    correct level name dim / relation
    recreate program
    delete old metadata
    insert new metadata
  endif

merge:
  delete old metadata
  create dim with merge mode
    add level name dim / relation
    create new levels
    recreate program
  insert metadata
--
*/
procedure correct_old_dim(p_dim dimension_r,p_flag out nocopy varchar2) is
l_old_dim dimension_tb;
l_merge_dim dimension_tb;
l_new_dim dimension_r;
l_old_dim_list dbms_sql.varchar2_table;
l_old_dim_action dbms_sql.varchar2_table;
Begin
  if g_debug then
    log('correct_old_dim for '||p_dim.dim_name);
  end if;
  p_flag:='create all';
  l_new_dim:=p_dim;
  bsc_aw_md_api.get_ccdim_for_levels(p_dim,l_old_dim_list);
  if l_old_dim_list.count>0 then
    for i in 1..l_old_dim_list.count loop
      bsc_aw_md_api.get_dim_md(l_old_dim_list(i),l_old_dim(i));
      if g_debug then
        log('Old dim dmp');
        dmp_dimension(l_old_dim(i));
      end if;
      --
      check_old_dim_operation(l_old_dim(i),p_dim,l_old_dim_action(i));
      if l_old_dim_action(i)='drop' then
        drop_dim(l_old_dim(i).dim_name);
      elsif l_old_dim_action(i)='correct' then
        correct_dim(l_old_dim(i));--correct old dim
      end if;
    end loop;
    --see if there is no change to the dim
    for i in 1..l_old_dim_list.count loop
      if l_old_dim_action(i)='same' then
        p_flag:='noop';
        exit;
      end if;
    end loop;
    if p_flag<>'noop' then
      --see if merge needed.
      for i in 1..l_old_dim_list.count loop
        if l_old_dim_action(i)='merge' then
          l_merge_dim(l_merge_dim.count+1):=l_old_dim(i);
        end if;
      end loop;
      if l_merge_dim.count>0 then
        merge_dim(l_merge_dim,l_new_dim);--merge into the dim with the best level match. rest are corrected
        p_flag:='noop'; --for the new dim. we need no op since we have already merged new into old
      end if;
    end if;
  end if;
  if g_debug then
    log('For the new dimension '||p_dim.dim_name||', final action required is '||p_flag);
  end if;
Exception when others then
  log_n('Exception in correct_old_dim '||sqlerrm);
  raise;
End;

/*
correct old dim. this is essentially disintegrating the old dim
correction of a dim is with respect to the metadata that exists in the system, not with respect to new dim
corrections can happen on dim that had been corrected in previous runs
*/
procedure correct_dim(p_old_dim in out nocopy dimension_r) is
l_old_level_groups level_group_tb;
l_new_levels levels_tb;
l_new_zero_levels zero_levels_tb;
l_new_parent_child dim_parent_child_tb;
l_new_level_groups level_group_tb;
Begin
  if g_debug then
    log('Correct Old dim '||p_old_dim.dim_name);
  end if;
  l_old_level_groups:=p_old_dim.level_groups;
  --
  for i in 1..p_old_dim.level_groups.count loop
    correct_levels(p_old_dim.level_groups(i).levels,l_new_levels);
    p_old_dim.level_groups(i).levels:=l_new_levels;
  end loop;
  for i in 1..p_old_dim.level_groups.count loop
    correct_zero_levels(p_old_dim.level_groups(i).levels,p_old_dim.level_groups(i).zero_levels,l_new_zero_levels);
    p_old_dim.level_groups(i).zero_levels:=l_new_zero_levels;
  end loop;
  for i in 1..p_old_dim.level_groups.count loop
    correct_parent_child(p_old_dim.level_groups(i),p_old_dim.level_groups(i).parent_child,l_new_parent_child);
    p_old_dim.level_groups(i).parent_child:=l_new_parent_child;
  end loop;
  correct_level_name_dim(p_old_dim.level_name_dim,l_old_level_groups,p_old_dim.level_groups);
  correct_level_groups(p_old_dim.level_groups,l_new_level_groups);
  p_old_dim.level_groups.delete;
  for i in 1..l_new_level_groups.count loop
    p_old_dim.level_groups(p_old_dim.level_groups.count+1):=l_new_level_groups(i);
  end loop;
  --
  /*
  following steps in correction
  drop old metadata
  drop programs
  re-create programs
  */
  --set the property to corrected
  p_old_dim.corrected:='Y';
  set_dim_properties(p_old_dim);
  if g_debug then
    log('After correct levels,zero levels,parent child,level name dim and level groups');
    dmp_dimension(p_old_dim);
  end if;
  bsc_aw_md_api.drop_dim(p_old_dim.dim_name);
  create_dim_program(p_old_dim);
  bsc_aw_md_api.create_dim_objects(p_old_dim);
Exception when others then
  log_n('Exception in correct_dim '||sqlerrm);
  raise;
End;

/*
there can be multiple dim for merge. D1 with 10 levels could have split into 3,3,2,1,1
if now all 10 levels are together, the 5 new dim are candidates for merge. merge into the one with
3 levels. all others are corrected
*/
procedure merge_dim(p_old_dim in out nocopy dimension_tb,p_new_dim in out nocopy dimension_r) is
l_new_levels dbms_sql.varchar2_table;
l_number_match dbms_sql.number_table;
l_max number;
Begin
  for i in 1..p_new_dim.level_groups.count loop
    for j in 1..p_new_dim.level_groups(i).levels.count loop
      bsc_aw_utility.merge_value(l_new_levels,p_new_dim.level_groups(i).levels(j).level_name);
    end loop;
  end loop;
  --
  for i in 1..p_old_dim.count loop
    l_number_match(i):=0;
    for j in 1..p_old_dim(i).level_groups.count loop
      for k in 1..p_old_dim(i).level_groups(j).levels.count loop
        if bsc_aw_utility.in_array(l_new_levels,p_old_dim(i).level_groups(j).levels(k).level_name) then
          l_number_match(i):=l_number_match(i)+1;
        end if;
      end loop;
    end loop;
    if g_debug then
      log('For old dim '||p_old_dim(i).dim_name||', number of levels matching new dim='||l_number_match(i));
    end if;
  end loop;
  l_max:=bsc_aw_utility.get_max(l_number_match);
  for i in 1..p_old_dim.count loop
    if l_number_match(i)=l_max then
      merge_dim(p_old_dim(i),p_new_dim);
      --correct all others
      for j in 1..p_old_dim.count loop
        if i <> j then
          correct_dim(p_old_dim(j));
        end if;
      end loop;
      exit;
    end if;
  end loop;
Exception when others then
  log_n('Exception in merge_dim '||sqlerrm);
  raise;
End;

procedure merge_dim(p_old_dim dimension_r,p_new_dim in out nocopy dimension_r) is
l_new_dim_name varchar2(200);
Begin
  if g_debug then
    log('Merge dim Old dim '||p_old_dim.dim_name||', New dim '||p_new_dim.dim_name);
  end if;
  l_new_dim_name:=p_new_dim.dim_name;
  --change the names in new dim to that of the old
  p_new_dim.dim_name:=p_old_dim.dim_name;
  p_new_dim.dim_type:=p_old_dim.dim_type;
  p_new_dim.concat:=p_old_dim.concat;
  p_new_dim.property:=p_old_dim.property;
  p_new_dim.relation_name:=p_old_dim.relation_name;
  p_new_dim.level_name_dim:=p_old_dim.level_name_dim;
  p_new_dim.recursive:=p_old_dim.recursive;
  p_new_dim.recursive_norm_hier:=p_old_dim.recursive_norm_hier;
  p_new_dim.initial_load_program:=p_old_dim.initial_load_program;
  p_new_dim.inc_load_program:=p_old_dim.inc_load_program;
  p_new_dim.filter_variable:=p_old_dim.filter_variable;
  p_new_dim.limit_variable:=p_old_dim.limit_variable;
  p_new_dim.rec_level_position_cube:=p_old_dim.rec_level_position_cube;
  p_new_dim.base_value_cube:=p_old_dim.base_value_cube;
  for i in 1..p_new_dim.level_groups.count loop
    for j in 1..p_new_dim.level_groups(i).data_source.dim_name.count loop
      if p_new_dim.level_groups(i).data_source.dim_name(j)=l_new_dim_name then
        p_new_dim.level_groups(i).data_source.dim_name(j):=p_new_dim.dim_name;
      end if;
    end loop;
  end loop;
  --
  bsc_aw_md_api.drop_dim(p_old_dim.dim_name);--drop metadata
  create_dim_objects(p_new_dim);--creates objects and metadata
Exception when others then
  log_n('Exception in merge_dim '||sqlerrm);
  raise;
End;

/*
remove levels that are no more used by aw kpi
*/
procedure correct_levels(p_old_level levels_tb,p_new_level out nocopy levels_tb) is
Begin
  for i in 1..p_old_level.count loop
    if bsc_aw_bsc_metadata.is_level_used_by_aw_kpi(p_old_level(i).level_name) then
      p_new_level(p_new_level.count+1):=p_old_level(i);
    end if;
  end loop;
Exception when others then
  log_n('Exception in correct_levels '||sqlerrm);
  raise;
End;

procedure correct_zero_levels(p_new_level levels_tb,p_old_zero_level zero_levels_tb,p_new_zero_level out nocopy zero_levels_tb) is
l_levels dbms_sql.varchar2_table;
Begin
  for i in 1..p_new_level.count loop
    l_levels(l_levels.count+1):=p_new_level(i).level_name;
  end loop;
  for i in 1..p_old_zero_level.count loop
    if bsc_aw_utility.in_array(l_levels,p_old_zero_level(i).child_level_name) then
      p_new_zero_level(p_new_zero_level.count+1):=p_old_zero_level(i);
    end if;
  end loop;
Exception when others then
  log_n('Exception in correct_zero_levels '||sqlerrm);
  raise;
End;

procedure correct_parent_child(p_level_group level_group_r,p_old_pc dim_parent_child_tb,p_new_pc out nocopy dim_parent_child_tb) is
l_parents dbms_sql.varchar2_table;
l_levels dbms_sql.varchar2_table;
l_dim_levels dbms_sql.varchar2_table;
Begin
  for i in 1..p_level_group.levels.count loop
    l_dim_levels(l_dim_levels.count+1):=p_level_group.levels(i).level_name;
  end loop;
  for i in 1..p_old_pc.count loop
    if bsc_aw_utility.in_array(l_dim_levels,p_old_pc(i).child_level) then
      bsc_aw_utility.merge_value(l_levels,p_old_pc(i).child_level);
    end if;
  end loop;
  for i in 1..l_levels.count loop
    l_parents.delete;
    bsc_aw_bsc_metadata.get_parent_level(l_levels(i),l_parents); --does not return top node
    for j in 1..p_old_pc.count loop
      if p_old_pc(j).child_level=l_levels(i) then
        --if p_old_pc(j).parent_level is null and l_parents.count=0
        --and bsc_aw_utility.in_array(l_dim_levels,p_old_pc(j).parent_level) then
        if p_old_pc(j).parent_level is null then
          p_new_pc(p_new_pc.count+1):=p_old_pc(j);
        elsif l_parents.count=0 then
          p_new_pc(p_new_pc.count+1):=p_old_pc(j);
          p_new_pc(p_new_pc.count).parent_level:=null;
          p_new_pc(p_new_pc.count).parent_pk:=null;
          p_new_pc(p_new_pc.count).child_fk:=null;
        elsif bsc_aw_utility.in_array(l_parents,p_old_pc(j).parent_level)
        and bsc_aw_utility.in_array(l_dim_levels,p_old_pc(j).parent_level) then
          p_new_pc(p_new_pc.count+1):=p_old_pc(j);
        else
          --this relation is no more valid
          null;
        end if;
      end if;
    end loop;
  end loop;
Exception when others then
  log_n('Exception in correct_parent_child '||sqlerrm);
  raise;
End;

procedure correct_level_name_dim(p_level_name_dim varchar2,p_old_level_groups level_group_tb,p_new_level_groups level_group_tb) is
l_flag boolean;
Begin
  for i in 1..p_old_level_groups.count loop
    for j in 1..p_old_level_groups(i).parent_child.count loop
      l_flag:=false;
      for k in 1..p_new_level_groups.count loop
        for m in 1..p_new_level_groups(k).parent_child.count loop
          if nvl(p_old_level_groups(i).parent_child(j).child_level,'^')=nvl(p_new_level_groups(k).parent_child(m).child_level,'^')
          and nvl(p_old_level_groups(i).parent_child(j).parent_level,'^')=nvl(p_new_level_groups(k).parent_child(m).parent_level,'^') then
            l_flag:=true;
            exit;
          end if;
        end loop;
        if l_flag then
          exit;
        end if;
      end loop;
      if l_flag=false then
        if p_old_level_groups(i).parent_child(j).child_level is not null and p_old_level_groups(i).parent_child(j).parent_level is not null then
          --remove this
          bsc_aw_dbms_aw.execute('maintain '||p_level_name_dim||' delete '''||p_old_level_groups(i).parent_child(j).parent_level||'.'||
          p_old_level_groups(i).parent_child(j).child_level||'''');
        end if;
      end if;
    end loop;
    --correct zero entries
    for j in 1..p_old_level_groups(i).zero_levels.count loop
      l_flag:=false;
      for k in 1..p_new_level_groups.count loop
        for m in 1..p_new_level_groups(k).zero_levels.count loop
          if p_old_level_groups(i).zero_levels(j).level_name=p_new_level_groups(k).zero_levels(m).level_name then
            l_flag:=true;
            exit;
          end if;
        end loop;
        if l_flag then
          exit;
        end if;
      end loop;
      if l_flag=false then
        bsc_aw_dbms_aw.execute('maintain '||p_level_name_dim||' delete '''||p_old_level_groups(i).zero_levels(j).level_name||'.'||
        p_old_level_groups(i).zero_levels(j).child_level_name||'''');
      end if;
    end loop;
  end loop;
Exception when others then
  log_n('Exception in correct_level_name_dim '||sqlerrm);
  raise;
End;

/*
level groups are never going to merge. they can only break up. so the number of level groups can only rise
look at each level group. if there is break in connection, break up the level group
*/
procedure correct_level_groups(p_old_level_groups level_group_tb,p_new_level_groups out nocopy level_group_tb) is
l_max_lg number;
l_new_level_groups level_group_tb;
Begin
  l_max_lg:=0;
  for i in 1..p_old_level_groups.count loop
    l_new_level_groups.delete;
    correct_level_groups(p_old_level_groups(i),l_new_level_groups);
    for j in 1..l_new_level_groups.count loop
      l_max_lg:=l_max_lg+1;
      l_new_level_groups(j).level_group_name:='level group.'||l_max_lg;
      p_new_level_groups(p_new_level_groups.count+1):=l_new_level_groups(j);
    end loop;
  end loop;
Exception when others then
  log_n('Exception in correct_level_groups '||sqlerrm);
  raise;
End;

procedure correct_level_groups(p_old_level_group level_group_r,p_new_level_groups out nocopy level_group_tb) is
--
l_max_set number;
l_level_considered dbms_sql.varchar2_table;
l_zero_level zero_levels_r;
l_rec_level rec_levels_r;
l_old_level_group level_group_r;
Begin
  l_old_level_group:=p_old_level_group;
  for i in 1..l_old_level_group.parent_child.count loop
    l_old_level_group.parent_child(i).level_set:=null;
  end loop;
  group_levels_into_sets(l_old_level_group.parent_child);
  l_max_set:=0;
  for i in 1..l_old_level_group.parent_child.count loop
    if l_old_level_group.parent_child(i).level_set>l_max_set then
      l_max_set:=l_old_level_group.parent_child(i).level_set;
    end if;
  end loop;
  --
  if l_max_set=1 then --no level group split
    p_new_level_groups(p_new_level_groups.count+1):=l_old_level_group;
  else
    for i in 1..l_max_set loop
      p_new_level_groups(p_new_level_groups.count+1).level_group_name:=l_old_level_group.level_group_name;
      /*
      the following are determined
      levels,
      parent_child,
      zero_levels,
      rec_levels,
      the following are blindly copied.
      data_source,
      property
      */
      p_new_level_groups(p_new_level_groups.count).data_source:=l_old_level_group.data_source;
      p_new_level_groups(p_new_level_groups.count).property:=l_old_level_group.property;
      l_level_considered.delete;
      for j in 1..l_old_level_group.parent_child.count loop
        if l_old_level_group.parent_child(j).level_set=i then
          p_new_level_groups(p_new_level_groups.count).parent_child(p_new_level_groups(p_new_level_groups.count).parent_child.count+1):=
          l_old_level_group.parent_child(j);
          --
          if l_old_level_group.parent_child(j).child_level is not null
          and bsc_aw_utility.in_array(l_level_considered,l_old_level_group.parent_child(j).child_level)=false then
            p_new_level_groups(p_new_level_groups.count).levels(p_new_level_groups(p_new_level_groups.count).levels.count+1):=
            get_level(l_old_level_group,l_old_level_group.parent_child(j).child_level);
            l_zero_level:=get_zero_level(l_old_level_group,l_old_level_group.parent_child(j).child_level);
            if l_zero_level.level_name is not null then
              p_new_level_groups(p_new_level_groups.count).zero_levels(p_new_level_groups(p_new_level_groups.count).zero_levels.count+1):=
              l_zero_level;
            end if;
            l_rec_level:=get_rec_level(l_old_level_group,l_old_level_group.parent_child(j).child_level);
            if l_rec_level.level_name is not null then
              p_new_level_groups(p_new_level_groups.count).rec_levels(p_new_level_groups(p_new_level_groups.count).rec_levels.count+1):=
              l_rec_level;
            end if;
            l_level_considered(l_level_considered.count+1):=l_old_level_group.parent_child(j).child_level;
          end if;
          --
          if l_old_level_group.parent_child(j).parent_level is not null
          and bsc_aw_utility.in_array(l_level_considered,l_old_level_group.parent_child(j).parent_level)=false then
            p_new_level_groups(p_new_level_groups.count).levels(p_new_level_groups(p_new_level_groups.count).levels.count+1):=
            get_level(l_old_level_group,l_old_level_group.parent_child(j).parent_level);
            l_zero_level:=get_zero_level(l_old_level_group,l_old_level_group.parent_child(j).parent_level);
            if l_zero_level.level_name is not null then
              p_new_level_groups(p_new_level_groups.count).zero_levels(p_new_level_groups(p_new_level_groups.count).zero_levels.count+1):=
              l_zero_level;
            end if;
            l_rec_level:=get_rec_level(l_old_level_group,l_old_level_group.parent_child(j).parent_level);
            if l_rec_level.level_name is not null then
              p_new_level_groups(p_new_level_groups.count).rec_levels(p_new_level_groups(p_new_level_groups.count).rec_levels.count+1):=
              l_rec_level;
            end if;
            l_level_considered(l_level_considered.count+1):=l_old_level_group.parent_child(j).parent_level;
          end if;
        end if;
      end loop;
    end loop;
  end if;
Exception when others then
  log_n('Exception in correct_level_groups '||sqlerrm);
  raise;
End;

/*
p_flag = correct, merge, noop or same
p_flag is from the perspective of p_old_dim
*/
procedure check_old_dim_operation(p_old_dim dimension_r,p_new_dim dimension_r,p_flag out nocopy varchar2) is
l_level_list dbms_sql.varchar2_table;
l_old_level_list dbms_sql.varchar2_table;
l_level_group level_group_r;
l_pc_comparison number;
Begin
  if g_debug then
    log('check_old_dim_operation, check Old dim '||p_old_dim.dim_name||' with New dim '||p_new_dim.dim_name);
  end if;
  for i in 1..p_new_dim.level_groups.count loop
    for j in 1..p_new_dim.level_groups(i).levels.count loop
      l_level_list(l_level_list.count+1):=p_new_dim.level_groups(i).levels(j).level_name;
    end loop;
  end loop;
  for i in 1..p_old_dim.level_groups.count loop
    for j in 1..p_old_dim.level_groups(i).levels.count loop
      l_old_level_list(l_old_level_list.count+1):=p_old_dim.level_groups(i).levels(j).level_name;
    end loop;
  end loop;
  --see if the dim is un-used and can be dropped
  if p_flag is null then
    if p_old_dim.corrected='Y' and p_old_dim.kpi_for_dim.count=0 then
      p_flag:='drop';
    end if;
    if g_debug then
      if p_flag is not null then
        log('Dim '||p_old_dim.dim_name||' is already corrected and unused. Drop...');
      end if;
    end if;
  end if;
  --
  if p_flag is null then
    for i in 1..l_old_level_list.count loop
      if bsc_aw_utility.in_array(l_level_list,l_old_level_list(i))=false then -- no merge possible. correction reqd
        p_flag:='correct';
        exit;
      end if;
    end loop;
    if p_flag is not null then
      if g_debug then
        log('All levels of old not in new.p_flag='||p_flag);
      end if;
    end if;
  end if;
  --
  if p_flag is null then --check to see if all old relations exist in the new one
    for i in 1..p_old_dim.level_groups.count loop --we  check each level group
      l_level_group:=get_level_group(p_new_dim,p_old_dim.level_groups(i).levels(1).level_name);
      l_pc_comparison:=compare_pc_relations(l_level_group.parent_child,p_old_dim.level_groups(i).parent_child);
      if not(l_pc_comparison=0 or l_pc_comparison=2) then --old is NOT in new
        p_flag:='correct';
        exit;
      elsif l_pc_comparison=2 and p_old_dim.corrected='N' then
        p_flag:='merge';
      end if;
    end loop;
    if p_flag is not null then
      if g_debug then
        log('Checked old vs new level relations.p_flag='||p_flag);
      end if;
    end if;
  end if;
  if p_flag is null then
    if p_old_dim.corrected='N' then  --old and new dim are the same. no change.
      p_flag:='same';
    else
      p_flag:='noop'; --no op reqd on old dim (which is a corrected dim)
    end if;
  end if;
  if g_debug then
    log('Final flag '||p_flag);
  end if;
Exception when others then
  log_n('Exception in check_old_dim_operation '||sqlerrm);
  raise;
End;

/*
given a level, get the level group
note>>> one level can only belong to one level group
*/
function get_level_group(p_dim dimension_r,p_level varchar2) return level_group_r is
Begin
  for i in 1..p_dim.level_groups.count loop
    for j in 1..p_dim.level_groups(i).levels.count loop
      if p_dim.level_groups(i).levels(j).level_name=p_level then
        return p_dim.level_groups(i);
      end if;
    end loop;
  end loop;
  return null;
Exception when others then
  log_n('Exception in get_level_group '||sqlerrm);
  raise;
End;

/*
-1 : 2 rel diff
0 : 2 rel same
1 : 1 is in 2
2: 2 is in 1
*/
function compare_pc_relations(p_pc_1 dim_parent_child_tb,p_pc_2 dim_parent_child_tb) return number is
--
l_pc_1 bsc_aw_utility.parent_child_tb;
l_pc_2 bsc_aw_utility.parent_child_tb;
Begin
  for i in 1..p_pc_1.count loop
    l_pc_1(i).parent:=p_pc_1(i).parent_level;
    l_pc_1(i).child:=p_pc_1(i).child_level;
  end loop;
  for i in 1..p_pc_2.count loop
    l_pc_2(i).parent:=p_pc_2(i).parent_level;
    l_pc_2(i).child:=p_pc_2(i).child_level;
  end loop;
  return bsc_aw_utility.compare_pc_relations(l_pc_1,l_pc_2);
Exception when others then
  log_n('Exception in compare_pc_relations '||sqlerrm);
  raise;
End;

function get_level(p_dimension dimension_r,p_level varchar2) return levels_r is
l_level levels_r;
Begin
  for i in 1..p_dimension.level_groups.count loop
    l_level:=get_level(p_dimension.level_groups(i),p_level);
    if l_level.level_name is not null then
      return l_level;
    end if;
  end loop;
  return null;
Exception when others then
  log_n('Exception in get_level '||sqlerrm);
  raise;
End;

function get_level(p_level_group level_group_r,p_level varchar2) return levels_r is
Begin
  for i in 1..p_level_group.levels.count loop
    if p_level_group.levels(i).level_name=p_level then
      return p_level_group.levels(i);
    end if;
  end loop;
  return null;
Exception when others then
  log_n('Exception in get_level '||sqlerrm);
  raise;
End;

function get_rec_level(p_level_group level_group_r,p_level varchar2) return rec_levels_r is
Begin
  for i in 1..p_level_group.rec_levels.count loop
    if p_level_group.rec_levels(i).child_level_name=p_level then
      return p_level_group.rec_levels(i);
    end if;
  end loop;
  return null;
Exception when others then
  log_n('Exception in get_rec_level '||sqlerrm);
  raise;
End;

procedure check_dim_name_conflict(p_dimension in out nocopy dimension_r) is
l_count number;
Begin
  l_count:=0;
  loop --till we get unique name
    if l_count>bsc_aw_utility.g_infinite_loop then
      log('Infinite loop detected in check_dim_name_conflict');
      raise bsc_aw_utility.g_exception;
    end if;
    if bsc_aw_md_api.is_dim_present(p_dimension.dim_name)=false then --no name conflict
      exit;
    end if;
    l_count:=l_count+1;
    make_dim_name(p_dimension,get_dim_name_hash_string(p_dimension)||'.'||bsc_aw_utility.get_dbms_time);
  end loop;
  if g_debug then
    log('check_dim_name_conflict, final dim name '||p_dimension.dim_name);
  end if;
Exception when others then
  log_n('Exception in check_dim_name_conflict '||sqlerrm);
  raise;
End;

function get_default_lg_name return varchar2 is
Begin
  return 'level group.1';
Exception when others then
  log_n('Exception in get_default_lg_name '||sqlerrm);
  raise;
End;

function get_std_dim_list return dbms_sql.varchar2_table is
l_dim dbms_sql.varchar2_table;
Begin
  l_dim(1):='TYPE';
  l_dim(2):='PROJECTION';
  return l_dim;
Exception when others then
  log_n('Exception in get_std_dim_list '||sqlerrm);
  raise;
End;

function get_preloaded_dim_list return dbms_sql.varchar2_table is
l_dim dbms_sql.varchar2_table;
Begin
  l_dim(1):='PROJECTION';
  return l_dim;
Exception when others then
  log_n('Exception in get_preloaded_dim_list '||sqlerrm);
  raise;
End;

/*given a set of child levels and parent levels, find the hier subset that includes all of them */
function get_hier_subset(p_parent_child dim_parent_child_tb,p_parent_level dbms_sql.varchar2_table,
p_child_level dbms_sql.varchar2_table) return dim_parent_child_tb is
l_pc_subset dim_parent_child_tb;
l_pc_subset_temp dim_parent_child_tb;
Begin
  for i in 1..p_child_level.count loop
    for j in 1..p_parent_level.count loop
      l_pc_subset_temp.delete;
      l_pc_subset_temp:=get_hier_subset(p_parent_child,p_parent_level(j),p_child_level(i));
      if l_pc_subset_temp.count>0 then
        merge_hier(l_pc_subset,l_pc_subset_temp);
      end if;
    end loop;
  end loop;
  return l_pc_subset;
Exception when others then
  log_n('Exception in get_hier_subset '||sqlerrm);
  raise;
End;

/*merges the entries from p_pc_subset_merge into p_pc_subset */
procedure merge_hier(p_pc_subset in out nocopy dim_parent_child_tb,p_pc_subset_merge dim_parent_child_tb) is
l_pc_subset dim_parent_child_tb;
flag boolean;
Begin
  for i in 1..p_pc_subset_merge.count loop
    flag:=false;
    for j in 1..p_pc_subset.count loop
      if nvl(p_pc_subset(j).parent_level,'^')=nvl(p_pc_subset_merge(i).parent_level,'^')
      and nvl(p_pc_subset(j).child_level,'^')=nvl(p_pc_subset_merge(i).child_level,'^')
      and nvl(p_pc_subset(j).parent_pk,'^')=nvl(p_pc_subset_merge(i).parent_pk,'^')
      and nvl(p_pc_subset(j).child_fk,'^')=nvl(p_pc_subset_merge(i).child_fk,'^') then
        flag:=true;
        exit;
      end if;
    end loop;
    if flag=false then
      l_pc_subset(l_pc_subset.count+1):=p_pc_subset_merge(i);
    end if;
  end loop;
  for i in 1..l_pc_subset.count loop
    p_pc_subset(p_pc_subset.count+1):=l_pc_subset(i);
  end loop;
Exception when others then
  log_n('Exception in merge_hier '||sqlerrm);
  raise;
End;

/*given a parent child hier and the parent and child level, tries to create a subset hier. if child does not roll to the parent, return table
is empty. go from child to parent*/
function get_hier_subset(p_parent_child dim_parent_child_tb,p_parent_level varchar2,p_child_level varchar2) return dim_parent_child_tb is
l_pc_subset dim_parent_child_tb;
Begin
  check_parent(p_parent_child,p_child_level,p_parent_level,l_pc_subset);
  return l_pc_subset;
Exception when others then
  log_n('Exception in get_hier_subset '||sqlerrm);
  raise;
End;

procedure check_parent(
p_parent_child dim_parent_child_tb,
p_child_level varchar2,
p_check_level varchar2,
p_pc_subset out nocopy dim_parent_child_tb
) is
--
l_pc_subset dim_parent_child_tb;
Begin
  for i in 1..p_parent_child.count loop
    if p_parent_child(i).child_level=p_child_level and p_parent_child(i).parent_level is not null then
      if p_parent_child(i).parent_level=p_check_level then
        p_pc_subset(p_pc_subset.count+1):=p_parent_child(i);
        exit;
      else
        check_parent(p_parent_child,p_parent_child(i).parent_level,p_check_level,l_pc_subset);
        if l_pc_subset.count>0 then
          for j in 1..l_pc_subset.count loop
            p_pc_subset(p_pc_subset.count+1):=l_pc_subset(j);
          end loop;
          p_pc_subset(p_pc_subset.count+1):=p_parent_child(i);
          exit;
        end if;
      end if;
    end if;
  end loop;
Exception when others then
  log_n('Exception in check_parent '||sqlerrm);
  raise;
End;

procedure set_dim_recursive(p_dimension in out nocopy dimension_r) is
Begin
  bsc_aw_bsc_metadata.set_dim_recursive(p_dimension);
  if p_dimension.recursive is null or p_dimension.recursive='N' then --do one more check
    if p_dimension.level_groups(1).parent_child.count=1
    and p_dimension.level_groups(1).parent_child(1).parent_level=p_dimension.level_groups(1).parent_child(1).child_level then
      p_dimension.recursive:='Y';
      p_dimension.recursive_norm_hier:='Y';
    end if;
  end if;
  if g_debug then
    if p_dimension.recursive='Y' then
      log('Dimension '||p_dimension.dim_name||' is recursive');
    end if;
  end if;
Exception when others then
  log_n('Exception in set_dim_recursive '||sqlerrm);
  raise;
End;

/*if any level is view based, return Y*/
function check_dim_view_based(p_dim varchar2) return varchar2 is
l_oo bsc_aw_md_wrapper.bsc_olap_object_tb;
Begin
  bsc_aw_md_api.get_bsc_olap_object(null,'dimension level',p_dim,'dimension',l_oo);
  for i in 1..l_oo.count loop
    if bsc_aw_utility.get_parameter_value(l_oo(i).property1,'level source',',')='view' then
      return 'Y';
    end if;
  end loop;
  return 'N';
Exception when others then
  log_n('Exception in check_dim_view_based '||sqlerrm);
  raise;
End;

procedure upgrade(p_new_version number,p_old_version number) is
l_action bsc_aw_utility.boolean_table;
Begin
  init_all;
  if g_debug then
    log('Dim upgrade New='||p_new_version||', Old='||p_old_version||bsc_aw_utility.get_time);
  end if;
  if p_new_version>p_old_version then
    if p_old_version<2 then
      /*upgrade to handle 5064802 */
      bsc_aw_load_dim.upgrade_load_sync_all_dim;
    end if;
  end if;
Exception when others then
  log_n('Exception in upgrade '||sqlerrm);
  raise;
End;

-------------------------
procedure init_all is
Begin
  g_debug:=bsc_aw_utility.g_debug;
  null;
Exception when others then
  log_n('Exception in init_all '||sqlerrm);
  raise;
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

END BSC_AW_ADAPTER_DIM;

/
