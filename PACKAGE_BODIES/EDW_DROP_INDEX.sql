--------------------------------------------------------
--  DDL for Package Body EDW_DROP_INDEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_DROP_INDEX" AS
/* $Header: EDWDRNDB.pls 115.2 2002/12/06 01:49:26 jwen noship $*/

procedure edw_drop_btree_ind (owner VARCHAR2, table_name VARCHAR2) IS
x_index_name	varchar(30);
sql_stmt	varchar(2000);
cur_stmt	varchar2(2000);
x_table_name	varchar2(30);
x_owner		varchar2(30);

TYPE IndexCurType is REF CURSOR;
ind_cv	IndexCurType;

BEGIN

x_table_name := UPPER(table_name);
x_owner := UPPER(owner);

cur_stmt := 'SELECT index_name FROM dba_indexes
where index_type = ''NORMAL''
and uniqueness = ''NONUNIQUE''
and owner = :x_owner
and table_name =:x_table_name';

OPEN ind_cv FOR cur_stmt USING x_owner, x_table_name;

LOOP
	FETCH ind_cv INTO x_index_name;
	EXIT WHEN ind_cv%NOTFOUND;
	sql_stmt := 'drop index '|| x_owner ||'.'|| x_index_name ;
	execute immediate sql_stmt;
END LOOP;

CLOSE ind_cv;

EXCEPTION
	WHEN OTHERS THEN NULL;

END;

END EDW_DROP_INDEX;

/
