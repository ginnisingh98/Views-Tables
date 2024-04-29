--------------------------------------------------------
--  DDL for Package Body BSC_DBGEN_METADATA_READER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_DBGEN_METADATA_READER" AS
/* $Header: BSCMDRDB.pls 120.13 2006/01/12 13:58:22 arsantha noship $ */

g_metadata_source VARCHAR2(100) := 'BSC';

-- PUBLIC APIs
PROCEDURE Initialize(p_metadata_source IN VARCHAR2) IS
BEGIN
  g_metadata_source  := p_metadata_source;
END;

FUNCTION Get_Fact_Source(p_fact_id IN NUMBER) RETURN VARCHAR2 IS
/*CURSOR cSource IS
select source from BSC_DB_FACT_KPI_MAPS
where indicator= p_fact_id;*/
l_source VARCHAR2(1000);
BEGIN
/* OPEN cSource;
 FETCH cSource INTO l_source;
 CLOSE cSource;
 RETURN l_source;*/
 return 'BSC';
END;

FUNCTION Get_Fact_Name(p_fact_id IN NUMBER) RETURN VARCHAR2 IS

/*CURSOR cSource IS
select object_name from BSC_DB_FACT_KPI_MAPS
where indicator= p_fact_id;*/
CURSOR cSource IS
select name from bsc_kpis_vl
where indicator= p_fact_id;
l_name VARCHAR2(1000);
BEGIN
 OPEN cSource;
 FETCH cSource INTO l_name;
 CLOSE cSource;
 RETURN l_name;
END;

PROCEDURE Get_Info_For_Fact_ID(p_fact_id IN NUMBER, p_fact OUT NOCOPY VARCHAR2,
 p_fact_Type OUT NOCOPY VARCHAR2, p_fact_source OUT NOCOPY VARCHAR2) IS

/*CURSOR cFact IS
select object_name, object_type, source from BSC_DB_FACT_KPI_MAPS
where indicator= p_fact_id;
*/
CURSOR cSource IS
select name, 1, 'BSC' from BSC_KPIS_VL
where indicator= p_fact_id;
BEGIN
 OPEN cSource;
 FETCH cSource INTO p_fact, p_fact_type, p_fact_source;
 CLOSE cSource;
END;

-- Get the list of facts

FUNCTION Get_Facts_To_Process(p_process_id IN NUMBER) return BSC_DBGEN_STD_METADATA.tab_clsFact IS


l_facts BSC_DBGEN_STD_METADATA.tab_clsFact ;
l_fact_tmp BSC_DBGEN_STD_METADATA.tab_clsFact ;
BEGIN

  l_facts := BSC_DBGEN_BSC_READER.Get_Facts_To_Process(p_process_id);
  --l_fact_tmp := BSC_DB_AK_READER.Get_Facts_To_Process(p_process_id);
  FOR i IN l_fact_tmp.first..l_fact_tmp.last LOOP
    l_facts(l_facts.count) := l_fact_tmp(i);
  END LOOP;
  commit;
  return l_facts;
END;


FUNCTION Get_Measures_For_Fact(p_fact IN VARCHAR2, p_dim_set IN NUMBER, p_include_derived_columns IN BOOLEAN default false) return BSC_DBGEN_STD_METADATA.tab_clsMeasure IS
BEGIN
  --IF (g_metadata_source = BSC_DBGEN_STD_METADATA.BSC) THEN
  return BSC_DBGEN_BSC_READER.Get_Measures_For_Fact(p_fact, p_dim_set, p_include_derived_columns);
  --ELSE
   -- return BSC_DB_AK_READER.Get_Measures_For_Fact(p_fact, p_dim_set);
 -- END IF;

  EXCEPTION WHEN OTHERS THEN
  raise;

END;


--****************************************************************************
--Get_Periodicities_For_Fact
--  DESCRIPTION:
--   Get the collection of periodicity codes of the indicator
--  PARAMETERS:
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************

FUNCTION Get_Periodicities_For_Fact(p_fact IN VARCHAR2) RETURN BSC_DBGEN_STD_METADATA.tab_ClsPeriodicity IS


BEGIN

  -- IF (g_metadata_source = BSC_DBGEN_STD_METADATA.BSC) THEN
    return BSC_DBGEN_BSC_READER.Get_Periodicities_For_Fact(p_fact);
  --ELSE
    --return BSC_DB_AK_READER.Get_Periodicities_For_Fact(p_fact);
  --END IF;

  EXCEPTION WHEN OTHERS THEN
  BSC_MO_HELPER_PKG.TerminateWithError('BSC_RETR_KPI_PERIOD_FAILED');
  fnd_message.set_name('BSC', 'BSC_RETR_KPI_PERIOD_FAILED');
	fnd_message.set_token('INDICATOR', p_fact);
  app_exception.raise_exception;
