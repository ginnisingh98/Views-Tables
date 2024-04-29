--------------------------------------------------------
--  DDL for Package Body OKE_AUTHORING_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_AUTHORING_UTILS" AS
/* $Header: OKEAUTLB.pls 115.0 2004/05/14 20:11:43 who noship $ */



  FUNCTION COLUMN_EXISTS
  ( p_object_code VARCHAR2
  , p_column_name VARCHAR2
  ) RETURN BOOLEAN IS
    l_view_name varchar2(200);
    l_found NUMBER;
    i NUMBER;

    Cursor l_jtfv_csr Is
      SELECT from_table
      FROM jtf_objects_vl
      WHERE object_code = p_object_code
      AND sysdate between nvl(start_date_active , sysdate-1)
                  and     nvl(end_date_active , sysdate+1);

    Cursor l_jtf_source_csr Is
        SELECT 1 FROM USER_TAB_COLUMNS
        WHERE table_name = l_view_name
        AND column_name = p_column_name;

  BEGIN
    open l_jtfv_csr;
    fetch l_jtfv_csr into l_view_name;
    close l_jtfv_csr;

    -- Trim any space and character after that
    i := INSTR(l_view_name,' ');
    If (i > 0) Then
        l_view_name := substr(l_view_name,1,i - 1);
    End If;

    open l_jtf_source_csr;
    fetch l_jtf_source_csr into l_found;
    close l_jtf_source_csr;
    If (l_found = 1) Then
        return TRUE;
    Else
        return FALSE;
    End If;
  EXCEPTION
    when NO_DATA_FOUND Then
      If (l_jtfv_csr%ISOPEN) Then
    close l_jtfv_csr;
      End If;
      If (l_jtf_source_csr%ISOPEN) Then
    close l_jtf_source_csr;
      End If;
      return FALSE;

    when OTHERS then
      If (l_jtfv_csr%ISOPEN) Then
    close l_jtfv_csr;
      End If;
      If (l_jtf_source_csr%ISOPEN) Then
    close l_jtf_source_csr;
      End If;
      return FALSE;
  END;

/** this part of the code attempts to retrieve party_id from
    the parent party role **/

FUNCTION Retrieve_Party_ID (P_jtot_object_code IN   VARCHAR2,
			    P_object_id1       IN   VARCHAR2,
			    P_object_id2       IN   VARCHAR2) return VARCHAR2
IS

i		NUMBER;
l_sql_stmt 	VARCHAR2(1000);
v_cursorID		INTEGER;
v_party_id		VARCHAR2(100) := '00';
v_dummy			INTEGER;

BEGIN


	l_sql_stmt := OKC_UTIL.GET_SQL_FROM_JTFV(P_jtot_object_code);

	IF l_sql_stmt is null THEN
	  return '-1';
	END IF;

	IF (column_exists(p_jtot_object_code,'PARTY_ID')) THEN

        i := INSTR(l_sql_stmt,'WHERE');
        If (i > 0) Then
           l_sql_stmt := SUBSTR(l_sql_stmt,1, i + 5) ||
         ' ID1 = ' ||''''|| P_OBJECT_ID1 ||''''|| ' AND ' ||
	 ' ID2 = ' ||''''|| P_OBJECT_ID2 ||'''';
-- || ' AND ' ||
--          SUBSTR(l_sql_stmt,i + 5);
        Else
           -- no where clause. Add before ORDER BY if any
           i := INSTR(l_sql_stmt,'ORDER BY');
           If (i > 0) Then
            l_sql_stmt := SUBSTR(l_sql_stmt,1,i-1) ||
            ' WHERE ID1 = ' ||''''|| P_OBJECT_ID1 ||''''|| ' AND '||
	    ' ID2 = ' ||''''|| P_OBJECT_ID2 ||''''||
            ' ' || SUBSTR(l_sql_stmt,i);
           Else
        -- no where and no order by
        l_sql_stmt := l_sql_stmt || ' WHERE ID1 = '||''''|| P_OBJECT_ID1 ||''''
		|| ' AND '|| ' ID2 = '||'''' || P_OBJECT_ID2 ||'''';
           End If;
        End If;

	END IF;

	l_sql_stmt := 'SELECT PARTY_ID FROM '|| l_sql_stmt;

	v_cursorID := DBMS_SQL.OPEN_CURSOR;
	dbms_output.put_line(l_sql_stmt);
	DBMS_SQL.PARSE(v_cursorID,l_sql_stmt,dbms_sql.native);
	DBMS_SQL.DEFINE_COLUMN(v_cursorID,1,v_party_id,100);
	v_dummy := DBMS_SQL.EXECUTE(v_cursorID);
	IF DBMS_SQL.FETCH_ROWS(v_cursorID)= 0 THEN
	 RETURN '-1';
	END IF;
	DBMS_SQL.COLUMN_VALUE(v_cursorID,1,v_party_id);
	DBMS_SQL.CLOSE_CURSOR(v_cursorID);

	return v_party_id;

EXCEPTION
  WHEN OTHERS THEN
    RETURN '-1';

END;


END OKE_AUTHORING_UTILS;

/
