--------------------------------------------------------
--  DDL for Package Body BOM_DIAGUNITTEST_IBRDATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_DIAGUNITTEST_IBRDATA" as
/* $Header: BOMDGIBB.pls 120.1 2007/12/26 09:52:38 vggarg noship $ */
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


/* Get the application installation info. References to Data Dictionary Objects without schema name
included in WHERE predicate are not allowed (GSCC Check: file.sql.47). Schema name has to be passed
as an input parameter to JTF_DIAGNOSTIC_COREAPI.Column_Exists API. */

l_ret_status :=      fnd_installation.get_app_info ('INV'
                                   , l_status
                                   , l_industry
                                   , l_oracle_schema
                                    );

/*JTF_DIAGNOSTIC_COREAPI.Line_Out(' l_oracle_schema: '||l_oracle_schema);*/


/* Start the diagnostic test scripts */
sqltxt := 'SELECT '||
	'	  MIF.PADDED_ITEM_NUMBER		"ITEM NUMBER"										    '||
	'	 ,MSIB.INVENTORY_ITEM_ID		"Item ID"										    '||
	'	 ,MP.ORGANIZATION_CODE			"Org Code"										    '||
	'	 ,MSIB.ORGANIZATION_ID			"Org Id"										    '||
	'	 ,to_char(MSIB.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "Last Update Date"								'||
	'	 ,MSIB.LAST_UPDATED_BY			"Last Updated By"									    '||
	'	 ,to_char(MSIB.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'') "Creation Date"							'||
	'	 ,MSIB.CREATED_BY			"Created by"										    '||
	'	 ,MSIB.LAST_UPDATE_LOGIN		"Last Update Login"									    '||
	'	 ,MSIB.SUMMARY_FLAG			"Summary Flag"										    '||
	'	 ,MSIB.ENABLED_FLAG			"Enabled Flag"										    '||
	'	 ,to_char(MSIB.START_DATE_ACTIVE,''DD-MON-YYYY HH24:MI:SS'')	"Start Date Active"						'||
	'	 ,to_char(MSIB.END_DATE_ACTIVE,''DD-MON-YYYY HH24:MI:SS'')	"END DATE ACTIVE"						'||
	'	 ,MSIB.DESCRIPTION			"DESCRIPTION"										    '||
	'	 ,MSIB.BUYER_ID				"BUYER ID" 										    '||
	'	 ,MSIB.ACCOUNTING_RULE_ID		"ACCOUNTING RULE ID"									    '||
	'	 ,MSIB.INVOICING_RULE_ID		"INVOICING RULE ID"									    '||
	'	 ,MSIB.SEGMENT1				"SEGMENT1"										    '||
	'	 ,MSIB.SEGMENT2				"SEGMENT2"										    '||
	'	 ,MSIB.SEGMENT3				"SEGMENT3"										    '||
	'	 ,MSIB.SEGMENT4				"SEGMENT4"										    '||
	'	 ,MSIB.SEGMENT5				"SEGMENT5"										    '||
	'	 ,MSIB.SEGMENT6				"SEGMENT6"										    '||
	'	 ,MSIB.SEGMENT7				"SEGMENT7"										    '||
	'	 ,MSIB.SEGMENT8				"SEGMENT8"										    '||
	'	 ,MSIB.SEGMENT9				"SEGMENT9"										    '||
	'	 ,MSIB.SEGMENT10			"SEGMENT10"										    '||
	'	 ,MSIB.SEGMENT11			"SEGMENT11"										    '||
	'	 ,MSIB.SEGMENT12			"SEGMENT12"										    '||
	'	 ,MSIB.SEGMENT13			"SEGMENT13"										    '||
	'	 ,MSIB.SEGMENT14			"SEGMENT14"										    '||
	'	 ,MSIB.SEGMENT15			"SEGMENT15"										    '||
	'	 ,MSIB.SEGMENT16			"SEGMENT16"										    '||
	'	 ,MSIB.SEGMENT17			"SEGMENT17"										    '||
	'	 ,MSIB.SEGMENT18			"SEGMENT18"										    '||
	'	 ,MSIB.SEGMENT19			"SEGMENT19"										    '||
	'	 ,MSIB.SEGMENT20			"SEGMENT20"										    '||
	'	 ,MSIB.ATTRIBUTE_CATEGORY		"ATTRIBUTE CATEGORY"									    '||
	'	 ,MSIB.ATTRIBUTE1			"ATTRIBUTE1"										    '||
	'	 ,MSIB.ATTRIBUTE2			"ATTRIBUTE2"										    '||
	'	 ,MSIB.ATTRIBUTE3			"ATTRIBUTE3"										    '||
	'	 ,MSIB.ATTRIBUTE4			"ATTRIBUTE4"										    '||
	'	 ,MSIB.ATTRIBUTE5			"ATTRIBUTE5"										    '||
	'	 ,MSIB.ATTRIBUTE6			"ATTRIBUTE6"										    '||
	'	 ,MSIB.ATTRIBUTE7			"ATTRIBUTE7"										    '||
	'	 ,MSIB.ATTRIBUTE8			"ATTRIBUTE8"		        							    '||
	'	 ,MSIB.ATTRIBUTE9                     	"ATTRIBUTE9"  										    '||
	'	 ,MSIB.ATTRIBUTE10                    	"ATTRIBUTE10"										    '||
	'	 ,MSIB.ATTRIBUTE11                    	"ATTRIBUTE11"										    '||
	'	 ,MSIB.ATTRIBUTE12                    	"ATTRIBUTE12"										    '||
	'	 ,MSIB.ATTRIBUTE13                    	"ATTRIBUTE13"										    '||
	'	 ,MSIB.ATTRIBUTE14                    	"ATTRIBUTE14"										    '||
	'	 ,MSIB.ATTRIBUTE15                    	"ATTRIBUTE15"										    '||
	'	 ,MSIB.PURCHASING_ITEM_FLAG           	"PURCHASING ITEM FLAG"          							    '||
	'	 ,MSIB.SHIPPABLE_ITEM_FLAG            	"SHIPPABLE ITEM FLAG"           							    '||
	'	 ,MSIB.CUSTOMER_ORDER_FLAG            	"CUSTOMER ORDER FLAG"           							    '||
	'	 ,MSIB.INTERNAL_ORDER_FLAG            	"INTERNAL ORDER FLAG"           							    '||
	'	 ,MSIB.SERVICE_ITEM_FLAG              	"SERVICE ITEM FLAG"             							    '||
	'	 ,MSIB.INVENTORY_ITEM_FLAG            	"INVENTORY ITEM FLAG"           							    '||
	'	 ,MSIB.ENG_ITEM_FLAG                  	"ENG ITEM FLAG"                 							    '||
	'	 ,MSIB.INVENTORY_ASSET_FLAG           	"INVENTORY ASSET FLAG"          							    '||
	'	 ,MSIB.PURCHASING_ENABLED_FLAG        	"PURCHASING ENABLED FLAG"       							    '||
	'	 ,MSIB.CUSTOMER_ORDER_ENABLED_FLAG    	"CUSTOMER ORDER ENABLED FLAG"   							    '||
	'	 ,MSIB.INTERNAL_ORDER_ENABLED_FLAG    	"INTERNAL ORDER ENABLED FLAG"   							    '||
	'	 ,MSIB.SO_TRANSACTIONS_FLAG           	"SO TRANSACTIONS FLAG"          							    '||
	'	 ,MSIB.MTL_TRANSACTIONS_ENABLED_FLAG  	"MTL TRANSACTIONS ENABLED FLAG" 							    '||
	'	 ,MSIB.STOCK_ENABLED_FLAG             	"STOCK ENABLED FLAG"            							    '||
	'	 ,MSIB.BOM_ENABLED_FLAG               	"BOM ENABLED FLAG"              							    '||
	'	 ,MSIB.BUILD_IN_WIP_FLAG              	"BUILD IN WIP FLAG"             							    '||
	'	 ,DECODE(MLU_RQCC.MEANING,null,null,												    '||
	'	 	(MLU_RQCC.MEANING || '' ('' || MSIB.REVISION_QTY_CONTROL_CODE || '')''))  "REVISION QTY CONTROL CODE" 			    '||
	'	 ,MSIB.ITEM_CATALOG_GROUP_ID          	"ITEM CATALOG GROUP ID"        								    '||
	'	 ,MSIB.CATALOG_STATUS_FLAG            	"CATALOG STATUS FLAG"          								    '||
	'	 ,MSIB.RETURNABLE_FLAG                	"RETURNABLE FLAG"              								    '||
	'	 ,MSIB.DEFAULT_SHIPPING_ORG           	"DEFAULT SHIPPING ORG"         								    '||
	'	 ,MSIB.COLLATERAL_FLAG                	"COLLATERAL FLAG"              								    '||
	'	 ,MSIB.TAXABLE_FLAG                   	"TAXABLE FLAG"                 								    '||
	'	 ,MSIB.PURCHASING_TAX_CODE            	"PURCHASING TAX CODE"            							    '||
	'	 ,DECODE(PLU_QREC.DISPLAYED_FIELD,null,null,											    '||
	'	 	(PLU_QREC.DISPLAYED_FIELD || '' ('' || MSIB.QTY_RCV_EXCEPTION_CODE || '')''))  "QTY RCV EXCEPTION CODE"			    '||
	'	 ,MSIB.ALLOW_ITEM_DESC_UPDATE_FLAG    	"ALLOW ITEM DESC UPDATE FLAG"    							    '||
	'	 ,MSIB.INSPECTION_REQUIRED_FLAG       	"INSPECTION REQUIRED FLAG"       							    '||
	'	 ,MSIB.RECEIPT_REQUIRED_FLAG          	"RECEIPT REQUIRED FLAG"          							    '||
	'	 ,MSIB.MARKET_PRICE                   	"MARKET PRICE"                   							    '||
	'	 ,MSIB.HAZARD_CLASS_ID                	"HAZARD CLASS ID"                							    '||
	'	 ,MSIB.RFQ_REQUIRED_FLAG              	"RFQ REQUIRED FLAG"              							    '||
	'	 ,MSIB.QTY_RCV_TOLERANCE              	"QTY RCV TOLERANCE"              							    '||
	'	 ,MSIB.LIST_PRICE_PER_UNIT            	"LIST PRICE PER UNIT"            							    '||
	'	 ,MSIB.UN_NUMBER_ID                   	"UN NUMBER ID"										    '||
	'	 ,MSIB.PRICE_TOLERANCE_PERCENT        	"PRICE TOLERANCE PERCENT"        							    '||
	'	 ,MSIB.ASSET_CATEGORY_ID              	"ASSET CATEGORY ID"              							    '||
	'	 ,MSIB.ROUNDING_FACTOR                	"ROUNDING FACTOR"                							    '||
	'	 ,MSIB.UNIT_OF_ISSUE                  	"UNIT OF ISSUE"		    								    '||
	'	 ,DECODE(PLU_ESLC.DISPLAYED_FIELD,null,null,											    '||
	'	 	(PLU_ESLC.DISPLAYED_FIELD || '' ('' || MSIB.ENFORCE_SHIP_TO_LOCATION_CODE || '')'')) "ENFORCE SHIP TO LOCATION CODE"   	    '||
	'	 ,MSIB.ALLOW_SUBSTITUTE_RECEIPTS_FLAG "ALLOW SUBSTITUTE RECEIPTS FLAG" 								    '||
	'	 ,MSIB.ALLOW_UNORDERED_RECEIPTS_FLAG  "ALLOW UNORDERED RECEIPTS FLAG"  								    '||
	'	 ,MSIB.ALLOW_EXPRESS_DELIVERY_FLAG    "ALLOW EXPRESS DELIVERY FLAG"    								    '||
	'	 ,MSIB.DAYS_EARLY_RECEIPT_ALLOWED     "DAYS EARLY RECEIPT ALLOWED"     								    '||
	'	 ,MSIB.DAYS_LATE_RECEIPT_ALLOWED      "DAYS LATE RECEIPT ALLOWED"      								    '||
	'	 ,DECODE(PLU_RDEC.DISPLAYED_FIELD,null,null,											    '||
	'	 	(PLU_RDEC.DISPLAYED_FIELD || '' ('' || MSIB.RECEIPT_DAYS_EXCEPTION_CODE || '')''))   "RECEIPT DAYS EXCEPTION CODE"   	    '||
	'	 ,MSIB.RECEIVING_ROUTING_ID           "RECEIVING ROUTING ID"             							    '||
	'	 ,MSIB.INVOICE_CLOSE_TOLERANCE        "INVOICE CLOSE TOLERANCE"          							    '||
	'	 ,MSIB.RECEIVE_CLOSE_TOLERANCE        "RECEIVE CLOSE TOLERANCE"           							    '||
	' FROM    mtl_system_items_b msib, mtl_item_flexfields mif										'||
	' 	 ,mtl_parameters mp														'||
	'	,MFG_LOOKUPS MLU_RQCC														'||
	'	,PO_LOOKUP_CODES PLU_QREC													'||
	'	,PO_LOOKUP_CODES PLU_ESLC													'||
	'	,PO_LOOKUP_CODES PLU_RDEC													'||
	' WHERE  1=1																'||
	' and	msib.inventory_item_id= mif.inventory_item_id											'||
	' and	msib.organization_id = mif.organization_id											'||
	' and	msib.organization_id = mp.organization_id											'||
	' and	mif.organization_id =  mp.organization_id											'||
	' and	msib.REVISION_QTY_CONTROL_CODE=MLU_RQCC.LOOKUP_CODE(+) AND ''MTL_ENG_QUANTITY''=MLU_RQCC.LOOKUP_TYPE(+)				'||
	' and	msib.QTY_RCV_EXCEPTION_CODE=PLU_QREC.LOOKUP_CODE(+) AND ''RECEIVING CONTROL LEVEL''=PLU_QREC.LOOKUP_TYPE(+)			'||
	' and	msib.ENFORCE_SHIP_TO_LOCATION_CODE=PLU_ESLC.LOOKUP_CODE(+) AND ''RECEVING CONTROL LEVEL''=PLU_ESLC.LOOKUP_TYPE(+)		'||
	' and	msib.RECEIPT_DAYS_EXCEPTION_CODE=PLU_RDEC.LOOKUP_CODE(+) AND ''RECEIVING CONTROL LEVEL''=PLU_RDEC.LOOKUP_TYPE(+)		';

	if l_org_id is not null then
	   sqltxt :=sqltxt||' and msib.organization_id =  '||l_org_id;
	end if;

	if l_item_id is not null then
	   sqltxt :=sqltxt||' and msib.inventory_item_id =  '||l_item_id;
	   sqltxt :=sqltxt||' and rownum <   '||row_limit;
	   sqltxt :=sqltxt||' order by  mp.organization_code,mif.padded_item_number';
	end if;

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Item Attributes');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;

	statusStr := 'SUCCESS';
	isFatal := 'FALSE';

sqltxt := '	SELECT ' ||
	'	   MIF.PADDED_ITEM_NUMBER		"ITEM NUMBER"										'||
	'	  ,MSIB.INVENTORY_ITEM_ID		"ITEM ID"										'||
	'	  ,MP.ORGANIZATION_CODE			"Org Code"										'||
	'	  ,MSIB.ORGANIZATION_ID			"ORG ID"										'||
	'	  ,MSIB.AUTO_LOT_ALPHA_PREFIX          	"AUTO LOT ALPHA PREFIX"									'||
	'	  ,MSIB.START_AUTO_LOT_NUMBER          	"START AUTO LOT NUMBER"									'||
	'	  ,DECODE(MLU_LOTCC.MEANING,null,null,												'||
	'	  	(MLU_LOTCC.MEANING || '' ('' || MSIB.LOT_CONTROL_CODE || '')''))	"LOT CONTROL CODE"  				'||
	'	  ,DECODE(MLU_SLC.MEANING,null,null,												'||
	'	  	(MLU_SLC.MEANING || '' ('' || MSIB.SHELF_LIFE_CODE || '')''))	"SHELF LIFE CODE"   					'||
	'	  ,MSIB.SHELF_LIFE_DAYS                "SHELF LIFE DAYS" 									'||
	'	  ,DECODE(MLU_SNCC.MEANING,null,null,												'||
	'	  	(MLU_SNCC.MEANING || '' ('' || MSIB.SERIAL_NUMBER_CONTROL_CODE || '')''))  "SERIAL NUMBER CONTROL CODE"  		'||
	'	  ,MSIB.START_AUTO_SERIAL_NUMBER       "START AUTO SERIAL NUMBER"   								'||
	'	  ,MSIB.AUTO_SERIAL_ALPHA_PREFIX       "AUTO SERIAL ALPHA PREFIX"   								'||
	'	  ,DECODE(MLU_ST.MEANING,null,null,												'||
	'	  	(MLU_ST.MEANING || '' ('' || MSIB.SOURCE_TYPE || '')''))		"SOURCE TYPE" 					'||
	'	  ,MSIB.SOURCE_ORGANIZATION_ID         "SOURCE ORGANIZATION ID"         							'||
	'	  ,MSIB.SOURCE_SUBINVENTORY            "SOURCE SUBINVENTORY"          								'||
	'	  ,MSIB.EXPENSE_ACCOUNT                "EXPENSE ACCOUNT"              								'||
	'	  ,MSIB.ENCUMBRANCE_ACCOUNT            "ENCUMBRANCE ACCOUNT"          								'||
	'	  ,DECODE(MLU_RSIC.MEANING,null,null,												'||
	'	  	(MLU_RSIC.MEANING || '' ('' || MSIB.RESTRICT_SUBINVENTORIES_CODE || '')''))  "RESTRICT SUBINVENTORIES CODE" 		'||
	'	  ,MSIB.UNIT_WEIGHT                    "UNIT WEIGHT"               								'||
	'	  ,MSIB.WEIGHT_UOM_CODE                "WEIGHT UOM CODE"           								'||
	'	  ,MSIB.VOLUME_UOM_CODE                "VOLUME UOM CODE"           								'||
	'	  ,MSIB.UNIT_VOLUME                    "UNIT VOLUME"               								'||
	'	  ,DECODE(MLU_RLC.MEANING,null,null,												'||
	'	  	(MLU_RLC.MEANING || '' ('' || MSIB.RESTRICT_LOCATORS_CODE || '')''))  "RESTRICT LOCATORS CODE"  			'||
	'	  ,DECODE(MLU_LCC.MEANING,null,null,												'||
	'	  	(MLU_LCC.MEANING || '' ('' || MSIB.LOCATION_CONTROL_CODE || '')''))   "LOCATION CONTROL CODE"   			'||
	'	  ,MSIB.SHRINKAGE_RATE                 "SHRINKAGE RATE"                   							'||
	'	  ,MSIB.ACCEPTABLE_EARLY_DAYS          "ACCEPTABLE EARLY DAYS" 									'||
	'	  ,DECODE(MLU_PTFC.MEANING,null,null,												'||
	'	  	(MLU_PTFC.MEANING || '' ('' || MSIB.PLANNING_TIME_FENCE_CODE || '')''))	"PLANNING TIME FENCE CODE"       		'||
	'	  ,DECODE(MLU_DTFC.MEANING,null,null,												'||
	'	  	(MLU_DTFC.MEANING || '' ('' || MSIB.DEMAND_TIME_FENCE_CODE || '')''))       "DEMAND TIME FENCE CODE"           		'||
	'	  ,MSIB.LEAD_TIME_LOT_SIZE             "LEAD TIME LOT SIZE"                    							'||
	'	  ,MSIB.STD_LOT_SIZE                   "STD LOT SIZE"                          							'||
	'	  ,MSIB.CUM_MANUFACTURING_LEAD_TIME    "CUM MANUFACTURING LEAD TIME"           							'||
	'	  ,MSIB.OVERRUN_PERCENTAGE             "OVERRUN PERCENTAGE"                    							'||
	'	  ,MSIB.MRP_CALCULATE_ATP_FLAG         "MRP CALCULATE ATP FLAG"                							'||
	'	  ,MSIB.ACCEPTABLE_RATE_INCREASE       "ACCEPTABLE RATE INCREASE"              							'||
	'	  ,MSIB.ACCEPTABLE_RATE_DECREASE       "ACCEPTABLE RATE DECREASE"              							'||
	'	  ,MSIB.CUMULATIVE_TOTAL_LEAD_TIME     "CUMULATIVE TOTAL LEAD TIME"            							'||
	'	  ,MSIB.PLANNING_TIME_FENCE_DAYS       "PLANNING TIME FENCE DAYS"              							'||
	'	  ,MSIB.DEMAND_TIME_FENCE_DAYS         "DEMAND TIME FENCE DAYS"                							'||
	'	  ,DECODE(FLU_EAPF.MEANING,null,null,												'||
	'	  	(FLU_EAPF.MEANING || '' ('' || MSIB.END_ASSEMBLY_PEGGING_FLAG || '')''))	"END ASSEMBLY PEGGING FLAG"   		'||
	'	  ,MSIB.REPETITIVE_PLANNING_FLAG       "REPETITIVE PLANNING FLAG"              							'||
	'	  ,MSIB.PLANNING_EXCEPTION_SET         "PLANNING EXCEPTION SET"                							'||
	'	  ,DECODE(MLU_BIT.MEANING,null,null,												'||
	'	  	(MLU_BIT.MEANING || '' ('' || MSIB.BOM_ITEM_TYPE || '')''))			"BOM ITEM TYPE"				'||
	'	  ,MSIB.PICK_COMPONENTS_FLAG           "PICK COMPONENTS FLAG"		  							'||
	'	  ,MSIB.REPLENISH_TO_ORDER_FLAG        "REPLENISH TO ORDER FLAG"		  						'||
	'	  ,MIF2.PADDED_ITEM_NUMBER		"BASE ITEM NUMBER"									'||
	'	  ,MSIB.BASE_ITEM_ID                   "BASE ITEM ID"                         							'||
	'	  ,MSIB.ATP_COMPONENTS_FLAG            "ATP COMPONENTS FLAG"									'||
	'	  ,MSIB.ATP_FLAG                       "ATP FLAG"										'||
	'	  ,MSIB.FIXED_LEAD_TIME                "FIXED LEAD TIME"                      							'||
	'	  ,MSIB.VARIABLE_LEAD_TIME             "VARIABLE LEAD TIME"                   							'||
	'	  ,MSIB.WIP_SUPPLY_LOCATOR_ID          "WIP SUPPLY LOCATOR ID"                							'||
	'	  ,DECODE(MLU_WST.MEANING,null,null,												'||
	'	  	(MLU_WST.MEANING || '' ('' || MSIB.WIP_SUPPLY_TYPE || '')''))		"WIP SUPPLY TYPE"               		'||
	'	  ,MSIB.WIP_SUPPLY_SUBINVENTORY        "WIP SUPPLY SUBINVENTORY"         							'||
	'	  ,MSIB.OVERCOMPLETION_TOLERANCE_TYPE  "OVERCOMPLETION TOLERANCE TYPE"   							'||
	'	  ,MSIB.OVERCOMPLETION_TOLERANCE_VALUE "OVERCOMPLETION TOLERANCE VALUE"  							'||
	'	FROM   	mtl_system_items_b msib, mtl_item_flexfields mif									'||
	'		,mtl_parameters mp, mtl_item_flexfields mif2										'||
	'		,MFG_LOOKUPS MLU_LOTCC													'||
	'		,MFG_LOOKUPS MLU_SLC													'||
	'		,MFG_LOOKUPS MLU_SNCC													'||
	'		,MFG_LOOKUPS MLU_ST													'||
	'		,MFG_LOOKUPS MLU_RSIC													'||
	'		,MFG_LOOKUPS MLU_RLC													'||
	'		,MFG_LOOKUPS MLU_LCC													'||
	'		,MFG_LOOKUPS MLU_PTFC													'||
	'		,MFG_LOOKUPS MLU_DTFC													'||
	'		,FND_LOOKUPS FLU_EAPF													'||
	'		,MFG_LOOKUPS MLU_BIT													'||
	'		,MFG_LOOKUPS MLU_WST													'||
	'	where 1=1															'||
	'	and 	msib.inventory_item_id= mif.inventory_item_id										'||
	'	and 	msib.organization_id = mif.organization_id										'||
	'	and 	msib.organization_id = mp.organization_id										'||
	'	and 	mif.organization_id =  mp.organization_id										'||
	'	and 	msib.base_item_id	 =  mif2.inventory_item_id(+)									'||
	'	and 	msib.organization_id = mif2.organization_id(+)										'||
	'	and 	msib.LOT_CONTROL_CODE=MLU_LOTCC.LOOKUP_CODE(+) AND ''MTL_LOT_CONTROL''=MLU_LOTCC.LOOKUP_TYPE(+)				'||
	'	and 	msib.SHELF_LIFE_CODE=MLU_SLC.LOOKUP_CODE(+) AND ''MTL_SHELF_LIFE''=MLU_SLC.LOOKUP_TYPE(+)				'||
	'	and 	msib.SERIAL_NUMBER_CONTROL_CODE=MLU_SNCC.LOOKUP_CODE(+) AND ''MTL_SERIAL_NUMBER''=MLU_SNCC.LOOKUP_TYPE(+)		'||
	'	and 	msib.SOURCE_TYPE=MLU_ST.LOOKUP_CODE(+) AND ''MTL_SOURCE_TYPES''=MLU_ST.LOOKUP_TYPE(+)					'||
	'	and 	msib.RESTRICT_SUBINVENTORIES_CODE=MLU_RSIC.LOOKUP_CODE(+) AND ''MTL_SUBINVENTORY_RESTRICTIONS''=MLU_RSIC.LOOKUP_TYPE(+)	'||
	'	and 	msib.RESTRICT_LOCATORS_CODE=MLU_RLC.LOOKUP_CODE(+) AND ''MTL_LOCATOR_RESTRICTIONS''=MLU_RLC.LOOKUP_TYPE(+)		'||
	'	and 	msib.LOCATION_CONTROL_CODE=MLU_LCC.LOOKUP_CODE(+) AND ''MTL_LOCATION_CONTROL''=MLU_LCC.LOOKUP_TYPE(+)			'||
	'	and	msib.PLANNING_TIME_FENCE_CODE=MLU_PTFC.LOOKUP_CODE(+) AND ''MTL_TIME_FENCE''=MLU_PTFC.LOOKUP_TYPE(+)			'||
	'	and 	msib.DEMAND_TIME_FENCE_CODE=MLU_DTFC.LOOKUP_CODE(+) AND ''MTL_ITEM_FENCH''=MLU_DTFC.LOOKUP_TYPE(+)			'||
	'	and 	msib.END_ASSEMBLY_PEGGING_FLAG=FLU_EAPF.LOOKUP_CODE(+) AND ''ASSEMBLY_PEGGING_CODE''=FLU_EAPF.LOOKUP_TYPE(+)		'||
	'	and 	msib.BOM_ITEM_TYPE=MLU_BIT.LOOKUP_CODE(+) AND ''BOM_ITEM_TYPE''=MLU_BIT.LOOKUP_TYPE(+)					'||
	'	and 	msib.WIP_SUPPLY_TYPE=MLU_WST.LOOKUP_CODE(+) AND ''WIP_SUPPLY''=MLU_WST.LOOKUP_TYPE(+)					';

	if l_org_id is not null then
	   sqltxt :=sqltxt||' and msib.organization_id =  '||l_org_id;
	end if;

	if l_item_id is not null then
	   sqltxt :=sqltxt||' and msib.inventory_item_id =  '||l_item_id;
	end if;

	sqltxt :=sqltxt||' and rownum <   '||row_limit;
	sqltxt :=sqltxt||' order by  mp.organization_code,mif.padded_item_number';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Item Attributes (Contd 1..)');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;

	statusStr := 'SUCCESS';
	isFatal := 'FALSE';

