--------------------------------------------------------
--  DDL for Package Body INV_DIAG_ORG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DIAG_ORG" as
/* $Header: INVDORGB.pls 120.0.12000000.1 2007/06/22 01:10:32 musinha noship $ */
PROCEDURE init is
BEGIN
-- test writer
null;
END init;

PROCEDURE cleanup IS
BEGIN
-- test writer could insert special cleanup code here
NULL;
END cleanup;

PROCEDURE runtest(inputs IN JTF_DIAG_INPUTTBL,
                  report OUT NOCOPY JTF_DIAG_REPORT,
                  reportClob OUT NOCOPY CLOB) IS

reportStr LONG;
counter NUMBER;
dummy_v2t JTF_DIAGNOSTIC_COREAPI.v2t;
c_userid VARCHAR2(50);
statusStr VARCHAR2(50);
errStr VARCHAR2(4000);
fixInfo VARCHAR2(4000);
isFatal VARCHAR2(50);
dummy_num NUMBER;
sqltxt VARCHAR2 (9999);
l_org_id NUMBER;
l_org_code VARCHAR2(3);
l_txn_id   NUMBER;

BEGIN

JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;
--JTF_DIAGNOSTIC_COREAPI.line_out('this also writes to the clob');
l_org_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('OrgId',inputs);

INV_DIAG_GRP.g_inv_diag_item_tbl.delete;
INV_DIAG_GRP.g_inv_diag_item_tbl(1).org_id := l_org_id;

