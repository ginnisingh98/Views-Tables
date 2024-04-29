--------------------------------------------------------
--  DDL for Package Body WSH_ACTIONS_LEVELS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_ACTIONS_LEVELS" as
/* $Header: WSHACLVB.pls 120.0.12010000.3 2009/12/04 05:54:15 mvudugul ship $ */

G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_ACTIONS_LEVELS';
--

PROCEDURE set_validation_level_on (
   p_entity			IN	VARCHAR2,
   x_return_status		OUT NOCOPY 	VARCHAR2
 ) IS

l_debug_on BOOLEAN;
 l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SET_VALIDATE_LEVEL_ON';

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
      WSH_DEBUG_SV.log(l_module_name,'p_entity',p_entity);
  END IF;
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  g_validation_level_tab(C_VALIDATE_CONSTRAINTS_LVL) := 1;

  IF (p_entity = 'DLVB' ) THEN
     g_validation_level_tab(C_ACTION_ENABLED_LVL):=1;
     g_validation_level_tab(C_LOCK_RECORDS_LVL):=1;
     g_validation_level_tab(C_DLVY_ACTION_ENABLED_LVL):=1;
     g_validation_level_tab(C_DECIMAL_QUANTITY_LVL):=1;
     g_validation_level_tab(C_GROSS_WEIGHT_LVL) := 1;
     g_validation_level_tab(C_NET_WEIGHT_LVL) := 1;
     g_validation_level_tab(C_VOLUME_LVL) :=1;
     g_validation_level_tab(C_CUSTOMER_LVL) :=1;
     g_validation_level_tab(C_SHIP_FROM_ORG_LVL) :=1;
     g_validation_level_tab(C_SHIP_TO_ORG_LVL) :=1;
     g_validation_level_tab(C_DELV_TO_ORG_LVL) :=1;
     g_validation_level_tab(C_INTMED_SHIP_ORG_LVL) :=1;
     g_validation_level_tab(C_TOL_ABOVE_LVL) :=1;
     g_validation_level_tab(C_TOL_BELOW_LVL) :=1;
     g_validation_level_tab(C_SHIP_QTY_LVL) :=1;
     g_validation_level_tab(C_CC_QTY_LVL) :=1;
-- HW Harmonization project for OPM. Added qty2
     g_validation_level_tab(C_SHIP_QTY2_LVL) :=1;
     g_validation_level_tab(C_CC_QTY2_LVL) :=1;
-- HW end of changes
     g_validation_level_tab(C_SERIAL_NUM_LVL) :=1;
     g_validation_level_tab(C_SMC_LVL) :=1;
     g_validation_level_tab(C_FREIGHT_TERMS_LVL) :=1;
     g_validation_level_tab(C_FOB_LVL) :=1;
     g_validation_level_tab(C_DEP_PLAN_LVL) :=1;
     g_validation_level_tab(C_SHIP_MOD_COMP_LVL) :=1;
     g_validation_level_tab(C_REL_STATUS_LVL) :=1;
     g_validation_level_tab(C_SUB_INV_LVL) :=1;
     g_validation_level_tab(C_REVISION_LVL) :=1;
     g_validation_level_tab(C_LOCATOR_LVL) :=1;
     g_validation_level_tab(C_LOT_NUMBER_LVL) :=1;
     g_validation_level_tab(C_SOLD_CONTACT_LVL) :=1;
     g_validation_level_tab(C_SHIP_CONTACT_LVL) :=1;
     g_validation_level_tab(C_DELIVER_CONTACT_LVL) :=1;
     g_validation_level_tab(C_INTMED_SHIP_CONTACT_LVL) :=1;
     g_validation_level_tab(C_CONT_ITEM_LVL):= 1;
     g_validation_level_tab(C_MASTER_SER_NUM_LVL):= 1;
     g_validation_level_tab(C_CONTAINER_STATUS_LVL) := 1;
     g_validation_level_tab(C_CONTAINER_ORG_LVL) := 1;
     g_validation_level_tab(C_CONT_DLVY_LVL) := 1;
     g_validation_level_tab(C_DET_INSPECT_FLAG_LVL) := 1;
     g_validation_level_tab(C_MASTER_LPN_ITEM_LVL) := 1;
     g_validation_level_tab(C_DETAIL_LPN_ITEM_LVL) := 1;
     g_validation_level_tab(C_VALIDATE_FREIGHT_CLASS_LVL) := 1;
     g_validation_level_tab(C_VALIDATE_OM_QTY_WT_VOL_LVL) := 1;
     g_validation_level_tab(C_VALIDATE_OKE_NULL_FIELDS_LVL) := 1;
     g_validation_level_tab(C_VALIDATE_OM_MIS_LVL) := 1;
     g_validation_level_tab(C_VALIDATE_OKE_MIS_LVL) := 1;
     g_validation_level_tab(C_POPULATE_ORGANIZATION_ID) := 1;
     g_validation_level_tab(C_GET_SHIP_FROM_LOC_LVL) := 1;
     g_validation_level_tab(C_GET_SHIPTO_LOC_LVL) := 1;
     g_validation_level_tab(C_GET_DELIVER_TO_LOC_LVL) := 1;
     g_validation_level_tab(C_GET_INTMED_SHIPTO_LOC_LVL) := 1;
     g_validation_level_tab(C_VALIDATE_SHIPTO_LOC_LVL) := 1;
     g_validation_level_tab(C_VALIDATE_SHIP_FROM_LOC_LVL) := 1;
     g_validation_level_tab(C_DEFAULT_FLEX_LVL) := 1;
     g_validation_level_tab(C_DEFAULT_CONTAINEER_LVL) := 1;
-- J-IB-ANVISWAN
     g_validation_level_tab(C_PO_VALIDATE_FOB_LVL) := 1;
     g_validation_level_tab(C_PO_VALIDATE_FR_TERMS_LVL) := 1;
     g_validation_level_tab(C_PO_VALIDATE_SHPTO_LOC_LVL) := 1;
     g_validation_level_tab(C_PO_VALIDATE_MAN_FIELDS_LVL) := 1;
     g_validation_level_tab(C_PO_DEFAULT_FLEX_LVL) := 1;
     g_validation_level_tab(C_PO_CHECK_ORGID_LVL) := 1;
     g_validation_level_tab(C_PO_DEFAULT_SHIPFROM_LVL) := 1;
     g_validation_level_tab(C_PO_DERIVE_DROPSHIP_LVL) := 1;
     g_validation_level_tab(C_PO_CALC_WT_VOL_LVL) := 1;
     g_validation_level_tab(C_PO_GET_OPM_QTY_LVL) := 1;
     g_validation_level_tab(C_WMS_CONTAINERS_LVL) := 1;
--lpn conv

  ELSIF (p_entity = 'DLVY' ) THEN
     g_validation_level_tab(C_ACTION_ENABLED_LVL)      := 1;
     g_validation_level_tab(C_LOCK_RECORDS_LVL)        := 1;
     g_validation_level_tab(C_DISABLED_LIST_LVL)       := 1;
     g_validation_level_tab(C_DLVY_DEFAULTS_LVL)       := 1;
     g_validation_level_tab(C_TRIP_NAME_LVL)           := 1;
     g_validation_level_tab(C_LOCATION_LVL)            := 1;
     g_validation_level_tab(C_STOP_NAME_LVL)           := 1;
     g_validation_level_tab(C_SEQ_NUM_LVL)             := 1;
