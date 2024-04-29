--------------------------------------------------------
--  DDL for Package Body BOM_DIAGUNITTEST_ITMHLCHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_DIAGUNITTEST_ITMHLCHK" as
/* $Header: BOMDGITB.pls 120.1 2007/12/26 09:54:57 vggarg noship $ */
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
 reportStr	LONG;           -- REPORT
 sqltxt		VARCHAR2(9999);  -- SQL select statement
 c_username	VARCHAR2(50);   -- accept input for username
 statusStr	VARCHAR2(50);   -- SUCCESS or FAILURE
 errStr		VARCHAR2(4000); -- error message
 fixInfo	VARCHAR2(4000); -- fix tip
 isFatal	VARCHAR2(50);   -- TRUE or FALSE
 num_rows	NUMBER;
 dummy_num	NUMBER;
 row_limit	NUMBER;
 l_item_id	NUMBER;
 l_org_id	NUMBER;
 Value_link	VARCHAR2(4000);
 l_org_exists	NUMBER;
 l_script	VARCHAR2(20);
 l_index_match	NUMBER;
 l_seg_count	NUMBER;
 l_org_col_exists NUMBER;
 l_where_clause VARCHAR2(500);
 l_count        NUMBER;
 ln_cursor	  Integer;
 sql_stmt        VARCHAR2(4000);
 ln_rows_proc    INTEGER :=0;
 l_ret_status      BOOLEAN;
 l_status          VARCHAR2 (1);
 l_industry        VARCHAR2 (1);
 l_oracle_schema   VARCHAR2 (30);

Cursor c_item_status_codes is
select inventory_item_status_code status
from mtl_item_status_tl
order by inventory_item_status_code;

Cursor c_item_status_attr_val(l_item_status_code VARCHAR2) Is
select inventory_item_status_code,substr(attribute_name,18) attribute_name,attribute_value
from mtl_stat_attrib_values_all_v
where status_code_ndb  = 1
and  inventory_item_status_code=l_item_status_code
order by attribute_name;

Cursor list_of_unique_indexes(l_owner VARCHAR2) Is
select index_name
from   all_indexes
where  table_name = 'MTL_SYSTEM_ITEMS_B'
and    owner = l_owner
and    UNIQUENESS = 'UNIQUE';

BEGIN
JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;

/* Set Row Limit to 1000 (i.e.) Max Number of records to be fetched by each sql*/
 row_limit :=1000;
 l_org_exists :=0; /* Initialize to zero */

-- accept input
l_org_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('OrgId',inputs);
l_script := nvl(upper(JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('Script',inputs)),'ALL');

-- JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Script Selected: '||l_script);


/* l_script is NOT a mandatory input. If it is not entered, then run all the scripts.
   However if a script name is entered, then validate it for existence. */

	If l_script not in ('DUP_ITEM','UNIQ_INDEX','IVGL_ACC','MISSING_TL','COST_ENABLED',
			    'SECONDARY_UOM','BUYER_ID','PLANNER_INACT',
			    'ATTR_DEPEND','STATTR_MISMATCH','ACTDATE_NN','ALL') Then

		JTF_DIAGNOSTIC_COREAPI.errorprint('Invalid Script Name');
		JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please choose a Script Name from the Lov or leave the field blank.');
		statusStr := 'FAILURE';
		isFatal := 'TRUE';
		fixInfo := ' Please review the error message below and take corrective action.';
		errStr  := ' Invalid value for input field Script ';

		report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
		reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
		Return;
	End If;
/* End of script name validation*/

/* l_org_id is NOT a mandatory input. If it is not entered, then run the scripts for all orgs.
   However if a value is entered for org_id, then validate it for existence. */

If l_org_id is not null Then /* validate if input org_id exists*/
	Begin
		select 1 into l_org_exists
		from   mtl_parameters
		where  organization_id = l_org_id;
	Exception
	When others Then
		l_org_exists :=0;
		JTF_DIAGNOSTIC_COREAPI.errorprint('Invalid Organization Id');
		JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(' Please either provide a valid value for the Organization Id or leave it blank.');
		statusStr := 'FAILURE';
		isFatal := 'TRUE';
		fixInfo := ' Please review the error message below and take corrective action. ';
		errStr  := ' Invalid value for input field Organization Id ';

		report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
		reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
	End;
End If; /* End of l_org_id is not null */

If (l_org_id is null) or (l_org_exists = 1) Then
/* Health Check scripts start */

/* Get the application installation info. References to Data Dictionary Objects without schema name
included in WHERE predicate are not allowed (GSCC Check: file.sql.47). Schema name has to be passed
as an input parameter to JTF_DIAGNOSTIC_COREAPI.Column_Exists API. */

l_ret_status :=      fnd_installation.get_app_info ('INV'
                                   , l_status
                                   , l_industry
                                   , l_oracle_schema
                                    );

/*JTF_DIAGNOSTIC_COREAPI.Line_Out(' l_oracle_schema: '||l_oracle_schema);*/

If l_script  in ('ALL','DUP_ITEM') Then
/* Script 1 - Duplicate Item Names */
sqltxt := 'SELECT   mif.PADDED_ITEM_NUMBER	"Item Number",				'||
	  '	    mp.organization_code	"Org Code",				'||
          '	    mif.inventory_item_id	"Item Id",				'||
	  '	    mif.organization_id		"Org Id"				'||
	  '  FROM   mtl_item_flexfields mif , mtl_parameters mp 			'||
	  ' WHERE  (mif.organization_id,PADDED_ITEM_NUMBER) in				'||
	  '			(select    organization_id , padded_item_number		'||
          '			 from      mtl_item_flexfields				'||
          '			 group by  organization_Id, PADDED_ITEM_NUMBER		'||
          '			 having  count(*) > 1 )					'||
	  '   AND  mif.organization_id = mp.organization_id				';

if l_org_id is not null then
   sqltxt :=sqltxt||' and mif.organization_id =  '||l_org_id;
end if;
sqltxt := sqltxt || ' and rownum< '||row_limit;
sqltxt := sqltxt || ' order by mif.PADDED_ITEM_NUMBER, mp.organization_code';
num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Duplicate Item Names ');

If (num_rows = 0) Then	   /* Corrupt Data Found for this case*/
 JTF_DIAGNOSTIC_COREAPI.Line_Out('No corrupt data found for this case. <BR/>');
ElsIf (num_rows > 0) Then  /* Show Impact and Action only if rows are returned */
 If (num_rows = row_limit -1 ) Then
 JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows
				  <BR/> to prevent an excessively big output file <BR/>');
 End If;
 JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/><u>IMPACT:</u>
