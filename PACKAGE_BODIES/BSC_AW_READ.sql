--------------------------------------------------------
--  DDL for Package Body BSC_AW_READ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_AW_READ" AS
/*$Header: BSCAWRDB.pls 120.21.12000000.4 2007/08/03 11:19:30 ankgoel ship $*/

/*
this procedure is used when we have filters at the resp or user level. we will use the
permit command to limit the dim values
*/
procedure init_filters(
p_user_name varchar2,
p_user_id number,
p_resp_name varchar2,
p_resp_id number
) is
Begin
  if g_init is null or g_init=false then
    init_all;
    g_init:=true;
  end if;
  if g_workspace_attached is null or g_workspace_attached=false then
    attach_workspace;
  end if;
Exception when others then
  bsc_aw_management.detach_workspace;
  g_workspace_attached:=false;
  log_n('Exception in init_filters '||sqlerrm);
  raise;
End;

/*
4486476
Issue is that PMV uses the short names for dimensions and measures. we use the dim table name and measure name from bsc
so we decided to do the lookup for them.
this api will convert the dim short names and measure short names in p_parameters to the ones in BSC
*/
procedure limit_dimensions_pmv(
p_kpi varchar2,
p_dim_set varchar2,
p_parameters BIS_PMV_PAGE_PARAMETER_TBL
) is
--
l_short_name dbms_sql.varchar2_table;
l_dim dbms_sql.varchar2_table;
l_measure dbms_sql.varchar2_table;
l_parameters BIS_PMV_PAGE_PARAMETER_TBL;
j integer;
Begin
  l_parameters:=p_parameters;
  l_short_name.delete;
  for i in 1..l_parameters.count loop
    if l_parameters(i).dimension='DIMENSION' then
      l_short_name(l_short_name.count+1):=l_parameters(i).parameter_name;
    end if;
  end loop;
  bsc_aw_bsc_metadata.get_dim_levels_for_short_names(l_short_name,l_dim);
  j:=1;
  for i in 1..l_parameters.count loop
    if l_parameters(i).dimension='DIMENSION' then
      l_parameters(i).parameter_name:=l_dim(j);
      j:=j+1;
    end if;
  end loop;
  -- measures
  l_short_name.delete;
  for i in 1..l_parameters.count loop
    if l_parameters(i).dimension='MEASURE' then
      l_short_name(l_short_name.count+1):=l_parameters(i).parameter_name;
    end if;
  end loop;
  bsc_aw_bsc_metadata.get_measures_for_short_names(l_short_name,l_measure);
  j:=1;
  for i in 1..l_parameters.count loop
    if l_parameters(i).dimension='MEASURE' then
      l_parameters(i).parameter_name:=l_measure(j);
      j:=j+1;
    end if;
  end loop;
  --
  limit_dimensions(p_kpi,p_dim_set,l_parameters);
Exception when others then
  log_n('Exception in limit_dimensions_pmv '||sqlerrm);
  raise;
End;

/*
this is a very imp procedure. this is called by PMV and iViewer to limit the dim values for query.
the api does the following
1. limit dimensions
2. sees if the level has been aggregated . if not it has to aggregate the level on the fly

in 10g, we may not need explicit limits. we will be using sql models and the database kernel will
automatically limit dimensions. not sure of the aggregation part.

p_parameters will contain

Dimensions and their values
Measures
Time periodicity and their values
Parameter_name        Parameter_id   Parameter_value            Dimension    Period_Date
BSC_D_COMPONENTS                      ABC                   DIMENSION
BSC_D_COMPONENTS                      XYZ                   DIMENSION
BSC_D_PRODUCT                         0                     DIMENSION
PERIODICITY 9                         10.2004               PERIODICITY
PERIODICITY 9                         11.2004 TO 21.2004    PERIODICITY
REVENUE                                                         MEASURE
COST                                                            MEASURE

ALL values are specified as
Parameter_name        Parameter_id   Parameter_value            Dimension    Period_Date
BSC_D_COMPONENTS                      ^ALL                   DIMENSION

You can specify multiple values for a dimension (bsc_d_components)
All value is specified as 0 (bsc_d_product)
You can specify range for periodicity (11.2004 TO 21.2004) Range is specified using TO
Periodicity must be indicated as PERIODICITY <PERIODICITY ID>
Measures also have to be indicated (Revenue and Cost)

assume that when this api is called, the user will have specified all dim levels that they need to limit
this means we will first do an "allstat"

*/
procedure limit_dimensions(
p_kpi varchar2,
p_dim_set varchar2,
p_parameters BIS_PMV_PAGE_PARAMETER_TBL
) is
--
l_status       varchar2(100);
l_kpi          varchar2(100);
l_kpi_in_cache boolean;
l_agg_status   varchar2(100);
l_parameters   BIS_PMV_PAGE_PARAMETER_TBL;
Begin
  if g_init is null or g_init=false then
    init_all;
    g_init:=true;
  end if;
  l_parameters:=p_parameters;
  if g_debug then
    dmp_parameters(l_parameters);
  end if;

  IF BSC_METADATA_OPTIMIZER_PKG.is_totally_shared_obj(p_kpi) THEN
    --totally shared objectives dont have AW summary objects
    SELECT source_indicator INTO l_kpi
      FROM bsc_kpis_b
      WHERE indicator  = p_kpi;
  ELSE
    l_kpi := p_kpi;
  END IF;

  --see if the kpi metadata is in
  l_kpi_in_cache:=check_kpi(l_kpi);
  if l_kpi_in_cache=false then
    load_kpi_metadata(l_kpi);
  end if;
  if g_kpi(l_kpi).status='non aw kpi' then --if this is a non aw kpi, return without doing anything.
    return;
  end if;
  if g_workspace_attached is null or g_workspace_attached=false then
    attach_workspace;
  end if;
  bsc_aw_dbms_aw.execute('allstat');
  if l_kpi_in_cache then
    --check to make sure that the kpi has not been modified. this will detach and attach workdspace if reqd. remove cache
    if check_kpi_change(l_kpi) then
      detach_workspace;
      attach_workspace;
      clear_all_cache;
      l_kpi_in_cache:=false;
    end if;
  end if;
  --
  if l_kpi_in_cache=false then --reload
    load_kpi_metadata(l_kpi);
  end if;
  if g_debug then
    dmp_kpi(g_kpi(l_kpi));
  end if;
  /*5155595 there can be cases where a formula measure alone is being looked at. formula measures are represented as on-line agg . this means
  if a formula measure alone is specified, no base measures get limited and nothing gets copied into display cube. we have to add relevant measures
  to l_parameters */
  add_relevant_measures(g_kpi(l_kpi).dim_set(p_dim_set),l_parameters);
  --load limit_track
  check_limit_track_seq(g_kpi(l_kpi).dim_set(p_dim_set),l_parameters,l_status);
  find_dimset_dimensions(g_kpi(l_kpi).dim_set(p_dim_set),l_parameters);
  find_dimset_xtd(g_kpi(l_kpi).dim_set(p_dim_set),l_parameters);
  limit_dimset(g_kpi(l_kpi).dim_set(p_dim_set),l_parameters);
  /*if there are display cubes, copy data into them */
  copy_data_display_cubes(g_kpi(l_kpi).dim_set(p_dim_set),l_parameters);
  --if aggregations are reqd, done in aggregate_dimensions
  l_agg_status:=find_agg_status(g_kpi(l_kpi).dim_set(p_dim_set));
  if l_agg_status <> 'no aggregate' then
    aggregate_dimset_dimensions(g_kpi(l_kpi).dim_set(p_dim_set),l_parameters);
  end if;
  --
  --limit the dim to the composites if we have ALL
  limit_dim_to_composite(g_kpi(l_kpi).dim_set(p_dim_set),l_parameters);
  --UI can now query from olap table function view
Exception when others then
  bsc_aw_management.detach_workspace;
  g_workspace_attached:=false;
  log_n('Exception in limit_dimensions '||sqlerrm);
  raise;
End;

function find_agg_status(p_dim_set dim_set_r) return varchar2 is
Begin
  if p_dim_set.dim_set.pre_calculated is null or p_dim_set.dim_set.pre_calculated='N' then
    return 'aggregate';
  else
    return 'no aggregate';
  end if;
Exception when others then
  log_n('Exception in find_agg_status '||sqlerrm);
  raise;
End;

function check_kpi(p_kpi varchar2) return boolean is
l_kpi varchar2(100);
Begin
  l_kpi:=g_kpi(p_kpi).kpi;
  return true;
Exception when others then
  return false;
End;

