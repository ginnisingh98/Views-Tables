--------------------------------------------------------
--  DDL for Package Body WSH_USA_INV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_USA_INV_PVT" as
/* $Header: WSHUSAIB.pls 120.32.12010000.14 2010/09/15 05:12:46 brana ship $ */

--G_PACKAGE_NAME         CONSTANT   VARCHAR2(50) := 'WSH_USA_INV_PVT';


-- declare the private function (Bug3012297)
FUNCTION check_inv_info  (
  p_delivery_detail_split_rec	 IN DeliveryDetailInvRecType,
  p_delivery_detail_id       	 IN NUMBER default NULL,
  p_rsv			         IN inv_reservation_global.mtl_reservation_rec_type
  ) return   BOOLEAN;


/**
   Procedure handles unassigning of delivery detail from delivery/container
   This procedure is called after detail is set to Backordered status to handle
   Wt/Vol adjustments as well as any other processing logic.
   The backordered delivery detail is unassigned from the delivery
   if the delivery is not planned
   The backordered delivery detail is unpacked if the org is wms enabled
   or if the org is not wms enabled and the delivery is not planned.
   Parameters :
   p_backorder_rec_tbl    - Input Table of Records with the following record structure:
     delivery_detail_id   - Delivery Detail which is getting backordered
     delivery_id          - Delivery of the backordered detail
     container_id         - Immediate Parent Container of the backordered detail
     organization_id      - Delivery Detail's Organization
     line_direction       - Line Direction
     planned_flag         - Delivery is Planned or not (Y/N)
     gross_weight         - Detail's Gross Weight
     net_weight           - Detail's Net Weight
     volume               - Detail's Volume
     del_batch_id         - Delivery's Pick Release Batch Id (whether created during Pick Release process)
   x_return_status        - Return Status (Success/Unexpected Error)
*/
PROCEDURE Unassign_Backordered_Details (
                                         p_backorder_rec_tbl    IN Back_Det_Rec_Tbl,
                                         p_org_info_tbl         IN WSH_PICK_LIST.Org_Params_Rec_Tbl,
                                         x_return_status        OUT NOCOPY VARCHAR2
                                        ) IS


   -- K LPN CONV. rv
   cursor l_cnt_orgn_csr (p_cnt_inst_id IN NUMBER) IS
   select organization_id
   from wsh_delivery_details
   where delivery_detail_id = p_cnt_inst_id
   and   container_flag = 'Y'
   and   source_code = 'WSH';

   -- OTM R12 : unassign delivery detail

   CURSOR c_detail_cont_planning_cur (p_detail_id IN NUMBER) IS
   SELECT ignore_for_planning
     FROM wsh_delivery_details
    WHERE delivery_detail_id = p_detail_id;

   -- End of OTM R12 : unassign delivery detail

   l_wms_org          VARCHAR2(10) := 'N';
   l_sync_tmp_rec     wsh_glbl_var_strct_grp.sync_tmp_rec_type;
   l_cnt_orgn_id      NUMBER;
   l_new_parent_detail_id NUMBER;
   l_num_warnings     NUMBER := 0;
   -- K LPN CONV. rv

   l_mdc_detail_tab   wsh_util_core.id_tab_type;
   l_dd_id            WSH_UTIL_CORE.ID_TAB_TYPE;
   l_del_tab          WSH_UTIL_CORE.Id_Tab_Type;
   l_return_status    VARCHAR2(1);
   l_new_delivery_id  WSH_DELIVERY_ASSIGNMENTS_V.DELIVERY_ID%TYPE;

   l_reprice_del_tab  WSH_UTIL_CORE.ID_TAB_TYPE;

   MARK_REPRICE_ERROR EXCEPTION;
   e_return           EXCEPTION;

   l_num_errors       NUMBER := 0;
   l_found_assigned_del  BOOLEAN;

   l_debug_on BOOLEAN;
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'UNASSIGN_BACKORDERED_DETAILS';


   -- OTM R12 : unassign delivery detail
   l_ignore_for_planning WSH_DELIVERY_DETAILS.IGNORE_FOR_PLANNING%TYPE;
   l_is_delivery_empty   VARCHAR2(1);
   l_interface_flag_tab  WSH_UTIL_CORE.COLUMN_TAB_TYPE;
   l_delivery_id_tab     WSH_UTIL_CORE.ID_TAB_TYPE;
   l_gc3_is_installed    VARCHAR2(1);
   l_call_update         VARCHAR2(1);
   -- End of OTM R12 : unassign delivery detail

   l_delivery_id_mod NUMBER; --Bug 9406326

BEGIN

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  IF l_debug_on IS NULL THEN
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
     WSH_DEBUG_SV.push(l_module_name);
     WSH_DEBUG_SV.log(l_module_name,'P_BACKORDER_REC_TBL.COUNT',P_BACKORDER_REC_TBL.COUNT);
     WSH_DEBUG_SV.log(l_module_name,'P_ORG_INFO_TBL.COUNT',P_ORG_INFO_TBL.COUNT);
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  -- OTM R12
  l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED;

  IF (l_gc3_is_installed IS NULL) THEN
    l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED;
  END IF;
  -- End of OTM R12

  -- Return back to caller if there are no records in table
  IF p_backorder_rec_tbl.COUNT = 0 THEN
     IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     RETURN;
  END IF;

  FOR i in p_backorder_rec_tbl.FIRST..p_backorder_rec_tbl.LAST LOOP --{

      l_new_delivery_id := NULL;
      l_new_parent_detail_id := NULL;
      l_cnt_orgn_id := NULL;

      SAVEPOINT unassign_backorder_details;

      -- For Pick Release cases where Delivery exists
      IF WSH_PICK_LIST.G_BATCH_ID IS NOT NULL AND p_backorder_rec_tbl(i).delivery_id IS NOT NULL THEN --{

         l_delivery_id_mod := MOD(p_backorder_rec_tbl(i).delivery_id,WSH_UTIL_CORE.C_INDEX_LIMIT) ; --Bug 9406326

         -- If the Delivery will be unassigned, then add to the list
         -- This is used to unassign empty containers from the Delivery at the end of Pick Release process
         IF p_backorder_rec_tbl(i).planned_flag = 'N'
         AND (NOT WSH_PICK_LIST.g_unassigned_delivery_ids.exists(l_delivery_id_mod)) THEN --{   --Bug 9406326 replaced p_backorder_rec_tbl(i).delivery_id with l_delivery_id_mod
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Assigning delivery to WSH_PICK_LIST.g_unassigned_delivery_ids');
           END IF;
           WSH_PICK_LIST.g_unassigned_delivery_ids(l_delivery_id_mod) := p_backorder_rec_tbl(i).delivery_id;     --Bug 9406326 replaced p_backorder_rec_tbl(i).delivery_id with l_delivery_id_mod
         END IF; --}

         -- Storing Pre-existing Assigned Deliveries to call Adjust_Planned_Flag API in Pick Release process
         -- These deliveries will not have either a batch_id or the same Pick Release batch_id
         -- This is required since some deliveries will no longer have any details from the Pick Release batch
         -- and they might have to be Planned. Hence this is stored in this table
         IF WSH_PICK_LIST.G_BATCH_ID <> NVL(p_backorder_rec_tbl(i).del_batch_id, -99) THEN --{
            IF WSH_PICK_LIST.g_assigned_del_tbl.count = 0 THEN --{
               WSH_PICK_LIST.g_assigned_del_tbl(WSH_PICK_LIST.g_assigned_del_tbl.count+1) := p_backorder_rec_tbl(i).delivery_id;
            ELSE
               l_found_assigned_del := FALSE;
               FOR j in WSH_PICK_LIST.g_assigned_del_tbl.FIRST .. WSH_PICK_LIST.g_assigned_del_tbl.LAST LOOP
                   IF WSH_PICK_LIST.g_assigned_del_tbl(j) = p_backorder_rec_tbl(i).delivery_id THEN
                      l_found_assigned_del := TRUE;
                      EXIT;
                   END IF;
               END LOOP;
               IF NOT l_found_assigned_del THEN
                  WSH_PICK_LIST.g_assigned_del_tbl(WSH_PICK_LIST.g_assigned_del_tbl.count+1) := p_backorder_rec_tbl(i).delivery_id;
               END IF;
            END IF; --}
         END IF; --}

      END IF; --}


      -- J: W/V Changes
      -- Decrement the W/V from parent(s) since the updates below will unassign the delivery detail
      -- from container and/or delivery
      IF ((p_backorder_rec_tbl(i).planned_flag = 'N' AND
           (p_backorder_rec_tbl(i).delivery_id is NOT NULL OR p_backorder_rec_tbl(i).container_id is NOT NULL))
      OR  (p_backorder_rec_tbl(i).planned_flag = 'Y' and
           p_org_info_tbl(p_backorder_rec_tbl(i).organization_id).wms_org = 'Y' AND
           p_backorder_rec_tbl(i).container_id is NOT NULL)
         ) THEN --{
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.DD_WV_Post_Process', WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;

         WSH_WV_UTILS.DD_WV_Post_Process(
            p_delivery_detail_id => p_backorder_rec_tbl(i).delivery_detail_id,
            p_diff_gross_wt      => -1 * p_backorder_rec_tbl(i).gross_weight,
            p_diff_net_wt        => -1 * p_backorder_rec_tbl(i).net_weight,
            p_diff_volume        => -1 * p_backorder_rec_tbl(i).volume,
            p_diff_fill_volume   => -1 * p_backorder_rec_tbl(i).volume,
            p_check_for_empty    => 'Y',
            x_return_status      => l_return_status);

         IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
            WSH_UTIL_CORE.Add_Message(l_return_status);
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Error in WSH_WV_UTILS.DD_WV_Post_Process ');
            END IF;
            ROLLBACK TO unassign_backorder_details;
            l_num_errors := l_num_errors + 1;
            GOTO next_record;
         END IF;
      END IF; --}

      -- Can the Update Statement below be replaced to call Unassign_Detail_From_Delivery ? 2 open issues remain :
      -- 1. Delivery can be absent.
      -- 2. Unassign Api will raise error if called for Planned Delivery. Also unpacking should be
      --    independent of unassignment

      UPDATE wsh_delivery_assignments_v
      SET    delivery_id =  decode(p_backorder_rec_tbl(i).planned_flag, 'N', null, delivery_id),
             parent_delivery_detail_id = decode(p_org_info_tbl(p_backorder_rec_tbl(i).organization_id).wms_org,
                                                'Y', null,
                                     decode(p_backorder_rec_tbl(i).planned_flag, 'N', null, parent_delivery_detail_id))
      WHERE  delivery_detail_id = p_backorder_rec_tbl(i).delivery_detail_id
      RETURNING delivery_id, parent_delivery_detail_id
      INTO l_new_delivery_id, l_new_parent_detail_id;


      -- OTM R12 : unassign delivery detail
      -- delivery_id is updated only when planned_flag = 'N', so check it
      -- Bug 7136152 : Needs to perform the following actions only when delivery
      --                    Id is not null.
      IF (l_gc3_is_installed = 'Y' AND
          p_backorder_rec_tbl(i).planned_flag = 'N' AND
p_backorder_rec_tbl(i).delivery_id IS NOT NULL) THEN

        -- grab ignore_for_planning
        OPEN c_detail_cont_planning_cur(p_backorder_rec_tbl(i).delivery_detail_id);
        FETCH c_detail_cont_planning_cur into l_ignore_for_planning;
        CLOSE c_detail_cont_planning_cur;

        IF (nvl(l_ignore_for_planning, 'N') = 'N') THEN
          l_call_update := 'Y';
          l_delivery_id_tab(1) := p_backorder_rec_tbl(i).delivery_id;
          l_is_delivery_empty := WSH_NEW_DELIVERY_ACTIONS.IS_DELIVERY_EMPTY(p_backorder_rec_tbl(i).delivery_id);

          IF (l_is_delivery_empty = WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Error in WSH_NEW_DELIVERIE_ACTIONS.IS_DELIVERY_EMPTY '||to_char(p_backorder_rec_tbl(i).delivery_id));
            END IF;
            ROLLBACK TO unassign_backorder_details;
            l_num_errors := l_num_errors + 1;
            GOTO next_record;
          ELSIF (l_is_delivery_empty = 'Y') THEN
            l_interface_flag_tab(1) := WSH_NEW_DELIVERIES_PVT.C_TMS_DELETE_REQUIRED;
          ELSIF (l_is_delivery_empty = 'N') THEN
             l_interface_flag_tab(1) := NULL;
             --Bug7608629
             --removed code which checked for gross weight
             --now irrespective of gross weight  UPDATE_TMS_INTERFACE_FLAG will be called
          END IF;

          IF l_call_update = 'Y' THEN
            WSH_NEW_DELIVERIES_PVT.UPDATE_TMS_INTERFACE_FLAG(
                    p_delivery_id_tab        => l_delivery_id_tab,
                    p_tms_interface_flag_tab => l_interface_flag_tab,
                    x_return_status          => l_return_status);

            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Error in WSH_NEW_DELIVERIES_PVT.UPDATE_TMS_INTERFACE_FLAG');
               END IF;
               ROLLBACK TO unassign_backorder_details;
               l_num_errors := l_num_errors + 1;
               GOTO next_record;
            ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error in WSH_NEW_DELIVERIES_PVT.UPDATE_TMS_INTERFACE_FLAG');
               END IF;
               RAISE e_return;
            ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Warning in WSH_NEW_DELIVERIES_PVT.UPDATE_TMS_INTERFACE_FLAG');
               END IF;
               l_num_warnings := l_num_warnings + 1;
            END IF;
          END IF;
        END IF;
      END IF; -- if OTM installed and the delivery is not planned
      -- End of OTM R12 : unassign delivery detail

      IF l_new_delivery_id IS NULL AND p_backorder_rec_tbl(i).delivery_id IS NOT NULL THEN
         -- unassignment needs to mark delivery's legs as repricing required.
         l_reprice_del_tab( l_reprice_del_tab.COUNT+1 ) := p_backorder_rec_tbl(i).delivery_id;
      END IF;

      l_mdc_detail_tab(1) := p_backorder_rec_tbl(i).delivery_detail_id;
      IF p_backorder_rec_tbl(i).planned_flag = 'N' THEN --{
         l_mdc_detail_tab(1) := p_backorder_rec_tbl(i).delivery_detail_id;
         WSH_DELIVERY_DETAILS_ACTIONS.Delete_Consol_Record(
                         p_detail_id_tab   => l_mdc_detail_tab,
                         x_return_status   => l_return_status);

         IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Error in WSH_DELIVERY_DETAILS_ACTIONS.Delete_Consol_Record');
            END IF;
            ROLLBACK TO unassign_backorder_details;
            l_num_errors := l_num_errors + 1;
            GOTO next_record;
         ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error in WSH_DELIVERY_DETAILS_ACTIONS.Delete_Consol_Record ');
            END IF;
            RAISE e_return;
         END IF;
      --}
      ELSIF p_org_info_tbl(p_backorder_rec_tbl(i).organization_id).wms_org = 'Y' THEN --{
         l_mdc_detail_tab(1) := p_backorder_rec_tbl(i).delivery_detail_id;
         WSH_DELIVERY_DETAILS_ACTIONS.Create_Consol_Record(
                         p_detail_id_tab   => l_mdc_detail_tab,
                         x_return_status   => l_return_status);

         IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Error in WSH_DELIVERY_DETAILS_ACTIONS.Create_Consol_Record');
            END IF;
            ROLLBACK TO unassign_backorder_details;
            l_num_errors := l_num_errors + 1;
            GOTO next_record;
         ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error in WSH_DELIVERY_DETAILS_ACTIONS.Create_Consol_Record');
            END IF;
            RAISE e_return;
         END IF;
      END IF; --}

      -- LPN CONV. rv
      IF nvl(l_new_parent_detail_id,-999) <> nvl(p_backorder_rec_tbl(i).container_id,-999) THEN
      --{
          open l_cnt_orgn_csr(p_backorder_rec_tbl(i).container_id);
          fetch l_cnt_orgn_csr into l_cnt_orgn_id;
          close l_cnt_orgn_csr;
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Parent Container Orgn Id Is',l_cnt_orgn_id);
          END IF;

          l_wms_org := wsh_util_validate.check_wms_org(l_cnt_orgn_id);

          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          AND p_backorder_rec_tbl(i).line_direction IN ('O', 'IO')
          AND
          (
            (WSH_WMS_LPN_GRP.GK_WMS_UNPACK and l_wms_org = 'Y')
            OR
            (WSH_WMS_LPN_GRP.GK_INV_UNPACK and l_wms_org = 'N')
          )
          THEN
          --{
              --
              l_sync_tmp_rec.delivery_detail_id := p_backorder_rec_tbl(i).delivery_detail_id;
              l_sync_tmp_rec.parent_delivery_detail_id := p_backorder_rec_tbl(i).container_id;
              l_sync_tmp_rec.delivery_id := p_backorder_rec_tbl(i).delivery_id;
              l_sync_tmp_rec.operation_type := 'PRIOR';
              --
              WSH_WMS_SYNC_TMP_PKG.MERGE
                (
                  p_sync_tmp_rec      => l_sync_tmp_rec,
                  x_return_status     => l_return_status
                );
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return Status',l_return_status);
              END IF;
              IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Error in WSH_WMS_SYNC_TMP_PKG.MERGE ');
                 END IF;
                 ROLLBACK TO unassign_backorder_details;
                 l_num_errors := l_num_errors + 1;
                 GOTO next_record;
              ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected Error in WSH_WMS_SYNC_TMP_PKG.MERGE ');
                 END IF;
                 RAISE e_return;
              ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                 l_num_warnings := l_num_warnings + 1;
              END IF;
          --}
          END IF;
      --}
      END IF;
      -- LPN CONV. rv

      IF p_backorder_rec_tbl(i).delivery_id IS NOT NULL OR p_backorder_rec_tbl(i).container_id IS NOT NULL THEN --{
      --
        --Bug9575761 Added condition p_backorder_rec_tbl(i).planned_flag <> 'Y'
         IF (p_backorder_rec_tbl(i).delivery_id IS NOT NULL) AND (p_backorder_rec_tbl(i).planned_flag <> 'Y') THEN --{
            l_del_tab(1) := p_backorder_rec_tbl(i).delivery_id;
            WSH_TP_RELEASE.calculate_cont_del_tpdates(
                  p_entity        => 'DLVY',
                  p_entity_ids    => l_del_tab,
                  x_return_status => l_return_status);
         ELSIF p_backorder_rec_tbl(i).container_id IS NOT NULL THEN
            l_del_tab(1) := p_backorder_rec_tbl(i).container_id;
            WSH_TP_RELEASE.calculate_cont_del_tpdates(
                  p_entity        => 'DLVB',
                  p_entity_ids    => l_del_tab,
                  x_return_status => l_return_status);
         END IF; --}
         -- Common Error Handling for above APIs
         IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN --{
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Error in WSH_TP_RELEASE.calculate_cont_del_tpdates ');
            END IF;
            ROLLBACK TO unassign_backorder_details;
            l_num_errors := l_num_errors + 1;
            GOTO next_record;
         ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected Error in WSH_TP_RELEASE.calculate_cont_del_tpdates ');
            END IF;
            RAISE e_return;
          ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            l_num_warnings := l_num_warnings + 1;
          END IF; --}
      END IF; --}

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Updated wsh_delivery_assignments_v for backordered_delivery_detail ' ,p_backorder_rec_tbl(i).delivery_detail_id);
      END IF;

      -- FP bug 4208538 from bug 4075078
      --   Freight costs need to be deleted for the delivery detail if
      --   calculated by FTE AND detail is unassigned from the delivery.
      --   If backordered line remains assigned to delivery, it can retain
      --   freight costs.
      --     Bug 2769639 fixes this in the API Unassign_Detail_From_Delivery,
      --     and it needs to be incorporated here as well.
      IF WSH_UTIL_CORE.FTE_Is_Installed = 'Y' AND l_new_delivery_id IS NULL  THEN --{
         l_dd_id(1) := p_backorder_rec_tbl(i).delivery_detail_id;

         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Call WSH_FREIGHT_COSTS_PVT.Remove_FTE_Freight_Costs',p_backorder_rec_tbl(i).delivery_detail_id);
         END IF;

         WSH_FREIGHT_COSTS_PVT.Remove_FTE_Freight_Costs(
             p_delivery_details_tab => l_dd_id,
             x_return_status        => l_return_status) ;

         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'After WSH_FREIGHT_COSTS_PVT.Remove_FTE_Freight_Costs: return',l_return_status);
         END IF;

         IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN --{
            FND_MESSAGE.Set_Name('WSH', 'WSH_REPRICE_REQUIRED_ERR');
            WSH_UTIL_CORE.add_message(l_return_status, l_module_name);
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Remove_FTE_Freight_Costs failed');
            END IF;
            ROLLBACK TO unassign_backorder_details;
            l_num_errors := l_num_errors + 1;
            GOTO next_record;
          ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            l_num_warnings := l_num_warnings + 1;
          END IF; --}
      END IF; --}

      -- J: W/V Changes
      -- Adjust the W/V back on delivery since the dd gets unassigned from container but stays on delivery
      -- in the following case
      IF  p_org_info_tbl(p_backorder_rec_tbl(i).organization_id).wms_org = 'Y'
      AND p_backorder_rec_tbl(i).planned_flag = 'Y' AND p_backorder_rec_tbl(i).delivery_id is NOT NULL
      AND p_backorder_rec_tbl(i).container_id is NOT NULL THEN --{
          IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.DD_WV_Post_Process'
                                              ,WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          WSH_WV_UTILS.DD_WV_Post_Process(
            p_delivery_detail_id => p_backorder_rec_tbl(i).delivery_detail_id,
            p_diff_gross_wt      => p_backorder_rec_tbl(i).gross_weight,
            p_diff_net_wt        => p_backorder_rec_tbl(i).net_weight,
            p_diff_volume        => p_backorder_rec_tbl(i).volume,
            p_diff_fill_volume   => p_backorder_rec_tbl(i).volume,
            x_return_status      => l_return_status);

          IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
             WSH_UTIL_CORE.Add_Message(l_return_status);
             IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Error in WSH_WV_UTILS.DD_WV_Post_Process ');
             END IF;
             ROLLBACK TO unassign_backorder_details;
             l_num_errors := l_num_errors + 1;
             GOTO next_record;
          END IF;
      END IF; --}

      << next_record >>
      NULL;

  END LOOP; --}

  IF l_reprice_del_tab.COUNT > 0 THEN --{
     WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required(
		  p_entity_type   => 'DELIVERY',
		  p_entity_ids    => l_reprice_del_tab,
		  x_return_status => l_return_status);
     IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Mark_Reprice_Required l_return_status',l_return_status);
     END IF;
     IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
        RAISE MARK_REPRICE_ERROR;
     END IF;
  END IF; --}

  IF (l_num_errors > 0) THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  ELSIF (l_num_warnings > 0) THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
  END IF;

  IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION

  WHEN MARK_REPRICE_ERROR THEN
       x_return_status := l_return_status;
       FND_MESSAGE.SET_NAME('WSH', 'WSH_REPRICE_REQUIRED_ERR');
       WSH_UTIL_CORE.add_message(l_return_status,l_module_name);
       -- OTM R12 : unassign delivery detail
       IF (c_detail_cont_planning_cur%ISOPEN) THEN
         CLOSE c_detail_cont_planning_cur;
       END IF;
       -- End of OTM R12 : unassign delivery detail
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'MARK_REPRICE_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:MARK_REPRICE_ERROR');
       END IF;

  WHEN e_return THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       WSH_UTIL_CORE.default_handler('WSH_USA_INV_PVT.unassign_backordered_details');
       -- OTM R12 : unassign delivery detail
       IF (c_detail_cont_planning_cur%ISOPEN) THEN
         CLOSE c_detail_cont_planning_cur;
       END IF;
       -- End of OTM R12 : unassign delivery detail
       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'UNASSIGN_BACKORDERED_DETAILS e_return exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:UNASSIGN_BACKORDERED_DETAILS');
       END IF;

  WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       WSH_UTIL_CORE.default_handler('WSH_USA_INV_PVT.unassign_backordered_details');
       -- OTM R12 : unassign delivery detail
       IF (c_detail_cont_planning_cur%ISOPEN) THEN
         CLOSE c_detail_cont_planning_cur;
       END IF;
       IF (l_cnt_orgn_csr%ISOPEN) THEN
         CLOSE l_cnt_orgn_csr;
       END IF;
       -- End of OTM R12 : unassign delivery detail
       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'UNASSIGN_BACKORDERED_DETAILS exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:UNASSIGN_BACKORDERED_DETAILS');
       END IF;

END Unassign_Backordered_Details;


-- Bug 2573434 : new local procedure added
/**
   Procedure handles backorder of lines
   This API updates the delivery detail and calls unassign_backordered_detail for
   unassignment and other post processing calls
   Parameters :
   p_delivery_detail_id   - Delivery Detail which is getting backordered
   p_requested_quantity   - Requested quantity
   p_requested_quantity2  - Requested quantity2
   p_planned_flag         - Delivery is Planned or not (Y/N)
   p_wms_enabled_flag     - Organization is WMS Organization or not (Y/N)
   p_del_batch_id         - Delivery's Pick Release Batch Id
   x_split_quantity       - Split Quantity
   x_return_status        - Return Status (Success/Unexpected Error)
*/
PROCEDURE backorder_delivery_detail (
                                        p_delivery_detail_id   IN  NUMBER,
                                        p_requested_quantity   IN  NUMBER,
                                        p_requested_quantity2  IN  NUMBER,
                                        p_planned_flag         IN  VARCHAR2,
                                        p_wms_enabled_flag     IN  VARCHAR2,
                                        p_replenishment_status  IN VARCHAR2 DEFAULT NULL,  --bug# 6689448 (replenishment project)
                                        p_del_batch_id         IN  NUMBER,
                                        x_split_quantity       OUT NOCOPY NUMBER,
                                        x_return_status        OUT NOCOPY VARCHAR2
                                    ) IS

-- J: W/V Changes
CURSOR C1 is
select parent_delivery_detail_id,
       delivery_id
from   wsh_delivery_assignments_v
where  delivery_detail_id = p_delivery_detail_id;
l_container_id NUMBER;
l_delivery_id  NUMBER;
l_gross_weight NUMBER;
l_net_weight   NUMBER;
l_volume       NUMBER;
l_return_status VARCHAR2(1);

l_user_id  NUMBER;
l_login_id NUMBER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'BACKORDER_DELIVERY_DETAIL';
--

l_detail_tab WSH_UTIL_CORE.id_tab_type;  -- DBI Project
l_dbi_rs        VARCHAR2(1);             -- DBI Project
l_dd_txn_id    NUMBER;    -- DBI Project
l_txn_return_status  VARCHAR2(1);		-- DBI Project
l_wf_rs        VARCHAR2(1);             -- Pick To POD WF project
l_standalone_mode  VARCHAR2(1); -- standalone project changes


 --Begin OPM Bug 3561937

  CURSOR get_pref_grade(wdd_id NUMBER) IS
  SELECT oelines.preferred_grade,
         wdd.organization_id,   -- LPN CONV. rv
         nvl(wdd.line_direction,'O') -- LPN CONV. rv
  FROM   oe_order_lines_all oelines, wsh_delivery_details wdd
  WHERE  wdd.delivery_detail_id = wdd_id
  AND    wdd.source_code        = 'OE'
  AND    wdd.source_line_id     = oelines.line_id;


  l_organization_id     NUMBER;
-- HW OPMCONV - changed size of grade to 150
  l_oeline_pref_grade   VARCHAR2(150) := NULL;
  l_line_direction   VARCHAR2(10);

  l_backorder_rec_tbl    Back_Det_Rec_Tbl;
  l_org_info_tbl         WSH_PICK_LIST.Org_Params_Rec_Tbl;

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
  -- Standalone project Changes
  l_standalone_mode := WMS_DEPLOY.wms_deployment_mode;
  IF l_debug_on THEN
     WSH_DEBUG_SV.push(l_module_name);
     --
     WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_DETAIL_ID',P_DELIVERY_DETAIL_ID);
     WSH_DEBUG_SV.log(l_module_name,'P_REQUESTED_QUANTITY',P_REQUESTED_QUANTITY);
     WSH_DEBUG_SV.log(l_module_name,'P_REQUESTED_QUANTITY2',P_REQUESTED_QUANTITY2);
     WSH_DEBUG_SV.log(l_module_name,'P_PLANNED_FLAG',P_PLANNED_FLAG);
     WSH_DEBUG_SV.log(l_module_name,'P_WMS_ENABLED_FLAG',P_WMS_ENABLED_FLAG);
     WSH_DEBUG_SV.log(l_module_name,'P_DEL_BATCH_ID',P_DEL_BATCH_ID);
     WSH_DEBUG_SV.log(l_module_name,'P_REPLENISHMENT_STATUS',p_replenishment_status);
     WSH_DEBUG_SV.log(l_module_name,'l_standalone_mode',l_standalone_mode);
  END IF;
  --

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  -- J: W/V Changes
  OPEN  C1;
  FETCH C1 INTO l_container_id, l_delivery_id;
  CLOSE C1;

  l_user_id  := FND_GLOBAL.user_id;
  l_login_id := FND_GLOBAL.login_id;

  OPEN  get_pref_grade(p_delivery_detail_id);
  FETCH get_pref_grade INTO l_oeline_pref_grade,
                            l_organization_id, l_line_direction; -- LPN CONV. rv
  CLOSE get_pref_grade;

  UPDATE wsh_delivery_details
  SET    released_status     = DECODE(requested_quantity, 0, 'D', decode(pickable_flag,'Y','B','X')) ,
         requested_quantity  = DECODE(p_requested_quantity,  NULL, requested_quantity,  p_requested_quantity),
         requested_quantity2 = DECODE(p_requested_quantity2, NULL, requested_quantity2, p_requested_quantity2),
         subinventory        = original_subinventory,
         --standalone project changes: start
         locator_id          = DECODE(l_standalone_mode,'D',original_locator_id ,NULL) ,
         lot_number          = DECODE(l_standalone_mode,'D',original_lot_number ,NULL) ,
         revision            = DECODE(l_standalone_mode,'D',original_revision ,NULL) ,
         -- standalone project changes: end
         move_order_line_id  = DECODE(requested_quantity, 0, move_order_line_id, NULL),--Bug 2114166
         picked_quantity     = NULL,
         picked_quantity2    = NULL,
         preferred_grade     = l_oeline_pref_grade,
         serial_number       = NULL,
         -- Batch_id is required for additional processing in Release_Batch API and hence this is retained for Pick Release
         -- Pick Release sets batch_id as Null for backordered details at the end of Pick Release process
         batch_id            = WSH_PICK_LIST.G_BATCH_ID,
         lpn_id              = NULL,
         last_update_date    = SYSDATE,
         last_updated_by     = l_user_id,
         last_update_login   = l_login_id,
         transaction_id      = NULL,
         replenishment_status = p_replenishment_status --bug# 6689448 (replenishment project)
  WHERE  delivery_detail_id  = p_delivery_detail_id
  RETURNING requested_quantity, gross_weight, net_weight, volume, organization_id
  INTO      x_split_quantity, l_gross_weight, l_net_weight, l_volume, l_organization_id;
  --Added organization_id for raise event: Pick to POD workflow

  --
  -- DBI Project
  -- Update of wsh_delivery_details where released_status
  -- are changed, call DBI API after the update.
  -- This API will also check for DBI Installed or not
  --DBI
  WSH_DD_TXNS_PVT. create_dd_txn_from_dd (
 					   p_delivery_detail_id => p_delivery_detail_id,
 				   	   x_dd_txn_id => l_dd_txn_id,
 				   	   x_return_status =>l_txn_return_status);
  IF (l_txn_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
      x_return_status := l_txn_return_status;
      RETURN;
  END IF;
  --DBI

  --bug# 6719369 (replenishment project) : replenishment case, invoke replenishment requested business event.
  IF ( p_replenishment_status IS NULL ) THEN
  --{
      --Raise Event : Pick To Pod Workflow
      WSH_WF_STD.Raise_Event(
         		  p_entity_type => 'LINE',
			  p_entity_id => p_delivery_detail_id ,
			  p_event => 'oracle.apps.wsh.line.gen.backordered' ,
			  p_organization_id => l_organization_id,
			  x_return_status => l_wf_rs ) ;
      IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Current Time is ',SYSDATE);
          WSH_DEBUG_SV.log(l_module_name,'Delivery Detail Id is  ',p_delivery_detail_id );
          wsh_debug_sv.log(l_module_name,'Return Status After Calling WSH_WF_STD.Raise_Event',l_wf_rs);
      END IF;
      --Done Raise Event: Pick To Pod Workflow
  ELSE
      WSH_WF_STD.Raise_Event(
			  p_entity_type => 'LINE',
			  p_entity_id => p_delivery_detail_id ,
			  p_event => 'oracle.apps.wsh.line.gen.replenishmentrequested' ,
			  p_organization_id => l_organization_id,
			  x_return_status => l_wf_rs ) ;
      IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Current Time is ',SYSDATE);
          WSH_DEBUG_SV.log(l_module_name,'Delivery Detail Id is  ',p_delivery_detail_id );
          wsh_debug_sv.log(l_module_name,'Return Status After Calling WSH_WF_STD.Raise_Event',l_wf_rs);
      END IF;
  --}
  END IF;


  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Detail id-',p_delivery_detail_id);
  END IF;
  l_detail_tab(1) := p_delivery_detail_id;
  WSH_INTEGRATION.DBI_Update_Detail_Log
    (p_delivery_detail_id_tab => l_detail_tab,
     p_dml_type               => 'UPDATE',
     x_return_status          => l_dbi_rs);

  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
  END IF;
  IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
     x_return_status := l_dbi_rs;
     -- just pass this return status to caller API
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'DBI API Returned Unexpected error '||x_return_status);
        WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     return;
  END IF;
  -- End of Code for DBI Project
  --
  --bug# 6719369 (replenishment2 project) : Unassigning delivery needs to be done only for back order delivery lines and not for
  -- replenishment requested lines.
  IF ( p_replenishment_status IS NULL ) THEN
  --{
      IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Updated wsh_delivery_details for backordered_delivery_detail ' ,p_delivery_detail_id);
      END IF;
      -- If Pick Release is run in Parallel Mode, then Unassigning is Deferred
      -- Unassignment API is later called from WSH_PICK_LIST.Release_Batch API
      -- For backordering in other cases or Non-Parallel Pick Release, unassign api is called immediately
      IF WSH_PICK_LIST.G_PICK_REL_PARALLEL IS NULL OR (NOT WSH_PICK_LIST.G_PICK_REL_PARALLEL) THEN --{
         -- Assigning all values to Backorder Table of Record
         l_backorder_rec_tbl(1).delivery_detail_id := p_delivery_detail_id;
         l_backorder_rec_tbl(1).delivery_id        := l_delivery_id;
         l_backorder_rec_tbl(1).container_id       := l_container_id;
         l_backorder_rec_tbl(1).organization_id    := l_organization_id;
         l_backorder_rec_tbl(1).line_direction     := l_line_direction;
         l_backorder_rec_tbl(1).planned_flag       := p_planned_flag;
         l_backorder_rec_tbl(1).gross_weight       := l_gross_weight;
         l_backorder_rec_tbl(1).net_weight         := l_net_weight;
         l_backorder_rec_tbl(1).volume             := l_volume;
         l_backorder_rec_tbl(1).del_batch_id       := p_del_batch_id;

         -- Assigning wms flag in Org Table Info
         l_org_info_tbl(l_organization_id).wms_org := p_wms_enabled_flag;

         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Unassign_Backordered_Details',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         Unassign_Backordered_Details (
                                       p_backorder_rec_tbl    =>  l_backorder_rec_tbl,
                                       p_org_info_tbl         =>  l_org_info_tbl,
                                       x_return_status        =>  l_return_status );

         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'After Unassign_Backordered_Details: return',l_return_status);
         END IF;
         IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            WSH_UTIL_CORE.Add_Message(x_return_status);
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'Return Status',x_return_status);
               WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            RETURN;
         ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            IF x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
               x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
            END IF;
         END IF;
      --}
      ELSE
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Deferring call to Unassign_Backordered_Details for detail : '||p_delivery_detail_id);
         END IF;
      END IF;
  --}
  END IF;

  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'Return Status at the end of backorder_delivery_detail API is',x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION

        WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          WSH_UTIL_CORE.default_handler('WSH_USA_INV_PVT.backorder_delivery_detail');
          IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'BACKORDER_DELIVERY_DETAIL_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:BACKORDER_DELIVERY_DETAIL');
          END IF;

