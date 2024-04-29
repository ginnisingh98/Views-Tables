--------------------------------------------------------
--  DDL for Package Body WSH_WMS_LPN_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_WMS_LPN_GRP" as
/* $Header: WSHWLGPB.pls 120.14.12010000.2 2008/08/04 12:33:58 suppal ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30)    := 'WSH_WMS_LPN_GRP';

  PROCEDURE Handle_miss_info
  (  p_container_info_rec IN OUT NOCOPY
                           WSH_GLBL_VAR_STRCT_GRP.delivery_details_Rec_Type,
     x_return_status OUT NOCOPY varchar2
  );

--========================================================================
-- PROCEDURE : create_update_containers  Must be called only by WMS APIs
--
-- PARAMETERS: p_api_version           known api version error buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_in_rec                Record for caller,
--                                     and action_code ( CREATE,UPDATE,
--                                     UPDATE_NULL)
--         p_detail_info_tab           Table of attributes for the containers
--           x_OUT_rec                 not used (bms)
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Creates or updates a record in wsh_new_deliveries table with information
--             specified in p_delivery_info
--========================================================================
  PROCEDURE create_update_containers
  ( p_api_version            IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    p_commit                 IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status          OUT  NOCOPY VARCHAR2,
    x_msg_count              OUT  NOCOPY NUMBER,
    x_msg_data               OUT  NOCOPY VARCHAR2,
    p_detail_info_tab        IN  OUT NOCOPY
                        WSH_GLBL_VAR_STRCT_GRP.delivery_details_Attr_tbl_Type,
    p_IN_rec                 IN     WSH_GLBL_VAR_STRCT_GRP.detailInRecType,
    x_OUT_rec                OUT NOCOPY     WSH_GLBL_VAR_STRCT_GRP.detailOutRecType
  )
  IS
    --
l_debug_on BOOLEAN;
    --
    l_module_name CONSTANT   VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME ||
            '.' || 'CREATE_UPDATE_CONTAINERS';
    --
    l_return_status          VARCHAR2(1);
    l_api_version_number     CONSTANT NUMBER := 1.0;
    l_api_name               CONSTANT VARCHAR2(30):= 'create_update_containers';
    l_msg_count        NUMBER;
    l_msg_data         VARCHAR2(32767);
    l_param_name       VARCHAR2(100);
    l_in_param_null    BOOLEAN := FALSE;
    l_num_warnings     NUMBER := 0;
    l_num_errors       NUMBER := 0;
    i                  NUMBER;
    l_delivery_detail_id NUMBER;
    l_dummy            NUMBER;

    CURSOR  c_lock_container(v_lpn_id number) IS
    SELECT delivery_detail_id
    FROM wsh_delivery_details
    WHERE lpn_id = v_lpn_id AND
    --LPN reuse project
    released_status = 'X'
    FOR UPDATE NOWAIT;

    CURSOR c_lpn_exist (v_lpn_id NUMBER) IS
    SELECT 1
    FROM wsh_delivery_details
    WHERE lpn_id = v_lpn_id
    AND
    --LPN reuse project
    released_status = 'X';

    e_success          EXCEPTION;

  BEGIN
    --
    SAVEPOINT create_update_WSHWLGPB;
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
      --
      wsh_debug_sv.push (l_module_name);
      wsh_debug_sv.log (l_module_name,'p_api_version',p_api_version);
      wsh_debug_sv.log (l_module_name,'p_init_msg_list',p_init_msg_list);
      wsh_debug_sv.log (l_module_name,'p_commit',p_commit);
      wsh_debug_sv.log (l_module_name,'p_detail_info_tab.count',
                                                  p_detail_info_tab.count);
      wsh_debug_sv.log (l_module_name,'caller',p_IN_rec.caller);
      wsh_debug_sv.log (l_module_name,'action_code',p_IN_rec.action_code);
      wsh_debug_sv.log (l_module_name,'g_call_group_api',g_call_group_api);
      wsh_debug_sv.log (l_module_name,'g_update_to_containers',g_update_to_containers);
      --
    END IF;
    --
    IF NOT FND_API.Compatible_API_Call
      ( l_api_version_number,
        p_api_version,
        l_api_name,
        G_PKG_NAME
       )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --
    --


    IF p_IN_rec.caller IS NULL THEN
       l_param_name := 'Caller';
       l_in_param_null := TRUE;
    ELSIF p_IN_rec.action_code IS NULL THEN
       l_param_name := 'Action Code';
       l_in_param_null := TRUE;
    END IF;

    IF  l_in_param_null THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
      FND_MESSAGE.SET_TOKEN('FIELD_NAME',l_param_name);
      wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    --
    IF p_IN_rec.caller not like 'WMS%' THEN
       IF l_debug_on THEN
         --
         wsh_debug_sv.log(l_module_name,'Invalid Caller',p_IN_rec.caller);
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    IF p_detail_info_tab.count = 0
     OR (g_update_to_containers = 'N' AND g_call_group_api = 'N' )THEN
       RAISE e_success;
    END IF;

    g_caller := p_IN_rec.caller;

    IF p_in_rec.action_code = 'UPDATE_NULL' THEN --{
       i := p_detail_info_tab.FIRST;
       WHILE i IS NOT NULL LOOP --{
          IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'lpn_id',
                                             p_detail_info_tab(i).lpn_id);
          END IF;

          --lock the record

          BEGIN
             OPEN c_lock_container(p_detail_info_tab(i).lpn_id);
             FETCH c_lock_container INTO l_delivery_detail_id;
             CLOSE c_lock_container;
          EXCEPTION
             WHEN app_exception.application_exception or app_exception.record_lock_exception THEN
                FND_MESSAGE.SET_NAME('WSH', 'WSH_DLVB_LOCK_FAILED');
                FND_MESSAGE.SET_TOKEN('DEL_NAME', l_delivery_detail_id);
                WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
                RAISE FND_API.G_EXC_ERROR;
          END;

          UPDATE wsh_delivery_details
          SET lpn_id = NULL
          WHERE lpn_id = p_detail_info_tab(i).lpn_id AND
	  --LPN reuse project
	  released_status = 'X';

          IF SQL%ROWCOUNT <> 1 THEN
             FND_MESSAGE.SET_NAME('WSH','WSH_LPN_UPDATE_FAILED'); --bms new
             FND_MESSAGE.SET_TOKEN('LPNID',p_detail_info_tab(i).lpn_id);
             WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
             RAISE FND_API.G_EXC_ERROR;
          END IF;
          i := p_detail_info_tab.NEXT(i);
       END LOOP; --}

    ELSIF p_in_rec.action_code IN ( 'UPDATE','CREATE')  THEN --}{
       G_CALLBACK_REQUIRED := 'N';
       IF p_in_rec.action_code = 'UPDATE' THEN --{
          i := p_detail_info_tab.FIRST;
          WHILE i IS NOT NULL LOOP --{
             IF l_debug_on THEN
               wsh_debug_sv.log(l_module_name,'lpn_id',
                                                p_detail_info_tab(i).lpn_id);
             END IF;
             IF p_detail_info_tab(i).lpn_id IS NULL THEN
                IF l_debug_on THEN
                   wsh_debug_sv.logmsg(l_module_name,'lpn_id cannot be null');
                END IF;
                FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
                FND_MESSAGE.SET_TOKEN('FIELD_NAME','LPN_ID');
                WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
                RAISE FND_API.G_EXC_ERROR;
             END IF;

             BEGIN

                SELECT delivery_detail_id
                INTO p_detail_info_tab(i).delivery_detail_id
                FROM WSH_DELIVERY_DETAILS
                WHERE lpn_id = p_detail_info_tab(i).lpn_id AND
		--LPN reuse project
		released_status = 'X';


             EXCEPTION
                WHEN NO_DATA_FOUND THEN
                   IF l_debug_on THEN
                      wsh_debug_sv.log(l_module_name,'There are no records in wsh_delivery_details for lpn_id: ', p_detail_info_tab(i).lpn_id);
                   END IF;

                   FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_DETAIL'); --bmso new message
                   WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
                   RAISE FND_API.G_EXC_ERROR;
             END;
             IF p_IN_rec.caller <> WSH_GLBL_VAR_STRCT_GRP.c_skip_miss_info THEN

               --handle_miss_info is not used, when wsh_container_grp.update_container calls this API.

               IF l_debug_on THEN
                 wsh_debug_sv.log(l_module_name,'lpn_id',p_detail_info_tab(i).lpn_id);
                 wsh_debug_sv.log(l_module_name,'net_weight',p_detail_info_tab(i).net_weight);
                 wsh_debug_sv.log(l_module_name,'weight_uom_code',p_detail_info_tab(i).weight_uom_code);
                 wsh_debug_sv.log(l_module_name,'gross_weight',p_detail_info_tab(i).gross_weight);
                 wsh_debug_sv.log(l_module_name,'volume',p_detail_info_tab(i).volume);
                 wsh_debug_sv.log(l_module_name,'volume_uom_code',p_detail_info_tab(i).volume_uom_code);
                 wsh_debug_sv.log(l_module_name,'filled_volume',p_detail_info_tab(i).filled_volume);
               END IF;

               handle_miss_info(  p_container_info_rec => p_detail_info_tab(i),
                                  x_return_status      => l_return_status
                               );

               wsh_util_core.api_post_call(
                  p_return_status    => l_return_status,
                  x_num_warnings     => l_num_warnings,
                  x_num_errors       => l_num_errors);
             END IF;
             i := p_detail_info_tab.NEXT(i);
          END LOOP; --}
       ELSIF p_in_rec.action_code = 'CREATE' THEN --}{

          --check if the lpn_id exists then error out

          i:= p_detail_info_tab.FIRST;
          WHILE i IS NOT NULL LOOP --{

             IF l_debug_on THEN
               wsh_debug_sv.log(l_module_name,'lpn_id',p_detail_info_tab(i).lpn_id);
               wsh_debug_sv.log(l_module_name,'net_weight',p_detail_info_tab(i).net_weight);
               wsh_debug_sv.log(l_module_name,'weight_uom_code',p_detail_info_tab(i).weight_uom_code);
               wsh_debug_sv.log(l_module_name,'gross_weight',p_detail_info_tab(i).gross_weight);
               wsh_debug_sv.log(l_module_name,'volume',p_detail_info_tab(i).volume);
               wsh_debug_sv.log(l_module_name,'volume_uom_code',p_detail_info_tab(i).volume_uom_code);
               wsh_debug_sv.log(l_module_name,'filled_volume',p_detail_info_tab(i).filled_volume);
             END IF;

             OPEN c_lpn_exist(p_detail_info_tab(i).lpn_id);
             FETCH c_lpn_exist INTO l_dummy;
             CLOSE c_lpn_exist;

             IF l_dummy = 1 THEN
                FND_MESSAGE.SET_NAME('WSH','WSH_DUPLICATE_RECORD');
                WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
                RAISE FND_API.G_EXC_ERROR;
             END IF;

             i := p_detail_info_tab.NEXT(i);
          END LOOP; --}
       END IF ;--}
       wsh_delivery_details_grp.create_update_delivery_detail(
            p_api_version_number      =>  p_api_version,
            p_init_msg_list           =>  FND_API.G_FALSE,
            p_commit                  =>  FND_API.G_FALSE,
            x_return_status           =>  l_return_status,
            x_msg_count               =>  l_msg_count,
            x_msg_data                =>  l_msg_data,
            p_detail_info_tab         =>  p_detail_info_tab,
            p_IN_rec                  =>  p_in_rec,
            x_OUT_rec                 =>  x_out_rec
       );
       wsh_util_core.api_post_call(
          p_return_status    => l_return_status,
          x_num_warnings     => l_num_warnings,
          x_num_errors       => l_num_errors,
          p_msg_data      => l_msg_data);
    ELSE --}{
       IF l_debug_on THEN
         wsh_debug_sv.log(l_module_name,'Invalid Action Code',
                                                  p_IN_rec.action_code);
       END IF;
       FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_ACTION_CODE');
       FND_MESSAGE.SET_TOKEN('ACT_CODE',p_IN_rec.action_code);
       WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR,l_module_name);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF; --}

    IF l_num_errors > 0
    THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    ELSIF l_num_warnings > 0
    THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    ELSE
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    END IF;

    G_CALLBACK_REQUIRED := 'Y';
    g_caller := NULL;
    --

    IF FND_API.To_Boolean( p_commit ) THEN
       commit;
    END IF;

    FND_MSG_PUB.Count_And_Get (
      p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => FND_API.G_FALSE);
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
  EXCEPTION

    WHEN e_success THEN
      G_CALLBACK_REQUIRED := 'Y';
      g_caller := NULL;
      --g_update_to_container := 'N';
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      FND_MSG_PUB.Count_And_Get
        (
         p_count  => x_msg_count,
         p_data  =>  x_msg_data,
         p_encoded => FND_API.G_FALSE
        );

      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,'Success');
      END IF;
      --
    WHEN FND_API.G_EXC_ERROR THEN
      G_CALLBACK_REQUIRED := 'Y';
      g_caller := NULL;
      --g_update_to_container := 'N';
      ROLLBACK TO create_update_WSHWLGPB;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
        (
         p_count  => x_msg_count,
         p_data  =>  x_msg_data,
         p_encoded => FND_API.G_FALSE
        );

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      G_CALLBACK_REQUIRED := 'Y';
      g_caller := NULL;
      --g_update_to_container := 'N';
      ROLLBACK TO create_update_WSHWLGPB;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get
        (
         p_count  => x_msg_count,
         p_data  =>  x_msg_data,
         p_encoded => FND_API.G_FALSE
        );

      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      G_CALLBACK_REQUIRED := 'Y';
      g_caller := NULL;
      --g_update_to_container := 'N';
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      FND_MSG_PUB.Count_And_Get
        (
         p_count  => x_msg_count,
         p_data  =>  x_msg_data,
         p_encoded => FND_API.G_FALSE
        );

      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --
    WHEN OTHERS THEN
      G_CALLBACK_REQUIRED := 'Y';
      g_caller := NULL;
      --g_update_to_container := 'N';
      ROLLBACK TO create_update_WSHWLGPB;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_WMS_LPN_GRP.create_update_containers');
      FND_MSG_PUB.Count_And_Get
        (
         p_count  => x_msg_count,
         p_data  =>  x_msg_data,
         p_encoded => FND_API.G_FALSE
        );

      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --

  END create_update_containers;

--========================================================================
-- PROCEDURE : Handle_miss_info       This procedure is called from
--                                    create_update_containers and will
--                                    populte the fields contain null with
--                                    g_miss and converts all the g_miss to null--
-- PARAMETERS: p_container_info_rec    In/OUT record to be modified
--             x_return_status         return status
--
--========================================================================

  PROCEDURE Handle_miss_info
  (  p_container_info_rec IN OUT NOCOPY
                           WSH_GLBL_VAR_STRCT_GRP.delivery_details_Rec_Type,
     x_return_status OUT NOCOPY varchar2
  )
  IS
    --
l_debug_on BOOLEAN;
    --
    l_module_name CONSTANT   VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME ||
            '.' || 'HANDLE_MISS_INFO';
    --
    l_return_status          VARCHAR2(1);
    l_num_warnings     NUMBER;
    l_num_errors       NUMBER;

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
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    IF l_debug_on THEN
      --
      wsh_debug_sv.push (l_module_name);
      --
    END IF;
    --

    --p_container_info_rec.delivery_detail_id  := FND_API.G_MISS_NUM;
    p_container_info_rec.source_code  := FND_API.G_MISS_CHAR;
    p_container_info_rec.source_header_id  := FND_API.G_MISS_NUM;
    p_container_info_rec.source_line_id  := FND_API.G_MISS_NUM;
    p_container_info_rec.customer_id  := FND_API.G_MISS_NUM;
    p_container_info_rec.sold_to_contact_id  := FND_API.G_MISS_NUM;
    p_container_info_rec.inventory_item_id  := WSH_INTERFACE_EXT_GRP.Handle_missing_info(p_container_info_rec.inventory_item_id  );
    p_container_info_rec.item_description  := WSH_INTERFACE_EXT_GRP.Handle_missing_info(p_container_info_rec.item_description  );
    p_container_info_rec.hazard_class_id  := FND_API.G_MISS_NUM;
    p_container_info_rec.country_of_origin  := FND_API.G_MISS_CHAR;
    p_container_info_rec.classification  := FND_API.G_MISS_CHAR;
    p_container_info_rec.ship_from_location_id  := FND_API.G_MISS_NUM;
    p_container_info_rec.ship_to_location_id  := FND_API.G_MISS_NUM;
    p_container_info_rec.ship_to_contact_id  := FND_API.G_MISS_NUM;
    p_container_info_rec.ship_to_site_use_id  := FND_API.G_MISS_NUM;
    p_container_info_rec.deliver_to_location_id  := FND_API.G_MISS_NUM;
    p_container_info_rec.deliver_to_contact_id  := FND_API.G_MISS_NUM;
    p_container_info_rec.deliver_to_site_use_id  := FND_API.G_MISS_NUM;
    p_container_info_rec.intmed_ship_to_location_id  := FND_API.G_MISS_NUM;
    p_container_info_rec.intmed_ship_to_contact_id  := FND_API.G_MISS_NUM;
    p_container_info_rec.hold_code  := FND_API.G_MISS_CHAR;
    p_container_info_rec.ship_tolerance_above  := FND_API.G_MISS_NUM;
    p_container_info_rec.ship_tolerance_below  := FND_API.G_MISS_NUM;
    p_container_info_rec.requested_quantity  := FND_API.G_MISS_NUM;
    p_container_info_rec.shipped_quantity  := FND_API.G_MISS_NUM;
    p_container_info_rec.delivered_quantity  := FND_API.G_MISS_NUM;
    p_container_info_rec.requested_quantity_uom  := FND_API.G_MISS_CHAR;
    p_container_info_rec.subinventory  := WSH_INTERFACE_EXT_GRP.Handle_missing_info(p_container_info_rec.subinventory  );
    p_container_info_rec.revision  := WSH_INTERFACE_EXT_GRP.Handle_missing_info(p_container_info_rec.revision  );
    p_container_info_rec.lot_number  := WSH_INTERFACE_EXT_GRP.Handle_missing_info(p_container_info_rec.lot_number  );
    p_container_info_rec.customer_requested_lot_flag  := FND_API.G_MISS_CHAR;
    p_container_info_rec.serial_number  := WSH_INTERFACE_EXT_GRP.Handle_missing_info(p_container_info_rec.serial_number  );
    p_container_info_rec.locator_id  := WSH_INTERFACE_EXT_GRP.Handle_missing_info(p_container_info_rec.locator_id  );
    p_container_info_rec.date_requested  := FND_API.G_MISS_DATE;
    p_container_info_rec.date_scheduled  := FND_API.G_MISS_DATE;
    p_container_info_rec.master_container_item_id  := FND_API.G_MISS_NUM;
    p_container_info_rec.detail_container_item_id  := FND_API.G_MISS_NUM;
    p_container_info_rec.load_seq_number  := FND_API.G_MISS_NUM;
    p_container_info_rec.ship_method_code  := FND_API.G_MISS_CHAR;
    p_container_info_rec.carrier_id  := FND_API.G_MISS_NUM;
    p_container_info_rec.freight_terms_code  := FND_API.G_MISS_CHAR;
    p_container_info_rec.shipment_priority_code  := FND_API.G_MISS_CHAR;
    p_container_info_rec.fob_code  := FND_API.G_MISS_CHAR;
    p_container_info_rec.customer_item_id  := FND_API.G_MISS_NUM;
    p_container_info_rec.dep_plan_required_flag  := FND_API.G_MISS_CHAR;
    p_container_info_rec.customer_prod_seq  := FND_API.G_MISS_CHAR;
    p_container_info_rec.customer_dock_code  := FND_API.G_MISS_CHAR;
    p_container_info_rec.cust_model_serial_number  := FND_API.G_MISS_CHAR;
    p_container_info_rec.customer_job   := FND_API.G_MISS_CHAR;
    p_container_info_rec.customer_production_line  := FND_API.G_MISS_CHAR;
    p_container_info_rec.net_weight  := WSH_INTERFACE_EXT_GRP.Handle_missing_info(p_container_info_rec.net_weight  );
    p_container_info_rec.weight_uom_code  := WSH_INTERFACE_EXT_GRP.Handle_missing_info(p_container_info_rec.weight_uom_code  );
    p_container_info_rec.volume  := WSH_INTERFACE_EXT_GRP.Handle_missing_info(p_container_info_rec.volume  );
    p_container_info_rec.volume_uom_code  := WSH_INTERFACE_EXT_GRP.Handle_missing_info(p_container_info_rec.volume_uom_code  );
    p_container_info_rec.tp_attribute_category  := FND_API.G_MISS_CHAR;
    p_container_info_rec.tp_attribute1  := FND_API.G_MISS_CHAR;
    p_container_info_rec.tp_attribute2  := FND_API.G_MISS_CHAR;
    p_container_info_rec.tp_attribute3  := FND_API.G_MISS_CHAR;
    p_container_info_rec.tp_attribute4  := FND_API.G_MISS_CHAR;
    p_container_info_rec.tp_attribute5  := FND_API.G_MISS_CHAR;
    p_container_info_rec.tp_attribute6  := FND_API.G_MISS_CHAR;
    p_container_info_rec.tp_attribute7  := FND_API.G_MISS_CHAR;
    p_container_info_rec.tp_attribute8  := FND_API.G_MISS_CHAR;
    p_container_info_rec.tp_attribute9  := FND_API.G_MISS_CHAR;
    p_container_info_rec.tp_attribute10  := FND_API.G_MISS_CHAR;
    p_container_info_rec.tp_attribute11  := FND_API.G_MISS_CHAR;
    p_container_info_rec.tp_attribute12  := FND_API.G_MISS_CHAR;
    p_container_info_rec.tp_attribute13  := FND_API.G_MISS_CHAR;
    p_container_info_rec.tp_attribute14  := FND_API.G_MISS_CHAR;
    p_container_info_rec.tp_attribute15  := FND_API.G_MISS_CHAR;
    p_container_info_rec.attribute_category  := FND_API.G_MISS_CHAR;
    p_container_info_rec.attribute1  := FND_API.G_MISS_CHAR;
    p_container_info_rec.attribute2  := FND_API.G_MISS_CHAR;
    p_container_info_rec.attribute3  := FND_API.G_MISS_CHAR;
    p_container_info_rec.attribute4  := FND_API.G_MISS_CHAR;
    p_container_info_rec.attribute5  := FND_API.G_MISS_CHAR;
    p_container_info_rec.attribute6  := FND_API.G_MISS_CHAR;
    p_container_info_rec.attribute7  := FND_API.G_MISS_CHAR;
    p_container_info_rec.attribute8  := FND_API.G_MISS_CHAR;
    p_container_info_rec.attribute9  := FND_API.G_MISS_CHAR;
    p_container_info_rec.attribute10  := FND_API.G_MISS_CHAR;
    p_container_info_rec.attribute11  := FND_API.G_MISS_CHAR;
    p_container_info_rec.attribute12  := FND_API.G_MISS_CHAR;
    p_container_info_rec.attribute13  := FND_API.G_MISS_CHAR;
    p_container_info_rec.attribute14  := FND_API.G_MISS_CHAR;
    p_container_info_rec.attribute15  := FND_API.G_MISS_CHAR;
    p_container_info_rec.created_by  := FND_API.G_MISS_NUM;
    p_container_info_rec.creation_date  := FND_API.G_MISS_DATE;
    p_container_info_rec.last_update_date  := FND_API.G_MISS_DATE;
    p_container_info_rec.last_update_login  := FND_API.G_MISS_NUM;
    p_container_info_rec.last_updated_by  := FND_API.G_MISS_NUM;
    p_container_info_rec.program_application_id  := FND_API.G_MISS_NUM;
    p_container_info_rec.program_id  := FND_API.G_MISS_NUM;
    p_container_info_rec.program_update_date  := FND_API.G_MISS_DATE;
    p_container_info_rec.request_id  := FND_API.G_MISS_NUM;
    p_container_info_rec.mvt_stat_status  := FND_API.G_MISS_CHAR;
    p_container_info_rec.released_flag  := FND_API.G_MISS_CHAR;
    p_container_info_rec.organization_id  := WSH_INTERFACE_EXT_GRP.Handle_missing_info(p_container_info_rec.organization_id  );
    p_container_info_rec.transaction_temp_id  := FND_API.G_MISS_NUM;
    p_container_info_rec.ship_set_id  := FND_API.G_MISS_NUM;
    p_container_info_rec.arrival_set_id  := FND_API.G_MISS_NUM;
    p_container_info_rec.ship_model_complete_flag  := FND_API.G_MISS_CHAR;
    p_container_info_rec.top_model_line_id  := FND_API.G_MISS_NUM;
    p_container_info_rec.source_header_number  := FND_API.G_MISS_CHAR;
    p_container_info_rec.source_header_type_id  := FND_API.G_MISS_NUM;
    p_container_info_rec.source_header_type_name  := FND_API.G_MISS_CHAR;
    p_container_info_rec.cust_po_number  := FND_API.G_MISS_CHAR;
    p_container_info_rec.ato_line_id  := FND_API.G_MISS_NUM;
    p_container_info_rec.src_requested_quantity  := FND_API.G_MISS_NUM;
    p_container_info_rec.src_requested_quantity_uom  := FND_API.G_MISS_CHAR;
    p_container_info_rec.move_order_line_id  := FND_API.G_MISS_NUM;
    p_container_info_rec.cancelled_quantity  := FND_API.G_MISS_NUM;
    p_container_info_rec.quality_control_quantity  := FND_API.G_MISS_NUM;
    p_container_info_rec.cycle_count_quantity  := FND_API.G_MISS_NUM;
    p_container_info_rec.tracking_number  := FND_API.G_MISS_CHAR;
    p_container_info_rec.movement_id  := FND_API.G_MISS_NUM;
    p_container_info_rec.shipping_instructions  := FND_API.G_MISS_CHAR;
    p_container_info_rec.packing_instructions  := FND_API.G_MISS_CHAR;
    p_container_info_rec.project_id  := FND_API.G_MISS_NUM;
    p_container_info_rec.task_id  := FND_API.G_MISS_NUM;
    p_container_info_rec.org_id  := FND_API.G_MISS_NUM;
    p_container_info_rec.oe_interfaced_flag  := FND_API.G_MISS_CHAR;
    p_container_info_rec.split_from_detail_id  := FND_API.G_MISS_NUM;
    p_container_info_rec.inv_interfaced_flag  := FND_API.G_MISS_CHAR;
    p_container_info_rec.source_line_number  := FND_API.G_MISS_CHAR;
    p_container_info_rec.inspection_flag  := FND_API.G_MISS_CHAR;
    p_container_info_rec.released_status  := FND_API.G_MISS_CHAR;
    p_container_info_rec.container_flag  := FND_API.G_MISS_CHAR;
    p_container_info_rec.container_type_code  := WSH_INTERFACE_EXT_GRP.Handle_missing_info(p_container_info_rec.container_type_code  );
    p_container_info_rec.container_name  := WSH_INTERFACE_EXT_GRP.Handle_missing_info(p_container_info_rec.container_name  );
    p_container_info_rec.fill_percent  := WSH_INTERFACE_EXT_GRP.Handle_missing_info(p_container_info_rec.fill_percent  );
    p_container_info_rec.gross_weight  := WSH_INTERFACE_EXT_GRP.Handle_missing_info(p_container_info_rec.gross_weight  );
    p_container_info_rec.master_serial_number  := WSH_INTERFACE_EXT_GRP.Handle_missing_info(p_container_info_rec.master_serial_number  );
    p_container_info_rec.maximum_load_weight  := WSH_INTERFACE_EXT_GRP.Handle_missing_info(p_container_info_rec.maximum_load_weight  );
    p_container_info_rec.maximum_volume  := WSH_INTERFACE_EXT_GRP.Handle_missing_info(p_container_info_rec.maximum_volume  );
    p_container_info_rec.minimum_fill_percent  := WSH_INTERFACE_EXT_GRP.Handle_missing_info(p_container_info_rec.minimum_fill_percent  );
    p_container_info_rec.seal_code  := FND_API.G_MISS_CHAR;
    p_container_info_rec.unit_number  := FND_API.G_MISS_CHAR;
    p_container_info_rec.unit_price  := FND_API.G_MISS_NUM;
    p_container_info_rec.currency_code  := FND_API.G_MISS_CHAR;
    p_container_info_rec.freight_class_cat_id  := FND_API.G_MISS_NUM;
    p_container_info_rec.commodity_code_cat_id  := FND_API.G_MISS_NUM;
    p_container_info_rec.preferred_grade       := FND_API.G_MISS_CHAR;
    p_container_info_rec.preferred_grade       := FND_API.G_MISS_CHAR;
    p_container_info_rec.src_requested_quantity2  := FND_API.G_MISS_NUM;
    p_container_info_rec.src_requested_quantity_uom2  := FND_API.G_MISS_CHAR;
    p_container_info_rec.requested_quantity2        := FND_API.G_MISS_NUM;
    p_container_info_rec.shipped_quantity2         := FND_API.G_MISS_NUM;
    p_container_info_rec.delivered_quantity2  := FND_API.G_MISS_NUM;
    p_container_info_rec.cancelled_quantity2  := FND_API.G_MISS_NUM;
    p_container_info_rec.quality_control_quantity2  := FND_API.G_MISS_NUM;
    p_container_info_rec.cycle_count_quantity2  := FND_API.G_MISS_NUM;
    p_container_info_rec.requested_quantity_uom2  := FND_API.G_MISS_CHAR;
    p_container_info_rec.lpn_id  := WSH_INTERFACE_EXT_GRP.Handle_missing_info(p_container_info_rec.lpn_id  );
    p_container_info_rec.pickable_flag  := FND_API.G_MISS_CHAR;
    p_container_info_rec.original_subinventory  := FND_API.G_MISS_CHAR;
    p_container_info_rec.to_serial_number    := WSH_INTERFACE_EXT_GRP.Handle_missing_info(p_container_info_rec.to_serial_number    );
    p_container_info_rec.picked_quantity  := FND_API.G_MISS_NUM;
    p_container_info_rec.picked_quantity2  := FND_API.G_MISS_NUM;
    p_container_info_rec.received_quantity  := FND_API.G_MISS_NUM;
    p_container_info_rec.received_quantity2  := FND_API.G_MISS_NUM;
    p_container_info_rec.source_line_set_id  := FND_API.G_MISS_NUM;
    p_container_info_rec.batch_id    := FND_API.G_MISS_NUM;
    --p_container_info_rec.ROWID  := FND_API.G_MISS_CHAR;
    p_container_info_rec.transaction_id   := FND_API.G_MISS_NUM;
    p_container_info_rec.VENDOR_ID   := FND_API.G_MISS_NUM;
    p_container_info_rec.SHIP_FROM_SITE_ID   := FND_API.G_MISS_NUM;
    p_container_info_rec.LINE_DIRECTION   := FND_API.G_MISS_CHAR;
    p_container_info_rec.PARTY_ID   := FND_API.G_MISS_NUM;
    p_container_info_rec.ROUTING_REQ_ID  := FND_API.G_MISS_NUM;
    p_container_info_rec.SHIPPING_CONTROL  := FND_API.G_MISS_CHAR;
    p_container_info_rec.SOURCE_BLANKET_REFERENCE_ID  := FND_API.G_MISS_NUM;
    p_container_info_rec.SOURCE_BLANKET_REFERENCE_NUM  := FND_API.G_MISS_NUM;
    p_container_info_rec.PO_SHIPMENT_LINE_ID   := FND_API.G_MISS_NUM;
    p_container_info_rec.PO_SHIPMENT_LINE_NUMBER  := FND_API.G_MISS_NUM;
    p_container_info_rec.RETURNED_QUANTITY    := FND_API.G_MISS_NUM;
    p_container_info_rec.RETURNED_QUANTITY2   := FND_API.G_MISS_NUM;
    p_container_info_rec.RCV_SHIPMENT_LINE_ID   := FND_API.G_MISS_NUM;
    p_container_info_rec.SOURCE_LINE_TYPE_CODE  := FND_API.G_MISS_CHAR;
    p_container_info_rec.SUPPLIER_ITEM_NUMBER   := FND_API.G_MISS_CHAR;
    p_container_info_rec.IGNORE_FOR_PLANNING    := FND_API.G_MISS_CHAR;
    p_container_info_rec.EARLIEST_PICKUP_DATE   := FND_API.G_MISS_DATE;
    p_container_info_rec.LATEST_PICKUP_DATE     := FND_API.G_MISS_DATE;
    p_container_info_rec.EARLIEST_DROPOFF_DATE  := FND_API.G_MISS_DATE;
    p_container_info_rec.LATEST_DROPOFF_DATE    := FND_API.G_MISS_DATE;
    p_container_info_rec.REQUEST_DATE_TYPE_CODE  := FND_API.G_MISS_CHAR;
    p_container_info_rec.tp_delivery_detail_id   := FND_API.G_MISS_NUM;
    p_container_info_rec.source_document_type_id  := FND_API.G_MISS_NUM;
    p_container_info_rec.unit_weight    := WSH_INTERFACE_EXT_GRP.Handle_missing_info(p_container_info_rec.unit_weight    );
    p_container_info_rec.unit_volume    := WSH_INTERFACE_EXT_GRP.Handle_missing_info(p_container_info_rec.unit_volume    );
    p_container_info_rec.filled_volume  := WSH_INTERFACE_EXT_GRP.Handle_missing_info(p_container_info_rec.filled_volume  );
    p_container_info_rec.wv_frozen_flag  := FND_API.G_MISS_CHAR;
    p_container_info_rec.mode_of_transport  := FND_API.G_MISS_CHAR;
    p_container_info_rec.service_level    := FND_API.G_MISS_CHAR;
    p_container_info_rec.po_revision_number  := FND_API.G_MISS_NUM;
    p_container_info_rec.release_revision_number  := FND_API.G_MISS_NUM;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
  EXCEPTION

    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_WMS_LPN_GRP.Handle_miss_info');
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --

  END Handle_miss_info;

--========================================================================
-- PROCEDURE : Delivery_Detail_Action  Must be called only by WMS APIs
--
-- PARAMETERS: p_api_version           known api version error buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_lpn_id_tbl            PLSQL table of LPN Ids for perform
--                                     any of the actions 'PACK', 'UNPACK'
--                                     'ASSIGN', 'UNASSIGN'.
--             p_del_det_id_tbl        PLSQL table of non-container delivery
--                                     lines to perform the same actions as above
--             p_action_prms           Contains actions related parameters
--                                     like action_code that can take any of the--                                     four values mentioned above.
--                                     caller should be something like 'WMS%'
--                                     lpn_rec must be populated for actions
--                                     'PACK' or 'UNPACK'
--            x_defaults               not used currenlty.
--            x_action_out_rec         not used currenlty.
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Performs any of the four actions as mentioned above i.e. 'PACK', 'UNPACK'
--             or 'ASSIGN', 'UNASSIGN'.
--========================================================================

  PROCEDURE Delivery_Detail_Action
  (
    p_api_version_number        IN         NUMBER,
    p_init_msg_list             IN         VARCHAR2,
    p_commit                    IN         VARCHAR2,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    p_lpn_id_tbl                IN         wsh_util_core.id_tab_type,
    p_del_det_id_tbl            IN         wsh_util_core.id_tab_type,
    p_action_prms               IN         WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type,
    x_defaults                  OUT NOCOPY WSH_GLBL_VAR_STRCT_GRP.dd_default_parameters_rec_type,
    x_action_out_rec            OUT NOCOPY WSH_GLBL_VAR_STRCT_GRP.dd_action_out_rec_type
  )
  IS
  --{

      cursor l_lpn_exists_csr(p_lpn_id IN NUMBER) is
      select 'X'
      from   wsh_delivery_details
      where  lpn_id = p_lpn_id
      --LPN Reuse project
      and    released_status = 'X';

      cursor l_get_detail_csr(p_lpn_id IN NUMBER) is
      select delivery_detail_id,
             inventory_item_id
      from   wsh_delivery_details
      where  lpn_id = p_lpn_id
      --LPN Reuse project
      and    released_status = 'X';

      CURSOR l_det_id_csr(p_detail_id IN NUMBER) IS
      SELECT released_status,
             organization_id,
             container_flag,
             source_code,
             delivery_detail_id,
             lpn_id,
             customer_id,
             inventory_item_id,
             ship_from_location_id,
             ship_to_location_id,
             intmed_ship_to_location_id,
             date_requested,
             date_scheduled,
             ship_method_code,
             carrier_id,
             shipping_control,
             party_id,
             line_direction,
             source_line_id
      FROM   wsh_delivery_details
      WHERE  delivery_detail_id = p_detail_id;

      CURSOR l_det_lpn_id_csr(p_lpn_id IN NUMBER) IS
      SELECT wdd.released_status,
             wdd.organization_id,
             wdd.container_flag,
             wdd.source_code,
             wdd.delivery_detail_id,
             wdd.lpn_id,
             wdd.customer_id,
             wdd.inventory_item_id,
             wdd.ship_from_location_id,
             wdd.ship_to_location_id,
             wdd.intmed_ship_to_location_id,
             wdd.date_requested,
             wdd.date_scheduled,
             wdd.ship_method_code,
             wdd.carrier_id,
             wdd.shipping_control,
             wdd.party_id,
             wdd.line_direction,
             wdd.source_line_id,
             wda.delivery_id,
             wda.parent_delivery_detail_id
      FROM   wsh_delivery_details wdd,
             wsh_delivery_assignments wda
      WHERE  wdd.lpn_id = p_lpn_id
      and    nvl(wda.type,'S') in ('S', 'C')
      and    wdd.delivery_detail_id = wda.delivery_detail_id
      --LPN Reuse project
      and    wdd.released_status = 'X';

      l_delivery_id NUMBER;
      l_del_det_id_tbl wsh_util_core.id_tab_type;
      l_lpn_exists VARCHAR2(1);
      l_call_for_update_flag BOOLEAN := FALSE;
      l_calc_fill_pc_flag    BOOLEAN := FALSE;
      l_update_sub_loc_flag  BOOLEAN := FALSE;
      l_cont_fill_pc         NUMBER;
      l_fill_status          VARCHAR2(10);
      l_action_prms WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type;
      l_return_status          VARCHAR2(1);
      l_api_version_number     CONSTANT NUMBER := 1.0;
      l_api_name               CONSTANT VARCHAR2(30):= 'create_update_containers';
      l_msg_count        NUMBER;
      l_msg_data         VARCHAR2(32767);
      l_param_name       VARCHAR2(100);
      l_raise_error_flag BOOLEAN := FALSE;
      l_num_warnings     NUMBER := 0;
      l_num_errors       NUMBER := 0;
      i                  NUMBER;
      j                  NUMBER;
      k                  NUMBER;
      l_index            NUMBER;
      l_detail_info_tab  WSH_GLBL_VAR_STRCT_GRP.delivery_details_Attr_tbl_Type;

      l_cr_up_in_rec      WSH_GLBL_VAR_STRCT_GRP.detailInRecType;
      l_cr_up_out_rec     WSH_GLBL_VAR_STRCT_GRP.detailOutRecType;
      l_exist_detail_id   NUMBER;
      l_exist_cnt_item_id   NUMBER;

      l_rec_attr_tab WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type;
      l_action_out_rec WSH_GLBL_VAR_STRCT_GRP.dd_action_out_rec_type;
      l_dummy_defaults    WSH_GLBL_VAR_STRCT_GRP.dd_default_parameters_rec_type;

      l_lpn_in_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_in_rec_type;
      l_lpn_out_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_out_rec_type;




  --}
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELIVERY_DETAIL_ACTION';
  --
  BEGIN
  --{
  --
      --
      l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
      --
      IF l_debug_on IS NULL
      THEN
          l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
      END IF;
      --
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.push(l_module_name);
          --
          WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION_NUMBER',P_API_VERSION_NUMBER);
          WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
          WSH_DEBUG_SV.log(l_module_name,'P_COMMIT',P_COMMIT);
          WSH_DEBUG_SV.log(l_module_name,'p_action_prms.caller',p_action_prms.caller);
          WSH_DEBUG_SV.log(l_module_name,'p_action_prms.action_code',p_action_prms.action_code);
          WSH_DEBUG_SV.log(l_module_name,'Count of lpn_id tbl is',p_lpn_id_tbl.count);
          WSH_DEBUG_SV.log(l_module_name,'Count of delivery_detail_id tbl is',p_del_det_id_tbl.count);
      END IF;
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

      --
      IF NOT FND_API.COMPATIBLE_API_CALL
        ( l_api_version_number,
          p_api_version_number,
          l_api_name,
          G_PKG_NAME
         )
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      --
      IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
      END IF;
      --

      IF p_action_prms.caller IS NULL THEN
         l_param_name := 'Caller';
         l_raise_error_flag := TRUE;
      ELSIF p_action_prms.action_code IS NULL THEN
         l_param_name := 'Action Code';
         l_raise_error_flag := TRUE;
      END IF;

      IF  l_raise_error_flag THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME',l_param_name);
        wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF NOT (p_action_prms.caller like 'WMS%') THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF p_action_prms.action_code NOT IN ('PACK', 'UNPACK', 'ASSIGN', 'UNASSIGN', 'DELETE') THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_ACTION_CODE');
        FND_MESSAGE.SET_TOKEN('ACT_CODE',p_action_prms.action_code);
        wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (g_call_group_api = 'N') THEN
        -- no need to do anything.
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        return;
      END IF;

      g_caller := p_action_prms.caller;
      g_callback_required := 'N';

      l_action_prms                            := p_action_prms;

      savepoint DEL_DETAIL_ACTION_WMS_GRP;

      IF p_action_prms.action_code = 'PACK' THEN
      --{
          open  l_lpn_exists_csr(p_action_prms.lpn_rec.lpn_id);
          fetch l_lpn_exists_csr into l_lpn_exists;
          close l_lpn_exists_csr;

          l_detail_info_tab(1)  := l_action_prms.lpn_rec;

          l_cr_up_in_rec.caller := l_action_prms.caller;

          IF l_lpn_exists IS NULL THEN
            l_cr_up_in_rec.action_code := 'CREATE';

            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_GRP.CREATE_UPDATE_DELIVERY_DETAIL',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            wsh_delivery_details_grp.create_update_delivery_detail(
              p_api_version_number      =>  p_api_version_number,
              p_init_msg_list           =>  FND_API.G_FALSE,
              p_commit                  =>  FND_API.G_FALSE,
              x_return_status           =>  l_return_status,
              x_msg_count               =>  l_msg_count,
              x_msg_data                =>  l_msg_data,
              p_detail_info_tab         =>  l_detail_info_tab,
              p_IN_rec                  =>  l_cr_up_in_rec,
              x_OUT_rec                 =>  l_cr_up_out_rec
            );
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            wsh_util_core.api_post_call(
              p_return_status => l_return_status,
              x_num_warnings  => l_num_warnings,
              x_num_errors    => l_num_errors,
              p_msg_data      => l_msg_data
              );

            l_calc_fill_pc_flag   := TRUE;
            l_update_sub_loc_flag := TRUE;
          ELSE

            l_cr_up_in_rec.action_code := 'UPDATE';
            --l_call_for_update_flag := TRUE;
          END IF;

      --}
      --ELSIF p_action_prms.action_code = 'UNPACK' THEN
      --{
          --l_call_for_update_flag := TRUE;
      --}
      END IF;
      --
      IF (p_action_prms.action_code IN ('PACK', 'UNPACK')) THEN
        open  l_get_detail_csr(p_action_prms.lpn_rec.lpn_id);
        fetch l_get_detail_csr into l_exist_detail_id, l_exist_cnt_item_id;
        close l_get_detail_csr;
      END IF;

      IF (p_lpn_id_tbl.count = 0 AND p_del_det_id_tbl.count = 0) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      j := 0;
      k := 0;

      IF (p_lpn_id_tbl.count > 0) THEN
      --{
          --Build the records to pass to the core group api
          l_index := p_lpn_id_tbl.FIRST;
          WHILE l_index IS NOT NULL
          LOOP
              --
              l_delivery_id := null;
              --
              FOR l_det_lpn_id_rec in l_det_lpn_id_csr(p_lpn_id_tbl(l_index)) LOOP
              --{
                  IF ( p_action_prms.action_code in ('PACK', 'ASSIGN', 'UNASSIGN')
                       or
                       ( p_action_prms.action_code = 'DELETE'
                         and l_det_lpn_id_rec.delivery_id is not null
                       )
                       or
                       ( p_action_prms.action_code = 'UNPACK'
                         and l_det_lpn_id_rec.parent_delivery_detail_id is not null
                       )
                     )
                  THEN
                  --{
                      j := j + 1;
                      l_rec_attr_tab(j).released_status  := l_det_lpn_id_rec.released_status;
                      l_rec_attr_tab(j).organization_id  := l_det_lpn_id_rec.organization_id;
                      l_rec_attr_tab(j).container_flag  := l_det_lpn_id_rec.container_flag;
                      l_rec_attr_tab(j).source_code  := l_det_lpn_id_rec.source_code;
                      l_rec_attr_tab(j).delivery_detail_id  := l_det_lpn_id_rec.delivery_detail_id;
                      l_rec_attr_tab(j).lpn_id  := l_det_lpn_id_rec.lpn_id;
                      l_rec_attr_tab(j).CUSTOMER_ID  := l_det_lpn_id_rec.CUSTOMER_ID;
                      l_rec_attr_tab(j).INVENTORY_ITEM_ID  := l_det_lpn_id_rec.INVENTORY_ITEM_ID;
                      l_rec_attr_tab(j).SHIP_FROM_LOCATION_ID  := l_det_lpn_id_rec.SHIP_FROM_LOCATION_ID;
                      l_rec_attr_tab(j).SHIP_TO_LOCATION_ID  := l_det_lpn_id_rec.SHIP_TO_LOCATION_ID;
                      l_rec_attr_tab(j).INTMED_SHIP_TO_LOCATION_ID  := l_det_lpn_id_rec.INTMED_SHIP_TO_LOCATION_ID;
                      l_rec_attr_tab(j).DATE_REQUESTED  := l_det_lpn_id_rec.DATE_REQUESTED;
                      l_rec_attr_tab(j).DATE_SCHEDULED  := l_det_lpn_id_rec.DATE_SCHEDULED;
                      l_rec_attr_tab(j).SHIP_METHOD_CODE  := l_det_lpn_id_rec.SHIP_METHOD_CODE;
                      l_rec_attr_tab(j).CARRIER_ID  := l_det_lpn_id_rec.CARRIER_ID;
                      l_rec_attr_tab(j).shipping_control  := l_det_lpn_id_rec.shipping_control;
                      l_rec_attr_tab(j).party_id  := l_det_lpn_id_rec.party_id;
                      l_rec_attr_tab(j).line_direction  := l_det_lpn_id_rec.line_direction;
                      l_rec_attr_tab(j).source_line_id  := l_det_lpn_id_rec.source_line_id;
                  --}
                  END IF;
                  --
                  --
                  IF (p_action_prms.action_code = 'DELETE') THEN
                  --{
                      --
                      k := k + 1;
                      l_del_det_id_tbl(k) := l_det_lpn_id_rec.delivery_detail_id;
                      --
                  --}
                  END IF;
                  --
              --}
              END LOOP;
              --
              l_index := p_lpn_id_tbl.NEXT(l_index);
              --
          END LOOP;
      --}
      END IF;
      --
      -- Now checking the size of p_del_det_id_tbl
      --
      j := 0;

      IF (p_del_det_id_tbl.count > 0) THEN
      --{
          --Build the records to pass to the core group api
          l_index := p_del_det_id_tbl.FIRST;
          WHILE l_index IS NOT NULL
          LOOP
              j := j + 1;
              OPEN l_det_id_csr(p_del_det_id_tbl(l_index));
              FETCH l_det_id_csr
              INTO l_rec_attr_tab(j).released_status,
                   l_rec_attr_tab(j).organization_id,
                   l_rec_attr_tab(j).container_flag,
                   l_rec_attr_tab(j).source_code,
                   l_rec_attr_tab(j).delivery_detail_id,
                   l_rec_attr_tab(j).lpn_id,
                   l_rec_attr_tab(j).CUSTOMER_ID,
                   l_rec_attr_tab(j).INVENTORY_ITEM_ID,
                   l_rec_attr_tab(j).SHIP_FROM_LOCATION_ID,
                   l_rec_attr_tab(j).SHIP_TO_LOCATION_ID,
                   l_rec_attr_tab(j).INTMED_SHIP_TO_LOCATION_ID,
                   l_rec_attr_tab(j).DATE_REQUESTED,
                   l_rec_attr_tab(j).DATE_SCHEDULED,
                   l_rec_attr_tab(j).SHIP_METHOD_CODE,
                   l_rec_attr_tab(j).CARRIER_ID,
                   l_rec_attr_tab(j).shipping_control,
                   l_rec_attr_tab(j).party_id,
                   l_rec_attr_tab(j).line_direction,
                   l_rec_attr_tab(j).source_line_id;

              IF l_det_id_csr%NOTFOUND THEN
                 CLOSE l_det_id_csr;
                 RAISE FND_API.G_EXC_ERROR;
              END IF;
              --
              CLOSE l_det_id_csr;
              --
              l_index := p_del_det_id_tbl.NEXT(l_index);
              --
          END LOOP;
      --}
      END IF;

      IF ( l_rec_attr_tab.count > 0) THEN
      --{

          l_action_prms.caller                     := RTRIM(p_action_prms.caller);
          l_action_prms.action_Code                := RTRIM(p_action_prms.action_Code);
          l_action_prms.delivery_name              := RTRIM(p_action_prms.delivery_name);
          l_action_prms.wv_override_flag           := RTRIM(p_action_prms.wv_override_flag);
          l_action_prms.container_name             := RTRIM(p_action_prms.lpn_rec.container_name);
          l_action_prms.container_flag             := RTRIM(p_action_prms.container_flag);
          l_action_prms.delivery_flag              := RTRIM(p_action_prms.delivery_flag);
          l_action_prms.container_instance_id      := l_exist_detail_id;
          l_action_prms.lpn_rec.delivery_detail_id := l_exist_detail_id;

          IF l_action_prms.action_code = 'DELETE' THEN
            l_action_prms.action_Code  := 'UNASSIGN';
          END IF;

          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_GRP.DELIVERY_DETAIL_ACTION',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          wsh_delivery_details_grp.Delivery_Detail_Action(
            p_api_version_number      => p_api_version_number,
            p_init_msg_list           => FND_API.G_FALSE,
            p_commit                  => FND_API.G_FALSE,
            x_return_status           => l_return_status,
            x_msg_count               => l_msg_count,
            x_msg_data                => l_msg_data,
            p_rec_attr_tab            => l_rec_attr_tab,
            p_action_prms             => l_action_prms,
            x_defaults                => l_dummy_defaults,
            x_action_out_rec          => l_action_out_rec
            );
          --
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          wsh_util_core.api_post_call(
            p_return_status => l_return_status,
            x_num_warnings  => l_num_warnings,
            x_num_errors    => l_num_errors,
            p_msg_data      => l_msg_data
            );

      --}
      END IF;


      IF (l_call_for_update_flag) THEN
      --{
          --
          l_detail_info_tab(1)  := l_action_prms.lpn_rec;
          l_cr_up_in_rec.caller := l_action_prms.caller;
          l_cr_up_in_rec.action_code := 'UPDATE';

          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_GRP.CREATE_UPDATE_DELIVERY_DETAIL',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          wsh_delivery_details_grp.create_update_delivery_detail(
            p_api_version_number      =>  p_api_version_number,
            p_init_msg_list           =>  FND_API.G_FALSE,
            p_commit                  =>  FND_API.G_FALSE,
            x_return_status           =>  l_return_status,
            x_msg_count               =>  l_msg_count,
            x_msg_data                =>  l_msg_data,
            p_detail_info_tab         =>  l_detail_info_tab,
            p_IN_rec                  =>  l_cr_up_in_rec,
            x_OUT_rec                 =>  l_cr_up_out_rec
            );
          --
          --
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          wsh_util_core.api_post_call(
            p_return_status => l_return_status,
            x_num_warnings  => l_num_warnings,
            x_num_errors    => l_num_errors,
            p_msg_data      => l_msg_data
            );
          --
      --}
      END IF;
      --
      --
      IF (l_update_sub_loc_flag) THEN
      --{
          --
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_ACTIONS.UPDATE_CHILD_INV_INFO',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          WSH_CONTAINER_ACTIONS.Update_child_inv_info(
            p_container_id  => l_exist_detail_id,
            p_locator_id    => p_action_prms.lpn_rec.locator_id,
            p_subinventory  => p_action_prms.lpn_rec.subinventory,
            x_return_status => l_return_status
           );
          --
          --
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          wsh_util_core.api_post_call(
            p_return_status => l_return_status,
            x_num_warnings  => l_num_warnings,
            x_num_errors    => l_num_errors
            );
          --
      --}
      END IF;
      --
      -- So that pvt APIs can insert into the global temp if required
      g_callback_required := 'Y';
      --
      IF (l_calc_fill_pc_flag AND l_exist_cnt_item_id IS NOT NULL) THEN
      --{
          --
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TPA_CONTAINER_PKG.CALC_CONT_FILL_PC',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          WSH_TPA_CONTAINER_PKG.Calc_Cont_Fill_Pc (
            l_exist_detail_id,
            'Y',
            NULL,
            l_cont_fill_pc,
            l_return_status);

          --
          --
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          wsh_util_core.api_post_call(
            p_return_status => l_return_status,
            x_num_warnings  => l_num_warnings,
            x_num_errors    => l_num_errors
            );
          --
      --}
      END IF;

      IF (p_action_prms.action_code IN ('PACK', 'UNPACK')
          AND l_exist_cnt_item_id IS NOT NULL) THEN
      --{
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CHECK_FILL_PC',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          WSH_WV_UTILS.Check_Fill_Pc (
            p_container_instance_id => l_exist_detail_id,
            x_fill_status           => l_fill_status,
            x_return_status         => l_return_status);
          --
          --
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          wsh_util_core.api_post_call(
            p_return_status => l_return_status,
            x_num_warnings  => l_num_warnings,
            x_num_errors    => l_num_errors
            );
          --
          IF (l_fill_status = 'O') THEN
          --{
              FND_MESSAGE.SET_NAME('WSH', 'WSH_CONT_OVERPACKED');
              FND_MESSAGE.SET_TOKEN('CONT_NAME', p_action_prms.lpn_rec.container_name);
              wsh_util_core.add_message(wsh_util_core.g_ret_sts_warning);
              l_num_warnings := l_num_warnings + 1;
          --}
          ELSIF (l_fill_status = 'U') THEN
          --{
              FND_MESSAGE.SET_NAME('WSH', 'WSH_CONT_OVERPACKED');
              FND_MESSAGE.SET_TOKEN('CONT_NAME', p_action_prms.lpn_rec.container_name);
              wsh_util_core.add_message(wsh_util_core.g_ret_sts_warning);
              l_num_warnings := l_num_warnings + 1;
          --}
          END IF;
          --
      --}
      END IF;

      IF (p_action_prms.action_code = 'DELETE' and l_del_det_id_tbl.count > 0) THEN
      --{
          l_index := l_del_det_id_tbl.FIRST;
          WHILE l_index IS NOT NULL
          LOOP
              --
              --
              -- Debug Statements
              --
              IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_GRP.DELIVERY_DETAIL_ACTION',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;
              --
              wsh_container_actions.delete_containers (
                p_container_id  => l_del_det_id_tbl(l_index),
                x_return_status => l_return_status);
              --
              --
              -- Debug Statements
              --
              IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;
              --
              wsh_util_core.api_post_call(
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors);

              l_index := l_del_det_id_tbl.NEXT(l_index);
              --
          END LOOP;
          --
      --}
      END IF;

      IF (g_callback_required = 'Y') THEN
      --{
          --
          -- Debug Statements
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
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          WSH_UTIL_CORE.API_POST_CALL
            (
              p_return_status    => l_return_status,
              x_num_warnings     => l_num_warnings,
              x_num_errors       => l_num_errors
            );
      --}
      END IF;


      IF l_num_errors > 0 THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_num_warnings > 0 THEN
        RAISE WSH_UTIL_CORE.G_EXC_WARNING;
      ELSE
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      END IF;


      IF FND_API.To_Boolean( p_commit ) THEN
        commit;
      END IF;

      FND_MSG_PUB.Count_And_Get (
        p_count => x_msg_count,
        p_data  => x_msg_data,
        p_encoded => FND_API.G_FALSE);

      --
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      --
  --}
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  EXCEPTION
  --{
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO DEL_DETAIL_ACTION_WMS_GRP;
      g_callback_required := 'N';
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
        (
         p_count  => x_msg_count,
         p_data  =>  x_msg_data,
         p_encoded => FND_API.G_FALSE
        );
      --
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO DEL_DETAIL_ACTION_WMS_GRP;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get
        (
         p_count  => x_msg_count,
         p_data  =>  x_msg_data,
         p_encoded => FND_API.G_FALSE
        );
      --
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      END IF;
      --
      IF (g_callback_required = 'Y') THEN
      --{
          --
          -- Debug Statements
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
          IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR,
                                  WSH_UTIL_CORE.G_RET_STS_ERROR)
             )
          THEN
            x_return_status := l_return_status;
          END IF;

      --}
      END IF;
      --
      FND_MSG_PUB.Count_And_Get
        (
         p_count  => x_msg_count,
         p_data  =>  x_msg_data,
         p_encoded => FND_API.G_FALSE
        );
      --
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --
    WHEN OTHERS THEN
      ROLLBACK TO DEL_DETAIL_ACTION_WMS_GRP;
      g_callback_required := 'N';
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      WSH_UTIL_CORE.default_handler('WSH_INTERFACE_GRP.Delivery_Detail_Action');
      --
  --}
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
  END IF;
  --
  END Delivery_Detail_Action;

--========================================================================
-- PROCEDURE : Check_purge             Called only by WMS APIs
--
-- PARAMETERS: p_api_version           known api version error buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--            x_action_out_rec         not used currenlty.
-- COMMENT   : Validates if the container records identified by
--             p_lpn_rec.lpn_ids, are purgable.  It populates the same table
--             with eligible records.
--========================================================================

  PROCEDURE Check_purge
  (
      p_api_version_number      IN      NUMBER,
      p_init_msg_list           IN      VARCHAR2,
      p_commit                  IN      VARCHAR2,
      x_return_status           OUT NOCOPY      VARCHAR2,
      x_msg_count               OUT NOCOPY      NUMBER,
      x_msg_data                OUT NOCOPY      VARCHAR2,
      P_lpn_rec                 IN  OUT NOCOPY
                                   WSH_GLBL_VAR_STRCT_GRP.purgeInOutRecType
  )
  IS
    --
    l_debug_on BOOLEAN;
    --
    l_module_name CONSTANT   VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME ||
            '.' || 'CHECK_PURGE';
    --
    l_return_status          VARCHAR2(1);
    l_api_version_number     CONSTANT NUMBER := 1.0;
    l_msg_count        NUMBER;
    l_msg_data         VARCHAR2(32767);
    l_api_name               CONSTANT VARCHAR2(30):= 'check_purge';
    l_count            NUMBER;
    --bmso dependency 4298071

    Cursor c_populate_out_rec IS
    Select lpn_id FROM wsh_lpn_purge_tmp
    WHERE eligible_flag = 'Y';


  BEGIN
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    SAVEPOINT check_purge_WSHWLGPB;
    --
    IF NOT FND_API.Compatible_API_Call
      ( l_api_version_number,
        p_api_version_number,
        l_api_name,
        G_PKG_NAME
       )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --
    IF l_debug_on THEN
      --
      wsh_debug_sv.push (l_module_name);
      wsh_debug_sv.log (l_module_name,'lpn_ids.count',p_lpn_rec.lpn_ids.COUNT);
      wsh_debug_sv.log (l_module_name,'p_init_msg_list',p_init_msg_list);
      wsh_debug_sv.log (l_module_name,'p_commit',p_commit);
      --
    END IF;
    --
    IF p_lpn_rec.lpn_ids.COUNT > 0 THEN --{

       BEGIN
          SELECT 1 INTO l_count
          FROM wsh_lpn_purge_tmp;
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
             l_count := 0;
       END;

       IF l_debug_on THEN
         wsh_debug_sv.log (l_module_name,'l_count',l_count);
       END IF;

       IF l_count > 0 THEN
          DELETE FROM wsh_lpn_purge_tmp;
       END IF;

       FORALL I  IN p_lpn_rec.lpn_ids.FIRST..p_lpn_rec.lpn_ids.LAST
       INSERT INTO wsh_lpn_purge_tmp
        ( lpn_id,
          ELIGIBLE_FLAG
       )VALUES(
         P_lpn_rec.lpn_ids(i),
         'Y'
       );

       Update wsh_lpn_purge_tmp
       Set eligible_flag = 'N' where
       Lpn_id in (
          Select wt.lpn_id from
          Wsh_lpn_purge_tmp wt, wsh_delivery_details wdd
          Where wt.lpn_id = wdd.lpn_id
          And nvl(wt.ELIGIBLE_FLAG ,'Y') = 'Y'
          And NVL(wdd.line_direction,'O') IN ('IO','O')
          And wdd.released_status <> 'C');

       IF l_debug_on THEN
         wsh_debug_sv.log (l_module_name,'Rows updated',SQL%rowcount);
       END IF;

       Update wsh_lpn_purge_tmp
       Set ELIGIBLE_FLAG = 'N'
       WHERE
       Lpn_id in (select wt.lpn_id
         FROM wms_lpn_histories wlh,
              wsh_inbound_txn_history wth,
              wsh_lpn_purge_tmp wt
         where wlh.parent_lpn_id = wt.lpn_id
         and nvl(wt.ELIGIBLE_FLAG,'Y') = 'Y'
         and wlh.source_type_id   = 1
         AND wlh.lpn_context = 7
         and wlh.source_header_id =  wth.shipment_header_id
         and wth.transaction_type in ('RECEIPT', 'ASN'));

       IF l_debug_on THEN
         wsh_debug_sv.log (l_module_name,'Rows updated',SQL%rowcount);
       END IF;

       UPDATE wsh_delivery_details
       SET lpn_id = NULL WHERE
       lpn_id IN (SELECT LPN_ID FROM wsh_lpn_purge_tmp
       WHERE eligible_flag = 'Y');

       Open c_populate_out_rec;
       FETCH c_populate_out_rec BULK COLLECT INTO p_lpn_rec.lpn_ids;
       CLOSE c_populate_out_rec;

       IF l_debug_on THEN
         wsh_debug_sv.log (l_module_name,'lpn_ids.COUNT',
                                                  p_lpn_rec.lpn_ids.COUNT);
       END IF;

    END IF; --}

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    FND_MSG_PUB.Count_And_Get (
      p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => FND_API.G_FALSE);
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
  EXCEPTION

    WHEN OTHERS THEN
      ROLLBACK TO check_purge_WSHWLGPB;
      --p_lpn_rec.lpn_ids.DELETE;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_WMS_LPN_GRP.check_purge');
      FND_MSG_PUB.Count_And_Get
        (
         p_count  => x_msg_count,
         p_data  =>  x_msg_data,
         p_encoded => FND_API.G_FALSE
        );

      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
  END Check_purge;


--***************************************************************************--
--========================================================================
-- PROCEDURE : is_valid_consol
--
-- PARAMETERS: p_init_msg_list             FND_API.G_TRUE to reset list
--             p_input_delivery_id_tab     Table of delivery records to process
--
--             p_target_consol_delivery_id Table of delivery ids to process
--             x_deconsolidation_location  deconsolidation location
--             x_msg_count                 Number of messages in the list
--             x_msg_data                  Text of messages
--             x_return_status             Return status
-- COMMENT   : This procedure is to find if a set of deliveries can be assigned to a consol delivery.
--             This procedure is called from WMS.
--
--========================================================================
PROCEDURE is_valid_consol(  p_init_msg_list             IN  VARCHAR2 DEFAULT fnd_api.g_false,
                            p_input_delivery_id_tab     IN  WSH_UTIL_CORE.id_tab_type,
                            p_target_consol_delivery_id IN  NUMBER,
                            p_caller                    IN  VARCHAR2 DEFAULT NULL,
                            x_deconsolidation_location  OUT NOCOPY NUMBER,
                            x_return_status             OUT  NOCOPY VARCHAR2,
                            x_msg_count                 OUT  NOCOPY NUMBER,
                            x_msg_data                  OUT  NOCOPY VARCHAR2
                          ) IS

cursor c_parent_info(p_del_id in NUMBER) is
select s.trip_id, l2.delivery_id
from   wsh_trip_stops s,
       wsh_delivery_legs l1,
       wsh_delivery_legs l2,
       wsh_new_deliveries d
where  d.initial_pickup_location_id = s.stop_location_id
and    l1.delivery_id = d.delivery_id
and    l1.pick_up_stop_id = s.stop_id
and    d.delivery_id = p_del_id
and    l1.parent_delivery_leg_id = l2.delivery_leg_id(+);

cursor c_pickup_trip(p_del_id in NUMBER) is
select s.trip_id
from   wsh_trip_stops s,
       wsh_delivery_legs l,
       wsh_new_deliveries d
where  d.initial_pickup_location_id = s.stop_location_id
and    l.delivery_id = d.delivery_id
and    l.pick_up_stop_id = s.stop_id
and    d.delivery_id = p_del_id;


l_temp_trip_id NUMBER := NULL;
l_consol_trip_id NUMBER := NULL;
l_temp_parent_del_id NUMBER := NULL;
l_parent_del_id NUMBER := NULL;
l_debug_on BOOLEAN;
l_module_name CONSTANT   VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'IS_VALID_CONSOL';

WSH_INVALID_DECONSOL_POINT EXCEPTION;
WSH_INVALID_PARENT EXCEPTION;
WSH_INVALID_TRIP EXCEPTION;

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
      --
      wsh_debug_sv.push (l_module_name);
      wsh_debug_sv.log (l_module_name,'p_input_delivery_id_tab.count',p_input_delivery_id_tab.COUNT);
      wsh_debug_sv.log (l_module_name,'p_target_consol_delivery_id',p_target_consol_delivery_id);
      --
    END IF;
    --



  x_return_status :=  WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  -- 1. Check if the deliveries are not on diff. pickup trips
  --    and diff. consol deliveries.

  FOR i in 1..p_input_delivery_id_tab.count LOOP

      OPEN c_parent_info(p_input_delivery_id_tab(i));
      FETCH c_parent_info
      INTO l_temp_trip_id, l_temp_parent_del_id;
      CLOSE c_parent_info;

      IF l_debug_on THEN
        --
        wsh_debug_sv.logmsg (l_module_name,'----------------------------------');
        wsh_debug_sv.log (l_module_name,'p_input_delivery_id_tab-->',p_input_delivery_id_tab(i));
        wsh_debug_sv.log (l_module_name,'l_temp_trip_id-->',l_temp_trip_id);
        wsh_debug_sv.log (l_module_name,'l_temp_parent_del_id-->',l_temp_parent_del_id);
        wsh_debug_sv.log (l_module_name,'l_consol_trip_id-->',l_consol_trip_id);
        wsh_debug_sv.log (l_module_name,'l_temp_parent_del_id-->',l_temp_parent_del_id);
        wsh_debug_sv.log (l_module_name,'l_parent_del_id-->',l_parent_del_id);
        wsh_debug_sv.logmsg (l_module_name,'----------------------------------');
        --
      END IF;

      IF l_temp_trip_id IS NOT NULL AND l_consol_trip_id IS NULL THEN
         l_consol_trip_id := l_temp_trip_id;
      ELSIF l_temp_trip_id <> l_consol_trip_id THEN
         RAISE WSH_INVALID_TRIP;
      END IF;

      IF l_temp_parent_del_id IS NOT NULL AND l_parent_del_id IS NULL THEN
         l_parent_del_id := l_temp_parent_del_id;
      ELSIF l_temp_parent_del_id <> l_parent_del_id THEN
         RAISE WSH_INVALID_PARENT;
      END IF;
  END LOOP;

  IF l_debug_on THEN
    --
    wsh_debug_sv.logmsg (l_module_name,'----------------------------------');
    wsh_debug_sv.log (l_module_name,'AFTER THE LOOP,l_consol_trip_id-->',l_consol_trip_id);
    wsh_debug_sv.log (l_module_name,'AFTER THE LOOP,l_parent_del_id-->',l_parent_del_id);
    --
  END IF;

  IF p_target_consol_delivery_id IS NOT NULL THEN
      OPEN c_pickup_trip(p_target_consol_delivery_id);
      FETCH c_pickup_trip
      INTO l_temp_trip_id;
      CLOSE c_pickup_trip;

      IF l_debug_on THEN
        --
        wsh_debug_sv.log (l_module_name,'l_temp_trip_id-->',l_temp_trip_id);
        wsh_debug_sv.log (l_module_name,'l_consol_trip_id-->',l_consol_trip_id);
        --
      END IF;

      IF l_temp_trip_id <> l_consol_trip_id THEN
         RAISE WSH_INVALID_TRIP;
      END IF;
  END IF;
  IF l_parent_del_id <> p_target_consol_delivery_id THEN
     RAISE WSH_INVALID_PARENT;
  END IF;

  -- 2. Check if deconsol points match.

  WSH_FTE_COMP_CONSTRAINT_GRP.is_valid_consol
                         (  p_init_msg_list             =>  p_init_msg_list,
                            p_input_delivery_id_tab     =>  p_input_delivery_id_tab,
                            p_target_consol_delivery_id =>  p_target_consol_delivery_id,
                            p_caller                    =>  p_caller,
                            x_deconsolidation_location  =>  x_deconsolidation_location,
                            x_return_status             =>  x_return_status,
                            x_msg_count                 =>  x_msg_count,
                            x_msg_data                  =>  x_msg_data
                          );

  IF x_return_status in (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
     RAISE WSH_INVALID_DECONSOL_POINT;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION

 WHEN WSH_INVALID_PARENT THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_PARENT');
       WSH_UTIL_CORE.Add_Message(x_return_status);
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INVALID_PARENT exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);

       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_PARENT');
       END IF;
        --
 WHEN WSH_INVALID_TRIP THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_TRIP');
       WSH_UTIL_CORE.Add_Message(x_return_status);
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INVALID_TRIP exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);

       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_TRIP');
       END IF;

 WHEN WSH_INVALID_DECONSOL_POINT THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_DECONSOL_POINT');
       WSH_UTIL_CORE.Add_Message(x_return_status);
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INVALID_DECONSOL_POINT exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);

       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_DECONSOL_POINT');
       END IF;

 WHEN OTHERS THEN
       wsh_util_core.default_handler('wsh_new_delivery_actions.Unassign_Dels_from_Consol_Del',l_module_name);
       --
       IF l_debug_on THEN
       wsh_debug_sv.pop(l_module_name, 'EXCEPTION:OTHERS');
 END IF;


END is_valid_consol;

END WSH_WMS_LPN_GRP;

/
