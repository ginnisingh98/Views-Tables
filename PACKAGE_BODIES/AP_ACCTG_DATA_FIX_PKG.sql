--------------------------------------------------------
--  DDL for Package Body AP_ACCTG_DATA_FIX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_ACCTG_DATA_FIX_PKG" AS
/* $Header: apgdfalb.pls 120.1.12010000.17 2010/03/08 05:56:13 imandal ship $ */

G_CURRENT_RUNTIME_LEVEL     NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_UNEXPECTED CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR      CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION  CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT      CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE  CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT  CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME      CONSTANT VARCHAR2(50) :='AP.PLSQL.AP_ACCTG_DATA_FIX_PKG.';



  /* Procedure to open the log files on the instance where the datafix
     script is being run. The log file contains the log messages
     and the report outputs written by the data fix scripts.
     The file location is the environment's 'utl_file_dir' parameter. */

  PROCEDURE Open_Log_Out_Files
       (P_Bug_Number             IN      varchar2,
        P_File_Location          OUT NOCOPY VARCHAR2) IS

    l_log_file         VARCHAR2(30);
    l_out_file         VARCHAR2(30);
    l_file_location    v$parameter.value%type;
    No_Utl_Dir         EXCEPTION;
    l_date             VARCHAR2(30);
    l_message          VARCHAR2(500);

  BEGIN
     SELECT TO_CHAR(SYSDATE, '-HH24:MI:SS')
     INTO   l_date
     FROM   DUAL;

    l_log_file := p_bug_number||l_date||'.html';
    l_out_file := p_bug_number||'.out';

    SELECT decode(instr(value,','),0,value,
                   SUBSTR (value,1,instr(value,',') - 1))
    INTO   l_file_location
    FROM   v$parameter
    WHERE  name = 'utl_file_dir';

    IF l_file_location IS NULL THEN
      RAISE No_Utl_Dir;
    END IF;

    p_file_location:=l_file_location||'/'||l_log_file;

    FND_FILE.PUT_NAMES(l_log_file,
                       l_out_file,
                       l_file_location);
  EXCEPTION
    WHEN OTHERS THEN
        l_message := 'Exception :: '||SQLERRM||'<p>';
        FND_File.Put_Line(fnd_file.log,l_message);

        l_message := 'in side AP_ACCTG_DATA_FIX_PKG.Open_Log_Out_Files '||'<p>';
        FND_File.Put_Line(fnd_file.log,l_message);
      APP_EXCEPTION.RAISE_EXCEPTION;
  END Open_Log_Out_Files;



  /* Procedure to close the log files on the instance once all the log
     messages are written to it. */

  PROCEDURE Close_Log_Out_Files IS
  BEGIN
    FND_File.Close;
  END Close_Log_Out_Files;


  /* Procedure to create temproary backup tables for the accounting */

  PROCEDURE Create_Temp_Acctg_Tables
      (P_Bug_Number             IN      NUMBER) IS
      First_time                number :=0;
      l_calling_sequence        VARCHAR2(2000);
      l_message                 VARCHAR2(500);
  Begin
    l_calling_sequence :=
           'AP_Acctg_Data_Fix_PKG.Create_Temp_Acctg_Tables';

  Execute Immediate
    'create table '||'Events_'||P_Bug_Number||
    ' as select * from XLA_EVENTS where rownum<1 ';

  Execute Immediate
    'alter table '||'Events_'||P_Bug_Number||
    ' add datafix_update_date date default sysdate';

  Execute Immediate
    'create table '||'HEADERS_'||P_Bug_Number||
    ' as select * from XLA_AE_HEADERS where rownum<1 ';

  Execute Immediate
    'alter table '||'HEADERS_'||P_Bug_Number||
    ' add datafix_update_date date default sysdate';

  Execute Immediate
    'create table '||'LINES_'||P_Bug_Number||
    ' as select * from XLA_AE_LINES where rownum<1 ';

  Execute Immediate
    'alter table '||'LINES_'||P_Bug_Number||
    ' add datafix_update_date date default sysdate';

  Execute Immediate
    'create table '||'DISTRIB_LINKS_'||P_Bug_Number||
    ' as select * from XLA_DISTRIBUTION_LINKS where rownum<1 ';

  Execute Immediate
    'alter table '||'DISTRIB_LINKS_'||P_Bug_Number||
    ' add datafix_update_date date default sysdate';

  Execute Immediate
    'create table '||'TRANS_ENTITIES_'||P_Bug_Number||
    ' as select * from XLA_TRANSACTION_ENTITIES where rownum<1 ';

  Execute Immediate
    'alter table '||'TRANS_ENTITIES_'||P_Bug_Number||
    ' add datafix_update_date date default sysdate';

  EXCEPTION

    WHEN OTHERS THEN
        l_message := 'Exception :: '||SQLERRM||'<p>';
        FND_File.Put_Line(fnd_file.log,l_message);

        l_message := 'in side '||l_calling_sequence||'<p>';
        FND_File.Put_Line(fnd_file.log,l_message);

      APP_EXCEPTION.RAISE_EXCEPTION;
  End Create_Temp_Acctg_Tables;


/* Procedure to get all the columns for a particular table.
   This procedure gets called from Back_Up_Acctg procedure. */

PROCEDURE Get_Cols(tab_name in varchar2,ret_str out NOCOPY varchar2) is
  TYPE sqlCurTyp IS REF CURSOR;
  cur sqlCurTyp;
  stmt_str VARCHAR2(500);
  col_name varchar2(100);
  l_all_tab_columns    varchar2(100) := 'ALL_TAB_COLUMNS';
  l_calling_sequence   VARCHAR2(2000);
  l_message            varchar2(500);

begin

  l_calling_sequence :=
           'AP_Acctg_Data_Fix_PKG.Get_Cols<-' ;
  stmt_str := 'select column_name from '|| l_all_tab_columns ||
              ' where table_name=:1 and column_name<>''DATAFIX_UPDATE_DATE''';
  OPEN cur FOR stmt_str USING TAB_NAME;
LOOP
  FETCH cur INTO COL_NAME;
  EXIT WHEN cur%NOTFOUND;
  ret_str:=ret_str||','||col_name;
END LOOP;
CLOSE cur;

ret_str:= SUBSTR(ret_str,2,LENGTH(ret_str));
  EXCEPTION

    WHEN OTHERS THEN
        l_message := 'Exception :: '||SQLERRM||'<p>';
        FND_File.Put_Line(fnd_file.log,l_message);

        l_message := 'in side '||l_calling_sequence||'<p>';
        FND_File.Put_Line(fnd_file.log,l_message);
      APP_EXCEPTION.RAISE_EXCEPTION;
end Get_Cols;

/*  Overload the Get_Cols procedure to handle the case where there are two tables with the same name
        in different schemas.  For example, you can find ap_invoices_all in both the ap and bifin schemas.
        Without this the procedure will end with ORA-00957: duplicate column name
*/

PROCEDURE Get_Cols(tab_name in varchar2, schema_name in varchar2, ret_str out NOCOPY varchar2) is
  TYPE sqlCurTyp IS REF CURSOR;
  cur sqlCurTyp;
  stmt_str VARCHAR2(500);
  col_name varchar2(100);
  l_all_tab_columns    varchar2(100) := 'ALL_TAB_COLUMNS';
  l_calling_sequence   VARCHAR2(2000);
  l_message            varchar2(500);

begin

  l_calling_sequence :=
           'AP_Acctg_Data_Fix_PKG.Get_Cols<-' ;
  stmt_str := 'select column_name from '|| l_all_tab_columns ||
              ' where table_name=:1 and owner =:2 and column_name<>''DATAFIX_UPDATE_DATE''';
  OPEN cur FOR stmt_str USING TAB_NAME, SCHEMA_NAME;
LOOP
  FETCH cur INTO COL_NAME;
  EXIT WHEN cur%NOTFOUND;
  ret_str:=ret_str||','||col_name;
END LOOP;
CLOSE cur;

ret_str:= SUBSTR(ret_str,2,LENGTH(ret_str));
  EXCEPTION

    WHEN OTHERS THEN
        l_message := 'Exception :: '||SQLERRM||'<p>';
        FND_File.Put_Line(fnd_file.log,l_message);

        l_message := 'in side '||l_calling_sequence||'<p>';
        FND_File.Put_Line(fnd_file.log,l_message);
      APP_EXCEPTION.RAISE_EXCEPTION;
end Get_Cols;


/* Procedure to get the backup of all the Accounting (XLA) tables. */

Procedure Back_Up_Acctg(P_Bug_Number in number,
                        P_Driver_Table in VARCHAR2 DEFAULT NULL,
                        P_Calling_Sequence in VARCHAR2 DEFAULT NULL) is

  l_driver_table        ALL_TABLES.TABLE_NAME%TYPE;
  l_debug_info          VARCHAR2(4000);
  sql_liab_stat         varchar2(5000);
  col_str1              varchar2(5000);
  col_str2              varchar2(5000);
  col_str3              varchar2(5000);
  col_str4              varchar2(5000);
  col_str5              varchar2(5000);
  bkp_tables_exists     number:=0;
  l_message             varchar2(500);
  TYPE sqlCurTyp IS     REF CURSOR;
  cur                   sqlCurTyp;
  l_tables              varchar2(100) := 'ALL_TABLES';
  l_calling_sequence          VARCHAR2(2000);
BEGIN

    l_calling_sequence :=
           'AP_Acctg_Data_Fix_PKG.Back_Up_Acctg<-'||P_calling_Sequence ;

    l_debug_info := 'Setting the driver table name';
    IF P_Driver_Table IS NULL THEN
      l_driver_table := 'AP_TEMP_DATA_DRIVER_'||P_Bug_number;
    ELSE
      l_driver_table := upper(P_Driver_Table);
    END IF;

    l_debug_info := 'Checking if the backup Tables exist';
    sql_liab_stat := 'select count(*) from '|| l_tables ||
                    ' where table_name='||''''||'HEADERS_'||P_Bug_number||'''';
    OPEN cur FOR sql_liab_stat;
      fetch cur into bkp_tables_exists;
    CLOSE cur;

    AP_Acctg_Data_Fix_PKG.Print('_______________________________________'||
                               '_______________________________________');

    if (bkp_tables_exists=0) then
      l_message := 'Backup tables do not Exist: Before creating accounting backup tables <p>';
      Print(l_message);

      AP_Acctg_Data_Fix_PKG.Create_Temp_Acctg_Tables(p_bug_number);

      l_message := 'After creating accounting backup tables <p>';
      Print(l_message);

    end if;

    l_debug_info := 'Before getting the cols for the Backup Tables';

    AP_Acctg_Data_Fix_PKG.get_cols('EVENTS_'||P_Bug_Number,col_str5);

    AP_Acctg_Data_Fix_PKG.get_cols('HEADERS_'||P_Bug_Number,col_str1);

    AP_Acctg_Data_Fix_PKG.get_cols('LINES_'||P_Bug_Number,col_str2);

    AP_Acctg_Data_Fix_PKG.get_cols('DISTRIB_LINKS_'||P_Bug_Number,col_str3);

    l_message := 'Before creating backup for Accounting tables <p>';
    FND_File.Put_Line(fnd_file.log,l_message);

    l_debug_info := 'Before backing the events';
    sql_liab_stat := 'insert into events_'||P_Bug_Number||'('||col_str5||') '||
                     ' select '||col_str5||' from xla_events '||
                     ' where  event_id in '||
    ' (select event_id from '||l_driver_table||
    ' Where process_flag=''Y'')';

    EXECUTE IMMEDIATE sql_liab_stat ;

    l_debug_info := 'Before backing the headers';
    sql_liab_stat := 'insert into headers_'||P_Bug_Number||'('||col_str1||') '||
                     ' select '||col_str1||' from xla_ae_headers '||
                     ' where  event_id in '||
    ' (select event_id from '||l_driver_table||
    ' Where process_flag=''Y'')';

    EXECUTE IMMEDIATE sql_liab_stat ;

   l_debug_info := 'Before backing the lines';
    sql_liab_stat := 'insert into lines_'||P_Bug_Number||'('||col_str2||') '||
                     ' select '||col_str2||' from xla_ae_lines '||
                     ' where  ae_header_id in '||
    ' (select xah.ae_header_id '||
    ' from headers_'||P_Bug_Number||' xah,  '||
           l_driver_table||' dr '||
    ' where dr.event_id = xah.event_id '||
    ' and dr.process_flag = ''Y'' '||
    ' ) ';

    EXECUTE IMMEDIATE sql_liab_stat;

    l_debug_info := 'Before backing the dist links';
    sql_liab_stat := 'insert into distrib_links_'||P_Bug_Number||'('||col_str3||') '||
                     ' select '||col_str3||' from xla_distribution_links '||
                     ' where  ae_header_id in '||
    ' (select xah.ae_header_id '||
    ' from headers_'||P_Bug_Number||' xah,  '||
           l_driver_table||' dr '||
    ' where dr.event_id = xah.event_id '||
    ' and dr.process_flag = ''Y'' '||
    ' ) ';

    EXECUTE IMMEDIATE sql_liab_stat;

    l_message := 'After creating backup for Accounting tables <p>';
    FND_File.Put_Line(fnd_file.log,l_message);

  EXCEPTION
    WHEN OTHERS THEN
        l_message := 'Exception :: '||SQLERRM||'<p>';
        FND_File.Put_Line(fnd_file.log,l_message);

        l_message := 'in side '||l_calling_sequence||
                     ' while performing '||l_debug_info||'<p>';
        FND_File.Put_Line(fnd_file.log,l_message);
      APP_EXCEPTION.RAISE_EXCEPTION();
  END Back_Up_Acctg;

  /* Procedure to print messages in the Log file */
  PROCEDURE Print
      (p_message                 IN       VARCHAR2,
       P_calling_sequence        IN       VARCHAR2) IS
    l_message          varchar2(500);
    l_calling_sequence varchar2(500);
  Begin
     l_calling_sequence:='AP_Acctg_Data_Fix_PKG.print <- '||p_calling_sequence;

     FND_File.Put_Line(fnd_file.log,p_message||'<p>');

  Exception
    WHEN OTHERS THEN
        l_message := 'Exception :: '||SQLERRM||'<p>';
        FND_File.Put_Line(fnd_file.log,l_message);

        l_message := 'in side '||l_calling_sequence||'<p>';
        FND_File.Put_Line(fnd_file.log,l_message);
      APP_EXCEPTION.RAISE_EXCEPTION;
  End Print;


/* Procedure to print the values in the table and column list
   passed as parameters, in HTML table format, into the Log file. */

Procedure Print_Html_Table
    (p_select_list       in VARCHAR2,
     p_table_in          in VARCHAR2,
     p_where_in          in VARCHAR2,
     P_calling_sequence  in VARCHAR2) IS

     l_calling_sequence varchar2(500);
   select_list1 varchar2(2000):=P_SELECT_LIST;

   TYPE string_tab IS TABLE OF VARCHAR2(100)
      INDEX BY BINARY_INTEGER;

   TYPE integer_tab IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

   colname string_tab;
   coltype string_tab;
   collen integer_tab;

   owner_nm VARCHAR2(100) := USER;
   table_nm VARCHAR2(100) := UPPER (p_table_in);
   where_clause VARCHAR2(1000) := LTRIM (UPPER (p_where_in));

   cur INTEGER := DBMS_SQL.OPEN_CURSOR;
   fdbk INTEGER := 0;

   string_value VARCHAR2(2000);
   number_value NUMBER;
   date_value DATE;

   dot_loc INTEGER;
   cur_pos INTEGER:=1;

   col_count INTEGER := 0;
   col_line LONG;
   col_list VARCHAR2(2000);
   l_message VARCHAR2(2000):='<table border="5"><tr>';

BEGIN
     l_calling_sequence:='AP_Acctg_Data_Fix_PKG.Print_Html_Table <- '||
                                                   p_calling_sequence;
   dot_loc := INSTR (table_nm, '.');
   IF dot_loc > 0
   THEN
      owner_nm := SUBSTR (table_nm, 1, dot_loc-1);
      table_nm := SUBSTR (table_nm, dot_loc+1);
   END IF;
   loop
   dot_loc := INSTR(select_list1,',');

   IF (DOT_LOC<=0) THEN
    col_list := col_list || ', ' || select_list1;
    col_count := col_count + 1;
    colname (col_count) := select_list1;
    l_message:=l_message||'<th>'||colname (col_count)||'</th></tr>';
   ELSE
    col_list := col_list || ', ' || SUBSTR (select_list1, 1, dot_loc-1);
    col_count := col_count + 1;
    colname (col_count) := SUBSTR (select_list1, 1, dot_loc-1);
    cur_pos:=dot_loc+1;
      select_list1:=SUBSTR (select_list1, dot_loc+1);

    l_message:=l_message||'<th>'||colname (col_count)||'</th>';
   end if;

      SELECT data_type,DATA_LENGTH
        INTO coltype (col_count) ,collen(col_count)
        FROM all_tab_columns
       WHERE owner = owner_nm
         AND table_name = table_nm
         AND column_name=colname (col_count);

     EXIT WHEN (DOT_LOC<=0);

   end loop;
    col_list := RTRIM (LTRIM (col_list, ', '), ', ');
    print(l_message);

   IF where_clause IS NOT NULL
   THEN
      IF (where_clause NOT LIKE 'GROUP BY%' AND
          where_clause NOT LIKE 'ORDER BY%')
      THEN
         where_clause :=
            'WHERE ' || LTRIM (where_clause, 'WHERE');
      END IF;
   END IF;

   DBMS_SQL.PARSE
      (cur,
       'SELECT ' || col_list ||
       '  FROM ' || p_table_in || ' ' || where_clause,
       1);

   FOR col_ind IN 1 .. col_count
   LOOP
      IF (coltype(col_ind) IN ('CHAR', 'VARCHAR2'))
      THEN
         DBMS_SQL.DEFINE_COLUMN
            (cur, col_ind, string_value, collen (col_ind));
      ELSIF (coltype(col_ind) = 'NUMBER')
      THEN
         DBMS_SQL.DEFINE_COLUMN (cur, col_ind, number_value);

      ELSIF (coltype(col_ind) = 'DATE')
      THEN
         DBMS_SQL.DEFINE_COLUMN (cur, col_ind, date_value);
      END IF;
   END LOOP;

   fdbk := DBMS_SQL.EXECUTE (cur);
   LOOP
      fdbk := DBMS_SQL.FETCH_ROWS (cur);
      EXIT WHEN fdbk = 0;

      col_line := NULL;
     l_message:='<tr>';
      FOR col_ind IN 1 .. col_count
      LOOP
         IF (coltype(col_ind) IN ('CHAR', 'VARCHAR2'))
         THEN

            DBMS_SQL.COLUMN_VALUE
               (cur, col_ind, string_value);

         ELSIF (coltype(col_ind) = 'NUMBER')
         THEN

            DBMS_SQL.COLUMN_VALUE
               (cur, col_ind, number_value);
            string_value := TO_CHAR (number_value);

         ELSIF (coltype(col_ind) = 'DATE')
         THEN

            DBMS_SQL.COLUMN_VALUE
               (cur, col_ind, date_value);
            string_value := date_value;
         END IF;

         col_line :=
            col_line || ' ' ||
            RPAD (NVL (string_value, ' '), collen (col_ind));
            l_message:=l_message||'<td>'||NVL (string_value, ' ')||'</td>';

      END LOOP;
      l_message:=l_message||'</tr>';
      Print(l_message);
   END LOOP;
      print('</table>');

  Exception
    WHEN OTHERS THEN
        l_message := 'SELECT ' || col_list ||
               '  FROM ' || p_table_in || ' ' || where_clause||'<p>';
        FND_File.Put_Line(fnd_file.log,l_message);

        l_message := 'Exception :: '||SQLERRM||'<p>';
        FND_File.Put_Line(fnd_file.log,l_message);

        l_message := 'in side '||l_calling_sequence||'<p>';
        FND_File.Put_Line(fnd_file.log,l_message);
      APP_EXCEPTION.RAISE_EXCEPTION;
END Print_Html_Table;

/* Procedure to backup the data from the source table to destination
   table. It also takes in as input SELECT LIST which determine
   the list of columns which will be backed up. The additional
   WHERE caluse can also be passed in as input. */

