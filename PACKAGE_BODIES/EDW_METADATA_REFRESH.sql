--------------------------------------------------------
--  DDL for Package Body EDW_METADATA_REFRESH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_METADATA_REFRESH" as
/* $Header: EDWMDRFB.pls 115.17 2004/04/06 16:41:34 vsurendr noship $*/

-- This procedure refreshes  metadata tables from owb repository

PROCEDURE refresh_metadata_tables(Errbuf out nocopy varchar2, Retcode out nocopy varchar2) IS
  l_stmt                        varchar2(20000);
  l_errbuf		 	varchar2(1000);
  l_retcode			varchar2(200);
  l_var varchar2(200);
  l_count                       number;
  check_tspace_exist            varchar(1);
  check_ts_mode                 varchar(1);
  physical_tspace_name          varchar2(100);
BEGIN


-- check the repository is OWB9i or OWB211. If it is 211, do nothing.
-- if it is 9i, refresh the metadata tables.

select count(*) into l_count from user_objects
 where object_name='ALL_IV_DIMENSIONS';

IF (l_count=0) THEN NULL;
ELSE
Errbuf := NULL;
Retcode := 0;
open_log_file;
g_owb_schema:=fnd_oracle_schema.getouvalue('OWB');
if g_owb_schema is null then
  g_owb_schema:='EDWREP';
end if;
log('OWB Schema '||g_owb_schema);
log('system time is '||    fnd_date.date_to_displaydt (sysdate) );
g_bis_owner:=get_db_user('BIS');
log('Bis owner= '||g_bis_owner);
if g_bis_owner is null then
  raise_application_error(-20000,errbuf);
  return;
end if;
--log('system time is '||    fnd_date.date_to_displaydt (sysdate) );
--l_stmt:='begin OWM_VIEW_UTILITIES.AUTO_SET_PRIMARY_SOURCE(false); end;';
--log(l_stmt);
--execute immediate l_stmt;
--commit;
log('system time is '||    fnd_date.date_to_displaydt (sysdate) );

/*******Bug 3008332******/
--Getting the operational tablespace
g_op_table_space:=fnd_profile.value('EDW_OP_TABLE_SPACE');
if g_op_table_space is null then
	AD_TSPACE_UTIL.is_new_ts_mode (check_ts_mode);
	If check_ts_mode ='Y' then
		AD_TSPACE_UTIL.get_tablespace_name ('BIS', 'INTERFACE','Y',check_tspace_exist, physical_tspace_name);
		if check_tspace_exist='Y' and physical_tspace_name is not null then
			g_op_table_space :=  physical_tspace_name;
		end if;
	end if;
   end if;
if g_op_table_space is null then
g_op_table_space:=EDW_OWB_COLLECTION_UTIL.get_table_space(g_bis_owner);
end if;
log('Operational tablespance is : ' || g_op_table_space);
/*******/

log('going to call refresh_owb_mv to refresh materialized views');
if refresh_owb_mv=false then
  raise_application_error(-20000,errbuf);
  return;
end if;
log('going to truncate all metadata tables'||get_time);
if truncate_all=false then
  raise_application_error(-20000,errbuf);
  return;
end if;
---------populate atomic tables ---------------------------------------
/**For ***Bug 3008332****/
l_stmt:= 'ALTER SESSION disable parallel query';
log( 'going to execute '||l_stmt);
execute immediate l_stmt;
log('Session altered to : DISABLED PARALLEL QUERY');
/****************************************************/

log('system time is '||    fnd_date.date_to_displaydt (sysdate) );
log('going to execute following sql statement ');
l_stmt:='insert into EDW_ALL_COLUMNS_MD (
ENTITY_ID,
ENTITY_TYPE,
ENTITY_NAME,
COLUMN_ID,
COLUMN_NAME,
BUSINESS_NAME,
DESCRIPTION,
POSITION,
DATA_TYPE,
LENGTH
)
select
ENTITY_ID,
ENTITY_TYPE,
ENTITY_NAME,
COLUMN_ID,
COLUMN_NAME,
BUSINESS_NAME,
DESCRIPTION,
POSITION,
DATA_TYPE,
LENGTH
FROM ALL_IV_COLUMNS
';
log(l_stmt);
execute immediate l_stmt;
log('No of Rows inserted : '||sql%rowcount||'   '||get_time);
commit;


log('going to execute following sql statement ');
l_stmt:='insert into EDW_ATTRIBUTE_SETS_MD
(ENTITY_ID,
 ENTITY_TYPE,
 ENTITY_NAME,
 ATTRIBUTE_GROUP_NAME,
 ATTRIBUTE_GROUP_ID,
 DESCRIPTION    )
SELECT
DATA_ENTITY_ID,
 DATA_ENTITY_TYPE,
 DATA_ENTITY_NAME,
 ATTRIBUTE_GROUP_NAME,
 ATTRIBUTE_GROUP_ID,
 DESCRIPTION
FROM ALL_IV_ATTR_GROUPS
';
log(l_stmt);
execute immediate l_stmt;
log('No of Rows inserted : '||sql%rowcount||'   '||get_time);
commit;

log('going to execute following sql statement ');
l_stmt:='insert into edw_dimensions_md(
dim_id,
dim_name,
dim_prefix,
dim_long_name,
dim_table_name,
dim_description
)
SELECT
    DIM.dimension_id,
    DIM.DIMENSION_NAME,
    DIM.DIMENSION_PREFIX,
    DIM.BUSINESS_NAME,
    DIM.DIMENSION_NAME,
        DIM.DESCRIPTION
FROM all_iv_dimensions DIM'
;
log(l_stmt);
execute immediate l_stmt;
log('No of Rows inserted : '||sql%rowcount||'   '||get_time);
commit;


log('going to execute following sql statement ');

l_stmt:='insert into  edw_facts_md
(
   fact_id,
   fact_name,
   fact_longname ,
   fact_description)
SELECT
    FACT.CUBE_ID,
    FACT.CUBE_NAME,
    FACT.BUSINESS_NAME,
    FACT.DESCRIPTION
 FROM
    ALL_IV_CUBES FACT';
log(l_stmt);
execute immediate l_stmt;
log('No of Rows inserted : '||sql%rowcount||'   '||get_time);
commit;


log('going to execute following sql statement ');
l_stmt:='insert into  EDW_FOREIGN_KEYS_MD
(
entity_id,
entity_type,
entity_name,
foreign_key_name,
foreign_key_id,
business_name,
description,
key_id,
key_name
)
select
entity_id,
entity_type,
entity_name,
foreign_key_name,
foreign_key_id,
business_name,
description,
key_id,
key_name
 from all_iv_foreign_keys'
;
log(l_stmt);
execute immediate l_stmt;
log('No of Rows inserted : '||sql%rowcount||'   '||get_time);
commit;


log('going to execute following sql statement ');
l_stmt:='insert into edw_hierarchies_md (
   dim_id,
   dim_name,
   hier_id,
   hier_name,
   hier_prefix,
   hier_long_name )
SELECT
    dim.dimension_id	dim_id,
dim.dimension_name	dim_name,
hier.hierarchy_id	hier_id,
hier.hierarchy_name	hier_name,
hier.hierarchy_prefix	hier_prefix,
hier.business_name	hier_long_name
FROM
    ALL_IV_DIMENSIONS dim, ALL_IV_DIM_HIERARCHIES hier
WHERE
    hier.dimension_id = dim.dimension_id';
log(l_stmt);
execute immediate l_stmt;
log('No of Rows inserted : '||sql%rowcount||'   '||get_time);
commit;


log('going to execute following sql statement ');
l_stmt:='insert into edw_relationmapping_md
  (
    sourcedataentity,
    targetdataentity,
    elementid,
    parentmodel,
    name
  )
select
src_map.data_entity_id sourcedataentity,
tgt_map.data_entity_id targetdataentity,
src_map.map_id elementid,
src_map.map_id parentmodel,
tgt_map.map_name name
from
ALL_IV_XFORM_MAP_PRIM_SOURCEs src_map,
ALL_IV_XFORM_MAP_TARGETS tgt_map
where
src_map.map_id=tgt_map.map_id'
;
log(l_stmt);
execute immediate l_stmt;
log('No of Rows inserted : '||sql%rowcount||'   '||get_time);
commit;


