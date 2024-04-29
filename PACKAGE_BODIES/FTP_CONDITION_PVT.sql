--------------------------------------------------------
--  DDL for Package Body FTP_CONDITION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTP_CONDITION_PVT" AS
/* $Header: ftpcondb.pls 120.1 2006/08/24 14:42:14 ashukuma noship $ */


/**
  * Function to get object_id from fnd_objects goven a object name.
  * @param     p_object_name    Object Name
  * @return    object_id      Object Identifier
  */
FUNCTION get_dim_member_name(p_dimension_id IN NUMBER, p_member_id IN VARCHAR2)
  RETURN VARCHAR2 IS
  l_member_table    fem_xdim_dimensions.member_vl_object_name%TYPE;
  l_member_id_col   fem_xdim_dimensions.member_col%TYPE;
  l_member_name_col fem_xdim_dimensions.member_name_col%TYPE;
  l_member_name     VARCHAR2(150);
  l_select_stmt     VARCHAR2(500);
  l_cursor_id       INTEGER;
  l_Dummy           INTEGER;
BEGIN
  -- Open the cursor for processing.
  l_cursor_id := DBMS_SQL.OPEN_CURSOR;

  -- Create the query string.
  SELECT member_vl_object_name, member_col, member_name_col
  INTO l_member_table, l_member_id_col, l_member_name_col
  FROM fem_xdim_dimensions
  WHERE dimension_id = p_dimension_id;

  l_select_stmt := 'SELECT ' || l_member_name_col ||
                   ' FROM '  || l_member_table ||
                   ' WHERE ' || l_member_id_col || '=:member_id';

  -- Parse the statement
  DBMS_SQL.PARSE(l_cursor_id, l_select_stmt, DBMS_SQL.NATIVE);

  -- Bind the input variables.
  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':member_id', p_member_id);

  -- Define the select list items.
  DBMS_SQL.DEFINE_COLUMN(l_cursor_id, 1, l_member_name, 150);

  l_Dummy := DBMS_SQL.EXECUTE(l_cursor_id);

  IF DBMS_SQL.FETCH_ROWS(l_cursor_id) = 0 THEN
    RETURN null;
  ELSE
    DBMS_SQL.COLUMN_VALUE(l_cursor_id, 1, l_member_name);
  END IF;
DBMS_SQL.CLOSE_CURSOR (l_cursor_id );
  RETURN l_member_name;
END;


END;

/
