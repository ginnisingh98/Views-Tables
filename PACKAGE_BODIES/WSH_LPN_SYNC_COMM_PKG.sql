--------------------------------------------------------
--  DDL for Package Body WSH_LPN_SYNC_COMM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_LPN_SYNC_COMM_PKG" as
/* $Header: WSHLSCMB.pls 120.5.12010000.2 2009/03/10 08:33:15 ueshanka ship $ */



  --
  G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_LPN_SYNC_COMM_PKG';
  --
  PROCEDURE SYNC_LPNS_TO_WMS
  (
    p_in_rec             IN             WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_in_rec_type,
    x_return_status      OUT NOCOPY     VARCHAR2,
    x_out_rec            OUT NOCOPY     WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_out_rec_type
  )
  IS
  --{
      l_return_status VARCHAR2(10);
      l_msg_count NUMBER;
      l_msg_data VARCHAR2(32767);
      l_num_warnings NUMBER :=0;
      l_num_errors NUMBER :=0;

      l_current_hw_time_stamp DATE;
      l_original_call_grp_api VARCHAR2(2);
      l_original_update_to_cnt VARCHAR2(2);

      cursor l_unpack_csr (p_hw_time_stamp IN DATE) is
      select wddc.lpn_id,
             wddp.lpn_id old_parent_lpn_id
      from   wsh_delivery_details wddc,
             wsh_delivery_details wddp,
             wsh_delivery_assignments_v wda,
             wsh_wms_sync_tmp wlst
      where  wlst.delivery_detail_id = wda.delivery_detail_id
      and    wddc.delivery_detail_id = wda.delivery_detail_id
      and    wlst.parent_delivery_detail_id = wddp.delivery_detail_id
      and    nvl(wda.parent_delivery_detail_id, -1) <> nvl(wlst.parent_delivery_detail_id,-1)
      and    wlst.parent_delivery_detail_id is not null
      and    wlst.operation_type = 'PRIOR'
      and    wddc.lpn_id is not null
      and    wddp.lpn_id is not null
      and    wlst.creation_date = p_hw_time_stamp
      order by
             wlst.parent_delivery_detail_id;

      l_curr_unpack_parent_lpn_id NUMBER;
      l_prev_unpack_parent_lpn_id NUMBER;
      l_unpack_lpn_id_tbl    wsh_util_core.id_tab_type;

      cursor l_pack_csr (p_hw_time_stamp IN DATE) is
      select wddc.lpn_id,
             wddp.lpn_id parent_lpn_id
      from   wsh_delivery_details wddc,
             wsh_delivery_details wddp,
             wsh_delivery_assignments_v wda,
             wsh_wms_sync_tmp wlst
      where  wlst.delivery_detail_id = wda.delivery_detail_id
      and    wddc.delivery_detail_id = wda.delivery_detail_id
      and    wda.parent_delivery_detail_id = wddp.delivery_detail_id
      and    nvl(wda.parent_delivery_detail_id, -1) <> nvl(wlst.parent_delivery_detail_id,-1)
      and    wda.parent_delivery_detail_id is not null
      and    wddc.lpn_id is not null
      and    wddp.lpn_id is not null
      and    wlst.operation_type = 'PRIOR'
      and    wlst.creation_date = p_hw_time_stamp
      order by
             wda.parent_delivery_detail_id;

      l_curr_pack_parent_lpn_id NUMBER;
      l_prev_pack_parent_lpn_id NUMBER;
      l_pack_lpn_id_tbl    wsh_util_core.id_tab_type;

      cursor l_unassign_csr (p_hw_time_stamp IN DATE) is
      select wdd.lpn_id,
             wlst.delivery_id old_delivery_id
      from   wsh_delivery_details wdd,
             wsh_delivery_assignments_v wda,
             wsh_wms_sync_tmp wlst
      where  wlst.delivery_detail_id = wda.delivery_detail_id
      and    wdd.delivery_detail_id = wda.delivery_detail_id
      and    nvl(wda.delivery_id, -1) <> nvl(wlst.delivery_id,-1)
      and    wlst.delivery_id is not null
      and    wdd.lpn_id is not null
      and    wlst.operation_type = 'PRIOR'
      and    wlst.creation_date = p_hw_time_stamp
      order by
             wlst.delivery_id;


      l_curr_unasgn_del_id NUMBER;
      l_prev_unasgn_del_id NUMBER;
      l_unasgn_lpn_id_tbl    wsh_util_core.id_tab_type;

      cursor l_assign_csr (p_hw_time_stamp IN DATE) is
      select wdd.lpn_id,
             wda.delivery_id new_delivery_id
      from   wsh_delivery_details wdd,
             wsh_delivery_assignments_v wda,
             wsh_wms_sync_tmp wlst
      where  wlst.delivery_detail_id = wda.delivery_detail_id
      and    wdd.delivery_detail_id = wda.delivery_detail_id
      and    nvl(wda.delivery_id, -1) <> nvl(wlst.delivery_id,-1)
      and    wda.delivery_id is not null
      and    wdd.lpn_id is not null
      and    wlst.operation_type = 'PRIOR'
      and    wlst.creation_date = p_hw_time_stamp
      order by
             wda.delivery_id;

      l_curr_asgn_del_id NUMBER;
      l_prev_asgn_del_id NUMBER;
      l_asgn_lpn_id_tbl    wsh_util_core.id_tab_type;

      cursor l_update_csr (p_hw_time_stamp IN DATE) is
      select wdd.lpn_id,
             wlst.delivery_detail_id,
             wdd.container_name,
             wdd.inventory_item_id,
             wdd.organization_id,
             wdd.subinventory,
             wdd.locator_id,
             wdd.gross_weight,
             wdd.volume_uom_code,
             wdd.filled_volume,
             wdd.volume,
             wdd.weight_uom_code,
             wdd.net_weight
      from   wsh_delivery_details wdd,
             wsh_wms_sync_tmp wlst
      where  wlst.delivery_detail_id = wdd.delivery_detail_id
      and    wdd.lpn_id is not null
      and    wlst.operation_type = 'UPDATE'
      and    wlst.creation_date = p_hw_time_stamp;

      l_current_parent_detail_id NUMBER;
      i NUMBER;
      l_prev_parent_detail_id NUMBER;
      l_wms_lpn_tbl WMS_DATA_TYPE_DEFINITIONS_PUB.LPNTableType;
      l_old_date_wm constant date := to_date('01-01-1901 00:00:00', 'DD-MM-YYYY HH24:MI:SS');

      l_tmp_tbl_size NUMBER;
  --}
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SYNC_LPNS_TO_WMS';
  --
  BEGIN
  --{
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
      END IF;
      --
      -- Setting the return status in the begining
      x_return_status := wsh_util_core.g_ret_sts_success;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'wsh_wms_lpn_grp.g_hw_time_stamp', wsh_wms_lpn_grp.g_hw_time_stamp);
      END IF;
      --
      IF ( wsh_wms_lpn_grp.g_hw_time_stamp is null ) THEN
        wsh_wms_lpn_grp.g_hw_time_stamp := sysdate;
      END IF;
      --
      l_current_hw_time_stamp := wsh_wms_lpn_grp.g_hw_time_stamp;
      l_original_call_grp_api := wsh_wms_lpn_grp.g_call_group_api;

      -- This is not required any more as g_hw_time_stamp will always be initialized
      --IF (l_current_hw_time_stamp IS NULL) THEN
      --{
      --    l_current_hw_time_stamp := l_old_date_wm;
      --}
      --END IF;
      -- Logic for 'UNPACK'
      i := 1;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_current_hw_time_stamp', l_current_hw_time_stamp);
      END IF;

      -- Bug 8314220: Moved following query out from debug
      select count(*)  into l_tmp_tbl_size from wsh_wms_sync_tmp
      where creation_date = l_current_hw_time_stamp;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Count of wsh_wms_sync_tmp table is', l_tmp_tbl_size);
      END IF;

      -- Bug 8314220: Execute following code only if there are any records in wsh_wms_sync_tmp table.
      IF l_tmp_tbl_size > 0 THEN
      --{
         -- We are doing the following update because, if a particular went through various
         -- steps of for example, update, assign, unassign, and was finally deleted, then
         -- we do not want to call WMS for these operations
         update wsh_wms_sync_tmp
         set    operation_type = 'DELETE'
         where  delivery_detail_id in (select delivery_detail_id
                                       from wsh_wms_sync_tmp
                                       where operation_type = 'DELETE'
                                       and creation_date = l_current_hw_time_stamp)
         and    operation_type = 'UPDATE'
         and    creation_date = l_current_hw_time_stamp;

         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Count of rows updated is', SQL%ROWCOUNT);
         END IF;

         FOR unpack_rec in l_unpack_csr(l_current_hw_time_stamp) LOOP
         --{
             --
             l_curr_unpack_parent_lpn_id := unpack_rec.old_parent_lpn_id;

             IF (i = 1 OR
                 nvl(l_prev_unpack_parent_lpn_id,-99) = nvl(l_curr_unpack_parent_lpn_id,-99)
                )
             THEN
               --
               l_unpack_lpn_id_tbl(i) := unpack_rec.lpn_id;
               --
             ELSE
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'Count of l_unpack_lpn_id_tbl is', l_unpack_lpn_id_tbl.count);
                   WSH_DEBUG_SV.log(l_module_name,'old parent lpn id is', l_prev_unpack_parent_lpn_id);
               END IF;
               -- This infrastructure is built for future so that when
               -- WMS is interested in getting this information, we
               -- need to make a call at this point
               -- need to set the WSH_WMS_LPN_GRP.g_call_group_api := 'N';
               -- before calling WMS
               l_unpack_lpn_id_tbl.delete;
               i := 1;
               --
             END IF;
             l_prev_unpack_parent_lpn_id := l_curr_unpack_parent_lpn_id;
             i := i + 1;
             --
         --}
         END LOOP;
         --
         -- Need to make one extra call to WMS for UNPACK to take care of the last set of lpns
         -- in the l_unpack_lpn_id_tbl after teh loop
         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Count of l_unpack_lpn_id_tbl is', l_unpack_lpn_id_tbl.count);
           WSH_DEBUG_SV.log(l_module_name,'new parent lpn id is', l_prev_unpack_parent_lpn_id);
         END IF;

         -- Logic for 'PACK'
         i := 1;

         FOR pack_rec in l_pack_csr(l_current_hw_time_stamp) LOOP
         --{
             --
             l_curr_pack_parent_lpn_id := pack_rec.parent_lpn_id;

             IF (i = 1 OR
                 nvl(l_prev_pack_parent_lpn_id,-99) = nvl(l_curr_pack_parent_lpn_id,-99)
                )
             THEN
               --
               l_pack_lpn_id_tbl(i) := pack_rec.lpn_id;
               --
             ELSE
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'Count of l_pack_lpn_id_tbl is', l_pack_lpn_id_tbl.count);
                   WSH_DEBUG_SV.log(l_module_name,'new parent lpn id is', l_prev_pack_parent_lpn_id);
               END IF;
               -- This infrastructure is built for future so that when
               -- WMS is interested in getting this information, we
               -- need to make a call at this point
               -- need to set the WSH_WMS_LPN_GRP.g_call_group_api := 'N';
               -- before calling WMS
               l_pack_lpn_id_tbl.delete;
               i := 1;
               --
             END IF;
             l_prev_pack_parent_lpn_id := l_curr_pack_parent_lpn_id;
             i := i + 1;
             --
         --}
         END LOOP;
         --
         -- Need to make one extra call to WMS for PACK to take care of the last set of lpns
         -- in the l_pack_lpn_id_tbl after teh loop
         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Count of l_pack_lpn_id_tbl is', l_pack_lpn_id_tbl.count);
           WSH_DEBUG_SV.log(l_module_name,'new parent lpn id is', l_prev_pack_parent_lpn_id);
         END IF;

         -- Logic for 'UNASSIGN'
         i := 1;
         FOR unasgn_rec in l_unassign_csr(l_current_hw_time_stamp) LOOP
         --{
             --
             l_curr_unasgn_del_id := unasgn_rec.old_delivery_id;

             IF (i = 1 OR
                 nvl(l_prev_unasgn_del_id,-99) = nvl(l_curr_unasgn_del_id,-99)
                )
             THEN
               --
               l_unasgn_lpn_id_tbl(i) := unasgn_rec.lpn_id;
               --
             ELSE
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'Count of l_unasgn_lpn_id_tbl is', l_unasgn_lpn_id_tbl.count);
                   WSH_DEBUG_SV.log(l_module_name,'old delivery id is', l_prev_unasgn_del_id);
               END IF;
               -- This infrastructure is built for future so that when
               -- WMS is interested in getting this information, we
               -- need to make a call at this point
               -- need to set the WSH_WMS_LPN_GRP.g_call_group_api := 'N';
               -- before calling WMS
               l_unasgn_lpn_id_tbl.delete;
               i := 1;
               --
             END IF;
             l_prev_unasgn_del_id := l_curr_unasgn_del_id;
             i := i + 1;
             --
         --}
         END LOOP;
         --
         -- Need to make one extra call to WMS for UNASSIGN to take care of the last set of lpns
         -- in the l_unasgn_lpn_id_tbl after the loop
         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Count of l_unasgn_lpn_id_tbl is', l_unasgn_lpn_id_tbl.count);
           WSH_DEBUG_SV.log(l_module_name,'new parent lpn id is', l_prev_unasgn_del_id);
         END IF;

         -- Logic for 'UNASSIGN'
         i := 1;

         FOR assign_rec in l_assign_csr(l_current_hw_time_stamp) LOOP
         --{
             --
             l_curr_asgn_del_id := assign_rec.new_delivery_id;

             IF (i = 1 OR
                 nvl(l_prev_asgn_del_id,-99) = nvl(l_curr_asgn_del_id,-99)
                )
             THEN
               --
               l_asgn_lpn_id_tbl(i) := assign_rec.lpn_id;
               --
             ELSE
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'Count of l_asgn_lpn_id_tbl is', l_asgn_lpn_id_tbl.count);
                   WSH_DEBUG_SV.log(l_module_name,'new delivery id is', l_prev_asgn_del_id);
               END IF;
               -- This infrastructure is built for future so that when
               -- WMS is interested in getting this information, we
               -- need to make a call at this point
               -- need to set the WSH_WMS_LPN_GRP.g_call_group_api := 'N';
               -- before calling WMS
               l_asgn_lpn_id_tbl.delete;
               i := 1;
               --
             END IF;
             l_prev_asgn_del_id := l_curr_asgn_del_id;
             i := i + 1;
             --
         --}
         END LOOP;
         --
         -- Need to make one extra call to WMS for ASSIGN to take care of the last set of lpns
         -- in the l_asgn_lpn_id_tbl after the loop
         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Count of l_asgn_lpn_id_tbl is', l_asgn_lpn_id_tbl.count);
           WSH_DEBUG_SV.log(l_module_name,'new parent lpn id is', l_prev_asgn_del_id);
         END IF;

         i := 1;
         FOR update_rec in l_update_csr(l_current_hw_time_stamp) LOOP
         --{
             IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'Inside the loop i is', i);
               WSH_DEBUG_SV.log(l_module_name,'Inside the loop delivery_detail_id is', update_rec.delivery_detail_id);
               WSH_DEBUG_SV.log(l_module_name,'Inside the loop lpn_id is', update_rec.lpn_id);
             END IF;

             IF (update_rec.lpn_id IS NOT NULL) THEN
               l_wms_lpn_tbl(i).LPN_ID                  := update_rec.lpn_id;
               l_wms_lpn_tbl(i).LICENSE_PLATE_NUMBER    := update_rec.container_name;
               l_wms_lpn_tbl(i).INVENTORY_ITEM_ID       := update_rec.inventory_item_id;
               l_wms_lpn_tbl(i).ORGANIZATION_ID         := update_rec.ORGANIZATION_ID;
               l_wms_lpn_tbl(i).SUBINVENTORY_CODE       := update_rec.SUBINVENTORY;
               l_wms_lpn_tbl(i).LOCATOR_ID              := update_rec.LOCATOR_ID;
               l_wms_lpn_tbl(i).GROSS_WEIGHT_UOM_CODE   := update_rec.weight_uom_code;
               l_wms_lpn_tbl(i).GROSS_WEIGHT            := update_rec.gross_weight;
               l_wms_lpn_tbl(i).CONTAINER_VOLUME_UOM    := update_rec.volume_uom_code;
               l_wms_lpn_tbl(i).CONTAINER_VOLUME        := update_rec.volume;
               l_wms_lpn_tbl(i).CONTENT_VOLUME_UOM_CODE := update_rec.volume_uom_code;
               l_wms_lpn_tbl(i).CONTENT_VOLUME          := update_rec.filled_volume;
               l_wms_lpn_tbl(i).TARE_WEIGHT_UOM_CODE    := update_rec.weight_uom_code;
               l_wms_lpn_tbl(i).TARE_WEIGHT             := (update_rec.gross_weight - update_rec.net_weight);
               i := i + 1;
             END IF;
         --}
         END LOOP;
      --}
      END IF;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'count of plsql table l_wms_lpn_tbl is', l_wms_lpn_tbl.count);
      END IF;
      --
      IF ( l_wms_lpn_tbl.count > 0 ) THEN
      --{
          -- setting the globals appropriately before calling WMS.
          WSH_WMS_LPN_GRP.g_call_group_api := 'N';

          IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WMS_CONTAINER_GRP.MODIFY_LPNS',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          WMS_Container_GRP.Modify_LPNs (
            p_api_version   => 1.0,
            p_init_msg_list => FND_API.G_FALSE,
            p_commit        => FND_API.G_FALSE,
            x_return_status => l_return_status,
            x_msg_count     => l_msg_count,
            x_msg_data      => l_msg_data,
            p_caller        => 'WSH_WMS_SYNC_TMP_PKG',
            p_lpn_table     => l_wms_lpn_tbl
           );
           -- resetting the values back to the original values
           WSH_WMS_LPN_GRP.g_call_group_api := l_original_call_grp_api;

           IF (nvl(wsh_wms_lpn_grp.g_update_to_containers,'N') = 'Y') THEN
             wsh_wms_lpn_grp.g_update_to_containers := 'N';
           END IF;

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

      wsh_wms_lpn_grp.g_hw_time_stamp := wsh_wms_lpn_grp.g_hw_time_stamp + 1/86400;

    IF l_num_errors > 0 THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_num_warnings > 0 THEN
      x_return_status := wsh_util_core.g_ret_sts_warning;
    END IF;

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
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_WMS_LPN_GRP.g_call_group_api := l_original_call_grp_api;
      IF (nvl(wsh_wms_lpn_grp.g_update_to_containers,'N') = 'Y') THEN
        wsh_wms_lpn_grp.g_update_to_containers := 'N';
      END IF;
      --
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
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      WSH_WMS_LPN_GRP.g_call_group_api := l_original_call_grp_api;
      IF (nvl(wsh_wms_lpn_grp.g_update_to_containers,'N') = 'Y') THEN
        wsh_wms_lpn_grp.g_update_to_containers := 'N';
      END IF;
      --
      --
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_module_name);
      WSH_WMS_LPN_GRP.g_call_group_api := l_original_call_grp_api;
      IF (nvl(wsh_wms_lpn_grp.g_update_to_containers,'N') = 'Y') THEN
        wsh_wms_lpn_grp.g_update_to_containers := 'N';
      END IF;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
  --}
  END SYNC_LPNS_TO_WMS;

  -- This procedure is used to synchronize the updates on LPNs in WSH
  -- to WMS due to proration logic
  PROCEDURE SYNC_PRORATED_LPNS_TO_WMS
  (
    p_in_rec             IN             WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_in_rec_type,
    x_return_status      OUT NOCOPY     VARCHAR2,
    x_out_rec            OUT NOCOPY     WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_out_rec_type
  )
  IS
  --{
      --
      cursor l_pr_update_csr (p_hw_time_stamp IN DATE) is
      select wdd.lpn_id,
             wlst.delivery_detail_id,
             wdd.container_name,
             wdd.inventory_item_id,
             wdd.organization_id,
             wdd.subinventory,
             wdd.locator_id,
             wdd.gross_weight,
             wdd.volume_uom_code,
             wdd.filled_volume,
             wdd.volume,
             wdd.weight_uom_code,
             wdd.net_weight,
             wlst.call_level
      from   wsh_delivery_details wdd,
             wsh_wms_sync_tmp wlst
      where  wlst.delivery_detail_id = wdd.delivery_detail_id
      and    wdd.lpn_id is not null
      and    wlst.operation_type = 'UPDATE'
      and    wlst.creation_date = p_hw_time_stamp
      order  by nvl(wlst.call_level,0) desc;

      l_current_hw_time_stamp DATE;
      l_original_call_grp_api VARCHAR2(2);
      l_call_level NUMBER := 0;
      l_prev_call_level NUMBER := 0;
      l_wms_lpn_tbl WMS_DATA_TYPE_DEFINITIONS_PUB.LPNTableType;
      l_return_status VARCHAR2(10);
      l_msg_count NUMBER;
      l_msg_data VARCHAR2(32767);
      l_num_warnings NUMBER :=0;
      l_num_errors NUMBER :=0;

      i NUMBER;
      l_loopCounter NUMBER;
      --
      l_debug_on BOOLEAN;
      --
      l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SYNC_PRORATED_LPNS_TO_WMS';
      --
  --}
  BEGIN
  --{
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
      END IF;
      --
      -- Setting the return status in the begining
      x_return_status := wsh_util_core.g_ret_sts_success;
      --
      IF ( wsh_wms_lpn_grp.g_hw_time_stamp is null ) THEN
        wsh_wms_lpn_grp.g_hw_time_stamp := sysdate;
      END IF;

      l_current_hw_time_stamp := wsh_wms_lpn_grp.g_hw_time_stamp;
      l_original_call_grp_api := wsh_wms_lpn_grp.g_call_group_api;

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'wsh_wms_lpn_grp.g_hw_time_stamp', wsh_wms_lpn_grp.g_hw_time_stamp);
        WSH_DEBUG_SV.log(l_module_name,'l_original_call_grp_api', l_original_call_grp_api);
      END IF;
      --
      i := 1;
      l_loopCounter := 1;
      --
      --
      FOR update_rec in l_pr_update_csr(l_current_hw_time_stamp) LOOP
      --{
          --
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'count of plsql table l_wms_lpn_tbl is', l_wms_lpn_tbl.count);
            WSH_DEBUG_SV.log(l_module_name,'l_call_level',l_call_level);
            WSH_DEBUG_SV.log(l_module_name,'l_prev_call_level',l_prev_call_level);
          END IF;
          --
          l_call_level := nvl(update_rec.call_level,0);
          --
          IF ( l_wms_lpn_tbl.count > 0
          AND  l_loopCounter > 1 AND  l_call_level <> l_prev_call_level) THEN
          --{
              -- setting the globals appropriately before calling WMS.
              WSH_WMS_LPN_GRP.g_call_group_api := 'N';

              IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WMS_CONTAINER_GRP.MODIFY_LPNS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WMS_Container_GRP.Modify_LPNs (
                p_api_version   => 1.0,
                p_init_msg_list => FND_API.G_FALSE,
                p_commit        => FND_API.G_FALSE,
                x_return_status => l_return_status,
                x_msg_count     => l_msg_count,
                x_msg_data      => l_msg_data,
                p_caller        => 'WSH_WMS_SYNC_TMP_PKG',
                p_lpn_table     => l_wms_lpn_tbl
               );
               -- resetting the values back to the original values
               WSH_WMS_LPN_GRP.g_call_group_api := l_original_call_grp_api;

               IF (nvl(wsh_wms_lpn_grp.g_update_to_containers,'N') = 'Y') THEN
                 wsh_wms_lpn_grp.g_update_to_containers := 'N';
               END IF;

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

             l_wms_lpn_tbl.delete;

             i := 1;

          --}
          END IF;
          --
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Inside the loop i is', i);
            WSH_DEBUG_SV.log(l_module_name,'Inside the loop delivery_detail_id is', update_rec.delivery_detail_id);
            WSH_DEBUG_SV.log(l_module_name,'Inside the loop lpn_id is', update_rec.lpn_id);
          END IF;

          l_wms_lpn_tbl(i).LPN_ID                  := update_rec.lpn_id;
          l_wms_lpn_tbl(i).LICENSE_PLATE_NUMBER    := update_rec.container_name;
          l_wms_lpn_tbl(i).INVENTORY_ITEM_ID       := update_rec.inventory_item_id;
          l_wms_lpn_tbl(i).ORGANIZATION_ID         := update_rec.ORGANIZATION_ID;
          l_wms_lpn_tbl(i).SUBINVENTORY_CODE       := update_rec.SUBINVENTORY;
          l_wms_lpn_tbl(i).LOCATOR_ID              := update_rec.LOCATOR_ID;
          l_wms_lpn_tbl(i).GROSS_WEIGHT_UOM_CODE   := update_rec.weight_uom_code;
          l_wms_lpn_tbl(i).GROSS_WEIGHT            := update_rec.gross_weight;
          l_wms_lpn_tbl(i).CONTAINER_VOLUME_UOM    := update_rec.volume_uom_code;
          l_wms_lpn_tbl(i).CONTAINER_VOLUME        := update_rec.volume;
          l_wms_lpn_tbl(i).CONTENT_VOLUME_UOM_CODE := update_rec.volume_uom_code;
          l_wms_lpn_tbl(i).CONTENT_VOLUME          := update_rec.filled_volume;
          l_wms_lpn_tbl(i).TARE_WEIGHT_UOM_CODE    := update_rec.weight_uom_code;
          l_wms_lpn_tbl(i).TARE_WEIGHT             := (update_rec.gross_weight - update_rec.net_weight);
          i := i + 1;
          l_loopCounter := l_loopCounter + 1;
          l_prev_call_level := l_call_level;

      --}
      END LOOP;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'count of plsql table l_wms_lpn_tbl is', l_wms_lpn_tbl.count);
      END IF;
      --
      IF ( l_wms_lpn_tbl.count > 0 ) THEN
      --{
          -- setting the globals appropriately before calling WMS.
          WSH_WMS_LPN_GRP.g_call_group_api := 'N';

          IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WMS_CONTAINER_GRP.MODIFY_LPNS',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          WMS_Container_GRP.Modify_LPNs (
            p_api_version   => 1.0,
            p_init_msg_list => FND_API.G_FALSE,
            p_commit        => FND_API.G_FALSE,
            x_return_status => l_return_status,
            x_msg_count     => l_msg_count,
            x_msg_data      => l_msg_data,
            p_caller        => 'WSH_WMS_SYNC_TMP_PKG',
            p_lpn_table     => l_wms_lpn_tbl
           );
           -- resetting the values back to the original values
           WSH_WMS_LPN_GRP.g_call_group_api := l_original_call_grp_api;

           IF (nvl(wsh_wms_lpn_grp.g_update_to_containers,'N') = 'Y') THEN
             wsh_wms_lpn_grp.g_update_to_containers := 'N';
           END IF;

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


      wsh_wms_lpn_grp.g_hw_time_stamp := wsh_wms_lpn_grp.g_hw_time_stamp + 1/86400;

    IF l_num_errors > 0 THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_num_warnings > 0 THEN
      x_return_status := wsh_util_core.g_ret_sts_warning;
    END IF;

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
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_WMS_LPN_GRP.g_call_group_api := l_original_call_grp_api;
      IF (nvl(wsh_wms_lpn_grp.g_update_to_containers,'N') = 'Y') THEN
        wsh_wms_lpn_grp.g_update_to_containers := 'N';
      END IF;
      --
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
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      WSH_WMS_LPN_GRP.g_call_group_api := l_original_call_grp_api;
      IF (nvl(wsh_wms_lpn_grp.g_update_to_containers,'N') = 'Y') THEN
        wsh_wms_lpn_grp.g_update_to_containers := 'N';
      END IF;
      --
      --
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_LPN_SYNC_COMM_PKG.SYNC_PRORATED_LPNS_TO_WMS',l_module_name);
      WSH_WMS_LPN_GRP.g_call_group_api := l_original_call_grp_api;
      IF (nvl(wsh_wms_lpn_grp.g_update_to_containers,'N') = 'Y') THEN
        wsh_wms_lpn_grp.g_update_to_containers := 'N';
      END IF;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
  --}
  END SYNC_PRORATED_LPNS_TO_WMS;




END WSH_LPN_SYNC_COMM_PKG;

/
