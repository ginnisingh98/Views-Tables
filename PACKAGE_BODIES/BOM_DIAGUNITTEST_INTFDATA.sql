--------------------------------------------------------
--  DDL for Package Body BOM_DIAGUNITTEST_INTFDATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_DIAGUNITTEST_INTFDATA" as
/* $Header: BOMDGINB.pls 120.1 2007/12/26 09:53:53 vggarg noship $ */
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
 num_rows   NUMBER;
 row_limit   NUMBER;
 l_item_id   NUMBER;
 l_org_id    NUMBER;
 l_type	     VARCHAR2(40);
 l_ret_status      BOOLEAN;
 l_status          VARCHAR2 (1);
 l_industry        VARCHAR2 (1);
 l_oracle_schema   VARCHAR2 (30);
 l_table_exists	   NUMBER;

BEGIN
JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;

/* set limit of records to be fetched*/
 row_limit :=1000;

-- accept input
 l_type	   := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('Type',inputs);
 /* Allowed values for input parameter type
	1 - Inv
	2 - Bom
	3 - Rtg
	4 - Eng
 */

/* Vaaidate input values for TYPE */
 If (l_type is null) or ( upper(l_type) not in ('INV', 'BOM','RTG','ENG')) Then
	JTF_DIAGNOSTIC_COREAPI.errorprint('Invalid input Type');
	JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(' Please provide a valid value for the input field Type. ');
	statusStr := 'FAILURE';
	isFatal := 'TRUE';
	fixInfo := ' Please review the error message below and take corrective action. ';
	errStr  := ' Invalid value for input field Type. ';

	report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
	reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;

Else /* valid value for input type  */
    If upper(l_type)='INV' Then
   /* Items Interface Details */

/* Get the application installation info. References to Data Dictionary Objects without schema name
included in WHERE predicate are not allowed (GSCC Check: file.sql.47). Schema name has to be passed
as an input parameter to JTF_DIAGNOSTIC_COREAPI.Column_Exists API. */

l_ret_status :=      fnd_installation.get_app_info ('INV'
                                   , l_status
                                   , l_industry
                                   , l_oracle_schema
                                    );

/*JTF_DIAGNOSTIC_COREAPI.Line_Out(' l_oracle_schema: '||l_oracle_schema);*/


  /* SQL to fetch records from mtl_system_items_interface */
sqltxt := 'SELECT ' ||
'    MSII.INVENTORY_ITEM_ID	      		"INVENTORY ITEM ID",			'||
'    MSII.ORGANIZATION_ID	      		    "ORGANIZATION ID",			'||
'    to_char(MSII.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'')	"LAST UPDATE DATE",	'||
'    MSII.LAST_UPDATED_BY	      		    "LAST UPDATED BY",			'||
'    to_char(MSII.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'')    "CREATION DATE",		'||
'    MSII.CREATED_BY		      		    "CREATED BY",			'||
'    MSII.LAST_UPDATE_LOGIN	      		    "LAST UPDATE LOGIN",		'||
'    MSII.SUMMARY_FLAG		      		    "SUMMARY FLAG",			'||
'    MSII.ENABLED_FLAG		      		    "ENABLED FLAG",			'||
'    to_char(MSII.START_DATE_ACTIVE,''DD-MON-YYYY HH24:MI:SS'')	 "START DATE ACTIVE",	'||
'    to_char(MSII.END_DATE_ACTIVE,''DD-MON-YYYY HH24:MI:SS'')	 "END DATE ACTIVE",	'||
'    MSII.DESCRIPTION		      		    "DESCRIPTION",			'||
'    MSII.BUYER_ID		      		    "BUYER ID",				'||
'    MSII.ACCOUNTING_RULE_ID	      		    "ACCOUNTING RULE ID",		'||
'    MSII.INVOICING_RULE_ID	      		    "INVOICING RULE ID",		'||
'    MSII.SEGMENT1		      		    "SEGMENT1",				'||
'    MSII.SEGMENT2		      		    "SEGMENT2",				'||
'    MSII.SEGMENT3		      		    "SEGMENT3",				'||
'    MSII.SEGMENT4		      		    "SEGMENT4",				'||
'    MSII.SEGMENT5		      		    "SEGMENT5",				'||
'    MSII.SEGMENT6		      		    "SEGMENT6",				'||
'    MSII.SEGMENT7		      		    "SEGMENT7",				'||
'    MSII.SEGMENT8		      		    "SEGMENT8",				'||
'    MSII.SEGMENT9		      		    "SEGMENT9",				'||
'    MSII.SEGMENT10		      		    "SEGMENT10",			'||
'    MSII.SEGMENT11		      		    "SEGMENT11",			'||
'    MSII.SEGMENT12		      		    "SEGMENT12",			'||
'    MSII.SEGMENT13		      		    "SEGMENT13",			'||
'    MSII.SEGMENT14		      		    "SEGMENT14",			'||
'    MSII.SEGMENT15		      		    "SEGMENT15",			'||
'    MSII.SEGMENT16		      		    "SEGMENT16",			'||
'    MSII.SEGMENT17		      		    "SEGMENT17",			'||
'    MSII.SEGMENT18		      		    "SEGMENT18",			'||
'    MSII.SEGMENT19		      		    "SEGMENT19",			'||
'    MSII.SEGMENT20		      		    "SEGMENT20",			'||
'    MSII.ATTRIBUTE_CATEGORY	      		    "ATTRIBUTE CATEGORY",		'||
'    MSII.ATTRIBUTE1		      		    "ATTRIBUTE1",			'||
'    MSII.ATTRIBUTE2		      		    "ATTRIBUTE2",			'||
'    MSII.ATTRIBUTE3		      		    "ATTRIBUTE3",			'||
'    MSII.ATTRIBUTE4		      		    "ATTRIBUTE4",			'||
'    MSII.ATTRIBUTE5		      		    "ATTRIBUTE5",			'||
'    MSII.ATTRIBUTE6		      		    "ATTRIBUTE6",			'||
'    MSII.ATTRIBUTE7		      		    "ATTRIBUTE7",			'||
'    MSII.ATTRIBUTE8		      		    "ATTRIBUTE8",			'||
'    MSII.ATTRIBUTE9		      		    "ATTRIBUTE9",			'||
'    MSII.ATTRIBUTE10		      		    "ATTRIBUTE10",			'||
'    MSII.ATTRIBUTE11		      		    "ATTRIBUTE11",			'||
'    MSII.ATTRIBUTE12		      		    "ATTRIBUTE12",			'||
'    MSII.ATTRIBUTE13		      		    "ATTRIBUTE13",			'||
'    MSII.ATTRIBUTE14		      		    "ATTRIBUTE14",			'||
'    MSII.ATTRIBUTE15		      		    "ATTRIBUTE15",			'||
'    MSII.PURCHASING_ITEM_FLAG	      		    "PURCHASING ITEM FLAG",		'||
'    MSII.SHIPPABLE_ITEM_FLAG	      		    "SHIPPABLE ITEM FLAG",		'||
'    MSII.CUSTOMER_ORDER_FLAG	      		    "CUSTOMER ORDER FLAG",		'||
'    MSII.INTERNAL_ORDER_FLAG	      		    "INTERNAL ORDER FLAG",		'||
'    MSII.SERVICE_ITEM_FLAG	      		    "SERVICE ITEM FLAG",		'||
'    MSII.INVENTORY_ITEM_FLAG	      		    "INVENTORY ITEM FLAG",		'||
'    MSII.ENG_ITEM_FLAG		      		    "ENG ITEM FLAG",			'||
'    MSII.INVENTORY_ASSET_FLAG	      		    "INVENTORY ASSET FLAG",		'||
'    MSII.PURCHASING_ENABLED_FLAG     		    "PURCHASING ENABLED FLAG",		'||
'    MSII.CUSTOMER_ORDER_ENABLED_FLAG 		    "CUSTOMER ORDER ENABLED FLAG",	'||
'    MSII.INTERNAL_ORDER_ENABLED_FLAG 		    "INTERNAL ORDER ENABLED FLAG",	'||
'    MSII.SO_TRANSACTIONS_FLAG	      		    "SO TRANSACTIONS FLAG",		'||
'    MSII.MTL_TRANSACTIONS_ENABLED_FLAG		    "MTL TRANSACTIONS ENABLED FLAG",	'||
'    MSII.STOCK_ENABLED_FLAG	      		    "STOCK ENABLED FLAG",		'||
'    MSII.BOM_ENABLED_FLAG	      		    "BOM ENABLED FLAG",			'||
'    MSII.BUILD_IN_WIP_FLAG	      		    "BUILD IN WIP FLAG",		'||
'    MSII.REVISION_QTY_CONTROL_CODE   		    "REVISION QTY CONTROL CODE",	'||
'    MSII.ITEM_CATALOG_GROUP_ID	      		    "ITEM CATALOG GROUP ID",		'||
'    MSII.CATALOG_STATUS_FLAG	      		    "CATALOG STATUS FLAG",		'||
'    MSII.CHECK_SHORTAGES_FLAG	      		    "CHECK SHORTAGES FLAG",		'||
'    MSII.RETURNABLE_FLAG	      		    "RETURNABLE FLAG",			'||
'    MSII.DEFAULT_SHIPPING_ORG	      		    "DEFAULT SHIPPING ORG",		'||
'    MSII.COLLATERAL_FLAG	      		    "COLLATERAL FLAG",			'||
'    MSII.TAXABLE_FLAG		      		    "TAXABLE FLAG",			'||
'    MSII.QTY_RCV_EXCEPTION_CODE      		    "QTY RCV EXCEPTION CODE",		'||
'    MSII.ALLOW_ITEM_DESC_UPDATE_FLAG 		    "ALLOW ITEM DESC UPDATE FLAG",	'||
'    MSII.INSPECTION_REQUIRED_FLAG    		    "INSPECTION REQUIRED FLAG",		'||
'    MSII.RECEIPT_REQUIRED_FLAG	      		    "RECEIPT REQUIRED FLAG",		'||
'    MSII.MARKET_PRICE		      		    "MARKET PRICE",			'||
'    MSII.HAZARD_CLASS_ID	      		    "HAZARD CLASS ID",			'||
'    MSII.RFQ_REQUIRED_FLAG	      		    "RFQ REQUIRED FLAG",		'||
'    MSII.QTY_RCV_TOLERANCE	      		    "QTY RCV TOLERANCE",		'||
'    MSII.LIST_PRICE_PER_UNIT	      		    "LIST PRICE PER UNIT",		'||
'    MSII.UN_NUMBER_ID		      		    "UN NUMBER ID",			'||
'    MSII.PRICE_TOLERANCE_PERCENT     		    "PRICE TOLERANCE PERCENT",		'||
'    MSII.ASSET_CATEGORY_ID	      		    "ASSET CATEGORY ID",		'||
'    MSII.ROUNDING_FACTOR	      		    "ROUNDING FACTOR",			'||
'    MSII.UNIT_OF_ISSUE		      		    "UNIT OF ISSUE",			'||
'    MSII.ENFORCE_SHIP_TO_LOCATION_CODE		    "ENFORCE SHIP TO LOCATION CODE",	'||
'    MSII.ALLOW_SUBSTITUTE_RECEIPTS_FLAG	    "ALLOW SUBSTITUTE RECEIPTS FLAG",	'||
'    MSII.ALLOW_UNORDERED_RECEIPTS_FLAG		    "ALLOW UNORDERED RECEIPTS FLAG",	'||
'    MSII.ALLOW_EXPRESS_DELIVERY_FLAG 		    "ALLOW EXPRESS DELIVERY FLAG",	'||
'    MSII.DAYS_EARLY_RECEIPT_ALLOWED  		    "DAYS EARLY RECEIPT ALLOWED",	'||
'    MSII.DAYS_LATE_RECEIPT_ALLOWED   		    "DAYS LATE RECEIPT ALLOWED",	'||
'    MSII.RECEIPT_DAYS_EXCEPTION_CODE 		    "RECEIPT DAYS EXCEPTION CODE",	'||
'    MSII.RECEIVING_ROUTING_ID	      		    "RECEIVING ROUTING ID",		'||
'    MSII.INVOICE_CLOSE_TOLERANCE     		    "INVOICE CLOSE TOLERANCE",		'||
'    MSII.RECEIVE_CLOSE_TOLERANCE     		    "RECEIVE CLOSE TOLERANCE",		'||
'    MSII.AUTO_LOT_ALPHA_PREFIX	      		    "AUTO LOT ALPHA PREFIX",		'||
'    MSII.START_AUTO_LOT_NUMBER	      		    "START AUTO LOT NUMBER",		'||
'    MSII.LOT_CONTROL_CODE	      		    "LOT CONTROL CODE",			'||
'    MSII.SHELF_LIFE_CODE	      		    "SHELF LIFE CODE",			'||
'    MSII.SHELF_LIFE_DAYS	      		    "SHELF LIFE DAYS",			'||
'    MSII.SERIAL_NUMBER_CONTROL_CODE  		    "SERIAL NUMBER CONTROL CODE",	'||
'    MSII.START_AUTO_SERIAL_NUMBER    		    "START AUTO SERIAL NUMBER",		'||
'    MSII.AUTO_SERIAL_ALPHA_PREFIX    		    "AUTO SERIAL ALPHA PREFIX",		'||
'    MSII.SOURCE_TYPE		      		    "SOURCE TYPE",			'||
'    MSII.SOURCE_ORGANIZATION_ID      		    "SOURCE ORGANIZATION ID",		'||
'    MSII.SOURCE_SUBINVENTORY	      		    "SOURCE SUBINVENTORY",		'||
'    MSII.EXPENSE_ACCOUNT	      		    "EXPENSE ACCOUNT",			'||
'    MSII.ENCUMBRANCE_ACCOUNT	      		    "ENCUMBRANCE ACCOUNT",		'||
'    MSII.RESTRICT_SUBINVENTORIES_CODE		    "RESTRICT SUBINVENTORIES CODE",	'||
'    MSII.UNIT_WEIGHT		      		    "UNIT WEIGHT",			'||
'    MSII.WEIGHT_UOM_CODE	      		    "WEIGHT UOM CODE",			'||
'    MSII.VOLUME_UOM_CODE	      		    "VOLUME UOM CODE",			'||
'    MSII.UNIT_VOLUME		      		    "UNIT VOLUME"			'||
'    from  mtl_system_items_interface	msii	    where 1=1				';

sqltxt :=sqltxt||' and rownum <   '||row_limit;
sqltxt :=sqltxt||' order by msii.inventory_item_id, msii.organization_id ';

   num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Records in mtl_system_items_interface table ');
   If (num_rows = row_limit -1 ) Then
	JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
   End If;
   statusStr := 'SUCCESS';
   isFatal := 'FALSE';

sqltxt := 'SELECT ' ||
'    MSII.INVENTORY_ITEM_ID	      	    "INVENTORY ITEM ID",		'||
'    MSII.ORGANIZATION_ID	      		    "ORGANIZATION ID",			'||
'    MSII.RESTRICT_LOCATORS_CODE      		    "RESTRICT LOCATORS CODE",		'||
'    MSII.LOCATION_CONTROL_CODE	      		    "LOCATION CONTROL CODE",		'||
'    MSII.SHRINKAGE_RATE	      		    "SHRINKAGE RATE",			'||
'    MSII.ACCEPTABLE_EARLY_DAYS	      		    "ACCEPTABLE EARLY DAYS",		'||
'    MSII.PLANNING_TIME_FENCE_CODE    		    "PLANNING TIME FENCE CODE",		'||
'    MSII.DEMAND_TIME_FENCE_CODE      		    "DEMAND TIME FENCE CODE",		'||
'    MSII.LEAD_TIME_LOT_SIZE	      		    "LEAD TIME LOT SIZE",		'||
'    MSII.STD_LOT_SIZE		      		    "STD LOT SIZE",			'||
'    MSII.CUM_MANUFACTURING_LEAD_TIME 		    "CUM MANUFACTURING LEAD TIME",	'||
'    MSII.OVERRUN_PERCENTAGE	      		    "OVERRUN PERCENTAGE",		'||
'    MSII.MRP_CALCULATE_ATP_FLAG      		    "MRP CALCULATE ATP FLAG",		'||
'    MSII.ACCEPTABLE_RATE_INCREASE    		    "ACCEPTABLE RATE INCREASE",		'||
'    MSII.ACCEPTABLE_RATE_DECREASE    		    "ACCEPTABLE RATE DECREASE",		'||
'    MSII.CUMULATIVE_TOTAL_LEAD_TIME  		    "CUMULATIVE TOTAL LEAD TIME",	'||
'    MSII.PLANNING_TIME_FENCE_DAYS    		    "PLANNING TIME FENCE DAYS",		'||
'    MSII.DEMAND_TIME_FENCE_DAYS      		    "DEMAND TIME FENCE DAYS",		'||
'    MSII.END_ASSEMBLY_PEGGING_FLAG   		    "END ASSEMBLY PEGGING FLAG",	'||
'    MSII.REPETITIVE_PLANNING_FLAG    		    "REPETITIVE PLANNING FLAG",		'||
'    MSII.PLANNING_EXCEPTION_SET      		    "PLANNING EXCEPTION SET",		'||
'    MSII.BOM_ITEM_TYPE		      		    "BOM ITEM TYPE",			'||
'    MSII.PICK_COMPONENTS_FLAG	      		    "PICK COMPONENTS FLAG",		'||
'    MSII.REPLENISH_TO_ORDER_FLAG     		    "REPLENISH TO ORDER FLAG",		'||
'    MSII.BASE_ITEM_ID		      		    "BASE ITEM ID",			'||
'    MSII.ATP_COMPONENTS_FLAG	      		    "ATP COMPONENTS FLAG",		'||
'    MSII.ATP_FLAG		      		    "ATP FLAG",				'||
'    MSII.FIXED_LEAD_TIME	      		    "FIXED LEAD TIME",			'||
'    MSII.VARIABLE_LEAD_TIME	      		    "VARIABLE LEAD TIME",		'||
'    MSII.WIP_SUPPLY_LOCATOR_ID	      		    "WIP SUPPLY LOCATOR ID",		'||
'    MSII.WIP_SUPPLY_TYPE	      		    "WIP SUPPLY TYPE",			'||
'    MSII.WIP_SUPPLY_SUBINVENTORY     		    "WIP SUPPLY SUBINVENTORY",		'||
'    MSII.PRIMARY_UOM_CODE	      		    "PRIMARY UOM CODE",			'||
'    MSII.PRIMARY_UNIT_OF_MEASURE     		    "PRIMARY UNIT OF MEASURE",		'||
'    MSII.ALLOWED_UNITS_LOOKUP_CODE   		    "ALLOWED UNITS LOOKUP CODE",	'||
'    MSII.COST_OF_SALES_ACCOUNT	      		    "COST OF SALES ACCOUNT",		'||
'    MSII.SALES_ACCOUNT		      		    "SALES ACCOUNT",			'||
'    MSII.DEFAULT_INCLUDE_IN_ROLLUP_FLAG	    "DEFAULT INCLUDE IN ROLLUP FLAG",	'||
'    MSII.INVENTORY_ITEM_STATUS_CODE  		    "INVENTORY ITEM STATUS CODE",	'||
'    MSII.INVENTORY_PLANNING_CODE     		    "INVENTORY PLANNING CODE",		'||
'    MSII.PLANNER_CODE		      		    "PLANNER CODE",			'||
'    MSII.PLANNING_MAKE_BUY_CODE      		    "PLANNING MAKE BUY CODE",		'||
'    MSII.FIXED_LOT_MULTIPLIER	      		    "FIXED LOT MULTIPLIER",		'||
'    MSII.ROUNDING_CONTROL_TYPE	      		    "ROUNDING CONTROL TYPE",		'||
'    MSII.CARRYING_COST		      		    "CARRYING COST",			'||
'    MSII.POSTPROCESSING_LEAD_TIME    		    "POSTPROCESSING LEAD TIME",		'||
'    MSII.PREPROCESSING_LEAD_TIME     		    "PREPROCESSING LEAD TIME",		'||
'    MSII.FULL_LEAD_TIME	      		    "FULL LEAD TIME",			'||
'    MSII.ORDER_COST		      		    "ORDER COST",			'||
'    MSII.MRP_SAFETY_STOCK_PERCENT    		    "MRP SAFETY STOCK PERCENT",		'||
'    MSII.MRP_SAFETY_STOCK_CODE	      		    "MRP SAFETY STOCK CODE",		'||
'    MSII.MIN_MINMAX_QUANTITY	      		    "MIN MINMAX QUANTITY",		'||
'    MSII.MAX_MINMAX_QUANTITY	      		    "MAX MINMAX QUANTITY",		'||
'    MSII.MINIMUM_ORDER_QUANTITY      		    "MINIMUM ORDER QUANTITY",		'||
'    MSII.FIXED_ORDER_QUANTITY	      		    "FIXED ORDER QUANTITY",		'||
'    MSII.FIXED_DAYS_SUPPLY	      		    "FIXED DAYS SUPPLY",		'||
'    MSII.MAXIMUM_ORDER_QUANTITY      		    "MAXIMUM ORDER QUANTITY",		'||
'    MSII.ATP_RULE_ID		      		    "ATP RULE ID",			'||
'    MSII.PICKING_RULE_ID	      		    "PICKING RULE ID",			'||
'    MSII.RESERVABLE_TYPE	      		    "RESERVABLE TYPE",			'||
'    MSII.POSITIVE_MEASUREMENT_ERROR  		    "POSITIVE MEASUREMENT ERROR",	'||
'    MSII.NEGATIVE_MEASUREMENT_ERROR  		    "NEGATIVE MEASUREMENT ERROR",	'||
'    MSII.ENGINEERING_ECN_CODE	      		    "ENGINEERING ECN CODE",		'||
'    MSII.ENGINEERING_ITEM_ID	      		    "ENGINEERING ITEM ID",		'||
'    to_char(MSII.ENGINEERING_DATE,''DD-MON-YYYY HH24:MI:SS'') "ENGINEERING DATE",	'||
'    MSII.SERVICE_STARTING_DELAY      		    "SERVICE STARTING DELAY",		'||
'    MSII.VENDOR_WARRANTY_FLAG	      		    "VENDOR WARRANTY FLAG",		'||
'    MSII.SERVICEABLE_COMPONENT_FLAG  		    "SERVICEABLE COMPONENT FLAG",	'||
'    MSII.SERVICEABLE_PRODUCT_FLAG    		    "SERVICEABLE PRODUCT FLAG",		'||
'    MSII.BASE_WARRANTY_SERVICE_ID    		    "BASE WARRANTY SERVICE ID",		'||
'    MSII.PAYMENT_TERMS_ID	      		    "PAYMENT TERMS ID",			'||
'    MSII.PREVENTIVE_MAINTENANCE_FLAG 		    "PREVENTIVE MAINTENANCE FLAG",	'||
'    MSII.PRIMARY_SPECIALIST_ID	      		    "PRIMARY SPECIALIST ID",		'||
'    MSII.SECONDARY_SPECIALIST_ID     		    "SECONDARY SPECIALIST ID",		'||
'    MSII.SERVICEABLE_ITEM_CLASS_ID   		    "SERVICEABLE ITEM CLASS ID",	'||
'    MSII.TIME_BILLABLE_FLAG	      		    "TIME BILLABLE FLAG",		'||
'    MSII.MATERIAL_BILLABLE_FLAG      		    "MATERIAL BILLABLE FLAG",		'||
'    MSII.EXPENSE_BILLABLE_FLAG	      		    "EXPENSE BILLABLE FLAG",		'||
'    MSII.PRORATE_SERVICE_FLAG	      		    "PRORATE SERVICE FLAG",		'||
'    MSII.COVERAGE_SCHEDULE_ID	      		    "COVERAGE SCHEDULE ID",		'||
'    MSII.SERVICE_DURATION_PERIOD_CODE		    "SERVICE DURATION PERIOD CODE",	'||
'    MSII.SERVICE_DURATION	      		    "SERVICE DURATION",			'||
'    MSII.WARRANTY_VENDOR_ID	      		    "WARRANTY VENDOR ID",		'||
'    MSII.MAX_WARRANTY_AMOUNT	      		    "MAX WARRANTY AMOUNT",		'||
'    MSII.RESPONSE_TIME_PERIOD_CODE   		    "RESPONSE TIME PERIOD CODE",	'||
'    MSII.RESPONSE_TIME_VALUE	      		    "RESPONSE TIME VALUE",		'||
'    MSII.NEW_REVISION_CODE	      		    "NEW REVISION CODE",		'||
'    MSII.INVOICEABLE_ITEM_FLAG	      		    "INVOICEABLE ITEM FLAG",		'||
'    MSII.TAX_CODE		      		    "TAX CODE",				'||
'    MSII.INVOICE_ENABLED_FLAG	      		    "INVOICE ENABLED FLAG",		'||
'    MSII.MUST_USE_APPROVED_VENDOR_FLAG		    "MUST USE APPROVED VENDOR FLAG",	'||
'    MSII.REQUEST_ID		      		    "REQUEST ID",			'||
'    MSII.PROGRAM_APPLICATION_ID      		    "PROGRAM APPLICATION ID",		'||
'    MSII.PROGRAM_ID		      		    "PROGRAM ID",			'||
'    to_char(MSII.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "PROGRAM UPDATE DATE",'||
'    MSII.OUTSIDE_OPERATION_FLAG      		    "OUTSIDE OPERATION FLAG",		'||
'    MSII.OUTSIDE_OPERATION_UOM_TYPE  		    "OUTSIDE OPERATION UOM TYPE",	'||
'    MSII.SAFETY_STOCK_BUCKET_DAYS    		    "SAFETY STOCK BUCKET DAYS",		'||
'    MSII.AUTO_REDUCE_MPS	      		    "AUTO REDUCE MPS",			'||
'    MSII.COSTING_ENABLED_FLAG	      		    "COSTING ENABLED FLAG",		'||
'    MSII.CYCLE_COUNT_ENABLED_FLAG    		    "CYCLE COUNT ENABLED FLAG",		'||
'    MSII.DEMAND_SOURCE_LINE	      		    "DEMAND SOURCE LINE",		'||
'    MSII.COPY_ITEM_ID		      		    "COPY ITEM ID",			'||
'    MSII.SET_ID		      		    "SET ID",				'||
'    MSII.REVISION		      		    "REVISION",				'||
'    MSII.AUTO_CREATED_CONFIG_FLAG    		    "AUTO CREATED CONFIG FLAG",		'||
'    MSII.ITEM_TYPE		      		    "ITEM TYPE",			'||
'    MSII.MODEL_CONFIG_CLAUSE_NAME    		    "MODEL CONFIG CLAUSE NAME",		'||
'    MSII.SHIP_MODEL_COMPLETE_FLAG    		    "SHIP MODEL COMPLETE FLAG",		'||
'    MSII.MRP_PLANNING_CODE	      		    "MRP PLANNING CODE",		'||
'    MSII.RETURN_INSPECTION_REQUIREMENT		    "RETURN INSPECTION REQUIREMENT",	'||
'    MSII.DEMAND_SOURCE_TYPE	      		    "DEMAND SOURCE TYPE",		'||
'    MSII.DEMAND_SOURCE_HEADER_ID     		    "DEMAND SOURCE HEADER ID",		'||
'    MSII.TRANSACTION_ID	      		    "TRANSACTION ID",			'||
'    MSII.PROCESS_FLAG		      		    "PROCESS FLAG",			'||
'    MSII.ORGANIZATION_CODE	      		    "ORGANIZATION CODE",		'||
'    MSII.ITEM_NUMBER		      		    "ITEM NUMBER",			'||
'    MSII.COPY_ITEM_NUMBER	      		    "COPY ITEM NUMBER",			'||
'    MSII.TEMPLATE_ID		      		    "TEMPLATE ID",			'||
'    MSII.TEMPLATE_NAME		      		    "TEMPLATE NAME",			'||
'    MSII.COPY_ORGANIZATION_ID	      		    "COPY ORGANIZATION ID",		'||
'    MSII.COPY_ORGANIZATION_CODE      		    "COPY ORGANIZATION CODE"		'||
'    from  mtl_system_items_interface	msii	    where 1=1				';

