--------------------------------------------------------
--  DDL for Package INV_ITEM_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_ITEM_GRP" AUTHID CURRENT_USER AS
/* $Header: INVGITMS.pls 120.3.12010000.4 2010/01/07 08:27:50 snandana ship $ */

-- ------------------------------------------------------------
-- -------------- Global variables and constants --------------
-- ------------------------------------------------------------

g_MISS_CHAR     VARCHAR2(1)  :=  fnd_api.g_MISS_CHAR;
g_MISS_NUM      NUMBER       :=  fnd_api.g_MISS_NUM;
g_MISS_DATE     DATE         :=  fnd_api.g_MISS_DATE;

-- ------------------------------------------------------
-- -------------------- Global types --------------------
-- ------------------------------------------------------

TYPE Item_rec_type IS RECORD
(
   ORGANIZATION_ID                      NUMBER          :=  g_MISS_NUM
,  ORGANIZATION_CODE                    VARCHAR2(3)     :=  g_MISS_CHAR
,  INVENTORY_ITEM_ID                    NUMBER          :=  g_MISS_NUM
,  ITEM_NUMBER                          VARCHAR2(2000)  :=  g_MISS_CHAR
,	SEGMENT1                       	VARCHAR2(40) 	:=  g_MISS_CHAR
,	SEGMENT2                       	VARCHAR2(40) 	:=  g_MISS_CHAR
,	SEGMENT3                       	VARCHAR2(40) 	:=  g_MISS_CHAR
,	SEGMENT4                       	VARCHAR2(40) 	:=  g_MISS_CHAR
,	SEGMENT5                       	VARCHAR2(40) 	:=  g_MISS_CHAR
,	SEGMENT6                       	VARCHAR2(40) 	:=  g_MISS_CHAR
,	SEGMENT7                       	VARCHAR2(40) 	:=  g_MISS_CHAR
,	SEGMENT8                       	VARCHAR2(40) 	:=  g_MISS_CHAR
,	SEGMENT9                       	VARCHAR2(40) 	:=  g_MISS_CHAR
,	SEGMENT10                      	VARCHAR2(40) 	:=  g_MISS_CHAR
,	SEGMENT11                      	VARCHAR2(40) 	:=  g_MISS_CHAR
,	SEGMENT12                      	VARCHAR2(40) 	:=  g_MISS_CHAR
,	SEGMENT13                      	VARCHAR2(40) 	:=  g_MISS_CHAR
,	SEGMENT14                      	VARCHAR2(40) 	:=  g_MISS_CHAR
,	SEGMENT15                      	VARCHAR2(40) 	:=  g_MISS_CHAR
,	SEGMENT16                      	VARCHAR2(40) 	:=  g_MISS_CHAR
,	SEGMENT17                      	VARCHAR2(40) 	:=  g_MISS_CHAR
,	SEGMENT18                      	VARCHAR2(40) 	:=  g_MISS_CHAR
,	SEGMENT19                      	VARCHAR2(40) 	:=  g_MISS_CHAR
,	SEGMENT20                      	VARCHAR2(40) 	:=  g_MISS_CHAR
,	SUMMARY_FLAG                   	VARCHAR2(1)  	:=  g_MISS_CHAR
,	ENABLED_FLAG                   	VARCHAR2(1)  	:=  g_MISS_CHAR
,	START_DATE_ACTIVE              	DATE         	:=  g_MISS_DATE
,	END_DATE_ACTIVE                	DATE         	:=  g_MISS_DATE
 --
 -- Main attributes
 --
,	DESCRIPTION                    	VARCHAR2(240)	:=  g_MISS_CHAR
,	LONG_DESCRIPTION               	VARCHAR2(4000)	:=  g_MISS_CHAR
,	PRIMARY_UOM_CODE               	VARCHAR2(3)  	:=  g_MISS_CHAR
,	PRIMARY_UNIT_OF_MEASURE        	VARCHAR2(25) 	:=  g_MISS_CHAR
,	ITEM_TYPE                      	VARCHAR2(30) 	:=  g_MISS_CHAR
,	INVENTORY_ITEM_STATUS_CODE     	VARCHAR2(10) 	:=  g_MISS_CHAR
,	ALLOWED_UNITS_LOOKUP_CODE      	NUMBER       	:=  g_MISS_NUM
,	ITEM_CATALOG_GROUP_ID          	NUMBER       	:=  g_MISS_NUM
,	CATALOG_STATUS_FLAG            	VARCHAR2(1)  	:=  g_MISS_CHAR
,	INVENTORY_ITEM_FLAG            	VARCHAR2(1)  	:=  g_MISS_CHAR
,	STOCK_ENABLED_FLAG             	VARCHAR2(1)  	:=  g_MISS_CHAR
,	MTL_TRANSACTIONS_ENABLED_FLAG  	VARCHAR2(1)  	:=  g_MISS_CHAR
,	CHECK_SHORTAGES_FLAG           	VARCHAR2(1)  	:=  g_MISS_CHAR
,	REVISION_QTY_CONTROL_CODE      	NUMBER       	:=  g_MISS_NUM
,	RESERVABLE_TYPE                	NUMBER       	:=  g_MISS_NUM
,	SHELF_LIFE_CODE                	NUMBER       	:=  g_MISS_NUM
,	SHELF_LIFE_DAYS                	NUMBER       	:=  g_MISS_NUM
,	CYCLE_COUNT_ENABLED_FLAG       	VARCHAR2(1)  	:=  g_MISS_CHAR
,	NEGATIVE_MEASUREMENT_ERROR     	NUMBER       	:=  g_MISS_NUM
,	POSITIVE_MEASUREMENT_ERROR     	NUMBER       	:=  g_MISS_NUM
,	LOT_CONTROL_CODE               	NUMBER       	:=  g_MISS_NUM
,	AUTO_LOT_ALPHA_PREFIX          	VARCHAR2(30) 	:=  g_MISS_CHAR
,	START_AUTO_LOT_NUMBER          	VARCHAR2(30) 	:=  g_MISS_CHAR
,	SERIAL_NUMBER_CONTROL_CODE     	NUMBER       	:=  g_MISS_NUM
,	AUTO_SERIAL_ALPHA_PREFIX       	VARCHAR2(30) 	:=  g_MISS_CHAR
,	START_AUTO_SERIAL_NUMBER       	VARCHAR2(30) 	:=  g_MISS_CHAR
,	LOCATION_CONTROL_CODE          	NUMBER       	:=  g_MISS_NUM
,	RESTRICT_SUBINVENTORIES_CODE   	NUMBER       	:=  g_MISS_NUM
,	RESTRICT_LOCATORS_CODE         	NUMBER       	:=  g_MISS_NUM
,	BOM_ENABLED_FLAG               	VARCHAR2(1)  	:=  g_MISS_CHAR
,	BOM_ITEM_TYPE                  	NUMBER       	:=  g_MISS_NUM
,	BASE_ITEM_ID                   	NUMBER       	:=  g_MISS_NUM
,	EFFECTIVITY_CONTROL            	NUMBER       	:=  g_MISS_NUM
,	ENG_ITEM_FLAG                  	VARCHAR2(1)  	:=  g_MISS_CHAR
,	ENGINEERING_ECN_CODE           	VARCHAR2(50) 	:=  g_MISS_CHAR
,	ENGINEERING_ITEM_ID            	NUMBER       	:=  g_MISS_NUM
,	ENGINEERING_DATE               	DATE         	:=  g_MISS_DATE
,	PRODUCT_FAMILY_ITEM_ID         	NUMBER       	:=  g_MISS_NUM
,	AUTO_CREATED_CONFIG_FLAG       	VARCHAR2(1)  	:=  g_MISS_CHAR
,	MODEL_CONFIG_CLAUSE_NAME       	VARCHAR2(10) 	:=  g_MISS_CHAR
,	COSTING_ENABLED_FLAG           	VARCHAR2(1)  	:=  g_MISS_CHAR
,	INVENTORY_ASSET_FLAG           	VARCHAR2(1)  	:=  g_MISS_CHAR
,	DEFAULT_INCLUDE_IN_ROLLUP_FLAG 	VARCHAR2(1)  	:=  g_MISS_CHAR
,	COST_OF_SALES_ACCOUNT          	NUMBER       	:=  g_MISS_NUM
,	STD_LOT_SIZE                   	NUMBER       	:=  g_MISS_NUM
,	PURCHASING_ITEM_FLAG           	VARCHAR2(1)  	:=  g_MISS_CHAR
,	PURCHASING_ENABLED_FLAG        	VARCHAR2(1)  	:=  g_MISS_CHAR
,	MUST_USE_APPROVED_VENDOR_FLAG  	VARCHAR2(1)  	:=  g_MISS_CHAR
,	ALLOW_ITEM_DESC_UPDATE_FLAG    	VARCHAR2(1)  	:=  g_MISS_CHAR
,	RFQ_REQUIRED_FLAG              	VARCHAR2(1)  	:=  g_MISS_CHAR
,	OUTSIDE_OPERATION_FLAG         	VARCHAR2(1)  	:=  g_MISS_CHAR
,	OUTSIDE_OPERATION_UOM_TYPE     	VARCHAR2(25) 	:=  g_MISS_CHAR
,	TAXABLE_FLAG                   	VARCHAR2(1)  	:=  g_MISS_CHAR
,	PURCHASING_TAX_CODE            	VARCHAR2(50) 	:=  g_MISS_CHAR
,	RECEIPT_REQUIRED_FLAG          	VARCHAR2(1)  	:=  g_MISS_CHAR
,	INSPECTION_REQUIRED_FLAG       	VARCHAR2(1)  	:=  g_MISS_CHAR
,	BUYER_ID                       	NUMBER       	:=  g_MISS_NUM
,	UNIT_OF_ISSUE                  	VARCHAR2(25) 	:=  g_MISS_CHAR
,	RECEIVE_CLOSE_TOLERANCE        	NUMBER       	:=  g_MISS_NUM
,	INVOICE_CLOSE_TOLERANCE        	NUMBER       	:=  g_MISS_NUM
,	UN_NUMBER_ID                   	NUMBER       	:=  g_MISS_NUM
,	HAZARD_CLASS_ID                	NUMBER       	:=  g_MISS_NUM
,	LIST_PRICE_PER_UNIT            	NUMBER       	:=  g_MISS_NUM
,	MARKET_PRICE                   	NUMBER       	:=  g_MISS_NUM
,	PRICE_TOLERANCE_PERCENT        	NUMBER       	:=  g_MISS_NUM
,	ROUNDING_FACTOR                	NUMBER       	:=  g_MISS_NUM
,	ENCUMBRANCE_ACCOUNT            	NUMBER       	:=  g_MISS_NUM
,	EXPENSE_ACCOUNT                	NUMBER       	:=  g_MISS_NUM
,	ASSET_CATEGORY_ID              	NUMBER       	:=  g_MISS_NUM
,	RECEIPT_DAYS_EXCEPTION_CODE    	VARCHAR2(25) 	:=  g_MISS_CHAR
,	DAYS_EARLY_RECEIPT_ALLOWED     	NUMBER       	:=  g_MISS_NUM
,	DAYS_LATE_RECEIPT_ALLOWED      	NUMBER       	:=  g_MISS_NUM
,	ALLOW_SUBSTITUTE_RECEIPTS_FLAG 	VARCHAR2(1)  	:=  g_MISS_CHAR
,	ALLOW_UNORDERED_RECEIPTS_FLAG  	VARCHAR2(1)  	:=  g_MISS_CHAR
,	ALLOW_EXPRESS_DELIVERY_FLAG    	VARCHAR2(1)  	:=  g_MISS_CHAR
,	QTY_RCV_EXCEPTION_CODE         	VARCHAR2(25) 	:=  g_MISS_CHAR
,	QTY_RCV_TOLERANCE              	NUMBER       	:=  g_MISS_NUM
,	RECEIVING_ROUTING_ID           	NUMBER       	:=  g_MISS_NUM
,	ENFORCE_SHIP_TO_LOCATION_CODE  	VARCHAR2(25) 	:=  g_MISS_CHAR
,	WEIGHT_UOM_CODE                	VARCHAR2(3)  	:=  g_MISS_CHAR
,	UNIT_WEIGHT                    	NUMBER       	:=  g_MISS_NUM
,	VOLUME_UOM_CODE                	VARCHAR2(3)  	:=  g_MISS_CHAR
,	UNIT_VOLUME                    	NUMBER       	:=  g_MISS_NUM
,	CONTAINER_ITEM_FLAG            	VARCHAR2(1)  	:=  g_MISS_CHAR
,	VEHICLE_ITEM_FLAG              	VARCHAR2(1)  	:=  g_MISS_CHAR
,	CONTAINER_TYPE_CODE            	VARCHAR2(30) 	:=  g_MISS_CHAR
,	INTERNAL_VOLUME                	NUMBER       	:=  g_MISS_NUM
,	MAXIMUM_LOAD_WEIGHT            	NUMBER       	:=  g_MISS_NUM
,	MINIMUM_FILL_PERCENT           	NUMBER       	:=  g_MISS_NUM
,	INVENTORY_PLANNING_CODE        	NUMBER       	:=  g_MISS_NUM
,	PLANNER_CODE                   	VARCHAR2(10) 	:=  g_MISS_CHAR
,	PLANNING_MAKE_BUY_CODE         	NUMBER       	:=  g_MISS_NUM
,	MIN_MINMAX_QUANTITY            	NUMBER       	:=  g_MISS_NUM
,	MAX_MINMAX_QUANTITY            	NUMBER       	:=  g_MISS_NUM
,	MINIMUM_ORDER_QUANTITY         	NUMBER       	:=  g_MISS_NUM
,	MAXIMUM_ORDER_QUANTITY         	NUMBER       	:=  g_MISS_NUM
,	ORDER_COST                     	NUMBER       	:=  g_MISS_NUM
,	CARRYING_COST                  	NUMBER       	:=  g_MISS_NUM
,	SOURCE_TYPE                    	NUMBER       	:=  g_MISS_NUM
,	SOURCE_ORGANIZATION_ID         	NUMBER       	:=  g_MISS_NUM
,	SOURCE_SUBINVENTORY            	VARCHAR2(10) 	:=  g_MISS_CHAR
,	MRP_SAFETY_STOCK_CODE          	NUMBER       	:=  g_MISS_NUM
,	SAFETY_STOCK_BUCKET_DAYS       	NUMBER       	:=  g_MISS_NUM
,	MRP_SAFETY_STOCK_PERCENT       	NUMBER       	:=  g_MISS_NUM
,	FIXED_ORDER_QUANTITY           	NUMBER       	:=  g_MISS_NUM
,	FIXED_DAYS_SUPPLY              	NUMBER       	:=  g_MISS_NUM
,	FIXED_LOT_MULTIPLIER           	NUMBER       	:=  g_MISS_NUM
,	MRP_PLANNING_CODE              	NUMBER       	:=  g_MISS_NUM
,	ATO_FORECAST_CONTROL           	NUMBER       	:=  g_MISS_NUM
,	PLANNING_EXCEPTION_SET         	VARCHAR2(10) 	:=  g_MISS_CHAR
,	END_ASSEMBLY_PEGGING_FLAG      	VARCHAR2(1)  	:=  g_MISS_CHAR
,	SHRINKAGE_RATE                 	NUMBER       	:=  g_MISS_NUM
,	ROUNDING_CONTROL_TYPE          	NUMBER       	:=  g_MISS_NUM
,	ACCEPTABLE_EARLY_DAYS          	NUMBER       	:=  g_MISS_NUM
,	REPETITIVE_PLANNING_FLAG       	VARCHAR2(1)  	:=  g_MISS_CHAR
,	OVERRUN_PERCENTAGE             	NUMBER       	:=  g_MISS_NUM
,	ACCEPTABLE_RATE_INCREASE       	NUMBER       	:=  g_MISS_NUM
,	ACCEPTABLE_RATE_DECREASE       	NUMBER       	:=  g_MISS_NUM
,	MRP_CALCULATE_ATP_FLAG         	VARCHAR2(1)  	:=  g_MISS_CHAR
,	AUTO_REDUCE_MPS                	NUMBER       	:=  g_MISS_NUM
,	PLANNING_TIME_FENCE_CODE       	NUMBER       	:=  g_MISS_NUM
,	PLANNING_TIME_FENCE_DAYS       	NUMBER       	:=  g_MISS_NUM
,	DEMAND_TIME_FENCE_CODE         	NUMBER       	:=  g_MISS_NUM
,	DEMAND_TIME_FENCE_DAYS         	NUMBER       	:=  g_MISS_NUM
,	RELEASE_TIME_FENCE_CODE        	NUMBER       	:=  g_MISS_NUM
,	RELEASE_TIME_FENCE_DAYS        	NUMBER       	:=  g_MISS_NUM
,	PREPROCESSING_LEAD_TIME        	NUMBER       	:=  g_MISS_NUM
,	FULL_LEAD_TIME                 	NUMBER       	:=  g_MISS_NUM
,	POSTPROCESSING_LEAD_TIME       	NUMBER       	:=  g_MISS_NUM
,	FIXED_LEAD_TIME                	NUMBER       	:=  g_MISS_NUM
,	VARIABLE_LEAD_TIME             	NUMBER       	:=  g_MISS_NUM
,	CUM_MANUFACTURING_LEAD_TIME    	NUMBER       	:=  g_MISS_NUM
,	CUMULATIVE_TOTAL_LEAD_TIME     	NUMBER       	:=  g_MISS_NUM
,	LEAD_TIME_LOT_SIZE             	NUMBER       	:=  g_MISS_NUM
,	BUILD_IN_WIP_FLAG              	VARCHAR2(1)  	:=  g_MISS_CHAR
,	WIP_SUPPLY_TYPE                	NUMBER       	:=  g_MISS_NUM
,	WIP_SUPPLY_SUBINVENTORY        	VARCHAR2(10) 	:=  g_MISS_CHAR
,	WIP_SUPPLY_LOCATOR_ID          	NUMBER       	:=  g_MISS_NUM
,	OVERCOMPLETION_TOLERANCE_TYPE  	NUMBER       	:=  g_MISS_NUM
,	OVERCOMPLETION_TOLERANCE_VALUE 	NUMBER       	:=  g_MISS_NUM
,	CUSTOMER_ORDER_FLAG            	VARCHAR2(1)  	:=  g_MISS_CHAR
,	CUSTOMER_ORDER_ENABLED_FLAG    	VARCHAR2(1)  	:=  g_MISS_CHAR
,	SHIPPABLE_ITEM_FLAG            	VARCHAR2(1)  	:=  g_MISS_CHAR
,	INTERNAL_ORDER_FLAG            	VARCHAR2(1)  	:=  g_MISS_CHAR
,	INTERNAL_ORDER_ENABLED_FLAG    	VARCHAR2(1)  	:=  g_MISS_CHAR
,	SO_TRANSACTIONS_FLAG           	VARCHAR2(1)  	:=  g_MISS_CHAR
,	PICK_COMPONENTS_FLAG           	VARCHAR2(1)  	:=  g_MISS_CHAR
,	ATP_FLAG                       	VARCHAR2(1)  	:=  g_MISS_CHAR
,	REPLENISH_TO_ORDER_FLAG        	VARCHAR2(1)  	:=  g_MISS_CHAR
,	ATP_RULE_ID                    	NUMBER       	:=  g_MISS_NUM
,	ATP_COMPONENTS_FLAG            	VARCHAR2(1)  	:=  g_MISS_CHAR
,	SHIP_MODEL_COMPLETE_FLAG       	VARCHAR2(1)  	:=  g_MISS_CHAR
,	PICKING_RULE_ID                	NUMBER       	:=  g_MISS_NUM
,	COLLATERAL_FLAG                	VARCHAR2(1)  	:=  g_MISS_CHAR
,	DEFAULT_SHIPPING_ORG           	NUMBER       	:=  g_MISS_NUM
,	RETURNABLE_FLAG                	VARCHAR2(1)  	:=  g_MISS_CHAR
,	RETURN_INSPECTION_REQUIREMENT  	NUMBER       	:=  g_MISS_NUM
,	OVER_SHIPMENT_TOLERANCE        	NUMBER  	:=  g_MISS_NUM
,	UNDER_SHIPMENT_TOLERANCE       	NUMBER  	:=  g_MISS_NUM
,	OVER_RETURN_TOLERANCE          	NUMBER  	:=  g_MISS_NUM
,	UNDER_RETURN_TOLERANCE         	NUMBER  	:=  g_MISS_NUM
,	INVOICEABLE_ITEM_FLAG          	VARCHAR2(1)  	:=  g_MISS_CHAR
,	INVOICE_ENABLED_FLAG           	VARCHAR2(1)  	:=  g_MISS_CHAR
,	ACCOUNTING_RULE_ID             	NUMBER       	:=  g_MISS_NUM
,	INVOICING_RULE_ID              	NUMBER       	:=  g_MISS_NUM
,	TAX_CODE                       	VARCHAR2(50) 	:=  g_MISS_CHAR
,	SALES_ACCOUNT                  	NUMBER       	:=  g_MISS_NUM
,	PAYMENT_TERMS_ID               	NUMBER       	:=  g_MISS_NUM
,	COVERAGE_SCHEDULE_ID           	NUMBER       	:=  g_MISS_NUM
,	SERVICE_DURATION               	NUMBER       	:=  g_MISS_NUM
,	SERVICE_DURATION_PERIOD_CODE   	VARCHAR2(10) 	:=  g_MISS_CHAR
,	SERVICEABLE_PRODUCT_FLAG       	VARCHAR2(1)  	:=  g_MISS_CHAR
,	SERVICE_STARTING_DELAY         	NUMBER       	:=  g_MISS_NUM
,	MATERIAL_BILLABLE_FLAG         	VARCHAR2(30) 	:=  g_MISS_CHAR
,	SERVICEABLE_COMPONENT_FLAG     	VARCHAR2(1)  	:=  g_MISS_CHAR
,	PREVENTIVE_MAINTENANCE_FLAG    	VARCHAR2(1)  	:=  g_MISS_CHAR
,	PRORATE_SERVICE_FLAG           	VARCHAR2(1)  	:=  g_MISS_CHAR
,	WH_UPDATE_DATE                 	DATE         	:=  g_MISS_DATE
,	 EQUIPMENT_TYPE                  NUMBER       	:=  g_MISS_NUM
,	RECOVERED_PART_DISP_CODE        VARCHAR2(30) 	:=  g_MISS_CHAR
,	DEFECT_TRACKING_ON_FLAG         VARCHAR2(1) 	:=  g_MISS_CHAR
,	EVENT_FLAG                      VARCHAR2(1) 	:=  g_MISS_CHAR
,	ELECTRONIC_FLAG                 VARCHAR2(1) 	:=  g_MISS_CHAR
,	DOWNLOADABLE_FLAG               VARCHAR2(1) 	:=  g_MISS_CHAR
,	VOL_DISCOUNT_EXEMPT_FLAG        VARCHAR2(1) 	:=  g_MISS_CHAR
,	COUPON_EXEMPT_FLAG              VARCHAR2(1) 	:=  g_MISS_CHAR
,	COMMS_NL_TRACKABLE_FLAG         VARCHAR2(1) 	:=  g_MISS_CHAR
,	ASSET_CREATION_CODE             VARCHAR2(30)	:=  g_MISS_CHAR
,	COMMS_ACTIVATION_REQD_FLAG      VARCHAR2(1) 	:=  g_MISS_CHAR
,	WEB_STATUS                      VARCHAR2(30)	:=  g_MISS_CHAR
,	ORDERABLE_ON_WEB_FLAG           VARCHAR2(1) 	:=  g_MISS_CHAR
,	BACK_ORDERABLE_FLAG             VARCHAR2(1) 	:=  g_MISS_CHAR
,	 INDIVISIBLE_FLAG                VARCHAR2(1) 	:=  g_MISS_CHAR
,	DIMENSION_UOM_CODE              VARCHAR2(3)  	:=  g_MISS_CHAR
,	UNIT_LENGTH                     NUMBER       	:=  g_MISS_NUM
,	UNIT_WIDTH                      NUMBER       	:=  g_MISS_NUM
,	UNIT_HEIGHT                     NUMBER       	:=  g_MISS_NUM
,	BULK_PICKED_FLAG                VARCHAR2(1)  	:=  g_MISS_CHAR
,	LOT_STATUS_ENABLED              VARCHAR2(1)  	:=  g_MISS_CHAR
,	DEFAULT_LOT_STATUS_ID           NUMBER       	:=  g_MISS_NUM
,	SERIAL_STATUS_ENABLED           VARCHAR2(1)  	:=  g_MISS_CHAR
,	DEFAULT_SERIAL_STATUS_ID        NUMBER       	:=  g_MISS_NUM
,	LOT_SPLIT_ENABLED               VARCHAR2(1)  	:=  g_MISS_CHAR
,	LOT_MERGE_ENABLED               VARCHAR2(1)  	:=  g_MISS_CHAR
,	INVENTORY_CARRY_PENALTY         NUMBER       	:=  g_MISS_NUM
,	OPERATION_SLACK_PENALTY         NUMBER       	:=  g_MISS_NUM
,	FINANCING_ALLOWED_FLAG          VARCHAR2(1)  	:=  g_MISS_CHAR
,  EAM_ITEM_TYPE                    NUMBER          :=  g_MISS_NUM
,  EAM_ACTIVITY_TYPE_CODE           VARCHAR2(30)    :=  g_MISS_CHAR
,  EAM_ACTIVITY_CAUSE_CODE          VARCHAR2(30)    :=  g_MISS_CHAR
,  EAM_ACT_NOTIFICATION_FLAG        VARCHAR2(1)     :=  g_MISS_CHAR
,  EAM_ACT_SHUTDOWN_STATUS          VARCHAR2(30)    :=  g_MISS_CHAR
,  DUAL_UOM_CONTROL                 NUMBER          :=  g_MISS_NUM
,  SECONDARY_UOM_CODE               VARCHAR2(3)     :=  g_MISS_CHAR
,  DUAL_UOM_DEVIATION_HIGH          NUMBER          :=  g_MISS_NUM
,  DUAL_UOM_DEVIATION_LOW           NUMBER          :=  g_MISS_NUM
--
,  SERVICE_ITEM_FLAG                VARCHAR2(1)     :=  g_MISS_CHAR
,  VENDOR_WARRANTY_FLAG             VARCHAR2(1)     :=  g_MISS_CHAR
,  USAGE_ITEM_FLAG                  VARCHAR2(1)     :=  g_MISS_CHAR
--
,  CONTRACT_ITEM_TYPE_CODE          VARCHAR2(30)    :=  g_MISS_CHAR
,  SUBSCRIPTION_DEPEND_FLAG         VARCHAR2(1)     :=  g_MISS_CHAR
--
,  SERV_REQ_ENABLED_CODE            VARCHAR2(30)    :=  g_MISS_CHAR
,  SERV_BILLING_ENABLED_FLAG        VARCHAR2(1)     :=  g_MISS_CHAR
,  SERV_IMPORTANCE_LEVEL            NUMBER          :=  g_MISS_NUM
,  PLANNED_INV_POINT_FLAG           VARCHAR2(1)     :=  g_MISS_CHAR
,  LOT_TRANSLATE_ENABLED            VARCHAR2(1)     :=  g_MISS_CHAR
,  DEFAULT_SO_SOURCE_TYPE           VARCHAR2(30)    :=  g_MISS_CHAR
,  CREATE_SUPPLY_FLAG               VARCHAR2(1)     :=  g_MISS_CHAR
,  SUBSTITUTION_WINDOW_CODE         NUMBER          :=  g_MISS_NUM
,  SUBSTITUTION_WINDOW_DAYS         NUMBER          :=  g_MISS_NUM
--Added as part of 11.5.9
,  LOT_SUBSTITUTION_ENABLED         VARCHAR2(1)     :=  g_MISS_CHAR
,  MINIMUM_LICENSE_QUANTITY         NUMBER          :=  g_MISS_NUM
,  EAM_ACTIVITY_SOURCE_CODE         VARCHAR2(30)    :=  g_MISS_CHAR
,  IB_ITEM_INSTANCE_CLASS           VARCHAR2(30)    :=  g_MISS_CHAR
,  CONFIG_MODEL_TYPE                VARCHAR2(30)    :=  g_MISS_CHAR
--Added as part of 11.5.10
,  TRACKING_QUANTITY_IND            VARCHAR2(30)    :=  g_MISS_CHAR
,  ONT_PRICING_QTY_SOURCE           VARCHAR2(30)    :=  g_MISS_CHAR
,  SECONDARY_DEFAULT_IND            VARCHAR2(30)    :=  g_MISS_CHAR
,  CONFIG_ORGS                      VARCHAR2(30)    :=  g_MISS_CHAR
,  CONFIG_MATCH                     VARCHAR2(30)    :=  g_MISS_CHAR
 --
 -- Descriptive flex
 --
,	ATTRIBUTE_CATEGORY             	VARCHAR2(30) 	:=  g_MISS_CHAR
,	ATTRIBUTE1                     	VARCHAR2(240)	:=  g_MISS_CHAR
,	ATTRIBUTE2                     	VARCHAR2(240)	:=  g_MISS_CHAR
,	ATTRIBUTE3                     	VARCHAR2(240)	:=  g_MISS_CHAR
,	ATTRIBUTE4                     	VARCHAR2(240)	:=  g_MISS_CHAR
,	ATTRIBUTE5                     	VARCHAR2(240)	:=  g_MISS_CHAR
,	ATTRIBUTE6                     	VARCHAR2(240)	:=  g_MISS_CHAR
,	ATTRIBUTE7                     	VARCHAR2(240)	:=  g_MISS_CHAR
,	ATTRIBUTE8                     	VARCHAR2(240)	:=  g_MISS_CHAR
,	ATTRIBUTE9                     	VARCHAR2(240)	:=  g_MISS_CHAR
,	ATTRIBUTE10                    	VARCHAR2(240)	:=  g_MISS_CHAR
,	ATTRIBUTE11                    	VARCHAR2(240)	:=  g_MISS_CHAR
,	ATTRIBUTE12                    	VARCHAR2(240)	:=  g_MISS_CHAR
,	ATTRIBUTE13                    	VARCHAR2(240)	:=  g_MISS_CHAR
,	ATTRIBUTE14                    	VARCHAR2(240)	:=  g_MISS_CHAR
,	ATTRIBUTE15                    	VARCHAR2(240)	:=  g_MISS_CHAR
/* Start Bug 3713912 */
,	ATTRIBUTE16                    	VARCHAR2(240)	:=  g_MISS_CHAR
,	ATTRIBUTE17                    	VARCHAR2(240)	:=  g_MISS_CHAR
,	ATTRIBUTE18                    	VARCHAR2(240)	:=  g_MISS_CHAR
,	ATTRIBUTE19                    	VARCHAR2(240)	:=  g_MISS_CHAR
,	ATTRIBUTE20                    	VARCHAR2(240)	:=  g_MISS_CHAR
,	ATTRIBUTE21                    	VARCHAR2(240)	:=  g_MISS_CHAR
,	ATTRIBUTE22                    	VARCHAR2(240)	:=  g_MISS_CHAR
,	ATTRIBUTE23                    	VARCHAR2(240)	:=  g_MISS_CHAR
,	ATTRIBUTE24                    	VARCHAR2(240)	:=  g_MISS_CHAR
,	ATTRIBUTE25                    	VARCHAR2(240)	:=  g_MISS_CHAR
,	ATTRIBUTE26                    	VARCHAR2(240)	:=  g_MISS_CHAR
,	ATTRIBUTE27                    	VARCHAR2(240)	:=  g_MISS_CHAR
,	ATTRIBUTE28                    	VARCHAR2(240)	:=  g_MISS_CHAR
,	ATTRIBUTE29                    	VARCHAR2(240)	:=  g_MISS_CHAR
,	ATTRIBUTE30                    	VARCHAR2(240)	:=  g_MISS_CHAR
/* End Bug 3713912 */
,	GLOBAL_ATTRIBUTE_CATEGORY      	VARCHAR2(150)	:=  g_MISS_CHAR
,	GLOBAL_ATTRIBUTE1              	VARCHAR2(150)	:=  g_MISS_CHAR
,	GLOBAL_ATTRIBUTE2              	VARCHAR2(150)	:=  g_MISS_CHAR
,	GLOBAL_ATTRIBUTE3              	VARCHAR2(150)	:=  g_MISS_CHAR
,	GLOBAL_ATTRIBUTE4              	VARCHAR2(150)	:=  g_MISS_CHAR
,	GLOBAL_ATTRIBUTE5              	VARCHAR2(150)	:=  g_MISS_CHAR
,	GLOBAL_ATTRIBUTE6              	VARCHAR2(150)	:=  g_MISS_CHAR
,	GLOBAL_ATTRIBUTE7              	VARCHAR2(150)	:=  g_MISS_CHAR
,	GLOBAL_ATTRIBUTE8              	VARCHAR2(150)	:=  g_MISS_CHAR
,	GLOBAL_ATTRIBUTE9              	VARCHAR2(150)	:=  g_MISS_CHAR
,	GLOBAL_ATTRIBUTE10             	VARCHAR2(150)	:=  g_MISS_CHAR
,	GLOBAL_ATTRIBUTE11              	VARCHAR2(150)	:=  g_MISS_CHAR
,	GLOBAL_ATTRIBUTE12              	VARCHAR2(150)	:=  g_MISS_CHAR
,	GLOBAL_ATTRIBUTE13              	VARCHAR2(150)	:=  g_MISS_CHAR
,	GLOBAL_ATTRIBUTE14              	VARCHAR2(150)	:=  g_MISS_CHAR
,	GLOBAL_ATTRIBUTE15              	VARCHAR2(150)	:=  g_MISS_CHAR
,	GLOBAL_ATTRIBUTE16              	VARCHAR2(150)	:=  g_MISS_CHAR
,	GLOBAL_ATTRIBUTE17              	VARCHAR2(150)	:=  g_MISS_CHAR
,	GLOBAL_ATTRIBUTE18              	VARCHAR2(150)	:=  g_MISS_CHAR
,	GLOBAL_ATTRIBUTE19              	VARCHAR2(150)	:=  g_MISS_CHAR
,	GLOBAL_ATTRIBUTE20             	VARCHAR2(150)	:=  g_MISS_CHAR
 --
 -- Lifecycle
 --
,  Lifecycle_Id				NUMBER		:=  g_MISS_NUM
,  Current_Phase_Id			NUMBER		:=  g_MISS_NUM
 --
 -- Who
 --
,  CREATION_DATE                  	DATE         	:=  g_MISS_DATE
,  CREATED_BY                     	NUMBER       	:=  g_MISS_NUM
,  LAST_UPDATE_DATE               	DATE         	:=  g_MISS_DATE
,  LAST_UPDATED_BY                	NUMBER       	:=  g_MISS_NUM
,  LAST_UPDATE_LOGIN              	NUMBER       	:=  g_MISS_NUM
,  REQUEST_ID                     	NUMBER       	:=  g_MISS_NUM
,  PROGRAM_APPLICATION_ID         	NUMBER       	:=  g_MISS_NUM
,  PROGRAM_ID                     	NUMBER       	:=  g_MISS_NUM
,  PROGRAM_UPDATE_DATE            	DATE         	:=  g_MISS_DATE
,  VMI_MINIMUM_UNITS         NUMBER          :=  g_MISS_NUM
,  VMI_MINIMUM_DAYS          NUMBER          :=  g_MISS_NUM
,  VMI_MAXIMUM_UNITS         NUMBER          :=  g_MISS_NUM
,  VMI_MAXIMUM_DAYS          NUMBER          :=  g_MISS_NUM
,  VMI_FIXED_ORDER_QUANTITY  NUMBER          :=  g_MISS_NUM
,  SO_AUTHORIZATION_FLAG     NUMBER          :=  g_MISS_NUM
,  CONSIGNED_FLAG            NUMBER          :=  g_MISS_NUM
,  ASN_AUTOEXPIRE_FLAG       NUMBER          :=  g_MISS_NUM
,  VMI_FORECAST_TYPE         NUMBER          :=  g_MISS_NUM
,  FORECAST_HORIZON          NUMBER          :=  g_MISS_NUM
,  EXCLUDE_FROM_BUDGET_FLAG  NUMBER          :=  g_MISS_NUM
,  DAYS_TGT_INV_SUPPLY       NUMBER          :=  g_MISS_NUM
,  DAYS_TGT_INV_WINDOW       NUMBER          :=  g_MISS_NUM
,  DAYS_MAX_INV_SUPPLY       NUMBER          :=  g_MISS_NUM
,  DAYS_MAX_INV_WINDOW       NUMBER          :=  g_MISS_NUM
,  DRP_PLANNED_FLAG          NUMBER          :=  g_MISS_NUM
,  CRITICAL_COMPONENT_FLAG   NUMBER          :=  g_MISS_NUM
,  CONTINOUS_TRANSFER        NUMBER          :=  g_MISS_NUM
,  CONVERGENCE               NUMBER          :=  g_MISS_NUM
,  DIVERGENCE                NUMBER          :=  g_MISS_NUM
/* Start Bug 3713912 */
,  LOT_DIVISIBLE_FLAG		        VARCHAR2(1)     :=  g_MISS_CHAR
,  GRADE_CONTROL_FLAG		        VARCHAR2(1)     :=  g_MISS_CHAR
,  DEFAULT_GRADE		        VARCHAR2(150)   :=  g_MISS_CHAR
,  CHILD_LOT_FLAG		        VARCHAR2(1)     :=  g_MISS_CHAR
,  PARENT_CHILD_GENERATION_FLAG	        VARCHAR2(1)     :=  g_MISS_CHAR
,  CHILD_LOT_PREFIX		        VARCHAR2(30)    :=  g_MISS_CHAR
,  CHILD_LOT_STARTING_NUMBER            NUMBER          :=  g_MISS_NUM
,  CHILD_LOT_VALIDATION_FLAG	        VARCHAR2(1)     :=  g_MISS_CHAR
,  COPY_LOT_ATTRIBUTE_FLAG	        VARCHAR2(1)     :=  g_MISS_CHAR
,  RECIPE_ENABLED_FLAG		        VARCHAR2(1)     :=  g_MISS_CHAR
,  PROCESS_QUALITY_ENABLED_FLAG	        VARCHAR2(1)     :=  g_MISS_CHAR
,  PROCESS_EXECUTION_ENABLED_FLAG       VARCHAR2(1)     :=  g_MISS_CHAR
,  PROCESS_COSTING_ENABLED_FLAG	        VARCHAR2(1)     :=  g_MISS_CHAR
,  PROCESS_SUPPLY_SUBINVENTORY	        VARCHAR2(10)    :=  g_MISS_CHAR
,  PROCESS_SUPPLY_LOCATOR_ID	        NUMBER		:=  g_MISS_NUM
,  PROCESS_YIELD_SUBINVENTORY	        VARCHAR2(10)    :=  g_MISS_CHAR
,  PROCESS_YIELD_LOCATOR_ID	        NUMBER		:=  g_MISS_NUM
,  HAZARDOUS_MATERIAL_FLAG	        VARCHAR2(1)     :=  g_MISS_CHAR
,  CAS_NUMBER			        VARCHAR2(30)    :=  g_MISS_CHAR
,  RETEST_INTERVAL		        NUMBER          :=  g_MISS_NUM
,  EXPIRATION_ACTION_INTERVAL	        NUMBER          :=  g_MISS_NUM
/* Bug 9217515. Changing the length to 32 characters, to sync it up with the column length in mtl_system_items_b table. */
,  EXPIRATION_ACTION_CODE	        VARCHAR2(32)     :=  g_MISS_CHAR
,  MATURITY_DAYS		        NUMBER          :=  g_MISS_NUM
,  HOLD_DAYS	                        NUMBER          :=  g_MISS_NUM
,  PROCESS_ITEM_RECORD                  NUMBER          :=  g_MISS_NUM
/* End Bug 3713912 */
/* R12 Enhancement */
,  CHARGE_PERIODICITY_CODE              VARCHAR2(3)     :=  g_MISS_CHAR
,  REPAIR_LEADTIME                      NUMBER          :=  g_MISS_NUM
,  REPAIR_YIELD                         NUMBER          :=  g_MISS_NUM
,  PREPOSITION_POINT			VARCHAR2(1)     :=  g_MISS_CHAR
,  REPAIR_PROGRAM                       NUMBER          :=  g_MISS_NUM
,  SUBCONTRACTING_COMPONENT             NUMBER          :=  g_MISS_NUM
,  OUTSOURCED_ASSEMBLY                  NUMBER          :=  g_MISS_NUM
 --R12 C Attributes
,  GDSN_OUTBOUND_ENABLED_FLAG           VARCHAR2(1)     :=  g_MISS_CHAR
,  TRADE_ITEM_DESCRIPTOR                VARCHAR2(35)    :=  g_MISS_CHAR
,  STYLE_ITEM_FLAG                      VARCHAR2(1)     :=  g_MISS_CHAR
,  STYLE_ITEM_ID                        NUMBER          :=  g_MISS_NUM
);

