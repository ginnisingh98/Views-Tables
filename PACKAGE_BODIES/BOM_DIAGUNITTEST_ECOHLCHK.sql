--------------------------------------------------------
--  DDL for Package Body BOM_DIAGUNITTEST_ECOHLCHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_DIAGUNITTEST_ECOHLCHK" as
/* $Header: BOMDGECB.pls 120.1 2007/12/26 09:47:19 vggarg noship $ */
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
		JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(' Please either provide a valid value for the Organization Id or leave it blank. ');
		statusStr := 'FAILURE';
		isFatal := 'TRUE';
		fixInfo := ' Please review the error message below and take corrective action.';
		errStr  := ' Invalid value for input field Organization Id ';

		report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
		reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
	End;
End If; /* End of l_org_id is not null */

If (l_org_id is null) or (l_org_exists = 1) Then

/* Script 1 - Fetch ECOs whose header does not show implemented status though
   all its revised items are implemented. */

sqltxt :='       select eec.change_notice 		  "ECO Number",			'||
	'		mp.organization_code   	   	  "Organization Code",		'||
	'		ecsvl.status_name		  "Current Status Name",	'||
	'	   	eec.status_type 		  "Current Status Type",	'||
	'		eec.change_id			  "Change Id",			'||
	'		eec.organization_id		  "Organization Id"          	'||
	'        from    eng_engineering_changes eec, mtl_parameters mp			'||
	'		 ,eng_change_statuses_vl ecsvl					'||
	'        where   eec.organization_id = mp.organization_id			'||
	'		and     eec.APPROVAL_STATUS_TYPE <> 4  				'||
	'		and     eec.status_type not in (5,6)				'||
	'		and	eec.status_type = ecsvl.status_code(+)			'||
	'        and not exists (select 1 from eng_revised_items eri			'||
	'                   	where eri.change_notice = eec.change_notice		'||
	'               	and   eri.organization_id = eec.organization_id		'||
        '          		and   eri.status_type not in (5,6))			'||
	'        and     exists (select 1 from eng_revised_items eri1			'||
	'                   	where eri1.change_notice = eec.change_notice		'||
	'			and eri1.organization_id = eec.organization_id		'||
	'			and eri1.status_type = 6)				';

	if l_org_id is not null then
	   sqltxt :=sqltxt||' and eec.organization_id =  '||l_org_id;
	end if;

	sqltxt :=sqltxt||' and rownum< '||row_limit;
	sqltxt :=sqltxt||' order by mp.organization_code, eec.change_notice';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' ECOs with non ''Implemented'' Status though all their Revised Items are in ''Implemented'' Status');

	If (num_rows = 0) Then	   /* Corrupt Data Not Found for this case*/
		JTF_DIAGNOSTIC_COREAPI.Line_Out('No corrupt data found for this case. <BR/><BR/>');
	ElsIf (num_rows > 0) Then  /* Show Impact and Action only if rows are returned */
	 If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows
						 <BR/> to prevent an excessively big output file. <BR/>');
	 End If;
	JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/><u>IMPACT:</u>
	<BR/> The discrepency between the ECO Header Status and
	<BR/> its Revised Items Statuses can mislead the users.
	<BR/> Any reports based on the Eco Header status will report wrong data. <BR/><BR/> ');

	JTF_DIAGNOSTIC_COREAPI.ActionErrorLink('<BR/> Please apply appropriate patches suggested in metalink note : ' , '393085.1', '' );

	reportStr := '<BR/> If any ECOs are fetched above,
	<BR/> then please follow the below steps to correct them.
	<BR/> (1) Please apply the patch suggested in above metalink  Note.
	<BR/> Please read the patch description carefully before applying it.
	<BR/> (2) Follow one of the below approaches for correcting the ECOs.
	<BR/> 	 Approach 1:
	<BR/>	 (a) Open (N) Engineering > ECOs > ECOs form.
	<BR/>	 (b) Query for the ECO to be corrected.
	<BR/>	 (c) Use (M) Tools > Implement to implement this ECO.
	<BR/>	 (d) Wait for the ''Engineering Change Order Implementation''
	<BR/>	     concurrent program to complete successfully.
	<BR/>	 (e) Requery the ECO.
	<BR/>	 (f) ECO Header Status should now show ''Implemented''.
	<BR/>
	<BR/> 	 Approach 2: Follow this approach if the number of ECOs
	<BR/>	 to be corrected are huge.
	<BR/>	 (a) Open (N) Engineering > ECOs > ECOs form.
	<BR/>	 (b) Query for the ECO to be corrected.
	<BR/>	 (c) Use (M) Tools > Schedule to schedule this ECO.
	<BR/>	 (d) Repeat steps b and c for all the ECOs to be corrected.
	<BR/>	 (e) Use (N) Engineering > Setup > ''Auto Implement'' feature
	<BR/>	     to auto implement all the scheduled ECOs.
	<BR/>';
	JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
	End If;   /* End of Impact and Action */

	statusStr := 'SUCCESS';
	isFatal := 'FALSE';
/* End of Script 1 */

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
     fixInfo := 'Unexpected Exception in BOMDGECB.pls';
     isFatal := 'FALSE';
     report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
     reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;

END runTest;

PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'ECOs Data Health Check Details';
END getComponentName;

PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2) IS
BEGIN
descStr := ' This diagnostic test performs a variety of health checks against ECOs <BR/>
		and provides suggestions on how to solve possible issues.<BR/>
		It is recommended to run this health check periodically. ';
END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'ECOs Data Health Check';
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

END BOM_DIAGUNITTEST_ECOHLCHK;

/
