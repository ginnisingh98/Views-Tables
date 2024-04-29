--------------------------------------------------------
--  DDL for Package Body INV_DIAG_RCV_RMA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DIAG_RCV_RMA" AS
/* $Header: INVDR02B.pls 120.2 2008/02/19 06:13:15 srnatara noship $ */

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
  str := 'Return Material Authorization';
END getTestName;

------------------------------------------------------------
-- procedure to report name back to framework
------------------------------------------------------------
PROCEDURE getComponentName(str OUT NOCOPY VARCHAR2) IS
BEGIN
  str := 'RMA';
END getComponentName;

------------------------------------------------------------
-- procedure to report test description back to framework
------------------------------------------------------------
PROCEDURE getTestDesc(str OUT NOCOPY VARCHAR2) IS
BEGIN
   str := 'This diagnostic test will collect setup and transactional data for a specific return material authorization.'||'<BR/>'||
         'The data collected can aid in the resolution of issues involving return material authorization.'||'<BR/>'||
         '<b>Parameters</b>'||'<BR/>'||
         'This script requires either the combination of Rma Number and Operating Unit Id or Receipt Number and '||
         ' Organization Id as mandatory parameters.'||'<BR/>'||'Rma Line Number is optional.'||
         ' Alternatively all the parameters can be entered at the same time.';
END getTestDesc;


------------------------------------------------------------
-- procedure to provide/populate  the default parameters for the test case.
------------------------------------------------------------
PROCEDURE getDefaultTestParams(defaultInputValues OUT NOCOPY JTF_DIAG_INPUTTBL) IS
  tempInput JTF_DIAG_INPUTTBL;
BEGIN
  tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;

/* Bug#6828508:
  * OperatingLov is wrongly referenced as 'OperatingUnit Id'.
  * So, changed 'OperatingUnit Id' to 'Operating Unit Id' as mentioned
  * in OperatingLov.
  */
  tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'Operating Unit Id','LOV-oracle.apps.inv.diag.lov.OperatingLov');--Bug#6828508
  tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'RMA Number','LOV-oracle.apps.inv.diag.lov.RMANumberLov');
  tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'RMA Line Number','LOV-oracle.apps.inv.diag.lov.RMAlineLov');
  tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'Organization Id','LOV-oracle.apps.inv.diag.lov.OrganizationLov');
  tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'Receipt Number','LOV-oracle.apps.inv.diag.lov.RMAReceiptLov');
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
   skip_execution NUMBER := 0;
   l_rma_count  number := 0;

   rma1_sql INV_DIAG_RCV_PO_COMMON.sqls_list;

   dummy_num        NUMBER;
   l_operating_id   po_headers_all.org_id%TYPE;
   l_rma_number      po_headers_all.segment1%TYPE;
   l_line_num       po_lines_all.line_num%TYPE;
   l_org_id         rcv_shipment_headers.organization_id%TYPE;
   l_line_loc_num   po_line_locations_all.shipment_num%TYPE;
   l_receipt_num    rcv_shipment_headers.receipt_num%TYPE;
 BEGIN
  JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
  JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
  JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;
  -- accept input
  l_rma_number := Trim(JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('RMA Number',inputs));
  l_operating_id := Trim(JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('Operating Unit Id',inputs));--Bug#6828508
  l_line_num :=Trim(JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('RMA Line Number',inputs));
  l_receipt_num :=Trim(JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('Receipt Number',inputs));
  l_org_id := Trim(JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('Organization Id',inputs));

IF l_rma_number IS NULL THEN

   IF (l_receipt_num IS NULL OR l_org_id IS NULL) THEN
      JTF_DIAGNOSTIC_COREAPI.ErrorPrint('Some of the required inputs are missing');
      JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please refer to the parameters section for mandatory parameters for this
test');
      statusStr  := 'FAILURE';
      --errStr     := 'Some of the Required inputs are missing';
      --fixInfo    := 'Please rerun the Diagnostics using either Purchase order number or Receipt number ';
      --isFatal := 'SUCCESS';
      report     := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
      reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
      skip_execution := 1;
      RETURN;
   END IF;
ELSIF l_operating_id IS NULL THEN

  JTF_DIAGNOSTIC_COREAPI.ErrorPrint('Some of the required inputs are missing');
      JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please refer to the parameters section for mandatory parameters for this
test');
      statusStr  := 'FAILURE';
      --errStr     := 'Some of the Required inputs are missing';
      --fixInfo    := 'Please rerun the Diagnostics using either Purchase order number or Receipt number ';
      --isFatal := 'SUCCESS';
      report     := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
      reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
    skip_execution := 1;
    RETURN;