--Added revision record to create/update API
TYPE Item_Revision_Rec_Type IS RECORD(
      Transaction_Type                  VARCHAR2(30)    :=  G_MISS_CHAR
     ,Return_Status                     VARCHAR2(1)     :=  G_MISS_CHAR
     ,Language_Code                     VARCHAR2(4)     :=  G_MISS_CHAR
   -- Revision identifier
     ,Inventory_Item_Id                 NUMBER          :=  G_MISS_NUM
     ,Item_Number                       VARCHAR2(2000)  :=  G_MISS_CHAR
     ,Organization_Id                   NUMBER          :=  G_MISS_NUM
     ,Organization_Code                 VARCHAR2(3)     :=  G_MISS_CHAR
     ,Revision_Id                       NUMBER          :=  G_MISS_NUM
   -- Attributes
     ,Revision_Code                     VARCHAR2(3)     :=  G_MISS_CHAR
     ,Revision_Label                    VARCHAR2(80)    :=  G_MISS_CHAR
     ,Description                       VARCHAR2(240)   :=  G_MISS_CHAR
     ,Change_Notice                     VARCHAR2(10)    :=  G_MISS_CHAR
     ,Ecn_Initiation_Date               DATE            :=  G_MISS_DATE
     ,Implementation_Date               DATE            :=  G_MISS_DATE
     ,Effectivity_Date                  DATE            :=  G_MISS_DATE
     ,Revised_Item_Sequence_Id          NUMBER          :=  G_MISS_NUM
   -- Lifecycle
     ,Lifecycle_Id                      NUMBER          :=  G_MISS_NUM
     ,Current_Phase_Id                  NUMBER          :=  G_MISS_NUM
   -- Added for 5208102
     ,template_id   MTL_ITEM_TEMPLATES_B.TEMPLATE_ID%TYPE    :=  G_MISS_NUM
     ,template_name MTL_ITEM_TEMPLATES_TL.TEMPLATE_NAME%TYPE :=  G_MISS_CHAR
   -- Descriptive flex
     ,Attribute_Category                VARCHAR2(30)    :=  G_MISS_CHAR
     ,Attribute1                        VARCHAR2(150)   :=  G_MISS_CHAR
     ,Attribute2                        VARCHAR2(150)   :=  G_MISS_CHAR
     ,Attribute3                        VARCHAR2(150)   :=  G_MISS_CHAR
     ,Attribute4                        VARCHAR2(150)   :=  G_MISS_CHAR
     ,Attribute5                        VARCHAR2(150)   :=  G_MISS_CHAR
     ,Attribute6                        VARCHAR2(150)   :=  G_MISS_CHAR
     ,Attribute7                        VARCHAR2(150)   :=  G_MISS_CHAR
     ,Attribute8                        VARCHAR2(150)   :=  G_MISS_CHAR
     ,Attribute9                        VARCHAR2(150)   :=  G_MISS_CHAR
     ,Attribute10                       VARCHAR2(150)   :=  G_MISS_CHAR
     ,Attribute11                       VARCHAR2(150)   :=  G_MISS_CHAR
     ,Attribute12                       VARCHAR2(150)   :=  G_MISS_CHAR
     ,Attribute13                       VARCHAR2(150)   :=  G_MISS_CHAR
     ,Attribute14                       VARCHAR2(150)   :=  G_MISS_CHAR
     ,Attribute15                       VARCHAR2(150)   :=  G_MISS_CHAR
   -- Who
     ,Object_Version_Number             NUMBER          :=  G_MISS_NUM
     ,Creation_Date                     DATE            :=  G_MISS_DATE
     ,Created_By                        NUMBER          :=  G_MISS_NUM
     ,Last_Update_Date                  DATE            :=  G_MISS_DATE
     ,Last_Updated_By                   NUMBER          :=  G_MISS_NUM
     ,Last_Update_Login                 NUMBER          :=  G_MISS_NUM);


