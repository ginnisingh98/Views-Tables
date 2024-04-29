--------------------------------------------------------
--  DDL for Package Body WSH_IB_UI_RECON_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_IB_UI_RECON_GRP" as
/* $Header: WSHURGPB.pls 120.3 2006/04/12 23:56:04 jnpinto noship $ */

  --
  G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_IB_UI_RECON_GRP';
  --
--===================
-- PROCEDURES
--===================

--========================================================================
-- PROCEDURE : Revert_Trips            This procedure is called only from
--                                     the Inbound Reconciliation UI
--                                     when the user performs the revert
--                                     matching of a matched or
--                                     partially matched receipt.
--
-- PARAMETERS: p_shipment_header_id    Shipment Header Id of the transaction
--             p_transaction_type      transaction type (ASN or RECEIPT)
--             x_return_status         return status of the API
--========================================================================
  procedure revert_trips(
    p_shipment_header_id IN NUMBER,
    p_transaction_type   IN NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2)
  IS
  --{
    cursor l_trips_csr(p_shpmt_header_id NUMBER) is
    select distinct wt.trip_id
    from wsh_trips wt,
         wsh_trip_stops wts,
         wsh_delivery_legs wdl,
         wsh_new_deliveries wnd
    where wnd.RCV_SHIPMENT_HEADER_ID = p_shpmt_header_id
    and wnd.delivery_id = wdl.delivery_id
    and wdl.pick_up_stop_id = wts.stop_id
    and wts.trip_id = wt.trip_id;

    l_trip_id_tab wsh_util_core.id_tab_type;
    l_return_status VARCHAR2(1);
    l_num_errors      NUMBER := 0;
    l_num_warnings    NUMBER := 0;
    i NUMBER;
  --}
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'REVERT_TRIPS';
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
        WSH_DEBUG_SV.log(l_module_name,'P_SHIPMENT_HEADER_ID',P_SHIPMENT_HEADER_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_TRANSACTION_TYPE',P_TRANSACTION_TYPE);
    END IF;
    --
    SAVEPOINT REVERT_TRIPS_GRP;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    open l_trips_csr(p_shipment_header_id);
    fetch l_trips_csr bulk collect into l_trip_id_tab;
    close l_trips_csr;

    IF l_trip_id_tab.COUNT > 0 THEN
    --{
      FORALL i in l_trip_id_tab.FIRST..l_trip_id_tab.LAST
        update wsh_trips
        set status_code = 'IT'
        where trip_id = l_trip_id_tab(i);
    --}
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
      ROLLBACK TO REVERT_TRIPS_GRP;
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
      ROLLBACK TO REVERT_TRIPS_GRP;
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
      ROLLBACK TO REVERT_TRIPS_GRP;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_IB_UI_RECON_GRP.REVERT_TRIPS', l_module_name);
  --}
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
  END IF;
  --
  END revert_trips;
  --
--========================================================================
-- PROCEDURE : Revert_Deliveries       This procedure is called only from
--                                     the Inbound Reconciliation UI
--                                     when the user performs the revert
--                                     matching of a matched or
--                                     partially matched receipt.
--
-- PARAMETERS: p_delivery_id_tab       Table of delivery Ids to be reverted
--             p_status_code_tab       Table of Status Code values to updated
--                                     on the deliveries stored in
--                                     p_delivery_id_tab.
--             x_return_status         Return status of the API

-- COMMENT   : This procedure is called by the revert_matching which is called
--             only from the Inbound Reconciliation UI when the user performs
--             the revert matching of a matched or partially matched receipt.
--             Here we update the status of the delivery based on the input
--             table p_status_code_tab (because if the receipt is against ASN
--             then the status should be 'IT' and NOT 'OP' This decision is
--             made in revert_details).
--             Following are the logical steps in this API -
--             1. Initially we update the status of all the deliveries based on
--                p_delivery_id_tab and p_status_code_tab and also
--                update rcv_shipment_header_id to NULL.
--             2. Then we call Mark_Reprice_Required to set the reprice_flag
--                on the delivery legs. (This we need to do because the
--                received quantities on the lines will be nullified and
--                we need to re-rate the deliveries)
--             3. We call WSH_TP_RELEASE.calculate_cont_del_tpdates
--                so that we recalculate the TP dates on all the
--                deliveries.
--             4. Finally, we also call WSH_INBOUND_UTIL_PKG.setTripStopStatus
--                to set the statuses of the corresponding trips and stops
--                corresponding  to the new status of the deliveries.
--========================================================================
  PROCEDURE revert_deliveries(
    p_delivery_id_tab    IN wsh_util_core.id_tab_type,
    p_status_code_tab    IN wsh_util_core.column_tab_type,
    x_return_status      OUT NOCOPY VARCHAR2)
  IS
  --{
    -- This cursor is not used anymore.  Was added in the beginning of coding.
    cursor l_parent_txn_sts_csr(p_shipment_header_id NUMBER) is
    select 'Y'
    from   wsh_inbound_txn_history wth1,
           wsh_inbound_txn_history wth2
    where  wth1.shipment_header_id = p_shipment_header_id
    and    wth1.transaction_type = 'ASN'
    and    wth2.parent_shipment_header_id = wth1.shipment_header_id;

    l_parent_txn_exists VARCHAR2(1);
    l_del_sts VARCHAR2(10);
    l_return_status VARCHAR2(1);
    l_num_errors      NUMBER := 0;
    l_num_warnings    NUMBER := 0;
    l_organization_id Number;
    l_wf_rs VARCHAR2(1); --Pick To POD Wf Project

    l_delivery_id_tab wsh_util_core.id_tab_type;

  --}
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'REVERT_DELIVERIES';
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
        --WSH_DEBUG_SV.log(l_module_name,'P_SHIPMENT_HEADER_ID',P_SHIPMENT_HEADER_ID);
        --WSH_DEBUG_SV.log(l_module_name,'P_TRANSACTION_TYPE',P_TRANSACTION_TYPE);
    END IF;
    --
    SAVEPOINT REVERT_DELIVERIES_GRP;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    /*
    open  l_parent_txn_sts_csr(p_shipment_header_id);
    fetch l_parent_txn_sts_csr into l_parent_txn_exists;
    close l_parent_txn_sts_csr;
    IF nvl(l_parent_txn_exists,'N') = 'Y' THEN
      l_del_sts := 'IT';
    ELSE
      l_del_sts := 'OP';
    END IF;


    */

    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_delivery_id_tab count',l_delivery_id_tab.count);
    END IF;

    IF (p_delivery_id_tab.count > 0 ) THEN
    --{
      FOR i in p_delivery_id_tab.FIRST..p_delivery_id_tab.LAST LOOP
        update wsh_new_deliveries
        set rcv_shipment_header_id = NULL,
            status_code = p_status_code_tab(i)
        where delivery_id = p_delivery_id_tab(i)
	RETURNING organization_id into l_organization_id    ; --Added for Pick To POD WF
      /* CURRENTLY NOT IN USE
      --Raise Event: Pick To Pod Workflow
	  WSH_WF_STD.Raise_Event(
							p_entity_type => 'DELIVERY',
							p_entity_id =>  p_delivery_id_tab(i),
							p_event => 'oracle.apps.fte.delivery.ib.receiptreverted' ,
							p_organization_id => l_organization_id,
							x_return_status => l_wf_rs ) ;
		 --Error Handling to be done in WSH_WF_STD.Raise_Event itself
		 IF l_debug_on THEN
		     WSH_DEBUG_SV.log(l_module_name,'Current Time is ',SYSDATE);
		     WSH_DEBUG_SV.log(l_module_name,'Delivery ID is  ',  p_delivery_id_tab(i));
		     WSH_DEBUG_SV.log(l_module_name,'Return Status After Calling WSH_WF_STD.Raise_Event',l_wf_rs);
		 END IF;
	--Done Raise Event: Pick To Pod Workflow
	*/
	END LOOP;

      -- Commented the below code because we are calling detail_weight_volume
      -- and that in turn would calculate the weight and volume of the
      -- delivery  ( and trip and trip stops if present).
      /*
      WSH_WV_UTILS.Delivery_Weight_Volume(
        p_del_rows          => p_delivery_id_tab,
        p_update_flag       => 'Y',
        p_calc_wv_if_frozen => 'N',
        x_return_status     => l_return_status);
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Return STatus after calling Delivery_Weight_Volume',l_return_status);
      END IF;

      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors);
      */

      WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required(
        p_entity_type           => 'DELIVERY',
        p_entity_ids            => p_delivery_id_tab,
        x_return_status         => l_return_status);
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Return STatus after calling Mark_Reprice_Required',l_return_status);
      END IF;
      --
      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors);
      --
      WSH_TP_RELEASE.calculate_cont_del_tpdates(
        p_entity        => 'DLVY',
        p_entity_ids    => p_delivery_id_tab,
        x_return_status => l_return_status);
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Return Status after calling calculate_cont_del_tpdates',l_return_status);
      END IF;
      --
      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors);
      --
      WSH_INBOUND_UTIL_PKG.setTripStopStatus(
        p_transaction_code => 'RECEIPT',
        p_action_code      => 'CANCEL',
        p_delivery_id_tab  => p_delivery_id_tab,
        x_return_status    => l_return_status);

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Return STatus after calling setTripStopStatus',l_return_status);
      END IF;
      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors);
      --
    --}
    END IF;

    IF l_num_errors   > 0 THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_num_warnings > 0 THEN
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
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO REVERT_DELIVERIES_GRP;
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
      ROLLBACK TO REVERT_DELIVERIES_GRP;
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
      ROLLBACK TO REVERT_DELIVERIES_GRP;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_IB_UI_RECON_GRP.REVERT_DELIVERIES', l_module_name);
  --}
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
  END IF;
  --
  END revert_deliveries;
  --