sqltxt := '	SELECT ' ||
	'	   MIF.PADDED_ITEM_NUMBER		"ITEM NUMBER"										'||
	'	  ,MSIB.INVENTORY_ITEM_ID		"ITEM ID"										'||
	'	  ,MP.ORGANIZATION_CODE			"ORG CODE"										'||
	'	  ,MSIB.ORGANIZATION_ID			"ORG ID"										'||
	'	  ,MSIB.PRIMARY_UOM_CODE		"PRIMARY UOM CODE"            								'||
	'	  ,MSIB.PRIMARY_UNIT_OF_MEASURE        	 "PRIMARY UNIT OF MEASURE"     								'||
	'	  ,DECODE(MLU_AULC.MEANING,null,null,												'||
	'		(MLU_AULC.MEANING || '' ('' || MSIB.ALLOWED_UNITS_LOOKUP_CODE || '')'')) "ALLOWED UNITS LOOKUP CODE"              	'||
	'	  ,MSIB.COST_OF_SALES_ACCOUNT          	"COST OF SALES ACCOUNT"               							'||
	'	  ,MSIB.SALES_ACCOUNT                  	"SALES ACCOUNT"                       							'||
	'	  ,MSIB.DEFAULT_INCLUDE_IN_ROLLUP_FLAG 	"DEFAULT INCLUDE IN ROLLUP FLAG"      							'||
	'	  ,MSIB.INVENTORY_ITEM_STATUS_CODE     	"INVENTORY ITEM STATUS CODE"								'||
	'	  ,DECODE(MLU_IPC.MEANING,null,null,												'||
	'		(MLU_IPC.MEANING || '' ('' || MSIB.INVENTORY_PLANNING_CODE || '')''))    "INVENTORY PLANNING CODE"         		'||
	'	  ,MSIB.PLANNER_CODE                   	"PLANNER CODE"                           						'||
	'	  ,DECODE(MLU_PMBC.MEANING,null,null,												'||
	'		(MLU_PMBC.MEANING || '' ('' || MSIB.PLANNING_MAKE_BUY_CODE || '')''))    "PLANNING MAKE BUY CODE"       		'||
	'	  ,MSIB.FIXED_LOT_MULTIPLIER           	"FIXED LOT MULTIPLIER"                   						'||
	'	  ,DECODE(MLU_RCT.MEANING,null,null,												'||
	'		(MLU_RCT.MEANING || '' ('' || MSIB.ROUNDING_CONTROL_TYPE || '')''))      "ROUNDING CONTROL TYPE"         		'||
	'	  ,MSIB.CARRYING_COST                  	"CARRYING COST"                        							'||
	'	  ,MSIB.POSTPROCESSING_LEAD_TIME       	"POSTPROCESSING LEAD TIME"             							'||
	'	  ,MSIB.PREPROCESSING_LEAD_TIME        	"PREPROCESSING LEAD TIME"              							'||
	'	  ,MSIB.FULL_LEAD_TIME                 	"FULL LEAD TIME"                       							'||
	'	  ,MSIB.ORDER_COST                     	"ORDER COST"                           							'||
	'	  ,MSIB.MRP_SAFETY_STOCK_PERCENT       	"MRP SAFETY STOCK PERCENT"             							'||
	'	  ,DECODE(MLU_MSSC.MEANING,null,null,												'||
	'		(MLU_MSSC.MEANING || '' ('' || MSIB.MRP_SAFETY_STOCK_CODE || '')''))      "MRP SAFETY STOCK CODE"        		'||
	'	  ,MSIB.MIN_MINMAX_QUANTITY            	"MIN MINMAX QUANTITY"									'||
	'	  ,MSIB.MAX_MINMAX_QUANTITY		"MAX MINMAX QUANTITY"									'||
	'	  ,MSIB.MINIMUM_ORDER_QUANTITY		"MINIMUM ORDER QUANTITY"								'||
	'	  ,MSIB.FIXED_ORDER_QUANTITY		"FIXED ORDER QUANTITY"									'||
	'	  ,MSIB.FIXED_DAYS_SUPPLY		"FIXED DAYS SUPPLY"									'||
	'	  ,MSIB.MAXIMUM_ORDER_QUANTITY		"MAXIMUM ORDER QUANTITY"								'||
	'	  ,MSIB.ATP_RULE_ID			"ATP RULE ID"										'||
	'	  ,MSIB.PICKING_RULE_ID			"PICKING RULE ID"									'||
	'	  ,MSIB.RESERVABLE_TYPE			"RESERVABLE TYPE"									'||
	'	  ,MSIB.POSITIVE_MEASUREMENT_ERROR	"POSITIVE MEASUREMENT ERROR"								'||
	'	  ,MSIB.NEGATIVE_MEASUREMENT_ERROR	"NEGATIVE MEASUREMENT ERROR"								'||
	'	  ,MSIB.ENGINEERING_ECN_CODE		"ENGINEERING ECN CODE"									'||
	'	  ,MSIB.ENGINEERING_ITEM_ID		"ENGINEERING ITEM ID"									'||
	'	  ,to_char(MSIB.ENGINEERING_DATE,''DD-MON-YYYY HH24:MI:SS'')	"ENGINEERING DATE"						'||
	'	  ,MSIB.SERVICE_STARTING_DELAY		"SERVICE STARTING DELAY"								'||
	'	  ,MSIB.VENDOR_WARRANTY_FLAG		"VENDOR WARRANTY FLAG"									'||
	'	  ,MSIB.SERVICEABLE_COMPONENT_FLAG	"SERVICEABLE COMPONENT FLAG"								'||
	'	  ,MSIB.SERVICEABLE_PRODUCT_FLAG	"SERVICEABLE PRODUCT FLAG"								'||
	'	  ,MSIB.BASE_WARRANTY_SERVICE_ID	"BASE WARRANTY SERVICE ID"								'||
	'	  ,MSIB.PAYMENT_TERMS_ID		"PAYMENT TERMS ID"									'||
	'	  ,MSIB.PREVENTIVE_MAINTENANCE_FLAG	"PREVENTIVE MAINTENANCE FLAG"								'||
	'	  ,MSIB.PRIMARY_SPECIALIST_ID		"PRIMARY SPECIALIST ID"									'||
	'	  ,MSIB.SECONDARY_SPECIALIST_ID		"SECONDARY SPECIALIST ID"								'||
	'	  ,MSIB.SERVICEABLE_ITEM_CLASS_ID	"SERVICEABLE ITEM CLASS ID"								'||
	'	  ,MSIB.TIME_BILLABLE_FLAG		"TIME BILLABLE FLAG"									'||
	'	  ,DECODE(CLU_MBF.MEANING,null,null,												'||
	'		(CLU_MBF.MEANING || '' ('' || MSIB.MATERIAL_BILLABLE_FLAG || '')''))	"MATERIAL BILLABLE FLAG"			'||
	'	  ,MSIB.EXPENSE_BILLABLE_FLAG		"EXPENSE BILLABLE FLAG"									'||
	'	  ,MSIB.PRORATE_SERVICE_FLAG		"PRORATE SERVICE FLAG"									'||
	'	  ,MSIB.COVERAGE_SCHEDULE_ID		"COVERAGE SCHEDULE ID"									'||
	'	  ,MSIB.SERVICE_DURATION_PERIOD_CODE	"SERVICE DURATION PERIOD CODE"								'||
	'	  ,MSIB.SERVICE_DURATION		"SERVICE DURATION"									'||
	'	  ,MSIB.WARRANTY_VENDOR_ID		"WARRANTY VENDOR ID"									'||
	'	  ,MSIB.MAX_WARRANTY_AMOUNT		"MAX WARRANTY AMOUNT"									'||
	'	  ,MSIB.RESPONSE_TIME_PERIOD_CODE	"RESPONSE TIME PERIOD CODE"								'||
	'	  ,MSIB.RESPONSE_TIME_VALUE		"RESPONSE TIME VALUE"									'||
	'	  ,MSIB.NEW_REVISION_CODE		"NEW REVISION CODE"									'||
	'	  ,MSIB.INVOICEABLE_ITEM_FLAG		"INVOICEABLE ITEM FLAG"									'||
	'	  ,MSIB.TAX_CODE			"TAX CODE"										'||
	'	  ,MSIB.INVOICE_ENABLED_FLAG		"INVOICE ENABLED FLAG"									'||
	'	  ,MSIB.MUST_USE_APPROVED_VENDOR_FLAG	"MUST USE APPROVED VENDOR FLAG"								'||
	'	  ,MSIB.REQUEST_ID			"REQUEST ID"										'||
	'	  ,MSIB.PROGRAM_APPLICATION_ID		"PROGRAM APPLICATION ID"								'||
	'	  ,MSIB.PROGRAM_ID			"PROGRAM ID"										'||
	'	  ,to_char(MSIB.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'')	"PROGRAM UPDATE DATE"						'||
	'	  ,MSIB.OUTSIDE_OPERATION_FLAG		"OUTSIDE OPERATION FLAG"								'||
	'	  ,DECODE(PLU_OOUT.DISPLAYED_FIELD,null,null,											'||
	'		(PLU_OOUT.DISPLAYED_FIELD || '' ('' || MSIB.OUTSIDE_OPERATION_UOM_TYPE || '')'')) "OUTSIDE OPERATION UOM TYPE"		'||
	'	  ,MSIB.SAFETY_STOCK_BUCKET_DAYS	"SAFETY STOCK BUCKET DAYS"								'||
	'	  ,DECODE(MLU_ARM.MEANING,null,null,												'||
	'		(MLU_ARM.MEANING || '' ('' || MSIB.AUTO_REDUCE_MPS || '')''))		"AUTO REDUCE MPS"				'||
	'	  ,MSIB.COSTING_ENABLED_FLAG		"COSTING ENABLED FLAG"									'||
	'	  ,MSIB.AUTO_CREATED_CONFIG_FLAG	"AUTO CREATED CONFIG FLAG"								'||
	'	  ,MSIB.CYCLE_COUNT_ENABLED_FLAG	"CYCLE COUNT ENABLED FLAG"								'||
	'	  ,DECODE(FCLU_ITT.MEANING,null,null,												'||
	'		(FCLU_ITT.MEANING || '' ('' || MSIB.ITEM_TYPE || '')''))		"ITEM TYPE"					'||
	'	  ,MSIB.MODEL_CONFIG_CLAUSE_NAME	"MODEL CONFIG CLAUSE NAME"								'||
	'	  ,MSIB.SHIP_MODEL_COMPLETE_FLAG	"SHIP MODEL COMPLETE FLAG"								'||
	'	  ,DECODE(MLU_MPC.MEANING,null,null,												'||
	'		(MLU_MPC.MEANING || '' ('' || MSIB.MRP_PLANNING_CODE || '')''))		"MRP PLANNING CODE"				'||
	'	  ,MSIB.RETURN_INSPECTION_REQUIREMENT	"RETURN INSPECTION REQUIREMENT"								'||
	'	  ,DECODE(MLU_AFOC.MEANING,null,null,												'||
	'		(MLU_AFOC.MEANING || '' ('' || MSIB.ATO_FORECAST_CONTROL || '')''))	"ATO FORECAST CONTROL"				'||
	'	  ,DECODE(MLU_RTFC.MEANING,null,null,												'||
	'		(MLU_RTFC.MEANING || '' ('' || MSIB.RELEASE_TIME_FENCE_CODE || '')''))	"RELEASE TIME FENCE CODE"			'||
	'	  ,MSIB.RELEASE_TIME_FENCE_DAYS		"RELEASE TIME FENCE DAYS"								'||
	'	  ,MSIB.CONTAINER_ITEM_FLAG		"CONTAINER ITEM FLAG"									'||
	'	  ,MSIB.VEHICLE_ITEM_FLAG		"VEHICLE ITEM FLAG"									'||
	'	  ,MSIB.MAXIMUM_LOAD_WEIGHT		"MAXIMUM LOAD WEIGHT"									'||
	'	  ,MSIB.MINIMUM_FILL_PERCENT		"MINIMUM FILL PERCENT"									'||
	'	  ,DECODE(FCLU_CTC.MEANING,null,null,												'||
	'		(FCLU_CTC.MEANING || '' ('' || MSIB.CONTAINER_TYPE_CODE || '')''))	"CONTAINER TYPE CODE"				'||
	'	  ,MSIB.INTERNAL_VOLUME			"INTERNAL VOLUME"									'||
	'	  ,to_char(MSIB.WH_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'')	"WH UPDATE DATE"						'||
	'	  ,MSIB.PRODUCT_FAMILY_ITEM_ID		"PRODUCT FAMILY ITEM ID"								'||
	'	  ,MSIB.GLOBAL_ATTRIBUTE_CATEGORY	"GLOBAL ATTRIBUTE CATEGORY"								'||
	'	  ,MSIB.GLOBAL_ATTRIBUTE1		"GLOBAL ATTRIBUTE1"									'||
	'	  ,MSIB.GLOBAL_ATTRIBUTE2		"GLOBAL ATTRIBUTE2"									'||
	'	  ,MSIB.GLOBAL_ATTRIBUTE3		"GLOBAL ATTRIBUTE3"									'||
	'	  ,MSIB.GLOBAL_ATTRIBUTE4		"GLOBAL ATTRIBUTE4"									'||
	'	  ,MSIB.GLOBAL_ATTRIBUTE5		"GLOBAL ATTRIBUTE5"									'||
	'	FROM   mtl_system_items_b msib, mtl_item_flexfields mif										'||
	'		,mtl_parameters mp													'||
	'		,MFG_LOOKUPS MLU_AULC													'||
	'		,MFG_LOOKUPS MLU_IPC													'||
	'		,MFG_LOOKUPS MLU_PMBC													'||
	'		,MFG_LOOKUPS MLU_RCT													'||
	'		,MFG_LOOKUPS MLU_MSSC													'||
	'		,CS_LOOKUPS CLU_MBF													'||
	'		,PO_LOOKUP_CODES PLU_OOUT												'||
	'		,MFG_LOOKUPS MLU_ARM													'||
	'		,FND_COMMON_LOOKUPS FCLU_ITT												'||
	'		,MFG_LOOKUPS MLU_MPC													'||
	'		,MFG_LOOKUPS MLU_AFOC													'||
	'		,MFG_LOOKUPS MLU_RTFC													'||
	'		,FND_COMMON_LOOKUPS FCLU_CTC												'||
	'	where 1=1															'||
	'	and 	msib.inventory_item_id= mif.inventory_item_id										'||
	'	and 	msib.organization_id = mif.organization_id										'||
	'	and 	msib.organization_id = mp.organization_id										'||
	'	and 	mif.organization_id =  mp.organization_id										'||
	'	and 	msib.ALLOWED_UNITS_LOOKUP_CODE=MLU_AULC.LOOKUP_CODE(+) AND ''MTL_CONVERSION_TYPE''=MLU_AULC.LOOKUP_TYPE(+)		'||
	'	and 	msib.INVENTORY_PLANNING_CODE=MLU_IPC.LOOKUP_CODE(+) AND ''MTL_MATERIAL_PLANNING''=MLU_IPC.LOOKUP_TYPE(+)		'||
	'	and 	msib.PLANNING_MAKE_BUY_CODE=MLU_PMBC.LOOKUP_CODE(+) AND ''MTL_PLANNING_MAKE_BUY''=MLU_PMBC.LOOKUP_TYPE(+)		'||
	'	and 	msib.ROUNDING_CONTROL_TYPE=MLU_RCT.LOOKUP_CODE(+) AND ''MTL_ROUTING''=MLU_RCT.LOOKUP_TYPE(+)				'||
	'	and	msib.MRP_SAFETY_STOCK_CODE=MLU_MSSC.LOOKUP_CODE(+) AND ''MTL_SAFETY_STOCK_TYPE''=MLU_MSSC.LOOKUP_TYPE(+)		'||
	'	and 	msib.MATERIAL_BILLABLE_FLAG=CLU_MBF.LOOKUP_CODE(+) AND ''MTL_SERVICE_BILLABLE_FLAG''=CLU_MBF.LOOKUP_TYPE(+)		'||
	'	and 	msib.OUTSIDE_OPERATION_UOM_TYPE=PLU_OOUT.LOOKUP_CODE(+) AND ''OUTSIDE OPERATION UOM TYPE''=PLU_OOUT.LOOKUP_TYPE(+)	'||
	'	and 	msib.AUTO_REDUCE_MPS=MLU_ARM.LOOKUP_CODE(+) AND ''MRP_AUTO_REDUCE_MPS''=MLU_ARM.LOOKUP_TYPE(+)				'||
	'	and 	msib.ITEM_TYPE=FCLU_ITT.LOOKUP_CODE(+) AND ''ITEM_TYPE''=FCLU_ITT.LOOKUP_TYPE(+)					'||
	'	and 	msib.MRP_PLANNING_CODE=MLU_MPC.LOOKUP_CODE(+) AND ''MRP_PLANNING_CODE''=MLU_MPC.LOOKUP_TYPE(+)				'||
	'	and	msib.ATO_FORECAST_CONTROL=MLU_AFOC.LOOKUP_CODE(+) AND ''MRP_ATO_FORECAST_CONTROL''=MLU_AFOC.LOOKUP_TYPE(+)		'||
	'	and 	msib.RELEASE_TIME_FENCE_CODE=MLU_RTFC.LOOKUP_CODE(+) AND ''MTL_RELEASE_TIME_FENCE''=MLU_RTFC.LOOKUP_TYPE(+)		'||
	'	and 	msib.CONTAINER_TYPE_CODE=FCLU_CTC.LOOKUP_CODE(+) AND ''CONTAINER_TYPE_CODE''=FCLU_CTC.LOOKUP_TYPE(+)			';

	if l_org_id is not null then
	   sqltxt :=sqltxt||' and msib.organization_id =  '||l_org_id;
	end if;

	if l_item_id is not null then
	   sqltxt :=sqltxt||' and msib.inventory_item_id =  '||l_item_id;
	end if;

	sqltxt :=sqltxt||' and rownum <   '||row_limit;
	sqltxt :=sqltxt||' order by  mp.organization_code,mif.padded_item_number';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Item Attributes (Contd 2..)');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;
	statusStr := 'SUCCESS';
	isFatal := 'FALSE';

