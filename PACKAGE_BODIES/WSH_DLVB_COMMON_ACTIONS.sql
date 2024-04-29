--------------------------------------------------------
--  DDL for Package Body WSH_DLVB_COMMON_ACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_DLVB_COMMON_ACTIONS" as
/* $Header: WSHDDCMB.pls 120.1.12010000.2 2009/05/18 13:17:53 selsubra ship $ */


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Assign_Details
   PARAMETERS : p_detail_tab - table of ids for assigning; could be delivery
		lines or containers
		p_parent_detail_id -  parent delivery detail id that details
		need to be assigned to
		p_delivery_id - delivery_id for assignment of details
		x_pack_status - status of container after assignment - whether
		underpacked, overpacked or success.
		x_return_status - return status of API
  DESCRIPTION : This procedure takes as input a table of delivery details -
		both lines and containers and creates an assignment to a parent
		detail (container) and/or a delivery.  The API loops through
		all input ids and creates the assignment by calling the
		appropriate delivery detail or container API. This API serves
		as the wrapper API to handle a multi-selection of both lines
		and containers.

------------------------------------------------------------------------------
*/


--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_DLVB_COMMON_ACTIONS';
--
PROCEDURE Assign_Details (
		p_detail_tab IN WSH_UTIL_CORE.id_tab_type,
		p_parent_detail_id IN NUMBER,
		p_delivery_id IN NUMBER,
                p_group_api_flag IN VARCHAR2 DEFAULT NULL,
		x_pack_status OUT NOCOPY  VARCHAR2,
		x_return_status OUT NOCOPY  VARCHAR2) IS

 l_cont_tab WSH_UTIL_CORE.id_tab_type;
 l_detail_tab WSH_UTIL_CORE.id_tab_type;
 l_error_tab WSH_UTIL_CORE.id_tab_type;

 l_det_rec	WSH_UTIL_CORE.ID_TAB_TYPE;

 l_return_status VARCHAR2(1) := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

 l_cont_name VARCHAR2(30);

 l_pack_status VARCHAR2(30);

 l_wms_filter_flag VARCHAR2(1) := 'N';

 l_entity_ids   WSH_UTIL_CORE.id_tab_type;
 --
 l_has_lines VARCHAR2(1) := 'N';
 l_dlvy_freight_terms_code VARCHAR2(30);
 l_fill_status  VARCHAR2(1);

l_num_warnings          number := 0;


cursor c_child_details(p_detail_id in number) is
select delivery_id
from wsh_delivery_assignments_v da
where da.delivery_detail_id = p_detail_id;

cursor c_delivery_org(p_delivery_id in number) is
select organization_id
from wsh_new_deliveries
where delivery_id = p_delivery_id;

l_delivery_id NUMBER;
l_organization_id NUMBER;
l_wms_org VARCHAR2(10);
-- K LPN CONV. rv
l_lpn_in_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_in_rec_type;
l_lpn_out_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_out_rec_type;
l_msg_count NUMBER;
l_msg_data  VARCHAR2(32767);
e_return_excp EXCEPTION;
-- K LPN CONV. rv



--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ASSIGN_DETAILS';
--
BEGIN
    -- bug 1678527: check for packing in WMS orgs
    --
    -- Debug Statements
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
        WSH_DEBUG_SV.log(l_module_name,'P_DETAIL_TAB.COUNT',P_DETAIL_TAB.COUNT);
        WSH_DEBUG_SV.log(l_module_name,'P_PARENT_DETAIL_ID',P_PARENT_DETAIL_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_GROUP_API_FLAG',P_GROUP_API_FLAG);
    END IF;
    --
    IF (p_parent_detail_id IS NOT NULL) AND (NVL(p_group_api_flag, 'N') = 'N') THEN
      l_wms_filter_flag := 'Y';
    ELSE
      l_wms_filter_flag := 'N';
    END IF;

    OPEN c_delivery_org(p_delivery_id);
    FETCH c_delivery_org
    INTO l_organization_id;
    CLOSE c_delivery_org;

    l_wms_org := WSH_UTIL_VALIDATE.check_wms_org(l_organization_id);
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DLVB_COMMON_ACTIONS.SEPARATE_DETAILS',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    WSH_DLVB_COMMON_ACTIONS.Separate_Details (
		 p_input_tab 		=>p_detail_tab,
	         x_cont_inst_tab	=>l_cont_tab,
	         x_detail_tab  		=>l_detail_tab,
		 x_error_tab 		=>l_error_tab,
		 x_return_status	=>x_return_status,
                 p_wms_filter_flag	=>l_wms_filter_flag);


    IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      IF l_wms_filter_flag = 'Y' THEN
	FND_MESSAGE.SET_NAME('WSH','WSH_SEPARATE_DET_ERROR');
	WSH_UTIL_CORE.Add_Message(x_return_status);
      END IF;
      --
      -- Debug Statements
      --
      --IF l_debug_on THEN
          --WSH_DEBUG_SV.pop(l_module_name);
      --END IF;
      --
      --return; LPN CONV. rv
      raise e_return_excp; -- LPN CONV. rv
    END IF;


/* first process all the delivery line records */
    IF l_detail_tab.count <> 0 THEN


	IF p_parent_detail_id IS NOT NULL THEN

	    --
	    -- Debug Statements
	    --
	    IF l_debug_on THEN
	        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_ACTIONS.ASSIGN_DETAIL',WSH_DEBUG_SV.C_PROC_LEVEL);
	    END IF;
	    --
	    WSH_CONTAINER_ACTIONS.Assign_Detail (
			p_container_instance_id =>p_parent_detail_id,
			p_del_detail_tab 	=>l_detail_tab,
			x_pack_status 		=>l_pack_status,
			x_return_status 	=>l_return_status);

	    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
               IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                  l_num_warnings := l_num_warnings + 1;
               ELSE
		  --
		  -- Debug Statements
		  --
		  IF l_debug_on THEN
		     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
		  END IF;
		  --
		  l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(p_parent_detail_id);
		  FND_MESSAGE.SET_NAME('WSH','WSH_CONT_DET_ASSG_ERROR');
		  x_return_status := l_return_status;
		  WSH_UTIL_CORE.Add_Message(l_return_status);
		  --
		  -- Debug Statements
		  --
		  --IF l_debug_on THEN
		     --WSH_DEBUG_SV.pop(l_module_name);
		  --END IF;
		  --
		  --return;
                  raise e_return_excp; -- LPN CONV. rv
	       END IF;
	    END IF;