TYPE Error_rec_type IS RECORD
(
   TRANSACTION_ID         NUMBER
,  UNIQUE_ID              NUMBER
,  MESSAGE_NAME           VARCHAR2(30)
,  MESSAGE_TEXT           VARCHAR2(2000)
,  TABLE_NAME             VARCHAR2(30)
,  COLUMN_NAME            VARCHAR2(32)
,  ORGANIZATION_ID        NUMBER
);

TYPE Error_tbl_type IS TABLE OF Error_rec_type
                       INDEX BY BINARY_INTEGER;

-- ----------------------------------------------------------------
-- ------------ Variables representing missing values -------------
-- ----------------------------------------------------------------

g_Miss_Item_rec      INV_ITEM_GRP.Item_rec_type;
g_Miss_Revision_rec  INV_ITEM_GRP.Item_Revision_Rec_Type;

-- --------------------------------------------------------
-- ------------------- Procedure specs --------------------
-- --------------------------------------------------------

-- -------------------- Create_Item -------------------
PROCEDURE Create_Item
(
   p_commit              IN      VARCHAR2                            DEFAULT  fnd_api.g_FALSE
,  p_validation_level    IN      NUMBER                              DEFAULT  fnd_api.g_VALID_LEVEL_FULL
,  p_Item_rec            IN      INV_ITEM_GRP.Item_rec_type
,  x_Item_rec            OUT     NOCOPY INV_ITEM_GRP.Item_rec_type
,  x_return_status       OUT     NOCOPY VARCHAR2
,  x_Error_tbl           IN OUT  NOCOPY INV_ITEM_GRP.Error_tbl_type
,  p_Template_Id         IN      NUMBER                              DEFAULT  NULL
,  p_Template_Name       IN      VARCHAR2                            DEFAULT  NULL
);

