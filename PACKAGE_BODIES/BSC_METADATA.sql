--------------------------------------------------------
--  DDL for Package Body BSC_METADATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_METADATA" AS
/*$Header: BSCMTDTB.pls 120.12 2006/04/20 11:28 vsurendr noship $*/

/*
for now, just hard code metadata
later, replaced with arun's api on standard output
*/
procedure get_parent_level(
p_level varchar2,
p_parents out nocopy BSC_AW_ADAPTER_DIM.dim_parent_child_tb
) is
--
l_tab_ClsLevelRelationship bsc_dbgen_std_metadata.tab_ClsLevelRelationship;
Begin
  l_tab_ClsLevelRelationship:=bsc_dbgen_metadata_reader.get_parents_for_level_aw(p_level,1);
  for i in 1..l_tab_ClsLevelRelationship.count loop
    p_parents(i).parent_level:=l_tab_ClsLevelRelationship(i).parent_level;
    p_parents(i).parent_pk:=l_tab_ClsLevelRelationship(i).parent_level_pk;
    p_parents(i).child_level:=l_tab_ClsLevelRelationship(i).child_level;
    p_parents(i).child_fk:=l_tab_ClsLevelRelationship(i).child_level_fk;
  end loop;
Exception when others then
  log_n('Exception in get_parent_level '||sqlerrm);
  raise;
End;

procedure get_child_level(
p_level varchar2,
p_children out nocopy BSC_AW_ADAPTER_DIM.dim_parent_child_tb
) is
--
l_tab_ClsLevelRelationship bsc_dbgen_std_metadata.tab_ClsLevelRelationship;
Begin
  l_tab_ClsLevelRelationship:=bsc_dbgen_metadata_reader.get_children_for_level_aw(p_level,1);
  for i in 1..l_tab_ClsLevelRelationship.count loop
    p_children(i).parent_level:=l_tab_ClsLevelRelationship(i).parent_level;
    p_children(i).parent_pk:=l_tab_ClsLevelRelationship(i).parent_level_pk;
    p_children(i).child_level:=l_tab_ClsLevelRelationship(i).child_level;
    p_children(i).child_fk:=l_tab_ClsLevelRelationship(i).child_level_fk;
  end loop;
Exception when others then
  log_n('Exception in get_child_level '||sqlerrm);
  raise;
End;

/*
we have to hardcode VARCHAR2(200) for the levels. please note that in our implementation, dim
are TEXT. so when we create olap table function views, the datatype muct be varchar2
Assumptions
12/8/05 Talked to Patricia. Right now, there are no cases where we have a view based dimension that is not invoked through the loader.
We have two types of dimensions, existing source and BSC. For both these, dimension loader is invoked. The dimension loader will call
the AW kpi to refresh the aw implementation of the dimension. This is irrespective of whether the loader actually loaded any object
for the dimension or decided to do nothing since the dim is view based. The AW dimension refresh api is called in all cases.
The potential issue we have is when the loader is not invoked. Right  now, we assume there is no such case.
*/
procedure get_level_pk(
p_level varchar2,
p_level_id out nocopy number,
p_level_pk out nocopy varchar2,
p_level_pk_datatype out nocopy varchar2,
p_level_source out nocopy varchar2
) is
--
l_level BSC_DBGEN_STD_METADATA.clsLevel;
Begin
  l_level:=bsc_dbgen_metadata_reader.get_level_info(p_level);
  p_level_id:=l_level.level_id;
  p_level_pk:=l_level.level_pk;
  p_level_pk_datatype:=l_level.Level_PK_Datatype;--must be varchar2...
  --for now, we hardcode p_level_pk_datatype to varchar2
  p_level_pk_datatype:='VARCHAR2(200)';
  --need to populate p_level_source
  p_level_source:='table';
Exception when others then
  log_n('Exception in get_level_pk '||sqlerrm);
  raise;
End;

