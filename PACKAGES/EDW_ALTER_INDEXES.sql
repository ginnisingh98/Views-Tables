--------------------------------------------------------
--  DDL for Package EDW_ALTER_INDEXES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_ALTER_INDEXES" AUTHID CURRENT_USER AS
/* $Header: EDWINDXS.pls 115.5 2002/12/05 23:01:36 arsantha noship $*/


Procedure alterIndexes( errbuf in varchar2, retcode in number,  p_fact_name in varchar2 default null);

TYPE indexInfo is RECORD(
	columnName	VARCHAR2(50),
	indexName	VARCHAR2(50));
TYPE tab_indexes is TABLE of indexInfo
	INDEX BY BINARY_INTEGER;

CURSOR c_fact_fks(p_fact_name varchar2) IS
select
'N' name,
'N' skip
from dual;

/*
CURSOR c_fact_fks(p_fact_name varchar2) IS
select
item.name,
'N' skip
from
cmpwbcube_v fact,
cmpforeignkey_v fk,
cmpwbitemsetusage_v isu,
cmpitem_v item
where
fact.name=p_fact_name
and fk.owningrelation=fact.elementid
and isu.itemset=fk.elementid
and item.elementid=isu.attribute
and not exists
(select 1
from cmpitemset_v sis,
cmpwbitemsetusage_v pisu
where sis.owningrelation=fact.elementid
and sis.name='SKIP_LOAD_SET'
and sis.disabled=0
and pisu.itemset=sis.elementid
and item.elementid=pisu.attribute)
UNION ALL
select item.name,
'Y' skip
from cmpitemset_v sis,
cmpwbitemsetusage_v isu,
cmpitem_v item,
cmpwbcube_v rel
where rel.name=p_fact_name
and sis.owningrelation=rel.elementid
and sis.name='SKIP_LOAD_SET'
and sis.disabled=0
and isu.itemset=sis.elementid
and item.elementid=isu.attribute;
*/

TYPE tab_fact_fks is TABLE of c_fact_fks%ROWTYPE
	INDEX BY BINARY_INTEGER;

g_indexes tab_indexes ;

end edw_alter_indexes;

 

/
