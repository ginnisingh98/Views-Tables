--------------------------------------------------------
--  DDL for Package Body INV_DIAG_RSV_MS_DUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DIAG_RSV_MS_DUMP" as
/* $Header: INVDP08B.pls 120.0.12000000.1 2007/06/22 01:19:52 musinha noship $ */

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

   IF l_script = 'MR_DUMP' THEN

       sqltxt := 'SELECT ' ||
                 ' MR.RESERVATION_ID                "RESERVATION_ID",' ||
                 ' MR.REQUIREMENT_DATE              "REQUIREMENT_DATE",' ||
                 ' mif.item_number||''(''||mif.inventory_item_id||'')'' "Item (Id)",' ||
                 ' mp.organization_code|| '' (''||mr.organization_id ||'')'' "Organization|Code (Id)",' ||
                 ' MR.DEMAND_SOURCE_TYPE_ID         "DEMAND_SOURCE_TYPE_ID",' ||
                 ' MR.DEMAND_SOURCE_NAME            "DEMAND_SOURCE_NAME",' ||
                 ' MR.DEMAND_SOURCE_HEADER_ID       "DEMAND_SOURCE_HEADER_ID",' ||
                 ' MR.DEMAND_SOURCE_LINE_ID         "DEMAND_SOURCE_LINE_ID",' ||
                 ' MR.DEMAND_SOURCE_DELIVERY        "DEMAND_SOURCE_DELIVERY",' ||
                 ' MR.PRIMARY_UOM_CODE              "PRIMARY_UOM_CODE",' ||
                 ' MR.PRIMARY_UOM_ID                "PRIMARY_UOM_ID",' ||
                 ' MR.RESERVATION_UOM_CODE          "RESERVATION_UOM_CODE",' ||
                 ' MR.RESERVATION_UOM_ID            "RESERVATION_UOM_ID",' ||
                 ' MR.RESERVATION_QUANTITY          "RESERVATION_QUANTITY",' ||
                 ' MR.PRIMARY_RESERVATION_QUANTITY  "PRIMARY_RESERVATION_QUANTITY",' ||
                 ' MR.AUTODETAIL_GROUP_ID           "AUTODETAIL_GROUP_ID",' ||
                 ' MR.EXTERNAL_SOURCE_CODE          "EXTERNAL_SOURCE_CODE",' ||
                 ' MR.EXTERNAL_SOURCE_LINE_ID       "EXTERNAL_SOURCE_LINE_ID",' ||
                 ' MR.SUPPLY_SOURCE_TYPE_ID         "SUPPLY_SOURCE_TYPE_ID",' ||
                 ' MR.SUPPLY_SOURCE_HEADER_ID       "SUPPLY_SOURCE_HEADER_ID",' ||
                 ' MR.SUPPLY_SOURCE_LINE_ID         "SUPPLY_SOURCE_LINE_ID",' ||
                 ' MR.SUPPLY_SOURCE_LINE_DETAIL     "SUPPLY_SOURCE_LINE_DETAIL",' ||
                 ' MR.SUPPLY_SOURCE_NAME            "SUPPLY_SOURCE_NAME",' ||
                 ' MR.REVISION                      "REVISION",' ||
                 ' MR.SUBINVENTORY_CODE             "SUBINVENTORY_CODE",' ||
                 ' MR.SUBINVENTORY_ID               "SUBINVENTORY_ID",' ||
                 ' MR.LOCATOR_ID                    "LOCATOR_ID",' ||
                 ' MR.LOT_NUMBER                    "LOT_NUMBER",' ||
                 ' MR.LOT_NUMBER_ID                 "LOT_NUMBER_ID",' ||
                 ' MR.SERIAL_NUMBER                 "SERIAL_NUMBER",' ||
                 ' MR.SERIAL_NUMBER_ID              "SERIAL_NUMBER_ID",' ||
                 ' MR.PARTIAL_QUANTITIES_ALLOWED    "PARTIAL_QUANTITIES_ALLOWED",' ||
                 ' MR.AUTO_DETAILED                 "AUTO_DETAILED",' ||
                 ' MR.PICK_SLIP_NUMBER              "PICK_SLIP_NUMBER",' ||
                 ' MR.LPN_ID                        "LPN_ID",' ||
                 ' MR.LAST_UPDATE_DATE              "LAST_UPDATE_DATE",' ||
                 ' MR.LAST_UPDATED_BY               "LAST_UPDATED_BY",' ||
                 ' MR.CREATION_DATE                 "CREATION_DATE",' ||
                 ' MR.CREATED_BY                    "CREATED_BY",' ||
                 ' MR.LAST_UPDATE_LOGIN             "LAST_UPDATE_LOGIN",' ||
                 ' MR.REQUEST_ID                    "REQUEST_ID",' ||
                 ' MR.PROGRAM_APPLICATION_ID        "PROGRAM_APPLICATION_ID",' ||
                 ' MR.PROGRAM_ID                    "PROGRAM_ID",' ||
                 ' MR.PROGRAM_UPDATE_DATE           "PROGRAM_UPDATE_DATE",' ||
                 ' MR.ATTRIBUTE_CATEGORY            "ATTRIBUTE_CATEGORY",' ||
                 ' MR.ATTRIBUTE1                    "ATTRIBUTE1",' ||
                 ' MR.ATTRIBUTE2                    "ATTRIBUTE2",' ||
                 ' MR.ATTRIBUTE3                    "ATTRIBUTE3",' ||
                 ' MR.ATTRIBUTE4                    "ATTRIBUTE4",' ||
                 ' MR.ATTRIBUTE5                    "ATTRIBUTE5",' ||
                 ' MR.ATTRIBUTE6                    "ATTRIBUTE6",' ||
                 ' MR.ATTRIBUTE7                    "ATTRIBUTE7",' ||
                 ' MR.ATTRIBUTE8                    "ATTRIBUTE8",' ||
                 ' MR.ATTRIBUTE9                    "ATTRIBUTE9",' ||
                 ' MR.ATTRIBUTE10                   "ATTRIBUTE10",' ||
                 ' MR.ATTRIBUTE11                   "ATTRIBUTE11",' ||
                 ' MR.ATTRIBUTE12                   "ATTRIBUTE12",' ||
                 ' MR.ATTRIBUTE13                   "ATTRIBUTE13",' ||
                 ' MR.ATTRIBUTE14                   "ATTRIBUTE14",' ||
                 ' MR.ATTRIBUTE15                   "ATTRIBUTE15",' ||
                 ' MR.SHIP_READY_FLAG               "SHIP_READY_FLAG",' ||
                 ' MR.N_COLUMN1                     "N_COLUMN1",' ||
                 ' MR.DETAILED_QUANTITY             "DETAILED_QUANTITY",' ||
                 ' MR.COST_GROUP_ID                 "COST_GROUP_ID",' ||
                 ' MR.CONTAINER_LPN_ID              "CONTAINER_LPN_ID",' ||
                 ' MR.STAGED_FLAG                   "STAGED_FLAG "' ||
                 ' FROM MTL_RESERVATIONS MR,  MTL_PARAMETERS mp, MTL_ITEM_FLEXFIELDS mif'  ||
    	         ' WHERE MR.organization_id = mp.organization_id' ||
                 ' and MR.inventory_item_id = mif.inventory_item_id(+)' ||
                 ' and MR.organization_id = mif.organization_id(+) ' ;

       IF l_org_id IS NOT NULL THEN

          IF l_item_id IS NOT NULL THEN
             sqltxt := sqltxt || ' AND MR.ORGANIZATION_ID = ' || l_org_id || ' AND MR.INVENTORY_ITEM_ID = ' || l_item_id || ' AND ROWNUM < ' || row_limit ;
          ELSE
             sqltxt := sqltxt || ' AND MR.ORGANIZATION_ID = ' || l_org_id || ' AND ROWNUM < ' || row_limit ;
          END IF;

       ELSE
          IF l_item_id IS NOT NULL THEN
             sqltxt := sqltxt || ' AND MR.INVENTORY_ITEM_ID = ' || l_item_id || ' AND ROWNUM < ' || row_limit ;
          ELSE
             sqltxt := sqltxt || ' AND ROWNUM < ' || row_limit;
          END IF;

       END IF;

       dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Dump of Reservations');

    ELSIF l_script = 'MS_DUMP' THEN
       sqltxt := 'SELECT ' ||
                 ' MS.SUPPLY_TYPE_CODE,' ||
                 ' MS.SUPPLY_SOURCE_ID,' ||
                 ' MS.LAST_UPDATED_BY,' ||
                 ' MS.LAST_UPDATE_DATE,' ||
                 ' MS.LAST_UPDATE_LOGIN,' ||
                 ' MS.CREATED_BY,' ||
                 ' MS.CREATION_DATE,' ||
                 ' MS.REQUEST_ID,' ||
                 ' MS.PROGRAM_APPLICATION_ID,' ||
                 ' MS.PROGRAM_ID,' ||
                 ' MS.PROGRAM_UPDATE_DATE,' ||
                 ' MS.REQ_HEADER_ID,' ||
                 ' MS.REQ_LINE_ID,' ||
                 ' MS.PO_HEADER_ID,' ||
                 ' MS.PO_RELEASE_ID,' ||
                 ' MS.PO_LINE_ID,' ||
                 ' MS.PO_LINE_LOCATION_ID,' ||
                 ' MS.PO_DISTRIBUTION_ID,' ||
                 ' MS.SHIPMENT_HEADER_ID,' ||
                 ' MS.SHIPMENT_LINE_ID,' ||
                 ' MS.RCV_TRANSACTION_ID,' ||
                 ' MS.ITEM_ID,' ||
    	         ' mif.item_number || ''(''|| mif.inventory_item_id || '')'' "Item (Id)", ' ||
                 ' MS.ITEM_REVISION,' ||
                 ' MS.CATEGORY_ID,' ||
                 ' MS.QUANTITY,' ||
                 ' MS.UNIT_OF_MEASURE,' ||
                 ' MS.TO_ORG_PRIMARY_QUANTITY,' ||
                 ' MS.TO_ORG_PRIMARY_UOM,' ||
                 ' MS.RECEIPT_DATE,' ||
                 ' MS.NEED_BY_DATE,' ||
                 ' MS.EXPECTED_DELIVERY_DATE,' ||
                 ' MS.DESTINATION_TYPE_CODE,' ||
                 ' MS.LOCATION_ID,' ||
                 ' mp.organization_code || ''('' || ms.from_organization_id ||'')'' "From Organization|Code (Id)", ' ||
                 ' MS.FROM_SUBINVENTORY,' ||
                 ' mpTo.organization_code || ''('' || ms.to_organization_id ||'')'' "To Organization|Code (Id)", ' ||
                 ' MS.TO_SUBINVENTORY,' ||
                 ' MS.INTRANSIT_OWNING_ORG_ID,' ||
                 ' MS.MRP_PRIMARY_QUANTITY,' ||
                 ' MS.MRP_PRIMARY_UOM,' ||
                 ' MS.MRP_EXPECTED_DELIVERY_DATE,' ||
                 ' MS.MRP_DESTINATION_TYPE_CODE,' ||
                 ' MS.MRP_TO_ORGANIZATION_ID,' ||
                 ' MS.MRP_TO_SUBINVENTORY,' ||
                 ' MS.CHANGE_FLAG,' ||
                 ' MS.CHANGE_TYPE,' ||
                 ' MS.COST_GROUP_ID ' ||
                 ' FROM MTL_SUPPLY MS, MTL_PARAMETERS mp, MTL_ITEM_FLEXFIELDS mif, MTL_PARAMETERS mpTo '  ||
    	     ' WHERE ms.from_organization_id = mp.organization_id ' ||
    	     ' AND ms.item_id = mif.inventory_item_id(+) ' ||
    	     ' AND ms.from_organization_id = mif.organization_id(+) ' ||
    	     ' AND ms.to_organization_id = mpTo.organization_id ' ;

       IF l_org_id IS NOT NULL THEN
          IF l_item_id IS NOT NULL THEN
             sqltxt := sqltxt || ' AND MS.FROM_ORGANIZATION_ID = ' || l_org_id || ' AND MS.ITEM_ID = ' || l_item_id || ' AND ROWNUM < ' || row_limit ;
          ELSE
             sqltxt := sqltxt || ' AND MS.FROM_ORGANIZATION_ID = ' || l_org_id || ' AND ROWNUM < ' || row_limit ;
          END IF;

       ELSE
          IF l_item_id IS NOT NULL THEN
             sqltxt := sqltxt || ' AND MS.ITEM_ID = ' || l_item_id  || ' AND ROWNUM < ' || row_limit ;
          ELSE
             sqltxt := sqltxt || ' AND ROWNUM < ' || row_limit ;
          END IF;

       END IF;


       dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Dump of MTL_SUPPLY');

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
    fixInfo := 'Unexpected Exception in INVDP08B.pls';
    isFatal := 'FALSE';
    report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
    reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
END runTest;


PROCEDURE getComponentName(name OUT NOCOPY  VARCHAR2) IS
BEGIN
   name := 'Pick Release and Reservation';
END getComponentName;

PROCEDURE getTestDesc(descStr OUT NOCOPY  VARCHAR2) IS
BEGIN
   descStr := 'Dump of Reservation / Supply';
END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY  VARCHAR2) IS
BEGIN
   name := 'Dump of Reservation / Supply';
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
   tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'ScriptName','LOV-oracle.apps.inv.diag.lov.PickRelRsvDiagScriptsLov');
   defaultInputValues := tempInput;
EXCEPTION
  when others then
    defaultInputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
END getDefaultTestParams;

Function getTestMode return INTEGER IS
BEGIN
 return JTF_DIAGNOSTIC_ADAPTUTIL.ADVANCED_MODE;
END getTestMode;

END INV_DIAG_RSV_MS_DUMP;

/