sqltxt :=sqltxt||' and rownum <   '||row_limit;
sqltxt :=sqltxt||' order by msii.inventory_item_id, msii.organization_id ';

   num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Records in mtl_system_items_interface table (Contd 1..)');
   If (num_rows = row_limit -1 ) Then
	JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
   End If;

   statusStr := 'SUCCESS';
   isFatal := 'FALSE';

sqltxt := 'SELECT ' ||
'    MSII.INVENTORY_ITEM_ID	      		   "INVENTORY ITEM ID",			'||
'    MSII.ORGANIZATION_ID	      		    "ORGANIZATION ID",			'||
'    MSII.ATO_FORECAST_CONTROL	      		    "ATO FORECAST CONTROL",		'||
'    MSII.TRANSACTION_TYPE	      		    "TRANSACTION TYPE",			'||
'    MSII.MATERIAL_COST		      		    "MATERIAL COST",			'||
'    MSII.MATERIAL_SUB_ELEM	      		    "MATERIAL SUB ELEM",		'||
'    MSII.MATERIAL_OH_RATE	      		    "MATERIAL OH RATE",			'||
'    MSII.MATERIAL_OH_SUB_ELEM	      		    "MATERIAL OH SUB ELEM",		'||
'    MSII.MATERIAL_SUB_ELEM_ID	      		    "MATERIAL SUB ELEM ID",		'||
'    MSII.MATERIAL_OH_SUB_ELEM_ID     		    "MATERIAL OH SUB ELEM ID",		'||
'    MSII.RELEASE_TIME_FENCE_CODE     		    "RELEASE TIME FENCE CODE",		'||
'    MSII.RELEASE_TIME_FENCE_DAYS     		    "RELEASE TIME FENCE DAYS",		'||
'    MSII.CONTAINER_ITEM_FLAG	      		    "CONTAINER ITEM FLAG",		'||
'    MSII.VEHICLE_ITEM_FLAG	      		    "VEHICLE ITEM FLAG",		'||
'    MSII.MAXIMUM_LOAD_WEIGHT	      		    "MAXIMUM LOAD WEIGHT",		'||
'    MSII.MINIMUM_FILL_PERCENT	      		    "MINIMUM FILL PERCENT",		'||
'    MSII.CONTAINER_TYPE_CODE	      		    "CONTAINER TYPE CODE",		'||
'    MSII.INTERNAL_VOLUME	      		    "INTERNAL VOLUME",			'||
'    MSII.SET_PROCESS_ID	      		    "SET PROCESS ID",			'||
'    to_char(MSII.WH_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "WH UPDATE DATE",		'||
'    MSII.PRODUCT_FAMILY_ITEM_ID      		    "PRODUCT FAMILY ITEM ID",		'||
'    MSII.PURCHASING_TAX_CODE	      		    "PURCHASING TAX CODE",		'||
'    MSII.OVERCOMPLETION_TOLERANCE_TYPE		    "OVERCOMPLETION TOLERANCE TYPE",	'||
'    MSII.OVERCOMPLETION_TOLERANCE_VALUE	    "OVERCOMPLETION TOLERANCE VALUE",	'||
'    MSII.EFFECTIVITY_CONTROL	      		    "EFFECTIVITY CONTROL",		'||
'    MSII.GLOBAL_ATTRIBUTE_CATEGORY   		    "GLOBAL ATTRIBUTE CATEGORY",	'||
'    MSII.GLOBAL_ATTRIBUTE1	      		    "GLOBAL ATTRIBUTE1",		'||
'    MSII.GLOBAL_ATTRIBUTE2	      		    "GLOBAL ATTRIBUTE2",		'||
'    MSII.GLOBAL_ATTRIBUTE3	      		    "GLOBAL ATTRIBUTE3",		'||
'    MSII.GLOBAL_ATTRIBUTE4	      		    "GLOBAL ATTRIBUTE4",		'||
'    MSII.GLOBAL_ATTRIBUTE5	      		    "GLOBAL ATTRIBUTE5",		'||
'    MSII.GLOBAL_ATTRIBUTE6	      		    "GLOBAL ATTRIBUTE6",		'||
'    MSII.GLOBAL_ATTRIBUTE7	      		    "GLOBAL ATTRIBUTE7",		'||
'    MSII.GLOBAL_ATTRIBUTE8	      		    "GLOBAL ATTRIBUTE8",		'||
'    MSII.GLOBAL_ATTRIBUTE9	      		    "GLOBAL ATTRIBUTE9",		'||
'    MSII.GLOBAL_ATTRIBUTE10	      		    "GLOBAL ATTRIBUTE10",		'||
'    MSII.OVER_SHIPMENT_TOLERANCE     		    "OVER SHIPMENT TOLERANCE",		'||
'    MSII.UNDER_SHIPMENT_TOLERANCE    		    "UNDER SHIPMENT TOLERANCE",		'||
'    MSII.OVER_RETURN_TOLERANCE	      		    "OVER RETURN TOLERANCE",		'||
'    MSII.UNDER_RETURN_TOLERANCE      		    "UNDER RETURN TOLERANCE",		'||
'    MSII.EQUIPMENT_TYPE	      		    "EQUIPMENT TYPE",			'||
'    MSII.RECOVERED_PART_DISP_CODE    		    "RECOVERED PART DISP CODE",		'||
'    MSII.DEFECT_TRACKING_ON_FLAG     		    "DEFECT TRACKING ON FLAG",		'||
'    MSII.USAGE_ITEM_FLAG	      		    "USAGE ITEM FLAG",			'||
'    MSII.EVENT_FLAG		      		    "EVENT FLAG",			'||
'    MSII.ELECTRONIC_FLAG	      		    "ELECTRONIC FLAG",			'||
'    MSII.DOWNLOADABLE_FLAG	      		    "DOWNLOADABLE FLAG",		'||
'    MSII.VOL_DISCOUNT_EXEMPT_FLAG    		    "VOL DISCOUNT EXEMPT FLAG",		'||
'    MSII.COUPON_EXEMPT_FLAG	      		    "COUPON EXEMPT FLAG",		'||
'    MSII.COMMS_NL_TRACKABLE_FLAG     		    "COMMS NL TRACKABLE FLAG",		'||
'    MSII.ASSET_CREATION_CODE	      		    "ASSET CREATION CODE",		'||
'    MSII.COMMS_ACTIVATION_REQD_FLAG  		    "COMMS ACTIVATION REQD FLAG",	'||
'    MSII.ORDERABLE_ON_WEB_FLAG	      		    "ORDERABLE ON WEB FLAG",		'||
'    MSII.BACK_ORDERABLE_FLAG	      		    "BACK ORDERABLE FLAG",		'||
'    MSII.WEB_STATUS		      		    "WEB STATUS",			'||
'    MSII.INDIVISIBLE_FLAG	      		    "INDIVISIBLE FLAG",			'||
'    MSII.LONG_DESCRIPTION	      		    "LONG DESCRIPTION",			'||
'    MSII.DIMENSION_UOM_CODE	      		    "DIMENSION UOM CODE",		'||
'    MSII.UNIT_LENGTH		      		    "UNIT LENGTH",			'||
'    MSII.UNIT_WIDTH		      		    "UNIT WIDTH",			'||
'    MSII.UNIT_HEIGHT		      		    "UNIT HEIGHT",			'||
'    MSII.BULK_PICKED_FLAG	      		    "BULK PICKED FLAG",			'||
'    MSII.LOT_STATUS_ENABLED	      		    "LOT STATUS ENABLED",		'||
'    MSII.DEFAULT_LOT_STATUS_ID	      		    "DEFAULT LOT STATUS ID",		'||
'    MSII.SERIAL_STATUS_ENABLED	      		    "SERIAL STATUS ENABLED",		'||
'    MSII.DEFAULT_SERIAL_STATUS_ID    		    "DEFAULT SERIAL STATUS ID",		'||
'    MSII.LOT_SPLIT_ENABLED	      		    "LOT SPLIT ENABLED",		'||
'    MSII.LOT_MERGE_ENABLED	      		    "LOT MERGE ENABLED",		'||
'    MSII.INVENTORY_CARRY_PENALTY     		    "INVENTORY CARRY PENALTY",		'||
'    MSII.OPERATION_SLACK_PENALTY     		    "OPERATION SLACK PENALTY",		'||
'    MSII.FINANCING_ALLOWED_FLAG      		    "FINANCING ALLOWED FLAG",		'||
'    MSII.EAM_ITEM_TYPE		      		    "EAM ITEM TYPE",			'||
'    MSII.EAM_ACTIVITY_TYPE_CODE      		    "EAM ACTIVITY TYPE CODE",		'||
'    MSII.EAM_ACTIVITY_CAUSE_CODE     		    "EAM ACTIVITY CAUSE CODE",		'||
'    MSII.EAM_ACT_NOTIFICATION_FLAG   		    "EAM ACT NOTIFICATION FLAG",	'||
'    MSII.EAM_ACT_SHUTDOWN_STATUS     		    "EAM ACT SHUTDOWN STATUS",		'||
'    MSII.DUAL_UOM_CONTROL	      		    "DUAL UOM CONTROL",			'||
'    MSII.SECONDARY_UOM_CODE	      		    "SECONDARY UOM CODE",		'||
'    MSII.DUAL_UOM_DEVIATION_HIGH     		    "DUAL UOM DEVIATION HIGH",		'||
'    MSII.DUAL_UOM_DEVIATION_LOW      		    "DUAL UOM DEVIATION LOW",		'||
'    MSII.CONTRACT_ITEM_TYPE_CODE     		    "CONTRACT ITEM TYPE CODE",		'||
'    MSII.SUBSCRIPTION_DEPEND_FLAG    		    "SUBSCRIPTION DEPEND FLAG",		'||
'    MSII.SERV_REQ_ENABLED_CODE	      		    "SERV REQ ENABLED CODE",		'||
'    MSII.SERV_BILLING_ENABLED_FLAG   		    "SERV BILLING ENABLED FLAG",	'||
'    MSII.SERV_IMPORTANCE_LEVEL	      		    "SERV IMPORTANCE LEVEL",		'||
'    MSII.PLANNED_INV_POINT_FLAG      		    "PLANNED INV POINT FLAG",		'||
'    MSII.LOT_TRANSLATE_ENABLED	      		    "LOT TRANSLATE ENABLED",		'||
'    MSII.DEFAULT_SO_SOURCE_TYPE      		    "DEFAULT SO SOURCE TYPE",		'||
'    MSII.CREATE_SUPPLY_FLAG	      		    "CREATE SUPPLY FLAG",		'||
'    MSII.SUBSTITUTION_WINDOW_CODE    		    "SUBSTITUTION WINDOW CODE",		'||
'    MSII.SUBSTITUTION_WINDOW_DAYS    		    "SUBSTITUTION WINDOW DAYS",		'||
'    MSII.IB_ITEM_INSTANCE_CLASS      		    "IB ITEM INSTANCE CLASS",		'||
'    MSII.CONFIG_MODEL_TYPE	      		    "CONFIG MODEL TYPE",		'||
'    MSII.LOT_SUBSTITUTION_ENABLED    		    "LOT SUBSTITUTION ENABLED",		'||
'    MSII.MINIMUM_LICENSE_QUANTITY    		    "MINIMUM LICENSE QUANTITY",		'||
'    MSII.EAM_ACTIVITY_SOURCE_CODE    		    "EAM ACTIVITY SOURCE CODE",		'||
'    MSII.LIFECYCLE_ID		      		    "LIFECYCLE ID",			'||
'    MSII.CURRENT_PHASE_ID	      		    "CURRENT PHASE ID"			'||
'    ,MSII.TRACKING_QUANTITY_IND	      	    "TRACKING QUANTITY IND"		'||
'    ,MSII.ONT_PRICING_QTY_SOURCE      		    "ONT PRICING QTY SOURCE"		'||
'    ,MSII.SECONDARY_DEFAULT_IND	      	    "SECONDARY DEFAULT IND"		'||
'    ,MSII.VMI_MINIMUM_UNITS	      		    "VMI MINIMUM UNITS"			'||
'    ,MSII.VMI_MINIMUM_DAYS	      		    "VMI MINIMUM DAYS"			'||
'    ,MSII.VMI_MAXIMUM_UNITS	      		    "VMI MAXIMUM UNITS"			'||
'    ,MSII.VMI_MAXIMUM_DAYS	      		    "VMI MAXIMUM DAYS"			'||
'    ,MSII.VMI_FIXED_ORDER_QUANTITY    		    "VMI FIXED ORDER QUANTITY"		'||
'    ,MSII.SO_AUTHORIZATION_FLAG	      	    "SO AUTHORIZATION FLAG"		'||
'    ,MSII.CONSIGNED_FLAG	      		    "CONSIGNED FLAG"			'||
'    ,MSII.ASN_AUTOEXPIRE_FLAG	      		    "ASN AUTOEXPIRE FLAG"		'||
'    ,MSII.VMI_FORECAST_TYPE	      		    "VMI FORECAST TYPE"			'||
'    ,MSII.FORECAST_HORIZON	      		    "FORECAST HORIZON"			'||
'    ,MSII.EXCLUDE_FROM_BUDGET_FLAG    		    "EXCLUDE FROM BUDGET FLAG"		'||
'    ,MSII.DAYS_TGT_INV_SUPPLY	      		    "DAYS TGT INV SUPPLY"		'||
'    ,MSII.DAYS_TGT_INV_WINDOW	      		    "DAYS TGT INV WINDOW"		'||
'    ,MSII.DAYS_MAX_INV_SUPPLY	      		    "DAYS MAX INV SUPPLY"		'||
'    ,MSII.DAYS_MAX_INV_WINDOW	      		    "DAYS MAX INV WINDOW"		'||
'    ,MSII.DRP_PLANNED_FLAG	      		    "DRP PLANNED FLAG"			'||
'    ,MSII.CRITICAL_COMPONENT_FLAG     		    "CRITICAL COMPONENT FLAG"		'||
'    ,MSII.CONTINOUS_TRANSFER	      		    "CONTINOUS TRANSFER"		'||
'    ,MSII.CONVERGENCE		      		    "CONVERGENCE"			'||
'    ,MSII.DIVERGENCE		      		    "DIVERGENCE"			'||
'    ,MSII.CONFIG_ORGS		      		    "CONFIG ORGS"			'||
'    ,MSII.CONFIG_MATCH		      		    "CONFIG MATCH"			'||
'    from  mtl_system_items_interface msii	    where 1=1				';

sqltxt :=sqltxt||' and rownum <   '||row_limit;
sqltxt :=sqltxt||' order by msii.inventory_item_id, msii.organization_id ';

   num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Records in mtl_system_items_interface table (Contd 2..) ');
   If (num_rows = row_limit -1 ) Then
	JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
   End If;
   statusStr := 'SUCCESS';
   isFatal := 'FALSE';

