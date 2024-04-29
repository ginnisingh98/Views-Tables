--------------------------------------------------------
--  DDL for Package Body ECE_FLATFILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECE_FLATFILE" AS
-- $Header: ECEGENB.pls 115.2 99/08/23 15:39:44 porting ship $

---	PROCEDURE select_clause.
---	Creation	Feb. 14, 1995
---
---	Procedure select_clause builds a Select clause and a From
---	clause and a Where clause at run time for the dynamic SQL call.

---	It looks at all the data columns for the EC transaction,
---	based on stored info, sort the columns in ascending order
---	of which should be written in the output file first, then
---	store them in a PL/SQL table.
---
---	It then builds a character string of the select clause
---	based on these stored columns and returns it.  This select
---	clause had already add the TO_CHAR function to convert
---	data to character type.

---	It also returns the number and position of columns stored,
---	and width of each column.  Furthmore, it returns the From
---	and Where clauses of the select statement.


PROCEDURE select_clause(
			cTransaction_Type	IN VARCHAR2,
			cCommunication_Method	IN VARCHAR2,
			cInterface_Table	IN VARCHAR2,
			cExt_Table		OUT VARCHAR2,
			cInt_Table		OUT CharTable,
			cInt_Column		OUT CharTable,
			nRecord_Num		OUT NumTable,
			nData_Pos		OUT NumTable,
			nCol_Width		OUT NumTable,
			iRow_count		OUT NUMBER,
			cSelect_string		OUT VARCHAR2,
			cFrom_string		OUT VARCHAR2,
			cWhere_string		OUT VARCHAR2)
IS
   cSelect_stmt		VARCHAR2(32000) := 'SELECT ';
   cFrom_stmt		VARCHAR2(32000) := ' FROM ';
   cWhere_stmt		VARCHAR2(32000) := ' WHERE ';

   cTO_CHAR		VARCHAR2(20) := 'TO_CHAR(';
   cDATE		VARCHAR2(40) := ',''YYYYMMDD HH24MISS'')';
   cWord1		VARCHAR2(20) := ' ';
   cWord2		VARCHAR2(40) := ' ';
   cExtension_Table	VARCHAR2(50);
   iColumn_count	INTEGER := 0;

   CURSOR c1 is
   Select min(eic.Table_Name) Table_Name,
	  eic.Column_Name Column_Name,
	  eic.Record_Number Record_Number,
	  eic.Position Position,
          eic.Width New_width,
	  atc.Data_Length Width,
	  atc.Data_Type Col_Type
     From all_tab_columns atc,
	  ece_interface_columns eic,
	  ece_interface_tables eit
    Where eit.Transaction_Type     = cTransaction_Type
      and eit.Interface_Table_Name = cInterface_Table
      and eit.interface_table_id   = eic.interface_table_id
      and eic.Column_Name          = atc.Column_Name
      and eic.Table_Name           = atc.Table_Name
      and eic.Position is not null
      and eic.Record_Number is not null
   Group by eic.Column_Name, eic.Record_Number, eic.Position, eic.Width, atc.Data_Length, atc.Data_Type
   Order By Record_Number, Position;
