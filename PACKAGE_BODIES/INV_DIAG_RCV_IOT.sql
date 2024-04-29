--------------------------------------------------------
--  DDL for Package Body INV_DIAG_RCV_IOT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DIAG_RCV_IOT" AS
/* $Header: INVDR04B.pls 120.1 2007/12/19 16:26:59 ssadasiv noship $ */

------------------------------------------------------------
-- procedure to initialize test datastructures
-- executes prior to test run
------------------------------------------------------------
PROCEDURE init IS
BEGIN
-- test writer could insert special setup code here
null;
END init;

------------------------------------------------------------
-- procedure to cleanup any  test datastructures that were setup in the init
--  procedure call executes after test run
------------------------------------------------------------
PROCEDURE cleanup IS
BEGIN
-- test writer could insert special cleanup code here
NULL;
END cleanup;

------------------------------------------------------------
-- procedure to report test name back to framework
------------------------------------------------------------
PROCEDURE getTestName(str OUT NOCOPY VARCHAR2) IS
BEGIN
str := 'Inter Org Transfer';
END getTestName;

------------------------------------------------------------
-- procedure to report name back to framework
------------------------------------------------------------
PROCEDURE getComponentName(str OUT NOCOPY VARCHAR2) IS
BEGIN
 str := 'IOT';
END getComponentName;

------------------------------------------------------------
-- procedure to report test description back to framework
------------------------------------------------------------
PROCEDURE getTestDesc(str OUT NOCOPY VARCHAR2) IS
BEGIN
str :=   'This diagnostic test will collect setup and transactional data for a specific interorg shipment.'||'<BR/>'||
         'The data collected can aid in the resolution of issues involving interorg shipment.'||'<BR/>'||
         '<b>Parameters</b>'||'<BR/>'||
         'This script requires either the combination of Shipment Number and Organization Id or Receipt Number and '||
         'Organization Id as mandatory parameters.'||'<BR/>'||'Shipment Line Number is optional.'||
         ' Alternatively all the parameters can be entered at the same time.';
END getTestDesc;


------------------------------------------------------------
-- procedure to provide/populate  the default parameters for the test case.
------------------------------------------------------------
PROCEDURE getDefaultTestParams(defaultInputValues OUT NOCOPY JTF_DIAG_INPUTTBL) IS
 tempInput JTF_DIAG_INPUTTBL;
BEGIN
 tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
 tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'Organization Id','LOV-oracle.apps.inv.diag.lov.OrganizationLov');
 tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'Shipment Number','LOV-oracle.apps.inv.diag.lov.IOTNumberLov');
  tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'Shipment Line Number','LOV-oracle.apps.inv.diag.lov.IOTlineLov');
  tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'Receipt Number','LOV-oracle.apps.inv.diag.lov.IOTReceiptLov');
 defaultInputValues := tempInput;
END getDefaultTestParams;

------------------------------------------------------------
-- procedure to report test mode back to the framework
------------------------------------------------------------
FUNCTION getTestMode RETURN NUMBER IS
BEGIN
 return JTF_DIAGNOSTIC_ADAPTUTIL.ADVANCED_MODE;
END getTestMode;

------------------------------------------------------------
-- procedure to execute the PLSQL test
-- the inputs needed for the test are passed in and a report object and CLOB are -- returned.
------------------------------------------------------------
PROCEDURE runtest(inputs IN  JTF_DIAG_INPUTTBL,
                         report OUT NOCOPY JTF_DIAG_REPORT,
                         reportClob OUT NOCOPY CLOB) IS
  reportStr   LONG;           -- REPORT
  c_username  VARCHAR2(50);   -- accept input for username
  statusStr   VARCHAR2(50);   -- SUCCESS or FAILURE
  errStr      VARCHAR2(4000); -- error message
  fixInfo     VARCHAR2(4000); -- fix tip
  isFatal     VARCHAR2(50);   -- TRUE or FALSE
  row_limit   NUMBER;

  sql_text VARCHAR2(6000);

  iot1_sql INV_DIAG_RCV_PO_COMMON.sqls_list;

  dummy_num        NUMBER;
  l_org_id              rcv_shipment_headers.organization_id%TYPE;
  l_receipt_num         rcv_shipment_headers.receipt_num%TYPE;
  l_shipment_num        rcv_shipment_headers.shipment_num%TYPE;
  l_shipment_line_num   rcv_shipment_lines.line_num%TYPE;
  l_makecall            NUMBER := 0;
  l_count               NUMBER := 1;

