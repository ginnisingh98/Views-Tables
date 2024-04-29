--------------------------------------------------------
--  DDL for Package Body WSH_INTERFACE_COMMON_ACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_INTERFACE_COMMON_ACTIONS" as
/* $Header: WSHINCAB.pls 120.1.12010000.7 2010/04/07 10:59:02 ueshanka ship $ */

-- this cursor will be used by Process_Non_Splits and Process_Splits procedures

-- TPW - Distributed changes
CURSOR del_det_int_cur(l_header_number NUMBER, l_detail_id NUMBER, l_dlvy_interface_id NUMBER) IS
SELECT
wddi.FREIGHT_CLASS_CAT_CODE,
wddi.HAZARD_CLASS_CODE,
wddi.INTMED_SHIP_TO_LOCATION_CODE,
wddi.ITEM_NUMBER,
wddi.LOCATOR_CODE,
wddi.MASTER_CONTAINER_ITEM_NUMBER,
wddi.ORGANIZATION_CODE,
wddi.SHIP_FROM_LOCATION_CODE,
wddi.SHIP_TO_LOCATION_CODE,
wddi.PROJECT_ID,
wddi.SEAL_CODE,
wddi.SHIP_TO_SITE_USE_ID,
wddi.SHIPPING_INSTRUCTIONS,
wddi.SOURCE_LINE_NUMBER,
wddi.TO_SERIAL_NUMBER,
wddi.TRACKING_NUMBER,
wddi.UNIT_NUMBER,
wddi.FILL_PERCENT,
wddi.FREIGHT_CLASS_CAT_ID,
wddi.INSPECTION_FLAG,
wddi.LPN_CONTENT_ID,
wddi.LPN_ID,
wddi.MASTER_SERIAL_NUMBER,
wddi.MAXIMUM_LOAD_WEIGHT,
wddi.MAXIMUM_VOLUME,
wddi.MINIMUM_FILL_PERCENT,
wddi.UNIT_PRICE,
wddi.COMMODITY_CODE_CAT_ID,
wddi.TP_ATTRIBUTE9,
wddi.TP_ATTRIBUTE10,
wddi.TP_ATTRIBUTE11,
wddi.TP_ATTRIBUTE12,
wddi.TP_ATTRIBUTE13,
wddi.TP_ATTRIBUTE14,
wddi.TP_ATTRIBUTE15,
wddi.ATTRIBUTE_CATEGORY,
wddi.ATTRIBUTE1,
wddi.ATTRIBUTE2,
wddi.ATTRIBUTE3,
wddi.ATTRIBUTE4,
wddi.ATTRIBUTE5,
wddi.ATTRIBUTE6,
wddi.ATTRIBUTE7,
wddi.ATTRIBUTE8,
wddi.ATTRIBUTE9,
wddi.ATTRIBUTE10,
wddi.ATTRIBUTE11,
wddi.ATTRIBUTE12,
wddi.ATTRIBUTE13,
wddi.ATTRIBUTE14,
wddi.ATTRIBUTE15,
wddi.CREATION_DATE,
wddi.CREATED_BY,
wddi.LAST_UPDATE_DATE,
wddi.LAST_UPDATED_BY,
wddi.LAST_UPDATE_LOGIN,
wddi.PROGRAM_APPLICATION_ID,
wddi.PROGRAM_ID,
wddi.PROGRAM_UPDATE_DATE,
wddi.REQUEST_ID,
wddi.INTERFACE_ACTION_CODE,
wddi.LOCK_FLAG,
wddi.PROCESS_FLAG,
wddi.PROCESS_MODE,
wddi.DELETE_FLAG,
wddi.PROCESS_STATUS_FLAG,
wddi.SOURCE_HEADER_NUMBER,
wddi.SOURCE_HEADER_TYPE_ID,
wddi.SOURCE_HEADER_TYPE_NAME,
wddi.CUST_PO_NUMBER,
wddi.SHIP_SET_ID,
wddi.ARRIVAL_SET_ID,
wddi.TOP_MODEL_LINE_ID,
wddi.ATO_LINE_ID,
wddi.SHIP_MODEL_COMPLETE_FLAG,
wddi.HAZARD_CLASS_ID,
wddi.CLASSIFICATION,
wddi.ORGANIZATION_ID,
wddi.SRC_REQUESTED_QUANTITY,
wddi.SRC_REQUESTED_QUANTITY_UOM,
wddi.QUALITY_CONTROL_QUANTITY,
wddi.CYCLE_COUNT_QUANTITY,
wddi.MOVE_ORDER_LINE_ID,
wddi.LOCATOR_ID,
wddi.MVT_STAT_STATUS,
wddi.TRANSACTION_TEMP_ID,
wddi.PREFERRED_GRADE,
wddi.SRC_REQUESTED_QUANTITY2,
wddi.SRC_REQUESTED_QUANTITY_UOM2,
wddi.REQUESTED_QUANTITY2,
wddi.SHIPPED_QUANTITY2,
wddi.DELIVERED_QUANTITY2,
wddi.CANCELLED_QUANTITY2,
wddi.QUALITY_CONTROL_QUANTITY2,
wddi.CYCLE_COUNT_QUANTITY2,
wddi.REQUESTED_QUANTITY_UOM2,
-- HW OPMCONV - No need for sublot_number
--wddi.SUBLOT_NUMBER,
wddi.SPLIT_FROM_DELIVERY_DETAIL_ID,
wddi.CARRIER_CODE,
wddi.COMMODITY_CODE_CAT_CODE,
wddi.CUSTOMER_NUMBER,
wddi.CUSTOMER_ITEM_NUMBER,
wddi.DELIVER_TO_LOCATION_CODE,
wddi.CUSTOMER_PRODUCTION_LINE,
wddi.DELIVER_TO_SITE_USE_ID,
wddi.MOVEMENT_ID,
wddi.ORG_ID,
wddi.ORIGINAL_SUBINVENTORY,
wddi.PACKING_INSTRUCTIONS,
wddi.PICKED_QUANTITY,
wddi.PICKED_QUANTITY2,
wddi.DELIVERY_DETAIL_INTERFACE_ID,
wddi.DELIVERY_DETAIL_ID,
wddi.SOURCE_CODE,
wddi.SOURCE_HEADER_ID,
wddi.SOURCE_LINE_ID,
wddi.CUSTOMER_ID,
wddi.SOLD_TO_CONTACT_ID,
wddi.INVENTORY_ITEM_ID,
wddi.ITEM_DESCRIPTION,
wddi.COUNTRY_OF_ORIGIN,
wddi.SHIP_FROM_LOCATION_ID,
wddi.SHIP_TO_LOCATION_ID,
wddi.SHIP_TO_CONTACT_ID,
wddi.DELIVER_TO_LOCATION_ID,
wddi.DELIVER_TO_CONTACT_ID,
wddi.INTMED_SHIP_TO_LOCATION_ID,
wddi.INTMED_SHIP_TO_CONTACT_ID,
wddi.SHIP_TOLERANCE_ABOVE,
wddi.SHIP_TOLERANCE_BELOW,
wddi.REQUESTED_QUANTITY,
wddi.CANCELLED_QUANTITY,
wddi.SHIPPED_QUANTITY,
wddi.DELIVERED_QUANTITY,
wddi.REQUESTED_QUANTITY_UOM,
wddi.SHIPPING_QUANTITY_UOM,
wddi.SUBINVENTORY,
wddi.REVISION,
wddi.LOT_NUMBER,
wddi.CUSTOMER_REQUESTED_LOT_FLAG,
wddi.SERIAL_NUMBER,
wddi.DATE_REQUESTED,
wddi.DATE_SCHEDULED,
wddi.MASTER_CONTAINER_ITEM_ID,
wddi.DETAIL_CONTAINER_ITEM_ID,
wddi.LOAD_SEQ_NUMBER,
wddi.SHIP_METHOD_CODE,
wddi.CARRIER_ID,
wddi.FREIGHT_TERMS_CODE,
wddi.SHIPMENT_PRIORITY_CODE,
wddi.FOB_CODE,
wddi.CUSTOMER_ITEM_ID,
wddi.DEP_PLAN_REQUIRED_FLAG,
wddi.CUSTOMER_PROD_SEQ,
wddi.CUSTOMER_DOCK_CODE,
wddi.GROSS_WEIGHT,
wddi.NET_WEIGHT,
wddi.WEIGHT_UOM_CODE,
wddi.VOLUME,
wddi.VOLUME_UOM_CODE,
wddi.TP_ATTRIBUTE_CATEGORY,
wddi.TP_ATTRIBUTE1,
wddi.TP_ATTRIBUTE2,
wddi.TP_ATTRIBUTE3,
wddi.TP_ATTRIBUTE4,
wddi.TP_ATTRIBUTE5,
wddi.TP_ATTRIBUTE6,
wddi.TP_ATTRIBUTE7,
wddi.TP_ATTRIBUTE8,
wddi.DETAIL_CONTAINER_ITEM_CODE,
wddi.TASK_ID,
wddi.CUSTOMER_JOB,
wddi.CONTAINER_FLAG,
wddi.CONTAINER_NAME,
wddi.CONTAINER_TYPE_CODE,
wddi.CURRENCY_CODE,
wddi.CUST_MODEL_SERIAL_NUMBER,
-- J: W/V Changes
wddi.filled_volume,
wddi.wv_frozen_flag,
--Bug 3458160
wddi.LINE_DIRECTION,
wddi.REQUEST_DATE_TYPE_CODE,
wddi.EARLIEST_PICKUP_DATE   ,
wddi.LATEST_PICKUP_DATE     ,
wddi.EARLIEST_DROPOFF_DATE ,
wddi.LATEST_DROPOFF_DATE
FROM wsh_del_details_interface wddi,
wsh_del_assgn_interface wdai
WHERE wddi.delivery_detail_id= nvl(l_detail_id, wddi.delivery_detail_id)
-- TPW - Distributed changes
AND nvl(wddi.source_header_number,'-99') = nvl(l_header_number, nvl(wddi.source_header_number,'-99'))
AND wddi.delivery_detail_interface_id = wdai.delivery_detail_interface_id
AND wdai.delivery_interface_id= l_dlvy_interface_id
AND WDDI.INTERFACE_ACTION_CODE = '94X_INBOUND'
AND WDAI.INTERFACE_ACTION_CODE = '94X_INBOUND'
ORDER BY wddi.delivery_detail_id, wddi.source_line_id;


-- forward declaration
--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_INTERFACE_COMMON_ACTIONS';
--
PROCEDURE Add_To_Update_Table(
	 p_del_det_int_rec 	IN del_det_int_cur%ROWTYPE,
	 p_update_mode		IN VARCHAR2 DEFAULT 'UPDATE',
	 p_delivery_id		IN NUMBER,
	 x_return_status	OUT NOCOPY  VARCHAR2);


PROCEDURE log_errors(
		p_loc_interface_errors_rec IN WSH_INTERFACE_VALIDATIONS_PKG.interface_errors_rec_type,
      		p_msg_data                 IN VARCHAR2 DEFAULT NULL,
    		p_api_name                 IN VARCHAR2,
		x_return_status OUT NOCOPY  VARCHAR2);

PROCEDURE split_delivery_detail(
   p_delivery_detail_id   IN              NUMBER,
   p_qty_to_split         IN              NUMBER,
   x_new_detail_id        OUT NOCOPY      NUMBER,
   x_return_status        OUT NOCOPY      VARCHAR2
);

PROCEDURE add_to_serial_table(
   p_serial_range_tab     IN  WSH_GLBL_VAR_STRCT_GRP.ddSerialRangeTabType);


PROCEDURE Update_Delivery_Details(
	p_source_code	        IN VARCHAR2 DEFAULT 'OE',
	p_delivery_interface_id IN NUMBER DEFAULT NULL,
	p_action_code           IN VARCHAR2,
	x_return_status         OUT NOCOPY  VARCHAR2);

-- TPW - Distributed changes
PROCEDURE Lock_Delivery_Details(
        p_delivery_interface_id IN         NUMBER,
        x_return_status         OUT NOCOPY VARCHAR2);

/*
-----------------------------------------------------------------------------
   PROCEDURE  : Update_Contnr_Int_Assignments
   PARAMETERS : p_parent_delivery_detail_id
		p_parent_detail_interface_id
		x_return_status - return status of API
  DESCRIPTION :
- This procedure is called in the Inbound Map, to relate the SHIPITEM records
with the SHIPUNIT/CONTAINER records through the parent_detail_interface_id.
- This procedure updates the wsh_del_assgn_interface table.
- This takes the parent_delivery_detail_id and parent_detail_interface_id.
- For those records which have parent_delivery_detail_id is equal to the
parameter value, the parent_detail_interface_id is updated with the give
value.


------------------------------------------------------------------------------
*/


PROCEDURE Update_Contnr_Int_Assignments(
	p_parent_delivery_detail_id 	IN NUMBER,
	p_parent_detail_interface_id  	IN NUMBER,
	x_return_status 		OUT NOCOPY  VARCHAR2) IS

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_CONTNR_INT_ASSIGNMENTS';
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
	wsh_debug_sv.push(l_module_name, 'Update_Contnr_Int_Assignments');
	wsh_debug_sv.log (l_module_name,'parent_delivery_detail_id ',p_parent_delivery_detail_id);
    	wsh_debug_sv.log (l_module_name,'parent_detail_interface_id ',p_parent_detail_interface_id);
      END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	UPDATE wsh_del_assgn_interface
	SET parent_detail_interface_id = p_parent_detail_interface_id
	WHERE parent_delivery_detail_id = p_parent_delivery_detail_id;

	IF (SQL%NOTFOUND) THEN
		NULL;
		-- need to check with anil
	END IF;

      IF l_debug_on THEN
	wsh_debug_sv.pop(l_module_name);
      END IF;

EXCEPTION

WHEN Others THEN

        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
END Update_Contnr_Int_Assignments;

/*
-----------------------------------------------------------------------------
   PROCEDURE  : Process_Interfaced_Del_Details
   PARAMETERS : p_del_detail_interface_id
		p_del_detail_id
		p_action_code	- Action code 'CREATE' or 'UPDATE'
		x_del_detail_id - Delivery_Detail_ID of the detail created
				- using Create_Shipment_Lines api
		x_return_status - return status of API
  DESCRIPTION :
- This procedure is used to process the delivery details in the wsh_del_details_interface
table.
- If the action is CREATE, then we take the interface record columns and call
the 'Create_Shipment_Lines' api.
- If the action is UPDATE, then we do the following:
-- Do count(*) of the records for the given delivery_detail_id (p_del_detail_id)
-- If the count=1, then we take the interface record columns and call
	   Update_Shipping_Attributes
-- If the count>1, then we have multiple delivery detail records in the interface
table for one record in the base table.
	-- Base records need to be split before the update. So we split the base
	   table record based on the quantities in the interface table records
	-- After every split, we call Update_Shipping_Attributes to update the
	   newly created base record with the corresponding interface record values
-- If the interface delivery detail is packed, then we do the following:
	-- create container instance in base tables using the container inv.item
	-- pack the base records into the newly created container instances.
------------------------------------------------------------------------------
*/


PROCEDURE Process_Interfaced_Del_Details(
	p_delivery_interface_id		IN NUMBER,
	p_delivery_id			IN NUMBER,
	p_new_delivery_id		IN NUMBER,
	p_action_code			IN VARCHAR2,
	x_return_status 		OUT NOCOPY  VARCHAR2) IS

-- procedure specific variables
-- TPW - Distributed changes - Starts
l_detail_tab       WSH_UTIL_CORE.id_tab_type;
l_organization_tab WSH_UTIL_CORE.id_tab_type;
l_wf_rs            VARCHAR2(1);
l_dbi_rs           VARCHAR2(1);
-- TPW - Distributed changes - Ends
l_return_status 	VARCHAR2(30);

-- exceptions
invalid_action_code 		exception;
invalid_input			exception;
-- TPW - Distributed changes
others_dbi                      exception;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PROCESS_INTERFACED_DEL_DETAILS';
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
	wsh_debug_sv.push(l_module_name, 'Process_Interfaced_Del_Details');
	wsh_debug_sv.log (l_module_name, 'Delivery Interface Id',p_delivery_interface_id);
	wsh_debug_sv.log (l_module_name,'Delivery Id', p_delivery_id);
	wsh_debug_sv.log (l_module_name,'New Delivery Id', p_new_delivery_id);
    	wsh_debug_sv.log (l_module_name,'Action Code ',p_action_code);
      END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	IF(p_delivery_interface_id IS NULL) THEN
		raise invalid_input;
	END IF;

	IF (p_action_code = 'UPDATE' and p_delivery_id IS NULL) THEN
		raise invalid_input;
	END IF;

	IF (p_action_code = 'CREATE' and p_new_delivery_id IS NULL) THEN
		raise invalid_input;
	END IF;

	Process_Non_Splits(
		p_delivery_interface_id	=> p_delivery_interface_id,
		p_delivery_id		=> p_delivery_id,
		p_new_delivery_id	=> p_new_delivery_id,
		p_action_code		=> p_action_code,
		x_return_status		=> l_return_status);

        IF l_debug_on THEN
	 wsh_debug_sv.log (l_module_name, 'Return Status from Process_Non_Splits', l_return_status);
	END IF;

	IF(l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	END IF;

	IF(p_action_code = 'UPDATE') THEN
		Process_Splits(
			p_delivery_interface_id	=> 	p_delivery_interface_id,
			p_delivery_id		=> 	p_delivery_id,
			x_return_status		=>	l_return_status);
	END IF;

        IF l_debug_on THEN
	 wsh_debug_sv.log (l_module_name, 'Return Status from Process Splits', l_return_status);
	END IF;

	IF(l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	END IF;

        -- TPW - Distributed changes - Start
        IF (nvl(WSH_INBOUND_SHIP_ADVICE_PKG.G_WAREHOUSE_TYPE, '!') in ( 'TPW', 'TW2')) THEN

           UPDATE wsh_delivery_details
           SET released_status = 'Y'
           WHERE delivery_detail_id IN (
                   SELECT delivery_detail_id
                   FROM wsh_delivery_assignments
                   WHERE delivery_id = p_delivery_id)
           AND released_status IN ('R', 'B', 'X')
           AND container_flag = 'N'
           RETURNING delivery_detail_id, organization_id BULK COLLECT INTO l_detail_tab, l_organization_tab; -- Added for TPW - Distributed changes;

           -- TPW - Distributed changes - Starts
           -- Moved above update statement from api WSH_INBOUND_SHIP_ADVICE_PKG.Process_Ship_Advice,
           -- as part of TPW - Distribution changes, however missed including call to Raise Business
           -- Event and DBI API in earlier version
           --Raise Event : Pick To Pod Workflow
           IF l_detail_tab.count > 0 THEN -- {
              FOR i in l_detail_tab.first .. l_detail_tab.last LOOP
                 WSH_WF_STD.Raise_Event(
                            p_entity_type => 'Line',
                            p_entity_id => l_detail_tab(i) ,
                            p_event => 'oracle.apps.wsh.line.gen.staged' ,
                            --p_parameters IN wf_parameter_list_t DEFAULT NULL,
                            p_organization_id => l_organization_tab(i),
                            x_return_status => l_wf_rs ) ;
                 --Error Handling to be done in WSH_WF_STD.Raise_Event itself
                 IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name,'Current Time is ',SYSDATE);
                     WSH_DEBUG_SV.log(l_module_name,'Delivery Detail Id is  ',l_detail_tab(i) );
                     wsh_debug_sv.log(l_module_name,'Return Status After Calling WSH_WF_STD.Raise_Event',l_wf_rs);
                 END IF;
              END LOOP;
           END IF; -- }
           --Done Raise Event: Pick To Pod Workflow
           --
           -- DBI Project
           -- Update of wsh_delivery_details where requested_quantity/released_status
           -- are changed, call DBI API after the update.
           -- This API will also check for DBI Installed or not
           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Detail Count-',l_detail_tab.count);
           END IF;
           WSH_INTEGRATION.DBI_Update_Detail_Log(
                 p_delivery_detail_id_tab => l_detail_tab,
                 p_dml_type               => 'UPDATE',
                 x_return_status          => l_dbi_rs);
           --
           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
           END IF;
           IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
              -- just pass this return status to caller API
              -- this is a pre-defined exception handled in parent EXCEPTIONS block
              -- x_return_status is set as Unexpected in exceptions handler
              RAISE others_dbi;
           END IF;
           -- treat all other return status as Success
           -- End of Code for DBI Project
           --
           -- TPW - Distributed changes - Ends
        END IF;

        IF (nvl(WSH_INBOUND_SHIP_ADVICE_PKG.G_WAREHOUSE_TYPE, '!') in ( 'TPW', 'TW2', 'CMS')) THEN
           update wsh_new_deliveries
           set status_code ='SA'
           where delivery_id = p_delivery_id
           and status_code IN ('OP','SR','SC');
        END IF;
	 -- TPW - Distributed changes - End

	IF(l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	END IF;

        IF l_debug_on THEN
	 wsh_debug_sv.log (l_module_name, 'Packing Table Count', G_Packing_Detail_Tab.count);
	END IF;
	IF(G_Packing_Detail_Tab.count > 0) THEN
		Pack_Lines(
			x_return_status	=> l_return_status);

                IF l_debug_on THEN
		 wsh_debug_sv.log (l_module_name, 'Return Status from Pack Lines', l_return_status);
		END IF;

		IF(l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
			x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		END IF;
	END IF;

	Update_Delivery_Details(
		p_delivery_interface_id => p_delivery_interface_id,
		p_action_code           => p_action_code,
		x_return_status	=> l_return_status);

        IF l_debug_on THEN
	 wsh_debug_sv.log (l_module_name, 'Return Status from Update Del Details', l_return_status);
	END IF;

        -- TPW - Distributed changes - Inv. Rsv API Integration Changes
        -- Identified during Inventory Integration testing
        -- Handling Return status of API Update_Delivery_Details
        IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        END IF;

        IF l_debug_on THEN
	 wsh_debug_sv.pop(l_module_name);
	END IF;

EXCEPTION
WHEN invalid_action_code THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'invalid_action_code exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:invalid_action_code');
        END IF;
WHEN invalid_input THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'invalid_input exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:invalid_input');
        END IF;
-- TPW - Distributed changes
WHEN others_dbi THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'others_dbi exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:others_dbi');
        END IF;
WHEN Others THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
END Process_Interfaced_Del_Details;


PROCEDURE Process_Non_Splits(
		p_delivery_interface_id	IN NUMBER,
		p_delivery_id		IN NUMBER,
		p_new_delivery_id	IN NUMBER,
		p_action_code		IN VARCHAR2,
		x_return_status		OUT NOCOPY  VARCHAR2) IS
-- local variables
l_new_del_detail_id 	NUMBER;
l_new_detail_ids	WSH_UTIL_CORE.Id_Tab_Type;
l_table_count		NUMBER;
l_return_status		VARCHAR2(30);

l_del_details_info 	WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type;
-- Patchset I: Harmonization Project
   l_detail_info_tab        WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type;
   l_api_version NUMBER := 1.0;
   l_detail_in_rec  WSH_GLBL_VAR_STRCT_GRP.detailInRecType;
   l_detail_out_rec WSH_GLBL_VAR_STRCT_GRP.detailOutRecType;
   l_index NUMBER;
-- End Patchset I: Harmonization Project


l_delivery_id		NUMBER;
l_delivery_name		NUMBER;

l_cont_inst_exists	NUMBER;
l_cont_instance_id 	NUMBER;
l_cont_name 		VARCHAR2(30);
l_row_id		VARCHAR2(30);
l_det_freight_costs	NUMBER;

l_pickable_flag		VARCHAR2(1);
-- J: W/V Changes
l_unit_weight           NUMBER;
l_unit_volume           NUMBER;

-- public api variables
l_init_msg_list 	VARCHAR2(30) := NULL;
l_msg_count 		NUMBER;
l_msg_data 		VARCHAR2(3000);
l_commit 		VARCHAR2(1);
l_validation_level	NUMBER;

-- cursors
-- TPW - Distributed changes
CURSOR detail_ids_cur IS
SELECT count(*),
       wddi.source_header_number,
       wdai.delivery_detail_id,
       decode(wddi.container_flag, 'Y', wdai.parent_delivery_detail_id,null) parent_delivery_detail_id,
       wddi.container_flag
FROM   wsh_del_assgn_interface wdai, wsh_del_details_interface wddi
WHERE  wdai.delivery_interface_id = p_delivery_interface_id
AND    wdai.delivery_detail_interface_id = wddi.delivery_detail_interface_id
AND    WDAI.INTERFACE_ACTION_CODE = '94X_INBOUND'
AND    WDDI.INTERFACE_ACTION_CODE = '94X_INBOUND'
GROUP  BY wddi.source_header_number,
       wdai.delivery_detail_id,
       decode(wddi.container_flag, 'Y', wdai.parent_delivery_detail_id,null),
       wddi.container_flag
HAVING count(*) = 1
ORDER  BY wddi.container_flag desc,
       decode(wddi.container_flag, 'Y', wdai.parent_delivery_detail_id,null) desc nulls first;

CURSOR cont_inst_exists(l_del_det_id NUMBER) IS
SELECT count(*)
FROM wsh_delivery_details wdd, wsh_delivery_assignments_v wda
WHERE wdd.source_line_id = l_del_det_id
AND wdd.source_code = 'WSH'
AND wdd.container_flag = 'Y'
AND wdd.delivery_detail_id = wda.delivery_detail_id
AND wda.delivery_id = p_delivery_id; -- check this

CURSOR c_specific_item_info(	p_inventory_item_id NUMBER,
				p_organization_id NUMBER)
IS
SELECT decode(mtl_transactions_enabled_flag,'Y','Y','N'),
       -- J: W/V Changes
       unit_weight,
       unit_volume
FROM mtl_system_items m
WHERE m.inventory_item_id = p_inventory_item_id
AND   m.organization_id = p_organization_id;

--Bug fix 3658492.
CURSOR c_org_oper_unit(p_organization_id IN NUMBER) IS
SELECT to_number(org_information3)
FROM hr_organization_information
WHERE organization_id = p_organization_id
AND org_information_context = 'Accounting Information';


l_dummy VARCHAR2(10);

del_det_int_rec	del_det_int_cur%ROWTYPE;

--exceptions
invalid_input			exception;
create_lines_failed 		exception;
create_cont_instance_failed 	exception;
add_to_update_failed		exception;
new_assignment_failed		exception;
freight_cost_processing_error 	exception;
l_msg_details varchar2(2000);
l_loc_interface_error_rec WSH_INTERFACE_VALIDATIONS_PKG.interface_errors_rec_type;

-- K LPN CONV. rv
l_cont_tab wsh_util_core.id_tab_type;
l_lpn_unit_weight NUMBER;
l_lpn_unit_volume NUMBER;
l_lpn_weight_uom_code VARCHAR2(100);
l_lpn_volume_uom_code VARCHAR2(100);
-- K LPN CONV. rv
l_delivery_rec WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type;
l_shipping_param_info WSH_SHIPPING_PARAMS_PVT.Parameter_Rec_Typ;