sqltxt := 'SELECT ' ||
'    MSII.INVENTORY_ITEM_ID	      			"INVENTORY ITEM ID",			'||
'    MSII.ORGANIZATION_ID	      			"ORGANIZATION ID",			'||
'    MSII.ATTRIBUTE16	      				"ATTRIBUTE16",		'||
'    MSII.ATTRIBUTE17	      				"ATTRIBUTE17",		'||
'    MSII.ATTRIBUTE18	      				"ATTRIBUTE18",		'||
'    MSII.ATTRIBUTE19	      				"ATTRIBUTE19",		'||
'    MSII.ATTRIBUTE20	      				"ATTRIBUTE20",		'||
'    MSII.ATTRIBUTE21	      				"ATTRIBUTE21",		'||
'    MSII.ATTRIBUTE22	      				"ATTRIBUTE22",		'||
'    MSII.ATTRIBUTE23	      				"ATTRIBUTE23",		'||
'    MSII.ATTRIBUTE24	      				"ATTRIBUTE24",		'||
'    MSII.ATTRIBUTE25	      				"ATTRIBUTE25",		'||
'    MSII.ATTRIBUTE26	      				"ATTRIBUTE26",		'||
'    MSII.ATTRIBUTE27	      				"ATTRIBUTE27",		'||
'    MSII.ATTRIBUTE28	      				"ATTRIBUTE28",		'||
'    MSII.ATTRIBUTE29	      				"ATTRIBUTE29",		'||
'    MSII.ATTRIBUTE30	      				"ATTRIBUTE30",		'||
'    MSII.CAS_NUMBER	      				"CAS NUMBER",			'||
'    MSII.CHILD_LOT_FLAG      				"CHILD LOT FLAG",			'||
'    MSII.CHILD_LOT_PREFIX    				"CHILD LOT PREFIX",			'||
'    MSII.CHILD_LOT_STARTING_NUMBER		"CHILD LOT STARTING NUMBER",			'||
'    MSII.CHILD_LOT_VALIDATION_FLAG		"CHILD LOT VALIDATION FLAG",			'||
'    MSII.COPY_LOT_ATTRIBUTE_FLAG		"COPY LOT ATTRIBUTE FLAG",			'||
'    MSII.DEFAULT_GRADE					"DEFAULT GRADE",			'||
'    MSII.EXPIRATION_ACTION_CODE		"EXPIRATION ACTION CODE",			'||
'    MSII.EXPIRATION_ACTION_INTERVAL		"EXPIRATION ACTION INTERVAL",			'||
'    MSII.GRADE_CONTROL_FLAG			"GRADE CONTROL FLAG",			'||
'    MSII.HAZARDOUS_MATERIAL_FLAG		"HAZARDOUS MATERIAL FLAG",			'||
'    MSII.HOLD_DAYS						"HOLD DAYS",			'||
'    MSII.LOT_DIVISIBLE_FLAG				"LOT DIVISIBLE FLAG",			'||
'    MSII.MATURITY_DAYS					"MATURITY DAYS",			'||
'    MSII.PARENT_CHILD_GENERATION_FLAG	"PARENT CHILD GENERATION FLAG",			'||
'    MSII.PROCESS_COSTING_ENABLED_FLAG	"PROCESS COSTING ENABLED FLAG",			'||
'    MSII.PROCESS_EXECUTION_ENABLED_FLAG"PROCESS EXECUTION ENABLED FLAG",			'||
'    MSII.PROCESS_QUALITY_ENABLED_FLAG     "PROCESS_QUALITY_ENABLED FLAG",			'||
'    MSII.PROCESS_SUPPLY_LOCATOR_ID		  "PROCESS SUPPLY LOCATOR ID",			'||
'    MSII.PROCESS_SUPPLY_SUBINVENTORY	  "PROCESS SUPPLY SUBINVENTORY",			'||
'    MSII.PROCESS_YIELD_LOCATOR_ID		  "PROCESS YIELD LOCATOR ID",			'||
'    MSII.PROCESS_YIELD_SUBINVENTORY	  "PROCESS YIELD SUBINVENTORY",			'||
'    MSII.RECIPE_ENABLED_FLAG			  "RECIPE ENABLED FLAG",			'||
'    MSII.RETEST_INTERVAL				  "RETEST INTERVAL",			'||
'    MSII.CHARGE_PERIODICITY_CODE		  "CHARGE PERIODICITY CODE",			'||
'    MSII.REPAIR_LEADTIME				  "REPAIR LEADTIME",			'||
'    MSII.REPAIR_YIELD					  "REPAIR YIELD",			'||
'    MSII.PREPOSITION_POINT				  "PREPOSITION POINT",			'||
'    MSII.REPAIR_PROGRAM				  "REPAIR PROGRAM",			'||
'    MSII.SUBCONTRACTING_COMPONENT	 	  "SUBCONTRACTING COMPONENT",			'||
'    MSII.OUTSOURCED_ASSEMBLY		 	  "OUTSOURCED ASSEMBLY",			'||
'    MSII.SOURCE_SYSTEM_ID			 	  "SOURCE SYSTEM ID",			'||
'    MSII.SOURCE_SYSTEM_REFERENCE	 	  "SOURCE SYSTEM REFERENCE",			'||
'    MSII.SOURCE_SYSTEM_REFERENCE_DESC 	  "SOURCE SYSTEM REFERENCE DESC",			'||
'    MSII.GLOBAL_TRADE_ITEM_NUMBER	 	  "GLOBAL TRADE ITEM NUMBER",			'||
'    MSII.CONFIRM_STATUS			 	  "CONFIRM STATUS",			'||
'    MSII.CHANGE_ID					 	  "CHANGE ID",			'||
'    MSII.CHANGE_LINE_ID			 	  "CHANGE LINE ID",			'||
'    MSII.ITEM_CATALOG_GROUP_NAME	 	  "ITEM CATALOG GROUP NAME",			'||
'    MSII.REVISION_IMPORT_POLICY	 	 	  "REVISION IMPORT POLICY",			'||
'    MSII.GTIN_DESCRIPTION		 	 	  "GTIN DESCRIPTION",			'||
'    MSII.INTERFACE_TABLE_UNIQUE_ID	 	  "INTERFACE TABLE UNIQUE ID"			'||
'    from  mtl_system_items_interface msii	    where 1=1				';

sqltxt :=sqltxt||' and rownum <   '||row_limit;
sqltxt :=sqltxt||' order by msii.inventory_item_id, msii.organization_id ';

   num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Records in mtl_system_items_interface table (Contd 3..) ');
   If (num_rows = row_limit -1 ) Then
	JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
   End If;
   statusStr := 'SUCCESS';
   isFatal := 'FALSE';

 /* End of mtl_system_items_interface */

 /* SQL to fetch records from mtl_item_revisions_interface */
 	sqltxt := 'SELECT ' ||
 '    MIRI.INVENTORY_ITEM_ID		       "INVENTORY ITEM ID",	     '||
'    MIRI.ORGANIZATION_ID		       "ORGANIZATION ID",	     '||
'    MIRI.REVISION			       "REVISION",		     '||
'    to_char(MIRI.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "LAST UPDATE DATE", '||
'    MIRI.LAST_UPDATED_BY		       "LAST UPDATED BY",	     '||
'    to_char(MIRI.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'')  "CREATION DATE",	'||
'    MIRI.CREATED_BY			       "CREATED BY",		     '||
'    MIRI.LAST_UPDATE_LOGIN		       "LAST UPDATE LOGIN",	     '||
'    MIRI.CHANGE_NOTICE			       "CHANGE NOTICE",		     '||
'    to_char(MIRI.ECN_INITIATION_DATE,''DD-MON-YYYY HH24:MI:SS'') "ECN INITIATION DATE",'||
'    to_char(MIRI.IMPLEMENTATION_DATE,''DD-MON-YYYY HH24:MI:SS'') "IMPLEMENTATION DATE",'||
'    MIRI.IMPLEMENTED_SERIAL_NUMBER	       "IMPLEMENTED SERIAL NUMBER",  '||
'    to_char(MIRI.EFFECTIVITY_DATE,''DD-MON-YYYY HH24:MI:SS'')	"EFFECTIVITY DATE",	'||
'    MIRI.ATTRIBUTE_CATEGORY		       "ATTRIBUTE CATEGORY",	     '||
'    MIRI.ATTRIBUTE1			       "ATTRIBUTE1",		     '||
'    MIRI.ATTRIBUTE2			       "ATTRIBUTE2",		     '||
'    MIRI.ATTRIBUTE3			       "ATTRIBUTE3",		     '||
'    MIRI.ATTRIBUTE4			       "ATTRIBUTE4",		     '||
'    MIRI.ATTRIBUTE5			       "ATTRIBUTE5",		     '||
'    MIRI.ATTRIBUTE6			       "ATTRIBUTE6",		     '||
'    MIRI.ATTRIBUTE7			       "ATTRIBUTE7",		     '||
'    MIRI.ATTRIBUTE8			       "ATTRIBUTE8",		     '||
'    MIRI.ATTRIBUTE9			       "ATTRIBUTE9",		     '||
'    MIRI.ATTRIBUTE10			       "ATTRIBUTE10",		     '||
'    MIRI.ATTRIBUTE11			       "ATTRIBUTE11",		     '||
'    MIRI.ATTRIBUTE12			       "ATTRIBUTE12",		     '||
'    MIRI.ATTRIBUTE13			       "ATTRIBUTE13",		     '||
'    MIRI.ATTRIBUTE14			       "ATTRIBUTE14",		     '||
'    MIRI.ATTRIBUTE15			       "ATTRIBUTE15",		     '||
'    MIRI.REQUEST_ID			       "REQUEST ID",		     '||
'    MIRI.PROGRAM_APPLICATION_ID	       "PROGRAM APPLICATION ID",     '||
'    MIRI.PROGRAM_ID			       "PROGRAM ID",		     '||
'    to_char(MIRI.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "PROGRAM UPDATE DATE",'||
'    MIRI.REVISED_ITEM_SEQUENCE_ID	       "REVISED ITEM SEQUENCE ID",   '||
'    MIRI.DESCRIPTION			       "DESCRIPTION",		     '||
'    MIRI.ITEM_NUMBER			       "ITEM NUMBER",		     '||
'    MIRI.ORGANIZATION_CODE		       "ORGANIZATION CODE",	     '||
'    MIRI.TRANSACTION_ID		       "TRANSACTION ID",	     '||
'    MIRI.PROCESS_FLAG			       "PROCESS FLAG",		     '||
'    MIRI.TRANSACTION_TYPE		       "TRANSACTION TYPE",	     '||
'    MIRI.SET_PROCESS_ID		       "SET PROCESS ID",	     '||
'    MIRI.REVISION_ID			       "REVISION ID",		     '||
'    MIRI.REVISION_LABEL		       "REVISION LABEL",	     '||
'    MIRI.REVISION_REASON		       "REVISION REASON",	     '||
'    MIRI.LIFECYCLE_ID			       "LIFECYCLE ID",		     '||
'    MIRI.CURRENT_PHASE_ID		       "CURRENT PHASE ID",	     '||
'    MIRI.SOURCE_SYSTEM_ID		       "SOURCE SYSTEM ID",	     '||
'    MIRI.SOURCE_SYSTEM_REFERENCE   "SOURCE SYSTEM REFERENCE"	,     '||
'    MIRI.CHANGE_ID					"CHANGE ID",	     '||
'    MIRI.INTERFACE_TABLE_UNIQUE_ID	"INTERFACE TABLE UNIQUE ID",	     '||
'    MIRI.TEMPLATE_ID				"TEMPLATE ID",     '||
'    MIRI.TEMPLATE_NAME				"TEMPLATE NAME"	     '||
'    from  mtl_item_revisions_interface miri	where 1=1		     ';

sqltxt :=sqltxt||' and rownum <   '||row_limit;
sqltxt :=sqltxt||' order by miri.inventory_item_id, miri.organization_id, miri.revision ';

   num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Records in mtl_item_revisions_interface table ');
   If (num_rows = row_limit -1 ) Then
	JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
   End If;
   statusStr := 'SUCCESS';
   isFatal := 'FALSE';

 /* End of mtl_item_revisions_interface */


 /* SQL to fetch records from mtl_rtg_item_revs_interface */

 	sqltxt := 'SELECT ' ||
 '    MRIRI.INVENTORY_ITEM_ID		       "INVENTORY ITEM ID",	     '||
'    MRIRI.ORGANIZATION_ID		       "ORGANIZATION ID",	     '||
'    MRIRI.PROCESS_REVISION			       "PROCESS REVISION",		     '||
'    to_char(MRIRI.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "LAST UPDATE DATE", '||
'    MRIRI.LAST_UPDATED_BY		       "LAST UPDATED BY",	     '||
'    to_char(MRIRI.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'')  "CREATION DATE",	'||
'    MRIRI.CREATED_BY			       "CREATED BY",		     '||
'    MRIRI.LAST_UPDATE_LOGIN		       "LAST UPDATE LOGIN",	     '||
'    MRIRI.CHANGE_NOTICE			       "CHANGE NOTICE",		     '||
'    to_char(MRIRI.ECN_INITIATION_DATE,''DD-MON-YYYY HH24:MI:SS'') "ECN INITIATION DATE",'||
'    to_char(MRIRI.IMPLEMENTATION_DATE,''DD-MON-YYYY HH24:MI:SS'') "IMPLEMENTATION DATE",'||
'    MRIRI.IMPLEMENTED_SERIAL_NUMBER	       "IMPLEMENTED SERIAL NUMBER",  '||
'    to_char(MRIRI.EFFECTIVITY_DATE,''DD-MON-YYYY HH24:MI:SS'')	"EFFECTIVITY DATE",	'||
'    MRIRI.ATTRIBUTE_CATEGORY		       "ATTRIBUTE CATEGORY",	     '||
'    MRIRI.ATTRIBUTE1			       "ATTRIBUTE1",		     '||
'    MRIRI.ATTRIBUTE2			       "ATTRIBUTE2",		     '||
'    MRIRI.ATTRIBUTE3			       "ATTRIBUTE3",		     '||
'    MRIRI.ATTRIBUTE4			       "ATTRIBUTE4",		     '||
'    MRIRI.ATTRIBUTE5			       "ATTRIBUTE5",		     '||
'    MRIRI.ATTRIBUTE6			       "ATTRIBUTE6",		     '||
'    MRIRI.ATTRIBUTE7			       "ATTRIBUTE7",		     '||
'    MRIRI.ATTRIBUTE8			       "ATTRIBUTE8",		     '||
'    MRIRI.ATTRIBUTE9			       "ATTRIBUTE9",		     '||
'    MRIRI.ATTRIBUTE10			       "ATTRIBUTE10",		     '||
'    MRIRI.ATTRIBUTE11			       "ATTRIBUTE11",		     '||
'    MRIRI.ATTRIBUTE12			       "ATTRIBUTE12",		     '||
'    MRIRI.ATTRIBUTE13			       "ATTRIBUTE13",		     '||
'    MRIRI.ATTRIBUTE14			       "ATTRIBUTE14",		     '||
'    MRIRI.ATTRIBUTE15			       "ATTRIBUTE15",		     '||
'    MRIRI.REQUEST_ID			       "REQUEST ID",		     '||
'    MRIRI.PROGRAM_APPLICATION_ID	       "PROGRAM APPLICATION ID",     '||
'    MRIRI.PROGRAM_ID			       "PROGRAM ID",		     '||
'    to_char(MRIRI.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "PROGRAM UPDATE DATE",'||
'    MRIRI.INVENTORY_ITEM_NUMBER			       "INVENTORY ITEM NUMBER",		     '||
'    MRIRI.ORGANIZATION_CODE		       "ORGANIZATION CODE",	     '||
'    MRIRI.TRANSACTION_ID		       "TRANSACTION ID",	     '||
'    MRIRI.PROCESS_FLAG			       "PROCESS FLAG",		     '||
'    MRIRI.TRANSACTION_TYPE		       "TRANSACTION TYPE",	     '||
'    MRIRI.ORIGINAL_SYSTEM_REFERENCE   "ORIGINAL SYSTEM REFERENCE"    '||
'    from  mtl_rtg_item_revs_interface mriri	where 1=1		     ';

sqltxt :=sqltxt||' and rownum <   '||row_limit;
sqltxt :=sqltxt||' order by mriri.inventory_item_id, mriri.organization_id, mriri.process_revision ';

   num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Records in mtl_rtg_item_revs_interface table ');
   If (num_rows = row_limit -1 ) Then
	JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
   End If;
   statusStr := 'SUCCESS';
   isFatal := 'FALSE';

 /* End of mtl_rtg_item_revs_interface */


  /* SQL to fetch records from mtl_item_categories_interface */
 	sqltxt := 'SELECT ' ||
'    MICI.INVENTORY_ITEM_ID	       "INVENTORY ITEM ID",	  '||
'    MICI.CATEGORY_SET_ID	       "CATEGORY SET ID",	  '||
'    MICI.CATEGORY_ID		       "CATEGORY ID",		  '||
'    to_char(MICI.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "LAST UPDATE DATE",'||
'    MICI.LAST_UPDATED_BY	       "LAST UPDATED BY",	  '||
'    to_char(MICI.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'')	"CREATION DATE", '||
'    MICI.CREATED_BY		       "CREATED BY",		  '||
'    MICI.LAST_UPDATE_LOGIN	       "LAST UPDATE LOGIN",	  '||
'    MICI.REQUEST_ID		       "REQUEST ID",		  '||
'    MICI.PROGRAM_APPLICATION_ID       "PROGRAM APPLICATION ID",  '||
'    MICI.PROGRAM_ID		       "PROGRAM ID",		  '||
'    to_char(MICI.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "PROGRAM UPDATE DATE",'||
'    MICI.ORGANIZATION_ID	       "ORGANIZATION ID",	  '||
'    MICI.TRANSACTION_ID	       "TRANSACTION ID",	  '||
'    MICI.PROCESS_FLAG		       "PROCESS FLAG",		  '||
'    MICI.CATEGORY_SET_NAME	       "CATEGORY SET NAME",	  '||
'    MICI.CATEGORY_NAME		       "CATEGORY NAME",		  '||
'    MICI.ORGANIZATION_CODE	       "ORGANIZATION CODE",	  '||
'    MICI.ITEM_NUMBER		       "ITEM NUMBER",		  '||
'    MICI.TRANSACTION_TYPE	       "TRANSACTION TYPE",	  '||
'    MICI.SET_PROCESS_ID	       "SET PROCESS ID",		  '||
'    MICI.OLD_CATEGORY_ID	       "OLD CATEGORY ID",		  '||
'    MICI.OLD_CATEGORY_NAME	"OLD CATEGORY NAME",		  '||
'    MICI.SOURCE_SYSTEM_ID		"SOURCE SYSTEM ID",		  '||
'    MICI.SOURCE_SYSTEM_REFERENCE "SOURCE SYSTEM REFERENCE",		  '||
'    MICI.CHANGE_ID				 "CHANGE ID",		  '||
'    MICI.CHANGE_LINE_ID		 "CHANGE LINE ID"		  '||
'    from  mtl_item_categories_interface mici	where 1=1	  ';

sqltxt :=sqltxt||' and rownum <   '||row_limit;
sqltxt :=sqltxt||' order by mici.inventory_item_id, mici.organization_id, '||
		 ' mici.category_set_id, mici.category_id		  ';

   num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Records in mtl_item_categories_interface table ');
   If (num_rows = row_limit -1 ) Then
	JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
   End If;
   statusStr := 'SUCCESS';
   isFatal := 'FALSE';
  /* End of mtl_item_categories_interface */
/* End of  l_type = items */

Elsif upper(l_type) in ('BOM','RTG','ENG') Then

If upper(l_type) = 'BOM' Then
/* Fetch data from tables exclusive to bom */

/* Get the application installation info. References to Data Dictionary Objects without schema name
included in WHERE predicate are not allowed (GSCC Check: file.sql.47). Schema name has to be passed
as an input parameter to JTF_DIAGNOSTIC_COREAPI.Column_Exists API. */

l_ret_status :=      fnd_installation.get_app_info ('BOM'
                                   , l_status
                                   , l_industry
                                   , l_oracle_schema
                                    );

/*JTF_DIAGNOSTIC_COREAPI.Line_Out(' l_oracle_schema: '||l_oracle_schema);*/

 /* SQL to fetch from bom_bill_of_mtls_interface table */
