--------------------------------------------------------
--  DDL for Package Body INV_DIAG_PHY_INV_DUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DIAG_PHY_INV_DUMP" as
/* $Header: INVDA07B.pls 120.0.12000000.1 2007/06/22 00:44:32 musinha noship $ */

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
                  report OUT NOCOPY  JTF_DIAG_REPORT,
                  reportClob OUT NOCOPY  CLOB) IS

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
l_item_id NUMBER;
row_limit NUMBER;
l_script  VARCHAR2(30);


BEGIN

   JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
   JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
   JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;
   --JTF_DIAGNOSTIC_COREAPI.line_out('this also writes to the clob');

   row_limit := INV_DIAG_GRP.g_max_row;

   l_org_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('OrgId',inputs);
   l_item_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('ItemId',inputs);
   l_script :=JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('ScriptName',inputs);

   IF l_script = 'MPA_DUMP' THEN

      sqltxt := ' SELECT' ||
                ' MPA.ADJUSTMENT_ID,' ||
                ' mp.organization_code || ''('' || mpa.organization_id ||'')'' "Organization|Code (Id)", ' ||
                ' MPA.PHYSICAL_INVENTORY_ID,' ||
             ' mif.item_number || ''(''|| mif.inventory_item_id || '')'' "Item (Id)", ' ||
                ' MPA.SUBINVENTORY_NAME,' ||
                ' MPA.SYSTEM_QUANTITY,' ||
                ' MPA.LAST_UPDATE_DATE,' ||
                ' MPA.LAST_UPDATED_BY,' ||
                ' MPA.CREATION_DATE,' ||
                ' MPA.CREATED_BY,' ||
                ' MPA.LAST_UPDATE_LOGIN,' ||
                ' MPA.COUNT_QUANTITY,' ||
                ' MPA.ADJUSTMENT_QUANTITY,' ||
                ' MPA.REVISION,' ||
                ' MPA.LOCATOR_ID,' ||
                ' MPA.LOT_NUMBER,' ||
                ' MPA.LOT_EXPIRATION_DATE,' ||
                ' MPA.SERIAL_NUMBER,' ||
                ' MPA.ACTUAL_COST,' ||
                ' MPA.APPROVAL_STATUS,' ||
                ' MPA.APPROVED_BY_EMPLOYEE_ID,' ||
                ' MPA.AUTOMATIC_APPROVAL_CODE,' ||
                ' MPA.GL_ADJUST_ACCOUNT,' ||
                ' MPA.REQUEST_ID,' ||
                ' MPA.PROGRAM_APPLICATION_ID,' ||
                ' MPA.PROGRAM_ID,' ||
                ' MPA.PROGRAM_UPDATE_DATE,' ||
                ' MPA.LOT_SERIAL_CONTROLS,' ||
                ' MPA.TEMP_APPROVER,' ||
                ' MPA.PARENT_LPN_ID,' ||
                ' MPA.OUTERMOST_LPN_ID,' ||
                ' MPA.COST_GROUP_ID' ||
                ' FROM MTL_PHYSICAL_ADJUSTMENTS MPA, MTL_PARAMETERS mp, MTL_ITEM_FLEXFIELDS mif ' ||
                ' WHERE MPA.ORGANIZATION_ID = mp.organization_id ' ||
                ' AND MPA.INVENTORY_ITEM_ID = mif.inventory_item_id(+) ' ||
                ' AND MPA.ORGANIZATION_ID = mif.organization_id(+) ' ;

       IF l_org_id IS NOT NULL THEN
          IF l_item_id IS NOT NULL THEN
             sqltxt := sqltxt || ' AND mpa.organization_id = ' || l_org_id || ' AND mpa.inventory_item_id = ' || l_item_id || ' AND ROWNUM < ' || row_limit ;
          ELSE
             sqltxt := sqltxt || ' AND mpa.organization_id = ' || l_org_id || ' AND ROWNUM < ' || row_limit ;
          END IF;

       ELSE
          IF l_item_id IS NOT NULL THEN
             sqltxt := sqltxt || ' AND mpa.inventory_item_id = ' || l_item_id  || ' AND ROWNUM < ' || row_limit ;
          ELSE
             sqltxt := sqltxt || ' AND ROWNUM < ' || row_limit ;
          END IF;

       END IF;
       dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Dump of Physical Inventory Adjustments');

    ELSIF l_script = 'MPIT_DUMP' THEN
       sqltxt := ' SELECT' ||
                 ' MPIT.TAG_ID,' ||
                 ' MPIT.PHYSICAL_INVENTORY_ID,' ||
                 ' mp.organization_code || ''('' || mpit.organization_id ||'')'' "Organization|Code (Id)", ' ||
                 ' MPIT.LAST_UPDATE_DATE,' ||
                 ' MPIT.LAST_UPDATED_BY,' ||
                 ' MPIT.CREATION_DATE,' ||
                 ' MPIT.CREATED_BY,' ||
                 ' MPIT.LAST_UPDATE_LOGIN,' ||
                 ' MPIT.VOID_FLAG,' ||
                 ' MPIT.TAG_NUMBER,' ||
                 ' MPIT.ADJUSTMENT_ID,' ||
                 ' mif.item_number || ''(''|| mif.inventory_item_id || '')'' "Item (Id)", ' ||
                 ' MPIT.TAG_QUANTITY,' ||
                 ' MPIT.TAG_UOM,' ||
                 ' MPIT.TAG_QUANTITY_AT_STANDARD_UOM,' ||
                 ' MPIT.STANDARD_UOM,' ||
                 ' MPIT.SUBINVENTORY,' ||
                 ' MPIT.LOCATOR_ID,' ||
                 ' MPIT.LOT_NUMBER,' ||
                 ' MPIT.LOT_EXPIRATION_DATE,' ||
                 ' MPIT.REVISION,' ||
                 ' MPIT.SERIAL_NUM,' ||
                 ' MPIT.COUNTED_BY_EMPLOYEE_ID,' ||
                 ' MPIT.LOT_SERIAL_CONTROLS,' ||
                 ' MPIT.ATTRIBUTE_CATEGORY,' ||
                 ' MPIT.ATTRIBUTE1,' ||
                 ' MPIT.ATTRIBUTE2,' ||
                 ' MPIT.ATTRIBUTE3,' ||
                 ' MPIT.ATTRIBUTE4,' ||
                 ' MPIT.ATTRIBUTE5,' ||
                 ' MPIT.ATTRIBUTE6,' ||
                 ' MPIT.ATTRIBUTE7,' ||
                 ' MPIT.ATTRIBUTE8,' ||
                 ' MPIT.ATTRIBUTE9,' ||
                 ' MPIT.ATTRIBUTE10,' ||
                 ' MPIT.ATTRIBUTE11,' ||
                 ' MPIT.ATTRIBUTE12,' ||
                 ' MPIT.ATTRIBUTE13,' ||
                 ' MPIT.ATTRIBUTE14,' ||
                 ' MPIT.ATTRIBUTE15,' ||
                 ' MPIT.REQUEST_ID,' ||
                 ' MPIT.PROGRAM_APPLICATION_ID,' ||
                 ' MPIT.PROGRAM_ID,' ||
                 ' MPIT.PROGRAM_UPDATE_DATE,' ||
                 ' MPIT.PARENT_LPN_ID,' ||
                 ' MPIT.OUTERMOST_LPN_ID,' ||
                 ' MPIT.COST_GROUP_ID ' ||
                 ' FROM MTL_PHYSICAL_INVENTORY_TAGS MPIT, MTL_PARAMETERS mp, MTL_ITEM_FLEXFIELDS mif ' ||
                 ' WHERE mpit.ORGANIZATION_ID = mp.organization_id ' ||
                 ' AND mpit.INVENTORY_ITEM_ID = mif.inventory_item_id(+) ' ||
                 ' AND mpit.ORGANIZATION_ID = mif.organization_id(+) ' ;

        IF l_org_id IS NOT NULL THEN
           IF l_item_id IS NOT NULL THEN
              sqltxt := sqltxt || ' AND mpit.organization_id = ' || l_org_id || ' AND mpit.inventory_item_id = ' || l_item_id || ' AND ROWNUM < ' || row_limit ;
           ELSE
              sqltxt := sqltxt || ' AND mpit.organization_id = ' || l_org_id || ' AND ROWNUM < ' || row_limit ;
           END IF;

        ELSE
           IF l_item_id IS NOT NULL THEN
              sqltxt := sqltxt || ' AND mpit.inventory_item_id = ' || l_item_id  || ' AND ROWNUM < ' || row_limit ;
           ELSE
              sqltxt := sqltxt || ' AND ROWNUM < ' || row_limit ;
           END IF;

        END IF;

        dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Details of Physical Inventory tags');

    ELSIF  l_script = 'MPI_DUMP' THEN
       sqltxt := ' SELECT ' ||
                 ' MPI.PHYSICAL_INVENTORY_ID,' ||
                 ' mp.organization_code || ''('' || mpi.organization_id ||'')'' "Organization|Code (Id)", ' ||
                 ' MPI.LAST_UPDATE_DATE,' ||
                 ' MPI.LAST_UPDATED_BY,' ||
                 ' MPI.CREATION_DATE,' ||
                 ' MPI.CREATED_BY,' ||
                 ' MPI.LAST_UPDATE_LOGIN,' ||
                 ' MPI.PHYSICAL_INVENTORY_DATE,' ||
                 ' MPI.LAST_ADJUSTMENT_DATE,' ||
                 ' MPI.TOTAL_ADJUSTMENT_VALUE,' ||
                 ' MPI.DESCRIPTION,' ||
                 ' MPI.FREEZE_DATE,' ||
                 ' MPI.PHYSICAL_INVENTORY_NAME,' ||
                 ' MPI.APPROVAL_REQUIRED,' ||
                 ' MPI.ALL_SUBINVENTORIES_FLAG,' ||
                 ' MPI.NEXT_TAG_NUMBER,' ||
                 ' MPI.TAG_NUMBER_INCREMENTS,' ||
                 ' MPI.DEFAULT_GL_ADJUST_ACCOUNT,' ||
                 ' MPI.REQUEST_ID,' ||
                 ' MPI.PROGRAM_APPLICATION_ID,' ||
                 ' MPI.PROGRAM_ID,' ||
                 ' MPI.PROGRAM_UPDATE_DATE,' ||
                 ' MPI.APPROVAL_TOLERANCE_POS,' ||
                 ' MPI.APPROVAL_TOLERANCE_NEG,' ||
                 ' MPI.COST_VARIANCE_POS,' ||
                 ' MPI.COST_VARIANCE_NEG,' ||
                 ' MPI.NUMBER_OF_SKUS,' ||
                 ' MPI.DYNAMIC_TAG_ENTRY_FLAG,' ||
                 ' MPI.ATTRIBUTE1,' ||
                 ' MPI.ATTRIBUTE2,' ||
                 ' MPI.ATTRIBUTE3,' ||
                 ' MPI.ATTRIBUTE4,' ||
                 ' MPI.ATTRIBUTE5,' ||
                 ' MPI.ATTRIBUTE6,' ||
                 ' MPI.ATTRIBUTE7,' ||
                 ' MPI.ATTRIBUTE8,' ||
                 ' MPI.ATTRIBUTE9,' ||
                 ' MPI.ATTRIBUTE10,' ||
                 ' MPI.ATTRIBUTE11,' ||
                 ' MPI.ATTRIBUTE12,' ||
                 ' MPI.ATTRIBUTE13,' ||
                 ' MPI.ATTRIBUTE14,' ||
                 ' MPI.ATTRIBUTE15,' ||
                 ' MPI.ATTRIBUTE_CATEGORY' ||
                 ' FROM MTL_PHYSICAL_INVENTORIES MPI, MTL_PARAMETERS mp ' ||
                 ' WHERE mpi.ORGANIZATION_ID = mp.organization_id ' ;

        IF l_org_id IS NOT NULL THEN
           sqltxt := sqltxt || ' AND mpi.organization_id = ' || l_org_id || ' AND ROWNUM < ' || row_limit ;
        ELSE
           sqltxt := sqltxt || ' AND ROWNUM < ' || row_limit ;
        END IF;

       dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Details of Physical Inventory tags without onhand');

    ELSE
       JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,'Please execute the report with Script Name');
       JTF_DIAGNOSTIC_COREAPI.errorprint('Error: '|| 'Invalid Script Name');
       JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please choose correct Script Name');
       statusStr := 'FAILURE';
       errStr := 'Invalid Script Name';
       fixInfo := 'Please choose correct Script Name';
       isFatal := 'FALSE';
       report  := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
       reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
       RETURN;
    END IF;

   reportStr := ' Note: Only first 199 rows are returned by this script. The test completed as expected';
   JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
   statusStr := 'SUCCESS';
   report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
   reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;