-- J: W/V Changes

            WSH_WV_UTILS.Check_Fill_Pc (
              p_container_instance_id => p_parent_detail_id,
              x_fill_status           => l_fill_status,
              x_return_status         => l_return_status);

            IF l_fill_status = 'O' THEN

                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(p_parent_detail_id);
                FND_MESSAGE.SET_NAME('WSH','WSH_CONT_OVERPACKED');
                FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
                l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
		l_num_warnings := l_num_warnings + 1; --Bug 8259359
                WSH_UTIL_CORE.Add_Message(l_return_status);
                x_pack_status := 'Overpacked';

            ELSIF l_fill_status = 'U' THEN
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(p_parent_detail_id);
                FND_MESSAGE.SET_NAME('WSH','WSH_CONT_UNDERPACKED');
                FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
                l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
		l_num_warnings := l_num_warnings + 1; --Bug 8259359
                WSH_UTIL_CORE.Add_Message(l_return_status);
                x_pack_status := 'Underpacked';
            ELSE
                x_pack_status := 'Success';
            END IF;

	END IF;

	IF p_delivery_id IS NOT NULL THEN

	    FOR i IN 1..l_detail_tab.count LOOP
		l_det_rec(i) := l_detail_tab(i);
	    END LOOP;

	    --
	    -- Debug Statements
	    --
	    IF l_debug_on THEN
	        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.ASSIGN_MULTIPLE_DETAILS',WSH_DEBUG_SV.C_PROC_LEVEL);
	    END IF;
	    --
	    WSH_DELIVERY_DETAILS_ACTIONS.Assign_Multiple_Details (
					p_rec_of_detail_ids	=>l_det_rec,
					p_delivery_id		=>p_delivery_id,
					p_cont_ins_id		=>NULL,
					x_return_status		=>l_return_status);

	    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
               IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                  l_num_warnings := l_num_warnings + 1;
               ELSE
		  FND_MESSAGE.SET_NAME('WSH','WSH_DETAILS_ASSG_ERROR');
		  x_return_status := l_return_status;
		  WSH_UTIL_CORE.Add_Message(l_return_status);
		  --
		  -- Debug Statements
		  --
		  --IF l_debug_on THEN
		     --WSH_DEBUG_SV.pop(l_module_name);
		  --END IF;
		  --
		  --return;
                  raise e_return_excp; -- LPN CONV. rv
	       END IF;
	    END IF;

         END IF;

    END IF;


/* process all the container records */

    IF l_cont_tab.count <> 0 THEN

	IF p_delivery_id IS NOT NULL -- J-IB-NPARIKH
	THEN
	--{
	    l_has_lines
	    := WSH_DELIVERY_VALIDATIONS.has_lines(p_delivery_id);
	--}
	END IF;
	--
	FOR i IN 1..l_cont_tab.count LOOP


	    IF p_parent_detail_id IS NOT NULL THEN

	    	--
	    	-- Debug Statements
	    	--
	    	IF l_debug_on THEN
	    	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_ACTIONS.ASSIGN_TO_CONTAINER',WSH_DEBUG_SV.C_PROC_LEVEL);
	    	END IF;
	    	--
	    	WSH_CONTAINER_ACTIONS.Assign_To_Container (
				p_det_cont_inst_id =>l_cont_tab(i),
				p_par_cont_inst_id =>p_parent_detail_id,
				x_return_status    =>l_return_status);

	        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                   IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                      l_num_warnings := l_num_warnings + 1;
                   ELSE
		      FND_MESSAGE.SET_NAME('WSH','WSH_CONT_ASSG_ERROR');
		      x_return_status := l_return_status;
		      WSH_UTIL_CORE.Add_Message(l_return_status);
		      --
		      -- Debug Statements
		      --
		      --IF l_debug_on THEN
		         --WSH_DEBUG_SV.pop(l_module_name);
		      --END IF;
		      --
		      --return;
                      raise e_return_excp; -- LPN CONV. rv
	    	   END IF;
	    	END IF;

	    END IF;


	    IF p_delivery_id IS NOT NULL THEN

              l_delivery_id := NULL;

              IF (l_wms_org  = 'Y') THEN

                OPEN c_child_details(l_cont_tab(i));
                FETCH c_child_details
                INTO  l_delivery_id;
                CLOSE c_child_details;

              END IF;

              IF (l_delivery_id IS NULL) THEN

	      	--
	      	-- Debug Statements
	      	--
	      	--
	      	WSH_CONTAINER_ACTIONS.Assign_To_Delivery (
					p_container_instance_id	=>l_cont_tab(i),
					p_delivery_id		=>p_delivery_id,
					x_return_status		=>l_return_status,
					x_dlvy_has_lines => l_has_lines,
					x_dlvy_freight_terms_code => l_dlvy_freight_terms_code
					);

	       	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                   IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                      l_num_warnings := l_num_warnings + 1;
                   ELSE
		      FND_MESSAGE.SET_NAME('WSH','WSH_CONT_ASSG_ERROR');
		      x_return_status := l_return_status;
		      WSH_UTIL_CORE.Add_Message(l_return_status);
		      --
		      -- Debug Statements
		      --
		      --IF l_debug_on THEN
		         --WSH_DEBUG_SV.pop(l_module_name);
		      --END IF;
		      --
		      --return;
                      raise e_return_excp; -- LPN CONV. rv
	           END IF;
	        END IF;

              END IF;

            END IF;

	END LOOP;

    END IF;


    /* H projects: pricing integration csun
       if the code reaches here, the status is either success or warning */
    IF p_parent_detail_id is NOT NULL THEN
       l_entity_ids.delete;
       l_entity_ids(1) := p_parent_detail_id;

       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_LEGS_ACTIONS.MARK_REPRICE_REQUIRED',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       --
       WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required(
    		       p_entity_type => 'DELIVERY_DETAIL',
    		       p_entity_ids   => l_entity_ids,
    		       x_return_status => l_return_status);
    		    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
    			FND_MESSAGE.SET_NAME('WSH','WSH_REPRICE_REQUIRED_ERR');
    			WSH_UTIL_CORE.Add_Message(l_return_status);
    		    END IF;

    END IF;
    IF p_delivery_id is NOT NULL THEN
       l_entity_ids.delete;
       l_entity_ids(1) := p_delivery_id;
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_LEGS_ACTIONS.MARK_REPRICE_REQUIRED',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       --
       WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required(
    		p_entity_type => 'DELIVERY',
    		p_entity_ids   => l_entity_ids,
    		x_return_status => l_return_status);
       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
    	  FND_MESSAGE.SET_NAME('WSH','WSH_REPRICE_REQUIRED_ERR');
    	  WSH_UTIL_CORE.Add_Message(l_return_status);
       END IF;
    END IF;

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	x_pack_status := 'Warning';
    	x_return_status := l_return_status;
	--
	-- Debug Statements
	--
	--IF l_debug_on THEN
	    --WSH_DEBUG_SV.pop(l_module_name);
	--END IF;
	--
	--return;
        raise e_return_excp; -- LPN CONV. rv
    ELSE
       IF l_num_warnings > 0 THEN
          x_pack_status := 'Warning';
          x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
       ELSE
    	  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	  x_pack_status := 'Success';
       END IF;
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Return Status',x_return_status);
          --WSH_DEBUG_SV.pop(l_module_name);
       END IF;
       --
       --return;
    END IF;

    --
    -- K LPN CONV. rv
    --
    IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
    THEN
    --{

        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
          (
            p_in_rec             => l_lpn_in_sync_comm_rec,
            x_return_status      => l_return_status,
            x_out_rec            => l_lpn_out_sync_comm_rec
          );
        --
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
        END IF;
    --}
    END IF;
    --
    --
    IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
        x_pack_status := 'Warning';
        x_return_status := l_return_status;
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        return;
    ELSE
       IF l_num_warnings > 0
       OR l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
          x_pack_status := 'Warning';
          x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
       ELSE
          x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
          x_pack_status := 'Success';
       END IF;
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Return Status',x_return_status);
          WSH_DEBUG_SV.pop(l_module_name);
       END IF;
       --
       return;
       --
    END IF;
    --
    -- K LPN CONV. rv
    --
    x_pack_status := 'Success';
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION

  WHEN e_return_excp THEN
          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
              IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR,WSH_UTIL_CORE.G_RET_STS_ERROR) and x_return_status <> WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
              END IF;
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --
          IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:E_RETURN_EXCP');
          END IF;
          --
  WHEN Others THEN
	WSH_UTIL_CORE.Default_Handler('WSH_DLVB_COMMON_ACTIONS.Assign_Details');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