-- TPW - Distributed changes
l_new_split_detail_id number;
l_req_qty number;
l_pending_req_qty number;
l_pending_shp_qty number;
l_curr_index      number;
l_detail_id_tab   wsh_util_core.id_tab_type;
l_detail_qty_tab  wsh_util_core.id_tab_type;
l_number_of_errors            NUMBER := 0;
l_number_of_warnings          NUMBER := 0;
l_serial_number_control       NUMBER;
-- TPW - Distributed changes

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PROCESS_NON_SPLITS';
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
	wsh_debug_sv.push(l_module_name, 'Process_Non_Splits');
	wsh_debug_sv.log (l_module_name,'Delivery Interface Id',p_delivery_interface_id);
	wsh_debug_sv.log (l_module_name,'Delivery Id', p_delivery_id);
	wsh_debug_sv.log (l_module_name, 'New Delivery Id', p_new_delivery_id);
    	wsh_debug_sv.log (l_module_name,'Action Code ',p_action_code);
      END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	IF(p_delivery_interface_id IS NULL) THEN
		raise invalid_input;
	END IF;

	IF(p_action_code = 'UPDATE') THEN
		IF (p_delivery_id IS NOT NULL) THEN
			l_delivery_id	:= p_delivery_id;
		ELSE
			raise invalid_input;
		END IF;
	ELSIF(p_action_code = 'CREATE' AND p_new_delivery_id IS NULL) THEN
			raise invalid_input;

	END IF;

	l_new_detail_ids.delete;

        IF l_debug_on THEN
	 wsh_debug_sv.logmsg(l_module_name, 'Before Looping thru details');
        END IF;

	FOR det_id IN detail_ids_cur LOOP
		/* Bug fix 2451920
		Have to clear out the variable l_cont_name
		After the first loop, the in-out parameter(x_cont_name) of create_container_instance
		populates the variable l_cont_name
		Since we don't want to use the created container name, we have to clear this variable */

		l_cont_name := NULL;


                IF l_debug_on THEN
		 wsh_debug_sv.log (l_module_name, 'Delivery Detail ID',det_id.delivery_detail_id);
                END IF;

                -- TPW - Distributed changes
		OPEN del_det_int_cur(det_id.source_header_number, det_id.delivery_detail_id, p_delivery_interface_id);
		FETCH del_det_int_cur INTO del_det_int_rec;
		CLOSE del_det_int_cur;

                IF l_debug_on THEN
 		wsh_debug_sv.log(l_module_name,'Delivery Detail Interf Id',del_det_int_rec.delivery_detail_interface_id);
                END IF;

		IF(p_action_code = 'CREATE') THEN --{

		/*
		Set l_del_details_info.released_status = X
		Because picking at TPW is not supported for patchset H
		*/

		l_del_details_info.released_status	:= 	'X';

		/*
		Set l_del_details_info.oe_interfaced_flag = X
		Because lines should not be interfaced with OM at the TPW
		*/

		l_del_details_info.oe_interfaced_flag	:= 	'X';


		/* For 940 Inbound, the next step is to create delivery details
		through the call to wsh_interface_pub.create_shipment_lines.
		This public api expects a source_header_id for the delivery details.
		We use the newly created delivery id as the source_header_id
		for the delivery details that are to be created */

		l_del_details_info.source_header_id	:= nvl(del_det_int_rec.source_header_id, p_new_delivery_id);

		l_del_details_info.source_code		:=	del_det_int_rec.source_code;
		l_del_details_info.source_line_id	:=	del_det_int_rec.source_line_id;
		l_del_details_info.org_id	:=	del_det_int_rec.org_id;

		/* create_shipment_line api needs source line number
		  we use the supplier instance's delivery detail id as the source line number
		 Inbound mapping would have populated source_line_id column with the
		supplier instance's delivery detail id */

		l_del_details_info.source_line_number	:= 	nvl(del_det_int_rec.source_line_number, del_det_int_rec.source_line_id);


		l_del_details_info.customer_id		:=	del_det_int_rec.customer_id;
		l_del_details_info.sold_to_contact_id	:=	del_det_int_rec.sold_to_contact_id;
		l_del_details_info.inventory_item_id	:=	del_det_int_rec.inventory_item_id;
		l_del_details_info.item_description	:=	del_det_int_rec.item_description;
		l_del_details_info.hazard_class_id	:=	del_det_int_rec.hazard_class_id;
		l_del_details_info.country_of_origin	:=	del_det_int_rec.country_of_origin;
		l_del_details_info.classification	:=	del_det_int_rec.classification;
		l_del_details_info.ship_from_location_id	:=	del_det_int_rec.ship_from_location_id;
		l_del_details_info.ship_to_location_id	:=	del_det_int_rec.ship_to_location_id;
		l_del_details_info.ship_to_contact_id	:=	del_det_int_rec.ship_to_contact_id;
		l_del_details_info.ship_to_site_use_id	:=	del_det_int_rec.ship_to_site_use_id;
		l_del_details_info.deliver_to_location_id	:=	del_det_int_rec.deliver_to_location_id;
		l_del_details_info.deliver_to_contact_id	:=	del_det_int_rec.deliver_to_contact_id;
		l_del_details_info.deliver_to_site_use_id	:=	del_det_int_rec.deliver_to_site_use_id;
		l_del_details_info.intmed_ship_to_location_id	:=	del_det_int_rec.intmed_ship_to_location_id;
		l_del_details_info.intmed_ship_to_contact_id	:=	del_det_int_rec.intmed_ship_to_contact_id;
--		l_del_details_info.hold_code		:=	del_det_int_rec.hold_code;
		l_del_details_info.ship_tolerance_above	:=	del_det_int_rec.ship_tolerance_above;
		l_del_details_info.ship_tolerance_below	:=	del_det_int_rec.ship_tolerance_below;
		l_del_details_info.requested_quantity	:=	del_det_int_rec.requested_quantity;
		l_del_details_info.shipped_quantity	:=	del_det_int_rec.shipped_quantity;
		l_del_details_info.delivered_quantity	:=	del_det_int_rec.delivered_quantity;
		l_del_details_info.requested_quantity_uom	:=	del_det_int_rec.requested_quantity_uom;
		l_del_details_info.subinventory		:=	del_det_int_rec.subinventory;
		l_del_details_info.revision		:=	del_det_int_rec.revision;
		l_del_details_info.lot_number		:=	del_det_int_rec.lot_number;
		l_del_details_info.customer_requested_lot_flag	:=	del_det_int_rec.customer_requested_lot_flag;
		l_del_details_info.serial_number	:=	del_det_int_rec.serial_number;
		l_del_details_info.locator_id		:=	del_det_int_rec.locator_id;
		l_del_details_info.date_requested	:=	del_det_int_rec.date_requested;
		l_del_details_info.date_scheduled	:=	del_det_int_rec.date_scheduled;
		l_del_details_info.master_container_item_id	:=	del_det_int_rec.master_container_item_id;
		l_del_details_info.detail_container_item_id	:=	del_det_int_rec.detail_container_item_id;
		l_del_details_info.load_seq_number	:=	del_det_int_rec.load_seq_number;
		l_del_details_info.ship_method_code	:=	del_det_int_rec.ship_method_code;
		l_del_details_info.carrier_id		:=	del_det_int_rec.carrier_id;
		l_del_details_info.freight_terms_code	:=	del_det_int_rec.freight_terms_code;
		l_del_details_info.shipment_priority_code	:=	del_det_int_rec.shipment_priority_code;
		l_del_details_info.fob_code		:=	del_det_int_rec.fob_code;
		l_del_details_info.customer_item_id	:=	del_det_int_rec.customer_item_id;
		l_del_details_info.dep_plan_required_flag	:=	del_det_int_rec.dep_plan_required_flag;
		l_del_details_info.customer_prod_seq	:=	del_det_int_rec.customer_prod_seq;
		l_del_details_info.customer_dock_code	:=	del_det_int_rec.customer_dock_code;
		l_del_details_info.cust_model_serial_number	:=	del_det_int_rec.cust_model_serial_number;
		l_del_details_info.customer_job 	:=	del_det_int_rec.customer_job ;
		l_del_details_info.customer_production_line	:=	del_det_int_rec.customer_production_line;
		l_del_details_info.net_weight		:=	del_det_int_rec.net_weight;
		l_del_details_info.weight_uom_code	:=	del_det_int_rec.weight_uom_code;
		l_del_details_info.volume		:=	del_det_int_rec.volume;
		l_del_details_info.volume_uom_code	:=	del_det_int_rec.volume_uom_code;
		l_del_details_info.tp_attribute_category	:=	del_det_int_rec.tp_attribute_category;
		l_del_details_info.tp_attribute1	:=	del_det_int_rec.tp_attribute1;
		l_del_details_info.tp_attribute2	:=	del_det_int_rec.tp_attribute2;
		l_del_details_info.tp_attribute3	:=	del_det_int_rec.tp_attribute3;
		l_del_details_info.tp_attribute4	:=	del_det_int_rec.tp_attribute4;
		l_del_details_info.tp_attribute5	:=	del_det_int_rec.tp_attribute5;
		l_del_details_info.tp_attribute6	:=	del_det_int_rec.tp_attribute6;
		l_del_details_info.tp_attribute7	:=	del_det_int_rec.tp_attribute7;
		l_del_details_info.tp_attribute8	:=	del_det_int_rec.tp_attribute8;
		l_del_details_info.tp_attribute9	:=	del_det_int_rec.tp_attribute9;
		l_del_details_info.tp_attribute10	:=	del_det_int_rec.tp_attribute10;
		l_del_details_info.tp_attribute11	:=	del_det_int_rec.tp_attribute11;
		l_del_details_info.tp_attribute12	:=	del_det_int_rec.tp_attribute12;
		l_del_details_info.tp_attribute13	:=	del_det_int_rec.tp_attribute13;
		l_del_details_info.tp_attribute14	:=	del_det_int_rec.tp_attribute14;
		l_del_details_info.tp_attribute15	:=	del_det_int_rec.tp_attribute15;
		l_del_details_info.attribute_category	:=	del_det_int_rec.attribute_category;
		l_del_details_info.attribute1	:=	del_det_int_rec.attribute1;
		l_del_details_info.attribute2	:=	del_det_int_rec.attribute2;
		l_del_details_info.attribute3	:=	del_det_int_rec.attribute3;
		l_del_details_info.attribute4	:=	del_det_int_rec.attribute4;
		l_del_details_info.attribute5	:=	del_det_int_rec.attribute5;
		l_del_details_info.attribute6	:=	del_det_int_rec.attribute6;
		l_del_details_info.attribute7	:=	del_det_int_rec.attribute7;
		l_del_details_info.attribute8	:=	del_det_int_rec.attribute8;
		l_del_details_info.attribute9	:=	del_det_int_rec.attribute9;
		l_del_details_info.attribute10	:=	del_det_int_rec.attribute10;
		l_del_details_info.attribute11	:=	del_det_int_rec.attribute11;
		l_del_details_info.attribute12	:=	del_det_int_rec.attribute12;
		l_del_details_info.attribute13	:=	del_det_int_rec.attribute13;
		l_del_details_info.attribute14	:=	del_det_int_rec.attribute14;
		l_del_details_info.attribute15	:=	del_det_int_rec.attribute15;

/* do we need to send the who columns for create/update ??
		l_del_details_info.created_by	:=	del_det_int_rec.created_by;
		l_del_details_info.creation_date	:=	del_det_int_rec.creation_date;
		l_del_details_info.last_update_date	:=	del_det_int_rec.last_update_date;
		l_del_details_info.last_update_login	:=	del_det_int_rec.last_update_login;
--		l_del_details_info.last_updated_by	:=	del_det_int_rec.last_updated_by;
		l_del_details_info.program_application_id	:=	del_det_int_rec.program_application_id;
		l_del_details_info.program_id		:=	del_det_int_rec.program_id;
		l_del_details_info.program_update_date	:=	del_det_int_rec.program_update_date;
		l_del_details_info.request_id		:=	del_det_int_rec.request_id;
*/
		l_del_details_info.mvt_stat_status	:=	del_det_int_rec.mvt_stat_status;

		l_del_details_info.organization_id	:=	del_det_int_rec.organization_id;
		l_del_details_info.transaction_temp_id	:=	del_det_int_rec.transaction_temp_id;
		l_del_details_info.ship_set_id		:=	del_det_int_rec.ship_set_id;
		l_del_details_info.arrival_set_id	:=	del_det_int_rec.arrival_set_id;
		l_del_details_info.ship_model_complete_flag	:=	del_det_int_rec.ship_model_complete_flag;

		l_del_details_info.top_model_line_id	:=	del_det_int_rec.top_model_line_id;
		l_del_details_info.source_header_number	:=	del_det_int_rec.source_header_number;
		l_del_details_info.source_header_type_id	:=	del_det_int_rec.source_header_type_id;
		l_del_details_info.source_header_type_name	:=	del_det_int_rec.source_header_type_name;
		l_del_details_info.cust_po_number	:=	del_det_int_rec.cust_po_number;
		l_del_details_info.ato_line_id		:=	del_det_int_rec.ato_line_id;
		l_del_details_info.src_requested_quantity	:=	del_det_int_rec.src_requested_quantity;
		l_del_details_info.src_requested_quantity_uom	:=	del_det_int_rec.src_requested_quantity_uom;
		l_del_details_info.move_order_line_id	:=	del_det_int_rec.move_order_line_id;
		l_del_details_info.cancelled_quantity	:=	del_det_int_rec.cancelled_quantity;
		l_del_details_info.quality_control_quantity	:=	del_det_int_rec.quality_control_quantity;
		l_del_details_info.cycle_count_quantity	:=	del_det_int_rec.cycle_count_quantity;
		l_del_details_info.tracking_number	:=	del_det_int_rec.tracking_number;
		l_del_details_info.movement_id		:=	del_det_int_rec.movement_id;
		l_del_details_info.shipping_instructions	:=	del_det_int_rec.shipping_instructions;
		l_del_details_info.packing_instructions	:=	del_det_int_rec.packing_instructions;
		l_del_details_info.project_id		:=	del_det_int_rec.project_id;
		l_del_details_info.task_id		:=	del_det_int_rec.task_id;

		l_del_details_info.inspection_flag	:=	del_det_int_rec.inspection_flag;
		l_del_details_info.container_flag	:=	del_det_int_rec.container_flag;
		l_del_details_info.container_type_code 	:=	del_det_int_rec.container_type_code ;

		l_del_details_info.container_name	:=	del_det_int_rec.container_name;
		l_del_details_info.fill_percent		:=	del_det_int_rec.fill_percent;
		l_del_details_info.gross_weight		:=	del_det_int_rec.gross_weight;

		l_del_details_info.master_serial_number	:=	del_det_int_rec.master_serial_number;
		l_del_details_info.maximum_load_weight	:=	del_det_int_rec.maximum_load_weight;
		l_del_details_info.maximum_volume	:=	del_det_int_rec.maximum_volume;
		l_del_details_info.minimum_fill_percent	:=	del_det_int_rec.minimum_fill_percent;
		l_del_details_info.seal_code		:=	del_det_int_rec.seal_code;
		l_del_details_info.unit_number  	:=	del_det_int_rec.unit_number  ;
		l_del_details_info.unit_price		:=	del_det_int_rec.unit_price;
		l_del_details_info.currency_code	:=	del_det_int_rec.currency_code;
		l_del_details_info.freight_class_cat_id	:=	del_det_int_rec.freight_class_cat_id;
		l_del_details_info.commodity_code_cat_id	:=	del_det_int_rec.commodity_code_cat_id;
		l_del_details_info.preferred_grade	:=	del_det_int_rec.preferred_grade;
		l_del_details_info.src_requested_quantity2	:=	del_det_int_rec.src_requested_quantity2;
		l_del_details_info.src_requested_quantity_uom2 	:=	del_det_int_rec.src_requested_quantity_uom2 ;
		l_del_details_info.requested_quantity2	:=	del_det_int_rec.requested_quantity2;
		l_del_details_info.shipped_quantity2	:=	del_det_int_rec.shipped_quantity2;
		l_del_details_info.delivered_quantity2 	:=	del_det_int_rec.delivered_quantity2 ;
		l_del_details_info.cancelled_quantity2	:=	del_det_int_rec.cancelled_quantity2;
		l_del_details_info.quality_control_quantity2	:=	del_det_int_rec.quality_control_quantity2;
		l_del_details_info.cycle_count_quantity2	:=	del_det_int_rec.cycle_count_quantity2;
		l_del_details_info.requested_quantity_uom2	:=	del_det_int_rec.requested_quantity_uom2;
-- HW OPMCONV - No need for sublot_number
--              l_del_details_info.sublot_number 	:=	del_det_int_rec.sublot_number ;
		l_del_details_info.lpn_id 		:=	del_det_int_rec.lpn_id ;
		-- bug 2399705
		-- We need to make this fix as WSHDDSHB.pls and WSHDDSPB.pls need to
		-- set inv_interfaced_flag to 'X' if pickable_flag is 'N'or NULL for WSH line.
		-- And if we do not set the pickable_flag according the item defn, inventory interface
		-- will not be run even for standard items the third party warehouse instance.
		open c_specific_item_info(p_inventory_item_id => del_det_int_rec.inventory_item_id,
					  p_organization_id   => del_det_int_rec.organization_id);
		fetch c_specific_item_info into l_pickable_flag,
                                                -- J: W/V Changes
                                                l_unit_weight,l_unit_volume;
		close c_specific_item_info;
		l_del_details_info.pickable_flag 	:=	l_pickable_flag;
                -- J: W/V Changes
		l_del_details_info.unit_weight 	        :=	l_unit_weight;
		l_del_details_info.unit_volume 	        :=	l_unit_volume;
                l_del_details_info.wv_frozen_flag       :=      del_det_int_rec.wv_frozen_flag;
		-- bug 2399705
--		l_del_details_info.pickable_flag 	:=	del_det_int_rec.pickable_flag ;
		l_del_details_info.original_subinventory 	:=	del_det_int_rec.original_subinventory ;
		l_del_details_info.to_serial_number	:=	del_det_int_rec.to_serial_number;
		l_del_details_info.picked_quantity	:=	del_det_int_rec.picked_quantity;
		l_del_details_info.picked_quantity2	:=	del_det_int_rec.picked_quantity2;
--Bug 3458160
		l_del_details_info.LINE_DIRECTION	:=	del_det_int_rec.LINE_DIRECTION;
		l_del_details_info.REQUEST_DATE_TYPE_CODE:=	del_det_int_rec.REQUEST_DATE_TYPE_CODE;
		l_del_details_info.EARLIEST_PICKUP_DATE :=	del_det_int_rec.EARLIEST_PICKUP_DATE;
		l_del_details_info.LATEST_PICKUP_DATE   :=	del_det_int_rec.LATEST_PICKUP_DATE;
		l_del_details_info.EARLIEST_DROPOFF_DATE:=	del_det_int_rec.EARLIEST_DROPOFF_DATE;
		l_del_details_info.LATEST_DROPOFF_DATE  :=	del_det_int_rec.LATEST_DROPOFF_DATE;
                IF (WSH_UTIL_CORE.GC3_IS_INSTALLED = 'N'
                  AND wsh_util_core.tp_is_installed = 'Y')
                THEN
		   l_del_details_info.ignore_for_planning  :=	'Y';
                END IF;

--{Bug 8539281
            IF l_debug_on THEN
               wsh_debug_sv.log (l_module_name, 'Organization id',l_del_details_info.organization_id);
               wsh_debug_sv.logmsg(l_module_name,'Calling program unit WSH_SHIPPING_PARAMS_PVT.GET',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

            WSH_SHIPPING_PARAMS_PVT.GET( p_organization_id => l_del_details_info.organization_id,
                                         x_param_info      => l_shipping_param_info,
                                         x_return_status   => l_return_status);

            IF l_debug_on THEN
               wsh_debug_sv.log (l_module_name, 'Return Status from WSH_SHIPPING_PARAMS_PVT.GET', l_return_status);
            END IF;

            IF(l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
               raise FND_API.G_EXC_ERROR ;
            END IF;

            --If any of the delivery grouping attribute is enabled copy the grouping attributes from delivery to delivery line
            IF (l_shipping_param_info.GROUP_BY_SHIP_METHOD_FLAG  = 'Y' or
                l_shipping_param_info.GROUP_BY_CUSTOMER_FLAG  = 'Y' or
                l_shipping_param_info.GROUP_BY_FREIGHT_TERMS_FLAG  = 'Y' or
                l_shipping_param_info.GROUP_BY_FOB_FLAG  = 'Y' or
                l_shipping_param_info.GROUP_BY_INTMED_SHIP_TO_FLAG  = 'Y') THEN
            --{
                  IF l_debug_on THEN
                     wsh_debug_sv.log (l_module_name, 'Getting the new delivery attributes-Delivery ID:',p_new_delivery_id);
                     wsh_debug_sv.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.TABLE_TO_RECORD',WSH_DEBUG_SV.C_PROC_LEVEL);
                  END IF;

                  WSH_NEW_DELIVERIES_PVT.TABLE_TO_RECORD(p_delivery_id=>p_new_delivery_id,
                                                         x_delivery_rec=>l_delivery_rec,
                                                         x_return_status=>l_return_status);

                  IF l_debug_on THEN
                     wsh_debug_sv.log (l_module_name, 'Return Status from WSH_NEW_DELIVERIES_PVT.TABLE_TO_RECORD', l_return_status);
                  END IF;

                  IF(l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                     raise FND_API.G_EXC_ERROR ;
                  END IF;

                  IF l_shipping_param_info.GROUP_BY_SHIP_METHOD_FLAG  = 'Y' THEN
                  --{
                       IF l_debug_on THEN
                          wsh_debug_sv.logmsg(l_module_name, 'Copying Ship Method attributes from delivery to delivery detail:'||
                                                             ' Carrier_id - '||to_char(l_delivery_rec.carrier_id)||' ,'||
                                                             ' service_level - '||l_delivery_rec.service_level||' ,'||
                                                             ' mode_of_transport - '||l_delivery_rec.mode_of_transport||' ,'||
                                                             ' ship_method_code - '||l_delivery_rec.ship_method_code,WSH_DEBUG_SV.C_STMT_LEVEL);
                       END IF;
                       l_del_details_info.carrier_id := l_delivery_rec.carrier_id ;
                       l_del_details_info.service_level := l_delivery_rec.service_level ;
                       l_del_details_info.mode_of_transport := l_delivery_rec.mode_of_transport ;
                       l_del_details_info.ship_method_code := l_delivery_rec.ship_method_code ;
                  --}
                  END IF;

                  IF l_shipping_param_info.GROUP_BY_CUSTOMER_FLAG  = 'Y' THEN

                       IF l_debug_on THEN
                          wsh_debug_sv.log (l_module_name, 'Copying customer_id value from delivery to delivery detail',l_delivery_rec.customer_id);
                       END IF;
                       l_del_details_info.customer_id := l_delivery_rec.customer_id ;

                  END IF;

                  IF l_shipping_param_info.GROUP_BY_FREIGHT_TERMS_FLAG  = 'Y' THEN

                       IF l_debug_on THEN
                          wsh_debug_sv.log (l_module_name, 'Copying freight_terms_code value from delivery to delivery detail',l_delivery_rec.freight_terms_code);
                       END IF;
                       l_del_details_info.freight_terms_code := l_delivery_rec.freight_terms_code ;

                  END IF;

                  IF l_shipping_param_info.GROUP_BY_FOB_FLAG  = 'Y' THEN

                       IF l_debug_on THEN
                          wsh_debug_sv.log (l_module_name, 'Copying fob_code value from delivery to delivery detail',l_delivery_rec.fob_code);
                       END IF;
                       l_del_details_info.fob_code := l_delivery_rec.fob_code ;

                  END IF;

                  IF l_shipping_param_info.GROUP_BY_INTMED_SHIP_TO_FLAG  = 'Y' THEN

                       IF l_debug_on THEN
                          wsh_debug_sv.log (l_module_name, 'Copying intmed_ship_to_location_id value from delivery to delivery detail',l_delivery_rec.intmed_ship_to_location_id);
                       END IF;
                       l_del_details_info.intmed_ship_to_location_id := l_delivery_rec.intmed_ship_to_location_id ;

                  END IF;
            --}
            END IF; --If any of the delivery grouping attribute is enabled
--}Bug 8539281

               IF l_debug_on THEN
		wsh_debug_sv.log (l_module_name, 'calling create shipment lines');
		wsh_debug_sv.log (l_module_name, 'the mandatory attributes for create shipment lines are:');
		wsh_debug_sv.log (l_module_name, 'source_code',l_del_details_info.source_code);
		wsh_debug_sv.log (l_module_name, 'Source header id',l_del_details_info.source_header_id);
		wsh_debug_sv.log (l_module_name, 'Source header number',l_del_details_info.source_header_number);
		wsh_debug_sv.log (l_module_name, 'Source line id',l_del_details_info.source_line_id);
		wsh_debug_sv.log (l_module_name, 'Source line number',l_del_details_info.source_line_number);
		wsh_debug_sv.log (l_module_name, 'Organization id',l_del_details_info.organization_id);
		wsh_debug_sv.log (l_module_name, 'Org Id', l_del_details_info.org_id);
		wsh_debug_sv.log (l_module_name, 'Requested qty', l_del_details_info.requested_quantity);
		wsh_debug_sv.log (l_module_name, 'Requested qty uom',l_del_details_info.requested_quantity_uom );
		wsh_debug_sv.log (l_module_name, 'Src req qty',l_del_details_info. src_requested_quantity);
		wsh_debug_sv.log (l_module_name, 'Src req qty uom', l_del_details_info.src_requested_quantity_uom);
		wsh_debug_sv.log (l_module_name, 'inventory item id',l_del_details_info.inventory_item_id);
		wsh_debug_sv.log (l_module_name, 'ship from loc id',l_del_details_info.ship_from_location_id);
		wsh_debug_sv.log (l_module_name, 'ship to loc id', l_del_details_info.ship_to_location_id);
		wsh_debug_sv.log (l_module_name, 'LINE_DIRECTION', l_del_details_info.LINE_DIRECTION);
		wsh_debug_sv.log (l_module_name, 'REQUEST_DATE_TYPE_CODE', l_del_details_info.REQUEST_DATE_TYPE_CODE);
		wsh_debug_sv.log (l_module_name, 'EARLIEST_PICKUP_DATE', l_del_details_info.EARLIEST_PICKUP_DATE);
		wsh_debug_sv.log (l_module_name, 'LATEST_PICKUP_DATE', l_del_details_info.LATEST_PICKUP_DATE);
		wsh_debug_sv.log (l_module_name, 'EARLIEST_DROPOFF_DATE', l_del_details_info.EARLIEST_DROPOFF_DATE);
		wsh_debug_sv.log (l_module_name, 'LATEST_DROPOFF_DATE', l_del_details_info.LATEST_DROPOFF_DATE);
               --}
               END IF;


                    /* Patchset I : Harmonization Project.
                    Calling Wrapper Group API in Interface Package */

                   l_detail_info_tab(1) := l_del_details_info;
                   l_detail_in_rec.caller := 'WSH_TPW_INBOUND';
                   l_detail_in_rec.action_code := 'CREATE';

                   WSH_INTERFACE_GRP.Create_Update_Delivery_Detail(
                      p_api_version_number	=> l_api_version,
                      p_init_msg_list          => FND_API.G_FALSE,
                      p_commit                => FND_API.G_FALSE,
                      x_return_status         => l_return_status,
                      x_msg_count             => l_msg_count,
                      x_msg_data              => l_msg_data,
                      p_detail_info_tab       => l_detail_info_tab,
                      p_IN_rec                => l_detail_in_rec,
                      x_OUT_rec               => l_detail_out_rec);

                    l_index := l_detail_out_rec.detail_ids.first;
                    l_new_del_detail_id := l_detail_out_rec.detail_ids(l_index);


                        IF l_debug_on THEN
			 wsh_debug_sv.log (l_module_name, 'Create Shipment Lines l_new_del_detail_id,l_return_status',
                                                              l_new_del_detail_id||','||l_return_status);
                        END IF;

			IF(l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN

                            l_loc_interface_error_rec.p_interface_table_name := 'WSH_NEW_DEL_INTERFACE';
                            l_loc_interface_error_rec.p_interface_id :=  p_delivery_interface_id;

                            IF l_debug_on THEN
			     wsh_debug_sv.log (l_module_name, 'Delivery Interface Id', p_delivery_interface_id);
                            END IF;

                            Log_Errors(
                                 p_loc_interface_errors_rec   => l_loc_interface_error_rec,
                                 p_msg_data      => l_msg_data,
                                 p_api_name      => 'WSH_INTERFACE_PUB.Create_Shipment_lines' ,
                                 x_return_status => l_return_status);

                               IF l_debug_on THEN
				wsh_debug_sv.log (l_module_name, 'Return status after log_errors', l_return_status);
                               END IF;
			       raise create_lines_failed;
			END IF;

			l_table_count := l_new_detail_ids.count;

			IF l_new_del_detail_id IS NOT NULL THEN
				l_new_detail_ids(l_table_count+1) := l_new_del_detail_id;
			ELSE
				raise create_lines_failed;
			END IF;
		ELSIF(p_action_code = 'UPDATE') THEN --}{
                       IF l_debug_on THEN
			wsh_debug_sv.logmsg(l_module_name,'Starting Update Action');
                       END IF;
			IF(nvl(del_det_int_rec.container_flag, 'N') = 'Y') THEN
			-- container record
			-- check if a container instance exists
			-- if it does not exist, then create a container instance using the item_id

				OPEN cont_inst_exists(del_det_int_rec.delivery_detail_id);
				FETCH cont_inst_exists INTO l_cont_inst_exists;
				CLOSE cont_inst_exists;

                                IF l_debug_on THEN
				 wsh_debug_sv.log (l_module_name, 'Container Instance Check', l_cont_inst_exists);
                                END IF;

				IF(nvl(l_cont_inst_exists, -9999) = 1) THEN
					-- Just add to the global update table.
					null;
				ELSE
				-- need to create the container instance
                                        --
                                        -- K LPN CONV. rv
                                        --
                                        WSH_CONTAINER_ACTIONS.Create_Cont_Instance_Multi(
                                          x_cont_name           => l_cont_name,
                                          p_cont_item_id        => del_det_int_rec.inventory_item_id,
                                          x_cont_instance_id    => l_cont_instance_id,
                                          p_par_detail_id       => NULL,
                                          p_organization_id     => del_det_int_rec.organization_id,
                                          p_container_type_code => del_det_int_rec.container_type_code,
                                          p_num_of_containers   => 1,
                                          x_row_id              => l_row_id,
                                          x_return_status       => l_return_status,
                                          x_cont_tab            => l_cont_tab,
                                          x_unit_weight         => l_lpn_unit_weight,
                                          x_unit_volume         => l_lpn_unit_volume,
                                          x_weight_uom_code     => l_lpn_weight_uom_code,
                                          x_volume_uom_code     => l_lpn_volume_uom_code,
                                          p_lpn_id              => NULL,
                                          p_ignore_for_planning => NULL,
                                          p_caller              => 'WSH');
                                        --
                                        --
                                        IF l_debug_on THEN
                                            WSH_DEBUG_SV.log(l_module_name,'return status',l_return_status);
                                            WSH_DEBUG_SV.log(l_module_name,'count of l_cont_tab',l_cont_tab.count);
                                        END IF;
                                        l_cont_instance_id := l_cont_tab(1);
                                        -- K LPN CONV. rv
                                        --
                                        /*
					WSH_CONTAINER_ACTIONS.Create_Container_Instance(
					  x_cont_name 		=> l_cont_name,
					  p_cont_item_id 	=> del_det_int_rec.inventory_item_id,
					  x_cont_instance_id 	=> l_cont_instance_id,
					  p_par_detail_id 	=> NULL,
					  p_organization_id 	=> del_det_int_rec.organization_id,
					  p_container_type_code => del_det_int_rec.container_type_code,
					  x_row_id 		=> l_row_id,
					  x_return_status 	=> l_return_status);

                                       IF  l_debug_on THEN
					wsh_debug_sv.log (l_module_name, 'Create_Container_Instance l_cont_instance_id,
                                                              l_return_status',l_cont_instance_id||','||l_return_status);
                                       END IF;
                                       */

					IF(l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
						raise create_cont_instance_failed;
					END IF;



					-- need to update the source_line_id of the newly created container instance
					UPDATE wsh_delivery_details
					SET source_line_id	= del_det_int_rec.delivery_detail_id
					WHERE delivery_detail_id = l_cont_instance_id;

					IF(SQL%NOTFOUND) THEN
						null;
						--need to check
					END IF;


					-- Need to update the record's delivery_detail id with the newly created
					-- delivery_detail_id. Because this record will be sent to USA for updating
					-- the newly created container instance with the data from the interface table record.
					del_det_int_rec.delivery_detail_id := l_cont_instance_id;

					-- TPW - Distributed changes
					--Add the container instance id to the list of detail ids that need assignment
					IF (nvl(WSH_INBOUND_SHIP_ADVICE_PKG.G_WAREHOUSE_TYPE, '!') = 'TW2') THEN
                                           l_new_detail_ids(l_new_detail_ids.COUNT+1) := l_cont_instance_id;
                                        END IF;

				END IF; -- if l_cont_inst_exists

                                Add_To_Update_Table(
                                    p_del_det_int_rec => del_det_int_rec,
                                    p_update_mode	  => 'UPDATE',
                                    p_delivery_id	  => l_delivery_id,
                                    x_return_status   => l_return_status);

                                IF l_debug_on THEN
                                   wsh_debug_sv.log (l_module_name, 'Add_To_Update_Table l_return_status',l_return_status);
                                END IF;

                                IF(l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                                   raise add_to_update_failed;
                                END IF;


			ELSE -- not a container, plain update
                                -- TPW - Distributed changes
                                IF l_debug_on THEN
			         wsh_debug_sv.log (l_module_name, 'in Else');
			         wsh_debug_sv.log (l_module_name, 'del_det_int_rec.source_line_id', del_det_int_rec.source_line_id);
			         wsh_debug_sv.log (l_module_name, 'del_det_int_rec.source_header_number', del_det_int_rec.source_header_number);
                                END IF;

                                IF (nvl(WSH_INBOUND_SHIP_ADVICE_PKG.G_WAREHOUSE_TYPE, '!') = 'TW2') THEN --{

                                  IF l_debug_on THEN
                                     wsh_debug_sv.logmsg(l_module_name, 'Line Direction '||del_det_int_rec.line_direction||
                                                         ' SHN '||del_det_int_rec.source_header_number||
                                                         ' Intf DDID '||del_det_int_rec.delivery_detail_id);
                                  END IF;

                                  IF (del_det_int_rec.line_direction = 'IO') THEN
                                     select wdd.delivery_detail_id, wdd.requested_quantity BULK COLLECT
                                     into   l_detail_id_tab, l_detail_qty_tab
                                     from   wsh_delivery_details wdd,
                                            oe_order_lines_all ol,
                                            po_requisition_lines_all pl,
                                            po_requisition_headers_all ph
                                     where  wdd.source_code = 'OE'
                                     and    wdd.released_status in ('R','B','X')
                                     and    wdd.source_line_id = ol.line_id
                                     and    ol.source_document_line_id = pl.requisition_line_id
                                     and    ol.source_document_id = pl.requisition_header_id
                                     and    pl.requisition_header_id = ph.requisition_header_id
                                     and    pl.line_num = del_det_int_rec.delivery_detail_id
                                     and    ph.segment1 = del_det_int_rec.source_header_number;
                                  ELSE
                                     select wdd.delivery_detail_id, wdd.requested_quantity BULK COLLECT
                                     into   l_detail_id_tab, l_detail_qty_tab
                                     from   wsh_delivery_details wdd,
                                            wsh_shipment_batches wsb,
                                            wsh_transactions_history wth
                                     where  wdd.source_code = 'OE'
                                     and    wdd.shipment_batch_id = wsb.batch_id
                                     and    wdd.shipment_line_number = del_det_int_rec.delivery_detail_id
                                     and    wsb.name = wth.entity_number
                                     and    wth.entity_type = 'BATCH'
                                     and    wth.document_direction = 'O'
                                     and    wth.document_type = 'SR'
                                     and    wth.document_number = del_det_int_rec.source_header_number
                                     and    wdd.released_status in ('R','B','X');
                                  END IF;

                                  IF l_debug_on THEN
                                     FOR i in 1..l_detail_id_tab.COUNT LOOP
                                        wsh_debug_sv.logmsg(l_module_name,'DD-id '||l_detail_id_tab(i)||' Req Qty '||l_detail_qty_tab(i));
                                     END LOOP;
                                  END IF;

                                  IF (del_det_int_rec.serial_number is not null) and (l_detail_id_tab.COUNT > 1) THEN
                                     -- Not Supported
                                     IF l_debug_on THEN
                                        wsh_debug_sv.logmsg(l_module_name,'Serial types not supported for remnant models');
                                     END IF;
                                     raise fnd_api.g_exc_error;
                                  -- Serial Number is NOT NULL
                                  ELSIF del_det_int_rec.serial_number IS NOT NULL THEN
                                     IF l_debug_on THEN
                                        wsh_debug_sv.log(l_module_name,'PNS: del_det_int_rec.inventory_item_id', del_det_int_rec.inventory_item_id);
                                        wsh_debug_sv.log(l_module_name,'PNS: del_det_int_rec.organization_id', del_det_int_rec.organization_id);
                                        wsh_debug_sv.log(l_module_name,'PNS: del_det_int_rec.serial_number', del_det_int_rec.serial_number);
                                        wsh_debug_sv.log(l_module_name,'PNS: del_det_int_rec.to_serial_number', del_det_int_rec.to_serial_number);
                                     END IF;

                                     BEGIN
                                     SELECT serial_number_control_code
                                     INTO   l_serial_number_control
                                     FROM   mtl_system_items
                                     WHERE  inventory_item_id = del_det_int_rec.inventory_item_id
                                     AND    organization_id   = del_det_int_rec.organization_id;

                                     IF l_debug_on THEN
                                        wsh_debug_sv.log(l_module_name,'PNS: l_serial_number_control', l_serial_number_control);
                                     END IF;

                                     EXCEPTION
                                     WHEN NO_DATA_FOUND THEN
                                          IF l_debug_on THEN
                                             wsh_debug_sv.logmsg(l_module_name,'PNS: Inside No-Data-Found');
                                          END IF;
                                     END;

                                     -- If item is not serial controlled then NULL out serial
                                     -- information obtained from WDDI interface table.
                                     IF nvl(l_serial_number_control, 0) = 1 THEN
                                        del_det_int_rec.serial_number    := NULL;
                                        del_det_int_rec.to_serial_number := NULL;
                                     END IF;
                                  END IF;

                                  l_pending_req_qty := del_det_int_rec.requested_quantity;
                                  l_pending_shp_qty := del_det_int_rec.shipped_quantity;
                                  l_curr_index      := 1;

                                  while (l_pending_req_qty > 0) loop --{

                                     if l_debug_on then
                                        wsh_debug_sv.logmsg(l_module_name, 'l_pending_req_qty '||l_pending_req_qty||
                                                                           ' l_pending_shp_qty '||l_pending_shp_qty);
                                        wsh_debug_sv.logmsg(l_module_name, ' l_curr_index '||l_curr_index||
                                                                           ' l_detail_id_tab(l_curr_index) '||l_detail_id_tab(l_curr_index));
                                     end if;

                                     IF (l_pending_req_qty <= l_detail_qty_tab(l_curr_index)) THEN --{
                                        split_delivery_detail(
                                          p_delivery_detail_id => l_detail_id_tab(l_curr_index),
                                          p_qty_to_split  => l_pending_req_qty,
                                          x_new_detail_id => l_new_split_detail_id,
                                          x_return_status => l_return_status);

                                        wsh_util_core.api_post_call(p_return_status => l_return_status,
                                          x_num_warnings => l_number_of_warnings,
                                          x_num_errors => l_number_of_errors);

                                        -- For the newly created base delivery detail, make updates
                                        -- Add the record with new detail id to the global table
                                        if l_debug_on then
                                          wsh_debug_sv.log(l_module_name, 'l_new_split_detail_id', l_new_split_detail_id);
                                        end if;

                                        IF (l_new_split_detail_id is not null) THEN
                                          del_det_int_rec.delivery_detail_id := l_new_split_detail_id;
                                        ELSE
                                          del_det_int_rec.delivery_detail_id := l_detail_id_tab(l_curr_index);
                                        END IF;
                                        del_det_int_rec.requested_quantity := l_pending_req_qty;
                                        del_det_int_rec.shipped_quantity   := l_pending_shp_qty;
                                        del_det_int_rec.cycle_count_quantity := null;

                                        l_pending_req_qty := 0;
                                        l_pending_shp_qty := 0;

                                     ELSE
                                        del_det_int_rec.delivery_detail_id := l_detail_id_tab(l_curr_index);
                                        del_det_int_rec.requested_quantity := l_detail_qty_tab(l_curr_index);
                                        del_det_int_rec.shipped_quantity   := l_detail_qty_tab(l_curr_index);
                                        del_det_int_rec.cycle_count_quantity := null;
                                        l_pending_req_qty := l_pending_req_qty - l_detail_qty_tab(l_curr_index);
                                        l_pending_shp_qty := l_pending_shp_qty - l_detail_qty_tab(l_curr_index);

                                        l_curr_index := l_curr_index + 1;

                                     END IF; --}

			             Add_To_Update_Table(
				        p_del_det_int_rec => del_det_int_rec,
				        p_update_mode	  => 'UPDATE',
				        p_delivery_id	  => l_delivery_id,
				        x_return_status   => l_return_status);

                                     IF l_debug_on THEN
			                wsh_debug_sv.log (l_module_name, 'Add_To_Update_Table l_return_status',l_return_status);
                                     END IF;

				     IF(l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
					raise add_to_update_failed;
                                     END IF;

                                     l_new_detail_ids(l_new_detail_ids.COUNT+1) := del_det_int_rec.delivery_detail_id;
                                end loop; --}
                              ELSE

			-- Add to the global table here. Because we need to call USA for all three update cases viz.
			-- 1. newly created container instance
			-- 2. existing container instance
			-- 3. existing non-container delivery details

			Add_To_Update_Table(
				p_del_det_int_rec => del_det_int_rec,
				p_update_mode	  => 'UPDATE',
				p_delivery_id	  => l_delivery_id,
				x_return_status   => l_return_status);

                                IF l_debug_on THEN
			         wsh_debug_sv.log (l_module_name, 'Add_To_Update_Table l_return_status',l_return_status);
                                END IF;

				IF(l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
					raise add_to_update_failed;
				END IF;
                              END IF; --}

			END IF; -- if nvl(del_det container flag)


			-- Process Interface freight costs
			SELECT count(*) INTO l_det_freight_costs
			FROM wsh_freight_costs_interface
			WHERE delivery_detail_interface_id = del_det_int_rec.delivery_detail_interface_id
		 	AND INTERFACE_ACTION_CODE = '94X_INBOUND';

                        IF l_debug_on THEN
			 wsh_debug_sv.log (l_module_name, 'Interface freight count', l_det_freight_costs);
			END IF;

			IF(l_det_freight_costs > 0 ) THEN
				Process_Int_Freight_Costs(
					p_del_detail_interface_id => del_det_int_rec.delivery_detail_interface_id,
                                        -- TPW - Distributed changes
                                        p_delivery_detail_id      => del_det_int_rec.delivery_detail_id,
					x_return_status => l_return_status);

                                IF l_debug_on THEN
				 wsh_debug_sv.log (l_module_name,'Return status from Process Int Freight Costs',l_return_status);
				END IF;

				IF( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
					raise freight_cost_processing_error;
				END IF;

			END IF;
		END IF; -- if action code = create }


	END LOOP; -- for det_id

	-- For the newly created delivery details, call detail_to_delivery to assign them to delivery
        IF l_debug_on THEN
	 wsh_debug_sv.log (l_module_name, 'Assign table count', l_new_detail_ids.count);
        END IF;

	IF(l_new_detail_ids.count > 0) THEN
		 WSH_DELIVERY_DETAILS_GRP.Detail_To_Delivery(
		p_api_version		=>1.0,
		p_init_msg_list		=> l_init_msg_list,
		p_validation_level	=> l_validation_level,
		p_commit		=> l_commit,
		x_return_status		=> l_return_status,
		x_msg_count		=> l_msg_count,
		x_msg_data		=> l_msg_data,
		p_TabOfDelDets		=> l_new_detail_ids,
		p_action		=> 'ASSIGN',
		p_delivery_id		=> p_new_delivery_id,
		p_delivery_name		=> l_delivery_name
		);

               IF l_debug_on THEN
		wsh_debug_sv.log (l_module_name, 'Return status from Detail to delivery', l_return_status);
		wsh_debug_sv.log (l_module_name, 'Detail to Delivery api msg count', l_msg_count);
		wsh_debug_sv.log (l_module_name, 'Detail to Delivery api msg data', l_msg_data);
	       END IF;

		IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
			raise new_assignment_failed;
		END IF;
	END IF;

        IF l_debug_on THEN
	 wsh_debug_sv.pop(l_module_name);
        END IF;
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION: FND_API.G_EXC_ERROR');
        END IF;
WHEN create_cont_instance_failed THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'create_cont_instance_failed exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:create_cont_instance_failed');
        END IF;
WHEN invalid_input THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'invalid_input exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:invalid_input');
        END IF;
WHEN create_lines_failed THEN
	FND_MESSAGE.SET_NAME('WSH', 'WSH_CREATE_LINES_FAILED');
	FND_MESSAGE.SET_TOKEN('DET_INT',del_det_int_rec.delivery_detail_interface_id);
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'create_lines_failed exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:create_lines_failed');
        END IF;
WHEN new_assignment_failed THEN
	FND_MESSAGE.SET_NAME('WSH','WSH_DEL_ASSGN_ERROR');
	FND_MESSAGE.SET_TOKEN('DLVY', p_new_delivery_id);
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'new_assignment_failed exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:new_assignment_failed');
        END IF;
WHEN freight_cost_processing_error THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'freight_cost_processing_error exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:freight_cost_processing_error');
        END IF;
WHEN Others THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
END Process_Non_Splits;

PROCEDURE process_splits(
   p_delivery_interface_id   IN              NUMBER,
   p_delivery_id             IN              NUMBER,
   x_return_status           OUT NOCOPY      VARCHAR2
) IS
-- local variables
   l_new_split_detail_id         NUMBER;
   l_base_req_qty                NUMBER;
   l_return_status               VARCHAR2(30);
   l_delivery_id                 NUMBER;
   l_det_freight_costs           NUMBER;
   l_ser_count                   NUMBER := 0;
   l_det_index                   NUMBER := 0;
   l_add_flag                    VARCHAR2(1) := 'T';
   l_total_req_qty               NUMBER := 0;
   l_total_shp_qty               NUMBER := 0;
   l_total_cc_qty                NUMBER := 0;
   l_dd_count                    NUMBER := 0;
   l_src_line_count              NUMBER := 0;
   l_prev_int_rec                del_det_int_cur%ROWTYPE;
   l_number_of_errors            NUMBER := 0;
   l_number_of_warnings          NUMBER := 0;
   l_num_of_dtl                  NUMBER := 0;
   l_serial_range_tab              WSH_GLBL_VAR_STRCT_GRP.ddSerialRangeTabType;
   l_index                       NUMBER;
   -- TPW - Distributed changes
   l_detail_id                   NUMBER;

--Cursors
--TPW - Distributed changes
CURSOR c_det_count_cur(p_header_number NUMBER, p_detail_id NUMBER, p_dlvy_int_id NUMBER) IS
SELECT COUNT(*)
FROM wsh_del_details_interface wddi, wsh_del_assgn_interface wdai
WHERE wddi.delivery_Detail_interface_id = wdai.delivery_detail_interface_id
AND wdai.delivery_interface_id = p_dlvy_int_id
AND wddi.delivery_detail_id=p_detail_id
AND nvl(wddi.source_header_number,'-99') = nvl(p_header_number,'-99')
AND WDAI.INTERFACE_ACTION_CODE = '94X_INBOUND'
AND WDDI.INTERFACE_ACTION_CODE = '94X_INBOUND';

-- TPW - Distributed changes
-- public api variables
l_init_msg_list         VARCHAR2(30) := NULL;
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(3000);
l_commit                VARCHAR2(1);
l_validation_level      NUMBER;
l_pending_req_qty       NUMBER;
l_pending_shp_qty       NUMBER;
l_curr_index            NUMBER;

l_serial_number_control NUMBER;
l_detail_id_tab         wsh_util_core.id_tab_type;
l_detail_qty_tab        wsh_util_core.id_tab_type;
l_new_detail_ids        wsh_util_core.id_tab_type;
l_frt_detail_intf_tab   wsh_util_core.id_tab_type;
l_frt_detail_tab        wsh_util_core.id_tab_type;
new_assignment_failed           exception;
-- TPW - Distributed changes

--exceptions
   invalid_input                 EXCEPTION;
   freight_cost_processing_error EXCEPTION;
--
   l_debug_on                    BOOLEAN;
--
   l_module_name        CONSTANT VARCHAR2(100)
                     := 'wsh.plsql.' || g_pkg_name || '.' || 'PROCESS_SPLITS';
--
BEGIN
   --
   l_debug_on := wsh_debug_interface.g_debug;

   --
   IF l_debug_on IS NULL THEN
      l_debug_on := wsh_debug_sv.is_debug_enabled;
   END IF;

   --
   IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name, 'Process_Splits');
      wsh_debug_sv.LOG(l_module_name, 'Delivery Interface Id',
         p_delivery_interface_id);
      wsh_debug_sv.LOG(l_module_name, 'Delivery Id', p_delivery_id);
   END IF;

   x_return_status := wsh_util_core.g_ret_sts_success;

   IF (p_delivery_interface_id IS NULL) THEN
      RAISE invalid_input;
   END IF;

   IF (p_delivery_id IS NOT NULL) THEN
      l_delivery_id := p_delivery_id;
   ELSE
      RAISE invalid_input;
   END IF;

   /* New Logic for splitting at supplier instance 945 inbound. kvenkate.
   For a given delivery_detail_id ,
   if more than one record exists in wsh_del_details_interface, then
     if those records have the same not null source_line_id, then do not split.
     if those records have distinct source_line_id, then split. */

   -- TPW - Distributed changes
   FOR del_det_int_rec IN del_det_int_cur(NULL, NULL, p_delivery_interface_id) LOOP --{
         IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name, '*** Current Delivery_Detail_Id', del_det_int_rec.delivery_detail_id);
            wsh_debug_sv.log(l_module_name, 'Current del.detail_int_id', del_det_int_rec.delivery_detail_interface_id);
            wsh_debug_sv.log(l_module_name, 'Req Qty '||del_det_int_rec.requested_quantity||' Shp Qty '||
                                             del_det_int_rec.shipped_quantity||' Cyc Qty '||del_det_int_rec.cycle_count_quantity);
            wsh_debug_sv.log(l_module_name, 'Previous Delivery_detail_id', l_prev_int_rec.delivery_detail_id);
            wsh_debug_sv.log(l_module_name, 'Previous del.detail_int_id', l_prev_int_rec.delivery_detail_interface_id);
            wsh_debug_sv.logmsg(l_module_name, 'l_src_line_count '||l_src_line_count||' l_dd_count '||l_dd_count);
            wsh_debug_sv.logmsg(l_module_name, 'Total req qty '|| l_total_req_qty ||' Total shp qty '||l_total_shp_qty||
                                               ' Total cc qty '||l_total_cc_qty);
            wsh_debug_sv.log(l_module_name, 'l_detail_id_tab.COUNT', l_detail_id_tab.COUNT);
         END IF;

      -- TPW - Distributed changes
      IF ((NVL(l_prev_int_rec.source_header_number, '-9999') = NVL(del_det_int_rec.source_header_number,'-9999')) AND
         (NVL(l_prev_int_rec.delivery_detail_id, '-9999') = del_det_int_rec.delivery_detail_id)) THEN --{
          if l_debug_on then
             wsh_debug_sv.logmsg(l_module_name, 'Same Delivery Detail');
          end if;
         l_dd_count := l_dd_count + 1;

         IF NVL(l_prev_int_rec.source_line_id, '-9999') =
                                               del_det_int_rec.source_line_id THEN
             if l_debug_on then
                  wsh_debug_sv.logmsg(l_module_name, 'Same Source Line');
             end if;
         ELSE --} {

            -- TPW - Distributed changes
            l_pending_req_qty := l_total_req_qty;
            l_pending_shp_qty := l_total_shp_qty;

            WHILE (l_pending_req_qty > 0) LOOP --{

               if l_debug_on then
                  wsh_debug_sv.logmsg(l_module_name, '*** 1 **** l_pending_req_qty '||l_pending_req_qty||' l_pending_shp_qty '||l_pending_shp_qty);
                  wsh_debug_sv.logmsg(l_module_name, ' l_curr_index '||l_curr_index||' l_detail_id_tab(l_curr_index) '||l_detail_id_tab(l_curr_index));
               end if;

               IF (l_pending_req_qty <= l_detail_qty_tab(l_curr_index)) THEN --{


                  l_detail_qty_tab(l_curr_index) := l_detail_qty_tab(l_curr_index) - l_pending_req_qty;

                  -- split dd
                  split_delivery_detail(
                     p_delivery_detail_id => l_detail_id_tab(l_curr_index),
                     p_qty_to_split  => l_pending_req_qty,
                     x_new_detail_id => l_new_split_detail_id,
                     x_return_status => l_return_status);

                  wsh_util_core.api_post_call(p_return_status => l_return_status,
                     x_num_warnings => l_number_of_warnings,
                     x_num_errors => l_number_of_errors);

                  -- For the newly created base delivery detail, make updates
                  -- Add the record with new detail id to the global table
                  if l_debug_on then
                     wsh_debug_sv.log(l_module_name, 'Splitted '||l_new_split_detail_id ||' from '|| l_detail_id_tab(l_curr_index) || ' for quantity '||l_pending_req_qty);
                  end if;

                  If l_new_split_detail_id IS NOT NULL THEN
                     l_prev_int_rec.delivery_detail_id := l_new_split_detail_id;
                     l_index := l_serial_range_tab.first;
                     while l_index is not null loop
                         l_serial_range_tab(l_index).delivery_detail_id := l_new_split_detail_id;
                         l_index := l_serial_range_tab.next(l_index);
                     end loop;
                  Else
                    l_prev_int_rec.delivery_detail_id := l_detail_id_tab(l_curr_index);
                  end if;

                  --
                  l_prev_int_rec.requested_quantity := l_pending_req_qty;
                  l_prev_int_rec.shipped_quantity := l_pending_shp_qty;
                  l_pending_req_qty := 0;

               ELSE --} {

                 l_prev_int_rec.delivery_detail_id := l_detail_id_tab(l_curr_index);
                 l_prev_int_rec.requested_quantity := l_detail_qty_tab(l_curr_index);
                 IF l_pending_shp_qty is not null THEN
                   l_prev_int_rec.shipped_quantity   := l_detail_qty_tab(l_curr_index);
                 END IF;
                 l_pending_req_qty                 := l_pending_req_qty - l_detail_qty_tab(l_curr_index);
                 l_pending_shp_qty                 := l_pending_shp_qty - l_detail_qty_tab(l_curr_index);

                 l_curr_index                      := l_curr_index + 1;

               END IF; --}

               IF (nvl(WSH_INBOUND_SHIP_ADVICE_PKG.G_WAREHOUSE_TYPE, '!') = 'TPW') THEN
                 l_prev_int_rec.cycle_count_quantity := l_total_cc_qty;
               ELSE
                 l_prev_int_rec.cycle_count_quantity := null;
               END IF;
               --

               add_to_update_table(
                  p_del_det_int_rec => l_prev_int_rec,
                  p_update_mode     => 'UPDATE',
                  p_delivery_id     => l_delivery_id,
                  x_return_status   => l_return_status);

               IF (l_return_status <> wsh_util_core.g_ret_sts_success) THEN
                  RAISE fnd_api.g_exc_error;
               END IF;


               IF (nvl(WSH_INBOUND_SHIP_ADVICE_PKG.G_WAREHOUSE_TYPE, '!') = 'TW2') THEN
                 l_new_detail_ids(l_new_detail_ids.COUNT+1) := l_prev_int_rec.delivery_detail_id;
               END IF;

            END LOOP; --}
            --
            -- g_serial_range_tab := g_serial_range_tab + l_serial_range_tab;
            add_to_serial_table(p_serial_range_tab => l_serial_range_tab);
            l_serial_range_tab.delete;
            l_total_req_qty := 0;
            l_total_shp_qty := 0;
            l_total_cc_qty := 0;
            l_src_line_count := l_src_line_count + 1;

	    l_frt_detail_intf_tab (l_frt_detail_intf_tab.COUNT+1) := l_prev_int_rec.delivery_detail_interface_id;
            l_frt_detail_tab (l_frt_detail_tab.COUNT+1)           := l_prev_int_rec.delivery_detail_id;
         END IF; --}

      ELSE --} {


         IF (l_prev_int_rec.container_flag = 'N') THEN --{

            IF l_src_line_count > 1 --count(distinct sn) for prev. dd id)
                                    THEN
               -- TPW - Distributed changes
               l_pending_req_qty := l_total_req_qty;
               l_pending_shp_qty := l_total_shp_qty;

               WHILE (l_pending_req_qty > 0) LOOP --{

                  if l_debug_on then
                     wsh_debug_sv.logmsg(l_module_name, '*** 2 **** l_pending_req_qty '||l_pending_req_qty||' l_pending_shp_qty '||l_pending_shp_qty);
                     wsh_debug_sv.logmsg(l_module_name, ' l_curr_index '||l_curr_index||' l_detail_id_tab(l_curr_index) '||l_detail_id_tab(l_curr_index));
                  end if;

                  IF (l_pending_req_qty <= l_detail_qty_tab(l_curr_index)) THEN --{


                     l_detail_qty_tab(l_curr_index) := l_detail_qty_tab(l_curr_index) - l_pending_req_qty;

                     -- split dd
                     --split_delivery_detail(p_delivery_detail_id => del_det_int_rec.delivery_detail_id,
                     split_delivery_detail(
                        p_delivery_detail_id => l_detail_id_tab(l_curr_index),
                        p_qty_to_split  => l_pending_req_qty,
                        x_new_detail_id => l_new_split_detail_id,
                        x_return_status => l_return_status);

                     wsh_util_core.api_post_call(p_return_status => l_return_status,
                        x_num_warnings => l_number_of_warnings,
                        x_num_errors => l_number_of_errors);

                     -- For the newly created base delivery detail, make updates
                     -- Add the record with new detail id to the global table
                     if l_debug_on then
                        wsh_debug_sv.log(l_module_name, 'Splitted '||l_new_split_detail_id ||' from '|| l_detail_id_tab(l_curr_index) || ' for quantity '||l_pending_req_qty);
                     end if;

                     If l_new_split_detail_id IS NOT NULL THEN
                        l_prev_int_rec.delivery_detail_id := l_new_split_detail_id;
                        l_index := l_serial_range_tab.first;
                        while l_index is not null loop
                            l_serial_range_tab(l_index).delivery_detail_id := l_new_split_detail_id;
                            l_index := l_serial_range_tab.next(l_index);
                        end loop;
                     Else
                       l_prev_int_rec.delivery_detail_id := l_detail_id_tab(l_curr_index);
                     end if;

                     --
                     l_prev_int_rec.requested_quantity := l_pending_req_qty;
                     l_prev_int_rec.shipped_quantity := l_pending_shp_qty;
                     l_pending_req_qty := 0;

                  ELSE

                    l_prev_int_rec.delivery_detail_id := l_detail_id_tab(l_curr_index);
                    l_prev_int_rec.requested_quantity := l_detail_qty_tab(l_curr_index);
                    IF l_pending_shp_qty is not null THEN
                      l_prev_int_rec.shipped_quantity   := l_detail_qty_tab(l_curr_index);
                    END IF;
                    l_pending_req_qty                 := l_pending_req_qty - l_detail_qty_tab(l_curr_index);
                    l_pending_shp_qty                 := l_pending_shp_qty - l_detail_qty_tab(l_curr_index);

                    l_curr_index                      := l_curr_index + 1;

                  END IF; --}

                  IF (nvl(WSH_INBOUND_SHIP_ADVICE_PKG.G_WAREHOUSE_TYPE, '!') = 'TPW') THEN
                    l_prev_int_rec.cycle_count_quantity := l_total_cc_qty;
                  ELSE
                    l_prev_int_rec.cycle_count_quantity := null;
                  END IF;
                  --

                  add_to_update_table(
                     p_del_det_int_rec => l_prev_int_rec,
                     p_update_mode     => 'UPDATE',
                     p_delivery_id     => l_delivery_id,
                     x_return_status   => l_return_status);

                  IF (l_return_status <> wsh_util_core.g_ret_sts_success) THEN
                     RAISE fnd_api.g_exc_error;
                  END IF;


                  IF (nvl(WSH_INBOUND_SHIP_ADVICE_PKG.G_WAREHOUSE_TYPE, '!') = 'TW2') THEN
                    l_new_detail_ids(l_new_detail_ids.COUNT+1) := l_prev_int_rec.delivery_detail_id;
                  END IF;

               END LOOP; --}

               add_to_serial_table(p_serial_range_tab => l_serial_range_tab);
               l_serial_range_tab.delete;

               l_frt_detail_intf_tab (l_frt_detail_intf_tab.COUNT+1) := l_prev_int_rec.delivery_detail_interface_id;
               l_frt_detail_tab (l_frt_detail_tab.COUNT+1)           := l_prev_int_rec.delivery_detail_id;

               l_detail_id_tab.DELETE;

            ELSIF l_dd_count > 1 -- count(prev dd id) > 1
                                 THEN
               l_pending_req_qty := l_total_req_qty;
               l_pending_shp_qty := l_total_shp_qty;

               WHILE (l_pending_req_qty > 0) LOOP --{

                  if l_debug_on then
                     wsh_debug_sv.logmsg(l_module_name, '*** 3 **** l_pending_req_qty '||l_pending_req_qty||' l_pending_shp_qty '||l_pending_shp_qty);
                     wsh_debug_sv.logmsg(l_module_name, ' l_curr_index '||l_curr_index||' l_detail_id_tab(l_curr_index) '||l_detail_id_tab(l_curr_index));
                  end if;

                  IF (l_pending_req_qty <= l_detail_qty_tab(l_curr_index)) THEN --{


                     l_detail_qty_tab(l_curr_index) := l_detail_qty_tab(l_curr_index) - l_pending_req_qty;

                     -- split dd
                     --split_delivery_detail(p_delivery_detail_id => del_det_int_rec.delivery_detail_id,
                     split_delivery_detail(
                        p_delivery_detail_id => l_detail_id_tab(l_curr_index),
                        p_qty_to_split  => l_pending_req_qty,
                        x_new_detail_id => l_new_split_detail_id,
                        x_return_status => l_return_status);

                     wsh_util_core.api_post_call(p_return_status => l_return_status,
                        x_num_warnings => l_number_of_warnings,
                        x_num_errors => l_number_of_errors);

                     -- For the newly created base delivery detail, make updates
                     -- Add the record with new detail id to the global table
                     if l_debug_on then
                        wsh_debug_sv.log(l_module_name, 'Splitted '||l_new_split_detail_id ||' from '|| l_detail_id_tab(l_curr_index) || ' for quantity '||l_pending_req_qty);
                     end if;

                     If l_new_split_detail_id IS NOT NULL THEN
                        l_prev_int_rec.delivery_detail_id := l_new_split_detail_id;
                        l_index := l_serial_range_tab.first;
                        while l_index is not null loop
                            l_serial_range_tab(l_index).delivery_detail_id := l_new_split_detail_id;
                            l_index := l_serial_range_tab.next(l_index);
                        end loop;
                     Else
                       l_prev_int_rec.delivery_detail_id := l_detail_id_tab(l_curr_index);
                     end if;

                     --
                     l_prev_int_rec.requested_quantity := l_pending_req_qty;
                     l_prev_int_rec.shipped_quantity := l_pending_shp_qty;
                     l_pending_req_qty := 0;

                  ELSE

                    l_prev_int_rec.delivery_detail_id := l_detail_id_tab(l_curr_index);
                    l_prev_int_rec.requested_quantity := l_detail_qty_tab(l_curr_index);
                    IF l_pending_shp_qty is not null THEN
                      l_prev_int_rec.shipped_quantity   := l_detail_qty_tab(l_curr_index);
                    END IF;
                    l_pending_req_qty                 := l_pending_req_qty - l_detail_qty_tab(l_curr_index);
                    l_pending_shp_qty                 := l_pending_shp_qty - l_detail_qty_tab(l_curr_index);

                    l_curr_index                      := l_curr_index + 1;

                  END IF; --}

                  IF (nvl(WSH_INBOUND_SHIP_ADVICE_PKG.G_WAREHOUSE_TYPE, '!') = 'TPW') THEN
                    l_prev_int_rec.cycle_count_quantity := l_total_cc_qty;
                  ELSE
                    l_prev_int_rec.cycle_count_quantity := null;
                  END IF;
                  --

                  add_to_update_table(
                     p_del_det_int_rec => l_prev_int_rec,
                     p_update_mode     => 'UPDATE',
                     p_delivery_id     => l_delivery_id,
                     x_return_status   => l_return_status);

                  IF (l_return_status <> wsh_util_core.g_ret_sts_success) THEN
                     RAISE fnd_api.g_exc_error;
                  END IF;


                  IF (nvl(WSH_INBOUND_SHIP_ADVICE_PKG.G_WAREHOUSE_TYPE, '!') = 'TW2') THEN
                    l_new_detail_ids(l_new_detail_ids.COUNT+1) := l_prev_int_rec.delivery_detail_id;
                  END IF;

               END LOOP; --}
               --
               -- g_serial_range_tab := g_serial_range_tab + l_serial_range_tab;
               add_to_serial_table(p_serial_range_tab => l_serial_range_tab);
               l_serial_range_tab.delete;

               -- TPW - Distributed changes
               l_frt_detail_intf_tab (l_frt_detail_intf_tab.COUNT+1) := l_prev_int_rec.delivery_detail_interface_id;
               l_frt_detail_tab (l_frt_detail_tab.COUNT+1)           := l_prev_int_rec.delivery_detail_id;

               l_detail_id_tab.DELETE;

            END IF;
         END IF; --}

         l_total_req_qty := 0;
         l_total_shp_qty := 0;
         l_total_cc_qty := 0;
         --
         l_dd_count := 1;
         l_src_line_count := 1;

         -- TPW - Distributed changes
         OPEN c_det_count_cur(del_det_int_rec.source_header_number, del_det_int_rec.delivery_detail_id, p_delivery_interface_id);
         FETCH c_det_count_cur INTO l_num_of_dtl;
         CLOSE c_det_count_cur;
         if l_debug_on THEN
            wsh_debug_sv.log(l_module_name, 'l_num_of_dtl', l_num_of_dtl);
         end if;

	    -- TPW - Distributed changes
         if (del_det_int_rec.container_flag = 'N') THEN

	    IF (nvl(WSH_INBOUND_SHIP_ADVICE_PKG.G_WAREHOUSE_TYPE, '!') = 'TW2') THEN

               IF l_debug_on THEN
                  wsh_debug_sv.logmsg(l_module_name, 'Line Direction '||del_det_int_rec.line_direction||
                                      ' SHN '||del_det_int_rec.source_header_number||
                                      ' Intf DDID '||del_det_int_rec.delivery_detail_id);
               END IF;

               IF (del_det_int_rec.line_direction = 'IO') THEN
                  select wdd.delivery_detail_id, wdd.requested_quantity BULK COLLECT
                  into   l_detail_id_tab, l_detail_qty_tab
                  from   wsh_delivery_details wdd,
                         oe_order_lines_all ol,
                         po_requisition_lines_all pl,
                         po_requisition_headers_all ph
                  where  wdd.source_code = 'OE'
                  and    wdd.released_status in ('R','B','X')
                  and    wdd.source_line_id = ol.line_id
                  and    ol.source_document_line_id = pl.requisition_line_id
                  and    ol.source_document_id = pl.requisition_header_id
                  and    pl.requisition_header_id = ph.requisition_header_id
                  and    pl.line_num = del_det_int_rec.delivery_detail_id
                  and    ph.segment1 = del_det_int_rec.source_header_number;
               ELSE
                  select wdd.delivery_detail_id, wdd.requested_quantity BULK COLLECT
                  into   l_detail_id_tab, l_detail_qty_tab
                  from   wsh_delivery_details wdd,
                         wsh_shipment_batches wsb,
                         wsh_transactions_history wth
                  where  wdd.source_code = 'OE'
                  and    wdd.released_status in ('R','B','X')
                  and    wdd.shipment_batch_id = wsb.batch_id
                  and    wdd.shipment_line_number = del_det_int_rec.delivery_detail_id
                  and    wsb.name = wth.entity_number
                  and    wth.entity_type = 'BATCH'
                  and    wth.document_direction = 'O'
                  and    wth.document_type = 'SR'
                  and    wth.document_number = del_det_int_rec.source_header_number;
               END IF;

               IF l_debug_on THEN
                  FOR i in 1..l_detail_id_tab.COUNT LOOP
                     wsh_debug_sv.logmsg(l_module_name,'DD-id '||l_detail_id_tab(i)||' Req Qty '||l_detail_qty_tab(i));
                  END LOOP;
               END IF;

            ELSE
               l_detail_id_tab(1) := del_det_int_rec.delivery_detail_id;

               select requested_quantity
               into   l_detail_qty_tab(1)
               from   wsh_delivery_details
               where  delivery_detail_id = del_det_int_rec.delivery_detail_id;
            END IF;

            l_curr_index := 1;
         else
             l_num_of_dtl := 1;
         end if;

         IF l_num_of_dtl = 1 THEN
            l_serial_range_tab.delete;
            goto detail_loop_end;
         END IF;

      END IF; --}

      l_total_req_qty := l_total_req_qty + del_det_int_rec.requested_quantity;
      l_total_shp_qty := l_total_shp_qty + del_det_int_rec.shipped_quantity;
      IF (nvl(WSH_INBOUND_SHIP_ADVICE_PKG.G_WAREHOUSE_TYPE, '!') = 'TPW') THEN
        l_total_cc_qty := l_total_cc_qty + del_det_int_rec.cycle_count_quantity;
      ELSE
        l_total_cc_qty := null;
      END IF;

      --
      IF del_det_int_rec.serial_number IS NOT NULL THEN
         -- { If Organization is TW2 then check if item is serial controlled - Start
         IF (nvl(WSH_INBOUND_SHIP_ADVICE_PKG.G_WAREHOUSE_TYPE, '!') = 'TW2') THEN
            IF l_debug_on THEN
               wsh_debug_sv.log(l_module_name,'PS: del_det_int_rec.inventory_item_id', del_det_int_rec.inventory_item_id);
               wsh_debug_sv.log(l_module_name,'PS: del_det_int_rec.organization_id', del_det_int_rec.organization_id);
               wsh_debug_sv.log(l_module_name,'PS: del_det_int_rec.serial_number', del_det_int_rec.serial_number);
               wsh_debug_sv.log(l_module_name,'PS: del_det_int_rec.to_serial_number', del_det_int_rec.to_serial_number);
            END IF;

            BEGIN
            SELECT serial_number_control_code
            INTO   l_serial_number_control
            FROM   mtl_system_items
            WHERE  inventory_item_id = del_det_int_rec.inventory_item_id
            AND    organization_id   = del_det_int_rec.organization_id;

            IF l_debug_on THEN
               wsh_debug_sv.log(l_module_name,'PS: l_serial_number_control', l_serial_number_control);
            END IF;

            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 IF l_debug_on THEN
                    wsh_debug_sv.logmsg(l_module_name,'PS: Inside No-Data-Found');
                 END IF;
            END;
         ELSE -- Organization is TPW Enabled
            l_serial_number_control := 2;
         END IF;
         -- } If Organization is TW2 then check if item is serial controlled - End

         -- TPW - Distributed changes
         IF (l_detail_id_tab.COUNT = 1) THEN --{
            IF l_serial_number_control <> 1 THEN
               IF l_debug_on THEN
                  wsh_debug_sv.logmsg(l_module_name, 'Adding serial number to serial table');
               END IF;

               l_ser_count := l_serial_range_tab.COUNT;
               l_serial_range_tab(l_ser_count + 1).delivery_detail_id :=
                                                  l_detail_id_tab(1);
               l_serial_range_tab(l_ser_count + 1).from_serial_number :=
                                                       del_det_int_rec.serial_number;
               l_serial_range_tab(l_ser_count + 1).to_serial_number :=
                                                    del_det_int_rec.to_serial_number;
               l_serial_range_tab(l_ser_count + 1).quantity :=
                                                    del_det_int_rec.shipped_quantity;
            END IF;

            -- Since serial numbers added to serial table, should not be added in the update record
            del_det_int_rec.serial_number := NULL;
            del_det_int_rec.to_serial_number := NULL;
         ELSE
           -- Not Supported
           IF l_debug_on THEN
             wsh_debug_sv.logmsg(l_module_name,'Serial types not supported for remnant models');
           END IF;
           raise fnd_api.g_exc_error;
         END IF; --}
      END IF;

      <<detail_loop_end>>
      l_prev_int_rec := del_det_int_rec;

   END LOOP; -- for del_det_int_rec in cursor }

   IF l_debug_on THEN
      wsh_debug_sv.logmsg(l_module_name, '*** Outside the Loop ***');
      wsh_debug_sv.logmsg(l_module_name, 'l_src_line_count '|| l_src_line_count||' l_dd_count '||l_dd_count);
      wsh_debug_sv.logmsg(l_module_name, 'Total req qty '|| l_total_req_qty||' Total shp qty '||l_total_shp_qty||' Total cc qty '||l_total_cc_qty);
   END IF;

   IF (l_prev_int_rec.container_flag = 'N') THEN --{
      IF l_src_line_count > 1 THEN

         -- TPW - Distributed changes
         l_pending_req_qty := l_total_req_qty;
         l_pending_shp_qty := l_total_shp_qty;

         WHILE (l_pending_req_qty > 0) LOOP --{

            if l_debug_on then
               wsh_debug_sv.logmsg(l_module_name, '*** 4 **** l_pending_req_qty '||l_pending_req_qty||' l_pending_shp_qty '||l_pending_shp_qty);
               wsh_debug_sv.logmsg(l_module_name, ' l_curr_index '||l_curr_index||' l_detail_id_tab(l_curr_index) '||l_detail_id_tab(l_curr_index));
            end if;

            IF (l_pending_req_qty <= l_detail_qty_tab(l_curr_index)) THEN --{


               l_detail_qty_tab(l_curr_index) := l_detail_qty_tab(l_curr_index) - l_pending_req_qty;

               -- split dd
               --split_delivery_detail(p_delivery_detail_id => del_det_int_rec.delivery_detail_id,
               split_delivery_detail(
                  p_delivery_detail_id => l_detail_id_tab(l_curr_index),
                  p_qty_to_split  => l_pending_req_qty,
                  x_new_detail_id => l_new_split_detail_id,
                  x_return_status => l_return_status);

               wsh_util_core.api_post_call(p_return_status => l_return_status,
                  x_num_warnings => l_number_of_warnings,
                  x_num_errors => l_number_of_errors);

               -- For the newly created base delivery detail, make updates
               -- Add the record with new detail id to the global table
               if l_debug_on then
                  wsh_debug_sv.log(l_module_name, 'Splitted '||l_new_split_detail_id ||' from '|| l_detail_id_tab(l_curr_index) || ' for quantity '||l_pending_req_qty);
               end if;

               If l_new_split_detail_id IS NOT NULL THEN
                  l_prev_int_rec.delivery_detail_id := l_new_split_detail_id;
                  l_index := l_serial_range_tab.first;
                  while l_index is not null loop
                      l_serial_range_tab(l_index).delivery_detail_id := l_new_split_detail_id;
                      l_index := l_serial_range_tab.next(l_index);
                  end loop;
               Else
                 l_prev_int_rec.delivery_detail_id := l_detail_id_tab(l_curr_index);
               end if;

               --
               l_prev_int_rec.requested_quantity := l_pending_req_qty;
               l_prev_int_rec.shipped_quantity := l_pending_shp_qty;
               l_pending_req_qty := 0;

            ELSE --} {

              l_prev_int_rec.delivery_detail_id := l_detail_id_tab(l_curr_index);
              l_prev_int_rec.requested_quantity := l_detail_qty_tab(l_curr_index);
              IF l_pending_shp_qty is not null THEN
                l_prev_int_rec.shipped_quantity   := l_detail_qty_tab(l_curr_index);
              END IF;
              l_pending_req_qty                 := l_pending_req_qty - l_detail_qty_tab(l_curr_index);
              l_pending_shp_qty                 := l_pending_shp_qty - l_detail_qty_tab(l_curr_index);

              l_curr_index                      := l_curr_index + 1;

            END IF; --}

            IF (nvl(WSH_INBOUND_SHIP_ADVICE_PKG.G_WAREHOUSE_TYPE, '!') = 'TPW') THEN
              l_prev_int_rec.cycle_count_quantity := l_total_cc_qty;
            ELSE
              l_prev_int_rec.cycle_count_quantity := null;
            END IF;
            --

            add_to_update_table(
               p_del_det_int_rec => l_prev_int_rec,
               p_update_mode     => 'UPDATE',
               p_delivery_id     => l_delivery_id,
               x_return_status   => l_return_status);

            IF (l_return_status <> wsh_util_core.g_ret_sts_success) THEN
               RAISE fnd_api.g_exc_error;
            END IF;


            IF (nvl(WSH_INBOUND_SHIP_ADVICE_PKG.G_WAREHOUSE_TYPE, '!') = 'TW2') THEN
              l_new_detail_ids(l_new_detail_ids.COUNT+1) := l_prev_int_rec.delivery_detail_id;
            END IF;

         END LOOP; --}

         add_to_serial_table(p_serial_range_tab => l_serial_range_tab);
         l_serial_range_tab.delete;

         l_frt_detail_intf_tab (l_frt_detail_intf_tab.COUNT+1) := l_prev_int_rec.delivery_detail_interface_id;
         l_frt_detail_tab (l_frt_detail_tab.COUNT+1)           := l_prev_int_rec.delivery_detail_id;

         l_detail_id_tab.DELETE;

      ELSIF l_dd_count > 1 THEN

         l_pending_req_qty := l_total_req_qty;
         l_pending_shp_qty := l_total_shp_qty;

         WHILE (l_pending_req_qty > 0) LOOP --{

            if l_debug_on then
               wsh_debug_sv.logmsg(l_module_name, '*** 5 **** l_pending_req_qty '||l_pending_req_qty||' l_pending_shp_qty '||l_pending_shp_qty);
               wsh_debug_sv.logmsg(l_module_name, ' l_curr_index '||l_curr_index||' l_detail_id_tab(l_curr_index) '||l_detail_id_tab(l_curr_index));
            end if;

            IF (l_pending_req_qty <= l_detail_qty_tab(l_curr_index)) THEN --{


               l_detail_qty_tab(l_curr_index) := l_detail_qty_tab(l_curr_index) - l_pending_req_qty;

               -- split dd
               --split_delivery_detail(p_delivery_detail_id => del_det_int_rec.delivery_detail_id,
               split_delivery_detail(
                  p_delivery_detail_id => l_detail_id_tab(l_curr_index),
                  p_qty_to_split  => l_pending_req_qty,
                  x_new_detail_id => l_new_split_detail_id,
                  x_return_status => l_return_status);

               wsh_util_core.api_post_call(p_return_status => l_return_status,
                  x_num_warnings => l_number_of_warnings,
                  x_num_errors => l_number_of_errors);

               -- For the newly created base delivery detail, make updates
               -- Add the record with new detail id to the global table
               if l_debug_on then
                  wsh_debug_sv.log(l_module_name, 'Splitted '||l_new_split_detail_id ||' from '|| l_detail_id_tab(l_curr_index) || ' for quantity '||l_pending_req_qty);
               end if;

               If l_new_split_detail_id IS NOT NULL THEN
                  l_prev_int_rec.delivery_detail_id := l_new_split_detail_id;
                  l_index := l_serial_range_tab.first;
                  while l_index is not null loop
                      l_serial_range_tab(l_index).delivery_detail_id := l_new_split_detail_id;
                      l_index := l_serial_range_tab.next(l_index);
                  end loop;
               Else
                 l_prev_int_rec.delivery_detail_id := l_detail_id_tab(l_curr_index);
               end if;

               --
               l_prev_int_rec.requested_quantity := l_pending_req_qty;
               l_prev_int_rec.shipped_quantity := l_pending_shp_qty;
               l_pending_req_qty := 0;

            ELSE --} {

              l_prev_int_rec.delivery_detail_id := l_detail_id_tab(l_curr_index);
              l_prev_int_rec.requested_quantity := l_detail_qty_tab(l_curr_index);
              IF l_pending_shp_qty is not null THEN
                l_prev_int_rec.shipped_quantity   := l_detail_qty_tab(l_curr_index);
              END IF;
              l_pending_req_qty                 := l_pending_req_qty - l_detail_qty_tab(l_curr_index);
              l_pending_shp_qty                 := l_pending_shp_qty - l_detail_qty_tab(l_curr_index);

              l_curr_index                      := l_curr_index + 1;

            END IF; --}

            IF (nvl(WSH_INBOUND_SHIP_ADVICE_PKG.G_WAREHOUSE_TYPE, '!') = 'TPW') THEN
              l_prev_int_rec.cycle_count_quantity := l_total_cc_qty;
            ELSE
              l_prev_int_rec.cycle_count_quantity := null;
            END IF;
            --

            add_to_update_table(
               p_del_det_int_rec => l_prev_int_rec,
               p_update_mode     => 'UPDATE',
               p_delivery_id     => l_delivery_id,
               x_return_status   => l_return_status);

            IF (l_return_status <> wsh_util_core.g_ret_sts_success) THEN
               RAISE fnd_api.g_exc_error;
            END IF;


            IF (nvl(WSH_INBOUND_SHIP_ADVICE_PKG.G_WAREHOUSE_TYPE, '!') = 'TW2') THEN
              l_new_detail_ids(l_new_detail_ids.COUNT+1) := l_prev_int_rec.delivery_detail_id;
            END IF;

         END LOOP; --}
         --
         -- g_serial_range_tab := g_serial_range_tab + l_serial_range_tab;
         add_to_serial_table(p_serial_range_tab => l_serial_range_tab);
         l_serial_range_tab.delete;

         -- TPW - Distributed changes
         l_frt_detail_intf_tab (l_frt_detail_intf_tab.COUNT+1) := l_prev_int_rec.delivery_detail_interface_id;
         l_frt_detail_tab (l_frt_detail_tab.COUNT+1)           := l_prev_int_rec.delivery_detail_id;

         l_detail_id_tab.DELETE;

      END IF;
   END IF; --}

   -- TPW - Distributed changes
   IF l_debug_on THEN
     wsh_debug_sv.log (l_module_name, 'Freight Table Count', l_frt_detail_intf_tab.COUNT);
   END IF;

   IF (l_frt_detail_intf_tab.COUNT > 0) THEN
     FOR i in 1..l_frt_detail_intf_tab.COUNT LOOP
       IF l_debug_on THEN
         wsh_debug_sv.log (l_module_name, 'i', i);
         wsh_debug_sv.log (l_module_name, 'l_frt_detail_intf_tab',l_frt_detail_intf_tab(i));
         wsh_debug_sv.log (l_module_name, 'l_frt_detail_tab',l_frt_detail_tab(i));
       END IF;
       -- Process interface freight costs
       SELECT COUNT(*)
       INTO l_det_freight_costs
       FROM wsh_freight_costs_interface
       WHERE delivery_detail_interface_id = l_frt_detail_intf_tab(i)
       AND INTERFACE_ACTION_CODE = '94X_INBOUND';

       IF l_debug_on THEN
         wsh_debug_sv.LOG(l_module_name, 'Interface freight count', l_det_freight_costs);
       END IF;

       IF (l_det_freight_costs > 0) THEN
         IF l_debug_on THEN
           wsh_debug_sv.LOG(l_module_name, 'Processing freight costs for interface detail', l_frt_detail_intf_tab(i));
         END IF;

         process_int_freight_costs(
           p_del_detail_interface_id => l_frt_detail_intf_tab(i),
           p_delivery_detail_id => l_frt_detail_tab(i),
           x_return_status => l_return_status);

         IF l_debug_on THEN
           wsh_debug_sv.LOG(l_module_name, 'Process_Int_Freight_Costs l_return_status', l_return_status);
         END IF;

         IF (l_return_status <> wsh_util_core.g_ret_sts_success) THEN
           RAISE freight_cost_processing_error;
         END IF;
       END IF;
     END LOOP;
   END IF;

   -- TPW - Distributed changes
   -- For the newly created delivery details, call detail_to_delivery to assign them to delivery
   IF l_debug_on THEN
      wsh_debug_sv.log (l_module_name, 'Assign table count', l_new_detail_ids.count);
   END IF;

   IF (l_new_detail_ids.count > 0) THEN
      WSH_DELIVERY_DETAILS_GRP.Detail_To_Delivery(
           p_api_version           =>1.0,
           p_init_msg_list         => l_init_msg_list,
           p_validation_level      => l_validation_level,
           p_commit                => l_commit,
           x_return_status         => l_return_status,
           x_msg_count             => l_msg_count,
           x_msg_data              => l_msg_data,
           p_TabOfDelDets          => l_new_detail_ids,
           p_action                => 'ASSIGN',
           p_delivery_id           => l_delivery_id
           );

      IF l_debug_on THEN
         wsh_debug_sv.log (l_module_name, 'Return status from Detail to delivery', l_return_status);
         wsh_debug_sv.log (l_module_name, 'Detail to Delivery api msg count', l_msg_count);
         wsh_debug_sv.log (l_module_name, 'Detail to Delivery api msg data', l_msg_data);
      END IF;

      IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
         raise new_assignment_failed;
      END IF;

   END IF;

   IF l_debug_on THEN
      wsh_debug_sv.pop(l_module_name);
   END IF;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      --
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name,
            'FND_API.G_EXC_ERROR exception has occured.',
            wsh_debug_sv.c_excep_level);
         wsh_debug_sv.pop(l_module_name, 'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
   --
   --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      --
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name,
            'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',
            wsh_debug_sv.c_excep_level);
         wsh_debug_sv.pop(l_module_name,
            'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
   --
   WHEN wsh_util_core.g_exc_warning THEN
      x_return_status := wsh_util_core.g_ret_sts_warning;
      --
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name,
            'WSH_UTIL_CORE.G_EXC_WARNING exception has occured ',
            wsh_debug_sv.c_excep_level);
         wsh_debug_sv.pop(l_module_name,
            'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
   --
   WHEN invalid_input THEN
      x_return_status := wsh_util_core.g_ret_sts_error;

      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name,
            'invalid_input exception has occured.',
            wsh_debug_sv.c_excep_level);
         wsh_debug_sv.pop(l_module_name, 'EXCEPTION:invalid_input');
      END IF;
   WHEN freight_cost_processing_error THEN
      x_return_status := wsh_util_core.g_ret_sts_error;

      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name,
            'freight_cost_processing_error exception has occured.',
            wsh_debug_sv.c_excep_level);
         wsh_debug_sv.pop(l_module_name,
            'EXCEPTION:freight_cost_processing_error');
      END IF;
   -- TPW - Distributed changes
   WHEN new_assignment_failed THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_DEL_ASSGN_ERROR');
        FND_MESSAGE.SET_TOKEN('DLVY', l_delivery_id);
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'new_assignment_failed exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:new_assignment_failed');
        END IF;
   WHEN OTHERS THEN
      x_return_status := wsh_util_core.g_ret_sts_unexp_error;

      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name,
               'Unexpected error has occured. Oracle error message is '
            || SQLERRM,
            wsh_debug_sv.c_unexpec_err_level);
         wsh_debug_sv.pop(l_module_name, 'EXCEPTION:OTHERS');
      END IF;