EXCEPTION
  when others then
    JTF_DIAGNOSTIC_COREAPI.errorprint('Error: '||sqlerrm);
    JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('This is the exception handler');
    statusStr := 'FAILURE';
    errStr := sqlerrm ||' occurred in script Exception handled';
    fixInfo := 'Unexpected Exception in INVDA07B.pls';
    isFatal := 'FALSE';
    report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
    reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
END runTest;


PROCEDURE getComponentName(name OUT NOCOPY  VARCHAR2) IS
BEGIN
   name := 'Accuracy';
END getComponentName;

PROCEDURE getTestDesc(descStr OUT NOCOPY  VARCHAR2) IS
BEGIN
   descStr := 'Dump of Physical Inventory Tables';
END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY  VARCHAR2) IS
BEGIN
   name := 'Dump of Physical Inventory';
END getTestName;

PROCEDURE getDependencies (package_names OUT NOCOPY   JTF_DIAG_DEPENDTBL) IS
tempDependencies JTF_DIAG_DEPENDTBL;

BEGIN
    package_names := JTF_DIAGNOSTIC_ADAPTUTIL.initDependencyTable;
END getDependencies;

PROCEDURE isDependencyPipelined (str OUT NOCOPY   VARCHAR2) IS
BEGIN
  str := 'FALSE';
