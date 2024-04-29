--------------------------------------------------------
--  DDL for Package Body BOM_DIAGUNITTEST_TSDATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_DIAGUNITTEST_TSDATA" as
/* $Header: BOMDGTSB.pls 120.1 2007/12/26 09:57:22 vggarg noship $ */
PROCEDURE init is
BEGIN
null;
END init;

PROCEDURE cleanup IS
BEGIN
-- test writer could insert special cleanup code here
NULL;
END cleanup;

PROCEDURE runtest(inputs IN  JTF_DIAG_INPUTTBL,
                        report OUT NOCOPY JTF_DIAG_REPORT,
                        reportClob OUT NOCOPY CLOB) IS
 reportStr   LONG;           -- REPORT
 sqltxt    VARCHAR2(9999);  -- SQL select statement
 c_username  VARCHAR2(50);   -- accept input for username
 statusStr   VARCHAR2(50);   -- SUCCESS or FAILURE
 errStr      VARCHAR2(4000); -- error message
 fixInfo     VARCHAR2(4000); -- fix tip
 isFatal     VARCHAR2(50);   -- TRUE or FALSE
 num_rows   NUMBER;
 row_limit   NUMBER;
 l_item_id   NUMBER;
 l_org_id    NUMBER;
 l_count     NUMBER;
 l_table      VARCHAR2(30);
 ln_cursor    INTEGER;
 sql_stmt     VARCHAR2(4000);
 ln_rows_proc INTEGER;
 l_ret_status      BOOLEAN;
 l_status          VARCHAR2 (1);
 l_industry        VARCHAR2 (1);
 l_oracle_schema   VARCHAR2 (30);

CURSOR  c_varchar_cols_cur(l_table_name varchar2, l_owner VARCHAR2) is
SELECT  column_name
FROM    all_tab_columns
WHERE   table_name = l_table_name
AND	owner = l_owner
AND     data_type in ( 'VARCHAR2' , 'CHAR');

CURSOR c_item_valid (cp_n_item_id IN NUMBER, cp_n_org_id IN NUMBER) IS
SELECT count(*)
FROM   mtl_system_items_b
WHERE  inventory_item_id = cp_n_item_id
AND    organization_id   = nvl(cp_n_org_id,organization_id);

BEGIN
JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;

 /*Initializing local vars */
 row_limit :=1000; /* Set Row Limit to 1000 (i.e.) Max Number of records to be fetched by each sql*/
 ln_rows_proc :=0;

-- accept input
l_org_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('OrgId',inputs);
l_item_id :=JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('ItemId',inputs);

   If l_item_id is NULL then
	JTF_DIAGNOSTIC_COREAPI.errorprint('Input Item Id is mandatory.');
	JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(' Please provide a valid value for the Item Id.');
	statusStr := 'FAILURE';
	isFatal := 'TRUE';
	fixInfo := ' Please review the error message below and take corrective action. ';
	errStr  := ' Invalid value for input field ItemId. It is a mandatory input.';

	report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
	reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
	Return;
   End If;

   If l_org_id is NULL then
	JTF_DIAGNOSTIC_COREAPI.errorprint('Input Organization Id is mandatory.');
	JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(' Please provide a valid value for the Organization Id.');
	statusStr := 'FAILURE';
	isFatal := 'TRUE';
	fixInfo := ' Please review the error message below and take corrective action. ';
	errStr  := ' Invalid value for input field Organization Id. It is a mandatory input.';

	report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
	reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
	Return;
   End If;

  If (l_item_id is NOT NULL) AND (l_org_id is NOT NULL) Then
	OPEN  c_item_valid (l_item_id, l_org_id);
	FETCH c_item_valid INTO l_count;
	CLOSE c_item_valid;

	IF (l_count IS NULL) OR (l_count = 0)  THEN
	    JTF_DIAGNOSTIC_COREAPI.errorprint('Invalid Item and Organization Combination');
            JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please enter right combination of Item and Organization ');
            statusStr := 'FAILURE';
            errStr := 'Invalid Item and Organization Combination';
            fixInfo := ' Please review the error message below and take corrective action. ';
            isFatal := 'TRUE';
            report  := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
            reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
            RETURN;
	END IF;
   End If;


/* Start of Scripts to check for trailing spaces in Item Tables */