<BR/>Querying these items in Items form , transactions form , sales order form etc.
<BR/>will error thus making these items unusable.');

reportStr := '<BR/>
<BR/><u>ACTION</u>:
<BR/>If Duplicate Rows are returned:
<BR/> Case 1: Master Item duplicates:
     <BR/> If Duplicate Item is present only in the Master org, then user needs to
     <BR/> rename the Master Item which is not assigned to any child org.
     <BR/> To rename the Master Item, make use of the below mentioned update script.
<BR/> Case 2: Both Child and Master org duplicates:
     <BR/> If the Duplicate Item is present in both Master and Child orgs , then user can
     <BR/> choose any one of the duplicated items and rename the same in the Master org.
     <BR/> To rename the Master Item, make use of the below mentioned update script.
     <BR/> Please use the below update statements to rename the Master Item.
     <BR/> <BR/>Important: Please try these scripts on a TEST instance first.
     <pre>
     The below update statement can be used to correct a specific item.
     Substitute the bind variables orgid and itemid with the appropriate values.

	update mtl_system_items_b
        set segment1 = ''segment1'' || ''_DUP''
       where  organization_id = :orgid
       and    inventory_item_id = :itemid;
       </pre>
     <BR/> Use ''Delete Items'' form to delete the renamed item.
<BR/>';
JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
End If;   /* End of Impact and Action */

statusStr := 'SUCCESS';
isFatal := 'FALSE';
JTF_DIAGNOSTIC_COREAPI.BRPrint;
End If; /* End of l_script */
/* End of Script 1 - Duplicate Item Names */

/* Script for Unique Index suggestion for Item Number segments in MSIB */

/* Get the application installation info. References to Data Dictionary Objects without schema name
included in WHERE predicate are not allowed (GSCC Check: file.sql.47). For accessing all_indexes
in cursor list_of_unique_indexes and all_ind_columns in the query below we need to pass the schema name*/

l_ret_status :=      fnd_installation.get_app_info ('INV'
                                   , l_status
                                   , l_industry
                                   , l_oracle_schema
                                    );

/*JTF_DIAGNOSTIC_COREAPI.Line_Out(' l_oracle_schema: '||l_oracle_schema);*/

If l_script  in ('ALL','UNIQ_INDEX') Then

/* Logic of the script:
   Let  SetA = all the enabled segments for MSTK kff
	SetB = all the columns in a particular index on table MTL_SYSTEM_ITEMS_B

    If SetA - SetB = SetB - SetA Then SetA = SetB
*/

	Begin
		/*Fetch Enabled System Items Segments */

		sqltxt := 'select segment_num "Segment Number", segment_name "Segment Name",	 '||
   		  '	application_column_name "Column Name", required_flag "Required Flag"	 '||
	   	  '	from   fnd_id_flex_segments_vl						 '||
	   	  '	where  application_id = 401						 '||
	   	  '	and    id_flex_code   = ''MSTK''					 '||
	          '	and    id_flex_num    = 101						 '||
	   	  '	and    enabled_flag   = ''Y''						 '||
	  	  '	order by segment_num 							 ';

		num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Unique Index suggestion for Enabled Item Number Segments in mtl_system_items_b Table.');
		statusStr := 'SUCCESS';
		isFatal := 'FALSE';
		/*End of Script to fetch Enabled System Items Segments */

		If (num_rows = 0) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('None of the Item Number Segments are enabled. <BR/>');
		Elsif (num_rows > 0) Then  /* Show Impact and Action only if rows are returned */
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Listed above are the enabled system items segments.
		<BR/> Users are suggested to create an Unique Index on MTL_SYSTEM_ITEMS_B table
		<BR/> containing all the enabled segments plus the organization_id column.
		<BR/> For further details on creating such an index please refer to
		<BR/> ''Oracle Manufacturing APIs and Open Interfaces Manual'' (Part No. A95955-03),
		<BR/> Chapter 7 - ''Oracle Inventory Open Interfaces and APIs'',
		<BR/> Section ''Open Item Interface'', SubSection ''Setting Up the Item Interface''.
		<BR/> <BR/><u>IMPACT:</u> Presence of such an Index will improve the performance
		<BR/> while querying up Items and will also avoid Duplicate Items from getting created.
		<BR/><BR/> Verifying whether such an index exists....
		<BR/> <u>Result:</u>');
		l_index_match:=0;

		For l_index in list_of_unique_indexes(l_oracle_schema) Loop
		l_index_match:=0; /* reset to does not match*/
		l_org_col_exists :=0;
		l_seg_count :=0;

		Begin

			Select 1 into l_seg_count from dual
			 where not exists (
			 (select APPLICATION_COLUMN_NAME "Column_Name"
			 from FND_ID_FLEX_SEGMENTS
			 where ID_FLEX_CODE = 'MSTK'
			 and enabled_flag = 'Y'
			 MINUS
			 select column_name  "Column_Name"
			 from   all_ind_columns aic
			 where  table_name = 'MTL_SYSTEM_ITEMS_B'
			 and    aic.index_name =l_index.index_name
			 and    index_owner=l_oracle_schema
			 and    COLUMN_NAME LIKE 'SEGMENT%')
			 UNION
			 (
			 select column_name  "Column_Name"
			 from   all_ind_columns aic
			 where  table_name = 'MTL_SYSTEM_ITEMS_B'
			 and    aic.index_name =l_index.index_name
			 and    index_owner=l_oracle_schema
			 and    COLUMN_NAME LIKE 'SEGMENT%'
			 MINUS
			 select APPLICATION_COLUMN_NAME "Column_Name"
			 from FND_ID_FLEX_SEGMENTS
			 where ID_FLEX_CODE = 'MSTK'
			 and enabled_flag = 'Y')
			 );

			If l_seg_count = 1 Then /* Segment Match Found*/
				Begin
		   			Select 1 into l_org_col_exists
					from   all_ind_columns aic
					where  table_name = 'MTL_SYSTEM_ITEMS_B'
					and    aic.index_name = l_index.index_name
					and    index_owner=l_oracle_schema
					and    COLUMN_NAME ='ORGANIZATION_ID';
				Exception
	   			When Others Then
					Null;
				End;
			End If;

			If l_seg_count=1 and l_org_col_exists=1 Then
				l_index_match :=1;   /* Matching Index Exists */
				JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Unique Index '||l_index.index_name||' matches the Enabled System Items Segments + Organization_Id columns. <BR/>');
				Exit;
			End If;

		Exception
		When Others Then
			null;
		End;
		End Loop;

		If l_index_match=0 Then /* Match Not Found*/
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> No Unique Index as described above exists.
		<BR/> <BR/><u>ACTION:</u> Please create a Unique Index on MTL_SYSTEM_ITEMS_B table
		<BR/> containing all the enabled segments plus the organization_id column. <BR/>');
		End If;
		End If;   /* End of Impact and Action */
	End;
