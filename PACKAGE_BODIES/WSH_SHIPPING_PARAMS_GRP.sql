--------------------------------------------------------
--  DDL for Package Body WSH_SHIPPING_PARAMS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_SHIPPING_PARAMS_GRP" as
/* $Header: WSHSPGPB.pls 120.0.12010000.5 2009/06/12 10:57:37 mvudugul ship $ */


--
-- Package Variables
--

G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_SHIPPING_PARAMS_GRP';

--
-- Procedure:		Get_Shipping_Parameters
-- Parameters:		p_organization_id - Organization's parameters
--			x_param_info - Record of all parameter info
--			x_return_status - return status of the API

PROCEDURE Get_Shipping_Parameters
	(p_organization_id	IN	NUMBER,
	 x_param_info		OUT	NOCOPY Shipping_Params_Rec,
   x_return_status	OUT	NOCOPY VARCHAR2) IS

	--
	--
	l_shipping_param_info	WSH_SHIPPING_PARAMS_PVT.Parameter_Rec_Typ;
	l_param_info		Shipping_Params_Rec;
	l_return_status		VARCHAR2(1);
	--
	l_debug_on BOOLEAN;
	--
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_SHIPPING_PARAMETERS';
	--

  BEGIN


  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --

  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --

  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
  END IF;

  --
     x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Fetch Shipping Parameters using WSH_SHIPPING_PARAMS_PVT.Get

  WSH_SHIPPING_PARAMS_PVT.Get(p_organization_id     => p_organization_id,
                              x_param_info          => l_shipping_param_info,
	                            x_return_status       => l_return_status);

    l_param_info.SHIP_CONFIRM_RULE_ID	:=	 l_shipping_param_info.SHIP_CONFIRM_RULE_ID;
    l_param_info.AUTOPACK_LEVEL		:=	 l_shipping_param_info.AUTOPACK_LEVEL;
    l_param_info.TASK_PLANNING_FLAG	:=	 l_shipping_param_info.TASK_PLANNING_FLAG;
    l_param_info.EXPORT_SCREENING_FLAG	:=	 l_shipping_param_info.EXPORT_SCREENING_FLAG;
    l_param_info.APPENDING_LIMIT	:=	 l_shipping_param_info.APPENDING_LIMIT;
    l_param_info.IGNORE_INBOUND_TRIP	:=	 l_shipping_param_info.IGNORE_INBOUND_TRIP;
    l_param_info.PACK_SLIP_REQUIRED_FLAG:=	 l_shipping_param_info.PACK_SLIP_REQUIRED_FLAG;
    l_param_info.PICK_SEQUENCE_RULE_ID	:=	 l_shipping_param_info.PICK_SEQUENCE_RULE_ID;
    l_param_info.PICK_GROUPING_RULE_ID	:=	 l_shipping_param_info.PICK_GROUPING_RULE_ID;
    l_param_info.PRINT_PICK_SLIP_MODE	:=	 l_shipping_param_info.PRINT_PICK_SLIP_MODE;
    l_param_info.PICK_RELEASE_REPORT_SET_ID:=	 l_shipping_param_info.PICK_RELEASE_REPORT_SET_ID;
    l_param_info.AUTOCREATE_DEL_ORDERS_FLAG:=	 l_shipping_param_info.AUTOCREATE_DEL_ORDERS_FLAG;
    l_param_info.DEFAULT_STAGE_SUBINVENTORY:=	 l_shipping_param_info.DEFAULT_STAGE_SUBINVENTORY;
    l_param_info.DEFAULT_STAGE_LOCATOR_ID  :=	 l_shipping_param_info.DEFAULT_STAGE_LOCATOR_ID;
    l_param_info.AUTODETAIL_PR_FLAG	:=	 l_shipping_param_info.AUTODETAIL_PR_FLAG;
    l_param_info.ENFORCE_PACKING_FLAG	:=	 l_shipping_param_info.ENFORCE_PACKING_FLAG;
    l_param_info.GROUP_BY_CUSTOMER_FLAG	:=	 l_shipping_param_info.GROUP_BY_CUSTOMER_FLAG;
    l_param_info.GROUP_BY_FOB_FLAG	:=	 l_shipping_param_info.GROUP_BY_FOB_FLAG;
    l_param_info.GROUP_BY_FREIGHT_TERMS_FLAG :=	 l_shipping_param_info.GROUP_BY_FREIGHT_TERMS_FLAG;
    l_param_info.GROUP_BY_INTMED_SHIP_TO_FLAG:=	 l_shipping_param_info.GROUP_BY_INTMED_SHIP_TO_FLAG;
    l_param_info.GROUP_BY_SHIP_METHOD_FLAG   :=	 l_shipping_param_info.GROUP_BY_SHIP_METHOD_FLAG;
    l_param_info.GROUP_BY_CARRIER_FLAG	:=	 l_shipping_param_info.GROUP_BY_CARRIER_FLAG;
    l_param_info.ATTRIBUTE_CATEGORY	:=	 l_shipping_param_info.ATTRIBUTE_CATEGORY;
    l_param_info.ATTRIBUTE1		:=	 l_shipping_param_info.ATTRIBUTE1;
    l_param_info.ATTRIBUTE2		:=	 l_shipping_param_info.ATTRIBUTE2;
    l_param_info.ATTRIBUTE3		:=	 l_shipping_param_info.ATTRIBUTE3;
    l_param_info.ATTRIBUTE4		:=	 l_shipping_param_info.ATTRIBUTE4;
    l_param_info.ATTRIBUTE5		:=	 l_shipping_param_info.ATTRIBUTE5;
    l_param_info.ATTRIBUTE6		:=	 l_shipping_param_info.ATTRIBUTE6;
    l_param_info.ATTRIBUTE7		:=	 l_shipping_param_info.ATTRIBUTE7;
    l_param_info.ATTRIBUTE8		:=	 l_shipping_param_info.ATTRIBUTE8;
    l_param_info.ATTRIBUTE9		:=	 l_shipping_param_info.ATTRIBUTE9;
    l_param_info.ATTRIBUTE10		:=	 l_shipping_param_info.ATTRIBUTE10;
    l_param_info.ATTRIBUTE11		:=	 l_shipping_param_info.ATTRIBUTE11;
    l_param_info.ATTRIBUTE12		:=	 l_shipping_param_info.ATTRIBUTE12;
    l_param_info.ATTRIBUTE13		:=	 l_shipping_param_info.ATTRIBUTE13;
    l_param_info.ATTRIBUTE14		:=	 l_shipping_param_info.ATTRIBUTE14;
    l_param_info.ATTRIBUTE15		:=	 l_shipping_param_info.ATTRIBUTE15;
    l_param_info.CREATION_DATE		:=	 l_shipping_param_info.CREATION_DATE;
    l_param_info.CREATED_BY		:=	 l_shipping_param_info.CREATED_BY;
    l_param_info.LAST_UPDATE_DATE	:=	 l_shipping_param_info.LAST_UPDATE_DATE;
    l_param_info.LAST_UPDATED_BY	:=	 l_shipping_param_info.LAST_UPDATED_BY;
    l_param_info.LAST_UPDATE_LOGIN	:=	 l_shipping_param_info.LAST_UPDATE_LOGIN;
    l_param_info.PROGRAM_APPLICATION_ID	:=	 l_shipping_param_info.PROGRAM_APPLICATION_ID;
    l_param_info.PROGRAM_ID		:=	 l_shipping_param_info.PROGRAM_ID;
    l_param_info.PROGRAM_UPDATE_DATE	:=	 l_shipping_param_info.PROGRAM_UPDATE_DATE;
    l_param_info.REQUEST_ID		:=	 l_shipping_param_info.REQUEST_ID;
    l_param_info.PICK_SLIP_LINES	:=	 l_shipping_param_info.PICK_SLIP_LINES;
    l_param_info.AUTOCREATE_DELIVERIES_FLAG:=	 l_shipping_param_info.AUTOCREATE_DELIVERIES_FLAG;
    l_param_info.FREIGHT_CLASS_CAT_SET_ID  :=	 l_shipping_param_info.FREIGHT_CLASS_CAT_SET_ID;
    l_param_info.COMMODITY_CODE_CAT_SET_ID :=	 l_shipping_param_info.COMMODITY_CODE_CAT_SET_ID;
    l_param_info.ENFORCE_SHIP_SET_AND_SMC  :=	 l_shipping_param_info.ENFORCE_SHIP_SET_AND_SMC;
    l_param_info.AUTO_SEND_DOC_FLAG	   :=	 l_shipping_param_info.AUTO_SEND_DOC_FLAG;
    l_param_info.ITM_ADDITIONAL_COUNTRY_CODE:=	 l_shipping_param_info.ITM_ADDITIONAL_COUNTRY_CODE;
    l_param_info.AUTO_SELECT_CARRIER	    :=	 l_shipping_param_info.AUTO_SELECT_CARRIER;
    l_param_info.GOODS_DISPATCHED_ACCOUNT   :=	 l_shipping_param_info.GOODS_DISPATCHED_ACCOUNT;
    l_param_info.LOCATION_ID		:=	 l_shipping_param_info.LOCATION_ID;
    l_param_info.ORGANIZATION_ID	:=	 l_shipping_param_info.ORGANIZATION_ID;
    l_param_info.WEIGHT_UOM_CLASS	:=	 l_shipping_param_info.WEIGHT_UOM_CLASS;
    l_param_info.VOLUME_UOM_CLASS	:=	 l_shipping_param_info.VOLUME_UOM_CLASS;
    l_param_info.WEIGHT_VOLUME_FLAG	:=	 l_shipping_param_info.WEIGHT_VOLUME_FLAG;
    l_param_info.INV_CONTROLS_CONTAINER_FLAG:=	 l_shipping_param_info.INV_CONTROLS_CONTAINER_FLAG;
    l_param_info.PERCENT_FILL_BASIS_FLAG:=	 l_shipping_param_info.PERCENT_FILL_BASIS_FLAG;
    l_param_info.TRIP_REPORT_SET_ID	:=	 l_shipping_param_info.TRIP_REPORT_SET_ID;
    l_param_info.DELIVERY_REPORT_SET_ID	:=	 l_shipping_param_info.DELIVERY_REPORT_SET_ID;
    l_param_info.AUTOCREATE_DEL_ORDERS_PR_FLAG:= l_shipping_param_info.AUTOCREATE_DEL_ORDERS_PR_FLAG;
    l_param_info.FPA_POSITIVE_TOL_AMT	:=	 l_shipping_param_info.FPA_POSITIVE_TOL_AMT;
    l_param_info.FPA_NEGATIVE_TOL_AMT	:=	 l_shipping_param_info.FPA_NEGATIVE_TOL_AMT;
    l_param_info.FPA_POSITIVE_TOL_PERCENTAGE:=	 l_shipping_param_info.FPA_POSITIVE_TOL_PERCENTAGE;
    l_param_info.FPA_NEGATIVE_TOL_PERCENTAGE:=	 l_shipping_param_info.FPA_NEGATIVE_TOL_PERCENTAGE;
    l_param_info.FPA_DEFAULT_FREIGHT_ACCOUNT:=	 l_shipping_param_info.FPA_DEFAULT_FREIGHT_ACCOUNT;
    l_param_info.AUTO_APPLY_ROUTING_RULES   :=	 l_shipping_param_info.AUTO_APPLY_ROUTING_RULES;
    l_param_info.AUTO_CALC_FGT_RATE_CR_DEL  :=	 l_shipping_param_info.AUTO_CALC_FGT_RATE_CR_DEL;
    l_param_info.AUTO_CALC_FGT_RATE_APPEND_DEL:= l_shipping_param_info.AUTO_CALC_FGT_RATE_APPEND_DEL;
    l_param_info.AUTO_CALC_FGT_RATE_SC_DEL   :=	 l_shipping_param_info.AUTO_CALC_FGT_RATE_SC_DEL;
    l_param_info.RAISE_BUSINESS_EVENTS  :=	 l_shipping_param_info.RAISE_BUSINESS_EVENTS;
    l_param_info.ENABLE_TRACKING_WFS    :=       l_shipping_param_info.ENABLE_TRACKING_WFS;
    l_param_info.ENABLE_SC_WF           :=       l_shipping_param_info.ENABLE_SC_WF;
    l_param_info.PROCESS_FLAG           :=       l_shipping_param_info.PROCESS_FLAG;