END process_splits;


PROCEDURE Pack_Lines(
		x_return_status	OUT NOCOPY  VARCHAR2) IS
-- variables
l_return_status VARCHAR2(30);
l_pack_status	VARCHAR2(30);
l_del_detail_tab	WSH_UTIL_CORE.id_tab_type;

--exceptions
packing_failed	exception;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PACK_LINES';
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
	wsh_debug_sv.push(l_module_name, 'Pack_Lines');
	wsh_debug_sv.log (l_module_name, 'Packing Table Count', G_Packing_Detail_Tab.count);
       END IF;

	x_return_status	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	FOR i in 1..G_Packing_Detail_Tab.count LOOP
                -- TPW - Distributed changes
                IF (G_Packing_Detail_Tab(i).src_container_flag = 'N') THEN --{
  		  -- Need to delete the table because we pass only one delivery detail per call
  		  l_del_detail_tab.delete;
  		  l_del_detail_tab(1)	:= G_Packing_Detail_Tab(i).Delivery_Detail_Id;
  		  -- call packing api

                  IF l_debug_on THEN
  		    wsh_debug_sv.logmsg(l_module_name, 'calling container_actions.assign_detail');
  		    wsh_debug_sv.log (l_module_name, 'Delivery detail id', G_Packing_Detail_Tab(i).Delivery_Detail_Id);
  		    wsh_debug_sv.log (l_module_name, 'Container instance id', G_Packing_Detail_Tab(i).Parent_Delivery_Detail_Id);
                  END IF;

  		  WSH_CONTAINER_ACTIONS.Assign_Detail(
  			p_container_instance_id	=> G_Packing_Detail_Tab(i).Parent_Delivery_Detail_Id,
  			p_del_detail_tab	=> l_del_detail_tab,
  			x_pack_status 		=> l_pack_status,
  			x_return_status 	=> l_return_status);

                ELSE --} {
                  IF l_debug_on THEN
		    wsh_debug_sv.logmsg(l_module_name, 'calling container_actions.assign_to_container');
		    wsh_debug_sv.log (l_module_name, 'Det Container instance id', G_Packing_Detail_Tab(i).Delivery_Detail_Id);
		    wsh_debug_sv.log (l_module_name, 'Master Container instance id', G_Packing_Detail_Tab(i).Parent_Delivery_Detail_Id);
                  END IF;

		  WSH_CONTAINER_ACTIONS.Assign_To_Container (
			p_det_cont_inst_id	=> G_Packing_Detail_Tab(i).Delivery_Detail_Id,
			p_par_cont_inst_id	=> G_Packing_Detail_Tab(i).Parent_Delivery_Detail_Id,
			x_return_status 	=> l_return_status);

                END IF; --}

                IF l_debug_on THEN
		 wsh_debug_sv.log (l_module_name,'Return Status', l_return_status);
		END IF;

		IF(l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
			FND_MESSAGE.SET_NAME('WSH','WSH_PACKING_ERROR');
			FND_MESSAGE.SET_TOKEN('DEL_DETAIL', G_Packing_Detail_Tab(i).Delivery_Detail_Id);
			raise packing_failed;
		END IF;
	END LOOP; -- for i in 1..G_Packing

      IF l_debug_on THEN
	wsh_debug_sv.pop(l_module_name);
      END IF;

EXCEPTION
WHEN packing_failed THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'packing_failed exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:packing_failed');
        END IF;