--========================================================================
-- PROCEDURE : Revert_Details          This procedure is called only from
--                                     the Inbound Reconciliation UI
--                                     when the user performs the revert
--                                     matching of a matched or
--                                     partially matched receipt.
--
-- PARAMETERS: p_shipment_header_id    Shipment Header Id of the transaction
--             p_transaction_type      transaction type (ASN or RECEIPT)
--             x_return_status         return status of the API
-- COMMENT   : This procedure is called by the revert_matching which is called
--             only from the Inbound Reconciliation UI when the user performs
--             the revert matching of a matched or partially matched receipt.
--             Here we update the released status, returned_quantity,
--             received_quantity of the delivery details based on the input
--             p_shipment_header_id (Secondary quantities are also taken care).
--             The following are the logic flow steps in this API -
--             1. Initially we get all the delivery details associated to
--                receipt using the shipment_header_id into PL/SQL tables.
--             2. Then, in a loop for each distinct po_line_location_id, we compare the
--                total returned quantity of the closed lines with the total
--                total requested quantity of the either open lines or lines
--                that are closed but have NULL received quantity.
--                (This is needed because, when we are reverting the
--                 delivery details associated a receipt, we need to reduce
--                 requested quantity on open delivery details by a quantity
--                 equal the total returned quantity on the closed delivery details).
--                  > If the total returned quantity of the closed details
--                  > is equal to the total requested quantity of the
--                  > open delivery details, then we delete all the open
--                  > delivery details.
--
--                  > If the total returned quantity of the closed details
--                  > is greater than the total requested quantity of the
--                  > open delivery details, then we raise an exception
--                  > as reverting cannot be completed successfully.
--
--                  > If the total returned quantity of the closed details
--                  > is less than the total requested quantity of the
--                  > open delivery details, then we call the API
--                  > WSH_RCV_CORR_RTV_TXN_PKG.process_remaining_req_quantity
--                  > with the action_code 'REVERT_MATCH'
--                  > and passing a negative value of the total returned quantity
--                  > for that po_line_location_id.
--
--                  > While looping through we also assign the appropriate values
--                    to the respective out parameters.
--              3. After the loop, since we are nullifying the received quantities
--                 on all these delivery details, we need to re-calculate the wt-vol
--                 of the delivery details, therefore, we call  the API
--                 WSH_WV_UTILS.Detail_Weight_Volume.
--              4. At the end, we loop through the delivery ids in l_delivery_id_tab to
--                 to remove the duplicate delivery ids.  Please refer to that
--                 part of the code for more detailed comments.
--========================================================================
  procedure revert_details(
    p_shipment_header_id IN NUMBER,
    p_transaction_type   IN VARCHAR2,
    x_dd_list            OUT NOCOPY WSH_PO_CMG_PVT.dd_list_type,
    x_delivery_id_tab    OUT NOCOPY WSH_UTIL_CORE.id_tab_type,
    x_status_code_tab    OUT NOCOPY WSH_UTIL_CORE.column_tab_type,
    x_unassign_det_id_tab OUT NOCOPY WSH_UTIL_CORE.id_tab_type,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2)
  IS
  --{

    -- This is not used anymore.  Was added in the beginning.
    cursor l_parent_txn_sts_csr(p_shipment_header_id NUMBER) is
    select 'Y'
    from   wsh_inbound_txn_history wth1,
           wsh_inbound_txn_history wth2
    where  wth1.shipment_header_id = p_shipment_header_id
    and    wth1.transaction_type = 'ASN'
    and    wth2.parent_shipment_header_id = wth1.shipment_header_id;

    -- This is used to obtain all the delivery details based on the
    -- rcv_shipment_header_id from wsh_new_deliveries.
    -- These will be the delivery details that we need to revert.
    cursor l_del_details_csr(p_shipment_header_id NUMBER) is
    select wdd.source_line_id,
           wdd.po_shipment_line_id,
           wdd.delivery_detail_id,
           wdd.ship_from_location_id,
           wdd.rcv_shipment_line_id,
           wdd.released_status,
           wnd.delivery_id,
           wnd.asn_shipment_header_id,
           wnd.rcv_shipment_header_id,
           wnd.status_code,
           wdd.picked_quantity,
           wdd.shipped_quantity
    from   wsh_delivery_details wdd,
           wsh_delivery_assignments_v wda,
           wsh_new_deliveries wnd
    where  wnd.rcv_shipment_header_id = p_shipment_header_id
    and    wnd.delivery_id = wda.delivery_id
    and    wda.delivery_detail_id = wdd.delivery_detail_id
    and    wdd.source_code = 'PO'
    order by wdd.source_line_id, wdd.po_shipment_line_id;

    -- This cursor is used to obtain the total returned quantity
    -- on the matched delivery details for a po_line_location_id.
    cursor l_tot_ret_qty_csr(p_source_line_id NUMBER,
                             p_po_line_loc_id NUMBER) is
    select sum(returned_quantity),
           sum(returned_quantity2)
    from   wsh_delivery_details wdd
    where  source_line_id = p_source_line_id
    and    po_shipment_line_id = p_po_line_loc_id
    and    released_status = 'L'
    and    source_code = 'PO';

    -- This cursor is used to obtain the total requested quantity
    -- on all the open/closed delivery details which were NOT
    -- matched against the receipt being reverted for a po_line_location_id.
    cursor l_tot_req_qty_csr(p_source_line_id NUMBER,
                             p_po_line_loc_id NUMBER) is
    select sum(requested_quantity), sum(requested_quantity2)
    from wsh_delivery_details wdd
    where source_line_id = p_source_line_id
    and   po_shipment_line_id = p_po_line_loc_id
    and   ( released_status = 'X'
            or
           (released_status = 'L' and received_quantity is null)
          )
    and  source_code = 'PO'
    and  routing_req_id is null;

    -- This is not used anymore.  Was added in the beginning.
    cursor l_packed_del_lines_csr(p_source_line_id NUMBER,
                                  p_po_line_loc_id NUMBER) is
    select wdd.delivery_detail_id
    from   wsh_delivery_details wdd,
           wsh_delivery_assignments_v wda
    where  wdd.source_line_id = p_source_line_id
    and    wdd.container_flag = 'N'
    and    wdd.source_code = 'PO'
    and    wda.delivery_detail_id = wdd.delivery_detail_id
    and    wda.parent_delivery_detail_id is not null;

    -- This is not used anymore.  Was added in the beginning.
    cursor l_del_det_id_csr(p_shipment_header_id NUMBER) is
    select wdd.po_shipment_line_id,
           wdd.delivery_detail_id
    from   wsh_delivery_details wdd,
           wsh_delivery_assignments_v wda,
           wsh_new_deliveries wnd
    where wnd.rcv_shipment_header_id = p_shipment_header_id
    and   wnd.delivery_id = wda.delivery_id
    and   wda.delivery_detail_id = wdd.delivery_detail_id
    and   wdd.source_code = 'PO';

    -- This cursor checks whether atleast one record in wsh_delivery_details
    -- is already purged. If yes, we do not allow reverting of the transaction.
    cursor l_purge_details_csr (p_source_line_id IN NUMBER,
                                p_po_shipment_line_id IN NUMBER) is
    select 'Y'
    from   wsh_delivery_details
    where  source_line_id = p_source_line_id
    and    po_shipment_line_id = p_po_shipment_line_id
    and    source_code = 'PO'
    and    released_status = 'P'
    and    rownum = 1;

    l_purged_details_flag  VARCHAR2(1);
    l_rel_sts  VARCHAR2(1);
    l_parent_txn_exists VARCHAR2(1);
    l_shipment_line_id NUMBER;
    l_source_line_id_tab wsh_util_core.id_tab_type;
    l_po_line_loc_id_tab wsh_util_core.id_tab_type;
    l_del_det_id_tab wsh_util_core.id_tab_type;
    l_ship_from_loc_id_tab wsh_util_core.id_tab_type;
    l_rcv_shipment_line_id_tab wsh_util_core.id_tab_type;
    l_released_status_tab wsh_util_core.column_tab_type;
    l_asn_shipment_header_id_tab wsh_util_core.id_tab_type;
    l_rcv_shipment_header_id_tab wsh_util_core.id_tab_type;
    l_packed_details_tab wsh_util_core.id_tab_type;
    l_picked_quantity_tab wsh_util_core.id_tab_type;
    l_shipped_quantity_tab wsh_util_core.id_tab_type;
    l_sum_returned_quantity NUMBER;
    l_sum_returned_quantity2 NUMBER;
    l_sum_req_qty NUMBER;
    l_sum_req_qty2 NUMBER;
    l_accept_rcv_lpn_flag VARCHAR2(32767);
    l_prev_po_line_loc_id NUMBER := -9999;
    l_unassign_det_id_tab wsh_util_core.id_tab_type;
    l_delivery_id_tab wsh_util_core.id_tab_type;
    l_status_code_tab wsh_util_core.column_tab_type;

    l_rcv_rtv_rec WSH_RCV_CORR_RTV_TXN_PKG.rem_req_qty_rec_type;
    l_det_action_prms    WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type;
    l_det_action_out_rec WSH_GLBL_VAR_STRCT_GRP.dd_action_out_rec_type;
    l_line_rec OE_WSH_BULK_GRP.Line_rec_type;

    l_return_status VARCHAR2(1);
    i NUMBER;
    l_del_index NUMBER;
    l_num_errors      NUMBER := 0;
    l_num_warnings    NUMBER := 0;
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);

    l_pr_rem_in_rec  WSH_RCV_CORR_RTV_TXN_PKG.action_in_rec_type;

    l_del_cache_tbl wsh_util_core.key_value_tab_type;
    l_del_ext_cache_tbl wsh_util_core.key_value_tab_type;

    l_detail_tab WSH_UTIL_CORE.id_tab_type;  -- DBI Project
    l_dbi_rs        VARCHAR2(1);             -- DBI Project

    l_cnt_det_id_tab wsh_util_core.id_tab_type;

    cursor l_delete_det_csr (p_source_line_id IN NUMBER,
                             p_po_shpmt_line_id IN NUMBER) is
    select delivery_detail_id
    from   wsh_delivery_details
    where  source_line_id = p_source_line_id
    and   po_shipment_line_id = p_po_shpmt_line_id
    and   ( released_status = 'X'
            or
            (released_status = 'L' and received_quantity is null)
          )
    and routing_req_id is null
    for update of delivery_detail_id nowait;

    l_delete_det_tbl wsh_util_core.id_tab_type;

    DD_LOCKED exception;
    PRAGMA EXCEPTION_INIT(DD_LOCKED, -54);
  --}
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'REVERT_DETAILS';
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
        WSH_DEBUG_SV.log(l_module_name,'P_SHIPMENT_HEADER_ID',P_SHIPMENT_HEADER_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_TRANSACTION_TYPE',P_TRANSACTION_TYPE);
    END IF;
    --
    SAVEPOINT REVERT_DETAILS_GRP;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   /*
    open  l_parent_txn_sts_csr(p_shipment_header_id);
    fetch l_parent_txn_sts_csr into l_parent_txn_exists;
    close l_parent_txn_sts_csr;
    IF nvl(l_parent_txn_exists,'N') = 'Y' THEN
    --{
      l_rel_sts := 'C';
    --}
    ELSE
    --{
      l_rel_sts := 'X';
      l_shipment_line_id := NULL;
    --}
    END IF;
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_rel_sts',l_rel_sts);
    END IF;
    */
    open  l_del_details_csr(p_shipment_header_id);
    fetch l_del_details_csr bulk collect into l_source_line_id_tab,
                                              l_po_line_loc_id_tab,
                                              l_del_det_id_tab,
                                              l_ship_from_loc_id_tab,
                                              l_rcv_shipment_line_id_tab,
                                              l_released_status_tab,
                                              l_delivery_id_tab,
                                              l_asn_shipment_header_id_tab,
                                              l_rcv_shipment_header_id_tab,
                                              l_status_code_tab,
                                              l_picked_quantity_tab,
                                              l_shipped_quantity_tab;
    close l_del_details_csr;
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'After fetching the cursor');
        WSH_DEBUG_SV.log(l_module_name,'l_po_line_loc_id_tab count is', l_po_line_loc_id_tab.count);
    END IF;
    IF l_po_line_loc_id_tab.count > 0 THEN
    --{
      i := l_po_line_loc_id_tab.first;
      while i IS NOT NULL LOOP
      --{
        IF (l_po_line_loc_id_tab(i) <> l_prev_po_line_loc_id) THEN
        --{
          open l_purge_details_csr(l_source_line_id_tab(i), l_po_line_loc_id_tab(i));
          fetch l_purge_details_csr into l_purged_details_flag;
          close l_purge_details_csr;
          IF (nvl(l_purged_details_flag, 'N') = 'Y') THEN
          --{
            FND_MESSAGE.SET_NAME('WSH','WSH_IB_DETAILS_PURGED');
            x_return_status := wsh_util_core.g_ret_sts_error;
            wsh_util_core.add_message(x_return_status, l_module_name);
            RAISE FND_API.G_EXC_ERROR;
          --}
          END IF;
          l_sum_returned_quantity := 0;
          l_sum_returned_quantity2 := 0;
          l_sum_req_qty := 0;
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'After initializing the quantities');
          END IF;
          open  l_tot_ret_qty_csr(l_source_line_id_tab(i),
                                  l_po_line_loc_id_tab(i));
          fetch l_tot_ret_qty_csr into l_sum_returned_quantity,
                                       l_sum_returned_quantity2;
          close l_tot_ret_qty_csr;
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_sum_returned_quantity',l_sum_returned_quantity);
            WSH_DEBUG_SV.log(l_module_name,'l_sum_returned_quantity2',l_sum_returned_quantity2);
          END IF;
          IF (nvl(l_sum_returned_quantity,0) > 0 ) THEN
          --{
            open  l_tot_req_qty_csr(l_source_line_id_tab(i),
                                    l_po_line_loc_id_tab(i));
            fetch l_tot_req_qty_csr into l_sum_req_qty, l_sum_req_qty2;
            close l_tot_req_qty_csr;
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_sum_req_qty',l_sum_req_qty);
              WSH_DEBUG_SV.log(l_module_name,'l_sum_req_qty2',l_sum_req_qty2);
            END IF;
            IF nvl (l_sum_req_qty, 0) < l_sum_returned_quantity THEN
            --{
              FND_MESSAGE.SET_NAME('WSH','WSH_IB_INSUFF_LINES_REVERT');
              x_return_status := wsh_util_core.g_ret_sts_error;
              wsh_util_core.add_message(x_return_status, l_module_name);
              RAISE FND_API.G_EXC_ERROR;
            --}
            ELSIF l_sum_req_qty = l_sum_returned_quantity THEN
            --{
              -- This cursor is for locking all the delivery details for
              -- corresponding po_line_location_id that we are going
              -- to delete.
              open  l_delete_det_csr(l_source_line_id_tab(i),
                                    l_po_line_loc_id_tab(i));
              fetch l_delete_det_csr bulk collect into l_delete_det_tbl;
              close l_delete_det_csr;
              IF (l_delete_det_tbl.count > 0) THEN
              --{
              -- We can delete all the open lines for the po line location.
              -- first deleting the assignments
                FORALL i IN l_delete_det_tbl.FIRST..l_delete_det_tbl.LAST
                DELETE wsh_delivery_assignments_v
                WHERE  delivery_detail_id = l_delete_det_tbl(i);

                IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'SQL%ROWCOUNT After deleting LPNs from WDA',SQL%ROWCOUNT);
                END IF;

                --Deleting the rows in WSH_DELIVERY_DETAILS corresponding to the selected LPNs.
                FORALL i IN l_delete_det_tbl.FIRST..l_delete_det_tbl.LAST
                DELETE WSH_DELIVERY_DETAILS
                WHERE  delivery_detail_id = l_delete_det_tbl(i);

                IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'SQL%ROWCOUNT After deleting LPNs from WDD',SQL%ROWCOUNT);
                END IF;
              --}
              END IF;
              l_delete_det_tbl.delete;
              /*
              delete from wsh_delivery_assignments_v
              where delivery_detail_id in
                (select delivery_detail_id
                 from   wsh_delivery_details
                 where  source_line_id = l_source_line_id_tab(i)
                 and   po_shipment_line_id = l_po_line_loc_id_tab(i)
                 and   ( released_status = 'X'
                         or
                        (released_status = 'L' and received_quantity is null)
                       )
                 and routing_req_id is null);

              delete from wsh_delivery_details
              where source_line_id = l_source_line_id_tab(i)
              and   po_shipment_line_id = l_po_line_loc_id_tab(i)
              and   ( released_status = 'X'
                      or
                      (released_status = 'L' and received_quantity is null)
                    )
              and routing_req_id is null;
              */
            --}
            ELSIF l_sum_req_qty > l_sum_returned_quantity THEN
            --{
              l_rcv_rtv_rec.po_line_id := l_source_line_id_tab(i);
              l_rcv_rtv_rec.po_line_location_id := l_po_line_loc_id_tab(i);
              l_rcv_rtv_rec.requested_quantity := -l_sum_returned_quantity;
              IF (nvl(l_sum_returned_quantity2,0) > 0 ) THEN
                l_rcv_rtv_rec.requested_quantity2 := -l_sum_returned_quantity2;
              END IF;
              --
              -- Debug Statements
              --
              IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_RCV_CORR_RTV_TXN_PKG.PROCESS_REMAINING_REQ_QUANTITY',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;
              --
              l_pr_rem_in_rec.action_code := 'REVERT_MATCH';
              WSH_RCV_CORR_RTV_TXN_PKG.process_remaining_req_quantity (
                p_rem_req_qty_rec => l_rcv_rtv_rec,
                p_in_rec          => l_pr_rem_in_rec,
                x_return_status => l_return_status);
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
          --}
          END IF;

          -- This update statement is added so that we can re-open the delivery
          -- details that are closed just because PO may be closed.  But we need to
          -- re-open them as we do not know which delivery details will be used
          -- when matching the receipt once again.
          update wsh_delivery_details
          set    released_status       = 'X'
          where  released_status       = 'L'
          and    source_code           = 'PO'
          and    po_shipment_line_id   = l_po_line_loc_id_tab(i)
          and    source_line_id        = l_source_line_id_tab(i)
          and    ship_from_location_id = -1
          and    rcv_shipment_line_id  is null
          RETURNING delivery_detail_id BULK COLLECT INTO l_detail_tab;

          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'SQL%ROWCOUNT After updating wdds',SQL%ROWCOUNT);
          END IF;

          --
          -- DBI Project
          -- Update of wsh_delivery_details where released_status
          -- are changed, call DBI API after the update.
          -- This API will also check for DBI Installed or not
          IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Calling DBI API. delivery details l_detail_tab count :',l_detail_tab.COUNT);
          END IF;
          WSH_INTEGRATION.DBI_Update_Detail_Log
           (p_delivery_detail_id_tab => l_detail_tab,
            p_dml_type               => 'UPDATE',
            x_return_status          => l_dbi_rs);

          IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
          END IF;
          IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
	  x_return_status := l_dbi_rs;
          Rollback to REVERT_DETAILS_GRP;
	  -- just pass this return status to caller API
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'DBI API Returned Unexpected error '||x_return_status);
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          return;
         END IF;
        -- End of Code for DBI Project
        --

        --}
        END IF;
        IF (l_asn_shipment_header_id_tab(i) IS NULL) OR
           (l_asn_shipment_header_id_tab(i) <> nvl(l_rcv_shipment_header_id_tab(i),-9999)) THEN
        --{
          l_rcv_shipment_line_id_tab(i) := NULL;
        --}
        END IF;
        -- else we need to leave the rcv shipment line id as it is.
        IF (l_asn_shipment_header_id_tab(i) IS NULL) THEN
        --{
          l_released_status_tab(i) := 'X';

          -- x_dd_list needs to be populated to finally call Update_Attributes
          -- because if the delivery details were not matched against ASN, then we
          -- need to reopen them and update them with the latest attributes of PO.
          x_dd_list.po_shipment_line_id.extend;
          x_dd_list.delivery_detail_id.extend;
          x_dd_list.po_shipment_line_id(x_dd_list.po_shipment_line_id.count) := l_po_line_loc_id_tab(i);
          x_dd_list.delivery_detail_id(x_dd_list.delivery_detail_id.count) := l_del_det_id_tab(i);
          l_status_code_tab(i) := 'OP';
        --}
        ELSE
        --{
          l_status_code_tab(i) := 'IT';
          l_released_status_tab(i) := 'C';
        --}
        END IF;
        -- This is for unassigning all the delivery details
        -- that have ship from location id as -1 and
        -- are still assigned to the deliveries
        IF (
            ( nvl(l_ship_from_loc_id_tab(i), -1) = -1
              and nvl(l_shipped_quantity_tab(i),0) = 0
            )
             OR
            (
              nvl(l_shipped_quantity_tab(i),nvl(l_picked_quantity_tab(i),0)) = 0
            )
           )
        THEN
          x_unassign_det_id_tab(x_unassign_det_id_tab.count + 1) := l_del_det_id_tab(i);
        END IF;
        l_prev_po_line_loc_id := l_po_line_loc_id_tab(i);
        i := l_po_line_loc_id_tab.next(i);
      --}
      END LOOP;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Before doing the update');
      END IF;
      FORALL i IN l_del_det_id_tab.FIRST..l_del_det_id_tab.LAST
        update wsh_delivery_details
        set returned_quantity = NULL,
            returned_quantity2 = NULL,
            received_quantity  =NULL,
            received_quantity2 = NULL,
            released_status    = l_released_status_tab(i),
            rcv_shipment_line_id = l_rcv_shipment_line_id_tab(i),
            last_update_date        = sysdate,
            last_updated_by         = fnd_global.user_id,
            last_update_login       = fnd_global.user_id
        where delivery_detail_id = l_del_det_id_tab(i)
        and   source_code = 'PO';

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'After doing the update');
      END IF;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'After doing the update');
        WSH_DEBUG_SV.log(l_module_name,'l_num_errors', l_num_errors);
        WSH_DEBUG_SV.log(l_module_name,'l_num_warnings', l_num_warnings);
      END IF;
      --
      -- DBI Project
      -- Update of wsh_delivery_details where released_status
      -- are changed, call DBI API after the update.
      -- This API will also check for DBI Installed or not
        IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Calling DBI API. delivery details l_del_det_id_tab count :',l_del_det_id_tab.COUNT);
        END IF;
        WSH_INTEGRATION.DBI_Update_Detail_Log
         (p_delivery_detail_id_tab => l_del_det_id_tab,
          p_dml_type               => 'UPDATE',
          x_return_status          => l_dbi_rs);

        IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
        END IF;
      IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
	x_return_status := l_dbi_rs ;
        Rollback to REVERT_DETAILS_GRP;
	-- just pass this return status to caller API
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'DBI API Returned Unexpected error '||x_return_status);
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        return;
      END IF;
      -- End of Code for DBI Project
      --
      -- Updating the released_status for the lpns if any are present
      --
      update wsh_delivery_details
        set returned_quantity = NULL,
            returned_quantity2 = NULL,
            received_quantity  =NULL,
            received_quantity2 = NULL,
            released_status    = 'C',
            last_update_date        = sysdate,
            last_updated_by         = fnd_global.user_id,
            last_update_login       = fnd_global.user_id
       where delivery_detail_id in (select wda.delivery_detail_id
                                    from   wsh_delivery_assignments_v wda,
                                           wsh_new_deliveries wnd
                                    where  wnd.rcv_shipment_header_id = p_shipment_header_id
                                    and    wda.delivery_id = wnd.delivery_id)
       and   container_flag = 'Y'
       returning delivery_detail_id
       bulk collect into l_cnt_det_id_tab;
       --
       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'l_cnt_det_id_tab count', l_cnt_det_id_tab.count);
       END IF;
       --
       IF (l_cnt_det_id_tab.count > 0 ) THEN
       --{
         --
         -- DBI Project
         -- Update of wsh_delivery_details where released_status
         -- are changed, call DBI API after the update.
         -- This API will also check for DBI Installed or not
         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Calling DBI API. delivery details l_del_det_id_tab count :',l_del_det_id_tab.COUNT);
         END IF;
         WSH_INTEGRATION.DBI_Update_Detail_Log
           (p_delivery_detail_id_tab => l_cnt_det_id_tab,
            p_dml_type               => 'UPDATE',
            x_return_status          => l_dbi_rs);

         IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
         END IF;
         IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
	   x_return_status := l_dbi_rs ;
           Rollback to REVERT_DETAILS_GRP;
	   -- just pass this return status to caller API
           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'DBI API Returned Unexpected error '||x_return_status);
             WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           return;
         END IF;
         -- End of Code for DBI Project
         --
       --}
       END IF;

      IF (l_del_det_id_tab.count > 0 ) THEN
      --{
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.DETAIL_WEIGHT_VOLUME',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        WSH_WV_UTILS.Detail_Weight_Volume(
          p_detail_rows    => l_del_det_id_tab,
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
    --}
    END IF;


    -- We need to do this because we obtain the l_delivery_id_tab
    -- from the l_del_details_csr cursor and this cursor is at the line level.
    -- Therefore we can have multiple records in l_delivery_id_tab storing
    -- the same delivery_id.  And if we pass the same table to revert_deliveries
    -- then the APIs Mark_Reprice_Required... will try to process the same
    -- delivery multiple times which is not good.  Therefore, we are
    -- using the caching mechanism to identify unique delivery ids and pass
    -- them as out parameters so that they can be used in revert_deliveries.

    l_del_index := l_delivery_id_tab.first;
    while l_del_index IS NOT NULL LOOP
    --{
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_CACHED_VALUE',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      wsh_util_core.get_cached_value(
        p_cache_tbl     => l_del_cache_tbl,
        p_cache_ext_tbl => l_del_ext_cache_tbl,
        p_value         => l_delivery_id_tab(l_del_index),
        p_key           => l_delivery_id_tab(l_del_index),
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
            WSH_DEBUG_SV.log(l_module_name,'Delivery Id is ',l_delivery_id_tab(l_del_index));
        END IF;
        --
        wsh_util_core.get_cached_value(
          p_cache_tbl     => l_del_cache_tbl,
          p_cache_ext_tbl => l_del_ext_cache_tbl,
          p_value         => l_delivery_id_tab(l_del_index),
          p_key           => l_delivery_id_tab(l_del_index),
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

        x_delivery_id_tab(x_delivery_id_tab.count+1) := l_delivery_id_tab(l_del_index);
        x_status_code_tab(x_status_code_tab.count+1) := l_status_code_tab(l_del_index);
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'After assigning the value');
        END IF;
      --}
      END IF;
      l_del_index := l_delivery_id_tab.next(l_del_index);
    --}
    END LOOP;
    --
    IF l_num_errors > 0 THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_num_warnings > 0 THEN
      RAISE WSH_UTIL_CORE.G_EXC_WARNING;
    ELSE
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    END IF;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Before calling count and get');
    END IF;
    FND_MSG_PUB.Count_And_Get
      (
       p_count  => x_msg_count,
       p_data  =>  x_msg_data,
       p_encoded => FND_API.G_FALSE
      );
    --
  --}
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'End of the procedure');
    END IF;
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  EXCEPTION
  --{
    WHEN DD_LOCKED THEN
      ROLLBACK TO REVERT_DETAILS_GRP;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      -- need to change the message
      FND_MESSAGE.SET_NAME('WSH','WSH_DELIVERY_LINES_LOCKED');
      wsh_util_core.add_message(x_return_status,l_module_name);
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'RECORD_LOCKED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:DD_LOCKED');
      END IF;
      --
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO REVERT_DETAILS_GRP;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
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
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO REVERT_DETAILS_GRP;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
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
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
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
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --
    WHEN OTHERS THEN
      ROLLBACK TO REVERT_DETAILS_GRP;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_IB_UI_RECON_GRP.REVERT_DETAILS', l_module_name);
      --
      FND_MSG_PUB.Count_And_Get
        (
         p_count  => x_msg_count,
         p_data  =>  x_msg_data,
         p_encoded => FND_API.G_FALSE
        );
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
  END revert_details;
  --