log('going to execute following sql statement ');
l_stmt:='insert into EDW_RELATIONS_MD
(
relation_id,
relation_name,
relation_long_name,
description,
relation_type
)
select table_id, table_name, business_name, description, null
from all_iv_tables
where table_name not in (select dim_name from edw_dimensions_md union
 select fact_name from edw_facts_md)
union all
select fact_id, fact_name, fact_longname, fact_description, ''CMPWBCube''
 from edw_facts_md
union all
select dim_id, dim_name, dim_long_name, dim_description, ''CMPWBDimension''
  from edw_dimensions_md
union all
select sequence_id, sequence_name, business_name, description, ''CMPWBSequence''
from all_iv_sequences
union all
select view_id, view_name, business_name, description, ''CMPWBView''
from all_iv_views';
log(l_stmt);
execute immediate l_stmt;
log('No of Rows inserted : '||sql%rowcount||'   '||get_time);
commit;


log('going to execute following sql statement ');
l_stmt:='insert into EDW_UNIQUE_KEYS_MD
(entity_id,
entity_type,
entity_name,
Key_id,
Key_name,
Business_name,
Description,
primarykey
)
SELECT
entity_id,
entity_type,
entity_name,
Key_id,
Key_name,
Business_name,
Description,
decode(is_primary, ''Y'', 1, 0)
FROM all_iv_keys';
log(l_stmt);
execute immediate l_stmt;
log('No of Rows inserted : '||sql%rowcount||'   '||get_time);
commit;


log('going to execute following sql statement ');
l_stmt:='insert into  EDW_UNIQUE_KEY_COLUMNS_MD
(
Key_id,
Key_name,
column_id,
column_name
)
SELECT
Key_id,
key_name,
column_id,
column_name
FROM all_iv_key_column_uses';
log(l_stmt);
execute immediate l_stmt;
log('No of Rows inserted : '||sql%rowcount||'   '||get_time);
commit;

------------ populate pvt tables ---------------------------
if populate_pvt_tables=false then
  raise_application_error(-20000,errbuf);
  return;
end if;

------------ populate secondary tables ---------------------------

log('system time is '||    fnd_date.date_to_displaydt (sysdate) );
log('going to execute following sql statement ');
l_stmt:='insert into edw_tables_md(
Elementid,
Name,
long_name)
SELECT
    table_ID 	Elementid,
    table_NAME 	Name,
business_name	long_name
FROM
   all_iv_tables TBL
WHERE
not exists( select dim_id from edw_dimensions_md where
dim_id = table_id) and
      not exists(select fact_id from edw_facts_md where fact_id = table_id) '
;
log(l_stmt);
execute immediate l_stmt;
log('No of Rows inserted : '||sql%rowcount||'   '||get_time);
commit;

log('going to execute following sql statement ');
l_stmt:='insert into edw_levels_md (
   level_id,
   level_name,
   level_prefix,
   level_long_name,
   level_table_id,
   level_table_name,
   description,
   dim_id,
   dim_name)
SELECT
LVL.LEVEL_ID,
LVL.LEVEL_NAME,
LVL.LEVEL_PREFIX ,
  LVL.BUSINESS_NAME	level_long_name,
  tbl.relation_id		level_table_id,
LVL.LEVEL_NAME||''_LTC''	level_table_name,
LVL.DESCRIPTION,
LVL.dimension_id	dim_id,
LVL.dimension_name	dim_name
FROM
all_iv_dim_levels lvl, EDW_RELATIONS_MD  tbl
where
lvl.level_name ||''_LTC'' = tbl.relation_name (+)'
;
log(l_stmt);
execute immediate l_stmt;
log('No of Rows inserted : '||sql%rowcount||'   '||get_time);
commit;

log('going to execute following sql statement ');
l_stmt:='insert into EDW_ATTRIBUTE_SET_COLUMN_MD
(ENTITY_ID,
ENTITY_TYPE,
ENTITY_NAME,
ATTRIBUTE_GROUP_NAME,
ATTRIBUTE_GROUP_ID,
COLUMN_ID,
COLUMN_TYPE,
COLUMN_NAME
)
select
GRP.DATA_ENTITY_ID		ENTITY_ID,
GRP.DATA_ENTITY_TYPE		ENTITY_TYPE,
GRP.DATA_ENTITY_NAME		ENTITY_NAME,
GRP.ATTRIBUTE_GROUP_NAME	ATTRIBUTE_GROUP_NAME,
GRP.ATTRIBUTE_GROUP_ID		ATTRIBUTE_GROUP_ID,
USES.DATA_ITEM_ID		COLUMN_ID,
USES.DATA_ITEM_TYPE		COLUMN_TYPE,
USES.DATA_ITEM_NAME		COLUMN_NAME
 from ALL_IV_ATTR_GROUPS grp,
ALL_IV_ATTR_GROUP_ITEM_USES uses
where
grp.attribute_group_id = uses.attribute_group_id ';
log(l_stmt);
execute immediate l_stmt;
log('No of Rows inserted : '||sql%rowcount||'   '||get_time);
commit;


log('going to execute following sql statement ');
l_stmt:='insert into edw_dim_attributes_md (
   dim_id,
   dim_name,
   attribute_id,
   attribute_name,
   attribute_longname,
   attribute_source_level,
   attribute_source_level_prefix,
   uk_id,
   uk_name )
select dim.dim_id dim_id,
dim.DIM_NAME     dim_name,
lvlattr.column_id    attribute_id,
lvlattr.COLUMN_NAME  attribute_name,
lvlattr.business_name   attribute_longname,
lvl.level_name          attribute_source_level,
lvl.level_prefix        attribute_source_level_prefix,
to_number(null)         uk_id,
to_char(null)           uk_name
from edw_dimensions_md dim, edw_levels_md lvl,
  EDW_ALL_COLUMNS_MD lvlattr
where dim.dim_id = lvl.dim_id
and lvl.level_id = lvlattr.ENTITY_ID
union
select dim.dim_id	dim_id,
dim.dim_name	dim_name,
lvlattr.column_id  	attribute_id,
lvlattr.column_name	attribute_name,
lvlattr.business_name	attribute_longname,
lvl.level_name		attribute_source_level,
lvl.level_prefix	attribute_source_level_prefix,
keys.key_id		uk_id,
keys.key_name		uk_name
from edw_dimensions_md dim, edw_levels_md lvl,
  EDW_ALL_COLUMNS_MD lvlattr,
EDW_UNIQUE_KEYS_MD keys,EDW_UNIQUE_KEY_COLUMNS_MD uses
where dim.dim_id = lvl.dim_id
and lvl.level_id = lvlattr.entity_id
and lvl.level_id = keys.entity_id
and keys.key_id = uses.key_id
and uses.column_id = lvlattr.column_id '
;
log(l_stmt);
execute immediate l_stmt;
log('No of Rows inserted : '||sql%rowcount||'   '||get_time);
commit;

log('going to execute following sql statement ');
l_stmt:='insert into edw_fact_attributes_md(
   fact_id,
   fact_name,
   attribute_type,
   attribute_id,
   attribute_name,
   attribute_longname,
   key_type,
   key_id,
   key_name )
SELECT  cube.fact_id,
cube.fact_name,
null,
col.column_id,
col.column_name,
col.business_name,
''FK'',
keys.key_id,
keys.key_name
FROM edw_all_columns_md  col,
edw_facts_md  cube,
edw_foreign_keys_md  keys,
edw_pvt_key_columns_md uses
where col.entity_id = cube.fact_id
and cube.fact_id = keys.entity_id
and keys.key_id = uses.key_id
and uses.column_id = col.column_id
UNION all
SELECT  cube.fact_id,
cube.fact_name,
DECODE(allcols.DATA_TYPE, ''NUMBER'' , ''MEASURE'', null),
col.measure_id,
col.measure_name,
col.business_name,
to_char(null),
to_number(null),
to_char(null)
FROM ALL_IV_CUBE_MEASURES col, edw_facts_md cube,
edw_all_columns_md  allcols
where col.cube_id = cube.fact_id
and allcols.entity_id = cube.fact_id
and allcols.column_id = col.measure_id'
;
log(l_stmt);
execute immediate l_stmt;
log('No of Rows inserted : '||sql%rowcount||'   '||get_time);
commit;

log('going to execute following sql statement ');
l_stmt:='insert into edw_fact_dim_relations_md (
   fact_id,
   fact_name,
   fact_fk_id,
   fact_fk_name,
   fact_fk_col_id,
   fact_fk_col_name,
   dim_uk_col_id,
   dim_uk_col_name,
   dim_uk_id,
   dim_uk_name,
   dim_uk_long_name,
   dim_id,
   dim_name ,
   fact_long_name)
