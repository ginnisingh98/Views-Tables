--------------------------------------------------------
--  DDL for Package Body WIP_DAT_DIAG_REP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_DAT_DIAG_REP" as
/* $Header: WIPDC02B.pls 120.1 2008/05/01 03:56:38 shjindal noship $ */
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
 dummy_num   NUMBER;
 row_limit   NUMBER;
 l_job_name  VARCHAR2(200);
 l_org_id    NUMBER;
 l_job_id    NUMBER;
 l_line_id    NUMBER;
 l_rep_schedule_id    NUMBER;
BEGIN

JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;

-- accept input
if ((ltrim(JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('Organization Id',inputs),'0123456789') is null) and
    (ltrim(JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('Assembly Id',inputs),'0123456789') is null) and
    (ltrim(JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('Line Id',inputs),'0123456789') is null) and
    (ltrim(JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('Repetitive Id',inputs),'0123456789')is null)) then

    l_org_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('Organization Id',inputs);
	l_job_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('Assembly Id',inputs);
	l_line_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('Line Id',inputs);
	l_rep_schedule_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('Repetitive Id',inputs);

else
   l_rep_schedule_id := null;

end if;

if (l_rep_schedule_id  is NULL or l_job_id is NULL or l_line_id is NULL) then

       JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('<BR>Parameter input is required.');
       statusStr := 'FAILURE';
       errStr := 'This test failed with : no/incorrect input';
       if l_rep_schedule_id IS NULL then
          fixInfo := 'Please select Repetitive Schedule for which output is desired.';
       elsif l_job_id is NULL then
          fixInfo := 'Please select Repetitive Assembly  for which output is desired.';
       elsif l_line_id IS NULL then
          fixInfo := 'Please select Repetitive Line  for which output is desired.';
       end if ;
       isFatal := 'FALSE';
 <<l_test_end>>
 report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
 reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;

else

  WIP_DIAG_DATA_COLL.repetitive(l_job_id, l_line_id, l_rep_schedule_id);

  reportStr := '<BR>The output generated gives you the details regarding a Repetitive Item';
  JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);


 <<l_test_end>>
 statusStr := 'SUCCESS';
 report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
 reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
end if ;

EXCEPTION
  when others then
    JTF_DIAGNOSTIC_COREAPI.errorprint('Error: '||sqlerrm);
    JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('This is the exception handler');
    statusStr := 'FAILURE';
    errStr := sqlerrm ||' occurred in script Exception handled';
    fixInfo := 'Unexpected Exception in WIPDC02B.pls';
    isFatal := 'FALSE';
    report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
    reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;


END runTest;

PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'Repetitive';
END getComponentName;

PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2) IS
BEGIN
descStr := 'This data collector retrieves all relevant details of a particular repetitive schedule.<BR>'||
           'Run this data collector and upload the resulting output when opening a service request in this area.';

END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'Repetitive';
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
  tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput, 'Organization Id', 'LOV-oracle.apps.inv.diag.lov.OrganizationLov');
  tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'Assembly Id','LOV-oracle.apps.wip.diag.lov.RepAssyLov');
  tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput, 'Line Id', 'LOV-oracle.apps.wip.diag.lov.LineLov');
  tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput, 'Repetitive Id', 'LOV-oracle.apps.wip.diag.lov.RepSchLov');
  defaultInputValues := tempInput;

EXCEPTION
  when others then
     defaultInputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
END getDefaultTestParams;

Function getTestMode return INTEGER IS
BEGIN
 return JTF_DIAGNOSTIC_ADAPTUTIL.ADVANCED_MODE; /* Bug 5735526 */

END getTestMode;

END;

/
