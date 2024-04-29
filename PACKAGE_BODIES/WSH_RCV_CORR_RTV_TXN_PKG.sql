--------------------------------------------------------
--  DDL for Package Body WSH_RCV_CORR_RTV_TXN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_RCV_CORR_RTV_TXN_PKG" as
/* $Header: WSHRCRVB.pls 120.0 2005/05/26 18:03:27 appldev noship $ */


--===================
-- GLOBAL VARIABLES
--===================
  --
  G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_RCV_CORR_RTV_TXN_PKG';
  --
  --
  -- the following variables are defined for caching the delivery id
  g_del_cache_tbl wsh_util_core.key_value_tab_type;
  g_del_ext_cache_tbl wsh_util_core.key_value_tab_type;

  -- the following variables are defined for caching the lpns that need to
  -- deleted
  g_unassgin_lpn_cache_tbl wsh_util_core.key_value_tab_type;
  g_unassgin_lpn_ext_cache_tbl wsh_util_core.key_value_tab_type;
  --
  --
--===================
-- PROCEDURES
--===================
--========================================================================
-- PROCEDURE : Process_Rcv             This procedure is called from
--                                     process_corrections_and_rtv
--                                     to handle the receipt corrections
--                                     (both positive and negative).
--
-- PARAMETERS: x_matched_detail_rec    Record that contains the info about
--                                     all the matched delivery details.
--             p_matched_detail_index  Index of x_matched_detail_rec on
--                                     which we need to process
--                                     the corrections.
--             x_update_det_rec        Record that we finally use to update
--                                     wsh_delivery_details after processing
--                                     the corrections.
--             p_update_det_rec_idx    Index of x_update_det_rec on
--                                     which we need to process
--                                     the corrections.
--             x_rem_req_qty_rec       Record to collect the remaining
--                                     requested quantity after processing
--                                     each record in the x_matched_detail_rec.
--             x_unassign_det_tbl      Table that is used to unassign the
--                                     delivery details from deliveries when
--                                     received quantity is completely
--                                     nullified on them.
--             x_delivery_id_tab       Table of delivery ids that need to be
--                                     passed back to
--                                     process_corrections_and_rtv which will
--                                     be used to re-calculate weight-vol,
--                                     Mark_Reprice_Required,rerateDeliveries.
--             x_wv_detail_tab         Table of delivery details for which we
--                                     need to re-calculate wt-vol as a result
--                                     of updating the received quantities.
--             x_unassigned_lpn_id_tab Table of lpns for that will be deleted
--                                     if they do not contain any delivery
--                                     lines within them.
--             x_wv_recalc_del_id_tab  Table of deliveries for which
--                                     the wv_frozen_flag is set to 'Y'
--                                     for the corresponding lines.
--             x_return_status         Return status of the API.