procedure load_kpi_metadata(p_kpi varchar2) is
l_olap_object bsc_aw_md_wrapper.bsc_olap_object_tb;
l_dim_set varchar2(100);
Begin
  g_kpi(p_kpi).kpi:=p_kpi;
  g_kpi(p_kpi).property.last_update_date:=bsc_metadata.get_kpi_LUD(p_kpi);
  g_kpi(p_kpi).dim_set.delete;
  g_kpi(p_kpi).dim_set_id.delete;
  --
  bsc_aw_md_api.get_kpi_dimset(p_kpi,l_olap_object);
  --if the kpi is not a AW kpi, simply return, do nothing.
  if l_olap_object.count=0 then
    g_kpi(p_kpi).status:='non aw kpi';
    return;
  end if;
  g_kpi(p_kpi).status:='aw kpi';
  --get dimset info for actuals
  for i in 1..l_olap_object.count loop
    if instr(l_olap_object(i).property1,'dim set type=actual') > 0 then
      l_dim_set:=bsc_aw_utility.get_parameter_value(l_olap_object(i).property1,'dim set',',');
      g_kpi(p_kpi).dim_set_id(g_kpi(p_kpi).dim_set_id.count+1):=l_dim_set;
      bsc_aw_md_api.get_kpi_dimset_md(p_kpi,l_olap_object(i).object,g_kpi(p_kpi).dim_set(l_dim_set).dim_set);
    end if;
  end loop;
  if g_debug then
    for i in 1..g_kpi(p_kpi).dim_set_id.count loop
      log('-------Dimset ----------');
      bsc_aw_adapter_kpi.dmp_dimset(g_kpi(p_kpi).dim_set(g_kpi(p_kpi).dim_set_id(i)).dim_set);
      log('---------------');
    end loop;
  end if;
  --load levels lookup table
  for i in 1..g_kpi(p_kpi).dim_set_id.count loop
    load_level_lookup(g_kpi(p_kpi).dim_set(g_kpi(p_kpi).dim_set_id(i)));
    load_level_drilldown(g_kpi(p_kpi).dim_set(g_kpi(p_kpi).dim_set_id(i)));
    load_periodicity_lookup(g_kpi(p_kpi),g_kpi(p_kpi).dim_set(g_kpi(p_kpi).dim_set_id(i)));
    load_periodicity_drilldown(g_kpi(p_kpi).dim_set(g_kpi(p_kpi).dim_set_id(i)));
    load_measures(g_kpi(p_kpi).dim_set(g_kpi(p_kpi).dim_set_id(i)));
  end loop;
Exception when others then
  log_n('Exception in load_kpi_metadata '||sqlerrm);
  raise;
End;

procedure load_level_lookup(p_dim_set in out nocopy dim_set_r) is
Begin
  p_dim_set.levels.delete;
  for i in 1..p_dim_set.dim_set.dim.count loop
    load_level_lookup(p_dim_set.dim_set.dim(i),p_dim_set);
  end loop;
  --load std dim
  for i in 1..p_dim_set.dim_set.std_dim.count loop
    load_level_lookup(p_dim_set.dim_set.std_dim(i),p_dim_set);
  end loop;
Exception when others then
  log_n('Exception in load_level_lookup '||sqlerrm);
  raise;
End;

procedure load_level_lookup(
p_dim bsc_aw_adapter_kpi.dim_r,
p_dim_set in out nocopy dim_set_r
) is
l_level_name varchar2(300);
Begin
  for i in 1..p_dim.levels.count loop
    l_level_name:=p_dim.levels(i).level_name;
    p_dim_set.level_names(p_dim_set.level_names.count+1):=l_level_name;
    p_dim_set.levels(l_level_name).level_name:=l_level_name;
    p_dim_set.levels(l_level_name).dim_name:=p_dim.dim_name;
    p_dim_set.levels(l_level_name).level_name_dim:=p_dim.level_name_dim;
    p_dim_set.levels(l_level_name).relation_name:=p_dim.relation_name;
    p_dim_set.levels(l_level_name).agg_map:=p_dim.agg_map.agg_map;
    p_dim_set.levels(l_level_name).zero_level:=p_dim.levels(i).zero_code_level;
    p_dim_set.levels(l_level_name).rec_parent_level:=p_dim.levels(i).rec_parent_level;
    p_dim_set.levels(l_level_name).position:=p_dim.levels(i).position;
    p_dim_set.levels(l_level_name).aggregated:=p_dim.levels(i).aggregated;
    p_dim_set.levels(l_level_name).zero_aggregated:=p_dim.levels(i).zero_aggregated;
  end loop;
Exception when others then
  log_n('Exception in load_level_lookup '||sqlerrm);
  raise;
End;

procedure load_periodicity_lookup(p_kpi kpi_r,p_dim_set in out nocopy dim_set_r) is
l_periodicity varchar2(100);
Begin
  --load calendar
  p_dim_set.calendar.aw_dim:=p_dim_set.dim_set.calendar.aw_dim;
  for i in 1..p_dim_set.dim_set.calendar.periodicity.count loop
    l_periodicity:=p_dim_set.dim_set.calendar.periodicity(i).periodicity;
    p_dim_set.calendar.periodicity(l_periodicity).aw_dim:=p_dim_set.dim_set.calendar.periodicity(i).aw_dim;
    p_dim_set.calendar.periodicity(l_periodicity).aggregated:=p_dim_set.dim_set.calendar.periodicity(i).aggregated;
    p_dim_set.calendar.periodicity(l_periodicity).calendar_aw_dim:=p_dim_set.dim_set.calendar.aw_dim;
    if p_dim_set.dim_set.calendar.periodicity(i).aggregated='N' then /*load current period which is used in agg to correct forecast */
      bsc_aw_load_kpi.get_forecast_current_period(p_kpi.kpi,p_dim_set.dim_set.calendar.calendar,p_dim_set.dim_set.calendar.periodicity(i).periodicity,
      p_dim_set.calendar.periodicity(l_periodicity).current_period);
    end if;
  end loop;
Exception when others then
  log_n('Exception in load_periodicity_lookup '||sqlerrm);
  raise;
End;

procedure load_level_drilldown(p_dim_set in out nocopy dim_set_r) is
--
l_level_name varchar2(300);
l_flag boolean;
--l_olap_object_relation bsc_aw_md_wrapper.bsc_olap_object_relation_tb;
l_child_levels dbms_sql.varchar2_table;
l_rel_level_name dbms_sql.varchar2_table;
Begin
  --we need to drill down only if aggregated is N
  --first see if a dim has any levels with aggregated=N
  for i in 1..p_dim_set.dim_set.dim.count loop
    l_flag:=false;
    for j in 1..p_dim_set.dim_set.dim(i).levels.count loop
      l_level_name:=p_dim_set.dim_set.dim(i).levels(j).level_name;
      if p_dim_set.levels(l_level_name).aggregated='N'  then
        l_flag:=true;
        exit;
      end if;
    end loop;
    --now if there is at-least one level with aggregated=N, we must find drill down levels
    if l_flag then
      for j in 1..p_dim_set.dim_set.dim(i).levels.count loop
        l_level_name:=p_dim_set.dim_set.dim(i).levels(j).level_name;
        if p_dim_set.levels(l_level_name).aggregated='N' then
          l_child_levels.delete;
          l_rel_level_name.delete; --'parent.child'
          get_child_level(
          l_level_name,
          p_dim_set.levels,
          p_dim_set.dim_set.dim(i).parent_child,
          l_child_levels,
          l_rel_level_name);
          p_dim_set.drill_down_levels(l_level_name).child_level:=l_child_levels;
          p_dim_set.drill_down_levels(l_level_name).rel_level_name:=l_rel_level_name; --'parent.child'
        end if;
      end loop;
    end if;
  end loop;
Exception when others then
  log_n('Exception in load_level_drilldown '||sqlerrm);
  raise;
End;

/*
find the child levels so we can use it to limit dim levels before drill down
  consider
      4
  2      3
       2-    1
  we have these levels with the positions indicated. if adv sum profile is 2 then we only store
  "3". this is because given "4" in the query, we will limit level name dim to 4 and then add "3".
  then we say drill down dim to children using relation. this will get the status to 2, 3 and then 2-, 1

called recursively

this is no more true. with the enhancement for handling diamond hierarchies, we have changed level name dim
to hold 'parent.child' as the hier, not just 'parent'
this means, we store in drill down levels '4.2', '4.3', '3.2-'

*/
procedure get_child_level(
p_level varchar2,
p_level_dim level_dim_tv,
p_parent_child bsc_aw_adapter_kpi.parent_child_tb,
p_child_levels in out nocopy dbms_sql.varchar2_table,
p_rel_level_name in out nocopy dbms_sql.varchar2_table
) is
l_child_levels dbms_sql.varchar2_table;
Begin
  --get immedate children if the position is > p_agg_level
  if p_level_dim(p_level).aggregated='N' then
    for i in 1..p_parent_child.count loop
      if p_parent_child(i).parent_level=p_level then
        p_child_levels(p_child_levels.count+1):=p_parent_child(i).child_level;
        p_rel_level_name(p_rel_level_name.count+1):=p_parent_child(i).parent_level||'.'||p_parent_child(i).child_level;
        l_child_levels(l_child_levels.count+1):=p_parent_child(i).child_level;
      end if;
    end loop;
    /*call recursively */
    for i in 1..l_child_levels.count loop
      get_child_level(l_child_levels(i),p_level_dim,p_parent_child,p_child_levels,p_rel_level_name);
    end loop;
  end if;
Exception when others then
  log_n('Exception in get_child_level '||sqlerrm);
  raise;
End;

procedure load_periodicity_drilldown(p_dim_set in out nocopy dim_set_r) is
l_child_levels dbms_sql.varchar2_table;
l_rel_level_name dbms_sql.varchar2_table;
Begin
  for i in 1..p_dim_set.dim_set.calendar.periodicity.count loop
    if p_dim_set.dim_set.calendar.periodicity(i).aggregated='N' then
      l_child_levels.delete;
      l_rel_level_name.delete;
      get_child_periodicity(p_dim_set.dim_set.calendar.periodicity(i).periodicity,p_dim_set.calendar.periodicity,
      p_dim_set.dim_set.calendar.parent_child,l_child_levels,l_rel_level_name);
      p_dim_set.calendar.drill_down_levels(p_dim_set.dim_set.calendar.periodicity(i).periodicity).child_level:=l_child_levels;
      p_dim_set.calendar.drill_down_levels(p_dim_set.dim_set.calendar.periodicity(i).periodicity).rel_level_name:=l_rel_level_name;
    end if;
  end loop;