--========================================================================
-- PROCEDURE : Get_Cum_Rcvd_Rtv_Quantities --
--                                     This procedure is called only from
--                                     the Inbound Reconciliation UI to
--                                     query the rcv shipment lines.
--
-- PARAMETERS: p_delivery_id_tab       Table of delivery Ids to be reverted
--             p_status_code_tab       Table of Status Code values to updated
--                                     on the deliveries stored in
--                                     p_delivery_id_tab.
--             x_return_status         Return status of the API

-- COMMENT   : This procedure is defined to obtain the cumulative received and
--             returned quantities for a rcv shipment line.
--             In this procedure we get the quantity for each transaction type
--             from rcv_fte_transactions_v for the input p_shipment_line_id
--             and then sum up the received correction quantities, to the
--             received quantities and sum up the returned correction quantities
--             to the returned quantities passing the final received quantity
--             and the returned quantity for a shipment_line_id in rcv_fte_lines_v
--             Please refer to the example in the Appendix.1 under the dld
--             for corrections and rtv to get the description of what this API
--             does.
--========================================================================
  PROCEDURE get_cum_rcvd_rtv_quantities(
              p_shipment_line_id   IN  NUMBER,
              --p_max_rcv_txn_id     IN  NUMBER,
              x_prim_rcvd_qty      OUT NOCOPY NUMBER,
              x_prim_ret_qty       OUT NOCOPY NUMBER,
              x_primary_uom_code   OUT NOCOPY VARCHAR2,
              x_sec_rcvd_qty       OUT NOCOPY NUMBER,
              x_sec_ret_qty        OUT NOCOPY NUMBER,
              x_secondary_uom_code OUT NOCOPY VARCHAR2,
              x_delete_rec_flag    OUT NOCOPY VARCHAR2,
              x_max_rcv_txn_id     OUT NOCOPY NUMBER,
              x_return_status      OUT NOCOPY VARCHAR2
            )
  IS
  --{
    --
    cursor l_max_txn_id_csr (p_shipment_line_id IN NUMBER) is
    select max(transaction_id)
    from rcv_fte_transactions_v
    where shipment_line_id = p_shipment_line_id;
    --
    l_max_txn_id NUMBER;
    --
    --
    cursor l_get_rcvd_qty_csr (p_shipment_line_id IN NUMBER) is
    select transaction_id,
           parent_transaction_id,
           primary_quantity,
           primary_uom_code,
           secondary_quantity,
           secondary_uom_code,
           DECODE(transaction_type,'MATCH','RECEIPT','UNORDERED','RECEIPT','MATCHED','RECEIPT', 'RECEIVE','RECEIPT', transaction_type)  transaction_type,
           DECODE(parent_transaction_type, 'MATCH','RECEIPT','UNORDERED','RECEIPT','MATCHED','RECEIPT', 'RECEIVE','RECEIPT', parent_transaction_type)   parent_transaction_type
    from   rcv_fte_transactions_v
    where  shipment_line_id = p_shipment_line_id
    order by nvl(parent_transaction_id, transaction_id), transaction_id;

    -- The order by is very important in the above cursor.
    -- This way we are getting all the records that belong to transaction type
    -- at one place.
    -- valid transaction types are 'RECEIVE', 'CORRECT', 'RETURN TO VENDOR'.
    --
    --
    l_parent_txn_id NUMBER;
    l_prim_rcvd_qty NUMBER;
    l_prim_rcvd_corr_qty NUMBER;
    l_prim_ret_qty NUMBER;
    l_prim_rtv_corr_qty NUMBER;
    l_sec_rcvd_qty NUMBER;
    l_sec_rcvd_corr_qty NUMBER;
    l_sec_ret_qty NUMBER;
    l_sec_rtv_corr_qty NUMBER;
    l_primary_uom_code VARCHAR2(32767);
    l_secondary_uom_code VARCHAR2(32767);

    l_txn_id_tab wsh_util_core.id_tab_type;
    l_parent_txn_id_tab wsh_util_core.id_tab_type;
    l_prim_qty_tab wsh_util_core.id_tab_type;
    l_sec_qty_tab  wsh_util_core.id_tab_type;
    l_prim_uom_code_tab wsh_util_core.column_tab_type;
    l_sec_uom_code_tab wsh_util_core.column_tab_type;
    l_txn_type_tab wsh_util_core.column_tab_type;
    l_parent_txn_type_tab wsh_util_core.column_tab_type;

    l_index NUMBER;

    c_receipt CONSTANT VARCHAR2(32767) := 'RECEIPT';
    c_correct CONSTANT VARCHAR2(32767) := 'CORRECT';
    c_rtv CONSTANT VARCHAR2(32767) := 'RETURN TO VENDOR';
    --
    --
  --}
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_CUM_RCVD_RTV_QUANTITIES';
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
        WSH_DEBUG_SV.log(l_module_name,'P_SHIPMENT_LINE_ID',P_SHIPMENT_LINE_ID);
        --WSH_DEBUG_SV.log(l_module_name,'P_MAX_RCV_TXN_ID',P_MAX_RCV_TXN_ID);
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    --
    --
    open  l_max_txn_id_csr(p_shipment_line_id);
    fetch l_max_txn_id_csr into l_max_txn_id;
    close l_max_txn_id_csr;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_max_txn_id',l_max_txn_id);
    END IF;
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Before opening the cursor l_get_rcvd_qty_csr');
    END IF;
    open  l_get_rcvd_qty_csr(p_shipment_line_id);
    fetch l_get_rcvd_qty_csr bulk collect into
                                     l_txn_id_tab,
                                     l_parent_txn_id_tab,
                                     l_prim_qty_tab,
                                     l_prim_uom_code_tab,
                                     l_sec_qty_tab,
                                     l_sec_uom_code_tab,
                                     l_txn_type_tab,
                                     l_parent_txn_type_tab;
    close l_get_rcvd_qty_csr;
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'After fetching the cursor l_get_rcvd_qty_csr');
      WSH_DEBUG_SV.log(l_module_name,'rcv txns records count is',l_txn_id_tab.count);
    END IF;
    x_delete_rec_flag := 'N';

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'x_delete_rec_flag',x_delete_rec_flag);
    END IF;
    l_index := l_prim_qty_tab.first;
    IF ( nvl(l_index, 0) > 0 ) THEN
    --{
      l_primary_uom_code := l_prim_uom_code_tab(l_index);
      l_secondary_uom_code := l_sec_uom_code_tab(l_index);
    --}
    END IF;

    while l_index is not null loop
    --{
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'transaction type',l_txn_type_tab(l_index));
        WSH_DEBUG_SV.log(l_module_name,'parent transaction type',l_parent_txn_type_tab(l_index));
      END IF;
      IF (l_txn_type_tab(l_index) = c_receipt) THEN
      --{
        l_prim_rcvd_qty :=   nvl(l_prim_rcvd_qty,0) + nvl(l_prim_qty_tab(l_index),0);
        l_sec_rcvd_qty  :=   nvl(l_sec_rcvd_qty,0)  + nvl(l_sec_qty_tab(l_index),0);
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'l_prim_rcvd_qty',l_prim_rcvd_qty);
        END IF;
      --}
      ELSIF (l_txn_type_tab(l_index) = c_rtv and l_parent_txn_type_tab(l_index) = c_receipt) THEN
      --{
        l_prim_ret_qty := nvl(l_prim_ret_qty,0) + nvl(l_prim_qty_tab(l_index),0);
        l_sec_ret_qty := nvl(l_sec_ret_qty,0) + nvl(l_sec_qty_tab(l_index), 0);
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'l_prim_ret_qty',l_prim_ret_qty);
        END IF;
      --}
      ELSIF (l_txn_type_tab(l_index) = c_correct and l_parent_txn_type_tab(l_index) = c_receipt) THEN
      --{
        l_prim_rcvd_corr_qty := nvl(l_prim_rcvd_corr_qty, 0) + nvl(l_prim_qty_tab(l_index),0);
        l_sec_rcvd_corr_qty := nvl(l_sec_rcvd_corr_qty,0) + nvl(l_sec_qty_tab(l_index), 0);
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'l_prim_rcvd_corr_qty',l_prim_rcvd_corr_qty);
        END IF;
      --}
      ELSIF (l_txn_type_tab(l_index) = c_correct and l_parent_txn_type_tab(l_index) = c_rtv) THEN
      --{
        l_prim_rtv_corr_qty := nvl(l_prim_rtv_corr_qty, 0) + nvl(l_prim_qty_tab(l_index),0);
   l_sec_rtv_corr_qty := nvl(l_sec_rtv_corr_qty,0) + nvl(l_sec_qty_tab(l_index), 0);
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'l_prim_rtv_corr_qty',l_prim_rtv_corr_qty);
        END IF;
      --}
      END IF;
      l_index := l_prim_qty_tab.next(l_index);
    --}
    end loop;

    -- Finally adding up all the quantities and setting the out parameters.
    x_prim_rcvd_qty      := nvl(l_prim_rcvd_qty,0) + nvl(l_prim_rcvd_corr_qty,0);
    x_sec_rcvd_qty       := nvl(l_sec_rcvd_qty,0) + nvl(l_sec_rcvd_corr_qty,0);
    x_prim_ret_qty       := nvl(l_prim_ret_qty,0) + nvl(l_prim_rtv_corr_qty,0);
    x_sec_ret_qty        := nvl(l_sec_ret_qty,0) + nvl(l_sec_rtv_corr_qty,0);
    x_primary_uom_code   := l_primary_uom_code;
    x_secondary_uom_code := l_secondary_uom_code;
    x_max_rcv_txn_id     := l_max_txn_id;
  --}
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'x_max_rcv_txn_id',x_max_rcv_txn_id);
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
      wsh_util_core.default_handler('WSH_IB_UI_RECON_GRP.GET_CUM_RCVD_RTV_QUANTITIES', l_module_name);
  --}
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
  END IF;
  --
  END get_cum_rcvd_rtv_quantities;

--========================================================================
-- PROCEDURE : Get_Shipment_Lines      This procedure is called only from
--                                     the Inbound Reconciliation UI
--
-- PARAMETERS: p_api_version           known api version error number
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             p_shipment_header_id    Shipment Header Id of the transaction
--             p_transaction_type      transaction type (ASN or RECEIPT)
--             p_view_only_flag        Used to decide wether to query all
--                                     rcv shipment lines or only the ones
--                                     that user is matching.
--                                     It gets a value of "Y" if user is
--                                     reverting a transaction or viewing a
--                                     matched transaction.  Otherwise it gets
--                                     "N".
--             x_shpmt_lines_out_rec   This is a record of tables
--                                     to store the rcv shipment lines
--                                     information that needs to be displayed.
--             x_max_rcv_txn_id        Not used anymore
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             x_return_status         return status of the API