END IF;
          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Assign_Details;


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Unassign_Details
   PARAMETERS : p_detail_tab - table of ids for unassigning; could be delivery
		lines or containers
		p_parent_detail_flag -  'Y' or 'N' to indicate whether to
		unassign from parent delivery detail id
		p_delivery_flag - 'Y' or 'N' to indicate whether to unassign
		from delivery
		x_return_status - return status of API
  DESCRIPTION : This procedure takes as input a table of delivery details -
		both lines and containers and unassigns the details from either
		containers or deliveries or both.  The API loops through
		all input ids and unassigns the details based on the two input
		flags. If the flags are set to 'Y' then the unassigning is
		done from that entity. If both the flags are set to 'N' then
		detail is unassigned from both the container and the delivery.
		The container and delivery weight volumes are re-calculated
		after the unassigning.

------------------------------------------------------------------------------
*/


PROCEDURE Unassign_Details (
		p_detail_tab IN WSH_UTIL_CORE.id_tab_type,
		p_parent_detail_flag IN VARCHAR2,
		p_delivery_flag IN VARCHAR2,
                p_group_api_flag IN VARCHAR2 DEFAULT NULL,
		x_return_status OUT NOCOPY  VARCHAR2,
        p_action_prms  IN wsh_glbl_var_strct_grp.dd_action_parameters_rec_type   -- J-IB-NPARIKH
       ) IS


 CURSOR Get_Min_Fill(v_cont_id NUMBER) IS
 SELECT nvl(minimum_fill_percent,0)
 FROM WSH_DELIVERY_DETAILS
 WHERE delivery_detail_id = v_cont_id
 AND container_flag = 'Y';


 l_cont_tab WSH_UTIL_CORE.id_tab_type;
 l_detail_tab WSH_UTIL_CORE.id_tab_type;
 l_error_tab WSH_UTIL_CORE.id_tab_type;

 l_det_rec	WSH_UTIL_CORE.ID_TAB_TYPE;

 l_gross NUMBER;
 l_net NUMBER;
 l_volume NUMBER;
 l_fill NUMBER;
 l_return_status VARCHAR2(1) := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

 l_min_fill NUMBER;

 l_pack_status VARCHAR2(30);
 l_wms_filter_flag    VARCHAR2(1);

l_num_warnings          number := 0;
-- K LPN CONV. rv
l_lpn_in_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_in_rec_type;
l_lpn_out_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_out_rec_type;
l_msg_count NUMBER;
l_msg_data  VARCHAR2(32767);
e_return_excp EXCEPTION;
-- K LPN CONV. rv

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UNASSIGN_DETAILS';
--
BEGIN

    -- bug 1678527: check for unpacking in WMS orgs
    --
    -- Debug Statements
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
        WSH_DEBUG_SV.log(l_module_name,'P_DETAIL_TAB.COUNT',p_detail_tab.count);
        WSH_DEBUG_SV.log(l_module_name,'P_PARENT_DETAIL_FLAG',P_PARENT_DETAIL_FLAG);
        WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_FLAG',P_DELIVERY_FLAG);
        WSH_DEBUG_SV.log(l_module_name,'P_GROUP_API_FLAG',P_GROUP_API_FLAG);
    END IF;
    --
    IF (p_parent_detail_flag = 'Y') AND (NVL(p_group_api_flag, 'N') = 'N') THEN
      l_wms_filter_flag := 'Y';
    ELSE
      l_wms_filter_flag := 'N';
    END IF;

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DLVB_COMMON_ACTIONS.SEPARATE_DETAILS',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    WSH_DLVB_COMMON_ACTIONS.Separate_Details (
				p_detail_tab,
				l_cont_tab,
				l_detail_tab,
				l_error_tab,
				x_return_status,
                                l_wms_filter_flag);

    IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      IF l_wms_filter_flag = 'Y' THEN
	FND_MESSAGE.SET_NAME('WSH','WSH_SEPARATE_DET_ERROR');
	WSH_UTIL_CORE.Add_Message(x_return_status);
      END IF;
      --
      -- Debug Statements
      --
      --IF l_debug_on THEN
          --WSH_DEBUG_SV.pop(l_module_name);
      --END IF;
      --
      --return;
      raise e_return_excp; -- LPN CONV. rv
    END IF;

/* first process all the delivery line records */

    IF l_detail_tab.count > 0 THEN

	    --
	    -- Debug Statements
	    --
	    IF l_debug_on THEN
	        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_ACTIONS.UNASSIGN_DETAIL',WSH_DEBUG_SV.C_PROC_LEVEL);
	    END IF;
	    --
	    WSH_CONTAINER_ACTIONS.Unassign_Detail (
					NULL,
					NULL,
					l_detail_tab,
					p_parent_detail_flag,
					p_delivery_flag,
					l_pack_status,
					x_return_status,
                    p_action_prms);   -- J-IB-NPARIKH