ELSE
IF (l_receipt_num IS NOT NULL AND l_org_id IS NULL) THEN
JTF_DIAGNOSTIC_COREAPI.ErrorPrint('Some of the required inputs are missing');
      JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please refer to the parameters section for mandatory parameters for this
test');
      statusStr  := 'FAILURE';
      --errStr     := 'Some of the Required inputs are missing';
      --fixInfo    := 'Please rerun the Diagnostics using either Purchase order number or Receipt number ';
      --isFatal := 'SUCCESS';
      report     := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
      reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
      skip_execution := 1;
      RETURN;
END IF;
END IF;

-- checking for valid data
if skip_execution <> 1 then
if l_rma_number is not null and l_operating_id is not null then
 begin
   select header_id
   into l_rma_count
   from oe_order_headers_all
   where org_id = l_operating_id
   and order_number = l_rma_number;
 EXCEPTION
  WHEN No_Data_Found THEN
   statusStr    := 'FAILURE';
   JTF_DIAGNOSTIC_COREAPI.ErrorPrint('No Data exists for the entered combination.');
   JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please enter valid RMA number and Operating unit id');
   report       := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
   reportClob   := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
   RETURN;
   skip_execution := 1;
  end;
end if;

if l_receipt_num is not null and l_org_id is not null then
 begin
   select shipment_header_id
   into l_rma_count
   from rcv_shipment_headers
   where receipt_num = l_receipt_num
   and ship_to_org_id = l_org_id;
 EXCEPTION
  WHEN No_Data_Found THEN
   statusStr    := 'FAILURE';
   JTF_DIAGNOSTIC_COREAPI.ErrorPrint('No Data exists for the entered combination.');
   JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please enter valid Receipt number and Organization id');
   report       := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
   reportClob   := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
   RETURN;
  skip_execution := 1;
 end;
end if;

end if; --skp_execption


-------------------------- Fixed Sqls
if skip_execution <> 1 then
IF l_rma_number IS NOT NULL AND l_operating_id IS NOT NULL AND
   l_receipt_num IS NULL AND l_org_id IS NULL AND l_line_num IS NULL then
     rma_diagnostics.rma_sql(l_operating_id,l_rma_number,rma1_sql);
END IF;

IF l_rma_number IS NOT NULL AND l_operating_id IS NOT NULL AND l_line_num IS NOT NULL
   AND l_receipt_num IS NULL AND l_org_id IS NULL THEN
   rma_diagnostics.rma_line_sql(l_operating_id,l_rma_number,l_line_num,rma1_sql);
 END IF;

IF l_rma_number IS NOT NULL AND l_operating_id IS NOT NULL
   AND l_receipt_num IS NOT NULL AND l_org_id IS NOT NULL THEN
 rma_diagnostics.rma_receipt_sql(l_operating_id,l_rma_number,l_receipt_num,l_org_id,rma1_sql) ;
 END IF;

IF l_receipt_num IS NOT NULL AND l_org_id IS NOT NULL AND
   l_rma_number IS NOT NULL AND l_operating_id IS NOT NULL AND l_line_num IS NOT NULL  THEN
 rma_rcv_diagnostics.rma_line_receipt_sql( l_operating_id,l_rma_number,l_line_num,l_receipt_num,l_org_id,rma1_sql);
END IF;

IF l_receipt_num IS NOT NULL AND l_org_id IS NOT NULL AND
   l_rma_number IS NULL AND l_line_num IS NULL THEN
rma_rcv_diagnostics.receipt_sql(l_receipt_num,l_org_id,rma1_sql);
END IF;

INV_DIAG_RCV_RCV_COMMON.build_lookup_codes(rma1_sql);
END IF;

JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;

