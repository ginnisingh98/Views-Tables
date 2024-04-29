--------------------------------------------------------
--  DDL for Package Body INV_DIAG_RCV_PO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DIAG_RCV_PO" AS
/* $Header: INVDPO1B.pls 120.2 2008/02/01 05:59:19 ssadasiv noship $ */
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
  str := 'Purchase Order';
END getTestName;

------------------------------------------------------------
-- procedure to report name back to framework
------------------------------------------------------------
PROCEDURE getComponentName(str OUT NOCOPY VARCHAR2) IS
BEGIN
  str := 'PO';
END getComponentName;

------------------------------------------------------------
-- procedure to report test description back to framework
------------------------------------------------------------
PROCEDURE getTestDesc(str OUT NOCOPY VARCHAR2) IS
BEGIN
  str := 'This diagnostic test will collect setup and transactional data for a specific purchase order.'||'<BR/>'||
         'The data collected can aid in the resolution of issues involving purchase order.'||'<BR/>'||
         '<b>Parameters</b>'||'<BR/>'||
         'This script requires either the combination of Purchase Order and Operating Unit Id or Receipt Number and Organization Id'||
         ' as mandatory parameters.'||'<BR/>'||'Purchase Order Line Number and Purchase Order Line Location Number'||
         ' are optional.'||' Alternatively all parameters can be entered at the same time.';

END getTestDesc;


------------------------------------------------------------
-- procedure to provide/populate  the default parameters for the test case.
-- There are 6 parameters in this Data Collection.
------------------------------------------------------------
PROCEDURE getDefaultTestParams(defaultInputValues OUT NOCOPY JTF_DIAG_INPUTTBL) IS
  tempInput JTF_DIAG_INPUTTBL;
BEGIN
  tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
  tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'Operating Unit Id','LOV-oracle.apps.inv.diag.lov.OperatingLov');
  tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'PO Number','LOV-oracle.apps.inv.diag.lov.PONumberLov');
  tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'PO Line Number','LOV-oracle.apps.inv.diag.lov.POlineLov');    -- LOV-oracle.apps.inv.diag.lov.ItemLov
  tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'PO Line Location Number','LOV-oracle.apps.inv.diag.lov.POlinelocLov');  -- LOV-oracle.apps.inv.diag.lov.ItemLov
  tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'Organization Id','LOV-oracle.apps.inv.diag.lov.OrganizationLov');
  tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'Receipt Number','LOV-oracle.apps.inv.diag.lov.ReceiptNumLov');
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
   l_count     NUMBER := 0;

   sql_text    VARCHAR2(6000);   -- Text variable to hold the sqls

   po_sql      INV_DIAG_RCV_PO_COMMON.sqls_list; -- Table of varchar2
   l_skip_rest VARCHAR2(1):= 'N';             -- Flag for skipping a Data collection Package call.

   dummy_num        NUMBER;
   l_operating_id   po_headers_all.org_id%TYPE;
   l_po_number      po_headers_all.segment1%TYPE;
   l_line_num       po_lines_all.line_num%TYPE;
   l_org_id         rcv_shipment_headers.organization_id%TYPE;
   l_line_loc_num   po_line_locations_all.shipment_num%TYPE;
   l_receipt_num    rcv_shipment_headers.receipt_num%TYPE;

 BEGIN
  JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
  JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
  JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;
  -- accept input
  l_po_number      := Trim(JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('PO Number',inputs));
  l_operating_id   := Trim(JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('Operating Unit Id',inputs));
  l_line_num       := Trim(JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('PO Line Number',inputs));
  l_line_loc_num   := Trim(JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('PO Line Location Number',inputs));
  l_receipt_num    := Trim(JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('Receipt Number',inputs));
  l_org_id         := Trim(JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('Organization Id',inputs));

  -----------------------------------------
  -- Validation part.
  -----------------------------------------
  -- 1.If PO Number is Entered,Operating Unit Id is Mandatory
  -- 2.If Receipt Number is Entered,Organization Id is Mandatory
  -- 3.The combination of PO and Receipt Number can be Entered
  ------------------------------------------
IF l_po_number IS NULL THEN

   IF (l_receipt_num IS NULL OR l_org_id IS NULL) THEN
      JTF_DIAGNOSTIC_COREAPI.ErrorPrint('Some of the required inputs are missing.');
      JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please refer to the parameters section for mandatory parameters for this test.');
      statusStr  := 'FAILURE';
      report     := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
      reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
      RETURN;
   END IF;
