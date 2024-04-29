--------------------------------------------------------
--  DDL for Package Body GMA_EDITTEXT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMA_EDITTEXT_PKG" AS
/* $Header: GMACEDTB.pls 115.3 2003/06/03 17:53:02 kmoizudd noship $ */

Function Copy_Text(
  X_Text_Code       in NUMBER,
  X_From_Text_Table in VARCHAR2,
  X_To_Text_Table   in VARCHAR2
  ) Return Number
is
pragma AUTONOMOUS_TRANSACTION;

  l_tl_sql_columns      varchar2(200);
  l_hdr_sql_columns     varchar2(200);
  l_check_text_rows     varchar2(300);
  l_Rows_Processed      integer;
  l_New_Text_Code       number(15);
  l_Tl_Sql_statement    varchar2(4000);
  l_Tl_Hdr_Sql_stmt     varchar2(4000);
  l_To_Hdr_Table        varchar2(100);
  l_From_Hdr_Table      varchar2(100);
  l_Cursor              integer;

Begin

  -- List all columns of TEXT table
  l_tl_sql_columns:=' LANG_CODE,PARAGRAPH_CODE,SUB_PARACODE,LINE_NO,TEXT,LANGUAGE,SOURCE_LANG,
                   LAST_UPDATED_BY,CREATED_BY,LAST_UPDATE_LOGIN ';

  l_hdr_sql_columns:= ' LAST_UPDATED_BY,CREATED_BY,LAST_UPDATE_LOGIN ';


  l_Cursor := dbms_sql.open_cursor;

  l_check_text_rows:= ' SELECT distinct TEXT_CODE ' ||
                      ' FROM '||X_From_Text_Table ||
                      ' WHERE Text_Code  = :X_Text_Code';

  dbms_sql.parse(l_Cursor,l_check_text_rows,0);

  -- Modified the SQL stmt to use of Bind Variable,this improves the significant performance
  -- Added by Khaja according to Project plan see bug 2935158
  dbms_sql.bind_variable(l_Cursor, 'X_Text_Code', X_Text_Code);

  l_Rows_processed:=dbms_sql.execute(l_Cursor);

  -- dbms_output.put_line(l_rows_processed);

  -- Process the new insert if rows exists otherwise no
  IF dbms_sql.fetch_rows (l_Cursor) > 0 THEN

   -- Generate new Text_code from sequence.
      SELECT gem5_text_code_s.nextval into l_New_Text_code
      FROM DUAL;

   -- Main sql stmt which inserts all text lines, replacing text_code with sequence
      l_TL_Sql_statement:= 'INSERT INTO '||X_To_Text_table||
                      ' ( '||
                          ' TEXT_CODE '       ||','||
                            l_TL_SQL_COLUMNS  ||','||
                          ' CREATION_DATE'    ||','||
                          ' LAST_UPDATE_DATE' ||
                      ' ) '||
                      ' SELECT :l_New_Text_Code '||','||
                                  l_tl_sql_columns ||','||
                                  'sysdate'||','||
                                  'sysdate'||
                      ' FROM '||X_From_Text_Table ||
                             ' WHERE Text_Code  = :X_Text_Code ';

      dbms_sql.parse(l_Cursor,l_TL_Sql_statement,0);

  -- Modified the SQL stmt to use of Bind Variable,this improves the significant performance
  -- Added by Khaja according to Project plan see bug 2935158
      dbms_sql.bind_variable(l_Cursor, 'l_New_Text_Code',l_New_Text_Code);
      dbms_sql.bind_variable(l_Cursor, 'X_Text_Code',X_Text_Code);

      l_Rows_processed:=dbms_sql.execute(l_Cursor);

      -- Prepare the To and From Header table name from the given text table

      l_From_Hdr_Table:=substr(X_From_Text_table,1,instr(upper(X_From_Text_table),'TEXT')+3)||'_HDR';
      l_To_Hdr_Table:=substr(X_To_Text_table,1,instr(upper(X_To_Text_table),'TEXT')+3)||'_HDR';

      -- GME header table name is different,not having name as _HDR, replacing it with _HEADER
      -- see bug 2935005
      IF upper(l_From_Hdr_Table)='GME_TEXT_HDR' then
         l_From_Hdr_Table:='GME_TEXT_HEADER';
      END IF;

      IF upper(l_to_Hdr_Table)='GME_TEXT_HDR' then
         l_To_Hdr_Table:='GME_TEXT_HEADER';
      END IF;

      -- Get ready with SQL stmt to insert row in header by replacing text_code with sequence
      l_TL_HDR_Sql_stmt:= 'INSERT INTO '||l_To_Hdr_Table||
                      ' ( '||
                          ' TEXT_CODE'        ||','||
                            l_hdr_sql_columns ||','||
                          ' CREATION_DATE'    ||','||
                          ' LAST_UPDATE_DATE' ||
                      ' ) '||
                      ' SELECT :l_New_Text_Code  '||','||
                                  l_hdr_sql_columns ||','||
                                  'sysdate'||','||
                                  'sysdate'||
                      ' FROM '||l_From_Hdr_Table ||
                             ' WHERE Text_Code = :X_Text_Code ';

      dbms_sql.parse(l_Cursor,l_TL_Hdr_Sql_stmt,0);

  -- Modified the SQL stmt to use of Bind Variable,this improves the significant performance
  -- Added by Khaja according to Project plan see bug 2935158
      dbms_sql.bind_variable(l_Cursor, 'l_New_Text_Code',l_New_Text_Code);
      dbms_sql.bind_variable(l_Cursor, 'X_Text_Code',X_Text_Code);

      l_Rows_processed:=dbms_sql.execute(l_Cursor);

      -- dbms_output.put_line(l_rows_processed);

      dbms_sql.close_cursor(l_Cursor);
    -- bug #2880608 placing a commit stmt as per Thomas Danial(GMD) for Session parameter request 4/1/03
       commit;
      Return l_New_Text_code;

  ELSE
      dbms_sql.close_cursor(l_Cursor);
    -- bug #2880608 placing a commit stmt as per Thomas Danial(GMD) for Session parameter request 4/1/03
       commit;
      RETURN NULL;
  END IF;