END backorder_delivery_detail;

-- This procedure is used to find out how much of reservations need to be
-- transferred. It returns total staged and unstaged reservations

-- HW OPMCONV - Added Qty2
PROCEDURE Get_total_reserved_quantity (p_source_code  IN VARCHAR2 ,
         p_source_header_id   IN NUMBER ,
         p_source_line_id     IN NUMBER ,
         p_organization_id    IN NUMBER ,
         x_total_rsv          IN OUT NOCOPY NUMBER ,
         x_total_rsv2         IN OUT NOCOPY NUMBER ,
         x_return_status      IN OUT NOCOPY VARCHAR2)
IS
l_rsv_array inv_reservation_global.mtl_reservation_tbl_type;
l_size      NUMBER ;
l_return_status VARCHAR2(1);

l_msg_count   NUMBER;
l_msg_data  VARCHAR2(2000);
l_staged_flag  VARCHAR2(1);

totals_failed   EXCEPTION;

-- HW OPMCONV - Added debug variable
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'GET_TOTAL_RESERVED_QUANTITY';
BEGIN

  --
  -- Debug Statements
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
     -- add more debug messages
     WSH_DEBUG_SV.push(l_module_name);
     WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
     WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_HEADER_ID',P_SOURCE_HEADER_ID);
     WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_LINE_ID',P_SOURCE_LINE_ID);
     WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
  END IF;
  --

  x_total_rsv := 0 ;
-- HW OPMCONV - Added Qty2
  x_total_rsv2 := 0 ;

  query_reservations  (
         p_source_code                 => p_source_code,
         p_source_header_id            => p_source_header_id,
         p_source_line_id              => p_source_line_id,
         p_organization_id             => p_organization_id,
         p_lock_records                => fnd_api.g_true,
         p_delivery_detail_id          => null, --X-dock
         x_mtl_reservation_tbl         => l_rsv_array,
         x_mtl_reservation_tbl_count   => l_size,
         x_return_status               => l_return_status);

   IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
     raise totals_failed;
   END IF;

   IF l_size = 0 THEN  -- This case is specific for non staged reservations as
     RETURN;      -- for a backordered DD reservations might or might not exist
   END IF;

   oe_debug_pub.add('In Get_total_Reserved_quantity ',2);
   oe_debug_pub.add('x_total_rsv , l_rsv_array(i).primary_reservation_quantity ,     l_rsv_array(i).requirement_Date   ',2);

   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'x_total_rsv2',x_total_rsv2);
   END IF;

   FOR i in 1..l_rsv_array.count
   LOOP

   x_total_rsv := x_total_rsv +  l_rsv_array(i).primary_reservation_quantity ;
         oe_debug_pub.add(x_total_rsv || ' : ' ||  l_rsv_array(i).primary_reservation_quantity || ' : ' ||   l_rsv_array(i).requirement_Date ,2);
-- HW OPMCONV - Get Qty2
   x_total_rsv2 := x_total_rsv2 +  l_rsv_array(i).secondary_reservation_quantity ;
   IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'x_total_rsv2',x_total_rsv2);
   END IF;

   END LOOP ;

   IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
   END IF;

EXCEPTION
    WHEN totals_failed THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_UTIL_CORE.add_message (x_return_status);
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'GET_TOTAL_RESERVED_QUANTITY exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:GET_TOTAL_RESERVED_QUANTITY');
      END IF;

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.default_handler('WSH_USA_INV_PVT.Get_total_Reserved_quantity');
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;

END Get_total_Reserved_quantity  ;


-- This is a wrapper on inv_reservation_pub.query_reservation_om_hdr_line
-- X-dock, added parameter p_delivery_detail_id
PROCEDURE  query_reservations  (
 p_source_code             IN  VARCHAR2,
 p_source_header_id        IN  NUMBER,
 p_source_line_id          IN  NUMBER,
 p_organization_id         IN  NUMBER,
 p_lock_records            IN  VARCHAR2,
 p_cancel_order_mode       IN  NUMBER,
 p_direction_flag          IN VARCHAR2 ,
 p_delivery_detail_id      IN NUMBER,
 x_mtl_reservation_tbl     OUT NOCOPY  inv_reservation_global.mtl_reservation_tbl_type,
 x_mtl_reservation_tbl_count   OUT NOCOPY  NUMBER,
 x_return_status           OUT NOCOPY  VARCHAR2)

IS
l_rsv    inv_reservation_global.mtl_reservation_rec_type;
l_msg_count   NUMBER;
l_msg_data  VARCHAR2(2000);
l_error_text  VARCHAR2(6000);
l_error_code  NUMBER;
l_sales_order_id  NUMBER;
l_sort_by_req_date NUMBER ;
query_reservation_failed   EXCEPTION;


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'QUERY_RESERVATIONS';
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
        WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
        WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_HEADER_ID',P_SOURCE_HEADER_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_LINE_ID',P_SOURCE_LINE_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_LOCK_RECORDS',P_LOCK_RECORDS);
        WSH_DEBUG_SV.log(l_module_name,'P_CANCEL_ORDER_MODE',P_CANCEL_ORDER_MODE);
        WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_DETAIL_ID',P_DELIVERY_DETAIL_ID);
    END IF;
    --
    --
    -- Debug Statements
    --
   IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name, 'IN WSH_USA_INV_PVT.QUERY_RESERVATIONS ORDER LINE = '|| P_SOURCE_LINE_ID  );
   END IF;
    --
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit OE_ORDER_SCH_UTIL.GET_MTL_SALES_ORDER_ID',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   l_sales_order_id
           := OE_ORDER_SCH_UTIL.Get_mtl_sales_order_id(p_source_header_id);
   IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'l_sales_order_id',l_sales_order_id);
   END IF;
   l_rsv.demand_source_header_id      := l_sales_order_id;
   l_rsv.demand_source_line_id      := p_source_line_id;
   l_rsv.organization_id          := p_organization_id;
   l_rsv.demand_source_line_detail  := p_delivery_detail_id; -- X-dock

   l_sort_by_req_date := inv_reservation_global.g_query_no_sort ;

   if p_direction_flag = 'L' then
      -- The following statment is commented because we ideally need this code , but
      -- we cannot since it will mean we have to include INV's patch .
      -- When front-porting to newer releases , please use this statment instead of the following hard-coding.
      -- l_sort_by_req_date := inv_reservation_global.g_query_req_date_inv_desc ;
      l_sort_by_req_date := 5 ;
         elsif p_direction_flag = 'F' then
      -- l_sort_by_req_date := inv_reservation_global.g_query_req_date_inv_asc ;
      l_sort_by_req_date := 4 ;
   end if ;
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_RESERVATION_PUB.QUERY_RESERVATION_OM_HDR_LINE',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   INV_RESERVATION_PUB.query_reservation_om_hdr_line
    (
       p_api_version_number   => 1.0
     , p_init_msg_lst       => fnd_api.g_true
     , x_return_status       => x_return_status
     , x_msg_count         => l_msg_count
     , x_msg_data         => l_msg_data
     , p_query_input         => l_rsv
     , p_cancel_order_mode     => p_cancel_order_mode
     , x_mtl_reservation_tbl     => x_mtl_reservation_tbl
     , x_mtl_reservation_tbl_count => x_mtl_reservation_tbl_count
     , x_error_code       => l_error_code
     , p_lock_records       => p_lock_records
     );
   IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'query_reservation_om_hdr_line x_return_status',x_return_status);
   END IF;


    IF x_return_status = fnd_api.g_ret_sts_success THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'NUMBER OF RESERVATIONS FOUND: '||TO_CHAR ( X_MTL_RESERVATION_TBL_COUNT )  );
      END IF;
      --
    ELSE
     FND_MESSAGE.Set_Name('WSH', 'WSH_QUERY_RESERVATION');
     IF l_msg_count = 1 THEN
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR: '|| L_MSG_DATA  );
       END IF;
       --
       FND_MESSAGE.Set_Token('ERROR_TEXT',l_msg_data);
     ELSE
       FOR l_index IN 1..l_msg_count LOOP
       l_msg_data := fnd_msg_pub.get;
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR: '|| L_MSG_DATA  );
       END IF;
       --
       l_error_text := l_error_text || l_msg_data;
       END LOOP;
       FND_MESSAGE.Set_Token('ERROR_TEXT',l_error_text);
     END IF;
     raise query_reservation_failed;
    END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
    WHEN query_reservation_failed THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
          IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'QUERY_RESERVATION_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:QUERY_RESERVATION_FAILED');
          END IF;
END QUERY_RESERVATIONS;

-- This is a wrapper on inv_reservation_pub.delete_reservation
PROCEDURE  delete_reservation (
 p_query_input           IN  inv_reservation_global.mtl_reservation_rec_type,
 x_return_status         OUT NOCOPY  VARCHAR2)
IS
l_msg_count NUMBER;
l_msg_data  VARCHAR2(2000);
l_error_text  VARCHAR2(6000);
l_dummy_sn  INV_RESERVATION_GLOBAL.serial_number_tbl_type;
delete_reservation_failed   EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'DELETE_RESERVATION';
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
         WSH_DEBUG_SV.logmsg(l_module_name, 'IN WSH_USA_INV_PVT.DELETE_RESERVATION ORDER LINE = '|| P_QUERY_INPUT.DEMAND_SOURCE_LINE_ID  );
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_RESERVATION_PUB.DELETE_RESERVATION',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;

     INV_RESERVATION_PUB.delete_reservation
    (
       p_api_version_number   => 1.0
     , p_init_msg_lst       => fnd_api.g_true
     , x_return_status       => x_return_status
     , x_msg_count         => l_msg_count
     , x_msg_data         => l_msg_data
     , p_rsv_rec           => p_query_input
     , p_serial_number       => l_dummy_sn
     );
     IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'delete_reservation x_return_status',x_return_status);
     END IF;

    IF x_return_status = fnd_api.g_ret_sts_success THEN
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'RESERVATION DELETED FOR RESERVATION ID : '||P_QUERY_INPUT.RESERVATION_ID  );
     END IF;
     --
    ELSE
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'COULD NOT DELETE RESERVATION FOR RESERVATION ID : '||P_QUERY_INPUT.RESERVATION_ID  );
     END IF;
     --
     FND_MESSAGE.Set_Name('WSH', 'WSH_DELETE_RESERVATION');
     IF l_msg_count = 1 THEN
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR: '|| L_MSG_DATA  );
       END IF;
       --
       FND_MESSAGE.Set_Token('ERROR_TEXT',l_msg_data);
     ELSE
       FOR l_index IN 1..l_msg_count LOOP
       l_msg_data := fnd_msg_pub.get;
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR: '|| L_MSG_DATA  );
       END IF;
       --
       l_error_text := l_error_text || l_msg_data;
       END LOOP;
       FND_MESSAGE.Set_Token('ERROR_TEXT',l_error_text);
     END IF;
     raise delete_reservation_failed;
    END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
    WHEN delete_reservation_failed THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'DELETE_RESERVATION_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:DELETE_RESERVATION_FAILED');
    END IF;
    --
END delete_reservation;

-- This is a wrapper on inv_reservation_pub.create_reservation
-- HW OPMCONV Pass Qty2 in order to call the correct INV_create_reservation
PROCEDURE  create_reservation (
 p_query_input           IN  inv_reservation_global.mtl_reservation_rec_type,
 p_qty2                  IN NUMBER default NULL,
 x_reservation_id       OUT NOCOPY  NUMBER,
 x_qty_reserved         OUT NOCOPY  NUMBER,
 x_return_status         OUT NOCOPY  VARCHAR2)

IS

l_msg_count NUMBER;
l_msg_data  VARCHAR2(2000);
l_error_text  VARCHAR2(6000);
l_dummy_sn  INV_RESERVATION_GLOBAL.serial_number_tbl_type;

-- HW OPMCONV - Added variable
X_SECONDARY_QTY_RESERVED         NUMBER;

create_reservation_failed   EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'CREATE_RESERVATION';
--
BEGIN
   /* if OPM do null */
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
       WSH_DEBUG_SV.log(l_module_name, 'p_query_input.organization_id',p_query_input.organization_id);
   END IF;
   --
   --
   -- Debug Statements
   --

-- HW OPMCONV. Removed forking
    --
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'IN WSH_USA_INV_PVT.CREATE_RESERVATION '  );
    END IF;
    --

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_RESERVATION_PUB.CREATE_RESERVATION',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --


-- HW OPMCONV check if qty2 exists to call the correct API
    IF ( p_qty2 is NULL OR p_qty2 = FND_API.G_MISS_NUM )  THEN
    INV_RESERVATION_PUB.create_reservation
    (
     p_api_version_number   => 1.0
     , p_init_msg_lst       => fnd_api.g_true
     , x_return_status       => x_return_status
     , x_msg_count         => l_msg_count
     , x_msg_data         => l_msg_data
     , p_rsv_rec           => p_query_input
     , p_serial_number       => l_dummy_sn
     , x_serial_number       => l_dummy_sn
     , p_partial_reservation_flag  => fnd_api.g_true
     , p_force_reservation_flag => fnd_api.g_false
     , p_validation_flag       => fnd_api.g_true
     -- bug 5333667: remove p_over_reservation_flag added by bug 5099694
     --              because it is necessary to validate the new reservation.
     , x_quantity_reserved     => x_qty_reserved
     , x_reservation_id     => x_reservation_id
     );
    ELSE
      INV_RESERVATION_PUB.create_reservation
    (
     p_api_version_number   => 1.0
     , p_init_msg_lst       => fnd_api.g_true
     , x_return_status       => x_return_status
     , x_msg_count         => l_msg_count
     , x_msg_data         => l_msg_data
     , p_rsv_rec           => p_query_input
     , p_serial_number       => l_dummy_sn
     , x_serial_number       => l_dummy_sn
     , p_partial_reservation_flag  => fnd_api.g_true
     , p_force_reservation_flag => fnd_api.g_false
     -- Bug 5099694
     , p_over_reservation_flag  =>3
     , p_validation_flag       => fnd_api.g_true
     , x_quantity_reserved     => x_qty_reserved
     , x_secondary_quantity_reserved     => x_secondary_qty_reserved
     , x_reservation_id     => x_reservation_id
     );
    END IF;
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'INV_RESERVATION_PUB.CREATE_RESERVATION',x_return_status);
    END IF;

    IF x_return_status = fnd_api.g_ret_sts_success THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'RESERVATION CREATED FOR RESERVATION ID : '||X_RESERVATION_ID  );
      END IF;
      --
    ELSE
     FND_MESSAGE.Set_Name('WSH', 'WSH_CREATE_RESERVATION');
     IF l_msg_count = 1 THEN
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR: '|| L_MSG_DATA  );
       END IF;
       --
       FND_MESSAGE.Set_Token('ERROR_TEXT',l_msg_data);
     ELSE
       FOR l_index IN 1..l_msg_count LOOP
       l_msg_data := fnd_msg_pub.get;
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR: '|| L_MSG_DATA  );
       END IF;
       --
       l_error_text := l_error_text || l_msg_data;
       END LOOP;
       FND_MESSAGE.Set_Token('ERROR_TEXT',l_error_text);
     END IF;
     raise create_reservation_failed;
    END IF;
-- HW OPMCONV  removed forking


--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
    WHEN create_reservation_failed THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'CREATE_RESERVATION_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:CREATE_RESERVATION_FAILED');
    END IF;
    --
END;


-- This is a wrapper on inv_reservation_pub.update_reservation
PROCEDURE  update_reservation (
 p_query_input           IN  inv_reservation_global.mtl_reservation_rec_type,
 p_new_resv_rec         IN inv_reservation_global.mtl_reservation_rec_type,
 x_return_status         OUT NOCOPY  VARCHAR2)

IS

l_msg_count NUMBER;
l_msg_data  VARCHAR2(2000);
l_error_text  VARCHAR2(6000);
l_dummy_sn  INV_RESERVATION_GLOBAL.serial_number_tbl_type;

update_reservation_failed   EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'UPDATE_RESERVATION';
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
         WSH_DEBUG_SV.log(l_module_name,'p_query_input.reservation_id',p_query_input.reservation_id);
         WSH_DEBUG_SV.log(l_module_name,'p_query_input.organization_id',p_query_input.organization_id);
         WSH_DEBUG_SV.log(l_module_name,'p_query_input.inventory_item_id',p_query_input.inventory_item_id);
         WSH_DEBUG_SV.log(l_module_name,'p_new_resv_rec.reservation_id',p_new_resv_rec.reservation_id);
         WSH_DEBUG_SV.log(l_module_name,'p_new_resv_rec.organization_id',p_new_resv_rec.organization_id);
         WSH_DEBUG_SV.log(l_module_name,'p_new_resv_rec.inventory_item_id',p_new_resv_rec.inventory_item_id);

          WSH_DEBUG_SV.logmsg(l_module_name, 'DEBUGGING IN UPDATE RESER' );
          WSH_DEBUG_SV.logmsg(l_module_name, 'p_new_resv_recsecondary_reservation_quantity '||p_new_resv_rec.secondary_reservation_quantity  );
          WSH_DEBUG_SV.logmsg(l_module_name, 'p_new_resv_rec.secondary_UOM_CODE '||p_new_resv_rec.secondary_uom_code );
          WSH_DEBUG_SV.logmsg(l_module_name, 'p_new_resv_rec.secondary_ID '||p_new_resv_rec.secondary_uom_id );


     END IF;
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_RESERVATION_PUB.UPDATE_RESERVATION',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --


     INV_RESERVATION_PUB.update_reservation
    (
       p_api_version_number   => 1.0
     , p_init_msg_lst       => fnd_api.g_true
     , x_return_status       => x_return_status
     , x_msg_count         => l_msg_count
     , x_msg_data         => l_msg_data
     , p_original_rsv_rec     => p_query_input
     , p_to_rsv_rec       => p_new_resv_rec
     , p_original_serial_number => l_dummy_sn -- no serial contorl
     , p_to_serial_number     => l_dummy_sn -- no serial control
     , p_validation_flag       => fnd_api.g_true
     -- Bug 5099694
     , p_over_reservation_flag  =>3
     );
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'INV_RESERVATION_PUB.update_reservation',x_return_status);
    END IF;

     IF x_return_status = fnd_api.g_ret_sts_success THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'RESERVATION UPDATED FOR RESERVATION ID : '||TO_CHAR ( P_QUERY_INPUT.RESERVATION_ID )  );
      END IF;
      --
     ELSE
     FND_MESSAGE.Set_Name('WSH', 'WSH_UPDATE_RESERVATION');
     IF l_msg_count = 1 THEN
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR: '|| L_MSG_DATA  );
       END IF;
       --
       FND_MESSAGE.Set_Token('ERROR_TEXT',l_msg_data);
     ELSE
       FOR l_index IN 1..l_msg_count LOOP
       l_msg_data := fnd_msg_pub.get;
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR: '|| L_MSG_DATA  );
       END IF;
       --
       l_error_text := l_error_text || l_msg_data;
       END LOOP;
       FND_MESSAGE.Set_Token('ERROR_TEXT',l_error_text);
     END IF;
     raise update_reservation_failed;
     END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
    WHEN update_reservation_failed THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'UPDATE_RESERVATION_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:UPDATE_RESERVATION_FAILED');
    END IF;
    --
END;

FUNCTION  check_allocations (
 p_move_order_line_id     IN  NUMBER) RETURN BOOLEAN
IS
l_trolin_rec               INV_MOVE_ORDER_PUB.Trolin_Rec_Type;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'CHECK_ALLOCATIONS';
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
         WSH_DEBUG_SV.log(l_module_name,'P_MOVE_ORDER_LINE_ID',P_MOVE_ORDER_LINE_ID);
     END IF;
     --
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_TROLIN_UTIL.QUERY_ROW',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     l_trolin_rec := INV_TROLIN_UTIL.Query_Row(
                       p_line_id => p_move_order_line_id);
     IF  nvl(l_trolin_rec.quantity_detailed,0) > 0 THEN
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
       END IF;
       --
       RETURN TRUE;
     ELSE
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
       END IF;
       --
       RETURN FALSE;
     END IF;
END;

--  This private function checks the inventory information for the delivery detail against those of the
--  reservation record and returns TRUE if they match
-- 3012297 (for OPM - adding delivery_detail_id parameter)
FUNCTION check_inv_info  (
  p_delivery_detail_split_rec  IN DeliveryDetailInvRecType,
  p_delivery_detail_id         IN NUMBER default NULL,
  p_rsv              IN inv_reservation_global.mtl_reservation_rec_type
  ) return   BOOLEAN  IS

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'CHECK_INV_INFO';
--

-- 3012297
-- HW OPMCONV. Removed OPM local variables

l_delivery_detail_id   NUMBER;
l_organization_id      NUMBER;

Cursor get_dd_info (p_delivery_detail_id IN NUMBER) is
 Select organization_id
 From wsh_delivery_details
 Where delivery_detail_id = p_delivery_detail_id;
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
  END IF;
  --
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
-- HW BUG#:3456926 - Removed OPM debugging msg and kept WSH
      WSH_DEBUG_SV.logmsg(l_module_name, 'IN WSH_USA_INV_PVT.CHECK_INV_INFO FOR DETAIL : '|| P_DELIVERY_DETAIL_SPLIT_REC.DELIVERY_DETAIL_ID||' REL STAT : '||P_DELIVERY_DETAIL_SPLIT_REC.RELEASED_STATUS  );
  END IF;
  --

  -- 3012297 (initializing l_process_flag)

  IF p_delivery_detail_id is NULL THEN
    l_delivery_detail_id := p_delivery_detail_split_rec.delivery_detail_id;
    l_organization_id    := p_delivery_detail_split_rec.organization_id;
  ELSE
    OPEN  get_dd_info(p_delivery_detail_id);
    FETCH get_dd_info
    INTO  l_organization_id;
    ClOSE get_dd_info;
    l_delivery_detail_id := p_delivery_detail_id;
  END IF;
  -- HW OPMCONV. Removed checking for process org


--HW OPMCONV. Removed code forking

    IF p_delivery_detail_split_rec.subinventory IS NOT NULL THEN
       IF p_delivery_detail_split_rec.subinventory <> p_rsv.subinventory_code THEN
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        return FALSE;
       END IF;

    END IF;


    IF p_delivery_detail_split_rec.revision IS NOT NULL THEN
       IF p_delivery_detail_split_rec.revision <> p_rsv.revision THEN
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        return FALSE;
       END IF;
    END IF;
    IF p_delivery_detail_split_rec.lot_number IS NOT NULL THEN
       IF p_delivery_detail_split_rec.lot_number <> p_rsv.lot_number THEN
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        return FALSE;
       END IF;
    END IF;

          -- Bug 2773605: In addition to the inventory controls , the lpn_id should also
          --              be the same.
    IF p_delivery_detail_split_rec.lpn_id IS NOT NULL THEN
       IF p_delivery_detail_split_rec.lpn_id <> p_rsv.lpn_id THEN
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        return FALSE;
       END IF;
    END IF;

    IF p_delivery_detail_split_rec.locator_id IS NOT NULL THEN
       IF p_delivery_detail_split_rec.locator_id <> p_rsv.locator_id THEN
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        return FALSE;
       END IF;
    END IF;
 -- HW OPMCONV. Removed ELSE. No need to fork the code
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  return TRUE;

END check_inv_info;

-- This procedure takes care that staged reservations get reduced by the cancellation quantity from
-- appropriate inventory controls when some quantity from a staged delivery line is reduced
PROCEDURE  cancel_staged_reservation  (
 p_source_code           IN  VARCHAR2,
 p_source_header_id       IN  NUMBER,
 p_source_line_id       IN  NUMBER,
 p_delivery_detail_split_rec   IN  DeliveryDetailInvRecType,
 p_cancellation_quantity     IN  NUMBER,
 p_cancellation_quantity2   IN  NUMBER,
 x_return_status         OUT NOCOPY  VARCHAR2)
IS

l_rsv    inv_reservation_global.mtl_reservation_rec_type;
l_rsv_new inv_reservation_global.mtl_reservation_rec_type;
l_rsv_array inv_reservation_global.mtl_reservation_tbl_type;
l_size    NUMBER;
l_msg_count NUMBER;
l_msg_data  VARCHAR2(240);
l_cancelled_reservation_qty   NUMBER;
l_cancelled_reservation_qty2  NUMBER;
l_cancellation_quantity    NUMBER;
l_cancellation_quantity2    NUMBER;
l_staged_flag   VARCHAR2(1);
-- HW OPMCONV. Removed OPM variables

l_pickable_flag   VARCHAR2(1);
l_reservable_flag VARCHAR2(1);

l_delivery_detail_id NUMBER;

cursor pickable_flag (p_delivery_detail IN number) is
select pickable_flag
from wsh_delivery_details
where delivery_detail_id = p_delivery_detail;

cancel_failed  EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'CANCEL_STAGED_RESERVATION';
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
     WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
     WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_HEADER_ID',P_SOURCE_HEADER_ID);
     WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_LINE_ID',P_SOURCE_LINE_ID);
     WSH_DEBUG_SV.log(l_module_name,'P_CANCELLATION_QUANTITY',P_CANCELLATION_QUANTITY);
     WSH_DEBUG_SV.log(l_module_name,'P_CANCELLATION_QUANTITY2',P_CANCELLATION_QUANTITY2);
     WSH_DEBUG_SV.log(l_module_name,'p_delivery_detail_split_rec.organization_id',p_delivery_detail_split_rec.organization_id);
     WSH_DEBUG_SV.log(l_module_name,'p_delivery_detail_split_rec.delivery_detail_id',p_delivery_detail_split_rec.delivery_detail_id);
     WSH_DEBUG_SV.log(l_module_name,'p_delivery_detail_split_rec.inventory_item_id',p_delivery_detail_split_rec.inventory_item_id);
 END IF;
 --
 x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

 IF p_cancellation_quantity = 0 THEN
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  RETURN;
 END IF;

 --
 -- Debug Statements
 --
 IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name, 'IN WSH_USA_INV_PVT.CANCEL_STAGED_RESERVATION QUANTITY : '|| P_CANCELLATION_QUANTITY  );
 END IF;
 --

 --X-dock, conditionally populate delivery_detail_id
 WSH_USA_INV_PVT.get_putaway_detail_id
    (p_detail_id          => p_delivery_detail_split_rec.delivery_detail_id,
     p_released_status    => p_delivery_detail_split_rec.released_status,
     p_move_order_line_id => p_delivery_detail_split_rec.move_order_line_id,
     x_detail_id          => l_delivery_detail_id,
     x_return_status      => x_return_status);

 IF x_return_status <> fnd_api.g_ret_sts_success THEN
   raise cancel_failed;
 END IF;
 --end of X-dock

 -- X-dock, l_rsv_array would be appropriately populated with null or not null
 -- value of delivery_detail_id and used in delete_reservation or update_reservation calls
 query_reservations  (
   p_source_code                 => p_source_code,
   p_source_header_id            => p_source_header_id,
   p_source_line_id              => p_source_line_id,
   p_organization_id             => p_delivery_detail_split_rec.organization_id,
   p_lock_records                => fnd_api.g_true,
   p_delivery_detail_id          => l_delivery_detail_id,  --X-dock changes
   x_mtl_reservation_tbl         => l_rsv_array,
   x_mtl_reservation_tbl_count   => l_size,
   x_return_status               => x_return_status);


   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name, 'query_reservations x_return_status',x_return_status);
       WSH_DEBUG_SV.logmsg(l_module_name, 'L_SIZE: '||L_SIZE  );
   END IF;

   IF (x_return_status <> fnd_api.g_ret_sts_success) OR (l_size = 0) THEN
   IF x_return_status = fnd_api.g_ret_sts_success THEN
       OPEN pickable_flag(p_delivery_detail_split_rec.delivery_detail_id);
       FETCH pickable_flag INTO l_pickable_flag;
       CLOSE pickable_flag;
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_INV.GET_RESERVABLE_FLAG',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       --
       l_reservable_flag := WSH_DELIVERY_DETAILS_INV.get_reservable_flag(
                  x_item_id    => p_delivery_detail_split_rec.inventory_item_id,
                  x_organization_id => p_delivery_detail_split_rec.organization_id,
                  x_pickable_flag   => l_pickable_flag);
                   IF l_debug_on THEN
                       WSH_DEBUG_SV.log(l_module_name, 'get_reservable_flag l_reservable_flag,x_return_status',l_reservable_flag||','||x_return_status);
                   END IF;
       -- Non reservable/transactable items will always have no reservations.
       IF l_reservable_flag = 'N' THEN
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'NON RESERVABLE/TRANSACTABLE ITEM'  );
           WSH_DEBUG_SV.pop(l_module_name);
       END IF;
       RETURN;
       END IF;
    END IF;
    raise cancel_failed;
   END IF;

   l_cancellation_quantity   :=  p_cancellation_quantity;
   l_cancellation_quantity2  :=  p_cancellation_quantity2;

   --
   -- Debug Statements
   --
-- HW OPMCONV. Removed checking for process org


 -- loop  over all the reservation records in l_rsv_array

   FOR l_counter in  1..l_size
   LOOP
     IF   NOT l_cancellation_quantity > 0 THEN
      EXIT;
     END IF;