JTF_DIAGNOSTIC_COREAPI.BRPrint;
End If; /* End of l_script */
/* End of Script for Unique Index suggestion for Item Number segments in MSIB */

/* Script for fetching items with invalid GL accounts. */
If l_script  in ('ALL','IVGL_ACC') Then
sqltxt := '	   SELECT glcc.PADDED_CONCATENATED_SEGMENTS  "Code Combination",					 '||
	  '	   mif.PADDED_ITEM_NUMBER 		   "Item Number",					 '||
	  '	   mp.organization_code 		   "Org Code",						 '||
	  '	   glcc.code_combination_id		   "Code Combination Id",				 '||
  	  '	   mif.inventory_item_id 		   "Item Id",						 '||
	  '	   mp.organization_id	 		   "Org Id",						 '||
	  '        decode(mif.cost_of_sales_account,glcc.code_combination_Id,''X'') "Cost Of Sales Account",	 '||
	  '	   decode(mif.sales_account,glcc.code_combination_Id,''X'')	  "Sales Account",		 '||
	  '	   decode(mif.expense_account,glcc.code_combination_Id,''X'')	  "Expense Account",		 '||
	  '	   decode(mif.encumbrance_account,glcc.code_combination_Id,''X'')	  "Encumbrance Account"		 '||
	  '	   FROM  gl_code_combinations_kfv glcc, mtl_item_flexfields mif , mtl_parameters mp		 '||
	  '        WHERE glcc.code_combination_id in (mif.cost_of_sales_account, mif.SALES_ACCOUNT,		 '||
	  '   					    mif.EXPENSE_ACCOUNT, mif.ENCUMBRANCE_ACCOUNT)		 '||
	  '        AND nvl(glcc.END_DATE_ACTIVE,sysdate) < sysdate						 '||
	  '        AND DETAIL_POSTING_ALLOWED = ''Y''								 '||
	  '	   AND CHART_OF_ACCOUNTS_ID in (select chart_of_accounts_id					 '||
	  '					from ORG_ORGANIZATION_DEFINITIONS ood				 '||
	  '					where ood.organization_id = mif.organization_id and rownum = 1)	 '||
	  '	   AND mif.organization_id = mp.organization_id 						 ';

if l_org_id is not null then
   sqltxt :=sqltxt||' and mif.organization_id =  '||l_org_id;
end if;
sqltxt := sqltxt || ' and rownum< '||row_limit;
sqltxt := sqltxt || ' order by glcc.PADDED_CONCATENATED_SEGMENTS, mif.PADDED_ITEM_NUMBER, mp.organization_code';

num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Items with Invalid GL Accounts');

If (num_rows = 0) Then	   /* Corrupt Data Found for this case*/
 JTF_DIAGNOSTIC_COREAPI.Line_Out('No corrupt data found for this case. <BR/>');
ElsIf (num_rows > 0) Then  /* Show Impact and Action only if rows are returned */
 If (num_rows = row_limit -1 ) Then
 JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows
				  <BR/> to prevent an excessively big output file <BR/>');
 End If;
 JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/>Account Columns marked with ''X'' correspond to invalid GL Accounts.');
 JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/><u>IMPACT:</u>
<BR/> Downstream applications using these items might refer to
<BR/> these invalid GL accounts thus causing data corruption. ');

reportStr :=
'<BR/> <BR/><u>ACTION</u>:
 <BR/> Please follow the below steps to correct each of the items with invalid GL Accounts.
 <BR/> 1) Open (N) Inventory > Items form (Master Items/Organization Items).
 <BR/> 2) Query for that Item.
 <BR/> 3) Go to the respective invalid GL Account Code field.
 <BR/>	    (T) Costing > ''Cost of Goods Sold Account'', (T) Invoicing > ''Sales Account'',
 <BR/>       (T) Purchasing > ''Expense Account'', (T) Purchasing > ''Encumbrance Account''.
 <BR/> 4) Choose an appropriate valid GL Account from the Lov attached.
 <BR/> 5) Save changes to this item.
 <BR/> <u>Note</u>: If the number of items to corrected are huge, then Item Import functionality
 <BR/> can also be used for correcting the GL Account fields.
 <BR/> For details on Item Import, please refer to
 <BR/> ''Oracle Manufacturing APIs and Open Interfaces Manual'' (Part No. A95955-03),
 <BR/> Chapter 7 - ''Oracle Inventory Open Interfaces and APIs'', Section ''Open Item Interface''.
 <BR/>';
JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
End If;   /* End of Impact and Action */

statusStr := 'SUCCESS';
isFatal := 'FALSE';

JTF_DIAGNOSTIC_COREAPI.BRPrint;
End If; /* End of l_script */
/* End of script for fetching items with invalid GL accounts. */

/* Script to identify items present in mtl_system_items_b but missing in mtl_system_items_tl */
If l_script  in ('ALL','MISSING_TL') Then
sqltxt := 'SELECT mif.PADDED_ITEM_NUMBER	"Item Number",					'||
	  '	  mp.Organization_code		"Org Code",					'||
	  '	  mif.inventory_item_id		"Item Id",					'||
	  '	  mif.organization_id		"Org Id"					'||
          '  FROM    mtl_item_flexfields mif , mtl_parameters mp				'||
          '  WHERE   Not Exists (SELECT      ''x''						'||
          '                  FROM        mtl_system_items_tl msitl				'||
          '                  WHERE       msitl.organization_id = mif.organization_id		'||
          '                  AND         msitl.inventory_item_id = mif.inventory_item_id)	'||
	  '   AND mif.organization_id = mp.organization_id					';

if l_org_id is not null then
   sqltxt :=sqltxt||' and mif.organization_id =  '||l_org_id;
end if;
sqltxt := sqltxt || ' and rownum< '||row_limit;
sqltxt := sqltxt || ' order by mif.PADDED_ITEM_NUMBER, mp.organization_code';

num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' List of Items present in mtl_system_items_b table but missing in mtl_system_items_tl table');

If (num_rows = 0) Then	   /* Corrupt Data Found for this case*/
 JTF_DIAGNOSTIC_COREAPI.Line_Out('No corrupt data found for this case. <BR/>');
ElsIf (num_rows > 0) Then  /* Show Impact and Action only if rows are returned */
 If (num_rows = row_limit -1 ) Then
 JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows
				  <BR/> to prevent an excessively big output file <BR/>');
 End If;
 JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/><u>IMPACT:</u>
 <BR/> These items cannot be queried and used in multiple forms across the application .
 <BR/> For e.g. Items , Purchasing, Transactions, Sales order form etc. <BR/><BR/>');