-- J-Stop Sequence Change - CSUN
     g_validation_level_tab(C_PLAN_ARR_DATE_LVL)       := 1;
     g_validation_level_tab(C_CHECK_UNASSIGN_LVL)      := 1;
     g_validation_level_tab(C_DOCUMENT_SETS_LVL)       := 1;
     g_validation_level_tab(C_TRIP_STATUS_LVL)         := 1;
     g_validation_level_tab(C_DELIVERY_NAME_LVL)       := 1;
     g_validation_level_tab(C_ORGANIZATION_LVL)        := 1;
     g_validation_level_tab(C_LOADING_ORDER_LVL)       := 1;
     g_validation_level_tab(C_SHIP_FROM_LOC_LVL)       := 1;
     g_validation_level_tab(C_SHIP_TO_LOC_LVL)         := 1;
     g_validation_level_tab(C_INTMD_SHIPTO_LOC_LVL)    := 1;
     g_validation_level_tab(C_POOLED_SHIPTO_LOC_LVL)   := 1;
     g_validation_level_tab(C_DLVY_ORG_LVL)            := 1;
     g_validation_level_tab(C_FREIGHT_CARRIER_LVL)     := 1;
     g_validation_level_tab(C_FOB_LVL)                 := 1;
     g_validation_level_tab(C_FOB_LOC_LVL)             := 1;
     g_validation_level_tab(C_ROUTE_EXPORT_TXN_LVL)    := 1;
     g_validation_level_tab(C_GROSS_WEIGHT_LVL)        := 1;
     g_validation_level_tab(C_NET_WEIGHT_LVL)          := 1;
     g_validation_level_tab(C_VOLUME_LVL)              := 1;
     g_validation_level_tab(C_CUSTOMER_LVL)            := 1;
     g_validation_level_tab(C_WEIGHT_UOM_LVL)          := 1;
     g_validation_level_tab(C_VOLUME_UOM_LVL)          := 1;
     g_validation_level_tab(C_ARR_DEP_DATES_LVL)       := 1;
     g_validation_level_tab(C_CURRENCY_LVL)            := 1;
     g_validation_level_tab(C_NUMBER_OF_LPN_LVL)       := 1;
     g_validation_level_tab(C_FREIGHT_TERMS_LVL)       := 1;
     g_validation_level_tab(C_DERIVE_DELIVERY_UOM_LVL) := 1;
     g_validation_level_tab(C_PRINT_LABEL_LVL)         := 1;
     g_validation_level_tab(C_CLIENT_LVL)              := 1; -- LSP PROJECT

  ELSIF (p_entity = 'STOP' ) THEN
     g_validation_level_tab(C_ACTION_ENABLED_LVL)    :=1;
     g_validation_level_tab(C_LOCK_RECORDS_LVL)      :=1;
     g_validation_level_tab(C_TRIP_NAME_LVL)         :=1;
     g_validation_level_tab(C_LOCATION_LVL)          :=1;
     g_validation_level_tab(C_STOP_NAME_LVL)         :=1;
     g_validation_level_tab(C_TRIP_STOP_VALIDATION_LVL)       :=1;
     g_validation_level_tab(C_STOP_DEFAULTS_LVL)              :=1;
     g_validation_level_tab(C_DOCUMENT_SETS_LVL)     :=1;
     g_validation_level_tab(C_CHK_UPDATE_STATUS_LVL)     :=1;
     g_validation_level_tab(C_TRIP_STATUS_LVL)    :=1;
     g_validation_level_tab(C_PLANNED_TRIP_LVL)    :=1;
     g_validation_level_tab(C_WEIGHT_UOM_LVL)    :=1;
     g_validation_level_tab(C_VOLUME_UOM_LVL)    :=1;
     g_validation_level_tab(C_ARR_DEP_DATES_LVL)    :=1;
     g_validation_level_tab(C_DISABLED_LIST_LVL)    :=1;
     g_validation_level_tab(C_SEQ_NUM_LVL) :=1;
  -- J-Stop Sequence Change - CSUN
     g_validation_level_tab(C_PLAN_ARR_DATE_LVL)       := 1;
     g_validation_level_tab(C_PRINT_LABEL_LVL)   := 1;
     g_validation_level_tab(C_CREATE_MIXED_STOP_LVL)  := 1;
  ELSIF (p_entity = 'TRIP' ) THEN
     g_validation_level_tab(C_ACTION_ENABLED_LVL)   :=1;
     g_validation_level_tab(C_LOCK_RECORDS_LVL)             :=1;
     g_validation_level_tab(C_TRIP_NAME_LVL)                :=1;
     g_validation_level_tab(C_TRIP_STOP_VALIDATION_LVL)     :=1;
     g_validation_level_tab(C_DOCUMENT_SETS_LVL)    :=1;
     g_validation_level_tab(C_TRIP_STATUS_LVL)    :=1;
     g_validation_level_tab(C_DISABLED_LIST_LVL)    :=1;
     g_validation_level_tab(C_ARR_AFTER_TRIP_LVL)   :=1;
     g_validation_level_tab(C_VEH_ORG_LVL)    :=1;
     g_validation_level_tab(C_TRIP_MOT_LVL)    :=1;
     g_validation_level_tab(C_SERVICE_LVL)    :=1;
     g_validation_level_tab(C_CARRIER_LVL)    :=1;
     g_validation_level_tab(C_VEH_ITEM_LVL)    :=1;
     g_validation_level_tab(C_CONSOL_ALLW_LVL)    :=1;
     g_validation_level_tab(C_TRIP_SMC_LVL)                :=1;
     g_validation_level_tab(C_FREIGHT_CARRIER_LVL)  := 1;
     g_validation_level_tab(C_FREIGHT_TERMS_LVL) :=1;
     g_validation_level_tab(C_TRIP_CONFIRM_DEFAULT_LVL)  := 1;
     g_validation_level_tab(C_CREATE_MIXED_TRIP_LVL)  := 1;
  ELSIF (p_entity = 'DLEG' ) THEN
     g_validation_level_tab(C_ACTION_ENABLED_LVL)   :=1;
     g_validation_level_tab(C_LOCK_RECORDS_LVL)             :=1;
     g_validation_level_tab(C_TRIP_SMC_LVL)                :=1;
     g_validation_level_tab(C_BOL_NUM_LVL)     :=1;
  ELSIF (p_entity = 'FRST' ) THEN
     g_validation_level_tab(C_FREIGHT_COST_TYPE_LVL)   :=1;
     g_validation_level_tab(C_FREIGHT_UNIT_AMT_LVL)    :=1;
     g_validation_level_tab(C_FREIGHT_CONV_RATE_LVL)   :=1;
     g_validation_level_tab(C_FREIGHT_CURR_CODE_LVL)   :=1;
     g_validation_level_tab(C_PARENT_ENTITY_LVL)       :=1;
     g_validation_level_tab(C_ACTION_ENABLED_LVL)      :=1;  -- J-IB-JCKWOK
  ELSE
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  END IF;

  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
 WHEN OTHERS THEN
   IF l_debug_on THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                          SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
   END IF;

END set_validation_level_on;


PROCEDURE set_validation_level_off(
   p_entity			IN	VARCHAR2,
   x_return_status		OUT NOCOPY 	VARCHAR2
 ) IS