if l_org_id is not null then

   sqltxt := 'SELECT mp.organization_code "Org Code"  '||
             ',mp.organization_id "Organization Id"  '||
             ',mpm.organization_code "Master Org Code"  '||
             ',mp.master_organization_id "Master Organization Id"  '||
             ',mpc.organization_code "Cost Org Code"  '||
             ',mp.cost_organization_id "Cost Organization Id"  '||
             ',mp.wms_enabled_flag "WMS Enabled"  '||
             ',DECODE(mp.negative_inv_receipt_code,1,''Yes'', ''No'') "Negative|Balances|Allowed" '||
             ',DECODE(mp.serial_number_generation,1,''At organization level'', 2,''At item level'', 3,''User Defined'', '||
             '        mp.serial_number_generation) "Serial Number|Generation"  '||
             ',DECODE(mp.lot_number_uniqueness,1,''Across items'', 2,''No uniqueness'',  mp.lot_number_uniqueness) "Lot Number|Uniqueness"   '||
             ',DECODE(mp.lot_number_generation,1,''At organization level'', 2,''At item level'',   3,''User Defined'',  '||
             '        mp.lot_number_generation) "Lot Number Generation"  '||
             ',DECODE(mp.serial_number_type,1,''Unique within inventory model and items'', 2,''Unique within organization'',   3,''Unique across organizations'',  '||
             '        4, ''Unique within inventory items'', mp.serial_number_type ) "Serial Number Type"  '||
             ',DECODE(mp.stock_locator_control_code,1,''None'', 2,''Prespecified'',  3,''Dynamic entry'',   4,''At subinventory level'',  5,''At item level'',  '||
             '        mp.stock_locator_control_code) "Locator|Control"  '||
             ',DECODE(mp.primary_cost_method,1,''Standard'', 2,''Average'', 3,''Periodic Average'',4,''Periodic Incremental LIFO'', 5,''FIFO'',  6,''LIFO'', mp.primary_cost_method) "Primary Cost Method" '||
             ',mp.default_cost_group_id "Default Cost Group Id"  '||
             ',mp.wsm_enabled_flag "WSM Enabled"  '||
             ',mp.process_enabled_flag "Process Enabled"  '||
             ',DECODE( TO_CHAR( NVL(mp.project_reference_enabled, 2)),''1'', ''Yes'', ''2'', ''No'' , TO_CHAR( mp.project_reference_enabled ) )|| '' ('' ||mp.project_reference_enabled||'')'' "Project Reference Enabled" '||
             ',mp.eam_enabled_flag "EAM|Enabled " '||
             ',mp.consigned_flag "Consigned|VMI Stock" '||
     'FROM mtl_parameters mp,mtl_parameters mpc  '||
     '    ,mtl_parameters mpm  '||
    'WHERE mp.cost_organization_id=mpc.organization_id  '||
     ' AND mp.master_organization_id=mpm.organization_id  '||
     ' AND mp.organization_id IN   '||
     '      ( SELECT organization_id  '||
     '          FROM mtl_parameters  '||
     '         WHERE organization_id = '||l_org_id||
     '        UNION  '||
     '        SELECT master_organization_id  '||
     '          FROM mtl_parameters  '||
     '         WHERE organization_id ='||l_org_id||' )'||
     ' ORDER BY mp.organization_code';

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Organization Parameters');
   statusStr := 'SUCCESS';
   isFatal := 'FALSE';

   sqltxt := 'SELECT ORGANIZATION_CODE, organization_name, operating_unit, gl.name "Set of Books" '||
             'FROM org_organization_definitions org, gl_sets_of_books gl '||
             'WHERE organization_id =  '||l_org_id||
             'and org.SET_OF_BOOKS_ID=gl.set_of_books_id';
   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Organization Information');
   statusStr := 'SUCCESS';
   isFatal := 'FALSE';

   sqltxt := 'select mg.concatenated_segments "Alias", gl.concatenated_segments "Account" '||
             ', mg.description "Description", mg.enabled_flag "Enabled" '||
             ', to_char(mg.effective_date, ''DD-Mon-RRRR'') "Effective On" '||
             ', to_char(mg.end_date_active , ''DD-Mon-RRRR'') "Effective To" '||
             'from mtl_generic_dispositions_kfv mg, gl_code_combinations_kfv gl '||
             'where mg.distribution_account = gl.code_combination_id '||
             'and mg.organization_id=  '||l_org_id;
   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Account Aliases');
   statusStr := 'SUCCESS';
   isFatal := 'FALSE';


   sqltxt := 'select period_name "Period", period_start_date "From", schedule_close_date "To", period_close_date "Close Date", decode(open_flag, ''Y'', ''Open'', ''Closed'') "Status" '||
             'from org_acct_periods where organization_id = '||l_org_id||
             'order by acct_period_id desc ';
   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Inventory Accounting Periods');
   statusStr := 'SUCCESS';
   isFatal := 'FALSE';

   sqltxt := 'select alias_name "Alias", gl.code_combination_id "Account Id" '||
             ', ff.concatenated_segments "Account", ff.enabled_flag "Enabled" '||
             ', to_char(gl.start_date_active, ''DD-Mon-RRRR'') "Effective On" '||
             ', to_char(gl.end_date_active, ''DD-Mon-RRRR'') "Effective To" '||
             ', ff.description "Description" '||
             'from fnd_shorthand_flex_aliases ff, gl_code_combinations_kfv gl '||
             'where id_flex_code =''GL#'' and application_id=101 and ID_FLEX_NUM=''101'' '||
             'and gl.chart_of_accounts_id = ff.id_flex_num '||
             'and gl.concatenated_segments=ff.concatenated_segments' ;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Operations Account');
   statusStr := 'SUCCESS';
   isFatal := 'FALSE';

else

    JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Org Id or Org Code input is requred!');
    statusStr := 'FAILURE';
    errStr := 'This test failed as: no input';
    fixInfo := 'Put informative fix info. here';
    isFatal := 'SUCCESS';

end if;

report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;

EXCEPTION
when others then
-- this should never happen
JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('Exception Occurred In RUNTEST');
reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
raise;

END runTest;

PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'Organization Information';
END getComponentName;

PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2) IS
BEGIN
descStr := 'Display Inventory organization information ';
END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'Organization Data Collection';
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
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'OrgId','LOV-oracle.apps.inv.diag.lov.OrganizationLov');
defaultInputValues := tempInput;
EXCEPTION
when others then
defaultInputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
END getDefaultTestParams;

Function getTestMode return INTEGER IS
BEGIN
 return JTF_DIAGNOSTIC_ADAPTUTIL.ADVANCED_MODE;

END getTestMode;

END;

/