-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This procedure is used to query the rcv shipment lines
--             from rcv_fte_lines_v
--             based on the transaction type and other input parameters
--             mentioned.  We are using a procedure to do this instead
--             of doing a direct query because we need to get the
--             cumulative quantities of the received quantity and
--             returned quantity for the receipt transaction.
--             We finally return this information in a object of tables
--             to the UI.
--             Please refer to the file WSHITYPS.sql for the defn. of
--             WSH_IB_SHPMT_LINE_REC_TYPE.
--             Following the logical flow of this API -
--             1. If the transaction type is 'RECEIPT', then we call the API
--             get_cum_rcvd_rtv_quantities to the cumulative received quantities
--             and returned quantities for each shipment line id for that receipt
--             2. Then, if the uom of the quantitities for each line in rcv_shipment_lines
--             is different from the UOM on the corresponding delivery details
--             (i.e. delivery details belonging to the same po_line_location_id)
--             , then we call convert_quantity to convert the quantity on
--             rcv shipment_lines to the UOM present on the delivery details.
--
--========================================================================

  PROCEDURE get_shipment_lines(
              p_api_version_number     IN   NUMBER,
              p_init_msg_list          IN   VARCHAR2,
              p_commit         IN   VARCHAR2,
              p_shipment_header_id IN NUMBER,
              p_transaction_type   IN VARCHAR2,
              --p_max_rcv_txn_id     IN NUMBER,
              p_view_only_flag     IN VARCHAR2,
              x_shpmt_lines_out_rec OUT NOCOPY WSH_IB_SHPMT_LINE_REC_TYPE,
              x_max_rcv_txn_id OUT NOCOPY NUMBER,
              x_msg_count      OUT NOCOPY NUMBER,
              x_msg_data       OUT NOCOPY VARCHAR2,
              x_return_status OUT NOCOPY VARCHAR2)
  IS
  --{
    l_api_version_number      CONSTANT NUMBER := 1.0;
    l_api_name                CONSTANT VARCHAR2(30):= 'get_shipment_lines';

    -- This cursor is used to query all the shipment lines for a given
    -- shipment_header_id from rcv_fte_lines_v.  This cursor is used
    -- for the following cases -
    -- 1. When the Transaction Type is ASN or
    -- 2. When the Transaction Type is Receipt and the transaction
    -- is completely pending or
    -- 2. When this API is called from the Review Page to only view the
    -- data.
    cursor l_all_shipment_line_csr (p_shipment_header_id IN NUMBER) is
    select rfl.shipment_line_id,
           rfl.item_id,
           rfl.item_revision,
           rfl.item_description,
           rfl.truck_num,
           rfl.quantity_shipped,
           rfl.quantity_received,
           null quantity_returned,
           rfl.uom_code,
           rfl.unit_of_measure,
           rfl.po_release_id,
           rfl.packing_slip,
           rfl.container_num,
           rfl.line_num,
           rfl.shipment_unit_price,
           rfl.secondary_quantity_shipped,
           rfl.secondary_quantity_received,
           null secondary_quantity_returned,
           rfl.secondary_uom_code,
           rfl.secondary_unit_of_measure,
           rfl.po_header_id,
           rfl.po_line_id,
           rfl.po_line_location_id,
           rfl.po_segment1 po_order_num,
           rfl.po_ship_to_location_id,
           rfl.po_shipment_num,
           rfl.po_line_number,
           msiv.concatenated_segments item_number,
           porel.release_num,
           rfl.asn_line_flag,
           rfl.revision_num po_revision_num,
           porel.revision_num rel_revision_num
     from  rcv_fte_lines_v rfl,
           mtl_system_items_vl msiv,
           po_releases_all porel,
           rcv_shipment_lines rsl
     where rfl.shipment_header_id = p_shipment_header_id
     and   rsl.shipment_header_id = p_shipment_header_id
     and   rsl.shipment_line_id  = rfl.shipment_line_id
     and   rfl.item_id = msiv.inventory_item_id(+)
     and   rfl.organization_id = msiv.organization_id(+)
     and   rfl.po_release_id = porel.po_release_id(+)
     order by rfl.po_line_id,
              rfl.po_line_location_id,
              rfl.shipment_line_id;

    -- This cursor is used to query partial set of shipment lines for a given
    -- shipment_header_id from rcv_fte_lines_v.  This cursor is used
    -- when the status of the receipt transaction is MATCHED_AND_CHILD_PENDING
    -- and user is trying to the match the pending transactions for the receipt.
    -- We query only those lines for which there are records present in
    -- wsh_inbound_txn_history for that shipment_header_id.
    cursor l_partial_shipment_line_csr (p_shipment_header_id IN NUMBER) is
    select distinct rfl.shipment_line_id,
           rfl.item_id,
           rfl.item_revision,
           rfl.item_description,
           rfl.truck_num,
           rfl.quantity_shipped,
           rfl.quantity_received,
           null quantity_returned,
           rfl.uom_code,
           rfl.unit_of_measure,
           rfl.po_release_id,
           rfl.packing_slip,
           rfl.container_num,
           rfl.line_num,
           rfl.shipment_unit_price,
           rfl.secondary_quantity_shipped,
           rfl.secondary_quantity_received,
           null secondary_quantity_returned,
           rfl.secondary_uom_code,
           rfl.secondary_unit_of_measure,
           rfl.po_header_id,
           rfl.po_line_id,
           rfl.po_line_location_id,
           rfl.po_segment1 po_order_num,
           rfl.po_ship_to_location_id,
           rfl.po_shipment_num,
           rfl.po_line_number,
           msiv.concatenated_segments item_number,
           porel.release_num,
           rfl.asn_line_flag,
           rfl.revision_num po_revision_num,
           porel.revision_num rel_revision_num
     from  rcv_fte_lines_v rfl,
           mtl_system_items_vl msiv,
           po_releases_all porel,
           wsh_inbound_txn_history wth,
           rcv_shipment_lines rsl
     where rfl.shipment_header_id = p_shipment_header_id
     and   rsl.shipment_header_id = p_shipment_header_id
     and   rsl.shipment_line_id  = rfl.shipment_line_id
     and   rfl.item_id = msiv.inventory_item_id(+)
     and   rfl.organization_id = msiv.organization_id(+)
     and   rfl.po_release_id = porel.po_release_id(+)
     and   rfl.shipment_line_id = wth.shipment_line_id
     and   wth.shipment_header_id = p_shipment_header_id
     and   wth.transaction_type IN ('RECEIPT_CORRECTION','RTV', 'RTV_CORRECTION','RTV_CORRECTION_NEGATIVE','RTV_CORRECTION_POSITIVE','RECEIPT_ADD', 'RECEIPT_CORRECTION_NEGATIVE', 'RECEIPT_CORRECTION_POSITIVE')
     order by rfl.po_line_id,
              rfl.po_line_location_id,
              rfl.shipment_line_id;

     l_unit_of_measure VARCHAR2(32767);
     l_sec_unit_of_measure VARCHAR2(32767);

     --Cursor to check the status of the transaction.
     cursor l_txn_status_csr (p_shipment_header_id IN NUMBER) is
     select 'Y'
     from   wsh_inbound_txn_history
     where  shipment_header_id = p_shipment_header_id
     and    transaction_type = 'RECEIPT'
     and    status like 'MATCHED%';

     shpmt_line_rec l_partial_shipment_line_csr%ROWTYPE;

     -- This cursor is used to get the UOM on the delivery details
     -- for the corresponding po_line_location_id
     cursor l_get_del_det_item_csr(p_po_line_location_id IN NUMBER,
                                   p_po_line_id IN NUMBER) is
     select wdd.inventory_item_id,
            wdd.requested_quantity_uom,
            wdd.organization_id,
            muom.unit_of_measure,
            wdd.src_requested_quantity,
            wdd.src_requested_quantity2
     from   wsh_delivery_details wdd,
            mtl_units_of_measure muom
     where  wdd.source_line_id = p_po_line_id
     and    wdd.po_shipment_line_id = p_po_line_location_id
     and    wdd.source_code = 'PO'
     and    wdd.requested_quantity_uom = muom.uom_code
     and    rownum =1;

     l_src_requested_qty NUMBER;
     l_src_requested_qty2 NUMBER;

     -- This cursor is used to derive pass a unique transaction type number
     -- for each shipment line.  This is important because
     -- this transaction type number is used in the UI to change
     -- query conditions on the delivery details.
     cursor l_txn_type_num_csr(p_shipment_header_id IN NUMBER, p_shipment_line_id IN NUMBER) is
     select DISTINCT DECODE(transaction_type, 'RECEIPT_ADD',1, 'RECEIPT_CORRECTION_POSITIVE',2,'RECEIPT_CORRECTION_NEGATIVE', 3, 'RTV',4, 'RTV_CORRECTION_NEGATIVE',5, 'RTV_CORRECTION_POSITIVE',6,7) txn_type
     from   wsh_inbound_txn_history
     where  shipment_line_id = p_shipment_line_id
     and    shipment_header_id = p_shipment_header_id
     and    transaction_type IN ('RECEIPT_ADD', 'RECEIPT_CORRECTION_POSITIVE', 'RECEIPT_CORRECTION_NEGATIVE', 'RTV', 'RTV_CORRECTION_NEGATIVE', 'RTV_CORRECTION_POSITIVE')
     order by txn_type;

     -- This cursor is used to check whether there is atleast one record in
     -- rcv_transactions table for the corresponding shipment_line_id.
     cursor l_chk_receipt_txn_csr(p_shipment_line_id IN NUMBER) is
     select 'X'
     from   rcv_transactions
     where  shipment_line_id = p_shipment_line_id
     and  transaction_type in ('RECEIVE', 'MATCH')
     and rownum=1;

     l_rcv_txn_rec_exists_flag VARCHAR2(1);

     cursor l_lock_txn_hist_csr (p_shipment_header_id IN NUMBER,
                                 p_transaction_type IN VARCHAR2) is
     select 'X'
     from   wsh_inbound_txn_history
     where  shipment_header_id = p_shipment_header_id
     and    transaction_type = p_transaction_type
     FOR UPDATE OF STATUS NOWAIT;

     cursor l_max_with_txn_id_csr (p_shipment_header_id IN NUMBER, p_shipment_line_id IN NUMBER) is
     select max(transaction_id)
     from   wsh_inbound_txn_history
     where  shipment_line_id = p_shipment_line_id
     and    shipment_header_id = p_shipment_header_id;

     l_lock_history_temp VARCHAR2(1);
     l_lock_obtained BOOLEAN;

     -- Cursor to check whether there was the receipt was recorded
     -- against an ASN or not
     cursor l_parent_txn_csr (p_shipment_header_id IN NUMBER) is
     select 'Y'
     from   wsh_inbound_txn_history
     where  shipment_header_id = p_shipment_header_id
     and    transaction_type = 'ASN';

     l_parent_txn_csr_opened BOOLEAN := FALSE;
     l_rcpt_against_asn_flag VARCHAR2(10) := 'N';

     -- Cursor to check if there are already matched delivery
     -- details for the add_to_receipt transaction_type.
     cursor l_matched_det_exist_csr (p_source_header_id IN NUMBER,
                              p_source_line_id IN NUMBER,
                              p_po_shpmt_line_id IN NUMBER,
                              p_rcv_shpmt_line_id IN NUMBER) is

     select 'Y'
     from   wsh_delivery_details
     where  source_header_id = p_source_header_id
     and    source_line_id   = p_source_line_id
     and    po_shipment_line_id = p_po_shpmt_line_id
     and    rcv_shipment_line_id = p_rcv_shpmt_line_id
     and    rownum = 1;

     l_matched_details_exist_flag VARCHAR2(10) := 'N';
    --
    --
    l_txn_type        VARCHAR2(32767) := p_transaction_type;
    l_dd_item_id      NUMBER;
    l_dd_uom_code     VARCHAR2(32767);
    l_dd_organization_id NUMBER;
    l_prim_rcvd_qty   NUMBER;
    l_prim_ret_qty    NUMBER;
    l_sec_rcvd_qty    NUMBER;
    l_sec_ret_qty     NUMBER;
    l_prim_rcv_uom_code   VARCHAR2(32767);
    l_sec_rcv_uom_code    VARCHAR2(32767);
    l_delete_rec_flag VARCHAR2(1);
    l_index           NUMBER;
    l_return_status   VARCHAR2(1);
    l_num_errors      NUMBER := 0;
    l_num_warnings    NUMBER := 0;
    l_pkg_name        VARCHAR2(32767);
    l_max_rcv_txn_id  NUMBER;
    l_status_matched_flag VARCHAR2(1);
    l_txn_type_number NUMBER;
    e_next_record     EXCEPTION;

    record_locked exception;
    PRAGMA EXCEPTION_INIT(record_locked, -54);
    --
    --
  --}
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_SHIPMENT_LINES';
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
        WSH_DEBUG_SV.log(l_module_name,'P_SHIPMENT_HEADER_ID',P_SHIPMENT_HEADER_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_TRANSACTION_TYPE',P_TRANSACTION_TYPE);
        --WSH_DEBUG_SV.log(l_module_name,'P_MAX_RCV_TXN_ID',P_MAX_RCV_TXN_ID);
    END IF;
    --
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --
    IF NOT FND_API.Compatible_API_Call
      ( l_api_version_number,
        p_api_version_number,
        l_api_name,
        l_pkg_name
       )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --
    -- setting the return status
     x_return_status := wsh_util_core.g_ret_sts_success;
    -- instantiating the table.

    -- Locking the transaction history to make sure that no other process
    -- works on this transaction

    SAVEPOINT lock_txn_history_sp;
    open l_lock_txn_hist_csr(p_shipment_header_id, p_transaction_type);
    fetch l_lock_txn_hist_csr into l_lock_history_temp;
    l_lock_obtained := l_lock_txn_hist_csr%FOUND;
    close l_lock_txn_hist_csr;
    IF (NOT l_lock_obtained) THEN
    --{
      FND_MESSAGE.SET_NAME('WSH','WSH_IB_TXN_UPDATE_ERROR');
      wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
      RAISE FND_API.G_EXC_ERROR;
    --}
    END IF;

    --
    x_shpmt_lines_out_rec := WSH_IB_SHPMT_LINE_REC_TYPE(WSH_NUM_TBL_TYPE(),
                                                        WSH_NUM_TBL_TYPE(),
                                                        WSH_VAR_TBL_TYPE(),
                                                        WSH_VAR_TBL_TYPE(),
                                                        WSH_VAR_TBL_TYPE(),
                                                        WSH_NUM_TBL_TYPE(),
                                                        WSH_NUM_TBL_TYPE(),
                                                        WSH_NUM_TBL_TYPE(),
                                                        WSH_VAR_TBL_TYPE(),
                                                        WSH_VAR_TBL_TYPE(),
                                                        WSH_NUM_TBL_TYPE(),
                                                        WSH_VAR_TBL_TYPE(),
                                                        WSH_VAR_TBL_TYPE(),
                                                        WSH_NUM_TBL_TYPE(),
                                                        WSH_VAR_TBL_TYPE(),
                                                        WSH_NUM_TBL_TYPE(),
                                                        WSH_NUM_TBL_TYPE(),
                                                        WSH_NUM_TBL_TYPE(),
                                                        WSH_VAR_TBL_TYPE(),
                                                        WSH_VAR_TBL_TYPE(),
                                                        WSH_VAR_TBL_TYPE(),
                                                        WSH_NUM_TBL_TYPE(),
                                                        WSH_NUM_TBL_TYPE(),
                                                        WSH_NUM_TBL_TYPE(),
                                                        WSH_VAR_TBL_TYPE(),
                                                        WSH_NUM_TBL_TYPE(),
                                                        WSH_NUM_TBL_TYPE(),
                                                        WSH_NUM_TBL_TYPE(),
                                                        WSH_NUM_TBL_TYPE(),
                                                        WSH_NUM_TBL_TYPE(),
                                                        WSH_NUM_TBL_TYPE());
    --
    IF l_txn_type = 'RECEIPT' THEN
    --{
      open  l_txn_status_csr(p_shipment_header_id);
      fetch l_txn_status_csr into l_status_matched_flag;
      close l_txn_status_csr;
    --}
    ElSE
    --{
      l_status_matched_flag := 'N';
    --}
    END IF;
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_status_matched_flag',nvl(l_status_matched_flag,'N'));
        WSH_DEBUG_SV.log(l_module_name,'p_view_only_flag',nvl(p_view_only_flag,'N'));
    END IF;
    -- This condition is to make sure that the transaction status is matched and its
    -- child txns are pending and that the user trying to match the pending transaction.
    IF (nvl(l_status_matched_flag, 'N') = 'Y' AND nvl(p_view_only_flag,'N') <> 'Y') THEN
    --{
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'opening l_partial_shipment_line_csr');
      END IF;
      open l_partial_shipment_line_csr(p_shipment_header_id);
    --}
    ELSE
    --{
      -- otherwise we query all the shipment lines belonging to the header.
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'opening l_all_shipment_line_csr');
      END IF;
      open l_all_shipment_line_csr(p_shipment_header_id);
    --}
    END IF;
    --FOR shpmt_line_rec IN l_shipment_line_csr(p_shipment_header_id)
    LOOP
    --{
      BEGIN
      --{
        --initializing the variables for every record in the loop
        l_txn_type_number := 0;
        l_rcv_txn_rec_exists_flag := NULL;

        --
        IF (nvl(l_status_matched_flag, 'N') = 'Y' AND nvl(p_view_only_flag,'N') <> 'Y') THEN
        --{
          -- we need to fetch this data only for receipts that are partially matched
          fetch l_partial_shipment_line_csr into shpmt_line_rec;
          -- We need to pass the transaction type number to the UI because,
          -- depending what child transactions are pending for each shipment line
          EXIT WHEN l_partial_shipment_line_csr%NOTFOUND;
          -- the query on the delivery details changes.
          open  l_txn_type_num_csr(p_shipment_header_id,shpmt_line_rec.shipment_line_id);
          fetch l_txn_type_num_csr into l_txn_type_number;
          close l_txn_type_num_csr;
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_txn_type_number',l_txn_type_number);
          END IF;
          -- The below condition has been added because, if the receipt
          -- is against an ASN and that the transaction_type is
          -- RECEIPT_ADD and if there is already a record in
          -- wdd matched against that shipment_line_id, then
          -- we need to treat it as RECEIPT_CORRECTION_POSITIVE.
          IF (nvl(l_txn_type_number,-9999) = 1) THEN
          --{
            -- need to reset the flag for every shpmt line
            l_matched_details_exist_flag := 'N';

            IF (NOT l_parent_txn_csr_opened) THEN
            --{
              open  l_parent_txn_csr(p_shipment_header_id);
              fetch l_parent_txn_csr into l_rcpt_against_asn_flag;
              close l_parent_txn_csr;
              l_parent_txn_csr_opened := TRUE;
            --}
            END IF;
            IF (nvl(l_rcpt_against_asn_flag,'N') = 'Y') THEN
            --{
              open l_matched_det_exist_csr(
                     shpmt_line_rec.po_header_id,
                     shpmt_line_rec.po_line_id,
                     shpmt_line_rec.po_line_location_id,
                     shpmt_line_rec.shipment_line_id);
              fetch l_matched_det_exist_csr into l_matched_details_exist_flag;
              close l_matched_det_exist_csr;
              IF (nvl(l_matched_details_exist_flag,'N') = 'Y') THEN
              --{
                -- changing the transaction type to 'Rcpt Correction Positive'
                l_txn_type_number := 2;
              --}
              END IF;
            --}
            END IF;
          --}
          END IF;
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_txn_type_number after the check',l_txn_type_number);
          END IF;
        --}
        ELSE
        --{
          fetch l_all_shipment_line_csr into shpmt_line_rec;
          EXIT WHEN l_all_shipment_line_csr%NOTFOUND;
        --}
        END IF;
        --
        IF (nvl(shpmt_line_rec.asn_line_flag,'N')  = 'Y' AND p_transaction_type = 'RECEIPT') THEN
        --{
          -- This is very important check.  This tells us whether the record in
          -- rcv_shipment_lines actually belongs to the receipt or if that shipment
          -- line was created as a part of the ASN transaction.
          open  l_chk_receipt_txn_csr(shpmt_line_rec.shipment_line_id);
          fetch l_chk_receipt_txn_csr into l_rcv_txn_rec_exists_flag;
          close l_chk_receipt_txn_csr;

          IF l_rcv_txn_rec_exists_flag IS NULL THEN
            raise e_next_record;
          END IF;
        --}
        END IF;
        --
        l_dd_uom_code := NULL;
        --
        --
        -- We need to get the cumulative received and returned quantities only for
        -- transaction type 'RECEIPT'.  It is not required for ASN.
        IF l_txn_type = 'RECEIPT' THEN
        --{
          get_cum_rcvd_rtv_quantities(
            p_shipment_line_id   => shpmt_line_rec.shipment_line_id,
            --p_max_rcv_txn_id     => p_max_rcv_txn_id,
            x_prim_rcvd_qty      => l_prim_rcvd_qty,
            x_prim_ret_qty       => l_prim_ret_qty,
            x_primary_uom_code   => l_prim_rcv_uom_code,
            x_sec_rcvd_qty       => l_sec_rcvd_qty,
            x_sec_ret_qty        => l_sec_ret_qty,
            x_secondary_uom_code => l_sec_rcv_uom_code,
            x_delete_rec_flag    => l_delete_rec_flag,
            x_max_rcv_txn_id     => l_max_rcv_txn_id,
            x_return_status      => l_return_status
           );
          --
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_prim_rcvd_qty', l_prim_rcvd_qty);
              WSH_DEBUG_SV.log(l_module_name,'l_prim_ret_qty',  l_prim_ret_qty);
              WSH_DEBUG_SV.log(l_module_name,'l_prim_rcv_uom_code', l_prim_rcv_uom_code);
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          wsh_util_core.api_post_call(
            p_return_status    => l_return_status,
            x_num_warnings     => l_num_warnings,
            x_num_errors       => l_num_errors);
        --}
        END IF;
        --
        -- Initializing the out record with all the columns except
        -- the quantities and UOMs.
        --
        --IF nvl(l_delete_rec_flag, 'N') = 'N' THEN
        --{
        IF (l_max_rcv_txn_id IS NOT NULL) THEN
        --{
          IF (x_max_rcv_txn_id IS NULL) THEN
          --{
            x_max_rcv_txn_id := l_max_rcv_txn_id;
          --}
          ELSIF (x_max_rcv_txn_id < l_max_rcv_txn_id) THEN
          --{
            x_max_rcv_txn_id := l_max_rcv_txn_id;
          --}
          END IF;
        --}
        END IF;
        x_shpmt_lines_out_rec.shipment_line_id_tab.extend;
        x_shpmt_lines_out_rec.item_id_tab.extend;
        x_shpmt_lines_out_rec.item_revision_tab.extend;
        x_shpmt_lines_out_rec.item_description_tab.extend;
        x_shpmt_lines_out_rec.truck_num_tab.extend;
        x_shpmt_lines_out_rec.primary_qty_shipped_tab.extend;
        x_shpmt_lines_out_rec.primary_qty_received_tab.extend;
        x_shpmt_lines_out_rec.primary_qty_returned_tab.extend;
        x_shpmt_lines_out_rec.primary_uom_code_tab.extend;
        x_shpmt_lines_out_rec.primary_unit_of_measure_tab.extend;
        x_shpmt_lines_out_rec.po_release_id_tab.extend;
        x_shpmt_lines_out_rec.packing_slip_tab.extend;
        x_shpmt_lines_out_rec.container_num_tab.extend;
        x_shpmt_lines_out_rec.rcv_line_num_tab.extend;
        x_shpmt_lines_out_rec.shipment_unit_price_tab.extend;
        x_shpmt_lines_out_rec.secondary_qty_shipped_tab.extend;
        x_shpmt_lines_out_rec.secondary_qty_received_tab.extend;
        x_shpmt_lines_out_rec.secondary_qty_returned_tab.extend;
        x_shpmt_lines_out_rec.secondary_uom_code_tab.extend;
        x_shpmt_lines_out_rec.secondary_unit_of_measure_tab.extend;
        x_shpmt_lines_out_rec.item_number_tab.extend;
        x_shpmt_lines_out_rec.po_header_id_tab.extend;
        x_shpmt_lines_out_rec.po_line_id_tab.extend;
        x_shpmt_lines_out_rec.po_line_location_id_tab.extend;
        x_shpmt_lines_out_rec.po_order_num_tab.extend;
        x_shpmt_lines_out_rec.po_ship_to_location_id_tab.extend;
        x_shpmt_lines_out_rec.po_line_location_num_tab.extend;
        x_shpmt_lines_out_rec.po_line_num_tab.extend;
        x_shpmt_lines_out_rec.po_revision_num_tab.extend;
        x_shpmt_lines_out_rec.txn_type_number_tab.extend;
        x_shpmt_lines_out_rec.max_txn_id_tab.extend;
        --
        l_index := x_shpmt_lines_out_rec.shipment_line_id_tab.count;
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Before assigning the values');
            WSH_DEBUG_SV.log(l_module_name,'l_index',l_index);
        END IF;
        open  l_max_with_txn_id_csr(p_shipment_header_id, shpmt_line_rec.shipment_line_id);
        fetch l_max_with_txn_id_csr into x_shpmt_lines_out_rec.max_txn_id_tab(l_index);
        close l_max_with_txn_id_csr;
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'x_shpmt_lines_out_rec.max_txn_id_tab('|| l_index||')',x_shpmt_lines_out_rec.max_txn_id_tab(l_index));
        END IF;
        x_shpmt_lines_out_rec.shipment_line_id_tab(l_index) := shpmt_line_rec.shipment_line_id;
        x_shpmt_lines_out_rec.item_id_tab(l_index) := shpmt_line_rec.item_id;
        x_shpmt_lines_out_rec.item_revision_tab(l_index) := shpmt_line_rec.item_revision;
        x_shpmt_lines_out_rec.item_description_tab(l_index) := shpmt_line_rec.item_description;
        x_shpmt_lines_out_rec.truck_num_tab(l_index) := shpmt_line_rec.truck_num;
        x_shpmt_lines_out_rec.po_release_id_tab(l_index) := shpmt_line_rec.po_release_id;
        x_shpmt_lines_out_rec.packing_slip_tab(l_index) := shpmt_line_rec.packing_slip;
        x_shpmt_lines_out_rec.container_num_tab(l_index) := shpmt_line_rec.container_num;
        x_shpmt_lines_out_rec.rcv_line_num_tab(l_index) := shpmt_line_rec.line_num;
        x_shpmt_lines_out_rec.shipment_unit_price_tab(l_index) := shpmt_line_rec.shipment_unit_price;
        x_shpmt_lines_out_rec.item_number_tab(l_index) := shpmt_line_rec.item_number;
        x_shpmt_lines_out_rec.po_header_id_tab(l_index) := shpmt_line_rec.po_header_id;
        x_shpmt_lines_out_rec.po_line_id_tab(l_index) := shpmt_line_rec.po_line_id;
        x_shpmt_lines_out_rec.po_line_location_id_tab(l_index) := shpmt_line_rec.po_line_location_id;
        IF (shpmt_line_rec.release_num is not null ) THEN
        --{
          x_shpmt_lines_out_rec.po_order_num_tab(l_index) := shpmt_line_rec.po_order_num || '-' || shpmt_line_rec.release_num;
        --}
        ELSE
        --{
          x_shpmt_lines_out_rec.po_order_num_tab(l_index) := shpmt_line_rec.po_order_num;
        --}
        END IF;
        x_shpmt_lines_out_rec.po_ship_to_location_id_tab(l_index) := shpmt_line_rec.po_ship_to_location_id;
        x_shpmt_lines_out_rec.po_line_location_num_tab(l_index) := shpmt_line_rec.po_shipment_num;
        x_shpmt_lines_out_rec.po_line_num_tab(l_index) := shpmt_line_rec.po_line_number;
        x_shpmt_lines_out_rec.po_revision_num_tab(l_index) := nvl(shpmt_line_rec.rel_revision_num, shpmt_line_rec.po_revision_num);
        x_shpmt_lines_out_rec.txn_type_number_tab(l_index) := l_txn_type_number;
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'After assigning the values');
            WSH_DEBUG_SV.log(l_module_name,'l_txn_type_number', l_txn_type_number);
        END IF;
        --
        --
        open  l_get_del_det_item_csr(shpmt_line_rec.po_line_location_id,
                                     shpmt_line_rec.po_line_id);
        fetch l_get_del_det_item_csr into l_dd_item_id, l_dd_uom_code, l_dd_organization_id, l_unit_of_measure,l_src_requested_qty,l_src_requested_qty2;
        close l_get_del_det_item_csr;

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'l_dd_uom_code', l_dd_uom_code);
          WSH_DEBUG_SV.log(l_module_name,'l_dd_item_id', l_dd_item_id);
          WSH_DEBUG_SV.log(l_module_name,'l_src_requested_qty', l_src_requested_qty);
          WSH_DEBUG_SV.log(l_module_name,'l_src_requested_qty2', l_src_requested_qty2);
        END IF;
        IF l_txn_type = 'RECEIPT' THEN
        --{
          IF l_dd_uom_code = l_prim_rcv_uom_code THEN
          --{
            x_shpmt_lines_out_rec.primary_qty_received_tab(l_index)   := l_prim_rcvd_qty;
            x_shpmt_lines_out_rec.primary_qty_returned_tab(l_index)   := l_prim_ret_qty;
            x_shpmt_lines_out_rec.primary_uom_code_tab(l_index)       := l_dd_uom_code;
            x_shpmt_lines_out_rec.secondary_qty_received_tab(l_index) := l_sec_rcvd_qty;
            x_shpmt_lines_out_rec.secondary_qty_returned_tab(l_index) := l_sec_ret_qty;
            x_shpmt_lines_out_rec.secondary_uom_code_tab(l_index)     := l_sec_rcv_uom_code;
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_unit_of_measure', l_unit_of_measure);
            END IF;
            x_shpmt_lines_out_rec.primary_unit_of_measure_tab(l_index):= l_unit_of_measure;
            x_shpmt_lines_out_rec.secondary_unit_of_measure_tab(l_index):= shpmt_line_rec.secondary_unit_of_measure;
          --}
          ELSE
          --{
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_UTIL_PKG.CONVERT_QUANTITY For received quantity',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_INBOUND_UTIL_PKG.convert_quantity(
              p_inv_item_id      => l_dd_item_id,
              p_organization_id  => l_dd_organization_id,
              p_primary_uom_code => l_dd_uom_code,
              p_quantity         => l_prim_rcvd_qty,
              p_qty_uom_code     => l_prim_rcv_uom_code,
              x_conv_qty         => x_shpmt_lines_out_rec.primary_qty_received_tab(l_index),
              x_return_status => l_return_status);
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
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_UTIL_PKG.CONVERT_QUANTITY For returned quantity',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_INBOUND_UTIL_PKG.convert_quantity(
              p_inv_item_id      => l_dd_item_id,
              p_organization_id  => l_dd_organization_id,
              p_primary_uom_code => l_dd_uom_code,
              p_quantity         => l_prim_ret_qty,
              p_qty_uom_code     => l_prim_rcv_uom_code,
              x_conv_qty         => x_shpmt_lines_out_rec.primary_qty_returned_tab(l_index),
              x_return_status => l_return_status);
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

            x_shpmt_lines_out_rec.primary_uom_code_tab(l_index) := l_dd_uom_code;
            x_shpmt_lines_out_rec.primary_unit_of_measure_tab(l_index):= l_unit_of_measure;
            x_shpmt_lines_out_rec.secondary_unit_of_measure_tab(l_index):= shpmt_line_rec.secondary_unit_of_measure;
          --}
          END IF;
        --}
        ELSE
        --{
          IF l_dd_uom_code = shpmt_line_rec.uom_code THEN
          --{
            x_shpmt_lines_out_rec.primary_qty_shipped_tab(l_index)   := shpmt_line_rec.quantity_shipped;
            x_shpmt_lines_out_rec.primary_uom_code_tab(l_index)     := shpmt_line_rec.uom_code;
            x_shpmt_lines_out_rec.secondary_qty_shipped_tab(l_index) := shpmt_line_rec.secondary_quantity_shipped;
            x_shpmt_lines_out_rec.secondary_uom_code_tab(l_index)    := shpmt_line_rec.secondary_uom_code;
            x_shpmt_lines_out_rec.primary_unit_of_measure_tab(l_index):= l_unit_of_measure;
            x_shpmt_lines_out_rec.secondary_unit_of_measure_tab(l_index):= shpmt_line_rec.secondary_unit_of_measure;
          --}
          ELSE
          --{
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_UTIL_PKG.CONVERT_QUANTITY For shipped quantity',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_INBOUND_UTIL_PKG.convert_quantity(
              p_inv_item_id      => l_dd_item_id,
              p_organization_id  => l_dd_organization_id,
              p_primary_uom_code => l_dd_uom_code,
              p_quantity         => shpmt_line_rec.quantity_shipped,
              p_qty_uom_code     => shpmt_line_rec.uom_code,
              x_conv_qty         => x_shpmt_lines_out_rec.primary_qty_shipped_tab(l_index),
              x_return_status => l_return_status);
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
            x_shpmt_lines_out_rec.primary_uom_code_tab(l_index) := l_dd_uom_code;
            x_shpmt_lines_out_rec.primary_unit_of_measure_tab(l_index):= l_unit_of_measure;
            x_shpmt_lines_out_rec.secondary_unit_of_measure_tab(l_index):= shpmt_line_rec.secondary_unit_of_measure;
            x_shpmt_lines_out_rec.primary_uom_code_tab(l_index):= shpmt_line_rec.uom_code;
          --}
          END IF;
          IF (x_shpmt_lines_out_rec.secondary_qty_shipped_tab(l_index) IS NULL
              AND l_src_requested_qty2 IS NOT NULL) THEN
          --{
-- HW OPMCONV - No need to use OPM precision. Use current INV which is 5
            x_shpmt_lines_out_rec.secondary_qty_shipped_tab(l_index) :=
               ROUND (
                 l_src_requested_qty2 * x_shpmt_lines_out_rec.primary_qty_shipped_tab(l_index)/l_src_requested_qty, WSH_UTIL_CORE.C_MAX_DECIMAL_DIGITS_INV
                     );
            l_src_requested_qty2 := NULL;
          --}
          END IF;
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'sec shipped quantity', x_shpmt_lines_out_rec.secondary_qty_shipped_tab(l_index));
          END IF;
        --}
        END IF;
        --}
        --END IF;
      --}
      EXCEPTION
      --{
        WHEN e_next_record THEN
          null;
        WHEN OTHERS THEN
          raise;
      --}
      END;
    --}
    END LOOP;
    IF l_all_shipment_line_csr%ISOPEN THEN
      close l_all_shipment_line_csr;
    END IF;
    IF l_partial_shipment_line_csr%ISOPEN THEN
      close l_partial_shipment_line_csr;
    END IF;

    -- We need to rollback to release the lock on the transaction history
    rollback to lock_txn_history_sp;

    IF x_shpmt_lines_out_rec.shipment_line_id_tab.count = 0 THEN
      FND_MESSAGE.SET_NAME('WSH','NO_DATA_FOUND');
      x_return_status := wsh_util_core.g_ret_sts_error;
      wsh_util_core.add_message(x_return_status, l_module_name);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    --
    FND_MSG_PUB.Count_And_Get
      (
       p_count  => x_msg_count,
       p_data  =>  x_msg_data,
       p_encoded => FND_API.G_FALSE
      );
     --IF (x_msg_count IS NULL ) THEN
      -- x_msg_count := 0;
    -- END IF;
    --
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name, 'x_max_rcv_txn_id',x_max_rcv_txn_id);
      --wsh_debug_sv.log(l_module_name, 'Number of records in x_shpmt_lines_out_rec',x_shpmt_lines_out_rec.shipment_line_id_tab.count);
      --wsh_debug_sv.log(l_module_name, 'Shipment line id 1 is',x_shpmt_lines_out_rec.shipment_line_id_tab(1));
      --wsh_debug_sv.log(l_module_name, 'Received Qty 1 is',x_shpmt_lines_out_rec.primary_qty_received_tab(1));
      --wsh_debug_sv.log(l_module_name, 'Received Qty 2 is',x_shpmt_lines_out_rec.primary_qty_received_tab(2));
      --wsh_debug_sv.log(l_module_name, 'Returned Qty 1 is',x_shpmt_lines_out_rec.primary_qty_returned_tab(1));
      --wsh_debug_sv.log(l_module_name, 'Returned Qty 2 is',x_shpmt_lines_out_rec.primary_qty_returned_tab(2));
      --wsh_debug_sv.log(l_module_name, 'Uom Code is',x_shpmt_lines_out_rec.primary_uom_code_tab(1));
      --wsh_debug_sv.log(l_module_name, 'Shipment line id 2 is',x_shpmt_lines_out_rec.shipment_line_id_tab(2));
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  --}
  EXCEPTION
  --{
    WHEN RECORD_LOCKED THEN
      ROLLBACK TO SAVEPOINT lock_txn_history_sp;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('WSH','WSH_IB_TXN_LOCK_ERROR');
      wsh_util_core.add_message(x_return_status,l_module_name);
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'RECORD_LOCKED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
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
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
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
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
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
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_IB_UI_RECON_GRP.GET_SHIPMENT_LINES', l_module_name);
      --
      FND_MSG_PUB.Count_And_Get
        (
         p_count  => x_msg_count,
         p_data  =>  x_msg_data,
         p_encoded => FND_API.G_FALSE
        );
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
  END get_shipment_lines;

--========================================================================
-- PROCEDURE : Revert_Matching         This procedure is called only from
--                                     the Inbound Reconciliation UI to
--                                     revert a matched ASN or a Receipt
--
-- PARAMETERS: p_api_version           known api version error number
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             p_shipment_header_id    Shipment Header Id of the transaction
--             p_transaction_type      transaction type (ASN or RECEIPT)
--             p_object_version_number current object version of the
--                                     transaction record in
--                                     wsh_inbound_txn_history
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             x_return_status         return status of the API

-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This procedure is used to revert a matched transaction (ASN or
--             RECEIPT)
--             The following is the flow of this procedure -
--             1. If the txn type is 'ASN', then we directly call
--                WSH_ASN_RECEIPT_PVT.Cancel_ASN with the action_code
--                as 'REVERT_ASN'.
--             2. If the txn type is 'RECEIPT', then we do the following -
--                > Call Revert_Details to revert the delivery details
--                > Call Revert_Deliveries to rever the deliveries
--                > If the revert_details API returns any records of delivery
--                > details that need to be unassigned from the delivery, then
--                > we call WSH_DELIVERY_DETAILS_ACTIONS.
--                > Unassign_Multiple_Details.  We need to do this only for
--                > delivery details that ship_from_location_id as -1.
--                > Then we call WSH_PO_CMG_PVT.Reapprove_PO as the
--                > lines that have been re-opened need to be updated with the
--                > latest information from po shipment lines.
--             3. Finally we call WSH_INBOUND_TXN_HISTORY_PKG.post_process
--                to set the status of the transaction history record appropriately.
--========================================================================
  PROCEDURE revert_matching(
              p_api_version_number     IN   NUMBER,
              p_init_msg_list          IN   VARCHAR2,
              p_commit         IN   VARCHAR2,
              p_shipment_header_id IN NUMBER,
              p_transaction_type IN VARCHAR2,
              p_object_version_number  IN   NUMBER,
              x_msg_count      OUT NOCOPY NUMBER,
              x_msg_data       OUT NOCOPY VARCHAR2,
              x_return_status OUT NOCOPY VARCHAR2)
  IS
  --{
    l_api_version_number      CONSTANT NUMBER := 1.0;
    l_api_name                CONSTANT VARCHAR2(30):= 'revert_matching';

    -- This cursor is used to check whether there is a receipt transaction
    -- that is matched.  We do not want to allow reverting of ASN if the
    -- receipt is already matched or partially matched.
    cursor l_child_txn_sts_csr(p_shipment_header_id NUMBER) is
    select status, receipt_number
    from wsh_inbound_txn_history
    where shipment_header_id = p_shipment_header_id
    and transaction_type = 'RECEIPT';

    l_child_txn_sts VARCHAR2(32767);
    l_receipt_num VARCHAR2(32767);
    l_action_prms WSH_BULK_TYPES_GRP.action_parameters_rectype;
    l_cancel_asn_action_prms WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type;
    l_line_rec OE_WSH_BULK_GRP.Line_rec_type;
    l_out_rec WSH_BULK_TYPES_GRP.Bulk_process_out_rec_type;
    l_return_status VARCHAR2(1);

    l_dd_list WSH_PO_CMG_PVT.dd_list_type;
    l_delivery_id_tab  wsh_util_core.id_tab_type;
    l_status_code_tab  wsh_util_core.column_tab_type;
    l_unassign_det_id_tab  wsh_util_core.id_tab_type;
    l_po_action_prms WSH_BULK_TYPES_GRP.action_parameters_rectype;
    l_dd_id_unassigned wsh_util_core.id_tab_type;
    l_wt_vol_dd_id wsh_util_core.id_tab_type;
    l_unassign_action_prms WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type;

    l_num_errors      NUMBER := 0;
    l_num_warnings    NUMBER := 0;
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);
    l_pkg_name        VARCHAR2(32767);

    cursor l_parent_txn_exists_csr(p_shipment_header_id NUMBER) is
    select 'Y'
    from wsh_inbound_txn_history
    where shipment_header_id = p_shipment_header_id
    and transaction_type = 'ASN';

    l_parent_txn_exists_flag VARCHAR2(10) := 'N';

  --
    l_debugfile varchar2(2000);
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'REVERT_MATCHING';
  --
  --Bugfix 4070732
  l_api_session_name CONSTANT VARCHAR2(150) := G_PKG_NAME ||'.' || l_module_name;
  l_reset_flags BOOLEAN;
  --}
  BEGIN
    --{
    IF WSH_UTIL_CORE.G_START_OF_SESSION_API is null THEN  --Bugfix 4070732
      WSH_UTIL_CORE.G_START_OF_SESSION_API     := l_api_session_name;
      WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API := FALSE;
    END IF;

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
        WSH_DEBUG_SV.log(l_module_name,'P_SHIPMENT_HEADER_ID',P_SHIPMENT_HEADER_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_TRANSACTION_TYPE',P_TRANSACTION_TYPE);
        WSH_DEBUG_SV.log(l_module_name,'P_OBJECT_VERSION_NUMBER',P_OBJECT_VERSION_NUMBER);
    END IF;
    --
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --
    SAVEPOINT revert_matching_grp;
    x_return_status := wsh_util_core.g_ret_sts_success;
    --
    IF NOT FND_API.Compatible_API_Call
      ( l_api_version_number,
        p_api_version_number,
        l_api_name,
        l_pkg_name
       )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'After checking Compatible_API_Call');
    END IF;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'After initializing the message list');
    END IF;
    -- { IB-Phase-2
    -- For manual matching of Receipts, rating of Trips has to be done asynchronously.
    WSH_INBOUND_UTIL_PKG.G_ASN_RECEIPT_MATCH_TYPE := 'MANUAL';
    -- } IB-Phase-2

    IF p_transaction_type = 'ASN' THEN
    --{
      -- This is an additional check to take care of concurrency issues
      -- to make sure that there is no receipt that is already matched
      -- while we are reverting an ASN.
      open  l_child_txn_sts_csr(p_shipment_header_id);
      fetch l_child_txn_sts_csr into l_child_txn_sts, l_receipt_num;
      close l_child_txn_sts_csr;
      IF nvl(l_child_txn_sts,'@@') like 'MATCHED%' THEN
      --{
        FND_MESSAGE.SET_NAME('WSH','WSH_IB_RECEIPT_MATCHED_ERR');
        FND_MESSAGE.SET_TOKEN('RECEIPT_NUM',l_receipt_num);
        x_return_status := wsh_util_core.g_ret_sts_error;
        wsh_util_core.add_message(x_return_status, l_module_name);
        RAISE FND_API.G_EXC_ERROR;
      --}
      ELSE
      --{
        l_cancel_asn_action_prms.action_code := 'REVERT_ASN';
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ASN_RECEIPT_PVT.CANCEL_ASN',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        WSH_ASN_RECEIPT_PVT.Cancel_ASN(
          p_header_id => p_shipment_header_id,
         -- p_line_rec  => l_line_rec,
          p_action_prms => l_cancel_asn_action_prms,
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
          p_return_status    => l_return_status,
          x_num_warnings     => l_num_warnings,
          x_num_errors       => l_num_errors);
      --}
      END IF;
    --}
    ELSIF p_transaction_type = 'RECEIPT' THEN
    --{
      -- Need to call Nikhil's API
      -- setTripStopStatus
      --revert_trips(
      -- p_shipment_header_id => p_shipment_header_id,
      -- p_transaction_type   => p_transaction_type,
      -- x_return_status      => l_return_status);


      revert_details(
        p_shipment_header_id => p_shipment_header_id,
        p_transaction_type   => p_transaction_type,
        x_dd_list            => l_dd_list,
        x_delivery_id_tab    => l_delivery_id_tab,
        x_status_code_tab    => l_status_code_tab,
        x_unassign_det_id_tab => l_unassign_det_id_tab,
        x_msg_count          => l_msg_count,
        x_msg_data           => l_msg_data,
        x_return_status      => l_return_status);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'return status is ', l_return_status);
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors);

      revert_deliveries(
        p_delivery_id_tab    => l_delivery_id_tab,
        p_status_code_tab    => l_status_code_tab,
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

      IF ( l_unassign_det_id_tab.count > 0 ) THEN
      --{
        open  l_parent_txn_exists_csr(p_shipment_header_id);
        fetch l_parent_txn_exists_csr into l_parent_txn_exists_flag;
        close l_parent_txn_exists_csr;
        IF (nvl(l_parent_txn_exists_flag,'N') = 'Y') THEN
        --{
          l_unassign_action_prms.caller := wsh_util_core.C_IB_RECEIPT_PREFIX;
        --}
        ELSE
        --{
          l_unassign_action_prms.caller := wsh_util_core.C_IB_ASN_PREFIX;
        --}
        END IF;
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.UNASSIGN_MULTIPLE_DETAILS',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        --l_unassign_action_prms.caller := wsh_util_core.C_IB_RECEIPT_PREFIX;
        WSH_DELIVERY_DETAILS_ACTIONS.Unassign_Multiple_Details(
          P_REC_OF_DETAIL_IDS    => l_unassign_det_id_tab,
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
      --}
      END IF;

      IF (l_dd_list.delivery_detail_id.count > 0 ) THEN
      --{
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_PO_CMG_PVT.REAPPROVE_PO',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        l_po_action_prms.action_code := 'CANCEL_ASN';
       /*
        WSH_PO_CMG_PVT.Update_Attributes(
          p_line_rec       => l_line_rec,
          p_action_prms    => l_po_action_prms,
          p_dd_list        => l_dd_list,
          p_dd_id_unassigned => l_dd_id_unassigned,
          p_wt_vol_dd_id    => l_wt_vol_dd_id,
          x_return_status  => l_return_status);
        */
        -- It was found that calling Reapprove_PO is better than calling Update_Attributes
        -- because, it will also take care of other processing
        -- like calculate wt-vol, unassign etc.
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
      --}
      END IF;
    --}
    END IF;
    --
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_TXN_HISTORY_PKG.POST_PROCESS',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    --
    WSH_INBOUND_TXN_HISTORY_PKG.post_process(
      p_shipment_header_id     => p_shipment_header_id,
      p_max_rcv_txn_id         => NULL,
      p_action_code            => 'REVERT',
      p_txn_type               => p_transaction_type,
      p_object_version_number  => p_object_version_number,
      x_return_status          => l_return_status);
    --
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Return Status after calling WSH_INBOUND_TXN_HISTORY_PKG.post_process is ', l_return_status);
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    --
    wsh_util_core.api_post_call(
      p_return_status    => l_return_status,
      x_num_warnings     => l_num_warnings,
      x_num_errors       => l_num_errors);
    --
    IF l_debug_on THEN
    --{
      WSH_DEBUG_SV.log(l_module_name,'l_num_warnings', l_num_warnings);
      WSH_DEBUG_SV.log(l_module_name,'l_num_errors', l_num_errors);

      fnd_profile.get('WSH_DEBUG_LOG_DIRECTORY',l_debugfile);
      l_debugfile := l_debugfile||'/'||WSH_DEBUG_SV.g_file;

      FND_MESSAGE.SET_NAME('WSH','WSH_DEBUG_FILE_NAME');
      FND_MESSAGE.SET_TOKEN('DEBUG_FILE_NAME',l_debugfile);
      x_return_status := wsh_util_core.g_ret_sts_success;
      wsh_util_core.add_message(x_return_status, l_module_name);
    --}
    END IF;
    --

    IF l_num_errors   > 0 THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_num_warnings > 0 THEN
      RAISE WSH_UTIL_CORE.G_EXC_WARNING;
    ELSE
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN

      --bug 4070732
      IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
      --{

          l_reset_flags := FALSE;

          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Process_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          WSH_UTIL_CORE.Process_stops_for_load_tender(p_reset_flags   => l_reset_flags,
                                                      x_return_status => l_return_status);

          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
          END IF;

          IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            RAISE WSH_UTIL_CORE.G_EXC_WARNING;
          END IF;

      --}
      END IF;
      --bug 4070732

      COMMIT WORK;
    END IF;
    --
    --bug 4070732
    IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
    --{
        IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
        --{

           IF FND_API.To_Boolean( p_commit ) THEN

            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

            WSH_UTIL_CORE.reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                        x_return_status => l_return_status);

	   ELSE

            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Process_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

            WSH_UTIL_CORE.Process_stops_for_load_tender(p_reset_flags   => TRUE,
                                                        x_return_status => l_return_status);

	   END IF;

            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
            END IF;

            IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                   WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR,
                                   WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
              x_return_status := l_return_status;
            END IF;

            IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR,
                                   WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
              IF NOT FND_API.To_Boolean( p_commit ) THEN
                ROLLBACK TO REVERT_MATCHING_GRP;
              END IF;
            END IF;

        --}
        END IF;
    --}
    END IF;

    --bug 4070732
    --
    FND_MSG_PUB.Count_And_Get
      (
       p_count  => x_msg_count,
       p_data  =>  x_msg_data,
       p_encoded => FND_API.G_FALSE
      );
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
      ROLLBACK TO REVERT_MATCHING_GRP;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      --
      --
      -- Start code for Bugfix 4070732
      --
      IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
      --{
          IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                        x_return_status => l_return_status);


              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
              END IF;

              IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
              END IF;
          --}
          END IF;
      --}
      END IF;
      --
      -- End of Code Bugfix 4070732
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
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          fnd_profile.get('WSH_DEBUG_LOG_DIRECTORY',l_debugfile);
          l_debugfile := l_debugfile||'/'||WSH_DEBUG_SV.g_file;

          FND_MESSAGE.SET_NAME('WSH','WSH_DEBUG_FILE_NAME');
          FND_MESSAGE.SET_TOKEN('DEBUG_FILE_NAME',l_debugfile);
          wsh_util_core.add_message(x_return_status, l_module_name);

          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO REVERT_MATCHING_GRP;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --

      --
      --
      -- Start code for Bugfix 4070732
      --
      IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
      --{
          IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                        x_return_status => l_return_status);


              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
              END IF;

              IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
              END IF;
          --}
          END IF;
      --}
      END IF;
      --
      -- End of Code Bugfix 4070732
      FND_MSG_PUB.Count_And_Get
        (
         p_count  => x_msg_count,
         p_data  =>  x_msg_data,
         p_encoded => FND_API.G_FALSE
        );
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          fnd_profile.get('WSH_DEBUG_LOG_DIRECTORY',l_debugfile);
          l_debugfile := l_debugfile||'/'||WSH_DEBUG_SV.g_file;

          FND_MESSAGE.SET_NAME('WSH','WSH_DEBUG_FILE_NAME');
          FND_MESSAGE.SET_TOKEN('DEBUG_FILE_NAME',l_debugfile);
          wsh_util_core.add_message(x_return_status, l_module_name);

          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      --
      --
      -- Start code for Bugfix 4070732
      --
      IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
      --{
          IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Process_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_UTIL_CORE.Process_stops_for_load_tender(p_reset_flags   => TRUE,
                                                          x_return_status => l_return_status);


              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
              END IF;

              IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                     WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR,
                                     WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
                x_return_status := l_return_status;
              END IF;
              IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR,
                                     WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
                ROLLBACK TO REVERT_MATCHING_GRP;
              END IF;

          --}
          END IF;
      --}
      END IF;
      --
      -- End of Code Bugfix 4070732
      FND_MSG_PUB.Count_And_Get
        (
         p_count  => x_msg_count,
         p_data  =>  x_msg_data,
         p_encoded => FND_API.G_FALSE
        );
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --
    WHEN OTHERS THEN
      ROLLBACK TO REVERT_MATCHING_GRP;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_IB_UI_RECON_GRP.REVERT_MATCHING', l_module_name);
      --
      --
      --
      --
      -- Start code for Bugfix 4070732
      --
      IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
      --{
          IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                        x_return_status => l_return_status);


              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
              END IF;

              IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
              END IF;
          --}
          END IF;
      --}
      END IF;
      --
      -- End of Code Bugfix 4070732
      --
  --}
      FND_MSG_PUB.Count_And_Get
        (
         p_count  => x_msg_count,
         p_data  =>  x_msg_data,
         p_encoded => FND_API.G_FALSE
        );
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);

      fnd_profile.get('WSH_DEBUG_LOG_DIRECTORY',l_debugfile);
      l_debugfile := l_debugfile||'/'||WSH_DEBUG_SV.g_file;

      FND_MESSAGE.SET_NAME('WSH','WSH_DEBUG_FILE_NAME');
      FND_MESSAGE.SET_TOKEN('DEBUG_FILE_NAME',l_debugfile);
      wsh_util_core.add_message(x_return_status, l_module_name);

      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
  END IF;
  --
  END revert_matching;