-- HW OPMCONV. No need to fork code
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_STAGED_RESERVATION_UTIL.QUERY_STAGED_FLAG',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     INV_STAGED_RESERVATION_UTIL.query_staged_flag
       ( x_return_status     =>  x_return_status,
       x_msg_count       =>  l_msg_count,
       x_msg_data     =>  l_msg_data,
       x_staged_flag     =>  l_staged_flag,
       p_reservation_id   =>  l_rsv_array(l_counter).reservation_id);
     IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name, 'query_staged_flag x_return_status',x_return_status);
     END IF;
     -- HW OPMCONV. No need to fork code

     --
     -- Debug Statements
     --
     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name, 'AFTER INV_STAGED_RESERVATION_UTIL.QUERY_STAGED_FLAG : '||L_STAGED_FLAG  );
     END IF;
     --

-- HW OPMCONV - Update qty2 using new reservation flds
     IF l_rsv_array(l_counter).secondary_reservation_quantity = FND_API.G_MISS_NUM THEN
       l_rsv_array(l_counter).secondary_reservation_quantity := null;
     END IF;

     -- Bug3012297 (Included reference to parameters)
     IF check_inv_info( p_delivery_detail_split_rec  => p_delivery_detail_split_rec
                      , p_rsv                        => l_rsv_array(l_counter))
          AND  l_staged_flag = 'Y' THEN

       IF l_rsv_array(l_counter).primary_reservation_quantity
            < l_cancellation_quantity THEN
         --  Can we delete reservation if detailed_quantity exists ?
         --  This would never happen. Detailed quantity is cleared
         --  during pick confirm (08/21 John)
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'GOING TO DELETE_RESERVATION IN CANCEL_STAGED_RESERVATION '  );
         END IF;
         --
         delete_reservation (p_query_input    =>  l_rsv_array(l_counter),
                             x_return_status    =>  x_return_status );
         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name, 'delete_reservation x_return_status',x_return_status);
         END IF;

         IF x_return_status <> fnd_api.g_ret_sts_success THEN
           raise cancel_failed;
         END IF;

         l_cancelled_reservation_qty  := l_rsv_array(l_counter).primary_reservation_quantity;
-- HW OPMCONV - Update Qty2 using new reservation flds.
         l_cancelled_reservation_qty2 := l_rsv_array(l_counter).secondary_reservation_quantity;

       ELSE

         l_rsv_new.primary_reservation_quantity  := l_rsv_array(l_counter).primary_reservation_quantity  -
                   l_cancellation_quantity;
-- HW OPMCONV - Update Qty2 using new reservation flds.
         l_rsv_new.secondary_reservation_quantity  := nvl(abs(l_rsv_array(l_counter).secondary_reservation_quantity),0)                                                        - nvl(abs(l_cancellation_quantity2),0);
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
-- HW OPMCONV - Print correct value of Qty2
           WSH_DEBUG_SV.logmsg(l_module_name, 'UPDATE QTY2 '|| l_rsv_new.secondary_reservation_quantity  );
         END IF;
         --
      -- HW OPMCONV - Ensure Qty2 are NULL before updating
         IF ( l_rsv_new.secondary_reservation_quantity = 0 OR
           l_rsv_new.secondary_reservation_quantity = FND_API.G_MISS_NUM ) THEN
           l_rsv_new.secondary_reservation_quantity := NULL;
         END IF;

         update_reservation (p_query_input =>  l_rsv_array(l_counter),
           p_new_resv_rec   =>  l_rsv_new,
           x_return_status  =>  x_return_status);
         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name, 'update_reservation x_return_status',x_return_status);
         END IF;

         IF x_return_status <> fnd_api.g_ret_sts_success THEN
           raise cancel_failed;
         END IF;

         EXIT;
       END IF;
       l_cancellation_quantity := l_cancellation_quantity - l_cancelled_reservation_qty;
       l_cancellation_quantity2 := l_cancellation_quantity2 - l_cancelled_reservation_qty2;
     END IF; -- end of check_inv_info and staged_flag = 'Y'
   END LOOP;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
   EXCEPTION
    WHEN cancel_failed THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'CANCEL_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:CANCEL_FAILED');
    END IF;
    --
    WHEN others THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    wsh_util_core.default_handler('WSH_USA_INV_PVT.cancel_staged_reservation',l_module_name);

                IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                 WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
              END IF;
END cancel_staged_reservation;


-- This procedure takes care that non staged reservations get reduced by the cancellation quantity
-- when some quantity from one or more non staged delivery line is reduced
PROCEDURE  cancel_nonstaged_reservation  (
 p_source_code          IN  VARCHAR2,
 p_source_header_id     IN  NUMBER,
 p_source_line_id       IN  NUMBER,
 p_delivery_detail_id   IN  NUMBER,
 p_organization_id         IN  NUMBER,
 p_cancellation_quantity     IN  NUMBER,
 p_cancellation_quantity2   IN  NUMBER,
 x_return_status         OUT NOCOPY  VARCHAR2)
IS

-- Bug 2595657
CURSOR c_nonstaged_qty is
SELECT nvl(sum(requested_quantity),0),
       nvl(sum(requested_quantity2),0)
FROM   wsh_delivery_details
WHERE  source_line_id   = p_source_line_id
and    source_header_id = p_source_header_id
and    source_code      = p_source_code
and    organization_id  = p_organization_id
and    ((released_status in ('R','B','N'))
         OR
        (released_status = 'S' and move_order_line_id IS NULL) -- Bug 5185995
       );

l_nonstaged_qty      NUMBER;
l_nonstaged_qty2     NUMBER;
l_nonstaged_rsv_qty  NUMBER;
l_nonstaged_rsv_qty2 NUMBER;
-- Bug 2595657

l_rsv    inv_reservation_global.mtl_reservation_rec_type;
l_rsv_new inv_reservation_global.mtl_reservation_rec_type;
l_rsv_array inv_reservation_global.mtl_reservation_tbl_type;
l_size    NUMBER;
l_msg_count NUMBER;
l_msg_data  VARCHAR2(240);
l_cancelled_reservation_qty   NUMBER;
l_cancelled_reservation_qty2  NUMBER;
l_cancellation_quantity    NUMBER;
l_cancellation_quantity2    NUMBER;
l_staged_flag   VARCHAR2(1);
-- HW OPMCONV. Removed OPM local variables

l_delivery_detail_id NUMBER;

l_rsv_match   	  VARCHAR2(1); --Bug3012297
l_dd_split_dummy        DeliveryDetailInvRecType; -- Bug 30122295

cancel_failed  EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'CANCEL_NONSTAGED_RESERVATION';
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
     WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
     WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_HEADER_ID',P_SOURCE_HEADER_ID);
     WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_LINE_ID',P_SOURCE_LINE_ID);
     WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
     WSH_DEBUG_SV.log(l_module_name,'P_delivery_detail_id',P_delivery_detail_id);
     WSH_DEBUG_SV.log(l_module_name,'P_CANCELLATION_QUANTITY',P_CANCELLATION_QUANTITY);
     WSH_DEBUG_SV.log(l_module_name,'P_CANCELLATION_QUANTITY2',P_CANCELLATION_QUANTITY2);
 END IF;
 --
 x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

 IF p_cancellation_quantity = 0 THEN
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  RETURN;
 END IF;

 --X-dock, conditionally populate delivery_detail_id
 -- released-status and MOL are passed as null and will be derived within the API
 WSH_USA_INV_PVT.get_putaway_detail_id
    (p_detail_id          => p_delivery_detail_id,
     p_released_status    => null,
     p_move_order_line_id => null,
     x_detail_id          => l_delivery_detail_id,
     x_return_status      => x_return_status);

 IF x_return_status <> fnd_api.g_ret_sts_success THEN
   raise cancel_failed;
 END IF;
 --end of X-dock

 --X-dock changes
 -- Output from above API l_rsv_array will contain demand_source_line_detail as null or not null
 -- which can be used for delete_reservation and update_reservation calls
 query_reservations  (
   p_source_code          => p_source_code,
   p_source_header_id        => p_source_header_id,
   p_source_line_id        => p_source_line_id,
   p_organization_id        => p_organization_id,
   p_delivery_detail_id    => l_delivery_detail_id,  -- X-dock changes
   p_lock_records          => fnd_api.g_true,
   x_mtl_reservation_tbl      => l_rsv_array,
   x_mtl_reservation_tbl_count    => l_size,
   x_return_status          => x_return_status);


   IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'query_reservations x_return_status',x_return_status);
   END IF;

   IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
    raise cancel_failed;
   END IF;

   IF l_size = 0 THEN  -- This case is specific for non staged reservations as
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    RETURN;     -- for a backordered DD reservations might or might not exist
   END IF;

   l_cancellation_quantity   :=  p_cancellation_quantity;
   l_cancellation_quantity2  :=  p_cancellation_quantity2;

   --
   -- Debug Statements
   --

-- HW OPMCONV. Removed checking for process org

   -- Bug 2595657 : Do not cancel p_cancellation_quantity reservation. Always cancel excess reservation
   OPEN  c_nonstaged_qty;
   FETCH c_nonstaged_qty
   INTO  l_nonstaged_qty, l_nonstaged_qty2;
   CLOSE c_nonstaged_qty;

-- HW OPMCONV - Added debugging statement
   IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'After fetching l_nonstaged_qty',l_nonstaged_qty);

     WSH_DEBUG_SV.log(l_module_name,'After fetching l_nonstaged_qty2',l_nonstaged_qty2);
   END IF;


   l_nonstaged_rsv_qty  := 0;
   l_nonstaged_rsv_qty2 := 0;
   FOR l_counter in  1..l_size
   LOOP
-- HW OPMCONV. Removed forking the code

       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Calling program unit INV_STAGED_RESERVATION_UTIL.query_staged_flag',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;

       IF l_debug_on THEN

     WSH_DEBUG_SV.log(l_module_name,'BEG OF LOOP l_nonstaged_qty',l_nonstaged_qty);

     WSH_DEBUG_SV.log(l_module_name,'BEG OF LOOP l_nonstaged_qty2',l_nonstaged_qty2);
   END IF;
       INV_STAGED_RESERVATION_UTIL.query_staged_flag(
         x_return_status   =>  x_return_status,
         x_msg_count       =>  l_msg_count,
         x_msg_data        =>  l_msg_data,
         x_staged_flag     =>  l_staged_flag,
         p_reservation_id  =>  l_rsv_array(l_counter).reservation_id);
       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'INV_STAGED_RESERVATION_UTIL.query_staged_flag',l_staged_flag);
       END IF;
-- HW OPMCONV. Removed code forking

     -- Bug3012297
     IF l_staged_flag <> 'Y'
          AND check_inv_info(  p_delivery_detail_split_rec => l_dd_split_dummy
                             , p_delivery_detail_id        => p_delivery_detail_id
                             , p_rsv                       => l_rsv_array(l_counter))
     THEN

     IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'BEFORE l_nonstaged_rsv_qty',l_nonstaged_rsv_qty);
          WSH_DEBUG_SV.log(l_module_name,'(l_rsv_array(l_counter).primary_reservation_quantity ',(l_rsv_array(l_counter).primary_reservation_quantity ));
          WSH_DEBUG_SV.log(l_module_name,'l_rsv_array(l_counter).detailed_quantity ',l_rsv_array(l_counter).detailed_quantity );
         END IF;
        l_nonstaged_rsv_qty := l_nonstaged_rsv_qty + (l_rsv_array(l_counter).primary_reservation_quantity
                                                      - nvl(l_rsv_array(l_counter).detailed_quantity,0));
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'AFTER l_nonstaged_rsv_qty',l_nonstaged_rsv_qty);
-- HW OPMCONV Added Qty2 using new reservation flds
        END IF;
         IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'l_nonstaged_rsv_qty2',l_nonstaged_rsv_qty2);
          WSH_DEBUG_SV.log(l_module_name,'(l_rsv_array(l_counter).secondary_reservation_quantity ',(l_rsv_array(l_counter).secondary_reservation_quantity ));
          WSH_DEBUG_SV.log(l_module_name,'l_rsv_array(l_counter).secondary_detailed_quantity ',l_rsv_array(l_counter).secondary_detailed_quantity );
         END IF;
        l_nonstaged_rsv_qty2 := l_nonstaged_rsv_qty2 + (l_rsv_array(l_counter).secondary_reservation_quantity
                                                      - nvl(l_rsv_array(l_counter).secondary_detailed_quantity,0));


        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'AFTER l_nonstaged_rsv_qty2',l_nonstaged_rsv_qty2);
-- HW OPMCONV Added Qty2 using new reservation flds
        END IF;
     END IF;
     --End Bug3012297

-- HW OPMCONV - Update correct Qty2 using new reservation flds.

     IF l_rsv_array(l_counter).secondary_reservation_quantity = FND_API.G_MISS_NUM
        OR l_rsv_array(l_counter).secondary_reservation_quantity = 0 THEN
        l_rsv_array(l_counter).secondary_reservation_quantity := null;
     END IF;


   END LOOP;

   IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'l_nonstaged_rsv_qty',l_nonstaged_rsv_qty);
     WSH_DEBUG_SV.log(l_module_name,'l_nonstaged_qty',l_nonstaged_qty);
     WSH_DEBUG_SV.log(l_module_name,'l_nonstaged_rsv_qty2',l_nonstaged_rsv_qty2);
     WSH_DEBUG_SV.log(l_module_name,'l_nonstaged_qty2',l_nonstaged_qty2);
   END IF;

   -- l_nonstaged_qty would have got reduced by p_cancellation_quantity by this time
   IF (l_nonstaged_rsv_qty > l_nonstaged_qty) THEN
     l_cancellation_quantity   :=  l_nonstaged_rsv_qty - l_nonstaged_qty;
     -- KYH BUG 4259636 BEGIN
     -- =====================
     -- Cannot compute cancellation quantity using summed quantities because it may mix various
     -- lot specific calculations.  Compute it later on a lot specific basis driving off l_cancellation_quantity
     -- l_cancellation_quantity2  :=  l_nonstaged_rsv_qty2 - l_nonstaged_qty2;
     -- KYH BUG 4259636 END
   ELSE
     l_cancellation_quantity   := 0;
     l_cancellation_quantity2  := 0;
   END IF;

   IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'Going to Cancel l_cancellation_quantity',l_cancellation_quantity);
  -- WSH_DEBUG_SV.log(l_module_name,'Going to Cancel l_cancellation_quantity2',l_cancellation_quantity2);
   END IF;
   -- 2595657

 -- loop  over all the reservation records in l_rsv_array

    FOR l_counter in  1..l_size
    LOOP
           IF   NOT l_cancellation_quantity > 0 then
            exit;
           END IF;
 -- HW OPMCONV. Removed forking the code
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_STAGED_RESERVATION_UTIL.QUERY_STAGED_FLAG',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            INV_STAGED_RESERVATION_UTIL.query_staged_flag
             ( x_return_status     =>  x_return_status,
             x_msg_count       =>  l_msg_count,
             x_msg_data     =>  l_msg_data,
             x_staged_flag     =>  l_staged_flag,
             p_reservation_id   =>  l_rsv_array(l_counter).reservation_id);
                                          IF l_debug_on THEN
                                            WSH_DEBUG_SV.log(l_module_name,'query_staged_flag x_return_status',x_return_status);
                                          END IF;
-- HW OPMCONV. No need to fork the code
           --
           -- Debug Statements
           --
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'AFTER INV_STAGED_RESERVATION_UTIL.QUERY_STAGED_FLAG : '||L_STAGED_FLAG  );
           END IF;
           --

-- HW OPMCONV -Update Qty2 using new reservation flds.

           IF l_rsv_array(l_counter).secondary_reservation_quantity = FND_API.G_MISS_NUM THEN
             l_rsv_array(l_counter).secondary_reservation_quantity := null;
           END IF;

          -- Bug3012297
          l_rsv_match := 'N';
     IF l_staged_flag <> 'Y' THEN
-- HW OPMCONV . Removed forking the code

                   l_rsv_match := 'Y';
        -- HW OPMCONV. Removed ELSIF

           END IF;
            -- End Bug3012297

            -- Bug3012297 (Replaced following IF)
            -- IF l_staged_flag <> 'Y' THEN
            IF l_rsv_match = 'Y' THEN

             --  Should be able to reduce any non detailed quantity ?

             IF l_rsv_array(l_counter).primary_reservation_quantity -
              nvl(l_rsv_array(l_counter).detailed_quantity,0)
                < l_cancellation_quantity THEN

--  Can we delete reservation if detailed_quantity exists ?
--  No  (08/21  John)

              IF nvl(l_rsv_array(l_counter).detailed_quantity,0) <> 0  THEN

                 l_rsv_new.primary_reservation_quantity  :=
                        l_rsv_array(l_counter).detailed_quantity;
-- HW OPMCONV - Added Qty2
                l_rsv_new.secondary_reservation_quantity  :=
                        l_rsv_array(l_counter).secondary_detailed_quantity;

-- HW OPMCONV - Ensure Qty2 are NULL before updating

      IF ( l_rsv_new.secondary_reservation_quantity = 0 OR
           l_rsv_new.secondary_reservation_quantity = FND_API.G_MISS_NUM ) THEN
           l_rsv_new.secondary_reservation_quantity := NULL;
       END IF;

      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'DEBUGGING' );
          WSH_DEBUG_SV.logmsg(l_module_name, 'l_rsv_new.secondary_reservation_quantity '||l_rsv_new.secondary_reservation_quantity  );
          WSH_DEBUG_SV.logmsg(l_module_name, 'l_rsv_new.secondary_UOM_CODE '||l_rsv_new.secondary_uom_code );
          WSH_DEBUG_SV.logmsg(l_module_name, 'l_rsv_new.secondary_ID '||l_rsv_new.secondary_uom_id );
      END IF;

      update_reservation (
        p_query_input  =>  l_rsv_array(l_counter),
        p_new_resv_rec   =>  l_rsv_new,
        x_return_status  =>  x_return_status);

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'update_reservation x_return_status',x_return_status);
      END IF;
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        raise cancel_failed;
      END IF;

              ELSE
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name, 'GOING TO DELETE_RESERVATION IN CANCEL_NON__STAGED_RESERVATION '  );
END IF;
--
                delete_reservation (
                 p_query_input     =>  l_rsv_array(l_counter),
                 x_return_status   =>  x_return_status );
                                          IF l_debug_on THEN
                                            WSH_DEBUG_SV.log(l_module_name,'delete_reservation x_return_status',x_return_status);
                                          END IF;

                IF x_return_status <> fnd_api.g_ret_sts_success THEN
                 raise cancel_failed;
                END IF;

              END IF;

              l_cancelled_reservation_qty  :=
                        l_rsv_array(l_counter).primary_reservation_quantity -
                        nvl(l_rsv_array(l_counter).detailed_quantity,0);
-- HW OPMCONV Update Qty2 using new reservations flds.
              l_cancelled_reservation_qty2 :=
                        l_rsv_array(l_counter).secondary_reservation_quantity -
                        nvl(l_rsv_array(l_counter).secondary_detailed_quantity,0);

--                        l_rsv_array(l_counter).attribute2;
             ELSE
                l_rsv_new.primary_reservation_quantity  :=
                  l_rsv_array(l_counter).primary_reservation_quantity  -
                  l_cancellation_quantity;
                  -- KYH BUG 4259636 BEGIN
                  -- =====================
                  -- Ensure cancellation_quantity2 is computed in accordance with any
                  -- lot specific calculation in play for the reservation line
                  -- otherwise we may be mixing item level and lot specific level calculations
                  IF l_rsv_array(l_counter).secondary_uom_code <> FND_API.G_MISS_CHAR THEN
                    -- For dual tracked items compute the secondary cancellation qty in
                    -- accordance with any lot specific calculation in play
                    l_cancellation_quantity2 := WSH_WV_UTILS.convert_uom(
                                   item_id                      => l_rsv_array(l_counter).inventory_item_id
                                 , lot_number                   => l_rsv_array(l_counter).lot_number
                                 , org_id                       => l_rsv_array(l_counter).organization_id
                                 , p_max_decimal_digits         => NULL -- use default precision
                                 , quantity                     => l_cancellation_quantity
                                 , from_uom                     => l_rsv_array(l_counter).primary_uom_code
                                 , to_uom                       => l_rsv_array(l_counter).secondary_uom_code
                                 );

                    IF l_cancellation_quantity2 = 0 THEN
                      -- conversion failed
                      IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR on UOM conversion to secondary UOM : '||l_rsv_array(l_counter).secondary_uom_code  );
                      END IF;
                      raise cancel_failed;
                    END IF;
                  END IF;
                  IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'Going to Cancel l_cancellation_quantity',l_cancellation_quantity);
                    WSH_DEBUG_SV.log(l_module_name,'Going to Cancel l_cancellation_quantity2',l_cancellation_quantity2);
                    WSH_DEBUG_SV.log(l_module_name,'Lot involved for conversions is ',l_rsv_array(l_counter).lot_number);
                  END IF;
                  -- KYH BUG 4259636 END
-- HW OPMCONV Update Qty2 using new reservations flds.
--                l_rsv_new.attribute2  :=
                  l_rsv_new.secondary_reservation_quantity  :=
                  nvl(abs(l_rsv_array(l_counter).secondary_reservation_quantity),0)  -
                  nvl(l_cancellation_quantity2,0);



 -- HW OPMCONV - Ensure Qty2 are NULL before updating
                 IF ( l_rsv_new.secondary_reservation_quantity = 0 OR
                   l_rsv_new.secondary_reservation_quantity = FND_API.G_MISS_NUM ) THEN
                   l_rsv_new.secondary_reservation_quantity := NULL;
                END IF;

                update_reservation (
                   p_query_input  =>  l_rsv_array(l_counter),
                   p_new_resv_rec   =>  l_rsv_new,
                   x_return_status  =>  x_return_status);
                                          IF l_debug_on THEN
                                            WSH_DEBUG_SV.log(l_module_name,'update_reservation x_return_status',x_return_status);
                                          END IF;

                IF x_return_status <> fnd_api.g_ret_sts_success THEN
                 raise cancel_failed;
                END IF;

                EXIT;
             END IF;
             l_cancellation_quantity := l_cancellation_quantity - l_cancelled_reservation_qty;
          -- l_cancellation_quantity2 := l_cancellation_quantity2 - l_cancelled_reservation_qty2; --BUG 4259636

           END IF;
    END LOOP;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
   EXCEPTION
    WHEN cancel_failed THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'CANCEL_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:CANCEL_FAILED');
    END IF;
    --
    WHEN others THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    wsh_util_core.default_handler('WSH_USA_INV_PVT.cancel_nonstaged_reservation',l_module_name);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
 END cancel_nonstaged_reservation;
-- bug # 9410461: Added to new out parameter x_new_rsv_id to return reservation id of the new reservation
--                record created.
--  This is a private procedure which wraps inv_reservation_pub.update_reservation
--  or inv_reservation_pub.transfer_reservation as required
-- COMMENT : p_rsv.demand_source_line_detail is required for X-dock lines
--           Functionality added in R12
-- Added parameter p_shipped_flag for bug 10105817
PROCEDURE Reservation_split_action (
 p_rsv          IN  inv_reservation_global.mtl_reservation_rec_type,
 p_rsv_new        IN  inv_reservation_global.mtl_reservation_rec_type,
 p_staged        IN VARCHAR2,
 p_released_status   IN  VARCHAR2,
 p_split_quantity    IN  OUT NOCOPY   NUMBER,
 p_split_quantity2   IN  OUT NOCOPY   NUMBER,
 x_new_rsv_id       OUT NOCOPY    NUMBER,
 p_shipped_flag   IN VARCHAR2,
 x_return_status    OUT NOCOPY    VARCHAR2)

IS
l_msg_count NUMBER;
l_msg_data  VARCHAR2(240);
l_error_text  VARCHAR2(6000);
l_new_rsv_id  NUMBER;
l_status  VARCHAR2(1);
l_quantity_to_split   NUMBER;
-- HW OPMCONV added qty2
l_quantity2_to_split   NUMBER;
l_max_qty2_to_split    NUMBER;


l_detailed_quantity  NUMBER;
l_detailed_quantity2 NUMBER;

l_rsv_new   inv_reservation_global.mtl_reservation_rec_type;
l_dummy_sn  INV_RESERVATION_GLOBAL.serial_number_tbl_type;

transfer_split_failed EXCEPTION;
l_validation_flag VARCHAR2(1);
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'RESERVATION_SPLIT_ACTION';
--
BEGIN
  --
  l_status := FND_API.G_RET_STS_SUCCESS;
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
   l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.push(l_module_name);
     WSH_DEBUG_SV.log(l_module_name,'P_STAGED',P_STAGED);
     WSH_DEBUG_SV.log(l_module_name,'P_RELEASED_STATUS',P_RELEASED_STATUS);
     WSH_DEBUG_SV.log(l_module_name,'P_SPLIT_QUANTITY',P_SPLIT_QUANTITY);
-- HW OPMCONV - Print Qty2
     WSH_DEBUG_SV.log(l_module_name,'P_SPLIT_QUANTITY2',P_SPLIT_QUANTITY2);
     WSH_DEBUG_SV.log(l_module_name,'p_rsv.organization_id',
                                     p_rsv.organization_id);
     WSH_DEBUG_SV.log(l_module_name,'p_rsv.inventory_item_id',
                                     p_rsv.inventory_item_id);
     WSH_DEBUG_SV.log(l_module_name,'p_rsv_new.organization_id',
                                     p_rsv_new.organization_id);
     WSH_DEBUG_SV.log(l_module_name,'p_rsv_new.inventory_item_id',
                                     p_rsv_new.inventory_item_id);
  END IF;


  -- Bug 2925398: detailed quantity needs to be subtracted from primary qty
  --              to avoid transferring the detailed portion unless this
  --              detail is released to warehouse.
  IF p_released_status = 'S' THEN
    l_detailed_quantity  := 0;
    l_detailed_quantity2 := 0;
  ELSE
    l_detailed_quantity  := p_rsv.detailed_quantity;
    l_detailed_quantity2 := p_rsv.secondary_detailed_quantity;
  END IF;

  l_quantity_to_split := least(p_split_quantity,
                               (p_rsv.primary_reservation_quantity
                                 - l_detailed_quantity));

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'l_quantity_to_split', l_quantity_to_split);
  END IF;

  IF NVL(l_quantity_to_split,0) = 0 THEN
    x_return_status := l_status;
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
  END IF;

-- HW OPMCONV - Added qty2

  -- KYH BUG 4259636 BEGIN
  --l_quantity2_to_split := least(p_split_quantity2 , p_rsv.secondary_reservation_quantity);
  -- This calculation is mixing item level UOM conversions (p_split_quantity2) with
  -- lot specific conversions (secondary_reservation_quantity).
  -- The wisest course of action is to compute the secondary based on the
  -- lot information available to us from the originating lot.
  IF p_rsv.secondary_uom_code <> FND_API.G_MISS_CHAR THEN
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'DUAL tracked item so convert for lot ',p_rsv.lot_number);
    END IF;
    l_quantity2_to_split := WSH_WV_UTILS.convert_uom(
            item_id                      => p_rsv.inventory_item_id
          , lot_number                   => p_rsv.lot_number
          , org_id                       => p_rsv.organization_id
          , p_max_decimal_digits         => NULL -- use default precision
          , quantity                     => l_quantity_to_split
          , from_uom                     => p_rsv.primary_uom_code
          , to_uom                       => p_rsv.secondary_uom_code
        );

    IF l_quantity2_to_split = 0 THEN
      -- conversion failed
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR on UOM conversion to secondary UOM : '||p_rsv_new.secondary_uom_code  );
      END IF;
      raise transfer_split_failed;
    END IF;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'l_quantity2_to_split', l_quantity2_to_split);
    END IF;

    -- bug 2925398: make sure secondary quantity will not touch the detailed
    --              portion unless the detail is released to warehouse.
    l_max_qty2_to_split := (p_rsv.secondary_reservation_quantity
                               - l_detailed_quantity2);
    IF l_quantity2_to_split > l_max_qty2_to_split THEN
      l_quantity2_to_split := l_max_qty2_to_split;
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'adjusted l_quantity2_to_split', l_quantity2_to_split);
      END IF;
    END IF;

  END IF;
  -- KYH INVCONV END

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name, 'IN WSH_USA_INV_PVT.RESERVATION_SPLIT_ACTION TO SPLIT : '|| L_QUANTITY_TO_SPLIT  );
  END IF;
  --
  -- 2847687 :   No More performing Update_Reservations per INV advice,
  --              So always calling Transfer Rsvtns.
  --        l_quantity_to_split will always be <=
  --        p_rsv.primary_reservation_quantity because of least() above
  --
  --   transfer reservation with l_quantity_to_split
  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name, 'QUANTITY TO SPLIT : '|| L_QUANTITY_TO_SPLIT  );
    WSH_DEBUG_SV.logmsg(l_module_name, 'QUANTITY2 TO SPLIT : '|| L_QUANTITY2_TO_SPLIT  );
  END IF;

  l_rsv_new := p_rsv_new;
  l_rsv_new.primary_reservation_quantity := l_quantity_to_split;

-- HW OPMCONV Added secondary_qty2
  l_rsv_new.secondary_reservation_quantity := l_quantity2_to_split;

  -- bug 2925398: corrected detailed quantity assignment.
  --              MOL's detailed portion should not be touched directly
  --              unless the line is released to warehouse
  IF p_released_status = 'S' THEN
    l_rsv_new.detailed_quantity := least(p_rsv.detailed_quantity,
                                        l_quantity_to_split);
    l_rsv_new.secondary_detailed_quantity :=
                             least(p_rsv.secondary_detailed_quantity,
                                   l_quantity2_to_split);
  ELSE
    l_rsv_new.detailed_quantity := 0;
    IF l_rsv_new.secondary_detailed_quantity > 0 THEN
      l_rsv_new.secondary_detailed_quantity := 0;
    END IF;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'l_rsv_new.detailed_quantity',
                                    l_rsv_new.detailed_quantity);
    WSH_DEBUG_SV.log(l_module_name, 'l_rsv_new.secondary_detailed_quantity',
                                    l_rsv_new.secondary_detailed_quantity);
  END IF;

  --
  -- FP bug 4107648
  -- Bug 4092477 : Do not call INV API if the quantity to split is NULL
  --
  IF l_rsv_new.primary_reservation_quantity IS NOT NULL THEN  --{
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_RESERVATION_PUB.TRANSFER_RESERVATION',WSH_DEBUG_SV.C_PROC_LEVEL);
      WSH_DEBUG_SV.log(l_module_name,'l_rsv_new.primary_reservation_quantity',
                                      l_rsv_new.primary_reservation_quantity);
      WSH_DEBUG_SV.log(l_module_name,'l_rsv_new.secondary_reservation_quantity',
                                      l_rsv_new.secondary_reservation_quantity);
    END IF;
    --
   --Added for bug 10105817

   IF ( p_shipped_flag = 'Y' ) THEN
      l_validation_flag := 'N';
   ELSE
      l_validation_flag := 'Y';
   END IF;

    INV_RESERVATION_PUB.transfer_reservation
           (p_api_version_number     => 1.0,
            p_init_msg_lst           => fnd_api.g_true,
            x_return_status          => l_status,
            x_msg_count              => l_msg_count,
            x_msg_data               => l_msg_data,
            p_original_rsv_rec       => p_rsv,
            p_to_rsv_rec             => l_rsv_new,
            p_original_serial_number => l_dummy_sn, -- no serial contorl
            p_to_serial_number       => l_dummy_sn, -- no serial control
            p_validation_flag        => l_validation_flag,
	    -- Bug 5099694
            p_over_reservation_flag  =>3,
            x_to_reservation_id      => l_new_rsv_id
           );
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'transfer_reservation l_status',l_status);
    END IF;

    IF l_status = fnd_api.g_ret_sts_success THEN
      IF l_debug_on THEN