WHEN Others THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;

END Pack_Lines;


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Process_Interfaced_Deliveries
   PARAMETERS : p_delivery_interface_id		IN NUMBER,
		p_action_code			CREATE or UPDATE
		x_dlvy_id		The delivery id that is created
		x_return_status			OUT VARCHAR2)

  DESCRIPTION :
-- This procedure is called by the wrapper, to process the interfaced deliveries
-- If the action is CREATE, then the interface record is fetched and a base
record is created by calling the public api
-- If the action is UPDATE, then , using the interface record values, the
base record is updated by calling the public api.

------------------------------------------------------------------------------
*/

PROCEDURE Process_Interfaced_Deliveries(
	p_delivery_interface_id		IN NUMBER,
	p_action_code			IN VARCHAR2,
	x_dlvy_id			OUT NOCOPY  NUMBER,
	x_return_status			OUT NOCOPY  VARCHAR2) IS

-- Bug 2753330
l_in_rec           WSH_DELIVERIES_GRP.Del_In_Rec_Type;
l_dlvy_attr_tab    WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type;
l_dlvy_out_rec_tab WSH_DELIVERIES_GRP.Del_Out_Tbl_Type;
l_index            NUMBER;
l_number_of_errors            NUMBER := 0;
l_number_of_warnings          NUMBER := 0;
l_api_version_number          NUMBER := 1.0;
--
l_init_msg_list 	VARCHAR2(30) := NULL;
l_return_status 	VARCHAR2(30);
l_msg_count 		NUMBER;
l_msg_data 		VARCHAR2(3000);

l_del_freight_costs	NUMBER;
l_delivery_id 		NUMBER;

l_delivery_name 	VARCHAR2(150);
x_delivery_name 	VARCHAR2(150);

l_curr_ship_method	VARCHAR2(30);

l_loc_interface_error_rec WSH_INTERFACE_VALIDATIONS_PKG.interface_errors_rec_type;

