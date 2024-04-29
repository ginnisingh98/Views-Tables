--------------------------------------------------------
--  DDL for Package Body BOM_DIAGUNITTEST_BILLHLCHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_DIAGUNITTEST_BILLHLCHK" as
/* $Header: BOMDGBIB.pls 120.1 2007/12/26 09:41:58 vggarg noship $ */
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
 sqltxt		VARCHAR2(9999);  -- SQL select statement
 c_username	VARCHAR2(50);   -- accept input for username
 statusStr	VARCHAR2(50);   -- SUCCESS or FAILURE
 errStr		VARCHAR2(4000); -- error message
 fixInfo	VARCHAR2(4000); -- fix tip
 isFatal	VARCHAR2(50);   -- TRUE or FALSE
 num_rows	NUMBER;
 row_limit	NUMBER;
 l_item_id	NUMBER;
 l_org_id	NUMBER;
 l_org_exists	NUMBER;
 l_script    VARCHAR2(20);

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

/*JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('OrgID input :'||l_org_id||' Script: '||l_script);
JTF_DIAGNOSTIC_COREAPI.BRPrint;
*/

-- JTF_DIAGNOSTIC_COREAPI.Line_Out('script: '||l_script);

/* l_script is NOT a mandatory input. If it is not entered, then run all the scripts.
   However if a script name is entered, then validate it for existence. */

	If l_script not in ('UNIT_EFF','IMPLDT_NULL','ALL') Then
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
		where  organization_id=l_org_id;
	Exception
	When others Then
		l_org_exists :=0;
		JTF_DIAGNOSTIC_COREAPI.errorprint('Invalid Organization Id');
		JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(' Please either provide a valid value for the Organization Id or leave it blank.');
		statusStr := 'FAILURE';
		isFatal := 'TRUE';
		fixInfo := ' Please review the error message below and take corrective action.';
		errStr  := ' Invalid value for input field Organization Id ';

		report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
		reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
	End;
End If; /* End of l_org_id is not null */

If (l_org_id is null) or (l_org_exists = 1) Then

/* Script 1 to identify invalid/missing Unit effective component records
   Records of the below three types are fetched.
   (a) Missing from_end_item_unit_number (it is a mandatory column)
   (b) Invalid from_end_item_unit_number
   (c) Invalid To_end_item_unit_number
    Note: Unit numbers are termed invalid if they do not exist in pjm_unit_numbers table.
	  To_end_item_unit_number is not a mandatory column and hence can be null.

   Logic of the Query below:
   Query 1 (fetches records with missing/invalid from_end_item_unit_number AND invalid to_end_item_unit_number)
   Union
   Query 2 (fetches records with missing/invalid from_end_item_unit_number AND Valid to_end_item_unit_number)
   Union
   Query 3 (fetches records with Valid from_end_item_unit_number AND invalid to_end_item_unit_number)

  output rows are limited to row_limt/3 since the accumulated output
  of all the three queries should atmost be row_limit.

*/