-- HW OPMCONV - Print Qty2
        WSH_DEBUG_SV.logmsg(l_module_name, 'Rsvn. Transferred FOR Rsvn.ID :'
           ||P_RSV.RESERVATION_ID || ' : TO Rsvn.ID : '||L_NEW_RSV_ID||
           ' BY Qty: '||L_QUANTITY_TO_SPLIT ||
           ' BY Qty2: '||L_QUANTITY2_TO_SPLIT  );
      END IF;
      x_new_rsv_id := l_new_rsv_id; -- bug # 9410461: Return the reservation id created.
    ELSE
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'COULD NOT TRANSFER FOR RESERVATION ID : '||P_RSV.RESERVATION_ID  );
      END IF;
      FND_MESSAGE.Set_Name('WSH', 'WSH_TRANSFER_RESERVATION');
      IF l_msg_count = 1 THEN
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR: '|| L_MSG_DATA  );
        END IF;
        --
        FND_MESSAGE.Set_Token('ERROR_TEXT',l_msg_data);
      ELSE
        FOR l_index IN 1..l_msg_count LOOP
          l_msg_data := fnd_msg_pub.get;
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR: '|| L_MSG_DATA  );
          END IF;
          --
          l_error_text := l_error_text || l_msg_data;
        END LOOP;
        FND_MESSAGE.Set_Token('ERROR_TEXT',l_error_text);
        l_error_text := '';
      END IF;
      raise transfer_split_failed;
    END IF;

    IF p_staged = 'Y' THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_STAGED_RESERVATION_UTIL.UPDATE_STAGED_FLAG',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      INV_STAGED_RESERVATION_UTIL.update_staged_flag
          ( x_return_status  =>  l_status,
            x_msg_count      =>  l_msg_count,
            x_msg_data       =>  l_msg_data,
            p_reservation_id =>  l_new_rsv_id,
            p_staged_flag    =>  p_staged
          );
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'update_staged_flag l_status',l_status);
      END IF;

      IF l_status = fnd_api.g_ret_sts_success THEN
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'STAGED FLAG UPDATED FOR RESERVATION ID : '||L_NEW_RSV_ID  );
        END IF;
      ELSE
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'COULD NOT UPDATE STAGED FLAG FOR RESERVATION ID : '||L_NEW_RSV_ID  );
        END IF;
        IF l_msg_count = 1 THEN
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR: '|| L_MSG_DATA  );
          END IF;
        ELSE
          FOR l_index IN 1..l_msg_count LOOP
            l_msg_data := fnd_msg_pub.get;
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR: '|| L_MSG_DATA  );
            END IF;
          END LOOP;
        END IF;
        raise transfer_split_failed;
      END IF;

    END IF;  -- Stgd. Flag

    p_split_quantity := p_split_quantity - l_quantity_to_split;
-- HW OPMCONV -Added Qty2
    IF (   p_split_quantity2 IS NULL
        OR p_split_quantity2 = FND_API.G_MISS_NUM) THEN
      p_split_quantity2 :=0;
    ELSE
      p_split_quantity2 := p_split_quantity2 - l_quantity2_to_split;
    END IF;

    x_return_status := l_status;

  END IF; --} /* l_quantity_to_split IS NOT NULL */


  IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

  --
  EXCEPTION
    WHEN transfer_split_failed THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'TRANSFER_SPLIT_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:TRANSFER_SPLIT_FAILED');
      END IF;
    --
    WHEN others THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      wsh_util_core.default_handler('WSH_USA_INV_PVT.reservation_split_action',l_module_name);
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
--
END  reservation_split_action;


-- This procedure takes care that reservations get updated/transferred by the split quantity
-- when an order line gets split.
-- Bug 2540015: Added p_move_order_line_status. Expected values are 'TRANSFER', 'CANCEL'
-- HW OPMCONV - Added p_split_quantity2
-- Added parameter p_shipped_flag for bug 10105817
PROCEDURE  split_reservation  (
 p_delivery_detail_split_rec IN  DeliveryDetailInvRecType,
 p_source_code               IN  VARCHAR2,
 p_source_header_id          IN  NUMBER,
 p_original_source_line_id   IN  NUMBER,
 p_split_source_line_id      IN  NUMBER,
 p_split_quantity            IN  NUMBER,   --  Passed requested_quantity
 p_split_quantity2           IN  NUMBER,
 p_move_order_line_status    IN  VARCHAR2,
 p_direction_flag            IN VARCHAR2 default 'U',
 p_shipped_flag              IN  VARCHAR2 default 'N',
 x_return_status             OUT NOCOPY  VARCHAR2)
IS

-- bug # 9410461: Begin
l_new_rsv_id                 NUMBER;
l_mmtt_tbl                   INV_MO_LINE_DETAIL_UTIL.g_mmtt_tbl_type;
l_temp_transaction_quantity  NUMBER;
l_temp_transaction_quantity2 NUMBER;
-- bug # 9410461: End

l_rsv_new   inv_reservation_global.mtl_reservation_rec_type;
l_msg_count NUMBER;
l_msg_data  VARCHAR2(240);
l_rsv_id  NUMBER;
l_status  VARCHAR2(1);
l_rsv_array inv_reservation_global.mtl_reservation_tbl_type;
l_size    NUMBER;
l_staged_flag   VARCHAR2(1);
-- HW OPMCONV. Removed OPM local variables

l_split_quantity   NUMBER;
-- HW OPMCONV. Added l_split_quantity2
l_split_quantity2 NUMBER ;
l_sales_order_id  NUMBER;
l_reservation_id  NUMBER;

l_detail_tab WSH_UTIL_CORE.id_tab_type;  -- DBI Project
l_dbi_rs        VARCHAR2(1);             -- DBI Project

l_wf_rs         VARCHAR2(1); --Pick to POD WF Project
l_organization_id NUMBER; --Pick to POD WF Project

l_delivery_detail_id NUMBER;
split_failed EXCEPTION;

l_released_status WSH_DELIVERY_DETAILS.RELEASED_STATUS%TYPE;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'SPLIT_RESERVATION';
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
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;  -- bug # 9410461: Initializing return status.
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       --
       WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
       WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_HEADER_ID',P_SOURCE_HEADER_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_ORIGINAL_SOURCE_LINE_ID',P_ORIGINAL_SOURCE_LINE_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_SPLIT_SOURCE_LINE_ID',P_SPLIT_SOURCE_LINE_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_SPLIT_QUANTITY',P_SPLIT_QUANTITY);
       WSH_DEBUG_SV.log(l_module_name,'P_SPLIT_QUANTITY2',P_SPLIT_QUANTITY2);
       WSH_DEBUG_SV.log(l_module_name,'P_SHIPPED_FLAG', P_SHIPPED_FLAG);
       WSH_DEBUG_SV.log(l_module_name,'p_delivery_detail_split_rec.organization_id',p_delivery_detail_split_rec.organization_id);
       WSH_DEBUG_SV.log(l_module_name,'p_delivery_detail_split_rec.delivery_detail_id',p_delivery_detail_split_rec.delivery_detail_id);
       WSH_DEBUG_SV.log(l_module_name,'p_delivery_detail_split_rec.inventory_item_id',p_delivery_detail_split_rec.inventory_item_id);
   END IF;
   --
   --
   -- Debug Statements
   -- HW OPMCONV. Removed checking for OPM org

   --X-dock,split
   WSH_USA_INV_PVT.get_putaway_detail_id
     (p_detail_id          => p_delivery_detail_split_rec.delivery_detail_id,
      p_released_status    => p_delivery_detail_split_rec.released_status,
      p_move_order_line_id => p_delivery_detail_split_rec.move_order_line_id,
      x_detail_id          => l_delivery_detail_id,
      x_return_status      => x_return_status);

   -- Above call populates l_delivery_detail_id and is used at multiple places in this API
   IF x_return_status IN (FND_API.G_RET_STS_UNEXP_ERROR,FND_API.G_RET_STS_ERROR) THEN
     IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Exception has occured after WSHUSAIB.get_putaway_detail_id');
       WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     RETURN;
   END IF;
   --End of X-dock,split

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name, 'IN WSH_USA_INV_PVT.SPLIT_RESERVATION TO SPLIT : '|| P_SPLIT_QUANTITY  );
   END IF;
   --
   --{
   IF  p_delivery_detail_split_rec.released_status = 'S' THEN
     --call  INV s cancel move order line API  with update reservation flag 'N'
     --this should clear out the detailed quantity for the appropriate reservation records
     -- Bug 2437799: Cancel the move order line or transfer it to new order line
     -- depending on parameter p_move_order_line_status
     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name, 'p_move_order_line_status is '||p_move_order_line_status);
     END IF;
     IF (p_move_order_line_status = 'CANCEL') THEN
       --
  -- HW OPMCONV. Removed forking the code

       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_MO_CANCEL_PVT.CANCEL_MOVE_ORDER_LINE',WSH_DEBUG_SV.C_PROC_LEVEL);
         WSH_DEBUG_SV.logmsg(l_module_name, 'CALLING INV_MO_CANCEL_PVT.CANCEL_MOVE_ORDER_LINE FOR DD : '|| P_DELIVERY_DETAIL_SPLIT_REC.DELIVERY_DETAIL_ID);
         WSH_DEBUG_SV.logmsg(l_module_name, 'CALLING INV_MO_CANCEL_PVT.CANCEL_MOVE_ORDER_LINE FOR MOL : '|| P_DELIVERY_DETAIL_SPLIT_REC.MOVE_ORDER_LINE_ID);
       END IF;
       --
       -- X-dock changes, added p_delivery_detail_id
       INV_MO_CANCEL_PVT.Cancel_Move_Order_Line
         (p_line_id             =>  p_delivery_detail_split_rec.move_order_line_id,
          p_delete_reservations =>  'N',
          p_txn_source_line_id  =>  p_original_source_line_id,
          p_delivery_detail_id  =>  p_delivery_detail_split_rec.delivery_detail_id,
          x_return_status       => x_return_status,
          x_msg_count           => l_msg_count,
          x_msg_data            => l_msg_data);
       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Cancel_Move_Order_Line x_return_status',x_return_status);
       END IF;

       -- bug 5226867
       IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Cancel_Move_Order_Line returned unexpected error');
         END IF;

         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         --
       ELSIF (x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Cancel_Move_Order_Line returned error');
         END IF;

         RAISE split_failed;
         --
       END IF;
       -- bug 5226867

 -- HW OPMCONV. Removed code forking

       -- For X-dock progressed line, l_delivery_detail_id will be not null,else null
       -- X-dock,split
       --{
       -- released_status is already checked above, should be 'S'
       IF p_delivery_detail_split_rec.move_order_line_id IS NOT NULL THEN
         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Updating released_status for detail');
         END IF;
         UPDATE wsh_delivery_details
           SET  released_status = 'R',
                move_order_line_id = NULL
         WHERE  delivery_detail_id = p_delivery_detail_split_rec.delivery_detail_id
         RETURNING organization_id -- done for Workflow Project
         INTO l_organization_id;

         --Raise Event : Pick To Pod Workflow
         WSH_WF_STD.Raise_Event
          (p_entity_type => 'LINE',
           p_entity_id => p_delivery_detail_split_rec.delivery_detail_id ,
           p_event => 'oracle.apps.wsh.line.gen.readytorelease' ,
           p_organization_id => l_organization_id,
           x_return_status => l_wf_rs);

         --Error Handling to be done in WSH_WF_STD.Raise_Event itself
         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Current Time is ',SYSDATE);
           wsh_debug_sv.log(l_module_name,'Return Status After Calling WSH_WF_STD.Raise_Event',l_wf_rs);
         END IF;
         --Done Raise Event: Pick To Pod Workflow

        --
        -- DBI Project
        -- Update of wsh_delivery_details where released_status
        -- are changed, call DBI API after the update.
        -- This API will also check for DBI Installed or not
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Detail id-',p_delivery_detail_split_rec.delivery_detail_id);
        END IF;
        l_detail_tab(1) := p_delivery_detail_split_rec.delivery_detail_id;
        WSH_INTEGRATION.DBI_Update_Detail_Log
          (p_delivery_detail_id_tab => l_detail_tab,
           p_dml_type               => 'UPDATE',
           x_return_status          => l_dbi_rs);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
        END IF;
        IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_dbi_rs;
          -- just pass this return status to caller API
          IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name,'DBI API Returned Unexpected error '||x_return_status);
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          return;
        END IF;
        -- End of Code for DBI Project
        --
     END IF;
     --}
     -- end of X-dock,split

     ELSIF (p_move_order_line_status IN ('TRANSFER','PTOTRANSFER') ) THEN  -- bug # 9410461: consider new value 'PTOTRANSFER'
-- HW OPMCONV. Removed forking the code

         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_Transfer_Order_PVT.Update_Txn_Source_Line',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         INV_Transfer_Order_PVT.Update_Txn_Source_Line
           (p_line_id               => p_delivery_detail_split_rec.move_order_line_id,
            p_new_source_line_id    => p_split_source_line_id);
         --
         -- bug # 9410461: Begin
         IF ( p_move_order_line_status = 'PTOTRANSFER' ) THEN
         --{
             -- bug # 9410461: Get all mmtt records for the given move order line id.
             -- This is required as the reservation_id of MMTT needs to updated when
             -- original reservation got split and transferred to new line.
             IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit inv_mo_line_detail_util.query_rows',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;
             l_mmtt_tbl := inv_mo_line_detail_util.query_rows(p_line_id => p_delivery_detail_split_rec.move_order_line_id);
             --
             IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'l_mmtt_tbl count',l_mmtt_tbl.Count);
             END IF;
         --}
         END IF;
         -- bug # 9410461: end

-- HW OPMCONV. Removed code forking

     END IF; -- p_move_order_line_status
   END IF; -- p_delivery_detail_split_rec.released_status
   --}

   l_split_quantity := p_split_quantity;
  -- HW OPMCONV. Added split_quantity2
   IF ( p_split_quantity2 = 0 OR p_split_quantity2 = FND_API.G_MISS_NUM) THEN
     l_split_quantity2 := NULL;
   ELSE
     l_split_quantity2 := p_split_quantity2;
   END IF;
   IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name, 'VALUE OF L_SPLIT_QUANTITY IN SPLIT_RESERVATION '||L_SPLIT_QUANTITY  );
-- HW OPMCONV. Print Qty2
     WSH_DEBUG_SV.logmsg(l_module_name, 'VALUE OF L_SPLIT_QUANTITY2 IN SPLIT_RESERVATION '||L_SPLIT_QUANTITY2  );

   END IF;
   --
-- HW OPMCONV. Removed forking the code

     --X-dock
     query_reservations  (
         p_source_code               => p_source_code,
         p_source_header_id          => p_source_header_id,
         p_source_line_id            => p_original_source_line_id,
         p_organization_id           => p_delivery_detail_split_rec.organization_id,
         p_lock_records              => fnd_api.g_true,
         p_direction_flag            => p_direction_flag ,
         p_delivery_detail_id        => l_delivery_detail_id, -- X-dock
         x_mtl_reservation_tbl       => l_rsv_array,
         x_mtl_reservation_tbl_count => l_size,
         x_return_status             => x_return_status);
     IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'query_reservations x_return_status',x_return_status);
     END IF;
   -- bug # 9410461: When transferring reservations
   -- only transfer the reservations which are associated MMTT records of the
   -- currrent move order line. If new reservation is created due to the split
   -- (when reservation qty is more than the current MMTT transactions qty) then
   -- stamp the new reservation id created on MMTT record.
   IF ( p_delivery_detail_split_rec.released_status = 'S'
           AND p_move_order_line_status = 'PTOTRANSFER' AND l_mmtt_tbl.Count > 0 ) THEN
   --{
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'Inside the PTO reservations'||l_size);
       END IF;
       l_sales_order_id := OE_ORDER_SCH_UTIL.Get_mtl_sales_order_id(p_source_header_id);
       l_rsv_new.demand_source_line_id    := p_split_source_line_id;
       l_rsv_new.demand_source_header_id  := l_sales_order_id;
       FOR j IN 1..l_mmtt_tbl.COUNT LOOP
       --{
           -- check reservations ids needs to be transferred.
           FOR l_counter in 1..l_size LOOP
           --{
               IF l_mmtt_tbl(j).reservation_id =  l_rsv_array(l_counter).reservation_id  THEN
               --{ Reservation is matched. needs to transfer to new line.
                   IF l_debug_on THEN
                       WSH_DEBUG_SV.log(l_module_name,'move order line id ',p_delivery_detail_split_rec.move_order_line_id);
                       WSH_DEBUG_SV.log(l_module_name, 'Reservation Id',l_mmtt_tbl(j).reservation_id);
                       WSH_DEBUG_SV.log(l_module_name,'MMTT qty ',l_mmtt_tbl(j).transaction_quantity);
                       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit reservation_split_action',WSH_DEBUG_SV.C_PROC_LEVEL);
                   END IF;
                   l_temp_transaction_quantity  := l_mmtt_tbl(j).transaction_quantity; -- p_split_quantity is IN/OUT parameter and hence this is req.
                   l_temp_transaction_quantity2 := l_mmtt_tbl(j).secondary_transaction_quantity; -- p_split_quantity is IN/OUT parameter and hence this is req.
                   reservation_split_action (
                       p_rsv             => l_rsv_array(l_counter),
                       p_rsv_new         => l_rsv_new,
                       p_staged          => l_staged_flag,
                       p_released_status => p_delivery_detail_split_rec.released_status,
                       p_split_quantity  => l_temp_transaction_quantity,
                       p_split_quantity2 => l_temp_transaction_quantity2,
                       x_new_rsv_id      => l_new_rsv_id,
		       p_shipped_flag    => p_shipped_flag,
                       x_return_status   => x_return_status);
                   IF l_debug_on THEN
                       WSH_DEBUG_SV.log(l_module_name, 'reservation_split_action',x_return_status);
                   END IF;
                   IF x_return_status <> fnd_api.g_ret_sts_success THEN
                       raise split_failed;
                   END IF;
                   IF l_new_rsv_id <> l_rsv_array(l_counter).reservation_id   THEN
                   --{
                       l_mmtt_tbl(j).reservation_id := l_new_rsv_id;
                       IF l_debug_on THEN
                           WSH_DEBUG_SV.log(l_module_name,'new reservation Id ',l_mmtt_tbl(j).reservation_id);
                           WSH_DEBUG_SV.log(l_module_name,' temp id ',l_mmtt_tbl(j).transaction_temp_id);
                           WSH_DEBUG_SV.log(l_module_name,' move order line id ',l_mmtt_tbl(j).move_order_line_id);
                           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit inv_mo_line_detail_util.update_row',WSH_DEBUG_SV.C_PROC_LEVEL);
                       END IF;
                       inv_mo_line_detail_util.update_row(
                           p_mo_line_detail_rec => l_mmtt_tbl(j),
                           x_return_status      => x_return_status);
                       IF l_debug_on THEN
                           WSH_DEBUG_SV.log(l_module_name, 'return_status',x_return_status);
                       END IF;
                       IF x_return_status <> fnd_api.g_ret_sts_success THEN
                           raise split_failed;
                       END IF;
                   --}
                   END IF;
                   EXIT;
               --}
               END IF;
           --}
           END LOOP;
       --}
       END LOOP;
   ELSE -- non PTOTRANSFER case..
     -- loop  over all the reservation records in l_rsv_array
     FOR l_counter in  1..l_size LOOP
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_STAGED_RESERVATION_UTIL.QUERY_STAGED_FLAG',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       --
       INV_STAGED_RESERVATION_UTIL.query_staged_flag(
           x_return_status   =>  x_return_status,
           x_msg_count       =>  l_msg_count,
           x_msg_data        =>  l_msg_data,
           x_staged_flag     =>  l_staged_flag,
           p_reservation_id  =>  l_rsv_array(l_counter).reservation_id);
       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'query_staged_flag x_return_status',x_return_status);
       END IF;

       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit OE_ORDER_SCH_UTIL.GET_MTL_SALES_ORDER_ID',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       --
       l_sales_order_id := OE_ORDER_SCH_UTIL.Get_mtl_sales_order_id(p_source_header_id);

       l_rsv_new.demand_source_line_id  := p_split_source_line_id;
       l_rsv_new.demand_source_header_id  := l_sales_order_id;
       --X-dock,split
       IF (p_delivery_detail_split_rec.released_status = 'S' AND
           p_delivery_detail_split_rec.move_order_line_id IS NULL) THEN
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Delivery Detail-',p_delivery_detail_split_rec.delivery_detail_id);
         END IF;
         l_rsv_new.demand_source_line_detail  :=  p_delivery_detail_split_rec.delivery_detail_id;
       END IF;
       --X-dock,split

       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'L_RSV_NEW.DEMAND_SOURCE_LINE_ID IN SPLIT_RESERV IS '||L_RSV_NEW.DEMAND_SOURCE_LINE_ID  );
         WSH_DEBUG_SV.logmsg(l_module_name, 'L_RSV_NEW.DEMAND_SOURCE_LINE_DETAIL IN SPLIT_RESERV IS '||L_RSV_NEW.DEMAND_SOURCE_LINE_DETAIL  );
         WSH_DEBUG_SV.logmsg(l_module_name, 'L_RSV_NEW.DEMAND_SOURCE_HEADER_ID IN SPLIT_RESERV IS '||L_RSV_NEW.DEMAND_SOURCE_HEADER_ID  );
         WSH_DEBUG_SV.logmsg(l_module_name, 'p_delivery_detail_split_rec.released_status '||p_delivery_detail_split_rec.released_status);
         WSH_DEBUG_SV.logmsg(l_module_name, 'l_rsv_array(l_counter).detailed_quantity '||nvl(l_rsv_array(l_counter).detailed_quantity,0)||' l_staged_flag '||l_staged_flag);
         WSH_DEBUG_SV.logmsg(l_module_name, 'l_rsv_array(l_counter).primary_reservation_quantity '||l_rsv_array(l_counter).primary_reservation_quantity);
-- HW OPMCONV - Print Qty2
         WSH_DEBUG_SV.logmsg(l_module_name, 'l_rsv_array(l_counter).secondary_detailed_quantity '||nvl(l_rsv_array(l_counter).secondary_detailed_quantity,0)||' l_staged_flag '||l_staged_flag);
         WSH_DEBUG_SV.logmsg(l_module_name, 'l_rsv_array(l_counter).secondary_reservation_quantity '||l_rsv_array(l_counter).secondary_reservation_quantity);
       END IF;

       IF ((l_rsv_array(l_counter).primary_reservation_quantity > 0) AND
           (l_rsv_array(l_counter).primary_reservation_quantity >= nvl(l_rsv_array(l_counter).detailed_quantity,0))) THEN
         IF ( p_delivery_detail_split_rec.released_status  IN   ('Y','C')  AND
               -- Bug3012297 (Included reference to parameters)
             check_inv_info( p_delivery_detail_split_rec  => p_delivery_detail_split_rec
                             , p_rsv                      => l_rsv_array(l_counter)) AND
              l_staged_flag = 'Y' )   OR
              --  We can split only staged reservation here as long as Inventory
              --  information match
              -- Bug 2540015: Added p_move_order_line_status
             ( p_delivery_detail_split_rec.released_status  NOT IN   ('Y','C')  AND
               (p_move_order_line_status = 'TRANSFER' OR
                (p_move_order_line_status = 'CANCEL' AND nvl(l_rsv_array(l_counter).detailed_quantity,0) = 0)
                ) AND
               l_staged_flag <> 'Y' )
             --  Can split only unstaged reservations with detailed_quantity NULL
             --  here.
             --  Do we have to look at inventory information here ?
             --  No  as talked to John (08/21)
         THEN
           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit reservation_split_action',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
        -- HW OPMCONV. Added l_split_quantity2

           -- 2925398: keep track of released status.
           l_released_status := p_delivery_detail_split_rec.released_status;
           IF     l_released_status = 'S'
              AND p_move_order_line_status = 'CANCEL' THEN
             -- at this time, the detailed quantity belonging to MOL of
             -- this line would have become cancelled.
             l_released_status := 'R';
           END IF;

           reservation_split_action (
              p_rsv             => l_rsv_array(l_counter),
              p_rsv_new         => l_rsv_new ,
              p_staged          => l_staged_flag,
              p_released_status => l_released_status,
              p_split_quantity  => l_split_quantity,
              p_split_quantity2 => l_split_quantity2,
              x_new_rsv_id      => l_new_rsv_id,   -- bug # 9410461: just for compatible.
	      p_shipped_flag    => p_shipped_flag, -- added for bug 10105817
              x_return_status   => x_return_status);
           IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name, 'reservation_split_action',x_return_status);
           END IF;
           IF x_return_status <> fnd_api.g_ret_sts_success THEN
             raise split_failed;
           END IF;
         END IF;  --  <>  'Y','C'
       END IF;
      IF l_split_quantity  = 0  THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'NOTHING TO SPLIT WE WILL EXIT IN SPLIT_RESERVATION' );
      END IF;
      --
         EXIT;
      END IF;
    END LOOP;   --  Loop over reservation records
-- HW OPMCONV. Removed code forking
   --} PTOTRANSFER case
   END IF; -- bug # 9410461: : End
   --
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   EXCEPTION
    WHEN split_failed THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'SPLIT_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:SPLIT_FAILED');
    END IF;
    --
    -- bug 5226867
    -- Added the new excpetion for unexpected error
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    -- bug 5226867
    WHEN others THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    wsh_util_core.default_handler('WSH_USA_INV_PVT.split_reservation',l_module_name);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END split_reservation;

-- update_serial_numbers

PROCEDURE  update_serial_numbers(
       p_delivery_detail_id    IN NUMBER,
       p_serial_number        IN  VARCHAR2,
       p_transaction_temp_id    IN  NUMBER,
       x_return_status        OUT NOCOPY    VARCHAR2)
IS
CURSOR Get_Sl_Num_Ctrl_Cd IS
  SELECT msi.serial_number_control_code
  FROM   mtl_system_items  msi,
     wsh_delivery_details wdd
  WHERE  msi.inventory_item_id   = wdd.inventory_item_id
  AND msi.organization_id  = wdd.organization_id
  AND wdd.delivery_detail_id  = p_delivery_detail_id;

l_serial_number_control_code NUMBER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'UPDATE_SERIAL_NUMBERS';
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
      WSH_DEBUG_SV.log(l_module_name,'P_SERIAL_NUMBER',P_SERIAL_NUMBER);
      WSH_DEBUG_SV.log(l_module_name,'P_TRANSACTION_TEMP_ID',P_TRANSACTION_TEMP_ID);
  END IF;
  --
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'IN WSH_USA_INV_PVT.UPDATE_SERIAL_NUMBERS'  );
  END IF;
  --
  IF (p_serial_number IS NULL) AND (p_transaction_temp_id IS NULL) THEN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   RETURN;
  ELSE
   OPEN Get_Sl_Num_Ctrl_Cd;
   FETCH Get_Sl_Num_Ctrl_Cd INTO l_serial_number_control_code;
   IF Get_Sl_Num_Ctrl_Cd%NOTFOUND THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    CLOSE Get_Sl_Num_Ctrl_Cd;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    RETURN;
   END IF;
   CLOSE Get_Sl_Num_Ctrl_Cd;

   WSH_DELIVERY_DETAILS_INV.Unmark_Serial_Number(
      p_delivery_detail_id  => p_delivery_detail_id,
      p_serial_number_code  => l_serial_number_control_code,
      p_serial_number    => p_serial_number,
      p_transaction_temp_id => p_transaction_temp_id,
      x_return_status    => x_return_status);
   IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Unmark_Serial_Number x_return_status',x_return_status);
   END IF;
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    RETURN;
   END IF;
   UPDATE wsh_delivery_details SET
   serial_number = NULL,
   to_serial_number = NULL,
   transaction_temp_id = NULL,
   shipped_quantity = 0
   WHERE delivery_detail_id = p_delivery_detail_id;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WSH_UTIL_CORE.default_handler('WSH_USA_INV_PVT.update_serial_numbers',l_module_name);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END update_serial_numbers;


PROCEDURE Update_Inventory_Info(
  p_Changed_Attributes        IN     WSH_INTERFACE.ChangedAttributeTabType
, x_return_status           OUT NOCOPY  VARCHAR2)
IS

-- Bug 2657652 : Changed cursor to fetch selective columns instead of *
-- Columns added for bug 4093619(FP-4145867) to fetch delivery grouping
-- attributes

CURSOR C_Old_Detail (p_Counter NUMBER)
IS
SELECT organization_id,
       source_header_number,
       ship_from_location_id,
       delivery_detail_id,
       released_status,
       move_order_line_id,
       requested_quantity,
       requested_quantity_uom,
       requested_quantity2,
       picked_quantity,
       picked_quantity2,
       inventory_item_id,
       subinventory,
       locator_id,
       lot_number,
-- HW OPMCONV - No need for sublot_number
--     sublot_number,
       preferred_grade,
       revision,
       serial_number,
       transaction_temp_id,
       ship_set_id,
       top_model_line_id,
       source_line_number, -- Bug 3481801
       -- deliveryMerge
       pickable_flag,
       -- J inbound logistics --jckwok
       nvl(line_direction, 'O') line_direction,
       -- J Consolidation of Back Order Delivery Details Enhancement
       source_line_id,
       tracking_number,  -- bug# 3632485
       nvl(ignore_for_planning,'N') ignore_for_planning,
       customer_id, -- Start of Bug 4093619(FP-4145867)
       ship_to_location_id,
       intmed_ship_to_location_id,
       fob_code,
       freight_terms_code,
       ship_method_code,
       deliver_to_location_id,
       shipping_control,
       mode_of_transport,
       carrier_id,
       service_level, -- End of Bug 4093619(FP-4145867)
       requested_quantity_uom2, --Bug# 5436033
       client_id -- LSP PROJECT
FROM wsh_delivery_details
WHERE delivery_detail_id = p_Changed_Attributes(p_Counter).delivery_detail_id ;

old_delivery_detail_rec   C_Old_Detail%ROWTYPE;

--  Consolidation of Back Order Delivery Details Enhancement

-- Added the record to call the WSH_SHIPPING_PARAMS_PVT.Get_Global_Parameters
l_global_param_rec_type WSH_SHIPPING_PARAMS_PVT.Global_Parameters_Rec_Typ;

-- Added tables to call the wsh_delivery_details_actions.Consolidate_Source_Lines
l_Cons_Source_Line_Rec_Tab   WSH_DELIVERY_DETAILS_ACTIONS.Cons_Source_Line_Rec_Tab;
l_cons_dd_ids           WSH_UTIL_CORE.Id_Tab_Type;

-- To store the shipping global parameter "Consolidate BO lines" value
l_auto_consolidate           VARCHAR2(1) := 'N';
-- To check the consolidation happened or Not
l_cons_flag                  VARCHAR2(1) := 'N';

-- End of Consolidation of Back Order Delivery Details Enhancement

l_changed_attributes                 WSH_INTERFACE.ChangedAttributeTabType;
l_counter                     NUMBER;
l_delivery_status                   VARCHAR2(3);
l_container_instance_id               NUMBER;
l_number_of_shipped_details             NUMBER;
l_number_of_packed_details               NUMBER;
l_exception_return_status             VARCHAR2(30);
l_exception_msg_count               NUMBER;
l_exception_msg_data                 VARCHAR2(4000) := NULL;
l_exception_assignment_id             NUMBER;
l_exception_error_message              VARCHAR2(2000) := NULL;
l_exception_location_id              NUMBER;
l_dummy_exception_id                 NUMBER;
l_dummy_detail_id                 NUMBER;
l_parent_detail_id                 NUMBER;
l_container_name                   VARCHAR2(30);
l_return_status                 VARCHAR2(30);
l_split_quantity                   NUMBER;
-- odaboval : Begin of OPM Changes (Pick_Confirm)
l_split_quantity2                  NUMBER;
-- odaboval : End of OPM Changes (Pick_Confirm)
l_multiple_update                 VARCHAR2(1);
l_ship_status                    VARCHAR2(100);
l_reject_update                    VARCHAR2(1);
l_cont_name                     VARCHAR2(30);
l_cont_item_id                     NUMBER ;
l_cont_instance_id                     NUMBER ;
l_num_containers                    NUMBER ;
l_organization_id                   NUMBER ;
l_delivery_detail_ids     WSH_UTIL_CORE.Id_Tab_Type;
l_row_id             VARCHAR2(30);
l_request_id                  NUMBER;
l_msg                      VARCHAR2(2000) := NULL;
l_item_name          VARCHAR2(2000):=NULL; -- Bug 1577237 : Earlier this was 40 characters long.
      -- Other packages that call get_item_name store the
      -- result in 2000 characters long variable, so made the
      -- same change here .
-- bug lgao 1635782
-- HW OPMCONV. Removed OPM variables

l_update_sub       VARCHAR2(1);
l_update_loc       VARCHAR2(1);
l_update_rev       VARCHAR2(1);

l_update_lot       VARCHAR2(1);
l_update_preferred_grade VARCHAR2(1);
l_update_serial_number   VARCHAR2(1);
l_update_rel_status   VARCHAR2(1);
l_update_quantities   VARCHAR2(1);
-- Bug 2657652 : Serial Numbers enhancement
l_update_transaction_temp_id   VARCHAR2(1);
l_update_shipped_quantity      VARCHAR2(1);

l_copy_detail_rec WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type;
l_details_to_delete  WSH_UTIL_CORE.Id_Tab_Type;
l_delete_count      NUMBER := 0;

l_overpick_rec    WSH_INTERFACE.ChangedAttributeRecType;
l_source_code    WSH_DELIVERY_DETAILS.SOURCE_CODE%TYPE;
l_new_req_quantity  NUMBER;
-- HW OPM added qty2
l_new_req_quantity2  NUMBER;
l_delivery_id    NUMBER;
l_planned_flag    VARCHAR2(1);
l_del_batch_id       NUMBER;

l_picked_qty   NUMBER;

l_wms_enabled_flag VARCHAR2(1); --  Bug fix: 2340652

l_backorder_cnt  NUMBER; -- Counter for Backorder of SS/SMC lines

l_dummy_quantity NUMBER;