ELSIF l_operating_id IS NULL THEN
      JTF_DIAGNOSTIC_COREAPI.ErrorPrint('Some of the required inputs are missing.');
      JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please refer to the parameters section for mandatory parameters for this test.');
      statusStr  := 'FAILURE';
      report     := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
      reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
      RETURN;
ELSE
IF (l_receipt_num IS NOT NULL AND l_po_number IS NULL AND l_org_id IS NULL) THEN
    JTF_DIAGNOSTIC_COREAPI.ErrorPrint('Some of the required inputs are missing.');
    JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please refer to the parameters section for mandatory parameters for this test.');
    statusStr    := 'FAILURE';
    report       := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
    reportClob   := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
    RETURN;
END IF;
END IF;

-----------------------------------------------
-- Check if the Entered Combinations are valid
-----------------------------------------------

IF l_operating_id IS NOT NULL AND l_po_number IS NOT NULL AND l_receipt_num IS NOT NULL AND l_org_id IS NOT NULL
   AND (l_line_num IS NOT NULL OR l_line_loc_num IS NOT NULL) THEN
SELECT Count(1)
INTO l_count
FROM po_headers_all ph,
po_lines_all pl,
po_line_locations_all pll,
rcv_shipment_headers rsh,
rcv_shipment_lines rsl
WHERE rsh.shipment_header_id=rsl.shipment_header_id
AND rsl.po_header_id=ph.po_header_id
AND rsl.po_line_id=pl.po_line_id
AND rsl.po_line_location_id=pll.line_location_id
AND pl.po_line_id=pll.po_line_id
AND pl.po_header_id=ph.po_header_id
AND pl.line_num=Nvl(l_line_num,pl.line_num)
AND pll.shipment_num=Nvl(l_line_loc_num,pll.shipment_num)
AND ph.segment1=l_po_number
AND ph.org_id=l_operating_id
AND rsh.receipt_num=l_receipt_num
AND rsh.ship_to_org_id=l_org_id;
IF l_count = 0 THEN
statusStr    := 'FAILURE';
JTF_DIAGNOSTIC_COREAPI.ErrorPrint('No Data exists for the entered combination.');
JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please enter valid data for all the input parameters.');
report       := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
reportClob   := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
RETURN;
END IF;
END IF;


IF l_operating_id IS NOT NULL AND l_po_number IS NOT NULL AND l_receipt_num IS NOT NULL AND l_org_id IS NOT NULL THEN
SELECT Count(1)
INTO l_count
FROM po_headers_all ph,
rcv_shipment_headers rsh,
rcv_shipment_lines rsl
WHERE rsh.shipment_header_id=rsl.shipment_header_id
AND rsl.po_header_id=ph.po_header_id
AND ph.segment1=l_po_number
AND ph.org_id=l_operating_id
AND rsh.receipt_num=l_receipt_num
AND rsh.ship_to_org_id=l_org_id;
IF l_count = 0 THEN
statusStr    := 'FAILURE';
JTF_DIAGNOSTIC_COREAPI.ErrorPrint('No Data exists for the entered combination.');
JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please enter a valid Purchase order number,Operating unit id,Receipt num and Organization_id.');
report       := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
reportClob   := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
RETURN;
END IF;
END IF;

IF l_operating_id IS NOT NULL AND l_po_number IS NOT NULL THEN
SELECT Count(1)
INTO l_count
FROM po_headers_all ph
where   ph.segment1=l_po_number
AND   ph.org_id=l_operating_id;
IF l_count = 0 THEN
statusStr    := 'FAILURE';
JTF_DIAGNOSTIC_COREAPI.ErrorPrint('No Data exists for the entered combination.');
JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please enter a valid Purchase order number and Operating unit id.');
report       := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
reportClob   := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
RETURN;
END IF;
END IF;

IF l_receipt_num IS NOT NULL AND l_org_id IS NOT NULL THEN
SELECT Count(1)
INTO l_count
FROM rcv_shipment_headers rsh
WHERE receipt_source_code='VENDOR'
AND rsh.receipt_num=l_receipt_num
AND rsh.ship_to_org_id=l_org_id;
IF l_count = 0 THEN
statusStr    := 'FAILURE';
   JTF_DIAGNOSTIC_COREAPI.ErrorPrint('No Data exists for the entered combination.');
   JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please enter a valid Receipt number and Organization id.');
   report       := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
   reportClob   := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