Procedure Backup_data
    (p_source_table      in VARCHAR2,
     p_destination_table in VARCHAR2,
     p_select_list       in VARCHAR2,
     p_where_clause      in VARCHAR2,
     P_calling_sequence  in VARCHAR2) is

  l_calling_sequence            varchar2(4000);
  l_message                     LONG;
  TYPE sqlCurTyp IS             REF CURSOR;
  cur                           sqlCurTyp;
  l_tables                      varchar2(100) := 'ALL_TABLES';
  l_bkp_tables_exists           number:=0;
  sql_stmt                      LONG;
  col_str1                      LONG;
  l_sql_stmt                    LONG;

Begin
     l_calling_sequence:='AP_Acctg_Data_Fix_PKG.Backup_data <- '||
                                                   p_calling_sequence;

       sql_stmt := 'select count(*) from '|| l_tables ||
                   ' where table_name='||''''||p_destination_table||'''';

       OPEN  cur FOR sql_stmt;
       FETCH cur into l_bkp_tables_exists;
       CLOSE cur;

   if (l_bkp_tables_exists=0) then
      Print('Before creating backup table '||p_destination_table);
      l_sql_stmt :=
       'Create table '||p_destination_table||
       ' as select  '||p_select_list||' from '||
       p_source_table||' where rownum<1 ';

     execute immediate l_sql_stmt;

      Execute Immediate
       'alter table '||p_destination_table||
       ' add datafix_update_date date default sysdate';
     Print('Created table '||p_destination_table);

   end if;
    sql_stmt := 'insert into '||p_destination_table||
                     '('||P_SELECT_LIST||') '||' select '||P_SELECT_LIST||
                     ' from '||P_SOURCE_TABLE||' '||P_WHERE_CLAUSE;
    l_message:=sql_stmt;
    EXECUTE IMMEDIATE sql_stmt;

  Exception
    WHEN OTHERS THEN
        l_message := 'Exception :: '||SQLERRM;
        print(l_message);

        l_message := 'in side '||l_calling_sequence;
        print(l_message);
      APP_EXCEPTION.RAISE_EXCEPTION;
End Backup_data;

PROCEDURE apps_initialize
      (p_user_name          IN           FND_USER.USER_NAME%TYPE,
       p_resp_name          IN           FND_RESPONSIBILITY_TL.RESPONSIBILITY_NAME%TYPE,
       p_calling_sequence   IN           VARCHAR2) IS

  l_user_id                              NUMBER;
  l_resp_id                              NUMBER;
  l_application_id                       NUMBER := 200;
  l_debug_info                           VARCHAR2(4000);
  l_error_log                            LONG;
  l_calling_sequence                     VARCHAR2(4000);
BEGIN

  l_calling_sequence := 'AP_ACCTG_DATA_FIX_PKG.apps_initialize <-'||p_calling_sequence;

  l_debug_info := 'Before fetching the User Details ';
  BEGIN
    SELECT fu.user_id
      INTO l_user_id
      FROM fnd_user fu
     WHERE fu.user_name = p_user_name;

  EXCEPTION
    WHEN OTHERS THEN
      print('User '||p_user_name||' Not Found');
      APP_EXCEPTION.RAISE_EXCEPTION();
  END;

  l_debug_info := 'Before fetching the responsibility details';
  BEGIN
    SELECT fr.responsibility_id
      INTO l_resp_id
      FROM fnd_responsibility_tl fr
     WHERE fr.responsibility_name = p_resp_name
       AND rownum = 1;

  EXCEPTION
    WHEN OTHERS THEN
      print('Responsibility '||p_resp_name||' Not Found');
      APP_EXCEPTION.RAISE_EXCEPTION();
  END;

  l_debug_info := 'Before Initializing the Application';
  FND_GLOBAL.apps_initialize
    (l_user_id,
     l_resp_id,
     l_application_id);

EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE <> -20001 THEN
      l_error_log := ' Encountered an Unhandled Exception, '||SQLCODE||'-'||SQLERRM||
                     ' in '||l_calling_sequence||' while performing '||l_debug_info;
      Print(l_error_log);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION();
END;


PROCEDURE Del_Nonfinal_xla_entries
     (p_event_id           IN           NUMBER,
      p_delete_event       IN           VARCHAR2,
      p_commit_flag        IN           VARCHAR2,
      p_calling_sequence   IN           VARCHAR2) IS

  l_event_status_code                    XLA_EVENTS.EVENT_STATUS_CODE%TYPE;
  l_gl_transfer_status_code              XLA_AE_HEADERS.GL_TRANSFER_STATUS_CODE%TYPE;
  l_debug_info                           VARCHAR2(4000);
  l_error_log                            LONG;
  l_calling_sequence                     VARCHAR2(4000);

BEGIN

  l_calling_sequence := 'AP_ACCTG_DATA_FIX_PKG.Del_Nonfinal_xla_entries <- '||p_calling_sequence;

  l_event_status_code := 'U';
  l_gl_transfer_status_code := 'N';

  BEGIN
    SELECT xe.event_status_code
      INTO l_event_status_code
      FROM xla_events xe
     WHERE xe.application_id = 200
       AND xe.event_id = p_event_id;

    SELECT xah.gl_transfer_status_code
      INTO l_gl_transfer_status_code
      FROM xla_ae_headers xah
     WHERE xah.application_id = 200
       AND xah.gl_transfer_status_code = 'Y'
       AND xah.event_id = p_event_id
       AND rownum = 1;

  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  IF l_event_status_code = 'P' OR
     l_gl_transfer_status_code = 'Y' THEN
    RETURN;
  END IF;

  DELETE FROM xla_distribution_links xdl
   WHERE xdl.application_id = 200
     AND xdl.ae_header_id IN
         (SELECT xah.ae_header_id
            FROM xla_ae_headers xah
           WHERE xah.application_id =200
             AND xah.event_id = p_event_id
         );

  DELETE FROM xla_ae_lines xal
   WHERE xal.application_id = 200
     AND xal.ae_header_id IN
         (SELECT xah.ae_header_id
            FROM xla_ae_headers xah
           WHERE xah.application_id =200
             AND xah.event_id = p_event_id
         );

  DELETE FROM xla_ae_headers xah
   WHERE xah.application_id =200
     AND xah.event_id = p_event_id;

  IF p_delete_event = 'Y' THEN
    DELETE FROM xla_events xe
     WHERE xe.application_id = 200
       AND xe.event_id = p_event_id;
  END IF;

  IF p_commit_flag = 'Y' THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE <> -20001 THEN
      l_error_log := ' Encountered an Unhandled Exception, '||SQLCODE||'-'||SQLERRM||
                     ' in '||l_calling_sequence||' while performing '||l_debug_info;
      Print(l_error_log);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION();
END;


-- bug9342663, modified the procedure to check for the
-- closing status of AP periods only when it belongs
-- to the Primary Ledger, since AP does not have any
-- UI or controls for the secondary or ALC ledger
-- periods, nor are they used in any AP flow
--

PROCEDURE check_period
      (p_bug_no                      IN          NUMBER,
       p_driver_table                IN          VARCHAR2,
       p_check_event_date            IN          VARCHAR2 DEFAULT 'Y',
       p_check_sysdate               IN          VARCHAR2 DEFAULT 'N',
       p_chk_proposed_undo_date      IN          VARCHAR2 DEFAULT 'N',
       p_update_process_flag         IN          VARCHAR2,
       P_calc_undo_date              IN          VARCHAR2,
       P_commit_flag                 IN          VARCHAR2 DEFAULT 'N',
       p_calling_sequence            IN          VARCHAR2) IS

  l_sql_stmt                            LONG;
  l_bug_no                              VARCHAR2(100);
  l_driver_table                        ALL_TABLES.TABLE_NAME%TYPE;
  l_debug_info                          VARCHAR2(4000);
  l_error_log                           LONG;
  l_date_string                         VARCHAR2(100);
  l_dummy                               NUMBER;
  l_check_process_flag                  VARCHAR2(1) := 'N';
  l_check_proposed_col                  VARCHAR2(1) := 'N';
  l_update_process_flag                 VARCHAR2(1);
  l_message                             VARCHAR2(4000);
  l_calling_sequence                    VARCHAR2(4000);

  TYPE refcurtyp            IS          REF CURSOR;
  closed_period_trx                     REFCURTYP;

  TYPE event_id_t                 IS TABLE OF XLA_AE_HEADERS.EVENT_ID%TYPE                        INDEX BY BINARY_INTEGER;
  TYPE event_type_code_t          IS TABLE OF XLA_AE_HEADERS.EVENT_TYPE_CODE%TYPE                 INDEX BY BINARY_INTEGER;
  TYPE ae_header_id_t             IS TABLE OF XLA_AE_HEADERS.AE_HEADER_ID%TYPE                    INDEX BY BINARY_INTEGER;
  TYPE accounting_date_t          IS TABLE OF XLA_AE_HEADERS.ACCOUNTING_DATE%TYPE                 INDEX BY BINARY_INTEGER;
  TYPE source_type_t              IS TABLE OF VARCHAR2(100)                                       INDEX BY BINARY_INTEGER;
  TYPE source_id_int_1_t          IS TABLE OF XLA_TRANSACTION_ENTITIES.SOURCE_ID_INT_1%TYPE       INDEX BY BINARY_INTEGER;
  TYPE transaction_number_t       IS TABLE OF XLA_TRANSACTION_ENTITIES.TRANSACTION_NUMBER%TYPE    INDEX BY BINARY_INTEGER;
  TYPE security_id_int_1_t        IS TABLE OF XLA_TRANSACTION_ENTITIES.SECURITY_ID_INT_1%TYPE     INDEX BY BINARY_INTEGER;
  TYPE period_name_t              IS TABLE OF GL_PERIOD_STATUSES.PERIOD_NAME%TYPE                 INDEX BY BINARY_INTEGER;
  TYPE closing_status_t           IS TABLE OF VARCHAR2(100)                                       INDEX BY BINARY_INTEGER;
  TYPE ledger_name_t              IS TABLE OF GL_LEDGERS.NAME%TYPE                                INDEX BY BINARY_INTEGER;

  TYPE period_close_rec_typ IS RECORD
    (event_id_l                event_id_t,
     event_type_code_l         event_type_code_t,
     ae_header_id_l            ae_header_id_t,
     accounting_date_l         accounting_date_t,
     source_type_l             source_type_t,
     source_id_int_1_l         source_id_int_1_t,
     transaction_number_l      transaction_number_t,
     security_id_int_1_l       security_id_int_1_t,
     period_name_l             period_name_t,
     closing_status_l          closing_status_t,
     ledger_name_l             ledger_name_t);

  period_close_list               PERIOD_CLOSE_REC_TYP;

