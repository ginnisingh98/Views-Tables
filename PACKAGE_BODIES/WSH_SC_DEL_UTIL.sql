--------------------------------------------------------
--  DDL for Package Body WSH_SC_DEL_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_SC_DEL_UTIL" as
/* $Header: WSHSDUTB.pls 115.2 99/07/16 08:21:34 porting ship $ */

-------------------------------------------------------------------
-- WSH_SC_DEL_UTIL
-- Purpose
--      Execute Mass Change
-- History
--      04-MAR-98 mgunawar Created
--
-------------------------------------------------------------------

PROCEDURE EXEC_MASS_CHANGE(statement varchar2, records_updated in out number) AS
	cursor_name INTEGER;
	rows_processed number;
BEGIN
	     cursor_name := DBMS_SQL.OPEN_CURSOR;
	     DBMS_SQL.PARSE(cursor_name, statement, DBMS_SQL.v7);

	     rows_processed := DBMS_SQL.EXECUTE(cursor_name);
	     records_updated := rows_processed;

	     DBMS_SQL.CLOSE_CURSOR(cursor_name);
EXCEPTION
	when others then
	     dbms_sql.close_cursor(cursor_name);
END;


FUNCTION Request_Id return NUMBER
IS
	id number;
BEGIN

	SELECT wsh_deliveries_interface_s.nextval INTO id
	       FROM Dual;

	return(id);

END;


end  WSH_SC_DEL_UTIL;

/
