--------------------------------------------------------
--  DDL for Package Body BOM_DIAGUNITTEST_EXPDATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_DIAGUNITTEST_EXPDATA" as
/* $Header: BOMDGEXB.pls 120.1 2007/12/26 09:49:25 vggarg noship $ */
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
 sqltxt      VARCHAR2(9999);  -- SQL select statement
 c_username  VARCHAR2(50);   -- accept input for username
 statusStr   VARCHAR2(50);   -- SUCCESS or FAILURE
 errStr      VARCHAR2(4000); -- error message
 fixInfo     VARCHAR2(4000); -- fix tip
 isFatal     VARCHAR2(50);   -- TRUE or FALSE
 num_rows    NUMBER;
 row_limit   NUMBER;
 l_item_id   NUMBER;
 l_org_id    NUMBER;
 l_count     NUMBER;
 l_ret_status      BOOLEAN;
 l_status          VARCHAR2 (1);
 l_industry        VARCHAR2 (1);
 l_oracle_schema   VARCHAR2 (30);

  CURSOR c_item_valid (cp_n_item_id IN NUMBER, cp_n_org_id IN NUMBER) IS
       SELECT count(*)
       FROM   mtl_system_items_b
       WHERE  inventory_item_id = cp_n_item_id
       AND    organization_id   = nvl(cp_n_org_id,organization_id);

BEGIN
JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;

 /*Initializing local vars */
 row_limit :=1000; /* Set Row Limit to 1000 (i.e.) Max Number of records to be fetched by each sql*/
 l_count := 0;

-- accept input
l_org_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('OrgId',inputs);
l_item_id :=JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('ItemId',inputs);

   If l_item_id is NULL then
	JTF_DIAGNOSTIC_COREAPI.errorprint('Input Item Id is mandatory.');
	JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(' Please provide a valid value for the Item Id.');
	statusStr := 'FAILURE';
	isFatal := 'TRUE';
	fixInfo := ' Please review the error message below and take corrective action. ';
	errStr  := ' Invalid value for input field Item Id. It is a mandatory input.';

	report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
	reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
	Return;
   Else /* l_item_id is not null */
	OPEN  c_item_valid (l_item_id, l_org_id);
	FETCH c_item_valid INTO l_count;
	CLOSE c_item_valid;

	IF (l_count IS NULL) OR (l_count = 0)  THEN
	    JTF_DIAGNOSTIC_COREAPI.errorprint('Invalid Item and Organization Combination');
            JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please enter right combination of Item and Organization ');
            statusStr := 'FAILURE';
            errStr := 'Invalid Item and Organization Combination';
            fixInfo := ' Please review the error message below and take corrective action. ';
            isFatal := 'TRUE';
            report  := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
            reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
            RETURN;
	END IF;
   End If; /* l_item_id is null */

/* Start of the diagnostic test script */
/* Get the application installation info. References to Data Dictionary Objects without schema name
included in WHERE predicate are not allowed (GSCC Check: file.sql.47). Schema name has to be passed
as an input parameter to JTF_DIAGNOSTIC_COREAPI.Column_Exists API. */

l_ret_status :=      fnd_installation.get_app_info ('BOM'
                                   , l_status
                                   , l_industry
                                   , l_oracle_schema
                                    );

/*JTF_DIAGNOSTIC_COREAPI.Line_Out(' l_oracle_schema: '||l_oracle_schema);*/