CURSOR del_int_cur IS
SELECT
POOLED_SHIP_TO_LOCATION_CODE,
ULTIMATE_DROPOFF_LOCATION_CODE,
CUSTOMER_NUMBER,
FOB_LOCATION_CODE,
INITIAL_PICKUP_LOCATION_CODE,
INTMED_SHIP_TO_LOCATION_CODE,
ORGANIZATION_CODE,
BATCH_ID,
BILL_FREIGHT_TO,
BOOKING_NUMBER
CARRIED_BY,
COD_AMOUNT,
COD_CHARGE_PAID_BY,
COD_CURRENCY_CODE,
COD_REMIT_TO,
DESCRIPTION,
ENTRY_NUMBER,
FTZ_NUMBER,
HASH_VALUE,
IN_BOND_CODE,
LOADING_ORDER_FLAG,
LOADING_SEQUENCE,
NUMBER_OF_LPN,
PORT_OF_DISCHARGE,
PORT_OF_LOADING,
PROBLEM_CONTACT_REFERENCE,
REASON_OF_TRANSPORT,
ROUTED_EXPORT_TXN,
ROUTING_INSTRUCTIONS,
SERVICE_CONTRACT,
SHIPPING_MARKS,
SOURCE_HEADER_ID,
CARRIER_CODE,
NAME,
PLANNED_FLAG,
STATUS_CODE,
INITIAL_PICKUP_DATE,
INITIAL_PICKUP_LOCATION_ID,
ULTIMATE_DROPOFF_LOCATION_ID,
ULTIMATE_DROPOFF_DATE,
CUSTOMER_ID,
INTMED_SHIP_TO_LOCATION_ID,
POOLED_SHIP_TO_LOCATION_ID,
FREIGHT_TERMS_CODE,
FOB_CODE,
FOB_LOCATION_ID,
WAYBILL,
LOAD_TENDER_FLAG,
ACCEPTANCE_FLAG,
ACCEPTED_BY,
ACCEPTED_DATE,
ACKNOWLEDGED_BY,
CONFIRMED_BY,
ASN_DATE_SENT,
ASN_STATUS_CODE,
ASN_SEQ_NUMBER,
GROSS_WEIGHT,
NET_WEIGHT,
WEIGHT_UOM_CODE,
VOLUME,
VOLUME_UOM_CODE,
ADDITIONAL_SHIPMENT_INFO,
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
TP_ATTRIBUTE_CATEGORY,
TP_ATTRIBUTE1,
TP_ATTRIBUTE2,
TP_ATTRIBUTE3,
TP_ATTRIBUTE4,
TP_ATTRIBUTE5,
TP_ATTRIBUTE6,
TP_ATTRIBUTE7,
TP_ATTRIBUTE8,
TP_ATTRIBUTE9,
TP_ATTRIBUTE10,
TP_ATTRIBUTE11,
TP_ATTRIBUTE12,
TP_ATTRIBUTE13,
TP_ATTRIBUTE14,
TP_ATTRIBUTE15,
CREATION_DATE,
CREATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_LOGIN,
PROGRAM_APPLICATION_ID,
PROGRAM_ID,
PROGRAM_UPDATE_DATE,
REQUEST_ID,
GLOBAL_ATTRIBUTE_CATEGORY,
GLOBAL_ATTRIBUTE1,
GLOBAL_ATTRIBUTE2,
GLOBAL_ATTRIBUTE3,
GLOBAL_ATTRIBUTE4,
GLOBAL_ATTRIBUTE5,
GLOBAL_ATTRIBUTE6,
GLOBAL_ATTRIBUTE7,
GLOBAL_ATTRIBUTE8,
GLOBAL_ATTRIBUTE9,
GLOBAL_ATTRIBUTE10,
GLOBAL_ATTRIBUTE11,
GLOBAL_ATTRIBUTE12,
GLOBAL_ATTRIBUTE13,
GLOBAL_ATTRIBUTE14,
GLOBAL_ATTRIBUTE15,
GLOBAL_ATTRIBUTE16,
GLOBAL_ATTRIBUTE17,
GLOBAL_ATTRIBUTE18,
GLOBAL_ATTRIBUTE19,
GLOBAL_ATTRIBUTE20,
INTERFACE_ACTION_CODE,
LOCK_FLAG,
PROCESS_FLAG,
PROCESS_MODE,
DELETE_FLAG,
PROCESS_STATUS_FLAG,
CURRENCY_CODE,
DELIVERY_TYPE,
ORGANIZATION_ID,
CARRIER_ID,
SHIP_METHOD_CODE,
DOCK_CODE,
CONFIRM_DATE,
DELIVERY_INTERFACE_ID,
DELIVERY_ID,
SERVICE_LEVEL,
MODE_OF_TRANSPORT,
-- J: W/V Changes
WV_FROZEN_FLAG,
--Bug 3458160
SHIPMENT_DIRECTION,
DELIVERED_DATE
FROM WSH_NEW_DEL_INTERFACE
WHERE delivery_interface_id = p_delivery_interface_id
AND INTERFACE_ACTION_CODE = '94X_INBOUND';

cursor	get_carrier ( p_carrier_name in varchar2 ) is
select	distinct carrier_id , manifesting_enabled_flag
from	wsh_carriers_v
where   carrier_name = p_carrier_name;

cursor l_get_enforce_shp_method_csr is
select enforce_ship_method
from   wsh_global_parameters;

cursor l_shp_method_org_csr(p_ship_method_code IN VARCHAR2,
                            p_organization_id IN NUMBER) is
select 'Y'
from wsh_carrier_services wcs,
     wsh_org_carrier_services wocs
where wcs.carrier_service_id  = wocs.carrier_service_id
and wcs.ship_method_code = p_ship_method_code
and wocs.organization_id = p_organization_id;

--exceptions
invalid_ship_method	exception;
freight_cost_processing_error exception;
--
l_carrier_id NUMBER;
l_manifesting_enabled_flag VARCHAR2(100);
l_enforce_ship_method VARCHAR2(100);
l_log_error_flag VARCHAR2(100);
l_valid_shp_method_flag VARCHAR2(100);
l_txn_type VARCHAR2(100);

-- TPW - Distributed changes
l_ship_to_site_use_id number;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PROCESS_INTERFACED_DELIVERIES';
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
	wsh_debug_sv.push(l_module_name,'Process_Interfaced_Deliveries');
	wsh_debug_sv.log (l_module_name,'Delivery interface Id', p_delivery_interface_id);
	wsh_debug_sv.log (l_module_name,'Action Code', p_action_code);
	wsh_debug_sv.log (l_module_name, 'Warehouse type', WSH_INBOUND_SHIP_ADVICE_PKG.G_WAREHOUSE_TYPE);
      END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	IF(p_delivery_interface_id IS NULL)
        THEN
		raise fnd_api.g_exc_error;
	END IF;

        IF p_action_code NOT IN ('CREATE', 'UPDATE')
        THEN
           FND_MESSAGE.SET_NAME('WSH', 'WSH_INVALID_ACTION_CODE');
           FND_MESSAGE.SET_TOKEN('ACT_CODE',p_action_code );
           RAISE fnd_api.g_exc_error;
        END IF;

	l_index := 1;

	-- get the delivery interface record
	--initialize the l_delivery_info record with the interface record values
	FOR l_del_int_rec IN del_int_cur
        LOOP
        -- {

            l_enforce_ship_method := NULL;
            open l_get_enforce_shp_method_csr;
            fetch l_get_enforce_shp_method_csr into l_enforce_ship_method;
            close l_get_enforce_shp_method_csr;

            IF l_debug_on THEN
	        wsh_debug_sv.log (l_module_name, ' Ship Method ', l_del_int_rec.ship_method_code);
            END IF;
	        -- need to send delivery id and name only for update
                --Bug Bug 3458160
		IF(p_action_code = 'UPDATE') THEN
                   l_dlvy_attr_tab(l_index).DELIVERY_ID  := l_del_int_rec.delivery_id;
                   l_dlvy_attr_tab(l_index).NAME         := l_del_int_rec.name;
                   l_dlvy_attr_tab(l_index).delivered_date :=
                                                  l_del_int_rec.delivered_date;
                ELSIF p_action_code = 'CREATE' THEN
                   l_dlvy_attr_tab(l_index).shipment_direction :=
                                              l_del_int_rec.shipment_direction;
                   IF (WSH_UTIL_CORE.GC3_IS_INSTALLED = 'N'
                     AND wsh_util_core.tp_is_installed = 'Y')
                   THEN
                      l_dlvy_attr_tab(l_index).ignore_for_planning  := 'Y';
                   END IF;
		END IF; -- if p_action_code=update

		-- This is to pass the carrier information to the Third Party Instance.
		if ( nvl(l_del_int_rec.carrier_code, fnd_api.g_miss_char) <> fnd_api.g_miss_char )
                THEN
                -- {
                   l_carrier_id := NULL;
                   l_manifesting_enabled_flag := NULL;
		   open  get_carrier( l_del_int_rec.carrier_code );
		   fetch get_carrier into l_carrier_id, l_manifesting_enabled_flag;
		   close get_carrier;
                   IF l_debug_on THEN
                     wsh_debug_sv.log (l_module_name, ' l_carrier_id', l_carrier_id);
                     wsh_debug_sv.log (l_module_name, ' l_manifesting_enabled_flag', l_manifesting_enabled_flag);
                   END IF;

                   l_del_int_rec.carrier_id := l_carrier_id;
                -- }
		end if;
                --
                IF(nvl(WSH_INBOUND_SHIP_ADVICE_PKG.G_WAREHOUSE_TYPE, FND_API.G_MISS_CHAR) = 'CMS')
                THEN
                -- {
                    -- For updates from CMS, need to check if the ship method code
                    -- is the same. Error out if different.
                    IF(p_action_code = 'UPDATE')
                    THEN
                    -- {
                        -- These changes are made to allow the manifesting system to send a changed
                        -- combo of carrier, service level, and mode of transport.
                        IF ( nvl(l_del_int_rec.carrier_code, fnd_api.g_miss_char) = fnd_api.g_miss_char) THEN
                        --{
                            IF l_debug_on THEN
	                      wsh_debug_sv.logmsg(l_module_name, 'Carrier is null');
                            END IF;
                            l_loc_interface_error_rec.p_message_name := 'WSH_NULL_INB_CARRIER';
                            l_log_error_flag := 'Y';
                        --}
                        ELSIF (l_carrier_id IS NULL) THEN
                        --{
                            IF l_debug_on THEN
	                      wsh_debug_sv.logmsg(l_module_name, 'Carrier Id is null');
                            END IF;
                            l_loc_interface_error_rec.p_message_name := 'WSH_INVALID_INB_CARRIER';
                            l_log_error_flag := 'Y';
                        --}
                        ELSIF (nvl(l_manifesting_enabled_flag, 'N') = 'N' ) THEN
                        --{
                            IF l_debug_on THEN
	                      wsh_debug_sv.logmsg(l_module_name, 'Carrier is not Manifesting Enabled');
                            END IF;
                            l_loc_interface_error_rec.p_message_name := 'WSH_INB_CAR_NOT_MFST_ENABLED';
                            l_log_error_flag := 'Y';
                        --}
                        END IF;
                        IF (
                            nvl(l_enforce_ship_method,'N') = 'Y'
                            AND nvl(l_del_int_rec.ship_method_code, FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR
                           ) THEN
                        --{
                            IF l_debug_on THEN
	                      wsh_debug_sv.logmsg(l_module_name, 'Ship Method is enforced for the org and inbound Ship Method is NULL');
                            END IF;
                            l_loc_interface_error_rec.p_message_name := 'WSH_NULL_INB_SHIP_METHOD';
                            l_log_error_flag := 'Y';
                        --}
                        ELSIF nvl(l_del_int_rec.ship_method_code, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR
                        THEN
                        --{
                          l_valid_shp_method_flag := NULL;
                          open l_shp_method_org_csr(l_del_int_rec.ship_method_code,  l_del_int_rec.organization_id);
                          fetch l_shp_method_org_csr into l_valid_shp_method_flag;
                          close l_shp_method_org_csr;
                          IF l_debug_on THEN
	                    wsh_debug_sv.log (l_module_name, ' l_valid_shp_method_flag ', l_valid_shp_method_flag);
                          END IF;

                          IF (nvl(l_valid_shp_method_flag,'N') = 'N') THEN
                          --{
	                    IF l_debug_on THEN
	                      wsh_debug_sv.logmsg(l_module_name, 'Ship Method is not valid');
                            END IF;
                            l_loc_interface_error_rec.p_message_name := 'WSH_OI_INVALID_SHIP_METHOD';
                            l_log_error_flag := 'Y';
                          --}
                          END IF;

                        --}
                        END IF;
                        IF ( l_log_error_flag = 'Y') THEN
                        --{
                            l_loc_interface_error_rec.p_interface_table_name := 'WSH_NEW_DEL_INTERFACE';
                            l_loc_interface_error_rec.p_interface_id :=  p_delivery_interface_id;
                            Log_Errors(
                              p_loc_interface_errors_rec   => l_loc_interface_error_rec,
                              p_api_name                   =>'Process_Interfaced_Deliveries, Action=UPDATE' ,
                              x_return_status              => l_return_status);

                            l_log_error_flag := 'N';
                            RAISE FND_API.G_EXC_ERROR;
                        --}
                        END IF;
                        /*
                        -- Commented this part of the code  as we allow the
                        -- manifesting system to change the carrier, srv lvl, and mot.
                        SELECT ship_method_code INTO l_curr_ship_method
                        FROM wsh_new_deliveries
                        WHERE delivery_id = l_del_int_rec.delivery_id;

                        IF l_debug_on THEN
                           wsh_debug_sv.log (l_module_name,'Current ship method', l_curr_ship_method);
                           wsh_debug_sv.log (l_module_name,'Incoming ship method', l_del_int_rec.ship_method_code);
                        END IF;

                       IF nvl(l_curr_ship_method,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR
                       THEN
                       -- {
                           IF(l_curr_ship_method <> nvl(l_del_int_rec.ship_method_code, FND_API.G_MISS_CHAR)) THEN
                              raise invalid_ship_method;
                           END IF;
                       -- }
                       END IF;
                       -- Bug 2753330
                       -- Since ship_method_code should not be updateable for CMS inbound,
                       -- Need to send G_MISS_CHAR for code and name
                       -- so that the database value will be used for ship method code
                       l_dlvy_attr_tab(l_index).ship_method_code := FND_API.G_MISS_CHAR;
                       */
                    -- }
                    END IF;
                    l_dlvy_attr_tab(l_index).ship_method_name := FND_API.G_MISS_CHAR;
                    l_dlvy_attr_tab(l_index).SHIP_METHOD_CODE                := nvl(l_del_int_rec.SHIP_METHOD_CODE, FND_API.G_MISS_CHAR);
                ELSE
                -- Need to send ship method code only for non-cms cases.
                    l_dlvy_attr_tab(l_index).SHIP_METHOD_CODE                := nvl(l_del_int_rec.SHIP_METHOD_CODE, FND_API.G_MISS_CHAR);
                -- }
                END IF;


           l_dlvy_attr_tab(l_index).DELIVERY_TYPE                    := nvl(l_del_int_rec.delivery_type, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).LOADING_SEQUENCE       	:= nvl(l_del_int_rec.loading_sequence, FND_API.G_MISS_NUM);
           l_dlvy_attr_tab(l_index).LOADING_ORDER_FLAG              := nvl(l_del_int_rec.loading_order_flag, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).INITIAL_PICKUP_DATE    	:= nvl(l_del_int_rec.initial_pickup_date, FND_API.G_MISS_DATE);
           l_dlvy_attr_tab(l_index).INITIAL_PICKUP_LOCATION_ID      := nvl(l_del_int_rec.initial_pickup_location_id, FND_API.G_MISS_NUM);
           l_dlvy_attr_tab(l_index).INITIAL_PICKUP_LOCATION_CODE    := nvl(l_del_int_rec.initial_pickup_location_code, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).ORGANIZATION_ID        	:= nvl(l_del_int_rec.organization_id, FND_API.G_MISS_NUM);
           l_dlvy_attr_tab(l_index).ORGANIZATION_CODE              := nvl(l_del_int_rec.organization_code, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).ULTIMATE_DROPOFF_LOCATION_ID    := nvl(l_del_int_rec.ultimate_dropoff_location_id, FND_API.G_MISS_NUM);
		-- Since the location id has been derived already, we should send the code only when the id is null
		IF(l_del_int_rec.ultimate_dropoff_location_id IS NULL)
                THEN
                   l_dlvy_attr_tab(l_index).ULTIMATE_DROPOFF_LOCATION_CODE  := nvl(l_del_int_rec.ULTIMATE_DROPOFF_LOCATION_CODE, FND_API.G_MISS_CHAR);
                END IF;
           l_dlvy_attr_tab(l_index).ULTIMATE_DROPOFF_DATE  	:= nvl(l_del_int_rec.ULTIMATE_DROPOFF_DATE, FND_API.G_MISS_DATE);
           l_dlvy_attr_tab(l_index).CUSTOMER_ID            	:= nvl(l_del_int_rec.CUSTOMER_ID, FND_API.G_MISS_NUM);
           l_dlvy_attr_tab(l_index).CUSTOMER_NUMBER                 := nvl(l_del_int_rec.customer_number, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).INTMED_SHIP_TO_LOCATION_ID      := nvl(l_del_int_rec.INTMED_SHIP_TO_LOCATION_ID, FND_API.G_MISS_NUM);

		-- Since the location id has been derived already, we should send the code only when the id is null
		IF(l_del_int_rec.INTMED_SHIP_TO_LOCATION_ID IS NULL)
                THEN
                    l_dlvy_attr_tab(l_index).INTMED_SHIP_TO_LOCATION_CODE    := nvl(l_del_int_rec.INTMED_SHIP_TO_LOCATION_CODE, FND_API.G_MISS_CHAR);
                END IF;

           l_dlvy_attr_tab(l_index).POOLED_SHIP_TO_LOCATION_ID      := nvl(l_del_int_rec.POOLED_SHIP_TO_LOCATION_ID, FND_API.G_MISS_NUM);
		-- Send the code only when the id is null
		IF(l_del_int_rec.POOLED_SHIP_TO_LOCATION_ID IS NULL) THEN
                   l_dlvy_attr_tab(l_index).POOLED_SHIP_TO_LOCATION_CODE    := nvl(l_del_int_rec.POOLED_SHIP_TO_LOCATION_CODE, FND_API.G_MISS_CHAR);
                END IF;

           l_dlvy_attr_tab(l_index).FREIGHT_TERMS_CODE              := nvl(l_del_int_rec.FREIGHT_TERMS_CODE, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).FOB_CODE                        := nvl(l_del_int_rec.FOB_CODE, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).FOB_LOCATION_ID        	:= nvl(l_del_int_rec.FOB_LOCATION_ID, FND_API.G_MISS_NUM);
           l_dlvy_attr_tab(l_index).FOB_LOCATION_CODE              := nvl(l_del_int_rec.FOB_LOCATION_CODE, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).WAYBILL                        := nvl(l_del_int_rec.waybill, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).DOCK_CODE                 := nvl(l_del_int_rec.dock_code, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).ACCEPTANCE_FLAG          := nvl(l_del_int_rec.acceptance_flag, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).ACCEPTED_BY             := nvl(l_del_int_rec.accepted_by, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).ACCEPTED_DATE          := nvl(l_del_int_rec.accepted_date, FND_API.G_MISS_DATE);
           l_dlvy_attr_tab(l_index).ACKNOWLEDGED_BY          := nvl(l_del_int_rec.acknowledged_by, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).CONFIRMED_BY             := nvl(l_del_int_rec.CONFIRMED_BY, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).CONFIRM_DATE           := nvl(l_del_int_rec.CONFIRM_DATE, FND_API.G_MISS_DATE);
           l_dlvy_attr_tab(l_index).ASN_DATE_SENT          := nvl(l_del_int_rec.ASN_DATE_SENT, FND_API.G_MISS_DATE);
           l_dlvy_attr_tab(l_index).ASN_STATUS_CODE              := nvl(l_del_int_rec.ASN_STATUS_CODE, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).ASN_SEQ_NUMBER        := nvl(l_del_int_rec.ASN_SEQ_NUMBER, FND_API.G_MISS_NUM);
           l_dlvy_attr_tab(l_index).GROSS_WEIGHT           := nvl(l_del_int_rec.GROSS_WEIGHT, FND_API.G_MISS_NUM);
           l_dlvy_attr_tab(l_index).NET_WEIGHT             := nvl(l_del_int_rec.NET_WEIGHT, FND_API.G_MISS_NUM);
           l_dlvy_attr_tab(l_index).WEIGHT_UOM_CODE        := nvl(l_del_int_rec.WEIGHT_UOM_CODE, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).VOLUME                 := nvl(l_del_int_rec.VOLUME , FND_API.G_MISS_NUM);
           l_dlvy_attr_tab(l_index).VOLUME_UOM_CODE        := nvl(l_del_int_rec.VOLUME_UOM_CODE, FND_API.G_MISS_CHAR);
           -- J: W/V Changes
           l_dlvy_attr_tab(l_index).WV_FROZEN_FLAG         := l_del_int_rec.WV_FROZEN_FLAG;
           l_dlvy_attr_tab(l_index).ADDITIONAL_SHIPMENT_INFO      := nvl(l_del_int_rec.ADDITIONAL_SHIPMENT_INFO  , FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).CURRENCY_CODE                 := nvl(l_del_int_rec.CURRENCY_CODE, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).ATTRIBUTE_CATEGORY       := nvl(l_del_int_rec.ATTRIBUTE_CATEGORY , FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).ATTRIBUTE1               := nvl(l_del_int_rec.ATTRIBUTE1, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).ATTRIBUTE2               := nvl(l_del_int_rec.ATTRIBUTE2, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).ATTRIBUTE3               := nvl(l_del_int_rec.ATTRIBUTE3, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).ATTRIBUTE4               := nvl(l_del_int_rec.ATTRIBUTE4, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).ATTRIBUTE5               := nvl(l_del_int_rec.ATTRIBUTE5, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).ATTRIBUTE6               := nvl(l_del_int_rec.ATTRIBUTE6, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).ATTRIBUTE7               := nvl(l_del_int_rec.ATTRIBUTE7, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).ATTRIBUTE8               := nvl(l_del_int_rec.ATTRIBUTE8, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).ATTRIBUTE9               := nvl(l_del_int_rec.ATTRIBUTE9, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).ATTRIBUTE10              := nvl(l_del_int_rec.ATTRIBUTE10, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).ATTRIBUTE11              := nvl(l_del_int_rec.ATTRIBUTE11, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).ATTRIBUTE12              := nvl(l_del_int_rec.ATTRIBUTE12, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).ATTRIBUTE13              := nvl(l_del_int_rec.ATTRIBUTE13, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).ATTRIBUTE14              := nvl(l_del_int_rec.ATTRIBUTE14, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).ATTRIBUTE15              := nvl(l_del_int_rec.ATTRIBUTE15, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).TP_ATTRIBUTE_CATEGORY    := nvl(l_del_int_rec.TP_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).TP_ATTRIBUTE1            := nvl(l_del_int_rec.TP_ATTRIBUTE1, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).TP_ATTRIBUTE2            := nvl(l_del_int_rec.TP_ATTRIBUTE2, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).TP_ATTRIBUTE3            := nvl(l_del_int_rec.TP_ATTRIBUTE3, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).TP_ATTRIBUTE4            := nvl(l_del_int_rec.TP_ATTRIBUTE4, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).TP_ATTRIBUTE5            := nvl(l_del_int_rec.TP_ATTRIBUTE5, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).TP_ATTRIBUTE6            := nvl(l_del_int_rec.TP_ATTRIBUTE6, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).TP_ATTRIBUTE7            := nvl(l_del_int_rec.TP_ATTRIBUTE7, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).TP_ATTRIBUTE8            := nvl(l_del_int_rec.TP_ATTRIBUTE8, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).TP_ATTRIBUTE9            := nvl(l_del_int_rec.TP_ATTRIBUTE9, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).TP_ATTRIBUTE10           := nvl(l_del_int_rec.TP_ATTRIBUTE10, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).TP_ATTRIBUTE11           := nvl(l_del_int_rec.TP_ATTRIBUTE11, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).TP_ATTRIBUTE12           := nvl(l_del_int_rec.TP_ATTRIBUTE12, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).TP_ATTRIBUTE13           := nvl(l_del_int_rec.TP_ATTRIBUTE13, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).TP_ATTRIBUTE14           := nvl(l_del_int_rec.TP_ATTRIBUTE14, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).TP_ATTRIBUTE15           := nvl(l_del_int_rec.TP_ATTRIBUTE15, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).GLOBAL_ATTRIBUTE_CATEGORY       := nvl(l_del_int_rec.GLOBAL_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).GLOBAL_ATTRIBUTE1        := nvl(l_del_int_rec.GLOBAL_ATTRIBUTE1 , FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).GLOBAL_ATTRIBUTE2        := nvl(l_del_int_rec.GLOBAL_ATTRIBUTE2 , FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).GLOBAL_ATTRIBUTE3        := nvl(l_del_int_rec.GLOBAL_ATTRIBUTE3 , FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).GLOBAL_ATTRIBUTE4        := nvl(l_del_int_rec.GLOBAL_ATTRIBUTE4 , FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).GLOBAL_ATTRIBUTE5        := nvl(l_del_int_rec.GLOBAL_ATTRIBUTE5 , FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).GLOBAL_ATTRIBUTE6        := nvl(l_del_int_rec.GLOBAL_ATTRIBUTE6 , FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).GLOBAL_ATTRIBUTE7        := nvl(l_del_int_rec.GLOBAL_ATTRIBUTE7 , FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).GLOBAL_ATTRIBUTE8        := nvl(l_del_int_rec.GLOBAL_ATTRIBUTE8 , FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).GLOBAL_ATTRIBUTE9        := nvl(l_del_int_rec.GLOBAL_ATTRIBUTE9 , FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).GLOBAL_ATTRIBUTE10       := nvl(l_del_int_rec.GLOBAL_ATTRIBUTE10, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).GLOBAL_ATTRIBUTE11       := nvl(l_del_int_rec.GLOBAL_ATTRIBUTE11, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).GLOBAL_ATTRIBUTE12       := nvl(l_del_int_rec.GLOBAL_ATTRIBUTE12, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).GLOBAL_ATTRIBUTE13       := nvl(l_del_int_rec.GLOBAL_ATTRIBUTE13, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).GLOBAL_ATTRIBUTE14       := nvl(l_del_int_rec.GLOBAL_ATTRIBUTE14, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).GLOBAL_ATTRIBUTE15       := nvl(l_del_int_rec.GLOBAL_ATTRIBUTE15, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).GLOBAL_ATTRIBUTE16       := nvl(l_del_int_rec.GLOBAL_ATTRIBUTE16, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).GLOBAL_ATTRIBUTE17       := nvl(l_del_int_rec.GLOBAL_ATTRIBUTE17, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).GLOBAL_ATTRIBUTE18       := nvl(l_del_int_rec.GLOBAL_ATTRIBUTE18, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).GLOBAL_ATTRIBUTE19       := nvl(l_del_int_rec.GLOBAL_ATTRIBUTE19, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).GLOBAL_ATTRIBUTE20       := nvl(l_del_int_rec.GLOBAL_ATTRIBUTE20, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).PROBLEM_CONTACT_REFERENCE     := nvl(l_del_int_rec.PROBLEM_CONTACT_REFERENCE, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).COD_AMOUNT		:= nvl(l_del_int_rec.COD_AMOUNT, FND_API.G_MISS_NUM);
           l_dlvy_attr_tab(l_index).COD_CURRENCY_CODE	:= nvl(l_del_int_rec.COD_CURRENCY_CODE , FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).COD_REMIT_TO		:= nvl(l_del_int_rec.COD_REMIT_TO, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).COD_CHARGE_PAID_BY	:= nvl(l_del_int_rec.COD_CHARGE_PAID_BY , FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).PORT_OF_LOADING	:= nvl(l_del_int_rec.PORT_OF_LOADING , FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).PORT_OF_DISCHARGE	:= nvl(l_del_int_rec.PORT_OF_DISCHARGE , FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).FTZ_NUMBER		:= nvl(l_del_int_rec.FTZ_NUMBER, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).ROUTED_EXPORT_TXN	:= nvl(l_del_int_rec.ROUTED_EXPORT_TXN, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).ENTRY_NUMBER		:= nvl(l_del_int_rec.ENTRY_NUMBER, FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).ROUTING_INSTRUCTIONS	:= nvl(l_del_int_rec.ROUTING_INSTRUCTIONS , FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).IN_BOND_CODE		:= nvl(l_del_int_rec.IN_BOND_CODE , FND_API.G_MISS_CHAR);
           l_dlvy_attr_tab(l_index).SHIPPING_MARKS		:= nvl(l_del_int_rec.SHIPPING_MARKS, FND_API.G_MISS_CHAR);
           l_txn_type                                           := l_del_int_rec.INTERFACE_ACTION_CODE;
           IF (nvl(l_txn_type,'!!!!') = '94X_INBOUND') THEN
             l_dlvy_attr_tab(l_index).CARRIER_ID                := l_del_int_rec.carrier_id;
             l_dlvy_attr_tab(l_index).CARRIER_CODE              := l_del_int_rec.carrier_code;
             l_dlvy_attr_tab(l_index).SERVICE_LEVEL             := l_del_int_rec.SERVICE_LEVEL;
             l_dlvy_attr_tab(l_index).MODE_OF_TRANSPORT         := l_del_int_rec.MODE_OF_TRANSPORT;
           ELSE
             l_dlvy_attr_tab(l_index).CARRIER_ID                := nvl(l_del_int_rec.carrier_id, FND_API.G_MISS_NUM);
             l_dlvy_attr_tab(l_index).CARRIER_CODE              := nvl(l_del_int_rec.carrier_code, FND_API.G_MISS_CHAR);
             l_dlvy_attr_tab(l_index).SERVICE_LEVEL             := nvl(l_del_int_rec.SERVICE_LEVEL, FND_API.G_MISS_CHAR);
             l_dlvy_attr_tab(l_index).MODE_OF_TRANSPORT := nvl(l_del_int_rec.MODE_OF_TRANSPORT, FND_API.G_MISS_CHAR);
           END IF;
           l_txn_type := null;

               IF l_debug_on THEN
                wsh_debug_sv.log (l_module_name, ' Service Level ', l_del_int_rec.SERVICE_LEVEL);
                wsh_debug_sv.log (l_module_name, ' Transportation Method ', l_del_int_rec.MODE_OF_TRANSPORT);
                wsh_debug_sv.logmsg (l_module_name, '--------------------------------------------------------------------------------------------');
                wsh_debug_sv.logmsg (l_module_name, 'The following are the values of Carrier, Service Level and MOT being passed to the Group API');
                wsh_debug_sv.logmsg (l_module_name, '--------------------------------------------------------------------------------------------');
                wsh_debug_sv.logmsg (l_module_name, '********************************************************************************************');
                wsh_debug_sv.logmsg (l_module_name, '--------------------------------------------------------------------------------------------');
                wsh_debug_sv.log (l_module_name, 'l_dlvy_attr_tab(l_index).CARRIER_ID',l_dlvy_attr_tab(l_index).CARRIER_ID);
                wsh_debug_sv.log (l_module_name, 'l_dlvy_attr_tab(l_index).CARRIER_CODE',l_dlvy_attr_tab(l_index).CARRIER_CODE);
                wsh_debug_sv.log (l_module_name, 'l_dlvy_attr_tab(l_index).SERVICE_LEVEL',l_dlvy_attr_tab(l_index).SERVICE_LEVEL);
                wsh_debug_sv.log (l_module_name, 'l_dlvy_attr_tab(l_index).MODE_OF_TRANSPORT',l_dlvy_attr_tab(l_index).MODE_OF_TRANSPORT);
                wsh_debug_sv.log (l_module_name, 'l_dlvy_attr_tab(l_index).SHIP_METHOD_CODE',l_dlvy_attr_tab(l_index).SHIP_METHOD_CODE);
                wsh_debug_sv.logmsg (l_module_name, '--------------------------------------------------------------------------------------------');
                wsh_debug_sv.logmsg (l_module_name, '********************************************************************************************');
                wsh_debug_sv.logmsg (l_module_name, '--------------------------------------------------------------------------------------------');
               END IF;

               l_index := l_index + 1;
        -- }
	END LOOP; -- for l_del_int_rec

        --Bug 3458160
        -- TPW - Distributed changes
        IF (p_action_code = 'CREATE') AND (nvl(WSH_INBOUND_SHIP_ADVICE_PKG.G_WAREHOUSE_TYPE, '!') <> 'TW2') THEN
           l_in_rec.caller      := 'WSH_TPW_INBOUND';
        ELSE
           l_in_rec.caller      := 'WSH_INBOUND';
        END IF;
        l_in_rec.action_code := p_action_code;

        wsh_interface_grp.Create_Update_Delivery(
           p_api_version_number   => l_api_version_number,
           p_init_msg_list        => FND_API.G_FALSE,
           p_commit	       => FND_API.G_FALSE,
           p_in_rec               => l_in_rec,
           p_rec_attr_tab	       => l_dlvy_attr_tab,
           x_del_out_rec_tab      => l_dlvy_out_rec_tab,
           x_return_status        => l_return_status,
           x_msg_count            => l_msg_count,
           x_msg_data             => l_msg_data);

         IF l_debug_on THEN
            wsh_debug_sv.log (l_module_name, 'Return status from create_Update_delivery',l_return_status);
            wsh_debug_sv.log (l_module_name, 'Create Update Delivery api msg count', l_msg_count);
            wsh_debug_sv.log (l_module_name, 'Create Update Delivery api msg', l_msg_data);
         END IF;

        IF(l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS)
        THEN
        -- {
           l_loc_interface_error_rec.p_interface_table_name := 'WSH_NEW_DEL_INTERFACE';
           l_loc_interface_error_rec.p_interface_id :=  p_delivery_interface_id;
           --
           Log_Errors(
               p_loc_interface_errors_rec   => l_loc_interface_error_rec,
               p_msg_data               => l_msg_data,
               p_api_name               => 'WSH_INTERFACE_GRP.Create_Update_Delivery' ,
               x_return_status          => l_return_status);
               --
               IF l_debug_on THEN
                  wsh_debug_sv.log (l_module_name,'Log_Errors l_return_status',l_return_status);
               END IF;

               IF p_action_code = 'CREATE'
               THEN
               -- {
                   FND_MESSAGE.SET_NAME('WSH', 'WSH_CREATE_DLVY_ERROR');
                   FND_MESSAGE.SET_TOKEN('DEL_INT',p_delivery_interface_id);
               ELSIF p_action_code = 'UPDATE'
               THEN
                   FND_MESSAGE.SET_NAME('WSH', 'WSH_UPDATE_DLVY_ERROR');
                   FND_MESSAGE.SET_TOKEN('DEL_INT', p_delivery_interface_id);
               -- }
               END IF;
               --
               RAISE fnd_api.g_exc_error;
        -- }
        END IF;

        -- send the newly created delivery in the out parameter
        IF p_action_code = 'CREATE'
        THEN
        -- {
            IF l_debug_on THEN
               wsh_debug_sv.log (l_module_name, 'New delivery Id created', l_dlvy_out_rec_tab(l_dlvy_out_rec_tab.first).delivery_id);
            END IF;
            x_dlvy_id := l_dlvy_out_rec_tab(l_dlvy_out_rec_tab.first).delivery_id;

            -- TPW - Distributed changes
            IF (nvl(WSH_INBOUND_SHIP_ADVICE_PKG.G_WAREHOUSE_TYPE, '!') = 'TW2') THEN
              update wsh_new_del_interface
              set    delivery_id = x_dlvy_id
              where  delivery_interface_id = p_delivery_interface_id;

              UPDATE wsh_del_legs_interface
              SET delivery_id = x_dlvy_id
              WHERE delivery_interface_id = p_delivery_interface_id;
            END IF;
        -- }
        END IF;

        -- TPW - Distributed changes
        SELECT count(*) INTO l_del_freight_costs
        FROM wsh_freight_costs_interface
        WHERE delivery_interface_id = p_delivery_interface_id
        AND INTERFACE_ACTION_CODE = '94X_INBOUND';

        IF l_debug_on THEN
           wsh_debug_sv.log (l_module_name, 'Delivery Freight record count', l_del_freight_costs);
        END IF;

        IF(l_del_freight_costs > 0)
        THEN
        -- {
            IF l_debug_on THEN
               wsh_debug_sv.log (l_module_name, 'calling process freight for delivery interface', p_delivery_interface_id);
            END IF;

            Process_Int_Freight_Costs(
                p_delivery_interface_id  => p_delivery_interface_id,
                x_return_status          => l_return_status);

            IF l_debug_on THEN
               wsh_debug_sv.log (l_module_name, 'Return status from process int freight costs', l_return_status);
            END IF;
            --
            IF(l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
               raise freight_cost_processing_error;
            END IF;
        -- }
        END IF;

      IF l_debug_on THEN
	wsh_debug_sv.pop(l_module_name);
      END IF;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      --
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'FND_API.G_EXC_ERROR exception has occured.', wsh_debug_sv.c_excep_level);
         wsh_debug_sv.pop(l_module_name, 'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
   --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      --
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.', wsh_debug_sv.c_excep_level);
         wsh_debug_sv.pop(l_module_name, 'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
   --
   WHEN wsh_util_core.g_exc_warning THEN
      x_return_status := wsh_util_core.g_ret_sts_warning;
      --
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'WSH_UTIL_CORE.G_EXC_WARNING exception has occured ', wsh_debug_sv.c_excep_level);
         wsh_debug_sv.pop(l_module_name, 'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
   --
  WHEN invalid_ship_method THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'invalid_ship_method exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:invalid_ship_method');
        END IF;
  WHEN freight_cost_processing_error THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'freight_cost_processing_error exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:freight_cost_processing_error');
        END IF;
   WHEN OTHERS THEN
      x_return_status := wsh_util_core.g_ret_sts_unexp_error;
      wsh_util_core.default_handler('WSH_INTERFACE_COMMON_ACTIONS.PROCESS_INTERFACED_DELIVERIES');

      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'Unexpected error has occured. Oracle error message is ' || SQLERRM, wsh_debug_sv.c_unexpec_err_level);
         wsh_debug_sv.pop(l_module_name, 'EXCEPTION:OTHERS');
      END IF;

END Process_Interfaced_Deliveries;

/*
-----------------------------------------------------------------------------
   PROCEDURE  : Delivery_Interface_Wrapper
   PARAMETERS : p_delivery_interface_id		IN NUMBER,
		p_action_code			CREATE or UPDATE or CANCEL
		x_return_status			OUT VARCHAR2)

  DESCRIPTION :
-- This is the wrapper procedure that will be called by the Process_Inbound
for Shipment_Advice or Shipment_Request.
-- This takes in a delivery_interface_id and the action code
-- If the action code is CREATE, then the delivery is created in the base
tables based on the data in the delivery-interface tables
- Then for each of the delivery details in the interface tables, a corresponding
delivery detail is created in the base tables.
-- Then the newly created base delivery details are assigned to the newly
created base delivery.
-- If the action code is UPDATE, then the base delivery is updated first
-- Followed by updates of base delivery details

------------------------------------------------------------------------------
*/

PROCEDURE Delivery_Interface_Wrapper(
	p_delivery_interface_id		IN NUMBER,
	p_action_code			IN VARCHAR2,
	x_delivery_id			IN OUT NOCOPY  NUMBER,
	x_return_status			OUT NOCOPY  VARCHAR2) IS

-- variables
l_return_status 	VARCHAR2(30);
l_delivery_id		NUMBER;

l_created_delivery_id 	NUMBER;
l_new_del_detail_id 	NUMBER;
l_action_code		VARCHAR2(30);

l_loc_interface_error_rec WSH_INTERFACE_VALIDATIONS_PKG.interface_errors_rec_type;
-- cursors
CURSOR del_id IS
SELECT delivery_id ,
-- J: W/V Changes
       gross_weight,
       net_weight,
       volume,
       wv_frozen_flag
FROM wsh_new_del_interface
WHERE delivery_interface_id = p_delivery_interface_id
AND INTERFACE_ACTION_CODE = '94X_INBOUND';

cursor org_del_id(c_del_id IN NUMBER) IS
SELECT NVL(gross_weight,0),
       NVL(net_weight,0),
       NVL(volume,0)
FROM   wsh_new_deliveries
WHERE  delivery_id = c_del_id;


-- J: W/V changes
l_api_version           NUMBER := 1.0;
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(3000);
l_gross_weight          NUMBER;
l_net_weight            NUMBER;
l_volume                NUMBER;
l_wv_frozen_flag        VARCHAR2(1);
l_tmp_del_id            NUMBER;
l_org_gross_weight      NUMBER;
l_org_net_weight        NUMBER;
l_org_volume            NUMBER;

-- exceptions
invalid_action_code 		exception;
process_del_details_failed 	exception;
process_delivery_failed 	exception;
process_delivery_wv_failed      exception;
cancel_lines_failed 		exception;
invalid_input			exception;
no_lock_found			exception;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELIVERY_INTERFACE_WRAPPER';
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
	wsh_debug_sv.push(l_module_name,'Delivery_Interface_Wrapper');
	wsh_debug_sv.log (l_module_name,'Delivery interface Id', p_delivery_interface_id);
	wsh_debug_sv.log (l_module_name,'Action Code', p_action_code);
       END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	l_action_code := p_action_code;

	-- First process the delivery
	IF(l_action_code IN ('CREATE', 'UPDATE')) THEN
		IF(p_delivery_interface_id IS NULL) THEN
			raise invalid_input;
		END IF;

                OPEN del_id;
                FETCH del_id INTO l_delivery_id,
                                  -- J: W/V Changes
                                  l_gross_weight,
                                  l_net_weight,
                                  l_volume,
                                  l_wv_frozen_flag;
                CLOSE del_id;

		IF(l_action_code = 'UPDATE') THEN

			--Lock the records
			Lock_Delivery_And_Details(
			p_delivery_id => l_delivery_id,
			x_return_status => l_return_status);

                       IF l_debug_on THEN
			wsh_debug_sv.log (l_module_name,'Return status from lock delivery and details', l_return_status);
                       END IF;

			IF(l_return_status <> wsh_util_core.g_ret_sts_success) THEN
				l_loc_interface_error_rec.p_interface_table_name := 'WSH_NEW_DEL_INTERFACE';
				l_loc_interface_error_rec.p_interface_id :=  p_delivery_interface_id;
				l_loc_interface_error_rec.p_message_name := 'WSH_NO_LOCK';

				  Log_Errors(
					p_loc_interface_errors_rec   => l_loc_interface_error_rec,
                                           p_api_name       =>'Delivery_Interface_Wrapper, Action=UPDATE' ,
				      x_return_status          => l_return_status);

                                  IF l_debug_on THEN
			           wsh_debug_sv.log (l_module_name,'Log_Errors l_return_status', l_return_status);
                                  END IF;
				raise no_lock_found;
			END IF;

                -- TPW - Distributed changes
                ELSIF (l_action_code = 'CREATE') AND (nvl(WSH_INBOUND_SHIP_ADVICE_PKG.G_WAREHOUSE_TYPE, '!') = 'TW2') THEN

                        --Lock the records
                        Lock_Delivery_Details(
                          p_delivery_interface_id => p_delivery_interface_id,
                          x_return_status => l_return_status);

                       IF l_debug_on THEN
                        wsh_debug_sv.log (l_module_name,'Return status from Lock_Delivery_Details', l_return_status);
                       END IF;

                        IF(l_return_status <> wsh_util_core.g_ret_sts_success) THEN
                                l_loc_interface_error_rec.p_interface_table_name := 'WSH_NEW_DEL_INTERFACE';
                                l_loc_interface_error_rec.p_interface_id :=  p_delivery_interface_id;
                                l_loc_interface_error_rec.p_message_name := 'WSH_NO_LOCK';

                                  Log_Errors(
                                        p_loc_interface_errors_rec   => l_loc_interface_error_rec,
                                           p_api_name       =>'Delivery_Interface_Wrapper, Action=CREATE' ,
                                      x_return_status          => l_return_status);

                                  IF l_debug_on THEN
                                   wsh_debug_sv.log (l_module_name,'Log_Errors l_return_status', l_return_status);
                                  END IF;
                                raise no_lock_found;
                        END IF;

		END IF;

		Process_Interfaced_Deliveries(
			p_delivery_interface_id	=> p_delivery_interface_id,
			p_action_code		=> l_action_code,
			x_dlvy_id		=> l_created_delivery_id,
			x_return_status		=> l_return_status);

                IF l_debug_on THEN
		 wsh_debug_sv.log (l_module_name, 'Return Status from Process Deliveries', l_return_status);
		END IF;

		IF(l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
			raise process_delivery_failed;
		END IF;

		IF(l_action_code = 'CREATE' AND l_created_delivery_id is NULL ) THEN
			raise process_delivery_failed;
		END IF;

		-- set the out parameter
		x_delivery_id := l_created_delivery_id;

                -- Now process the delivery details
                -- TPW - Distributed changes
                IF (nvl(WSH_INBOUND_SHIP_ADVICE_PKG.G_WAREHOUSE_TYPE, '!') = 'TW2') THEN
		  Process_Interfaced_Del_Details(
			p_delivery_interface_id		=> p_delivery_interface_id,
			p_delivery_id			=> l_created_delivery_id,
			p_new_delivery_id		=> l_created_delivery_id,
			p_action_code			=> 'UPDATE',
			x_return_status 		=> l_return_status);

                ELSE
                  Process_Interfaced_Del_Details(
                        p_delivery_interface_id         => p_delivery_interface_id,
                        p_delivery_id                   => l_delivery_id,
                        p_new_delivery_id               => l_created_delivery_id,
                        p_action_code                   => l_action_code,
                        x_return_status                 => l_return_status);
                END IF;

                IF l_debug_on THEN
		 wsh_debug_sv.log (l_module_name, 'Return Status from Process Details', l_return_status);
		END IF;

		IF(l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
			raise process_del_details_failed;
		END IF;

                -- J: W/V Changes
                -- Need to update W/V for del here
                IF(l_action_code = 'UPDATE') THEN
                  l_tmp_del_id := l_delivery_id;
                ELSE
                  l_tmp_del_id := l_created_delivery_id;
                END IF;

                /* Adjust the W/V on delivery
                   as the dd assignment would have bumped(if del W/V is not frozen)
                   up the W/V on del */

                OPEN  org_del_id(l_tmp_del_id);
                FETCH org_del_id
                INTO  l_org_gross_weight,
                      l_org_net_weight,
                      l_org_volume;
                CLOSE org_del_id;

                UPDATE wsh_new_deliveries
                SET    gross_weight = l_gross_weight,
                       net_weight   = l_net_weight,
                       volume       = l_volume,
                       wv_frozen_flag = l_wv_frozen_flag
                WHERE  delivery_id  = l_tmp_del_id;

                WSH_WV_UTILS.Del_WV_Post_Process(
                  p_delivery_id   => l_tmp_del_id,
                  p_diff_gross_wt => NVL(l_gross_weight,0) - l_org_gross_weight,
                  p_diff_net_wt   => NVL(l_net_weight,0) - l_org_net_weight,
                  p_diff_volume   => NVL(l_volume,0) - l_org_volume,
                  x_return_status => l_return_status);

                IF l_debug_on THEN
                  wsh_debug_sv.log (l_module_name, 'Return status from WSH_WV_UTILS.Del_WV_Post_Process ',l_return_status);
                END IF;

                IF(l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN

                  l_loc_interface_error_rec.p_interface_table_name := 'WSH_NEW_DEL_INTERFACE';
                  l_loc_interface_error_rec.p_interface_id :=  p_delivery_interface_id;

                  IF l_debug_on THEN
                    wsh_debug_sv.log (l_module_name, 'Delivery Interface Id', p_delivery_interface_id);
                  END IF;

                  Log_Errors(
                    p_loc_interface_errors_rec   => l_loc_interface_error_rec,
                    p_msg_data      => l_msg_data,
                    p_api_name      => 'WSH_INTERFACE_PUB.Delivery_Interface_Wrapper' ,
                    x_return_status => l_return_status);

                  IF l_debug_on THEN
                    wsh_debug_sv.log (l_module_name, 'Return status after log_errors', l_return_status);
                  END IF;
                  raise process_delivery_wv_failed;
                END IF;

	ELSIF (l_action_code = 'CANCEL') THEN

		-- for cancel case, we need a base delivery id
		-- hence raise error if it is null
		IF(x_delivery_id IS NULL) THEN
			raise invalid_input;
		ELSE
			l_delivery_id := x_delivery_id;
		END IF;

		Process_Cancel(
			p_delivery_id 	=> l_delivery_id,
			x_return_status => l_return_status);

                IF l_debug_on THEN
		 wsh_debug_sv.log (l_module_name, 'Return Status from Process Cancel', l_return_status);
		END IF;

		IF(l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
			raise cancel_lines_failed;
		END IF;

	ELSE
		raise invalid_action_code;
	END IF; -- if l_action_code

        IF l_debug_on THEN
	 wsh_debug_sv.pop(l_module_name);
	END IF;

EXCEPTION
WHEN invalid_input THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'invalid_input exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:invalid_input');
        END IF;
WHEN no_lock_found THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'no_lock_found exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:no_lock_found');
        END IF;
WHEN invalid_action_code 	THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'invalid_action_code exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:invalid_action_code');
        END IF;
WHEN process_delivery_failed 	THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'process_delivery_failed exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:process_delivery_failed');
        END IF;
-- J: W/V Changes
WHEN process_delivery_wv_failed THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'process_delivery_wv_failed exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:process_delivery_wv_failed');
        END IF;