select cube.cube_id,
cube.cube_name,
fk.foreign_key_id,
fk.foreign_key_name,
 fkuses.column_id,
fkuses.column_name,
pkuses.column_id,
pkuses.column_name,
pkuses.key_id,
pkuses.key_name,
pkkey.business_name,
pkkey.entity_id,
pkkey.entity_name ,
cube.business_name
from all_iv_cubes cube,
all_iv_foreign_keys fk,
all_iv_key_column_uses fkuses,
all_iv_key_column_uses pkuses,
all_iv_keys pkkey
where cube.cube_id = fk.entity_id
and fk.foreign_key_id = fkuses.key_id
and fk.key_id = pkuses.key_id
and pkuses.key_id = pkkey.key_id '
;
log(l_stmt);
execute immediate l_stmt;
log('No of Rows inserted : '||sql%rowcount||'   '||get_time);
commit;

log('going to execute following sql statement ');
l_stmt:='insert into edw_fact_hier_md(
   fact_id,
   fact_name,
   dim_id,
   dim_name,
   hier_id,
   hier_name )
select fact.fact_id,
fact.fact_name ,
keys.entity_id,
keys.entity_name,
hier.hier_id,
hier.hier_name
from
edw_facts_md fact,
edw_hierarchies_md hier,
EDW_FOREIGN_KEYS_MD fk,
EDW_UNIQUE_KEYS_MD  keys
where fact.fact_id = fk.entity_id
and fk.key_id = keys.key_id
and keys.entity_id = hier.dim_id';
log(l_stmt);
execute immediate l_stmt;
log('No of Rows inserted : '||sql%rowcount||'   '||get_time);
commit;

log('going to execute following sql statement ');
l_stmt:='insert into EDW_FOREIGN_KEY_COLUMNS_MD
(entity_id,
entity_type,
entity_name,
fk_name,
fk_id,
fk_logical_name,
fk_description,
pk_id,
pk_name,
fk_column_id,
fk_column_name,
fk_position)
select fk.entity_id,
fk.entity_type,
fk.entity_name,
fk.foreign_key_name	fk_name,
fk.foreign_key_id	fk_id,
fk.business_name	fk_logical_name,
fk.description		fk_description,
fk.key_id		pk_id,
fk.key_name		pk_name,
fkuse.column_id		fk_column_id,
fkuse.column_name	fk_column_name,
fkuse.position		fk_position
from all_iv_foreign_keys fk, all_iv_key_column_uses fkuse
where fk.foreign_key_id = fkuse.key_id ';
log(l_stmt);
execute immediate l_stmt;
log('No of Rows inserted : '||sql%rowcount||'   '||get_time);
commit;


log('going to execute following sql statement ');
l_stmt:='insert into edw_hierarchy_level_md (
   dim_id,
   dim_name,
   hier_id,
   hier_name,
   lvl_id,
   lvl_name,
   lvl_prefix,
   parent_lvl_id
)
select
dim.dim_id,
dim.dim_name,
hier.hier_id,
hier.hier_name,
lvl.level_id		lvl_id,
lvl.level_name		lvl_name,
lvl.level_prefix	lvl_prefix,
hierlvl.parent_level_id parent_lvl_id
from edw_dimensions_md  dim,
EDW_LEVELS_MD  lvl,
edw_hierarchies_md  hier,
all_iv_dim_hierarchy_levels hierlvl
where dim.dim_id = lvl.dim_id
and dim.dim_id = hier.dim_id
and hier.hier_id = hierlvl.hierarchy_id
and lvl.level_id = hierlvl.level_id '
;
log(l_stmt);
execute immediate l_stmt;
log('No of Rows inserted : '||sql%rowcount||'   '||get_time);
commit;

log('going to execute following sql statement ');
l_stmt:='insert into EDW_LEVEL_ATTS_MD
( dim_id,
   dim_name,
   lvl_id,
   lvl_name,
   lvl_col_id,
   lvl_col_name,
   lvl_col_long_name,
   uk_id,
   uk_name )
select dim.dim_id ,
dim.dim_name,
lvl.level_id            ,
lvl.level_name          ,
lvlattr.column_id    ,
lvlattr.column_name  ,
lvlattr.business_name   ,
to_number(null)         ,
to_char(null)
from
edw_dimensions_md  dim,
edw_levels_md      lvl ,
edw_all_columns_md lvlattr
where
dim.dim_id = lvl.dim_id
and lvl.level_id = lvlattr.entity_id
union
select dim.dim_id,
dim.dim_name,
lvl.level_id            ,
lvl.level_name          ,
lvlattr.column_id    ,
lvlattr.column_name  ,
lvlattr.business_name   ,
keys.key_id             ,
keys.key_name
 from
edw_dimensions_md dim,
edw_levels_md  lvl ,
edw_all_columns_md lvlattr,
EDW_UNIQUE_KEYS_MD  keys,
EDW_UNIQUE_KEY_COLUMNS_MD  keycols
where
dim.dim_id = lvl.dim_id
and lvl.level_id = lvlattr.entity_id
and lvl.level_id = keys.entity_id (+)
and keys.key_id = keycols.key_id (+)
and lvlattr.column_id(+) = keycols.column_id'
;
log(l_stmt);
execute immediate l_stmt;
log('No of Rows inserted : '||sql%rowcount||'   '||get_time);
commit;

analyze_all;

log('going to execute following sql statement ');
l_stmt:='insert into edw_level_relations_md
(  level_relation_id,
   dim_id,
   dim_name,
   hier_id,
   hier_name,
   parent_lvl_id,
   parent_lvl_name,
   parent_lvl_prefix,
   parent_lvltbl_id,
   parent_lvltbl_name,
   uk_id,
   uk_name,
   child_lvl_id,
   child_lvl_name,
   child_lvl_prefix,
   child_lvltbl_id,
   chil_lvltbl_name,
   fk_id,
   fk_name )
select
lvlrel.level_use_id	,
dim.dim_id	,
dim.dim_name	,
hier.hier_id,
hier.hier_name,
lvlrel.parent_level_id,
plvl.level_name		,
plvl.level_prefix	,
ptbl.relation_id	,
ptbl.relation_name	,
uk.key_id		,
uk.key_name		,
lvlrel.level_id		,
clvl.level_name		,
clvl.level_prefix	,
ctbl.relation_id	,
ctbl.relation_name	,
fk.foreign_key_id	,
fk.foreign_key_name
FROM
edw_dimensions_md dim,
edw_hierarchies_md hier,
all_iv_dim_hierarchy_levels lvlrel,
edw_levels_md 		plvl,
EDW_RELATIONS_MD 	ptbl,
EDW_UNIQUE_KEYS_MD 	uk,
edw_levels_md 		clvl,
EDW_RELATIONS_MD 	ctbl,
EDW_FOREIGN_KEYS_MD 	fk
where
  dim.dim_id = hier.dim_id
and hier.hier_id = lvlrel.HIERARCHY_id
and lvlrel.parent_level_id = plvl.level_id
and plvl.level_name || ''_LTC'' = ptbl.relation_name (+)
and ptbl.relation_name is not null
and ptbl.relation_id = uk.entity_id(+)
and lvlrel.level_id = clvl.level_id
and clvl.level_name||''_LTC'' = ctbl.relation_name (+)
and ctbl.relation_name is not null
and ctbl.relation_id = fk.entity_id (+)
and fk.key_id = uk.key_id
UNION ALL
SELECT
LVLREL.LEVEL_USE_ID   ,
DIM.DIM_ID      ,
DIM.DIM_NAME    ,
HIER.HIER_ID,
HIER.HIER_NAME,
LVLREL.PARENT_LEVEL_ID,
PLVL.LEVEL_NAME          ,
PLVL.LEVEL_PREFIX         ,
TO_NUMBER(NULL)    ,
NULL                ,
TO_NUMBER(NULL)    ,
NULL               ,
LVLREL.LEVEL_ID    ,
CLVL.LEVEL_NAME           ,
CLVL.LEVEL_PREFIX        ,
TO_NUMBER(NULL)       ,
NULL                  ,
TO_NUMBER(NULL)    ,
NULL
FROM edw_dimensions_md DIM,
edw_hierarchies_md  hier,
all_iv_dim_hierarchy_levels lvlrel,
edw_levels_md 		plvl ,
EDW_RELATIONS_MD ptbl,
edw_levels_md 		Clvl,
EDW_RELATIONS_MD 	CTBL
WHERE
    DIM.DIM_ID = HIER.DIM_ID