-- HW OPMCONV - Retrieve check_on_hand
    l_param_info.CHECK_ON_HAND               :=	 l_shipping_param_info.CHECK_ON_HAND ;
-- Bugfix 7194517 added below 3 columns
    l_param_info.MAX_NET_WEIGHT              :=  l_shipping_param_info.MAX_NET_WEIGHT;
    l_param_info.MAX_GROSS_WEIGHT            :=  l_shipping_param_info.MAX_GROSS_WEIGHT;
    l_param_info.OTM_ENABLED                 :=  l_shipping_param_info.OTM_ENABLED;
    --Bug 7131800
    l_param_info.retain_nonstaged_det_flag :=  l_shipping_param_info.retain_nonstaged_det_flag;
    --Bug 7131800
    -- Bug 8446283 (Added wt/vol UOM codes on shipping parameters forms)
    l_param_info.weight_uom_code           :=  l_shipping_param_info.weight_uom_code;
    l_param_info.volume_uom_code           :=  l_shipping_param_info.volume_uom_code;
    -- Bug 8446283 : end
    x_return_status := l_return_status;
    x_param_info := l_param_info;

    -- Debug Statements
    --
    IF l_debug_on THEN
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.SHIP_CONFIRM_RULE_ID ',X_PARAM_INFO.SHIP_CONFIRM_RULE_ID);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.AUTOPACK_LEVEL ',X_PARAM_INFO.AUTOPACK_LEVEL);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.TASK_PLANNING_FLAG ',X_PARAM_INFO.TASK_PLANNING_FLAG);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.EXPORT_SCREENING_FLAG ',X_PARAM_INFO.EXPORT_SCREENING_FLAG);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.APPENDING_LIMIT ',X_PARAM_INFO.APPENDING_LIMIT);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.IGNORE_INBOUND_TRIP ',X_PARAM_INFO.IGNORE_INBOUND_TRIP);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.PACK_SLIP_REQUIRED_FLAG ',X_PARAM_INFO.PACK_SLIP_REQUIRED_FLAG);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.PICK_SEQUENCE_RULE_ID ',X_PARAM_INFO.PICK_SEQUENCE_RULE_ID);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.PICK_GROUPING_RULE_ID ',X_PARAM_INFO.PICK_GROUPING_RULE_ID);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.PRINT_PICK_SLIP_MODE ',X_PARAM_INFO.PRINT_PICK_SLIP_MODE);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.PICK_RELEASE_REPORT_SET_ID ',X_PARAM_INFO.PICK_RELEASE_REPORT_SET_ID);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.AUTOCREATE_DEL_ORDERS_FLAG ',X_PARAM_INFO.AUTOCREATE_DEL_ORDERS_FLAG);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.DEFAULT_STAGE_SUBINVENTORY ',X_PARAM_INFO.DEFAULT_STAGE_SUBINVENTORY);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.DEFAULT_STAGE_LOCATOR_ID ',X_PARAM_INFO.DEFAULT_STAGE_LOCATOR_ID);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.AUTODETAIL_PR_FLAG ',X_PARAM_INFO.AUTODETAIL_PR_FLAG);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ENFORCE_PACKING_FLAG ',X_PARAM_INFO.ENFORCE_PACKING_FLAG);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.GROUP_BY_CUSTOMER_FLAG ',X_PARAM_INFO.GROUP_BY_CUSTOMER_FLAG);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.GROUP_BY_FOB_FLAG ',X_PARAM_INFO.GROUP_BY_FOB_FLAG);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.GROUP_BY_FREIGHT_TERMS_FLAG ',X_PARAM_INFO.GROUP_BY_FREIGHT_TERMS_FLAG);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.GROUP_BY_INTMED_SHIP_TO_FLAG ',X_PARAM_INFO.GROUP_BY_INTMED_SHIP_TO_FLAG);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.GROUP_BY_SHIP_METHOD_FLAG ',X_PARAM_INFO.GROUP_BY_SHIP_METHOD_FLAG);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.GROUP_BY_CARRIER_FLAG ',X_PARAM_INFO.GROUP_BY_CARRIER_FLAG);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE_CATEGORY ',X_PARAM_INFO.ATTRIBUTE_CATEGORY);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE1 ',X_PARAM_INFO.ATTRIBUTE1);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE2 ',X_PARAM_INFO.ATTRIBUTE2);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE3 ',X_PARAM_INFO.ATTRIBUTE3);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE4 ',X_PARAM_INFO.ATTRIBUTE4);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE5 ',X_PARAM_INFO.ATTRIBUTE5);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE6 ',X_PARAM_INFO.ATTRIBUTE6);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE7 ',X_PARAM_INFO.ATTRIBUTE7);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE8 ',X_PARAM_INFO.ATTRIBUTE8);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE9 ',X_PARAM_INFO.ATTRIBUTE9);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE10 ',X_PARAM_INFO.ATTRIBUTE10);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE11 ',X_PARAM_INFO.ATTRIBUTE11);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE12 ',X_PARAM_INFO.ATTRIBUTE12);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE13 ',X_PARAM_INFO.ATTRIBUTE13);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE14 ',X_PARAM_INFO.ATTRIBUTE14);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE15 ',X_PARAM_INFO.ATTRIBUTE15);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.CREATION_DATE ',X_PARAM_INFO.CREATION_DATE);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.CREATED_BY ',X_PARAM_INFO.CREATED_BY);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.LAST_UPDATE_DATE ',X_PARAM_INFO.LAST_UPDATE_DATE);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.LAST_UPDATED_BY ',X_PARAM_INFO.LAST_UPDATED_BY);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.LAST_UPDATE_LOGIN ',X_PARAM_INFO.LAST_UPDATE_LOGIN);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.PROGRAM_APPLICATION_ID ',X_PARAM_INFO.PROGRAM_APPLICATION_ID);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.PROGRAM_ID ',X_PARAM_INFO.PROGRAM_ID);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.PROGRAM_UPDATE_DATE ',X_PARAM_INFO.PROGRAM_UPDATE_DATE);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.REQUEST_ID ',X_PARAM_INFO.REQUEST_ID);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.PICK_SLIP_LINES ',X_PARAM_INFO.PICK_SLIP_LINES);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.AUTOCREATE_DELIVERIES_FLAG ',X_PARAM_INFO.AUTOCREATE_DELIVERIES_FLAG);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.FREIGHT_CLASS_CAT_SET_ID ',X_PARAM_INFO.FREIGHT_CLASS_CAT_SET_ID);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.COMMODITY_CODE_CAT_SET_ID ',X_PARAM_INFO.COMMODITY_CODE_CAT_SET_ID);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ENFORCE_SHIP_SET_AND_SMC ',X_PARAM_INFO.ENFORCE_SHIP_SET_AND_SMC);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.AUTO_SEND_DOC_FLAG ',X_PARAM_INFO.AUTO_SEND_DOC_FLAG);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ITM_ADDITIONAL_COUNTRY_CODE ',X_PARAM_INFO.ITM_ADDITIONAL_COUNTRY_CODE);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.AUTO_SELECT_CARRIER ',X_PARAM_INFO.AUTO_SELECT_CARRIER);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.GOODS_DISPATCHED_ACCOUNT ',X_PARAM_INFO.GOODS_DISPATCHED_ACCOUNT);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.LOCATION_ID ',X_PARAM_INFO.LOCATION_ID);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ORGANIZATION_ID ',X_PARAM_INFO.ORGANIZATION_ID);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.WEIGHT_UOM_CLASS ',X_PARAM_INFO.WEIGHT_UOM_CLASS);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.VOLUME_UOM_CLASS ',X_PARAM_INFO.VOLUME_UOM_CLASS);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.WEIGHT_VOLUME_FLAG ',X_PARAM_INFO.WEIGHT_VOLUME_FLAG);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.INV_CONTROLS_CONTAINER_FLAG ',X_PARAM_INFO.INV_CONTROLS_CONTAINER_FLAG);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.PERCENT_FILL_BASIS_FLAG ',X_PARAM_INFO.PERCENT_FILL_BASIS_FLAG);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.TRIP_REPORT_SET_ID ',X_PARAM_INFO.TRIP_REPORT_SET_ID);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.DELIVERY_REPORT_SET_ID ',X_PARAM_INFO.DELIVERY_REPORT_SET_ID);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.AUTOCREATE_DEL_ORDERS_PR_FLAG ',X_PARAM_INFO.AUTOCREATE_DEL_ORDERS_PR_FLAG);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.FPA_POSITIVE_TOL_AMT ',X_PARAM_INFO.FPA_POSITIVE_TOL_AMT);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.FPA_NEGATIVE_TOL_AMT ',X_PARAM_INFO.FPA_NEGATIVE_TOL_AMT);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.FPA_POSITIVE_TOL_PERCENTAGE ',X_PARAM_INFO.FPA_POSITIVE_TOL_PERCENTAGE);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.FPA_NEGATIVE_TOL_PERCENTAGE ',X_PARAM_INFO.FPA_NEGATIVE_TOL_PERCENTAGE);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.FPA_DEFAULT_FREIGHT_ACCOUNT ',X_PARAM_INFO.FPA_DEFAULT_FREIGHT_ACCOUNT);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.AUTO_APPLY_ROUTING_RULES ',X_PARAM_INFO.AUTO_APPLY_ROUTING_RULES);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.AUTO_CALC_FGT_RATE_CR_DEL ',X_PARAM_INFO.AUTO_CALC_FGT_RATE_CR_DEL);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.AUTO_CALC_FGT_RATE_APPEND_DEL ',X_PARAM_INFO.AUTO_CALC_FGT_RATE_APPEND_DEL);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.AUTO_CALC_FGT_RATE_SC_DEL ',X_PARAM_INFO.AUTO_CALC_FGT_RATE_SC_DEL);
                         WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.RAISE_BUSINESS_EVENTS',X_PARAM_INFO.RAISE_BUSINESS_EVENTS);
                         WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ENABLE_TRACKING_WFS',X_PARAM_INFO.ENABLE_TRACKING_WFS);
                         WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ENABLE_SC_WF',X_PARAM_INFO.ENABLE_SC_WF);
                         WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.PROCESS_FLAG ',X_PARAM_INFO.PROCESS_FLAG);