-- COMMENT   : This procedure is used to mainly assign the updated received
--             quantities from x_matched_detail_rec for each delivery detail
--             to x_update_det_rec correspondingly as this x_update_det_rec
--             is finally used to perform a bulk update on wsh_delivery_details
--             in the procedure process_corrections_and_rtv.
--
--========================================================================

  PROCEDURE process_rcv (
    x_matched_detail_rec IN OUT NOCOPY WSH_IB_UI_RECON_GRP.asn_rcv_del_det_rec_type,
    p_matched_detail_index IN NUMBER,
    x_update_det_rec IN OUT NOCOPY update_detail_rec_type,
    p_update_det_rec_idx IN NUMBER,
    x_rem_req_qty_rec IN OUT NOCOPY rem_req_qty_rec_type,
    x_unassign_det_tbl IN OUT NOCOPY wsh_util_core.id_tab_type,
    x_po_line_loc_tbl IN OUT NOCOPY wsh_util_core.id_tab_type,
    x_delivery_id_tab  IN OUT NOCOPY wsh_util_core.id_tab_type,
    x_wv_detail_tab    IN OUT NOCOPY wsh_util_core.id_tab_type,
    x_unassigned_lpn_id_tab       IN OUT NOCOPY wsh_util_core.id_tab_type,
    x_wv_recalc_del_id_tab       IN OUT NOCOPY wsh_util_core.id_tab_type,
    x_return_status OUT NOCOPY VARCHAR2)
  IS
  --{

  l_child_index      NUMBER;
  l_det_id_tab wsh_util_core.id_tab_type;
  l_det_action_prms    WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type;
  l_det_action_out_rec WSH_GLBL_VAR_STRCT_GRP.DD_ACTION_OUT_REC_TYPE;
  l_return_status VARCHAR2(1);
  l_num_errors    NUMBER;
  l_msg_data      VARCHAR2(32767);
  l_msg_count     NUMBER;
  l_num_warnings  NUMBER;

  l_del_update_req_flag VARCHAR2(1);
  l_delivery_id   NUMBER;
  --
    -- This cursor is used to obtain the delivery_id for the
    -- delivery detail which is being processed.
    -- Finally these deliveries will be used to recalculate the wt-vol,
    -- and rerating etc.
    cursor l_delivery_id_csr(p_del_det_id NUMBER) is
    select wnd.delivery_id
    from  wsh_delivery_assignments_v wda,
          wsh_new_deliveries wnd
    where wda.delivery_detail_id = p_del_det_id
    and   wda.delivery_id = wnd.delivery_id;

    --
    -- cursor to get the lpns for the lines.
    cursor l_unassigned_lpns_csr(p_delivery_detail_id IN NUMBER) is
    select parent_delivery_detail_id
    from   wsh_delivery_assignments_v
    where  delivery_detail_id = p_delivery_detail_id;

    l_unassigned_lpn_id NUMBER;

    cursor l_del_det_wv_flag_csr(p_delivery_detail_id IN NUMBER) is
    select gross_weight,
           net_weight,
           volume,
           NVL(wv_frozen_flag,'Y') wv_frozen_flag
    from   wsh_delivery_details
    where  delivery_detail_id = p_delivery_detail_id;

    l_qty_ratio NUMBER;
    l_det_gr_weight NUMBER;
    l_det_net_weight NUMBER;
    l_det_volume     NUMBER;
    l_det_wv_frozen_flag VARCHAR2(10) := 'N';
  --
  --}
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PROCESS_RCV';
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
        --
        WSH_DEBUG_SV.log(l_module_name,'P_MATCHED_DETAIL_INDEX',P_MATCHED_DETAIL_INDEX);

        WSH_DEBUG_SV.log(l_module_name,'P_UPDATE_DET_REC_IDX',P_UPDATE_DET_REC_IDX);
        WSH_DEBUG_SV.log(l_module_name,'recevied quantity db',x_matched_detail_rec.received_qty_db_tab(p_matched_detail_index));
        WSH_DEBUG_SV.log(l_module_name,'recevied quantity ',x_matched_detail_rec.received_qty_tab(p_matched_detail_index));
        WSH_DEBUG_SV.log(l_module_name,'update recs recevied quantity ',x_update_det_rec.received_qty_tab(p_update_det_rec_idx));
        WSH_DEBUG_SV.log(l_module_name,'update recs record_changed_flag ',x_update_det_rec.record_changed_flag_tab(p_update_det_rec_idx));
    END IF;
    --
    SAVEPOINT PROCESS_RCV;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    IF x_matched_detail_rec.received_qty_tab(p_matched_detail_index) < 0 THEN
    --{
      FND_MESSAGE.SET_NAME('WSH','WSH_UI_NEGATIVE_QTY');
      x_return_status := wsh_util_core.g_ret_sts_error;
      wsh_util_core.add_message(x_return_status, l_module_name);
      RAISE FND_API.G_EXC_ERROR;
    --}
    END IF;
    IF nvl(x_matched_detail_rec.received_qty_db_tab(p_matched_detail_index),0) > nvl(x_matched_detail_rec.received_qty_tab(p_matched_detail_index),0) THEN
    --{
      -- This means that the user has reduced the received quantity on the delivery
      -- detail (equivalent to negative correction).
      IF nvl(x_matched_detail_rec.received_qty_tab(p_matched_detail_index),0) = 0 THEN
      --{
        -- This means that the delivery detail's received quantity is nulled by the user
        -- which tells us that we need to unassign this detail its the delivery.
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'This means complete negative correction of the original quantity received');
          WSH_DEBUG_SV.log(l_module_name,'delivery detail id ', x_matched_detail_rec.del_detail_id_tab(p_matched_detail_index));
          WSH_DEBUG_SV.log(l_module_name,'po line loc id ', x_matched_detail_rec.po_line_location_id_tab(p_matched_detail_index));
        END IF;
        x_unassign_det_tbl(x_unassign_det_tbl.count + 1) := x_matched_detail_rec.del_detail_id_tab(p_matched_detail_index);
        x_po_line_loc_tbl(x_po_line_loc_tbl.count + 1) := x_matched_detail_rec.po_line_location_id_tab(p_matched_detail_index);

        -- need to delete the corresponding lpns also if they are not
        -- containing any other delivery lines.
        open  l_unassigned_lpns_csr(x_matched_detail_rec.del_detail_id_tab(p_matched_detail_index));
        fetch l_unassigned_lpns_csr into l_unassigned_lpn_id;
        close l_unassigned_lpns_csr;
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'delivery line is',x_matched_detail_rec.del_detail_id_tab(p_matched_detail_index));
          WSH_DEBUG_SV.log(l_module_name,'l_unassigned_lpn_id',l_unassigned_lpn_id);
        END IF;

        IF (l_unassigned_lpn_id IS NOT NULL) THEN
        --{
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_CACHED_VALUE',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          wsh_util_core.get_cached_value(
            p_cache_tbl     => g_unassgin_lpn_cache_tbl,
            p_cache_ext_tbl => g_unassgin_lpn_ext_cache_tbl,
            p_value         => l_unassigned_lpn_id,
            p_key           => l_unassigned_lpn_id,
            p_action        => 'GET',
            x_return_status => l_return_status);

          IF l_return_status IN (wsh_util_core.g_ret_sts_error, wsh_util_core.g_ret_sts_unexp_error) THEN
             RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF (l_return_status = wsh_util_core.g_ret_sts_warning) THEN
          --{
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_CACHED_VALUE',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            wsh_util_core.get_cached_value(
              p_cache_tbl     => g_unassgin_lpn_cache_tbl,
              p_cache_ext_tbl => g_unassgin_lpn_ext_cache_tbl,
              p_value         => l_unassigned_lpn_id,
              p_key           => l_unassigned_lpn_id,
              p_action        => 'PUT',
              x_return_status => l_return_status);

            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return Status after calling wsh_util_core.get_cached_value for put is',l_return_status);
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            wsh_util_core.api_post_call(
              p_return_status    => l_return_status,
              x_num_warnings     => l_num_warnings,
              x_num_errors       => l_num_errors);

            x_unassigned_lpn_id_tab(x_unassigned_lpn_id_tab.count + 1) := l_unassigned_lpn_id;
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'After assigning the value');
            END IF;
          --}
          END IF;
        --}
        END IF;

        /*  commented this code because this is already taken care of by
        unassign_multilple_details
        x_update_det_rec.received_qty_tab(p_matched_detail_index) := NULL;
        x_update_det_rec.received_qty2_tab(p_matched_detail_index) := NULL;
        x_update_det_rec.returned_qty_tab(p_matched_detail_index) := NULL;
        x_update_det_rec.returned_qty2_tab(p_matched_detail_index) := NULL;
        x_update_det_rec.shipment_line_id_tab(p_matched_detail_index) := NULL;
        x_update_det_rec.released_sts_tab(p_matched_detail_index) := 'X';
        */
      --}
      ELSE
      --{
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Inside the Else part of IF condition');
        END IF;
        x_update_det_rec.received_qty_tab(p_update_det_rec_idx) := x_matched_detail_rec.received_qty_tab(p_matched_detail_index);

        x_update_det_rec.requested_qty_tab(p_update_det_rec_idx) := least(x_matched_detail_rec.requested_qty_tab(p_matched_detail_index),
        x_matched_detail_rec.received_qty_tab(p_matched_detail_index));

        x_update_det_rec.received_qty2_tab(p_update_det_rec_idx) := x_matched_detail_rec.received_qty2_tab(p_matched_detail_index);

        x_update_det_rec.requested_qty2_tab(p_update_det_rec_idx) := least(x_matched_detail_rec.requested_qty2_tab(p_matched_detail_index),
        x_matched_detail_rec.received_qty2_tab(p_matched_detail_index));

        l_child_index := x_matched_detail_rec.child_index_tab(p_matched_detail_index);
        /*
        IF ( l_child_index IS NOT NULL ) THEN
        --{
          x_matched_detail_rec.process_corr_rtv_flag_tab(l_child_index) := 'N';
         */
        --}
        IF ( l_child_index IS NULL ) THEN
        --{
          x_rem_req_qty_rec.requested_quantity := nvl(x_rem_req_qty_rec.requested_quantity,0) +
          /*
          (x_matched_detail_rec.received_qty_db_tab(p_matched_detail_index) -
          x_matched_detail_rec.received_qty_tab(p_matched_detail_index));
          */
          greatest((least(x_matched_detail_rec.received_qty_db_tab(p_matched_detail_index), x_matched_detail_rec.requested_qty_db_tab(p_matched_detail_index))-x_matched_detail_rec.received_qty_tab(p_matched_detail_index)),0);

          x_rem_req_qty_rec.requested_quantity_uom := x_matched_detail_rec.requested_qty_uom_tab(p_matched_detail_index);

          IF x_matched_detail_rec.requested_qty2_tab(p_matched_detail_index) IS NOT NULL THEN
          --{
            x_rem_req_qty_rec.requested_quantity2 := nvl(x_rem_req_qty_rec.requested_quantity2,0) +
            /*
            (x_matched_detail_rec.received_qty2_db_tab(p_matched_detail_index) -
            x_matched_detail_rec.received_qty2_tab(p_matched_detail_index));
            */
            greatest((least(x_matched_detail_rec.received_qty2_db_tab(p_matched_detail_index), x_matched_detail_rec.requested_qty2_db_tab(p_matched_detail_index))-x_matched_detail_rec.received_qty2_tab(p_matched_detail_index)),0);

            x_rem_req_qty_rec.requested_quantity2_uom:= x_matched_detail_rec.requested_qty_uom2_tab(p_matched_detail_index);
          --}
          END IF;
        --}
        END IF;

      --}
      END IF;
      x_update_det_rec.record_changed_flag_tab(p_update_det_rec_idx) := 'Y';
      l_del_update_req_flag := 'Y';
    --}
    ELSIF nvl(x_matched_detail_rec.received_qty_db_tab(p_matched_detail_index),0) < nvl(x_matched_detail_rec.received_qty_tab(p_matched_detail_index),0) THEN
    --{
      -- This means that the user has increased the received quantity on the delivery
      -- detail (equivalent to positive correction).
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Inside the Else IF condition');
      END IF;
      x_update_det_rec.received_qty_tab(p_update_det_rec_idx) := x_matched_detail_rec.received_qty_tab(p_matched_detail_index);

      x_update_det_rec.received_qty2_tab(p_update_det_rec_idx) := x_matched_detail_rec.received_qty2_tab(p_matched_detail_index);

      x_update_det_rec.record_changed_flag_tab(p_update_det_rec_idx) := 'Y';
      l_del_update_req_flag := 'Y';
    --}
    END IF;
    --
    --
    IF nvl(l_del_update_req_flag, 'N') = 'Y' THEN
    --{
      IF nvl(x_update_det_rec.received_qty_tab(p_update_det_rec_idx),0) = 0 THEN
      --{
        x_update_det_rec.received_qty_tab(p_update_det_rec_idx) := null;
      --}
      END IF;
      --
      -- This is added so that we calculate the weight and volume of the del details
      -- only for receipt corrections.
      x_wv_detail_tab(x_wv_detail_tab.count + 1) := x_matched_detail_rec.del_detail_id_tab(p_matched_detail_index);
      --
      IF nvl(x_update_det_rec.received_qty2_tab(p_update_det_rec_idx),0) = 0 THEN
      --{
        x_update_det_rec.received_qty2_tab(p_update_det_rec_idx) := null;
      --}
      END IF;

      open l_del_det_wv_flag_csr(x_matched_detail_rec.del_detail_id_tab(p_matched_detail_index));
      fetch l_del_det_wv_flag_csr into
                              l_det_gr_weight,
                              l_det_net_weight,
                              l_det_volume,
                              l_det_wv_frozen_flag;
      close l_del_det_wv_flag_csr;
      IF (l_det_wv_frozen_flag = 'Y') THEN
      --{
        l_qty_ratio := x_matched_detail_rec.received_qty_tab(p_matched_detail_index)/x_matched_detail_rec.received_qty_db_tab(p_matched_detail_index);
        x_update_det_rec.wv_changed_flag_tab(p_update_det_rec_idx) := 'Y';
        x_update_det_rec.gross_weight_tab(p_update_det_rec_idx) := ROUND(l_qty_ratio*l_det_gr_weight,5);
        x_update_det_rec.net_weight_tab(p_update_det_rec_idx) := ROUND(l_qty_ratio*l_det_net_weight,5);
        x_update_det_rec.volume_tab(p_update_det_rec_idx) := ROUND(l_qty_ratio*l_det_volume,5);
      --}
      END IF;
      open  l_delivery_id_csr(x_matched_detail_rec.del_detail_id_tab(p_matched_detail_index));
      fetch l_delivery_id_csr into l_delivery_id;
      close l_delivery_id_csr;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_CACHED_VALUE',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      wsh_util_core.get_cached_value(
        p_cache_tbl     => g_del_cache_tbl,
        p_cache_ext_tbl => g_del_ext_cache_tbl,
        p_value         => l_delivery_id,
        p_key           => l_delivery_id,
        p_action        => 'GET',
        x_return_status => l_return_status);

      IF l_return_status IN (wsh_util_core.g_ret_sts_error, wsh_util_core.g_ret_sts_unexp_error) THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (l_return_status = wsh_util_core.g_ret_sts_warning) THEN
      --{
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_CACHED_VALUE',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.get_cached_value(
          p_cache_tbl     => g_del_cache_tbl,
          p_cache_ext_tbl => g_del_ext_cache_tbl,
          p_value         => l_delivery_id,
          p_key           => l_delivery_id,
          p_action        => 'PUT',
          x_return_status => l_return_status);

        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Return Status after calling wsh_util_core.get_cached_value for put is',l_return_status);
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.api_post_call(
          p_return_status    => l_return_status,
          x_num_warnings     => l_num_warnings,
          x_num_errors       => l_num_errors);

        x_delivery_id_tab(x_delivery_id_tab.count+1) := l_delivery_id;
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'After assigning the value');
        END IF;
        IF (l_det_wv_frozen_flag = 'Y') THEN
          x_wv_recalc_del_id_tab(x_wv_recalc_del_id_tab.count+1) := l_delivery_id;
        END IF;
      --}
      END IF;
    --}
    END IF;
  --}
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'At the end - update recs recevied quantity ',x_update_det_rec.received_qty_tab(p_update_det_rec_idx));
    WSH_DEBUG_SV.log(l_module_name,'At the end - update recs record_changed_flag ',x_update_det_rec.record_changed_flag_tab(p_update_det_rec_idx));
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  EXCEPTION
  --{
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO PROCESS_RCV;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO PROCESS_RCV;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
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
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --
    WHEN OTHERS THEN
      ROLLBACK TO PROCESS_RCV;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_IB_UI_RECON_GRP.PROCESS_RCV');
  --}
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
  END IF;
  --
  END process_rcv;

--========================================================================
-- PROCEDURE : Process_Rtv             This procedure is called from
--                                     process_corrections_and_rtv
--                                     to handle the rtv and rtv corrections
--                                     (both positive and negative).
--
-- PARAMETERS: x_matched_detail_rec    Record that contains the info about
--                                     all the matched delivery details.
--             p_matched_detail_index  Index of x_matched_detail_rec on
--                                     which we need to process
--                                     the rtv quantities.
--             x_update_det_rec        Record that we finally use to update
--                                     wsh_delivery_details after processing
--                                     the rtv quantities.
--             p_update_det_rec_idx    Index of x_update_det_rec on
--                                     which we need to process
--                                     the rtv quantities.
--             x_rem_req_qty_rec       Record to collect the remaining
--                                     requested quantity after processing
--                                     each record in the x_matched_detail_rec.
--             x_return_status         Return status of the API.

