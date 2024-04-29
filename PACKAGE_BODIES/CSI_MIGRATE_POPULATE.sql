--------------------------------------------------------
--  DDL for Package Body CSI_MIGRATE_POPULATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_MIGRATE_POPULATE" AS
/* $Header: csipopdb.pls 115.5 2003/08/25 17:36:32 epajaril ship $ */

PROCEDURE Build_Parse(p_values in varchar) IS
   v_num_of_rows        number;
   v_cursor_handle      PLS_INTEGER := dbms_sql.open_cursor;
   v_statement          varchar2(240);
BEGIN
   v_statement := p_values;

   dbms_sql.parse(v_cursor_handle, v_statement, dbms_sql.native);

   v_num_of_rows := dbms_sql.execute(v_cursor_handle);
   dbms_sql.close_cursor(v_cursor_handle);
END;
END CSI_MIGRATE_POPULATE;

/
