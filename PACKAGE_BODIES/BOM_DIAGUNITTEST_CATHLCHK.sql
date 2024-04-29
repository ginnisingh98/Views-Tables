--------------------------------------------------------
--  DDL for Package Body BOM_DIAGUNITTEST_CATHLCHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_DIAGUNITTEST_CATHLCHK" as
/* $Header: BOMDGICB.pls 120.0.12000000.1 2007/07/26 13:28:16 vggarg noship $ */
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
 sqltxt      VARCHAR2(9999);  -- SQL select statement
 c_username  VARCHAR2(50);   -- accept input for username
 statusStr   VARCHAR2(50);   -- SUCCESS or FAILURE
 errStr      VARCHAR2(4000); -- error message
 fixInfo     VARCHAR2(4000); -- fix tip
 isFatal     VARCHAR2(50);   -- TRUE or FALSE
 num_rows    NUMBER;
 row_limit   NUMBER;
 l_item_id   NUMBER;
 l_org_id    NUMBER;
 l_org_exists	NUMBER;
 l_master_org_id    NUMBER;
 l_master_org_code  VARCHAR2(3);
 l_script    VARCHAR2(20);

BEGIN
JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;

/* Set Row Limit to 1000 (i.e.) Max Number of records to be fetched by each sql*/
 row_limit :=1000;

-- accept input
l_script := nvl(upper(JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('Script',inputs)),'ALL');

-- JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Script Selected: '||l_script);

/* l_script is NOT a mandatory input. If it is not entered, then run all the scripts.
   However if a script name is entered, then validate it for existence. */

	If l_script not in ('MULT_CAT','SEED_CAT','ALL') Then
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

/* Script 1 - Multiple item category assignments exists for category set which do not allow multiple assignments.
	      This script is run for all orgs.*/
/*List of Category Sets that do not allow Multiple Item Category Assignments
but actually have Multiple Item Category Assignments*/

If l_script  in ('ALL','MULT_CAT') Then

sqltxt := ' Select * from (	'||
	  '	select mcsv.category_set_name "Category Set Name",						'||
	  '	decode(mcsv.control_level,1,''Master'',2,''Org'')	"Control Level",			'||
	  '	mp.organization_code "Organization Code",							'||
	  '	mif.padded_item_number "Item Number",count(*) "Count of categories assigned",			'||
	  '	mic.category_set_id "Category Set Id",								'||
	  '	mic.organization_id "Organization Id" ,mic.inventory_item_id "Item Id"				'||
	  '	from mtl_item_categories mic, mtl_category_sets_v mcsv,						'||
	  '	     mtl_parameters mp, mtl_item_flexfields mif							'||
	  '	where mif.inventory_item_id = mic.inventory_item_id						'||
	  '	and   mif.organization_id   = mic.organization_id						'||
	  '	and   mic.organization_id   = mp.organization_id						'||
	  '	and   mcsv.category_set_id  = mic.category_set_id						'||
	  '	and   mcsv.mult_item_cat_assign_flag = ''N''							'||
    	  '	group by mcsv.category_set_name,mcsv.control_level, mp.organization_code,mif.padded_item_number,'||
	  '	         mic.category_set_id,mic.organization_id,mic.inventory_item_id				'||
	  '	having count(*) > 1										'||
	  '	order by mcsv.category_set_name,mp.organization_code,mif.padded_item_number			'||
	  '	) where rownum <  '||row_limit;

num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Multiple Item Category Assignments exists for Category Sets which do not allow multiple assignments.');

If (num_rows = 0) Then	   /* Corrupt Data Found for this case*/
	JTF_DIAGNOSTIC_COREAPI.Line_Out('No corrupt data found for this case. <BR/><BR/>');
ElsIf (num_rows > 0) Then  /* Show Impact and Action only if rows are returned */
 If (num_rows = row_limit -1 ) Then
	JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows
					 <BR/> to prevent an excessively big output file. <BR/>');
 End If;
 JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Please note that this script is run for all the organizations.<BR/>');
 JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/><u>IMPACT:</u>
 <BR/> This affects inventory transactions , POs, Quotations, iProcurement, Costing etc
 <BR/> as all these modules assume a single category for an item
 <BR/> for their respective functional area category set. ');