BEGIN

  l_calling_sequence := 'AP_ACCTG_DATA_FIX_PKG.Check_Period <- '||p_calling_sequence;
  l_bug_no := p_bug_no;

  l_debug_info := 'Constructing the name of the driver table';
  IF p_driver_table IS NOT NULL THEN
    l_driver_table := upper(p_driver_table);
  ELSE
    l_driver_table := 'AP_TEMP_DATA_DRIVER_'||l_bug_no;
  END IF;

  l_debug_info := 'Verifying the input parameters for the API, wrt dates';
  IF nvl(p_check_sysdate, 'N') = 'N' AND
     nvl(p_check_event_date, 'N') = 'N' AND
     nvl(p_chk_proposed_undo_date, 'N') = 'N' THEN
    l_error_log := ' Period check needs to be performed either on event_date '||
                   ' or for a specific date ';
    Print(l_error_log);
    APP_EXCEPTION.RAISE_EXCEPTION();
  END IF;

  l_debug_info := 'Checking for the presence of the event_id column in the '||
                  'driver ';
  BEGIN
    SELECT 1
      INTO l_dummy
      FROM sys.all_tab_columns
     WHERE table_name = l_driver_table
       AND column_name = 'EVENT_ID';

  EXCEPTION
    WHEN OTHERS THEN
      l_error_log := 'Could not find the column event_id in the driver table '||
                     l_driver_table||' : aborting';
      Print(l_error_log);
      APP_EXCEPTION.RAISE_EXCEPTION();
  END;

  l_debug_info := 'Check for the presence of the process_flag on the driver table ';
  BEGIN
    SELECT 'Y'
      INTO l_check_process_flag
      FROM sys.all_tab_columns
     WHERE table_name = l_driver_table
       AND column_name = 'PROCESS_FLAG';

  EXCEPTION
    WHEN OTHERS THEN
      l_debug_info := 'The column process_flag is not found in the table';
      l_check_process_flag := 'N';
  END;

  l_debug_info := 'The column process flag does not exist, proceeding to add it for '||
                  'further reporting and calculations ';
  IF l_check_process_flag <> 'Y' THEN

    l_sql_stmt := 'ALTER TABLE '||l_driver_table||' ADD (process_flag VARCHAR2(1) DEFAULT ''Y'') ';
    EXECUTE IMMEDIATE l_sql_stmt;

  END IF;

  l_debug_info := 'If the api has been called to calculate the Undo Date, process_flag '||
                  'must get updated';
  l_update_process_flag := p_update_process_flag;
  IF P_calc_undo_date = 'Y' THEN
    l_update_process_flag := 'Y';
  END IF;

  l_debug_info := 'Checking the events having a user proposed undo date';
  BEGIN
    SELECT 'Y'
      INTO l_check_proposed_col
      FROM sys.all_tab_columns
     WHERE table_name = l_driver_table
       AND column_name = 'PROPOSED_UNDO_DATE';

   EXCEPTION
     WHEN OTHERS THEN
       l_check_proposed_col := 'N';
   END;

   l_debug_info := 'Proceeding to display all of the transactions which have undo '||
                   'Date entered by the user which is in a closed period ';
   IF p_chk_proposed_undo_date = 'Y' AND l_check_proposed_col = 'Y' THEN
     l_debug_info := 'Constructing the dynamic sql for checking the undo date';
     l_sql_stmt :=
        ' SELECT DISTINCT '||
        '        xah.event_id, '||
        '        xah.event_type_code, '||
        '        xah.ae_header_id, '||
        '        xah.accounting_date, '||
        '        DECODE(xte.entity_code, '||
        '               ''AP_INVOICES'', ''Invoice'', '||
        '               ''AP_PAYMENTS'', ''Payments''), '||
        '        xte.source_id_int_1, '||
        '        xte.transaction_number, '||
        '        xte.security_id_int_1, '||
        '        glps.period_name, '||
        '        DECODE(glps.closing_status, '||
        '               ''C'', ''Closed'', '||
        '               ''N'', ''Never Opened'', '||
        '               ''Not-Open''), '||
        '        gl.name '||
        '   FROM xla_events xe, '||
        '        xla_ae_headers xah, '||
                 l_driver_table||' dr, '||
        '        xla_transaction_entities_upg xte, '||
        '        gl_period_statuses glps, '||
        '        gl_ledgers gl '||
        '  WHERE xe.application_id = 200 '||
        '    AND xah.application_id =200 '||
        '    AND xte.application_id =200 '||
        '    AND xe.event_id = dr.event_id '||
        '    AND xe.entity_id = xte.entity_id '||
        '    AND xe.event_id = xah.event_id '||
        '    AND xah.entity_id = xte.entity_id '||
        '    AND xe.event_status_code = ''P'' '||
        '    AND xah.accounting_entry_status_code = ''F'' '||
        '    AND xah.event_type_code <> ''MANUAL'' '||
        '    AND (glps.application_id = 101 OR '||
        '        (glps.application_id = 200 AND '||
        '         xah.ledger_id = xte.ledger_id)) '||
        '    AND nvl(glps.adjustment_period_flag, ''N'') = ''N'' '||
        '    AND glps.set_of_books_id = xah.ledger_id '||
        '    AND glps.closing_status NOT IN (''O'',''F'') '||
        '    AND dr.proposed_undo_date IS NOT NULL '||
        '    AND dr.proposed_undo_date BETWEEN glps.start_date AND glps.end_date '||
        '    AND xah.ledger_id = gl.ledger_id ';

     l_message := '<b><u>Following Events would not be Un-Accounted because the '||
                  'Date provided by the User is in a closed Period</u></b>';
     Print(l_message);

     l_message := '<table border="5">'||
                  '<th>EVENT_ID</th>'||
                  '<th>EVENT_TYPE_CODE</th>'||
                  '<th>AE_HEADER_ID</th>'||
                  '<th>ACCOUNTING_DATE</th>'||
                  '<th>SOURCE_TYPE</th>'||
                  '<th>SOURCE_ID_INT_1</th>'||
                  '<th>TRANSACTION_NUMBER</th>'||
                  '<th>SECURITY_ID_INT_1</th>'||
                  '<th>PROPOSED_PERIOD_NAME</th>'||
                  '<th>CLOSING_STATUS</th>'||
                  '<th>LEDGER_NAME</th></tr>';

     print(l_message);

     OPEN closed_period_trx FOR l_sql_stmt;
     LOOP
       FETCH closed_period_trx
       BULK COLLECT INTO period_close_list.event_id_l,
                      period_close_list.event_type_code_l,
                      period_close_list.ae_header_id_l,
                      period_close_list.accounting_date_l,
                      period_close_list.source_type_l,
                      period_close_list.source_id_int_1_l,
                      period_close_list.transaction_number_l,
                      period_close_list.security_id_int_1_l,
                      period_close_list.period_name_l,
                      period_close_list.closing_status_l,
                      period_close_list.ledger_name_l  LIMIT 1000;

       IF period_close_list.event_id_l.COUNT > 0 THEN
         FOR i IN period_close_list.event_id_l.FIRST..period_close_list.event_id_l.LAST LOOP
           l_message :=
             '<tr><td>'||
                to_char(period_close_list.event_id_l(i))||'</td><td>'||
                period_close_list.event_type_code_l(i)||'</td><td>'||
                to_char(period_close_list.ae_header_id_l(i))||'</td><td>'||
                to_char(period_close_list.accounting_date_l(i), 'DD-MON-YYYY')||'</td><td>'||
                period_close_list.source_type_l(i)||'</td><td>'||
                to_char(period_close_list.source_id_int_1_l(i))||'</td><td>'||
                period_close_list.transaction_number_l(i)||'</td><td>'||
                to_char(period_close_list.security_id_int_1_l(i))||'</td><td>'||
                period_close_list.period_name_l(i)||'</td><td>'||
                period_close_list.closing_status_l(i)||'</td><td>'||
                period_close_list.ledger_name_l(i)||'</td></tr>';

           print(l_message);
         END LOOP;
       END IF;

        IF (l_update_process_flag = 'Y' AND period_close_list.event_id_l.COUNT > 0) THEN

          l_debug_info := 'The column process_flag has been found, proceeding to update';
          FOR i IN period_close_list.event_id_l.FIRST..period_close_list.event_id_l.LAST LOOP
            l_sql_stmt :=
                 ' UPDATE '||l_driver_table||
                 ' SET process_flag = ''N'' '||
                 ' WHERE event_id = '||period_close_list.event_id_l(i);

            l_debug_info := 'Proceeding to update the process flag for the event '||
                            period_close_list.event_id_l(i);
            EXECUTE IMMEDIATE l_sql_stmt;
          END LOOP;

        END IF;

       EXIT WHEN closed_period_trx%NOTFOUND;
     END LOOP;

     l_message := '</table>';
     print(l_message);
   END IF;

  -- Find out all the events for which there exists at least one of the secondary
  -- ledgers, for which the period is not OPEN in AP or GL for the event
  -- date AND for the parameter date, depending on options passed:

  IF (nvl(p_check_sysdate, 'N') <> 'N' OR
      nvl(p_check_event_date, 'N') <> 'N') THEN

    IF p_check_sysdate = 'Y' THEN
       l_date_string := ' trunc(sysdate) ';
    ELSE
       l_date_string := ' XE.event_date ';
    END IF;

    l_debug_info := 'Pos 2 Constructing the statement for fetching the period info';
    l_sql_stmt :=
        ' SELECT DISTINCT '||
        '        xah.event_id, '||
        '        xah.event_type_code, '||
        '        xah.ae_header_id, '||
        '        xah.accounting_date, '||
        '        DECODE(xte.entity_code, '||
        '               ''AP_INVOICES'', ''Invoice'', '||
        '               ''AP_PAYMENTS'', ''Payments''), '||
        '        xte.source_id_int_1, '||
        '        xte.transaction_number, '||
        '        xte.security_id_int_1, '||
        '        glps.period_name, '||
        '        DECODE(glps.closing_status, '||
        '               ''C'', ''Closed'', '||
        '               ''N'', ''Never Opened'', '||
        '               ''Not-Open''), '||
        '        gl.name '||
        '   FROM xla_events xe, '||
        '        xla_ae_headers xah, '||
                 l_driver_table||' dr, '||
        '        xla_transaction_entities_upg xte, '||
        '        gl_period_statuses glps, '||
        '        gl_ledgers gl '||
        '  WHERE xe.application_id = 200 '||
        '    AND xah.application_id =200 '||
        '    AND xte.application_id =200 '||
        '    AND xe.event_id = dr.event_id '||
        '    AND xe.entity_id = xte.entity_id '||
        '    AND xe.event_id = xah.event_id '||
        '    AND xah.entity_id = xte.entity_id '||
        '    AND xe.event_status_code = ''P'' '||
        '    AND xah.accounting_entry_status_code = ''F'' '||
        '    AND xah.event_type_code <> ''MANUAL'' '||
        '    AND (glps.application_id = 101 OR '||
        '        (glps.application_id = 200 AND '||
        '         xah.ledger_id = xte.ledger_id)) '||
        '    AND nvl(glps.adjustment_period_flag, ''N'') = ''N'' '||
        '    AND glps.set_of_books_id = xah.ledger_id '||
        '    AND glps.closing_status NOT IN (''O'',''F'') '||
        '    AND xah.ledger_id = gl.ledger_id '||
        '    AND '||l_date_string||' BETWEEN glps.start_date AND glps.end_date ';

    IF p_chk_proposed_undo_date = 'Y' AND l_check_proposed_col = 'Y' THEN
      l_sql_stmt := l_sql_stmt||
        '    AND dr.proposed_undo_date IS NULL ';
    END IF;

    IF p_check_sysdate = 'Y' AND p_check_event_date = 'Y' THEN
      l_sql_stmt := l_sql_stmt||
                      ' AND EXISTS '||
                      '       (SELECT 1 '||
                      '        FROM gl_period_statuses glpse, '||
                      '             xla_ae_headers xahe '||
                      '        WHERE xahe.application_id = 200 '||
                      '        AND (glpse.application_id = 101 OR '||
                      '             (glpse.application_id = 200 AND '||
                      '              xahe.ledger_id = xte.ledger_id)) '||
                      '        AND xahe.event_id = xe.event_id '||
                      '        AND nvl(glpse.adjustment_period_flag, ''N'') = ''N'' '||
                      '        AND glpse.set_of_books_id = xahe.ledger_id '||
                      '        AND glpse.closing_status NOT IN (''O'',''F'') '||
                      '        AND xe.event_date BETWEEN glpse.start_date AND glpse.end_date) ';
    END IF;

    --Print(l_sql_stmt);

    l_message := '<b><u>The Following events cannot be Unaccounted';
    IF p_check_event_date = 'Y' AND nvl(p_check_sysdate, 'N') = 'N' THEN
      l_message := l_message||' On the same Date as the Original Event Date because the Original Period is Closed</u></b> ';
    ELSIF nvl(p_check_event_date, 'N') = 'N' AND p_check_sysdate = 'Y' THEN
      l_message := l_message||' On the SYSDATE because the current Period is Closed</u></b>';
    ELSIF p_check_event_date = 'Y' AND p_check_sysdate = 'Y' THEN
      l_message := l_message||' On the same Date as the Original Event Date or the Sysdate because both Original '||
                   ' and Current Periods are Closed</u></b>';
    END IF;

    Print(l_message);

    l_message := '<table border="5">'||
                 '<th>EVENT_ID</th>'||
                 '<th>EVENT_TYPE_CODE</th>'||
                 '<th>AE_HEADER_ID</th>'||
                 '<th>ACCOUNTING_DATE</th>'||
                 '<th>SOURCE_TYPE</th>'||
                 '<th>SOURCE_ID_INT_1</th>'||
                 '<th>TRANSACTION_NUMBER</th>'||
                 '<th>SECURITY_ID_INT_1</th>'||
                 '<th>PERIOD_NAME</th>'||
                 '<th>CLOSING_STATUS</th>'||
                 '<th>LEDGER_NAME</th></tr>';

    print(l_message);

    OPEN closed_period_trx FOR l_sql_stmt;
    LOOP
      FETCH closed_period_trx
      BULK COLLECT INTO period_close_list.event_id_l,
                        period_close_list.event_type_code_l,
                        period_close_list.ae_header_id_l,
                        period_close_list.accounting_date_l,
                        period_close_list.source_type_l,
                        period_close_list.source_id_int_1_l,
                        period_close_list.transaction_number_l,
                        period_close_list.security_id_int_1_l,
                        period_close_list.period_name_l,
                        period_close_list.closing_status_l,
                        period_close_list.ledger_name_l  LIMIT 1000;

      IF period_close_list.event_id_l.COUNT > 0 THEN
        FOR i IN period_close_list.event_id_l.FIRST..period_close_list.event_id_l.LAST LOOP
          l_message :=
             '<tr><td>'||
                to_char(period_close_list.event_id_l(i))||'</td><td>'||
                period_close_list.event_type_code_l(i)||'</td><td>'||
                to_char(period_close_list.ae_header_id_l(i))||'</td><td>'||
                to_char(period_close_list.accounting_date_l(i), 'DD-MON-YYYY')||'</td><td>'||
                period_close_list.source_type_l(i)||'</td><td>'||
                to_char(period_close_list.source_id_int_1_l(i))||'</td><td>'||
                period_close_list.transaction_number_l(i)||'</td><td>'||
                to_char(period_close_list.security_id_int_1_l(i))||'</td><td>'||
                period_close_list.period_name_l(i)||'</td><td>'||
                period_close_list.closing_status_l(i)||'</td><td>'||
                period_close_list.ledger_name_l(i)||'</td></tr>';

           print(l_message);
        END LOOP;
      END IF;

      IF (l_update_process_flag = 'Y' AND period_close_list.event_id_l.COUNT > 0) THEN
        l_debug_info := 'The column process_flag has been found, proceeding to update';
        FOR i IN period_close_list.event_id_l.FIRST..period_close_list.event_id_l.LAST LOOP
          l_sql_stmt :=
                 ' UPDATE '||l_driver_table||
                 ' SET process_flag = ''N'' '||
                 ' WHERE event_id = '||period_close_list.event_id_l(i);

            l_debug_info := 'Proceeding to update the process flag for the event '||
                            period_close_list.event_id_l(i);
            EXECUTE IMMEDIATE l_sql_stmt;
        END LOOP;
      END IF;
      EXIT WHEN closed_period_trx%NOTFOUND;

    END LOOP;
    l_message := '</table>';
    print(l_message);
  END IF;

  IF p_calc_undo_date = 'Y' THEN
    l_debug_info := 'Check for the presence of columns for calculated undo dates and periods';
    BEGIN
      SELECT 1
        INTO l_dummy
        FROM sys.all_tab_columns
       WHERE table_name = l_driver_table
         AND column_name = 'CALCULATED_UNDO_DATE';

    EXCEPTION
      WHEN OTHERS THEN
        l_sql_stmt := ' ALTER TABLE '||l_driver_table||' ADD '||
                      ' (CALCULATED_UNDO_DATE DATE, CALCULATED_UNDO_PERIOD VARCHAR2(100)) ';

        EXECUTE IMMEDIATE l_sql_stmt;
    END;

    --Bug 9436697 changed the update to update dr.proposed_undo_date onto dr.calculated_undo_date

    IF p_chk_proposed_undo_date = 'Y' AND l_check_proposed_col = 'Y' THEN

      l_sql_stmt :=
         ' UPDATE '||l_driver_table ||' dr '||
         '    SET (dr.calculated_undo_date, '||
         '         dr.calculated_undo_period) = '||
         '          (SELECT dr.proposed_undo_date, glps.period_name '||
         '            FROM xla_events xe,  '||
         '                 gl_period_statuses glps, '||
         '                 xla_transaction_entities_upg xte '||
         '           WHERE xe.application_id = 200 '||
         '             AND glps.application_id = 200 '||
         '             AND nvl(glps.adjustment_period_flag, ''N'') = ''N'' '||
         '             AND glps.set_of_books_id = xte.ledger_id '||
         '             AND xte.application_id =200 '||
         '             AND xte.entity_id = xe.entity_id '||
         '             AND dr.event_id = xe.event_id '||
         '             AND dr.proposed_undo_date BETWEEN glps.start_date  '||
         '                                       AND glps.end_date) '||
         ' WHERE 1=1 ';

       IF p_chk_proposed_undo_date = 'Y' AND l_check_proposed_col = 'Y' THEN
         l_sql_stmt := l_sql_stmt||
                          ' AND dr.proposed_undo_date IS NOT NULL ';
       END IF;

       l_sql_stmt := l_sql_stmt||
         ' AND dr.process_flag = ''Y'' '||
         ' AND dr.calculated_undo_date IS NULL '||
         ' AND NOT EXISTS '||
         '     (SELECT 1 '||
         '        FROM gl_period_statuses glps, '||
	 '             xla_transaction_entities_upg xte, '||
         '             xla_ae_headers xah '||
         '       WHERE (glps.application_id = 101 OR '||
         '              (glps.application_id = 200 AND '||
         '               xah.ledger_id = xte.ledger_id)) '||
         '         AND dr.event_id = xah.event_id '||
         '         AND xah.application_id =200 '||
	 '         AND xte.application_id =200 '||
	 '         AND xah.entity_id = xte.entity_id '||
         '         AND xah.ledger_id = glps.set_of_books_id '||
         '         AND nvl(glps.adjustment_period_flag, ''N'') = ''N'' '||
         '         AND dr.proposed_undo_date BETWEEN glps.start_date  '||
         '                                   AND glps.end_date '||
         '         AND glps.closing_status NOT IN (''O'',''F'')) ';

      l_debug_info := 'Before updating the calculated values where the event date is open';
      EXECUTE IMMEDIATE l_sql_stmt;

    END IF;

    IF p_check_event_date = 'Y' THEN
      l_debug_info := ' Updating calculated date and period for all records where event date '||
                      ' is in an open period ';

      l_sql_stmt :=
         ' UPDATE '||l_driver_table ||' dr '||
         '    SET (dr.calculated_undo_date, '||
         '         dr.calculated_undo_period) = '||
         '          (SELECT xe.event_date, glps.period_name '||
         '            FROM xla_events xe,  '||
         '                 gl_period_statuses glps, '||
         '                 xla_transaction_entities_upg xte '||
         '           WHERE xe.application_id = 200 '||
         '             AND glps.application_id = 200 '||
         '             AND nvl(glps.adjustment_period_flag, ''N'') = ''N'' '||
         '             AND glps.set_of_books_id = xte.ledger_id '||
         '             AND xte.application_id =200 '||
         '             AND xte.entity_id = xe.entity_id '||
         '             AND dr.event_id = xe.event_id '||
         '             AND xe.event_date BETWEEN glps.start_date  '||
         '                                   AND glps.end_date) '||
         ' WHERE 1=1 ';

       IF p_chk_proposed_undo_date = 'Y' AND l_check_proposed_col = 'Y' THEN
         l_sql_stmt := l_sql_stmt||
                          ' AND dr.proposed_undo_date IS NULL ';
       END IF;

       l_sql_stmt := l_sql_stmt||
         ' AND dr.process_flag = ''Y'' '||
         ' AND dr.calculated_undo_date IS NULL '||
         ' AND NOT EXISTS '||
         '     (SELECT 1 '||
         '        FROM gl_period_statuses glps, '||
	 '             xla_transaction_entities_upg xte, '||
         '             xla_ae_headers xah '||
         '       WHERE (glps.application_id = 101 OR '||
         '              (glps.application_id = 200 AND '||
         '               xah.ledger_id = xte.ledger_id)) '||
         '         AND dr.event_id = xah.event_id '||
         '         AND xah.application_id =200 '||
	 '         AND xte.application_id =200 '||
	 '         AND xah.entity_id = xte.entity_id '||
         '         AND xah.ledger_id = glps.set_of_books_id '||
         '         AND nvl(glps.adjustment_period_flag, ''N'') = ''N'' '||
         '         AND xah.accounting_date BETWEEN glps.start_date  '||
         '                                AND glps.end_date '||
         '         AND glps.closing_status NOT IN (''O'',''F'')) ';

      l_debug_info := 'Before updating the calculated values where the event date is open';
      EXECUTE IMMEDIATE l_sql_stmt;
    END IF;

    IF p_check_sysdate = 'Y' THEN
      l_debug_info := ' Updating calculated date and period for all records where sysdate '||
                      ' is in an open period ';
      l_sql_stmt :=
         ' UPDATE '||l_driver_table ||' dr '||
         '    SET (dr.calculated_undo_date, '||
         '         dr.calculated_undo_period) = '||
         '          (SELECT trunc(sysdate), glps.period_name '||
         '            FROM xla_events xe,  '||
         '                 gl_period_statuses glps, '||
         '                 xla_transaction_entities_upg xte '||
         '           WHERE xe.application_id = 200 '||
         '             AND glps.application_id = 200 '||
         '             AND nvl(glps.adjustment_period_flag, ''N'') = ''N'' '||
         '             AND glps.set_of_books_id = xte.ledger_id '||
         '             AND xte.application_id =200 '||
         '             AND xte.entity_id = xe.entity_id '||
         '             AND dr.event_id = xe.event_id '||
         '             AND trunc(sysdate) BETWEEN glps.start_date  '||
         '                                    AND glps.end_date) '||
         ' WHERE 1=1 ';

       IF p_chk_proposed_undo_date = 'Y' AND l_check_proposed_col = 'Y' THEN
         l_sql_stmt := l_sql_stmt||
                          ' AND dr.proposed_undo_date IS NULL ';
       END IF;

       l_sql_stmt := l_sql_stmt||
         ' AND dr.process_flag = ''Y'' '||
         ' AND dr.calculated_undo_date IS NULL '||
         ' AND NOT EXISTS '||
         '     (SELECT 1 '||
         '        FROM gl_period_statuses glps, '||
	 '             xla_transaction_entities_upg xte, '||
         '             xla_ae_headers xah '||
         '       WHERE (glps.application_id = 101 OR '||
         '              (glps.application_id = 200 AND '||
         '               xah.ledger_id = xte.ledger_id)) '||
         '         AND dr.event_id = xah.event_id '||
         '         AND xah.application_id =200 '||
	 '         AND xte.application_id =200 '||
	 '         AND xah.entity_id = xte.entity_id '||
         '         AND xah.ledger_id = glps.set_of_books_id '||
         '         AND nvl(glps.adjustment_period_flag, ''N'') = ''N'' '||
         '         AND trunc(sysdate) BETWEEN glps.start_date  '||
         '                                AND glps.end_date '||
         '         AND glps.closing_status NOT IN (''O'',''F'')) ';

      l_debug_info := 'Before updating the calculated values for events where event date is closed, '||
                      'and there is no proposed date';
      EXECUTE IMMEDIATE l_sql_stmt;
    END IF;

  END IF;

  IF p_commit_flag = 'Y' THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE <> -20001 THEN
      l_error_log := ' Encountered an Unhandled Exception, '||SQLCODE||'-'||SQLERRM||
                       ' in '||l_calling_sequence||' while performing '||l_debug_info;
      Print(l_error_log);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION();
END;

PROCEDURE check_ccid
      (p_bug_no                       IN          NUMBER,
       p_driver_table                 IN          VARCHAR2,
       p_update_process_flag          IN          VARCHAR2,
       p_commit_flag                  IN          VARCHAR2 DEFAULT 'N',
       p_calling_sequence             IN          VARCHAR2) IS

  l_sql_stmt                            LONG;
  l_bug_no                              VARCHAR2(100);
  l_driver_table                        ALL_TABLES.TABLE_NAME%TYPE;
  l_debug_info                          VARCHAR2(4000);
  l_error_log                           LONG;
  l_date                                VARCHAR2(100);
  l_dummy                               NUMBER;
  l_check_process_flag                  VARCHAR2(1) := 'N';
  l_message                             VARCHAR2(4000);
  l_calling_sequence                    VARCHAR2(4000);

  TYPE event_id_t                 IS TABLE OF XLA_AE_HEADERS.EVENT_ID%TYPE                          INDEX BY BINARY_INTEGER;
  TYPE event_type_code_t          IS TABLE OF XLA_AE_HEADERS.EVENT_TYPE_CODE%TYPE                   INDEX BY BINARY_INTEGER;
  TYPE ae_header_id_t             IS TABLE OF XLA_AE_HEADERS.AE_HEADER_ID%TYPE                      INDEX BY BINARY_INTEGER;
  TYPE accounting_date_t          IS TABLE OF XLA_AE_HEADERS.ACCOUNTING_DATE%TYPE                   INDEX BY BINARY_INTEGER;
  TYPE ae_line_num_t              IS TABLE OF XLA_AE_LINES.AE_LINE_NUM%TYPE                         INDEX BY BINARY_INTEGER;
  TYPE accounting_class_code_t    IS TABLE OF XLA_AE_LINES.ACCOUNTING_CLASS_CODE%TYPE               INDEX BY BINARY_INTEGER;
  TYPE source_type_t              IS TABLE OF VARCHAR2(100)                                         INDEX BY BINARY_INTEGER;
  TYPE source_id_int_1_t          IS TABLE OF XLA_TRANSACTION_ENTITIES.SOURCE_ID_INT_1%TYPE         INDEX BY BINARY_INTEGER;
  TYPE transaction_number_t       IS TABLE OF XLA_TRANSACTION_ENTITIES.TRANSACTION_NUMBER%TYPE      INDEX BY BINARY_INTEGER;
  TYPE security_id_int_1_t        IS TABLE OF XLA_TRANSACTION_ENTITIES.SECURITY_ID_INT_1%TYPE       INDEX BY BINARY_INTEGER;
  TYPE code_combination_id_t      IS TABLE OF GL_CODE_COMBINATIONS.CODE_COMBINATION_ID%TYPE         INDEX BY BINARY_INTEGER;
  TYPE account_t                  IS TABLE OF VARCHAR2(1000)                                        INDEX BY BINARY_INTEGER;
  TYPE enabled_flag_t             IS TABLE OF GL_CODE_COMBINATIONS.ENABLED_FLAG%TYPE                INDEX BY BINARY_INTEGER;
  TYPE end_date_active_t          IS TABLE OF GL_CODE_COMBINATIONS.END_DATE_ACTIVE%TYPE             INDEX BY BINARY_INTEGER;
  TYPE ledger_name_t              IS TABLE OF GL_LEDGERS.NAME%TYPE                           INDEX BY BINARY_INTEGER;

  TYPE invalid_ccid_rec_typ IS RECORD
   (event_id_l                  event_id_t,
    event_type_code_l           event_type_code_t,
    ae_header_id_l              ae_header_id_t,
    accounting_date_l           accounting_date_t,
    ae_line_num_l               ae_line_num_t,
    accounting_class_code_l     accounting_class_code_t,
    source_type_l               source_type_t,
    source_id_int_1_l           source_id_int_1_t,
    transaction_number_l        transaction_number_t,
    security_id_int_1_l         security_id_int_1_t,
    code_combination_id_l       code_combination_id_t,
    account_l                   account_t,
    enabled_flag_l              enabled_flag_t,
    end_date_active_l           end_date_active_t,
    ledger_name_l               ledger_name_t);

  invalid_ccid_list                     INVALID_CCID_REC_TYP;

  TYPE refcurtyp            IS          REF CURSOR;
  invalid_ccid                          REFCURTYP;

