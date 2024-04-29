--------------------------------------------------------
--  DDL for Package Body WSH_INBOUND_SHIP_ADVICE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_INBOUND_SHIP_ADVICE_PKG" as
/* $Header: WSHINSAB.pls 120.2.12010000.3 2010/02/26 07:09:11 sankarun ship $ */

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_INBOUND_SHIP_ADVICE_PKG';
--
PROCEDURE Process_Ship_Advice(
		p_delivery_interface_id IN NUMBER,
		p_event_key		IN VARCHAR2,
		x_return_status OUT NOCOPY  VARCHAR2
			) IS
l_delivery_id 		NUMBER;
l_delivery_name		VARCHAR2(30);
l_organization_id	NUMBER := NULL;
l_return_status 	VARCHAR2(30);
l_del_rows  		wsh_util_core.id_tab_type;
l_unplan_del_rows	wsh_util_core.id_tab_type;
l_warehouse_type	VARCHAR2(30);
l_dummy			NUMBER;
l_not_recv_count	NUMBER;
-- ship confirm variables
l_sc_action_flag	VARCHAR2(1);
l_sc_intransit_flag	VARCHAR2(1);
l_sc_close_trip_flag	VARCHAR2(1);
l_sc_create_bol_flag	VARCHAR2(1);
l_sc_stage_del_flag	VARCHAR2(1);
l_sc_trip_ship_method	VARCHAR2(30);
l_sc_actual_dep_date	DATE;
l_sc_report_set_id	NUMBER;
l_sc_report_set_name	VARCHAR2(30);

l_pickup_stop_id	NUMBER;
l_dropoff_stop_id	NUMBER;
l_trip_id		NUMBER;
l_actual_dep_date	DATE;
l_stop_rows		wsh_util_core.id_tab_type;

l_msg_count	NUMBER;
l_msg_data	VARCHAR2(4000);
l_msg_details	VARCHAR2(4000);

l_bo_rows      wsh_util_core.id_tab_type; -- list of details to Backorder
l_bo_qtys      wsh_util_core.id_tab_type; --  list of details BO qty
l_bo_qtys2     wsh_util_core.id_tab_type; --  list of details BO qty2
l_req_qtys     wsh_util_core.id_tab_type; --  list of details req qty
l_overpick_qtys     wsh_util_core.id_tab_type; -- list of details overpick qty
l_overpick_qtys2    wsh_util_core.id_tab_type; --list of details overpick qty2
l_cc_ids	wsh_util_core.id_tab_type;

l_det_rq	NUMBER;
l_det_pq	NUMBER;
l_overpick_qty	NUMBER;
l_cont_flag	VARCHAR2(1);
l_wf_rs	VARCHAR2(1); --Pick tp POD Wf Project
-- cursors

CURSOR del_id IS
SELECT delivery_id, name,
	organization_id  --AD Trip Consolidation heali
FROM wsh_new_del_interface
WHERE delivery_interface_id = p_delivery_interface_id
AND INTERFACE_ACTION_CODE ='94X_INBOUND';

-- TPW - Distributed changes
CURSOR c_get_del_name (c_delivery_id IN NUMBER) IS
SELECT name FROM wsh_new_deliveries
WHERE  delivery_id = c_delivery_id;

CURSOR cont_not_recv_cur(l_delivery_id NUMBER, l_delivery_interface_id NUMBER) IS
SELECT wda.delivery_detail_id
FROM wsh_delivery_assignments_v wda,
wsh_delivery_details wdd
where wdd.delivery_detail_id = wda.delivery_detail_id
and wdd.container_flag = 'Y'
and wda.parent_delivery_detail_id IS NULL
and wda.delivery_id IS NOT NULL
and wda.delivery_id = l_delivery_id
MINUS
SELECT wdai.delivery_detail_id
FROM wsh_del_assgn_interface wdai,
wsh_del_details_interface wddi
where wddi.delivery_detail_interface_id = wdai.delivery_detail_interface_id
and wddi.container_flag = 'Y'
and wdai.parent_delivery_detail_id IS NULL
and wdai.delivery_interface_id IS NOT NULL
and wdai.delivery_interface_id = l_delivery_interface_id
AND WDAI.INTERFACE_ACTION_CODE = '94X_INBOUND'
AND WDDI.INTERFACE_ACTION_CODE = '94X_INBOUND';