/** Bug 1559785 and 1562917 -- warning is not being passed to the form in a
    proper way,so add the part for Warning */
            IF ((x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
                (x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_DETAILS_UNASSG_ERROR');
		l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		WSH_UTIL_CORE.Add_Message(x_return_status);
            ELSE
                IF x_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                   l_num_warnings := l_num_warnings + 1;
                END IF;
                l_return_status := x_return_status;
	    END IF;

    END IF;


/* process all the container records */

    IF l_cont_tab.count > 0 THEN

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_ACTIONS.UNASSIGN_DETAIL',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	WSH_CONTAINER_ACTIONS.Unassign_Detail (
					NULL,
					NULL,
					l_cont_tab,
					p_parent_detail_flag,
					p_delivery_flag,
					l_pack_status,
					x_return_status);

/** Bug 1559785 and 1562917 -- warning is not being passed to the form in a
    proper way,so add the part for Warning */
         IF ((x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
             (x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
	    FND_MESSAGE.SET_NAME('WSH','WSH_CONT_UNASSG_ERROR');
	    l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    WSH_UTIL_CORE.Add_Message(l_return_status);
         ELSE
           IF x_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
              l_num_warnings := l_num_warnings + 1;
           END IF;
           l_return_status := x_return_status;
    	 END IF;

    END IF;


    --
    -- K LPN CONV. rv
    --
    IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
    THEN
    --{
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
          (
            p_in_rec             => l_lpn_in_sync_comm_rec,
            x_return_status      => x_return_status,
            x_out_rec            => l_lpn_out_sync_comm_rec
          );
        --
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',x_return_status);
        END IF;
        --
        --
        IF ((x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
         (x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN

          IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
            l_return_status := x_return_status;
          END IF;

        ELSE
          IF x_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            l_num_warnings := l_num_warnings + 1;
          END IF;
          l_return_status := x_return_status;
        END IF;
        --
        --
    --}
    END IF;
    --
    -- K LPN CONV. rv
    --
/** Bug 1559785 and 1562917 -- warning is not being passed to the form in a
    proper way,so add the part for Warning */
    IF ((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
        (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    ELSE
       IF l_num_warnings > 0 THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
       ELSE
	  x_return_status := l_return_status; -- modified since it can be S or W
       END IF;
    END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
   WSH_DEBUG_SV.log(l_module_name,'Return Status',x_return_status);
   WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
  WHEN e_return_excp THEN
          --
          -- K LPN CONV. rv
          --
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
              IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR,WSH_UTIL_CORE.G_RET_STS_ERROR) and x_return_status <> WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
              END IF;
              --
          --}
          END IF;
          --
          IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:e_return_excp');
          END IF;
          --
          -- K LPN CONV. rv
          --
  WHEN Others THEN
	WSH_UTIL_CORE.Default_Handler('WSH_DLVB_COMMON_ACTIONS.Unassign_Details');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
END IF;
          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --


--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Unassign_Details;


-------------------------------------------------------------------
-- This procedure is only for backward compatibility. No one should call
-- this procedure.
-------------------------------------------------------------------

PROCEDURE Unassign_Details (
        p_detail_tab IN WSH_UTIL_CORE.id_tab_type,
        p_parent_detail_flag IN VARCHAR2,
        p_delivery_flag IN VARCHAR2,
                p_group_api_flag IN VARCHAR2 DEFAULT NULL,
        x_return_status OUT NOCOPY  VARCHAR2) IS




--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UNASSIGN_DETAILS';
--
l_action_prms   wsh_glbl_var_strct_grp.dd_action_parameters_rec_type;  -- J-IB-NPARIKH

BEGIN

    -- bug 1678527: check for unpacking in WMS orgs
    --
    -- Debug Statements
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
        WSH_DEBUG_SV.log(l_module_name,'P_DETAIL_TAB.COUNT',p_detail_tab.count);
        WSH_DEBUG_SV.log(l_module_name,'P_PARENT_DETAIL_FLAG',P_PARENT_DETAIL_FLAG);
        WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_FLAG',P_DELIVERY_FLAG);
        WSH_DEBUG_SV.log(l_module_name,'P_GROUP_API_FLAG',P_GROUP_API_FLAG);
    END IF;
    --
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DLVB_COMMON_ACTIONS.UNASSIGN_DETAILS',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    Unassign_Details (
                p_detail_tab,
                p_parent_detail_flag,
                p_delivery_flag,
                p_group_api_flag,
                x_return_status,
                l_action_prms);
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
EXCEPTION

  WHEN Others THEN
    WSH_UTIL_CORE.Default_Handler('WSH_DLVB_COMMON_ACTIONS.Unassign_Details',l_module_name);
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
END Unassign_Details;

/*
-----------------------------------------------------------------------------
   PROCEDURE  : Auto_Pack_Lines
   PARAMETERS :	p_group_id_tab - table of group ids if the grouping for the
		lines are already known.
		p_detail_tab - table of ids for assigning; could be delivery
		lines or containers
		p_pack_cont_flag - 'Y' or 'N' to determine whether to autopack
		detail containers into master containers while autopacking
		x_cont_inst_tab - table of delivery detail ids (containers)
		that were created due to the autopack.
		x_return_status - return status of API
  DESCRIPTION : This procedure takes as input a table of delivery details -
		both lines and containers and eliminates all container ids and
		with the remaining delivery lines, it calls the auto pack API
		in the container actions package. This API serves as the
		wrapper API to handle a multi-selection of both lines and
		containers.

------------------------------------------------------------------------------
*/


PROCEDURE Auto_Pack_Lines (
		p_group_id_tab IN WSH_UTIL_CORE.id_tab_type,
		p_detail_tab IN WSH_UTIL_CORE.id_tab_type,
		p_pack_cont_flag IN VARCHAR2,
                p_group_api_flag IN VARCHAR2 DEFAULT NULL,
		x_cont_inst_tab OUT NOCOPY  WSH_UTIL_CORE.id_tab_type,
		x_return_status OUT NOCOPY  VARCHAR2) IS


 l_cont_tab WSH_UTIL_CORE.id_tab_type;
 l_detail_tab WSH_UTIL_CORE.id_tab_type;
 l_error_tab WSH_UTIL_CORE.id_tab_type;

 l_ret_sts VARCHAR2(1) := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

 l_cont_name VARCHAR2(30);

 l_cont_info_tab WSH_CONTAINER_ACTIONS.empty_cont_info_tab;

 l_cont_inst_tab WSH_UTIL_CORE.id_tab_type;

 i NUMBER;
 cont_cnt NUMBER;
 l_wms_filter_flag VARCHAR2(1);

 /* H projects: pricing integration csun */
 l_entity_ids WSH_UTIL_CORE.id_tab_type;
 m NUMBER := 0;
 mark_reprice_error  EXCEPTION;

-- K LPN CONV. rv
l_lpn_in_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_in_rec_type;
l_lpn_out_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_out_rec_type;
l_msg_count NUMBER;
l_msg_data  VARCHAR2(32767);
l_return_status VARCHAR2(10);
l_num_warnings NUMBER := 0;
e_return_excp EXCEPTION;
-- K LPN CONV. rv

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'AUTO_PACK_LINES';
--
BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'P_GROUP_ID_TAB.COUNT',P_GROUP_ID_TAB.COUNT);
    WSH_DEBUG_SV.log(l_module_name,'P_DETAIL_TAB.COUNT',P_DETAIL_TAB.COUNT);
    WSH_DEBUG_SV.log(l_module_name,'P_PACK_CONT_FLAG',P_PACK_CONT_FLAG);
    WSH_DEBUG_SV.log(l_module_name,'P_GROUP_API_FLAG',P_GROUP_API_FLAG);
  END IF;

  l_entity_ids.delete;
  -- bug 1678527: disallow auto-packing in WMS orgs
  IF NVL(p_group_api_flag, 'N') = 'N' THEN
    l_wms_filter_flag := 'Y';
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DLVB_COMMON_ACTIONS.SEPARATE_DETAILS',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
    --
  WSH_DLVB_COMMON_ACTIONS.Separate_Details (
				p_detail_tab,
				l_cont_tab,
				l_detail_tab,
				l_error_tab,
				x_return_status,
                                l_wms_filter_flag);


  IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
    IF l_wms_filter_flag = 'Y' THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_SEPARATE_DET_ERROR');
      WSH_UTIL_CORE.Add_Message(x_return_status);
    END IF;
    --IF l_debug_on THEN
      --WSH_DEBUG_SV.pop(l_module_name);
    --END IF;
    --return;
    raise e_return_excp; -- LPN CONV. rv
  END IF;

  IF (l_error_tab.count > 0) THEN
    l_ret_sts := WSH_UTIL_CORE.G_RET_STS_WARNING;
  END IF;


  IF l_detail_tab.count <= 0 AND l_cont_tab.count <= 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('WSH','WSH_CONT_DET_ASSG_NULL');
    WSH_UTIL_CORE.Add_Message(x_return_status);
    --IF l_debug_on THEN
      --WSH_DEBUG_SV.pop(l_module_name);
    --END IF;
    --return;
    raise e_return_excp; -- LPN CONV. rv
  END IF;

  IF l_detail_tab.count > 0 THEN

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_ACTIONS.AUTO_PACK_LINES',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;

    WSH_CONTAINER_ACTIONS.Auto_Pack_Lines (
				p_group_id_tab,
				l_detail_tab,
				p_pack_cont_flag,
				l_cont_inst_tab,
				x_return_status);

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'RETURN_STATUS'||x_return_status);
    END IF;
    IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
-- Bug 2847515
      l_ret_sts := x_return_status;
    END IF;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'After Detail Tab');
    WSH_DEBUG_SV.logmsg(l_module_name,'X_RETURN_STATUS'||x_return_status);
    WSH_DEBUG_SV.logmsg(l_module_name,'L_RETURN_STATUS'||l_ret_sts);
  END IF;

  FOR i IN 1..l_cont_inst_tab.count LOOP
    x_cont_inst_tab(i) := l_cont_inst_tab(i);
    /* H projecst : pricing integration csun */
    m := m+1;
    l_entity_ids(m) := l_cont_inst_tab(i);

  END LOOP;

  l_cont_inst_tab.delete;

  IF l_cont_tab.count > 0 THEN

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_ACTIONS.AUTO_PACK_CONTS',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    WSH_CONTAINER_ACTIONS.Auto_Pack_Conts (
				p_group_id_tab,
				l_cont_info_tab,
				l_cont_tab,
				l_cont_inst_tab,
				x_return_status);

    IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
--      Bug 3562797 jckwok
--      Set l_ret_sts to return status of Auto_Pack_Conts.  Similar issue
--      (Bug 2847515) was already fixed
--      after call to WSH_CONTAINER_ACTIONS.Auto_Pack_Lines but
--      neglected for WSH_CONTAINER_ACTIONS.Auto_Pack_Conts
         l_ret_sts := x_return_status;
   END IF;
  END IF;

  cont_cnt := x_cont_inst_tab.count;
  i := 1;

  FOR i IN 1..l_cont_inst_tab.count LOOP
    cont_cnt := cont_cnt + 1;
    x_cont_inst_tab(cont_cnt) := l_cont_inst_tab(i);
    /* H projecst : pricing integration csun */
    m := m+1;
    l_entity_ids(m) := l_cont_inst_tab(i);
  END LOOP;

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'After Container Tab');
    WSH_DEBUG_SV.logmsg(l_module_name,'X_RETURN_STATUS'||x_return_status);
    WSH_DEBUG_SV.logmsg(l_module_name,'L_RETURN_STATUS'||l_ret_sts);
  END IF;

  IF (l_ret_sts <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
-- Bug 2847515
    x_return_status := l_ret_sts;
    FND_MESSAGE.SET_NAME('WSH','WSH_SUM_AUTOPACK_ERROR');
    WSH_UTIL_CORE.Add_Message(x_return_status);
    IF (l_ret_sts = WSH_UTIL_CORE.G_RET_STS_ERROR) THEN --Bug 3562797 jckwok
       --IF l_debug_on THEN
         --WSH_DEBUG_SV.pop(l_module_name);
       --END IF;
       --return;
       raise e_return_excp; -- LPN CONV. rv
    END IF;
  END IF;
    /* H projecst : pricing integration csun */
  IF l_entity_ids.count > 0 THEN
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_LEGS_ACTIONS.MARK_REPRICE_REQUIRED',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required(
     		       p_entity_type => 'DELIVERY_DETAIL',
     		       p_entity_ids   => l_entity_ids,
     		       x_return_status => l_ret_sts);
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'After Mark_Reprice_Required L_RETURN_STATUS:'||l_ret_sts);
    END IF;
    IF l_ret_sts <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      raise mark_reprice_error;
    END IF;
  END IF;
--  Bug 3562797 jckwok
--  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  --
  -- K LPN CONV. rv
  --
  IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
  THEN
  --{

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
        (
          p_in_rec             => l_lpn_in_sync_comm_rec,
          x_return_status      => l_return_status,
          x_out_rec            => l_lpn_out_sync_comm_rec
        );
      --
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
      END IF;
      --
      --
      IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
        --
        x_return_status := l_return_status;
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_WMS_SYNC_TMP_PKG.MERGE completed with an error');
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        RETURN;
      ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
        l_num_warnings := l_num_warnings + 1;
      END IF;
      --
  --}
  END IF;
  --
  -- K LPN CONV. rv
  --

  IF (l_num_warnings > 0 AND x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    --
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'X_RETURN_STATUS:'||x_return_status);
    WSH_DEBUG_SV.log(l_module_name,'X_CONT_INST_TAB.COUNT',X_CONT_INST_TAB.COUNT);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION

 WHEN e_return_excp THEN
          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
              IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR,WSH_UTIL_CORE.G_RET_STS_ERROR) and x_return_status <> WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
              END IF;
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'E_RETURN_EXCP exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:E_RETURN_EXCP');
          END IF;
          --
          --
 WHEN mark_reprice_error THEN
      FND_MESSAGE.Set_Name('WSH', 'WSH_REPRICE_REQUIRED_ERR');
      WSH_UTIL_CORE.add_message (x_return_status);
      x_return_status := l_ret_sts;

          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
              IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
              END IF;
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'MARK_REPRICE_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:MARK_REPRICE_ERROR');
END IF;
--
  WHEN Others THEN
	WSH_UTIL_CORE.Default_Handler('WSH_DLVB_COMMON_ACTIONS.Auto_Pack_Lines');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