EXCEPTION
  WHEN others THEN
    IF dbms_sql.is_open (l_Cursor) THEN
      dbms_sql.close_cursor (l_Cursor);
    END IF;
    Raise;

End Copy_Text;

Procedure Delete_Text(
  X_Text_Code       in NUMBER,
  X_From_Text_Table in VARCHAR2
  )
is
pragma AUTONOMOUS_TRANSACTION;

  l_tl_sql_statement varchar2(1000);
  l_from_hdr_Table   varchar2(100);
  l_tl_hdr_Sql_stmt  varchar2(4000);
  l_Rows_Processed   integer;
  l_Cursor           integer;

Begin

  -- Prepare the Delete stmt for text line
      l_tl_sql_statement:=' DELETE FROM '|| X_From_Text_table ||
                       ' WHERE  TEXT_CODE = :X_Text_Code ';

      l_from_Hdr_table:=substr(X_From_Text_table,1,instr(upper(X_From_Text_table),'TEXT')+3)||'_HDR';

      -- GME header table name is different,not having name as _HDR, replacing it with _HEADER
      -- see bug 2935005
      IF upper(l_From_Hdr_Table)='GME_TEXT_HDR' then
         l_From_Hdr_Table:='GME_TEXT_HEADER';
      END IF;

  -- Prepare the Delete stmt for Header text line
      l_tl_hdr_sql_stmt:=' DELETE FROM '|| l_From_hdr_table ||
                       ' WHERE  TEXT_CODE =:X_Text_Code ';

      l_Cursor := dbms_sql.open_cursor;

      dbms_sql.parse(l_Cursor,l_tl_Sql_statement,0);

  -- Modified the SQL stmt to use of Bind Variable,this improves the significant performance
  -- Added by Khaja according to Project plan see bug 2935158
      dbms_sql.bind_variable(l_Cursor, 'X_Text_Code',X_Text_Code);

      l_Rows_processed:=dbms_sql.execute(l_Cursor);

      dbms_sql.parse(l_Cursor,l_tl_hdr_sql_stmt,0);

  -- Modified the SQL stmt to use of Bind Variable,this improves the significant performance
  -- Added by Khaja according to Project plan see bug 2935158
      dbms_sql.bind_variable(l_Cursor, 'X_Text_Code',X_Text_Code);

      l_Rows_processed:=dbms_sql.execute(l_Cursor);

      dbms_sql.close_cursor(l_Cursor);

    -- bug #2880608 placing a commit stmt as per Thomas Danial(GMD) for Session parameter request 4/1/03
       commit;

EXCEPTION
  WHEN others THEN
    IF dbms_sql.is_open (l_Cursor) THEN
      dbms_sql.close_cursor (l_Cursor);
    END IF;
    Raise;

End Delete_Text;

End GMA_EDITTEXT_PKG;

/