l_debug_on BOOLEAN;
 l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SET_VALIDATE_LEVEL_OFF';

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
      WSH_DEBUG_SV.log(l_module_name,'p_entity',p_entity);
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

     --Turning off the common validation levels first
     g_validation_level_tab(C_ACTION_ENABLED_LVL):=0;
     g_validation_level_tab(C_LOCK_RECORDS_LVL):=0;
     g_validation_level_tab(C_DISABLED_LIST_LVL):=0;
     g_validation_level_tab(C_VALIDATE_CONSTRAINTS_LVL) := 0;

   -- Based on the entity , turning off the respective validation levels
  IF (p_entity = 'DLVB' ) THEN
     g_validation_level_tab(C_DLVY_ACTION_ENABLED_LVL):=0;
     g_validation_level_tab(C_DECIMAL_QUANTITY_LVL):=0;
     g_validation_level_tab(C_GROSS_WEIGHT_LVL) := 0;
     g_validation_level_tab(C_NET_WEIGHT_LVL) := 0;
     g_validation_level_tab(C_VOLUME_LVL) :=0;
     g_validation_level_tab(C_CUSTOMER_LVL) :=0;
     g_validation_level_tab(C_SHIP_FROM_ORG_LVL) :=0;
     g_validation_level_tab(C_SHIP_TO_ORG_LVL) :=0;
     g_validation_level_tab(C_DELV_TO_ORG_LVL) :=0;
     g_validation_level_tab(C_INTMED_SHIP_ORG_LVL) :=0;
     g_validation_level_tab(C_TOL_ABOVE_LVL) :=0;
     g_validation_level_tab(C_TOL_BELOW_LVL) :=0;
     g_validation_level_tab(C_SHIP_QTY_LVL) :=0;
     g_validation_level_tab(C_CC_QTY_LVL) :=0;
-- HW Harmonization project for OPM. Added qty2
     g_validation_level_tab(C_SHIP_QTY2_LVL) :=0;
     g_validation_level_tab(C_CC_QTY2_LVL) :=0;
-- HW end of changes

     g_validation_level_tab(C_SERIAL_NUM_LVL) :=0;
     g_validation_level_tab(C_SMC_LVL) :=0;
     g_validation_level_tab(C_FREIGHT_TERMS_LVL) :=0;
     g_validation_level_tab(C_FOB_LVL) :=0;
     g_validation_level_tab(C_DEP_PLAN_LVL) :=0;
     g_validation_level_tab(C_SHIP_MOD_COMP_LVL) :=0;
     g_validation_level_tab(C_REL_STATUS_LVL) :=0;
     g_validation_level_tab(C_SUB_INV_LVL) :=0;
     g_validation_level_tab(C_REVISION_LVL) :=0;
     g_validation_level_tab(C_LOCATOR_LVL) :=0;
     g_validation_level_tab(C_LOT_NUMBER_LVL) :=0;
     g_validation_level_tab(C_SOLD_CONTACT_LVL) :=0;
     g_validation_level_tab(C_SHIP_CONTACT_LVL) :=0;
     g_validation_level_tab(C_DELIVER_CONTACT_LVL) :=0;
     g_validation_level_tab(C_INTMED_SHIP_CONTACT_LVL) :=0;
     g_validation_level_tab(C_CONT_ITEM_LVL):= 0;
     g_validation_level_tab(C_MASTER_SER_NUM_LVL):= 0;
     g_validation_level_tab(C_CONTAINER_STATUS_LVL) := 0;
     g_validation_level_tab(C_CONTAINER_ORG_LVL) := 0;
     g_validation_level_tab(C_CONT_DLVY_LVL) := 0;
     g_validation_level_tab(C_DET_INSPECT_FLAG_LVL) := 0;
     g_validation_level_tab(C_MASTER_LPN_ITEM_LVL) := 0;
     g_validation_level_tab(C_DETAIL_LPN_ITEM_LVL) := 0;
     g_validation_level_tab(C_VALIDATE_FREIGHT_CLASS_LVL) := 0;
     g_validation_level_tab(C_VALIDATE_OM_QTY_WT_VOL_LVL) := 0;
     g_validation_level_tab(C_VALIDATE_OKE_NULL_FIELDS_LVL) := 0;
     g_validation_level_tab(C_VALIDATE_OM_MIS_LVL) := 0;
     g_validation_level_tab(C_VALIDATE_OKE_MIS_LVL) := 0;
     g_validation_level_tab(C_POPULATE_ORGANIZATION_ID) := 0;
     g_validation_level_tab(C_GET_SHIP_FROM_LOC_LVL) := 0;
     g_validation_level_tab(C_GET_SHIPTO_LOC_LVL) := 0;
     g_validation_level_tab(C_GET_DELIVER_TO_LOC_LVL) := 0;
     g_validation_level_tab(C_GET_INTMED_SHIPTO_LOC_LVL) := 0;
     g_validation_level_tab(C_VALIDATE_SHIPTO_LOC_LVL) := 0;
     g_validation_level_tab(C_VALIDATE_SHIP_FROM_LOC_LVL) := 0;
     g_validation_level_tab(C_DEFAULT_FLEX_LVL) := 0;
     g_validation_level_tab(C_DEFAULT_CONTAINEER_LVL) := 0;
-- J-IB-ANVISWAN
     g_validation_level_tab(C_PO_VALIDATE_FOB_LVL) := 0;
     g_validation_level_tab(C_PO_VALIDATE_FR_TERMS_LVL) := 0;
     g_validation_level_tab(C_PO_VALIDATE_SHPTO_LOC_LVL) := 0;
     g_validation_level_tab(C_PO_VALIDATE_MAN_FIELDS_LVL) := 0;
     g_validation_level_tab(C_PO_DEFAULT_FLEX_LVL) := 0;
     g_validation_level_tab(C_PO_CHECK_ORGID_LVL) := 0;
     g_validation_level_tab(C_PO_DEFAULT_SHIPFROM_LVL) := 0;
     g_validation_level_tab(C_PO_DERIVE_DROPSHIP_LVL) := 0;
     g_validation_level_tab(C_PO_CALC_WT_VOL_LVL) := 0;
     g_validation_level_tab(C_PO_GET_OPM_QTY_LVL) := 0;
     g_validation_level_tab(C_WMS_CONTAINERS_LVL) := 0;
