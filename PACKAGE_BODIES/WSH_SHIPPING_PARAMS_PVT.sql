--------------------------------------------------------
--  DDL for Package Body WSH_SHIPPING_PARAMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_SHIPPING_PARAMS_PVT" as
/* $Header: WSHSPRMB.pls 120.4.12010000.5 2009/12/03 10:55:22 mvudugul ship $ */

--
-- Package data types
--

TYPE Parameter_Rec_Tab_Typ IS TABLE OF Parameter_Rec_Typ INDEX BY BINARY_INTEGER;
TYPE Global_Parameters_rec_Tab_Typ IS TABLE OF Global_Parameters_Rec_Typ INDEX BY BINARY_INTEGER;
TYPE parameter_values_tbl IS TABLE OF parameter_value_rec_typ INDEX BY BINARY_INTEGER;

--
-- Package Variables
--

g_parameters  Parameter_Rec_Tab_Typ;
g_global_parameters Global_Parameters_rec_Tab_Typ;
g_parameter_values parameter_values_tbl;

C_ERROR_STATUS       CONSTANT VARCHAR2(1) := WSH_UTIL_CORE.G_RET_STS_ERROR;
C_WARNING_STATUS     CONSTANT VARCHAR2(1) := WSH_UTIL_CORE.G_RET_STS_WARNING;
C_SUCCESS_STATUS     CONSTANT VARCHAR2(1) := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
C_UNEXP_ERROR_STATUS CONSTANT VARCHAR2(1) := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

  --
  G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_SHIPPING_PARAMS_PVT';
  --

/* Local Procedure to write debug information */
Procedure print_debug_info(
   p_module_name      IN  VARCHAR2,
   p_print_info       IN  VARCHAR2,
   x_param_info       IN  parameter_rec_typ,
   x_param_value_info IN  parameter_value_rec_typ,
   x_return_status    OUT NOCOPY VARCHAR2);

/*+=======================================================================================
 API name        : Get
 Type            : Private.
 IN Parameters   : Organization_id
                   P_client_id : Client Id.
 OUT Parameters  : Shipping Parameter Record for individual Organization and client_id passed.
                   In addition it also tells if the organization is a process organization.

 Description     : This procedure caches the shipping Parameters in the Record Type
                   Collection for Reference.

+=======================================================================================*/

  PROCEDURE Get
  (p_organization_id  IN  NUMBER,
   p_client_id        IN NUMBER DEFAULT NULL, -- LSP PROJECT.
   x_param_info   OUT NOCOPY  Parameter_Rec_Typ,
   x_return_status  OUT NOCOPY  VARCHAR2) IS

-- HW OPMCONV - Retrieve CHECK_ON_HAND
  CURSOR c_get_param (v_organization_id NUMBER) IS
    SELECT
    SHIP_CONFIRM_RULE_ID,
    AUTOPACK_LEVEL,
    TASK_PLANNING_FLAG,
    EXPORT_SCREENING_FLAG,
    APPENDING_LIMIT,
    IGNORE_INBOUND_TRIP,
    PACK_SLIP_REQUIRED_FLAG,
    PICK_SEQUENCE_RULE_ID,
    PICK_GROUPING_RULE_ID,
    PRINT_PICK_SLIP_MODE,
    PICK_RELEASE_REPORT_SET_ID,
    AUTOCREATE_DEL_ORDERS_FLAG,
    DEFAULT_STAGE_SUBINVENTORY,
    DEFAULT_STAGE_LOCATOR_ID,
    AUTODETAIL_PR_FLAG,
    ENFORCE_PACKING_FLAG,
    GROUP_BY_CUSTOMER_FLAG,
    GROUP_BY_FOB_FLAG,
    GROUP_BY_FREIGHT_TERMS_FLAG,
    GROUP_BY_INTMED_SHIP_TO_FLAG,
    GROUP_BY_SHIP_METHOD_FLAG,
    GROUP_BY_CARRIER_FLAG,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    PROGRAM_UPDATE_DATE,
    REQUEST_ID,
    PICK_SLIP_LINES,
    AUTOCREATE_DELIVERIES_FLAG,
    FREIGHT_CLASS_CAT_SET_ID,
    COMMODITY_CODE_CAT_SET_ID,
    ENFORCE_SHIP_SET_AND_SMC,
    AUTO_SEND_DOC_FLAG,
    ITM_ADDITIONAL_COUNTRY_CODE,
    AUTO_SELECT_CARRIER,
    GOODS_DISPATCHED_ACCOUNT,
    LOCATION_ID,
    ORGANIZATION_ID,
    WEIGHT_UOM_CLASS,
    VOLUME_UOM_CLASS,
    WEIGHT_VOLUME_FLAG,
    INV_CONTROLS_CONTAINER_FLAG,
    PERCENT_FILL_BASIS_FLAG,
    TRIP_REPORT_SET_ID,
    DELIVERY_REPORT_SET_ID,
    AUTOCREATE_DEL_ORDERS_PR_FLAG,
    FPA_POSITIVE_TOL_AMT,
    FPA_NEGATIVE_TOL_AMT,
    FPA_POSITIVE_TOL_PERCENTAGE,
    FPA_NEGATIVE_TOL_PERCENTAGE,
    FPA_DEFAULT_FREIGHT_ACCOUNT,
    AUTO_APPLY_ROUTING_RULES,
    AUTO_CALC_FGT_RATE_CR_DEL,
    AUTO_CALC_FGT_RATE_APPEND_DEL,
    AUTO_CALC_FGT_RATE_SC_DEL,
    RAISE_BUSINESS_EVENTS,
    ENABLE_TRACKING_WFS,
    ENABLE_SC_WF,
    null PROCESS_FLAG,
-- HW OPMCON. get check_on_hand
    CHECK_ON_HAND,
    --OTM R12
    MAX_NET_WEIGHT,
    MAX_GROSS_WEIGHT,
    nvl(OTM_ENABLED,'N'),  --OTM R12 Org-Specific
    nvl(DYNAMIC_REPLENISHMENT_FLAG,'N'),  --bug# 6689448 (replenishment project)
    nvl(DOCK_APPT_SCHEDULING_FLAG,'N'), --bug 6700792: OTM Dock Door Sched Proj
    nvl(RETAIN_NONSTAGED_DET_FLAG,'N'), --Bug 7131800
    -- Bug 8446283 (Added wt/vol UOM codes on shipping parameters forms)
    WEIGHT_UOM_CODE,
    VOLUME_UOM_CODE
    -- Bug 8446283 : end
  FROM   WSH_SHIPPING_PARAMETERS
  WHERE  ORGANIZATION_ID = v_organization_id;

  l_found   BOOLEAN := FALSE;
  l_param_info    Parameter_Rec_Typ;
  i     NUMBER;
  l_client_params              inv_cache.ct_rec_type; -- LSP PROJECT

l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET';
--
l_msg_data  VARCHAR(2000);

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
      --
      WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_CLIENT_ID',P_CLIENT_ID); -- LSP PROJECT
  END IF;
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  -- Search table if it has any values

  IF g_parameters.count <> 0 THEN
  --{
      -- Check if parameters have already been fetched
      FOR i IN g_parameters.FIRST..g_parameters.LAST LOOP
      --{
          IF g_parameters(i).organization_id = p_organization_id THEN
              l_found := TRUE;
              x_param_info := g_parameters(i);
              EXIT;
          END IF;
      --}
      END LOOP;
  --}
  END IF;
  IF NOT l_found THEN
  --{
      -- Need to fetch and cache parameter info
      OPEN c_get_param(p_organization_id);
      FETCH c_get_param
      INTO  l_param_info;
      IF c_get_param%NOTFOUND THEN
      --{
         --Bug  3539616 : Error message shown when Shipping Parameters are not defined
         FND_MESSAGE.Set_Name('WSH', 'WSH_SHP_NOT_FOUND');
         FND_MESSAGE.Set_Token('ORG_NAME', wsh_util_core.get_org_name(p_organization_id));
  	     IF l_debug_on THEN
	         WSH_DEBUG_SV.log(l_module_name,'ERROR: ','Shipping Parameters not defined for Organization '||p_organization_id);
	     END IF;
	     RAISE NO_DATA_FOUND;
      --}
      END IF;
      --
      -- Debug Statements
      --
      -- HW OPMCONV - Removed call to check for process
      -- Insert into cached info into PL/SQL table
      IF g_parameters.count = 0 THEN
          g_parameters(1) := l_param_info;
      ELSE
          i := g_parameters.LAST + 1;
          g_parameters(i) := l_param_info;
      END IF;
      x_param_info := l_param_info;
  --}
  END IF;
  --
  --
  -- LSP PROJECT : Get Client related setup parameters and overrite the org parameters.
  IF (p_client_id IS NOT NULL AND WMS_DEPLOY.WMS_DEPLOYMENT_MODE = 'L' ) THEN
  --{ client validation
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'Calling INV_CACHE.GET_CLIENT_DEFAULT_PARAMETERS', WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      inv_cache.get_client_default_parameters (
          p_client_id             => p_client_id,
          x_client_parameters_rec => l_client_params,
          x_return_status         => x_return_status);
      IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name, 'Error occured in get_client_default_parameters => ' || x_return_status, WSH_DEBUG_SV.C_ERR_LEVEL);
          END IF;
          RAISE NO_DATA_FOUND;
      END IF;
      --
      x_param_info.ship_confirm_rule_id         := l_client_params.client_rec.ship_confirm_rule_id;
      x_param_info.autocreate_del_orders_flag   := l_client_params.client_rec.autocreate_del_orders_flag;
      x_param_info.group_by_customer_flag       := l_client_params.client_rec.group_by_customer_flag;
      x_param_info.group_by_fob_flag            := l_client_params.client_rec.group_by_fob_flag;
      x_param_info.group_by_freight_terms_flag  := l_client_params.client_rec.group_by_freight_terms_flag;
      x_param_info.group_by_intmed_ship_to_flag := 'N';
      x_param_info.group_by_ship_method_flag    := l_client_params.client_rec.group_by_ship_method_flag;
      x_param_info.group_by_carrier_flag        := 'N';
      x_param_info.otm_enabled                  := l_client_params.client_rec.otm_enabled;
      x_param_info.delivery_report_set_id       := l_client_params.client_rec.delivery_report_set_id;
  --}
  END IF;
  -- LSP PROJECT : end
  --
  -- Debug Statements
  IF l_debug_on THEN
      --
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.SHIP_CONFIRM_RULE_ID',X_PARAM_INFO.SHIP_CONFIRM_RULE_ID);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.AUTOPACK_LEVEL',X_PARAM_INFO.AUTOPACK_LEVEL);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.TASK_PLANNING_FLAG',X_PARAM_INFO.TASK_PLANNING_FLAG);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.EXPORT_SCREENING_FLAG',X_PARAM_INFO.EXPORT_SCREENING_FLAG);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.APPENDING_LIMIT',X_PARAM_INFO.APPENDING_LIMIT);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.IGNORE_INBOUND_TRIP',X_PARAM_INFO.IGNORE_INBOUND_TRIP);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.PACK_SLIP_REQUIRED_FLAG',X_PARAM_INFO.PACK_SLIP_REQUIRED_FLAG);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.PICK_SEQUENCE_RULE_ID',X_PARAM_INFO.PICK_SEQUENCE_RULE_ID);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.PICK_GROUPING_RULE_ID',X_PARAM_INFO.PICK_GROUPING_RULE_ID);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.PRINT_PICK_SLIP_MODE',X_PARAM_INFO.PRINT_PICK_SLIP_MODE);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.PICK_RELEASE_REPORT_SET_ID',X_PARAM_INFO.PICK_RELEASE_REPORT_SET_ID);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.AUTOCREATE_DEL_ORDERS_FLAG',X_PARAM_INFO.AUTOCREATE_DEL_ORDERS_FLAG);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.DEFAULT_STAGE_SUBINVENTORY',X_PARAM_INFO.DEFAULT_STAGE_SUBINVENTORY);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.DEFAULT_STAGE_LOCATOR_ID',X_PARAM_INFO.DEFAULT_STAGE_LOCATOR_ID);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.AUTODETAIL_PR_FLAG',X_PARAM_INFO.AUTODETAIL_PR_FLAG);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ENFORCE_PACKING_FLAG',X_PARAM_INFO.ENFORCE_PACKING_FLAG);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.GROUP_BY_CUSTOMER_FLAG',X_PARAM_INFO.GROUP_BY_CUSTOMER_FLAG);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.GROUP_BY_FOB_FLAG',X_PARAM_INFO.GROUP_BY_FOB_FLAG);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.GROUP_BY_FREIGHT_TERMS_FLAG',X_PARAM_INFO.GROUP_BY_FREIGHT_TERMS_FLAG);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.GROUP_BY_INTMED_SHIP_TO_FLAG',X_PARAM_INFO.GROUP_BY_INTMED_SHIP_TO_FLAG);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.GROUP_BY_SHIP_METHOD_FLAG',X_PARAM_INFO.GROUP_BY_SHIP_METHOD_FLAG);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.GROUP_BY_CARRIER_FLAG',X_PARAM_INFO.GROUP_BY_CARRIER_FLAG);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE_CATEGORY',X_PARAM_INFO.ATTRIBUTE_CATEGORY);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE1',X_PARAM_INFO.ATTRIBUTE1);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE2',X_PARAM_INFO.ATTRIBUTE2);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE3',X_PARAM_INFO.ATTRIBUTE3);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE4',X_PARAM_INFO.ATTRIBUTE4);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE5',X_PARAM_INFO.ATTRIBUTE5);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE6',X_PARAM_INFO.ATTRIBUTE6);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE7',X_PARAM_INFO.ATTRIBUTE7);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE8',X_PARAM_INFO.ATTRIBUTE8);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE9',X_PARAM_INFO.ATTRIBUTE9);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE10',X_PARAM_INFO.ATTRIBUTE10);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE11',X_PARAM_INFO.ATTRIBUTE11);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE12',X_PARAM_INFO.ATTRIBUTE12);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE13',X_PARAM_INFO.ATTRIBUTE13);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE14',X_PARAM_INFO.ATTRIBUTE14);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE15',X_PARAM_INFO.ATTRIBUTE15);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.CREATION_DATE',X_PARAM_INFO.CREATION_DATE);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.CREATED_BY',X_PARAM_INFO.CREATED_BY);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.LAST_UPDATE_DATE',X_PARAM_INFO.LAST_UPDATE_DATE);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.LAST_UPDATED_BY',X_PARAM_INFO.LAST_UPDATED_BY);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.LAST_UPDATE_LOGIN',X_PARAM_INFO.LAST_UPDATE_LOGIN);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.PROGRAM_APPLICATION_ID',X_PARAM_INFO.PROGRAM_APPLICATION_ID);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.PROGRAM_ID',X_PARAM_INFO.PROGRAM_ID);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.PROGRAM_UPDATE_DATE',X_PARAM_INFO.PROGRAM_UPDATE_DATE);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.REQUEST_ID',X_PARAM_INFO.REQUEST_ID);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.PICK_SLIP_LINES',X_PARAM_INFO.PICK_SLIP_LINES);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.AUTOCREATE_DELIVERIES_FLAG',X_PARAM_INFO.AUTOCREATE_DELIVERIES_FLAG);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.FREIGHT_CLASS_CAT_SET_ID',X_PARAM_INFO.FREIGHT_CLASS_CAT_SET_ID);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.COMMODITY_CODE_CAT_SET_ID',X_PARAM_INFO.COMMODITY_CODE_CAT_SET_ID);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ENFORCE_SHIP_SET_AND_SMC',X_PARAM_INFO.ENFORCE_SHIP_SET_AND_SMC);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.AUTO_SEND_DOC_FLAG',X_PARAM_INFO.AUTO_SEND_DOC_FLAG);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ITM_ADDITIONAL_COUNTRY_CODE',X_PARAM_INFO.ITM_ADDITIONAL_COUNTRY_CODE);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.AUTO_SELECT_CARRIER',X_PARAM_INFO.AUTO_SELECT_CARRIER);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.GOODS_DISPATCHED_ACCOUNT',X_PARAM_INFO.GOODS_DISPATCHED_ACCOUNT);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.LOCATION_ID',X_PARAM_INFO.LOCATION_ID);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ORGANIZATION_ID',X_PARAM_INFO.ORGANIZATION_ID);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.WEIGHT_UOM_CLASS',X_PARAM_INFO.WEIGHT_UOM_CLASS);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.VOLUME_UOM_CLASS',X_PARAM_INFO.VOLUME_UOM_CLASS);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.WEIGHT_VOLUME_FLAG',X_PARAM_INFO.WEIGHT_VOLUME_FLAG);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.INV_CONTROLS_CONTAINER_FLAG',X_PARAM_INFO.INV_CONTROLS_CONTAINER_FLAG);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.PERCENT_FILL_BASIS_FLAG',X_PARAM_INFO.PERCENT_FILL_BASIS_FLAG);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.TRIP_REPORT_SET_ID',X_PARAM_INFO.TRIP_REPORT_SET_ID);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.DELIVERY_REPORT_SET_ID',X_PARAM_INFO.DELIVERY_REPORT_SET_ID);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.AUTOCREATE_DEL_ORDERS_PR_FLAG',X_PARAM_INFO.AUTOCREATE_DEL_ORDERS_PR_FLAG);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.FPA_POSITIVE_TOL_AMT',X_PARAM_INFO.FPA_POSITIVE_TOL_AMT);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.FPA_NEGATIVE_TOL_AMT',X_PARAM_INFO.FPA_NEGATIVE_TOL_AMT);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.FPA_POSITIVE_TOL_PERCENTAGE',X_PARAM_INFO.FPA_POSITIVE_TOL_PERCENTAGE);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.FPA_NEGATIVE_TOL_PERCENTAGE',X_PARAM_INFO.FPA_NEGATIVE_TOL_PERCENTAGE);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.FPA_DEFAULT_FREIGHT_ACCOUNT',X_PARAM_INFO.FPA_DEFAULT_FREIGHT_ACCOUNT);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.AUTO_APPLY_ROUTING_RULES',X_PARAM_INFO.AUTO_APPLY_ROUTING_RULES);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.AUTO_CALC_FGT_RATE_CR_DEL',X_PARAM_INFO.AUTO_CALC_FGT_RATE_CR_DEL);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.AUTO_CALC_FGT_RATE_APPEND_DEL',X_PARAM_INFO.AUTO_CALC_FGT_RATE_APPEND_DEL);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.AUTO_CALC_FGT_RATE_SC_DEL',X_PARAM_INFO.AUTO_CALC_FGT_RATE_SC_DEL);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.RAISE_BUSINESS_EVENTS',X_PARAM_INFO.RAISE_BUSINESS_EVENTS);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ENABLE_TRACKING_WFS',X_PARAM_INFO.ENABLE_TRACKING_WFS);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ENABLE_SC_WF',X_PARAM_INFO.ENABLE_SC_WF);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.PROCESS_FLAG',X_PARAM_INFO.PROCESS_FLAG);
-- HW OPMCONV - Print value of CHECK_ON_HAND
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.CHECK_ON_HAND',X_PARAM_INFO.CHECK_ON_HAND);
           --OTM R12
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.MAX_NET_WEIGHT',X_PARAM_INFO.MAX_NET_WEIGHT);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.MAX_GROSS_WEIGHT',X_PARAM_INFO.MAX_GROSS_WEIGHT);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.OTM_ENABLED',X_PARAM_INFO.OTM_ENABLED);      --OTM R12 Org-Specific
           --
	   WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.DYNAMIC_REPLENISHMENT_FLAG',X_PARAM_INFO.DYNAMIC_REPLENISHMENT_FLAG); --bug# 6689448 (replenishment project)
	   WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.DOCK_APPT_SCHEDULING_FLAG',X_PARAM_INFO.DOCK_APPT_SCHEDULING_FLAG); --bug 6700792: OTM Dock Door Appt Sched Proj
