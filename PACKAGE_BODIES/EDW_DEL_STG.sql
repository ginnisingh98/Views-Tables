--------------------------------------------------------
--  DDL for Package Body EDW_DEL_STG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_DEL_STG" AS
/* $Header: EDWDELB.pls 120.1 2005/08/11 04:40:35 aguwalan noship $*/
g_dummy         VARCHAR2(30);
g_dummy_int     NUMBER;
cid             NUMBER;
l_fact      BOOLEAN := TRUE;
g_errbuf varchar2(200) := null;
g_retcode number := 0;
g_name varchar2(100) := null;

/* cursor alldimm is
select
dim.name dim_name
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
select cube.name fact_name
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



cursor factt(p_fact_name varchar2) is
select  relation.relation_name table_name
from  edw_relations_md_v relation,
      edw_relationmapping_md_v map,
      edw_relations_md_v lvl_relation
where lvl_relation.relation_long_name=p_fact_name
 and map.targetdataentity=lvl_relation.relation_id
 and relation.relation_id=map.sourcedataentity;


Procedure Delete_Table(p_stg_name in varchar2) IS
l_count NUMBER:=0;
TYPE curType IS REF CURSOR ;
del_cur curType;
l_stmt varchar2(1000);
BEGIN
	begin
           cid := DBMS_SQL.open_cursor;

       DBMS_SQL.PARSE(cid, 'DELETE FROM '||p_stg_name||
        ' WHERE nvl(COLLECTION_STATUS, ''ERROR'') = ''COLLECTED'' OR nvl(COLLECTION_STATUS, ''ERROR'') =''DUPLICATE-COLLECT''', dbms_sql.native);


           g_dummy_int:=DBMS_SQL.EXECUTE(cid);
           EXCEPTION
                   when others then
                g_errbuf := sqlerrm;
                g_retcode := -1;
        end;
        begin
        DBMS_SQL.PARSE(cid, 'LOCK TABLE '||p_stg_name
                ||' IN EXCLUSIVE MODE NOWAIT', dbms_sql.native);
        g_dummy_int:=DBMS_SQL.EXECUTE(cid);

	begin
          l_stmt := 'select /*+ FIRST_ROWS */ 1 from '|| p_stg_name ||' where rownum=1';
          open del_cur for l_stmt;
          fetch del_cur into g_dummy_int;
          if (del_cur%NotFound) then
            l_stmt := 'TRUNCATE TABLE '|| p_stg_name ||' DROP STORAGE';
            execute immediate l_stmt;
            commit;
          end if;
          close del_cur;
        end;
	EXCEPTION when others then
		 g_errbuf := sqlerrm;
		commit;
	end;

	IF DBMS_SQL.IS_OPEN(cid)  THEN
		DBMS_SQL.CLOSE_CURSOR(cid);
	END IF;
END;

Procedure Delete_Dimension(Errbuf in out NOCOPY varchar2, Retcode in out NOCOPY varchar2, p_dim_name in varchar2, p_purge_option in number) IS
l_mode number;
BEGIN
	l_mode:=p_purge_option;
   	if l_mode is null then
    		l_mode:=0;  -- 0 for delete, 1 for truncate
  	end if;
	edw_log.put_line('Dimension name is '||p_dim_name);

        IF (l_mode=0) THEN
	    edw_log.put_line('Deleting loaded records in interface tables');
	        IF (p_dim_name IS NULL) THEN
        	        Delete_All_Dimensions;
		ELSE
			Delete_One_Dimension(p_dim_name);
        	END IF;
	ELSE
	    edw_log.put_line('Truncating interface tables');
		IF (p_dim_name IS NULL) THEN
        	        EDW_TRUNC_STG.Truncate_All_Dimensions;
		ELSE
			EDW_TRUNC_STG.Truncate_One_Dimension(p_dim_name);
        	END IF;
	END IF;
END;

Procedure Delete_One_Dimension(p_dim_name in varchar2) IS

BEGIN

	/* delete from the level staging tables */
	edw_log.put_line('Deleting staging tables for '||p_dim_name);
	FOR r1 IN dimm(p_dim_name) LOOP
       		Delete_Table(r1.table_name);
		edw_log.put_line('Deleted staging table '||r1.table_name);
	END LOOP;
END;

Procedure Delete_All_Dimensions IS
BEGIN
        for r1 in alldimm loop
                Delete_One_Dimension(r1.dim_name);
        end loop;
END;


Procedure Delete_Fact(Errbuf in out NOCOPY varchar2, Retcode in out NOCOPY varchar2, p_fact_name in varchar2, p_purge_option in number) IS
l_mode number;
l_staging_table varchar2(120) := null;
BEGIN
        l_mode:=p_purge_option;
        if l_mode is null then
                l_mode:=0;
		   -- 0 for delete loaded recods, 1 for truncate all records
        end if;
        edw_log.put_line('Fact name is '||p_fact_name);

        IF (l_mode=0) THEN
	    edw_log.put_line('Deleting loaded records in interface tables');
	        IF (p_fact_name IS NULL) THEN
        	        Delete_All_Facts;
		ELSE
			Delete_One_fact(p_fact_name);
	        END IF;
        ELSE
	    edw_log.put_line('Truncating interface tables');
                IF (p_fact_name IS NULL) THEN
                        EDW_TRUNC_STG.Truncate_All_Facts;
                ELSE
                        EDW_TRUNC_STG.Truncate_One_Fact(p_fact_name);
                END IF;
        END IF;


END;

Procedure Delete_One_Fact(p_fact_name in varchar2) IS
l_staging_table varchar2(120) := null;
BEGIN
       edw_log.put_line('Deleting staging tables for '||p_fact_name);
	open factt(p_fact_name);
	fetch factt into l_staging_table;
	close factt;
	Delete_Table(l_staging_table);
	edw_log.put_line('Deleted staging table '||l_staging_table);

END;


Procedure Delete_All_Facts IS
BEGIN
	for r1 in allfactt loop
        	Delete_One_Fact(r1.fact_name);
	end loop;

END;

End EDW_DEL_STG;

/