WHEN process_del_details_failed THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'process_del_details_failed exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:process_del_details_failed');
        END IF;
WHEN cancel_lines_failed 	THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'cancel_lines_failed exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:cancel_lines_failed');
        END IF;
WHEN Others THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;

END Delivery_Interface_Wrapper;


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Process_Int_Freight_Costs
   PARAMETERS : p_delivery_interface_id		IN NUMBER DEFAULT NULL,
		p_del_detail_interface_id	IN NUMBER DEFAULT NULL,
		p_delivery_detail_id  	        IN NUMBER DEFAULT NULL,
		p_stop_interface_id		IN NUMBER DEFAULT NULL,
		p_trip_interface_id		IN NUMBER DEFAULT NULL,
		x_return_status - return status of API
  DESCRIPTION :
-- This procedure takes the freight cost record from freight interface table
and inserts into the base wsh_freight_costs table.
-- This takes in as input the interface_id for a delivery or detail or stop or trip
-- This will be called by the procedures for processing delivery and delivery details

------------------------------------------------------------------------------
*/


PROCEDURE Process_Int_Freight_Costs(
	p_delivery_interface_id		IN NUMBER, -- DEFAULT NULL in spec,
	p_del_detail_interface_id	IN NUMBER, -- DEFAULT NULL in spec
        -- TPW - Distributed changes
        p_delivery_detail_id            IN NUMBER, -- DEFAULT NULL in spec
	p_stop_interface_id		IN NUMBER, -- DEFAULT NULL in spec
	p_trip_interface_id		IN NUMBER, -- DEFAULT NULL in spec
	x_return_status			OUT NOCOPY  VARCHAR2) IS

-- variables
l_freight_costs_info 	WSH_FREIGHT_COSTS_PUB.PubFreightCostRecType;
l_freight_cost_id 	NUMBER;
l_fc_type_id		NUMBER;
l_freight_cost_int_id 	NUMBER;

l_msg_count	 	NUMBER;
l_msg_data 		VARCHAR2(3000);
l_init_msg_list 	VARCHAR2(30) := NULL;
l_commit 		VARCHAR2(1);
l_return_status 	VARCHAR2(30);

l_loc_interface_error_rec WSH_INTERFACE_VALIDATIONS_PKG.interface_errors_rec_type;
l_entity_interface_id	NUMBER;
l_delivery_id 		NUMBER;
l_del_detail_id		NUMBER;
-- cursors
CURSOR freight_int_cur IS
SELECT 	FREIGHT_COST_INTERFACE_ID,
	FREIGHT_COST_ID,
	FREIGHT_COST_TYPE_ID,
	FREIGHT_COST_TYPE_CODE,
	UNIT_AMOUNT,
	CALCULATION_METHOD,
	UOM,
	QUANTITY,
	TOTAL_AMOUNT,
	CURRENCY_CODE,
	CONVERSION_DATE,
	CONVERSION_RATE,
	CONVERSION_TYPE_CODE,
	TRIP_INTERFACE_ID,
	STOP_INTERFACE_ID,
	DELIVERY_INTERFACE_ID,
	DELIVERY_LEG_INTERFACE_ID,
	DELIVERY_DETAIL_INTERFACE_ID,
	TRIP_ID,
	STOP_ID,
	DELIVERY_ID,
	DELIVERY_LEG_ID,
	ATTRIBUTE9,
	ATTRIBUTE10,
	ATTRIBUTE11,
	ATTRIBUTE12,
	ATTRIBUTE13,
	ATTRIBUTE6,
	ATTRIBUTE7,
	ATTRIBUTE8,
	ATTRIBUTE_CATEGORY,
	ATTRIBUTE1,
	ATTRIBUTE2,
	ATTRIBUTE3,
	ATTRIBUTE4,
	ATTRIBUTE5,
	DELIVERY_DETAIL_ID,
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
	FREIGHT_CODE,
	INTERFACE_ACTION_CODE
FROM wsh_freight_costs_interface
WHERE	(delivery_detail_interface_id 	= NVL(p_del_detail_interface_id, -99999))
OR	(delivery_interface_id		= NVL(p_delivery_interface_id, -99999))
OR	(stop_interface_id		= NVL(p_stop_interface_id, -99999))
OR 	(trip_interface_id		= NVL(p_trip_interface_id, -99999))
AND INTERFACE_ACTION_CODE = '94X_INBOUND';

CURSOR fc_type_id(l_fc_type_code VARCHAR2) IS
SELECT freight_cost_type_id
FROM wsh_freight_cost_types
WHERE name = l_fc_type_code;

--exceptions
no_freight_record 	exception;
invalid_input		exception;
invalid_freight_cost_type exception;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PROCESS_INT_FREIGHT_COSTS';
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
	wsh_debug_sv.push(l_module_name,'Process_Int_Freight_Costs');
	wsh_debug_sv.log (l_module_name,'Delivery interface Id', p_delivery_interface_id);
	wsh_debug_sv.log (l_module_name,'del_detail_interface_id', p_del_detail_interface_id);
        wsh_debug_sv.log (l_module_name,'delivery detail id', p_delivery_detail_id);
      END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


	IF(p_del_detail_interface_id IS NOT NULL) THEN
		IF(p_delivery_detail_id IS NULL) THEN
                       IF l_debug_on THEN
			wsh_debug_sv.logmsg(l_module_name, 'Null Delivery Detail Id');
                       END IF;
		       raise invalid_input;
		END IF;
	ELSIF(p_delivery_interface_id IS NOT NULL) THEN
		l_entity_interface_id := p_delivery_interface_id;
		SELECT delivery_id INTO l_delivery_id
		FROM wsh_new_del_interface
		WHERE delivery_interface_id = p_delivery_interface_id
		  AND INTERFACE_ACTION_CODE = '94X_INBOUND';

                IF l_debug_on THEN
		 wsh_debug_sv.log (l_module_name, 'Delivery Id', l_delivery_id);
		END IF;
		IF(l_delivery_id IS NULL) THEN
                       IF l_debug_on THEN
			wsh_debug_sv.logmsg(l_module_name, 'Null Delivery Id');
                       END IF;
			raise invalid_input;
		END IF;

	ELSIF(p_stop_interface_id IS NOT NULL) THEN
		l_entity_interface_id := p_stop_interface_id;
	ELSIF(p_trip_interface_id IS NOT NULL) THEN
		l_entity_interface_id := p_trip_interface_id;
	ELSE
                IF l_debug_on THEN
		 wsh_debug_sv.logmsg(l_module_name, 'Entity IDs are Null');
		END IF;
		raise invalid_input;
	END IF;

	-- call the public api for creating freight costs

	FOR l_freight_int_rec in freight_int_cur LOOP

                IF l_debug_on THEN
		 wsh_debug_sv.log (l_module_name, 'Freight Cost Type Code', l_freight_int_rec.freight_cost_type_code);
		END IF;

		IF(l_freight_int_rec.freight_cost_type_code IS NOT NULL) THEN
			OPEN fc_type_id(l_freight_int_rec.freight_cost_type_code);
			FETCH fc_type_id INTO l_fc_type_id;
			CLOSE fc_type_id;
		ELSE
			raise invalid_freight_cost_type;
		END IF;

                IF l_debug_on THEN
		 wsh_debug_sv.log (l_module_name, 'Freight Cost Type Id', l_fc_type_id);
		END IF;
		IF(l_fc_type_id IS NULL) THEN
                        IF l_debug_on THEN
		 	 wsh_debug_sv.logmsg(l_module_name, 'Invalid Freight Cost Type');
                        END IF;

			l_loc_interface_error_rec.p_interface_table_name := 'WSH_FREIGHT_COSTS_INTERFACE';
			l_loc_interface_error_rec.p_interface_id :=  l_entity_interface_id;

				Log_Errors(
					p_loc_interface_errors_rec   => l_loc_interface_error_rec,
                                        p_msg_data               => 'Invalid Freight Cost Type',
                                        p_api_name   => 'WSH_FREIGHT_COSTS_PUB.Create_Update_Freight_Costs',
				      x_return_status          => l_return_status);
                                IF l_debug_on THEN
        		 	 wsh_debug_sv.log (l_module_name, 'Log_Errors l_return_status',l_return_status);
                                END IF;
			raise invalid_freight_cost_type;
		ELSE
			l_freight_costs_info.freight_cost_type_id := l_fc_type_id;
		END IF;

		l_freight_costs_info.freight_cost_id 	:= l_freight_int_rec.freight_cost_id;

		l_freight_costs_info.unit_amount 	:= l_freight_int_rec.unit_amount;
		l_freight_costs_info.currency_code	:= l_freight_int_rec.currency_code;
		l_freight_costs_info.conversion_date	:= l_freight_int_rec.conversion_date;
		l_freight_costs_info.conversion_rate	:= l_freight_int_rec.conversion_rate;
		l_freight_costs_info.conversion_type_code	:= l_freight_int_rec.conversion_type_code;
		l_freight_costs_info.trip_id		:= l_freight_int_rec.trip_id;
		l_freight_costs_info.stop_id		:= l_freight_int_rec.stop_id;

		l_freight_costs_info.delivery_id	:= l_delivery_id;
		l_freight_costs_info.delivery_leg_id	:= l_freight_int_rec.delivery_leg_id;
		l_freight_costs_info.delivery_detail_id := p_delivery_detail_id;

		l_freight_costs_info.attribute_category	:= l_freight_int_rec.attribute_category;
		l_freight_costs_info.attribute1		:= l_freight_int_rec.attribute1;
		l_freight_costs_info.attribute2		:= l_freight_int_rec.attribute2;
		l_freight_costs_info.attribute3		:= l_freight_int_rec.attribute3;
		l_freight_costs_info.attribute4		:= l_freight_int_rec.attribute4;
		l_freight_costs_info.attribute5		:= l_freight_int_rec.attribute5;
		l_freight_costs_info.attribute6		:= l_freight_int_rec.attribute6;
		l_freight_costs_info.attribute7		:= l_freight_int_rec.attribute7;
		l_freight_costs_info.attribute8		:= l_freight_int_rec.attribute8;
		l_freight_costs_info.attribute9		:= l_freight_int_rec.attribute9;
		l_freight_costs_info.attribute10	:= l_freight_int_rec.attribute10;
		l_freight_costs_info.attribute11	:= l_freight_int_rec.attribute11;
		l_freight_costs_info.attribute12	:= l_freight_int_rec.attribute12;
		l_freight_costs_info.attribute13	:= l_freight_int_rec.attribute13;
		l_freight_costs_info.attribute14	:= l_freight_int_rec.attribute14;
		l_freight_costs_info.attribute15	:= l_freight_int_rec.attribute15;

               IF l_debug_on THEN
		wsh_debug_sv.logmsg(l_module_name,'Calling freight public api');
		wsh_debug_sv.log (l_module_name, 'Unit amount', l_freight_costs_info.unit_amount);
		wsh_debug_sv.log (l_module_name, 'Currency code', l_freight_costs_info.currency_code);
		wsh_debug_sv.log (l_module_name, 'Delivery Id', l_freight_costs_info.delivery_id);
		wsh_debug_sv.log (l_module_name, 'Delivery Detail Id',l_freight_costs_info.delivery_detail_id);
		wsh_debug_sv.log (l_module_name, 'Trip Id', l_freight_costs_info.trip_id);
		wsh_debug_sv.log (l_module_name, 'Trip Name', l_freight_costs_info.trip_name);
		wsh_debug_sv.log (l_module_name, 'Stop Id', l_freight_costs_info.stop_id);
               END IF;

		WSH_FREIGHT_COSTS_PUB.Create_Update_Freight_Costs (
			p_api_version_number  	=> 1.0,
			p_init_msg_list       	=> l_init_msg_list,
			p_commit              	=> l_commit,
			x_return_status       	=> l_return_status,
			x_msg_count           	=> l_msg_count,
			x_msg_data  	      	=> l_msg_data,
			p_pub_freight_costs	=> l_freight_costs_info,
			p_action_code   	=> 'CREATE',
			x_freight_cost_id    	=> l_freight_cost_id);

               IF l_debug_on THEN
		wsh_debug_sv.log (l_module_name, 'return status from freight public api', l_return_status);
		wsh_debug_sv.log (l_module_name, 'Create Update Freight Costs api msg count', l_msg_count);
		wsh_debug_sv.log (l_module_name, 'Create Update Freight Costs api msg', l_msg_data);
		wsh_debug_sv.log (l_module_name, 'freight_cost id created', l_freight_cost_id);
               END IF;

		IF(l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
			l_loc_interface_error_rec.p_interface_table_name := 'WSH_FREIGHT_COSTS_INTERFACE';
			l_loc_interface_error_rec.p_interface_id :=  l_entity_interface_id;

				Log_Errors(
					p_loc_interface_errors_rec   => l_loc_interface_error_rec,
                                        p_msg_data               => l_msg_data,
                                        p_api_name   => 'WSH_FREIGHT_COSTS_PUB.Create_Update_Freight_Costs',
				      x_return_status          => l_return_status);
                                IF l_debug_on THEN
        		 	 wsh_debug_sv.log (l_module_name, 'Log_Errors l_return_status',l_return_status);
                                END IF;
			x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		END IF;

	END LOOP;

       IF l_debug_on THEN
	wsh_debug_sv.pop(l_module_name);
       END IF;

EXCEPTION
WHEN invalid_input THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'invalid_input exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:invalid_input');
        END IF;