sqltxt := 'SELECT ' ||
'    BBMI.ASSEMBLY_ITEM_ID		  "ASSEMBLY ITEM ID",		   '||
'    BBMI.ORGANIZATION_ID		  "ORGANIZATION ID",		   '||
'    BBMI.ALTERNATE_BOM_DESIGNATOR	  "ALTERNATE BOM DESIGNATOR",	   '||
'    to_char(BBMI.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "LAST UPDATE DATE", '||
'    BBMI.LAST_UPDATED_BY		  "LAST UPDATED BY",		   '||
'    to_char(BBMI.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'') "CREATION DATE",	'||
'    BBMI.CREATED_BY			  "CREATED BY",			   '||
'    BBMI.LAST_UPDATE_LOGIN		  "LAST UPDATE LOGIN",		   '||
'    BBMI.COMMON_ASSEMBLY_ITEM_ID	  "COMMON ASSEMBLY ITEM ID",	   '||
'    BBMI.SPECIFIC_ASSEMBLY_COMMENT	  "SPECIFIC ASSEMBLY COMMENT",	   '||
'    BBMI.PENDING_FROM_ECN		  "PENDING FROM ECN",		   '||
'    BBMI.ATTRIBUTE_CATEGORY		  "ATTRIBUTE CATEGORY",		   '||
'    BBMI.ATTRIBUTE1			  "ATTRIBUTE1",			   '||
'    BBMI.ATTRIBUTE2			  "ATTRIBUTE2",			   '||
'    BBMI.ATTRIBUTE3			  "ATTRIBUTE3",			   '||
'    BBMI.ATTRIBUTE4			  "ATTRIBUTE4",			   '||
'    BBMI.ATTRIBUTE5			  "ATTRIBUTE5",			   '||
'    BBMI.ATTRIBUTE6			  "ATTRIBUTE6",			   '||
'    BBMI.ATTRIBUTE7			  "ATTRIBUTE7",			   '||
'    BBMI.ATTRIBUTE8			  "ATTRIBUTE8",			   '||
'    BBMI.ATTRIBUTE9			  "ATTRIBUTE9",			   '||
'    BBMI.ATTRIBUTE10			  "ATTRIBUTE10",		   '||
'    BBMI.ATTRIBUTE11			  "ATTRIBUTE11",		   '||
'    BBMI.ATTRIBUTE12			  "ATTRIBUTE12",		   '||
'    BBMI.ATTRIBUTE13			  "ATTRIBUTE13",		   '||
'    BBMI.ATTRIBUTE14			  "ATTRIBUTE14",		   '||
'    BBMI.ATTRIBUTE15			  "ATTRIBUTE15",		   '||
'    BBMI.ASSEMBLY_TYPE			  "ASSEMBLY TYPE",		   '||
'    BBMI.COMMON_BILL_SEQUENCE_ID	  "COMMON BILL SEQUENCE ID",	   '||
'    BBMI.BILL_SEQUENCE_ID		  "BILL SEQUENCE ID",		   '||
'    BBMI.REQUEST_ID			  "REQUEST ID",			   '||
'    BBMI.PROGRAM_APPLICATION_ID	  "PROGRAM APPLICATION ID",	   '||
'    BBMI.PROGRAM_ID			  "PROGRAM ID",			   '||
'    to_char(BBMI.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "PROGRAM UPDATE DATE", '||
'    BBMI.DEMAND_SOURCE_LINE		  "DEMAND SOURCE LINE",		   '||
'    BBMI.SET_ID			  "SET ID",			   '||
'    BBMI.COMMON_ORGANIZATION_ID	  "COMMON ORGANIZATION ID",	   '||
'    BBMI.DEMAND_SOURCE_TYPE		  "DEMAND SOURCE TYPE",		   '||
'    BBMI.DEMAND_SOURCE_HEADER_ID	  "DEMAND SOURCE HEADER ID",	   '||
'    BBMI.TRANSACTION_ID		  "TRANSACTION ID",		   '||
'    BBMI.PROCESS_FLAG			  "PROCESS FLAG",		   '||
'    BBMI.ORGANIZATION_CODE		  "ORGANIZATION CODE",		   '||
'    BBMI.COMMON_ORG_CODE		  "COMMON ORG CODE",		   '||
'    BBMI.ITEM_NUMBER			  "ITEM NUMBER",		   '||
'    BBMI.COMMON_ITEM_NUMBER		  "COMMON ITEM NUMBER",		   '||
'    to_char(BBMI.NEXT_EXPLODE_DATE,''DD-MON-YYYY HH24:MI:SS'')	"NEXT EXPLODE DATE", '||
'    BBMI.REVISION			  "REVISION",			   '||
'    BBMI.TRANSACTION_TYPE		  "TRANSACTION TYPE",		   '||
'    BBMI.DELETE_GROUP_NAME		  "DELETE GROUP NAME",		   '||
'    BBMI.DG_DESCRIPTION		  "DG DESCRIPTION",		   '||
'    BBMI.ORIGINAL_SYSTEM_REFERENCE	  "ORIGINAL SYSTEM REFERENCE"	   '||
'    ,to_char(BBMI.IMPLEMENTATION_DATE,''DD-MON-YYYY HH24:MI:SS'') "IMPLEMENTATION DATE "	   '||
'    ,BBMI.OBJ_NAME					"OBJ NAME"	   '||
'    ,BBMI.PK1_VALUE				"PK1 VALUE"	   '||
'    ,BBMI.PK2_VALUE				"PK2 VALUE"	   '||
'    ,BBMI.PK3_VALUE				"PK3 VALUE"	   '||
'    ,BBMI.PK4_VALUE				"PK4 VALUE"	   '||
'    ,BBMI.PK5_VALUE				"PK5 VALUE"	   '||
'    ,BBMI.STRUCTURE_TYPE_NAME		"STRUCTURE_TYPE_NAME"	   '||
'    ,BBMI.STRUCTURE_TYPE_ID			"STRUCTURE_TYPE_ID"	   '||
'    ,BBMI.EFFECTIVITY_CONTROL		"EFFECTIVITY CONTROL"	   '||
'    ,BBMI.RETURN_STATUS			"RETURN STATUS"	   '||
'    ,BBMI.IS_PREFERRED				"IS PREFERRED"	   '||
'    ,BBMI.SOURCE_SYSTEM_REFERENCE	"SOURCE SYSTEM REFERENCE"	   '||
'    ,BBMI.SOURCE_SYSTEM_REFERENCE_DESC"SOURCE SYSTEM REFERENCE DESC"	   '||
'    ,BBMI.BATCH_ID					"BATCH ID"	   '||
'    ,BBMI.CHANGE_ID				"CHANGE ID"	   '||
'    ,BBMI.CATALOG_CATEGORY_NAME	"CATALOG CATEGORY NAME"	   '||
'    ,BBMI.ITEM_CATALOG_GROUP_ID	"ITEM CATALOG GROUP ID"	   '||
'    ,BBMI.PRIMARY_UNIT_OF_MEASURE	"PRIMARY UNIT OF MEASURE"	   '||
'    ,BBMI.ITEM_DESCRIPTION			"ITEM DESCRIPTION"	   '||
'    ,BBMI.TEMPLATE_NAME			"TEMPLATE NAME"	   '||
'    ,BBMI.SOURCE_BILL_SEQUENCE_ID	"SOURCE BILL SEQUENCE ID"	   '||
'    ,BBMI.ENABLE_ATTRS_UPDATE		"ENABLE ATTRS UPDATE"	   '||
'    ,BBMI.INTERFACE_TABLE_UNIQUE_ID	"INTERFACE TABLE UNIQUE ID"	   '||
'    from  bom_bill_of_mtls_interface bbmi where 1=1		           ';

sqltxt :=sqltxt||' and rownum <   '||row_limit;
sqltxt :=sqltxt||' order by bbmi.assembly_item_id, bbmi.organization_id, bbmi.alternate_bom_designator';

   num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Records in bom_bill_of_mtls_interface table ');
   If (num_rows = row_limit -1 ) Then
	JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
   End If;
   statusStr := 'SUCCESS';
   isFatal := 'FALSE';
 /* End of bom_bill_of_mtls_interface */

/* End of tables exclusive to bom */

ElsIf upper(l_type) = 'RTG' Then
/* Fetch tables exclusive to rtg */

/* Get the application installation info. References to Data Dictionary Objects without schema name
included in WHERE predicate are not allowed (GSCC Check: file.sql.47). Schema name has to be passed
as an input parameter to JTF_DIAGNOSTIC_COREAPI.Column_Exists API. */

l_ret_status :=      fnd_installation.get_app_info ('BOM'
                                   , l_status
                                   , l_industry
                                   , l_oracle_schema
                                    );

/*JTF_DIAGNOSTIC_COREAPI.Line_Out(' l_oracle_schema: '||l_oracle_schema);*/

   /* SQL to fetch records from bom_op_routings_interface table */
sqltxt := 'SELECT ' ||
'    BORI.ROUTING_SEQUENCE_ID		     "ROUTING SEQUENCE ID",		  '||
'    BORI.ASSEMBLY_ITEM_ID		     "ASSEMBLY ITEM ID",		  '||
'    BORI.ORGANIZATION_ID		     "ORGANIZATION ID",			  '||
'    BORI.ALTERNATE_ROUTING_DESIGNATOR	     "ALTERNATE ROUTING DESIGNATOR",	  '||
'    to_char(BORI.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "LAST UPDATE DATE",'||
'    BORI.LAST_UPDATED_BY		     "LAST UPDATED BY",			  '||
'    to_char(BORI.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'')  "CREATION DATE",	  '||
'    BORI.CREATED_BY			     "CREATED BY",			  '||
'    BORI.LAST_UPDATE_LOGIN		     "LAST UPDATE LOGIN",		  '||
'    BORI.ROUTING_TYPE			     "ROUTING TYPE",			  '||
'    BORI.COMMON_ASSEMBLY_ITEM_ID	     "COMMON ASSEMBLY ITEM ID",		  '||
'    BORI.COMMON_ROUTING_SEQUENCE_ID	     "COMMON ROUTING SEQUENCE ID",	  '||
'    BORI.ROUTING_COMMENT		     "ROUTING COMMENT",			  '||
'    BORI.COMPLETION_SUBINVENTORY	     "COMPLETION SUBINVENTORY",		  '||
'    BORI.COMPLETION_LOCATOR_ID		     "COMPLETION LOCATOR ID",		  '||
'    BORI.ATTRIBUTE_CATEGORY		     "ATTRIBUTE CATEGORY",		  '||
'    BORI.ATTRIBUTE1			     "ATTRIBUTE1",			  '||
'    BORI.ATTRIBUTE2			     "ATTRIBUTE2",			  '||
'    BORI.ATTRIBUTE3			     "ATTRIBUTE3",			  '||
'    BORI.ATTRIBUTE4			     "ATTRIBUTE4",			  '||
'    BORI.ATTRIBUTE5			     "ATTRIBUTE5",			  '||
'    BORI.ATTRIBUTE6			     "ATTRIBUTE6",			  '||
'    BORI.ATTRIBUTE7			     "ATTRIBUTE7",			  '||
'    BORI.ATTRIBUTE8			     "ATTRIBUTE8",			  '||
'    BORI.ATTRIBUTE9			     "ATTRIBUTE9",			  '||
'    BORI.ATTRIBUTE10			     "ATTRIBUTE10",			  '||
'    BORI.ATTRIBUTE11			     "ATTRIBUTE11",			  '||
'    BORI.ATTRIBUTE12			     "ATTRIBUTE12",			  '||
'    BORI.ATTRIBUTE13			     "ATTRIBUTE13",			  '||
'    BORI.ATTRIBUTE14			     "ATTRIBUTE14",			  '||
'    BORI.ATTRIBUTE15			     "ATTRIBUTE15",			  '||
'    BORI.REQUEST_ID			     "REQUEST ID",			  '||
'    BORI.PROGRAM_APPLICATION_ID	     "PROGRAM APPLICATION ID",		  '||
'    BORI.PROGRAM_ID			     "PROGRAM ID",			  '||
'    to_char(BORI.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "PROGRAM UPDATE DATE",'||
'    BORI.DEMAND_SOURCE_LINE		     "DEMAND SOURCE LINE",		  '||
'    BORI.SET_ID			     "SET ID",				  '||
'    BORI.PROCESS_REVISION		     "PROCESS REVISION",		  '||
'    BORI.DEMAND_SOURCE_TYPE		     "DEMAND SOURCE TYPE",		  '||
'    BORI.DEMAND_SOURCE_HEADER_ID	     "DEMAND SOURCE HEADER ID",		  '||
'    BORI.ORGANIZATION_CODE		     "ORGANIZATION CODE",		  '||
'    BORI.ASSEMBLY_ITEM_NUMBER		     "ASSEMBLY ITEM NUMBER",		  '||
'    BORI.COMMON_ITEM_NUMBER		     "COMMON ITEM NUMBER",		  '||
'    BORI.LOCATION_NAME			     "LOCATION NAME",			  '||
'    BORI.TRANSACTION_ID		     "TRANSACTION ID",			  '||
'    BORI.PROCESS_FLAG			     "PROCESS FLAG",			  '||
'    BORI.TRANSACTION_TYPE		     "TRANSACTION TYPE",		  '||
'    BORI.LINE_ID			     "LINE ID",				  '||
'    BORI.LINE_CODE			     "LINE CODE",			  '||
'    BORI.MIXED_MODEL_MAP_FLAG		     "MIXED MODEL MAP FLAG",		  '||
'    BORI.PRIORITY			     "PRIORITY",			  '||
'    BORI.CFM_ROUTING_FLAG		     "CFM ROUTING FLAG",		  '||
'    BORI.TOTAL_PRODUCT_CYCLE_TIME	     "TOTAL PRODUCT CYCLE TIME",	  '||
'    BORI.CTP_FLAG			     "CTP FLAG",			  '||
'    BORI.ORIGINAL_SYSTEM_REFERENCE	     "ORIGINAL SYSTEM REFERENCE",	  '||
'    BORI.SERIALIZATION_START_OP	     "SERIALIZATION START OP",		  '||
'    BORI.DELETE_GROUP_NAME		     "DELETE GROUP NAME",		  '||
'    BORI.DG_DESCRIPTION		     "DG DESCRIPTION",			  '||
'    BORI.BATCH_ID				     "BATCH ID"			  '||
'    from  bom_op_routings_interface bori    where 1=1				  ';

sqltxt :=sqltxt||' and rownum <   '||row_limit;
sqltxt :=sqltxt||' order by  bori.assembly_item_id, bori.organization_id, bori.alternate_routing_designator';

   num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Records in bom_op_routings_interface table ');
   If (num_rows = row_limit -1 ) Then
	JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
   End If;
   statusStr := 'SUCCESS';
   isFatal := 'FALSE';

  /* End of bom_op_routings_interface */

  /* SQL to fetch records from bom_op_networks_interface table */
sqltxt := 'SELECT ' ||
'    BONI.FROM_OP_SEQ_ID				"FROM OP SEQ ID",			'||
'    BONI.TO_OP_SEQ_ID					"TO OP SEQ ID",				'||
'    BONI.TRANSITION_TYPE				"TRANSITION TYPE",			'||
'    BONI.PLANNING_PCT					"PLANNING PCT",				'||
'    BONI.OPERATION_TYPE				"OPERATION TYPE",			'||
'    to_char(BONI.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'')	"LAST UPDATE DATE",		'||
'    BONI.LAST_UPDATED_BY				"LAST UPDATED BY",			'||
'    to_char(BONI.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'') "CREATION DATE",			'||
'    BONI.CREATED_BY					"CREATED BY",				'||
'    BONI.LAST_UPDATE_LOGIN				"LAST UPDATE LOGIN",			'||
'    BONI.ATTRIBUTE_CATEGORY				"ATTRIBUTE CATEGORY",			'||
'    BONI.ATTRIBUTE1					"ATTRIBUTE1",				'||
'    BONI.ATTRIBUTE2					"ATTRIBUTE2",				'||
'    BONI.ATTRIBUTE3					"ATTRIBUTE3",				'||
'    BONI.ATTRIBUTE4					"ATTRIBUTE4",				'||
'    BONI.ATTRIBUTE5					"ATTRIBUTE5",				'||
'    BONI.ATTRIBUTE6					"ATTRIBUTE6",				'||
'    BONI.ATTRIBUTE7					"ATTRIBUTE7",				'||
'    BONI.ATTRIBUTE8					"ATTRIBUTE8",				'||
'    BONI.ATTRIBUTE9					"ATTRIBUTE9",				'||
'    BONI.ATTRIBUTE10					"ATTRIBUTE10",				'||
'    BONI.ATTRIBUTE11					"ATTRIBUTE11",				'||
'    BONI.ATTRIBUTE12					"ATTRIBUTE12",				'||
'    BONI.ATTRIBUTE13					"ATTRIBUTE13",				'||
'    BONI.ATTRIBUTE14					"ATTRIBUTE14",				'||
'    BONI.ATTRIBUTE15					"ATTRIBUTE15",				'||
'    BONI.FROM_X_COORDINATE				"FROM X COORDINATE",			'||
'    BONI.TO_X_COORDINATE				"TO X COORDINATE",			'||
'    BONI.FROM_Y_COORDINATE				"FROM Y COORDINATE",			'||
'    BONI.TO_Y_COORDINATE				"TO Y COORDINATE",			'||
'    BONI.FROM_OP_SEQ_NUMBER				"FROM OP SEQ NUMBER",			'||
'    BONI.TO_OP_SEQ_NUMBER				"TO OP SEQ NUMBER",			'||
'    to_char(BONI.FROM_START_EFFECTIVE_DATE,''DD-MON-YYYY HH24:MI:SS'')	"FROM START EFFECTIVE DATE",	'||
'    to_char(BONI.TO_START_EFFECTIVE_DATE,''DD-MON-YYYY HH24:MI:SS'')	"TO START EFFECTIVE DATE",	'||
'    BONI.PROGRAM_APPLICATION_ID			"PROGRAM APPLICATION ID",		'||
'    BONI.PROGRAM_ID					"PROGRAM ID",				'||
'    to_char(BONI.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "PROGRAM UPDATE DATE",	'||
'    BONI.NEW_FROM_OP_SEQ_NUMBER			"NEW FROM OP SEQ NUMBER",		'||
'    BONI.NEW_TO_OP_SEQ_NUMBER				"NEW TO OP SEQ NUMBER",			'||
'    to_char(BONI.NEW_FROM_START_EFFECTIVE_DATE,''DD-MON-YYYY HH24:MI:SS'') "NEW FROM START EFFECTIVE DATE",	'||
'    to_char(BONI.NEW_TO_START_EFFECTIVE_DATE,''DD-MON-YYYY HH24:MI:SS'') "NEW TO START EFFECTIVE DATE",	'||
'    BONI.ASSEMBLY_ITEM_ID				"ASSEMBLY ITEM ID",			'||
'    BONI.ALTERNATE_ROUTING_DESIGNATOR			"ALTERNATE ROUTING DESIGNATOR",		'||
'    BONI.ORGANIZATION_ID				"ORGANIZATION ID",			'||
'    BONI.ROUTING_SEQUENCE_ID				"ROUTING SEQUENCE ID",			'||
'    BONI.ORGANIZATION_CODE				"ORGANIZATION CODE",			'||
'    BONI.ASSEMBLY_ITEM_NUMBER				"ASSEMBLY ITEM NUMBER",			'||
'    BONI.ORIGINAL_SYSTEM_REFERENCE			"ORIGINAL SYSTEM REFERENCE",		'||
'    BONI.TRANSACTION_ID				"TRANSACTION ID",			'||
'    BONI.PROCESS_FLAG					"PROCESS FLAG",				'||
'    BONI.TRANSACTION_TYPE				"TRANSACTION TYPE"			'||
'    ,BONI.REQUEST_ID					"REQUEST ID"				'||
'    ,BONI.BATCH_ID						"BATCH ID"				'||
'    from  bom_op_networks_interface boni    where 1=1						';

sqltxt :=sqltxt||' and rownum <   '||row_limit;
sqltxt :=sqltxt||' order by  boni.assembly_item_id, boni.organization_id, boni.alternate_routing_designator,'||
		 ' boni.from_op_seq_id, boni.to_op_seq_id ';

   num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Records in bom_op_networks_interface table ');
   If (num_rows = row_limit -1 ) Then
	JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
   End If;
   statusStr := 'SUCCESS';
   isFatal := 'FALSE';

  /* End of bom_op_networks_interface */

/* End of tables exclusive to rtg */

ElsIf upper(l_type) = 'ENG' Then
/* Fetch tables exclusive to eng */
   /* SQL to fetch records from eng_eng_changes_interface table */
      	sqltxt := 'SELECT ' ||