End;

--****************************************************************************
--
--
--  DESCRIPTION:
--   Get the collection of levels for the indicator
--
--  PARAMETERS:
--   p_fact: indicator code
--   p_dim_set: p_dim_set
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
Function get_dimensions_for_fact(p_fact IN VARCHAR2, p_dim_set IN NUMBER, p_include_missing_levels IN BOOLEAN default false)
RETURN BSC_DBGEN_STD_METADATA.tab_clsDimension IS


BEGIN

   --IF (g_metadata_source = BSC_DBGEN_STD_METADATA.BSC) THEN
    return BSC_DBGEN_BSC_READER.get_dimensions_for_fact(p_fact, p_dim_set, p_include_missing_levels);
  --ELSE
    --return BSC_DB_AK_READER.get_dimensions_for_fact(p_fact, p_dim_set);
  --END IF;
  EXCEPTION WHEN OTHERS THEN
    fnd_message.set_name('BSC', 'BSC_RETR_DIM_KPI_FAILED');
    fnd_message.set_token('INDICATOR', p_fact);
    fnd_message.set_token('DIMENSION_SET', p_dim_set);
    app_exception.raise_exception;
    raise;
END;

	/*
	GetLevelsForDimension: Return the levels associated with a dimension
	GetHierarchiesForDimension: Return the hierarchies associated with a dimension
	GetLevelRelationships: Return the level and hierarchy information for a specified dimension
    GetObjectProperty: Return the value of a property for a given object

	GetSummaryTablesForFact: Return the tables created by the database generator for the fact
	GetBaseTablesFor: Return the base tables created by the database generator for the fact
	GetInputTablesFact: Return the base tables created by the database generator for the fact
	GetDimensionTablesFact: Return the base tables created by the database generator for the fact
	GetPropertiesForTable: Return the list of properties for a given table
	GetPropertyValueForTable: Return the property value for a given table and property code
	GetColumnsForTable: Return the list of columns for a given table
	GetPropertiesForColumn: Return the list of properties for a given table and column
	*/

-- Public APIs needed by AW module
/* requested signature
procedure get_parent_level(
p_level varchar2,
p_parents out nocopy BSC_AW_ADAPTER_DIM.dim_parent_child_tb
) is */
function get_parents_for_level(
  p_level_name varchar2,
  p_num_levels number default 1000000
) RETURN BSC_DBGEN_STD_METADATA.tab_ClsLevelRelationship is


Begin
 return BSC_DBGEN_BSC_READER.get_parents_for_level(p_level_name, p_num_levels);
 Exception when others then
 raise;
End;

/* Requested Signature
procedure get_child_level(
p_level varchar2,
p_children out nocopy BSC_AW_ADAPTER_DIM.dim_parent_child_tb
) is */
function get_children_for_level(
  p_level_name varchar2,
  p_num_levels number default 1000000
) RETURN BSC_DBGEN_STD_METADATA.tab_ClsLevelRelationship is


Begin
 return BSC_DBGEN_BSC_READER.get_children_for_level(p_level_name, p_num_levels);
 Exception when others then
 raise;
End;


/*
we have to hardcode VARCHAR2(200) for the levels. please note that in our implementation, dim
are TEXT. so when we create olap table function views, the datatype muct be varchar2
*/
/* Requested Signature
procedure get_level_pk(
p_level varchar2,
p_level_id out nocopy number,
p_level_pk out nocopy varchar2,
p_level_pk_datatype out nocopy varchar2*/

-- note that this will populate only the following attributes
-- level_id, level_pk, level_pk_datatype
function get_level_info(
p_level varchar2
) return BSC_DBGEN_STD_METADATA.clsLevel is


l_level BSC_DBGEN_STD_METADATA.clsLevel ;

Begin
  return BSC_DBGEN_BSC_READER.get_level_info(p_level);
  Exception when others then
    raise;
End;

/*
given a set of levels, find out the kpi/dimset which has ANY of the levels specified
*/
/* Requested Signature
procedure get_kpi_for_dim(
p_levels dbms_sql.varchar2_table,
p_kpi out nocopy bsc_aw_adapter_dim.kpi_for_dim_tb) */
function get_facts_for_levels(p_levels dbms_sql.varchar2_table) return BSC_DBGEN_STD_METADATA.tab_clsFact is


  l_facts BSC_DBGEN_STD_METADATA.tab_clsFact ;
  l_fact_tmp BSC_DBGEN_STD_METADATA.tab_clsFact;