--Bug 7131800
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.RETAIN_NONSTAGED_DET_FLAG',X_PARAM_INFO.RETAIN_NONSTAGED_DET_FLAG);
--Bug 7131800
           -- Bug 8446283
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.WEIGHT_UOM_CODE',X_PARAM_INFO.WEIGHT_UOM_CODE);
           WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.VOLUME_UOM_CODE',X_PARAM_INFO.VOLUME_UOM_CODE);
           -- Bug 8446283
   END IF;



--
-- Debug Statements
--
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
--
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF c_get_param%ISOPEN THEN
        CLOSE c_get_param;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'NO_DATA_FOUND exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NO_DATA_FOUND');
      END IF;
      --
    WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('WSH','WSH_UNEXP_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','WSH_SHIPPING_PARAMS_PVT');
      FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
      FND_MESSAGE.Set_Token('ORA_TEXT','');
      IF c_get_param%ISOPEN THEN
        CLOSE c_get_param;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
  END Get;


/*======================================================================================+
 API name        : Get_Global_Parameters
 Type            : Private.
 IN Parameters   : None.
 OUT Parameters  : record for global parameters.
 Description     : This procedure caches the global Parameters in the Record Type
                   Collection for Reference.
+=======================================================================================*/

Procedure Get_Global_Parameters(
x_Param_Info OUT NOCOPY Global_Parameters_Rec_Typ,
x_return_status OUT NOCOPY VARCHAR2) IS

  CURSOR c_get_global_param IS
    SELECT
	AUTO_RATE_TP_REL_TRIPS,
	TL_PRIN_COST_ALLOC_BASIS,
	TL_DISTANCE_ALLOC_BASIS,
	TL_STOP_COST_ALLOC_BASIS,
	AUTOFIRM_LOAD_TENDERED_TRIPS,
	CONSOLIDATE_BO_LINES,
	GU_WEIGHT_CLASS,
	GU_WEIGHT_UOM,
	GU_VOLUME_UOM,
	GU_VOLUME_CLASS,
	GU_DISTANCE_CLASS,
	GU_DISTANCE_UOM,
	GU_DIMENSION_CLASS,
	GU_DIMENSION_UOM,
	GU_CURRENCY_COUNTRY,
	GU_CURRENCY_UOM,
	GU_TIME_CLASS,
	GU_TIME_UOM,
	DEF_MILE_CALC_ON_CUST_FAC,
	DEF_MILE_CALC_ON_SUPP_FAC,
	DEF_MILE_CALC_ON_ORG_FAC,
	DEF_MILE_CALC_ON_CARR_FAC,
	TL_HWAY_DIS_EMP_CONSTANT,
	AVG_HWAY_SPEED,
	DISTANCE_UOM,
	TIME_UOM,
        UOM_FOR_NUM_OF_UNITS,
        PALLET_ITEM_TYPE,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
    	ATTRIBUTE9,
    	ATTRIBUTE10,
    	ATTRIBUTE11,
    	ATTRIBUTE12,
   	ATTRIBUTE13,
   	ATTRIBUTE14,
   	ATTRIBUTE15,
   	CREATION_DATE,
   	CREATED_BY,
   	LAST_UPDATE_DATE,
   	LAST_UPDATED_BY,
   	LAST_UPDATE_LOGIN,
   	DEFER_INTERFACE,
   	ENFORCE_SHIP_METHOD,
   	ALLOW_FUTURE_SHIP_DATE,
        RATE_IB_DELS_FGT_TERM,
        SKIP_RATE_OB_DELS_FGT_TERM,
        DEL_DATE_CALC_METHOD,
        RATE_DS_DELS_FGT_TERM_ID,
        RAISE_BUSINESS_EVENTS,
        ENABLE_TRACKING_WFS,
        ENABLE_SC_WF,
        EXPAND_CARRIER_RANKINGS,
	DEFER_PLAN_SHIPMENT_INTERFACE --bug 7491598
  FROM   WSH_GLOBAL_PARAMETERS;

  l_found   BOOLEAN := FALSE;
  l_param_info    Global_Parameters_Rec_Typ;
  i     NUMBER;

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

  -- Search table if it has global parameters already populated.

  IF g_global_parameters.count <> 0 THEN

    x_param_info := g_global_parameters(1);
        --
        -- Debug Statements
        IF l_debug_on THEN
        --
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.AUTO_RATE_TP_REL_TRIPS',X_PARAM_INFO.AUTO_RATE_TP_REL_TRIPS);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.TL_PRIN_COST_ALLOC_BASIS',X_PARAM_INFO.TL_PRIN_COST_ALLOC_BASIS);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.TL_DISTANCE_ALLOC_BASIS',X_PARAM_INFO.TL_DISTANCE_ALLOC_BASIS);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.TL_STOP_COST_ALLOC_BASIS',X_PARAM_INFO.TL_STOP_COST_ALLOC_BASIS);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.AUTOFIRM_LOAD_TENDERED_TRIPS',X_PARAM_INFO.AUTOFIRM_LOAD_TENDERED_TRIPS);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.CONSOLIDATE_BO_LINES',X_PARAM_INFO.CONSOLIDATE_BO_LINES);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.GU_WEIGHT_CLASS',X_PARAM_INFO.GU_WEIGHT_CLASS);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.GU_WEIGHT_UOM',X_PARAM_INFO.GU_WEIGHT_UOM);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.GU_VOLUME_UOM',X_PARAM_INFO.GU_VOLUME_UOM);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.GU_VOLUME_CLASS',X_PARAM_INFO.GU_VOLUME_CLASS);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.GU_DISTANCE_CLASS',X_PARAM_INFO.GU_DISTANCE_CLASS);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.GU_DISTANCE_UOM',X_PARAM_INFO.GU_DISTANCE_UOM);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.GU_DIMENSION_CLASS',X_PARAM_INFO.GU_DIMENSION_CLASS);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.GU_DIMENSION_UOM',X_PARAM_INFO.GU_DIMENSION_UOM);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.GU_CURRENCY_COUNTRY',X_PARAM_INFO.GU_CURRENCY_COUNTRY);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.GU_CURRENCY_UOM',X_PARAM_INFO.GU_CURRENCY_UOM);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.GU_TIME_CLASS',X_PARAM_INFO.GU_TIME_CLASS);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.GU_TIME_UOM',X_PARAM_INFO.GU_TIME_UOM);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.DEF_MILE_CALC_ON_CUST_FAC',X_PARAM_INFO.DEF_MILE_CALC_ON_CUST_FAC);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.DEF_MILE_CALC_ON_SUPP_FAC',X_PARAM_INFO.DEF_MILE_CALC_ON_SUPP_FAC);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.DEF_MILE_CALC_ON_ORG_FAC',X_PARAM_INFO.DEF_MILE_CALC_ON_ORG_FAC);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.DEF_MILE_CALC_ON_CARR_FAC',X_PARAM_INFO.DEF_MILE_CALC_ON_CARR_FAC);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.TL_HWAY_DIS_EMP_CONSTANT',X_PARAM_INFO.TL_HWAY_DIS_EMP_CONSTANT);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.AVG_HWAY_SPEED',X_PARAM_INFO.AVG_HWAY_SPEED);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.DISTANCE_UOM',X_PARAM_INFO.DISTANCE_UOM);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.TIME_UOM',X_PARAM_INFO.TIME_UOM);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.UOM_FOR_NUM_OF_UNITS',X_PARAM_INFO.UOM_FOR_NUM_OF_UNITS);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.PALLET_ITEM_TYPE',X_PARAM_INFO.PALLET_ITEM_TYPE);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE_CATEGORY',X_PARAM_INFO.ATTRIBUTE_CATEGORY);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE1',X_PARAM_INFO.ATTRIBUTE1);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE2',X_PARAM_INFO.ATTRIBUTE2);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE3',X_PARAM_INFO.ATTRIBUTE3);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE4',X_PARAM_INFO.ATTRIBUTE4);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE5',X_PARAM_INFO.ATTRIBUTE5);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE6',X_PARAM_INFO.ATTRIBUTE6);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE7',X_PARAM_INFO.ATTRIBUTE7);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE8',X_PARAM_INFO.ATTRIBUTE8);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE9',X_PARAM_INFO.ATTRIBUTE9);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE10',X_PARAM_INFO.ATTRIBUTE10);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE11',X_PARAM_INFO.ATTRIBUTE11);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE12',X_PARAM_INFO.ATTRIBUTE12);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE13',X_PARAM_INFO.ATTRIBUTE13);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE14',X_PARAM_INFO.ATTRIBUTE14);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE15',X_PARAM_INFO.ATTRIBUTE15);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.CREATION_DATE',X_PARAM_INFO.CREATION_DATE);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.CREATED_BY',X_PARAM_INFO.CREATED_BY);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.LAST_UPDATE_DATE',X_PARAM_INFO.LAST_UPDATE_DATE);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.LAST_UPDATED_BY',X_PARAM_INFO.LAST_UPDATED_BY);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.LAST_UPDATE_LOGIN',X_PARAM_INFO.LAST_UPDATE_LOGIN);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ENFORCE_SHIP_METHOD',X_PARAM_INFO.ENFORCE_SHIP_METHOD);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ALLOW_FUTURE_SHIP_DATE',X_PARAM_INFO.ALLOW_FUTURE_SHIP_DATE);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.DEFER_INTERFACE',X_PARAM_INFO.DEFER_INTERFACE);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.RATE_IB_DELS_FGT_TERM',X_PARAM_INFO.RATE_IB_DELS_FGT_TERM);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.SKIP_RATE_OB_DELS_FGT_TERM',X_PARAM_INFO.SKIP_RATE_OB_DELS_FGT_TERM);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.DEL_DATE_CALC_METHOD',X_PARAM_INFO.DEL_DATE_CALC_METHOD);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.RATE_DS_DELS_FGT_TERM_ID',X_PARAM_INFO.RATE_DS_DELS_FGT_TERM_ID);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.RAISE_BUSINESS_EVENTS',X_PARAM_INFO.RAISE_BUSINESS_EVENTS);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ENABLE_TRACKING_WFS',X_PARAM_INFO.ENABLE_TRACKING_WFS);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ENABLE_SC_WF',X_PARAM_INFO.ENABLE_SC_WF);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.EXPAND_CARRIER_RANKINGS',X_PARAM_INFO.EXPAND_CARRIER_RANKINGS);
	  --bug 7491598 DEFER OTM-PLANNED SHIPMENT INTERFACES ENHANCEMENT
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.DEFER_PLAN_SHIPMENT_INTERFACE',X_PARAM_INFO.DEFER_PLAN_SHIPMENT_INTERFACE);
        END IF;
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        RETURN;

    END IF;

    -- Need to fetch and cache global parameter info
    OPEN c_get_global_param;
    FETCH c_get_global_param
    INTO  l_param_info;
    IF c_get_global_param%NOTFOUND THEN
      FND_MESSAGE.Set_Name('WSH','WSH_PARAM_NOT_DEFINED');
      RAISE NO_DATA_FOUND;
    END IF;

    -- Insert cached info into PL/SQL table

    IF g_global_parameters.count = 0 THEN
      g_global_parameters(1) := l_param_info;
    ELSE
      i := g_global_parameters.LAST + 1;
      g_global_parameters(i) := l_param_info;
    END IF;

    x_param_info := l_param_info;

    -- Debug Statements

    IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.AUTO_RATE_TP_REL_TRIPS',X_PARAM_INFO.AUTO_RATE_TP_REL_TRIPS);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.TL_PRIN_COST_ALLOC_BASIS',X_PARAM_INFO.TL_PRIN_COST_ALLOC_BASIS);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.TL_DISTANCE_ALLOC_BASIS',X_PARAM_INFO.TL_DISTANCE_ALLOC_BASIS);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.TL_STOP_COST_ALLOC_BASIS',X_PARAM_INFO.TL_STOP_COST_ALLOC_BASIS);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.AUTOFIRM_LOAD_TENDERED_TRIPS',X_PARAM_INFO.AUTOFIRM_LOAD_TENDERED_TRIPS);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.CONSOLIDATE_BO_LINES',X_PARAM_INFO.CONSOLIDATE_BO_LINES);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.GU_WEIGHT_CLASS',X_PARAM_INFO.GU_WEIGHT_CLASS);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.GU_WEIGHT_UOM',X_PARAM_INFO.GU_WEIGHT_UOM);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.GU_VOLUME_UOM',X_PARAM_INFO.GU_VOLUME_UOM);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.GU_VOLUME_CLASS',X_PARAM_INFO.GU_VOLUME_CLASS);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.GU_DISTANCE_CLASS',X_PARAM_INFO.GU_DISTANCE_CLASS);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.GU_DISTANCE_UOM',X_PARAM_INFO.GU_DISTANCE_UOM);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.GU_DIMENSION_CLASS',X_PARAM_INFO.GU_DIMENSION_CLASS);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.GU_DIMENSION_UOM',X_PARAM_INFO.GU_DIMENSION_UOM);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.GU_CURRENCY_COUNTRY',X_PARAM_INFO.GU_CURRENCY_COUNTRY);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.GU_CURRENCY_UOM',X_PARAM_INFO.GU_CURRENCY_UOM);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.GU_TIME_CLASS',X_PARAM_INFO.GU_TIME_CLASS);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.GU_TIME_UOM',X_PARAM_INFO.GU_TIME_UOM);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.DEF_MILE_CALC_ON_CUST_FAC',X_PARAM_INFO.DEF_MILE_CALC_ON_CUST_FAC);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.DEF_MILE_CALC_ON_SUPP_FAC',X_PARAM_INFO.DEF_MILE_CALC_ON_SUPP_FAC);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.DEF_MILE_CALC_ON_ORG_FAC',X_PARAM_INFO.DEF_MILE_CALC_ON_ORG_FAC);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.DEF_MILE_CALC_ON_CARR_FAC',X_PARAM_INFO.DEF_MILE_CALC_ON_CARR_FAC);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.TL_HWAY_DIS_EMP_CONSTANT',X_PARAM_INFO.TL_HWAY_DIS_EMP_CONSTANT);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.AVG_HWAY_SPEED',X_PARAM_INFO.AVG_HWAY_SPEED);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.DISTANCE_UOM',X_PARAM_INFO.DISTANCE_UOM);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.TIME_UOM',X_PARAM_INFO.TIME_UOM);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.UOM_FOR_NUM_OF_UNITS',X_PARAM_INFO.UOM_FOR_NUM_OF_UNITS);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.PALLET_ITEM_TYPE',X_PARAM_INFO.PALLET_ITEM_TYPE);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE_CATEGORY',X_PARAM_INFO.ATTRIBUTE_CATEGORY);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE1',X_PARAM_INFO.ATTRIBUTE1);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE2',X_PARAM_INFO.ATTRIBUTE2);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE3',X_PARAM_INFO.ATTRIBUTE3);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE4',X_PARAM_INFO.ATTRIBUTE4);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE5',X_PARAM_INFO.ATTRIBUTE5);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE6',X_PARAM_INFO.ATTRIBUTE6);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE7',X_PARAM_INFO.ATTRIBUTE7);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE8',X_PARAM_INFO.ATTRIBUTE8);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE9',X_PARAM_INFO.ATTRIBUTE9);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE10',X_PARAM_INFO.ATTRIBUTE10);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE11',X_PARAM_INFO.ATTRIBUTE11);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE12',X_PARAM_INFO.ATTRIBUTE12);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE13',X_PARAM_INFO.ATTRIBUTE13);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE14',X_PARAM_INFO.ATTRIBUTE14);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ATTRIBUTE15',X_PARAM_INFO.ATTRIBUTE15);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.CREATION_DATE',X_PARAM_INFO.CREATION_DATE);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.CREATED_BY',X_PARAM_INFO.CREATED_BY);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.LAST_UPDATE_DATE',X_PARAM_INFO.LAST_UPDATE_DATE);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.LAST_UPDATED_BY',X_PARAM_INFO.LAST_UPDATED_BY);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.LAST_UPDATE_LOGIN',X_PARAM_INFO.LAST_UPDATE_LOGIN);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ENFORCE_SHIP_METHOD',X_PARAM_INFO.ENFORCE_SHIP_METHOD);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ALLOW_FUTURE_SHIP_DATE',X_PARAM_INFO.ALLOW_FUTURE_SHIP_DATE);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.DEFER_INTERFACE',X_PARAM_INFO.DEFER_INTERFACE);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.RATE_IB_DELS_FGT_TERM',X_PARAM_INFO.RATE_IB_DELS_FGT_TERM);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.SKIP_RATE_OB_DELS_FGT_TERM',X_PARAM_INFO.SKIP_RATE_OB_DELS_FGT_TERM);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.DEL_DATE_CALC_METHOD',X_PARAM_INFO.DEL_DATE_CALC_METHOD);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.RATE_DS_DELS_FGT_TERM_ID',X_PARAM_INFO.RATE_DS_DELS_FGT_TERM_ID);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.RAISE_BUSINESS_EVENTS',X_PARAM_INFO.RAISE_BUSINESS_EVENTS);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ENABLE_TRACKING_WFS',X_PARAM_INFO.ENABLE_TRACKING_WFS);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.ENABLE_SC_WF',X_PARAM_INFO.ENABLE_SC_WF);
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.EXPAND_CARRIER_RANKINGS',X_PARAM_INFO.EXPAND_CARRIER_RANKINGS);
	  --bug 7491598 DEFER OTM-PLANNED SHIPMENT INTERFACES ENHANCEMENT
          WSH_DEBUG_SV.log(l_module_name,'X_PARAM_INFO.DEFER_PLAN_SHIPMENT_INTERFACE',X_PARAM_INFO.DEFER_PLAN_SHIPMENT_INTERFACE);
    END IF;
