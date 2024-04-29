--------------------------------------------------------
--  DDL for Package Body BOM_DIAGUNITTEST_RTGHLCHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_DIAGUNITTEST_RTGHLCHK" as
/* $Header: BOMDGRTB.pls 120.1 2007/12/26 09:56:14 vggarg noship $ */
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
 row_limit	NUMBER;
 l_item_id	NUMBER;
 l_org_id	NUMBER;
 l_org_exists	NUMBER;
BEGIN
JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;

/* Set Row Limit to 1000 (i.e.) Max Number of records to be fetched by each sql*/
 row_limit :=1000;
 l_org_exists :=0; /* Initialize to zero */

-- accept input
l_org_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('OrgId',inputs);

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
		fixInfo := ' Please review the error message below and take corrective action. ';
		errStr  := ' Invalid value for input field Organization Id ';

		report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
		reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
	End;
End If; /* End of l_org_id is not null */

If (l_org_id is null) or (l_org_exists = 1) Then

/* script 1- Orphan Rtg Rev Records: Routing Revisions exist but routings do not exist. */
sqltxt := '	select	mif.item_number "Item Number", mp.organization_code "Organization Code",		'||
 	  '		mrir.process_revision "Routing Revision",						'||
	  '		to_char(mrir.effectivity_date,''DD-MON-YYYY HH24:MI:SS'') "Effectivity Date",		'||
	  '		to_char(mrir.implementation_date,''DD-MON-YYYY HH24:MI:SS'') "Implementation Date",	'||
	  '		mrir.change_notice "ECO Number",							'||
	  '		mif.inventory_item_id "Item Id", mrir.organization_id "Organization Id",		'||
	  '		mrir.revised_item_sequence_id "Revised Item Seq Id"					'||
	  '	from    mtl_item_flexfields mif, mtl_rtg_item_revisions mrir, mtl_parameters mp			'||
	  '	where   mif.inventory_item_id=mrir.inventory_item_id						'||
	  '	and     mif.organization_id  =mrir.organization_id						'||
	  '	and	mp.organization_id   =mif.organization_id						'||
	  '	and     mrir.process_revision is not null							'||
	  '	and     mrir.change_notice is null								'||
	  '	and     mrir.revised_item_sequence_id is null							'||
	  '	and     not exists										'||
	  '		(select 1 from bom_operational_routings bor						'||
	  '		 where bor.assembly_item_id=mrir.inventory_item_id					'||
          '		 and   bor.organization_id =mrir.organization_id )					';

if l_org_id is not null then
   sqltxt :=sqltxt||' and mrir.organization_id =  '||l_org_id;
end if;

  sqltxt :=sqltxt||' and rownum< '||row_limit;
  sqltxt :=sqltxt||' order by mp.organization_code, mif.item_number, mrir.process_revision ';

num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Orphan Routing Revisions - Routing Revisions exist for non-existent Routings');

If (num_rows = 0) Then	   /* Corrupt Data Not Found for this case*/
	JTF_DIAGNOSTIC_COREAPI.Line_Out('No corrupt data found for this case. <BR/><BR/>');
ElsIf (num_rows > 0) Then  /* Show Impact and Action only if rows are returned */
 If (num_rows = row_limit -1 ) Then
	JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows
					 <BR/> to prevent an excessively big output file. <BR/>');
 End If;
 JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/><u>IMPACT:</u>
 <BR/> Users will not be able to create Routings for these items. ');

reportStr := '<BR/><BR/><u>ACTION</u>:
<BR/><I><u>Important:</u> Try this action plan on a TEST INSTANCE first.</I>
<BR/>Please follow below steps to delete these routing revision records.
<BR/>(1) Take a backup of entire mtl_rtg_item_revisions table.
<BR/>(2) Use the below script to delete these orphan records.
<PRE>
delete from mtl_rtg_item_revisions
where  inventory_item_id in
       (select mif.inventory_item_id
	from    mtl_item_flexfields mif,
		mtl_rtg_item_revisions mrir
where  mif.inventory_item_id=mrir.inventory_item_id
and    mif.organization_id  =mrir.organization_id
and    mrir.process_revision is not null
and    mrir.change_notice is null
and    mrir.revised_item_sequence_id is null
and    not exists
   (select 1 from bom_operational_routings bor
    where bor.assembly_item_id=mrir.inventory_item_id
    and   bor.organization_id =mrir.organization_id )
   );
 </PRE>
(3) Make sure that the total number of records deleted
<BR/>are same as the number of records fetched above.
<BR/>(4) Commit the transaction.
<BR/>';
JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
End If;   /* End of Impact and Action */

statusStr := 'SUCCESS';
isFatal := 'FALSE';

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
     fixInfo := 'Unexpected Exception in BOMDGRTB.pls';
     isFatal := 'FALSE';
     report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
     reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
END runTest;

PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'Routings Data Health Check Details';
END getComponentName;

PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2) IS
BEGIN
descStr := ' This diagnostic test performs a variety of health checks against Routings <BR/>
		and provides suggestions on how to solve possible issues.<BR/>
		It is recommended to run this health check periodically. ';
END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'Routings Data Health Check';
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
defaultInputValues := tempInput;
EXCEPTION
when others then
defaultInputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
END getDefaultTestParams;

Function getTestMode return INTEGER IS
BEGIN
 return JTF_DIAGNOSTIC_ADAPTUTIL.ADVANCED_MODE;

END getTestMode;

END BOM_DIAGUNITTEST_RTGHLCHK;

/