-- COMMENT   : This procedure is used to mainly assign the updated returned
--             quantities from x_matched_detail_rec for each delivery detail
--             to x_update_det_rec correspondingly as this x_update_det_rec
--             is finally used to perform a bulk update on wsh_delivery_details
--             in the procedure process_corrections_and_rtv.
--
--========================================================================

  PROCEDURE process_rtv (
    x_matched_detail_rec in out NOCOPY WSH_IB_UI_RECON_GRP.asn_rcv_del_det_rec_type,
    p_matched_detail_index IN NUMBER,
    x_update_det_rec IN OUT NOCOPY update_detail_rec_type,
    p_update_det_rec_idx IN NUMBER,
    x_rem_req_qty_rec IN OUT NOCOPY rem_req_qty_rec_type,
    x_return_status OUT NOCOPY VARCHAR2)
  IS
  --{

  l_num_errors    NUMBER;
  l_num_warnings  NUMBER;
  l_msg_data      VARCHAR2(32767);
  l_msg_count     NUMBER;
  l_return_status VARCHAR2(1);
  --}
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PROCESS_RTV';
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
        --
        WSH_DEBUG_SV.log(l_module_name,'P_MATCHED_DETAIL_INDEX',P_MATCHED_DETAIL_INDEX);
        WSH_DEBUG_SV.log(l_module_name,'P_UPDATE_DET_REC_IDX',P_UPDATE_DET_REC_IDX);
        WSH_DEBUG_SV.log(l_module_name,'returned_qty',x_matched_detail_rec.returned_qty_tab(p_matched_detail_index));
        WSH_DEBUG_SV.log(l_module_name,'returned_qty_db',x_matched_detail_rec.returned_qty_db_tab(p_matched_detail_index));
    END IF;
    --
    x_return_status := wsh_util_core.g_ret_sts_success;
    IF x_matched_detail_rec.returned_qty_tab(p_matched_detail_index) < 0 THEN
    --{
      FND_MESSAGE.SET_NAME('WSH','WSH_UI_NEGATIVE_QTY');
      x_return_status := wsh_util_core.g_ret_sts_error;
      wsh_util_core.add_message(x_return_status, l_module_name);
      RAISE FND_API.G_EXC_ERROR;
    --}
    END IF;
    IF nvl(x_matched_detail_rec.returned_qty_db_tab(p_matched_detail_index),0) <> nvl(x_matched_detail_rec.returned_qty_tab(p_matched_detail_index),0) THEN
    --{
      x_update_det_rec.returned_qty_tab(p_update_det_rec_idx) := x_matched_detail_rec.returned_qty_tab(p_matched_detail_index);

      x_update_det_rec.returned_qty2_tab(p_update_det_rec_idx) := x_matched_detail_rec.returned_qty2_tab(p_matched_detail_index);

      x_rem_req_qty_rec.requested_quantity := nvl(x_rem_req_qty_rec.requested_quantity,0) + (nvl(x_matched_detail_rec.returned_qty_tab(p_matched_detail_index),0) - nvl(x_matched_detail_rec.returned_qty_db_tab(p_matched_detail_index),0));
      x_rem_req_qty_rec.requested_quantity_uom := x_matched_detail_rec.requested_qty_uom_tab(p_matched_detail_index);

      IF x_matched_detail_rec.requested_qty2_tab(p_matched_detail_index) IS NOT NULL THEN
      --{
        x_rem_req_qty_rec.requested_quantity2 := nvl(x_rem_req_qty_rec.requested_quantity2,0) +
        (nvl(x_matched_detail_rec.returned_qty2_tab(p_matched_detail_index),0) -
        nvl(x_matched_detail_rec.returned_qty2_db_tab(p_matched_detail_index),0));
        x_rem_req_qty_rec.requested_quantity2_uom:= x_matched_detail_rec.requested_qty_uom2_tab(p_matched_detail_index);
      --}
      END IF;
      IF (nvl(x_update_det_rec.returned_qty_tab(p_update_det_rec_idx), 0) = 0) THEN
      --{
        x_update_det_rec.returned_qty_tab(p_update_det_rec_idx) := null;
      --}
      END IF;
      --
      IF (nvl(x_update_det_rec.returned_qty2_tab(p_update_det_rec_idx), 0) = 0) THEN
      --{
        x_update_det_rec.returned_qty2_tab(p_update_det_rec_idx) := null;
      --}
      END IF;
      x_update_det_rec.record_changed_flag_tab(p_update_det_rec_idx) := 'Y';
    --}
    END IF;

  --}
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'remaining req quantity',x_rem_req_qty_rec.requested_quantity);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  EXCEPTION
  --{
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
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
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_IB_UI_RECON_GRP.PROCESS_RTV');
  --}
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
  END IF;
  --
  END process_rtv;

--========================================================================
-- PROCEDURE : Process_Corrections_And_Rtv --
--                                    This procedure is called from
--                                    both Inbound Reconciliation UI and
--                                    Matching Algorithm to match the
--                                    Corrections and RTV transactions.
--
-- PARAMETERS: p_api_version           Known api version error number
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             p_rtv_corr_in_rec       global line rec type (not used)
--             p_matched_detail_rec    record of matched delivery details
--             p_action_prms           action parameters record type
--             p_rtv_corr_out_rec      output record of the API (not used)
--             x_po_cancel_rec         output record of cancelled po lines
--             x_po_close_rec          output record of closed po lines
--             x_msg_data              text of messages
--             x_msg_count             number of messages in the list
--             x_return_status         return status of the API