BEGIN

  l_calling_sequence := 'AP_ACCTG_DATA_FIX_PKG.check_ccid <- '||p_calling_sequence;
  l_bug_no := p_bug_no;

  l_debug_info := 'Constructing the driver table name';
  IF p_driver_table IS NOT NULL THEN
    l_driver_table := upper(p_driver_table);
  ELSE
    l_driver_table := 'AP_TEMP_DATA_DRIVER_'||p_bug_no;
  END IF;

  l_debug_info := 'Constructing the sql statement ';
  l_sql_stmt :=
    ' SELECT DISTINCT '||
    '        xah.event_id, '||
    '        xah.event_type_code, '||
    '        xah.ae_header_id, '||
    '        xah.accounting_date, '||
    '        xal.ae_line_num, '||
    '        xal.accounting_class_code, '||
    '        DECODE(xte.entity_code, '||
    '               ''AP_INVOICES'', ''Invoice'', '||
    '               ''AP_PAYMENTS'', ''Payments''), '||
    '        xte.source_id_int_1, '||
    '        xte.transaction_number, '||
    '        xte.security_id_int_1, '||
    '        glcc.code_combination_id, '||
    '        glcc.padded_concatenated_segments, '||
    '        glcc.enabled_flag, '||
    '        glcc.end_date_active, '||
    '        gl.name '||
    '   FROM xla_events xe, '||
    '        xla_ae_headers xah, '||
    '        xla_ae_lines xal, '||
             l_driver_table||' dr, '||
    '        xla_transaction_entities_upg xte, '||
    '        gl_code_combinations_kfv glcc, '||
    '        gl_ledgers gl '||
    '  WHERE xe.application_id = 200 '||
    '    AND xah.application_id = 200 '||
    '    AND xal.application_id = 200 '||
    '    AND xte.application_id =200 '||
    '    AND xe.event_id = dr.event_id '||
    '    AND xe.entity_id = xte.entity_id '||
    '    AND xe.event_id = xah.event_id '||
    '    AND xah.entity_id = xte.entity_id '||
    '    AND xe.event_status_code = ''P'' '||
    '    AND xah.accounting_entry_status_code = ''F'' '||
    '    AND xah.event_type_code <> ''MANUAL'' '||
    '    AND xah.ae_header_id = xal.ae_header_id '||
    '    AND xal.code_combination_id = glcc.code_combination_id '||
    '    AND (glcc.enabled_flag = ''N'' OR glcc.end_date_active IS NOT NULL) '||
    '    AND xah.ledger_id = gl.ledger_id ';

  --Print(l_sql_stmt);

  l_message := '<b><u>The following events cannot be Unaccounted because the Code Combination Id is not Enabled</u></b>';
  Print(l_message);

  l_message := '<table border="5">'||
               '<th>EVENT_ID</th>'||
               '<th>EVENT_TYPE_CODE</th>'||
               '<th>AE_HEADER_ID</th>'||
               '<th>ACCOUNTING_DATE</th>'||
               '<th>AE_LINE_NUM</th>'||
               '<th>ACCOUNTING_CLASS_CODE</th>'||
               '<th>SOURCE_TYPE</th>'||
               '<th>SOURCE_ID_INT_1</th>'||
               '<th>TRANSACTION_NUMBER</th>'||
               '<th>SECURITY_ID_INT_1</th>'||
               '<th>CODE_COMBINATION_ID</th>'||
               '<th>ACCOUNT</th>'||
               '<th>ENABLED_FLAG</th>'||
               '<th>END_DATE_ACTIVE</th>'||
               '<th>LEDGER_NAME</tr>';
  print(l_message);

  OPEN invalid_ccid FOR l_sql_stmt;
  LOOP
    FETCH invalid_ccid
    BULK COLLECT INTO invalid_ccid_list.event_id_l,
                      invalid_ccid_list.event_type_code_l,
                      invalid_ccid_list.ae_header_id_l,
                      invalid_ccid_list.accounting_date_l,
                      invalid_ccid_list.ae_line_num_l,
                      invalid_ccid_list.accounting_class_code_l,
                      invalid_ccid_list.source_type_l,
                      invalid_ccid_list.source_id_int_1_l,
                      invalid_ccid_list.transaction_number_l,
                      invalid_ccid_list.security_id_int_1_l,
                      invalid_ccid_list.code_combination_id_l,
                      invalid_ccid_list.account_l,
                      invalid_ccid_list.enabled_flag_l,
                      invalid_ccid_list.end_date_active_l,
                      invalid_ccid_list.ledger_name_l LIMIT 1000;

     IF invalid_ccid_list.event_id_l.COUNT > 0 THEN
       FOR i IN invalid_ccid_list.event_id_l.FIRST..invalid_ccid_list.event_id_l.LAST LOOP
         l_message :=
           '<tr><td>'||
               to_char(invalid_ccid_list.event_id_l(i))||'</td><td>'||
               invalid_ccid_list.event_type_code_l(i)||'</td><td>'||
               to_char(invalid_ccid_list.ae_header_id_l(i))||'</td><td>'||
               to_char(invalid_ccid_list.accounting_date_l(i), 'DD-MON-YYYY')||'</td><td>'||
               to_char(invalid_ccid_list.ae_line_num_l(i))||'</td><td>'||
               invalid_ccid_list.accounting_class_code_l(i)||'</td><td>'||
               invalid_ccid_list.source_type_l(i)||'</td><td>'||
               to_char(invalid_ccid_list.source_id_int_1_l(i))||'</td><td>'||
               invalid_ccid_list.transaction_number_l(i)||'</td><td>'||
               to_char(invalid_ccid_list.security_id_int_1_l(i))||'</td><td>'||
               to_char(invalid_ccid_list.code_combination_id_l(i))||'</td><td>'||
               invalid_ccid_list.account_l(i)||'</td><td>'||
               invalid_ccid_list.enabled_flag_l(i)||'</td><td>'||
               to_char(invalid_ccid_list.end_date_active_l(i), 'DD-MON-YYYY')||'</td><td>'||
               invalid_ccid_list.ledger_name_l(i)||'</td><tr>';

         print(l_message);
       END LOOP;
     END IF;

     BEGIN
       SELECT 'Y'
         INTO l_check_process_flag
         FROM sys.all_tab_columns
        WHERE table_name = l_driver_table
          AND column_name = 'PROCESS_FLAG';

      EXCEPTION
        WHEN OTHERS THEN
          l_debug_info := 'The column process_flag is not found in the table';
          l_check_process_flag := 'N';

      END;

      IF (l_check_process_flag = 'Y' AND p_update_process_flag = 'Y') THEN

        l_debug_info := 'The column process_flag has been found, proceeding to update';

        IF invalid_ccid_list.event_id_l.COUNT > 0 THEN
          FOR i IN invalid_ccid_list.event_id_l.FIRST..invalid_ccid_list.event_id_l.LAST LOOP
            l_sql_stmt :=
                 ' UPDATE '||l_driver_table||
                 ' SET process_flag = ''N'' '||
                 ' WHERE event_id = '||invalid_ccid_list.event_id_l(i);

            l_debug_info := 'Proceeding to update the process flag for the event '||
                            invalid_ccid_list.event_id_l(i);
            EXECUTE IMMEDIATE l_sql_stmt;
          END LOOP;
        END IF;

      END IF;

     EXIT WHEN invalid_ccid%NOTFOUND;
  END LOOP;

  l_message := '</table>';
  print(l_message);

  IF p_commit_flag = 'Y' THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE <> -20001 THEN
      l_error_log := ' Encountered an Unhandled Exception, '||SQLCODE||'-'||SQLERRM||
                       ' in '||l_calling_sequence||' while performing '||l_debug_info;
      Print(l_error_log);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION();
END;

PROCEDURE Undo_Accounting
     (p_Source_Table      IN VARCHAR2,
      p_Source_Id         IN NUMBER,
      p_Event_Id          IN NUMBER DEFAULT NULL,
      p_skip_date_calc    IN VARCHAR2 DEFAULT 'N',
      p_undo_date         IN DATE,
      p_undo_period       IN VARCHAR2,
      p_bug_id            IN NUMBER DEFAULT NULL,
      p_Gl_Date           IN DATE DEFAULT NULL, --Bug#8471406
      p_rev_event_id      OUT NOCOPY NUMBER,
      p_new_event_id      OUT NOCOPY NUMBER,
      p_return_code       OUT NOCOPY VARCHAR2,
      p_calling_sequence  IN VARCHAR2
      )
IS
  l_aPi_Version              NUMBER;
  l_InIt_msg_List            VARCHAR2(300);
  l_Application_Id           INTEGER;
  l_Reversal_Method          VARCHAR2(300);
  l_gl_Date                  DATE;
  l_Post_To_gl_Flag          VARCHAR2(3);
  x_msg_Count                NUMBER;
  x_msg_Data                 VARCHAR2(4000);
  x_Rev_ae_Header_Id         INTEGER;
  x_Rev_Event_Id             INTEGER;
  x_Rev_Entity_Id            INTEGER;
  x_New_Event_Id             INTEGER;
  x_New_Entity_Id            INTEGER;
  l_Rev_Event_Id             INTEGER;
  l_New_Event_Id             INTEGER;
  l_Source_Id                NUMBER;
  l_Return_Status            VARCHAR2(300);
  l_event_status_code        XLA_EVENTS.EVENT_STATUS_CODE%TYPE;
  Debug_Info                 VARCHAR2(50) := 'Undo_Accounting';
  l_calling_sequence         VARCHAR2(4000);

  --Cursor modified to improve performance 7655892

  CURSOR Events_to_Process(p_Check_Or_Invoice_Id NUMBER) IS
    SELECT  /*LEADING(ASP, XTE)*/ DISTINCT xe.event_id,
        security_id_int_1 cur_org_id,
        decode(xte.entity_code,   'AP_PAYMENTS',   'CHECKS',   'AP_INVOICES',   'INVOICES') check_or_invoice,
        gl_transfer_status_code,
        xe.event_date gl_date
  FROM xla_transaction_entities_upg xte,
        xla_events xe,
        xla_ae_headers xah,
        ap_system_parameters_all asp
  WHERE xte.entity_id = xe.entity_id
    AND xe.application_id = 200
    AND xte.entity_code = p_Source_Table
    AND nvl(source_id_int_1,-99) = p_Check_Or_Invoice_Id    --nvl added by bug 7655892
    AND xe.event_status_code = 'P'
    AND xe.process_status_code = 'P'
    AND xah.event_id = xe.event_id
    AND nvl(xe.event_id,   xe.event_id) = nvl(p_Event_Id,   xe.event_id)  --nvl added to both sides in 7655892
    AND xah.application_id = 200
    AND xte.application_id = 200
    AND xah.ledger_id = xte.ledger_id
    AND xte.ledger_id = asp.set_of_books_id             --extra join condition added by 7655892
    AND xte.security_id_int_1 = asp.org_id
    AND nvl(xe.budgetary_control_flag,   'N') = 'N'; -- 7627438

  TYPE Events_to_Process_tab_type IS TABLE of Events_to_Process%ROWTYPE;
  Events_to_Process_tab Events_to_Process_tab_type;

    CURSOR Check_period_Status(p_Date DATE,
                               p_org_id NUMBER) IS
    SELECT DISTINCT gps.Period_Name
      FROM gl_Period_Statuses gps,
           ap_System_Parameters_All Asp
     WHERE gps.Application_Id = 200
       AND gps.Set_Of_Books_Id = Asp.Set_Of_Books_Id
       AND Nvl(gps.Adjustment_Period_Flag,'N') = 'N'
       AND p_Date BETWEEN Trunc(gps.Start_Date)
                              AND Trunc(gps.End_Date)
       AND Nvl(Asp.Org_Id,- 99) = Nvl(p_org_id,- 99)
       AND gps.closing_Status in ('O', 'F')
    INTERSECT
    SELECT DISTINCT gps.Period_Name
      FROM gl_Period_Statuses gps,
           ap_System_Parameters_All Asp
     WHERE gps.Application_Id = 101
       AND gps.Set_Of_Books_Id = Asp.Set_Of_Books_Id
       AND Nvl(gps.Adjustment_Period_Flag,'N') = 'N'
       AND p_Date BETWEEN Trunc(gps.Start_Date)
                              AND Trunc(gps.End_Date)
       AND Nvl(Asp.Org_Id,- 99) = Nvl(p_org_id,- 99)
       AND gps.closing_Status in ('O', 'F');

  /* bug # 7688339. if the event date period and
     sysdate period is not open. it will place
     the accounting reversals for earliest open period.
     the cursor check_open_period will check the
     latest open period for the org_id
  */
     --Bug#8471406 start
    CURSOR Check_Open_Period(p_org_id NUMBER) IS
     SELECT Period_Name, End_Date
     FROM (
      SELECT DISTINCT gps.Period_Name, trunc(gps.End_Date) End_date
      FROM gl_Period_Statuses gps,
           ap_System_Parameters_All Asp
      WHERE gps.Application_Id = 200
       AND gps.Set_Of_Books_Id = Asp.Set_Of_Books_Id
       AND Nvl(gps.Adjustment_Period_Flag,'N') = 'N'
       AND Nvl(Asp.Org_Id,- 99) = Nvl(p_org_id,- 99)
       AND gps.closing_Status in ('O', 'F')
       INTERSECT
      SELECT DISTINCT gps.Period_Name, trunc(gps.End_Date) End_date
      FROM gl_Period_Statuses gps,
           ap_System_Parameters_All Asp
      WHERE gps.Application_Id = 101
       AND gps.Set_Of_Books_Id = Asp.Set_Of_Books_Id
       AND Nvl(gps.Adjustment_Period_Flag,'N') = 'N'
       AND Nvl(Asp.Org_Id,- 99) = Nvl(p_org_id,- 99)
       AND gps.closing_Status in ('O', 'F')
       order by end_date
       )
     WHERE rownum < 2;

    CURSOR Check_Entered_Gl_date(p_org_id NUMBER) IS
     SELECT DISTINCT gps.Period_Name
      FROM gl_Period_Statuses gps,
           ap_System_Parameters_All Asp
      WHERE gps.Application_Id = 200
       AND p_Gl_Date between trunc(gps.start_date) and trunc(gps.end_date)
       AND gps.Set_Of_Books_Id = Asp.Set_Of_Books_Id
       AND Nvl(gps.Adjustment_Period_Flag,'N') = 'N'
       AND Nvl(Asp.Org_Id,- 99) = Nvl(p_org_id,- 99)
       AND gps.closing_Status in ('O', 'F')
     INTERSECT
    SELECT DISTINCT gps.Period_Name
      FROM gl_Period_Statuses gps,
           ap_System_Parameters_All Asp
      WHERE gps.Application_Id = 101
       AND p_Gl_Date between trunc(gps.start_date) and trunc(gps.end_date)
       AND gps.Set_Of_Books_Id = Asp.Set_Of_Books_Id
       AND Nvl(gps.Adjustment_Period_Flag,'N') = 'N'
       AND Nvl(Asp.Org_Id,- 99) = Nvl(p_org_id,- 99)
       AND gps.closing_Status in ('O', 'F');


  l_entered_date DATE;
  l_entered_Period VARCHAR2(15);
  --Bug#8471406 end

  l_Period_Name              VARCHAR2(15);
  l_cur_Period_Name          VARCHAR2(15);
  NULL_VALUE NUMBER := null;
  l_table_name VARCHAR2(20) := 'ALL_TABLES';
  ins_AP_undo_event_log_stmt VARCHAR2(200) := 'INSERT INTO AP_undo_event_log('
     ||'EVENT_ID,E2,E3,STATUS,INVOICE_ID,CHECK_ID, BUG_ID) '||
         'VALUES(:1, :2, :3, :4, :5, :6, :7)';
  log_table_exists_stmt VARCHAR2(200) := 'select count(*) '||
      'from '||l_table_name ||
     ' where table_name = ''AP_UNDO_EVENT_LOG'' ';
  log_table_exists NUMBER ;
   -- Logging:
  l_procedure_name CONSTANT VARCHAR2(30) := 'Undo_Accounting';
  l_log_msg        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

  l_calling_sequence := 'AP_ACCTG_DATA_FIX_PKG <- '||p_calling_sequence;

  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  l_log_msg := 'Begin of procedure '|| l_procedure_name;
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE,
                   G_MODULE_NAME||l_procedure_name||'.begin',
                   l_log_msg);
  END IF;

  l_aPi_Version := 1.0;
  l_InIt_msg_List := fnd_aPi.g_True;
  l_Application_Id := 200;
  l_Reversal_Method := 'SIDE';
  l_Post_To_gl_Flag := 'N';
  l_Source_Id := p_Source_Id;

  EXECUTE IMMEDIATE log_table_exists_stmt into log_table_exists;

   IF ( log_table_exists = 0) THEN

   l_log_msg := 'Before creating Table AP_undo_event_log';
   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE,
                   G_MODULE_NAME||l_procedure_name,
                   l_log_msg);
   END IF;

      BEGIN
         EXECUTE IMMEDIATE 'CREATE TABLE AP_undo_event_log
         (
           EVENT_ID NUMBER,
           E2 integer,E3 integer,STATUS varchar2(300),
          INVOICE_ID NUMBER ,CHECK_ID NUMBER, BUG_ID NUMBER)';

         l_log_msg := 'Created table AP_undo_event_log';
         IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.STRING(G_LEVEL_PROCEDURE,
                   G_MODULE_NAME||l_procedure_name,
                   l_log_msg);
         END IF;

      EXCEPTION
        WHEN OTHERS THEN

         l_log_msg := 'Could not create table AP_undo_event_log';
         IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.STRING(G_LEVEL_PROCEDURE,
                   G_MODULE_NAME||l_procedure_name,
                   l_log_msg);
         END IF;

      END;
   END IF;

   OPEN Events_to_Process(l_Source_Id);
  FETCH Events_to_Process BULK COLLECT INTO Events_to_Process_tab;
  CLOSE Events_to_Process;

  IF(Events_to_Process_tab.COUNT =0) THEN
         l_log_msg := 'No events exist for the parameters passed : '||p_Source_Table
                       || ' , '||p_Source_Id;
         IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.STRING(G_LEVEL_PROCEDURE,
                   G_MODULE_NAME||l_procedure_name,
                   l_log_msg);
         END IF;
  END IF;
  FOR i in 1..Events_to_Process_tab.COUNT LOOP

    IF (p_skip_date_calc = 'Y' AND
        p_undo_date IS NOT NULL AND
        p_undo_period IS NOT NULL) THEN

      l_gl_date := p_undo_date;
      l_period_name := p_undo_period;
    ELSE

     l_gl_Date := Events_to_Process_tab(i).gl_Date;
     OPEN Check_period_Status(l_gl_Date,
                              Events_to_Process_tab(i).Cur_Org_Id);
      FETCH Check_period_Status INTO l_Period_Name;
        IF(Check_period_Status%NOTFOUND ) THEN
          l_Period_Name := null;
        END IF;
      CLOSE Check_period_Status;

      --Bug#8471406 start
      if (l_Period_Name is Null) Then
       if ( p_Gl_Date is not Null) then
          Open Check_Entered_Gl_date(Events_to_Process_tab(i).Cur_Org_Id);
         Fetch Check_Entered_Gl_date into l_entered_period;
           IF(Check_Entered_Gl_date%NOTFOUND ) THEN
                   l_log_msg := 'The entered date did not have any period, please recheck '||
                                ' exiting.....';
                   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                       FND_LOG.STRING(G_LEVEL_PROCEDURE,
                                      G_MODULE_NAME||l_procedure_name,
                                      l_log_msg);
                    END IF;
             RETURN; -- exit undo accounting program
           END IF;
          Close Check_Entered_Gl_date;
        l_gl_Date := p_Gl_Date;
        l_Period_Name := l_entered_period;
       Else       -- p_Gl_Date is null

           FOR Check_Open_Period_rec IN Check_Open_Period(Events_to_Process_tab(i).Cur_Org_Id)
            LOOP
               l_gl_Date := Check_Open_Period_rec.End_Date;
               l_Period_Name := Check_Open_Period_rec.Period_Name;

            END LOOP;

       End if; -- p_Gl_Date is null
      End If; -- transaction date in closed period
    END IF;

  mo_Global.Set_Policy_Context('S',Events_to_Process_tab(i).Cur_Org_Id);

         l_log_msg := 'Set Org context to '||Events_to_Process_tab(i).Cur_Org_Id;
         IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.STRING(G_LEVEL_PROCEDURE,
                   G_MODULE_NAME||l_procedure_name,
                   l_log_msg);
         END IF;

  l_return_status := NULL;
  BEGIN

    IF (Events_to_Process_tab(i).gl_Transfer_Status_Code = 'Y') THEN
        Debug_Info := 'xla_DataFixes_Pub.Reverse_Journal_entries';

         l_log_msg := 'Calling xla_DataFixes_Pub.Reverse_Journal_entries';
         IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.STRING(G_LEVEL_PROCEDURE,
                   G_MODULE_NAME||l_procedure_name,
                   l_log_msg);
         END IF;

      xla_DataFixes_Pub.Reverse_Journal_entries
          (p_aPi_Version      => l_aPi_Version,
           p_InIt_msg_List    => l_InIt_msg_List,
           p_Application_Id   => l_Application_Id,
           p_event_id         => Events_to_Process_tab(i).Event_Id,
           p_Reversal_Method  => l_Reversal_Method,
           p_gl_Date          => l_gl_Date,
           p_Post_To_gl_Flag  => l_Post_To_gl_Flag,
           x_Return_Status    => l_Return_Status,
           x_msg_Count        => x_msg_Count,
           x_msg_Data         => x_msg_Data,
           x_Rev_ae_Header_Id => x_Rev_ae_Header_Id,
           x_Rev_Event_Id     => x_Rev_Event_Id,
           x_Rev_Entity_Id    => x_Rev_Entity_Id,
           x_New_Event_Id     => x_New_Event_Id,
           x_New_Entity_Id    => x_New_Entity_Id);

         l_Rev_Event_Id := x_Rev_Event_Id;
         l_New_Event_Id := x_New_Event_Id;
         p_rev_event_id := x_Rev_Event_Id;
         p_new_event_id := x_New_Event_Id;

         l_log_msg := 'l_Return_Status='||l_Return_Status;
         IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.STRING(G_LEVEL_PROCEDURE,
                   G_MODULE_NAME||l_procedure_name,
                   l_log_msg);
         END IF;

    If(x_msg_Count > 0 OR l_Return_Status = 'U') Then

      l_log_msg := 'Undo_Accounting : Error in xla_DataFixes_Pub.Reverse_Journal_entries
                      :'|| x_msg_Data;
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,
                 G_MODULE_NAME||l_procedure_name,
                 l_log_msg);
      END IF;
      p_return_code := 'XLA_ERROR';

    End If;

  ELSIF(Events_to_Process_tab(i).gl_Transfer_Status_Code = 'N') THEN
      Debug_Info := 'xla_DataFixes_Pub.delete_journal_entries';

         l_log_msg := 'Calling xla_datafixes_pub.delete_journal_entries';
         IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.STRING(G_LEVEL_PROCEDURE,
                   G_MODULE_NAME||l_procedure_name,
                   l_log_msg);
         END IF;

      xla_datafixes_pub.delete_journal_entries
          (p_api_version     => l_aPi_Version,
           p_init_msg_list   => l_InIt_msg_List,
           p_application_id  => l_Application_Id,
           p_event_id        => Events_to_Process_tab(i).Event_Id,
           x_return_status   => l_Return_Status,
           x_msg_count       => x_msg_Count,
           x_msg_data        => x_msg_Data);

         l_log_msg := 'l_Return_Status='||l_Return_Status;
         IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.STRING(G_LEVEL_PROCEDURE,
                   G_MODULE_NAME||l_procedure_name,
                   l_log_msg);
         END IF;

     If(x_msg_Count > 0 OR l_Return_Status = 'U') Then

      l_log_msg := 'Undo_Accounting : Error in xla_DataFixes_Pub.delete_journal_entries
             :'|| x_msg_Data;
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,
                 G_MODULE_NAME||l_procedure_name,
                 l_log_msg);
      END IF;

      p_return_code := 'XLA_ERROR';

      End If;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      l_return_status := 'U';
      p_return_code := 'XLA_EXCEPTION';
  END;

  IF (l_Return_Status = 'S') THEN
    BEGIN
      SELECT event_status_code
        INTO l_event_status_code
        FROM xla_events xe
       WHERE xe.application_id = 200
         AND xe.event_id = Events_to_Process_tab(i).Event_Id;

     IF l_event_status_code = 'P' THEN
        p_return_code := 'XLA_NO_WORK';
     END IF;

    EXCEPTION
      WHEN OTHERS THEN
        l_event_status_code := 'X';
        p_return_code := 'XLA_NO_WORK';
    END;

    IF (Events_to_Process_tab(i).Check_Or_Invoice = 'CHECKS' AND
        l_event_status_code = 'U') THEN

     BEGIN

      UPDATE ap_Payment_History_All aph
         SET Accounting_Date = l_gl_Date,
             Posted_Flag = 'N',
             Last_Updated_By = fnd_Global.User_Id
       WHERE Accounting_Event_Id = Events_to_Process_tab(i).Event_Id
         AND Check_Id = p_Source_Id;


      UPDATE ap_Invoice_Payments_All aip
         SET Accounting_Date = l_gl_Date,
             Posted_Flag = 'N',
             Accrual_Posted_Flag = 'N',
             Last_Updated_By = fnd_Global.User_Id,
             Period_Name = l_Period_Name
      WHERE  Accounting_Event_Id = Events_to_Process_tab(i).Event_Id
        AND Check_Id = p_Source_Id;

     --8306966
     UPDATE ap_Invoice_distributions_All aid
         SET Accounting_Date = l_gl_Date,
             Posted_Flag = 'N',
             Accrual_Posted_Flag = 'N',
             Last_Updated_By = fnd_Global.User_Id,
             Period_Name = l_Period_Name
      WHERE  Accounting_Event_Id = Events_to_Process_tab(i).Event_Id
      AND    line_type_lookup_code = 'AWT' ;
     --end of 8306966


      UPDATE xla_Events
         SET Event_Date = l_gl_Date
       WHERE Event_Id = Events_to_Process_tab(i).Event_Id;

      EXECUTE IMMEDIATE ins_AP_undo_event_log_stmt USING
        Events_to_Process_tab(i).Event_Id,l_rev_event_id
        ,l_new_event_id,l_return_status,NULL_VALUE
        ,l_Source_Id,p_bug_id;

      DELETE
        FROM ap_Payment_Hist_dIsts
       WHERE Payment_History_Id IN
                  (SELECT Payment_History_Id
                     FROM ap_Payment_History_All
                    WHERE Accounting_Event_Id = Events_to_Process_tab(i).Event_Id
                      AND Check_Id = l_Source_Id);

       p_return_code := 'SUCCESS';

       l_log_msg :='Updated Transaction tables for Payments';
         IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.STRING(G_LEVEL_PROCEDURE,
                   G_MODULE_NAME||l_procedure_name,
                   l_log_msg);
         END IF;

     EXCEPTION
       WHEN OTHERS THEN
         p_return_code := 'AP_PAYMENT_ERROR';
     END;

    ELSIF (Events_to_Process_tab(i).Check_Or_Invoice = 'INVOICES' AND
           l_event_status_code = 'U') THEN

     BEGIN

      UPDATE ap_Invoice_Distributions_All Aid
         SET Accounting_Date = l_gl_Date,
             Posted_Flag = 'N',
             Accrual_Posted_Flag = 'N',
             Last_Updated_By = fnd_Global.User_Id,
             Period_Name =l_Period_Name
      WHERE Accounting_Event_Id = Events_to_Process_tab(i).Event_Id
        AND Invoice_Id = l_Source_Id;

      UPDATE ap_self_assessed_tax_dist_all asatd
         SET Accounting_Date = l_gl_Date,
             Posted_Flag = 'N',
             Accrual_Posted_Flag = 'N',
             Last_Updated_By = fnd_Global.User_Id,
             Period_Name = l_Period_Name
      WHERE Accounting_Event_Id = Events_to_Process_tab(i).Event_Id
        AND Invoice_Id = l_Source_Id;


      UPDATE xla_Events
         SET Event_Date = l_gl_Date
       WHERE Event_Id = Events_to_Process_tab(i).Event_Id;

      UPDATE ap_prepay_history_all aph
         SET Accounting_Date = l_gl_Date,
             Posted_Flag = 'N',
             Last_Updated_By = fnd_Global.User_Id
      WHERE Accounting_Event_Id = Events_to_Process_tab(i).Event_Id
        AND Invoice_Id = l_Source_Id;

      DELETE
        FROM ap_prepay_app_dists
       WHERE PREPAY_HISTORY_ID IN
                  (SELECT PREPAY_HISTORY_ID
                     FROM ap_prepay_history_all
                    WHERE Accounting_Event_Id = Events_to_Process_tab(i).Event_Id
                      AND transaction_type = 'PREPAYMENT APPLICATION ADJ' --7502473
                      AND Invoice_Id = l_Source_Id);


      EXECUTE IMMEDIATE ins_AP_undo_event_log_stmt USING
        Events_to_Process_tab(i).Event_Id,l_rev_event_id,
        l_new_event_id,l_return_status,l_Source_Id,
        NULL_VALUE,p_bug_id;


       p_return_code := 'SUCCESS';

       l_log_msg :='Updated Transaction tables for Invoice';
         IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.STRING(G_LEVEL_PROCEDURE,
                   G_MODULE_NAME||l_procedure_name,
                   l_log_msg);
         END IF;

     EXCEPTION
       WHEN OTHERS THEN
         p_return_code := 'AP_INVOICE_ERROR';
     END;
    END IF;
   ELSE

     IF p_return_code IS NULL THEN
          p_return_code := 'XLA_ERROR';
     END IF;

     IF (Events_to_Process_tab(i).Check_Or_Invoice = 'INVOICES') THEN
       Print('Undo Accounting Unsuccessful for Invoice id ' ||l_Source_Id
                ||' event id ' ||Events_to_Process_tab(i).Event_Id);

       l_log_msg :='Undo Accounting Unsuccessful for Invoice id ' ||l_Source_Id
                    ||' event id ' ||Events_to_Process_tab(i).Event_Id;
         IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.STRING(G_LEVEL_PROCEDURE,
                   G_MODULE_NAME||l_procedure_name,
                   l_log_msg);
         END IF;

     ELSIF (Events_to_Process_tab(i).Check_Or_Invoice = 'CHECKS') THEN
       Print('Undo Accounting Unsuccessful for Check id ' ||l_Source_Id
                ||' event id ' ||Events_to_Process_tab(i).Event_Id);

       l_log_msg :='Undo Accounting Unsuccessful for Check id ' ||l_Source_Id
                ||' event id ' ||Events_to_Process_tab(i).Event_Id;
         IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.STRING(G_LEVEL_PROCEDURE,
                   G_MODULE_NAME||l_procedure_name,
                   l_log_msg);
         END IF;

     END IF;
   END IF;
 END LOOP;
