--------------------------------------------------------
--  DDL for Package Body BSC_AW_ADAPTER_KPI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_AW_ADAPTER_KPI" AS
/*$Header: BSCAWAKB.pls 120.30 2006/05/20 02:10:19 vsurendr ship $*/

procedure create_kpi(p_kpi_list dbms_sql.varchar2_table) is
l_kpi kpi_tb;
Begin
  for i in 1..p_kpi_list.count loop
    l_kpi(i).kpi:=p_kpi_list(i);
  end loop;
  for i in 1..l_kpi.count loop
    create_kpi(l_kpi(i));
  end loop;
Exception when others then
  log_n('Exception in create_kpi '||sqlerrm);
  raise;
End;

procedure create_kpi(p_kpi in out nocopy kpi_r) is
--
Begin
  --first we need to get the dimension sets of the kpi
  --get_kpi_properties gets calendar etc
  if g_debug then
    log_n('=====================================================');
    log('KPI Adapter. Process KPI ->'||p_kpi.kpi);
  end if;
  /*
  if the kpi is already implemented as AW, we do
  1. if recreate is specified, its all cleaned up and recretaed
  2. else , return. do nothing
  */
  if check_kpi_create(p_kpi.kpi) then
    bsc_aw_bsc_metadata.get_kpi_properties(p_kpi);--gets calendar
    bsc_aw_bsc_metadata.get_kpi_dim_sets(p_kpi);
    --for each dim set, get the bsc dim levels in it. for these levels, get the cc dim
    for i in 1..p_kpi.dim_set.count loop
      get_dim_set_properties(p_kpi.kpi,p_kpi.dim_set(i)); --forecast yes or no
      get_dim_set_dims(p_kpi.kpi,p_kpi.dim_set(i));
      identify_standalone_levels(p_kpi.kpi,p_kpi.dim_set(i)); --user specifies city and country with no parent child relation
      create_missing_dim_levels(p_kpi.kpi,p_kpi.dim_set(i)); --if intermediate levels are not specified for the kpi
      get_dim_set_std_dims(p_kpi.kpi,p_kpi.dim_set(i));--type and projection dim
      get_dim_set_calendar(p_kpi,p_kpi.dim_set(i));
      --we go to bsc olap metadata to get the dim properties
      get_dim_set_dim_properties(p_kpi.kpi,p_kpi.dim_set(i)); --recursive, multi level, time or normal
      set_dim_level_positions(p_kpi.kpi,p_kpi.dim_set(i));
      set_dim_order(p_kpi.dim_set(i));
      get_dim_set_measures(p_kpi.kpi,p_kpi.dim_set(i));
    end loop;
    --get the targets at higher level info (if there are targets at higher levels)
    get_dim_set_targets(p_kpi);
    --set_dim_agg_level will set the agg level for each dim
    set_dim_agg_level(p_kpi);
    set_calendar_agg_level(p_kpi);
    --
    for i in 1..p_kpi.dim_set.count loop
      get_s_views(p_kpi.kpi,p_kpi.dim_set(i)); --gets both regular and z views
      get_dim_set_data_source(p_kpi,p_kpi.dim_set(i));
      if p_kpi.dim_set(i).targets_higher_levels='Y' then
        get_dim_set_data_source(p_kpi,p_kpi.target_dim_set(i));
      end if;
    end loop;
    /*set the DS levels. this has to be set before check_compressed_composite*/
    for i in 1..p_kpi.dim_set.count loop
      set_DS_dim_levels(p_kpi,p_kpi.dim_set(i));
      if p_kpi.dim_set(i).targets_higher_levels='Y' then
        set_DS_dim_levels(p_kpi,p_kpi.target_dim_set(i));
      end if;
    end loop;
    /*see if we can set the sql_aggregated flag for non std agg to Y. this can enable compressed composites and partitions */
    set_sql_aggregations(p_kpi,'set');
    /*first set the partition for target, only then actual. actual can be partitioned only of target can also be partitioned
    set_dimset_partition_info can change the agg_level of the dimensions if hash partitions are involved */
    for i in 1..p_kpi.dim_set.count loop
      check_compressed_composite(p_kpi.dim_set(i),p_kpi.target_dim_set(i));
      set_dimset_partition_info(p_kpi.kpi,p_kpi.dim_set(i),p_kpi.target_dim_set(i));
    end loop;
    /*if we do not have partitions, we can unset the sql_aggregation flag */
    set_sql_aggregations(p_kpi,'unset');
    --make the sql stmt etc
    for i in 1..p_kpi.dim_set.count loop
      /*set the PT info in the dimset */
      set_data_source_PT(p_kpi,p_kpi.dim_set(i));
      set_dim_set_data_source(p_kpi,p_kpi.dim_set(i));
      if p_kpi.dim_set(i).targets_higher_levels='Y' then
        set_data_source_PT(p_kpi,p_kpi.target_dim_set(i));
        set_dim_set_data_source(p_kpi,p_kpi.target_dim_set(i));
      end if;
    end loop;
    --set properties like pre-calculated dimset etc
    set_dim_set_properties(p_kpi);
    --metadata read complete.
    --create_aw_object_names gives the names to the aw objects like dim, cubes
    create_aw_object_names(p_kpi);
    make_agg_formula(p_kpi);
    if g_debug then
      dmp_kpi(p_kpi);
    end if;
    create_kpi_aw(p_kpi);--create the aw objects
    --create the kpi metadata
    bsc_aw_md_api.create_kpi(p_kpi);
  end if;
Exception when others then
  log_n('Exception in create_kpi '||sqlerrm);
  raise;
End;

/*
given a kpi object filled with all reqd metadata, this creates the aw objects.
can be used later to recreate kpi from olap metadata. we fill kpi_r and send it
to this api
we do not create the metadata here since its already there in case of recreate
*/
procedure create_kpi_aw(p_kpi in out nocopy kpi_r) is
Begin
  create_kpi_objects(p_kpi);
  create_kpi_program(p_kpi);
  create_kpi_program_parallel(p_kpi); --creates program based on partition or program based on measure
  create_kpi_view(p_kpi); --creates the S views based on olap table functions
Exception when others then
  log_n('Exception in create_kpi '||sqlerrm);
  raise;
End;

/*
see if recreate is specified. if yes, drop the kpi (if it exists)
if RECREATE is specified, aw objects are dropped
*/
function check_kpi_create(p_kpi varchar2) return boolean is
Begin
  --see if the kpi exists
  if bsc_aw_md_api.is_kpi_present(p_kpi) then
    if bsc_aw_utility.get_parameter_value(bsc_aw_utility.g_options,'RECREATE KPI')='Y' then
      drop_kpi_objects(p_kpi); --drops aw objects and olap metadata
      return true;
    else
      return false; --do not create the kpi. already present
    end if;
  else --new kpi
    return true;
  end if;
Exception when others then
  log_n('Exception in check_kpi_create '||sqlerrm);
  raise;
End;


/*
from bsc olap metadata, get the dim properties
we consider time and other dim separately. time is considered in calendars, not in dim

here we are getting level properties in 2 parts.
bsc_aw_bsc_metadata.get_dim_level_properties gets it from metadata
for rec dim, we also do bsc_aw_md_api.get_bsc_olap_object_relation to find the rec_parent_level.
this is ok since rec_parent_level is not a bsc metadata property. its specific to our implementation.
*/
procedure get_dim_set_dim_properties(p_kpi varchar2,p_dim_set in out nocopy dim_set_r) is
Begin
  for i in 1..p_dim_set.dim.count loop
    get_dim_properties(p_kpi,p_dim_set.dim(i));
  end loop;
  --need to see if we need zero code on the dim
  bsc_aw_bsc_metadata.check_dim_zero_code(p_kpi,p_dim_set);
Exception when others then
  log_n('Exception in get_dim_set_dim_properties '||sqlerrm);
  raise;
End;

procedure get_dim_properties(p_kpi varchar2,p_dim in out nocopy dim_r) is
--
l_olap_object_relation bsc_aw_md_wrapper.bsc_olap_object_relation_tb;
Begin
  bsc_aw_md_api.get_dim_properties(p_dim); --recursive, multi level, time or normal, concat?, base value cube etc
  bsc_aw_bsc_metadata.get_dim_level_properties(p_kpi,p_dim); --pk,fk,datatype for the levels and the filter
  l_olap_object_relation.delete;
  --'zero code level'  'recursive parent level'
  bsc_aw_md_api.get_bsc_olap_object_relation(null,null,null,p_dim.dim_name,'dimension',l_olap_object_relation);
  for i in 1..l_olap_object_relation.count loop
    if l_olap_object_relation(i).object_type='dimension level' and l_olap_object_relation(i).relation_type='zero code level' then
      for j in 1..p_dim.levels.count loop
        if l_olap_object_relation(i).object=p_dim.levels(j).level_name then
          p_dim.levels(j).zero_code_level:=l_olap_object_relation(i).relation_object;
          exit;
        end if;
      end loop;
    elsif l_olap_object_relation(i).object_type='dimension level' and l_olap_object_relation(i).relation_type='recursive parent level' then
      for j in 1..p_dim.levels.count loop
        if l_olap_object_relation(i).object=p_dim.levels(j).level_name then
          p_dim.levels(j).rec_parent_level:=l_olap_object_relation(i).relation_object;
          exit;
        end if;
      end loop;
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_dim_properties '||sqlerrm);
  raise;
End;

/*set the level position by reading the olap metadata
required for set_dim_agg_level
*/
procedure set_dim_level_positions(p_kpi varchar2,p_dim_set in out nocopy dim_set_r) is
Begin
  for i in 1..p_dim_set.dim.count loop
    set_dim_level_positions(p_dim_set.dim(i));
  end loop;
  --std dim
  for i in 1..p_dim_set.std_dim.count loop
    set_dim_level_positions(p_dim_set.std_dim(i));
  end loop;
Exception when others then
  log_n('Exception in set_dim_level_positions '||sqlerrm);
  raise;
End;

procedure set_dim_level_positions(p_dim in out nocopy dim_r) is
l_olap_object bsc_aw_md_wrapper.bsc_olap_object_tb;
Begin
  l_olap_object.delete;
  bsc_aw_md_api.get_bsc_olap_object(null,'dimension level',p_dim.dim_name,'dimension',l_olap_object);
  for i in 1..p_dim.levels.count loop
    --standalone dim for each dim level do not have dimension levels with them.
    p_dim.levels(i).position:=1;
    for j in 1..l_olap_object.count loop
      if p_dim.levels(i).level_name=l_olap_object(j).object then
        p_dim.levels(i).position:=bsc_aw_utility.get_parameter_value(l_olap_object(j).property1,'position',',');
        exit;
      end if;
    end loop;
  end loop;
Exception when others then
  log_n('Exception in set_dim_level_positions '||sqlerrm);
  raise;
End;

/*
given a kpi and dim set, find out the calendar and the periodicity info
calendar is at kpi level, we store it at dimset level to keep consistent with other dim
NOTE!! for calendar,we cannot assume that periodicity(1) is the lowest level
simply because there can be multiple lowest levels. so we have a flag in periodicity_r called
lowest_level
*/
procedure get_dim_set_calendar(p_kpi kpi_r,p_dim_set in out nocopy dim_set_r) is
l_pc cal_parent_child_tb;
Begin
  p_dim_set.calendar.calendar:=p_kpi.calendar;
  bsc_aw_bsc_metadata.get_dim_set_calendar(p_kpi.kpi,p_dim_set);
  --give the aw dim names
  p_dim_set.calendar.aw_dim:=bsc_aw_calendar.get_calendar_name(p_dim_set.calendar.calendar);
  --set the relation name, periodicity aw name
  bsc_aw_md_api.get_dim_set_calendar(p_kpi,p_dim_set);
  --now, get the missing periodicity, and mark lowest level
  get_missing_periodicity(p_kpi,p_dim_set);
  /*of all hier relations in the calendar, grab only those that are relevant to the dimset */
  get_relevant_cal_hier(p_dim_set.calendar.periodicity,p_dim_set.calendar.parent_child,l_pc);
  if p_dim_set.calendar.periodicity.count>1 and l_pc.count=0 then
    log('correct_relevant_cal_hier could not get the relevant cal hier');
    raise bsc_aw_utility.g_exception;
  end if;
  p_dim_set.calendar.parent_child.delete;
  for i in 1..l_pc.count loop
    p_dim_set.calendar.parent_child(i):=l_pc(i);
  end loop;
Exception when others then
  log_n('Exception in get_dim_set_calendar '||sqlerrm);
  raise;
End;

/*
given a dim set, finds out the levels in it and also finds from olap metadata
what the cc dim is. the data structure is then loaded
in get_dim_set_dims, we expect the dim levels come with the lowest levels first. this means we can assume
that the first level for any dim is the lowest level

get_dim_set_dims returns the missing levels. so if the kpi has city and country, the api will also return
state
*/
procedure get_dim_set_dims(
p_kpi varchar2,
p_dim_set in out nocopy dim_set_r) is
--
l_dim_level dbms_sql.varchar2_table;
l_mo_dim_group dbms_sql.varchar2_table; --used to see if a level is stand alone or part of parent child
l_skip_level dbms_sql.varchar2_table;
l_dim varchar2(300);
Begin
  bsc_aw_bsc_metadata.get_dim_set_dims(p_kpi,p_dim_set.dim_set,l_dim_level,l_mo_dim_group,l_skip_level);
  for i in 1..l_dim_level.count loop
    bsc_aw_md_api.get_dim_for_level(l_dim_level(i),l_dim);
    if g_debug then
      log('For level '||l_dim_level(i)||' got dim '||l_dim);
    end if;
    set_dim_and_level(p_dim_set,l_dim,l_dim_level(i),l_mo_dim_group(i),l_skip_level(i)); --level properties are set in get_dim_set_dim_properties
  end loop;
Exception when others then
  log_n('Exception in get_dim_set_dims '||sqlerrm);
  raise;
End;

/*
given a cc dim and level, see if  the cc dim exists. if not create it . if yes,
see if the level is already in. if not, add it.
*/
procedure set_dim_and_level(
p_dim_set in out nocopy dim_set_r,
p_dim varchar2,
p_level varchar2,
p_mo_dim_group varchar2,
p_skip_level varchar2
) is
Begin
  for i in 1..p_dim_set.dim.count loop
    if p_dim_set.dim(i).dim_name=p_dim then
      for j in 1..p_dim_set.dim(i).levels.count loop
        if p_dim_set.dim(i).levels(j).level_name=p_level then
          return;
        end if;
      end loop;
      --at this point, p_level was not in the levels list...so add it
      p_dim_set.dim(i).levels(p_dim_set.dim(i).levels.count+1).level_name:=p_level;
      p_dim_set.dim(i).levels(p_dim_set.dim(i).levels.count).property:='mo dim group='||p_mo_dim_group||',skip level='||
      nvl(p_skip_level,'N');
      return;
    end if;
  end loop;
  --here, p_dim was not found in the dim set. create the dim and add the level
  p_dim_set.dim(p_dim_set.dim.count+1).dim_name:=p_dim;
  p_dim_set.dim(p_dim_set.dim.count).levels(p_dim_set.dim(p_dim_set.dim.count).levels.count+1).level_name:=p_level;
  p_dim_set.dim(p_dim_set.dim.count).levels(p_dim_set.dim(p_dim_set.dim.count).levels.count).property:='mo dim group='||
  p_mo_dim_group||',skip level='||nvl(p_skip_level,'N');
Exception when others then
  log_n('Exception in set_dim_and_level '||sqlerrm);
  raise;
End;

/*
in the composite, the order of dim is
dim with no agg, no zero code
dim with no agg, zero code
dim with agg
rec dim
time
also, in the load program, we follow the same order. this api just rearranges the dim in this order
please note that time dim is handled differently in calendar in the dim set
*/
procedure set_dim_order(p_dim_set in out nocopy dim_set_r)  is
l_order dbms_sql.number_table;
l_rank number;
l_dim dim_tb;
Begin
  for i in 1..p_dim_set.dim.count loop
    l_order(i):=null;
  end loop;
  l_rank:=0;
  for i in 1..p_dim_set.dim.count loop
    log_n('prop='||p_dim_set.dim(i).property||' rec='||p_dim_set.dim(i).recursive||' count='||p_dim_set.dim(i).levels.count||' zero='||
    p_dim_set.dim(i).zero_code);
    if p_dim_set.dim(i).property='normal' and p_dim_set.dim(i).recursive='N' and p_dim_set.dim(i).levels.count=1
    and p_dim_set.dim(i).zero_code='N' then
      l_rank:=l_rank+1;
      l_order(i):=l_rank;
    end if;
  end loop;
  for i in 1..p_dim_set.dim.count loop
    if p_dim_set.dim(i).property='normal' and p_dim_set.dim(i).recursive='N' and p_dim_set.dim(i).levels.count=1
    and p_dim_set.dim(i).zero_code='Y' and l_order(i) is null then
      l_rank:=l_rank+1;
      l_order(i):=l_rank;
    end if;
  end loop;
  for i in 1..p_dim_set.dim.count loop
    if p_dim_set.dim(i).property='normal' and p_dim_set.dim(i).recursive='N' and l_order(i) is null then
      l_rank:=l_rank+1;
      l_order(i):=l_rank;
    end if;
  end loop;
  for i in 1..p_dim_set.dim.count loop
    if p_dim_set.dim(i).property='normal' and p_dim_set.dim(i).recursive='Y' and l_order(i) is null then
      l_rank:=l_rank+1;
      l_order(i):=l_rank;
    end if;
  end loop;
  --copy back in the correct order
  l_dim:=p_dim_set.dim;
  p_dim_set.dim.delete;
  for i in 1..l_rank loop
    for j in 1..l_dim.count loop
      if l_order(j)=i then
        p_dim_set.dim(p_dim_set.dim.count+1):=l_dim(j);
        exit;
      end if;
    end loop;
  end loop;
Exception when others then
  log_n('Exception in set_dim_order '||sqlerrm);
  raise;
End;

/*
get properties like
1. are there targets at higher levels
2. is there forecast
*/
procedure get_dim_set_properties(p_kpi varchar2,p_dim_set in out nocopy dim_set_r) is
Begin
  p_dim_set.dim_set_type:='actual';
Exception when others then
  log_n('Exception in get_dim_set_properties '||sqlerrm);
  raise;
End;

procedure get_dim_set_measures(p_kpi varchar2,p_dim_set in out nocopy dim_set_r) is
Begin
  bsc_aw_bsc_metadata.get_dim_set_measures(p_kpi,p_dim_set.dim_set,p_dim_set.measure);
  /*if there are BALANCE LAST VALUE measures add the .period and .year property, used in measure name dim or cubes in 9i */
  /* NOTE the period cube and year cube name change in create_PT_comp_names for 9i*/
  for i in 1..p_dim_set.measure.count loop
    if p_dim_set.measure(i).measure_type=g_balance_last_value_prop then
      bsc_aw_utility.merge_property(p_dim_set.measure(i).property,'period cube',null,p_dim_set.measure(i).measure||'.period');
      bsc_aw_utility.merge_property(p_dim_set.measure(i).property,'year cube',null,p_dim_set.measure(i).measure||'.year');
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_dim_set_measures '||sqlerrm);
  raise;
End;

/*
get the target dim and the dim levels
given the kpi and the dim set we see if there is targets at this dim set
for each dimset see if there are targets implemented
*/
procedure get_dim_set_targets(p_kpi in out nocopy kpi_r) is
Begin
  for i in 1..p_kpi.dim_set.count loop
    p_kpi.dim_set(i).targets_higher_levels:=bsc_aw_bsc_metadata.is_target_at_higher_level(p_kpi.kpi,p_kpi.dim_set(i).dim_set);
    if p_kpi.dim_set(i).targets_higher_levels='Y' then
      p_kpi.target_dim_set(i):=p_kpi.dim_set(i);--copy all dim set properties excluding s_views and data source
      --change the dimset name. append .target to it
      p_kpi.target_dim_set(i).dim_set_name:=p_kpi.target_dim_set(i).dim_set_name||'.tgt';
      p_kpi.target_dim_set(i).dim_set_type:='target';
      p_kpi.target_dim_set(i).base_dim_set:=p_kpi.dim_set(i).dim_set_name;--for actuals, base_dim_set is null
      bsc_aw_bsc_metadata.get_target_dim_levels(p_kpi.kpi,p_kpi.target_dim_set(i));
      bsc_aw_bsc_metadata.get_target_dim_periodicity(p_kpi.kpi,p_kpi.target_dim_set(i));
    else
      p_kpi.target_dim_set(i).dim_set:=null;
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_dim_set_targets '||sqlerrm);
  raise;
End;

--get both regular MV and ZMV
procedure get_s_views(p_kpi varchar2,p_dim_set in out nocopy dim_set_r) is
Begin
  bsc_aw_bsc_metadata.get_s_views(p_kpi,p_dim_set);
Exception when others then
  log_n('Exception in get_s_views '||sqlerrm);
  raise;
End;

/*
This is an imp procedure!
this procedure will create the data sources for dim sets. finds out the base tables, finds out the level
of the base tables and create the sql statements as data source

at this point in time, we assume that all dim properties have been set. for example, dim levels
filters etc. we assign data_source.dim=dim_set.dim inside bsc_aw_bsc_metadata.get_dim_set_data_source
--
each data source is at a certain periodicity. they also contain
*/
procedure get_dim_set_data_source(p_kpi kpi_r,p_dim_set in out nocopy dim_set_r) is
Begin
  --get_dim_set_data_source fills data_source and inc_data_source
  bsc_aw_bsc_metadata.get_dim_set_data_source(p_kpi.kpi,p_dim_set);
Exception when others then
  log_n('Exception in get_dim_set_data_source '||sqlerrm);
  raise;
End;

procedure set_dim_set_data_source(p_kpi kpi_r,p_dim_set in out nocopy dim_set_r) is
Begin
  /*
  get the change vector value. we look at bsc_olap_object_relation to see what change vectors are currently
  used for base tables. then we allocate the next higher number
  get_change_vector sets the change vector for initial, inc and target data sources

  we have obsoleted the old approach to inc load as mentioned above . (date today is 18 may 2005)
  we change the inc approach to not using the aw table. we will not have a bsc_b_aw table. we will have the change_vector column in the b table
  it will be indexed. every time we load the b table or process it, we will load a unique value into this column. then we will also register
  in olap metadata what the latest value is. this value is from a seq
  in olap metadaat, for b table and dimset relation, we will have
  current change vector
  current change vector is the value that this b->dimset looked at.
  current is what is in b table now.
  we will create the aw programs to accept 2 more parameters . the sql will look as
  select ...from b table where change_vector between min value and max value from a temp table
  we will insert into the temp table the min value and max value . min value is what the dim set last loaded +1
  max value is the value for change vector from the base table
  if the kpi has less keys, we will replace the aw table with in - line sql again with where change_vector between min and max
  after loading, we will do update set last change vector=current change vector
  when b table is loaded, it will call an api that will update the current change vector for this b table.
  we will not call bsc_aw_md_api.get_change_vector(p_kpi.kpi,p_dim_set) or correct_change_vector(p_kpi,p_dim_set) anymore

  issue is : what if the b table already exists with data and we are creating the kpi. in this case, what will we set
  current change vector to?
  we will set it to 0. during load time, we check the b table for max(change_vector), set the current change vector
  to that value and then continue. we want this at load time and not at optimizer time. after mo is run, someone can
  load the b table.

  at this time the following are true
  -we have the base table names in each data source
  -the levels in the base table have the level names. also pk and fk.
  -the measure in data source has measure names and formula. no other info
  -the measure record of the dim set does not have the formula info.
  to construct the data source from the base table level info, this package must get the level relation info from
  bsc olap metadata and construct the sql. it needs to go to olap metadata since the level info from the dim set
  will not contain the in-between levels from the base table to the first level in the dim set
  */
  for i in 1..p_dim_set.data_source.count loop
    create_data_source_sql(p_kpi.kpi,p_dim_set,p_dim_set.data_source(i));
  end loop;
  for i in 1..p_dim_set.inc_data_source.count loop
    create_data_source_sql(p_kpi.kpi,p_dim_set,p_dim_set.inc_data_source(i));
  end loop;
  /*
  the data source sql is mainly driven by the base table. we encountered perf issue 4549680 where we had 6 baes tables. each base table
  feeds one measure. the load went sequentially loading from each base table. this added to the time. if there are multiple data source
  and we load the dimset, we need to load all the cubes 1 shot. create new virtual data source with base tables together. this will be
  invoked when the dimset is loaded
  */
  create_dimset_data_source_sql(p_kpi.kpi,p_dim_set,p_dim_set.data_source);
  create_dimset_data_source_sql(p_kpi.kpi,p_dim_set,p_dim_set.inc_data_source);
Exception when others then
  log_n('Exception in set_dim_set_data_source '||sqlerrm);
  raise;
End;

/*
4642937 need to correct the levels of a data source. kpi can be a pre-calc kpi. this means there is B table data at upper levels also
if B table data comes at higher levels, we consider the dimset pre-calculated
data source has levels from the dimset. this means for targets, are already at higher level.
All B tables in a DS must have the same dim levels
status:correct,lower,higher,extra,skip
*/
procedure set_DS_dim_levels(p_kpi kpi_r,p_dim_set in out nocopy dim_set_r) is
Begin
  for i in 1..p_dim_set.data_source.count loop
    set_DS_dim_levels(p_kpi.kpi,p_dim_set,p_dim_set.data_source(i));
  end loop;
  for i in 1..p_dim_set.inc_data_source.count loop
    set_DS_dim_levels(p_kpi.kpi,p_dim_set,p_dim_set.inc_data_source(i));
  end loop;
Exception when others then
  log_n('Exception in set_DS_dim_levels '||sqlerrm);
  raise;
End;

procedure set_DS_dim_levels(p_kpi varchar2,p_dim_set in out nocopy dim_set_r,p_data_source in out nocopy data_source_r) is
l_base_table base_table_r;
l_dim dim_r;
l_level level_r;
l_ds_dim_set dbms_sql.varchar2_table;
Begin
  for i in 1..p_data_source.base_tables.count loop
    set_DS_dim_levels(p_kpi,p_dim_set,p_data_source,p_data_source.base_tables(i));
  end loop;
  --correct the ds dim levels. since all B tables have the same dim levels in a DS, take just the first one
  l_base_table:=p_data_source.base_tables(1);
  for i in 1..l_base_table.levels.count loop
    if l_base_table.level_status(i)='higher' then
      l_dim:=get_kpi_level_dim_r(p_dim_set,l_base_table.levels(i).level_name);
      l_level:=get_dim_level_r(l_dim,l_base_table.levels(i).level_name);
      l_ds_dim_set(l_ds_dim_set.count+1):=l_dim.dim_name;
      for j in 1..p_data_source.dim.count loop
        if p_data_source.dim(j).dim_name=l_dim.dim_name then
          p_data_source.dim(j).levels.delete;
          p_data_source.dim(j).levels(p_data_source.dim(j).levels.count+1):=l_level;
          exit;
        end if;
      end loop;
    end if;
  end loop;
  --set lower and correct keys
  for i in 1..p_data_source.dim.count loop
    if bsc_aw_utility.in_array(l_ds_dim_set,p_data_source.dim(i).dim_name)=false then
      l_level:=p_data_source.dim(i).levels(1);
      p_data_source.dim(i).levels.delete;
      p_data_source.dim(i).levels(p_data_source.dim(i).levels.count+1):=l_level;
    end if;
  end loop;
Exception when others then
  log_n('Exception in set_DS_dim_levels '||sqlerrm);
  raise;
End;

/*status:correct,lower,higher,extra,skip keys
we need from MO api as to what level B table feeds
*/
procedure set_DS_dim_levels(p_kpi varchar2,p_dim_set dim_set_r,p_data_source data_source_r,p_base_table in out nocopy base_table_r) is
l_dim dim_r;
l_oo_dim varchar2(100);
l_ds_dim_set dbms_sql.varchar2_table;
Begin
  for i in 1..p_base_table.levels.count loop
    p_base_table.level_status(i):=null;
  end loop;
  --mark correct keys
  for i in 1..p_base_table.levels.count loop
    if p_base_table.feed_levels(i)='Y' then
      l_dim:=get_kpi_level_dim_r(p_dim_set,p_base_table.levels(i).level_name);
      if l_dim.dim_name is null then --lower or higher
        bsc_aw_md_api.get_dim_for_level(p_base_table.levels(i).level_name,l_oo_dim);
        if g_debug then
          log('Level '||p_base_table.levels(i).level_name||' has no dim in this dimset '||p_dim_set.dim_set||', found dim '||
          l_oo_dim||' from oo metadata');
        end if;
        l_dim:=get_dim_given_dim_name(l_oo_dim,p_dim_set);
      end if;
      l_ds_dim_set(l_ds_dim_set.count+1):=l_dim.dim_name;
      if p_base_table.levels(i).level_name=l_dim.levels(1).level_name then
        p_base_table.level_status(i):='correct';
      else --higher or lower
        p_base_table.level_status(i):='lower';
        for j in 1..l_dim.levels.count loop
          if p_base_table.levels(i).level_name=l_dim.levels(j).level_name then --higher
            p_base_table.level_status(i):='higher';
            exit;
          end if;
        end loop;
      end if;
    end if;
  end loop;
  --now mark the extra keys as extra or skip
  for i in 1..p_base_table.levels.count loop
    if p_base_table.feed_levels(i)='N' then
      l_dim:=get_kpi_level_dim_r(p_dim_set,p_base_table.levels(i).level_name);
      if l_dim.dim_name is null then
        bsc_aw_md_api.get_dim_for_level(p_base_table.levels(i).level_name,l_oo_dim);
      else
        l_oo_dim:=l_dim.dim_name;
      end if;
      if l_oo_dim is null or bsc_aw_utility.in_array(l_ds_dim_set,l_oo_dim)=false then
        p_base_table.level_status(i):='extra';
      else
        p_base_table.level_status(i):='skip';
      end if;
    end if;
  end loop;
  if g_debug then
    log('set_DS_dim_levels dimset='||p_dim_set.dim_set||', base table='||p_base_table.base_table_name);
    for i in 1..p_base_table.levels.count loop
      log('Level '||p_base_table.levels(i).level_name||', Status '||p_base_table.level_status(i));
    end loop;
  end if;
Exception when others then
  log_n('Exception in set_DS_dim_levels '||sqlerrm);
  raise;
End;

/*
group all DS with the same dim levels and periodicity
note>>> we usually have 2 scenarios. B tables witl column merge or B tables with row merge. row merge is diff periodicities
if we have a scenario with row merge and same periodicity (i dont think this will ever happen), we can have an issue when we load
dimset vs we load B tables separately. dimset has union all and group by. so the data is added up.
this api will increase the number of p_data_source
*/
procedure create_dimset_data_source_sql(
p_kpi varchar2,
p_dim_set dim_set_r,
p_data_source in out nocopy data_source_tb
) is
--
l_distinct_levels dbms_sql.varchar2_table;
l_level_string dbms_sql.varchar2_table;
l_data_source data_source_tb;
l_new_data_source data_source_tb;
Begin
  if p_data_source.count=0 then
    return;
  end if;
  for i in 1..p_data_source.count loop
    l_level_string(i):=null;
    for j in 1..p_data_source(i).dim.count loop
      l_level_string(i):=l_level_string(i)||p_data_source(i).dim(j).levels(1).level_name||'.';
    end loop;
    for j in 1..p_data_source(i).std_dim.count loop
      l_level_string(i):=l_level_string(i)||p_data_source(i).std_dim(j).levels(1).level_name||'.';
    end loop;
    l_level_string(i):=l_level_string(i)||p_data_source(i).calendar.periodicity(1).periodicity;
    --
    bsc_aw_utility.merge_value(l_distinct_levels,l_level_string(i));
  end loop;
  if g_debug then
    log('create_dimset_data_source_sql: Distinct level combinations');
    for i in 1..l_distinct_levels.count loop
      log(l_distinct_levels(i));
    end loop;
  end if;
  for i in 1..l_distinct_levels.count loop
    l_data_source.delete;
    for j in 1..l_level_string.count loop
      if l_level_string(j)=l_distinct_levels(i) then
        l_data_source(l_data_source.count+1):=p_data_source(j);
      end if;
    end loop;
    --l_data_source has the same dim levels and periodicity
    --if we have 1 data source, we do not need to merge data source sql for performance
    if l_data_source.count>1 then
      l_new_data_source(l_new_data_source.count+1).ds_type:=l_data_source(1).ds_type||',dimset'; --initial dimset or inc dimset
      create_dimset_data_source_sql(p_kpi,p_dim_set,l_data_source,l_new_data_source(l_new_data_source.count));
    end if;
  end loop;
  --
  for i in 1..l_new_data_source.count loop
    p_data_source(p_data_source.count+1):=l_new_data_source(i);
  end loop;
Exception when others then
  log_n('Exception in create_dimset_data_source_sql '||sqlerrm);
  raise;
End;

/*
this generates sql for pulling into dimset
each DS is a unit of data. filter is inside DS. this is fine. tested perf with prototype.
*/
procedure create_dimset_data_source_sql(
p_kpi varchar2,
p_dim_set dim_set_r,
p_data_source data_source_tb,
p_new_data_source in out nocopy data_source_r
) is
--
j integer;
l_measure_index bsc_aw_utility.number_table;
l_balance_loaded_column dbms_sql.varchar2_table;
Begin
  p_new_data_source.dim:=p_data_source(1).dim;
  p_new_data_source.std_dim:=p_data_source(1).std_dim;
  p_new_data_source.calendar:=p_data_source(1).calendar;
  p_new_data_source.data_source_PT:=p_data_source(1).data_source_PT;
  /*here we make a copy of data_source_PT from the first DS of the dimset. to make a new DS with many DS in it, all the DS must share the
  same PT characteristics */
  --get the B tables
  bsc_aw_utility.init_is_new_value(1);
  for i in 1..p_data_source.count loop
    for j in 1..p_data_source(i).base_tables.count loop
      if bsc_aw_utility.is_new_value(p_data_source(i).base_tables(j).base_table_name,1) then
        p_new_data_source.base_tables(p_new_data_source.base_tables.count+1):=p_data_source(i).base_tables(j);
      end if;
    end loop;
  end loop;
  --get the measures in all the datasource
  bsc_aw_utility.init_is_new_value(1);
  for i in 1..p_data_source.count loop
    for j in 1..p_data_source(i).measure.count loop
      if bsc_aw_utility.is_new_value(p_data_source(i).measure(j).measure,1) then
        p_new_data_source.measure(p_new_data_source.measure.count+1):=
        p_data_source(i).measure(j);
      end if;
    end loop;
  end loop;
  /*merge all the properties like dimension filter or balance last value */
  for i in 1..p_data_source.count loop
    for j in 1..p_data_source(i).property.count loop
      bsc_aw_utility.merge_property(p_new_data_source.property,p_data_source(i).property(j).property_name,p_data_source(i).property(j).property_type,
      p_data_source(i).property(j).property_value);
    end loop;
  end loop;
  if g_debug then
    log('New datasource dmp');
    dmp_data_source(p_new_data_source);
  end if;
  p_new_data_source.data_source_stmt.delete;
  p_new_data_source.data_source_stmt_type.delete;
  --
  p_new_data_source.data_source_stmt(p_new_data_source.data_source_stmt.count+1):='sql declare c1 cursor for select';
  p_new_data_source.data_source_stmt_type(p_new_data_source.data_source_stmt.count):='sql select';
  for i in 1..p_new_data_source.dim.count loop
    p_new_data_source.data_source_stmt(p_new_data_source.data_source_stmt.count+1):=p_new_data_source.dim(i).levels(1).fk||',';
    p_new_data_source.data_source_stmt_type(p_new_data_source.data_source_stmt.count):='dimension='||p_new_data_source.dim(i).dim_name;
  end loop;
  for i in 1..p_dim_set.std_dim.count loop
    p_new_data_source.data_source_stmt(p_new_data_source.data_source_stmt.count+1):=p_dim_set.std_dim(i).levels(1).fk||',';
    p_new_data_source.data_source_stmt_type(p_new_data_source.data_source_stmt.count):='dimension='||p_dim_set.std_dim(i).dim_name;
  end loop;
  --time
  p_new_data_source.data_source_stmt(p_new_data_source.data_source_stmt.count+1):='period,';
  p_new_data_source.data_source_stmt_type(p_new_data_source.data_source_stmt.count):='dimension=time';
  if bsc_aw_utility.get_property(p_new_data_source.property,g_balance_last_value_prop).property_value='Y' then
    /*period.temp and year.temp */
    p_new_data_source.data_source_stmt(p_new_data_source.data_source_stmt.count+1):=g_period_temp||',';
    p_new_data_source.data_source_stmt_type(p_new_data_source.data_source_stmt.count):='temp time='||g_period_temp;
    p_new_data_source.data_source_stmt(p_new_data_source.data_source_stmt.count+1):=g_year_temp||',';
    p_new_data_source.data_source_stmt_type(p_new_data_source.data_source_stmt.count):='temp time='||g_year_temp;
  end if;
  --
  if p_dim_set.number_partitions>0 then
    p_new_data_source.data_source_stmt(p_new_data_source.data_source_stmt.count+1):=p_new_data_source.data_source_PT.partition_template.template_dim||',';
    p_new_data_source.data_source_stmt_type(p_new_data_source.data_source_stmt.count):='partition dim';
  end if;
  --measures
  for i in 1..p_new_data_source.measure.count loop
    --we need here the agg fn from the formula for the measure. its not the formula or the agg formula!
    p_new_data_source.data_source_stmt(p_new_data_source.data_source_stmt.count+1):=
    substr(p_new_data_source.measure(i).formula,1,instr(p_new_data_source.measure(i).formula,'(')-1)||'('||p_new_data_source.measure(i).measure||') '||
    p_new_data_source.measure(i).measure||',';
    p_new_data_source.data_source_stmt_type(p_new_data_source.data_source_stmt.count):='measure='||upper(p_new_data_source.measure(i).measure);
  end loop;
  /*balance loaded column */
  for i in 1..p_new_data_source.measure.count loop
    l_balance_loaded_column(i):=null;
    if p_new_data_source.measure(i).measure_type=g_balance_last_value_prop then
      l_balance_loaded_column(i):=bsc_aw_utility.get_property(p_new_data_source.measure(i).property,g_balance_loaded_column_prop).property_value;
      if l_balance_loaded_column(i) is not null then /*balance loaded column is always summed up */
        p_new_data_source.data_source_stmt(p_new_data_source.data_source_stmt.count+1):='SUM('||l_balance_loaded_column(i)||') '||
        l_balance_loaded_column(i)||',';
        p_new_data_source.data_source_stmt_type(p_new_data_source.data_source_stmt.count):='temp balance loaded column='||
        p_new_data_source.measure(i).measure;
      end if;
    end if;
  end loop;
  --the markers for the fk
  for i in 1..p_new_data_source.dim.count loop
    p_new_data_source.data_source_stmt(p_new_data_source.data_source_stmt.count+1):='1,';
    p_new_data_source.data_source_stmt_type(p_new_data_source.data_source_stmt.count):='limit cube='||p_new_data_source.dim(i).dim_name;
  end loop;
  --markers for std dim
  for i in 1..p_dim_set.std_dim.count loop
    p_new_data_source.data_source_stmt(p_new_data_source.data_source_stmt.count+1):='1,';
    p_new_data_source.data_source_stmt_type(p_new_data_source.data_source_stmt.count):='limit cube='||p_dim_set.std_dim(i).dim_name;
  end loop;
  --marker for time
  p_new_data_source.data_source_stmt(p_new_data_source.data_source_stmt.count+1):='1';
  p_new_data_source.data_source_stmt_type(p_new_data_source.data_source_stmt.count):='limit cube=time';
  p_new_data_source.data_source_stmt(p_new_data_source.data_source_stmt.count+1):='from (';
  p_new_data_source.data_source_stmt_type(p_new_data_source.data_source_stmt.count):='sql from';
  --
  --
  --now we have the sql from the data sources
  /*
  each data source has its measues. we need to place null for the other measures. each data source must only contain its measures
  and also, the DS stmt have the filter in them
  */
  for i in 1..p_data_source.count loop
    if i<>1 then
      p_new_data_source.data_source_stmt(p_new_data_source.data_source_stmt.count+1):='union all';
      p_new_data_source.data_source_stmt_type(p_new_data_source.data_source_stmt.count):='sql union all';
    end if;
    j:=1;
    loop
      if substr(p_data_source(i).data_source_stmt_type(j),1,8)='measure=' then
        --first insert nulls
        for k in 1..p_new_data_source.measure.count loop
          p_new_data_source.data_source_stmt(p_new_data_source.data_source_stmt.count+1):=
          'null '||p_new_data_source.measure(k).measure||',';
          p_new_data_source.data_source_stmt_type(p_new_data_source.data_source_stmt.count):=
          'measure='||upper(p_new_data_source.measure(k).measure);
          l_measure_index(upper(p_new_data_source.measure(k).measure)):=p_new_data_source.data_source_stmt.count;
        end loop;
        loop
          p_new_data_source.data_source_stmt(l_measure_index(substr(p_data_source(i).data_source_stmt_type(j),9))):=
          p_data_source(i).data_source_stmt(j);
          j:=j+1;
          if substr(p_data_source(i).data_source_stmt_type(j),1,8)<>'measure=' then
            exit;
          end if;
        end loop;
        l_measure_index.delete;
        /*balance loaded column temp balance loaded column=*/
        if bsc_aw_utility.get_property(p_new_data_source.property,g_balance_last_value_prop).property_value='Y' then
          for k in 1..p_new_data_source.measure.count loop
            if p_new_data_source.measure(k).measure_type=g_balance_last_value_prop and l_balance_loaded_column(k) is not null then
              p_new_data_source.data_source_stmt(p_new_data_source.data_source_stmt.count+1):=
              '0 '||l_balance_loaded_column(k)||',';
              p_new_data_source.data_source_stmt_type(p_new_data_source.data_source_stmt.count):='temp balance loaded column='||
              p_new_data_source.measure(k).measure;
              l_measure_index(p_new_data_source.measure(k).measure):=p_new_data_source.data_source_stmt.count;
            end if;
          end loop;
          loop
            if substr(p_data_source(i).data_source_stmt_type(j),1,27)<>'temp balance loaded column=' then
              exit;
            end if;
            p_new_data_source.data_source_stmt(l_measure_index(substr(p_data_source(i).data_source_stmt_type(j),28))):=
            p_data_source(i).data_source_stmt(j);
            j:=j+1;
          end loop;
        end if;
      end if;
      --
      if p_data_source(i).data_source_stmt_type(j)='sql select' and p_data_source(i).data_source_stmt(j)='sql declare c1 cursor for select' then
        p_new_data_source.data_source_stmt(p_new_data_source.data_source_stmt.count+1):='select';
        p_new_data_source.data_source_stmt_type(p_new_data_source.data_source_stmt.count):=p_data_source(i).data_source_stmt_type(j);
      elsif substr(p_data_source(i).data_source_stmt_type(j),1,11)='limit cube=' then
        null; --do not add this
      else
        if p_data_source(i).data_source_stmt_type(j)='sql from' and p_data_source(i).data_source_stmt_type(j-1)<>'sql from' then
          --if the last stmt has a trailing , remove it . this must happen only for the first <sql from>
          if substr(p_new_data_source.data_source_stmt(p_new_data_source.data_source_stmt.count),
          length(p_new_data_source.data_source_stmt(p_new_data_source.data_source_stmt.count)))=',' then
            p_new_data_source.data_source_stmt(p_new_data_source.data_source_stmt.count):=substr(
            p_new_data_source.data_source_stmt(p_new_data_source.data_source_stmt.count),1,
            length(p_new_data_source.data_source_stmt(p_new_data_source.data_source_stmt.count))-1);
          end if;
        end if;
        p_new_data_source.data_source_stmt(p_new_data_source.data_source_stmt.count+1):=p_data_source(i).data_source_stmt(j);
        p_new_data_source.data_source_stmt_type(p_new_data_source.data_source_stmt.count):=p_data_source(i).data_source_stmt_type(j);
        /*if the new data source has balance last value and the individual data source does not, we have to force adding period temp and year temp
        p_data_source(i) will not have period_temp and year_temp*/
        if p_data_source(i).data_source_stmt_type(j)='dimension=time' then
          if bsc_aw_utility.get_property(p_new_data_source.property,g_balance_last_value_prop).property_value='Y'
          and bsc_aw_utility.get_property(p_data_source(i).property,g_balance_last_value_prop).property_value is null then
            if p_data_source(i).data_source_stmt_type(j+1)<>'temp time='||g_period_temp then
              p_new_data_source.data_source_stmt(p_new_data_source.data_source_stmt.count+1):='period '||g_period_temp||',';
              p_new_data_source.data_source_stmt_type(p_new_data_source.data_source_stmt.count):='temp time='||g_period_temp;
              p_new_data_source.data_source_stmt(p_new_data_source.data_source_stmt.count+1):='year '||g_year_temp||',';
              p_new_data_source.data_source_stmt_type(p_new_data_source.data_source_stmt.count):='temp time='||g_year_temp;
            end if;
          end if;
        end if;
      end if;
      j:=j+1;
      if j>p_data_source(i).data_source_stmt.count then
        exit;
      end if;
    end loop;
  end loop;
  p_new_data_source.data_source_stmt(p_new_data_source.data_source_stmt.count+1):=') BSC_B';
  p_new_data_source.data_source_stmt_type(p_new_data_source.data_source_stmt.count):='sql from';
  p_new_data_source.data_source_stmt(p_new_data_source.data_source_stmt.count+1):='group by';
  p_new_data_source.data_source_stmt_type(p_new_data_source.data_source_stmt.count):='sql group by';
  for i in reverse 1..p_dim_set.std_dim.count loop
    p_new_data_source.data_source_stmt(p_new_data_source.data_source_stmt.count+1):=p_dim_set.std_dim(i).levels(1).fk||',';
    p_new_data_source.data_source_stmt_type(p_new_data_source.data_source_stmt.count):='sql group by stmt';
  end loop;
  for i in reverse 1..p_new_data_source.dim.count loop
    p_new_data_source.data_source_stmt(p_new_data_source.data_source_stmt.count+1):=p_new_data_source.dim(i).levels(1).fk||',';
    p_new_data_source.data_source_stmt_type(p_new_data_source.data_source_stmt.count):='sql group by stmt';
  end loop;
  --time
  p_new_data_source.data_source_stmt(p_new_data_source.data_source_stmt.count+1):='period,';
  p_new_data_source.data_source_stmt_type(p_new_data_source.data_source_stmt.count):='sql group by stmt';
  if bsc_aw_utility.get_property(p_new_data_source.property,g_balance_last_value_prop).property_value='Y' then
    p_new_data_source.data_source_stmt(p_new_data_source.data_source_stmt.count+1):=g_period_temp||',';
    p_new_data_source.data_source_stmt_type(p_new_data_source.data_source_stmt.count):='sql group by stmt';
    p_new_data_source.data_source_stmt(p_new_data_source.data_source_stmt.count+1):=g_year_temp||',';
    p_new_data_source.data_source_stmt_type(p_new_data_source.data_source_stmt.count):='sql group by stmt';
  end if;
  --
  if p_dim_set.number_partitions>0 then
    p_new_data_source.data_source_stmt(p_new_data_source.data_source_stmt.count+1):=p_new_data_source.data_source_PT.partition_template.template_dim||',';
    p_new_data_source.data_source_stmt_type(p_new_data_source.data_source_stmt.count):='sql group by stmt';
  end if;
  --remove the trailing ,
  p_new_data_source.data_source_stmt(p_new_data_source.data_source_stmt.count):=
  substr(p_new_data_source.data_source_stmt(p_new_data_source.data_source_stmt.count),1,
  length(p_new_data_source.data_source_stmt(p_new_data_source.data_source_stmt.count))-1);
Exception when others then
  log_n('Exception in create_dimset_data_source_sql '||sqlerrm);
  raise;
End;

/*
given a data source, create the sql data source stmt
if the level of the base table is the same as that of the lowest level of the dim set, no need to
join to dim tables. else, have to join
if the base table has the same number of keys as the dim set, no agg needed. else agg needed
this generates the sql for driving from B table
*/
procedure create_data_source_sql(
p_kpi varchar2,
p_dim_set dim_set_r,
p_data_source in out nocopy data_source_r
) is
--
l_balance_loaded_column varchar2(40);
l_DS_dim_parent_child parent_child_tb;
Begin
  p_data_source.data_source_stmt.delete;
  p_data_source.data_source_stmt_type.delete;
  /*set the properties */
  if is_filter_in_data_source(p_data_source)='Y' then
    bsc_aw_utility.merge_property(p_data_source.property,'dimension filter',null,'Y');
  end if;
  if is_balance_last_value_in_DS(p_data_source)='Y' then
    bsc_aw_utility.merge_property(p_data_source.property,g_balance_last_value_prop,null,'Y');
  end if;
  --for now, we only have 1 base table per data source. not any more...we can have the prj table as the second b table in the DS
  for i in 1..p_data_source.base_tables.count loop
    if i=1 then
      p_data_source.data_source_stmt(p_data_source.data_source_stmt.count+1):='sql declare c1 cursor for select';
    else
      p_data_source.data_source_stmt(p_data_source.data_source_stmt.count+1):='select';
    end if;
    p_data_source.data_source_stmt_type(p_data_source.data_source_stmt.count):='sql select';
    --for each base table, keys are the same
    for j in 1..p_data_source.dim.count loop
      if instr(lower(p_data_source.dim(j).levels(1).data_type),'varchar')>0 then
        p_data_source.data_source_stmt(p_data_source.data_source_stmt.count+1):='to_char('||p_data_source.dim(j).levels(1).fk||') '||
        p_data_source.dim(j).levels(1).fk||',';
      else
        p_data_source.data_source_stmt(p_data_source.data_source_stmt.count+1):=p_data_source.dim(j).levels(1).fk||',';
      end if;
      p_data_source.data_source_stmt_type(p_data_source.data_source_stmt.count):='dimension='||p_data_source.dim(j).dim_name;
    end loop;
    --std dim
    for j in 1..p_dim_set.std_dim.count loop
      if instr(lower(p_dim_set.std_dim(j).levels(1).data_type),'varchar')>0 then
        p_data_source.data_source_stmt(p_data_source.data_source_stmt.count+1):='to_char('||p_dim_set.std_dim(j).levels(1).fk||') '||
        p_dim_set.std_dim(j).levels(1).fk||',';
      else
        p_data_source.data_source_stmt(p_data_source.data_source_stmt.count+1):=p_dim_set.std_dim(j).levels(1).fk||',';
      end if;
      p_data_source.data_source_stmt_type(p_data_source.data_source_stmt.count):='dimension='||p_dim_set.std_dim(j).dim_name;
    end loop;
    --time
    p_data_source.data_source_stmt(p_data_source.data_source_stmt.count+1):='period||\''.\''||year period,';
    p_data_source.data_source_stmt_type(p_data_source.data_source_stmt.count):='dimension=time';
    if bsc_aw_utility.get_property(p_data_source.property,g_balance_last_value_prop).property_value='Y' then
      /*select period and year separately to load period.temp and year.temp. used for BALANCE LAST VALUE
      Q: classified as temp or measure? keep temp for now*/
      p_data_source.data_source_stmt(p_data_source.data_source_stmt.count+1):='period '||g_period_temp||',';
      p_data_source.data_source_stmt_type(p_data_source.data_source_stmt.count):='temp time='||g_period_temp;
      p_data_source.data_source_stmt(p_data_source.data_source_stmt.count+1):='year '||g_year_temp||',';
      p_data_source.data_source_stmt_type(p_data_source.data_source_stmt.count):='temp time='||g_year_temp;
    end if;
    /*
    if we have partition, we want to select the partiton key here
    the partition key is made of the dim keys
    we set the partition_dim of the data source only if there are partitions in the dimset
    */
    --
    if p_dim_set.number_partitions>0 then
      /*we need to see in the future how to support range partitions etc. for now, we only support hash partitons(list)
      if the B table is list partitioned, we can simply select from the B table partition
      all B tables in a DS have the same partition type
      note>>>diff DS can have diff partitions. one B table may have list, another may have no partitions at all
      this is not ok. if a dimset has multiple DS, we cannot be sure of the partition value in the B table. each B table may have diff
      keys and the order used may be diff. so a row from B1 and a corresponding row from B2 may show diff partition list values. in this case,
      we cannot channel them to separate PT and then calculated measures(formula) will be wrong.
      */
      if p_dim_set.partition_type='list' then
        p_data_source.data_source_stmt(p_data_source.data_source_stmt.count+1):=
        p_data_source.base_tables(1).table_partition.main_partition.partition_column||' '||p_data_source.data_source_PT.partition_template.template_dim||',';
        p_data_source.data_source_stmt_type(p_data_source.data_source_stmt.count):='partition dim list';
      else /*hash partitions */
        /*now hpt_data drives what dimensions are in the hash list */
        /*Q:do we have master pt or cube pt? we will have master pt. cube pt holds physical info like axis name etc. the logical properties
        must be in master PT. for each DS, we see which dim from hpt_data match and use them. example one DS may be at week level, another at month
        level. hpt_data contains both week and month
        DS must have partition info set. DS cannot be feeding levels that have no partitions
        p_data_source.data_source_PT should be set if there are hash partitions. when there are multiple DS, the order of dim keys in the hash
        function is important*/
        p_data_source.data_source_stmt(p_data_source.data_source_stmt.count+1):=get_DS_PT_hash_stmt(p_dim_set,p_data_source)||' '||
        p_data_source.data_source_PT.partition_template.template_dim||',';
        p_data_source.data_source_stmt_type(p_data_source.data_source_stmt.count):='partition dim hash';
      end if;
    end if;
    --measures...measures are dependent on the data source
    --a data source always feeds the same measures, even if there are multiple base tables
    for j in 1..p_data_source.measure.count loop
      --please note that the formula is already resolved in create_base_table_sql and aliased to p_data_source.measure(j).measure
      p_data_source.data_source_stmt(p_data_source.data_source_stmt.count+1):=p_data_source.measure(j).measure||',';
      p_data_source.data_source_stmt_type(p_data_source.data_source_stmt.count):='measure='||upper(p_data_source.measure(j).measure);
    end loop;
    /*balance loaded column */
    for j in 1..p_data_source.measure.count loop
      if p_data_source.measure(j).measure_type=g_balance_last_value_prop then
        l_balance_loaded_column:=bsc_aw_utility.get_property(p_data_source.measure(j).property,g_balance_loaded_column_prop).property_value;
        if l_balance_loaded_column is not null then
          p_data_source.data_source_stmt(p_data_source.data_source_stmt.count+1):=l_balance_loaded_column||',';
          p_data_source.data_source_stmt_type(p_data_source.data_source_stmt.count):='temp balance loaded column='||p_data_source.measure(j).measure;
        end if;
      end if;
    end loop;
    --the markers for the fk
    for j in 1..p_data_source.dim.count loop
      p_data_source.data_source_stmt(p_data_source.data_source_stmt.count+1):='1,';
      p_data_source.data_source_stmt_type(p_data_source.data_source_stmt.count):='limit cube='||p_data_source.dim(j).dim_name;
    end loop;
    --markers for std dim
    for j in 1..p_dim_set.std_dim.count loop
      p_data_source.data_source_stmt(p_data_source.data_source_stmt.count+1):='1,';
      p_data_source.data_source_stmt_type(p_data_source.data_source_stmt.count):='limit cube='||p_dim_set.std_dim(j).dim_name;
    end loop;
    --marker for time
    p_data_source.data_source_stmt(p_data_source.data_source_stmt.count+1):='1';
    p_data_source.data_source_stmt_type(p_data_source.data_source_stmt.count):='limit cube=time';
    --we then create the sql for the base tables
    create_base_table_sql(p_dim_set,p_data_source,p_data_source.base_tables(i));
    p_data_source.data_source_stmt(p_data_source.data_source_stmt.count+1):='from ';
    p_data_source.data_source_stmt_type(p_data_source.data_source_stmt.count):='sql from';
    --base_table_sql is o the form (select...from base where ...)
    for j in 1..p_data_source.base_tables(i).base_table_sql.count loop
      p_data_source.data_source_stmt(p_data_source.data_source_stmt.count+1):=p_data_source.base_tables(i).base_table_sql(j);
      p_data_source.data_source_stmt_type(p_data_source.data_source_stmt.count):='sql from table';
    end loop;
    /*if we have partition dim levels at higher level than the floor level of the DS, we need to join to levels or calendar to get
    the higher keys */
    for j in 1..p_data_source.data_source_PT.partition_template.hpt_data.hpt_dimensions.count loop
      l_DS_dim_parent_child.delete;
      l_DS_dim_parent_child:=p_data_source.data_source_PT.dim_parent_child(
      p_data_source.data_source_PT.partition_template.hpt_data.hpt_dimensions(j).dim_name);
      if l_DS_dim_parent_child.count>0 then
        bsc_aw_utility.init_is_new_value(1);
        for k in 1..l_DS_dim_parent_child.count loop
          if bsc_aw_utility.is_new_value(l_DS_dim_parent_child(k).child_level,1) then
            p_data_source.data_source_stmt(p_data_source.data_source_stmt.count+1):=','||l_DS_dim_parent_child(k).child_level;
            p_data_source.data_source_stmt_type(p_data_source.data_source_stmt.count):='sql from table';
          end if;
        end loop;
      end if;
    end loop;
    if p_data_source.data_source_PT.cal_parent_child.count>0 then
      p_data_source.data_source_stmt(p_data_source.data_source_stmt.count+1):=',(select distinct year pt_year';
      bsc_aw_utility.init_is_new_value(1);
      for j in 1..p_data_source.data_source_PT.cal_parent_child.count loop
        if bsc_aw_utility.is_new_value(p_data_source.data_source_PT.cal_parent_child(j).child_dim_name,1) then /*child_dim_name is db_column_name */
          p_data_source.data_source_stmt(p_data_source.data_source_stmt.count):=p_data_source.data_source_stmt(p_data_source.data_source_stmt.count)||','||
          p_data_source.data_source_PT.cal_parent_child(j).child_dim_name;
        end if;
        if bsc_aw_utility.is_new_value(p_data_source.data_source_PT.cal_parent_child(j).parent_dim_name,1) then /*parent_dim_name is db_column_name */
          p_data_source.data_source_stmt(p_data_source.data_source_stmt.count):=p_data_source.data_source_stmt(p_data_source.data_source_stmt.count)||','||
          p_data_source.data_source_PT.cal_parent_child(j).parent_dim_name;
        end if;
      end loop;
      p_data_source.data_source_stmt(p_data_source.data_source_stmt.count):=p_data_source.data_source_stmt(p_data_source.data_source_stmt.count)||
      ' from bsc_db_calendar) bsc_db_calendar';
      p_data_source.data_source_stmt_type(p_data_source.data_source_stmt.count):='sql from table';
    end if;
    --
    p_data_source.data_source_stmt(p_data_source.data_source_stmt.count+1):=' where 1=1 ';
    p_data_source.data_source_stmt_type(p_data_source.data_source_stmt.count):='sql where';
    --add the filter
    --check for the filter at the lowest level
    --filter is (select..from bsc_sys_filters...)
    for j in 1..p_data_source.dim.count loop
      if p_data_source.dim(j).levels(1).filter.count > 0 then
        p_data_source.data_source_stmt(p_data_source.data_source_stmt.count+1):=' and '||p_data_source.base_tables(i).base_table_name||'.'||
        p_data_source.dim(j).levels(1).fk||' in ';
        p_data_source.data_source_stmt_type(p_data_source.data_source_stmt.count):='sql where stmt';
        for k in 1..p_data_source.dim(j).levels(1).filter.count loop
          p_data_source.data_source_stmt(p_data_source.data_source_stmt.count+1):=p_data_source.dim(j).levels(1).filter(k);
          p_data_source.data_source_stmt_type(p_data_source.data_source_stmt.count):='sql where stmt';
        end loop;
      end if;
    end loop;
    /*now add the join if there are higher level partitions */
    for j in 1..p_data_source.data_source_PT.partition_template.hpt_data.hpt_dimensions.count loop
      l_DS_dim_parent_child.delete;
      l_DS_dim_parent_child:=p_data_source.data_source_PT.dim_parent_child(
      p_data_source.data_source_PT.partition_template.hpt_data.hpt_dimensions(j).dim_name);
      if l_DS_dim_parent_child.count>0 then
        /*first the B table join */
        for k in 1..p_data_source.dim.count loop
          /*assumption: l_DS_dim_parent_child.count has the lowest level which the level of the DS */
          if p_data_source.dim(k).dim_name=p_data_source.data_source_PT.partition_template.hpt_data.hpt_dimensions(j).dim_name then
            p_data_source.data_source_stmt(p_data_source.data_source_stmt.count+1):=' and '||p_data_source.base_tables(i).base_table_name||'.'||
            p_data_source.dim(k).levels(1).fk||'='||l_DS_dim_parent_child(l_DS_dim_parent_child.count).child_level||'.'||
            l_DS_dim_parent_child(l_DS_dim_parent_child.count).parent_pk;/*assume parent_pk is same like CODE across levels */
            p_data_source.data_source_stmt_type(p_data_source.data_source_stmt.count):='sql where stmt';
            --
            exit;
          end if;
        end loop;
        /*now, the join between the levels */
        for k in 2..l_DS_dim_parent_child.count loop /*we start from 2 since we do not include the top most level for perf reasons */
          p_data_source.data_source_stmt(p_data_source.data_source_stmt.count+1):=' and '||l_DS_dim_parent_child(k).child_level||'.'||
          l_DS_dim_parent_child(k).child_fk||'='||l_DS_dim_parent_child(k).parent_level||'.'||l_DS_dim_parent_child(k).parent_pk;
          p_data_source.data_source_stmt_type(p_data_source.data_source_stmt.count):='sql where stmt';
        end loop;
      end if;
    end loop;
    /*now the calendar */
    if p_data_source.data_source_PT.cal_parent_child.count>0 then
      /*first the B table join */
      p_data_source.data_source_stmt(p_data_source.data_source_stmt.count+1):=' and '||p_data_source.base_tables(i).base_table_name||'.year='||
      'bsc_db_calendar.pt_year and '||p_data_source.base_tables(i).base_table_name||'.period=bsc_db_calendar.'||
      p_data_source.data_source_PT.cal_parent_child(1).child_dim_name;/*cal_parent_child(1).child_dim_name will all be the DS periodicity */
      p_data_source.data_source_stmt_type(p_data_source.data_source_stmt.count):='sql where stmt';
    end if;
    if p_data_source.base_tables.count>1 and i<>p_data_source.base_tables.count then
      p_data_source.data_source_stmt(p_data_source.data_source_stmt.count+1):=' union all ';
      p_data_source.data_source_stmt_type(p_data_source.data_source_stmt.count):='sql union all';
    end if;
  end loop;
Exception when others then
  log_n('Exception in create_data_source_sql '||sqlerrm);
  raise;
End;

/*
this procedure creates the base table sql. the base table can be at a lower level than the first level of the dim set.
in this case, it need to rollup the data before loading the kpi dim set
base table can have larger number of keys. in this case also rollup.
the base table can have the same number of keys at the same level. in this case no rollup. remove the agg function from
the formula
agg formula is like MIN(Gr_806Sim1/DECODE(Gr_806Sim2,0,NULL,Gr_806Sim2)) change it to
(Gr_806Sim1/DECODE(Gr_806Sim2,0,NULL,Gr_806Sim2))

if the base table has more keys than the dim set, when we move data from the _AW table, we have to join with the base table.
if the base table has more keys, then the aw table is used only as a fk table. the sql will be
select
base.k1,
base.k2,
..
formula(base.m1) m1,
formula(base.m2) m1,
...
from
base,
(select distinct k1,k2... from base_aw where bitand(...)) base_aw
where base.k1=base_aw.k1 and ...

if the number of keys in the base and dimset are the same, we only need the base_aw table in the inc mode
*/
procedure create_base_table_sql(
p_dim_set dim_set_r,
p_data_source data_source_r,
p_base_table in out nocopy base_table_r
) is
--
l_dim varchar2(300);
l_parent_child bsc_aw_adapter_dim.dim_parent_child_tb;
l_pc_subset bsc_aw_adapter_dim.dim_parent_child_tb;
l_from_sql dbms_sql.varchar2_table;
l_where_sql dbms_sql.varchar2_table;
l_group_sql dbms_sql.varchar2_table;
l_base_cal_column varchar2(100); --lower periodicity column name from bsc_db_calendar
l_dimset_cal_column varchar2(100);
l_remove_agg_flag boolean;
l_formula varchar(4000);
l_flag boolean;
--l_base_aw_join_flag is used only for inc load if the number of keys in the base > that in the dim set
--keeps track of what keys to join between base and base_aw
l_base_aw_join_flag dbms_sql.varchar2_table;
l_alias varchar2(100);
l_aw_table_fk_driver_only boolean;--if true the aw table is only a fk driver table
l_balance_loaded_column varchar2(40);
Begin
  p_base_table.base_table_sql.delete;
  l_aw_table_fk_driver_only:=false;
  if p_data_source.ds_type='inc' then
    if bsc_aw_utility.in_array(p_base_table.level_status,'extra') then
      l_aw_table_fk_driver_only:=true;
    end if;
  end if;
  l_from_sql.delete;
  l_where_sql.delete;
  p_base_table.base_table_sql(1):='(select ';
  if (p_data_source.ds_type='initial') or (p_data_source.ds_type='inc' and l_aw_table_fk_driver_only) then
    --in this case, bsc_aw_temp_cv is in the inner sql
    l_from_sql(1):=' from '||p_base_table.base_table_name;
    l_alias:=p_base_table.base_table_name;
    l_where_sql(1):=' where 1=1 ';
  else
    l_from_sql(1):=' from bsc_aw_temp_cv,'||p_base_table.base_table_name;
    l_alias:=p_base_table.base_table_name;
    l_where_sql(1):=' where 1=1 ';
    l_where_sql(l_where_sql.count+1):=' and bsc_aw_temp_cv.change_vector_base_table=\'''||upper(p_base_table.base_table_name)||'\'' and '||
    l_alias||'.change_vector between bsc_aw_temp_cv.change_vector_min_value and bsc_aw_temp_cv.change_vector_max_value ';
  end if;
  l_group_sql(1):='group by ';
  --for all the keys that are N, we need to further process
  for i in 1..p_base_table.levels.count loop
    l_base_aw_join_flag(i):='N';
    if p_base_table.level_status(i)='lower' then --the level is lower than the lowest level of dim set
      l_parent_child.delete;
      l_pc_subset.delete;
      bsc_aw_md_api.get_dim_for_level(p_base_table.levels(i).level_name,l_dim);
      bsc_aw_md_api.get_dim_parent_child(l_dim,l_parent_child);
      l_pc_subset:=bsc_aw_adapter_dim.get_hier_subset(l_parent_child,get_dim_given_dim_name(l_dim,p_data_source.dim).levels(1).level_name,
      p_base_table.levels(i).level_name);
      if l_pc_subset.count=0 then
        log('Could not rollup from B table to dimset '||p_base_table.base_table_name||', at level '||p_base_table.levels(i).level_name);
        raise bsc_aw_utility.g_exception;
      end if;
      l_base_aw_join_flag(i):='Y';
      --first entry is the data source level
      p_base_table.base_table_sql(p_base_table.base_table_sql.count+1):=l_pc_subset(1).child_level||'.'||l_pc_subset(1).child_fk||',';
      l_group_sql(l_group_sql.count+1):=l_pc_subset(1).child_level||'.'||l_pc_subset(1).child_fk||',';
      l_where_sql(l_where_sql.count+1):=' and '||l_alias||'.'||p_base_table.levels(i).fk||'='||
      l_pc_subset(l_pc_subset.count).child_level||'.'||l_pc_subset(l_pc_subset.count).parent_pk;
      for j in 1..l_pc_subset.count loop
        l_from_sql(l_from_sql.count+1):=','||l_pc_subset(j).child_level;
        if j <> 1 then --we do not include the last level...for performance
          l_where_sql(l_where_sql.count+1):=' and '||l_pc_subset(j).child_level||'.'||l_pc_subset(j).child_fk||
          '='||l_pc_subset(j).parent_level||'.'||l_pc_subset(j).parent_pk;
        end if;
      end loop;
    elsif p_base_table.level_status(i)='correct' or p_base_table.level_status(i)='higher' then
      l_base_aw_join_flag(i):='Y';--base table key has to join with the _AW table key
      p_base_table.base_table_sql(p_base_table.base_table_sql.count+1):=l_alias||'.'||p_base_table.levels(i).fk||',';
      l_group_sql(l_group_sql.count+1):=l_alias||'.'||p_base_table.levels(i).fk||',';
    else --the skip key
      --if the lowest key and a higher key exists in the base table, we dont have to group by the lowest key since the data
      --is already at the lowest key granularity
      null;
    end if;
  end loop;
  --now the std dim, type and projection
  for i in 1..p_data_source.std_dim.count loop
    p_base_table.base_table_sql(p_base_table.base_table_sql.count+1):=l_alias||'.'||p_data_source.std_dim(i).levels(1).fk||',';
    l_group_sql(l_group_sql.count+1):=l_alias||'.'||p_data_source.std_dim(i).levels(1).fk||',';
  end loop;
  --now period and year
  --if the base table is at lower perioidicity than the dim set, also have to rollup on time
  --p_dim_set.calendar.periodicity(1) is the lowest level in time: NO this is not true. look at lowest_level flag
  --if p_base_table.periodicity.periodicity <> p_data_source.calendar.periodicity(1).periodicity then
  /*there is an interesting issue here. what if the measure is a balance measure and we have to rollup B table on time? so far this
  issue has not come up because balance is at day level */
  if p_base_table.periodicity.periodicity <> p_data_source.calendar.periodicity(1).periodicity then --then this is coming at a lower level
    l_base_cal_column:=bsc_aw_bsc_metadata.get_db_calendar_column(p_dim_set.calendar.calendar,p_base_table.periodicity.periodicity);
    --note>>>datasource has one periodicity. see get_dim_set_data_source in bsc_aw_bsc_metadata
    l_dimset_cal_column:=bsc_aw_bsc_metadata.get_db_calendar_column(p_dim_set.calendar.calendar,p_data_source.calendar.periodicity(1).periodicity);
    p_base_table.base_table_sql(p_base_table.base_table_sql.count+1):='bsc_db_calendar.'||l_dimset_cal_column||' period,'||
    'bsc_db_calendar.year year,';
    l_group_sql(l_group_sql.count+1):='bsc_db_calendar.'||l_dimset_cal_column||',bsc_db_calendar.year,';
    l_from_sql(l_from_sql.count+1):=',(select distinct '||l_base_cal_column||','||l_dimset_cal_column||',year from bsc_db_calendar where calendar_id='||
    p_data_source.calendar.calendar||') bsc_db_calendar';
    l_where_sql(l_where_sql.count+1):=' and bsc_db_calendar.'||l_base_cal_column||'='||l_alias||'.period and '||
    'bsc_db_calendar.year='||l_alias||'.year';
  else
    --base table at the same periodicity as the dim set
    p_base_table.base_table_sql(p_base_table.base_table_sql.count+1):=l_alias||'.period,'||l_alias||'.year,';
    l_group_sql(l_group_sql.count+1):=l_alias||'.period,'||l_alias||'.year,';
  end if;
  --if base keys > dim set keys and inc load
  --in this case the aw table is only a key drive table. data comes from base table
  --please note that if the extra keys are keys with l_ok(i)='S', we do not have to do this.
  --skip keys are simply ignored. its as if they did not exist
  --do p_base_table.levels.count - p_data_source.dim.count if this is > count(l_ok='S') then we have to do this
  if p_data_source.ds_type='inc' and l_aw_table_fk_driver_only then
    --make the from clause
    l_from_sql(l_from_sql.count+1):=',(select distinct ';
    for i in 1..p_base_table.levels.count loop
      if l_base_aw_join_flag(i)='Y' then
        --we have _AW appended to the fk from the _AW table (in line sql) to avoid the issue of having to correctly
        --specify the table name in the select and group by part.
        l_from_sql(l_from_sql.count+1):=p_base_table.base_table_name||'.'||p_base_table.levels(i).fk||' '||p_base_table.levels(i).fk||'_AW,';
      end if;
    end loop;
    --we need the std dim
    for i in 1..p_data_source.std_dim.count loop
      l_from_sql(l_from_sql.count+1):=p_base_table.base_table_name||'.'||p_data_source.std_dim(i).levels(1).fk||' '||
      p_data_source.std_dim(i).levels(1).fk||'_AW,';
    end loop;
    --also we need period and year
    /*in caes of partitions, the filter on the partition is added in  create_kpi_program_partition*/
    l_from_sql(l_from_sql.count+1):=p_base_table.base_table_name||'.period period_aw,'||
    p_base_table.base_table_name||'.year year_aw from bsc_aw_temp_cv,'||p_base_table.base_table_name;
    l_from_sql(l_from_sql.count+1):=' where 1=1 ';
    l_from_sql(l_from_sql.count+1):='and bsc_aw_temp_cv.change_vector_base_table=\'''||upper(p_base_table.base_table_name)||'\'' and '||
    p_base_table.base_table_name||'.change_vector between bsc_aw_temp_cv.change_vector_min_value and bsc_aw_temp_cv.change_vector_max_value) B_AW';
    --make the where clause
    for i in 1..p_base_table.levels.count loop
      if l_base_aw_join_flag(i)='Y' then
        --we have _AW appended to the fk from the _AW table (in line sql) to avoid the issue of having to correctly
        --specify the table name in the select and group by part.
        l_where_sql(l_where_sql.count+1):=' and '||l_alias||'.'||p_base_table.levels(i).fk||'='||
        'B_AW.'||p_base_table.levels(i).fk||'_AW';
      end if;
    end loop;
    --std dim
    for i in 1..p_data_source.std_dim.count loop
      l_where_sql(l_where_sql.count+1):=' and '||l_alias||'.'||p_data_source.std_dim(i).levels(1).fk||'='||
      'B_AW.'||p_data_source.std_dim(i).levels(1).fk||'_AW';
    end loop;
    --join period and year
    l_where_sql(l_where_sql.count+1):=' and '||l_alias||'.period=B_AW.period_AW';
    l_where_sql(l_where_sql.count+1):=' and '||l_alias||'.year=B_AW.year_AW';
  end if;
  --if we have list partitions, include the list partition column also
  /*we can select partition col only if dimset is partitioned. otherwise, group by batch from B table will make data loaded into dimset incorrect
  there is no group by at data source level
  if dimset partition type is list, then we can be assured that B table is partitioned by list partitions, with the same number of partitions
  as the dimset. this is done in api load_master_PT*/
  if p_dim_set.number_partitions>0 and p_dim_set.partition_type='list' then
    if p_base_table.table_partition.main_partition.partition_type='LIST' then
      p_base_table.base_table_sql(p_base_table.base_table_sql.count+1):=l_alias||'.'||p_base_table.table_partition.main_partition.partition_column||',';
      l_group_sql(l_group_sql.count+1):=l_alias||'.'||p_base_table.table_partition.main_partition.partition_column||',';
    end if;
  end if;
  --now the measures
  l_remove_agg_flag:=false;
  if bsc_aw_utility.in_array(p_base_table.level_status,'lower')=false and bsc_aw_utility.in_array(p_base_table.level_status,'extra')=false
  and p_base_table.periodicity.periodicity=p_data_source.calendar.periodicity(1).periodicity then
    --there are no keys with rollup or there are no extra keys and the periodicity of base is same as dimset
    --this means we can remove the agg function
    l_remove_agg_flag:=true;
    --see if count is a part of the agg function. if yes, we have to force agg, make l_remove_agg_flag:=false
    --we saw if we can hardcode 1 in parse_out_agg_function. but AW threw error
    --ORA-34738: (NOUPDATE) A severe problem has been detected. Analytic workspace operations have been disabled.
    --ORA-06512: at "APPS.BSC_AW_UTILITY", line 466
    --ORA-06512: at "APPS.BSC_AW_LOAD", line 112.  it was confusing 1 with true/false 1 so we are forced to have agg when count is involved
    --maybe we can use sql fetch c1 loop into...but for now, lets keep the agg when count is involved
    --database does not suffer too much in perf with a group by. note here that there is no joins involbed. its just group by on the
    --base table
    for i in 1..p_data_source.measure.count loop
      if lower(ltrim(rtrim(substr(p_data_source.measure(i).formula,1,instr(p_data_source.measure(i).formula,'(')-1))))='count' then
        l_remove_agg_flag:=false;
        exit;
      end if;
    end loop;
  end if;
  for i in 1..p_data_source.measure.count loop
    l_balance_loaded_column:=bsc_aw_utility.get_property(p_data_source.measure(i).property,g_balance_loaded_column_prop).property_value;
    if l_remove_agg_flag then
      --l_formula has no agg, we can have 3 types of agg in BSC
      --Apply aggregation method to the each element of the formula, e.g.: SUM(source_column1)/SUM(source_column2)
      --Apply aggregation method to the overall formula, e.g.: SUM(source_column1/source_column2)
      --Formulas between 2 calculated Measures e.g.: SUM(source_col1/source_col2)/AVG(source_col3+source_col4)
      bsc_aw_utility.parse_out_agg_function(p_data_source.measure(i).formula,l_formula);
      p_base_table.base_table_sql(p_base_table.base_table_sql.count+1):=l_formula||' '||p_data_source.measure(i).measure||',';
      if p_data_source.measure(i).measure_type=g_balance_last_value_prop and l_balance_loaded_column is not null then
        p_base_table.base_table_sql(p_base_table.base_table_sql.count+1):='decode('||l_balance_loaded_column||',\''Y\'',1,0) '||
        l_balance_loaded_column||',';
      end if;
    else
      p_base_table.base_table_sql(p_base_table.base_table_sql.count+1):=p_data_source.measure(i).formula||' '||
      p_data_source.measure(i).measure||',';
      if p_data_source.measure(i).measure_type=g_balance_last_value_prop and l_balance_loaded_column is not null then
        p_base_table.base_table_sql(p_base_table.base_table_sql.count+1):='SUM(decode('||l_balance_loaded_column||',\''Y\'',1,0)) '||
        l_balance_loaded_column||',';
      end if;
    end if;
  end loop;
  p_base_table.base_table_sql(p_base_table.base_table_sql.count):=substr(p_base_table.base_table_sql(p_base_table.base_table_sql.count),
  1,length(p_base_table.base_table_sql(p_base_table.base_table_sql.count))-1);
  for i in 1..l_from_sql.count loop
    p_base_table.base_table_sql(p_base_table.base_table_sql.count+1):=l_from_sql(i);
  end loop;
  for i in 1..l_where_sql.count loop
    p_base_table.base_table_sql(p_base_table.base_table_sql.count+1):=l_where_sql(i);
  end loop;
  --if l_remove_agg_flag=false, this means that there is either a rollup or an extra key
  if l_remove_agg_flag=false then
    --remove the trailing "," from groupby
    l_group_sql(l_group_sql.count):=substr(l_group_sql(l_group_sql.count),1,length(l_group_sql(l_group_sql.count))-1);
    for i in 1..l_group_sql.count loop
      p_base_table.base_table_sql(p_base_table.base_table_sql.count+1):=l_group_sql(i);
    end loop;
  end if;
  p_base_table.base_table_sql(p_base_table.base_table_sql.count+1):=') '||p_base_table.base_table_name;
Exception when others then
  log_n('Exception in create_base_table_sql '||sqlerrm);
  raise;
End;

/*
given a dim record, loop through the levels in it to see if the given level is a part of the dim or not
used by trim_parent_child, which in turn is used by create_base_table_sql
*/
function is_level_in_dim(p_dim dim_r,p_level varchar2) return boolean is
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
given a CC dim name, get the dim_r object
*/
function get_dim_given_dim_name(p_dim varchar2,p_dim_set dim_set_r) return dim_r is
Begin
  return get_dim_given_dim_name(p_dim,p_dim_set.dim);
Exception when others then
  log_n('Exception in get_dim_given_dim_name '||sqlerrm);
  raise;
End;

function get_dim_given_dim_name(p_dim varchar2,p_dim_t dim_tb) return dim_r is
Begin
  for i in 1..p_dim_t.count loop
    if p_dim_t(i).dim_name=p_dim then
      return p_dim_t(i);
    end if;
  end loop;
  return null;
Exception when others then
  log_n('Exception in get_dim_given_dim_name '||sqlerrm);
  raise;
End;

function is_dim_in_dimset(p_dim_set dim_set_r,p_dim varchar2) return boolean is
Begin
  for i in 1..p_dim_set.dim.count loop
    if p_dim_set.dim(i).dim_name=p_dim then
      return true;
    end if;
  end loop;
  return false;
Exception when others then
  log_n('Exception in is_dim_in_dimset '||sqlerrm);
  raise;
End;

procedure drop_kpi_objects(p_kpi varchar2) is
Begin
  if g_debug then
    log_n('Drop KPI '||p_kpi);
  end if;
  drop_kpi_objects_aw(p_kpi);
  drop_kpi_objects_relational(p_kpi);
  --drop kpi metadata
  bsc_aw_md_api.drop_kpi(p_kpi);
Exception when others then
  log_n('Exception in drop_kpi_objects '||sqlerrm);
  raise;
End;

procedure drop_kpi_objects_aw(p_kpi varchar2) is
--
l_objects bsc_aw_utility.object_tb; --object_t is object_name and object_type
l_flag dbms_sql.varchar2_table;
Begin
  bsc_aw_md_api.get_kpi_olap_objects(p_kpi,l_objects,'all');
  for i in 1..l_objects.count loop
    l_flag(i):='N';
  end loop;
  --get_kpi_olap_objects will only populate l_objects when olap object type is not null
  for i in 1..l_objects.count loop
    if l_flag(i)='N' and l_objects(i).object_type <> 'partition template' and
    l_objects(i).object_type <> 'dimension' and l_objects(i).object_type <> 'composite' then
      bsc_aw_utility.delete_aw_object(l_objects(i).object_name);
      l_flag(i):='Y';
    end if;
  end loop;
  --partition template
  for i in 1..l_objects.count loop
    if l_flag(i)='N' and l_objects(i).object_type = 'partition template' then
      bsc_aw_utility.delete_aw_object(l_objects(i).object_name);
      l_flag(i):='Y';
    end if;
  end loop;
  --composite
  for i in 1..l_objects.count loop
    if l_flag(i)='N' and l_objects(i).object_type = 'composite' then
      bsc_aw_utility.delete_aw_object(l_objects(i).object_name);
      l_flag(i):='Y';
    end if;
  end loop;
  --dimensions
  for i in 1..l_objects.count loop
    if l_flag(i)='N' and l_objects(i).object_type = 'dimension' then
      bsc_aw_utility.delete_aw_object(l_objects(i).object_name);
      l_flag(i):='Y';
    end if;
  end loop;
  --all the other objects
  for i in 1..l_objects.count loop
    if l_flag(i)='N' then
      bsc_aw_utility.delete_aw_object(l_objects(i).object_name);
      l_flag(i):='Y';
    end if;
  end loop;
  /*
  we do not want to drop olap table function types and views since the drop is permanent, if there is failure
  we cannot rollback
  This is no more true. we drop these objects. (In drop_kpi_objects_relational). we drop them because we have
  to clean up old objects. if midway the drop fails, the system is in unusuable state anyway
  */
  ---
Exception when others then
  log_n('Exception in drop_kpi_objects_aw '||sqlerrm);
  raise;
End;

/*
we will hold the type and view name in bsc olap objects. olap_object column will be null. so
drop_kpi_objects_relational action is final. due to database commit, if there is a failure in between, we cannot guarantee
the system. drop has to be rerun till successful
*/
procedure drop_kpi_objects_relational(p_kpi varchar2) is
l_flag dbms_sql.varchar2_table;
l_olap_object bsc_aw_md_wrapper.bsc_olap_object_tb;
Begin
  bsc_aw_md_api.get_bsc_olap_object(null,null,p_kpi,'kpi',l_olap_object);
  for i in 1..l_olap_object.count loop
    l_flag(i):='N';
  end loop;
  --
  for i in 1..l_olap_object.count loop
    if l_flag(i)='N' and l_olap_object(i).object_type='relational view' then
      bsc_aw_utility.execute_stmt_ne('drop view '||l_olap_object(i).object);
      l_flag(i):='Y';
    end if;
  end loop;
  --
  for i in 1..l_olap_object.count loop
    if l_flag(i)='N' and l_olap_object(i).object_type='relational type' then
      bsc_aw_utility.execute_stmt_ne('drop type '||l_olap_object(i).object||'_tab'); --assume naming convention
      bsc_aw_utility.execute_stmt_ne('drop type '||l_olap_object(i).object);
      l_flag(i):='Y';
    end if;
  end loop;
  --
Exception when others then
  log_n('Exception in drop_kpi_objects_relational '||sqlerrm);
  raise;
End;

/*
set the partition info.
note>>> we need to set this before the call to set_dim_set_data_source
by default, there are no partitions.
--
if there are non std agg, we have difficulty with hahs partitions. consider the case where we have bugnew=bugopen/bugclosed
here, the data looked as
               ------------------------------------DATACUBE.1.4014------------------------------------
               ----------------------------------HASH_PARTITION_DIM-----------------------------------
MEASURENAME.1.
4014               0          1          2          3          4          5          6          7
-------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
BUGOPEN            200.00      20.00         NA         NA         NA         NA         NA         NA
BUGCLOSED          100.00      10.00         NA         NA         NA         NA         NA         NA
BUGNEW               2.00       2.00         NA         NA         NA         NA         NA         NA
the formula was correctly calculated for each partition. however, when we sum the measure, we get a value 4. this is incorrect
since the real value is 220/110 = 2 and not 4.
the soln is not to materialize the formulas. we can define a formula as bugnew=total(bugopen)/total(bugclosed) and this formula is in the
view.also note the impact for avg measure. for now, we will disable partitions when we have non std agg
if 10.1.04 and greater and we have 2 times the cpu count as partitions reqd, try partition out.
*/
procedure set_dimset_partition_info(p_kpi varchar2,p_actual_dim_set in out nocopy dim_set_r,p_target_dim_set in out nocopy dim_set_r) is
Begin
  if g_debug then
    log('set_dimset_partition_info dimset='||p_actual_dim_set.dim_set_name||', with target='||p_target_dim_set.dim_set_name);
  end if;
  p_actual_dim_set.number_partitions:=0;
  p_target_dim_set.number_partitions:=0;
  load_master_PT(p_actual_dim_set,p_target_dim_set);
Exception when others then
  log_n('Exception in set_dimset_partition_info '||sqlerrm);
  raise;
End;

/*
create_aw_object_names gives names to cubes, programs etc
*/
procedure create_aw_object_names(p_kpi in out nocopy kpi_r) is
--
l_dim_index bsc_aw_utility.number_table;--used to populate limit cubes into data source.dim
l_measure_index bsc_aw_utility.number_table;--used to populate cubes into data source.measure
Begin
  for i in 1..p_kpi.dim_set.count loop
    --
    p_kpi.dim_set(i).aggmap_operator.measure_dim:='measuredim.'||p_kpi.dim_set(i).dim_set||'.'||p_kpi.kpi;
    p_kpi.dim_set(i).aggmap_operator.opvar:='opvar.'||p_kpi.dim_set(i).dim_set||'.'||p_kpi.kpi;
    p_kpi.dim_set(i).aggmap_operator.argvar:='argvar.'||p_kpi.dim_set(i).dim_set||'.'||p_kpi.kpi;
    --
    p_kpi.dim_set(i).agg_map.agg_map:='aggmap.'||p_kpi.dim_set(i).dim_set||'.'||p_kpi.kpi;
    p_kpi.dim_set(i).agg_map.aggmap_operator:=p_kpi.dim_set(i).aggmap_operator;
    --
    p_kpi.dim_set(i).agg_map_notime.agg_map:='aggmap.'||p_kpi.dim_set(i).dim_set||'.'||p_kpi.kpi||'.notime';
    p_kpi.dim_set(i).agg_map_notime.aggmap_operator:=p_kpi.dim_set(i).aggmap_operator;
    --
    p_kpi.dim_set(i).initial_load_program.program_name:='load.'||p_kpi.dim_set(i).dim_set||'.'||p_kpi.kpi||'.initial';
    p_kpi.dim_set(i).inc_load_program.program_name:='load.'||p_kpi.dim_set(i).dim_set||'.'||p_kpi.kpi||'.inc';
    --
    p_kpi.dim_set(i).initial_load_program_parallel.program_name:='load.'||p_kpi.dim_set(i).dim_set||'.'||p_kpi.kpi||'.initial.parallel';
    p_kpi.dim_set(i).inc_load_program_parallel.program_name:='load.'||p_kpi.dim_set(i).dim_set||'.'||p_kpi.kpi||'.inc.parallel';
    --
    p_kpi.dim_set(i).aggregate_marker_program:='aggmark.'||p_kpi.dim_set(i).dim_set||'.'||p_kpi.kpi||'.program';
    --for 10g, targets will need a separate program so it can run in parallel
    for j in 1..p_kpi.dim_set(i).dim.count loop
      l_dim_index(p_kpi.dim_set(i).dim(j).dim_name):=j;
      p_kpi.dim_set(i).dim(j).limit_cube:='kpi.'||p_kpi.kpi||'.'||p_kpi.dim_set(i).dim_set||'.'||p_kpi.dim_set(i).dim(j).dim_name||'.LB';
      p_kpi.dim_set(i).dim(j).reset_cube:='kpi.'||p_kpi.kpi||'.'||p_kpi.dim_set(i).dim_set||'.'||p_kpi.dim_set(i).dim(j).dim_name||'.RB';
      if nvl(bsc_aw_utility.get_parameter_value('NO LIMIT CUBE COMPOSITE'),'N')='N' then
        p_kpi.dim_set(i).dim(j).limit_cube_composite:='c.'||p_kpi.dim_set(i).dim(j).limit_cube;
      end if;
      p_kpi.dim_set(i).dim(j).aggregate_marker:='aggmark.'||p_kpi.kpi||'.'||p_kpi.dim_set(i).dim_set||'.'||p_kpi.dim_set(i).dim(j).dim_name;
      p_kpi.dim_set(i).dim(j).agg_map.agg_map:='aggmap.'||p_kpi.dim_set(i).dim(j).dim_name||'.'||p_kpi.dim_set(i).dim_set||'.'||p_kpi.kpi;
      p_kpi.dim_set(i).dim(j).agg_map.aggmap_operator:=p_kpi.dim_set(i).aggmap_operator;
    end loop;
    --std dim
    for j in 1..p_kpi.dim_set(i).std_dim.count loop
      l_dim_index(p_kpi.dim_set(i).std_dim(j).dim_name):=j;
      p_kpi.dim_set(i).std_dim(j).limit_cube:='kpi.'||p_kpi.kpi||'.'||p_kpi.dim_set(i).dim_set||'.'||p_kpi.dim_set(i).std_dim(j).dim_name||'.LB';
      if nvl(bsc_aw_utility.get_parameter_value('NO LIMIT CUBE COMPOSITE'),'N')='N' then
        p_kpi.dim_set(i).std_dim(j).limit_cube_composite:='c.'||p_kpi.dim_set(i).std_dim(j).limit_cube;
      end if;
    end loop;
    --time limit cube
    p_kpi.dim_set(i).calendar.limit_cube:='kpi.'||p_kpi.kpi||'.'||p_kpi.dim_set(i).dim_set||'.'||p_kpi.dim_set(i).calendar.aw_dim||'.LB';
    if nvl(bsc_aw_utility.get_parameter_value('NO LIMIT CUBE COMPOSITE'),'N')='N' then
      p_kpi.dim_set(i).calendar.limit_cube_composite:='c.'||p_kpi.dim_set(i).calendar.limit_cube;
    end if;
    p_kpi.dim_set(i).calendar.aggregate_marker:='aggmark.'||p_kpi.kpi||'.'||p_kpi.dim_set(i).dim_set||'.'||p_kpi.dim_set(i).calendar.aw_dim;
    /*also add aggmap for calendar. used to aggregate non bal measures uptime if bal measure also present in dimset */
    p_kpi.dim_set(i).calendar.agg_map.agg_map:='aggmap.'||p_kpi.dim_set(i).calendar.aw_dim||'.'||p_kpi.dim_set(i).dim_set||'.'||p_kpi.kpi;
    p_kpi.dim_set(i).calendar.agg_map.aggmap_operator:=p_kpi.dim_set(i).aggmap_operator;
    --measures
    --first, load the partition, composite and cube info
    --names partitions, composites, cubes and measure cubes
    create_PT_comp_names(p_kpi.kpi,p_kpi.dim_set(i));
    --
    for j in 1..p_kpi.dim_set(i).measure.count loop
      l_measure_index(p_kpi.dim_set(i).measure(j).measure):=j;
    end loop;
    --give cube names to data source measures
    for j in 1..p_kpi.dim_set(i).data_source.count loop
      for k in 1..p_kpi.dim_set(i).data_source(j).measure.count loop
        p_kpi.dim_set(i).data_source(j).measure(k).cube:=p_kpi.dim_set(i).measure(l_measure_index(p_kpi.dim_set(i).data_source(j).measure(k).measure)).cube;
        p_kpi.dim_set(i).data_source(j).measure(k).property:=
        p_kpi.dim_set(i).measure(l_measure_index(p_kpi.dim_set(i).data_source(j).measure(k).measure)).property;
      end loop;
      --set the dim limit cubes
      for k in 1..p_kpi.dim_set(i).data_source(j).dim.count loop
        p_kpi.dim_set(i).data_source(j).dim(k).limit_cube:=
        p_kpi.dim_set(i).dim(l_dim_index(p_kpi.dim_set(i).data_source(j).dim(k).dim_name)).limit_cube;
      end loop;
      for k in 1..p_kpi.dim_set(i).data_source(j).std_dim.count loop
        p_kpi.dim_set(i).data_source(j).std_dim(k).limit_cube:=
        p_kpi.dim_set(i).std_dim(l_dim_index(p_kpi.dim_set(i).data_source(j).std_dim(k).dim_name)).limit_cube;
      end loop;
      p_kpi.dim_set(i).data_source(j).calendar.limit_cube:=p_kpi.dim_set(i).calendar.limit_cube;
    end loop;
    for j in 1..p_kpi.dim_set(i).inc_data_source.count loop
      for k in 1..p_kpi.dim_set(i).inc_data_source(j).measure.count loop
        p_kpi.dim_set(i).inc_data_source(j).measure(k).cube:=p_kpi.dim_set(i).measure(
        l_measure_index(p_kpi.dim_set(i).inc_data_source(j).measure(k).measure)).cube;
        p_kpi.dim_set(i).inc_data_source(j).measure(k).property:=p_kpi.dim_set(i).measure(
        l_measure_index(p_kpi.dim_set(i).inc_data_source(j).measure(k).measure)).property;
      end loop;
      for k in 1..p_kpi.dim_set(i).inc_data_source(j).dim.count loop
        p_kpi.dim_set(i).inc_data_source(j).dim(k).limit_cube:=
        p_kpi.dim_set(i).dim(l_dim_index(p_kpi.dim_set(i).inc_data_source(j).dim(k).dim_name)).limit_cube;
      end loop;
      for k in 1..p_kpi.dim_set(i).inc_data_source(j).std_dim.count loop
        p_kpi.dim_set(i).inc_data_source(j).std_dim(k).limit_cube:=
        p_kpi.dim_set(i).std_dim(l_dim_index(p_kpi.dim_set(i).inc_data_source(j).std_dim(k).dim_name)).limit_cube;
      end loop;
      p_kpi.dim_set(i).inc_data_source(j).calendar.limit_cube:=p_kpi.dim_set(i).calendar.limit_cube;
    end loop;
    --targets only have cubes, limit cubes and load programs
    if p_kpi.dim_set(i).targets_higher_levels='Y' then
      p_kpi.target_dim_set(i).agg_map.agg_map:=null;
      --
      p_kpi.target_dim_set(i).initial_load_program.program_name:=p_kpi.dim_set(i).initial_load_program.program_name||'.tgt';
      p_kpi.target_dim_set(i).inc_load_program.program_name:=p_kpi.dim_set(i).inc_load_program.program_name||'.tgt';
      p_kpi.target_dim_set(i).initial_load_program_parallel.program_name:=p_kpi.dim_set(i).initial_load_program_parallel.program_name||'.tgt';
      p_kpi.target_dim_set(i).inc_load_program_parallel.program_name:=p_kpi.dim_set(i).inc_load_program_parallel.program_name||'.tgt';
      --for 10g, targets will need a separate program so it can run in parallel
      for j in 1..p_kpi.target_dim_set(i).dim.count loop
        p_kpi.target_dim_set(i).dim(j).limit_cube:=p_kpi.dim_set(i).dim(j).limit_cube||'.tgt';
        if nvl(bsc_aw_utility.get_parameter_value('NO LIMIT CUBE COMPOSITE'),'N')='N' then
          p_kpi.target_dim_set(i).dim(j).limit_cube_composite:='c.'||p_kpi.target_dim_set(i).dim(j).limit_cube;
        end if;
      end loop;
      --std dim
      for j in 1..p_kpi.target_dim_set(i).std_dim.count loop
        p_kpi.target_dim_set(i).std_dim(j).limit_cube:=p_kpi.dim_set(i).std_dim(j).limit_cube||'.tgt';
        if nvl(bsc_aw_utility.get_parameter_value('NO LIMIT CUBE COMPOSITE'),'N')='N' then
          p_kpi.target_dim_set(i).std_dim(j).limit_cube_composite:='c.'||p_kpi.target_dim_set(i).std_dim(j).limit_cube;
        end if;
      end loop;
      --time limit cube
      p_kpi.target_dim_set(i).calendar.limit_cube:=p_kpi.dim_set(i).calendar.limit_cube||'.tgt';
      if nvl(bsc_aw_utility.get_parameter_value('NO LIMIT CUBE COMPOSITE'),'N')='N' then
        p_kpi.target_dim_set(i).calendar.limit_cube_composite:='c.'||p_kpi.target_dim_set(i).calendar.limit_cube;
      end if;
      --
      create_PT_comp_names(p_kpi.kpi,p_kpi.target_dim_set(i));
      --give cube names to data source measures
      for j in 1..p_kpi.target_dim_set(i).data_source.count loop
        for k in 1..p_kpi.target_dim_set(i).data_source(j).measure.count loop
          p_kpi.target_dim_set(i).data_source(j).measure(k).cube:=p_kpi.target_dim_set(i).measure(l_measure_index(p_kpi.target_dim_set(i).data_source(j).measure(k).measure)).cube;
          p_kpi.target_dim_set(i).data_source(j).measure(k).property:=
          p_kpi.target_dim_set(i).measure(l_measure_index(p_kpi.target_dim_set(i).data_source(j).measure(k).measure)).property;
        end loop;
        --set the dim limit cubes
        for k in 1..p_kpi.target_dim_set(i).data_source(j).dim.count loop
          p_kpi.target_dim_set(i).data_source(j).dim(k).limit_cube:=
          p_kpi.target_dim_set(i).dim(l_dim_index(p_kpi.target_dim_set(i).data_source(j).dim(k).dim_name)).limit_cube;
        end loop;
        for k in 1..p_kpi.target_dim_set(i).data_source(j).std_dim.count loop
          p_kpi.target_dim_set(i).data_source(j).std_dim(k).limit_cube:=
          p_kpi.target_dim_set(i).std_dim(l_dim_index(p_kpi.target_dim_set(i).data_source(j).std_dim(k).dim_name)).limit_cube;
        end loop;
        p_kpi.target_dim_set(i).data_source(j).calendar.limit_cube:=p_kpi.target_dim_set(i).calendar.limit_cube;
      end loop;
      for j in 1..p_kpi.target_dim_set(i).inc_data_source.count loop
        for k in 1..p_kpi.target_dim_set(i).inc_data_source(j).measure.count loop
          p_kpi.target_dim_set(i).inc_data_source(j).measure(k).cube:=p_kpi.target_dim_set(i).measure(
          l_measure_index(p_kpi.target_dim_set(i).inc_data_source(j).measure(k).measure)).cube;
          p_kpi.target_dim_set(i).inc_data_source(j).measure(k).property:=p_kpi.target_dim_set(i).measure(
          l_measure_index(p_kpi.target_dim_set(i).inc_data_source(j).measure(k).measure)).property;
        end loop;
        for k in 1..p_kpi.target_dim_set(i).inc_data_source(j).dim.count loop
          p_kpi.target_dim_set(i).inc_data_source(j).dim(k).limit_cube:=
          p_kpi.target_dim_set(i).dim(l_dim_index(p_kpi.target_dim_set(i).inc_data_source(j).dim(k).dim_name)).limit_cube;
        end loop;
        for k in 1..p_kpi.target_dim_set(i).inc_data_source(j).std_dim.count loop
          p_kpi.target_dim_set(i).inc_data_source(j).std_dim(k).limit_cube:=
          p_kpi.target_dim_set(i).std_dim(l_dim_index(p_kpi.target_dim_set(i).inc_data_source(j).std_dim(k).dim_name)).limit_cube;
        end loop;
        p_kpi.target_dim_set(i).inc_data_source(j).calendar.limit_cube:=p_kpi.target_dim_set(i).calendar.limit_cube;
      end loop;
    end if;
  end loop;
Exception when others then
  log_n('Exception in create_aw_object_names '||sqlerrm);
  raise;
End;

/*
this procedure names the partitions , composites.
p_dimset cane be actual or target  for target, dim_set_name contains .tgt at the end
with the display cube concept, create_PT_comp_names must be called only after compressed composite parameters and partition parameters
are set
*/
procedure create_PT_comp_names(p_kpi varchar2,p_dimset in out nocopy dim_set_r) is
l_kpi varchar2(100); --just used to name objects
l_composite_name varchar2(200);
l_countvar_flag boolean;
composite_index bsc_aw_utility.number_table;
Begin
  l_kpi:=p_kpi;
  if p_dimset.dim_set_type='target' then
    l_kpi:=l_kpi||'.tgt';
  end if;
  --measurename_dim cannot be null
  /*
  measurename muct be shared by the tgt and actual. otherwise, data is not copied correctly.
  so also partition dim
  note>>> for measurename, we use p_kpi, not l_kpi
  */
  p_dimset.measurename_dim:='measurename.'||p_dimset.dim_set||'.'||p_kpi;
  l_composite_name:='comp.'||p_dimset.dim_set||'.'||l_kpi;
  --
  l_countvar_flag:=check_countvar_cube_needed(p_dimset);
  if bsc_aw_utility.get_db_version >=10 and nvl(bsc_aw_utility.get_parameter_value('NO DATACUBE'),'N')='N' then
    --
    p_dimset.cube_design:='datacube';
    if p_dimset.number_partitions>0 then
      --dimset can have multiple partition templates to support PT for countvar cubes when we have to use compressed composites
      /*copy the info from master partition template. master_partition_template(1) is for datacubes */
      p_dimset.partition_template(1):=p_dimset.master_partition_template(1);
      p_dimset.partition_template(1).template_name:='PT.'||p_dimset.dim_set||'.'||l_kpi;
      for i in 1..p_dimset.number_partitions loop --partitions are named P0, P1 etc. name starts with "0"
        p_dimset.composite(p_dimset.composite.count+1).composite_name:=l_composite_name||'.'||(i-1);
        if p_dimset.compressed='N' then
          p_dimset.composite(p_dimset.composite.count).composite_type:='non compressed';
        else
          p_dimset.composite(p_dimset.composite.count).composite_type:='compressed';
        end if;
        composite_index('cube'||i):=p_dimset.composite.count;
        --we cannot have compressed composites when we have targets at higher levels since we cannot copy data into higher levels
        --from targets to the actuals
        --
        p_dimset.partition_template(1).template_partitions(i).partition_name:='P.'||(i-1);
        p_dimset.partition_template(1).template_partitions(i).partition_dim_value:=to_char(i-1);
        p_dimset.partition_template(1).template_partitions(i).partition_axis.delete;
        p_dimset.partition_template(1).template_partitions(i).partition_axis(1).axis_name:=p_dimset.partition_template(1).template_dim;
        p_dimset.partition_template(1).template_partitions(i).partition_axis(1).axis_type:='dimension';
        p_dimset.partition_template(1).template_partitions(i).partition_axis(
        p_dimset.partition_template(1).template_partitions(i).partition_axis.count+1).axis_name:=p_dimset.measurename_dim;
        p_dimset.partition_template(1).template_partitions(i).partition_axis(
        p_dimset.partition_template(1).template_partitions(i).partition_axis.count).axis_type:='dimension';
        p_dimset.partition_template(1).template_partitions(i).partition_axis(
        p_dimset.partition_template(1).template_partitions(i).partition_axis.count+1).axis_name:=
        p_dimset.composite(composite_index('cube'||i)).composite_name;
        p_dimset.partition_template(1).template_partitions(i).partition_axis(
        p_dimset.partition_template(1).template_partitions(i).partition_axis.count).axis_type:='composite';
      end loop;
      --if there is countvar and compressed composite, we create separate PT for countvar cube . this is not supported now
      --by AW. but in case in the future we have it...
      if l_countvar_flag and p_dimset.compressed='Y' then
        p_dimset.partition_template(2):=p_dimset.master_partition_template(1);
        p_dimset.partition_template(2).template_name:='PT.'||p_dimset.dim_set||'.'||l_kpi||'.countvar';
        for i in 1..p_dimset.number_partitions loop --partitions are named P0, P1 etc. name starts with "0"
          p_dimset.composite(p_dimset.composite.count+1).composite_name:=l_composite_name||'.'||(i-1)||'.countvar';
          if p_dimset.compressed='N' then
            p_dimset.composite(p_dimset.composite.count).composite_type:='non compressed';
          else
            p_dimset.composite(p_dimset.composite.count).composite_type:='compressed';
          end if;
          composite_index('countvar'||i):=p_dimset.composite.count;
          p_dimset.partition_template(2).template_partitions(i).partition_name:='P.'||(i-1);
          p_dimset.partition_template(2).template_partitions(i).partition_dim_value:=to_char(i-1);
          p_dimset.partition_template(2).template_partitions(i).partition_axis.delete;
          p_dimset.partition_template(2).template_partitions(i).partition_axis(1).axis_name:=p_dimset.partition_template(2).template_dim;
          p_dimset.partition_template(2).template_partitions(i).partition_axis(1).axis_type:='dimension';
          p_dimset.partition_template(2).template_partitions(i).partition_axis(
          p_dimset.partition_template(2).template_partitions(i).partition_axis.count+1).axis_name:=p_dimset.measurename_dim;
          p_dimset.partition_template(2).template_partitions(i).partition_axis(
          p_dimset.partition_template(2).template_partitions(i).partition_axis.count).axis_type:='dimension';
          p_dimset.partition_template(2).template_partitions(i).partition_axis(
          p_dimset.partition_template(2).template_partitions(i).partition_axis.count+1).axis_name:=
          p_dimset.composite(composite_index('countvar'||i)).composite_name;
          p_dimset.partition_template(2).template_partitions(i).partition_axis(
          p_dimset.partition_template(2).template_partitions(i).partition_axis.count).axis_type:='composite';
        end loop;
      end if;
    else --this is 10g, but there are no partitions
      --10g will have datacube.
      p_dimset.composite(1).composite_name:=l_composite_name;
      if p_dimset.compressed='N' then
        p_dimset.composite(1).composite_type:='non compressed';
      else
        p_dimset.composite(1).composite_type:='compressed';
      end if;
      composite_index('cube'):=1;
      if l_countvar_flag and p_dimset.compressed='Y' then
        p_dimset.composite(2).composite_name:=l_composite_name||'.countvar';
        if p_dimset.compressed='N' then
          p_dimset.composite(2).composite_type:='non compressed';
        else
          p_dimset.composite(2).composite_type:='compressed';
        end if;
        composite_index('countvar'):=2;
      end if;
    end if;
    --cubes
    /*
    we need algo to decide the datatype. for now, we go with number
    */
    p_dimset.cube_set(1).cube_set_name:='cube set.'||p_dimset.dim_set_name||'.1';
    p_dimset.cube_set(1).cube_set_type:='datacube';
    p_dimset.cube_set(1).cube.cube_name:='datacube.'||p_dimset.dim_set||'.'||l_kpi;
    p_dimset.cube_set(1).cube.cube_datatype:='number';
    p_dimset.cube_set(1).fcst_cube.cube_name:=p_dimset.cube_set(1).cube.cube_name||'.fcst';
    p_dimset.cube_set(1).fcst_cube.cube_datatype:='number';
    if l_countvar_flag then
      if bsc_aw_utility.get_property(p_dimset.property,'aggcount').property_value='Y' then
        null;
      else
        p_dimset.cube_set(1).countvar_cube.cube_name:=p_dimset.cube_set(1).cube.cube_name||'.countvar'; --countvar not used in targets
        p_dimset.cube_set(1).countvar_cube.cube_datatype:='integer';
      end if;
    end if;
    p_dimset.cube_set(1).measurename_dim:=p_dimset.measurename_dim;
    for i in 1..p_dimset.measure.count loop
      p_dimset.measure(i).cube:=p_dimset.cube_set(1).cube.cube_name;
      p_dimset.measure(i).fcst_cube:=p_dimset.cube_set(1).fcst_cube.cube_name;
      --if there is one measure with avg, we need countvar for all cubes
      if p_dimset.cube_set(1).countvar_cube.cube_name is not null then
        p_dimset.measure(i).countvar_cube:=p_dimset.cube_set(1).countvar_cube.cube_name;
      end if;
      p_dimset.measure(i).aw_formula.formula_name:=p_dimset.measure(i).measure||'.'||p_dimset.dim_set||'.'||l_kpi;
      p_dimset.measure(i).aw_formula.formula_expression:=p_dimset.measure(i).cube||'('||p_dimset.measurename_dim||' '''||
      p_dimset.measure(i).measure||''')';
    end loop;
    /*if we have partitions and this is compressed composite, we have a problem when we need to aggregate data on the fly. compressed
    composites cannot be limited in dim status and aggregated. this means we will copy the data into a display cube and then aggregate the display
    cube. the view runs off the display cube. for now, we have no composites for the display cube. it must have all the dim of the cube including
    partition dim. this name must also be added to measuredim for aggregation
    display cube axis is set in create_cube. we need to make sure that display cube axis has the same dim in the same order as that of the cube*/
    if is_display_cube_required(p_dimset,p_dimset.cube_set(1).cube.cube_name) then
      p_dimset.cube_set(1).display_cube.cube_name:=p_dimset.cube_set(1).cube.cube_name||'.disp';
      p_dimset.cube_set(1).display_cube.cube_type:=p_dimset.cube_set(1).cube.cube_type;
      p_dimset.cube_set(1).display_cube.cube_datatype:=p_dimset.cube_set(1).cube.cube_datatype;
      /*display cube will have its composite */
      p_dimset.composite(p_dimset.composite.count+1).composite_name:='c.'||p_dimset.cube_set(1).display_cube.cube_name;
      p_dimset.composite(p_dimset.composite.count).composite_type:='non compressed';
      composite_index('display'):=p_dimset.composite.count;
      /*no partition dim for display cube. in the reader,we copy from main cube to display cube. display=main cube
      since there is no node duplication across partitions, when data is copied into the display cube, there is no overwriting
      so display cube does not need partition dim. this means we can implement avg measure also with display cubes */
      p_dimset.cube_set(1).display_cube.cube_axis(1).axis_name:=p_dimset.measurename_dim;
      p_dimset.cube_set(1).display_cube.cube_axis(1).axis_type:='dimension';
      p_dimset.cube_set(1).display_cube.cube_axis(2).axis_name:=p_dimset.composite(composite_index('display')).composite_name;
      p_dimset.cube_set(1).display_cube.cube_axis(2).axis_type:='composite';
    end if;
    /*set the display cube properties for the measures */
    for i in 1..p_dimset.measure.count loop
      p_dimset.measure(i).display_cube:=p_dimset.cube_set(1).display_cube.cube_name;
      if p_dimset.measure(i).display_cube is not null then /*partitions with CC or avg agg or non-sql-agg formula */
        p_dimset.measure(i).aw_formula.formula_expression:=p_dimset.measure(i).display_cube||'('||p_dimset.measurename_dim||' '''||
        p_dimset.measure(i).measure||''')';
      end if;
    end loop;
    /* */
    if p_dimset.number_partitions>0 then
      --here countvar cube and regular cube share the partition since the partition is non compressed
      p_dimset.cube_set(1).cube.cube_axis(1).axis_name:=p_dimset.partition_template(1).template_name;
      p_dimset.cube_set(1).cube.cube_axis(1).axis_type:='partition template';
      if p_dimset.cube_set(1).countvar_cube.cube_name is not null then
        if p_dimset.compressed='Y' then
          p_dimset.cube_set(1).countvar_cube.cube_axis(1).axis_name:=p_dimset.partition_template(2).template_name;
        else
          p_dimset.cube_set(1).countvar_cube.cube_axis(1).axis_name:=p_dimset.partition_template(1).template_name;
        end if;
        p_dimset.cube_set(1).countvar_cube.cube_axis(1).axis_type:='partition template';
      end if;
      --we dont populate the fcst cubes for now
    else --10g but with no partitions
      --here countvar cube and regular cube share the partition since the partition is non compressed
      p_dimset.cube_set(1).cube.cube_axis(1).axis_name:=p_dimset.measurename_dim;
      p_dimset.cube_set(1).cube.cube_axis(1).axis_type:='dimension';
      p_dimset.cube_set(1).cube.cube_axis(2).axis_name:=p_dimset.composite(composite_index('cube')).composite_name;
      p_dimset.cube_set(1).cube.cube_axis(2).axis_type:='composite';
      if p_dimset.cube_set(1).countvar_cube.cube_name is not null then
        p_dimset.cube_set(1).countvar_cube.cube_axis(1).axis_name:=p_dimset.measurename_dim;
        p_dimset.cube_set(1).countvar_cube.cube_axis(1).axis_type:='dimension';
        if p_dimset.compressed='Y' then
          p_dimset.cube_set(1).countvar_cube.cube_axis(2).axis_name:=p_dimset.composite(composite_index('countvar')).composite_name;
        else
          p_dimset.cube_set(1).countvar_cube.cube_axis(2).axis_name:=p_dimset.composite(composite_index('cube')).composite_name;
        end if;
        p_dimset.cube_set(1).countvar_cube.cube_axis(2).axis_type:='composite';
      end if;
      --we dont populate the fcst cubes for now
    end if;
  else --9i no compressed composite in 9i
    --no partitions  1 composite , multiple cubes at measure level
    p_dimset.composite(1).composite_name:=l_composite_name;
    p_dimset.composite(1).composite_type:='non compressed';
    composite_index('cube'):=1;
    p_dimset.cube_design:='single composite';
    p_dimset.compressed:='N';
    for i in 1..p_dimset.measure.count loop
      p_dimset.cube_set(i).cube_set_name:='cube set.'||p_dimset.dim_set_name||'.'||i;
      p_dimset.cube_set(i).cube_set_type:='measurecube';
      p_dimset.cube_set(i).cube.cube_name:=p_dimset.measure(i).measure||'.'||p_dimset.dim_set||'.'||l_kpi;
      p_dimset.cube_set(i).cube.cube_datatype:=p_dimset.measure(i).data_type;
      p_dimset.cube_set(i).fcst_cube.cube_name:=p_dimset.cube_set(i).cube.cube_name||'.fcst';
      p_dimset.cube_set(i).fcst_cube.cube_datatype:=p_dimset.measure(i).data_type;
      if l_countvar_flag then
        p_dimset.cube_set(i).countvar_cube.cube_name:=p_dimset.cube_set(i).cube.cube_name||'.countvar';
        p_dimset.cube_set(i).countvar_cube.cube_datatype:='integer';
      end if;
      --
      p_dimset.cube_set(i).measurename_dim:=p_dimset.measurename_dim;
      --
      p_dimset.cube_set(i).cube.cube_axis(1).axis_name:=p_dimset.composite(composite_index('cube')).composite_name;
      p_dimset.cube_set(i).cube.cube_axis(1).axis_type:='composite';
      if p_dimset.cube_set(i).countvar_cube.cube_name is not null then
        p_dimset.cube_set(i).countvar_cube.cube_axis(1).axis_name:=p_dimset.composite(composite_index('cube')).composite_name;
        p_dimset.cube_set(i).countvar_cube.cube_axis(1).axis_type:='composite';
      end if;
      --dont populate the fcst cube for now
      --
      p_dimset.measure(i).cube:=p_dimset.cube_set(i).cube.cube_name;
      if p_dimset.cube_set(i).countvar_cube.cube_name is not null then
        p_dimset.measure(i).countvar_cube:=p_dimset.cube_set(i).countvar_cube.cube_name;
      end if;
      p_dimset.measure(i).fcst_cube:=p_dimset.cube_set(i).fcst_cube.cube_name;
      --
    end loop;
    /*if there are period cubes and year cubes then create the extra cubes for these objects*/
    for i in 1..p_dimset.measure.count loop
      for j in 1..p_dimset.measure(i).property.count loop
        if p_dimset.measure(i).property(j).property_name='period cube' or p_dimset.measure(i).property(j).property_name='year cube' then
          p_dimset.cube_set(p_dimset.cube_set.count+1).cube_set_name:='cube set.'||p_dimset.dim_set_name||'.'||
          p_dimset.measure(i).property(j).property_name||'.'||i||'.'||j;
          p_dimset.cube_set(p_dimset.cube_set.count).cube_set_type:='measurecube';
          p_dimset.cube_set(p_dimset.cube_set.count).cube.cube_name:=p_dimset.measure(i).property(j).property_value||'.'||
          p_dimset.dim_set||'.'||l_kpi;
          /*set the property name to reflect the correct cube name*/
          p_dimset.measure(i).property(j).property_value:=p_dimset.cube_set(p_dimset.cube_set.count).cube.cube_name;
          p_dimset.cube_set(p_dimset.cube_set.count).cube.cube_datatype:=p_dimset.measure(i).data_type; /*should be number */
          p_dimset.cube_set(p_dimset.cube_set.count).measurename_dim:=p_dimset.measurename_dim;
          p_dimset.cube_set(p_dimset.cube_set.count).cube.cube_axis(1).axis_name:=p_dimset.composite(composite_index('cube')).composite_name;
          p_dimset.cube_set(p_dimset.cube_set.count).cube.cube_axis(1).axis_type:='composite';
          /*no fcst cubes or countvar cubes */
        end if;
      end loop;
    end loop;
  end if;
Exception when others then
  log_n('Exception in create_PT_comp_names '||sqlerrm);
  raise;
End;

/*
*/
procedure create_kpi_objects(p_kpi in out nocopy kpi_r) is
Begin
  for i in 1..p_kpi.dim_set.count loop
    create_kpi_objects(p_kpi,p_kpi.dim_set(i));
    if p_kpi.dim_set(i).targets_higher_levels='Y' then
      create_kpi_objects(p_kpi,p_kpi.target_dim_set(i));
    end if;
  end loop;
Exception when others then
  log_n('Exception in create_kpi_objects '||sqlerrm);
  raise;
End;

/*
composite name : comp_dimset_kpi
in the composite, the order of dim is
dim with no agg, no zero code
dim with no agg, zero code
dim with agg
rec dim
time
*/
procedure create_kpi_objects(
p_kpi kpi_r,
p_dim_set in out nocopy dim_set_r) is
l_comp varchar2(300);
Begin
  create_measure_dim(p_kpi,p_dim_set);
  create_composite(p_kpi,p_dim_set);
  create_partition_template(p_kpi,p_dim_set);
  create_cube(p_kpi,p_dim_set);
  create_measure_formula(p_kpi,p_dim_set);
  create_aggmap_operators(p_kpi,p_dim_set);
  create_agg_map(p_kpi,p_dim_set);
Exception when others then
  log_n('Exception in create_kpi_objects '||sqlerrm);
  raise;
End;

procedure create_measure_dim(
p_kpi kpi_r,
p_dim_set in out nocopy dim_set_r) is
l_pt_comp_type varchar2(100);
l_pt_comp varchar2(100);
l_partition_template partition_template_r;
l_stmt varchar2(2000);
Begin
  if g_debug then
    log_n('create_measure_dim, dimset='||p_dim_set.dim_set_name);
  end if;
  --if this is targets, we share the measuredim with the actuals. so no need to create it
  --actuals are created before targets. see procedure create_kpi_objects(p_kpi in out nocopy kpi_r) is
  if p_dim_set.dim_set_type <> 'target' then
    l_stmt:='dfn '||p_dim_set.measurename_dim||' dimension TEXT';
    bsc_aw_dbms_aw.execute(l_stmt);
    for i in 1..p_dim_set.measure.count loop
      l_stmt:='mnt '||p_dim_set.measurename_dim||' add '''||p_dim_set.measure(i).measure||'''';
      bsc_aw_dbms_aw.execute(l_stmt);
      if p_dim_set.measure(i).measure_type=g_balance_last_value_prop then
        for j in 1..p_dim_set.measure(i).property.count loop
          if p_dim_set.measure(i).property(j).property_name='period cube' or p_dim_set.measure(i).property(j).property_name='year cube' then
            l_stmt:='mnt '||p_dim_set.measurename_dim||' add '''||p_dim_set.measure(i).property(j).property_value||'''';
            bsc_aw_dbms_aw.execute(l_stmt);
          end if;
        end loop;
      end if;
    end loop;
  end if;
  --
  if p_dim_set.aggmap_operator.measure_dim is not null then
    l_stmt:='dfn '||p_dim_set.aggmap_operator.measure_dim||' dimension TEXT';
    bsc_aw_dbms_aw.execute(l_stmt);
    for i in 1..p_dim_set.cube_set.count loop
      l_stmt:='mnt '||p_dim_set.aggmap_operator.measure_dim||' add '''||p_dim_set.cube_set(i).cube.cube_name||'''';
      bsc_aw_dbms_aw.execute(l_stmt);
      if p_dim_set.cube_set(i).display_cube.cube_name is not null then
        l_stmt:='mnt '||p_dim_set.aggmap_operator.measure_dim||' add '''||p_dim_set.cube_set(i).display_cube.cube_name||'''';
        bsc_aw_dbms_aw.execute(l_stmt);
      end if;
      /*if the main cube is partitioned, we also add the cube partitions. with this, we can now say
      aggregate datacube.4.4014 (partition P.0) using aggmap.4.4014.notime for nonCC composites. earlier we were limiting the
      hash partition dim to ensure that only the specified partition got aggregated. but, all partitions ended up getting
      aggregated. if we specify datacube.4.4014 (partition P.0) , then only P.0 gets aggregated. but we need an entry for
      datacube.4.4014 (partition P.0) in opvar */
      l_pt_comp:=get_cube_pt_comp(p_dim_set.cube_set(i).cube.cube_name,p_dim_set,l_pt_comp_type);
      if l_pt_comp_type='partition template' then
        l_partition_template:=get_partition_template_r(l_pt_comp,p_dim_set);
        for j in 1..l_partition_template.template_partitions.count loop
          l_stmt:='mnt '||p_dim_set.aggmap_operator.measure_dim||' add '''||p_dim_set.cube_set(i).cube.cube_name||' (PARTITION '||
          l_partition_template.template_partitions(j).partition_name||')''';
          bsc_aw_dbms_aw.execute(l_stmt);
        end loop;
      end if;
    end loop;
  end if;
Exception when others then
  log_n('Exception in create_measure_dim '||sqlerrm);
  raise;
End;

function get_comp_dimensions(p_dim_set in out nocopy dim_set_r) return dbms_sql.varchar2_table is
--
l_comp_dimensions dbms_sql.varchar2_table;
Begin
  --first we have the dim on which are going to aggregate. confirmed with AW team. best to have the dim on which we are aggregating
  --ahead in the index. we will have time first
  l_comp_dimensions(l_comp_dimensions.count+1):=p_dim_set.calendar.aw_dim;
  --dim on which we aggregate
  for i in 1..p_dim_set.dim.count loop
    --if p_dim_set.dim(i).levels.count>1 or p_dim_set.dim(i).zero_code='Y' or p_dim_set.dim(i).recursive='Y' then
    if is_dim_aggregated(p_dim_set.dim(i)) then
      p_dim_set.dim(i).agg_map.created:='Y'; --from now, we will check this flag to see if we need to aggregate on this dim
      l_comp_dimensions(l_comp_dimensions.count+1):=p_dim_set.dim(i).dim_name;
    end if;
  end loop;
  --dim on which there is no agg
  for i in 1..p_dim_set.dim.count loop
    if p_dim_set.dim(i).agg_map.created is null or p_dim_set.dim(i).agg_map.created <> 'Y' then
      l_comp_dimensions(l_comp_dimensions.count+1):=p_dim_set.dim(i).dim_name;
    end if;
  end loop;
  --last have the std dim
  for i in 1..p_dim_set.std_dim.count loop
    l_comp_dimensions(l_comp_dimensions.count+1):=p_dim_set.std_dim(i).dim_name;
  end loop;
  return l_comp_dimensions;
Exception when others then
  log_n('Exception in get_comp_dimensions '||sqlerrm);
  raise;
End;

/*
composite name : comp_dimset_kpi
in the composite, the order of dim is
dim with no agg, no zero code
dim with no agg, zero code
dim with agg
rec dim
time
please note that the procedure set_dim_order has already set the dim in the correct order
*/
procedure create_composite(
p_kpi kpi_r,
p_dim_set in out nocopy dim_set_r) is
l_comp_created dbms_sql.varchar2_table;
l_comp_dimensions dbms_sql.varchar2_table;
Begin
  l_comp_dimensions:=get_comp_dimensions(p_dim_set);
  --first create the composites
  for i in 1..p_dim_set.composite.count loop
    if bsc_aw_utility.in_array(l_comp_created,p_dim_set.composite(i).composite_name)=false then
      p_dim_set.composite(i).composite_dimensions:=l_comp_dimensions;
      g_stmt:='dfn '||p_dim_set.composite(i).composite_name||' composite <';
      for j in 1..p_dim_set.composite(i).composite_dimensions.count loop
        g_stmt:=g_stmt||p_dim_set.composite(i).composite_dimensions(j)||' ';
      end loop;
      g_stmt:=g_stmt||'>';
      if p_dim_set.composite(i).composite_type='compressed' then
        g_stmt:=g_stmt||' compressed';
      end if;
      bsc_aw_dbms_aw.execute(g_stmt);
      l_comp_created(l_comp_created.count+1):=p_dim_set.composite(i).composite_name;
    end if;
  end loop;
Exception when others then
  log_n('Exception in create_composite '||sqlerrm);
  raise;
End;

/*
now, we only create list partitions, these list partitions are essentially hash partitions
*/
procedure create_partition_template(
p_kpi kpi_r,
p_dim_set in out nocopy dim_set_r) is
Begin
  --create the partitions
  for i in 1..p_dim_set.partition_template.count loop
    create_partition_template(p_kpi,p_dim_set,p_dim_set.partition_template(i));
 end loop;
Exception when others then
  log_n('Exception in create_partition '||sqlerrm);
  raise;
End;

procedure create_partition_template(
p_kpi kpi_r,
p_dim_set in out nocopy dim_set_r,
p_partition_template in out nocopy partition_template_r
) is
--
l_comp_dimensions dbms_sql.varchar2_table;
Begin
  if p_partition_template.template_name is not null then
    l_comp_dimensions:=get_comp_dimensions(p_dim_set);
    p_partition_template.template_dimensions(1):=p_partition_template.template_dim;
    p_partition_template.template_dimensions(p_partition_template.template_dimensions.count+1):=p_dim_set.measurename_dim;
    for i in 1..l_comp_dimensions.count loop
      p_partition_template.template_dimensions(p_partition_template.template_dimensions.count+1):=l_comp_dimensions(i);
    end loop;
    g_stmt:='dfn '||p_partition_template.template_name||' PARTITION TEMPLATE <';
    for i in 1..p_partition_template.template_dimensions.count loop
      g_stmt:=g_stmt||' '||p_partition_template.template_dimensions(i);
    end loop;
    g_stmt:=g_stmt||'> -'||bsc_aw_utility.g_newline;
    g_stmt:=g_stmt||'partition by '||p_partition_template.template_type||' ('||p_partition_template.template_dim||') -'||bsc_aw_utility.g_newline;
    g_stmt:=g_stmt||'( -'||bsc_aw_utility.g_newline;
    for i in 1..p_partition_template.template_partitions.count loop
      g_stmt:=g_stmt||'PARTITION '||p_partition_template.template_partitions(i).partition_name||' VALUES ('||
      p_partition_template.template_partitions(i).partition_dim_value||') <';
      for j in 1..p_partition_template.template_partitions(i).partition_axis.count loop
        g_stmt:=g_stmt||' '||p_partition_template.template_partitions(i).partition_axis(j).axis_name;
        if p_partition_template.template_partitions(i).partition_axis(j).axis_type='composite' then --mention the composite dim also
          l_comp_dimensions:=get_composite_r(p_partition_template.template_partitions(i).partition_axis(j).axis_name,p_dim_set).composite_dimensions;
          g_stmt:=g_stmt||'<';
          for k in 1..l_comp_dimensions.count loop
            g_stmt:=g_stmt||' '||l_comp_dimensions(k);
          end loop;
          g_stmt:=g_stmt||'>';
        end if;
      end loop;
      g_stmt:=g_stmt||'> -'||bsc_aw_utility.g_newline;
    end loop;
    g_stmt:=g_stmt||')';
    bsc_aw_dbms_aw.execute(g_stmt);
  end if;
Exception when others then
  log_n('Exception in create_partition_template '||sqlerrm);
  raise;
End;

procedure create_cube(
p_kpi kpi_r,
p_dim_set in out nocopy dim_set_r) is
--
l_lc_axis varchar2(400);
Begin
  for i in 1..p_dim_set.cube_set.count loop
    create_cube(p_kpi,p_dim_set,p_dim_set.cube_set(i).cube);
    if p_dim_set.cube_set(i).countvar_cube.cube_name is not null then
      create_cube(p_kpi,p_dim_set,p_dim_set.cube_set(i).countvar_cube);
    end if;
    if p_dim_set.cube_set(i).display_cube.cube_name is not null then
      --create_cube(p_kpi,p_dim_set,p_dim_set.cube_set(i).display_cube,make_display_cube_axis(p_dim_set,p_dim_set.cube_set(i).cube));
      create_cube(p_kpi,p_dim_set,p_dim_set.cube_set(i).display_cube);
    end if;
    --we do not create the fcst cube now
  end loop;
  --create the limit cubes
  for i in 1..p_dim_set.dim.count loop
    --create the composite
    if p_dim_set.dim(i).limit_cube_composite is not null then
      g_stmt:='dfn '||p_dim_set.dim(i).limit_cube_composite||' composite <'||p_dim_set.dim(i).dim_name||'>';
      bsc_aw_dbms_aw.execute(g_stmt);
      l_lc_axis:=p_dim_set.dim(i).limit_cube_composite||'<'||p_dim_set.dim(i).dim_name||'>';
    else
      l_lc_axis:=p_dim_set.dim(i).dim_name;
    end if;
    g_stmt:='dfn '||p_dim_set.dim(i).limit_cube||' variable boolean <'||l_lc_axis||'>';
    bsc_aw_dbms_aw.execute(g_stmt);
    if p_dim_set.dim(i).reset_cube is not null then
      g_stmt:='dfn '||p_dim_set.dim(i).reset_cube||' variable boolean <'||l_lc_axis||'>';
      bsc_aw_dbms_aw.execute(g_stmt);
    end if;
    if p_dim_set.dim(i).aggregate_marker is not null then
      g_stmt:='dfn '||p_dim_set.dim(i).aggregate_marker||' boolean';
      bsc_aw_dbms_aw.execute(g_stmt);
      g_stmt:=p_dim_set.dim(i).aggregate_marker||'=false';
      bsc_aw_dbms_aw.execute(g_stmt);
    end if;
  end loop;
  --std dim
  for i in 1..p_dim_set.std_dim.count loop
    if p_dim_set.std_dim(i).limit_cube_composite is not null then
      g_stmt:='dfn '||p_dim_set.std_dim(i).limit_cube_composite||' composite <'||p_dim_set.std_dim(i).dim_name||'>';
      bsc_aw_dbms_aw.execute(g_stmt);
      l_lc_axis:=p_dim_set.std_dim(i).limit_cube_composite||'<'||p_dim_set.std_dim(i).dim_name||'>';
    else
      l_lc_axis:=p_dim_set.std_dim(i).dim_name;
    end if;
    g_stmt:='dfn '||p_dim_set.std_dim(i).limit_cube||' variable boolean <'||l_lc_axis||'>';
    bsc_aw_dbms_aw.execute(g_stmt);
  end loop;
  --limit cube for time dim
  if p_dim_set.calendar.limit_cube_composite is not null then
    g_stmt:='dfn '||p_dim_set.calendar.limit_cube_composite||' composite <'||p_dim_set.calendar.aw_dim||'>';
    bsc_aw_dbms_aw.execute(g_stmt);
    l_lc_axis:=p_dim_set.calendar.limit_cube_composite||'<'||p_dim_set.calendar.aw_dim||'>';
  else
    l_lc_axis:=p_dim_set.calendar.aw_dim;
  end if;
  g_stmt:='dfn '||p_dim_set.calendar.limit_cube||' variable boolean <'||l_lc_axis||'>';
  bsc_aw_dbms_aw.execute(g_stmt);
  if p_dim_set.calendar.aggregate_marker is not null then
    g_stmt:='dfn '||p_dim_set.calendar.aggregate_marker||' boolean';
    bsc_aw_dbms_aw.execute(g_stmt);
  end if;
Exception when others then
  log_n('Exception in create_cube '||sqlerrm);
  raise;
End;

procedure create_cube(
p_kpi kpi_r,
p_dim_set dim_set_r,
p_cube cube_r) is
Begin
 create_cube(p_kpi,p_dim_set,p_cube,p_cube.cube_axis);
Exception when others then
  log_n('Exception in create_cube '||sqlerrm);
  raise;
End;

procedure create_cube(p_kpi kpi_r,p_dim_set dim_set_r,p_cube cube_r,p_cube_axis axis_tb) is
l_stmt varchar2(4000);
l_dimensions dbms_sql.varchar2_table;
Begin
  l_stmt:='dfn '||p_cube.cube_name||' '||p_cube.cube_datatype||'<';
  for i in 1..p_cube_axis.count loop
    l_stmt:=l_stmt||' '||p_cube_axis(i).axis_name;
    l_dimensions.delete;
    if p_cube_axis(i).axis_type='partition template' then
      l_dimensions:=get_partition_template_r(p_cube_axis(i).axis_name,p_dim_set).template_dimensions;
    elsif p_cube_axis(i).axis_type='composite' then
      l_dimensions:=get_composite_r(p_cube_axis(i).axis_name,p_dim_set).composite_dimensions;
    else --dimension
      null; --no action reqd
    end if;
    if l_dimensions.count>0 then
      l_stmt:=l_stmt||' <';
      for j in 1..l_dimensions.count loop
        l_stmt:=l_stmt||' '||l_dimensions(j);
      end loop;
      l_stmt:=l_stmt||' >';
    end if;
  end loop;
  l_stmt:=l_stmt||' >';
  if bsc_aw_utility.get_property(p_dim_set.property,'aggcount').property_value='Y' then
    l_stmt:=l_stmt||' WITH AGGCOUNT';
  end if;
  bsc_aw_dbms_aw.execute(l_stmt);
Exception when others then
  log_n('Exception in create_cube '||sqlerrm);
  raise;
End;

procedure create_measure_formula(
p_kpi kpi_r,
p_dim_set in out nocopy dim_set_r) is
Begin
  for i in 1..p_dim_set.measure.count loop
    if p_dim_set.measure(i).aw_formula.formula_name is not null then
      g_stmt:='dfn '||p_dim_set.measure(i).aw_formula.formula_name||' formula '||p_dim_set.measure(i).aw_formula.formula_expression;
      bsc_aw_dbms_aw.execute(g_stmt);
    end if;
  end loop;
Exception when others then
  log_n('Exception in create_measure_formula '||sqlerrm);
  raise;
End;

/*
aggregation is performed if
1. dim.levels.count>1
2. zero code=Y
3. recursive=Y
*/
procedure create_agg_map(
p_kpi kpi_r,
p_dim_set in out nocopy dim_set_r) is
--
l_flag boolean;
Begin
  if p_dim_set.agg_map.agg_map is not null then
    p_dim_set.agg_map.property:='normal';
    p_dim_set.agg_map_notime.property:='notime';
    create_agg_map(p_dim_set,p_dim_set.agg_map);
    create_agg_map(p_dim_set,p_dim_set.agg_map_notime);
    ----agg maps for individual dims
    --we create agg map for each individual dim for use in on-line agg. we create it with opvar, argvar and measure dim
    --if the dimset has 4 cubes and we want to agg only 1, we will limit p_agg_map.measure_dim to just that cube
    for i in 1..p_dim_set.dim.count loop
      if p_dim_set.dim(i).agg_map.created='Y' then --create_composite has already set this flag
        g_commands.delete;
        bsc_aw_utility.add_g_commands(g_commands,'dfn '||p_dim_set.dim(i).agg_map.agg_map||' aggmap ');
        bsc_aw_utility.add_g_commands(g_commands,'relation '||p_dim_set.dim(i).relation_name||' OPERATOR '||
        p_dim_set.dim(i).agg_map.aggmap_operator.opvar||' ARGS '||p_dim_set.dim(i).agg_map.aggmap_operator.argvar);
        bsc_aw_utility.add_g_commands(g_commands,'MEASUREDIM '||p_dim_set.dim(i).agg_map.aggmap_operator.measure_dim);
        bsc_aw_utility.exec_aggmap_commands(p_dim_set.dim(i).agg_map.agg_map,g_commands);
        /*had aggindex=no. from olap doc, if aggindex=no, then dim outside the composite are aggregated on the fly when natrigger property
        is set. for us, all dim are in composite. so no need to have this */
      end if;
    end loop;
    /*create aggmap of calendar */
    g_commands.delete;
    bsc_aw_utility.add_g_commands(g_commands,'dfn '||p_dim_set.calendar.agg_map.agg_map||' aggmap ');
    bsc_aw_utility.add_g_commands(g_commands,'relation '||p_dim_set.calendar.relation_name||' OPERATOR '||
    p_dim_set.calendar.agg_map.aggmap_operator.opvar||' ARGS '||p_dim_set.calendar.agg_map.aggmap_operator.argvar);
    bsc_aw_utility.add_g_commands(g_commands,'MEASUREDIM '||p_dim_set.calendar.agg_map.aggmap_operator.measure_dim);
    bsc_aw_utility.exec_aggmap_commands(p_dim_set.calendar.agg_map.agg_map,g_commands);
  end if;
Exception when others then
  log_n('Exception in create_agg_map '||sqlerrm);
  raise;
End;

/*
the operators for agg maps need not be specific to each aggmap. say aggmap, aggmap_notime
and dim agg maps.
aggmap and aggmap_notime have diff measures. the operator dim will contain all measures
so before firing an aggmap, we must limit the measuredim
tested to make sure that we can have measurename and measuredim that holds the cube name in opvar.
*/
procedure create_aggmap_operators(p_kpi kpi_r,p_dim_set dim_set_r) is
l_cube_set cube_set_r;
l_pt_comp_type varchar2(100);
l_pt_comp varchar2(100);
l_partition_template partition_template_r;
Begin
  --measure_dim created in create_measure_dim
  --opvar makes sense only for std agg. for formulas, it makes no sense. but we just have it here
  if p_dim_set.aggmap_operator.opvar is not null then
    g_stmt:='dfn '||p_dim_set.aggmap_operator.opvar||' TEXT<'||p_dim_set.measurename_dim||' '||p_dim_set.aggmap_operator.measure_dim||'>';
    bsc_aw_dbms_aw.execute(g_stmt);
    for i in 1..p_dim_set.measure.count loop
      l_cube_set:=get_cube_set_r(p_dim_set.measure(i).cube,p_dim_set);
      g_stmt:=p_dim_set.aggmap_operator.opvar||'('||p_dim_set.measurename_dim||' '''||p_dim_set.measure(i).measure||''' '||
      p_dim_set.aggmap_operator.measure_dim||' '''||l_cube_set.cube.cube_name||
      ''')='''||replace(p_dim_set.measure(i).agg_formula.agg_formula,'''','\''')||'''';
      bsc_aw_dbms_aw.execute(g_stmt);
      /*we need to add the aggregation function for the partitions */
      l_pt_comp:=get_cube_pt_comp(l_cube_set.cube.cube_name,p_dim_set,l_pt_comp_type);
      if l_pt_comp_type='partition template' then
        l_partition_template:=get_partition_template_r(l_pt_comp,p_dim_set);
        for j in 1..l_partition_template.template_partitions.count loop
          g_stmt:=p_dim_set.aggmap_operator.opvar||'('||p_dim_set.measurename_dim||' '''||p_dim_set.measure(i).measure||''' '||
          p_dim_set.aggmap_operator.measure_dim||' '''||l_cube_set.cube.cube_name||' (PARTITION '||
          l_partition_template.template_partitions(j).partition_name||')'')='''||replace(p_dim_set.measure(i).agg_formula.agg_formula,'''','\''')||'''';
          bsc_aw_dbms_aw.execute(g_stmt);
        end loop;
      end if;
      if l_cube_set.display_cube.cube_name is not null then
        g_stmt:=p_dim_set.aggmap_operator.opvar||'('||p_dim_set.measurename_dim||' '''||p_dim_set.measure(i).measure||''' '||
        p_dim_set.aggmap_operator.measure_dim||' '''||l_cube_set.display_cube.cube_name||
        ''')='''||replace(p_dim_set.measure(i).agg_formula.agg_formula,'''','\''')||'''';
        bsc_aw_dbms_aw.execute(g_stmt);
      end if;
    end loop;
  end if;
  if p_dim_set.aggmap_operator.argvar is not null then
    g_stmt:='dfn '||p_dim_set.aggmap_operator.argvar||' TEXT<'||p_dim_set.measurename_dim||' '||p_dim_set.aggmap_operator.measure_dim||'>';
    bsc_aw_dbms_aw.execute(g_stmt);
    for i in 1..p_dim_set.measure.count loop
      l_cube_set:=get_cube_set_r(p_dim_set.measure(i).cube,p_dim_set);
      g_stmt:=p_dim_set.aggmap_operator.argvar||'('||p_dim_set.measurename_dim||' '''||p_dim_set.measure(i).measure||''' '||
      p_dim_set.aggmap_operator.measure_dim||' '''||l_cube_set.cube.cube_name||''')=NA';
      bsc_aw_dbms_aw.execute(g_stmt);
      if l_cube_set.display_cube.cube_name is not null then
        g_stmt:=p_dim_set.aggmap_operator.argvar||'('||p_dim_set.measurename_dim||' '''||p_dim_set.measure(i).measure||''' '||
        p_dim_set.aggmap_operator.measure_dim||' '''||l_cube_set.display_cube.cube_name||''')=NA';
        bsc_aw_dbms_aw.execute(g_stmt);
      end if;
    end loop;
  end if;
Exception when others then
  log_n('Exception in create_aggmap_operators '||sqlerrm);
  raise;
End;

/*
if the aggmap is regular one, time is added
if notime, no time relation is added
*/
procedure create_agg_map(p_dim_set dim_set_r,p_agg_map in out nocopy agg_map_r) is
--
l_flag boolean;
agg_formula varchar2(2000);
Begin
  --create the agg map
  g_commands.delete;
  l_flag:=false;
  bsc_aw_utility.add_g_commands(g_commands,'dfn '||p_agg_map.agg_map||' aggmap ');
  if p_dim_set.compressed='Y' then /* 5236161*/
    for i in 1..p_dim_set.measure.count loop
      if bsc_aw_utility.is_std_aggregation_function(p_dim_set.measure(i).agg_formula.agg_formula)='Y' then
        agg_formula:=p_dim_set.measure(i).agg_formula.agg_formula;
        if agg_formula is not null then
          exit;
        end if;
      end if;
    end loop;
    if agg_formula is null then
      log('Could not get an agg formula with std aggregation for CC');
      raise bsc_aw_utility.g_exception;
    end if;
  end if;
  --if regular aggmap, add time relation also
  if p_agg_map.property='normal' then
    if is_calendar_aggregated(p_dim_set.calendar) then
      l_flag:=true;
      if p_dim_set.compressed='Y' then
        --cannot have opvar, argvar or measuredim. so we have restricted implementation. all measures must have the same agg
        --formula. if the agg formula is diff, create_PT_comp_names would have set compressed to N
        bsc_aw_utility.add_g_commands(g_commands,'relation '||p_dim_set.calendar.relation_name||' OPERATOR '||
        agg_formula);
      else
        bsc_aw_utility.add_g_commands(g_commands,'relation '||p_dim_set.calendar.relation_name||' OPERATOR '||
        p_agg_map.aggmap_operator.opvar||' ARGS '||p_agg_map.aggmap_operator.argvar);
      end if;
    end if;
  end if;
  for i in 1..p_dim_set.dim.count loop
    if p_dim_set.dim(i).agg_map.created='Y' then --create_composite has already set this flag
      l_flag:=true;
      if p_dim_set.compressed='Y' then
        bsc_aw_utility.add_g_commands(g_commands,'relation '||p_dim_set.dim(i).relation_name||' OPERATOR '||
        agg_formula);
      else
        bsc_aw_utility.add_g_commands(g_commands,'relation '||p_dim_set.dim(i).relation_name||' OPERATOR '||
        p_agg_map.aggmap_operator.opvar||' ARGS '||p_agg_map.aggmap_operator.argvar);
      end if;
    end if;
  end loop;
  if p_dim_set.compressed='Y' then
    null;
  else
    bsc_aw_utility.add_g_commands(g_commands,'MEASUREDIM '||p_agg_map.aggmap_operator.measure_dim);
  end if;
  if l_flag then
    p_agg_map.created:='Y';
    bsc_aw_utility.exec_aggmap_commands(p_agg_map.agg_map,g_commands);
  else
    p_agg_map.created:='N';
  end if;
Exception when others then
  log_n('Exception in create_agg_map '||sqlerrm);
  raise;
End;

procedure create_kpi_program(p_kpi in out nocopy kpi_r) is
Begin
  for i in 1..p_kpi.dim_set.count loop
    create_kpi_program(p_kpi,p_kpi.dim_set(i),'initial');
    create_kpi_program(p_kpi,p_kpi.dim_set(i),'inc');
    create_aggregate_marker_pgm(p_kpi,p_kpi.dim_set(i));
  end loop;
  --if targets are implemented, create load programs for targets also
  for i in 1..p_kpi.target_dim_set.count loop
    if p_kpi.target_dim_set(i).dim_set is not null then
      create_kpi_program(p_kpi,p_kpi.target_dim_set(i),'initial');
      create_kpi_program(p_kpi,p_kpi.target_dim_set(i),'inc');
    end if;
  end loop;
Exception when others then
  log_n('Exception in create_kpi_program 1 '||sqlerrm);
  raise;
End;

/*
only creates load program. no aggregation or forecast
the program has a if findchars check for each data source each data source has base tables
RSG will load base tables, not KPI. so we need to load only those data sources which have the
base tables RSG has specified. also, the load may be for the kpi. so we do the check at each
datasource witl ALL and the base table names
arg(1) will be ALL or BSC_B_1,BSC_B_2, etc. we have a comma at the end and check with the comma to prevent
BSC_B_1 being oked for BSC_B_10
*/
procedure create_kpi_program(
p_kpi kpi_r,
p_dim_set in out nocopy dim_set_r,
p_mode varchar2) is
--
l_pgm varchar2(300);
l_stmt varchar2(4000);
Begin
  g_commands.delete;
  if p_mode='initial' then
    set_program_property(p_dim_set.initial_load_program,p_dim_set.data_source);
    l_pgm:=p_dim_set.initial_load_program.program_name;
    bsc_aw_utility.add_g_commands(g_commands,'dfn '||l_pgm||' program');
    for i in 1..p_dim_set.data_source.count loop
      create_kpi_program(p_kpi,p_dim_set,p_dim_set.data_source(i));
    end loop;
  else
    set_program_property(p_dim_set.inc_load_program,p_dim_set.inc_data_source);
    l_pgm:=p_dim_set.inc_load_program.program_name;
    bsc_aw_utility.add_g_commands(g_commands,'dfn '||l_pgm||' program');
    for i in 1..p_dim_set.inc_data_source.count loop
      create_kpi_program(p_kpi,p_dim_set,p_dim_set.inc_data_source(i));
    end loop;
  end if;
  bsc_aw_utility.exec_program_commands(l_pgm,g_commands);
Exception when others then
  log_n('Exception in create_kpi_program 2 '||sqlerrm);
  raise;
End;

/*
given a data source construct the program statements.
this procesure creates the program that will load all measures at the same time. this is done for 9i and 10g.
in 10g, we will also have a program that will load measures in diff sessions for parallelism
this is created so that in case parallelism is disabled, we can launch this process to load all measures at the same
time
for 10g with partitions, we have programs that load on partition basis
we now AND the base tables in a data source. these base tables are ordered according to name
*/
procedure create_kpi_program(
p_kpi kpi_r,
p_dim_set dim_set_r,
p_data_source data_source_r) is
l_stmt varchar(4000);
--
l_cube_set cube_set_r;
l_filter varchar2(2000);
l_ordered_b_tables dbms_sql.varchar2_table;
l_balance_loaded_column varchar2(40);
Begin
  for i in 1..p_data_source.base_tables.count loop
    bsc_aw_utility.merge_value(l_ordered_b_tables,p_data_source.base_tables(i).base_table_name);
  end loop;
  l_ordered_b_tables:=bsc_aw_utility.order_array(l_ordered_b_tables);
  bsc_aw_utility.add_g_commands(g_commands,'if arg(1) EQ \'''||bsc_aw_utility.make_string_from_list(l_ordered_b_tables)||'\'' --');
  --see if there are any additional filter properties defined..used when partitions are involved
  l_filter:=bsc_aw_utility.get_property(p_data_source.property,'datasource filter').property_value;
  if l_filter is not null then
    bsc_aw_utility.add_g_commands(g_commands,l_filter||' --');
  end if;
  bsc_aw_utility.trim_g_commands(g_commands,3,null);
  bsc_aw_utility.add_g_commands(g_commands,'then do');
  /*temp variables period.temp and year.temp hold the period and year values. they are present in all cube loading programs. they are used when we
  have BALANCE LAST VALUE type measure */
  create_temp_variables(p_dim_set,p_data_source);
  bsc_aw_utility.add_g_commands(g_commands,'allstat');
  --if compressed composite, clear the aggregates. if < 10.2
  if p_dim_set.compressed='Y' and bsc_aw_utility.get_db_version<10.2 then
    bsc_aw_utility.init_is_new_value(1);
    for i in 1..p_data_source.measure.count loop
      if bsc_aw_utility.is_new_value(p_data_source.measure(i).cube,1) then
        bsc_aw_utility.add_g_commands(g_commands,'clear all aggregates from '||p_data_source.measure(i).cube);
        /*here we clear all aggregates from the cubes without looking at which measures are involved. if we load only 1
        B, we aggregate all measures. this is ok, since cost is not in the arthmetic, but in composite build
        */
      end if;
    end loop;
  end if;
  for i in 1..p_data_source.data_source_stmt.count loop
    bsc_aw_utility.add_g_commands(g_commands,p_data_source.data_source_stmt(i)||' --');
  end loop;
  bsc_aw_utility.trim_g_commands(g_commands,3,null);
  create_dim_match_header(p_data_source);
  /*
  if the dimset has partitions, data source stmt will have the partition key
  if the data source partition dim is not null, it means partitions are implemented in the dimset
  */
  if p_dim_set.number_partitions>0 and p_data_source.data_source_PT.partition_template.template_dim is not null then
    bsc_aw_utility.add_g_commands(g_commands,':match '||p_data_source.data_source_PT.partition_template.template_dim||' --');
  end if;
  --now the cubes
  --every dim has CC dim. we have this so that we can do zero code on any of them.
  for i in 1..p_data_source.measure.count loop
    l_stmt:=':'||p_data_source.measure(i).cube||'(';
    l_cube_set:=get_cube_set_r(p_data_source.measure(i).cube,p_dim_set);
    if l_cube_set.cube_set_type='datacube' then --specify the measure name
      l_stmt:=l_stmt||l_cube_set.measurename_dim||' \'''||p_data_source.measure(i).measure||'\'' ';
    end if;
    --time will always be concat
    --we dont need to have std dim since they do not have concat dim
    --dim. we also need to filter out dim which are standalone and not concat
    --note: std dim are automatically filtered since they are not concat
    for j in 1..p_data_source.dim.count loop
      if p_data_source.dim(j).concat='Y' then
        l_stmt:=l_stmt||p_data_source.dim(j).dim_name||' '||p_data_source.dim(j).levels(1).level_name||' ';
      end if;
    end loop;
    --time
    l_stmt:=l_stmt||p_data_source.calendar.aw_dim||' '||p_data_source.calendar.periodicity(1).aw_dim||' ';
    l_stmt:=l_stmt||') --';
    bsc_aw_utility.add_g_commands(g_commands,l_stmt);
  end loop;
  for i in 1..p_data_source.measure.count loop
    if p_data_source.measure(i).measure_type=g_balance_last_value_prop then
      /*if this is a BALANCE LAST VALUE column, also grab the loaded Y/N column */
      l_balance_loaded_column:=bsc_aw_utility.get_property(p_data_source.measure(i).property,g_balance_loaded_column_prop).property_value;
      if l_balance_loaded_column is not null then
        bsc_aw_utility.add_g_commands(g_commands,':'||l_balance_loaded_column||' --');
      end if;
    end if;
  end loop;
  --markers...limit cubes
  create_limit_cube_tail(p_data_source);
  /*have a then stmt. if there are balance measures, we need the then */
  bsc_aw_utility.add_g_commands(g_commands,'then --');
  bsc_aw_utility.add_g_commands(g_commands,'temp_number=NA --');
  --if there is balance, add the balance aggregation statements
  create_balance_aggregation(p_dim_set,p_data_source,p_data_source.measure);
  --
  bsc_aw_utility.trim_g_commands(g_commands,3,null);
  bsc_aw_utility.add_g_commands(g_commands,'sql close c1');
  bsc_aw_utility.add_g_commands(g_commands,'sql cleanup');
  bsc_aw_utility.add_g_commands(g_commands,'doend');
Exception when others then
  log_n('Exception in create_kpi_program 3 ,dimset='||p_dim_set.dim_set_name||' '||sqlerrm);
  raise;
End;

procedure create_balance_aggregation(p_dim_set dim_set_r, p_data_source data_source_r,p_measures measure_tb) is
l_upper_periodicity dbms_sql.varchar2_table;
l_cube_copy_stmt dbms_sql.varchar2_table;
l_limit_cube_copy_stmt dbms_sql.varchar2_table;
l_stmt varchar2(8000);
l_cube_set cube_set_r;
--
l_balance_loaded_column varchar2(40);
l_year_cube varchar2(80);
l_period_cube varchar2(80);
l_year_cube_stmt varchar2(2000);
l_period_cube_stmt varchar2(2000);
Begin
  for i in 1..p_data_source.calendar.parent_child.count loop
    if p_data_source.calendar.parent_child(i).parent_dim_name is not null
    and p_data_source.calendar.parent_child(i).parent_dim_name<>p_data_source.calendar.periodicity(1).aw_dim then
      bsc_aw_utility.merge_value(l_upper_periodicity,p_data_source.calendar.parent_child(i).parent_dim_name);
    end if;
    if p_data_source.calendar.parent_child(i).child_dim_name is not null
    and p_data_source.calendar.parent_child(i).child_dim_name<>p_data_source.calendar.periodicity(1).aw_dim then
      bsc_aw_utility.merge_value(l_upper_periodicity,p_data_source.calendar.parent_child(i).child_dim_name);
    end if;
  end loop;
  if g_debug then
    log('In create_balance_aggregation dimset '||p_dim_set.dim_set_name||', upper periodicities:-');
    for i in 1..l_upper_periodicity.count loop
      log(l_upper_periodicity(i));
    end loop;
  end if;
  for i in 1..p_measures.count loop
    if g_debug then
      log(p_measures(i).measure||' '||p_measures(i).measure_type);
    end if;
    if p_measures(i).measure_type=g_balance_end_period_prop or p_measures(i).measure_type=g_balance_last_value_prop then
      l_cube_set:=get_cube_set_r(p_measures(i).cube,p_dim_set);
      for j in 1..l_upper_periodicity.count loop
        l_cube_copy_stmt(j):=p_measures(i).cube||'(';
        if l_cube_set.cube_set_type='datacube' then --specify the measure name
          l_cube_copy_stmt(j):=l_cube_copy_stmt(j)||l_cube_set.measurename_dim||' \'''||p_measures(i).measure||'\'' ';
        end if;
        for k in 1..p_data_source.dim.count loop
          if p_data_source.dim(k).concat='Y' then
            l_cube_copy_stmt(j):=l_cube_copy_stmt(j)||p_data_source.dim(k).dim_name||' '||p_data_source.dim(k).levels(1).level_name||' ';
          end if;
        end loop;
        --time
        l_cube_copy_stmt(j):=l_cube_copy_stmt(j)||p_data_source.calendar.aw_dim||' '||p_data_source.calendar.denorm_relation_name||'('||
        p_data_source.calendar.aw_dim||' '||p_data_source.calendar.periodicity(1).aw_dim||' '||
        p_data_source.calendar.end_period_level_name_dim||' \'''||l_upper_periodicity(j)||'\''))=';
        l_cube_copy_stmt(j):=l_cube_copy_stmt(j)||p_measures(i).cube||'(';
        if l_cube_set.cube_set_type='datacube' then --specify the measure name
          l_cube_copy_stmt(j):=l_cube_copy_stmt(j)||l_cube_set.measurename_dim||' \'''||p_measures(i).measure||'\'' ';
        end if;
        for k in 1..p_data_source.dim.count loop
          if p_data_source.dim(k).concat='Y' then
            l_cube_copy_stmt(j):=l_cube_copy_stmt(j)||p_data_source.dim(k).dim_name||' '||p_data_source.dim(k).levels(1).level_name||' ';
          end if;
        end loop;
        --time
        l_cube_copy_stmt(j):=l_cube_copy_stmt(j)||p_data_source.calendar.aw_dim||' '||p_data_source.calendar.periodicity(1).aw_dim||') --';
        /*limit cube stmt */
        l_limit_cube_copy_stmt(j):=p_data_source.calendar.limit_cube||'('||p_data_source.calendar.aw_dim||' '||
        p_data_source.calendar.denorm_relation_name||'('||p_data_source.calendar.aw_dim||' '||p_data_source.calendar.periodicity(1).aw_dim||' '||
        p_data_source.calendar.end_period_level_name_dim||' \'''||l_upper_periodicity(j)||'\''))=TRUE --';
      end loop;
    end if;
    if p_measures(i).measure_type=g_balance_end_period_prop then --default end period balance
      /*must have rollup to all upper periodicities */
      for j in 1..l_upper_periodicity.count loop
        l_stmt:='if '||p_data_source.calendar.aw_dim||'('||p_data_source.calendar.aw_dim||' '||p_data_source.calendar.periodicity(1).aw_dim||') '||
        'EQ '||p_data_source.calendar.end_period_relation_name||'('||p_data_source.calendar.aw_dim||' '||
        p_data_source.calendar.denorm_relation_name||'('||p_data_source.calendar.aw_dim||' '||p_data_source.calendar.periodicity(1).aw_dim||' '||
        p_data_source.calendar.end_period_level_name_dim||' \'''||l_upper_periodicity(j)||'\'') '||
        p_data_source.calendar.end_period_level_name_dim||' \'''||p_data_source.calendar.periodicity(1).aw_dim||'\'') --';
        bsc_aw_utility.add_g_commands(g_commands,l_stmt);
        bsc_aw_utility.add_g_commands(g_commands,'then do --');
        bsc_aw_utility.add_g_commands(g_commands,l_cube_copy_stmt(j));
        /*set the limit cube of time also to true. this means we are simulating the time agg to come from the B table. this is important
        later for aggregation and target copy */
        bsc_aw_utility.add_g_commands(g_commands,l_limit_cube_copy_stmt(j));
        bsc_aw_utility.add_g_commands(g_commands,'doend --');
      end loop;
    elsif p_measures(i).measure_type=g_balance_last_value_prop then --last value balance
      l_balance_loaded_column:=bsc_aw_utility.get_property(p_measures(i).property,g_balance_loaded_column_prop).property_value;
      l_year_cube:=bsc_aw_utility.get_property(p_measures(i).property,'year cube').property_value;
      l_period_cube:=bsc_aw_utility.get_property(p_measures(i).property,'period cube').property_value;
      /*l_year_cube and l_period_cube cannot be null */
      if l_balance_loaded_column is not null then
        bsc_aw_utility.add_g_commands(g_commands,'if '||l_balance_loaded_column||' GT 0 --');
        bsc_aw_utility.add_g_commands(g_commands,'then do --');
      end if;
      for j in 1..l_upper_periodicity.count loop
        if l_cube_set.cube_set_type='datacube' then
          l_year_cube_stmt:=p_measures(i).cube||'('||l_cube_set.measurename_dim||' \'''||l_year_cube||'\'' ';
          l_period_cube_stmt:=p_measures(i).cube||'('||l_cube_set.measurename_dim||' \'''||l_period_cube||'\'' ';
        else
          l_year_cube_stmt:=l_year_cube||'(';
          l_period_cube_stmt:=l_period_cube||'(';
        end if;
        l_stmt:=null;
        for k in 1..p_data_source.dim.count loop
          if p_data_source.dim(k).concat='Y' then
            l_stmt:=l_stmt||p_data_source.dim(k).dim_name||' '||p_data_source.dim(k).levels(1).level_name||' ';
          end if;
        end loop;
        --time
        l_stmt:=l_stmt||p_data_source.calendar.aw_dim||' '||p_data_source.calendar.denorm_relation_name||'('||
        p_data_source.calendar.aw_dim||' '||p_data_source.calendar.periodicity(1).aw_dim||' '||
        p_data_source.calendar.end_period_level_name_dim||' \'''||l_upper_periodicity(j)||'\''))';
        l_year_cube_stmt:=l_year_cube_stmt||l_stmt;
        l_period_cube_stmt:=l_period_cube_stmt||l_stmt;
        bsc_aw_utility.add_g_commands(g_commands,'if '||l_year_cube_stmt||' EQ NA OR --');
        bsc_aw_utility.add_g_commands(g_commands,g_year_temp||' GT '||l_year_cube_stmt||' OR --');
        bsc_aw_utility.add_g_commands(g_commands,'('||g_year_temp||' EQ '||l_year_cube_stmt||' AND --');
        bsc_aw_utility.add_g_commands(g_commands,g_period_temp||' GT '||l_period_cube_stmt||') --');
        bsc_aw_utility.add_g_commands(g_commands,'then do --');
        bsc_aw_utility.add_g_commands(g_commands,l_cube_copy_stmt(j));
        bsc_aw_utility.add_g_commands(g_commands,l_limit_cube_copy_stmt(j));
        /*we must set the upper year and period values also */
        bsc_aw_utility.add_g_commands(g_commands,l_year_cube_stmt||'='||g_year_temp||' --');
        bsc_aw_utility.add_g_commands(g_commands,l_period_cube_stmt||'='||g_period_temp||' --');
        bsc_aw_utility.add_g_commands(g_commands,'doend --');
      end loop;
      if l_balance_loaded_column is not null then
        bsc_aw_utility.add_g_commands(g_commands,'doend --');
      end if;
    end if;
  end loop;
Exception when others then
  log_n('Exception in create_balance_aggregation,dimset='||p_dim_set.dim_set_name||' '||sqlerrm);
  raise;
End;

/*
this procedure will create the :match header. we have this procesure in place because the following will need it.
creation of generic load program for all measures
creation of load program per measure (10g)
creation of limit cube program (10g)
we have this so we can avoid repeating the code
*/
procedure create_dim_match_header(p_data_source data_source_r) is
Begin
  bsc_aw_utility.add_g_commands(g_commands,'sql open c1');
  --even after arun changed the filter to be like (select code from dim_view), import does not work. this means
  --if there is filter, we have to have fetch loop...
  if bsc_aw_utility.get_property(p_data_source.property,'dimension filter').property_value='Y'
  or bsc_aw_utility.get_property(p_data_source.property,g_balance_last_value_prop).property_value='Y' then
    bsc_aw_utility.add_g_commands(g_commands,'sql fetch c1 loop into --');
  else
    bsc_aw_utility.add_g_commands(g_commands,'sql import c1 into --');
  end if;
  for i in 1..p_data_source.dim.count loop
    bsc_aw_utility.add_g_commands(g_commands,':match '||p_data_source.dim(i).levels(1).level_name||' --');
  end loop;
  --std dim
  for i in 1..p_data_source.std_dim.count loop
    bsc_aw_utility.add_g_commands(g_commands,':match '||p_data_source.std_dim(i).levels(1).level_name||' --');
  end loop;
  --time dim. data source will only have 1 periodicity, the periodicity of the base table
  bsc_aw_utility.add_g_commands(g_commands,':match '||p_data_source.calendar.periodicity(1).aw_dim||' --');
  if bsc_aw_utility.get_property(p_data_source.property,g_balance_last_value_prop).property_value='Y' then
    /*we need to place period and year values into the temp variables */
    bsc_aw_utility.add_g_commands(g_commands,':'||g_period_temp||' --');
    bsc_aw_utility.add_g_commands(g_commands,':'||g_year_temp||' --');
  end if;
Exception when others then
  log_n('Exception in create_dim_match_header '||sqlerrm);
  raise;
End;

/*
creates the trailing :limit cube stmt. here in place to avoid duplicating code
needed by generic program for all measures and the program for individual measures and limit cubes
*/
procedure create_limit_cube_tail(p_data_source data_source_r) is
Begin
  for i in 1..p_data_source.dim.count loop
    if p_data_source.dim(i).concat='Y' then
      bsc_aw_utility.add_g_commands(g_commands,':'||p_data_source.dim(i).limit_cube||'('||
      p_data_source.dim(i).dim_name||' '||p_data_source.dim(i).levels(1).level_name||') --');
    else
      bsc_aw_utility.add_g_commands(g_commands,':'||p_data_source.dim(i).limit_cube||' --');
    end if;
  end loop;
  --limit cubes for std dim...std dim are not concat
  for i in 1..p_data_source.std_dim.count loop
    bsc_aw_utility.add_g_commands(g_commands,':'||p_data_source.std_dim(i).limit_cube||' --');
  end loop;
  --we dont need to have std dim since they do not have concat dim
  --time dim
  bsc_aw_utility.add_g_commands(g_commands,':'||p_data_source.calendar.limit_cube||'('||
  p_data_source.calendar.aw_dim||' '||p_data_source.calendar.periodicity(1).aw_dim||') --');
Exception when others then
  log_n('Exception in create_limit_cube_tail '||sqlerrm);
  raise;
End;

/*
this procedure creates the program that can load in parallel the dim limit cubes and the measures
the program will look as
--data source 1
if findchars(MEASURE1) GT 0
then do
  select dim1,dim2,measure1 from B1 where ...
  sql import into :match dim1 :match dim2 :cube1(..)
doend
if findchars(MEASURE2) GT 0
then do
  select dim1,dim2,measure2 from B1 where ...
  sql import into :match dim1 :match dim2 :cube1(..)
doend
if findchars(LIMIT CUBE) GT 0
then do
  select dim1,dim2,1,1,1.. from B1 where ...
  sql import into :match dim1 :match dim2 :limitcube1,limitcube2...(..)
doend
--data source 2
if findchars(MEASURE1) GT 0
then do
  select dim1,dim2,measure1 from B2 where ...
  sql import into :match dim1 :match dim2 :cube1(..)
doend
if findchars(LIMIT CUBE) GT 0
then do
  select dim1,dim2,1,1,1.. from B2 where ...
  sql import into :match dim1 :match dim2 :limitcube1,limitcube2...(..)
doend
*/
procedure create_kpi_program_parallel(p_kpi in out nocopy kpi_r) is
Begin
  for i in 1..p_kpi.dim_set.count loop
    if p_kpi.dim_set(i).number_partitions>0 then
      create_kpi_program_LB_resync(p_kpi,p_kpi.dim_set(i));
      create_kpi_program_partition(p_kpi,p_kpi.dim_set(i),'initial');
      create_kpi_program_partition(p_kpi,p_kpi.dim_set(i),'inc');
    else
      create_kpi_program_cube(p_kpi,p_kpi.dim_set(i),'initial');
      create_kpi_program_cube(p_kpi,p_kpi.dim_set(i),'inc');
    end if;
  end loop;
  --if targets are implemented, create load programs for targets also
  for i in 1..p_kpi.target_dim_set.count loop
    if p_kpi.target_dim_set(i).dim_set is not null then
      if p_kpi.target_dim_set(i).number_partitions>0 then
        create_kpi_program_LB_resync(p_kpi,p_kpi.target_dim_set(i));
        create_kpi_program_partition(p_kpi,p_kpi.target_dim_set(i),'initial');
        create_kpi_program_partition(p_kpi,p_kpi.target_dim_set(i),'inc');
      else
        create_kpi_program_cube(p_kpi,p_kpi.target_dim_set(i),'initial');
        create_kpi_program_cube(p_kpi,p_kpi.target_dim_set(i),'inc');
      end if;
    end if;
  end loop;
Exception when others then
  log_n('Exception in create_kpi_program_parallel '||sqlerrm);
  raise;
End;

/*
this procedure creates the program that can load in parallel the dim limit cubes and the measures
*/
procedure create_kpi_program_cube(
p_kpi kpi_r,
p_dim_set in out nocopy dim_set_r,
p_mode varchar2) is
--
l_data_source data_source_tb;
l_pgm varchar2(300);
l_cube_measures measure_tb;
l_cube_considered dbms_sql.varchar2_table;
Begin
  g_commands.delete;
  if p_mode='initial' then
    set_program_property(p_dim_set.initial_load_program_parallel,p_dim_set.data_source);
    l_pgm:=p_dim_set.initial_load_program_parallel.program_name;
    l_data_source:=p_dim_set.data_source;
  else
    set_program_property(p_dim_set.inc_load_program_parallel,p_dim_set.inc_data_source);
    l_pgm:=p_dim_set.inc_load_program_parallel.program_name;
    l_data_source:=p_dim_set.inc_data_source;
  end if;
  bsc_aw_utility.add_g_commands(g_commands,'dfn '||l_pgm||' program');
  for i in 1..l_data_source.count loop
    l_cube_considered.delete;
    for j in 1..l_data_source(i).measure.count loop
      if bsc_aw_utility.in_array(l_cube_considered,l_data_source(i).measure(j).cube)=false then
        l_cube_considered(l_cube_considered.count+1):=l_data_source(i).measure(j).cube;
      end if;
    end loop;
    for j in 1..l_cube_considered.count loop
      l_cube_measures.delete;
      for k in 1..l_data_source(i).measure.count loop
        if l_data_source(i).measure(k).cube=l_cube_considered(j) then
          l_cube_measures(l_cube_measures.count+1):=l_data_source(i).measure(k);
        end if;
      end loop;
      create_kpi_program_cube(p_kpi,p_dim_set,get_cube_set_r(l_cube_considered(j),p_dim_set),l_cube_measures,l_data_source(i));
    end loop;
    --limit cubes
    create_kpi_program_limit_cube(p_kpi,p_dim_set,l_data_source(i));
  end loop;
  bsc_aw_utility.exec_program_commands(l_pgm,g_commands);
Exception when others then
  log_n('Exception in create_kpi_program_cube 2 '||sqlerrm);
  raise;
End;

/*
this procedure adds to the program that loads measures in parallel. input is a measure and a data source. if the datasource
has the measure, then create the program stmt
*/
procedure create_kpi_program_cube(
p_kpi kpi_r,
p_dim_set dim_set_r,
p_cube_set cube_set_r,
p_measures measure_tb,
p_data_source data_source_r) is
--
l_measure_index number;
l_stmt varchar(4000);
l_measures dbms_sql.varchar2_table;
l_ordered_b_tables dbms_sql.varchar2_table;
l_balance_loaded_column varchar2(40);
Begin
  for i in 1..p_measures.count loop
    l_measures(i):=p_measures(i).measure;
  end loop;
  for i in 1..p_data_source.base_tables.count loop
    bsc_aw_utility.merge_value(l_ordered_b_tables,p_data_source.base_tables(i).base_table_name);
  end loop;
  l_ordered_b_tables:=bsc_aw_utility.order_array(l_ordered_b_tables);
  bsc_aw_utility.add_g_commands(g_commands,'if arg(1) EQ \'''||bsc_aw_utility.make_string_from_list(l_ordered_b_tables)||'\'' --');
  bsc_aw_utility.add_g_commands(g_commands,' AND arg(2) EQ \'''||upper(p_cube_set.cube.cube_name)||',\'' ');
  bsc_aw_utility.add_g_commands(g_commands,'then do');
  /*temp variables period.temp and year.temp hold the period and year values. they are present in all cube loading programs. they are used when we
  have BALANCE LAST VALUE type measure */
  create_temp_variables(p_dim_set,p_data_source);
  --if compressed composite, clear the aggregates. if < 10.2
  if p_dim_set.compressed='Y' and bsc_aw_utility.get_db_version<10.2 then
    bsc_aw_utility.add_g_commands(g_commands,'clear all aggregates from '||p_cube_set.cube.cube_name);
  end if;
  --we do not have limit cubes. only the sql, dim and the measure we are looking at
  for i in 1..p_data_source.data_source_stmt.count loop
    if substr(p_data_source.data_source_stmt_type(i),1,3)='sql' or substr(p_data_source.data_source_stmt_type(i),1,10)='dimension=' or
    substr(p_data_source.data_source_stmt_type(i),1,10)='temp time=' then
      if p_data_source.data_source_stmt_type(i)='sql from' then
        if substr(bsc_aw_utility.get_g_commands(g_commands,null),-4)=', --' then
          bsc_aw_utility.trim_g_commands(g_commands,4,' --'); --remove the trailing ,
        end if;
      end if;
      bsc_aw_utility.add_g_commands(g_commands,p_data_source.data_source_stmt(i)||' --');
    elsif substr(p_data_source.data_source_stmt_type(i),1,8)='measure=' then
      if bsc_aw_utility.in_array(l_measures,substr(p_data_source.data_source_stmt_type(i),9,length(p_data_source.data_source_stmt_type(i)))) then
        bsc_aw_utility.add_g_commands(g_commands,p_data_source.data_source_stmt(i)||' --');
      end if;
    elsif substr(p_data_source.data_source_stmt_type(i),1,27)='temp balance loaded column=' then /*temp balance loaded column=measure name */
      if bsc_aw_utility.in_array(l_measures,substr(p_data_source.data_source_stmt_type(i),28,length(p_data_source.data_source_stmt_type(i)))) then
        bsc_aw_utility.add_g_commands(g_commands,p_data_source.data_source_stmt(i)||' --');
      end if;
    end if;
  end loop;
  bsc_aw_utility.trim_g_commands(g_commands,3,null);
  create_dim_match_header(p_data_source);
  --now the cube for the measures
  for i in 1..p_measures.count loop
    l_stmt:=':'||p_cube_set.cube.cube_name||'('; --time will always be concat
    if p_cube_set.cube_set_type='datacube' then
      l_stmt:=l_stmt||p_cube_set.measurename_dim||' \'''||p_measures(i).measure||'\'' ';
    end if;
    for j in 1..p_data_source.dim.count loop
      if p_data_source.dim(j).concat='Y' then
        l_stmt:=l_stmt||p_data_source.dim(j).dim_name||' '||p_data_source.dim(j).levels(1).level_name||' ';
      end if;
    end loop;
    --time
    l_stmt:=l_stmt||p_data_source.calendar.aw_dim||' '||p_data_source.calendar.periodicity(1).aw_dim||' ';
    l_stmt:=l_stmt||') --';
    bsc_aw_utility.add_g_commands(g_commands,l_stmt);
  end loop;
  for i in 1..p_measures.count loop
    if p_measures(i).measure_type=g_balance_last_value_prop then
      /*if this is a BALANCE LAST VALUE column, also grab the loaded Y/N column */
      l_balance_loaded_column:=bsc_aw_utility.get_property(p_measures(i).property,g_balance_loaded_column_prop).property_value;
      if l_balance_loaded_column is not null then
        bsc_aw_utility.add_g_commands(g_commands,':'||l_balance_loaded_column||' --');
      end if;
    end if;
  end loop;
  /*have a then stmt. if there are balance measures, we need the then */
  bsc_aw_utility.add_g_commands(g_commands,'then --');
  bsc_aw_utility.add_g_commands(g_commands,'temp_number=NA --');
  --if there is balance, add the balance aggregation statements
  create_balance_aggregation(p_dim_set,p_data_source,p_measures);
  --
  bsc_aw_utility.trim_g_commands(g_commands,3,null);
  bsc_aw_utility.add_g_commands(g_commands,'sql close c1');
  bsc_aw_utility.add_g_commands(g_commands,'sql cleanup');
  bsc_aw_utility.add_g_commands(g_commands,'doend');
Exception when others then
  log_n('Exception in create_kpi_program_cube 3 '||sqlerrm);
  raise;
End;

/*
this program is reqd when we have partitions. the dim LB is the same across partition loads. we need to acquire lock with
resync at the end on the LB. resync discards private data changes. so before getting the lock, we save the state to session
variables, get the lock, then merge the status from session variables into LB and then save it back. so the program has a
pre and post part
*/
procedure create_kpi_program_LB_resync(
p_kpi kpi_r,
p_dim_set in out nocopy dim_set_r
) is
--
l_kpi varchar2(200);
l_name varchar2(200);
Begin
  l_kpi:=p_kpi.kpi;
  if p_dim_set.dim_set_type='target' then
    l_kpi:=l_kpi||'.tgt';
  end if;
  p_dim_set.LB_resync_program:='LB.resync.'||p_dim_set.dim_set||'.'||l_kpi;
  g_commands.delete;
  bsc_aw_utility.add_g_commands(g_commands,'dfn '||p_dim_set.LB_resync_program||' program');
  --all LB of the dimset
  bsc_aw_utility.add_g_commands(g_commands,'if arg(1) EQ \''PRE\'' ');
  bsc_aw_utility.add_g_commands(g_commands,'then do');
  for i in 1..p_dim_set.dim.count loop
    l_name:=p_dim_set.dim(i).limit_cube||'.S';
    bsc_aw_utility.add_g_commands(g_commands,'if exists(\'''||l_name||'\'') eq false');
    bsc_aw_utility.add_g_commands(g_commands,'then do');
    bsc_aw_utility.add_g_commands(g_commands,'dfn '||l_name||' boolean <'||p_dim_set.dim(i).dim_name||'> session');
    bsc_aw_utility.add_g_commands(g_commands,'doend');
  end loop;
  for i in 1..p_dim_set.std_dim.count loop
    l_name:=p_dim_set.std_dim(i).limit_cube||'.S';
    bsc_aw_utility.add_g_commands(g_commands,'if exists(\'''||l_name||'\'') eq false');
    bsc_aw_utility.add_g_commands(g_commands,'then do');
    bsc_aw_utility.add_g_commands(g_commands,'dfn '||l_name||' boolean <'||p_dim_set.std_dim(i).dim_name||'> session');
    bsc_aw_utility.add_g_commands(g_commands,'doend');
  end loop;
  l_name:=p_dim_set.calendar.limit_cube||'.S';
  bsc_aw_utility.add_g_commands(g_commands,'if exists(\'''||l_name||'\'') eq false');
  bsc_aw_utility.add_g_commands(g_commands,'then do');
  bsc_aw_utility.add_g_commands(g_commands,'dfn '||l_name||' boolean <'||p_dim_set.calendar.aw_dim||'> session');
  bsc_aw_utility.add_g_commands(g_commands,'doend');
  --
  for i in 1..p_dim_set.dim.count loop
    bsc_aw_utility.add_g_commands(g_commands,'push '||p_dim_set.dim(i).dim_name);
    bsc_aw_utility.add_g_commands(g_commands,'limit '||p_dim_set.dim(i).dim_name||' to '||p_dim_set.dim(i).limit_cube);
    bsc_aw_utility.add_g_commands(g_commands,p_dim_set.dim(i).limit_cube||'.S=true');
    bsc_aw_utility.add_g_commands(g_commands,'pop '||p_dim_set.dim(i).dim_name);
  end loop;
  for i in 1..p_dim_set.std_dim.count loop
    bsc_aw_utility.add_g_commands(g_commands,'push '||p_dim_set.std_dim(i).dim_name);
    bsc_aw_utility.add_g_commands(g_commands,'limit '||p_dim_set.std_dim(i).dim_name||' to '||p_dim_set.std_dim(i).limit_cube);
    bsc_aw_utility.add_g_commands(g_commands,p_dim_set.std_dim(i).limit_cube||'.S=true');
    bsc_aw_utility.add_g_commands(g_commands,'pop '||p_dim_set.std_dim(i).dim_name);
  end loop;
  bsc_aw_utility.add_g_commands(g_commands,'push '||p_dim_set.calendar.aw_dim);
  bsc_aw_utility.add_g_commands(g_commands,'limit '||p_dim_set.calendar.aw_dim||' to '||p_dim_set.calendar.limit_cube);
  bsc_aw_utility.add_g_commands(g_commands,p_dim_set.calendar.limit_cube||'.S=true');
  bsc_aw_utility.add_g_commands(g_commands,'pop '||p_dim_set.calendar.aw_dim);
  --
  bsc_aw_utility.add_g_commands(g_commands,'doend');
  --
  bsc_aw_utility.add_g_commands(g_commands,'if arg(1) EQ \''POST\'' ');
  bsc_aw_utility.add_g_commands(g_commands,'then do');
  for i in 1..p_dim_set.dim.count loop
    bsc_aw_utility.add_g_commands(g_commands,'push '||p_dim_set.dim(i).dim_name);
    bsc_aw_utility.add_g_commands(g_commands,'limit '||p_dim_set.dim(i).dim_name||' to '||p_dim_set.dim(i).limit_cube||'.S');
    bsc_aw_utility.add_g_commands(g_commands,p_dim_set.dim(i).limit_cube||'=true');
    bsc_aw_utility.add_g_commands(g_commands,'pop '||p_dim_set.dim(i).dim_name);
  end loop;
  for i in 1..p_dim_set.std_dim.count loop
    bsc_aw_utility.add_g_commands(g_commands,'push '||p_dim_set.std_dim(i).dim_name);
    bsc_aw_utility.add_g_commands(g_commands,'limit '||p_dim_set.std_dim(i).dim_name||' to '||p_dim_set.std_dim(i).limit_cube||'.S');
    bsc_aw_utility.add_g_commands(g_commands,p_dim_set.std_dim(i).limit_cube||'=true');
    bsc_aw_utility.add_g_commands(g_commands,'pop '||p_dim_set.std_dim(i).dim_name);
  end loop;
  bsc_aw_utility.add_g_commands(g_commands,'push '||p_dim_set.calendar.aw_dim);
  bsc_aw_utility.add_g_commands(g_commands,'limit '||p_dim_set.calendar.aw_dim||' to '||p_dim_set.calendar.limit_cube||'.S');
  bsc_aw_utility.add_g_commands(g_commands,p_dim_set.calendar.limit_cube||'=true');
  bsc_aw_utility.add_g_commands(g_commands,'pop '||p_dim_set.calendar.aw_dim);
  bsc_aw_utility.add_g_commands(g_commands,'doend');
  --
  bsc_aw_utility.exec_program_commands(p_dim_set.LB_resync_program,g_commands);
Exception when others then
  log_n('Exception in create_kpi_program_LB_resync '||sqlerrm);
  raise;
End;

procedure create_kpi_program_partition(
p_kpi kpi_r,
p_dim_set in out nocopy dim_set_r,
p_mode varchar2) is
--
l_pgm varchar2(300);
l_data_source data_source_tb;
l_partition_template partition_template_r;
l_pt_name varchar2(200);
Begin
  g_commands.delete;
  if p_mode='initial' then
    set_program_property(p_dim_set.initial_load_program_parallel,p_dim_set.data_source);
    l_pgm:=p_dim_set.initial_load_program_parallel.program_name;
    l_data_source:=p_dim_set.data_source;
  else
    set_program_property(p_dim_set.inc_load_program_parallel,p_dim_set.inc_data_source);
    l_pgm:=p_dim_set.inc_load_program_parallel.program_name;
    l_data_source:=p_dim_set.inc_data_source;
  end if;
  bsc_aw_utility.add_g_commands(g_commands,'dfn '||l_pgm||' program');
  --
  for i in 1..l_data_source.count loop
    l_pt_name:=get_cube_axis(l_data_source(i).measure(1).cube,p_dim_set,'partition template');
    --note>>> all measures of a data source share a PT. a cube can have at most 1 PT
    l_partition_template:=get_partition_template_r(l_pt_name,p_dim_set);
    for j in 1..l_partition_template.template_partitions.count loop
      create_kpi_program_partition(p_kpi,l_partition_template.template_partitions(j),p_dim_set,l_data_source(i),j);
    end loop;
  end loop;
  bsc_aw_utility.exec_program_commands(l_pgm,g_commands);
Exception when others then
  log_n('Exception in create_kpi_program_partition '||sqlerrm);
  raise;
End;

/*
we loop through the data source and fix the where clause to add the 'where partition_dim=partition_dim_value'
*/
procedure create_kpi_program_partition(
p_kpi kpi_r,
template_partition partition_r,
p_dim_set in out nocopy dim_set_r,
p_data_source data_source_r,
partition_index number --1,2,3,4 etc
) is
--
l_data_source data_source_r;
i integer;
l_partition_stmt varchar2(4000);
l_partition_type varchar2(40);
l_cubes dbms_sql.varchar2_table;
l_property_value varchar2(4000);
Begin
  l_data_source:=p_data_source;
  i:=1;
  loop
    if l_data_source.data_source_stmt_type(i)='partition dim list' then
      l_partition_type:='list';
    elsif l_data_source.data_source_stmt_type(i)='partition dim hash' then
      /*l_partition_stmt will look like
      dbms_utility.get_hash_value(RELEASE_CODE||'-'||COMPO_CODE||'-'||CITY_CODE||'-'||PER_CODE||'-'||TYPE||'-'||PROJECTION||'-'||
      period||'.'||year,0,4) hash_partition_dim,
      so we need to substr this to remove the hash_partition_dim,   look for the last )
      */
      l_partition_stmt:=l_data_source.data_source_stmt(i);
      l_partition_stmt:=substr(l_partition_stmt,1,instr(l_partition_stmt,')',-1));
      l_partition_type:='hash';
    end if;
    if l_partition_type='hash' and l_data_source.data_source_stmt_type(i)='sql where' and l_data_source.data_source_stmt(i)=' where 1=1 ' then
      --we add partition filter to the DS stmt
      l_data_source.data_source_stmt(i):=l_data_source.data_source_stmt(i)||'and '||template_partition.partition_dim_value||'='||
      l_partition_stmt;
    end if;
    if l_partition_type='list' and l_data_source.data_source_stmt_type(i)='sql from table' and l_data_source.data_source_stmt(i)=' where 1=1 ' then
      --we add partition filter to the B table stmt
      if l_data_source.base_tables(1).table_partition.main_partition.partition_column_data_type='NUMBER' then
        l_data_source.data_source_stmt(i):=l_data_source.data_source_stmt(i)||'and '||
        l_data_source.base_tables(1).table_partition.main_partition.partitions(partition_index).partition_value||'='||
        l_data_source.base_tables(1).table_partition.main_partition.partition_column;
      else
        l_data_source.data_source_stmt(i):=l_data_source.data_source_stmt(i)||'and '||
        '\'''||l_data_source.base_tables(1).table_partition.main_partition.partitions(partition_index).partition_value||'\''='||
        l_data_source.base_tables(1).table_partition.main_partition.partition_column;
      end if;
    end if;
    i:=i+1;
    if i>l_data_source.data_source_stmt.count then
      exit;
    end if;
  end loop;
  --
  for i in 1..l_data_source.measure.count loop
    if bsc_aw_utility.in_array(l_cubes,l_data_source.measure(i).cube)=false then
      l_cubes(l_cubes.count+1):=l_data_source.measure(i).cube;
    end if;
  end loop;
  l_property_value:='AND (';
  for i in 1..l_cubes.count loop
    l_property_value:=l_property_value||'arg(2) EQ \'''||l_cubes(i)||',\'' OR ';
  end loop;
  l_property_value:=substr(l_property_value,1,length(l_property_value)-3);
  l_property_value:=l_property_value||') AND arg(3) EQ \''partition='||template_partition.partition_name||',\'' ';
  bsc_aw_utility.merge_property(l_data_source.property,'datasource filter',null,l_property_value);
  bsc_aw_utility.merge_property(l_data_source.property,'partition',null,template_partition.partition_name);
  --
  create_kpi_program(p_kpi,p_dim_set,l_data_source);
Exception when others then
  log_n('Exception in create_kpi_program_partition '||sqlerrm);
  raise;
End;

/*
used to create the program where measures and limit cubes run in parallel
*/
procedure create_kpi_program_limit_cube(
p_kpi kpi_r,
p_dim_set dim_set_r,
p_data_source data_source_r) is
l_ordered_b_tables dbms_sql.varchar2_table;
Begin
  for i in 1..p_data_source.base_tables.count loop
    bsc_aw_utility.merge_value(l_ordered_b_tables,p_data_source.base_tables(i).base_table_name);
  end loop;
  l_ordered_b_tables:=bsc_aw_utility.order_array(l_ordered_b_tables);
  bsc_aw_utility.add_g_commands(g_commands,'if arg(1) EQ \'''||bsc_aw_utility.make_string_from_list(l_ordered_b_tables)||'\'' --');
  bsc_aw_utility.add_g_commands(g_commands,' AND arg(2) EQ \''LIMIT CUBE\'' ');
  bsc_aw_utility.add_g_commands(g_commands,'then do');
  create_temp_variables(p_dim_set,p_data_source);
  for i in 1..p_data_source.data_source_stmt.count loop
    if p_data_source.data_source_stmt_type(i)='sql from' then
      if substr(bsc_aw_utility.get_g_commands(g_commands,null),-4)=', --' then
        bsc_aw_utility.trim_g_commands(g_commands,4,' --'); --remove the trailing ,
      end if;
    end if;
    if substr(p_data_source.data_source_stmt_type(i),1,3)='sql' or
    substr(p_data_source.data_source_stmt_type(i),1,10)='dimension=' or
    substr(p_data_source.data_source_stmt_type(i),1,10)='temp time=' or
    substr(p_data_source.data_source_stmt_type(i),1,11)='limit cube=' then
      bsc_aw_utility.add_g_commands(g_commands,p_data_source.data_source_stmt(i)||' --');
    end if;
  end loop;
  bsc_aw_utility.trim_g_commands(g_commands,3,null);
  create_dim_match_header(p_data_source);
  create_limit_cube_tail(p_data_source);
  bsc_aw_utility.trim_g_commands(g_commands,3,null);
  bsc_aw_utility.add_g_commands(g_commands,'sql close c1');
  bsc_aw_utility.add_g_commands(g_commands,'sql cleanup');
  bsc_aw_utility.add_g_commands(g_commands,'doend');
Exception when others then
  log_n('Exception in create_kpi_program_limit_cube '||sqlerrm);
  raise;
End;

/*
used in create_kpi_program to see if we need to use sql fetch c1 loop into or import
import is faster but filter has hardcoded numbers that import does not allow.
*/
function is_filter_in_data_source(
p_data_source data_source_r
)return varchar2 is
Begin
  for i in 1..p_data_source.dim.count loop
    if p_data_source.dim(i).levels(1).filter.count > 0 then
      return 'Y';
    end if;
  end loop;
  return 'N';
Exception when others then
  log_n('Exception in is_filter_in_data_source '||sqlerrm);
  raise;
End;

function is_balance_last_value_in_DS(p_data_source data_source_r) return varchar2 is
Begin
  for i in 1..p_data_source.measure.count loop
    if p_data_source.measure(i).measure_type=g_balance_last_value_prop then
      return 'Y';
    end if;
  end loop;
  return 'N';
Exception when others then
  log_n('Exception in is_balance_last_value_in_DS '||sqlerrm);
  raise;
End;

/*
creates the S views. we dont create the SB views since they are never queried directly
we do have SB cubes though

create kpi view and create type must be autonomous transactions. otherwise, they result in
implicit commit
*/
procedure create_kpi_view(p_kpi in out nocopy kpi_r) is
PRAGMA AUTONOMOUS_TRANSACTION;
Begin
  for i in 1..p_kpi.dim_set.count loop
    create_kpi_view(p_kpi,p_kpi.dim_set(i));
  end loop;
Exception when others then
  log_n('Exception in create_kpi_view '||sqlerrm);
  raise;
End;

procedure create_kpi_view(p_kpi kpi_r,p_dim_set in out nocopy dim_set_r) is
PRAGMA AUTONOMOUS_TRANSACTION;
Begin
  create_db_type(p_kpi,p_dim_set);
  --std S MV
  for i in 1..p_dim_set.s_view.count loop
    create_kpi_view(p_kpi,p_dim_set,p_dim_set.s_view(i),'mv');
  end loop;
  --
  --Zero code MV
  for i in 1..p_dim_set.z_s_view.count loop
    create_kpi_view(p_kpi,p_dim_set,p_dim_set.z_s_view(i),'zmv');
  end loop;
Exception when others then
  log_n('Exception in create_kpi_view '||sqlerrm);
  raise;
End;

/*s view dim have 1 level
*/
procedure create_kpi_view(p_kpi kpi_r,p_dim_set dim_set_r,p_s_view s_view_r,p_type varchar2) is
PRAGMA AUTONOMOUS_TRANSACTION;
--
l_dimensions dbms_sql.varchar2_table;
l_outer_measures dbms_sql.varchar2_table;
l_outer_measure_agg_types dbms_sql.varchar2_table;
l_outer_measure_aggregations dbms_sql.varchar2_table;/*holds the agg formula */
l_inner_measures dbms_sql.varchar2_table;
l_inner_select_columns dbms_sql.varchar2_table;
l_inner_select_column_types dbms_sql.varchar2_table;/*fk or measure */
l_name varchar2(30);
l_inner_stmt varchar2(32000);
l_sql_agg_stmt varchar2(32000);
sql_aggregation boolean;
Begin
  sql_aggregation:=false;
  l_inner_stmt:=' from table (
  olap_table('''||bsc_aw_management.get_aw_workspace_name||' duration session'','''||p_s_view.type_table_name||''','''',
  ''';
  for i in 1..p_s_view.dim.count loop
    if p_s_view.dim(i).levels(1).level_type='normal' then
      if p_s_view.dim(i).base_value_cube is not null then
        --use get_hash to make sure we are within 30 chars
        l_name:='D_'||bsc_aw_utility.get_hash_value(p_s_view.dim(i).dim_name||'.'||p_s_view.dim(i).levels(1).level_name||'.'||i,
        100,1073741824);
        l_inner_stmt:=l_inner_stmt||' dimension '||l_name||' from '||p_s_view.dim(i).dim_name||bsc_aw_utility.g_newline;
        l_dimensions(l_dimensions.count+1):=l_name;
        l_inner_stmt:=l_inner_stmt||' with attribute '||p_s_view.dim(i).levels(1).fk||' from '||p_s_view.dim(i).base_value_cube||
        bsc_aw_utility.g_newline;
        l_inner_measures(l_inner_measures.count+1):=p_s_view.dim(i).levels(1).fk;
        l_inner_select_columns(l_inner_select_columns.count+1):=p_s_view.dim(i).levels(1).fk;
        l_inner_select_column_types(l_inner_select_column_types.count+1):='fk';
      else
        --if a rec dim, we must be referncing  the parent level
        if p_s_view.dim(i).levels(1).rec_parent_level is not null then
          l_inner_stmt:=l_inner_stmt||' dimension '||p_s_view.dim(i).levels(1).fk||' from '||p_s_view.dim(i).levels(1).rec_parent_level||'
          ';
          /*elsif p_type='zmv' and p_s_view.dim(i).levels(1).zero_code_level is not null then
          l_inner_stmt:=l_inner_stmt||' dimension '||p_s_view.dim(i).levels(1).fk||' from '||p_s_view.dim(i).levels(1).zero_code_level||'
          ';
          cannot have this...the zero code mv must be based on regular levels. if we base it on zero code level
          how can we limit dim to any other value? zero code mv has 0 and other values.
          so we need to limit zero code levelto 0, limit dim to zero code level, then limit level to 0
          so when we query from the mv, we will see the level value as 0 and also see the measure value for "all"
          */
        else
          l_inner_stmt:=l_inner_stmt||' dimension '||p_s_view.dim(i).levels(1).fk||' from '||p_s_view.dim(i).levels(1).level_name||'
          ';
        end if;
        l_inner_measures(l_inner_measures.count+1):=p_s_view.dim(i).levels(1).fk;
        l_inner_select_columns(l_inner_select_columns.count+1):=p_s_view.dim(i).levels(1).fk;
        l_inner_select_column_types(l_inner_select_column_types.count+1):='fk';
      end if;
    end if;
  end loop;
  --std dim
  for i in 1..p_dim_set.std_dim.count loop
    l_inner_stmt:=l_inner_stmt||' dimension '||p_dim_set.std_dim(i).levels(1).fk||' from '||p_dim_set.std_dim(i).levels(1).level_name||'
    ';
    l_dimensions(l_dimensions.count+1):=p_dim_set.std_dim(i).levels(1).fk;
    l_inner_select_columns(l_inner_select_columns.count+1):=p_dim_set.std_dim(i).levels(1).fk;
    l_inner_select_column_types(l_inner_select_column_types.count+1):='fk';
    --assume std dim are non concat?
  end loop;
  --time
  --all s views have period and year and periodicity
  l_inner_stmt:=l_inner_stmt||' measure period from period_cal_'||p_kpi.calendar||'
  measure year from year_cal_'||p_kpi.calendar||'
  measure periodicity_id from periodicity_cal_'||p_kpi.calendar||'
  ';
  l_inner_measures(l_inner_measures.count+1):='period';
  l_inner_measures(l_inner_measures.count+1):='year';
  l_inner_measures(l_inner_measures.count+1):='periodicity_id';
  l_inner_select_columns(l_inner_select_columns.count+1):='period';
  l_inner_select_column_types(l_inner_select_column_types.count+1):='fk';
  l_inner_select_columns(l_inner_select_columns.count+1):='year';
  l_inner_select_column_types(l_inner_select_column_types.count+1):='fk';
  l_inner_select_columns(l_inner_select_columns.count+1):='periodicity_id';
  l_inner_select_column_types(l_inner_select_column_types.count+1):='fk';
  for i in 1..p_dim_set.measure.count loop
    l_outer_measures(l_outer_measures.count+1):=p_dim_set.measure(i).measure;
    l_outer_measure_aggregations(l_outer_measure_aggregations.count+1):=p_dim_set.measure(i).agg_formula.sql_agg_formula;
    if p_dim_set.measure(i).sql_aggregated='N' then
      l_outer_measure_agg_types(l_outer_measure_agg_types.count+1):='std';
      l_inner_stmt:=l_inner_stmt||' measure '||p_dim_set.measure(i).measure||' from ';
      if p_dim_set.measure(i).aw_formula.formula_name is not null then
        l_inner_stmt:=l_inner_stmt||p_dim_set.measure(i).aw_formula.formula_name;
      else
        l_inner_stmt:=l_inner_stmt||p_dim_set.measure(i).cube;
      end if;
      l_inner_stmt:=l_inner_stmt||'
      ';
      l_inner_measures(l_inner_measures.count+1):=p_dim_set.measure(i).measure;
      l_inner_select_columns(l_inner_select_columns.count+1):=p_dim_set.measure(i).measure;
      l_inner_select_column_types(l_inner_select_column_types.count+1):='measure';
    else
      sql_aggregation:=true;
      l_outer_measure_agg_types(l_outer_measure_agg_types.count+1):='non std';
    end if;
  end loop;
  l_inner_stmt:=l_inner_stmt||'''))';
  if bsc_aw_utility.get_db_version>10.1 and l_dimensions.count>0 and l_inner_measures.count>0 then
    l_inner_stmt:=l_inner_stmt||bsc_aw_utility.g_newline;
    l_inner_stmt:=l_inner_stmt||'model'||bsc_aw_utility.g_newline;
    l_inner_stmt:=l_inner_stmt||'UNIQUE SINGLE REFERENCE'||bsc_aw_utility.g_newline;
    l_inner_stmt:=l_inner_stmt||'dimension by('||bsc_aw_utility.g_newline;
    for i in 1..l_dimensions.count loop
      if i=1 then
        l_inner_stmt:=l_inner_stmt||l_dimensions(i)||bsc_aw_utility.g_newline;
      else
        l_inner_stmt:=l_inner_stmt||','||l_dimensions(i)||bsc_aw_utility.g_newline;
      end if;
    end loop;
    l_inner_stmt:=l_inner_stmt||')'||bsc_aw_utility.g_newline;
    l_inner_stmt:=l_inner_stmt||'measures('||bsc_aw_utility.g_newline;
    for i in 1..l_inner_measures.count loop
      if i=1 then
        l_inner_stmt:=l_inner_stmt||l_inner_measures(i)||bsc_aw_utility.g_newline;
      else
        l_inner_stmt:=l_inner_stmt||','||l_inner_measures(i)||bsc_aw_utility.g_newline;
      end if;
    end loop;
    l_inner_stmt:=l_inner_stmt||')'||bsc_aw_utility.g_newline;
    l_inner_stmt:=l_inner_stmt||'rules update sequential order()';
  end if;
  /*if there is sql agg for non std measures (when there are non std agg and partitions), we need to create the stmt as (AVGBUG is the formula)
  create or replace view testv as
  select PER_CODE,COUNTRY_CODE,TYPE,PROJECTION,period,year,periodicity_id,BUGLOG,BUGLOG/BUGOPEN AVGBUG
  from(
  select PER_CODE,COUNTRY_CODE,TYPE,PROJECTION,period,year,periodicity_id,sum(BUGLOG) BUGLOG,sum(BUGOPEN) BUGOPEN
  from
  (select PER_CODE,COUNTRY_CODE,TYPE,PROJECTION,period,year,periodicity_id,BUGLOG,BUGOPEN
  from table (  olap_table( ...
  ...
  rules update sequential order())
  group by PER_CODE,COUNTRY_CODE,TYPE,PROJECTION,period,year,periodicity_id)
  */
  g_stmt:='create or replace view '||p_s_view.s_view||' as select ';
  if sql_aggregation then
    for i in 1..l_inner_select_columns.count loop
      if l_inner_select_column_types(i)='fk' then
        g_stmt:=g_stmt||l_inner_select_columns(i)||',';
      end if;
    end loop;
    /*now the measures */
    for i in 1..l_outer_measures.count loop
      if l_outer_measure_agg_types(i)='std' then
        g_stmt:=g_stmt||l_outer_measures(i)||',';
      else/*non std */
        g_stmt:=g_stmt||'('||l_outer_measure_aggregations(i)||') '||l_outer_measures(i)||',';
      end if;
    end loop;
    /*now the second part */
    g_stmt:=substr(g_stmt,1,length(g_stmt)-1);
    g_stmt:=g_stmt||bsc_aw_utility.g_newline;
    g_stmt:=g_stmt||'from (select ';
    for i in 1..l_inner_select_columns.count loop
      if l_inner_select_column_types(i)='fk' then
        g_stmt:=g_stmt||l_inner_select_columns(i)||',';
      end if;
    end loop;
    for i in 1..l_outer_measures.count loop
      if l_outer_measure_agg_types(i)='std' then
        g_stmt:=g_stmt||l_outer_measure_aggregations(i)||'('||l_outer_measures(i)||') '||l_outer_measures(i)||',';
      end if;
    end loop;
    g_stmt:=substr(g_stmt,1,length(g_stmt)-1);
    g_stmt:=g_stmt||bsc_aw_utility.g_newline;
    g_stmt:=g_stmt||'from (select ';
  end if;
  for i in 1..l_inner_select_columns.count loop
    g_stmt:=g_stmt||l_inner_select_columns(i)||',';
  end loop;
  g_stmt:=substr(g_stmt,1,length(g_stmt)-1);
  g_stmt:=g_stmt||l_inner_stmt;
  if sql_aggregation then
    g_stmt:=g_stmt||')'||bsc_aw_utility.g_newline;
    g_stmt:=g_stmt||'group by ';
    for i in 1..l_inner_select_columns.count loop
      if l_inner_select_column_types(i)='fk' then
        g_stmt:=g_stmt||l_inner_select_columns(i)||',';
      end if;
    end loop;
    g_stmt:=substr(g_stmt,1,length(g_stmt)-1);
    g_stmt:=g_stmt||')';
  end if;
  bsc_aw_utility.execute_ddl(g_stmt);
Exception when others then
  log_n('Exception in create_kpi_view '||sqlerrm);
  raise;
End;

/*
this procedure creates the database type and table of type so that we can build the olap table
function on top of this
we have to create a type for each s view since the column names have to match if we are going to go
with the model of having 2 views , the second view doing to_number(), then we only need one type
per dim set. for now, we create a type per s view

we can create one type object for all the views in a dims set,. this would mean that all upper levels
of a dim also share the same data type. can we assume this?
if City is varchar2 and State is number, then we have a problem. in our implementation, all dim are TEXT. so
we can assume this.
this will not work because if we have one type with col names FK_1, FK_2 etc, then the views created will also
have these column names. this will not do. so each s view must have its own type
*/
procedure create_db_type(p_kpi kpi_r,p_dim_set in out nocopy dim_set_r) is
PRAGMA AUTONOMOUS_TRANSACTION;
Begin
  for i in 1..p_dim_set.s_view.count loop
    create_db_type(p_kpi.kpi,p_dim_set,p_dim_set.s_view(i));
  end loop;
  for i in 1..p_dim_set.z_s_view.count loop
    create_db_type(p_kpi.kpi,p_dim_set,p_dim_set.z_s_view(i));
  end loop;
Exception when others then
  log_n('Exception in create_db_type '||sqlerrm);
  raise;
End;

procedure create_db_type(p_kpi varchar2,p_dim_set dim_set_r,p_s_view in out nocopy s_view_r) is
PRAGMA AUTONOMOUS_TRANSACTION;
--
l_name varchar2(30);
Begin
  p_s_view.type_name:='type_'||p_kpi||'_'||p_dim_set.dim_set||'_'||p_s_view.id;
  p_s_view.type_table_name:=p_s_view.type_name||'_tab';
  g_stmt:='drop type '||p_s_view.type_table_name;
  bsc_aw_utility.execute_ddl_ne(g_stmt);
  g_stmt:='drop type '||p_s_view.type_name;
  bsc_aw_utility.execute_ddl_ne(g_stmt);
  g_stmt:='create or replace type '||p_s_view.type_name||' as object (';
  for i in 1..p_s_view.dim.count loop
    if p_s_view.dim(i).levels(1).level_type='normal' then
      if p_s_view.dim(i).base_value_cube is not null then
        l_name:='D_'||bsc_aw_utility.get_hash_value(p_s_view.dim(i).dim_name||'.'||p_s_view.dim(i).levels(1).level_name||'.'||i,
        100,1073741824);
        g_stmt:=g_stmt||l_name||' varchar2(800),';
      end if;
      g_stmt:=g_stmt||p_s_view.dim(i).levels(1).fk||' '||p_s_view.dim(i).levels(1).data_type||',';
    end if;
  end loop;
  --std dim
  for j in 1..p_dim_set.std_dim.count loop
    g_stmt:=g_stmt||p_dim_set.std_dim(j).levels(1).fk||' '||p_dim_set.std_dim(j).levels(1).data_type||',';
  end loop;
  --time
  g_stmt:=g_stmt||'period number,year number,periodicity_id number,';
  for j in 1..p_dim_set.measure.count loop
    g_stmt:=g_stmt||p_dim_set.measure(j).measure||' '||p_dim_set.measure(j).data_type||',';
  end loop;
  g_stmt:=substr(g_stmt,1,length(g_stmt)-1)||')';
  bsc_aw_utility.execute_ddl(g_stmt);
  --create the table of type
  g_stmt:='create or replace type '||p_s_view.type_table_name||' as table of '||p_s_view.type_name;
  bsc_aw_utility.execute_ddl(g_stmt);
Exception when others then
  log_n('Exception in create_db_type '||sqlerrm);
  raise;
End;

/*
dmp the kpi record and all its properties
*/
procedure dmp_kpi(p_kpi kpi_r) is
Begin
  log_n('KPI Dmp');
  log('---------------------------------');
  log('KPI '||p_kpi.kpi);
  log('Dim Sets');
  for i in 1..p_kpi.dim_set.count loop
    log(p_kpi.dim_set(i).dim_set);
  end loop;
  log('Calendar');
  log(p_kpi.calendar);
  log('KPI Dim Set Parameters =');
  for i in 1..p_kpi.dim_set.count loop
    dmp_dimset(p_kpi.dim_set(i));
  end loop;
  log('================================================');
  log('================================================');
  log('KPI Target Dim Set Parameters =');
  for i in 1..p_kpi.target_dim_set.count loop
    dmp_dimset(p_kpi.target_dim_set(i));
  end loop;
Exception when others then
  log_n('Exception in dmp_kpi '||sqlerrm);
  raise;
End;

procedure dmp_dimset(p_dim_set dim_set_r) is
Begin
  if p_dim_set.dim_set is null then
    return;
  end if;
  log('----------------------------------------');
  log('Dmp Dim Set ='||p_dim_set.dim_set||', Dim Set Name ='||p_dim_set.dim_set_name);
  log('Dim Set Type='||p_dim_set.dim_set_type);
  log('Dim Set Aggmap Operators shared across Agg Maps');
  dmp_agg_map_operator(p_dim_set.aggmap_operator);
  dmp_agg_map(p_dim_set.agg_map);
  dmp_agg_map(p_dim_set.agg_map_notime);
  log('Initial Load Program='||p_dim_set.initial_load_program.program_name||', Inc Load Program='||p_dim_set.inc_load_program.program_name);
  dmp_calendar(p_dim_set.calendar);
  log('Dimensions =('||p_dim_set.dim.count||')');
  for i in 1..p_dim_set.dim.count loop
    dmp_dim(p_dim_set.dim(i));
  end loop;
  log('Std Dimensions =('||p_dim_set.std_dim.count||')');
  for i in 1..p_dim_set.std_dim.count loop
    dmp_dim(p_dim_set.std_dim(i));
  end loop;
  log('Targets at higher level? '||p_dim_set.targets_higher_levels);
  log('Measures =');
  for i in 1..p_dim_set.measure.count loop
    dmp_measure(p_dim_set.measure(i));
  end loop;
  log('Dimset Properties');
  log('Measurename Dim='||p_dim_set.measurename_dim);
  log('Partition Dim='||p_dim_set.partition_dim);
  log('Cube design='||p_dim_set.cube_design);
  log('Number partitions='||p_dim_set.number_partitions);
  log('Compressed='||p_dim_set.compressed);
  log('Partition Template');
  for i in 1..p_dim_set.partition_template.count loop
    dmp_partition_template(p_dim_set.partition_template(i));
  end loop;
  for i in 1..p_dim_set.composite.count loop
    dmp_composite(p_dim_set.composite(i));
  end loop;
  for i in 1..p_dim_set.cube_set.count loop
    dmp_cube_set(p_dim_set.cube_set(i));
  end loop;
  --
  log('Initial Data Source=');
  dmp_data_source(p_dim_set.data_source);
  log('Inc Data Source=');
  dmp_data_source(p_dim_set.inc_data_source);
  --
  log('S Views=');
  for i in 1..p_dim_set.s_view.count loop
    log('S View '||p_dim_set.s_view(i).s_view||', ID='||p_dim_set.s_view(i).id);
    log('S view levels ');
    for j in 1..p_dim_set.s_view(i).dim.count loop
      log('Dim '||p_dim_set.s_view(i).dim(j).dim_name);
      log('Levels');
      for k in 1..p_dim_set.s_view(i).dim(j).levels.count loop
        log(p_dim_set.s_view(i).dim(j).levels(k).level_name);
      end loop;
    end loop;
  end loop;
  --
  log('Z S Views=');
  for i in 1..p_dim_set.z_s_view.count loop
    log('S View '||p_dim_set.z_s_view(i).s_view||', ID='||p_dim_set.z_s_view(i).id);
    log('S view levels ');
    for j in 1..p_dim_set.z_s_view(i).dim.count loop
      log('Dim '||p_dim_set.z_s_view(i).dim(j).dim_name);
      log('Levels');
      for k in 1..p_dim_set.z_s_view(i).dim(j).levels.count loop
        log(p_dim_set.z_s_view(i).dim(j).levels(k).level_name);
      end loop;
    end loop;
  end loop;
  log('--------------------');
Exception when others then
  log_n('Exception in dmp_dimset '||sqlerrm);
  raise;
End;

procedure dmp_measure(p_measure measure_r) is
Begin
  log(p_measure.measure||' type='||p_measure.measure_type||' data type='||p_measure.data_type);
  log('formula='||p_measure.formula||' agg formula='||p_measure.agg_formula.agg_formula||', std agg='||
  p_measure.agg_formula.std_aggregation);
  log('forecast='||p_measure.forecast||', forecast method='||p_measure.forecast_method);
  log('cube='||p_measure.cube||', countvar cube='||p_measure.countvar_cube||', fcst cube='||p_measure.fcst_cube);
  if p_measure.agg_formula.std_aggregation='N' then
    log('Agg formula cubes');
    for i in 1..p_measure.agg_formula.cubes.count loop
      log(p_measure.agg_formula.cubes(i));
    end loop;
  end if;
Exception when others then
  log_n('Exception in dmp_measure '||sqlerrm);
  raise;
End;

procedure dmp_agg_map(p_agg_map agg_map_r) is
Begin
  log('Agg Map ='||p_agg_map.agg_map);
  log('  Property='||p_agg_map.property);
  dmp_agg_map_operator(p_agg_map.aggmap_operator);
Exception when others then
  log_n('Exception in dmp_agg_map '||sqlerrm);
  raise;
End;

procedure dmp_agg_map_operator(p_agg_map_operator aggmap_operator_r) is
Begin
  log('Agg Map.Measure_dim='||p_agg_map_operator.measure_dim);
  log('Agg Map.Opvar='||p_agg_map_operator.opvar);
  log('Agg Map.Argvar='||p_agg_map_operator.argvar);
Exception when others then
  log_n('Exception in dmp_agg_map_operator '||sqlerrm);
  raise;
End;

procedure dmp_dim(p_dim dim_r) is
Begin
  log('Dim '||p_dim.dim_name||' prop='||p_dim.property||' rec='||
  p_dim.recursive||' multi-level='||p_dim.multi_level||' zero code='||
  p_dim.zero_code||', concat='||p_dim.concat);
  log('limit cube='||p_dim.limit_cube||', limit cube composite='||p_dim.limit_cube_composite||
  ',reset cube='||p_dim.reset_cube||',aggregate marker='||p_dim.aggregate_marker||',agg map='||
  p_dim.agg_map.agg_map||', agg level='||p_dim.agg_level);
  log('Dim Levels =');
  for i in 1..p_dim.levels.count loop
    log(p_dim.levels(i).level_name||' type='||p_dim.levels(i).level_type||' pk='||
    p_dim.levels(i).pk||' fk='||p_dim.levels(i).fk||' data type='||
    p_dim.levels(i).data_type||' zero code='||p_dim.levels(i).zero_code||', zero code level='||p_dim.levels(i).zero_code_level||
    ', position='||p_dim.levels(i).position||',property='||p_dim.levels(i).property);
    log('filter=');
    for j in 1..p_dim.levels(i).filter.count loop
      log(p_dim.levels(i).filter(j));
    end loop;
  end loop;
  log('Dim Level Relations =');
  for i in 1..p_dim.parent_child.count loop
    log('Parent='||p_dim.parent_child(i).parent_level||', pk='||p_dim.parent_child(i).parent_pk||','||
    'Child='||p_dim.parent_child(i).child_level||',fk='||p_dim.parent_child(i).child_fk);
  end loop;
Exception when others then
  log_n('Exception in dmp_dim '||sqlerrm);
  raise;
End;

procedure dmp_data_source(p_data_source data_source_tb) is
Begin
  for i in 1..p_data_source.count loop
    log('Data Source -> '||i);
    dmp_data_source(p_data_source(i));
  end loop;
Exception when others then
  log_n('Exception in dmp_data_source '||sqlerrm);
  raise;
End;

procedure dmp_data_source(p_data_source data_source_r) is
Begin
  log('DS type='||p_data_source.ds_type);
  log('partition_dim='||p_data_source.data_source_PT.partition_template.template_dim);
  log('DS properties');
  for i in 1..p_data_source.property.count loop
    log(p_data_source.property(i).property_name||' '||p_data_source.property(i).property_type||' '||
    p_data_source.property(i).property_value);
  end loop;
  log('Data Source Dimensions=');
  for i in 1..p_data_source.dim.count loop
    dmp_dim(p_data_source.dim(i));
  end loop;
  log('Data Source Std dimensions=');
  for i in 1..p_data_source.std_dim.count loop
    dmp_dim(p_data_source.std_dim(i));
  end loop;
  dmp_calendar(p_data_source.calendar);
  log('Data Source Measures=');
  for i in 1..p_data_source.measure.count loop
    log(p_data_source.measure(i).measure||' cube='||p_data_source.measure(i).cube);
  end loop;
  log('Base Tables=');
  for i in 1..p_data_source.base_tables.count loop
    log(p_data_source.base_tables(i).base_table_name);
    log('Base Table periodicity >'||p_data_source.base_tables(i).periodicity.periodicity);
    log('Current period>'||p_data_source.base_tables(i).current_period);
    log('Base Table Levels');
    for j in 1..p_data_source.base_tables(i).levels.count loop
      log(p_data_source.base_tables(i).levels(j).level_name||', feed='||p_data_source.base_tables(i).feed_levels(j));
    end loop;
    dmp_table_partition(p_data_source.base_tables(i).table_partition);
  end loop;
  log('Data Source Stmt =');
  for i in 1..p_data_source.data_source_stmt.count loop
    log(p_data_source.data_source_stmt(i));
  end loop;
Exception when others then
  log_n('Exception in dmp_data_source '||sqlerrm);
  raise;
End;

procedure dmp_table_partition(p_partition bsc_aw_utility.object_partition_r) is
Begin
  log('Table partitions');
  log('Main partition:-');
  dmp_partition_set(p_partition.main_partition);
  log('Sub partition:-');
  dmp_partition_set(p_partition.sub_partition);
Exception when others then
  log_n('Exception in dmp_table_partition '||sqlerrm);
  raise;
End;

procedure dmp_partition_set(p_partition_set bsc_aw_utility.partition_set_r) is
Begin
  log('Partition set '||p_partition_set.set_name);
  if p_partition_set.set_name is not null then
    log('Partition type '||p_partition_set.partition_type);
    log('Partition Column '||p_partition_set.partition_column);
    log('Partition Column Data Type '||p_partition_set.partition_column_data_type);
    for i in 1..p_partition_set.partitions.count loop
      log('Partition Name '||p_partition_set.partitions(i).partition_name);
      log('Partition Value '||p_partition_set.partitions(i).partition_value);
      log('Partition Position '||p_partition_set.partitions(i).partition_position);
    end loop;
  end if;
Exception when others then
  log_n('Exception in dmp_partition_set '||sqlerrm);
  raise;
End;

procedure dmp_calendar(p_calendar calendar_r) is
Begin
  log('Calendar '||p_calendar.calendar||' dim='||p_calendar.aw_dim||' relation='||
  p_calendar.relation_name||', denorm relation='||p_calendar.denorm_relation_name);
  log('Limit cube='||p_calendar.limit_cube||', Limit cube composite='||p_calendar.limit_cube_composite||
  ', aggregate marker='||p_calendar.aggregate_marker);
  log('Periodicities');
  for i in 1..p_calendar.periodicity.count loop
    log('Periodicity='||p_calendar.periodicity(i).periodicity||' dim='||p_calendar.periodicity(i).aw_dim||
    ', property='||p_calendar.periodicity(i).property||', lowest level='||p_calendar.periodicity(i).lowest_level||', missing level='||
    p_calendar.periodicity(i).missing_level);
  end loop;
  log('Periodicitie Relations');
  for i in 1..p_calendar.parent_child.count loop
    log('Parent='||p_calendar.parent_child(i).parent_dim_name||', Parent periodicity='||
    p_calendar.parent_child(i).parent||',Child='||p_calendar.parent_child(i).child_dim_name||',Child periodicity='||
    p_calendar.parent_child(i).child);
  end loop;
Exception when others then
  log_n('Exception in dmp_calendar '||sqlerrm);
  raise;
End;

procedure dmp_partition_template(p_partition_template partition_template_r) is
Begin
  log('Partition Template:-');
  log('Template name='||p_partition_template.template_name);
  log('Template type='||p_partition_template.template_type);
  log('Template use='||p_partition_template.template_use);
  log('Template dim='||p_partition_template.template_dim);
  log('hpt data');
  dmp_hpt_data(p_partition_template.hpt_data);
  log('Template dimensions');
  for i in 1..p_partition_template.template_dimensions.count loop
    log(p_partition_template.template_dimensions(i));
  end loop;
  log('Partitions:-');
  for i in 1..p_partition_template.template_partitions.count loop
    dmp_partition(p_partition_template.template_partitions(i));
  end loop;
Exception when others then
  log_n('Exception in dmp_partition_template '||sqlerrm);
  raise;
End;

procedure dmp_partition(p_partition partition_r) is
Begin
  log('Partition name='||p_partition.partition_name);
  log('Partition Dim Value='||p_partition.partition_dim_value);
  for i in 1..p_partition.partition_axis.count loop
    dmp_axis(p_partition.partition_axis(i));
  end loop;
Exception when others then
  log_n('Exception in dmp_partition '||sqlerrm);
  raise;
End;

procedure dmp_axis(p_axis axis_r) is
Begin
  log('Axis name='||p_axis.axis_name||', Axis type='||p_axis.axis_type);
Exception when others then
  log_n('Exception in dmp_axis '||sqlerrm);
  raise;
End;

procedure dmp_composite(p_composite composite_r) is
Begin
  log('Composite name='||p_composite.composite_name);
  log('Composite type='||p_composite.composite_type);
  log('Composite dimensions');
  for i in 1..p_composite.composite_dimensions.count loop
    log(p_composite.composite_dimensions(i));
  end loop;
Exception when others then
  log_n('Exception in dmp_composite '||sqlerrm);
  raise;
End;

procedure dmp_cube_set(p_cube_set cube_set_r) is
Begin
  log('Cube set name='||p_cube_set.cube_set_name||', Cube set type='||p_cube_set.cube_set_type);
  log('Measurename Dim='||p_cube_set.measurename_dim);
  log('Cube:-');
  dmp_cube(p_cube_set.cube);
  log('Fcst Cube:-');
  dmp_cube(p_cube_set.fcst_cube);
  log('Countvar Cube:-');
  dmp_cube(p_cube_set.countvar_cube);
Exception when others then
  log_n('Exception in dmp_cube_set '||sqlerrm);
  raise;
End;

procedure dmp_cube(p_cube cube_r) is
Begin
  log('Cube name='||p_cube.cube_name);
  log('Cube type='||p_cube.cube_type);
  log('Cube datatype='||p_cube.cube_datatype);
  for i in 1..p_cube.cube_axis.count loop
    dmp_axis(p_cube.cube_axis(i));
  end loop;
Exception when others then
  log_n('Exception in dmp_cube '||sqlerrm);
  raise;
End;

/*
every kpi has the type and projection dim attached to it. this api adds these std dimensions
to the kpi dimset
*/
procedure get_dim_set_std_dims(
p_kpi varchar2,
p_dim_set in out nocopy dim_set_r) is
--
Begin
  p_dim_set.std_dim(1):=null;
  p_dim_set.std_dim(2):=null;
  get_dim_set_std_dim_type(p_kpi,p_dim_set.std_dim(1));
  get_dim_set_std_dim_projection(p_kpi,p_dim_set.std_dim(2));
Exception when others then
  log_n('Exception in get_dim_set_std_dims '||sqlerrm);
  raise;
End;

--adds TYPE dim to the dim of the dimset
procedure get_dim_set_std_dim_type(
p_kpi varchar2,
p_dim in out nocopy dim_r) is
--
l_dim varchar2(300);
Begin
  bsc_aw_md_api.get_dim_for_level('TYPE',l_dim);
  p_dim.dim_name:=l_dim;
  p_dim.zero_code:='N';
  p_dim.relation_name:=null;
  p_dim.property:='normal';
  p_dim.recursive:='N';
  p_dim.multi_level:='N';
  p_dim.zero_code:='N';
  p_dim.agg_level:=0;
  p_dim.levels(1).level_name:='TYPE';
  p_dim.levels(1).level_type:='normal';
  p_dim.levels(1).pk:='TYPE';
  p_dim.levels(1).fk:='TYPE';
  p_dim.levels(1).data_type:='varchar2(100)';
  p_dim.levels(1).zero_code:='N';
  p_dim.levels(1).position:=1;
Exception when others then
  log_n('Exception in get_dim_set_std_dim_type '||sqlerrm);
  raise;
End;

--adds TYPE dim to the dim of the dimset
procedure get_dim_set_std_dim_projection(
p_kpi varchar2,
p_dim in out nocopy dim_r) is
--
l_dim varchar2(300);
Begin
  bsc_aw_md_api.get_dim_for_level('PROJECTION',l_dim);
  p_dim.dim_name:=l_dim;
  p_dim.zero_code:='N';
  p_dim.relation_name:=null;
  p_dim.property:='normal';
  p_dim.recursive:='N';
  p_dim.multi_level:='N';
  p_dim.zero_code:='N';
  p_dim.agg_level:=0;
  p_dim.levels(1).level_name:='PROJECTION';
  p_dim.levels(1).level_type:='normal';
  p_dim.levels(1).pk:='PROJECTION';
  p_dim.levels(1).fk:='PROJECTION';
  p_dim.levels(1).data_type:='varchar2(100)';
  p_dim.levels(1).zero_code:='N';
  p_dim.levels(1).position:=1;
Exception when others then
  log_n('Exception in get_dim_set_std_dim_projection '||sqlerrm);
  raise;
End;

/*
this procedure takes in an agg formula based on measures and then substitutes the cube names. once the cube names are in, we
can simply execute the formula

note: this changes the agg formula. it substitutes the cube names in the place of measure names

the formula is ALL CAPS
*/
procedure make_agg_formula(
p_kpi in out nocopy kpi_r
) is
Begin
  for i in 1..p_kpi.dim_set.count loop
    make_agg_formula(p_kpi.dim_set(i));
    --no need for targets since they have no agg
  end loop;
Exception when others then
  log_n('Exception in make_agg_formula '||sqlerrm);
  raise;
End;

procedure make_agg_formula(
p_dim_set in out nocopy dim_set_r
) is
Begin
  for i in 1..p_dim_set.measure.count loop
    if p_dim_set.measure(i).agg_formula.std_aggregation='N' then
      make_agg_formula(p_dim_set.measure(i),p_dim_set.measure,p_dim_set);
    end if;
  end loop;
Exception when others then
  log_n('Exception in make_agg_formula '||sqlerrm);
  raise;
End;

procedure make_agg_formula(
p_measure in out nocopy measure_r,
p_all_measures measure_tb,
p_dim_set dim_set_r
) is
--
l_agg_formula varchar2(1000);
l_start_array dbms_sql.number_table; --contains the start address of a measure in a formula
l_cube varchar2(200);
l_cube_set cube_set_r;
Begin
  l_agg_formula:=p_measure.agg_formula.agg_formula;
  if g_debug then
    log_n('In make_agg_formula, old agg formula='||l_agg_formula);
  end if;
  --search for each measure and substitute it
  for i in 1..p_all_measures.count loop
    l_start_array.delete;
    if bsc_aw_utility.is_string_present(l_agg_formula,p_all_measures(i).measure,l_start_array) then
      if l_start_array.count>0 then
        l_cube_set:=get_cube_set_r(p_all_measures(i).cube,p_dim_set);
        if l_cube_set.cube_set_type='datacube' then
          l_cube:=p_all_measures(i).cube||'('||l_cube_set.measurename_dim||' '''||p_all_measures(i).measure||''')';
        else
          l_cube:=p_all_measures(i).cube;
        end if;
        --we leave the agg_formula.cubes as the original name of the cube
        bsc_aw_utility.merge_value(p_measure.agg_formula.cubes,p_all_measures(i).cube);
        bsc_aw_utility.merge_value(p_measure.agg_formula.measures,p_all_measures(i).measure);
        bsc_aw_utility.replace_string(l_agg_formula,p_all_measures(i).measure,l_cube,l_start_array);
      end if;
    end if;
  end loop;
  if g_debug then
    log('New agg formula='||l_agg_formula);
    log('--');
  end if;
  --now change the record to reflect the agg formula with the cube
  p_measure.agg_formula.agg_formula:=l_agg_formula;
  /*agg_formula.sql_agg_formula retains the original agg formula from metadata */
Exception when others then
  log_n('Exception in make_agg_formula '||sqlerrm);
  raise;
End;

/*
this procedure decides what the agg level should be for each dim in the dim sets
the first choise is adv sum profile. it gets complicated if targets at higher levels are involved.
say adv sum profile is to state. if targets come to country level, then we have to aggregate to
country. its too complicated to handle this on-line.

since we set the agg level at the creation time, when adv sum profile changes, we have to drop the
cubes, recreate them and reload them,
this is better for aw. sotherwise, when adv sum profile is dropped from 3 to 2, how do we reclaim space
from the cubes? it gets complicated
*/
procedure set_dim_agg_level(p_kpi in out nocopy kpi_r) is
l_flag dbms_sql.varchar2_table;--to track if we do change the agg level in a target dim set
Begin
  --
  for i in 1..p_kpi.dim_set.count loop
    init_agg_level(p_kpi.dim_set(i));
  end loop;
  for i in 1..p_kpi.target_dim_set.count loop
    init_agg_level(p_kpi.target_dim_set(i));
  end loop;
  --
  for i in 1..p_kpi.target_dim_set.count loop
    l_flag(i):='N';
    --for each dim, see if the first level > adv sum profile
    for j in 1..p_kpi.target_dim_set(i).dim.count loop
      if p_kpi.target_dim_set(i).dim(j).recursive='N' then
        if p_kpi.target_dim_set(i).dim(j).levels(1).position > p_kpi.target_dim_set(i).dim(j).agg_level then
          l_flag(i):='Y';
          p_kpi.target_dim_set(i).dim(j).agg_level:=p_kpi.target_dim_set(i).dim(j).levels(1).position;
        end if;
      end if;
    end loop;
  end loop;
  --also set the agg level for the corresponding actual dimset
  for i in 1..p_kpi.target_dim_set.count loop
    if l_flag(i)='Y' then
      --get the corresponding actual dimset
      for j in 1..p_kpi.dim_set.count loop
        if p_kpi.target_dim_set(i).base_dim_set=p_kpi.dim_set(j).dim_set_name then
          for k in 1..p_kpi.target_dim_set(i).dim.count loop
            for m in 1..p_kpi.dim_set(j).dim.count loop
              if p_kpi.target_dim_set(i).dim(k).dim_name=p_kpi.dim_set(j).dim(m).dim_name then
                if p_kpi.dim_set(j).dim(m).agg_level < p_kpi.target_dim_set(i).dim(k).agg_level then
                  p_kpi.dim_set(j).dim(m).agg_level:=p_kpi.target_dim_set(i).dim(k).agg_level;
                end if;
                exit;
              end if;
            end loop;
          end loop;
          exit;
        end if;
      end loop;
    end if;
  end loop;
  for i in 1..p_kpi.dim_set.count loop
    set_dim_agg_level(p_kpi.dim_set(i));
  end loop;
  for i in 1..p_kpi.target_dim_set.count loop
    set_dim_agg_level(p_kpi.target_dim_set(i));
  end loop;
Exception when others then
  log_n('Exception in set_dim_agg_level '||sqlerrm);
  raise;
End;

/*level positions are read from bsc_olap_object. level positions are set when the dim metadata is created. so the lowest level for a kpi
need not have level position of 1 */
procedure set_dim_agg_level(p_dim_set in out nocopy dim_set_r) is
Begin
  for i in 1..p_dim_set.dim.count loop
    set_dim_agg_level(p_dim_set.dim(i));
  end loop;
Exception when others then
  log_n('Exception in set_dim_agg_level '||sqlerrm);
  raise;
End;

procedure set_dim_agg_level(p_dim in out nocopy dim_r) is
Begin
  for i in 1..p_dim.levels.count loop
    p_dim.levels(i).aggregated:='Y';
    p_dim.levels(i).zero_aggregated:=nvl(p_dim.levels(i).zero_code,'N');
    if p_dim.levels(i).position>p_dim.agg_level then
      p_dim.levels(i).aggregated:='N';
      p_dim.levels(i).zero_aggregated:='N';
    end if;
  end loop;
Exception when others then
  log_n('Exception in set_dim_agg_level '||sqlerrm);
  raise;
End;

/*set the aggregated flag for each periodicity */
procedure set_calendar_agg_level(p_kpi in out nocopy kpi_r) is
Begin
  for i in 1..p_kpi.dim_set.count loop
    set_calendar_agg_level(p_kpi.dim_set(i),p_kpi.target_dim_set(i));
  end loop;
  for i in 1..p_kpi.target_dim_set.count loop
    set_calendar_agg_level(p_kpi.target_dim_set(i));
  end loop;
Exception when others then
  log_n('Exception in set_calendar_agg_level '||sqlerrm);
  raise;
End;

/*by default, we will not aggregate on time, unless explicitly specified */
procedure set_calendar_agg_level(p_dim_set in out nocopy dim_set_r) is
aggregated boolean;
Begin
  if bsc_aw_utility.get_parameter_value('AGGREGATE TIME')='Y' then
    aggregated:=true;
  else
    aggregated:=false;
  end if;
  for i in 1..p_dim_set.calendar.periodicity.count loop
    if p_dim_set.calendar.periodicity(i).lowest_level='Y' then
      p_dim_set.calendar.periodicity(i).aggregated:='Y';
    else
      if aggregated then
        p_dim_set.calendar.periodicity(i).aggregated:='Y';
      else
        p_dim_set.calendar.periodicity(i).aggregated:='N';
      end if;
    end if;
  end loop;
Exception when others then
  log_n('Exception in set_calendar_agg_level '||sqlerrm);
  raise;
End;

/*if there are targets, we need to make sure that the level at the target is aggregated. if target is at month, we cannot just agg to
day level */
procedure set_calendar_agg_level(p_dim_set in out nocopy dim_set_r,p_target_dim_set dim_set_r) is
l_pc bsc_aw_utility.parent_child_tb;
l_child_levels dbms_sql.varchar2_table;
Begin
  set_calendar_agg_level(p_dim_set);
  if p_dim_set.targets_higher_levels='Y' then
    for i in 1..p_dim_set.calendar.parent_child.count loop
      if p_dim_set.calendar.parent_child(i).parent_dim_name is not null and p_dim_set.calendar.parent_child(i).child_dim_name is not null then
        l_pc(l_pc.count+1).parent:=p_dim_set.calendar.parent_child(i).parent_dim_name;
        l_pc(l_pc.count).child:=p_dim_set.calendar.parent_child(i).child_dim_name;
      end if;
    end loop;
    for i in 1..p_target_dim_set.calendar.periodicity.count loop
      if p_target_dim_set.calendar.periodicity(i).lowest_level='Y' then
        /*set the actual per corresponding to targets as aggregated */
        for j in 1..p_dim_set.calendar.periodicity.count loop
          if p_dim_set.calendar.periodicity(j).aw_dim=p_target_dim_set.calendar.periodicity(i).aw_dim then
            p_dim_set.calendar.periodicity(j).aggregated:='Y';
            if g_debug then
              log('Due to targets('||p_dim_set.dim_set_name||'), setting '||p_dim_set.calendar.periodicity(j).aw_dim||' aggregated flag to ''Y''');
            end if;
            --
            exit;
          end if;
        end loop;
        l_child_levels.delete;
        bsc_aw_utility.get_all_children(l_pc,p_target_dim_set.calendar.periodicity(i).aw_dim,l_child_levels);
        if l_child_levels.count>0 then
          for j in 1..p_dim_set.calendar.periodicity.count loop
            if bsc_aw_utility.in_array(l_child_levels,p_dim_set.calendar.periodicity(j).aw_dim) then
              p_dim_set.calendar.periodicity(j).aggregated:='Y';
              if g_debug then
                log('Due to targets('||p_dim_set.dim_set_name||'), setting '||p_dim_set.calendar.periodicity(j).aw_dim||' aggregated flag to ''Y''');
              end if;
            end if;
          end loop;
        end if;
      end if;
    end loop;
  end if;
Exception when others then
  log_n('Exception in set_calendar_agg_level '||sqlerrm);
  raise;
End;

procedure init_agg_level(p_dim_set in out nocopy dim_set_r) is
--
l_adv_sum_profile number;
Begin
  l_adv_sum_profile:=bsc_aw_utility.get_adv_sum_profile;
  --init the agg level to adv sum profile first
  for i in 1..p_dim_set.dim.count loop
    if p_dim_set.dim(i).recursive='Y' then
      p_dim_set.dim(i).agg_level:=1000000; --hard coded. agg all levels for rec dim
    else
      p_dim_set.dim(i).agg_level:=l_adv_sum_profile;
    end if;
  end loop;
  for i in 1..p_dim_set.std_dim.count loop
    p_dim_set.std_dim(i).agg_level:=l_adv_sum_profile;
  end loop;
Exception when others then
  log_n('Exception in init_agg_level '||sqlerrm);
  raise;
End;

/*
open: we have an issue where user can have missing levels for a kpi. they can have city and country. right now, in BSC, this is
treated as independent dimensions.
in aw, we will find out the missing levels. we will optimize to get the shortest path between the levels.
then we will make sure that the agg level for this dim is set to the max of the levels specified for the kpi. so wven if
agg level is 2, we will make it 3 since country is an independent level for the kpi
in the s views, we will have both the city and country keys. we query the s view levels. so the MO api is going to come back with
city and country. so we will end up with city and country levels and fk. also the read api must handle multiple level values being
specified for the same dim.

when this procedure is called, targets are not yet in the picture. so we do not have to think about propagating
the missing levels to targets

NOTE!!! get_dim_set_dims will return the missing levels. so we really do not need an api to create the missing levels.
now, the issue will be this. say city and country are the levels. get_dim_set_dims returns city,state and country.
if the adv sum profile is 2, then we only aggregate to state. when country is specified, we have to agg on the fly. in bsc, when
city and country are specified, both are level 1.

Other issue : what about zero code? when city and country are specified, there is zero code for both. get_zero_code_levels will
say there is zero code for both city and country.
we now have zero code in dim at all levels.
*/
procedure create_missing_dim_levels(p_kpi varchar2,p_dim_set in out nocopy dim_set_r) is
Begin
  null;
Exception when others then
  log_n('Exception in create_missing_dim_levels '||sqlerrm);
  raise;
End;

/*
user can specify city and country with no relation between each other. they become independent levels. so the cube must have
city and country as the dim, not geog.
we do this:
lets say in a dim we see levels with diff MO dim groups. this means they are independent. say
geog :
city  mo : 1
state  mo : 1
country mo : 2
region mo : 2

we group all levels associated with the lowest level into the geog dim.
all others become independent levels.

This is not possible. this is because if we dim with the concat dim, then we cannot dim by any otger level
we get this error
ORA-33376: (DUPCLCHK03) BSC_AW!BSC_D_STATE_AW and BSC_AW!BSC_CCDIM_400_401_402 cannot both appear in a dimension list because they
this means if there are more than 1 MO dim groups, we have to have all levels as snow flake.
also we need to skip missing levels.

note>>> how will we ever support multiple references to the same dim in BSC?
do we create diff copies of the dim?
*/
procedure identify_standalone_levels(
p_kpi varchar2,
p_dim_set in out nocopy dim_set_r) is
--
l_distict_mo_dim_groups dbms_sql.varchar2_table;
l_levels level_tb;
l_levels_for_new_dim level_tb;
l_dim_to_split dim_tb;
l_dim_copy dim_tb;
l_flag bsc_aw_utility.boolean_table;
l_skip_flag varchar2(40);
Begin
  --for each dim, get a list of distinct mo
  for i in 1..p_dim_set.dim.count loop
    l_flag(i):=false;
    l_distict_mo_dim_groups.delete;
    get_dim_mo_dim_groups(p_dim_set.dim(i),l_distict_mo_dim_groups);
    if l_distict_mo_dim_groups.count>1 then
      --we have to remove this dim from the dimset
      l_dim_to_split(l_dim_to_split.count+1):=p_dim_set.dim(i);
      l_flag(i):=true;
      if g_debug then
        log_n('identify_standalone_levels: Remove Dim '||p_dim_set.dim(i).dim_name||', replace with levels');
      end if;
    end if;
  end loop;
  if l_dim_to_split.count>0 then
    --remove the split dim from the dimset
    l_dim_copy:=p_dim_set.dim;
    p_dim_set.dim.delete;
    for i in 1..l_dim_copy.count loop
      if l_flag(i)=false then
        p_dim_set.dim(p_dim_set.dim.count+1):=l_dim_copy(i);
      end if;
    end loop;
    --now split the dim
    l_levels_for_new_dim.delete;
    for i in 1..l_dim_to_split.count loop
      for j in 1..l_dim_to_split(i).levels.count loop
        l_skip_flag:=bsc_aw_utility.get_parameter_value(l_dim_to_split(i).levels(j).property,'skip level',',');
        --ignore the levels to skip
        if l_skip_flag='N' then
          l_levels_for_new_dim(l_levels_for_new_dim.count+1):=l_dim_to_split(i).levels(j);
        end if;
      end loop;
    end loop;
  end if;
  if g_debug then
    if l_levels_for_new_dim.count>0 then
      log_n('identify_standalone_levels : Create new dim for these levels');
      for i in 1..l_levels_for_new_dim.count loop
        log(l_levels_for_new_dim(i).level_name);
      end loop;
    end if;
  end if;
  --create the new dim
  --dim with name=level name are seeded in bsc olap metadata. this is the snowflake implementation.
  --this metadata is created when the dim is created
  if l_levels_for_new_dim.count>0 then
    for i in 1..l_levels_for_new_dim.count loop
      p_dim_set.dim(p_dim_set.dim.count+1).dim_name:=l_levels_for_new_dim(i).level_name;
      p_dim_set.dim(p_dim_set.dim.count).levels(p_dim_set.dim(p_dim_set.dim.count).levels.count+1):=l_levels_for_new_dim(i);
    end loop;
  end if;
  --
Exception when others then
  log_n('Exception in identify_standalone_levels '||sqlerrm);
  raise;
End;

--level mo dim group is held in level.property
procedure get_dim_mo_dim_groups(
p_dim dim_r,
p_distict_mo_dim_groups out nocopy dbms_sql.varchar2_table) is
--
l_mo_dim_group varchar2(200);
Begin
  for i in 1..p_dim.levels.count loop
    l_mo_dim_group:=bsc_aw_utility.get_parameter_value(p_dim.levels(i).property,'mo dim group',',');
    if bsc_aw_utility.in_array(p_distict_mo_dim_groups,l_mo_dim_group)=false then
      p_distict_mo_dim_groups(p_distict_mo_dim_groups.count+1):=l_mo_dim_group;
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_dim_mo_dim_groups '||sqlerrm);
  raise;
End;

/*
used to dmp cube data into a table.
dmps all cubes of the dimset
p_table_name is dropped and recreated
p_dimset will be 0 or 1 etc
*/
procedure create_dmp_program(
p_kpi varchar2,
p_dimset varchar2,
p_dim_levels dbms_sql.varchar2_table,
p_name varchar2,
p_table_name varchar2) is
--
l_oo_object bsc_aw_md_wrapper.bsc_olap_object_tb;
l_oo_relation bsc_aw_md_wrapper.bsc_olap_object_relation_tb;
l_dimset varchar2(100);
l_dim_level_dims dbms_sql.varchar2_table;
l_measures dbms_sql.varchar2_table;
l_cubes dbms_sql.varchar2_table;
l_cube_formula dbms_sql.varchar2_table;
l_cube_composites dbms_sql.varchar2_table;
l_stmt varchar2(8000);
l_calendar_id number;
l_dim_levels dbms_sql.varchar2_table;
l_axis_type varchar2(100);
Begin
  l_dim_levels:=p_dim_levels;
  bsc_aw_md_api.get_kpi_dimset(p_kpi,l_oo_object);
  for i in 1..l_oo_object.count loop
    if bsc_aw_utility.get_parameter_value(l_oo_object(i).property1,'dim set',',')=p_dimset then
      if bsc_aw_utility.get_parameter_value(l_oo_object(i).property1,'dim set type',',')='actual' then
        l_dimset:=l_oo_object(i).object;
        exit;
      end if;
    end if;
  end loop;
  if l_dimset is not null then
    bsc_aw_md_api.get_bsc_olap_object_relation(null,null,null,p_kpi,'kpi',l_oo_relation);
    for i in 1..l_dim_levels.count loop
      l_dim_level_dims(i):=null;
      for j in 1..l_oo_relation.count loop
        if l_oo_relation(j).relation_object=l_dim_levels(i) and l_oo_relation(j).relation_type='dim set dim level' and
        instr(l_oo_relation(j).object,'+'||l_dimset)>0 and instr(l_oo_relation(j).object,'+'||l_dimset||'.')=0 then
          log(l_oo_relation(j).object);
          l_dim_level_dims(i):=substr(l_oo_relation(j).object,1,instr(l_oo_relation(j).object,'+')-1);
          exit;
        end if;
      end loop;
      --is this rec dim, then get the parent level
      l_oo_object.delete;
      bsc_aw_md_api.get_bsc_olap_object(l_dim_level_dims(i),'dimension',l_dim_level_dims(i),'dimension',l_oo_object);
      if bsc_aw_utility.get_parameter_value(l_oo_object(1).property1,'recursive',',')='Y' then
        l_oo_object.delete;
        bsc_aw_md_api.get_bsc_olap_object(null,'recursive level',l_dim_level_dims(i),'dimension',l_oo_object);
        l_dim_levels(i):=l_oo_object(1).object;--store the parent rec level
      end if;
    end loop;
    --calendar
    for i in 1..l_oo_relation.count loop
      if l_oo_relation(i).object=l_dimset and l_oo_relation(i).relation_type='dim set calendar' then
        l_calendar_id:=to_number(bsc_aw_utility.get_parameter_value(l_oo_relation(i).property1,'calendar',','));
        exit;
      end if;
    end loop;
    --get the measures and cubes
    for i in 1..l_oo_relation.count loop
      if l_oo_relation(i).object=l_dimset and l_oo_relation(i).relation_type='dim set measure' then
        l_measures(l_measures.count+1):=l_oo_relation(i).relation_object;
        l_cubes(l_cubes.count+1):=bsc_aw_utility.get_parameter_value(l_oo_relation(i).property1,'cube',',');
        l_cube_formula(l_cube_formula.count+1):=bsc_aw_utility.get_parameter_value(l_oo_relation(i).property1,'aw formula',',');
        for j in 1..l_oo_relation.count loop
          if l_oo_relation(j).object=l_cubes(l_cubes.count) and l_oo_relation(j).relation_type='cube axis' then
            l_axis_type:=bsc_aw_utility.get_parameter_value(l_oo_relation(j).property1,'axis type',',');
            if l_axis_type='partition template' or l_axis_type='composite' then
              l_cube_composites(l_cubes.count):=l_oo_relation(j).relation_object;
              exit;
            end if;
          end if;
        end loop;
      end if;
    end loop;
    --create the table first
    bsc_aw_utility.execute_ddl_ne('drop table '||p_table_name);
    l_stmt:='create table '||p_table_name||'(
    ';
    for i in 1..l_dim_levels.count loop
      l_stmt:=l_stmt||l_dim_levels(i)||' varchar2(300),
      ';
    end loop;
    for i in 1..l_measures.count loop
      l_stmt:=l_stmt||l_measures(i)||' number,
      ';
    end loop;
    l_stmt:=l_stmt||'period number,year number,periodicity_id number)';
    bsc_aw_utility.execute_ddl(l_stmt);
    --create the program
    g_commands.delete;
    bsc_aw_utility.add_g_commands(g_commands,'dfn '||p_name||' program');
    bsc_aw_utility.add_g_commands(g_commands,'sql prepare c1 from --');
    bsc_aw_utility.add_g_commands(g_commands,'insert into '||p_table_name||' values ( --');
    for i in 1..l_dim_levels.count loop
      if l_dim_level_dims(i) <> l_dim_levels(i) then
        bsc_aw_utility.add_g_commands(g_commands,':key('||l_dim_level_dims(i)||' '||l_dim_levels(i)||'), --');
      else
        bsc_aw_utility.add_g_commands(g_commands,':'||l_dim_levels(i)||', --');
      end if;
    end loop;
    for i in 1..l_measures.count loop
      if l_cube_formula(i) is not null then
        bsc_aw_utility.add_g_commands(g_commands,':'||l_cube_formula(i)||', --');
      else
        bsc_aw_utility.add_g_commands(g_commands,':'||l_cubes(i)||', --');
      end if;
    end loop;
    bsc_aw_utility.add_g_commands(g_commands,':period_cal_'||l_calendar_id||',:year_cal_'||l_calendar_id||',:periodicity_cal_'||l_calendar_id||')');
    bsc_aw_utility.add_g_commands(g_commands,'for '||l_cube_composites(1));
    bsc_aw_utility.add_g_commands(g_commands,'do');
    bsc_aw_utility.add_g_commands(g_commands,'sql execute c1');
    bsc_aw_utility.add_g_commands(g_commands,'if sqlcode ne 0');
    bsc_aw_utility.add_g_commands(g_commands,'then break');
    bsc_aw_utility.add_g_commands(g_commands,'doend');
    bsc_aw_utility.exec_program_commands(p_name,g_commands);
    --limit the dimensions
    for i in 1..l_dim_levels.count loop
      if l_dim_level_dims(i) <> l_dim_levels(i) then
        bsc_aw_dbms_aw.execute('limit '||l_dim_level_dims(i)||' to '||l_dim_levels(i));
      end if;
    end loop;
  end if;
Exception when others then
  log_n('Exception in create_dmp_program '||sqlerrm);
  raise;
End;

procedure get_missing_periodicity(p_kpi kpi_r,p_dim_set in out nocopy dim_set_r) is
--
l_periodicity_dim dbms_sql.varchar2_table;
l_lowest_level dbms_sql.varchar2_table;
l_initial_count number;
l_flag boolean;
Begin
  l_initial_count:=p_dim_set.calendar.periodicity.count;
  for i in 1..p_dim_set.calendar.periodicity.count loop
    l_periodicity_dim(l_periodicity_dim.count+1):=p_dim_set.calendar.periodicity(i).aw_dim;
  end loop;
  --
  bsc_aw_calendar.get_missing_periodicity(p_dim_set.calendar.aw_dim,l_periodicity_dim,l_lowest_level);
  --
  for i in 1..l_periodicity_dim.count loop
    l_flag:=false;
    for j in 1..p_dim_set.calendar.periodicity.count loop
      if p_dim_set.calendar.periodicity(j).aw_dim=l_periodicity_dim(i) then
        p_dim_set.calendar.periodicity(j).lowest_level:=l_lowest_level(i);
        p_dim_set.calendar.periodicity(j).missing_level:='N';
        l_flag:=true;
        exit;
      end if;
    end loop;
    if l_flag=false then
      p_dim_set.calendar.periodicity(p_dim_set.calendar.periodicity.count+1).aw_dim:=l_periodicity_dim(i);
      p_dim_set.calendar.periodicity(p_dim_set.calendar.periodicity.count).lowest_level:=l_lowest_level(i);
      p_dim_set.calendar.periodicity(p_dim_set.calendar.periodicity.count).missing_level:='Y';
    end if;
  end loop;
  if l_initial_count < p_dim_set.calendar.periodicity.count then --we need to add periodicity id to the new dim..this is re-read cal info
    bsc_aw_md_api.get_dim_set_calendar(p_kpi,p_dim_set);
  end if;
Exception when others then
  log_n('Exception in get_missing_periodicity '||sqlerrm);
  raise;
End;

function get_periodicity_r(p_periodicity periodicity_tb,p_periodicity_dim varchar2) return periodicity_r is
Begin
  for i in 1..p_periodicity.count loop
    if p_periodicity(i).aw_dim=p_periodicity_dim then
      return p_periodicity(i);
    end if;
  end loop;
  return null;
Exception when others then
  log_n('Exception in get_periodicity_r '||sqlerrm);
  raise;
End;

function get_periodicity_r(p_periodicity periodicity_tb,p_periodicity_id number) return periodicity_r is
Begin
  for i in 1..p_periodicity.count loop
    if p_periodicity(i).periodicity=p_periodicity_id then
      return p_periodicity(i);
    end if;
  end loop;
  return null;
Exception when others then
  log_n('Exception in get_periodicity_r '||sqlerrm);
  raise;
End;

/*
we have to handle re-agg of cubes when dim hier change. we do inc aggregations. this means we do limit dim to limit.cube
this has an issue. if dim A needs re-agg, then we cannot limit dim B to limit cube. if we do, we re-agg only a portion
of the data in the cube. if A has re-agg, we have to limit the limit cube to the composite of the cubes.
we limit it to the composite of the cube for efficiency. we want to re-agg only those data that has to be re-aggregated. so we
do not want to limit B to all values.
this program must be called before calling the load of the dimset. the reason is that we want to do this
only to those values of dim that have undergone hier change. if we load data, limit cubes capture inc data also
*/
procedure create_aggregate_marker_pgm(
p_kpi kpi_r,
p_dim_set dim_set_r
)is
--
l_composite_name dbms_sql.varchar2_table;
l_flag boolean;
l_cube cube_tb;
Begin
  --note>>> we dont do this for std dim since they are single level dim
  for i in 1..p_dim_set.measure.count loop
    l_cube(i):=get_cube_set_r(p_dim_set.measure(i).cube,p_dim_set).cube;
    for j in 1..l_cube(i).cube_axis.count loop
      if l_cube(i).cube_axis(j).axis_type='partition template' or l_cube(i).cube_axis(j).axis_type='composite' then
        if bsc_aw_utility.in_array(l_composite_name,l_cube(i).cube_axis(j).axis_name)=false then
          l_composite_name(l_composite_name.count+1):=l_cube(i).cube_axis(j).axis_name;
        end if;
      end if;
    end loop;
  end loop;
  --there must be 1 entry only for l_composite_name, either a PT or composite
  l_flag:=false;
  g_commands.delete;
  bsc_aw_utility.add_g_commands(g_commands,'dfn '||p_dim_set.aggregate_marker_program||' program');
  l_flag:=true;
  for i in 1..p_dim_set.dim.count loop
    if p_dim_set.dim(i).aggregate_marker is not null then --there is a aggregate marker
      bsc_aw_utility.add_g_commands(g_commands,'allstat');
      bsc_aw_utility.add_g_commands(g_commands,'if '||p_dim_set.dim(i).aggregate_marker||' EQ true');
      bsc_aw_utility.add_g_commands(g_commands,'then do');
      bsc_aw_utility.add_g_commands(g_commands,'limit '||p_dim_set.dim(i).dim_name||' to '||p_dim_set.dim(i).limit_cube);
      bsc_aw_utility.add_g_commands(g_commands,'limit '||p_dim_set.dim(i).dim_name||' add ancestors using '||p_dim_set.dim(i).relation_name);
      for j in 1..p_dim_set.dim.count loop
        if i<>j then
          for k in 1..l_composite_name.count loop
            bsc_aw_utility.add_g_commands(g_commands,p_dim_set.dim(j).limit_cube||'=true across '||l_composite_name(k));
          end loop;
        end if;
      end loop;
      for j in 1..p_dim_set.std_dim.count loop
        for k in 1..l_composite_name.count loop
          bsc_aw_utility.add_g_commands(g_commands,p_dim_set.std_dim(j).limit_cube||'=true across '||l_composite_name(k));
        end loop;
      end loop;
      for j in 1..l_composite_name.count loop
        bsc_aw_utility.add_g_commands(g_commands,p_dim_set.calendar.limit_cube||'=true across '||l_composite_name(j));
      end loop;
      bsc_aw_utility.add_g_commands(g_commands,'doend');
    end if;
  end loop;
  --for the reset cubes. loop across each dim and if each dim has a situation where a parent now no longer has any child nodes,
  --set the value of the cube to na
  for i in 1..p_dim_set.dim.count loop
    if p_dim_set.dim(i).reset_cube is not null and p_dim_set.dim(i).aggregate_marker is not null then --there is a aggregate marker and reset cube
      bsc_aw_utility.add_g_commands(g_commands,'if '||p_dim_set.dim(i).aggregate_marker||' EQ true');
      bsc_aw_utility.add_g_commands(g_commands,'then do');
      bsc_aw_utility.add_g_commands(g_commands,'allstat');
      bsc_aw_utility.add_g_commands(g_commands,'limit '||p_dim_set.dim(i).dim_name||' to '||p_dim_set.dim(i).reset_cube);
      bsc_aw_utility.add_g_commands(g_commands,'if statlen('||p_dim_set.dim(i).dim_name||') GT 0');
      bsc_aw_utility.add_g_commands(g_commands,'then do');
      bsc_aw_utility.init_is_new_value(1);
      for j in 1..p_dim_set.measure.count loop
        for k in 1..l_cube(j).cube_axis.count loop
          if l_cube(j).cube_axis(k).axis_type='partition template' or l_cube(j).cube_axis(k).axis_type='composite' then
            if bsc_aw_utility.is_new_value(p_dim_set.measure(j).cube,1) then
              bsc_aw_utility.add_g_commands(g_commands,p_dim_set.measure(j).cube||'=NA across '||l_cube(j).cube_axis(k).axis_name);
            end if;
          end if;
        end loop;
      end loop;
      bsc_aw_utility.add_g_commands(g_commands,'doend');
      bsc_aw_utility.add_g_commands(g_commands,'doend');
    end if;
  end loop;
  --reset values
  bsc_aw_utility.add_g_commands(g_commands,'allstat');
  for i in 1..p_dim_set.dim.count loop
    if p_dim_set.dim(i).aggregate_marker is not null then
      bsc_aw_utility.add_g_commands(g_commands,p_dim_set.dim(i).aggregate_marker||'=false');
    end if;
    if p_dim_set.dim(i).reset_cube is not null then
      if p_dim_set.dim(i).limit_cube_composite is not null then
        bsc_aw_utility.add_g_commands(g_commands,p_dim_set.dim(i).reset_cube||'=false across '||p_dim_set.dim(i).limit_cube_composite);
      else
        bsc_aw_utility.add_g_commands(g_commands,p_dim_set.dim(i).reset_cube||'=false');
      end if;
    end if;
  end loop;
  if l_flag then
    bsc_aw_utility.exec_program_commands(p_dim_set.aggregate_marker_program,g_commands);
  end if;
Exception when others then
  log_n('Exception in create_aggregate_marker_pgm '||sqlerrm);
  raise;
End;

/*this procedure will load the master partition template pattern. then the dimset PT can make copies from this.
this is the main procedure that will set the partition aspects of the dimset*/
procedure load_master_PT(p_actual_dim_set in out nocopy dim_set_r,p_target_dim_set in out nocopy dim_set_r) is
Begin
  if g_debug then
    log('load_master_PT '||p_actual_dim_set.dim_set_name);
  end if;
  if check_partition_possible(p_actual_dim_set,p_target_dim_set) then
    set_pt_type_count(p_actual_dim_set);
    if p_actual_dim_set.targets_higher_levels='Y' then
      set_pt_type_count(p_target_dim_set);
    end if;
    if p_actual_dim_set.number_partitions>0 then
      set_master_PT(p_actual_dim_set);
      /*this sets the hash dim to partition on if pt type=hash for example. may also turn off partitions if partitions cannot be implemented
      for the type specified */
      if p_actual_dim_set.number_partitions>0 then
        if p_actual_dim_set.targets_higher_levels='Y' then
          if p_target_dim_set.number_partitions>0 then
            set_master_PT(p_target_dim_set);
          end if;
        end if;
      else
        p_target_dim_set.number_partitions:=0;
      end if;
    end if;
  else
    p_actual_dim_set.number_partitions:=0;
    p_target_dim_set.number_partitions:=0;
  end if;
  if g_debug then
    if p_actual_dim_set.number_partitions>0 then
      log('Finally, Master Partition Template for Actuals');
      dmp_partition_template(p_actual_dim_set.master_partition_template(1));
      if p_actual_dim_set.targets_higher_levels='Y' then
        log('Finally, Master Partition Template for Targets');
        dmp_partition_template(p_target_dim_set.master_partition_template(1));
      end if;
    else
      log('Finally, No partitions');
    end if;
  end if;
Exception when others then
  log_n('Exception in load_master_PT  '||sqlerrm);
  raise;
End;

/*right now, partitions are checked at dimset level. this means all cubes of a dimset have partitions or none have */
function check_partition_possible(p_actual_dim_set in out nocopy dim_set_r,p_target_dim_set in out nocopy dim_set_r) return boolean is
l_partition_count number;
display_cube_flag boolean;
actual_periodicity periodicity_tb;
target_periodicity periodicity_tb;
flag boolean;
Begin
  if g_debug then
    log('check_partition_possible dimset '||p_actual_dim_set.dim_set_name||', with target '||p_target_dim_set.dim_set_name);
  end if;
  if bsc_aw_utility.get_db_version<10.2 then
    if g_debug then
      log('DB < 10.2. No partitions');
    end if;
    return false;
  end if;
  --
  if p_actual_dim_set.dim.count=0 then
    if g_debug then
      log('Only std dim and time, No other dimensions. No partitions');
    end if;
    return false;
  end if;
  --
  if nvl(bsc_aw_utility.get_parameter_value('NO PARTITION'),'N')='Y' then
    if g_debug then
      log('No partition specified.');
    end if;
    return false;
  end if;
  /*we have an issue with compressed composite and partitions in 10.104. clear all from aggregates does not work when we have cc
  and pt. 10.2, it should be resolved. if cc is specified, gets priority over pt specification
  we have partitions only when db is 10.2 and greater
  */
  --
  l_partition_count:=get_partition_count;
  if l_partition_count is null or l_partition_count<2 then
    if g_debug then
      log('Max possible partition count<2. No partitions');
    end if;
    return false;
  end if;
  /* */
  display_cube_flag:=is_display_cube_possible(p_actual_dim_set);
  if display_cube_flag=false then
    if check_countvar_cube_needed(p_actual_dim_set) then
      if g_debug then
        log('Countvar cube needed. Partitions not possible');
      end if;
      return false;
    end if;
    /*if sql aggregations are enabled, we can go for partitions. the view has the formula in it */
    for i in 1..p_actual_dim_set.measure.count loop
      if p_actual_dim_set.measure(i).sql_aggregated='N' then
        if p_actual_dim_set.measure(i).agg_formula.std_aggregation='N' then
          if g_debug then
            log('Non std agg in dimset '||p_actual_dim_set.dim_set||', partitions not possible');
          end if;
          return false;
        end if;
        /*for now, if thereis AVERAGE or COUNT aggregation, we disable partitions */
        if bsc_aw_utility.is_PT_aggregation_function(p_actual_dim_set.measure(i).agg_formula.agg_formula)='N' then
          if g_debug then
            log('Non partitionable aggregation function '||p_actual_dim_set.measure(i).agg_formula.agg_formula);
          end if;
          return false;
        end if;
      end if;
    end loop;
  else
    if g_debug then
      log('Display cube is possible. This means we can have partitions when there is AVERAGE or Non Std Aggregations');
    end if;
  end if;
  /*if there are targets at higher levels, we disable partitions
  targets can be partitioned if actuals are partitioned or not. however, actuals cannot be partitioned if there are targets.
  for targets we can introduce year based partitions. question is : is it really worth it. year based partitions (still list) will help
  parallelize initial aggregations. on an inc basis, there is no help. if a dbi style kpi is brought into bsc, it will not have targets at higher
  levels mostly. even without partitions, aw aggregations are fast. so not worth it to introduce year based aggregations
  --
  with hash partitions on time and agg on time on the fly, we can partition targets at higher levels as long as targets and actuals are at the
  same periodicity level. if actuals are at day and targets at month, no partitions. if at the same periodicity level, we enable only hash
  partitions on time. must make sure we have only hash and only on time. targets do not have rollups. so the system must not select list partitions
  for it. we can partition when there are targets as long as actuals and targets have the same number of partitions and a given period is guaranteed
  to be in P.x of actuals and P.x of targets
  */
  if p_actual_dim_set.targets_higher_levels='Y' then
    if nvl(bsc_aw_utility.get_parameter_value('NO TARGET PARTITION'),'N')='Y' then
      if g_debug then
        log('Targets at higher level and NO TARGET PARTITION specified. No partitions');
      end if;
      return false;
    end if;
    if g_debug then
      log('Targets at higher level. Partitions are possible only if targets and actuals have the same periodicity');
    end if;
    actual_periodicity:=get_dim_set_lowest_periodicity(p_actual_dim_set);
    target_periodicity:=get_dim_set_lowest_periodicity(p_target_dim_set);
    for i in 1..target_periodicity.count loop
      flag:=false;
      for j in 1..actual_periodicity.count loop
        if actual_periodicity(j).aw_dim=target_periodicity(i).aw_dim then
          flag:=true;
          exit;
        end if;
      end loop;
      if flag=false then
        if g_debug then
          log('Targets and Actuals do not have the same periodicity. Partitions not possible');
        end if;
        return false;
      end if;
    end loop;
    if g_debug then
      log('Partitions are possible. Only HASH partitions on Time Dimension');
    end if;
    bsc_aw_utility.merge_property(p_actual_dim_set.property,'hash partition',null,'Y');
    bsc_aw_utility.merge_property(p_actual_dim_set.property,'hash partition only time',null,'Y');
    /* */
    bsc_aw_utility.merge_property(p_target_dim_set.property,'hash partition',null,'Y');
    bsc_aw_utility.merge_property(p_target_dim_set.property,'hash partition only time',null,'Y');
  end if;
  /*partition possible*/
  return true;
Exception when others then
  log_n('Exception in check_partition_possible  '||sqlerrm);
  raise;
End;

/*check to see if list partition is possible or we need hash partition the number of partitions are set here*/
procedure set_pt_type_count(p_dim_set in out nocopy dim_set_r) is
l_bt_pt_type varchar2(40);
l_bt_pt_count number;
l_bt_levels dbms_sql.varchar2_table;
l_reason varchar2(8000);
l_partition_count number;
Begin
  if bsc_aw_utility.get_property(p_dim_set.property,'hash partition').property_value='Y' then
    p_dim_set.partition_type:='hash';
  else
    p_dim_set.partition_type:='list';--default
  end if;
  l_bt_levels.delete;
  for i in 1..p_dim_set.data_source(1).base_tables(1).levels.count loop
    l_bt_levels(l_bt_levels.count+1):=p_dim_set.data_source(1).base_tables(1).levels(i).level_name;
  end loop;
  /*list partitions are possible if this dimset has no aggregation in it and the dimset has the same number of keys at the same level
  as the B tables. also the periodicity must match */
  if p_dim_set.partition_type='list' then
    for i in 1..p_dim_set.dim.count loop
      if p_dim_set.dim(i).levels.count>1 then /*there is rollup */
        p_dim_set.partition_type:='hash';
        l_reason:='Dim '||p_dim_set.dim(i).dim_name||' has rollup. List partitions not possible';
        exit;
      end if;
    end loop;
    if p_dim_set.partition_type='list' then /*see if there is time rollup */
      for i in 1..p_dim_set.calendar.periodicity.count loop
        if p_dim_set.calendar.periodicity(i).lowest_level<>'Y' then
          p_dim_set.partition_type:='hash';
          l_reason:='Dimset calendar has rollup. List partitions not possible';
        end if;
      end loop;
    end if;
    if p_dim_set.partition_type='list' then
      if p_dim_set.dim.count<>l_bt_levels.count then
        p_dim_set.partition_type:='hash';
        l_reason:='Dimset has diff number of dimension keys than B table. Only hash partition possible';
      end if;
    end if;
    if p_dim_set.partition_type='list' then
      for i in 1..p_dim_set.dim.count loop
        if bsc_aw_utility.in_array(l_bt_levels,p_dim_set.dim(i).levels(1).level_name)=false then
          p_dim_set.partition_type:='hash';
          l_reason:='Dimset has diff dim levels than B table. Only hash partition possible';
          exit;
        end if;
      end loop;
    end if;
  end if;
  if p_dim_set.partition_type='list' then
    for i in 1..p_dim_set.data_source.count loop
      for j in 1..p_dim_set.data_source(i).base_tables.count loop
        if p_dim_set.data_source(i).base_tables(j).levels.count<>l_bt_levels.count then
          l_reason:='B table '||p_dim_set.data_source(i).base_tables(j).base_table_name||' has '||p_dim_set.data_source(i).base_tables(j).levels.count||
          ' number of levels while the first B table has '||l_bt_levels.count||' levels. List partitions not possible';
          p_dim_set.partition_type:='hash';
          exit;
        end if;
        /*check that each levels match */
        for k in 1..p_dim_set.data_source(i).base_tables(j).levels.count loop
          if bsc_aw_utility.in_array(l_bt_levels,p_dim_set.data_source(i).base_tables(j).levels(k).level_name)=false then
            l_reason:='B table '||p_dim_set.data_source(i).base_tables(j).base_table_name||' has level '||
            p_dim_set.data_source(i).base_tables(j).levels(k).level_name||' that is not in the first B table. List partitions not possible';
            p_dim_set.partition_type:='hash';
            exit;
          end if;
        end loop;
      end loop;
      /*check that there is no periodicity rollup reqd from any B table */
      if p_dim_set.data_source(i).calendar.periodicity(1).periodicity<>p_dim_set.data_source(i).base_tables(1).periodicity.periodicity then
        p_dim_set.partition_type:='hash';
        l_reason:='B table '||p_dim_set.data_source(i).base_tables(1).base_table_name||' needs rollup in periodicity. List partitions not possible';
      end if;
      if p_dim_set.partition_type='hash' then /*list partitions not possible */
        exit;
      end if;
    end loop;
  end if;
  /*if we can go for list partitions, now make sure that all B tables have the same list partitions */
  if p_dim_set.partition_type='list' then
    l_bt_pt_type:=nvl(p_dim_set.data_source(1).base_tables(1).table_partition.main_partition.partition_type,'none');
    l_bt_pt_count:=p_dim_set.data_source(1).base_tables(1).table_partition.main_partition.partitions.count;
    if l_bt_pt_type='LIST' and l_bt_pt_count>0 then
      for i in 1..p_dim_set.data_source.count loop
        for j in 1..p_dim_set.data_source(i).base_tables.count loop
          if nvl(p_dim_set.data_source(i).base_tables(j).table_partition.main_partition.partition_type,'none')<>l_bt_pt_type
          or p_dim_set.data_source(i).base_tables(j).table_partition.main_partition.partitions.count<>l_bt_pt_count then
            l_reason:='B table '||p_dim_set.data_source(i).base_tables(j).base_table_name||' has diff partition parameters.'||
            'List partitions on dimset not possible';
            p_dim_set.partition_type:='hash';
            exit;
          end if;
        end loop;
        if p_dim_set.partition_type='hash' then /*list partitions not possible */
          exit;
        end if;
      end loop;
    else
      l_reason:='B table does not have LIST partitions. So we can only attempt hash partitions';
      p_dim_set.partition_type:='hash';
    end if;
  end if;
  --
  if p_dim_set.partition_type='hash' then
    if g_debug then
      log('We can only try hash partitions for dimset '||p_dim_set.dim_set_name||'. Reason: '||l_reason);
    end if;
  end if;
  --
  l_reason:=null;
  l_partition_count:=get_partition_count;
  if p_dim_set.partition_type='list' then
    if l_bt_pt_count>l_partition_count then
      l_partition_count:=0;
      l_reason:='B tables have number of partitions='||l_bt_pt_count||' while max allowed partitions are '||l_partition_count||
      '. Cannot have partitions';
    elsif l_bt_pt_count<l_partition_count then
      l_partition_count:=l_bt_pt_count;
      l_reason:='B tables have number of partitions='||l_bt_pt_count||' while max allowed partitions are '||l_partition_count||
      '. Reducing number of partition to '||l_bt_pt_count;
    end if;
  end if;
  if l_partition_count is null then
    l_partition_count:=0;
  end if;
  p_dim_set.number_partitions:=l_partition_count;
  if g_debug then
    log('Finally, Dimset '||p_dim_set.dim_set||', partition type='||p_dim_set.partition_type||', number partitions='||
    p_dim_set.number_partitions||' and any reason(null if nothing)='||l_reason);
  end if;
Exception when others then
  log_n('Exception in set_pt_type_count  '||sqlerrm);
  raise;
End;

/*here, we set the master PT template for list or hash or range partitions
master PT only contains the logical metadata. will not contain axis info. this is loaded in create_pt_comp_names*/
procedure set_master_PT(p_dim_set in out nocopy dim_set_r) is
Begin
  p_dim_set.partition_dim:='hash_partition_dim';
  p_dim_set.master_partition_template(1).template_name:='master PT';
  p_dim_set.master_partition_template(1).template_type:='list'; /*hash and list are AW list partitions */
  p_dim_set.master_partition_template(1).template_use:='datacube';/*this pt is meant for cubes */
  p_dim_set.master_partition_template(1).template_dim:=p_dim_set.partition_dim;
  if p_dim_set.partition_type='hash' then
    if set_PT_hash_dimensions(p_dim_set,p_dim_set.master_partition_template(1)) then
      set_PT_dim_aggregated(p_dim_set,p_dim_set.master_partition_template(1));/*sets the aggregated flag */
      set_PT_calendar_aggregated(p_dim_set,p_dim_set.master_partition_template(1));/*sets the aggregated flag */
    else
     p_dim_set.number_partitions:=0;
     p_dim_set.partition_dim:=null;
     reset_PT_template(p_dim_set.master_partition_template(1));
     if g_debug then
       log('No Hash Partitions possible for '||p_dim_set.dim_set_name);
     end if;
    end if;
  end if;
Exception when others then
  log_n('Exception in set_master_PT  '||sqlerrm);
  raise;
End;

/*this api must set the hash partition dim. what dim this sets has implication on what levels will get aggregated.
if this sets partition at lowest calendar level (day) there is no aggrgation in time except at runtime
if this is set at state, there is aggregation upto state. we will change the agg level per dim to reflect this
have to account for targets. there are no partitions when there are targets. but still, must make sure that we do not include dim that have
targets coming at diff levels
if balance measures are involved and we partition on time, they are still aggregated to top levels in time since this is done in the
load program itself. aggregation online is for non bal measures only
if we have multiple lowest levels in a dim like
city>-state>-country
county>-state>-country, if we decide to partition on city, we must also partition on county because otherwise, data coming at county level
has no partition to go to
if the return flag=false, it means this api could not find dim suitable to hash partition on
*/
function set_PT_hash_dimensions(p_dim_set dim_set_r,p_partition_template in out nocopy partition_template_r) return boolean is
partition_time boolean;
partition_dim boolean;
Begin
  p_partition_template.hpt_data.hpt_dimensions.delete;
  p_partition_template.hpt_data.hpt_calendar.dim_name:=null;
  /*for now, we hash on time only. must handle kpi that only have year level.for now, if there is year only kpi, no hash partitions possible */
  /*if we have yearly kpi or balance last value measure, we cannot hash on time. if we just have balance measure (based on period end), we
  can hash on time. upper time nodes will not be duplicated across partitions in this case */
  if p_dim_set.calendar.periodicity.count=1 then
    if p_dim_set.calendar.periodicity(1).periodicity_type='1' then
      if g_debug then
        log('HASH Partitions not possible on time as the KPI is YEARLY kpi');
      end if;
      return false;
    end if;
  end if;
  /*check for balance last value */
  for i in 1..p_dim_set.measure.count loop
    if p_dim_set.measure(i).measure_type=g_balance_last_value_prop then
      if g_debug then
        log('HASH Partitions not possible on time as the KPI has measure of type '||g_balance_last_value_prop);
      end if;
      return false;
    end if;
  end loop;
  partition_dim:=false; /*for now, no dim involved in hash partitions */
  partition_time:=true;
  if bsc_aw_utility.get_property(p_dim_set.property,'hash partition only time').property_value='Y' then
    partition_dim:=false;/*this will be the case for targets at higher levels */
  end if;
  if partition_time then
    p_partition_template.hpt_data.hpt_calendar.dim_name:=p_dim_set.calendar.aw_dim;
    p_partition_template.hpt_data.hpt_calendar.dim_type:='time';
    p_partition_template.hpt_data.hpt_calendar.level_names.delete;
    p_partition_template.hpt_data.hpt_calendar.level_keys.delete;
    for i in 1..p_dim_set.calendar.periodicity.count loop
      if p_dim_set.calendar.periodicity(i).lowest_level='Y' then
        p_partition_template.hpt_data.hpt_calendar.level_names(
        p_partition_template.hpt_data.hpt_calendar.level_names.count+1):=
        p_dim_set.calendar.periodicity(i).aw_dim;
        p_partition_template.hpt_data.hpt_calendar.level_keys(
        p_partition_template.hpt_data.hpt_calendar.level_keys.count+1):='period';
      end if;
    end loop;
  end if;
  /*if we needed to partition on time, we can do so here. but for now, there are partitions only on time */
  if partition_dim then
    null;
  end if;
  if g_debug then
    log('set_PT_hash_dimensions for template '||p_partition_template.template_name);
    dmp_hpt_data(p_partition_template.hpt_data);
  end if;
  return true;
Exception when others then
  log_n('Exception in set_PT_hash_dimensions '||sqlerrm);
  raise;
End;

/*sets the aggregated flag */
procedure set_PT_dim_aggregated(p_dim_set in out nocopy dim_set_r,p_partition_template partition_template_r) is
Begin
  for i in 1..p_dim_set.dim.count loop
    for j in 1..p_partition_template.hpt_data.hpt_dimensions.count loop
      if p_dim_set.dim(i).dim_name=p_partition_template.hpt_data.hpt_dimensions(j).dim_name then
        set_PT_dim_aggregated(p_dim_set.dim(i),p_dim_set,p_partition_template.hpt_data.hpt_dimensions(j).level_names);
        --
        exit;
      end if;
    end loop;
  end loop;
Exception when others then
  log_n('Exception in set_PT_dim_aggregated '||sqlerrm);
  raise;
End;

procedure set_PT_dim_aggregated(p_dim in out nocopy dim_r,p_dim_set dim_set_r,p_levels dbms_sql.varchar2_table) is
l_parent_child bsc_aw_adapter_dim.dim_parent_child_tb;
l_pc bsc_aw_utility.parent_child_tb;
l_child_levels dbms_sql.varchar2_table;
zero_aggregated dbms_sql.varchar2_table;
aggregated dbms_sql.varchar2_table;
Begin
  bsc_aw_md_api.get_dim_parent_child(p_dim.dim_name,l_parent_child);
  for i in 1..l_parent_child.count loop
    if l_parent_child(i).parent_level is not null and l_parent_child(i).child_level is not null then
      l_pc(l_pc.count+1).parent:=l_parent_child(i).parent_level;
      l_pc(l_pc.count).child:=l_parent_child(i).child_level;
    end if;
  end loop;
  /*if there is partition at country say, we can rollup to country but not perform zero code */
  for i in 1..p_dim.levels.count loop
    if bsc_aw_utility.in_array(p_levels,p_dim.levels(i).level_name) then
      /*p_dim.levels(i).aggregated is left unchanged*/
      p_dim.levels(i).zero_aggregated:='N';/*there cannot be zero code aggregation at this level */
      aggregated(i):=p_dim.levels(i).aggregated;
      zero_aggregated(i):=p_dim.levels(i).zero_aggregated;
      if g_debug then
        log('Dimension '||p_dim.dim_name||', Partition Level '||p_dim.levels(i).level_name||' aggregated='''||p_dim.levels(i).aggregated||
        ''', zero_aggregated='''||p_dim.levels(i).zero_aggregated||'''');
      end if;
    else
      aggregated(i):=p_dim.levels(i).aggregated;
      zero_aggregated(i):=p_dim.levels(i).zero_aggregated;/*capture the prev setting for zero_aggregated */
      p_dim.levels(i).aggregated:='N';
      p_dim.levels(i).zero_aggregated:='N';
    end if;
  end loop;
  if l_pc.count>0 then
    for i in 1..p_levels.count loop
      l_child_levels.delete;
      bsc_aw_utility.get_all_children(l_pc,p_levels(i),l_child_levels);
      if l_child_levels.count>0 then
        for j in 1..p_dim.levels.count loop
          if bsc_aw_utility.in_array(l_child_levels,p_dim.levels(j).level_name) then
            p_dim.levels(j).aggregated:=aggregated(j);
            p_dim.levels(j).zero_aggregated:=zero_aggregated(j);
            if g_debug then
              log('Dimension '||p_dim.dim_name||', Child Level '||p_dim.levels(j).level_name||' aggregated='''||p_dim.levels(j).aggregated||
              ''', zero_aggregated='''||p_dim.levels(j).zero_aggregated||'''');
            end if;
          end if;
        end loop;
      end if;
    end loop;
  end if;
Exception when others then
  log_n('Exception in set_PT_dim_aggregated '||sqlerrm);
  raise;
End;

/*sets the aggregated flag */
procedure set_PT_calendar_aggregated(p_dim_set in out nocopy dim_set_r,p_partition_template partition_template_r) is
Begin
  if p_partition_template.hpt_data.hpt_calendar.dim_name is not null then /*There is partitioning on Calendar */
    set_PT_calendar_aggregated(p_dim_set.calendar,p_dim_set,p_partition_template.hpt_data.hpt_calendar.level_names);
  end if;
Exception when others then
  log_n('Exception in set_PT_calendar_aggregated '||sqlerrm);
  raise;
End;

procedure set_PT_calendar_aggregated(p_calendar in out nocopy calendar_r,p_dim_set dim_set_r,p_levels dbms_sql.varchar2_table) is
l_pc bsc_aw_utility.parent_child_tb;
l_child_levels dbms_sql.varchar2_table;
aggregated dbms_sql.varchar2_table;
Begin
  for i in 1..p_calendar.parent_child.count loop
    if p_calendar.parent_child(i).parent_dim_name is not null and p_calendar.parent_child(i).child_dim_name is not null then
      l_pc(l_pc.count+1).parent:=p_calendar.parent_child(i).parent_dim_name;
      l_pc(l_pc.count).child:=p_calendar.parent_child(i).child_dim_name;
    end if;
  end loop;
  for i in 1..p_calendar.periodicity.count loop
    if bsc_aw_utility.in_array(p_levels,p_calendar.periodicity(i).aw_dim) then
      /*p_calendar.periodicity(i).aggregated is left unchanged */
      aggregated(i):=p_calendar.periodicity(i).aggregated;/*could be Y or N */
    else
      aggregated(i):=p_calendar.periodicity(i).aggregated;
      p_calendar.periodicity(i).aggregated:='N';/*init all to N. then from the PT levels, drill down and mark as Y */
    end if;
  end loop;
  if l_pc.count>0 then
    for i in 1..p_levels.count loop
      l_child_levels.delete;
      bsc_aw_utility.get_all_children(l_pc,p_levels(i),l_child_levels);
      if l_child_levels.count>0 then
        for j in 1..p_calendar.periodicity.count loop
          if bsc_aw_utility.in_array(l_child_levels,p_calendar.periodicity(j).aw_dim) then
            p_calendar.periodicity(j).aggregated:=aggregated(j);
            if g_debug then
              log('Calendar '||p_calendar.aw_dim||', Child Periodicity '||p_calendar.periodicity(j).aw_dim||' aggregated='''||
              p_calendar.periodicity(j).aggregated||'''');
            end if;
          end if;
        end loop;
      end if;
    end loop;
  end if;
Exception when others then
  log_n('Exception in set_PT_calendar_aggregated '||sqlerrm);
  raise;
End;

function get_partition_count return number is
l_cpu_count number;
l_partition_count number;
Begin
  l_cpu_count:=bsc_aw_utility.get_cpu_count;
  l_partition_count:=to_number(bsc_aw_utility.get_parameter_value('NUMBER PARTITION'));--most of the time null
  if l_partition_count is null or l_partition_count=0 then
    l_partition_count:=bsc_aw_utility.get_min(bsc_aw_utility.get_closest_2_power_number(l_cpu_count),bsc_aw_utility.g_max_partitions);
  else
    if l_partition_count>l_cpu_count then
      l_partition_count:=l_cpu_count; /*max partitions possible is cpu count */
    end if;
  end if;
  if l_partition_count>bsc_aw_utility.g_max_partitions then
    l_partition_count:=bsc_aw_utility.g_max_partitions;
  end if;
  return l_partition_count;
Exception when others then
  log_n('Exception in get_partition_count '||sqlerrm);
  raise;
End;

function get_cube_set_r(p_cube_name varchar2,p_dimset dim_set_r) return cube_set_r is
Begin
  for i in 1..p_dimset.cube_set.count loop
    if p_dimset.cube_set(i).cube.cube_name=p_cube_name then
      return p_dimset.cube_set(i);
    end if;
  end loop;
  /*check countvar cube */
  for i in 1..p_dimset.cube_set.count loop
    if p_dimset.cube_set(i).countvar_cube.cube_name=p_cube_name then
      return p_dimset.cube_set(i);
    end if;
  end loop;
  /*check display cube */
  for i in 1..p_dimset.cube_set.count loop
    if p_dimset.cube_set(i).display_cube.cube_name=p_cube_name then
      return p_dimset.cube_set(i);
    end if;
  end loop;
  /* */
  return null;
Exception when others then
  log_n('Exception in get_cube_set_r '||sqlerrm);
  raise;
End;

function get_composite_r(p_composite_name varchar2,p_dimset dim_set_r) return composite_r is
Begin
  for i in 1..p_dimset.composite.count loop
    if p_dimset.composite(i).composite_name=p_composite_name then
      return p_dimset.composite(i);
    end if;
  end loop;
  return null;
Exception when others then
  log_n('Exception in get_composite_r '||sqlerrm);
  raise;
End;

function get_partition_template_r(p_partition_template varchar2,p_dimset dim_set_r) return partition_template_r is
Begin
  for i in 1..p_dimset.partition_template.count loop
    if p_dimset.partition_template(i).template_name=p_partition_template then
      return p_dimset.partition_template(i);
    end if;
  end loop;
  return null;
Exception when others then
  log_n('Exception in get_partition_template_r '||sqlerrm);
  raise;
End;

/*
right now, we support p_axis_type of partition template or composite
*/
function get_cube_axis(p_cube_name varchar2,p_dimset dim_set_r,p_axis_type varchar2) return varchar2 is
cube_set cube_set_r;
l_cube cube_r;
Begin
  cube_set:=get_cube_set_r(p_cube_name,p_dimset);
  if cube_set.cube.cube_name=p_cube_name then
    l_cube:=cube_set.cube;
  elsif cube_set.countvar_cube.cube_name=p_cube_name then
    l_cube:=cube_set.countvar_cube;
  elsif cube_set.display_cube.cube_name=p_cube_name then
    l_cube:=cube_set.display_cube;
  end if;
  if l_cube.cube_name is not null then
    for i in 1..l_cube.cube_axis.count loop
      if l_cube.cube_axis(i).axis_type=p_axis_type then
        return l_cube.cube_axis(i).axis_name;
      end if;
    end loop;
  end if;
  return null;
Exception when others then
  log_n('Exception in get_cube_axis '||sqlerrm);
  raise;
End;

/*
let us assume a cube has 1 PT or 1 composite. this function returns either PT or if not found, composite name
*/
function get_cube_pt_comp(p_cube_name varchar2,p_dimset dim_set_r,p_type out nocopy varchar2) return varchar2 is
l_pt_name varchar2(200);
Begin
  p_type:=null;
  l_pt_name:=get_cube_axis(p_cube_name,p_dimset,'partition template');
  if l_pt_name is null then
    l_pt_name:=get_cube_axis(p_cube_name,p_dimset,'composite');
    if l_pt_name is not null then
      p_type:='composite';
    end if;
  else
    p_type:='partition template';
  end if;
  return l_pt_name;
Exception when others then
  log_n('Exception in get_cube_pt_comp '||sqlerrm);
  raise;
End;

procedure get_measures_for_cube(
p_cube varchar2,
p_dim_set dim_set_r,
p_measures out nocopy measure_tb) is
Begin
  for i in 1..p_dim_set.measure.count loop
    if p_dim_set.measure(i).cube=p_cube then
      p_measures(p_measures.count+1):=p_dim_set.measure(i);
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_measures_for_cube '||sqlerrm);
  raise;
End;

function get_cube_set_for_measure(p_measure varchar2,p_dim_set dim_set_r) return cube_set_r is
Begin
  for i in 1..p_dim_set.measure.count loop
    if p_dim_set.measure(i).measure=p_measure then
      return get_cube_set_r(p_dim_set.measure(i).cube,p_dim_set);
    end if;
  end loop;
  return null;
Exception when others then
  log_n('Exception in get_measures_for_cube '||sqlerrm);
  raise;
End;

/*
this is to register the B table combinations used in the load program. when we load the B tables, we see which one of these combinations
to use
*/
procedure set_program_property(p_load_program in out nocopy load_program_r,p_data_source data_source_tb) is
l_ordered_bt dbms_sql.varchar2_table;
Begin
  p_load_program.ds_base_tables:=null;
  for i in 1..p_data_source.count loop
    l_ordered_bt.delete;
    for j in 1..p_data_source(i).base_tables.count loop
      l_ordered_bt(l_ordered_bt.count+1):=upper(p_data_source(i).base_tables(j).base_table_name);
    end loop;
    l_ordered_bt:=bsc_aw_utility.order_array(l_ordered_bt);
    p_load_program.ds_base_tables:=p_load_program.ds_base_tables||bsc_aw_utility.make_string_from_list(l_ordered_bt,'^')||'+';
  end loop;
  if g_debug then
    log('Program name '||p_load_program.program_name||', DS Tables '||p_load_program.ds_base_tables);
  end if;
Exception when others then
  log_n('Exception in set_program_property '||sqlerrm);
  raise;
End;

/*
if we know the level name, this api will loop over the dim set dim and their levels and return the
dim structure
*/
function get_kpi_level_dim_r(
p_dim_set dim_set_r,
p_level varchar2) return dim_r is
Begin
  for i in 1..p_dim_set.dim.count loop
    for j in 1..p_dim_set.dim(i).levels.count loop
      if p_dim_set.dim(i).levels(j).level_name=p_level then
        return p_dim_set.dim(i);
      end if;
    end loop;
  end loop;
  return null;
Exception when others then
  log_n('Exception in get_kpi_level_dim_r '||sqlerrm);
  raise;
End;

function get_dim_level_r(
p_dim dim_r,
p_level varchar2) return level_r is
Begin
  for i in 1..p_dim.levels.count loop
    if p_dim.levels(i).level_name=p_level then
      return p_dim.levels(i);
    end if;
  end loop;
  return null;
Exception when others then
  log_n('Exception in get_dim_level_r '||sqlerrm);
  raise;
End;

procedure check_compressed_composite(p_actual_dim_set in out nocopy dim_set_r,p_target_dim_set in out nocopy dim_set_r) is
l_reason varchar2(4000);
l_countvar_flag boolean;
l_agg_formula varchar2(4000);
l_cal_aggregated boolean;
Begin
  p_actual_dim_set.compressed:='N';--default
  p_target_dim_set.compressed:='N';--default
  l_countvar_flag:=check_countvar_cube_needed(p_actual_dim_set);
  if nvl(bsc_aw_utility.get_parameter_value('NO COMPRESSED COMPOSITE'),'N')='Y' then
    if g_debug then
      log('Non compressed composite specified');
    end if;
    return;
  end if;
  if bsc_aw_utility.get_db_version>=10.2 or nvl(bsc_aw_utility.get_parameter_value('COMPRESSED COMPOSITE'),'N')='Y' then
    /*if we have average in aggregation, we need countvar. countvar cannot share the same composite as main cube. if we have
    diff composite, we cannot aggregate. aw throws error
    ORA-36168: COUNTVAR variable BSC_AW!DATACUBE.1.4014.COUNTVAR must have the same dimensionality as AGGMAP object
    BSC_AW!DATACUBE.1.4014. so we have to disable compressed composite
    */
    p_actual_dim_set.compressed:='Y'; --default
    if p_actual_dim_set.targets_higher_levels='Y' then
      p_actual_dim_set.compressed:='N';
      l_reason:='Target at higher level';
    end if;
    /*if l_countvar_flag then
      bsc_aw_utility.merge_property(p_actual_dim_set.property,'aggcount',null,'Y');
    end if;*/
    /*even with aggcount set in the cube, aw still complains that we need countvar cube when we have aggregate cube using aggmap. so for now,
    no CC for avg */
    if l_countvar_flag then
      p_actual_dim_set.compressed:='N';
      l_reason:='countvar cube needed';
    end if;
    if p_actual_dim_set.compressed='Y' then --check to make sure all measures have the same agg formula
      --we cannot use opvar and argvar and measuredim in the aggmap with cc
      --now we have this restricted implementation. future,can create cubes by grouping according to agg formula
      l_agg_formula:=null;
      for i in 1..p_actual_dim_set.measure.count loop
        if p_actual_dim_set.measure(i).sql_aggregated='N' then
          l_agg_formula:=p_actual_dim_set.measure(i).agg_formula.agg_formula;
          exit;
        end if;
      end loop;
      if l_agg_formula is not null then
        if bsc_aw_utility.is_CC_aggregation_function(l_agg_formula)='N' then
          p_actual_dim_set.compressed:='N';
          l_reason:='Agg Formula '||l_agg_formula||' cannot have compressed composite';
        end if;
      end if;
      if p_actual_dim_set.compressed='Y' then
        for i in 1..p_actual_dim_set.measure.count loop
          if p_actual_dim_set.measure(i).sql_aggregated='N' then
            if p_actual_dim_set.measure(i).agg_formula.agg_formula<>l_agg_formula then
              p_actual_dim_set.compressed:='N';
              l_reason:='agg formula not the same across measures';
              exit;
            end if;
          end if;
        end loop;
      end if;
    end if;
    /*we have to consider ORA-37133: Cannot write into an aggregated VARIABLE dimensioned by a COMPRESSED COMPOSITE.
    this means we cannot have balance measures or formula measures or projection measures in compressed composite
    */
    if p_actual_dim_set.compressed='Y' then
      l_cal_aggregated:=is_calendar_aggregated(p_actual_dim_set.calendar);
      for i in 1..p_actual_dim_set.measure.count loop
        if p_actual_dim_set.measure(i).agg_formula.std_aggregation='N' and p_actual_dim_set.measure(i).sql_aggregated='N' then
          p_actual_dim_set.compressed:='N';
          l_reason:='non std agg (formula)';
          exit;
        elsif p_actual_dim_set.measure(i).measure_type=g_balance_end_period_prop or p_actual_dim_set.measure(i).measure_type=g_balance_last_value_prop then
          p_actual_dim_set.compressed:='N';
          l_reason:='balance measure';
          exit;
        elsif p_actual_dim_set.measure(i).forecast='Y' and l_cal_aggregated then
          /*its very important that set_calendar_agg_level be done before this is executed. if we do not have agg on calendar at load time,
          we do not have to correct forecast. for CC, forecast correction done online is on the display cube. projection is on by default in BSC
          so we want to have CC even when there are forecasts */
          p_actual_dim_set.compressed:='N';
          l_reason:='Measure has projection';
          exit;
        end if;
      end loop;
    end if;
    /*if we have B table loading at higher periodicity or dim level, cannot have compressed composite */
    if p_actual_dim_set.compressed='Y' then
      if is_higher_level_preloaded(p_actual_dim_set) then
        p_actual_dim_set.compressed:='N';
        l_reason:='Higher levels preloaded from Base Tables';
      end if;
    end if;
    if p_actual_dim_set.compressed='Y' then
      if is_higher_period_preloaded(p_actual_dim_set) then
        p_actual_dim_set.compressed:='N';
        l_reason:='Higher periodicity preloaded from Base Tables';
      end if;
    end if;
    /* */
    if p_actual_dim_set.compressed='N' then
      if g_debug then
        log('Could not implement compressed composite. dimset='||p_actual_dim_set.dim_set||', Reason '||l_reason);
      end if;
    end if;
  else
    p_actual_dim_set.compressed:='N'; --default, no compressed composite
  end if;
  if p_actual_dim_set.targets_higher_levels='Y' and p_actual_dim_set.compressed='Y' then /*not possible scenario for now */
    p_target_dim_set.compressed:='Y';
  end if;
Exception when others then
  log_n('Exception in check_compressed_composite '||sqlerrm);
  raise;
End;

function check_countvar_cube_needed(p_dimset dim_set_r) return boolean is
l_countvar_flag boolean;
Begin
  l_countvar_flag:=false;
  if p_dimset.dim_set_type<>'target' then --if target, no countvar cube
    for i in 1..p_dimset.measure.count loop --create countvar only if needed
      if p_dimset.measure(i).agg_formula.avg_aggregation='Y' then
        l_countvar_flag:=true;
        exit;
      end if;
    end loop;
  end if;
  return l_countvar_flag;
Exception when others then
  log_n('Exception in check_countvar_cube_needed '||sqlerrm);
  raise;
End;

/*set dimset properties like pre-calc etc. only actuals?
*/
procedure set_dim_set_properties(p_kpi in out nocopy kpi_r) is
Begin
  for i in 1..p_kpi.dim_set.count loop
    set_dim_set_properties(p_kpi.dim_set(i));
  end loop;
Exception when others then
  log_n('Exception in set_dim_set_properties '||sqlerrm);
  raise;
End;

procedure set_dim_set_properties(p_dim_set in out nocopy dim_set_r) is
Begin
  --pre-calc
  if is_dimset_precalculated(p_dim_set) then
    p_dim_set.pre_calculated:='Y';
  else
    p_dim_set.pre_calculated:='N';
  end if;
Exception when others then
  log_n('Exception in set_dim_set_properties '||sqlerrm);
  raise;
End;

/*for now, see if there is any DS feeding at higher level and if so, its pre-calculated. ideally, pre-calc means all higher levels are
provided by DS. Q is : what if we have a case where some higher levels are from DS and the remaining higher levels have to be done by AW?
this can be quite complicated. user provides city and country. AW aggregates to state and then from country to region?
we do not consider this case. if DS provides any higher level or periodicity, its pre-calc */
function is_dimset_precalculated(p_dim_set dim_set_r) return boolean is
Begin
  return is_higher_level_preloaded(p_dim_set);
  /*later, also check is_higher_period_preloaded */
Exception when others then
  log_n('Exception in is_dimset_precalculated '||sqlerrm);
  raise;
End;

/* this looks at the cal hier and looks at the periodicities in the dimset and trims the parent child relation to have only the relevant
parent child relations*/
procedure get_relevant_cal_hier(p_periodicity periodicity_tb,p_pc cal_parent_child_tb,p_relevant_pc out nocopy cal_parent_child_tb) is
l_periodicity dbms_sql.varchar2_table;
Begin
  for i in 1..p_periodicity.count loop
    l_periodicity(l_periodicity.count+1):=p_periodicity(i).aw_dim;
  end loop;
  for i in 1..p_pc.count loop
    if (p_pc(i).parent_dim_name is null or bsc_aw_utility.in_array(l_periodicity,p_pc(i).parent_dim_name))
    and (p_pc(i).child_dim_name is null or bsc_aw_utility.in_array(l_periodicity,p_pc(i).child_dim_name)) then
      p_relevant_pc(p_relevant_pc.count+1):=p_pc(i);
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_relevant_cal_hier '||sqlerrm);
  raise;
End;

/*given a hier and a start value, it finds the upper hier */
procedure get_upper_cal_hier(p_pc cal_parent_child_tb,p_child varchar2,p_upper_hier out nocopy cal_parent_child_tb) is
l_pc bsc_aw_utility.parent_child_tb;
l_trim_pc bsc_aw_utility.parent_child_tb;
Begin
  for i in 1..p_pc.count loop
    l_pc(l_pc.count+1).parent:=p_pc(i).parent_dim_name;
    l_pc(l_pc.count).child:=p_pc(i).child_dim_name;
  end loop;
  bsc_aw_utility.get_upper_trim_hier(l_pc,p_child,l_trim_pc);
  --
  for i in 1..l_trim_pc.count loop
    for j in 1..p_pc.count loop
      if nvl(p_pc(j).parent_dim_name,'^^^')=nvl(l_trim_pc(i).parent,'^^^')
      and nvl(p_pc(j).child_dim_name,'^^^')=nvl(l_trim_pc(i).child,'^^^') then
        p_upper_hier(p_upper_hier.count+1):=p_pc(j);
        exit;
      end if;
    end loop;
  end loop;
Exception when others then
  log_n('Exception in get_upper_cal_hier '||sqlerrm);
  raise;
End;

/*temp variables period.temp and year.temp hold the period and year values. they are present in all cube loading programs. they are used when we
have BALANCE LAST VALUE type measure */
procedure create_temp_variables(p_dim_set dim_set_r,p_data_source data_source_r) is
l_balance_loaded_column varchar2(40);
Begin
  if bsc_aw_utility.get_property(p_data_source.property,g_balance_last_value_prop).property_value='Y' then
    bsc_aw_utility.add_g_commands(g_commands,'if exists(\'''||g_period_temp||'\'') eq false');
    bsc_aw_utility.add_g_commands(g_commands,'then do');
    bsc_aw_utility.add_g_commands(g_commands,'dfn '||g_period_temp||' NUMBER session');
    bsc_aw_utility.add_g_commands(g_commands,'doend');
    bsc_aw_utility.add_g_commands(g_commands,'if exists(\'''||g_year_temp||'\'') eq false');
    bsc_aw_utility.add_g_commands(g_commands,'then do');
    bsc_aw_utility.add_g_commands(g_commands,'dfn '||g_year_temp||' NUMBER session');
    bsc_aw_utility.add_g_commands(g_commands,'doend');
    /*columns to hold balance loaded are also temp . balance loaded column will hold number. see create_base_table_sql decodes this
    to number*/
    for i in 1..p_data_source.measure.count loop
      if p_data_source.measure(i).measure_type=g_balance_last_value_prop then
        l_balance_loaded_column:=bsc_aw_utility.get_property(p_data_source.measure(i).property,g_balance_loaded_column_prop).property_value;
        if l_balance_loaded_column is not null then
          bsc_aw_utility.add_g_commands(g_commands,'if exists(\'''||l_balance_loaded_column||'\'') eq false');
          bsc_aw_utility.add_g_commands(g_commands,'then do');
          bsc_aw_utility.add_g_commands(g_commands,'dfn '||l_balance_loaded_column||' NUMBER session');
          bsc_aw_utility.add_g_commands(g_commands,'doend');
        end if;
      end if;
    end loop;
  end if;
Exception when others then
  log_n('Exception in create_temp_variables '||sqlerrm);
  raise;
End;

procedure upgrade(p_new_version number,p_old_version number) is
Begin
  null;
Exception when others then
  log_n('Exception in upgrade '||sqlerrm);
  raise;
End;

function is_higher_level_preloaded(p_dim_set dim_set_r) return boolean is
Begin
  for i in 1..p_dim_set.dim.count loop
    for j in 1..p_dim_set.data_source.count loop
      for k in 1..p_dim_set.data_source(j).dim.count loop
        if p_dim_set.dim(i).dim_name=p_dim_set.data_source(j).dim(k).dim_name then
          if p_dim_set.dim(i).levels(1).level_name <> p_dim_set.data_source(j).dim(k).levels(1).level_name then
            if g_debug then
              log('Dimset dim '||p_dim_set.dim(i).dim_name||' has Lowest Level='||p_dim_set.dim(i).levels(1).level_name||', while DS has '||
              p_dim_set.data_source(j).dim(k).levels(1).level_name||'. Higher Level preloaded');
            end if;
            return true;
          end if;
          exit;
        end if;
      end loop;
    end loop;
  end loop;
  return false;
Exception when others then
  log_n('Exception in is_higher_level_preloaded '||sqlerrm);
  raise;
End;

function is_higher_period_preloaded(p_dim_set dim_set_r) return boolean is
Begin
  for i in 1..p_dim_set.data_source.count loop
    for j in 1..p_dim_set.calendar.periodicity.count loop
      if p_dim_set.calendar.periodicity(j).periodicity=p_dim_set.data_source(i).calendar.periodicity(1).periodicity then
        if p_dim_set.calendar.periodicity(j).lowest_level<>'Y' then
          if g_debug then
            log('Datasource has periodicity '||p_dim_set.data_source(i).calendar.periodicity(1).periodicity||' and this is not the lowest '||
            'periodicity in dimset ');
          end if;
          return true;
        end if;
        exit;
      end if;
    end loop;
  end loop;
  return false;
Exception when others then
  log_n('Exception in is_higher_period_preloaded '||sqlerrm);
  raise;
End;

procedure dmp_hpt_data(p_hpt_data hpt_data_r) is
Begin
  log('hpt dimensions');
  for i in 1..p_hpt_data.hpt_dimensions.count loop
    log(p_hpt_data.hpt_dimensions(i).dim_name||' '||p_hpt_data.hpt_dimensions(i).dim_type);
    for j in 1..p_hpt_data.hpt_dimensions(i).level_names.count loop
      log('  '||p_hpt_data.hpt_dimensions(i).level_names(j)||' ('||p_hpt_data.hpt_dimensions(i).level_keys(j)||')');
    end loop;
  end loop;
  log('hpt calendar');
  log(p_hpt_data.hpt_calendar.dim_name||' '||p_hpt_data.hpt_calendar.dim_type);
  for i in 1..p_hpt_data.hpt_calendar.level_names.count loop
    log('  '||p_hpt_data.hpt_calendar.level_names(i)||' ('||p_hpt_data.hpt_calendar.level_keys(i)||')');
  end loop;
Exception when others then
  log_n('Exception in dmp_hpt_data '||sqlerrm);
  raise;
End;

/*PT belong to dimsets. cubes point to the PT they want to use. DS has measures that its loading. from this, we find the cubes and find
the PT. from PT we can get all info like partition dim, hpt_data etc. we assume that all the cubes a DS is loading has a similar PT
so each DS deals with one PT*/
function get_DS_partition_template(p_dim_set dim_set_r,p_data_source data_source_r) return partition_template_r is
l_cube_set cube_set_r;
l_axis axis_tb;
l_pt partition_template_r;
Begin
  l_cube_set:=get_cube_set_for_measure(p_data_source.measure(1).measure,p_dim_set);
  l_axis:=l_cube_set.cube.cube_axis;
  for i in 1..l_axis.count loop
    if l_axis(i).axis_type='partition template' then
      l_pt.template_name:=l_axis(i).axis_name;
      exit;
    end if;
  end loop;
  if l_pt.template_name is not null then
    l_pt:=get_partition_template_r(l_pt.template_name,p_dim_set);
  end if;
  return l_pt;
Exception when others then
  log_n('Exception in get_DS_partition_template '||sqlerrm);
  raise;
End;

/*PT belong to dimsets. cubes point to the PT they want to use. DS has measures that its loading. from this, we find the cubes and find
the PT. from PT we can get all info like partition dim, hpt_data etc. we assume that all the cubes a DS is loading has similar PT
so each DS deals with one PT
because cube axis info is set in create_pt_comp_names, which comes after set_data_source_sql, for now, lets go with the assumption
that a dimset has cubes all of which share the PT characteristics*/
procedure set_data_source_PT(p_kpi kpi_r,p_dim_set in out nocopy dim_set_r) is
Begin
  if p_dim_set.number_partitions>0 then
    for i in 1..p_dim_set.data_source.count loop
      set_data_source_PT(p_dim_set,p_dim_set.data_source(i));
    end loop;
    for i in 1..p_dim_set.inc_data_source.count loop
      set_data_source_PT(p_dim_set,p_dim_set.inc_data_source(i));
    end loop;
  end if;
Exception when others then
  log_n('Exception in set_data_source_PT '||sqlerrm);
  raise;
End;

procedure set_data_source_PT(p_dim_set dim_set_r,p_data_source in out nocopy data_source_r) is
Begin
  p_data_source.data_source_PT.partition_template:=p_dim_set.master_partition_template(1);/*master_partition_template(1) is for datacubes */
  if p_data_source.data_source_PT.partition_template.template_name is not null then
    if p_dim_set.partition_type='hash' then
      /*we need info on hpt dimensions, rollups reqd if partition is at state level and DS is at city level */
      set_DS_hpt_rollup_data(p_dim_set,p_data_source);
    end if;
  end if;
Exception when others then
  log_n('Exception in set_data_source_PT '||sqlerrm);
  raise;
End;

/*given a DS and a dimset, this goes through the hpt data of the PT in the dimset, then assigns corrected hpt data to data source data_source_PT
it also loads data_source_pt.dim_parent_child and data_source_pt.cal_parent_child if rollups are reqd */
procedure set_DS_hpt_rollup_data(p_dim_set dim_set_r,p_data_source in out nocopy data_source_r) is
l_hpt_data hpt_data_r;
Begin
  l_hpt_data:=p_data_source.data_source_PT.partition_template.hpt_data;
  /*reset DS.partition.hpt_data info. we do so because we need to set only those levels that the DS is responsible for */
  p_data_source.data_source_PT.partition_template.hpt_data.hpt_dimensions.delete;
  set_DS_hpt_rollup_data(p_data_source.dim,l_hpt_data,p_data_source);
  set_DS_hpt_rollup_data(p_data_source.std_dim,l_hpt_data,p_data_source);
  set_DS_hpt_rollup_data(p_dim_set.calendar,p_data_source.calendar,l_hpt_data,p_data_source);
  /*we have to pass dimset cal because DS cal does not have all periodicities */
  if g_debug then
    log('Datasource Partition Template dmp for '||p_dim_set.dim_set_name||' '||p_data_source.ds_type);
    dmp_partition_template(p_data_source.data_source_PT.partition_template);
  end if;
Exception when others then
  log_n('Exception in set_DS_hpt_rollup_data '||sqlerrm);
  raise;
End;

/*p_dim can be normal or std dim */
procedure set_DS_hpt_rollup_data(p_DS_dim dim_tb,p_hpt_data hpt_data_r,p_data_source in out nocopy data_source_r) is
l_dim_parent_child parent_child_tb;/*for initialization */
l_index number;
l_parent_child bsc_aw_adapter_dim.dim_parent_child_tb;
l_pc_subset bsc_aw_adapter_dim.dim_parent_child_tb;
l_child_levels dbms_sql.varchar2_table;
Begin
  for i in 1..p_DS_dim.count loop
    for j in 1..p_hpt_data.hpt_dimensions.count loop /*hpt_dimension does not include time */
      if p_DS_dim(i).dim_name=p_hpt_data.hpt_dimensions(j).dim_name then
        p_data_source.data_source_PT.partition_template.hpt_data.hpt_dimensions(
        p_data_source.data_source_PT.partition_template.hpt_data.hpt_dimensions.count+1).dim_name:=p_hpt_data.hpt_dimensions(j).dim_name;
        p_data_source.data_source_PT.partition_template.hpt_data.hpt_dimensions(
        p_data_source.data_source_PT.partition_template.hpt_data.hpt_dimensions.count).dim_type:=p_hpt_data.hpt_dimensions(j).dim_type;
        l_dim_parent_child.delete;
        p_data_source.data_source_PT.dim_parent_child(p_hpt_data.hpt_dimensions(j).dim_name):=l_dim_parent_child;/*empty parent child info */
        l_index:=bsc_aw_utility.get_array_index(p_hpt_data.hpt_dimensions(j).level_names,p_DS_dim(i).levels(1).level_name);
        if l_index is not null then
          p_data_source.data_source_PT.partition_template.hpt_data.hpt_dimensions(
          p_data_source.data_source_PT.partition_template.hpt_data.hpt_dimensions.count).level_names(
          p_data_source.data_source_PT.partition_template.hpt_data.hpt_dimensions(
          p_data_source.data_source_PT.partition_template.hpt_data.hpt_dimensions.count).level_names.count+1):=
          p_hpt_data.hpt_dimensions(j).level_names(l_index);
          p_data_source.data_source_PT.partition_template.hpt_data.hpt_dimensions(
          p_data_source.data_source_PT.partition_template.hpt_data.hpt_dimensions.count).level_keys(
          p_data_source.data_source_PT.partition_template.hpt_data.hpt_dimensions(
          p_data_source.data_source_PT.partition_template.hpt_data.hpt_dimensions.count).level_keys.count+1):=
          p_hpt_data.hpt_dimensions(j).level_keys(l_index);
          /*level keys is initially set to dim(i).levels(j).fk */
        else
          /*there is rollup reqd . for std dim, this part should not be executed*/
          /*we will have to find the rollup info for each level that is partitioned and merge the parent child relations. example, we can have hier
          like comp>-prod>-prod fam, comp>-prod>-manager. we can have partition at prod fam and manager. then we find the rollup from comp->prodfam
          and comp->manager and then merge the 2 pc together */
          l_parent_child.delete;
          l_pc_subset.delete;
          l_child_levels.delete;
          bsc_aw_md_api.get_dim_parent_child(p_DS_dim(i).dim_name,l_parent_child);
          l_child_levels(l_child_levels.count+1):=p_DS_dim(i).levels(1).level_name;
          l_pc_subset:=bsc_aw_adapter_dim.get_hier_subset(l_parent_child,p_hpt_data.hpt_dimensions(j).level_names,l_child_levels);
          if l_pc_subset.count=0 then
            log('Could not rollup from '||p_DS_dim(i).levels(1).level_name||' to higher levels like '||p_hpt_data.hpt_dimensions(j).level_names(1));
            log('This means we cannot rollup from the dim level of the DS to the dim level at which the partition is defined. This is not allowed');
            raise bsc_aw_utility.g_exception;
          end if;
          l_dim_parent_child.delete;
          for k in 1..l_pc_subset.count loop
            l_dim_parent_child(l_dim_parent_child.count+1).parent_level:=l_pc_subset(k).parent_level;
            l_dim_parent_child(l_dim_parent_child.count).child_level:=l_pc_subset(k).child_level;
            l_dim_parent_child(l_dim_parent_child.count).parent_pk:=l_pc_subset(k).parent_pk;
            l_dim_parent_child(l_dim_parent_child.count).child_fk:=l_pc_subset(k).child_fk;
          end loop;
          p_data_source.data_source_PT.dim_parent_child(p_hpt_data.hpt_dimensions(j).dim_name):=l_dim_parent_child;
          /*from l_pc_subset, we need to find levels that match p_hpt_data.hpt_dimensions(j).level_names. these levels are then loaded
          into hpt_dimensions */
          for k in 1..p_hpt_data.hpt_dimensions(j).level_names.count loop
            for m in 1..l_pc_subset.count loop
              if p_hpt_data.hpt_dimensions(j).level_names(k)=l_pc_subset(m).parent_level then
                p_data_source.data_source_PT.partition_template.hpt_data.hpt_dimensions(
                p_data_source.data_source_PT.partition_template.hpt_data.hpt_dimensions.count).level_names(
                p_data_source.data_source_PT.partition_template.hpt_data.hpt_dimensions(
                p_data_source.data_source_PT.partition_template.hpt_data.hpt_dimensions.count).level_names.count+1):=
                l_pc_subset(m).child_level;
                p_data_source.data_source_PT.partition_template.hpt_data.hpt_dimensions(
                p_data_source.data_source_PT.partition_template.hpt_data.hpt_dimensions.count).level_keys(
                p_data_source.data_source_PT.partition_template.hpt_data.hpt_dimensions(
                p_data_source.data_source_PT.partition_template.hpt_data.hpt_dimensions.count).level_keys.count+1):=
                l_pc_subset(m).child_level||'.'||l_pc_subset(m).child_fk;
                /*we modify the level key to pick the child.fk example bsc_d_city.state_code when partition is at state
                its initially set to dim(i).levels(j).fk . we use this column to hash on
                if PT is at DS dim level,level_key will be simply city_code etc. if there is rollup, then it will be bsc_d_city.state_code etc */
                --
                exit;
              end if;
            end loop;
          end loop;
        end if;
        --
        exit;
      end if;
    end loop;
  end loop;
Exception when others then
  log_n('Exception in set_DS_hpt_rollup_data '||sqlerrm);
  raise;
End;

/*we can have multiple levels at which partitons are defined. example month and week
each DS can be at one periodicity only*/
procedure set_DS_hpt_rollup_data(p_calendar calendar_r,p_DS_calendar calendar_r,p_hpt_data hpt_data_r,p_data_source in out nocopy data_source_r) is
l_index number;
l_calendar bsc_aw_calendar.calendar_r;
l_ds_periodicity bsc_aw_calendar.periodicity_r;
l_upper_periodicities bsc_aw_calendar.periodicity_tb;
Begin
  p_data_source.data_source_PT.partition_template.hpt_data.hpt_calendar.dim_name:=null;
  p_data_source.data_source_PT.partition_template.hpt_data.hpt_calendar.level_names.delete;
  p_data_source.data_source_PT.partition_template.hpt_data.hpt_calendar.level_keys.delete;
  if p_hpt_data.hpt_calendar.dim_name is not null and p_hpt_data.hpt_calendar.dim_name=p_DS_calendar.aw_dim then
    p_data_source.data_source_PT.partition_template.hpt_data.hpt_calendar.dim_name:=p_hpt_data.hpt_calendar.dim_name;
    p_data_source.data_source_PT.partition_template.hpt_data.hpt_calendar.dim_type:=p_hpt_data.hpt_calendar.dim_type;
    l_index:=bsc_aw_utility.get_array_index(p_hpt_data.hpt_calendar.level_names,p_DS_calendar.periodicity(1).aw_dim);
    if l_index is not null then
      p_data_source.data_source_PT.partition_template.hpt_data.hpt_calendar.level_names(
      p_data_source.data_source_PT.partition_template.hpt_data.hpt_calendar.level_names.count+1):=
      p_hpt_data.hpt_calendar.level_names(l_index);
      p_data_source.data_source_PT.partition_template.hpt_data.hpt_calendar.level_keys(
      p_data_source.data_source_PT.partition_template.hpt_data.hpt_calendar.level_keys.count+1):=
      p_hpt_data.hpt_calendar.level_keys(l_index);
    else /*rollup required */
      /*find out the upper periodicities that DS periodicity touches */
      /*upgrade(to level 3) must reimplement all calendars so db_column_name is populated in bsc olap metadata */
      bsc_aw_calendar.get_calendar(p_DS_calendar.aw_dim,l_calendar);
      l_ds_periodicity:=bsc_aw_calendar.get_periodicity_r(p_DS_calendar.periodicity(1).periodicity,l_calendar.periodicity);
      bsc_aw_calendar.get_all_upper_periodicities(l_ds_periodicity,l_calendar,l_upper_periodicities);
      for j in 1..p_hpt_data.hpt_calendar.level_names.count loop
        for k in 1..l_upper_periodicities.count loop
          if p_hpt_data.hpt_calendar.level_names(j)=l_upper_periodicities(k).dim_name then
            p_data_source.data_source_PT.cal_parent_child(p_data_source.data_source_PT.cal_parent_child.count+1).parent:=
            l_upper_periodicities(k).periodicity_id;
            p_data_source.data_source_PT.cal_parent_child(p_data_source.data_source_PT.cal_parent_child.count).parent_dim_name:=
            l_upper_periodicities(k).db_column_name;
            p_data_source.data_source_PT.cal_parent_child(p_data_source.data_source_PT.cal_parent_child.count).child:=
            l_ds_periodicity.periodicity_id;
            p_data_source.data_source_PT.cal_parent_child(p_data_source.data_source_PT.cal_parent_child.count).child_dim_name:=
            l_ds_periodicity.db_column_name;
            --
            p_data_source.data_source_PT.partition_template.hpt_data.hpt_calendar.level_names(
            p_data_source.data_source_PT.partition_template.hpt_data.hpt_calendar.level_names.count+1):=l_upper_periodicities(k).dim_name;
            p_data_source.data_source_PT.partition_template.hpt_data.hpt_calendar.level_keys(
            p_data_source.data_source_PT.partition_template.hpt_data.hpt_calendar.level_keys.count+1):='bsc_db_calendar.'||
            l_upper_periodicities(k).db_column_name;
            --
            exit;
          end if;
        end loop;
      end loop;
    end if;
  end if;
Exception when others then
  log_n('Exception in set_DS_hpt_rollup_data '||sqlerrm);
  raise;
End;

function get_DS_PT_hash_stmt(p_dim_set dim_set_r,p_data_source data_source_r)return varchar2 is
pt_stmt varchar2(4000);
Begin
  pt_stmt:='dbms_utility.get_hash_value(\''H\''';
  for i in 1..p_data_source.data_source_PT.partition_template.hpt_data.hpt_dimensions.count loop /*loop through dim (Not time)*/
    for j in 1..p_data_source.data_source_PT.partition_template.hpt_data.hpt_dimensions(i).level_names.count loop
      pt_stmt:=pt_stmt||'||\''-\''||'||p_data_source.data_source_PT.partition_template.hpt_data.hpt_dimensions(i).level_keys(j);
    end loop;
  end loop;
  if p_data_source.data_source_PT.partition_template.hpt_data.hpt_calendar.dim_name is not null then
    for i in 1..p_data_source.data_source_PT.partition_template.hpt_data.hpt_calendar.level_names.count loop
      pt_stmt:=pt_stmt||'||\''-\''||'||p_data_source.data_source_PT.partition_template.hpt_data.hpt_calendar.level_keys(i)||'||\''.\''||year';
      /*append year also as part of the calendar key
      pt_ is appended to the columns selected from calendar to prevent clash with columns selected from the DS*/
    end loop;
  end if;
  pt_stmt:=pt_stmt||',0,'||p_dim_set.number_partitions||') ';
  return pt_stmt;
Exception when others then
  log_n('Exception in get_DS_PT_hash_stmt '||sqlerrm);
  raise;
End;

function is_dim_aggregated(p_dim dim_r) return boolean is
Begin
  /*if p_dim_set.dim(i).levels.count>1 or p_dim_set.dim(i).zero_code='Y' or p_dim_set.dim(i).recursive='Y' then */
  if p_dim.recursive='Y' then
    return true;
  else
    for i in 1..p_dim.levels.count loop
      if p_dim.levels(i).aggregated='Y' then
        if i=1 then /*lowest level */
          if p_dim.levels(i).zero_aggregated='Y' then /*lowest level and there is zero code */
            return true;
          end if;
        else
          return true;
        end if;
      end if;
    end loop;
  end if;
  return false;
Exception when others then
  log_n('Exception in is_dim_aggregated '||sqlerrm);
  raise;
End;

function is_calendar_aggregated(p_calendar calendar_r) return boolean is
Begin
  for i in 1..p_calendar.periodicity.count loop
    if p_calendar.periodicity(i).aggregated='Y'
    and (p_calendar.periodicity(i).lowest_level is null or p_calendar.periodicity(i).lowest_level<>'Y') then
      return true;
    end if;
  end loop;
  return false;
Exception when others then
  log_n('Exception in is_calendar_aggregated '||sqlerrm);
  raise;
End;

function get_projection_dim(p_dim_set dim_set_r) return varchar2 is
Begin
  for i in 1..p_dim_set.std_dim.count loop
    if p_dim_set.std_dim(i).dim_name='PROJECTION' then
      return p_dim_set.std_dim(i).dim_name;
    end if;
  end loop;
  return null;
Exception when others then
  log_n('Exception in get_projection_dim '||sqlerrm);
  raise;
End;

function make_display_cube_axis(p_dim_set dim_set_r,p_cube cube_r) return axis_tb is
l_axis axis_tb;
l_dimensions dbms_sql.varchar2_table;
Begin
  for i in 1..p_cube.cube_axis.count loop
    l_dimensions.delete;
    if p_cube.cube_axis(i).axis_type='partition template' then
      l_dimensions:=get_partition_template_r(p_cube.cube_axis(i).axis_name,p_dim_set).template_dimensions;
    elsif p_cube.cube_axis(i).axis_type='composite' then
      l_dimensions:=get_composite_r(p_cube.cube_axis(i).axis_name,p_dim_set).composite_dimensions;
    end if;
    if l_dimensions.count>0 then
      for j in 1..l_dimensions.count loop
        l_axis(l_axis.count+1).axis_name:=l_dimensions(j);
        l_axis(l_axis.count).axis_type:='dimension';
      end loop;
    else
      l_axis(l_axis.count+1):=p_cube.cube_axis(i);
    end if;
  end loop;
  return l_axis;
Exception when others then
  log_n('Exception in get_display_cube_axis '||sqlerrm);
  raise;
End;

/*sets the sql_aggregation flag for the measures to Y or N
unset is done only if the dimset is not partitioned
if we have a situation where the agg_formula looks like sum(m1/m2), we have to set this as sql_aggregated=Y. for aw, if this is a formula, we want
the formula to be like m1/m2. I guess this is how the metadata reader api will return the formula. we cannot have sum(m1/m2) specified. because the
formula is applied as it is. like cube3=cube1/cube2.
*/
procedure set_sql_aggregations(p_kpi in out nocopy kpi_r,p_action varchar2) is
Begin
  for i in 1..p_kpi.dim_set.count loop
    if (p_action='set' and bsc_aw_utility.get_db_version>=10.2 and p_kpi.dim_set(i).targets_higher_levels<>'Y')
    or (p_action='unset' and p_kpi.dim_set(i).number_partitions=0 and p_kpi.dim_set(i).compressed<>'Y') then
      set_sql_aggregations(p_kpi,p_kpi.dim_set(i),p_action);
    end if;
  end loop;
Exception when others then
  log_n('Exception in set_sql_aggregations '||sqlerrm);
  raise;
End;

/*if action=set
if there are targets, we do not set sql_aggregated to Y. we need to aggregate the measure and copy the targets
 */
procedure set_sql_aggregations(p_kpi kpi_r,p_dim_set in out nocopy dim_set_r,p_action varchar2) is
l_agg_flag varchar2(10);
Begin
  if p_action='set' then
    l_agg_flag:='Y';
  else
    l_agg_flag:='N';
  end if;
  for i in 1..p_dim_set.measure.count loop
    if p_dim_set.measure(i).agg_formula.std_aggregation='N' then
      p_dim_set.measure(i).sql_aggregated:=l_agg_flag;
    end if;
  end loop;
Exception when others then
  log_n('Exception in set_sql_aggregations '||sqlerrm);
  raise;
End;

procedure reset_PT_template(p_partition_template in out nocopy partition_template_r) is
Begin
  p_partition_template.template_name:=null;
  p_partition_template.template_type:=null;
  p_partition_template.template_use:=null;
  p_partition_template.template_dim:=null;
  p_partition_template.template_dimensions.delete;
  p_partition_template.template_partitions.delete;
  p_partition_template.hpt_data.hpt_dimensions.delete;
  p_partition_template.hpt_data.hpt_calendar.dim_name:=null;
Exception when others then
  log_n('Exception in reset_PT_template '||sqlerrm);
  raise;
End;

/*used in partitions to see if we can get partitions done with display cubes. data is copied into display cubes for
aggregations at viewer time */
function is_display_cube_required(p_dim_set dim_set_r,p_cube varchar2) return boolean is
measures measure_tb;
flag boolean;
Begin
  flag:=false;
  if p_dim_set.number_partitions>0 then
    if p_dim_set.compressed='Y' then
      if g_debug then
        log('Compressed composite. partitions possible only with display cube');
      end if;
      flag:=true;
    end if;
    if flag=false then
      measures.delete;
      get_measures_for_cube(p_cube,p_dim_set,measures);
      for i in 1..measures.count loop
        if measures(i).agg_formula.std_aggregation='N' and measures(i).sql_aggregated='N' then
          if g_debug then
            log('Non std agg in dimset '||p_dim_set.dim_set||', partitions possible only with display cube');
          end if;
          flag:=true;
          exit;
        end if;
        if bsc_aw_utility.is_PT_aggregation_function(measures(i).agg_formula.agg_formula)='N' then
          if g_debug then
            log('Non partitionable aggregation function '||measures(i).agg_formula.agg_formula||'. Partitions possible only with '||
           'display cubes');
          end if;
          flag:=true;
          exit;
        end if;
      end loop;
    end if;
  end if;
  return flag;
Exception when others then
  log_n('Exception in is_display_cube_required '||sqlerrm);
  raise;
End;

function is_display_cube_possible(p_dim_set dim_set_r) return boolean is
Begin
  if nvl(bsc_aw_utility.get_parameter_value('NO DISPLAY CUBE'),'N')='Y' then
    return false;
  end if;
  return true;
Exception when others then
  log_n('Exception in is_display_cube_possible '||sqlerrm);
  raise;
End;

function get_dim_set_lowest_periodicity(p_dim_set dim_set_r) return periodicity_tb is
periodicity periodicity_tb;
Begin
  for i in 1..p_dim_set.calendar.periodicity.count loop
    if p_dim_set.calendar.periodicity(i).lowest_level='Y' then
      periodicity(periodicity.count+1):=p_dim_set.calendar.periodicity(i);
    end if;
  end loop;
  return periodicity;
Exception when others then
  log_n('Exception in get_dim_set_lowest_periodicity '||sqlerrm);
  raise;
End;

------------------
procedure init_all is
Begin
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

END BSC_AW_ADAPTER_KPI;

/