sqltxt := '	SELECT ' ||
	'	   MIF.PADDED_ITEM_NUMBER			"ITEM NUMBER"									'||
	'	  ,MSIB.INVENTORY_ITEM_ID			"ITEM ID"											'||
	'	  ,MP.ORGANIZATION_CODE				"ORG CODE"									'||
	'	  ,MSIB.ORGANIZATION_ID				"ORG ID"										'||
	'	  ,MSIB.GLOBAL_ATTRIBUTE6		"GLOBAL ATTRIBUTE6"									'||
	'	  ,MSIB.GLOBAL_ATTRIBUTE7		"GLOBAL ATTRIBUTE7"									'||
	'	  ,MSIB.GLOBAL_ATTRIBUTE8		"GLOBAL ATTRIBUTE8"									'||
	'	  ,MSIB.GLOBAL_ATTRIBUTE9		"GLOBAL ATTRIBUTE9"									'||
	'	  ,MSIB.GLOBAL_ATTRIBUTE10		"GLOBAL ATTRIBUTE10"									'||
	'	  ,MSIB.PURCHASING_TAX_CODE			"PURCHASING TAX CODE"						'||
	'	  ,MSIB.OVERCOMPLETION_TOLERANCE_TYPE		"OVERCOMPLETION TOLERANCE TYPE"			'||
	'	  ,MSIB.OVERCOMPLETION_TOLERANCE_VALUE		"OVERCOMPLETION TOLERANCE VALUE"		'||
	'	  ,MSIB.EFFECTIVITY_CONTROL			"EFFECTIVITY CONTROL"							'||
	'	  ,MSIB.CHECK_SHORTAGES_FLAG			"CHECK SHORTAGES FLAG"						'||
	'	  ,MSIB.OVER_SHIPMENT_TOLERANCE			"OVER SHIPMENT TOLERANCE"				'||
	'	  ,MSIB.UNDER_SHIPMENT_TOLERANCE		"UNDER SHIPMENT TOLERANCE"					'||
	'	  ,MSIB.OVER_RETURN_TOLERANCE			"OVER RETURN TOLERANCE"						'||
	'	  ,MSIB.UNDER_RETURN_TOLERANCE			"UNDER RETURN TOLERANCE"					'||
	'	  ,MSIB.EQUIPMENT_TYPE				"EQUIPMENT TYPE"									'||
	'	  ,MSIB.RECOVERED_PART_DISP_CODE		"RECOVERED PART DISP CODE"					'||
	'	  ,MSIB.DEFECT_TRACKING_ON_FLAG			"DEFECT TRACKING ON FLAG"					'||
	'	  ,MSIB.USAGE_ITEM_FLAG				"USAGE ITEM FLAG"								'||
	'	  ,MSIB.EVENT_FLAG				"EVENT FLAG"											'||
	'	  ,MSIB.ELECTRONIC_FLAG				"ELECTRONIC FLAG"								'||
	'	  ,MSIB.DOWNLOADABLE_FLAG			"DOWNLOADABLE FLAG"							'||
	'	  ,MSIB.VOL_DISCOUNT_EXEMPT_FLAG		"VOL DISCOUNT EXEMPT FLAG"					'||
	'	  ,MSIB.COUPON_EXEMPT_FLAG			"COUPON EXEMPT FLAG"							'||
	'	  ,MSIB.COMMS_NL_TRACKABLE_FLAG			"COMMS NL TRACKABLE FLAG"					'||
	'	  ,MSIB.ASSET_CREATION_CODE			"ASSET CREATION CODE"							'||
	'	  ,MSIB.COMMS_ACTIVATION_REQD_FLAG		"COMMS ACTIVATION REQD FLAG"				'||
	'	  ,MSIB.ORDERABLE_ON_WEB_FLAG			"ORDERABLE ON WEB FLAG"					'||
	'	  ,MSIB.BACK_ORDERABLE_FLAG			"BACK ORDERABLE FLAG"							'||
	'	  ,MSIB.WEB_STATUS				"WEB STATUS"										'||
	'	  ,MSIB.INDIVISIBLE_FLAG			"INDIVISIBLE FLAG"									'||
	'	  ,MSIB.DIMENSION_UOM_CODE			"DIMENSION UOM CODE"							'||
	'	  ,MSIB.UNIT_LENGTH				"UNIT LENGTH"										'||
	'	  ,MSIB.UNIT_WIDTH				"UNIT WIDTH"										'||
	'	  ,MSIB.UNIT_HEIGHT				"UNIT HEIGHT"										'||
	'	  ,MSIB.BULK_PICKED_FLAG			"BULK PICKED FLAG"								'||
	'	  ,MSIB.LOT_STATUS_ENABLED			"LOT STATUS ENABLED"								'||
	'	  ,MSIB.DEFAULT_LOT_STATUS_ID			"DEFAULT LOT STATUS ID"							    '||
	'	  ,MSIB.SERIAL_STATUS_ENABLED			"SERIAL STATUS ENABLED"							    '||
	'	  ,MSIB.DEFAULT_SERIAL_STATUS_ID		"DEFAULT SERIAL STATUS ID"						    '||
	'	  ,MSIB.LOT_SPLIT_ENABLED			"LOT SPLIT ENABLED"							    '||
	'	  ,MSIB.LOT_MERGE_ENABLED			"LOT MERGE ENABLED"							    '||
	'	  ,MSIB.INVENTORY_CARRY_PENALTY			"INVENTORY CARRY PENALTY"						    '||
	'	  ,MSIB.OPERATION_SLACK_PENALTY			"OPERATION SLACK PENALTY"						    '||
	'	  ,MSIB.FINANCING_ALLOWED_FLAG			"FINANCING ALLOWED FLAG"						    '||
	'	  ,MSIB.EAM_ITEM_TYPE				"EAM ITEM TYPE"								    '||
	'	  ,MSIB.EAM_ACTIVITY_TYPE_CODE			"EAM ACTIVITY TYPE CODE"						    '||
	'	  ,MSIB.EAM_ACTIVITY_CAUSE_CODE			"EAM ACTIVITY CAUSE CODE"						    '||
	'	  ,MSIB.EAM_ACT_NOTIFICATION_FLAG		"EAM ACT NOTIFICATION FLAG"						    '||
	'	  ,MSIB.EAM_ACT_SHUTDOWN_STATUS			"EAM ACT SHUTDOWN STATUS"						    '||
	'	  ,MSIB.DUAL_UOM_CONTROL			"DUAL UOM CONTROL"							    '||
	'	  ,MSIB.SECONDARY_UOM_CODE			"SECONDARY UOM CODE"							    '||
	'	  ,MSIB.DUAL_UOM_DEVIATION_HIGH			"DUAL UOM DEVIATION HIGH"						    '||
	'	  ,MSIB.DUAL_UOM_DEVIATION_LOW			"DUAL UOM DEVIATION LOW"						    '||
	'	  ,MSIB.CONTRACT_ITEM_TYPE_CODE			"CONTRACT ITEM TYPE CODE"						    '||
	'	  ,MSIB.SUBSCRIPTION_DEPEND_FLAG		"SUBSCRIPTION DEPEND FLAG"						    '||
	'	  ,MSIB.SERV_REQ_ENABLED_CODE			"SERV REQ ENABLED CODE"							    '||
	'	  ,MSIB.SERV_BILLING_ENABLED_FLAG		"SERV BILLING ENABLED FLAG"						    '||
	'	  ,MSIB.SERV_IMPORTANCE_LEVEL			"SERV IMPORTANCE LEVEL"							    '||
	'	  ,MSIB.PLANNED_INV_POINT_FLAG			"PLANNED INV POINT FLAG"						    '||
	'	  ,MSIB.LOT_TRANSLATE_ENABLED			"LOT TRANSLATE ENABLED"							    '||
	'	  ,MSIB.DEFAULT_SO_SOURCE_TYPE			"DEFAULT SO SOURCE TYPE"						    '||
	'	  ,MSIB.CREATE_SUPPLY_FLAG			"CREATE SUPPLY FLAG"							    '||
	'	  ,MSIB.SUBSTITUTION_WINDOW_CODE		"SUBSTITUTION WINDOW CODE"						    '||
	'	  ,MSIB.SUBSTITUTION_WINDOW_DAYS		"SUBSTITUTION WINDOW DAYS"						    '||
	'	  ,MSIB.IB_ITEM_INSTANCE_CLASS			"IB ITEM INSTANCE CLASS"						    '||
	'	  ,MSIB.CONFIG_MODEL_TYPE			"CONFIG MODEL TYPE"							    '||
	'	  ,MSIB.LOT_SUBSTITUTION_ENABLED		"LOT SUBSTITUTION ENABLED"						    '||
	'	  ,MSIB.MINIMUM_LICENSE_QUANTITY		"MINIMUM LICENSE QUANTITY"						    '||
	'	  ,MSIB.EAM_ACTIVITY_SOURCE_CODE		"EAM ACTIVITY SOURCE CODE"						    '||
	'	  ,MSIB.LIFECYCLE_ID				"LIFECYCLE ID"								    '||
	'	  ,MSIB.CURRENT_PHASE_ID			"CURRENT PHASE ID"							    '||
	'	  ,MSIB.OBJECT_VERSION_NUMBER			"OBJECT VERSION NUMBER"							    '||
	'	  ,MSIB.TRACKING_QUANTITY_IND			"TRACKING QUANTITY IND"							    '||
	'	  ,MSIB.ONT_PRICING_QTY_SOURCE			"ONT PRICING QTY SOURCE"						    '||
	'	  ,MSIB.SECONDARY_DEFAULT_IND			"SECONDARY DEFAULT IND"							    '||
	'	  ,MSIB.OPTION_SPECIFIC_SOURCED			"OPTION SPECIFIC SOURCED"						    '||
	'	  ,MSIB.APPROVAL_STATUS				"APPROVAL STATUS"							    '||
	'	  ,MSIB.VMI_MINIMUM_UNITS			"VMI MINIMUM UNITS"							    '||
	'	  ,MSIB.VMI_MINIMUM_DAYS			"VMI MINIMUM DAYS"							    '||
	'	  ,MSIB.VMI_MAXIMUM_UNITS			"VMI MAXIMUM UNITS"							    '||
	'	  ,MSIB.VMI_MAXIMUM_DAYS			"VMI MAXIMUM DAYS"							    '||
	'	  ,MSIB.VMI_FIXED_ORDER_QUANTITY		"VMI FIXED ORDER QUANTITY"						    '||
	'	  ,MSIB.SO_AUTHORIZATION_FLAG			"SO AUTHORIZATION FLAG"							    '||
	'	  ,MSIB.CONSIGNED_FLAG				"CONSIGNED FLAG"							    '||
	'	  ,MSIB.ASN_AUTOEXPIRE_FLAG			"ASN AUTOEXPIRE FLAG"							    '||
	'	  ,MSIB.VMI_FORECAST_TYPE			"VMI FORECAST TYPE"							    '||
	'	  ,MSIB.FORECAST_HORIZON			"FORECAST HORIZON"							    '||
	'	  ,MSIB.EXCLUDE_FROM_BUDGET_FLAG		"EXCLUDE FROM BUDGET FLAG"						    '||
	'	  ,MSIB.DAYS_TGT_INV_SUPPLY			"DAYS TGT INV SUPPLY"							    '||
	'	  ,MSIB.DAYS_TGT_INV_WINDOW			"DAYS TGT INV WINDOW"							    '||
	'	  ,MSIB.DAYS_MAX_INV_SUPPLY			"DAYS MAX INV SUPPLY"							    '||
	'	  ,MSIB.DAYS_MAX_INV_WINDOW			"DAYS MAX INV WINDOW"							    '||
	'	  ,MSIB.DRP_PLANNED_FLAG			"DRP PLANNED FLAG"							    '||
	'	  ,MSIB.CRITICAL_COMPONENT_FLAG			"CRITICAL COMPONENT FLAG"						    '||
	'	  ,MSIB.CONTINOUS_TRANSFER			"CONTINOUS TRANSFER"							    '||
	'	  ,MSIB.CONVERGENCE				"CONVERGENCE"								    '||
	'	  ,MSIB.DIVERGENCE				"DIVERGENCE"								    '||
	'	  ,MSIB.CONFIG_ORGS				"CONFIG ORGS"								    '||
	'	  ,MSIB.CONFIG_MATCH				"CONFIG MATCH"								    '||
	'	FROM   mtl_system_items_b msib , mtl_item_flexfields mif								    '||
	'		,mtl_parameters mp												    '||
	'	where 1=1														    '||
	'	and 	msib.inventory_item_id= mif.inventory_item_id									    '||
	'	and 	msib.organization_id = mif.organization_id									    '||
	'	and 	msib.organization_id = mp.organization_id									    '||
	'	and 	mif.organization_id =  mp.organization_id									    ';

	if l_org_id is not null then
	   sqltxt :=sqltxt||' and msib.organization_id =  '||l_org_id;
	end if;

	if l_item_id is not null then
	   sqltxt :=sqltxt||' and msib.inventory_item_id =  '||l_item_id;
	end if;

	sqltxt :=sqltxt||' and rownum <   '||row_limit;
	sqltxt :=sqltxt||' order by  mp.organization_code ,mif.padded_item_number';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Item Attributes (Contd 3..)');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;
	statusStr := 'SUCCESS';
	isFatal := 'FALSE';

sqltxt := '	SELECT ' ||
	'	   MIF.PADDED_ITEM_NUMBER				"ITEM NUMBER"					'||
	'	  ,MSIB.INVENTORY_ITEM_ID				"ITEM ID"							'||
	'	  ,MP.ORGANIZATION_CODE				"ORG CODE"						'||
	'	  ,MSIB.ORGANIZATION_ID				"ORG ID"							'||
	'	  ,MSIB.ATTRIBUTE16					"ATTRIBUTE16"						'||
	'	  ,MSIB.ATTRIBUTE17					"ATTRIBUTE17"						'||
	'	  ,MSIB.ATTRIBUTE18					"ATTRIBUTE18"						'||
	'	  ,MSIB.ATTRIBUTE19					"ATTRIBUTE19"						'||
	'	  ,MSIB.ATTRIBUTE20					"ATTRIBUTE20"						'||
	'	  ,MSIB.ATTRIBUTE21					"ATTRIBUTE21"						'||
	'	  ,MSIB.ATTRIBUTE22					"ATTRIBUTE22"						'||
	'	  ,MSIB.ATTRIBUTE23					"ATTRIBUTE23"						'||
	'	  ,MSIB.ATTRIBUTE24					"ATTRIBUTE24"						'||
	'	  ,MSIB.ATTRIBUTE25					"ATTRIBUTE25"						'||
	'	  ,MSIB.ATTRIBUTE26					"ATTRIBUTE26"						'||
	'	  ,MSIB.ATTRIBUTE27					"ATTRIBUTE27"						'||
	'	  ,MSIB.ATTRIBUTE28					"ATTRIBUTE28"						'||
	'	  ,MSIB.ATTRIBUTE29					"ATTRIBUTE29"						'||
	'	  ,MSIB.ATTRIBUTE30					"ATTRIBUTE30"						'||
	'	  ,MSIB.CAS_NUMBER					"CAS NUMBER"						'||
	'	  ,MSIB.CHILD_LOT_FLAG					"CHILD LOT FLAG"					'||
	'	  ,MSIB.CHILD_LOT_PREFIX				"CHILD LOT PREFIX"					'||
	'	  ,MSIB.CHILD_LOT_STARTING_NUMBER		"CHILD LOT STARTING NUMBER"		'||
	'	  ,MSIB.CHILD_LOT_VALIDATION_FLAG		"CHILD LOT VALIDATION FLAG"		'||
	'	  ,MSIB.COPY_LOT_ATTRIBUTE_FLAG		"CHILD LOT ATTRIBUTE FLAG"			'||
	'	  ,MSIB.DEFAULT_GRADE					"DEFAULT GRADE"					'||
	'	  ,MSIB.EXPIRATION_ACTION_CODE			"EXPIRATION ACTION CODE"			'||
	'	  ,MSIB.EXPIRATION_ACTION_INTERVAL		"EXPIRATION ACTION INTERVAL"		'||
	'	  ,MSIB.GRADE_CONTROL_FLAG			"GRADE CONTROL FLAG"				'||
	'	  ,MSIB.HAZARDOUS_MATERIAL_FLAG		"HAZARDOUS MATERIAL FLAG"			'||
	'	  ,MSIB.HOLD_DAYS						"HOLD DAYS"						'||
	'	  ,MSIB.LOT_DIVISIBLE_FLAG				"LOT DIVISIBLE FLAG"				'||
	'	  ,MSIB.MATURITY_DAYS					"MATURITY DAYS"					'||
	'	  ,MSIB.PARENT_CHILD_GENERATION_FLAG	"PARENT CHILD GENERATION FLAG"		'||
	'	  ,MSIB.PROCESS_COSTING_ENABLED_FLAG	"PROCESS COSTING ENABLED FLAG"	'||
	'	  ,MSIB.PROCESS_EXECUTION_ENABLED_FLAG"PROCESS EXECUTION ENABLED FLAG"	'||
	'	  ,MSIB.PROCESS_QUALITY_ENABLED_FLAG     "PROCESS QUALITY ENABLED FLAG"	'||
	'	  ,MSIB.PROCESS_SUPPLY_LOCATOR_ID		"PROCESS SUPPLY LOCATOR ID"		'||
	'	  ,MSIB.PROCESS_SUPPLY_SUBINVENTORY	"PROCESS SUPPLY SUBINVENTORY"		'||
	'	  ,MSIB.PROCESS_YIELD_LOCATOR_ID		"PROCESS YIELD LOCATOR ID"		'||
	'	  ,MSIB.PROCESS_YIELD_SUBINVENTORY		"PROCESS YIELD SUBINVENTORY"		'||
	'	  ,MSIB.RECIPE_ENABLED_FLAG			"RECIPE ENABLED FLAG"				'||
	'	  ,MSIB.RETEST_INTERVAL				"RETEST INTERVAL"					'||
	'	  ,MSIB.CHARGE_PERIODICITY_CODE		"CHARGE PERIODICITY CODE"			'||
	'	  ,MSIB.REPAIR_LEADTIME				"REPAIR LEADTIME"					'||
	'	  ,MSIB.REPAIR_YIELD					"REPAIR YIELD"					'||
	'	  ,MSIB.PREPOSITION_POINT				"PREPOSITION POINT"				'||
	'	  ,MSIB.REPAIR_PROGRAM				"REPAIR PROGRAM"					'||
	'	  ,MSIB.SUBCONTRACTING_COMPONENT		"SUBCONTRACTING COMPONENT"		'||
	'	  ,MSIB.OUTSOURCED_ASSEMBLY			"OUTSOURCED ASSEMBLY"			'||
	'	FROM   mtl_system_items_b msib , mtl_item_flexfields mif						'||
	'		,mtl_parameters mp													'||
	'	where 1=1															'||
	'	and 	msib.inventory_item_id= mif.inventory_item_id							'||
	'	and 	msib.organization_id = mif.organization_id								'||
	'	and 	msib.organization_id = mp.organization_id								'||
	'	and 	mif.organization_id =  mp.organization_id								';

	if l_org_id is not null then
	   sqltxt :=sqltxt||' and msib.organization_id =  '||l_org_id;
	end if;

	if l_item_id is not null then
	   sqltxt :=sqltxt||' and msib.inventory_item_id =  '||l_item_id;
	end if;

	sqltxt :=sqltxt||' and rownum <   '||row_limit;
	sqltxt :=sqltxt||' order by  mp.organization_code ,mif.padded_item_number';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Item Attributes (Contd 4..)');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;

	statusStr := 'SUCCESS';
	isFatal := 'FALSE';

/* End of sql to fetch rows in mtl_system_items_b */

/* SQL to fetch rows in mtl_system_items_tl table */
sqltxt := 'SELECT								'||
	'	   MIF1.PADDED_ITEM_NUMBER	"ITEM NUMBER"			'||
	'	  ,MSITL.INVENTORY_ITEM_ID	"ITEM ID"	     	 	'||
	'	  ,MP1.ORGANIZATION_CODE 	"ORGANIZATION CODE"	 	'||
	'	  ,MSITL.ORGANIZATION_ID	"ORG ID"	     	 	'||
	'	  ,MSITL.LANGUAGE		"LANGUAGE"		 	'||
	'	  ,MSITL.SOURCE_LANG		"SOURCE LANG"	     	 	'||
	'	  ,MSITL.DESCRIPTION		"DESCRIPTION"	     	 	'||
	'	  ,MSITL.LONG_DESCRIPTION	"LONG DESCRIPTION"   	 	'||
	' FROM	   MTL_SYSTEM_ITEMS_TL MSITL			      		'||
	'	  ,MTL_PARAMETERS MP1				 		'||
	'	  ,MTL_ITEM_FLEXFIELDS MIF1  			 		'||
	' WHERE		1=1							'||
	' AND 		MSITL.ORGANIZATION_ID    = MP1.ORGANIZATION_ID		'||
	' AND 		MSITL.INVENTORY_ITEM_ID  = MIF1.INVENTORY_ITEM_ID	'||
	' AND 		MSITL.ORGANIZATION_ID 	 = MIF1.ORGANIZATION_ID		';


	if l_org_id is not null then
	   sqltxt :=sqltxt||' and msitl.organization_id =  '||l_org_id;
	end if;

	if l_item_id is not null then
	   sqltxt :=sqltxt||' and msitl.inventory_item_id =  '||l_item_id;
	end if;

	sqltxt :=sqltxt||' and rownum <   '||row_limit;
	sqltxt :=sqltxt||' order by mp1.organization_code, mif1.padded_item_number, msitl.language';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Item Translation Details');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;

	statusStr := 'SUCCESS';
	isFatal := 'FALSE';

/* End of mtl_system_items_tl rows */

/* SQL to fetch item revisions */
sqltxt := 'SELECT								     '||
	'     MIF1.PADDED_ITEM_NUMBER	       "ITEM NUMBER"			     '||
	'    ,MIRB.INVENTORY_ITEM_ID	       "ITEM ID"			     '||
	'    ,MP1.ORGANIZATION_CODE 	       "ORGANIZATION CODE"		     '||
	'    ,MIRB.ORGANIZATION_ID	       "ORGANIZATION ID"		     '||
	'    ,MIRB.REVISION		       "REVISION"			     '||
	'    ,to_char(MIRB.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'')  "LAST UPDATE DATE" '||
	'    ,MIRB.LAST_UPDATED_BY	       "LAST UPDATED BY"		     '||
	'    ,to_char(MIRB.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'')	"CREATION DATE"	 '||
	'    ,MIRB.CREATED_BY		       "CREATED BY"			     '||
	'    ,MIRB.LAST_UPDATE_LOGIN	       "LAST UPDATE LOGIN"		     '||
	'    ,MIRB.CHANGE_NOTICE		"CHANGE NOTICE"				'||
	'    ,to_char(MIRB.ECN_INITIATION_DATE,''DD-MON-YYYY HH24:MI:SS'') "ECN INITIATION DATE" '||
	'    ,to_char(MIRB.IMPLEMENTATION_DATE,''DD-MON-YYYY HH24:MI:SS'') "IMPLEMENTATION DATE" '||
	'    ,MIRB.IMPLEMENTED_SERIAL_NUMBER    "IMPLEMENTED SERIAL NUMBER"	     '||
	'    ,to_char(MIRB.EFFECTIVITY_DATE,''DD-MON-YYYY HH24:MI:SS'')	   "EFFECTIVITY DATE"	 '||
	'    ,MIRB.ATTRIBUTE_CATEGORY	       "ATTRIBUTE CATEGORY"		     '||
	'    ,MIRB.ATTRIBUTE1		       "ATTRIBUTE1"			     '||
	'    ,MIRB.ATTRIBUTE2		       "ATTRIBUTE2"			     '||
	'    ,MIRB.ATTRIBUTE3		       "ATTRIBUTE3"			     '||
	'    ,MIRB.ATTRIBUTE4		       "ATTRIBUTE4"			     '||
	'    ,MIRB.ATTRIBUTE5		       "ATTRIBUTE5"			     '||
	'    ,MIRB.ATTRIBUTE6		       "ATTRIBUTE6"			     '||
	'    ,MIRB.ATTRIBUTE7		       "ATTRIBUTE7"			     '||
	'    ,MIRB.ATTRIBUTE8		       "ATTRIBUTE8"			     '||
	'    ,MIRB.ATTRIBUTE9		       "ATTRIBUTE9"			     '||
	'    ,MIRB.ATTRIBUTE10		       "ATTRIBUTE10"			     '||
	'    ,MIRB.ATTRIBUTE11		       "ATTRIBUTE11"			     '||
	'    ,MIRB.ATTRIBUTE12		       "ATTRIBUTE12"			     '||
	'    ,MIRB.ATTRIBUTE13		       "ATTRIBUTE13"			     '||
	'    ,MIRB.ATTRIBUTE14		       "ATTRIBUTE14"			     '||
	'    ,MIRB.ATTRIBUTE15		       "ATTRIBUTE15"			     '||
	'    ,MIRB.REQUEST_ID		       "REQUEST ID"			     '||
	'    ,MIRB.PROGRAM_APPLICATION_ID      "PROGRAM APPLICATION ID" 	     '||
	'    ,MIRB.PROGRAM_ID		       "PROGRAM ID"			     '||
	'    ,to_char(MIRB.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "PROGRAM UPDATE DATE" '||
	'    ,MIRB.REVISED_ITEM_SEQUENCE_ID    "REVISED ITEM SEQUENCE ID"	     '||
	'    ,MIRB.DESCRIPTION		       "DESCRIPTION"			     '||
	'    ,MIRB.OBJECT_VERSION_NUMBER	"OBJECT VERSION NUMBER"		     '||
	'    ,MIRB.REVISION_ID		       "REVISION ID"			     '||
	'    ,MIRB.REVISION_LABEL	       "REVISION LABEL"			     '||
	'    ,MIRB.REVISION_REASON	       "REVISION REASON"		     '||
	'    ,MIRB.LIFECYCLE_ID		       "LIFECYCLE ID"			     '||
	'    ,MIRB.CURRENT_PHASE_ID	       "CURRENT PHASE ID"		     '||
	' FROM  MTL_ITEM_REVISIONS_B MIRB					     '||
	'	,MTL_PARAMETERS MP1						     '||
	'	,MTL_ITEM_FLEXFIELDS MIF1					     '||
	' WHERE 1=1								     '||
	' AND	MIRB.ORGANIZATION_ID 	 = MP1.ORGANIZATION_ID			'||
	' AND	MIRB.INVENTORY_ITEM_ID 	 = MIF1.INVENTORY_ITEM_ID		'||
	' AND	MIRB.ORGANIZATION_ID 	 = MIF1.ORGANIZATION_ID			';

	if l_org_id is not null then
		sqltxt :=sqltxt||' and mirb.organization_id =  '||l_org_id;
	end if;

	if l_item_id is not null then
		sqltxt :=sqltxt||' and mirb.inventory_item_id =  '||l_item_id;
	end if;

	sqltxt :=sqltxt||' and rownum <   '||row_limit;
	sqltxt :=sqltxt||' order by mp1.organization_code, mif1.padded_item_number, mirb.revision';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Item Revisions');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;

	statusStr := 'SUCCESS';
	isFatal := 'FALSE';

/* End of item revisions */

/* SQL to fetch item revisions TL */
sqltxt := '	SELECT   ' ||
	' 	   MIF1.PADDED_ITEM_NUMBER	    "ITEM NUMBER"		      	'||
	' 	   ,MIRTL.INVENTORY_ITEM_ID	    "INVENTORY ITEM ID"	      		'||
	' 	   ,MP1.ORGANIZATION_CODE 	    "ORGANIZATION CODE"       	      	'||
	' 	   ,MIRTL.ORGANIZATION_ID	    "ORGANIZATION ID"	       	      	'||
	' 	   ,MIRTL.REVISION_ID		    "REVISION ID"	       	      	'||
	' 	   ,MIRTL.LANGUAGE		    "LANGUAGE"		       	      	'||
	' 	   ,MIRTL.SOURCE_LANG		    "SOURCE LANG"	       	      	'||
	' 	   ,MIRTL.DESCRIPTION		    "DESCRIPTION"	       	      	'||
	' 	   ,to_char(MIRTL.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'') "CREATION DATE" '||
	' 	   ,MIRTL.CREATED_BY		    "CREATED BY"	       	      	'||
	' 	   ,to_char(MIRTL.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "LAST UPDATE DATE" '||
	' 	   ,MIRTL.LAST_UPDATED_BY	    "LAST UPDATED BY"	       	      	'||
	' 	   ,MIRTL.LAST_UPDATE_LOGIN	    "LAST UPDATE LOGIN"	       	      	'||
	' 	FROM MTL_ITEM_REVISIONS_TL MIRTL				      	'||
	'		 ,MTL_ITEM_FLEXFIELDS MIF1				      	'||
	'		 ,MTL_PARAMETERS MP1					      	'||
	' 	WHERE 1=1							      	'||
	' 	AND 	MIRTL.ORGANIZATION_ID    = MP1.ORGANIZATION_ID		      	'||
	' 	AND 	MIRTL.INVENTORY_ITEM_ID  = MIF1.INVENTORY_ITEM_ID     		'||
	' 	AND 	MIRTL.ORGANIZATION_ID 	 = MIF1.ORGANIZATION_ID			';


	if l_org_id is not null then
		sqltxt :=sqltxt||' and mirtl.organization_id =  '||l_org_id;
	end if;

	if l_item_id is not null then
		sqltxt :=sqltxt||' and mirtl.inventory_item_id =  '||l_item_id;
	end if;

	sqltxt :=sqltxt||' and rownum <   '||row_limit;
	sqltxt :=sqltxt||' order by mp1.organization_code, mif1.padded_item_number, mirtl.revision_id, mirtl.language';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Item Revision Translation Details');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;

	statusStr := 'SUCCESS';
	isFatal := 'FALSE';

/* End of item revisions TL*/

/* SQL to fetch item catalog descriptive elements */

sqltxt := 'SELECT									'||
	'	  MIF1.PADDED_ITEM_NUMBER	   	"ITEM NUMBER"			'||
	'	  ,MDEV.INVENTORY_ITEM_ID	   	"INVENTORY ITEM ID"		'||
	'	  ,MDEV.ELEMENT_NAME		   	"ELEMENT NAME"			'||
	'	  ,MDEV.ELEMENT_VALUE	   		"ELEMENT VALUE"			'||
	'	  ,to_char(MDEV.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "LAST UPDATE DATE"	'||
	'	  ,MDEV.LAST_UPDATED_BY	   		"LAST UPDATED BY"		'||
	'	  ,to_char(MDEV.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'') "CREATION DATE"	'||
	'	  ,MDEV.CREATED_BY		   	"CREATED BY"			'||
	'	  ,MDEV.LAST_UPDATE_LOGIN	   	"LAST UPDATE LOGIN"		'||
	'	  ,MDEV.REQUEST_ID		   	"REQUEST ID"			'||
	'	  ,MDEV.PROGRAM_APPLICATION_ID  	"PROGRAM APPLICATION ID"	'||
	'	  ,MDEV.PROGRAM_ID		   	"PROGRAM ID"			'||
	'	  ,to_char(MDEV.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'')	"PROGRAM UPDATE DATE" '||
	'	  ,DECODE(MDEV.DEFAULT_ELEMENT_FLAG,null,null,''Y'',''Yes (Y)'',''N'',''No (N)'','||
	'		''OTHER('' || MDEV.DEFAULT_ELEMENT_FLAG || '')'') "DEFAULT ELEMENT FLAG"'||
	'	  ,MDEV.ELEMENT_SEQUENCE	   	"ELEMENT SEQUENCE"		'||
	'  FROM 	 MTL_DESCR_ELEMENT_VALUES MDEV					'||
	'		,MTL_ITEM_FLEXFIELDS MIF1					'||
	'  WHERE 	1=1								'||
	'  AND 		MDEV.INVENTORY_ITEM_ID 	 = MIF1.INVENTORY_ITEM_ID		';


	/* Catalog elements are associated to items always at the master org level.
	   So the filter on org_id is not required. */

	 if l_item_id is not null then
	   sqltxt :=sqltxt||' and mdev.inventory_item_id =  '||l_item_id;
	end if;

	   sqltxt :=sqltxt||' and rownum <   '||row_limit;
	   sqltxt :=sqltxt||' order by mif1.padded_item_number, mdev.element_name';

	   num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Item Catalog Descriptive Elements ');
	   If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	   End If;

	   statusStr := 'SUCCESS';
	   isFatal := 'FALSE';