'    EECI.CHANGE_NOTICE			  "CHANGE NOTICE",		  '||
'    EECI.ORGANIZATION_ID		  "ORGANIZATION ID",		  '||
'    to_char(EECI.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'')	"LAST UPDATE DATE", '||
'    EECI.LAST_UPDATED_BY		  "LAST UPDATED BY",		  '||
'    to_char(EECI.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'')	 "CREATION DATE", '||
'    EECI.CREATED_BY			  "CREATED BY",			  '||
'    EECI.LAST_UPDATE_LOGIN		  "LAST UPDATE LOGIN",		  '||
'    EECI.DESCRIPTION			  "DESCRIPTION",		  '||
'    EECI.STATUS_TYPE			  "STATUS TYPE",		  '||
'    to_char(EECI.INITIATION_DATE,''DD-MON-YYYY HH24:MI:SS'') "INITIATION DATE", '||
'    to_char(EECI.IMPLEMENTATION_DATE,''DD-MON-YYYY HH24:MI:SS'') "IMPLEMENTATION DATE", '||
'    to_char(EECI.CANCELLATION_DATE,''DD-MON-YYYY HH24:MI:SS'')	"CANCELLATION DATE",	'||
'    EECI.CANCELLATION_COMMENTS		  "CANCELLATION COMMENTS",	  '||
'    EECI.PRIORITY_CODE			  "PRIORITY CODE",		  '||
'    EECI.REASON_CODE			  "REASON CODE",		  '||
'    EECI.ESTIMATED_ENG_COST		  "ESTIMATED ENG COST",		  '||
'    EECI.ESTIMATED_MFG_COST		  "ESTIMATED MFG COST",		  '||
'    EECI.REQUESTOR_ID			  "REQUESTOR ID",		  '||
'    EECI.ATTRIBUTE_CATEGORY		  "ATTRIBUTE CATEGORY",		  '||
'    EECI.ATTRIBUTE1			  "ATTRIBUTE1",			  '||
'    EECI.ATTRIBUTE2			  "ATTRIBUTE2",			  '||
'    EECI.ATTRIBUTE3			  "ATTRIBUTE3",			  '||
'    EECI.ATTRIBUTE4			  "ATTRIBUTE4",			  '||
'    EECI.ATTRIBUTE5			  "ATTRIBUTE5",			  '||
'    EECI.ATTRIBUTE6			  "ATTRIBUTE6",			  '||
'    EECI.ATTRIBUTE7			  "ATTRIBUTE7",			  '||
'    EECI.ATTRIBUTE8			  "ATTRIBUTE8",			  '||
'    EECI.ATTRIBUTE9			  "ATTRIBUTE9",			  '||
'    EECI.ATTRIBUTE10			  "ATTRIBUTE10",		  '||
'    EECI.ATTRIBUTE11			  "ATTRIBUTE11",		  '||
'    EECI.ATTRIBUTE12			  "ATTRIBUTE12",		  '||
'    EECI.ATTRIBUTE13			  "ATTRIBUTE13",		  '||
'    EECI.ATTRIBUTE14			  "ATTRIBUTE14",		  '||
'    EECI.ATTRIBUTE15			  "ATTRIBUTE15",		  '||
'    EECI.REQUEST_ID			  "REQUEST ID",			  '||
'    EECI.PROGRAM_APPLICATION_ID	  "PROGRAM APPLICATION ID",	  '||
'    EECI.PROGRAM_ID			  "PROGRAM ID",			  '||
'    to_char(EECI.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "PROGRAM UPDATE DATE",'||
'    EECI.APPROVAL_STATUS_TYPE		  "APPROVAL STATUS TYPE",	  '||
'    to_char(EECI.APPROVAL_DATE,''DD-MON-YYYY HH24:MI:SS'') "APPROVAL DATE", '||
'    EECI.APPROVAL_LIST_ID		  "APPROVAL LIST ID",		  '||
'    EECI.APPROVAL_LIST_NAME		  "APPROVAL LIST NAME",		  '||
'    EECI.CHANGE_ORDER_TYPE_ID		  "CHANGE ORDER TYPE ID",	  '||
'    EECI.CHANGE_ORDER_TYPE		  "CHANGE ORDER TYPE",		  '||
'    EECI.RESPONSIBLE_ORGANIZATION_ID	  "RESPONSIBLE ORGANIZATION ID",  '||
'    EECI.SET_ID			  "SET ID",			  '||
'    to_char(EECI.APPROVAL_REQUEST_DATE,''DD-MON-YYYY HH24:MI:SS'') "APPROVAL REQUEST DATE",'||
'    EECI.DDF_CONTEXT			  "DDF CONTEXT",		  '||
'    EECI.CO_CREATED			  "CO CREATED",			  '||
'    EECI.TRANSACTION_ID		  "TRANSACTION ID",		  '||
'    EECI.TRANSACTION_TYPE		  "TRANSACTION TYPE",		  '||
'    EECI.PROCESS_FLAG			  "PROCESS FLAG",		  '||
'    EECI.ORGANIZATION_CODE		  "ORGANIZATION CODE",		  '||
'    EECI.RESPONSIBLE_ORG_CODE		  "RESPONSIBLE ORG CODE",	  '||
'    EECI.ENG_CHANGES_IFCE_KEY		  "ENG CHANGES IFCE KEY",	  '||
'    EECI.CHANGE_ID			  "CHANGE ID",			  '||
'    EECI.STATUS_NAME			  "STATUS NAME",		  '||
'    EECI.REQUESTOR_USER_NAME		  "REQUESTOR USER NAME",	  '||
'    EECI.APPROVAL_STATUS_NAME		  "APPROVAL STATUS NAME",	  '||
'    EECI.CHANGE_MGMT_TYPE_CODE		  "CHANGE MGMT TYPE CODE",	  '||
'    EECI.ORIGINAL_SYSTEM_REFERENCE	  "ORIGINAL SYSTEM REFERENCE",	  '||
'    EECI.ORGANIZATION_HIERARCHY	  "ORGANIZATION HIERARCHY",	  '||
'    EECI.ASSIGNEE_NAME			  "ASSIGNEE NAME",		  '||
'    EECI.SOURCE_TYPE_NAME		  "SOURCE TYPE NAME",		  '||
'    EECI.SOURCE_NAME			  "SOURCE NAME",		  '||
'    to_char(EECI.NEED_BY_DATE,''DD-MON-YYYY HH24:MI:SS'') "NEED BY DATE",'||
'    EECI.EFFORT			  "EFFORT",			  '||
'    EECI.CHANGE_NAME			  "CHANGE NAME",		  '||
'    EECI.CHANGE_NOTICE_PREFIX		  "CHANGE NOTICE PREFIX",	  '||
'    EECI.CHANGE_NOTICE_NUMBER		  "CHANGE NOTICE NUMBER",	  '||
'    EECI.ECO_DEPARTMENT_NAME		  "ECO DEPARTMENT NAME",	  '||
'    EECI.INTERNAL_USE_ONLY		  "INTERNAL USE ONLY",		  '||
'    EECI.CHANGE_MGMT_TYPE_NAME		  "CHANGE MGMT TYPE NAME",	  '||
'    EECI.PROJECT_NAME			  "PROJECT NAME",		  '||
'    EECI.TASK_NUMBER			  "TASK NUMBER",		  '||
'    EECI.PK1_NAME			  "PK1 NAME",			  '||
'    EECI.PK2_NAME			  "PK2 NAME",			  '||
'    EECI.PK3_NAME			  "PK3 NAME",			  '||
'    EECI.PLM_OR_ERP_CHANGE		  "PLM OR ERP CHANGE",		  '||
'    EECI.ASSIGNEE_ID			  "ASSIGNEE ID",		  '||
'    EECI.CLASSIFICATION_ID		  "CLASSIFICATION ID",		  '||
'    EECI.HIERARCHY_ID			  "HIERARCHY ID",		  '||
'    EECI.SOURCE_ID	 			  "SOURCE ID",		  '||
'    EECI.SOURCE_TYPE_CODE		  "SOURCE TYPE CODE",		  '||
'    EECI.EMPLOYEE_NUMBER		  "EMPLOYEE NUMBER"		  '||
'    from  eng_eng_changes_interface eeci   where 1=1			  ';

sqltxt :=sqltxt||' and rownum <   '||row_limit;
sqltxt :=sqltxt||' order by eeci.change_notice, eeci.organization_id  ';

   num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Records in eng_eng_changes_interface table ');
   If (num_rows = row_limit -1 ) Then
	JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
   End If;
   statusStr := 'SUCCESS';
   isFatal := 'FALSE';

  /* End of eng_eng_changes_interface */

   /* SQL to fetch records from eng_revised_items_interface table */
      	sqltxt := 'SELECT ' ||
'    ERII.CHANGE_NOTICE			  "CHANGE NOTICE",		   '||
'    ERII.ORGANIZATION_ID		  "ORGANIZATION ID",		   '||
'    ERII.REVISED_ITEM_ID		  "REVISED ITEM ID",		   '||
'    to_char(ERII.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "LAST UPDATE DATE",'||
'    ERII.LAST_UPDATED_BY		  "LAST UPDATED BY",		   '||
'    to_char(ERII.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'') "CREATION DATE", '||
'    ERII.CREATED_BY			  "CREATED BY",			   '||
'    ERII.LAST_UPDATE_LOGIN		  "LAST UPDATE LOGIN",		   '||
'    to_char(ERII.IMPLEMENTATION_DATE,''DD-MON-YYYY HH24:MI:SS'')"IMPLEMENTATION DATE",	'||
'    ERII.DESCRIPTIVE_TEXT		  "DESCRIPTIVE TEXT",		   '||
'    to_char(ERII.CANCELLATION_DATE,''DD-MON-YYYY HH24:MI:SS'')	 "CANCELLATION DATE",	'||
'    ERII.CANCEL_COMMENTS		  "CANCEL COMMENTS",		   '||
'    ERII.DISPOSITION_TYPE		  "DISPOSITION TYPE",		   '||
'    ERII.NEW_ITEM_REVISION		  "NEW ITEM REVISION",		   '||
'    to_char(ERII.AUTO_IMPLEMENT_DATE,''DD-MON-YYYY HH24:MI:SS'') "AUTO IMPLEMENT DATE", '||
'    to_char(ERII.EARLY_SCHEDULE_DATE,''DD-MON-YYYY HH24:MI:SS'') "EARLY SCHEDULE DATE", '||
'    ERII.ATTRIBUTE_CATEGORY		  "ATTRIBUTE CATEGORY",		   '||
'    ERII.ATTRIBUTE1			  "ATTRIBUTE1",			   '||
'    ERII.ATTRIBUTE2			  "ATTRIBUTE2",			   '||
'    ERII.ATTRIBUTE3			  "ATTRIBUTE3",			   '||
'    ERII.ATTRIBUTE4			  "ATTRIBUTE4",			   '||
'    ERII.ATTRIBUTE5			  "ATTRIBUTE5",			   '||
'    ERII.ATTRIBUTE6			  "ATTRIBUTE6",			   '||
'    ERII.ATTRIBUTE7			  "ATTRIBUTE7",			   '||
'    ERII.ATTRIBUTE8			  "ATTRIBUTE8",			   '||
'    ERII.ATTRIBUTE9			  "ATTRIBUTE9",			   '||
'    ERII.ATTRIBUTE10			  "ATTRIBUTE10",		   '||
'    ERII.ATTRIBUTE11			  "ATTRIBUTE11",		   '||
'    ERII.ATTRIBUTE12			  "ATTRIBUTE12",		   '||
'    ERII.ATTRIBUTE13			  "ATTRIBUTE13",		   '||
'    ERII.ATTRIBUTE14			  "ATTRIBUTE14",		   '||
'    ERII.ATTRIBUTE15			  "ATTRIBUTE15",		   '||
'    ERII.STATUS_TYPE			  "STATUS TYPE",		   '||
'    to_char(ERII.SCHEDULED_DATE,''DD-MON-YYYY HH24:MI:SS'') "SCHEDULED DATE",	'||
'    ERII.BILL_SEQUENCE_ID		  "BILL SEQUENCE ID",		   '||
'    ERII.MRP_ACTIVE			  "MRP ACTIVE",			   '||
'    ERII.REQUEST_ID			  "REQUEST ID",			   '||
'    ERII.PROGRAM_APPLICATION_ID	  "PROGRAM APPLICATION ID",	   '||
'    ERII.PROGRAM_ID			  "PROGRAM ID",			   '||
'    to_char(ERII.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "PROGRAM UPDATE DATE", '||
'    ERII.UPDATE_WIP			  "UPDATE WIP",			   '||
'    ERII.USE_UP			  "USE UP",			   '||
'    ERII.USE_UP_ITEM_ID		  "USE UP ITEM ID",		   '||
'    ERII.REVISED_ITEM_SEQUENCE_ID	  "REVISED ITEM SEQUENCE ID",	   '||
'    ERII.ALTERNATE_BOM_DESIGNATOR	  "ALTERNATE BOM DESIGNATOR",	   '||
'    ERII.CATEGORY_SET_ID		  "CATEGORY SET ID",		   '||
'    ERII.STRUCTURE_ID			  "STRUCTURE ID",		   '||
'    ERII.ITEM_FROM			  "ITEM FROM",			   '||
'    ERII.ITEM_TO			  "ITEM TO",			   '||
'    ERII.CATEGORY_FROM			  "CATEGORY FROM",		   '||
'    ERII.CATEGORY_TO			  "CATEGORY TO",		   '||
'    ERII.DDF_CONTEXT			  "DDF CONTEXT",		   '||
'    ERII.INCREMENT_REV			  "INCREMENT REV",		   '||
'    ERII.ITEM_TYPE			  "ITEM TYPE",			   '||
'    ERII.USE_UP_PLAN_NAME		  "USE UP PLAN NAME",		   '||
'    ERII.ALTERNATE_SELECTION_CODE	  "ALTERNATE SELECTION CODE",	   '||
'    ERII.TRANSACTION_ID		  "TRANSACTION ID",		   '||
'    ERII.TRANSACTION_TYPE		  "TRANSACTION TYPE",		   '||
'    ERII.PROCESS_FLAG			  "PROCESS FLAG",		   '||
'    ERII.ORGANIZATION_CODE		  "ORGANIZATION CODE",		   '||
'    ERII.REQUESTOR_ID			  "REQUESTOR ID",		   '||
'    ERII.COMMENTS			  "COMMENTS",			   '||
'    ERII.REVISED_ITEM_NUMBER		  "REVISED ITEM NUMBER",	   '||
'    ERII.ASSEMBLY_ITEM_NUMBER		  "ASSEMBLY ITEM NUMBER",	   '||
'    ERII.USE_UP_ITEM_NUMBER		  "USE UP ITEM NUMBER",		   '||
'    ERII.APPROVAL_LIST_NAME		  "APPROVAL LIST NAME",		   '||
'    ERII.BASE_ITEM_ID			  "BASE ITEM ID",		   '||
'    ERII.ENG_REVISED_ITEMS_IFCE_KEY	  "ENG REVISED ITEMS IFCE KEY",	   '||
'    ERII.ENG_CHANGES_IFCE_KEY		  "ENG CHANGES IFCE KEY",	   '||
'    ERII.FROM_END_ITEM_UNIT_NUMBER	  "FROM END ITEM UNIT NUMBER",	   '||
'    ERII.NEW_RTG_REVISION		  "NEW RTG REVISION",		   '||
'    ERII.FROM_END_ITEM_REV_ID		  "FROM END ITEM REV ID",	   '||
'    ERII.FROM_END_ITEM_NUMBER		  "FROM END ITEM NUMBER",	   '||
'    ERII.FROM_END_ITEM_REVISION	  "FROM END ITEM REVISION",	   '||
'    ERII.PARENT_REVISED_ITEM_NAME	  "PARENT REVISED ITEM NAME",	   '||
'    ERII.PARENT_ALTERNATE_NAME		  "PARENT ALTERNATE NAME",	   '||
'    ERII.UPDATED_ITEM_REVISION		  "UPDATED ITEM REVISION",	   '||
'    to_char(ERII.NEW_SCHEDULED_DATE,''DD-MON-YYYY HH24:MI:SS'') "NEW SCHEDULED DATE", '||
'    ERII.FROM_ITEM_REVISION	 		  "FROM ITEM REVISION",	   '||
'    ERII.NEW_REVISION_LABEL		  "NEW REVISION LABEL",	   '||
'    ERII.NEW_REVISED_ITEM_REV_DESC	  "NEW REVISED ITEM REV DESC",	   '||
'    ERII.NEW_REVISION_REASON		  "NEW REVISION REASON"	   '||
'    from  eng_revised_items_interface erii   where 1=1			   ';

sqltxt :=sqltxt||' and rownum <   '||row_limit;
sqltxt :=sqltxt||' order by erii.change_notice,erii.organization_id,	'||
		 ' erii.revised_item_id,erii.revised_item_sequence_id   ';

   num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Records in eng_revised_items_interface table ');
   If (num_rows = row_limit -1 ) Then
	JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
   End If;
   statusStr := 'SUCCESS';
   isFatal := 'FALSE';

  /* End of eng_revised_items_interface */

   /* SQL to fetch records from eng_eco_revisions_interface table */
      	sqltxt := 'SELECT ' ||
'    EERI.REVISION_ID			  "REVISION ID",		    '||
'    EERI.CHANGE_NOTICE			  "CHANGE NOTICE",		    '||
'    EERI.ORGANIZATION_ID		  "ORGANIZATION ID",		    '||
'    EERI.REVISION			  "REVISION",			    '||
'    to_char(EERI.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'')"LAST UPDATE DATE",'||
'    EERI.LAST_UPDATED_BY		  "LAST UPDATED BY",		    '||
'    to_char(EERI.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'') "CREATION DATE",	'||
'    EERI.CREATED_BY			  "CREATED BY",			    '||
'    EERI.LAST_UPDATE_LOGIN		  "LAST UPDATE LOGIN",		    '||
'    EERI.COMMENTS			  "COMMENTS",			    '||
'    EERI.ATTRIBUTE_CATEGORY		  "ATTRIBUTE CATEGORY",		    '||
'    EERI.ATTRIBUTE1			  "ATTRIBUTE1",			    '||
'    EERI.ATTRIBUTE2			  "ATTRIBUTE2",			    '||
'    EERI.ATTRIBUTE3			  "ATTRIBUTE3",			    '||
'    EERI.ATTRIBUTE4			  "ATTRIBUTE4",			    '||
'    EERI.ATTRIBUTE5			  "ATTRIBUTE5",			    '||
'    EERI.ATTRIBUTE6			  "ATTRIBUTE6",			    '||
'    EERI.ATTRIBUTE7			  "ATTRIBUTE7",			    '||
'    EERI.ATTRIBUTE8			  "ATTRIBUTE8",			    '||
'    EERI.ATTRIBUTE9			  "ATTRIBUTE9",			    '||
'    EERI.ATTRIBUTE10			  "ATTRIBUTE10",		    '||
'    EERI.ATTRIBUTE11			  "ATTRIBUTE11",		    '||
'    EERI.ATTRIBUTE12			  "ATTRIBUTE12",		    '||
'    EERI.ATTRIBUTE13			  "ATTRIBUTE13",		    '||
'    EERI.ATTRIBUTE14			  "ATTRIBUTE14",		    '||
'    EERI.ATTRIBUTE15			  "ATTRIBUTE15",		    '||
'    EERI.PROGRAM_APPLICATION_ID	  "PROGRAM APPLICATION ID",	    '||
'    EERI.PROGRAM_ID			  "PROGRAM ID",			    '||
'    to_char(EERI.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "PROGRAM UPDATE DATE", '||
'    EERI.REQUEST_ID			  "REQUEST ID",			    '||
'    EERI.TRANSACTION_ID		  "TRANSACTION ID",		    '||
'    EERI.TRANSACTION_TYPE		  "TRANSACTION TYPE",		    '||
'    EERI.PROCESS_FLAG			  "PROCESS FLAG",		    '||
'    EERI.ORGANIZATION_CODE		  "ORGANIZATION CODE",		    '||
'    EERI.NEW_REVISION			  "NEW REVISION",		    '||
'    EERI.ENG_ECO_REVISIONS_IFCE_KEY	  "ENG ECO REVISIONS IFCE KEY",	    '||
'    EERI.ENG_CHANGES_IFCE_KEY		  "ENG CHANGES IFCE KEY",	    '||
'    EERI.CHANGE_ID			  "CHANGE ID"			    '||
'    from  eng_eco_revisions_interface eeri  where 1=1			     ';

sqltxt :=sqltxt||' and rownum <   '||row_limit;
sqltxt :=sqltxt||' order by  eeri.organization_id, eeri.change_notice,eeri.revision ';

   num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Records in eng_eco_revisions_interface table ');
   If (num_rows = row_limit -1 ) Then
	JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
   End If;
   statusStr := 'SUCCESS';
   isFatal := 'FALSE';

  /* End of eng_eco_revisions_interface */

/* End of tables exclusive to eng */
End If; /* End of exclusive tables */

If upper(l_type) in ('BOM','ENG') Then
/* Fetch tables common to bom and eng */

/* Get the application installation info. References to Data Dictionary Objects without schema name
included in WHERE predicate are not allowed (GSCC Check: file.sql.47). Schema name has to be passed
as an input parameter to JTF_DIAGNOSTIC_COREAPI.Column_Exists API. */

l_ret_status :=      fnd_installation.get_app_info ('BOM'
                                   , l_status
                                   , l_industry
                                   , l_oracle_schema
                                    );

/*JTF_DIAGNOSTIC_COREAPI.Line_Out(' l_oracle_schema: '||l_oracle_schema);*/