JTF_DIAGNOSTIC_COREAPI.ActionErrorLink('<BR/> If Rows are returned with missing data in translations table,
					<BR/> then please refer to metalink note : ' , '388325.1', '' );
End If;   /* End of Impact and Action */

statusStr := 'SUCCESS';
isFatal := 'FALSE';

JTF_DIAGNOSTIC_COREAPI.BRPrint;
End If; /* End of l_script */
/* End of Script to identiy items present in mtl_system_items_b but missing in mtl_system_items_tl */


/* Script to Identify costing enabled items with missing data in costing tables */
If l_script  in ('ALL','COST_ENABLED') Then
sqltxt := '	select '||
	  '	mif.padded_item_number	   "PADDED ITEM NUMBER",   			 '||
	  '	mp.organization_code	   "ORGANIZATION CODE",    			 '||
	  '	mif.costing_enabled_flag   "COSTING ENABLED FLAG",	 		 '||
	  '	mif.inventory_asset_flag   "INVENTORY ASSET FLAG",  			 '||
	  '	mif.inventory_item_id	   "INVENTORY ITEM ID",    			 '||
	  '	mp.organization_id 	   "ORGANIZATION ID"     			 '||
	  '	from    mtl_item_flexfields mif, mtl_parameters mp			 '||
	  '	where   mif.organization_id = mp.organization_id 			 '||
	  '	and     mif.costing_enabled_flag = ''Y''				 '||
	  '	and not exists (select null 						 '||
	  '			from  cst_item_costs cic 				 '||
	  '	                where cic.organization_id   = mif.organization_id 	 '||
	  '	                and   cic.inventory_item_id = mif.inventory_item_id)	 ';

	if l_org_id is not null then
	   sqltxt :=sqltxt||' and mif.organization_id =  '||l_org_id;
	end if;
	sqltxt := sqltxt || ' and rownum< '||row_limit;
	sqltxt :=sqltxt||' order by mif.padded_item_number, mp.organization_code';

num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Costing Enabled Items with missing data in costing tables. ');

If (num_rows = 0) Then	   /* Corrupt Data Found for this case*/
 JTF_DIAGNOSTIC_COREAPI.Line_Out('No corrupt data found for this case. <BR/>');
ElsIf (num_rows > 0) Then  /* Show Impact and Action only if rows are returned */
 If (num_rows = row_limit -1 ) Then
 JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows
				  <BR/> to prevent an excessively big output file <BR/>');
 End If;
JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/><u>IMPACT:</u>
<BR/>These items cannot be costed which will cause data corruption in Costing module. ');

reportStr :=
' <BR/><BR/><u>ACTION</u>:
  <BR/>	Please follow the below steps to create the missing data in costing tables
  <BR/>  for each item returned above.
  <BR/>	Case 1: (On Hand Quantity does not exist for the item in the corresponding organization)
  <BR/>	1) Open (N) Inventory > Items form (Master Items/Organization Items).
  <BR/>	2) Query for that Item.
  <BR/>	3) Go to (T) Costing.
  <BR/>	4) Select ''Costing Enabled'' checkbox. Select ''Inventory Asset Value'' checkbox if required.
  <BR/>	   If these checkboxes are already checked, then uncheck them first and then check again.
  <BR/>	5) Save changes to this item.
  <BR/>
  <BR/>	Case 2:(On Hand Quantity exists for the item in the corresponding organization)
  <BR/>	1) Issue out the on hand quantity for this item.
  <BR/>  Now <b><u>NO</u></b> On Hand Quantity exists for this item.
  <BR/>	2) Follow the steps in case 1 to enable the costing flags.
  <BR/>	3) Receive the quantity back into the organization.
  <BR/>
  <BR/>	Caution:Costing Flags should be flipped only when NO On Hand Qty exists for an Item.
  <BR/>	         Otherwise it will lead to severe data corruption.
  <BR/>	<u>Note</u>: If the number of items to corrected are huge, then Item Import functionality
  <BR/>  can also be used for flipping the costing flags.
  <BR/>  For details on Item Import, please refer to
  <BR/>  ''Oracle Manufacturing APIs and Open Interfaces Manual'' (Part No. A95955-03),
  <BR/>  Chapter 7 - ''Oracle Inventory Open Interfaces and APIs'', Section ''Open Item Interface''.
  <BR/>';

JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
End If;   /* End of Impact and Action */

statusStr := 'SUCCESS';
isFatal := 'FALSE';

JTF_DIAGNOSTIC_COREAPI.BRPrint;
End If; /* End of l_script */
/* End of costing enabled items with missing data in costing tables. */


/* Script to identify items whose tracking and pricing UOMs are set to Primary but
  Secondary UOM has a non null value. So we check for the existence of the columns ont_pricing_qty_source,tracking_quantity_ind
  in table mtl_system_items_b */

If l_script  in ('ALL','SECONDARY_UOM') Then

sqltxt := '	select '||
	  '		mif.padded_item_number		"item number",			  '||
	  ' 		mp.organization_code 		"org code",			  '||
	  ' 	  	mif.tracking_quantity_ind 	"tracking quantity ind", 	  '||
	  '	  	mif.ont_pricing_qty_source 	"ont pricing qty source", 	  '||
	  '   	  	mif.secondary_uom_code 		"secondary uom code",   	  '||
	  ' 	  	mif.inventory_item_id 		"inventory item id",		  '||
	  ' 	  	mif.organization_id 		"organization id" 		  '||
	  '	from    mtl_item_flexfields mif, mtl_parameters mp			  '||
	  '	where   mif.organization_id=mp.organization_id				  '||
	  '	and     nvl(mif.tracking_quantity_ind,''P'') =  ''P'' 			  '||
	  '	and     nvl(mif.ont_pricing_qty_source,''P'') = ''P'' 			  '||
	  '	and     mif.secondary_uom_code is not null 				  ';

	if l_org_id is not null then
	   sqltxt :=sqltxt||' and mif.organization_id =  '||l_org_id;
	end if;
	sqltxt := sqltxt || ' and rownum< '||row_limit;
	sqltxt :=sqltxt||' order by mif.padded_item_number, mp.organization_code';

num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Items whose Tracking or Pricing fields (Items -> Main tab) set to Primary but Secondary UOM has a Non Null value.');

If (num_rows = 0) Then	   /* Corrupt Data Found for this case*/
 JTF_DIAGNOSTIC_COREAPI.Line_Out('No corrupt data found for this case. <BR/>');