Begin
  l_facts := BSC_DBGEN_BSC_READER.get_facts_for_levels(p_levels);
  --dbms_output.put_line('Chk1');
  --l_fact_tmp := BSC_DB_AK_READER.get_kpis_for_levels;
  /*FOR i IN l_fact_tmp.first..l_fact_tmp.last LOOP
    l_facts(l_facts.count) := l_fact_tmp(i);
  END LOOP;*/
  return l_facts;
Exception when others then
 raise;
End;
/* Requested Signature
procedure get_dims_for_kpis(
p_kpi_list dbms_sql.varchar2_table,
p_dim_list out nocopy dbms_sql.varchar2_table)*/
-- use existing api

/* Requested  signature function is_dim_recursive(p_dim_level varchar2) return varchar2 is */
function is_dim_recursive(p_dim_level varchar2) return boolean is
l_dim_list bsc_varchar2_table_type;
l_num_dim_list number := 0;
l_error varchar2(1000);
l_count number;
cursor cRec is
select count(1) from bsc_sys_dim_level_rels
where dim_level_id=parent_dim_level_id
and dim_level_id in (select dim_level_id from bsc_sys_dim_levels_b where level_table_name=p_dim_level);
BEGIN
  bsc_olap_main.get_list_of_rec_dim(gRecDims, l_num_dim_list, l_error);
  FOR i IN gRecDims.first..gRecDims.last LOOP
    IF (p_dim_level = gRecDims(i)) THEN
      return true;
    END IF;
  END LOOP;
  open cRec;
  fetch cRec into l_count;
  close cRec;
  if (l_count>0) then
    return true;
  end if;
  return false;
Exception when others then
 raise;
End;

/*
for DBI dim. read the static package
*/
-- Venu asked me to ignore this - 31 Jan 2005
/*
procedure get_dim_data_source(
p_level_list dbms_sql.varchar2_table,
p_level_pk_col out nocopy dbms_sql.varchar2_table,
p_data_source out nocopy varchar2,
p_inc_data_source out nocopy varchar2
) is
Begin
 if p_level_list(1)='HRI_PER' then
   p_level_pk_col(1):='CODE';
   p_data_source:='(select code from hri_table)';
   p_inc_data_source:='(select code from hri_table)';
 end if;
Exception when others then
 write_to_log_file_n('Error in get_dim_data_source '||sqlerrm);
 raise;
End;
*/
/*
for DBI recursive dim. read the static package
there is no p_denorm_inc_data_source. we always full refresh the rec dim. this does not mean kpi will need
full agg. dim load will figure out if there is hier change
*/
-- Venu asked me to ignore this - 31 Jan 2005
/*procedure get_denorm_data_source(
p_dim_level varchar2,
p_child_col out nocopy varchar2,
p_parent_col out nocopy varchar2,
p_denorm_data_source out nocopy varchar2,
p_denorm_change_data_source out nocopy varchar2
) is
Begin
 if p_dim_level='HRI_PER' then
   p_child_col:='employee';
   p_parent_col:='manager';
   p_denorm_data_source:='(select employee, manager from hri_denorm_table)';
   p_denorm_change_data_source:='(select employee, manager from hri_denorm_change_table)';
 end if;
Exception when others then
 write_to_log_file_n('Error in get_denorm_data_source '||sqlerrm);
 raise;
End;*/

/* requested signature
procedure get_kpi_for_calendar(
p_calendar_id number,
p_kpi_list out nocopy dbms_sql.varchar2_table) is
*/
function get_fact_ids_for_calendar(
p_calendar_id number) return dbms_sql.number_table
is


cursor cCalendars IS
select kpi.indicator from bsc_kpi_periodicities kpi,
bsc_sys_periodicities sysper
where kpi.periodicity_id = sysper.periodicity_id
and sysper.calendar_id= p_calendar_id;
l_fact_ids dbms_sql.number_table;
l_fact_id number;
Begin
  OPEN cCalendars;
  LOOP
    FETCH cCalendars INTO l_fact_id;
    EXIT WHEN cCalendars%NOTFOUND;
    l_fact_ids(l_fact_ids.count+1) := l_fact_id;
  END LOOP;
  CLOSE cCalendars;
  return l_fact_ids;
Exception when others then
 raise;
End;
/*Req signature


procedure get_kpi_calendar(
p_kpi varchar2,
p_calendar out nocopy number) is */