--lpn conv

  ELSIF (p_entity = 'DLVY' ) THEN
     g_validation_level_tab(C_DLVY_DEFAULTS_LVL)       := 0;
     g_validation_level_tab(C_TRIP_NAME_LVL)           := 0;
     g_validation_level_tab(C_LOCATION_LVL)            := 0;
     g_validation_level_tab(C_STOP_NAME_LVL)           := 0;
     g_validation_level_tab(C_SEQ_NUM_LVL)             := 0;
  -- J-Stop Sequence Change - CSUN
     g_validation_level_tab(C_PLAN_ARR_DATE_LVL)       := 0;
     g_validation_level_tab(C_CHECK_UNASSIGN_LVL)      := 0;
     g_validation_level_tab(C_DOCUMENT_SETS_LVL)       := 0;
     g_validation_level_tab(C_TRIP_STATUS_LVL)         := 0;
     g_validation_level_tab(C_DELIVERY_NAME_LVL)       := 0;
     g_validation_level_tab(C_ORGANIZATION_LVL)        := 0;
     g_validation_level_tab(C_LOADING_ORDER_LVL)       := 0;
     g_validation_level_tab(C_SHIP_FROM_LOC_LVL)       := 0;
     g_validation_level_tab(C_SHIP_TO_LOC_LVL)         := 0;
     g_validation_level_tab(C_INTMD_SHIPTO_LOC_LVL)    := 0;
     g_validation_level_tab(C_POOLED_SHIPTO_LOC_LVL)   := 0;
     g_validation_level_tab(C_DLVY_ORG_LVL)            := 0;
     g_validation_level_tab(C_FREIGHT_CARRIER_LVL)     := 0;
     g_validation_level_tab(C_FOB_LVL)                 := 0;
     g_validation_level_tab(C_FOB_LOC_LVL)             := 0;
     g_validation_level_tab(C_ROUTE_EXPORT_TXN_LVL)    := 0;
     g_validation_level_tab(C_GROSS_WEIGHT_LVL)        := 0;
     g_validation_level_tab(C_NET_WEIGHT_LVL)          := 0;
     g_validation_level_tab(C_VOLUME_LVL)              := 0;
     g_validation_level_tab(C_CUSTOMER_LVL)            := 0;
     g_validation_level_tab(C_WEIGHT_UOM_LVL)          := 0;
     g_validation_level_tab(C_VOLUME_UOM_LVL)          := 0;
     g_validation_level_tab(C_ARR_DEP_DATES_LVL)       := 0;
     g_validation_level_tab(C_CURRENCY_LVL)            := 0;
     g_validation_level_tab(C_NUMBER_OF_LPN_LVL)       := 0;
     g_validation_level_tab(C_FREIGHT_TERMS_LVL)       := 0;
     g_validation_level_tab(C_DERIVE_DELIVERY_UOM_LVL) := 0;
     g_validation_level_tab(C_PRINT_LABEL_LVL)         := 0;
     g_validation_level_tab(C_LOCK_RELATED_ENTITIES_LVL) := 0; -- BUG 2684692
     g_validation_level_tab(C_CLIENT_LVL) := 0; -- LSP PROJECT
  ELSIF (p_entity = 'STOP' ) THEN
     g_validation_level_tab(C_TRIP_NAME_LVL)         :=0;
     g_validation_level_tab(C_LOCATION_LVL)          :=0;
     g_validation_level_tab(C_STOP_NAME_LVL)         :=0;
     g_validation_level_tab(C_TRIP_STOP_VALIDATION_LVL)       :=0;
     g_validation_level_tab(C_STOP_DEFAULTS_LVL)              :=0;
     g_validation_level_tab(C_DOCUMENT_SETS_LVL)     :=0;
     g_validation_level_tab(C_CHK_UPDATE_STATUS_LVL)     :=0;
     g_validation_level_tab(C_TRIP_STATUS_LVL)    :=0;
     g_validation_level_tab(C_PLANNED_TRIP_LVL)    :=0;
     g_validation_level_tab(C_WEIGHT_UOM_LVL)    :=0;
     g_validation_level_tab(C_VOLUME_UOM_LVL)    :=0;
     g_validation_level_tab(C_ARR_DEP_DATES_LVL)    :=0;
     g_validation_level_tab(C_SEQ_NUM_LVL) :=0;
  -- J-Stop Sequence Change - CSUN
     g_validation_level_tab(C_PLAN_ARR_DATE_LVL)       := 0;
     g_validation_level_tab(C_PRINT_LABEL_LVL)   := 0;
     g_validation_level_tab(C_LOCK_RELATED_ENTITIES_LVL) := 0; -- BUG 2684692
     g_validation_level_tab(C_CREATE_MIXED_STOP_LVL)  := 0;
  ELSIF (p_entity = 'TRIP' ) THEN
     g_validation_level_tab(C_TRIP_NAME_LVL)                :=0;
     g_validation_level_tab(C_TRIP_STOP_VALIDATION_LVL)     :=0;
     g_validation_level_tab(C_DOCUMENT_SETS_LVL)    :=0;
     g_validation_level_tab(C_TRIP_STATUS_LVL)    :=0;
     g_validation_level_tab(C_ARR_AFTER_TRIP_LVL)   :=0;
     g_validation_level_tab(C_VEH_ORG_LVL)    :=0;
     g_validation_level_tab(C_TRIP_MOT_LVL)    :=0;
     g_validation_level_tab(C_SERVICE_LVL)    :=0;
     g_validation_level_tab(C_CARRIER_LVL)    :=0;
     g_validation_level_tab(C_VEH_ITEM_LVL)    :=0;
     g_validation_level_tab(C_CONSOL_ALLW_LVL)    :=0;
     g_validation_level_tab(C_TRIP_SMC_LVL)    :=0;
     g_validation_level_tab(C_FREIGHT_CARRIER_LVL)  := 0;
     g_validation_level_tab(C_FREIGHT_TERMS_LVL) :=0;
     g_validation_level_tab(C_TRIP_CONFIRM_DEFAULT_LVL)  := 0;
     g_validation_level_tab(C_CREATE_MIXED_TRIP_LVL)  := 0;
  ELSIF (p_entity = 'DLEG' ) THEN
     g_validation_level_tab(C_TRIP_SMC_LVL)    :=0;
     g_validation_level_tab(C_BOL_NUM_LVL)     :=0;
  ELSIF (p_entity = 'FRST' ) THEN
     g_validation_level_tab(C_FREIGHT_COST_TYPE_LVL)   :=0;
     g_validation_level_tab(C_FREIGHT_UNIT_AMT_LVL)    :=0;
     g_validation_level_tab(C_FREIGHT_CONV_RATE_LVL)   :=0;
     g_validation_level_tab(C_FREIGHT_CURR_CODE_LVL)   :=0;
     g_validation_level_tab(C_PARENT_ENTITY_LVL)       :=0;
     g_validation_level_tab(C_ACTION_ENABLED_LVL)      :=0;  -- J-IB-JCKWOK
  ELSE
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  END IF;

  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
 WHEN OTHERS THEN
   IF l_debug_on THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                          SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
   END IF;

END set_validation_level_off;


PROCEDURE set_validation_level (
   	p_entity		IN VARCHAR2,
        p_caller                IN VARCHAR2,
        p_phase                 IN NUMBER,
        p_action                IN VARCHAR2,
        x_return_status		OUT NOCOPY 	VARCHAR2
    ) IS