BEGIN
 JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
 JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
 JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;

 -- accept input
 l_shipment_num      := Trim(JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('Shipment Number',inputs));
 l_org_id            := Trim(JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('Organization Id',inputs));
 l_shipment_line_num := Trim(JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('Shipment Line Number',inputs));
 l_receipt_num       := Trim(JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('Receipt Number',inputs));


   IF (l_shipment_num is NULL AND l_receipt_num is NULL AND l_shipment_line_num IS NULL AND l_org_id is NULL ) THEN

     JTF_DIAGNOSTIC_COREAPI.ErrorPrint('Some of the required inputs are missing');
     JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please refer to the parameters section for mandatory parameters for this
test');
     statusStr  := 'FAILURE';
     report     := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
     reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
     l_makecall  := 1;
     RETURN;
  END IF;


  IF (l_shipment_num is NULL AND l_receipt_num is NULL AND l_org_id is NULL) THEN

     JTF_DIAGNOSTIC_COREAPI.ErrorPrint('Some of the required inputs are missing');
     JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please refer to the parameters section for mandatory parameters for this
test');
     statusStr  := 'FAILURE';
     report     := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
     reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
     l_makecall  := 1;
     RETURN;
  END IF;


  IF (l_shipment_num is NOT NULL and l_org_id is NULL) THEN
   JTF_DIAGNOSTIC_COREAPI.ErrorPrint('Some of the required inputs are missing');
     JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please refer to the parameters section for mandatory parameters for this
test');
     statusStr  := 'FAILURE';
     report     := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
     reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
     l_makecall  := 1;
     RETURN;
  END IF;


  IF (l_receipt_num is NOT NULL and l_org_id is NULL) THEN

     JTF_DIAGNOSTIC_COREAPI.ErrorPrint('Some of the required inputs are missing');
     JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please refer to the parameters section for mandatory parameters for this
test');
     statusStr  := 'FAILURE';
     report     := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
     reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
     l_makecall  := 1;
     RETURN;
  END IF;


  IF (l_receipt_num is NULL and l_shipment_num is NULL and l_org_id is NOT NULL) THEN
     JTF_DIAGNOSTIC_COREAPI.ErrorPrint('Some of the required inputs are missing');
     JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please refer to the parameters section for mandatory parameters for this
test');
     statusStr  := 'FAILURE';
     report     := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
     reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
     l_makecall  := 1;
     RETURN;
  END IF;


  IF (l_receipt_num is NULL and l_shipment_num is NULL and l_shipment_line_num is NOT NULL) THEN
     JTF_DIAGNOSTIC_COREAPI.ErrorPrint('Some of the required inputs are missing');
     JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please refer to the parameters section for mandatory parameters for this
test');
     statusStr  := 'FAILURE';
     report     := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
     reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
     l_makecall  := 1;
     RETURN;
  END IF;


  IF (l_shipment_num is NOT NULL and l_receipt_num is NOT NULL and l_shipment_line_num is NOT NULL and l_org_id is NOT
NULL) THEN

     select Count(*)
     into l_count
     from rcv_shipment_headers rsh,
          rcv_shipment_lines rsl
     where rsh.receipt_num = l_receipt_num
     AND rsh.shipment_num = l_shipment_num
     AND rsh.shipment_header_id = rsl.shipment_header_id
     AND rsl.line_num = l_shipment_line_num
     and rsh.ship_to_org_id = l_org_id
     and rsh.receipt_source_code = 'INVENTORY';

  END IF;


  IF (l_shipment_num is NOT NULL and l_shipment_line_num is NOT NULL and l_org_id is NOT NULL AND l_count <> 0) THEN

     select Count(*)
     into l_count
     from rcv_shipment_headers rsh,
          rcv_shipment_lines rsl
     where rsh.shipment_num = l_shipment_num
     AND rsh.shipment_header_id = rsl.shipment_header_id
     AND rsl.line_num = l_shipment_line_num
     and rsh.ship_to_org_id = l_org_id
     and rsh.receipt_source_code = 'INVENTORY';

  END IF;

  IF (l_receipt_num is NOT NULL and l_shipment_line_num is NOT NULL and l_org_id is NOT NULL AND l_count <> 0) THEN

     select Count(*)
     into l_count
     from rcv_shipment_headers rsh,
          rcv_shipment_lines rsl
     where rsh.receipt_num = l_receipt_num
     AND rsh.shipment_header_id = rsl.shipment_header_id
     AND rsl.line_num = l_shipment_line_num
     and rsh.ship_to_org_id = l_org_id
     and rsh.receipt_source_code = 'INVENTORY';

  END IF;

