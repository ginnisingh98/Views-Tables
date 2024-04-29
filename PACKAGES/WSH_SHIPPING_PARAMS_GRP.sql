--------------------------------------------------------
--  DDL for Package WSH_SHIPPING_PARAMS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_SHIPPING_PARAMS_GRP" AUTHID CURRENT_USER as
/* $Header: WSHSPGPS.pls 120.0.12010000.5 2009/06/12 10:56:15 mvudugul ship $ */
--
-- Package type declarations
--

TYPE Shipping_Params_Rec IS RECORD (

SHIP_CONFIRM_RULE_ID          WSH_SHIPPING_PARAMETERS.SHIP_CONFIRM_RULE_ID%TYPE,
AUTOPACK_LEVEL                WSH_SHIPPING_PARAMETERS.AUTOPACK_LEVEL%TYPE,
TASK_PLANNING_FLAG            WSH_SHIPPING_PARAMETERS.TASK_PLANNING_FLAG%TYPE,
EXPORT_SCREENING_FLAG         WSH_SHIPPING_PARAMETERS.EXPORT_SCREENING_FLAG%TYPE,
APPENDING_LIMIT               WSH_SHIPPING_PARAMETERS.APPENDING_LIMIT%TYPE,
IGNORE_INBOUND_TRIP           WSH_SHIPPING_PARAMETERS.IGNORE_INBOUND_TRIP%TYPE,
PACK_SLIP_REQUIRED_FLAG       WSH_SHIPPING_PARAMETERS.PACK_SLIP_REQUIRED_FLAG%TYPE,
PICK_SEQUENCE_RULE_ID         WSH_SHIPPING_PARAMETERS.PICK_SEQUENCE_RULE_ID%TYPE,
PICK_GROUPING_RULE_ID         WSH_SHIPPING_PARAMETERS.PICK_GROUPING_RULE_ID%TYPE,
PRINT_PICK_SLIP_MODE          WSH_SHIPPING_PARAMETERS.PRINT_PICK_SLIP_MODE%TYPE,
PICK_RELEASE_REPORT_SET_ID    WSH_SHIPPING_PARAMETERS.PICK_RELEASE_REPORT_SET_ID%TYPE,
AUTOCREATE_DEL_ORDERS_FLAG    WSH_SHIPPING_PARAMETERS.AUTOCREATE_DEL_ORDERS_FLAG%TYPE,
DEFAULT_STAGE_SUBINVENTORY    WSH_SHIPPING_PARAMETERS.DEFAULT_STAGE_SUBINVENTORY%TYPE,
DEFAULT_STAGE_LOCATOR_ID      WSH_SHIPPING_PARAMETERS.DEFAULT_STAGE_LOCATOR_ID%TYPE,
AUTODETAIL_PR_FLAG            WSH_SHIPPING_PARAMETERS.AUTODETAIL_PR_FLAG%TYPE,
ENFORCE_PACKING_FLAG          WSH_SHIPPING_PARAMETERS.ENFORCE_PACKING_FLAG%TYPE,
GROUP_BY_CUSTOMER_FLAG        WSH_SHIPPING_PARAMETERS.GROUP_BY_CUSTOMER_FLAG%TYPE,
GROUP_BY_FOB_FLAG             WSH_SHIPPING_PARAMETERS.GROUP_BY_FOB_FLAG%TYPE,
GROUP_BY_FREIGHT_TERMS_FLAG   WSH_SHIPPING_PARAMETERS.GROUP_BY_FREIGHT_TERMS_FLAG%TYPE,
GROUP_BY_INTMED_SHIP_TO_FLAG  WSH_SHIPPING_PARAMETERS.GROUP_BY_INTMED_SHIP_TO_FLAG%TYPE,
GROUP_BY_SHIP_METHOD_FLAG     WSH_SHIPPING_PARAMETERS.GROUP_BY_SHIP_METHOD_FLAG%TYPE,
GROUP_BY_CARRIER_FLAG         WSH_SHIPPING_PARAMETERS.GROUP_BY_CARRIER_FLAG%TYPE,
ATTRIBUTE_CATEGORY            WSH_SHIPPING_PARAMETERS.ATTRIBUTE_CATEGORY%TYPE,
ATTRIBUTE1                    WSH_SHIPPING_PARAMETERS.ATTRIBUTE1%TYPE,
ATTRIBUTE2                    WSH_SHIPPING_PARAMETERS.ATTRIBUTE2%TYPE,
ATTRIBUTE3                    WSH_SHIPPING_PARAMETERS.ATTRIBUTE3%TYPE,
ATTRIBUTE4                    WSH_SHIPPING_PARAMETERS.ATTRIBUTE4%TYPE,
ATTRIBUTE5                    WSH_SHIPPING_PARAMETERS.ATTRIBUTE5%TYPE,
ATTRIBUTE6                    WSH_SHIPPING_PARAMETERS.ATTRIBUTE6%TYPE,
ATTRIBUTE7                    WSH_SHIPPING_PARAMETERS.ATTRIBUTE7%TYPE,
ATTRIBUTE8                    WSH_SHIPPING_PARAMETERS.ATTRIBUTE8%TYPE,
ATTRIBUTE9                    WSH_SHIPPING_PARAMETERS.ATTRIBUTE9%TYPE,
ATTRIBUTE10                   WSH_SHIPPING_PARAMETERS.ATTRIBUTE10%TYPE,
ATTRIBUTE11                   WSH_SHIPPING_PARAMETERS.ATTRIBUTE11%TYPE,
ATTRIBUTE12                   WSH_SHIPPING_PARAMETERS.ATTRIBUTE12%TYPE,
ATTRIBUTE13                   WSH_SHIPPING_PARAMETERS.ATTRIBUTE13%TYPE,
ATTRIBUTE14                   WSH_SHIPPING_PARAMETERS.ATTRIBUTE14%TYPE,
ATTRIBUTE15                   WSH_SHIPPING_PARAMETERS.ATTRIBUTE15%TYPE,
CREATION_DATE                 WSH_SHIPPING_PARAMETERS.CREATION_DATE%TYPE,
CREATED_BY                    WSH_SHIPPING_PARAMETERS.CREATED_BY%TYPE,
LAST_UPDATE_DATE              WSH_SHIPPING_PARAMETERS.LAST_UPDATE_DATE%TYPE,
LAST_UPDATED_BY               WSH_SHIPPING_PARAMETERS.LAST_UPDATED_BY%TYPE,
LAST_UPDATE_LOGIN             WSH_SHIPPING_PARAMETERS.LAST_UPDATE_LOGIN%TYPE,
PROGRAM_APPLICATION_ID        WSH_SHIPPING_PARAMETERS.PROGRAM_APPLICATION_ID%TYPE,
PROGRAM_ID                    WSH_SHIPPING_PARAMETERS.PROGRAM_ID%TYPE,
PROGRAM_UPDATE_DATE           WSH_SHIPPING_PARAMETERS.PROGRAM_UPDATE_DATE%TYPE,
REQUEST_ID                    WSH_SHIPPING_PARAMETERS.REQUEST_ID%TYPE,
PICK_SLIP_LINES               WSH_SHIPPING_PARAMETERS.PICK_SLIP_LINES%TYPE,
AUTOCREATE_DELIVERIES_FLAG    WSH_SHIPPING_PARAMETERS.AUTOCREATE_DELIVERIES_FLAG%TYPE,
FREIGHT_CLASS_CAT_SET_ID      WSH_SHIPPING_PARAMETERS.FREIGHT_CLASS_CAT_SET_ID%TYPE,
COMMODITY_CODE_CAT_SET_ID     WSH_SHIPPING_PARAMETERS.COMMODITY_CODE_CAT_SET_ID%TYPE,
ENFORCE_SHIP_SET_AND_SMC      WSH_SHIPPING_PARAMETERS.ENFORCE_SHIP_SET_AND_SMC%TYPE,
AUTO_SEND_DOC_FLAG            WSH_SHIPPING_PARAMETERS.AUTO_SEND_DOC_FLAG%TYPE,
ITM_ADDITIONAL_COUNTRY_CODE   WSH_SHIPPING_PARAMETERS.ITM_ADDITIONAL_COUNTRY_CODE%TYPE,
AUTO_SELECT_CARRIER           WSH_SHIPPING_PARAMETERS.AUTO_SELECT_CARRIER%TYPE,
GOODS_DISPATCHED_ACCOUNT      WSH_SHIPPING_PARAMETERS.GOODS_DISPATCHED_ACCOUNT%TYPE,
LOCATION_ID                   WSH_SHIPPING_PARAMETERS.LOCATION_ID%TYPE,
ORGANIZATION_ID               WSH_SHIPPING_PARAMETERS.ORGANIZATION_ID%TYPE,
WEIGHT_UOM_CLASS              WSH_SHIPPING_PARAMETERS.WEIGHT_UOM_CLASS%TYPE,
VOLUME_UOM_CLASS              WSH_SHIPPING_PARAMETERS.VOLUME_UOM_CLASS%TYPE,
WEIGHT_VOLUME_FLAG            WSH_SHIPPING_PARAMETERS.WEIGHT_VOLUME_FLAG%TYPE,
INV_CONTROLS_CONTAINER_FLAG   WSH_SHIPPING_PARAMETERS.INV_CONTROLS_CONTAINER_FLAG%TYPE,
PERCENT_FILL_BASIS_FLAG       WSH_SHIPPING_PARAMETERS.PERCENT_FILL_BASIS_FLAG%TYPE,
TRIP_REPORT_SET_ID            WSH_SHIPPING_PARAMETERS.TRIP_REPORT_SET_ID%TYPE,
DELIVERY_REPORT_SET_ID        WSH_SHIPPING_PARAMETERS.DELIVERY_REPORT_SET_ID%TYPE,
AUTOCREATE_DEL_ORDERS_PR_FLAG WSH_SHIPPING_PARAMETERS.AUTOCREATE_DEL_ORDERS_PR_FLAG%TYPE,
FPA_POSITIVE_TOL_AMT          WSH_SHIPPING_PARAMETERS.FPA_POSITIVE_TOL_AMT%TYPE,
FPA_NEGATIVE_TOL_AMT          WSH_SHIPPING_PARAMETERS.FPA_NEGATIVE_TOL_AMT%TYPE,
FPA_POSITIVE_TOL_PERCENTAGE   WSH_SHIPPING_PARAMETERS.FPA_POSITIVE_TOL_PERCENTAGE%TYPE,
FPA_NEGATIVE_TOL_PERCENTAGE   WSH_SHIPPING_PARAMETERS.FPA_NEGATIVE_TOL_PERCENTAGE%TYPE,
FPA_DEFAULT_FREIGHT_ACCOUNT   WSH_SHIPPING_PARAMETERS.FPA_DEFAULT_FREIGHT_ACCOUNT%TYPE,
AUTO_APPLY_ROUTING_RULES      WSH_SHIPPING_PARAMETERS.AUTO_APPLY_ROUTING_RULES%TYPE,
AUTO_CALC_FGT_RATE_CR_DEL     WSH_SHIPPING_PARAMETERS.AUTO_CALC_FGT_RATE_CR_DEL%TYPE,
AUTO_CALC_FGT_RATE_APPEND_DEL WSH_SHIPPING_PARAMETERS.AUTO_CALC_FGT_RATE_APPEND_DEL%TYPE,
AUTO_CALC_FGT_RATE_SC_DEL     WSH_SHIPPING_PARAMETERS.AUTO_CALC_FGT_RATE_SC_DEL%TYPE,
RAISE_BUSINESS_EVENTS         WSH_SHIPPING_PARAMETERS.RAISE_BUSINESS_EVENTS%TYPE,
ENABLE_TRACKING_WFS           WSH_SHIPPING_PARAMETERS.ENABLE_TRACKING_WFS%TYPE,
ENABLE_SC_WF                  WSH_SHIPPING_PARAMETERS.ENABLE_SC_WF%TYPE,
PROCESS_FLAG                  VARCHAR2(1),
-- HW OPMCONV - Added CHECK_ON_HAND
CHECK_ON_HAND                 VARCHAR2(1),
-- Bugfix 7194517 added below 3 columns
MAX_NET_WEIGHT		          WSH_SHIPPING_PARAMETERS.MAX_NET_WEIGHT%TYPE,
MAX_GROSS_WEIGHT	          WSH_SHIPPING_PARAMETERS.MAX_GROSS_WEIGHT%TYPE,
OTM_ENABLED                   WSH_SHIPPING_PARAMETERS.OTM_ENABLED%TYPE,
--Bug 7131800
RETAIN_NONSTAGED_DET_FLAG     WSH_SHIPPING_PARAMETERS.RETAIN_NONSTAGED_DET_FLAG%TYPE,
--Bug 7131800
-- Bug 8446283 (Added wt/vol UOM codes on shipping parameters forms)
WEIGHT_UOM_CODE               WSH_SHIPPING_PARAMETERS.WEIGHT_UOM_CODE%TYPE,
VOLUME_UOM_CODE               WSH_SHIPPING_PARAMETERS.VOLUME_UOM_CODE%TYPE
-- Bug 8446283 : end
);