AND HIER.HIER_ID = LVLREL.HIERARCHY_ID
AND LVLREL.PARENT_LEVEL_ID = PLVL.LEVEL_ID
AND PLVL.LEVEL_NAME || ''_LTC'' = PTBL.RELATION_NAME (+)
AND PTBL.RELATION_NAME IS NULL AND LVLREL.LEVEL_ID  = CLVL.LEVEL_ID
AND CLVL.LEVEL_NAME || ''_LTC'' = CTBL.RELATION_NAME (+)
AND CTBL.RELATION_NAME IS NULL'
;
log(l_stmt);
execute immediate l_stmt;
log('No of Rows inserted : '||sql%rowcount||'   '||get_time);
commit;

log('going to execute following sql statement ');
l_stmt:='insert into  edw_level_table_atts_md (dim_id, dim_name,
level_table_id, level_table_name, level_prefix,
level_table_col_id, level_table_col_name, level_table_col_long_name,
key_type, key_id, key_name, level_id,
level_name, level_long_name)
SELECT DIM.DIM_ID, DIM.DIM_NAME, LVLTBL.ELEMENTID,
LVLTBL.NAME, LVL.LEVEL_PREFIX, UCOL.COLUMN_ID, UCOL.COLUMN_NAME,
UCOL.BUSINESS_NAME, DECODE(uk.KEY_ID, NULL, NULL, ''UK''),
UK.KEY_ID, UK.KEY_NAME, lvl.LEVEL_id, lvl.LEVEL_name,
LVL.LEVEL_LONG_NAME
FROM EDW_DIMENSIONS_MD DIM , EDW_LEVELS_MD LVL , EDW_TABLES_MD LVLTBL ,
EDW_ALL_COLUMNS_MD UCOL ,
EDW_UNIQUE_KEYS_MD UK, EDW_UNIQUE_KEY_COLUMNS_MD ukuse
WHERE DIM.DIM_ID = LVL.DIM_ID
AND LVL.LEVEL_NAME || ''_LTC'' = LVLTBL.NAME AND LVLTBL.ELEMENTID =
UCOL.ENTITY_ID
AND LVLTBL.ELEMENTID = UK.ENTITY_ID
and uk.key_id = ukuse.key_id
and ukuse.column_id = ucol.column_id
UNION ALL
SELECT DIM.DIM_ID, DIM.DIM_NAME, LVLTBL.ELEMENTID,
LVLTBL.NAME, LVL.LEVEL_PREFIX, UCOL.COLUMN_ID, UCOL.COLUMN_NAME,
UCOL.BUSINESS_NAME, null,
to_number(null), null, lvl.LEVEL_id, lvl.LEVEL_name, LVL.LEVEL_LONG_NAME
FROM EDW_DIMENSIONS_MD_V DIM , EDW_LEVELS_MD LVL , EDW_TABLES_MD LVLTBL,
EDW_ALL_COLUMNS_MD UCOL
WHERE DIM.DIM_ID = LVL.DIM_ID
AND LVL.LEVEL_NAME || ''_LTC'' = LVLTBL.NAME AND LVLTBL.ELEMENTID =
UCOL.ENTITY_ID
and ucol.column_id not in
(select keyuse.column_id from EDW_UNIQUE_KEYS_MD keys,
EDW_UNIQUE_KEY_COLUMNS_MD keyuse
where keys.key_id = keyuse.key_id
and keys.entity_id = LVLTBL.ELEMENTID)
and ucol.column_id not in (
select keyuse.column_id from EDW_FOREIGN_KEYS_MD keys,
EDW_UNIQUE_KEY_COLUMNS_MD keyuse
where keys.foreign_key_id = keyuse.key_id
and keys.entity_id = LVLTBL.ELEMENTID
)
UNION ALL
SELECT
DIM.DIM_ID, DIM.DIM_NAME,
LVLTBL.ELEMENTID, LVLTBL.NAME, LVL.LEVEL_PREFIX, FCOL.COLUMN_ID,
FCOL.COLUMN_NAME,
FCOL.BUSINESS_NAME, ''FK'', FK.KEY_ID, FK.KEY_NAME, lvl.level_id,
lvl.level_name, LVL.LEVEL_LONG_NAME
FROM
EDW_DIMENSIONS_MD_V DIM , EDW_LEVELS_MD LVL , EDW_TABLES_MD LVLTBL ,
EDW_ALL_COLUMNS_MD FCOL ,
EDW_FOREIGN_KEYS_MD FK, EDW_UNIQUE_KEY_COLUMNS_MD fkuse
WHERE DIM.DIM_ID = LVL.DIM_ID
AND LVL.LEVEL_NAME || ''_LTC'' = LVLTBL.NAME AND LVLTBL.ELEMENTID = FCOL.ENTITY_ID
AND LVLTBL.ELEMENTID = FK.ENTITY_ID
and fk.foreign_key_id = fkuse.key_id
and fkuse.column_id = fcol.column_id';
log(l_stmt);
execute immediate l_stmt;
log('No of Rows inserted : '||sql%rowcount||'   '||get_time);
commit;

analyze_all;
END IF;
log ('Finished procedure refresh_metadata_tables');
Exception when others then
  g_status_message:=sqlerrm;
  log('Error in populate metadata tables '||sqlerrm);
  raise_application_error(-20000,errbuf);
END refresh_metadata_tables;


function get_db_user(p_product varchar2) return varchar2 is
l_dummy1 varchar2(2000);
l_dummy2 varchar2(2000);
l_schema varchar2(400);
Begin
  if FND_INSTALLATION.GET_APP_INFO(p_product,l_dummy1, l_dummy2,l_schema) = false then
    log('FND_INSTALLATION.GET_APP_INFO returned with error');
    return null;
  end if;
  return l_schema;
Exception when others then
  g_status_message:=sqlerrm;
  log('Error in get_db_user '||sqlerrm);
  return null;
End;

procedure log(p_message varchar2) is
Begin
  edw_owb_collection_util.write_to_log_file_n(p_message);
Exception when others then
  g_status_message:=sqlerrm;
  null;
End;

function get_time return varchar2 is
Begin
  return ' '||fnd_date.date_to_displaydt (sysdate);
Exception when others then
  null;
End;