WHEN invalid_freight_cost_type THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'invalid_freight_cost_type exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:invalid_freight_cost_type');
        END IF;
WHEN no_freight_record THEN
	null;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'no_freight_record exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:no_freight_record');
        END IF;
WHEN Others THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;

END Process_Int_Freight_Costs;


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Update_Delivery_Details
   PARAMETERS : p_changed_det_attributes 	IN  WSH_INTERFACE.ChangedAttributeTabType
		x_return_status - return status of API
  DESCRIPTION :
-- This is an internal procedure, used by Process_Interfaced_Del_Details
-- This will be called for any updates of delivery details

-- history: 1/13/03 jckwok added a parameter for action_code to distinguish
--          between UPDATE and CANCEL actions.
------------------------------------------------------------------------------
*/


PROCEDURE Update_Delivery_Details(
	p_source_code	        IN VARCHAR2, -- DEFAULT 'OE' in spec
	p_delivery_interface_id	IN NUMBER,
	p_action_code           IN VARCHAR2,  -- jckwok
	x_return_status         OUT NOCOPY  VARCHAR2
	) IS

-- public api variables
l_msg_count 		NUMBER;
l_msg_data 		VARCHAR2(3000);
l_init_msg_list 	VARCHAR2(30) := NULL;
l_commit 		VARCHAR2(1) ;
l_return_status 	VARCHAR2(30);

l_loc_interface_error_rec WSH_INTERFACE_VALIDATIONS_PKG.interface_errors_rec_type;
l_DETAIL_INFO_TAB         WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type;
l_IN_REC                  WSH_GLBL_VAR_STRCT_GRP.detailInRecType;
l_OUT_REC                 WSH_GLBL_VAR_STRCT_GRP.detailOutRecType;
-- TPW - Distribution Organization Changes - Inv. Rsv API Integration Changes - Starts
l_header_id             NUMBER;
l_rsv_rec               inv_reservation_global.mtl_reservation_rec_type;
l_serial_number_tbl     inv_reservation_global.serial_number_tbl_type;
-- TPW - Distribution Organization Changes - Inv. Rsv API Integration Changes - Ends
--exceptions
update_shipping_att_failed	exception;
cont_upd_ship_att_failed	exception;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_DELIVERY_DETAILS';
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
	wsh_debug_sv.push(l_module_name,'Update_Delivery_Details');
	wsh_debug_sv.log (l_module_name, 'Source Code', p_source_code);
	wsh_debug_sv.log (l_module_name, 'Delivery Interface Id', p_delivery_interface_id);
	wsh_debug_sv.log (l_module_name, 'Update Table Count', G_Update_Attributes_Tab.count);
        wsh_debug_sv.log(l_module_name, 'Serial Range Tab count',G_SERIAL_RANGE_TAB.count);
      END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	-- Use the global table to call create_update Group API

	IF(G_Update_Attributes_Tab.count > 0 ) THEN
            l_in_rec.caller := 'WSH_INBOUND';
--jckwok: set UPDATE or CANCEL action codes
            l_in_rec.action_code := p_action_code;
            l_in_rec.phase     := 1;

           wsh_delivery_Details_grp.create_update_delivery_detail(
              P_API_VERSION_NUMBER =>      1.0,
              P_INIT_MSG_LIST      => FND_API.G_FALSE,
              P_COMMIT             => FND_API.G_FALSE,
              x_RETURN_STATUS      => l_RETURN_STATUS,
              X_MSG_COUNT          => l_MSG_COUNT,
              X_MSG_DATA           => l_MSG_DATA,
              P_DETAIL_INFO_TAB    => G_Update_Attributes_Tab,
              P_IN_REC             => l_IN_REC,
              X_OUT_REC            => l_OUT_REC,
              P_SERIAL_RANGE_TAB   => G_SERIAL_RANGE_TAB
              );

               IF l_debug_on THEN
		wsh_debug_sv.log (l_module_name,'Return Status from create_update group api', l_return_status);
		wsh_debug_sv.log (l_module_name, 'Update Ship Attr api msg count', l_msg_count);
		wsh_debug_sv.log (l_module_name, 'Update Ship Attr api msg data', l_msg_data);
               END IF;

		IF(l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
			-- Need to insert record in interface errors table only
			-- for 'OE' source code, i.e during 945 inbound
			-- For 940 inbound - cancel case, there may not be any
			-- data in interface tables.

		    IF(p_delivery_interface_id IS NOT NULL) THEN
			l_loc_interface_error_rec.p_interface_table_name := 'WSH_NEW_DEL_INTERFACE';
				l_loc_interface_error_rec.p_interface_id :=  p_delivery_interface_id;

				Log_Errors(
				       p_loc_interface_errors_rec   => l_loc_interface_error_rec,
                                       p_msg_data                 => l_msg_data,
                                       p_api_name =>'WSH_DELIVERY_DETAILS_GRP.Create_Update_Delivery_Detail',
				      x_return_status          => l_return_status);

                                IF l_debug_on THEN
                  		 wsh_debug_sv.log (l_module_name,'Log_Errors l_return_status',l_return_status);
                                END IF;

		    END IF;
			raise update_shipping_att_failed;
		END IF;

        -- TPW - Distribution Organization Changes - Inv. Rsv API Integration Changes - Starts
        IF ( nvl(WSH_INBOUND_SHIP_ADVICE_PKG.G_WAREHOUSE_TYPE, '!') = 'TW2' )
        THEN --{
           FOR i in G_Update_Attributes_Tab.first..G_Update_Attributes_Tab.last
           LOOP --{
              --
              IF l_debug_on THEN
                 wsh_debug_sv.log (l_module_name, 'Container Flag for delivery detail: ' || G_Update_Attributes_Tab(i).delivery_detail_id, G_Update_Attributes_Tab(i).Container_Flag);
              END IF;
              --
              IF ( G_Update_Attributes_Tab(i).Container_Flag = 'N' )
              THEN -- {
                 SELECT source_header_id,
                        source_line_id,
                        inventory_item_id,
                        organization_id,
                        requested_quantity_uom,
                        DECODE(line_direction, 'IO', 8, 2),
                        shipped_quantity,
                        revision,
                        subinventory,
                        lot_number,
                        locator_id
                 INTO   l_header_id,
                        l_rsv_rec.demand_source_line_id,
                        l_rsv_rec.inventory_item_id,
                        l_rsv_rec.organization_id,
                        l_rsv_rec.primary_uom_code,
                        l_rsv_rec.demand_source_type_id,
                        l_rsv_rec.primary_reservation_quantity,
                        l_rsv_rec.revision,
                        l_rsv_rec.subinventory_code,
                        l_rsv_rec.lot_number,
                        l_rsv_rec.locator_id
                 FROM   wsh_delivery_details
                 WHERE  delivery_detail_id = G_Update_Attributes_Tab(i).delivery_detail_id;
                 --
                 IF l_debug_on THEN
                    wsh_debug_sv.logmsg (l_module_name,'Calling INV_SALESORDER.Get_Salesorder_For_Oeheader', WSH_DEBUG_SV.C_PROC_LEVEL );
                 END IF;
                 --
                 l_rsv_rec.demand_source_header_id      := INV_SALESORDER.Get_Salesorder_For_Oeheader(P_OE_HEADER_ID => l_header_id);
                 --
                 IF l_debug_on THEN
                    wsh_debug_sv.logmsg (l_module_name,'Calling INV_RSV_DETAIL_STAGE_PVT.Process_Reservation', WSH_DEBUG_SV.C_PROC_LEVEL );
                 END IF;
                 --
                 -- After discussing with Inventory team, its been decided that
                 -- 1. Serial Numbers will NOT be passed in p_serial_number parameter,
                 --    even if the item is Serial Controlled.
                 -- 2. Return Status of Process_Reservation api will NOT be handled
                 -- Documented the same in MED under Closed Issues
                 INV_RSV_DETAIL_STAGE_PVT.Process_Reservation(
                         p_api_version_number => 1.0,
                         p_init_msg_lst       => FND_API.G_TRUE,
                         p_rsv_rec            => l_rsv_rec,
                         p_serial_number      => l_serial_number_tbl,
                         p_rsv_status         => 'STAGE',
                         x_return_status      => l_return_status,
                         x_msg_count          => l_msg_count,
                         x_msg_data           => l_msg_data );
                 --
                 -- Bug 8579149 - Fixing the GSCC error introduced in previous fix
                 IF l_debug_on THEN
                    wsh_debug_sv.log (l_module_name, 'Return Status from INV_RSV_DETAIL_STAGE_PVT.Process_Reservation', l_return_status);
                    wsh_debug_sv.log (l_module_name, 'Process_Reservation api msg count', l_msg_count);
                    wsh_debug_sv.log (l_module_name, 'Process_Reservation api msg data', l_msg_data);
                 END IF;
                 --
                 -- Return Status of Process_Reservation api will NOT be handled
              END IF; --} Container Flag
           END LOOP; --}
        END IF; --}
        -- TPW - Distribution Organization Changes - Inv. Rsv API Integration Changes - Ends

        END IF; -- if G_Update_Attributes_Tab.count

       IF l_debug_on THEN
	wsh_debug_sv.pop(l_module_name);
       END IF;

EXCEPTION
WHEN update_shipping_att_failed THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'update_shipping_att_failed exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:update_shipping_att_failed');
        END IF;
WHEN cont_upd_ship_att_failed THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'cont_upd_ship_att_failed exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:cont_upd_ship_att_failed');
        END IF;
WHEN Others THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
END Update_Delivery_Details;


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Create_Update_Trip_For_Dlvy
   PARAMETERS : p_delivery_id
		x_return_status - return status of API
  DESCRIPTION :
- This procedure is called to create/update the trip for the delivery
which has been updated with the inbound 945 transaction data
- If a trip already exists for the delivery in the base tables, then
this procedure just updates the trip and trip_stop tables based on the
values in the trip interface table and trip_stop interface table.
- If a trip does not already exist, then this procedure first calls
autocreate_trip to create a trip for the delivery.
-- Then it updates the newly created trip and trip_stops with the
values from the interface table data

------------------------------------------------------------------------------
*/

PROCEDURE  Create_Update_Trip_For_Dlvy(
	p_delivery_id	IN NUMBER,
	x_pickup_stop_id OUT NOCOPY  NUMBER,
	x_dropoff_stop_id OUT NOCOPY  NUMBER,
	x_trip_id	OUT NOCOPY  NUMBER,
	x_return_status OUT NOCOPY  VARCHAR2) IS

-- variables
l_del_rows              wsh_util_core.id_tab_type;

l_pickup_stop_id        NUMBER ;
l_dropoff_stop_id       NUMBER ;
l_delivery_leg_id       NUMBER ;

l_trip_id 		NUMBER;
l_trip_name		VARCHAR2(30);

l_trip_interface_id	NUMBER;
l_stop_interface_id	NUMBER;

l_pickup_stop_int_id	NUMBER;
l_dropoff_stop_int_id	NUMBER;

l_return_status	VARCHAR2(30);

l_stop_tab WSH_UTIL_CORE.id_tab_type;  -- DBI Project
l_dbi_rs            VARCHAR2(1);       -- DBI Project

-- cursors
CURSOR del_trip_stops IS
SELECT wdg.pick_up_stop_id, wdg.drop_off_stop_id, wts.trip_id
FROM   wsh_delivery_legs wdg, wsh_trip_stops wts
WHERE  wdg.delivery_id = p_delivery_id
AND 	wdg.pick_up_stop_id = wts.stop_id;

CURSOR int_del_trip_stops IS
SELECT wdli.pick_up_stop_interface_id, wdli.drop_off_stop_interface_id, wtsi.trip_interface_id
FROM wsh_del_legs_interface wdli, wsh_trip_stops_interface wtsi
WHERE wdli.delivery_id = p_delivery_id
AND   wdli.pick_up_stop_interface_id = wtsi.stop_interface_id
AND WDLI.INTERFACE_ACTION_CODE = '94X_INBOUND'
AND WTSI.INTERFACE_ACTION_CODE = '94X_INBOUND';


CURSOR int_pickup_stop_cur(l_stop_interface_id NUMBER) IS
SELECT actual_departure_date, departure_seal_code
FROM wsh_trip_stops_interface
WHERE stop_interface_id = l_stop_interface_id
AND INTERFACE_ACTION_CODE = '94X_INBOUND';

CURSOR int_dropoff_stop_cur(l_stop_interface_id NUMBER) IS
SELECT actual_arrival_date
FROM wsh_trip_stops_interface
WHERE stop_interface_id = l_stop_interface_id
AND INTERFACE_ACTION_CODE = '94X_INBOUND';

CURSOR int_trip_cur(l_trip_interface_id NUMBER) IS
SELECT vehicle_number, vehicle_num_prefix, route_id, routing_instructions,
--Bug 3458160
operator
FROM wsh_trips_interface
WHERE trip_interface_id = l_trip_interface_id
AND INTERFACE_ACTION_CODE = '94X_INBOUND';

-- cursor records
int_trip_rec 		int_trip_cur%ROWTYPE;
int_dropoff_stop_rec 	int_dropoff_stop_cur%ROWTYPE;
int_pickup_stop_rec 	int_pickup_stop_cur%ROWTYPE;

--exceptions
trip_creation_failed 	exception;
invalid_input		exception;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_UPDATE_TRIP_FOR_DLVY';
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
	wsh_debug_sv.push(l_module_name,'Create_Update_Trip_For_Dlvy');
	wsh_debug_sv.log (l_module_name, 'Delivery id', p_delivery_id);
       END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	IF(p_delivery_id IS NULL) THEN
		raise invalid_input;
	END IF;

	-- check if a trip exists
	OPEN  del_trip_stops;
	FETCH del_trip_stops INTO l_pickup_stop_id, l_dropoff_stop_id, l_trip_id;
	CLOSE del_trip_stops;

       IF l_debug_on THEN
	wsh_debug_sv.log (l_module_name, 'Pickup Stop Id', l_pickup_stop_id);
	wsh_debug_sv.log (l_module_name, 'Dropoff Stop Id', l_dropoff_stop_id);
	wsh_debug_sv.log (l_module_name, 'Trip Id', l_trip_id);
       END IF;
	IF (l_pickup_stop_id IS NULL) THEN

  		-- trip does not exist. so do autocreate_trip

		l_del_rows(1) := p_delivery_id;

		wsh_trips_actions.autocreate_trip(
                               p_del_rows => l_del_rows,
                               x_trip_id  => l_trip_id,
                               x_trip_name => l_trip_name,
                               x_return_status => l_return_status);

               IF l_debug_on THEN
		wsh_debug_sv.log (l_module_name, 'Return status from autocreate trip', l_return_status);
		wsh_debug_sv.log (l_module_name, 'Trip created', l_trip_id);
	       END IF;

		IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                	x_return_status := l_return_status;
			raise trip_creation_failed;
		END IF;

		-- Now that a trip is created, get the stop and trip info
		OPEN  del_trip_stops;
		FETCH del_trip_stops INTO l_pickup_stop_id, l_dropoff_stop_id, l_trip_id;
		CLOSE del_trip_stops;

               IF l_debug_on THEN
		wsh_debug_sv.log (l_module_name, 'After doing autocreate trip');
		wsh_debug_sv.log (l_module_name, 'Pickup Stop Id', l_pickup_stop_id);
		wsh_debug_sv.log (l_module_name, 'Dropoff Stop Id', l_dropoff_stop_id);
		wsh_debug_sv.log (l_module_name, 'Trip Id', l_trip_id);
	       END IF;

	END IF; -- if l_pickup_stop_id is null

	-- get the interface trip_stop_ids and trip_id
	OPEN int_del_trip_stops;
	FETCH int_del_trip_stops
	INTO l_pickup_stop_int_id, l_dropoff_stop_int_id, l_trip_interface_id;
	CLOSE int_del_trip_stops;

       IF l_debug_on THEN
	wsh_debug_sv.log (l_module_name, 'Pickup Stop Interface Id', l_pickup_stop_int_id);
	wsh_debug_sv.log (l_module_name, 'Dropoff Stop Interface Id', l_dropoff_stop_int_id);
	wsh_debug_sv.log (l_module_name, 'Trip Interface Id', l_trip_interface_id);
       END IF;

	-- get the interface trip_stop info
	OPEN int_pickup_stop_cur(l_pickup_stop_int_id);
	FETCH int_pickup_stop_cur INTO int_pickup_stop_rec;

	IF(int_pickup_stop_cur%NOTFOUND) THEN
		NULL;
		-- need to decide what should be done
	END IF;
       IF l_debug_on THEN
	wsh_debug_sv.log (l_module_name, 'Updating Stop Id', l_pickup_stop_id);
       END IF;

	-- update the base trip_stops
	IF l_pickup_stop_id IS NOT NULL THEN

		UPDATE wsh_trip_stops
		SET	actual_departure_date	= int_pickup_stop_rec.actual_departure_date,
			departure_seal_code	= int_pickup_stop_rec.departure_seal_code
		WHERE	stop_id	= l_pickup_stop_id;

 --
        -- DBI Project
        -- Updating  WSH_TRIP_STOPS.
        -- Call DBI API after the Update.
        -- This API will also check for DBI Installed or not
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Stop id -',l_pickup_stop_id);
        END IF;
	l_stop_tab(1) := l_pickup_stop_id;
        WSH_INTEGRATION.DBI_Update_Trip_Stop_Log
          (p_stop_id_tab	=> l_stop_tab,
           p_dml_type		=> 'UPDATE',
           x_return_status      => l_dbi_rs);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
        END IF;
        IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
	  x_return_status := l_dbi_rs;
          -- just pass this return status to caller API
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'DBI API Returned Unexpected error '||x_return_status);
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          return;
       END IF;
        -- End of Code for DBI Project
 --

		x_pickup_stop_id := l_pickup_stop_id;

	END IF;

	IF(int_pickup_stop_cur%ISOPEN) THEN
		CLOSE int_pickup_stop_cur;
	END IF;

	OPEN int_dropoff_stop_cur(l_dropoff_stop_int_id);
	FETCH int_dropoff_stop_cur INTO int_dropoff_stop_rec;

	IF(int_dropoff_stop_cur%NOTFOUND) THEN
		NULL;
		-- need to decide what should be done
	END IF;
       IF l_debug_on THEN
	wsh_debug_sv.log (l_module_name, 'Updating Drop off Stop Id', l_dropoff_stop_id);
       END IF;

	IF l_dropoff_stop_id IS NOT NULL THEN
		UPDATE wsh_trip_stops
		SET	actual_arrival_date	= int_dropoff_stop_rec.actual_arrival_date
		WHERE 	stop_id = l_dropoff_stop_id;

 --
        -- DBI Project
        -- Updating  WSH_TRIP_STOPS.
        -- Call DBI API after the Update.
        -- This API will also check for DBI Installed or not
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Stop id -',l_dropoff_stop_id);
        END IF;
	l_stop_tab(1) := l_dropoff_stop_id;
        WSH_INTEGRATION.DBI_Update_Trip_Stop_Log
          (p_stop_id_tab	=> l_stop_tab,
           p_dml_type		=> 'UPDATE',
           x_return_status      => l_dbi_rs);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
        END IF;
        IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
	  x_return_status := l_dbi_rs;
          -- just pass this return status to caller API
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'DBI API Returned Unexpected error '||x_return_status);
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          return;
        END IF;
        -- End of Code for DBI Project
 --

		x_dropoff_stop_id := l_dropoff_stop_id;
	END IF;

	IF(int_dropoff_stop_cur%ISOPEN) THEN
		CLOSE int_dropoff_stop_cur;
	END IF;

	-- get the interface trip info
	OPEN int_trip_cur(l_trip_interface_id);
	FETCH int_trip_cur INTO int_trip_rec;

	IF(int_trip_cur%NOTFOUND) THEN
		NULL;
		-- need to decide what should be done
	END IF;

       IF l_debug_on THEN
	wsh_debug_sv.log (l_module_name, 'Updating Trip Id', l_trip_id);
       END IF;
	-- update the base trip
	IF l_trip_id IS NOT NULL THEN

		UPDATE wsh_trips
		SET	vehicle_num_prefix 	= int_trip_rec.vehicle_num_prefix,
			vehicle_number	= int_trip_rec.vehicle_number,
			route_id	= int_trip_rec.route_id,
			routing_instructions	= int_trip_rec.routing_instructions,
                        --Bug 3458160
                        operator  = int_trip_rec.operator
		WHERE trip_id = l_trip_id;

		x_trip_id := l_trip_id;

	END IF; -- if l_trip_id is not null

	IF(int_trip_cur%ISOPEN) THEN
		CLOSE int_trip_cur;
	END IF;

       IF l_debug_on THEN
	wsh_debug_sv.pop(l_module_name);
       END IF;
EXCEPTION
WHEN trip_creation_failed THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'trip_creation_failed exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:trip_creation_failed');
        END IF;
WHEN invalid_input THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'invalid_input exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:invalid_input');
        END IF;
WHEN Others THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;

END Create_Update_Trip_For_Dlvy;


PROCEDURE Int_Trip_Stop_Info(
	p_delivery_interface_id		IN NUMBER,
	p_act_dep_date		IN 	DATE,
	p_dep_seal_code		IN	VARCHAR2,
	p_act_arr_date		IN 	DATE,
	p_trip_vehicle_num	IN 	VARCHAR2,
	p_trip_veh_num_pfx	IN	VARCHAR2,
	p_trip_route_id		IN	NUMBER,
	p_trip_routing_ins	IN	VARCHAR2,
        --Bug 3458160
        p_operator              IN      VARCHAR2,
	x_return_status		OUT NOCOPY  VARCHAR2) IS

-- variables
l_del_leg_interface_id		NUMBER;
l_pickup_stop_interface_id 	NUMBER;
l_dropoff_stop_interface_id 	NUMBER;
l_trip_interface_id		NUMBER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INT_TRIP_STOP_INFO';
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
	wsh_debug_sv.push(l_module_name,'Int_Trip_Stop_Info');
	wsh_debug_sv.log (l_module_name, 'Delivery Interface id', p_delivery_interface_id);
	wsh_debug_sv.log (l_module_name, 'Act Departure Date', p_act_dep_date);
	wsh_debug_sv.log (l_module_name, 'Dep Seal Code', p_dep_seal_code);
	wsh_debug_sv.log (l_module_name, 'Act Arrival Date', p_act_arr_date);
	wsh_debug_sv.log (l_module_name, 'Vehicle Num', p_trip_vehicle_num);
	wsh_debug_sv.log (l_module_name, 'Vehicle Num Prefix', p_trip_veh_num_pfx);
	wsh_debug_sv.log (l_module_name, 'Route Id', p_trip_route_id);
	wsh_debug_sv.log (l_module_name, 'Routing Ins', p_trip_routing_ins);
	wsh_debug_sv.log (l_module_name, 'p_operator', p_operator);
      END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	-- get delivery_leg_interface_id, stop_interface_id, trip_interface_id

	SELECT
	WSH_DEL_LEGS_INTERFACE_S.nextval,
	WSH_TRIP_STOPS_INTERFACE_S.nextval,
	WSH_TRIPS_INTERFACE_S.nextval
	INTO 	l_del_leg_interface_id,
		l_pickup_stop_interface_id,
		l_trip_interface_id
	FROM dual;

	SELECT
	WSH_TRIP_STOPS_INTERFACE_S.nextval
	INTO l_dropoff_stop_interface_id
	FROM dual;

	-- insert record into wsh_del_legs_interface

	INSERT into wsh_del_legs_interface(
		DELIVERY_LEG_INTERFACE_ID,
		DELIVERY_INTERFACE_ID,
		PICK_UP_STOP_INTERFACE_ID,
		DROP_OFF_STOP_INTERFACE_ID,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		INTERFACE_ACTION_CODE)
		VALUES(
			l_del_leg_interface_id,
			p_delivery_interface_id,
			l_pickup_stop_interface_id,
			l_dropoff_stop_interface_id,
			SYSDATE,
			FND_GLOBAL.USER_ID,
			SYSDATE,
			FND_GLOBAL.USER_ID,
			'94X_INBOUND');

	-- insert records into wsh_trip_stops_interface
	-- first the pickup stop
	INSERT INTO wsh_trip_stops_interface(
		STOP_INTERFACE_ID,
		TRIP_INTERFACE_ID,
		ACTUAL_DEPARTURE_DATE,
		DEPARTURE_SEAL_CODE,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		INTERFACE_ACTION_CODE)
		VALUES(
			l_pickup_stop_interface_id,
			l_trip_interface_id,
			p_act_dep_date,
			p_dep_seal_code,
			SYSDATE,
			FND_GLOBAL.USER_ID,
			SYSDATE,
			FND_GLOBAL.USER_ID,
			'94X_INBOUND');

	-- then the dropoff stop
	INSERT INTO wsh_trip_stops_interface(
		STOP_INTERFACE_ID,
		TRIP_INTERFACE_ID,
		ACTUAL_ARRIVAL_DATE,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		INTERFACE_ACTION_CODE)
		VALUES(
			l_dropoff_stop_interface_id,
			l_trip_interface_id,
			p_act_arr_date,
			SYSDATE,
			FND_GLOBAL.USER_ID,
			SYSDATE,
			FND_GLOBAL.USER_ID,
			 '94X_INBOUND');

	-- insert records into wsh_trips_interface
	INSERT INTO wsh_trips_interface(
		TRIP_INTERFACE_ID,
		VEHICLE_NUM_PREFIX,
		VEHICLE_NUMBER,
		ROUTE_ID,
		ROUTING_INSTRUCTIONS,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		INTERFACE_ACTION_CODE,
--Bug 3458160
                operator)
		VALUES (
			l_trip_interface_id,
			p_trip_veh_num_pfx,
			p_trip_vehicle_num,
			p_trip_route_id,
			p_trip_routing_ins,
			SYSDATE,
			FND_GLOBAL.USER_ID,
			SYSDATE,
			FND_GLOBAL.USER_ID,
			'94X_INBOUND',
                        p_operator);

      IF l_debug_on THEN
	wsh_debug_sv.pop(l_module_name);
      END IF;
EXCEPTION

WHEN Others THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
END Int_Trip_Stop_Info;


PROCEDURE Add_To_Update_Table
	(p_del_det_int_rec 	IN del_det_int_cur%ROWTYPE,
	 p_update_mode		IN VARCHAR2 DEFAULT 'UPDATE',
	 p_delivery_id		IN NUMBER,
	 x_return_status	OUT NOCOPY  VARCHAR2) IS

-- variables
--l_changed_attributes	 WSH_INTERFACE.ChangedAttributeRecType;
l_changed_attributes     WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type;
l_packing_detail_rec	WSH_INTERFACE_COMMON_ACTIONS.PackingDetailRecType;
l_intf_parent_det_id	NUMBER;

-- TPW - Distributed changes
l_container_flag VARCHAR2(1);

l_delivery_detail_id    NUMBER;
l_subinventory          wsh_delivery_details.subinventory%type;
l_locator_id            NUMBER;
l_wms_installed varchar2(1);

-- cursors
CURSOR base_detail_cur(l_cont_inst_id NUMBER) IS
SELECT wdd.delivery_detail_id
FROM wsh_delivery_details wdd
WHERE source_line_id = l_cont_inst_id
AND wdd.source_code = 'WSH'
AND wdd.container_flag = 'Y'
AND wdd.organization_id = p_del_det_int_rec.organization_id;