--========================================================================
-- PROCEDURE : Match_Shipments         This procedure is called only from
--                                     the Inbound Reconciliation UI to
--                                     match a pending ASN or a pending
--                                     Receipt or partially matched Receipt.
--
-- PARAMETERS: p_api_version           known api version error number
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             p_shipment_header_id    Shipment Header Id of the transaction
--             p_transaction_type      transaction type (ASN or RECEIPT)
--             p_max_rcv_txn_id        Not used any more.
--             p_process_asn_rcv_flag  Flag to decide whether to call
--                                     WSH_ASN_RECEIPT_PVT.Process_Matched_Txns
--                                     or not to match the ASN or Receipt.
--             p_process_corr_rtv_flag Flag to decide whether to call
--                                     WSH_RCV_CORR_RTV_TXN_PKG.
--                                     process_corrections_and_rtv or not
--                                     match the corrections, rtv transactions.
--             p_object_version_number current object version of the
--                                     transaction record in
--                                     wsh_inbound_txn_history
--             p_shipment_line_id_tab  table of shipment line ids.  If
--                                     this table contains any ids, we need
--                                     to delete all those records from
--                                     wsh_inbound_txn_history.
--             p_max_txn_id_tab        table of max transaction ids for
--                                     each shipment line id in
--                                     wsh_inbound_txn_history.
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             x_return_status         return status of the API