ElsIf (num_rows > 0) Then  /* Show Impact and Action only if rows are returned */
 If (num_rows = row_limit -1 ) Then
	JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows
					 <BR/> to prevent an excessively big output file <BR/>');
 End If;
JTF_DIAGNOSTIC_COREAPI.Line_Out(' <BR/> When an item''s Tracking or Pricing field (Items -> main tab)
				  <BR/> is set to Primary, then its Secondary UOM should not be populated.');

JTF_DIAGNOSTIC_COREAPI.Line_Out(' <BR/><u>IMPACT:</u>
<BR/> Item import process cannot be run to update any of the Item attributes
<BR/> as users will receive the following error message.
<BR/> ''If tracking and pricing are set to Primary,
<BR/> then Secondary Unit of measure can only have a null value. '' ');

reportStr := '<BR/><BR/><u>ACTION</u>:
<BR/> Use Item Import in UPDATE mode to update the column SECONDARY_UOM_CODE
<BR/> as NULL for these Items.
<BR/> To null out varchar attributes through Item Import, the value ''!'' (exclamation mark)
<BR/> has to be populated for the corresponding column in the interface record.
<BR/> For details on Item Import, please refer to
<BR/> ''Oracle Manufacturing APIs and Open Interfaces Manual'' (Part No. A95955-03),
<BR/> Chapter 7 - ''Oracle Inventory Open Interfaces and APIs'', Section ''Open Item Interface''.
<BR/>';
JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
End If;   /* End of Impact and Action */

statusStr := 'SUCCESS';
isFatal := 'FALSE';

JTF_DIAGNOSTIC_COREAPI.BRPrint;
End If; /* End of l_script */
/* End of script to identify items whose tracking and pricing UOMs are set to Primary but
  Secondary UOM has a non null value.*/

/* Script to identify items attached with inactive buyers*/
If l_script  in ('ALL','BUYER_ID') Then
sqltxt := '	select '||
	  '	   	mif.padded_item_number    "Item Number",			  '||
	  ' 	   	mp.organization_code	  "Organization Code",			  '||
	  ' 	   	pav.agent_name		  "Default Buyer",			  '||
	  '	   	to_char(pav.start_date_active,''DD-MON-YYYY HH24:MI:SS'')     "Start Date Active", '||
	  '   	   	to_char(pav.end_date_active,''DD-MON-YYYY HH24:MI:SS'')       "End Date Active",   '||
	  ' 	   	mif.inventory_item_id  	  "Inventory Item Id",			  '||
	  '		mif.organization_id	  "Organization Id",			  '||
	  '	   	mif.buyer_id		  "Default Buyer Id"			  '||
	  '	from    mtl_item_flexfields mif, mtl_parameters mp, po_agents_v pav	  '||
	  '	where   mif.organization_id=mp.organization_id				  '||
	  '	and     mif.buyer_id=pav.agent_id					  '||
	  '	and     sysdate not between nvl(pav.start_date_active, sysdate-1) 	  '||
 	  ' 		 		       and nvl(pav.end_date_active, sysdate+1)	  ';

	if l_org_id is not null then
	   sqltxt :=sqltxt||' and mif.organization_id =  '||l_org_id;
	end if;
	sqltxt := sqltxt || ' and rownum< '||row_limit;
	sqltxt := sqltxt ||'  order by mif.padded_item_number, mp.organization_code';

num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Items whose buyer_id corresponds to Inactive Buyers');

If (num_rows = 0) Then	   /* Corrupt Data Found for this case*/
 JTF_DIAGNOSTIC_COREAPI.Line_Out('No corrupt data found for this case. <BR/>');
ElsIf (num_rows > 0) Then  /* Show Impact and Action only if rows are returned */
 If (num_rows = row_limit -1 ) Then
 JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows
				  <BR/> to prevent an excessively big output file <BR/>');
 End If;
JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/><u>IMPACT:</u>
<BR/> Item import process cannot be run to update any of the Item attributes as users
<BR/> will receive error messages corresponding to inactive buyers. ');

reportStr := '<BR/><BR/><u>ACTION</u>:
<BR/> If records are fetched with inactive buyer_id,
<BR/> then please follow the below steps to correct them.
<BR/> 1) Open (N) Inventory > Items > Items form.
<BR/>	If attribute ''Default Buyer'' is Master Controlled, then use Master Items form,
<BR/>	Else if it is Org Controlled, then use Organization Items form.
<BR/> 2) Query for an item fetched above.
<BR/> 3) Go to (T) Purchasing > ''Default Buyer'' field.
<BR/> 4) Currently it will be blank.
<BR/> 5)	Click on this field and tab out without entering any value for it.
<BR/> This will clear the buyer_id column.
<BR/> 6) Save the changes to the form.
<BR/>';
JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);


/*<BR/><BR/> Note: If the number of items to be corrected are huge, then use Item Import in UPDATE mode to null out the buyer_id column.
<BR/> For nulling out numeric attributes through IOI the value -999999 has to be populated for the corresponding column in the interface record.
*/
End If;   /* End of Impact and Action */

statusStr := 'SUCCESS';
isFatal := 'FALSE';

JTF_DIAGNOSTIC_COREAPI.BRPrint;
End If; /* End of l_script */
/* End of Script to identify items attached with inactive buyers*/

/* Script to identify items attached with inactive planners*/