reportStr :=
'<BR/><BR/><u>ACTION</u>:
<BR/> If Rows are returned with multiple category assignments,
<BR/> please follow the below steps for correcting them.
<BR/> Case 1: For Org controlled Category Sets.
<BR/> 1) Open (N) Inventory > Organization Items form.
<BR/> 2) Query for an Item fetched above.
<BR/> 3) Go to (M) Tools > Categories.
<BR/> 4) Query for the corresponding Category Set containing multiple assignments.
<BR/>    (i.e.) This item will be assigned to multiple categories
<BR/>    under this category set which is not allowed.
<BR/> 5) Delete the unwanted item category assignments.
<BR/> 6) Save the changes to the Item.
<BR/>
<BR/> Case 2: For Master controlled Category Sets.
<BR/> 1) Open (N) Inventory > Master Items form.
<BR/> 2) Query for an Item fetched above.
<BR/> 3) Go to (M) Tools > Categories.
<BR/> 4) Query for the corresponding Category Set containing multiple assignments.
<BR/>    (i.e.) This item will be assigned to multiple categories
<BR/>	under this category set which is not allowed.
<BR/> 5) Delete the unwanted item category assignments.
<BR/> 6) Save the changes to the Item.
<BR/>';
JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
End If;   /* End of Impact and Action */

statusStr := 'SUCCESS';
isFatal := 'FALSE';

JTF_DIAGNOSTIC_COREAPI.BRPrint;
End If; /* End of l_script */
/* End of Script 1 */

/* Script 2 - Check whether seeded Category set id 5,11,12 are attached to structures other than
              (SALES_CATEGORIES for 5   and CARTONIZATION for 11,12) */
If l_script  in ('ALL','SEED_CAT') Then
sqltxt := '	  select  mcsv.category_set_name	"CATEGORY SET NAME",		  '||
	  '	  mcsv.description			"CATEGORY SET DESCRIPTION",	  '||
	  '	  fifsv.id_flex_structure_code		"ID FLEX STRUCTURE CODE",	  '||
	  '	  fifsv.id_flex_structure_name		"ID FLEX STRUCTURE NAME",	  '||
	  '	  fifsv.description			"ID FLEX STRUCTURE DESCRIPTION",  '||
	  '	  mcsv.category_set_id			"CATEGORY SET ID",		  '||
	  '	  mcsv.structure_id			"STRUCTURE ID",			  '||
	  '	  mcsv.default_category_id		"DEFAULT CATEGORY ID",		  '||
	  '	  mcsv.validate_flag			"VALIDATE FLAG",		  '||
	  '	  mcsv.control_level			"CONTROL LEVEL",		  '||
	  '	  mcsv.mult_item_cat_assign_flag	"MULT ITEM CAT ASSIGN FLAG"	  '||
	  '	  from   mtl_category_sets_vl mcsv, fnd_id_flex_structures_vl fifsv	  '||
	  '	  where  mcsv.structure_id=fifsv.id_flex_num				  '||
	  '	  and    fifsv.id_flex_code = ''MCAT''					  '||
	  '	  and    (  ( mcsv.category_set_id =5 					  '||
	  '		        and fifsv.id_flex_structure_code  <> ''SALES_CATEGORIES'' '||
	  '			  )							  '||
	  '			or							  '||
	  '			  ( mcsv.category_set_id in (11,12) 			  '||
	  '		        and fifsv.id_flex_structure_code <> ''CARTONIZATION''	  '||
	  '			  )							  '||
	  '		   )								  ';

num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Seeded Category Sets with invalid structure code ');

If (num_rows = 0) Then	   /* Corrupt Data Found for this case*/
	JTF_DIAGNOSTIC_COREAPI.Line_Out('No corrupt data found for this case. <BR/><BR/>');
ElsIf (num_rows > 0) Then  /* Show Impact and Action only if rows are returned */
/*It is not required to check if num_rows = (row_limit-1) since the output of this query
  can atmost be 3 records only. */
JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/>Seeded Category Sets -
	      <BR/>''Sales and Marketing'' (category set id = 5) should be attached
	      <BR/> to Structure code ''SALES_CATEGORIES'' only.
	      <BR/> ''Contained Item'' (category set id = 11) and ''Container Item'' (category set id = 12)
	      <BR/> should be attached to Structure code ''CARTONIZATION'' only. ');

JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/><BR/><u>IMPACT:</u>
<BR/> User defined category set overwrites the seeded category set values
<BR/> thus causing data corruption.
<BR/> Some upgrade scripts fail with unique constraint violation error.');