function get_calendar_id_for_fact(
p_fact IN VARCHAR2) return number is


l_calendar_id NUMBER;
cursor cCal is
SELECT calendar_id
FROM bsc_sys_periodicities sysper,
bsc_kpi_periodicities kpi
where kpi.periodicity_id = sysper.periodicity_id
and kpi.indicator = to_number(p_fact);
Begin
  OPEN cCal;
  FETCH cCal INTO l_calendar_id;
  CLOSE cCal;
  return l_calendar_id;

  Exception when others then
    raise;
End;
/*Req signature
procedure get_kpi_dim_sets(
p_kpi varchar2,
p_dim_set out nocopy dbms_sql.varchar2_table
*/

function get_dim_sets_for_fact(
p_fact varchar2
) return dbms_sql.number_table
 is


 l_dim_sets dbms_sql.number_table;
Begin
 --IF get_fact_source(to_number(p_kpi)) = BSC_DBGEN_STD_METADATA.BSC THEN
   l_dim_sets := BSC_DBGEN_BSC_READER.get_dim_sets_for_fact(to_number(p_fact));
 --ELSE   -- AK report
   --l_dim_sets(1) := 0;
 --END IF;
 return l_dim_sets;
Exception when others then
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
*/

/*Requested Signature
procedure get_dim_set_dims(
p_kpi varchar2,
p_dim_set varchar2,
p_dim_level out nocopy dbms_sql.varchar2_table)*/

-- use get_dimensions_for_fact

/*
populate
measure name
measure type  --normal or balance
formula
*/
/*procedure get_dim_set_measures(
p_kpi varchar2,
p_dim_set varchar2,
p_measure out nocopy dbms_sql.varchar2_table,
p_measure_type out nocopy dbms_sql.varchar2_table,
p_data_type out nocopy dbms_sql.varchar2_table,
p_agg_formula out nocopy dbms_sql.varchar2_table)
Use get_measures_for_fact
*/

/* Requested
function is_target_at_higher_level(
p_kpi varchar2,
p_dim_set varchar2) return varchar2 is */

function is_target_at_higher_level(
p_fact varchar2,
p_dim_set varchar2) return boolean is


Begin
  IF bsc_dbgen_utils.get_kpi_property_value(p_fact, 'DB_TRANSFORM', 1) <> 2 THEN
    return false;
  ELSE
    return true;
  END IF;
Exception when others then
 raise;
End;

/*
for now, we dont support forecast in AW
*/
/* ignored
function is_forecast_implemented(
p_kpi varchar2,
p_dim_set varchar2) return varchar2 is
Begin
 return 'N';
Exception when others then
 write_to_log_file_n('Error in is_forecast_implemented '||sqlerrm);
 raise;
End;
*/

/* Reuse get levels for fact API and check target_level property to be 1
procedure get_target_levels(
p_kpi varchar2,
p_dim_set varchar2,
p_levels out nocopy dbms_sql.varchar2_table) is
Begin
 if p_kpi='3014' then
   return;
 end if;
Exception when others then
 write_to_log_file_n('Error in get_target_levels '||sqlerrm);
 raise;
End;
*/

/* Reuse get_level_info API
procedure get_dim_level_properties(
p_level varchar2,
p_pk out nocopy varchar2,
p_fk out nocopy varchar2,
p_datatype out nocopy varchar2) is
--
l_level_id number;
Begin
 get_level_pk(p_level,l_level_id,p_pk,p_datatype);
 if p_level='BSC_D_BUG_COMPONENTS' then
   p_fk:='COMPO_CODE';
 elsif p_level='BSC_D_BUG_PRODUCTS' then
   p_fk:='PROD_CODE';
 elsif p_level='BSC_D_PRODUCT_FAMILY' then
   p_fk:='FAMILY_CODE';
 elsif p_level='BSC_D_MANAGER' then
   p_fk:='MANAGER_CODE';
 end if;
 if p_level='HRI_PER' then
   p_fk:='PER_CODE';
 end if;
Exception when others then
 write_to_log_file_n('Error in get_dim_level_properties '||sqlerrm);
 raise;
End;
*/

/*
given a kpi and the dim level, get the filter
Req sig
procedure get_dim_level_filter(
p_kpi varchar2,
p_level varchar2,
p_filter out nocopy dbms_sql.varchar2_table) is*/
function get_filter_for_dim_level(
p_fact varchar2,
p_level varchar2) return varchar2 is


Begin
 return BSC_DBGEN_BSC_READER.get_filter_for_dim_level(p_fact, p_level);
Exception when others then
 raise;