END IF;
          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --


--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Auto_Pack_Lines;


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Separate_Details
   PARAMETERS :	p_input_tab - table of ids in input; could be delivery
		lines or containers
		x_cont_inst_tab - table of delivery detail ids that are
		containers
		x_detail_tab - table of delivery_details that are lines.
		x_error_tab - table of any ids that are erroneous
		x_return_status - return status of API
		p_wms_filter_flag - Y = do not include records in WMS orgs.
				    N = include all records.
				    Default = N
				    Bug 1678527: disable packing actions
				 	for delivery details in WMS orgs.
  DESCRIPTION : This procedure takes as input a table of delivery details -
		both lines and containers and separates all container ids and
		delivery lines. It returns three tables - one for containers,
		one for delivery lines and one for any erroroneous ids.

------------------------------------------------------------------------------
*/


PROCEDURE Separate_Details (
		p_input_tab IN WSH_UTIL_CORE.id_tab_type,
		x_cont_inst_tab OUT NOCOPY  WSH_UTIL_CORE.id_tab_type,
		x_detail_tab OUT NOCOPY  WSH_UTIL_CORE.id_tab_type,
		x_error_tab OUT NOCOPY  WSH_UTIL_CORE.id_tab_type,
		x_return_status OUT NOCOPY  VARCHAR2,
		p_wms_filter_flag IN VARCHAR2 DEFAULT 'N') IS

 -- bug 1678527: look up wms enabled flag
 CURSOR Select_Cont_Flag (v_detail_id NUMBER) IS
 SELECT nvl(wdd.container_flag,'N'),
        NVL(mp.wms_enabled_flag, 'N'),
        nvl(line_direction,'O') line_direction   -- J-IB-NPARIKH
 FROM WSH_DELIVERY_DETAILS wdd,
      MTL_PARAMETERS       mp
 WHERE wdd.delivery_detail_id = v_detail_id
 AND   mp.organization_id(+) = wdd.organization_id;

 l_cont_flag VARCHAR2(1);
 l_wms_enabled  VARCHAR2(1);
 l_line_direction   VARCHAR2(30);
 det_cnt NUMBER := 0;
 cont_cnt NUMBER := 0;
 err_cnt NUMBER := 0;
 wms_cnt NUMBER := 0;

 l_ret_sts VARCHAR2(1) := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SEPARATE_DETAILS';
