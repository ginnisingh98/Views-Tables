--------------------------------------------------------
--  DDL for Package Body EDW_TRUNC_STG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_TRUNC_STG" AS
/* $Header: EDWTRCTB.pls 115.10 2004/02/13 05:06:25 smulye noship $*/
g_dummy         VARCHAR2(30);
g_dummy_int     NUMBER;
cid             NUMBER;
l_fact      BOOLEAN := TRUE;
g_errbuf varchar2(200) := null;
g_retcode number := 0;
g_name varchar2(100) := null;


/* cursor alldimm is
select
dim.longname dim_name
from
cmprelationmapping_v  dim_map,
cmpwbdimension_v  dim
where
dim_map.targetdataentity=dim.elementid; */

cursor alldimm is
select
dim.dim_long_name dim_name
from edw_relationmapping_md_v  dim_map,
  edw_dimensions_md_v  dim
where dim_map.targetdataentity=dim.dim_id;

/* cursor dimm(p_dim_name varchar2) is
select
src_relation.name table_name
from
cmprelation_v relation,
cmprelation_v src_relation,
cmprelationmapping_v dim_map,
cmprelationmapping_v lvl_map,
cmpwbrelationusage_v dim_ru,
cmpwbdimension_v dim
where
dim.longname=rtrim(p_dim_name)
and dim_map.targetdataentity=dim.elementid
and dim_ru.cmprelationmapping=dim_map.elementid
and dim_ru.source=1
and relation.elementid=dim_ru.cmprelation
and relation.classname='CMPWBTable'
and lvl_map.targetdataentity=relation.elementid
and src_relation.elementid=lvl_map.sourcedataentity; */

cursor dimm(p_dim_name varchar2) is
select lstg.relation_name  table_name
from edw_relations_md_v ltc,edw_relations_md_v lstg,
     edw_relationmapping_md_v map,edw_dimensions_md_v dim,
     edw_levels_md_v lvl
where dim.dim_long_name=p_dim_name
 and lvl.dim_id=dim.dim_id
 and ltc.relation_name=lvl.level_name||'_LTC'
 and map.targetdataentity=ltc.relation_id
 and lstg.relation_id=map.sourcedataentity;


/* cursor allfactt is
select cube.longname fact_name
from cmprelationmapping_v map,
cmpwbcube_v cube
where cube.elementid = map.targetdataentity; */

/**cursor allfactt is
select cube.fact_longname fact_name
from edw_relationmapping_md_v map,edw_facts_md_v cube
where cube.fact_id = map.targetdataentity;**/

----fix bug 2109920.Exclude derived facts from the fact list---
cursor allfactt is
select cube1.fact_longname fact_name
from edw_relationmapping_md_v map1,edw_facts_md_v cube1
where cube1.fact_id = map1.targetdataentity
and  cube1.fact_longname not in
(select distinct cube.fact_longname
from
edw_facts_md_v cube,
edw_facts_md_v cube_src,
edw_relationmapping_md_v map where
map.targetdataentity=cube.fact_id
and map.sourcedataentity=cube_src.fact_id);


/* cursor factt(p_fact_name varchar2) is
select
  relation.name table_name
from
  cmprelation_v relation,
  cmprelationmapping_v map,
  cmprelation_v lvl_relation
where
lvl_relation.longname=rtrim(p_fact_name)
and map.targetdataentity=lvl_relation.elementid
and relation.elementid=map.sourcedataentity; */
cursor factt(p_fact_name varchar2) is
select  relation.relation_name table_name
from  edw_relations_md_v relation,
      edw_relationmapping_md_v map,
      edw_relations_md_v lvl_relation
where lvl_relation.relation_long_name=p_fact_name
 and map.targetdataentity=lvl_relation.relation_id
 and relation.relation_id=map.sourcedataentity;


cursor table_owner(p_tab_name varchar2) is
select
table_owner
from user_synonyms
where table_name=p_tab_name;

Procedure truncate_Table(p_stg_name in varchar2) IS
l_count NUMBER:=0;
l_owner varchar2(10);
begin
      open table_owner(p_stg_name);
      fetch table_owner into l_owner;
      if table_owner%notfound then
           null;
      end if;
      close table_owner;
       edw_log.put_line('owner '||l_owner);
         edw_log.put_line('staging '||p_stg_name);
      if l_owner is not null  then
           cid := DBMS_SQL.open_cursor;
	   DBMS_SQL.PARSE(cid, 'truncate table '||l_owner||'.'||p_stg_name||' drop storage', dbms_sql.native);
           g_dummy_int:=DBMS_SQL.EXECUTE(cid);
           commit;
      end if;
EXCEPTION
        when others then
                g_errbuf := sqlerrm;
                g_retcode := -1;
end;



Procedure truncate_Dimension(Errbuf in out NOCOPY varchar2, Retcode in out NOCOPY varchar2, p_dim_name in varchar2) IS

BEGIN
   edw_log.put_line('Dimension name is '||p_dim_name);
   IF (p_dim_name IS NULL) THEN
                truncate_All_Dimensions;
   ELSE
		truncate_One_Dimension(p_dim_name);
   END IF;
END;

Procedure truncate_One_Dimension(p_dim_name in varchar2) IS
BEGIN
	/* truncate  the level staging tables */
	edw_log.put_line('Truncating staging tables for '||p_dim_name);
	FOR r1 IN dimm(p_dim_name) LOOP
       		truncate_Table(r1.table_name);
	    	edw_log.put_line('Truncated staging table '||r1.table_name);
	END LOOP;
END;

Procedure truncate_All_Dimensions IS
BEGIN
        for r1 in alldimm loop
                truncate_One_Dimension(r1.dim_name);
        end loop;
END;


Procedure truncate_Fact(Errbuf in out NOCOPY varchar2, Retcode in out NOCOPY varchar2, p_fact_name in varchar2) IS
l_staging_table varchar2(120) := null;
BEGIN
        IF (p_fact_name IS NULL) THEN
                truncate_All_Facts;
	ELSE
		truncate_One_fact(p_fact_name);
        END IF;

END;

Procedure truncate_One_Fact(p_fact_name in varchar2) IS
l_staging_table varchar2(120) := null;
BEGIN
	open factt(p_fact_name);
	fetch factt into l_staging_table;
	close factt;
    edw_log.put_line('Truncating staging tables for '||p_fact_name);
	truncate_Table(l_staging_table);
    edw_log.put_line('Truncated staging table '||l_staging_table);
END;


Procedure truncate_All_Facts IS
BEGIN
	for r1 in allfactt loop
        	truncate_One_Fact(r1.fact_name);
	end loop;

END;

END; -- Package Body EDW_TRUNC_STG

/