-- bug 2805603 : added following variables for call to get_inv_pc_attributes and set_inv_pc_attributes
l_InvPCOutRecType       WSH_INTEGRATION.InvPCOutRecType;
l_InvPCInRecType        WSH_INTEGRATION.InvPCInRecType;
l_transaction_id        NUMBER;
l_transaction_temp_id   wsh_delivery_Details.transaction_temp_id%type;
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);

l_user_id  NUMBER;
l_login_id NUMBER;

-- Following variables added for Bug 4093619(FP-4145867) to store delivery grouping
-- attributes value for container record.
 l_customer_id                     NUMBER;
 l_ship_to_location_id             NUMBER;
 l_intmed_ship_to_location_id      NUMBER;
 l_deliver_to_location_id          NUMBER;
 l_fob_code                        WSH_DELIVERY_DETAILS.Fob_Code%TYPE;
 l_freight_terms_code              WSH_DELIVERY_DETAILS.Freight_Terms_Code%TYPE;
 l_ship_method_code                WSH_DELIVERY_DETAILS.Ship_Method_Code%TYPE;
 l_line_direction                  WSH_DELIVERY_DETAILS.line_direction%TYPE;
 l_ignore_for_planning             WSH_DELIVERY_DETAILS.ignore_for_planning%TYPE;
 l_shipping_control                WSH_DELIVERY_DETAILS.shipping_control%TYPE;
 l_mode_of_transport               WSH_DELIVERY_DETAILS.mode_of_transport%TYPE;
 l_service_level                   WSH_DELIVERY_DETAILS.service_level%TYPE;
 l_carrier_id                      NUMBER;
 l_client_id                       NUMBER; -- LSP PROJECT

-- K LPN CONV. rvishnuv
l_cont_tab wsh_util_core.id_tab_type;
l_lpn_unit_weight NUMBER;
l_lpn_unit_volume NUMBER;
l_lpn_weight_uom_code VARCHAR2(100);
l_lpn_volume_uom_code VARCHAR2(100);
l_create_cnt_caller   constant VARCHAR2(100) := 'WSH_PICK_RELEASE';
-- K LPN CONV. rvishnuv
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'UPDATE_INVENTORY_INFO';
--
/* 2740833 */
l_rs_ignored       VARCHAR2(30);
l_net_weight       NUMBER;
l_volume           NUMBER;

-- deliveryMerge
Adjust_Planned_Flag_Err   EXCEPTION;
l_adjust_planned_del_tab  WSH_UTIL_CORE.Id_Tab_Type;
l_delivery_already_included  boolean;

-- inbound --jckwok
Delivery_Line_Direction_Err EXCEPTION;
--Added for bug 5234326
l_cnt_tab       WSH_UTIL_CORE.Id_Tab_Type;

l_det_tab        WSH_UTIL_CORE.Id_Tab_Type;

l_detail_tab    WSH_UTIL_CORE.id_tab_type; -- DBI Project
l_dbi_rs         VARCHAR2(1);              -- DBI Project
l_dd_txn_id    NUMBER;     -- DBI Project
l_txn_return_status  VARCHAR2(1);  -- DBI Project

l_wf_rs         VARCHAR2(1);     --Pick to POD WF Project

-- Bug 3390514 : Treating FND_API.G_MISS_NUM in pending_quantity as Zero
l_pending_quantity      NUMBER;
l_backordered_item_id NUMBER;
l_top_model_item_id   NUMBER;

-- LPN CONV rv
l_original_caller VARCHAR2(100) := WSH_WMS_LPN_GRP.g_caller;
l_orig_callback_reqd VARCHAR2(100) := WSH_WMS_LPN_GRP.g_callback_required;
-- LPN CONV rv

--Bug 3878429: treat fnd_api.g_miss_num in pending_quantity2 as zero
l_pending_quantity2 NUMBER;
-- /==Workflow Change
Cursor c_get_picked_lines_count (c_delivery_detail_id NUMBER)
IS
SELECT count (wdd.delivery_detail_id), delivery_id
FROM
	wsh_delivery_details wdd,
	  wsh_delivery_assignments_v wda
WHERE
	wdd.delivery_detail_id = wda.delivery_detail_id
	AND wda.delivery_id = (  SELECT delivery_id
						FROM wsh_delivery_assignments_v
						WHERE delivery_detail_id = c_delivery_detail_id )
         AND wdd.released_status NOT IN ('R', 'X', 'N')
         AND wdd.pickable_flag = 'Y'
	 AND wdd.container_flag = 'N'
     GROUP BY delivery_id;
l_count_picked_lines NUMBER;
l_delv_id NUMBER;
-- Workflow Change==/

l_requested_quantity2 NUMBER := NULL; -- bug# 5436033
l_post_process_flag   VARCHAR2(1);  -- Bug # 7307755
--Bug 7592072
 	 l_under_pick_post_process_flag  VARCHAR2(1);
 	 l_cont_gross_weight             NUMBER;
 	 l_cont_net_weight               NUMBER;
 	 l_cont_volume                   NUMBER;
 	 l_cont_fill_pc                  NUMBER;
--Bug 7592072

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
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   l_multiple_update := 'N';

   -- deliveryMerge
   l_adjust_planned_del_tab.delete;

   l_user_id  := FND_GLOBAL.user_id;
   l_login_id := FND_GLOBAL.login_id;

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,  'IN UPDATE_INVENTORY_INFO PROCEDURE ...'  );
       WSH_DEBUG_SV.logmsg(l_module_name,  'Calling program unit WSH_INTEGRATION.Get_Inv_PC_Attributes' );
   END IF;
   --
   -- bug 2805603 : added call to get_inv_pc_attributes and set_inv_pc_attributes to get transaction_id and transaction_temp_id
   WSH_INTEGRATION.Get_Inv_PC_Attributes
                ( p_out_attributes       => l_InvPCOutRecType,
                  x_return_status        => l_return_status,
                  x_msg_count            => l_msg_count,
                  x_msg_data             => l_msg_data) ;
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'After call to Get_Inv_PC_Attributes ',l_return_status);
   END IF;
   IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,  'Errored out in Get_Inv_PC_Attributes '  );
       END IF;
   ELSE
       l_transaction_id      := l_InvPCOutRecType.transaction_id;
       l_transaction_temp_id := l_InvPCOutRecType.transaction_temp_id;
       IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,  'l_transaction_id IS ' || L_TRANSACTION_ID  );
    WSH_DEBUG_SV.logmsg(l_module_name,  'l_transaction_temp_id IS ' || L_TRANSACTION_TEMP_ID  );
       END IF;
   END IF;

   -- Assumption : Inventory will be setting the Transaction and Transaction_Temp_Id
   -- and Shipping will reset both the values to Null whenever action_flag <> 'M'. This is because when
   -- action_flag is M, recursive call to update_inventory_info is done with action_flag as U.
   -- So values will be lost during the 2nd call. That is why it is not reset for action_flag as M.
   IF p_changed_attributes(p_changed_attributes.FIRST).action_flag <> 'M' THEN
   --{
      --Bug#5104847:Assigning default value FND_API.G_MISS_NUM to trx_id and trx_temp_id as
      --
      IF ( l_transaction_id <> FND_API.G_MISS_NUM OR l_transaction_id IS NULL
             OR l_transaction_temp_id <> FND_API.G_MISS_NUM OR l_transaction_temp_id IS NULL) THEN
      --{
          l_InvPCInRecType.transaction_id      :=  FND_API.G_MISS_NUM;
          l_InvPCInRecType.transaction_temp_id :=  FND_API.G_MISS_NUM;
          l_InvPCInRecType.source_code         := 'INV';
          l_InvPCInRecType.api_version_number  :=  1.0;
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,  'Calling program unit WSH_INTEGRATION.Set_Inv_PC_Attributes' );
          END IF;
          --
          WSH_INTEGRATION.Set_Inv_PC_Attributes
               ( p_in_attributes         =>   l_InvPCInRecType,
                 x_return_status         =>   l_return_status,
                 x_msg_count             =>   l_msg_count,
                 x_msg_data              =>   l_msg_data );

          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'After call to Set_Inv_PC_Attributes ',l_return_status);
          END IF;
          IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
              x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
              IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,  'Errored out in Set_Inv_PC_Attributes '  );
              END IF;
          END IF;
      END IF;
   END IF;

   -- Assumption : Whenever Inventory calls with transaction_temp_id, they will pass only 1 record in
   -- p_changed_attributes. If not, return error for the transaction
   --Bug#5104847:transaction_temp_id default value is FND_API.G_MISS_NUM
   IF  ( l_transaction_temp_id IS NOT NULL AND l_transaction_temp_id <> FND_API.G_MISS_NUM ) AND p_changed_attributes.COUNT > 1 THEN

       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,  'Number of records passed by inventory ' || p_changed_attributes.COUNT  );
          WSH_DEBUG_SV.logmsg(l_module_name,  'Reject request as transaction_temp_id is passed for more than 1 record by inventory ');
       END IF;
       l_ship_status := 'having more than 1 record from inventory to be processed';
       FND_MESSAGE.Set_Name('WSH', 'WSH_REJECT_UPDATE_REQUEST');
       FND_MESSAGE.Set_Token('SHIP_STATUS', l_ship_status);
       FND_MESSAGE.Set_Token('UPDATE_ATTRIBUTE', 'transaction_temp_id');
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
       IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name,'ERROR:REJECT INV REQUEST');
       END IF;
       RETURN;
   END IF;

   FOR l_counter IN p_Changed_Attributes.FIRST .. p_Changed_Attributes.LAST
   LOOP
    l_update_sub := 'N';
    l_update_loc := 'N';
    l_update_rev := 'N';
-- HW OPMCONV - No need for sublot_number
--  l_update_sublot := 'N';
    l_update_lot := 'N';
    l_update_preferred_grade := 'N';
    l_update_serial_number := 'N';
    l_update_rel_status := 'N';
          l_update_transaction_temp_id := 'N';
          l_update_shipped_quantity := 'N';

    l_update_quantities := 'N';
    l_new_req_quantity := NULL;


    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,  'L_COUNTER IS ' || L_COUNTER  );
        WSH_DEBUG_SV.logmsg(l_module_name,  'ACTION FLAG IS ' || P_CHANGED_ATTRIBUTES ( L_COUNTER ) .ACTION_FLAG  );
        WSH_DEBUG_SV.logmsg(l_module_name,  'DELDET ID IS ' || P_CHANGED_ATTRIBUTES ( L_COUNTER ) .DELIVERY_DETAIL_ID  );
        WSH_DEBUG_SV.logmsg(l_module_name,  'ORDERED QTY IS ' || P_CHANGED_ATTRIBUTES ( L_COUNTER ) .ORDERED_QUANTITY  );
    END IF;

	  -- Bug 3390514 : Treating FND_API.G_MISS_NUM in pending_quantity as Zero
	  IF  p_changed_attributes(l_counter).pending_quantity = FND_API.G_MISS_NUM THEN
	  --{
	      l_pending_quantity := 0;
	  --}
	  ELSE
	  --{
	      l_pending_quantity := p_changed_attributes(l_counter).pending_quantity;
	  --}
	  END IF;

          --Bug 3878429.
	  IF  p_changed_attributes(l_counter).pending_quantity2 = FND_API.G_MISS_NUM THEN
	  --{
	      l_pending_quantity2 := 0;
	  --}
	  ELSE
	  --{
	      l_pending_quantity2 := p_changed_attributes(l_counter).pending_quantity2;
	  --}
	  END IF;

    l_delivery_status := 'OK';

    BEGIN
     SELECT wnd.status_code,
        wnd.delivery_id,
        wnd.planned_flag,
        wnd.batch_id
     INTO   l_delivery_status,
        l_delivery_id,
        l_planned_flag,
        l_del_batch_id
     FROM   wsh_new_deliveries wnd,
        wsh_delivery_details wdd,
        wsh_delivery_assignments_v wda
     WHERE  wdd.delivery_detail_id = p_changed_attributes(l_Counter).delivery_detail_id
     AND  wda.delivery_id = wnd.delivery_id
     AND  wda.delivery_detail_id = wdd.delivery_detail_id ;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
      l_delivery_status := 'OK';
      l_delivery_id     := NULL;
      l_planned_flag    := 'N'; -- Bug 2573434 : changed from NULL to 'N' to check if delivery can be unassigned
      l_del_batch_id        := NULL;
    END;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,  'DELIVERY STATUS IS ' || L_DELIVERY_STATUS  );
        WSH_DEBUG_SV.logmsg(l_module_name,  'DELIVERY ID IS ' || L_DELIVERY_ID  );
        WSH_DEBUG_SV.logmsg(l_module_name,  'PLANNED FLAG IS ' || L_PLANNED_FLAG  );
    END IF;

    OPEN  C_Old_Detail(l_counter);
    FETCH C_Old_Detail
    INTO  old_delivery_detail_rec;
    IF c_old_detail%NOTFOUND THEN
      old_delivery_detail_rec.released_status := 'N';
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,
                            'c_old_detail not found. setting status N.');
      END IF;
    END IF;
    CLOSE C_Old_Detail;
          -- J: raise an exception if line_direction is not 'outbound' or 'internal order' -- jckwok
                IF (old_delivery_detail_rec.line_direction NOT IN ('O', 'IO')) THEN
                      FND_MESSAGE.Set_Name('WSH', 'WSH_DEL_LINE_DIR_INVALID');
                      FND_MESSAGE.Set_Token('DELIVERY_DETAIL_ID', old_delivery_detail_rec.delivery_detail_id);
                      WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
                      IF l_debug_on THEN
                           WSH_DEBUG_SV.logmsg(l_module_name,'ERROR: operation is invalid for delivery line direction');
                      END IF;
                      raise Delivery_Line_Direction_Err;
                END IF;

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,
                         'original RELEASED_STATUS',
                         OLD_DELIVERY_DETAIL_REC.RELEASED_STATUS );
        WSH_DEBUG_SV.logmsg(l_module_name,  'ORGANIZATION ID IS ' || OLD_DELIVERY_DETAIL_REC.ORGANIZATION_ID  );
    END IF;

    -- bug 4481819: fail pick confirm if released status is 'N'
    -- to prevent stuck orders in Interface Trip Stop.
    -- message needs to be set for the caller.
    --
    -- Backordering should still be allowed.
    --
    IF     OLD_DELIVERY_DETAIL_REC.RELEASED_STATUS = 'N'
       AND p_changed_attributes(l_Counter).action_flag <>  'B'
       THEN

       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

       FND_MESSAGE.SET_NAME('WSH', 'WSH_PICK_CONFIRM_NOT_READY');

       FND_MESSAGE.SET_TOKEN('SOURCE_LINE_NUM',
                             old_delivery_detail_rec.source_line_number);
       FND_MESSAGE.SET_TOKEN('SOURCE_ORDER_NUM',
                             old_delivery_detail_rec.source_header_number);

       WSH_UTIL_CORE.add_message (x_return_status, l_module_name);

       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'detail is not ready to release.');
         WSH_DEBUG_SV.pop(l_module_name);
       END IF;
       RETURN;
    END IF;


    --
      -- Bug fix 2340652
      -- We need to know if the org is wms enabled.
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.CHECK_WMS_ORG',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      l_wms_enabled_flag := WSH_UTIL_VALIDATE.Check_Wms_Org(old_delivery_detail_rec.organization_id);

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,  'WMS ENABLED FLAG IS ' || L_WMS_ENABLED_FLAG  );
    END IF;
    --
      --Bug fix 2340652

    --
    -- Debug Statements
    --
-- HW OPMCONV. Removed checking for OPM orgs


    -- handle multiple updates on serial/lot number
    IF (p_changed_attributes(l_counter).action_flag = 'M') THEN
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'CALLED WITH MULTIPLE UPDATES'  );
     END IF;
     --
     l_multiple_update := 'Y';
     l_changed_attributes(l_counter) := p_changed_attributes(l_counter);

     IF (p_changed_attributes(l_counter).picked_quantity = FND_API.G_MISS_NUM) THEN

    -- Can  l_split_quantity is null ? If yes , then we need to handle that condition here.
       l_split_quantity := p_changed_attributes(l_counter).ordered_quantity ;

       -- odaboval : Begin of OPM Changes (Pick_Confirm)
      if ( p_changed_attributes(l_Counter).ordered_quantity2 =  FND_API.G_MISS_NUM ) then
          l_split_quantity2 := null ;
      else
        l_split_quantity2 := p_changed_attributes(l_Counter).ordered_quantity2 ;
      end if ;

      -- odaboval : End of OPM Changes (Pick_Confirm)

       IF (l_split_quantity = old_Delivery_detail_rec.requested_quantity) THEN
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'CHANGING ACTION FLAG TO U '  );
        END IF;
        --
        l_changed_attributes(l_counter).action_flag := 'U';
       ELSE
        -- odaboval : Begin of OPM Changes (Pick_Confirm)
        WSH_DELIVERY_DETAILS_ACTIONS.Split_Delivery_Details(
              p_from_detail_id   => p_Changed_attributes(l_counter).delivery_detail_id,
              p_req_quantity   => l_split_quantity,
              x_new_detail_id => l_dummy_detail_id,
              x_return_status => l_return_status,
              p_req_quantity2 => l_split_quantity2,
              p_manual_split   => p_changed_attributes(l_counter).action_flag);
        -- odaboval : End of OPM Changes (Pick_Confirm)
        IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Split_Delivery_Details',l_return_status);
        END IF;

        -- Bug 3724578 : Return back to the caller if any error occures while
        --               splitting the delivery detail line
	--- Message will be set in  Split_Delivery_Details
	IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
		 x_return_status := l_return_status;
                 return;
	END IF;

	l_changed_attributes(l_counter).delivery_detail_id := l_dummy_detail_id;
        l_changed_attributes(l_counter).action_flag := 'U';
       END IF;
     /* LG BUG#:2005977 */
-- HW OPMCONV. Removed code forking

     ELSE -- picked_quantity is passed for 'M'

       l_changed_attributes(l_counter).action_flag := 'U';

     l_dummy_detail_id := p_changed_attributes(l_counter).delivery_detail_id;
       l_split_quantity := p_changed_attributes(l_counter).picked_quantity ;

       -- begin of OPM
       if ( p_changed_attributes(l_Counter).picked_quantity2 =  FND_API.G_MISS_NUM ) then
        l_split_quantity2 := null ;
     else
    l_split_quantity2 := p_changed_attributes(l_Counter).picked_quantity2 ;
       end if ;
       -- end of OPM

       -- keep this line's picked_quantity up to date as sum of picked_quantity+pending_quantity,
       -- so that we can split the current picked_quantity and the old line will have pending quantity.
       old_delivery_detail_rec.picked_quantity := p_changed_attributes(l_counter).picked_quantity
                            + l_pending_quantity; -- Bug#: 3390514

       --Fix for bug 3878429
       --Use l_pending_quantity2 instead of p_changed_attributes(l_counter).pending_quantity2
       --because p_changed_attributes(l_counter).pending_quantity2 could be fnd_api.g_miss_num

         old_delivery_detail_rec.picked_quantity2 := l_split_quantity2 + l_pending_quantity2;

/*
       old_delivery_detail_rec.picked_quantity2 := l_split_quantity2
                            + p_changed_attributes(l_counter).pending_quantity2; */

       UPDATE WSH_DELIVERY_DETAILS
       SET  picked_quantity  = old_delivery_detail_rec.picked_quantity,
          picked_quantity2 = old_delivery_detail_rec.picked_quantity2,
          requested_quantity_uom2 = DECODE(l_wms_enabled_flag,
                                           'Y',
                                           DECODE(p_changed_attributes(l_counter).ordered_quantity_uom2,
                                                  FND_API.G_MISS_CHAR, requested_quantity_uom2,
                                                  p_changed_attributes(l_counter).ordered_quantity_uom2),
                                           requested_quantity_uom2)
       WHERE delivery_detail_id = old_delivery_detail_rec.delivery_detail_id;

       IF l_split_quantity < old_delivery_detail_rec.picked_quantity THEN

       WSH_DELIVERY_DETAILS_ACTIONS.Split_Delivery_Details(
              p_from_detail_id   => p_Changed_attributes(l_counter).delivery_detail_id,
              p_req_quantity   => l_split_quantity,
              x_new_detail_id => l_dummy_detail_id,
              x_return_status => l_return_status,
              p_req_quantity2 => l_split_quantity2,
              p_manual_split   => p_changed_attributes(l_counter).action_flag);
       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Split_Delivery_Details l_return_status',l_return_status);
       END IF;


       -- Bug 3724578 : Return back to the caller if any error occures while
        --               splitting the delivery detail line
        --- Message will be set in  Split_Delivery_Details
        IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
           x_return_status := l_return_status;
                       return;
        END IF;
       END IF;

       -- If this delivery line has requested_quantity > 0, it is not pending overpick,
       -- and its picked quantity columns should be NULL.
       UPDATE wsh_delivery_details
        SET picked_quantity  = decode(requested_quantity, 0, picked_quantity, NULL),
          picked_quantity2 = decode(requested_quantity2, 0, picked_quantity2, NULL)
      WHERE delivery_detail_id = old_delivery_detail_rec.delivery_detail_id;

       l_changed_attributes(l_counter).delivery_detail_id := l_dummy_detail_id;

     END IF; -- (p_changed_attributes(l_counter).picked_quantity = FND_API.G_MISS_NUM) for 'M'

     /* NC - Added - OPM Changes BUG# 1675561 */
 -- HW OPMCONV. Removed code forking

    ELSE
     IF (p_changed_attributes(l_Counter).action_flag =  'S' )  THEN

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'ACTION FLAG IS S'  );
          WSH_DEBUG_SV.log(l_module_name, 'p_changed_attributes(l_counter).picked_quantity', p_changed_attributes(l_counter).picked_quantity);
          WSH_DEBUG_SV.log(l_module_name, 'p_changed_attributes(l_counter).picked_quantity2', p_changed_attributes(l_counter).picked_quantity2);
         WSH_DEBUG_SV.log(l_module_name, 'l_pending_quantity', l_pending_quantity);
         WSH_DEBUG_SV.log(l_module_name, 'l_pending_quantity2', l_pending_quantity2);
      END IF;
      --

      IF p_changed_attributes(l_counter).picked_quantity <> FND_API.G_MISS_NUM THEN

          -- begin of OPM
          if ( p_changed_attributes(l_Counter).picked_quantity2 =  FND_API.G_MISS_NUM ) then
          l_split_quantity2 := null ;
        else
      l_split_quantity2 := p_changed_attributes(l_Counter).picked_quantity2 ;
          end if ;
          -- end of OPM

          -- keep this line's picked_quantity up to date as sum of picked_quantity+pending_quantity,
          old_delivery_detail_rec.picked_quantity := p_changed_attributes(l_counter).picked_quantity
                            + l_pending_quantity; -- Bug#: 3390514

          --Fix for bug 3878429
          --Use l_pending_quantity2 instead of p_changed_attributes(l_counter).pending_quantity2
          --because p_changed_attributes(l_counter).pending_quantity2 could be fnd_api.g_miss_num

           old_delivery_detail_rec.picked_quantity2 := l_split_quantity2 + l_pending_quantity2;

/*          old_delivery_detail_rec.picked_quantity2 := l_split_quantity2
                            + p_changed_attributes(l_counter).pending_quantity2; */

          IF l_debug_on THEN
             wsh_debug_sv.log(l_module_name, 'old_delivery_detail_rec.picked_quantity', old_delivery_detail_rec.picked_quantity);
             wsh_debug_sv.log(l_module_name, 'old_delivery_detail_rec.picked_quantity2', old_delivery_detail_rec.picked_quantity2);
          END IF;

          UPDATE WSH_DELIVERY_DETAILS
          SET picked_quantity  = old_delivery_detail_rec.picked_quantity,
             picked_quantity2 = old_delivery_detail_rec.picked_quantity2
          WHERE delivery_detail_id = old_delivery_detail_rec.delivery_detail_id;

          l_split_quantity := l_pending_quantity; -- Bug#: 3390514

          IF (p_changed_attributes(l_counter).pending_quantity2 = FND_API.G_MISS_NUM) THEN
          l_split_quantity2 := old_delivery_detail_rec.requested_quantity2;
          ELSE
          l_split_quantity2 := p_changed_attributes(l_counter).pending_quantity2;
          END IF;

      ELSE
        -- In order to update released status correctly, I manually use
        -- this split quantity to have the newly create delivery detail
        -- to be backorder detail
        l_split_quantity := old_delivery_detail_rec.requested_quantity -  p_Changed_attributes(l_Counter).ordered_quantity;
        -- odaboval : Begin of OPM Changes (Pick_Confirm)
        if ( p_changed_attributes(l_Counter).ordered_quantity2 =  FND_API.G_MISS_NUM ) then
        l_split_quantity2 := old_delivery_detail_rec.requested_quantity2  ;
        else
        l_split_quantity2 := old_delivery_detail_rec.requested_quantity2 -  p_changed_attributes(l_Counter).ordered_quantity2 ;
        end if ;
      END IF;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.SPLIT_DELIVERY_DETAILS',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      WSH_DELIVERY_DETAILS_ACTIONS.Split_Delivery_Details(
               p_from_detail_id   => p_Changed_attributes(l_counter).delivery_detail_id,
               p_req_quantity  => l_split_quantity,
               x_new_detail_id  => l_dummy_detail_id,
               x_return_status  => l_return_status,
               p_req_quantity2  => l_split_quantity2,
               p_manual_split  => p_changed_attributes(l_counter).action_flag);
      -- odaboval : End of OPM Changes (Pick_Confirm)
      IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Split_Delivery_Details l_return_status',l_return_status);
      END IF;

        -- Bug 3724578 : Return back to the caller if any error occures while
        --               splitting the delivery detail line
	-- Message will be set in  Split_Delivery_Details
	IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
		 x_return_status := l_return_status;
                 return;
	END IF;

 /* LG BUG#:2005977 */