JTF_DIAGNOSTIC_COREAPI.insert_html('<table border="1" cellpadding="1" cellspacing="1" bgcolor="#f7f7e7">'||'
<tr bgcolor="#cccc99">'||'
<th colspan="3">INDEX OF QUERIES</th>'||'
<a name="INDEX OF QUERIES"></a></tr>'||'
<tr>'||'
<td><a href="#OE_ORDER_HEADERS_ALL">OE_ORDER_HEADERS_ALL</a></td>'||'
<td><a href="#OE_ORDER_LINES_ALL">OE_ORDER_LINES_ALL</a></td>'||'
<td><a href="#MTL_SYSTEM_ITEMS">MTL_SYSTEM_ITEMS</a></td>'||'
</tr>'||'
<tr>'||'
<td><a href="#RCV_SHIPMENT_HEADERS">RCV_SHIPMENT_HEADERS</a></td>'||'
<td><a href="#RCV_SHIPMENT_LINES">RCV_SHIPMENT_LINES</a></td>'||'
<td><a href="#RCV_TRANSACTIONS">RCV_TRANSACTIONS</a></td>'||'
</tr>'||'
<tr>'||'
<td><a href="#RCV_HEADERS_INTERFACE">RCV_HEADERS_INTERFACE</a></td>'||'
<td><a href="#RCV_TRANSACTIONS_INTERFACE">RCV_TRANSACTIONS_INTERFACE</a></td>'||'
<td><a href="#PO_INTERFACE_ERRORS">PO_INTERFACE_ERRORS</a></td>'||'
</tr>'||'
<tr>'||'
<td><a href="#ORG_ORG_DEFINITIONS">ORG_ORG_DEFINITIONS</a></td>'||'
<td><a href="#MTL_PARAMETERS">MTL_PARAMETERS</a></td>'||'
<td><a href="#MTL_MATERIAL_TRANSACTIONS">MTL_MATERIAL_TRANSACTIONS</a></td>'||'
</tr>'||'
<tr>'||'
<td><a href="#MTL_TRANSACTION_TYPES">MTL_TRANSACTION_TYPES</a></td>'||'
<td><a href="#MTL_TRANSACTION_REQUEST_LINES">MTL_TRANSACTION_REQUEST_LINES</a></td>'||'
<td><a href="#MTL_MATERIAL_TRANSACTIONS_TEMP">MTL_MATERIAL_TRANSACTIONS_TEMP</a></td>'||'
</tr>'||'
<tr>'||'
<td><a href="#OE_LOT_SERIAL_NUMBERS">OE_LOT_SERIAL_NUMBERS</a></td>'||'
<td><a href="#MTL_SERIAL_NUMBERS">MTL_SERIAL_NUMBERS</a></td>'||'
<td><a href="#MTL_SERIAL_NUMBERS_TEMP">MTL_SERIAL_NUMBERS_TEMP</a></td>'||'
</tr>'||'
<tr>'||'
<td><a href="#MTL_SERIAL_NUMBERS_INTERFACE">MTL_SERIAL_NUMBERS_INTERFACE</a></td>'||'
<td><a href="#MTL_UNIT_TRANSACTIONS">MTL_UNIT_TRANSACTIONS</a></td>'||'
<td><a href="#RCV_SERIAL_TRANSACTIONS">RCV_SERIAL_TRANSACTIONS</a></td>'||'
</tr>'||'
<tr>'||'

<td><a href="#RCV_SERIAL_INTERFACE">RCV_SERIAL_INTERFACE</a></td>'||'
<td><a href="#MTL_PARAMETERS">MTL_PARAMETERS</a></td>'||'
<td><a href="#MTL_LOT_NUMBERS">MTL_LOT_NUMBERS</a></td>'||'
</tr>'||'
<tr>'||'
<td><a href="#MTL_TRANSACTION_LOT_NUMBERS">MTL_TRANSACTION_LOT_NUMBERS</a></td>'||'
<td><a href="#MTL_TRANSACTION_LOT_INTERFACE">MTL_TRANSACTION_LOT_INTERFACE</a></td>'||'
<td><a href="#MTL_TRANSACTION_LOTS_TEMP">MTL_TRANSACTION_LOTS_TEMP</a></td>'||'
</tr>'||'
<tr>'||'
<td><a href="#RCV_LOT_TRANSACTIONS">RCV_LOT_TRANSACTIONS</a></td>'||'
<td><a href="#RCV_PARAMETERS">RCV_PARAMETERS</a></td>'||'
<td><a href="#PO_SYSTEM_PARAMETERS_ALL">PO_SYSTEM_PARAMETERS_ALL</a></td>'||'
</tr>'||'
<tr>'||'
<td><a href="#FINANCIAL_SYSTEM_PARAMETERS">FINANCIAL_SYSTEM_PARAMETERS</a></td>'||'
<td><a href="#LOOKUP CODES">LOOKUP CODES</a></td>'||'
</tr>'||'
</table>');


IF skip_execution <> 1 THEN

JTF_DIAGNOSTIC_COREAPI.insert_html('<h4>RMA Information</h4>');

sql_text := rma1_sql(1);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="OE_ORDER_HEADERS_ALL"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>OE_ORDER_HEADERS_ALL</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text := rma1_sql(2);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="OE_ORDER_LINES_ALL"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>OE_ORDER_LINES_ALL</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;


sql_text := rma1_sql(3);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_SYSTEM_ITEMS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_SYSTEM_ITEMS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

JTF_DIAGNOSTIC_COREAPI.insert_html('<h4>Receipt Information</h4>');

sql_text := rma1_sql(4);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_SHIPMENT_HEADERS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_SHIPMENT_HEADERS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text := rma1_sql(5);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_SHIPMENT_LINES"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_SHIPMENT_LINES</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= rma1_sql(6);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_TRANSACTIONS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_TRANSACTIONS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text  := rma1_sql(7);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_HEADERS_INTERFACE"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_HEADERS_INTERFACE</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text := rma1_sql(8);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_TRANSACTIONS_INTERFACE"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_TRANSACTIONS_INTERFACE</b>&nbsp;&nbsp;<a href="#INDEX OF
QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text := rma1_sql(9);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="PO_INTERFACE_ERRORS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>PO_INTERFACE_ERRORS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

JTF_DIAGNOSTIC_COREAPI.insert_html('<h4>Inventory Information</h4>');

sql_text:= rma1_sql(10);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="ORG_ORG_DEFINITIONS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>ORG_ORG_DEFINITIONS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= rma1_sql(11);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_PARAMETERS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_PARAMETERS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= rma1_sql(12);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_MATERIAL_TRANSACTIONS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_MATERIAL_TRANSACTIONS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= rma1_sql(13);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_TRANSACTION_TYPES"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_TRANSACTION_TYPES</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= rma1_sql(14);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_TRANSACTION_REQUEST_LINES"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_TRANSACTION_REQUEST_LINES</b>&nbsp;&nbsp;<a href="#INDEX OF
QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= rma1_sql(15);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_MATERIAL_TRANSACTIONS_TEMP"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_MATERIAL_TRANSACTIONS_TEMP</b>&nbsp;&nbsp;<a href="#INDEX OF
QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= rma1_sql(16);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="OE_LOT_SERIAL_NUMBERS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>OE_LOT_SERIAL_NUMBERS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= rma1_sql(17);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_SERIAL_NUMBERS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_SERIAL_NUMBERS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= rma1_sql(18);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_SERIAL_NUMBERS_TEMP"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_SERIAL_NUMBERS_TEMP</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= rma1_sql(19);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_SERIAL_NUMBERS_INTERFACE"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_SERIAL_NUMBERS_INTERFACE</b>&nbsp;&nbsp;<a href="#INDEX OF
QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= rma1_sql(20);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_UNIT_TRANSACTIONS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_UNIT_TRANSACTIONS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= rma1_sql(21);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_SERIAL_TRANSACTIONS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_SERIAL_TRANSACTIONS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= rma1_sql(22);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_SERIAL_INTERFACE"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_SERIAL_INTERFACE</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= rma1_sql(23);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_LOT_NUMBERS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_LOT_NUMBERS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= rma1_sql(24);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_TRANSACTION_LOT_NUMBERS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_TRANSACTION_LOT_NUMBERS</b>&nbsp;&nbsp;<a href="#INDEX OF
QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= rma1_sql(25);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_TRANSACTION_LOT_INTERFACE"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_TRANSACTION_LOT_INTERFACE</b>&nbsp;&nbsp;<a href="#INDEX OF
QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= rma1_sql(26);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_TRANSACTION_LOTS_TEMP"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_TRANSACTION_LOTS_TEMP</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= rma1_sql(27);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_LOT_TRANSACTIONS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_LOT_TRANSACTIONS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= rma1_sql(28);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_PARAMETERS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_PARAMETERS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= rma1_sql(29);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="PO_SYSTEM_PARAMETERS_ALL"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>PO_SYSTEM_PARAMETERS_ALL</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= rma1_sql(30);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="FINANCIAL_SYSTEM_PARAMETERS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>FINANCIAL_SYSTEM_PARAMETERS</b>&nbsp;&nbsp;<a href="#INDEX OF
QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="LOOKUP CODES"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<h4>Lookup Codes</h4>');
sql_text:= rma1_sql(100);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="Serial Control"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>Serial Control</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= rma1_sql(101);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="Serial Uniqueness"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>Serial Uniqueness</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= rma1_sql(102);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="Serial Generation"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>Serial Generation</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= rma1_sql(103);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="Serial Number Status"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>Serial Number Status</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= rma1_sql(104);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="Lot Control"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>Lot Control</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= rma1_sql(105);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="Lot Generation"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>Lot Generation</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= rma1_sql(106);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="LOT Uniqueness"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>LOT Uniqueness</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;


END IF;

------------------------- Submit the sql to fwk
if skip_execution <> 1 then
JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
statusStr := 'SUCCESS';
report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
end if;

EXCEPTION
  when others then
    JTF_DIAGNOSTIC_COREAPI.errorprint('Error: '||sqlerrm);
    JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('This is the exception handler');
    statusStr := 'FAILURE';
    errStr := sqlerrm ||' occurred in script Exception handled';
    isFatal := 'FALSE';
    report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
    reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
END runTest;


END INV_DIAG_RCV_RMA;

/
