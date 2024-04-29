--------------------------------------------------------
--  DDL for Package Body CN_COLLECT_CUSTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_COLLECT_CUSTOM" AS
-- $Header: cncocub.pls 120.6 2006/01/18 03:45:51 apink noship $

--
-- Procedure Name
--   collect
-- Purpose
--   This procedure calls the correct collections package for the
--   specified data source
--
-- History
--   03-Apr-00       D.Maskell       Created
--


PROCEDURE collect (x_errbuf     OUT NOCOPY VARCHAR2,
		         x_retcode      OUT NOCOPY NUMBER,
		         p_table_map_id IN NUMBER
                  ) -- Added as part of MOAC Changes
                 IS

  package_name      cn_objects.name%TYPE;
  dummy_vch         VARCHAR2(2);
  dummy_num         NUMBER;
  c                 INTEGER;
  rows_processed    INTEGER;
  statement         VARCHAR2(1000);
  x_org_id          NUMBER;


BEGIN

  x_org_id := mo_global.get_current_org_id;

  --+
  -- Get the name of the collection package
  --+
  MO_GLOBAL.SET_POLICY_CONTEXT ('S',x_org_id);
  SELECT OBJ.name
  INTO   package_name
  FROM   cn_table_map_objects tmov, cn_objects obj
  WHERE  tmov.table_map_id = p_table_map_id
  and obj.object_id = tmov.object_id
         AND tmov.tm_object_type = 'PKS'
         and tmov.org_id = obj.org_id
         AND tmov.org_id = x_org_id;
  --+
  -- Construct the call to the collect procedure of the package
  --+
  statement := 'BEGIN '||package_name||'.collect(:err,:ret,:orgid); END;';
--dbms_output.put_line('cn_collect_custom: Procedure Call = '||statement);

  --+
  -- Use dynamic SQL to run the statement
  --+
  c := dbms_sql.open_cursor;

  dbms_sql.parse(c, statement, dbms_sql.native);

  dbms_sql.bind_variable(c,'err', dummy_vch, 30);
  dbms_sql.bind_variable(c,'ret', dummy_num);
  dbms_sql.bind_variable(c,'orgid', x_org_id);

  rows_processed := dbms_sql.execute(c);

  dbms_sql.variable_value(c,'err', x_errbuf);
  dbms_sql.variable_value(c,'ret', x_retcode);

  dbms_sql.close_cursor(c);

END collect;

END cn_collect_custom;

/