/* End of item catalog descriptive elements */

/* SQL to fetch pending item statuses */
  sqltxt := '	SELECT										'||
	' 	   MIF1.PADDED_ITEM_NUMBER	   "ITEM NUMBER"				'||
	' 	   ,MPIS.INVENTORY_ITEM_ID	   "INVENTORY ITEM ID"				'||
	' 	   ,MP1.ORGANIZATION_CODE 	   "ORGANIZATION CODE"       			'||
	' 	   ,MPIS.ORGANIZATION_ID	   "ORGANIZATION ID"				'||
	' 	   ,MPIS.STATUS_CODE		   "STATUS CODE"				'||
	' 	   ,to_char(MPIS.EFFECTIVE_DATE,''DD-MON-YYYY HH24:MI:SS'') "EFFECTIVE DATE"	'||
	' 	   ,to_char(MPIS.IMPLEMENTED_DATE,''DD-MON-YYYY HH24:MI:SS'') "IMPLEMENTED DATE"'||
	' 	   ,DECODE(MPIS.PENDING_FLAG,null,null,''Y'',''Yes (Y)'',''N'',''No (N)'',	'||
	'		''OTHER('' || MPIS.PENDING_FLAG || '')'') "PENDING FLAG" 		'||
	' 	   ,to_char(MPIS.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "LAST UPDATE DATE"'||
	' 	   ,MPIS.LAST_UPDATED_BY	   "LAST UPDATED BY"				'||
	' 	   ,to_char(MPIS.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'')"CREATION DATE"	'||
	' 	   ,MPIS.CREATED_BY		   "CREATED BY"					'||
	' 	   ,MPIS.LAST_UPDATE_LOGIN	   "LAST UPDATE LOGIN"				'||
	' 	   ,MPIS.REQUEST_ID		   "REQUEST ID"					'||
	' 	   ,MPIS.PROGRAM_APPLICATION_ID    "PROGRAM APPLICATION ID"			'||
	' 	   ,MPIS.PROGRAM_ID		   "PROGRAM ID"					'||
	' 	   ,to_char(MPIS.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "PROGRAM UPDATE DATE"'||
	' 	   ,MPIS.REVISION_ID		   "REVISION ID"				'||
	' 	   ,MPIS.LIFECYCLE_ID		   "LIFECYCLE ID"				'||
	' 	   ,MPIS.PHASE_ID		   "PHASE ID"					'||
	'	   ,MPIS.CHANGE_ID		   "CHANGE ID"					'||
	'	  ,MPIS.CHANGE_LINE_ID	   "CHANGE LINE ID"					'||
	' 	FROM 	MTL_PENDING_ITEM_STATUS MPIS						'||
	'		,MTL_ITEM_FLEXFIELDS MIF1						'||
	'		,MTL_PARAMETERS MP1							'||
	' 	where 	1=1									'||
	'	AND 	MPIS.INVENTORY_ITEM_ID 	 = MIF1.INVENTORY_ITEM_ID			'||
	'	AND 	MPIS.ORGANIZATION_ID 	 = MIF1.ORGANIZATION_ID				'||
	' 	AND 	MPIS.ORGANIZATION_ID      = MP1.ORGANIZATION_ID				';


	if l_org_id is not null then
	   sqltxt :=sqltxt||' and mpis.organization_id =  '||l_org_id;
	end if;

	if l_item_id is not null then
	   sqltxt :=sqltxt||' and mpis.inventory_item_id =  '||l_item_id;
	end if;

	   sqltxt :=sqltxt||' and rownum <   '||row_limit;
	   sqltxt :=sqltxt||' order by mp1.organization_code, mif1.padded_item_number,  '||
			    '  mpis.effective_date,mpis.status_code	 ';

	   num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Item Pending Statuses ');
	   If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	   End If;

	   statusStr := 'SUCCESS';
	   isFatal := 'FALSE';
/* End of pending item statuses */

/* SQL to fetch item cross references details */
sqltxt := 'SELECT   ' ||
	'	     MIF1.PADDED_ITEM_NUMBER	   "ITEM NUMBER"		 		'||
	'	     ,MCR.INVENTORY_ITEM_ID	   "INVENTORY ITEM ID"		 		'||
	'            ,MP1.ORGANIZATION_CODE 	   "ORGANIZATION CODE"		 		'||
	'	     ,MCR.ORGANIZATION_ID	   "ORGANIZATION ID"		 		'||
	'	     ,MCR.CROSS_REFERENCE_TYPE	   "CROSS REFERENCE TYPE"	 		'||
	'	     ,MCR.CROSS_REFERENCE	   "CROSS REFERENCE"		 		'||
	'	     ,to_char(MCR.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "LAST UPDATE DATE" '||
	'	     ,MCR.LAST_UPDATED_BY	   "LAST UPDATED BY"		 		'||
	'	     ,to_char(MCR.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'')	"CREATION DATE"	'||
	'	     ,MCR.CREATED_BY		   "CREATED BY"		 			'||
	'	     ,MCR.LAST_UPDATE_LOGIN	   "LAST UPDATE LOGIN"		 		'||
	'	     ,MCR.DESCRIPTION		   "DESCRIPTION"		 		'||
	'   	     ,DECODE(MCR.ORG_INDEPENDENT_FLAG,NULL,NULL,''Y'',''Yes (Y)'',''N'',''No (N)'','||
	'		''OTHER ('' || MCR.ORG_INDEPENDENT_FLAG || '')'') "PENDING FLAG" 	'||
	'	     ,MCR.ORG_INDEPENDENT_FLAG	   "ORG INDEPENDENT FLAG"	 		'||
	'	     ,MCR.REQUEST_ID		   "REQUEST ID"		 			'||
	'	     ,MCR.PROGRAM_APPLICATION_ID   "PROGRAM APPLICATION ID"	 		'||
	'	     ,MCR.PROGRAM_ID		   "PROGRAM ID"		 			'||
	'	     ,to_char(MCR.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "PROGRAM UPDATE DATE"	 '||
	'	     ,MCR.ATTRIBUTE1		   "ATTRIBUTE1"		 			'||
	'	     ,MCR.ATTRIBUTE2		   "ATTRIBUTE2"		 			'||
	'	     ,MCR.ATTRIBUTE3		   "ATTRIBUTE3"		 			'||
	'	     ,MCR.ATTRIBUTE4		   "ATTRIBUTE4"		 			'||
	'	     ,MCR.ATTRIBUTE5		   "ATTRIBUTE5"		 			'||
	'	     ,MCR.ATTRIBUTE6		   "ATTRIBUTE6"		 			'||
	'	     ,MCR.ATTRIBUTE7		   "ATTRIBUTE7"		 			'||
	'	     ,MCR.ATTRIBUTE8		   "ATTRIBUTE8"		 			'||
	'	     ,MCR.ATTRIBUTE9		   "ATTRIBUTE9"		 			'||
	'	     ,MCR.ATTRIBUTE10		   "ATTRIBUTE10"		 		'||
	'	     ,MCR.ATTRIBUTE11		   "ATTRIBUTE11"		 		'||
	'	     ,MCR.ATTRIBUTE12		   "ATTRIBUTE12"		 		'||
	'	     ,MCR.ATTRIBUTE13		   "ATTRIBUTE13"		 		'||
	'	     ,MCR.ATTRIBUTE14		   "ATTRIBUTE14"		 		'||
	'	     ,MCR.ATTRIBUTE15		   "ATTRIBUTE15"		 		'||
	'	     ,MCR.ATTRIBUTE_CATEGORY	   "ATTRIBUTE CATEGORY"	 '||
	'	     ,MCR.UOM_CODE		   "UOM CODE"			 		'||
	'	     ,MCR.REVISION_ID		   "REVISION ID"		 		'||
	'	     ,MCR.CROSS_REFERENCE_ID "CROSS REFERENCE ID"		 		'||
	'	     ,MCR.EPC_GTIN_SERIAL	 "EPC GTIN SERIAL"		 		'||
	'	     ,MCR.SOURCE_SYSTEM_ID	 "SOURCE SYSTEM ID"		 		'||
	'	     ,MCR.START_DATE_ACTIVE	 "START DATE ACTIVE"		 		'||
	'	     ,MCR.END_DATE_ACTIVE	 "END DATE ACTIVE"		 		'||
	'	     ,MCR.OBJECT_VERSION_NUMBER	 "OBJECT VERSION NUMBER"	'||
	'	FROM 	 MTL_CROSS_REFERENCES_B MCR				 		'||
	'		,MTL_ITEM_FLEXFIELDS MIF1				 		'||
	'	        ,MTL_PARAMETERS MP1					 		'||
	'	WHERE 	1=1							 		'||
	' 	AND 	MCR.INVENTORY_ITEM_ID   = MIF1.INVENTORY_ITEM_ID	 		'||
	'	AND 	MCR.ORGANIZATION_ID     = MIF1.ORGANIZATION_ID	 			'||
	' 	AND 	MCR.ORGANIZATION_ID     = MP1.ORGANIZATION_ID 				';


	if l_org_id is not null then
	   sqltxt :=sqltxt||' and (  ( mcr.organization_id =  '||l_org_id||' and  org_independent_flag=''N'') '||
			    ' or (     mcr.organization_id is null and org_independent_flag=''Y'') )	';
	end if;

	if l_item_id is not null then
	   sqltxt :=sqltxt||' and mcr.inventory_item_id =  '||l_item_id;
	end if;

	   sqltxt :=sqltxt||' and rownum <   '||row_limit;
	   sqltxt :=sqltxt||' order by  mp1.organization_code, mif1.padded_item_number, '||
			    '  mcr.cross_reference_type,mcr.cross_reference	   ';

	   num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Item Cross References ');
	   If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	   End If;

	   statusStr := 'SUCCESS';
	   isFatal := 'FALSE';
/* End of cross references*/

/* SQL to fetch item translated cross references details */
sqltxt := 'SELECT   ' ||
	'	     MIF1.PADDED_ITEM_NUMBER	   "ITEM NUMBER"		 		'||
	'	     ,MCRB.INVENTORY_ITEM_ID	   "INVENTORY ITEM ID"		 		'||
	'            ,MP1.ORGANIZATION_CODE 	   "ORGANIZATION CODE"		 		'||
	'	     ,MCRB.ORGANIZATION_ID	   "ORGANIZATION ID"		 		'||
	'	     ,MCRB.CROSS_REFERENCE_TYPE	   "CROSS REFERENCE TYPE"	 		'||
	'	     ,MCRB.CROSS_REFERENCE	   "CROSS REFERENCE"		 		'||
	'	     ,MCRT.CROSS_REFERENCE_ID	   "CROSS REFERENCE ID"		 		'||
	'	     ,MCRT.LANGUAGE			   "LANGUAGE"		 		'||
	'	     ,MCRT.SOURCE_LANG			   "SOURCE LANG"		 		'||
	'	     ,MCRT.DESCRIPTION			   "DESCRIPTION"		 		'||
	'	     ,MCRT.CREATION_DATE		   "CREATION DATE"		 		'||
	'	     ,MCRT.CREATED_BY			   "CREATION BY"		 		'||
	'	     ,MCRT.LAST_UPDATE_DATE	 	   "LAST UPDATE DATE"		 	'||
	'	     ,MCRT.LAST_UPDATED_BY	 	   "LAST UPDATED BY"		 	'||
	'	     ,MCRT.LAST_UPDATE_LOGIN 	   "LAST UPDATED LOGIN"		 	'||
	'	FROM 	 MTL_CROSS_REFERENCES_B MCRB				 		'||
	'		,MTL_CROSS_REFERENCES_TL MCRT				'||
	'		,MTL_ITEM_FLEXFIELDS MIF1				 		'||
	'	        ,MTL_PARAMETERS MP1					 		'||
	'	WHERE 	1=1							 		'||
	' 	AND 	MCRB.CROSS_REFERENCE_ID   = MCRT.CROSS_REFERENCE_ID	 		'||
	' 	AND 	MCRB.INVENTORY_ITEM_ID   = MIF1.INVENTORY_ITEM_ID	 		'||
	'	AND 	MCRB.ORGANIZATION_ID     = MIF1.ORGANIZATION_ID	 			'||
	' 	AND 	MCRB.ORGANIZATION_ID     = MP1.ORGANIZATION_ID 				';

	if l_org_id is not null then
	   sqltxt :=sqltxt||' and (  ( MCRB.organization_id =  '||l_org_id||' and  org_independent_flag=''N'') '||
			    ' or (     MCRB.organization_id is null and org_independent_flag=''Y'') )	';
	end if;

	if l_item_id is not null then
	   sqltxt :=sqltxt||' and MCRB.inventory_item_id =  '||l_item_id;
	end if;

	   sqltxt :=sqltxt||' and rownum <   '||row_limit;
	   sqltxt :=sqltxt||' order by  mp1.organization_code, mif1.padded_item_number, '||
			    '  MCRB.cross_reference_type,MCRB.cross_reference,mcrt.cross_reference_id, mcrt.language	   ';

	   num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Item Cross References Transalation Details');
	   If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	   End If;

	   statusStr := 'SUCCESS';
	   isFatal := 'FALSE';

/* End of translated cross references*/


/* SQL to fetch customer item xrefs details*/
/* Customer Items xrefs are defined at the master org level. So get the master_org_id of the input org_id.
If no org_id is input then run the script for all master orgs.*/
sqltxt :=	'	SELECT   ' ||
		'	   MCIX.CUSTOMER_ITEM_NUMBER             "CUSTOMER ITEM NUMBER"	  	  '||
		'	   ,MCIX.CUSTOMER_ITEM_ID		 "CUSTOMER ITEM ID"		  '||
		'	   ,MIF.PADDED_ITEM_NUMBER                "ITEM NUMBER"			  '||
		'	   ,MCIX.INVENTORY_ITEM_ID		 "INVENTORY ITEM ID"		  '||
		'	   ,MP1.organization_code                 "MASTER ORGANIZATION CODE"	  '||
		'	   ,MCIX.MASTER_ORGANIZATION_ID	         "MASTER ORGANIZATION ID"	  '||
		'	   ,MCIX.RANK            		 "PREFERENCE NUMBER"		  '||
		'	   ,DECODE(MCIX.INACTIVE_FLAG,null,null,''Y'',''Yes ( Y )'',''N'',''No ( N )'','||
		'           ''OTHER ('' || MCIX.INACTIVE_FLAG || '')'') "INACTIVE FLAG"		  '||
		'	   ,to_char(MCIX.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "LAST UPDATE DATE" '||
		'	   ,MCIX.LAST_UPDATED_BY		         "LAST UPDATED BY"	  '||
		'	   ,to_char(MCIX.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'') "CREATION DATE"	'||
		'	   ,MCIX.CREATED_BY			 "CREATED BY"			  '||
		'	   ,MCIX.LAST_UPDATE_LOGIN		 "LAST UPDATE LOGIN"		  '||
		'	   ,MCIX.ATTRIBUTE_CATEGORY		 "ATTRIBUTE CATEGORY"		  '||
		'	   ,MCIX.ATTRIBUTE1			 "ATTRIBUTE1"			  '||
		'	   ,MCIX.ATTRIBUTE2			 "ATTRIBUTE2"			  '||
		'	   ,MCIX.ATTRIBUTE3			 "ATTRIBUTE3"			  '||
		'	   ,MCIX.ATTRIBUTE4			 "ATTRIBUTE4"			  '||
		'	   ,MCIX.ATTRIBUTE5			 "ATTRIBUTE5"			  '||
		'	   ,MCIX.ATTRIBUTE6			 "ATTRIBUTE6"			  '||
		'	   ,MCIX.ATTRIBUTE7			 "ATTRIBUTE7"			  '||
		'	   ,MCIX.ATTRIBUTE8			 "ATTRIBUTE8"			  '||
		'	   ,MCIX.ATTRIBUTE9			 "ATTRIBUTE9"			  '||
		'	   ,MCIX.ATTRIBUTE10			 "ATTRIBUTE10"			  '||
		'	   ,MCIX.ATTRIBUTE11			 "ATTRIBUTE11"			  '||
		'	   ,MCIX.ATTRIBUTE12			 "ATTRIBUTE12"			  '||
		'	   ,MCIX.ATTRIBUTE13			 "ATTRIBUTE13"			  '||
		'	   ,MCIX.ATTRIBUTE14			 "ATTRIBUTE14"			  '||
		'	   ,MCIX.ATTRIBUTE15			 "ATTRIBUTE15"			  '||
		'	   ,MCIX.REQUEST_ID			 "REQUEST ID"			  '||
		'	   ,MCIX.PROGRAM_APPLICATION_ID	 "PROGRAM APPLICATION ID"		  '||
		'	   ,MCIX.PROGRAM_ID			 "PROGRAM ID"			  '||
		'	   ,to_char(MCIX.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "PROGRAM UPDATE DATE" '||
		'	FROM 	 MTL_CUSTOMER_ITEM_XREFS_V  mcix  				  '||
		'	   	,mtl_item_flexfields mif					  '||
		'	   	,mtl_parameters mp1						  '||
		'	where 1=1								  '||
		'	AND 	MCIX.INVENTORY_ITEM_ID =  MIF.INVENTORY_ITEM_ID			  '||
		'	AND 	MCIX.MASTER_ORGANIZATION_ID = MIF.ORGANIZATION_ID		  '||
		'	AND  	MCIX.MASTER_ORGANIZATION_ID = MP1.ORGANIZATION_ID		  ';

	if l_org_id is not null then
	   sqltxt :=sqltxt||' and mcix.master_organization_id =			  '||
			    ' (select master_organization_id from mtl_parameters  '||
			    '  where organization_id= '||l_org_id||' ) ';
	else /* l_org_id is null */
	  sqltxt :=sqltxt||' and mcix.master_organization_id in			  '||
			  '( select distinct master_organization_id from mtl_parameters )';
	end if;

	if l_item_id is not null then
	   sqltxt :=sqltxt||' and mcix.inventory_item_id =  '||l_item_id;
	end if;

	   sqltxt :=sqltxt||' and rownum <   '||row_limit;
	   sqltxt :=sqltxt||' order by mp1.organization_code, mif.padded_item_number, mcix.customer_item_number';

	   num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Customer Item Cross References ');
	   If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	   End If;

	   statusStr := 'SUCCESS';
	   isFatal := 'FALSE';
/* End of customer item xrefs*/


/* SQL to fetch manufacturer part numbers*/
sqltxt := '	SELECT								'||
	'		  MMPN.MANUFACTURER_NAME     	"MANUFACTURER NAME"	'||
	'		 ,MMPN.MANUFACTURER_ID		"MANUFACTURER ID"	'||
	'		 ,MMPN.MFG_PART_NUM		"MFG PART NUM"		'||
	'		 ,MIF.PADDED_ITEM_NUMBER	"ITEM NUMBER"	 	'||
	'		 ,MMPN.INVENTORY_ITEM_ID	"INVENTORY ITEM ID"	'||
	'		 ,MMPN.ITEM_DESCRIPTION		"ITEM DESCRIPTION "	'||
	'		 ,MP1.ORGANIZATION_CODE     	"ORGANIZATION CODE "	'||
	'		 ,MMPN.ORGANIZATION_ID		"ORGANIZATION ID"	'||
	'		 ,MMPN.ATTRIBUTE_CATEGORY	"ATTRIBUTE CATEGORY"	'||
	'		 ,MMPN.ATTRIBUTE1		"ATTRIBUTE1"		'||
	'		 ,MMPN.ATTRIBUTE2		"ATTRIBUTE2"		'||
	'		 ,MMPN.ATTRIBUTE3		"ATTRIBUTE3"		'||
	'		 ,MMPN.ATTRIBUTE4		"ATTRIBUTE4"		'||
	'		 ,MMPN.ATTRIBUTE5		"ATTRIBUTE5"		'||
	'		 ,MMPN.ATTRIBUTE6		"ATTRIBUTE6"		'||
	'		 ,MMPN.ATTRIBUTE7		"ATTRIBUTE7"		'||
	'		 ,MMPN.ATTRIBUTE8		"ATTRIBUTE8"		'||
	'		 ,MMPN.ATTRIBUTE9		"ATTRIBUTE9"		'||
	'		 ,MMPN.ATTRIBUTE10		"ATTRIBUTE10"		'||
	'		 ,MMPN.ATTRIBUTE11		"ATTRIBUTE11"		'||
	'		 ,MMPN.ATTRIBUTE12		"ATTRIBUTE12"		'||
	'		 ,MMPN.ATTRIBUTE13		"ATTRIBUTE13"		'||
	'		 ,MMPN.ATTRIBUTE14		"ATTRIBUTE14"		'||
	'		 ,MMPN.ATTRIBUTE15		"ATTRIBUTE15"		'||
	'		 ,MMPN.DESCRIPTION		"DESCRIPTION"		'||
	'		 ,to_char(MMPN.START_DATE,''DD-MON-YYYY HH24:MI:SS'')	"START DATE"		'||
	'		 ,to_char(MMPN.END_DATE,''DD-MON-YYYY HH24:MI:SS'')	"END DATE"		'||
	'		 ,MMPN.FIRST_ARTICLE_STATUS	"FIRST ARTICLE STATUS"	'||
	'		 ,MMPN.APPROVAL_STATUS		"APPROVAL STATUS"	'||
	'	FROM 	  MTL_MFG_PART_NUMBERS_ALL_V MMPN 			'||
	'		 ,MTL_PARAMETERS MP1					'||
	'		 ,MTL_ITEM_FLEXFIELDS MIF				'||
	'	WHERE 	1=1  							'||
	'	AND  	MMPN.ORGANIZATION_ID = MP1.ORGANIZATION_ID		'||
	'	AND  	MMPN.INVENTORY_ITEM_ID=MIF.INVENTORY_ITEM_ID	 	'||
	'	AND  	MMPN.ORGANIZATION_ID = MIF.ORGANIZATION_ID		';


	 /* Mfg part numbers are master org (or Item Master org) specific,
	   so org filter is applied on master org id of the input org id.
	   This may not properly handle the case where an organization's
	   Item Master org is different from its master org. Need to change this filter if necessary*/

	if l_org_id is not null then
	   sqltxt :=sqltxt||' and mmpn.organization_id =			  '||
			    ' (select master_organization_id from mtl_parameters  '||
			    '  where organization_id= '||l_org_id||' )		  ';
	else /* l_org_id is null */
	  sqltxt :=sqltxt||' and mmpn.organization_id in			  '||
			  '( select distinct master_organization_id from mtl_parameters )';
	end if;

	if l_item_id is not null then
	   sqltxt :=sqltxt||' and mmpn.inventory_item_id =  '||l_item_id;
	end if;

	   sqltxt :=sqltxt||' and rownum <   '||row_limit;
	   sqltxt :=sqltxt||' order by mp1.organization_code,mmpn.manufacturer_name,mmpn.mfg_part_num ';

	   num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Manufacturer Part Numbers ');
	   If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	   End If;

	   statusStr := 'SUCCESS';
	   isFatal := 'FALSE';

/* End of manufacturer part numbers*/