EXCEPTION
  WHEN OTHERS THEN
             l_log_msg :='Exception in Undo_accounting ';
         IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.STRING(G_LEVEL_PROCEDURE,
                   G_MODULE_NAME||l_procedure_name,
                   l_log_msg);
         END IF;
    IF (SQLCODE <> - 20001) THEN
      fnd_Message.Set_Name('SQLAP','AP_DEBUG');
      fnd_Message.Set_Token('ERROR',SQLERRM);
      fnd_Message.Set_Token('CALLING_SEQUENCE',l_Calling_Sequence);
      fnd_Message.Set_Token('PARAMETERS','p_source_id = '
                                         ||p_Source_Id
                                         ||', p_Source_Table = '
                                         ||p_Source_Table);
      fnd_Message.Set_Token('DEBUG_INFO',Debug_Info);
    END IF;

    app_Exception.Raise_Exception;

END Undo_Accounting;

PROCEDURE Undo_Accounting
      (p_source_table      IN VARCHAR2,
       p_source_id         IN NUMBER,
       p_Event_id          IN NUMBER DEFAULT NULL,
       p_calling_sequence  IN VARCHAR2 DEFAULT NULL,
       p_bug_id            IN NUMBER DEFAULT NULL,
       p_GL_Date           IN DATE DEFAULT NULL) IS

l_source_table           XLA_TRANSACTION_ENTITIES.ENTITY_CODE%TYPE;
l_source_id              XLA_TRANSACTION_ENTITIES.SOURCE_ID_INT_1%TYPE;
l_event_id               XLA_EVENTS.EVENT_ID%TYPE;
l_calling_sequence       VARCHAR2(4000);
l_bug_id                 NUMBER;
l_rev_event_id           NUMBER;
l_new_event_id           NUMBER;
l_return_code            VARCHAR2(4000);
l_log_msg                FND_NEW_MESSAGES.MESSAGE_NAME%TYPE;
l_procedure_name         VARCHAR2(1000);
debug_info               VARCHAR2(4000);
l_gl_date                DATE;

BEGIN

   l_calling_sequence := 'Overloaded Undo_Accounting api <- '||p_calling_sequence;

   debug_info := 'Setting the Variables that need to be passed';
   l_source_table := p_source_table;
   l_source_id := p_source_id;
   l_event_id := p_event_id;
   l_bug_id := p_bug_id;
   l_gl_date := p_GL_Date;
   l_procedure_name := 'AP_ACCTG_DATA_FIX_PKG.undo_accounting';

   debug_info := 'Calling the Undo_Accounting with higher number of Arguments';
   Undo_Accounting
     (p_Source_Table      => l_source_table,
      p_Source_Id         => l_source_id,
      p_Event_Id          => l_event_id,
      p_skip_date_calc    => 'N',
      p_undo_date         => NULL,
      p_undo_period       => NULL,
      p_bug_id            => l_bug_id,
      p_Gl_Date           => l_gl_date,
      p_rev_event_id      => l_rev_event_id,
      p_new_event_id      => l_new_event_id,
      p_return_code       => l_return_code,
      p_calling_sequence  => l_calling_sequence);

EXCEPTION
  WHEN OTHERS THEN
    l_log_msg :='Exception in Undo_accounting ';
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.STRING(G_LEVEL_PROCEDURE,
                   G_MODULE_NAME||l_procedure_name,
                   l_log_msg);
    END IF;
    IF (SQLCODE <> - 20001) THEN
      fnd_Message.Set_Name('SQLAP','AP_DEBUG');
      fnd_Message.Set_Token('ERROR',SQLERRM);
      fnd_Message.Set_Token('CALLING_SEQUENCE',p_Calling_Sequence);
      fnd_Message.Set_Token('PARAMETERS','p_source_id = '
                                         ||p_Source_Id
                                         ||', p_Source_Table = '
                                         ||p_Source_Table);
      fnd_Message.Set_Token('DEBUG_INFO',Debug_Info);
    END IF;
    app_Exception.Raise_Exception;
END;

PROCEDURE undo_acctg_entries
      (p_bug_no             IN          NUMBER,
       p_driver_table       IN          VARCHAR2,
       p_calling_sequence   IN          VARCHAR2) IS

  l_sql_stmt                            LONG;
  l_bug_no                              VARCHAR2(100);
  l_driver_table                        ALL_TABLES.TABLE_NAME%TYPE;
  l_debug_info                          VARCHAR2(4000);
  l_error_log                           LONG;
  l_prev_org_id                         NUMBER := -99;
  l_org_id                              NUMBER := -99;
  l_dummy                               NUMBER;
  l_rev_event_id                        NUMBER;
  l_new_event_id                        NUMBER;
  l_return_code                         VARCHAR2(1000);
  l_event_status_code                   XLA_EVENTS.EVENT_STATUS_CODE%TYPE;
  l_message                             VARCHAR2(4000);
  l_calling_sequence                    VARCHAR2(4000);

  TYPE refcurtyp            IS          REF CURSOR;
  undo_events_cur                       REFCURTYP;
  undo_journals_details                 REFCURTYP;
  undo_failures                         REFCURTYP;

  TYPE kind_t                         IS TABLE OF VARCHAR2(100)                                              INDEX BY BINARY_INTEGER;
  TYPE event_id_t                     IS TABLE OF XLA_AE_HEADERS.EVENT_ID%TYPE                               INDEX BY BINARY_INTEGER;
  TYPE accounting_class_code_t        IS TABLE OF XLA_AE_LINES.ACCOUNTING_CLASS_CODE%TYPE                    INDEX BY BINARY_INTEGER;
  TYPE event_type_code_t              IS TABLE OF XLA_AE_HEADERS.EVENT_TYPE_CODE%TYPE                        INDEX BY BINARY_INTEGER;
  TYPE event_date_t                   IS TABLE OF XLA_EVENTS.EVENT_DATE%TYPE                                 INDEX BY BINARY_INTEGER;
  TYPE ae_header_id_t                 IS TABLE OF XLA_AE_HEADERS.AE_HEADER_ID%TYPE                           INDEX BY BINARY_INTEGER;
  TYPE balance_type_code_t            IS TABLE OF XLA_AE_HEADERS.BALANCE_TYPE_CODE%TYPE                      INDEX BY BINARY_INTEGER;
  TYPE source_id_int_1_t              IS TABLE OF XLA_TRANSACTION_ENTITIES.SOURCE_ID_INT_1%TYPE              INDEX BY BINARY_INTEGER;
  TYPE org_id_t                       IS TABLE OF XLA_TRANSACTION_ENTITIES.SECURITY_ID_INT_1%TYPE            INDEX BY BINARY_INTEGER;
  TYPE transaction_number_t           IS TABLE OF XLA_TRANSACTION_ENTITIES.TRANSACTION_NUMBER%TYPE           INDEX BY BINARY_INTEGER;
  TYPE entity_code_t                  IS TABLE OF XLA_TRANSACTION_ENTITIES.ENTITY_CODE%TYPE                  INDEX BY BINARY_INTEGER;
  TYPE ae_line_num_t                  IS TABLE OF XLA_AE_LINES.AE_LINE_NUM%TYPE                              INDEX BY BINARY_INTEGER;
  TYPE padded_concatenated_segments_t IS TABLE OF GL_CODE_COMBINATIONS_KFV.PADDED_CONCATENATED_SEGMENTS%TYPE INDEX BY BINARY_INTEGER;
  TYPE entered_dr_t                   IS TABLE OF XLA_AE_LINES.ENTERED_DR%TYPE                               INDEX BY BINARY_INTEGER;
  TYPE entered_cr_t                   IS TABLE OF XLA_AE_LINES.ENTERED_CR%TYPE                               INDEX BY BINARY_INTEGER;
  TYPE accounted_dr_t                 IS TABLE OF XLA_AE_LINES.ACCOUNTED_DR%TYPE                             INDEX BY BINARY_INTEGER;
  TYPE accounted_cr_t                 IS TABLE OF XLA_AE_LINES.ACCOUNTED_CR%TYPE                             INDEX BY BINARY_INTEGER;
  TYPE description_t                  IS TABLE OF XLA_AE_LINES.DESCRIPTION%TYPE                              INDEX BY BINARY_INTEGER;
  TYPE name_t                         IS TABLE OF GL_LEDGERS.NAME%TYPE                                       INDEX BY BINARY_INTEGER;
  TYPE calc_undo_date_t               IS TABLE OF XLA_EVENTS.EVENT_DATE%TYPE                                 INDEX BY BINARY_INTEGER;
  TYPE calc_undo_period_t             IS TABLE OF GL_PERIOD_STATUSES.PERIOD_NAME%TYPE                        INDEX BY BINARY_INTEGER;
  TYPE error_reason_t                 IS TABLE OF VARCHAR2(1000)                                             INDEX BY BINARY_INTEGER;

  TYPE undo_rec_typ IS RECORD
   (event_id_l          event_id_t,
    source_type_l       entity_code_t,
    source_id_l         source_id_int_1_t,
    org_id_l            org_id_t,
    calc_undo_date_l    calc_undo_date_t,
    calc_undo_period_l  calc_undo_period_t);

  undo_events_list                      UNDO_REC_TYP;

  TYPE undo_journal_details IS RECORD
   (kind_l                                  kind_t,
    accounting_class_code_l                 accounting_class_code_t,
    event_type_code_l                       event_type_code_t,
    event_id_l                              event_id_t,
    event_date_l                            event_date_t,
    ae_header_id_l                          ae_header_id_t,
    balance_type_code_l                     balance_type_code_t,
    source_id_int_1_l                       source_id_int_1_t,
    transaction_number_l                    transaction_number_t,
    entity_code_l                           entity_code_t,
    ae_line_num_l                           ae_line_num_t,
    padded_concatenated_segments_l          padded_concatenated_segments_t,
    entered_dr_l                            entered_dr_t,
    entered_cr_l                            entered_cr_t,
    accounted_dr_l                          accounted_dr_t,
    accounted_cr_l                          accounted_cr_t,
    description_l                           description_t,
    name_l                                  name_t);

  undo_journal_dtls_l    UNDO_JOURNAL_DETAILS;

  TYPE undo_failure_details IS RECORD
  (entity_code_l             entity_code_t,
   source_id_int_1_l         source_id_int_1_t,
   transaction_number_l      transaction_number_t,
   event_id_l                event_id_t,
   calc_undo_date_l          calc_undo_date_t,
   calc_undo_period_l        calc_undo_period_t,
   error_reason_l            error_reason_t
   );

  undo_failures_l         UNDO_FAILURE_DETAILS;


