--------------------------------------------------------
--  DDL for Package Body CN_COLLECT_CLAWBACKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_COLLECT_CLAWBACKS" AS
-- $Header: cncocbkb.pls 120.2 2006/01/19 03:56:26 apink noship $


compile_error EXCEPTION;
PRAGMA EXCEPTION_INIT(compile_error, -6550);

-- cached_org_id and cached_org_append

cached_org_id                integer;
cached_org_append            varchar2(100);

/* private procedures */

/*
PROCEDURE std_other_error( cursor_id in out nocopy number,
                           sql_statement in varchar2 ) IS
stmt_len integer;
loop_var integer;

BEGIN
  dbms_sql.close_cursor(cursor_id);

  dbms_output.put_line('--');
  dbms_output.put_line('SQL statement that failed is:');

  stmt_len := length(sql_statement);

  if stmt_len > 255 then
    loop_var := 1;
    while loop_var <= stmt_len loop
      dbms_output.put_line(substr(sql_statement,loop_var,80));
      loop_var := loop_var + 80;
    end loop;
  else
    dbms_output.put_line(sql_statement);
  end if;

  dbms_output.put_line('--');
END std_other_error;


PROCEDURE std_compile_error( cursor_id in out nocopy number,
                             sql_statement in varchar2 ) IS

BEGIN

  dbms_output.put_line('Error: Package cn_collect_clawbacks'||cached_org_append||' is probably missing');
  if cached_org_id = -99 then
    dbms_output.put_line('Org ID is not defined (set to -99)');
  else
    dbms_output.put_line('Org ID is: '||cached_org_id);
  end if;

  std_other_error(cursor_id, sql_statement);

--   arp_standard.fnd_message('AR_ADDS_NOT_INSTALLED');
END std_compile_error;
*/
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


--
-- Procedure Name
--   collect
-- Purpose
--   This procedure is the router for collecting clawbacks
--
-- History
--   02-Jan-97	Jcheng	Router Procedure for collecting clawbacks
--


PROCEDURE collect (errbuf OUT NOCOPY VARCHAR2,
		   retcode OUT NOCOPY NUMBER,
		   x_start_period_name IN VARCHAR2,
		   x_end_period_name IN VARCHAR2
           )  IS

  dummy_vch             varchar2(2);
  dummy_num             number;
  c			            integer;
  rows_processed	    integer;
  statement		        varchar2(1000);
  x_org_id              NUMBER;

begin

  c := dbms_sql.open_cursor;

  x_org_id := mo_global.get_current_org_id;

  get_org_append(x_org_id);

  statement := 'begin cn_collect_clawbacks'||cached_org_append||
    '.collect(:err,:ret,:start,:end,:orgid); end;';

  dbms_sql.parse(c, statement, dbms_sql.native);

  dbms_sql.bind_variable(c,'err', dummy_vch, 30);
  dbms_sql.bind_variable(c,'ret', dummy_num);
  dbms_sql.bind_variable(c,'start', x_start_period_name);
  dbms_sql.bind_variable(c,'end', x_end_period_name);
  dbms_sql.bind_variable(c,'orgid', x_org_id);

  rows_processed := dbms_sql.execute(c);

  dbms_sql.variable_value(c,'err', errbuf);
  dbms_sql.variable_value(c,'ret', retcode);

  dbms_sql.close_cursor(c);

--exception
--    when compile_error then
--      std_compile_error(c, statement);
--    when others then
--      std_other_error(c, statement);
--      raise;
end collect;

BEGIN

/* global package initialization */

  select
    NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL,
                         SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)
  into cached_org_id
  from dual;

  if cached_org_id = -99 then
    cached_org_append := '_M99';
  else
    cached_org_append := '_' || cached_org_id;
  end if;

END cn_collect_clawbacks;

/