/* SQL to fetch records from bom_inventory_comps_interface */
sqltxt := 'SELECT ' ||
'    BICI.OPERATION_SEQ_NUM			"OPERATION SEQ NUM",			 '||
'    BICI.COMPONENT_ITEM_ID			"COMPONENT ITEM ID",			 '||
'    to_char(BICI.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'')	"LAST UPDATE DATE",	'||
'    BICI.LAST_UPDATED_BY			"LAST UPDATED BY",			 '||
'    to_char(BICI.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'') "CREATION DATE",		'||
'    BICI.CREATED_BY				"CREATED BY",				 '||
'    BICI.LAST_UPDATE_LOGIN			"LAST UPDATE LOGIN",			 '||
'    BICI.ITEM_NUM				"ITEM NUM",				 '||
'    BICI.COMPONENT_QUANTITY			"COMPONENT QUANTITY",			 '||
'    BICI.COMPONENT_YIELD_FACTOR		"COMPONENT YIELD FACTOR",		 '||
'    BICI.COMPONENT_REMARKS			"COMPONENT REMARKS",			 '||
'    to_char(BICI.EFFECTIVITY_DATE,''DD-MON-YYYY HH24:MI:SS'')	"EFFECTIVITY DATE",	'||
'    BICI.CHANGE_NOTICE				"CHANGE NOTICE",			 '||
'    to_char(BICI.IMPLEMENTATION_DATE,''DD-MON-YYYY HH24:MI:SS'') "IMPLEMENTATION DATE", '||
'    to_char(BICI.DISABLE_DATE,''DD-MON-YYYY HH24:MI:SS'')	"DISABLE DATE",		 '||
'    BICI.ATTRIBUTE_CATEGORY			"ATTRIBUTE CATEGORY",			 '||
'    BICI.ATTRIBUTE1				"ATTRIBUTE1",				 '||
'    BICI.ATTRIBUTE2				"ATTRIBUTE2",				 '||
'    BICI.ATTRIBUTE3				"ATTRIBUTE3",				 '||
'    BICI.ATTRIBUTE4				"ATTRIBUTE4",				 '||
'    BICI.ATTRIBUTE5				"ATTRIBUTE5",				 '||
'    BICI.ATTRIBUTE6				"ATTRIBUTE6",				 '||
'    BICI.ATTRIBUTE7				"ATTRIBUTE7",				 '||
'    BICI.ATTRIBUTE8				"ATTRIBUTE8",				 '||
'    BICI.ATTRIBUTE9				"ATTRIBUTE9",				 '||
'    BICI.ATTRIBUTE10				"ATTRIBUTE10",				 '||
'    BICI.ATTRIBUTE11				"ATTRIBUTE11",				 '||
'    BICI.ATTRIBUTE12				"ATTRIBUTE12",				 '||
'    BICI.ATTRIBUTE13				"ATTRIBUTE13",				 '||
'    BICI.ATTRIBUTE14				"ATTRIBUTE14",				 '||
'    BICI.ATTRIBUTE15				"ATTRIBUTE15",				 '||
'    BICI.PLANNING_FACTOR			"PLANNING FACTOR",			 '||
'    BICI.QUANTITY_RELATED			"QUANTITY RELATED",			 '||
'    BICI.SO_BASIS				"SO BASIS",				 '||
'    BICI.OPTIONAL				"OPTIONAL",				 '||
'    BICI.MUTUALLY_EXCLUSIVE_OPTIONS		"MUTUALLY EXCLUSIVE OPTIONS",		 '||
'    BICI.INCLUDE_IN_COST_ROLLUP		"INCLUDE IN COST ROLLUP",		 '||
'    BICI.CHECK_ATP				"CHECK ATP",				 '||
'    BICI.SHIPPING_ALLOWED			"SHIPPING ALLOWED",			 '||
'    BICI.REQUIRED_TO_SHIP			"REQUIRED TO SHIP",			 '||
'    BICI.REQUIRED_FOR_REVENUE			"REQUIRED FOR REVENUE",			 '||
'    BICI.INCLUDE_ON_SHIP_DOCS			"INCLUDE ON SHIP DOCS",			 '||
'    BICI.LOW_QUANTITY				"LOW QUANTITY",				 '||
'    BICI.HIGH_QUANTITY				"HIGH QUANTITY",			 '||
'    BICI.ACD_TYPE				"ACD TYPE",				 '||
'    BICI.OLD_COMPONENT_SEQUENCE_ID		"OLD COMPONENT SEQUENCE ID",		 '||
'    BICI.COMPONENT_SEQUENCE_ID			"COMPONENT SEQUENCE ID",		 '||
'    BICI.BILL_SEQUENCE_ID			"BILL SEQUENCE ID",			 '||
'    BICI.REQUEST_ID				"REQUEST ID",				 '||
'    BICI.PROGRAM_APPLICATION_ID		"PROGRAM APPLICATION ID",		 '||
'    BICI.PROGRAM_ID				"PROGRAM ID",				 '||
'    to_char(BICI.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "PROGRAM UPDATE DATE", '||
'    BICI.WIP_SUPPLY_TYPE			"WIP SUPPLY TYPE",			 '||
'    BICI.SUPPLY_SUBINVENTORY			"SUPPLY SUBINVENTORY",			 '||
'    BICI.SUPPLY_LOCATOR_ID			"SUPPLY LOCATOR ID",			 '||
'    BICI.REVISED_ITEM_SEQUENCE_ID		"REVISED ITEM SEQUENCE ID",		 '||
'    BICI.MODEL_COMP_SEQ_ID			"MODEL COMP SEQ ID",			 '||
'    BICI.ASSEMBLY_ITEM_ID			"ASSEMBLY ITEM ID",			 '||
'    BICI.ALTERNATE_BOM_DESIGNATOR		"ALTERNATE BOM DESIGNATOR",		 '||
'    BICI.ORGANIZATION_ID			"ORGANIZATION ID",			 '||
'    BICI.ORGANIZATION_CODE			"ORGANIZATION CODE",			 '||
'    BICI.COMPONENT_ITEM_NUMBER			"COMPONENT ITEM NUMBER",		 '||
'    BICI.ASSEMBLY_ITEM_NUMBER			"ASSEMBLY ITEM NUMBER",			 '||
'    BICI.REVISED_ITEM_NUMBER			"REVISED ITEM NUMBER",			 '||
'    BICI.LOCATION_NAME				"LOCATION NAME",			 '||
'    BICI.REFERENCE_DESIGNATOR			"REFERENCE DESIGNATOR",			 '||
'    BICI.SUBSTITUTE_COMP_ID			"SUBSTITUTE COMP ID",			 '||
'    BICI.SUBSTITUTE_COMP_NUMBER		"SUBSTITUTE COMP NUMBER",		 '||
'    BICI.TRANSACTION_ID			"TRANSACTION ID",			 '||
'    BICI.PROCESS_FLAG				"PROCESS FLAG",				 '||
'    BICI.BOM_ITEM_TYPE				"BOM ITEM TYPE",			 '||
'    BICI.OPERATION_LEAD_TIME_PERCENT		"OPERATION LEAD TIME PERCENT",		 '||
'    BICI.COST_FACTOR				"COST FACTOR",				 '||
'    BICI.INCLUDE_ON_BILL_DOCS			"INCLUDE ON BILL DOCS",			 '||
'    BICI.PICK_COMPONENTS			"PICK COMPONENTS",			 '||
'    BICI.DDF_CONTEXT1				"DDF CONTEXT1",				 '||
'    BICI.DDF_CONTEXT2				"DDF CONTEXT2",				 '||
'    BICI.NEW_OPERATION_SEQ_NUM			"NEW OPERATION SEQ NUM",		 '||
'    BICI.OLD_OPERATION_SEQ_NUM			"OLD OPERATION SEQ NUM",		 '||
'    to_char(BICI.NEW_EFFECTIVITY_DATE,''DD-MON-YYYY HH24:MI:SS'') "NEW EFFECTIVITY DATE", '||
'    to_char(BICI.OLD_EFFECTIVITY_DATE,''DD-MON-YYYY HH24:MI:SS'') "OLD EFFECTIVITY DATE", '||
'    BICI.ASSEMBLY_TYPE				"ASSEMBLY TYPE",			 '||
'    BICI.INTERFACE_ENTITY_TYPE			"INTERFACE ENTITY TYPE"		 '||
'    from   bom_inventory_comps_interface bici  where 1=1		           ';

sqltxt :=sqltxt||' and rownum <   '||row_limit;
sqltxt :=sqltxt||' order by   bici.operation_seq_num, bici.component_item_id';

   num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Records in bom_inventory_comps_interface table ');
   If (num_rows = row_limit -1 ) Then
	JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
   End If;
   statusStr := 'SUCCESS';
   isFatal := 'FALSE';


   sqltxt := 'SELECT ' ||
'    BICI.OPERATION_SEQ_NUM			"OPERATION SEQ NUM",			 '||
'    BICI.COMPONENT_ITEM_ID			"COMPONENT ITEM ID",			 '||
'    BICI.TRANSACTION_TYPE			"TRANSACTION TYPE",			 '||
'    BICI.BOM_INVENTORY_COMPS_IFCE_KEY		"BOM INVENTORY COMPS IFCE KEY",		 '||
'    BICI.ENG_REVISED_ITEMS_IFCE_KEY		"ENG REVISED ITEMS IFCE KEY",		 '||
'    BICI.ENG_CHANGES_IFCE_KEY			"ENG CHANGES IFCE KEY",			 '||
'    BICI.TO_END_ITEM_UNIT_NUMBER		"TO END ITEM UNIT NUMBER",		 '||
'    BICI.FROM_END_ITEM_UNIT_NUMBER		"FROM END ITEM UNIT NUMBER",		 '||
'    BICI.NEW_FROM_END_ITEM_UNIT_NUMBER		"NEW FROM END ITEM UNIT NUMBER",	 '||
'    BICI.DELETE_GROUP_NAME			"DELETE GROUP NAME",			 '||
'    BICI.DG_DESCRIPTION			"DG DESCRIPTION",			 '||
'    BICI.ORIGINAL_SYSTEM_REFERENCE		"ORIGINAL SYSTEM REFERENCE",		 '||
'    BICI.ENFORCE_INT_REQUIREMENTS		"ENFORCE INT REQUIREMENTS",		 '||
'    BICI.OPTIONAL_ON_MODEL			"OPTIONAL ON MODEL",			 '||
'    BICI.PARENT_BILL_SEQ_ID			"PARENT BILL SEQ ID",			 '||
'    BICI.PLAN_LEVEL				"PLAN LEVEL",				 '||
'    BICI.AUTO_REQUEST_MATERIAL			"AUTO REQUEST MATERIAL"			 '||
'    ,BICI.SUGGESTED_VENDOR_NAME		"SUGGESTED VENDOR NAME"			 '||
'    ,BICI.UNIT_PRICE				"UNIT PRICE"				 '||
'    ,BICI.NEW_REVISED_ITEM_REVISION		"NEW REVISED ITEM REVISION",		 '||
'    BICI.BASIS_TYPE					"BASIS TYPE",			 '||
'    BICI.INVERSE_QUANTITY			"INVERSE QUANTITY",			 '||
'    BICI.OBJ_NAME					"OBJ NAME",			 '||
'    BICI.PK1_VALUE					"PK1 VALUE",			 '||
'    BICI.PK2_VALUE					"PK2 VALUE",			 '||
'    BICI.PK3_VALUE					"PK3 VALUE",			 '||
'    BICI.PK4_VALUE					"PK4 VALUE",			 '||
'    BICI.PK5_VALUE					"PK5 VALUE",			 '||
'    BICI.FROM_OBJECT_REVISION_CODE				"FROM OBJECT REVISION CODE",			 '||
'    BICI.FROM_OBJECT_REVISION_ID				"FROM OBJECT REVISION ID",			 '||
'    BICI.TO_OBJECT_REVISION_CODE				"TO OBJECT REVISION CODE",			 '||
'    BICI.TO_OBJECT_REVISION_ID					"TO OBJECT REVISION ID",			 '||
'    BICI.FROM_MINOR_REVISION_CODE				"FROM MINOR REVISION CODE",			 '||
'    BICI.FROM_MINOR_REVISION_ID				"FROM MINOR REVISION ID",			 '||
'    BICI.TO_MINOR_REVISION_CODE				"TO MINOR REVISION CODE",			 '||
'    BICI.TO_MINOR_REVISION_ID					"TO MINOR REVISION ID",			 '||
'    BICI.FROM_END_ITEM_MINOR_REV_CODE			"FROM END ITEM MINOR REV CODE",			 '||
'    BICI.FROM_END_ITEM_MINOR_REV_ID			"FROM END ITEM MINOR REV ID",			 '||
'    BICI.TO_END_ITEM_MINOR_REV_CODE			"TO END ITEM MINOR REV CODE",			 '||
'    BICI.TO_END_ITEM_MINOR_REV_ID				"TO END ITEM MINOR REV ID",			 '||
'    BICI.RETURN_STATUS							"RETURN STATUS",			 '||
'    BICI.FROM_END_ITEM	 						"FROM END ITEM",			 '||
'    BICI.FROM_END_ITEM_ID 						"FROM END ITEM ID",			 '||
'    BICI.FROM_END_ITEM_REV_CODE				"FROM END ITEM REV CODE",			 '||
'    BICI.FROM_END_ITEM_REV_ID					"FROM END ITEM REV ID",			 '||
'    BICI.TO_END_ITEM_REV_CODE					"TO END ITEM REV CODE",			 '||
'    BICI.TO_END_ITEM_REV_ID					"TO END ITEM REV ID",			 '||
'    BICI.COMPONENT_REVISION_CODE				"COMPONENT REVISION CODE",			 '||
'    BICI.COMPONENT_REVISION_ID	 				"COMPONENT REVISION ID",			 '||
'    BICI.BATCH_ID				 				"BATCH ID",			 '||
'    BICI.COMP_SOURCE_SYSTEM_REFERENCE			"COMP SOURCE SYSTEM REFERENCE",			 '||
'    BICI.COMP_SOURCE_SYSTEM_REFER_DESC		"COMP SOURCE SYSTEM REFER DESC",			 '||
'    BICI.PARENT_SOURCE_SYSTEM_REFERENCE		"PARENT SOURCE SYSTEM REFERENCE",			 '||
'    BICI.CATALOG_CATEGORY_NAME				"CATALOG CATEGORY NAME",			 '||
'    BICI.ITEM_CATALOG_GROUP_ID					"ITEM CATALOG GROUP ID",			 '||
'    BICI.CHANGE_ID								"CHANGE ID",			 '||
'    BICI.TEMPLATE_NAME							"TEMPLATE NAME",			 '||
'    BICI.PRIMARY_UNIT_OF_MEASURE				"PRIMARY UNIT OF MEASURE",			 '||
'    BICI.ITEM_DESCRIPTION						"ITEM DESCRIPTION",			 '||
'    BICI.COMMON_COMPONENT_SEQUENCE_ID		"COMMON COMPONENT SEQUENCE ID",			 '||
'    BICI.CHANGE_TRANSACTION_TYPE				"CHANGE TRANSACTION TYPE",			 '||
'    BICI.INTERFACE_TABLE_UNIQUE_ID				"INTERFACE TABLE UNIQUE ID",			 '||
'    BICI.PARENT_REVISION_CODE					"PARENT REVISION CODE",			 '||
'    BICI.PARENT_REVISION_ID	 					"PARENT REVISION ID"			 '||
'    from   bom_inventory_comps_interface bici  where 1=1		           ';

sqltxt :=sqltxt||' and rownum <   '||row_limit;
sqltxt :=sqltxt||' order by   bici.operation_seq_num, bici.component_item_id';

   num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Records in bom_inventory_comps_interface table (Contd 1..) ');
   If (num_rows = row_limit -1 ) Then
	JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
   End If;
   statusStr := 'SUCCESS';
   isFatal := 'FALSE';


 /* End of bom_inventory_comps_interface */

  /* SQL to fetch records from bom_ref_desgs_interface table */
sqltxt := 'SELECT ' ||
'    BRDI.COMPONENT_REFERENCE_DESIGNATOR	"COMPONENT REFERENCE DESIGNATOR",	  '||
'    to_char(BRDI.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'')	"LAST UPDATE DATE",	'||
'    BRDI.LAST_UPDATED_BY			"LAST UPDATED BY",			  '||
'    to_char(BRDI.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'')	"CREATION DATE",	  '||
'    BRDI.CREATED_BY				"CREATED BY",				  '||
'    BRDI.LAST_UPDATE_LOGIN			"LAST UPDATE LOGIN",			  '||
'    BRDI.REF_DESIGNATOR_COMMENT		"REF DESIGNATOR COMMENT",		  '||
'    BRDI.CHANGE_NOTICE				"CHANGE NOTICE",			  '||
'    BRDI.COMPONENT_SEQUENCE_ID			"COMPONENT SEQUENCE ID",		  '||
'    BRDI.ACD_TYPE				"ACD TYPE",				  '||
'    BRDI.REQUEST_ID				"REQUEST ID",				  '||
'    BRDI.PROGRAM_APPLICATION_ID		"PROGRAM APPLICATION ID",		  '||
'    BRDI.PROGRAM_ID				"PROGRAM ID",				  '||
'    to_char(BRDI.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "PROGRAM UPDATE DATE",  '||
'    BRDI.ATTRIBUTE_CATEGORY			"ATTRIBUTE CATEGORY",			  '||
'    BRDI.ATTRIBUTE1				"ATTRIBUTE1",				  '||
'    BRDI.ATTRIBUTE2				"ATTRIBUTE2",				  '||
'    BRDI.ATTRIBUTE3				"ATTRIBUTE3",				  '||
'    BRDI.ATTRIBUTE4				"ATTRIBUTE4",				  '||
'    BRDI.ATTRIBUTE5				"ATTRIBUTE5",				  '||
'    BRDI.ATTRIBUTE6				"ATTRIBUTE6",				  '||
'    BRDI.ATTRIBUTE7				"ATTRIBUTE7",				  '||
'    BRDI.ATTRIBUTE8				"ATTRIBUTE8",				  '||
'    BRDI.ATTRIBUTE9				"ATTRIBUTE9",				  '||
'    BRDI.ATTRIBUTE10				"ATTRIBUTE10",				  '||
'    BRDI.ATTRIBUTE11				"ATTRIBUTE11",				  '||
'    BRDI.ATTRIBUTE12				"ATTRIBUTE12",				  '||
'    BRDI.ATTRIBUTE13				"ATTRIBUTE13",				  '||
'    BRDI.ATTRIBUTE14				"ATTRIBUTE14",				  '||
'    BRDI.ATTRIBUTE15				"ATTRIBUTE15",				  '||
'    BRDI.BILL_SEQUENCE_ID			"BILL SEQUENCE ID",			  '||
'    BRDI.ASSEMBLY_ITEM_ID			"ASSEMBLY ITEM ID",			  '||
'    BRDI.ALTERNATE_BOM_DESIGNATOR		"ALTERNATE BOM DESIGNATOR",		  '||
'    BRDI.ORGANIZATION_ID			"ORGANIZATION ID",			  '||
'    BRDI.COMPONENT_ITEM_ID			"COMPONENT ITEM ID",			  '||
'    BRDI.OPERATION_SEQ_NUM			"OPERATION SEQ NUM",			  '||
'    to_char(BRDI.EFFECTIVITY_DATE,''DD-MON-YYYY HH24:MI:SS'')	"EFFECTIVITY DATE",	  '||
'    BRDI.ORGANIZATION_CODE			"ORGANIZATION CODE",			  '||
'    BRDI.ASSEMBLY_ITEM_NUMBER			"ASSEMBLY ITEM NUMBER",			  '||
'    BRDI.COMPONENT_ITEM_NUMBER			"COMPONENT ITEM NUMBER",		  '||
'    BRDI.TRANSACTION_ID			"TRANSACTION ID",			  '||
'    BRDI.PROCESS_FLAG				"PROCESS FLAG",				  '||
'    BRDI.NEW_DESIGNATOR			"NEW DESIGNATOR",			  '||
'    BRDI.INTERFACE_ENTITY_TYPE			"INTERFACE ENTITY TYPE",		  '||
'    BRDI.TRANSACTION_TYPE			"TRANSACTION TYPE",			  '||
'    BRDI.BOM_REF_DESGS_IFCE_KEY		"BOM REF DESGS IFCE KEY",		  '||
'    BRDI.BOM_INVENTORY_COMPS_IFCE_KEY		"BOM INVENTORY COMPS IFCE KEY",		  '||
'    BRDI.ENG_REVISED_ITEMS_IFCE_KEY		"ENG REVISED ITEMS IFCE KEY",		  '||
'    BRDI.ENG_CHANGES_IFCE_KEY			"ENG CHANGES IFCE KEY",			  '||
'    BRDI.FROM_END_ITEM_UNIT_NUMBER		"FROM END ITEM UNIT NUMBER",		  '||
'    BRDI.ORIGINAL_SYSTEM_REFERENCE		"ORIGINAL SYSTEM REFERENCE"		  '||
'    ,BRDI.NEW_REVISED_ITEM_REVISION		"NEW REVISED ITEM REVISION"		  '||
'    ,BRDI.RETURN_STATUS				"RETURN STATUS"		  '||
'    ,BRDI.BATCH_ID						"BATCH ID"		  '||
'    ,BRDI.COMP_SOURCE_SYSTEM_REFERENCE	"COMP SOURCE SYSTEM REFERENCE"		  '||
'    ,BRDI.PARENT_SOURCE_SYSTEM_REFERENCE	"PARENT SOURCE SYSTEM REFERENCE"		  '||
'    ,BRDI.CHANGE_ID				"CHANGE ID"		  '||
'    ,BRDI.CHANGE_TRANSACTION_TYPE		"CHANGE TRANSACTION TYPE"		  '||
'    ,BRDI.INTERFACE_TABLE_UNIQUE_ID		"INTERFACE TABLE UNIQUE ID"		  '||
'    ,BRDI.ASSEMBLY_ITEM_REVISION_CODE	"ASSEMBLY ITEM REVISION CODE"		  '||
'    ,BRDI.ASSEMBLY_ITEM_REVISION_ID		"ASSEMBLY ITEM REVISION ID"		  '||
'    from   bom_ref_desgs_interface brdi	where 1=1				  ';

sqltxt :=sqltxt||' and rownum <   '||row_limit;
sqltxt :=sqltxt||' order by   brdi.component_reference_designator	';

   num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Records in  bom_ref_desgs_interface table ');
   If (num_rows = row_limit -1 ) Then
	JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
   End If;
   statusStr := 'SUCCESS';
   isFatal := 'FALSE';
   /* End of bom_ref_desgs_interface */

  /* SQL to fetch records frombom_sub_comps_interface table */