CURSOR intf_parent_det_cur IS
SELECT wdai.parent_delivery_detail_id, wddi.container_flag
FROM wsh_del_assgn_interface wdai, wsh_del_details_interface wddi
WHERE wdai.delivery_detail_interface_id = p_del_det_int_rec.delivery_detail_interface_id
AND wdai.delivery_detail_interface_id = wddi.delivery_detail_interface_id
AND wddi.INTERFACE_ACTION_CODE = '94X_INBOUND'
AND WDAI.INTERFACE_ACTION_CODE = '94X_INBOUND';

--bugfix 8841528 added cursor
CURSOR inv_detail_cur IS
SELECT wdd.delivery_detail_id,wdd.subinventory, wdd.locator_id
FROM wsh_delivery_details wdd
WHERE source_line_id = p_del_det_int_rec.delivery_detail_id
AND wdd.source_code = 'WSH'
AND wdd.container_flag = 'Y'
AND wdd.organization_id = p_del_det_int_rec.organization_id;


--exceptions
packing_error	exception;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ADD_TO_UPDATE_TABLE';
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
	wsh_debug_sv.push(l_module_name, 'Add_To_Update_Table');
	wsh_debug_sv.log (l_module_name, 'Update Mode' , p_update_mode);
	wsh_debug_sv.log (l_module_name, 'p_delivery_id', p_delivery_id);
        wsh_debug_sv.log(l_module_name, 'Delivery Detail Id', p_del_det_int_rec.delivery_detail_id);
       END IF;

	-- Add To Packing Table, only for update cases
	IF(p_update_mode = 'UPDATE') THEN
		OPEN intf_parent_det_cur;
		FETCH intf_parent_det_cur INTO l_intf_parent_det_id, l_container_flag;
		CLOSE intf_parent_det_cur;

                IF l_debug_on THEN
                 wsh_debug_sv.log (l_module_name, 'l_container_flag', l_container_flag);
		 wsh_debug_sv.log (l_module_name, 'Parent del.detail in intef assgn', l_intf_parent_det_id);
                 wsh_debug_sv.log(l_module_name, 'Organization id of detail', p_del_det_int_rec.organization_id);
                END IF;

		IF(l_intf_parent_det_id IS NOT NULL) THEN

                        l_packing_detail_rec.delivery_detail_id	 := p_del_det_int_rec.delivery_detail_id;
                        l_packing_detail_rec.src_container_flag	 := l_container_flag;

			OPEN base_detail_cur(l_intf_parent_det_id);
			FETCH base_detail_cur INTO l_packing_detail_rec.parent_delivery_detail_id;

                        IF l_debug_on THEN
		 	 wsh_debug_sv.log (l_module_name, 'Base table detail id', l_packing_detail_rec.parent_delivery_detail_id);
			END IF;

			IF( base_detail_cur%NOTFOUND) THEN
				raise packing_error;
			END IF;

			CLOSE base_detail_cur;

			G_Packing_Detail_Tab((G_Packing_Detail_Tab.count) +1) := l_packing_detail_rec;

		END IF; -- if l_intf_parent_det_id
	END IF; -- if p_udpate_mode is UPDATE

	l_changed_attributes.source_header_id	:=	p_del_det_int_rec.source_header_id;
	l_changed_attributes.source_line_id	:=	p_del_det_int_rec.source_line_id;
	l_changed_attributes.source_code        :=      p_del_det_int_rec.source_code;
--	l_changed_attributes.sold_to_org_id	:=	p_del_det_int_rec.sold_to_org_id;
--	l_changed_attributes.customer_number    :=	p_del_det_int_rec.customer_number;
	l_changed_attributes.sold_to_contact_id	:=	p_del_det_int_rec.sold_to_contact_id;
--	l_changed_attributes.ship_from_org_id	:=	p_del_det_int_rec.ship_from_org_id;
--	l_changed_attributes.ship_to_org_id	:=	p_del_det_int_rec.ship_to_location_id;
	l_changed_attributes.ship_to_contact_id	:=	p_del_det_int_rec.ship_to_contact_id;
--	l_changed_attributes.deliver_to_org_id	:=	p_del_det_int_rec.deliver_to_org_id;
	l_changed_attributes.deliver_to_contact_id	:=	p_del_det_int_rec.deliver_to_contact_id;
--	l_changed_attributes.intmed_ship_to_org_id	:=	p_del_det_int_rec.intmed_ship_to_org_id;
	l_changed_attributes.intmed_ship_to_contact_id	:=	p_del_det_int_rec.intmed_ship_to_contact_id;
	l_changed_attributes.preferred_grade	:=	p_del_det_int_rec.preferred_grade;

        --bugfix 8841528

       IF(nvl(WSH_INBOUND_SHIP_ADVICE_PKG.G_WAREHOUSE_TYPE, FND_API.G_MISS_CHAR) = 'CMS') AND (p_del_det_int_rec.container_flag = 'Y') THEN

	 OPEN inv_detail_cur;
         FETCH inv_detail_cur INTO l_delivery_detail_id,l_subinventory,l_locator_id;
	 CLOSE inv_detail_cur;
	  --
          IF l_debug_on THEN
             wsh_debug_sv.log (l_module_name, 'Base table delivery detail id', l_delivery_detail_id);
 	     wsh_debug_sv.log (l_module_name, 'Base table  subinventory', l_subinventory);
 	     wsh_debug_sv.log (l_module_name, 'Base table locator ', l_locator_id);
	  END IF;
         --
      	  l_changed_attributes.subinventory	:=	nvl(p_del_det_int_rec.subinventory,l_subinventory);

          l_wms_installed := wsh_util_validate.Check_Wms_Org(p_del_det_int_rec.organization_id);

	   --
	   IF l_wms_installed = 'Y' THEN

	       l_changed_attributes.locator_id		:=	nvl(p_del_det_int_rec.locator_id,l_locator_id);

           ELSE
	      l_changed_attributes.locator_id		:=	p_del_det_int_rec.locator_id;

	   END IF ;
           --
        ELSE

        l_changed_attributes.subinventory	:=	p_del_det_int_rec.subinventory;
	l_changed_attributes.locator_id		:=	p_del_det_int_rec.locator_id;
       END IF;

	l_changed_attributes.revision		:=	p_del_det_int_rec.revision;
	l_changed_attributes.lot_number		:=	p_del_det_int_rec.lot_number;
-- HW OPMCONV - No need for sublot_number
--      l_changed_attributes.sublot_number	:=	p_del_det_int_rec.sublot_number;
	l_changed_attributes.customer_requested_lot_flag	:=	p_del_det_int_rec.customer_requested_lot_flag;
        /* --kvenkate commenting the following line in patchset I
	l_changed_attributes.serial_number	:=	nvl(p_del_det_int_rec.serial_number, FND_API.G_MISS_CHAR);
        */
        l_changed_attributes.serial_number	:=      p_del_det_int_rec.serial_number;
		l_changed_attributes.master_container_item_id	:=	p_del_det_int_rec.master_container_item_id;
	l_changed_attributes.detail_container_item_id	:=	p_del_det_int_rec.detail_container_item_id;


-- 	No need to pass ship method code because when a delivery is present, the ship method code of
--      delivery detail should not be updated.
--	l_changed_attributes.shipping_method_code	:=	p_del_det_int_rec.ship_method_code;
	l_changed_attributes.carrier_id		:=	p_del_det_int_rec.carrier_id;

--	l_changed_attributes.freight_terms_code	:=	p_del_det_int_rec.freight_terms_code;
	l_changed_attributes.shipment_priority_code	:=	p_del_det_int_rec.shipment_priority_code;
--	l_changed_attributes.fob_code		:=	p_del_det_int_rec.fob_code;
	l_changed_attributes.dep_plan_required_flag	:=	p_del_det_int_rec.dep_plan_required_flag;
	l_changed_attributes.customer_prod_seq	:=	p_del_det_int_rec.customer_prod_seq;
	l_changed_attributes.customer_dock_code	:=	p_del_det_int_rec.customer_dock_code;
	l_changed_attributes.gross_weight	:=	p_del_det_int_rec.gross_weight;
	l_changed_attributes.net_weight		:=	p_del_det_int_rec.net_weight;
	l_changed_attributes.weight_uom_code	:=	p_del_det_int_rec.weight_uom_code;
	l_changed_attributes.volume		:=	p_del_det_int_rec.volume;
	l_changed_attributes.volume_uom_code	:=	p_del_det_int_rec.volume_uom_code;
        -- J: W/V Changes
        l_changed_attributes.filled_volume      :=      p_del_det_int_rec.filled_volume;
        l_changed_attributes.fill_percent       :=      p_del_det_int_rec.fill_percent;
        l_changed_attributes.wv_frozen_flag     :=      p_del_det_int_rec.wv_frozen_flag;

	l_changed_attributes.top_model_line_id	:=	p_del_det_int_rec.top_model_line_id;
	l_changed_attributes.ato_line_id	:=	p_del_det_int_rec.ato_line_id;
	l_changed_attributes.arrival_set_id	:=	p_del_det_int_rec.arrival_set_id;
	l_changed_attributes.ship_model_complete_flag	:=	p_del_det_int_rec.ship_model_complete_flag;
	l_changed_attributes.cust_po_number	:=	p_del_det_int_rec.cust_po_number;
	l_changed_attributes.packing_instructions	:=	p_del_det_int_rec.packing_instructions;
	l_changed_attributes.shipping_instructions	:=	p_del_det_int_rec.shipping_instructions;
        IF l_debug_on THEN
           wsh_debug_sv.log(l_module_name,'Orig Container Name',
                                             p_del_det_int_rec.container_name);
           wsh_debug_sv.log(l_module_name,'delivery detail id',
                                         p_del_det_int_rec.delivery_detail_id);
           wsh_debug_sv.log(l_module_name,'container flag',
                                             p_del_det_int_rec.container_flag);
        END IF;
        IF (p_del_det_int_rec.container_flag = 'Y' )
          AND (NVL(p_del_det_int_rec.container_name ,FND_API.G_MISS_CHAR) <>
                 FND_API.G_MISS_CHAR)
          AND (NVL(p_del_det_int_rec.delivery_detail_id,FND_API.G_MISS_NUM) <>
                 FND_API.G_MISS_NUM)
        THEN
           l_changed_attributes.container_name	:=
                     SUBSTRB(TO_CHAR(p_del_det_int_rec.delivery_detail_id)||
                     '-' || p_del_det_int_rec.container_name ,1,30);
        ELSE
           l_changed_attributes.container_name  :=
                     nvl(p_del_det_int_rec.container_name,FND_API.G_MISS_CHAR);
        END IF;

        IF l_debug_on THEN
           wsh_debug_sv.log(l_module_name,'New container name',
                                         l_changed_attributes.container_name);
        END IF;

	l_changed_attributes.container_flag 	:=	p_del_det_int_rec.container_flag ;
	l_changed_attributes.delivery_detail_id	:=	p_del_det_int_rec.delivery_detail_id;

        IF l_debug_on THEN
	 wsh_debug_sv.log (l_module_name, 'Shipped Quantity ', p_del_det_int_rec.shipped_quantity);
        END IF;

	IF nvl(p_del_det_int_rec.shipped_quantity,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN
	   l_changed_attributes.shipped_quantity	:=	0;
	ELSE
	   l_changed_attributes.shipped_quantity	:=	p_del_det_int_rec.shipped_quantity;
	END IF;
	l_changed_attributes.cycle_count_quantity	:=	p_del_det_int_rec.cycle_count_quantity;
	l_changed_attributes.tracking_number 	:=	p_del_det_int_rec.tracking_number ;
	l_changed_attributes.attribute1		:=	p_del_det_int_rec.attribute1;
	l_changed_attributes.attribute2		:=	p_del_det_int_rec.attribute2;
	l_changed_attributes.attribute3		:=	p_del_det_int_rec.attribute3;
	l_changed_attributes.attribute4		:=	p_del_det_int_rec.attribute4;
	l_changed_attributes.attribute5		:=	p_del_det_int_rec.attribute5;
	l_changed_attributes.attribute6		:=	p_del_det_int_rec.attribute6;
	l_changed_attributes.attribute7		:=	p_del_det_int_rec.attribute7;
	l_changed_attributes.attribute8		:=	p_del_det_int_rec.attribute8;
	l_changed_attributes.attribute9		:=	p_del_det_int_rec.attribute9;
	l_changed_attributes.attribute10	:=	p_del_det_int_rec.attribute10;
	l_changed_attributes.attribute11	:=	p_del_det_int_rec.attribute11;
	l_changed_attributes.attribute12	:=	p_del_det_int_rec.attribute12;
	l_changed_attributes.attribute13	:=	p_del_det_int_rec.attribute13;
	l_changed_attributes.attribute14	:=	p_del_det_int_rec.attribute14;
	l_changed_attributes.attribute15	:=	p_del_det_int_rec.attribute15;
        l_changed_attributes.to_serial_number   :=      p_del_det_int_rec.to_serial_number;
	l_changed_attributes.requested_quantity_uom :=  p_del_det_int_rec.requested_quantity_uom;

        if l_debug_on then
           wsh_debug_sv.log(l_module_name, 'subinventory:', l_changed_attributes.subinventory);
           wsh_debug_sv.log(l_module_name, 'Container Name:', l_changed_attributes.container_name);
           wsh_debug_sv.log(l_module_name, 'Tracking Number', l_changed_attributes.tracking_number);
        end if;



        G_Update_Attributes_Tab((G_Update_Attributes_Tab.count)+1) := l_changed_attributes;


       /* Patchset I: passing serial numbers to group api. so no need for the direct update of to_serial_number
              -- kvenkate. Removed the code for direct update.
       */

        IF l_debug_on THEN
	 wsh_debug_sv.pop(l_module_name);
	END IF;

EXCEPTION
WHEN packing_error THEN
	IF(base_detail_cur%ISOPEN) THEN
		CLOSE base_detail_cur;
	END IF;
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'packing_error exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:packing_error');
        END IF;

WHEN Others THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;

END Add_To_Update_Table;


PROCEDURE Process_Cancel(
		p_delivery_id	IN NUMBER,
		x_return_status	OUT NOCOPY  VARCHAR2) IS

CURSOR del_details_cur IS
SELECT wdd.delivery_detail_id,
wdd.source_line_id,
wdd.source_code,
wdd.container_flag,
wdd.requested_quantity_uom
FROM wsh_delivery_details wdd,
wsh_delivery_assignments_v wda
WHERE wdd.delivery_detail_id = wda.delivery_detail_id
AND wda.delivery_id = p_delivery_id;

l_del_det_int_rec	del_det_int_cur%ROWTYPE;
l_return_status		VARCHAR2(30);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PROCESS_CANCEL';
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
	wsh_debug_sv.push(l_module_name, 'Process_Cancel');
	wsh_debug_sv.log (l_module_name, 'Delivery Id', p_delivery_id);
       END IF;

	x_return_status	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	-- select the delivery lines
	-- Add to the global update table

	FOR del_details_rec IN del_details_cur LOOP

		l_del_det_int_rec.delivery_detail_id := del_details_rec.delivery_detail_id;
		l_del_det_int_rec.source_line_id     := del_details_rec.source_line_id;
		l_del_det_int_rec.source_code        := del_details_rec.source_code;
		l_del_det_int_rec.container_flag     := del_details_rec.container_flag;
		l_del_det_int_rec.requested_quantity_uom := del_details_rec.requested_quantity_uom;
                IF l_debug_on THEN
		 wsh_debug_sv.log (l_module_name, 'For cancel, delivery detail id',l_del_det_int_rec.delivery_detail_id);
                END IF;

		Add_To_Update_Table(
			l_del_det_int_rec,
			'CANCEL',
			p_delivery_id,
			l_return_status);

                IF l_debug_on THEN
		 wsh_debug_sv.log (l_module_name, 'return status from add_to_update_tbl', l_return_status);
                END IF;

	END LOOP; -- for del_details_rec


	-- call update_delivery_details
	Update_Delivery_Details(
		p_source_code  => 'WSH',
		p_action_code  => 'CANCEL',
		x_return_status	=> l_return_status
		);

        IF l_debug_on THEN
	 wsh_debug_sv.log (l_module_name, 'Update_Delivery_Details l_return_status',l_return_status);
        END IF;

        IF l_debug_on THEN
	 wsh_debug_sv.pop(l_module_name);
        END IF;

EXCEPTION
WHEN Others THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;

END Process_Cancel;

PROCEDURE Lock_Delivery_And_Details(
	p_delivery_id	IN	NUMBER,
	x_return_status	OUT NOCOPY 	VARCHAR2) IS

l_dummy_id	NUMBER;

CURSOR lock_delivery_details IS
SELECT wdd.delivery_detail_id
FROM wsh_delivery_details wdd, wsh_delivery_assignments_v wda
WHERE wdd.delivery_detail_id = wda.delivery_detail_id
AND wda.delivery_id = p_delivery_id
FOR UPDATE NOWAIT;

det_ids lock_delivery_details%ROWTYPE;
RECORD_LOCKED		 EXCEPTION;
PRAGMA EXCEPTION_INIT(RECORD_LOCKED, -54);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_DELIVERY_AND_DETAILS';
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
	wsh_debug_sv.push(l_module_name, 'Lock_Delivery_And_Details');
	wsh_debug_sv.log (l_module_name, 'Delivery Id', p_delivery_id);
       END IF;

	x_return_status := wsh_util_core.g_ret_sts_success;

       IF l_debug_on THEN
	wsh_debug_sv.logmsg(l_module_name, 'Locking the Delivery');
       END IF;
	SELECT delivery_id
	INTO l_dummy_id
	FROM wsh_new_deliveries
	WHERE delivery_id = p_delivery_id
	FOR UPDATE NOWAIT;

       IF l_debug_on THEN
	wsh_debug_sv.logmsg(l_module_name, 'Locking the delivery details');
       END IF;
	OPEN lock_delivery_details;
	FETCH lock_delivery_details INTO det_ids;
	IF lock_delivery_details%NOTFOUND THEN
	    IF l_debug_on THEN
		wsh_debug_sv.logmsg(l_module_name, 'No details found');
            END IF;

		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		CLOSE lock_delivery_details;
	END IF;
	IF (lock_delivery_details%ISOPEN) THEN
		CLOSE lock_delivery_details;
	END IF;
       IF l_debug_on THEN
	wsh_debug_sv.pop(l_module_name);
       END IF;

EXCEPTION
	WHEN RECORD_LOCKED THEN
	  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

	  IF l_debug_on THEN
	    wsh_debug_sv.logmsg(l_module_name, 'Could not obtain lock');
	  END IF;

	  FND_MESSAGE.Set_Name('WSH', 'WSH_NO_LOCK');
	  WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
          IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'RECORD_LOCKED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:RECORD_LOCKED');
          END IF;

	WHEN others THEN
	  x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
          IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
          END IF;
END Lock_Delivery_And_Details;


-- TPW - Distributed changes
PROCEDURE Lock_Delivery_Details(
	p_delivery_interface_id	IN	NUMBER,
	x_return_status	OUT NOCOPY 	VARCHAR2) IS

l_dummy_id	NUMBER;

CURSOR lock_delivery_details IS
SELECT wdd.delivery_detail_id
FROM   wsh_delivery_details wdd,
       wsh_delivery_assignments wda
WHERE  wdd.source_code = 'OE'
AND    wdd.delivery_detail_id = wda.delivery_detail_id
AND    wdd.released_status in ('R','B','X')
AND    wdd.delivery_detail_id in (
         select wdd1.delivery_detail_id
         from   wsh_del_details_interface wddi,
                wsh_del_assgn_interface wdai,
                wsh_shipment_batches wsb,
                wsh_transactions_history wth,
                wsh_delivery_details wdd1
         where  wdd1.source_code = 'OE'
         and    wdd1.released_status in ('R','B','X')
         and    wdd1.shipment_line_number = wddi.delivery_detail_id
         and    wddi.delivery_detail_interface_id = wdai.delivery_detail_interface_id
         and    wdai.delivery_interface_id = p_delivery_interface_id
         and    wddi.line_direction = 'O'
         AND    wdd1.shipment_batch_id = wsb.batch_id
         AND    wsb.name = wth.entity_number
         AND    wth.entity_type = 'BATCH'
         AND    wth.document_number = wddi.source_header_number
         AND    wth.document_type = 'SR'
         AND    wth.document_direction = 'O'
         UNION
         SELECT wdd1.delivery_detail_id
         FROM wsh_del_details_interface wddi,
              wsh_del_assgn_interface wdai,
              wsh_delivery_details wdd1,
              oe_order_lines_all ol,
              po_requisition_lines_all pl,
              po_requisition_headers_all ph
         where wdd1.source_code          = 'OE'
         and   wdd1.released_status in ('R','B','X')
         and wddi.delivery_detail_interface_id = wdai.delivery_detail_interface_id
         and wdai.delivery_interface_id = p_delivery_interface_id
         and wddi.line_direction      = 'IO'
         and wdd1.source_line_id       = ol.line_id
         and ol.source_document_line_id = pl.requisition_line_id
         and ol.source_document_id    = pl.requisition_header_id
         and pl.requisition_header_id = ph.requisition_header_id
         and pl.line_num             = wddi.delivery_detail_id
         and ph.segment1             = wddi.source_header_number)
FOR UPDATE OF wdd.attribute1, wda.parent_delivery_id NOWAIT;


det_ids lock_delivery_details%ROWTYPE;
RECORD_LOCKED		 EXCEPTION;
PRAGMA EXCEPTION_INIT(RECORD_LOCKED, -54);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_DELIVERY_DETAILS';
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
	wsh_debug_sv.push(l_module_name, 'Lock_Delivery_Details');
	wsh_debug_sv.log (l_module_name, 'Delivery Interface Id', p_delivery_interface_id);
       END IF;

	x_return_status := wsh_util_core.g_ret_sts_success;

       IF l_debug_on THEN
	wsh_debug_sv.logmsg(l_module_name, 'Locking the delivery details');
       END IF;
	OPEN lock_delivery_details;
	FETCH lock_delivery_details INTO det_ids;
	IF lock_delivery_details%NOTFOUND THEN
	    IF l_debug_on THEN
		wsh_debug_sv.logmsg(l_module_name, 'No details found');
            END IF;

		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		CLOSE lock_delivery_details;
	END IF;
	IF (lock_delivery_details%ISOPEN) THEN
		CLOSE lock_delivery_details;
	END IF;
       IF l_debug_on THEN
	wsh_debug_sv.pop(l_module_name);
       END IF;

EXCEPTION
	WHEN RECORD_LOCKED THEN
	  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

	  IF l_debug_on THEN
	    wsh_debug_sv.logmsg(l_module_name, 'Could not obtain lock');
	  END IF;

	  FND_MESSAGE.Set_Name('WSH', 'WSH_NO_LOCK');
	  WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
          IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'RECORD_LOCKED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:RECORD_LOCKED');
          END IF;

	WHEN others THEN
	  x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
          IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
          END IF;
END Lock_Delivery_Details;

PROCEDURE log_errors(
		p_loc_interface_errors_rec IN WSH_INTERFACE_VALIDATIONS_PKG.interface_errors_rec_type,
      		p_msg_data                 IN VARCHAR2 DEFAULT NULL,
    		p_api_name                 IN VARCHAR2,
		x_return_status OUT NOCOPY  VARCHAR2
		) IS
		--
l_debug_on BOOLEAN;
		--
		l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOG_ERRORS';
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
	wsh_debug_sv.push(l_module_name, 'log_errors');
	wsh_debug_sv.log (l_module_name, 'Interface table name', p_loc_interface_errors_rec.p_interface_table_name);
	wsh_debug_sv.log (l_module_name, 'Interface Id', p_loc_interface_errors_rec.p_interface_id);
	wsh_debug_sv.log (l_module_name, 'Message Name', p_loc_interface_errors_rec.p_message_name);
      END IF;

	WSH_INTERFACE_VALIDATIONS_PKG.Log_Interface_Errors(
		      p_interface_errors_rec   => p_loc_interface_errors_rec,
            	      p_msg_data               => p_msg_data,
    	              p_api_name               => p_api_name,
		      x_return_status          => x_return_status);

      IF l_debug_on THEN
	wsh_debug_sv.log (l_module_name, 'Return status from Log_Interface_Errors', x_return_status);
	wsh_debug_sv.pop(l_module_name);
      END IF;
EXCEPTION
	WHEN others THEN
	  x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
          IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
          END IF;

END Log_Errors;

PROCEDURE split_delivery_detail(
   p_delivery_detail_id   IN              NUMBER,
   p_qty_to_split         IN              NUMBER,
   x_new_detail_id        OUT NOCOPY      NUMBER,
   x_return_status        OUT NOCOPY      VARCHAR2
) IS

   l_base_req_qty  NUMBER ;
   l_qty_to_split NUMBER;
   l_return_status VARCHAR2(30);
   l_number_of_errors	NUMBER := 0;
   l_number_of_warnings  NUMBER := 0;
   --
   CURSOR base_detail_qty(l_del_detail_id NUMBER) IS
   SELECT requested_quantity
   FROM wsh_delivery_details
   WHERE delivery_detail_id =l_del_detail_id;
   --
   l_debug_on                    BOOLEAN;
   --
   l_module_name        CONSTANT VARCHAR2(100):= 'wsh.plsql.' || g_pkg_name || '.' || 'SPLIT_DELIVERY_DETAIL';
BEGIN
   --
   l_debug_on := wsh_debug_interface.g_debug;

   --
   IF l_debug_on IS NULL THEN
      l_debug_on := wsh_debug_sv.is_debug_enabled;
   END IF;

   --
   IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name, 'split_delivery_detail');
      wsh_debug_sv.LOG(l_module_name, 'p_delivery_detail_id',p_delivery_detail_id);
      wsh_debug_sv.LOG(l_module_name, 'p_qty_to_split', p_qty_to_split);
   END IF;

   OPEN base_detail_qty(p_delivery_detail_id);
   FETCH base_detail_qty INTO l_base_req_qty;
   CLOSE base_detail_qty;

   IF l_debug_on THEN
      wsh_debug_sv.LOG(l_module_name, 'Base req qty', l_base_req_qty);
   END IF;

   IF (p_qty_to_split > l_base_req_qty) THEN
      -- Quantity has exceeded
      -- so exit
      NULL;
   ELSIF(p_qty_to_split = l_base_req_qty) THEN
      NULL;
   ELSE
      -- call split_delivery_details
      IF l_debug_on THEN
         wsh_debug_sv.LOG(l_module_name, 'qty to split', p_qty_to_split);
      END IF;

      IF p_qty_to_split IS NULL THEN
         fnd_message.set_name('WSH', 'WSH_REQUIRED_FIELD_NULL');
         fnd_message.set_token('FIELD_NAME', 'REQUESTED_QTY');
         wsh_util_core.add_message(wsh_util_core.g_ret_sts_error);
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      l_qty_to_split := p_qty_to_split;
      wsh_delivery_details_actions.split_delivery_details(
         p_from_detail_id => p_delivery_detail_id,
         p_req_quantity => l_qty_to_split,
         x_new_detail_id => x_new_detail_id,
         x_return_status => l_return_status);

      IF l_debug_on THEN
         wsh_debug_sv.LOG(l_module_name, 'Split_Delivery_Details x_new_detail_id,l_return_status',
            x_new_detail_id || ',' || l_return_status);
      END IF;

      wsh_util_core.api_post_call(
         p_return_status  =>l_return_status,
         x_num_warnings	 =>l_number_of_warnings,
         x_num_errors	   =>l_number_of_errors);
   END IF;

   IF l_number_of_warnings > 0 THEN
      IF l_debug_on THEN
         wsh_debug_sv.logmsg (l_module_name,'Number of warnings', l_number_of_warnings);
      END IF;
      RAISE WSH_UTIL_CORE.G_EXC_WARNING;
   END IF;

   x_return_status := wsh_util_core.g_ret_sts_success;

   IF l_debug_on THEN
      wsh_debug_sv.pop(l_module_name);
   END IF;
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      --
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name,
            'FND_API.G_EXC_ERROR exception has occured.',
            wsh_debug_sv.c_excep_level);
         wsh_debug_sv.pop(l_module_name, 'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
   --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      --
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name,
            'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',
            wsh_debug_sv.c_excep_level);
         wsh_debug_sv.pop(l_module_name,
            'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
   --
   WHEN wsh_util_core.g_exc_warning THEN
      x_return_status := wsh_util_core.g_ret_sts_warning;
      --
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name,
            'WSH_UTIL_CORE.G_EXC_WARNING exception has occured ',
            wsh_debug_sv.c_excep_level);
         wsh_debug_sv.pop(l_module_name,
            'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
   WHEN OTHERS THEN
      x_return_status := wsh_util_core.g_ret_sts_unexp_error;
      wsh_util_core.default_handler('WSH_INTERFACE_COMMON_ACTIONS.split_delivery_detail');
      --
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name,
               'Unexpected error has occured. Oracle error message is '
            || SQLERRM,
            wsh_debug_sv.c_unexpec_err_level);
         wsh_debug_sv.pop(l_module_name, 'EXCEPTION:OTHERS');
      END IF;
END split_delivery_detail;


PROCEDURE add_to_serial_table(
   p_serial_range_tab     IN  WSH_GLBL_VAR_STRCT_GRP.ddSerialRangeTabType)
IS
l_index  NUMBER;
l_g_count NUMBER;
BEGIN
    l_index := p_serial_range_tab.first;
    while l_index is not null loop
        l_g_count := g_serial_range_tab.count;
        g_serial_range_tab(l_g_count + 1).delivery_detail_id := p_serial_range_tab(l_index).delivery_detail_id;
        g_serial_range_tab(l_g_count + 1).from_serial_number := p_serial_range_tab(l_index).from_serial_number;
        g_serial_range_tab(l_g_count + 1).to_serial_number := p_serial_range_tab(l_index).to_serial_number;
        g_serial_range_tab(l_g_count + 1).quantity := p_serial_range_tab(l_index).quantity;
        l_index := p_serial_range_tab.next(l_index);
    end loop;
EXCEPTION
WHEN OTHERS THEN
      raise fnd_api.g_exc_error;
END add_to_serial_table;

END WSH_INTERFACE_COMMON_ACTIONS;

/