BEGIN

  l_bug_no := p_bug_no;
  l_calling_sequence := 'Undo_acctg_entries <- '||p_calling_sequence;

  l_debug_info := 'Constructing the name of the driver table';
  IF p_driver_table IS NOT NULL THEN
    l_driver_table := upper(p_driver_table);
  ELSE
    l_driver_table := 'AP_TEMP_DATA_DRIVER_'||l_bug_no;
  END IF;

  l_debug_info := 'Before calling the check_period API';
  check_period
      (p_bug_no                      => l_bug_no,
       p_driver_table                => l_driver_table,
       p_check_sysdate               => 'Y',
       p_check_event_date            => 'Y',
       p_chk_proposed_undo_date      => 'Y',
       p_update_process_flag         => 'Y',
       p_calc_undo_date              => 'Y',
       p_commit_flag                 => 'Y',
       p_calling_sequence            => l_calling_sequence);

  l_debug_info := 'Before calling the check_ccid api';
  check_ccid
      (p_bug_no                       => l_bug_no,
       p_driver_table                 => l_driver_table,
       p_update_process_flag          => 'Y',
       p_commit_flag                  => 'Y',
       p_calling_sequence             => l_calling_sequence);

   l_debug_info := 'Checking the presence of the O/P values on the '||
                   'temp data driver';
   BEGIN
     SELECT 1
       INTO l_dummy
       FROM sys.all_tab_columns
      WHERE table_name = l_driver_table
        AND column_name = 'REVERSAL_EVENT_ID';

   EXCEPTION
     WHEN OTHERS THEN
       l_dummy := 0;
   END;

   IF l_dummy = 0 THEN
     l_sql_stmt := ' ALTER TABLE '||l_driver_table||
                   ' ADD (REVERSAL_EVENT_ID NUMBER, '||
                   '      NEW_EVENT_ID      NUMBER, '||
                   '      RETURN_STATUS     VARCHAR2(1000)) ';
     EXECUTE IMMEDIATE l_sql_stmt;
   END IF;

   l_debug_info := 'Constructing the dynamic sql statement ';
   l_sql_stmt :=      ' SELECT DISTINCT '||
                      '   xte.entity_code, '||
                      '   xte.source_id_int_1, '||
                      '   xe.event_id, '||
                      '   xte.security_id_int_1, '||
                      '   dr.calculated_undo_date, '||
                      '   dr.calculated_undo_period '||
                      ' FROM xla_transaction_entities_upg xte, '||
                      '      xla_events xe, '||
                             l_driver_table||' dr '||
                      ' WHERE xte.application_id = 200 '||
                      ' AND xe.application_id = 200 '||
                      ' AND dr.event_id = xe.event_id '||
                      ' AND xe.entity_id = xte.entity_id '||
                      ' AND dr.process_flag = ''Y'' '||
                      ' AND xe.event_status_code = ''P'' '||
                      ' AND xe.event_type_code <> ''MANUAL'' ';

   l_debug_info := 'After the l_sql_stmt, before opening the cursor';
   OPEN undo_events_cur FOR l_sql_stmt;
   LOOP
     FETCH undo_events_cur
     BULK COLLECT INTO undo_events_list.source_type_l,
                       undo_events_list.source_id_l,
                       undo_events_list.event_id_l,
                       undo_events_list.org_id_l,
                       undo_events_list.calc_undo_date_l,
                       undo_events_list.calc_undo_period_l    LIMIT 1000;

     l_debug_info := 'After the fetch, before looping for the batch of 1000';
     IF undo_events_list.event_id_l.COUNT > 0 THEN
       FOR i IN undo_events_list.event_id_l.FIRST..undo_events_list.event_id_l.LAST LOOP

         SAVEPOINT BEFORE_UNDO;
         BEGIN

           l_debug_info := 'Fetching the org_id';
           l_org_id := undo_events_list.org_id_l(i);

           IF l_org_id <> l_prev_org_id THEN
             l_debug_info := 'Setting the org context to org_id '||l_org_id;
             MO_GLOBAL.set_policy_context('S', l_org_id);
           END IF;

           l_debug_info := 'Before calling the undo_accounting api';

           Undo_Accounting
               (p_Source_Table      => undo_events_list.source_type_l(i),
                p_Source_Id         => undo_events_list.source_id_l(i),
                p_Event_Id          => undo_events_list.event_id_l(i),
                p_Skip_Date_Calc    => 'Y',
                p_undo_date         => undo_events_list.calc_undo_date_l(i),
                p_undo_period       => undo_events_list.calc_undo_period_l(i),
                p_bug_id            => l_bug_no,
                p_Gl_Date           => NULL,
                P_rev_event_id      => l_rev_event_id,
                P_new_event_id      => l_new_event_id,
                P_return_code       => l_return_code,
                P_calling_sequence  => l_calling_sequence);

           l_debug_info := 'Resetting the prev org context ';
           l_prev_org_id := l_org_id;

         EXCEPTION
           WHEN OTHERS THEN
             l_prev_org_id := -99;
             l_message := 'Event_id '||undo_events_list.event_id_l(i)||' Could not be processed '||
                          'because of unexpected error ';
             ROLLBACK TO BEFORE_UNDO;
         END;

         l_sql_stmt :=
               ' UPDATE '||l_driver_table||
               ' SET reversal_event_id = :b1, '||
               '     new_event_id = :b2, '||
               '     return_status = :b3 '||
               ' WHERE event_id = :b4 ';

         EXECUTE IMMEDIATE l_sql_stmt USING l_rev_event_id,
                                            l_new_event_id,
                                            l_return_code,
                                            undo_events_list.event_id_l(i);
         -- A commit is required here, if not committed, then in case there
         -- is an XLA exception while undo, XLA issues a blind Rollback, which
         -- causes all the events which were successfully undone to be rolled
         -- back
         --
         COMMIT;

       END LOOP;
     END IF;
     EXIT WHEN undo_events_cur%NOTFOUND;
   END LOOP;

   l_message := '<b><u>Following are the details of the Original and the Reversal '||
                'Entries for the Events successfully Unaccounted</u></b>';
   Print(l_message);

   l_debug_info := ' Printing the details of the Original and the reversal '||
                   ' Journal Entries ';
   l_message := '<table border="5">'||
                '<th>LEDGER_NAME</th>'||
                '<th>KIND</th>'||
                '<th>ACCOUNTING_CLASS_CODE</th>'||
                '<th>EVENT_TYPE_CODE</th>'||
                '<th>EVENT_ID</th>'||
                '<th>EVENT_DATE</th>'||
                '<th>AE_HEADER_ID</th>'||
                '<th>BALANCE_TYPE_CODE</th>'||
                '<th>SOURCE_ID_INT_1</th>'||
                '<th>TRANSACTION_NUMBER</th>'||
                '<th>ENTITY_CODE</th>'||
                '<th>AE_LINE_NUM</th>'||
                '<th>PADDED_CONCATENATED_SEGMENTS</th>'||
                '<th>ENTERED_DR</th>'||
                '<th>ENTERED_CR</th>'||
                '<th>ACCOUNTED_DR</th>'||
                '<th>ACCOUNTED_CR</th>'||
                '<th>DESCRIPTION</th>';

   print(l_message);
   l_sql_stmt :=
        ' SELECT v1.kind, '||
        '        v1.accounting_class_code, '||
        '        v1.event_type_code, '||
        '        v1.event_id, '||
        '        v1.event_date, '||
        '        v1.ae_header_id, '||
        '        v1.balance_type_code, '||
        '        v1.source_id_int_1, '||
        '        v1.transaction_number, '||
        '        v1.entity_code, '||
        '        v1.ae_line_num, '||
        '        v1.padded_concatenated_segments, '||
        '        v1.entered_dr, '||
        '        v1.entered_cr, '||
        '        v1.accounted_dr, '||
        '        v1.accounted_cr, '||
        '        v1.description, '||
        '        v1.name '||
        ' FROM '||
        ' ( '||
        '   SELECT ''OLD'' KIND, '||
        '        xal.accounting_class_code, '||
        '        xah.event_type_code, '||
        '        xah.event_id, '||
        '        xe.event_date, '||
        '        xah.ae_header_id, '||
        '        xah.balance_type_code, '||
        '        xah.accounting_date, '||
        '        xte.source_id_int_1, '||
        '        xte.transaction_number, '||
        '        xte.entity_code, '||
        '        xal.ae_line_num, '||
        '        gcc.padded_concatenated_segments, '||
        '        xal.entered_dr, '||
        '        xal.entered_cr, '||
        '        xal.accounted_dr, '||
        '        xal.accounted_cr, '||
        '        xal.description, '||
        '        gl.name '||
        '   FROM xla_events xe, '||
        '        xla_ae_headers xah, '||
        '        xla_ae_lines xal, '||
        '        xla_transaction_entities_upg xte, '||
        '        gl_code_combinations_kfv gcc, '||
        '        gl_ledgers gl '||
        '   WHERE xe.application_id = 200 '||
        '   AND xah.application_id = 200 '||
        '   AND xal.application_id = 200 '||
        '   AND xte.application_id = 200 '||
        '   AND xe.event_id = xah.event_id '||
        '   AND xe.entity_id = xte.entity_id '||
        '   AND xah.ae_header_id = xal.ae_header_id '||
        '   AND xah.ledger_id = gl.ledger_id '||
        '   AND xal.code_combination_id = gcc.code_combination_id '||
        '   AND xah.event_id IN '||
        '     (SELECT DISTINCT dr.new_event_id  '||
        '      FROM '||l_driver_table||' dr, '||
        '           xla_events xe '||
        '      WHERE xe.application_id = 200 '||
        '      AND dr.event_id = xe.event_id '||
        '      AND xe.event_status_code <> ''MANUAL'' '||
        '      AND dr.process_flag = ''Y'' '||
        '      AND xe.event_status_code <> ''P'' '||
        '     ) '||
        '     UNION ALL '||
        '   SELECT ''REVERSAL'' KIND, '||
        '        xal.accounting_class_code, '||
        '        xah.event_type_code, '||
        '        xah.event_id, '||
        '        xe.event_date, '||
        '        xah.ae_header_id, '||
        '        xah.balance_type_code, '||
        '        xah.accounting_date, '||
        '        xte.source_id_int_1, '||
        '        xte.transaction_number, '||
        '        xte.entity_code, '||
        '        xal.ae_line_num, '||
        '        gcc.padded_concatenated_segments, '||
        '        xal.entered_dr, '||
        '        xal.entered_cr, '||
        '        xal.accounted_dr, '||
        '        xal.accounted_cr, '||
        '        xal.description, '||
        '        gl.name '||
        '   FROM xla_events xe, '||
        '        xla_ae_headers xah, '||
        '        xla_ae_lines xal, '||
        '        xla_transaction_entities_upg xte, '||
        '        gl_code_combinations_kfv gcc, '||
        '        gl_ledgers gl '||
        '   WHERE xe.application_id = 200 '||
        '   AND xah.application_id = 200 '||
        '   AND xal.application_id = 200 '||
        '   AND xte.application_id = 200 '||
        '   AND xe.event_id = xah.event_id '||
        '   AND xah.ledger_id = gl.ledger_id '||
        '   AND xe.entity_id = xte.entity_id '||
        '   AND xah.ae_header_id = xal.ae_header_id '||
        '   AND xe.event_type_code = ''MANUAL'' '||
        '   AND xal.code_combination_id = gcc.code_combination_id '||
        '   AND xe.event_id IN '||
        '     (SELECT DISTINCT dr.reversal_event_id  '||
        '      FROM '||l_driver_table||' dr, '||
        '           xla_events xe '||
        '      WHERE xe.application_id = 200 '||
        '      AND dr.event_id = xe.event_id '||
        '      AND xe.event_status_code <> ''MANUAL'' '||
        '      AND dr.process_flag = ''Y'' '||
        '      AND xe.event_status_code <> ''P'' '||
        '     ) '||
        ' ) v1 '||
        ' ORDER BY v1.entity_code, '||
        '          v1.source_id_int_1, '||
        '          v1.KIND, '||
        '          v1.event_type_code, '||
        '          v1.ae_header_id, '||
        '          v1.balance_type_code, '||
        '          v1.ae_line_num ';

   l_debug_info := 'Before Opening the cursor for Printing the details '||
                   'of the Original and Reversal Entries ';
   OPEN undo_journals_details FOR l_sql_stmt;
   LOOP

     l_debug_info := 'Before fetch for a batchsize for Printing details of Original and Rev';
     FETCH undo_journals_details
     BULK COLLECT INTO undo_journal_dtls_l.kind_l,
                       undo_journal_dtls_l.accounting_class_code_l,
                       undo_journal_dtls_l.event_type_code_l,
                       undo_journal_dtls_l.event_id_l,
                       undo_journal_dtls_l.event_date_l,
                       undo_journal_dtls_l.ae_header_id_l,
                       undo_journal_dtls_l.balance_type_code_l,
                       undo_journal_dtls_l.source_id_int_1_l,
                       undo_journal_dtls_l.transaction_number_l,
                       undo_journal_dtls_l.entity_code_l,
                       undo_journal_dtls_l.ae_line_num_l,
                       undo_journal_dtls_l.padded_concatenated_segments_l,
                       undo_journal_dtls_l.entered_dr_l,
                       undo_journal_dtls_l.entered_cr_l,
                       undo_journal_dtls_l.accounted_dr_l,
                       undo_journal_dtls_l.accounted_cr_l,
                       undo_journal_dtls_l.description_l,
                       undo_journal_dtls_l.name_l  LIMIT 1000;

     l_debug_info := 'Before looping for the batchsize';
     IF undo_journal_dtls_l.event_id_l.COUNT > 0 THEN
       FOR i IN undo_journal_dtls_l.event_id_l.FIRST..undo_journal_dtls_l.event_id_l.LAST LOOP
         l_message :=
           '<tr><td>'||undo_journal_dtls_l.name_l(i)||'</td><td>'||
                       undo_journal_dtls_l.kind_l(i)||'</td><td>'||
                       undo_journal_dtls_l.accounting_class_code_l(i)||'</td><td>'||
                       undo_journal_dtls_l.event_type_code_l(i)||'</td><td>'||
                       to_char(undo_journal_dtls_l.event_id_l(i))||'</td><td>'||
                       to_char(undo_journal_dtls_l.event_date_l(i), 'DD-MON-YYYY')||'</td><td>'||
                       to_char(undo_journal_dtls_l.ae_header_id_l(i))||'</td><td>'||
                       undo_journal_dtls_l.balance_type_code_l(i)||'</td><td>'||
                       to_char(undo_journal_dtls_l.source_id_int_1_l(i))||'</td><td>'||
                       undo_journal_dtls_l.transaction_number_l(i)||'</td><td>'||
                       undo_journal_dtls_l.entity_code_l(i)||'</td><td>'||
                       to_char(undo_journal_dtls_l.ae_line_num_l(i))||'</td><td>'||
                       undo_journal_dtls_l.padded_concatenated_segments_l(i)||'</td><td>'||
                       to_char(undo_journal_dtls_l.entered_dr_l(i))||'</td><td>'||
                       to_char(undo_journal_dtls_l.entered_cr_l(i))||'</td><td>'||
                       to_char(undo_journal_dtls_l.accounted_dr_l(i))||'</td><td>'||
                       to_char(undo_journal_dtls_l.accounted_cr_l(i))||'</td><td>'||
                       undo_journal_dtls_l.description_l(i)||'</td><td>';
         print(l_message);
       END LOOP;
     END IF;
     EXIT WHEN undo_journals_details%NOTFOUND;
   END LOOP;

   l_debug_info := 'After Printing the details of the Original and the Reversal Entries';

   l_message := '</table>';
   print(l_message);


   l_message := '<b><u>Following are the details of the XLA events for which '||
                'there was an error while Unaccounting</u></b>';
   Print(l_message);

   l_debug_info := ' Printing the details of the transactions for which the Undo '||
                   ' was not successful, and the reasons for the same ';
   l_sql_stmt :=  ' SELECT DISTINCT '||
                  '   xte.entity_code, '||
                  '   xte.source_id_int_1, '||
                  '   xte.transaction_number, '||
                  '   xe.event_id, '||
                  '   dr.calculated_undo_date, '||
                  '   dr.calculated_undo_period, '||
                  '   decode(dr.return_status, '||
                  '          ''XLA_ERROR'', ''XLA Undo API Error'', '||
                  '          ''XLA_EXCEPTION'', ''XLA Undo API throws Exception'', '||
                  '          ''XLA_NO_WORK'', ''XLA API did not Work'', '||
                  '          ''AP_PAYMENT_ERROR'', ''Exception while updating AP Payments'', '||
                  '          ''AP_INVOICE_ERROR'', ''Exception while updating AP Invoices'', '||
                  '          ''UNEXPECTED_EXCEPTION'', ''Unexpected Exception Occurred'', '||
                  '          ''SUCCESS'', ''Success'', '||
                  '          ''Relevant Error Not Found '' '||
                  '         ) '||
                  ' FROM xla_transaction_entities_upg xte, '||
                  '      xla_events xe, '||
                         l_driver_table||' dr '||
                  ' WHERE xte.application_id = 200 '||
                  ' AND xe.application_id = 200 '||
                  ' AND dr.event_id = xe.event_id '||
                  ' AND xe.entity_id = xte.entity_id '||
                  ' AND dr.process_flag = ''Y'' '||
                  ' AND xe.event_status_code = ''P'' '||
                  ' AND xe.event_type_code <> ''MANUAL'' ';

   l_message := '<table border="5">'||
                '<th>SOURCE_TYPE</th>'||
                '<th>TRANSACTION_ID</th>'||
                '<th>TRANSACTION_NUMBER</th>'||
                '<th>EVENT_ID</th>'||
                '<th>UNDO_DATE</th>'||
                '<th>UNDO_PERIOD</th>'||
                '<th>ERROR_REASON</th>';
   Print(l_message);

   l_debug_info := 'Before Opening the cursor for Printing the failures';
   OPEN undo_failures FOR l_sql_stmt;
   LOOP
     l_debug_info := 'Inside the Loop before fetching the batchsize';
     FETCH undo_failures
     BULK COLLECT INTO undo_failures_l.entity_code_l,
                       undo_failures_l.source_id_int_1_l,
                       undo_failures_l.transaction_number_l,
                       undo_failures_l.event_id_l,
                       undo_failures_l.calc_undo_date_l,
                       undo_failures_l.calc_undo_period_l,
                       undo_failures_l.error_reason_l   LIMIT 1000;

     l_debug_info := 'After the fetch before looping for the batchsize';
     IF undo_failures_l.event_id_l.COUNT > 0 THEN
       FOR i IN undo_failures_l.event_id_l.FIRST..undo_failures_l.event_id_l.LAST LOOP
         l_debug_info := 'Constructing the failure message for the event_id '||undo_failures_l.event_id_l(i);
         l_message :=
           '<tr><td>'||undo_failures_l.entity_code_l(i)||'</td><td>'||
                       to_char(undo_failures_l.source_id_int_1_l(i))||'</td><td>'||
                       undo_failures_l.transaction_number_l(i)||'</td><td>'||
                       to_char(undo_failures_l.event_id_l(i))||'</td><td>'||
                       to_char(undo_failures_l.calc_undo_date_l(i), 'DD-MON-YYYY')||'</td><td>'||
                       undo_failures_l.calc_undo_period_l(i)||'</td><td>'||
                       undo_failures_l.error_reason_l(i)||'</td><td>';
         Print(l_message);
       END LOOP;
     END IF;
     EXIT WHEN undo_failures%NOTFOUND;
     l_debug_info := 'After Processing One batch';
   END LOOP;
   l_debug_info := 'After processing the failures';

   l_debug_info := 'Marking all the events for which Undo has been successful to D ';
   l_sql_stmt :=
         'UPDATE '||l_driver_table||' dr '||
         '   SET dr.process_flag = ''D'' '||
         ' WHERE dr.process_flag = ''Y'' '||
         '   AND dr.event_id IN '||
         '       (SELECT xe.event_id '||
         '          FROM xla_events xe, '||
                         l_driver_table||'  dr1 '||
         '         WHERE xe.application_id = 200 '||
         '           AND xe.event_status_code <> ''P'' '||
         '   AND xe.event_id = dr1.event_id) ';

   EXECUTE IMMEDIATE l_sql_stmt;
   COMMIT;

   l_message := '</table>';
   print(l_message);

EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE <> -20001 THEN
      l_error_log := ' Encountered an Unhandled Exception, '||SQLCODE||'-'||SQLERRM||
                       ' in '||l_calling_sequence||' while performing '||l_debug_info;
      Print(l_error_log);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION();
END;

PROCEDURE push_error(p_error_code     IN VARCHAR2,
                     p_error_stack    IN OUT NOCOPY Rejection_List_Tab_Typ) IS

 l_log_msg		FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
 l_procedure_name       CONSTANT VARCHAR2(30) := 'Push_error';
 l_index		NUMBER;

BEGIN

    l_index := p_error_stack.COUNT;

    l_log_msg := ' Current Stack Count : '||l_index||
                 ' Pushing the error :'||p_error_code||
		 ' in the stack';

    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name,
                     l_log_msg);
    END IF;

    p_error_stack(l_index + 1) := p_error_code;