sqltxt := 'SELECT ' ||
'    BSCI.SUBSTITUTE_COMPONENT_ID		  "SUBSTITUTE COMPONENT ID",		   '||
'    to_char(BSCI.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'')	"LAST UPDATE DATE",	   '||
'    BSCI.LAST_UPDATED_BY			  "LAST UPDATED BY",			   '||
'    to_char(BSCI.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'') "CREATION DATE",		'||
'    BSCI.CREATED_BY				  "CREATED BY",				   '||
'    BSCI.LAST_UPDATE_LOGIN			  "LAST UPDATE LOGIN",			   '||
'    BSCI.SUBSTITUTE_ITEM_QUANTITY		  "SUBSTITUTE ITEM QUANTITY",		   '||
'    BSCI.COMPONENT_SEQUENCE_ID			  "COMPONENT SEQUENCE ID",		   '||
'    BSCI.ACD_TYPE				  "ACD TYPE",				   '||
'    BSCI.CHANGE_NOTICE				  "CHANGE NOTICE",			   '||
'    BSCI.REQUEST_ID				  "REQUEST ID",				   '||
'    BSCI.PROGRAM_APPLICATION_ID		  "PROGRAM APPLICATION ID",		   '||
'    BSCI.PROGRAM_ID				  "PROGRAM ID",				   '||
'    to_char(BSCI.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'')  "PROGRAM UPDATE DATE",  '||
'    BSCI.ATTRIBUTE_CATEGORY			  "ATTRIBUTE CATEGORY",			   '||
'    BSCI.ATTRIBUTE1				  "ATTRIBUTE1",				   '||
'    BSCI.ATTRIBUTE2				  "ATTRIBUTE2",				   '||
'    BSCI.ATTRIBUTE3				  "ATTRIBUTE3",				   '||
'    BSCI.ATTRIBUTE4				  "ATTRIBUTE4",				   '||
'    BSCI.ATTRIBUTE5				  "ATTRIBUTE5",				   '||
'    BSCI.ATTRIBUTE6				  "ATTRIBUTE6",				   '||
'    BSCI.ATTRIBUTE7				  "ATTRIBUTE7",				   '||
'    BSCI.ATTRIBUTE8				  "ATTRIBUTE8",				   '||
'    BSCI.ATTRIBUTE9				  "ATTRIBUTE9",				   '||
'    BSCI.ATTRIBUTE10				  "ATTRIBUTE10",			   '||
'    BSCI.ATTRIBUTE11				  "ATTRIBUTE11",			   '||
'    BSCI.ATTRIBUTE12				  "ATTRIBUTE12",			   '||
'    BSCI.ATTRIBUTE13				  "ATTRIBUTE13",			   '||
'    BSCI.ATTRIBUTE14				  "ATTRIBUTE14",			   '||
'    BSCI.ATTRIBUTE15				  "ATTRIBUTE15",			   '||
'    BSCI.BILL_SEQUENCE_ID			  "BILL SEQUENCE ID",			   '||
'    BSCI.ASSEMBLY_ITEM_ID			  "ASSEMBLY ITEM ID",			   '||
'    BSCI.ALTERNATE_BOM_DESIGNATOR		  "ALTERNATE BOM DESIGNATOR",		   '||
'    BSCI.ORGANIZATION_ID			  "ORGANIZATION ID",			   '||
'    BSCI.COMPONENT_ITEM_ID			  "COMPONENT ITEM ID",			   '||
'    BSCI.OPERATION_SEQ_NUM			  "OPERATION SEQ NUM",			   '||
'    to_char(BSCI.EFFECTIVITY_DATE,''DD-MON-YYYY HH24:MI:SS'') "EFFECTIVITY DATE",	   '||
'    BSCI.TRANSACTION_ID			  "TRANSACTION ID",			   '||
'    BSCI.PROCESS_FLAG				  "PROCESS FLAG",			   '||
'    BSCI.ORGANIZATION_CODE			  "ORGANIZATION CODE",			   '||
'    BSCI.SUBSTITUTE_COMP_NUMBER		  "SUBSTITUTE COMP NUMBER",		   '||
'    BSCI.COMPONENT_ITEM_NUMBER			  "COMPONENT ITEM NUMBER",		   '||
'    BSCI.ASSEMBLY_ITEM_NUMBER			  "ASSEMBLY ITEM NUMBER",		   '||
'    BSCI.NEW_SUB_COMP_ID			  "NEW SUB COMP ID",			   '||
'    BSCI.NEW_SUB_COMP_NUMBER			  "NEW SUB COMP NUMBER",		   '||
'    BSCI.INTERFACE_ENTITY_TYPE			  "INTERFACE ENTITY TYPE",		   '||
'    BSCI.TRANSACTION_TYPE			  "TRANSACTION TYPE",			   '||
'    BSCI.BOM_SUB_COMPS_IFCE_KEY		  "BOM SUB COMPS IFCE KEY",		   '||
'    BSCI.BOM_INVENTORY_COMPS_IFCE_KEY		  "BOM INVENTORY COMPS IFCE KEY",	   '||
'    BSCI.ENG_REVISED_ITEMS_IFCE_KEY		  "ENG REVISED ITEMS IFCE KEY",		   '||
'    BSCI.ENG_CHANGES_IFCE_KEY			  "ENG CHANGES IFCE KEY",		   '||
'    BSCI.FROM_END_ITEM_UNIT_NUMBER		  "FROM END ITEM UNIT NUMBER",		   '||
'    BSCI.ORIGINAL_SYSTEM_REFERENCE		  "ORIGINAL SYSTEM REFERENCE",		   '||
'    BSCI.ENFORCE_INT_REQUIREMENTS		  "ENFORCE INT REQUIREMENTS"		   '||
'    ,BSCI.NEW_REVISED_ITEM_REVISION		  "NEW REVISED ITEM REVISION"		   '||
'    ,BSCI.RETURN_STATUS					  "RETURN STATUS"		   '||
'    ,BSCI.BATCH_ID							  "BATCH ID"		   '||
'    ,BSCI.COMP_SOURCE_SYSTEM_REFERENCE	  "COMP SOURCE SYSTEM REFERENCE"		   '||
'    ,BSCI.PARENT_SOURCE_SYSTEM_REFERENCE	  "PARENT SOURCE SYSTEM REFERENCE"		   '||
'    ,BSCI.SUBCOM_SOURCE_SYSTEM_REFERENCE	  "SUBCOM SOURCE SYSTEM REFERENCE"		   '||
'    ,BSCI.CHANGE_ID			  "CHANGE ID"		   '||
'    ,BSCI.SUB_COMP_INVERSE_QUANTITY		  "SUB COMP INVERSE QUANTITY"		   '||
'    ,BSCI.CHANGE_TRANSACTION_TYPE			  "CHANGE TRANSACTION TYPE"		   '||
'    ,BSCI.INTERFACE_TABLE_UNIQUE_ID			  "INTERFACE TABLE UNIQUE ID"		   '||
'    ,BSCI.ASSEMBLY_ITEM_REVISION_CODE		  "ASSEMBLY ITEM REVISION CODE"		   '||
'    ,BSCI.ASSEMBLY_ITEM_REVISION_ID			  "ASSEMBLY ITEM REVISION ID"		   '||
'    from   bom_sub_comps_interface bsci	  where 1=1				  ';

sqltxt :=sqltxt||' and rownum <   '||row_limit;
sqltxt :=sqltxt||' order by  bsci.substitute_component_id	';

   num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Records in bom_sub_comps_interface table ');
   If (num_rows = row_limit -1 ) Then
	JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
   End If;
   statusStr := 'SUCCESS';
   isFatal := 'FALSE';
  /* End of bom_sub_comps_interface */

 /* SQL to fetch records from bom_component_ops_interface  table */
sqltxt := 'SELECT ' ||
'    BCOI.COMP_OPERATION_SEQ_ID			"COMP OPERATION SEQ ID",	     '||
'    BCOI.OPERATION_SEQ_NUM			"OPERATION SEQ NUM",		     '||
'    BCOI.ADDITIONAL_OPERATION_SEQ_NUM		"ADDITIONAL OPERATION SEQ NUM",	     '||
'    BCOI.NEW_ADDITIONAL_OP_SEQ_NUM		"NEW ADDITIONAL OP SEQ NUM",	     '||
'    BCOI.OPERATION_SEQUENCE_ID			"OPERATION SEQUENCE ID",	     '||
'    to_char(BCOI.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'')	"LAST UPDATE DATE",  '||
'    BCOI.LAST_UPDATED_BY			"LAST UPDATED BY",		     '||
'    to_char(BCOI.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'') "CREATION DATE",	     '||
'    BCOI.CREATED_BY				"CREATED BY",			     '||
'    BCOI.LAST_UPDATE_LOGIN			"LAST UPDATE LOGIN",		     '||
'    BCOI.REQUEST_ID				"REQUEST ID",			     '||
'    to_char(BCOI.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "PROGRAM UPDATE DATE", '||
'    BCOI.PROGRAM_ID				"PROGRAM ID",			     '||
'    BCOI.PROGRAM_APPLICATION_ID		"PROGRAM APPLICATION ID",	     '||
'    BCOI.COMPONENT_SEQUENCE_ID			"COMPONENT SEQUENCE ID",	     '||
'    BCOI.BILL_SEQUENCE_ID			"BILL SEQUENCE ID",		     '||
'    BCOI.CONSUMING_OPERATION_FLAG		"CONSUMING OPERATION FLAG",	     '||
'    BCOI.CONSUMPTION_QUANTITY			"CONSUMPTION QUANTITY",		     '||
'    BCOI.SUPPLY_SUBINVENTORY			"SUPPLY SUBINVENTORY",		     '||
'    BCOI.SUPPLY_LOCATOR_ID			"SUPPLY LOCATOR ID",		     '||
'    BCOI.WIP_SUPPLY_TYPE			"WIP SUPPLY TYPE",		     '||
'    BCOI.ATTRIBUTE_CATEGORY			"ATTRIBUTE CATEGORY",		     '||
'    BCOI.ATTRIBUTE1				"ATTRIBUTE1",			     '||
'    BCOI.ATTRIBUTE2				"ATTRIBUTE2",			     '||
'    BCOI.ATTRIBUTE3				"ATTRIBUTE3",			     '||
'    BCOI.ATTRIBUTE4				"ATTRIBUTE4",			     '||
'    BCOI.ATTRIBUTE5				"ATTRIBUTE5",			     '||
'    BCOI.ATTRIBUTE6				"ATTRIBUTE6",			     '||
'    BCOI.ATTRIBUTE7				"ATTRIBUTE7",			     '||
'    BCOI.ATTRIBUTE8				"ATTRIBUTE8",			     '||
'    BCOI.ATTRIBUTE9				"ATTRIBUTE9",			     '||
'    BCOI.ATTRIBUTE10				"ATTRIBUTE10",			     '||
'    BCOI.ATTRIBUTE11				"ATTRIBUTE11",			     '||
'    BCOI.ATTRIBUTE12				"ATTRIBUTE12",			     '||
'    BCOI.ATTRIBUTE13				"ATTRIBUTE13",			     '||
'    BCOI.ATTRIBUTE14				"ATTRIBUTE14",			     '||
'    BCOI.ATTRIBUTE15				"ATTRIBUTE15",			     '||
'    BCOI.ASSEMBLY_ITEM_ID			"ASSEMBLY ITEM ID",		     '||
'    BCOI.ASSEMBLY_ITEM_NUMBER			"ASSEMBLY ITEM NUMBER",		     '||
'    BCOI.ALTERNATE_BOM_DESIGNATOR		"ALTERNATE BOM DESIGNATOR",	     '||
'    BCOI.ORGANIZATION_ID			"ORGANIZATION ID",		     '||
'    BCOI.ORGANIZATION_CODE			"ORGANIZATION CODE",		     '||
'    BCOI.COMPONENT_ITEM_ID			"COMPONENT ITEM ID",		     '||
'    BCOI.COMPONENT_ITEM_NUMBER			"COMPONENT ITEM NUMBER",	     '||
'    to_char(BCOI.EFFECTIVITY_DATE,''DD-MON-YYYY HH24:MI:SS'')	"EFFECTIVITY DATE",  '||
'    BCOI.FROM_END_ITEM_UNIT_NUMBER		"FROM END ITEM UNIT NUMBER",	     '||
'    BCOI.TO_END_ITEM_UNIT_NUMBER		"TO END ITEM UNIT NUMBER",	     '||
'    BCOI.ORIGINAL_SYSTEM_REFERENCE		"ORIGINAL SYSTEM REFERENCE",	     '||
'    BCOI.TRANSACTION_ID			"TRANSACTION ID",		     '||
'    BCOI.PROCESS_FLAG				"PROCESS FLAG",			     '||
'    BCOI.TRANSACTION_TYPE			"TRANSACTION TYPE",		     '||
'    BCOI.RETURN_STATUS	 			"RETURN STATUS",		     '||
'    BCOI.BATCH_ID		 			"BATCH ID",		     '||
'    BCOI.COMP_SOURCE_SYSTEM_REFERENCE	"COMP SOURCE SYSTEM REFERENCE",		     '||
'    BCOI.PARENT_SOURCE_SYSTEM_REFERENCE	"PARENT SOURCE SYSTEM REFERENCE",		     '||
'    BCOI.ASSEMBLY_ITEM_REVISION_CODE		"ASSEMBLY ITEM REVISION CODE",		     '||
'    BCOI.ASSEMBLY_ITEM_REVISION_ID			"ASSEMBLY ITEM REVISION ID"		     '||
'    from  bom_component_ops_interface bcoi	  where 1=1			     ';

sqltxt :=sqltxt||' and rownum <   '||row_limit;
sqltxt :=sqltxt||' order by bcoi.comp_operation_seq_id	';

   num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Records in bom_component_ops_interface table ');
   If (num_rows = row_limit -1 ) Then
	JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
   End If;
   statusStr := 'SUCCESS';
   isFatal := 'FALSE';
  /* End of bom_component_ops_interface  */

End If; /* End of tables common to bom and eng */


If upper(l_type) in ('RTG','ENG') Then
/* Fetch tables common to rtg and eng */

/* Get the application installation info. References to Data Dictionary Objects without schema name
included in WHERE predicate are not allowed (GSCC Check: file.sql.47). Schema name has to be passed
as an input parameter to JTF_DIAGNOSTIC_COREAPI.Column_Exists API. */

l_ret_status :=      fnd_installation.get_app_info ('BOM'
                                   , l_status
                                   , l_industry
                                   , l_oracle_schema
                                    );

/*JTF_DIAGNOSTIC_COREAPI.Line_Out(' l_oracle_schema: '||l_oracle_schema);*/

  /* SQL to fetch records from bom_op_sequences_interface table */
sqltxt := 'SELECT ' ||
'    BOSI.OPERATION_SEQUENCE_ID		       "OPERATION SEQUENCE ID",		      '||
'    BOSI.ROUTING_SEQUENCE_ID		       "ROUTING SEQUENCE ID",		      '||
'    BOSI.OPERATION_SEQ_NUM		       "OPERATION SEQ NUM",		      '||
'    to_char(BOSI.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "LAST UPDATE DATE", '||
'    BOSI.LAST_UPDATED_BY		       "LAST UPDATED BY",		      '||
'    to_char(BOSI.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'')  "CREATION DATE",		'||
'    BOSI.CREATED_BY			       "CREATED BY",			      '||
'    BOSI.LAST_UPDATE_LOGIN		       "LAST UPDATE LOGIN",		      '||
'    BOSI.STANDARD_OPERATION_ID		       "STANDARD OPERATION ID",		      '||
'    BOSI.DEPARTMENT_ID			       "DEPARTMENT ID",			      '||
'    BOSI.OPERATION_LEAD_TIME_PERCENT	       "OPERATION LEAD TIME PERCENT",	      '||
'    BOSI.RUN_TIME_OVERLAP_PERCENT	       "RUN TIME OVERLAP PERCENT",	      '||
'    BOSI.MINIMUM_TRANSFER_QUANTITY	       "MINIMUM TRANSFER QUANTITY",	      '||
'    BOSI.COUNT_POINT_TYPE		       "COUNT POINT TYPE",		      '||
'    BOSI.OPERATION_DESCRIPTION		       "OPERATION DESCRIPTION",		      '||
'    to_char(BOSI.EFFECTIVITY_DATE,''DD-MON-YYYY HH24:MI:SS'') "EFFECTIVITY DATE",	'||
'    BOSI.CHANGE_NOTICE			       "CHANGE NOTICE",			      '||
'    to_char(BOSI.IMPLEMENTATION_DATE,''DD-MON-YYYY HH24:MI:SS'') "IMPLEMENTATION DATE", '||
'    to_char(BOSI.DISABLE_DATE,''DD-MON-YYYY HH24:MI:SS'')	"DISABLE DATE",		'||
'    BOSI.BACKFLUSH_FLAG		       "BACKFLUSH FLAG",		      '||
'    BOSI.OPTION_DEPENDENT_FLAG		       "OPTION DEPENDENT FLAG",		      '||
'    BOSI.ATTRIBUTE_CATEGORY		       "ATTRIBUTE CATEGORY",		      '||
'    BOSI.ATTRIBUTE1			       "ATTRIBUTE1",			      '||
'    BOSI.ATTRIBUTE2			       "ATTRIBUTE2",			      '||
'    BOSI.ATTRIBUTE3			       "ATTRIBUTE3",			      '||
'    BOSI.ATTRIBUTE4			       "ATTRIBUTE4",			      '||
'    BOSI.ATTRIBUTE5			       "ATTRIBUTE5",			      '||
'    BOSI.ATTRIBUTE6			       "ATTRIBUTE6",			      '||
'    BOSI.ATTRIBUTE7			       "ATTRIBUTE7",			      '||
'    BOSI.ATTRIBUTE8			       "ATTRIBUTE8",			      '||
'    BOSI.ATTRIBUTE9			       "ATTRIBUTE9",			      '||
'    BOSI.ATTRIBUTE10			       "ATTRIBUTE10",			      '||
'    BOSI.ATTRIBUTE11			       "ATTRIBUTE11",			      '||
'    BOSI.ATTRIBUTE12			       "ATTRIBUTE12",			      '||
'    BOSI.ATTRIBUTE13			       "ATTRIBUTE13",			      '||
'    BOSI.ATTRIBUTE14			       "ATTRIBUTE14",			      '||
'    BOSI.ATTRIBUTE15			       "ATTRIBUTE15",			      '||
'    BOSI.REQUEST_ID			       "REQUEST ID",			      '||
'    BOSI.PROGRAM_APPLICATION_ID	       "PROGRAM APPLICATION ID",	      '||
'    BOSI.PROGRAM_ID			       "PROGRAM ID",			      '||
'    to_char(BOSI.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'')  "PROGRAM UPDATE DATE", '||
'    BOSI.MODEL_OP_SEQ_ID		       "MODEL OP SEQ ID",		      '||
'    BOSI.ASSEMBLY_ITEM_ID		       "ASSEMBLY ITEM ID",		      '||
'    BOSI.ORGANIZATION_ID		       "ORGANIZATION ID",		      '||
'    BOSI.ALTERNATE_ROUTING_DESIGNATOR	       "ALTERNATE ROUTING DESIGNATOR",	      '||
'    BOSI.ORGANIZATION_CODE		       "ORGANIZATION CODE",		      '||
'    BOSI.ASSEMBLY_ITEM_NUMBER		       "ASSEMBLY ITEM NUMBER",		      '||
'    BOSI.DEPARTMENT_CODE		       "DEPARTMENT CODE",		      '||
'    BOSI.OPERATION_CODE		       "OPERATION CODE",		      '||
'    BOSI.RESOURCE_ID1			       "RESOURCE ID1",			      '||
'    BOSI.RESOURCE_ID2			       "RESOURCE ID2",			      '||
'    BOSI.RESOURCE_ID3			       "RESOURCE ID3",			      '||
'    BOSI.RESOURCE_CODE1		       "RESOURCE CODE1",		      '||
'    BOSI.RESOURCE_CODE2		       "RESOURCE CODE2",		      '||
'    BOSI.RESOURCE_CODE3		       "RESOURCE CODE3",		      '||
'    BOSI.INSTRUCTION_CODE1		       "INSTRUCTION CODE1",		      '||
'    BOSI.INSTRUCTION_CODE2		       "INSTRUCTION CODE2",		      '||
'    BOSI.INSTRUCTION_CODE3		       "INSTRUCTION CODE3",		      '||
'    BOSI.TRANSACTION_ID		       "TRANSACTION ID",		      '||
'    BOSI.PROCESS_FLAG			       "PROCESS FLAG",			      '||
'    BOSI.TRANSACTION_TYPE		       "TRANSACTION TYPE",		      '||
'    BOSI.NEW_OPERATION_SEQ_NUM		       "NEW OPERATION SEQ NUM",		      '||
'    to_char(BOSI.NEW_EFFECTIVITY_DATE,''DD-MON-YYYY HH24:MI:SS'') "NEW EFFECTIVITY DATE", '||
'    BOSI.ASSEMBLY_TYPE			       "ASSEMBLY TYPE",			      '||
'    BOSI.OPERATION_TYPE		       "OPERATION TYPE",		      '||
'    BOSI.REFERENCE_FLAG		       "REFERENCE FLAG",		      '||
'    BOSI.PROCESS_OP_SEQ_ID		       "PROCESS OP SEQ ID",		      '||
'    BOSI.LINE_OP_SEQ_ID		       "LINE OP SEQ ID",		      '||
'    BOSI.YIELD				       "YIELD",				      '||
'    BOSI.CUMULATIVE_YIELD		       "CUMULATIVE YIELD",		      '||
'    BOSI.REVERSE_CUMULATIVE_YIELD	       "REVERSE CUMULATIVE YIELD",	      '||
'    BOSI.LABOR_TIME_CALC		       "LABOR TIME CALC",		      '||
'    BOSI.MACHINE_TIME_CALC		       "MACHINE TIME CALC",		      '||
'    BOSI.TOTAL_TIME_CALC		       "TOTAL TIME CALC",		      '||
'    BOSI.LABOR_TIME_USER		       "LABOR TIME USER",		      '||
'    BOSI.MACHINE_TIME_USER		       "MACHINE TIME USER",		      '||
'    BOSI.TOTAL_TIME_USER		       "TOTAL TIME USER",		      '||
'    BOSI.NET_PLANNING_PERCENT		       "NET PLANNING PERCENT",		      '||
'    BOSI.INCLUDE_IN_ROLLUP		       "INCLUDE IN ROLLUP",		      '||
'    BOSI.OPERATION_YIELD_ENABLED	       "OPERATION YIELD ENABLED",	      '||
'    BOSI.PROCESS_SEQ_NUMBER		       "PROCESS SEQ NUMBER",		      '||
'    BOSI.PROCESS_CODE			       "PROCESS CODE",			      '||
'    BOSI.LINE_OP_SEQ_NUMBER		       "LINE OP SEQ NUMBER",		      '||
'    BOSI.LINE_OP_CODE			       "LINE OP CODE",			      '||
'    BOSI.ORIGINAL_SYSTEM_REFERENCE	       "ORIGINAL SYSTEM REFERENCE",	      '||
'    BOSI.SHUTDOWN_TYPE			       "SHUTDOWN TYPE",			      '||
'    BOSI.LONG_DESCRIPTION		       "LONG DESCRIPTION",		      '||
'    BOSI.DELETE_GROUP_NAME		       "DELETE GROUP NAME",		      '||
'    BOSI.DG_DESCRIPTION		       "DG DESCRIPTION",		      '||
'    BOSI.NEW_ROUTING_REVISION		       "NEW ROUTING REVISION",		      '||
'    BOSI.ACD_TYPE			       "ACD TYPE",			      '||
'    to_char(BOSI.OLD_START_EFFECTIVE_DATE,''DD-MON-YYYY HH24:MI:SS'') "OLD START EFFECTIVE DATE", '||
'    BOSI.CANCEL_COMMENTS		       "CANCEL COMMENTS",		      '||
'    BOSI.ENG_CHANGES_IFCE_KEY		       "ENG CHANGES IFCE KEY",		      '||
'    BOSI.ENG_REVISED_ITEMS_IFCE_KEY	       "ENG REVISED ITEMS IFCE KEY",	      '||
'    BOSI.BOM_REV_OP_IFCE_KEY		       "BOM REV OP IFCE KEY"		      '||
'    ,BOSI.NEW_REVISED_ITEM_REVISION	       "NEW REVISED ITEM REVISION"	      '||
'    ,BOSI.BATCH_ID				       "BATCH ID"	      '||
'    from  bom_op_sequences_interface bosi     where 1=1			      ';