l_debug_on BOOLEAN;
 l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SET_VALIDATE_LEVEL';

 error_in_validation_level_off EXCEPTION;
 l_phase	NUMBER;
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
      --
      WSH_DEBUG_SV.log(l_module_name,'p_entity',p_entity);
      WSH_DEBUG_SV.log(l_module_name,'p_caller',p_caller);
      WSH_DEBUG_SV.log(l_module_name,'p_phase',p_phase);
      WSH_DEBUG_SV.log(l_module_name,'p_action',p_action);
  END IF;

  l_phase := nvl(p_phase,1);

  set_validation_level_off(p_entity,x_return_status);
  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'set_validation_level_off x_return_status',x_return_status);
  END IF;

  IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
    raise error_in_validation_level_off;
  END IF;

  IF (p_entity = 'DLVB' ) THEN
     IF p_caller = 'WSH_FSTRX' THEN
        g_validation_level_tab(C_WMS_CONTAINERS_LVL) := 1;
        IF l_phase = 1 THEN
           g_validation_level_tab(C_ACTION_ENABLED_LVL) := 1;
           IF p_action NOT IN ('RESOLVE-EXCEPTIONS-UI','PICK-RELEASE-UI') THEN
              g_validation_level_tab(C_LOCK_RECORDS_LVL) := 1;
           END IF;
        ELSIF l_phase = 2 THEN

           IF p_action = 'ASSIGN' THEN
              g_validation_level_tab(C_DLVY_ACTION_ENABLED_LVL) := 1;
              g_validation_level_tab(C_VALIDATE_CONSTRAINTS_LVL) := 1;
           END IF;
        END IF;
      ELSIF p_caller = 'OM' THEN
          g_validation_level_tab(C_WMS_CONTAINERS_LVL) := 1;
          g_validation_level_tab(C_VALIDATE_FREIGHT_CLASS_LVL) := 1;
          g_validation_level_tab(C_VALIDATE_OM_QTY_WT_VOL_LVL) := 1;
          g_validation_level_tab(C_VALIDATE_OM_MIS_LVL) := 1;
          g_validation_level_tab(C_POPULATE_ORGANIZATION_ID) := 1;
          g_validation_level_tab(C_GET_SHIP_FROM_LOC_LVL) := 1;
          g_validation_level_tab(C_GET_SHIPTO_LOC_LVL) := 1;
          g_validation_level_tab(C_GET_DELIVER_TO_LOC_LVL) := 1;
          g_validation_level_tab(C_GET_INTMED_SHIPTO_LOC_LVL) := 1;
          g_validation_level_tab(C_DEFAULT_FLEX_LVL) := 1;
          g_validation_level_tab(C_DEFAULT_CONTAINEER_LVL) := 1;
      ELSIF p_caller = 'OKE' THEN
          g_validation_level_tab(C_WMS_CONTAINERS_LVL) := 1;
          g_validation_level_tab(C_VALIDATE_OKE_NULL_FIELDS_LVL) := 1;
          g_validation_level_tab(C_VALIDATE_OKE_MIS_LVL) := 1;
          g_validation_level_tab(C_VALIDATE_SHIPTO_LOC_LVL) := 1;
          g_validation_level_tab(C_VALIDATE_SHIP_FROM_LOC_LVL) := 1;
          g_validation_level_tab(C_DEFAULT_FLEX_LVL) := 1;
      ELSIF p_caller = 'PO' THEN
-- J-IB-ANVISWAN
          g_validation_level_tab(C_WMS_CONTAINERS_LVL) := 1;
          g_validation_level_tab(C_PO_VALIDATE_FOB_LVL) := 1;
          g_validation_level_tab(C_PO_VALIDATE_FR_TERMS_LVL) := 1;
          g_validation_level_tab(C_PO_VALIDATE_SHPTO_LOC_LVL) := 1;
          g_validation_level_tab(C_PO_VALIDATE_MAN_FIELDS_LVL) := 1;
          g_validation_level_tab(C_PO_DEFAULT_FLEX_LVL) := 1;
          g_validation_level_tab(C_PO_CHECK_ORGID_LVL) := 1;
-- Bug 3574509 : Derive Drop Ship need not be called for the
-- following action codes.
          IF p_action NOT IN  ('CANCEL_PO','FINAL_CLOSE','CLOSE_PO',
                               'CLOSE_PO_FOR_RECEIVING') THEN
             g_validation_level_tab(C_PO_DERIVE_DROPSHIP_LVL) := 1;
          END IF;
          g_validation_level_tab(C_PO_CALC_WT_VOL_LVL) := 1;
          g_validation_level_tab(C_PO_GET_OPM_QTY_LVL) := 1;
          IF p_action = 'APPROVE_PO' THEN
                g_validation_level_tab(C_PO_DEFAULT_SHIPFROM_LVL) := 1;
          END IF;

      ELSE  -- p_caller = 'PLSQL'
           g_validation_level_tab(C_ACTION_ENABLED_LVL) := 1;
           -- Bug fix 2646425
           -- Locks to be obtained for non-wshfstrx callers as well
           IF p_action <> 'CREATE' THEN
               g_validation_level_tab(C_LOCK_RECORDS_LVL) := 1;
           END IF;
           IF p_action IN ('SPLIT-LINE', 'CYCLE-COUNT') THEN
              g_validation_level_tab(C_DECIMAL_QUANTITY_LVL) := 1;
           ELSIF p_action = 'ASSIGN' and NVL(WSH_WMS_LPN_GRP.g_caller ,'PLSQL') NOT LIKE 'WMS%'THEN
              g_validation_level_tab(C_DLVY_ACTION_ENABLED_LVL) := 1;
              g_validation_level_tab(C_VALIDATE_CONSTRAINTS_LVL) := 1;
           ELSIF p_action IN('PACK', 'UNPACK') THEN
              g_validation_level_tab(C_CONTAINER_STATUS_LVL) := 1;
              g_validation_level_tab(C_CONT_DLVY_LVL) := 1;
              IF(p_caller like 'WSH%') THEN
                 g_validation_level_tab(C_CONTAINER_ORG_LVL) := 1;
              END IF;
           ELSIF p_action IN ('CREATE', 'UPDATE') THEN
              IF (p_action = 'CREATE')  THEN
                 g_validation_level_tab(C_CONTAINER_ORG_LVL) := 1;
                 IF p_caller NOT LIKE 'WMS%' THEN
                    g_validation_level_tab(C_CONT_ITEM_LVL) := 1;
                 END IF;
              END IF;

              -- Get Disabled List is called only for update
              -- For create, get_disabled_list is not called in phase I
              -- Because that would make the required fields null
              IF(p_action = 'UPDATE') THEN
                 g_validation_level_tab(C_DISABLED_LIST_LVL) := 1;
              END IF;
              IF (NVL(WSH_WMS_LPN_GRP.g_caller ,'PLSQL') NOT LIKE 'WMS%' )
               OR (p_action = 'UPDATE' ) THEN
                  g_validation_level_tab(C_WMS_CONTAINERS_LVL) := 1;
--lpn conv
              END IF;
              g_validation_level_tab(C_GROSS_WEIGHT_LVL) := 1;
              g_validation_level_tab(C_NET_WEIGHT_LVL) := 1;
              g_validation_level_tab(C_VOLUME_LVL) :=1;
              g_validation_level_tab(C_CUSTOMER_LVL) :=1;
              g_validation_level_tab(C_SHIP_FROM_ORG_LVL) :=1;
              g_validation_level_tab(C_SHIP_TO_ORG_LVL) :=1;
              g_validation_level_tab(C_DELV_TO_ORG_LVL) :=1;
              g_validation_level_tab(C_INTMED_SHIP_ORG_LVL) :=1;
              g_validation_level_tab(C_TOL_ABOVE_LVL) :=1;
              g_validation_level_tab(C_TOL_BELOW_LVL) :=1;
              g_validation_level_tab(C_SHIP_QTY_LVL) :=1;
              g_validation_level_tab(C_CC_QTY_LVL) :=1;
-- HW Hamronization project OPM. Added qty2
              g_validation_level_tab(C_SHIP_QTY2_LVL) :=1;
              g_validation_level_tab(C_CC_QTY2_LVL) :=1;