Exception when others then
  log_n('Exception in load_periodicity_drilldown '||sqlerrm);
  raise;
End;

/*called recursively */
procedure get_child_periodicity(p_periodicity varchar2,p_cal_periodicity periodicity_tv,p_parent_child bsc_aw_adapter_kpi.cal_parent_child_tb,
p_child_levels in out nocopy dbms_sql.varchar2_table,p_rel_level_name in out nocopy dbms_sql.varchar2_table) is
l_child_levels dbms_sql.varchar2_table;
Begin
  if p_cal_periodicity(p_periodicity).aggregated='N' then
    for i in 1..p_parent_child.count loop
      if p_parent_child(i).parent_dim_name=p_cal_periodicity(p_periodicity).aw_dim then
        if p_parent_child(i).child_dim_name is not null then
          p_child_levels(p_child_levels.count+1):=p_parent_child(i).child;/*need the periodicity_id to index */
          p_rel_level_name(p_rel_level_name.count+1):=p_parent_child(i).parent_dim_name||'.'||p_parent_child(i).child_dim_name;
          l_child_levels(l_child_levels.count+1):=p_parent_child(i).child;
        end if;
      end if;
    end loop;
    /*call recursively */
    for i in 1..l_child_levels.count loop
      get_child_periodicity(l_child_levels(i),p_cal_periodicity,p_parent_child,p_child_levels,p_rel_level_name);
    end loop;
  end if;
Exception when others then
  log_n('Exception in get_child_periodicity '||sqlerrm);
  raise;
End;

procedure load_measures(p_dim_set in out nocopy dim_set_r) is
--
l_measure_name varchar2(100);
Begin
  p_dim_set.measure.delete;
  for i in 1..p_dim_set.dim_set.measure.count loop
    l_measure_name:=p_dim_set.dim_set.measure(i).measure;
    --pmv may pass upper measure name, we need to index with upper case
    p_dim_set.measure(upper(l_measure_name)):=p_dim_set.dim_set.measure(i);
  end loop;
Exception when others then
  log_n('Exception in load_measures '||sqlerrm);
  raise;
End;

/*5155595 there can be cases where a formula measure alone is being looked at. formula measures are represented as on-line agg . this means
if a formula measure alone is specified, no base measures get limited and nothing gets copied into display cube. we have to add relevant measures
to l_parameters */
procedure add_relevant_measures(p_dim_set dim_set_r,p_parameters in out nocopy BIS_PMV_PAGE_PARAMETER_TBL) is
l_measures dbms_sql.varchar2_table;
add_measures dbms_sql.varchar2_table;
add_all_measures boolean;
Begin
  add_measures.delete;
  add_all_measures:=false;
  get_measures(p_parameters,l_measures);
  for i in 1..l_measures.count loop
    l_measures(i):=upper(l_measures(i));
  end loop;
  if l_measures.count=0 then /*add all the measures of the dimset if none are specified */
    add_all_measures:=true;
  else /*if there are sql agg measures, make sure base measures are also in */
    for i in 1..p_dim_set.dim_set.measure.count loop
      if nvl(p_dim_set.dim_set.measure(i).sql_aggregated,'N')='Y' and p_dim_set.dim_set.measure(i).agg_formula.std_aggregation='N' then
        if bsc_aw_utility.in_array(l_measures,upper(p_dim_set.dim_set.measure(i).measure)) then
          if p_dim_set.dim_set.measure(i).agg_formula.measures.count>0 then /*add if the measures are not present */
            for j in 1..p_dim_set.dim_set.measure(i).agg_formula.measures.count loop
              if bsc_aw_utility.in_array(l_measures,upper(p_dim_set.dim_set.measure(i).agg_formula.measures(j)))=false then
                bsc_aw_utility.merge_value(add_measures,upper(p_dim_set.dim_set.measure(i).agg_formula.measures(j)));
              end if;
            end loop;
          else /*play safe. add all measures */
            add_all_measures:=true;
          end if;
        end if;
      end if;
    end loop;
  end if;
  if add_all_measures then
    for i in 1..p_dim_set.dim_set.measure.count loop
      if nvl(p_dim_set.dim_set.measure(i).sql_aggregated,'N')='N' then
        if bsc_aw_utility.in_array(l_measures,upper(p_dim_set.dim_set.measure(i).measure))=false then
          bsc_aw_utility.merge_value(add_measures,upper(p_dim_set.dim_set.measure(i).measure));
        end if;
      end if;
    end loop;
  end if;
  if add_measures.count>0 then
    for i in 1..add_measures.count loop
      if g_debug then
        log('Add extra measure '||add_measures(i)||' into p_parameters');
      end if;
      p_parameters.extend;
      p_parameters(p_parameters.count):=BIS_PMV_PAGE_PARAMETER_REC(add_measures(i),null,null,'MEASURE',null,null);
    end loop;
  end if;
Exception when others then
  log_n('Exception in add_relevant_measures '||sqlerrm);
  raise;
End;

/*
in this proedure we see if need to reaggregate etc. for now we simply adv the limit_track
in future, there is more intelligent processing here
*/
procedure check_limit_track_seq(
p_dim_set in out nocopy dim_set_r,
p_parameters BIS_PMV_PAGE_PARAMETER_TBL,
p_status out nocopy varchar2
) is
--
l_count number;
Begin
  l_count:=p_dim_set.limit_track.count+1;
  p_dim_set.limit_track(l_count).seq_no:=l_count;
  p_status:='new';
Exception when others then
  log_n('Exception in check_limit_track_seq '||sqlerrm);
  raise;
End;

/*
we load limit_dim structure in this api for both dimensions and periodicities
*/
procedure find_dimset_dimensions(
p_dim_set in out nocopy dim_set_r,
p_parameters BIS_PMV_PAGE_PARAMETER_TBL
) is
--
l_count number;
l_level varchar2(300);
Begin
  l_count:=p_dim_set.limit_track.count;
  for i in 1..p_parameters.count loop
    if p_parameters(i).dimension='DIMENSION' then
      --if rec dim, then we use the rec parent level
      l_level:=p_dim_set.levels(p_parameters(i).parameter_name).rec_parent_level;
      if l_level is null then --then not a rec dim
        l_level:=p_dim_set.levels(p_parameters(i).parameter_name).level_name;
      end if;
      p_dim_set.limit_track(l_count).limit_dim(p_dim_set.limit_track(l_count).limit_dim.count+1).level_name:=l_level;
      p_dim_set.limit_track(l_count).limit_dim(p_dim_set.limit_track(l_count).limit_dim.count).dim_name:=p_dim_set.levels(p_parameters(i).parameter_name).dim_name;
      p_dim_set.limit_track(l_count).limit_dim(p_dim_set.limit_track(l_count).limit_dim.count).dim_type:='DIMENSION';
      p_dim_set.limit_track(l_count).limit_dim(p_dim_set.limit_track(l_count).limit_dim.count).value:=
      nvl(p_parameters(i).parameter_id,p_parameters(i).parameter_value);
      /*had discussion with amod. 08/22/05. pmv passes dim code in parameter_id and the display name in parameter_value. iviewer may be passing
      the code in value. so we give paramter_id the priority.
      */
    end if;
  end loop;
  --now add time
  for i in 1..p_parameters.count loop
    if p_parameters(i).dimension='PERIODICITY' then
      p_dim_set.limit_track(l_count).limit_dim(p_dim_set.limit_track(l_count).limit_dim.count+1).level_name:=p_dim_set.calendar.periodicity(p_parameters(i).parameter_name).aw_dim;
      p_dim_set.limit_track(l_count).limit_dim(p_dim_set.limit_track(l_count).limit_dim.count).dim_name:=p_dim_set.calendar.periodicity(p_parameters(i).parameter_name).calendar_aw_dim;
      p_dim_set.limit_track(l_count).limit_dim(p_dim_set.limit_track(l_count).limit_dim.count).dim_type:='PERIODICITY';
      p_dim_set.limit_track(l_count).limit_dim(p_dim_set.limit_track(l_count).limit_dim.count).value:=
      nvl(p_parameters(i).parameter_id,p_parameters(i).parameter_value);
    end if;
  end loop;
  --
  set_viewby_dimensions(p_dim_set,p_parameters,p_dim_set.limit_track(l_count));
Exception when others then
  log_n('Exception in find_dimset_dimensions '||sqlerrm);
  raise;
End;

/*4637087. when dim is not specified, we need to set the value of the dim to ^ALL
this significantly improves performance
*/
procedure set_viewby_dimensions(
p_dim_set in out nocopy dim_set_r,
p_parameters BIS_PMV_PAGE_PARAMETER_TBL,
p_limit_track in out nocopy limit_track_r
) is
l_flag boolean;
l_dim_cache dbms_sql.varchar2_table;
Begin
  for i in 1..p_limit_track.limit_dim.count loop
    l_dim_cache(l_dim_cache.count+1):=p_limit_track.limit_dim(i).dim_name;
  end loop;
  for i in 1..p_dim_set.level_names.count loop
    l_flag:=false;
    for j in 1..p_parameters.count loop
      if p_parameters(j).dimension='DIMENSION' and p_parameters(j).parameter_name=p_dim_set.level_names(i) then
        l_flag:=true;
        exit;
      end if;
    end loop;
    --we will add this level only if there is no dim for this level
    if l_flag=false then --view by level
      if bsc_aw_utility.in_array(g_std_dim,p_dim_set.level_names(i))=false
      and (p_dim_set.levels(p_dim_set.level_names(i)).dim_name is null or bsc_aw_utility.in_array(l_dim_cache,
      p_dim_set.levels(p_dim_set.level_names(i)).dim_name)=false) then
        p_limit_track.limit_dim(p_limit_track.limit_dim.count+1).level_name:=nvl(p_dim_set.levels(p_dim_set.level_names(i)).rec_parent_level,
        p_dim_set.level_names(i));
        p_limit_track.limit_dim(p_limit_track.limit_dim.count).dim_name:=p_dim_set.levels(p_dim_set.level_names(i)).dim_name;
        p_limit_track.limit_dim(p_limit_track.limit_dim.count).dim_type:='DIMENSION';
        p_limit_track.limit_dim(p_limit_track.limit_dim.count).value:='^ALL';
      end if;
    end if;
  end loop;