END;


PROCEDURE final_pay_round_dfix
  (p_invoice_id                 IN              NUMBER,
   p_op_event_id                OUT     NOCOPY  NUMBER,
   p_op_event_type              OUT     NOCOPY  VARCHAR2,
   p_return_status              OUT     NOCOPY  BOOLEAN,
   p_rejection_tab              OUT     NOCOPY  Rejection_List_Tab_Typ,
   p_rej_count                  OUT     NOCOPY  NUMBER,
   p_error_msg                  OUT     NOCOPY  VARCHAR2,
   p_pay_dist_tab               OUT     NOCOPY  Pay_Dist_Tab_Typ,
   p_prepay_dist_tab            OUT     NOCOPY  Prepay_Dist_Tab_Typ,
   p_commit_flag                IN              VARCHAR2,
   p_calling_sequence           IN              VARCHAR2) IS

  l_dummy               NUMBER;
  l_org_id              AP_INVOICES_ALL.org_id%TYPE;
  l_count_hist_pay      NUMBER;
  l_cnt_unacc_inv_evnts NUMBER;
  l_cnt_unacc_pay_evnts NUMBER;
  l_cnt_untrx_inv_evnts NUMBER;
  l_cnt_untrx_pay_evnts NUMBER;
  l_invoice_id          NUMBER;
  l_check_id            NUMBER;
  l_is_final_pay        BOOLEAN;
  l_rej_count           NUMBER;
  l_reject_code         VARCHAR2(100);
  l_index               NUMBER := 0;
  l_max_event_id        XLA_EVENTS.event_id%TYPE;
  l_op_event_type       XLA_EVENTS.EVENT_TYPE_CODE%TYPE;
  l_max_pay_dist_id     NUMBER;
  l_max_prepay_dist_id  NUMBER;
  l_return_status       BOOLEAN;
  l_validation_status   VARCHAR2(100);
  l_error_code          VARCHAR2(100);
  l_error_log           LONG;

  l_inv_rec             ap_accounting_pay_pkg.r_invoices_info;
  l_xla_event_rec       ap_accounting_pay_pkg.r_xla_event_info;
  l_pay_hist_rec        ap_accounting_pay_pkg.r_pay_hist_info;
  l_clr_hist_rec        ap_accounting_pay_pkg.r_pay_hist_info;
  l_inv_pay_rec         ap_acctg_pay_dist_pkg.r_inv_pay_info;
  l_prepay_inv_rec      ap_accounting_pay_pkg.r_invoices_info;
  l_prepay_hist_rec     AP_ACCTG_PREPAY_DIST_PKG.r_prepay_hist_info;
  l_prepay_dist_rec     AP_ACCTG_PREPAY_DIST_PKG.r_prepay_dist_info;

  l_debug_info          VARCHAR2(4000);
  l_calling_sequence    VARCHAR2(4000);

  l_pay_dist_tab        Pay_Dist_Tab_Typ;
  l_prepay_dist_tab     Prepay_Dist_Tab_Typ;
  l_rejection_tab       Rejection_List_Tab_Typ;

  l_procedure_name	CONSTANT VARCHAR2(30) := 'Final_Pay_Round_Dfix';
  l_log_msg		FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;


  CURSOR xla_evnt_dtls(p_event_id NUMBER) IS
  SELECT XE.Event_ID,
         XE.Event_Type_Code,
         XE.Event_Date,
         XE.Event_Number,
         XE.Event_Status_Code,
         XTE.Entity_Code,
         XTE.Source_ID_Int_1
    FROM xla_events XE,
         xla_transaction_entities_upg XTE
   WHERE XE.application_id = 200
     AND XTE.application_id = 200
     AND XE.entity_id = XTE.entity_id
     AND XE.event_id = p_event_id;

  CURSOR Invoice_Payments
         (P_Invoice_id NUMBER,
	  P_Check_id   NUMBER,
	  P_Event_id   NUMBER) IS
  SELECT AIP.Invoice_ID,
         AIP.Invoice_Payment_ID,
         AIP.Amount,
         AIP.Discount_Taken,
         AIP.Payment_Base_Amount,
         AIP.Invoice_Base_Amount,
         AIP.Exchange_Rate_Type,
         AIP.Exchange_Date,
         AIP.Exchange_Rate,
         NVL(AIP.Reversal_Flag,'N'),
         AIP.Reversal_Inv_Pmt_ID
    FROM Ap_Invoice_Payments_All AIP
   WHERE AIP.invoice_id = P_Invoice_id
     AND AIP.accounting_event_id = nvl(P_Event_id, AIP.accounting_event_id)
     AND AIP.check_id = nvl(P_Check_id, AIP.check_id)
     AND nvl(AIP.reversal_flag, 'N') <> 'Y';

  CURSOR Prepay_History
        (P_Invoice_ID   NUMBER,
         P_event_id     NUMBER
        ) IS
  SELECT APH.Prepay_History_ID,
         APH.Prepay_Invoice_ID,
         APH.Invoice_ID,
         APH.Invoice_Line_Number,
         APH.Transaction_Type,
         APH.Accounting_Date,
         APH.Invoice_Adjustment_Event_ID,
         APH.Related_Prepay_App_Event_ID
  FROM   AP_Prepay_History_All APH
  WHERE  APH.Invoice_ID = P_Invoice_ID
  AND    APH.accounting_event_id = P_event_id
  ORDER BY transaction_type;

  CURSOR Prepay_Dists
        (P_Invoice_ID             NUMBER,
         P_event_id               NUMBER
        ) IS
  SELECT AID.Invoice_ID,
         AID.Invoice_Distribution_ID Invoice_Distribution_ID,
         AID.Line_Type_Lookup_Code,
         AID.Amount,
         AID.Base_Amount,
         AID.Accounting_Event_ID,
         AID.Prepay_Distribution_ID,
         AID.Prepay_Tax_Diff_Amount,
         AID.Parent_Reversal_ID
  FROM   AP_Invoice_Distributions_All AID
  WHERE  Invoice_ID = P_Invoice_ID
  AND    Line_Type_Lookup_Code = 'PREPAY'
  AND    Accounting_Event_ID = P_event_id
  ORDER BY abs(AID.amount) DESC;

  CURSOR new_round_pay_dists(p_event_id NUMBER,
                             p_max_pay_dist_id NUMBER)
  IS
  SELECT aphd.payment_hist_dist_id,
         aphd.accounting_event_id,
         aphd.pay_dist_lookup_code,
         aphd.invoice_distribution_id,
         aphd.amount,
         aphd.payment_history_id,
         aphd.invoice_payment_id,
         aphd.bank_curr_amount,
         aphd.cleared_base_amount,
         aphd.historical_flag,
         aphd.invoice_dist_amount,
         aphd.invoice_dist_base_amount,
         aphd.invoice_adjustment_event_id,
         aphd.matured_base_amount,
         aphd.paid_base_amount,
         aphd.rounding_amt,
         aphd.reversal_flag,
         aphd.reversed_pay_hist_dist_id,
         aphd.created_by,
         aphd.creation_date,
         aphd.last_update_date,
         aphd.last_updated_by,
         aphd.last_update_login,
         aphd.program_application_id,
         aphd.program_id,
         aphd.program_login_id,
         aphd.program_update_date,
         aphd.request_id,
         aphd.awt_related_id,
         aphd.release_inv_dist_derived_from,
         aphd.pa_addition_flag,
         aphd.amount_variance,
         aphd.invoice_base_amt_variance,
         aphd.quantity_variance,
         aphd.invoice_base_qty_variance,
         DECODE(asp.automatic_offsets_flag,
                'Y',DECODE(asp.liability_post_lookup_code,
                           'ACCOUNT_SEGMENT_VALUE', aid.dist_code_combination_id,
                           asp.rounding_error_ccid),
                asp.rounding_error_ccid
               ) write_off_code_combination
    FROM ap_payment_hist_dists aphd,
         ap_payment_history_all aph,
         ap_system_parameters_all asp,
         ap_invoice_distributions_all aid
   WHERE aphd.accounting_event_id = p_event_id
     AND aph.payment_history_id = aphd.payment_history_id
     AND aph.org_id = asp.org_id
     AND aphd.invoice_distribution_id = aid.invoice_distribution_id
     AND aphd.payment_hist_dist_id > p_max_pay_dist_id;

  CURSOR new_round_prepay_dists(p_event_id NUMBER,
                                p_max_prepay_dist_id NUMBER)
  IS
  SELECT apad.prepay_app_dist_id,
         apad.prepay_dist_lookup_code,
         apad.invoice_distribution_id,
         apad.prepay_app_distribution_id,
         apad.accounting_event_id,
         apad.prepay_history_id,
         apad.prepay_exchange_date,
         apad.prepay_pay_exchange_date,
         apad.prepay_clr_exchange_date,
         apad.prepay_exchange_rate,
         apad.prepay_pay_exchange_rate,
         apad.prepay_clr_exchange_rate,
         apad.prepay_exchange_rate_type,
         apad.prepay_pay_exchange_rate_type,
         apad.prepay_clr_exchange_rate_type,
         apad.reversed_prepay_app_dist_id,
         apad.amount,
         apad.base_amt_at_prepay_xrate,
         apad.base_amt_at_prepay_pay_xrate,
         apad.base_amount,
         apad.base_amt_at_prepay_clr_xrate,
         apad.rounding_amt,
         apad.round_amt_at_prepay_xrate,
         apad.round_amt_at_prepay_pay_xrate,
         apad.round_amt_at_prepay_clr_xrate,
         apad.last_updated_by,
         apad.last_update_date,
         apad.last_update_login,
         apad.created_by,
         apad.creation_date,
         apad.program_application_id,
         apad.program_id,
         apad.program_update_date,
         apad.request_id,
         apad.awt_related_id,
         apad.release_inv_dist_derived_from,
         apad.pa_addition_flag,
         apad.bc_event_id,
         apad.amount_variance,
         apad.invoice_base_amt_variance,
         apad.quantity_variance,
         apad.invoice_base_qty_variance,
         DECODE(asp.automatic_offsets_flag,
                'Y',DECODE(asp.liability_post_lookup_code,
                           'ACCOUNT_SEGMENT_VALUE', aid.dist_code_combination_id,
                           asp.rounding_error_ccid),
                asp.rounding_error_ccid
               ) write_off_code_combination
    FROM ap_prepay_app_dists apad,
         ap_prepay_history_all apph,
         ap_system_parameters_all asp,
         ap_invoice_distributions_all aid
   WHERE apad.accounting_event_id = P_Event_Id
     AND apad.prepay_history_id = apph.prepay_history_id
     AND apph.org_id = asp.org_id
     AND apad.invoice_distribution_id = aid.invoice_distribution_id
     AND apad.prepay_app_dist_id > P_Max_Prepay_Dist_id;