IF (l_shipment_num is NOT NULL and l_receipt_num is NOT NULL and l_org_id is NOT NULL AND l_count <> 0) THEN

     select Count(*)
     into l_count
     from rcv_shipment_headers rsh
     where rsh.receipt_num = l_receipt_num
     AND rsh.shipment_num = l_shipment_num
     and rsh.ship_to_org_id = l_org_id
     and rsh.receipt_source_code = 'INVENTORY';

  END IF;

IF (l_shipment_num is NOT NULL and l_org_id is NOT NULL AND l_count <> 0) THEN

     select Count(*)
     into l_count
     from rcv_shipment_headers rsh
     where rsh.shipment_num = l_shipment_num
     and rsh.ship_to_org_id = l_org_id
     and rsh.receipt_source_code = 'INVENTORY';

  END IF;

IF (l_receipt_num is NOT NULL and l_org_id is NOT NULL AND l_count <> 0) THEN

     select Count(*)
     into l_count
     from rcv_shipment_headers rsh
     where rsh.receipt_num = l_receipt_num
     and rsh.ship_to_org_id = l_org_id
     and rsh.receipt_source_code = 'INVENTORY';

  END IF;


  IF (l_count = 0) THEN
   statusStr    := 'FAILURE';
   JTF_DIAGNOSTIC_COREAPI.ErrorPrint('No Data exists for the entered combination.');
   JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please enter a valid combination of data');
   report       := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
   reportClob   := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
   RETURN;
  END IF;


IF (l_makecall  <> 1) THEN

  IF (l_shipment_num is NULL and l_receipt_num is NOT NULL and l_org_id is NOT NULL) THEN

     begin

     select shipment_num
     into l_shipment_num
     from rcv_shipment_headers rsh
     where receipt_num = l_receipt_num
     and ship_to_org_id = l_org_id
     and rsh.receipt_source_code = 'INVENTORY';

     exception
     when no_data_found then
     l_shipment_num := NULL;
     end;
  END IF;


  IF (l_shipment_num is NOT NULL and l_receipt_num is NULL and l_org_id is NOT NULL) THEN

     begin
     select receipt_num
     into l_receipt_num
     from rcv_shipment_headers rsh
     where shipment_num = l_shipment_num
     and ship_to_org_id = l_org_id
     and rsh.receipt_source_code = 'INVENTORY';

     exception
     when no_data_found then
     l_receipt_num := NULL;
     end;

  END IF;

-------------------------- Fixed Sqls

IF (l_shipment_num is NOT NULL AND l_shipment_line_num is NULL) THEN
 iot_diagnostics.shipment_num_sql(l_org_id,l_shipment_num,l_receipt_num,iot1_sql);
END IF;


IF (l_shipment_num is NOT NULL AND l_shipment_line_num is NOT NULL) THEN
iot_diagnostics.shipment_line_num_sql(l_org_id,l_shipment_num,l_shipment_line_num,l_receipt_num,iot1_sql);
END IF;

JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;
JTF_DIAGNOSTIC_COREAPI.insert_html('<table border="1" cellpadding="1" cellspacing="1" bgcolor="#f7f7e7">'||'
<tr bgcolor="#cccc99">'||'
<th colspan="3">INDEX OF QUERIES</th>'||'
<a name="INDEX OF QUERIES"></a></tr>'||'
<tr>'||'
<td><a href="#RCV_HEADERS_INTERFACE">RCV_HEADERS_INTERFACE</a></td>'||'
<td><a href="#RCV_TRANSACTIONS_INTERFACE">RCV_TRANSACTIONS_INTERFACE</a></td>'||'
<td><a href="#PO_INTERFACE_ERRORS">PO_INTERFACE_ERRORS</a></td>'||'
</tr>'||'
<tr>'||'
<td><a href="#RCV_SHIPMENT_HEADERS">RCV_SHIPMENT_HEADERS</a></td>'||'
<td><a href="#RCV_SHIPMENT_LINES">RCV_SHIPMENT_LINES</a></td>'||'
<td><a href="#RCV_TRANSACTIONS">RCV_TRANSACTIONS</a></td>'||'
</tr>'||'
<tr>'||'
<td><a href="#MTL_SUPPLY">MTL_SUPPLY</a></td>'||'
<td><a href="#RCV_SUPPLY">RCV_SUPPLY</a></td>'||'
<td><a href="#MTL_MATERIAL_TRANSACTIONS_TEMP">MTL_MATERIAL_TRANSACTIONS_TEMP</a></td>'||'
</tr>'||'
<tr>'||'
<td><a href="#MTL_MATERIAL_TRANSACTIONS">MTL_MATERIAL_TRANSACTIONS</a></td>'||'
<td><a href="#MTL_LOT_NUMBERSS">MTL_LOT_NUMBERS</a></td>'||'
<td><a href="#MTL_TRANSACTION_LOT_NUMBERS">MTL_TRANSACTION_LOT_NUMBERS</a></td>'||'
</tr>'||'
<tr>'||'
<td><a href="#MTL_TRANSACTION_LOTS_INTERFACE">MTL_TRANSACTION_LOTS_INTERFACE</a></td>'||'
<td><a href="#MTL_TRANSACTION_LOTS_TEMP">MTL_TRANSACTION_LOTS_TEMP</a></td>'||'
<td><a href="#RCV_LOTS_SUPPLY">RCV_LOTS_SUPPLY</a></td>'||'
</tr>'||'
<tr>'||'
<td><a href="#RCV_LOT_TRANSACTIONS">RCV_LOT_TRANSACTIONS</a></td>'||'
<td><a href="#RCV_LOTS_INTERFACE">RCV_LOTS_INTERFACE</a></td>'||'
<td><a href="#RCV_SERIALS_SUPPLY">RCV_SERIALS_SUPPLY</a></td>'||'
</tr>'||'
<tr>'||'
<td><a href="#RCV_SERIAL_TRANSACTIONS">RCV_SERIAL_TRANSACTIONS</a></td>'||'
<td><a href="#RCV_SERIALS_INTERFACE">RCV_SERIALS_INTERFACE</a></td>'||'
<td><a href="#MTL_SERIAL_NUMBERS">MTL_SERIAL_NUMBERS</a></td>'||'
</tr>'||'
<tr>'||'

<td><a href="#MTL_SERIAL_NUMBERS_TEMPE">MTL_SERIAL_NUMBERS_TEMP</a></td>'||'
<td><a href="#MTL_SERIAL_NUMBERS_INTERFACES">MTL_SERIAL_NUMBERS_INTERFACE</a></td>'||'
<td><a href="#MTL_UNIT_TRANSACTIONSS">MTL_UNIT_TRANSACTIONS</a></td>'||'
</tr>'||'
<tr>'||'
<td><a href="#MTL_SYSTEM_ITEMS">MTL_SYSTEM_ITEMS</a></td>'||'
<td><a href="#MTL_TRANSACTION_TYPES">MTL_TRANSACTION_TYPES</a></td>'||'
<td><a href="#ORG_ORG_DEFINIATIONS">ORG_ORG_DEFINIATIONS</a></td>'||'
</tr>'||'
<tr>'||'
<td><a href="#MTL_INTERORG_PARAMETERS">MTL_INTERORG_PARAMETERS</a></td>'||'
<td><a href="MTL_PARAMETERS">MTL_PARAMETERS</a></td>'||'
<td><a href="#RCV_PARAMETERS">RCV_PARAMETERS</a></td>'||'
</tr>'||'
<tr>'||'
<td><a href="#LOOKUP CODES">LOOKUP CODES</a></td>'||'
</tr>'||'
</table>');

JTF_DIAGNOSTIC_COREAPI.insert_html('<h4>Receipt Information</h4>');
sql_text := iot1_sql(1);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_HEADERS_INTERFACE"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_HEADERS_INTERFACE</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text := iot1_sql(2);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_TRANSACTIONS_INTERFACE"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_TRANSACTIONS_INTERFACE</b>&nbsp;&nbsp;<a href="#INDEX OF
QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text := iot1_sql(3);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="PO_INTERFACE_ERRORS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>PO_INTERFACE_ERRORS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;


sql_text := iot1_sql(4);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_SHIPMENT_HEADERS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_SHIPMENT_HEADERS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;


sql_text := iot1_sql(5);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_SHIPMENT_LINES"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_SHIPMENT_LINES</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;


sql_text:= iot1_sql(6);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_TRANSACTIONS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_TRANSACTIONS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text  := iot1_sql(7);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_SUPPLY"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_SUPPLY</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text := iot1_sql(8);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_SUPPLY"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_SUPPLY</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'RCV_SUPPLY','Y','Y');
JTF_DIAGNOSTIC_COREAPI.BRPrint;


