--------------------------------------------------------
--  DDL for Package Body LNS_LOAN_HISTORY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_LOAN_HISTORY_PUB" AS
/* $Header: LNS_LNHIS_PUBP_B.pls 120.0 2005/05/31 17:58:27 appldev noship $ */
procedure get_record_snapshot(p_id NUMBER, p_primary_key_name VARCHAR2, p_table_name VARCHAR2, p_mode VARCHAR2) AS

	l_select_col_stmt	VARCHAR2(4000);
	l_select_val_stmt	VARCHAR2(4000);
	l_cursorID	INTEGER;
	l_cursorID2	INTEGER;
	l_column_name	DBA_TAB_COLUMNS.column_name%TYPE;
	l_data_type	DBA_TAB_COLUMNS.data_type%TYPE;
	l_dummy		INTEGER;
	l_index		NUMBER;

BEGIN
	l_cursorID := DBMS_SQL.OPEN_CURSOR;

	l_select_col_stmt := 'select column_name, data_type from dba_tab_columns' || ' where table_name = :tab_name and owner = ''LNS'' order by column_id';

	l_select_val_stmt := 'select';

	DBMS_SQL.PARSE(l_cursorID, l_select_col_stmt, DBMS_SQL.V7);
	DBMS_SQL.BIND_VARIABLE(l_cursorID, ':tab_name', p_table_name);

	DBMS_SQL.DEFINE_COLUMN(l_cursorID, 1, l_column_name, 30);
	DBMS_SQL.DEFINE_COLUMN(l_cursorID, 2, l_data_type, 106);

	l_dummy := DBMS_SQL.EXECUTE(l_cursorID);

	l_index := 1;
	LOOP
	  IF DBMS_SQL.FETCH_ROWS(l_cursorID) = 0 THEN
	    EXIT;
	  END IF;

	  DBMS_SQL.COLUMN_VALUE(l_cursorID, 1, l_column_name);
	  DBMS_SQL.COLUMN_VALUE(l_cursorID, 2, l_data_type);

	  IF (l_column_name NOT IN ('CREATED_BY', 'CREATION_DATE',
		'LAST_UPDATED_BY', 'LAST_UPDATE_DATE', 'LAST_UPDATE_LOGIN'
		, 'OBJECT_VERSION_NUMBER')) THEN
	    IF (p_mode = 'PRE') THEN
	      G_VALUE_LIST(l_index).column_name := l_column_name;
	      G_VALUE_LIST(l_index).data_type := l_data_type;
	    ELSE
	      -- Validate in POST mode,
	      -- the snapshot of the SAME record is getting retrieved
	      IF (G_VALUE_LIST(l_index).column_name <> l_column_name)
	      THEN
	        RAISE FND_API.G_EXC_ERROR;
	      END IF;
	    END IF;

	    -- handle special first case
	    IF (length(l_select_val_stmt) = 6) THEN
	      l_select_val_stmt := l_select_val_stmt || ' ';
	    ELSE
	      l_select_val_stmt := l_select_val_stmt || ', ';
	    END IF;

	    IF (l_data_type = 'VARCHAR2') THEN
	      l_select_val_stmt := l_select_val_stmt || l_column_name;
	    ELSIF (l_data_type = 'NUMBER') THEN
	      l_select_val_stmt := l_select_val_stmt || 'to_char(' || l_column_name || ')';
	    ELSIF (l_data_Type = 'DATE') THEN
	      l_select_val_stmt := l_select_val_stmt || 'to_char(' || l_column_Name || ', ''DD-MON-YYYY HH24:MI:SS'')';
	    ELSE
	      l_select_val_stmt := l_select_val_stmt || l_column_name;
	    END IF;
  	    l_index := l_index + 1;

	  END IF;

	END LOOP;

	l_index := G_VALUE_LIST.count;

	DBMS_SQL.CLOSE_CURSOR(l_cursorID);

	IF (length(l_select_val_stmt) > 6) THEN

	  l_select_val_stmt := l_select_val_stmt || ' from ' || p_table_name || ' where ';
	  l_select_val_stmt := l_select_val_stmt || p_primary_key_name || ' = :p_id';

	  l_cursorID := DBMS_SQL.OPEN_CURSOR;
	  DBMS_SQL.PARSE(l_cursorID, l_select_val_stmt, DBMS_SQL.V7);

	  DBMS_SQL.BIND_VARIABLE(l_cursorID, ':p_id', p_id);

	  FOR i in 1..l_index LOOP

	    IF (p_mode = 'PRE') THEN
	      DBMS_SQL.DEFINE_COLUMN(l_cursorID, i, G_VALUE_LIST(i).old_value, 2000);
	    ELSE
	      DBMS_SQL.DEFINE_COLUMN(l_cursorID, i, G_VALUE_LIST(i).new_value, 2000);
	    END IF;
	  END LOOP;

	  l_dummy := DBMS_SQL.EXECUTE(l_cursorID);

	  IF DBMS_SQL.FETCH_ROWS(l_cursorID) = 0 THEN
	    RAISE NO_DATA_FOUND;
	  END IF;

	  FOR i in 1..l_index LOOP
	    IF (p_mode = 'PRE') THEN
	      DBMS_SQL.COLUMN_VALUE(l_cursorID, i, G_VALUE_LIST(i).old_value);
	    ELSE
	      DBMS_SQL.COLUMN_VALUE(l_cursorID, i, G_VALUE_LIST(i).new_value);
	    END IF;
	  END LOOP;

	  DBMS_SQL.CLOSE_CURSOR(l_cursorID);
	ELSE
	  raise FND_API.G_EXC_ERROR;
	  -- NO TABLE INFORMATION FOUND. RAISE ERROR HERE
	END IF;