-- HW OPMCONV. Removed code forking

      IF p_changed_attributes(l_counter).picked_quantity <> FND_API.G_MISS_NUM THEN
          -- correct the requested quantities of the split lines.
          -- be sure to clear the picked quantities if line has requested_quantity > 0.

      UPDATE wsh_delivery_details
          SET requested_quantity = LEAST(old_delivery_detail_rec.requested_quantity,
                          picked_quantity),
             requested_quantity2 = LEAST(old_delivery_detail_rec.requested_quantity2,
                          picked_quantity2)
          WHERE delivery_detail_id = old_delivery_detail_rec.delivery_detail_id
          RETURNING requested_quantity, requested_quantity2 INTO l_split_quantity, l_split_quantity2;

      --
      -- DBI Project
      -- Update of wsh_delivery_details where requested_quantity
      -- are changed, call DBI API after the update.
      -- DBI API checks for DBI Installed also
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Detail id-',old_delivery_detail_rec.delivery_detail_id);
      END IF;
      l_detail_tab(1) := old_delivery_detail_rec.delivery_detail_id;
      WSH_INTEGRATION.DBI_Update_Detail_Log
        (p_delivery_detail_id_tab => l_detail_tab,
         p_dml_type               => 'UPDATE',
         x_return_status          => l_dbi_rs);

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
      END IF;
      -- DBI API can only raise unexpected error, in that case need to
      -- pass it to the caller API for roll back of the whole transaction
      -- Only need to handle Unexpected error, rest are treated as success
      -- Since code is not proceeding, no need to reset x_return_status
      IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
        x_return_status := l_dbi_rs;
        IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        RETURN;
      END IF;

      -- End of Code for DBI Project
      --

          l_split_quantity := GREATEST(old_delivery_detail_rec.requested_quantity - l_split_quantity, 0);
          l_split_quantity2 := GREATEST(old_delivery_detail_rec.requested_quantity2 - l_split_quantity2, 0);
          UPDATE wsh_delivery_details SET
            requested_quantity = l_split_quantity,
             requested_quantity2 = l_split_quantity2,
          picked_quantity  = decode(l_split_quantity, 0, picked_quantity, NULL),
          picked_quantity2 = decode(l_split_quantity2, 0, picked_quantity2, NULL)
          WHERE delivery_detail_id = l_dummy_detail_id;
          -- bug 4416863
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.Detail_Weight_Volume',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          WSH_WV_UTILS.Detail_Weight_Volume
                                             (p_delivery_detail_id => l_dummy_detail_id,
                                              p_update_flag        => 'Y',
                                              p_post_process_flag  => 'Y',
                                              p_calc_wv_if_frozen  => 'N',
                                              x_net_weight         => l_net_weight,
                                              x_volume             => l_volume,
                                              x_return_status      => l_return_status);
          IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
            x_return_status := l_return_status;
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Detail_Weight_Volume returned '|| l_return_status);
              WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            return;
          END IF;
          -- end bug 4416863

      ELSE

          -- make sure the newly create detail will be released_status of 'S'
          UPDATE wsh_delivery_details
          SET released_status =  'S'
          WHERE delivery_detail_id = l_dummy_detail_id
	  RETURNING organization_id
          INTO l_organization_id;

	--DBI api
 		WSH_DD_TXNS_PVT. create_dd_txn_from_dd  (
 					p_delivery_detail_id => l_dummy_detail_id,
 					x_dd_txn_id => l_dd_txn_id,
 					x_return_status =>l_txn_return_status
 					);

 		IF (l_txn_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
 			 x_return_status := l_txn_return_status;
 			 return;
 		END IF;
 	--DBI Api
	--Raise Event : Pick To Pod Workflow
	  WSH_WF_STD.Raise_Event(
							p_entity_type => 'LINE',
							p_entity_id => l_dummy_detail_id ,
							p_event => 'oracle.apps.wsh.line.gen.releasedtowarehouse' ,
							p_organization_id => l_organization_id,
							x_return_status => l_wf_rs ) ;
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.log(l_module_name,'Current Time is ',SYSDATE);
	     wsh_debug_sv.log(l_module_name,'Return Status After Calling WSH_WF_STD.Raise_Event',l_wf_rs);
	 END IF;

	OPEN c_get_picked_lines_count( l_dummy_detail_id );
	FETCH c_get_picked_lines_count into l_count_picked_lines, l_delv_id ;
	IF (c_get_picked_lines_count%FOUND) THEN
		IF ( l_count_picked_lines=1) THEN --If it is the first line in a delivery to be released
		  WSH_WF_STD.Raise_Event(
								p_entity_type => 'DELIVERY',
								p_entity_id => l_delv_id ,
								p_event => 'oracle.apps.wsh.delivery.pik.pickinitiated' ,
								p_organization_id => l_organization_id,
								x_return_status => l_wf_rs ) ;
			 IF l_debug_on THEN
			     WSH_DEBUG_SV.log(l_module_name,'Current Time is ',SYSDATE);
			     WSH_DEBUG_SV.log(l_module_name,'Return Status After Calling WSH_WF_STD.Raise_Event',l_wf_rs);
			 END IF;
		END IF;
	END IF;
       CLOSE c_get_picked_lines_count;

	--Done Raise Event : Pick To Pod Workflow

      END IF;
      --
      -- DBI Project
      -- Update of wsh_delivery_details where requested_quantity
      -- are changed, call DBI API after the update.
      -- DBI API checks for DBI Installed also
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Detail id-',l_dummy_detail_id);
      END IF;
      l_detail_tab(1) := l_dummy_detail_id;
      WSH_INTEGRATION.DBI_Update_Detail_Log
        (p_delivery_detail_id_tab => l_detail_tab,
         p_dml_type               => 'UPDATE',
         x_return_status          => l_dbi_rs);

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
      END IF;
      -- DBI API can only raise unexpected error, in that case need to
      -- pass it to the caller API for roll back of the whole transaction
      -- Only need to handle Unexpected error, rest are treated as success
      -- Since code is not proceeding, no need to reset x_return_status
      IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
         x_return_status := l_dbi_rs;
        IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        RETURN;
      END IF;

      -- End of Code for DBI Project
      --
      --bug# 6689448 (replenishment project): begin
      -- In dynamic replenishment case, WMS passes the action flag as 'R' and replenishment quantity in cycle_count_quantity attribute.
      ELSIF (p_changed_attributes(l_Counter).action_flag =  'R' )  THEN
      --{
 	       IF l_debug_on THEN
		       WSH_DEBUG_SV.logmsg(l_module_name,  'CYCLE_COUNT_QUANTITY = ' || P_CHANGED_ATTRIBUTES ( L_COUNTER ) .CYCLE_COUNT_QUANTITY  );
		       WSH_DEBUG_SV.logmsg(l_module_name,  'L_REQUEST_ID = ' || L_REQUEST_ID  );

		   END IF;

		   l_split_quantity  := p_Changed_attributes(l_Counter).cycle_count_quantity;
		   l_split_quantity2 := p_Changed_attributes(l_Counter).cycle_count_quantity2;
		   IF l_split_quantity2 = FND_API.G_MISS_NUM THEN
			 l_split_quantity2 := NULL;
		   END IF;

		   IF (l_split_quantity < old_Delivery_detail_rec.requested_quantity) THEN
			  --
			  -- Debug Statements
			  --
			  IF l_debug_on THEN
			      WSH_DEBUG_SV.logmsg(l_module_name, 'SPLIT_DELIVERY_DETAILS BEING CALLED WITH ' || TO_CHAR ( L_SPLIT_QUANTITY )  );
			  END IF;
			  --
			  WSH_DELIVERY_DETAILS_ACTIONS.Split_Delivery_Details(
						p_from_detail_id   => p_Changed_attributes(l_counter).delivery_detail_id,
						p_req_quantity	 => l_split_quantity,
						x_new_detail_id	=> l_dummy_detail_id,
						x_return_status	=> l_return_status,
						p_req_quantity2	=> l_split_quantity2,
						p_manual_split	 => 'B');
			  IF l_debug_on THEN
			      WSH_DEBUG_SV.log(l_module_name,'Split_Delivery_Details l_return_status',l_return_status);
                  WSH_DEBUG_SV.log(l_module_name,'Split_Delivery_Details is ',l_dummy_detail_id);
			  END IF;

			  IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
				 x_return_status := l_return_status;
                                 return;
			  END IF;

		   ELSE
			  l_dummy_detail_id :=  p_Changed_attributes(l_counter).delivery_detail_id ;
		   END IF ;
            -- Added Call backorder API to unassign/unpack delivery detail
            --
            -- Debug Statements
            --
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_USA_INV_PVT.   BACKORDERED_DELIVERY_DETAIL' ,WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           --
           backorder_delivery_detail(
                                              p_delivery_detail_id   =>  l_dummy_detail_id ,
                                              p_requested_quantity   =>  NULL,
                                              p_requested_quantity2  =>  NULL,
                                              p_planned_flag         =>  l_planned_flag,
                                              p_wms_enabled_flag     =>  l_wms_enabled_flag,
                                              p_replenishment_status   =>  'R',
                                              p_del_batch_id         =>  l_del_batch_id,
                                              x_split_quantity       =>  l_split_quantity,
                                              x_return_status        =>  l_return_status
                                            );
           IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
               x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           END IF;
           GOTO loop_end;

		 -- if action_flag = 'R'
     --bug# 6689448 (replenishment project): end
    ELSIF (p_changed_attributes(l_Counter).action_flag =  'B' )  THEN
    -- Setting Backorder Flag as TRUE so that request ends with Warning
    WSH_PICK_LIST.G_BACKORDERED := TRUE;
          --BUG#:1549665 hwahdani log exception if running from conc. request
    -- and action is backorder
    l_request_id := fnd_global.conc_request_id;
    -- 1729516
    IF ( l_request_id <> -1 OR
       p_changed_attributes(l_Counter).cycle_count_quantity = FND_API.G_MISS_NUM OR
       WSH_PICK_LIST.G_BATCH_ID IS NOT NULL ) THEN
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,  'CYCLE_COUNT_QUANTITY = ' || P_CHANGED_ATTRIBUTES ( L_COUNTER ) .CYCLE_COUNT_QUANTITY  );
           WSH_DEBUG_SV.logmsg(l_module_name,  'L_REQUEST_ID = ' || L_REQUEST_ID  );
                 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_ITEM_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;

             l_item_name := WSH_UTIL_CORE.Get_Item_Name(old_delivery_detail_rec.inventory_item_id,old_delivery_detail_rec.organization_id);
                  IF (old_delivery_detail_rec.ship_set_id IS NOT NULL) OR
                     (old_delivery_detail_rec.top_model_line_id IS NOT NULL ) THEN

                     -- Line belongs to Ship Set / SMC
                     --
                     -- Debug Statements
                     --
                     IF l_debug_on THEN
                         WSH_DEBUG_SV.logmsg(l_module_name,  'CHECK FOR BACKORDER OF SHIP SET / SMC LINES'  );
                     END IF;
                     --
                     --
                     -- Debug Statements
                     --
                     IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,
          'SS ID = '
          || OLD_DELIVERY_DETAIL_REC.SHIP_SET_ID
          || ' , SMC ID = '
          || OLD_DELIVERY_DETAIL_REC.TOP_MODEL_LINE_ID
          || ' , G_SHIP_SET_ID = '
          || G_SHIP_SET_ID
          || ' , G_SHIP_MODEL_ID = '
          || G_SHIP_MODEL_ID  );
                     END IF;
                     --

                     -- Check if Ship Set is present, if not check for SMC ; Ship set takes precedence
                     IF old_delivery_detail_rec.ship_set_id IS NOT NULL AND
                        ( NVL(old_delivery_detail_rec.ship_set_id,0) <> NVL(g_ship_set_id,0) ) THEN

                       --
                       -- Debug Statements
                       --
                       IF l_debug_on THEN
                           WSH_DEBUG_SV.logmsg(l_module_name,  'SHIP SET IS DIFFERENT AND ASSIGNING BEFORE LOOP '  );
                       END IF;
                       --
                       g_ss_smc_found         := FALSE;
                       g_move_order_line_id   := NULL ;
                       g_delivery_detail_id   := NULL ;
                       g_ship_set_id          := NULL ;
                       g_ship_model_id        := NULL ;
                       g_backordered_item     := NULL ;
                       g_top_model_item       := NULL ;
                       g_ship_set_name        := NULL ;
                       l_backorder_cnt := WSH_INTEGRATION.G_BackorderRec_Tbl.FIRST;
                       WHILE l_backorder_cnt IS NOT NULL LOOP
                             --
                             -- Debug Statements
                             --
                             IF l_debug_on THEN
                                 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INTEGRATION.G_BACKORDERREC_TBL',WSH_DEBUG_SV.C_PROC_LEVEL);
                             END IF;
                             --
                             IF NVL(old_delivery_detail_rec.ship_set_id,0) =
                                NVL(WSH_INTEGRATION.G_BackorderRec_Tbl(l_backorder_cnt).ship_set_id,0) THEN
                                g_ss_smc_found         := TRUE;
                                --
                                IF l_debug_on THEN
                                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INTEGRATION.G_BACKORDERREC_TBL',WSH_DEBUG_SV.C_PROC_LEVEL);
                                END IF;
                                --
                                g_move_order_line_id   := WSH_INTEGRATION.G_BackorderRec_Tbl(l_backorder_cnt).move_order_line_id;
                                g_delivery_detail_id   := WSH_INTEGRATION.G_BackorderRec_Tbl(l_backorder_cnt).delivery_detail_id;
                                --
                                IF l_debug_on THEN
                                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INTEGRATION.G_BACKORDERREC_TBL',WSH_DEBUG_SV.C_PROC_LEVEL);
                                END IF;
                                --
                                g_ship_set_id          := WSH_INTEGRATION.G_BackorderRec_Tbl(l_backorder_cnt).ship_set_id;
                                g_ship_model_id        := NULL;
                                --
                                IF g_delivery_detail_id IS NOT NULL THEN
                                   SELECT inventory_item_id
                                   INTO   l_backordered_item_id
                                   FROM   wsh_delivery_details
                                   WHERE  delivery_detail_id = g_delivery_detail_id;
                                ELSIF g_move_order_line_id IS NOT NULL THEN
                                   SELECT inventory_item_id
                                   INTO   l_backordered_item_id
                                   FROM   wsh_delivery_details
                                   WHERE  move_order_line_id = g_move_order_line_id;
                                END IF;
                                IF g_ship_set_id IS NOT NULL THEN
                                   SELECT set_name
                                   INTO   g_ship_set_name
                                   FROM   oe_sets
                                   WHERE  set_id = g_ship_set_id
                                   AND    set_type = 'SHIP_SET';
                                END IF;

                                IF l_debug_on THEN
	                           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_ITEM_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
                                END IF;
                                --
                                g_backordered_item := WSH_UTIL_CORE.Get_Item_Name(l_backordered_item_id,old_delivery_detail_rec.organization_id);
                                --
                                --
                                IF l_debug_on THEN
                                    WSH_DEBUG_SV.logmsg(l_module_name,  'FOUND NEW G_MOVE_ORDER_LINE_ID = ' || G_MOVE_ORDER_LINE_ID ||
                                                             ' G_DELIVERY_DETAIL_ID = ' || G_DELIVERY_DETAIL_ID  );
                                END IF;
                                --
                                --
                                -- Debug Statements
                                --
                                IF l_debug_on THEN
                                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INTEGRATION.G_BACKORDERREC_TBL.DELETE',WSH_DEBUG_SV.C_PROC_LEVEL);
                                END IF;
                                --
                                WSH_INTEGRATION.G_BackorderRec_Tbl.DELETE(l_backorder_cnt);
                                EXIT;
                             END IF;
                             --
                             -- Debug Statements
                             --
                             IF l_debug_on THEN
                                 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INTEGRATION.G_BACKORDERREC_TBL.NEXT',WSH_DEBUG_SV.C_PROC_LEVEL);
                             END IF;
                             --
                             l_backorder_cnt := WSH_INTEGRATION.G_BackorderRec_Tbl.NEXT(l_backorder_cnt);
                       END LOOP;
                     ELSIF old_delivery_detail_rec.ship_set_id IS NULL AND
                        ( NVL(old_delivery_detail_rec.top_model_line_id,0) <> NVL(g_ship_model_id,0) ) THEN
                       --
                       -- Debug Statements
                       --
                       IF l_debug_on THEN
                           WSH_DEBUG_SV.logmsg(l_module_name,  'SHIP MODEL IS DIFFERENT AND ASSIGNING BEFORE LOOP '  );
                       END IF;
                       --
                       g_ss_smc_found         := FALSE;
                       g_move_order_line_id   := NULL ;
                       g_delivery_detail_id   := NULL ;
                       g_ship_set_id          := NULL ;
                       g_ship_model_id        := NULL ;
                       g_backordered_item     := NULL ;
                       g_top_model_item       := NULL ;
                       g_ship_set_name        := NULL ;
                       l_backorder_cnt := WSH_INTEGRATION.G_BackorderRec_Tbl.FIRST;
                       WHILE l_backorder_cnt IS NOT NULL LOOP
                             --
                             -- Debug Statements
                             --
                             IF l_debug_on THEN
                                 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INTEGRATION.G_BACKORDERREC_TBL',WSH_DEBUG_SV.C_PROC_LEVEL);
                             END IF;
                             --
                             IF NVL(old_delivery_detail_rec.top_model_line_id,0) =
                                NVL(WSH_INTEGRATION.G_BackorderRec_Tbl(l_backorder_cnt).ship_model_id,0) THEN
                                -- Consider Ship Model as Ship Set is not present
                                g_ss_smc_found         := TRUE;
                                --
                                -- Debug Statements
                                --
                                IF l_debug_on THEN
                                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INTEGRATION.G_BACKORDERREC_TBL',WSH_DEBUG_SV.C_PROC_LEVEL);
                                END IF;
                                --
                                g_move_order_line_id   := WSH_INTEGRATION.G_BackorderRec_Tbl(l_backorder_cnt).move_order_line_id;
                                g_delivery_detail_id   := WSH_INTEGRATION.G_BackorderRec_Tbl(l_backorder_cnt).delivery_detail_id;
                                g_ship_set_id          := NULL;

                                -- Debug Statements
                                --
                                IF l_debug_on THEN
                                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INTEGRATION.G_BACKORDERREC_TBL',WSH_DEBUG_SV.C_PROC_LEVEL);
                                    WSH_DEBUG_SV.logmsg(l_module_name,  'FOUND NEW G_MOVE_ORDER_LINE_ID = ' || G_MOVE_ORDER_LINE_ID ||
                                                             ' G_DELIVERY_DETAIL_ID = ' || G_DELIVERY_DETAIL_ID  );
                                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INTEGRATION.G_BACKORDERREC_TBL.DELETE',WSH_DEBUG_SV.C_PROC_LEVEL);
                                END IF;
                                --
                                g_ship_model_id        := WSH_INTEGRATION.G_BackorderRec_Tbl(l_backorder_cnt).ship_model_id;


                                IF g_delivery_detail_id IS NOT NULL THEN
                                   SELECT inventory_item_id
                                   INTO   l_backordered_item_id
                                   FROM   wsh_delivery_details
                                   WHERE  delivery_detail_id = g_delivery_detail_id;
                                ELSIF g_move_order_line_id IS NOT NULL THEN
                                   SELECT inventory_item_id
                                   INTO   l_backordered_item_id
                                   FROM   wsh_delivery_details
                                   WHERE  move_order_line_id = g_move_order_line_id;
                                END IF;
                                IF g_ship_model_id IS NOT NULL THEN
                                   SELECT inventory_item_id
                                   INTO   l_top_model_item_id
                                   FROM   oe_order_lines_all
                                   WHERE  line_id = g_ship_model_id;
                                END IF;
                                --
                                IF l_debug_on THEN
	                           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_ITEM_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
                                END IF;
                                --
                                g_backordered_item := WSH_UTIL_CORE.Get_Item_Name(l_backordered_item_id,old_delivery_detail_rec.organization_id);
                                --
                             g_top_model_item := WSH_UTIL_CORE.Get_Item_Name(l_top_model_item_id,old_delivery_detail_rec.organization_id);
                                --
                             WSH_INTEGRATION.G_BackorderRec_Tbl.DELETE(l_backorder_cnt);
                             EXIT;
                          END IF;
			     --
                             -- Debug Statements
                             --
                             IF l_debug_on THEN
                                 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INTEGRATION.G_BACKORDERREC_TBL.NEXT',WSH_DEBUG_SV.C_PROC_LEVEL);
                             END IF;
                             --
                             l_backorder_cnt := WSH_INTEGRATION.G_BackorderRec_Tbl.NEXT(l_backorder_cnt);
                       END LOOP;
                     END IF;

                     --
                     -- Debug Statements
                     --
                     IF l_debug_on THEN
                         WSH_DEBUG_SV.logmsg(l_module_name,  'BEFORE LOGGING EXCEPTION , G_MOVE_ORDER_LINE_ID = ' || G_MOVE_ORDER_LINE_ID ||
                                                             ' G_DELIVERY_DETAIL_ID = ' || G_DELIVERY_DETAIL_ID  );
                     END IF;
                     --


                     IF ( g_ss_smc_found = TRUE ) AND
                        ( ( old_delivery_detail_rec.move_order_line_id <> NVL(g_move_order_line_id,0) ) OR
                          ( old_delivery_detail_rec.delivery_detail_id <> NVL(g_delivery_detail_id,0) )) THEN
                            --
                            -- Debug Statements
                            --
                            IF l_debug_on THEN
                                WSH_DEBUG_SV.logmsg(l_module_name,  'SHIPSET/SMC LINE GETTING BACKORDERED DUE TO ANOTHER LINE'  );
                            END IF;
                            --
                             IF g_ship_set_id IS NOT NULL THEN
                               FND_MESSAGE.SET_NAME('WSH','WSH_PR_OTHER_SS_FAILED');
                               FND_MESSAGE.SET_TOKEN('ITEM',l_item_name);
                               FND_MESSAGE.SET_TOKEN('SHIP_SET_NAME',g_ship_set_name);
                               FND_MESSAGE.SET_TOKEN('ORDER',old_delivery_detail_rec.source_header_number);
                               FND_MESSAGE.SET_TOKEN('BACKORDER_ITEM',g_backordered_item);
                            ELSE
                               FND_MESSAGE.SET_NAME('WSH','WSH_PR_OTHER_SMC_FAILED');
                               FND_MESSAGE.SET_TOKEN('ITEM',l_item_name);
                               FND_MESSAGE.SET_TOKEN('LINE',old_delivery_detail_rec.source_line_number);
                               FND_MESSAGE.SET_TOKEN('MODEL_ITEM',g_top_model_item);
                               FND_MESSAGE.SET_TOKEN('ORDER',old_delivery_detail_rec.source_header_number);
                               FND_MESSAGE.SET_TOKEN('BACKORDER_ITEM',g_backordered_item);
                            END IF;
                             l_msg:=FND_MESSAGE.GET;
                            --
                            -- Debug Statements
                            --
                            IF l_debug_on THEN
                                WSH_DEBUG_SV.logmsg(l_module_name,  L_MSG  );
                            END IF;
                            --
                            l_exception_location_id := old_delivery_detail_rec.ship_from_location_id;

                            Begin
                              wsh_xc_util.log_exception(
                                  p_api_version             => 1.0,
                                  x_return_status           => l_exception_return_status,
                                  x_msg_count               => l_exception_msg_count,
                                  x_msg_data                => l_exception_msg_data,
                                  x_exception_id            => l_dummy_exception_id ,
                                  p_logged_at_location_id   => l_exception_location_id,
                                  p_exception_location_id   => l_exception_location_id,
                                  p_logging_entity          => 'SHIPPER',
                                  p_logging_entity_id       => FND_GLOBAL.USER_ID,
                                  p_exception_name          => 'WSH_PICK_BACKORDER',
                                  p_message                 => l_msg ,
                                  p_error_message           => l_exception_error_message,
                                  p_request_id              => l_request_id,
                         -- 1729516
                                  p_batch_id                => WSH_PICK_LIST.G_BATCH_ID
                              );
                              IF l_debug_on THEN
                               WSH_DEBUG_SV.log(l_module_name,'log_exception l_exception_return_status',l_exception_return_status);
                              END IF;
                            Exception
                              when others  then
                                  --
                                  -- Debug Statements
                                  --
                                  IF l_debug_on THEN
                                      WSH_DEBUG_SV.logmsg(l_module_name, 'EXCEPTION RAISED BY LOG_EXCEPTION'  );
                                  END IF;
                                  --
                            End;
                            --
                            -- Debug Statements
                            --
                            IF l_debug_on THEN
                                WSH_DEBUG_SV.logmsg(l_module_name,  L_EXCEPTION_ERROR_MESSAGE  );
                            END IF;
                            --

                     ELSE
                            --
                            -- Debug Statements
                            --
                            IF l_debug_on THEN
                                WSH_DEBUG_SV.logmsg(l_module_name,  'SHIPSET/SMC LINE GETTING BACKORDERED DUE TO INSUFFICIENT QTY '  );
                            END IF;
                            --
                            FND_MESSAGE.SET_NAME('WSH','WSH_PICK_BACKORDER');
                            FND_MESSAGE.SET_TOKEN('QTY',p_Changed_attributes(l_Counter).cycle_count_quantity);
                            FND_MESSAGE.SET_TOKEN('ITEM',l_item_name);
                            FND_MESSAGE.SET_TOKEN('ORDER',old_delivery_detail_rec.source_header_number);
                            l_msg:=FND_MESSAGE.GET;
                            --
                            -- Debug Statements
                            --
                            IF l_debug_on THEN
                                WSH_DEBUG_SV.logmsg(l_module_name,  L_MSG  );
                            END IF;
                            --
                            l_exception_location_id := old_delivery_detail_rec.ship_from_location_id;

                            Begin
                                 wsh_xc_util.log_exception(
                                     p_api_version             => 1.0,
                                     x_return_status           => l_exception_return_status,
                                     x_msg_count               => l_exception_msg_count,
                                     x_msg_data                => l_exception_msg_data,
                                     x_exception_id            => l_dummy_exception_id ,
                                     p_logged_at_location_id   => l_exception_location_id,
                                     p_exception_location_id   => l_exception_location_id,
                                     p_logging_entity          => 'SHIPPER',
                                     p_logging_entity_id       => FND_GLOBAL.USER_ID,
                                     p_exception_name          => 'WSH_PICK_BACKORDER',
                                     p_message                 => l_msg ,
                                     p_error_message           => l_exception_error_message,
                                     p_inventory_item_id       => old_delivery_detail_rec.inventory_item_id,--Bug:1646466
                                     p_quantity                => p_changed_attributes(l_Counter).cycle_count_quantity,--Bug:1646466
                                     p_unit_of_measure         => old_delivery_detail_rec.requested_quantity_uom,--Bug:1646466
                                     p_request_id              => l_request_id,
                            -- 1729516
                                     p_batch_id                => WSH_PICK_LIST.G_BATCH_ID
                                    );
                                 IF l_debug_on THEN
                                     WSH_DEBUG_SV.log(l_module_name,'log_exception l_exception_return_status',l_exception_return_status);
                                 END IF;
                            Exception
                              when others  then
                                  --
                                  -- Debug Statements
                                  --
                                  IF l_debug_on THEN
                                      WSH_DEBUG_SV.logmsg(l_module_name, 'EXCEPTION RAISED BY LOG_EXCEPTION'  );
                                  END IF;
                                  --
                            End;
                            --
                            -- Debug Statements
                            --
                            IF l_debug_on THEN
                                WSH_DEBUG_SV.logmsg(l_module_name,  L_EXCEPTION_ERROR_MESSAGE  );
                            END IF;
                            --

                     END IF; -- End of Logging exceptions for Ship Sets / SMCs lines

                  ELSE
                     -- Exception logging for Normal Lines
                     --
                     -- Debug Statements
                     --
                     IF l_debug_on THEN
                         WSH_DEBUG_SV.logmsg(l_module_name,  'LOGGING EXCEPTIONS FOR NON SHIPSET/SMC LINES '  );
                     END IF;
                     --
                     FND_MESSAGE.SET_NAME('WSH','WSH_PICK_BACKORDER');
                     FND_MESSAGE.SET_TOKEN('QTY',p_Changed_attributes(l_Counter).cycle_count_quantity);
                     FND_MESSAGE.SET_TOKEN('ITEM',l_item_name);
                     FND_MESSAGE.SET_TOKEN('ORDER',old_delivery_detail_rec.source_header_number);
                     l_msg:=FND_MESSAGE.GET;
                     --
                     -- Debug Statements
                     --
                     IF l_debug_on THEN
                         WSH_DEBUG_SV.logmsg(l_module_name,  L_MSG  );
                     END IF;
                     --
                     l_exception_location_id := old_delivery_detail_rec.ship_from_location_id;

                     Begin

                       wsh_xc_util.log_exception(
                           p_api_version             => 1.0,
                           x_return_status           => l_exception_return_status,
                           x_msg_count               => l_exception_msg_count,
                           x_msg_data                => l_exception_msg_data,
                           x_exception_id            => l_dummy_exception_id ,
                           p_logged_at_location_id   => l_exception_location_id,
                           p_exception_location_id   => l_exception_location_id,
                           p_logging_entity          => 'SHIPPER',
                           p_logging_entity_id       => FND_GLOBAL.USER_ID,
                           p_exception_name          => 'WSH_PICK_BACKORDER',
                           p_message                 => l_msg ,
                           p_error_message           => l_exception_error_message,
                           p_inventory_item_id       => old_delivery_detail_rec.inventory_item_id,--Bug:1646466
                           p_quantity                => p_changed_attributes(l_Counter).cycle_count_quantity,--Bug:1646466
                           p_unit_of_measure         => old_delivery_detail_rec.requested_quantity_uom,--Bug:1646466
                           p_request_id              => l_request_id,
                  -- 1729516
                           p_batch_id                => WSH_PICK_LIST.G_BATCH_ID
                       );
                                 IF l_debug_on THEN
                                     WSH_DEBUG_SV.log(l_module_name,'log_exception l_exception_return_status',l_exception_return_status);
                                 END IF;
                    Exception
                       when others  then
                           --
                           -- Debug Statements
                           --
                           IF l_debug_on THEN
                               WSH_DEBUG_SV.logmsg(l_module_name, 'EXCEPTION RAISED BY LOG_EXCEPTION'  );
                           END IF;
                           --
                    End;
                    --
                    -- Debug Statements
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,  L_EXCEPTION_ERROR_MESSAGE  );
                    END IF;
                    --

                  END IF; -- End of check whether line belongs to Ship Set / SMC

       ELSE
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name, 'L_REQUEST_ID = -1 , NOT LOGGING EXCEPTION FOR BACKORDERING'  );
            END IF;
            --
       END IF;
       -- BUG#:1549665 hwahdani end of changes

       l_split_quantity  := p_Changed_attributes(l_Counter).cycle_count_quantity;
       l_split_quantity2 := p_Changed_attributes(l_Counter).cycle_count_quantity2;
       IF l_split_quantity2 = FND_API.G_MISS_NUM THEN
       l_split_quantity2 := NULL;
       END IF;

       -- Start of Consolidation Of BO DD's.

       l_cons_flag := 'N';
       -- Check the auto consolidation of back order lines only when current delivery detail id is
       -- not assigned to any planned delivery

       IF ( l_planned_flag = 'N' ) THEN
       --{
           --
           -- Debug Statements
           --
           IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIPPING_PARAMS_PVT. Get_Global_Parameters',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           --
           WSH_SHIPPING_PARAMS_PVT. Get_Global_Parameters(l_global_param_rec_type,l_return_status);
           --
           IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name, 'After calling Get_Global_Parameters: ' || l_return_status );
           END IF;
           --
           IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
               x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           END IF;
           l_auto_consolidate := l_global_param_rec_type.consolidate_bo_lines;
       END IF;   --}, l_planned_flag

       IF (l_split_quantity < old_Delivery_detail_rec.requested_quantity) THEN
       --{
	  IF ( l_auto_consolidate = 'Y') THEN   -- consolidate the split Quantity
	  --{
              --
              -- Debug Statements
              --
              IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name, 'WSH_DELIVERY_DETAILS_ACTIONS.CONSOLIDATE_SOURCE_LINE being called with Del Det Id: ',p_Changed_attributes(l_counter).delivery_detail_id);
              END IF;
              --
              l_Cons_Source_Line_Rec_Tab(1).delivery_detail_id:= old_Delivery_detail_rec.delivery_detail_id ;
              l_Cons_Source_Line_Rec_Tab(1).delivery_id:= null;
              l_Cons_Source_Line_Rec_Tab(1).source_line_id:=  old_Delivery_detail_rec.source_line_id;
              l_Cons_Source_Line_Rec_Tab(1).req_qty:= old_Delivery_detail_rec.requested_quantity ;
              l_Cons_Source_Line_Rec_Tab(1).bo_qty:= l_split_quantity;
-- HW OPM BUG#:3121616 added qty2s
              l_Cons_Source_Line_Rec_Tab(1).req_qty2:= old_Delivery_detail_rec.requested_quantity2 ;
              l_Cons_Source_Line_Rec_Tab(1).bo_qty2:= l_split_quantity2;
-- end of 3121616

              WSH_DELIVERY_DETAILS_ACTIONS.Consolidate_Source_Line(
                        p_Cons_Source_Line_Rec_Tab => l_Cons_Source_Line_Rec_Tab,
                        x_consolidate_ids     => l_cons_dd_ids,
                        x_return_status       => l_return_status);

              IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'After calling CONSOLIDATE_SOURCE_LINE: ',l_return_status);
              END IF;
              IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
              END IF;
                -- Checking consolidation is done or not

              IF ( l_cons_dd_ids(1) <> p_Changed_attributes(l_counter).delivery_detail_id ) THEN
                  l_cons_flag := 'Y';
                  IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name,'Consolidated partial Qty for the Del Det Id: ',old_Delivery_detail_rec.delivery_detail_id);
                  END IF;

                  l_dummy_detail_id := 0;
              ELSE
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'Consolidation not happened for the the Del Det Id: ',old_Delivery_detail_rec.delivery_detail_id);
                 END IF;
              END IF;
          END IF; --}, l_auto_consolidate

          -- If no consolidation for the partail quantity then Split the line
          IF ( l_cons_flag = 'N' ) THEN
          --{
              IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name, 'SPLIT_DELIVERY_DETAILS BEING CALLED WITH ' || TO_CHAR ( L_SPLIT_QUANTITY )  );
              END IF;
              --
              WSH_DELIVERY_DETAILS_ACTIONS.Split_Delivery_Details(
                         p_from_detail_id   => p_Changed_attributes(l_counter).delivery_detail_id,
                         p_req_quantity   => l_split_quantity,
                         x_new_detail_id => l_dummy_detail_id,
                         x_return_status => l_return_status,
                         p_req_quantity2 => l_split_quantity2,
                         p_manual_split   => p_changed_attributes(l_counter).action_flag);
              IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'Split_Delivery_Details l_return_status',l_return_status);
              END IF;

        -- Bug 3724578 : Return back to the caller if any error occures while
        --               splitting the delivery detail line
	-- Message will be set in  Split_Delivery_Details
	IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
		 x_return_status := l_return_status;
                 return;
	END IF;

	END IF;            --}, End of the Split Line

       ELSE                  -- No split, Complete back order case
          l_dummy_detail_id :=  p_Changed_attributes(l_counter).delivery_detail_id ;
       END IF ;  --},  l_split_quantity < old_Delivery_detail_rec.requested_quantity
       -- Now l_dummy_detail_id  contain any one value as follow
       -- 0            : means partial back order case and consolidation has happened for the partial quantity
       -- new dd id    : means which created when we call split delivery detail, It needs to be back order
       --Current dd id : means complete back order case
       -- If it is complete back order case then try to consolidate it
       IF ( l_auto_consolidate = 'Y' AND  l_dummy_detail_id = p_Changed_attributes(l_counter).delivery_detail_id) THEN
       --{
          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name, 'WSH_DELIVERY_DETAILS_ACTIONS.CONSOLIDATE_SOURCE_LINE being called with Del Det Id: ',old_Delivery_detail_rec.delivery_detail_id);
          END IF;
          l_Cons_Source_Line_Rec_Tab(1).delivery_detail_id:= old_Delivery_detail_rec.delivery_detail_id ;
          l_Cons_Source_Line_Rec_Tab(1).delivery_id:= null;
          l_Cons_Source_Line_Rec_Tab(1).source_line_id:=  old_Delivery_detail_rec.source_line_id;
          l_Cons_Source_Line_Rec_Tab(1).req_qty:= old_Delivery_detail_rec.requested_quantity ;
          l_Cons_Source_Line_Rec_Tab(1).bo_qty:=  old_Delivery_detail_rec.requested_quantity;
-- HW OPM BUG#:3121616 added qty2s
          l_Cons_Source_Line_Rec_Tab(1).req_qty2:= old_Delivery_detail_rec.requested_quantity2 ;
          l_Cons_Source_Line_Rec_Tab(1).bo_qty2:=  old_Delivery_detail_rec.requested_quantity2;
