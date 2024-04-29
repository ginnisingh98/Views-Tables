--------------------------------------------------------
--  DDL for Package Body ECE_EXTRACT_UTILS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECE_EXTRACT_UTILS_PUB" AS
-- $Header: ECPEXTUB.pls 120.2 2005/09/29 11:39:23 arsriniv ship $
debug_mode_on_insert BOOLEAN := FALSE;
debug_mode_on_select BOOLEAN := FALSE;
debug_mode_on_prod   BOOLEAN := FALSE;
g_error_count        NUMBER  := 0;

---	PROCEDURE select_clause.
---	Creation	Oct. 24, 1996
---
---	Procedure select_clause builds a Select clause and a From
---	clause and a Where clause at run time for the dynamic SQL call.

---	It uses the data from the in-parameter p_source_tbl to
---	construst the SELECT clause.    This select
---	clause had already add the TO_CHAR function to convert
---	data to character type.
--	The reason for converting data to VARCHAR is to simplify
--	the dynamic SQL statement.

PROCEDURE select_clause(
            cTransaction_Type       IN VARCHAR2,
            cCommunication_Method   IN VARCHAR2,
            cInterface_Table        IN VARCHAR2,
            p_source_tbl            IN ece_flatfile_pvt.Interface_tbl_type,
            cSelect_string          OUT NOCOPY VARCHAR2,
            cFrom_string            OUT NOCOPY VARCHAR2,
            cWhere_string           OUT NOCOPY VARCHAR2) IS
   xProgress		VARCHAR2(30);
   cOutput_path		VARCHAR2(120);

   cSelect_stmt		VARCHAR2(32000) := 'SELECT ';
   cFrom_stmt		VARCHAR2(32000) := ' FROM ';
   cWhere_stmt		VARCHAR2(32000) := ' WHERE ';

   cTO_CHAR		VARCHAR2(20) := 'TO_CHAR(';
   cDATE		VARCHAR2(40) := ',''YYYYMMDD HH24MISS'')';
   cWord1		VARCHAR2(20) := ' ';
   cWord2		VARCHAR2(40) := ' ';

   iRow_count		NUMBER := p_source_tbl.count;
   iDebug		NUMBER := 0;