RETURN;
END IF;
END IF;

------------------------------------------------------------------------
-- Call Appropriate Procedures based on the input parameters
-- Set l_skip_rest to "Y" so that subsequent procedure call are skipped
------------------------------------------------------------------------
-- If all the Input fields are Entered use the below call
IF l_po_number     IS NOT NULL AND
   l_operating_id  IS NOT NULL AND
   l_receipt_num   IS NOT NULL AND
   l_org_id        IS NOT NULL AND
   l_skip_rest = 'N' THEN

  INV_DIAG_RCV_PO_COMMON.build_all_sql(l_operating_id,l_po_number,l_line_num,l_line_loc_num,l_org_id,l_receipt_num,po_sql);
  l_skip_rest := 'Y';
END if;

-- Below procedure will handle both PO,OU and PO,OU,PLL,POL
IF l_po_number     IS NOT NULL  AND
   l_operating_id  IS NOT NULL  AND
   l_skip_rest = 'N' THEN

   INV_DIAG_RCV_PO_COMMON.build_po_all_sql(l_operating_id,l_po_number,l_line_num,l_line_loc_num,po_sql);
   l_skip_rest := 'Y';
END if;

IF l_receipt_num    IS NOT NULL AND
   l_org_id         IS NOT NULL AND
   l_skip_rest = 'N' THEN

  INV_DIAG_RCV_RCV_COMMON.build_rcv_sql(l_org_id,l_receipt_num,po_sql);
  l_skip_rest := 'Y';
END IF;

-- Call the procedure to get the lookup codes
INV_DIAG_RCV_RCV_COMMON.build_lookup_codes(po_sql);