If l_script  in ('ALL','PLANNER_INACT') Then
sqltxt := '	select '||
	  '  		mif.padded_item_number    "Item Number",			'||
	  '  		mp.organization_code	  "Organization Code",			'||
	  ' 		mpl.planner_code	  "Planner",				'||
	  '		to_char(mpl.disable_date,''DD-MON-YYYY HH24:MI:SS'')	  "Planner Disable Date", '||
	  '  		mif.inventory_item_id  	  "Inventory Item Id",			'||
	  ' 		mif.organization_id	  "Organization Id"			'||
	  ' 	from	mtl_item_flexfields mif, mtl_parameters mp, mtl_planners mpl	'||
	  ' 	where	mif.organization_id=mp.organization_id				'||
	  ' 	and	mif.organization_id=mpl.organization_id				'||
	  ' 	and	mif.planner_code=mpl.planner_code				'||
	  ' 	and	nvl(mpl.disable_date, sysdate+1) < sysdate 			';

	if l_org_id is not null then
	   sqltxt :=sqltxt||' and mif.organization_id =  '||l_org_id;
	end if;
	sqltxt := sqltxt || ' and rownum< '||row_limit;
	sqltxt := sqltxt ||'  order by mif.padded_item_number, mp.organization_code, mpl.planner_code';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Items with Inactive Planners ');

	If (num_rows = 0) Then	   /* Corrupt Data Found for this case*/
		JTF_DIAGNOSTIC_COREAPI.Line_Out('No corrupt data found for this case. <BR/>');
	ElsIf (num_rows > 0) Then  /* Show Impact and Action only if rows are returned */
		If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows
						 <BR/> to prevent an excessively big output file <BR/>');
		End If;

	JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/><u>IMPACT:</u>
	<BR/> Item import process cannot be run to update any of the Item attributes as users
	<BR/> will receive error messages corresponding to invalid planners. ');

	reportStr := '<BR/><BR/><u>ACTION</u>:
	<BR/> If records are fetched with inactive planners,
	<BR/> then please follow the below steps to correct them.
	<BR/> 1) Open (N) Inventory > Items > Items form.
	<BR/>	If attribute ''Planner'' is Master Controlled, then use Master Items form,
	<BR/>	Else if it is Org Controlled, then use Organization Items form.
	<BR/> 2) Query for an item fetched above.
	<BR/> 3) Go to (T) General Planning > Planner field.
	<BR/> 4) Currently it will show the inactive planner.
	<BR/> 5)	Either clear this field or choose a valid planner from the lov.
	<BR/> 6) Save the changes to the form. <BR/>
	<BR/> <U>Note:</U> If the number of items to be corrected are huge, then
	<BR/> use Item Import in UPDATE mode to update the column PLANNER_CODE
	<BR/> for these Items to either a NULL value or a valid Planner.
	<BR/> To null out varchar attributes through Item Import, the value ''!'' (exclamation mark)
	<BR/> has to be populated for the corresponding column in the interface record.
	<BR/> For details on Item Import, please refer to
	<BR/> ''Oracle Manufacturing APIs and Open Interfaces Manual'' (Part No. A95955-03),
	<BR/> Chapter 7 - ''Oracle Inventory Open Interfaces and APIs'', Section ''Open Item Interface''.
	<BR/>';
	JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);


	End If;   /* End of Impact and Action */

	statusStr := 'SUCCESS';
	isFatal := 'FALSE';

JTF_DIAGNOSTIC_COREAPI.BRPrint;
End If; /* End of l_script */
/* End of Script to identify items with inactive planners*/


/* Script to identify items that fail the Interdependencies betweem Status Attributes. */
If l_script  in ('ALL','ATTR_DEPEND') Then
sqltxt := 	'	Select	'||
		'	mif.padded_item_number     "Item Number",																	'||
		'       mp.organization_code       "Org Code",																		'||
		'	mif.inventory_item_flag    "INVENTORY ITEM FLAG",																'||
		'	mif.purchasing_item_flag   "PURCHASING ITEM FLAG",																'||
		'	mif.customer_order_flag    "CUSTOMER ORDER FLAG",																'||
		'	mif.internal_order_flag    "INTERNAL ORDER FLAG",																'||
		'	mif.invoiceable_item_flag  "INVOICEABLE ITEM FLAG",																'||
		'	decode(mif.bom_item_type,1,''Model'',2,''Option Class'',3,''Planning'',4,''Standard'',5,''Product Family'')  "BOM ITEM TYPE",							'||
		'       decode(stock_enabled_flag,inventory_item_flag,null,''N'',null,''Y'',stock_enabled_flag) "STOCK ENABLED FLAG",									'||
		'       decode(mtl_transactions_enabled_flag,stock_enabled_flag,null,''N'',null,''Y'',mtl_transactions_enabled_flag) "MTL TRANSACTIONS ENABLED FLAG",					'||
		'       decode(purchasing_enabled_flag,purchasing_item_flag,null,''N'',null,''Y'',purchasing_enabled_flag) "PURCHASING ENABLED FLAG",							'||
		'       decode(customer_order_enabled_flag,customer_order_flag,null,''N'',null,''Y'',customer_order_enabled_flag) "CUSTOMER ORDER ENABLED FLAG",					'||
		'       decode(internal_order_enabled_flag,internal_order_flag,null,''N'',null,''Y'',internal_order_enabled_flag) "INTERNAL ORDER ENABLED FLAG",					'||
		'       decode(invoice_enabled_flag,invoiceable_item_flag,null,''N'',null,''Y'',invoice_enabled_flag) "INVOICE ENABLED FLAG",								'||
		'       decode(build_in_wip_flag,inventory_item_flag,decode(build_in_wip_flag,decode(bom_item_type,1,''N'',2,''N'',3,''N'',5,''N'',build_in_wip_flag),null,build_in_wip_flag),		'||
		'       						 ''N'',decode(build_in_wip_flag,decode(bom_item_type,1,''N'',2,''N'',3,''N'',5,''N'',build_in_wip_flag),null,build_in_wip_flag),'||
		'       						 ''Y'',build_in_wip_flag) "BUILD IN WIP FLAG",											'||
		'       mif.inventory_item_id "Inventory Item Id",mif.organization_id "Org Id"														'||
		'       from mtl_item_flexfields mif, mtl_parameters mp																	'||
		'       where																						'||
		'       mif.organization_id=mp.organization_id																		'||
		'       and																						'||
		'       (  																						'||
		'          ( mif.inventory_item_flag=''N'' and mif.stock_enabled_flag=''Y'')														'||
		'          or (mif.inventory_item_flag=''N'' and  mif.mtl_transactions_enabled_flag=''Y'')												'||
		'          or (mif.purchasing_item_flag=''N'' and mif.purchasing_enabled_flag=''Y'')													'||
		'          or (mif.customer_order_flag=''N'' and  mif.customer_order_enabled_flag=''Y'')												'||
		'          or (mif.internal_order_flag=''N'' and  mif.internal_order_enabled_flag=''Y'')												'||
		'          or (mif.invoiceable_item_flag=''N'' and mif.invoice_enabled_flag=''Y'')													'||
		'          or ( (mif.inventory_item_flag=''N'' or mif.bom_item_type <> 4) and  mif.build_in_wip_flag=''Y'')										'||
		'  	)																						';

	If l_org_id is not null then
	   sqltxt :=sqltxt||' and mif.organization_id =  '||l_org_id;
	End if;
	sqltxt := sqltxt || ' and rownum< '||row_limit;
	sqltxt := sqltxt ||'  order by mif.padded_item_number, mp.organization_code';

num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Items that fail the Interdependencies between Status Attributes.');

If (num_rows = 0) Then	   /* Corrupt Data Found for this case*/
 JTF_DIAGNOSTIC_COREAPI.Line_Out('No corrupt data found for this case. <BR/>');