Exception when others then
  log_n('Exception in set_viewby_dimensions '||sqlerrm);
  raise;
End;

/*this one sees if there is xtd and if there is xtd, loads limit_track with the xtd info
iviewer can pass down a : separated list of as of dates
*/
procedure find_dimset_xtd(
p_dim_set in out nocopy dim_set_r,
p_parameters BIS_PMV_PAGE_PARAMETER_TBL
) is
--
l_count number;
l_xtd_keys_table varchar2(100);
l_xtd_session_id number;
l_xtd_report_date dbms_sql.varchar2_table;
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
--
l_periodicity_id dbms_sql.varchar2_table;
l_period dbms_sql.varchar2_table;
Begin
  l_count:=p_dim_set.limit_track.count;
  for i in 1..p_parameters.count loop
    if p_parameters(i).dimension='XTD KEYS TABLE' then
      l_xtd_keys_table:=p_parameters(i).parameter_name;
    elsif p_parameters(i).dimension='XTD SESSION ID' then
      l_xtd_session_id:=to_number(p_parameters(i).parameter_name);
    elsif p_parameters(i).dimension='XTD REPORT DATE' then
      bsc_aw_utility.parse_parameter_values(p_parameters(i).parameter_name,':',l_xtd_report_date);
    end if;
  end loop;
  if l_xtd_keys_table is not null then
    bsc_aw_utility.delete_table('bsc_aw_temp_vn',null);
    forall i in 1..l_xtd_report_date.count
      execute immediate 'insert into bsc_aw_temp_vn(name) values (:1)' using l_xtd_report_date(i);
    g_stmt:='select to_char(periodicity_id),period||''.''||year period from '||l_xtd_keys_table||',bsc_aw_temp_vn where session_id=:1 and '||
    'to_char(report_date,''MM/DD/YYYY'')=bsc_aw_temp_vn.name order by periodicity_id';
    if g_debug then
      log_n(g_stmt||' using '||l_xtd_session_id);
    end if;
    open cv for g_stmt using l_xtd_session_id;
    loop
      fetch cv bulk collect into l_periodicity_id,l_period;
      exit when cv%notfound;
    end loop;
    close cv;
    for i in 1..l_periodicity_id.count loop
      p_dim_set.limit_track(l_count).limit_dim(p_dim_set.limit_track(l_count).limit_dim.count+1).level_name:=p_dim_set.calendar.periodicity(l_periodicity_id(i)).aw_dim;
      p_dim_set.limit_track(l_count).limit_dim(p_dim_set.limit_track(l_count).limit_dim.count).dim_name:=p_dim_set.calendar.periodicity(l_periodicity_id(i)).calendar_aw_dim;
      p_dim_set.limit_track(l_count).limit_dim(p_dim_set.limit_track(l_count).limit_dim.count).dim_type:='PERIODICITY';
      p_dim_set.limit_track(l_count).limit_dim(p_dim_set.limit_track(l_count).limit_dim.count).value:=l_period(i);
    end loop;
  end if;
  --
Exception when others then
  log_n('Exception in find_dimset_xtd '||sqlerrm);
  raise;
End;

--rkumar: bug#5954342
procedure validate_limit_range(p_lower_period in out nocopy varchar2,p_upper_period  in out nocopy varchar2, p_parameters  BIS_PMV_PAGE_PARAMETER_TBL)
is
l_calendar_id number(5);
l_periodicity_id number(5);
l_limit_range varchar2(32000);
l_max_period  varchar2(100);
l_min_period  varchar2(100);

begin
l_limit_range:=p_lower_period||' TO '||p_upper_period;
  for i in 1..p_parameters.count loop
    if p_parameters(i).dimension ='PERIODICITY' and p_parameters(i).parameter_value =l_limit_range then
       l_periodicity_id:=p_parameters(i).parameter_name;
    end if;
  end loop;

  select calendar_id into l_calendar_id from bsc_sys_periodicities where periodicity_id=l_periodicity_id;
  select max(year) into l_max_period from bsc_db_calendar where calendar_id=l_calendar_id;
  select min(year) into l_min_period from bsc_db_calendar where calendar_id=l_calendar_id;

  -- set the upper and lower periods based on the above query
  if  to_number(substr(p_lower_period,1,instr(p_lower_period,'.')-1)) < l_min_period then
      p_lower_period:=l_min_period||'.'||l_min_period;
  end if;

  if  to_number(substr(p_upper_period,1,instr(p_upper_period,'.')-1)) > l_max_period then
      p_upper_period:=l_max_period||'.'||l_max_period;
  end if;

Exception when others then
log_n('Exception in limit values '||sqlerrm);

End;

/*
this procedure looks at the latest p_dim_set.limit_track and limits the dim in it.
logic
limit levels to null
limit dim to null

limit levels add value
limit dim add level
*/
procedure limit_dimset(
p_dim_set dim_set_r,
p_parameters BIS_PMV_PAGE_PARAMETER_TBL
) is
--
l_count number;
l_parse_values bsc_aw_utility.value_tb;--use in the case when TO is used
l_cache bsc_aw_utility.boolean_table;--to prevent same object from being set to null again and again