-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This procedure is used to match pending transaction (ASN or
--             RECEIPT)
--             The following is flow of the procedure -
--             1. We check for the flags p_process_asn_rcv_flag and
--                p_process_corr_rtv_flag.  If the p_process_asn_rcv_flag
--                is set to 'Y', then we call
--                WSH_ASN_RECEIPT_PVT.Process_Matched_Txns to match the
--                receipt or ASN.  If the p_process_corr_rtv_flag is set to 'Y',
--                then we call WSH_RCV_CORR_RTV_TXN_PKG.process_corrections_and_rtv
--                to match the child transactions for the receipt.
--             2. Then we call WSH_INBOUND_TXN_HISTORY_PKG.post_process API
--                to set the status of the transaction history record.
--                appropriately
--             3. The APIs Process_Matched_Txns and process_corrections_and_rtv
--                return the output parameter records that tell us whether
--                the corresponding po shipment lines have been cancelled or closed.
--                If the record count is greater than zero, then we call
--                WSH_ASN_RECEIPT_PVT.cancel_close_pending_txns to cancel or
--                close those respective lines.
--========================================================================
  PROCEDURE match_shipments(
              p_api_version_number     IN   NUMBER,
              p_init_msg_list          IN   VARCHAR2,
              p_commit                 IN   VARCHAR2,
              p_shipment_header_id     IN   NUMBER,
              p_max_rcv_txn_id         IN   NUMBER,
              p_transaction_type       IN   VARCHAR2,
              p_process_asn_rcv_flag   IN   VARCHAR2,
              p_process_corr_rtv_flag  IN   VARCHAR2,
              p_object_version_number  IN   NUMBER,
              p_shipment_line_id_tab   IN   WSH_NUM_TBL_TYPE,
              p_max_txn_id_tab         IN   WSH_NUM_TBL_TYPE,
              x_msg_count              OUT NOCOPY NUMBER,
              x_msg_data               OUT NOCOPY VARCHAR2,
              x_return_status          OUT NOCOPY VARCHAR2)
  IS
  --{
    l_api_version_number      CONSTANT NUMBER := 1.0;
    l_api_name                CONSTANT VARCHAR2(30):= 'match_shipments';
    l_asn_rcv_action_prms WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type;
    l_corr_rtv_action_prms WSH_BULK_TYPES_GRP.action_parameters_rectype;
    l_line_rec OE_WSH_BULK_GRP.Line_rec_type;
    l_out_rec WSH_BULK_TYPES_GRP.Bulk_process_out_rec_type;
    l_return_status VARCHAR2(1);
    l_num_errors      NUMBER := 0;
    l_num_warnings    NUMBER := 0;
    i NUMBER;
    l_pkg_name VARCHAR2(32767);
    l_msg_count NUMBER;
    l_msg_data  VARCHAR2(32767);
    l_process_asn_rcv_count NUMBER := 0;
    l_pr_corr_rtv_count NUMBER := 0;
    l_corr_rtv_out_rec WSH_RCV_CORR_RTV_TXN_PKG.corr_rtv_out_rec_type;

    -- This cursor is used to obtain the matched delivery details from
    -- the global temporary table wsh_inbound_del_lines_temp.
    -- Please refer to the file WSHILTMP.sql for details about this table
    -- definition.
    cursor l_inbound_del_det_temp_csr is
    select delivery_detail_id,
           delivery_id,
           shipment_line_id,
           child_index,
           requested_quantity,
           shipped_quantity,
           received_quantity,
           returned_quantity,
           requested_quantity_db,
           shipped_quantity_db,
           received_quantity_db,
           returned_quantity_db,
           requested_quantity2,
           shipped_quantity2,
           received_quantity2,
           returned_quantity2,
           requested_quantity2_db,
           shipped_quantity2_db,
           received_quantity2_db,
           returned_quantity2_db,
           shipment_line_id_db,
           ship_from_location_id,
           po_shipment_line_id,
           source_line_id,
           process_corr_rtv_flag,
           process_asn_rcv_flag,
           requested_quantity_uom,
           requested_quantity_uom2,
           source_header_id,
           released_status,
           parent_delivery_detail_id,
           picked_quantity,
           picked_quantity2,
           picked_quantity picked_quantity_db,
           picked_quantity2 picked_quantity2_db,
           dd_last_update_date
    from   wsh_inbound_del_lines_temp;

    -- { IB-Phase-2
    cursor l_get_ship_from_of_header_csr is
    select ship_from_location_id
    from wsh_inbound_txn_history
    where shipment_header_id = p_shipment_header_id
    AND   transaction_type IN ('ASN','RECEIPT');
    -- } IB-Phase-2

    l_header_ship_from_loc_id NUMBER; --  IB-Phase-2
    l_ib_del_det_rec asn_rcv_del_det_rec_type;
    l_ib_det_count   NUMBER := 0;

    l_asn_rcv_po_cancel_rec OE_WSH_BULK_GRP.line_rec_type;
    l_asn_rcv_po_close_rec OE_WSH_BULK_GRP.line_rec_type;
    l_rtv_corr_po_cancel_rec OE_WSH_BULK_GRP.line_rec_type;
    l_rtv_corr_po_close_rec OE_WSH_BULK_GRP.line_rec_type;

    l_max_rcv_txn_id NUMBER;
  --
    l_debugfile varchar2(2000);
  --
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'MATCH_SHIPMENTS';
  --Bugfix 4070732
  l_api_session_name CONSTANT VARCHAR2(150) := G_PKG_NAME ||'.' || l_module_name;
  l_reset_flags BOOLEAN;

  --
  --}
  BEGIN
   IF WSH_UTIL_CORE.G_START_OF_SESSION_API is null THEN  --Bugfix 4070732
     WSH_UTIL_CORE.G_START_OF_SESSION_API     := l_api_session_name;
     WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API := FALSE;
   END IF;

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
        WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION_NUMBER',P_API_VERSION_NUMBER);
        WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
        WSH_DEBUG_SV.log(l_module_name,'P_COMMIT',P_COMMIT);
        WSH_DEBUG_SV.log(l_module_name,'P_SHIPMENT_HEADER_ID',P_SHIPMENT_HEADER_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_MAX_RCV_TXN_ID',P_MAX_RCV_TXN_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_TRANSACTION_TYPE',P_TRANSACTION_TYPE);
        WSH_DEBUG_SV.log(l_module_name,'P_PROCESS_ASN_RCV_FLAG',P_PROCESS_ASN_RCV_FLAG);
        WSH_DEBUG_SV.log(l_module_name,'P_PROCESS_CORR_RTV_FLAG',P_PROCESS_CORR_RTV_FLAG);
        WSH_DEBUG_SV.log(l_module_name,'p_shipment_line_id_tab.count',p_shipment_line_id_tab.count);
        WSH_DEBUG_SV.log(l_module_name,'p_max_txn_id_tab.count',p_max_txn_id_tab.count);
        WSH_DEBUG_SV.log(l_module_name,'p_shipment_line_id_tab.count',p_shipment_line_id_tab.count);
    END IF;
    --
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --
    SAVEPOINT MATCH_SHIPMENTS_GRP;
    --
    IF NOT FND_API.Compatible_API_Call
      ( l_api_version_number,
        p_api_version_number,
        l_api_name,
        l_pkg_name
       )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --
    -- { IB-Phase-2
    -- For manual matching of Receipts, rating of Trips has to be done asynchronously.
    WSH_INBOUND_UTIL_PKG.G_ASN_RECEIPT_MATCH_TYPE := 'MANUAL';
    -- } IB-Phase-2

    -- If the Header has ShipFromLocation, then all the lines under the header should have
    -- the same ShipFromLocation. The update which is done in the following lines can be
    -- avoided under the following scenario
    --  1. Debug is on
    --  2. by using the while loop which is now being used to print the values of l_ib_del_det_rec
    --     after being populated by the cursor l_inbound_del_det_temp_csr.
    --  In such a scenario, instead of the update, the value of l_header_ship_from_loc_id can
    --  be copied to l_ib_del_det_rec.ship_from_location_id_tab, for performance improvements.
    -- { IB-Phase-2
    open  l_get_ship_from_of_header_csr;
    fetch l_get_ship_from_of_header_csr into l_header_ship_from_loc_id;
    close l_get_ship_from_of_header_csr;
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_header_ship_from_loc_id',l_header_ship_from_loc_id);
    END IF;


    IF l_header_ship_from_loc_id IS NOT NULL
    THEN
      update wsh_inbound_del_lines_temp
      set    ship_from_location_id = l_header_ship_from_loc_id
      where  ship_from_location_id is null
          or ship_from_location_id = WSH_UTIL_CORE.C_NULL_SF_LOCN_ID;
    END IF;
    -- } IB-Phase-2

    open l_inbound_del_det_temp_csr;
    fetch l_inbound_del_det_temp_csr bulk collect into
                       l_ib_del_det_rec.del_detail_id_tab,
                       l_ib_del_det_rec.delivery_id_tab,
                       l_ib_del_det_rec.shipment_line_id_tab,
                       l_ib_del_det_rec.child_index_tab,
                       l_ib_del_det_rec.requested_qty_tab,
                       l_ib_del_det_rec.shipped_qty_tab,
                       l_ib_del_det_rec.received_qty_tab,
                       l_ib_del_det_rec.returned_qty_tab,
                       l_ib_del_det_rec.requested_qty_db_tab,
                       l_ib_del_det_rec.shipped_qty_db_tab,
                       l_ib_del_det_rec.received_qty_db_tab,
                       l_ib_del_det_rec.returned_qty_db_tab,
                       l_ib_del_det_rec.requested_qty2_tab,
                       l_ib_del_det_rec.shipped_qty2_tab,
                       l_ib_del_det_rec.received_qty2_tab,
                       l_ib_del_det_rec.returned_qty2_tab,
                       l_ib_del_det_rec.requested_qty2_db_tab,
                       l_ib_del_det_rec.shipped_qty2_db_tab,
                       l_ib_del_det_rec.received_qty2_db_tab,
                       l_ib_del_det_rec.returned_qty2_db_tab,
                       l_ib_del_det_rec.shipment_line_id_db_tab,
                       l_ib_del_det_rec.ship_from_location_id_tab,
                       l_ib_del_det_rec.po_line_location_id_tab,
                       l_ib_del_det_rec.po_line_id_tab,
                       l_ib_del_det_rec.process_corr_rtv_flag_tab,
                       l_ib_del_det_rec.process_asn_rcv_flag_tab,
                       l_ib_del_det_rec.requested_qty_uom_tab,
                       l_ib_del_det_rec.requested_qty_uom2_tab,
                       l_ib_del_det_rec.po_header_id_tab,
                       l_ib_del_det_rec.released_status_tab,
                       l_ib_del_det_rec.parent_delivery_detail_id_tab,
                       l_ib_del_det_rec.picked_qty_tab,
                       l_ib_del_det_rec.picked_qty2_tab,
                       l_ib_del_det_rec.picked_qty_db_tab,
                       l_ib_del_det_rec.picked_qty2_db_tab,
                       l_ib_del_det_rec.last_update_date_tab;
    close l_inbound_del_det_temp_csr;

    l_ib_det_count := l_ib_del_det_rec.del_detail_id_tab.count;

    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_ib_det_count',l_ib_det_count);
        i := l_ib_del_det_rec.del_detail_id_tab.first;
        WHILE i is not null LOOP
        --{
          WSH_DEBUG_SV.log(l_module_name,'process_asn_rcv_flag_tab(' || i || ')',l_ib_del_det_rec.process_asn_rcv_flag_tab(i));
          WSH_DEBUG_SV.log(l_module_name,'process_corr_rtv_flag(' || i || ')',l_ib_del_det_rec.process_corr_rtv_flag_tab(i));
          WSH_DEBUG_SV.log(l_module_name,'shipment_line_id(' || i || ')',l_ib_del_det_rec.shipment_line_id_tab(i));
          WSH_DEBUG_SV.log(l_module_name,'po_line_location_id(' || i || ')',l_ib_del_det_rec.po_line_location_id_tab(i));
          WSH_DEBUG_SV.log(l_module_name,'delivery_detail_id(' || i || ')',l_ib_del_det_rec.del_detail_id_tab(i));
          WSH_DEBUG_SV.log(l_module_name,'parent_delivery_detail_id(' || i || ')',l_ib_del_det_rec.parent_delivery_detail_id_tab(i));
          WSH_DEBUG_SV.log(l_module_name,'requested_qty_db_tab(' || i || ')',l_ib_del_det_rec.requested_qty_db_tab(i));
          WSH_DEBUG_SV.log(l_module_name,'requested_qty_tab(' || i || ')',l_ib_del_det_rec.requested_qty_tab(i));
          WSH_DEBUG_SV.log(l_module_name,'shipped_qty_tab(' || i || ')',l_ib_del_det_rec.shipped_qty_tab(i));
          WSH_DEBUG_SV.log(l_module_name,'received_qty_tab(' || i || ')',l_ib_del_det_rec.received_qty_tab(i));
          WSH_DEBUG_SV.log(l_module_name,'returned_qty_tab(' || i || ')',l_ib_del_det_rec.returned_qty_tab(i));
          WSH_DEBUG_SV.log(l_module_name,'child_index_tab(' || i || ')',l_ib_del_det_rec.child_index_tab(i));
          WSH_DEBUG_SV.log(l_module_name,'requested_qty_uom_tab(' || i || ')',l_ib_del_det_rec.requested_qty_uom_tab(i));
          WSH_DEBUG_SV.log(l_module_name,'ship_from_location_id_tab(' || i || ')',l_ib_del_det_rec.ship_from_location_id_tab(i));
          WSH_DEBUG_SV.log(l_module_name,'released_status_tab(' || i || ')',l_ib_del_det_rec.released_status_tab(i));
          WSH_DEBUG_SV.log(l_module_name,'delivery_id_tab(' || i || ')',l_ib_del_det_rec.delivery_id_tab(i));
          WSH_DEBUG_SV.log(l_module_name,'requested_qty2_db_tab(' || i || ')',l_ib_del_det_rec.requested_qty2_db_tab(i));
          WSH_DEBUG_SV.log(l_module_name,'requested_qty2_tab(' || i || ')',l_ib_del_det_rec.requested_qty2_tab(i));
          WSH_DEBUG_SV.log(l_module_name,'shipped_qty2_tab(' || i || ')',l_ib_del_det_rec.shipped_qty2_tab(i));
          WSH_DEBUG_SV.log(l_module_name,'received_qty2_tab(' || i || ')',l_ib_del_det_rec.received_qty2_tab(i));
          WSH_DEBUG_SV.log(l_module_name,'returned_qty2_tab(' || i || ')',l_ib_del_det_rec.returned_qty2_tab(i));
          WSH_DEBUG_SV.log(l_module_name,'picked_qty_tab(' || i || ')',l_ib_del_det_rec.picked_qty_tab(i));
          WSH_DEBUG_SV.log(l_module_name,'picked_qty2_tab(' || i || ')',l_ib_del_det_rec.picked_qty2_tab(i));
          WSH_DEBUG_SV.log(l_module_name,'last_update_date_tab(' || i || ')',l_ib_del_det_rec.last_update_date_tab(i));
          i := l_ib_del_det_rec.del_detail_id_tab.NEXT(i);
        --}
        END LOOP;
    END IF;
    --need to extend these columns as these are not fetched from the db
    IF l_ib_det_count > 0 THEN
      l_ib_del_det_rec.shpmt_line_id_idx_tab.extend(l_ib_det_count);
      l_ib_del_det_rec.trip_id_tab.extend(l_ib_det_count);
    END IF;
    l_ib_del_det_rec.shipment_header_id := p_shipment_header_id;
    l_ib_del_det_rec.max_transaction_id := p_max_rcv_txn_id;
    l_ib_del_det_rec.transaction_type := p_transaction_type;
    l_ib_del_det_rec.object_version_number := p_object_version_number;
    IF nvl(p_process_asn_rcv_flag, 'N') = 'Y' THEN
    --{
      --l_action_prms.shipment_header_id := l_ib_del_det_rec.shipment_header_id;
      l_asn_rcv_action_prms.action_code := p_transaction_type;
      l_asn_rcv_action_prms.caller := 'WSH_IB_UI_MATCH';
      WSH_ASN_RECEIPT_PVT.Process_Matched_Txns(
        p_dd_rec                   => l_ib_del_det_rec,
        p_line_rec                 => l_line_rec,
        p_action_prms              => l_asn_rcv_action_prms,
        p_shipment_header_id       => l_ib_del_det_rec.shipment_header_id,
        p_max_txn_id               => l_ib_del_det_rec.max_transaction_id,
        x_po_cancel_rec            => l_asn_rcv_po_cancel_rec,
        x_po_close_rec             => l_asn_rcv_po_close_rec,
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
    IF nvl(p_process_corr_rtv_flag, 'N') = 'Y' THEN
    --{
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_RCV_CORR_RTV_TXN_PKG.PROCESS_CORRECTIONS_AND_RTV',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      l_corr_rtv_action_prms.action_code := p_transaction_type;
      WSH_RCV_CORR_RTV_TXN_PKG.process_corrections_and_rtv (
        p_rtv_corr_in_rec    => l_line_rec,
        p_matched_detail_rec => l_ib_del_det_rec,
        p_action_prms        => l_corr_rtv_action_prms,
        p_rtv_corr_out_rec   => l_corr_rtv_out_rec,
        x_po_cancel_rec      => l_rtv_corr_po_cancel_rec,
        x_po_close_rec       => l_rtv_corr_po_close_rec,
        x_msg_data           => l_msg_data,
        x_msg_count          => l_msg_count,
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
        x_num_errors       => l_num_errors,
        p_msg_data         => l_msg_data);
    --}
    END IF;
    --
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_TXN_HISTORY_PKG.POST_PROCESS',WSH_DEBUG_SV.C_PROC_LEVEL);
        WSH_DEBUG_SV.log(l_module_name,'p_shipment_line_id_tab.count', p_shipment_line_id_tab.count);
    END IF;
    --
    -- This was added as a part of the changes to support matching of
    -- partially matched transactions.
    -- The information stored in p_max_txn_id_tab is passed from the get_shipment_lines
    -- to the UI and then from UI to the match_shipments so that we know exactly
    -- what records need to be deleted from wsh_inbound_txn_history
    -- when matching a partially matched transaction.
    IF (p_shipment_line_id_tab.count > 0) THEN
    --{
      l_max_rcv_txn_id := -1;
      --  can use bulk delete
      FOR i in p_shipment_line_id_tab.FIRST..p_shipment_line_id_tab.LAST LOOP
      --{
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'p_shipment_line_id_tab(i)', p_shipment_line_id_tab(i));
          WSH_DEBUG_SV.log(l_module_name,'p_max_txn_id_tab(i)', p_max_txn_id_tab(i));
        END IF;
        delete from wsh_inbound_txn_history
        where shipment_line_id = p_shipment_line_id_tab(i)
        and   transaction_type NOT IN ('ASN','RECEIPT')
        and   transaction_id <= p_max_txn_id_tab(i);
      --}
      END LOOP;
    --}
    ELSE
    --{
      l_max_rcv_txn_id := p_max_rcv_txn_id;
    --}
    END IF;
    --
    WSH_INBOUND_TXN_HISTORY_PKG.post_process(
      p_shipment_header_id     => p_shipment_header_id,
      p_max_rcv_txn_id         => l_max_rcv_txn_id,
      p_action_code            => 'MATCHED',
      p_txn_type               => p_transaction_type,
      p_object_version_number  => p_object_version_number,
      x_return_status          => l_return_status);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Return Status after calling WSH_INBOUND_TXN_HISTORY_PKG.post_process is ', l_return_status);
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors);

    --x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    IF (l_asn_rcv_po_cancel_rec.line_id.COUNT > 0  OR l_asn_rcv_po_close_rec.line_id.COUNT > 0 ) THEN
    --{
      WSH_ASN_RECEIPT_PVT.cancel_close_pending_txns(
        p_po_cancel_rec => l_asn_rcv_po_cancel_rec,
        p_po_close_rec  => l_asn_rcv_po_close_rec,
        x_return_status => l_return_status);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Return Status after calling cancel_close_pending_txns 1 is ', l_return_status);
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors);
    --}
    END IF;
    --
    IF (l_rtv_corr_po_cancel_rec.line_id.COUNT > 0  OR l_rtv_corr_po_close_rec.line_id.COUNT > 0 ) THEN
    --{
      WSH_ASN_RECEIPT_PVT.cancel_close_pending_txns(
        p_po_cancel_rec => l_rtv_corr_po_cancel_rec,
        p_po_close_rec  => l_rtv_corr_po_close_rec,
        x_return_status => l_return_status);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Return Status after calling cancel_close_pending_txns 2 is ', l_return_status);
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
    --{
      fnd_profile.get('WSH_DEBUG_LOG_DIRECTORY',l_debugfile);
      l_debugfile := l_debugfile||'/'||WSH_DEBUG_SV.g_file;

      FND_MESSAGE.SET_NAME('WSH','WSH_DEBUG_FILE_NAME');
      FND_MESSAGE.SET_TOKEN('DEBUG_FILE_NAME',l_debugfile);
      x_return_status := wsh_util_core.g_ret_sts_success;
      wsh_util_core.add_message(x_return_status, l_module_name);

    --}
    END IF;
    --

    IF l_num_warnings > 0 THEN
        RAISE WSH_UTIL_CORE.G_EXC_WARNING;
    ELSE
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    END IF;
    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN

      --bug 4070732
      IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
      --{

          l_reset_flags := FALSE;

          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Process_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          WSH_UTIL_CORE.Process_stops_for_load_tender(p_reset_flags   => l_reset_flags,
                                                      x_return_status => l_return_status);

          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
          END IF;

          IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            RAISE WSH_UTIL_CORE.G_EXC_WARNING;
          END IF;

      --}
      END IF;
      --bug 4070732

      COMMIT WORK;
    END IF;
    --
    --bug 4070732
    IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
    --{
        IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
        --{

           IF FND_API.To_Boolean( p_commit ) THEN

            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

            WSH_UTIL_CORE.reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                        x_return_status => l_return_status);


	   ELSE


            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Process_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

            WSH_UTIL_CORE.Process_stops_for_load_tender(p_reset_flags   => TRUE,
                                                        x_return_status => l_return_status);

	   END IF;

            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
            END IF;

            IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                   WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR,
                                   WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
              x_return_status := l_return_status;
            END IF;

            IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                   WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
              IF NOT FND_API.To_Boolean( p_commit ) THEN
                ROLLBACK TO MATCH_SHIPMENTS_GRP;
              END IF;
            END IF;

        --}
        END IF;
    --}
    END IF;

    --bug 4070732
    --
    FND_MSG_PUB.Count_And_Get
      (
       p_count  => x_msg_count,
       p_data  =>  x_msg_data,
       p_encoded => FND_API.G_FALSE
      );
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
      ROLLBACK TO MATCH_SHIPMENTS_GRP;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      --
      -- Start code for Bugfix 4070732
      --
      IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
      --{
          IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                        x_return_status => l_return_status);


              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
              END IF;

              IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
              END IF;
          --}
          END IF;
      --}
      END IF;
      --
      -- End of Code Bugfix 4070732
      --
      FND_MSG_PUB.Count_And_Get
        (
         p_count  => x_msg_count,
         p_data  =>  x_msg_data,
         p_encoded => FND_API.G_FALSE
        );
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO MATCH_SHIPMENTS_GRP;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      --
      -- Start code for Bugfix 4070732
      --
      IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
      --{
          IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                        x_return_status => l_return_status);


              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
              END IF;

              IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
              END IF;
          --}
          END IF;
      --}
      END IF;
      --
      -- End of Code Bugfix 4070732
      --
      FND_MSG_PUB.Count_And_Get
        (
         p_count  => x_msg_count,
         p_data  =>  x_msg_data,
         p_encoded => FND_API.G_FALSE
        );
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);

          fnd_profile.get('WSH_DEBUG_LOG_DIRECTORY',l_debugfile);
          l_debugfile := l_debugfile||'/'||WSH_DEBUG_SV.g_file;

          FND_MESSAGE.SET_NAME('WSH','WSH_DEBUG_FILE_NAME');
          FND_MESSAGE.SET_TOKEN('DEBUG_FILE_NAME',l_debugfile);
          wsh_util_core.add_message(x_return_status, l_module_name);

          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      --
      --
      -- Start code for Bugfix 4070732
      --
      IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
      --{
          IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Process_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_UTIL_CORE.Process_stops_for_load_tender(p_reset_flags   => TRUE,
                                                          x_return_status => l_return_status);


              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
              END IF;

              IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                     WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR,
                                     WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
                x_return_status := l_return_status;
              END IF;
              IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                     WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                ROLLBACK TO MATCH_SHIPMENTS_GRP;
              END IF;


          --}
          END IF;
      --}
      END IF;
      --
      -- End of Code Bugfix 4070732
      --
      FND_MSG_PUB.Count_And_Get
        (
         p_count  => x_msg_count,
         p_data  =>  x_msg_data,
         p_encoded => FND_API.G_FALSE
        );
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --
    WHEN OTHERS THEN
      ROLLBACK TO MATCH_SHIPMENTS_GRP;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_IB_UI_RECON_GRP.MATCH_SHIPMENTS', l_module_name);
      --
      --
      -- Start code for Bugfix 4070732
      --
      IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
      --{
          IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                        x_return_status => l_return_status);


              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
              END IF;

              IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
              END IF;
          --}
          END IF;
      --}
      END IF;
      --
      -- End of Code Bugfix 4070732
      --
  --}
      FND_MSG_PUB.Count_And_Get
        (
         p_count  => x_msg_count,
         p_data  =>  x_msg_data,
         p_encoded => FND_API.G_FALSE
        );
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      fnd_profile.get('WSH_DEBUG_LOG_DIRECTORY',l_debugfile);
      l_debugfile := l_debugfile||'/'||WSH_DEBUG_SV.g_file;

      FND_MESSAGE.SET_NAME('WSH','WSH_DEBUG_FILE_NAME');
      FND_MESSAGE.SET_TOKEN('DEBUG_FILE_NAME',l_debugfile);
      wsh_util_core.add_message(x_return_status, l_module_name);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
  END IF;
  --
  END match_shipments;

END WSH_IB_UI_RECON_GRP;

/