-- end of 3121616

          WSH_DELIVERY_DETAILS_ACTIONS.Consolidate_Source_Line(
              p_Cons_Source_Line_Rec_Tab   => l_Cons_Source_Line_Rec_Tab,
              x_consolidate_ids       => l_cons_dd_ids,
              x_return_status         => l_return_status);

           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'After calling CONSOLIDATE_SOURCE_LINE: ',l_return_status);
           END IF;

           IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
               x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           END IF;

           IF ( l_cons_dd_ids(1) <> p_Changed_attributes(l_counter).delivery_detail_id ) THEN
               l_cons_flag := 'Y';
               IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'Consolidated the Del Det Id: ',old_Delivery_detail_rec.delivery_detail_id);
               END IF;
           ELSE
              IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'Consolidation not happened for the the Del Det Id: ',old_Delivery_detail_rec.delivery_detail_id);
              END IF;
           END IF;

       END IF; --}, End of consolidation for the complete back order case

       --  Back Order the Delivery Detail which is created after split(Partial back order case)
       --       OR  current delivery in the case of complete back order case (if consolidation done it should not back order the line)

      IF ( l_cons_flag = 'N' ) THEN

          /* Can this part be replaced with a call to wsh_ship_confirm_Actions2.backorder ??? */
          /* No because that API will immediately release the process lines to warehouse. */

                -- Mark line as deleted if requested_quantity is 0 (when line was formerly pending overpick).

                -- Bug 2573434 : Added Call backorder API to unassign/unpack delivery detail
                --
                -- Debug Statements
                --

          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'Calling program unit WSH_USA_INV_PVT.   BACKORDERED_DELIVERY_DETAIL' ,WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          --
                      backorder_delivery_detail(
                                              p_delivery_detail_id   =>  l_dummy_detail_id ,
                                              p_requested_quantity   =>  NULL,
                                              p_requested_quantity2  =>  NULL,
                                              p_planned_flag         =>  l_planned_flag,
                                              p_wms_enabled_flag     =>  l_wms_enabled_flag,
                                              p_del_batch_id         =>  l_del_batch_id,
                                              x_split_quantity       =>  l_split_quantity,
                                              x_return_status        =>  l_return_status
                                            );
                     IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                     END IF;


          IF l_split_quantity = 0 THEN
         -- delete the overpick line, not backorder it.
         l_delete_count := l_delete_count + 1;
         l_details_to_delete(l_delete_count) := l_dummy_detail_id;
          END IF;
       END IF; -- End of complete Back Order case.
                   --- END Of Consolidation of back order delivery details
                   -- Bug 1858936
       GOTO loop_end;

     END IF; -- if action_flag = 'B'

     -- If even on line is shipped, reject user's Update request
     IF (l_delivery_status = 'CO')  THEN
      l_ship_status := 'confirmed' ;
      l_reject_update := 'Y' ;
     ELSIF (l_delivery_status = 'CL') THEN
      l_ship_status := 'closed' ;
      l_reject_update := 'Y' ;
     ELSIF (l_delivery_status = 'IT') THEN
      l_ship_status := 'in-transit' ;
      l_reject_update := 'Y' ;
     END IF ;

     BEGIN
      SELECT parent_delivery_detail_id
      INTO   l_parent_detail_id
      FROM   wsh_delivery_assignments_v
      WHERE  delivery_detail_id = p_changed_attributes(l_Counter).delivery_detail_id
      AND parent_delivery_detail_id IS NOT NULL;

      SELECT container_name
      INTO   l_container_name
      FROM   wsh_delivery_details
      WHERE  delivery_detail_id = l_parent_detail_id;
     EXCEPTION
      WHEN no_data_found THEN
        l_parent_detail_id := NULL;
        l_container_name   := NULL;
     END;
     --
     -- LSP PROJECT : debug stmt
     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,  'TRANSFER LPN ID ' || p_changed_attributes(l_Counter).transfer_lpn_id);
     END IF;
     -- LSP PROJECT : end
     --

     IF (p_changed_attributes(l_Counter).transfer_lpn_id <> FND_API.G_MISS_NUM ) THEN

        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'UPDATE TRANSFER LPN ID'  );
        END IF;
        --

        IF ( l_reject_update = 'Y' )  THEN
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name, 'UPDATE REJECTED'  );
         END IF;
         --
         FND_MESSAGE.Set_Name('WSH', 'WSH_REJECT_UPDATE_REQUEST');
         FND_MESSAGE.Set_Token('SHIP_STATUS', l_ship_status);
         FND_MESSAGE.Set_Token('UPDATE_ATTRIBUTE', 'transfer lpn id');
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
        ELSE
         IF (l_parent_detail_id IS NOT NULL) THEN

          l_msg := NULL;
          FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_PACKING');
          l_msg := FND_MESSAGE.GET;
          l_exception_location_id := old_delivery_detail_rec.ship_from_location_id;

          --
          wsh_xc_util.log_exception(
              p_api_version      => 1.0,
              x_return_status      => l_exception_return_status,
              x_msg_count        => l_exception_msg_count,
              x_msg_data        => l_exception_msg_data,
              x_exception_id      => l_dummy_exception_id ,
              p_logged_at_location_id   => l_exception_location_id,
              p_exception_location_id   => l_exception_location_id,
              p_logging_entity      => 'SHIPPER',
              p_logging_entity_id    => FND_GLOBAL.USER_ID,
              p_exception_name      => 'WSH_INVALID_PACKING',
              p_message        => l_msg,
              p_delivery_detail_id    => old_delivery_detail_rec.delivery_detail_id,
              p_subinventory      => p_changed_attributes(l_Counter).transfer_lpn_id,
              p_container_name      => l_container_name,
              p_inventory_item_id    => old_delivery_detail_rec.inventory_item_id,
              p_error_message      => l_exception_error_message
              );
          IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'log_exception l_exception_return_status',l_exception_return_status);
          END IF;
          IF (l_exception_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
             --
             -- Debug Statements
             --
             IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,  'WSH_XC_UTIL.LOG_EXCEPTION PROCEDURE FAILED TO LOG EXCEPTION'  );
                 WSH_DEBUG_SV.logmsg(l_module_name,  L_EXCEPTION_ERROR_MESSAGE  );
             END IF;
          END IF;


         ELSE
         -- First get the details of the license_plate_number
         -- that is to be updated.
           --
           -- Debug Statements
           --
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'FETCHING LPN DETAILS'  );
           END IF;
           --

       -- K LPN CONV. rvishnuv
       /*
       SELECT license_plate_number ,
              inventory_item_id ,
              organization_id
           INTO   l_cont_name ,
              l_cont_item_id  ,
              l_organization_id
           FROM   wms_license_plate_numbers
           WHERE  lpn_id = p_Changed_Attributes(l_Counter).transfer_lpn_id ;
       */
       -- K LPN CONV. rvishnuv

         -- Before Updating transfer_lpn_id , check if this lpn_id already
         -- exists

       SELECT count(*)
           INTO   l_num_containers
       FROM   wsh_delivery_Details
       WHERE  lpn_id  = p_Changed_Attributes(l_Counter).transfer_lpn_id
       AND  container_flag  = 'Y'
       AND  delivery_detail_id <>  p_changed_attributes(l_Counter).delivery_detail_id
       AND  nvl(line_direction , 'O') IN ('O', 'IO')  -- J-IB-JCKWOK
       --LPN reuse project
       AND released_status = 'X'
       AND  rownum = 1 ;

           --
           -- Debug Statements
           --
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, TO_CHAR ( L_NUM_CONTAINERS ) || ' CONTAINER DELIVERY DETAILS FETCHED'  );
           END IF;
           --

       IF ( l_num_containers = 0 ) then--{
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'CREATING CONTAINER WITH LPN '  );
         END IF;
         --
         -- Create container as it does not exist.
         -- K LPN CONV. rvishnuv
         WSH_CONTAINER_ACTIONS.Create_Cont_Instance_Multi(
              x_cont_name           => l_cont_name,
              p_cont_item_id        => NULL,
              x_cont_instance_id    => l_cont_instance_id,
              p_par_detail_id       => NULL,
              p_organization_id     => NULL,
              p_container_type_code => NULL,
              p_num_of_containers   => 1,
              x_row_id              => l_row_id,
              x_return_status       => l_return_status,
              x_cont_tab            => l_cont_tab,
              x_unit_weight         => l_lpn_unit_weight,
              x_unit_volume         => l_lpn_unit_volume,
              x_weight_uom_code     => l_lpn_weight_uom_code,
              x_volume_uom_code     => l_lpn_volume_uom_code,
              p_lpn_id              => p_Changed_Attributes(l_Counter).transfer_lpn_id,
              p_ignore_for_planning => old_delivery_detail_rec.ignore_for_planning,
              p_caller              => l_create_cnt_caller);

         IF (l_cont_tab.count = 0) THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           --
           -- Debug Statements
           --
           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name, 'NO CONTAINERS WERE CREATED THROUGH CREATE_CONT_INSTANCE_MULTI'  );
             WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           --
           RETURN;
           --
         END IF;

         l_cont_instance_id := l_cont_tab(1);

         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Create_Cont_Instance_Multi l_return_status',l_return_status);
         END IF;

         IF (l_return_status NOT IN (WSH_UTIL_CORE.G_RET_STS_SUCCESS,
                                     WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
           x_return_status := l_return_status;
           IF l_debug_on THEN
             WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           RETURN; -- bug 3703648: should return immediately to avoid spurious messages created by subsequent calls
         END IF ;
         -- K LPN CONV. rvishnuv
         --

       ELSE
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'FETCHING DELIVERY DETAIL OF CONTAINER WITH LPN'  );
         END IF;
         --
         -- Bug 4093619(FP-4145867): Modified following query to fetch delivery grouping
         -- attributes of container record
         SELECT delivery_Detail_id, customer_id ,
                ship_to_location_id, intmed_ship_to_location_id,
                deliver_to_location_id, fob_code,
                freight_terms_code, ship_method_code,
                nvl(line_direction,'O'),
                nvl(ignore_for_planning, 'N'),
                shipping_control,
                carrier_id,
                service_level,
                mode_of_transport,
                client_id -- LSP PROJECT
         INTO   l_cont_instance_id, l_customer_id,
                l_ship_to_location_id, l_intmed_ship_to_location_id,
                l_deliver_to_location_id, l_fob_code,
                l_freight_terms_code, l_ship_method_code,
                l_line_direction, l_ignore_for_planning,
                l_shipping_control, l_carrier_id,
                l_service_level, l_mode_of_transport,l_client_id -- LSP PROJECT
         FROM   wsh_Delivery_Details
         WHERE  lpn_id = p_changed_attributes(l_Counter).transfer_lpn_id
           AND  container_flag = 'Y'
           --LPN reuse project
           AND released_status = 'X'
           AND  nvl(line_direction , 'O') IN ('O', 'IO'); -- J-IB-JCKWOK

         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name, 'l_cont_instance_id', l_cont_instance_id);
           WSH_DEBUG_SV.log(l_module_name, 'l_customer_id', l_customer_id);
           WSH_DEBUG_SV.log(l_module_name, 'l_ship_to_location_id', l_ship_to_location_id);
           WSH_DEBUG_SV.log(l_module_name, 'l_intmed_ship_to_location_id', l_intmed_ship_to_location_id);
           WSH_DEBUG_SV.log(l_module_name, 'l_deliver_to_location_id', l_deliver_to_location_id);
           WSH_DEBUG_SV.log(l_module_name, 'l_fob_code', l_fob_code);
           WSH_DEBUG_SV.log(l_module_name, 'l_freight_terms_code', l_freight_terms_code);
           WSH_DEBUG_SV.log(l_module_name, 'l_ship_method_code', l_ship_method_code);
           WSH_DEBUG_SV.log(l_module_name, 'l_line_direction', l_line_direction);
           WSH_DEBUG_SV.log(l_module_name, 'l_ignore_for_planning', l_ignore_for_planning);
           WSH_DEBUG_SV.log(l_module_name, 'l_shipping_control', l_shipping_control);
           WSH_DEBUG_SV.log(l_module_name, 'l_carrier_id', l_carrier_id);
           WSH_DEBUG_SV.log(l_module_name, 'l_service_level', l_service_level);
           WSH_DEBUG_SV.log(l_module_name, 'l_mode_of_transport', l_mode_of_transport);
           WSH_DEBUG_SV.log(l_module_name, 'l_client_id', l_client_id); -- LSP PROJECT
         END IF;
         -- End of Bug 4093619(FP-4145867)

       END IF ;--}

       --
       -- LPN CONV rv
       WSH_WMS_LPN_GRP.g_caller := 'WMS';
       WSH_WMS_LPN_GRP.g_callback_required := 'N';
       -- LPN CONV rv
       --
       WSH_DELIVERY_DETAILS_ACTIONS.Assign_Detail_To_Cont (
               p_changed_attributes(l_Counter).delivery_detail_id,
               l_cont_instance_id,
               l_return_status);
       IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Assign_Detail_To_Cont l_return_status',l_return_status);

       END IF;
       --
       -- LPN CONV rv

       IF (nvl(l_num_containers,0) > 0 ) THEN
       --{

           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Updating the master serial number of the container onto the line');
           END IF;

           UPDATE WSH_DELIVERY_DETAILS
           SET master_serial_number = (select master_serial_number
                                       from wsh_delivery_details
                                       where delivery_detail_id = l_cont_instance_id
                                       and container_flag = 'Y')
           WHERE delivery_detail_id = p_changed_attributes(l_Counter).delivery_detail_id;

       --}
       END IF;

       WSH_WMS_LPN_GRP.g_caller := l_original_caller;
       WSH_WMS_LPN_GRP.g_callback_required := l_orig_callback_reqd;
       -- LPN CONV rv
       --
       IF (l_return_status NOT IN (WSH_UTIL_CORE.G_RET_STS_SUCCESS,
                        WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
          x_return_status := l_return_status;
          RETURN;
      END IF ;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'calling Calculate TP Dates for entity LPN'  );
      END IF;
      --Modified Entity_Type and Entity_ids for bug 5234326
      l_cont_tab(1) := l_cont_instance_id;
      WSH_TP_RELEASE.calculate_cont_del_tpdates(
            p_entity        => 'LPN',
            p_entity_ids    => l_cnt_tab,
            x_return_status => l_return_status);

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'calculate_cont_del_tpdates l_return_status',l_return_status);
      END IF;

      IF (l_return_status NOT IN (WSH_UTIL_CORE.G_RET_STS_SUCCESS,
                      WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
         x_return_status := l_return_status;
        RETURN;
      END IF ;

      -- Bug 4093619(FP-4145867) : Added the condition below so that container
      -- hierarchy's delivery grouping attribute is not updated if it is same.
      IF  ( nvl(old_delivery_detail_rec.customer_id, -1)                <> nvl(l_customer_id, '-1')
        OR  nvl(old_delivery_detail_rec.ship_to_location_id, -1)        <> nvl(l_ship_to_location_id, '-1')
        OR  nvl(old_delivery_detail_rec.intmed_ship_to_location_id, -1) <> nvl(l_intmed_ship_to_location_id, '-1')
        OR  nvl(old_delivery_detail_rec.deliver_to_location_id, -1)     <> nvl(l_deliver_to_location_id, '-1')
        OR  nvl(old_delivery_detail_rec.fob_code, '-1')                 <> nvl(l_fob_code, '-1')
        OR  nvl(old_delivery_detail_rec.freight_terms_code, '-1')       <> nvl(l_freight_terms_code, '-1')
        OR  nvl(old_delivery_detail_rec.ship_method_code, '-1')         <> nvl(l_ship_method_code, '-1')
        OR  nvl(old_delivery_detail_rec.line_direction, 'O')            <> nvl(l_line_direction, 'O')
        OR  nvl(old_delivery_detail_rec.ignore_for_planning, 'N')       <> nvl(l_ignore_for_planning, 'N')
        OR  nvl(old_delivery_detail_rec.shipping_control, 'N')          <> nvl(l_shipping_control, 'N')
        OR  nvl(old_delivery_detail_rec.carrier_id, -1)                 <> nvl(l_carrier_id, -1)
        OR  nvl(old_delivery_detail_rec.service_level, '-1')            <> nvl(l_service_level, '-1')
        OR  nvl(old_delivery_detail_rec.mode_of_transport, '-1')        <> nvl(l_mode_of_transport, '-1')
        OR  nvl(old_delivery_detail_rec.client_id, '-1')                <> nvl(l_client_id, '-1')) -- LSP PROJECT)
        THEN --{

        -- Bug 2706103 - Reused container should be updated with grouping attributes
        -- code fix per WMS issue where grouping attributes were not updated for a reused container.
        -- IF (l_num_containers = 0) THEN
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'Calling Update_Cont_Hierarchy as Grouping attributes do not match');
        END IF;
        WSH_CONTAINER_ACTIONS.Update_Cont_Hierarchy (
             p_changed_attributes(l_Counter).delivery_detail_id,
             NULL,
             l_cont_instance_id,
             l_return_status);
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Update_Cont_Hierarchy l_return_status',l_return_status);
        END IF;

        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
          FND_MESSAGE.SET_NAME('WSH','WSH_CONT_UPD_ATTR_ERROR');
          FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
          WSH_UTIL_CORE.Add_Message(l_return_status,l_module_name);
          x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        END IF;

      END IF;--}

           -- END IF;
           -- end bug 1663149: update shipping attributes in the new container record
         END IF; -- End of if detail is packed
        END IF;  -- End of if reject_update
     END IF;  -- End of if transfer_lpn_id

   -- HW OPMCONV. Removed OPM specific logic
     IF (p_changed_attributes(l_counter).subinventory <> FND_API.G_MISS_CHAR  AND
     (NVL(old_delivery_detail_rec.subinventory,'-99') <> NVL(p_changed_attributes(l_Counter).subinventory,'-99'))) THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'UPDATE INVENTORY'  );
      END IF;
      --
      IF ( l_reject_update = 'Y' )  THEN
         FND_MESSAGE.Set_Name('WSH', 'WSH_REJECT_UPDATE_REQUEST');
         FND_MESSAGE.Set_Token('SHIP_STATUS', l_ship_status);
         FND_MESSAGE.Set_Token('UPDATE_ATTRIBUTE', 'subinventory');
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
      ELSE
                           -- bug 2302693: we do not log an exception if the line is packed
                           -- and its subinventory was not null before pick confirm.
                           -- The reason is that the item is being moved from a source subinventory
                           -- to a stage subinventory.
                           --   To see the original code, please look at revision 115.17.
               l_update_sub := 'Y';
      END IF;  -- End of if shipped_details >= 1
     END IF;  -- End of if subinventory

    -- HW OPMCONV. Removed OPM specific logic
     IF (p_changed_attributes(l_counter).locator_id <> FND_API.G_MISS_NUM  AND
        (NVL(old_delivery_detail_rec.locator_id,-99) <> NVL(p_changed_attributes(l_Counter).locator_id,-99))) THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'UPDATE LOCATOR'  );
      END IF;
      --
      IF (l_reject_update = 'Y')  THEN
         -- At least one line is shipped, reject user's request
         l_ship_status := 'confirmed, in-transit or closed';
         FND_MESSAGE.Set_Name('WSH', 'WSH_REJECT_UPDATE_REQUEST');
         FND_MESSAGE.Set_Token('SHIP_STATUS', l_ship_status);
         FND_MESSAGE.Set_Token('UPDATE_ATTRIBUTE', 'locator_id');
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
      ELSE
                           -- bug 2302693: we do not log an exception if the line is packed
                           -- and its inventory control was not null before pick confirm.
                           -- The reason is that before pick confirm, we assume packing is planned.
                           --   To see the original code, please look at revision 115.17.
         l_update_loc := 'Y';
      END IF;  -- End of if shipped_details >= 1
     END IF;  -- End of if locator_id

     IF (p_changed_attributes(l_counter).revision <> FND_API.G_MISS_CHAR  AND
       (NVL(old_delivery_detail_rec.revision,'-99') <> NVL(p_changed_attributes(l_Counter).revision,'-99'))) THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'UPDATE REVISION'  );
      END IF;
      --
      IF (l_reject_update = 'Y')  THEN
        -- At least one line is shipped, reject user's request
        l_ship_status := 'confirmed, in-transit or closed';
        FND_MESSAGE.Set_Name('WSH', 'WSH_REJECT_UPDATE_REQUEST');
        FND_MESSAGE.Set_Token('SHIP_STATUS', l_ship_status);
        FND_MESSAGE.Set_Token('UPDATE_ATTRIBUTE', 'revision');
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
      ELSE
                           -- bug 2302693: we do not log an exception if the line is packed
                           -- and its inventory control was not null before pick confirm.
                           -- The reason is that before pick confirm, we assume packing is planned.
                           --   To see the original code, please look at revision 115.17.
         l_update_rev := 'Y';
      END IF;  -- End of if shipped_details >= 1
     END IF;  -- End of if revision

     -- odaboval : Begin of OPM Changes (Pick_Confirm)
-- HW OPMCONV - Removed sublot code

     --  IF (p_changed_attributes(l_counter).lot_number <> FND_API.G_MISS_CHAR  AND
     --  ((NVL(old_delivery_detail_rec.lot_number,'-99') <> NVL(p_changed_attributes(l_Counter).lot_number,'-99')))) THEN
                             --bug 6675904  changed if condition as Inv allows any value for lot number so -99 was
                             --not getting updated in WDD
     IF ( ( ( old_delivery_detail_rec.lot_number IS NULL AND p_changed_attributes(l_Counter).lot_number IS NOT NULL ) OR
           ( old_delivery_detail_rec.lot_number IS NOT NULL AND p_changed_attributes(l_Counter).lot_number IS NULL ) OR
           ( old_delivery_detail_rec.lot_number IS NOT NULL AND p_changed_attributes(l_Counter).lot_number IS NOT NULL AND
             old_delivery_detail_rec.lot_number <> p_changed_attributes(l_Counter).lot_number )) and
             p_changed_attributes(l_counter).lot_number <> FND_API.G_MISS_CHAR) THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'UPDATE LOT NUMBER'  );
      END IF;
      --
      IF (l_reject_update = 'Y')  THEN
         -- At least one line is shipped, reject user's request
         l_ship_status := 'confirmed, in-transit or closed';
         FND_MESSAGE.Set_Name('WSH', 'WSH_REJECT_UPDATE_REQUEST');
         FND_MESSAGE.Set_Token('SHIP_STATUS', l_ship_status);
         FND_MESSAGE.Set_Token('UPDATE_ATTRIBUTE', 'lot_number');
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
      ELSE
                           -- bug 2302693: we do not log an exception if the line is packed
                           -- and its inventory control was not null before pick confirm.
                           -- The reason is that before pick confirm, we assume packing is planned.
                           --   To see the original code, please look at revision 115.17.
         l_update_lot := 'Y';
      END IF;  -- End of if shipped_details >= 1
     END IF;  -- End of if lot_number


     -- Hverddin 12-SEP-200 Start of OPM changes For Grade
     -- NOTE LOG EXCEPTIONS PUT VALUE INTO LOT_NUMBER UNTIL RESOLVED
     IF (p_changed_attributes(l_counter).preferred_grade <> FND_API.G_MISS_CHAR  AND
       (NVL(old_delivery_detail_rec.preferred_grade,'-99') <> NVL(p_changed_attributes(l_Counter).preferred_grade,'-99'))) THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'PREFERRED GRADE'  );
      END IF;
      --
      IF (l_reject_update = 'Y')  THEN
         -- At least one line is shipped, reject user's request
         l_ship_status := 'confirmed, in-transit or closed';
         FND_MESSAGE.Set_Name('WSH', 'WSH_REJECT_UPDATE_REQUEST');
         FND_MESSAGE.Set_Token('SHIP_STATUS', l_ship_status);
         FND_MESSAGE.Set_Token('UPDATE_ATTRIBUTE', 'preferred_grade');
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
      ELSE
                           -- bug 2302693: we do not log an exception if the line is packed
                           -- and its inventory control was not null before pick confirm.
                           -- The reason is that before pick confirm, we assume packing is planned.
                           --   To see the original code, please look at revision 115.17.
               l_update_preferred_grade := 'Y';
      END IF;  -- End of if shipped_details >= 1
     END IF;  -- End of if preferred_grade
     -- Hverddin 12-SEP-200 End of OPM changes For Grade

                 -- Bug 2657652 : Added transaction_temp_id
                 IF (l_transaction_temp_id <> FND_API.G_MISS_NUM  AND
                    (NVL(old_delivery_detail_rec.transaction_temp_id,-99) <> NVL(l_transaction_temp_id,-99))) THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'UPDATE TRANSACTION TEMP ID with transaction_temp_id :'||
                                                               l_transaction_temp_id ||
                                                               ', picked_quantity :'||
                                                               p_changed_attributes(l_Counter).picked_quantity );
      END IF;
      --
                        IF (l_reject_update = 'Y')  THEN
                          -- At least one line is shipped, reject user's request
                          l_ship_status := 'confirmed, in-transit or closed';
                          FND_MESSAGE.Set_Name('WSH', 'WSH_REJECT_UPDATE_REQUEST');
                          FND_MESSAGE.Set_Token('SHIP_STATUS', l_ship_status);
                          FND_MESSAGE.Set_Token('UPDATE_ATTRIBUTE', 'transaction_temp_id');
                          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                          WSH_UTIL_CORE.Add_Message(x_return_status);
                        ELSE
                          l_update_transaction_temp_id := 'Y';
                        END IF;  -- End of if l_reject_update = 'Y'
                 END IF;  -- End of if transaction_temp_id

     IF (p_changed_attributes(l_counter).serial_number <> FND_API.G_MISS_CHAR  AND
       (NVL(old_delivery_detail_rec.serial_number,'-99') <> NVL(p_changed_attributes(l_Counter).serial_number,'-99'))) THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'UPDATE SERIAL NUMBER'  );
      END IF;
      --
      IF (l_reject_update = 'Y')  THEN
         -- At least one line is shipped, reject user's request
         l_ship_status := 'confirmed, in-transit or closed';
         FND_MESSAGE.Set_Name('WSH', 'WSH_REJECT_UPDATE_REQUEST');
         FND_MESSAGE.Set_Token('SHIP_STATUS', l_ship_status);
         FND_MESSAGE.Set_Token('UPDATE_ATTRIBUTE', 'serial_number');
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
      ELSE
                           -- bug 2302693: we do not log an exception if the line is packed
                           -- and its inventory control was not null before pick confirm.
                           -- The reason is that before pick confirm, we assume packing is planned.
                           --   To see the original code, please look at revision 115.17.
               l_update_serial_number := 'Y';
      END IF;  -- End of if shipped_details >= 1
     END IF;  -- End of if serial_number

     IF (p_changed_attributes(l_counter).released_status <> FND_API.G_MISS_CHAR  AND
       NVL(old_delivery_detail_rec.released_status, 'N') <> NVL(p_changed_attributes(l_Counter).released_status, 'N')) THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'UPDATE RELEASED STATUS '  );
      END IF;
      --
      IF (l_reject_update = 'Y')  THEN
         -- At least one line is shipped, reject user's request
         l_ship_status := 'confirmed, in-transit or closed';
         FND_MESSAGE.Set_Name('WSH', 'WSH_REJECT_UPDATE_REQUEST');
         FND_MESSAGE.Set_Token('SHIP_STATUS', l_ship_status);
         FND_MESSAGE.Set_Token('UPDATE_ATTRIBUTE', 'released_status');
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
      ELSE
         l_update_rel_status := 'Y';

         -- start overpicking logic
         -- If we overpick, we want to update this delivery line's requested_quantity
         -- in order to minimize the overpicking.
         --
         -- When that happens, we call update_ordered_quantity in order to update
         -- other unstaged delivery lines so that the total requested quantity will
         -- still match the order line's ordered quantity.
         IF p_changed_attributes(l_counter).picked_quantity <> FND_API.G_MISS_NUM THEN

         DECLARE -- BLOCK for managing requested quantity changes
           CURSOR c_detail_info(x_delivery_detail_id IN NUMBER) IS
           SELECT source_line_id,
               source_code,
	       organization_id,     -- bug 7131800
               requested_quantity,
               requested_quantity2
	   FROM   wsh_delivery_details
           WHERE  delivery_detail_id = x_delivery_detail_id;

--HW OPM Rretrieve qty2 attributes
           CURSOR c_source_info(x_source_line_id IN NUMBER, x_source_code IN VARCHAR2) IS
          SELECT ordered_quantity,
               order_quantity_uom,
               ordered_quantity2,
               ordered_quantity_uom2
          FROM   oe_order_lines_all
          WHERE  line_id = x_source_line_id
          AND x_source_code = 'OE';

           l_detail_info     c_detail_info%ROWTYPE;
           l_source_info     c_source_info%ROWTYPE;
           l_max_quantity   NUMBER;
           l_avail_quantity NUMBER;
-- HW OPM added qty2 variables

           l_process_flag     VARCHAR2(1) :=FND_API.G_FALSE;
           l_max_quantity2    NUMBER;
           l_avail_quantity2  NUMBER;
           l_allowed_flag   VARCHAR2(1);
           l_rs       VARCHAR2(1);
           l_found       BOOLEAN := FALSE;
           --Bug 7131800
           l_ship_params   WSH_SHIPPING_PARAMS_PVT.Parameter_Rec_Typ;
           l_retain_nonstaged_dd_param VARCHAR2(1);
           l_ret_status   VARCHAR2(1);
           --Bug 7131800

         BEGIN
           OPEN  c_detail_info(p_changed_attributes(l_Counter).delivery_detail_id);
           FETCH c_detail_info INTO l_detail_info;
           l_found := c_detail_info%FOUND;
           CLOSE c_detail_info;

           -- make sure this is an overpick case
           IF  l_found
            AND (l_detail_info.requested_quantity
                < p_changed_attributes(l_counter).picked_quantity) THEN

             -- We call check_quantity_to_pick to get the available requested quantity
             -- that can be staged.

-- HW OPM added l_max_quantity2 and l_avail_quantity2 to the call
             --
             wsh_details_validations.check_quantity_to_pick(
                p_order_line_id   => l_detail_info.source_line_id,
                p_quantity_to_pick   => p_changed_attributes(l_counter).picked_quantity,
                p_quantity2_to_pick  => p_changed_attributes(l_counter).picked_quantity2,
                x_allowed_flag     => l_allowed_flag,
                x_max_quantity_allowed => l_max_quantity,
                x_max_quantity2_allowed => l_max_quantity2,
                x_avail_req_quantity   => l_avail_quantity,
                x_avail_req_quantity2   => l_avail_quantity2,
                x_return_status   => l_rs);
             IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'check_quantity_to_pick l_rs',l_rs);
--Bug 7131800
              WSH_DEBUG_SV.log(l_module_name,'l_detail_info.req.qty ', l_detail_info.requested_quantity);
 	            WSH_DEBUG_SV.log(l_module_name,'check_quantity_to_pick l_avail_qty ', l_avail_quantity);
 	            WSH_DEBUG_SV.log(l_module_name,'chgd.attr picked.qty ', p_changed_attributes(l_counter).picked_quantity);
 	            WSH_DEBUG_SV.log(l_module_name,'check_quantity_to_pick l_max_qty ', l_max_quantity);
--Bug 7131800
             END IF;

             IF l_rs = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
--Bug 7131800
                IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIPPING_PARAMS_PVT.GET',
                                        WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                wsh_shipping_params_pvt.get(
		                            p_organization_id => l_detail_info.organization_id,
		                            x_param_info      => l_ship_params,
		                            x_return_status   => l_ret_status);

	     IF l_debug_on THEN
		     WSH_DEBUG_SV.log(l_module_name,'wsh_shipping_params_pvt.get l_ret_status',l_ret_status);
		     WSH_DEBUG_SV.log(l_module_name,'l_ship_params.retain_nonstaged_det_flag',l_ship_params.retain_nonstaged_det_flag);
	     END IF;

     -- bug 7131800
      IF NOT INV_GMI_RSV_BRANCH.Process_Branch(p_organization_id => l_detail_info.organization_id) THEN
       l_process_flag := FND_API.G_FALSE;
      ELSE
       l_process_flag := FND_API.G_TRUE;
      END IF;

	      IF l_debug_on THEN
		     WSH_DEBUG_SV.log(l_module_name,'l_process_flag',l_process_flag);
              END IF;


                IF l_ret_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                  l_retain_nonstaged_dd_param := nvl(l_ship_params.retain_nonstaged_det_flag,'N');
                  IF ( l_process_flag = FND_API.G_FALSE AND l_retain_nonstaged_dd_param  = 'Y') THEN
			             l_new_req_quantity :=  l_detail_info.requested_quantity + (l_avail_quantity - LEAST(l_max_quantity -(p_changed_attributes(l_counter).picked_quantity - l_detail_info.requested_quantity), l_avail_quantity));
                  ELSE
                 	l_new_req_quantity := LEAST(p_changed_attributes(l_counter).picked_quantity,
			                           l_avail_quantity);
			            END IF;
-- HW added qty2 for OPM
                l_new_req_quantity2 := nvl(LEAST(p_changed_attributes(l_counter).picked_quantity2,l_avail_quantity2),0);
                ELSE
                    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		                l_new_req_quantity := NULL;
                    l_new_req_quantity2 := NULL;
                END IF;
--Bug 7131800
             ELSE
             x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
-- HW OPM added qty2
             l_new_req_quantity := NULL;
             l_new_req_quantity2 := NULL;

             END IF;
--Bug 7131800
             IF l_debug_on THEN
 	               WSH_DEBUG_SV.log(l_module_name,'l_new_req_qty ', l_new_req_quantity);
 	       END IF;
--Bug 7131800

-- HW OPM added condition OR
             IF l_new_req_quantity > l_detail_info.requested_quantity
               OR nvl(l_new_req_quantity2,0) > nvl(l_detail_info.requested_quantity2,0)THEN

             -- Because we will increase this newly staged delivery line's
             -- requested quantity to accomodate the picked quantity,
             -- we need to reduce excess requested quantity
             -- of unstaged delivery lines.

             OPEN  c_source_info(l_detail_info.source_line_id, l_detail_info.source_code);
             FETCH c_source_info INTO l_source_info;
             l_found := c_source_info%FOUND;
             CLOSE c_source_info;

             IF l_found THEN
               l_update_quantities := 'Y';
               l_source_code             := l_detail_info.source_code;
               l_overpick_rec.source_line_id     := l_detail_info.source_line_id;
               l_overpick_rec.ordered_quantity   := l_source_info.ordered_quantity;
               l_overpick_rec.order_quantity_uom   := l_source_info.order_quantity_uom;
-- HW OPM added qty2
               l_overpick_rec.ordered_quantity2  := l_source_info.ordered_quantity2;
               l_overpick_rec.ordered_quantity_uom2   := l_source_info.ordered_quantity_uom2;
             ELSE
               -- fail-safe mode: do not update requested_quantity or call update_ordered_quantity
               l_update_quantities := 'N';
               l_new_req_quantity := NULL;