l_lower_period varchar2(32000);
l_upper_period varchar2(32000);
Begin
  l_count:=p_dim_set.limit_track.count;
  for i in 1..p_dim_set.limit_track(l_count).limit_dim.count loop
    if l_cache.exists(p_dim_set.limit_track(l_count).limit_dim(i).level_name)=false then
      bsc_aw_dbms_aw.execute('limit '||p_dim_set.limit_track(l_count).limit_dim(i).level_name||' to NULL');
      l_cache(p_dim_set.limit_track(l_count).limit_dim(i).level_name):=true;
    end if;
    --limit_track.limit_dim.dim_name CAN BE NULL!!!
    if p_dim_set.limit_track(l_count).limit_dim(i).dim_name is not null then
      --this if clause eliminates dim with no concat dim like TYPE
      if p_dim_set.limit_track(l_count).limit_dim(i).dim_name <> p_dim_set.limit_track(l_count).limit_dim(i).level_name then
        if l_cache.exists(p_dim_set.limit_track(l_count).limit_dim(i).dim_name)=false then
          bsc_aw_dbms_aw.execute('limit '||p_dim_set.limit_track(l_count).limit_dim(i).dim_name||' to NULL');
          l_cache(p_dim_set.limit_track(l_count).limit_dim(i).dim_name):=true;
        end if;
      end if;
    end if;
  end loop;
  --
  /*
  to handle all, we need this logic
  when we limit dim to all, the dim may have 1000 values. so the status gets limited to all 1000 values. we may only have 2 of
  these values in the cube. but select from the mv will show all 1000 dim values. to restrict this to just the 2, we have to limit
  the dim to only those values in the composite
  in order to do this we do the following
  - limit dim to ALL (as before)
  - limit CC dim add dim (as before)
  - create a session boolean cube <CC dim>
  - for all composites
    - cube=true across composites
  - limit CC dim to cube
  */
  for i in 1..p_dim_set.limit_track(l_count).limit_dim.count loop
    if p_dim_set.limit_track(l_count).limit_dim(i).value='^ALL' then
      bsc_aw_dbms_aw.execute('limit '||p_dim_set.limit_track(l_count).limit_dim(i).level_name||' TO ALL');
    else
      --we need to handle time or any dim limited with the TO option. ie  limit month_5_cal_1 to ''1.2004'' TO ''12.2004''
      --input in BIS_PMV_PAGE_PARAMETER_TBL will be '1.2004 TO 12.2004'. we need to convert it to ''1.2004'' TO ''12.2004''
      --when limiting, we use execute_ne so that even if the user has not loaded the kpi or is specifying unloaded values, we do not
      --want the api to return error.
      if instr(p_dim_set.limit_track(l_count).limit_dim(i).value,' TO ')>0 then
       --rkumar: get the maximum and minimum values from the: Note.. need to modify the queries written below..
        l_parse_values.delete;
        bsc_aw_utility.parse_parameter_values(p_dim_set.limit_track(l_count).limit_dim(i).value,' TO ',l_parse_values);
        --see if its an year
        l_lower_period:=l_parse_values(1).parameter;
        l_upper_period:=l_parse_values(2).parameter;

        if substr(l_lower_period,1,instr(l_lower_period,'.') -1) = substr(l_lower_period,instr(l_lower_period,'.')+1) then
         validate_limit_range(l_lower_period,l_upper_period,p_parameters);
          bsc_aw_dbms_aw.execute_ne('limit '||p_dim_set.limit_track(l_count).limit_dim(i).level_name||' ADD '||
        ''''||l_lower_period||''' TO '''||l_upper_period||'''');
        else
        bsc_aw_dbms_aw.execute_ne('limit '||p_dim_set.limit_track(l_count).limit_dim(i).level_name||' ADD '||
        ''''||l_parse_values(1).parameter||''' TO '''||l_parse_values(2).parameter||'''');
        end if;

      else
        bsc_aw_dbms_aw.execute_ne('limit '||p_dim_set.limit_track(l_count).limit_dim(i).level_name||' ADD '||
        ''''||p_dim_set.limit_track(l_count).limit_dim(i).value||'''');
      end if;
    end if;
    if p_dim_set.limit_track(l_count).limit_dim(i).dim_name is not null then
      if p_dim_set.limit_track(l_count).limit_dim(i).dim_name <> p_dim_set.limit_track(l_count).limit_dim(i).level_name then
        bsc_aw_dbms_aw.execute('limit '||p_dim_set.limit_track(l_count).limit_dim(i).dim_name||' ADD '||
        p_dim_set.limit_track(l_count).limit_dim(i).level_name);
      end if;
    end if;
  end loop;
  --
Exception when others then
  log_n('Exception in limit_dimset '||sqlerrm);
  raise;
End;

/*
when we aggregate, if zero is specified for the level, we need to include the zero code level also when
limiting the level name dim. this means in the agg api, we have to scan limit_track and see if for a given
dim, zero is a specified value.

we have a virtual zero level for perf. not all kpi can have zero at the top level. also when agg on the fly, we
may not necessarily specify 0.
*/
function is_zero_specified_for_level(p_dim_set dim_set_r,p_level_name varchar2) return boolean is
--
l_count number;
Begin
  l_count:=p_dim_set.limit_track.count;
  for i in 1..p_dim_set.limit_track(l_count).limit_dim.count loop
    if p_dim_set.limit_track(l_count).limit_dim(i).level_name=p_level_name and p_dim_set.limit_track(l_count).limit_dim(i).value='0' then
      return true;
    end if;
  end loop;
  return false;
Exception when others then
  log_n('Exception in is_zero_specified_for_level '||sqlerrm);
  raise;
End;

/*
used in the ALL case.
for all dim,
- create a temp boolean cube
- set cube=true across all available composites
- set dim=true for the cube

NOTE!!NOTE!! we are going to consider only 1 composite even if there are many measures. the reason is that
even if the measures do have multiple composites (10g), they will all have the same values. remember that the
measures are loaded together and aggregated together. so the cubes of a dimset have the same dim status
4637087: it may be better to have ALL cubes for each dimset for each dim. this will have the bit set for each dim value
that the composite contains. this may be faster that limiting a dim to the composite. this may not be necessary also.
what if we have loop across composite specified in the view? loop across composite is improved in 10.2 so the all cubes may
not be necessary.
*/
procedure limit_dim_to_composite(
p_dim_set dim_set_r,
p_parameters BIS_PMV_PAGE_PARAMETER_TBL
) is
--
l_count number;
l_dim varchar2(300);
l_cube varchar2(200);
l_measures dbms_sql.varchar2_table;
l_composite varchar2(300);
l_comp_type varchar2(300);
l_dim_cache dbms_sql.varchar2_table;
Begin
  /*we cannot limit dim to a composite for compressed composite */
  if p_dim_set.dim_set.compressed='Y' then
    return;
  end if;
  l_cube:='bscawrdb_temp_dim_limit';
  get_measures(p_parameters,l_measures);
  l_composite:=bsc_aw_adapter_kpi.get_cube_pt_comp(p_dim_set.measure(upper(l_measures(1))).cube,p_dim_set.dim_set,l_comp_type);
  if l_composite is not null then
    --loop across all dim in the limit track
    l_count:=p_dim_set.limit_track.count;
    for i in 1..p_dim_set.limit_track(l_count).limit_dim.count loop
      if p_dim_set.limit_track(l_count).limit_dim(i).value='^ALL' then
        if p_dim_set.limit_track(l_count).limit_dim(i).dim_name is not null then
          l_dim:=p_dim_set.limit_track(l_count).limit_dim(i).dim_name;
        else
          l_dim:=p_dim_set.limit_track(l_count).limit_dim(i).level_name;
        end if;
        --
        if bsc_aw_utility.in_array(l_dim_cache,l_dim)=false then
          bsc_aw_dbms_aw.execute_ne('delete '||l_cube);
          bsc_aw_dbms_aw.execute('dfn '||l_cube||' boolean <'||l_dim||'>');
          bsc_aw_dbms_aw.execute(l_cube||' = true across '||l_composite);
          bsc_aw_dbms_aw.execute('limit '||l_dim||' to '||l_cube);
          l_dim_cache(l_dim_cache.count+1):=l_dim;
        end if;
        --
      end if;
    end loop;
  end if;
Exception when others then
  bsc_aw_dbms_aw.execute_ne('delete '||l_cube);
  log_n('Exception in limit_dim_to_composite '||sqlerrm);
  raise;
End;

/*
aggregation follows this logic
see in levels if any level needs agg
if yes,
    limit level name dim to the drill down levels
    push dim status
    drill dim down to children
    aggregate measures with std agg
    pop dim
    aggregate measures with formula
*/
procedure aggregate_dimset_dimensions(
p_dim_set dim_set_r,
p_parameters BIS_PMV_PAGE_PARAMETER_TBL
) is
--
l_measures dbms_sql.varchar2_table;
l_agg_measures dbms_sql.varchar2_table;
l_zero_specified boolean;
l_dim_aggregate dbms_sql.varchar2_table;
l_level dbms_sql.varchar2_table;
--
l_LT_index number;
l_periodicity dbms_sql.varchar2_table;
agg_cal_flag boolean;
agg_dim_flag boolean;
Begin
  /*
  push all dim
  drill down all dim
  then aggregate for each dim and then pop the dim
  */
  for i in 1..p_parameters.count loop
    if p_parameters(i).dimension='DIMENSION' then
      if bsc_aw_utility.in_array(l_level,p_dim_set.levels(p_parameters(i).parameter_name).level_name)=false then /*process a level only one time */
        l_level(l_level.count+1):=p_dim_set.levels(p_parameters(i).parameter_name).level_name;
        agg_dim_flag:=false;/*default */
        l_zero_specified:=false;
        if p_dim_set.levels(p_parameters(i).parameter_name).zero_level is not null then
          l_zero_specified:=is_zero_specified_for_level(p_dim_set,p_dim_set.levels(p_parameters(i).parameter_name).level_name);
        end if;
        if l_zero_specified and p_dim_set.levels(p_parameters(i).parameter_name).zero_aggregated='N' then
          agg_dim_flag:=true;
        end if;
        if p_dim_set.levels(p_parameters(i).parameter_name).aggregated='N' then
          agg_dim_flag:=true;
        end if;
        if agg_dim_flag then
          if bsc_aw_utility.in_array(l_dim_aggregate,p_dim_set.levels(p_parameters(i).parameter_name).dim_name)=false then
            bsc_aw_dbms_aw.execute('push '||p_dim_set.levels(p_parameters(i).parameter_name).dim_name);
            bsc_aw_dbms_aw.execute('limit '||p_dim_set.levels(p_parameters(i).parameter_name).level_name_dim||' TO NULL');
            l_dim_aggregate(l_dim_aggregate.count+1):=p_dim_set.levels(p_parameters(i).parameter_name).dim_name;
          end if;
          --if this level at which aggregatino is sought has zero code, and the value requested is zero then we need to limit
          --the level name dim to include zero code level also
          if l_zero_specified then
            if p_dim_set.levels(p_parameters(i).parameter_name).zero_level is not null then
              bsc_aw_dbms_aw.execute('limit '||p_dim_set.levels(p_parameters(i).parameter_name).level_name_dim||' ADD '''||
              p_dim_set.levels(p_parameters(i).parameter_name).zero_level||'.'||p_dim_set.levels(p_parameters(i).parameter_name).level_name||'''');
            end if;
          end if;
          if p_dim_set.levels(p_parameters(i).parameter_name).aggregated='N' then
            for j in 1..p_dim_set.drill_down_levels(p_parameters(i).parameter_name).child_level.count loop
              bsc_aw_dbms_aw.execute('limit '||p_dim_set.levels(p_parameters(i).parameter_name).level_name_dim||' ADD '''||
              p_dim_set.drill_down_levels(p_parameters(i).parameter_name).rel_level_name(j)||'''');
              /*rel_level_name will contain only those where there is no pre-aggregation. if agg is at city level and country data is asked, then
              rel_level_name contains country.state and state.city  so data can rollup from city to country */
              /*
              we were facing an issue:level 12 rolls to level 11. now, the relation is
              12        11      11:0
              0                 0
              1         1       0
              2         1       0
              we see that for value "0" in 12, we go directly to 11:0. lets say cube data is null for 12:0 when aggregated,
              this null replaces the aggregated values from 12(1,2) -> 11(1) -> 11(0)
              issue is resolved if we include the 12_zero.12 hierarchy.
              this way, all 12's data first rolls to 12:0 and then to 11:0.
              another way is to make the relation hold na for 12:0 -> 11:0
              BSC_CCDIM_1845_1846_1847.rel(BSC_D_AWDIMOBJ12 '0')=NA
              also note:::0 is always there in any level
              Q:what about precalculated indicators where users specify aggregated data for all the levels. they also specify data for
              0. does this mean we dont aggregate these kpis?
              */
              if l_zero_specified then
                bsc_aw_dbms_aw.execute(p_dim_set.levels(p_parameters(i).parameter_name).relation_name||'('||
                p_dim_set.drill_down_levels(p_parameters(i).parameter_name).child_level(j)||' ''0'')=NA');
              end if;
            end loop;
            --
            bsc_aw_dbms_aw.execute('limit '||p_dim_set.levels(p_parameters(i).parameter_name).dim_name||' ADD DESCENDANTS using '||
            p_dim_set.levels(p_parameters(i).parameter_name).relation_name);
            /*to be on the safe side, we keep only those levels where there is data aggregated. we should not go lower
            for now, lets assume that parent.child is limited correctly so that drill down to descendants will come down only to the point where top most
            agg data is available*/
            --
          end if;
        end if;
      end if;
    end if;
  end loop;
  /*drill down on time if needed . to see the time periodicities involved, we have to go through p_dim_set.limit_track. for xtd, p_parameters
  cannot give the periodicities cal is limited to*/
  l_LT_index:=p_dim_set.limit_track.count;
  for i in 1..p_dim_set.limit_track(l_LT_index).limit_dim.count loop
    if p_dim_set.limit_track(l_LT_index).limit_dim(i).dim_type='PERIODICITY' then
      for j in 1..p_dim_set.dim_set.calendar.periodicity.count loop
        if p_dim_set.limit_track(l_LT_index).limit_dim(i).level_name=p_dim_set.dim_set.calendar.periodicity(j).aw_dim then
          if bsc_aw_utility.in_array(l_periodicity,p_dim_set.dim_set.calendar.periodicity(j).periodicity)=false then
            l_periodicity(l_periodicity.count+1):=p_dim_set.dim_set.calendar.periodicity(j).periodicity;
          end if;
          --
          exit;
        end if;
      end loop;
    end if;
  end loop;
  agg_cal_flag:=false;
  for i in 1..l_periodicity.count loop
    if p_dim_set.calendar.periodicity(l_periodicity(i)).aggregated='N' then
      if agg_cal_flag=false then
        bsc_aw_dbms_aw.execute('push '||p_dim_set.calendar.aw_dim);
        bsc_aw_dbms_aw.execute('limit '||p_dim_set.dim_set.calendar.level_name_dim||' TO NULL');
        agg_cal_flag:=true;
      end if;
      for j in 1..p_dim_set.calendar.drill_down_levels(l_periodicity(i)).child_level.count loop
        bsc_aw_dbms_aw.execute('limit '||p_dim_set.dim_set.calendar.level_name_dim||' ADD '''||
        p_dim_set.calendar.drill_down_levels(l_periodicity(i)).rel_level_name(j)||'''');
      end loop;
      bsc_aw_dbms_aw.execute('limit '||p_dim_set.calendar.aw_dim||' ADD DESCENDANTS using '||p_dim_set.dim_set.calendar.relation_name);
    end if;
  end loop;
  --now, limit the dim to the values in the composite. this is for performance
  --earlier, we had a call here : limit_dim_to_composite(p_dim_set,p_parameters);
  --this is not reqd. imagine a case where we are aggregating on the fly and the value specified is not all
  --when we do limit dim to descendents ... we are going to end up with values not in the comp. aw is smart
  --enough to consider only the values in the comp for aggregation . its at the time of reporting that we
  --need to limit_dim_to_composite, this means at the very end
  --
  --aggregate
  if l_dim_aggregate.count>0 or agg_cal_flag then
    l_measures.delete;
    get_measures(p_parameters,l_measures);
    get_measures_aggregate(p_dim_set,l_measures,l_agg_measures);/*l_agg_measures is all the measures to agg */
    /*if there are display cubes, copy data into them. display cubes get aggregated. display cubes are used when we have CC and PT
    aggregate_cubes_dim and aggregate_cubes_calendar will aggregate the display cubes*/
    copy_data_display_cubes(p_dim_set,l_agg_measures);
    /*aggregate on dim */
    if l_dim_aggregate.count>0 then
      for i in 1..l_dim_aggregate.count loop
        aggregate_cubes_dim(p_dim_set,l_agg_measures,l_dim_aggregate(i));
        bsc_aw_dbms_aw.execute('pop '||l_dim_aggregate(i));
      end loop;
    end if;
    /*now aggregate on time if needed */
    if agg_cal_flag then
      aggregate_cubes_calendar(p_dim_set,l_agg_measures);
      bsc_aw_dbms_aw.execute('pop '||p_dim_set.calendar.aw_dim);
    end if;
    --if there are non std agg, (agg formula), do them now. the dim have been brought back to the higher levels
    aggregate_formula(p_dim_set,l_measures);
    /*correct forecast */
    if agg_cal_flag then
      correct_forecast(p_dim_set,l_measures,l_periodicity);
    end if;
  end if;
Exception when others then
  log_n('Exception in aggregate_dimset_dimensions '||sqlerrm);
  raise;
End;

/*forecast correction done for projected measures only
Q:In this procedure, if display_cube is not null, we correct it and not the main cube*/
procedure correct_forecast(p_dim_set dim_set_r,p_measures dbms_sql.varchar2_table,p_periodicity dbms_sql.varchar2_table) is
l_cubes dbms_sql.varchar2_table;
l_display_cubes dbms_sql.varchar2_table;
l_pt_comp varchar2(80);
l_stmt varchar2(4000);
l_projection_dim varchar2(80);
l_measures dbms_sql.varchar2_table;
l_pt_comp_type varchar2(80);
Begin
  for i in 1..p_measures.count loop
    if p_dim_set.measure(upper(p_measures(i))).forecast='Y' then
      /*5458597. measurename dim has mixed case.initially it was l_measures(l_measures.count+1):=p_measures(i) */
      l_measures(l_measures.count+1):=p_dim_set.measure(upper(p_measures(i))).measure;
    end if;
  end loop;
  if l_measures.count>0 then
    for i in 1..l_measures.count loop
      if bsc_aw_utility.in_array(l_cubes,p_dim_set.measure(upper(l_measures(i))).cube)=false then
        l_cubes(l_cubes.count+1):=p_dim_set.measure(upper(l_measures(i))).cube;
        l_display_cubes(l_display_cubes.count+1):=p_dim_set.measure(upper(l_measures(i))).display_cube;
      end if;
    end loop;
    l_projection_dim:=bsc_aw_adapter_kpi.get_projection_dim(p_dim_set.dim_set);
    bsc_aw_dbms_aw.execute('push '||p_dim_set.dim_set.measurename_dim);
    bsc_aw_dbms_aw.execute('push '||l_projection_dim);
    bsc_aw_dbms_aw.execute('push '||p_dim_set.calendar.aw_dim);
    bsc_aw_dbms_aw.execute('limit '||l_projection_dim||' TO ''Y''');
    bsc_aw_dbms_aw.execute('limit '||p_dim_set.calendar.aw_dim||' TO NULL');
    --bug:5954342 changed the dbms_aw.execute api to dbms_aw.execute_ne to shadow errors thrown in case of
    --non existing values
    for i in 1..p_periodicity.count loop
      if p_dim_set.calendar.periodicity(p_periodicity(i)).aggregated='N' then
        bsc_aw_dbms_aw.execute_ne('limit '||p_dim_set.calendar.periodicity(p_periodicity(i)).aw_dim||' TO '''||
        p_dim_set.calendar.periodicity(p_periodicity(i)).current_period||'''');
        bsc_aw_dbms_aw.execute_ne('limit '||p_dim_set.calendar.aw_dim||' ADD '||p_dim_set.calendar.periodicity(p_periodicity(i)).aw_dim);
      end if;
    end loop;
    if p_dim_set.dim_set.cube_design='datacube' then
      bsc_aw_dbms_aw.execute('limit '||p_dim_set.dim_set.measurename_dim||' to NULL');
      for i in 1..l_measures.count loop
        bsc_aw_dbms_aw.execute_ne('limit '||p_dim_set.dim_set.measurename_dim||' ADD '''||l_measures(i)||'''');
      end loop;
    end if;
    for i in 1..l_cubes.count loop
      l_pt_comp:=null;
      if l_display_cubes(i) is null then
        l_stmt:=l_cubes(i)||'=NA';
        l_pt_comp:=bsc_aw_adapter_kpi.get_cube_pt_comp(l_cubes(i),p_dim_set.dim_set,l_pt_comp_type);
      else
        l_stmt:=l_display_cubes(i)||'=NA';
        l_pt_comp:=bsc_aw_adapter_kpi.get_cube_pt_comp(l_display_cubes(i),p_dim_set.dim_set,l_pt_comp_type);
      end if;
      if l_pt_comp is not null then
        l_stmt:=l_stmt||' across '||l_pt_comp;
      end if;
      bsc_aw_dbms_aw.execute(l_stmt);
    end loop;
    bsc_aw_dbms_aw.execute('pop '||p_dim_set.dim_set.measurename_dim);
    bsc_aw_dbms_aw.execute('pop '||l_projection_dim);
    bsc_aw_dbms_aw.execute('pop '||p_dim_set.calendar.aw_dim);
  end if;
Exception when others then
  log_n('Exception in correct_forecast '||sqlerrm);
  raise;
End;

procedure get_measures(
p_parameters BIS_PMV_PAGE_PARAMETER_TBL,
p_measures out nocopy dbms_sql.varchar2_table
) is
Begin
  for i in 1..p_parameters.count loop
    if p_parameters(i).dimension='MEASURE' then
      p_measures(p_measures.count+1):=p_parameters(i).parameter_name;
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_measures '||sqlerrm);
  raise;
End;

/*
aggregate the given list of measures.
assume that the dim have been correctly limited

if non std agg
    get cubes in formula
    add them to the list of cubes to aggregate
    (we assume that these cubes are std agg!!)
endif;
aggregate cubes

we cannot aggregate  non std agg here. non std agg are done after all dim are poped back
to the requested level
*/
procedure aggregate_cubes_dim(
p_dim_set dim_set_r,
p_measures dbms_sql.varchar2_table,
p_dim varchar2) is
l_std_measures dbms_sql.varchar2_table;
l_agg_map varchar2(80);
Begin
  for i in 1..p_measures.count loop
    if p_dim_set.measure(upper(p_measures(i))).agg_formula.std_aggregation='Y' then
      l_std_measures(l_std_measures.count+1):=p_measures(i);
    end if;
  end loop;
  if l_std_measures.count>0 then
    for i in 1..p_dim_set.dim_set.dim.count loop
      if p_dim_set.dim_set.dim(i).dim_name=p_dim then
        l_agg_map:=p_dim_set.dim_set.dim(i).agg_map.agg_map;
        --
        exit;
      end if;
    end loop;
    if l_agg_map is not null then
      aggregate_cubes(p_dim_set,l_std_measures,l_agg_map);
    end if;
  end if;
Exception when others then
  log_n('Exception in aggregate_cubes '||sqlerrm);
  raise;
End;

/*only aggregate non bal measures on time */
procedure aggregate_cubes_calendar(p_dim_set dim_set_r,p_measures dbms_sql.varchar2_table) is
l_std_measures dbms_sql.varchar2_table;
l_nonbal_measures dbms_sql.varchar2_table;
l_agg_map varchar2(80);
Begin
  for i in 1..p_measures.count loop
    /*5458597. measurename dim has mixed case.earlier it was l_std_measures(l_std_measures.count+1):=p_measures(i) */
    if p_dim_set.measure(upper(p_measures(i))).agg_formula.std_aggregation='Y' then
      l_std_measures(l_std_measures.count+1):=p_dim_set.measure(upper(p_measures(i))).measure;
    end if;
  end loop;
  if l_std_measures.count>0 then
    l_agg_map:=p_dim_set.dim_set.calendar.agg_map.agg_map;
    if l_agg_map is not null then
      for i in 1..l_std_measures.count loop
        if p_dim_set.measure(upper(l_std_measures(i))).measure_type='NORMAL' then
          l_nonbal_measures(l_nonbal_measures.count+1):=l_std_measures(i);
        end if;
      end loop;
      if l_nonbal_measures.count>0 then
        aggregate_cubes(p_dim_set,l_nonbal_measures,l_agg_map);
      end if;
    end if;
  end if;
Exception when others then
  log_n('Exception in aggregate_cubes_calendar '||sqlerrm);
  raise;
End;

/*Q:In this procesure, we aggregate display_cube is its not null */
procedure aggregate_cubes(p_dim_set dim_set_r,p_std_measures dbms_sql.varchar2_table,p_agg_map varchar2) is
l_stmt varchar2(4000);
flag boolean;
l_cubes dbms_sql.varchar2_table;
l_countvar_cubes dbms_sql.varchar2_table;
l_display_cubes dbms_sql.varchar2_table;
Begin
  for i in 1..p_std_measures.count loop
    if bsc_aw_utility.in_array(l_cubes,p_dim_set.measure(upper(p_std_measures(i))).cube)=false then
      l_cubes(l_cubes.count+1):=p_dim_set.measure(upper(p_std_measures(i))).cube;
      l_countvar_cubes(l_countvar_cubes.count+1):=p_dim_set.measure(upper(p_std_measures(i))).countvar_cube;
      l_display_cubes(l_display_cubes.count+1):=p_dim_set.measure(upper(p_std_measures(i))).display_cube;
    end if;
  end loop;
  bsc_aw_dbms_aw.execute('limit '||p_dim_set.dim_set.aggmap_operator.measure_dim||' to NULL');
  /*Q:can we assume that if there is display cube, it alone needs to be aggregated
  Q: here, we do not worry about partitions because we aggregate all partitions*/
  for i in 1..p_std_measures.count loop
    if p_dim_set.measure(upper(p_std_measures(i))).display_cube is null then
      bsc_aw_dbms_aw.execute('limit '||p_dim_set.dim_set.aggmap_operator.measure_dim||' ADD '''||
      p_dim_set.measure(upper(p_std_measures(i))).cube||'''');
    else
      bsc_aw_dbms_aw.execute('limit '||p_dim_set.dim_set.aggmap_operator.measure_dim||' ADD '''||
      p_dim_set.measure(upper(p_std_measures(i))).display_cube||'''');
    end if;
  end loop;
  bsc_aw_dbms_aw.execute('push '||p_dim_set.dim_set.measurename_dim);
  /*if datacube, we need to limit measurename dim */
  if p_dim_set.dim_set.cube_design='datacube' then
    bsc_aw_dbms_aw.execute('limit '||p_dim_set.dim_set.measurename_dim||' to NULL');
    for i in 1..p_std_measures.count loop
      bsc_aw_dbms_aw.execute('limit '||p_dim_set.dim_set.measurename_dim||' ADD '''||p_std_measures(i)||'''');
    end loop;
  end if;
  --aggregate cubes with countvar cubes
  flag:=false;
  l_stmt:='aggregate ';
  for i in 1..l_countvar_cubes.count loop
    if l_countvar_cubes(i) is not null then
      flag:=true;
      if l_display_cubes(i) is null then
        l_stmt:=l_stmt||l_cubes(i)||' ';
      else
        l_stmt:=l_stmt||l_display_cubes(i)||' ';
      end if;
    end if;
  end loop;
  l_stmt:=l_stmt||' using '||p_agg_map||' countvar ';
  for i in 1..l_countvar_cubes.count loop
    if l_countvar_cubes(i) is not null then
      l_stmt:=l_stmt||l_countvar_cubes(i)||' ';
    end if;
  end loop;
  if flag then
    bsc_aw_dbms_aw.execute(l_stmt);
  end if;
  /*no countvar cubes */
  flag:=false;
  l_stmt:='aggregate ';
  for i in 1..l_countvar_cubes.count loop
    if l_countvar_cubes(i) is null then
      flag:=true;
      if l_display_cubes(i) is null then
        l_stmt:=l_stmt||l_cubes(i)||' ';
      else
        l_stmt:=l_stmt||l_display_cubes(i)||' ';
      end if;
    end if;
  end loop;
  l_stmt:=l_stmt||' using '||p_agg_map;
  if flag then
    bsc_aw_dbms_aw.execute(l_stmt);
  end if;
  bsc_aw_dbms_aw.execute('pop '||p_dim_set.dim_set.measurename_dim);
Exception when others then
  log_n('Exception in aggregate_cubes '||sqlerrm);
  raise;
End;

/*Q:here also, if the display_cube is not null, its calculated */
procedure aggregate_formula(p_dim_set dim_set_r,p_measures dbms_sql.varchar2_table) is
l_cube varchar2(100);
Begin
  --if there are non std agg, (agg formula), do them now. the dim have been brought back to the higher levels
  for i in 1..p_measures.count loop
    if p_dim_set.measure(upper(p_measures(i))).agg_formula.std_aggregation='N' and p_dim_set.measure(upper(p_measures(i))).sql_aggregated='N' then
      if p_dim_set.measure(upper(p_measures(i))).display_cube is null then
        l_cube:=p_dim_set.measure(upper(p_measures(i))).cube;
      else
        l_cube:=p_dim_set.measure(upper(p_measures(i))).display_cube;
      end if;
      if p_dim_set.dim_set.cube_design='datacube' then
        /*5458597. measurename dim has mixed case. earlier it was p_dim_set.dim_set.measurename_dim||' '''||p_measures(i)||''')=*/
        bsc_aw_dbms_aw.execute(l_cube||'('||p_dim_set.dim_set.measurename_dim||' '''||
        p_dim_set.measure(upper(p_measures(i))).measure||''')='||p_dim_set.measure(upper(p_measures(i))).agg_formula.agg_formula);
      else
        bsc_aw_dbms_aw.execute(l_cube||'='||p_dim_set.measure(upper(p_measures(i))).agg_formula.agg_formula);
      end if;
    end if;
  end loop;
Exception when others then
  log_n('Exception in aggregate_formula '||sqlerrm);
  raise;
End;

procedure get_measures_aggregate(p_dim_set dim_set_r,p_measures dbms_sql.varchar2_table,p_agg_measures out nocopy dbms_sql.varchar2_table) is
l_cubes dbms_sql.varchar2_table;
Begin
  for i in 1..p_measures.count loop
    if p_dim_set.measure(upper(p_measures(i))).agg_formula.std_aggregation='N' and p_dim_set.measure(upper(p_measures(i))).sql_aggregated='N' then
      --
      l_cubes.delete;
      for j in 1..p_dim_set.measure(upper(p_measures(i))).agg_formula.cubes.count loop
        if bsc_aw_utility.in_array(l_cubes,p_dim_set.measure(upper(p_measures(i))).agg_formula.cubes(j))=false then
          l_cubes(l_cubes.count+1):=p_dim_set.measure(upper(p_measures(i))).agg_formula.cubes(j);
        end if;
      end loop;
      /*if we have non std agg, then we need to make sure that the source cubes for the formula are aggregated. this means we need to parse out
      this info etc. so, to be safe, we look at all cubes that the given measures affect and then get all measures for these cubes */
      for j in 1..l_cubes.count loop
        for k in 1..p_dim_set.dim_set.measure.count loop
          if p_dim_set.dim_set.measure(k).cube=l_cubes(j) then
            if bsc_aw_utility.in_array(p_agg_measures,p_dim_set.dim_set.measure(k).measure)=false then
              p_agg_measures(p_agg_measures.count+1):=p_dim_set.dim_set.measure(k).measure;
            end if;
            --
            exit;
          end if;
        end loop;
      end loop;
    else
      p_agg_measures(p_agg_measures.count+1):=p_measures(i);
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_measures_aggregate '||sqlerrm);
  raise;
End;

procedure dmp_kpi(p_kpi kpi_r) is
Begin
  log_n('=======================================');
  log('Dmp KPI '||p_kpi.kpi);
  for i in 1..p_kpi.dim_set_id.count loop
    log('Dimset '||p_kpi.dim_set_id(i));
    dmp_dimset(p_kpi.dim_set(p_kpi.dim_set_id(i)));
    log('---------End Dimset Dmp----------------');
  end loop;
  log_n('=========END==========================');
Exception when others then
  log_n('Exception in dmp_kpi '||sqlerrm);
  raise;
End;

procedure dmp_dimset(p_dimset dim_set_r) is
Begin
  log('Level_tv dmp');
  for i in 1..p_dimset.dim_set.dim.count loop
    for j in 1..p_dimset.dim_set.dim(i).levels.count loop
      dmp_level_dim_r(p_dimset.levels(p_dimset.dim_set.dim(i).levels(j).level_name));
    end loop;
  end loop;
  --std dim
  for i in 1..p_dimset.dim_set.std_dim.count loop
    for j in 1..p_dimset.dim_set.std_dim(i).levels.count loop
      dmp_level_dim_r(p_dimset.levels(p_dimset.dim_set.std_dim(i).levels(j).level_name));
    end loop;
  end loop;
  --
  log('Drill_Down_Level_tv dmp');
  for i in 1..p_dimset.dim_set.dim.count loop
    for j in 1..p_dimset.dim_set.dim(i).levels.count loop
      if p_dimset.levels(p_dimset.dim_set.dim(i).levels(j).level_name).aggregated='N' then
        log('Level='||p_dimset.dim_set.dim(i).levels(j).level_name);
        for k in 1..p_dimset.drill_down_levels(p_dimset.dim_set.dim(i).levels(j).level_name).child_level.count loop
          log('Drill down level='||p_dimset.drill_down_levels(p_dimset.dim_set.dim(i).levels(j).level_name).child_level(k)||' '||
          ',rel level name='||p_dimset.drill_down_levels(p_dimset.dim_set.dim(i).levels(j).level_name).rel_level_name(k));
        end loop;
      end if;
    end loop;
  end loop;
  --
  for i in 1..p_dimset.dim_set.calendar.periodicity.count loop
    dmp_periodicity_r(p_dimset.calendar.periodicity(p_dimset.dim_set.calendar.periodicity(i).periodicity));
  end loop;
  --
  for i in 1..p_dimset.dim_set.measure.count loop
    bsc_aw_adapter_kpi.dmp_measure(p_dimset.measure(upper(p_dimset.dim_set.measure(i).measure)));
  end loop;
  --
Exception when others then
  log_n('Exception in dmp_dimset '||sqlerrm);
  raise;
End;

procedure dmp_level_dim_r(p_level level_dim_r) is
Begin
  log('level='||
  p_level.level_name||' dim='||
  p_level.dim_name||' level name dim='||
  p_level.level_name_dim||' rel name='||
  p_level.relation_name||' agg map='||
  p_level.agg_map||' zero level='||
  p_level.zero_level||' rec parent level='||
  p_level.rec_parent_level||' position='||
  p_level.position||' aggregated='||
  p_level.aggregated||' zero_aggregated='||p_level.zero_aggregated
  );
Exception when others then
  log_n('Exception in dmp_level_dim_r '||sqlerrm);
  raise;
End;

procedure dmp_periodicity_r(p_periodicity periodicity_r) is
Begin
  log('periodicity aw dim='||p_periodicity.aw_dim||', calendar dim='||p_periodicity.calendar_aw_dim||' aggregated='||p_periodicity.aggregated
  );
Exception when others then
  log_n('Exception in dmp_periodicity_r '||sqlerrm);
  raise;
End;

procedure attach_workspace is
l_bsc_olap_object bsc_aw_md_wrapper.bsc_olap_object_tb;
Begin
  begin
    bsc_aw_management.get_workspace_lock('ro',null); --read only mode
  exception when others then
    if sqlcode=-33262 then
      --ignore this error.  this may be a MV instance
      null;
    else
      raise;
    end if;
  end;
  g_workspace_attached:=true;
Exception when others then
  log_n('Exception in attach_workspace '||sqlerrm);
  raise;
End;

procedure detach_workspace is
Begin
  begin
    bsc_aw_management.detach_workspace;
  exception when others then
    if sqlcode=-33262 then
      --ignore this error.  this may be a MV instance
      null;
    else
      raise;
    end if;
  end;
  g_workspace_attached:=false;
Exception when others then
  log_n('Exception in detach_workspace '||sqlerrm);
  raise;
End;

procedure dmp_parameters(p_parameters BIS_PMV_PAGE_PARAMETER_TBL) is
Begin
  log('Parameter dmp');
  for i in 1..p_parameters.count loop
    log(p_parameters(i).parameter_name||' '||p_parameters(i).parameter_id||' '||p_parameters(i).parameter_value||' '||p_parameters(i).dimension);
  end loop;
  log('--------');
Exception when others then
  log_n('Exception in dmp_parameters '||sqlerrm);
  raise;
End;

procedure clear_all_cache is
Begin
  g_kpi.delete;
Exception when others then
  log_n('Exception in clear_all_cache '||sqlerrm);
  raise;
End;

function check_kpi_change(p_kpi varchar2) return boolean is
l_date date;
Begin
  l_date:=bsc_metadata.get_kpi_LUD(p_kpi);
  if l_date>g_kpi(p_kpi).property.last_update_date then
    return true;
  end if;
  return false;
Exception when others then
  log_n('Exception in check_kpi_change '||sqlerrm);
  raise;
End;

/*when there are partitions and CC, we need display cubes to handle aggregations on the fly. CC cubes cannot be aggregated on the fly
if there are balance measures that are already aggregated in time, these have to be copied too. so we should not lose the data at the
specified dim levels*/
procedure copy_data_display_cubes(p_dim_set dim_set_r,p_parameters BIS_PMV_PAGE_PARAMETER_TBL) is
l_measures dbms_sql.varchar2_table;
Begin
  get_measures(p_parameters,l_measures);
  copy_data_display_cubes(p_dim_set,l_measures);
Exception when others then
  log_n('Exception in copy_data_display_cubes '||sqlerrm);
  raise;
End;

procedure copy_data_display_cubes(p_dim_set dim_set_r,p_measures dbms_sql.varchar2_table) is
l_cubes dbms_sql.varchar2_table;
l_display_cubes dbms_sql.varchar2_table;
Begin
  for i in 1..p_measures.count loop
    if p_dim_set.measure(upper(p_measures(i))).sql_aggregated='N'
    and bsc_aw_utility.in_array(l_cubes,p_dim_set.measure(upper(p_measures(i))).cube)=false then
      l_cubes(l_cubes.count+1):=p_dim_set.measure(upper(p_measures(i))).cube;
      l_display_cubes(l_display_cubes.count+1):=p_dim_set.measure(upper(p_measures(i))).display_cube;
    end if;
  end loop;
  for i in 1..l_cubes.count loop
    if l_display_cubes(i) is not null then
      copy_data_display_cubes(p_dim_set,l_cubes(i),l_display_cubes(i));
    end if;
  end loop;
Exception when others then
  log_n('Exception in copy_data_display_cubes '||sqlerrm);
  raise;
End;

/*when this api is called, dim should be properly limited */
procedure copy_data_display_cubes(p_dim_set dim_set_r,p_cube varchar2,p_display_cube varchar2) is
l_pt_comp varchar2(100);
l_pt_comp_type varchar2(100);
l_stmt varchar2(4000);
Begin
  l_pt_comp:=bsc_aw_adapter_kpi.get_cube_pt_comp(p_cube,p_dim_set.dim_set,l_pt_comp_type);
  l_stmt:=p_display_cube||'='||p_cube;
  if l_pt_comp is not null then
    l_stmt:=l_stmt||' across '||l_pt_comp;
  end if;
  bsc_aw_dbms_aw.execute(l_stmt);
Exception when others then
  log_n('Exception in copy_data_display_cubes '||sqlerrm);
  raise;
End;

---------------------------------------------------------------------------
procedure init_all is
Begin
  if bsc_aw_utility.get_parameter_value(bsc_aw_utility.g_options,'DEBUG LOG')='Y'
  or bsc_aw_utility.g_log_level>=FND_LOG.G_CURRENT_RUNTIME_LEVEL then
    g_debug:=true;
  else
    g_debug:=false;
  end if;
  bsc_aw_utility.init_all(g_debug);
  BSC_AW_MD_API.init_all;
  bsc_aw_dbms_aw.init_all;
  bsc_aw_management.init_all;
  g_std_dim:=bsc_aw_adapter_dim.get_std_dim_list;
  if nvl(bsc_aw_utility.get_parameter_value('FILE LOG'),'N')='Y' then
    g_log_type:='file log';
  else
    g_log_type:='fnd log';
  end if;
Exception when others then
  null;
End;

procedure log(p_message varchar2) is
Begin
  if g_log_type='fnd log' then
    bsc_aw_utility.log_fnd(p_message,bsc_aw_utility.g_log_level);
  else
    bsc_aw_utility.log(p_message);
  end if;
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

END BSC_AW_READ;

/