/* SQL to fetch item relationships*/
sqltxt :=	'	SELECT												    '||
		'	   	 MIF1.PADDED_ITEM_NUMBER			"ITEM NUMBER"				     '||
		'	   	,MRI.INVENTORY_ITEM_ID		     		"INVENTORY ITEM ID"	  		     '||
		'	   	,MRI.INVENTORY_ITEM_DESCRIPTION                 "ITEM DESCRIPTION "			     '||
		'	   	,MP1.ORGANIZATION_CODE                          "ORGANIZATION CODE "       		     '||
		'	   	,MRI.ORGANIZATION_ID		                "ORGANIZATION ID"	  		     '||
		'	   	,MIF2.PADDED_ITEM_NUMBER			"RELATED ITEM NUMBER"			     '||
		'	   	,MRI.RELATED_ITEM_ID		                "RELATED ITEM ID"	  		     '||
		' 		,MRI.RELATED_ITEM_DESCRIPTION			"RELATED ITEM DESCRIPTION"       	     '||
		'	   	,DECODE(MLU_RT.MEANING,null,null,                                                	     '||
		'	  		(MLU_RT.MEANING ||''('' || MRI.RELATIONSHIP_TYPE_ID|| '')'')) "RELATION TYPE"	     '||
		'          	,MRI.RELATIONSHIP_TYPE_ID		              		"RELATIONSHIP TYPE ID"       '||
		'	   	,DECODE(MRI.RECIPROCAL_FLAG,null,null,''Y'',''Yes ( Y )'',''N'',''No ( N )'', 	             '||
		'	   	    ''OTHER ('' || MRI.RECIPROCAL_FLAG || '')'') "RECIPROCAL FLAG" 	  		     '||
		'	   	,to_char(MRI.START_DATE,''DD-MON-YYYY HH24:MI:SS'')	"START DATE"		  	     '||
		'	   	,to_char(MRI.END_DATE,''DD-MON-YYYY HH24:MI:SS'')	"END DATE"		  	'||
		'	   	,MRI.ATTR_CONTEXT			  	"ATTR CONTEXT"		  		     '||
		'	   	,MRI.ATTR_CHAR1			  		"ATTR CHAR1"		  		     '||
		'	   	,MRI.ATTR_CHAR2			  		"ATTR CHAR2"		  		     '||
		'	   	,MRI.ATTR_CHAR3			  		"ATTR CHAR3"		  		     '||
		'	   	,MRI.ATTR_CHAR4			  		"ATTR CHAR4"		  		     '||
		'	   	,MRI.ATTR_CHAR5			  		"ATTR CHAR5"		  		     '||
		'	   	,MRI.ATTR_CHAR6			  		"ATTR CHAR6"		  		     '||
		'	   	,MRI.ATTR_CHAR7			  		"ATTR CHAR7"		  		     '||
		'	   	,MRI.ATTR_CHAR8			  		"ATTR CHAR8"		  		     '||
		'	   	,MRI.ATTR_CHAR9			  		"ATTR CHAR9"		  		     '||
		'	   	,MRI.ATTR_CHAR10			  	"ATTR CHAR10"		  		     '||
		'	   	,MRI.ATTR_NUM1			    	  	"ATTR NUM1"		  		     '||
		'	   	,MRI.ATTR_NUM2			  	  	"ATTR NUM2"		  		     '||
		'	   	,MRI.ATTR_NUM3			  	  	"ATTR NUM3"		  		     '||
		'	   	,MRI.ATTR_NUM4			  	  	"ATTR NUM4"		  		     '||
		'	   	,MRI.ATTR_NUM5			  	  	"ATTR NUM5"		  		     '||
		'	   	,MRI.ATTR_NUM6			  	  	"ATTR NUM6"		  		     '||
		'	   	,MRI.ATTR_NUM7			  	  	"ATTR NUM7"		  		     '||
		'	   	,MRI.ATTR_NUM8			  	  	"ATTR NUM8"		  		     '||
		'	   	,MRI.ATTR_NUM9			  	  	"ATTR NUM9"		  		     '||
		'	   	,MRI.ATTR_NUM10			  		"ATTR NUM10"		  		     '||
		'	   	,to_char(MRI.ATTR_DATE1,''DD-MON-YYYY HH24:MI:SS'')	"ATTR DATE1"		  	     '||
		'	   	,to_char(MRI.ATTR_DATE2,''DD-MON-YYYY HH24:MI:SS'')	"ATTR DATE2"		  	     '||
		'	   	,to_char(MRI.ATTR_DATE3,''DD-MON-YYYY HH24:MI:SS'')	"ATTR DATE3"		  	     '||
		'	   	,to_char(MRI.ATTR_DATE4,''DD-MON-YYYY HH24:MI:SS'')	"ATTR DATE4"		  	     '||
		'	   	,to_char(MRI.ATTR_DATE5,''DD-MON-YYYY HH24:MI:SS'')	"ATTR DATE5"		  	     '||
		'	   	,to_char(MRI.ATTR_DATE6,''DD-MON-YYYY HH24:MI:SS'')	"ATTR DATE6"		  	     '||
		'	   	,to_char(MRI.ATTR_DATE7,''DD-MON-YYYY HH24:MI:SS'')	"ATTR DATE7"		  	     '||
		'	   	,to_char(MRI.ATTR_DATE8,''DD-MON-YYYY HH24:MI:SS'')	"ATTR DATE8"		  	     '||
		'	   	,to_char(MRI.ATTR_DATE9,''DD-MON-YYYY HH24:MI:SS'')	"ATTR DATE9"		  	     '||
		'          	,to_char(MRI.ATTR_DATE10,''DD-MON-YYYY HH24:MI:SS'')	"ATTR DATE10"		     '||
		'   		,DECODE(MRI.PLANNING_ENABLED_FLAG,null,null,''Y'',''Yes ( Y )'',''N'',''No ( N )'', 	     '||
		'   			''OTHER ('' || MRI.PLANNING_ENABLED_FLAG || '')'')    "PLANNING ENABLED FLAG"  '||
		'	   FROM 									          							'||
		'	   	MTL_RELATED_ITEMS_ALL_V MRI  					   	  					'||
		'	   	,MFG_LOOKUPS MLU_RT							     	  					'||
		'	   	,MTL_PARAMETERS MP1													'||
		'	   	,MTL_ITEM_FLEXFIELDS MIF1												'||
		'	   	,MTL_ITEM_FLEXFIELDS MIF2 												'||
		'	   where 1=1																'||
		'	   AND 	MRI.INVENTORY_ITEM_ID=MIF1.INVENTORY_ITEM_ID						'||
		'	   AND 	MRI.ORGANIZATION_ID = MIF1.ORGANIZATION_ID							'||
		'	   AND 	MRI.RELATED_ITEM_ID = MIF2.INVENTORY_ITEM_ID						'||
		'	   AND 	MRI.ORGANIZATION_ID = MIF2.ORGANIZATION_ID							'||
		'	   AND 	MRI.ORGANIZATION_ID = MP1.ORGANIZATION_ID							'||
		'	   AND 	MRI.relationship_type_id=MLU_RT.LOOKUP_CODE(+)						'||
		'	   AND 	''MTL_RELATIONSHIP_TYPES''=MLU_RT.LOOKUP_TYPE(+)					';

	 /* Item Relationships are master org (or Item Master org) specific,
	   so org filter is applied on master org id of the input org id.
	   This may not properly handle the case where an organization's
	   Item Master org is different from its master org. Need to change this filter if necessary*/

	if l_org_id is not null then
	   sqltxt :=sqltxt||' and mri.organization_id =			  '||
			    ' (select master_organization_id from mtl_parameters  '||
			    '  where organization_id= '||l_org_id||' )    ';
	else  /* l_org_id is null */
	sqltxt :=sqltxt||' and mri.organization_id in			  '||
			  '( select distinct master_organization_id from mtl_parameters )';
	end if;

	if l_item_id is not null then
	   sqltxt :=sqltxt||' and (mri.inventory_item_id =  '||l_item_id||
			    '   or  mri.related_item_id =     '||l_item_id||' ) ';
	end if;

	   sqltxt :=sqltxt||' and rownum <   '||row_limit;
	   sqltxt :=sqltxt||' order by mp1.organization_code,mif1.padded_item_number,  '||
			    ' mif2.padded_item_number,mri.relationship_type_id	   ';

	   num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Item Relationships ');
	   If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	   End If;

	   statusStr := 'SUCCESS';
	   isFatal := 'FALSE';

/* End of item relationships*/

/* SQL to fetch item onhand quantities */

     sqltxt := ' SELECT mif.padded_item_number		"Item Number"	  '||
                 ' , moq.inventory_item_id		"Item Id"	  '||
		 ' , mp1.organization_code  		"ORGANIZATION CODE"'||
		 ' , moq.organization_id		"Organization Id" '||
                 ' , SUM( moq.transaction_quantity )	"Txn Qty"	  '||
                 ' , moq.subinventory_code		"Subinv"	  '||
                 ' , mil.concatenated_segments		"Locator"	  '||
		 ' , moq.locator_id			"Locator Id"	  '||
                 ' , mil.description			"Locator Desc"    '||
                 ' , moq.revision			"Revision"	  '||
                 ' , moq.lot_number			"Lot Number"	  '||
                 ' FROM mtl_onhand_quantities_detail moq		  '||
                 ' , mtl_item_flexfields mif				  '||
                 ' , mtl_item_locations_kfv mil				  '||
		 ' , mtl_parameters mp1					  '||
                 ' WHERE 1=1						  '||
                 ' AND moq.inventory_item_id = mif.inventory_item_id(+)   '||
                 ' AND moq.organization_id = mif.organization_id(+)	  '||
                 ' AND moq.organization_id = mil.organization_id(+)	  '||
                 ' AND moq.locator_id = mil.inventory_location_id(+)	  '||
		'  AND moq.organization_id = mp1.organization_id	  ';

		if l_org_id is not null then
		   sqltxt :=sqltxt||' and moq.organization_id =  '||l_org_id;
		end if;

		if l_item_id is not null then
		   sqltxt :=sqltxt||' and moq.inventory_item_id =  '||l_item_id;
		end if;

     sqltxt := sqltxt ||' GROUP BY mif.padded_item_number, moq.inventory_item_id			' ||
		 ' , mp1.organization_code ,moq.organization_id						' ||
		 ' , moq.subinventory_code, moq.locator_id						' ||
                 ' , mil.concatenated_segments, mil.description						' ||
                 ' , moq.revision, moq.lot_number							' ||
                 '   ORDER BY mp1.organization_code,mif.padded_item_number				' ||
                 ' , moq.subinventory_code, moq.locator_id						' ||
                 ' , mil.concatenated_segments, mil.description						' ||
                 ' , moq.revision, moq.lot_number							';

       num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,' Item Onhand Quantity ');

	statusStr := 'SUCCESS';
	isFatal := 'FALSE';
/* End of item relationships*/

/* SQL to fetch default category sets */
sqltxt := '	SELECT										  '||
	'	    MDCS.FUNCTIONAL_AREA_DESC	      "FUNCTIONAL AREA",			  '||
	'	    MDCS.FUNCTIONAL_AREA_ID	      "FUNCTIONAL AREA ID",			  '||
	'	    MDCS.CATEGORY_SET_NAME            "CATEGORY SET NAME",			  '||
	'	    MDCS.CATEGORY_SET_ID	      "CATEGORY SET ID",			  '||
	'	    to_char(MDCS.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "LAST UPDATE DATE",	'||
	'	    MDCS.LAST_UPDATED_BY	      "LAST UPDATED BY",	    		  '||
	'	    to_char(MDCS.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'')    "CREATION DATE",		'||
	'	    MDCS.CREATED_BY		      "CREATED BY",		    		  '||
	'	    MDCS.LAST_UPDATE_LOGIN	      "LAST UPDATE LOGIN",	    		  '||
	'	    MDCS.REQUEST_ID		      "REQUEST ID",		    		  '||
	'	    MDCS.PROGRAM_APPLICATION_ID      "PROGRAM APPLICATION ID",	    		  '||
	'	    MDCS.PROGRAM_ID		      "PROGRAM ID",		    		  '||
	'	    to_char(MDCS.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "PROGRAM UPDATE DATE"	'||
	'	FROM  MTL_DEFAULT_CATEGORY_SETS_FK_V  mdcs     where 1=1	    		  ';

	sqltxt :=sqltxt||' and rownum <   '||row_limit;
	sqltxt :=sqltxt||' order by mdcs.functional_area_id,mdcs.category_set_name';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Default Category Sets ');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;

	statusStr := 'SUCCESS';
	isFatal := 'FALSE';

/*  End default category sets */

/*  SQL to fetch category sets */
	sqltxt := '	SELECT   ' ||
		'	 	MCSVL.CATEGORY_SET_NAME		              			"CATEGORY SET NAME"			       '||
		'	 	,MCSVL.CATEGORY_SET_ID	  	              			"CATEGORY SET ID"		  	       '||
		'	 	,FIFSV.ID_FLEX_STRUCTURE_NAME				  	"STRUCTURE NAME"			       '||
		'	 	,FIFSV.ID_FLEX_STRUCTURE_CODE				  	"STRUCTURE CODE"		  	       '||
		'	 	,MCSVL.STRUCTURE_ID			              		"STRUCTURE ID"			  	       '||
		'	 	,DECODE(MCSVL.VALIDATE_FLAG,null,null,''Y'',''Yes ( Y )'',''N'',''No ( N )'', 		  		       '||
		'	 	   ''OTHER ('' || MCSVL.VALIDATE_FLAG || '')'')       		"VALIDATE FLAG"			  	       '||
		'	 	,DECODE(MCSVL.CONTROL_LEVEL,NULL,NULL,1,''Master (1)'',2,''Org (2)'',			  		       '||
		'	 	  ''OTHER ('' || MCSVL.CONTROL_LEVEL || '')'')	      		"CONTROL LEVEL"			     	       '||
		'	 	,mcv.CATEGORY_CONCAT_SEGS                          		"DEFAULT CATEGORY NAME"		  	       '||
		'	 	,NVL(MCSVL.DEFAULT_CATEGORY_ID,NULL)		      		"DEFAULT CATEGORY ID"	          	       '||
		'	 	,to_char(MCSVL.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'')	"LAST UPDATE DATE"		  	       '||
		'	 	,MCSVL.LAST_UPDATED_BY		     	      			"LAST UPDATED BY"		  	       '||
		'	 	,to_char(MCSVL.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'')	"CREATION DATE"			  	       '||
		'	 	,MCSVL.CREATED_BY			     	      		"CREATED BY"			  	       '||
		'	 	,MCSVL.LAST_UPDATE_LOGIN		              		"LAST UPDATE LOGIN"		     	       '||
		'	 	,MCSVL.REQUEST_ID			     	      		"REQUEST ID"			  	       '||
		'	 	,MCSVL.PROGRAM_APPLICATION_ID	     	      			"PROGRAM APPLICATION ID"	               '||
		'	 	,MCSVL.PROGRAM_ID			     	      		"PROGRAM ID"			  	       '||
		'	 	,to_char(MCSVL.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'')	"PROGRAM UPDATE DATE"		  	       '||
		'	 	,DECODE(MCSVL.MULT_ITEM_CAT_ASSIGN_FLAG,null,null,''Y'',''Yes ( Y )'',''N'',''No ( N )'', 	  	       '||
		'	 		''OTHER ('' || MCSVL.MULT_ITEM_CAT_ASSIGN_FLAG || '')'') "MULT ITEM CAT ASSIGN FLAG"	  	       '||
		'	 	,DECODE(MCSVL.CONTROL_LEVEL_UPDATEABLE_FLAG,null,null,''Y ( Y )'',''Yes'',''N'',''No ( N )'',  		       '||
		'	 		''OTHER ('' || MCSVL.CONTROL_LEVEL_UPDATEABLE_FLAG || '')'') "CONTROL LEVEL UPDATEABLE FLAG" 	       '||
		'	 	,DECODE(MCSVL.MULT_ITEM_CAT_UPDATEABLE_FLAG,null,null,''Y ( Y )'',''Yes'',''N'',''No ( N )'',  		       '||
		'	 		''OTHER ('' || MCSVL.MULT_ITEM_CAT_UPDATEABLE_FLAG || '')'')  "MULT ITEM CAT UPDATEABLE FLAG"	       '||
		'	 	,DECODE(MCSVL.HIERARCHY_ENABLED,null,null,''Y ( Y )'',''Yes'',''N'',''No ( N )'', 		  	       '||
		'	 		''OTHER ('' || MCSVL.HIERARCHY_ENABLED || '')'')           "HIERARCHY ENABLED"		  	       '||
		'	 	,DECODE(MCSVL.VALIDATE_FLAG_UPDATEABLE_FLAG,null,null,''Y ( Y )'',''Yes'',''N '',''No ( N )'', 		       '||
		'	 		''OTHER ('' || MCSVL.VALIDATE_FLAG_UPDATEABLE_FLAG || '')'') "VALIDATE FLAG UPDATEABLE FLAG" 	       '||
		'	 FROM	 mtl_category_sets_vl mcsvl	 						   	 		       '||
		'	 	,mtl_categories_v     mcv										       '||
		'	 	,fnd_id_flex_structures_vl fifsv									       '||
		' 	 where 	1=1									 	  			       '||
		' 	 AND 	mcsvl.default_category_id = mcv.category_id(+)								       '||
		' 	 AND 	mcsvl.structure_id	  =fifsv.id_flex_num								       '||
		' 	 AND 	fifsv.id_flex_code 	  = ''MCAT''										';

		sqltxt :=sqltxt||' and rownum <   '||row_limit;
		sqltxt :=sqltxt||' order by mcsvl.category_set_name,fifsv.id_flex_structure_name';

		num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Category Sets ');
		If (num_rows = row_limit -1 ) Then
			JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
		End If;

		statusStr := 'SUCCESS';
		isFatal := 'FALSE';
/*  End category sets */

/* SQL to fetch item category assignments */
	sqltxt := '	SELECT   ' ||
		'		 MIF1.PADDED_ITEM_NUMBER   			"ITEM NUMBER"			'||
		'		,MIC.INVENTORY_ITEM_ID	  			"INVENTORY ITEM ID"		'||
		'		,MP1.ORGANIZATION_CODE     			"ORGANIZATION CODE"     	'||
		'		,MIC.ORGANIZATION_ID	      			"ORGANIZATION ID"		'||
		'		,MIC.CATEGORY_SET_NAME     			"CATEGORY SET NAME" 		'||
		'		,MIC.CATEGORY_SET_ID	      			"CATEGORY SET ID"		'||
		'		,MIC.CATEGORY_CONCAT_SEGS  			"CATEGORY NAME"			'||
		'		,MIC.CATEGORY_ID		      		"CATEGORY ID"			'||
		'		,to_char(MIC.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'')  "LAST UPDATE DATE"	'||
		'		,MIC.LAST_UPDATED_BY	      			"LAST UPDATED BY"		'||
		'		,to_char(MIC.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'')	"CREATION DATE"		'||
		'		,MIC.CREATED_BY		      			"CREATED BY"			'||
		'		,MIC.LAST_UPDATE_LOGIN	  			"LAST UPDATE LOGIN"		'||
		'		,MIC.REQUEST_ID		      			"REQUEST ID"			'||
		'		,MIC.PROGRAM_APPLICATION_ID              	"PROGRAM APPLICATION ID"	'||
		'		,MIC.PROGRAM_ID		                	"PROGRAM ID"			'||
		'		,to_char(MIC.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "PROGRAM UPDATE DATE" '||
		'	FROM 										  	'||
		'		mtl_item_categories_v MIC						  	'||
		'		,mtl_parameters MP1 							  	'||
		'		,mtl_item_flexfields MIF1						  	'||
		'	where	1=1 								  	  	'||
		'	AND  	MIC.INVENTORY_ITEM_ID   = MIF1.INVENTORY_ITEM_ID		  	  	'||
		'	AND  	MIC.ORGANIZATION_ID     = MIF1.ORGANIZATION_ID			  	  	'||
		'	AND  	MIF1.ORGANIZATION_ID    = MP1.ORGANIZATION_ID			  	  	';


		if l_org_id is not null then
			sqltxt :=sqltxt||' and mic.organization_id =  '||l_org_id;
		end if;

		if l_item_id is not null then
			sqltxt :=sqltxt||' and mic.inventory_item_id =  '||l_item_id;
		end if;

		sqltxt :=sqltxt||' and rownum <   '||row_limit;
		sqltxt :=sqltxt||' order by mp1.organization_code, mif1.padded_item_number,  '||
				    '   mic.category_set_name, mic.category_concat_segs	   ';

		num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Item Category Assignments ');
		If (num_rows = row_limit -1 ) Then
			JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
		End If;

		statusStr := 'SUCCESS';
		isFatal := 'FALSE';
/* End of item category assignments */


/* Start of BOM, RTG scripts*/
/* Get the application installation info. References to Data Dictionary Objects without schema name
included in WHERE predicate are not allowed (GSCC Check: file.sql.47). Schema name has to be passed
as an input parameter to JTF_DIAGNOSTIC_COREAPI.Column_Exists API. */

l_ret_status :=      fnd_installation.get_app_info ('BOM'
                                   , l_status
                                   , l_industry
                                   , l_oracle_schema
                                    );
/*JTF_DIAGNOSTIC_COREAPI.Line_Out(' l_oracle_schema: '||l_oracle_schema);*/


/* SQL to Fetch Bill Header Details */
sqltxt :=	'SELECT   ' ||
		'        MIF1.PADDED_ITEM_NUMBER		 		"ASSEMBLY ITEM NUMBER"			 '||
		'	,bsb.ASSEMBLY_ITEM_ID            			"ASSEMBLY ITEM ID"			 '||
		'	,MP1.ORGANIZATION_CODE    	 			"ORGANIZATION CODE"			 '||
		'	,bsb.ORGANIZATION_ID             			"ORGANIZATION ID "			 '||
		'	,bsb.ALTERNATE_BOM_DESIGNATOR    			"ALTERNATE BOM DESIGNATOR"		 '||
		'	,to_char(bsb.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'')  "LAST UPDATE DATE"			 '||
		'	,bsb.LAST_UPDATED_BY             			"LAST UPDATED BY"			 '||
		'	,to_char(bsb.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'')     "CREATION DATE"			 '||
		'	,bsb.CREATED_BY                  			"CREATED BY"				 '||
		'	,bsb.LAST_UPDATE_LOGIN           			"LAST UPDATE LOGIN"			 '||
		'	,bsb.SPECIFIC_ASSEMBLY_COMMENT   			"SPECIFIC ASSEMBLY COMMENT"		 '||
		'	,bsb.PENDING_FROM_ECN            			"PENDING FROM ECN"			 '||
		'	,bsb.ATTRIBUTE_CATEGORY          			"ATTRIBUTE CATEGORY"			 '||
		'	,bsb.ATTRIBUTE1                  			"ATTRIBUTE1"				 '||
		'	,bsb.ATTRIBUTE2                  			"ATTRIBUTE2"				 '||
		'	,bsb.ATTRIBUTE3                  			"ATTRIBUTE3"				 '||
		'	,bsb.ATTRIBUTE4                  			"ATTRIBUTE4"				 '||
		'	,bsb.ATTRIBUTE5                  			"ATTRIBUTE5"				 '||
		'	,bsb.ATTRIBUTE6                  			"ATTRIBUTE6"				 '||
		'	,bsb.ATTRIBUTE7                  			"ATTRIBUTE7"				 '||
		'	,bsb.ATTRIBUTE8                  			"ATTRIBUTE8"				 '||
		'	,bsb.ATTRIBUTE9                  			"ATTRIBUTE9"				 '||
		'	,bsb.ATTRIBUTE10                 			"ATTRIBUTE10"				 '||
		'	,bsb.ATTRIBUTE11                 			"ATTRIBUTE11"				 '||
		'	,bsb.ATTRIBUTE12                 			"ATTRIBUTE12"				 '||
		'	,bsb.ATTRIBUTE13                 			"ATTRIBUTE13"				 '||
		'	,bsb.ATTRIBUTE14                 			"ATTRIBUTE14"				 '||
		'	,bsb.ATTRIBUTE15                 			"ATTRIBUTE15"				 '||
		'	,DECODE(bsb.ASSEMBLY_TYPE,NULL,NULL,1,''Manufacturing (1)'',  2, ''Engineering (2)'', 		 '||
		'              ''Other ('' ||bsb.ASSEMBLY_TYPE|| '')'')         "ASSEMBLY TYPE"			 '||
		'	,MIF2.PADDED_ITEM_NUMBER		                 "ITEM NUMBER (COMMON)"			 '||
		'	,NVL(bsb.COMMON_ASSEMBLY_ITEM_ID,bsb.ASSEMBLY_ITEM_ID) "COMMON ASSEMBLY ITEM ID"		 '||
		'	,MP2.ORGANIZATION_CODE		                        "ORGANIZATION CODE (COMMON)"		 '||
		'	,NVL(bsb.COMMON_ORGANIZATION_ID,bsb.ORGANIZATION_ID)   "COMMON ORGANIZATION ID"		 '||
		'	,bsb.COMMON_BILL_SEQUENCE_ID     			"COMMON BILL SEQUENCE ID"		 '||
		'	,bsb.BILL_SEQUENCE_ID            			"BILL SEQUENCE ID"			 '||
		'	,bsb.REQUEST_ID                  			"REQUEST ID"				 '||
		'	,bsb.PROGRAM_APPLICATION_ID      			"PROGRAM APPLICATION ID"		 '||
		'	,bsb.PROGRAM_ID                  			"PROGRAM ID"				 '||
		'	,to_char(bsb.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "PROGRAM UPDATE DATE"		 '||
		'	,bsb.NEXT_EXPLODE_DATE           			"NEXT EXPLODE DATE"			 '||
		'	,bsb.PROJECT_ID                  			"PROJECT ID"				 '||
		'	,bsb.TASK_ID                     			"TASK ID"				 '||
		'	,bsb.ORIGINAL_SYSTEM_REFERENCE   			"ORIGINAL SYSTEM REFERENCE"		 '||
		'	,bsb.STRUCTURE_TYPE_ID           			"STRUCTURE TYPE ID"			 '||
		'	,bsb.IMPLEMENTATION_DATE         			"IMPLEMENTATION DATE"			 '||
		'	,bsb.OBJ_NAME                    			"OBJ NAME"				 '||
		'	,bsb.PK1_VALUE                   			"PK1 VALUE"				 '||
		'	,bsb.PK2_VALUE                   			"PK2 VALUE"				 '||
		'	,bsb.PK3_VALUE                   			"PK3 VALUE"				 '||
		'	,bsb.PK4_VALUE                   			"PK4 VALUE"				 '||
		'	,bsb.PK5_VALUE                   			"PK5 VALUE"				 '||
		'	,bsb.EFFECTIVITY_CONTROL         			"EFFECTIVITY CONTROL"			 '||
		'	,bsb.IS_PREFERRED         			"IS PREFERRED"			 '||
		'	,bsb.SOURCE_BILL_SEQUENCE_ID         	"SOURCE BILL SEQUENCE ID"			 '||
		' FROM 													 '||
		'        bom_structures_b bsb									 '||
		'       ,mtl_parameters mp1 										 '||
		'       ,mtl_parameters mp2 										 '||
		'       ,mtl_item_flexfields mif1									 '||
		'       ,mtl_item_flexfields mif2									 '||
		' WHERE 1=1												 '||
		' AND	bsb.assembly_item_id = mif1.inventory_item_id							 '||
		' AND	bsb.organization_id = mif1.organization_id							 '||
		' AND	mif1.organization_id = mp1.organization_id							 '||
		' AND	nvl(bsb.common_assembly_item_id,bsb.assembly_item_id) = mif2.inventory_item_id		 '||
		' AND	nvl(bsb.common_organization_id, bsb.organization_id)  = mif2.organization_id			 '||
		' AND	mif2.organization_id =  mp2.organization_id							 ';

	if l_org_id is not null then
	   sqltxt :=sqltxt||' and bsb.organization_id =  '||l_org_id;
	end if;

	if l_item_id is not null then
	   sqltxt :=sqltxt||' and bsb.assembly_item_id =  '||l_item_id;
	end if;

	sqltxt :=sqltxt||' and rownum <   '||row_limit;
	sqltxt :=sqltxt||' order by mp1.organization_code, mif1.padded_item_number, bsb.alternate_bom_designator';
	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Bill Headers ');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;
	statusStr := 'SUCCESS';
	isFatal := 'FALSE';

