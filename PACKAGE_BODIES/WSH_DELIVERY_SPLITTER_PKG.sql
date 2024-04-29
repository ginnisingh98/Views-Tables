--------------------------------------------------------
--  DDL for Package Body WSH_DELIVERY_SPLITTER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_DELIVERY_SPLITTER_PKG" as
/* $Header: WSHDESPB.pls 120.4.12010000.2 2008/08/04 12:30:29 suppal ship $ */

  --
  G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_DELIVERY_SPLITTER_PKG';
  --

  --OTM R12
  ---------------------------------------------------------------------
  -- PROCEDURE LOG_DEL_SPLITTER_EXCEPTION
  --
  -- parameters: p_delivery_rec	    record of delivery information containing
  --				    id, gross weight, weight uom,
  --				    pickup loc, org id
  --		 p_content_weight   delivery's content's weight sum
  --		 p_new_delivery_name  new delivery's name
  --             p_exception_message  the exception message to log
  --               this is included for complicated exception message
  --             p_exception_name   name of the exception to log
  --		 x_return_status    return status of the procedure
  --
  -- description: 	This procedure logs the exceptions for delivery splitting.
  --                    The exception messge parameter is checked first.
  --                    If not NULL then it's used, else generate the message
  --                    depend on the exception name.
  -- Prereq:     this procedure will raise unexpected error if delivery or exception
  --             name passed in is NULL, so it's caller's responsibility.  For
  --             DEL_SPLIT and DEL_SPLIT_LARGE, p_exception_message must be provided,
  --             else the procedure will return with unexpected error.
  ---------------------------------------------------------------------
  PROCEDURE LOG_DEL_SPLITTER_EXCEPTION
  (p_delivery_rec	IN WSH_ENTITY_INFO_REC,
   p_content_weight	IN NUMBER,
   p_weight_limit	IN NUMBER,
   p_new_delivery_name	IN VARCHAR2 DEFAULT NULL,
   p_new_delivery_id    IN NUMBER DEFAULT NULL,
   p_exception_message	IN VARCHAR2 DEFAULT NULL,
   p_exception_name	IN VARCHAR2,
   x_return_status	OUT NOCOPY VARCHAR2) IS

  l_exception_id	WSH_EXCEPTIONS.EXCEPTION_ID%TYPE;
  l_exception_message	WSH_EXCEPTIONS.MESSAGE%TYPE;
  l_num_error           NUMBER;
  l_num_warn            NUMBER;
  l_return_status       VARCHAR2(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(32767);
  l_delivery_id         WSH_NEW_DELIVERIES.DELIVERY_ID%TYPE;
  unexp_error		EXCEPTION;

  l_debug_on       BOOLEAN;
  --
  l_module_name    CONSTANT VARCHAR2(100) := 'wsh.plsql.' || g_pkg_name ||
						     '.' || 'LOG_DEL_SPLITTER_EXCEPTION';

  BEGIN

    --
    l_debug_on := wsh_debug_interface.g_debug;
    --
    IF l_debug_on IS NULL THEN
      l_debug_on := wsh_debug_sv.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name);
      wsh_debug_sv.log(l_module_name, 'p_delivery_rec name',
                                       p_delivery_rec.entity_name);
      wsh_debug_sv.log(l_module_name, 'p_delivery_rec id',
                                       p_delivery_rec.entity_id);
      wsh_debug_sv.log(l_module_name, 'p_content_weight',
                                       p_content_weight);
      wsh_debug_sv.log(l_module_name, 'p_weight_limit',
                                       p_weight_limit);
      wsh_debug_sv.log(l_module_name, 'p_new_delivery_name',
                                       p_new_delivery_name);
      wsh_debug_sv.log(l_module_name, 'p_new_delivery_id',
                                       p_new_delivery_id);
      wsh_debug_sv.log(l_module_name, 'p_exception_message',
                                       p_exception_message);
      wsh_debug_sv.log(l_module_name, 'p_exception_name',
                                       p_exception_name);

    END IF;

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    l_num_error	:= 0;
    l_num_warn 	:= 0;

    IF (p_exception_name IS NULL OR p_delivery_rec.entity_id IS NULL) THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'exception name or delivery id is NULL');
      END IF;
      RAISE unexp_error;
    END IF;

    IF (p_new_delivery_id IS NOT NULL) THEN
      l_delivery_id := p_new_delivery_id;
    ELSE
      l_delivery_id := p_delivery_rec.entity_id;
    END IF;

    IF (p_exception_message IS NOT NULL) THEN
      l_exception_message := p_exception_message;
    ELSE
      IF (p_exception_name = 'WSH_OTM_DEL_OVERSIZED') THEN
        FND_MESSAGE.SET_NAME('WSH', 'WSH_OTM_DEL_OVERSIZED');
        FND_MESSAGE.SET_TOKEN('DELIVERY_NAME',
                              p_delivery_rec.entity_name);
        FND_MESSAGE.SET_TOKEN('GROSS_WEIGHT',
                              p_delivery_rec.gross_weight);
        FND_MESSAGE.SET_TOKEN('WEIGHT_LIMIT',
                              p_weight_limit);
        FND_MESSAGE.SET_TOKEN('DEL_DET_WEIGHT',
                              p_content_weight);
      ELSIF (p_exception_name = 'WSH_OTM_DEL_SPLIT_FAIL') THEN
        FND_MESSAGE.SET_NAME('WSH', 'WSH_OTM_DEL_SPLIT_FAILED');
        FND_MESSAGE.SET_TOKEN('DELIVERY_NAME',
                              p_delivery_rec.entity_name);
        FND_MESSAGE.SET_TOKEN('GROSS_WEIGHT',
                              p_delivery_rec.gross_weight);
        FND_MESSAGE.SET_TOKEN('WEIGHT_LIMIT',
                              p_weight_limit);
        FND_MESSAGE.SET_TOKEN('DEL_DET_WEIGHT',
                              p_content_weight);
      ELSIF (p_exception_name = 'WSH_OTM_DEL_SPLIT_CHILD') THEN
        FND_MESSAGE.SET_NAME('WSH', 'WSH_OTM_DELIVERY_SPLIT_CHILD');
        FND_MESSAGE.SET_TOKEN('CHILD_DELIVERY_NAME',
                              p_new_delivery_name);
        FND_MESSAGE.SET_TOKEN('PARENT_DELIVERY_NAME',
                              p_delivery_rec.entity_name);
      ELSIF (p_exception_name = 'WSH_OTM_DEL_LOCK_FAIL') THEN
        FND_MESSAGE.SET_NAME('WSH', 'WSH_NO_LOCK');
      ELSIF (p_exception_name IN ('WSH_OTM_DEL_SPLIT_LARGE', 'WSH_OTM_DEL_SPLIT')) THEN
        --the caller API (which is in this file since this is internal api) should provide the
        --message for these two exceptions due to complication, this is not expected
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'exception message is not provided for WSH_OTM_DEL_SPLIT_LARGE or WSH_OTM_DEL_SPLIT');
        END IF;
        RAISE unexp_error;
      END IF;

      l_exception_message := FND_MESSAGE.Get;

    END IF;

    IF (l_exception_message IS NULL) THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'exception message is NULL');
      END IF;
      RAISE unexp_error;
    END IF;

    l_exception_id := NULL;

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,
                  'Calling program unit WSH_XC_UTIL.LOG_EXCEPTION',
                  WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;

    WSH_XC_UTIL.log_exception(
      p_api_version           => 1.0,
      x_return_status         => l_return_status,
      x_msg_count             => l_msg_count,
      x_msg_data              => l_msg_data,
      x_exception_id          => l_exception_id,
      p_exception_location_id => p_delivery_rec.init_pickup_loc_id,
      p_logged_at_location_id => p_delivery_rec.init_pickup_loc_id,
      p_logging_entity        => 'SHIPPER',
      p_logging_entity_id     => FND_GLOBAL.USER_ID,
      p_exception_name        => p_exception_name,
      p_delivery_id           => l_delivery_id,
      p_message	              => SUBSTRB(l_exception_message,1,2000));

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'return status from WSH_XC_UTIL.log_exception: ' || l_return_status);
    END IF;

    IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
      l_num_error := l_num_error+1;
    END IF;

    IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
      l_num_warn := l_num_warn+1;
    END IF;

    IF l_num_error > 0 THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    ELSIF l_num_warn > 0 THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    ELSE
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    END IF;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'l_num_error', l_num_error);
      WSH_DEBUG_SV.log(l_module_name, 'l_num_warn', l_num_warn);
      WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --

      WSH_UTIL_CORE.default_handler(
        'WSH_DELIVERY_SPLITTER_PKG.LOG_DEL_SPLITTER_EXCEPTION', l_module_name);
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,
		'Unexpected error has occured. Oracle error message is '||
		SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;

  END LOG_DEL_SPLITTER_EXCEPTION;

  ---------------------------------------------------------------------
  -- PROCEDURE DELIVERY_SPLITTER
  --
  -- parameters: p_delivery_tab	    table of delivery information containing
  --				    id, gross weight, weight uom,
  --				    pickup loc, org id
  --		 p_autosplit_flag   variable for the autosplit option,
  --				    defaulted NULL, if Y then we will split
  --				    delivery if size is too large
  --		 x_accepted_del_id  table of delivery id that is accepted to
  --				    be sent to GC3
  --		 x_rejected_del_id  table of delivery id that is rejected
  --				    because of oversize
  --		 x_return_status    return status of the procedure
  --
  -- description: this procedure takes in a table of delivery information and
  --		  split the deliveries if the gross weight exceeds limit.
  --		  The splitting is done only if autosplit flag is Y, delivery
  --		  is not assigned to a trip, delivery lines are not pick
  --		  released,delivery's not content firm, delivery's each content
  --		  is not larger than the limit, and the sum of delivery's content
  --              matches the delivery weight total.
  ---------------------------------------------------------------------
  PROCEDURE Delivery_Splitter
  (p_delivery_tab	IN WSH_ENTITY_INFO_TAB,
   p_autosplit_flag	IN VARCHAR2 DEFAULT NULL,
   x_accepted_del_id	OUT NOCOPY WSH_OTM_ID_TAB,
   x_rejected_del_id	OUT NOCOPY WSH_OTM_ID_TAB,
   x_return_status	OUT NOCOPY VARCHAR2) IS

  -- this will get top most delivery detail ID, gross weight,
  -- and UOM, order by converted gross weight and ignoring null or 0
  -- weight details
  CURSOR c_get_delivery_line_and_cont(p_delivery_id IN NUMBER,
                                      p_uom IN VARCHAR2) IS
    SELECT decode(WDD.WEIGHT_UOM_CODE,
                  p_uom, WDD.GROSS_WEIGHT,
                  WSH_WV_UTILS.convert_uom(
                                wdd.weight_uom_code,
                                p_uom,
                                WDD.GROSS_WEIGHT)) gross_weight_converted,
           WDA.DELIVERY_DETAIL_ID
    FROM   WSH_DELIVERY_DETAILS WDD, WSH_DELIVERY_ASSIGNMENTS WDA
    WHERE  WDA.DELIVERY_ID = p_delivery_id
    AND    wda.delivery_detail_id = wdd.delivery_detail_id
    AND    WDA.PARENT_DELIVERY_DETAIL_ID IS NULL
    AND    WDD.WEIGHT_UOM_CODE IS NOT NULL
    AND    WDD.GROSS_WEIGHT <> 0
    ORDER BY gross_weight_converted ASC;

  -- this will get all delivery details' (non LPN) released status
  CURSOR c_get_delivery_line(p_delivery_id IN NUMBER) IS
    SELECT WDD.RELEASED_STATUS
    FROM   WSH_DELIVERY_DETAILS WDD, WSH_DELIVERY_ASSIGNMENTS WDA
    WHERE  WDA.DELIVERY_ID = p_delivery_id
    AND    WDA.DELIVERY_DETAIL_ID = WDD.DELIVERY_DETAIL_ID
    AND    WDD.CONTAINER_FLAG = 'N'
    AND    WDD.RELEASED_STATUS NOT IN ('R', 'B', 'X');

  -- check if delivery is assigned to a trip
  CURSOR c_is_delivery_assigned(p_delivery_id IN NUMBER) IS
    SELECT 1
    FROM WSH_DELIVERY_LEGS
    WHERE delivery_id = p_delivery_id
    AND rownum = 1;

  l_current_weight 		WSH_NEW_DELIVERIES.GROSS_WEIGHT%TYPE; -- variable used to track delivery weight
  l_content_weight		WSH_NEW_DELIVERIES.GROSS_WEIGHT%TYPE; -- variable used to track total content weight

  -- variable used to track delivery weight for new delivery
  l_new_weight 			WSH_NEW_DELIVERIES.GROSS_WEIGHT%TYPE;
  l_line_and_container_id 	WSH_UTIL_CORE.ID_TAB_TYPE;
  l_line_and_container_weight 	WSH_UTIL_CORE.ID_TAB_TYPE;
  l_line_status	                WSH_UTIL_CORE.COLUMN_TAB_TYPE;

  -- used to keep the list of delivery ids for the splitted delivery
  l_curr_del_split_list 	WSH_UTIL_CORE.ID_TAB_TYPE;
  l_curr_del_split_name		WSH_UTIL_CORE.COLUMN_TAB_TYPE;
  l_count 			NUMBER;
  -- used to keep the list of delivery ids for the new delivery creation
  l_current_ids 		WSH_UTIL_CORE.ID_TAB_TYPE;

  l_temp_ids			WSH_UTIL_CORE.ID_TAB_TYPE;
  l_parameter_info		WSH_SHIPPING_PARAMS_PVT.PARAMETER_REC_TYP;
  l_global_param_info		WSH_SHIPPING_PARAMS_PVT.GLOBAL_PARAMETERS_REC_TYP;
  l_new_delivery_name		WSH_NEW_DELIVERIES.NAME%TYPE;  -- new delivery id
  l_action_prms			WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type;
  l_temp_num			NUMBER;

  l_num_error           	NUMBER;
  l_num_warn            	NUMBER;
  l_return_status       	VARCHAR2(1);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(32767);

  l_delivery_info		WSH_NEW_DELIVERIES_PVT.DELIVERY_REC_TYPE;
  i  				NUMBER;
  j				NUMBER;
  k				NUMBER;
  z            			NUMBER;
  l_exception_name		WSH_EXCEPTIONS.EXCEPTION_NAME%TYPE;

  l_debug_on       BOOLEAN;
  --
  l_module_name    CONSTANT VARCHAR2(100) := 'wsh.plsql.' || g_pkg_name ||
					     '.' || 'DELIVERY_SPLITTER';
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
      wsh_debug_sv.push(l_module_name);
      wsh_debug_sv.log(l_module_name, 'P_DELIVERY_TAB.COUNT:',
			p_delivery_tab.count);
      wsh_debug_sv.log(l_module_name, 'p_autosplit_flag',
			p_autosplit_flag);
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    --

    --intialize
    l_temp_num 	:= 0;
    l_num_error := 0;
    l_num_warn 	:= 0;
    l_count	:= 0;
    l_new_delivery_name := NULL;
    x_rejected_del_id := WSH_OTM_ID_TAB();
    x_accepted_del_id := WSH_OTM_ID_TAB();
    l_exception_name := NULL;

    IF (p_delivery_tab.COUNT = 0) THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'there is no delivery to split');
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      RETURN;
    END IF;

    l_action_prms.caller := 'WSH_DELIVERY_SPLITTER';

    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIPPING_PARAMS_PVT.Get_Global_Parameters',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;

    WSH_SHIPPING_PARAMS_PVT.get_global_parameters(
			x_param_info    => l_global_param_info,
			x_return_status => l_return_status);

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'return status from WSH_SHIPPING_PARAMS_PVT.Get_Global_Parameters: ' || l_return_status);
    END IF;

    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
      l_num_warn := l_num_warn + 1;
    ELSIF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
			       WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
      FND_MESSAGE.Set_Name('WSH', 'WSH_INVALID_GLOBAL_PARAMETER');
      wsh_util_core.add_message(l_return_status,l_module_name);

      x_return_status := l_return_status;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      RETURN;
    END IF;

    i := p_delivery_tab.FIRST;

    --looping over all the deliveries to process each one for splitting
    WHILE i IS NOT NULL LOOP

      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name, 'P_DELIVERY_TAB.entity_id',
                                         p_delivery_tab(i).entity_id);
        wsh_debug_sv.log(l_module_name, 'p_delivery_tab.entity_name',
                                         p_delivery_tab(i).entity_name);
        wsh_debug_sv.log(l_module_name, 'p_delivery_tab.item_id',
                                         p_delivery_tab(i).item_id);
        wsh_debug_sv.log(l_module_name, 'p_delivery_tab.net_weight',
                                         p_delivery_tab(i).net_weight);
        wsh_debug_sv.log(l_module_name, 'p_delivery_tab.gross_weight',
                                         p_delivery_tab(i).gross_weight);
        wsh_debug_sv.log(l_module_name, 'p_delivery_tab.organization_id',
                                         p_delivery_tab(i).organization_id);
        wsh_debug_sv.log(l_module_name, 'p_delivery_tab.weight_uom',
                                         p_delivery_tab(i).weight_uom);
        wsh_debug_sv.log(l_module_name, 'p_delivery_tab.quantity',
                                         p_delivery_tab(i).quantity);
        wsh_debug_sv.log(l_module_name, 'p_delivery_tab.init_pickup_loc_id',
                                         p_delivery_tab(i).init_pickup_loc_id);
        wsh_debug_sv.log(l_module_name, 'p_delivery_tab.content_firm',
                                         p_delivery_tab(i).content_firm);
      END IF;


      --the locking procedure fails when delivery does not have details, and only
      --case the delivery has no details is when it is DELETE_REQUIRED.
      --so adding this first query to bypass all the DELETE_REQUIRED deliveries

      --get delivery information
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_VALIDATIONS.get_delivery_information',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

      WSH_DELIVERY_VALIDATIONS.get_delivery_information(p_delivery_id   => p_delivery_tab(i).entity_id,
                                                        x_delivery_rec  => l_delivery_info,
                                                        x_return_status => l_return_status);

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'return status from WSH_DELIVERY_VALIDATIONS.get_delivery_information: ' || l_return_status);
      END IF;

      IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
          WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN

        --reject failed delivery
        IF l_debug_on THEN
          wsh_debug_sv.logmsg(l_module_name, 'Error: cannot get delivery record');
        END IF;

        l_num_error := l_num_error + 1;
        x_rejected_del_id.EXTEND;
        x_rejected_del_id(x_rejected_del_id.COUNT) := p_delivery_tab(i).entity_id;
        GOTO loop_end;
      ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
        l_num_warn := l_num_warn + 1;
      END IF;

      --accept all delete required or ignore for planning deliveries, no need to split
      --Bug 7148914 added OR condition so that same flow is followed for delivery with tms_interface_flag 'DP'
      IF (l_delivery_info.ignore_for_planning = 'Y' OR
          l_delivery_info.tms_interface_flag = WSH_NEW_DELIVERIES_PVT.C_TMS_DELETE_REQUIRED OR
          l_delivery_info.tms_interface_flag = WSH_NEW_DELIVERIES_PVT.C_TMS_DELETE_IN_PROCESS ) THEN


        IF l_debug_on THEN
          wsh_debug_sv.logmsg(l_module_name, 'accepted delivery ' || p_delivery_tab(i).entity_id || ' because ignore for planning, DR or DP status');
        END IF;
        x_accepted_del_id.EXTEND;
        x_accepted_del_id(x_accepted_del_id.COUNT) := p_delivery_tab(i).entity_id;

        GOTO loop_end;

      END IF;

      --now proceed with the lock
      SAVEPOINT delivery_record;

      --LOCK THE DELIVERY AND IT'S CONTENT
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,
         'Calling program unit WSH_INTERFACE_COMMON_ACTIONS.LOCK_DELIVERY_AND_DETAILS',
         WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

      WSH_INTERFACE_COMMON_ACTIONS.lock_delivery_and_details(
               p_delivery_id   => p_delivery_tab(i).entity_id,
               x_return_status => l_return_status);

      IF l_debug_on THEN
        wsh_debug_sv.log (l_module_name,
           'Return status from lock delivery and details',
           l_return_status);
      END IF;

      --only locking one delivery, should have no warning status for l_return_status
      IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN

        IF l_debug_on THEN
          wsh_debug_sv.logmsg(l_module_name,
             'Unable to lock the delivery');
        END IF;

        l_num_error := l_num_error+1;

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit log_del_splitter_exception',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        log_del_splitter_exception
              (p_delivery_rec	        => p_delivery_tab(i),
               p_content_weight	        => l_content_weight,
               p_weight_limit		=> l_parameter_info.MAX_GROSS_WEIGHT,
               p_exception_name	        => 'WSH_OTM_DEL_LOCK_FAIL',
               x_return_status		=> l_return_status);

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'return status from log_del_splitter_exception: ' || l_return_status);
        END IF;

        x_rejected_del_id.EXTEND;
        x_rejected_del_id(x_rejected_del_id.COUNT) := p_delivery_tab(i).entity_id;
        GOTO loop_end;

      END IF;

      --get delivery information again to ensure it's latest
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_VALIDATIONS.get_delivery_information',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

      WSH_DELIVERY_VALIDATIONS.get_delivery_information(p_delivery_id   => p_delivery_tab(i).entity_id,
                                                        x_delivery_rec  => l_delivery_info,
                                                        x_return_status => l_return_status);

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'return status from WSH_DELIVERY_VALIDATIONS.get_delivery_information: ' || l_return_status);
      END IF;

      IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
          WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN

        ROLLBACK TO delivery_record;

        --reject failed delivery
        IF l_debug_on THEN
          wsh_debug_sv.logmsg(l_module_name, 'Error: cannot get delivery record');
        END IF;

        l_num_error := l_num_error + 1;
        x_rejected_del_id.EXTEND;
        x_rejected_del_id(x_rejected_del_id.COUNT) := p_delivery_tab(i).entity_id;
        GOTO loop_end;
      ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
        l_num_warn := l_num_warn + 1;
      END IF;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIPPING_PARAMS_PVT.Get',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

      --get shipping parameters
      WSH_SHIPPING_PARAMS_PVT.get(
		p_organization_id => p_delivery_tab(i).organization_id,
		x_param_info      => l_parameter_info,
		x_return_status   => l_return_status);

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'return status from WSH_SHIPPING_PARAMS_PVT.Get: ' || l_return_status);
      END IF;

      IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
        l_num_warn := l_num_warn + 1;
      ELSIF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
	  			 WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN

        ROLLBACK TO delivery_record;
        FND_MESSAGE.Set_Name('WSH', 'WSH_PARAM_NOT_DEFINED');
        FND_MESSAGE.Set_Token('ORGANIZATION_CODE',
             wsh_util_core.get_org_name(p_delivery_tab(i).organization_id));
        wsh_util_core.add_message(l_return_status,l_module_name);
        l_num_error := l_num_error+1;

        IF l_debug_on THEN
          wsh_debug_sv.logmsg(l_module_name, 'Error: cannot get shipping parameter info');
        END IF;

        x_rejected_del_id.EXTEND;
        x_rejected_del_id(x_rejected_del_id.COUNT) := p_delivery_tab(i).entity_id;

        GOTO loop_end;
      END IF;

      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,
                         'Max Gross Weight',
                         l_parameter_info.max_gross_weight);
        wsh_debug_sv.log(l_module_name,
                         'Global UOM',
                         l_global_param_info.GU_WEIGHT_UOM);
        wsh_debug_sv.log(l_module_name,
                         'delivery gross weight',
                         p_delivery_tab(i).gross_weight);
      END IF;

      --if no limit specified in shipping parameter, accept it all
      IF (l_parameter_info.MAX_GROSS_WEIGHT IS NULL) THEN

        IF l_debug_on THEN
          wsh_debug_sv.logmsg(l_module_name,
                              'Gross Weight IS NULL');
        END IF;

        x_accepted_del_id.EXTEND;
        x_accepted_del_id(x_accepted_del_id.COUNT) := p_delivery_tab(i).entity_id;
        COMMIT;  --release lock

        GOTO loop_end;
      END IF;

      --if delivery weight uom is not setup, then cannot proceed
      IF (p_delivery_tab(i).weight_uom IS NULL OR l_global_param_info.GU_WEIGHT_UOM IS NULL) THEN
        ROLLBACK TO delivery_record;

        IF l_debug_on THEN
          wsh_debug_sv.logmsg(l_module_name,
                              'Weight UOM IS NULL');
        END IF;

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit log_del_splitter_exception',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        log_del_splitter_exception
            (p_delivery_rec	        => p_delivery_tab(i),
             p_content_weight	        => 0, --passing 0 here because delivery UOM is NULL, dunno what weight would be.
             p_weight_limit		=> l_parameter_info.MAX_GROSS_WEIGHT,
             p_exception_name	        => 'WSH_OTM_DEL_SPLIT_FAIL',
             x_return_status		=> l_return_status);

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'return status from log_del_splitter_exception: ' || l_return_status);
        END IF;

        IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
          l_num_error := l_num_error+1;
        ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
          l_num_warn := l_num_warn+1;
        END IF;

        x_rejected_del_id.EXTEND;
        x_rejected_del_id(x_rejected_del_id.COUNT) := p_delivery_tab(i).entity_id;
        GOTO loop_end;

      END IF;

      --convert the max gross weight to delivery's weight UOM
      IF (l_global_param_info.GU_WEIGHT_UOM <> p_delivery_tab(i).weight_uom) THEN
        l_parameter_info.MAX_GROSS_WEIGHT := WSH_WV_UTILS.convert_uom(
					     from_uom => l_global_param_info.GU_WEIGHT_UOM,
 					     to_uom   => p_delivery_tab(i).weight_uom,
					     quantity => l_parameter_info.MAX_GROSS_WEIGHT);
      END IF;

      l_content_weight := 0;

      --checking if the delivery content weight sum is over the limit
      IF (NVL(l_delivery_info.wv_frozen_flag, 'N') = 'N') THEN
        --if delivery is not frozen, then weight is same
        l_content_weight := NVL(p_delivery_tab(i).gross_weight, 0);
      END IF;

      --if frozen weight or delivery is oversized then need to get the detail weights
      IF (NVL(p_delivery_tab(i).gross_weight, 0) > l_parameter_info.MAX_GROSS_WEIGHT
          OR l_delivery_info.wv_frozen_flag = 'Y') THEN

        l_line_and_container_weight.DELETE;
        l_line_and_container_id.DELETE;

        OPEN c_get_delivery_line_and_cont(p_delivery_tab(i).entity_id, p_delivery_tab(i).weight_uom);
        FETCH c_get_delivery_line_and_cont
          BULK COLLECT INTO l_line_and_container_weight,
                            l_line_and_container_id;

        IF l_debug_on THEN
          wsh_debug_sv.log(l_module_name,
            'l_line_and_container_weight.count:',
            l_line_and_container_weight.count);
          wsh_debug_sv.log(l_module_name,
            'l_line_and_container_id.count:',
            l_line_and_container_id.count);
          wsh_debug_sv.log(l_module_name,
            'wv_frozen_flag:',
            l_delivery_info.wv_frozen_flag);
        END IF;

        --if delivery weight is frozen, need to sum up the content weight
        IF (l_delivery_info.wv_frozen_flag = 'Y'
            AND l_line_and_container_weight.COUNT > 0) THEN

          z := l_line_and_container_weight.FIRST;

          --looping over the detail weights to sum it up.
          WHILE z IS NOT NULL LOOP

            l_content_weight := l_content_weight + l_line_and_container_weight(z);

            IF l_debug_on THEN
              wsh_debug_sv.log(l_module_name, 'z', z);
              wsh_debug_sv.log(l_module_name, 'l_content_weight', l_content_weight);
            END IF;

            z:= l_line_and_container_weight.NEXT(z);

          END LOOP;
        END IF;
        CLOSE c_get_delivery_line_and_cont;

        IF l_debug_on THEN
          wsh_debug_sv.log(l_module_name,
                         'Converted Max Gross Weight',
                         l_parameter_info.max_gross_weight);
          wsh_debug_sv.log(l_module_name,
                         'delivery content weight sum',
                         l_content_weight);
        END IF;
      END IF;

      --accept all under sized deliveries
      IF (NVL(p_delivery_tab(i).gross_weight, 0) <= l_parameter_info.MAX_GROSS_WEIGHT
         AND l_content_weight <= l_parameter_info.MAX_GROSS_WEIGHT) THEN

        x_accepted_del_id.EXTEND;
        x_accepted_del_id(x_accepted_del_id.COUNT) := p_delivery_tab(i).entity_id;
        COMMIT;  --release lock
        GOTO loop_end;
      END IF;

      --if split flag is off but oversized, reject it.
      IF (p_autosplit_flag IS NULL OR p_autosplit_flag = 'N') THEN

        ROLLBACK TO delivery_record;

        IF l_debug_on THEN
          wsh_debug_sv.logmsg(l_module_name,
                      'Autosplit flag is off but delivery weight or delivery detail weight sum is over the weight limits');
        END IF;

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit log_del_splitter_exception',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        log_del_splitter_exception
              (p_delivery_rec	        => p_delivery_tab(i),
               p_content_weight	        => l_content_weight,
               p_weight_limit		=> l_parameter_info.MAX_GROSS_WEIGHT,
               p_exception_name	        => 'WSH_OTM_DEL_OVERSIZED',
               x_return_status		=> l_return_status);

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'return status from log_del_splitter_exception: ' || l_return_status);
        END IF;

        IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
          l_num_error := l_num_error+1;
        ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
          l_num_warn := l_num_warn+1;
        END IF;

        x_rejected_del_id.EXTEND;
        x_rejected_del_id(x_rejected_del_id.COUNT) := p_delivery_tab(i).entity_id;

        GOTO loop_end;
      END IF;

      --split flag Yes but delivery weight and detail weight sum doesn't match and either delivery weight or detail
      --weight sum is over the limit, reject
      IF ((NVL(p_delivery_tab(i).gross_weight, 0) <= l_parameter_info.MAX_GROSS_WEIGHT
           AND l_content_weight > l_parameter_info.MAX_GROSS_WEIGHT)
          OR (NVL(p_delivery_tab(i).gross_weight, 0) > l_parameter_info.MAX_GROSS_WEIGHT
              AND l_content_weight <> NVL(p_delivery_tab(i).gross_weight, 0))) THEN

        ROLLBACK TO delivery_record;

        IF l_debug_on THEN
          wsh_debug_sv.logmsg(l_module_name,
              'Content Weight sum does not equal delivery gross weight');
        END IF;

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit log_del_splitter_exception',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        log_del_splitter_exception
              (p_delivery_rec	        => p_delivery_tab(i),
               p_content_weight	        => l_content_weight,
               p_weight_limit		=> l_parameter_info.MAX_GROSS_WEIGHT,
               p_exception_name	        => 'WSH_OTM_DEL_SPLIT_FAIL',
               x_return_status		=> l_return_status);

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'return status from log_del_splitter_exception: ' || l_return_status);
        END IF;

        IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
          l_num_error := l_num_error+1;
        ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
          l_num_warn := l_num_warn+1;
        END IF;

        x_rejected_del_id.EXTEND;
        x_rejected_del_id(x_rejected_del_id.COUNT) := p_delivery_tab(i).entity_id;
        GOTO loop_end;
      END IF;

      --if delivery is content firm, cannot split
      IF (p_delivery_tab(i).content_firm IN ('F', 'Y')) THEN

        ROLLBACK TO delivery_record;

        IF l_debug_on THEN
          wsh_debug_sv.logmsg(l_module_name,
			   'Delivery is content firm');
        END IF;

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit log_del_splitter_exception',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        log_del_splitter_exception
              (p_delivery_rec	        => p_delivery_tab(i),
               p_content_weight	        => l_content_weight,
               p_weight_limit		=> l_parameter_info.MAX_GROSS_WEIGHT,
               p_exception_name	        => 'WSH_OTM_DEL_SPLIT_FAIL',
               x_return_status		=> l_return_status);

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'return status from log_del_splitter_exception: ' || l_return_status);
        END IF;

        IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
          l_num_error := l_num_error+1;
        ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
          l_num_warn := l_num_warn+1;
        END IF;

        x_rejected_del_id.EXTEND;
        x_rejected_del_id(x_rejected_del_id.COUNT) := p_delivery_tab(i).entity_id;
        GOTO loop_end;

      END IF;

      --if one detail/LPN (entity that has no parent but the delivery) is larger than the limit, can't split
      IF l_line_and_container_weight(l_line_and_container_weight.LAST) > l_parameter_info.MAX_GROSS_WEIGHT THEN

        ROLLBACK TO delivery_record;

        IF l_debug_on THEN
          wsh_debug_sv.logmsg(l_module_name,
			   'Delivery line weight greater than the gross weight limit');
        END IF;

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit log_del_splitter_exception',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        log_del_splitter_exception
              (p_delivery_rec	        => p_delivery_tab(i),
               p_content_weight	        => l_content_weight,
               p_weight_limit		=> l_parameter_info.MAX_GROSS_WEIGHT,
               p_exception_name	        => 'WSH_OTM_DEL_SPLIT_FAIL',
               x_return_status		=> l_return_status);

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'return status from log_del_splitter_exception: ' || l_return_status);
        END IF;

        IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
          l_num_error := l_num_error+1;
        ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
          l_num_warn := l_num_warn+1;
        END IF;

        x_rejected_del_id.EXTEND;
        x_rejected_del_id(x_rejected_del_id.COUNT) := p_delivery_tab(i).entity_id;
        GOTO loop_end;

      END IF;

      OPEN c_is_delivery_assigned(p_delivery_tab(i).entity_id);
      FETCH c_is_delivery_assigned INTO l_temp_num;
      CLOSE c_is_delivery_assigned;

      --If delivery has trip, no split
      IF (l_temp_num IS NOT NULL AND l_temp_num > 0) THEN

        ROLLBACK TO delivery_record;

        IF l_debug_on THEN
          wsh_debug_sv.logmsg(l_module_name,
	            'Delivery is assigned to trip');
        END IF;

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit log_del_splitter_exception',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        log_del_splitter_exception
              (p_delivery_rec	        => p_delivery_tab(i),
               p_content_weight	        => l_content_weight,
               p_weight_limit		=> l_parameter_info.MAX_GROSS_WEIGHT,
               p_exception_name	        => 'WSH_OTM_DEL_SPLIT_FAIL',
               x_return_status		=> l_return_status);

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'return status from log_del_splitter_exception: ' || l_return_status);
        END IF;

        IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
          l_num_error := l_num_error+1;
        ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
          l_num_warn := l_num_warn+1;
        END IF;

        x_rejected_del_id.EXTEND;
        x_rejected_del_id(x_rejected_del_id.COUNT) := p_delivery_tab(i).entity_id;
        GOTO loop_end;

      END IF;

      --delivery with pick released/pick confirmed delivery lines cannot be split
      l_line_status.DELETE;
      OPEN c_get_delivery_line(p_delivery_tab(i).entity_id);
      FETCH c_get_delivery_line BULK COLLECT INTO l_line_status;
      CLOSE c_get_delivery_line;

      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name, 'l_line_status count', l_line_status.COUNT);
      END IF;

      IF (l_line_status.COUNT > 0) THEN

        ROLLBACK TO delivery_record;

        IF l_debug_on THEN
          wsh_debug_sv.logmsg(l_module_name,
                'Delivery line is pick released or pick confirmed.');
        END IF;

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit log_del_splitter_exception',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        log_del_splitter_exception
              (p_delivery_rec	        => p_delivery_tab(i),
               p_content_weight	        => l_content_weight,
               p_weight_limit		=> l_parameter_info.MAX_GROSS_WEIGHT,
               p_exception_name	        => 'WSH_OTM_DEL_SPLIT_FAIL',
               x_return_status		=> l_return_status);

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'return status from log_del_splitter_exception: ' || l_return_status);
        END IF;

        IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
          l_num_error := l_num_error+1;
        ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
          l_num_warn := l_num_warn+1;
        END IF;

        x_rejected_del_id.EXTEND;
        x_rejected_del_id(x_rejected_del_id.COUNT) := p_delivery_tab(i).entity_id;
        GOTO loop_end;

      END IF;

      l_current_weight := 0;

      --Splitting the delivery by delivery detail weights
      --looping over all the top most detail/LPNs in the delivery
      j := l_line_and_container_id.FIRST;
      WHILE j IS NOT NULL LOOP

        --try to fill up as many detail/LPN as possible within the weight limit.
        IF (l_current_weight + l_line_and_container_weight(j)) <= l_parameter_info.MAX_GROSS_WEIGHT THEN

          l_current_weight := l_current_weight + l_line_and_container_weight(j);

        ELSE

          --unassign all the delivery lines that's outside the limit
          l_temp_ids.DELETE;

          --looping over all the top most detail/LPNs from z to the end of the list
          --to create a list of ids to unassign from delivery
          z := j;
          WHILE z IS NOT NULL LOOP

            l_temp_ids(l_temp_ids.COUNT+1) := l_line_and_container_id(z);
            z:= l_line_and_container_id.NEXT(z);

          END LOOP;

          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,
                  'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.Unassign_multiple_details',
                  WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          WSH_DELIVERY_DETAILS_ACTIONS.unassign_multiple_details(
			       	  p_rec_of_detail_ids => l_temp_ids,
			       	  p_from_delivery     => 'Y',
			       	  p_from_container    => 'N',
		       		  p_action_prms       => l_action_prms,
			       	  x_return_status     => l_return_status);

          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'return status from WSH_DELIVERY_DETAILS_ACTIONS.UNASSIGN_MULTIPLE_DETAILS: ' || l_return_status);
          END IF;

          IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN

            ROLLBACK TO delivery_record;

            l_num_error := l_num_error+1;

            --reject failed delivery
            IF l_debug_on THEN
              wsh_debug_sv.logmsg(l_module_name, 'Error during unassign delivery details');
            END IF;

            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit log_del_splitter_exception',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

            log_del_splitter_exception
                  (p_delivery_rec	        => p_delivery_tab(i),
                   p_content_weight	        => l_content_weight,
                   p_weight_limit		=> l_parameter_info.MAX_GROSS_WEIGHT,
                   p_exception_name	        => 'WSH_OTM_DEL_SPLIT_FAIL',
                   x_return_status		=> l_return_status);

            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name, 'return status from log_del_splitter_exception: ' || l_return_status);
            END IF;

            x_rejected_del_id.EXTEND;
            x_rejected_del_id(x_rejected_del_id.COUNT) := p_delivery_tab(i).entity_id;
            GOTO loop_end;

          ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
            l_num_warn := l_num_warn+1;
          END IF;

          l_new_weight := 0;
          l_curr_del_split_list(1) := p_delivery_tab(i).entity_id;
          l_curr_del_split_name(1) := p_delivery_tab(i).entity_name;

          l_current_ids.DELETE;

          --now loop through the list of top most details/LPNs from j to the end to figure out
          --which details/LPNs can be put into new deliveries
          k := j;
          WHILE k IS NOT NULL LOOP

            --assign as many details/LPNs as possible under the weight limit for the new delivery
            IF (l_new_weight + l_line_and_container_weight(k)) <= l_parameter_info.MAX_GROSS_WEIGHT THEN

              l_new_weight := l_new_weight + l_line_and_container_weight(k);
              l_current_ids(l_current_ids.COUNT+1) := l_line_and_container_id(k);

            ELSE
              --if no more can be added to the new delivery, create the delivery based on the list l_current_ids

              l_temp_ids.DELETE;

              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,
                       'Calling program unit WSH_DELIVERY_DETAILS_GRP.AUTOCREATE_DELIVERIES',
                        WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_DELIVERY_DETAILS_GRP.autocreate_deliveries(
                        	p_api_version_number   =>  1.0,
                        	p_init_msg_list        =>  FND_API.G_FALSE,
                        	p_commit               =>  FND_API.G_FALSE,
				p_caller               =>  l_action_prms.caller,
                        	x_return_status        =>  l_return_status ,
                        	x_msg_count            =>  l_msg_count,
                        	x_msg_data             =>  l_msg_data,
                        	p_line_rows            =>  l_current_ids,
                        	p_group_by_header_flag =>  'N',
                        	x_del_rows             =>  l_temp_ids);

              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name, 'return status from WSH_DELIVERY_DETAILS_GRP.AUTOCREATE_DELIVERIES: ' || l_return_status);
              END IF;

              IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN

                ROLLBACK TO delivery_record;

                l_num_error := l_num_error+1;
                --reject failed delivery
                IF l_debug_on THEN
                  wsh_debug_sv.logmsg(l_module_name, 'Error during autocreate delivery');
                END IF;

                IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit log_del_splitter_exception',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;

                log_del_splitter_exception
                        (p_delivery_rec	        => p_delivery_tab(i),
                         p_content_weight       => l_content_weight,
                         p_weight_limit		=> l_parameter_info.MAX_GROSS_WEIGHT,
                         p_exception_name       => 'WSH_OTM_DEL_SPLIT_FAIL',
                         x_return_status	=> l_return_status);

                IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name, 'return status from log_del_splitter_exception: ' || l_return_status);
                END IF;

                x_rejected_del_id.EXTEND;
                x_rejected_del_id(x_rejected_del_id.COUNT) := p_delivery_tab(i).entity_id;
                GOTO loop_end;

              ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
                l_num_warn := l_num_warn+1;
              END IF;

              z := l_temp_ids.FIRST;

              WHILE z IS NOT NULL LOOP

                l_new_delivery_name :=  WSH_NEW_DELIVERIES_PVT.get_name(l_temp_ids(z));  --newly created delivery

                --logging tms exception for the new delivery
                IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit log_del_splitter_exception',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;

                log_del_splitter_exception
                     (p_delivery_rec		=> p_delivery_tab(i),
                      p_content_weight          => NULL,
                      p_weight_limit		=> NULL,
                      p_new_delivery_name	=> l_new_delivery_name,
                      p_new_delivery_id         => l_temp_ids(z),
                      p_exception_name          => 'WSH_OTM_DEL_SPLIT_CHILD',
                      x_return_status		=> l_return_status);

                IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name, 'return status from log_del_splitter_exception: ' || l_return_status);
                END IF;

                IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN

                  ROLLBACK TO delivery_record;
                  IF l_debug_on THEN
                    wsh_debug_sv.logmsg(l_module_name, 'Error during log delivery exception');
                  END IF;

                  l_num_error := l_num_error+1;
                  x_rejected_del_id.EXTEND;
                  x_rejected_del_id(x_rejected_del_id.COUNT) := p_delivery_tab(i).entity_id;
                  GOTO loop_end;
                ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
                  l_num_warn := l_num_warn+1;
                END IF;

                l_curr_del_split_list(l_curr_del_split_list.COUNT+1) := l_temp_ids(z);
                l_curr_del_split_name(l_curr_del_split_name.COUNT+1) := l_new_delivery_name;

                z := l_temp_ids.NEXT(z);

              END LOOP;  --l_temp_ids

              l_new_weight := l_line_and_container_weight(k);
              l_current_ids.DELETE;
              l_current_ids(l_current_ids.COUNT+1) := l_line_and_container_id(k);

            END IF;
            k:= l_line_and_container_id.NEXT(k);

          END LOOP; -- FOR k in j..l_line_and_container_id.last

          --create the last delivery after all the list gone over and new deliveries created, at least 1 more
          --line/LPN should be left under the limit.
          l_temp_ids.DELETE;

          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,
                  'Calling program unit WSH_DELIVERY_DETAILS_GRP.AUTOCREATE_DELIVERIES',
                  WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          WSH_DELIVERY_DETAILS_GRP.autocreate_deliveries(
	                          p_api_version_number   =>  1.0,
        	                  p_init_msg_list        =>  FND_API.G_FALSE,
                	          p_commit               =>  FND_API.G_FALSE,
				  p_caller               =>  l_action_prms.caller,
	                          x_return_status        =>  l_return_status ,
        	                  x_msg_count            =>  l_msg_count,
                	          x_msg_data             =>  l_msg_data,
                        	  p_line_rows            =>  l_current_ids,
	                          p_group_by_header_flag =>  'N',
        	                  x_del_rows             =>  l_temp_ids);

          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'return status from WSH_DELIVERY_DETAILS_GRP.AUTOCREATE_DELIVERIES: ' || l_return_status);
          END IF;

          IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN

            ROLLBACK TO delivery_record;

            l_num_error := l_num_error+1;

            --reject failed delivery
            IF l_debug_on THEN
              wsh_debug_sv.logmsg(l_module_name, 'Error during autocreate delivery');
            END IF;

            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit log_del_splitter_exception',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

            log_del_splitter_exception
                  (p_delivery_rec	        => p_delivery_tab(i),
                   p_content_weight	        => l_content_weight,
                   p_weight_limit		=> l_parameter_info.MAX_GROSS_WEIGHT,
                   p_exception_name	        => 'WSH_OTM_DEL_SPLIT_FAIL',
                   x_return_status		=> l_return_status);

            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name, 'return status from log_del_splitter_exception: ' || l_return_status);
            END IF;

            x_rejected_del_id.EXTEND;
            x_rejected_del_id(x_rejected_del_id.COUNT) := p_delivery_tab(i).entity_id;
            GOTO loop_end;

          ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
            l_num_warn := l_num_warn+1;
          END IF;

          z := l_temp_ids.FIRST;

          WHILE z IS NOT NULL LOOP

            l_new_delivery_name :=  WSH_NEW_DELIVERIES_PVT.get_name(l_temp_ids(z));  --newly created delivery

            --log tms exceptions for the new delivery
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit log_del_splitter_exception',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

            log_del_splitter_exception
                     (p_delivery_rec		=> p_delivery_tab(i),
                      p_content_weight          => NULL,
                      p_weight_limit		=> NULL,
                      p_new_delivery_name	=> l_new_delivery_name,
                      p_new_delivery_id         => l_temp_ids(z),
                      p_exception_name          => 'WSH_OTM_DEL_SPLIT_CHILD',
                      x_return_status		=> l_return_status);

            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name, 'return status from log_del_splitter_exception: ' || l_return_status);
            END IF;

            IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN

              ROLLBACK TO delivery_record;

              IF l_debug_on THEN
                wsh_debug_sv.logmsg(l_module_name, 'Error during log delivery exception');
              END IF;

              l_num_error := l_num_error+1;
              x_rejected_del_id.EXTEND;
              x_rejected_del_id(x_rejected_del_id.COUNT) := p_delivery_tab(i).entity_id;
              GOTO loop_end;
            ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
              l_num_warn := l_num_warn+1;
            END IF;

            l_curr_del_split_list(l_curr_del_split_list.COUNT+1) := l_temp_ids(z);
            l_curr_del_split_name(l_curr_del_split_name.COUNT+1) := l_new_delivery_name;

            z := l_temp_ids.NEXT(z);

          END LOOP;  --l_temp_ids

          l_count := l_curr_del_split_list.COUNT;

          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,
                  l_curr_del_split_name(1) || ' is split into '
                  || l_count || ' deliveries.');

            z := l_curr_del_split_list.FIRST;

            WHILE z IS NOT NULL LOOP

              WSH_DEBUG_SV.log(l_module_name, 'Delivery ' || z, l_curr_del_split_list(z));
              WSH_DEBUG_SV.log(l_module_name, 'Delivery Name ' || z, l_curr_del_split_name(z));
              z:= l_curr_del_split_list.NEXT(z);

            END LOOP;
          END IF;

          --after the delivery is split, need to log exception on delivery to inform the user
          --generating exception message based on number of deliveries split.
          IF (l_count > 6) THEN
            l_exception_name := 'WSH_OTM_DEL_SPLIT_LARGE';
            FND_MESSAGE.SET_NAME('WSH', 'WSH_OTM_DELIVERY_SPLIT_LARGE');
          ELSE
            l_exception_name := 'WSH_OTM_DEL_SPLIT';
            FND_MESSAGE.SET_NAME('WSH', 'WSH_OTM_DELIVERY_SPLIT');
          END IF;

          FND_MESSAGE.SET_TOKEN('PARENT_DELIVERY_NAME', l_curr_del_split_name(1));

          --setting child delivery name 1-5 in the message
          FOR z IN 2..6 LOOP
            IF (l_count >= z) THEN
              FND_MESSAGE.SET_TOKEN('CHILD_DELIVERY_NAME' || to_char(z-1), l_curr_del_split_name(z));
            ELSE
              FND_MESSAGE.SET_TOKEN('CHILD_DELIVERY_NAME' || to_char(z-1), NULL);
            END IF;
          END LOOP;

          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit log_del_splitter_exception',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          log_del_splitter_exception
                (p_delivery_rec         => p_delivery_tab(i),
                 p_content_weight	=> NULL,
                 p_weight_limit         => NULL,
                 p_exception_message	=> FND_MESSAGE.get,
                 p_exception_name	=> l_exception_name,
                 x_return_status	=> l_return_status);

          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'return status from log_del_splitter_exception: ' || l_return_status);
          END IF;

          IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN

            ROLLBACK TO delivery_record;

            --reject failed delivery
            IF l_debug_on THEN
              wsh_debug_sv.logmsg(l_module_name, 'Error during log delivery exception');
            END IF;

            l_num_error := l_num_error+1;
            x_rejected_del_id.EXTEND;
            x_rejected_del_id(x_rejected_del_id.COUNT) := p_delivery_tab(i).entity_id;
            GOTO loop_end;
          ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
            l_num_warn := l_num_warn+1;
          END IF;

          z := l_curr_del_split_list.FIRST;

          WHILE z IS NOT NULL LOOP

            x_accepted_del_id.EXTEND;
            x_accepted_del_id(x_accepted_del_id.COUNT) := l_curr_del_split_list(z);

            z:= l_curr_del_split_list.NEXT(z);

          END LOOP;

          l_curr_del_split_list.DELETE;
          l_curr_del_split_name.DELETE;
          l_current_ids.DELETE;  --remove current autocreate ids

          EXIT; --end current delivery loop;

        END IF;
        j:= l_line_and_container_id.NEXT(j);

      END LOOP; --FOR j
      COMMIT;  --release lock
      i:= p_delivery_tab.NEXT(i);
      GOTO next;

      <<loop_end>>
      i:= p_delivery_tab.NEXT(i);

      <<next>>
      NULL;
    END LOOP;

    IF (l_num_error > 0 AND l_num_error = p_delivery_tab.COUNT) THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    ELSIF (l_num_error > 0 OR l_num_warn > 0) THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    ELSE
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    END IF;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'l_num_error', l_num_error);
      WSH_DEBUG_SV.log(l_module_name, 'l_num_warn', l_num_warn);
      WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
  EXCEPTION
    --
    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO delivery_record;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF (c_get_delivery_line_and_cont%ISOPEN) THEN
	CLOSE c_get_delivery_line_and_cont;
      END IF;
      --
      IF (c_is_delivery_assigned%ISOPEN) THEN
	CLOSE c_is_delivery_assigned;
      END IF;
      --
      IF c_get_delivery_line%ISOPEN THEN
        CLOSE c_get_delivery_line;
      END IF;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,
			    'FND_API.G_EXC_ERROR exception has occured ',
			    WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            --
      ROLLBACK TO delivery_record;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      IF (c_get_delivery_line_and_cont%ISOPEN) THEN
	CLOSE c_get_delivery_line_and_cont;
      END IF;
      --
      IF (c_is_delivery_assigned%ISOPEN) THEN
	CLOSE c_is_delivery_assigned;
      END IF;
      --
      IF c_get_delivery_line%ISOPEN THEN
        CLOSE c_get_delivery_line;
      END IF;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,
			    'Unexpected error has occured. Oracle error message is '||
			    SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,
			 'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --

    WHEN NO_DATA_FOUND THEN

      ROLLBACK TO delivery_record;
      FND_MESSAGE.Set_Name('WSH','WSH_DEL_NOT_FOUND');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF (c_get_delivery_line_and_cont%ISOPEN) THEN
	CLOSE c_get_delivery_line_and_cont;
      END IF;
      --
      IF (c_is_delivery_assigned%ISOPEN) THEN
	CLOSE c_is_delivery_assigned;
      END IF;
      --
      IF c_get_delivery_line%ISOPEN THEN
        CLOSE c_get_delivery_line;
      END IF;
      --
      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,
			'NO_DATA_FOUND exception has occured.',
			WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NO_DATA_FOUND');
      END IF;
      --

    WHEN OTHERS THEN

      ROLLBACK TO delivery_record;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF (c_get_delivery_line_and_cont%ISOPEN) THEN
	CLOSE c_get_delivery_line_and_cont;
      END IF;
      --
      IF (c_is_delivery_assigned%ISOPEN) THEN
	CLOSE c_is_delivery_assigned;
      END IF;
      --
      IF c_get_delivery_line%ISOPEN THEN
        CLOSE c_get_delivery_line;
      END IF;
      --
      WSH_UTIL_CORE.DEFAULT_HANDLER(
		'WSH_DELIVERY_SPLITTER_PKG.DELIVERY_SPLITTER', l_module_name);
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,
		'Unexpected error has occured. Oracle error message is '||
		SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;

  END DELIVERY_SPLITTER;


END WSH_DELIVERY_SPLITTER_PKG;

/