If l_script  in ('ALL','UNIT_EFF') Then
   sqltxt :=	   '  	 select mif1.padded_item_number 	 			"Assembly Item Number",		     '||
		   '	 	mp.organization_code   	 				"Organization Code",		     '||
		   '	 	bsb.alternate_bom_designator 				"Alternate Bom Designator",	     '||
		   '	 	bcb.operation_seq_num	 				"Operation Seq Num",		     '||
		   '	 	bcb.item_num			 			"Item Seq Num",			     '||
		   '   	 	mif2.padded_item_number	 				"Component Item",		     '||
		   '	 	decode(bcb.from_end_item_unit_number,null,''*MISSING'', 				     '||
		   '	 	       bcb.from_end_item_unit_number||'' (Invalid)'') 	"From End Item Unit Number",  	     '||
		   '   	 	bcb.to_end_item_unit_number||'' (Invalid)''  		"To End Item Unit Number",	     '||
		   '	 	bcb.component_quantity	 	    			"Component Quantity",		     '||
		   '	 	to_char(bcb.effectivity_date,''DD-MON-YYYY HH24:MI:SS'') "Effectivity Date",		     '||
		   '	 	to_char(bcb.disable_date,''DD-MON-YYYY HH24:MI:SS'')	"Disable Date",			     '||
		   '	 	bcb.change_notice		 		 	"Change Notice",		     '||
		   '	 	bsb.assembly_item_id	 		 		"Assembly Item Id",		     '||
		   '	 	bsb.organization_id		 		 	"Organization Id",		     '||
		   '	 	bsb.bill_sequence_id	 		 		"Bill Sequence Id",		     '||
		   '	 	bcb.component_sequence_id	 	 		"Component Sequence Id"  	     '||
		   '	 from   bom_components_b bcb, bom_structures_b bsb,	  			     '||
		   '	 	   mtl_item_flexfields mif1, mtl_item_flexfields mif2,		  			     '||
		   '	 	   mtl_parameters mp						  			     '||
		   '	 where  bsb.bill_sequence_id = bcb.bill_sequence_id			  			     '||
		   '	 and    bsb.assembly_item_id = mif1.inventory_item_id			  			     '||
		   '	 and    bsb.organization_id  = mif1.organization_id			  			     '||
		   '	 and    bcb.component_item_id = mif2.inventory_item_id			  			     '||
		   '	 and    bsb.organization_id  = mif2.organization_id			  			     '||
		   '	 and    mif1.organization_id  = mp.organization_id			  			     '||
		   '	 and    mif1.effectivity_control = 2					  			     '||
		   '	 and    (   ( bcb.from_end_item_unit_number is null 						     '||
		   '	 	      or 										     '||
		   '	 		 ( bcb.from_end_item_unit_number is not null 					     '||
		   '	 	   	   and not exists 								     '||
		   '	 	   	        (select 1 from pjm_unit_numbers 					     '||
		   '	 	                 where unit_number = bcb.from_end_item_unit_number)			     '||
		   '	 	         ) 										     '||
		   '	 	     )   										     '||
		   '	         and ( bcb.to_end_item_unit_number is not null 						     '||
		   '	 	       and not exists 									     '||
		   '	 	   	      (select 1 from pjm_unit_numbers 						     '||
		   '	 	               where unit_number = bcb.to_end_item_unit_number) 			     '||
	 	   '	 	      ) 										     '||
		   '	 	)											     ';

			if l_org_id is not null then
			   sqltxt :=sqltxt||' and bsb.organization_id =  '||l_org_id;
			end if;
		sqltxt :=sqltxt||' and rownum< '||round(row_limit/3);

  sqltxt :=sqltxt||'	 UNION												     '||
		   '	 select mif1.padded_item_number 				"Assembly Item Number",		     '||
		   '	 	mp.organization_code   		 			"Organization Code",		     '||
		   '	 	bsb.alternate_bom_designator 				"Alternate Bom Designator",	     '||
		   '	 	bcb.operation_seq_num		 			"Operation Seq Num",		     '||
		   '	    	bcb.item_num						"Item Seq Num",			     '||
		   '	 	mif2.padded_item_number		 			"Component Item",		     '||
		   '	 	decode(bcb.from_end_item_unit_number,null,''*MISSING'',					     '||
		   '	 		bcb.from_end_item_unit_number||'' (Invalid)'') 	"From End Item Unit Number",	     '||
		   '	    	bcb.to_end_item_unit_number 	 			"To End Item Unit Number",	     '||
		   '	 	bcb.component_quantity		 			"Component Quantity",		     '||
		   '	 	to_char(bcb.effectivity_date,''DD-MON-YYYY HH24:MI:SS'') "Effectivity Date",		     '||
		   '	 	to_char(bcb.disable_date,''DD-MON-YYYY HH24:MI:SS'')	"Disable Date",			     '||
		   '	 	bcb.change_notice			 		"Change Notice",		     '||
		   '	 	bsb.assembly_item_id		 			"Assembly Item Id",		     '||
		   '	 	bsb.organization_id			 		"Organization Id",		     '||
		   '	 	bsb.bill_sequence_id		 			"Bill Sequence Id",		     '||
		   '	 	bcb.component_sequence_id	 			"Component Sequence Id"  	     '||
		   '	 	from   bom_components_b bcb, bom_structures_b bsb,			     '||
		   '	 		   mtl_item_flexfields mif1, mtl_item_flexfields mif2,				     '||
		   '	 		   mtl_parameters mp								     '||
		   '	 	where  bsb.bill_sequence_id = bcb.bill_sequence_id					     '||
		   '	 	and    bsb.assembly_item_id = mif1.inventory_item_id					     '||
		   '	 	and    bsb.organization_id  = mif1.organization_id					     '||
		   '	 	and    bcb.component_item_id = mif2.inventory_item_id					     '||
		   '	 	and    bsb.organization_id  = mif2.organization_id					     '||
		   '	 	and    mif1.organization_id  = mp.organization_id					     '||
		   '	 	and    mif1.effectivity_control = 2							     '||
		   '	 	and    (   ( bcb.from_end_item_unit_number is null					     '||
		   '	 		     or  ( bcb.from_end_item_unit_number is not null				     '||
		   '	 	   	           and not exists							     '||
		   '	   	            	   (select 1 from pjm_unit_numbers					     '||
		   '	 	                    where unit_number = bcb.from_end_item_unit_number)			     '||
		   '	 	                   ) 									     '||
		   '	 	 	    )										     '||
		   '	 		    and ( bcb.to_end_item_unit_number is null					     '||
		   '	 			  or 									     '||
		   '	 			  ( bcb.to_end_item_unit_number is not null				     '||
		   '	 	   	            and exists								     '||
		   '	 	   	                (select 1 from pjm_unit_numbers					     '||
		   '	 	                         where unit_number = bcb.to_end_item_unit_number)		     '||
		   '	 	                  )									     '||
		   '	 			)  									     '||
		   '	 		 )										     ';

			if l_org_id is not null then
			   sqltxt :=sqltxt||' and bsb.organization_id =  '||l_org_id;
			end if;
			sqltxt :=sqltxt||' and rownum< '||round(row_limit/3);

  sqltxt :=sqltxt||'	 UNION												     '||
		   '	 select mif1.padded_item_number 	 		"Assembly Item Number",	 		     '||
		   '	 	mp.organization_code   	 			"Organization Code",		 	     '||
		   '	 	bsb.alternate_bom_designator 			"Alternate Bom Designator",	 	     '||
		   '	 	bcb.operation_seq_num	 			"Operation Seq Num",		 	     '||
		   '	 	bcb.item_num			 		"Item Seq Num",		 		     '||
		   '	 	mif2.padded_item_number	 			"Component Item",		 	     '||
		   '	 	bcb.from_end_item_unit_number 			"From End Item Unit Number",	 	     '||
		   '	 	bcb.to_end_item_unit_number||'' (Invalid)'' 	"To End Item Unit Number",	 	     '||
		   '	 	bcb.component_quantity	 			"Component Quantity",		 	     '||
		   '	 	to_char(bcb.effectivity_date,''DD-MON-YYYY HH24:MI:SS'')"Effectivity Date",		     '||
		   '	 	to_char(bcb.disable_date,''DD-MON-YYYY HH24:MI:SS'')	"Disable Date",		 		'||
		   '	 	bcb.change_notice		 		"Change Notice",		 	     '||
		   '	 	bsb.assembly_item_id				"Assembly Item Id",		 	     '||
		   '	 	bsb.organization_id		 		"Organization Id",		 	     '||
		   '	 	bsb.bill_sequence_id	 			"Bill Sequence Id",		 	     '||
		   '	 	bcb.component_sequence_id	 		"Component Sequence Id"  	 	     '||
		   '	 from   bom_components_b bcb, bom_structures_b bsb,	 			     '||
		   '	 	   mtl_item_flexfields mif1, mtl_item_flexfields mif2,		 			     '||
		   '	 	   mtl_parameters mp						 			     '||
		   '	 where  bsb.bill_sequence_id = bcb.bill_sequence_id			 			     '||
		   '	 and    bsb.assembly_item_id = mif1.inventory_item_id			 			     '||
		   '	 and    bsb.organization_id  = mif1.organization_id			 			     '||
		   '	 and    bcb.component_item_id = mif2.inventory_item_id			 			     '||
		   '	 and    bsb.organization_id  = mif2.organization_id			 			     '||
		   '	 and    mif1.organization_id  = mp.organization_id			 			     '||
		   '	 and    mif1.effectivity_control = 2					 			     '||
		   '	 and    (   ( bcb.to_end_item_unit_number is not null						     '||
		   '	 	      and not exists									     '||
		   '	 	          (select 1 from pjm_unit_numbers						     '||
		   '	 	           where unit_number = bcb.to_end_item_unit_number)				     '||
		   '	 	    )											     '||
		   '	 	    and ( bcb.from_end_item_unit_number is not null					     '||
		   '	 	          and exists									     '||
		   '	 	              (select 1 from pjm_unit_numbers						     '||
		   '	 	               where unit_number = bcb.from_end_item_unit_number)			     '||
		   '	 	        )										     '||
		   '	        )											     ';

		if l_org_id is not null then
		   sqltxt :=sqltxt||' and bsb.organization_id =  '||l_org_id;
		end if;

		sqltxt :=sqltxt||' and rownum< '||round(row_limit/3);

		num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Unit Effective Components with invalid ''From End Item Unit Number'' or ''To End Item Unit Number'' ');

		If (num_rows = 0) Then	   /* Corrupt Data Not Found for this case*/
			JTF_DIAGNOSTIC_COREAPI.Line_Out('No corrupt data found for this case. <BR/><BR/>');
		ElsIf (num_rows > 0) Then  /* Show Impact and Action only if rows are returned */
		 If (num_rows = row_limit -1 ) Then
			JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows
							 <BR/> to prevent an excessively big output file. <BR/>');
		 End If;
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/>Records of the below three types are fetched.
		   				 <BR/> (a) Missing from_end_item_unit_number (it is a mandatory column).
		   				 <BR/>	  Indicated by word '' *MISSING''.
   						 <BR/> (b) Invalid from_end_item_unit_number.  Indicated by word ''Invalid''.
   						 <BR/> (c) Invalid To_end_item_unit_number. Indicated by word ''Invalid''.
    						 <BR/> Note: Unit numbers are termed invalid if they do not exist
						 <BR/> in pjm_unit_numbers table.
	 					 <BR/> To_end_item_unit_number is not a mandatory column
						 <BR/> and hence can be null. ');

		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/><BR/><u>IMPACT:</u>
		<BR/>Component records get created with corrupt data which
		<BR/>generate error messages while querying the Bills.<BR/><BR/> ');

		JTF_DIAGNOSTIC_COREAPI.ActionErrorLink('<BR/> For fixing the rootcause of this data corruption,
					<BR/> please apply appropriate patches suggested in metalink note : ' , '393085.1', '' );

		reportStr := '<BR/> If Rows are returned with missing/invalid ''From End Item Unit Number''
		<BR/> or ''To End Item Unit Number'' ,
		<BR/> then please follow the below steps for correcting them.
		<BR/> 1) Open (N) Bills of Material > Bills form.
		<BR/> 2) Query for the Assembly Items fetched above.
		<BR/> 3) Query for the particular Component record as identified by
		<BR/> ''Operation Seq Num'', ''Item Num'', ''Component Item'' etc.
		<BR/> 4) Go to ''Unit Effectivity'' tab in Components block.
		<BR/> 4) Go to the ''From''  field or the ''To''  field that has to be corrected.
		<BR/> 5) Correct these values by choosing an appropriate unit number
		<BR/> from the associated Lov.
		<BR/> 6) Save the changes to the bill.
		<BR/> <u>Note</u>: If the number of invalid unit numbers are huge,
		<BR/> then use the Bills Open Interface functionality to correct them.
		<BR/>';
		JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
		End If;   /* End of Impact and Action */

		statusStr := 'SUCCESS';
		isFatal := 'FALSE';