/* SQL to Fetch Bill Component Details */

sqltxt :=	' SELECT '||
		'	 MIF1.PADDED_ITEM_NUMBER   			        "Item Number (Assembly)"		'||
		'	,BSB.ASSEMBLY_ITEM_ID 					"Assy Item Id"				'||
		'	,MP1.ORGANIZATION_CODE 					"Org Code"				'||
		'	,BSB.ORGANIZATION_ID  					"ORGANIZATION ID"			'||
		'	,BSB.ALTERNATE_BOM_DESIGNATOR     			"ALTERNATE BOM DESIGNATOR"		'||
		'	,BCB.BILL_SEQUENCE_ID              			"BILL SEQUENCE ID"           		'||
		'	,MIF2.PADDED_ITEM_NUMBER 				"Item Number (COMPONENT)"		'||
		'	,BCB.COMPONENT_ITEM_ID             			"COMPONENT ITEM ID"          		'||
		'	,BCB.COMPONENT_SEQUENCE_ID         			"COMPONENT SEQUENCE ID"                 '||
		'	,BCB.OPERATION_SEQ_NUM             			"OPERATION SEQ NUM"          		'||
		'	,BCB.ITEM_NUM                      			"ITEM NUM"             			'||
		'	,NVL(BCB.COMPONENT_QUANTITY,0)     			"COMPONENT QUANTITY"         		'||
		'	,NVL(BCB.COMPONENT_YIELD_FACTOR,0) 			"COMPONENT YIELD FACTOR"     		'||
		'	,BCB.COMPONENT_REMARKS             			"COMPONENT REMARKS"			'||
		'	,to_char(BCB.EFFECTIVITY_DATE,''DD-MON-YYYY HH24:MI:SS'')    "EFFECTIVITY DATE "          	'||
		'	,BCB.CHANGE_NOTICE                 			"CHANGE NOTICE"      			'||
		'	,to_char(BCB.IMPLEMENTATION_DATE,''DD-MON-YYYY HH24:MI:SS'') "IMPLEMENTATION DATE"		'||
		'	,to_char(BCB.DISABLE_DATE,''DD-MON-YYYY HH24:MI:SS'')   "DISABLE DATE" 				'||
		'	,BCB.ATTRIBUTE_CATEGORY            			"ATTRIBUTE CATEGORY"         		'||
		'	,BCB.ATTRIBUTE1                    			"ATTRIBUTE1"             		'||
		'	,BCB.ATTRIBUTE2                    			"ATTRIBUTE2"             		'||
		'	,BCB.ATTRIBUTE3                    			"ATTRIBUTE3"             		'||
		'	,BCB.ATTRIBUTE4                    			"ATTRIBUTE4"             		'||
		'	,BCB.ATTRIBUTE5                    			"ATTRIBUTE5"             		'||
		'	,BCB.ATTRIBUTE6                    			"ATTRIBUTE6"             		'||
		'	,BCB.ATTRIBUTE7                    			"ATTRIBUTE7"             		'||
		'	,BCB.ATTRIBUTE8                    			"ATTRIBUTE8"             		'||
		'	,BCB.ATTRIBUTE9                    			"ATTRIBUTE9"             		'||
		'	,BCB.ATTRIBUTE10                   			"ATTRIBUTE10"             		'||
		'	,BCB.ATTRIBUTE11                   			"ATTRIBUTE11"             		'||
		'	,BCB.ATTRIBUTE12                   			"ATTRIBUTE12"             		'||
		'	,BCB.ATTRIBUTE13                   			"ATTRIBUTE13"             		'||
		'	,BCB.ATTRIBUTE14                   			"ATTRIBUTE14"             		'||
		'	,BCB.ATTRIBUTE15                   			"ATTRIBUTE15"             		'||
		'	,BCB.PLANNING_FACTOR               			"PLANNING FACTOR"           		'||
		'	,DECODE(BCB.QUANTITY_RELATED,null,null,1,''Yes (1)'',2,''No (2)'',				'||
		'                      ''OTHER ('' || BCB.QUANTITY_RELATED || '')'') "QUANTITY RELATED"			'||
		'	,DECODE(MLU_SO.MEANING,null,null,								'||
		'		(MLU_SO.MEANING || ''('' || BCB.SO_BASIS || '')''))    "SO BASIS"			'||
		'	,DECODE(BCB.OPTIONAL,null,null,1,''Yes (1)'',2,''No (2)'',					'||
		'                     ''OTHER ('' || BCB.OPTIONAL || '')'')         "OPTIONAL"				'||
		'	,DECODE(BCB.MUTUALLY_EXCLUSIVE_OPTIONS,null,null,1,''Yes (1)'',2,''No (2)'',			'||
		'          ''OTHER ('' || BCB.MUTUALLY_EXCLUSIVE_OPTIONS || '')'')  "MUTUALLY EXCLUSIVE OPTIONS"	'||
		'	,DECODE(BCB.INCLUDE_IN_COST_ROLLUP,null,null,1,''Yes (1)'',2,''No (2)'',			'||
		'                ''OTHER ('' || BCB.INCLUDE_IN_COST_ROLLUP || '')'')  "INCLUDE IN COST ROLLUP"    	'||
		'	,DECODE(BCB.CHECK_ATP,null,null,1,''Yes (1)'',2,''No (2)'',					'||
		'                  ''OTHER ('' || BCB.CHECK_ATP || '')'')             "CHECK ATP"             		'||
		'	,DECODE(BCB.SHIPPING_ALLOWED,null,null,1,''Yes (1)'',2,''No (2)'',				'||
		'                    ''OTHER ('' || BCB.SHIPPING_ALLOWED || '')'')    "SHIPPING ALLOWED"          	'||
		'	,DECODE(BCB.REQUIRED_TO_SHIP,null,null,1,''Yes (1)'',2,''No (2)'',				'||
		'            ''OTHER ('' || BCB.REQUIRED_TO_SHIP || '')'')            "REQUIRED TO SHIP"          	'||
		'	,DECODE(BCB.REQUIRED_FOR_REVENUE,null,null,1,''Yes (1)'',2,''No (2)'',				'||
		'                ''OTHER ('' || BCB.REQUIRED_FOR_REVENUE || '')'')    "REQUIRED FOR REVENUE"      	'||
		'	,DECODE(BCB.INCLUDE_ON_SHIP_DOCS,null,null,1,''Yes (1)'',2,''No (2)'',				'||
		'                 ''OTHER ('' || BCB.INCLUDE_ON_SHIP_DOCS || '')'')    "INCLUDE ON SHIP DOCS"      	'||
		'	,DECODE(BCB.INCLUDE_ON_BILL_DOCS,null,null,1,''Yes (1)'',2,''No (2)'',				'||
		'                ''OTHER ('' || BCB.INCLUDE_ON_BILL_DOCS || '')'')    "INCLUDE ON BILL DOCS"      	'||
		'	,BCB.LOW_QUANTITY           			        "LOW QUANTITY"             		'||
		'	,BCB.HIGH_QUANTITY     				        "HIGH QUANTITY"             		'||
		'	,DECODE(MLU_ACD.MEANING,null,null,								'||
		'		  (MLU_ACD.MEANING || '' ('' || BCB.ACD_TYPE || '')'')) "ACD TYPE"			'||
		'	,BCB.OLD_COMPONENT_SEQUENCE_ID                           "OLD COMPONENT SEQUENCE ID" 		'||
		'       ,DECODE(MLU_WIP.MEANING,null,null,								'||
		'		  (MLU_WIP.MEANING || ''('' || BCB.WIP_SUPPLY_TYPE || '')'')) "WIP SUPPLY TYPE"		'||
		'	,BCB.PICK_COMPONENTS              			 "PICK COMPONENTS"              	'||
		'	,BCB.SUPPLY_SUBINVENTORY          			 "SUPPLY SUBINVENTORY"        		'||
		'	,BCB.SUPPLY_LOCATOR_ID            			 "SUPPLY LOCATOR ID"          		'||
		'	,BCB.OPERATION_LEAD_TIME_PERCENT  			 "OPERATION LEAD TIME PERCENT"		'||
		'	,BCB.REVISED_ITEM_SEQUENCE_ID     			 "REVISED ITEM SEQUENCE ID"   		'||
		'	,BCB.COST_FACTOR                  			 "COST FACTOR"             		'||
		'       ,DECODE(MLU_BIT.MEANING,null,null,								'||
		'		 (MLU_BIT.MEANING || ''('' || BCB.BOM_ITEM_TYPE || '')'')) "BOM ITEM TYPE"              '||
		'	,BCB.FROM_END_ITEM_UNIT_NUMBER    			 "FROM END ITEM UNIT NUMBER"  		'||
		'	,BCB.TO_END_ITEM_UNIT_NUMBER      			 "TO END ITEM UNIT NUMBER"    		'||
		'	,BCB.ORIGINAL_SYSTEM_REFERENCE    			 "ORIGINAL SYSTEM REFERENCE"  		'||
		'	,BCB.ECO_FOR_PRODUCTION           			 "ECO FOR PRODUCTION"         		'||
		'	,BCB.ENFORCE_INT_REQUIREMENTS     			 "ENFORCE INT REQUIREMENTS"   		'||
		'	,BCB.COMPONENT_ITEM_REVISION_ID   			 "COMPONENT ITEM REVISION ID" 		'||
		'	,BCB.DELETE_GROUP_NAME            			 "DELETE GROUP NAME"          		'||
		'	,BCB.DG_DESCRIPTION               			 "DG DESCRIPTION"             		'||
		'	,BCB.OPTIONAL_ON_MODEL            			 "OPTIONAL ON MODEL"          		'||
		'	,BCB.PARENT_BILL_SEQ_ID           			 "PARENT BILL SEQ ID"         		'||
		'	,BCB.MODEL_COMP_SEQ_ID            			 "MODEL COMP SEQ ID"          		'||
		'	,BCB.PLAN_LEVEL                   			 "PLAN LEVEL"             		'||
		'	,BCB.FROM_BILL_REVISION_ID        			 "FROM BILL REVISION ID"      		'||
		'	,BCB.TO_BILL_REVISION_ID          			 "TO BILL REVISION ID"        		'||
		'	,BCB.AUTO_REQUEST_MATERIAL        			 "AUTO REQUEST MATERIAL"      		'||
		'	,to_char(BCB.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "LAST UPDATE DATE "       		'||
		'	,BCB.LAST_UPDATED_BY              			 "LAST UPDATED BY"         		'||
		'	,to_char(BCB.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'')    "CREATION DATE"           		'||
		'	,BCB.CREATED_BY                   			 "CREATED BY"             		'||
		'	,BCB.LAST_UPDATE_LOGIN            			 "LAST UPDATE LOGIN"       		'||
		'	,BCB.REQUEST_ID                   			 "REQUEST ID"             		'||
		'	,BCB.PROGRAM_APPLICATION_ID       			 "PROGRAM APPLICATION ID"  		'||
		'	,BCB.PROGRAM_ID                   			 "PROGRAM ID"             		'||
		'	,to_char(BCB.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "PROGRAM UPDATE DATE"    		'||
		'	,BCB.SUGGESTED_VENDOR_NAME        			 "SUGGESTED VENDOR NAME"      		'||
		'	,BCB.VENDOR_ID                    			 "VENDOR ID"             		'||
		'	,BCB.UNIT_PRICE                   			 "UNIT PRICE"             		'||
		'	,BCB.OBJ_NAME                     			 "OBJ NAME"             		'||
		'	,BCB.PK1_VALUE                    			 "PK1 VALUE"             		'||
		'	,BCB.PK2_VALUE                    			 "PK2 VALUE"             		'||
		'	,BCB.PK3_VALUE                    			 "PK3 VALUE"             		'||
		'	,BCB.PK4_VALUE                    			 "PK4 VALUE"             		'||
		'	,BCB.PK5_VALUE                    			 "PK5 VALUE"             		'||
		'	,BCB.FROM_END_ITEM_REV_ID         			 "FROM END ITEM REV ID"       		'||
		'	,BCB.TO_END_ITEM_REV_ID           			 "TO END ITEM REV ID"       		'||
		'	,BCB.OVERLAPPING_CHANGES          			 "OVERLAPPING CHANGES"        		'||
		'	,BCB.FROM_OBJECT_REVISION_ID      			 "FROM OBJECT REVISION ID"    		'||
		'	,BCB.FROM_MINOR_REVISION_ID       			 "FROM MINOR REVISION ID"     		'||
		'	,BCB.TO_OBJECT_REVISION_ID        			 "TO OBJECT REVISION ID"      		'||
		'	,BCB.TO_MINOR_REVISION_ID         			 "TO MINOR REVISION ID"       		'||
		'	,BCB.FROM_END_ITEM_MINOR_REV_ID   			 "FROM END ITEM MINOR REV ID" 		'||
		'	,BCB.TO_END_ITEM_MINOR_REV_ID     			 "TO END ITEM MINOR REV ID"   		'||
		'	,BCB.COMPONENT_MINOR_REVISION_ID  			 "COMPONENT MINOR REVISION ID"		'||
		'	,BCB.FROM_STRUCTURE_REVISION_CODE 			 "FROM STRUCTURE REVISION CODE" 	'||
		'	,BCB.TO_STRUCTURE_REVISION_CODE   			 "TO STRUCTURE REVISION CODE"   	'||
		'	,BCB.FROM_END_ITEM_STRC_REV_ID    			 "FROM END ITEM STRC REV ID"    	'||
		'	,BCB.TO_END_ITEM_STRC_REV_ID      			 "TO END ITEM STRC REV ID"		'||
		'	,BCB.BASIS_TYPE      						"BASIS TYPE"		'||
		'	,BCB.COMMON_COMPONENT_SEQUENCE_ID      	"COMMON COMPONENT SEQUENCE ID"		'||
		' FROM   BOM_STRUCTURES_B BSB 									'||
		'	,BOM_COMPONENTS_B BCB 									'||
		'	,MTL_PARAMETERS MP1      									'||
		'	,MTL_ITEM_FLEXFIELDS MIF1									'||
		'	,MTL_ITEM_FLEXFIELDS MIF2									'||
		'	,MFG_LOOKUPS MLU_SO										'||
		'	,MFG_LOOKUPS MLU_ACD										'||
		'	,MFG_LOOKUPS MLU_WIP										'||
		'	,MFG_LOOKUPS MLU_BIT										'||
		' WHERE 1 = 1												'||
		' AND	BSB.assembly_item_id = MIF1.inventory_item_id							'||
		' AND	BSB.organization_id = MIF1.organization_id							'||
		' AND	MIF1.organization_id = MP1.organization_id							'||
		' AND	BCB.component_item_id =  MIF2.inventory_item_id							'||
		' AND	BSB.organization_id = MIF2.organization_id							'||
		' AND	BSB.bill_sequence_id = BCB.bill_sequence_id							'||
		' AND	BCB.SO_BASIS=MLU_SO.LOOKUP_CODE(+) AND ''BOM_SO_BASIS''=MLU_SO.LOOKUP_TYPE(+)			'||
		' AND	BCB.ACD_TYPE=MLU_ACD.LOOKUP_CODE(+) AND ''ECG_ACTION''=MLU_ACD.LOOKUP_TYPE(+)			'||
		' AND	BCB.WIP_SUPPLY_TYPE=MLU_WIP.LOOKUP_CODE(+) AND ''WIP_SUPPLY''=MLU_WIP.LOOKUP_TYPE(+)		'||
		' AND	BCB.BOM_ITEM_TYPE=MLU_BIT.LOOKUP_CODE(+) AND ''BOM_ITEM_TYPE''=MLU_BIT.LOOKUP_TYPE(+)		';

	if l_org_id is not null then
	   sqltxt :=sqltxt||' and BSB.organization_id =  '||l_org_id;
	end if;

	if l_item_id is not null then
	   sqltxt :=sqltxt||' and BSB.assembly_item_id =  '||l_item_id;
	end if;

	sqltxt :=sqltxt||' and rownum <   '||row_limit;
	sqltxt :=sqltxt||' order by mp1.organization_code, mif1.padded_item_number, BSB.alternate_bom_designator, BCB.operation_seq_num ,mif2.padded_item_number';
	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Bill Components ');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;
	statusStr := 'SUCCESS';
	isFatal := 'FALSE';

/* SQL to Fetch Reference Designators */
sqltxt :=	' SELECT												 '||
		'	MIF1.PADDED_ITEM_NUMBER				          "Item Number (Assembly)"		 '||
		'	,BSB.ASSEMBLY_ITEM_ID		   			  "ASSEMBLY ITEM ID"			 '||
		'	,MP1.ORGANIZATION_CODE 		   			  "Org Code"        			 '||
		'	,BSB.ORGANIZATION_ID 					  "ORGANIZATION ID"       		 '||
		'	,BSB.ALTERNATE_BOM_DESIGNATOR    			  "ALTERNATE BOM DESIGNATOR"		 '||
		'	,MIF2.PADDED_ITEM_NUMBER 				  "Item Number (Component)"          	 '||
		'	,BCB.COMPONENT_ITEM_ID		     		   	  "COMPONENT ITEM ID"			 '||
		'	,BCB.COMPONENT_SEQUENCE_ID	     			  "COMPONENT SEQUENCE ID"		 '||
		'	,BRD.COMPONENT_REFERENCE_DESIGNATOR   			  "COMPONENT REFERENCE DESIGNATOR"	 '||
		'	,to_char(BRD.LAST_UPDATE_DATE ,''DD-MON-YYYY HH24:MI:SS'') "LAST UPDATE DATE"                  	 '||
		'	,BRD.LAST_UPDATED_BY                  			  "LAST UPDATED BY"                   	 '||
		'	,to_char(BRD.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'')    "CREATION DATE"                     	 '||
		'	,BRD.CREATED_BY                       			  "CREATED BY"                        	 '||
		'	,BRD.LAST_UPDATE_LOGIN                			  "LAST UPDATE LOGIN"                 	 '||
		'	,BRD.REF_DESIGNATOR_COMMENT           			  "REF DESIGNATOR COMMENT"            	 '||
		'	,BRD.CHANGE_NOTICE                    			  "CHANGE NOTICE"                     	 '||
		'	,BRD.COMPONENT_SEQUENCE_ID            			  "COMPONENT SEQUENCE ID"             	 '||
		'	,DECODE(BRD.ACD_TYPE,null,null,1,''Add (1)'',2,''Change (2)'',3,''Delete (3)'',			 '||
		'               ''OTHER('' || BRD.ACD_TYPE || '')'') 		  "ACD TYPE"				 '||
		'	,BRD.REQUEST_ID                     			  "REQUEST ID"                        	 '||
		'	,BRD.PROGRAM_APPLICATION_ID         			  "PROGRAM APPLICATION ID"            	 '||
		'	,BRD.PROGRAM_ID                     			  "PROGRAM ID"                        	 '||
		'	,to_char(BRD.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "PROGRAM UPDATE DATE"               '||
		'	,BRD.ATTRIBUTE_CATEGORY             			  "ATTRIBUTE CATEGORY"                	 '||
		'	,BRD.ATTRIBUTE1                     			  "ATTRIBUTE1"                        	 '||
		'	,BRD.ATTRIBUTE2                     			  "ATTRIBUTE2"                        	 '||
		'	,BRD.ATTRIBUTE3                     			  "ATTRIBUTE3"                        	 '||
		'	,BRD.ATTRIBUTE4                     			  "ATTRIBUTE4"                        	 '||
		'	,BRD.ATTRIBUTE5                     			  "ATTRIBUTE5"                        	 '||
		'	,BRD.ATTRIBUTE6                     			  "ATTRIBUTE6"                        	 '||
		'	,BRD.ATTRIBUTE7                     			  "ATTRIBUTE7"                        	 '||
		'	,BRD.ATTRIBUTE8                     			  "ATTRIBUTE8"                        	 '||
		'	,BRD.ATTRIBUTE9                     			  "ATTRIBUTE9"                        	 '||
		'	,BRD.ATTRIBUTE10                    			  "ATTRIBUTE10"                       	 '||
		'	,BRD.ATTRIBUTE11                    			  "ATTRIBUTE11"                      	 '||
		'	,BRD.ATTRIBUTE12                    			  "ATTRIBUTE12"                       	 '||
		'	,BRD.ATTRIBUTE13                    			  "ATTRIBUTE13"                       	 '||
		'	,BRD.ATTRIBUTE14                    			  "ATTRIBUTE14"                       	 '||
		'	,BRD.ATTRIBUTE15                    			  "ATTRIBUTE15"                       	 '||
		'	,BRD.ORIGINAL_SYSTEM_REFERENCE      		  "ORIGINAL SYSTEM REFERENCE"		 '||
		'	,BRD.COMMON_COMPONENT_SEQUENCE_ID     "COMMON COMPONENT SEQUENCE ID"		 '||
		' FROM   												 '||
		'	 bom_components_b bcb 									 '||
		'	,bom_structures_b bsb 									 '||
		'	,bom_reference_designators brd 									 '||
		'	,MTL_PARAMETERS MP1 										 '||
		'	,MTL_ITEM_FLEXFIELDS MIF1 									 '||
		'	,MTL_ITEM_FLEXFIELDS MIF2									 '||
		' where 1=1 												 '||
		' AND	bcb.bill_sequence_id = bsb.bill_sequence_id 							 '||
		' AND	brd.component_sequence_id = bcb.component_sequence_id						 '||
		' AND	BSB.ORGANIZATION_ID  = MP1.ORGANIZATION_ID							 '||
		' AND	BSB.ASSEMBLY_ITEM_ID = MIF1.INVENTORY_ITEM_ID							 '||
		' AND	BSB.ORGANIZATION_ID  = MIF1.ORGANIZATION_ID							 '||
		' AND	BCB.COMPONENT_ITEM_ID = MIF2.INVENTORY_ITEM_ID							 '||
		' AND	BSB.ORGANIZATION_ID  = MIF2.ORGANIZATION_ID							 ';

		if l_org_id is not null then
		   sqltxt :=sqltxt||' and bsb.organization_id =  '||l_org_id;
		end if;

		if l_item_id is	not null then
		   sqltxt :=sqltxt||' and bsb.assembly_item_id =  '||l_item_id;
		end if;

		sqltxt :=sqltxt||' and rownum <   '||row_limit;
		sqltxt :=sqltxt||' order by mp1.organization_code, mif1.padded_item_number, bsb.alternate_bom_designator, '||
			 ' bcb.operation_seq_num, bcb.item_num,				'||
			 ' mif2.padded_item_number, brd.component_reference_designator';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Bill Reference Designators ');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;
	statusStr := 'SUCCESS';
	isFatal := 'FALSE';

/*End of Ref Desgs */