ElsIf (num_rows > 0) Then  /* Show Impact and Action only if rows are returned */
 If (num_rows = row_limit -1 ) Then
 JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows
				  <BR/> to prevent an excessively big output file <BR/>');
 End If;
 reportStr := '<BR/> Listed below are the interdependencies for the Item Status Attributes.
  <BR/><BR/> 1. Stockable (stock_enabled_flag) Must be set to No
  <BR/> If Inventory Item (inventory_item_flag) is set to No.
  <BR/> 2. Transactable (mtl_transactions_enabled_flag) Must be set to No
  <BR/> If Stockable (stock_enabled_flag) is set to No.
  <BR/> 3. Purchasable (purchasing_enabled_flag) Must be set to No
  <BR/> If Purchased (purchasing_item_flag) is set to No.
  <BR/> 4. Build in WIP (build_in_wip_flag) Must be set to No
  <BR/> If Inventory Item (inventory_item_flag) is set to No
  <BR/> OR BOM Item Type (bom_item_type) is NOT set to Standard.
  <BR/> 5. Customer Orders Enabled (customer_order_enabled_flag) Must be set to No
  <BR/> If Customer Ordered Item (customer_order_flag) is set to No.
  <BR/> 6. Internal Orders Enabled (internal_order_enabled_flag) Must be set to No
  <BR/> If Internal Ordered Item (internal_order_flag) is set to No.
  <BR/> 7. Invoice Enabled (invoice_enabled_flag) Must be set to No
  <BR/> If Invoiceable Item (invoiceable_item_flag) is set to No.
  <BR/><BR/> Note 1: In the output above, the Item Status Attributes
  <BR/> successfully meeting the interdepencies are indicated with a null value.
  <BR/> The ones showing ''Y'' indicate the failed status attributes.
  <BR/> The current values (''Y'' or ''N'') of the Independent attributes are always shown.
  <BR/> Note 2: For an item, if either Stockable or Transactable attributes are wrong
  <BR/> then please verify and correct both.
  <BR/><BR/><u>ACTION</u>:
  <BR/> If records are fetched above,then please use Item Import in UPDATE mode
  <BR/> to correct the respective Item Status Attribute value.
  <BR/> For details on Item Import, please refer to
  <BR/> ''Oracle Manufacturing APIs and Open Interfaces Manual'' (Part No. A95955-03),
  <BR/> Chapter 7 - ''Oracle Inventory Open Interfaces and APIs'', Section ''Open Item Interface''.
  <BR/>';
JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
End If;   /* End of Impact and Action */

statusStr := 'SUCCESS';
isFatal := 'FALSE';

JTF_DIAGNOSTIC_COREAPI.BRPrint;
End If; /* End of l_script */
/* End of Script to identify items that fail the Interdependencies betweem Status Attributes. */