/*
   Select min(EIC.Table_Name) Table_Name, EIC.Column_Name Column_Name,
	  EIC.Record_Number Record_Number, EIC.Position Position,
          EIC.Width New_width,
	  ATC.Data_Length Width, ATC.Data_Type Col_Type
   From	  ALL_TAB_COLUMNS ATC, ECE_INTERFACE_COLUMNS EIC
   Where  EIC.Transaction_Type = cTransaction_Type
   and	  EIC.Interface_Table_Name = cInterface_Table
   and	  EIC.Column_Name = ATC.Column_Name
   and 	  EIC.Table_Name  = ATC.Table_Name
   Group by EIC.Column_Name, EIC.Record_Number, EIC.Position, ATC.Data_Length, ATC.Data_Type
   Order By Record_Number, Position;
*/
BEGIN

   For c1_rec in c1 loop

      -- **************************************
      -- store data in PL/SQL tables
      -- These tables will be returned to the main program
      -- **************************************

      iColumn_count := iColumn_count + 1;
      cInt_Table(iColumn_count)  := c1_rec.Table_Name;
      cInt_Column(iColumn_count) := c1_rec.Column_Name;
      nRecord_Num(iColumn_count) := c1_rec.Record_Number;
      nData_Pos(iColumn_count)   := c1_rec.Position;
      nCol_Width(iColumn_count)  := NVL(c1_rec.New_width, c1_rec.Width);

      -- **************************************
      -- apply appropriate data conversion
      -- **************************************

      if 'DATE' = c1_rec.Col_Type
      Then
         cWord1 := cTO_CHAR;
         cWord2 := cDATE;
         nCol_Width(iColumn_count) := 15;

      elsif 'NUMBER' = c1_rec.Col_Type
      Then
         cWord1 := cTO_CHAR;
         cWord2 := ')';
      else
         cWord1 := NULL;
         cWord2 := NULL;
      END if;

      -- build SELECT statement

      cSelect_stmt :=  cSelect_stmt || ' ' || cWord1 || c1_rec.Table_Name || '.' ||
 			c1_rec.Column_Name || cWord2 || ',';

   End Loop;

   Select EIT.Extension_Table_Name			-- select extension table name
   Into	  cExtension_Table
   From	  ECE_INTERFACE_TABLES EIT
   Where  EIT.Transaction_Type     = cTransaction_Type
   And	  EIT.Interface_Table_Name = cInterface_Table;

								-- build FROM, WHERE statements
   cFrom_stmt  := cFrom_stmt  || cInterface_Table || ', '|| cExtension_Table;
   cWhere_stmt := cWhere_stmt || cInterface_Table || '.' || 'TRANSACTION_RECORD_ID' ||
		' = ' || cExtension_table || '.'|| 'TRANSACTION_RECORD_ID(+)';

   cSelect_string := RTRIM (cSelect_stmt, ',');
   cFrom_string	  := cFrom_stmt;
   cWhere_string  := cWhere_stmt;
   iRow_count	  := iColumn_count;
   cExt_Table 	  := cExtension_Table;

END select_clause;




---	PROCEDURE write_to_ece_output
---	Creation	Feb. 15, 1995
---	This report procedure writes data to the ECE_OUTPUT table.
---	It put the appropriate record id at the beginning of each record
---	lines of data.  The entire record line of data is inserted into the
---	TEXT column in the table.
---
---	It expects a PL/SQL table of output data (in ASC order)!!!

PROCEDURE write_to_ece_output(
		cTransaction_Type	IN VARCHAR2,
		cCommunication_Method	IN VARCHAR2,
		cInterface_Table	IN VARCHAR2,
		cColumn			IN CharTable,
		cReport_data 		IN CharTable,
		nRecord_Num		IN NumTable,
		nData_pos		IN NumTable,
		nData_width		IN NumTable,
		iData_count		IN NUMBER,
		iOutput_width		IN INTEGER,
		iRun_id			IN INTEGER)
IS
	iLine_pos	INTEGER;
	iStart_num	INTEGER;
	cInsert_stmt    VARCHAR2(32000);

BEGIN

   iStart_num   := nRecord_Num(1);
   cInsert_stmt := ' ' || TO_CHAR(nRecord_Num(1));
   iLine_pos := LENGTH(cInsert_stmt);

   For i IN 1..iData_count Loop

      cInsert_stmt := cInsert_stmt || substrb(rpad(nvl(cReport_data(i),' '),nData_width(i),' '),1,nData_width(i));

      -- the following line is for testing/debug purpose
--      cInsert_stmt := cInsert_stmt || rpad(substrb(cColumn(i),1,nData_width(i)-2)||
--      substrb(TO_CHAR(nData_width(i)),1,2), TO_CHAR(nData_width(i)),' ');

      if i < iData_count
      then
         If nRecord_Num(i) <> nRecord_Num(i+1)
         then
            insert into ece_output( RUN_ID, LINE_ID, TEXT) values
               (iRun_id, ece_output_lines_s.nextval, substrb(cInsert_stmt,1,iOutput_width));
            cInsert_stmt := '*' || TO_CHAR(nRecord_Num(i+1));
         end if;
      else
         insert into ece_output( RUN_ID, LINE_ID, TEXT) values
               (iRun_id, ece_output_lines_s.nextval, substrb(cInsert_stmt,1,iOutput_width));

      end if;
   end Loop;

END write_to_ece_output;


PROCEDURE Find_pos(
		cColumn_Name		IN CharTable,
		nColumn_count		IN NUMBER,
		cIn_text		IN VARCHAR2,
		nPos			OUT NUMBER)
IS
	cIn_string	VARCHAR2(1000);
BEGIN
	cIn_string := UPPER(cIn_text);
	For k in 1..nColumn_count loop
		if UPPER(cColumn_Name(k)) = cIn_string then
			nPos := k;
			exit;
		end if;
	end loop;
END Find_pos;

END ECE_FLATFILE;

/