/*
	for i in 1..l_index LOOP
	  dbms_output.put_line('COLUMN: ' || G_VALUE_LIST(i).column_name);
	  dbms_output.put_line('DATATYPE: ' ||G_VALUE_LIST(i).data_type);
	  dbms_output.put_line('OLD VALUE: ' ||G_VALUE_LIST(i).old_value);
	  dbms_output.put_line('NEW VALUE: ' ||G_VALUE_LIST(i).new_value);
	END LOOP;
*/
exception
when others then
  dbms_sql.close_cursor(l_cursorID);
  raise;
end get_record_snapshot;

procedure log_changes(p_loan_id NUMBER) AS
  x_loan_history_id	NUMBER := NULL;
BEGIN
	for i in 1..G_VALUE_LIST.count LOOP
	  if (G_VALUE_LIST(i).old_value <> G_VALUE_LIST(i).new_value OR
	    (G_VALUE_LIST(i).old_value is NULL AND G_VALUE_LIST(i).new_value is NOT NULL) OR
	    (G_VALUE_LIST(i).old_value is NOT NULL AND G_VALUE_LIST(i).new_value is NULL)) then
	    LNS_LOAN_HISTORIES_H_PKG.Insert_Row(
		x_loan_history_id	=> x_loan_history_id,
		p_loan_id		=> p_loan_id,
		p_table_Name		=> G_TABLE_NAME,
		p_column_name		=> G_VALUE_LIST(i).column_name,
		p_data_type		=> G_VALUE_LIST(i).data_type,
		p_old_value		=> G_VALUE_LIST(i).old_value,
		p_new_value		=> G_VALUE_LIST(i).new_value,
		p_object_version_number	=> 1,
		p_primary_key_id	=> G_PRIMARY_KEY_ID);
	  end if;
	END LOOP;

EXCEPTION
WHEN OTHERS THEN
  RAISE;
END;

procedure log_record_pre(p_id NUMBER, p_primary_key_name VARCHAR2, p_table_name VARCHAR2) AS
BEGIN
	-- reset the table
	G_VALUE_LIST.delete;
	G_PRIMARY_KEY_NAME := p_primary_key_name;
	G_PRIMARY_KEY_ID   := p_id;
	G_TABLE_NAME	   := p_table_name;
	get_record_snapshot(p_id, p_primary_key_name, p_table_name, 'PRE');

END log_record_pre;

procedure log_record_post(p_id NUMBER, p_primary_key_name VARCHAR2, p_table_name VARCHAR2, p_loan_id NUMBER) AS
BEGIN

	IF (G_VALUE_LIST.count = 0) THEN
	  -- NO PRE UPDATE SNAPSHOT, RAISE ERROR
	  raise FND_API.G_EXC_ERROR;
	END IF;

	IF (G_TABLE_NAME <> p_table_name) THEN
	-- RAISE ERROR -- invalid table name
	  raise FND_API.G_EXC_ERROR;
	END IF;

	IF (G_PRIMARY_KEY_NAME <> p_primary_key_name OR
	  G_PRIMARY_KEY_ID <> p_id) THEN
	  raise FND_API.G_EXC_ERROR;
	END IF;

	get_record_snapshot(p_id, p_primary_key_name, p_table_name, 'POST');
	log_changes(p_loan_id);

EXCEPTION
WHEN OTHERS THEN
  RAISE;
END log_record_post;

END lns_loan_history_pub;

/