--
-- Debug Statements
--
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
--
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF c_get_global_param%ISOPEN THEN
        CLOSE c_get_global_param;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'NO_DATA_FOUND exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NO_DATA_FOUND');
      END IF;
      --
    WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('WSH','WSH_UNEXP_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','WSH_SHIPPING_PARAMS_PVT');
      FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
      FND_MESSAGE.Set_Token('ORA_TEXT','');
      IF c_get_global_param%ISOPEN THEN
        CLOSE c_get_global_param;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '
                        || SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Get_Global_Parameters;


Procedure Get( x_param_value_info IN OUT NOCOPY  parameter_value_rec_typ,
               x_return_status  OUT NOCOPY  VARCHAR2) is

 cursor get_paramter_values_csr(p_organization_id in number) is
 select class_code
      , param_name
      , decode(class_code
        ,'ROUTING_RULES',nvl(param_value, 'N'),param_value) param_value
      , param_data_type
   from wsh_shipping_parameter_values
  where organization_id = p_organization_id ;

 type l_varchar2_tbl is table of wsh_shipping_parameter_values.param_value%TYPE index by binary_integer;
 l_param_value         l_varchar2_tbl;
 l_parameter_name      wsh_util_core.column_tab_type;
 l_param_value_info    parameter_value_rec_typ;
 temp_param_value_info parameter_value_rec_typ;
 l_selective boolean;
 l_row_count number;
 l_found     boolean ;
 l_debug_on  boolean;
 x_row_count number;
 l_return_status varchar2(10);
 l_module_name   constant varchar(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET ';


Begin
 x_return_status := wsh_util_core.g_ret_sts_success;

 If x_param_value_info.param_name.count > 0 then
    l_selective := TRUE;
    l_parameter_name := x_param_value_info.param_name;
 Else
    l_selective := FALSE;
 End If;

 l_param_value_info.organization_id := x_param_value_info.organization_id ;
 temp_param_value_info := x_param_value_info;
 x_param_value_info.class_code.delete;
 x_param_value_info.param_name.delete;
 x_param_value_info.param_data_type.delete;
 x_param_value_info.param_value_num.delete;
 x_param_value_info.param_value_chr.delete;
 x_param_value_info.param_value_date.delete;

  If g_parameter_values.count > 0 then
     <<OUTER>>
     For i in g_parameter_values.FIRST..g_parameter_values.LAST
     Loop
        If g_parameter_values(i).organization_id = temp_param_value_info.organization_id and l_selective then
           l_found := TRUE;
           If temp_param_value_info.param_name.count > 0 then
           For j in temp_param_value_info.param_name.first.. temp_param_value_info.param_name.last
           Loop
              If g_parameter_values(i).param_name.count > 0 then
              For k in g_parameter_values(i).param_name.first.. g_parameter_values(i).param_name.last
              Loop
                 If g_parameter_values(i).param_name(k) = temp_param_value_info.param_name(j) then
                     x_row_count := nvl(x_row_count,0) + 1;
                     x_param_value_info.class_code(x_row_count) := g_parameter_values(i).class_code(k);
                     x_param_value_info.param_name(x_row_count) := g_parameter_values(i).param_name(k);
                     x_param_value_info.param_data_type(x_row_count) := g_parameter_values(i).param_data_type(k);
                     x_param_value_info.param_value_chr(x_row_count) := g_parameter_values(i).param_value_chr(k);
                     x_param_value_info.param_value_num(x_row_count) := g_parameter_values(i).param_value_num(k);
                     x_param_value_info.param_value_date(x_row_count) := g_parameter_values(i).param_value_date(k);
                 End If;
              End Loop;
              End If;
           End Loop;
           End If;
           If l_found = TRUE then
                 exit OUTER;
           End If;
        Elsif g_parameter_values(i).organization_id = x_param_value_info.organization_id and not l_selective then
           x_param_value_info := g_parameter_values(i);
           l_found := TRUE;
           exit OUTER;
        End If;
     End Loop;

     If l_found  and l_debug_on then
        print_debug_info(l_module_name
                        ,'WSH_SHIPPING_PARAMETER_VALUES'
                        ,null
                        ,x_param_value_info
                        ,l_return_status);
        WSH_DEBUG_SV.pop(l_module_name);
     End If;
     If l_found then
        return;
     End If;
  End If;

 Open get_paramter_values_csr(x_param_value_info.organization_id);
 Fetch get_paramter_values_csr bulk collect into
       l_param_value_info.class_code
      ,l_param_value_info.param_name
      ,l_param_value
      ,l_param_value_info.param_data_type;
 Close get_paramter_values_csr;

 If l_param_value_info.param_name.COUNT > 0 then
   For i in l_param_value_info.param_name.FIRST..l_param_value_info.param_name.LAST
     Loop
        If  l_param_value_info.param_data_type(i) = 'VARCHAR2' then
            l_param_value_info.param_value_num(i) := NULL;
            l_param_value_info.param_value_chr(i) := l_param_value(i);
            l_param_value_info.param_value_date(i):= NULL;
        Elsif  l_param_value_info.param_data_type(i) = 'DATE' then
            l_param_value_info.param_value_num(i) := NULL;
            l_param_value_info.param_value_chr(i) := NULL;
            l_param_value_info.param_value_date(i):= fnd_date.canonical_to_date(l_param_value(i));
        Elsif  l_param_value_info.param_data_type(i) = 'NUMBER' then
            l_param_value_info.param_value_num(i) := fnd_number.canonical_to_number(l_param_value(i));
            l_param_value_info.param_value_chr(i) := NULL;
            l_param_value_info.param_value_date(i):= NULL;
        End If;
     End Loop;
 End if;

 If l_selective then
  l_row_count := 0;
  For i in l_parameter_name.FIRST..l_parameter_name.LAST
  Loop
    If l_param_value_info.param_name.count > 0 then
      For j in l_param_value_info.param_name.FIRST..l_param_value_info.param_name.LAST
      Loop
        If l_parameter_name(i) = l_param_value_info.param_name(j) then
           l_row_count := l_row_count+1;
           x_param_value_info.class_code(l_row_count)      := l_param_value_info.class_code(j);
           x_param_value_info.param_name(l_row_count)      := l_param_value_info.param_name(j);
           x_param_value_info.param_data_type(l_row_count) := l_param_value_info.param_data_type(j);
           x_param_value_info.param_value_num(l_row_count) := l_param_value_info.param_value_num(j);
           x_param_value_info.param_value_chr(l_row_count) := l_param_value_info.param_value_chr(j);
           x_param_value_info.param_value_date(l_row_count):= l_param_value_info.param_value_date(j);
        End If;
      End Loop;
    End If;
  End Loop;
 Else
   x_param_value_info := l_param_value_info;
 End If;

 g_parameter_values(nvl(g_parameter_values.count,0)+1) := l_param_value_info;

 If l_debug_on then
    wsh_debug_sv.pop(l_module_name);
 End If;

 Exception
   When others then
      x_return_status := wsh_util_core.g_ret_sts_error;
      fnd_message.set_name('WSH','WSH_UNEXP_ERROR');
      fnd_message.set_token('PACKAGE',l_module_name);
      fnd_message.set_token('ORA_ERROR',to_char(sqlcode));
      fnd_message.set_token('ORA_TEXT',SQLERRM);
      If l_debug_on then
         wsh_debug_sv.log(l_module_name,'SQLERRM : ',sqlerrm);
         wsh_debug_sv.log(l_module_name,'x_return_status = : ',x_return_status);
         wsh_debug_sv.pop(l_module_name);
      End If;

End Get;


Procedure insert_parameter_values (p_ins_ship_par_val_rec parameter_value_rec_typ ) is
 l_user_id        number:= fnd_global.user_id;
 l_login_id       number:= fnd_global.login_id;
Begin
    forall i in p_ins_ship_par_val_rec.class_code.first..p_ins_ship_par_val_rec.class_code.last
    insert into wsh_shipping_parameter_values(
                organization_id,
                class_code,
                param_name,
                param_value,
                param_data_type,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                last_update_login)
         values (p_ins_ship_par_val_rec.organization_id
                ,p_ins_ship_par_val_rec.class_code(i)
                ,p_ins_ship_par_val_rec.param_name(i)
                ,p_ins_ship_par_val_rec.param_value_chr(i)
                ,p_ins_ship_par_val_rec.param_data_type(i)
                ,sysdate
                ,l_user_id
                ,sysdate
                ,l_user_id
                ,l_login_id);
End insert_parameter_values;


Procedure create_parameter(
  p_ship_par_rec     IN parameter_rec_typ,
  p_ship_par_val_rec IN parameter_value_rec_typ,
  x_return_status    OUT NOCOPY VARCHAR2) is

  type l_parameter_value_type is table of wsh_shipping_parameter_values.PARAM_VALUE%TYPE index by binary_integer;
  type l_parameter_name_type is table of wsh_shipping_parameter_values.PARAM_NAME%TYPE index by binary_integer;

  l_freight_terms_value l_parameter_value_type;
  l_param_name          l_parameter_name_type;
  l_param_value_tbl     l_parameter_value_type;

  l_ship_par_val_rec    parameter_value_rec_typ;
  l_freight_terms_rec   parameter_value_rec_typ;

  l_user_id        number:= fnd_global.user_id;
  l_login_id       number:= fnd_global.login_id;
  l_debug_on       boolean;
  l_module_name    constant varchar(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_PARAMETER';
  l_return_status  varchar2(1);
  l_org_name       varchar2(2000) := wsh_util_core.get_org_name(p_ship_par_rec.organization_id);
  handle_exception exception;
  l_freight_count  number;
  l_param_count    number ;
  l_sqlerrm        varchar2(2000);

Begin
 x_return_status := wsh_util_core.g_ret_sts_success;
 l_debug_on := wsh_debug_interface.g_debug;
 If l_debug_on is null then
    l_debug_on := wsh_debug_sv.is_debug_enabled;
 End If;
 If l_debug_on then
    wsh_debug_sv.push(l_module_name);
    print_debug_info(l_module_name
                    ,'ALL'
                    ,p_ship_par_rec
                    ,p_ship_par_val_rec
                    ,l_return_status);
 End If;

 Begin
 --bug# 6689448 (replenishment project): added the field dynamic_replenishment_flag
 Insert into wsh_shipping_parameters (
            goods_dispatched_account,
            location_id,
            organization_id,
            weight_uom_class,
            volume_uom_class,
            weight_volume_flag,
            inv_controls_container_flag,
            percent_fill_basis_flag,
            trip_report_set_id,
            delivery_report_set_id,
            pack_slip_required_flag,
            pick_sequence_rule_id,
            pick_grouping_rule_id,
            print_pick_slip_mode,
            pick_release_report_set_id,
            autocreate_del_orders_flag,
            default_stage_subinventory,
            default_stage_locator_id,
            autodetail_pr_flag,
            enforce_packing_flag,
            group_by_customer_flag,
            group_by_fob_flag,
            group_by_freight_terms_flag,
            group_by_intmed_ship_to_flag,
            group_by_ship_method_flag,
            group_by_carrier_flag,
            attribute_category,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            pick_slip_lines,
            autocreate_deliveries_flag,
            freight_class_cat_set_id,
            commodity_code_cat_set_id,
            enforce_ship_set_and_smc,
            auto_send_doc_flag,
            itm_additional_country_code,
            auto_select_carrier,
            ship_confirm_rule_id,
            autopack_level,
            task_planning_flag,
            appending_limit,
            export_screening_flag,
            autocreate_del_orders_pr_flag,
            fpa_positive_tol_amt,
            fpa_negative_tol_amt,
            fpa_positive_tol_percentage,
            fpa_negative_tol_percentage,
            fpa_default_freight_account,
            auto_apply_routing_rules,
            auto_calc_fgt_rate_cr_del,
            auto_calc_fgt_rate_append_del,
            auto_calc_fgt_rate_sc_del,
            raise_business_events,
            enable_tracking_wfs,
            enable_sc_wf,
            check_on_hand,
            --OTM R12
            max_net_weight,
            max_gross_weight,
            --OTM R12 Org-Specific
            otm_enabled,
            dynamic_replenishment_flag,
	    -- OTM Dock Door Appt Sched Proj
            dock_appt_scheduling_flag,
            retain_nonstaged_det_flag, --Bug 7131800
            -- Bug 8446283 (Added wt/vol UOM codes on shipping parameters forms)
            weight_uom_code,
            volume_uom_code
            -- Bug 8446283 : end
            )
    Values ( p_ship_par_rec.goods_dispatched_account,
             p_ship_par_rec.location_id,
             p_ship_par_rec.organization_id,
             p_ship_par_rec.weight_uom_class,
             p_ship_par_rec.volume_uom_class,
             p_ship_par_rec.weight_volume_flag,
             p_ship_par_rec.inv_controls_container_flag,
             p_ship_par_rec.percent_fill_basis_flag,
             p_ship_par_rec.trip_report_set_id,
             p_ship_par_rec.delivery_report_set_id,
             p_ship_par_rec.pack_slip_required_flag,
             p_ship_par_rec.pick_sequence_rule_id,
             p_ship_par_rec.pick_grouping_rule_id,
             p_ship_par_rec.print_pick_slip_mode,
             p_ship_par_rec.pick_release_report_set_id,
             p_ship_par_rec.autocreate_del_orders_flag,
             p_ship_par_rec.default_stage_subinventory,
             p_ship_par_rec.default_stage_locator_id,
             p_ship_par_rec.autodetail_pr_flag,
             p_ship_par_rec.enforce_packing_flag,
             p_ship_par_rec.group_by_customer_flag,
             p_ship_par_rec.group_by_fob_flag,
             p_ship_par_rec.group_by_freight_terms_flag,
             p_ship_par_rec.group_by_intmed_ship_to_flag,
             p_ship_par_rec.group_by_ship_method_flag,
             p_ship_par_rec.group_by_carrier_flag,
             p_ship_par_rec.attribute_category,
             p_ship_par_rec.attribute1,
             p_ship_par_rec.attribute2,
             p_ship_par_rec.attribute3,
             p_ship_par_rec.attribute4,
             p_ship_par_rec.attribute5,
             p_ship_par_rec.attribute6,
             p_ship_par_rec.attribute7,
             p_ship_par_rec.attribute8,
             p_ship_par_rec.attribute9,
             p_ship_par_rec.attribute10,
             p_ship_par_rec.attribute11,
             p_ship_par_rec.attribute12,
             p_ship_par_rec.attribute13,
             p_ship_par_rec.attribute14,
             p_ship_par_rec.attribute15,
             nvl(p_ship_par_rec.creation_date,sysdate),
             nvl(p_ship_par_rec.created_by,l_user_id),
             nvl(p_ship_par_rec.last_update_date,sysdate),
             nvl(p_ship_par_rec.last_updated_by,l_user_id),
             nvl(p_ship_par_rec.last_update_login,l_login_id),
             p_ship_par_rec.pick_slip_lines,
             p_ship_par_rec.autocreate_deliveries_flag,
             p_ship_par_rec.freight_class_cat_set_id,
             p_ship_par_rec.commodity_code_cat_set_id,
             p_ship_par_rec.enforce_ship_set_and_smc,
             p_ship_par_rec.auto_send_doc_flag,
             p_ship_par_rec.itm_additional_country_code,
             p_ship_par_rec.auto_select_carrier,
             p_ship_par_rec.ship_confirm_rule_id,
             p_ship_par_rec.autopack_level,
             p_ship_par_rec.task_planning_flag,
             p_ship_par_rec.appending_limit,
             p_ship_par_rec.export_screening_flag,
             p_ship_par_rec.autocreate_del_orders_pr_flag,
             p_ship_par_rec.fpa_positive_tol_amt,
             p_ship_par_rec.fpa_negative_tol_amt,
             p_ship_par_rec.fpa_positive_tol_percentage,
             p_ship_par_rec.fpa_negative_tol_percentage,
             p_ship_par_rec.fpa_default_freight_account,
             p_ship_par_rec.auto_apply_routing_rules,
             p_ship_par_rec.auto_calc_fgt_rate_cr_del,
             p_ship_par_rec.auto_calc_fgt_rate_append_del,
             p_ship_par_rec.auto_calc_fgt_rate_sc_del,
             p_ship_par_rec.raise_business_events,
             p_ship_par_rec.enable_tracking_wfs,
             p_ship_par_rec.enable_sc_wf,
             p_ship_par_rec.check_on_hand,
             --OTM R12
             p_ship_par_rec.max_net_weight,
             p_ship_par_rec.max_gross_weight,
             --OTM R12 Org-Specific
             p_ship_par_rec.otm_enabled,
             p_ship_par_rec.dynamic_replenishment_flag,
	     --OTM Dock Door App Sched Proj
             p_ship_par_rec.dock_appt_scheduling_flag,
             --Bug 7131800
             p_ship_par_rec.retain_nonstaged_det_flag,
             -- Bug 8446283 : begin
             p_ship_par_rec.weight_uom_code,
             p_ship_par_rec.volume_uom_code
             -- Bug 8446283 : end
             );
 Exception
   When others then
     If l_debug_on then
        wsh_debug_sv.log(l_module_name,'After insert into WSH_SHIPPING_PARAMETERS SQLERRM : ',sqlerrm);
     End If;
     fnd_message.set_name('WSH','WSH_UNEXP_ERROR');
     fnd_message.set_token('PACKAGE',l_module_name);
     fnd_message.set_token('ORA_ERROR',to_char(sqlcode));
     fnd_message.set_token('ORA_TEXT',SQLERRM);
     raise handle_exception;
 End;
 If l_debug_on then
    wsh_debug_sv.log(l_module_name,'After insert into WSH_SHIPPING_PARAMETERS SQLERRM : ',sqlerrm);
 End If;


 If  p_ship_par_val_rec.class_code.count > 0 then   /* Start of Main If logic */
 For i in p_ship_par_val_rec.class_code.FIRST..p_ship_par_val_rec.class_code.LAST
 Loop
     If p_ship_par_val_rec.param_name(i) = 'FREIGHT_TERMS' then
        l_freight_count := nvl(l_freight_terms_rec.class_code.count,0) + 1;
        l_freight_terms_rec.class_code(l_freight_count)      := p_ship_par_val_rec.class_code(i);
        l_freight_terms_rec.param_name(l_freight_count)      := p_ship_par_val_rec.param_name(i);
        l_freight_terms_rec.param_data_type(l_freight_count) := p_ship_par_val_rec.param_data_type(i);
        l_freight_terms_rec.param_value_chr(l_freight_count) := p_ship_par_val_rec.param_value_chr(i);
     Else
        l_param_count := nvl(l_ship_par_val_rec.class_code.count,0) + 1;
        l_ship_par_val_rec.organization_id := p_ship_par_val_rec.organization_id;
        l_ship_par_val_rec.class_code(l_param_count)      := p_ship_par_val_rec.class_code(i);
        l_ship_par_val_rec.param_name(l_param_count)      := p_ship_par_val_rec.param_name(i);
        l_ship_par_val_rec.param_data_type(l_param_count) := p_ship_par_val_rec.param_data_type(i);

        If p_ship_par_val_rec.param_data_type(i)    = 'VARCHAR2' then
           If p_ship_par_val_rec.param_name(i) = 'SKIP_RTNG_RULE_AC_TRIP' and
              p_ship_par_rec.auto_apply_routing_rules <> 'D' then
              l_ship_par_val_rec.param_value_chr(l_param_count) := 'N';
           Else
              l_ship_par_val_rec.param_value_chr(l_param_count) := p_ship_par_val_rec.param_value_chr(i);
           End If;
        Elsif p_ship_par_val_rec.param_data_type(i) = 'NUMBER' then
           l_ship_par_val_rec.param_value_chr(l_param_count) := FND_NUMBER.NUMBER_TO_CANONICAL(p_ship_par_val_rec.param_value_num(i));
        Elsif p_ship_par_val_rec.param_data_type(i) = 'DATE' then
           l_ship_par_val_rec.param_value_chr(l_param_count) := fnd_date.date_to_canonical(p_ship_par_val_rec.param_value_date(i)) ;
        End If;

     End If;
 End Loop;

 If l_freight_terms_rec.class_code.count > 0 then

    Begin
       Delete from wsh_shipping_parameter_values
        Where organization_id = l_freight_terms_rec.organization_id
          and class_code = 'FREIGHT_TERMS'
          and param_name = 'FREIGHT_TERMS';
    If l_debug_on then
       wsh_debug_sv.log(l_module_name,'After delete of Freight Terms from wsh_shipping_parameter_values : ',sqlerrm);
    End If;
    Exception
       When others then
         If l_debug_on then
            wsh_debug_sv.log(l_module_name,'After delete of Freight Terms from wsh_shipping_parameter_values : ',sqlerrm);
         End If;
         fnd_message.set_name('WSH','WSH_UNEXP_ERROR');
         fnd_message.set_token('PACKAGE',l_module_name);
         fnd_message.set_token('ORA_ERROR',to_char(sqlcode));
         fnd_message.set_token('ORA_TEXT',SQLERRM);
         Raise handle_exception;
    End;

    l_freight_terms_rec.organization_id  := p_ship_par_val_rec.organization_id;
    create_freight_terms(l_freight_terms_rec
                        ,l_return_status);
    If l_return_status <> wsh_util_core.g_ret_sts_success then
       If l_debug_on then
          wsh_debug_sv.log(l_module_name,'After call to create_freight_terms procedure l_return_status = ',l_return_status);
       End If;
       raise handle_exception;
    End If;
    If l_debug_on then
       wsh_debug_sv.log(l_module_name,'After call to create_freight_terms procedure l_return_status = ',l_return_status);
    End If;
 End If;

 If l_debug_on then
     wsh_debug_sv.log(l_module_name,'Values to be inserted into WSH_SHIPPING_PARAMETER_VALUES as follows');
     print_debug_info(l_module_name
                     ,'WSH_SHIPPING_PARAMETER_VALUES'
                     ,p_ship_par_rec
                     ,l_ship_par_val_rec
                     ,l_return_status);
 End If;


 If l_ship_par_val_rec.class_code.count > 0 then
 Begin
    insert_parameter_values (l_ship_par_val_rec);
 /*
    FORALL i in l_ship_par_val_rec.class_code.FIRST..l_ship_par_val_rec.class_code.LAST
    INSERT INTO wsh_shipping_parameter_values(
                organization_id,
                class_code,
                param_name,
                param_value,
                param_data_type,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                last_update_login)
         VALUES (l_ship_par_val_rec.organization_id,
                l_ship_par_val_rec.class_code(i),
                l_ship_par_val_rec.param_name(i),
                l_ship_par_val_rec.param_value_chr(i),
                p_ship_par_val_rec.param_data_type(i),
                sysdate,
                l_user_id,
                sysdate,
                l_user_id,
                l_login_id);
*/

 If l_debug_on then
    wsh_debug_sv.log(l_module_name,'After insert of values into wsh_shipping_parameter_values table : ',sqlerrm);
 End If;

 Exception
   When Others then
     If l_debug_on then
        wsh_debug_sv.log(l_module_name,'After insert of values into wsh_shipping_parameter_values table : ',sqlerrm);
     End If;
     fnd_message.set_name('WSH','WSH_UNEXP_ERROR');
     fnd_message.set_token('PACKAGE',l_module_name);
     fnd_message.set_token('ORA_ERROR',to_char(sqlcode));
     fnd_message.set_token('ORA_TEXT',SQLERRM);
     raise handle_exception;
 End;
 End If;

 End If;  /* End of Main If logic */

 If l_debug_on then
   wsh_debug_sv.log(l_module_name,'After insert into WSH_SHIPPING_PARAMETER_VALUES SQLERRM : ',sqlerrm);
   wsh_debug_sv.pop(l_module_name);
 End If;

 Exception
   When handle_exception then
      x_return_status := wsh_util_core.g_ret_sts_error;
      If l_debug_on then
         wsh_debug_sv.log(l_module_name,'SQLERRM : ',sqlerrm);
         wsh_debug_sv.log(l_module_name,'x_return_status = : ',x_return_status);
         wsh_debug_sv.pop(l_module_name);
      End If;

   When others then
      x_return_status := wsh_util_core.g_ret_sts_error;
      fnd_message.set_name('WSH','WSH_UNEXP_ERROR');
      fnd_message.set_token('PACKAGE',l_module_name);
      fnd_message.set_token('ORA_ERROR',to_char(sqlcode));
      fnd_message.set_token('ORA_TEXT',SQLERRM);
      If l_debug_on then
         wsh_debug_sv.log(l_module_name,'SQLERRM : ',sqlerrm);
         wsh_debug_sv.log(l_module_name,'x_return_status = : ',x_return_status);
         wsh_debug_sv.pop(l_module_name);
      End If;

End create_parameter ;


Procedure update_parameter(
  p_ship_par_rec     IN parameter_rec_typ,
  p_ship_par_val_rec IN parameter_value_rec_typ,
  x_return_status    OUT NOCOPY VARCHAR2) is

  cursor l_shipping_param_values_csr ( p_organization_id in number ) is
  select param_name
        ,count(*) record_count
    from wsh_shipping_parameter_values
   where organization_id = p_organization_id
     and param_name in (
         'BOL_TEMPLATE'
        ,'EVAL_RULE_BASED_ON_SHIPTO_CUST'
        ,'MBOL_TEMPLATE'
        ,'PACKSLIP_TEMPLATE'
        ,'SKIP_RTNG_RULE_AC_TRIP')
   group by param_name;

  type l_param_value_tbl_type is table of wsh_shipping_parameter_values.param_value%TYPE index by binary_integer;
  type l_param_name_tbl_type  is table of wsh_shipping_parameter_values.param_name%TYPE  index by binary_integer;
  type l_param_class_code_tbl_type is table of wsh_shipping_parameter_values.class_code%TYPE index by binary_integer;
  type l_param_data_type_tbl_type is table of wsh_shipping_parameter_values.param_data_type%TYPE index by binary_integer;
  type l_number_tbl is table of number index by binary_integer;

  l_param_name_tbl   l_param_name_tbl_type;
  l_record_count_tbl l_number_tbl;
  l_user_id       number  := fnd_global.user_id;
  l_login_id      number  := fnd_global.login_id;
  l_all_update    boolean := FALSE;
  l_all_insert    boolean := FALSE;
  l_update_insert boolean := FALSE;
  l_record_exists boolean := FALSE;
  ins_count       number;
  upd_count       number;
  l_debug_on      boolean;
  l_org_name      varchar2(2000) := wsh_util_core.get_org_name(p_ship_par_rec.organization_id);
  l_module_name   constant varchar(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_PARAMETER';
  l_freight_count number ;
  l_return_status varchar2(10);
  l_freight_terms varchar2(240);

  l_freight_terms_value  l_param_value_tbl_type;
  l_freight_terms_rec    parameter_value_rec_typ;
  l_ins_ship_par_val_rec parameter_value_rec_typ;
  l_upd_ship_par_val_rec parameter_value_rec_typ;

 Cursor check_duplicate_csr(p_param_name in varchar2
                           ,p_param_value in varchar2
                           ,p_class_code  in varchar2
                           ,p_organization_id in number ) is
 Select param_value
   from wsh_shipping_parameter_values
  where param_name = p_param_name
    and class_code = p_class_code
    and param_value      = p_param_value
    and organization_id  = p_organization_id;

  handle_exception exception;


Begin
  x_return_status := wsh_util_core.g_ret_sts_success;
  l_debug_on := wsh_debug_interface.g_debug;
  If l_debug_on is null then
     l_debug_on := wsh_debug_sv.is_debug_enabled;
  End If;
  If l_debug_on then
     wsh_debug_sv.push(l_module_name);
  End If;
  Begin
    UPDATE wsh_shipping_parameters set
            goods_dispatched_account       = p_ship_par_rec.goods_dispatched_account,
            location_id                    = p_ship_par_rec.location_id,
            organization_id                = p_ship_par_rec.organization_id,
            weight_uom_class               = p_ship_par_rec.weight_uom_class,
            volume_uom_class               = p_ship_par_rec.volume_uom_class,
            weight_volume_flag             = p_ship_par_rec.weight_volume_flag,
            inv_controls_container_flag    = p_ship_par_rec.inv_controls_container_flag,
            percent_fill_basis_flag        = p_ship_par_rec.percent_fill_basis_flag,
            trip_report_set_id             = p_ship_par_rec.trip_report_set_id,
            delivery_report_set_id         = p_ship_par_rec.delivery_report_set_id,
            pack_slip_required_flag        = p_ship_par_rec.pack_slip_required_flag,
            pick_sequence_rule_id          = p_ship_par_rec.pick_sequence_rule_id,
            pick_grouping_rule_id          = p_ship_par_rec.pick_grouping_rule_id,
            print_pick_slip_mode           = p_ship_par_rec.print_pick_slip_mode,
            pick_release_report_set_id     = p_ship_par_rec.pick_release_report_set_id,
            autocreate_del_orders_flag     = p_ship_par_rec.autocreate_del_orders_flag,
            default_stage_subinventory     = p_ship_par_rec.default_stage_subinventory,
            default_stage_locator_id       = p_ship_par_rec.default_stage_locator_id,
            autodetail_pr_flag             = p_ship_par_rec.autodetail_pr_flag,
            enforce_packing_flag           = p_ship_par_rec.enforce_packing_flag,
            group_by_customer_flag         = p_ship_par_rec.group_by_customer_flag,
            group_by_fob_flag              = p_ship_par_rec.group_by_fob_flag,
            group_by_freight_terms_flag    = p_ship_par_rec.group_by_freight_terms_flag,
            group_by_intmed_ship_to_flag   = p_ship_par_rec.group_by_intmed_ship_to_flag,
            group_by_ship_method_flag      = p_ship_par_rec.group_by_ship_method_flag,
            group_by_carrier_flag          = p_ship_par_rec.group_by_carrier_flag,
            attribute_category             = p_ship_par_rec.attribute_category,
            attribute1                     = p_ship_par_rec.attribute1,
            attribute2                     = p_ship_par_rec.attribute2,
            attribute3                     = p_ship_par_rec.attribute3,
            attribute4                     = p_ship_par_rec.attribute4,
            attribute5                     = p_ship_par_rec.attribute5,
            attribute6                     = p_ship_par_rec.attribute6,
            attribute7                     = p_ship_par_rec.attribute7,
            attribute8                     = p_ship_par_rec.attribute8,
            attribute9                     = p_ship_par_rec.attribute9,
            attribute10                    = p_ship_par_rec.attribute10,
            attribute11                    = p_ship_par_rec.attribute11,
            attribute12                    = p_ship_par_rec.attribute12,
            attribute13                    = p_ship_par_rec.attribute13,
            attribute14                    = p_ship_par_rec.attribute14,
            attribute15                    = p_ship_par_rec.attribute15,
            last_update_date               = nvl(p_ship_par_rec.last_update_date,sysdate),
            last_updated_by                = nvl(p_ship_par_rec.last_updated_by,l_user_id),
            last_update_login              = nvl(p_ship_par_rec.last_update_login,l_login_id),
            pick_slip_lines                = p_ship_par_rec.pick_slip_lines,
            autocreate_deliveries_flag     = p_ship_par_rec.autocreate_deliveries_flag,
            freight_class_cat_set_id       = p_ship_par_rec.freight_class_cat_set_id,
            commodity_code_cat_set_id      = p_ship_par_rec.commodity_code_cat_set_id,
            enforce_ship_set_and_smc       = p_ship_par_rec.enforce_ship_set_and_smc,
            auto_send_doc_flag             = p_ship_par_rec.auto_send_doc_flag,
            itm_additional_country_code    = p_ship_par_rec.itm_additional_country_code,
            auto_select_carrier            = p_ship_par_rec.auto_select_carrier,
            ship_confirm_rule_id           = p_ship_par_rec.ship_confirm_rule_id,
            autopack_level                 = p_ship_par_rec.autopack_level,
            task_planning_flag             = p_ship_par_rec.task_planning_flag,
            appending_limit                = p_ship_par_rec.appending_limit,
            export_screening_flag          = p_ship_par_rec.export_screening_flag,
            autocreate_del_orders_pr_flag  = p_ship_par_rec.autocreate_del_orders_pr_flag,
            fpa_positive_tol_amt           = p_ship_par_rec.fpa_positive_tol_amt,
            fpa_negative_tol_amt           = p_ship_par_rec.fpa_negative_tol_amt,
            fpa_positive_tol_percentage    = p_ship_par_rec.fpa_positive_tol_percentage,
            fpa_negative_tol_percentage    = p_ship_par_rec.fpa_negative_tol_percentage,
            fpa_default_freight_account    = p_ship_par_rec.fpa_default_freight_account,
            auto_apply_routing_rules       = p_ship_par_rec.auto_apply_routing_rules,
            auto_calc_fgt_rate_cr_del      = p_ship_par_rec.auto_calc_fgt_rate_cr_del,
            auto_calc_fgt_rate_append_del  = p_ship_par_rec.auto_calc_fgt_rate_append_del,
            auto_calc_fgt_rate_sc_del      = p_ship_par_rec.auto_calc_fgt_rate_sc_del,
            raise_business_events          = p_ship_par_rec.raise_business_events,
            enable_tracking_wfs            = p_ship_par_rec.enable_tracking_wfs,
            enable_sc_wf                   = p_ship_par_rec.enable_sc_wf,
            check_on_hand                  = p_ship_par_rec.check_on_hand,
            --OTM R12
            max_net_weight                 = p_ship_par_rec.max_net_weight,
            max_gross_weight               = p_ship_par_rec.max_gross_weight,
            --OTM R12 Org-Specific
            otm_enabled                    = p_ship_par_rec.otm_enabled,
            dynamic_replenishment_flag     = p_ship_par_rec.dynamic_replenishment_flag,  --bug# 6689448 (replenishment project)
            dock_appt_scheduling_flag      = p_ship_par_rec.dock_appt_scheduling_flag,  --bug 6700792: OTM Dock Door App Sched Proj
            retain_nonstaged_det_flag      = p_ship_par_rec.retain_nonstaged_det_flag, --Bug 7131800
            -- Bug 8446283 (Added wt/vol UOM codes on shipping parameters forms)
            weight_uom_code                = p_ship_par_rec.weight_uom_code,
            volume_uom_code                = p_ship_par_rec.volume_uom_code
            -- Bug 8446283 : end
    WHERE organization_id =  p_ship_par_rec.organization_id;

  If l_debug_on then
     wsh_debug_sv.log(l_module_name,'After update of values in wsh_shipping_parameters table : ',sqlerrm);
  End If;

  Exception
    When others then
       If l_debug_on then
          wsh_debug_sv.log(l_module_name,'After update of values in wsh_shipping_parameters table : ',sqlerrm);
       End If;
       fnd_message.set_name('WSH','WSH_UNEXP_ERROR');
       fnd_message.set_token('PACKAGE',l_module_name);
       fnd_message.set_token('ORA_ERROR',to_char(sqlcode));
       fnd_message.set_token('ORA_TEXT',SQLERRM);
       raise handle_exception;
  End;


  If  p_ship_par_val_rec.class_code.count > 0 then  /* Start of Main IF logic */
  open  l_shipping_param_values_csr(p_ship_par_val_rec.organization_id);
  fetch l_shipping_param_values_csr bulk collect into
        l_param_name_tbl,
        l_record_count_tbl;
  close l_shipping_param_values_csr;

  If l_param_name_tbl.count = 0 then
     l_all_insert := TRUE;
  End If;

 For i in p_ship_par_val_rec.class_code.FIRST..p_ship_par_val_rec.class_code.LAST
 Loop
     If p_ship_par_val_rec.param_name(i) = 'FREIGHT_TERMS' then
        l_freight_count := nvl(l_freight_terms_rec.class_code.count,0) + 1;
        l_freight_terms_rec.class_code(l_freight_count)      := p_ship_par_val_rec.class_code(i);
        l_freight_terms_rec.param_name(l_freight_count)      := p_ship_par_val_rec.param_name(i);
        l_freight_terms_rec.param_data_type(l_freight_count) := p_ship_par_val_rec.param_data_type(i);
        l_freight_terms_rec.param_value_chr(l_freight_count) := p_ship_par_val_rec.param_value_chr(i);
     Else
        If l_all_insert then
             ins_count := nvl(l_ins_ship_par_val_rec.class_code.count,0) + 1;
             l_ins_ship_par_val_rec.class_code(ins_count)   := p_ship_par_val_rec.class_code(i);
             l_ins_ship_par_val_rec.param_name(ins_count)   := p_ship_par_val_rec.param_name(i);
             l_ins_ship_par_val_rec.param_data_type(ins_count)   := p_ship_par_val_rec.param_data_type(i);

             If p_ship_par_val_rec.param_data_type(i)    = 'VARCHAR2' then
                   l_ins_ship_par_val_rec.param_value_chr(ins_count) := p_ship_par_val_rec.param_value_chr(i);
             Elsif p_ship_par_val_rec.param_data_type(i) = 'NUMBER' then
                   l_ins_ship_par_val_rec.param_value_chr(ins_count) :=
                                         FND_NUMBER.NUMBER_TO_CANONICAL(p_ship_par_val_rec.param_value_num(i));
             Elsif p_ship_par_val_rec.param_data_type(i) = 'DATE' then
                   l_upd_ship_par_val_rec.param_value_chr(ins_count) :=
                                         fnd_date.date_to_canonical(p_ship_par_val_rec.param_value_date(i)) ;
             End If;
        Else
             <<INNER>>
             For j in l_param_name_tbl.FIRST..l_param_name_tbl.LAST
             Loop
                 l_record_exists := FALSE;
                 If (p_ship_par_val_rec.param_name(i) = l_param_name_tbl(j)) then
                    l_record_exists := TRUE;
                    Exit INNER;
                 End If;
             End Loop;
             If l_record_exists then
                  upd_count := nvl(l_upd_ship_par_val_rec.class_code.count,0) + 1;
                  l_upd_ship_par_val_rec.class_code(upd_count)   := p_ship_par_val_rec.class_code(i);
                  l_upd_ship_par_val_rec.param_name(upd_count)   := p_ship_par_val_rec.param_name(i);
                  l_upd_ship_par_val_rec.param_data_type(upd_count)   := p_ship_par_val_rec.param_data_type(i);

                  If p_ship_par_val_rec.param_data_type(i)    = 'VARCHAR2' then
                        l_upd_ship_par_val_rec.param_value_chr(upd_count) := p_ship_par_val_rec.param_value_chr(i);
                  Elsif p_ship_par_val_rec.param_data_type(i) = 'NUMBER' then
                        l_upd_ship_par_val_rec.param_value_chr(upd_count) :=
                                         FND_NUMBER.NUMBER_TO_CANONICAL(p_ship_par_val_rec.param_value_num(i));
                  Elsif p_ship_par_val_rec.param_data_type(i) = 'DATE' then
                        l_upd_ship_par_val_rec.param_value_chr(upd_count) :=
                                         fnd_date.date_to_canonical(p_ship_par_val_rec.param_value_date(i)) ;
                  End If;
                  l_record_exists := FALSE;
             Else
                  ins_count := nvl(l_ins_ship_par_val_rec.class_code.count,0) + 1;
                  l_ins_ship_par_val_rec.class_code(ins_count)   := p_ship_par_val_rec.class_code(i);
                  l_ins_ship_par_val_rec.param_name(ins_count)   := p_ship_par_val_rec.param_name(i);
                  l_ins_ship_par_val_rec.param_data_type(ins_count)   := p_ship_par_val_rec.param_data_type(i);

                  If p_ship_par_val_rec.param_data_type(i)    = 'VARCHAR2' then
                        l_ins_ship_par_val_rec.param_value_chr(ins_count) := p_ship_par_val_rec.param_value_chr(i);
                  Elsif p_ship_par_val_rec.param_data_type(i) = 'NUMBER' then
                        l_ins_ship_par_val_rec.param_value_chr(ins_count) :=
                                            FND_NUMBER.NUMBER_TO_CANONICAL(p_ship_par_val_rec.param_value_num(i));
                  Elsif p_ship_par_val_rec.param_data_type(i) = 'DATE' then
                        l_upd_ship_par_val_rec.param_value_chr(ins_count) :=
                                            fnd_date.date_to_canonical(p_ship_par_val_rec.param_value_date(i)) ;
                  End If;
             End If;
        End If;
     End If;
 End Loop;

 If l_freight_terms_rec.class_code.count > 0 then
    l_freight_terms_rec.organization_id  := p_ship_par_val_rec.organization_id;
    Begin
        Delete from wsh_shipping_parameter_values
         Where organization_id = l_freight_terms_rec.organization_id
           and class_code = 'FREIGHT_TERMS'
           and param_name = 'FREIGHT_TERMS';
       If l_debug_on then
          wsh_debug_sv.log(l_module_name,'After delete of Freigth Terms from  wsh_shipping_parameter_value : ',sqlerrm);
       End If;
    Exception
       When others then
          If l_debug_on then
             wsh_debug_sv.log(l_module_name,'After delete of Freigth Terms from  wsh_shipping_parameter_value : ',sqlerrm);
          End If;
          fnd_message.set_name('WSH','WSH_UNEXP_ERROR');
          fnd_message.set_token('PACKAGE',l_module_name);
          fnd_message.set_token('ORA_ERROR',to_char(sqlcode));
          fnd_message.set_token('ORA_TEXT',SQLERRM);
          raise handle_exception;
    End;
    create_freight_terms(l_freight_terms_rec
                        ,l_return_status);
    If l_return_status <> wsh_util_core.g_ret_sts_success then
       If l_debug_on then
          wsh_debug_sv.log(l_module_name,'After call to create_freight_terms procedure l_return_status = ',l_return_status);
       End If;
       raise handle_exception;
    End If;
 End If;

  If l_all_insert then
     If l_ins_ship_par_val_rec.class_code.COUNT > 0 then
        If l_debug_on then
           wsh_debug_sv.log(l_module_name,'In l_all_insert condition of If statement');
        End If;
        l_ins_ship_par_val_rec.organization_id := p_ship_par_val_rec.organization_id;
        Begin
           insert_parameter_values (l_ins_ship_par_val_rec);
           If l_debug_on then
               wsh_debug_sv.log(l_module_name,'After insert of values in wsh_shipping_parameter_value table : ',sqlerrm);
           End If;
        Exception
          When others then
            If l_debug_on then
               wsh_debug_sv.log(l_module_name,'After insert of values in wsh_shipping_parameter_value table : ',sqlerrm);
            End If;
            fnd_message.set_name('WSH','WSH_UNEXP_ERROR');
            fnd_message.set_token('PACKAGE',l_module_name);
            fnd_message.set_token('ORA_ERROR',to_char(sqlcode));
            fnd_message.set_token('ORA_TEXT',SQLERRM);
            raise handle_exception;
        End;
     End If;
  Else
     If l_ins_ship_par_val_rec.class_code.count > 0 then
        l_ins_ship_par_val_rec.organization_id := p_ship_par_val_rec.organization_id;
        If l_debug_on then
           wsh_debug_sv.log(l_module_name,'Going for insert in ELSE part of l_all_insert condition If statement');
        End If;
        Begin
            insert_parameter_values (l_ins_ship_par_val_rec);
            If l_debug_on then
               wsh_debug_sv.log(l_module_name,'After insert of values in wsh_shipping_parameter_values table : ',sqlerrm);
            End If;
        Exception
          When others then
            If l_debug_on then
               wsh_debug_sv.log(l_module_name,'After insert of values in wsh_shipping_parameter_value table : ',sqlerrm);
            End If;
            fnd_message.set_name('WSH','WSH_UNEXP_ERROR');
            fnd_message.set_token('PACKAGE',l_module_name);
            fnd_message.set_token('ORA_ERROR',to_char(sqlcode));
            fnd_message.set_token('ORA_TEXT',SQLERRM);
            raise handle_exception;
        End;
     End If;

     If l_upd_ship_par_val_rec.class_code.count > 0 then
        l_upd_ship_par_val_rec.organization_id := p_ship_par_val_rec.organization_id;

        If l_debug_on then
           wsh_debug_sv.log(l_module_name,'Going for update in ELSE part of l_all_insert condition If statement');
        End If;

        Begin
             forall i in l_upd_ship_par_val_rec.class_code.first..l_upd_ship_par_val_rec.class_code.last
             update wsh_shipping_parameter_values
                set param_value      = l_upd_ship_par_val_rec.param_value_chr(i)
                  , creation_date    = sysdate
                  , created_by       = l_user_id
                  , last_update_date = sysdate
                  , last_updated_by  = l_user_id
                  , last_update_login= l_login_id
              where organization_id = l_upd_ship_par_val_rec.organization_id
                and param_data_type = l_upd_ship_par_val_rec.param_data_type(i)
                and param_name = l_upd_ship_par_val_rec.param_name(i);

             If l_debug_on then
                wsh_debug_sv.log(l_module_name,'After update of values in wsh_shipping_parameter_values table : ',sqlerrm);
             End If;
        Exception
          When others then
            If l_debug_on then
               wsh_debug_sv.log(l_module_name,'After update of values in wsh_shipping_parameter_value table : ',sqlerrm);
            End If;
            fnd_message.set_name('WSH','WSH_UNEXP_ERROR');
            fnd_message.set_token('PACKAGE',l_module_name);
            fnd_message.set_token('ORA_ERROR',to_char(sqlcode));
            fnd_message.set_token('ORA_TEXT',SQLERRM);
            Raise handle_exception;
        End;
     End If;
  End If;
  End If;  /* End of Main IF logic */

  If l_debug_on then
     wsh_debug_sv.log(l_module_name,'SQLERRM : ',sqlerrm);
     wsh_debug_sv.pop(l_module_name);
  End If;

 Exception
   When handle_exception then
      If l_debug_on then
         wsh_debug_sv.log(l_module_name,'SQLERRM : ',sqlerrm);
         wsh_debug_sv.pop(l_module_name);
      End If;
      x_return_status := wsh_util_core.g_ret_sts_error;

   When others then
      fnd_message.set_name('WSH','WSH_UNEXP_ERROR');
      fnd_message.set_token('PACKAGE',l_module_name);
      fnd_message.set_token('ORA_ERROR',to_char(sqlcode));
      fnd_message.set_token('ORA_TEXT',SQLERRM);
      If l_debug_on then
         wsh_debug_sv.log(l_module_name,'SQLERRM : ',sqlerrm);
         wsh_debug_sv.pop(l_module_name);
      End If;
      x_return_status := wsh_util_core.g_ret_sts_error;

End update_parameter;


Procedure lock_record(
  p_organization_id  IN NUMBER,
  p_last_update_date IN DATE,
  x_return_status    OUT NOCOPY VARCHAR2) is

 Cursor get_last_update_date_csr is
 select last_update_date
   from wsh_shipping_parameters
  where organization_id = p_organization_id;

 Cursor l_lock_csr is
 select 1
   from wsh_shipping_parameters
  where organization_id = p_organization_id
  for update nowait;

 l_id       number :=0;
 l_debug_on boolean;
 l_date     date;
 l_module_name   constant varchar(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_RECORD';
 handle_exception exception;
 others exception;

Begin
 x_return_status := wsh_util_core.G_RET_STS_SUCCESS;
 l_debug_on := wsh_debug_interface.g_debug;
 If l_debug_on is null then
    l_debug_on := wsh_debug_sv.is_debug_enabled;
 End If;
 If l_debug_on then
    wsh_debug_sv.push(l_module_name);
 End If;

 Open  get_last_update_date_csr;
 Fetch get_last_update_date_csr into l_date;
 Close get_last_update_date_csr;

 If l_date is not null then
    If l_date <> p_last_update_date then
       fnd_message.set_name('FND' , 'FND_RECORD_CHANGED_ERROR');
       Raise handle_exception;
    End If;

 End If;

 Open  l_lock_csr;
 Fetch l_lock_csr into l_id ;
 Close l_lock_csr;

 If l_id is null then
   x_return_status := wsh_util_core.G_RET_STS_ERROR;
   fnd_message.set_name('FND', 'FND_RECORD_DELETED_ERROR');
   If l_debug_on then
      wsh_debug_sv.log(l_module_name,'Value of L_ID = ',l_id);
      wsh_debug_sv.log(l_module_name,'Record dosent exists for the ORG ID ',p_organization_id);
      wsh_debug_sv.log(l_module_name,'x_return_status  ',x_return_status);
   End If;
   raise others;
 End If;

 If l_debug_on then
    wsh_debug_sv.log(l_module_name,'x_return_status  ',x_return_status);
    wsh_debug_sv.pop(l_module_name);
 End If;

Exception
  When handle_exception then
       x_return_status := wsh_util_core.g_ret_sts_error;
       If l_debug_on then
          wsh_debug_sv.log(l_module_name,'SQLERRM : ',sqlerrm);
          wsh_debug_sv.log(l_module_name,'x_return_status : ',x_return_status);
          wsh_debug_sv.pop(l_module_name);
       End If;
  When Others then
       fnd_message.set_name('FND', 'FND_LOCK_RECORD_ERROR');
       x_return_status := wsh_util_core.G_RET_STS_UNEXP_ERROR;
       If l_debug_on then
          wsh_debug_sv.log(l_module_name,'Unexpected Error Occured During Locking for Org Id ',p_organization_id);
          wsh_debug_sv.log(l_module_name,'SQLERRM = ', SQLERRM );
          wsh_debug_sv.log(l_module_name,'x_return_status  ',x_return_status);
          wsh_debug_sv.pop(l_module_name);
       End If;
End lock_record;


Procedure get_layout_template (
  p_concprg_name  IN VARCHAR2,
  p_code_field    IN VARCHAR2,
  x_name_field    OUT NOCOPY VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR )is

 Cursor get_template_name_csr is
 select template_name
   from xdo_templates_vl
  where data_source_code = p_concprg_name
    and template_code = p_code_field;

 get_template_name_rec get_template_name_csr%ROWTYPE;
 l_debug_on      boolean;
 l_module_name   constant varchar(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_LAYOUT_TEMPLATE';

Begin
  x_return_status := wsh_util_core.G_RET_STS_SUCCESS;
  l_debug_on := wsh_debug_interface.g_debug;
  If l_debug_on is null then
     l_debug_on := wsh_debug_sv.is_debug_enabled;
  End If;
  If l_debug_on then
     wsh_debug_sv.push(l_module_name);
     wsh_debug_sv.log(l_module_name,'p_concprg_name ',p_concprg_name);
     wsh_debug_sv.log(l_module_name,'p_code_field   ',p_code_field);
  End If;

  Open  get_template_name_csr;
  Fetch get_template_name_csr into get_template_name_rec;
  Close get_template_name_csr;
  x_name_field := get_template_name_rec.template_name;

  If l_debug_on then
     wsh_debug_sv.log(l_module_name,'x_name_field  ',x_name_field);
     wsh_debug_sv.pop(l_module_name);
  End If;

Exception
 When Others then
   x_return_status := wsh_util_core.G_RET_STS_ERROR;
   If l_debug_on then
       wsh_debug_sv.log(l_module_name,'Unexpected Error Occured while getting tamplate name ',p_concprg_name||' '||p_code_field);
       wsh_debug_sv.log(l_module_name,'SQLERRM = ', SQLERRM );
       wsh_debug_sv.log(l_module_name,'x_return_status  ',x_return_status);
       wsh_debug_sv.pop(l_module_name);
   End If;

End get_layout_template;


Procedure  get(
   p_organization_id  IN  NUMBER,
   x_param_info       OUT NOCOPY  parameter_rec_typ,
   x_param_value_info OUT NOCOPY  parameter_value_rec_typ,
   x_return_status    OUT NOCOPY  VARCHAR2) IS

  type l_varchar2_tb is table of wsh_shipping_parameter_values.param_value%TYPE index by binary_integer;
  l_param_value l_varchar2_tb;

  cursor get_paramter_values_csr(p_organization_id in number) is
  select class_code
       , param_name
       , decode(class_code
         ,'ROUTING_RULES',nvl(param_value, 'N'),param_value) param_value
       , param_data_type
    from wsh_shipping_parameter_values
   where organization_id = p_organization_id ;

  l_param_info    parameter_Rec_Typ;
  l_module_name   CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET';
  l_found         boolean := FALSE;
  l_row_count     number;
  l_debug_on      boolean;
  l_msg_data      varchar2(2000);
  l_return_status varchar2(1);

  others exception;

Begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_debug_on := wsh_debug_interface.g_debug;
  IF l_debug_on IS NULL THEN
     l_debug_on := wsh_debug_sv.is_debug_enabled;
  END IF;
  IF l_debug_on THEN
     wsh_debug_sv.push(l_module_name);
     wsh_debug_sv.log(l_module_name,'P_ORGANIZATION_ID',p_organization_id);
  END IF;

  ------------------------------------------------------------------------
  --           Get values from wsh_shipping_parameters table .           -
  ------------------------------------------------------------------------
  get(p_organization_id => p_organization_id
     ,x_param_info      => l_param_info
     ,x_return_status   => l_return_status);

  If l_return_status <> fnd_api.G_RET_STS_SUCCESS then
     x_return_status := l_return_status;
     return;
  Else
     x_param_info := l_param_info;
  End If;

  ------------------------------------------------------------------------
  -- Get values from wsh_shipping_parameter_values table .Don't raise   --
  -- error is records dosen't exists.                                   --
  ------------------------------------------------------------------------
  l_found := FALSE;
  If g_parameter_values.count > 0 then
     For i in g_parameter_values.FIRST..g_parameter_values.LAST
     Loop
        If g_parameter_values(i).organization_id = p_organization_id then
           x_param_value_info := g_parameter_values(i);
           l_found := TRUE;
           exit;
        End If;
     End Loop;
     If l_found  and l_debug_on then
        print_debug_info(l_module_name
                        ,'WSH_SHIPPING_PARAMETER_VALUES'
                        ,x_param_info
                        ,x_param_value_info
                        ,l_return_status);
        WSH_DEBUG_SV.pop(l_module_name);
     End If;
     If l_found then
        return;
     End If;
  End If;

  Open get_paramter_values_csr(p_organization_id);
  Fetch get_paramter_values_csr bulk collect into
        x_param_value_info.class_code
       ,x_param_value_info.param_name
       ,l_param_value
       ,x_param_value_info.param_data_type;
  Close get_paramter_values_csr;
  If l_debug_on then
     wsh_debug_sv.log(l_module_name,'After select from wsh_shipping_parameter_values : ',sqlerrm);
     wsh_debug_sv.log(l_module_name,'Row_Count =  : ',x_param_value_info.param_name.count);
  End If;

  If x_param_value_info.param_name.COUNT > 0 then
   For i in x_param_value_info.param_name.FIRST..x_param_value_info.param_name.LAST
     Loop
        If  x_param_value_info.param_data_type(i) = 'VARCHAR2' then
            x_param_value_info.param_value_num(i) := NULL;
            x_param_value_info.param_value_chr(i) := l_param_value(i);
            x_param_value_info.param_value_date(i):= NULL;
        Elsif  x_param_value_info.param_data_type(i) = 'DATE' then
            x_param_value_info.param_value_num(i) := NULL;
            x_param_value_info.param_value_chr(i) := NULL;
            x_param_value_info.param_value_date(i):= fnd_date.canonical_to_date(l_param_value(i));
        Elsif  x_param_value_info.param_data_type(i) = 'NUMBER' then
            x_param_value_info.param_value_num(i) := fnd_number.canonical_to_number(l_param_value(i));
            x_param_value_info.param_value_chr(i) := NULL;
            x_param_value_info.param_value_date(i):= NULL;
        End If;
     End Loop;
  End if;

  If l_found  and l_debug_on then
     print_debug_info(l_module_name
                     ,'WSH_SHIPPING_PARAMETER_VALUES'
                     ,x_param_info
                     ,x_param_value_info
                     ,l_return_status);
  End If;

  If x_param_value_info.param_name.COUNT > 0 then
     l_row_count := g_parameter_values.count + 1;
     g_parameter_values(l_row_count).organization_id  := p_organization_id;
     g_parameter_values(l_row_count).class_code       := x_param_value_info.class_code;
     g_parameter_values(l_row_count).param_name       := x_param_value_info.param_name;
     g_parameter_values(l_row_count).param_data_type  := x_param_value_info.param_data_type;
     g_parameter_values(l_row_count).param_value_num  := x_param_value_info.param_value_num;
     g_parameter_values(l_row_count).param_value_chr  := x_param_value_info.param_value_chr;
     g_parameter_values(l_row_count).param_value_date := x_param_value_info.param_value_date;
  End If;

  If l_debug_on then
    wsh_debug_sv.pop(l_module_name);
  End If;

  Exception
    When Others Then
      fnd_message.set_name('WSH','WSH_UNEXP_ERROR');
      fnd_message.set_token('PACKAGE','WSH_SHIPPING_PARAMS_PVT');
      fnd_message.set_token('ORA_ERROR',to_char(sqlcode));
      fnd_message.set_token('ORA_TEXT','');
      x_return_status := FND_API.G_RET_STS_ERROR;
      If l_debug_on Then
           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
END Get;


Procedure create_freight_terms(
  p_freight_terms_rec IN parameter_value_rec_typ,
  x_return_status OUT NOCOPY VARCHAR2)is

 type l_parameter_value_type is table of wsh_shipping_parameter_values.PARAM_VALUE%TYPE index by binary_integer;

 l_freight_terms_value l_parameter_value_type;
 l_org_name      varchar2(2000) := wsh_util_core.get_org_name(p_freight_terms_rec.organization_id);
 l_user_id       number:= fnd_global.user_id;
 l_login_id      number:= fnd_global.login_id;
 l_debug_on      boolean;
 l_module_name   constant varchar(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_FREIGHT_TERMS';
 l_return_status varchar2(10);
 l_freight_terms varchar2(240);

 Cursor check_duplicate_csr(p_param_name in varchar2
                           ,p_param_value in varchar2
                           ,p_class_code  in varchar2
                           ,p_organization_id in number ) is
 Select param_value
   from wsh_shipping_parameter_values
  where param_name = p_param_name
    and class_code = p_class_code
    and param_value      = p_param_value
    and organization_id  = p_organization_id;

 handle_exception exception;

Begin

 x_return_status := fnd_api.g_ret_sts_success;

 l_debug_on := wsh_debug_interface.g_debug;
 If l_debug_on is null then
    wsh_debug_sv.push(l_module_name);
    l_debug_on := wsh_debug_sv.is_debug_enabled;
 End If;
 If l_debug_on then
    wsh_debug_sv.log(l_module_name, 'p_freight_terms_rec.class_code.count ', p_freight_terms_rec.class_code.count);
    print_debug_info(l_module_name
                    ,'WSH_SHIPPING_PARAMETER_VALUES'
                    ,null
                    ,p_freight_terms_rec
                    ,l_return_status);
 End If;

 If p_freight_terms_rec.class_code.count > 0 then
    For i in p_freight_terms_rec.class_code.FIRST..p_freight_terms_rec.class_code.LAST
    Loop
       If l_freight_terms_value.COUNT > 0 then
         For j in l_freight_terms_value.FIRST..l_freight_terms_value.LAST
         Loop
             If l_freight_terms_value(j) = p_freight_terms_rec.param_value_chr(i) then
                If l_debug_on then
                    wsh_debug_sv.log(l_module_name, 'Going to raise others exception , Duplicate records exists for freight terms ');
                End If;
                fnd_message.set_name('WSH','WSH_FREIGHT_ORG_ASSGN_EXISTS');
                fnd_message.set_token('FREIGHT_TERMS',p_freight_terms_rec.param_value_chr(i));
                fnd_message.set_token('ORG_NAME',l_org_name);
                Raise handle_exception;
             End If;
         End Loop;
         l_freight_terms_value(nvl(l_freight_terms_value.count,0)+1) := p_freight_terms_rec.param_value_chr(i);
       Else
         l_freight_terms_value(nvl(l_freight_terms_value.count,0)+1) := p_freight_terms_rec.param_value_chr(i);
       End If;

       open  check_duplicate_csr(p_freight_terms_rec.param_name(i)
                                ,p_freight_terms_rec.param_value_chr(i)
                                ,p_freight_terms_rec.class_code(i)
                                ,p_freight_terms_rec.organization_id);
       fetch check_duplicate_csr into l_freight_terms;
       close check_duplicate_csr;

       If l_freight_terms is not null then
          If l_debug_on then
             wsh_debug_sv.log(l_module_name, 'One of the inserted records matches existing record in wsh_shipping_parameter_values table');
             wsh_debug_sv.log(l_module_name, 'Duplicate Freight Terms is ',p_freight_terms_rec.param_value_chr(i));
             wsh_debug_sv.log(l_module_name, 'For Organization id  ',p_freight_terms_rec.organization_id);
          End If;
          fnd_message.set_name('FND','FND_RECORD_CHANGED_ERROR');
          Raise handle_exception;
       End If;

    End Loop;

    If l_debug_on then
       wsh_debug_sv.log(l_module_name, 'p_freight_terms_rec.class_code.count ', p_freight_terms_rec.class_code.count);
       wsh_debug_sv.log(l_module_name,'Before insert of values into wsh_shipping_parameter_values table : ');
    End If;

    If p_freight_terms_rec.param_name.count > 0 then
       Begin
           FORALL i in p_freight_terms_rec.class_code.FIRST..p_freight_terms_rec.class_code.LAST
           Insert into wsh_shipping_parameter_values(
                  organization_id,
                  class_code,
                  param_name,
                  param_value,
                  param_data_type,
                  creation_date,
                  created_by,
                  last_update_date,
                  last_updated_by,
                  last_update_login)
          Values (p_freight_terms_rec.organization_id,
                  p_freight_terms_rec.class_code(i),
                  p_freight_terms_rec.param_name(i),
                  p_freight_terms_rec.param_value_chr(i),
                  p_freight_terms_rec.param_data_type(i),
                  sysdate,
                  l_user_id,
                  sysdate,
                  l_user_id,
                  l_login_id);

            If l_debug_on then
               wsh_debug_sv.log(l_module_name,'After insert of values in wsh_shipping_parameter_values table : ',sqlerrm);
            End If;
       Exception
          When others then
              If l_debug_on then
                 wsh_debug_sv.log(l_module_name,'After insert of values in wsh_shipping_parameter_values table : ',sqlerrm);
              End If;
              fnd_message.set_name('WSH','WSH_UNEXP_ERROR');
              fnd_message.set_token('PACKAGE',l_module_name);
              fnd_message.set_token('ORA_ERROR',to_char(sqlcode));
              fnd_message.set_token('ORA_TEXT',SQLERRM);
              raise handle_exception;
       End;
    End If;
 End If;

 If l_debug_on then
    wsh_debug_sv.log(l_module_name,'After insert into wsh_shipping_parameter_values SQLERRM : ',SQLERRM);
    wsh_debug_sv.pop(l_module_name);
 End If;

 Exception
   When handle_exception then
      x_return_status := wsh_util_core.g_ret_sts_error;
      If l_debug_on then
         wsh_debug_sv.log(l_module_name,'SQLERRM : ',sqlerrm);
         wsh_debug_sv.log(l_module_name,'x_return_status : ',x_return_status);
         wsh_debug_sv.pop(l_module_name);
      End If;
   When others then
      x_return_status := wsh_util_core.g_ret_sts_error;
      fnd_message.set_name('WSH','WSH_UNEXP_ERROR');
      fnd_message.set_token('PACKAGE',l_module_name);
      fnd_message.set_token('ORA_ERROR',to_char(sqlcode));
      fnd_message.set_token('ORA_TEXT',SQLERRM);
      If l_debug_on then
         wsh_debug_sv.log(l_module_name,'SQLERRM : ',sqlerrm);
         wsh_debug_sv.log(l_module_name,'x_return_status : ',x_return_status);
         wsh_debug_sv.pop(l_module_name);
      End If;

End create_freight_terms;



Procedure update_freight_terms(
  p_freight_terms_rec IN parameter_value_rec_typ,
  row_id  IN row_id_tbl,
  x_return_status OUT NOCOPY VARCHAR2) is

 Cursor check_duplicate_csr(p_row_id     in varchar2
                           ,p_param_name in varchar2
                           ,p_param_value in varchar2
                           ,p_class_code  in varchar2
                           ,p_organization_id in number ) is
 Select param_value
   from wsh_shipping_parameter_values
  where rowid <> p_row_id
    and param_name = p_param_name
    and class_code = p_class_code
    and param_value      = p_param_value
    and organization_id  = p_organization_id;

 l_user_id         number:= fnd_global.user_id;
 l_login_id        number:= fnd_global.login_id;
 l_debug_on        boolean;
 l_module_name     constant varchar(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_FREIGHT_TERMS';
 l_return_status   varchar2(10);
 l_org_name        varchar2(2000) := wsh_util_core.get_org_name(p_freight_terms_rec.organization_id);
 l_freight_terms   varchar2(240);
 handle_exception  exception;

Begin

 x_return_status := fnd_api.g_ret_sts_success;

 l_debug_on := wsh_debug_interface.g_debug;
 If l_debug_on is null then
    l_debug_on := wsh_debug_sv.is_debug_enabled;
 End If;
 If l_debug_on then
    wsh_debug_sv.log(l_module_name, 'p_freight_terms_rec.class_code.count ', p_freight_terms_rec.class_code.count);
    print_debug_info(l_module_name
                    ,'WSH_SHIPPING_PARAMETER_VALUES'
                    ,null
                    ,p_freight_terms_rec
                    ,l_return_status);
 End If;

 If p_freight_terms_rec.class_code.count > 0 then

    For i in row_id.first..row_id.last
    Loop
       open  check_duplicate_csr(row_id(i)
                                ,p_freight_terms_rec.param_name(i)
                                ,p_freight_terms_rec.param_value_chr(i)
                                ,p_freight_terms_rec.class_code(i)
                                ,p_freight_terms_rec.organization_id);
       fetch check_duplicate_csr into l_freight_terms;
       close check_duplicate_csr;

       If l_freight_terms is not null then
          If l_debug_on then
             wsh_debug_sv.log(l_module_name, 'Going to raise others exception , Duplicate records exists for freight terms ');
          End If;
          fnd_message.set_name('WSH','WSH_FREIGHT_ORG_ASSGN_EXISTS');
          fnd_message.set_token('FREIGHT_TERMS',p_freight_terms_rec.param_value_chr(i));
          fnd_message.set_token('ORG_NAME',l_org_name);
          Raise handle_exception;
       End If;
    End Loop;

     If l_debug_on then
        wsh_debug_sv.log(l_module_name, 'Before update of wsh_shipping_parameter_values table');
     End If;

     If row_id.count > 0 then
        Begin
           Forall i in row_id.first..row_id.last
           Update wsh_shipping_parameter_values
              Set param_value   = p_freight_terms_rec.param_value_chr(i),
                  creation_date = sysdate,
                  created_by    = l_user_id,
                  last_update_date  = sysdate,
                  last_updated_by   = l_user_id,
                  last_update_login = l_login_id
           Where rowid = row_id(i);
        Exception
          When others then
              If l_debug_on then
                 wsh_debug_sv.log(l_module_name,'After insert of values in wsh_shipping_parameter_values table : ',sqlerrm);
              End If;
              fnd_message.set_name('WSH','WSH_UNEXP_ERROR');
              fnd_message.set_token('PACKAGE',l_module_name);
              fnd_message.set_token('ORA_ERROR',to_char(sqlcode));
              fnd_message.set_token('ORA_TEXT',SQLERRM);
              raise handle_exception;
        End;
     End If;

     If sql%notfound then
        fnd_message.set_name('FND' , 'FORM_RECORD_CHANGED');
        Raise handle_exception;
     End If;

     If l_debug_on then
        wsh_debug_sv.log(l_module_name, 'After update of wsh_shipping_parameter_values SQLERRM',SQLERRM);
     End If;
 End If;

 If l_debug_on then
    wsh_debug_sv.pop(l_module_name);
 End If;

 Exception
   When handle_exception then
      x_return_status := wsh_util_core.g_ret_sts_error;
      If l_debug_on then
         wsh_debug_sv.log(l_module_name,'SQLERRM : ',sqlerrm);
         wsh_debug_sv.log(l_module_name,'x_return_status : ',x_return_status);
         wsh_debug_sv.pop(l_module_name);
      End If;
   When others then
      x_return_status := wsh_util_core.g_ret_sts_error;
      fnd_message.set_name('WSH','WSH_UNEXP_ERROR');
      fnd_message.set_token('PACKAGE',l_module_name);
      fnd_message.set_token('ORA_ERROR',to_char(sqlcode));
      fnd_message.set_token('ORA_TEXT',SQLERRM);
      If l_debug_on then
         wsh_debug_sv.log(l_module_name,'SQLERRM : ',sqlerrm);
         wsh_debug_sv.log(l_module_name,'x_return_status : ',x_return_status);
         wsh_debug_sv.pop(l_module_name);
      End If;

End update_freight_terms;



Procedure delete_freight_terms(
  p_freight_terms_rec IN parameter_value_rec_typ,
  row_id  IN row_id_tbl,
  x_return_status OUT NOCOPY VARCHAR2) is

 l_debug_on      boolean;
 l_module_name   constant varchar(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELETE_FREIGHT_TERMS';
 l_return_status varchar2(10);
 Others Exception;

Begin

 x_return_status := fnd_api.g_ret_sts_success;

 l_debug_on := wsh_debug_interface.g_debug;
 If l_debug_on is null then
    l_debug_on := wsh_debug_sv.is_debug_enabled;
 End If;
 If l_debug_on then
    wsh_debug_sv.log(l_module_name, 'p_freight_terms_rec.class_code.count ', p_freight_terms_rec.class_code.count);
    wsh_debug_sv.log(l_module_name, 'row_id.count ', row_id.count);
    print_debug_info(l_module_name
                    ,'WSH_SHIPPING_PARAMETER_VALUES'
                    ,null
                    ,p_freight_terms_rec
                    ,l_return_status);
 End If;

 If row_id.count > 0 then
  Forall i in row_id.first..row_id.last
  Delete from  wsh_shipping_parameter_values
   Where rowid = row_id(i);
 End If;

 If l_debug_on then
    wsh_debug_sv.pop(l_module_name);
 End If;

 Exception
   When others then
      x_return_status := wsh_util_core.g_ret_sts_error;
      fnd_message.set_name('WSH','WSH_UNEXP_ERROR');
      fnd_message.set_token('PACKAGE',l_module_name);
      fnd_message.set_token('ORA_ERROR',to_char(sqlcode));
      fnd_message.set_token('ORA_TEXT',SQLERRM);
      If l_debug_on then
         wsh_debug_sv.log(l_module_name,'SQLERRM : ',sqlerrm);
         wsh_debug_sv.log(l_module_name,'x_return_status : ',x_return_status);
         wsh_debug_sv.pop(l_module_name);
      End If;

End delete_freight_terms;



Procedure print_debug_info(
   p_module_name      IN VARCHAR2,
   p_print_info       IN VARCHAR2,
   x_param_info       IN parameter_rec_typ,
   x_param_value_info IN parameter_value_rec_typ,
   x_return_status    OUT NOCOPY  VARCHAR2) is

   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PRINT_DEBUG_INFO';

Begin

 x_return_status := fnd_api.g_ret_sts_success;
 If p_print_info = 'WSH_SHIPPING_PARAMETERS'  OR p_print_info = 'ALL' then
   wsh_debug_sv.log(p_module_name,'x_param_info.ship_confirm_rule_id',x_param_info.ship_confirm_rule_id);
   wsh_debug_sv.log(p_module_name,'x_param_info.autopack_level',x_param_info.autopack_level);
   wsh_debug_sv.log(p_module_name,'x_param_info.task_planning_flag',x_param_info.task_planning_flag);
   wsh_debug_sv.log(p_module_name,'x_param_info.export_screening_flag',x_param_info.export_screening_flag);
   wsh_debug_sv.log(p_module_name,'x_param_info.appending_limit',x_param_info.appending_limit);
   wsh_debug_sv.log(p_module_name,'x_param_info.ignore_inbound_trip',x_param_info.ignore_inbound_trip);
   wsh_debug_sv.log(p_module_name,'x_param_info.pack_slip_required_flag',x_param_info.pack_slip_required_flag);
   wsh_debug_sv.log(p_module_name,'x_param_info.pick_sequence_rule_id',x_param_info.pick_sequence_rule_id);
   wsh_debug_sv.log(p_module_name,'x_param_info.pick_grouping_rule_id',x_param_info.pick_grouping_rule_id);
   wsh_debug_sv.log(p_module_name,'x_param_info.print_pick_slip_mode',x_param_info.print_pick_slip_mode);
   wsh_debug_sv.log(p_module_name,'x_param_info.pick_release_report_set_id',x_param_info.pick_release_report_set_id);
   wsh_debug_sv.log(p_module_name,'x_param_info.autocreate_del_orders_flag',x_param_info.autocreate_del_orders_flag);
   wsh_debug_sv.log(p_module_name,'x_param_info.default_stage_subinventory',x_param_info.default_stage_subinventory);
   wsh_debug_sv.log(p_module_name,'x_param_info.default_stage_locator_id',x_param_info.default_stage_locator_id);
   wsh_debug_sv.log(p_module_name,'x_param_info.autodetail_pr_flag',x_param_info.autodetail_pr_flag);
   wsh_debug_sv.log(p_module_name,'x_param_info.enforce_packing_flag',x_param_info.enforce_packing_flag);
   wsh_debug_sv.log(p_module_name,'x_param_info.group_by_customer_flag',x_param_info.group_by_customer_flag);
   wsh_debug_sv.log(p_module_name,'x_param_info.group_by_fob_flag',x_param_info.group_by_fob_flag);
   wsh_debug_sv.log(p_module_name,'x_param_info.group_by_freight_terms_flag',x_param_info.group_by_freight_terms_flag);
   wsh_debug_sv.log(p_module_name,'x_param_info.group_by_intmed_ship_to_flag',x_param_info.group_by_intmed_ship_to_flag);
   wsh_debug_sv.log(p_module_name,'x_param_info.group_by_ship_method_flag',x_param_info.group_by_ship_method_flag);
   wsh_debug_sv.log(p_module_name,'x_param_info.group_by_carrier_flag',x_param_info.group_by_carrier_flag);
   wsh_debug_sv.log(p_module_name,'x_param_info.attribute_category',x_param_info.attribute_category);
   wsh_debug_sv.log(p_module_name,'x_param_info.attribute1',x_param_info.attribute1);
   wsh_debug_sv.log(p_module_name,'x_param_info.attribute2',x_param_info.attribute2);
   wsh_debug_sv.log(p_module_name,'x_param_info.attribute3',x_param_info.attribute3);
   wsh_debug_sv.log(p_module_name,'x_param_info.attribute4',x_param_info.attribute4);
   wsh_debug_sv.log(p_module_name,'x_param_info.attribute5',x_param_info.attribute5);
   wsh_debug_sv.log(p_module_name,'x_param_info.attribute6',x_param_info.attribute6);
   wsh_debug_sv.log(p_module_name,'x_param_info.attribute7',x_param_info.attribute7);
   wsh_debug_sv.log(p_module_name,'x_param_info.attribute8',x_param_info.attribute8);
   wsh_debug_sv.log(p_module_name,'x_param_info.attribute9',x_param_info.attribute9);
   wsh_debug_sv.log(p_module_name,'x_param_info.attribute10',x_param_info.attribute10);
   wsh_debug_sv.log(p_module_name,'x_param_info.attribute11',x_param_info.attribute11);
   wsh_debug_sv.log(p_module_name,'x_param_info.attribute12',x_param_info.attribute12);
   wsh_debug_sv.log(p_module_name,'x_param_info.attribute13',x_param_info.attribute13);
   wsh_debug_sv.log(p_module_name,'x_param_info.attribute14',x_param_info.attribute14);
   wsh_debug_sv.log(p_module_name,'x_param_info.attribute15',x_param_info.attribute15);
   wsh_debug_sv.log(p_module_name,'x_param_info.creation_date',x_param_info.creation_date);
   wsh_debug_sv.log(p_module_name,'x_param_info.created_by',x_param_info.created_by);
   wsh_debug_sv.log(p_module_name,'x_param_info.last_update_date',x_param_info.last_update_date);
   wsh_debug_sv.log(p_module_name,'x_param_info.last_updated_by',x_param_info.last_updated_by);
   wsh_debug_sv.log(p_module_name,'x_param_info.last_update_login',x_param_info.last_update_login);
   wsh_debug_sv.log(p_module_name,'x_param_info.program_application_id',x_param_info.program_application_id);
   wsh_debug_sv.log(p_module_name,'x_param_info.program_id',x_param_info.program_id);
   wsh_debug_sv.log(p_module_name,'x_param_info.program_update_date',x_param_info.program_update_date);
   wsh_debug_sv.log(p_module_name,'x_param_info.request_id',x_param_info.request_id);
   wsh_debug_sv.log(p_module_name,'x_param_info.pick_slip_lines',x_param_info.pick_slip_lines);
   wsh_debug_sv.log(p_module_name,'x_param_info.autocreate_deliveries_flag',x_param_info.autocreate_deliveries_flag);
   wsh_debug_sv.log(p_module_name,'x_param_info.freight_class_cat_set_id',x_param_info.freight_class_cat_set_id);
   wsh_debug_sv.log(p_module_name,'x_param_info.commodity_code_cat_set_id',x_param_info.commodity_code_cat_set_id);
   wsh_debug_sv.log(p_module_name,'x_param_info.enforce_ship_set_and_smc',x_param_info.enforce_ship_set_and_smc);
   wsh_debug_sv.log(p_module_name,'x_param_info.auto_send_doc_flag',x_param_info.auto_send_doc_flag);
   wsh_debug_sv.log(p_module_name,'x_param_info.itm_additional_country_code',x_param_info.itm_additional_country_code);
   wsh_debug_sv.log(p_module_name,'x_param_info.auto_select_carrier',x_param_info.auto_select_carrier);
   wsh_debug_sv.log(p_module_name,'x_param_info.goods_dispatched_account',x_param_info.goods_dispatched_account);
   wsh_debug_sv.log(p_module_name,'x_param_info.location_id',x_param_info.location_id);
   wsh_debug_sv.log(p_module_name,'x_param_info.organization_id',x_param_info.organization_id);
   wsh_debug_sv.log(p_module_name,'x_param_info.weight_uom_class',x_param_info.weight_uom_class);
   wsh_debug_sv.log(p_module_name,'x_param_info.volume_uom_class',x_param_info.volume_uom_class);
   wsh_debug_sv.log(p_module_name,'x_param_info.weight_volume_flag',x_param_info.weight_volume_flag);
   wsh_debug_sv.log(p_module_name,'x_param_info.inv_controls_container_flag',x_param_info.inv_controls_container_flag);
   wsh_debug_sv.log(p_module_name,'x_param_info.percent_fill_basis_flag',x_param_info.percent_fill_basis_flag);
   wsh_debug_sv.log(p_module_name,'x_param_info.trip_report_set_id',x_param_info.trip_report_set_id);
   wsh_debug_sv.log(p_module_name,'x_param_info.delivery_report_set_id',x_param_info.delivery_report_set_id);
   wsh_debug_sv.log(p_module_name,'x_param_info.autocreate_del_orders_pr_flag',x_param_info.autocreate_del_orders_pr_flag);
   wsh_debug_sv.log(p_module_name,'x_param_info.fpa_positive_tol_amt',x_param_info.fpa_positive_tol_amt);
   wsh_debug_sv.log(p_module_name,'x_param_info.fpa_negative_tol_amt',x_param_info.fpa_negative_tol_amt);
   wsh_debug_sv.log(p_module_name,'x_param_info.fpa_positive_tol_percentage',x_param_info.fpa_positive_tol_percentage);
   wsh_debug_sv.log(p_module_name,'x_param_info.fpa_negative_tol_percentage',x_param_info.fpa_negative_tol_percentage);
   wsh_debug_sv.log(p_module_name,'x_param_info.fpa_default_freight_account',x_param_info.fpa_default_freight_account);
   wsh_debug_sv.log(p_module_name,'x_param_info.auto_apply_routing_rules',x_param_info.auto_apply_routing_rules);
   wsh_debug_sv.log(p_module_name,'x_param_info.auto_calc_fgt_rate_cr_del',x_param_info.auto_calc_fgt_rate_cr_del);
   wsh_debug_sv.log(p_module_name,'x_param_info.auto_calc_fgt_rate_append_del',x_param_info.auto_calc_fgt_rate_append_del);
   wsh_debug_sv.log(p_module_name,'x_param_info.auto_calc_fgt_rate_sc_del',x_param_info.auto_calc_fgt_rate_sc_del);
   wsh_debug_sv.log(p_module_name,'x_param_info.raise_business_events',x_param_info.raise_business_events);
   wsh_debug_sv.log(p_module_name,'x_param_info.enable_tracking_wfs',x_param_info.enable_tracking_wfs);
   wsh_debug_sv.log(p_module_name,'x_param_info.enable_sc_wf',x_param_info.enable_sc_wf);
   wsh_debug_sv.log(p_module_name,'x_param_info.process_flag',x_param_info.process_flag);
   wsh_debug_sv.log(p_module_name,'x_param_info.check_on_hand ',x_param_info.check_on_hand );
   --OTM R12
   wsh_debug_sv.log(p_module_name,'x_param_info.max_net_weight ',x_param_info.max_net_weight );
   wsh_debug_sv.log(p_module_name,'x_param_info.max_gross_weight ',x_param_info.max_gross_weight );
   --OTM R12 Org-Specific
   wsh_debug_sv.log(p_module_name,'x_param_info.otm_enabled ',x_param_info.otm_enabled );
   wsh_debug_sv.log(p_module_name,'x_param_info.dynamic_replenishment_flag ',x_param_info.dynamic_replenishment_flag ); --bug# 6689448 (replenishment project)
   wsh_debug_sv.log(p_module_name,'x_param_info.dock_appt_scheduling_flag ',x_param_info.dock_appt_scheduling_flag ); --bug 6700792: OTM Dock Door App Sched Proj
   wsh_debug_sv.log(p_module_name,'x_param_info.retain_nonstaged_det_flag ',x_param_info.retain_nonstaged_det_flag ); --Bug 7131800
   -- Bug 8446283
   wsh_debug_sv.log(p_module_name,'x_param_info.weight_uom_code ',x_param_info.weight_uom_code);
   wsh_debug_sv.log(p_module_name,'x_param_info.volume_uom_code ',x_param_info.volume_uom_code);
   -- Bug 8446283
 End If;

 If p_print_info = 'WSH_SHIPPING_PARAMETER_VALUES'  OR p_print_info = 'ALL' then
   wsh_debug_sv.log(p_module_name,'x_param_value_info.organization_id',x_param_value_info.organization_id);
   wsh_debug_sv.log(p_module_name,'x_param_value_info.param_name.COUNT',x_param_value_info.param_name.COUNT);
   If x_param_value_info.param_name.COUNT > 0 then
     For i in x_param_value_info.param_name.FIRST..x_param_value_info.param_name.LAST
     Loop
        if x_param_value_info.class_code.count >= i then
           wsh_debug_sv.log(p_module_name,'x_param_value_info.class_code('||i||')',x_param_value_info.class_code(i));
        Else
           wsh_debug_sv.log(p_module_name,'x_param_value_info.class_code.count = ',x_param_value_info.class_code.count);
        End If;
        If x_param_value_info.param_name.count >= i then
           wsh_debug_sv.log(p_module_name,'x_param_value_info.param_name('||i||')',x_param_value_info.param_name(i));
        Else
           wsh_debug_sv.log(p_module_name,'x_param_value_info.param_name.count = ',x_param_value_info.param_name.count);
        End If;
        If x_param_value_info.param_data_type.count >= i then
           wsh_debug_sv.log(p_module_name,'x_param_value_info.param_data_type('||i||')',x_param_value_info.param_data_type(i));
        Else
           wsh_debug_sv.log(p_module_name,'x_param_value_info.param_data_type.count = ',x_param_value_info.param_data_type.count);
        End If;
        If x_param_value_info.param_value_num.count >= i then
           wsh_debug_sv.log(p_module_name,'x_param_value_info.param_value_num('||i||')',x_param_value_info.param_value_num(i));
        Else
           wsh_debug_sv.log(p_module_name,'x_param_value_info.param_value_num.count = ',x_param_value_info.param_value_num.count);
        End If;
        If x_param_value_info.param_value_chr.count >= i then
           wsh_debug_sv.log(p_module_name,'x_param_value_info.param_value_chr('||i||')',x_param_value_info.param_value_chr(i));
        Else
           wsh_debug_sv.log(p_module_name,'x_param_value_info.param_value_chr.count = ',x_param_value_info.param_value_chr.count);
        End If;
        If x_param_value_info.param_value_date.count >= i then
           wsh_debug_sv.log(p_module_name,'x_param_value_info.param_value_date('||i||')',x_param_value_info.param_value_date(i));
        Else
           wsh_debug_sv.log(p_module_name,'x_param_value_info.param_value_date.count = ',x_param_value_info.param_value_date.count);
        End If;
     End Loop;
   End If;
 End If;

 Exception
   When others then
     wsh_debug_sv.log(l_module_name,'Exception raised from print log info. Wont affect the program flow .SQLERRM : ',sqlerrm);
End print_debug_info;


END WSH_SHIPPING_PARAMS_PVT;

/