PROCEDURE Create_Item
(
   p_commit              IN      VARCHAR2                            DEFAULT  fnd_api.g_FALSE
,  p_validation_level    IN      NUMBER                              DEFAULT  fnd_api.g_VALID_LEVEL_FULL
,  p_Item_rec            IN      INV_ITEM_GRP.Item_rec_type
,  x_Item_rec            OUT     NOCOPY INV_ITEM_GRP.Item_rec_type
,  x_return_status       OUT     NOCOPY VARCHAR2
,  x_Error_tbl           IN OUT  NOCOPY INV_ITEM_GRP.Error_tbl_type
,  p_Template_Id         IN      NUMBER                              DEFAULT  NULL
,  p_Template_Name       IN      VARCHAR2                            DEFAULT  NULL
,  p_Revision_rec        IN      INV_ITEM_GRP.Item_Revision_Rec_Type
-- Bug 9092888 - changes
,  p_attributes_row_table          IN   EGO_USER_ATTR_ROW_TABLE DEFAULT NULL
,  p_attributes_data_table         IN   EGO_USER_ATTR_DATA_TABLE DEFAULT NULL
-- Bug 9092888 - changes

);

-- -------------------- Update_Item -------------------

PROCEDURE Update_Item
(
   p_commit              IN      VARCHAR2                            DEFAULT  fnd_api.g_FALSE
,  p_lock_rows           IN      VARCHAR2                            DEFAULT  fnd_api.g_TRUE
,  p_validation_level    IN      NUMBER                              DEFAULT  fnd_api.g_VALID_LEVEL_FULL
,  p_Item_rec            IN      INV_ITEM_GRP.Item_rec_type
,  x_Item_rec            OUT     NOCOPY INV_ITEM_GRP.Item_rec_type
,  x_return_status       OUT     NOCOPY VARCHAR2
,  x_Error_tbl           IN OUT  NOCOPY INV_ITEM_GRP.Error_tbl_type
,  p_Template_Id         IN      NUMBER                              DEFAULT  NULL
,  p_Template_Name       IN      VARCHAR2                            DEFAULT  NULL
);