-- HW OPM added qty2
               l_new_req_quantity2 := NULL;
             END IF;

             END IF; -- l_new_req_quantity > l_detail_info.requested_quantity
           END IF;  -- l_found AND requested_quantity <> picked_quantity

         END; -- BLOCK for managing requested quantity changes
         END IF;  -- p_changed_attributes(l_counter).picked_quantity <> FND_API.G_MISS_NUM
         -- end overpicking logic

      END IF;  -- End of if shipped_details >= 1
     END IF;  -- End of if released_status


                 -- Bug 2657652 : fail safe check
                 -- Shipping expects either transaction_temp_id or serial_number but not both
                 -- If transaction_temp_id is passed then quantity should be > 1
                 -- As per Bug 3764278, transaction temp id can be passed for quantity 1 as well since WMS can also specify attributes
                 -- If serial_number is passed then quantity should be 1
                 --
                 -- Debug Statements
                 --
                 IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name, ' l_update_transaction_temp_id '||l_update_transaction_temp_id||
                                                         ' l_update_serial_number '||l_update_serial_number||
                                                         ' p_changed_attributes(l_counter).picked_quantity '||p_changed_attributes(l_counter).picked_quantity||
                                                         ' l_new_req_quantity '||l_new_req_quantity||
                                                         ' old_delivery_detail_rec.requested_quantity '||old_delivery_detail_rec.requested_quantity );
                 END IF;
                 --
                 -- Bug 3764278, allow WMS to stamp transaction temp id when quantity =1
                 -- WMS has UI where user can enter serial number and attributes, hence this
                 -- requirement.This API is also called during Pick Confirm, test cases for Inv.
                 IF ((l_update_transaction_temp_id = 'Y' AND l_update_serial_number = 'Y') OR
                     (l_update_serial_number = 'Y' AND
                      ((p_changed_attributes(l_counter).picked_quantity = FND_API.G_MISS_NUM  AND
                        NVL(l_new_req_quantity, old_delivery_detail_rec.requested_quantity) > 1) OR
                       (p_changed_attributes(l_counter).picked_quantity <> FND_API.G_MISS_NUM AND
                        p_changed_attributes(l_counter).picked_quantity > 1))
                     )
                    ) THEN

                   OE_DEBUG_PUB.Add('REJECTING INVENTORY REQUEST');
                   FND_MESSAGE.Set_Name('WSH', 'WSH_REJECT_INV_REQUEST');
                   FND_MESSAGE.Set_Token('TRANSACTION_TEMP_ID', l_transaction_temp_id);
                   FND_MESSAGE.Set_Token('SERIAL_NUMBER', p_changed_attributes(l_counter).serial_number);
                   FND_MESSAGE.Set_Token('PICKED_QUANTITY', p_changed_attributes(l_counter).picked_quantity);
                   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                   WSH_UTIL_CORE.Add_Message(x_return_status);

                 END IF;


     IF ((l_update_sub = 'Y') OR
       (l_update_loc = 'Y') OR
       (l_update_rev = 'Y')
-- HW OPMCONV - Removed check for sublot code
        OR
       (l_update_lot = 'Y') OR
       (l_update_preferred_grade = 'Y') OR
       (l_update_transaction_temp_id = 'Y') OR
       (l_update_serial_number = 'Y') OR
       (l_update_rel_status = 'Y')) THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'UPDATE WSH_DELIVERY_DETAILS'  );
      END IF;
      --

    -- bug 2120494
    -- This part handles backordering of lines in the case of under picking where
    -- the pending quantity is zero.
    -- Below is a update statement which is repetition of from code where "action_flag = 'B'"
    -- This needs to be replaced soon with a procedure to reduce redundancy.
    l_under_pick_post_process_flag := 'N';  --Bug7592072
      IF  (l_pending_quantity = 0 -- Bug#: 3390514
    AND p_changed_attributes(l_counter).action_flag = 'U'
    AND p_Changed_Attributes(l_counter).picked_quantity < old_Delivery_detail_rec.requested_quantity )
    THEN
           l_under_pick_post_process_flag := 'Y';   --Bug7592072
-- HW OPM split_qty2 should get value of picked_quantity2
        l_split_quantity2 := p_Changed_attributes(l_Counter).picked_quantity2;
        IF l_split_quantity2 = FND_API.G_MISS_NUM THEN
        l_split_quantity2 := NULL;
        END IF;

        l_split_quantity := p_Changed_Attributes(l_counter).picked_quantity;

--Start of Consolidation of BO DD's

         l_cons_flag := 'N';
         -- Check the auto consolidation of back order lines only when current delivery detail id is
         -- not assigned to any planned delivery
         IF ( l_planned_flag = 'N' ) THEN
             --
	     -- Debug Statements
             --
             IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIPPING_PARAMS_PVT. Get_Global_Parameters',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;
             --
             WSH_SHIPPING_PARAMS_PVT. Get_Global_Parameters(l_global_param_rec_type,l_return_status);
             --
             IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name, 'After calling Get_Global_Parameters: ' || l_return_status );
             END IF;
             --
             IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
             END IF;
             l_auto_consolidate := l_global_param_rec_type.consolidate_bo_lines;
	 END IF;



         IF ( l_auto_consolidate = 'Y') THEN   -- consolidate the split Quantity

            l_Cons_Source_Line_Rec_Tab(1).delivery_detail_id:= old_Delivery_detail_rec.delivery_detail_id ;
            l_Cons_Source_Line_Rec_Tab(1).delivery_id:= null;
            l_Cons_Source_Line_Rec_Tab(1).source_line_id:=  old_Delivery_detail_rec.source_line_id;
            l_Cons_Source_Line_Rec_Tab(1).req_qty:= old_Delivery_detail_rec.requested_quantity;
            l_Cons_Source_Line_Rec_Tab(1).bo_qty:= old_Delivery_detail_rec.requested_quantity - l_split_quantity;
-- HW OPM BUG#:3121616 added qty2s
            l_Cons_Source_Line_Rec_Tab(1).req_qty2:= old_Delivery_detail_rec.requested_quantity2;

            --Bug# 5436033
            --do not calculate the qty2 - instead convert from bo_Qty Cause this is like entering a new line
            --and SO pad computes the sec qty from the order qty.
            IF l_Cons_Source_Line_Rec_Tab(1).bo_qty <> 0
                  AND old_Delivery_detail_rec.requested_quantity_uom2 IS NOT NULL THEN
                     l_Cons_Source_Line_Rec_Tab(1).bo_qty2 := WSH_WV_UTILS.convert_uom(
                                   item_id              => old_Delivery_detail_rec.inventory_item_id
                                 , lot_number           => NULL
                                 , org_id               => old_Delivery_detail_rec.organization_id
                                 , p_max_decimal_digits => NULL -- use default precision
                                 , quantity             => l_Cons_Source_Line_Rec_Tab(1).bo_qty
                                 , from_uom             => old_Delivery_detail_rec.requested_quantity_uom
                                 , to_uom               => old_Delivery_detail_rec.requested_quantity_uom2
                                 );
            END IF;
            --l_Cons_Source_Line_Rec_Tab(1).bo_qty2:= old_Delivery_detail_rec.requested_quantity2 - l_split_quantity2;
            --End Bug# 5436033

-- end of 3121616

            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name, 'CONSOLIDATE_SOURCE_LINE BEING CALLED WITH FOLLOWING PARAMETERS');
                 WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_DETAIL_ID',old_Delivery_detail_rec.delivery_detail_id);
                 WSH_DEBUG_SV.log(l_module_name,'P_REQUESTED_QUANTITY',old_Delivery_detail_rec.requested_quantity);
                 WSH_DEBUG_SV.log(l_module_name,'Back Order Qty:',old_Delivery_detail_rec.requested_quantity - l_split_quantity);
-- HW OPM BUG#:3121616 added qty2s
                 WSH_DEBUG_SV.log(l_module_name,'P_REQUESTED_QUANTITY2',old_Delivery_detail_rec.requested_quantity2);
                 WSH_DEBUG_SV.log(l_module_name,'Back Order Qty2:',l_Cons_Source_Line_Rec_Tab(1).bo_qty2);

            END IF;
            --
            WSH_DELIVERY_DETAILS_ACTIONS.Consolidate_Source_Line(
                         p_Cons_Source_Line_Rec_Tab    => l_Cons_Source_Line_Rec_Tab,
                         x_consolidate_ids        => l_cons_dd_ids,
                         x_return_status          => l_return_status);

             IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'After calling CONSOLIDATE_SOURCE_LINE: ',l_return_status);
             END IF;
             IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
             END IF;

             IF ( l_cons_dd_ids(1) <> p_Changed_attributes(l_counter).delivery_detail_id ) THEN
                l_cons_flag := 'Y';
                IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'Consolidated the Del Det Id: ',old_Delivery_detail_rec.delivery_detail_id);
                END IF;
                l_dummy_detail_id := p_Changed_attributes(l_counter).delivery_detail_id;
             ELSE
                IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'Consolidation not happened for the the Del Det Id: ',old_Delivery_detail_rec.delivery_detail_id);
                END IF;
             END IF;

          END IF; -- End of Consolidation of BO DD's

         -- IF no consolidation then Split the line
         IF ( l_cons_flag = 'N' ) THEN

             WSH_DELIVERY_DETAILS_ACTIONS.Split_Delivery_Details(
              p_from_detail_id   => p_Changed_attributes(l_counter).delivery_detail_id,
              p_req_quantity   => l_split_quantity,
              x_new_detail_id => l_dummy_detail_id,
              x_return_status => l_return_status,
              p_req_quantity2 => l_split_quantity2,
              p_manual_split   => p_changed_attributes(l_counter).action_flag);
       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Split_Delivery_Details l_return_status',l_return_status);
       END IF;


       -- Bug 3724578 : Return back to the caller if any error occures while
        --               splitting the delivery detail line
	--- Message will be set in  Split_Delivery_Details
	IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
		 x_return_status := l_return_status;
                 return;
	END IF;

                         -- Bug 2573434 : Added Call backorder API to unassign/unpack delivery detail
                         --
                         -- Debug Statements
                         --
                         IF l_debug_on THEN
                             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_USA_INV_PVT. BACKORDERED_DELIVERY_DETAIL',WSH_DEBUG_SV.C_PROC_LEVEL);
                         END IF;
                         --
                         --Bug# 5436033
                         --do not calculate the qty2 convert from bo_Qty Cause this is like entering a new line
                         --and SO pad computes the sec qty from the order qty.
                        IF (old_Delivery_detail_rec.requested_quantity - p_changed_attributes(l_Counter).picked_quantity) <> 0
                           AND old_Delivery_detail_rec.requested_quantity_uom2 IS NOT NULL THEN

                           l_requested_quantity2 := WSH_WV_UTILS.convert_uom(
                                                     item_id                => old_Delivery_detail_rec.inventory_item_id
                                                     , lot_number           => NULL
                                                     , org_id               => old_Delivery_detail_rec.organization_id
                                                     , p_max_decimal_digits => NULL -- use default precision
                                                     , quantity             => (old_Delivery_detail_rec.requested_quantity

 - p_changed_attributes(l_Counter).picked_quantity)
                                                     , from_uom             => old_Delivery_detail_rec.requested_quantity_uom
                                                     , to_uom               => old_Delivery_detail_rec.requested_quantity_uom2
                                                     );

                         END IF;
                         --End Bug# 5436033

                         backorder_delivery_detail(
                                           p_delivery_detail_id   =>  p_changed_attributes(l_counter).delivery_detail_id,
                                           p_requested_quantity   =>  old_Delivery_detail_rec.requested_quantity
                                                                                 - p_changed_attributes(l_Counter).picked_quantity,
                                           p_requested_quantity2  =>  l_requested_quantity2, --Bug# 5436033
                                           p_planned_flag         =>  l_planned_flag,
                                           p_wms_enabled_flag     =>  l_wms_enabled_flag,
                                           p_del_batch_id         =>  l_del_batch_id,
                                           x_split_quantity       =>  l_dummy_quantity,
                                           x_return_status        =>  l_return_status
                                           );
                         IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                             x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                         END IF;
         END IF; -- No Consolidation check.
    ELSE
        l_dummy_detail_id := p_Changed_attributes(l_counter).delivery_detail_id;
          END IF;

                -- Bug 2657652: Added l_update_shipped_quantity
                l_update_shipped_quantity := 'N';
                IF (l_update_transaction_temp_id = 'Y' OR l_update_serial_number = 'Y' or l_wms_enabled_flag = 'Y' ) THEN
                  l_update_shipped_quantity := 'Y';
                END IF;

    -- bug 2120494
                -- HW OPM added OPM attributes qty2
-- HW OPM BUG#:3121616 added shipped_qty2 and cycle_count_quantity2
          UPDATE wsh_delivery_details
          SET    subinventory = decode(l_update_sub,'Y',p_Changed_Attributes(l_Counter).subinventory,subinventory),
           locator_id = decode(l_update_loc, 'Y',p_Changed_Attributes(l_Counter).locator_id,locator_id),
           revision   = decode(l_update_rev ,'Y',p_Changed_Attributes(l_Counter).revision,revision),
-- HW OPMCONV - No need for sublot_number
--         sublot_number  = decode(l_update_sublot,'Y',p_Changed_Attributes(l_Counter).sublot_number,sublot_number),
           lot_number = decode(l_update_lot,'Y',p_Changed_Attributes(l_Counter).lot_number,lot_number),
           preferred_grade  = decode(l_update_preferred_grade,'Y',p_Changed_Attributes(l_Counter).preferred_grade,preferred_grade),
                       -- Bug 2657652: Added transaction_temp_id and modified Shipped Quantity / Cycle Count Quantity clause
                       transaction_temp_id = decode(l_update_transaction_temp_id, 'Y',l_transaction_temp_id,transaction_temp_id),
           serial_number  = decode(l_update_serial_number,'Y',p_Changed_Attributes(l_Counter).serial_number,serial_number),
           shipped_quantity = decode(l_update_shipped_quantity,
                                           'Y',decode(p_changed_attributes(l_counter).picked_quantity,
                                                 FND_API.G_MISS_NUM, NVL(l_new_req_quantity, requested_quantity),
                                                 p_changed_attributes(l_counter).picked_quantity),
                                           shipped_quantity),
           shipped_quantity2 = decode(l_update_shipped_quantity,
                                           'Y',decode(p_changed_attributes(l_counter).picked_quantity2,
                                                 FND_API.G_MISS_NUM, NVL(l_new_req_quantity2, requested_quantity2),
                                                 p_changed_attributes(l_counter).picked_quantity2),
                                           shipped_quantity2),

           -- Bug 1851473 : Set backordered qty = 0 in STF
           cycle_count_quantity = decode(l_update_shipped_quantity,'Y',0,cycle_count_quantity),
           cycle_count_quantity2 = decode(l_update_shipped_quantity,'Y',0,cycle_count_quantity2),
           released_status  = decode(l_update_rel_status,'Y',decode(pickable_flag,'Y',p_Changed_Attributes(l_Counter).released_status,'X'), released_status),
           requested_quantity  = NVL(l_new_req_quantity, requested_quantity),
           requested_quantity2 = NVL(l_new_req_quantity2, requested_quantity2),
           picked_quantity  = DECODE(p_changed_attributes(l_counter).picked_quantity, FND_API.G_MISS_NUM, NULL,
                       p_changed_attributes(l_counter).picked_quantity),
           picked_quantity2 = DECODE(p_changed_attributes(l_counter).picked_quantity2, FND_API.G_MISS_NUM, NULL,
                       p_changed_attributes(l_counter).picked_quantity2),
           requested_quantity_uom2 = DECODE(l_wms_enabled_flag,
                                           'Y',
                                           DECODE(p_changed_attributes(l_counter).ordered_quantity_uom2,
                                                  FND_API.G_MISS_CHAR, requested_quantity_uom2,
                                                  p_changed_attributes(l_counter).ordered_quantity_uom2),
                                           requested_quantity_uom2),
           batch_id = DECODE(batch_id, NULL, WSH_PICK_LIST.G_BATCH_ID, batch_id),
                       last_update_date  = SYSDATE,
                       last_updated_by   = l_user_id,
                       last_update_login = l_login_id,
           ----Bug#5104847:transaction_id updated only when l_transaction_id is not FND_API.G_MISS_NUM (default value).
           transaction_id = DECODE(l_transaction_id,FND_API.G_MISS_NUM,transaction_id,l_transaction_id)
	   ,tracking_number = old_Delivery_detail_rec.tracking_number --Bug# 3632485
          WHERE  delivery_detail_id = l_dummy_detail_id
          RETURNING organization_id -- Done for Workflow Project
          INTO l_organization_id;

	--Raise Event : Pick To Pod Workflow
	  WSH_WF_STD.Raise_Event(
							p_entity_type => 'LINE',
							p_entity_id => l_dummy_detail_id ,
							p_event => 'oracle.apps.wsh.line.gen.staged' ,
							p_organization_id => l_organization_id,
							x_return_status => l_wf_rs ) ;
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.log(l_module_name,'Current Time is ',SYSDATE);
	     wsh_debug_sv.log(l_module_name,'Return Status After Calling WSH_WF_STD.Raise_Event',l_wf_rs);
	 END IF;
	--Done Raise Event : Pick To Pod Workflow


       --
        --
        -- DBI Project
        -- Update of wsh_delivery_details where requested_quantity
        -- are changed, call DBI API after the update.
        -- DBI API checks for DBI Installed also
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Detail id-',l_dummy_detail_id);
        END IF;
        l_detail_tab(1) := l_dummy_detail_id;
        WSH_INTEGRATION.DBI_Update_Detail_Log
          (p_delivery_detail_id_tab => l_detail_tab,
           p_dml_type               => 'UPDATE',
           x_return_status          => l_dbi_rs);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
        END IF;
        -- DBI API can only raise unexpected error, in that case need to
        -- pass it to the caller API for roll back of the whole transaction
        -- Only need to handle Unexpected error, rest are treated as success
        -- Since code is not proceeding, no need to reset x_return_status
        IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_dbi_rs;
          IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          RETURN;
        END IF;

        -- End of Code for DBI Project
        --
	-- bug 3632485 When transacted quantity is less than allocated quantity, null out tracking number for backordered delivery detail.
	if (old_Delivery_detail_rec.tracking_number is not null
	    and p_Changed_attributes(l_counter).delivery_detail_id <>l_dummy_detail_id) then
	     update wsh_delivery_details
	     set tracking_number = NULL
	     where delivery_detail_id = p_Changed_attributes(l_counter).delivery_detail_id;
	 end if;

/* Bug 2740833: After updating the wdd with the overpick qty, the weight and the volume needs to be re-calculated.*/
-- J: W/V Changes
-- Bug7592072 Begin
                IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name,'l_under_pick_post_process_flag',l_under_pick_post_process_flag);
                     WSH_DEBUG_SV.log(l_module_name,'p_changed_attributes(l_Counter).transfer_lpn_id',p_changed_attributes(l_Counter).transfer_lpn_id);
                     WSH_DEBUG_SV.log(l_module_name,'l_cont_instance_id',l_cont_instance_id);
                     WSH_DEBUG_SV.log(l_module_name,'l_wms_enabled_flag',l_wms_enabled_flag);
                END IF;
                IF  (  l_under_pick_post_process_flag = 'Y'  AND  l_cont_instance_id IS NOT NULL  AND l_wms_enabled_flag = 'Y'
                        AND  p_changed_attributes(l_Counter).transfer_lpn_id IS NOT NULL) THEN
                --{
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONTAINER_WEIGHT_VOLUME',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    WSH_WV_UTILS.Container_Weight_Volume (
                           p_container_instance_id => l_cont_instance_id,
                           p_override_flag         => 'Y',
                           p_fill_pc_flag          => 'Y',
                           p_post_process_flag     => 'Y',
                           p_calc_wv_if_frozen     => 'Y',
                          x_gross_weight           => l_cont_gross_weight,
                          x_net_weight             => l_cont_net_weight,
                          x_volume                 => l_cont_volume,
                          x_cont_fill_pc           => l_cont_fill_pc,
                          x_return_status          => x_return_status);
                    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
                        x_return_status := l_return_status;
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.pop(l_module_name,'Container_Weight_Volume returned '||l_return_status);
                            WSH_DEBUG_SV.pop(l_module_name);
                        END IF;
                        return;
                    END IF;
               --}
               END IF;
--Bug7592072 End
                --Bug 7307755 : No need to post weight changes to LPN records as
                --              WMS is taking care of populating w/v values including
                --              overpicked qty on LPN records.
                l_post_process_flag := 'Y';
                IF (p_changed_attributes(l_Counter).transfer_lpn_id <> FND_API.G_MISS_NUM ) THEN
                    l_post_process_flag := 'N';
                END IF;
                --
                IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'l_post_process_flag',l_post_process_flag);
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.Detail_Weight_Volume',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;

                WSH_WV_UTILS.Detail_Weight_Volume
                                             (p_delivery_detail_id =>l_dummy_detail_id,
                                              p_update_flag        => 'Y',
                                              p_post_process_flag  => l_post_process_flag,--Bug7307755
                                              p_calc_wv_if_frozen  => 'N',
                                              x_net_weight         => l_net_weight,
                                              x_volume             => l_volume,
                                              x_return_status      => l_return_status);
                IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
                  x_return_status := l_return_status;
                  IF l_debug_on THEN
                    WSH_DEBUG_SV.pop(l_module_name,'Detail_Weight_Volume returned '||l_return_status);
                    WSH_DEBUG_SV.pop(l_module_name);
                  END IF;
                  return;
                END IF;

                /* OPM Begin Bug 2671460 */
                            /* OPM Begin Bug 2671460 */
-- HW OPMCONV. Removed code forking

      IF l_update_quantities = 'Y' THEN
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_USA_QUANTITY_PVT.UPDATE_ORDERED_QUANTITY',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
                                        -- bug 2942655 / 2936559
                                        --   overpick normalization will avoid canceling
                                        --     lines pending overpick by passing p_context.
          WSH_USA_QUANTITY_PVT.Update_Ordered_Quantity(
            p_changed_attribute   => l_overpick_rec,
            p_source_code         => l_source_code,
            p_action_flag         => 'U',
                                          p_context             => 'OVERPICK',
            x_return_status => l_return_status
          );

          IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          END IF;
      END IF;

     END IF;

    END IF; -- End of if action_flag = 'M'

   <<loop_end>>


   -- deliveryMerge csun
   IF l_update_rel_status = 'Y'
            and old_delivery_detail_rec.pickable_flag = 'Y'
            and p_changed_attributes(l_counter).released_status = 'Y'
            and l_delivery_id is not NULL
            and NVL(WSH_PICK_LIST.G_AUTO_PICK_CONFIRM, 'N') <> 'Y' THEN
        l_delivery_already_included := false;

        IF l_adjust_planned_del_tab.count > 0 THEN
           FOR i in l_adjust_planned_del_tab.FIRST .. l_adjust_planned_del_tab.LAST LOOP
              IF l_adjust_planned_del_tab(i) = l_delivery_id THEN
                 l_delivery_already_included := true;
              END IF;
           END LOOP;
        END IF;

        IF NOT l_delivery_already_included THEN
           l_adjust_planned_del_tab(l_adjust_planned_del_tab.count+1) := l_delivery_id;
        END IF;
   END IF;


   END LOOP;



   IF l_details_to_delete.count > 0 THEN
   --
   WSH_INTERFACE.Delete_Details(
       p_details_id => l_details_to_delete,
       x_return_status => l_return_status);
   IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'Delete_Details l_return_status',l_return_status);
   END IF;
   IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   END IF;
   END IF;


   -- deliveryMerge
   IF l_adjust_planned_del_tab.count > 0 THEN
      WSH_NEW_DELIVERY_ACTIONS.Adjust_Planned_Flag(
         p_delivery_ids          => l_adjust_planned_del_tab,
         p_caller                => 'WSH_DLMG',
         p_force_appending_limit => 'N',
         p_call_lcss             => 'Y',
         x_return_status         => l_return_status);

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Adjust_Planned_Flag returns ',l_return_status);
      END IF;

      IF  l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
         raise Adjust_Planned_Flag_Err;
      ELSIF (l_return_status in (WSH_UTIL_CORE.G_RET_STS_WARNING, WSH_UTIL_CORE.G_RET_STS_ERROR)) and
            x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      END IF;
   END IF;


   <<multiple_updates>>
   IF (l_multiple_update = 'Y') THEN
    update_inventory_info(l_changed_attributes, l_return_status);
    --bugfix 9726107 added warning condition
    IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    ELSIF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    END IF;

   END IF;
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'update_inventory_info procedure returns ',x_return_status);
      WSH_DEBUG_SV.logmsg(l_module_name,'EXITING UPDATE_INVENTORY_INFO PROCEDURE ...'  );
   END IF;
   --

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
   EXCEPTION
          -- inbound logistics --jckwok
          WHEN Delivery_Line_Direction_Err THEN
                x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                --
                -- LPN CONV rv
                WSH_WMS_LPN_GRP.g_caller := l_original_caller;
                WSH_WMS_LPN_GRP.g_callback_required := l_orig_callback_reqd;
                -- LPN CONV rv
                --
                IF l_debug_on THEN
                   WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:Delivery_Line_Direction_Err');
                END IF;
          -- deliveryMerge
          WHEN Adjust_Planned_Flag_Err THEN
                FND_MESSAGE.SET_NAME('WSH', 'WSH_ADJUST_PLANNED_FLAG_ERR');
                WSH_UTIL_CORE.add_message(l_return_status,l_module_name);
                x_return_status := l_return_status;

                --
                -- LPN CONV rv
                WSH_WMS_LPN_GRP.g_caller := l_original_caller;
                WSH_WMS_LPN_GRP.g_callback_required := l_orig_callback_reqd;
                -- LPN CONV rv
                --
                IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Adjust_Planned_Flag_Err exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                   WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:Adjust_Planned_Flag_Err');
                END IF;
          --

    WHEN others THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    wsh_util_core.default_handler('WSH_USA_INV_PVT.Update_Inventory_Info',l_module_name);
                --
                -- LPN CONV rv
                WSH_WMS_LPN_GRP.g_caller := l_original_caller;
                WSH_WMS_LPN_GRP.g_callback_required := l_orig_callback_reqd;
                -- LPN CONV rv
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
                END IF;
--
END Update_Inventory_Info;

-- Bug 2939884

-- HW OPMCONV Make get_detailed a procedure to pass Qty2

-- PROCEDURE get_detailed_quantity
-- Parameters:	p_mo_line_id     - Move order line id
-- 		x_detailed_qty   - Primary Qty
--              x_detailed_qty2  - Secondary Qty
--              x_return_status  - Return Status

-- Description: This procedure was originally a function but because of
-- OPM Convergence project, it was converted to a procedure to return
-- Qty1 and Qty2.
-- This procedure checks if Qtys are detailed in mtl_material_transactions_temp
-- for a specific move order line id
--
PROCEDURE  get_detailed_quantity (
           p_mo_line_id              IN          NUMBER,
           x_detailed_qty            OUT NOCOPY  NUMBER,
           x_detailed_qty2           OUT NOCOPY  NUMBER,
           x_return_status           OUT NOCOPY  VARCHAR2)
IS

l_detailed_qty NUMBER;
-- HW OPMCONV -added qty2
l_detailed_qty2 NUMBER ;

-- HW OPMCONV added Qty2
cursor c_detailed_qty(p_line_id IN NUMBER)  IS
select sum(abs(transaction_quantity)) detailed_quantity,
       sum(abs(SECONDARY_TRANSACTION_QUANTITY )) secondary_detailed_quantity
from mtl_material_transactions_temp
where move_order_line_id = p_line_id;

l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'get_detailed_quantity';
l_debug_on BOOLEAN;
qty_not_found EXCEPTION;

BEGIN

   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
     WSH_DEBUG_SV.push(l_module_name);
     WSH_DEBUG_SV.log(l_module_name,'p_mo_line_id',p_mo_line_id);
   END IF;

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   OPEN c_detailed_qty(p_mo_line_id);
   FETCH  c_detailed_qty INTO l_detailed_qty, l_detailed_qty2;
   IF c_detailed_qty%NOTFOUND THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'l_detailed_qty not found');
        raise qty_not_found;
      END IF;
   END IF;

   CLOSE c_detailed_qty;


   IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_detailed_qty',l_detailed_qty);
-- HW OPMCONV - Print value of Qty2
    WSH_DEBUG_SV.log(l_module_name,'l_detailed_qty2',l_detailed_qty2);
    WSH_DEBUG_SV.pop(l_module_name);
   END IF;

   --fp bug 5347149/5253861: return 0, instead of NULL, so that
   -- the callers can compute the non-null reservation quantity to transfer.
   x_detailed_qty := NVL(l_detailed_qty, 0);
-- HW OPMCONV - Pass Qty2 as 0 if it is NULL
   x_detailed_qty2 := NVL(l_detailed_qty2,0);

EXCEPTION

WHEN qty_not_found THEN
  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  IF c_detailed_qty%ISOPEN THEN
     CLOSE c_detailed_qty;
  END IF;
  IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:get_detailed_FAILED');
  END IF;


WHEN OTHERS THEN

  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  IF c_detailed_qty%ISOPEN THEN
     CLOSE c_detailed_qty;
  END IF;
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
  END IF;
  wsh_util_core.default_handler('WSH_USA_INV_PVT.get_detailed_quantity',l_module_name);

END get_detailed_quantity;

--
--  X-dock
-- Function: Derive Move Order type based on move_order_line_id
-- Parameters : p_move_order_line_id - Move Order Line id
-- Description : If move_order_type = PUTAWAY for the input move_order_line_id
--               return TRUE, else return FALSE
--
FUNCTION is_mo_type_putaway (p_move_order_line_id IN NUMBER) RETURN VARCHAR2 IS

  L_mo_type       NUMBER;
  l_is_putaway    VARCHAR2(1);
  l_return_status VARCHAR2(1);
  l_mo_header_id  NUMBER;

  l_module_name   CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'is_mo_type_putaway';
  l_debug_on      BOOLEAN;

BEGIN

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_move_order_line_id',p_move_order_line_id);
  END IF;

  l_is_putaway := 'N';

  WMS_CROSSDOCK_GRP.CHK_MO_TYPE
    (p_mo_line_id      => p_move_order_line_id,
     x_return_status   => l_return_status,
     x_mo_header_id    => l_mo_header_id,
     x_mo_type         => l_mo_type,
     x_is_putaway_mo   => l_is_putaway);

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
    WSH_DEBUG_SV.log(l_module_name,'l_mo_header_id',l_mo_header_id);
    WSH_DEBUG_SV.log(l_module_name,'l_mo_type',l_mo_type);
    WSH_DEBUG_SV.log(l_module_name,'Is Type Putaway',l_is_putaway);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

  RETURN l_is_putaway;

EXCEPTION

  WHEN OTHERS THEN
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_USA_INV_PVT.is_mo_type_putaway',l_module_name);
    RETURN 'N';

END is_mo_type_putaway;

--
-- Procedure   : get_putaway_detail_id
-- Description : Procedure to return delivery_detail_id based on move_order_type
--               associated with Move Order Line id.For scenarios where released_status
--               and move_order_line_id are not passed to this API, first
--               derive those from wsh_delivery_details and then proceed.
--
PROCEDURE  get_putaway_detail_id(
           p_detail_id               IN          NUMBER,
           p_released_status         IN          VARCHAR2,
           p_move_order_line_id      IN          NUMBER,
           x_detail_id               OUT NOCOPY  NUMBER,
           x_return_status           OUT NOCOPY  VARCHAR2) IS

CURSOR c_get_line_details IS
  SELECT released_status,
         move_order_line_id
    FROM wsh_delivery_details
   WHERE delivery_detail_id = p_detail_id;

l_line_details c_get_line_details%ROWTYPE;
l_released_status WSH_DELIVERY_DETAILS.RELEASED_STATUS%TYPE;
l_move_order_line_id WSH_DELIVERY_DETAILS.MOVE_ORDER_LINE_ID%TYPE;

l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PACKAGE_NAME || '.' || 'get_putaway_detail_id';
l_debug_on BOOLEAN;

BEGIN

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_detail_id',p_detail_id);
    WSH_DEBUG_SV.log(l_module_name,'p_released_status',p_released_status);
    WSH_DEBUG_SV.log(l_module_name,'p_move_order_line_id',p_move_order_line_id);
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  -- Check if released_status and move_order_line_id have been specified
  -- MOL can be null even if released status is specified.
  IF (p_detail_id is not null AND
      p_released_status IS NULL
     ) THEN

    OPEN c_get_line_details;
    FETCH c_get_line_details
     INTO l_line_details;
    CLOSE c_get_line_details;

    l_released_status := l_line_details.released_status;
    l_move_order_line_id := l_line_details.move_order_line_id;
  ELSE
    l_released_status := p_released_status;
    l_move_order_line_id := p_move_order_line_id;
  END IF;

  -- normal Inventory scenario or Planned X-dock without MOL
  x_detail_id := NULL;

  --Check only for line with released_status = 'S' and MOL is not null and MO type = PUTAWAY
  IF p_detail_id IS NOT NULL AND
     l_released_status = WSH_DELIVERY_DETAILS_PKG.C_RELEASED_TO_WAREHOUSE AND
     l_move_order_line_id IS NOT NULL AND
     wsh_usa_inv_pvt.is_mo_type_putaway (l_move_order_line_id) = 'Y' THEN
    x_detail_id := p_detail_id;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'x_detail_id',x_detail_id);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    IF c_get_line_details%ISOPEN THEN
      CLOSE c_get_line_details;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_USA_INV_PVT.get_putaway_detail_id',l_module_name);
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
END get_putaway_detail_id;

END WSH_USA_INV_PVT;

/