JTF_DIAGNOSTIC_COREAPI.Line_Out('
<BR/> This script will report the records in Items,Bills,
<BR/> Routings related tables that contain trailing spaces
<BR/> in any of their column values.
<BR/><BR/><u>IMPACT:</u>
<BR/> If a column contains trailing spaces then,
<BR/> FRM-40654 error may occur while trying to
<BR/> update those records from the Form.
<BR/><BR/><u>ACTION:</u>
<BR/> In this script''s output for each table,
<BR/> ''Column Name'' stands for the name of the offending column
<BR/> ''Column Value'' stands for the value of the offending column.
<BR/> The rest of the columns are useful in uniquely identifying
<BR/> the specific record.
<BR/>
<BR/> If records are fetched from any of the tables,
<BR/> then the record with the offending column
<BR/> needs to be updated so that the columns with
<BR/> the trailing spaces are trimmed for this specific record.
<BR/>
<BR/>(E.g.) If for mtl_system_items_b table,
<BR/> a record is fetched with
<BR/> Inventory Item Id = 1234
<BR/> Organization id   = 100
<BR/> Column Name	  = Attribute1
<BR/> Column Value	  = ''column with trailing space  ''
<BR/>
<BR/> Use file "afchrchk.sql" present in $FND_TOP/sql to trim the trailing spaces.
<BR/> This script will ask for the following input.
<BR/> 1. Table name: Enter the table name fetched above (e.g.)mtl_system_items_b
<BR/> 2. Column name: Enter the column name fetched above (e.g.) Attribute1
<BR/> 3. Check for newline characters (Y/N)?: Enter as N
<BR/> 4. Automatically fix all errors found (Y/N)? Enter as Y
<BR/>
<BR/><I><u>Important:</u> Try the above action plan on a TEST INSTANCE first.</I>
<BR/>');

/* Note 1: It was observed that for all the tables used in this script, on an average the number of varchar2
columns were about 25. So for each column, the number of probelmatic records that get logged have been
restricted to 40. So that 40*25 =1000 (row_limt). In future, a more refined approach can be coded if neccessary.

Note 2: The global temporary table contains four specific columns namely
Inventory_item_id, organization_id, Description,Long_Description for storing the item_id,org_id,desc,long_desc
of an item respectively. The rest of the problematic varchar2 columns are stored in Char_col2.
Always, Char_col1 stores the name of the column with trailing spaces and
char_col2 will store its value.
*/

/* Start of Scripts for Item tables */
/* Get the application installation info. References to Data Dictionary Objects without schema name
included in WHERE predicate are not allowed (GSCC Check: file.sql.47). For accessing all_tab_columns
in cursor c_varchar_cols_cur we need to pass the schema name*/

l_ret_status :=      fnd_installation.get_app_info ('INV'
                                   , l_status
                                   , l_industry
                                   , l_oracle_schema
                                    );

/*JTF_DIAGNOSTIC_COREAPI.Line_Out(' l_oracle_schema: '||l_oracle_schema);*/

/* Script to verify records in mtl_system_items_b table */
Begin
	 delete from bom_diag_temp_tab; -- Clear the temporary tables
For l_varchar_col_rec in c_varchar_cols_cur('MTL_SYSTEM_ITEMS_B',l_oracle_schema) Loop
--JTF_DIAGNOSTIC_COREAPI.Line_Out('Column: '||l_varchar_col_rec.column_name);

	 sql_stmt := '';
	 sql_stmt :=' Insert into bom_diag_temp_tab (Inventory_item_id, organization_id,	'||
 		 	'     char_col1,char_col2)						'||
	 		'  	    SELECT  msib.inventory_item_id 				'||
	 		' 		   ,msib.organization_id				'||
			'		   ,'''||l_varchar_col_rec.column_name||'''	'||
			'		   ,msib.'||l_varchar_col_rec.column_name||'		'||
			'	    FROM   MTL_SYSTEM_ITEMS_B	msib				'||
			'	    WHERE  msib.organization_id  = '||l_org_id||'		'||
			'	    AND    msib.inventory_item_id ='||l_item_id||'		'||
			'	    AND    msib.'||l_varchar_col_rec.column_name||' LIKE ''% ''	'||
			'	    AND	   rownum < '||(row_limit/25);

      	ln_cursor := dbms_sql.open_cursor;
        DBMS_SQL.PARSE(ln_cursor,sql_stmt,dbms_sql.native);
        ln_rows_proc := DBMS_SQL.EXECUTE(ln_cursor);
        DBMS_SQL.CLOSE_CURSOR(ln_cursor);

End Loop;

	sqltxt:='	Select     Inventory_Item_Id 	  "Inventory Item Id",		     '||
		'	 	   Organization_id	  "Organization id",		     '||
		'		   Char_Col1		  "Column Name",		     '||
		'	 	   Char_Col2		  "Column Value"		     '||
		'	From	   bom_diag_temp_tab	  where 1=1			     ';

	sqltxt := sqltxt || ' and rownum< '||row_limit;
	sqltxt :=sqltxt||' order by inventory_item_id, organization_id,char_col1';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Columns containing Trailing Spaces in mtl_system_items_b table ');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;
	statusStr := 'SUCCESS';
	isFatal := 'FALSE';

End;
/* End of mtl_system_items_b script */

/* Script to verify records in mtl_system_items_tl table */
Begin
	 delete from bom_diag_temp_tab; -- Clear the temporary tables
For l_varchar_col_rec in c_varchar_cols_cur('MTL_SYSTEM_ITEMS_TL',l_oracle_schema) Loop
--JTF_DIAGNOSTIC_COREAPI.Line_Out('Column: '||l_varchar_col_rec.column_name);

	 sql_stmt := '';

/*	If (upper(l_varchar_col_rec.column_name) NOT IN ('DESCRIPTION','LONG_DESCRIPTION')) Then
	-- JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> not description, long description');
	 sql_stmt :=' Insert into bom_diag_temp_tab (Inventory_item_id, organization_id,	'||
 		 	'     char_col3,char_col1,char_col2)					'||
	 		'  	    SELECT  msitl.inventory_item_id	 			'||
	 		' 		   ,msitl.organization_id				'||
			'		   ,msitl.language					'||
			'		   ,'''||l_varchar_col_rec.column_name||'''		'||
			'		   ,msitl.'||l_varchar_col_rec.column_name||'		'||
			'	    FROM   MTL_SYSTEM_ITEMS_TL	msitl				'||
			'	    WHERE  msitl.organization_id  = '||l_org_id||'		'||
			'	    AND    msitl.inventory_item_id ='||l_item_id||'		'||
			'	    AND    msitl.'||l_varchar_col_rec.column_name||' LIKE ''% '' '||
			'	    AND	   rownum < '||(row_limit/25);
*/
If (upper(l_varchar_col_rec.column_name) IN ('DESCRIPTION','LONG_DESCRIPTION')) Then
	If (upper(l_varchar_col_rec.column_name)='DESCRIPTION') Then
	/*JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> description '); */
	 sql_stmt :=' Insert into bom_diag_temp_tab (Inventory_item_id, organization_id,	'||
 		 	'     char_col3,char_col1,description)					'||
	 		'  	    SELECT  msitl.inventory_item_id	 			'||
	 		' 		   ,msitl.organization_id				'||
			'		   ,msitl.language					'||
			'		   ,''DESCRIPTION''					'||
			'		   ,msitl.'||l_varchar_col_rec.column_name||'		'||
			'	    FROM   MTL_SYSTEM_ITEMS_TL	msitl				'||
			'	    WHERE  msitl.organization_id  = '||l_org_id||'		'||
			'	    AND    msitl.inventory_item_id ='||l_item_id||'		'||
			'	    AND    msitl.'||l_varchar_col_rec.column_name||' LIKE ''% '' '||
			'	    AND	   rownum < '||(row_limit/25);

	ElsIf (upper(l_varchar_col_rec.column_name)='LONG_DESCRIPTION') Then
	/*JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> long description');*/
	 sql_stmt :=' Insert into bom_diag_temp_tab (Inventory_item_id, organization_id,	'||
 		 	'     char_col3,char_col1,Long_Description)				'||
	 		'  	    SELECT  msitl.inventory_item_id	 			'||
	 		' 		   ,msitl.organization_id				'||
			'		   ,msitl.language					'||
			'		   ,''LONG_DESCRIPTION''				'||
			'		   ,msitl.'||l_varchar_col_rec.column_name||'		'||
			'	    FROM   MTL_SYSTEM_ITEMS_TL	msitl				'||
			'	    WHERE  msitl.organization_id  = '||l_org_id||'		'||
			'	    AND    msitl.inventory_item_id ='||l_item_id||'		'||
			'	    AND    msitl.'||l_varchar_col_rec.column_name||' LIKE ''% '' '||
			'	    AND	   rownum < '||(row_limit/25);

	End If;

      	ln_cursor := dbms_sql.open_cursor;
        DBMS_SQL.PARSE(ln_cursor,sql_stmt,dbms_sql.native);
        ln_rows_proc := DBMS_SQL.EXECUTE(ln_cursor);
        DBMS_SQL.CLOSE_CURSOR(ln_cursor);

End If;		/* l_varchar_col_rec.column_name) IN ('DESCRIPTION','LONG_DESCRIPTION') */
End Loop;

	sqltxt:='	Select     Inventory_Item_Id 	  "Inventory Item Id",		     '||
		'	 	   Organization_id	  "Organization id",		     '||
		'		   Char_col3		  "Language",			     '||
		'		   Char_Col1		  "Column Name",		     '||
		'		   Description		  "Description",		     '||
		'		   Long_Description	  "Long Description"		     '||
		'	From	   bom_diag_temp_tab	  where 1=1			     ';

	sqltxt := sqltxt || ' and rownum< '||row_limit;
	sqltxt :=sqltxt||' order by inventory_item_id, organization_id,char_col3,char_col1';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Columns containing Trailing Spaces in mtl_system_items_tl table ');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;
	statusStr := 'SUCCESS';
	isFatal := 'FALSE';

End;
/* End of mtl_system_items_tl script */

/* Script to verify records in mtl_item_revisions_b table */
Begin
	 delete from bom_diag_temp_tab; -- Clear the temporary tables
For l_varchar_col_rec in c_varchar_cols_cur('MTL_ITEM_REVISIONS_B',l_oracle_schema) Loop
--JTF_DIAGNOSTIC_COREAPI.Line_Out('Column: '||l_varchar_col_rec.column_name);

	 sql_stmt := '';
	 sql_stmt :=' Insert into bom_diag_temp_tab (Inventory_item_id, organization_id,	'||
 		 	'     char_col3,num_col1,char_col1,char_col2)				'||
	 		'  	    SELECT  mirb.inventory_item_id	 			'||
	 		' 		   ,mirb.organization_id				'||
			'		   ,mirb.revision					'||
			'		   ,mirb.revision_id					'||
			'		   ,'''||l_varchar_col_rec.column_name||'''		'||
			'		   ,mirb.'||l_varchar_col_rec.column_name||'		'||
			'	    FROM   MTL_ITEM_REVISIONS_B	mirb				'||
			'	    WHERE  mirb.organization_id  = '||l_org_id||'		'||
			'	    AND    mirb.inventory_item_id ='||l_item_id||'		'||
			'	    AND    mirb.'||l_varchar_col_rec.column_name||' LIKE ''% ''	'||
			'	    AND	   rownum < '||(row_limit/25);

      	ln_cursor := dbms_sql.open_cursor;
        DBMS_SQL.PARSE(ln_cursor,sql_stmt,dbms_sql.native);
        ln_rows_proc := DBMS_SQL.EXECUTE(ln_cursor);
        DBMS_SQL.CLOSE_CURSOR(ln_cursor);

End Loop;

	sqltxt:='	Select     Inventory_Item_Id 	  "Inventory Item Id",		     '||
		'	 	   Organization_id	  "Organization id",		     '||
		'		   Char_Col3		  "Revision",			     '||
		'		   Num_Col1		  "Revision Id",		     '||
		'		   Char_Col1		  "Column Name",		     '||
		'	 	   Char_Col2		  "Column Value"		     '||
		'	From	   bom_diag_temp_tab	  where 1=1			     ';

	sqltxt := sqltxt || ' and rownum< '||row_limit;
	sqltxt :=sqltxt||' order by inventory_item_id, organization_id, char_col3,char_col1';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Columns containing Trailing Spaces in mtl_item_revisions_b table ');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;
	statusStr := 'SUCCESS';
	isFatal := 'FALSE';

End;
/* End of mtl_item_revisions_b script */

/* Script to verify records in mtl_item_revisions_tl table */
Begin
	 delete from bom_diag_temp_tab; -- Clear the temporary tables
For l_varchar_col_rec in c_varchar_cols_cur('MTL_ITEM_REVISIONS_TL',l_oracle_schema) Loop
--JTF_DIAGNOSTIC_COREAPI.Line_Out('Column: '||l_varchar_col_rec.column_name);

	 sql_stmt := '';
	 sql_stmt :=' Insert into bom_diag_temp_tab (Inventory_item_id, organization_id,	'||
 		 	'     num_col1,char_col3,char_col1,char_col2)				'||
	 		'  	    SELECT  mirtl.inventory_item_id	 			'||
	 		' 		   ,mirtl.organization_id				'||
			'		   ,mirtl.revision_id					'||
			'		   ,mirtl.language					'||
			'		   ,'''||l_varchar_col_rec.column_name||'''		'||
			'		   ,mirtl.'||l_varchar_col_rec.column_name||'		'||
			'	    FROM   MTL_ITEM_REVISIONS_TL	mirtl			'||
			'	    WHERE  mirtl.organization_id  = '||l_org_id||'		'||
			'	    AND    mirtl.inventory_item_id ='||l_item_id||'		'||
			'	    AND    mirtl.'||l_varchar_col_rec.column_name||' LIKE ''% '' '||
			'	    AND	   rownum < '||(row_limit/25);

      	ln_cursor := dbms_sql.open_cursor;
        DBMS_SQL.PARSE(ln_cursor,sql_stmt,dbms_sql.native);
        ln_rows_proc := DBMS_SQL.EXECUTE(ln_cursor);
        DBMS_SQL.CLOSE_CURSOR(ln_cursor);

End Loop;

	sqltxt:='	Select     Inventory_Item_Id 	  "Inventory Item Id",		     '||
		'	 	   Organization_id	  "Organization id",		     '||
		'		   Num_Col1		  "Revision Id",		     '||
		'		   Char_Col3		  "Language",			     '||
		'		   Char_Col1		  "Column Name",		     '||
		'	 	   Char_Col2		  "Column Value"		     '||
		'	From	   bom_diag_temp_tab	  where 1=1			     ';

	sqltxt := sqltxt || ' and rownum< '||row_limit;
	sqltxt :=sqltxt||' order by inventory_item_id, organization_id, num_col1,char_col3,char_col1';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Columns containing Trailing Spaces in mtl_item_revisions_tl table ');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;
	statusStr := 'SUCCESS';
	isFatal := 'FALSE';

End;
/* End of mtl_item_revisions_tl script */

/* Script to verify records in mtl_descr_element_values table */
Begin
	 delete from bom_diag_temp_tab; -- Clear the temporary tables
For l_varchar_col_rec in c_varchar_cols_cur('MTL_DESCR_ELEMENT_VALUES',l_oracle_schema) Loop
--JTF_DIAGNOSTIC_COREAPI.Line_Out('Column: '||l_varchar_col_rec.column_name);

	 sql_stmt := '';
	 sql_stmt :=' Insert into bom_diag_temp_tab (Inventory_item_id,				'||
 		 	'     char_col3,num_col1,char_col1,char_col2)				'||
	 		'  	    SELECT  mdev.inventory_item_id	 			'||
			'		   ,mdev.element_name					'||
			'		   ,mdev.element_sequence				'||
			'		   ,'''||l_varchar_col_rec.column_name||'''		'||
			'		   ,mdev.'||l_varchar_col_rec.column_name||'		'||
			'	    FROM   MTL_DESCR_ELEMENT_VALUES mdev			'||
			'	    WHERE  mdev.inventory_item_id ='||l_item_id||'		'||
			'	    AND    mdev.'||l_varchar_col_rec.column_name||' LIKE ''% ''	'||
			'	    AND	   rownum < '||(row_limit/25);

      	ln_cursor := dbms_sql.open_cursor;
        DBMS_SQL.PARSE(ln_cursor,sql_stmt,dbms_sql.native);
        ln_rows_proc := DBMS_SQL.EXECUTE(ln_cursor);
        DBMS_SQL.CLOSE_CURSOR(ln_cursor);

End Loop;

	sqltxt:='	Select     Inventory_Item_Id 	  "Inventory Item Id",		     '||
		'		   Char_Col3		  "Element Name",		     '||
		'		   Num_Col1		  "Element Sequence",		     '||
		'		   Char_Col1		  "Column Name",		     '||
		'	 	   Char_Col2		  "Column Value"		     '||
		'	From	   bom_diag_temp_tab	  where 1=1			     ';

	sqltxt := sqltxt || ' and rownum< '||row_limit;
	sqltxt :=sqltxt||' order by inventory_item_id, organization_id, char_col3,char_col1';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Columns containing Trailing Spaces in mtl_descr_element_values table ');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;
	statusStr := 'SUCCESS';
	isFatal := 'FALSE';
End;
/* End of mtl_descr_element_values script */

/* Script to verify records in mtl_pending_item_status table */
Begin
	 delete from bom_diag_temp_tab; -- Clear the temporary tables
For l_varchar_col_rec in c_varchar_cols_cur('MTL_PENDING_ITEM_STATUS',l_oracle_schema) Loop
--JTF_DIAGNOSTIC_COREAPI.Line_Out('Column: '||l_varchar_col_rec.column_name);

	 sql_stmt := '';
	 sql_stmt :=' Insert into bom_diag_temp_tab (Inventory_item_id,Organization_id,		'||
 		 	'     char_col3,Date_col1,char_col1,char_col2)				'||
	 		'  	    SELECT  mpis.inventory_item_id	 			'||
			'		   ,mpis.Organization_id				'||
			'		   ,mpis.STATUS_CODE					'||
			'		   ,mpis.EFFECTIVE_DATE					'||
			'		   ,'''||l_varchar_col_rec.column_name||'''		'||
			'		   ,mpis.'||l_varchar_col_rec.column_name||'		'||
			'	    FROM   MTL_PENDING_ITEM_STATUS mpis				'||
			'	    WHERE  mpis.inventory_item_id ='||l_item_id||'		'||
			'	    AND    mpis.organization_id  = '||l_org_id||'		'||
			'	    AND    mpis.'||l_varchar_col_rec.column_name||' LIKE ''% ''	'||
			'	    AND	   rownum < '||(row_limit/25);

      	ln_cursor := dbms_sql.open_cursor;
        DBMS_SQL.PARSE(ln_cursor,sql_stmt,dbms_sql.native);
        ln_rows_proc := DBMS_SQL.EXECUTE(ln_cursor);
        DBMS_SQL.CLOSE_CURSOR(ln_cursor);

End Loop;

	sqltxt:='	Select     Inventory_Item_Id 	  "Inventory Item Id",		     '||
		'	 	   Organization_id	  "Organization id",		     '||
		'		   Char_Col3		  "Status Code",		     '||
		'		   to_char(Date_Col1,''DD-MON-YYYY HH24:MI:SS'') "Effectivity Date", '||
		'		   Char_Col1		  "Column Name",		     '||
		'	 	   Char_Col2		  "Column Value"		     '||
		'	From	   bom_diag_temp_tab	  where 1=1			     ';

	sqltxt := sqltxt || ' and rownum< '||row_limit;
	sqltxt :=sqltxt||' order by inventory_item_id, organization_id, char_col3,Date_col1,char_col1';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Columns containing Trailing Spaces in mtl_pending_item_status table ');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;
	statusStr := 'SUCCESS';
	isFatal := 'FALSE';
End;
/* End of mtl_pending_item_status script */


/* Script to verify records in mtl_cross_references_b table */
Begin
	 delete from bom_diag_temp_tab; -- Clear the temporary tables
For l_varchar_col_rec in c_varchar_cols_cur('MTL_CROSS_REFERENCES_B',l_oracle_schema) Loop
--JTF_DIAGNOSTIC_COREAPI.Line_Out('Column: '||l_varchar_col_rec.column_name);

	 sql_stmt := '';
	 sql_stmt :=' Insert into bom_diag_temp_tab (Inventory_item_id,Organization_id,		'||
 		 	'     char_col3,char_col4,char_col1,char_col2)				'||
	 		'  	    SELECT  mcr.inventory_item_id	 			'||
			'		   ,mcr.Organization_id					'||
			'		   ,MCR.CROSS_REFERENCE_TYPE				'||
			'		   ,MCR.CROSS_REFERENCE					'||
			'		   ,'''||l_varchar_col_rec.column_name||'''		'||
			'		   ,mcr.'||l_varchar_col_rec.column_name||'		'||
			'	    FROM   MTL_CROSS_REFERENCES_B mcr				'||
			'	    WHERE  mcr.inventory_item_id ='||l_item_id||'		'||
			'	    AND   (  ( mcr.organization_id =  '||l_org_id||' and  org_independent_flag=''N'') '||
			'			or ( mcr.organization_id is null and org_independent_flag=''Y'') )    '||
			'	    AND    mcr.'||l_varchar_col_rec.column_name||' LIKE ''% ''	'||
			'	    AND	   rownum < '||(row_limit/25);

      	ln_cursor := dbms_sql.open_cursor;
        DBMS_SQL.PARSE(ln_cursor,sql_stmt,dbms_sql.native);
        ln_rows_proc := DBMS_SQL.EXECUTE(ln_cursor);
        DBMS_SQL.CLOSE_CURSOR(ln_cursor);

End Loop;

	sqltxt:='	Select     Inventory_Item_Id 	  "Inventory Item Id",		     '||
		'	 	   Organization_id	  "Organization id",		     '||
		'		   Char_Col3		  "Cross Reference Type",	     '||
		'		   Char_Col4		  "Cross Reference",		     '||
		'		   Char_Col1		  "Column Name",		     '||
		'	 	   Char_Col2		  "Column Value"		     '||
		'	From	   bom_diag_temp_tab	  where 1=1			     ';

	sqltxt := sqltxt || ' and rownum< '||row_limit;
	sqltxt :=sqltxt||' order by inventory_item_id, organization_id, char_col3,char_col4,char_col1';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Columns containing Trailing Spaces in mtl_cross_references_b table ');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;
	statusStr := 'SUCCESS';
	isFatal := 'FALSE';
End;
/* End of mtl_cross_references_b script */

/* Script to verify records in mtl_cross_references_tl table */
Begin
	 delete from bom_diag_temp_tab; -- Clear the temporary tables
For l_varchar_col_rec in c_varchar_cols_cur('MTL_CROSS_REFERENCES_TL',l_oracle_schema) Loop
--JTF_DIAGNOSTIC_COREAPI.Line_Out('Column: '||l_varchar_col_rec.column_name);

	 sql_stmt := '';
	 sql_stmt :=' Insert into bom_diag_temp_tab (num_col1,		'||
 		 	'     char_col4,char_col1,char_col2)				'||
	 		'  	    SELECT  mcrt.cross_reference_id	 			'||
			'		   ,mcrt.language					'||
			'		   ,'''||l_varchar_col_rec.column_name||'''		'||
			'		   ,mcrt.'||l_varchar_col_rec.column_name||'		'||
			'	    FROM   MTL_CROSS_REFERENCES_B mcrb, MTL_CROSS_REFERENCES_TL mcrt				'||
			'	    WHERE  mcrb.inventory_item_id ='||l_item_id||'		'||
			'	    AND   (  ( mcrb.organization_id =  '||l_org_id||' and  org_independent_flag=''N'') '||
			'			or ( mcrb.organization_id is null and org_independent_flag=''Y'') )    '||
			'	    AND    mcrb.cross_reference_id = mcrt.cross_reference_id	'||
			'	    AND    mcrt.'||l_varchar_col_rec.column_name||' LIKE ''% ''	'||
			'	    AND	   rownum < '||(row_limit/25);

      	ln_cursor := dbms_sql.open_cursor;
        DBMS_SQL.PARSE(ln_cursor,sql_stmt,dbms_sql.native);
        ln_rows_proc := DBMS_SQL.EXECUTE(ln_cursor);
        DBMS_SQL.CLOSE_CURSOR(ln_cursor);

End Loop;

	sqltxt:='	Select  num_col1		  "Cross Reference Id",		     '||
		'		   Char_Col4		  "Language",		     '||
		'		   Char_Col1		  "Column Name",		     '||
		'	 	   Char_Col2		  "Column Value"		     '||
		'	From	   bom_diag_temp_tab	  where 1=1			     ';

	sqltxt := sqltxt || ' and rownum< '||row_limit;
	sqltxt :=sqltxt||' order by num_col1,char_col4,char_col1';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Columns containing Trailing Spaces in mtl_cross_references_tl table ');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;
	statusStr := 'SUCCESS';
	isFatal := 'FALSE';
End;
/* End of mtl_cross_references_tl script */

/* Script to verify records in mtl_customer_item_xrefs table */
Begin
	 delete from bom_diag_temp_tab; -- Clear the temporary tables
For l_varchar_col_rec in c_varchar_cols_cur('MTL_CUSTOMER_ITEM_XREFS',l_oracle_schema) Loop
--JTF_DIAGNOSTIC_COREAPI.Line_Out('Column: '||l_varchar_col_rec.column_name);

	 sql_stmt := '';
	 sql_stmt :=' Insert into bom_diag_temp_tab (Inventory_item_id,Organization_id,		'||
 		 	'     Num_col1,char_col1,char_col2)					'||
	 		'  	    SELECT  mcix.inventory_item_id	 			'||
			'		   ,mcix.Master_Organization_id				'||
			'		   ,MCIX.CUSTOMER_ITEM_ID				'||
			'		   ,'''||l_varchar_col_rec.column_name||'''		'||
			'		   ,mcix.'||l_varchar_col_rec.column_name||'		'||
			'	    FROM   MTL_CUSTOMER_ITEM_XREFS mcix				'||
			'	    WHERE  mcix.inventory_item_id ='||l_item_id||'		'||
			'	    AND    mcix.master_organization_id =			'||
			'			(select master_organization_id from mtl_parameters  '||
			'			 where organization_id= '||l_org_id||' )	'||
			'	    AND    mcix.'||l_varchar_col_rec.column_name||' LIKE ''% ''	'||
			'	    AND	   rownum < '||(row_limit/25);

      	ln_cursor := dbms_sql.open_cursor;
        DBMS_SQL.PARSE(ln_cursor,sql_stmt,dbms_sql.native);
        ln_rows_proc := DBMS_SQL.EXECUTE(ln_cursor);
        DBMS_SQL.CLOSE_CURSOR(ln_cursor);

End Loop;

	sqltxt:='	Select     Inventory_Item_Id 	  "Inventory Item Id",		     '||
		'	 	   Organization_id	  "Master Organization id",	     '||
		'		   Num_Col1		  "Customer Item Id",		     '||
		'		   Char_Col1		  "Column Name",		     '||
		'	 	   Char_Col2		  "Column Value"		     '||
		'	From	   bom_diag_temp_tab	  where 1=1			     ';

	sqltxt := sqltxt || ' and rownum< '||row_limit;
	sqltxt :=sqltxt||' order by inventory_item_id, organization_id, Num_col1,char_col1';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Columns containing Trailing Spaces in mtl_customer_item_xrefs table ');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;
	statusStr := 'SUCCESS';
	isFatal := 'FALSE';
End;
/* End of mtl_customer_item_xrefs script */

/* Script to verify records in mtl_mfg_part_numbers table */
Begin
	 delete from bom_diag_temp_tab; -- Clear the temporary tables
For l_varchar_col_rec in c_varchar_cols_cur('MTL_MFG_PART_NUMBERS',l_oracle_schema) Loop
--JTF_DIAGNOSTIC_COREAPI.Line_Out('Column: '||l_varchar_col_rec.column_name);

	 sql_stmt := '';
	 sql_stmt :=' Insert into bom_diag_temp_tab (Inventory_item_id,Organization_id,		'||
 		 	'     Num_col1,char_col3,char_col1,char_col2)				'||
	 		'  	    SELECT  mmpn.inventory_item_id	 			'||
			'		   ,mmpn.Organization_id				'||
			'		   ,MMPN.MANUFACTURER_ID				'||
			'		   ,MMPN.MFG_PART_NUM					'||
			'		   ,'''||l_varchar_col_rec.column_name||'''		'||
			'		   ,mmpn.'||l_varchar_col_rec.column_name||'		'||
			'	    FROM   MTL_MFG_PART_NUMBERS mmpn				'||
			'	    WHERE  mmpn.inventory_item_id ='||l_item_id||'		'||
			'	    AND    mmpn.organization_id =				'||
			'			(select master_organization_id from mtl_parameters  '||
			'			 where organization_id= '||l_org_id||' )	'||
			'	    AND    mmpn.'||l_varchar_col_rec.column_name||' LIKE ''% ''	'||
			'	    AND	   rownum < '||(row_limit/25);

      	ln_cursor := dbms_sql.open_cursor;
        DBMS_SQL.PARSE(ln_cursor,sql_stmt,dbms_sql.native);
        ln_rows_proc := DBMS_SQL.EXECUTE(ln_cursor);
        DBMS_SQL.CLOSE_CURSOR(ln_cursor);

End Loop;

	sqltxt:='	Select     Inventory_Item_Id 	  "Inventory Item Id",		     '||
		'	 	   Organization_id	  "Organization id",		     '||
		'		   Num_Col1		  "Manufacturer Id",		     '||
		'		   Char_Col3		  "Mfg Part Num",		     '||
		'		   Char_Col1		  "Column Name",		     '||
		'	 	   Char_Col2		  "Column Value"		     '||
		'	From	   bom_diag_temp_tab	  where 1=1			     ';

	sqltxt := sqltxt || ' and rownum< '||row_limit;
	sqltxt :=sqltxt||' order by inventory_item_id, organization_id, Num_col1,char_col3,char_col1';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Columns containing Trailing Spaces in mtl_mfg_part_numbers table ');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;
	statusStr := 'SUCCESS';
	isFatal := 'FALSE';
End;
/* End of mtl_mfg_part_numbers script */

/* Script to verify records in mtl_rtg_item_revisions table */
Begin
	 delete from bom_diag_temp_tab; -- Clear the temporary tables
For l_varchar_col_rec in c_varchar_cols_cur('MTL_RTG_ITEM_REVISIONS',l_oracle_schema) Loop
--JTF_DIAGNOSTIC_COREAPI.Line_Out('Column: '||l_varchar_col_rec.column_name);

	 sql_stmt := '';
	 sql_stmt :=' Insert into bom_diag_temp_tab (Inventory_item_id, organization_id,	'||
 		 	'     char_col3,char_col1,char_col2)					'||
	 		'  	    SELECT  mrir.inventory_item_id	 			'||
	 		' 		   ,mrir.organization_id				'||
			'		   ,MRIR.PROCESS_REVISION				'||
			'		   ,'''||l_varchar_col_rec.column_name||'''		'||
			'		   ,mrir.'||l_varchar_col_rec.column_name||'		'||
			'	    FROM   MTL_RTG_ITEM_REVISIONS mrir				'||
			'	    WHERE  mrir.organization_id  = '||l_org_id||'		'||
			'	    AND    mrir.inventory_item_id ='||l_item_id||'		'||
			'	    AND    mrir.'||l_varchar_col_rec.column_name||' LIKE ''% ''	'||
			'	    AND	   rownum < '||(row_limit/25);

      	ln_cursor := dbms_sql.open_cursor;
        DBMS_SQL.PARSE(ln_cursor,sql_stmt,dbms_sql.native);
        ln_rows_proc := DBMS_SQL.EXECUTE(ln_cursor);
        DBMS_SQL.CLOSE_CURSOR(ln_cursor);

End Loop;

	sqltxt:='	Select     Inventory_Item_Id 	  "Inventory Item Id",		     '||
		'	 	   Organization_id	  "Organization id",		     '||
		'		   Char_Col3		  "Process Revision",		     '||
		'		   Char_Col1		  "Column Name",		     '||
		'	 	   Char_Col2		  "Column Value"		     '||
		'	From	   bom_diag_temp_tab	  where 1=1			     ';

	sqltxt := sqltxt || ' and rownum< '||row_limit;
	sqltxt :=sqltxt||' order by inventory_item_id, organization_id, char_col3,char_col1';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Columns containing Trailing Spaces in mtl_rtg_item_revisions table ');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;
	statusStr := 'SUCCESS';
	isFatal := 'FALSE';

End;
/* End of mtl_rtg_item_revisions script */

/* Script to verify records in mtl_related_items table */
Begin
	 delete from bom_diag_temp_tab; -- Clear the temporary tables
For l_varchar_col_rec in c_varchar_cols_cur('MTL_RELATED_ITEMS',l_oracle_schema) Loop
--JTF_DIAGNOSTIC_COREAPI.Line_Out('Column: '||l_varchar_col_rec.column_name);

	 sql_stmt := '';
	 sql_stmt :=' Insert into bom_diag_temp_tab (Inventory_item_id,Organization_id,		'||
 		 	'     Num_col1,Num_col2,char_col1,char_col2)				'||
	 		'  	    SELECT  mri.inventory_item_id	 			'||
			'		   ,mri.Organization_id					'||
			'		   ,MRI.RELATED_ITEM_ID					'||
			'		   ,MRI.RELATIONSHIP_TYPE_ID				'||
			'		   ,'''||l_varchar_col_rec.column_name||'''		'||
			'		   ,mri.'||l_varchar_col_rec.column_name||'		'||
			'	    FROM   MTL_RELATED_ITEMS mri				'||
			'	    WHERE  mri.inventory_item_id ='||l_item_id||'		'||
			'	    AND    mri.organization_id =				'||
			'			(select master_organization_id from mtl_parameters  '||
			'			 where organization_id= '||l_org_id||' )	'||
			'	    AND    mri.'||l_varchar_col_rec.column_name||' LIKE ''% ''	'||
			'	    AND	   rownum < '||(row_limit/25);

      	ln_cursor := dbms_sql.open_cursor;
        DBMS_SQL.PARSE(ln_cursor,sql_stmt,dbms_sql.native);
        ln_rows_proc := DBMS_SQL.EXECUTE(ln_cursor);
        DBMS_SQL.CLOSE_CURSOR(ln_cursor);

End Loop;

	sqltxt:='	Select     Inventory_Item_Id 	  "Inventory Item Id",		     '||
		'	 	   Organization_id	  "Organization id",		     '||
		'		   Num_Col1		  "Related Item Id",		     '||
		'		   Num_Col2		  "Relationship Type Id",	     '||
		'		   Char_Col1		  "Column Name",		     '||
		'	 	   Char_Col2		  "Column Value"		     '||
		'	From	   bom_diag_temp_tab	  where 1=1			     ';

	sqltxt := sqltxt || ' and rownum< '||row_limit;
	sqltxt :=sqltxt||' order by inventory_item_id, organization_id, Num_col1,Num_col2,char_col1';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Columns containing Trailing Spaces in mtl_related_items table ');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;
	statusStr := 'SUCCESS';
	isFatal := 'FALSE';
End;
/* End of mtl_related_items script */

/* End of Scripts to check for trailing spaces in Item Tables */


/* Start of Scripts to check for trailing spaces in Bom Tables */

/* Get the application installation info. References to Data Dictionary Objects without schema name
included in WHERE predicate are not allowed (GSCC Check: file.sql.47). For accessing all_tab_columns
in cursor c_varchar_cols_cur we need to pass the schema name*/

l_ret_status :=      fnd_installation.get_app_info ('BOM'
						, l_status
						, l_industry
						, l_oracle_schema
						);

/*JTF_DIAGNOSTIC_COREAPI.Line_Out(' l_oracle_schema: '||l_oracle_schema);*/

/* Script to verify records in BOM_STRUCTURES_B table */
Begin
	 delete from bom_diag_temp_tab; -- Clear the temporary tables
For l_varchar_col_rec in c_varchar_cols_cur('BOM_STRUCTURES_B',l_oracle_schema) Loop
--JTF_DIAGNOSTIC_COREAPI.Line_Out('Column: '||l_varchar_col_rec.column_name);

	 sql_stmt := '';
	 sql_stmt :=' Insert into bom_diag_temp_tab (Inventory_item_id,Organization_id,		'||
 		 	'     char_col3,Num_col1,char_col1,char_col2)				'||
	 		'  	    SELECT  bsb.assembly_item_id	 			'||
			'		   ,bsb.Organization_id				'||
			'		   ,bsb.ALTERNATE_BOM_DESIGNATOR			'||
			'		   ,bsb.BILL_SEQUENCE_ID				'||
			'		   ,'''||l_varchar_col_rec.column_name||'''		'||
			'		   ,bsb.'||l_varchar_col_rec.column_name||'		'||
			'	    FROM   BOM_STRUCTURES_B bsb					'||
			'	    WHERE  bsb.assembly_item_id ='||l_item_id||'		'||
			'	    AND    bsb.organization_id  = '||l_org_id||'		'||
			'	    AND    bsb.'||l_varchar_col_rec.column_name||' LIKE ''% ''	'||
			'	    AND	   rownum < '||(row_limit/25);

      	ln_cursor := dbms_sql.open_cursor;
        DBMS_SQL.PARSE(ln_cursor,sql_stmt,dbms_sql.native);
        ln_rows_proc := DBMS_SQL.EXECUTE(ln_cursor);
        DBMS_SQL.CLOSE_CURSOR(ln_cursor);

End Loop;

	sqltxt:='	Select     Inventory_Item_Id 	  "Assembly Item Id",		     '||
		'	 	   Organization_id	  "Organization id",		     '||
		'		   char_Col3		  "ALTERNATE BOM DESIGNATOR",	     '||
		'		   Num_Col1		  "BILL SEQUENCE ID",		     '||
		'		   Char_Col1		  "Column Name",		     '||
		'	 	   Char_Col2		  "Column Value"		     '||
		'	From	   bom_diag_temp_tab	  where 1=1			     ';

	sqltxt := sqltxt || ' and rownum< '||row_limit;
	sqltxt :=sqltxt||' order by inventory_item_id, organization_id, char_col3,Num_col1,char_col1';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Columns containing Trailing Spaces in bom_structures_b table ');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;
	statusStr := 'SUCCESS';
	isFatal := 'FALSE';
End;
/* End of bom_bill_of_materials script */

/* Script to verify records in BOM_COMPONENTS_B table */
Begin
	 delete from bom_diag_temp_tab; -- Clear the temporary tables
For l_varchar_col_rec in c_varchar_cols_cur('BOM_COMPONENTS_B',l_oracle_schema) Loop
--JTF_DIAGNOSTIC_COREAPI.Line_Out('Column: '||l_varchar_col_rec.column_name);

	 sql_stmt := '';
	 sql_stmt :=' Insert into bom_diag_temp_tab (Inventory_item_id,Organization_id,		'||
 		 	'     char_col3,Num_col1,Num_col2,Num_col3,num_col4,char_col1,char_col2)'||
	 		'  	    SELECT  bsb.assembly_item_id	 			'||
			'		   ,bsb.Organization_id				'||
			'		   ,bsb.ALTERNATE_BOM_DESIGNATOR			'||
			'		   ,bsb.BILL_SEQUENCE_ID				'||
			'		   ,BCB.OPERATION_SEQ_NUM				'||
			'		   ,BCB.COMPONENT_ITEM_ID				'||
			'		   ,bcb.component_sequence_id				'||
			'		   ,'''||l_varchar_col_rec.column_name||'''		'||
			'		   ,bcb.'||l_varchar_col_rec.column_name||'		'||
			'	    FROM  BOM_COMPONENTS_B bcb , BOM_STRUCTURES_B bsb	'||
			'	    WHERE  1=1							'||
			'	    AND    bcb.bill_sequence_id = bsb.bill_sequence_id		'||
			'	    AND    bsb.assembly_item_id ='||l_item_id||'		'||
			'	    AND    bsb.organization_id  = '||l_org_id||'		'||
			'	    AND    bcb.'||l_varchar_col_rec.column_name||' LIKE ''% ''	'||
			'	    AND	   rownum < '||(row_limit/25);

      	ln_cursor := dbms_sql.open_cursor;
        DBMS_SQL.PARSE(ln_cursor,sql_stmt,dbms_sql.native);
        ln_rows_proc := DBMS_SQL.EXECUTE(ln_cursor);
        DBMS_SQL.CLOSE_CURSOR(ln_cursor);

End Loop;

	sqltxt:='	Select     Inventory_Item_Id 	  "Assembly Item Id",		     '||
		'	 	   Organization_id	  "Organization id",		     '||
		'		   char_Col3		  "ALTERNATE BOM DESIGNATOR",	     '||
		'		   Num_Col1		  "BILL SEQUENCE ID",		     '||
		'		   Num_Col2		  "OPERATION SEQ NUM",		     '||
		'		   Num_Col3		  "COMPONENT ITEM ID",		     '||
		'		   Num_Col4		  "COMPONENT SEQUENCE ID",	     '||
		'		   Char_Col1		  "Column Name",		     '||
		'	 	   Char_Col2		  "Column Value"		     '||
		'	From	   bom_diag_temp_tab	  where 1=1			     ';

	sqltxt := sqltxt || ' and rownum< '||row_limit;
	sqltxt :=sqltxt||' order by inventory_item_id, organization_id, char_col3,Num_col1,Num_col2,Num_col3,char_col1';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Columns containing Trailing Spaces in bom_components_b table ');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;
	statusStr := 'SUCCESS';
	isFatal := 'FALSE';
End;
/* End of bom_inventory_components script */

/* Script to verify records in bom_reference_designators table */
Begin
	 delete from bom_diag_temp_tab; -- Clear the temporary tables
For l_varchar_col_rec in c_varchar_cols_cur('BOM_REFERENCE_DESIGNATORS',l_oracle_schema) Loop
--JTF_DIAGNOSTIC_COREAPI.Line_Out('Column: '||l_varchar_col_rec.column_name);

	 sql_stmt := '';
	 sql_stmt :=' Insert into bom_diag_temp_tab (Inventory_item_id,Organization_id,		'||
 		 	'     char_col3,Num_col1,Num_col2,char_col4,char_col1,char_col2)	'||
	 		'  	    SELECT  bsb.assembly_item_id	 			'||
			'		   ,bsb.Organization_id				'||
			'		   ,bsb.ALTERNATE_BOM_DESIGNATOR			'||
			'		   ,bsb.BILL_SEQUENCE_ID				'||
			'		   ,bcb.component_sequence_id				'||
			'		   ,BRD.COMPONENT_REFERENCE_DESIGNATOR			'||
			'		   ,'''||l_varchar_col_rec.column_name||'''		'||
			'		   ,brd.'||l_varchar_col_rec.column_name||'		'||
			'	    FROM   bom_inventory_components bcb, bom_bill_of_materials bsb, bom_reference_designators brd '||
			'	    WHERE  1=1							'||
			'	    AND    bcb.bill_sequence_id = bsb.bill_sequence_id		'||
			'	    and    brd.component_sequence_id=bcb.component_sequence_id  '||
			'	    AND    bsb.assembly_item_id ='||l_item_id||'		'||
			'	    AND    bsb.organization_id  = '||l_org_id||'		'||
			'	    AND    brd.'||l_varchar_col_rec.column_name||' LIKE ''% ''	'||
			'	    AND	   rownum < '||(row_limit/25);

      	ln_cursor := dbms_sql.open_cursor;
        DBMS_SQL.PARSE(ln_cursor,sql_stmt,dbms_sql.native);
        ln_rows_proc := DBMS_SQL.EXECUTE(ln_cursor);
        DBMS_SQL.CLOSE_CURSOR(ln_cursor);

End Loop;

	sqltxt:='	Select     Inventory_Item_Id 	  "Assembly Item Id",		     '||
		'	 	   Organization_id	  "Organization id",		     '||
		'		   char_Col3		  "ALTERNATE BOM DESIGNATOR",	     '||
		'		   Num_Col1		  "BILL SEQUENCE ID",		     '||
		'		   Num_Col2		  "COMPONENT SEQUENCE ID",	     '||
		'		   Char_Col4		  "COMPONENT REFERENCE DESIGNATOR",  '||
		'		   Char_Col1		  "Column Name",		     '||
		'	 	   Char_Col2		  "Column Value"		     '||
		'	From	   bom_diag_temp_tab	  where 1=1			     ';

	sqltxt := sqltxt || ' and rownum< '||row_limit;
	sqltxt :=sqltxt||' order by inventory_item_id, organization_id, char_col3,Num_col1,Num_col2,char_col1';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Columns containing Trailing Spaces in bom_reference_designators table ');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;
	statusStr := 'SUCCESS';
	isFatal := 'FALSE';
End;
/* End of bom_reference_designators script */

/* Script to verify records in bom_substitute_components table */
Begin
	 delete from bom_diag_temp_tab; -- Clear the temporary tables
For l_varchar_col_rec in c_varchar_cols_cur('BOM_SUBSTITUTE_COMPONENTS',l_oracle_schema) Loop
--JTF_DIAGNOSTIC_COREAPI.Line_Out('Column: '||l_varchar_col_rec.column_name);

	 sql_stmt := '';
	 sql_stmt :=' Insert into bom_diag_temp_tab (Inventory_item_id,Organization_id,		'||
 		 	'     char_col3,Num_col1,Num_col2,Num_col3,char_col1,char_col2)	'||
	 		'  	    SELECT  bsb.assembly_item_id	 			'||
			'		   ,bsb.Organization_id				'||
			'		   ,bsb.ALTERNATE_BOM_DESIGNATOR			'||
			'		   ,bsb.BILL_SEQUENCE_ID				'||
			'		   ,bcb.component_sequence_id				'||
			'		   ,BSC.SUBSTITUTE_COMPONENT_ID				'||
			'		   ,'''||l_varchar_col_rec.column_name||'''		'||
			'		   ,bsc.'||l_varchar_col_rec.column_name||'		'||
			'	    FROM   bom_inventory_components bcb, bom_bill_of_materials bsb, bom_substitute_components bsc '||
			'	    WHERE  1=1							'||
			'	    AND    bcb.bill_sequence_id = bsb.bill_sequence_id		'||
			'	    and    bsc.component_sequence_id=bcb.component_sequence_id  '||
			'	    AND    bsb.assembly_item_id ='||l_item_id||'		'||
			'	    AND    bsb.organization_id  = '||l_org_id||'		'||
			'	    AND    bsc.'||l_varchar_col_rec.column_name||' LIKE ''% ''	'||
			'	    AND	   rownum < '||(row_limit/25);

      	ln_cursor := dbms_sql.open_cursor;
        DBMS_SQL.PARSE(ln_cursor,sql_stmt,dbms_sql.native);
        ln_rows_proc := DBMS_SQL.EXECUTE(ln_cursor);
        DBMS_SQL.CLOSE_CURSOR(ln_cursor);

End Loop;

	sqltxt:='	Select     Inventory_Item_Id 	  "Assembly Item Id",		     '||
		'	 	   Organization_id	  "Organization id",		     '||
		'		   char_Col3		  "ALTERNATE BOM DESIGNATOR",	     '||
		'		   Num_Col1		  "BILL SEQUENCE ID",		     '||
		'		   Num_Col2		  "COMPONENT SEQUENCE ID",	     '||
		'		   Num_col3		  "SUBSTITUTE COMPONENT ID",	     '||
		'		   Char_Col1		  "Column Name",		     '||
		'	 	   Char_Col2		  "Column Value"		     '||
		'	From	   bom_diag_temp_tab	  where 1=1			     ';

	sqltxt := sqltxt || ' and rownum< '||row_limit;
	sqltxt :=sqltxt||' order by inventory_item_id, organization_id, char_col3,Num_col1,Num_col2,char_col1';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Columns containing Trailing Spaces in bom_substitute_components table ');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;
	statusStr := 'SUCCESS';
	isFatal := 'FALSE';
End;
/* End of bom_substitute_components script */

/* End of Scripts to check for trailing spaces in Bom Tables */

/* Start of Scripts to check for trailing spaces in Rtg Tables */

/* Script to verify records in bom_operational_routings table */
Begin
	 delete from bom_diag_temp_tab; -- Clear the temporary tables
For l_varchar_col_rec in c_varchar_cols_cur('BOM_OPERATIONAL_ROUTINGS',l_oracle_schema) Loop
--JTF_DIAGNOSTIC_COREAPI.Line_Out('Column: '||l_varchar_col_rec.column_name);

	 sql_stmt := '';
	 sql_stmt :=' Insert into bom_diag_temp_tab (Inventory_item_id,Organization_id,		'||
 		 	'     char_col3,Num_col1,char_col1,char_col2)				'||
	 		'  	    SELECT  bor.assembly_item_id	 			'||
			'		   ,bor.Organization_id					'||
			'		   ,BOR.ALTERNATE_ROUTING_DESIGNATOR			'||
			'		   ,BOR.ROUTING_SEQUENCE_ID				'||
			'		   ,'''||l_varchar_col_rec.column_name||'''		'||
			'		   ,bor.'||l_varchar_col_rec.column_name||'		'||
			'	    FROM   bom_operational_routings bor				'||
			'	    WHERE  1=1							'||
			'	    AND    bor.assembly_item_id ='||l_item_id||'		'||
			'	    AND    bor.organization_id  = '||l_org_id||'		'||
			'	    AND    bor.'||l_varchar_col_rec.column_name||' LIKE ''% ''	'||
			'	    AND	   rownum < '||(row_limit/25);

      	ln_cursor := dbms_sql.open_cursor;
        DBMS_SQL.PARSE(ln_cursor,sql_stmt,dbms_sql.native);
        ln_rows_proc := DBMS_SQL.EXECUTE(ln_cursor);
        DBMS_SQL.CLOSE_CURSOR(ln_cursor);

End Loop;

	sqltxt:='	Select     Inventory_Item_Id 	  "Assembly Item Id",		     '||
		'	 	   Organization_id	  "Organization id",		     '||
		'		   char_Col3		  "ALTERNATE ROUTING DESIGNATOR",    '||
		'		   Num_Col1		  "ROUTING SEQUENCE ID",	     '||
		'		   Char_Col1		  "Column Name",		     '||
		'	 	   Char_Col2		  "Column Value"		     '||
		'	From	   bom_diag_temp_tab	  where 1=1			     ';

	sqltxt := sqltxt || ' and rownum< '||row_limit;
	sqltxt :=sqltxt||' order by inventory_item_id, organization_id, char_col3,char_col1';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Columns containing Trailing Spaces in bom_operational_routings table ');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;
	statusStr := 'SUCCESS';
	isFatal := 'FALSE';
End;
/* End of bom_operational_routings script */

/* Script to verify records in bom_operation_sequences table */
Begin
	 delete from bom_diag_temp_tab; -- Clear the temporary tables
For l_varchar_col_rec in c_varchar_cols_cur('BOM_OPERATION_SEQUENCES',l_oracle_schema) Loop
--JTF_DIAGNOSTIC_COREAPI.Line_Out('Column: '||l_varchar_col_rec.column_name);

	 sql_stmt := '';
	 sql_stmt :=' Insert into bom_diag_temp_tab (Inventory_item_id,Organization_id,		'||
 		 	'     char_col3,Num_col1,Num_col2,char_col1,char_col2)			'||
	 		'  	    SELECT  bor.assembly_item_id	 			'||
			'		   ,bor.Organization_id					'||
			'		   ,BOR.ALTERNATE_ROUTING_DESIGNATOR			'||
			'		   ,BOR.ROUTING_SEQUENCE_ID				'||
			'		   ,BOS.OPERATION_SEQUENCE_ID				'||
			'		   ,'''||l_varchar_col_rec.column_name||'''		'||
			'		   ,bos.'||l_varchar_col_rec.column_name||'		'||
			'	    FROM    bom_operational_routings bor, bom_operation_sequences bos '||
			'	    WHERE  1=1							'||
			'	    AND	   bos.routing_sequence_id=bor.routing_sequence_id	'||
			'	    AND    bor.assembly_item_id ='||l_item_id||'		'||
			'	    AND    bor.organization_id  = '||l_org_id||'		'||
			'	    AND    bos.'||l_varchar_col_rec.column_name||' LIKE ''% ''	'||
			'	    AND	   rownum < '||(row_limit/25);

      	ln_cursor := dbms_sql.open_cursor;
        DBMS_SQL.PARSE(ln_cursor,sql_stmt,dbms_sql.native);
        ln_rows_proc := DBMS_SQL.EXECUTE(ln_cursor);
        DBMS_SQL.CLOSE_CURSOR(ln_cursor);

End Loop;

	sqltxt:='	Select     Inventory_Item_Id 	  "Assembly Item Id",		     '||
		'	 	   Organization_id	  "Organization id",		     '||
		'		   char_Col3		  "ALTERNATE ROUTING DESIGNATOR",    '||
		'		   Num_Col1		  "ROUTING SEQUENCE ID",	     '||
		'		   Num_Col2		  "OPERATION SEQUENCE ID",	     '||
		'		   Char_Col1		  "Column Name",		     '||
		'	 	   Char_Col2		  "Column Value"		     '||
		'	From	   bom_diag_temp_tab	  where 1=1			     ';

	sqltxt := sqltxt || ' and rownum< '||row_limit;
	sqltxt :=sqltxt||' order by inventory_item_id, organization_id, char_col3,char_col1';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Columns containing Trailing Spaces in bom_operation_sequences table ');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;
	statusStr := 'SUCCESS';
	isFatal := 'FALSE';
End;
/* End of bom_operation_sequences script */

/* Script to verify records in bom_operation_resources table */
Begin
	 delete from bom_diag_temp_tab; -- Clear the temporary tables
For l_varchar_col_rec in c_varchar_cols_cur('BOM_OPERATION_RESOURCES',l_oracle_schema) Loop
--JTF_DIAGNOSTIC_COREAPI.Line_Out('Column: '||l_varchar_col_rec.column_name);

	 sql_stmt := '';
	 sql_stmt :=' Insert into bom_diag_temp_tab (Inventory_item_id,Organization_id,		'||
 		 	'     char_col3,Num_col1,Num_col2,Num_col3,Num_col4,char_col1,char_col2)'||
	 		'  	    SELECT  bor.assembly_item_id	 			'||
			'		   ,bor.Organization_id					'||
			'		   ,BOR.ALTERNATE_ROUTING_DESIGNATOR			'||
			'		   ,BOR.ROUTING_SEQUENCE_ID				'||
			'		   ,BOS.OPERATION_SEQUENCE_ID				'||
			'		   ,BORE.RESOURCE_SEQ_NUM				'||
			'		   ,BORE.RESOURCE_ID					'||
			'		   ,'''||l_varchar_col_rec.column_name||'''		'||
			'		   ,bore.'||l_varchar_col_rec.column_name||'		'||
			'	    FROM   bom_operational_routings bor, bom_operation_sequences bos,'||
			'		   bom_operation_resources bore				'||
			'	    WHERE   1=1							'||
			'	    AND	   bos.routing_sequence_id=bor.routing_sequence_id	'||
			'	    AND    bore.operation_sequence_id=bos.operation_sequence_id	'||
			'	    AND    bor.assembly_item_id ='||l_item_id||'		'||
			'	    AND    bor.organization_id  = '||l_org_id||'		'||
			'	    AND    bore.'||l_varchar_col_rec.column_name||' LIKE ''% ''	'||
			'	    AND	   rownum < '||(row_limit/25);

      	ln_cursor := dbms_sql.open_cursor;
        DBMS_SQL.PARSE(ln_cursor,sql_stmt,dbms_sql.native);
        ln_rows_proc := DBMS_SQL.EXECUTE(ln_cursor);
        DBMS_SQL.CLOSE_CURSOR(ln_cursor);

End Loop;

	sqltxt:='	Select     Inventory_Item_Id 	  "Assembly Item Id",		     '||
		'	 	   Organization_id	  "Organization id",		     '||
		'		   char_Col3		  "ALTERNATE ROUTING DESIGNATOR",    '||
		'		   Num_Col1		  "ROUTING SEQUENCE ID",	     '||
		'		   Num_Col2		  "OPERATION SEQUENCE ID",	     '||
		'		   Num_Col3		  "RESOURCE SEQ NUM",		     '||
		'		   Num_Col4		  "RESOURCE ID",		     '||
		'		   Char_Col1		  "Column Name",		     '||
		'	 	   Char_Col2		  "Column Value"		     '||
		'	From	   bom_diag_temp_tab	  where 1=1			     ';

	sqltxt := sqltxt || ' and rownum< '||row_limit;
	sqltxt :=sqltxt||' order by inventory_item_id, organization_id, char_col3,Num_col2,Num_col3,char_col1';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Columns containing Trailing Spaces in bom_operation_resources table ');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;
	statusStr := 'SUCCESS';
	isFatal := 'FALSE';
End;
/* End of bom_operation_resources script */

/* Script to verify records in bom_sub_operation_resources table */
Begin
	 delete from bom_diag_temp_tab; -- Clear the temporary tables
For l_varchar_col_rec in c_varchar_cols_cur('BOM_SUB_OPERATION_RESOURCES',l_oracle_schema) Loop
--JTF_DIAGNOSTIC_COREAPI.Line_Out('Column: '||l_varchar_col_rec.column_name);

	 sql_stmt := '';
	 sql_stmt :=' Insert into bom_diag_temp_tab (Inventory_item_id,Organization_id,		'||
 		 	'     char_col3,Num_col1,Num_col2,Num_col3,Num_col4,Num_col5,Num_col6,char_col1,char_col2)'||
	 		'  	    SELECT  bor.assembly_item_id	 			'||
			'		   ,bor.Organization_id					'||
			'		   ,BOR.ALTERNATE_ROUTING_DESIGNATOR			'||
			'		   ,BOR.ROUTING_SEQUENCE_ID				'||
			'		   ,BOS.OPERATION_SEQUENCE_ID				'||
			'		   ,BSOR.SUBSTITUTE_GROUP_NUM				'||
			'		   ,BSOR.RESOURCE_ID					'||
			'		   ,BSOR.SCHEDULE_SEQ_NUM				'||
			'		   ,BSOR.REPLACEMENT_GROUP_NUM				'||
			'		   ,'''||l_varchar_col_rec.column_name||'''		'||
			'		   ,bsor.'||l_varchar_col_rec.column_name||'		'||
			'	    FROM   bom_operational_routings bor, bom_operation_sequences bos,'||
			'		   bom_sub_operation_resources bsor			'||
			'	    WHERE   1=1							'||
			'	    AND	   bos.routing_sequence_id=bor.routing_sequence_id	'||
			'	    AND    bsor.operation_sequence_id=bos.operation_sequence_id	'||
			'	    AND    bor.assembly_item_id ='||l_item_id||'		'||
			'	    AND    bor.organization_id  = '||l_org_id||'		'||
			'	    AND    bsor.'||l_varchar_col_rec.column_name||' LIKE ''% ''	'||
			'	    AND	   rownum < '||(row_limit/25);

      	ln_cursor := dbms_sql.open_cursor;
        DBMS_SQL.PARSE(ln_cursor,sql_stmt,dbms_sql.native);
        ln_rows_proc := DBMS_SQL.EXECUTE(ln_cursor);
        DBMS_SQL.CLOSE_CURSOR(ln_cursor);

End Loop;

	sqltxt:='	Select     Inventory_Item_Id 	  "Assembly Item Id",		     '||
		'	 	   Organization_id	  "Organization id",		     '||
		'		   char_Col3		  "ALTERNATE ROUTING DESIGNATOR",    '||
		'		   Num_Col1		  "ROUTING SEQUENCE ID",	     '||
		'		   Num_Col2		  "OPERATION SEQUENCE ID",	     '||
		'		   Num_Col3		  "SUBSTITUTE GROUP NUM",	     '||
		'		   Num_Col4		  "RESOURCE ID",		     '||
		'		   Num_Col5		  "SCHEDULE SEQ NUM",		     '||
		'		   Num_Col6		  "REPLACEMENT GROUP NUM",	     '||
		'		   Char_Col1		  "Column Name",		     '||
		'	 	   Char_Col2		  "Column Value"		     '||
		'	From	   bom_diag_temp_tab	  where 1=1			     ';

	sqltxt := sqltxt || ' and rownum< '||row_limit;
	sqltxt :=sqltxt||' order by inventory_item_id, organization_id, char_col3,Num_col2,Num_col3,Num_col6,char_col1';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Columns containing Trailing Spaces in bom_sub_operation_resources table ');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;
	statusStr := 'SUCCESS';
	isFatal := 'FALSE';
End;
/* End of bom_sub_operation_resources script */


/* Script to verify records in bom_operation_networks table */
Begin
	 delete from bom_diag_temp_tab; -- Clear the temporary tables
For l_varchar_col_rec in c_varchar_cols_cur('BOM_OPERATION_NETWORKS',l_oracle_schema) Loop
--JTF_DIAGNOSTIC_COREAPI.Line_Out('Column: '||l_varchar_col_rec.column_name);

	 sql_stmt := '';
	 sql_stmt :=' Insert into bom_diag_temp_tab (Inventory_item_id,Organization_id,		'||
 		 	'     char_col3,Num_col1,Num_col2,Num_col3,Num_col4,char_col1,char_col2)'||
	 		'  	    SELECT  bor.assembly_item_id	 			'||
			'		   ,bor.Organization_id					'||
			'		   ,BOR.ALTERNATE_ROUTING_DESIGNATOR			'||
			'		   ,BOR.ROUTING_SEQUENCE_ID				'||
			'		   ,BOS.OPERATION_SEQUENCE_ID				'||
			'		   ,BON.FROM_OP_SEQ_ID					'||
			'		   ,BON.TO_OP_SEQ_ID					'||
			'		   ,'''||l_varchar_col_rec.column_name||'''		'||
			'		   ,bon.'||l_varchar_col_rec.column_name||'		'||
			'	    FROM   bom_operational_routings bor, bom_operation_sequences bos,'||
			'		   bom_operation_networks bon				'||
			'	    WHERE   1=1							'||
			'	    AND    bos.routing_sequence_id=bor.routing_sequence_id	'||
			'	    AND    bon.to_op_seq_id=bos.operation_sequence_id		'||
			'	    AND    bor.assembly_item_id ='||l_item_id||'		'||
			'	    AND    bor.organization_id  = '||l_org_id||'		'||
			'	    AND    bon.'||l_varchar_col_rec.column_name||' LIKE ''% ''	'||
			'	    AND    rownum < '||(row_limit/25);

      	ln_cursor := dbms_sql.open_cursor;
        DBMS_SQL.PARSE(ln_cursor,sql_stmt,dbms_sql.native);
        ln_rows_proc := DBMS_SQL.EXECUTE(ln_cursor);
        DBMS_SQL.CLOSE_CURSOR(ln_cursor);

End Loop;

	sqltxt:='	Select     Inventory_Item_Id 	  "Assembly Item Id",		     '||
		'	 	   Organization_id	  "Organization id",		     '||
		'		   char_Col3		  "ALTERNATE ROUTING DESIGNATOR",    '||
		'		   Num_Col1		  "ROUTING SEQUENCE ID",	     '||
		'		   Num_Col2		  "OPERATION SEQUENCE ID",	     '||
		'		   Num_Col3		  "FROM OP SEQ ID",		     '||
		'		   Num_Col4		  "TO OP SEQ ID",		     '||
		'		   Char_Col1		  "Column Name",		     '||
		'	 	   Char_Col2		  "Column Value"		     '||
		'	From	   bom_diag_temp_tab	  where 1=1			     ';

	sqltxt := sqltxt || ' and rownum< '||row_limit;
	sqltxt :=sqltxt||' order by inventory_item_id, organization_id, char_col3,Num_col2,Num_col3,char_col1';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Columns containing Trailing Spaces in bom_operation_networks table ');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;
	statusStr := 'SUCCESS';
	isFatal := 'FALSE';
End;
/* End of bom_operation_networks script */

/* End of Scripts to check for trailing spaces in Rtg Tables */

  <<l_test_end>>
 JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/><BR/>This data collection script completed as expected <BR/>');
 report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
 reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;

EXCEPTION
 when others then
     JTF_DIAGNOSTIC_COREAPI.errorprint('Error: '||sqlerrm);
     JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('If this error repeats, please contact Oracle Support Services');
     statusStr := 'FAILURE';
     errStr := sqlerrm ||' occurred in script. ';
     fixInfo := 'Unexpected Exception in BOMDGTSB.pls';
     isFatal := 'FALSE';
     report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
     reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;

END runTest;

PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'Attribute Trailing Spaces';
END getComponentName;

PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2) IS
BEGIN
descStr := ' This diagnostic test checks Items/Bills/Routing tables for <BR/>
		columns holding values with trailing spaces and <BR/>
		provides suggestions on how to solve possible issues.<BR/>
		Run this health check when experiencing issues with a specific Item.<BR/>
		( E.g. FRM-40654 : Record has been updated.)<BR/>
		Inputs for fields OrgId and ItemID are mandatory. ';
END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'Attribute Trailing Spaces';
END getTestName;

PROCEDURE getDependencies (package_names OUT NOCOPY JTF_DIAG_DEPENDTBL) IS
tempDependencies JTF_DIAG_DEPENDTBL;

BEGIN
    package_names := JTF_DIAGNOSTIC_ADAPTUTIL.initDependencyTable;
END getDependencies;

PROCEDURE isDependencyPipelined (str OUT NOCOPY VARCHAR2) IS
BEGIN
  str := 'FALSE';
END isDependencyPipelined;


PROCEDURE getOutputValues(outputValues OUT NOCOPY JTF_DIAG_OUTPUTTBL) IS
  tempOutput JTF_DIAG_OUTPUTTBL;
BEGIN
  tempOutput := JTF_DIAGNOSTIC_ADAPTUTIL.initOutputTable;
  outputValues := tempOutput;
EXCEPTION
 when others then
 outputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initOutputTable;
END getOutputValues;


PROCEDURE getDefaultTestParams(defaultInputValues OUT NOCOPY JTF_DIAG_INPUTTBL) IS
tempInput JTF_DIAG_INPUTTBL;
BEGIN
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'OrgId','LOV-oracle.apps.bom.diag.lov.OrganizationLov');-- Lov name modified to OrgId for bug 6412260
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'ItemId','LOV-oracle.apps.bom.diag.lov.ItemLov');-- Lov name modified to ItemId for bug 6412260
defaultInputValues := tempInput;
EXCEPTION
when others then
defaultInputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
END getDefaultTestParams;

Function getTestMode return INTEGER IS
BEGIN
return JTF_DIAGNOSTIC_ADAPTUTIL.ADVANCED_MODE;

END getTestMode;

END BOM_DIAGUNITTEST_TSDATA;

/