PROCEDURE Update_Item
(
   p_commit              IN      VARCHAR2                            DEFAULT  fnd_api.g_FALSE
,  p_lock_rows           IN      VARCHAR2                            DEFAULT  fnd_api.g_TRUE
,  p_validation_level    IN      NUMBER                              DEFAULT  fnd_api.g_VALID_LEVEL_FULL
,  p_Item_rec            IN      INV_ITEM_GRP.Item_rec_type
,  x_Item_rec            OUT     NOCOPY INV_ITEM_GRP.Item_rec_type
,  x_return_status       OUT     NOCOPY VARCHAR2
,  x_Error_tbl           IN OUT  NOCOPY INV_ITEM_GRP.Error_tbl_type
,  p_Template_Id         IN      NUMBER                              DEFAULT  NULL
,  p_Template_Name       IN      VARCHAR2                            DEFAULT  NULL
,  p_Revision_rec        IN      INV_ITEM_GRP.Item_Revision_Rec_Type
);

-- -------------------- Lock_Item --------------------

PROCEDURE Lock_Item
(
    p_Item_ID             IN    NUMBER
,   p_Org_ID              IN    NUMBER
,   x_return_status       OUT   NOCOPY VARCHAR2
,   x_Error_tbl         IN OUT  NOCOPY INV_ITEM_GRP.Error_tbl_type
);