End;


/*Requested Signature
procedure get_s_views(
p_fact varchar2,
p_dim_set varchar2,
p_s_views out nocopy dbms_sql.varchar2_table) is*/
function get_s_views(
p_fact IN VARCHAR2,
p_dim_set IN NUMBER)
return dbms_sql.varchar2_table is


Begin
 return BSC_DBGEN_BSC_READER.get_s_views(p_fact, p_dim_set);
Exception when others then
	 raise;
End;

/* Req sig
procedure get_s_view_levels(
p_s_view varchar2,
p_levels out nocopy dbms_sql.varchar2_table) is
Use following api */

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
Req sig
procedure get_base_table_levels(
p_fact varchar2,
p_dim_set varchar2,
p_base_table varchar2,
p_bt_levels out nocopy dbms_sql.varchar2_table,
p_bt_level_fks out nocopy dbms_sql.varchar2_table,
p_bt_level_pks out nocopy dbms_sql.varchar2_table
) is*/
function get_levels_for_table(
p_table_name varchar2
) return BSC_DBGEN_STD_METADATA.tab_clsLevel is


 l_table_type VARCHAR2(100):='TABLE';
Begin
 IF (p_table_name like 'BSC%MV') THEN
   l_table_type := 'MV';
 END IF;
 return BSC_DBGEN_BSC_READER.get_levels_for_table(p_table_name, l_table_type);
Exception when others then
 raise;
End;

/*
get the measures relevant to the dim set and mapped from this base table
Req sig
procedure get_base_table_measures(
p_fact varchar2,
p_dim_set varchar2,
p_base_table varchar2,
p_measures out nocopy dbms_sql.varchar2_table,
p_bt_formula out nocopy dbms_sql.varchar2_table) */

function get_b_table_measures_for_fact(
p_fact varchar2,
p_dim_set varchar2,
p_base_table varchar2,
p_include_derived_columns boolean )
return BSC_DBGEN_STD_METADATA.tab_clsMeasure IS


Begin
  return BSC_DBGEN_BSC_READER.get_b_table_measures_for_fact(p_fact, p_dim_set, p_base_table, p_include_derived_columns);
Exception when others then
 raise;
End;

/*
for a kpi, get the calendar info and the periodicity info.
we assume here that periodicities are not missing!!!! make sure the optimizer api gives without missing periodicity
assume that the lowest periodicity is first element in the array!!
*/

/* Use get_periodicities_for_fact */
/*
procedure get_kpi_periodicities(
p_kpi varchar2,
p_dim_set varchar2,
p_periodicity out nocopy dbms_sql.number_table
) is
Begin
 if p_kpi='3014' then
   p_periodicity(1):=9;
   p_periodicity(2):=5;
   p_periodicity(3):=3;
 end if;
Exception when others then
 write_to_log_file_n('Error in get_kpi_periodicities '||sqlerrm);
 raise;
End;
*/

/* Req sig
procedure get_base_table_periodicity(
p_base_table varchar2,
p_periodicity out nocopy number) is*/
function get_periodicity_for_table(
p_table varchar2) return NUMBER is


Begin
  return BSC_DBGEN_BSC_READER.get_periodicity_for_table(p_table);
Exception when others then
 raise;
End;

/*
given a calendar and periodicity, get the column name from bsc_db_calendar
*/
/* Req Sig
function get_db_calendar_column(
p_calendar number,
p_periodicity number) return varchar2 */
function get_db_calendar_column(
p_calendar_id number,
p_periodicity_id number) return varchar2 is


Begin
  return BSC_DBGEN_BSC_READER.get_db_calendar_column(p_calendar_id, p_periodicity_id);
 Exception when others then
 raise;
End;

/*Req sig
procedure get_zero_code_levels(
p_kpi varchar2,
p_dim_set varchar2,
p_levels out nocopy dbms_sql.varchar2_table) is*/
function get_zero_code_levels(
p_fact varchar2,
p_dim_set varchar2) return BSC_DBGEN_STD_METADATA.tab_clsLevel is


Begin
   return BSC_DBGEN_BSC_READER.get_zero_code_levels(p_fact, p_dim_set) ;
Exception when others then
 raise;
End;

/* Req sig
procedure get_dim_set_base_tables(
p_kpi varchar2,
p_dim_set varchar2,
p_base_tables out nocopy dbms_sql.varchar2_table) is*/
function get_base_tables_for_dim_set(
p_fact in varchar2,
p_dim_set in varchar2,
p_targets in boolean) return dbms_sql.varchar2_table is