/*
given a set of levels, find out the kpi involved and the dim sets
returns kpi that  references any of the levels.(not necessarily all levels)
*/
procedure get_kpi_for_dim(
p_levels varchar2,
p_kpi out nocopy dbms_sql.varchar2_table,
p_dimset out nocopy dbms_sql.varchar2_table
) is
--
l_facts BSC_DBGEN_STD_METADATA.tab_clsFact;
l_levels dbms_sql.varchar2_table;
l_all_kpis dbms_sql.varchar2_table;
Begin
  l_levels(1):=p_levels;
  l_facts:=bsc_dbgen_metadata_reader.get_facts_for_levels(l_levels);
  --now, match these with the facts implemented in aw
  get_all_kpi_in_aw(l_all_kpis);
  for i in 1..l_facts.count loop
    if bsc_aw_utility.in_array(l_all_kpis,to_char(l_facts(i).fact_id)) then
      for j in 1..l_facts(i).dimension_set.count loop
        p_kpi(p_kpi.count+1):=l_facts(i).fact_id;
        p_dimset(p_dimset.count+1):=l_facts(i).dimension_set(j);
      end loop;
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_kpi_for_dim '||sqlerrm);
  raise;
End;

procedure get_dims_for_kpis(
p_kpi_list dbms_sql.varchar2_table,
p_dim_list out nocopy dbms_sql.varchar2_table
) is
--
l_dimensions dbms_sql.varchar2_table;
Begin
  for i in 1..p_kpi_list.count loop
    l_dimensions.delete;
    l_dimensions:=bsc_dbgen_metadata_reader.get_all_levels_for_fact(p_kpi_list(i));
    for j in 1..l_dimensions.count loop
      if bsc_aw_utility.in_array(p_dim_list,l_dimensions(j))=false then
        p_dim_list(p_dim_list.count+1):=l_dimensions(j);
      end if;
    end loop;
  end loop;
Exception when others then
  log_n('Exception in get_dims_for_kpis '||sqlerrm);
  raise;
End;

function is_dim_recursive(p_dim_level varchar2) return varchar2 is
--
l_flag boolean;
Begin
  l_flag:=bsc_dbgen_metadata_reader.is_dim_recursive(p_dim_level);
  if l_flag then
    return 'Y';
  else
    return 'N';
  end if;
Exception when others then
  log_n('Exception in is_dim_recursive '||sqlerrm);
  raise;
End;

/*
for DBI dim. read the static package

discussed with arun : 03/10/05
for now, we will call bsc_update_dim.Get_Dbi_Dim_Data

called only for NON REC dim
DBI dim are single level dim. we should modify this api to handle multi level dim
*/
procedure get_dim_data_source(
p_level_list dbms_sql.varchar2_table,
p_level_pk_col out nocopy dbms_sql.varchar2_table,
p_data_source out nocopy varchar2,
p_inc_data_source out nocopy varchar2
) is
--
l_level_short_name varchar2(100);
l_data_source BSC_UPDATE_DIM.t_dbi_dim_data;
l_code varchar2(100);
Begin
  for i in 1..p_level_list.count loop
    l_level_short_name:=get_level_short_name(p_level_list(i));
    bsc_update_dim.Get_Dbi_Dim_Data(l_level_short_name,l_data_source);
    if l_data_source.short_name is not null then
      --this is dbi dim
      l_code:='CODE';
      if l_data_source.code_col is not null then
        l_code:=l_data_source.code_col;
      end if;
      if l_data_source.table_name is not null and l_data_source.materialized='YES' then
        --code should be distinct in table
        p_data_source:='(select '||l_code||' from '||l_data_source.table_name||')';
        p_inc_data_source:='(select '||l_code||' from '||l_data_source.table_name||')';
      else
        p_data_source:='(select distinct '||l_code||' from '||l_data_source.from_clause||' '||l_data_source.where_clause||')';
        p_inc_data_source:='(select distinct '||l_code||' from '||l_data_source.from_clause||' '||l_data_source.where_clause||')';
      end if;
      p_level_pk_col(1):=l_code;
      exit;--assume single level dim
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_dim_data_source '||sqlerrm);
  raise;
End;