-- -------------------- Get_Item ---------------------

PROCEDURE Get_Item
(
    p_Item_Number        IN    VARCHAR2       :=  fnd_api.g_MISS_CHAR
,   p_Item_ID            IN    NUMBER         :=  fnd_api.g_MISS_NUM
,   p_Org_ID             IN    NUMBER
,   p_Language_Code      IN    VARCHAR2	      :=  fnd_api.g_MISS_CHAR
,   x_Item_rec           OUT   NOCOPY INV_ITEM_GRP.Item_rec_type
,   x_return_status      OUT   NOCOPY VARCHAR2
,   x_return_err         OUT   NOCOPY VARCHAR2
);

PROCEDURE Interface_Handler
(  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE
  ,p_transaction_type IN VARCHAR2
  ,p_Item_rec IN INV_ITEM_GRP.Item_Rec_Type
  ,P_revision_rec IN INV_ITEM_GRP.Item_Revision_Rec_Type
  ,p_Template_Id IN NUMBER
  ,p_Template_Name IN VARCHAR2
  ,x_batch_id OUT NOCOPY NUMBER
  ,x_return_status OUT NOCOPY VARCHAR2
  ,x_return_err  OUT NOCOPY VARCHAR2
);

/*
-- ------------------- Get_Item_Number ------------------

PROCEDURE Get_Item_Number
(
    p_Item_ID            IN    NUMBER
,   p_Org_ID             IN    NUMBER
,   x_Item_Number        OUT   NOCOPY VARCHAR2
,   x_return_status      OUT   NOCOPY VARCHAR2
,   x_return_err         OUT   NOCOPY VARCHAR2
);

-- ------------------- Check_Item_Number ------------------

PROCEDURE Check_Item_Number
(
    p_Item_Number        IN    VARCHAR2
,   p_Org_ID             IN    NUMBER
,   x_return_status      OUT   NOCOPY VARCHAR2
,   x_return_err         OUT   NOCOPY VARCHAR2
);

-- -------------------- Get_Item_ID --------------------

PROCEDURE Get_Item_ID
(
    p_Item_Number        IN    VARCHAR2
,   x_Item_ID            OUT   NOCOPY NUMBER
,   x_Org_ID             OUT   NOCOPY NUMBER
,   x_return_status      OUT   NOCOPY VARCHAR2
,   x_return_err         OUT   NOCOPY VARCHAR2
);

*/

END INV_ITEM_GRP;

/