-- HW end of changes
              g_validation_level_tab(C_SERIAL_NUM_LVL) :=1;
              g_validation_level_tab(C_SMC_LVL) :=1;
              g_validation_level_tab(C_FREIGHT_TERMS_LVL) :=1;
              g_validation_level_tab(C_FOB_LVL) :=1;
              g_validation_level_tab(C_DEP_PLAN_LVL) :=1;
              g_validation_level_tab(C_SHIP_MOD_COMP_LVL) :=1;
              g_validation_level_tab(C_REL_STATUS_LVL) :=1;
              IF NVL(p_caller, 'XX') <> 'WMS_CONSOLIDATE' THEN    -- Bug 2755193 bypass validation of
                g_validation_level_tab(C_SUB_INV_LVL) :=1;        -- inv. controls for WMS subinventory transfer.
                g_validation_level_tab(C_REVISION_LVL) :=1;
                g_validation_level_tab(C_LOCATOR_LVL) :=1;
                g_validation_level_tab(C_LOT_NUMBER_LVL) :=1;
              END IF;
              g_validation_level_tab(C_SOLD_CONTACT_LVL) :=1;
              g_validation_level_tab(C_SHIP_CONTACT_LVL) :=1;
              g_validation_level_tab(C_DELIVER_CONTACT_LVL) :=1;
              g_validation_level_tab(C_INTMED_SHIP_CONTACT_LVL) :=1;
              g_validation_level_tab(C_MASTER_SER_NUM_LVL):= 1;
              g_validation_level_tab(C_DET_INSPECT_FLAG_LVL) := 1;
              g_validation_level_tab(C_MASTER_LPN_ITEM_LVL) := 1;
              g_validation_level_tab(C_DETAIL_LPN_ITEM_LVL) := 1;
           END IF;
      END IF;
      IF p_action = 'AUTOCREATE-DEL' THEN
         g_validation_level_tab(C_VALIDATE_CONSTRAINTS_LVL) := 1;
      END IF;

  ELSIF (p_entity = 'DLVY' ) THEN
     IF p_caller IN ('WSH_FSTRX', 'WSH_TRCON') THEN
        IF p_action = 'CREATE' THEN
          g_validation_level_tab(C_NUMBER_OF_LPN_LVL) := 1;
          g_validation_level_tab(C_VALIDATE_CONSTRAINTS_LVL) := 1;
        ELSIF p_action = 'UPDATE' THEN
          g_validation_level_tab(C_NUMBER_OF_LPN_LVL) := 1;
          g_validation_level_tab(C_VALIDATE_CONSTRAINTS_LVL) := 1;
        ELSIF p_action = 'CLOSE' THEN
          -- This should be turned on irrespective of the phase
          -- Reason. This would be necessary either in phase 1 or phase 2
          -- In phase 1, for cases where all base entites(deliveries) are eligible
          -- In phase 2, for cases where some base entities were not eligible
          -- and control went to form and came back to continue for eligible records
          g_validation_level_tab(C_LOCK_RELATED_ENTITIES_LVL) := 1; -- Bug 2684692
        END IF;
        IF l_phase = 1 THEN
           g_validation_level_tab(C_ACTION_ENABLED_LVL) := 1;

           IF p_action NOT IN ('PICK-RELEASE','RESOLVE-EXCEPTIONS-UI','PICK-RELEASE-UI','VIEW-STATUS-UI',
                                'TRANSACTION-HISTORY-UI','PRINT-DOC-SETS') THEN
              g_validation_level_tab(C_LOCK_RECORDS_LVL) := 1;
           END IF;

           IF p_action = 'CONFIRM' THEN
              g_validation_level_tab(C_DLVY_DEFAULTS_LVL) := 1;
              g_validation_level_tab(C_PRINT_LABEL_LVL)   := 1;
           ELSIF p_action = 'PRINT-DOC-SETS' THEN
              g_validation_level_tab(C_DOCUMENT_SETS_LVL) := 1;
           ELSIF p_action = 'UNASSIGN-TRIP' THEN
              g_validation_level_tab(C_CHECK_UNASSIGN_LVL) := 1;
           END IF;
        ELSIF l_phase = 2 THEN
           IF p_action = 'PRINT-DOC-SETS' THEN
              g_validation_level_tab(C_DOCUMENT_SETS_LVL) := 1;
           ELSIF p_action = 'UNASSIGN-TRIP' THEN
              g_validation_level_tab(C_CHECK_UNASSIGN_LVL) := 1;
           ELSIF p_action = 'CONFIRM' THEN
              g_validation_level_tab(C_PRINT_LABEL_LVL)   := 1;
              g_validation_level_tab(C_DOCUMENT_SETS_LVL) := 1;
           ELSIF p_action = 'ASSIGN-TRIP' THEN
              g_validation_level_tab(C_VALIDATE_CONSTRAINTS_LVL) := 1;
           END IF;
        END IF;
     ELSE  -- p_caller = 'PLSQL' i.e. Caller is Public API
        g_validation_level_tab(C_ACTION_ENABLED_LVL) := 1;
           -- Bug fix 2646425
           -- Locks to be obtained for non-wshfstrx callers as well
           IF p_action NOT IN ('PICK-RELEASE','PRINT-DOC-SETS', 'CREATE') THEN
              g_validation_level_tab(C_LOCK_RECORDS_LVL) := 1;
           END IF;

        IF p_action IN ('PRINT-DOC-SETS','CONFIRM') THEN
           g_validation_level_tab(C_DOCUMENT_SETS_LVL) := 1;
           -- Bug # 8561299 : Label printing should be enabled when auto ship confirming dureing pick
           -- release process or ship confirming through ship confirm deliveries SRS.
           IF p_action = 'CONFIRM' AND p_caller = 'WSH_BHPS' THEN
               g_validation_level_tab(C_PRINT_LABEL_LVL) := 1;
           END IF;
           -- Bug # 8561299 : End
        ELSIF p_action = 'CLOSE' THEN
           g_validation_level_tab(C_LOCK_RELATED_ENTITIES_LVL) := 1; -- Bug 2684692
        ELSIF p_action = 'ASSIGN-TRIP' THEN
           g_validation_level_tab(C_TRIP_NAME_LVL) := 1;
           g_validation_level_tab(C_LOCATION_LVL) := 1;
           IF (   p_caller LIKE 'FTE%'
               OR p_caller LIKE 'WSH%')
              AND (p_caller <> 'WSH_PUB') THEN
             g_validation_level_tab(C_STOP_NAME_LVL) := 0;
           ELSE
             g_validation_level_tab(C_STOP_NAME_LVL) := 1;
           END IF;
           g_validation_level_tab(C_SEQ_NUM_LVL) := 1;
  -- J-Stop Sequence Change - CSUN
           g_validation_level_tab(C_PLAN_ARR_DATE_LVL)  := 1;
           g_validation_level_tab(C_TRIP_STATUS_LVL)    :=1;
           g_validation_level_tab(C_VALIDATE_CONSTRAINTS_LVL) := 1;
        ELSIF p_action = 'UNASSIGN-TRIP' THEN
           g_validation_level_tab(C_TRIP_NAME_LVL) := 1;
           g_validation_level_tab(C_CHECK_UNASSIGN_LVL) := 1;
        ELSIF p_action IN( 'CREATE','UPDATE') THEN
           g_validation_level_tab(C_VALIDATE_CONSTRAINTS_LVL) := 1;
           g_validation_level_tab(C_DISABLED_LIST_LVL)    := 1;
           g_validation_level_tab(C_ORGANIZATION_LVL)     := 1;
           g_validation_level_tab(C_LOADING_ORDER_LVL)    := 1;
           g_validation_level_tab(C_SHIP_FROM_LOC_LVL)    := 1;
           g_validation_level_tab(C_SHIP_TO_LOC_LVL)      := 1;
           g_validation_level_tab(C_INTMD_SHIPTO_LOC_LVL) := 1;
           g_validation_level_tab(C_POOLED_SHIPTO_LOC_LVL):= 1;
           g_validation_level_tab(C_DLVY_ORG_LVL)         := 1;
           g_validation_level_tab(C_FREIGHT_CARRIER_LVL)  := 1;
           g_validation_level_tab(C_FOB_LVL)              := 1;
           g_validation_level_tab(C_FOB_LOC_LVL)          := 1;
           g_validation_level_tab(C_ROUTE_EXPORT_TXN_LVL) := 1;
           g_validation_level_tab(C_GROSS_WEIGHT_LVL)     := 1;
           g_validation_level_tab(C_NET_WEIGHT_LVL)       := 1;
           g_validation_level_tab(C_VOLUME_LVL)           := 1;
           g_validation_level_tab(C_CUSTOMER_LVL)         := 1;
           g_validation_level_tab(C_WEIGHT_UOM_LVL)       := 1;
           g_validation_level_tab(C_VOLUME_UOM_LVL)       := 1;
           g_validation_level_tab(C_ARR_DEP_DATES_LVL)    := 1;
           g_validation_level_tab(C_CURRENCY_LVL)         := 1;
           g_validation_level_tab(C_NUMBER_OF_LPN_LVL)    := 1;
           g_validation_level_tab(C_FREIGHT_TERMS_LVL)    := 1;
           g_validation_level_tab(C_CLIENT_LVL)           := 1; -- LSP PROJECT
           IF p_action = 'UPDATE' THEN
             g_validation_level_tab(C_DELIVERY_NAME_LVL)       := 1;
             g_validation_level_tab(C_DERIVE_DELIVERY_UOM_LVL) := 1;
           END IF;
        END IF;
     END IF;
     IF p_action IN ('AUTOCREATE-TRIP', 'TRIP-CONSOLIDATION') THEN
        g_validation_level_tab(C_VALIDATE_CONSTRAINTS_LVL) := 1;
     END IF;

  ELSIF (p_entity = 'STOP' ) THEN

     -- We need to turn on this validation level irrespective of
     -- the caller and phase.
     IF p_action IN ('CREATE','UPDATE') THEN
       g_validation_level_tab(C_TRIP_STOP_VALIDATION_LVL) := 1;
       g_validation_level_tab(C_VALIDATE_CONSTRAINTS_LVL) := 1;