CURSOR cont_contents_cur(l_del_detail_id NUMBER) IS
SELECT wda.delivery_detail_id
FROM wsh_delivery_assignments_v wda
WHERE parent_delivery_detail_id IS NOT NULL
START WITH wda.delivery_detail_id = l_del_detail_id
CONNECT BY PRIOR delivery_detail_id = parent_delivery_detail_id;

CURSOR det_qtys_cur(l_del_detail_id NUMBER) IS
SELECT requested_quantity, picked_quantity, container_flag
FROM wsh_delivery_details
WHERE delivery_detail_id = l_del_detail_id;

--Bug 3346237:ENFORCE SHIP METHOD NOT ENFORCED WHILE SHIP CONFIRMING
--Created new cursor get_defer_interface_info to get defer_interface
--value from global parameters table.


--SA Trip Consolidation heali

CURSOR get_inbd_trip_info (p_organization_id NUMBER) IS
 SELECT nvl(IGNORE_INBOUND_TRIP,'N')
 FROM WSH_SHIPPING_PARAMETERS
 WHERE organization_id = p_organization_id;

CURSOR get_defer_interface_info IS
 SELECT nvl(defer_interface,'N')
 FROM WSH_GLOBAL_PARAMETERS;


l_ignore_inbd_trip		varchar2(1);
l_autocreate_trip_flag		varchar2(1);
l_defer_interface_flag		varchar2(1);
l_del_orgaization_id		NUMBER;

-- l_dummy_line_ids		WSH_UTIL_CORE.Id_Tab_Type;

--exceptions
process_delivery_failed		exception;
create_update_trip_failed	exception;
validate_delivery_failed	exception;
ship_confirm_failed		exception;
update_dlvy_status_failed	exception;
invalid_input			exception;
get_warehouse_type_failed	exception;
others_update_dlvy_det		exception;
others_create_update_trip	exception;
others_ship_confirm		exception;