function populate_pvt_tables return boolean is
l_stmt varchar2(32000);
l_table varchar2(300);
l_table2 varchar2(300);
l_table3 varchar2(300);
l_table4 varchar2(300);
Begin
  log('going to execute following sql statement ');
  l_stmt:='insert into edw_pvt_level_relation_md( '||
  'hierarchy_id, '||
  'parent_level_id, '||
  'child_level_id) '||
  'select '||
  'hierarchy_id, '||
  'parent_level_id, '||
  'level_id child_level_id '||
  'from '||
  'all_iv_dim_hierarchy_levels ';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  log(sql%rowcount||get_time);
  commit;
  l_stmt:='insert into  edw_pvt_sequences_md( '||
  ' sequence_id, '||
  ' sequence_name, '||
  'logical_name, '||
  'description) '||
  'select '||
  ' sequence_id, '||
  ' sequence_name, '||
  ' business_name logical_name, '||
  ' description description '||
  'from '||
  'all_iv_sequences ';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  log(sql%rowcount||get_time);
  commit;
  l_stmt:='insert into  edw_pvt_views_md( '||
  ' view_id, '||
  ' view_name, '||
  'logical_name, '||
  'description '||
  ') '||
  'select '||
  ' view_id, '||
  ' view_name, '||
  ' business_name logical_name, '||
  ' description description '||
  'from '||
  'all_iv_views ';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  log(sql%rowcount||get_time);
  commit;
  l_stmt:='insert into edw_pvt_columns_md( '||
  ' column_id, '||
  ' column_name, '||
  'parent_object_id, '||
  ' data_type, '||
  ' length, '||
  ' logical_name, '||
  ' description '||
  ') '||
  ' select '||
  ' column_id, '||
  ' column_name, '||
  ' entity_id parent_object_id, '||
  ' data_type, '||
  ' length, '||
  ' business_name logical_name, '||
  ' description description '||
  'from '||
  'all_iv_columns ';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  log(sql%rowcount||get_time);
  commit;
  l_stmt:='insert into edw_pvt_key_columns_md( '||
  'key_id, '||
  'column_id, '||
  'KEY_TYPE, '||
  'KEY_NAME '||
  ') '||
  'select '||
  'key_id, '||
  'column_id, '||
  'KEY_TYPE, '||
  'KEY_NAME '||
  'from '||
  'all_iv_key_column_uses ';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  log(sql%rowcount||get_time);
  commit;
  l_stmt:='insert into edw_pvt_mappings_md( '||
  'mapping_id, '||
  'mapping_name, '||
  'logical_name, '||
  'description '||
  ') '||
  'select '||
  'map_id mapping_id, '||
  'map_name mapping_name, '||
  'business_name logical_name, '||
  'description description '||
  'from '||
  'all_iv_xform_maps ';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  log(sql%rowcount||get_time);
  commit;
  l_table:=g_bis_owner||'.edw_pvt_map_properties_md1';
  drop_table(l_table);

  l_stmt:='create table '||l_table||' tablespace '||g_op_table_space||' as '||
  'select '||
  'comp.map_id mapping_id, '||
  'prop.property_value text, '||
  '''Filter'' text_type '||
  'from '||
  'all_iv_xform_map_components comp, '||
  'all_iv_xform_map_properties prop '||
  'where '||
  'prop.map_component_id = comp.map_component_id and '||
  'comp.operator_type = ''Filter''';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  log(sql%rowcount||get_time);
  commit;

  l_stmt:='insert into edw_pvt_map_properties_md( '||
  'mapping_id, '||
  'Primary_source, '||
  'Primary_target, '||
  'text, '||
  'text_type '||
  ') '||
  'select '||
  'src.map_id mapping_id, '||
  'src.DATA_ENTITY_ID Primary_source, '||
  'tgt.DATA_ENTITY_ID Primary_target, '||
  'line.text text, '||
  'line.text_type text_type '||
  'from '||
  'ALL_IV_XFORM_MAP_PRIM_SOURCES src, '||
  'ALL_IV_XFORM_MAP_TARGETS tgt, '||
  l_table||' line '||
  'where '||
  'src.map_id=tgt.map_id '||
  'and line.mapping_id(+)=src.map_id ';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  log(sql%rowcount||get_time);
  commit;
  drop_table(l_table);
  l_stmt:='insert into edw_pvt_map_sources_md( '||
  'mapping_id, '||
  'source_id, '||
  'source_usage_id, '||
  'source_alias '||
  ') '||
  'select '||
  'src.map_id mapping_id, '||
  'src.DATA_ENTITY_ID source_id, '||
  'src.map_component_id source_usage_id, '||
  'src.map_component_name source_alias '||
  'from '||
  'ALL_IV_XFORM_MAPS map, '||
  'ALL_IV_XFORM_MAP_SOURCES src '||
  'where map.map_id=src.map_id ';
  log(l_stmt);
  execute immediate l_stmt;
  log('No of Rows inserted : '||sql%rowcount||'   '||get_time);
  commit;
  ------------------------------------------------------------------------------
  --fix for 2739489.
  log('going to execute following sql statement ');
    l_stmt:='create table '||l_table||' tablespace '||g_op_table_space||' as select edw_pvt_map_sources_md.*, '||
  'owm_view_utilities.ISREALSOURCE(source_usage_id) col from edw_pvt_map_sources_md ';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  log(sql%rowcount||get_time);
  l_stmt := 'truncate table '||g_bis_owner||'.EDW_PVT_MAP_SOURCES_MD';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  l_stmt:='insert into edw_pvt_map_sources_md(mapping_id, '||
  'source_id, '||
  'source_usage_id, '||
  'source_alias) select mapping_id, '||
  'source_id, '||
  'source_usage_id, '||
  'source_alias from '||l_table||' where col=''Y''';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  log(sql%rowcount||get_time);
  commit;
  drop_table(l_table);
  ------------------------------------------------------------------------------
  log('going to execute following sql statement ');
  l_stmt:='insert into edw_pvt_map_targets_md( '||
  'mapping_id, '||
  'target_id, '||
  'target_usage_id, '||
  'target_alias '||
  ') '||
  'select '||
  'tgt.map_id mapping_id, '||
  'tgt.DATA_ENTITY_ID target_id, '||
  'tgt.map_component_id target_usage_id, '||
  'tgt.map_component_name target_alias '||
  'from '||
  'ALL_IV_XFORM_MAPS map, '||
  'ALL_IV_XFORM_MAP_TARGETS tgt '||
  'where map.map_id=tgt.map_id ';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  log(sql%rowcount||get_time);
  commit;
  l_table:=g_bis_owner||'.edw_pvt_map_columns_md_1';
  drop_table(l_table);
  l_stmt:='create table '||l_table||' tablespace '||g_op_table_space||'  as '||
  'SELECT  * from ALL_IV_XFORM_MAP_PARAMETERS3';
  log(l_stmt);
  execute immediate l_stmt;
  log('No of Rows inserted : '||sql%rowcount||'   '||get_time);
  commit;

  log('going to execute following sql statement ');
  l_stmt:='insert into edw_pvt_map_columns_tgt_md ('||
  '       map_id, '||
  '       map_component_id, '||
  '       source_parameter_id, '||
  '       parameter_id, '||
  '       data_item_id ) '||
  'select '||
  '       tgt_ru.map_id, '||
  '       tgt_ru.map_component_id, '||
  '       tgt_iu.source_parameter_id, '||
  '       tgt_iu.parameter_id, '||
  '       tgt_iu.data_item_id '||
  'from '||
  '       all_iv_xform_map_targets tgt_ru, '||
  '       '||l_table||' tgt_iu '||
  'where '||
  '       tgt_ru.map_component_id = tgt_iu.map_component_id ';
  log(l_stmt);
  execute immediate l_stmt;
  log('No of Rows inserted : '||sql%rowcount||'   '||get_time);
  commit;

  drop_table(l_table);

  log('going to execute following sql statement ');
  l_stmt:='insert into edw_pvt_map_columns_src_md('||
  '      map_id, '||
  '      map_component_id, '||
  '      parameter_id, '||
  '      data_item_id) '||
  'select '||
  'src_ru.map_id, '||
  'src_ru.map_component_id, '||
  'src_iu.parameter_id, '||
  'src_iu.data_item_id '||
  'from '||
  'all_iv_xform_map_components2 src_ru, '||
  'all_iv_xform_map_parameters2 src_iu '||
  'where '||
  'src_ru.map_component_id = src_iu.map_component_id ';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  log(sql%rowcount||get_time);
  commit;
  l_table:=g_bis_owner||'.t_xform_map_components';
  l_table2:=g_bis_owner||'.t_foreign_keys';
  l_table3:=g_bis_owner||'.t_keys';
  drop_table(l_table);
  drop_table(l_table2);
  drop_table(l_table3);
  l_stmt:='create table '||l_table||' tablespace '||g_op_table_space||'  as select * from all_iv_xform_map_components3';
  log(l_stmt);
  execute immediate l_stmt;
  log('No of Rows inserted : '||sql%rowcount||'   '||get_time);
  commit;

  log('going to execute following sql statement ');
  l_stmt:='create table '||l_table2||' tablespace '||g_op_table_space||'  as select * from all_iv_foreign_keys';
  log(l_stmt);
  execute immediate l_stmt;
  log('No of Rows inserted : '||sql%rowcount||'   '||get_time);
  commit;

  log('going to execute following sql statement ');
  l_stmt:='create table '||l_table3||' tablespace '||g_op_table_space||'  as select * from all_iv_keys';
  log(l_stmt);
  execute immediate l_stmt;
  log('No of Rows inserted : '||sql%rowcount||'   '||get_time);
  commit;

  log('going to execute following sql statement ');
  l_stmt:='insert into edw_pvt_map_key_usages_md( '||
  'Source_usage_id, '||
  'Parent_table_usage_id, '||
  'foreign_key_usage_id, '||
  'foreign_key_id, '||
  'Unique_key_id, '||
  'mapping_id '||
  ') '||
  'select /*+use_hash(fstg_usage,fstg_fk,dim_usage,dim_pk)*/ '||
  '       fstg_usage.map_component_id source_usage_id, '||
  '       dim_usage.map_component_id  parent_table_usage_id, '||
  '       fstg_fk.foreign_key_id      foreign_key_usage_id, '||
  '       fstg_fk.foreign_key_id      foreign_key_id, '||
  '       dim_pk.key_id               unique_key_id, '||
  '       fstg_usage.map_id           map_id '||
  'from '||
  '       '||l_table||' fstg_usage, '||
  '       '||l_table2||' fstg_fk, '||
  '       '||l_table||' dim_usage, '||
  '       '||l_table3||' dim_pk '||
  'where '||
  '       fstg_fk.entity_id = fstg_usage.data_entity_id '||
  'and    fstg_usage.map_id = dim_usage.map_id '||
  'and    fstg_fk.key_id    = dim_pk.key_id '||
  'and    dim_pk.entity_id  = dim_usage.data_entity_id ';
  log(l_stmt);
  execute immediate l_stmt;
  log('No of Rows inserted : '||sql%rowcount||'   '||get_time);
  commit;

  drop_table(l_table);
  drop_table(l_table2);
  drop_table(l_table3);
  ------------------------------------------------------------------------------
  --fix for 2739489.
  log('going to execute following sql statement ');
  l_stmt:='create table '||l_table||' tablespace '||g_op_table_space||' as select edw_pvt_map_key_usages_md.*,'||
  'owm_view_utilities.ISREALSOURCE(source_usage_id) col from edw_pvt_map_key_usages_md ';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  log(sql%rowcount||get_time);
  l_stmt := 'truncate table '||g_bis_owner||'.edw_pvt_map_key_usages_md';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  l_stmt:='insert into edw_pvt_map_key_usages_md( '||
  'Source_usage_id, '||
  'Parent_table_usage_id, '||
  'foreign_key_usage_id, '||
  'foreign_key_id, '||
  'Unique_key_id, '||
  'mapping_id) select '||
  'Source_usage_id, '||
  'Parent_table_usage_id, '||
  'foreign_key_usage_id, '||
  'foreign_key_id, '||
  'Unique_key_id, '||
  'mapping_id from '||l_table||' where col=''Y''';
  log(l_stmt);
  execute immediate l_stmt;
  log(sql%rowcount||'   '||get_time);
  commit;
  drop_table(l_table);
  ------------------------------------------------------------------------------
  log('going to execute following sql statement ');
  --Bug 3548744
  l_stmt:='insert into edw_pvt_map_func_md( '||
  'func_name,  '||
  'category_name,  '||
  'column_name,  '||
  'column_id,  '||
  'column_usage_id , '||
  'aggregation,  '||
  'is_distinct,  '||
  'relation_id,  '||
  'relation_name,  '||
  'relation_usage_id,  '||
  'relation_type,  '||
  'func_usage_id,  '||
  'attribute_position, '||
  'func_default_value,  '||
  'mapping_id  '||
  ')  '||
  'select /*+ ordered(v2,rel) no_merge(v2) */ '||
  '     v2.function_name,  '||
  '     v2.function_library_name, '||
  '     v2.parameter_name src_parameter_name, '||
  '     col.column_id,  '||
  '     v2.src_parameter_id, '||
  '     owm_view_utilities.getaggregationfunction(v2.src_parameter_id), '||
  '     null,  '||
  '     rel.object_id, '||
  '     rel.object_name,  '||
  '     v2.src_component_id  as map_component_id, '||
  '     rel.object_type,  '||
  '     v2.operator_id      as func_usage_id, '||
  '     v2.position,  '||
  '     v2.default_value    as defaultvalue, '||
  '     v2.map_id  '||
  ' from  '||
  ' (select /*+ ordered(v1,mpv) no_merge(v1) */ '||
  '     v1.function_name,  '||
  '     v1.src_parameter_name, '||
  '     v1.src_parameter_id,  '||
  '     v1.src_component_id,  '||
  '     v1.siusage,  '||
  '     v1.operator_id,  '||
  '     v1.map_id,  '||
  '     v1.position, '||
  '     v1.default_value, '||
  '     v1.function_library_name, '||
  '     (select parameter_name from all_iv_xform_map_parameters '||
  '       where parameter_id = v1.siusage) parameter_name,  '||
  '     (select sc.data_entity_id  '||
  '       from  all_iv_xform_map_parameters mpv, '||
  '             all_iv_xform_map_components sc  '||
  '       where  v1.siusage = mpv.parameter_id  '||
  '       and    mpv.map_component_id = sc.map_component_id) data_entity_id '||
  '   from  '||
  '     (select /*+ ordered(ops,fa,fcat) '||
  '                 no_merge(fa) no_merge(ops) no_merge(fa)*/ '||
  '             ops.function_name,  '||
  '             ops.src_parameter_name, '||
  '             ops.src_parameter_id,  '||
  '             ops.src_component_id,  '||
  '             ops.operator_id,  '||
  '             ops.map_id,  '||
  '             owm_view_utilities.findsourceitemusage(ops.src_parameter_id) siusage, '||
  '             fa.position,  '||
  '             fa.default_value, '||
  '             fcat.function_library_name '||
  '       from  all_iv_operator_sources2 ops,  '||
  '             all_iv_function_parameters fa,  '||
  '             all_iv_function_libraries  fcat, '||
  '             all_iv_xform_map_parameters maprmv '||
  '       where  '||
  '       ops.function_id          = fa.function_id '||
  '       and ops.map_id = maprmv.map_id  '||
  '       and ops.op_param_id = maprmv.parameter_id '||
  '       and    maprmv.position        = fa.position  '||
  '       and    fcat.function_library_id =ops.function_library_id '||
  '   ) v1  '||
  ') v2,  '||
  ' all_iv_all_objects rel, '||
  ' edw_pvt_columns_md col  '||
  ' where  '||
  ' v2.data_entity_id = rel.object_id (+) '||
  ' and col.parent_object_id = rel.object_id  '||
  ' and col.column_name=v2.parameter_name  ';
  log(l_stmt);
  execute immediate l_stmt;
   log('No of Rows inserted : '||sql%rowcount||'   '||get_time);
  commit;
  /*
  Bug 2638686
  The above sql only inserted half the info. it only inserted the src columns to
  a transform and missed the tgt columns.the sql below gets the tgt column.
  the sql below written by vsurendr and not owb team
  */
  log('going to execute following sql statement ');
  l_stmt:='insert into edw_pvt_map_func_md( '||
  'func_name, '||
  'category_name, '||
  'column_name, '||
  'column_id, '||
  'column_usage_id , '||
  'aggregation, '||
  'is_distinct, '||
  'relation_id, '||
  'relation_name, '||
  'relation_usage_id, '||
  'relation_type, '||
  'func_usage_id, '||
  'attribute_position, '||
  'func_default_value, '||
  'mapping_id '||
  ') '||
  'select   '||
  'tgt.function_name, '||
  'fcat.function_library_name, '||
  'tgt.tgt_parameter_name, '||
  'col.column_id, '||
  'tgt.tgt_parameter_id, '||
  'null, '||
  'null, '||
  'map_tgt.data_entity_id, '||
  'tgt.tgt_component_name, '||
  'tgt.tgt_component_id, '||
  'null, '||
  'tgt.operator_id, '||
  '0, '||
  'null, '||
  'tgt.map_id '||
  'from '||
  'all_iv_function_libraries fcat, '||
  'all_iv_operator_targets tgt, '||
  'ALL_IV_XFORM_MAP_TARGETS map_tgt, '||
  'edw_pvt_columns_md col '||
  'where '||
  'fcat.function_library_id=tgt.function_library_id '||
  'and map_tgt.map_id=tgt.map_id '||
  'and map_tgt.data_entity_name=tgt.tgt_component_name '||
  'and col.column_name=tgt.tgt_parameter_name '||
  'and col.parent_object_id =map_tgt.data_entity_id ';
  log(l_stmt);
  execute immediate l_stmt;
  log('No of Rows inserted : '||sql%rowcount||'   '||get_time);
  commit;
  /*
  bug 3109244
  maps were using aggregation operator. we did not support aggregation operator.
  in 2.1.1, to get count(...), you would need to define a transform in edw_stand_alone
  transform category called count with one parameter as input .
  then you would use this transform in the map. (like group_by).
  bookings_pk will the input to this transform and the output of the transform
  goes to order_count in the fact. This is how you would have does in 2.1.1 and
  this is what we support in 9i.
  there is a need to start supporting aggregation operators because they will be used in maps
  made a change to support aggregation operator. aggregation operator is simulated
  as a transform edw_stand_alone.count(...) or edw_stand_alone.max(...) etc
  its import to know that we are simulating the aggregation operator as a transform
  EDW_STAND_ALONE.count(...)
  If we bring into the map a real EDW_STAND_ALONE.count(...), this will still work. that is
  because the earlier insert into edw_pvt_map_func_md will handle that
  we support ONLY ONE aggregation operator in the map!!!
  */
  l_table:=g_bis_owner||'.edw_pvt_map_func_md_T1';
  l_table2:=g_bis_owner||'.edw_pvt_map_func_md_T2';
  drop_table(l_table);
  drop_table(l_table2);
  l_stmt:='create table '||l_table||' tablespace '||g_op_table_space||' as '||
  'select map_id,map_component_id from all_iv_xform_map_components where operator_type=''Aggregation''';
  log(l_stmt);
  execute immediate l_stmt;
  log('Created with '||sql%rowcount||' rows '||get_time);
  l_stmt:='create table '||l_table2||' tablespace '||g_op_table_space||' as '||
  'select '||
  'out_param.map_id, '||
  'out_param.parameter_id out_param, '||
  'target_param.data_item_id target_column,  '||
  'target_param.parameter_id target_column_usage, '||
  'substr(out_param.transformation_expression,1,instr(out_param.transformation_expression,''('')-1) expression, '||
  'in_param.source_parameter_id in_param '||
  'from  '||
  'all_iv_xform_map_parameters out_param, '||
  'all_iv_xform_map_parameters in_param, '||
  'all_iv_xform_map_parameters target_param, '||
  'all_iv_xform_map_targets targets, '||
  l_table||' '||
  'where  '||
  l_table||'.map_id=out_param.map_id '||
  'and '||l_table||'.map_component_id=out_param.map_component_id '||
  'and '||l_table||'.map_id=in_param.map_id '||
  'and '||l_table||'.map_component_id=in_param.map_component_id '||
  'and instr(out_param.transformation_expression,''('')>0 '||
  'and out_param.position=in_param.position '||
  'and out_param.parameter_type=''OUT'' '||
  'and in_param.parameter_type=''IN'' '||
  'and target_param.map_id='||l_table||'.map_id '||
  'and target_param.map_component_id=targets.map_component_id '||
  'and targets.map_id='||l_table||'.map_id '||
  'and target_param.source_parameter_id=out_param.parameter_id ';
  log(l_stmt);
  execute immediate l_stmt;
  log('Created with '||sql%rowcount||' rows '||get_time);
  l_stmt:='insert into edw_pvt_map_func_md( '||
  'func_name, '||
  'category_name, '||
  'column_name, '||
  'column_id, '||
  'column_usage_id , '||
  'aggregation, '||
  'is_distinct, '||
  'relation_id, '||
  'relation_name, '||
  'relation_usage_id, '||
  'relation_type, '||
  'func_usage_id, '||
  'attribute_position, '||
  'func_default_value, '||
  'mapping_id '||
  ') '||
  'select '||
  l_table2||'.expression, '||
  '''EDW_STAND_ALONE'', '||
  'col.column_name, '||
  'col.column_id, '||
  'param.parameter_id, '||--column usage id
  'null, '||--aggregation
  'null, '||--is_distinct
  'rel.relation_id, '||
  'rel.relation_name, '||
  'src_usage.source_usage_id, '||
  'rel.relation_type, '||
  l_table2||'.target_column_usage function_usage_id, '||
  'rownum attribute_position, '||
  'null, '||--func_default_value
  l_table2||'.map_id '||
  'from '||
  l_table2||', '||
  'all_iv_xform_map_parameters param, '||
  'edw_pvt_columns_md col, '||
  'edw_relations_md rel, '||
  'edw_pvt_map_sources_md src_usage '||
  'where '||
  'param.parameter_id=owm_view_utilities.findsourceitemusage('||l_table2||'.in_param) '||
  'and param.map_id='||l_table2||'.map_id '||
  'and col.column_id=param.data_item_id '||
  'and rel.relation_id=col.parent_object_id '||
  'and src_usage.mapping_id='||l_table2||'.map_id '||
  'and src_usage.source_id=rel.relation_id   '||
  'union all '||
  'select '||
  l_table2||'.expression, '||
  '''EDW_STAND_ALONE'', '||
  'col.column_name, '||
  'col.column_id, '||
  l_table2||'.target_column_usage, '||
  'null, '||--aggregation
  'null, '||--is_distinct
  'rel.relation_id, '||
  'rel.relation_name, '||
  'tgt_usage.target_usage_id, '||
  'rel.relation_type, '||
  l_table2||'.target_column_usage function_usage_id, '||
  '0 attribute_position, '||
  'null, '||--default value
  l_table2||'.map_id '||
  'from '||
  l_table2||', '||
  'edw_pvt_columns_md col, '||
  'edw_relations_md rel, '||
  'edw_pvt_map_targets_md tgt_usage '||
  'where '||
  '  col.column_id='||l_table2||'.target_column '||
  'and rel.relation_id=col.parent_object_id '||
  'and tgt_usage.mapping_id='||l_table2||'.map_id '||
  'and tgt_usage.target_id=rel.relation_id ';
  log(l_stmt);
  execute immediate l_stmt;
  log('Inserted '||sql%rowcount||' rows '||get_time);
  commit;
  drop_table(l_table);
  drop_table(l_table2);
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  log('Error in populate_pvt_tables '||sqlerrm);
  return false;