Begin
  return BSC_DBGEN_BSC_READER.get_base_tables_for_dim_set(to_number(p_fact), to_number(p_dim_set), p_targets);
Exception when others then
 raise;
End;

/* Req sig
procedure get_dim_set_target_base_tables(
p_kpi varchar2,
p_dim_set varchar2,
p_base_tables out nocopy dbms_sql.varchar2_table) is
Use get_base_tables_for_dim_set with p_targets=true
*/


/*
this procedure gives the period in which there is a mix of forecast and real data
we need the following
kpi and periodicity : we use this to hit bsc_db_tables that will indicate the current period
Req sig
procedure get_kpi_current_period(
p_kpi varchar2,
p_periodicity number,
p_period out nocopy number) is */
function get_current_period_for_fact(
p_fact varchar2,
--p_dim_set NUMBER,
p_periodicity number) return number is


Begin
  return BSC_DBGEN_BSC_READER.get_current_period_for_fact(p_fact, p_periodicity);
Exception when others then
 raise;
End;


function get_current_year_for_fact(
p_fact varchar2) return number is
Begin
  return BSC_DBGEN_BSC_READER.get_current_year_for_fact(p_fact);
Exception when others then
 raise;
End;

/*
this API is only called from the BSC Metadata Optimizer UI for AW support
*/
function is_projection_enabled_for_kpi(
  p_kpi in varchar2
) return varchar2 is
Begin
 return BSC_DBGEN_BSC_READER.is_projection_enabled_for_kpi(p_kpi);
Exception when others then
 raise;
End;

/*
returns all the kpi that have been implemented in AW
*/
function get_all_facts_in_aw return dbms_sql.varchar2_table is


Begin
 return BSC_DBGEN_BSC_READER.get_all_facts_in_aw;
Exception when others then
 raise;
End;
--get the ZMV for a kpi and dimset
/* Req sig
procedure get_z_s_views(
p_kpi varchar2,
p_dim_set varchar2,
p_s_views out nocopy dbms_sql.varchar2_table)*/
function get_z_s_views(
p_fact IN VARCHAR2,
p_dim_set IN NUMBER)
return dbms_sql.varchar2_table is


Begin
 return BSC_DBGEN_BSC_READER.get_z_s_views(p_fact, p_dim_set);
Exception when others then
	 raise;
End;


--****************************************************************************
--
--
--  DESCRIPTION:
--   Get the collection of levels for the indicator
--
--  PARAMETERS:
--   p_fact: indicator code
-- this is needed by AW specifically, no need to order or
-- find missing levels.
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
-- Arun.Santhanam March 10, 2005
--***************************************************************************
Function get_all_levels_for_fact(p_fact IN VARCHAR2)
RETURN DBMS_SQL.VARCHAR2_TABLE IS

BEGIN
  return BSC_DBGEN_BSC_READER.get_all_levels_for_fact(p_fact);
END;


function get_dimension_level_short_name(p_dim_level_table_name IN VARCHAR2) return VARCHAR2
IS
BEGIN
  return BSC_DBGEN_BSC_READER.get_dimension_level_short_name(p_dim_level_table_name);
END;

function get_measures_for_short_names(p_short_names in dbms_sql.varchar2_table) return dbms_sql.varchar2_table is
begin
  return BSC_DBGEN_BSC_READER.get_measures_for_short_names(p_short_names);
end;

function get_dim_levels_for_short_names(p_short_names in dbms_sql.varchar2_table) return dbms_sql.varchar2_table is
begin
  return BSC_DBGEN_BSC_READER.get_dim_levels_for_short_names(p_short_names);
end;

function get_fact_implementation_type(p_fact in varchar2) return varchar2 is
begin
  return BSC_DBGEN_BSC_READER.get_fact_implementation_type(p_fact);
end;


function is_level_used_by_aw_fact(p_level_name in varchar2) return boolean is
begin
  return  bsc_dbgen_bsc_reader.is_level_used_by_aw_fact(p_level_name);
end;

-- reqd by venu to identify dim level changes
-- will return only the children used by facts implemented as AW
function get_parents_for_level_aw(p_level_name varchar2, p_num_levels number default 1000000) RETURN BSC_DBGEN_STD_METADATA.tab_ClsLevelRelationship is
begin
  return bsc_dbgen_bsc_reader.get_parents_for_level_aw(p_level_name, p_num_levels);
end;

-- reqd by venu to identify dim level changes
-- will return only the children used by facts implemented as AW
function get_children_for_level_aw(p_level_name varchar2, p_num_levels number default 1000000) RETURN BSC_DBGEN_STD_METADATA.tab_ClsLevelRelationship is
begin
  return bsc_dbgen_bsc_reader.get_children_for_level_aw(p_level_name, p_num_levels);