/*
for DBI recursive dim. read the static package
there is no p_denorm_inc_data_source. we always full refresh the rec dim. this does not mean kpi will need
full agg. dim load will figure out if there is hier change
p_position_col will be the column that holds the position of the dim value. larry will have 1, john wookey
2 etc. if there is no position col in the denorm table, set this column to "1"
*/
procedure get_denorm_data_source(
p_dim_level varchar2,
p_child_col out nocopy varchar2,
p_parent_col out nocopy varchar2,
p_position_col out nocopy varchar2,
p_denorm_data_source out nocopy varchar2,
p_denorm_change_data_source out nocopy varchar2
) is
--
l_level_short_name varchar2(100);
l_data_source BSC_UPDATE_DIM.t_dbi_dim_data;
l_value varchar2(100);
l_string varchar2(8000);
Begin
  l_level_short_name:=get_level_short_name(p_dim_level);
  bsc_update_dim.Get_Dbi_Dim_Data(l_level_short_name,l_data_source);
  if l_data_source.denorm_table is not null then
    p_child_col:=l_data_source.child_col;
    p_parent_col:=l_data_source.parent_col;
    p_position_col:=l_data_source.parent_level_col;
    p_denorm_data_source:='(select '||p_child_col||','||p_parent_col||' from '||l_data_source.denorm_table||')';
    p_denorm_change_data_source:='select child_value '||p_child_col||', parent_value '||p_parent_col||' from bsc_aw_rec_dim_hier_change ';
    /*4924532. we have to use literal binding here because this part of the stmt is coming inside aw dml load program */
    l_string:=p_denorm_change_data_source;
    l_string:=l_string||' whe';
    l_string:=l_string||'re ';
    l_value:='\'''||p_dim_level||'\''';
    l_string:=l_string||'dim_level='||l_value;
    p_denorm_change_data_source:='('||l_string||')';
  end if;
Exception when others then
  log_n('Exception in get_denorm_data_source '||sqlerrm);
  raise;
End;

procedure get_kpi_for_calendar(
p_calendar_id number,
p_kpi_list out nocopy dbms_sql.varchar2_table) is
--
l_kpi_list dbms_sql.number_table;
Begin
  l_kpi_list:=bsc_dbgen_metadata_reader.get_fact_ids_for_calendar(p_calendar_id);
  for i in 1..l_kpi_list.count loop
    p_kpi_list(i):=l_kpi_list(i);
  end loop;
Exception when others then
  log_n('Exception in get_kpi_for_calendar '||sqlerrm);
  raise;
End;

procedure get_kpi_calendar(
p_kpi varchar2,
p_calendar out nocopy number) is
Begin
  p_calendar:=bsc_dbgen_metadata_reader.get_calendar_id_for_fact(p_kpi);
Exception when others then
  log_n('Exception in get_kpi_calendar '||sqlerrm);
  raise;
End;

procedure get_kpi_dim_sets(
p_kpi varchar2,
p_dim_set out nocopy dbms_sql.varchar2_table
) is
--
l_dim_set dbms_sql.number_table;
Begin
  l_dim_set:=bsc_dbgen_metadata_reader.get_dim_sets_for_fact(p_kpi);
  for i in 1..l_dim_set.count loop
    p_dim_set(i):=l_dim_set(i);
  end loop;
Exception when others then
  log_n('Exception in get_kpi_dim_sets '||sqlerrm);
  raise;
End;

/*
this returns the level list in the lowest to the highest order
lowest levels come first. if the levels are
City State Country
Prod ProdCat ProdCatType
Day Month
then first three levels are
City, Prod, Day. others in any order
in api must get periodicity info also and have that in p_dim_level

p_mo_dim_group is used to see if a dim is standalone or part of a parent child hier
if city ,state and country are levels with parent child relation, p_mo_dim_group will be the same for the
3 levels. if they are standalone levels, then p_mo_dim_group will be diff for the 3. (Arun)
*/
procedure get_dim_set_dims(
p_kpi varchar2,
p_dim_set varchar2,
p_dim_level out nocopy dbms_sql.varchar2_table,
p_mo_dim_group out nocopy dbms_sql.varchar2_table,
p_skip_level out nocopy dbms_sql.varchar2_table
) is
--
l_dimension BSC_DBGEN_STD_METADATA.tab_clsDimension;
Begin
  /*
  discussed with arun. 03/22/05
  when calling get_dimensions_for_fact, call with missing levels=false. not true. if called with true, in the case where
  we have city and country as independent dim, MO will find state as missing level, group city,state and country into 1 dim
  we will not know if city and country are independent dim or are related. so call with false. hardcode skip level to N
  */
  l_dimension:=bsc_dbgen_metadata_reader.get_dimensions_for_fact(p_kpi,to_number(p_dim_set),false);
  --true is to include missing levels. so if the kpi has city and country, this api will also return state
  --loop through hierarchies, levels are inside hierarchies
  --there is only hier that arun is using. levels are in order of parent to child. so we reverse the order
  for i in 1..l_dimension.count loop
    for j in 1..l_dimension(i).Hierarchies.count loop
      for k in reverse 1..l_dimension(i).Hierarchies(j).Levels.count loop
        if bsc_aw_utility.in_array(p_dim_level,l_dimension(i).Hierarchies(j).Levels(k).level_name)=false then
          p_dim_level(p_dim_level.count+1):=l_dimension(i).Hierarchies(j).Levels(k).level_name;
          p_skip_level(p_skip_level.count+1):='N';--hardcoded since we call get_dimensions_for_fact with false
          p_mo_dim_group(p_mo_dim_group.count+1):=i;--dim name will be null. so use i
        end if;
      end loop;
    end loop;
  end loop;
Exception when others then
  log_n('Exception in get_dim_set_dims '||sqlerrm);
  raise;
End;

/*
populate
measure name
measure type  --normal or balance
formula
p_agg_formula should all caps
if p_measure is a BALANCE LAST VALUE colummn, p_property can contain the loaded Y or N column name
*/
procedure get_dim_set_measures(
p_kpi varchar2,
p_dim_set varchar2,
p_measure out nocopy dbms_sql.varchar2_table,
p_measure_type out nocopy dbms_sql.varchar2_table,
p_data_type out nocopy dbms_sql.varchar2_table,
p_agg_formula out nocopy dbms_sql.varchar2_table,
p_forecast out nocopy dbms_sql.varchar2_table,
p_property out nocopy dbms_sql.varchar2_table
) is
--
l_measures BSC_DBGEN_STD_METADATA.tab_clsMeasure;
l_projection varchar2(200); --"0" means no projection. else projection
l_type varchar2(100);
Begin
  l_measures:=bsc_dbgen_metadata_reader.Get_Measures_For_Fact(p_kpi,to_number(p_dim_set),true);
  --true means return kpi measures+calculated internal measures
  for i in 1..l_measures.count loop
    p_measure(i):=l_measures(i).Measure_Name;
    p_property(i):=null;
    l_type:=l_measures(i).Measure_Type;
    if l_type='2' then --2 is balance, 1 is normal
      p_measure_type(i):='BALANCE';
    else --Statistic
      p_measure_type(i):='NORMAL';
    end if;
    p_data_type(i):=l_measures(i).datatype;
    --aggregation_method will contain SUM AVG M1/M2
    --talked to arun. the formula will be in SOURCE_FORMULA. so if formula is not found then then look for agg method
    p_agg_formula(i):=bsc_dbgen_utils.get_property_value(l_measures(i).properties,BSC_DBGEN_STD_METADATA.SOURCE_FORMULA);
    if p_agg_formula(i)=BSC_DBGEN_STD_METADATA.BSC_PROPERTY_NOT_FOUND then
      p_agg_formula(i):=l_measures(i).aggregation_method;
    end if;
    if p_agg_formula(i)='AVG' then
      p_agg_formula(i):='AVERAGE';
    end if;
    l_projection:=bsc_dbgen_utils.get_property_value(l_measures(i).properties,BSC_DBGEN_STD_METADATA.PROJECTION_ID);
    if l_projection='0' then
      p_forecast(i):='N';
    else
      p_forecast(i):='Y';
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_dim_set_measures '||sqlerrm);
  raise;
End;

function is_target_at_higher_level(
p_kpi varchar2,
p_dim_set varchar2
) return varchar2 is
--
l_flag boolean;
Begin
  l_flag:=bsc_dbgen_metadata_reader.is_target_at_higher_level(p_kpi,p_dim_set);
  if l_flag then
    return 'Y';
  else
    return 'N';
  end if;
Exception when others then
  log_n('Exception in is_target_at_higher_level '||sqlerrm);
  raise;
End;

/*
here we only need the level name , compared with get_dim_set_dims. once we have the levels, we loop over the dimset dim
and find the level_r and assign it to the target dimset
*/
procedure get_target_levels(
p_kpi varchar2,
p_dim_set varchar2,
p_dim_level out nocopy dbms_sql.varchar2_table) is
--
l_dimension BSC_DBGEN_STD_METADATA.tab_clsDimension;
Begin
  l_dimension:=bsc_dbgen_metadata_reader.get_dimensions_for_fact(p_kpi,to_number(p_dim_set),false);
  for i in 1..l_dimension.count loop
    for j in 1..l_dimension(i).Hierarchies.count loop
      for k in reverse 1..l_dimension(i).Hierarchies(j).Levels.count loop
        if bsc_dbgen_utils.get_property_value(l_dimension(i).Hierarchies(j).Levels(k).properties,BSC_DBGEN_STD_METADATA.TARGET_LEVEL)='1' then
          if bsc_aw_utility.in_array(p_dim_level,l_dimension(i).Hierarchies(j).Levels(k).level_name)=false then
            p_dim_level(p_dim_level.count+1):=l_dimension(i).Hierarchies(j).Levels(k).level_name;
          end if;
        end if;
      end loop;
    end loop;
  end loop;
Exception when others then
  log_n('Exception in get_target_levels '||sqlerrm);
  raise;
End;

--targets and actuals have the same periodicity
--NO!!! targets can have diff periodicity
--get_target_periodicity will return ONLY THE LOWEST periodicities for targets
--qtr or month or maybe month+week
procedure get_target_periodicity(
p_kpi varchar2,
p_dim_set varchar2,
p_periodicities out nocopy dbms_sql.number_table
) is
--
l_periodicity BSC_DBGEN_STD_METADATA.tab_ClsPeriodicity;
l_flag boolean;
Begin
  l_periodicity:=bsc_dbgen_metadata_reader.Get_Periodicities_For_Fact(p_kpi);
  for i in 1..l_periodicity.count loop
    --MO will give back all levels with targets. we need to scan and eliminate all periodicities that are not lowest
    if bsc_dbgen_utils.get_property_value(l_periodicity(i).properties,BSC_DBGEN_STD_METADATA.TARGET_LEVEL)='1' then
      --if l_periodicity(i).Parent_periods.count=0 then --this is the lowest level
      --make sure this is the lowest
      l_flag:=false;
      --say year and qtr show up. for year, qtr is a src. so qtr will show up as a parent period of year
      for j in 1..l_periodicity.count loop
        if bsc_dbgen_utils.get_property_value(l_periodicity(j).properties,BSC_DBGEN_STD_METADATA.TARGET_LEVEL)='1' then
          if bsc_aw_utility.in_array(l_periodicity(i).Parent_periods,to_char(l_periodicity(j).Periodicity_id)) then
            l_flag:=true;
            exit;
          end if;
        end if;
      end loop;
      if l_flag=false then
        p_periodicities(p_periodicities.count+1):=l_periodicity(i).Periodicity_id;
      end if;
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_target_periodicity '||sqlerrm);
  raise;
End;

procedure get_dim_level_properties(
p_level varchar2,
p_pk out nocopy varchar2,
p_fk out nocopy varchar2,
p_datatype out nocopy varchar2,
p_level_source out nocopy varchar2) is
--
l_level_id number;
l_level BSC_DBGEN_STD_METADATA.clsLevel;
Begin
  get_level_pk(p_level,l_level_id,p_pk,p_datatype,p_level_source);
  l_level:=bsc_dbgen_metadata_reader.get_level_info(p_level);
  p_fk:=l_level.LEVEL_FK;
Exception when others then
  log_n('Exception in get_dim_level_properties '||sqlerrm);
  raise;
End;

/*
given a kpi and the dim level, get the filter
*/
procedure get_dim_level_filter(
p_kpi varchar2,
p_level varchar2,
p_filter out nocopy dbms_sql.varchar2_table) is
--
l_filter varchar2(32000);
Begin
  l_filter:=bsc_dbgen_metadata_reader.get_filter_for_dim_level(p_kpi,p_level);
  bsc_aw_utility.convert_varchar2_to_table(l_filter,3800,p_filter);
Exception when others then
  log_n('Exception in get_dim_level_filter '||sqlerrm);
  raise;
End;

procedure get_s_views(
p_kpi varchar2,
p_dim_set varchar2,
p_s_views out nocopy dbms_sql.varchar2_table) is
Begin
  p_s_views:=bsc_dbgen_metadata_reader.get_s_views(p_kpi,to_number(p_dim_set));
Exception when others then
  log_n('Exception in get_s_views '||sqlerrm);
  raise;
End;

--get the z mvs
procedure get_z_s_views(
p_kpi varchar2,
p_dim_set varchar2,
p_s_views out nocopy dbms_sql.varchar2_table) is
Begin
  --zero code mv
  p_s_views:=bsc_dbgen_metadata_reader.get_z_s_views(p_kpi,to_number(p_dim_set));
Exception when others then
  log_n('Exception in get_s_views '||sqlerrm);
  raise;
End;

procedure get_s_view_levels(
p_s_view varchar2,
p_levels out nocopy dbms_sql.varchar2_table) is
--
l_levels BSC_DBGEN_STD_METADATA.tab_clsLevel;
Begin
  l_levels:=bsc_dbgen_metadata_reader.get_levels_for_table(p_s_view);
  for i in 1..l_levels.count loop
    p_levels(i):=l_levels(i).Level_Name;
  end loop;
Exception when others then
  log_n('Exception in get_s_view_levels '||sqlerrm);
  raise;
End;

/*
return all the levels of the base table. the dim set may have 5 levels. the base table may have 10. we
are not interested in the 5 keys not in the dim set. but we need to know that we have 10 keys in the base table so we can aggregate
p_bt_level_fks contains the column from the base table to this level. , like BUG_COMPO_CODE, RELEASEF_CODE etc
SQL> desc bsc_b_406_aw
 Name                            Null?    Type
 ------------------------------- -------- ----
 BUG_COMPO_CODE                           VARCHAR2(40)
 RELEASEF_CODE                            VARCHAR2(40)
 BUG_PRIOR_CODE                           VARCHAR2(40)
 BUG_ASSIG_CODE                           VARCHAR2(40)
 YEAR                            NOT NULL NUMBER(5)
 TYPE                                     VARCHAR2(40)
 PERIOD                          NOT NULL NUMBER(5)
 BUGOPEN                                  NUMBER
p_bt_level_pks contain the level pk like CODE
*/
procedure get_base_table_levels(
p_kpi varchar2,
p_dim_set varchar2,
p_base_table varchar2,
p_bt_levels out nocopy dbms_sql.varchar2_table,
p_bt_level_fks out nocopy dbms_sql.varchar2_table,
p_bt_level_pks out nocopy dbms_sql.varchar2_table,
p_bt_feed_level out nocopy dbms_sql.varchar2_table
) is
--
l_levels BSC_DBGEN_STD_METADATA.tab_clsLevel;
l_map BSC_DBGEN_STD_METADATA.tab_clsColumnMaps;
Begin
  l_levels:=bsc_dbgen_metadata_reader.get_levels_for_table(p_base_table);
  for i in 1..l_levels.count loop
    p_bt_levels(i):=l_levels(i).level_name;
    p_bt_level_fks(i):=l_levels(i).LEVEL_FK;
    p_bt_level_pks(i):=l_levels(i).Level_PK;
    p_bt_feed_level(i):='N';
  end loop;
  l_map:=bsc_dbgen_metadata_reader.get_fact_cols_from_b_table(p_kpi,to_number(p_dim_set),p_base_table,'KEYS');
  for i in 1..p_bt_levels.count loop
    for j in 1..l_map.count loop
      if p_bt_level_fks(i)=l_map(j).source_column_name then
        p_bt_feed_level(i):='Y';
        exit;
      end if;
    end loop;
  end loop;
Exception when others then
  log_n('Exception in get_base_table_levels '||sqlerrm);
  raise;
End;

/*
get the measures relevant to the dim set and mapped from this base table
*/
procedure get_base_table_measures(
p_kpi varchar2,
p_dim_set varchar2,
p_base_table varchar2,
p_measures out nocopy dbms_sql.varchar2_table,
p_bt_formula out nocopy dbms_sql.varchar2_table) is
--
l_measures BSC_DBGEN_STD_METADATA.tab_clsMeasure;
Begin
  l_measures:=bsc_dbgen_metadata_reader.get_b_table_measures_for_fact(p_kpi,p_dim_set,p_base_table,true);
  for i in 1..l_measures.count loop
    p_measures(i):=l_measures(i).Measure_Name;
    p_bt_formula(i):=bsc_dbgen_utils.get_property_value(l_measures(i).properties,BSC_DBGEN_STD_METADATA.SOURCE_FORMULA);
  end loop;
Exception when others then
  log_n('Exception in get_base_table_measures '||sqlerrm);
  raise;
End;

/*
for a kpi, get the calendar info and the periodicity info.
we assume here that periodicities are not missing!!!! make sure the optimizer api gives without missing periodicity
assume that the lowest periodicity is first element in the array!!
*/
procedure get_kpi_periodicities(
p_kpi varchar2,
p_dim_set varchar2,
p_periodicity out nocopy dbms_sql.number_table
) is
--
l_periodicity BSC_DBGEN_STD_METADATA.tab_ClsPeriodicity;
Begin
  l_periodicity:=bsc_dbgen_metadata_reader.Get_Periodicities_For_Fact(p_kpi);
  for i in 1..l_periodicity.count loop
    p_periodicity(i):=l_periodicity(i).Periodicity_id;
  end loop;
Exception when others then
  log_n('Exception in get_kpi_periodicities '||sqlerrm);
  raise;
End;

procedure get_base_table_periodicity(
p_base_table varchar2,
p_periodicity out nocopy number) is
Begin
  p_periodicity:=bsc_dbgen_metadata_reader.get_periodicity_for_table(p_base_table);
Exception when others then
  log_n('Exception in get_base_table_periodicity '||sqlerrm);
  raise;
End;

procedure get_base_table_properties(
p_base_table varchar2,
p_prj_table out nocopy varchar2,
p_partition out nocopy bsc_aw_utility.object_partition_r) is
--
l_partition_info BSC_DBGEN_STD_METADATA.clsTablePartition;
Begin
  p_prj_table:=BSC_DBGEN_METADATA_READER.get_table_properties(p_base_table,BSC_DBGEN_STD_METADATA.BSC_B_PRJ_TABLE);
  l_partition_info:=BSC_DBGEN_METADATA_READER.get_partition_info(p_base_table);
  if l_partition_info.table_name is not null then
    p_partition.main_partition.set_name:='main partition';
    p_partition.main_partition.partition_type:=l_partition_info.partitioning_type;--HASH, RANGE, LIST
    p_partition.main_partition.partition_column:=l_partition_info.partitioning_column;
    p_partition.main_partition.partition_column_data_type:=l_partition_info.partitioning_column_datatype;
    for i in 1..l_partition_info.partition_info.count loop
      p_partition.main_partition.partitions(i).partition_name:=l_partition_info.partition_info(i).partition_name;
      p_partition.main_partition.partitions(i).partition_value:=l_partition_info.partition_info(i).partition_value;
      p_partition.main_partition.partitions(i).partition_position:=l_partition_info.partition_info(i).partition_position;
    end loop;
  end if;
Exception when others then
  log_n('Exception in get_base_table_properties '||sqlerrm);
  raise;
End;

/*
given a calendar and periodicity, get the column name from bsc_db_calendar
*/
function get_db_calendar_column(
p_calendar number,
p_periodicity number) return varchar2 is
Begin
  return bsc_dbgen_metadata_reader.get_db_calendar_column(p_calendar,p_periodicity);
Exception when others then
  log_n('Exception in get_db_calendar_column '||sqlerrm);
  raise;
End;

procedure get_zero_code_levels(
p_kpi varchar2,
p_dim_set varchar2,
p_levels out nocopy dbms_sql.varchar2_table) is
--
l_levels BSC_DBGEN_STD_METADATA.tab_clsLevel;
Begin
  l_levels:=bsc_dbgen_metadata_reader.get_zero_code_levels(p_kpi,p_dim_set);
  for i in 1..l_levels.count loop
    p_levels(i):=l_levels(i).level_name;
  end loop;
Exception when others then
  log_n('Exception in get_zero_code_levels '||sqlerrm);
  raise;
End;

procedure get_dim_set_base_tables(
p_kpi varchar2,
p_dim_set varchar2,
p_base_tables out nocopy dbms_sql.varchar2_table) is
Begin
  p_base_tables:=bsc_dbgen_metadata_reader.get_base_tables_for_dim_set(p_kpi,p_dim_set,false);--false is for "p_targets in boolean"
Exception when others then
  log_n('Exception in get_dim_set_base_tables '||sqlerrm);
  raise;
End;

procedure get_dim_set_target_base_tables(
p_kpi varchar2,
p_dim_set varchar2,
p_base_tables out nocopy dbms_sql.varchar2_table) is
Begin
  p_base_tables:=bsc_dbgen_metadata_reader.get_base_tables_for_dim_set(p_kpi,p_dim_set,true);--true is for "p_targets in boolean"
Exception when others then
  log_n('Exception in get_dim_set_target_base_tables '||sqlerrm);
  raise;
End;

/*
this procedure gives the period in which there is a mix of forecast and real data
we need the following
kpi and periodicity : we use this to hit bsc_db_tables that will indicate the current period
*/
procedure get_kpi_current_period(
p_kpi varchar2,
p_periodicity number,
p_period out nocopy number,
p_year out nocopy number
) is
Begin
  --bsc_dbgen_metadata_reader.get_current_period_for_fact also takes care of missing periodicities
  p_period:=bsc_dbgen_metadata_reader.get_current_period_for_fact(p_kpi,p_periodicity);
  p_year:=bsc_dbgen_metadata_reader.get_current_year_for_fact(p_kpi);
Exception when others then
  log_n('Exception in get_kpi_current_period '||sqlerrm);
  raise;
End;

/*
returns all the kpi that have been implemented in AW
*/
procedure get_all_kpi_in_aw(p_kpi_list out nocopy dbms_sql.varchar2_table) is
Begin
  p_kpi_list:=bsc_dbgen_metadata_reader.get_all_facts_in_aw;
Exception when others then
  log_n('Exception in get_all_kpi_in_aw '||sqlerrm);
  raise;
End;

/*
given the level table name get the level short name
*/
function get_level_short_name(p_level_table_name varchar2) return varchar2 is
Begin
  return bsc_dbgen_metadata_reader.get_dimension_level_short_name(p_level_table_name);
Exception when others then
  log_n('Exception in get_level_short_name '||sqlerrm);
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
  p_measure_name:=BSC_DBGEN_METADATA_READER.get_measures_for_short_names(p_short_name);
Exception when others then
  log_n('Exception in get_measures_for_short_names '||sqlerrm);
  raise;
End;

procedure get_dim_levels_for_short_names(
p_short_name dbms_sql.varchar2_table,
p_dim_level_name out nocopy dbms_sql.varchar2_table
) is
Begin
  p_dim_level_name:=BSC_DBGEN_METADATA_READER.get_dim_levels_for_short_names(p_short_name);
Exception when others then
  log_n('Exception in get_dim_levels_for_short_names '||sqlerrm);
  raise;
End;

function is_level_used_by_aw_kpi(p_level varchar2) return boolean is
Begin
  return BSC_DBGEN_METADATA_READER.is_level_used_by_aw_fact(p_level);
Exception when others then
  log_n('Exception in is_level_used_by_aw_kpi '||sqlerrm);
  raise;
End;

procedure get_B_table_feed_periodicity(p_kpi varchar2,p_dim_set varchar2,p_base_table varchar2,p_feed_periodicity out nocopy dbms_sql.number_table) is
l_periodicity dbms_sql.varchar2_table;
Begin
  l_periodicity:=BSC_DBGEN_METADATA_READER.get_target_per_for_b_table(p_kpi,to_number(p_dim_set),p_base_table);
  for i in 1..l_periodicity.count loop
    p_feed_periodicity(i):=to_number(l_periodicity(i));
  end loop;
Exception when others then
  log_n('Exception in get_B_table_feed_periodicity '||sqlerrm);
  raise;
End;

function get_kpi_LUD(p_kpi varchar2) return date is
Begin
  return BSC_DBGEN_METADATA_READER.get_last_update_date_for_fact(p_kpi);
Exception when others then
  log_n('Exception in get_kpi_LUD '||sqlerrm);
  raise;
End;

procedure get_table_current_period(p_table varchar2,p_period out nocopy number,p_year out nocopy number) is
Begin
  p_period:=bsc_dbgen_metadata_reader.get_current_period_for_table(p_table);
  p_year:=bsc_dbgen_metadata_reader.get_current_year_for_table(p_table);
Exception when others then
  log_n('Exception in get_table_current_period '||sqlerrm);
  raise;
End;

------------------------------
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

END BSC_METADATA;

/