/* SQL to fetch Substitute Component Details */
sqltxt :=	' SELECT										 '||
		' 	MIF1.PADDED_ITEM_NUMBER 		"Item Number (Assembly)"       		 '||
		' 	,bsb.ASSEMBLY_ITEM_ID 			"Assy Item Id" 				 '||
		' 	,MP1.ORGANIZATION_CODE			"Org Code"	         		 '||
		' 	,bsb.ORGANIZATION_ID 			"ORGANIZATION ID"         		 '||
		' 	,bsb.ALTERNATE_BOM_DESIGNATOR    	"ALTERNATE BOM DESIGNATOR"		 '||
		' 	,MIF2.PADDED_ITEM_NUMBER 		"Item Number (Component)" 		 '||
		' 	,BCB.COMPONENT_ITEM_ID         	    	"COMPONENT ITEM ID" 			 '||
		' 	,BCB.COMPONENT_SEQUENCE_ID		"COMPONENT SEQUENCE ID"		 	 '||
		' 	,MIF3.PADDED_ITEM_NUMBER                 "Item Number (Substitute)"		 '||
		' 	,BSCO.SUBSTITUTE_COMPONENT_ID	    	"SUBSTITUTE COMPONENT ID"		 '||
		' 	,to_char(BSCO.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "LAST UPDATE DATE"    '||
		' 	,BSCO.LAST_UPDATED_BY                	"LAST UPDATED BY"          		 '||
		' 	,to_char(BSCO.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'')    "CREATION DATE"       '||
		' 	,BSCO.CREATED_BY                     	"CREATED BY"               		 '||
		' 	,BSCO.LAST_UPDATE_LOGIN              	"LAST UPDATE LOGIN"        		 '||
		' 	,NVL(BSCO.SUBSTITUTE_ITEM_QUANTITY,0)	"SUBSTITUTE ITEM QUANTITY" 		 '||
		' 	,BSCO.COMPONENT_SEQUENCE_ID          	"COMPONENT SEQUENCE ID"    		 '||
		' 	,DECODE(MLU_ACD.MEANING,null,null, 						 '||
		' 		(MLU_ACD.MEANING || '' ('' || BSCO.ACD_TYPE || '')'')) "ACD TYPE"	 '||
		' 	,BSCO.CHANGE_NOTICE                   	"CHANGE NOTICE"            		 '||
		' 	,BSCO.REQUEST_ID                    		"REQUEST ID"               	 '||
		' 	,BSCO.PROGRAM_APPLICATION_ID        		"PROGRAM APPLICATION ID"   	 '||
		' 	,BSCO.PROGRAM_ID                    		"PROGRAM ID"               	 '||
		' 	,to_char(BSCO.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "PROGRAM UPDATE DATE"  '||
		' 	,BSCO.ATTRIBUTE_CATEGORY            		"ATTRIBUTE CATEGORY"       	 '||
		' 	,BSCO.ATTRIBUTE1                    		"ATTRIBUTE1"               	 '||
		' 	,BSCO.ATTRIBUTE2                    		"ATTRIBUTE2"               	 '||
		' 	,BSCO.ATTRIBUTE3                    		"ATTRIBUTE3"               	 '||
		' 	,BSCO.ATTRIBUTE4                    		"ATTRIBUTE4"               	 '||
		' 	,BSCO.ATTRIBUTE5                    		"ATTRIBUTE5"               	 '||
		' 	,BSCO.ATTRIBUTE6                    		"ATTRIBUTE6"               	 '||
		' 	,BSCO.ATTRIBUTE7                    		"ATTRIBUTE7"               	 '||
		' 	,BSCO.ATTRIBUTE8                    		"ATTRIBUTE8"               	 '||
		' 	,BSCO.ATTRIBUTE9                    		"ATTRIBUTE9"               	 '||
		' 	,BSCO.ATTRIBUTE10                   		"ATTRIBUTE10"              	 '||
		' 	,BSCO.ATTRIBUTE11                   		"ATTRIBUTE11"              	 '||
		' 	,BSCO.ATTRIBUTE12                   		"ATTRIBUTE12"              	 '||
		' 	,BSCO.ATTRIBUTE13                   		"ATTRIBUTE13"              	 '||
		' 	,BSCO.ATTRIBUTE14                   		"ATTRIBUTE14"              	 '||
		' 	,BSCO.ATTRIBUTE15                   		"ATTRIBUTE15"              	 '||
		' 	,BSCO.ORIGINAL_SYSTEM_REFERENCE     		"ORIGINAL SYSTEM REFERENCE"	 '||
		' 	,BSCO.ENFORCE_INT_REQUIREMENTS      		"ENFORCE INT REQUIREMENTS"	 '||
		' 	,BSCO.COMMON_COMPONENT_SEQUENCE_ID	"COMMON COMPONENT SEQUENCE ID"	 '||
		' 	FROM   										 '||
		' 	bom_components_b BCB 							 '||
		' 	,bom_structures_b bsb							 '||
		' 	,bom_substitute_components BSCO							 '||
		' 	,MTL_PARAMETERS MP1								 '||
		' 	,MTL_ITEM_FLEXFIELDS MIF1							 '||
		' 	,MTL_ITEM_FLEXFIELDS MIF2							 '||
		' 	,MTL_ITEM_FLEXFIELDS MIF3							 '||
		' 	,MFG_LOOKUPS MLU_ACD								 '||
		' 	where 1=1 									 '||
		' 	AND bsb.ORGANIZATION_ID = MP1.ORGANIZATION_ID 					 '||
		' 	AND bsb.ASSEMBLY_ITEM_ID = MIF1.INVENTORY_ITEM_ID				 '||
		' 	AND bsb.ORGANIZATION_ID = MIF1.ORGANIZATION_ID					 '||
		' 	AND BCB.COMPONENT_ITEM_ID = MIF2.INVENTORY_ITEM_ID				 '||
		' 	AND bsb.ORGANIZATION_ID = MIF2.ORGANIZATION_ID					 '||
		' 	AND BCB.BILL_SEQUENCE_ID = bsb.BILL_SEQUENCE_ID				 '||
		' 	AND BSCO.COMPONENT_SEQUENCE_ID = BCB.COMPONENT_SEQUENCE_ID			 '||
		' 	AND BSCO.SUBSTITUTE_COMPONENT_ID = MIF3.INVENTORY_ITEM_ID			 '||
		' 	AND bsb.ORGANIZATION_ID = MIF3.ORGANIZATION_ID					 '||
		' 	AND BSCO.ACD_TYPE = MLU_ACD.LOOKUP_CODE(+)					 '||
		' 	AND ''ECG_ACTION''=MLU_ACD.LOOKUP_TYPE(+)					 ';

	if l_org_id is not null then
	   sqltxt :=sqltxt||' and bsb.organization_id =  '||l_org_id;
	end if;

	if l_item_id is not null then
	   sqltxt :=sqltxt||' and bsb.assembly_item_id =  '||l_item_id;
	end if;

	sqltxt :=sqltxt||' and rownum <   '||row_limit;
	sqltxt :=sqltxt||' order by mp1.organization_code, mif1.padded_item_number, bsb.alternate_bom_designator,	'||
			 ' BCB.operation_seq_num ,mif2.padded_item_number, mif3.padded_item_number';
	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Bill Substitute Components ');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;
	statusStr := 'SUCCESS';
	isFatal := 'FALSE';

/* End of Substitute Component Details */

/* SQL to fetch the Routing Header Details */
 sqltxt := '	SELECT '||
	'	MIF1.PADDED_ITEM_NUMBER			"ASSEMBLY ITEM NUMBER",					     '||
	'	BOR1.ASSEMBLY_ITEM_ID			"ASSEMBLY ITEM ID",					     '||
	'	MP1.ORGANIZATION_CODE		   	"ORGANIZATION CODE",					     '||
	'	BOR1.ORGANIZATION_ID			"ORGANIZATION ID",					     '||
	'	BOR1.ALTERNATE_ROUTING_DESIGNATOR	"ALTERNATE ROUTING DESIGNATOR", 			     '||
	'	BOR1.ROUTING_SEQUENCE_ID      		"ROUTING SEQUENCE ID",					     '||
	'	to_char(BOR1.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "LAST UPDATE DATE",			     '||
	'	BOR1.LAST_UPDATED_BY 			"LAST UPDATED BY",					     '||
	'	to_char(BOR1.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'') "CREATION DATE",				     '||
	'	BOR1.CREATED_BY      			"CREATED BY",						     '||
	'	BOR1.LAST_UPDATE_LOGIN			"LAST UPDATE LOGIN",					     '||
	'	(DECODE(BOR1.ROUTING_TYPE,NULL,NULL,1,''Manufacturing (1)'', 2, ''Engineering (2)'',			'||
	'		''Other('' ||BOR1.ROUTING_TYPE|| '')''))		"ROUTING TYPE",				'||
	'	MIF2.PADDED_ITEM_NUMBER			"ITEM NUMBER (COMMON)",					     '||
	'	NVL(BOR1.COMMON_ASSEMBLY_ITEM_ID,BOR1.ASSEMBLY_ITEM_ID ) 	"COMMON ASSEMBLY ITEM ID",	     '||
	'	MP2.ORGANIZATION_CODE			"ORGANIZATION CODE (COMMON)",				     '||
	'	NVL(MP2.ORGANIZATION_ID,MP1.ORGANIZATION_ID)			"ORGANIZATION ID (COMMON)",	     '||
	'	BOR1.COMMON_ROUTING_SEQUENCE_ID		"COMMON ROUTING SEQUENCE ID",				     '||
	'	BOR1.ROUTING_COMMENT 			"ROUTING COMMENT",					     '||
	'	BOR1.COMPLETION_SUBINVENTORY  		"COMPLETION SUBINVENTORY",				     '||
	'	BOR1.COMPLETION_LOCATOR_ID    		"COMPLETION LOCATOR ID",				     '||
	'	BOR1.ATTRIBUTE_CATEGORY       		"ATTRIBUTE CATEGORY",					     '||
	'	BOR1.ATTRIBUTE1      			"ATTRIBUTE1",						     '||
	'	BOR1.ATTRIBUTE2      			"ATTRIBUTE2",						     '||
	'	BOR1.ATTRIBUTE3      			"ATTRIBUTE3",						     '||
	'	BOR1.ATTRIBUTE4      			"ATTRIBUTE4",						     '||
	'	BOR1.ATTRIBUTE5      			"ATTRIBUTE5",						     '||
	'	BOR1.ATTRIBUTE6     			"ATTRIBUTE6",						     '||
	'	BOR1.ATTRIBUTE7      			"ATTRIBUTE7",						     '||
	'	BOR1.ATTRIBUTE8      			"ATTRIBUTE8",						     '||
	'	BOR1.ATTRIBUTE9      			"ATTRIBUTE9",						     '||
	'	BOR1.ATTRIBUTE10     			"ATTRIBUTE10",						     '||
	'	BOR1.ATTRIBUTE11     			"ATTRIBUTE11",						     '||
	'	BOR1.ATTRIBUTE12     			"ATTRIBUTE12",						     '||
	'	BOR1.ATTRIBUTE13     			"ATTRIBUTE13",						     '||
	'	BOR1.ATTRIBUTE14    			"ATTRIBUTE14",						     '||
	'	BOR1.ATTRIBUTE15     			"ATTRIBUTE15",						     '||
	'	BOR1.REQUEST_ID      			"REQUEST ID",						     '||
	'	BOR1.PROGRAM_APPLICATION_ID   		"PROGRAM APPLICATION ID",				     '||
	'	BOR1.PROGRAM_ID      			"PROGRAM ID",						     '||
	'	to_char(BOR1.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "PROGRAM UPDATE DATE",			'||
	'	BOR1.LINE_ID				"LINE ID",						     '||
	'	DECODE(BOR1.CFM_ROUTING_FLAG,null,null,1,''Yes (1)'',2,''No (2)'',					'||
	'		''OTHER ('' || BOR1.CFM_ROUTING_FLAG || '')'') 	  	"CFM ROUTING FLAG",		     '||
	'	DECODE(BOR1.MIXED_MODEL_MAP_FLAG,null,null,1,''Yes (1)'',2,''No (2)'',				     '||
	'		''OTHER ('' || BOR1.MIXED_MODEL_MAP_FLAG || '')'')   	"MIXED MODEL MAP FLAG",		     '||
	'	BOR1.PRIORITY				"PRIORITY",						     '||
	'	BOR1.TOTAL_PRODUCT_CYCLE_TIME 		"TOTAL PRODUCT CYCLE TIME",				     '||
	'	DECODE(BOR1.CTP_FLAG,null,null,1,''Yes (1)'',2,''No (2)'',						'||
	'		''OTHER ('' || BOR1.CTP_FLAG || '')'')			"CTP FLAG",			     '||
	'	BOR1.PROJECT_ID      			"PROJECT ID",						     '||
	'	BOR1.TASK_ID				"TASK ID",						     '||
	'	BOR1.PENDING_FROM_ECN			"PENDING FROM ECN",					     '||
	'	BOR1.ORIGINAL_SYSTEM_REFERENCE		"ORIGINAL SYSTEM REFERENCE",				     '||
	'	BOR1.SERIALIZATION_START_OP   		"SERIALIZATION START OP"				     '||
	'	FROM bom_operational_routings bor1,								     '||
	'	mtl_parameters mp1, mtl_item_flexfields mif1,							     '||
	'	bom_operational_routings bor2,									     '||
	'	mtl_parameters mp2, mtl_item_flexfields mif2							     '||
	'	WHERE 1=1											     '||
	'	and bor1.assembly_item_id = mif1.inventory_item_id						     '||
	'	and bor1.organization_id = mif1.organization_id							     '||
	'	and mif1.organization_id = mp1.organization_id							     '||
	'	and nvl(bor1.common_routing_sequence_id,bor1.routing_sequence_id) = bor2.routing_sequence_id	     '||
	'	and bor2.assembly_item_id = mif2.inventory_item_id						     '||
	'	and bor2.organization_id =  mif2.organization_id						     '||
	'	and mif2.organization_id =  mp2.organization_id							     ';

	if l_org_id is not null then
	   sqltxt :=sqltxt||' and bor1.organization_id =  '||l_org_id;
	end if;

	if l_item_id is not null then
	   sqltxt :=sqltxt||' and bor1.assembly_item_id =  '||l_item_id;
	end if;

	sqltxt :=sqltxt||' and rownum <   '||row_limit;
	sqltxt :=sqltxt||' order by mp1.organization_code, mif1.padded_item_number, bor1.alternate_routing_designator';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Routing Headers ');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;
	statusStr := 'SUCCESS';
	isFatal := 'FALSE';

/* End of Routing Header Details */

/* SQL to fetch the Routing Operation Details */
sqltxt := '	SELECT '||
	'	MIF.PADDED_ITEM_NUMBER	   			  "ASSEMBLY ITEM NUMBER",						'||
	'	BOR.ASSEMBLY_ITEM_ID				  "ASSEMBLY ITEM ID",							'||
	'	MP.ORGANIZATION_CODE				  "ORGANIZATION CODE",							'||
	'	BOR.ORGANIZATION_ID				  "ORGANIZATION ID",							'||
	'	BOR.ALTERNATE_ROUTING_DESIGNATOR		"ALTERNATE ROUTING DESIGNATOR",						'||
	'	BOS.OPERATION_SEQUENCE_ID         		"OPERATION SEQUENCE ID",						'||
	'	BOS.ROUTING_SEQUENCE_ID           		"ROUTING SEQUENCE ID",							'||
	'	BOS.OPERATION_SEQ_NUM             		"OPERATION SEQ NUM",							'||
	'	to_char(BOS.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'')  "LAST UPDATE DATE ",						'||
	'	BOS.LAST_UPDATED_BY               		"LAST UPDATED BY",							'||
	'	to_char(BOS.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'')  "CREATION DATE",							'||
	'	BOS.CREATED_BY                    		"CREATED BY",								'||
	'	BOS.LAST_UPDATE_LOGIN             		"LAST UPDATE LOGIN",							'||
	'	BOS.STANDARD_OPERATION_ID         		"STANDARD OPERATION ID",						'||
	'	BOS.DEPARTMENT_ID                 		"DEPARTMENT ID",							'||
	'	BOS.OPERATION_LEAD_TIME_PERCENT   		"OPERATION LEAD TIME PERCENT",						'||
	'	BOS.MINIMUM_TRANSFER_QUANTITY     		"MINIMUM TRANSFER QUANTITY",						'||
	'	DECODE(MLU_BCPT.MEANING,null,null,											'||
	'		(MLU_BCPT.MEANING || '' ('' || BOS.COUNT_POINT_TYPE || '')'')) "Count Point Type",				'||
	'	BOS.OPERATION_DESCRIPTION			"OPERATION DESCRIPTION",						'||
	'	to_char(BOS.EFFECTIVITY_DATE,''DD-MON-YYYY HH24:MI:SS'') "EFFECTIVITY DATE",						'||
	'	to_char(BOS.DISABLE_DATE,''DD-MON-YYYY HH24:MI:SS'')     "DISABLE DATE",						'||
	'	DECODE(BOS.BACKFLUSH_FLAG,null,null,1,''Yes (1)'',2,''No (2)'',								'||
	'		''OTHER ('' || BOS.BACKFLUSH_FLAG || '')'') "Backflush Flag",							'||
	'	DECODE(BOS.OPTION_DEPENDENT_FLAG,null,null,1,''Yes (1)'',2,''No (2)'',							'||
	'		''OTHER ('' || BOS.OPTION_DEPENDENT_FLAG || '')'') "Option Dependent Flag",					'||
	'	BOS.ATTRIBUTE_CATEGORY            		"ATTRIBUTE CATEGORY ",							'||
	'	BOS.ATTRIBUTE1                    		"ATTRIBUTE1",								'||
	'	BOS.ATTRIBUTE2                    		"ATTRIBUTE2",								'||
	'	BOS.ATTRIBUTE3                    		"ATTRIBUTE3",								'||
	'	BOS.ATTRIBUTE4                    		"ATTRIBUTE4",								'||
	'	BOS.ATTRIBUTE5                    		"ATTRIBUTE5",								'||
	'	BOS.ATTRIBUTE6                    		"ATTRIBUTE6",								'||
	'	BOS.ATTRIBUTE7                    		"ATTRIBUTE7",								'||
	'	BOS.ATTRIBUTE8                    		"ATTRIBUTE8",								'||
	'	BOS.ATTRIBUTE9                    		"ATTRIBUTE9",								'||
	'	BOS.ATTRIBUTE10                   		"ATTRIBUTE10",								'||
	'	BOS.ATTRIBUTE11                   		"ATTRIBUTE11",								'||
	'	BOS.ATTRIBUTE12                   		"ATTRIBUTE12",								'||
	'	BOS.ATTRIBUTE13                   		"ATTRIBUTE13",								'||
	'	BOS.ATTRIBUTE14                   		"ATTRIBUTE14",								'||
	'	BOS.ATTRIBUTE15                   		"ATTRIBUTE15",								'||
	'	BOS.REQUEST_ID                    		"REQUEST ID",								'||
	'	BOS.PROGRAM_APPLICATION_ID        		"PROGRAM APPLICATION ID",						'||
	'	BOS.PROGRAM_ID                    		"PROGRAM ID",								'||
	'	to_char(BOS.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "PROGRAM UPDATE DATE",					'||
	'	DECODE(MLU_OPT.MEANING,null,null,											'||
	'		(MLU_OPT.MEANING || '' ('' || BOS.OPERATION_TYPE || '')'')) "Operation Type",		'||
	'	DECODE(BOS.REFERENCE_FLAG,null,null,1,''Yes (1)'',2,''No (2)'',						'||
	'		''OTHER ('' || BOS.REFERENCE_FLAG || '')'') 		"Reference Flag",				'||
	'	BOS.PROCESS_OP_SEQ_ID             		"PROCESS OP SEQ ID",						'||
	'	BOS.LINE_OP_SEQ_ID                		"LINE OP SEQ ID",							'||
	'	BOS.YIELD                         		"YIELD",										'||
	'	BOS.CUMULATIVE_YIELD              		"CUMULATIVE YIELD",						'||
	'	BOS.REVERSE_CUMULATIVE_YIELD      		"REVERSE CUMULATIVE YIELD",			'||
	'	BOS.LABOR_TIME_CALC               		"LABOR TIME CALC",						'||
	'	BOS.MACHINE_TIME_CALC             		"MACHINE TIME CALC",						'||
	'	BOS.TOTAL_TIME_CALC               		"TOTAL TIME CALC",							'||
	'	BOS.LABOR_TIME_USER               		"LABOR TIME USER",						'||
	'	BOS.MACHINE_TIME_USER             		"MACHINE TIME USER",						'||
	'	BOS.TOTAL_TIME_USER               		"TOTAL TIME USER",							'||
	'	BOS.NET_PLANNING_PERCENT          		"NET PLANNING PERCENT ",				'||
	'	BOS.X_COORDINATE                  		"X COORDINATE",							'||
	'	BOS.Y_COORDINATE                  		"Y COORDINATE",							'||
	'	DECODE(BOS.INCLUDE_IN_ROLLUP,null,null,1,''Yes (1)'',2,''No (2)'',					'||
	'		''OTHER ('' || BOS.INCLUDE_IN_ROLLUP || '')'')  "INCLUDE IN ROLLUP",				'||
	'	DECODE(BOS.OPERATION_YIELD_ENABLED,null,null,1,''Yes (1)'',2,''No (2)'',				'||
	'		''OTHER ('' || BOS.OPERATION_YIELD_ENABLED || '')'')    "OPERATION YIELD ENABLED",	'||
	'	BOS.OLD_OPERATION_SEQUENCE_ID     		"OLD OPERATION SEQUENCE ID",		'||
	'	DECODE(BOS.ACD_TYPE,null,null,1,''Add (1)'',2,''Change (2)'',3,''Delete (3)'',				'||
	'		''OTHER ('' || BOS.ACD_TYPE || '')'')  "ACD TYPE",								'||
	'	BOS.REVISED_ITEM_SEQUENCE_ID      	 	"REVISED ITEM SEQUENCE ID",			'||
	'	BOS.ORIGINAL_SYSTEM_REFERENCE     		"ORIGINAL SYSTEM REFERENCE",			'||
	'	BOS.CHANGE_NOTICE                 		"CHANGE NOTICE",							'||
	'	to_char(BOS.IMPLEMENTATION_DATE,''DD-MON-YYYY HH24:MI:SS'') "IMPLEMENTATION DATE",					'||
	'	DECODE(BOS.ECO_FOR_PRODUCTION,null,null,1,''Yes (1)'',2,''No (2)'',					'||
	'		''OTHER ('' || BOS.ECO_FOR_PRODUCTION || '')'')  "ECO FOR PRODUCTION ",			'||
	'	DECODE(MLU_SHT.MEANING,null,null,											'||
	'	(MLU_SHT.MEANING || '' ('' || BOS.SHUTDOWN_TYPE || '')''))             "SHUTDOWN TYPE",	'||
	'	BOS.ACTUAL_IPK                    		"ACTUAL IPK",									'||
	'	BOS.CRITICAL_TO_QUALITY           		"CRITICAL TO QUALITY",						'||
	'	BOS.VALUE_ADDED                   		"VALUE ADDED",							'||
	'	BOS.MACHINE_PROCESS_EFFICIENCY    		"MACHINE PROCESS EFFICIENCY",			'||
	'	BOS.LABOR_PROCESS_EFFICIENCY      		"LABOR PROCESS EFFICIENCY",			'||
	'	BOS.TOTAL_PROCESS_EFFICIENCY      		"TOTAL PROCESS EFFICIENCY",			'||
	'	BOS.LONG_DESCRIPTION              		"LONG DESCRIPTION"						'||
	'	,BOS.CONFIG_ROUTING_ID             		"CONFIG ROUTING ID"						'||
	'	,BOS.MODEL_OP_SEQ_ID               		"MODEL OP SEQ ID"							'||
	'	,BOS.LOWEST_ACCEPTABLE_YIELD    	"LOWEST ACCEPTABLE YIELD"					'||
	'	,BOS.USE_ORG_SETTINGS		    	"USE ORG SETTINGS"						'||
	'	,BOS.QUEUE_MANDATORY_FLAG	    	"QUEUE MANDATORY FLAG"					'||
	'	,BOS.RUN_MANDATORY_FLAG		    	"RUN MANDATORY FLAG"						'||
	'	,BOS.TO_MOVE_MANDATORY_FLAG	    	"TO MOVE MANDATORY FLAG"					'||
	'	,BOS.SHOW_NEXT_OP_BY_DEFAULT    	"SHOW NEXT OP BY DEFAULT"					'||
	'	,BOS.SHOW_SCRAP_CODE		    	"SHOW SCRAP CODE"						'||
	'	,BOS.SHOW_LOT_ATTRIB	 		    	"SHOW LOT ATTRIB"							'||
	'	,BOS.TRACK_MULTIPLE_RES_USAGE_DATES	    	"TRACK MULTIPLE RES USAGE DATES"	'||
	'	FROM    bom_operational_routings bor, bom_operation_sequences bos,							'||
	'	MTL_PARAMETERS MP, MTL_ITEM_FLEXFIELDS MIF										'||
	'	,MFG_LOOKUPS MLU_BCPT													'||
	'	,MFG_LOOKUPS MLU_OPT													'||
	'	,MFG_LOOKUPS MLU_SHT													'||
	'	WHERE 1=1 														'||
	'	AND  bos.routing_sequence_id=bor.routing_sequence_id									'||
	'	and  bor.assembly_item_id = mif.inventory_item_id									'||
	'	and  bor.organization_id = mif.organization_id										'||
	'	and  mif.organization_id = mp.organization_id										'||
	'	and  bos.count_point_type=mlu_bcpt.lookup_code(+) and ''BOM_COUNT_POINT_TYPE''=mlu_bcpt.lookup_type(+)			'||
	'	and  bos.operation_type=mlu_opt.lookup_code(+) and ''BOM_OPERATION_TYPE''=mlu_opt.lookup_type(+)			'||
	'	and  bos.shutdown_type=mlu_sht.lookup_code(+) and ''BOM_EAM_SHUTDOWN_TYPE''=mlu_sht.lookup_type(+)			';

	if l_org_id is not null then
	   sqltxt :=sqltxt||' and bor.organization_id =  '||l_org_id;
	end if;

	if l_item_id is not null then
	   sqltxt :=sqltxt||' and bor.assembly_item_id =  '||l_item_id;
	end if;

	sqltxt :=sqltxt||' and rownum <   '||row_limit;
	sqltxt :=sqltxt||' order by mp.organization_code, mif.padded_item_number,  bor.alternate_routing_designator,'||
			 ' bos.operation_seq_num ';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Routing Operations ');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;
	statusStr := 'SUCCESS';
	isFatal := 'FALSE';
/* End of Routing Operation Details */

