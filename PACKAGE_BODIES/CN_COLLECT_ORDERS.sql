--------------------------------------------------------
--  DDL for Package Body CN_COLLECT_ORDERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_COLLECT_ORDERS" AS
-- $Header: cncooeb.pls 120.2 2006/01/18 03:52:40 apink noship $

cached_org_id                INTEGER;
cached_org_append            VARCHAR2(100);

PROCEDURE get_org_append(x_org_id IN number)
IS

BEGIN
  cached_org_id := x_org_id;

  IF cached_org_id=NULL OR cached_org_id=0 OR cached_org_id=-1 THEN
    cached_org_id := mo_global.get_current_org_id;
  END IF;

  IF cached_org_id = -99
  THEN
     cached_org_append := '_M99';
  ELSE
     cached_org_append := '_' || cached_org_id;
  END IF;
END get_org_append;

PROCEDURE COLLECT (errbuf OUT NOCOPY VARCHAR2,
		   retcode OUT NOCOPY NUMBER,
		   x_start_period_name IN VARCHAR2,
		   x_end_period_name IN VARCHAR2
		   )  IS

  dummy_vch             VARCHAR2(2);
  dummy_num             NUMBER;
  c			            INTEGER;
  rows_processed	    INTEGER;
  STATEMENT		        VARCHAR2(1000);
  x_org_id              NUMBER;

BEGIN

  c := dbms_sql.open_cursor;

  x_org_id := mo_global.get_current_org_id;

  get_org_append(x_org_id);

  STATEMENT := 'begin CN_COLLECT_ORDERS'||cached_org_append||
    '.collect(:err,:ret,:start,:end,:orgid); end;';

  dbms_sql.parse(c, STATEMENT, dbms_sql.native);

  dbms_sql.bind_variable(c,'err', dummy_vch, 30);
  dbms_sql.bind_variable(c,'ret', dummy_num);
  dbms_sql.bind_variable(c,'start', x_start_period_name);
  dbms_sql.bind_variable(c,'end', x_end_period_name);
  dbms_sql.bind_variable(c,'orgid',x_org_id);

  rows_processed := dbms_sql.EXECUTE(c);

  dbms_sql.variable_value(c,'err', errbuf);
  dbms_sql.variable_value(c,'ret', retcode);

  dbms_sql.close_cursor(c);

END COLLECT;


END cn_collect_orders;

/