End;

procedure drop_table(p_table varchar2) is
Begin
  execute immediate 'drop table '||p_table;
Exception when others then
  null;
End;

procedure analyze_all is
l_errbuf varchar2(2000);
l_retcode varchar2(200);
Begin
  log('system time is '||    fnd_date.date_to_displaydt (sysdate) );
  log('going to analyze metadata tables ');
  fnd_stats.gather_table_stats(l_errbuf, l_retcode,g_bis_owner,'EDW_ALL_COLUMNS_MD',10,1);
  fnd_stats.gather_table_stats(l_errbuf, l_retcode,g_bis_owner,'EDW_ATTRIBUTE_SETS_MD',10,1);
  fnd_stats.gather_table_stats(l_errbuf, l_retcode,g_bis_owner,'EDW_ATTRIBUTE_SET_COLUMN_MD',10,1);
  fnd_stats.gather_table_stats(l_errbuf, l_retcode,g_bis_owner,'EDW_DIMENSIONS_MD',10,1);
  fnd_stats.gather_table_stats(l_errbuf, l_retcode,g_bis_owner,'EDW_DIM_ATTRIBUTES_MD',10,1);
  fnd_stats.gather_table_stats(l_errbuf, l_retcode,g_bis_owner,'EDW_FACTS_MD',10,1);
  fnd_stats.gather_table_stats(l_errbuf, l_retcode,g_bis_owner,'EDW_FACT_ATTRIBUTES_MD',10,1);
  fnd_stats.gather_table_stats(l_errbuf, l_retcode,g_bis_owner,'EDW_FACT_DIM_RELATIONS_MD',10,1);
  fnd_stats.gather_table_stats(l_errbuf, l_retcode,g_bis_owner,'EDW_FACT_HIER_MD',10,1);
  fnd_stats.gather_table_stats(l_errbuf, l_retcode,g_bis_owner,'EDW_FOREIGN_KEYS_MD',10,1);
  fnd_stats.gather_table_stats(l_errbuf, l_retcode,g_bis_owner,'EDW_FOREIGN_KEY_COLUMNS_MD',10,1);
  fnd_stats.gather_table_stats(l_errbuf, l_retcode,g_bis_owner,'EDW_HIERARCHIES_MD',10,1);
  fnd_stats.gather_table_stats(l_errbuf, l_retcode,g_bis_owner,'EDW_HIERARCHY_LEVEL_MD',10,1);
  fnd_stats.gather_table_stats(l_errbuf, l_retcode,g_bis_owner,'EDW_LEVELS_MD',10,1);
  fnd_stats.gather_table_stats(l_errbuf, l_retcode,g_bis_owner,'EDW_LEVEL_ATTS_MD',10,1);
  fnd_stats.gather_table_stats(l_errbuf, l_retcode,g_bis_owner,'EDW_LEVEL_RELATIONS_MD',10,1);
  fnd_stats.gather_table_stats(l_errbuf, l_retcode,g_bis_owner,'EDW_LEVEL_TABLE_ATTS_MD',10,1);
  fnd_stats.gather_table_stats(l_errbuf, l_retcode,g_bis_owner,'EDW_RELATIONMAPPING_MD',10,1);
  fnd_stats.gather_table_stats(l_errbuf, l_retcode,g_bis_owner,'EDW_RELATIONS_MD',10,1);
  fnd_stats.gather_table_stats(l_errbuf, l_retcode,g_bis_owner,'EDW_TABLES_MD',10,1);
  fnd_stats.gather_table_stats(l_errbuf, l_retcode,g_bis_owner,'EDW_UNIQUE_KEYS_MD',10,1);
  fnd_stats.gather_table_stats(l_errbuf, l_retcode,g_bis_owner,'EDW_UNIQUE_KEY_COLUMNS_MD',10,1);
  ----pvt tables
  fnd_stats.gather_table_stats(l_errbuf, l_retcode,g_bis_owner,'EDW_PVT_COLUMNS_MD',10,1);
  fnd_stats.gather_table_stats(l_errbuf, l_retcode,g_bis_owner,'EDW_PVT_KEY_COLUMNS_MD',10,1);
  fnd_stats.gather_table_stats(l_errbuf, l_retcode,g_bis_owner,'EDW_PVT_LEVEL_RELATION_MD',10,1);
  fnd_stats.gather_table_stats(l_errbuf, l_retcode,g_bis_owner,'EDW_PVT_MAPPINGS_MD',10,1);
  fnd_stats.gather_table_stats(l_errbuf, l_retcode,g_bis_owner,'EDW_PVT_MAP_COLUMNS_MD',10,1);
  fnd_stats.gather_table_stats(l_errbuf, l_retcode,g_bis_owner,'edw_pvt_map_columns_tgt_md',10,1);
  fnd_stats.gather_table_stats(l_errbuf, l_retcode,g_bis_owner,'edw_pvt_map_columns_src_md',10,1);
  fnd_stats.gather_table_stats(l_errbuf, l_retcode,g_bis_owner,'EDW_PVT_MAP_FUNC_MD',10,1);
  fnd_stats.gather_table_stats(l_errbuf, l_retcode,g_bis_owner,'EDW_PVT_MAP_KEY_USAGES_MD',10,1);
  fnd_stats.gather_table_stats(l_errbuf, l_retcode,g_bis_owner,'EDW_PVT_MAP_PROPERTIES_MD',10,1);
  fnd_stats.gather_table_stats(l_errbuf, l_retcode,g_bis_owner,'EDW_PVT_MAP_SOURCES_MD',10,1);
  fnd_stats.gather_table_stats(l_errbuf, l_retcode,g_bis_owner,'EDW_PVT_MAP_TARGETS_MD',10,1);
  fnd_stats.gather_table_stats(l_errbuf, l_retcode,g_bis_owner,'EDW_PVT_SEQUENCES_MD',10,1);
  fnd_stats.gather_table_stats(l_errbuf, l_retcode,g_bis_owner,'EDW_PVT_VIEWS_MD',10,1);
  log('finish analyzing metadata tables.');
  log('system time is '||    fnd_date.date_to_displaydt (sysdate) );