-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This procedure is used to match the child transactions
--             (Receipt Corrections, RTV, and RTV corrections) of a Receipt.
--             This procedure is the main procedure to handle the correctios
--             and rtvs for receipt transactions.
--             The following is the flow of this procedure -
--             1. We initially loop through the p_matched_detail_rec
--                and update the l_update_det_rec with the
--                new received quantities and returned quantities for each
--                delivery detail by calling Process_Rcv and Process_Rtv.
--             2. For each record in p_matched_detail_rec, we also calculate
--                the remaining requested quantity and acculumate the quantity
--                until there is a change in the po_line_location_id and then
--                if this quantity <> 0 for the corresponding
--                po_line_location_id, then we call the procedure
--                Process_remaining_req_quantity.
--             3. Then we perform a bulk update on wsh_delivery_details
--                to update the new received and returned quantities
--             4. If there are any delivery details for which there was
--                a complete receipt correction (i.e. received quantity
--                becomes null or zero), then we call
--                WSH_DELIVERY_DETAILS_ACTIONS.Unassign_Multiple_Details
--                to unassign those lines from the delivery.
--             5. If there were any lines for which there was a receipt
--                correction, we call WSH_WV_UTILS.Detail_Weight_Volume
--                to re-calculate the wt-vol of the lines.
--             6. Similary if there were any lines for which there was a
--                receipt correction, then we get the corresponding deliveries
--                and then call the APIs
--                WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required
--                and WSH_INBOUND_UTIL_PKG.reRateDeliveries to set the
--                reprice_required flag and to re-rate the deliveries.
--             7. Then we loop through the p_matched_detail_rec
--                and for each po_line_location_id we call the API
--                PO_FTE_INTEGRATION_GRP.po_status_check to check the line's
--                status and assign the line to x_po_close_rec
--                or x_po_cancel_rec depending on the status of the line
--                and pass them as out parameters to the calling procedure
--                so the calling program either call cancel_po or close_po
--                accordingly.
--             8. Then we handle the return status.
--========================================================================

  PROCEDURE process_corrections_and_rtv (
              p_rtv_corr_in_rec IN OE_WSH_BULK_GRP.Line_rec_type,
              p_matched_detail_rec IN OUT NOCOPY WSH_IB_UI_RECON_GRP.asn_rcv_del_det_rec_type,
              p_action_prms      IN WSH_BULK_TYPES_GRP.action_parameters_rectype,
              p_rtv_corr_out_rec OUT NOCOPY corr_rtv_out_rec_type,
              x_po_cancel_rec OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
              x_po_close_rec  OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
              x_msg_data      OUT NOCOPY VARCHAR2,
              x_msg_count     OUT NOCOPY NUMBER,
              x_return_status OUT NOCOPY VARCHAR2)
  IS
  --{

    l_index NUMBER;
    l_update_det_rec update_detail_rec_type;
    l_update_det_rec_idx NUMBER := -1;
    l_rem_req_qty_rec rem_req_qty_rec_type;

    l_prev_po_line_loc_id NUMBER;
    l_prev_po_line_id NUMBER;

    l_delivery_id_tab wsh_util_core.id_tab_type;
    l_fob_code_tab    wsh_util_core.Column_tab_type;
    l_fr_terms_code_tab    wsh_util_core.Column_tab_type;

    l_return_status VARCHAR2(1);
    l_msg_data      VARCHAR2(32767);
    l_msg_count     NUMBER;
    l_num_errors    NUMBER;
    l_num_warnings  NUMBER;
    l_delivery_id   NUMBER;

    l_del_action_prms WSH_DELIVERIES_GRP.action_parameters_rectype;
    l_del_action_out_rec WSH_DELIVERIES_GRP.Delivery_Action_Out_Rec_Type;


    -- This is not used any more.  Was added in the beginning.
    cursor l_del_det_fob_chk_csr(p_delivery_id NUMBER) is
    select 'N'
    from   wsh_delivery_assignments_v wda,
           wsh_delivery_details wdd1,
           wsh_delivery_details wdd2
    where  wda.delivery_id = p_delivery_id
    and    wda.delivery_detail_id = wdd1.delivery_detail_id
    and    wda.delivery_detail_id = wdd2.delivery_detail_id
    and    (wdd1.fob_code is null
            or wdd2.fob_code is null
            or wdd1.fob_code <> wdd2.fob_code)
    and    rownum =1;

    -- This is not used any more.  Was added in the beginning.
    cursor l_del_det_fr_terms_chk_csr(p_delivery_id NUMBER) is
    select 'N'
    from   wsh_delivery_assignments_v wda,
           wsh_delivery_details wdd1,
           wsh_delivery_details wdd2
    where  wda.delivery_id = p_delivery_id
    and    wda.delivery_detail_id = wdd1.delivery_detail_id
    and    wda.delivery_detail_id = wdd2.delivery_detail_id
    and    (wdd1.freight_terms_code is null
            or wdd2.freight_terms_code is null
            or wdd1.freight_terms_code <> wdd2.freight_terms_code)
    and    rownum =1;

    -- This is not used any more.  Was added in the beginning.
    cursor l_del_det_fr_term_fob_csr (p_delivery_id NUMBER) is
    select wdd.freight_terms_code, wdd.fob_code
    from   wsh_delivery_assignments_v wda,
           wsh_delivery_details wdd
    where  wda.delivery_id = p_delivery_id
    and    wda.delivery_detail_id = wdd.delivery_detail_id
    and    rownum =1;

    l_distinct_fob_found VARCHAR2(1) := 'Y';
    l_distinct_fr_terms_found VARCHAR2(1) := 'Y';

    l_fob_code VARCHAR2(32767);
    l_fr_terms_code VARCHAR2(32767);

    l_fob_fr_terms_csr_open_flag VARCHAR2(1) := 'N';
    l_fob_fr_terms_changed_tab wsh_util_core.Column_tab_type;
    i  NUMBER;


    l_unassign_det_tbl wsh_util_core.id_tab_type;
    l_po_line_loc_tbl wsh_util_core.id_tab_type;
    l_wv_detail_tab wsh_util_core.id_tab_type;

    -- cursor to check the lpns obtained from process_rcv
    -- still have any delivery lines in them or not.
    -- If they do not have any delivery lines, then
    -- they are eligible to be deleted.
    cursor l_chk_lpn_empty_csr(p_del_det_id IN NUMBER) is
    select 'N'
    from wsh_delivery_assignments_v
    where parent_delivery_detail_id = p_del_det_id
    and rownum=1;

    l_lpn_empty_flag VARCHAR2(10);
    l_unassigned_lpn_id_tab  wsh_util_core.id_tab_type;
    l_delete_lpn_id_tab  wsh_util_core.id_tab_type;
    l_wv_recalc_del_id_tab  wsh_util_core.id_tab_type;

    l_line_rec OE_WSH_BULK_GRP.line_rec_type;
    -- the following variables are defined for caching the po line location id
    l_po_line_loc_cache_tbl wsh_util_core.key_value_tab_type;
    l_po_line_loc_ext_cache_tbl wsh_util_core.key_value_tab_type;

    --l_cancel_line_rec OE_WSH_BULK_GRP.line_rec_type;
    --l_close_line_rec OE_WSH_BULK_GRP.line_rec_type;
    l_action_prms  WSH_BULK_TYPES_GRP.action_parameters_rectype;
    l_po_status_rec PO_STATUS_REC_TYPE;
    l_unassign_action_prms wsh_glbl_var_strct_grp.dd_action_parameters_rec_type;
    l_pr_rem_in_rec  WSH_RCV_CORR_RTV_TXN_PKG.action_in_rec_type;

    l_po_action_prms WSH_BULK_TYPES_GRP.action_parameters_rectype;
    l_dd_list WSH_PO_CMG_PVT.dd_list_type;

    -- Variable to store the last record to be processed in p_matched_detail_rec
    l_last_valid_det_index NUMBER;
  --}
  --
  l_dbi_rs                      VARCHAR2(1); -- Return Status from DBI API
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PROCESS_CORRECTIONS_AND_RTV';
  --
  l_rcv_qty NUMBER;
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
    SAVEPOINT process_corrections_and_rtv;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    --l_index := p_matched_detail_rec.del_detail_id_tab.first;
    --l_prev_po_line_loc_id := p_matched_detail_rec.po_line_location_id_tab(l_index);
    l_rem_req_qty_rec.requested_quantity := 0;

    l_update_det_rec_idx := l_update_det_rec.del_det_id_tab.count;

    g_del_cache_tbl.delete;
    g_del_ext_cache_tbl.delete;

    for l_index in p_matched_detail_rec.del_detail_id_tab.first..p_matched_detail_rec.del_detail_id_tab.last loop
    --{
      IF (p_matched_detail_rec.process_corr_rtv_flag_tab(l_index) = 'Y') THEN
      --{
        -- remember the l_update_det_rec_idx was initialized with -1
        l_update_det_rec_idx := l_update_det_rec_idx + 1;

        l_update_det_rec.del_det_id_tab(l_update_det_rec_idx) := p_matched_detail_rec.del_detail_id_tab(l_index);

        l_update_det_rec.requested_qty_tab(l_update_det_rec_idx) := p_matched_detail_rec.requested_qty_tab(l_index);

        l_update_det_rec.shipped_qty_tab(l_update_det_rec_idx) := p_matched_detail_rec.shipped_qty_tab(l_index);

        l_update_det_rec.received_qty_tab(l_update_det_rec_idx) := p_matched_detail_rec.received_qty_tab(l_index);

        l_update_det_rec.returned_qty_tab(l_update_det_rec_idx) := p_matched_detail_rec.returned_qty_tab(l_index);

        l_update_det_rec.requested_qty2_tab(l_update_det_rec_idx) := p_matched_detail_rec.requested_qty2_tab(l_index);

        l_update_det_rec.shipped_qty2_tab(l_update_det_rec_idx) := p_matched_detail_rec.shipped_qty2_tab(l_index);

        l_update_det_rec.received_qty2_tab(l_update_det_rec_idx) := p_matched_detail_rec.received_qty2_tab(l_index);

        l_update_det_rec.returned_qty2_tab(l_update_det_rec_idx) := p_matched_detail_rec.returned_qty2_tab(l_index);
        l_update_det_rec.shipment_line_id_tab(l_update_det_rec_idx) := p_matched_detail_rec.shipment_line_id_tab(l_index);
        --l_update_det_rec.released_sts_tab(l_update_det_rec_idx) :=  null;
        l_update_det_rec.record_changed_flag_tab(l_update_det_rec_idx) :=  'N';
        l_update_det_rec.wv_changed_flag_tab(l_update_det_rec_idx) :=  'N';
        l_update_det_rec.net_weight_tab(l_update_det_rec_idx) := null;
        l_update_det_rec.gross_weight_tab(l_update_det_rec_idx) := null;
        l_update_det_rec.volume_tab(l_update_det_rec_idx)       := null;

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'requested qty(' || l_update_det_rec_idx|| ')', l_update_det_rec.requested_qty_tab(l_update_det_rec_idx));
          WSH_DEBUG_SV.log(l_module_name,'received qty(' || l_update_det_rec_idx|| ')', l_update_det_rec.received_qty_tab(l_update_det_rec_idx));
          WSH_DEBUG_SV.log(l_module_name,'returned qty(' || l_update_det_rec_idx|| ')', l_update_det_rec.returned_qty_tab(l_update_det_rec_idx));
          WSH_DEBUG_SV.log(l_module_name,'Shipped qty(' || l_update_det_rec_idx|| ')', l_update_det_rec.shipped_qty_tab(l_update_det_rec_idx));
        END IF;

        --  Here we compare if the requested quantity for a given
        --  po_line_location_id is not equal to zero or not.  If yes,
        --  then we also make sure that we have accumalated the requested
        --  quantity for that po_line_location_id completely and we verify
        --  that by checking if the po_line_location_id has changed or not.
        --  If yes, then we need to process that quantity to be applied
        --  onto the open delivery details.
        IF (l_rem_req_qty_rec.requested_quantity <>0) AND nvl(l_prev_po_line_loc_id,-9999) <>nvl(p_matched_detail_rec.po_line_location_id_tab(l_index), -9999) THEN
        --{
          l_rem_req_qty_rec.po_line_location_id := l_prev_po_line_loc_id;
          l_rem_req_qty_rec.po_line_id := l_prev_po_line_id;
          Process_remaining_req_quantity (
            p_rem_req_qty_rec    => l_rem_req_qty_rec,
            p_in_rec             => l_pr_rem_in_rec,
            x_return_status      => l_return_status);
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          wsh_util_core.api_post_call(
            p_return_status    => l_return_status,
            x_num_warnings     => l_num_warnings,
            x_num_errors       => l_num_errors);

          -- Initializing it back to 0 so that the subsequent process should not get affected.
          l_rem_req_qty_rec.requested_quantity  := 0;
          l_rem_req_qty_rec.requested_quantity2 := 0;
        --}
        END IF;


        IF nvl(p_action_prms.action_code, 'RECEIPT') IN ('RECEIPT_CORRECTION', 'RECEIPT_CORRECTION_NEGATIVE', 'RECEIPT_CORRECTION_POSITIVE', 'RECEIPT') THEN
        --{
          process_rcv (
            x_matched_detail_rec       => p_matched_detail_rec,
            p_matched_detail_index     => l_index,
            x_update_det_rec           => l_update_det_rec,
            p_update_det_rec_idx       => l_update_det_rec_idx,
            x_rem_req_qty_rec          => l_rem_req_qty_rec,
            x_unassign_det_tbl         => l_unassign_det_tbl,
            x_po_line_loc_tbl          => l_po_line_loc_tbl,
            x_delivery_id_tab          => l_delivery_id_tab,
            x_wv_detail_tab            => l_wv_detail_tab,
            x_unassigned_lpn_id_tab    => l_unassigned_lpn_id_tab,
            x_wv_recalc_del_id_tab     => l_wv_recalc_del_id_tab,
            x_return_status            => l_return_status);

          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          wsh_util_core.api_post_call(
            p_return_status    => l_return_status,
            x_num_warnings     => l_num_warnings,
            x_num_errors       => l_num_errors);
        --}
        END IF;

        IF nvl(p_action_prms.action_code, 'RECEIPT') IN ( 'RTV_CORRECTION', 'RTV_CORRECTION_NEGATIVE','RTV_CORRECTION_POSITIVE', 'RTV','RECEIPT') THEN
        --{
          process_rtv (
            x_matched_detail_rec       => p_matched_detail_rec,
            p_matched_detail_index     => l_index,
            x_update_det_rec           => l_update_det_rec,
            p_update_det_rec_idx       => l_update_det_rec_idx,
            x_rem_req_qty_rec          => l_rem_req_qty_rec,
            x_return_status            => l_return_status);

          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'Return Status',l_return_status);
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          wsh_util_core.api_post_call(
            p_return_status    => l_return_status,
            x_num_warnings     => l_num_warnings,
            x_num_errors       => l_num_errors);
        --}
        END IF;

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Before assigning the value to l_prev_po_line_loc_id');
        END IF;
        l_prev_po_line_loc_id := p_matched_detail_rec.po_line_location_id_tab(l_index);
        l_prev_po_line_id := p_matched_detail_rec.po_line_id_tab(l_index);
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'After assigning the value to l_prev_po_line_loc_id');
          WSH_DEBUG_SV.log(l_module_name,'l_index', l_index);
        END IF;
        l_last_valid_det_index := l_index;
      --}
      END IF;

      --l_index := p_matched_detail_rec.del_detail_id_tab.next(l_index);
    --}
    end loop;

    IF (l_rem_req_qty_rec.requested_quantity <>0) THEN
    --{
      l_rem_req_qty_rec.po_line_location_id := p_matched_detail_rec.po_line_location_id_tab(l_last_valid_det_index);
      l_rem_req_qty_rec.po_line_id := p_matched_detail_rec.po_line_id_tab(l_last_valid_det_index);
      Process_remaining_req_quantity (
        p_rem_req_qty_rec    => l_rem_req_qty_rec,
        p_in_rec             => l_pr_rem_in_rec,
        x_return_status      => l_return_status);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors);
      l_rem_req_qty_rec.requested_quantity := 0;
      l_rem_req_qty_rec.requested_quantity2 := 0;
    --}
    END IF;
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Before doing a bulk update');
      WSH_DEBUG_SV.log(l_module_name,'received qty before the update', l_update_det_rec.received_qty_tab(1));
      WSH_DEBUG_SV.log(l_module_name,'update rec count is', l_update_det_rec.received_qty_tab.count);
      WSH_DEBUG_SV.log(l_module_name,'record_changed_flag', l_update_det_rec.record_changed_flag_tab(1));
      WSH_DEBUG_SV.log(l_module_name,'del_detid', l_update_det_rec.del_det_id_tab(1));
      WSH_DEBUG_SV.log(l_module_name,'shipped_qty_tab', l_update_det_rec.shipped_qty_tab(1));
      WSH_DEBUG_SV.log(l_module_name,'shipped_qty2_tab', l_update_det_rec.shipped_qty2_tab(1));
      WSH_DEBUG_SV.log(l_module_name,'received_qty_tab', l_update_det_rec.received_qty_tab(1));
      WSH_DEBUG_SV.log(l_module_name,'returned_qty_tab', l_update_det_rec.returned_qty_tab(1));
      WSH_DEBUG_SV.log(l_module_name,'shipment_line_id_tab', l_update_det_rec.shipment_line_id_tab(1));
      WSH_DEBUG_SV.log(l_module_name,'wv_changed_flag_tab', l_update_det_rec.wv_changed_flag_tab(1));
      WSH_DEBUG_SV.log(l_module_name,'net_weight_tab', l_update_det_rec.net_weight_tab(1));
      WSH_DEBUG_SV.log(l_module_name,'gross_weight_tab', l_update_det_rec.gross_weight_tab(1));
      WSH_DEBUG_SV.log(l_module_name,'volume_tab', l_update_det_rec.volume_tab(1));
    END IF;
    forall i in l_update_det_rec.del_det_id_tab.first..l_update_det_rec.del_det_id_tab.last
      update wsh_delivery_details
      set requested_quantity      = l_update_det_rec.requested_qty_tab(i),
          requested_quantity2     = l_update_det_rec.requested_qty2_tab(i),
          shipped_quantity        = l_update_det_rec.shipped_qty_tab(i),
          shipped_quantity2       = l_update_det_rec.shipped_qty2_tab(i),
          received_quantity       = l_update_det_rec.received_qty_tab(i),
          received_quantity2      = l_update_det_rec.received_qty2_tab(i),
          returned_quantity       = l_update_det_rec.returned_qty_tab(i),
          returned_quantity2      = l_update_det_rec.returned_qty2_tab(i),
          rcv_shipment_line_id    = l_update_det_rec.shipment_line_id_tab(i),
          net_weight              = decode(l_update_det_rec.wv_changed_flag_tab(i),
                                           'Y',
                                           l_update_det_rec.net_weight_tab(i),
                                           net_weight
                                          ),
          gross_weight            = decode(l_update_det_rec.wv_changed_flag_tab(i),
                                           'Y',
                                           l_update_det_rec.gross_weight_tab(i),
                                           gross_weight
                                          ),
          volume                  = decode(l_update_det_rec.wv_changed_flag_tab(i),
                                           'Y',
                                           l_update_det_rec.volume_tab(i),
                                           volume
                                          ),
          last_update_date        = sysdate,
          last_updated_by         = fnd_global.user_id,
          last_update_login       = fnd_global.user_id
       where l_update_det_rec.record_changed_flag_tab(i) = 'Y'
       and   delivery_detail_id   = l_update_det_rec.del_det_id_tab(i);


    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'After the bulk update');
      WSH_DEBUG_SV.log(l_module_name,'Number of Records updated', SQL%ROWCOUNT);
    END IF;

    --
    -- DBI Project
    -- Update of wsh_delivery_details where requested_quantity/released_status
    -- are changed, call DBI API after the update.
    -- DBI API will check if DBI is installed
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Detail Count-',l_update_det_rec.del_det_id_tab.count);
    END IF;
    WSH_INTEGRATION.DBI_Update_Detail_Log
      (p_delivery_detail_id_tab => l_update_det_rec.del_det_id_tab,
       p_dml_type               => 'UPDATE',
       x_return_status          => l_dbi_rs);

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
    END IF;
    -- Only Handle Unexpected error
    IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_dbi_rs;
      ROLLBACK TO process_corrections_and_rtv;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
    END IF;
    -- End of Code for DBI Project
    --

    --  The l_unassign_det_tbl contains the list of delivery details
    --  for which there was a complete receipt negative correction
    --  and therefore, we need to unassign these delivery details
    --  from their respective deliveries.

    IF ( l_unassign_det_tbl.count > 0 ) THEN
    --{
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.UNASSIGN_MULTIPLE_DETAILS',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      l_unassign_action_prms.caller := wsh_util_core.C_IB_RECEIPT_PREFIX;
      WSH_DELIVERY_DETAILS_ACTIONS.Unassign_Multiple_Details(
        P_REC_OF_DETAIL_IDS    => l_unassign_det_tbl,
        P_FROM_delivery        => 'Y',
        P_FROM_container       => 'N',
        x_return_status        =>  l_return_status,
        p_validate_flag        =>  'Y',
        p_action_prms          =>  l_unassign_action_prms);





      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors);


       -- Need to go through the l_unassigned_lpn_id_tab and delete them
       -- if they do not have any delivery lines associated.
       IF (l_unassigned_lpn_id_tab.count > 0) THEN
       --{
         i := l_unassigned_lpn_id_tab.first;
         WHILE i IS NOT NULL LOOP
         --{
           l_lpn_empty_flag := null;
           open  l_chk_lpn_empty_csr(l_unassigned_lpn_id_tab(i));
           fetch l_chk_lpn_empty_csr into l_lpn_empty_flag;
           close l_chk_lpn_empty_csr;
           IF nvl(l_lpn_empty_flag,'Y') = 'Y' THEN -- delete the lpn
           --{
             l_delete_lpn_id_tab(l_delete_lpn_id_tab.count + 1) := l_unassigned_lpn_id_tab(i);
           --}
           END IF;
           i := l_unassigned_lpn_id_tab.NEXT(i);
         --}
         END LOOP;

         IF (l_delete_lpn_id_tab.count > 0) THEN
         --{
           FORALL i IN l_delete_lpn_id_tab.FIRST..l_delete_lpn_id_tab.LAST
           DELETE wsh_delivery_assignments_v
           WHERE  delivery_detail_id = l_delete_lpn_id_tab(i);

           IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'SQL%ROWCOUNT After deleting LPNs from WDA',SQL%ROWCOUNT);
           END IF;

           --Deleting the rows in WSH_DELIVERY_DETAILS corresponding to the selected LPNs.
           FORALL i IN l_delete_lpn_id_tab.FIRST..l_delete_lpn_id_tab.LAST
           DELETE WSH_DELIVERY_DETAILS
           WHERE  delivery_detail_id = l_delete_lpn_id_tab(i);

           IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'SQL%ROWCOUNT After deleting LPNs from WDD',SQL%ROWCOUNT);
           END IF;
         --}
         END IF;

       --}
       END IF;
      -- since the delivery details in l_unassign_det_tbl are being re-opened and unassigned,
      -- we need to update these lines with the latest attributes from PO.
      -- l_dd_list needs to be populated to finally call Reapprove_PO.

      FOR i in l_unassign_det_tbl.FIRST..l_unassign_det_tbl.LAST LOOP
      --{
        l_dd_list.po_shipment_line_id.extend;
        l_dd_list.delivery_detail_id.extend;
        l_dd_list.po_shipment_line_id(l_dd_list.po_shipment_line_id.count) := l_po_line_loc_tbl(i);
        l_dd_list.delivery_detail_id(l_dd_list.delivery_detail_id.count)   := l_unassign_det_tbl(i);
      --}
      END LOOP;
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_PO_CMG_PVT.REAPPROVE_PO',WSH_DEBUG_SV.C_PROC_LEVEL);
        WSH_DEBUG_SV.log(l_module_name,'l_dd_list.COUNT',l_dd_list.po_shipment_line_id.COUNT);
      END IF;
      l_po_action_prms.action_code := 'CANCEL_ASN';
      l_po_action_prms.caller := 'WSH_RCV_CORR_RTV';
      IF (l_dd_list.po_shipment_line_id.COUNT > 0 ) THEN
      --{
        WSH_PO_CMG_PVT.Reapprove_PO(
          p_line_rec           => l_line_rec,
          p_action_prms        => l_po_action_prms,
          p_dd_list            => l_dd_list,
          x_return_status      => l_return_status);

        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Return Status after calling Reapprove_PO is ', l_return_status);
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.api_post_call(
          p_return_status    => l_return_status,
          x_num_warnings     => l_num_warnings,
          x_num_errors       => l_num_errors);
        --
      --}
      END IF;
    --}
    END IF;
    IF (l_wv_detail_tab.count > 0 ) THEN
    --{
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.DETAIL_WEIGHT_VOLUME',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      WSH_WV_UTILS.Detail_Weight_Volume(
        p_detail_rows    => l_wv_detail_tab,
        p_override_flag  => 'Y',
        p_calc_wv_if_frozen => 'N',
        x_return_status     => l_return_status);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors);

    --}
    END IF;

    IF(l_wv_recalc_del_id_tab.count > 0) THEN
    --{
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.DELIVERY_WEIGHT_VOLUME',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      WSH_WV_UTILS.Delivery_Weight_Volume(
        p_del_rows          => l_wv_recalc_del_id_tab,
        p_update_flag       => 'Y',
        p_calc_wv_if_frozen => 'N',
        x_return_status     => l_return_status);

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors);
    --}
    END IF;

    IF (l_delivery_id_tab.count > 0 ) THEN
    --{
      -- Commented the below code because we are calling detail_weight_volume
      -- and that in turn would calculate the weight and volume of the
      -- delivery  ( and trip and trip stops if present).
      /*
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.DELIVERY_WEIGHT_VOLUME',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      WSH_WV_UTILS.Delivery_Weight_Volume(
        p_del_rows          => l_delivery_id_tab,
        p_update_flag       => 'Y',
        p_calc_wv_if_frozen => 'N',
        x_return_status     => l_return_status);

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors);
      */


      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_LEGS_ACTIONS.MARK_REPRICE_REQUIRED',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required(
        p_entity_type           => 'DELIVERY',
        p_entity_ids            => l_delivery_id_tab,
        x_return_status         => l_return_status);

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors);

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_UTIL_PKG.RERATEDELIVERIES',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      WSH_INBOUND_UTIL_PKG.reRateDeliveries(
        p_delivery_id_tab       => l_delivery_id_tab,
        x_return_status         => l_return_status);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors);
    --}
    END IF;

    for l_index in p_matched_detail_rec.del_detail_id_tab.first..p_matched_detail_rec.del_detail_id_tab.last loop
    --{
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_CACHED_VALUE',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      wsh_util_core.get_cached_value(
        p_cache_tbl     => l_po_line_loc_cache_tbl,
        p_cache_ext_tbl => l_po_line_loc_ext_cache_tbl,
        p_value         => p_matched_detail_rec.po_line_location_id_tab(l_index),
        p_key           => p_matched_detail_rec.po_line_location_id_tab(l_index),
        p_action        => 'GET',
        x_return_status => l_return_status);

        IF l_return_status IN (wsh_util_core.g_ret_sts_error, wsh_util_core.g_ret_sts_unexp_error) THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;

      IF (l_return_status = wsh_util_core.g_ret_sts_warning) THEN
      --{
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_CACHED_VALUE',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.get_cached_value(
          p_cache_tbl     => l_po_line_loc_cache_tbl,
          p_cache_ext_tbl => l_po_line_loc_ext_cache_tbl,
          p_value         => p_matched_detail_rec.po_line_location_id_tab(l_index),
          p_key           => p_matched_detail_rec.po_line_location_id_tab(l_index),
          p_action        => 'PUT',
          x_return_status => l_return_status);
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Return Status after calling wsh_util_core.get_cached_value for put is',l_return_status);
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       --
       wsh_util_core.api_post_call(
         p_return_status    => l_return_status,
         x_num_warnings     => l_num_warnings,
         x_num_errors       => l_num_errors);

       IF (PO_CODE_RELEASE_GRP.Current_Release >= PO_CODE_RELEASE_GRP.PRC_11i_Family_Pack_J)  THEN
       --{
         PO_FTE_INTEGRATION_GRP.po_status_check (
           p_api_version           => 1.0,
           p_header_id             => p_matched_detail_rec.po_header_id_tab(l_index),
           p_release_id            => NULL,
           p_document_type         => NULL,
           p_document_subtype      => NULL,
           p_document_num          => NULL,
           p_vendor_order_num      => NULL,
           p_line_id               => p_matched_detail_rec.po_line_id_tab(l_index),
           p_line_location_id      => p_matched_detail_rec.po_line_location_id_tab(l_index),
           p_distribution_id       => NULL,
           p_mode                  => 'GET_STATUS',
           p_lock_flag             => 'N',
           x_po_status_rec         => l_po_status_rec,
           x_return_status         => l_return_status);
         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_index', l_index);
           WSH_DEBUG_SV.log(l_module_name,'return_status is', l_return_status);
           WSH_DEBUG_SV.log(l_module_name,'count of l_po_status_rec.closed_code', l_po_status_rec.closed_code.count);
         END IF;
         wsh_util_core.api_post_call(
           p_return_status    => l_return_status,
           x_num_warnings     => l_num_warnings,
           x_num_errors       => l_num_errors);
         IF l_po_status_rec.closed_code.count > 0 THEN
         --{
           IF (nvl(l_po_status_rec.closed_code(l_po_status_rec.closed_code.first),'N') IN ('CLOSED', 'CLOSED FOR RECEIVING', 'FINALLY CLOSED') AND nvl(l_po_status_rec.cancel_flag(l_po_status_rec.cancel_flag.first), 'N') <> 'Y') THEN
           --{
             x_po_close_rec.po_shipment_line_id.extend;
             x_po_close_rec.line_id.extend;
             x_po_close_rec.header_id.extend;
             x_po_close_rec.source_blanket_reference_id.extend;
             x_po_close_rec.line_id(x_po_close_rec.line_id.count) := p_matched_detail_rec.po_line_id_tab(l_index);
             x_po_close_rec.po_shipment_line_id(x_po_close_rec.line_id.count) := p_matched_detail_rec.po_line_location_id_tab(l_index);
             x_po_close_rec.header_id(x_po_close_rec.line_id.count) := p_matched_detail_rec.po_header_id_tab(l_index);
           --}
           ELSIF (nvl(l_po_status_rec.cancel_flag(l_po_status_rec.cancel_flag.first), 'N') = 'Y') THEN
           --{
             x_po_cancel_rec.po_shipment_line_id.extend;
             x_po_cancel_rec.line_id.extend;
             x_po_cancel_rec.header_id.extend;
             x_po_cancel_rec.source_blanket_reference_id.extend;
             x_po_cancel_rec.line_id(x_po_cancel_rec.line_id.count) := p_matched_detail_rec.po_line_id_tab(l_index);
             x_po_cancel_rec.po_shipment_line_id(x_po_cancel_rec.line_id.count) := p_matched_detail_rec.po_line_location_id_tab(l_index);
             x_po_cancel_rec.header_id(x_po_cancel_rec.line_id.count) := p_matched_detail_rec.po_header_id_tab(l_index);
           --}
           END IF;
         --}
         END IF;
       --}
       END IF;
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'After checking for status');
       END IF;
     --}
     END IF;

    --}
    end loop;
    --

    IF l_num_warnings > 0 THEN
        RAISE WSH_UTIL_CORE.G_EXC_WARNING;
    ELSE
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    END IF;
  --}
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Return Status after calling Post_Process',l_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  EXCEPTION
  --{
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO process_corrections_and_rtv;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO process_corrections_and_rtv;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
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
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --
    WHEN OTHERS THEN
      ROLLBACK TO process_corrections_and_rtv;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_IB_UI_RECON_GRP.PROCESS_CORRECTIONS_AND_RTV');
  --}
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
  END IF;
  --
  END process_corrections_and_rtv;