-----------------------------------------
-- Code to Build the Index of HTML tables
-----------------------------------------
JTF_DIAGNOSTIC_COREAPI.insert_html('<table border="1" cellpadding="1" cellspacing="1" bgcolor="#f7f7e7">'||'
<tr bgcolor="#cccc99">'||'
<th colspan="3">INDEX OF QUERIES</th>'||'
<a name="INDEX OF QUERIES"></a></tr>'||'
<tr>'||'
<td><a href="#PO_HEADERS_ALL">PO_HEADERS_ALL</a></td>'||'
<td><a href="#PO_LINES_ALL">PO_LINES_ALL</a></td>'||'
<td><a href="#PO_LINE_LOCATIONS_ALL">PO_LINE_LOCATIONS_ALL</a></td>'||'
</tr>'||'
<tr>'||'
<td><a href="#GL_CODE_COMBINATIONS">GL_CODE_COMBINATIONS</a></td>'||'
<td><a href="#RCV_RECEIVING_SUB_LEDGER">RCV_RECEIVING_SUB_LEDGER</a></td>'||'
<td><a href="#AP_INVOICE_LINES_ALL">AP_INVOICE_LINES_ALL</a></td>'||'
</tr>'||'
<tr>'||'
<td><a href="#AP_INVOICES_ALL">AP_INVOICES_ALL</a></td>'||'
<td><a href="#AP_INVOICE_LINES_INTERFACE">AP_INVOICE_LINES_INTERFACE</a></td>'||'
<td><a href="#AP_INVOICES_INTERFACE">AP_INVOICES_INTERFACE</a></td>'||'
</tr>'||'
<tr>'||'
<td><a href="#RCV_SHIPMENT_HEADERS">RCV_SHIPMENT_HEADERS</a></td>'||'
<td><a href="#RCV_SHIPMENT_LINES">RCV_SHIPMENT_LINES</a></td>'||'
<td><a href="#RCV_TRANSACTIONS">RCV_TRANSACTIONS</a></td>'||'
</tr>'||'
<tr>'||'
<td><a href="#MTL_SUPPLY">MTL_SUPPLY</a></td>'||'
<td><a href="#RCV_SUPPLY">RCV_SUPPLY</a></td>'||'
<td><a href="#RCV_HEADERS_INTERFACE">RCV_HEADERS_INTERFACE</a></td>'||'
</tr>'||'
<tr>'||'
<td><a href="#RCV_TRANSACTIONS_INTERFACE">RCV_TRANSACTIONS_INTERFACE</a></td>'||'
<td><a href="#PO_INTERFACE_ERRORS">PO_INTERFACE_ERRORS</a></td>'||'
<td><a href="#MTL_SYSTEM_ITEMS">MTL_SYSTEM_ITEMS</a></td>'||'
</tr>'||'
<tr>'||'
<td><a href="#MTL_MATERIAL_TRANSACTIONS">MTL_MATERIAL_TRANSACTIONS</a></td>'||'
<td><a href="#MTL_TRANSACTION_TYPES">MTL_TRANSACTION_TYPES</a></td>'||'
<td><a href="#MTL_TXN_REQUEST_LINES">MTL_TXN_REQUEST_LINES</a></td>'||'
</tr>'||'
<tr>'||'
<td><a href="#MTL_MATERIAL_TRANSACTIONS_TEMP">MTL_MATERIAL_TRANSACTIONS_TEMP</a></td>'||'
<td><a href="#ORG_ORGANIZATION_DEFINITIONS">ORG_ORGANIZATION_DEFINITIONS</a></td>'||'
<td><a href="#MTL_PARAMETERS">MTL_PARAMETERS</a></td>'||'
</tr>'||'
<tr>'||'
<td><a href="#RCV_PARAMETERS">RCV_PARAMETERS</a></td>'||'
<td><a href="#PO_SYSTEM_PARAMETERS_ALL">PO_SYSTEM_PARAMETERS_ALL</a></td>'||'
<td><a href="#FINANCIALS_SYSTEM_PARAMS_ALL">FINANCIALS_SYSTEM_PARAMS_ALL</a></td>'||'
</tr>'||'
<tr>'||'
<td><a href="#MTL_SERIAL_NUMBERS">MTL_SERIAL_NUMBERS</a></td>'||'
<td><a href="#MTL_SERIAL_NUMBERS_TEMP">MTL_SERIAL_NUMBERS_TEMP</a></td>'||'
<td><a href="#MTL_SERIAL_NUMBERS_INTERFACE">MTL_SERIAL_NUMBERS_INTERFACE</a></td>'||'
</tr>'||'
<tr>'||'
<td><a href="#MTL_UNIT_TRANSACTIONS">MTL_UNIT_TRANSACTIONS</a></td>'||'
<td><a href="#RCV_SERIALS_SUPPLY">RCV_SERIALS_SUPPLY</a></td>'||'
<td><a href="#RCV_SERIAL_TRANSACTIONS">RCV_SERIAL_TRANSACTIONS</a></td>'||'
</tr>'||'
<tr>'||'
<td><a href="#RCV_SERIALS_INTERFACE">RCV_SERIALS_INTERFACE</a></td>'||'
<td><a href="#MTL_LOT_NUMBERS">MTL_LOT_NUMBERS</a></td>'||'
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
<td><a href="#Lookup Codes">LOOKUP CODES</a></td>'||'
</tr>'||'
</table>');

-------------------
-- Execute the Sqls
-------------------
JTF_DIAGNOSTIC_COREAPI.insert_html('<h4>Purchase Order Details</h4>');
sql_text := po_sql(1);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="PO_HEADERS_ALL"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>PO_HEADERS_ALL</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text := po_sql(2);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="PO_LINES_ALL"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>PO_LINES_ALL</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text := po_sql(3);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="PO_LINE_LOCATIONS_ALL"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>PO_LINE_LOCATIONS_ALL</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text := po_sql(4);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="PO_DISTRIBUTIONS_ALL"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>PO_DISTRIBUTIONS_ALL</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text := po_sql(5);
JTF_DIAGNOSTIC_COREAPI.insert_html('<h4>Invoice Details</h4>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="GL_CODE_COMBINATIONS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>GL_CODE_COMBINATIONS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= po_sql(6);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_RECEIVING_SUB_LEDGER"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_RECEIVING_SUB_LEDGER</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text  := po_sql(7);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="AP_INVOICE_LINES_ALL"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>AP_INVOICE_LINES_ALL</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text := po_sql(8);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="AP_INVOICES_ALL"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>AP_INVOICES_ALL</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text := po_sql(9);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="AP_INVOICE_LINES_INTERFACE"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>AP_INVOICE_LINES_INTERFACE</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= po_sql(10);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="AP_INVOICES_INTERFACE"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>AP_INVOICES_INTERFACE</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= po_sql(11);

JTF_DIAGNOSTIC_COREAPI.insert_html('<h4>Receipt Details</h4>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_SHIPMENT_HEADERS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_SHIPMENT_HEADERS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= po_sql(12);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_SHIPMENT_LINES"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_SHIPMENT_LINES</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= po_sql(13);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_TRANSACTIONS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_TRANSACTIONS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= po_sql(14);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_SUPPLY"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_SUPPLY</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= po_sql(15);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_SUPPLY"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_SUPPLY</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= po_sql(16);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_HEADERS_INTERFACE"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_HEADERS_INTERFACE</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= po_sql(17);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_TRANSACTIONS_INTERFACE"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_TRANSACTIONS_INTERFACE</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= po_sql(18);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="PO_INTERFACE_ERRORS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>PO_INTERFACE_ERRORS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= po_sql(19);

JTF_DIAGNOSTIC_COREAPI.insert_html('<h4>Inventory Details</h4>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_SYSTEM_ITEMS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_SYSTEM_ITEMS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= po_sql(20);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_MATERIAL_TRANSACTIONS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_MATERIAL_TRANSACTIONS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= po_sql(21);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_TRANSACTION_TYPES"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_TRANSACTION_TYPES</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= po_sql(22);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_TXN_REQUEST_LINES"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_TXN_REQUEST_LINES</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= po_sql(23);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_MATERIAL_TRANSACTIONS_TEMP"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_MATERIAL_TRANSACTIONS_TEMP</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= po_sql(24);

JTF_DIAGNOSTIC_COREAPI.insert_html('<h4>Organization Setup Details</h4>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="ORG_ORGANIZATION_DEFINITIONS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>ORG_ORGANIZATION_DEFINITIONS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= po_sql(25);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_PARAMETERS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_PARAMETERS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= po_sql(26);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_PARAMETERS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_PARAMETERS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= po_sql(27);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="PO_SYSTEM_PARAMETERS_ALL"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>PO_SYSTEM_PARAMETERS_ALL</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= po_sql(28);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="FINANCIALS_SYSTEM_PARAMS_ALL"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>FINANCIALS_SYSTEM_PARAMS_ALL</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= po_sql(29);

JTF_DIAGNOSTIC_COREAPI.insert_html('<h4>Lot and Serial Transaction Details</h4>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_SERIAL_NUMBERS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_SERIAL_NUMBERS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= po_sql(30);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_SERIAL_NUMBERS_TEMP"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_SERIAL_NUMBERS_TEMP</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= po_sql(31);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_SERIAL_NUMBERS_INTERFACE"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_SERIAL_NUMBERS_INTERFACE</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= po_sql(32);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_UNIT_TRANSACTIONS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_UNIT_TRANSACTIONS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= po_sql(33);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_SERIALS_SUPPLY"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_SERIALS_SUPPLY</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= po_sql(34);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_SERIAL_TRANSACTIONS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_SERIAL_TRANSACTIONS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= po_sql(35);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_SERIALS_INTERFACE"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_SERIALS_INTERFACE</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= po_sql(36);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_LOT_NUMBERS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_LOT_NUMBERS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= po_sql(37);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_TRANSACTION_LOT_NUMBERS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_TRANSACTION_LOT_NUMBERS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= po_sql(38);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_TRANSACTION_LOTS_INTERFACE"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_TRANSACTION_LOTS_INTERFACE</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= po_sql(39);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="MTL_TRANSACTION_LOTS_TEMP"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>MTL_TRANSACTION_LOTS_TEMP</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= po_sql(40);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_LOTS_SUPPLY"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_LOTS_SUPPLY</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= po_sql(41);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_LOT_TRANSACTIONS"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_LOT_TRANSACTIONS</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= po_sql(42);
JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="RCV_LOTS_INTERFACE"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>RCV_LOTS_INTERFACE</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

JTF_DIAGNOSTIC_COREAPI.insert_html('<a name="LOOKUP CODES"></a>');
JTF_DIAGNOSTIC_COREAPI.insert_html('<h4>Lookup Codes</h4>');
sql_text:= po_sql(100);
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>Serial Control</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= po_sql(101);
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>Serial Uniqueness</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= po_sql(102);
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>Serial Generation</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= po_sql(103);
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>Serial Number Status</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= po_sql(104);
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>Lot Control</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= po_sql(105);
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>Lot Generation</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
JTF_DIAGNOSTIC_COREAPI.BRPrint;

sql_text:= po_sql(106);
JTF_DIAGNOSTIC_COREAPI.insert_html('<b>LOT Uniqueness</b>&nbsp;&nbsp;<a href="#INDEX OF QUERIES">[Top]</a>');
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sql_text,'');
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
    fixInfo := 'Unexpected Exception in INVDPO1B.pls';
    isFatal := 'SUCCESS';
    report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
    reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
END runTest;


END INV_DIAG_RCV_PO;

/