--
BEGIN

 --
 -- Debug Statements
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
     WSH_DEBUG_SV.log(l_module_name,'P_INPUT_TAB.COUNT',P_INPUT_TAB.COUNT);
     WSH_DEBUG_SV.log(l_module_name,'P_WMS_FILTER_FLAG',P_WMS_FILTER_FLAG);
 END IF;
 --
 IF p_input_tab.count <> 0 THEN

   FOR i IN 1..p_input_tab.count LOOP

	OPEN Select_Cont_Flag (p_input_tab(i));
 FETCH Select_Cont_Flag INTO l_cont_flag, l_wms_enabled,l_line_direction;

	IF Select_Cont_Flag%NOTFOUND THEN
		err_cnt := err_cnt + 1;
		x_error_tab(err_cnt) := p_input_tab(i);
		CLOSE Select_Cont_Flag;
		l_ret_sts := WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;

	IF Select_Cont_Flag%ISOPEN THEN
	   CLOSE Select_Cont_Flag;
	END IF;

        IF     p_wms_filter_flag = 'Y'
           AND l_wms_enabled = 'Y'
        AND l_line_direction IN ('O','IO')
        THEN
          -- bug 1678527: do not add WMS controlled records to lists.
          wms_cnt := wms_cnt + 1;
        ELSE

  	  IF l_cont_flag = 'N' THEN
	     det_cnt := det_cnt + 1;
	     x_detail_tab(det_cnt) := p_input_tab(i);
	  END IF;

	  IF l_cont_flag = 'Y' THEN
	     cont_cnt := cont_cnt + 1;
	     x_cont_inst_tab(cont_cnt) := p_input_tab(i);
	  END IF;

        END IF;

   END LOOP;

   IF wms_cnt > 0 THEN

     IF wms_cnt = p_input_tab.count THEN
       l_ret_sts := WSH_UTIL_CORE.G_RET_STS_ERROR;
       FND_MESSAGE.SET_NAME('WSH', 'WSH_WMS_PACK_NOT_ALLOWED');
       WSH_UTIL_CORE.Add_message(l_ret_sts);
     ELSE
       FND_MESSAGE.SET_NAME('WSH', 'WSH_WMS_RECORDS_NOT_PACKED');
       FND_MESSAGE.SET_TOKEN('COUNT', wms_cnt);
       WSH_UTIL_CORE.Add_message(l_ret_sts);
     END IF;

   END IF;

 ELSE
    l_ret_sts := WSH_UTIL_CORE.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('WSH','WSH_INPUT_TABLE_NULL');
    WSH_UTIL_CORE.Add_Message(l_ret_sts);
 END IF;

 x_return_status := l_ret_sts;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'X_DETAIL_TAB.COUNT',X_DETAIL_TAB.COUNT);
    WSH_DEBUG_SV.log(l_module_name,'X_CONT_INST_TAB.COUNT',X_CONT_INST_TAB.COUNT);
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION

  WHEN Others THEN
	WSH_UTIL_CORE.Default_Handler('WSH_DLVB_COMMON_ACTIONS.Separate_Details');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Separate_Details;



/*
-----------------------------------------------------------------------------
   PROCEDURE  : Calc_Cont_Avail
   PARAMETERS :	p_container_instance_id - delivery detail id of container
		x_avail_wt - available weight capacity of container
		x_avail_vol - available volume capacity of container
		x_wt_uom - weight uom code for above weights
		x_vol_uom - volume uom code for above volumes
		x_return_status - return status of API
  DESCRIPTION : This procedure takes as input a container (delivery detail id)
		and returns the	available weight and volume capacity for the
		container.

------------------------------------------------------------------------------
*/

PROCEDURE Calc_Cont_Avail (
			p_container_instance_id IN NUMBER,
			x_avail_wt OUT NOCOPY  NUMBER,
			x_avail_vol OUT NOCOPY  NUMBER,
			x_wt_uom OUT NOCOPY  VARCHAR2,
			x_vol_uom OUT NOCOPY  VARCHAR2,
			x_return_status OUT NOCOPY  VARCHAR2) IS

 --Bug 3630085 :Select filled_Volume instead of volume

 CURSOR Get_Cont_Info IS
 SELECT inventory_item_id, gross_weight, net_weight, filled_volume,
        maximum_load_weight, maximum_volume,
	weight_uom_code, volume_uom_code, organization_id
 FROM   WSH_DELIVERY_DETAILS
 WHERE  delivery_detail_id = p_container_instance_id
 and    container_flag = 'Y';

 gr_wt NUMBER;
 net_wt NUMBER;
 fill_pc NUMBER;
 fill_vol NUMBER;
 tmp_fil_vol NUMBER;
 wt_uom VARCHAR2(3);
 vol_uom VARCHAR2(3);
 wsh_wt_uom VARCHAR2(3);
 wsh_vol_uom VARCHAR2(3);
 l_ret_sts VARCHAR2(1);
 tmp_gr_wt NUMBER;
 tmp_net_wt NUMBER;
 tmp_vol NUMBER;
 tmp_tare_wt NUMBER;
 tare_wt NUMBER;
 max_load_wt NUMBER;
 tmp_max_load_wt NUMBER;
 tmp_max_vol NUMBER;
 max_vol NUMBER;
 cont_item_id NUMBER;
 cont_org_id NUMBER;
 dummy_vol  NUMBER;
 l_cont_name VARCHAR2(30);
 l_org_name VARCHAR2(240);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CALC_CONT_AVAIL';
--
BEGIN

   --
   -- Debug Statements
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
       WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_INSTANCE_ID',P_CONTAINER_INSTANCE_ID);
   END IF;
   --
   OPEN Get_Cont_Info;

   FETCH Get_Cont_Info INTO
   cont_item_id,
   tmp_gr_wt,
   tmp_net_wt,
   tmp_fil_vol,
   tmp_max_load_wt,
   tmp_max_vol,
   wt_uom,
   vol_uom,
   cont_org_id;

   IF (Get_Cont_Info%NOTFOUND) THEN
     CLOSE Get_Cont_Info;
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(p_container_instance_id);
     FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CONTAINER');
     FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     WSH_UTIL_CORE.Add_Message(x_return_status);
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
     return;
   END IF;

   IF Get_Cont_Info%ISOPEN THEN
	CLOSE Get_Cont_Info;
   END IF;

   IF wt_uom IS NULL OR vol_uom IS NULL THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(p_container_instance_id);
      FND_MESSAGE.SET_NAME('WSH','WSH_CONT_WV_UOM_NULL');
      FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_UTIL_CORE.Add_Message(x_return_status);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return;
   END IF;

   IF (tmp_gr_wt IS NULL) THEN