BEGIN
   EC_DEBUG.PUSH('ece_extract_utils_pub.select_clause');
   if EC_DEBUG.G_debug_level >= 2 then
   EC_DEBUG.PL(3, 'cTransaction_Type : ',cTransaction_Type);
   EC_DEBUG.PL(3, 'cCommunication_Method: ',cCommunication_Method);
   end if;

   xProgress := 'EXTUB-10-1020';
   For i in 1..iRow_count loop

      xProgress := 'EXTUB-10-1030';
      g_error_count := i;
      -- **************************************
      -- apply appropriate data conversion
      -- convert everything to VARCHAR
      -- **************************************

      xProgress := 'EXTUB-10-1040';
      if 'DATE' = p_source_tbl(i).data_type Then
         xProgress := 'EXTUB-10-1050';
         cWord1 := cTO_CHAR;
         cWord2 := cDATE;
       if EC_DEBUG.G_debug_level >= 2 then
         EC_DEBUG.PL(3, 'cWord1: ',cWord1);
         EC_DEBUG.PL(3, 'cWord2: ',cWord2);
       end if;
      elsif 'NUMBER' = p_source_tbl(i).data_type Then
         xProgress := 'EXTUB-10-1060';
         cWord1 := cTO_CHAR;
         cWord2 := ')';
         if EC_DEBUG.G_debug_level >= 2 then
         EC_DEBUG.PL(3, 'cWord1: ',cWord1);
         EC_DEBUG.PL(3, 'cWord2: ',cWord2);
         end if;
      else
         xProgress := 'EXTUB-10-1070';
         cWord1 := NULL;
         cWord2 := NULL;
      END if;

      -- build SELECT statement
       xProgress := 'EXTUB-10-1080';
       cSelect_stmt :=  cSelect_stmt || ' ' || cWord1 || nvl(p_source_tbl(i).base_column_Name,'NULL') || cWord2 || ',';
     if EC_DEBUG.G_debug_level >= 2 then
	ec_debug.pl(3,'Counter'||i,p_source_tbl(i).interface_column_name);
      end if;
   End Loop;

   -- build FROM, WHERE statements


   -- Loop through the pl/sql table until we get a base_table_name
   -- base_table_name will either be null or the view name we are
   -- using to extract the data.
   xProgress := 'EXTUB-10-1090';
   For i in 1..iRow_count loop
	if p_source_tbl(i).base_table_name is not null then
   	 xProgress := 'EXTUB-10-1095';
	 cFrom_stmt  := cFrom_stmt  || p_source_tbl(i).base_table_name;
	 exit;
	end if;
   End Loop;

   xProgress := 'EXTUB-10-1100';
   cSelect_string := RTRIM (cSelect_stmt, ',');
   xProgress := 'EXTUB-10-1110';
   cFrom_string	  := cFrom_stmt;
   xProgress := 'EXTUB-10-1120';
   cWhere_string  := cWhere_stmt;

   if (debug_mode_on_select) then
      declare
         stmt_1		varchar2(2000) := substrb(RTRIM(cSelect_stmt, ','), 1, 2000);
         stmt_2		varchar2(2000) := substrb(RTRIM(cSelect_stmt, ','), 2001, 2000);
         stmt_3		varchar2(2000) := substrb(RTRIM(cSelect_stmt, ','), 4001, 2000);
      begin
        if EC_DEBUG.G_debug_level >= 2 then
         EC_DEBUG.PL(3, 'stmt_1: ',stmt_1);
         EC_DEBUG.PL(3, 'stmt_2: ',stmt_2);
         EC_DEBUG.PL(3, 'stmt_3: ',stmt_3);
        end if;
         insert into ece_error (creation_date, run_id, line_id, text)
		values( sysdate, 76451, ece_error_s.nextval, stmt_1);
         insert into ece_error (creation_date, run_id, line_id, text)
                values( sysdate, 76451, ece_error_s.nextval, stmt_2);
         insert into ece_error (creation_date, run_id, line_id, text)
                values( sysdate, 76451, ece_error_s.nextval, stmt_3);
      end;
   end if;

   EC_DEBUG.POP('ece_extract_utils_pub.select_clause');
   exception
      when others then
             EC_DEBUG.PL(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','ECE_EXTRACT_UTILS_PUB.Select_Clause');
             EC_DEBUG.PL(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','xProgress');
              EC_DEBUG.PL(0,'EC','ECE_ERROR_CODE','ERROR_CODE',SQLCODE);
              EC_DEBUG.PL(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);

              EC_DEBUG.PL(0,'EC','ECE_PLSQL_POS_NOT_FOUND','COLUMN_NAME', 'to_char(g_error_count)');

         if g_error_count > 0 then
                EC_DEBUG.PL(0,'EC','ECE_PLSQL_VALUE','VALUE', 'p_apps_tbl(g_error_count).value');

                  EC_DEBUG.PL(0,'EC','ECE_PLSQL_DATA_TYPE','DATA_TYPE', 'p_apps_tbl(g_error_count).data_type');


                  EC_DEBUG.PL(0,'EC','ECE_PLSQL_COLUMN_NAME','COLUMN_NAME', 'to_char(g_error_count).base_column_name');

         end if;
         app_exception.raise_exception;

END select_clause;


-- ******************************************************
--
-- Insert into interface table
--
-- This procedure insert data into the EDI interface
-- table
-- The caller pass in the p_source_tbl which contains
-- the data.
-- p_source_tbl also stores a pointer (foreign key) to
-- identify where should the data be placed in the
-- interface table
--
-- ECE_INTERFACE_COLUMNS serves as a data dictionary
-- to store which each data goes in the interface
-- table.
--
-- ******************************************************

PROCEDURE insert_into_interface_tbl(
			iRun_id			IN NUMBER,
			cTransaction_Type	IN VARCHAR2,
			cCommunication_Method	IN VARCHAR2,
			cInterface_Table	IN VARCHAR2,
			p_source_tbl		IN ece_flatfile_pvt.Interface_tbl_type,
			p_foreign_key		IN NUMBER
)
IS

   xProgress		VARCHAR2(30);
   cOutput_path		VARCHAR2(120);

   cInsert_stmt		VARCHAR2(32000) := 'INSERT INTO ';
--   cValue_stmt		VARCHAR2(32000) := 'VALUES ('||iRun_id||',';
   cValue_stmt 		VARCHAR2(32000) := 'VALUES (';
   cSrc_tbl_val_wo_newl VARCHAR2(400);
   cSrc_tbl_val_wo_frmf VARCHAR2(400);
   cSrc_tbl_val_wo_tab  VARCHAR2(400);
   cValue		VARCHAR2(2000);
/*   cTo_NUM		VARCHAR2(20) := 'TO_NUMBER(''';
   cTO_CHAR		VARCHAR2(20) := 'TO_CHAR(''';
   cTO_DATE		VARCHAR2(20) := 'TO_DATE(''';
   cDATE		VARCHAR2(40) := ''',''YYYYMMDD HH24MISS'')';
   cQuote		VARCHAR2(20) := '''';
   cNULL		VARCHAR2(20) := 'NULL';
   cBlank		VARCHAR2(20) := '';
   cWord1		VARCHAR2(20) := ' ';*/
   d_date 		DATE;
   n_number 		NUMBER;
   cWord2		VARCHAR2(40) := ' ';
   c_local_chr_10       VARCHAR2(1) := fnd_global.local_chr(10);
   c_local_chr_13       VARCHAR2(1) := fnd_global.local_chr(13);
   c_local_chr_9        VARCHAR2(1) := fnd_global.local_chr(9);

   c_Insert_cur		INTEGER;
   dummy		INTEGER;

   l_col_name		VARCHAR2(40);
   l_total_rows_of_value  NUMBER := 0;
   l_Row_count		NUMBER;

   TYPE CharTable	IS TABLE OF VARCHAR2(400) INDEX BY BINARY_INTEGER;
   cColumn_val		CharTable;

BEGIN

  if EC_DEBUG.G_debug_level >= 2 then
   EC_DEBUG.PUSH('ece_extract_utils_pub.insert_into_interface_tbl');
   EC_DEBUG.PL(3, 'iRun_id : ',iRun_id);
   EC_DEBUG.PL(3, 'cTransaction_Type: ',cTransaction_Type);
   EC_DEBUG.PL(3, 'cCommunication_Method: ',cCommunication_Method);
   EC_DEBUG.PL(3, 'cInterface_Table: ',cInterface_Table);
   EC_DEBUG.PL(3, 'p_foreign_key: ',p_foreign_key);
  end if;
   xProgress := 'EXTUB-20-1020';
   cInsert_stmt := cInsert_stmt || ' ' || cInterface_Table || '( ';
  if EC_DEBUG.G_debug_level >= 2 then
   EC_DEBUG.PL(3, 'cInsert_stmt: ',cInsert_stmt);
  end if;

   xProgress := 'EXTUB-20-1030';
   l_Row_count := p_source_tbl.count;
 if EC_DEBUG.G_debug_level >= 2 then
   EC_DEBUG.PL(3, 'l_Row_count: ',l_Row_count);
 end if;

 --Bug 2198707
   xProgress := 'EXTUB-20-1040';
   For i in 1..l_Row_count loop
      if p_source_tbl(i).Interface_Column_Name is not null
      then                                                       --Bug 2239977
        cInsert_stmt := cInsert_stmt || ' ' ||
                         p_source_tbl(i).interface_column_Name || ',';

        cValue_stmt  := cValue_stmt || ':b' || i ||',';
     end if;
   end loop;

   xProgress := 'EXTUB-20-1050';
   cInsert_stmt := RTRIM(cInsert_stmt, ',') || ')';

   xProgress := 'EXTUB-20-1060';
   cValue_stmt := RTRIM(cValue_stmt, ',') ||')';

   xProgress := 'EXTUB-20-1070';
   cInsert_stmt := cInsert_stmt || cValue_stmt;
   if EC_DEBUG.G_debug_level = 3 then
   EC_DEBUG.PL(3, 'cInsert_stmt: ',cInsert_stmt);
   end if;

   xProgress := 'EXTUB-20-1080';
   c_Insert_cur := dbms_sql.open_cursor;
    if EC_DEBUG.G_debug_level = 3 then
    EC_DEBUG.PL(3, 'c_Insert_cur: ',c_Insert_cur);
    end if;

   xProgress := 'EXTUB-20-1090';
   dbms_sql.parse(c_Insert_cur, cInsert_stmt, dbms_sql.native);

   xProgress := 'EXTUB-20-1100';
   For i in 1..l_Row_count loop

      -- **************************************
      --
      -- For each data, find out where
      -- should it go in the interface table
      -- We use data_loc_id as key between the
      -- ece_source_date_loc and the
      -- ece_interface_columns table
      --
      -- **************************************

      xProgress := 'EXTUB-20-1110';
      g_error_count := i;

      if p_source_tbl(i).Interface_Column_Name = 'RUN_ID' then

           xProgress := 'EXTUB-20-1120';
           dbms_sql.bind_variable(c_Insert_cur,'b'||i,iRun_id);
      elsif p_source_tbl(i).Interface_Column_Name
                = 'TRANSACTION_RECORD_ID' then

           xProgress := 'EXTUB-20-1130';
           dbms_sql.bind_variable(c_Insert_cur,'b'||i,p_foreign_key);
      elsif p_source_tbl(i).Interface_Column_Name is not null
      then

         -- **************************************
         --
	         -- apply appropriate data conversion
         -- All data passed in is in VARCHAR,
         -- we need to convert it because
         -- the interface table is expecting the
         -- correct data type
         --
         -- **************************************
            --Bug 2252075

            cSrc_tbl_val_wo_newl :=
                replace(p_source_tbl(i).value, c_local_chr_10,'');
           cSrc_tbl_val_wo_frmf :=
                replace(cSrc_tbl_val_wo_newl, c_local_chr_13,'');
           cSrc_tbl_val_wo_tab  :=
                replace(cSrc_tbl_val_wo_frmf, c_local_chr_9,'');
--Commented the line 'cValue := replace(cSrc_tbl_val_wo_tab,'''','''''');' 2458190.
           --cValue := replace(cSrc_tbl_val_wo_tab,'''','''''');
           cValue := cSrc_tbl_val_wo_tab;

         xProgress := 'EXTUB-20-1140';
         if 'DATE' = p_source_tbl(i).data_type
         Then
         xProgress := 'EXTUB-20-1150';
            if p_source_tbl(i).value is not NULL
            then
               xProgress := 'EXTUB-20-1160';
               d_date := TO_DATE(cValue,'YYYYMMDD HH24MISS');
            else
               xProgress := 'EXTUB-20-1170';
               d_date := NULL;
            end if;
   dbms_sql.bind_variable(c_Insert_cur,'b'||i,d_date);
         elsif 'NUMBER' = p_source_tbl(i).data_type
         Then
            xProgress := 'EXTUB-20-1180';
            if p_source_tbl(i).value is not NULL
            then
               xProgress := 'EXTUB-20-1190';
               n_number:= TO_NUMBER(cValue);
             else
               xProgress := 'EXTUB-20-1200';
               n_number:= NULL;
            end if;
            dbms_sql.bind_variable(c_Insert_cur,'b'||i,n_number);
         else
            xProgress := 'EXTUB-20-1210';

          dbms_sql.bind_variable(c_Insert_cur,'b'||i,cValue);
          END if; -- if DATE

       end if;
     End Loop;

/*  Bug 2198707 - The following code is commented out.
         if 'DATE' = p_source_tbl(i).data_type
         Then
            xProgress := 'EXTUB-20-1080';
            if p_source_tbl(i).value is not NULL
            then
               xProgress := 'EXTUB-20-1090';
               cWord1 := cTO_DATE;
               cWord2 := cDATE;
              if EC_DEBUG.G_debug_level >= 2 then
               EC_DEBUG.PL(3, 'cWord1: ',cWord1);
               EC_DEBUG.PL(3, 'cWord2: ',cWord2);
              end if;
              else
               xProgress := 'EXTUB-20-1100';
               cWord1 := cQuote;
               cWord2 := cQuote;
          if EC_DEBUG.G_debug_level >= 2 then
               EC_DEBUG.PL(3, 'cWord1: ',cWord1);
               EC_DEBUG.PL(3, 'cWord2: ',cWord2);
          end if;
             end if;
         elsif 'NUMBER' = p_source_tbl(i).data_type
         Then
            xProgress := 'EXTUB-20-1110';
            if p_source_tbl(i).value is not NULL
            then
               xProgress := 'EXTUB-20-1120';
               cWord1 := cTO_NUM;
               cWord2 := ''')';
               if EC_DEBUG.G_debug_level >= 2 then
               EC_DEBUG.PL(3, 'cWord1: ',cWord1);
               EC_DEBUG.PL(3, 'cWord2: ',cWord2);
               end if;
             else
               xProgress := 'EXTUB-20-1130';
               cWord1 := cQuote;
               cWord2 := cQuote;
               if EC_DEBUG.G_debug_level >= 2 then
               EC_DEBUG.PL(3, 'cWord1: ',cWord1);
               EC_DEBUG.PL(3, 'cWord2: ',cWord2);
               end if;
            end if;

         else
            xProgress := 'EXTUB-20-1140';
            cWord1 := cQuote;
            cWord2 := cQuote;
            if EC_DEBUG.G_debug_level >= 2 then
            EC_DEBUG.PL(3, 'cWord1: ',cWord1);
            EC_DEBUG.PL(3, 'cWord2: ',cWord2);
            end if;
            END if; -- if DATE

         xProgress := 'EXTUB-20-1150';
         if p_source_tbl(i).Interface_Column_Name = 'RUN_ID' then

           xProgress := 'EXTUB-20-1160';
	   cValue := to_char(iRun_id);
          if EC_DEBUG.G_debug_level >= 2 then
             EC_DEBUG.PL(3, 'cValue: ',cValue);
          end if;
         elsif p_source_tbl(i).Interface_Column_Name
	   	= 'TRANSACTION_RECORD_ID' then

           xProgress := 'EXTUB-20-1170';
	   cValue := to_char(p_foreign_key);
           if EC_DEBUG.G_debug_level >= 2 then
           EC_DEBUG.PL(3, 'cValue: ',cValue);
           end if;
         else

           xProgress := 'EXTUB-20-1180';
           cSrc_tbl_val_wo_newl :=
                replace(p_source_tbl(i).value, c_local_chr_10,'');
           cSrc_tbl_val_wo_frmf :=
                replace(cSrc_tbl_val_wo_newl, c_local_chr_13,'');
           cSrc_tbl_val_wo_tab  :=
                replace(cSrc_tbl_val_wo_frmf, c_local_chr_9,'');
	   cValue := replace(cSrc_tbl_val_wo_tab,'''','''''');
            if EC_DEBUG.G_debug_level >= 2 then
            EC_DEBUG.PL(3, 'cValue: ',cValue);
            end if;
         end if;

         -- build INSERT statement
         xProgress := 'EXTUB-20-1190';
         cInsert_stmt := cInsert_stmt || ' ' ||
			 p_source_tbl(i).interface_column_Name || ',';

         xProgress := 'EXTUB-20-1200';
         cValue_stmt  := cValue_stmt || cWord1 || cValue || cWord2 ||',';


     end if;
   End Loop;

   xProgress := 'EXTUB-20-1210';
   cInsert_stmt := RTRIM(cInsert_stmt, ',') || ')';

   xProgress := 'EXTUB-20-1220';
   cValue_stmt := RTRIM(cValue_stmt, ',') ||')';

   xProgress := 'EXTUB-20-1230';
   cInsert_stmt := cInsert_stmt || cValue_stmt;
   if EC_DEBUG.G_debug_level >= 2 then
   EC_DEBUG.PL(3, 'cInsert_stmt: ',cInsert_stmt);
   end if;
   xProgress := 'EXTUB-20-1240';
   c_Insert_cur := dbms_sql.open_cursor;
    if EC_DEBUG.G_debug_level >= 2 then
    EC_DEBUG.PL(3, 'c_Insert_cur: ',c_Insert_cur);
    end if;
   xProgress := 'EXTUB-20-1250';
   dbms_sql.parse(c_Insert_cur, cInsert_stmt, dbms_sql.native);
*/

   xProgress := 'EXTUB-20-1220';
   dummy := dbms_sql.execute(c_Insert_cur);
    if EC_DEBUG.G_debug_level >= 2 then
    EC_DEBUG.PL(3, 'dummy: ',dummy);
    end if;
   if (debug_mode_on_insert)
   then
      declare
         stmt_1		varchar2(2000) := substrb(cInsert_stmt, 1, 2000);
         stmt_2		varchar2(2000) := substrb(cInsert_stmt, 2001, 2000);
         stmt_3		varchar2(2000) := substrb(cInsert_stmt, 4001, 2000);
         stmt_4		varchar2(2000) := substrb(cInsert_stmt, 6001, 2000);
         stmt_5		varchar2(2000) := substrb(cInsert_stmt, 8001, 2000);
      begin
         if EC_DEBUG.G_debug_level >= 2 then
         EC_DEBUG.PL(3, 'stmt_1: ',stmt_1);
         EC_DEBUG.PL(3, 'stmt_2: ',stmt_2);
         EC_DEBUG.PL(3, 'stmt_3: ',stmt_3);
         EC_DEBUG.PL(3, 'stmt_4: ',stmt_4);
         EC_DEBUG.PL(3, 'stmt_5: ',stmt_5);
         end if;
          insert into ece_error (run_id, line_id, text) values( 478, ece_error_s.nextval, stmt_1);
         insert into ece_error (run_id, line_id, text) values( 478, ece_error_s.nextval, stmt_2);
         insert into ece_error (run_id, line_id, text) values( 478, ece_error_s.nextval, stmt_3);
         insert into ece_error (run_id, line_id, text) values( 478, ece_error_s.nextval, stmt_4);
         insert into ece_error (run_id, line_id, text) values( 478, ece_error_s.nextval, stmt_5);
      end;
--commit;
   end if;

   xProgress := 'EXTUB-20-1230';
   dbms_sql.close_cursor(c_Insert_cur);

  if EC_DEBUG.G_debug_level >= 2 then
   EC_DEBUG.POP('ece_extract_utils_pub.insert_into_interface_tbl');
  end if;
   exception
      when others
      then
             EC_DEBUG.PL(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','ECE_EXTRACT_UTILS_PUB.Insert_into_Interface_tbl');
             EC_DEBUG.PL(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','xProgress');
              EC_DEBUG.PL(0,'EC','ECE_ERROR_CODE','ERROR_CODE',SQLCODE);
              EC_DEBUG.PL(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);

              EC_DEBUG.PL(0,'EC','ECE_PLSQL_POS_NOT_FOUND','COLUMN_NAME', 'to_char(g_error_count)');

         if g_error_count > 0 then
               EC_DEBUG.PL(0,'EC','ECE_PLSQL_VALUE','VALUE', 'p_apps_tbl(g_error_count).value');

                  EC_DEBUG.PL(0,'EC','ECE_PLSQL_DATA_TYPE','DATA_TYPE', 'p_apps_tbl(g_error_count).data_type');


                  EC_DEBUG.PL(0,'EC','ECE_PLSQL_COLUMN_NAME','COLUMN_NAME', 'to_char(g_error_count).base_column_name');

         end if;
         app_exception.raise_exception;

END insert_into_interface_tbl;

PROCEDURE insert_into_prod_interface(
			p_Interface_Table	IN VARCHAR2,
			p_Insert_cur		IN OUT NOCOPY INTEGER,
			p_apps_tbl		IN ece_flatfile_pvt.Interface_tbl_type)

IS
   xProgress		VARCHAR2(30);
   cOutput_path		VARCHAR2(120);

   cInsert_stmt		VARCHAR2(32000) := 'INSERT INTO ';
   cValue_stmt		VARCHAR2(32000) := 'VALUES (';

   c_Insert_cur		INTEGER ;
   dummy		INTEGER;
   d_date		DATE;
   n_number		NUMBER;
   c_count 		NUMBER;

BEGIN

   if p_Insert_cur = 0
   then
      xProgress := 'EXTUB-30-1020';
      p_Insert_cur := -911;
   end if;

   xProgress := 'EXTUB-30-1030';
if p_Insert_cur < 0
then

   xProgress := 'EXTUB-30-1040';
   cInsert_stmt := cInsert_stmt || ' ' || p_Interface_Table || '(';

   xProgress := 'EXTUB-30-1050';
   For i in 1..p_apps_tbl.count loop


       -- **************************************
       -- Only insert those data which
       -- are expected in the open interfaces.
       --
       -- The incoming flatfile contains many data
       -- but not all of them have a corresponding
       -- column in the open interfaces
       -- **************************************

       xProgress := 'EXTUB-30-1060';
       if p_apps_tbl(i).base_column_name is not null
       then
         -- build INSERT statement

         xProgress := 'EXTUB-30-1070';
         cInsert_stmt := cInsert_stmt || ' ' || p_apps_tbl(i).base_column_name || ',';

         xProgress := 'EXTUB-30-1080';
         cValue_stmt  := cValue_stmt || ':b' || i ||',';

       end if;

   end loop;

   xProgress := 'EXTUB-30-1090';
   cInsert_stmt := RTRIM (cInsert_stmt, ',') || ') ';

   xProgress := 'EXTUB-30-1100';
   cValue_stmt  := RTRIM (cValue_stmt, ',') || ')';

   xProgress := 'EXTUB-30-1110';
   cInsert_stmt := cInsert_stmt || cValue_stmt;

   xProgress := 'EXTUB-30-1110';
   p_Insert_cur := dbms_sql.open_cursor;

   xProgress := 'EXTUB-30-1120';
   if (debug_mode_on_prod)
   then
      declare
         stmt_1		varchar2(2000) := substrb(cInsert_stmt, 1, 2000);
         stmt_2		varchar2(2000) := substrb(cInsert_stmt, 2001, 2000);
         stmt_3		varchar2(2000) := substrb(cInsert_stmt, 4001, 2000);
         stmt_4		varchar2(2000) := substrb(cInsert_stmt, 6001, 2000);
         stmt_5		varchar2(2000) := substrb(cInsert_stmt, 8001, 2000);
      begin
         insert into ece_error (run_id, line_id, text) values( 78, ece_error_s.nextval, stmt_1);
         insert into ece_error (run_id, line_id, text) values( 78, ece_error_s.nextval, stmt_2);
         insert into ece_error (run_id, line_id, text) values( 78, ece_error_s.nextval, stmt_3);
         insert into ece_error (run_id, line_id, text) values( 78, ece_error_s.nextval, stmt_4);
         insert into ece_error (run_id, line_id, text) values( 78, ece_error_s.nextval, stmt_5);
      end;
--commit;
   end if;


   xProgress := 'EXTUB-30-1130';
   dbms_sql.parse(p_Insert_cur, cInsert_stmt, dbms_sql.native);
end if;

--if 1 =0
xProgress := 'EXTUB-30-1140';
if p_Insert_cur > 0
then

  begin
   xProgress := 'EXTUB-30-1150';
   for k in 1..p_apps_tbl.count
   loop

      xProgress := 'EXTUB-30-1160';
      g_error_count := k;

      xProgress := 'EXTUB-30-1170';
      if p_apps_tbl(k).base_column_name is not null
      then

         xProgress := 'EXTUB-30-1180';
         if 'DATE' = p_apps_tbl(k).data_type
         Then
            xProgress := 'EXTUB-30-1190';
            if p_apps_tbl(k).value is not NULL
            then
               xProgress := 'EXTUB-30-1200';
               d_date := to_date(p_apps_tbl(k).value,'YYYYMMDD HH24MISS');
            else
                xProgress := 'EXTUB-30-1210';
		d_date := NULL;
            end if;
            xProgress := 'EXTUB-30-1220';
            dbms_sql.bind_variable(p_Insert_cur,
				'b'||k,
				d_date);

            if (debug_mode_on_prod)
            then
               insert into ece_error (run_id, line_id, text) values
                             ( 88, ece_error_s.nextval, 'b' ||k|| ' = '||d_date);
            end if;
         elsif 'NUMBER' = p_apps_tbl(k).data_type
         then
            xProgress := 'EXTUB-30-1230';
            if p_apps_tbl(k).value is not NULL
            then
                xProgress := 'EXTUB-30-1240';
               n_number := to_number(p_apps_tbl(k).value);
            else
                xProgress := 'EXTUB-30-1250';
               n_number := NULL;
            end if;
            xProgress := 'EXTUB-30-1260';
            dbms_sql.bind_variable(p_Insert_cur,
				'b'||k,
				n_number);
            if (debug_mode_on_prod)
            then
               insert into ece_error (run_id, line_id, text) values
                    ( 88, ece_error_s.nextval, 'b'||k|| ' ='||n_number);
            end if;
         else
            xProgress := 'EXTUB-30-1270';
            dbms_sql.bind_variable(p_Insert_cur,
				'b'||k,
				substrb(p_apps_tbl(k).value,
					1,
				p_apps_tbl(k).data_length));
            if (debug_mode_on_prod)
            then
               insert into ece_error (run_id, line_id, text) values
                   ( 88, ece_error_s.nextval, 'b'||k|| ' ='||p_apps_tbl(k).value);
            end if;
         end if;
--commit;
      end if;

   end loop;

   xProgress := 'EXTUB-30-1280';
   dummy := dbms_sql.execute(p_Insert_cur);
   exception
     when others then
            EC_DEBUG.PL(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','ECE_EXTRACT_UTILS_PUB.insert_into_prod_interface');
            EC_DEBUG.PL(0,'EC','ECE_ERROR_CODE','ERROR_CODE',SQLCODE);
            EC_DEBUG.PL(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
            EC_DEBUG.PL(0,'EC','ECE_PLSQL_POS_NOT_FOUND','COLUMN_NAME', g_error_count);

         if g_error_count > 0 then
              EC_DEBUG.PL(0,'EC','ECE_PLSQL_VALUE','VALUE', p_apps_tbl(g_error_count).value);

         EC_DEBUG.PL(0,'EC','ECE_PLSQL_DATA_TYPE','DATA_TYPE', p_apps_tbl(g_error_count).data_type);


        EC_DEBUG.PL(0,'EC','ECE_PLSQL_COLUMN_NAME','COLUMN_NAME', p_apps_tbl(g_error_count).base_column_name);
       end if;
       raise;
   end;

end if;

END insert_into_prod_interface;

-- ******************************************************
--
-- Insert into product open interface tables
--
-- This procedure insert data into the product (non-EDI Gateway)
-- interface table
-- The caller pass in the p_source_tbl which contains
-- the data.
-- p_source_tbl also stores a pointer (foreign key) to
-- identify where should the data be placed in the
-- interface table
--


-- ECE_INTERFACE_COLUMNS serves as a data dictionary
-- to store which each data goes in the interface
-- table.
--
--
--  WARNING:
--	The first call to this function,
--	p_Insert_cur   M U S T   be zero (0).
-- ******************************************************
PROCEDURE insert_into_prod_interface_pvt(
            p_api_version_number IN       NUMBER,
            p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false,
            p_simulate           IN       VARCHAR2 := fnd_api.g_false,
            p_commit             IN       VARCHAR2 := fnd_api.g_false,
            p_validation_level   IN       NUMBER   := fnd_api.g_valid_level_full,
            x_return_status      OUT NOCOPY      VARCHAR2,
            x_msg_count          OUT NOCOPY     NUMBER,
            x_msg_data           OUT NOCOPY     VARCHAR2,
            p_interface_table    IN       VARCHAR2,
            p_insert_cur         IN OUT NOCOPY  INTEGER,
            p_apps_tbl           IN       ece_flatfile_pvt.Interface_tbl_type) IS

   l_api_name           CONSTANT VARCHAR2(30)      := 'insert_into_prod_interface_pvt';
   l_api_version_number CONSTANT NUMBER            :=  1.0;
   l_return_status               VARCHAR2(10);

   xProgress                     VARCHAR2(30);
   cOutput_path                  VARCHAR2(120);

   cInsert_stmt                  VARCHAR2(32000)   := 'INSERT INTO ';
   cValue_stmt                   VARCHAR2(32000)   := 'VALUES (';

   c_Insert_cur                  INTEGER ;
   dummy                         INTEGER;
   d_date                        DATE;
   n_number                      NUMBER;
   c_count                       NUMBER;

   BEGIN
   EC_DEBUG.PUSH('ece_extract_utils_pub.insert_into_prod_interface_pvt');
   if EC_DEBUG.G_debug_level >= 2 then
   EC_DEBUG.PL(3, 'p_api_version_number : ',p_api_version_number);
   EC_DEBUG.PL(3, 'p_init_msg_list: ',p_init_msg_list);
   EC_DEBUG.PL(3, 'p_simulate: ',p_simulate);
   EC_DEBUG.PL(3, 'p_commit: ',p_commit);
   EC_DEBUG.PL(3, 'p_validation_level: ',p_validation_level);
   EC_DEBUG.PL(3, 'p_interface_table: ',p_interface_table);
   EC_DEBUG.PL(3, 'p_insert_cur: ',p_insert_cur);
   end if;
      -- Standard Start of API savepoint
      SAVEPOINT insert_into_prod_interface_pvt;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call(
         l_api_version_number,
         p_api_version_number,
         l_api_name,
         g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      -- Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      if EC_DEBUG.G_debug_level >= 2 then
      EC_DEBUG.PL(3, 'x_return_status: ',x_return_status);
      end if;
      IF p_insert_cur = 0 THEN
         xProgress := 'EXTUB-30-1020';
         p_insert_cur := -911;
      END IF;

      xProgress := 'EXTUB-30-1030';
      IF p_insert_cur < 0 THEN
         xProgress := 'EXTUB-30-1040';
         cInsert_stmt := cInsert_stmt || ' ' || p_Interface_Table || '(';
if EC_DEBUG.G_debug_level >= 2 then
EC_DEBUG.PL(3, 'cInsert_stmt: ',cInsert_stmt);
end if;
         xProgress := 'EXTUB-30-1050';
         FOR i IN 1..p_apps_tbl.COUNT LOOP

            -- **************************************
            -- Only insert those data which
            -- are expected in the open interfaces.
            --
            -- The incoming flatfile contains many data
            -- but not all of them have a corresponding
            -- column in the open interfaces
            -- **************************************
            xProgress := 'EXTUB-30-1060';
            IF p_apps_tbl(i).base_column_name IS NOT NULL THEN
               -- build INSERT statement
               xProgress := 'EXTUB-30-1070';
               cInsert_stmt := cInsert_stmt || ' ' || p_apps_tbl(i).base_column_name || ',';
if EC_DEBUG.G_debug_level >= 2 then
EC_DEBUG.PL(3, 'cInsert_stmt: ',cInsert_stmt);
end if;
               xProgress := 'EXTUB-30-1080';
               cValue_stmt  := cValue_stmt || ':b' || i || ',';
if EC_DEBUG.G_debug_level >= 2 then
EC_DEBUG.PL(3, 'cValue_stmt: ',cValue_stmt);
end if;
            END IF;
         END LOOP;

         xProgress := 'EXTUB-30-1090';
         cInsert_stmt := RTRIM(cInsert_stmt,',') || ') ';
if EC_DEBUG.G_debug_level >= 2 then
EC_DEBUG.PL(3, 'cInsert_stmt: ',cInsert_stmt);
end if;
         xProgress := 'EXTUB-30-1100';
         cValue_stmt  := RTRIM(cValue_stmt,',') || ')';
if EC_DEBUG.G_debug_level >= 2 then
EC_DEBUG.PL(3, 'cValue_stmt: ',cValue_stmt);
end if;
         xProgress := 'EXTUB-30-1110';
         cInsert_stmt := cInsert_stmt || cValue_stmt;
if EC_DEBUG.G_debug_level >= 2 then
EC_DEBUG.PL(3, 'cInsert_stmt: ',cInsert_stmt);
end if;
         xProgress := 'EXTUB-30-1110';
         p_Insert_cur := dbms_sql.open_cursor;
if EC_DEBUG.G_debug_level >= 2 then
EC_DEBUG.PL(3, 'p_Insert_cur: ',p_Insert_cur);
end if;
         xProgress := 'EXTUB-30-1120';
         IF debug_mode_on_prod THEN
            DECLARE
               stmt_1      VARCHAR2(2000) := SUBSTR(cInsert_stmt,1,   2000);
               stmt_2      VARCHAR2(2000) := SUBSTR(cInsert_stmt,2001,2000);
               stmt_3      VARCHAR2(2000) := SUBSTR(cInsert_stmt,4001,2000);
               stmt_4      VARCHAR2(2000) := SUBSTR(cInsert_stmt,6001,2000);
               stmt_5      VARCHAR2(2000) := SUBSTR(cInsert_stmt,8001,2000);

            BEGIN
if EC_DEBUG.G_debug_level >= 2 then
               EC_DEBUG.PL(3, 'stmt_1: ',stmt_1);
               EC_DEBUG.PL(3, 'stmt_2: ',stmt_2);
               EC_DEBUG.PL(3, 'stmt_3: ',stmt_3);
               EC_DEBUG.PL(3, 'stmt_4: ',stmt_4);
               EC_DEBUG.PL(3, 'stmt_5: ',stmt_5);
end if;
               INSERT INTO ece_error(run_id,line_id,text) VALUES(78,ece_error_s.NEXTVAL,stmt_1);
               INSERT INTO ece_error(run_id,line_id,text) VALUES(78,ece_error_s.NEXTVAL,stmt_2);
               INSERT INTO ece_error(run_id,line_id,text) VALUES(78,ece_error_s.NEXTVAL,stmt_3);
               INSERT INTO ece_error(run_id,line_id,text) VALUES(78,ece_error_s.NEXTVAL,stmt_4);
               INSERT INTO ece_error(run_id,line_id,text) VALUES(78,ece_error_s.NEXTVAL,stmt_5);
            END;
            -- COMMIT;
         END IF;

         xProgress := 'EXTUB-30-1130';
         BEGIN
            xProgress := 'EXTUB-30-1131';
            dbms_sql.parse(p_Insert_cur,cInsert_stmt,dbms_sql.native);

         EXCEPTION
            WHEN OTHERS THEN
               ROLLBACK TO insert_into_prod_interface_pvt;
               ece_error_handling_pvt.print_parse_error(
                  dbms_sql.last_error_position,
                  cInsert_stmt);
               fnd_msg_pub.count_and_get(
                  p_count  => x_msg_count,
                  p_data   => x_msg_data);
               RAISE;
         END;
      END IF;

      xProgress := 'EXTUB-30-1140';
      IF p_Insert_cur > 0 THEN
         BEGIN
            xProgress := 'EXTUB-30-1150';
            FOR k IN 1..p_apps_tbl.COUNT LOOP
               xProgress := 'EXTUB-30-1160';
               g_error_count := k;
if EC_DEBUG.G_debug_level >= 2 then
EC_DEBUG.PL(3, 'g_error_count: ',g_error_count);
end if;
               xProgress := 'EXTUB-30-1170';
               IF p_apps_tbl(k).base_column_name IS NOT NULL THEN
                  xProgress := 'EXTUB-30-1180';
                  IF 'DATE' = p_apps_tbl(k).data_type THEN
                     xProgress := 'EXTUB-30-1190';
                     IF p_apps_tbl(k).value IS NOT NULL THEN
                        xProgress := 'EXTUB-30-1200';
                        d_date := TO_DATE(p_apps_tbl(k).value,'YYYYMMDD HH24MISS');
if EC_DEBUG.G_debug_level >= 2 then
EC_DEBUG.PL(3, 'd_date: ',d_date);
end if;
                     ELSE
                        xProgress := 'EXTUB-30-1210';
                        d_date := NULL;
                     END IF;

                     xProgress := 'EXTUB-30-1220';
                     dbms_sql.bind_variable(p_Insert_cur,'b'|| k,d_date);

                     IF debug_mode_on_prod THEN
                        INSERT INTO ece_error(run_id,line_id,text) VALUES(88,ece_error_s.NEXTVAL,'b' || k || ' = ' || d_date);
                     END IF;
                  ELSIF 'NUMBER' = p_apps_tbl(k).data_type THEN
                     xProgress := 'EXTUB-30-1230';
                     IF p_apps_tbl(k).value IS NOT NULL THEN
                        xProgress := 'EXTUB-30-1240';
                        n_number := TO_NUMBER(p_apps_tbl(k).value);
if EC_DEBUG.G_debug_level >= 2 then
EC_DEBUG.PL(3, 'n_number: ',n_number);
end if;
                     ELSE
                        xProgress := 'EXTUB-30-1250';
                        n_number := NULL;
                     END IF;

                     xProgress := 'EXTUB-30-1260';
                     dbms_sql.bind_variable(p_Insert_cur,'b' || k,n_number);

                     IF debug_mode_on_prod THEN
                        INSERT INTO ece_error(run_id,line_id,text) VALUES(88,ece_error_s.NEXTVAL,'b' || k || ' =' || n_number);
                     END IF;
                  ELSE
                     xProgress := 'EXTUB-30-1270';
                     dbms_sql.bind_variable(p_Insert_cur,'b' || k,SUBSTR(p_apps_tbl(k).value,1,p_apps_tbl(k).data_length));

                     IF debug_mode_on_prod THEN
                        INSERT INTO ece_error(run_id,line_id,text) VALUES(88,ece_error_s.NEXTVAL,'b' || k || ' =' || p_apps_tbl(k).value);
                     END IF;
                  END IF;

                  --commit;
               END IF;
            END LOOP;

            xProgress := 'EXTUB-30-1280';
            dummy := dbms_sql.execute(p_Insert_cur);

         EXCEPTION
            WHEN OTHERS THEN
              EC_DEBUG.PL(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','ECE_EXTRACT_UTILS_PUB.insert_into_prod_interface_pvt');
              EC_DEBUG.PL(0,'EC','ECE_ERROR_CODE','ERROR_CODE',SQLCODE);
              EC_DEBUG.PL(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);

              EC_DEBUG.PL(0,'EC','ECE_PLSQL_POS_NOT_FOUND','COLUMN_NAME', 'to_char(g_error_count)');

               IF g_error_count > 0 THEN
                  EC_DEBUG.PL(0,'EC','ECE_PLSQL_VALUE','VALUE', 'p_apps_tbl(g_error_count).value');

                  EC_DEBUG.PL(0,'EC','ECE_PLSQL_DATA_TYPE','DATA_TYPE', 'p_apps_tbl(g_error_count).data_type');


                  EC_DEBUG.PL(0,'EC','ECE_PLSQL_COLUMN_NAME','COLUMN_NAME', 'to_char(g_error_count).base_column_name');
               END IF;

               app_exception.raise_exception;
               RAISE;
         END;

      END IF;

      -- Both G_EXC_ERROR and G_EXC_UNEXPECTED_ERROR are handled in
      -- the API exception handler.
      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         -- Unexpected error, abort processing.
         RAISE fnd_api.g_exc_unexpected_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
         -- Error, abort processing
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Standard check of p_simulate and p_commit parameters
      IF fnd_api.to_boolean(p_simulate) THEN
         ROLLBACK TO insert_into_prod_interface_pvt;
      ELSIF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get(
         p_count  => x_msg_count,
         p_data   => x_msg_data);
   EC_DEBUG.POP('ece_extract_utils_pub.insert_into_prod_interface_pvt');

   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO insert_into_prod_interface_pvt;
         x_return_status := fnd_api.g_ret_sts_error;

         fnd_msg_pub.count_and_get(
            p_count  => x_msg_count,
            p_data   => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO insert_into_prod_interface_pvt;
         x_return_status := fnd_api.g_ret_sts_error;

         fnd_msg_pub.count_and_get(
            p_count  => x_msg_count,
            p_data   => x_msg_data);
      WHEN OTHERS THEN
         ece_error_handling_pvt.print_parse_error(
            dbms_sql.last_error_position,
            '');
         ROLLBACK TO insert_into_prod_interface_pvt;
         x_return_status := fnd_api.g_ret_sts_error;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(
               g_file_name,
               g_pkg_name,
               l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(
            p_count  => x_msg_count,
            p_data   => x_msg_data);

   END insert_into_prod_interface_pvt;

   PROCEDURE find_pos(
      p_source_tbl   IN ece_flatfile_pvt.Interface_tbl_type,
		p_in_text		IN VARCHAR2,
		p_pos			   IN OUT NOCOPY NUMBER) IS

      cIn_string	   VARCHAR2(1000)	:= UPPER(p_in_text);
      l_Row_count	   NUMBER 		   := p_source_tbl.COUNT;
      b_found		   BOOLEAN 	      := FALSE;
      pos_not_found  EXCEPTION;
      cOutput_path	VARCHAR2(120);

      BEGIN
         ec_debug.push('ECE_EXTRACT_UTILS_PUB.FIND_POS');
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pl(3,'p_in_text: ',p_in_text);
end if;
         FOR k IN 1..l_row_count LOOP
            IF UPPER(NVL(p_source_tbl(k).base_column_name,'NULL')) = cIn_string THEN
		         p_Pos := k;
		         b_found := TRUE;
                 if EC_DEBUG.G_debug_level >= 2 then
                 ec_debug.pl(3,'p_pos: ',p_pos);
                 end if;
		         EXIT;
	         END IF;
         END LOOP;

         IF NOT b_found THEN
            RAISE pos_not_found;
         END IF;

         ec_debug.pop('ECE_EXTRACT_UTILS_PUB.FIND_POS');

      EXCEPTION
         WHEN pos_not_found THEN
            ec_debug.pl(0,'EC','ECE_PLSQL_POS_NOT_FOUND','COLUMN_NAME',cIn_string);
            app_exception.raise_exception;

         WHEN OTHERS THEN
            ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','ECE_EXTRACT_UTILS_PUB.FIND_POS');
            ec_debug.pl(0,'EC','ECE_ERROR_CODE','ERROR_CODE',SQLCODE);
            ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
            app_exception.raise_exception;

      END find_pos;

FUNCTION POS_OF (pInterface_tbl 	IN ece_flatfile_pvt.Interface_tbl_type,
		 cCol_name		IN VARCHAR2)
RETURN NUMBER
IS
  l_Row_count	NUMBER 		:= pInterface_tbl.count;
  b_found	BOOLEAN 	:= FALSE;
  pos_not_found	EXCEPTION;
  cOutput_path	VARCHAR2(120);
BEGIN
   EC_DEBUG.PUSH('ece_extract_utils_pub.POS_OF');
if EC_DEBUG.G_debug_level >= 2 then
EC_DEBUG.PL(3, 'cCol_name: ',cCol_name);
end if;

      For k in 1..l_Row_count loop
         if UPPER(nvl(pInterface_tbl(k).base_column_name, 'NULL')) = UPPER(cCol_name) then
 		b_found := TRUE;
if EC_DEBUG.G_debug_level >= 2 then
   EC_DEBUG.PL(3, 'k: ',k);
end if;
   EC_DEBUG.POP('ece_extract_utils_pub.POS_OF');
		return(k);
                exit;
	 end if;
      end loop;

      if not b_found
      then
         raise pos_not_found;
      end if;

EXCEPTION
  WHEN pos_not_found THEN
     EC_DEBUG.PL(0,'EC','ECE_PLSQL_POS_NOT_FOUND','COLUMN_NAME', 'upper(cCol_name)');
      app_exception.raise_exception;
  WHEN OTHERS THEN
         EC_DEBUG.PL(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','ECE_EXTRACT_UTILS_PUB.POS_OF');
         EC_DEBUG.PL(0,'EC','ECE_ERROR_CODE','ERROR_CODE',SQLCODE);
         EC_DEBUG.PL(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
         app_exception.raise_exception;
END pos_of;

-- 2823215
PROCEDURE ext_get_value(
        l_plsql_tbl             IN       ece_flatfile_pvt.Interface_tbl_type,
        p_in_text               IN       VARCHAR2,
        p_Position              IN OUT NOCOPY   NUMBER,
        o_value                 OUT NOCOPY    varchar2)
IS
      cIn_string	   VARCHAR2(1000)  := UPPER(p_in_text);
      l_Row_count	   NUMBER 	   := l_plsql_tbl.COUNT;
      b_found		   BOOLEAN         := FALSE;
      pos_not_found  EXCEPTION;
      cOutput_path	VARCHAR2(120);

BEGIN
	 if EC_DEBUG.G_debug_level >= 2 then
           ec_debug.push('ECE_EXTRACT_UTILS_PUB.EXT_GET_VALUE');
	   ec_debug.pl(3,'p_in_text: ',p_in_text);
	 end if;
         FOR k IN 1..l_row_count LOOP
            IF UPPER(NVL(l_plsql_tbl(k).ext_column_name,'NULL')) = cIn_string THEN
		         p_Position := k;
		         o_value := l_plsql_tbl(k).value;
		         b_found := TRUE;
		         EXIT;
	         END IF;
         END LOOP;

         IF NOT b_found THEN
            RAISE pos_not_found;
         END IF;

	 if EC_DEBUG.G_debug_level >= 2 then
          ec_debug.pl(3,'p_position: ',p_position);
          ec_debug.pl(3,'o_value: ',o_value);
          ec_debug.pop('ECE_EXTRACT_UTILS_PUB.EXT_GET_VALUE');
         end if;

EXCEPTION
         WHEN pos_not_found THEN
            ec_debug.pl(0,'EC','ECE_PLSQL_POS_NOT_FOUND','COLUMN_NAME',cIn_string);
            app_exception.raise_exception;

         WHEN OTHERS THEN
            ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','ECE_EXTRACT_UTILS_PUB.EXT_GET_VALUE');
            ec_debug.pl(0,'EC','ECE_ERROR_CODE','ERROR_CODE',SQLCODE);
            ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
            app_exception.raise_exception;
END ext_get_value;

PROCEDURE ext_insert_value(
        l_plsql_tbl       IN OUT NOCOPY  ece_flatfile_pvt.Interface_tbl_type,
        p_position        IN     number,
        p_value           IN     varchar2)
IS
BEGIN
	 if EC_DEBUG.G_debug_level >= 2 then
           ec_debug.push('ECE_EXTRACT_UTILS_PUB.EXT_INSERT_VALUE');
           ec_debug.pl(3,'p_position: ',p_position);
           ec_debug.pl(3,'p_value: ',p_value);
	 end if;
         l_plsql_tbl(p_position).value := p_value;

	 if EC_DEBUG.G_debug_level >= 2 then
          ec_debug.pop('ECE_EXTRACT_UTILS_PUB.EXT_INSERT_VALUE');
         end if;

EXCEPTION
         WHEN OTHERS THEN
            ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','ECE_EXTRACT_UTILS_PUB.EXT_INSERT_VALUE');
            ec_debug.pl(0,'EC','ECE_ERROR_CODE','ERROR_CODE',SQLCODE);
            ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
            app_exception.raise_exception;
end ext_insert_value;

END ece_extract_utils_pub;


/