BEGIN


  l_calling_sequence := 'Final_Pay_Round_Dfix <- '||P_Calling_Sequence;
  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  l_log_msg := 'Procedure Begins';

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE,
                   G_MODULE_NAME||l_procedure_name,
                   l_log_msg);
  END IF;

  l_debug_info := 'Before Verifying if the Invoice is Valid';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN

    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   G_MODULE_NAME||l_procedure_name,
                   l_debug_info);
  END IF;

  l_invoice_id := p_invoice_id;

  BEGIN

    SELECT 1
      INTO l_dummy
      FROM ap_invoices_all
     WHERE invoice_id = l_invoice_id;

  EXCEPTION
    WHEN OTHERS THEN
      l_reject_code := 'INVALID INVOICE';
      Push_Error(p_error_code  => l_reject_code,
                 p_error_stack => p_rejection_tab);

      p_return_status := FALSE;
      p_rej_count := p_rejection_tab.COUNT;

      RETURN;
  END;


  l_debug_info := 'Before getting the operating unit for the Invoice';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   G_MODULE_NAME||l_procedure_name,
                   l_debug_info);
  END IF;

  SELECT org_id
    INTO l_org_id
    FROM ap_invoices_all
   WHERE invoice_id = l_invoice_id;

  l_debug_info := 'Before setting the org context for the Invoice';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   G_MODULE_NAME||l_procedure_name,
                   l_debug_info);
  END IF;

  MO_GLOBAL.set_policy_context('S', l_org_id);


  -- Proceed with the remainder of the Validations
  -- All the Validations would be carried out, and the
  -- error messages would be pushed into the stack
  --

  l_debug_info := 'Before checking for the Validation status of the Invoice';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   G_MODULE_NAME||l_procedure_name,
                   l_debug_info);
  END IF;

  SELECT ap_invoices_utility_pkg.Get_Approval_Status
           (ai.invoice_id,
            ai.invoice_amount,
            ai.payment_status_flag,
            ai.invoice_type_lookup_code)
    INTO l_validation_status
    FROM ap_invoices_all ai
   WHERE ai.invoice_id = l_invoice_id;

  IF l_validation_status NOT IN ('APPROVED','UNPAID','FULL','PERMANENT','AVAILABLE') THEN
    Push_Error(p_error_code  => 'UNAPPROVED INVOICE : '||l_validation_status,
               p_error_stack => p_rejection_tab);
  END IF;


  l_debug_info := 'Check if there is any of the events accruing liability '||
                  'have been Accounted in 11i';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   G_MODULE_NAME||l_procedure_name,
                   l_debug_info);
  END IF;


  SELECT count(*)
    INTO l_count_hist_pay
    FROM ap_invoice_payments_all aip,
         xla_ae_headers xah,
         xla_transaction_entities_upg xte,
         xla_ae_lines xal
   WHERE xah.application_id = 200
     AND aip.check_id = nvl(xte.source_id_int_1, -99)
     AND aip.set_of_books_id = xte.ledger_id
     AND xte.entity_code = 'AP_PAYMENTS'
     AND aip.invoice_id = l_invoice_id
     AND xah.upg_batch_id IS NOT NULL
     AND xah.upg_batch_id <> -9999
     AND xte.entity_id = xah.entity_id
     AND xah.ae_header_id = xal.ae_header_id
     AND xal.accounting_class_code = 'LIABILITY'
     AND rownum = 1;

  IF l_count_hist_pay > 0  THEN
    Push_Error(p_error_code  => 'HISTORICAL PAYMENT',
               p_error_stack => p_rejection_tab);
  END IF;


  l_debug_info := 'Check if any of the Invoice events (Including '||
                  'Prepayment Applications) have not been '||
                  'Accounted ';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   G_MODULE_NAME||l_procedure_name,
                   l_debug_info);
  END IF;


  SELECT count(*)
    INTO l_cnt_unacc_inv_evnts
    FROM xla_events xe,
         xla_transaction_entities_upg xte,
	 ap_invoices_all ai
   WHERE xe.application_id = 200
     AND xte.application_id = 200
     AND xe.entity_id = xte.entity_id
     AND xte.entity_code = 'AP_INVOICES'
     AND xe.event_status_code NOT IN ('P', 'N', 'Z')
     AND nvl(xte.source_id_int_1, -99) = ai.invoice_id
     AND xte.ledger_id = ai.set_of_books_id
     AND ai.invoice_id = l_invoice_id
     AND rownum = 1;

  IF l_cnt_unacc_inv_evnts > 0  THEN
    Push_Error(p_error_code  => 'UNACCOUNTED INVOICE',
               p_error_stack => p_rejection_tab);
  END IF;


  l_debug_info := 'Check if any of the Payment events pertaining '||
                  'to the Invoice have been accounted in 11i ';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   G_MODULE_NAME||l_procedure_name,
                   l_debug_info);
  END IF;


  SELECT count(*)
    INTO l_cnt_unacc_pay_evnts
    FROM xla_events xe,
         xla_transaction_entities_upg xte,
         ap_invoice_payments_all aip
   WHERE xe.application_id = 200
     AND xte.application_id = 200
     AND xte.entity_code = 'AP_PAYMENTS'
     AND xe.entity_id = xte.entity_id
     AND aip.invoice_id = l_invoice_id
     AND nvl(xte.source_id_int_1, -99) = aip.check_id
     AND xte.ledger_id = aip.set_of_books_id
     AND xe.event_status_code NOT IN ('P', 'N', 'Z')
     AND rownum = 1;

  IF l_cnt_unacc_pay_evnts > 0  THEN
    Push_Error(p_error_code  => 'UNACCOUNTED PAYMENT',
               p_error_stack => p_rejection_tab);
  END IF;


  IF l_cnt_unacc_inv_evnts = 0 AND
     l_cnt_unacc_pay_evnts = 0 THEN

    l_debug_info := 'Checking if any of the Invoice events is not transferred '||
                    'to GL';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     l_debug_info);
    END IF;

    SELECT count(*)
      INTO l_cnt_untrx_inv_evnts
      FROM xla_events xe,
           xla_ae_headers xah,
           xla_transaction_entities_upg xte,
	   ap_invoices_all ai
     WHERE xe.application_id = 200
       AND xte.application_id = 200
       AND xah.application_id = 200
       AND xe.entity_id = xte.entity_id
       AND xte.entity_code = 'AP_INVOICES'
       AND xe.event_status_code = 'P'
       AND xah.event_id = xe.event_id
       AND xah.accounting_entry_status_code = 'F'
       AND xah.gl_transfer_status_code <> 'Y'
       AND nvl(xte.source_id_int_1, -99) = ai.invoice_id
       AND xte.ledger_id = ai.set_of_books_id
       AND ai.invoice_id = l_invoice_id
       AND rownum = 1;

    IF l_cnt_untrx_inv_evnts > 0 THEN
      Push_Error(p_error_code  => 'UNTRANSFERRED INVOICE',
                 p_error_stack => p_rejection_tab);
    END IF;

    l_debug_info := 'Checking if any of the Payment Events is not transferred '||
                    'to GL';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     l_debug_info);
    END IF;

    SELECT count(*)
      INTO l_cnt_untrx_pay_evnts
      FROM xla_events xe,
           xla_ae_headers xah,
           xla_transaction_entities_upg xte,
           ap_invoice_payments_all aip
     WHERE xe.application_id = 200
       AND xte.application_id = 200
       AND xte.entity_code = 'AP_PAYMENTS'
       AND xe.entity_id = xte.entity_id
       AND aip.invoice_id = l_invoice_id
       AND nvl(xte.source_id_int_1, -99) = aip.check_id
       AND xte.ledger_id = aip.set_of_books_id
       AND xe.event_status_code = 'P'
       AND xah.event_id = xe.event_id
       AND xah.accounting_entry_status_code = 'F'
       AND xah.gl_transfer_status_code <> 'Y'
       AND rownum = 1;

    IF l_cnt_untrx_pay_evnts > 0 THEN
      Push_Error(p_error_code  => 'UNTRANSFERRED PAYMENT',
                 p_error_stack => p_rejection_tab);
    END IF;

  END IF;

  -- Find the event on which we need to create the final
  -- Payment Rounding

  l_debug_info := 'fetch the event for which we need to round';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   G_MODULE_NAME||l_procedure_name,
                   l_debug_info);
  END IF;

  SELECT max(xe.event_id)
    INTO l_max_event_id
    FROM xla_events xe
   WHERE xe.application_id = 200
     AND xe.event_status_code = 'P'
     AND xe.event_id IN
         (SELECT aph.accounting_event_id
            FROM ap_payment_history_all aph,
                 ap_invoice_payments_all aip
           WHERE aip.check_id = aph.check_id
             AND aip.invoice_id = l_invoice_id
	     AND aph.rev_pmt_hist_id IS NULL
             AND aph.transaction_type IN ('PAYMENT CREATED',
	                                  'REFUND RECORDED',
	                                  'PAYMENT ADJUSTED',
                                          'MANUAL PAYMENT ADJUSTED',
					  'PAYMENT CLEARING',
					  'PAYMENT CLEARING ADJUSTED'
					  )
             AND NOT EXISTS
                 (SELECT 1
                    FROM ap_payment_history_all aph_rev
                   WHERE aph_rev.check_id = aph.check_id
                     AND nvl(aph_rev.related_event_id, aph_rev.accounting_event_id)
                                     = nvl(aph.related_event_id, aph.accounting_event_id)
                     AND aph_rev.rev_pmt_hist_id IS NOT NULL
		  )
          UNION
          SELECT aid.accounting_event_id
            FROM ap_invoice_distributions_all aid
           WHERE aid.invoice_id = l_invoice_id
             AND aid.line_type_lookup_code = 'PREPAY'
             AND nvl(aid.reversal_flag, 'N') <> 'Y')
     AND EXISTS
         (SELECT 1
	    FROM xla_ae_headers xah,
	         xla_ae_lines xal
           WHERE xah.application_id = 200
	     AND xal.application_id = 200
	     AND xah.event_id = xe.event_id
	     AND xah.ae_header_id = xal.ae_header_id
	     AND xal.accounting_class_code = 'LIABILITY');

  p_op_event_id := l_max_event_id;
  l_debug_info := 'Check if ane event has been suitably determined for '||
                  'rounding';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   G_MODULE_NAME||l_procedure_name,
                   l_debug_info);
  END IF;

  IF l_max_event_id IS NULL THEN
    Push_Error(p_error_code  => 'NO AVAILABLE EVENT',
               p_error_stack => p_rejection_tab);
    P_rej_count := p_rejection_tab.COUNT;
    P_return_status := FALSE;

    l_debug_info := 'Cannot proceed without an available event,'||
                    'bailing out';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     l_debug_info);
    END IF;

    RETURN;

  END IF;

  l_debug_info := 'For the event type determined set the event '||
                  'type O/P flag appropriately ';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   G_MODULE_NAME||l_procedure_name,
                   l_debug_info);
  END IF;

  SELECT xe.event_type_code
    INTO p_op_event_type
    FROM xla_events xe
   WHERE xe.application_id = 200
     AND xe.event_id = l_max_event_id;


  l_debug_info := ' Check if the Invoice is fully paid ';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   G_MODULE_NAME||l_procedure_name,
                   l_debug_info);
  END IF;


  OPEN Ap_Acctg_Pay_Dist_Pkg.Invoice_Header(l_invoice_id);
  FETCH Ap_Acctg_Pay_Dist_Pkg.Invoice_Header INTO l_inv_rec;
  CLOSE Ap_Acctg_Pay_Dist_Pkg.Invoice_Header;

  l_debug_info := 'Before the is_final_payment api call';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   G_MODULE_NAME||l_procedure_name,
                   l_debug_info);
  END IF;


  l_is_final_pay := Ap_Accounting_Pay_Pkg.Is_Final_Payment
                         (P_Inv_Rec             => l_Inv_Rec,
                          P_Payment_Amount      => 0,
                          P_Discount_Amount     => 0,
                          P_Prepay_Amount       => 0,
                          P_Transaction_Type    => p_op_event_type,
                          P_calling_sequence    => l_calling_sequence);

  IF NOT l_is_final_pay THEN
    Push_Error(p_error_code  => 'NOT FINAL PAYMENT',
               p_error_stack => p_rejection_tab);
  END IF;

  -- Check the count of the Rejections in the stack, if
  -- Rejections have been incurrent, do not proceed further
  -- and hence return
  p_rej_count := p_rejection_tab.COUNT;

  l_debug_info := 'The final rejection count after evaluating all the '||
                  'factors for final_pay rounding is '||p_rej_count;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   G_MODULE_NAME||l_procedure_name,
                   l_debug_info);
  END IF;


  IF p_rej_count > 0 THEN
    l_debug_info := 'Since there are rejections, setting the return status '||
                    'to false, and returning';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     l_debug_info);
    END IF;

    p_return_status := FALSE;
    RETURN;
  END IF;

  l_debug_info := 'Determine the max id for the distribution '||
                  'pertaining to the Payment/Prepayment distribution ';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   G_MODULE_NAME||l_procedure_name,
                   l_debug_info);
  END IF;


  IF p_op_event_type NOT LIKE 'PREPAY%' THEN

    SELECT max(aphd.payment_hist_dist_id)
      INTO l_max_pay_dist_id
      FROM ap_payment_hist_dists aphd
     WHERE aphd.accounting_event_id = l_max_event_id;

  ELSE

    SELECT max(apad.prepay_app_dist_id)
      INTO l_max_prepay_dist_id
      FROM ap_prepay_app_dists apad
     WHERE apad.accounting_event_id = l_max_event_id;

  END IF;

  -- Call the final Payment rounding api, for the
  -- specific event

  l_debug_info := 'Fetching the event record';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   G_MODULE_NAME||l_procedure_name,
                   l_debug_info);
  END IF;


  OPEN xla_evnt_dtls(l_max_event_id);
  FETCH xla_evnt_dtls INTO l_xla_event_rec;
  CLOSE xla_evnt_dtls;

  IF p_op_event_type NOT LIKE 'PREPAY%' THEN

    l_debug_info := 'fetching the Payment History Record';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     l_debug_info);
    END IF;

    OPEN Ap_Acctg_Pay_Dist_Pkg.Payment_History(l_max_event_id);
    FETCH Ap_Acctg_Pay_Dist_Pkg.Payment_History INTO l_pay_hist_rec;
    CLOSE Ap_Acctg_Pay_Dist_Pkg.Payment_History;

    l_debug_info := 'Fetching the Invoice Payment Record';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     l_debug_info);
    END IF;

    -- We need to fetch the Invoice Payment record depending on the type
    -- of the event, in case it is present on Invoice Payments, one
    -- of the Invoice Payment Records can be used on which the event is
    -- stamped
    --
    -- In case it is a clearing event, or it is an Adjustment event, we
    -- would be fetching one of the Invoice Payments corresponding to the
    -- check, to which the event belongs
    --

    l_debug_info := 'before fetching the check_id';
    SELECT xte.source_id_int_1
      INTO l_check_id
      FROM xla_transaction_entities_upg xte,
           xla_events xe
     WHERE xe.application_id = 200
       AND xte.application_id = 200
       AND xe.entity_id = xte.entity_id
       AND xte.entity_code = 'AP_PAYMENTS'
       AND xe.event_id = l_max_event_id;

    l_debug_info := 'Check_id :'||l_check_id||' fetched for the event ';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     l_debug_info);
    END IF;

    IF p_op_event_type NOT IN ('PAYMENT ADJUSTED','PAYMENT CLEARED', 'PAYMENT CLEARING ADJUSTED') THEN

      l_debug_info := ' Event type :'||p_op_event_type||' would be present on Invoice payments '||
                      ' Cursor Invoice_Payments opened with :'||
		      ' Invoice_id:'||l_invoice_id||' Check_id:'||l_check_id||
		      ' Event_id:'||l_max_event_id;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,
                       G_MODULE_NAME||l_procedure_name,
                       l_debug_info);
      END IF;

      OPEN Invoice_Payments(l_invoice_id, l_check_id, l_max_event_id);
      FETCH Invoice_Payments INTO l_inv_pay_rec;
      CLOSE Invoice_Payments;

    ELSE

      l_debug_info := ' Event type :'||p_op_event_type||' would not be present on Invoice payments '||
                      ' Cursor Invoice_Payments opened with :'||
		      ' Invoice_id:'||l_invoice_id||' Check_id:'||l_check_id||
		      ' Event_id: null';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,
                       G_MODULE_NAME||l_procedure_name,
                       l_debug_info);
      END IF;


      OPEN Invoice_Payments(l_invoice_id, l_check_id, null);
      FETCH Invoice_Payments INTO l_inv_pay_rec;
      CLOSE Invoice_Payments;

    END IF;

  ELSE

    l_debug_info := 'Fetching the Prepay History Record';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     l_debug_info);
    END IF;

    OPEN Prepay_History(l_invoice_id, l_max_event_id);
    FETCH Prepay_History INTO l_prepay_hist_rec;
    CLOSE Prepay_History;

    l_debug_info := 'Fetching the Prepay Distribution record';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     l_debug_info);
    END IF;

    OPEN Prepay_Dists(l_invoice_id, l_max_event_id);
    FETCH Prepay_Dists INTO l_prepay_dist_rec;
    CLOSE Prepay_Dists;

  END IF;

  l_debug_info := 'Before the call to the Final Pay api';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   G_MODULE_NAME||l_procedure_name,
                   l_debug_info);
  END IF;


  Ap_Acctg_Pay_Round_Pkg.Final_Pay
           (p_xla_event_rec         => l_xla_event_rec,
            p_pay_hist_rec          => l_pay_hist_rec,
            p_clr_hist_rec          => l_clr_hist_rec,
            p_inv_rec               => l_inv_rec,
            p_inv_pay_rec           => l_inv_pay_rec,
            p_prepay_inv_rec        => l_prepay_inv_rec,
            p_prepay_hist_rec       => l_prepay_hist_rec,
            p_prepay_dist_rec       => l_prepay_dist_rec,
            p_calling_sequence	    => l_calling_sequence);

  -- depending on the type of the event query the
  -- appropriate table, for the specific event for all
  -- the ids greater than the max id stored


  IF p_op_event_type NOT LIKE 'PREPAY%' THEN

    l_debug_info := 'Fetching the details of the Payment Hist dists created';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     l_debug_info);
    END IF;

    OPEN new_round_pay_dists(l_max_event_id, l_max_pay_dist_id);
    FETCH new_round_pay_dists BULK COLLECT INTO p_pay_dist_tab;
    CLOSE new_round_pay_dists;

    IF p_pay_dist_tab.COUNT = 0 THEN

      Push_Error(p_error_code  => 'NO PAY DIST CREATED',
                 p_error_stack => p_rejection_tab);

      p_return_status := FALSE;
      p_rej_count := p_rejection_tab.COUNT;

    ELSE
      p_return_status := TRUE;
    END IF;

  ELSE

    l_debug_info := 'Fetching the details of the Prepay Hist Dists Created';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     l_debug_info);
    END IF;

    OPEN new_round_prepay_dists(l_max_event_id, l_max_prepay_dist_id);
    FETCH new_round_prepay_dists BULK COLLECT INTO p_prepay_dist_tab;
    CLOSE new_round_prepay_dists;

    IF p_prepay_dist_tab.COUNT = 0 THEN

      Push_Error(p_error_code  => 'NO PREPAY DIST CREATED',
                 p_error_stack => p_rejection_tab);

      p_return_status := FALSE;
      p_rej_count := p_rejection_tab.COUNT;

    ELSE
      p_return_status := TRUE;
    END IF;


  END IF;

  l_debug_info := 'Committing if asked to';
  IF nvl(p_commit_flag, 'N') = 'Y' THEN
    COMMIT;
  END IF;

  l_log_msg := 'Procedure Ends';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE,
                   G_MODULE_NAME||l_procedure_name,
                   l_log_msg);
  END IF;



EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE <> -20001 THEN
      p_error_msg := ' Encountered an Exception '||SQLERRM||
                     ' at : '||l_calling_sequence||
                     ' while performing : '||l_debug_info||
                     ' for Invoice_id : '||l_invoice_id;

      p_return_status := FALSE;

      Push_Error(p_error_code  => 'UNEXPECTED EXCEPTION',
                 p_error_stack => p_rejection_tab);

      p_rej_count := p_rejection_tab.COUNT;


    END IF;
END;


Function Is_period_open(P_Date IN date,
                        P_Org_Id IN number default mo_global.get_current_org_id)
return varchar2
IS
l_period_name           Varchar2(15) Default Null;
Begin
SELECT period_name
Into l_period_name
      FROM gl_period_statuses GLPS,
           ap_system_parameters_all SP
     WHERE application_id = 200
       AND sp.org_id = P_Org_Id
       AND GLPS.set_of_books_id = SP.set_of_books_id
       AND trunc(P_Date) BETWEEN start_date AND end_date
       AND closing_status in ('O', 'F')
       AND NVL(adjustment_period_flag, 'N') = 'N';


 return (l_period_name);
 Exception
 when others then
return (NULL);
End;

Function get_open_period_start_date(P_Org_Id IN number)
return date
Is
l_start_date    Date;

Begin
SELECT Start_Date
Into  l_start_date
FROM (
      SELECT DISTINCT gps.Period_Name, trunc(gps.Start_Date) Start_date
      FROM gl_Period_Statuses gps,
           ap_System_Parameters_All Asp
      WHERE gps.Application_Id = 200
       AND gps.Set_Of_Books_Id = Asp.Set_Of_Books_Id
       AND Nvl(gps.Adjustment_Period_Flag,'N') = 'N'
       AND Nvl(Asp.Org_Id,- 99) = Nvl(p_org_id,- 99)
       AND gps.closing_Status in ('O', 'F')
       INTERSECT
      SELECT DISTINCT gps.Period_Name, trunc(gps.start_Date) start_date
      FROM gl_Period_Statuses gps,
           ap_System_Parameters_All Asp
      WHERE gps.Application_Id = 101
       AND gps.Set_Of_Books_Id = Asp.Set_Of_Books_Id
       AND Nvl(gps.Adjustment_Period_Flag,'N') = 'N'
       AND Nvl(Asp.Org_Id,- 99) = Nvl(P_Org_Id,- 99)
       AND gps.closing_Status in ('O', 'F')
       order by Start_date
       )
 WHERE rownum < 2;

 return (l_start_date);
 Exception
 when others then
return (NULL);
 End;

/*
USE :
Public api to delete prepay appl/payment cascade adjustment events

INPUT :
   p_source_type      - 'AP_INVOICES' -- for prepay appl
                        'AP_PAYMENTS' -- for payment
   p_source_id        - invoice_id    -- when p_source_type is 'AP_INVOICES'
                        check_id      -- when p_source_type is 'AP_PAYMENTS'
   p_related_event_id - related event id of cascade adjustment.
                        This is added to handle single event only
                        for ex: in case when single event id undone..etc

NOTES :
1. org context needs to be set prior to call the api
2. commit is to be handled by the calling api

*/
FUNCTION delete_cascade_adjustments
  (p_source_type      IN VARCHAR2,
   p_source_id        IN NUMBER,
   p_related_event_id IN NUMBER DEFAULT NULL)
RETURN BOOLEAN IS

  l_procedure_name CONSTANT VARCHAR2(30) := 'delete_cascade_adjustments()';
  l_debug_info              VARCHAR2(1000);

  l_event_security_context  XLA_EVENTS_PUB_PKG.T_SECURITY;
  l_event_source_info       XLA_EVENTS_PUB_PKG.T_EVENT_SOURCE_INFO;

  CURSOR payment_cascade_adj_cur IS
  SELECT DISTINCT aph_adj.accounting_event_id
    FROM ap_payment_history_all aph
         , xla_events xe
         , ap_payment_history_all aph_adj
         , xla_events xe_adj
   WHERE aph.check_id = p_source_id
     AND aph.accounting_event_id = NVL(p_related_event_id
                                       , aph.accounting_event_id)
     AND aph.transaction_type IN('PAYMENT CREATED',
                                 'PAYMENT MATURITY',
                                 'PAYMENT CLEARING',
                                 'REFUND RECORDED')
     AND aph.posted_flag <> 'Y'
     AND xe.event_id = aph.accounting_event_id
     AND xe.event_status_code <> 'P'
     AND aph_adj.check_id = aph.check_id
     AND aph_adj.related_event_id <> aph_adj.accounting_event_id
     AND aph_adj.related_event_id = aph.accounting_event_id
     AND aph_adj.transaction_type IN('PAYMENT ADJUSTED',
                                     'PAYMENT MATURITY ADJUSTED',
                                     'PAYMENT CLEARING ADJUSTED',
                                     'REFUND ADJUSTED')
     AND aph_adj.posted_flag <> 'Y'
     AND xe_adj.event_id = aph_adj.accounting_event_id
     AND xe_adj.event_status_code <> 'P';

  CURSOR prepay_appl_cascade_adj_cur IS
  SELECT DISTINCT apph_adj.accounting_event_id
    FROM ap_invoices_all ai
         , ap_prepay_history_all apph
         , xla_events xe
         , ap_prepay_history_all apph_adj
         , xla_events xe_adj
   WHERE 1=1
     AND ai.invoice_id = p_source_id
     AND ap_invoices_utility_pkg.get_approval_status
                                (ai.invoice_id,
                                 ai.invoice_amount,
                                 ai.payment_status_flag,
                                 ai.invoice_type_lookup_code)
                IN ('NEEDS REAPPROVAL',
                    'NEVER APPROVED',
                    'UNAPPROVED')
     AND apph.invoice_id = ai.invoice_id
     AND apph.accounting_event_id = NVL(p_related_event_id,
                                        apph.accounting_event_id)
     AND apph.transaction_type IN('PREPAYMENT APPLIED')
     AND apph.posted_flag <> 'Y'
     AND NOT EXISTS
         (
          SELECT 'encumbered'
            FROM ap_invoice_distributions_all aid
  	   WHERE aid.accounting_event_id = apph.accounting_event_id
             AND NVL(aid.encumbered_flag, 'N') NOT IN ('N', 'H', 'P')
         )
     AND xe.event_id = apph.accounting_event_id
     AND xe.event_status_code <> 'P'
     AND apph_adj.invoice_id = apph.invoice_id
     AND apph_adj.related_prepay_app_event_id <> apph_adj.accounting_event_id
     AND apph_adj.related_prepay_app_event_id = apph.accounting_event_id
     AND apph_adj.transaction_type IN('PREPAYMENT APPLICATION ADJ')
     AND apph_adj.posted_flag <> 'Y'
     AND xe_adj.event_id = apph_adj.accounting_event_id
     AND xe_adj.event_status_code <> 'P';

BEGIN

  l_debug_info := 'Begin : function '||l_procedure_name;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   G_MODULE_NAME||l_procedure_name,
                   l_debug_info);
  END IF;

  l_debug_info := 'input : p_source_type = '||p_source_type
                      ||', p_source_id = '||p_source_id;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   G_MODULE_NAME||l_procedure_name,
                   l_debug_info);
  END IF;

  /* validating and getting the EVENT SOURCE information */
  BEGIN

    SELECT security_id_int_1,
           legal_entity_id,
           ledger_id,
           entity_code,
           source_id_int_1,
           transaction_number,
           application_id
      INTO l_event_security_context.security_id_int_1,
           l_event_source_info.legal_entity_id,
           l_event_source_info.ledger_id,
           l_event_source_info.entity_type_code,
           l_event_source_info.source_id_int_1,
           l_event_source_info.transaction_number,
           l_event_source_info.application_id
      FROM xla_transaction_entities_upg xte
     WHERE NVL(xte.source_id_int_1, -99) = p_source_id
       AND xte.entity_code = p_source_type
       AND xte.application_id = 200;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       l_debug_info := 'source information is INVALID';
       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        l_debug_info);
       END IF;
     RETURN FALSE;
  END;


  IF p_source_type = 'AP_INVOICES' THEN

    /* delete PREPAY APPL cascade adjustments */
    FOR i IN prepay_appl_cascade_adj_cur
    LOOP

      AP_XLA_EVENTS_PKG.delete_event
                        ( p_event_source_info => l_event_source_info,
                          p_event_id          => i.accounting_event_id,
                          p_valuation_method  => NULL,
                          p_security_context  => l_event_security_context,
                          p_calling_sequence  => l_procedure_name
                        );

      DELETE ap_prepay_app_dists apad
       WHERE apad.accounting_event_id = i.accounting_event_id
         AND NOT EXISTS
             (
              SELECT 1
                FROM xla_events xe
               WHERE xe.event_id = apad.accounting_event_id
                 AND xe.application_id = 200
             );

      DELETE ap_prepay_history_all apph
       WHERE apph.accounting_event_id = i.accounting_event_id
         AND NOT EXISTS
             (
              SELECT 1
                FROM xla_events xe
               WHERE xe.event_id = apph.accounting_event_id
                 AND xe.application_id = 200
             );

    END LOOP;

  ELSIF p_source_type = 'AP_PAYMENTS' THEN

    /* delete PAYMENT cascade adjustments */
    FOR i IN payment_cascade_adj_cur
    LOOP

      AP_XLA_EVENTS_PKG.delete_event
                        ( p_event_source_info => l_event_source_info,
                          p_event_id          => i.accounting_event_id,
                          p_valuation_method  => NULL,
                          p_security_context  => l_event_security_context,
                          p_calling_sequence  => l_procedure_name
                        );

      DELETE ap_payment_hist_dists aphd
       WHERE aphd.accounting_event_id = i.accounting_event_id
         AND NOT EXISTS
             (
              SELECT 1
                FROM xla_events xe
               WHERE xe.event_id = aphd.accounting_event_id
                 AND xe.application_id = 200
             );

      DELETE ap_payment_history_all aph
       WHERE aph.accounting_event_id = i.accounting_event_id
         AND NOT EXISTS
             (
              SELECT 1
                FROM xla_events xe
               WHERE xe.event_id = aph.accounting_event_id
                 AND xe.application_id = 200
             );

    END LOOP;

  END IF; -- p_source_type = 'AP_INVOICES'

  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     SQLERRM);
    END IF;

    RETURN FALSE;
END delete_cascade_adjustments;


END AP_Acctg_Data_Fix_PKG;

/