sqltxt :=	' Select '||
		'    BE.TOP_BILL_SEQUENCE_ID			"TOP BILL SEQUENCE ID",			'||
		'    BE.BILL_SEQUENCE_ID			"BILL SEQUENCE ID",			'||
		'    BE.ORGANIZATION_ID				"ORGANIZATION ID",			'||
		'    BE.EXPLOSION_TYPE				"EXPLOSION TYPE",			'||
		'    BE.COMPONENT_SEQUENCE_ID			"COMPONENT SEQUENCE ID",		'||
		'    BE.COMPONENT_ITEM_ID			"COMPONENT ITEM ID",			'||
		'    BE.PLAN_LEVEL				"PLAN LEVEL",				'||
		'    BE.EXTENDED_QUANTITY			"EXTENDED QUANTITY",			'||
		'    BE.SORT_ORDER				"SORT ORDER",				'||
		'    to_char(BE.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'') "CREATION DATE",		'||
		'    BE.CREATED_BY				"CREATED BY",				'||
		'    to_char(BE.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "LAST UPDATE DATE",	'||
		'    BE.LAST_UPDATED_BY				"LAST UPDATED BY",			'||
		'    BE.TOP_ITEM_ID				"TOP ITEM ID",				'||
		'    BE.CONTEXT					"CONTEXT",				'||
		'    BE.ATTRIBUTE1				"ATTRIBUTE1",				'||
		'    BE.ATTRIBUTE2				"ATTRIBUTE2",				'||
		'    BE.ATTRIBUTE3				"ATTRIBUTE3",				'||
		'    BE.ATTRIBUTE4				"ATTRIBUTE4",				'||
		'    BE.ATTRIBUTE5				"ATTRIBUTE5",				'||
		'    BE.ATTRIBUTE6				"ATTRIBUTE6",				'||
		'    BE.ATTRIBUTE7				"ATTRIBUTE7",				'||
		'    BE.ATTRIBUTE8				"ATTRIBUTE8",				'||
		'    BE.ATTRIBUTE9				"ATTRIBUTE9",				'||
		'    BE.ATTRIBUTE10				"ATTRIBUTE10",				'||
		'    BE.ATTRIBUTE11				"ATTRIBUTE11",				'||
		'    BE.ATTRIBUTE12				"ATTRIBUTE12",				'||
		'    BE.ATTRIBUTE13				"ATTRIBUTE13",				'||
		'    BE.ATTRIBUTE14				"ATTRIBUTE14",				'||
		'    BE.ATTRIBUTE15				"ATTRIBUTE15",				'||
		'    BE.COMPONENT_QUANTITY			"COMPONENT QUANTITY",			'||
		'    BE.SO_BASIS				"SO BASIS",				'||
		'    BE.OPTIONAL				"OPTIONAL",				'||
		'    BE.MUTUALLY_EXCLUSIVE_OPTIONS		"MUTUALLY EXCLUSIVE OPTIONS",		'||
		'    BE.CHECK_ATP				"CHECK ATP",				'||
		'    BE.SHIPPING_ALLOWED			"SHIPPING ALLOWED",			'||
		'    BE.REQUIRED_TO_SHIP			"REQUIRED TO SHIP",			'||
		'    BE.REQUIRED_FOR_REVENUE			"REQUIRED FOR REVENUE",			'||
		'    BE.INCLUDE_ON_SHIP_DOCS			"INCLUDE ON SHIP DOCS",			'||
		'    BE.INCLUDE_ON_BILL_DOCS			"INCLUDE ON BILL DOCS",			'||
		'    BE.LOW_QUANTITY				"LOW QUANTITY",				'||
		'    BE.HIGH_QUANTITY				"HIGH QUANTITY",			'||
		'    BE.PICK_COMPONENTS				"PICK COMPONENTS",			'||
		'    BE.PRIMARY_UOM_CODE			"PRIMARY UOM CODE",			'||
		'    BE.PRIMARY_UNIT_OF_MEASURE			"PRIMARY UNIT OF MEASURE",		'||
		'    BE.BASE_ITEM_ID				"BASE ITEM ID",				'||
		'    BE.ATP_COMPONENTS_FLAG			"ATP COMPONENTS FLAG",			'||
		'    BE.ATP_FLAG				"ATP FLAG",				'||
		'    BE.BOM_ITEM_TYPE				"BOM ITEM TYPE",			'||
		'    BE.PICK_COMPONENTS_FLAG			"PICK COMPONENTS FLAG",			'||
		'    BE.REPLENISH_TO_ORDER_FLAG			"REPLENISH TO ORDER FLAG",		'||
		'    BE.SHIPPABLE_ITEM_FLAG			"SHIPPABLE ITEM FLAG",			'||
		'    BE.CUSTOMER_ORDER_FLAG			"CUSTOMER ORDER FLAG",			'||
		'    BE.INTERNAL_ORDER_FLAG			"INTERNAL ORDER FLAG",			'||
		'    BE.CUSTOMER_ORDER_ENABLED_FLAG		"CUSTOMER ORDER ENABLED FLAG",		'||
		'    BE.INTERNAL_ORDER_ENABLED_FLAG		"INTERNAL ORDER ENABLED FLAG",		'||
		'    BE.SO_TRANSACTIONS_FLAG			"SO TRANSACTIONS FLAG",			'||
		'    BE.DESCRIPTION				"DESCRIPTION",				'||
		'    BE.ASSEMBLY_ITEM_ID			"ASSEMBLY ITEM ID",			'||
		'    BE.COMPONENT_CODE				"COMPONENT CODE",			'||
		'    BE.LOOP_FLAG				"LOOP FLAG",				'||
		'    BE.PARENT_BOM_ITEM_TYPE			"PARENT BOM ITEM TYPE",			'||
		'    BE.OPERATION_SEQ_NUM			"OPERATION SEQ NUM",			'||
		'    BE.ITEM_NUM				"ITEM NUM",				'||
		'    to_char(BE.EFFECTIVITY_DATE,''DD-MON-YYYY HH24:MI:SS'') "EFFECTIVITY DATE",'||
		'    to_char(BE.DISABLE_DATE,''DD-MON-YYYY HH24:MI:SS'')	     "DISABLE DATE",	'||
		'    to_char(BE.IMPLEMENTATION_DATE,''DD-MON-YYYY HH24:MI:SS'')	"IMPLEMENTATION DATE",	'||
		'    BE.REXPLODE_FLAG				"REXPLODE FLAG",			'||
		'    BE.COMMON_BILL_SEQUENCE_ID			"COMMON BILL SEQUENCE ID",		'||
		'    BE.COMP_BILL_SEQ_ID			"COMP BILL SEQ ID",			'||
		'    BE.COMP_COMMON_BILL_SEQ_ID			"COMP COMMON BILL SEQ ID",		'||
		'    BE.EXPLODE_GROUP_ID			"EXPLODE GROUP ID",			'||
		'    BE.NUM_COL1				"NUM COL1",				'||
		'    BE.NUM_COL2				"NUM COL2",				'||
		'    BE.NUM_COL3				"NUM COL3",				'||
		'    to_char(BE.DATE_COL1,''DD-MON-YYYY HH24:MI:SS'')	"DATE COL1",			'||
		'    to_char(BE.DATE_COL2,''DD-MON-YYYY HH24:MI:SS'')	"DATE COL2",			'||
		'    to_char(BE.DATE_COL3,''DD-MON-YYYY HH24:MI:SS'')	"DATE COL3",			'||
		'    BE.CHAR_COL1				"CHAR COL1",				'||
		'    BE.CHAR_COL2				"CHAR COL2",				'||
		'    BE.CHAR_COL3				"CHAR COL3",				'||
		'    BE.AUTO_REQUEST_MATERIAL			"AUTO REQUEST MATERIAL",		'||
		'    BE.INCLUDE_IN_COST_ROLLUP			"INCLUDE IN COST ROLLUP",		'||
		'    BE.COMPONENT_YIELD_FACTOR			"COMPONENT YIELD FACTOR",		'||
		'    BE.PLANNING_FACTOR				"PLANNING FACTOR",			'||
		'    BE.CHANGE_NOTICE				"CHANGE NOTICE",			'||
		'    BE.PARENT_SORT_ORDER			"PARENT SORT ORDER"			'||
		'    ,BE.SUGGESTED_VENDOR_NAME			"SUGGESTED VENDOR NAME"			'||
		'    ,BE.VENDOR_ID				"VENDOR ID"				'||
		'    ,BE.UNIT_PRICE				"UNIT PRICE"				'||
		'    ,BE.REQUEST_ID				"REQUEST ID"				'||
		'    ,BE.BASIS_TYPE				"BASIS TYPE"				'||
		'    ,BE.SOURCE_BILL_SEQUENCE_ID				"SOURCE BILL SEQUENCE ID"				'||
		'    ,BE.COMMON_COMPONENT_SEQUENCE_ID				"COMMON COMPONENT SEQUENCE ID"				'||
		'    ,BE.COMP_SOURCE_BILL_SEQ_ID				"COMP SOURCE BILL SEQ ID"				'||
		'    FROM   bom_explosions  be			WHERE 1=1				';

		if l_org_id is not null then
		   sqltxt :=sqltxt||' and  be.organization_id =  '||l_org_id;
		end if;

		if l_item_id is not null then
		   sqltxt :=sqltxt||' and be.top_item_id =  '||l_item_id;
		end if;

		sqltxt := sqltxt || ' and rownum< '||row_limit;
		sqltxt := sqltxt || ' order by be.organization_id,be.sort_order ';
		num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Bom Explosions Data ');
		If (num_rows = row_limit -1 ) Then
			JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
		End If;
		statusStr := 'SUCCESS';
		isFatal := 'FALSE';

 <<l_test_end>>
 JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/><BR/>This data collection script completed as expected <BR/>');
 report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
 reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;