JTF_DIAGNOSTIC_COREAPI.BRPrint;
End If; /* End of l_script */
/* End of script identify components with invalid Unit numbers*/

/* Script 2 - Fetch bills with Null Implementation Date */
If l_script  in ('ALL','IMPLDT_NULL') Then
sqltxt:=	'	select	mif.padded_item_number		"Assembly Item",					   '||
		'		mp.organization_code		"Organization Code",					   '||
		'		bsb.alternate_bom_designator	"Alternate Designator",					   '||
		'		decode(bsb.assembly_type,1,''Manufacturing Bill'',2,''Engineering Bill'')  "Assembly Type",'||
		'		to_char(bsb.implementation_date,''DD-MON-YYYY HH24:MI:SS'')	"Implementation Date",	   '||
		'		bsb.pending_from_ecn		"Pending From ECN",			  		   '||
		'		bsb.assembly_item_id		"Assembly Item Id" ,					   '||
		'		bsb.organization_id		"Organization Id",					   '||
		'		bsb.bill_sequence_id		"Bill Sequence Id",					   '||
		'		bsb.common_bill_sequence_id	"Common Bill Sequence Id"				   '||
		'	from    bom_structures_b bsb, mtl_item_flexfields mif, mtl_parameters mp			   '||
		'	where	mif.inventory_item_id =  bsb.assembly_item_id						   '||
		'	and	mif.organization_id   =  bsb.organization_id						   '||
		'	and	bsb.organization_id  =  mp.organization_id						   '||
		'	and 	bsb.implementation_date is null							   ';

		if l_org_id is not null then
		   sqltxt :=sqltxt||' and bsb.organization_id =  '||l_org_id;
		end if;

		sqltxt :=sqltxt||' and rownum< '||row_limit;
		/* sqltxt := sqltxt || ' and rownum< 5'; -- temporarily limiting the records to 5  */
		sqltxt :=sqltxt||' order by mp.organization_code, mif.padded_item_number,bsb.alternate_bom_designator';

		num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Bills with Null Implementation Date ');

		If (num_rows = 0) Then	   /* Corrupt Data Not Found for this case*/
			JTF_DIAGNOSTIC_COREAPI.Line_Out('No corrupt data found for this case. <BR/><BR/>');
		ElsIf (num_rows > 0) Then  /* Show Impact and Action only if rows are returned */
			If (num_rows = row_limit -1 ) Then
			JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows
							 <BR/> to prevent an excessively big output file. <BR/>');
			End If;

		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/><u>IMPACT:</u>
		<BR/> Components added to these bills will appear
		<BR/> to be unimplemented when querying the bill.');

		reportStr := '<BR/><BR/><u>ACTION</u>:
		<BR/> If bills are returned with Null Implementation Date,
		<BR/>then please follow the below steps for correcting them.
		<BR/><I><u>Important:</u> Try this action plan on a TEST INSTANCE first.</I>
		<BR/>(1) Take a backup of entire bom_structures_b table.
		<BR/>(2) Use the below update statement to correct these bills.
