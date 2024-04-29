--------------------------------------------------------
--  DDL for Package Body BIS_INIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_INIT" as
/* $Header: EDWINITB.pls 120.0 2005/06/01 17:23:18 appldev noship $*/

-- This is initialization procedure for BIS/EDW

PROCEDURE initialize IS

--  PRAGMA AUTONOMOUS_TRANSACTION;

  sql_stmt			varchar2(2000);
  x_step			varchar2(50);
  v_Errorcode                   number;
  v_ErrorText                   varchar2(200);

  sorc_records                  number := 0;
  wh_records                    number := 0;

  impl_type			varchar2(30);

  --added fro bug 3871867
  l_dummy1                      varchar2(32);
  l_dummy2                      varchar2(32);
  l_schema                      varchar2(32);
BEGIN

--Get the schema name from an FND API bug 3871867
if FND_INSTALLATION.GET_APP_INFO('BIS',l_dummy1,l_dummy2,l_schema) = false then
    l_schema := 'BIS';
end if;

-- Identify if DBI env

impl_type := FND_PROFILE.VALUE('BIS_IMPLEMENTATION_TYPE');

IF ( impl_type = 'OLTP') THEN

	null;

ELSE


-- Identify if instance is source or/and warehouse

-- Check if source

  select count(*) into sorc_records from dba_tables
  where owner = l_schema  --bug 3871867
  and table_name = 'EDW_LOCAL_INSTANCE';

  IF sorc_records > 0 THEN
	sql_stmt := 'select count(*) from edw_local_instance';
	EXECUTE IMMEDIATE sql_stmt into sorc_records;
  END IF;


-- Check if warehouse

  select count(*) into wh_records from dba_tables
  where owner = l_schema    --bug 3871867
  and table_name = 'EDW_SOURCE_INSTANCES';

  IF wh_records > 0 THEN
        sql_stmt := 'select count(*) from edw_source_instances';
	EXECUTE IMMEDIATE sql_stmt into wh_records;
  END IF;


  x_step := 'set_global_names_false';

  IF sorc_records > 0 THEN
        -- Set Global_names to false
        sql_stmt := ' ALTER SESSION SET global_names = false';
	EXECUTE IMMEDIATE sql_stmt;
  END IF;

  x_step := 'set_security_context';

  IF wh_records > 0 THEN
        -- Set context attributes for EDW Security
        sql_stmt := 'BEGIN edw_sec_pkg.set_context; END;';
        EXECUTE IMMEDIATE sql_stmt;
  END IF;

END IF;

EXCEPTION

  WHEN OTHERS THEN
	v_ErrorCode := SQLCODE;
	v_ErrorText := SUBSTR(SQLERRM, 1, 200);

--	Log error message into edw_error_log table

        insert into edw_error_log
        (object_name, object_type, resp_id, message,
        last_update_date, last_updated_by, creation_date, created_by, last_update_login)
        values
        ('BIS_INIT.INITIALIZE', 'BIS/EDW Initialization Procedure', NULL,
	'Oracle error occured in edw_init.initialize procedure at step : '|| x_step
         || '. Errorcode is : ' || v_ErrorCode || ' and Errortext is : ' || v_ErrorText,
        sysdate, 0, sysdate, 0, 0);
        commit;

-- Pass on control to FND_GLOBAL.INIT

        RAISE;

END initialize;

END bis_init;

/
