--------------------------------------------------------
--  DDL for Package Body WSH_INVOICE_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_INVOICE_UTILITIES" as
/* $Header: WSHARINB.pls 115.3 99/07/16 08:17:42 porting ship $ */

  inv_num       Varchar2(40);

  --
  -- PUBLIC FUNCTIONS
  --
/*===========================================================================+
 | Name: update_numbers                                                      |
 | Purpose: It looks in ra_interface_lines table for the lines inserted for  |
 |          this run of Receivables Interface and updates them with an       |
 |          Invoice Number based on the delivery name                        |
 +===========================================================================*/

  FUNCTION update_invoice_numbers(x_del_id NUMBER, x_del_name VARCHAR2,
	   err_msg IN OUT VARCHAR2) Return NUMBER IS

    inv_num_index Number;
    inv_num_base  Varchar2(40);

  BEGIN
    --dbms_output.put_line('Update Invoice Numbers: del_id ' || to_char(x_del_id) || ' del name: ' || x_del_name );
    inv_num_base := x_del_name;

    Select nvl((max(index_number)+1), 0)
    Into inv_num_index
    From wsh_invoice_numbers
    Where delivery_id = x_del_id;

    If ( SQL%NOTFOUND ) Then
      inv_num_index := 1;
    End if;

    if ( inv_num_index = 0 ) Then
      inv_num := inv_num_base;
    Else
      inv_num := inv_num_base || '-' || to_char(inv_num_index);
    End If;

    --dbms_output.put_line('global user ' || fnd_global.user_id);
    --dbms_output.put_line('inv num index ' || to_char(inv_num_index));
    Insert Into Wsh_Invoice_Numbers
      (INVOICE_NUMBER_ID, DELIVERY_ID, INDEX_NUMBER, LAST_UPDATE_DATE,
       LAST_UPDATED_BY, CREATION_DATE, CREATED_BY)
    VALUES
      (wsh_invoice_numbers_s.nextval, x_del_id, inv_num_index, SYSDATE,
       fnd_global.user_id, SYSDATE, fnd_global.user_id);

    return 0;

  EXCEPTION
    WHEN others THEN
      err_msg := 'Error in wsh_invoice_utilities.update_invoice_numbers:\n '||
		 SQLERRM;
      --dbms_output.put_line(err_msg);
      return -1;

  END;

  PROCEDURE update_numbers(x_org_id NUMBER ,
			   x_request_id NUMBER,
			   err_msg IN OUT VARCHAR2 ) IS

    group_col_clause varchar2(10000) := '';
    select_col       varchar2(10000) := '';
    col_name         varchar2(100) ;
    grp_stmt         varchar2(20000);
    col_length       NUMBER;
    group_cursor     INTEGER;
    rows_processed   INTEGER;

    last_concat_cols varchar2(5000) := '';
    this_concat_cols varchar2(5000) := '';

    last_del_name varchar2(15) := '';
    this_del_name varchar2(15) := '';
    this_del_id Number;
    this_rowid  Varchar2(20);

    Cursor cur_get_cols IS
      Select upper(c.from_column_name), c.from_column_length
      From ra_group_by_columns c
      Where c.column_type = 'M';

    Cursor cur_get_del_id (x_del_name IN VARCHAR2) IS
      Select delivery_id
      From wsh_deliveries
      Where name = x_del_name;

  BEGIN

    -- Get all the group by columns from ra_group_by_columns table
    -- and build up the select and group bu column clauses.
    --dbms_output.put_line('Position 1');
    Open cur_get_cols;
    Loop
      Fetch cur_get_cols Into col_name, col_length;
      Exit when cur_get_cols%NOTFOUND;
      If ( group_col_clause is NULL ) Then
	group_col_clause := col_name;
	select_col := col_name;
      Else
	group_col_clause := group_col_clause || ', ' || col_name;
	select_col := select_col || '||' || '''~'''|| '||'|| col_name;
      End If;
    End Loop;
    Close cur_get_cols;
    --dbms_output.put_line('Position 2');
    --dbms_output.put_line('Grouping Clause: ' || group_col_clause);
    --dbms_output.put_line('Select Clause: ' || select_col);

    -- Build the full select statement and using dbms_sql execute
    -- the statement
    --dbms_output.put_line('Position 21');
    grp_stmt := 'Select ' || select_col || ' group_cols,'    ||
		' l.interface_line_attribute3, ROWID '       ||
		' From RA_INTERFACE_LINES_ALL L'             ||
		' Where trx_number is NULL'                  ||
		' And request_id = ' || to_char(x_request_id)||
		' Order by ' || group_col_clause             ||
		' , l.interface_line_attribute3, l.org_id' ;

    --dbms_output.put_line(grp_stmt);
    --dbms_output.put_line('Position 3');
    group_cursor := dbms_sql.open_cursor;
    dbms_sql.parse( group_cursor, grp_stmt, dbms_sql.v7);
    --dbms_output.put_line('Position 31');
    dbms_sql.define_column( group_cursor, 1, this_concat_cols, 5000);
    dbms_sql.define_column( group_cursor, 2, this_del_name, 15);
    dbms_sql.define_column( group_cursor, 3, this_rowid, 20);
    rows_processed := dbms_sql.execute (group_cursor);

    --dbms_output.put_line('Position 4');
    Loop
      if ( dbms_sql.fetch_rows (group_cursor) > 0 ) Then
        dbms_sql.column_value (group_cursor, 1, this_concat_cols);
        dbms_sql.column_value (group_cursor, 2, this_del_name);
        dbms_sql.column_value (group_cursor, 3, this_rowid);
      Else
        exit;
      End if;

      --dbms_output.put_line('Delivery Name: ' || this_del_name);
      --dbms_output.put_line('Concat Cols: ' || this_concat_cols);
      if ( last_del_name is NULL OR
	   last_del_name <> this_del_name ) Then

          --dbms_output.put_line('Position 5');
	  Open cur_get_del_id(this_del_name);
	  Fetch cur_get_del_id Into this_del_id;

	  if (cur_get_del_id%NOTFOUND ) Then
	    fnd_message.set_token('DELIVERY_NAME', this_del_name);
	    fnd_message.set_name('OE', 'WSH_AR_INVALID_DEL_NAME');
	    err_msg := fnd_message.get;
            --dbms_output.put_line(err_msg);
	    Close cur_get_del_id;
	    --return;
	  End if;
	  if ( cur_get_del_id%ISOPEN ) Then
	    Close cur_get_del_id;
	  end if;
          --dbms_output.put_line('Delivery Id: ' || to_char(this_del_id));

      End if;

      if ( last_concat_cols is NULL OR
	   last_concat_cols <> this_concat_cols ) Then

        --dbms_output.put_line('Concat cols changed, calling update_invoice');
	if ( update_invoice_numbers ( this_del_id, this_del_name,
				      err_msg ) < 0 ) Then
	  return;
	end if;

	last_del_name := this_del_name;
        last_concat_cols := this_concat_cols;

      Else

	if ( last_del_name <> this_del_name ) Then

          --dbms_output.put_line('del name changed, calling update_invoice');
	  if ( update_invoice_numbers ( this_del_id, this_del_name,
				        err_msg ) < 0 ) Then
	    return;
	  end if;

	  last_del_name := this_del_name;

	End if;

      End if;

      Update RA_INTERFACE_LINES_ALL
	set trx_number = inv_num
	where rowid = chartorowid(this_rowid);

    End Loop;

    dbms_sql.close_cursor (group_cursor);

    Return;

  EXCEPTION
    WHEN others THEN
      --dbms_output.put_line('Oracle Error: ' || SQLERRM);
      err_msg := 'Error in wsh_invoice_utilities.update_numbers:\n '|| SQLERRM;
      --dbms_output.put_line(err_msg);
      if (cur_get_cols%ISOPEN) Then
        Close cur_get_cols;
      End if;
      if (cur_get_del_id%ISOPEN) Then
        Close cur_get_del_id;
      End if;
      Return;

  END;

END WSH_INVOICE_UTILITIES;

/