l_detail_tab WSH_UTIL_CORE.id_tab_type;  -- DBI Project
l_dbi_rs                      VARCHAR2(1); -- Return Status from DBI API
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PROCESS_SHIP_ADVICE';
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
	wsh_debug_sv.push(l_module_name);
	wsh_debug_sv.log (l_module_name, 'Delivery Interface Id', p_delivery_interface_id);
	wsh_debug_sv.log (l_module_name, 'Event Key', p_event_key);
       END IF;

	x_return_status	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	IF(p_delivery_interface_id IS NULL) THEN
		raise invalid_input;
	END IF;

	OPEN del_id;
	FETCH del_id INTO l_delivery_id, l_delivery_name,l_del_orgaization_id;
	CLOSE del_id;

       IF l_debug_on THEN
	wsh_debug_sv.log (l_module_name, 'Delivery ID', l_delivery_id);
       END IF;

        --SA Trip Consolidation heali
        OPEN get_inbd_trip_info(l_del_orgaization_id);
        FETCH get_inbd_trip_info INTO l_ignore_inbd_trip;
        CLOSE get_inbd_trip_info;
        --SA Trip Consolidation heali

        IF l_debug_on THEN
 	   wsh_debug_sv.log (l_module_name, 'l_ignore_inbd_trip',l_ignore_inbd_trip);
	END IF;

        ----Bug 3346237:ENFORCE SHIP METHOD NOT ENFORCED WHILE SHIP CONFIRMING
        OPEN get_defer_interface_info;
        FETCH get_defer_interface_info INTO l_defer_interface_flag;
        CLOSE get_defer_interface_info;

	IF l_debug_on THEN
 	   wsh_debug_sv.log (l_module_name, 'l_defer_interface_flag',l_defer_interface_flag);
        END IF;

	-- check for warehouse type
	l_warehouse_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type(
                -- TPW - Distributed changes
		P_Organization_ID	=> l_del_orgaization_id,
		P_Event_Key 		=> p_event_key,
		X_Return_Status   	=> l_return_status);

       IF l_debug_on THEN
	wsh_debug_sv.log (l_module_name, 'Return status from get warehouse type', l_return_status);
	wsh_debug_sv.log (l_module_name, 'Warehouse type ', l_warehouse_type);
       END IF;

	IF(l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
		raise get_warehouse_type_failed;
	END IF;

	G_WAREHOUSE_TYPE := l_warehouse_type;


	-- Validate the delivery and the delivery details
	-- This procedure checks if the incoming delivery_id and delivery_detail_ids
	-- exist in the instance
	-- For delivery details, only the non-container records would be checked
	-- Because, for inbound from TPW, there could be new delivery details for containers

        -- TPW - Distributed changes
        IF (nvl(WSH_INBOUND_SHIP_ADVICE_PKG.G_WAREHOUSE_TYPE, '!') = 'TW2') THEN
	  WSH_INTERFACE_VALIDATIONS_PKG.Validate_Delivery_Details
		(p_delivery_interface_id => p_delivery_interface_id,
		 x_return_Status	 => l_return_status);
          IF l_debug_on THEN
	    wsh_debug_sv.log (l_module_name, 'Return status from Validate Delivery Details', l_return_status);
          END IF;

	  IF(l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
		raise validate_delivery_failed;
	  END IF;
        ELSE
	  WSH_INTERFACE_VALIDATIONS_PKG.Validate_Deliveries
		(p_delivery_id		=> l_delivery_id,
		 x_return_Status	=> l_return_status);
          IF l_debug_on THEN
	    wsh_debug_sv.log (l_module_name, 'Return status from Validate Deliveries', l_return_status);
          END IF;

	  IF(l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
		raise validate_delivery_failed;
	  END IF;
        END IF;

	-- Then compare the base table data with interface
	-- To see if the critical data are same
	-- This comparison is needed only for TPW.

	/*IF (nvl(l_warehouse_type, '!') = 'TPW') THEN

		WSH_INTERFACE_VALIDATIONS_PKG.Compare_Ship_Request_Advice
			(P_Delivery_ID		=> l_delivery_id,
	 		 X_Return_Status	=> l_return_status);

               IF l_debug_on THEN
		wsh_debug_sv.log (l_module_name, 'Return status from compare procedure', l_return_status);
               END IF;

		IF(l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
			raise validate_delivery_failed;
		END IF;
	END IF; */

        -- TPW - Distributed changes
        IF (l_delivery_id IS NULL) AND (nvl(WSH_INBOUND_SHIP_ADVICE_PKG.G_WAREHOUSE_TYPE, '!') in ('TPW', 'CMS')) THEN
                raise invalid_input;
        END IF;

	SAVEPOINT before_update_dlvy_det;

	BEGIN

          -- TPW - Distributed changes
	  IF nvl(WSH_INBOUND_SHIP_ADVICE_PKG.G_WAREHOUSE_TYPE, '!') = 'TW2' THEN
		  WSH_INTERFACE_COMMON_ACTIONS.Delivery_Interface_Wrapper(
			p_delivery_interface_id	=> p_delivery_interface_id,
			p_action_code		=> 'CREATE',
			x_delivery_id		=> l_delivery_id,
			x_return_status		=> l_return_status);
          ELSE

		WSH_INTERFACE_COMMON_ACTIONS.Delivery_Interface_Wrapper(
			p_delivery_interface_id	=> p_delivery_interface_id,
			p_action_code		=> 'UPDATE',
			x_delivery_id		=> l_dummy,
			x_return_status		=> l_return_status);
          END IF;

               IF l_debug_on THEN
		wsh_debug_sv.log (l_module_name, 'Return status from Dlvy Wrapper', l_return_status);
               END IF;

		IF(l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
			raise process_delivery_failed;
		ELSE
		     IF (nvl(l_warehouse_type, '!') = 'CMS') THEN
			-- If the inbound from CMS does not have a container that was sent in
			-- the outbound, the delivery details of the container need to be
			-- backordered. The following code does this check and action.

			-- First get the list of containers that are not received.
			l_not_recv_count := 0;
			FOR l_cont_not_recv IN cont_not_recv_cur(l_delivery_id, p_delivery_interface_id) LOOP
				l_not_recv_count := l_not_recv_count + 1;
                               IF l_debug_on THEN
				wsh_debug_sv.log (l_module_name, 'Container not received', l_cont_not_recv.delivery_detail_id);
                               END IF;
				-- For each of these containers, need to drill down and
				-- backorder the delivery details that are not containers
				FOR non_cont IN cont_contents_cur(l_cont_not_recv.delivery_detail_id) LOOP
                                 IF l_debug_on THEN
				  wsh_debug_sv.log (l_module_name, 'Contents', non_cont.delivery_detail_id);
                                 END IF;
					OPEN det_qtys_cur(non_cont.delivery_detail_id);
					FETCH det_qtys_cur INTO l_det_rq, l_det_pq, l_cont_flag;
					CLOSE det_qtys_cur;

					IF(l_cont_flag = 'N') THEN
					  l_bo_rows(l_bo_rows.count + 1)   := non_cont.delivery_detail_id;
					  l_req_qtys(l_req_qtys.count + 1) := l_det_rq;
					  l_overpick_qty := LEAST(l_det_rq,
									NVL(l_det_pq, l_det_rq) - l_det_rq);
                                         IF l_debug_on THEN
					  wsh_debug_sv.log (l_module_name, 'Over picked qty', l_overpick_qty);
 					  wsh_debug_sv.log (l_module_name, 'Req qty', l_det_rq);
					  wsh_debug_sv.log (l_module_name, 'Picked qty', l_det_pq);
                                         END IF;
					  l_overpick_qtys(l_overpick_qtys.count + 1) := l_overpick_qty;
					  l_bo_qtys(l_bo_qtys.count + 1) := l_det_rq - l_overpick_qty;
					END IF;

				END LOOP;
			END LOOP;

                       IF l_debug_on THEN
			wsh_debug_sv.log (l_module_name, 'Rows count ', l_bo_rows.count);
			wsh_debug_sv.log (l_module_name, 'Not received count', l_not_recv_count);
                       END IF;
			IF(l_not_recv_count > 0 AND l_bo_rows.count > 0) THEN
				wsh_ship_confirm_actions2.Backorder(
				    p_detail_ids => l_bo_rows ,
				    p_bo_qtys    => l_bo_qtys ,
				    p_req_qtys   => l_req_qtys ,
				    p_bo_qtys2   => l_bo_qtys2 ,
				    p_overpick_qtys  => l_overpick_qtys ,
				    p_overpick_qtys2   => l_overpick_qtys2 ,
				    p_bo_mode    => 'UNRESERVE',
				    x_out_rows => l_cc_ids ,
				    x_return_status  => l_return_status);
                               IF l_debug_on THEN
				wsh_debug_sv.log (l_module_name, 'Return status after backorder', l_return_status);
                               END IF;
			END IF; -- if l_not_recv_count
             	     END IF; -- if l_warehouse_type = cms

		END IF; -- if l_return_status<>success

	EXCEPTION
		WHEN process_delivery_failed THEN
			RAISE process_delivery_failed;
		WHEN others THEN
			RAISE others_update_dlvy_det;
	END;

	-- need to process trip and stops
	BEGIN

           IF l_ignore_inbd_trip='N' THEN --{
           --SA Trip Consolidation heali

		WSH_INTERFACE_COMMON_ACTIONS.Create_Update_Trip_For_Dlvy(
			p_delivery_id	=>l_delivery_id,
			x_pickup_stop_id => l_pickup_stop_id,
			x_dropoff_stop_id => l_dropoff_stop_id,
			x_trip_id	=> l_trip_id,
			x_return_status => l_return_status);

               IF l_debug_on THEN
		wsh_debug_sv.log (l_module_name, 'Return status from create-update-trip', l_return_status);
               END IF;

		IF(l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
			raise create_update_trip_failed;
		ELSE
		-- Return status success

		        -- TPW - Distributed changes
                        open  c_get_del_name(l_delivery_id);
                        fetch c_get_del_name into l_delivery_name;
                        close c_get_del_name;

                        IF l_debug_on THEN
		           wsh_debug_sv.log (l_module_name, 'Delivery Name', l_delivery_name);
                        END IF;

			-- 1. Need to update the txn. history record to success
			-- Because all data(dlvy, details, trip, stop) have been successfully moved to base tables
			  UPDATE wsh_transactions_history
                	     SET transaction_status = 'SC',
                        	 entity_number = l_delivery_name,
	                         entity_type = 'DLVY'
        	           WHERE entity_type = 'DLVY_INT'
                	     AND entity_number = to_char(p_delivery_interface_id)
	                     AND document_type = 'SA';


			IF (nvl(l_warehouse_type, '!') = 'CMS') THEN
				-- If there is atleast one container that is not received from CMS,
				-- we backorder the contents of that container
				-- Ship confirm will try to unassign those backordered lines from the delivery
				-- But since the delivery is planned , the unassign api will fail.
				-- Hence we need to UNPLAN the delivery in such cases.

                               IF l_debug_on THEN
				wsh_debug_sv.log (l_module_name, 'Contnr not received count', l_not_recv_count);
                               END IF;

				IF(l_not_recv_count > 0) THEN
					l_unplan_del_rows(1) := l_delivery_id;
					WSH_NEW_DELIVERY_ACTIONS.Unplan(
					p_del_rows		=> l_unplan_del_rows,
					 x_return_status	=> l_return_status);
                                        IF l_debug_on THEN
   					   wsh_debug_sv.log (l_module_name, 'Return status after Unplan', l_return_status);
                                        END IF;
				END IF;
			END IF; -- if l_warehouse_type

			-- 2. Need to delete the records in interface tables
			WSH_PROCESS_INTERFACED_PKG.Delete_Interface_Records(
				p_delivery_interface_id => p_delivery_interface_id,
			        x_return_status     => l_return_status);
                        IF l_debug_on THEN
			 wsh_debug_sv.log(l_module_name,'Return status after delete interface records', l_return_status);
                        END IF;
		END IF;
           END IF; --}
	EXCEPTION
		WHEN create_update_trip_failed THEN
		RAISE create_update_trip_failed;
		WHEN update_dlvy_status_failed THEN
			RAISE update_dlvy_status_failed;
		WHEN others THEN
		RAISE others_create_update_trip;
	END;
	l_stop_rows(l_stop_rows.count + 1 ) := l_pickup_stop_id;
	l_stop_rows(l_stop_rows.count + 1 ) := l_dropoff_stop_id;



	SAVEPOINT before_ship_confirm;
	BEGIN
		l_sc_intransit_flag	:= 'Y';
                --Standalone TPW FP changes
		--for TPW Batch based (TW2), setting the action flag to 'Ship'
                IF l_warehouse_type IN ('CMS', 'TW2') THEN
		   l_sc_action_flag	:= 'S';
                ELSIF l_warehouse_type = 'TPW' THEN
		   l_sc_action_flag	:= 'B';
                END IF;
		l_sc_close_trip_flag	:= 'Y';

		l_del_rows(1)	:= l_delivery_id;

                IF l_ignore_inbd_trip = 'N' THEN
                   l_autocreate_trip_flag:= 'Y';
                ELSE
                   l_autocreate_trip_flag:= 'N';
                END IF;

		 WSH_NEW_DELIVERY_ACTIONS.Confirm_Delivery
		(p_del_rows         => l_del_rows,
                 p_action_flag      => l_sc_action_flag,
                 p_intransit_flag   => l_sc_intransit_flag,
                 p_close_flag       => l_sc_close_trip_flag,
		 p_stage_del_flag   => l_sc_stage_del_flag,
		 p_actual_dep_date  => l_sc_actual_dep_date,
                 p_report_set_id    => l_sc_report_set_id,
                 p_ship_method      => l_sc_trip_ship_method,
                 p_bol_flag         => l_sc_create_bol_flag,
                 p_mc_bol_flag      => l_sc_create_bol_flag,
		 p_defer_interface_flag =>	l_defer_interface_flag,
		 p_send_945_flag	=> 'N',
                 p_autocreate_trip_flag	=> l_autocreate_trip_flag,
                 x_return_status    => l_return_status,
                 p_caller                => 'WSH_IB');

		wsh_util_core.get_messages('Y', l_msg_data, l_msg_details, l_msg_count);
               IF l_debug_on THEN
		wsh_debug_sv.log (l_module_name, 'Return status from ship confirm', l_return_status);
		wsh_debug_sv.log (l_module_name, 'Ship confirm message count',l_msg_count);
		wsh_debug_sv.log (l_module_name, 'Ship confirm messages', l_msg_data);
		wsh_debug_sv.log (l_module_name, 'Ship confirm message details', l_msg_details);
               END IF;

		IF(l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
		   IF(l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
			-- If Ship confirm completes with warning and if the global variable is set to 'E'
			-- Then need to raise the exception
			-- Otherwise, i.e if the global variable is not 'E' then it means the warning
			-- can be ignored and hence no need to raise the exception
               IF l_debug_on THEN
		wsh_debug_sv.log (l_module_name, 'Ship confirm global variable', WSH_NEW_DELIVERY_ACTIONS.g_error_level);
               END IF;
			IF(nvl(WSH_NEW_DELIVERY_ACTIONS.g_error_level, '!') = 'E') THEN
				-- Reset the global variable to null
				-- And then raise the exception
				WSH_NEW_DELIVERY_ACTIONS.g_error_level := NULL;
				raise ship_confirm_failed;
			END IF;
		  ELSE
			-- If return status is not warning and not success, then it is
			-- either error or unexpected error. Hence raise exception.
			raise ship_confirm_failed;
		  END IF;
		END IF;
	EXCEPTION
		WHEN ship_confirm_failed THEN
		RAISE ship_confirm_failed;
		WHEN others THEN
		RAISE others_ship_confirm;
	END;


       IF l_debug_on THEN
	wsh_debug_sv.pop(l_module_name);
       END IF;

EXCEPTION
WHEN invalid_input THEN
	x_return_status	:= WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'invalid_input exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:invalid_input');
        END IF;
WHEN validate_delivery_failed THEN
	FND_MESSAGE.SET_NAME('WSH','WSH_VALIDATE_DLVY_ERROR');
	FND_MESSAGE.SET_TOKEN('DLVY', l_delivery_id);
	x_return_status	:= WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'validate_delivery_failed exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:validate_delivery_failed');
        END IF;
WHEN process_delivery_failed THEN
	x_return_status	:= WSH_UTIL_CORE.G_RET_STS_ERROR;
	ROLLBACK TO before_update_dlvy_det;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'process_delivery_failed exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:process_delivery_failed');
        END IF;
WHEN create_update_trip_failed THEN
	FND_MESSAGE.SET_NAME('WSH', 'WSH_TRIP_PROCESS_ERROR');
	FND_MESSAGE.SET_TOKEN('DLVY',l_delivery_id);
	ROLLBACK TO before_update_dlvy_det;
	x_return_status	:= WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'create_update_trip_failed exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:create_update_trip_failed');
        END IF;
WHEN ship_confirm_failed THEN
	FND_MESSAGE.SET_NAME('WSH','WSH_TXN_SHIP_CONFIRM_ERROR');
	FND_MESSAGE.SET_TOKEN('DLVY',l_delivery_id);
	ROLLBACK TO before_ship_confirm;
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'ship_confirm_failed exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:ship_confirm_failed');
        END IF;
WHEN update_dlvy_status_failed THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	ROLLBACK TO before_update_dlvy_det;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'update_dlvy_status_failed exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:update_dlvy_status_failed');
        END IF;
WHEN get_warehouse_type_failed THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'get_warehouse_type_failed exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:get_warehouse_type_failed');
        END IF;
WHEN others_update_dlvy_det THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	ROLLBACK TO before_update_dlvy_det;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'others_update_dlvy_det exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:others_update_dlvy_det');
        END IF;
WHEN others_create_update_trip THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	ROLLBACK TO before_update_dlvy_det;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'others_create_update_trip exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:others_create_update_trip');
        END IF;
WHEN others_ship_confirm THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	ROLLBACK TO before_ship_confirm;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'others_ship_confirm exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:others_ship_confirm');
        END IF;
WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;

END Process_Ship_Advice;


END WSH_INBOUND_SHIP_ADVICE_PKG;

/
