--------------------------------------------------------
--  DDL for Package Body INV_RCV_DIAG_LCM_02
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_RCV_DIAG_LCM_02" AS
/* $Header: INVRCV2B.pls 120.0.12010000.1 2009/03/18 19:20:30 musinha noship $ */

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

BEGIN

   JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
   JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
   JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;

   -- Printing RCV_SHIPMENT_HEADERS Data
   JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_SHIPMENT_HEADERS"></a>');
   JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_SHIPMENT_HEADERS</b><a href="#INDEX OF QUERIES">[Top]</a>');

   sqltxt :=     ' select rsh.* ' ||
                 ' FROM   rcv_shipment_lines   rsl,'                                     ||
                 '        rcv_shipment_headers rsh '                                     ||
    	         ' WHERE  rsh.shipment_header_id = rsl.shipment_header_id'               ||
    	         ' AND    lcm_shipment_line_id in '                                      ||
		 '       ( SELECT lcm_shipment_line_id'                                  ||
                 '         FROM  (SELECT lcm_shipment_line_id,  count(shipment_line_id)' ||
		 '                FROM   rcv_shipment_lines'                             ||
		 '                WHERE  lcm_shipment_line_id is not null'               ||
		 '                GROUP BY lcm_shipment_line_id'                         ||
		 '                HAVING COUNT(shipment_line_id) > 1))'                  ||
		 ' ORDER BY lcm_shipment_line_id, shipment_line_id';

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'');
   JTF_DIAGNOSTIC_COREAPI.BRPrint;

   -- Printing RCV_SHIPMENT_LINES Data
   JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_SHIPMENT_LINES"></a>');
   JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_SHIPMENT_LINES</b><a href="#INDEX OF QUERIES">[Top]</a>');

   sqltxt :=     ' select * ' ||
                 ' FROM   rcv_shipment_lines'                                            ||
                 ' WHERE  lcm_shipment_line_id in '                                      ||
                 '       ( SELECT lcm_shipment_line_id'                                  ||
                 '         FROM  (SELECT lcm_shipment_line_id,  count(shipment_line_id)' ||
		 '                FROM   rcv_shipment_lines'                             ||
		 '                WHERE  lcm_shipment_line_id is not null'               ||
		 '                GROUP BY lcm_shipment_line_id'                         ||
		 '                HAVING COUNT(shipment_line_id) > 1))'                  ||
		 ' ORDER BY lcm_shipment_line_id, shipment_line_id';
   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'');
   JTF_DIAGNOSTIC_COREAPI.BRPrint;

   -- Printing PO_LINE_LOCATIONS_ALL Data
   JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="PO_LINE_LOCATIONS_ALL"></a>');
   JTF_DIAGNOSTIC_COREAPI.insert_html('<b>PO_LINE_LOCATIONS_ALL</b><a href="#INDEX OF QUERIES">[Top]</a>');

   sqltxt :=     ' select pll.* ' ||
                 ' FROM   rcv_shipment_lines    rsl,'                                    ||
                 '        po_line_locations_all pll '                                    ||
    	         ' WHERE  pll.line_location_id = rsl.po_line_location_id'                ||
    	         ' AND    lcm_shipment_line_id in '                                      ||
		 '       ( SELECT lcm_shipment_line_id'                                  ||
                 '         FROM  (SELECT lcm_shipment_line_id,  count(shipment_line_id)' ||
		 '                FROM   rcv_shipment_lines'                             ||
		 '                WHERE  lcm_shipment_line_id is not null'               ||
		 '                GROUP BY lcm_shipment_line_id'                         ||
		 '                HAVING COUNT(shipment_line_id) > 1))'                  ||
		 ' ORDER BY lcm_shipment_line_id, shipment_line_id';

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'');
   JTF_DIAGNOSTIC_COREAPI.BRPrint;

   -- Printing MTL_PARAMETERS Data
   JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_PARAMETERS"></a>');
   JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_PARAMETERS</b><a href="#INDEX OF QUERIES">[Top]</a>');

   sqltxt :=     ' select  mp.* '                                                                 ||
                 ' FROM    mtl_parameters     mp '                                                ||
                 ' WHERE   mp.organization_id in '                                                ||
                 '         (SELECT distinct rsl.to_organization_id '                              ||
                 '          FROM   rcv_shipment_lines rsl,'                                       ||
                 '                 mtl_parameters     mp '                                        ||
                 '          WHERE  rsl.to_organization_id = mp.organization_id'                   ||
                 '          AND    lcm_shipment_line_id in '                                      ||
		 '                ( SELECT lcm_shipment_line_id'                                  ||
                 '                  FROM  (SELECT lcm_shipment_line_id,  count(shipment_line_id)' ||
		 '                         FROM   rcv_shipment_lines'                             ||
		 '                         WHERE  lcm_shipment_line_id is not null'               ||
		 '                         GROUP BY lcm_shipment_line_id'                         ||
		 '                         HAVING COUNT(shipment_line_id) > 1)))';

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'');
   JTF_DIAGNOSTIC_COREAPI.BRPrint;

   -- Printing RCV_PARAMETERS Data
   JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_PARAMETERS"></a>');
   JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_PARAMETERS</b><a href="#INDEX OF QUERIES">[Top]</a>');

   sqltxt :=     ' select  rp.* ' ||
                 ' FROM    rcv_parameters     rp '                                                ||
                 ' WHERE   rp.organization_id in '                                                ||
                 '         (SELECT distinct rsl.to_organization_id '                              ||
                 '          FROM   rcv_shipment_lines rsl,'                                       ||
                 '                 mtl_parameters     mp '                                        ||
                 '          WHERE  rsl.to_organization_id = mp.organization_id'                   ||
                 '          AND    lcm_shipment_line_id in '                                      ||
		 '                ( SELECT lcm_shipment_line_id'                                  ||
                 '                  FROM  (SELECT lcm_shipment_line_id,  count(shipment_line_id)' ||
		 '                         FROM   rcv_shipment_lines'                             ||
		 '                         WHERE  lcm_shipment_line_id is not null'               ||
		 '                         GROUP BY lcm_shipment_line_id'                         ||
		 '                         HAVING COUNT(shipment_line_id) > 1)))';

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'');
   JTF_DIAGNOSTIC_COREAPI.BRPrint;

   -- Test Completed successfully.
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
   name := 'Duplicate lcm_shipment_id in rcv_shipment_lines';
END getComponentName;

PROCEDURE getTestDesc(descStr OUT NOCOPY  VARCHAR2) IS
BEGIN
   descStr := 'Duplicate lcm_shipment_id in rcv_shipment_lines';
END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY  VARCHAR2) IS
BEGIN
   name := 'Duplicate lcm shipment lines in rcv_shipment_lines';
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

END INV_RCV_DIAG_LCM_02;

/