JTF_DIAGNOSTIC_COREAPI.insert_html('<h4>Inventory Information</h4>');
sql_text := iot1_sql(9);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_MATERIAL_TRANSACTIONS_TEMP"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_MATERIAL_TRANSACTIONS_TEMP</b>&nbsp;&nbsp;<a href="#INDEX OF
QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;


sql_text:= iot1_sql(10);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_MATERIAL_TRANSACTIONS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_MATERIAL_TRANSACTIONS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= iot1_sql(11);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_LOT_NUMBERS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_LOT_NUMBERS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= iot1_sql(12);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_TRANSACTION_LOT_NUMBERS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_TRANSACTION_LOT_NUMBERS</b>&nbsp;&nbsp;<a href="#INDEX OF
QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= iot1_sql(13);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_TRANSACTION_LOT_INTERFACE"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_TRANSACTION_LOT_INTERFACE</b>&nbsp;&nbsp;<a href="#INDEX OF
QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= iot1_sql(14);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_TRANSACTION_LOTS_TEMP"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_TRANSACTION_LOTS_TEMP</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= iot1_sql(15);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_LOTS_SUPPLY"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_LOTS_SUPPLY</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= iot1_sql(16);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_LOT_TRANSACTIONS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_LOT_TRANSACTIONS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= iot1_sql(17);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_LOTS_INTERFACE"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_LOTS_INTERFACE</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= iot1_sql(18);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_SERIAL_SUPPLY"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_SERIAL_SUPPLY</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= iot1_sql(19);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_SERIAL_TRANSACTIONS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_SERIAL_TRANSACTIONS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= iot1_sql(20);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_SERIALS_INTERFACE"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_SERIALS_INTERFACE</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= iot1_sql(21);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_SERIAL_NUMBERS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_SERIAL_NUMBERS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= iot1_sql(22);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_SERIAL_NUMBERS_TEMP"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_SERIAL_NUMBERS_TEMP</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= iot1_sql(23);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_SERIAL_NUMBERS_INTERFACE"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_SERIAL_NUMBERS_INTERFACE</b>&nbsp;&nbsp;<a href="#INDEX OF
QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= iot1_sql(24);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_UNIT_TRANSACTIONS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_UNIT_TRANSACTIONS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= iot1_sql(25);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_SYSTEM_ITEMS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_SYSTEM_ITEMS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= iot1_sql(26);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_TRANSACTION_TYPES"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_TRANSACTION_TYPES</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= iot1_sql(27);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="ORG_ORG_DEFINITIONS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>ORG_ORG_DEFINITIONS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= iot1_sql(28);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_INTERORG_PARAMETERS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_INTERORG_PARAMETERS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= iot1_sql(29);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_PARAMETERS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_PARAMETERS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= iot1_sql(30);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_PARAMETERS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_PARAMETERS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="LOOKUP CODES"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<h4>Lookup Codes</h4>');
sql_text:= iot1_sql(31);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="Lot Control"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>Lot Control</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= iot1_sql(32);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="Lot Generation"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>Lot Generation</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= iot1_sql(33);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="LOT Uniqueness"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>LOT Uniqueness</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= iot1_sql(34);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="Serial Control"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>Serial Control</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;


sql_text:= iot1_sql(35);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="Serial Uniqueness"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>Serial Uniqueness</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;


sql_text:= iot1_sql(36);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="Serial Generation"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>Serial Generation</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= iot1_sql(37);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="Serial Number Status"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>Serial Number Status</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;


END IF;

------------------------- Submit the sql to fwk

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
   fixInfo := 'Unexpected Exception in INVDR01B.pls';
   isFatal := 'FALSE';
   report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
   reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
END runTest;


END INV_DIAG_RCV_IOT;

/