EXCEPTION
 when others then
     JTF_DIAGNOSTIC_COREAPI.errorprint('Error: '||sqlerrm);
     JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('If this error repeats, please contact Oracle Support Services');
     statusStr := 'FAILURE';
     errStr := sqlerrm ||' occurred in script. ';
     fixInfo := 'Unexpected Exception in BOMDGEXB.pls';
     isFatal := 'FALSE';
     report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
     reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
END runTest;

PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'Bom Explosions Data Collection';
END getComponentName;

PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2) IS
BEGIN
descStr := ' This data collection script collects data about Bom Explosions Details.  <BR/>
	     Input for field ItemId is mandatory. ';
END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'Bom Explosions Data Collection';
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
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'OrgId','LOV-oracle.apps.bom.diag.lov.OrganizationLov');-- Lov name modified to OrgId for bug 6412260
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'ItemId','LOV-oracle.apps.bom.diag.lov.ItemLov'); -- Lov name modified to ItemId for bug 6412260
defaultInputValues := tempInput;
EXCEPTION
when others then
defaultInputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
END getDefaultTestParams;

Function getTestMode return INTEGER IS
BEGIN
return JTF_DIAGNOSTIC_ADAPTUTIL.ADVANCED_MODE;

END getTestMode;

END BOM_DIAGUNITTEST_EXPDATA;

/