end;


procedure mark_facts_in_process(p_facts in dbms_sql.varchar2_table) is
begin
  g_assume_production_facts.delete;
  for i in 1..p_facts.count loop
    g_assume_production_facts(i):=p_facts(i);
  end loop;
end;

function get_target_per_for_b_table(p_fact in varchar2, p_dim_set in number, p_b_table in varchar2) return dbms_sql.varchar2_table is
begin
  return bsc_dbgen_bsc_reader.get_target_per_for_b_table(p_fact, p_dim_set, p_b_table);

end;


function get_initora_parameter(p_parameter in varchar2) return varchar2 is
CURSOR cValue is
select value from v$parameter where name=p_parameter;
begin
  if g_initora_parameters.exists(p_parameter) then
    return g_initora_parameters(p_parameter).value;
  end if;
  open cValue;
  fetch cValue INTO g_initora_parameters(p_parameter).value;
  close cValue;
  return  g_initora_parameters(p_parameter).value;
end;


function get_partition_clause return varchar2 is
l_stmt varchar2(1000);
begin
  if g_num_partitions = -1 then
    g_num_partitions := get_max_partitions;
  end if;
  if g_num_partitions <2 then
    return null;
  end if;
  l_stmt := ' partition by list('|| BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||') (';
  for i in 1..g_num_partitions loop
    if (i>1) then -- need comma
      l_stmt := l_stmt ||',';
    end if;
    l_stmt := l_stmt ||' partition p_'||(i-1)||' values('||(i-1)||')';
  end loop;
  l_stmt := l_stmt ||')';
  return l_stmt;
end;

function get_max_partitions return number is
l_cpus number;
begin
  if (g_num_partitions <> -1) then
    return g_num_partitions;
  end if;
  l_cpus := get_initora_parameter('cpu_count');
  -- if there are 2 or less cpus, then dont partition
  if (l_cpus <2) then
    g_num_partitions := 0;
    return g_num_partitions;
  end if;

  -- set the # of partitions to the max possible 2^x such that 2^x is less than max cpus
  -- eg. if there are 7 cpus, then 4
  -- eg. if there are 4 cpus, then 4
  -- eg. if there are 3 cpus, then 2
  g_num_partitions := 1;
  for i in 1..l_cpus loop
    if (g_num_partitions*2 > l_cpus) then
      exit;
    else
      g_num_partitions := g_num_partitions*2;
    end if;
  end loop;
  return g_num_partitions;

end;

function get_table_properties(p_table_name in VARCHAR2, p_property varchar2) return varchar2 is

l_properties dbms_sql.varchar2_table;
l_property_values dbms_sql.varchar2_table;
begin
  l_properties(1) := p_property;
  l_property_values := get_table_properties(p_table_name, l_properties);
  return l_property_values(1);
end;


function get_table_properties(p_table_name in VARCHAR2, p_property_list in dbms_sql.VARCHAR2_table) return dbms_sql.VARCHAR2_table IS
cursor cProperty is
select properties from bsc_db_tables
where table_name = p_table_name;
l_db_property varchar2(4000);
l_index number;

l_property_values dbms_sql.varchar2_table;
begin
  if p_property_list.count = 0 then
    return p_property_list;
  end if;
  open cProperty;
  fetch cProperty into l_db_property;
  close cProperty;
  l_index := p_property_list.first;
  loop
    if (p_property_list(l_index) is not null) then
      --dbms_output.put_line('calling parse with prop='||l_db_property||' name='||p_property_list(l_index)||', '|| BSC_DBGEN_STD_METADATA.BSC_ASSIGNMENT
      --   ||', null, '||BSC_DBGEN_STD_METADATA.BSC_PROPERTY_SEPARATOR);
      l_property_values(l_index) := bsc_dbgen_utils.parse_value(l_db_property, p_property_list(l_index),
                BSC_DBGEN_STD_METADATA.BSC_ASSIGNMENT,
                null,
                BSC_DBGEN_STD_METADATA.BSC_PROPERTY_SEPARATOR);
    else
      l_property_values(l_index) := null;
    end if;
    exit when l_index=p_property_list.last;
    l_index := p_property_list.next(l_index);
  end loop;
  return l_property_values;

end;

function get_partition_info(p_table_name varchar2) return BSC_DBGEN_STD_METADATA.clsTablePartition IS
cursor cPartitionType(p_owner varchar2) IS
select table_name, partitioning_type, partition_count from all_part_tables where table_name=p_table_name
and owner=p_owner;