END isDependencyPipelined;

PROCEDURE getOutputValues(outputValues OUT NOCOPY   JTF_DIAG_OUTPUTTBL) IS
  tempOutput JTF_DIAG_OUTPUTTBL;
BEGIN
  tempOutput := JTF_DIAGNOSTIC_ADAPTUTIL.initOutputTable;
  outputValues := tempOutput;
EXCEPTION
 when others then
 outputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initOutputTable;
END getOutputValues;

PROCEDURE getDefaultTestParams(defaultInputValues OUT NOCOPY  JTF_DIAG_INPUTTBL) IS
tempInput JTF_DIAG_INPUTTBL;
BEGIN
   tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
   tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'OrgId','LOV-oracle.apps.inv.diag.lov.OrganizationLov');
   tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'ItemId','LOV-oracle.apps.inv.diag.lov.ItemLov');
   tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'ScriptName','LOV-oracle.apps.inv.diag.lov.PhyInvDumpScriptsLov');
   defaultInputValues := tempInput;
EXCEPTION
  when others then
    defaultInputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
END getDefaultTestParams;

Function getTestMode return INTEGER IS
BEGIN
 return JTF_DIAGNOSTIC_ADAPTUTIL.ADVANCED_MODE;
END getTestMode;

END INV_DIAG_PHY_INV_DUMP;

/