reportStr := '<BR/>
	<BR/><u>ACTION</u>:
	<BR/> <u>Important:</u> Try this action plan on a TEST instance first.
	<BR/> If Rows are returned with corrupt Seeded Category Sets,
	<BR/> please follow the below steps for correcting them.
	<BR/> 1) Run the below queries. Substitute the bind variable :cat_set_id
	<BR/> with the category_set_id of the corrupted Category Set.
	<pre>
        select category_set_id,count(*)
        from mtl_item_categories
        where category_set_id = :cat_set_id
        group by category_set_id ;

        select category_set_id,count(*)
        from mtl_category_set_valid_cats
        where category_set_id = :cat_set_id
        group by category_set_id ;

        select category_set_id,count(*)
        from cst_cost_updates
        where category_set_id = :cat_set_id
        group by category_set_id ;

        select category_set_id,count(*)
        from cst_cost_type_history
        where category_set_id  = :cat_set_id
        group by category_set_id ;

        select category_set_id,count(*)
        from mtl_default_category_sets
        where category_set_id =:cat_set_id
        group by category_set_id ;

        select category_set_id,count(*)
        from cst_ap_variance_batches
        where category_set_id = :cat_set_id
        group by category_set_id ;

        select category_set_id,count(*)
        from cst_item_overhead_defaults
        where category_set_id = :cat_set_id
        group by category_set_id ;

        select category_set_id,count(*)
        from cst_sc_rollup_history
        where category_set_id = :cat_set_id
        group by category_set_id ;
	</pre>
	2) If all the above queries return NO rows, proceed to Step 3.
	<BR/>3) Take a backup of entire mtl_category_sets_b table.
	<BR/>4) Run the below query to get the correct Structure Id
	<BR/> to be set to these seeded Category Sets.
	<pre>
	select  id_flex_structure_code "Structure Code",
		id_flex_num "New Structure Id"
	from    fnd_id_flex_structures_vl
	where   id_flex_code = ''MCAT''
	and     id_flex_structure_code
		in (''SALES_CATEGORIES'',''CARTONIZATION'');
	</pre>
	5) Use the below update statement to correct the seeded category sets.
	<BR/>   The bind variables
	<BR/>   cat_set_id stands for the category_set_id of the corrupted seeded category set.
	<BR/>   old_structure_id stands for the incorrect structure_id
	<BR/>   currently associated with this category set.
	<BR/>   new_structure_id stands for the New structure Id
	<BR/>   retrieved through the select statement in step 4.
	<pre>
	update mtl_category_sets_b
	set    structure_id = :new_structure_id
	where  category_set_id = :cat_set_id
	and    structure_id = :old_structure_id ;
	</pre>
	6) Commit the transaction.
	<BR/>';
JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
End If;   /* End of Impact and Action */

statusStr := 'SUCCESS';
isFatal := 'FALSE';

JTF_DIAGNOSTIC_COREAPI.BRPrint;
End If; /* End of l_script */
/* End of script 2*/

 <<l_test_end>>
  JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/><BR/>This Health Check test completed as expected <BR/>');
 report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
 reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;

EXCEPTION
 when others then
     JTF_DIAGNOSTIC_COREAPI.errorprint('Error: '||sqlerrm);
     JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('If this error repeats, please contact Oracle Support Services');
     statusStr := 'FAILURE';
     errStr := sqlerrm ||' occurred in script. ';
     fixInfo := 'Unexpected Exception in BOMDGICB.pls';
     isFatal := 'FALSE';
     report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
     reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
END runTest;

PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'Item Categories Data Health Check Details';
END getComponentName;

PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2) IS
BEGIN
descStr := ' This diagnostic test performs a variety of health checks against Item Categories<BR/>
		and provides suggestions on how to solve possible issues.<BR/>
		It is recommended to run this health check periodically. <BR/> ';
END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'Item Categories Data Health Check';
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
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'Script','LOV-oracle.apps.bom.diag.lov.CatHealthLov');
defaultInputValues := tempInput;
EXCEPTION
when others then
defaultInputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
END getDefaultTestParams;

Function getTestMode return INTEGER IS
BEGIN
 return JTF_DIAGNOSTIC_ADAPTUTIL.ADVANCED_MODE;

END getTestMode;

END BOM_DIAGUNITTEST_CATHLCHK;

/