sqltxt :=sqltxt||' and rownum <   '||row_limit;
sqltxt :=sqltxt||' order by  bosi.operation_sequence_id ';

   num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Records in bom_op_sequences_interface table ');
   If (num_rows = row_limit -1 ) Then
	JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
   End If;
   statusStr := 'SUCCESS';
   isFatal := 'FALSE';

  /* End of bom_op_sequences_interface  */

   /* SQL to fetch records from bom_op_resources_interface bori table */
sqltxt := 'SELECT ' ||
'    BORI.OPERATION_SEQUENCE_ID		       "OPERATION SEQUENCE ID",			'||
'    BORI.RESOURCE_SEQ_NUM		       "RESOURCE SEQ NUM",			'||
'    BORI.RESOURCE_ID			       "RESOURCE ID",				'||
'    BORI.ACTIVITY_ID			       "ACTIVITY ID",				'||
'    BORI.STANDARD_RATE_FLAG		       "STANDARD RATE FLAG",			'||
'    BORI.ASSIGNED_UNITS		       "ASSIGNED UNITS",			'||
'    BORI.USAGE_RATE_OR_AMOUNT		       "USAGE RATE OR AMOUNT",			'||
'    BORI.USAGE_RATE_OR_AMOUNT_INVERSE	       "USAGE RATE OR AMOUNT INVERSE",		'||
'    BORI.BASIS_TYPE			       "BASIS TYPE",				'||
'    BORI.SCHEDULE_FLAG			       "SCHEDULE FLAG",				'||
'    to_char(BORI.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "LAST UPDATE DATE",	'||
'    BORI.LAST_UPDATED_BY		       "LAST UPDATED BY",			'||
'    to_char(BORI.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'') "CREATION DATE",		'||
'    BORI.CREATED_BY			       "CREATED BY",				'||
'    BORI.LAST_UPDATE_LOGIN		       "LAST UPDATE LOGIN",			'||
'    BORI.RESOURCE_OFFSET_PERCENT	       "RESOURCE OFFSET PERCENT",		'||
'    BORI.AUTOCHARGE_TYPE		       "AUTOCHARGE TYPE",			'||
'    BORI.ATTRIBUTE_CATEGORY		       "ATTRIBUTE CATEGORY",			'||
'    BORI.ATTRIBUTE1			       "ATTRIBUTE1",				'||
'    BORI.ATTRIBUTE2			       "ATTRIBUTE2",				'||
'    BORI.ATTRIBUTE3			       "ATTRIBUTE3",				'||
'    BORI.ATTRIBUTE4			       "ATTRIBUTE4",				'||
'    BORI.ATTRIBUTE5			       "ATTRIBUTE5",				'||
'    BORI.ATTRIBUTE6			       "ATTRIBUTE6",				'||
'    BORI.ATTRIBUTE7			       "ATTRIBUTE7",				'||
'    BORI.ATTRIBUTE8			       "ATTRIBUTE8",				'||
'    BORI.ATTRIBUTE9			       "ATTRIBUTE9",				'||
'    BORI.ATTRIBUTE10			       "ATTRIBUTE10",				'||
'    BORI.ATTRIBUTE11			       "ATTRIBUTE11",				'||
'    BORI.ATTRIBUTE12			       "ATTRIBUTE12",				'||
'    BORI.ATTRIBUTE13			       "ATTRIBUTE13",				'||
'    BORI.ATTRIBUTE14			       "ATTRIBUTE14",				'||
'    BORI.ATTRIBUTE15			       "ATTRIBUTE15",				'||
'    BORI.REQUEST_ID			       "REQUEST ID",				'||
'    BORI.PROGRAM_APPLICATION_ID	       "PROGRAM APPLICATION ID",		'||
'    BORI.PROGRAM_ID			       "PROGRAM ID",				'||
'    to_char(BORI.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "PROGRAM UPDATE DATE",'||
'    BORI.ASSEMBLY_ITEM_ID		       "ASSEMBLY ITEM ID",			'||
'    BORI.ALTERNATE_ROUTING_DESIGNATOR	       "ALTERNATE ROUTING DESIGNATOR",		'||
'    BORI.ORGANIZATION_ID		       "ORGANIZATION ID",			'||
'    BORI.OPERATION_SEQ_NUM		       "OPERATION SEQ NUM",			'||
'    to_char(BORI.EFFECTIVITY_DATE,''DD-MON-YYYY HH24:MI:SS'') "EFFECTIVITY DATE",	'||
'    BORI.ROUTING_SEQUENCE_ID		       "ROUTING SEQUENCE ID",			'||
'    BORI.ORGANIZATION_CODE		       "ORGANIZATION CODE",			'||
'    BORI.ASSEMBLY_ITEM_NUMBER		       "ASSEMBLY ITEM NUMBER",			'||
'    BORI.RESOURCE_CODE			       "RESOURCE CODE",				'||
'    BORI.ACTIVITY			       "ACTIVITY",				'||
'    BORI.TRANSACTION_ID		       "TRANSACTION ID",			'||
'    BORI.PROCESS_FLAG			       "PROCESS FLAG",				'||
'    BORI.TRANSACTION_TYPE		       "TRANSACTION TYPE",			'||
'    BORI.NEW_RESOURCE_SEQ_NUM		       "NEW RESOURCE SEQ NUM",			'||
'    BORI.OPERATION_TYPE		       "OPERATION TYPE",			'||
'    BORI.PRINCIPLE_FLAG		       "PRINCIPLE FLAG",			'||
'    BORI.SCHEDULE_SEQ_NUM		       "SCHEDULE SEQ NUM",			'||
'    BORI.ORIGINAL_SYSTEM_REFERENCE	       "ORIGINAL SYSTEM REFERENCE",		'||
'    BORI.SETUP_CODE			       "SETUP CODE",				'||
'    BORI.ECO_NAME			       "ECO NAME",				'||
'    BORI.NEW_ROUTING_REVISION		       "NEW ROUTING REVISION",			'||
'    BORI.ACD_TYPE			       "ACD TYPE",				'||
'    BORI.ENG_CHANGES_IFCE_KEY		       "ENG CHANGES IFCE KEY",			'||
'    BORI.ENG_REVISED_ITEMS_IFCE_KEY	       "ENG REVISED ITEMS IFCE KEY",		'||
'    BORI.BOM_REV_OP_IFCE_KEY		       "BOM REV OP IFCE KEY",			'||
'    BORI.BOM_REV_OP_RES_IFCE_KEY	       "BOM REV OP RES IFCE KEY"		'||
'    ,BORI.NEW_REVISED_ITEM_REVISION	       "NEW REVISED ITEM REVISION"		'||
'    ,BORI.SUBSTITUTE_GROUP_NUM		       "SUBSTITUTE GROUP NUM"			'||
'    ,BORI.BATCH_ID				       "BATCH ID"			'||
'    from  bom_op_resources_interface bori     where 1=1			      ';

sqltxt :=sqltxt||' and rownum <   '||row_limit;
sqltxt :=sqltxt||' order by bori.operation_sequence_id,bori.resource_seq_num ';

   num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Records in bom_op_resources_interface table ');
   If (num_rows = row_limit -1 ) Then
	JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
   End If;
   statusStr := 'SUCCESS';
   isFatal := 'FALSE';

  /* End of bom_op_resources_interface */

   /* SQL to fetch records from bom_sub_op_resources_interface table */
sqltxt := 'SELECT ' ||
'    BSORI.OPERATION_SEQUENCE_ID		  "OPERATION SEQUENCE ID",		   '||
'    BSORI.SUBSTITUTE_GROUP_NUM			  "SUBSTITUTE GROUP NUM",		   '||
'    BSORI.SCHEDULE_SEQ_NUM			  "SCHEDULE SEQ NUM",			   '||
'    BSORI.REPLACEMENT_GROUP_NUM		  "REPLACEMENT GROUP NUM",		   '||
'    BSORI.RESOURCE_ID				  "RESOURCE ID",			   '||
'    BSORI.ACTIVITY_ID				  "ACTIVITY ID",			   '||
'    BSORI.OPERATION_TYPE			  "OPERATION TYPE",			   '||
'    BSORI.STANDARD_RATE_FLAG			  "STANDARD RATE FLAG",			   '||
'    BSORI.ASSIGNED_UNITS			  "ASSIGNED UNITS",			   '||
'    BSORI.USAGE_RATE_OR_AMOUNT			  "USAGE RATE OR AMOUNT",		   '||
'    BSORI.USAGE_RATE_OR_AMOUNT_INVERSE		  "USAGE RATE OR AMOUNT INVERSE",	   '||
'    BSORI.BASIS_TYPE				  "BASIS TYPE",				   '||
'    BSORI.SCHEDULE_FLAG			  "SCHEDULE FLAG",			   '||
'    to_char(BSORI.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'')	 "LAST UPDATE DATE",	   '||
'    BSORI.LAST_UPDATED_BY			  "LAST UPDATED BY",			   '||
'    to_char(BSORI.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'')	"CREATION DATE",	   '||
'    BSORI.CREATED_BY				  "CREATED BY",				   '||
'    BSORI.LAST_UPDATE_LOGIN			  "LAST UPDATE LOGIN",			   '||
'    BSORI.RESOURCE_OFFSET_PERCENT		  "RESOURCE OFFSET PERCENT",		   '||
'    BSORI.AUTOCHARGE_TYPE			  "AUTOCHARGE TYPE",			   '||
'    BSORI.ATTRIBUTE_CATEGORY			  "ATTRIBUTE CATEGORY",			   '||
'    BSORI.ATTRIBUTE1				  "ATTRIBUTE1",				   '||
'    BSORI.ATTRIBUTE2				  "ATTRIBUTE2",				   '||
'    BSORI.ATTRIBUTE3				  "ATTRIBUTE3",				   '||
'    BSORI.ATTRIBUTE4				  "ATTRIBUTE4",				   '||
'    BSORI.ATTRIBUTE5				  "ATTRIBUTE5",				   '||
'    BSORI.ATTRIBUTE6				  "ATTRIBUTE6",				   '||
'    BSORI.ATTRIBUTE7				  "ATTRIBUTE7",				   '||
'    BSORI.ATTRIBUTE8				  "ATTRIBUTE8",				   '||
'    BSORI.ATTRIBUTE9				  "ATTRIBUTE9",				   '||
'    BSORI.ATTRIBUTE10				  "ATTRIBUTE10",			   '||
'    BSORI.ATTRIBUTE11				  "ATTRIBUTE11",			   '||
'    BSORI.ATTRIBUTE12				  "ATTRIBUTE12",			   '||
'    BSORI.ATTRIBUTE13				  "ATTRIBUTE13",			   '||
'    BSORI.ATTRIBUTE14				  "ATTRIBUTE14",			   '||
'    BSORI.ATTRIBUTE15				  "ATTRIBUTE15",			   '||
'    BSORI.REQUEST_ID				  "REQUEST ID",				   '||
'    BSORI.PROGRAM_APPLICATION_ID		  "PROGRAM APPLICATION ID",		   '||
'    BSORI.PROGRAM_ID				  "PROGRAM ID",				   '||
'    to_char(BSORI.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "PROGRAM UPDATE DATE",  '||
'    BSORI.ASSEMBLY_ITEM_ID			  "ASSEMBLY ITEM ID",			   '||
'    BSORI.ALTERNATE_ROUTING_DESIGNATOR		  "ALTERNATE ROUTING DESIGNATOR",	   '||
'    BSORI.ORGANIZATION_ID			  "ORGANIZATION ID",			   '||
'    BSORI.OPERATION_SEQ_NUM			  "OPERATION SEQ NUM",			   '||
'    to_char(BSORI.EFFECTIVITY_DATE,''DD-MON-YYYY HH24:MI:SS'')	"EFFECTIVITY DATE",	   '||
'    BSORI.ROUTING_SEQUENCE_ID			  "ROUTING SEQUENCE ID",		   '||
'    BSORI.ORGANIZATION_CODE			  "ORGANIZATION CODE",			   '||
'    BSORI.ASSEMBLY_ITEM_NUMBER			  "ASSEMBLY ITEM NUMBER",		   '||
'    BSORI.SUB_RESOURCE_CODE			  "SUB RESOURCE CODE",			   '||
'    BSORI.ACTIVITY				  "ACTIVITY",				   '||
'    BSORI.TRANSACTION_ID			  "TRANSACTION ID",			   '||
'    BSORI.PROCESS_FLAG				  "PROCESS FLAG",			   '||
'    BSORI.TRANSACTION_TYPE			  "TRANSACTION TYPE",			   '||
'    BSORI.NEW_SUB_RESOURCE_CODE		  "NEW SUB RESOURCE CODE",		   '||
'    BSORI.PRINCIPLE_FLAG			  "PRINCIPLE FLAG",			   '||
'    BSORI.ORIGINAL_SYSTEM_REFERENCE		  "ORIGINAL SYSTEM REFERENCE",		   '||
'    BSORI.SETUP_CODE				  "SETUP CODE",				   '||
'    BSORI.ECO_NAME				  "ECO NAME",				   '||
'    BSORI.NEW_REVISED_ITEM_REVISION		  "NEW REVISED ITEM REVISION",		   '||
'    BSORI.NEW_ROUTING_REVISION			  "NEW ROUTING REVISION",		   '||
'    BSORI.ACD_TYPE				  "ACD TYPE"				   '||
'    ,BSORI.NEW_REPLACEMENT_GROUP_NUM		  "NEW REPLACEMENT GROUP NUM"		   '||
'    ,BSORI.ENG_CHANGES_IFCE_KEY		  "ENG CHANGES IFCE KEY"		   '||
'    ,BSORI.BATCH_ID					  "BATCH ID"		   '||
'    ,BSORI.NEW_BASIS_TYPE				  "NEW BASIS TYPE"		   '||
'    from  bom_sub_op_resources_interface bsori   where 1=1			      ';

sqltxt :=sqltxt||' and rownum <   '||row_limit;
sqltxt :=sqltxt||' order by bsori.operation_sequence_id,bsori.substitute_group_num,	  '||
		 ' bsori.schedule_seq_num, bsori.replacement_group_num, bsori.resource_id ';

   num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Records in bom_sub_op_resources_interface table ');
   If (num_rows = row_limit -1 ) Then
	JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
   End If;
   statusStr := 'SUCCESS';
   isFatal := 'FALSE';
  /* End of bom_sub_op_resources_interface */

 End If; /* End of tables common to rtg and eng */

End If; /* end of l_type in either in inv or (bom/rtg/eng) */

/* SQL to fetch records from mtl_interface_errors table.*/
sqltxt := 'SELECT ' ||
'    MIE.ORGANIZATION_ID	     "ORGANIZATION ID",			'||
'    MIE.TRANSACTION_ID		     "TRANSACTION ID",			'||
'    MIE.UNIQUE_ID		     "UNIQUE ID",			'||
'    to_char(MIE.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "LAST UPDATE DATE",'||
'    MIE.LAST_UPDATED_BY	     "LAST UPDATED BY",			'||
'    to_char(MIE.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'')    "CREATION DATE",	'||
'    MIE.CREATED_BY		     "CREATED BY",			'||
'    MIE.LAST_UPDATE_LOGIN	     "LAST UPDATE LOGIN",		'||
'    MIE.TABLE_NAME		     "TABLE NAME",			'||
'    MIE.MESSAGE_NAME		     "MESSAGE NAME",			'||
'    MIE.COLUMN_NAME		     "COLUMN NAME",			'||
'    MIE.REQUEST_ID		     "REQUEST ID",			'||
'    MIE.PROGRAM_APPLICATION_ID	     "PROGRAM APPLICATION ID",		'||
'    MIE.PROGRAM_ID		     "PROGRAM ID",			'||
'    to_char(MIE.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "PROGRAM UPDATE DATE",	'||
'    MIE.ERROR_MESSAGE		     "ERROR MESSAGE",			'||
'    MIE.ENTITY_IDENTIFIER	     "ENTITY IDENTIFIER",		'||
'    MIE.BO_IDENTIFIER		     "BO IDENTIFIER"	, 		'||
'    MIE.MESSAGE_TYPE		     "MESSAGE TYPE"			'||
'    from  mtl_interface_errors mie  where 1=1			        ';

sqltxt :=sqltxt||' and rownum <   '||row_limit;
sqltxt :=sqltxt||' order by mie.organization_id,mie.transaction_id, mie.unique_id  ';

   num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Records in mtl_interface_errors table ');
   If (num_rows = row_limit -1 ) Then
	JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
   End If;
   statusStr := 'SUCCESS';
   isFatal := 'FALSE';

/* End of mtl_interface_errors table.*/

 <<l_test_end>>
 JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/><BR/>This data collection script completed as expected <BR/>');
 report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
 reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
 End If; /* l_type is valid */

 EXCEPTION
 when others then
     JTF_DIAGNOSTIC_COREAPI.errorprint('Error: '||sqlerrm);
     JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('If this error repeats, please contact Oracle Support Services');
     statusStr := 'FAILURE';
     errStr := sqlerrm ||' occurred in script. ';
     fixInfo := 'Unexpected Exception in BOMDGINB.pls';
     isFatal := 'FALSE';
     report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
     reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
END runTest;

PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'Items/Bills/Routings Interface Data Collection';
END getComponentName;

PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2) IS
BEGIN
descStr := ' <pre>This data collection script collects data about Items/Bills/Routings Interface Details. <BR/>	'||
	   ' Type is a mandatory Input field. <BR/>'||
	   ' Note: Please truncate the following interface tables before doing the test cases. <BR/>'||
	   ' Then load the test records into the requisite import tables.<BR/>'||
	   ' For INV - mtl_system_items_interface, mtl_item_revisions_interface,<BR/>'||
	   '           mtl_rtg_item_revs_interface, mtl_item_categories_interface <BR/>'||
	   ' For BOM - bom_bill_of_mtls_interface,bom_inventory_comps_interface,bom_ref_desgs_interface,<BR/>'||
	   '           bom_sub_comps_interface,bom_component_ops_interface<BR/>'||
	   ' For RTG - bom_op_routings_interface, bom_op_sequences_interface, bom_op_resources_interface,<BR/>'||
	   '           bom_sub_op_resources_interface, bom_op_networks_interface <BR/>'||
	   ' Please truncate mtl_interface_errors table for all the cases.<BR/>'||
	   ' Please run this script before and after Import process.</pre>';
/*	   ' For ENG - eng_eng_changes_interface, eng_revised_items_interface, eng_eco_revisions_interface<BR/>'|| */
END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'Items/Bills/Routings Interface Data Collection';
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
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'Type','LOV-oracle.apps.bom.diag.lov.InterfaceRecLov');-- Lov name modified to Type for bug 6412260
defaultInputValues := tempInput;
EXCEPTION
when others then
defaultInputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
END getDefaultTestParams;

Function getTestMode return INTEGER IS
BEGIN
return JTF_DIAGNOSTIC_ADAPTUTIL.ADVANCED_MODE;

END getTestMode;

END BOM_DIAGUNITTEST_INTFDATA;

/