<pre>	update bom_structures_b
	set    implementation_date = creation_date
	where  implementation_date is null;
</pre>
		(3) Make sure that the total number of records updated
		<BR/>are same as the number of records fetched above.
		<BR/>(4) Commit the transaction.
		<BR/>';
		JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);

		End If;   /* End of Impact and Action */

		statusStr := 'SUCCESS';
		isFatal := 'FALSE';

JTF_DIAGNOSTIC_COREAPI.BRPrint;
 End If; /* End of l_script */
/* End of script 2- Bills with NULL Implementation Date */

 <<l_test_end>>
 JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/><BR/>This Health Check test completed as expected <BR/>');
 report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
 reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
 End If; /* End of l_org_id is null or l_org_exists=1 */

 EXCEPTION
 when others then
     JTF_DIAGNOSTIC_COREAPI.errorprint('Error: '||sqlerrm);
     JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('If this error repeats, please contact Oracle Support Services');
     statusStr := 'FAILURE';
     errStr := sqlerrm ||' occurred in script. ';
     fixInfo := 'Unexpected Exception in BOMDGBIB.pls';
     isFatal := 'FALSE';
     report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
     reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
END runTest;

PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'Bills Data Health Check Details';
END getComponentName;

PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2) IS
BEGIN
descStr := ' This diagnostic test performs a variety of health checks against Bills <BR/>
		and provides suggestions on how to solve possible issues.<BR/>
		It is recommended to run this health check periodically. ';
END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'Bills Data Health Check';
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
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'Script','LOV-oracle.apps.bom.diag.lov.BomHealthLov');
defaultInputValues := tempInput;
EXCEPTION
when others then
defaultInputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
END getDefaultTestParams;

Function getTestMode return INTEGER IS
BEGIN
 return JTF_DIAGNOSTIC_ADAPTUTIL.ADVANCED_MODE;

END getTestMode;

END BOM_DIAGUNITTEST_BILLHLCHK;

/