TYPE Global_Params_Rec IS RECORD (
AUTO_RATE_TP_REL_TRIPS        WSH_GLOBAL_PARAMETERS.AUTO_RATE_TP_REL_TRIPS%TYPE,
TL_PRIN_COST_ALLOC_BASIS      WSH_GLOBAL_PARAMETERS.TL_PRIN_COST_ALLOC_BASIS%TYPE,
TL_DISTANCE_ALLOC_BASIS       WSH_GLOBAL_PARAMETERS.TL_DISTANCE_ALLOC_BASIS%TYPE,
TL_STOP_COST_ALLOC_BASIS      WSH_GLOBAL_PARAMETERS.TL_STOP_COST_ALLOC_BASIS%TYPE,
AUTOFIRM_LOAD_TENDERED_TRIPS  WSH_GLOBAL_PARAMETERS.AUTOFIRM_LOAD_TENDERED_TRIPS%TYPE,
CONSOLIDATE_BO_LINES          WSH_GLOBAL_PARAMETERS.CONSOLIDATE_BO_LINES%TYPE,
GU_WEIGHT_CLASS               WSH_GLOBAL_PARAMETERS.GU_WEIGHT_CLASS%TYPE,
GU_WEIGHT_UOM                 WSH_GLOBAL_PARAMETERS.GU_WEIGHT_UOM%TYPE,
GU_VOLUME_UOM                 WSH_GLOBAL_PARAMETERS.GU_VOLUME_UOM%TYPE,
GU_VOLUME_CLASS               WSH_GLOBAL_PARAMETERS.GU_VOLUME_CLASS%TYPE,
GU_DISTANCE_CLASS             WSH_GLOBAL_PARAMETERS.GU_DISTANCE_CLASS%TYPE,
GU_DISTANCE_UOM               WSH_GLOBAL_PARAMETERS.GU_DISTANCE_UOM%TYPE,
GU_DIMENSION_CLASS            WSH_GLOBAL_PARAMETERS.GU_DIMENSION_CLASS%TYPE,
GU_DIMENSION_UOM              WSH_GLOBAL_PARAMETERS.GU_DIMENSION_UOM%TYPE,
GU_CURRENCY_COUNTRY           WSH_GLOBAL_PARAMETERS.GU_CURRENCY_COUNTRY%TYPE,
GU_CURRENCY_UOM               WSH_GLOBAL_PARAMETERS.GU_CURRENCY_UOM%TYPE,
GU_TIME_CLASS                 WSH_GLOBAL_PARAMETERS.GU_TIME_CLASS%TYPE,
GU_TIME_UOM                   WSH_GLOBAL_PARAMETERS.GU_TIME_UOM%TYPE,
DEF_MILE_CALC_ON_CUST_FAC     WSH_GLOBAL_PARAMETERS.DEF_MILE_CALC_ON_CUST_FAC%TYPE,
DEF_MILE_CALC_ON_SUPP_FAC     WSH_GLOBAL_PARAMETERS.DEF_MILE_CALC_ON_SUPP_FAC%TYPE,
DEF_MILE_CALC_ON_ORG_FAC      WSH_GLOBAL_PARAMETERS.DEF_MILE_CALC_ON_ORG_FAC%TYPE,
DEF_MILE_CALC_ON_CARR_FAC     WSH_GLOBAL_PARAMETERS.DEF_MILE_CALC_ON_CARR_FAC%TYPE,
TL_HWAY_DIS_EMP_CONSTANT      WSH_GLOBAL_PARAMETERS.TL_HWAY_DIS_EMP_CONSTANT%TYPE,
AVG_HWAY_SPEED                WSH_GLOBAL_PARAMETERS.AVG_HWAY_SPEED%TYPE,
DISTANCE_UOM                  WSH_GLOBAL_PARAMETERS.DISTANCE_UOM%TYPE,
TIME_UOM                      WSH_GLOBAL_PARAMETERS.TIME_UOM%TYPE,
UOM_FOR_NUM_OF_UNITS	      WSH_GLOBAL_PARAMETERS.UOM_FOR_NUM_OF_UNITS%TYPE,
PALLET_ITEM_TYPE              WSH_GLOBAL_PARAMETERS.PALLET_ITEM_TYPE%TYPE,
ATTRIBUTE_CATEGORY            WSH_GLOBAL_PARAMETERS.ATTRIBUTE_CATEGORY%TYPE,
ATTRIBUTE1                    WSH_GLOBAL_PARAMETERS.ATTRIBUTE1%TYPE,
ATTRIBUTE2                    WSH_GLOBAL_PARAMETERS.ATTRIBUTE2%TYPE,
ATTRIBUTE3                    WSH_GLOBAL_PARAMETERS.ATTRIBUTE3%TYPE,
ATTRIBUTE4                    WSH_GLOBAL_PARAMETERS.ATTRIBUTE4%TYPE,
ATTRIBUTE5                    WSH_GLOBAL_PARAMETERS.ATTRIBUTE5%TYPE,
ATTRIBUTE6                    WSH_GLOBAL_PARAMETERS.ATTRIBUTE6%TYPE,
ATTRIBUTE7                    WSH_GLOBAL_PARAMETERS.ATTRIBUTE7%TYPE,
ATTRIBUTE8                    WSH_GLOBAL_PARAMETERS.ATTRIBUTE8%TYPE,
ATTRIBUTE9                    WSH_GLOBAL_PARAMETERS.ATTRIBUTE9%TYPE,
ATTRIBUTE10                   WSH_GLOBAL_PARAMETERS.ATTRIBUTE10%TYPE,
ATTRIBUTE11                   WSH_GLOBAL_PARAMETERS.ATTRIBUTE11%TYPE,
ATTRIBUTE12                   WSH_GLOBAL_PARAMETERS.ATTRIBUTE12%TYPE,
ATTRIBUTE13                   WSH_GLOBAL_PARAMETERS.ATTRIBUTE13%TYPE,
ATTRIBUTE14                   WSH_GLOBAL_PARAMETERS.ATTRIBUTE14%TYPE,
ATTRIBUTE15                   WSH_GLOBAL_PARAMETERS.ATTRIBUTE15%TYPE,
CREATION_DATE                 WSH_GLOBAL_PARAMETERS.CREATION_DATE%TYPE,
CREATED_BY                    WSH_GLOBAL_PARAMETERS.CREATED_BY%TYPE,
LAST_UPDATE_DATE              WSH_GLOBAL_PARAMETERS.LAST_UPDATE_DATE%TYPE,
LAST_UPDATED_BY               WSH_GLOBAL_PARAMETERS.LAST_UPDATED_BY%TYPE,
LAST_UPDATE_LOGIN             WSH_GLOBAL_PARAMETERS.LAST_UPDATE_LOGIN%TYPE,
DEFER_INTERFACE               WSH_GLOBAL_PARAMETERS.DEFER_INTERFACE%TYPE,
ENFORCE_SHIP_METHOD           WSH_GLOBAL_PARAMETERS.ENFORCE_SHIP_METHOD%TYPE,
ALLOW_FUTURE_SHIP_DATE        WSH_GLOBAL_PARAMETERS.ALLOW_FUTURE_SHIP_DATE%TYPE,
RATE_IB_DELS_FGT_TERM         WSH_GLOBAL_PARAMETERS.RATE_IB_DELS_FGT_TERM%TYPE,
SKIP_RATE_OB_DELS_FGT_TERM    WSH_GLOBAL_PARAMETERS.SKIP_RATE_OB_DELS_FGT_TERM%TYPE,
DEL_DATE_CALC_METHOD	      WSH_GLOBAL_PARAMETERS.DEL_DATE_CALC_METHOD%TYPE,
RATE_DS_DELS_FGT_TERM_ID      WSH_GLOBAL_PARAMETERS.RATE_DS_DELS_FGT_TERM_ID%TYPE,
RAISE_BUSINESS_EVENTS         WSH_GLOBAL_PARAMETERS.RAISE_BUSINESS_EVENTS%TYPE,
ENABLE_TRACKING_WFS           WSH_GLOBAL_PARAMETERS.ENABLE_TRACKING_WFS%TYPE,
ENABLE_SC_WF                  WSH_GLOBAL_PARAMETERS.ENABLE_SC_WF%TYPE,
--bug 7491598 DEFER OTM-PLANNED SHIPMENT INTERFACES ENHANCEMENT
DEFER_PLAN_SHIPMENT_INTERFACE     WSH_GLOBAL_PARAMETERS.DEFER_PLAN_SHIPMENT_INTERFACE%TYPE
);

--
-- Procedure:		Get_Shipping_Parameters
-- Parameters:		p_organization_id - Organization's parameters
--			x_param_info - Record of all parameter info
--			x_return_status - return status of the API

PROCEDURE Get_Shipping_Parameters
	(p_organization_id	IN	NUMBER,
	 x_param_info		 OUT	NOCOPY Shipping_Params_Rec,
	 x_return_status	OUT NOCOPY 	VARCHAR2);

--
-- Procedure:		Get_Global_Parameters
-- Parameters:		x_global_param_info - Record of all parameter info
--			x_return_status - return status of the API

PROCEDURE Get_Global_Parameters
	  (x_global_param_info  OUT  NOCOPY  Global_Params_Rec,
	   x_return_status	    OUT NOCOPY   VARCHAR2);


END WSH_SHIPPING_PARAMS_GRP;

/