cursor cPartCols(p_owner varchar2, p_table varchar2) IS
SELECT part_cols.column_name, tab_cols.data_type
  FROM all_tab_columns tab_cols
     , all_part_key_columns part_cols
 WHERE part_cols.name=p_table_name
   AND part_cols.owner = p_owner
   AND part_cols.name = tab_cols.table_name
   AND part_cols.column_name = tab_cols.column_name
   AND part_cols.owner = tab_cols.owner
   AND part_cols.object_type = p_table;

cursor cPartitionInfo(pOwner varchar2) IS
select partition_name, high_value, partition_position
from all_tab_partitions where table_name=p_table_name
and table_owner = pOwner
order by partition_position;

l_table_partition BSC_DBGEN_STD_METADATA.clsTablePartition;
l_partition BSC_DBGEN_STD_METADATA.clsPartitionInfo;
l_partition_null BSC_DBGEN_STD_METADATA.clsPartitionInfo;
l_count number := 1;
begin
  if (g_bsc_schema is null) then
    bsc_apps.init_bsc_apps;
    g_bsc_schema := bsc_apps.get_user_schema;
  end if;

  open cPartitionType(g_bsc_schema);
  fetch cPartitionType into l_table_partition.table_name, l_table_partition.partitioning_type, l_table_partition.partition_count;
  close cPartitionType;
  if l_table_partition.table_name is null then
    return l_table_partition;
  end if;

  -- get the partitioning column and its data type
  for i in cPartCols(g_bsc_schema, 'TABLE') loop
    l_table_partition.partitioning_column := l_table_partition.partitioning_column||i.column_name||',';
    l_table_partition.partitioning_column_datatype := l_table_partition.partitioning_column_datatype||i.data_type||',';
  end loop;
  l_table_partition.partitioning_column := substr(l_table_partition.partitioning_column, 1, length(l_table_partition.partitioning_column)-1);
  l_table_partition.partitioning_column_datatype := substr(l_table_partition.partitioning_column_datatype, 1,
                                                       length(l_table_partition.partitioning_column_datatype)-1);
  open cPartitionInfo(g_bsc_schema);
  loop
    fetch cPartitionInfo into l_partition.partition_name, l_partition.partition_value, l_partition.partition_position;
    exit when cPartitionInfo%NOTFOUND;
    l_table_partition.partition_info(l_count) := l_partition;
    l_count := l_count + 1;
    l_partition := l_partition_null;
  end loop;
  close cPartitionInfo;
  return l_table_partition;
end;


function get_last_update_date_for_fact(p_fact in varchar2) return date is
begin
  return bsc_dbgen_bsc_reader.get_last_update_date_for_fact(p_fact);
end;

function get_fact_cols_from_b_table(
p_fact in varchar2,
p_dim_set in number,
p_b_table_name in varchar2,
p_col_type in varchar2
) return BSC_DBGEN_STD_METADATA.tab_clsColumnMaps IS
--BSC_DBGEN_STD_METADATA.tab_clsLevel
Begin
  return bsc_dbgen_bsc_reader.get_fact_cols_from_b_table(p_fact, p_dim_set, p_b_table_name, p_col_type);
Exception when others then
 raise;
End;


procedure set_table_property(p_table_name in varchar2, p_property_name in varchar2, p_property_value in varchar2) is
begin
  bsc_dbgen_bsc_reader.set_table_property(p_table_name, p_property_name, p_property_value);
end;


FUNCTION get_denorm_dimension_table(p_dim_short_name VARCHAR2) return VARCHAR2 IS
l_denorm_table varchar2(100);
l_reverse varchar2(100);
BEGIN
  l_denorm_table := 'BSC_DN_';
  select reverse(p_dim_short_name) into l_reverse from dual;
  l_denorm_table := l_denorm_table|| bsc_aw_utility.get_hash_value(p_dim_short_name,100,1073741824)||'_'||
	bsc_aw_utility.get_hash_value('*'||l_reverse,100,1073741824);
  return l_denorm_table;
END;



--added Jan 12, 2006 for Venu
function get_current_period_for_table( p_table_name varchar2) return number is
begin
  return bsc_dbgen_bsc_reader.get_current_period_for_table(p_table_name);
end;


function get_current_year_for_table(p_table_name varchar2) return number is
begin
  return bsc_dbgen_bsc_reader.get_current_year_for_table(p_table_name);
end;

END BSC_DBGEN_METADATA_READER;

/