-- J-IB-NPARIKH-{
       IF p_Action = 'CREATE'
       THEN
            g_validation_level_tab(C_CREATE_MIXED_STOP_LVL)  := 1;
       END IF;

-- J-IB-NPARIKH-}
--Bug 4027163:Constraint validations should not be done for deleting a stop as
--only those stops are considered for the delivery which are non-origin, non-destination
--pickup/drop off stops for that delivery. No other stops on the trip need to
--be validated
     --ELSIF p_action = 'DELETE'  THEN
       --g_validation_level_tab(C_VALIDATE_CONSTRAINTS_LVL) := 1;
     END IF;

     IF p_caller = 'WSH_FSTRX' THEN
        IF l_phase = 1 THEN
           g_validation_level_tab(C_ACTION_ENABLED_LVL) := 1;
           g_validation_level_tab(C_CHK_UPDATE_STATUS_LVL):=1;
           g_validation_level_tab(C_PLANNED_TRIP_LVL)    :=1;
           g_validation_level_tab(C_WEIGHT_UOM_LVL)    :=1;
           g_validation_level_tab(C_VOLUME_UOM_LVL)    :=1;
           g_validation_level_tab(C_ARR_DEP_DATES_LVL)    :=1;
           g_validation_level_tab(C_SEQ_NUM_LVL) := 1;
  -- J-Stop Sequence Change - CSUN
           g_validation_level_tab(C_PLAN_ARR_DATE_LVL)       := 1;
           IF p_action NOT IN ('PICK-RELEASE','RESOLVE-EXCEPTIONS-UI','PICK-RELEASE-UI','PRINT-DOC-SETS') THEN
              g_validation_level_tab(C_LOCK_RECORDS_LVL) := 1;
           END IF;
           IF p_action = 'PRINT-DOC-SETS' THEN
              g_validation_level_tab(C_DOCUMENT_SETS_LVL) := 1;
           END IF;
           IF p_action = 'TRIP-CONFIRM' THEN
              g_validation_level_tab(C_TRIP_CONFIRM_DEFAULT_LVL) := 1;
           END IF;
           IF p_action = 'UPDATE-STATUS' THEN
              g_validation_level_tab(C_STOP_DEFAULTS_LVL) := 1;
              g_validation_level_tab(C_TRIP_STOP_VALIDATION_LVL) := 1;
              g_validation_level_tab(C_PRINT_LABEL_LVL)   := 1;
           END IF;
        ELSIF l_phase = 2 THEN
           g_validation_level_tab(C_CHK_UPDATE_STATUS_LVL):=1;
           IF p_action = 'PRINT-DOC-SETS' THEN
              g_validation_level_tab(C_DOCUMENT_SETS_LVL) := 1;
           END IF;
           IF p_action = 'UPDATE-STATUS' THEN
              g_validation_level_tab(C_TRIP_STOP_VALIDATION_LVL) := 1;
              g_validation_level_tab(C_PRINT_LABEL_LVL)   := 1;
              g_validation_level_tab(C_LOCK_RELATED_ENTITIES_LVL) := 1; -- Bug 2684692
           END IF;
        END IF;
      ELSE  -- p_caller = 'PLSQL' i.e. Caller is Public API
           -- Bug fix 2646425
           -- Locks to be obtained for non-wshfstrx callers as well
           IF p_action NOT IN ('PICK-RELEASE','PRINT-DOC-SETS', 'CREATE') THEN
               g_validation_level_tab(C_LOCK_RECORDS_LVL) := 1;
           END IF;

        IF p_action IN ('CREATE') THEN
           g_validation_level_tab(C_TRIP_STATUS_LVL)    :=1;
        END IF;

        g_validation_level_tab(C_ACTION_ENABLED_LVL) := 1;
        g_validation_level_tab(C_TRIP_NAME_LVL) := 1;
        g_validation_level_tab(C_LOCATION_LVL) := 1;

        IF (  (   p_caller LIKE 'FTE%'
               OR p_caller LIKE 'WSH%')
            AND (p_caller <> 'WSH_PUB'))
           OR (p_action = 'CREATE')     THEN
          g_validation_level_tab(C_STOP_NAME_LVL) := 0;
        ELSE
          g_validation_level_tab(C_STOP_NAME_LVL) := 1;
        END IF;

        g_validation_level_tab(C_CHK_UPDATE_STATUS_LVL):=1;
        g_validation_level_tab(C_PLANNED_TRIP_LVL)    :=1;
        g_validation_level_tab(C_WEIGHT_UOM_LVL)    :=1;
        g_validation_level_tab(C_VOLUME_UOM_LVL)    :=1;
        g_validation_level_tab(C_ARR_DEP_DATES_LVL)    :=1;
        g_validation_level_tab(C_DISABLED_LIST_LVL)    :=1;
        g_validation_level_tab(C_SEQ_NUM_LVL) := 1;
  -- J-Stop Sequence Change - CSUN
        g_validation_level_tab(C_PLAN_ARR_DATE_LVL)       := 1;
        IF p_action = 'PRINT-DOC-SETS' THEN
           g_validation_level_tab(C_DOCUMENT_SETS_LVL) := 1;
        END IF;
        IF p_action ='UPDATE-STATUS' THEN
           g_validation_level_tab(C_TRIP_STOP_VALIDATION_LVL) := 1;
           g_validation_level_tab(C_LOCK_RELATED_ENTITIES_LVL) := 1; -- Bug 2684692
        END IF;
      END IF;

  ELSIF (p_entity = 'TRIP' ) THEN
     -- We need to turn on this validation level irrespective of
     -- the caller and phase.
     IF p_action = 'UPDATE' THEN
       g_validation_level_tab(C_TRIP_STOP_VALIDATION_LVL) := 1;
       g_validation_level_tab(C_VALIDATE_CONSTRAINTS_LVL) := 1;
     END IF;
     -- J-IB-NPARIKH-{
     IF p_action = 'CREATE' THEN
       g_validation_level_tab(C_CREATE_MIXED_TRIP_LVL)  := 1;
     END IF;
     -- J-IB-NPARIKH-}

     --TL Rating C_CONSOL_ALLW_LVL    validation moved from form to grp api.
     --independant of phase for create, update
     IF p_action IN ('CREATE', 'UPDATE') THEN
        g_validation_level_tab(C_CONSOL_ALLW_LVL)    :=1;
     END IF;
     IF p_caller = 'WSH_FSTRX' THEN
        IF l_phase = 1 THEN
           g_validation_level_tab(C_ACTION_ENABLED_LVL) := 1;
           g_validation_level_tab(C_TRIP_STATUS_LVL)    :=1;
           IF p_action NOT IN ('PICK-RELEASE','RESOLVE-EXCEPTIONS-UI','PICK-RELEASE-UI','PRINT-DOC-SETS') THEN
              g_validation_level_tab(C_LOCK_RECORDS_LVL) := 1;
           END IF;
           IF p_action = 'PRINT-DOC-SETS' THEN
              g_validation_level_tab(C_DOCUMENT_SETS_LVL) := 1;
           END IF;
           IF p_action IN ('PLAN', 'UNPLAN') THEN
              g_validation_level_tab(C_TRIP_STOP_VALIDATION_LVL) := 1;
           END IF;
           IF p_action = 'TRIP-CONFIRM' THEN
              g_validation_level_tab(C_TRIP_CONFIRM_DEFAULT_LVL) := 1;
           END IF;
        ELSIF l_phase = 2 THEN
           IF p_action = 'PRINT-DOC-SETS' THEN
              g_validation_level_tab(C_DOCUMENT_SETS_LVL) := 1;
           END IF;
           IF p_action IN ('PLAN', 'UNPLAN') THEN
              g_validation_level_tab(C_TRIP_STOP_VALIDATION_LVL) := 1;
           END IF;
           IF p_action = 'TRIP-CONFIRM' THEN
              g_validation_level_tab(C_TRIP_CONFIRM_DEFAULT_LVL) := 1;
           END IF;
        END IF;
      ELSE  -- p_caller = 'PLSQL' i.e. Caller is Public API
           -- Bug fix 2646425
           -- Locks to be obtained for non-wshfstrx callers as well
           IF p_action NOT IN ('PICK-RELEASE','PRINT-DOC-SETS', 'CREATE') THEN
               g_validation_level_tab(C_LOCK_RECORDS_LVL) := 1;
           END IF;
        g_validation_level_tab(C_ACTION_ENABLED_LVL) := 1;
        g_validation_level_tab(C_TRIP_STATUS_LVL)    :=1;
        g_validation_level_tab(C_DISABLED_LIST_LVL)    :=1;
        g_validation_level_tab(C_ARR_AFTER_TRIP_LVL)   :=1;
        g_validation_level_tab(C_VEH_ORG_LVL)    :=1;
        g_validation_level_tab(C_TRIP_MOT_LVL)    :=1;
        g_validation_level_tab(C_SERVICE_LVL)    :=1;
        g_validation_level_tab(C_CARRIER_LVL)    :=1;
        g_validation_level_tab(C_VEH_ITEM_LVL)    :=1;
        g_validation_level_tab(C_TRIP_SMC_LVL)    :=1;
        g_validation_level_tab(C_FREIGHT_CARRIER_LVL)  := 1;
        g_validation_level_tab(C_FREIGHT_TERMS_LVL) :=1;

        IF p_action <> 'CREATE' THEN
           g_validation_level_tab(C_TRIP_NAME_LVL) := 1;
        END IF;

        IF p_action = 'PRINT-DOC-SETS' THEN
           g_validation_level_tab(C_DOCUMENT_SETS_LVL) := 1;
        END IF;

        IF p_action IN ('PLAN', 'UNPLAN') THEN
           g_validation_level_tab(C_TRIP_STOP_VALIDATION_LVL) := 1;
        END IF;
        IF p_action = 'TRIP-CONFIRM' THEN
           g_validation_level_tab(C_TRIP_CONFIRM_DEFAULT_LVL) := 1;
        END IF;
      END IF;

  ELSIF (p_entity = 'DLEG' ) THEN
     IF p_caller = 'WSH_FSTRX' THEN
        IF l_phase = 1 THEN
           g_validation_level_tab(C_ACTION_ENABLED_LVL)   :=1;
           g_validation_level_tab(C_LOCK_RECORDS_LVL)     :=1;
           IF p_action = 'GENERATE-BOL' THEN
              g_validation_level_tab(C_TRIP_SMC_LVL)    :=1;
              g_validation_level_tab(C_BOL_NUM_LVL)     :=1;
           END IF;
        ELSIF l_phase = 2 THEN
           IF p_action = 'GENERATE-BOL' THEN
              g_validation_level_tab(C_TRIP_SMC_LVL)    :=1;
              g_validation_level_tab(C_BOL_NUM_LVL)     :=1;
           END IF;
        END IF;
     END IF;
  ELSIF (p_entity = 'FRST' ) THEN
     IF p_caller <> 'WSH_FSTRX' THEN
        g_validation_level_tab(C_FREIGHT_COST_TYPE_LVL)   :=1;
        g_validation_level_tab(C_FREIGHT_UNIT_AMT_LVL)    :=1;
        g_validation_level_tab(C_FREIGHT_CONV_RATE_LVL)   :=1;
        g_validation_level_tab(C_FREIGHT_CURR_CODE_LVL)   :=1;
        g_validation_level_tab(C_PARENT_ENTITY_LVL)       :=1;
        g_validation_level_tab(C_DISABLED_LIST_LVL)    :=1;
        g_validation_level_tab(C_ACTION_ENABLED_LVL)      :=1;  -- J-IB-JCKWOK
     END IF;

  ELSE
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  END IF;

  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN error_in_validation_level_off THEN
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'error_in_set_validation_level_off exception has occured.',
                           WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:error_in_set_validation_level_off');
   END IF;

  WHEN OTHERS THEN
   IF l_debug_on THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                          SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
   END IF;
END set_validation_level;


END WSH_ACTIONS_LEVELS;

/
