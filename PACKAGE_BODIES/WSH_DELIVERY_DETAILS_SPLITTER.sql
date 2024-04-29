--------------------------------------------------------
--  DDL for Package Body WSH_DELIVERY_DETAILS_SPLITTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_DELIVERY_DETAILS_SPLITTER" as
/* $Header: WSHDTSPB.pls 120.2.12010000.2 2009/12/03 16:15:53 gbhargav ship $ */

  G_PACKAGE_NAME CONSTANT   VARCHAR2(50) := 'WSH_DELIVERY_DETAILS_SPLITTER';


  --OTM R12
  ------------------------------------------------------------
  -- PROCEDURE TMS_DELIVERY_DETAIL_SPLIT
  --
  --  Parameters: p_detail_tab	table of delivery detail information containing
  --				id, net weight, weight uom,
  --				pickup loc, org id, quantity, item id
  --              p_item_quantity_uom_tab  table of delivery detail requested
  --                                       quantity uoms
  --              x_return_status return status
  --
  --  Description:    This API is used to control the delivery detail size when
  --		      it is created. it will take a table of delivery details
  --		      information and call split api until the weight of the
  --		      delivery detail is under the limit specified in the
  --                  shipping parameter.  The splitting is done based on
  --		      decimal quantity of the item
  -- The procedure returns with success if no delivery details are passed in.
  ------------------------------------------------------------
  PROCEDURE tms_delivery_detail_split
  (p_detail_tab            IN         WSH_ENTITY_INFO_TAB,
   p_item_quantity_uom_tab IN         WSH_UTIL_CORE.COLUMN_TAB_TYPE,
   x_return_status         OUT NOCOPY VARCHAR2) IS

  -- LSP PROJECT :
  CURSOR c_get_client(p_delivery_detail_id IN NUMBER) IS
    SELECT client_id
    FROM   wsh_delivery_details
    WHERE  delivery_detail_id = p_delivery_detail_id;
  --
  l_client_id               NUMBER;
  l_standalone_mode         VARCHAR2(1);
  -- LSP PROJECT : end
  l_parameter_info	WSH_SHIPPING_PARAMS_PVT.PARAMETER_REC_TYP;
  l_global_param_info	WSH_SHIPPING_PARAMS_PVT.GLOBAL_PARAMETERS_REC_TYP;
  l_max_quantity	WSH_DELIVERY_DETAILS.REQUESTED_QUANTITY%TYPE;
  l_quantity		WSH_DELIVERY_DETAILS.REQUESTED_QUANTITY%TYPE;
  l_new_detail_id	WSH_DELIVERY_DETAILS.DELIVERY_DETAIL_ID%TYPE;
  l_num_split		NUMBER;
  l_msg_count		NUMBER;
  l_msg_data            VARCHAR2(32767);
  l_exception_id	WSH_EXCEPTIONS.EXCEPTION_ID%TYPE;
  l_number_of_errors    NUMBER;
  l_number_of_warnings  NUMBER;
  l_return_status       VARCHAR2(1);
  l_dd_id_tab		WSH_UTIL_CORE.ID_TAB_TYPE;
  l_temp		NUMBER;
  l_exception_message	WSH_EXCEPTIONS.MESSAGE%TYPE;
  i			NUMBER;
  split_error		EXCEPTION;
  l_gc3_is_installed    VARCHAR2(1);
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' ||
					  G_PACKAGE_NAME ||
					  '.' || 'TMS_DELIVERY_DETAIL_SPLIT';
  --
  BEGIN
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_DETAIL_TAB COUNT',p_detail_tab.COUNT);
      WSH_DEBUG_SV.log(l_module_name,'P_ITEM_QUANTITY_UOM_TAB COUNT',p_item_quantity_uom_tab.COUNT);
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED;

    IF (l_gc3_is_installed IS NULL) THEN
      l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED;
    END IF;

    IF (l_gc3_is_installed = 'Y') THEN
      --initializing
      l_max_quantity       := 0;
      l_quantity           := 0;
      l_num_split          := 0;
      l_number_of_warnings := 0;
      l_number_of_errors   := 0;
      l_temp 	           := 0;
      i	                   := 0;

      IF (p_detail_tab.COUNT = 0) THEN
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'no delivery detail to split');
          WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        RETURN;
      END IF;

      --get weight UOM from global parameters

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIPPING_PARAMS_PVT.Get_Global_Parameters',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

      WSH_SHIPPING_PARAMS_PVT.get_global_parameters(
		x_param_info => l_global_param_info,
		x_return_status => l_return_status);

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'return status from WSH_SHIPPING_PARAMS_PVT.Get_Global_Parameters: ' || l_return_status);
      END IF;

      IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
        l_number_of_warnings := l_number_of_warnings + 1;
      ELSIF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
			       WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
        FND_MESSAGE.Set_Name('WSH', 'WSH_INVALID_GLOBAL_PARAMETER');
        wsh_util_core.add_message(l_return_status,l_module_name);
        x_return_status := l_return_status;
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        RETURN;
      END IF;

      i:= p_detail_tab.FIRST;
      l_standalone_mode := WMS_DEPLOY.WMS_DEPLOYMENT_MODE; -- LSP PROJECT
      WHILE i IS NOT NULL LOOP

        l_temp := i;

        BEGIN
          -- LSP PROJECT :Populate local table if client info is there on dd.
          l_client_id       := NULL;
          IF l_standalone_mode  = 'L' THEN
          --{
            OPEN  c_get_client(p_detail_tab(i).entity_id);
            FETCH c_get_client INTO l_client_id;
            CLOSE c_get_client;
          --}
          END IF;
          -- LSP PROJECT : end
          --
          --get net weight limit
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIPPING_PARAMS_PVT.Get',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          WSH_SHIPPING_PARAMS_PVT.get(
              p_organization_id => p_detail_tab(i).organization_id,
              p_client_id       => l_client_id, -- LSP PROJECT
              x_param_info => l_parameter_info,
              x_return_status => l_return_status);

          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'return status from WSH_SHIPPING_PARAMS_PVT.Get: ' || l_return_status);
          END IF;

          IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
            WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
            FND_MESSAGE.Set_Name('WSH', 'WSH_PARAM_NOT_DEFINED');
            FND_MESSAGE.Set_Token('ORGANIZAION_CODE',
               wsh_util_core.get_org_name(p_detail_tab(i).organization_id));
            wsh_util_core.add_message(l_return_status,l_module_name);
            l_number_of_errors := l_number_of_errors+1;

          ELSE

            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
              l_number_of_warnings := l_number_of_warnings + 1;
            END IF;

            IF l_debug_on THEN
              wsh_debug_sv.log(l_module_name,'l_parameter_info.otm_enabled', l_parameter_info.otm_enabled );
            END IF;

            --Added the outer if condition to check OTM enabled at org level.
            IF l_parameter_info.otm_enabled = 'Y' THEN --OTM R12 Org-Specific
            --{
              IF l_debug_on THEN
                wsh_debug_sv.log(l_module_name,
                                 'Max Net Weight',
                                 l_parameter_info.max_net_weight);
                wsh_debug_sv.log(l_module_name,
			   'Global UOM',
			   l_global_param_info.GU_WEIGHT_UOM);
                wsh_debug_sv.log(l_module_name,
			   'detail uom',
			   p_detail_tab(i).weight_uom);
              END IF;

              IF l_parameter_info.MAX_NET_WEIGHT IS NOT NULL THEN
                --convert the net weight limit to use delivery detail's weight UOM

                IF (p_detail_tab(i).weight_uom IS NULL) THEN
                  RAISE split_error;
                END IF;

                IF (l_global_param_info.GU_WEIGHT_UOM <> p_detail_tab(i).weight_uom) THEN
                  l_parameter_info.MAX_NET_WEIGHT := WSH_WV_UTILS.convert_uom(
					     from_uom => l_global_param_info.GU_WEIGHT_UOM,
 					     to_uom   => p_detail_tab(i).weight_uom,
					     quantity => l_parameter_info.MAX_NET_WEIGHT);
                END IF;

                IF l_debug_on THEN
                  wsh_debug_sv.log(l_module_name,
			   'Converted Max Net Weight',
			   l_parameter_info.max_net_weight);

                  wsh_debug_sv.log(l_module_name,
			   'Detail Weight',
			   NVL(p_detail_tab(i).net_weight, 0));
                END IF;

                IF (NVL(p_detail_tab(i).net_weight, 0) > l_parameter_info.MAX_NET_WEIGHT) THEN

                  IF (l_parameter_info.MAX_NET_WEIGHT = 0) THEN
                    RAISE split_error;
                  END IF;

                  --here we are not checking p_detail_tab's weight is 0 or NULL because if 0 it shouldn't
                  --be over the net weight limit

                  --calculate ideal max quantity in a delivery
                  l_max_quantity := (l_parameter_info.MAX_NET_WEIGHT / p_detail_tab(i).net_weight) * p_detail_tab(i).quantity;
                  --number of split needed idealy
                  l_num_split := FLOOR(p_detail_tab(i).net_weight/l_parameter_info.MAX_NET_WEIGHT);

                  IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DETAILS_VALIDATIONS.CHECK_DECIMAL_QUANTITY',WSH_DEBUG_SV.C_PROC_LEVEL);
                    WSH_DEBUG_SV.log(l_module_name, 'l_max_quantity', l_max_quantity);
                    WSH_DEBUG_SV.log(l_module_name, 'l_num_split', l_num_split);
                  END IF;

                  WSH_DETAILS_VALIDATIONS.check_decimal_quantity(
                      p_item_id         => p_detail_tab(i).item_id,
                      p_organization_id => p_detail_tab(i).organization_id,
                      p_input_quantity  => l_max_quantity,
                      p_uom_code        => p_item_quantity_uom_tab(i),
                      x_output_quantity => l_quantity,
                      x_return_status   => l_return_status);

                  IF l_debug_on THEN
                    wsh_debug_sv.log(l_module_name,
			   'check decimal quantity return status',
			   l_return_status);
                    WSH_DEBUG_SV.log(l_module_name, 'l_quantity', l_quantity);
                  END IF;

                  IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE split_error;
                  ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
                    --indivisible quantity, calculate split num by quantity
                    l_max_quantity := FLOOR(l_quantity); --take the maximum whole number quantity since not divisible

                    IF (l_max_quantity = 0) THEN
                      l_num_split := 0;
                    ELSE
                      --calculate number of splits
                      l_num_split := FLOOR(p_detail_tab(i).quantity/l_max_quantity);
                      IF (MOD(p_detail_tab(i).quantity, l_max_quantity) = 0) THEN
                        --need to -1 split if the two quantity is perfectly divisible
                        l_num_split := l_num_split -1;
                      END IF;
                    END IF;

                  ELSE  --has decimal quantity

                    IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
                      l_number_of_warnings := l_number_of_warnings+1;
                    END IF;

                    --if there's no remainder that means the number of splits is one less
                    --than the weights divided
                    IF (MOD(p_detail_tab(i).net_weight,l_parameter_info.MAX_NET_WEIGHT) = 0) THEN
                      l_num_split := l_num_split - 1;
                    END IF;
                  END IF;

                  IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name, 'l_num_split', l_num_split);
                  END IF;

                  IF (l_num_split = 0) THEN
                    RAISE split_error;
                  END IF;

                  l_dd_id_tab.DELETE;
                  l_new_detail_id := NULL;

                  IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,
                        'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.SPLIT_DELIVERY_DETAILS_BULK',
	                WSH_DEBUG_SV.C_PROC_LEVEL);
                    WSH_DEBUG_SV.log(l_module_name, 'l_num_split', l_num_split);
                  END IF;

                  WSH_DELIVERY_DETAILS_ACTIONS.split_delivery_details_bulk (
                      p_from_detail_id => p_detail_tab(i).entity_id,
                      p_req_quantity   => l_max_quantity,
                      p_num_of_split   => l_num_split,
                      x_new_detail_id  => l_new_detail_id,
                      x_dd_id_tab      => l_dd_id_tab,
                      x_return_status  => l_return_status
                  );

                  IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name, 'return status from WSH_DELIVERY_DETAILS_ACTIONS.SPLIT_DELIVERY_DETAILS_BULK: ' || l_return_status);
                  END IF;

                  IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
                    RAISE split_error;
                  END IF;

                  IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
                    l_number_of_warnings := l_number_of_warnings+1;
                  END IF;

                END IF;  --detail weight > l_parameter_info.MAX_NET_WEIGHT
              END IF;  --l_parameter_info.MAX_NET_WEIGHT IS NOT NULL
            --}
            END IF;  --l_parameter_info.otm_enabled = 'Y'
          END IF;  --l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR or UNEXP ERROR

        EXCEPTION
          WHEN split_error THEN  --catching every exception and treat it as cannot split
            --
            l_number_of_errors := l_number_of_errors+1;
            FND_MESSAGE.SET_NAME('WSH', 'WSH_OTM_DET_SPLIT_FAILED');
            FND_MESSAGE.SET_TOKEN('DELIVERY_DETAIL_ID',
                                   p_detail_tab(l_temp).entity_id);
            FND_MESSAGE.SET_TOKEN('NET_WEIGHT',
                                   p_detail_tab(l_temp).net_weight);
            FND_MESSAGE.SET_TOKEN('WEIGHT_LIMIT',
                                   l_parameter_info.MAX_NET_WEIGHT);

            l_exception_message := FND_MESSAGE.Get;

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
                  p_exception_location_id => p_detail_tab(l_temp).init_pickup_loc_id,
                  p_logged_at_location_id => p_detail_tab(l_temp).init_pickup_loc_id,
                  p_logging_entity        => 'SHIPPER',
                  p_logging_entity_id     => FND_GLOBAL.USER_ID,
                  p_exception_name        => 'WSH_OTM_DET_OVERSIZED',
                  p_delivery_detail_id    => p_detail_tab(l_temp).entity_id,
                  p_message		  => SUBSTRB(l_exception_message,1,2000)
            );

            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name, 'return status from WSH_XC_UTIL.log_exception: ' || l_return_status);
            END IF;

            IF l_debug_on THEN
              wsh_debug_sv.logmsg(l_module_name,
                 'WSH_DELIVERY_DETAILS_SPLITTER.TMS_DELIVERY_DETAIL_SPLIT exception has occured ',
                 wsh_debug_sv.c_excep_level);
            END IF;

        END;

        i := p_detail_tab.NEXT(i);

      END LOOP;
    END IF;

    IF l_number_of_errors > 0 THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    ELSIF l_number_of_warnings > 0 THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    ELSE
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    END IF;

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
  EXCEPTION

    WHEN OTHERS THEN
      --
      WSH_UTIL_CORE.default_handler(
		'WSH_DELIVERY_DETAILS_SPLITTER.TMS_DELIVERY_DETAIL_SPLIT', l_module_name);
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,
		'Unexpected error has occured. Oracle error message is '||
		SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
  END TMS_DELIVERY_DETAIL_SPLIT;

END WSH_DELIVERY_DETAILS_SPLITTER;

/