--	WSH_WV_UTILS.Container_Weight_Volume (
--	replacing with TPA enabled API..
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TPA_CONTAINER_PKG.CONTAINER_WEIGHT_VOLUME',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	--Bug 3630085:OMFST:J:R2:WRONG VALUE OF WEIGHT AND VOLUME IN PACKING WORKBENCH WINDOW
	--x_volume in case of a container represent the total volume of the container
	--Collecting x_volume in a dummy variable

	WSH_TPA_CONTAINER_PKG.Container_Weight_Volume (
          p_container_instance_id  => p_container_instance_id,
          p_override_flag	   => 'N',
          x_gross_weight           => tmp_gr_wt,
          x_net_weight             => tmp_net_wt,
          x_volume		   => dummy_vol,
          p_fill_pc_flag	   => 'Y',
          x_cont_fill_pc	   => fill_pc,
          x_return_status	   => l_ret_sts);

	IF l_ret_sts <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	    	--
	    	-- Debug Statements
	    	--
	    	IF l_debug_on THEN
	    	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	    	END IF;
	    	--
	    	l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(p_container_instance_id);
		FND_MESSAGE.SET_NAME('WSH','WSH_CONT_WT_VOL_FAILED');
		FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
		l_ret_sts := WSH_UTIL_CORE.G_RET_STS_WARNING;
     		WSH_UTIL_CORE.Add_Message(l_ret_sts);
		tmp_gr_wt := 0;
		tmp_net_wt := 0;
		fill_pc := 0;
	END IF;
   END IF;

--   WSH_WV_UTILS.Container_Tare_Weight_Self (
--   replacing with TPA enabled API..

     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TPA_CONTAINER_PKG.CONTAINER_TARE_WEIGHT_SELF',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     WSH_TPA_CONTAINER_PKG.Container_Tare_Weight_Self (
			p_container_instance_id,
			cont_item_id,
			wt_uom,
			cont_org_id,
			tmp_tare_wt,
			l_ret_sts);

   IF l_ret_sts <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(p_container_instance_id);
	FND_MESSAGE.SET_NAME('WSH','WSH_CONT_TARE_SELF_FAIL');
	FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
	l_ret_sts := WSH_UTIL_CORE.G_RET_STS_WARNING;
	WSH_UTIL_CORE.Add_Message(l_ret_sts);
	tmp_tare_wt := 0;
   END IF;

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.GET_DEFAULT_UOMS',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   WSH_WV_UTILS.Get_Default_Uoms (
			cont_org_id,
			wsh_wt_uom,
			wsh_vol_uom,
			l_ret_sts);

   IF l_ret_sts <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_ORG_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	l_org_name := WSH_UTIL_CORE.Get_Org_Name(cont_org_id);
	FND_MESSAGE.SET_NAME('WSH','WSH_DEFAULT_UOM_ERROR');
	FND_MESSAGE.SET_TOKEN('ORG_NAME',l_org_name);
	l_ret_sts := WSH_UTIL_CORE.G_RET_STS_WARNING;
	WSH_UTIL_CORE.Add_Message(l_ret_sts);
	wsh_wt_uom  := wt_uom;
	wsh_vol_uom := vol_uom;
   END IF;

   x_wt_uom  := wsh_wt_uom;
   x_vol_uom := wsh_vol_uom;


   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   gr_wt := WSH_WV_UTILS.Convert_Uom (
			wt_uom,
			wsh_wt_uom,
			tmp_gr_wt,
			cont_item_id);

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   net_wt := WSH_WV_UTILS.Convert_Uom (
			wt_uom,
			wsh_wt_uom,
			tmp_net_wt,
			cont_item_id);

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   max_load_wt := WSH_WV_UTILS.Convert_Uom (
			wt_uom,
			wsh_wt_uom,
			tmp_max_load_wt,
			cont_item_id);


   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   fill_vol := WSH_WV_UTILS.Convert_Uom (
			vol_uom,
			wsh_vol_uom,
			tmp_fil_vol,
			cont_item_id);


   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   max_vol := WSH_WV_UTILS.Convert_Uom (
			vol_uom,
			wsh_vol_uom,
			tmp_max_vol,
			cont_item_id);


   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   tare_wt := WSH_WV_UTILS.Convert_Uom (
			wt_uom,
			wsh_wt_uom,
			tmp_tare_wt,
			cont_item_id);


   x_avail_wt := max_load_wt - nvl(gr_wt,0) + nvl(tare_wt,0);
   x_avail_vol := max_vol - nvl(fill_vol,0);

   IF x_avail_wt < 0 THEN
	x_avail_wt := 0;
   END IF;

   IF x_avail_vol < 0 THEN
	x_avail_vol := 0;
   END IF;

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'X_AVAIL_WT',x_avail_wt);
    WSH_DEBUG_SV.log(l_module_name,'X_AVAIL_VOL',x_avail_vol);
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION

  WHEN Others THEN
	WSH_UTIL_CORE.Default_Handler('WSH_DLVB_COMMON_ACTIONS.Calc_Cont_Avail');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Calc_Cont_Avail;



/*
-----------------------------------------------------------------------------
   PROCEDURE  : Calc_Item_Total
   PARAMETERS :	p_delivery_detail_id - delivery detail id of line
		x_item_wt - weight of line
		x_item_vol - volume of line
		x_wt_uom - weight uom code for above weights
		x_vol_uom - volume uom code for above volumes
		x_return_status - return status of API
  DESCRIPTION : This procedure takes as input a delivery detail id and
		returns the total item weight and volume for the line.

------------------------------------------------------------------------------
*/


PROCEDURE Calc_Item_Total (
			p_delivery_detail_id IN NUMBER,
			x_item_wt OUT NOCOPY  NUMBER,
			x_item_vol OUT NOCOPY  NUMBER,
			x_wt_uom OUT NOCOPY  VARCHAR2,
			x_vol_uom OUT NOCOPY  VARCHAR2,
			x_return_status OUT NOCOPY  VARCHAR2) IS


 CURSOR Get_Detail_Info IS
 SELECT inventory_item_id, net_weight, volume,
	weight_uom_code, volume_uom_code, organization_id
 FROM WSH_DELIVERY_DETAILS
 WHERE delivery_detail_id = p_delivery_detail_id
 AND nvl(container_flag,'N') = 'N';

 net_wt NUMBER;
 vol NUMBER;
 wt_uom VARCHAR2(3);
 vol_uom VARCHAR2(3);
 wsh_wt_uom VARCHAR2(3);
 wsh_vol_uom VARCHAR2(3);
 l_ret_sts VARCHAR2(1);
 tmp_net_wt NUMBER;
 tmp_vol NUMBER;
 det_item_id NUMBER;
 det_org_id NUMBER;

 l_org_name VARCHAR2(240);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CALC_ITEM_TOTAL';
--
BEGIN

   --
   -- Debug Statements
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
       WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_DETAIL_ID',P_DELIVERY_DETAIL_ID);
   END IF;
   --
   OPEN Get_Detail_Info;

   FETCH Get_Detail_Info INTO
   det_item_id,
   tmp_net_wt,
   tmp_vol,
   wt_uom,
   vol_uom,
   det_org_id;

   IF Get_Detail_Info%NOTFOUND THEN
      CLOSE Get_Detail_Info;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('WSH','WSH_DET_INVALID_DETAIL_ID');
      FND_MESSAGE.SET_TOKEN('DETAIL_ID',p_delivery_detail_id);
      WSH_UTIL_CORE.Add_Message(x_return_status);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return;
   END IF;

   IF Get_Detail_Info%ISOPEN THEN
	CLOSE Get_Detail_Info;
   END IF;

   IF wt_uom IS NULL OR vol_uom IS NULL THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_DET_WV_UOM_NULL');
      FND_MESSAGE.SET_TOKEN('DETAIL_ID',p_delivery_detail_id);
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_UTIL_CORE.Add_Message(x_return_status);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return;
   END IF;

   IF (tmp_net_wt IS NULL OR tmp_vol IS NULL) THEN

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.DETAIL_WEIGHT_VOLUME',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	WSH_WV_UTILS.Detail_Weight_Volume (
          p_delivery_detail_id => p_delivery_detail_id,
          p_update_flag        => 'N',
          x_net_weight         => tmp_net_wt,
          x_volume             => tmp_vol,
          x_return_status      => l_ret_sts);

	IF l_ret_sts <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	        FND_MESSAGE.SET_NAME('WSH','WSH_DET_WT_VOL_FAILED');
		FND_MESSAGE.SET_TOKEN('DETAIL_ID',p_delivery_detail_id);
		l_ret_sts := WSH_UTIL_CORE.G_RET_STS_WARNING;
     		WSH_UTIL_CORE.Add_Message(l_ret_sts);
		tmp_net_wt := 0;
		tmp_vol := 0;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.pop(l_module_name);
		END IF;
		--
		return;
	END IF;

   END IF;

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.GET_DEFAULT_UOMS',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   WSH_WV_UTILS.Get_Default_Uoms (
			det_org_id,
			wsh_wt_uom,
			wsh_vol_uom,
			l_ret_sts);

   IF l_ret_sts <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_ORG_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	l_org_name := WSH_UTIL_CORE.Get_Org_Name(det_org_id);
	FND_MESSAGE.SET_NAME('WSH','WSH_DEFAULT_UOM_ERROR');
	FND_MESSAGE.SET_TOKEN('ORG_NAME',l_org_name);
	l_ret_sts := WSH_UTIL_CORE.G_RET_STS_WARNING;
	WSH_UTIL_CORE.Add_Message(l_ret_sts);
	wsh_wt_uom := wt_uom;
	wsh_vol_uom := vol_uom;
	x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
   END IF;

   x_wt_uom := wsh_wt_uom;
   x_vol_uom := wsh_vol_uom;


   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   net_wt := WSH_WV_UTILS.Convert_Uom (
			wt_uom,
			wsh_wt_uom,
			tmp_net_wt,
			det_item_id);

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   vol := WSH_WV_UTILS.Convert_Uom (
			vol_uom,
			wsh_vol_uom,
			tmp_vol,
			det_item_id);



   x_item_wt := nvl(net_wt,0);
   x_item_vol := nvl(vol,0);

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'x_item_wt',x_item_wt);
    WSH_DEBUG_SV.log(l_module_name,'x_item_vol',x_item_vol);
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION

  WHEN Others THEN
	WSH_UTIL_CORE.Default_Handler('WSH_DLVB_COMMON_ACTIONS.Calc_Item_Total');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Calc_Item_Total;



