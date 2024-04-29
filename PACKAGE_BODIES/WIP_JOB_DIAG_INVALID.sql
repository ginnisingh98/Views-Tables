--------------------------------------------------------
--  DDL for Package Body WIP_JOB_DIAG_INVALID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_JOB_DIAG_INVALID" as
/* $Header: WIPDD01B.pls 120.0.12000000.1 2007/07/10 09:32:53 mraman noship $ */
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
BEGIN
         WIP_DIAG_JOB_SCH_HC.invalid_job_def_job(inputs,
                  report,
                  reportClob);
exception
  when others then
       raise_application_error (-20500, 'Error in test Invalid Job/Schedule ' || sqlerrm) ;
END runTest;

PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'Job/Schedule Health Check';
END getComponentName;

PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2) IS
BEGIN
   descStr := 'This health check diagnostic identifies potential data inconsistency in jobs/schedules.<BR>'||
              'Run this diagnostic to find out invalid data for jobs/schedules.<BR>' ||
              'Please see the diagnostic output for recommended actions.<BR>' ||
              'It is recommended to run this health check periodically.<BR>';
END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'Invalid Job Definition';
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
  tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'Job Id','LOV-oracle.apps.wip.diag.lov.JobLov');
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