--========================================================================
-- PROCEDURE : Process_Remaining_Req_Quantity --
--                                     This procedure is called from
--                                     process_corrections_and_rtv
--                                     and from revert_details to handle
--                                     the remaining requested quantity
--                                     that needs to be adjusted on open
--                                     delivery details.
--
-- PARAMETERS: p_rem_req_qty_rec       Record that stores the remaining
--                                     requested quantity after performing the
--                                     matching or after performing the revert.
--             p_in_rec                Input record to pass the action code
--                                     (possible values are "MATCH" and
--                                     "REVERT_MATCH").
--             x_return_status         Return status of the API

-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This procedure is used to handle the remaining requested
--             quantity to be update on open delivery details.
--             The following is flow of this procedure -
--             1. If the p_in_rec.action_code is 'MATCH', then we all the open
--                delivery details for which routing_req_id is null
--                else if p_in_rec.action_code is 'REVERT_MATCH', then
--                we get all the open delivery details and also the closed
--                lines for which the received_quantity is null (these lines
--                are probably closed as po might have been closed).
--                Then we collect all these lines into a table.
--             2. If the remaining requested quantity is < 0, then
--                we loop through all the delivery details and for delivery
--                we compare its req. qty with the remaining req. qty.
--                if the abs(remaining req. qty) > curr detail's req. qty
--                we delete the delivery detail and the delivery assignment
--                and decrement the remaining req. qty accordingly and we
--                we repeat this until the abs(remaining req. qty) becomes
--                less the del detail's req. qty.  Then we just update
--                that delivery detail with req. qty = (detail's req. qty
--                - abs(remaining req. qty.).
--             3. If the remaining requested quantity is > 0, then
--                we call the WSH_INBOUND_UTIL_PKG.get_po_rcv_attributes
--                to get all the latest attributes of PO and then
--                call reapprove_po to either update or create new delivery
--                lines.
--                Please refer to Appendix. 7  wsh_inbound_corr_rtv_revert_ui.rtf
--                for the examples to explain the cases handled by this API.
--========================================================================

  PROCEDURE process_remaining_req_quantity (
    p_rem_req_qty_rec IN rem_req_qty_rec_type,
    p_in_rec          IN action_in_rec_type,
    x_return_status OUT NOCOPY VARCHAR2)
  IS
  --{
    l_new_req_qty NUMBER := p_rem_req_qty_rec.requested_quantity;
    l_new_req_qty2 NUMBER := p_rem_req_qty_rec.requested_quantity2;
    l_update_rec update_detail_rec_type;
    l_update_del_det_id NUMBER;
    l_update_del_det_id_tab  wsh_util_core.id_tab_type;
    l_update_del_det_req_qty NUMBER;
    l_update_del_det_req_qty2 NUMBER;
    l_record_found BOOLEAN := TRUE;
    l_num_errors    NUMBER;
    l_msg_data      VARCHAR2(32767);
    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER;
    l_num_warnings  NUMBER;
    i NUMBER;
    l_line_rec_index NUMBER;
    l_req_qty_uom   VARCHAR2(30);
    l_ordered_quantity NUMBER;
    l_ordered_quantity2 NUMBER;
    l_action_prms WSH_BULK_TYPES_GRP.action_parameters_rectype;
    l_line_rec OE_WSH_BULK_GRP.line_rec_type;
    l_out_rec WSH_BULK_TYPES_GRP.Bulk_process_out_rec_type;
    l_header_ids wsh_util_core.id_tab_type;
    l_dd_list WSH_PO_CMG_PVT.dd_list_type;

    l_po_line_rec PO_FTE_INTEGRATION_GRP.po_release_rec_type;

    -- This cursor is used to get the open delivery details
    -- for which routing request is not sent.
    cursor l_open_del_det_csr(p_po_line_loc_id NUMBER,
                              p_source_line_id IN NUMBER) is
    select delivery_detail_id,
           requested_quantity,
           requested_quantity2
    from   wsh_delivery_details
    where  source_line_id = p_source_line_id
    and    po_shipment_line_id = p_po_line_loc_id
    and    released_status = 'X'
    and    routing_req_id is null
    and    source_code = 'PO'
    order by requested_quantity desc;
    --for update of requested_quantity nowait;

    -- This cursor is used to get the open and closed delivery details
    -- for which routing request is not sent.
    cursor l_all_del_det_csr(p_po_line_loc_id NUMBER,
                             p_source_line_id IN NUMBER) is
    select delivery_detail_id,
           requested_quantity,
           requested_quantity2
    from   wsh_delivery_details
    where  source_line_id = p_source_line_id
    and    po_shipment_line_id = p_po_line_loc_id
    and   ( released_status = 'X'
            or
            ( released_status = 'L'
              and received_quantity is null
            )
          )
    and    routing_req_id is null
    and    source_code = 'PO'
    order by requested_quantity desc,
    decode (released_status,
                           'X',1,
                           'L',2);
    --for update of requested_quantity nowait;

    -- This cursor is used to just get the uom stored on wsh_delivery_details
    -- This is not used anymore as the input record structure already has the UOMs
    -- passed.
    cursor l_del_det_uom_csr(p_po_line_loc_id NUMBER,
                             p_source_line_id IN NUMBER) is
    select requested_quantity_uom
    from   wsh_delivery_details
    where source_line_id = p_source_line_id
    and   source_code = 'PO'
    and   po_shipment_line_id = p_po_line_loc_id;

    -- For negative rtv corrections, even after updating the open or
    -- closed lines without routing request, if we are still left with
    -- some negative quantity, then, we query even the lines that had
    -- routing request, lines that were matched against ASN and lines
    -- that were matched against receipt and reduce their requested
    -- quantities to fulfill the returned quantity correction.
    -- This cursor servers this purpose.
    cursor l_rem_ret_qty_csr(p_po_line_loc_id NUMBER,
                             p_source_line_id IN NUMBER) is
    select delivery_detail_id,
           requested_quantity,
           requested_quantity2,
           'N' record_changed_flag
    from   wsh_delivery_details
    where  source_line_id = p_source_line_id
    and    po_shipment_line_id = p_po_line_loc_id
    and    released_status in ('X', 'C', 'L')
    and    source_code = 'PO'
    and    requested_quantity > 0
    order by
    decode (released_status,
                           'X',1,
                           'C',2,
                           'L',3),
           delivery_detail_id desc
    for update of requested_quantity nowait;
    --
    --
    DD_LOCKED exception;
    PRAGMA EXCEPTION_INIT(DD_LOCKED, -54);

  --}
  l_dbi_rs                      VARCHAR2(1); -- Return Status from DBI API
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PROCESS_REMAINING_REQ_QUANTITY';
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
      WSH_DEBUG_SV.log(l_module_name,'Remaining Requested Quantity is', p_rem_req_qty_rec.requested_quantity);
      WSH_DEBUG_SV.log(l_module_name,'po line location id', p_rem_req_qty_rec.po_line_location_id);
      WSH_DEBUG_SV.log(l_module_name,'po line id', p_rem_req_qty_rec.po_line_id);
    END IF;
    --
    SAVEPOINT PR_REM_REQ_QTY;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    IF nvl(p_in_rec.action_code, 'MATCH') <> 'REVERT_MATCH' THEN
    --{
      open l_open_del_det_csr(p_rem_req_qty_rec.po_line_location_id,
                              p_rem_req_qty_rec.po_line_id);

      fetch l_open_del_det_csr bulk collect into l_update_rec.del_det_id_tab,
                                               l_update_rec.requested_qty_tab,
                                               l_update_rec.requested_qty2_tab;
      close l_open_del_det_csr;
    --}
    ELSE
    --{
      open l_all_del_det_csr(p_rem_req_qty_rec.po_line_location_id,
                              p_rem_req_qty_rec.po_line_id);

      fetch l_all_del_det_csr bulk collect into l_update_rec.del_det_id_tab,
                                               l_update_rec.requested_qty_tab,
                                               l_update_rec.requested_qty2_tab;
      close l_all_del_det_csr;
    --}
    END IF;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'count of update rec tables is', l_update_rec.del_det_id_tab.COUNT);
      WSH_DEBUG_SV.log(l_module_name,'l_new_req_qty', l_new_req_qty);
    END IF;
    IF (l_update_rec.del_det_id_tab.COUNT < 1 ) THEN
    --{
      l_record_found := FALSE;
    --}
    END IF;
    IF ( l_new_req_qty > 0 ) THEN
    --{
        -- call PO's API to obtain all the attributes for the po_line_location_id
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_UTIL_PKG.GET_PO_RCV_ATTRIBUTES',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        WSH_INBOUND_UTIL_PKG.get_po_rcv_attributes(
          p_po_line_location_id => p_rem_req_qty_rec.po_line_location_id,
          p_rcv_shipment_line_id => NULL,
          x_line_rec  => l_line_rec,
          x_return_status => l_return_status);
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'return status after calling get_po_rcv_attributes', l_return_status);
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.api_post_call(
          p_return_status    => l_return_status,
          x_num_warnings     => l_num_warnings,
          x_num_errors       => l_num_errors);
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Before assigning the consolidate quantity', l_new_req_qty);
            WSH_DEBUG_SV.log(l_module_name,'l_new_req_qty2', l_new_req_qty2);
            WSH_DEBUG_SV.log(l_module_name,'req qty uom', p_rem_req_qty_rec.requested_quantity_uom);
            WSH_DEBUG_SV.log(l_module_name,'req qty uom 2', p_rem_req_qty_rec.requested_quantity2_uom);
        END IF;
        l_line_rec.consolidate_quantity.extend;
        l_line_rec.consolidate_quantity(1) := l_new_req_qty;
        l_line_rec.requested_quantity_uom(1) := p_rem_req_qty_rec.requested_quantity_uom;
        l_line_rec.requested_quantity2(1) := l_new_req_qty2;
        l_line_rec.requested_quantity_uom2(1) := p_rem_req_qty_rec.requested_quantity2_uom;
        l_action_prms.action_code := 'RECEIPT';
        l_action_prms.caller := 'WSH_RCV_CORR_RTV';
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_PO_CMG_PVT.REAPPROVE_PO',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        WSH_PO_CMG_PVT.reapprove_po(
          p_line_rec      => l_line_rec,
          p_action_prms   => l_action_prms,
          p_dd_list       => l_dd_list,
          x_return_status => l_return_status);
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Return Status after calling reapprove_po is', l_return_status);
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.api_post_call(
          p_return_status    => l_return_status,
          x_num_warnings     => l_num_warnings,
          x_num_errors       => l_num_errors);
    --}
    ELSIF ( l_new_req_qty < 0 ) THEN
    --{
      i := l_update_rec.del_det_id_tab.first;
      WHILE i is not null AND l_new_req_qty < 0 LOOP
      --{

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'i is', i);
          WSH_DEBUG_SV.log(l_module_name,'Delivery Detail Id', l_update_rec.del_det_id_tab(i));
          WSH_DEBUG_SV.log(l_module_name,'l_new_req_qty', l_new_req_qty);
          WSH_DEBUG_SV.log(l_module_name,'Delivery Detail Req Qty ', l_update_rec.requested_qty_tab(i));
          WSH_DEBUG_SV.log(l_module_name,'l_new_req_qty2', l_new_req_qty2);
          WSH_DEBUG_SV.log(l_module_name,'Delivery Detail Req Qty 2', l_update_rec.requested_qty2_tab(i));
        END IF;

        l_update_rec.record_changed_flag_tab (i) := 'N';
        IF l_update_rec.requested_qty_tab(i) > abs(l_new_req_qty) THEN
        --{
          l_update_rec.requested_qty_tab(i) := l_update_rec.requested_qty_tab(i) + l_new_req_qty;
          IF (nvl(l_new_req_qty2,0) <> 0 ) THEN
          --{
            l_update_rec.requested_qty2_tab(i) := nvl(l_update_rec.requested_qty2_tab(i),0) +
            l_new_req_qty2;

            IF (l_update_rec.requested_qty2_tab(i) < 0) THEN
            --{
              l_update_rec.requested_qty2_tab(i) := 0;
            --}
            END IF;
          --}
          END IF;

          l_update_rec.record_changed_flag_tab (i) := 'Y';
          l_new_req_qty := 0; -- so that we can go out the loop as we already
                              -- updated the remaining quantity on the lines.
          l_update_del_det_id := l_update_rec.del_det_id_tab(i);
          l_update_del_det_req_qty := l_update_rec.requested_qty_tab(i);
          l_update_del_det_req_qty2 := l_update_rec.requested_qty2_tab(i);
        --}
        ELSE -- l_update_rec.requested_qty_tab(i) <= abs(l_new_req_qty)
        --{
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_PKG.LOCK_DETAIL_NO_COMPARE',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          wsh_delivery_details_pkg.Lock_Detail_No_Compare(
            p_delivery_detail_id => l_update_rec.del_det_id_tab(i));

          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_PKG.DELETE_DELIVERY_DETAILS',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          wsh_delivery_details_pkg.delete_delivery_details(
            p_delivery_detail_id => l_update_rec.del_det_id_tab(i),
            x_return_status      => l_return_status);
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          wsh_util_core.api_post_call(
            p_return_status    => l_return_status,
            x_num_warnings     => l_num_warnings,
            x_num_errors       => l_num_errors);

          l_new_req_qty := l_new_req_qty + l_update_rec.requested_qty_tab(i);
          IF (l_update_rec.requested_qty2_tab(i) IS NOT NULL) THEN
          --{
            l_new_req_qty2 := l_new_req_qty2 + l_update_rec.requested_qty2_tab(i);
            IF (l_new_req_qty2 > 0) THEN
            --{
              l_new_req_qty2 := 0;
            --}
            END IF;
          --}
          END IF;

        --}
        END IF;
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'l_new_req_qty at the end of processing the current record ', l_new_req_qty);
          WSH_DEBUG_SV.log(l_module_name,'Record Changed flag for the current record is', l_update_rec.record_changed_flag_tab(i));
        END IF;

        i := l_update_rec.del_det_id_tab.NEXT(i);
        /*
        IF NOT (l_update_rec.del_det_id_tab(i).EXISTS) THEN
        --{
          l_new_req_qty := 0; -- so that we can exit the loop.
        --}
        END IF;
        */
        --}
      END LOOP;
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Before performing the update');
        WSH_DEBUG_SV.log(l_module_name,'Delivery Detail Id is ', l_update_del_det_id);
      END IF;

      IF l_update_del_det_id IS NOT NULL THEN
      --{
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_PKG.LOCK_DETAIL_NO_COMPARE',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_delivery_details_pkg.Lock_Detail_No_Compare(
          p_delivery_detail_id => l_update_del_det_id);
        -- we need to update atmost one record.
        update wsh_delivery_details
        set requested_quantity  = l_update_del_det_req_qty,
            requested_quantity2 = nvl(l_update_del_det_req_qty2,requested_quantity2),
            last_update_date        = sysdate,
            last_updated_by         = fnd_global.user_id,
            last_update_login       = fnd_global.user_id
         where delivery_detail_id = l_update_del_det_id;
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'After the update');
        END IF;
        --
        l_update_del_det_id_tab(1) := l_update_del_det_id;

        --
        -- DBI Project
        -- Update of wsh_delivery_details where requested_quantity/released_status
        -- are changed, call DBI API after the update.
        -- DBI API will check if DBI is installed
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Detail Count-', l_update_del_det_id_tab.count);
        END IF;
        WSH_INTEGRATION.DBI_Update_Detail_Log
          (p_delivery_detail_id_tab =>  l_update_del_det_id_tab,
           p_dml_type               => 'UPDATE',
           x_return_status          => l_dbi_rs);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
        END IF;
        -- Only Handle Unexpected error
        IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
          --
          x_return_status := l_dbi_rs;
          ROLLBACK TO PR_REM_REQ_QTY;
          IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          --
          RETURN;
        END IF;
        -- End of Code for DBI Project
        --
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Need to recalculate weight and volume for del detail --- ',l_update_del_det_id);
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.DETAIL_WEIGHT_VOLUME',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        WSH_WV_UTILS.Detail_Weight_Volume(
          p_detail_rows    => l_update_del_det_id_tab,
          p_override_flag  => 'Y',
          p_calc_wv_if_frozen => 'N',
          x_return_status     => l_return_status);
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.api_post_call(
          p_return_status    => l_return_status,
          x_num_warnings     => l_num_warnings,
          x_num_errors         => l_num_errors);
        --
        -- Nullifying the value so that it is not used again.
        l_update_del_det_id := NULL;

      --}
      END IF;
      --
      --
      --  This logic is added for rtv negative correction
      --  where when we have some more left over quantity that still
      --  needs to be corrected on the other delivery lines.
      IF nvl(p_in_rec.action_code, 'MATCH') <> 'REVERT_MATCH'
      AND l_new_req_qty < 0 THEN
      --{
        l_update_rec.del_det_id_tab.delete;
        l_update_rec.requested_qty_tab.delete;
        l_update_rec.requested_qty2_tab.delete;
        open  l_rem_ret_qty_csr(p_rem_req_qty_rec.po_line_location_id,
                                p_rem_req_qty_rec.po_line_id);

        fetch l_rem_ret_qty_csr bulk collect into l_update_rec.del_det_id_tab,
                                                 l_update_rec.requested_qty_tab,
                                                 l_update_rec.requested_qty2_tab,
                                                 l_update_rec.record_changed_flag_tab;
        close l_rem_ret_qty_csr;
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Need to recalculate weight and volume for del detail --- ',l_update_del_det_id);
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.DETAIL_WEIGHT_VOLUME',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        -- This loop is exact repetition (except for the deletes) of the above loop
        -- but since this is just to take care of a corner
        -- case, we are repeating the code.
        -- This must be cleaned up in next release.
        i := l_update_rec.del_det_id_tab.first;
        WHILE i is not null AND l_new_req_qty < 0 LOOP
        --{

          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'i is', i);
            WSH_DEBUG_SV.log(l_module_name,'Delivery Detail Id ('||i||')', l_update_rec.del_det_id_tab(i));
            WSH_DEBUG_SV.log(l_module_name,'l_new_req_qty', l_new_req_qty);
            WSH_DEBUG_SV.log(l_module_name,'Delivery Detail Req Qty ('||i||')', l_update_rec.requested_qty_tab(i));
            WSH_DEBUG_SV.log(l_module_name,'l_new_req_qty2', l_new_req_qty2);
            WSH_DEBUG_SV.log(l_module_name,'Delivery Detail Req Qty 2 ('||i||')', l_update_rec.requested_qty2_tab(i));
          END IF;

          IF l_update_rec.requested_qty_tab(i) > abs(l_new_req_qty) THEN
          --{
            l_update_rec.requested_qty_tab(i) := l_update_rec.requested_qty_tab(i) + l_new_req_qty;
            l_update_rec.record_changed_flag_tab(i) := 'Y';
            IF (nvl(l_new_req_qty2,0) <> 0 ) THEN
            --{
              l_update_rec.requested_qty2_tab(i) := nvl(l_update_rec.requested_qty2_tab(i),0) +
              l_new_req_qty2;

              IF (l_update_rec.requested_qty2_tab(i) < 0) THEN
              --{
                l_update_rec.requested_qty2_tab(i) := 0;
              --}
              END IF;
            --}
            END IF;

            l_new_req_qty := 0; -- so that we can go out the loop as we already
                                -- updated the remaining quantity on the lines.
            l_update_del_det_id := l_update_rec.del_det_id_tab(i);
            l_update_del_det_req_qty := l_update_rec.requested_qty_tab(i);
            l_update_del_det_req_qty2 := l_update_rec.requested_qty2_tab(i);
          --}
          ELSE -- l_update_rec.requested_qty_tab(i) <= abs(l_new_req_qty)
          --{
            l_new_req_qty := l_new_req_qty + l_update_rec.requested_qty_tab(i);
            l_update_rec.requested_qty_tab(i) := 0;
            l_update_rec.record_changed_flag_tab(i) := 'Y';

            IF (l_update_rec.requested_qty2_tab(i) IS NOT NULL) THEN
            --{
              l_new_req_qty2 := l_new_req_qty2 + l_update_rec.requested_qty2_tab(i);
              l_update_rec.requested_qty2_tab(i) := 0;
              IF (l_new_req_qty2 > 0) THEN
              --{
                l_new_req_qty2 := 0;
              --}
              END IF;
            --}
            END IF;

          --}
          END IF;
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_new_req_qty at the end of processing the current record ', l_new_req_qty);
          END IF;

          i := l_update_rec.del_det_id_tab.NEXT(i);
        --}
        END LOOP;
        IF ( l_update_rec.del_det_id_tab.COUNT > 0 ) THEN
        --{
           --
           --
           FORALL i IN l_update_rec.del_det_id_tab.FIRST..l_update_rec.del_det_id_tab.LAST
             update wsh_delivery_details
             set    requested_quantity      =   l_update_rec.requested_qty_tab(i),
                    requested_quantity2     =   l_update_rec.requested_qty2_tab(i),
                    last_update_date        =   sysdate,
                    last_updated_by         =   fnd_global.user_id,
                    last_update_login       =   fnd_global.user_id
             where  delivery_detail_id      =   l_update_rec.del_det_id_tab(i)
             and    nvl(l_update_rec.record_changed_flag_tab(i), 'N') = 'Y';
           --
           --
           IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'After the bulk update');
              WSH_DEBUG_SV.log(l_module_name,'Number of Records updated', SQL%ROWCOUNT);
           END IF;
           --
           -- DBI Project
           -- Update of wsh_delivery_details where requested_quantity/released_status
           -- are changed, call DBI API after the update.
           -- DBI API will check if DBI is installed
           IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Detail Count-', l_update_rec.del_det_id_tab.count);
           END IF;
           WSH_INTEGRATION.DBI_Update_Detail_Log
             (p_delivery_detail_id_tab =>  l_update_rec.del_det_id_tab,
              p_dml_type               => 'UPDATE',
              x_return_status          => l_dbi_rs);

           IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
           END IF;
           -- Only Handle Unexpected error
           IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
             x_return_status := l_dbi_rs;
             --
             ROLLBACK TO PR_REM_REQ_QTY;
             IF l_debug_on THEN
               WSH_DEBUG_SV.pop(l_module_name);
             END IF;
             --
             RETURN;
           END IF;
           -- End of Code for DBI Project
           --
         --}
         END IF;
      --}
      END IF;
      --
      --
    --}
    END IF;
    --
    IF l_num_warnings > 0 THEN
        RAISE WSH_UTIL_CORE.G_EXC_WARNING;
    ELSE
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
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
    WHEN DD_LOCKED THEN
      ROLLBACK TO PR_REM_REQ_QTY;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      -- need to change the message
      FND_MESSAGE.SET_NAME('WSH','WSH_DELIVERY_LINES_LOCKED');
      wsh_util_core.add_message(x_return_status,l_module_name);
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'RECORD_LOCKED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO PR_REM_REQ_QTY;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO PR_REM_REQ_QTY;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
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
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --
    WHEN OTHERS THEN
      ROLLBACK TO PR_REM_REQ_QTY;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_IB_UI_RECON_GRP.PROCESS_REMAINING_REQ_QUANTITY');
  --}
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
  END IF;
  --
  END  process_remaining_req_quantity;

END WSH_RCV_CORR_RTV_TXN_PKG;

/