/*
-----------------------------------------------------------------------------
   PROCEDURE  : Calculate_Total_Capacities
   PARAMETERS :	p_detail_input_tab - table of ids in input; could be delivery
		lines or containers
		x_cont_wt_avail - total available weight capacity of all
		containers in the selection of input ids
		x_cont_vol_avail - total available volume capacity of all
		containers in the selection of input ids.
		x_item_wt_total - total weight of all lines in the input
		selection of ids.
		x_item_vol_total - total volume of all lines in the input
		selection of ids.
		x_wt_uom - weight uom code for above weights
		x_vol_uom - volume uom code for above volumes
		x_return_status - return status of API
  DESCRIPTION : This procedure takes as input a table of delivery details -
		both lines and containers and separates all container ids and
		delivery lines. It returns the available container weight and
		volume capacities and total weight and volume of lines.

------------------------------------------------------------------------------
*/


PROCEDURE Calculate_Total_Capacities (
			p_detail_input_tab IN WSH_UTIL_CORE.id_tab_type,
			x_cont_wt_avail OUT NOCOPY  NUMBER,
			x_cont_vol_avail OUT NOCOPY  NUMBER,
			x_item_wt_total OUT NOCOPY  NUMBER,
			x_item_vol_total OUT NOCOPY  NUMBER,
			x_wt_uom OUT NOCOPY  VARCHAR2,
			x_vol_uom OUT NOCOPY  VARCHAR2,
			x_return_status OUT NOCOPY  VARCHAR2) IS


 l_cont_tab WSH_UTIL_CORE.id_tab_type;
 l_detail_tab WSH_UTIL_CORE.id_tab_type;
 l_error_tab WSH_UTIL_CORE.id_tab_type;

 l_avail_wt NUMBER;
 l_avail_vol NUMBER;
 l_item_wt_total NUMBER;
 l_item_vol_total NUMBER;

 l_wt_uom VARCHAR2(3);
 l_vol_uom VARCHAR2(3);

 l_ret_sts VARCHAR2(1) := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

 l_cont_name VARCHAR2(30);

 l_return_status VARCHAR2(1);

 -- K LPN CONV. rv
 l_lpn_in_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_in_rec_type;
 l_lpn_out_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_out_rec_type;
 l_msg_count NUMBER;
 l_msg_data  VARCHAR2(32767);
 e_return_excp EXCEPTION;
 -- K LPN CONV. rv

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CALCULATE_TOTAL_CAPACITIES';
--
BEGIN

  --
  -- Debug Statements
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
      WSH_DEBUG_SV.log(l_module_name,'P_DETAIL_INPUT_TAB.COUNT',p_detail_input_tab.count);
  END IF;
  --
  IF p_detail_input_tab.count <= 0 THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	FND_MESSAGE.SET_NAME('WSH','WSH_INPUT_TABLE_NULL');
	WSH_UTIL_CORE.Add_Message(x_return_status);
	--
	-- Debug Statements
	--
	--IF l_debug_on THEN
	    --WSH_DEBUG_SV.pop(l_module_name);
	--END IF;
	--
	--return;
        raise e_return_excp; -- LPN CONV. rv
  END IF;

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DLVB_COMMON_ACTIONS.SEPARATE_DETAILS',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  WSH_DLVB_COMMON_ACTIONS.Separate_Details (
				p_detail_input_tab,
				l_cont_tab,
				l_detail_tab,
				l_error_tab,
				x_return_status);



  IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	FND_MESSAGE.SET_NAME('WSH','WSH_SEPARATE_DET_ERROR');
	WSH_UTIL_CORE.Add_Message(x_return_status);
	--
	-- Debug Statements
	--
	--IF l_debug_on THEN
	    --WSH_DEBUG_SV.pop(l_module_name);
	--END IF;
	--
	--return;
        raise e_return_excp; -- LPN CONV. rv
  END IF;


  FOR i IN 1..l_cont_tab.count LOOP

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DLVB_COMMON_ACTIONS.CALC_CONT_AVAIL',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	WSH_DLVB_COMMON_ACTIONS.Calc_Cont_Avail (
				l_cont_tab(i),
				l_avail_wt,
				l_avail_vol,
				l_wt_uom,
				l_vol_uom,
				l_return_status);


        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		l_ret_sts := WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;

        x_cont_wt_avail := nvl(x_cont_wt_avail,0) + nvl(l_avail_wt,0);
	x_cont_vol_avail := nvl(x_cont_vol_avail,0) + nvl(l_avail_vol,0);

  END LOOP;

  -- x_item_wt_total := 0;
  -- x_item_vol_total := 0;

  FOR i IN 1..l_detail_tab.count LOOP


	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DLVB_COMMON_ACTIONS.CALC_ITEM_TOTAL',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	WSH_DLVB_COMMON_ACTIONS.Calc_Item_Total (
				l_detail_tab(i),
				l_item_wt_total,
				l_item_vol_total,
				l_wt_uom,
				l_vol_uom,
				l_return_status);



        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		l_ret_sts := WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;

        x_item_wt_total := nvl(x_item_wt_total,0) + nvl(l_item_wt_total,0);
	x_item_vol_total := nvl(x_item_vol_total,0) + nvl(l_item_vol_total,0);

   END LOOP;
   --
   -- K LPN CONV. rv
   --
   IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
   THEN
   --{
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;

       WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
         (
           p_in_rec             => l_lpn_in_sync_comm_rec,
           x_return_status      => l_return_status,
           x_out_rec            => l_lpn_out_sync_comm_rec
         );
       --
       --
       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
       END IF;
       --
       --
       IF l_return_status NOT IN (WSH_UTIL_CORE.G_RET_STS_SUCCESS,WSH_UTIL_CORE.G_RET_STS_WARNING)
       AND x_return_status <> WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
       THEN
          x_return_status := l_return_status;
       END IF;
       --
  --}
  END IF;
  --
  -- K LPN CONV. rv
  --

   x_wt_uom := l_wt_uom;
   x_vol_uom := l_vol_uom;

   IF l_ret_sts <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	FND_MESSAGE.SET_NAME('WSH','WSH_CALC_CAPACITY_WARN');
	WSH_UTIL_CORE.Add_Message(l_ret_sts);
	x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
   ELSE
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'x_item_wt_total',x_item_wt_total);
    WSH_DEBUG_SV.log(l_module_name,'x_item_vol_total',x_item_vol_total);
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
  --
  -- K LPN CONV. rv
  WHEN e_return_excp THEN
          --
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
              IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR,WSH_UTIL_CORE.G_RET_STS_ERROR) and x_return_status <> WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
              END IF;
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --
          IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:E_RETURN_EXCP');
          END IF;
          --
  WHEN Others THEN
	WSH_UTIL_CORE.Default_Handler('WSH_DLVB_COMMON_ACTIONS.Calculate_Total_Capacities');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
END IF;
          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Calculate_Total_Capacities;


END WSH_DLVB_COMMON_ACTIONS;

/