-- HW OPMCONV - Print the value of check_on_hand
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.CHECK_ON_HAND ',X_PARAM_INFO.CHECK_ON_HAND);
-- Bugfix 7194517 Start
  			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.MAX_NET_WEIGHT ',X_PARAM_INFO.MAX_NET_WEIGHT);
			 WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.MAX_GROSS_WEIGHT ',X_PARAM_INFO.MAX_GROSS_WEIGHT);
             WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.OTM_ENABLED',X_PARAM_INFO.OTM_ENABLED);
-- Bugfix 7194517 End
--Bug 7131800
		     WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.RETAIN_NONSTAGED_DET_FLAG ',X_PARAM_INFO.RETAIN_NONSTAGED_DET_FLAG);
--Bug 7131800
             -- Bug 8446283 begin
             WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.WEIGHT_UOM_CODE ',X_PARAM_INFO.WEIGHT_UOM_CODE);
             WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.VOLUME_UOM_CODE ',X_PARAM_INFO.VOLUME_UOM_CODE);
             -- Bug 8446283 end

    END IF;
--
-- Debug Statements
--
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
--
END Get_Shipping_Parameters;

--
-- Procedure:		Get_Global_Parameters
-- Parameters:		x_global_param_info - Record of all Global parameters
--			x_return_status - return status of the API