/* SQL to fetch the Operation Resource Details */
sqltxt := '	SELECT '||
	'	MIF.PADDED_ITEM_NUMBER			"ASSEMBLY ITEM NUMBER",						'||
	'	BOR.ASSEMBLY_ITEM_ID		   	"ASSEMBLY ITEM ID",						'||
	'	MP.ORGANIZATION_CODE			"ORGANIZATION CODE",						'||
	'	BOR.ORGANIZATION_ID 			"ORGANIZATION ID",						'||
	'	BOR.ALTERNATE_ROUTING_DESIGNATOR	"ALTERNATE ROUTING DESIGNATOR", 				'||
	'	BOR.ROUTING_SEQUENCE_ID			"ROUTING SEQUENCE ID",						'||
	'	BOS.OPERATION_SEQ_NUM			"OPERATION SEQ NUM",						'||
	'	BORE.OPERATION_SEQUENCE_ID            	"OPERATION SEQUENCE ID",					'||
	'	BORE.RESOURCE_SEQ_NUM                 	"RESOURCE SEQ NUM",						'||
	'	BR.RESOURCE_CODE			"RESOURCE CODE",						'||
	'	BORE.RESOURCE_ID                      	"RESOURCE ID",						        '||
	'	BR.DESCRIPTION				"RESOURCE DESCRIPTION",						'||
	'	BORE.ACTIVITY_ID                      	"ACTIVITY ID",							'||
	'	DECODE(BORE.STANDARD_RATE_FLAG,null,null,1,''Yes (1)'',2,''No (2)'',					'||
	'		''OTHER ('' || BORE.STANDARD_RATE_FLAG || '')'')    "STANDARD RATE FLAG",			'||
	'	BORE.ASSIGNED_UNITS                   	"ASSIGNED UNITS",						'||
	'	BORE.USAGE_RATE_OR_AMOUNT             	"USAGE RATE OR AMOUNT",						'||
	'	BORE.USAGE_RATE_OR_AMOUNT_INVERSE     	"USAGE RATE OR AMOUNT INVERSE",					'||
	'	DECODE(MLU_BT.MEANING,null,null,									'||
	'		(MLU_BT.MEANING || '' ('' || BORE.BASIS_TYPE || '')''))	"BASIS TYPE",				'||
	'	DECODE(MLU_SF.MEANING,null,null,									'||
	'		(MLU_SF.MEANING || '' ('' || BORE.SCHEDULE_FLAG || '')''))  "SCHEDULE FLAG",			'||
	'	to_char(BORE.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "LAST UPDATE DATE",				'||
	'	BORE.LAST_UPDATED_BY                  	"LAST UPDATED BY",						'||
	'	to_char(BORE.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'')    "CREATION DATE",				'||
	'	BORE.CREATED_BY                       	"CREATED BY",							'||
	'	BORE.LAST_UPDATE_LOGIN                	"LAST UPDATE LOGIN",						'||
	'	BORE.RESOURCE_OFFSET_PERCENT          	"RESOURCE OFFSET PERCENT",					'||
	'	DECODE(MLU_ACT.MEANING,null,null,									'||
	'		(MLU_ACT.MEANING || '' ('' || BORE.AUTOCHARGE_TYPE || '')'')) "AUTOCHARGE TYPE",		'||
	'	BORE.ATTRIBUTE_CATEGORY               	"ATTRIBUTE CATEGORY",						'||
	'	BORE.ATTRIBUTE1                       	"ATTRIBUTE1",							'||
	'	BORE.ATTRIBUTE2                       	"ATTRIBUTE2",							'||
	'	BORE.ATTRIBUTE3                       	"ATTRIBUTE3",							'||
	'	BORE.ATTRIBUTE4                       	"ATTRIBUTE4",							'||
	'	BORE.ATTRIBUTE5                       	"ATTRIBUTE5",							'||
	'	BORE.ATTRIBUTE6                       	"ATTRIBUTE6",							'||
	'	BORE.ATTRIBUTE7                       	"ATTRIBUTE7",							'||
	'	BORE.ATTRIBUTE8                       	"ATTRIBUTE8",							'||
	'	BORE.ATTRIBUTE9                       	"ATTRIBUTE9",							'||
	'	BORE.ATTRIBUTE10                      	"ATTRIBUTE10",							'||
	'	BORE.ATTRIBUTE11                      	"ATTRIBUTE11",							'||
	'	BORE.ATTRIBUTE12                      	"ATTRIBUTE12",							'||
	'	BORE.ATTRIBUTE13                      	"ATTRIBUTE13",							'||
	'	BORE.ATTRIBUTE14                      	"ATTRIBUTE14",							'||
	'	BORE.ATTRIBUTE15                      	"ATTRIBUTE15",							'||
	'	BORE.REQUEST_ID                       	"REQUEST ID",							'||
	'	BORE.PROGRAM_APPLICATION_ID           	"PROGRAM APPLICATION ID",					'||
	'	BORE.PROGRAM_ID                       	"PROGRAM ID",							'||
	'	to_char(BORE.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "PROGRAM UPDATE DATE",			'||
	'	BORE.SCHEDULE_SEQ_NUM                 	"SCHEDULE SEQ NUM",						'||
	'	BORE.SUBSTITUTE_GROUP_NUM             	"SUBSTITUTE GROUP NUM",						'||
	'	DECODE(BORE.PRINCIPLE_FLAG,null,null,1,''Yes (1)'',2,''No (2)'',					'||
	'			''OTHER ('' || BORE.PRINCIPLE_FLAG || '')'')   	"PRINCIPLE FLAG",			'||
	'	BORE.SETUP_ID                         	"SETUP ID",							'||
	'	BORE.CHANGE_NOTICE                    	"CHANGE NOTICE",						'||
	'	DECODE(BORE.ACD_TYPE,null,null,1,''Add (1)'',2,''Change (2)'',3,''Delete (3)'',				'||
	'			''OTHER ('' || BORE.ACD_TYPE || '')'')   	"ACD TYPE",				'||
	'	BORE.ORIGINAL_SYSTEM_REFERENCE        	"ORIGINAL SYSTEM REFERENCE"					'||
	'	FROM BOM_OPERATIONAL_ROUTINGS BOR, BOM_OPERATION_SEQUENCES BOS,						'||
	'	     BOM_OPERATION_RESOURCES BORE, bom_resources br,							'||
	'		 MTL_PARAMETERS MP, MTL_ITEM_FLEXFIELDS MIF,							'||
	'		 MFG_LOOKUPS MLU_BT, MFG_LOOKUPS MLU_SF,							'||
	'	 	 MFG_LOOKUPS MLU_ACT										'||
	'	 WHERE 1=1												'||
	'	 AND bos.routing_sequence_id=bor.routing_sequence_id							'||
	'	 AND bore.operation_sequence_id=bos.operation_sequence_id						'||
	'	 and  bor.assembly_item_id = mif.inventory_item_id							'||
	'	 and  bor.organization_id = mif.organization_id								'||
	'	 and  mif.organization_id = mp.organization_id								'||
	'	 AND  bore.resource_id	= br.resource_id								'||
	'	 AND BORE.BASIS_TYPE=MLU_BT.LOOKUP_CODE(+) AND ''CST_BASIS''=MLU_BT.LOOKUP_TYPE(+)			'||
	'	 AND BORE.SCHEDULE_FLAG=MLU_SF.LOOKUP_CODE(+) AND ''BOM_RESOURCE_SCHEDULE_TYPE''=MLU_SF.LOOKUP_TYPE(+)	'||
 	'	 AND BORE.AUTOCHARGE_TYPE=MLU_ACT.LOOKUP_CODE(+) AND ''BOM_AUTOCHARGE_TYPE''=MLU_ACT.LOOKUP_TYPE(+)	';

	if l_org_id is not null then
		sqltxt :=sqltxt||' and bor.organization_id =  '||l_org_id;
	end if;

	if l_item_id is not null then
	   sqltxt :=sqltxt||' and bor.assembly_item_id =  '||l_item_id;
	end if;

	sqltxt :=sqltxt||' and rownum <   '||row_limit;
	sqltxt :=sqltxt||' order by mp.organization_code, mif.padded_item_number,  bor.alternate_routing_designator,'||
			 ' bos.operation_seq_num, bore.resource_seq_num, br.resource_code ';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Routing Operation Resources ');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;
	statusStr := 'SUCCESS';
	isFatal := 'FALSE';

/* End of Operation Resource Details */

/* SQL to fetch the Operation Sub Resource Details */
sqltxt := '	 SELECT '||
	'	 MIF.PADDED_ITEM_NUMBER			"ASSEMBLY ITEM NUMBER",					 '||
	'	 BOR.ASSEMBLY_ITEM_ID			"ASSEMBLY ITEM ID",					 '||
	'	 MP.ORGANIZATION_CODE			"ORGANIZATION CODE",					 '||
	'	 BOR.ORGANIZATION_ID 			"ORGANIZATION ID",					 '||
	'	 BOR.ALTERNATE_ROUTING_DESIGNATOR	"ALTERNATE ROUTING DESIGNATOR", 			 '||
	'	 BOR.ROUTING_SEQUENCE_ID		"ROUTING SEQUENCE ID",					 '||
	'	 BOS.OPERATION_SEQ_NUM			"OPERATION SEQ NUM",					 '||
	'	 BSOR.OPERATION_SEQUENCE_ID	       "OPERATION SEQUENCE ID",					 '||
	'	 BSOR.SUBSTITUTE_GROUP_NUM	       "SUBSTITUTE GROUP NUM",					 '||
	'	 BR.RESOURCE_CODE			"RESOURCE CODE",					 '||
	'	 BSOR.RESOURCE_ID                      	"RESOURCE ID",						 '||
	'	 BR.DESCRIPTION				"RESOURCE DESCRIPTION",					 '||
	'	 BSOR.SCHEDULE_SEQ_NUM		       "SCHEDULE SEQ NUM",					 '||
	'	 BSOR.REPLACEMENT_GROUP_NUM	       "REPLACEMENT GROUP NUM",					 '||
	'	 BSOR.ACTIVITY_ID		       "ACTIVITY ID",						 '||
	'	 DECODE(BSOR.STANDARD_RATE_FLAG,null,null,1,''Yes (1)'',2,''No (2)'',				 '||
	'	 	''OTHER ('' || BSOR.STANDARD_RATE_FLAG || '')'')   "STANDARD RATE FLAG",		 '||
	'	 BSOR.ASSIGNED_UNITS		       "ASSIGNED UNITS",					 '||
	'	 BSOR.USAGE_RATE_OR_AMOUNT	       "USAGE RATE OR AMOUNT",					 '||
	'	 BSOR.USAGE_RATE_OR_AMOUNT_INVERSE     "USAGE RATE OR AMOUNT INVERSE",				 '||
	'	 DECODE(MLU_BT.MEANING,null,null,								 '||
	'	 	(MLU_BT.MEANING || '' ('' || BSOR.BASIS_TYPE || '')''))      "BASIS TYPE",		 '||
	'	 DECODE(MLU_SF.MEANING,null,null,								 '||
	'	 	(MLU_SF.MEANING || '' ('' || BSOR.SCHEDULE_FLAG || '')''))   "SCHEDULE FLAG",		 '||
	'	 to_char(BSOR.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "LAST UPDATE DATE",			 '||
	'	 BSOR.LAST_UPDATED_BY		       "LAST UPDATED BY",					 '||
	'	 to_char(BSOR.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'')	"CREATION DATE",			 '||
	'	 BSOR.CREATED_BY		       "CREATED BY",						 '||
	'	 BSOR.LAST_UPDATE_LOGIN		       "LAST UPDATE LOGIN",					 '||
	'	 BSOR.RESOURCE_OFFSET_PERCENT	       "RESOURCE OFFSET PERCENT",				 '||
	'	 DECODE(MLU_ACT.MEANING,null,null,								 '||
	'	 	(MLU_ACT.MEANING || '' ('' || BSOR.AUTOCHARGE_TYPE || '')'')) "AUTOCHARGE TYPE",	 '||
	'	 BSOR.ATTRIBUTE_CATEGORY	       "ATTRIBUTE CATEGORY",					 '||
	'	 BSOR.REQUEST_ID		       "REQUEST ID",						 '||
	'	 BSOR.PROGRAM_APPLICATION_ID	       "PROGRAM APPLICATION ID",				 '||
	'	 BSOR.PROGRAM_ID		       "PROGRAM ID",						 '||
	'	 to_char(BSOR.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "PROGRAM UPDATE DATE",		 '||
	'	 BSOR.ATTRIBUTE1		       "ATTRIBUTE1",						 '||
	'	 BSOR.ATTRIBUTE2		       "ATTRIBUTE2",						 '||
	'	 BSOR.ATTRIBUTE3		       "ATTRIBUTE3",						 '||
	'	 BSOR.ATTRIBUTE4		       "ATTRIBUTE4",						 '||
	'	 BSOR.ATTRIBUTE5		       "ATTRIBUTE5",						 '||
	'	 BSOR.ATTRIBUTE6		       "ATTRIBUTE6",						 '||
	'	 BSOR.ATTRIBUTE7		       "ATTRIBUTE7",						 '||
	'	 BSOR.ATTRIBUTE8		       "ATTRIBUTE8",						 '||
	'	 BSOR.ATTRIBUTE9		       "ATTRIBUTE9",						 '||
	'	 BSOR.ATTRIBUTE10		       "ATTRIBUTE10",						 '||
	'	 BSOR.ATTRIBUTE11		       "ATTRIBUTE11",						 '||
	'	 BSOR.ATTRIBUTE12		       "ATTRIBUTE12",						 '||
	'	 BSOR.ATTRIBUTE13		       "ATTRIBUTE13",						 '||
	'	 BSOR.ATTRIBUTE14		       "ATTRIBUTE14",						 '||
	'	 BSOR.ATTRIBUTE15		       "ATTRIBUTE15",						 '||
	'	 DECODE(BSOR.PRINCIPLE_FLAG,null,null,1,''Yes (1)'',2,''No (2)'',				 '||
	'	 	''OTHER ('' || BSOR.PRINCIPLE_FLAG || '')'')   	"PRINCIPLE FLAG",			 '||
	'	 BSOR.SETUP_ID			       "SETUP ID",						 '||
	'	 BSOR.CHANGE_NOTICE		       "CHANGE NOTICE",						 '||
	'	 DECODE(BSOR.ACD_TYPE,null,null,1,''Add (1)'',2,''Change (2)'',3,''Delete (3)'',		 '||
	'	 	''OTHER ('' || BSOR.ACD_TYPE || '')'')   	"ACD TYPE",				 '||
	'	 BSOR.ORIGINAL_SYSTEM_REFERENCE	       "ORIGINAL SYSTEM REFERENCE"				 '||
	'  FROM BOM_OPERATIONAL_ROUTINGS BOR, BOM_OPERATION_SEQUENCES BOS,					 '||
	'	      BOM_SUB_OPERATION_RESOURCES BSOR, bom_resources br,					 '||
	'	  	  MTL_PARAMETERS MP, MTL_ITEM_FLEXFIELDS MIF,						 '||
	'	   	  MFG_LOOKUPS MLU_BT, MFG_LOOKUPS MLU_SF,						 '||
	'	   	  MFG_LOOKUPS MLU_ACT									 '||
	'  WHERE 1=1												 '||
	'	  AND bos.routing_sequence_id=bor.routing_sequence_id						 '||
	'	  AND bsor.operation_sequence_id=bos.operation_sequence_id					 '||
	'	  and  bor.assembly_item_id = mif.inventory_item_id						 '||
	'	  and  bor.organization_id = mif.organization_id						 '||
	'	  and  mif.organization_id = mp.organization_id 						 '||
	'	  and  bsor.resource_id = br.resource_id							 '||
	'	  AND  BSOR.BASIS_TYPE=MLU_BT.LOOKUP_CODE(+) 							 '||
	'	  	AND ''CST_BASIS''=MLU_BT.LOOKUP_TYPE(+)							 '||
	'	  AND  BSOR.SCHEDULE_FLAG=MLU_SF.LOOKUP_CODE(+)							 '||
	'	  	AND ''BOM_RESOURCE_SCHEDULE_TYPE''=MLU_SF.LOOKUP_TYPE(+)				 '||
	'	  AND  BSOR.AUTOCHARGE_TYPE=MLU_ACT.LOOKUP_CODE(+)						 '||
	'	  	AND ''BOM_AUTOCHARGE_TYPE''=MLU_ACT.LOOKUP_TYPE(+) 	   				 ';

	if l_org_id is not null then
	   sqltxt :=sqltxt||' and bor.organization_id =  '||l_org_id;
	end if;

	if l_item_id is not null then
	   sqltxt :=sqltxt||' and bor.assembly_item_id =  '||l_item_id;
	end if;

	sqltxt :=sqltxt||' and rownum <   '||row_limit;
	sqltxt :=sqltxt||' order by mp.organization_code, mif.padded_item_number,  bor.alternate_routing_designator,'||
			 ' bos.operation_seq_num,bsor.substitute_group_num,bsor.replacement_group_num,br.resource_code';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Routing Operation Sub Resources ');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;
	statusStr := 'SUCCESS';
	isFatal := 'FALSE';
/* End of Operation Resource Details */

/* SQL to fetch Routing Revision Details */
sqltxt := '	SELECT '||
	'	MIF.PADDED_ITEM_NUMBER		"ASSEMBLY ITEM NUMBER",		     	'||
	'	MRIR.INVENTORY_ITEM_ID		"INVENTORY ITEM ID",		     	'||
	'	MP.ORGANIZATION_CODE		"ORGANIZATION CODE",		     	'||
	'	MRIR.ORGANIZATION_ID		"ORGANIZATION ID",	     	     	'||
	'	MRIR.PROCESS_REVISION		"PROCESS REVISION",	     	     	'||
	'	to_char(MRIR.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "LAST UPDATE DATE",	'||
      	'	MRIR.LAST_UPDATED_BY		"LAST UPDATED BY",	     		'||
      	'	to_char(MRIR.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'')	"CREATION DATE",	'||
	'	MRIR.CREATED_BY			"CREATED BY",		     		'||
      	'	MRIR.LAST_UPDATE_LOGIN		"LAST UPDATE LOGIN",	     		'||
      	'	MRIR.CHANGE_NOTICE		"CHANGE NOTICE",	     		'||
      	'	to_char(MRIR.ECN_INITIATION_DATE,''DD-MON-YYYY HH24:MI:SS'')	 "ECN INITIATION DATE",	   '||
      	'	to_char(MRIR.IMPLEMENTATION_DATE,''DD-MON-YYYY HH24:MI:SS'')	"IMPLEMENTATION DATE",	   '||
     	'	MRIR.IMPLEMENTED_SERIAL_NUMBER	"IMPLEMENTED SERIAL NUMBER", 		'||
      	'	to_char(MRIR.EFFECTIVITY_DATE,''DD-MON-YYYY HH24:MI:SS'')	"EFFECTIVITY DATE",	   '||
      	'	MRIR.ATTRIBUTE_CATEGORY		"ATTRIBUTE CATEGORY",	     		'||
      	'	MRIR.ATTRIBUTE1			"ATTRIBUTE1",		     		'||
      	'	MRIR.ATTRIBUTE2			"ATTRIBUTE2",		     		'||
      	'	MRIR.ATTRIBUTE3			"ATTRIBUTE3",		     		'||
      	'	MRIR.ATTRIBUTE4			"ATTRIBUTE4",		     		'||
      	'	MRIR.ATTRIBUTE5			"ATTRIBUTE5",		     		'||
      	'	MRIR.ATTRIBUTE6			"ATTRIBUTE6",		     		'||
      	'	MRIR.ATTRIBUTE7			"ATTRIBUTE7",		     		'||
      	'	MRIR.ATTRIBUTE8			"ATTRIBUTE8",		     		'||
      	'	MRIR.ATTRIBUTE9			"ATTRIBUTE9",		     		'||
      	'	MRIR.ATTRIBUTE10		"ATTRIBUTE10",		     		'||
      	'	MRIR.ATTRIBUTE11		"ATTRIBUTE11",		     		'||
      	'	MRIR.ATTRIBUTE12		"ATTRIBUTE12",		     		'||
      	'	MRIR.ATTRIBUTE13		"ATTRIBUTE13",		     		'||
      	'	MRIR.ATTRIBUTE14		"ATTRIBUTE14",		     		'||
      	'	MRIR.ATTRIBUTE15		"ATTRIBUTE15",		     		'||
      	'	MRIR.REQUEST_ID			"REQUEST ID",		     		'||
      	'	MRIR.PROGRAM_APPLICATION_ID	"PROGRAM APPLICATION ID",    		'||
      	'	MRIR.PROGRAM_ID			"PROGRAM ID",		     		'||
      	'	to_char(MRIR.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "PROGRAM UPDATE DATE",	  '||
      	'	MRIR.REVISED_ITEM_SEQUENCE_ID	"REVISED ITEM SEQUENCE ID"   		'||
      	'	from mtl_rtg_item_revisions mrir,				     	'||
	'  	     MTL_PARAMETERS MP, MTL_ITEM_FLEXFIELDS MIF			     	'||
	'  	where 1=1							     	'||
	'  	and  mrir.inventory_item_id=  mif.inventory_item_id		     	'||
	'  	and  mrir.organization_id =   mif.organization_id		     	'||
	'  	and  mif.organization_id =   mp.organization_id				';

	if l_org_id is not null then
	   sqltxt :=sqltxt||' and mrir.organization_id =  '||l_org_id;
	end if;

	if l_item_id is not null then
	   sqltxt :=sqltxt||' and mrir.inventory_item_id =  '||l_item_id;
	end if;

	sqltxt :=sqltxt||' and rownum <   '||row_limit;
	sqltxt :=sqltxt||' order by mp.organization_code, mif.padded_item_number, mrir.process_revision';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Routing Revisions ');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;
	statusStr := 'SUCCESS';
	isFatal := 'FALSE';

/* End of Routing Revision Details */

/* SQL to fetch the Operation Network Details */
sqltxt := ' SELECT '||
	'	MIF.PADDED_ITEM_NUMBER			"ASSEMBLY ITEM NUMBER",			'||
	'	BOR.ASSEMBLY_ITEM_ID		   	"ASSEMBLY ITEM ID",			'||
	'	MP.ORGANIZATION_CODE			"ORGANIZATION CODE",			'||
	'     	BOR.ORGANIZATION_ID 			"ORGANIZATION ID",			'||
	'     	BOR.ALTERNATE_ROUTING_DESIGNATOR	"ALTERNATE ROUTING DESIGNATOR",		'||
	'     	BOR.ROUTING_SEQUENCE_ID			"ROUTING SEQUENCE ID",			'||
	'     	BON.FROM_OP_SEQ_ID			"FROM OP SEQ ID",			'||
	'     	BON.TO_OP_SEQ_ID			"TO OP SEQ ID",				'||
	'     	BON.TRANSITION_TYPE		      	"TRANSITION TYPE",			'||
	'     	BON.PLANNING_PCT			"PLANNING PCT",				'||
	'     	to_char(BON.EFFECTIVITY_DATE,''DD-MON-YYYY HH24:MI:SS'') "EFFECTIVITY DATE",	'||
	'     	to_char(BON.DISABLE_DATE,''DD-MON-YYYY HH24:MI:SS'')	 "DISABLE DATE",	'||
	'     	BON.CREATED_BY			      	"CREATED BY",				'||
	'     	to_char(BON.CREATION_DATE,''DD-MON-YYYY HH24:MI:SS'')	"CREATION DATE",	'||
	'     	BON.LAST_UPDATED_BY		      	"LAST UPDATED BY",			'||
	'     	to_char(BON.LAST_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'') "LAST UPDATE DATE",	'||
	'     	BON.LAST_UPDATE_LOGIN		      	"LAST UPDATE LOGIN",			'||
	'     	BON.ATTRIBUTE_CATEGORY		      	"ATTRIBUTE CATEGORY",			'||
	'     	BON.ATTRIBUTE1			      	"ATTRIBUTE1",				'||
	'     	BON.ATTRIBUTE2			      	"ATTRIBUTE2",				'||
	'     	BON.ATTRIBUTE3			      	"ATTRIBUTE3",				'||
	'     	BON.ATTRIBUTE4			      	"ATTRIBUTE4",				'||
	'     	BON.ATTRIBUTE5			      	"ATTRIBUTE5",				'||
	'     	BON.ATTRIBUTE6			      	"ATTRIBUTE6",				'||
	'     	BON.ATTRIBUTE7			      	"ATTRIBUTE7",				'||
	'     	BON.ATTRIBUTE8			      	"ATTRIBUTE8",				'||
	'     	BON.ATTRIBUTE9			      	"ATTRIBUTE9",				'||
	'     	BON.ATTRIBUTE10			      	"ATTRIBUTE10",				'||
	'     	BON.ATTRIBUTE11			      	"ATTRIBUTE11",				'||
	'     	BON.ATTRIBUTE12			      	"ATTRIBUTE12",				'||
	'     	BON.ATTRIBUTE13			      	"ATTRIBUTE13",				'||
	'     	BON.ATTRIBUTE14			      	"ATTRIBUTE14",				'||
	'     	BON.ATTRIBUTE15			      	"ATTRIBUTE15",				'||
	'     	BON.ORIGINAL_SYSTEM_REFERENCE	      	"ORIGINAL SYSTEM REFERENCE",		'||
	'     	BON.REQUEST_ID			      	"REQUEST ID",		'||
	'     	BON.PROGRAM_APPLICATION_ID	"PROGRAM APPLICATION ID",		'||
	'     	BON.PROGRAM_ID				"PROGRAM ID",		'||
	'     	to_char(BON.PROGRAM_UPDATE_DATE,''DD-MON-YYYY HH24:MI:SS'')	"PROGRAM UPDATE DATE"		'||
	'  	FROM bom_operational_routings bor, bom_operation_sequences bos,			'||
	'  	     bom_operation_networks bon,						'||
	'  	     MTL_PARAMETERS MP, MTL_ITEM_FLEXFIELDS MIF					'||
	'  	WHERE 1=1									'||
	'  	AND  bos.routing_sequence_id=bor.routing_sequence_id				'||
	'  	AND  bon.to_op_seq_id=bos.operation_sequence_id					'||
	'  	and  bor.assembly_item_id = mif.inventory_item_id				'||
	'  	and  bor.organization_id = mif.organization_id					'||
	'  	and  mif.organization_id = mp.organization_id					';


	if l_org_id is not null then
	   sqltxt :=sqltxt||' and bor.organization_id =  '||l_org_id;
	end if;

	if l_item_id is not null then
	   sqltxt :=sqltxt||' and bor.assembly_item_id =  '||l_item_id;
	end if;

	sqltxt :=sqltxt||' and rownum <   '||row_limit;
	sqltxt :=sqltxt||' order by mp.organization_code, mif.padded_item_number, bor.alternate_routing_designator,'||
			 ' bos.operation_seq_num, bon.from_op_seq_id, bon.to_op_seq_id ';

	num_rows:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Routing Operation Networks ');
	If (num_rows = row_limit -1 ) Then
		JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR/> Output of the above table is limited to the first '||(row_limit-1)||' rows to prevent an excessively big output file. <BR/>');
	End If;

	statusStr := 'SUCCESS';
	isFatal := 'FALSE';
/* End of  Operation Network Details */


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
     fixInfo := 'Unexpected Exception in BOMDGIBB.pls';
     isFatal := 'FALSE';
     report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
     reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;

END runTest;

PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'Items/Bills/Routings Data Collection';
END getComponentName;

PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2) IS
BEGIN
descStr := ' This data collection script collects data about Items/Bills/Routings details. <BR/>
	     Input for ItemId field is mandatory. ';
END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'Items/Bills/Routings Data Collection ';
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
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'ItemId','LOV-oracle.apps.bom.diag.lov.ItemLov');-- Lov name modified to ItemId for bug 6412260
defaultInputValues := tempInput;
EXCEPTION
when others then
defaultInputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
END getDefaultTestParams;

Function getTestMode return INTEGER IS
BEGIN
 return JTF_DIAGNOSTIC_ADAPTUTIL.ADVANCED_MODE;

END getTestMode;

END BOM_DIAGUNITTEST_IBRDATA;

/