/* Script to identify Items violating validations between status code and status control attributes . */
If l_script  in ('ALL','STATTR_MISMATCH') Then
Begin
	 delete from bom_diag_temp_tab; -- Clear the temporary tables
	For l_item_st_rec in  c_item_status_codes loop
		l_where_clause :='';
		l_where_clause :=l_where_clause ||' and mif.INVENTORY_ITEM_STATUS_CODE = '''||l_item_st_rec.status||''' and ( 1=2 ';
		for l_st_attr_rec in c_item_status_attr_val(l_item_st_rec.status) loop
			l_where_clause := l_where_clause||' or  mif.'||l_st_attr_rec.attribute_name||' <> '''||l_st_attr_rec.attribute_value||'''';
		end loop;
	  l_where_clause :=l_where_clause ||' ) '; /* append closing brace */

	/* Insert the fetched records into temporary table bom_diag_temp_tab */
        sql_stmt := '';
	sql_stmt := ' Insert into bom_diag_temp_tab (Inventory_item_id, organization_id, '||
 		 ' char_col1,char_col2,char_col3,char_col4,char_col5,char_col6,char_col7,char_col8,char_col9) '||
		 '  Select mif.inventory_item_id ,	        '||
		'     mif.organization_Id, 			'||
		'     MIF.INVENTORY_ITEM_STATUS_CODE,		'||
		'     MIF.BOM_ENABLED_FLAG,		  	'||
		'     MIF.BUILD_IN_WIP_FLAG,			'||
		'     MIF.CUSTOMER_ORDER_ENABLED_FLAG,		'||
		'     MIF.INTERNAL_ORDER_ENABLED_FLAG,		'||
		'     MIF.INVOICE_ENABLED_FLAG,			'||
		'     MIF.MTL_TRANSACTIONS_ENABLED_FLAG,	'||
		'     MIF.PURCHASING_ENABLED_FLAG,		'||
		'     MIF.STOCK_ENABLED_FLAG			'||
		'     From mtl_item_flexfields	mif		'||
		'     Where	1=1 '||l_where_clause;
	if l_org_id is not null then
	   sql_stmt :=sql_stmt||' and mif.organization_id =  '||l_org_id;
	end if;
	/*sql_stmt := sql_stmt || ' and rownum< 5'; -- temporarily limiting the records to 5 */

        ln_cursor := dbms_sql.open_cursor;
        DBMS_SQL.PARSE(ln_cursor,sql_stmt,dbms_sql.native);
        ln_rows_proc := DBMS_SQL.EXECUTE(ln_cursor);
        DBMS_SQL.CLOSE_CURSOR(ln_cursor);

	End Loop;

	/* Display the records stored in temporary table bom_diag_temp_tab */
	sqltxt := '	Select     Inventory_Item_Id 	  "Inventory Item Id",		     '||
		  '	 	   Organization_id	  "Organization id",		     '||
		  '		   Char_Col1		  "Inventory Item Status Code",	     '||
		  '		   Char_Col2		  "BOM ENABLED FLAG",		     '||
		  '		   Char_Col3		  "BUILD IN WIP FLAG",		     '||
		  '	 	   Char_Col4		  "CUSTOMER ORDER ENABLED FLAG",     '||
		  '		   Char_Col5		  "INTERNAL ORDER ENABLED FLAG",     '||
		  '	 	   Char_Col6		  "INVOICE ENABLED FLAG",	     '||
		  '		   Char_Col7		  "MTL TRANSACTIONS ENABLED FLAG",   '||
		  '	 	   Char_Col8		  "PURCHASING ENABLED FLAG",	     '||
		  '	 	   Char_Col9		  "STOCK ENABLED FLAG"		     '||
		  '	From       bom_diag_temp_tab where 1=1	';

	sqltxt := sqltxt || ' and rownum< '||row_limit;
	sqltxt :=sqltxt||' order by inventory_item_id, organization_id';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Items violating validations between status code and status control attributes ');

	If (num_rows = 0) Then	   /* Corrupt Data Found for this case*/
	 JTF_DIAGNOSTIC_COREAPI.Line_Out('No corrupt data found for this case. <BR/>');
	ElsIf (num_rows > 0) Then  /* Show Impact and Action only if rows are returned */
	 If (num_rows = row_limit -1 ) Then
	 JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows
					  <BR/> to prevent an excessively big output file <BR/>');
	 End If;
	JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/>
	 The values of the Status Control Attributes that use ''Sets Value'' status setting should
	<BR/> always be in sync with their corresponding values of the Item Status Code chosen.
	<BR/> Listed above are the items that violate this validation.
	<BR/> The values of all their Status Control Attributes
	<BR/> along with the Item Status Code are also listed.
	<BR/> Please refer to the below table that lists the Status Control Attributes
	<BR/> using ''Sets Value'' status setting. If no rows are fetched,
	<BR/> it implies that none of the Status Control Attributes use ''Sets Value''.
	<BR/>');

	sqltxt := '	select attribute_name "Attribute Name"	'||
		  '	from   mtl_item_attributes		'||
		  '	where status_control_code = 1		';
	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'');

	reportStr := ('<BR/><u>ACTION</u>:
	<BR/>If records are fetched above listing items that violate this validation, then
	<BR/>1) Please use Item Import in UPDATE mode to modify the Item Status Code
	<BR/>which will in turn set the values of all Status Control Attributes.
	<BR/>2) If required, the values of the Status Controlled Attributes that
	<BR/>do NOT use ''Sets Value'' setting, can then be changed.
	<BR/> For details on Item Import, please refer to
	<BR/> ''Oracle Manufacturing APIs and Open Interfaces Manual'' (Part No. A95955-03),
	<BR/> Chapter 7 - ''Oracle Inventory Open Interfaces and APIs'', Section ''Open Item Interface''.
	<BR/>');

	JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
	End If;   /* End of Impact and Action */

	statusStr := 'SUCCESS';
	isFatal := 'FALSE';

End;

JTF_DIAGNOSTIC_COREAPI.BRPrint;
End If; /* End of l_script */
/* End of Script to identify Items violating validations between status code and status control attributes . */

/* Script to fetch items whose start_date_active, end_date_active columns are not null */
If l_script  in ('ALL','ACTDATE_NN') Then
	sqltxt := '	SELECT mif.padded_item_number "Item Number",		 '||
		  '	       mp.organization_code   "Org Code",		 '||
		  '	       to_char(mif.start_date_active,''DD-MON-YYYY HH24:MI:SS'')  "Start Date Active",	 '||
	 	  '	       to_char(mif.end_date_active,''DD-MON-YYYY HH24:MI:SS'')    "End Date Active",	 '||
		  '	       mif.inventory_item_id  "Item Id",		 '||
		  '	       mp.organization_id     "Org Id"  		 '||
	     	  '	 FROM  mtl_item_flexfields mif , mtl_parameters mp	 '||
		  '	 WHERE 1=1						 '||
		  '      AND   mif.organization_id=mp.organization_id		 '||
		  '	 AND   ( mif.end_date_active IS NOT NULL OR mif.start_date_active IS NOT NULL ) ';

		if l_org_id is not null then
		   sqltxt :=sqltxt||' and mif.organization_id =  '||l_org_id;
		end if;
		sqltxt := sqltxt || ' and rownum< '||row_limit;
		sqltxt := sqltxt || ' order by mif.PADDED_ITEM_NUMBER, mp.organization_code';

num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Items whose start_date_active, end_date_active columns are populated ');

If (num_rows = 0) Then	   /* Corrupt Data Found for this case*/
 JTF_DIAGNOSTIC_COREAPI.Line_Out('No corrupt data found for this case. <BR/>');
ElsIf (num_rows > 0) Then  /* Show Impact and Action only if rows are returned */
 If (num_rows = row_limit -1 ) Then
 JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows
				  <BR/> to prevent an excessively big output file <BR/>');
 End If;
JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> start_date_active and end_date_active date fields
<BR/> are NOT used to determine the effectivity of an item.
<BR/> The effectivity of an item is determined by its Item Status Code.
<BR/><BR/><u>IMPACT:</u>
<BR/> None of the attributes of these items can be updated.
<BR/> FRM-40654 error may also occur while trying to
<BR/> update these items through the Items form.
<BR/>');

reportStr := '<BR/><u>ACTION</u>:
  <BR/> These two date fields have to be nulled out.
   <BR/> Nulling them out will not effect any standard functionality in Items form.
  <BR/> Please use the below update statements to null out these two date fields.
  <BR/> <BR/>Important: Please try these scripts on a TEST instance first.
  <pre>
  The below update statement can be used to correct a specific item.
  Substitute the bind variables orgid and itemid
  with the appropriate values.

   update mtl_system_items_b
   set    start_date_active = null
         ,end_date_active = null
   where  organization_id = :orgid
   and    inventory_item_id = :itemid;

  The below two update statements can be used
  to collectively correct all the problematic items.

  update mtl_system_items_b
  set    start_date_active = null
  where  start_date_active is not null;

  update mtl_system_items_b
  set    end_date_active = null
  where  end_date_active is not null;  </pre>
  <BR/>';
JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
End If;   /* End of Impact and Action */

statusStr := 'SUCCESS';
isFatal := 'FALSE';

JTF_DIAGNOSTIC_COREAPI.BRPrint;
End If; /* End of l_script */
/* End of Script to fetch items whose start_date_active, end_date_active columns are not null */

----------------
 <<l_test_end>>
 JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/><BR/>This Health Check Test completed as expected <BR/>');
 report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
 reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;

End If; /* End of l_org_id is null or l_org_exists=1 */

EXCEPTION
 when others then
     JTF_DIAGNOSTIC_COREAPI.errorprint('Error: '||sqlerrm);
     JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('If this error repeats, please contact Oracle Support Services');
     statusStr := 'FAILURE';
     errStr := sqlerrm ||' occurred in script. ';
     fixInfo := 'Unexpected Exception in BOMDGITB.pls';
     isFatal := 'FALSE';
     report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
     reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;

END runTest;

PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'Items Data Health Check Details';
END getComponentName;

PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2) IS
BEGIN
descStr := 'This diagnostic test performs a variety of health checks against Items <BR/>
		and provides suggestions on how to solve possible issues.<BR/>
		It is recommended to run this health check periodically.';
END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'Items Data Health Check';
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
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'Script','LOV-oracle.apps.bom.diag.lov.ItemHealthLov');
defaultInputValues := tempInput;
EXCEPTION
when others then
defaultInputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
END getDefaultTestParams;

Function getTestMode return INTEGER IS
BEGIN
 return JTF_DIAGNOSTIC_ADAPTUTIL.ADVANCED_MODE;

END getTestMode;

END BOM_DIAGUNITTEST_ITMHLCHK;

/