PROCEDURE Get_Global_Parameters
  (x_global_param_info   OUT NOCOPY  Global_Params_Rec,
   x_return_status  OUT NOCOPY  VARCHAR2) IS

  --
  --Variable Declaration.
  --
	l_global_param_info   WSH_SHIPPING_PARAMS_PVT.Global_Parameters_Rec_Typ;
  l_param_info		 Global_Params_Rec;
  l_return_status	 VARCHAR2(1);
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_GLOBAL_PARAMETERS';
  --
BEGIN

  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
  END IF;
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Fetch Global Parameters using WSH_SHIPPING_PARAMS_PVT.Get_Global_Parameters

   WSH_SHIPPING_PARAMS_PVT.Get_Global_Parameters( x_param_info => l_global_param_info,
						  x_return_status =>l_return_status);

	l_param_info.AUTO_RATE_TP_REL_TRIPS	:=	l_global_param_info.AUTO_RATE_TP_REL_TRIPS;
	l_param_info.TL_PRIN_COST_ALLOC_BASIS	:=	l_global_param_info.TL_PRIN_COST_ALLOC_BASIS;
	l_param_info.TL_DISTANCE_ALLOC_BASIS	:=	l_global_param_info.TL_DISTANCE_ALLOC_BASIS;
	l_param_info.TL_STOP_COST_ALLOC_BASIS	:=	l_global_param_info.TL_STOP_COST_ALLOC_BASIS;
	l_param_info.AUTOFIRM_LOAD_TENDERED_TRIPS:=	l_global_param_info.AUTOFIRM_LOAD_TENDERED_TRIPS;
	l_param_info.CONSOLIDATE_BO_LINES	:=	l_global_param_info.CONSOLIDATE_BO_LINES;
	l_param_info.GU_WEIGHT_CLASS		:=	l_global_param_info.GU_WEIGHT_CLASS;
	l_param_info.GU_WEIGHT_UOM		:=	l_global_param_info.GU_WEIGHT_UOM;
	l_param_info.GU_VOLUME_UOM		:=	l_global_param_info.GU_VOLUME_UOM;
	l_param_info.GU_VOLUME_CLASS		:=	l_global_param_info.GU_VOLUME_CLASS;
	l_param_info.GU_DISTANCE_CLASS		:=	l_global_param_info.GU_DISTANCE_CLASS;
	l_param_info.GU_DISTANCE_UOM		:=	l_global_param_info.GU_DISTANCE_UOM;
	l_param_info.GU_DIMENSION_CLASS		:=	l_global_param_info.GU_DIMENSION_CLASS;
	l_param_info.GU_DIMENSION_UOM		:=	l_global_param_info.GU_DIMENSION_UOM;
	l_param_info.GU_CURRENCY_COUNTRY	:=	l_global_param_info.GU_CURRENCY_COUNTRY;
	l_param_info.GU_CURRENCY_UOM		:=	l_global_param_info.GU_CURRENCY_UOM;
	l_param_info.GU_TIME_CLASS		:=	l_global_param_info.GU_TIME_CLASS;
	l_param_info.GU_TIME_UOM		:=	l_global_param_info.GU_TIME_UOM;
	l_param_info.DEF_MILE_CALC_ON_CUST_FAC	:=	l_global_param_info.DEF_MILE_CALC_ON_CUST_FAC;
	l_param_info.DEF_MILE_CALC_ON_SUPP_FAC	:=	l_global_param_info.DEF_MILE_CALC_ON_SUPP_FAC;
	l_param_info.DEF_MILE_CALC_ON_ORG_FAC	:=	l_global_param_info.DEF_MILE_CALC_ON_ORG_FAC;
	l_param_info.DEF_MILE_CALC_ON_CARR_FAC	:=	l_global_param_info.DEF_MILE_CALC_ON_CARR_FAC;
	l_param_info.TL_HWAY_DIS_EMP_CONSTANT	:=	l_global_param_info.TL_HWAY_DIS_EMP_CONSTANT;
	l_param_info.AVG_HWAY_SPEED		:=	l_global_param_info.AVG_HWAY_SPEED;
	l_param_info.DISTANCE_UOM		:=	l_global_param_info.DISTANCE_UOM;
	l_param_info.TIME_UOM			:=	l_global_param_info.TIME_UOM;
	l_param_info.UOM_FOR_NUM_OF_UNITS	:=	l_global_param_info.UOM_FOR_NUM_OF_UNITS;
	l_param_info.PALLET_ITEM_TYPE		:=	l_global_param_info.PALLET_ITEM_TYPE;
	l_param_info.ATTRIBUTE_CATEGORY		:=	l_global_param_info.ATTRIBUTE_CATEGORY;
	l_param_info.ATTRIBUTE1			:=	l_global_param_info.ATTRIBUTE1;
	l_param_info.ATTRIBUTE2			:=	l_global_param_info.ATTRIBUTE2;
	l_param_info.ATTRIBUTE3			:=	l_global_param_info.ATTRIBUTE3;
	l_param_info.ATTRIBUTE4			:=	l_global_param_info.ATTRIBUTE4;
	l_param_info.ATTRIBUTE5			:=	l_global_param_info.ATTRIBUTE5;
	l_param_info.ATTRIBUTE6			:=	l_global_param_info.ATTRIBUTE6;
	l_param_info.ATTRIBUTE7			:=	l_global_param_info.ATTRIBUTE7;
	l_param_info.ATTRIBUTE8			:=	l_global_param_info.ATTRIBUTE8;
	l_param_info.ATTRIBUTE9			:=	l_global_param_info.ATTRIBUTE9;
	l_param_info.ATTRIBUTE10		:=	l_global_param_info.ATTRIBUTE10;
	l_param_info.ATTRIBUTE11		:=	l_global_param_info.ATTRIBUTE11;
	l_param_info.ATTRIBUTE12		:=	l_global_param_info.ATTRIBUTE12;
	l_param_info.ATTRIBUTE13		:=	l_global_param_info.ATTRIBUTE13;
	l_param_info.ATTRIBUTE14		:=	l_global_param_info.ATTRIBUTE14;
	l_param_info.ATTRIBUTE15		:=	l_global_param_info.ATTRIBUTE15;
	l_param_info.CREATION_DATE		:=	l_global_param_info.CREATION_DATE;
	l_param_info.CREATED_BY			:=	l_global_param_info.CREATED_BY;
	l_param_info.LAST_UPDATE_DATE		:=	l_global_param_info.LAST_UPDATE_DATE;
	l_param_info.LAST_UPDATED_BY		:=	l_global_param_info.LAST_UPDATED_BY;
	l_param_info.LAST_UPDATE_LOGIN		:=	l_global_param_info.LAST_UPDATE_LOGIN;
	l_param_info.DEFER_INTERFACE		:=	l_global_param_info.DEFER_INTERFACE;
	l_param_info.ENFORCE_SHIP_METHOD	:=	l_global_param_info.ENFORCE_SHIP_METHOD;
	l_param_info.ALLOW_FUTURE_SHIP_DATE :=	l_global_param_info.ALLOW_FUTURE_SHIP_DATE;
	l_param_info.RATE_IB_DELS_FGT_TERM	:=	l_global_param_info.RATE_IB_DELS_FGT_TERM;
	l_param_info.SKIP_RATE_OB_DELS_FGT_TERM:= l_global_param_info.SKIP_RATE_OB_DELS_FGT_TERM;
	l_param_info.DEL_DATE_CALC_METHOD	   := l_global_param_info.DEL_DATE_CALC_METHOD;
	l_param_info.RATE_DS_DELS_FGT_TERM_ID  := l_global_param_info.RATE_DS_DELS_FGT_TERM_ID;
        l_param_info.RAISE_BUSINESS_EVENTS     := l_global_param_info.RAISE_BUSINESS_EVENTS;
        l_param_info.ENABLE_TRACKING_WFS       := l_global_param_info.ENABLE_TRACKING_WFS;
        l_param_info.ENABLE_SC_WF              := l_global_param_info.ENABLE_SC_WF;
	--bug 7491598 DEFER OTM-PLANNED SHIPMENT INTERFACES ENHANCEMENT
	l_param_info.DEFER_PLAN_SHIPMENT_INTERFACE := l_global_param_info.DEFER_PLAN_SHIPMENT_INTERFACE;

	x_return_status := l_return_status;
	x_global_param_info := l_param_info;

	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.AUTO_RATE_TP_REL_TRIPS ',X_GLOBAL_PARAM_INFO.AUTO_RATE_TP_REL_TRIPS);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.TL_PRIN_COST_ALLOC_BASIS ',X_GLOBAL_PARAM_INFO.TL_PRIN_COST_ALLOC_BASIS);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.TL_DISTANCE_ALLOC_BASIS  ',X_GLOBAL_PARAM_INFO.TL_DISTANCE_ALLOC_BASIS);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.TL_STOP_COST_ALLOC_BASIS ',X_GLOBAL_PARAM_INFO.TL_STOP_COST_ALLOC_BASIS);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.AUTOFIRM_LOAD_TENDERED_TRIPS ',X_GLOBAL_PARAM_INFO.AUTOFIRM_LOAD_TENDERED_TRIPS);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.CONSOLIDATE_BO_LINES ',X_GLOBAL_PARAM_INFO.CONSOLIDATE_BO_LINES);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.GU_WEIGHT_CLASS ',X_GLOBAL_PARAM_INFO.GU_WEIGHT_CLASS);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.GU_WEIGHT_UOM ',X_GLOBAL_PARAM_INFO.GU_WEIGHT_UOM);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.GU_VOLUME_UOM ',X_GLOBAL_PARAM_INFO.GU_VOLUME_UOM);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.GU_VOLUME_CLASS ',X_GLOBAL_PARAM_INFO.GU_VOLUME_CLASS);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.GU_DISTANCE_CLASS ',X_GLOBAL_PARAM_INFO.GU_DISTANCE_CLASS);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.GU_DISTANCE_UOM ',X_GLOBAL_PARAM_INFO.GU_DISTANCE_UOM);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.GU_DIMENSION_CLASS ',X_GLOBAL_PARAM_INFO.GU_DIMENSION_CLASS);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.GU_DIMENSION_UOM ',X_GLOBAL_PARAM_INFO.GU_DIMENSION_UOM);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.GU_CURRENCY_COUNTRY ',X_GLOBAL_PARAM_INFO.GU_CURRENCY_COUNTRY);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.GU_CURRENCY_UOM ',X_GLOBAL_PARAM_INFO.GU_CURRENCY_UOM);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.GU_TIME_CLASS ',X_GLOBAL_PARAM_INFO.GU_TIME_CLASS);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.GU_TIME_UOM ',X_GLOBAL_PARAM_INFO.GU_TIME_UOM);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.DEF_MILE_CALC_ON_CUST_FAC ',X_GLOBAL_PARAM_INFO.DEF_MILE_CALC_ON_CUST_FAC);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.DEF_MILE_CALC_ON_SUPP_FAC ',X_GLOBAL_PARAM_INFO.DEF_MILE_CALC_ON_SUPP_FAC);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.DEF_MILE_CALC_ON_ORG_FAC ',X_GLOBAL_PARAM_INFO.DEF_MILE_CALC_ON_ORG_FAC);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.DEF_MILE_CALC_ON_CARR_FAC ',X_GLOBAL_PARAM_INFO.DEF_MILE_CALC_ON_CARR_FAC);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.TL_HWAY_DIS_EMP_CONSTANT ',X_GLOBAL_PARAM_INFO.TL_HWAY_DIS_EMP_CONSTANT);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.AVG_HWAY_SPEED ',X_GLOBAL_PARAM_INFO.AVG_HWAY_SPEED);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.DISTANCE_UOM ',X_GLOBAL_PARAM_INFO.DISTANCE_UOM);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.TIME_UOM ',X_GLOBAL_PARAM_INFO.TIME_UOM);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.UOM_FOR_NUM_OF_UNITS ',X_GLOBAL_PARAM_INFO.UOM_FOR_NUM_OF_UNITS);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.PALLET_ITEM_TYPE ',X_GLOBAL_PARAM_INFO.PALLET_ITEM_TYPE);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.ATTRIBUTE_CATEGORY ',X_GLOBAL_PARAM_INFO.ATTRIBUTE_CATEGORY);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.ATTRIBUTE1 ',X_GLOBAL_PARAM_INFO.ATTRIBUTE1);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.ATTRIBUTE2 ',X_GLOBAL_PARAM_INFO.ATTRIBUTE2);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.ATTRIBUTE3 ',X_GLOBAL_PARAM_INFO.ATTRIBUTE3);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.ATTRIBUTE4 ',X_GLOBAL_PARAM_INFO.ATTRIBUTE4);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.ATTRIBUTE5 ',X_GLOBAL_PARAM_INFO.ATTRIBUTE5);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.ATTRIBUTE6 ',X_GLOBAL_PARAM_INFO.ATTRIBUTE6);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.ATTRIBUTE7 ',X_GLOBAL_PARAM_INFO.ATTRIBUTE7);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.ATTRIBUTE8 ',X_GLOBAL_PARAM_INFO.ATTRIBUTE8);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.ATTRIBUTE9 ',X_GLOBAL_PARAM_INFO.ATTRIBUTE9);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.ATTRIBUTE10 ',X_GLOBAL_PARAM_INFO.ATTRIBUTE10);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.ATTRIBUTE11 ',X_GLOBAL_PARAM_INFO.ATTRIBUTE11);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.ATTRIBUTE12 ',X_GLOBAL_PARAM_INFO.ATTRIBUTE12);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.ATTRIBUTE13 ',X_GLOBAL_PARAM_INFO.ATTRIBUTE13);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.ATTRIBUTE14 ',X_GLOBAL_PARAM_INFO.ATTRIBUTE14);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.ATTRIBUTE15 ',X_GLOBAL_PARAM_INFO.ATTRIBUTE15);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.CREATION_DATE ',X_GLOBAL_PARAM_INFO.CREATION_DATE);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.CREATED_BY ',X_GLOBAL_PARAM_INFO.CREATED_BY);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.LAST_UPDATE_DATE ',X_GLOBAL_PARAM_INFO.LAST_UPDATE_DATE);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.LAST_UPDATED_BY ',X_GLOBAL_PARAM_INFO.LAST_UPDATED_BY);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.LAST_UPDATE_LOGIN ',X_GLOBAL_PARAM_INFO.LAST_UPDATE_LOGIN);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.ENFORCE_SHIP_METHOD ',X_GLOBAL_PARAM_INFO.ENFORCE_SHIP_METHOD);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.ALLOW_FUTURE_SHIP_DATE ',X_GLOBAL_PARAM_INFO.ALLOW_FUTURE_SHIP_DATE);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.DEFER_INTERFACE ',X_GLOBAL_PARAM_INFO.DEFER_INTERFACE);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.RATE_IB_DELS_FGT_TERM ',X_GLOBAL_PARAM_INFO.RATE_IB_DELS_FGT_TERM);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.SKIP_RATE_OB_DELS_FGT_TERM ',X_GLOBAL_PARAM_INFO.SKIP_RATE_OB_DELS_FGT_TERM);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.DEL_DATE_CALC_METHOD ',X_GLOBAL_PARAM_INFO.DEL_DATE_CALC_METHOD);
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.RATE_DS_DELS_FGT_TERM_ID ',X_GLOBAL_PARAM_INFO.RATE_DS_DELS_FGT_TERM_ID);
                WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.RAISE_BUSINESS_EVENTS',X_GLOBAL_PARAM_INFO.RAISE_BUSINESS_EVENTS);
                WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.ENABLE_TRACKING_WFS',X_GLOBAL_PARAM_INFO.ENABLE_TRACKING_WFS);
                WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.ENABLE_SC_WF',X_GLOBAL_PARAM_INFO.ENABLE_SC_WF);
		--bug 7491598 DEFER OTM-PLANNED SHIPMENT INTERFACES ENHANCEMENT
		WSH_DEBUG_SV.log(l_module_name,'X_GLOBAL_PARAM_INFO.DEFER_PLAN_SHIPMENT_INTERFACE',X_GLOBAL_PARAM_INFO.DEFER_PLAN_SHIPMENT_INTERFACE);

  END IF;

    --
    -- Debug Statements
    --
	IF l_debug_on THEN
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--

END Get_Global_Parameters;

END WSH_SHIPPING_PARAMS_GRP;

/