Exception when others then
  log('Error in analye_all '||sqlerrm);
  null;
End;

function truncate_all return boolean is
l_stmt varchar2(4000);
Begin
  l_stmt := 'truncate table '||g_bis_owner||'.EDW_ALL_COLUMNS_MD';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  l_stmt := 'truncate table '||g_bis_owner||'.EDW_ATTRIBUTE_SETS_MD';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  l_stmt := 'truncate table '||g_bis_owner||'.EDW_ATTRIBUTE_SET_COLUMN_MD';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  l_stmt := 'truncate table '||g_bis_owner||'.EDW_DIMENSIONS_MD';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  l_stmt := 'truncate table '||g_bis_owner||'.EDW_DIM_ATTRIBUTES_MD';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  l_stmt := 'truncate table '||g_bis_owner||'.EDW_FACTS_MD';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  l_stmt := 'truncate table '||g_bis_owner||'.EDW_FACT_ATTRIBUTES_MD';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  l_stmt := 'truncate table '||g_bis_owner||'.EDW_FACT_DIM_RELATIONS_MD';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  l_stmt := 'truncate table '||g_bis_owner||'.EDW_FACT_HIER_MD';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  l_stmt := 'truncate table '||g_bis_owner||'.EDW_FOREIGN_KEYS_MD';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  l_stmt := 'truncate table '||g_bis_owner||'.EDW_FOREIGN_KEY_COLUMNS_MD';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  l_stmt := 'truncate table '||g_bis_owner||'.EDW_HIERARCHIES_MD';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  l_stmt := 'truncate table '||g_bis_owner||'.EDW_HIERARCHY_LEVEL_MD';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  l_stmt := 'truncate table '||g_bis_owner||'.EDW_LEVELS_MD';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  l_stmt := 'truncate table '||g_bis_owner||'.EDW_LEVEL_ATTS_MD';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  l_stmt := 'truncate table '||g_bis_owner||'.EDW_LEVEL_RELATIONS_MD';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  l_stmt := 'truncate table '||g_bis_owner||'.EDW_LEVEL_TABLE_ATTS_MD';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  l_stmt := 'truncate table '||g_bis_owner||'.EDW_RELATIONMAPPING_MD';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  l_stmt := 'truncate table '||g_bis_owner||'.EDW_RELATIONS_MD';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  l_stmt := 'truncate table '||g_bis_owner||'.EDW_TABLES_MD';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  l_stmt := 'truncate table '||g_bis_owner||'.EDW_UNIQUE_KEYS_MD';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  l_stmt := 'truncate table '||g_bis_owner||'.EDW_UNIQUE_KEY_COLUMNS_MD';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  l_stmt := 'truncate table '||g_bis_owner||'.EDW_PVT_COLUMNS_MD';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  l_stmt := 'truncate table '||g_bis_owner||'.EDW_PVT_KEY_COLUMNS_MD';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  l_stmt := 'truncate table '||g_bis_owner||'.EDW_PVT_LEVEL_RELATION_MD';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  l_stmt := 'truncate table '||g_bis_owner||'.EDW_PVT_MAPPINGS_MD';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  l_stmt := 'truncate table '||g_bis_owner||'.EDW_PVT_MAP_COLUMNS_MD';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  l_stmt := 'truncate table '||g_bis_owner||'.edw_pvt_map_columns_tgt_md';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  l_stmt := 'truncate table '||g_bis_owner||'.edw_pvt_map_columns_src_md';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  l_stmt := 'truncate table '||g_bis_owner||'.EDW_PVT_MAP_FUNC_MD';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  l_stmt := 'truncate table '||g_bis_owner||'.EDW_PVT_MAP_KEY_USAGES_MD';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  l_stmt := 'truncate table '||g_bis_owner||'.EDW_PVT_MAP_PROPERTIES_MD';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  l_stmt := 'truncate table '||g_bis_owner||'.EDW_PVT_MAP_SOURCES_MD';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  l_stmt := 'truncate table '||g_bis_owner||'.EDW_PVT_MAP_TARGETS_MD';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  l_stmt := 'truncate table '||g_bis_owner||'.EDW_PVT_SEQUENCES_MD';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  l_stmt := 'truncate table '||g_bis_owner||'.EDW_PVT_VIEWS_MD';
  log(l_stmt||get_time);
  execute immediate l_stmt;
  log('All tables truncated '||get_time);
  return true;
Exception when others then
  log('Error in truncate_all '||sqlerrm);
  return false;
End;

procedure open_log_file is
l_dir varchar2(2000);
Begin
  l_dir:='bis';
  l_dir:=l_dir||'.'||'edw';
  l_dir:=l_dir||'.'||'metadata_refresh';
  EDW_OWB_COLLECTION_UTIL.init_all('MD_LOAD',null,l_dir);
Exception when others then
  null;
End;

function refresh_owb_mv return boolean is
Begin
  dbms_snapshot.refresh(g_owb_schema||'.ALL_IV_XFORM_MAP_TARGETS');
  dbms_snapshot.refresh(g_owb_schema||'.ALL_IV_XFORM_MAP_SOURCES');
  return true;
Exception when others then
  log('Error in refresh_owb_mv '||sqlerrm);
  return false;
End;

END edw_metadata_refresh;

/
