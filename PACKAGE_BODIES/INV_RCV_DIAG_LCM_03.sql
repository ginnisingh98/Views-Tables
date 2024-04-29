--------------------------------------------------------
--  DDL for Package Body INV_RCV_DIAG_LCM_03
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_RCV_DIAG_LCM_03" AS
/* $Header: INVRCV3B.pls 120.0.12010000.1 2009/03/18 19:31:33 musinha noship $ */

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
row_limit NUMBER;


BEGIN

   JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
   JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
   JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;

   -- Printing RCV_SHIPMENT_HEADERS Data
   JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_SHIPMENT_HEADERS"></a>');
   JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_SHIPMENT_HEADERS</b><a href="#INDEX OF QUERIES">[Top]</a>');
   sqltxt :=     ' SELECT rsh.*'                                                   ||
                 ' FROM   rcv_shipment_headers rsh'                                ||
                 ' WHERE  rsh.shipment_header_id in '                              ||
                 '       ( SELECT distinct rt.shipment_header_id '                 ||
		 '         FROM   rcv_transactions      rt,'                       ||
		 '                po_line_locations_all pll'                       ||
    	         '         WHERE  rt.po_line_location_id is not null '             ||
		 '         AND    rt.po_line_location_id = pll.line_location_id'   ||
                 '         AND    pll.lcm_flag =  ''Y''  '                         ||
		 '         AND    unit_landed_cost is null)';
   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'');
   JTF_DIAGNOSTIC_COREAPI.BRPrint;

   -- Printing RCV_SHIPMENT_LINES Data
   JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_SHIPMENT_LINES"></a>');
   JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_SHIPMENT_LINES</b><a href="#INDEX OF QUERIES">[Top]</a>');
   sqltxt :=     ' SELECT rsl.*'                                                   ||
                 ' FROM   rcv_shipment_lines rsl'                                  ||
                 ' WHERE  rsl.shipment_line_id in '                                ||
                 '       ( SELECT distinct rt.shipment_line_id '                   ||
		 '         FROM   rcv_transactions      rt,'                       ||
		 '                po_line_locations_all pll'                       ||
    	         '         WHERE  rt.po_line_location_id is not null '             ||
		 '         AND    rt.po_line_location_id = pll.line_location_id'   ||
                 '         AND    pll.lcm_flag =  ''Y''  '                         ||
		 '         AND    unit_landed_cost is null)';
   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'');
   JTF_DIAGNOSTIC_COREAPI.BRPrint;

   -- Printing RCV_TRANSACTIONS Data
   JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_TRANSACTIONS"></a>');
   JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_TRANSACTIONS</b><a href="#INDEX OF QUERIES">[Top]</a>');
   sqltxt :=     ' SELECT rt.* '                                           ||
		 ' FROM   rcv_transactions      rt,'                       ||
		 '        po_line_locations_all pll'                       ||
    	         ' WHERE  rt.po_line_location_id is not null '             ||
		 ' AND    rt.po_line_location_id = pll.line_location_id'   ||
                 ' AND    pll.lcm_flag =  ''Y''  '                         ||
		 ' AND    unit_landed_cost is null'                        ||
		 ' ORDER BY rt.shipment_header_id, rt.shipment_header_id, rt.transaction_id' ;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'');
   JTF_DIAGNOSTIC_COREAPI.BRPrint;

   -- Printing PO_LINE_LOCATIONS_ALL Data
   JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="PO_LINE_LOCATIONS_ALL"></a>');
   JTF_DIAGNOSTIC_COREAPI.insert_html('<b>PO_LINE_LOCATIONS_ALL</b><a href="#INDEX OF QUERIES">[Top]</a>');
   sqltxt :=     ' SELECT pll.* '                                           ||
		 ' FROM   rcv_transactions      rt,'                       ||
		 '        po_line_locations_all pll'                       ||
    	         ' WHERE  rt.po_line_location_id is not null '             ||
		 ' AND    rt.po_line_location_id = pll.line_location_id'   ||
                 ' AND    pll.lcm_flag =  ''Y''  '                         ||
		 ' AND    unit_landed_cost is null'                        ||
		 ' ORDER BY rt.shipment_header_id, rt.shipment_header_id, rt.transaction_id' ;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'');
   JTF_DIAGNOSTIC_COREAPI.BRPrint;

   -- Printing MTL_PARAMETERS Data
   JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_PARAMETERS"></a>');
   JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_PARAMETERS</b><a href="#INDEX OF QUERIES">[Top]</a>');
   sqltxt :=     ' SELECT  mp.* '                                                 ||
                 ' FROM    mtl_parameters mp'                                     ||
                 ' WHERE   mp.organization_id in'                                 ||
                 '        ( SELECT distinct rt.organization_id'                   ||
		 '          FROM   rcv_transactions      rt,'                     ||
		 '                 po_line_locations_all pll'                     ||
    	         '          WHERE  rt.po_line_location_id is not null '           ||
		 '          AND    rt.po_line_location_id = pll.line_location_id' ||
		 '          AND    pll.lcm_flag =  ''Y''  '                       ||
		 '          AND    rt.unit_landed_cost is null)';

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'');
   JTF_DIAGNOSTIC_COREAPI.BRPrint;

   -- Printing RCV_PARAMETERS Data
   JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_PARAMETERS"></a>');
   JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_PARAMETERS</b><a href="#INDEX OF QUERIES">[Top]</a>');
   sqltxt :=     ' SELECT  rp.* '                                                 ||
                 ' FROM    rcv_parameters rp'                                     ||
                 ' WHERE   rp.organization_id in'                                 ||
                 '        ( SELECT distinct rt.organization_id'                   ||
		 '          FROM   rcv_transactions      rt,'                     ||
		 '                 po_line_locations_all pll'                     ||
    	         '          WHERE  rt.po_line_location_id is not null '           ||
		 '          AND    rt.po_line_location_id = pll.line_location_id' ||
		 '          AND    pll.lcm_flag =  ''Y''  '                       ||
		 '          AND    rt.unit_landed_cost is null)';

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'');
   JTF_DIAGNOSTIC_COREAPI.BRPrint;

   -- Test Completed successfully.
   statusStr := 'SUCCESS';
   isFatal := 'FALSE';
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
   name := 'RT for lcm lines with null landed cost';
END getComponentName;

PROCEDURE getTestDesc(descStr OUT NOCOPY  VARCHAR2) IS
BEGIN
   descStr := 'RT for lcm lines with null landed cost';
END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY  VARCHAR2) IS
BEGIN
   name := 'Transactions with null landed cost in LCM enabled organizations';
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
   defaultInputValues := tempInput;
EXCEPTION
  when others then
    defaultInputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
END getDefaultTestParams;

Function getTestMode return INTEGER IS
BEGIN
 return JTF_DIAGNOSTIC_ADAPTUTIL.ADVANCED_MODE;
END getTestMode;

END INV_RCV_DIAG_LCM_03;

/
