--------------------------------------------------------
--  DDL for Package Body WSH_DELIVERIES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_DELIVERIES_GRP" as
/* $Header: WSHDEGPB.pls 120.23.12010000.8 2010/02/26 06:28:44 sankarun ship $ */

--===================
-- CONSTANTS
--===================
G_PKG_NAME CONSTANT VARCHAR2(30) := 'WSH_DELIVERIES_GRP';
-- add your constants here if any

-- Forward declaration
PROCEDURE Lock_Related_Entities(
         p_rec_attr_tab     IN  WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type,
         p_action_prms      IN  action_parameters_rectype,
         x_valid_ids_tab    OUT NOCOPY WSH_UTIL_CORE.ID_TAB_TYPE,
         x_return_status    OUT NOCOPY VARCHAR2
          );

--===================
-- PROCEDURES
--===================
-- I Harmonization: rvishnuv ******* Actions ******
--========================================================================
-- PROCEDURE : Delivery_Action         Must be called only by the Form
--                                     and the Wrapper Group API.
--
-- PARAMETERS: p_api_version_number    known api version error number
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_action_prms           Record of caller, phase, action_code and other
--                                     parameters specific to the actions.
--         p_rec_attr_tab          Table of attributes for the delivery entity
--             x_result_id_tab         Table of result ids for the actions 'AUTO-PACK',
--                                     'AUTO-PACK-MASTER' and 'PICK-RELEASE'
--             x_valid_ids_tab         Table of valid indexes or ids.  If the caller is STF,
--                                     it contains table of valid indexes, else it contains
--                                     table of valid ids.
--             x_selection_issue_flag  It is a form specific out parameter. It set to 'Y', if
--                                     the Validations in phase 1 return a 'warning'.
--             x_defaults_rec          Record of Default Parameters that passed for the actions
--                                     'CONFIRM', 'UNASSIGN-TRIP'.
--             x_delivery_out_rec      Record of output parameters based on the actions.
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This procedure is used to perform an action specified
--             in p_action_prms.action_code on an existing delivery identified
--             by p_rec_attr.delivery_id.
--========================================================================

  PROCEDURE Delivery_Action
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    p_commit         IN   VARCHAR2,
    p_action_prms      IN   action_parameters_rectype,
    p_rec_attr_tab       IN   WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type ,
    x_delivery_out_rec       OUT  NOCOPY Delivery_Action_Out_Rec_Type,
    x_defaults_rec       OUT  NOCOPY default_parameters_rectype,
    x_return_status          OUT  NOCOPY VARCHAR2,
    x_msg_count              OUT  NOCOPY NUMBER,
    x_msg_data               OUT  NOCOPY VARCHAR2
  )
  IS

  CURSOR trip_cur(p_trip_id NUMBER) IS
    SELECT SHIP_METHOD_CODE
    FROM wsh_trips
    WHERE trip_id = p_trip_id;


  -- Bug 3346237 : Defer interface and enforce ship method to be taken from global parameters

  cursor get_defer_interface is
    select defer_interface,
           enforce_ship_method
    from wsh_global_parameters;


  CURSOR c_dlvy_pack_slip_cur(p_delivery_id NUMBER) IS
     SELECT sequence_number
     FROM wsh_document_instances
     WHERE entity_name = 'WSH_NEW_DELIVERIES'
     AND entity_id = p_delivery_id
     AND document_type = 'PACK_TYPE';

  -- Cursors c_pack_slip_doc_set and c_delv_trip_id_cursor added for bug 4493263
  CURSOR c_pack_slip_doc_set IS
    SELECT WRS.Report_Set_Id
    FROM   Wsh_Report_Sets Wrs,
           Wsh_Report_Set_Lines Wrsl
    WHERE  Wrsl.Report_Set_Id = Wrs.Report_Set_Id
    AND    Wrs.Name = 'Packing Slip Report';

  CURSOR c_delv_trip_id_cursor( t_delivery_id NUMBER ) IS
    select distinct trip_id from wsh_trip_stops
    where stop_id in
      ( select distinct pick_up_stop_id
        from   wsh_delivery_legs
        where  delivery_id = t_delivery_id );


  CURSOR c_dlvy_leg_cur(p_delivery_id NUMBER) IS
    SELECT b.delivery_leg_id,
    b.pick_up_location_id,
    b.drop_off_location_id,
    b.ship_method,
    b.carrier_id,
    b.trip_id,
    b.trip_name,
    l.parent_delivery_leg_id
    FROM wsh_bols_db_v b, wsh_delivery_legs l
    WHERE b.delivery_id = p_delivery_id
    AND l.delivery_leg_id = b.delivery_leg_id;

  CURSOR c_child_deliveries(p_delivery_id IN NUMBER) IS
    select child.delivery_id
    from wsh_delivery_legs parent,
         wsh_delivery_legs child
    where parent.delivery_id = p_delivery_id
    and   parent.delivery_leg_id = child.parent_delivery_leg_id;


  Cursor c_get_delivery_org(c_delivery_id number) is
      SELECT initial_pickup_location_id
      FROM wsh_new_deliveries
      WHERE delivery_id = c_delivery_id;

  Cursor c_del_assign_to_trip(c_delivery_id number) is
	SELECT distinct t.trip_id, t.ship_method_code, t.lane_id
	FROM   wsh_new_deliveries dl,
	       wsh_delivery_legs dg,
	       wsh_trip_stops st,
	       wsh_trips t
	WHERE  dl.delivery_id = c_delivery_id AND
	       dl.delivery_id = dg.delivery_id AND
	       (dg.pick_up_stop_id = st.stop_id
		OR
		dg.DROP_OFF_STOP_ID = st.stop_id) AND
	       st.trip_id = t.trip_id;

  --Bug 7418439 : The cursor selects the trip_id if the delivery is not the last unconfirmed delivery in the trip.
  Cursor c_unconfirmed_del_exist(c_delivery_id number) is
         SELECT s1.trip_id
         FROM wsh_trip_stops s1,
              wsh_delivery_legs dl1,
              wsh_new_deliveries d1,
              wsh_trip_stops s2,
              wsh_delivery_legs dl2
          WHERE d1.delivery_id <> c_delivery_id
          AND s1.stop_id = dl1.pick_up_stop_id
          AND d1.delivery_id = dl1.delivery_id
          AND d1.status_code = 'OP'
          AND d1.delivery_type = 'STANDARD'
          AND s2.trip_id = s1.trip_id
          AND s2.stop_id = dl2.pick_up_stop_id
          AND dl2.delivery_id = c_delivery_id
          AND rownum = 1;

     l_unconfirmed_del_exist NUMBER;

  --OTM R12
  --selecting deliveries that has 'AR' status on a trip
  CURSOR c_get_delivery_id(p_trip_id IN NUMBER) IS
    SELECT wdl.delivery_id,
           WSH_NEW_DELIVERIES_PVT.C_TMS_AWAITING_ANSWER interface_flag
    FROM   wsh_delivery_legs wdl,
           wsh_trip_stops wts,
           wsh_new_deliveries wnd,
           wsh_trips wt
    WHERE  wt.trip_id = p_trip_id
    AND    wts.trip_id = wt.trip_id
    AND    wt.status_code = 'OP'
    AND    wdl.pick_up_stop_id = wts.stop_id
    AND    wnd.delivery_id = wdl.delivery_id
    AND    wnd.tms_interface_flag = WSH_NEW_DELIVERIES_PVT.C_TMS_ANSWER_RECEIVED;
  --END OTM R12
  --
  -- LSP PROJECT :
  CURSOR c_get_client(p_delivery_id NUMBER) IS
    SELECT client_id
    FROM   wsh_new_deliveries
    WHERE  delivery_id = p_delivery_id;
  --
  l_client_id               NUMBER;
  l_standalone_mode         VARCHAR2(1);
  -- LSP PROJECT : end
  l_first                   NUMBER;
  l_last                    NUMBER;
  l_return_status           VARCHAR2(1);
  l_num_errors              NUMBER := 0;
  l_num_warnings            NUMBER := 0;
  l_api_version_number      CONSTANT NUMBER := 1.0;
  l_api_name                CONSTANT VARCHAR2(30):= 'Delivery_Action';
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(32767);
  l_counter                 NUMBER;
  l_index                   NUMBER;
  --
  l_report_set_id           NUMBER := p_action_prms.report_set_id;
  l_form_flag               VARCHAR2(1);
  l_trip_id                 NUMBER := p_action_prms.trip_id;
  l_pickup_loc_id           NUMBER := p_action_prms.pickup_loc_id;
  l_dropoff_loc_id          NUMBER := p_action_prms.dropoff_loc_id;
  --
  l_debug_on                BOOLEAN;
  l_module_name             CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELIVERY_ACTION';
  --
  l_delivery_id_tab         wsh_util_core.id_tab_type;
  l_valid_ids_tab           wsh_util_core.id_tab_type;
  l_valid_index_tab         wsh_util_core.id_tab_type;
  l_error_ids               wsh_util_core.id_tab_type;
  l_org_id_tab              wsh_util_core.id_tab_type;
  l_Client_id_tab		    wsh_util_core.id_tab_type;  -- Modified R12.1.1 LSP PROJECT
  l_rec_attr_tab            wsh_new_deliveries_pvt.Delivery_Attr_Tbl_Type;
  l_ship_method_code_tab    WSH_NEW_DELIVERY_ACTIONS.ship_method_type;
  l_delivery_rec_tab        wsh_delivery_validations.dlvy_rec_tab_type;
  l_dummy_id_tab            wsh_util_core.id_tab_type;
  l_dummy_doc_set_params    wsh_document_sets.document_set_tab_type;
  l_param_name              VARCHAR2(100);
  l_isWshLocation           BOOLEAN DEFAULT FALSE;
  --
  --Compatibility Changes
  l_cc_validate_result      VARCHAR2(1);
  l_caller_module           VARCHAR2(3);
  l_cc_failed_records       WSH_FTE_COMP_CONSTRAINT_PKG.failed_line_tab_type;
  l_cc_line_groups          WSH_FTE_COMP_CONSTRAINT_PKG.line_group_tab_type;
  l_cc_group_info           WSH_FTE_COMP_CONSTRAINT_PKG.cc_group_tab_type;
  b_cc_linefailed           boolean;
  b_cc_groupidexists        boolean;
  l_delivery_id_tab_temp    wsh_util_core.id_tab_type;
  l_delivery_id_tab_t       wsh_util_core.id_tab_type;
  l_rec_attr_tab_temp       WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type;
  l_cc_count_success        NUMBER;
  l_cc_count_group_ids      NUMBER;
  l_cc_count_rec            NUMBER;
  l_cc_group_ids            wsh_util_core.id_tab_type;
  l_cc_upd_dlvy_intmed_ship_to  VARCHAR2(1);
  l_cc_upd_dlvy_ship_method VARCHAR2(1);
  l_cc_dlvy_intmed_ship_to  NUMBER;
  l_cc_dlvy_ship_method     VARCHAR2(30);
  l_cc_del_rows             wsh_util_core.id_tab_type;
  l_cc_grouping_rows        wsh_util_core.id_tab_type;
  l_cc_return_status        VARCHAR2(1);
  l_cc_count_del_rows       NUMBER;
  l_cc_count_trip_rows      NUMBER;
  l_cc_count_grouping_rows  NUMBER;
  l_cc_trip_id              wsh_util_core.id_tab_type;
  l_cc_trip_id_tab          wsh_util_core.id_tab_type;
  --dummy tables for calling validate_constraint_mainper
  l_cc_del_attr_tab         WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type;
  l_cc_det_attr_tab         wsh_glbl_var_strct_grp.Delivery_Details_Attr_Tbl_Type;
  l_cc_trip_attr_tab        WSH_TRIPS_PVT.Trip_Attr_Tbl_Type;
  l_cc_stop_attr_tab        WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type;
  l_cc_in_ids               wsh_util_core.id_tab_type;
  l_cc_fail_ids             wsh_util_core.id_tab_type;
  --

  --Compatibility Changes
  --
  l_tripindex               NUMBER;
  l_trip_names              wsh_util_core.column_tab_type;

  --
  -- l_trip_name VARCHAR2(30) := NULL;
  l_action_code             VARCHAR2(32767);
  i                         NUMBER;
  j		            NUMBER;
  l_DelivGrpRec	            WSH_TRIP_CONSOLIDATION.t_DelivGrpRec;
  l_tripID		    NUMBER;
  l_defer_interface_flag    VARCHAR2(1);
  --

  -- PACK J: QS: KVENKATE
  l_dlvy_doc_seq_num        VARCHAR2(50);
  l_application_id          NUMBER;
  l_request_id              NUMBER;

  -- Added for bug 4493263
  l_doc_set_id              NUMBER;
  l_doc_delivery_id_tab     wsh_util_core.id_tab_type;
  l_doc_valid_ids_tab       wsh_util_core.id_tab_type;

  l_dleg_prms               WSH_DELIVERY_LEGS_GRP.action_parameters_rectype;
  l_dleg_action_out_rec     WSH_DELIVERY_LEGS_GRP.action_out_rec_type;
  l_dleg_tab                WSH_DELIVERY_LEGS_GRP.dlvy_leg_tab_type;

  l_action_prms             action_parameters_rectype;
  l_delivery_out_rec        Delivery_Action_Out_Rec_Type;
  l_defaults_rec            default_parameters_rectype;
  l_loop_num_warn           NUMBER := 0;
  l_loop_num_err            NUMBER := 0;
  l_submitted_docs          NUMBER :=0;
  l_req_id_str              VARCHAR2(2000);
  -- PACK J: KVENKATE
  l_routingRespIdTab	    wsh_util_core.id_tab_type;

  -- csun deliveryMerge
  l_exception_id            NUMBER;
  l_initial_pickup_location_id  NUMBER;
  l_exception_message       VARCHAR2(2000);
  l_in_param_rec            WSH_FTE_INTEGRATION.rate_del_in_param_rec;
  l_out_param_rec           WSH_FTE_INTEGRATION.rate_del_out_param_rec;

  -- J-Stop Sequence Change-CSUN
  l_stop_details_rec        WSH_TRIP_STOPS_VALIDATIONS.stop_details;

  -- Bug 3311273
  l_dleg_found              VARCHAR2(1) := 'N';
  --
  --dcp
  l_check_dcp               NUMBER;
  l_stop_id                 NUMBER;

  -- Bug 3877951
  l_intransit_flag          varchar2(1);

  l_ship_method_code        VARCHAR2(30);
  l_ship_method_name        VARCHAR2(240);  -- Bug#3880569

  -- Bug 4100661 (FP: 4103129)
  l_temp_trip_id            NUMBER;
  l_temp_lane_id            NUMBER;
  l_temp_ship_method_code   WSH_TRIPS.SHIP_METHOD_CODE%TYPE;

  l_temp                    NUMBER;
  l_is_del_assign_trip      BOOLEAN;
  --Bugfix 4070732
  l_api_session_name        CONSTANT VARCHAR2(150) := G_PKG_NAME ||'.' || l_module_name;
  l_reset_flags             BOOLEAN;


  -- K LPN CONV. rv
  l_lpn_in_sync_comm_rec    WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_in_rec_type;
  l_lpn_out_sync_comm_rec   WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_out_rec_type;
  -- K LPN CONV. rv

  l_child_deliveries_tab    wsh_util_core.id_tab_type;

  --OTM R12
  l_new_delivery_id_tab	    WSH_UTIL_CORE.ID_TAB_TYPE;
  l_new_interface_flag_tab  WSH_UTIL_CORE.COLUMN_TAB_TYPE;
  l_gc3_is_installed        VARCHAR2(1);
  --

  BEGIN
    <<api_start>>
    --
    -- Bug 4070732
    IF WSH_UTIL_CORE.G_START_OF_SESSION_API is null THEN
      WSH_UTIL_CORE.G_START_OF_SESSION_API     := l_api_session_name;
      WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API := FALSE;
    END IF;
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    SAVEPOINT DELIVERY_ACTION_GRP;
    --
    l_check_dcp := WSH_DCP_PVT.G_CHECK_DCP;

    IF l_check_dcp IS NULL THEN
       l_check_dcp := wsh_dcp_pvt.is_dcp_enabled;
    END IF;



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
    ELSE
     IF nvl(l_check_dcp, '-99') IN (1,2) THEN
      WSH_DCP_PVT.G_INIT_MSG_COUNT := fnd_msg_pub.count_msg;
     END IF;
    END IF;
    --
    IF l_debug_on THEN
      wsh_debug_sv.push (l_module_name);
      wsh_debug_sv.log (l_module_name,'action_code',p_action_prms.action_code);
      wsh_debug_sv.log (l_module_name,'caller',p_action_prms.caller);
      wsh_debug_sv.log (l_module_name,'COUNT',p_rec_attr_tab.COUNT);
    END IF;

    --Fix for bug 3636800
    --Initialize l_num_warning, l_num_error so that when dcp code re-runs this procedure,
    --these variables are reinitialized.
    l_num_warnings := 0;
    l_num_errors := 0;

    IF p_action_prms.action_code IS NULL THEN
      l_param_name := 'p_action_prms.action_code';
    ELSIF p_action_prms.caller IS NULL  THEN
      l_param_name := 'p_action_prms.caller';
    ELSIF p_action_prms.caller = 'WSH_FSTRX' THEN
      IF p_action_prms.phase IS NULL THEN
        l_param_name := 'p_action_prms.phase';
      END IF;
    ELSIF p_rec_attr_tab.COUNT = 0  THEN
      l_param_name := 'p_rec_attr_tab.COUNT';
    END IF;

    IF l_param_name is not null THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
      FND_MESSAGE.SET_TOKEN('FIELD_NAME',l_param_name);
      x_return_status := wsh_util_core.g_ret_sts_error;
      wsh_util_core.add_message(x_return_status,l_module_name);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    --OTM R12
    l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED; -- this is global variable

    IF l_gc3_is_installed IS NULL THEN
      l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED; -- this is actual function
    END IF;
    --

    IF p_action_prms.caller IN ( 'WSH_FSTRX' , 'WSH_TPW_INBOUND')
     OR p_action_prms.caller LIKE 'FTE%' THEN
       l_isWshLocation := TRUE;
    END IF;

    i := p_rec_attr_tab.FIRST;
    --l_last := p_rec_attr_tab.LAST;

    --
    WHILE i is not null LOOP
    --
      l_delivery_id_tab(i) := p_rec_attr_tab(i).delivery_id;
      IF nvl(p_action_prms.phase,1) = 1 THEN
        l_delivery_rec_tab(i).delivery_id := p_rec_attr_tab(i).delivery_id;
        l_delivery_rec_tab(i).status_code := p_rec_attr_tab(i).status_code;
        l_delivery_rec_tab(i).planned_flag := p_rec_attr_tab(i).planned_flag;
        l_delivery_rec_tab(i).organization_id := p_rec_attr_tab(i).organization_id;
        l_delivery_rec_tab(i).shipment_direction := p_rec_attr_tab(i).shipment_direction;
        --OTM R12
        l_delivery_rec_tab(i).ignore_for_planning := p_rec_attr_tab(i).ignore_for_planning;
        l_delivery_rec_tab(i).tms_interface_flag := p_rec_attr_tab(i).tms_interface_flag;
        --
        l_delivery_rec_tab(i).client_id := p_rec_attr_tab(i).client_id; -- LSP PROJECT
        --
        IF l_debug_on THEN
          wsh_debug_sv.log (l_module_name,'client_id',p_rec_attr_tab(i).client_id); -- LSP PROJECT
        END IF;
        --
        IF p_action_prms.action_code = 'CONFIRM' THEN
          --
          -- bug 6369687: Setting G_ACTION as 'CONFIRM'
          G_ACTION := 'CONFIRM';
          l_org_id_tab(i) := p_rec_attr_tab(i).organization_id;
          l_ship_method_code_tab(i) := p_rec_attr_tab(i).ship_method_code;
          l_client_id_tab(i) := p_rec_attr_tab(i).client_id; -- Modified R12.1.1 LSP PROJECT
          --
          IF l_debug_on THEN
            wsh_debug_sv.log (l_module_name,' Ship Method Code ' || p_rec_attr_tab(i).ship_method_code );
          END IF;
          --
        END IF;
        --
        IF l_debug_on THEN
          wsh_debug_sv.log (l_module_name,'delivery_id',p_rec_attr_tab(i).delivery_id);
          wsh_debug_sv.log (l_module_name,'status_code',p_rec_attr_tab(i).status_code);
          wsh_debug_sv.log (l_module_name,'planned_flag',p_rec_attr_tab(i).planned_flag);
          wsh_debug_sv.log (l_module_name,'organization_id',p_rec_attr_tab(i).organization_id);
          wsh_debug_sv.log (l_module_name,'shipment_direction',p_rec_attr_tab(i).shipment_direction);
          --OTM R12
          wsh_debug_sv.log (l_module_name,'ignore_for_planning',p_rec_attr_tab(i).ignore_for_planning);
          wsh_debug_sv.log (l_module_name,'tms_interface_flag',p_rec_attr_tab(i).tms_interface_flag);
          --
          wsh_debug_sv.log (l_module_name,'client_id',p_rec_attr_tab(i).client_id); -- Modified R12.1.1 LSP PROJECT
        END IF;
        --
      END IF;
      --
      IF l_debug_on THEN
        wsh_debug_sv.log (l_module_name,'delivery_id tab( ' || i || ')' ,l_delivery_id_tab(i));
      END IF;
    --
      i := p_rec_attr_tab.NEXT(i);
    END LOOP;
    --
    --
    i := 0;
    --
    -- bug 2789821
    -- This condition is added so that we treat these actions
    -- as equivalent to "PICK-RELEASE" ONLY during
    -- setting the levels and validating the eligibility of the action
    IF p_action_prms.action_code IN ('PICK-SHIP', 'PICK-PACK-SHIP') THEN
      l_action_code := 'PICK-RELEASE';
    ELSIF p_action_prms.action_code IN ('AUTOCREATE-TRIP', 'TRIP-CONSOLIDATION') THEN
      l_action_code := 'AUTOCREATE-TRIP';
    ELSE
      l_action_code := p_action_prms.action_code;
    END IF;
    --
    WSH_ACTIONS_LEVELS.set_validation_level (
      p_entity        => 'DLVY',
      p_caller        => p_action_prms.caller,
      p_phase         => nvl(p_action_prms.phase,1), -- phase should not be null
      p_action        => l_action_code,
      x_return_status => l_return_status);
    --
    IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name,'Return Status After Calling set_validation_level',l_return_status);
    END IF;
    --
    wsh_util_core.api_post_call(
      p_return_status    => l_return_status,
      x_num_warnings     => l_num_warnings,
      x_num_errors       => l_num_errors);
    --
    IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_ACTION_ENABLED_LVL) = 1 THEN
      IF l_debug_on THEN
        wsh_debug_sv.logmsg(l_module_name,'Calling IS_Action_Enabled');
      END IF;

      WSH_DELIVERY_VALIDATIONS.Is_Action_Enabled(
        p_dlvy_rec_tab            => l_delivery_rec_tab,
        p_action                  => l_action_code,
        p_caller                  => p_action_prms.caller,
        p_tripid                  => p_action_prms.trip_id,--J TP Release
        x_return_status           => l_return_status,
        x_valid_ids               => l_valid_ids_tab ,
        x_error_ids               => l_error_ids ,
        x_valid_index_tab         => l_valid_index_tab);

      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'Return Status After Calling IS_Action_Enabled',l_return_status);
      END IF;
      --
      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors,
        p_msg_data         => NULL,
        p_raise_error_flag => FALSE);
      --
      IF p_action_prms.caller IN ('WSH_FSTRX', 'WSH_TRCON') THEN
         x_delivery_out_rec.valid_ids_tab := l_valid_index_tab;
      ELSE
         x_delivery_out_rec.valid_ids_tab := l_valid_ids_tab;
      END IF;
      --
    END IF;
    --
    IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_LOCK_RECORDS_LVL) = 1 THEN
      --
     IF  NOT (    p_action_prms.caller = 'WSH_FSTRX'
              AND p_action_prms.action_code =  'DELETE'
             )  THEN --BUG 4354579
      WSH_NEW_DELIVERIES_PVT.Lock_Delivery(
        p_rec_attr_tab          => p_rec_attr_tab,
        p_caller                => p_action_prms.caller,
        p_valid_index_tab       => l_valid_index_tab,
        x_valid_ids_tab         => l_valid_ids_tab,
        x_return_status         => l_return_status,
        p_action                => p_action_prms.action_code);
      --
      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'Return Status After Calling Lock_Delivery',l_return_status);
      END IF;
      --
      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors,
        p_msg_data         => NULL,
        p_raise_error_flag => FALSE);
      --
      x_delivery_out_rec.valid_ids_tab := l_valid_ids_tab;
      --
     END IF;
    END IF;

    --
    IF(l_num_errors >0 ) THEN
      --{
      x_return_status := wsh_util_core.g_ret_sts_error;
      --
      IF p_action_prms.caller = 'WSH_FSTRX' THEN
        FND_MESSAGE.SET_NAME('WSH', 'WSH_DISABLE_ACTION');
        wsh_util_core.add_message(x_return_status,l_module_name);
      END IF;
      --
      IF l_debug_on THEN
        wsh_debug_sv.logmsg(l_module_name, 'WSH_DISABLE_ACTION');
      END IF;
      --
      RAISE FND_API.G_EXC_ERROR;
      --}
    END IF;
    --
    -- bug 2651859.  Refreshing the table of ids.
    -- before defaulting the parameters.
    IF l_num_warnings > 0 and l_valid_ids_tab.count > 0
    AND p_action_prms.action_code IN ('UNASSIGN-TRIP', 'CONFIRM')
    THEN
      --
      l_delivery_id_tab.delete;
      l_org_id_tab.delete;
      l_ship_method_code_tab.delete;
      FOR i in l_valid_ids_tab.first..l_valid_ids_tab.last LOOP
      --
        l_delivery_id_tab(i) := p_rec_attr_tab(i).delivery_id;
        --
        IF l_debug_on THEN
          wsh_debug_sv.log (l_module_name,'delivery_id',l_delivery_id_tab(i));
        END IF;
        --
        IF p_action_prms.action_code = 'CONFIRM' THEN
          --
          l_org_id_tab(i) := p_rec_attr_tab(i).organization_id;
          l_ship_method_code_tab(i) := p_rec_attr_tab(i).ship_method_code;
          l_client_id_tab(i) := p_rec_attr_tab(i).client_id; -- Modified R12.1.1 LSP PROJECT
          --
          IF l_debug_on THEN
            wsh_debug_sv.log (l_module_name,' Ship Method Code ' || p_rec_attr_tab(i).ship_method_code );
            wsh_debug_sv.log (l_module_name,' Organization_Id ' || p_rec_attr_tab(i).organization_id );
            wsh_debug_sv.log (l_module_name,' Client_Id ' || p_rec_attr_tab(i).client_id); -- Modified R12.1.1 LSP PROJECT

          END IF;
          --
        END IF;
        --
      --
      END LOOP;
      --
    END IF;
      --
    IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_DLVY_DEFAULTS_LVL) = 1 THEN
      --
      WSH_NEW_DELIVERY_ACTIONS.Get_Delivery_Defaults(
        p_del_rows              => l_delivery_id_tab,
        p_org_ids               => l_org_id_tab,
        p_client_ids		        => l_client_id_tab, -- Modified R12.1.1 LSP PROJECT
        p_ship_method_code_vals => l_ship_method_code_tab,
        x_autointransit_flag    => x_defaults_rec.autointransit_flag,
        x_autoclose_flag        => x_defaults_rec.autoclose_flag,
        x_report_set_id         => x_defaults_rec.report_set_id,
        x_report_set_name       => x_defaults_rec.report_set_name,
        x_ship_method_name      => x_defaults_rec.ship_method_name,
        x_return_status         => l_return_status,
        x_sc_rule_id            => x_defaults_rec.sc_rule_id,
        x_ac_bol_flag           => x_defaults_rec.ac_bol_flag,
        x_defer_interface_flag  => x_defaults_rec.defer_interface_flag,
        x_sc_rule_name          => x_defaults_rec.sc_rule_name
        );
      --
      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'Return Status After Calling Get_Delivery_Defaults',l_return_status);
        wsh_debug_sv.log(l_module_name,' Default AutoIntransit_Flag ',x_defaults_rec.autointransit_flag);
        wsh_debug_sv.log(l_module_name,' Default Autoclose_flag ',x_defaults_rec.autoclose_flag);
        wsh_debug_sv.log(l_module_name,' Default report_set_id ',x_defaults_rec.report_set_id);
        wsh_debug_sv.log(l_module_name,' Default report_set_name ',x_defaults_rec.report_set_name);
        wsh_debug_sv.log(l_module_name,' Default ship_method_name ',x_defaults_rec.ship_method_name);
        wsh_debug_sv.log(l_module_name,' Sc Rule ',x_defaults_rec.sc_rule_id);
        wsh_debug_sv.log(l_module_name,' Sc RuleName ',x_defaults_rec.sc_rule_name);
        wsh_debug_sv.log(l_module_name,' BOL ',x_defaults_rec.ac_bol_flag);
        wsh_debug_sv.log(l_module_name,' DI flag ',x_defaults_rec.defer_interface_flag);

      END IF;
      --
      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors);
      --
      open get_defer_interface;
      fetch get_defer_interface into l_defer_interface_flag, x_defaults_rec.enforce_ship_method;
      close get_defer_interface;
   -- END IF;
-- Ship Confirm Rule is Null, then use defer interface flag for 1st record
      IF x_defaults_rec.sc_rule_id IS NULL THEN
        x_defaults_rec.defer_interface_flag := l_defer_interface_flag;
      END IF;
    END IF;
    --
    IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_CHECK_UNASSIGN_LVL) = 1 THEN
      --
      WSH_TRIPS_ACTIONS.check_unassign_trip (
        p_del_rows      => l_delivery_id_tab,
        x_trip_rows     => x_defaults_rec.trip_id_tab,
        x_return_status => l_return_status);
      --
      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'Return Status After Calling check_unassign_trip',l_return_status);
      END IF;
      --
      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors);
      --
    END IF;
    --
    IF l_num_warnings > 0 THEN
      --
      FND_MESSAGE.SET_NAME('WSH', 'WSH_DISABLE_ACTION_WARN');
      x_return_status := wsh_util_core.g_ret_sts_warning;
      wsh_util_core.add_message(x_return_status,l_module_name);
      IF l_debug_on THEN
        wsh_debug_sv.logmsg(l_module_name, 'WSH_DISABLE_ACTION_WARN');
        wsh_debug_sv.log(l_module_name, 'x_delivery_out_rec.valid_ids_tab count is', l_valid_ids_tab.count);
      END IF;
      --
      IF p_action_prms.caller IN ('WSH_FSTRX', 'WSH_TRCON') THEN
        x_delivery_out_rec.selection_issue_flag := 'Y';
        RAISE WSH_UTIL_CORE.G_EXC_WARNING;
      ELSE
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      --
    END IF;
    --
   IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_VALIDATE_CONSTRAINTS_LVL) = 1  THEN --{
    --Compatiblity Changes
    --for autocreatetrip or if assign trip and caller is STF, phase=2

    IF wsh_util_core.fte_is_installed='Y'  THEN

    l_caller_module := SUBSTR(p_action_prms.caller,1,3);
    --
    IF l_debug_on THEN
        wsh_debug_sv.log (l_module_name,'l_caller_module : '||l_caller_module);
        wsh_debug_sv.log (l_module_name,'p_action_prms.pickup_loc_id : '||p_action_prms.pickup_loc_id);
        wsh_debug_sv.log (l_module_name,'p_action_prms.dropoff_loc_id : '||p_action_prms.dropoff_loc_id);
        wsh_debug_sv.log (l_module_name,'p_action_prms.ship_method_code : '||p_action_prms.ship_method_code);
    END IF;
    --

    i := p_rec_attr_tab.FIRST;
    WHILE i is not null LOOP
    --
        l_rec_attr_tab_temp(i) := p_rec_attr_tab(i);

        IF l_caller_module = 'FTE' THEN
           IF p_action_prms.ship_method_code IS NOT NULL AND p_action_prms.ship_method_code <> p_rec_attr_tab(i).ship_method_code THEN
              l_rec_attr_tab_temp(i).ship_method_code := p_action_prms.ship_method_code;
           END IF;

        END IF;
      --
      IF l_debug_on THEN
        wsh_debug_sv.log (l_module_name,'l_rec_attr_tab_temp index '|| i);
        wsh_debug_sv.log (l_module_name,'l_rec_attr_tab_temp delivery_id '|| l_rec_attr_tab_temp(i).delivery_id);
        wsh_debug_sv.log (l_module_name,'l_rec_attr_tab_temp name '|| l_rec_attr_tab_temp(i).name);
        wsh_debug_sv.log (l_module_name,'l_rec_attr_tab_temp status_code '|| l_rec_attr_tab_temp(i).status_code);
        wsh_debug_sv.log (l_module_name,'l_rec_attr_tab_temp planned_flag '|| l_rec_attr_tab_temp(i).planned_flag);
        wsh_debug_sv.log (l_module_name,'l_rec_attr_tab_temp organization_id '|| l_rec_attr_tab_temp(i).organization_id);
        wsh_debug_sv.log (l_module_name,'l_rec_attr_tab_temp customer_id '|| l_rec_attr_tab_temp(i).customer_id);
        wsh_debug_sv.log (l_module_name,'l_rec_attr_tab_temp delivery_type '|| l_rec_attr_tab_temp(i).delivery_type);
        wsh_debug_sv.log (l_module_name,'l_rec_attr_tab_temp initial_pickup_location_id '|| l_rec_attr_tab_temp(i).initial_pickup_location_id);
        wsh_debug_sv.log (l_module_name,'l_rec_attr_tab_temp ultimate_dropoff_location_id '|| l_rec_attr_tab_temp(i).ultimate_dropoff_location_id);
        wsh_debug_sv.log (l_module_name,'l_rec_attr_tab_temp ship_method_code '|| l_rec_attr_tab_temp(i).ship_method_code);
      END IF;
      --
      i := p_rec_attr_tab.NEXT(i);
    END LOOP;
    i := 0;
    --
    IF l_debug_on THEN
        wsh_debug_sv.log (l_module_name,'Calling validate_constraint_main ');
    END IF;
    --

     WSH_FTE_COMP_CONSTRAINT_PKG.validate_constraint_main(
       p_api_version_number =>  p_api_version_number,
       p_init_msg_list      =>  FND_API.G_FALSE,
       p_entity_type        =>  'D',
       p_target_id          =>  p_action_prms.TRIP_ID,
       p_action_code        =>  l_action_code,
       --p_del_attr_tab       =>  p_rec_attr_tab,
       p_del_attr_tab       =>  l_rec_attr_tab_temp,
       p_det_attr_tab       =>  l_cc_det_attr_tab,
       p_trip_attr_tab      =>  l_cc_trip_attr_tab,
       p_stop_attr_tab      =>  l_cc_stop_attr_tab,
       p_in_ids             =>  l_cc_in_ids,
       p_pickup_stop_id     => p_action_prms.pickup_stop_id,
       p_pickup_loc_id      => p_action_prms.pickup_loc_id,
       p_pickup_stop_seq    => p_action_prms.pickup_stop_seq,
       p_dropoff_stop_id    => p_action_prms.dropoff_stop_id,
       p_dropoff_loc_id     => p_action_prms.dropoff_loc_id,
       p_dropoff_stop_seq   => p_action_prms.dropoff_stop_seq,
       p_pickup_arr_date    => p_action_prms.pickup_arr_date,
       p_pickup_dep_date    => p_action_prms.pickup_dep_date,
       p_dropoff_arr_date   => p_action_prms.dropoff_arr_date,
       p_dropoff_dep_date   => p_action_prms.dropoff_dep_date,
       x_fail_ids           =>  l_cc_fail_ids,
       x_validate_result          =>  l_cc_validate_result,
       x_failed_lines             =>  l_cc_failed_records,
       x_line_groups              =>  l_cc_line_groups,
       x_group_info               =>  l_cc_group_info,
       x_msg_count                =>  l_msg_count,
       x_msg_data                 =>  l_msg_data,
       x_return_status            =>  l_return_status);


      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_constraint_main',l_return_status);
        wsh_debug_sv.log(l_module_name,'validate_result After Calling validate_constraint_main',l_cc_validate_result);
        wsh_debug_sv.log(l_module_name,'msg_count After Calling validate_constraint_main',l_msg_count);
        wsh_debug_sv.log(l_module_name,'msg_data After Calling validate_constraint_main',l_msg_data);
        wsh_debug_sv.log(l_module_name,'fail_ids count After Calling validate_constraint_main',l_cc_failed_records.COUNT);
        wsh_debug_sv.log(l_module_name,'l_cc_line_groups.count count After Calling validate_constraint_main',l_cc_line_groups.COUNT);
        wsh_debug_sv.log(l_module_name,'group_info count After Calling validate_constraint_main',l_cc_group_info.COUNT);
      END IF;
      --

    IF l_return_status=wsh_util_core.g_ret_sts_error THEN
      --fix l_rec_attr_tab to have only successful records
      l_cc_count_success:=1;

      IF l_debug_on THEN
         wsh_debug_sv.log(l_module_name,'p_rec_attr_tab.count before removing failed lines',p_rec_attr_tab.COUNT);
      END IF;

      IF l_cc_failed_records.COUNT = 0 AND p_rec_attr_tab.COUNT>0 THEN
         l_return_status := wsh_util_core.g_ret_sts_success;
      END IF;


      IF l_cc_failed_records.COUNT>0 AND p_rec_attr_tab.COUNT>0 THEN

          --set return_status as warning
          IF l_cc_failed_records.COUNT<>p_rec_attr_tab.COUNT THEN
             l_return_status:=wsh_util_core.g_ret_sts_warning;
          END IF;

       FOR i in p_rec_attr_tab.FIRST..p_rec_attr_tab.LAST LOOP
        b_cc_linefailed:=FALSE;

         FOR j in l_cc_failed_records.FIRST..l_cc_failed_records.LAST LOOP
          IF (p_rec_attr_tab(i).delivery_id=l_cc_failed_records(j).entity_line_id) THEN
            b_cc_linefailed:=TRUE;
            FND_MESSAGE.SET_NAME('WSH','WSH_DEL_COMP_FAILED');
            FND_MESSAGE.SET_TOKEN('DEL_ID',l_cc_failed_records(j).entity_line_id);
            wsh_util_core.add_message(l_return_status);
          END IF;
         END LOOP;

        IF (NOT(b_cc_linefailed)) THEN
          l_delivery_id_tab_t(l_cc_count_success):=p_rec_attr_tab(i).delivery_id;
          l_cc_count_success:=l_cc_count_success+1;
        END IF;
      END LOOP;
      --
      IF l_debug_on
      THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Value of ctrl rec After constraints check');
     END IF;

       --bsadri for assign-trip, if one line fails, then fail all lines {
       IF l_action_code = 'ASSIGN-TRIP'
          AND l_cc_failed_records.COUNT > 0 THEN
          l_delivery_id_tab_t.DELETE;
          l_return_status := wsh_util_core.g_ret_sts_error;
       END IF;
       --}


      IF l_delivery_id_tab_t.COUNT>0 THEN
        l_delivery_id_tab:=l_delivery_id_tab_t;
      ELSE
           IF l_debug_on THEN
               wsh_debug_sv.logmsg(l_module_name,'all lines errored in compatibility check');
           END IF;
          wsh_util_core.api_post_call(
           p_return_status    => l_return_status,
           x_num_warnings     => l_num_warnings,
           x_num_errors       => l_num_errors);

       END IF;

       IF l_debug_on THEN
         wsh_debug_sv.log(l_module_name,'l_delivery_id_tab.count before removing failed lines',l_delivery_id_tab.COUNT);
       END IF;
    END IF;

   ELSIF l_return_status=wsh_util_core.g_ret_sts_unexp_error THEN
      wsh_util_core.api_post_call(
           p_return_status    => l_return_status,
           x_num_warnings     => l_num_warnings,
           x_num_errors       => l_num_errors);
   END IF;
      --bug 3763800 : removed l_msg_data input so that message does not get added again
      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors,
        p_raise_error_flag => FALSE);
  END IF;
    --Compatiblity Changes
 END IF; --}



    IF p_action_prms.action_code IN ('CONFIRM', 'UNASSIGN-TRIP',
                                     'ASSIGN-TRIP','OUTBOUND-DOCUMENT',
                                     'PRINT-DOC-SETS')
    AND nvl(p_action_prms.phase,1) = 1
    AND p_action_prms.caller = 'WSH_FSTRX'
    THEN
      x_return_status := wsh_util_core.g_ret_sts_success;

      --Start of bug 4070732
      --Calling Reset_stops_for_load_tender as it is returning successfully.

      --Bugfix 4070732 {
      IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
         IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

            WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                      x_return_status => x_return_status);

            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
            END IF;

         END IF;
      END IF;
      --}
      -- End of bug 4070732

      IF l_debug_on THEN
        wsh_debug_sv.logmsg(l_module_name, 'Returning back to the Form');
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      RETURN; -- Non-Generic Actions.
    END IF;
    --
    -- Code added for Bug 2684692
    -- Need to lock related entities where applicable
    IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_LOCK_RELATED_ENTITIES_LVL) = 1
    THEN
    -- {
         Lock_Related_Entities(
            p_rec_attr_tab     => p_rec_attr_tab,
            p_action_prms      => p_action_prms,
            x_valid_ids_tab    => l_delivery_id_tab,
            x_return_status    => l_return_status
         );

         wsh_util_core.api_post_call(
         p_return_status    => l_return_status,
         x_num_warnings     => l_num_warnings,
         x_num_errors       => l_num_errors);
      --
    -- }
    END IF;


    --jckwok. Bug 3426434
    IF p_action_prms.action_code IN ('UNASSIGN-TRIP',
					 'ASSIGN-TRIP')
    THEN
     IF (nvl(p_action_prms.trip_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM
     AND nvl(p_action_prms.trip_name, FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR)
     THEN
	  FND_MESSAGE.SET_NAME('WSH', 'WSH_TRIP_ID_OR_NAME_REQUIRED');
	  FND_MESSAGE.SET_TOKEN('ACTION_CODE' , p_action_prms.action_code);
	  l_return_status := wsh_util_core.g_ret_sts_error;
	  wsh_util_core.add_message(l_return_status,l_module_name);
	  IF l_debug_on THEN
		 wsh_debug_sv.log (l_module_name,'Trip_id or Trip_name is required for this action');
	  END IF;
          RAISE FND_API.G_EXC_ERROR;
     END IF;
    END IF;
    --

    -- J-IB-NPARIKH-{
    IF p_action_prms.action_code = 'GENERATE-ROUTING-RESPONSE' THEN
      --
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERY_ACTIONS.generate_routing_response',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
      WSH_ROUTING_RESPONSE_PKG.GenerateRoutingResponse
        (
            p_deliveryIdTab      => l_delivery_id_tab,
            x_routingRespIdTab   => l_routingRespIdTab,
            x_RetStatus          => l_return_status
        );

      --
      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'Return Status After Calling generate_routing_response',l_return_status);
      END IF;
      --
      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors);
      --
      -- J-IB-NPARIKH-}

    ELSIF p_action_prms.action_code = 'PLAN' THEN
      --
      WSH_NEW_DELIVERY_ACTIONS.plan (
        p_del_rows      => l_delivery_id_tab,
        x_return_status => l_return_status);
      --
      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'Return Status After Calling Plan',l_return_status);
      END IF;
      --
      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors);
      --

    ELSIF p_action_prms.action_code = 'UNPLAN' THEN
      --
      WSH_NEW_DELIVERY_ACTIONS.unplan (
        p_del_rows      => l_delivery_id_tab,
        x_return_status => l_return_status);
      --
      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'Return Status After Calling Unplan',l_return_status);
      END IF;
      --
      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors);
      --
    /* J TP Release */
    ELSIF p_action_prms.action_code = 'FIRM' THEN
      --
      WSH_NEW_DELIVERY_ACTIONS.FIRM (
        p_del_rows      => l_delivery_id_tab,
        x_return_status => l_return_status);
      --
      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'Return Status After Calling firm',l_return_status);
      END IF;
      --
      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors);
      --

    ELSIF p_action_prms.action_code in ('IGNORE_PLAN', 'INCLUDE_PLAN') then
        Wsh_tp_release.change_ignoreplan_status
                   (p_entity        =>'DLVY',
                    p_in_ids        => l_delivery_id_tab,
                    p_action_code   => p_action_prms.action_code,
                    x_return_status => l_return_status);
        --
        IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'Return Status After Calling change_ignoreplan_status ',l_return_status);
        END IF;
         --
        wsh_util_core.api_post_call(
           p_return_status    => l_return_status,
           x_num_warnings     => l_num_warnings,
           x_num_errors       => l_num_errors);
         --

    ELSIF p_action_prms.action_code = 'PICK-RELEASE' THEN
      --
      WSH_PICK_LIST.launch_pick_release (
        p_trip_ids      => l_dummy_id_tab,
        p_stop_ids      => l_dummy_id_tab,
        p_delivery_ids  => l_delivery_id_tab,
        p_detail_ids    => l_dummy_id_tab,
        x_request_ids   => x_delivery_out_rec.result_id_tab,
        x_return_status => l_return_status);
      --
      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'Return Status After Calling Launch_Pick_Release',l_return_status);
      END IF;
      --
      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors);
      --
    ELSIF p_action_prms.action_code = 'PICK-PACK-SHIP' THEN
      --
      WSH_PICK_LIST.launch_pick_release (
        p_trip_ids      => l_dummy_id_tab,
        p_stop_ids      => l_dummy_id_tab,
        p_delivery_ids  => l_delivery_id_tab,
        p_detail_ids    => l_dummy_id_tab,
        x_request_ids   => x_delivery_out_rec.result_id_tab,
        x_return_status => l_return_status,
        p_auto_pack_ship => 'PS');
      --
      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'Return Status After Calling Launch_Pick_Release',l_return_status);
      END IF;
      --
      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors);
      --
    ELSIF p_action_prms.action_code = 'PICK-SHIP' THEN
      --
      WSH_PICK_LIST.launch_pick_release (
        p_trip_ids      => l_dummy_id_tab,
        p_stop_ids      => l_dummy_id_tab,
        p_delivery_ids  => l_delivery_id_tab,
        p_detail_ids    => l_dummy_id_tab,
        x_request_ids   => x_delivery_out_rec.result_id_tab,
        x_return_status => l_return_status,
        p_auto_pack_ship => 'SC');
      --
      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'Return Status After Calling Launch_Pick_Release',l_return_status);
      END IF;
      --
      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors);
      --
    ELSIF p_action_prms.action_code = 'PRINT-DOC-SETS' THEN
      --
      IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_DOCUMENT_SETS_LVL) = 1 THEN
        --
        WSH_UTIL_VALIDATE.validate_report_set(
          p_report_set_id   => l_report_set_id,
          p_report_set_name => p_action_prms.report_set_name,
          x_return_status   => l_return_status);
        --
        IF l_debug_on THEN
          wsh_debug_sv.log(l_module_name,'Return Status After Calling Validate_Report_Set',l_return_status);
        END IF;
        --
        wsh_util_core.api_post_call(
          p_return_status    => l_return_status,
          x_num_warnings     => l_num_warnings,
          x_num_errors       => l_num_errors);
        --
      END IF;
      --

      FOR i IN l_delivery_id_tab.FIRST..l_delivery_id_tab.LAST
      LOOP
        -- Start of bugfix 4493263
        OPEN c_delv_trip_id_cursor(l_delivery_id_tab(i));
        LOOP
           FETCH c_delv_trip_id_cursor INTO l_dummy_doc_set_params(i).p_trip_id;
           EXIT WHEN c_delv_trip_id_cursor%NOTFOUND;
           --
           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name, 'Trip Id : ', l_dummy_doc_set_params(i).p_trip_id );
           END IF;
           --
        END LOOP;
        CLOSE c_delv_trip_id_cursor;
        -- End of bugfix 4493263
      END LOOP;

      WSH_DOCUMENT_SETS.print_document_sets(
        p_report_set_id         => l_report_set_id ,
        p_organization_id       => p_action_prms.organization_id,
        p_trip_ids              => l_dummy_id_tab,
        p_stop_ids              => l_dummy_id_tab,
        p_delivery_ids          => l_delivery_id_tab,
        p_document_param_info   => l_dummy_doc_set_params,
        x_return_status         => l_return_status);
      --
      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'Return Status After Calling Print_Document_Sets',l_return_status);
      END IF;
      --
      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors);
      --
    ELSIF p_action_prms.action_code = 'WT-VOL' THEN
      --
      -- OTM R12 : packing ECO
      -- This change was introduced to mark the G_RESET_WV flag
      -- before calling delivery_weight_volume so the procedure will know
      -- to invoke update tms_interface_flag process.

      IF l_gc3_is_installed = 'Y' THEN
        WSH_WV_UTILS.G_RESET_WV := 'Y'; -- set to Y to enable the update
      END IF;
      -- End of OTM R12 : packing ECO

      WSH_WV_UTILS.Delivery_Weight_Volume(
        p_del_rows      => l_delivery_id_tab,
        p_update_flag   => p_action_prms.override_flag,
        x_return_status => l_return_status);
      --
      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'Return Status After Calling Delivery_Weight_Volume',l_return_status);
      END IF;
      --
      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors);

      -- OTM R12 : packing ECO
      IF l_gc3_is_installed = 'Y' THEN
        WSH_WV_UTILS.G_RESET_WV := 'N'; -- after call, set it back to 'N'
      END IF;
      -- End of OTM R12 : packing ECO

    ELSIF p_action_prms.action_code = 'AUTO-PACK' THEN

      IF NVL(p_action_prms.caller, 'X') <> 'WSH_BHPS' THEN

         IF l_delivery_id_tab.count > 0 THEN

           FORALL i in 1..l_delivery_id_tab.count
           update wsh_new_deliveries
           set ap_batch_id = NULL
           where delivery_id = l_delivery_id_tab(i);

         END IF;
       END IF;


      --
      WSH_CONTAINER_GRP.Auto_Pack (
        p_api_version               => p_api_version_number,
        p_init_msg_list             => p_init_msg_list,
        p_commit                    => p_commit,
        p_validation_level          => NULL,
        x_return_status             => l_return_status,
        x_msg_count                 => l_msg_count,
        x_msg_data                  => l_msg_data,
        p_entity_tab                => l_delivery_id_tab,
        p_entity_type               => 'D',
        p_group_id_tab              => l_dummy_id_tab,
        p_pack_cont_flag            => 'N',
        x_cont_inst_tab             => x_delivery_out_rec.result_id_tab);
      --
      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'Return Status After Calling Auto_Pack for Action Auto_Pack',l_return_status);
      END IF;
      --
      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors,
        p_msg_data         => l_msg_data);
      --

    ELSIF p_action_prms.action_code = 'AUTO-PACK-MASTER' THEN
      --

      IF NVL(p_action_prms.caller, 'X') <> 'WSH_BHPS' THEN

         IF l_delivery_id_tab.count > 0 THEN

           FORALL i in 1..l_delivery_id_tab.count
           update wsh_new_deliveries
           set ap_batch_id = NULL
           where delivery_id = l_delivery_id_tab(i);

         END IF;
       END IF;

      WSH_CONTAINER_GRP.Auto_Pack (
        p_api_version               => p_api_version_number,
        p_init_msg_list             => p_init_msg_list,
        p_commit                    => p_commit,
        p_validation_level          => NULL,
        x_return_status             => l_return_status,
        x_msg_count                 => l_msg_count,
        x_msg_data                  => l_msg_data,
        p_entity_tab                => l_delivery_id_tab,
        p_entity_type               => 'D',
        p_group_id_tab              => l_dummy_id_tab,
        p_pack_cont_flag            => 'Y',
        x_cont_inst_tab             => x_delivery_out_rec.result_id_tab);
      --
      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'Return Status After Calling Auto_Pack for Action Auto_Pack_Master',l_return_status);
      END IF;
      --
      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors,
        p_msg_data         => l_msg_data);
      --

    ELSIF p_action_prms.action_code = 'GEN-LOAD-SEQ' THEN
      --
      WSH_NEW_DELIVERY_ACTIONS.Generate_Loading_Seq(
        p_del_rows      => l_delivery_id_tab,
        x_return_status => l_return_status);
      --
      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'Return Status After Calling Generate_Loading_Seq',l_return_status);
      END IF;
      --
      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors);
      --
    ELSIF p_action_prms.action_code = 'CREATE-CONSOL-DEL' THEN
       WSH_DELIVERY_AUTOCREATE.Autocreate_Consol_Delivery(
           p_del_attributes_tab => p_rec_attr_tab,
           p_caller  => p_action_prms.caller,
           p_trip_prefix => p_action_prms.trip_name,
           x_parent_del_id => x_delivery_out_rec.result_id_tab(1),
           x_parent_trip_id => x_delivery_out_rec.valid_ids_tab(1),
           x_return_status => l_return_status);

       IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'Return Status After Calling  WSH_DELIVERY_AUTOCREATE.Autocreate_Consol_Delivery',l_return_status);
      END IF;
      --
      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors,
        p_msg_data         => l_msg_data);

    ELSIF p_action_prms.action_code = 'CONFIRM' THEN

      -- bug 4302048: if global parameter enforces ship method,
      -- the caller (e.g., Public API) must pass ship method code.
      --
      -- wsh_interface_grp will use the SC rule to derive it if required;
      -- direct callers of this API need to derive properly.
      --
      -- bug 5472722: DO NOT enforce shipmethod when cycle counting and
      -- back ordering all.

      --Bug 7418439: check if p_action_prms.ship_method_code is null only if the caller is Public API.
      --             When the Global parameter 'Enforce Ship Method' is enabled,a check is needed only
      --             when the caller is public API because UI (Forms) ensures that 'Ship Method' is a
      --             'Required' field whenever the last unconfirmed delivery in the trip is being confirmed.
      IF (p_action_prms.ship_method_code IS NULL) AND (p_action_prms.action_flag IN ('S', 'B', 'L', 'T', 'A')) AND (p_action_prms.caller = 'WSH_PUB') THEN

       OPEN c_unconfirmed_del_exist(l_delivery_id_tab(1));
       FETCH c_unconfirmed_del_exist into l_unconfirmed_del_exist;

       IF l_debug_on THEN
           wsh_debug_sv.log(l_module_name,'l_unconfirmed_del_exist : ',l_unconfirmed_del_exist);
       END IF;
       IF l_unconfirmed_del_exist IS NULL THEN

        DECLARE
         l_global_parameters WSH_SHIPPING_PARAMS_PVT.Global_Parameters_Rec_Typ;
        BEGIN
          WSH_SHIPPING_PARAMS_PVT.Get_Global_Parameters(
                  x_param_info    => l_global_parameters,
                  x_return_status => l_return_status);
          IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
            x_return_status := l_return_status;
            IF l_debug_on THEN
              WSH_DEBUG_SV.pop(l_module_name,'get_global_parameters failed');
            END IF;
            RETURN;
          END IF;

          IF l_global_parameters.enforce_ship_method = 'Y' THEN
            FND_MESSAGE.SET_NAME('WSH','WSH_SC_SM_REQUIRED');
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            wsh_util_core.add_message(x_return_status,l_module_name);
            IF l_debug_on THEN
              WSH_DEBUG_SV.pop(l_module_name,'ship method is required');
            END IF;
            RETURN;
          END IF;
        END;
       END IF;
      END IF;

-- Bug#3880569: Validating the Ship Method Code.
-- Do the Validation only if the Delivery is not associated with a Trip.
l_ship_method_code   := p_action_prms.ship_method_code;
l_is_del_assign_trip := FALSE;

FOR i in l_delivery_id_tab.FIRST..l_delivery_id_tab.LAST LOOP
        -- Bug 4100661
        l_temp_trip_id := NULL;
        OPEN c_del_assign_to_trip(l_delivery_id_tab(i));
        LOOP
           FETCH c_del_assign_to_trip INTO l_temp_trip_id, l_temp_ship_method_code, l_temp_lane_id;
           EXIT WHEN c_del_assign_to_trip%NOTFOUND;
           IF l_temp_trip_id is not NULL THEN
              l_is_del_assign_trip := TRUE;

              IF WSH_UTIL_CORE.FTE_IS_INSTALLED = 'Y' AND l_temp_lane_id is not NULL AND
                 NVL(l_ship_method_code,l_temp_ship_method_code) <> l_temp_ship_method_code THEN
                 CLOSE c_del_assign_to_trip;
                 l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                 FND_MESSAGE.SET_NAME('FTE', 'FTE_SEGMENT_CSM_CHANGE_ERROR');
                 FND_MESSAGE.SET_TOKEN('TRIP_SEGMENT_NAME', wsh_trips_pvt.get_name(l_temp_trip_id));
                 WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);

                 wsh_util_core.api_post_call(
                   p_return_status    => l_return_status,
                   x_num_warnings     => l_num_warnings,
                   x_num_errors       => l_num_errors);
              END IF;
           END IF;
        END LOOP;
        CLOSE c_del_assign_to_trip;
        /*
        IF c_del_assign_to_trip%FOUND THEN
            l_is_del_assign_trip := TRUE;
            CLOSE c_del_assign_to_trip;
            exit;
        END IF;
        CLOSE c_del_assign_to_trip;
        */
END LOOP;

IF NOT l_is_del_assign_trip AND l_ship_method_code IS NOT NULL AND p_action_prms.caller <> 'WSH_FSTRX' THEN
	WSH_UTIL_VALIDATE.Validate_Active_SM
      ( p_ship_method_code => l_ship_method_code,
        p_ship_method_name => l_ship_method_name,
        x_return_status    => l_return_status
       );
       wsh_util_core.api_post_call(p_return_status  => l_return_status,
                                   x_num_warnings   => l_num_warnings,
                                   x_num_errors     => l_num_errors);
END IF;

-- End, Bug#3880569

      IF NVL(p_action_prms.caller, 'X') <> 'WSH_BHPS' THEN

         IF l_delivery_id_tab.count > 0 THEN

           FORALL i in 1..l_delivery_id_tab.count
           update wsh_new_deliveries
           set batch_id = NULL
           where delivery_id = l_delivery_id_tab(i);

         END IF;
      END IF;
      --
      IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_DOCUMENT_SETS_LVL) = 1 THEN
        --
        WSH_UTIL_VALIDATE.validate_report_set(
          p_report_set_id   => l_report_set_id,
          p_report_set_name => p_action_prms.report_set_name,
          x_return_status   => l_return_status);
        --
        IF l_debug_on THEN
          wsh_debug_sv.log(l_module_name,'Return Status After Calling Validate_Report_Set',l_return_status);
        END IF;
        --
        wsh_util_core.api_post_call(
          p_return_status    => l_return_status,
          x_num_warnings     => l_num_warnings,
          x_num_errors       => l_num_errors);
        --
      END IF;
      --

      -- Bug 3877951
      IF p_action_prms.close_trip_flag = 'Y' THEN
         l_intransit_flag := 'Y';
      ELSE
         l_intransit_flag := p_action_prms.intransit_flag;
      END IF;
      --
      IF NVL(p_action_prms.caller, 'X') <> 'WSH_BHPS' THEN
	      --
	WSH_NEW_DELIVERY_ACTIONS.Confirm_Delivery(
	   p_del_rows              => l_delivery_id_tab,
	   p_action_flag           => p_action_prms.action_flag,
	   p_intransit_flag        => l_intransit_flag,
	   p_close_flag            => p_action_prms.close_trip_flag,
	   p_stage_del_flag        => p_action_prms.stage_del_flag,
	   p_report_set_id         => l_report_set_id,
	   p_ship_method           => p_action_prms.ship_method_code,
	   p_actual_dep_date       => p_action_prms.actual_dep_date,
	   p_bol_flag              => p_action_prms.bill_of_lading_flag,
	   p_mc_bol_flag           => p_action_prms.bill_of_lading_flag,
	   p_defer_interface_flag  => p_action_prms.defer_interface_flag,
	   p_send_945_flag         => p_action_prms.send_945_flag,
	   x_return_status         => l_return_status);
      ELSE
	WSH_NEW_DELIVERY_ACTIONS.Confirm_Delivery(
	   p_del_rows              => l_delivery_id_tab,
	   p_action_flag           => p_action_prms.action_flag,
	   p_intransit_flag        => l_intransit_flag,
	   p_close_flag            => p_action_prms.close_trip_flag,
	   p_stage_del_flag        => p_action_prms.stage_del_flag,
	   p_report_set_id         => l_report_set_id,
	   p_ship_method           => p_action_prms.ship_method_code,
	   p_actual_dep_date       => p_action_prms.actual_dep_date,
	   p_bol_flag              => p_action_prms.bill_of_lading_flag,
	   p_mc_bol_flag           => p_action_prms.mc_bill_of_lading_flag,
	   p_defer_interface_flag  => p_action_prms.defer_interface_flag,
	   p_send_945_flag         => p_action_prms.send_945_flag,
	   x_return_status         => l_return_status);
      END IF;
      --
      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'Return Status After Calling Confirm_Delivery',l_return_status);
      END IF;
      --
      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors);
      --
      IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_PRINT_LABEL_LVL) = 1 THEN
        --
        -- Bug#5864517: Needs to call Print_Label API irrespective of p_intransit_flag and p_close_flag
        --                flag values.
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Calling WSH_UTIL_CORE.Print_Label');
        END IF;

          WSH_UTIL_CORE.Print_Label(
            p_stop_ids      => l_dummy_id_tab,
            p_delivery_ids  => l_delivery_id_tab,
            x_return_status => l_return_status);
          --
          IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'Return Status After Calling Print_Label',l_return_status);
          END IF;
          --
          wsh_util_core.api_post_call(
            p_return_status    => l_return_status,
            x_num_warnings     => l_num_warnings,
            x_num_errors       => l_num_errors);
          --
      --
      END IF;
      --

    ELSIF p_action_prms.action_code IN ('RE-OPEN','CLOSE') THEN
      --
      WSH_NEW_DELIVERY_ACTIONS.Change_Status (
        p_del_rows      => l_delivery_id_tab,
        p_action        => p_action_prms.action_code,
        p_actual_date   => NULL,
        x_return_status => l_return_status);
      --
      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'Return Status After Calling Change_Status',l_return_status);
      END IF;
      --
      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors);
      --
    ELSIF p_action_prms.action_code = 'ASSIGN-TRIP' THEN
      --
      IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_TRIP_NAME_LVL) = 1 THEN
        --
        WSH_UTIL_VALIDATE.Validate_Trip_Name (
          p_trip_id       => l_trip_id,
          p_trip_name     => p_action_prms.trip_name,
          x_return_status => l_return_status);
        --
      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'Return Status After Calling Validate_Trip_Name',l_return_status);
      END IF;
      --
        wsh_util_core.api_post_call(
          p_return_status    => l_return_status,
          x_num_warnings     => l_num_warnings,
          x_num_errors       => l_num_errors);
        --
      END IF;
      --
      IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_TRIP_STATUS_LVL) = 1 THEN
        --
        --WSH_UTIL_VALIDATE.Validate_Trip_Status(   -- J-IB-NPARIKH
        WSH_TRIP_VALIDATIONS.Validate_Trip_Status(   -- J-IB-NPARIKH
          p_trip_id       => l_trip_id,
          p_action        => p_action_prms.action_code,
          x_return_status => l_return_status);
        --
      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'Return Status After Calling Validate_Trip_Status',l_return_status);
      END IF;
      --
        wsh_util_core.api_post_call(
          p_return_status    => l_return_status,
          x_num_warnings     => l_num_warnings,
          x_num_errors       => l_num_errors);
        --
      END IF;
      --
      IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_LOCATION_LVL) = 1 THEN
        --
        WSH_UTIL_VALIDATE.Validate_Location (
          p_location_id      => l_pickup_loc_id,
          p_location_code    => p_action_prms.pickup_loc_code,
          x_return_status    => l_return_status,
          p_isWshLocation    => l_isWshLocation);
        --
        IF l_debug_on THEN
          wsh_debug_sv.log(l_module_name,'Return Status After Calling Validate_Location',l_return_status);
        END IF;
        --
        wsh_util_core.api_post_call(
          p_return_status    => l_return_status,
          x_num_warnings     => l_num_warnings,
          x_num_errors       => l_num_errors);
        --
        WSH_UTIL_VALIDATE.Validate_Location (
          p_location_id      => l_dropoff_loc_id,
          p_location_code    => p_action_prms.dropoff_loc_code,
          x_return_status    => l_return_status,
          p_isWshLocation    => l_isWshLocation);
        --
        IF l_debug_on THEN
          wsh_debug_sv.log(l_module_name,'Return Status After Calling Validate_Location',l_return_status);
        END IF;
        --
        wsh_util_core.api_post_call(
          p_return_status    => l_return_status,
          x_num_warnings     => l_num_warnings,
          x_num_errors       => l_num_errors);
        --
      END IF;
      --
      IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_STOP_NAME_LVL) = 1 THEN
        --
        -- If stops are specified, validate they are eligible.
        --
        IF p_action_prms.pickup_stop_id IS NOT NULL THEN
          l_stop_id := p_action_prms.pickup_stop_id;
          WSH_UTIL_VALIDATE.Validate_Stop_Name (
            p_stop_id          => l_stop_id,
            p_trip_id          => p_action_prms.trip_id,
            p_stop_location_id => NULL,  -- not needed
            p_planned_dep_date => NULL,  -- not needed
            x_return_status    => l_return_status);
          --
          IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'Return Status After Calling Validate_Stop_Name for pickup',l_return_status);
          END IF;
          --
          wsh_util_core.api_post_call(
             p_return_status    => l_return_status,
             x_num_warnings     => l_num_warnings,
             x_num_errors       => l_num_errors);
          --
        END IF;
        --
        IF p_action_prms.dropoff_stop_id IS NOT NULL THEN
          l_stop_id := p_action_prms.dropoff_stop_id;
          WSH_UTIL_VALIDATE.Validate_Stop_Name (
            p_stop_id          => l_stop_id,
            p_trip_id          => p_action_prms.trip_id,
            p_stop_location_id => NULL,  -- not needed
            p_planned_dep_date => NULL,  -- not needed
            x_return_status    => l_return_status);
          --
          IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'Return Status After Calling Validate_Stop_Name for drop off',l_return_status);
          END IF;
          --
          wsh_util_core.api_post_call(
             p_return_status    => l_return_status,
             x_num_warnings     => l_num_warnings,
             x_num_errors       => l_num_errors);
          --
        END IF;
        --
      END IF;
      --
      -- SSN change
      -- Validate stop_sequence_number if profile option is set to SSN
      IF (WSH_TRIPS_ACTIONS.GET_STOP_SEQ_MODE  = WSH_INTERFACE_GRP.G_STOP_SEQ_MODE_SSN) AND
              (WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_SEQ_NUM_LVL) = 1) THEN
                --
                -- in context of creating new stops, their status is
                -- assumed to be NULL, so we need to pass 'OP'
                -- to avoid getting error about invalid stop status.
                --
                WSH_TRIP_STOPS_VALIDATIONS.Validate_Sequence_Number (
                  p_stop_id              => p_action_prms.pickup_stop_id,
                  p_stop_sequence_number => p_action_prms.pickup_stop_seq,
                  p_trip_id              => l_trip_id,
                  p_status_code          => NVL(p_action_prms.pickup_stop_status, 'OP'),
                  x_return_status        => l_return_status);
                --
                IF l_debug_on THEN
                  wsh_debug_sv.log(l_module_name,'Return Status After Calling Validate_Sequence_Number',l_return_status);
                END IF;
                --
                wsh_util_core.api_post_call(
                  p_return_status    => l_return_status,
                  x_num_warnings     => l_num_warnings,
                  x_num_errors       => l_num_errors);
                --
                WSH_TRIP_STOPS_VALIDATIONS.Validate_Sequence_Number (
                  p_stop_id              => p_action_prms.dropoff_stop_id,
                  p_stop_sequence_number => p_action_prms.dropoff_stop_seq,
                  p_trip_id              => l_trip_id,
                  p_status_code          => NVL(p_action_prms.dropoff_stop_status, 'OP'),
                  x_return_status        => l_return_status);
                --
                IF l_debug_on THEN
                  wsh_debug_sv.log(l_module_name,'Return Status After Calling Validate_Sequence_Number',l_return_status);
                END IF;
                --
                wsh_util_core.api_post_call(
                  p_return_status    => l_return_status,
                  x_num_warnings     => l_num_warnings,
                  x_num_errors       => l_num_errors);
                --
      END IF; -- If profile = SSN and level = 1

      --
      -- bug 3516052
      -- validate the planned date for pick up and drop off stop

      IF p_action_prms.pickup_dep_date is not NULL and
         p_action_prms.pickup_arr_date is not NULL and
         (p_action_prms.pickup_dep_date < p_action_prms.pickup_arr_date) THEN
         l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

         l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('WSH', 'WSH_PLAN_DEP_ARR_DATE');
         wsh_util_core.add_message(l_return_status, l_module_name);

         wsh_util_core.api_post_call(
           p_return_status    => l_return_status,
           x_num_warnings     => l_num_warnings,
           x_num_errors       => l_num_errors);
      END IF;

      IF p_action_prms.dropoff_dep_date is not NULL and
         p_action_prms.dropoff_arr_date is not NULL and
         (p_action_prms.dropoff_dep_date < p_action_prms.dropoff_arr_date) THEN

         l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('WSH', 'WSH_PLAN_DEP_ARR_DATE');
         wsh_util_core.add_message(l_return_status, l_module_name);

         wsh_util_core.api_post_call(
            p_return_status    => l_return_status,
            x_num_warnings     => l_num_warnings,
            x_num_errors       => l_num_errors);
      END IF;
      --
      --OTM R12, check for allowed assign trip
      IF (l_gc3_is_installed = 'Y' AND p_action_prms.caller <> 'FTE_TMS_INTEGRATION') THEN

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'checking for include for planning trip');
        END IF;

        --check for include for planning, delivery should have same ignore for planning flag as trip
        --if any delivery is include for planning, cannot assign to trip
        i := p_rec_attr_tab.FIRST;
        WHILE i IS NOT NULL LOOP

          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'ignore for planning for delivery ' || i, p_rec_attr_tab(i).ignore_for_planning);
          END IF;

          IF (NVL(p_rec_attr_tab(i).ignore_for_planning, 'N') = 'N') THEN

            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'GC3 IS INSTALLED, AND TRIP IS INCLUDE FOR PLANNING, CANNOT ASSIGN');
            END IF;

            FND_MESSAGE.SET_NAME('WSH', 'WSH_OTM_ASSIGN_TRIP');

            l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            WSH_UTIL_CORE.add_message(x_return_status, l_module_name);

            wsh_util_core.api_post_call(
              p_return_status    => l_return_status,
              x_num_warnings     => l_num_warnings,
              x_num_errors       => l_num_errors);

          END IF;

          i := p_rec_attr_tab.NEXT(i);
        END LOOP;
      END IF;
      --END OTM R12

      WSH_TRIPS_ACTIONS.Assign_Trip (
        p_del_rows              => l_delivery_id_tab,
        p_trip_id               => l_trip_id,
        p_pickup_stop_id        => p_action_prms.pickup_stop_id,
        p_pickup_stop_seq       => p_action_prms.pickup_stop_seq,
        p_dropoff_stop_id       => p_action_prms.dropoff_stop_id,
        p_dropoff_stop_seq      => p_action_prms.dropoff_stop_seq,
        p_pickup_location_id    => p_action_prms.pickup_loc_id,
        p_dropoff_location_id   => p_action_prms.dropoff_loc_id,
        p_pickup_arr_date       => p_action_prms.pickup_arr_date,
        p_pickup_dep_date       => p_action_prms.pickup_dep_date,
        p_dropoff_arr_date      => p_action_prms.dropoff_arr_date,
        p_dropoff_dep_date      => p_action_prms.dropoff_dep_date,
        p_caller                => p_action_prms.caller||'ASSIGNTRIP',
        x_return_status         => l_return_status
        );
      --
      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'Return Status After Calling Assign_Trip',l_return_status);
      END IF;
      --
      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors);
      --

    ELSIF p_action_prms.action_code = 'UNASSIGN-TRIP' THEN
      --
      IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_TRIP_NAME_LVL) = 1 THEN
        --
        WSH_UTIL_VALIDATE.Validate_Trip_Name (
          p_trip_id       => l_trip_id,
          p_trip_name     => p_action_prms.trip_name,
          x_return_status => l_return_status);
        --
        IF l_debug_on THEN
          wsh_debug_sv.log(l_module_name,'Return Status After Calling Validate_Trip_Name',l_return_status);
        END IF;
        --
        wsh_util_core.api_post_call(
          p_return_status    => l_return_status,
          x_num_warnings     => l_num_warnings,
          x_num_errors       => l_num_errors);
        --
      END IF;
      --
      WSH_TRIPS_ACTIONS.Unassign_Trip (
        p_del_rows      => l_delivery_id_tab,
        p_trip_id       => l_trip_id,
        x_return_status => l_return_status);
      --
      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'Return Status After Calling Unassign_Trip',l_return_status);
      END IF;
      --
      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors);
      --

      --OTM R12, validate after unassign to set delivery status.
      IF (l_gc3_is_installed = 'Y') THEN

        --check for include for planning, delivery should have same ignore for planning flag as trip
        --in theory all delivery on that trip should have same ignore for planning flag, so if
        --any delivery is include for planning, assume trip is include for planning
        i := p_rec_attr_tab.FIRST;

        WHILE (i IS NOT NULL) LOOP
          IF (NVL(p_rec_attr_tab(i).ignore_for_planning, 'N') = 'N') THEN

            IF (p_action_prms.caller <> 'FTE_TMS_INTEGRATION') THEN

              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TP_RELEASE.CHANGE_IGNOREPLAN_STATUS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_TP_RELEASE.change_ignoreplan_status
                  (p_entity         => 'DLVY',
                   p_in_ids         => l_delivery_id_tab,
                   p_action_code    => 'IGNORE_PLAN',
                   x_return_status  => l_return_status);

              IF l_debug_on THEN
                wsh_debug_sv.log(l_module_name,'Return Status After Calling change_ignoreplan_sttatus',l_return_status);
              END IF;

              WSH_UTIL_CORE.api_post_call(
                  p_return_status    => l_return_status,
                  x_num_warnings     => l_num_warnings,
                  x_num_errors       => l_num_errors);

              -- now have to set the other dels on this trip to AW if it's AR l_trip_id
              OPEN c_get_delivery_id(l_trip_id);
              FETCH c_get_delivery_id BULK COLLECT INTO l_new_delivery_id_tab, l_new_interface_flag_tab;
              --table is default NULL, so if no delivery found then the table stay empty
              CLOSE c_get_delivery_id;

              IF l_debug_on THEN
                wsh_debug_sv.log(l_module_name,'l_trip_id', l_trip_id);
                wsh_debug_sv.log(l_module_name,'delivery id count', l_new_delivery_id_tab.COUNT);
              END IF;

              IF (l_new_delivery_id_tab.COUNT > 0) THEN

                IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.UPDATE_TMS_INTERFACE_FLAG',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;

                WSH_NEW_DELIVERIES_PVT.update_tms_interface_flag(
                    p_delivery_id_tab        => l_new_delivery_id_tab,
                    p_tms_interface_flag_tab => l_new_interface_flag_tab,
                    x_return_status          => l_return_status);

                IF l_debug_on THEN
                  wsh_debug_sv.log(l_module_name,'Return Status After Calling update_tms_interface_flag',l_return_status);
                END IF;

                WSH_UTIL_CORE.api_post_call(
                    p_return_status    => l_return_status,
                    x_num_warnings     => l_num_warnings,
                    x_num_errors       => l_num_errors);

              END IF;

            END IF;  --action prms check

            --delete freight cost record, delivery leg is deleted
            --when delivery unassigned from trip, no need to delete the leg's freight cost
            IF l_delivery_id_tab.COUNT > 0 THEN
              FORALL i IN l_delivery_id_tab.FIRST..l_delivery_id_tab.LAST
                DELETE FROM WSH_FREIGHT_COSTS
                WHERE delivery_id = l_delivery_id_tab(i);
            END IF;
            EXIT; --exit loop once an include for delivery is found because this trip will only need to be processed once
          END IF; --ignore for planning check

          i := p_rec_attr_tab.NEXT(i);
        END LOOP;
      END IF;
      --END OTM R12

    ELSIF p_action_prms.action_code = 'AUTOCREATE-TRIP' THEN
      --
       --Compatibility Changes
      IF wsh_util_core.fte_is_installed = 'Y' AND l_cc_line_groups.COUNT>0 THEN

       --1. get the group ids by which the constraints API has grouped the lines
       l_cc_count_group_ids:=1;
       FOR i in l_cc_line_groups.FIRST..l_cc_line_groups.LAST LOOP
         b_cc_groupidexists:=FALSE;
         IF l_cc_group_ids.COUNT>0 THEN
           FOR j in l_cc_group_ids.FIRST..l_cc_group_ids.LAST LOOP
             IF (l_cc_line_groups(i).line_group_id=l_cc_group_ids(j)) THEN
               b_cc_groupidexists:=TRUE;
             END IF;
           END LOOP;
         END IF;

         IF (NOT(b_cc_groupidexists)) THEN
           l_cc_group_ids(l_cc_count_group_ids):=l_cc_line_groups(i).line_group_id;
           l_cc_count_group_ids:=l_cc_count_group_ids+1;
         END IF;
      END LOOP;

      --2. from the group id table above, loop thru lines table to get the lines which belong
      --to each group and call autocreate_trip for each group
      FOR i in l_cc_group_ids.FIRST..l_cc_group_ids.LAST LOOP
        l_cc_count_rec:=1;
        FOR j in l_cc_line_groups.FIRST..l_cc_line_groups.LAST LOOP
          IF l_cc_line_groups(j).line_group_id=l_cc_group_ids(i) THEN
            l_delivery_id_tab_temp(l_cc_count_rec):=l_cc_line_groups(j).entity_line_id;
            l_cc_count_rec:=l_cc_count_rec+1;
          END IF;
        END LOOP;

        IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'l_delivery_id_tab_temp count ',l_delivery_id_tab_temp.COUNT);
        END IF;

        /* J TP Release */
        WSH_TRIPS_ACTIONS.autocreate_trip_multi( p_del_rows      => l_delivery_id_tab_temp,
                             x_trip_ids      => x_delivery_out_rec.result_id_tab,
                             x_trip_names    => l_trip_names,
                             x_return_status => l_return_status);

        IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'return from autocreate_trip_multi '
                                                             ,l_return_status);
        END IF;

        --set the ship method to null if group rec from constraint validation has this as 'N'
        l_cc_upd_dlvy_ship_method:='Y';
        IF l_cc_group_info.COUNT>0 THEN
          FOR j in l_cc_group_info.FIRST..l_cc_group_info.LAST LOOP
            IF l_cc_group_info(j).line_group_id=l_cc_group_ids(i) THEN
              l_cc_upd_dlvy_ship_method:=l_cc_group_info(j).upd_dlvy_ship_method;
            END IF;
          END LOOP;
        END IF;

        IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'l_cc_upd_dlvy_ship_method ',l_cc_upd_dlvy_ship_method);
            IF (x_delivery_out_rec.result_id_tab.count > 0)  THEN
              wsh_debug_sv.log(l_module_name,'l_trip_id ', x_delivery_out_rec.result_id_tab(1));
            ELSE
              wsh_debug_sv.log(l_module_name,'l_trip_id ', 'not created');
            END IF;
            IF (l_trip_names.count > 0) THEN
              wsh_debug_sv.log(l_module_name,'l_trip_name ',l_trip_names(1));
            ELSE
              wsh_debug_sv.log(l_module_name,'l_trip_name ', 'not created');
            END IF;
            wsh_debug_sv.log(l_module_name,'l_return_status after calling autocreate_trip in comp ',l_return_status);
        END IF;

        /* J TP Release */
        IF x_delivery_out_rec.result_id_tab is not null AND x_delivery_out_rec.result_id_tab.COUNT>0 THEN
          FOR l_tripindex IN x_delivery_out_rec.result_id_tab.FIRST..x_delivery_out_rec.result_id_tab.LAST LOOP
            IF l_cc_upd_dlvy_ship_method='N' THEN
              FOR tripcurtemp in trip_cur(x_delivery_out_rec.result_id_tab(l_tripindex)) LOOP
                l_cc_dlvy_ship_method:=tripcurtemp.SHIP_METHOD_CODE;
                IF l_cc_upd_dlvy_ship_method='N' THEN
                  update wsh_trips
                  set SHIP_METHOD_CODE=null,
                    CARRIER_ID = null,
                    MODE_OF_TRANSPORT = null,
                    SERVICE_LEVEL = null
                  where trip_id= x_delivery_out_rec.result_id_tab(l_tripindex);
                END IF;
              END LOOP;
            END IF;
            --set the intermediate ship to, ship method to null if group rec from constraint validation has these as 'N'

          l_cc_trip_id(l_cc_trip_id.COUNT+1):=x_delivery_out_rec.result_id_tab(l_tripindex);
          END LOOP;
        END IF;--x_delivery_out_rec.result_id_tab
        --
        IF (l_cc_return_status is not null AND l_cc_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
          l_return_status:=l_cc_return_status;
        ELSIF (l_cc_return_status is not null AND l_cc_return_status=WSH_UTIL_CORE.G_RET_STS_WARNING AND l_return_status=WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
          l_return_status:=l_cc_return_status;
        ELSE
          l_cc_return_status:=l_return_status;
        END IF;

      END LOOP;
      x_delivery_out_rec.result_id_tab := l_cc_trip_id;
      l_return_status:=l_cc_return_status;

      IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'x_delivery_out_rec.result_id_tab.COUNT after loop ',x_delivery_out_rec.result_id_tab.COUNT);
      END IF;

     ELSE
        /* J TP Release */
        WSH_TRIPS_ACTIONS.autocreate_trip_multi( p_del_rows      => l_delivery_id_tab,
                             x_trip_ids      => x_delivery_out_rec.result_id_tab,
                             x_trip_names    => l_trip_names,
                             x_return_status => l_return_status);

     END IF;
        --
     IF l_debug_on THEN
          wsh_debug_sv.log(l_module_name,'Return Status After Calling Autocreate_Trip',l_return_status);
     END IF;
     --
     wsh_util_core.api_post_call(
          p_return_status    => l_return_status,
          x_num_warnings     => l_num_warnings,
          x_num_errors       => l_num_errors);
    --
    -- rlanka : Trip Consolidation Pack J
    --
    ELSIF p_action_prms.action_code = 'TRIP-CONSOLIDATION' THEN
      --
      IF wsh_util_core.fte_is_installed = 'Y' AND l_cc_line_groups.COUNT > 0 THEN
       --{
       -- 1. get the group ids by which the constraints API has grouped the lines
       --
       l_cc_count_group_ids:=1;
       FOR i in l_cc_line_groups.FIRST..l_cc_line_groups.LAST LOOP
         --{
         b_cc_groupidexists:=FALSE;
         IF l_cc_group_ids.COUNT>0 THEN
           FOR j in l_cc_group_ids.FIRST..l_cc_group_ids.LAST LOOP
             IF (l_cc_line_groups(i).line_group_id=l_cc_group_ids(j)) THEN
               b_cc_groupidexists:=TRUE;
             END IF;
           END LOOP;
         END IF;

         IF (NOT(b_cc_groupidexists)) THEN
           l_cc_group_ids(l_cc_count_group_ids):=l_cc_line_groups(i).line_group_id;
           l_cc_count_group_ids:=l_cc_count_group_ids+1;
         END IF;
         --}
       END LOOP;
       --
       -- 2. from the group id table above, loop thru lines table to get the lines which belong
       -- to each group and call autocreate_trip for each group
       FOR i in l_cc_group_ids.FIRST..l_cc_group_ids.LAST LOOP
         --{
         l_cc_count_rec:=1;
         l_delivery_id_tab_temp.DELETE;      -- added this line
         FOR j in l_cc_line_groups.FIRST..l_cc_line_groups.LAST LOOP
           IF l_cc_line_groups(j).line_group_id=l_cc_group_ids(i) THEN
             l_delivery_id_tab_temp(l_cc_count_rec):=l_cc_line_groups(j).entity_line_id;
             l_cc_count_rec:=l_cc_count_rec+1;
           END IF;
         END LOOP;
         --
         IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'Number of delivs. in this group',l_delivery_id_tab_temp.COUNT);
         END IF;
	 --
	 l_DelivGrpRec.deliv_IDTab := l_delivery_id_tab_temp;
	 l_delivGrpRec.max_Delivs  := p_action_prms.maxDelivs;
	 --
         WSH_TRIP_CONSOLIDATION.GroupDelivsIntoTrips(
           p_delivGrpRec	=> l_delivGrpRec,
           x_delOutRec       	=> x_delivery_out_rec,
           x_return_status 	=> l_return_status);
         --
         l_cc_upd_dlvy_ship_method:='Y';
         --
         IF l_cc_group_info.COUNT > 0 THEN
           FOR j in l_cc_group_info.FIRST..l_cc_group_info.LAST LOOP
             IF l_cc_group_info(j).line_group_id=l_cc_group_ids(i) THEN
              l_cc_upd_dlvy_ship_method:=l_cc_group_info(j).upd_dlvy_ship_method;
             END IF;
           END LOOP;
         END IF;
         --
         IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'l_cc_upd_dlvy_ship_method ',l_cc_upd_dlvy_ship_method);
            wsh_debug_sv.log(l_module_name, '# of trips', x_delivery_out_rec.result_id_tab.COUNT);
            wsh_debug_sv.log(l_module_name,'l_return_status after GroupDelivsIntoTrips',l_return_status);
         END IF;
         --
         j := x_delivery_out_rec.result_id_tab.FIRST;
         WHILE j IS NOT NULL LOOP
           --{
           IF l_debug_on THEN
             wsh_debug_sv.log(l_module_name, 'Trip Name', x_delivery_out_rec.result_id_tab(j));
           END IF;
           --
           l_tripID := x_delivery_out_rec.result_id_tab(j);
           --
           IF l_cc_upd_dlvy_ship_method='N' THEN
             FOR tripcurtemp in trip_cur(l_tripID) LOOP
               l_cc_dlvy_ship_method:=tripcurtemp.SHIP_METHOD_CODE;
               IF l_cc_upd_dlvy_ship_method='N' THEN
                 update wsh_trips
                 set SHIP_METHOD_CODE=null,
                    CARRIER_ID = null,
                    MODE_OF_TRANSPORT = null,
                    SERVICE_LEVEL = null
                 where trip_id= l_tripID;
               END IF;
             END LOOP;
           END IF;
           --}
           j := x_delivery_out_rec.result_id_tab.NEXT(j);
           --
         END LOOP;
         --
         IF (l_cc_return_status is not null AND
	     l_cc_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
           l_return_status:=l_cc_return_status;
         ELSIF (l_cc_return_status is not null AND
	        l_cc_return_status=WSH_UTIL_CORE.G_RET_STS_WARNING AND
	        l_return_status=WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
           l_return_status:=l_cc_return_status;
         ELSE
           l_cc_return_status:=l_return_status;
         END IF;
        --}
       END LOOP;
       --
       l_return_status:=l_cc_return_status;
       --
       IF l_debug_on THEN
         wsh_debug_sv.log(l_module_name,'Total number of trips',x_delivery_out_rec.result_id_tab.COUNT);
       END IF;
       --}
     ELSE
      --{
      IF l_debug_on THEN
        wsh_debug_sv.logmsg(l_module_name, 'No constraints, calling GroupDelivsIntoTrips');
        wsh_debug_sv.log(l_module_name, 'Number of delivs', l_delivery_id_tab.COUNT);
      END IF;
      --
      l_delivGrpRec.deliv_IDTab := l_delivery_id_tab;
      l_delivGrpRec.max_Delivs  := p_action_prms.maxDelivs;
      --
      WSH_TRIP_CONSOLIDATION.GroupDelivsIntoTrips(
          p_delivGrpRec		=> l_delivGrpRec,
          x_delOutRec       	=> x_delivery_out_rec,
          x_return_status 	=> l_return_status);
      --
      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'Total number of trips',x_delivery_out_rec.result_id_tab.COUNT);
      END IF;
      --}
     END IF;
     --
     IF l_debug_on THEN
       wsh_debug_sv.log(l_module_name,'Return Status After GroupDelivsIntoTrips',l_return_status);
     END IF;
     --
     wsh_util_core.api_post_call(
          p_return_status    => l_return_status,
          x_num_warnings     => l_num_warnings,
          x_num_errors       => l_num_errors);
     --
    ELSIF p_action_prms.action_code = 'OUTBOUND-DOCUMENT' THEN
      --
      IF p_rec_attr_tab.COUNT > 1 THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_UI_MULTI_SELECTION');
        x_return_status := wsh_util_core.g_ret_sts_error;
        wsh_util_core.add_message(x_return_status,l_module_name);
        IF l_debug_on THEN
          wsh_debug_sv.log (l_module_name,'WSH_UI_MULTI_SELECTION');
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      --
      --Standalone changes
      -- LSP PROJECT :Populate local table if client info is there on dd.
      l_standalone_mode := WMS_DEPLOY.WMS_DEPLOYMENT_MODE;
      IF l_standalone_mode  = 'L' THEN
      --{
        OPEN  c_get_client(l_delivery_id_tab(1));
        FETCH c_get_client INTO l_client_id;
        CLOSE c_get_client;
      --}
      END IF;
      -- LSP PROJECT : end
      --
      IF ( (l_standalone_mode = 'D' OR (l_standalone_mode = 'L' AND l_client_id IS NOT NULL)) AND ( p_action_prms.caller = 'WSH_PUB' )) THEN
      --{
          IF l_debug_on THEN
            wsh_debug_sv.log (l_module_name,'Action_type is', 'A');
            wsh_debug_sv.log (l_module_name,'Document_type is', 'SA');
            wsh_debug_sv.log (l_module_name,'Organization_id is', p_rec_attr_tab(1).organization_id);
          END IF;

          WSH_TRANSACTIONS_UTIL.Send_Document(
            p_entity_id       => l_delivery_id_tab(1),
            p_entity_type     => 'DLVY',
            p_action_type     => 'A',
            p_document_type   => 'SA',
            p_organization_id => p_rec_attr_tab(1).organization_id,
            x_return_status   => l_return_status);

      --}
      ELSE
      --{
           WSH_TRANSACTIONS_UTIL.Send_Document(
             p_entity_id       => l_delivery_id_tab(1),
             p_entity_type     => 'DLVY',
             p_action_type     => p_action_prms.action_type,
             p_document_type   => p_action_prms.document_type ,
             p_organization_id => p_action_prms.organization_id,
             x_return_status   => l_return_status);
      --}
      END IF;
      --
      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'Return Status After Calling Send_Document',l_return_status);
      END IF;
      --
      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors);
      --
    ELSIF p_action_prms.action_code = 'SELECT-CARRIER' THEN
      --
      IF wsh_util_core.fte_is_installed = 'Y' THEN
        --
        IF p_rec_attr_tab.COUNT > 1 and p_action_prms.caller in('WSH_FSTRX', 'WSH_PUB') THEN
          FND_MESSAGE.SET_NAME('WSH','WSH_UI_MULTI_SELECTION');
          x_return_status := wsh_util_core.g_ret_sts_error;
          wsh_util_core.add_message(x_return_status,l_module_name);
          FND_MSG_PUB.ADD;
          IF l_debug_on THEN
            wsh_debug_sv.logmsg(l_module_name,'WSH_UI_MULTI_SELECTION');
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        --Bug 2657875
        -- l_form_flag := 'Y';

        IF  p_action_prms.form_flag = 'N' THEN
           l_form_flag := 'N';
        ELSE
           l_form_flag := 'Y';
        END IF;

        IF p_action_prms.ignore_ineligible_dels = 'Y' and
           l_num_warnings > 0 and l_valid_ids_tab.count > 0 THEN
           l_delivery_id_tab.delete;
           FOR i in l_valid_ids_tab.FIRST .. l_valid_ids_tab.LAST LOOP
              l_delivery_id_tab(l_delivery_id_tab.count+1) := l_valid_ids_tab(i);
           END LOOP;
        END IF;

        IF l_delivery_id_tab.count > 0 THEN
           WSH_NEW_DELIVERY_ACTIONS.process_carrier_selection(
             p_delivery_id_tab => l_delivery_id_tab,
             p_batch_id        => NULL,
             p_form_flag       => l_form_flag,
             p_caller          => p_action_prms.caller,
             x_return_message  => l_msg_data,
             x_return_status   => l_return_status);

           IF l_debug_on THEN
             wsh_debug_sv.log(l_module_name,'Return Status After Calling Process_Carrier_Selection',l_return_status);
           END IF;
           --
        ELSE
           l_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
        END IF;

        wsh_util_core.api_post_call(
          p_return_status    => l_return_status,
          x_num_warnings     => l_num_warnings,
          x_num_errors       => l_num_errors);


        --
      ELSE
        FND_MESSAGE.SET_NAME('FTE', 'FTE_NOT_INSTALLED');
        x_return_status := wsh_util_core.g_ret_sts_error;
        wsh_util_core.add_message(x_return_status,l_module_name);
        IF l_debug_on THEN
          wsh_debug_sv.logmsg(l_module_name,'FTE_NOT_INSTALLED');
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      --
    ELSIF p_action_prms.action_code = 'DELETE' THEN

      --OTM R12, prevent delete of delivery that's not empty and ignore for planning
      IF (l_gc3_is_installed = 'Y') THEN

        i := l_delivery_id_tab.FIRST;
        l_counter := 1;

        WHILE i IS NOT NULL LOOP

          --allow delete for all 'NS' deliveries
          IF (NVL(p_rec_attr_tab(i).tms_interface_flag, WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT)
              = WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT) THEN
            --generate allowed list of deliveries to be deleted
            l_new_delivery_id_tab(l_counter) := l_delivery_id_tab(i);
            l_counter := l_counter + 1;
          ELSE
            --add a message for the delivery that cannot be deleted.
            l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;

            IF l_debug_on THEN
              wsh_debug_sv.logmsg(l_module_name,'ERROR: delivery ' || l_delivery_id_tab(i) || ' cannot be deleted when it is not NS status');
            END IF;

            FND_MESSAGE.SET_NAME('WSH','WSH_OTM_DEL_DELETE_ERROR');
            FND_MESSAGE.SET_TOKEN('DEL_NAME',WSH_NEW_DELIVERIES_PVT.get_name(l_delivery_id_tab(i)));

            --we do not want the prefix error or warning for the message, so adding it with success
            --status will leave out the prefix.  Reason being this is an error message but could be
            --displayed as a warning if not all deliveries fail.
            WSH_UTIL_CORE.add_message(WSH_UTIL_CORE.G_RET_STS_SUCCESS, l_module_name);

            l_num_warnings := l_num_warnings + 1;

          END IF;
          i := l_delivery_id_tab.NEXT(i);
        END LOOP;

        IF (l_new_delivery_id_tab.COUNT = 0) THEN
          l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'0 deliveries to delete');
          END IF;

          wsh_util_core.api_post_call(
              p_return_status    => l_return_status,
              x_num_warnings     => l_num_warnings,
              x_num_errors       => l_num_errors);

        END IF;

        l_delivery_id_tab.DELETE;
        l_delivery_id_tab := l_new_delivery_id_tab;
      END IF;
      --END OTM R12

      WSH_UTIL_CORE.Delete(
        p_type          => 'DLVY',
        p_rows          => l_delivery_id_tab,
        x_return_status => l_return_status);
      --
      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'Return Status After Calling Delete',l_return_status);
      END IF;
      --
      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors);
      --
-- Bug 4493263: This generate-pack-slip action is not needed as it is
-- taken care a little down in the code line.
/*    ELSIF p_action_prms.action_code = 'GENERATE-PACK-SLIP' THEN
      --
      IF p_rec_attr_tab.COUNT > 1 THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_UI_MULTI_SELECTION');
        x_return_status := wsh_util_core.g_ret_sts_error;
        wsh_util_core.add_message(x_return_status,l_module_name);
        IF l_debug_on THEN
          wsh_debug_sv.log (l_module_name,'WSH_UI_MULTI_SELECTION');
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      --
      WSH_PACKING_SLIPS_PVT.Insert_Row(
        x_return_status       => l_return_status,
        x_msg_count           => l_msg_count,
        x_msg_data            => l_msg_data,
        p_entity_name         => 'WSH_NEW_DELIVERIES',
        p_entity_id           => l_delivery_id_tab(1),
        p_application_id      => 665  --FND_GLOBAL.RESP_APPL_ID
        p_location_id         => l_pickup_loc_id,
        p_document_type       => 'PACK_TYPE',
        p_document_sub_type   => 'SALES_ORDER',
        p_reason_of_transport => p_action_prms.reason_of_transport,
        p_description         => p_action_prms.description,
        x_document_number     => x_delivery_out_rec.packing_slip_number);
      --
      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'Return Status After Calling Insert_Row',l_return_status);
      END IF;
      --
      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors,
        p_msg_data     => l_msg_data);
      --
   */--Bug 4493263
    ELSIF p_action_prms.action_code IN ('PICK-RELEASE-UI','RESOLVE-EXCEPTIONS-UI','TRANSACTION-HISTORY-UI','FREIGHT-COSTS-UI')
          AND p_action_prms.caller = 'WSH_FSTRX' THEN
      --
      IF p_rec_attr_tab.COUNT > 1 THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_UI_MULTI_SELECTION');
        x_return_status := wsh_util_core.g_ret_sts_error;
        wsh_util_core.add_message(x_return_status,l_module_name);
        IF l_debug_on THEN
          wsh_debug_sv.log (l_module_name,'WSH_UI_MULTI_SELECTION');
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      --

    ELSIF p_action_prms.action_code = 'GENERATE-PACK-SLIP' THEN
      --
      --Bug 4493263
      i := p_rec_attr_tab.first;
      WHILE i IS NOT NULL LOOP
      --{
        -- initialize loop_num_warning, loop_num_error
        l_loop_num_warn := 0;
        l_loop_num_err  := 0;
        l_dlvy_doc_seq_num := null;

        OPEN c_dlvy_pack_slip_cur(p_rec_attr_tab(i).delivery_id);
        FETCH c_dlvy_pack_slip_cur INTO l_dlvy_doc_seq_num;
        CLOSE c_dlvy_pack_slip_cur;

        IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name, 'Delivery id', p_rec_attr_tab(i).delivery_id);
            wsh_debug_sv.log(l_module_name, 'Doc seq num', l_dlvy_doc_seq_num);
        END IF;

     /* IF p_rec_attr_tab.COUNT > 1 THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_UI_MULTI_SELECTION');
        x_return_status := wsh_util_core.g_ret_sts_error;
        wsh_util_core.add_message(x_return_status,l_module_name);
        IF l_debug_on THEN
          wsh_debug_sv.log (l_module_name,'WSH_UI_MULTI_SELECTION');
        END IF;
        RAISE FND_API.G_EXC_ERROR;
       END IF;*/

      --
        IF ( l_dlvy_doc_seq_num IS NULL ) THEN
        --{
          WSH_PACKING_SLIPS_PVT.Insert_Row(
            x_return_status       => l_return_status,
            x_msg_count           => l_msg_count,
            x_msg_data            => l_msg_data,
            p_entity_name         => 'WSH_NEW_DELIVERIES',
            p_entity_id           => p_rec_attr_tab(i).delivery_id,
            p_application_id      => 665 /* FND_GLOBAL.RESP_APPL_ID */,
            --Bug 6625788 For all Iteration Same l_pickup_loc_id is passed, so sending pickup_location_id for corresponding Delivery
           -- p_location_id         => l_pickup_loc_id,
            p_location_id         =>  p_rec_attr_tab(i).INITIAL_PICKUP_LOCATION_ID,
            p_document_type       => 'PACK_TYPE',
            p_document_sub_type   => 'SALES_ORDER',
            --Bug 6625788 For all Iteration Same Reason of Transport and Description is passed, so sending corresponding info for Each Delivery
            --p_reason_of_transport => p_action_prms.reason_of_transport,
            --p_description         => p_action_prms.description,
            p_reason_of_transport => p_rec_attr_tab(i).REASON_OF_TRANSPORT,
            p_description         => p_rec_attr_tab(i).DESCRIPTION,
            x_document_number     => x_delivery_out_rec.packing_slip_number);
            --
          IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'Return Status After Calling Insert_Row',l_return_status);
          END IF;
          --
          wsh_util_core.api_post_call(
            p_return_status    => l_return_status,
            x_num_warnings     => l_loop_num_warn,
            x_num_errors       => l_loop_num_err,
            p_msg_data         => l_msg_data);

        --}
        END IF;

        i := p_rec_attr_tab.next(i);
        l_num_warnings := l_num_warnings + l_loop_num_warn;
        l_num_errors   := l_num_errors   + l_loop_num_err;
        --
      --}
      END LOOP;

      --
      IF l_num_errors > 0 THEN
        IF l_num_errors  = p_rec_attr_tab.count THEN
           RAISE FND_API.G_EXC_ERROR;
        ELSE
           RAISE WSH_UTIL_CORE.G_EXC_WARNING;
        END IF;
      ELSIF l_num_warnings > 0 THEN
         RAISE WSH_UTIL_CORE.G_EXC_WARNING;
      END IF;
      --

    ELSIF p_action_prms.action_code IN ('PICK-RELEASE-UI','RESOLVE-EXCEPTIONS-UI','TRANSACTION-HISTORY-UI','FREIGHT-COSTS-UI')
          AND p_action_prms.caller = 'WSH_FSTRX' THEN
      --
      IF p_rec_attr_tab.COUNT > 1 THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_UI_MULTI_SELECTION');
        x_return_status := wsh_util_core.g_ret_sts_error;
        wsh_util_core.add_message(x_return_status,l_module_name);
        IF l_debug_on THEN
          wsh_debug_sv.log (l_module_name,'WSH_UI_MULTI_SELECTION');
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      --

    ELSIF p_action_prms.action_code = 'GET-FREIGHT-COSTS' THEN
       --

       IF wsh_util_core.fte_is_installed = 'Y' THEN
          --
          IF p_rec_attr_tab.COUNT > 1 and p_action_prms.caller in('WSH_FSTRX', 'WSH_PUB') THEN
            FND_MESSAGE.SET_NAME('WSH','WSH_UI_MULTI_SELECTION');
            x_return_status := wsh_util_core.g_ret_sts_error;
            wsh_util_core.add_message(x_return_status,l_module_name);
            FND_MSG_PUB.ADD;
            IF l_debug_on THEN
              wsh_debug_sv.logmsg(l_module_name,'WSH_UI_MULTI_SELECTION');
            END IF;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF p_action_prms.ignore_ineligible_dels = 'Y'  and
             l_num_warnings > 0 and l_valid_ids_tab.count > 0 THEN
             l_delivery_id_tab.delete;
             FOR i in l_valid_ids_tab.FIRST .. l_valid_ids_tab.LAST LOOP
                l_delivery_id_tab(l_delivery_id_tab.count+1) := l_valid_ids_tab(i);
             END LOOP;
          END IF;


          l_in_param_rec.delivery_id_list := l_delivery_id_tab;
          l_in_param_rec.action := 'RATE';
          IF p_action_prms.caller = 'WSH_DLMG' THEN -- R12 Select Carrier
             l_in_param_rec.seq_tender_flag := 'Y';
          END IF;

          WSH_FTE_INTEGRATION.Rate_Delivery(
               p_api_version      => 1.0,
               p_init_msg_list    => FND_API.G_FALSE,
               p_commit           => p_commit,
               p_in_param_rec     => l_in_param_rec,
               x_out_param_rec    => l_out_param_rec,
               x_return_status    => l_return_status,
               x_msg_count        => l_msg_count,
               x_msg_data         => l_msg_data);
             --
          IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'Return Status from WSH_FTE_INTEGRATION.Rate_Delivery' ,l_return_status);
          END IF;


         IF p_action_prms.caller = 'WSH_DLMG' AND
            l_return_status  in (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
            -- csun deliveryMerge , log exception

            i := l_out_param_rec.failed_delivery_id_list.FIRST;
            WHILE i is not NULL LOOP
               FND_MESSAGE.SET_NAME('WSH', 'WSH_RATE_DELIVERY_FAIL');
	       FND_MESSAGE.SET_TOKEN('DELIVERY_ID' , to_char(l_out_param_rec.failed_delivery_id_list(i)));
               l_exception_message := FND_MESSAGE.Get;
               l_exception_id := NULL;
               OPEN c_get_delivery_org(l_out_param_rec.failed_delivery_id_list(i));
               FETCH c_get_delivery_org INTO l_initial_pickup_location_id;
               IF c_get_delivery_org%NOTFOUND THEN
                 CLOSE c_get_delivery_org;
                 raise FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
               CLOSE c_get_delivery_org;
               wsh_xc_util.log_exception(
                  p_api_version           => 1.0,
                  x_return_status         => l_return_status,
                  x_msg_count             => l_msg_count,
                  x_msg_data              => l_msg_data,
                  x_exception_id          => l_exception_id,
                  p_exception_location_id => l_initial_pickup_location_id,
                  p_logged_at_location_id => l_initial_pickup_location_id,
                  p_logging_entity        => 'SHIPPER',
                  p_logging_entity_id     => FND_GLOBAL.USER_ID,
                  p_exception_name        => 'WSH_RATE_DELIVERY_FAIL',
                  p_message               => substrb(l_exception_message,1,2000),
                  p_delivery_id           => l_out_param_rec.failed_delivery_id_list(i));
            i := l_out_param_rec.failed_delivery_id_list.next(i);
            END LOOP;

            l_return_status :=  WSH_UTIL_CORE.G_RET_STS_WARNING;

         END IF;

          wsh_util_core.api_post_call(
             p_return_status    => l_return_status,
             x_num_warnings     => l_num_warnings,
             x_num_errors       => l_num_errors,
             p_msg_data         => l_msg_data);

       ELSE
          -- FTE is not installed
          FND_MESSAGE.SET_NAME('FTE', 'FTE_NOT_INSTALLED');
             x_return_status := wsh_util_core.g_ret_sts_error;
             wsh_util_core.add_message(x_return_status,l_module_name);
          IF l_debug_on THEN
             wsh_debug_sv.logmsg(l_module_name,'FTE_NOT_INSTALLED');
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;



    ELSIF p_action_prms.action_code = 'CANCEL-SHIP-METHOD' THEN

      WSH_FTE_INTEGRATION.Cancel_Service  (
        p_delivery_list  =>  l_delivery_id_tab,
        p_action         => 'CANCEL',
        p_commit         => p_commit,
        x_return_status  => l_return_status,
        x_msg_count      => l_msg_count,
        x_msg_data       => l_msg_data );


       IF l_debug_on THEN
          wsh_debug_sv.log(l_module_name,'Return Status After Cancel Ship Method',l_return_status);
       END IF;

       wsh_util_core.api_post_call(
         p_return_status    => l_return_status,
         x_num_warnings     => l_num_warnings,
         x_num_errors       => l_num_errors,
         p_msg_data         => l_msg_data);

    --deliveryMerge
    ELSIF p_action_prms.action_code = 'ADJUST-PLANNED-FLAG' THEN

       WSH_NEW_DELIVERY_ACTIONS.Adjust_Planned_Flag(
          p_delivery_ids          => l_delivery_id_tab,
          p_caller                => p_action_prms.caller,
          p_force_appending_limit => 'N',
          p_call_lcss             => 'Y',
          p_event                 => p_action_prms.event,
          x_return_status         => l_return_status);

       IF l_debug_on THEN
          wsh_debug_sv.log(l_module_name,'Return Status from WSH_NEW_DELIVERY_ACTIONS.Adjust_Planned_Flag',l_return_status);
       END IF;

       wsh_util_core.api_post_call(
         p_return_status    => l_return_status,
         x_num_warnings     => l_num_warnings,
         x_num_errors       => l_num_errors,
         p_msg_data         => l_msg_data);

    ELSIF p_action_prms.action_code = 'PRINT-PACK-SLIP' THEN
    --{ begin print pack slip

      i := p_rec_attr_tab.first;
      WHILE i IS NOT NULL LOOP
      --{
         -- initialize loop_num_warning, loop_num_error
         l_loop_num_warn := 0;
         l_loop_num_err  := 0;

         OPEN c_dlvy_pack_slip_cur(p_rec_attr_tab(i).delivery_id);
         FETCH c_dlvy_pack_slip_cur INTO l_dlvy_doc_seq_num;
         CLOSE c_dlvy_pack_slip_cur;

        if l_debug_on then
          wsh_debug_sv.log(l_module_name, 'Doc seq num', l_dlvy_doc_seq_num);
        end if;
        IF l_dlvy_doc_seq_num IS NULL THEN
         --{
         --Pack slip does not exist. Call Group API for action Generate Pack Slip
          l_action_prms := p_action_prms;
          l_action_prms.action_code := 'GENERATE-PACK-SLIP';
          l_rec_attr_tab.delete;
          l_rec_attr_tab(1) := p_rec_attr_tab(i);

        wsh_deliveries_grp.delivery_action(
          p_api_version_number     =>  p_api_version_number,
          p_init_msg_list          =>  FND_API.G_FALSE,
          p_commit                 =>  FND_API.G_FALSE,
          p_action_prms            =>  l_action_prms,
          p_rec_attr_tab           =>  l_rec_attr_tab,
          x_delivery_out_rec       =>  x_delivery_out_rec,
          x_defaults_rec           =>  x_defaults_rec,
          x_return_status          =>  l_return_status,
          x_msg_count              =>  l_msg_count,
          x_msg_data               =>  l_msg_data);

        -- Set raise error flag to false ,continue with next delivery in the loop
        -- after end of loop, check for l_num_errors
        wsh_util_core.api_post_call(
          p_return_status    => l_return_status,
          x_num_warnings     => l_loop_num_warn,
          x_num_errors       => l_loop_num_err,
          p_msg_data         => l_msg_data,
          p_raise_error_flag => FALSE);

        --}
        END IF;
        --Bug 4493263
        l_num_warnings := l_num_warnings + l_loop_num_warn;
        l_num_errors := l_num_errors + l_loop_num_err;

        IF ( l_loop_num_err = 0 ) THEN
            l_doc_delivery_id_tab(l_doc_delivery_id_tab.COUNT+1) := p_rec_attr_tab(i).delivery_id;
            l_doc_valid_ids_tab(l_doc_valid_ids_tab.COUNT+1) := i;
        END IF;

        i := p_rec_attr_tab.next(i);
      --}
      END LOOP;

      -- Bug 4493263
      -- Records in STF are refreshed based on this x_delivery_out_rec.valid_ids_tab count if
      -- multi-records are selected in STF while calling this API with action 'PRINT-PACK-SLIP'
      -- Prior to this fix, x_delivery_out_rec.valid_ids_tab will always have 1 record, if
      -- records selected from STF doesn't have packing slip number.
      x_delivery_out_rec.valid_ids_tab := l_doc_valid_ids_tab;

      OPEN  c_pack_slip_doc_set;
      FETCH c_pack_slip_doc_set into l_doc_set_id;
      CLOSE c_pack_slip_doc_set;

      IF ( l_doc_set_id IS NOT NULL AND
           l_doc_delivery_id_tab.COUNT > 0 )
      THEN
         -- initialize loop_num_warning, loop_num_error
         l_loop_num_warn := 0;
         l_loop_num_err  := 0;

         WSH_DOCUMENT_SETS.Print_Document_Sets(
                      p_report_set_id       => l_doc_set_id,
                      p_organization_id     => p_action_prms.organization_id,
                      p_trip_ids            => l_dummy_id_tab,
                      p_stop_ids            => l_dummy_id_tab,
                      p_delivery_ids        => l_doc_delivery_id_tab,
                      p_document_param_info => l_dummy_doc_set_params,
                      x_return_status       => l_return_status);

         wsh_util_core.api_post_call(
                  p_return_status    => l_return_status,
                  x_num_warnings     => l_loop_num_warn,
                  x_num_errors       => l_loop_num_err,
                  p_msg_data         => l_msg_data,
                  p_raise_error_flag => FALSE );


         l_num_warnings := l_num_warnings + l_loop_num_warn;
         l_num_errors := l_num_errors + l_loop_num_err;
      END IF;

      IF l_num_errors > 0 THEN
        IF l_num_errors  = p_rec_attr_tab.count THEN
           RAISE FND_API.G_EXC_ERROR;
        ELSE
           RAISE WSH_UTIL_CORE.G_EXC_WARNING;
        END IF;
      ELSIF l_num_warnings > 0 THEN
         RAISE WSH_UTIL_CORE.G_EXC_WARNING;
      END IF;

    --} end print pack slip
--  Bug 4493263 : added action 'GENERATE-BOL'
    ELSIF p_action_prms.action_code in ( 'GENERATE-BOL', 'PRINT-BOL' ) THEN
    --{ begin print bol

      i := p_rec_attr_tab.first;

      <<dlvy_loop>>
      WHILE i IS NOT NULL
      LOOP
      --{ loop for delivery
       l_child_deliveries_tab.delete;
       OPEN c_child_deliveries(p_rec_attr_tab(i).delivery_id);
       FETCH c_child_deliveries BULK COLLECT INTO l_child_deliveries_tab;
       CLOSE c_child_deliveries;

       IF l_child_deliveries_tab.count =  0 THEN
          l_child_deliveries_tab(1) := p_rec_attr_tab(i).delivery_id;
       END IF;

       -- { child deliveries loop
       FOR child in 1 .. l_child_deliveries_tab.count LOOP
           <<leg_loop>>
           FOR dlvy_leg_rec IN c_dlvy_leg_cur(l_child_deliveries_tab(child))
           LOOP
           --{ loop for dleg
             -- initialize loop_num_warning, loop_num_error
             -- Need to address this later... We have two loops, one for delivery, another for delivery legs
             -- How should warnings, errors be tracked for cases where a single delivery has many legs
             l_loop_num_warn := 0;
             l_loop_num_err  := 0;

            -- Bug 3311273
             -- Flag to indicate there is atleast one delivery leg for the delivery
             l_dleg_found := 'Y';
             -- Validate if ship method exists or not
             IF dlvy_leg_rec.ship_method IS NULL THEN

               --l_num_errors   := l_num_errors + l_loop_num_err;
               l_num_errors   := l_num_errors + 1;
               FND_MESSAGE.SET_NAME('WSH','WSH_BOL_NULL_SHIP_METHOD_ERROR');
               FND_MESSAGE.SET_TOKEN('TRIP_NAME',wsh_trips_pvt.get_name(dlvy_leg_rec.trip_id));
               l_return_status := wsh_util_core.g_ret_sts_error;
               wsh_util_core.add_message(l_return_status,l_module_name);
               IF l_debug_on THEN
                 wsh_debug_sv.log (l_module_name,'No Ship Method for the trip'||dlvy_leg_rec.trip_id);
               END IF;
               exit leg_loop;
             END IF;
-- End of Bug 3311273

             IF l_debug_on THEN
                wsh_debug_sv.log(l_module_name, 'Processing delivery leg', dlvy_leg_rec.delivery_leg_id);
             END IF;

             l_dleg_tab.delete;
             wsh_delivery_legs_pvt.populate_record(
                  p_delivery_leg_id => NVL(dlvy_leg_rec.parent_delivery_leg_id, dlvy_leg_rec.delivery_leg_id),
                  x_delivery_leg_info => l_dleg_tab(1),
                  x_return_status    => l_return_status);

             wsh_util_core.api_post_call(
                p_return_status    => l_return_status,
                x_num_warnings     => l_loop_num_warn,
                x_num_errors       => l_loop_num_err,
                p_raise_error_flag => FALSE);

              -- if there is an error for current delivery leg,
              -- need to skip this and proceed with next leg
              -- l_num_error count will be checked towards the end
              if l_return_status in (wsh_util_core.g_ret_sts_error,
                                 wsh_util_core.g_ret_sts_unexp_error) then
                l_num_warnings := l_num_warnings + l_loop_num_warn;
                l_num_errors   := l_num_errors + l_loop_num_err;
                 exit leg_loop;
              end if;

             l_dleg_prms.caller := p_action_prms.caller;
             l_dleg_prms.action_code := p_action_prms.action_code;
             l_dleg_prms.phase := p_action_prms.phase;
             l_dleg_prms.p_Pick_Up_Location_Id := dlvy_leg_rec.pick_Up_Location_Id;
             l_dleg_prms.p_Ship_Method := dlvy_leg_rec.Ship_Method;
             l_dleg_prms.p_Drop_Off_Location_Id := dlvy_leg_rec.Drop_Off_Location_Id;
             l_dleg_prms.p_Carrier_Id := dlvy_leg_rec.Carrier_Id;

             l_dleg_action_out_rec.x_trip_id := dlvy_leg_rec.trip_id;
             l_dleg_action_out_rec.x_trip_name := dlvy_leg_rec.trip_name;
             l_dleg_action_out_rec.x_delivery_id := l_child_deliveries_tab(child);
             l_dleg_action_out_rec.result_id_tab.delete;

             wsh_delivery_legs_grp.Delivery_Leg_Action(
                p_api_version_number  => 1.0,
                p_init_msg_list       => FND_API.G_FALSE,
                p_commit              => FND_API.G_FALSE,
                p_rec_attr_tab        => l_dleg_tab,
                p_action_prms         => l_dleg_prms,
                x_action_out_rec      => l_dleg_action_out_rec,
                x_return_status       => l_return_status,
                x_msg_count           => l_msg_count,
                x_msg_data            => l_msg_data);


              IF l_dleg_action_out_rec.result_id_tab.count > 0 THEN
                  l_request_id := l_dleg_action_out_rec.result_id_tab(l_dleg_action_out_rec.result_id_tab.first);
                  x_delivery_out_rec.result_id_tab(x_delivery_out_rec.result_id_tab.count +1) := l_request_id;
              END IF;

           -- increase the counter if successful
           IF l_request_id > 0 THEN --{

               l_submitted_docs := l_submitted_docs + 1;

               IF l_submitted_docs = 1 THEN --{
                  l_req_id_str := to_char(l_request_id);
               ELSE
                  l_req_id_str := l_req_id_str || ', ' || to_char(l_request_id);
               END IF; --}

           END IF;


           -- Set raise error flag to FALSE so that the loop can continue
           -- with other legs or deliveries
           -- After end of loop, checks for l_num_warning, l_num_errors should set the final return_status

           wsh_util_core.api_post_call(
             p_return_status    => l_return_status,
             x_num_warnings     => l_loop_num_warn,
             x_num_errors       => l_loop_num_err,
             p_msg_data         => l_msg_data,
             p_raise_error_flag => FALSE);

            l_num_warnings := l_num_warnings + l_loop_num_warn;
            l_num_errors   := l_num_errors + l_loop_num_err;
            --} loop for dleg
            END LOOP leg_loop;

        END LOOP; --} child deliveries loop

-- Bug 3311273
        -- If no leg exist for this Delivery,there should be a ERROR/WARNING message here
        -- Indicates there is no associated trip for the delivery
        IF l_dleg_found = 'N' THEN
          FND_MESSAGE.SET_NAME('WSH','WSH_BOL_NO_TRIP_FOR_DLVY');
          FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_rec_attr_tab(i).delivery_id));
          l_num_errors   := l_num_errors + 1;
          l_return_status := wsh_util_core.g_ret_sts_error;
          wsh_util_core.add_message(l_return_status,l_module_name);
          IF l_debug_on THEN
            wsh_debug_sv.log (l_module_name,'WSH_NO_DELIVERY_LEG_FOUND');
          END IF;
        END IF;
-- End of Bug 3311273

        i := p_rec_attr_tab.next(i);
      --} loop for delivery
      END LOOP dlvy_loop;

      IF l_debug_on THEN
         wsh_debug_sv.log(l_module_name, 'result id tab count', x_delivery_out_rec.result_id_tab.count);
      END IF;

      IF l_submitted_docs > 0 THEN
         fnd_message.set_name('WSH', 'WSH_PRINT_BOL_REQUEST');
         fnd_message.set_token('REQ_IDS', l_req_id_str);
         wsh_util_core.add_message(wsh_util_core.g_ret_sts_success);
      END IF;

      IF l_num_errors > 0 THEN
-- 3311273
        FND_MESSAGE.SET_NAME('WSH','WSH_BOL_SUMMARY_MESG');
        FND_MESSAGE.SET_TOKEN('ERROR_COUNT',l_num_errors );
        FND_MESSAGE.SET_TOKEN('SUCC_COUNT',p_rec_attr_tab.count - l_num_errors );
        l_return_status := wsh_util_core.g_ret_sts_error;
        wsh_util_core.add_message(l_return_status,l_module_name);
        IF l_debug_on THEN
          wsh_debug_sv.log (l_module_name,'Error processing deliveries-'||l_num_errors);
        END IF;
-- End of 3311273
        IF l_num_errors  = p_rec_attr_tab.count THEN
           RAISE FND_API.G_EXC_ERROR;
        ELSE
          RAISE WSH_UTIL_CORE.G_EXC_WARNING;
        END IF;
      ELSIF l_num_warnings > 0 THEN
         RAISE WSH_UTIL_CORE.G_EXC_WARNING;
      END IF;

    --} end print bol
   ELSE
      --
      FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_ACTION_CODE');
      FND_MESSAGE.SET_TOKEN('ACT_CODE',p_action_prms.action_code );
      x_return_status := wsh_util_core.g_ret_sts_error;
      wsh_util_core.add_message(x_return_status,l_module_name);
      IF l_debug_on THEN
         wsh_debug_sv.log (l_module_name,'WSH_INVALID_ACTION_CODE');
      END IF;
      RAISE FND_API.G_EXC_ERROR;
      --
    END IF;
    --
    IF l_debug_on THEN
       wsh_debug_sv.log(l_module_name, 'l_num_errors', l_num_errors);
       wsh_debug_sv.log(l_module_name, 'l_num_warnings', l_num_warnings);
    END IF;


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
       IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,  'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS', l_return_status);
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
   -- K LPN CONV. rv
   --

        --Call to DCP
        --If profile is turned on.
   BEGIN
   --{
       IF l_debug_on THEN
          wsh_debug_sv.log(l_module_name, 'l_check_dcp', l_check_dcp);
          wsh_debug_sv.log(l_module_name, 'g_call_dcp_check', WSH_DCP_PVT.G_CALL_DCP_CHECK);
       END IF;

       IF NVL(l_check_dcp, -99) IN (1,2)
       AND NVL(WSH_DCP_PVT.G_CALL_DCP_CHECK, 'Y') = 'Y'
       THEN
       --{
          IF p_action_prms.action_code IN ('AUTO-PACK', 'CONFIRM') THEN

             IF l_debug_on THEN
                WSH_DEBUG_SV.LOGMSG(L_MODULE_NAME, 'CALLING DCP ');
             END IF;

             wsh_dcp_pvt.check_delivery(
                     p_action_code => p_action_prms.action_code,
                     p_dlvy_table  => p_rec_attr_tab);
          END IF;
       --}
       END IF;

    EXCEPTION
      WHEN wsh_dcp_pvt.data_inconsistency_exception THEN
       if NOT l_debug_on OR l_debug_on is null then
          l_debug_on := wsh_debug_sv.is_debug_enabled;
       end if;
       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'data_inconsistency_exception');
       END IF;
       ROLLBACK TO DELIVERY_ACTION_GRP;
       GOTO api_start;
      WHEN OTHERS THEN
       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'When Others');
       END IF;
        null;
    --}
    END;


    IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,  'Return status ', l_return_status);
           WSH_DEBUG_SV.log(l_module_name,  'l_num_warnings', l_num_warnings);
           WSH_DEBUG_SV.log(l_module_name,  'l_num_warnings', l_num_warnings);
    END IF;


    IF l_num_warnings > 0 THEN
    IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,  'l_num_warnings', l_num_warnings);
    END IF;
        RAISE WSH_UTIL_CORE.G_EXC_WARNING;
    ELSE
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    END IF;
    --
    IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,  'Return status ', l_return_status);
           WSH_DEBUG_SV.log(l_module_name,  'l_num_warnings', l_num_warnings);
           WSH_DEBUG_SV.log(l_module_name,  'l_num_warnings', l_num_warnings);
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

        --}
        END IF;
    --}
    END IF;

    --bug 4070732
    --
    IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,  'before calling FND_MSG_PUB.Count_And_Get', l_num_warnings);
    END IF;
    FND_MSG_PUB.Count_And_Get
      (
       p_count  => x_msg_count,
       p_data  =>  x_msg_data,
       p_encoded => FND_API.G_FALSE
      );
    --
    IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,  'FND_MSG_PUB.Count_And_Get, count: ', x_msg_count);
    END IF;
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      -- ROLLBACK TO DELIVERY_ACTION_GRP;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

      --OTM R12
      IF (c_get_delivery_id%ISOPEN) THEN
        CLOSE c_get_delivery_id;
      END IF;
      --

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
          IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,  'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS', l_return_status);
          END IF;
          --
          IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
          END IF;
      --}
      END IF;
      -- K LPN CONV. rv
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
      --
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
      -- ROLLBACK TO DELIVERY_ACTION_GRP;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;

      --OTM R12
      IF (c_get_delivery_id%ISOPEN) THEN
        CLOSE c_get_delivery_id;
      END IF;
      --

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
          IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,  'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS', l_return_status);
          END IF;
          --
      --}
      END IF;
      -- K LPN CONV. rv
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
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN

      --OTM R12
      IF (c_get_delivery_id%ISOPEN) THEN
        CLOSE c_get_delivery_id;
      END IF;
      --

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,' Raising: WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
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
          IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,  'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS', l_return_status);
          END IF;
          --
          IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
            x_return_status := l_return_status;
          END IF;
      --}
      END IF;
      -- K LPN CONV. rv
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

          --}
          END IF;
      --}
      END IF;
      --
      -- End of Code Bugfix 4070732
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,' calling: FND_MSG_PUB.Count_And_Get');
      END IF;
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

      --OTM R12
      IF (c_get_delivery_id%ISOPEN) THEN
        CLOSE c_get_delivery_id;
      END IF;
      --

      -- ROLLBACK TO DELIVERY_ACTION_GRP;
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
          IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,  'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS', l_return_status);
          END IF;
          --
      --}
      END IF;
      -- K LPN CONV. rv
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_DELIVERIES_GRP.DELIVERY_ACTION');

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
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
  END Delivery_Action;

-- I Harmonization: rvishnuv ******* Actions ******

-- I Harmonization: rvishnuv ******* Create/Update ******
--Bug 5191354: For the action UPDATE, validating the delivery attributes only when the corresponding
--             input parameter contains some value (other then fnd_api.g_miss_num/fnd_api.g_miss_char/fnd_api.g_miss_date).
  PROCEDURE Validate_Delivery
           (x_rec_attr_tab    IN OUT NOCOPY WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type,
            p_in_rec_attr_tab IN   WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type,  --Bug 5191354
            p_action_code     IN     VARCHAR2,
            p_caller          IN     VARCHAR2,
            x_valid_index_tab OUT    NOCOPY wsh_util_core.id_tab_type,
            x_return_status   OUT    NOCOPY VARCHAR2)
  IS
  --

  -- heali for bug 2771579
    CURSOR c_get_org_location(p_org_id NUMBER) IS
    select      location_id
    from        hr_organization_units
    where       organization_id = p_org_id;

  l_org_location_id  NUMBER;
  -- heali for bug 2771579

  l_net_weight           WSH_NEW_DELIVERIES.NET_WEIGHT%TYPE;
  l_gross_weight         WSH_NEW_DELIVERIES.GROSS_WEIGHT%TYPE;
  l_volume               WSH_NEW_DELIVERIES.VOLUME%TYPE;
  l_volume_uom_code      WSH_NEW_DELIVERIES.VOLUME_UOM_CODE%TYPE;
  l_weight_uom_code      WSH_NEW_DELIVERIES.WEIGHT_UOM_CODE%TYPE;
  l_initial_pickup_location_id  WSH_NEW_DELIVERIES.initial_pickup_location_id%TYPE;
  --


  l_assigned_to_trip     VARCHAR2(1);
  l_return_status        VARCHAR2(1);
  l_num_errors           NUMBER;
  l_num_warnings         NUMBER;
  l_index                NUMBER;
  l_dummy_meaning        VARCHAR2(240);
  l_vol_nullify_flag     BOOLEAN := FALSE;
  l_wt_nullify_flag      BOOLEAN := FALSE;
  l_isWshLocation        BOOLEAN DEFAULT FALSE;
  --
l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_DELIVERY';
  --
  l_shipping_control     VARCHAR2(30);
  l_routing_response_id  NUMBER;
  l_routing_request_flag VARCHAR2(30);

  --OTM R12
  l_adjusted_amount      NUMBER;
  --
  l_client_name          VARCHAR2(200);   -- LSP PROJECT

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

    SAVEPOINT VALIDATE_DELIVERY_GRP;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        WSH_DEBUG_SV.log(l_module_name,'p_action_code',p_action_code);
        WSH_DEBUG_SV.log(l_module_name,'Number of Delivery Records is', x_rec_attr_tab.COUNT);
    END IF;
    --

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    --OTM R12
    l_adjusted_amount := 0;
    --

    --
    IF p_caller IN ( 'WSH_FSTRX' , 'WSH_TPW_INBOUND')
    OR p_caller LIKE 'FTE%' THEN
       l_isWshLocation := TRUE;
    END IF;

    l_index := x_rec_attr_tab.FIRST;
    WHILE l_index is not null LOOP
      BEGIN
        SAVEPOINT VALIDATE_DLVY_GRP_LOOP;

        --Bug 5191354
        IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_DELIVERY_NAME_LVL) = 1
        AND (p_action_code = 'CREATE' OR
                 (p_action_code = 'UPDATE' AND
                   ((p_in_rec_attr_tab(l_index).delivery_id IS NULL ) OR (p_in_rec_attr_tab(l_index).delivery_id <> fnd_api.g_miss_num)
                     OR (p_in_rec_attr_tab(l_index).name IS NULL ) OR (p_in_rec_attr_tab(l_index).name <> fnd_api.g_miss_char)
                   ))) THEN
          --
          wsh_util_validate.validate_delivery_name(
            p_delivery_id       => x_rec_attr_tab(l_index).delivery_id,
            p_delivery_name     => x_rec_attr_tab(l_index).name,
            x_return_status     => l_return_status);
          --
            IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_delivery_name',l_return_status);
          END IF;
          --
          WSH_UTIL_CORE.api_post_call(
            p_return_status     => l_return_status,
            x_num_warnings      => l_num_warnings,
            x_num_errors        => l_num_errors);
          --
        END IF;
        --
        IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_ORGANIZATION_LVL) = 1 THEN
          --Bug 5191354
          IF p_action_code = 'CREATE'
          AND nvl(x_rec_attr_tab(l_index).organization_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM
          AND nvl(x_rec_attr_tab(l_index).organization_code,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR
          THEN
            x_return_status := wsh_util_core.g_ret_sts_error;
            WSH_UTIL_CORE.api_post_call(p_return_status    => x_return_status,
                                x_num_warnings     =>l_num_warnings,
                                x_num_errors       =>l_num_errors,
                                p_module_name      =>l_module_name,
                                p_msg_data         => 'WSH_DEL_ORG_NULL');

          ELSIF (p_action_code = 'CREATE' OR
                 (p_action_code = 'UPDATE' AND
                   ((p_in_rec_attr_tab(l_index).organization_id IS NULL ) OR (p_in_rec_attr_tab(l_index).organization_id <> fnd_api.g_miss_num)
                     OR (p_in_rec_attr_tab(l_index).organization_code IS NULL ) OR (p_in_rec_attr_tab(l_index).organization_code <> fnd_api.g_miss_char)
                   ))) THEN
          --{

            IF ( p_action_code = 'UPDATE'
                AND x_rec_attr_tab(l_index).organization_id IS NULL
                AND x_rec_attr_tab(l_index).organization_code IS NULL) THEN
            --{ NULL case
              x_return_status := wsh_util_core.g_ret_sts_error;
              WSH_UTIL_CORE.api_post_call(p_return_status    => x_return_status,
                                x_num_warnings     =>l_num_warnings,
                                x_num_errors       =>l_num_errors,
                                p_module_name      =>l_module_name,
                                p_msg_data         => 'WSH_DEL_ORG_NULL');

            --} NULL case
            END IF;
            wsh_util_validate.validate_org(
              p_org_id            => x_rec_attr_tab(l_index).organization_id,
              p_org_code          => x_rec_attr_tab(l_index).organization_code,
              x_return_status     => l_return_status);
            --
            IF l_debug_on THEN
              wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_org',l_return_status);
            END IF;
            --
            WSH_UTIL_CORE.api_post_call(
              p_return_status     => l_return_status,
              x_num_warnings      => l_num_warnings,
              x_num_errors        => l_num_errors);
            --
          END IF;
          --
        END IF;
        --
        IF (nvl(x_rec_attr_tab(l_index).delivery_type,'STANDARD') NOT IN ('STANDARD','CONSOLIDATION')) THEN
          x_rec_attr_tab(l_index).delivery_type := 'STANDARD';
        END IF;
        --Bug 5191354
        IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_LOADING_ORDER_LVL) = 1
           AND (p_action_code = 'CREATE' OR
                 (p_action_code = 'UPDATE' AND
                   ((p_in_rec_attr_tab(l_index).loading_order_flag IS NULL ) OR (p_in_rec_attr_tab(l_index).loading_order_flag <> fnd_api.g_miss_char)
                     OR (p_in_rec_attr_tab(l_index).loading_order_desc IS NULL ) OR (p_in_rec_attr_tab(l_index).loading_order_desc <> fnd_api.g_miss_char)
                   ))) THEN
          --
          wsh_util_validate.validate_loading_order(
            p_loading_order_flag => x_rec_attr_tab(l_index).loading_order_flag,
            p_loading_order_desc => x_rec_attr_tab(l_index).loading_order_desc,
            x_return_status      => l_return_status);
          --
          IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_loading_order',l_return_status);
          END IF;
          --
          WSH_UTIL_CORE.api_post_call(
            p_return_status     => l_return_status,
            x_num_warnings      => l_num_warnings,
            x_num_errors        => l_num_errors);
          --
        END IF;
        --
        IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_SHIP_FROM_LOC_LVL) = 1
        THEN
          --
          IF p_action_code = 'CREATE'
          AND nvl(x_rec_attr_tab(l_index).initial_pickup_location_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM
          AND nvl(x_rec_attr_tab(l_index).initial_pickup_location_code,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR
          THEN
            x_return_status := wsh_util_core.g_ret_sts_error;
            WSH_UTIL_CORE.api_post_call(p_return_status    => x_return_status,
                                x_num_warnings     =>l_num_warnings,
                                x_num_errors       =>l_num_errors,
                                p_module_name      =>l_module_name,
                                p_msg_data         => 'WSH_DEL_PICKUP_LOC_NULL');
          --Bug 5191354
          ELSIF (p_action_code = 'CREATE' OR
                 (p_action_code = 'UPDATE' AND
                   ((p_in_rec_attr_tab(l_index).initial_pickup_location_id IS NULL ) OR (p_in_rec_attr_tab(l_index).initial_pickup_location_id <> fnd_api.g_miss_num)
                       OR (p_in_rec_attr_tab(l_index).initial_pickup_location_code IS NULL ) OR (p_in_rec_attr_tab(l_index).initial_pickup_location_code <> fnd_api.g_miss_char)
                   ))) THEN
          --{

            IF (p_action_code = 'UPDATE'
                AND x_rec_attr_tab(l_index).initial_pickup_location_id IS NULL
                AND x_rec_attr_tab(l_index).initial_pickup_location_code IS NULL) THEN
            --{ NULL case
               x_return_status := wsh_util_core.g_ret_sts_error;
               WSH_UTIL_CORE.api_post_call(p_return_status    => x_return_status,
                                x_num_warnings     =>l_num_warnings,
                                x_num_errors       =>l_num_errors,
                                p_module_name      =>l_module_name,
                                p_msg_data         => 'WSH_DEL_PICKUP_LOC_NULL');


            --} NULL case
            END IF;

            -- J-IB-NPARIKH-{
            --
            IF  NVL(x_rec_attr_tab(l_index).shipment_direction,'O') NOT IN ('O','IO')
            --AND x_rec_attr_tab(l_index).initial_pickup_location_id  = WSH_UTIL_CORE.C_NULL_SF_LOCN_ID
            THEN
            --{
                --
                -- Check if delivery's transportation is arranged by supplier
                -- or if routing request was not received for all delivery lines
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_VALIDATIONS.GET_SHIPPING_CONTROL',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                WSH_DELIVERY_VALIDATIONS.GET_SHIPPING_CONTROL
                (
                    p_delivery_id           => x_rec_attr_tab(l_index).delivery_id,
                    x_shipping_control      => l_shipping_control,
                    x_routing_response_id   => l_routing_response_id,
                    x_routing_request_flag  => l_routing_request_flag,
                    x_return_status         => l_return_status
                );
                --
                --
                IF l_debug_on THEN
                    wsh_debug_sv.log(l_module_name, 'l_return_status', l_return_status);
                    wsh_debug_sv.log(l_module_name, 'l_shipping_control', l_shipping_control);
                    wsh_debug_sv.log(l_module_name, 'l_routing_response_id', l_routing_response_id);
                    wsh_debug_sv.log(l_module_name, 'l_routing_request_flag', l_routing_request_flag);
                    --
                END IF;
                --
                --
                WSH_UTIL_CORE.api_post_call(
                  p_return_status     => l_return_status,
                  x_num_warnings      => l_num_warnings,
                  x_num_errors        => l_num_errors);
            --}
            END IF;
            --
            -- J-IB-NPARIKH-}
            --
            IF NVL(x_rec_attr_tab(l_index).shipment_direction,'O') IN ('O','IO')   -- J-IB-NPARIKH
            OR x_rec_attr_tab(l_index).initial_pickup_location_id  <> WSH_UTIL_CORE.C_NULL_SF_LOCN_ID   -- J-IB-NPARIKH
            --OR l_shipping_control                                  <> 'SUPPLIER'   -- J-IB-NPARIKH
            --OR l_routing_request_flag                              <> 'N'          -- J-IB-NPARIKH
            THEN
                wsh_util_validate.validate_location(
                  p_location_id   => x_rec_attr_tab(l_index).initial_pickup_location_id,
                  p_location_code => x_rec_attr_tab(l_index).initial_pickup_location_code,
                  x_return_status => l_return_status,
                  p_isWshLocation => l_isWshLocation);
                --
                IF l_debug_on THEN
                  wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_location for Ship From',l_return_status);
                END IF;
                --
                WSH_UTIL_CORE.api_post_call(
                  p_return_status     => l_return_status,
                  x_num_warnings      => l_num_warnings,
                  x_num_errors        => l_num_errors);
                --
                --
                -- J-IB-NPARIKH-{
                IF l_shipping_control     = 'SUPPLIER'
                OR l_routing_request_flag = 'N'
                THEN
                --{
                    --
                    -- Check if delivery's transportation is arranged by supplier
                    -- or if routing request was not received for all delivery lines
                    -- If that's the case, validate that ship-from location is
                    -- a valid ship-from for the supplier
                    --
                    IF NVL(x_rec_attr_tab(l_index).shipment_direction,'O')
                       NOT IN ('O','IO')   -- J-IB-NPARIKH
                    THEN
                    --{
                    wsh_util_validate.validate_supplier_location
                        (
                            p_vendor_id     => x_rec_attr_tab(l_index).vendor_id,
                            p_party_id      => x_rec_attr_tab(l_index).party_id,
                            p_location_id   => x_rec_attr_tab(l_index).initial_pickup_location_id,
                            x_return_status => l_return_status
                        );
                    --
                    IF l_debug_on THEN
                      wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_supplier_location for Ship From',l_return_status);
                    END IF;
                    --
                    WSH_UTIL_CORE.api_post_call(
                      p_return_status     => l_return_status,
                      x_num_warnings      => l_num_warnings,
                      x_num_errors        => l_num_errors);
                    --}
                    END IF;
                --}
                END IF;
                -- J-IB-NPARIKH-}

            END IF;

            IF NVL(x_rec_attr_tab(l_index).shipment_direction,'O') IN ('O','IO')   -- J-IB-NPARIKH
            THEN
                -- Validation that ship-from organization corresponds to initial pickup
                -- location is applicable only for outbound (O/IO) delivery.
                --
                -- heali for bug 2771579
                OPEN c_get_org_location(x_rec_attr_tab(l_index).organization_id);
                FETCH c_get_org_location INTO l_org_location_id;
                CLOSE c_get_org_location;

                IF l_debug_on THEN
                  wsh_debug_sv.log(l_module_name,'organization_id',x_rec_attr_tab(l_index).initial_pickup_location_id);
                  wsh_debug_sv.log(l_module_name,'l_org_location_id',l_org_location_id);
                END IF;

                IF (l_org_location_id <> x_rec_attr_tab(l_index).initial_pickup_location_id) THEN
                   x_return_status := wsh_util_core.g_ret_sts_error;
                   WSH_UTIL_CORE.api_post_call(p_return_status    => x_return_status,
                                    x_num_warnings     =>l_num_warnings,
                                    x_num_errors       =>l_num_errors,
                                    p_module_name      =>l_module_name,
                                    p_msg_data         => 'WSH_DEL_PICK_LOC_NOT_MATCH');

                END IF;
                -- heali for bug 2771579
            END IF;

          END IF;
          --
        END IF;
          --
        IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_SHIP_TO_LOC_LVL) = 1 THEN
          --
          IF p_action_code = 'CREATE'
          AND nvl(x_rec_attr_tab(l_index).ultimate_dropoff_location_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM
          AND nvl(x_rec_attr_tab(l_index).ultimate_dropoff_location_code,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR
          THEN
            x_return_status := wsh_util_core.g_ret_sts_error;
            WSH_UTIL_CORE.api_post_call(p_return_status    => x_return_status,
                                x_num_warnings     =>l_num_warnings,
                                x_num_errors       =>l_num_errors,
                                p_module_name      =>l_module_name,
                                p_msg_data         => 'WSH_DEL_DROPOFF_LOC_NULL');
          --Bug 5191354
          ELSIF (p_action_code = 'CREATE' OR
                 (p_action_code = 'UPDATE' AND
                   ((p_in_rec_attr_tab(l_index).ultimate_dropoff_location_id IS NULL ) OR (p_in_rec_attr_tab(l_index).ultimate_dropoff_location_id <> fnd_api.g_miss_num)
                     OR (p_in_rec_attr_tab(l_index).ultimate_dropoff_location_code IS NULL ) OR (p_in_rec_attr_tab(l_index).ultimate_dropoff_location_code <> fnd_api.g_miss_char)
                   ))) THEN
          --{

            IF ( p_action_code = 'UPDATE'
                  AND x_rec_attr_tab(l_index).ultimate_dropoff_location_id IS NULL
                  AND x_rec_attr_tab(l_index).ultimate_dropoff_location_code IS NULL )  THEN
            --{ NULL case
                x_return_status := wsh_util_core.g_ret_sts_error;
                WSH_UTIL_CORE.api_post_call(p_return_status    => x_return_status,
                                x_num_warnings     =>l_num_warnings,
                                x_num_errors       =>l_num_errors,
                                p_module_name      =>l_module_name,
                                p_msg_data         => 'WSH_DEL_DROPOFF_LOC_NULL');

            --} NULL case
            END IF;
            wsh_util_validate.validate_location(
              p_location_id   => x_rec_attr_tab(l_index).ultimate_dropoff_location_id,
              p_location_code => x_rec_attr_tab(l_index).ultimate_dropoff_location_code,
              x_return_status => l_return_status,
              p_isWshLocation => l_isWshLocation);
            --
            IF l_debug_on THEN
              wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_location for Ship To',l_return_status);
            END IF;
            --
            WSH_UTIL_CORE.api_post_call(
              p_return_status     => l_return_status,
              x_num_warnings      => l_num_warnings,
              x_num_errors        => l_num_errors);
            --
          END IF;
          --
        END IF;
        --Bug 5191354
        IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_INTMD_SHIPTO_LOC_LVL) = 1
           AND (p_action_code = 'CREATE' OR
                 (p_action_code = 'UPDATE' AND
                   ((p_in_rec_attr_tab(l_index).intmed_ship_to_location_id IS NULL ) OR (p_in_rec_attr_tab(l_index).intmed_ship_to_location_id <> fnd_api.g_miss_num)
                     OR (p_in_rec_attr_tab(l_index).intmed_ship_to_location_code IS NULL ) OR (p_in_rec_attr_tab(l_index).intmed_ship_to_location_code <> fnd_api.g_miss_char)
                   ))) THEN
            IF l_debug_on THEN
              wsh_debug_sv.log(l_module_name,'loc id ',x_rec_attr_tab(l_index).intmed_ship_to_location_id);
              wsh_debug_sv.log(l_module_name,'loc code ',x_rec_attr_tab(l_index).intmed_ship_to_location_code);
            END IF;
            --
          wsh_util_validate.validate_location(
            p_location_id   => x_rec_attr_tab(l_index).intmed_ship_to_location_id,
            p_location_code => x_rec_attr_tab(l_index).intmed_ship_to_location_code,
            x_return_status => l_return_status,
            p_isWshLocation => l_isWshLocation);
          --
          IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_location for Intmed Ship To',l_return_status);
          END IF;
          --
          WSH_UTIL_CORE.api_post_call(
            p_return_status     => l_return_status,
            x_num_warnings      => l_num_warnings,
            x_num_errors        => l_num_errors);
          --
        END IF;
        --Bug 5191354
        IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_POOLED_SHIPTO_LOC_LVL) = 1
           AND (p_action_code = 'CREATE' OR
                 (p_action_code = 'UPDATE' AND
                   ((p_in_rec_attr_tab(l_index).pooled_ship_to_location_id IS NULL ) OR (p_in_rec_attr_tab(l_index).pooled_ship_to_location_id <> fnd_api.g_miss_num)
                     OR (p_in_rec_attr_tab(l_index).pooled_ship_to_location_code IS NULL ) OR (p_in_rec_attr_tab(l_index).pooled_ship_to_location_code <> fnd_api.g_miss_char)
                   ))) THEN
          --
          wsh_util_validate.validate_location(
            p_location_id   => x_rec_attr_tab(l_index).pooled_ship_to_location_id,
            p_location_code => x_rec_attr_tab(l_index).pooled_ship_to_location_code,
            x_return_status => l_return_status,
            p_isWshLocation => l_isWshLocation);
          --
          IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_location for Pooled Ship To',l_return_status);
          END IF;
          --
          WSH_UTIL_CORE.api_post_call(
            p_return_status     => l_return_status,
            x_num_warnings      => l_num_warnings,
            x_num_errors        => l_num_errors);
          --
        END IF;
        --Bug 5191354
        IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_FOB_LOC_LVL) = 1
           AND (p_action_code = 'CREATE' OR
                 (p_action_code = 'UPDATE' AND
                   ((p_in_rec_attr_tab(l_index).fob_location_id IS NULL ) OR (p_in_rec_attr_tab(l_index).fob_location_id <> fnd_api.g_miss_num)
                     OR (p_in_rec_attr_tab(l_index).fob_location_code IS NULL ) OR (p_in_rec_attr_tab(l_index).fob_location_code <> fnd_api.g_miss_char)
                   ))) THEN
          --
          wsh_util_validate.validate_location(
            p_location_id   => x_rec_attr_tab(l_index).fob_location_id,
            p_location_code => x_rec_attr_tab(l_index).fob_location_code,
            x_return_status => l_return_status,
            p_isWshLocation => l_isWshLocation);
          --
          IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_location for fob location',l_return_status);
          END IF;
          --
          WSH_UTIL_CORE.api_post_call(
            p_return_status     => l_return_status,
            x_num_warnings      => l_num_warnings,
            x_num_errors        => l_num_errors);
          --
        END IF;

        --Bug 5191354
        IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_CUSTOMER_LVL) = 1
           AND (p_action_code = 'CREATE' OR
                 (p_action_code = 'UPDATE' AND
                   ((p_in_rec_attr_tab(l_index).customer_id IS NULL ) OR (p_in_rec_attr_tab(l_index).customer_id <> fnd_api.g_miss_num)
                     OR (p_in_rec_attr_tab(l_index).customer_number IS NULL ) OR (p_in_rec_attr_tab(l_index).customer_number <> fnd_api.g_miss_char)
                   ))) THEN
          --
          wsh_util_validate.validate_customer(
            p_customer_id       => x_rec_attr_tab(l_index).customer_id,
            p_customer_number   => x_rec_attr_tab(l_index).customer_number,
            x_return_status     => l_return_status);
          --
          IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_customer',l_return_status);
          END IF;
          --
          WSH_UTIL_CORE.api_post_call(
            p_return_status     => l_return_status,
            x_num_warnings      => l_num_warnings,
            x_num_errors        => l_num_errors);

        END IF;
        --Bug 5191354
        -- LSP PROJECT : Validate client info
        IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_CLIENT_LVL) = 1
           AND (p_action_code = 'CREATE' OR
                 (p_action_code = 'UPDATE' AND
                   ((p_in_rec_attr_tab(l_index).client_id IS NULL ) OR (p_in_rec_attr_tab(l_index).client_id <> fnd_api.g_miss_num)
                     OR (p_in_rec_attr_tab(l_index).client_code IS NULL ) OR (p_in_rec_attr_tab(l_index).client_code <> fnd_api.g_miss_char)
                   ))) THEN
          --
          IF ( Nvl(x_rec_attr_tab(l_index).client_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num
              OR Nvl(x_rec_attr_tab(l_index).client_code,fnd_api.g_miss_char) <> fnd_api.g_miss_char ) THEN
          --{
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WMS_DEPLOY.GET_CLIENT_DETAILS',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            wms_deploy.get_client_details(
              x_client_id     => x_rec_attr_tab(l_index).client_id,
              x_client_name   => l_client_name,
              x_client_code   => x_rec_attr_tab(l_index).client_code,
              x_return_status => l_return_status);
            --
            IF l_debug_on THEN
              wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_client',l_return_status);
            END IF;
            --
            IF l_return_status <> 'S' THEN
            --{
              FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_ATTRIBUTE');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE','CLIENT');
		      wsh_util_core.add_message(l_return_status,l_module_name);
            --}
            END IF;
            WSH_UTIL_CORE.api_post_call(
            p_return_status     => l_return_status,
            x_num_warnings      => l_num_warnings,
            x_num_errors        => l_num_errors);
          --}
          END IF;
        END IF;
        --LSP PROJECT: end

        IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_FREIGHT_TERMS_LVL) = 1
           AND (p_action_code = 'CREATE' OR
                 (p_action_code = 'UPDATE' AND
                   ((p_in_rec_attr_tab(l_index).freight_terms_code IS NULL ) OR (p_in_rec_attr_tab(l_index).freight_terms_code <> fnd_api.g_miss_char)
                     OR (p_in_rec_attr_tab(l_index).freight_terms_name IS NULL ) OR (p_in_rec_attr_tab(l_index).freight_terms_name <> fnd_api.g_miss_char)
                   ))) THEN
          --
          wsh_util_validate.validate_freight_terms(
            p_freight_terms_code  => x_rec_attr_tab(l_index).freight_terms_code,
            p_freight_terms_name  => x_rec_attr_tab(l_index).freight_terms_name,
            x_return_status       => l_return_status);
          --
          IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_freight_terms',l_return_status);
          END IF;
          --
          WSH_UTIL_CORE.api_post_call(
            p_return_status     => l_return_status,
            x_num_warnings      => l_num_warnings,
            x_num_errors        => l_num_errors);
          --
        END IF;
        --Bug 5191354
        IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_FOB_LVL) = 1
           AND (p_action_code = 'CREATE' OR
                 (p_action_code = 'UPDATE' AND
                   ((p_in_rec_attr_tab(l_index).fob_code IS NULL ) OR (p_in_rec_attr_tab(l_index).fob_code <> fnd_api.g_miss_char)
                     OR (p_in_rec_attr_tab(l_index).fob_name IS NULL ) OR (p_in_rec_attr_tab(l_index).fob_name <> fnd_api.g_miss_char)
                   ))) THEN
          --
          wsh_util_validate.validate_fob(
            p_fob_code          => x_rec_attr_tab(l_index).fob_code,
            p_fob_name          => x_rec_attr_tab(l_index).fob_name,
            x_return_status     => l_return_status);
          --
          IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_fob',l_return_status);
          END IF;
          --
          WSH_UTIL_CORE.api_post_call(
            p_return_status     => l_return_status,
            x_num_warnings      => l_num_warnings,
            x_num_errors        => l_num_errors);
          --
        END IF;

        --Bug 5191354
        IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_WEIGHT_UOM_LVL) = 1
           AND (p_action_code = 'CREATE' OR
                 (p_action_code = 'UPDATE' AND
                   ((p_in_rec_attr_tab(l_index).weight_uom_code IS NULL ) OR (p_in_rec_attr_tab(l_index).weight_uom_code <> fnd_api.g_miss_char)
                   ))) THEN
          --
          IF x_rec_attr_tab(l_index).weight_uom_code is not null or x_rec_attr_tab(l_index).weight_uom_desc is not null THEN
            wsh_util_validate.validate_uom(
              p_type             => 'WEIGHT',
              p_organization_id  => x_rec_attr_tab(l_index).organization_id,
              p_uom_code         => x_rec_attr_tab(l_index).weight_uom_code,
              p_uom_desc         => x_rec_attr_tab(l_index).weight_uom_desc,
              x_return_status    => l_return_status);
            --
            IF l_debug_on THEN
              wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_uom for Weight',l_return_status);
            END IF;
            --
            WSH_UTIL_CORE.api_post_call(
              p_return_status     => l_return_status,
              x_num_warnings      => l_num_warnings,
              x_num_errors        => l_num_errors);
            --
          ELSE
            x_rec_attr_tab(l_index).net_weight := NULL;
            x_rec_attr_tab(l_index).gross_weight := NULL;
          END IF;
          --
        END IF;
        --Bug 5191354
        IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_VOLUME_UOM_LVL) = 1
           AND (p_action_code = 'CREATE' OR
                 (p_action_code = 'UPDATE' AND
                   ((p_in_rec_attr_tab(l_index).volume_uom_code IS NULL ) OR (p_in_rec_attr_tab(l_index).volume_uom_code <> fnd_api.g_miss_char)
                   ))) THEN
          --
          IF x_rec_attr_tab(l_index).volume_uom_code is not null or x_rec_attr_tab(l_index).volume_uom_desc is not null THEN
            wsh_util_validate.validate_uom(
              p_type             => 'VOLUME',
              p_organization_id  => x_rec_attr_tab(l_index).organization_id,
              p_uom_code         => x_rec_attr_tab(l_index).volume_uom_code,
              p_uom_desc         => x_rec_attr_tab(l_index).volume_uom_desc,
              x_return_status    => l_return_status);
            --
            IF l_debug_on THEN
              wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_uom for Volume',l_return_status);
            END IF;
            --
            WSH_UTIL_CORE.api_post_call(
              p_return_status     => l_return_status,
              x_num_warnings      => l_num_warnings,
              x_num_errors        => l_num_errors);
            --
          ELSE
            x_rec_attr_tab(l_index).volume := NULL;
          END IF;
          --
        END IF;
        --Bug 5191354
        IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_CURRENCY_LVL) = 1
           AND ((p_action_code = 'CREATE' OR p_action_code = 'UPDATE') AND
                   ((p_in_rec_attr_tab(l_index).currency_code <> fnd_api.g_miss_char)
                     OR (p_in_rec_attr_tab(l_index).currency_name <> fnd_api.g_miss_char)
                   )) THEN
          --
          --OTM R12, added parameter l_adjusted_amount
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_CURRENCY',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          wsh_util_validate.validate_currency(
            p_currency_code     => x_rec_attr_tab(l_index).currency_code,
            p_currency_name     => x_rec_attr_tab(l_index).currency_name,
            p_amount            => NULL,
            x_return_status     => l_return_status,
            x_adjusted_amount   => l_adjusted_amount);
          --
          IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_currency',l_return_status);
          END IF;
          --
          WSH_UTIL_CORE.api_post_call(
            p_return_status     => l_return_status,
            x_num_warnings      => l_num_warnings,
            x_num_errors        => l_num_errors);
          --
        END IF;
        --Bug 5191354
        IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_ARR_DEP_DATES_LVL) = 1
           AND (p_action_code = 'CREATE' OR
                 (p_action_code = 'UPDATE' AND
                   ((p_in_rec_attr_tab(l_index).initial_pickup_date IS NULL ) OR (p_in_rec_attr_tab(l_index).initial_pickup_date <> fnd_api.g_miss_date)
                     OR (p_in_rec_attr_tab(l_index).ultimate_dropoff_date IS NULL ) OR (p_in_rec_attr_tab(l_index).ultimate_dropoff_date <> fnd_api.g_miss_date)
                   ))) THEN
          --
          wsh_util_validate.validate_from_to_dates(
            p_from_date         => x_rec_attr_tab(l_index).initial_pickup_date,
            p_to_date           => x_rec_attr_tab(l_index).ultimate_dropoff_date,
            x_return_status     => l_return_status);
          --
          IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_from_to_dates',l_return_status);
          END IF;
          --
          WSH_UTIL_CORE.api_post_call(
            p_return_status     => l_return_status,
            x_num_warnings      => l_num_warnings,
            x_num_errors        => l_num_errors);
          --
        END IF;
        --
	--bug 4587399 commented out the code below
	/**************************************************************************************
        IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_NUMBER_OF_LPN_LVL) = 1 THEN
          --
          WSH_DELIVERY_VALIDATIONS.derive_number_of_lpn(
            p_delivery_id       => x_rec_attr_tab(l_index).delivery_id,
            x_number_of_lpn     => x_rec_attr_tab(l_index).number_of_lpn,
            x_return_status     => l_return_status);
          --
          IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'Return Status After Calling derive_numer_of_lpn',l_return_status);
          END IF;
          --
          WSH_UTIL_CORE.api_post_call(
            p_return_status     => l_return_status,
            x_num_warnings      => l_num_warnings,
            x_num_errors        => l_num_errors);
          --
        END IF;
        --
	****************************************************************************************/
        --Bug 5191354
        IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_ROUTE_EXPORT_TXN_LVL) = 1
           AND (p_action_code = 'CREATE' OR
                 (p_action_code = 'UPDATE' AND
                   ((p_in_rec_attr_tab(l_index).ROUTED_EXPORT_TXN IS NULL ) OR (p_in_rec_attr_tab(l_index).ROUTED_EXPORT_TXN <> fnd_api.g_miss_char)
                ))) THEN
          --
          WSH_DELIVERY_VALIDATIONS.Validate_Routed_Export_Txn(
            x_rtd_expt_txn_code       => x_rec_attr_tab(l_index).ROUTED_EXPORT_TXN,
            p_rtd_expt_txn_meaning    => l_dummy_meaning,
            x_return_status           => l_return_status);
          --
          IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'Return Status After Calling Validate_Routed_Export_Txn',l_return_status);
          END IF;
          --
          WSH_UTIL_CORE.api_post_call(
            p_return_status     => l_return_status,
            x_num_warnings      => l_num_warnings,
            x_num_errors        => l_num_errors);
          --
        END IF;
        --Bug 5191354
        IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_FREIGHT_CARRIER_LVL) = 1
           AND (p_action_code = 'CREATE' OR
                 (p_action_code = 'UPDATE' AND
                   ((p_in_rec_attr_tab(l_index).ship_method_name IS NULL ) OR (p_in_rec_attr_tab(l_index).ship_method_name <> fnd_api.g_miss_char)
                     OR (p_in_rec_attr_tab(l_index).ship_method_code IS NULL ) OR (p_in_rec_attr_tab(l_index).ship_method_code <> fnd_api.g_miss_char)
                     OR (p_in_rec_attr_tab(l_index).carrier_code IS NULL ) OR (p_in_rec_attr_tab(l_index).carrier_code <> fnd_api.g_miss_char)
                     OR (p_in_rec_attr_tab(l_index).carrier_id IS NULL ) OR (p_in_rec_attr_tab(l_index).carrier_id <> fnd_api.g_miss_num)
                     OR (p_in_rec_attr_tab(l_index).service_level IS NULL ) OR (p_in_rec_attr_tab(l_index).service_level <> fnd_api.g_miss_char)
                     OR (p_in_rec_attr_tab(l_index).mode_of_transport IS NULL ) OR (p_in_rec_attr_tab(l_index).mode_of_transport <> fnd_api.g_miss_char)
                   ))) THEN
          --
          wsh_util_validate.validate_freight_carrier(
            p_ship_method_name  => x_rec_attr_tab(l_index).ship_method_name,
            x_ship_method_code  => x_rec_attr_tab(l_index).ship_method_code,
            p_carrier_name      => x_rec_attr_tab(l_index).carrier_code,
            x_carrier_id        => x_rec_attr_tab(l_index).carrier_id,
            x_service_level     => x_rec_attr_tab(l_index).service_level,
            x_mode_of_transport => x_rec_attr_tab(l_index).mode_of_transport,
            p_entity_id         => x_rec_attr_tab(l_index).delivery_id,
            p_entity_type       => 'DLVY',
            p_organization_id   => x_rec_attr_tab(l_index).organization_id,
            x_return_status     => l_return_status,
            p_caller            => p_caller);
          --
          IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_freight_carrier',l_return_status);
          END IF;
          --
         /* Fix for Bug 2753330
          If caller is WSH_INBOUND, then need to convert warning to success
          for cases where  validate_freight_carrier returns warning
          so that Inbound processing does not error out */
          IF p_caller IN ('WSH_INBOUND', 'WSH_TPW_INBOUND')
             AND l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING
          THEN
          -- {
              IF l_debug_on THEN
                 wsh_debug_sv.logmsg(l_module_name, 'Setting success for Inbound');
              END IF;
              l_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
          -- }
          END IF;
          WSH_UTIL_CORE.api_post_call(
            p_return_status     => l_return_status,
            x_num_warnings      => l_num_warnings,
            x_num_errors        => l_num_errors);
          --
        END IF;
        --Bug 5191354
        IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_DERIVE_DELIVERY_UOM_LVL) = 1
           AND (p_action_code = 'CREATE' OR
                 (p_action_code = 'UPDATE' AND
                   ( (p_in_rec_attr_tab(l_index).volume_uom_code IS NULL ) OR (p_in_rec_attr_tab(l_index).volume_uom_code <> fnd_api.g_miss_char)
                     OR (p_in_rec_attr_tab(l_index).weight_uom_code IS NULL ) OR (p_in_rec_attr_tab(l_index).weight_uom_code <> fnd_api.g_miss_char)
                    ))) THEN
          --
          wsh_delivery_validations.derive_delivery_uom(
            p_delivery_id         => x_rec_attr_tab(l_index).delivery_id,
            p_organization_id     => x_rec_attr_tab(l_index).organization_id,
            x_volume_uom_code     => x_rec_attr_tab(l_index).volume_uom_code,
            x_weight_uom_code     => x_rec_attr_tab(l_index).weight_uom_code,
            x_wt_nullify_flag     => l_wt_nullify_flag,
            x_vol_nullify_flag    => l_vol_nullify_flag,
            x_return_status       => l_return_status);

          --
          IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'Return Status After Calling derive_delivery_uom',l_return_status);
          END IF;
          --
          WSH_UTIL_CORE.api_post_call(
            p_return_status     => l_return_status,
            x_num_warnings      => l_num_warnings,
            x_num_errors        => l_num_errors);
          --
          -- We need to nullify the Weight and Volumes if the organization is changed
          -- and if the existing uoms are not defined in the new organization.
          IF l_wt_nullify_flag THEN
            x_rec_attr_tab(l_index).net_weight := NULL;
            x_rec_attr_tab(l_index).gross_weight := NULL;
          END IF;
          IF l_vol_nullify_flag THEN
            x_rec_attr_tab(l_index).volume := NULL;
          END IF;
          --
        END IF;
        --
        --Bug 4140359
        IF NVL(p_caller,'-1') <> 'WSH_FSTRX' THEN --{
           IF NVL(x_rec_attr_tab(l_index).GROSS_WEIGHT,0) > 0
              OR NVL(x_rec_attr_tab(l_index).NET_WEIGHT,0) > 0 THEN
              IF x_rec_attr_tab(l_index).WEIGHT_UOM_CODE IS NULL THEN
                 FND_MESSAGE.SET_NAME('WSH','WSH_WTVOL_NULL');
                 wsh_util_core.add_message(wsh_util_core.g_ret_sts_error,l_module_name);
                 RAISE FND_API.G_EXC_ERROR;
              END IF;
           END IF;
           --Bug 4140359
           IF NVL(x_rec_attr_tab(l_index).VOLUME,0) > 0
             AND x_rec_attr_tab(l_index).VOLUME_UOM_CODE IS NULL THEN
              FND_MESSAGE.SET_NAME('WSH','WSH_WTVOL_NULL');
              wsh_util_core.add_message(wsh_util_core.g_ret_sts_error,l_module_name);
              RAISE FND_API.G_EXC_ERROR;
           END IF;
        END IF; --}
        x_valid_index_tab(l_index) := l_index;
        --
      EXCEPTION
        --
        WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO VALIDATE_DLVY_GRP_LOOP;
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO VALIDATE_DLVY_GRP_LOOP;
        WHEN OTHERS THEN
          ROLLBACK TO VALIDATE_DLVY_GRP_LOOP;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        --
      END;
      --
      l_index := x_rec_attr_tab.NEXT(l_index);
      --
    END LOOP;
    --
    IF l_num_errors = x_rec_attr_tab.COUNT THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_num_errors > 0 THEN
      RAISE WSH_UTIL_CORE.G_EXC_WARNING;
    ELSIF l_num_warnings > 0 THEN
      RAISE WSH_UTIL_CORE.G_EXC_WARNING;
    ELSE
      x_return_status := wsh_util_core.g_ret_sts_success;
    END IF;

/* Assumption is this should be taken care of by get_disabled list.
          l_assigned_to_trip := WSH_Delivery_Validations.Del_Assigned_To_Trip
                                         (p_delivery_id =>  x_rec_attr_tab(l_index).delivery_id,
                                          x_return_status => x_return_status);
*/
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO VALIDATE_DELIVERY_GRP;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO VALIDATE_DELIVERY_GRP;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --
    WHEN OTHERS THEN
      ROLLBACK TO VALIDATE_DELIVERY_GRP;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_DELIVERIES_GRP.VALIDATE_DELIVERY');
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
  END Validate_Delivery;

--========================================================================
-- PROCEDURE : Create_Update_Delivery  Must be called only by the Form
--                                     and the Wrapper Group API.
--
-- PARAMETERS: p_api_version_number    known api version error buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_in_rec                Record for caller, phase
--                                     and action_code ( CREATE-UPDATE )
--         p_rec_attr_tab          Table of attributes for the delivery entity
--           x_del_out_rec_tab       Table of delivery_id, and name of new deliveries,
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Creates or updates a record in wsh_new_deliveries table with information
--             specified in p_delivery_info
--========================================================================
  PROCEDURE Create_Update_Delivery
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    p_commit         IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_in_rec                 IN   del_In_Rec_Type,
    p_rec_attr_tab       IN   WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type,
    x_del_out_rec_tab        OUT  NOCOPY Del_Out_Tbl_Type,
    x_return_status          OUT  NOCOPY VARCHAR2,
    x_msg_count              OUT  NOCOPY NUMBER,
    x_msg_data               OUT  NOCOPY VARCHAR2)
  IS
    --
l_debug_on BOOLEAN;
    --
    l_module_name CONSTANT   VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_UPDATE_DELIVERY';
    --
    l_index                  NUMBER;
    l_num_warnings           NUMBER := 0;
    l_num_errors             NUMBER := 0;
    l_return_status          VARCHAR2(1);
    l_api_version_number     CONSTANT NUMBER := 1.0;
    l_api_name               CONSTANT VARCHAR2(30):= 'Create_Update_Delivery';
    l_msg_count        NUMBER;
    l_msg_data         VARCHAR2(32767);

    --
    l_rec_attr_tab           WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type;
    l_index_tab              wsh_util_core.id_tab_type;
    --
    l_input_param_flag      BOOLEAN := TRUE;
    --
    l_param_name            VARCHAR2(100);
    --
--Compatibility Changes
    l_cc_validate_result    VARCHAR2(1);
    l_cc_failed_records     WSH_FTE_COMP_CONSTRAINT_PKG.failed_line_tab_type;
    l_cc_line_groups      WSH_FTE_COMP_CONSTRAINT_PKG.line_group_tab_type;
    l_cc_group_info     WSH_FTE_COMP_CONSTRAINT_PKG.cc_group_tab_type;


    l_cc_upd_dlvy_intmed_ship_to  VARCHAR2(1);
    l_cc_upd_dlvy_ship_method   VARCHAR2(1);
    l_cc_dlvy_intmed_ship_to    NUMBER;
    l_cc_dlvy_ship_method   VARCHAR2(30);
    l_cc_del_rows     wsh_util_core.id_tab_type;
    l_cc_grouping_rows      wsh_util_core.id_tab_type;
    l_cc_return_status      VARCHAR2(1);
    l_cc_count_trip_rows    NUMBER;
    l_cc_count_grouping_rows    NUMBER;
    l_cc_trip_id      wsh_util_core.id_tab_type;
    l_cc_trip_id_tab      wsh_util_core.id_tab_type;
    b_cc_linefailed     boolean;
    l_rec_attr_tab_temp     WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type;
    l_cc_count_success      NUMBER;

    --dummy tables for calling validate_constraint_mainper
    l_cc_del_attr_tab         WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type;
    l_cc_det_attr_tab         wsh_glbl_var_strct_grp.Delivery_Details_Attr_Tbl_Type;
    l_cc_trip_attr_tab          WSH_TRIPS_PVT.Trip_Attr_Tbl_Type;
    l_cc_stop_attr_tab          WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type;
    l_cc_in_ids           wsh_util_core.id_tab_type;
    l_cc_fail_ids   wsh_util_core.id_tab_type;
    l_param_info    WSH_SHIPPING_PARAMS_PVT.Parameter_Rec_Typ;
    l_log_itm_exc   VARCHAR2(1);

--Compatibility Changes

    CURSOR c_getorgcarriersmc(p_delid NUMBER) IS
    SELECT organization_id, name, ship_method_code, carrier_id
    FROM wsh_new_deliveries
    WHERE  delivery_id = p_delid
    and ignore_for_planning<>'Y';

    l_wh_type VARCHAR2(3);
    l_organization_id     wsh_new_deliveries.organization_id%TYPE;
    l_smc                 wsh_new_deliveries.ship_method_code%TYPE;
    l_carrier_id          wsh_new_deliveries.carrier_id%TYPE;
    l_ignore_for_planning wsh_new_deliveries.ignore_for_planning%TYPE;
    l_tmp_ignore          wsh_new_deliveries.ignore_for_planning%TYPE;
    l_tmp_del_ids         wsh_util_core.id_tab_type;

    -- Pack J: LCSS Rate Delivery.
    l_exception_id     NUMBER;
    l_exception_message  VARCHAR2(2000);
    l_in_param_rec       WSH_FTE_INTEGRATION.rate_del_in_param_rec;
    l_out_param_rec      WSH_FTE_INTEGRATION.rate_del_out_param_rec;
    l_error_text         VARCHAR2(2000);
    l_delivery_rows       wsh_util_core.id_tab_type;
    --

    --OTM R12 Org-Specific Start.
    l_gc3_is_installed    VARCHAR2(1);
    --OTM R12 End.

    RECORD_LOCKED           EXCEPTION;
    PRAGMA EXCEPTION_INIT(RECORD_LOCKED, -54);
    --
    --Bugfix 4070732
    l_api_session_name CONSTANT VARCHAR2(150) := G_PKG_NAME ||'.' || l_module_name;
    l_reset_flags BOOLEAN;

  BEGIN
    -- Bug 4070732
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
    SAVEPOINT CREATE_UPDATE_DELIVERY_GRP;
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

    --OMT R12 Org-Specific Start
    l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED;
    IF l_gc3_is_installed IS NULL THEN
      l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED;
    END IF;
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_gc3_is_installed ',
                                      l_gc3_is_installed);
    END IF;
    --OTM R12 End.

    IF l_debug_on THEN
      --
      wsh_debug_sv.push (l_module_name);
      wsh_debug_sv.log (l_module_name,'action_code',p_in_rec.action_code);
      wsh_debug_sv.log (l_module_name,'caller',p_in_rec.caller);
      wsh_debug_sv.log (l_module_name,'COUNT',p_rec_attr_tab.COUNT);
      --
    END IF;
    --
    IF p_in_rec.action_code IS NULL THEN
      l_param_name := 'p_in_rec.action_code';
      l_input_param_flag := FALSE;
    ELSIF p_in_rec.caller IS NULL  THEN
      l_param_name := 'p_in_rec.caller';
      l_input_param_flag := FALSE;
    ELSIF p_rec_attr_tab.COUNT = 0  THEN
      l_param_name := 'p_rec_attr_tab.COUNT';
      l_input_param_flag := FALSE;
    END IF;

    IF not l_input_param_flag THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
      FND_MESSAGE.SET_TOKEN('FIELD_NAME',l_param_name);
      x_return_status := wsh_util_core.g_ret_sts_error;
      wsh_util_core.add_message(x_return_status,l_module_name);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    --
    WSH_ACTIONS_LEVELS.set_validation_level (
      p_entity        => 'DLVY',
      p_caller        => p_in_rec.caller,
      p_phase         => nvl(p_in_rec.phase,1),
      p_action        => p_in_rec.action_code ,
      x_return_status => l_return_status);
    --
    IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name,'Return Status After Calling set_validation_level',l_return_status);
    END IF;
    --
    wsh_util_core.api_post_call(
      p_return_status    => l_return_status,
      x_num_warnings     => l_num_warnings,
      x_num_errors       => l_num_errors);
    --
    IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_DISABLED_LIST_LVL) = 1 THEN
      --
      l_index := p_rec_attr_tab.FIRST;
      WHILE l_index is not null LOOP
        BEGIN
          SAVEPOINT DLVY_GRP_GET_DISAB_LIST_LOOP;

          WSH_DELIVERY_VALIDATIONS.get_disabled_list(
            p_delivery_rec     => p_rec_attr_tab(l_index),
            p_in_rec           => p_in_rec,
            x_return_status    => l_return_status,
            x_msg_count        => l_msg_count,
            x_msg_data         => l_msg_data,
            x_delivery_rec     => l_rec_attr_tab(l_index));
          --
          IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'Return Status After Calling get_disabled_list',l_return_status);
          END IF;
          --
          WSH_UTIL_CORE.api_post_call(
            p_return_status    => l_return_status,
            x_num_warnings     => l_num_warnings,
            x_num_errors       => l_num_errors,
            p_msg_data         => l_msg_data);
          --
        EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO DLVY_GRP_GET_DISAB_LIST_LOOP;
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO DLVY_GRP_GET_DISAB_LIST_LOOP;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          WHEN OTHERS THEN
            ROLLBACK TO DLVY_GRP_GET_DISAB_LIST_LOOP;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;
        --
        l_index := p_rec_attr_tab.NEXT(l_index);
        --
      END LOOP;
      --
    ELSE
      --
      l_rec_attr_tab := p_rec_attr_tab;
      --
    END IF;
    --
   IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_VALIDATE_CONSTRAINTS_LVL) = 1  THEN --{
--Compatibility Constraints
    --Compatiblity Changes
    IF wsh_util_core.fte_is_installed = 'Y' THEN

     WSH_FTE_COMP_CONSTRAINT_PKG.validate_constraint_main(
       p_api_version_number =>  p_api_version_number,
       p_init_msg_list      =>  FND_API.G_FALSE,
       p_entity_type        =>  'D',
       p_target_id          =>  null,
       p_action_code        =>  p_in_rec.action_code,
       p_del_attr_tab       =>  l_rec_attr_tab,
       p_det_attr_tab       =>  l_cc_det_attr_tab,
       p_trip_attr_tab      =>  l_cc_trip_attr_tab,
       p_stop_attr_tab      =>  l_cc_stop_attr_tab,
       p_in_ids             =>  l_cc_in_ids,
       x_fail_ids           =>  l_cc_fail_ids,
       x_validate_result          =>  l_cc_validate_result,
       x_failed_lines             =>  l_cc_failed_records,
       x_line_groups              =>  l_cc_line_groups,
       x_group_info               =>  l_cc_group_info,
       x_msg_count                =>  l_msg_count,
       x_msg_data                 =>  l_msg_data,
       x_return_status            =>  l_return_status);


      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_constraint_dlvy_wrap',l_return_status);
        wsh_debug_sv.log(l_module_name,'validate_result After Calling validate_constraint_main',l_cc_validate_result);
        wsh_debug_sv.log(l_module_name,'msg_count After Calling validate_constraint_main',l_msg_count);
        wsh_debug_sv.log(l_module_name,'msg_data After Calling validate_constraint_main',l_msg_data);
        wsh_debug_sv.log(l_module_name,'fail_ids count After Calling validate_constraint_main',l_cc_failed_records.COUNT);
        wsh_debug_sv.log(l_module_name,'l_cc_line_groups.count count After Calling validate_constraint_main',l_cc_line_groups.COUNT);
        wsh_debug_sv.log(l_module_name,'group_info count After Calling validate_constraint_main',l_cc_group_info.COUNT);
      END IF;


      IF l_return_status=wsh_util_core.g_ret_sts_error THEN
        --fix p_rec_attr_tab to have only successful records
        l_cc_count_success:=1;

        IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'l_rec_attr_tab count before removing failed lines',l_rec_attr_tab.COUNT);
        END IF;

        IF l_cc_failed_records.COUNT>0 AND l_rec_attr_tab.COUNT>0 THEN

          IF l_cc_failed_records.COUNT=l_rec_attr_tab.COUNT THEN
            IF l_debug_on THEN
               wsh_debug_sv.logmsg(l_module_name,'all dels failed compatibility check');
            END IF;
            FND_MESSAGE.SET_NAME('WSH','WSH_DEL_COMP_FAILED');
            wsh_util_core.api_post_call(
              p_return_status    => l_return_status,
              x_num_warnings     => l_num_warnings,
              x_num_errors       => l_num_errors,
              p_msg_data         => l_msg_data);
          ELSE
            l_return_status:=wsh_util_core.g_ret_sts_warning;
          END IF;


          FOR i in l_rec_attr_tab.FIRST..l_rec_attr_tab.LAST LOOP
            b_cc_linefailed:=FALSE;
            FOR j in l_cc_failed_records.FIRST..l_cc_failed_records.LAST LOOP
              --for create, in WSHFTCCB, dummy delivery_id (index of l_rec_attr_tab)
              --is passed so use that to remove rec
              IF (p_in_rec.action_code='CREATE' AND l_rec_attr_tab(i).delivery_id is null
                  AND i=l_cc_failed_records(j).entity_line_id) THEN
                b_cc_linefailed:=TRUE;
                FND_MESSAGE.SET_NAME('WSH','WSH_DEL_COMP_FAILED');
                FND_MESSAGE.SET_TOKEN('DEL_ID',l_rec_attr_tab(i).name);
              ELSIF (l_rec_attr_tab(i).delivery_id=l_cc_failed_records(j).entity_line_id) THEN
                b_cc_linefailed:=TRUE;
                FND_MESSAGE.SET_NAME('WSH','WSH_DEL_COMP_FAILED');
                FND_MESSAGE.SET_TOKEN('DEL_ID',l_cc_failed_records(j).entity_line_id);
              END IF;
            END LOOP;
            IF (NOT(b_cc_linefailed)) THEN
              l_rec_attr_tab_temp(l_cc_count_success):=l_rec_attr_tab(i);
              l_cc_count_success:=l_cc_count_success+1;
            END IF;
         END LOOP;

         IF l_rec_attr_tab_temp.COUNT>0 THEN
            l_rec_attr_tab:=l_rec_attr_tab_temp;
         END IF;

       ELSE
            l_return_status:=wsh_util_core.g_ret_sts_warning;
       END IF;--failed_records.count>0


       IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'del rec_attr_tab count after removing failed lines',l_rec_attr_tab.COUNT);
       END IF;
       --fix p_rec_attr_tab to have only successful records
     END IF;--error


      IF l_return_status=wsh_util_core.g_ret_sts_error and l_cc_failed_records.COUNT<>l_rec_attr_tab.COUNT THEN
        l_return_status:=wsh_util_core.g_ret_sts_warning;
      END IF;


      --
      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors,
        p_msg_data         => l_msg_data);

    END IF;

--Compatibility Constraints
   END IF; --}
-- Bug# 5191354: Parameter p_in_rec_attr_tab has been added to the API.
    Validate_Delivery (
      x_rec_attr_tab        =>  l_rec_attr_tab ,
      p_in_rec_attr_tab     =>  p_rec_attr_tab, --Bug 5191354
      p_action_code         =>  p_in_rec.action_code,
      p_caller              =>  p_in_rec.caller,
      x_valid_index_tab     =>  l_index_tab,
      x_return_status       =>  l_return_status);
    --
    WSH_UTIL_CORE.api_post_call(
      p_return_status        => l_return_status,
      x_num_warnings         => l_num_warnings,
      x_num_errors           => l_num_errors);
    --
    IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_delivery',l_return_status);
    END IF;
    --
    l_index := l_index_tab.FIRST;
    WHILE l_index is not null LOOP
      BEGIN
        --
        SAVEPOINT CREATE_UPDATE_DLVY_GRP_LOOP;
        --
        IF p_in_rec.action_code = 'CREATE' THEN

          /*** J changes TP release ****/
          l_tmp_ignore := l_rec_attr_tab(l_index).ignore_for_planning;
          IF (wsh_util_core.TP_is_installed ='Y' OR l_gc3_is_installed = 'Y' ) --OTM R12 Org-Specific . Added second OR condition
             AND (
                  (l_tmp_ignore is null OR l_tmp_ignore=FND_API.G_MISS_CHAR)
                   OR (l_tmp_ignore is not null AND l_tmp_ignore='N')-- need to check this as form always passes 'N'
                 ) THEN

                 l_wh_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type
                           (p_organization_id	 => l_rec_attr_tab(l_index).organization_id,
                            p_carrier_id         => l_rec_attr_tab(l_index).carrier_id,
                            p_ship_method_code   => l_rec_attr_tab(l_index).ship_method_code,
                            p_msg_display        => 'N',
                            x_return_status  	 => l_return_status
                            );

                 IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,' Get_Warehouse_Type  l_wh_type,l_return_status',l_wh_type||l_return_status);
                 END IF;
                 WSH_UTIL_CORE.api_post_call(
                     p_return_status        => l_return_status,
                     x_num_warnings         => l_num_warnings,
                     x_num_errors           => l_num_errors);


                 -- TPW - Distributed changes
                 IF (nvl(l_wh_type, FND_API.G_MISS_CHAR) IN ('TPW','CMS','TW2')) THEN
	             l_ignore_for_planning:='Y';
                 --OTM R12 Org-Specific Start
                 ELSIF (l_gc3_is_installed = 'Y') THEN
                     wsh_util_validate.calc_ignore_for_planning(
                     p_organization_id  => l_rec_attr_tab(l_index).organization_id
                    ,p_client_id        => l_rec_attr_tab(l_index).client_id -- LSP PROJECT
                    ,p_carrier_id       => NULL
                    ,p_ship_method_code => NULL
                    ,p_tp_installed     => NULL
                    ,p_caller           => NULL
                    ,x_ignore_for_planning => l_ignore_for_planning
                    ,x_return_status       => l_return_status
                    ,p_otm_installed       => 'Y');
                    IF l_debug_on THEN
                      WSH_DEBUG_SV.log(l_module_name,'After call to wsh_util_validate.ca'
                            ||'lc_ignore_for_planning l_return_status',l_return_status);
                      WSH_DEBUG_SV.log(l_module_name,'l_ignore_for_planning ',
                                                      l_ignore_for_planning );
                    END IF;
                    IF (l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                            WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
                       RAISE FND_API.G_EXC_ERROR;
                    END IF;
                 END IF;
                 --OTM R12 End.
          ELSIF (l_tmp_ignore='Y' and
                 (WSH_UTIL_CORE.TP_Is_Installed ='Y' OR
                  l_gc3_is_installed = 'Y')) THEN
              l_ignore_for_planning:=l_tmp_ignore;
          ELSE
              l_ignore_for_planning:='N';
          END IF;

          --OTM R12 Org-Specific Start
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_ignore_for_planning ',l_ignore_for_planning);
          END IF;
          --OTM R12 End.
          l_rec_attr_tab(l_index).ignore_for_planning:=l_ignore_for_planning;
          /*** J changes TP release ****/


         WSH_DELIVERY_AUTOCREATE.Create_Update_Hash(
               p_delivery_rec => l_rec_attr_tab(l_index),
               x_return_status => l_return_status);

         WSH_UTIL_CORE.api_post_call(
           p_return_status        => l_return_status,
           x_num_warnings         => l_num_warnings,
           x_num_errors           => l_num_errors);



          --
          WSH_NEW_DELIVERIES_PVT.Create_Delivery(
            p_delivery_info    => l_rec_attr_tab(l_index),
            x_rowid            => x_del_out_rec_tab(l_index).rowid,
            x_delivery_id      => x_del_out_rec_tab(l_index).delivery_id,
            x_name             => x_del_out_rec_tab(l_index).name,
            x_return_status    => l_return_status);
          --
          IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'Return Status After Calling Create Delivery',l_return_status);
          END IF;

          IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIPPING_PARAMS_PVT.Get',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          --
          WSH_UTIL_CORE.api_post_call(
            p_return_status    => l_return_status,
            x_num_warnings     => l_num_warnings,
            x_num_errors       => l_num_errors);

          WSH_SHIPPING_PARAMS_PVT.Get(
            p_organization_id => l_rec_attr_tab(l_index).organization_id,
            x_param_info    => l_param_info,
            x_return_status   => l_return_status
                              );

          IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'Return Status After Calling WSH_SHIPPING_PARAMS_PVT.Get',l_return_status);
          END IF;

          WSH_UTIL_CORE.api_post_call(
            p_return_status        => l_return_status,
            x_num_warnings         => l_num_warnings,
            x_num_errors           => l_num_errors);

          IF l_param_info.export_screening_flag IN ('C', 'A')
          AND NVL(l_rec_attr_tab(l_index).shipment_Direction,'O') IN ('O','IO')   -- J-IB-NPARIKH
          THEN

            -- ITM Check applicable only for outbound (O/IO) delivery.
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_VALIDATIONS.Check_ITM_Required',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

            l_log_itm_exc :=  WSH_DELIVERY_VALIDATIONS.Check_ITM_Required
                                  (p_delivery_id => x_del_out_rec_tab(l_index).delivery_id,
                                   x_return_status => l_return_status);
            IF l_debug_on THEN
               wsh_debug_sv.log(l_module_name,'Return Status After Calling WSH_DELIVERY_VALIDATIONS.Check_ITM_Required',l_return_status);
            END IF;

            WSH_UTIL_CORE.api_post_call(
                  p_return_status        => l_return_status,
                  x_num_warnings         => l_num_warnings,
                  x_num_errors           => l_num_errors);

            IF l_log_itm_exc = 'Y' THEN
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_VALIDATIONS.Log_ITM_Exception',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               WSH_DELIVERY_VALIDATIONS.Log_ITM_Exception (
                                   p_delivery_id => x_del_out_rec_tab(l_index).delivery_id,
                                   p_action_type => 'CREATE_DELIVERY',
                                   p_ship_from_location_id =>  l_rec_attr_tab(l_index).initial_pickup_location_id,
                                   x_return_status => l_return_status);
                IF l_debug_on THEN
                   wsh_debug_sv.log(l_module_name,'Return Status After Calling WSH_DELIVERY_VALIDATIONS.Log_ITM_Exception',l_return_status);
                END IF;

                WSH_UTIL_CORE.api_post_call(
                  p_return_status        => l_return_status,
                  x_num_warnings         => l_num_warnings,
                  x_num_errors           => l_num_errors);
            END IF;

          END IF;
          --
          -- Pack J: Auto Select Carrier if the parameter is set.
          IF NVL(l_param_info.auto_apply_routing_rules, 'N') = 'D' THEN

             IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERY_ACTIONS.PROCESS_CARRIER_SELECTION',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;
         --
             l_delivery_rows(1) := x_del_out_rec_tab(l_index).delivery_id;

             WSH_NEW_DELIVERY_ACTIONS.PROCESS_CARRIER_SELECTION(p_delivery_id_tab => l_delivery_rows,
                                                            p_batch_id        => null,
                                                            p_form_flag       => 'N',
                                                            x_return_message  => l_error_text,
                                                            x_return_status   => l_return_status);


             IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN

               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,  'ERROR OCCURRED WHILST PROCESSING CARRIER SELECTION'  );
               END IF;

               l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;

             END IF;

             WSH_UTIL_CORE.api_post_call(
                  p_return_status    => l_return_status,
                  x_num_warnings     => l_num_warnings,
                  x_num_errors       => l_num_errors);

          END IF;

          --
        ELSE

          -- J-IB-NPARIKH-{
          IF NVL(l_rec_attr_tab(l_index).shipment_direction,'O') NOT IN ('O','IO')
          THEN
          --{
              --
              -- Update ship-from location on delivery,lines and associated trip stops
              --
              WSH_NEW_DELIVERY_ACTIONS.update_ship_from_location
                (
                    p_delivery_id                   => l_rec_attr_tab(l_index).delivery_id,
                    p_location_id                   => l_rec_attr_tab(l_index).initial_pickup_location_id,
                    x_return_status                 => l_return_status
                );
              --
              IF l_debug_on THEN
                wsh_debug_sv.log(l_module_name,'Return Status After Calling update_ship_from_location',l_return_status);
              END IF;
              --
              WSH_UTIL_CORE.api_post_call(
                  p_return_status    => l_return_status,
                  x_num_warnings     => l_num_warnings,
                  x_num_errors       => l_num_errors);
          --}
          END IF;
          --
          --
          -- J-IB-NPARIKH-}

         WSH_DELIVERY_AUTOCREATE.Create_Update_Hash(
               p_delivery_rec => l_rec_attr_tab(l_index),
               x_return_status => l_return_status);

         WSH_UTIL_CORE.api_post_call(
           p_return_status        => l_return_status,
           x_num_warnings         => l_num_warnings,
           x_num_errors           => l_num_errors);



          WSH_NEW_DELIVERIES_PVT.Update_Delivery(
            p_rowid            => l_rec_attr_tab(l_index).rowid,
            p_delivery_info    => l_rec_attr_tab(l_index),
            x_return_status    => l_return_status);
          --
          IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'Return Status After Calling Update Delivery',l_return_status);
          END IF;
          --
          --
          WSH_UTIL_CORE.api_post_call(
            p_return_status    => l_return_status,
            x_num_warnings     => l_num_warnings,
            x_num_errors       => l_num_errors);

          /***TP Release**/
          --TP Release : if carrier or smc is changed, if they are CMS/TPW, call change_ignoreplan_status
          l_organization_id:=l_rec_attr_tab(l_index).organization_id;
          l_smc:=l_rec_attr_tab(l_index).ship_method_code;
          l_carrier_id:=l_rec_attr_tab(l_index).carrier_id;

          IF (l_carrier_id is not null
              OR l_smc is not null
              OR l_organization_id is not null
             ) AND (WSH_UTIL_CORE.TP_Is_Installed = 'Y'
                    OR l_gc3_is_installed = 'Y') THEN

             FOR cur in c_getorgcarriersmc (l_rec_attr_tab(l_index).delivery_id) LOOP
                   IF l_organization_id is null THEN
                       l_organization_id:=cur.organization_id;
                   END IF;
                   IF l_smc is null THEN
                       l_smc:=cur.ship_method_code;
                   END IF;
                   IF l_carrier_id is null THEN
                       l_carrier_id:=cur.carrier_id;
                   END IF;
                   l_wh_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type
				(p_organization_id => l_organization_id,
				 x_return_status   => l_return_status,
				 p_carrier_id	   => l_carrier_id,
				 p_ship_method_code=> l_smc,
				 p_msg_display	   => 'N');

                   IF l_debug_on THEN
		         WSH_DEBUG_SV.log(l_module_name,'Get_Warehouse_Type organization_id,l_wh_type,l_return_status',l_organization_id||l_wh_type||l_return_status);
		         WSH_DEBUG_SV.log(l_module_name,'carrier_id',l_carrier_id);
		         WSH_DEBUG_SV.log(l_module_name,'smc',l_smc);
                         WSH_DEBUG_SV.log(l_module_name,'l_ignore',l_ignore_for_planning);
          	   END IF;

                   WSH_UTIL_CORE.api_post_call(
                       p_return_status    => l_return_status,
                       x_num_warnings     => l_num_warnings,
                       x_num_errors       => l_num_errors);

                   --if org is a tpw/cms and current ignore plan is 'N', change ignore plan by
                   --calling api.

                   IF (nvl(l_wh_type, FND_API.G_MISS_CHAR) IN ('TPW','CMS')) THEN
                        l_tmp_del_ids.delete;
                        l_tmp_del_ids(1):=l_rec_attr_tab(l_index).delivery_id;
                        wsh_tp_release.change_ignoreplan_status
                                     (p_entity         => 'DLVY',
                                      p_in_ids         => l_tmp_del_ids,
                                      p_action_code    => 'IGNORE_PLAN',
                                      x_return_status  => l_return_status);
                       IF l_debug_on THEN
                            wsh_debug_sv.log(l_module_name,'Return Status After Calling change_ignoreplan_sttatus',l_return_status);
                       END IF;
                       WSH_UTIL_CORE.api_post_call(
                         p_return_status    => l_return_status,
                         x_num_warnings     => l_num_warnings,
                         x_num_errors       => l_num_errors);
                   END IF;

             END LOOP;
          END IF;
          /***TP Release**/
        END IF; -- End if For p_in_rec.action_code Check for CREATE or UDPATE.
        --
      EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO CREATE_UPDATE_DLVY_GRP_LOOP;
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO CREATE_UPDATE_DLVY_GRP_LOOP;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        WHEN OTHERS THEN
          ROLLBACK TO CREATE_UPDATE_DLVY_GRP_LOOP;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;
      --
      l_index := l_index_tab.NEXT(l_index);
      --
    END LOOP;
    --

    IF (l_num_errors = l_rec_attr_tab.count ) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_num_errors > 0 ) THEN
      RAISE WSH_UTIL_CORE.G_EXC_WARNING;
    ELSIF (l_num_warnings > 0 ) THEN
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
                ROLLBACK TO CREATE_UPDATE_DELIVERY_GRP;
              END IF;
            END IF;

        --}
        END IF;
    --}
    END IF;

    --bug 4070732
    --
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
    WHEN RECORD_LOCKED THEN
      ROLLBACK TO CREATE_UPDATE_DELIVERY_GRP;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('WSH', 'WSH_NO_LOCK');
      wsh_util_core.add_message(x_return_status,l_module_name);
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
      FND_MSG_PUB.Count_And_Get (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
                     p_encoded => FND_API.G_FALSE);

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'RECORD_LOCKED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:RECORD_LOCKED');
      END IF;

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO CREATE_UPDATE_DELIVERY_GRP;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
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

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CREATE_UPDATE_DELIVERY_GRP;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;

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
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
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
                ROLLBACK TO CREATE_UPDATE_DELIVERY_GRP;
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
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --
    WHEN OTHERS THEN
      ROLLBACK TO CREATE_UPDATE_DELIVERY_GRP;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_DELIVERIES_GRP.CREATE_UPDATE_DELIVERY');
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
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
  END Create_Update_Delivery;


-- The below procedue will be obsoleted after patchset I.
--========================================================================
-- PROCEDURE : Validate_Delivery         PRIVATE
--
-- PARAMETERS: p_delivery_info         Attributes for the delivery entity
--             p_action_code           'CREATE', 'UPDATE'
--             x_return_status         Return status of API
-- COMMENT   : Validates p_delivery_info by calling column specific validations
--========================================================================

  PROCEDURE Validate_Delivery
      (p_delivery_info         IN OUT NOCOPY  delivery_pub_rec_type,
       p_action_code           IN     VARCHAR2,
       x_return_status         OUT NOCOPY     VARCHAR2) IS

  l_assigned_to_trip VARCHAR2(1);

  --OTM R12
  l_adjusted_amount      NUMBER;
  --

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_DELIVERY';
--
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
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        --
        WSH_DEBUG_SV.log(l_module_name,'P_ACTION_CODE',P_ACTION_CODE);
        WSH_DEBUG_SV.log(l_module_name,'p_delivery_info.delivery_id',
                                         p_delivery_info.delivery_id);
        WSH_DEBUG_SV.log(l_module_name,'p_delivery_info.name',
                                         p_delivery_info.name);
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    --OTM R12
    l_adjusted_amount := 0;
    --

    IF (p_action_code <> 'CREATE') THEN

       IF (p_delivery_info.delivery_id <> FND_API.G_MISS_NUM) OR (p_delivery_info.name <> FND_API.G_MISS_CHAR) THEN

            IF (p_delivery_info.name <> FND_API.G_MISS_CHAR) THEN
             p_delivery_info.delivery_id := NULL;
          END IF;

            wsh_util_validate.validate_delivery_name(
            p_delivery_info.delivery_id,
            p_delivery_info.name,
            x_return_status);

            IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'x_return_status',
                                                             x_return_status);
                   WSH_DEBUG_SV.pop(l_module_name);
               END IF;
               --
               RETURN;
          END IF;

         END IF;

      END IF;

    IF (p_delivery_info.organization_id <> FND_API.G_MISS_NUM) OR (p_delivery_info.organization_code <> FND_API.G_MISS_CHAR) THEN

         IF (p_delivery_info.organization_code <> FND_API.G_MISS_CHAR) THEN
          p_delivery_info.organization_id := NULL;
       END IF;
         wsh_util_validate.validate_org(
         p_delivery_info.organization_id,
         p_delivery_info.organization_code,
         x_return_status);

         IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'x_return_status',
                                                              x_return_status);
                WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            --
            RETURN;
       END IF;
    END IF;

    IF (nvl(p_delivery_info.delivery_type,'STANDARD') NOT IN ('STANDARD','CONSOLIDATED')) THEN
          p_delivery_info.delivery_type := 'STANDARD';

      END IF;

    IF (p_delivery_info.loading_order_flag <> FND_API.G_MISS_CHAR) OR (p_delivery_info.loading_order_desc <> FND_API.G_MISS_CHAR) THEN

         IF (p_delivery_info.loading_order_desc <> FND_API.G_MISS_CHAR) THEN
          p_delivery_info.loading_order_flag := NULL;
       END IF;
         wsh_util_validate.validate_loading_order(
         p_delivery_info.loading_order_flag,
         p_delivery_info.loading_order_desc,
         x_return_status);

         IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'x_return_status',
                                                     x_return_status);
                WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            --
            RETURN;
       END IF;
      END IF;

    IF (p_delivery_info.initial_pickup_location_id <> FND_API.G_MISS_NUM) OR (p_delivery_info.initial_pickup_location_code <> FND_API.G_MISS_CHAR) THEN

         IF (p_delivery_info.initial_pickup_location_code <> FND_API.G_MISS_CHAR) THEN
          p_delivery_info.initial_pickup_location_id := NULL;
       END IF;
         wsh_util_validate.validate_location(
         p_delivery_info.initial_pickup_location_id,
         p_delivery_info.initial_pickup_location_code,
         x_return_status);

         IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'x_return_status',
                                                              x_return_status);
                WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            --
            RETURN;
       END IF;
      END IF;

    IF (p_delivery_info.ultimate_dropoff_location_id <> FND_API.G_MISS_NUM) OR (p_delivery_info.ultimate_dropoff_location_code <> FND_API.G_MISS_CHAR) THEN

         IF (p_delivery_info.ultimate_dropoff_location_code <> FND_API.G_MISS_CHAR) THEN
          p_delivery_info.ultimate_dropoff_location_id := NULL;
       END IF;
         wsh_util_validate.validate_location(
         p_delivery_info.ultimate_dropoff_location_id,
         p_delivery_info.ultimate_dropoff_location_code,
         x_return_status);

         IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'x_return_status',
                                                           x_return_status);
                WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            --
            RETURN;
       END IF;
      END IF;

    IF (p_delivery_info.intmed_ship_to_location_id <> FND_API.G_MISS_NUM) OR (p_delivery_info.intmed_ship_to_location_code <> FND_API.G_MISS_CHAR) THEN

         IF (p_delivery_info.intmed_ship_to_location_code <> FND_API.G_MISS_CHAR) THEN
          p_delivery_info.intmed_ship_to_location_id := NULL;
       END IF;
         wsh_util_validate.validate_location(
         p_delivery_info.intmed_ship_to_location_id,
         p_delivery_info.intmed_ship_to_location_code,
         x_return_status);

         IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'x_return_status',
                                                           x_return_status);
                WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            --
            RETURN;
       END IF;
      END IF;

    IF (p_delivery_info.pooled_ship_to_location_id <> FND_API.G_MISS_NUM) OR (p_delivery_info.pooled_ship_to_location_code <> FND_API.G_MISS_CHAR) THEN

         IF (p_delivery_info.pooled_ship_to_location_code <> FND_API.G_MISS_CHAR) THEN
          p_delivery_info.pooled_ship_to_location_id := NULL;
       END IF;
         wsh_util_validate.validate_location(
         p_delivery_info.pooled_ship_to_location_id,
         p_delivery_info.pooled_ship_to_location_code,
         x_return_status);

         IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'x_return_status',
                                                           x_return_status);
                WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            --
            RETURN;
       END IF;
      END IF;

    IF (p_delivery_info.customer_id <> FND_API.G_MISS_NUM) OR (p_delivery_info.customer_number <> FND_API.G_MISS_CHAR) THEN

         IF (p_delivery_info.customer_number <> FND_API.G_MISS_CHAR) THEN
          p_delivery_info.customer_id := NULL;
       END IF;
         wsh_util_validate.validate_customer(
         p_delivery_info.customer_id,
         p_delivery_info.customer_number,
         x_return_status);

         IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'x_return_status',
                                                           x_return_status);
                WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            --
            RETURN;
       END IF;
      END IF;

    -- Carrier ID is not validated as it is not used...Ship method is used instead.

    IF (p_delivery_info.ship_method_code <> FND_API.G_MISS_CHAR) OR (p_delivery_info.ship_method_name <> FND_API.G_MISS_CHAR) THEN

         IF (p_delivery_info.ship_method_code <> FND_API.G_MISS_CHAR) THEN
          p_delivery_info.ship_method_name := NULL;
       END IF;
         wsh_util_validate.validate_ship_method(
         p_delivery_info.ship_method_code,
         p_delivery_info.ship_method_name,
         x_return_status);

         IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'x_return_status',
                                                           x_return_status);
                WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            --
            RETURN;
       END IF;
      END IF;

    IF (p_delivery_info.freight_terms_code <> FND_API.G_MISS_CHAR) OR (p_delivery_info.freight_terms_name <> FND_API.G_MISS_CHAR) THEN

         IF (p_delivery_info.freight_terms_name <> FND_API.G_MISS_CHAR) THEN
          p_delivery_info.freight_terms_name := NULL;
       END IF;
         wsh_util_validate.validate_freight_terms(
         p_delivery_info.freight_terms_code,
         p_delivery_info.freight_terms_name,
         x_return_status);

         IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'x_return_status',
                                                           x_return_status);
                WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            --
            RETURN;
       END IF;
      END IF;

    IF (p_delivery_info.fob_code <> FND_API.G_MISS_CHAR) OR (p_delivery_info.fob_name <> FND_API.G_MISS_CHAR) THEN

         IF (p_delivery_info.fob_name <> FND_API.G_MISS_CHAR) THEN
          p_delivery_info.fob_code := NULL;
       END IF;
         wsh_util_validate.validate_fob(
         p_delivery_info.fob_code,
         p_delivery_info.fob_name,
         x_return_status);

         IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'x_return_status',
                                                           x_return_status);
                WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            --
            RETURN;
       END IF;
      END IF;

    IF (p_delivery_info.fob_location_id <> FND_API.G_MISS_NUM) OR (p_delivery_info.fob_location_code <> FND_API.G_MISS_CHAR) THEN

         IF (p_delivery_info.fob_location_code <> FND_API.G_MISS_CHAR) THEN
          p_delivery_info.fob_location_id := NULL;
       END IF;
         wsh_util_validate.validate_location(
         p_delivery_info.fob_location_id,
         p_delivery_info.fob_location_code,
         x_return_status);

         IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'x_return_status',
                                                           x_return_status);
                WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            --
            RETURN;
       END IF;
      END IF;

    IF (p_delivery_info.weight_uom_code <> FND_API.G_MISS_CHAR) OR (p_delivery_info.weight_uom_desc <> FND_API.G_MISS_CHAR) THEN

         IF (p_delivery_info.weight_uom_desc <> FND_API.G_MISS_CHAR) THEN
          p_delivery_info.weight_uom_code := NULL;
       END IF;

         wsh_util_validate.validate_uom(
         'WEIGHT',
         p_delivery_info.organization_id,
         p_delivery_info.weight_uom_code,
         p_delivery_info.weight_uom_desc,
         x_return_status);

         IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'x_return_status',
                                                           x_return_status);
                WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            --
            RETURN;
       END IF;
      END IF;

    IF (p_delivery_info.volume_uom_code <> FND_API.G_MISS_CHAR) OR (p_delivery_info.volume_uom_desc <> FND_API.G_MISS_CHAR) THEN

         IF (p_delivery_info.volume_uom_desc <> FND_API.G_MISS_CHAR) THEN
          p_delivery_info.volume_uom_code := NULL;
       END IF;
         wsh_util_validate.validate_uom(
         'VOLUME',
         p_delivery_info.organization_id,
         p_delivery_info.volume_uom_code,
         p_delivery_info.volume_uom_desc,
         x_return_status);

         IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'x_return_status',
                                                           x_return_status);
                WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            --
            RETURN;
       END IF;
      END IF;

    IF (p_delivery_info.currency_code <> FND_API.G_MISS_CHAR) OR (p_delivery_info.currency_name <> FND_API.G_MISS_CHAR) THEN

         IF (p_delivery_info.currency_name <> FND_API.G_MISS_CHAR) THEN
          p_delivery_info.currency_code := NULL;
       END IF;
         --OTM R12, added parameter l_adjusted_amount
         wsh_util_validate.validate_currency(
            p_currency_code     => p_delivery_info.currency_code,
            p_currency_name     => p_delivery_info.currency_name,
            p_amount            => NULL,
            x_return_status     => x_return_status,
            x_adjusted_amount   => l_adjusted_amount);

         IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'x_return_status',
                                                           x_return_status);
                WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            --
            RETURN;
       END IF;
      END IF;

      --
      -- manifesting code changes
      -- disallow update of ship method or its components if the delivery is assigned to trip.
      --

      IF (p_delivery_info.ship_method_code <> FND_API.G_MISS_CHAR) OR (p_delivery_info.ship_method_code IS NULL) OR
         (p_delivery_info.carrier_id <> FND_API.G_MISS_NUM) OR (p_delivery_info.carrier_id IS NULL) OR
         (p_delivery_info.service_level  <> FND_API.G_MISS_CHAR) OR (p_delivery_info.service_level IS NULL) OR
         (p_delivery_info.mode_of_transport <> FND_API.G_MISS_CHAR) OR (p_delivery_info.mode_of_transport IS NULL) THEN

          l_assigned_to_trip := WSH_Delivery_Validations.Del_Assigned_To_Trip
                                         (p_delivery_id =>  p_delivery_info.delivery_id,
                                          x_return_status => x_return_status);

          IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'x_return_status',
                                                           x_return_status);
                WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            --
            RETURN;

          ELSIF l_assigned_to_trip = 'Y' THEN
             FND_MESSAGE.SET_NAME('WSH','WSH_DEL_ASSIGNED_ERROR');
             --
             IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'WSH_DEL_ASSIGNED_ERROR');
             END IF;
             --
             FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_delivery_info.delivery_id));
             x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
             wsh_util_core.add_message(x_return_status,l_module_name);
             IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'x_return_status',
                                                           x_return_status);
                 WSH_DEBUG_SV.pop(l_module_name);
             END IF;
             --
             RETURN;
          END IF;
       END IF;

  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  EXCEPTION
       WHEN others THEN
          wsh_util_core.default_handler('WSH_DELIVERIES_GRP.Validate_Delivery',l_module_name);
          x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
          END IF;
          --
  END Validate_Delivery;

-- The below procedue will be obsoleted after patchset I.

  PROCEDURE map_grp_to_pvt(
    p_pub_rec IN delivery_pub_rec_type,
    x_pvt_rec OUT NOCOPY  wsh_new_deliveries_pvt.delivery_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2)
  IS
    --
l_debug_on BOOLEAN;
    l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'MAP_GRP_TO_PVT';

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
      WSH_DEBUG_SV.push(l_module_name);
    END IF;
    x_return_status := wsh_util_core.g_ret_sts_success;
    --
    x_pvt_rec.DELIVERY_ID     := p_pub_rec.DELIVERY_ID;
    x_pvt_rec.NAME        := p_pub_rec.NAME;
    x_pvt_rec.DELIVERY_TYPE     := p_pub_rec.DELIVERY_TYPE;
    x_pvt_rec.LOADING_SEQUENCE      := p_pub_rec.LOADING_SEQUENCE;
    x_pvt_rec.LOADING_ORDER_FLAG    := p_pub_rec.LOADING_ORDER_FLAG;
    x_pvt_rec.LOADING_ORDER_DESC    := p_pub_rec.LOADING_ORDER_DESC;
    x_pvt_rec.INITIAL_PICKUP_DATE   := p_pub_rec.INITIAL_PICKUP_DATE;
    x_pvt_rec.INITIAL_PICKUP_LOCATION_ID  := p_pub_rec.INITIAL_PICKUP_LOCATION_ID;
    x_pvt_rec.INITIAL_PICKUP_LOCATION_CODE  := p_pub_rec.INITIAL_PICKUP_LOCATION_CODE;
    x_pvt_rec.ORGANIZATION_ID     := p_pub_rec.ORGANIZATION_ID;
    x_pvt_rec.ORGANIZATION_CODE     := p_pub_rec.ORGANIZATION_CODE;
    x_pvt_rec.ULTIMATE_DROPOFF_LOCATION_ID  := p_pub_rec.ULTIMATE_DROPOFF_LOCATION_ID;
    x_pvt_rec.ULTIMATE_DROPOFF_LOCATION_CODE  := p_pub_rec.ULTIMATE_DROPOFF_LOCATION_CODE;
    x_pvt_rec.ULTIMATE_DROPOFF_DATE   := p_pub_rec.ULTIMATE_DROPOFF_DATE;
    x_pvt_rec.CUSTOMER_ID     := p_pub_rec.CUSTOMER_ID;
    x_pvt_rec.CUSTOMER_NUMBER     := p_pub_rec.CUSTOMER_NUMBER;
    x_pvt_rec.INTMED_SHIP_TO_LOCATION_ID  := p_pub_rec.INTMED_SHIP_TO_LOCATION_ID;
    x_pvt_rec.INTMED_SHIP_TO_LOCATION_CODE  := p_pub_rec.INTMED_SHIP_TO_LOCATION_CODE;
    x_pvt_rec.POOLED_SHIP_TO_LOCATION_ID  := p_pub_rec.POOLED_SHIP_TO_LOCATION_ID;
    x_pvt_rec.POOLED_SHIP_TO_LOCATION_CODE  := p_pub_rec.POOLED_SHIP_TO_LOCATION_CODE;
    x_pvt_rec.CARRIER_ID      := p_pub_rec.CARRIER_ID;
    x_pvt_rec.CARRIER_CODE      := p_pub_rec.CARRIER_CODE;
    x_pvt_rec.SHIP_METHOD_CODE      := p_pub_rec.SHIP_METHOD_CODE;
    x_pvt_rec.SHIP_METHOD_NAME      := p_pub_rec.SHIP_METHOD_NAME;
    x_pvt_rec.FREIGHT_TERMS_CODE    := p_pub_rec.FREIGHT_TERMS_CODE;
    x_pvt_rec.FREIGHT_TERMS_NAME    := p_pub_rec.FREIGHT_TERMS_NAME;
    x_pvt_rec.FOB_CODE        := p_pub_rec.FOB_CODE;
    x_pvt_rec.FOB_NAME        := p_pub_rec.FOB_NAME;
    x_pvt_rec.FOB_LOCATION_ID     := p_pub_rec.FOB_LOCATION_ID;
    x_pvt_rec.FOB_LOCATION_CODE     := p_pub_rec.FOB_LOCATION_CODE;
    x_pvt_rec.WAYBILL       := p_pub_rec.WAYBILL;
    x_pvt_rec.DOCK_CODE       := p_pub_rec.DOCK_CODE;
    x_pvt_rec.ACCEPTANCE_FLAG     := p_pub_rec.ACCEPTANCE_FLAG;
    x_pvt_rec.ACCEPTED_BY     := p_pub_rec.ACCEPTED_BY;
    x_pvt_rec.ACCEPTED_DATE     := p_pub_rec.ACCEPTED_DATE;
    x_pvt_rec.ACKNOWLEDGED_BY     := p_pub_rec.ACKNOWLEDGED_BY;
    x_pvt_rec.CONFIRMED_BY      := p_pub_rec.CONFIRMED_BY;
    x_pvt_rec.CONFIRM_DATE      := p_pub_rec.CONFIRM_DATE;
    x_pvt_rec.ASN_DATE_SENT     := p_pub_rec.ASN_DATE_SENT;
    x_pvt_rec.ASN_STATUS_CODE     := p_pub_rec.ASN_STATUS_CODE;
    x_pvt_rec.ASN_SEQ_NUMBER      := p_pub_rec.ASN_SEQ_NUMBER;
    x_pvt_rec.GROSS_WEIGHT      := p_pub_rec.GROSS_WEIGHT;
    x_pvt_rec.NET_WEIGHT      := p_pub_rec.NET_WEIGHT;
    x_pvt_rec.WEIGHT_UOM_CODE     := p_pub_rec.WEIGHT_UOM_CODE;
    x_pvt_rec.WEIGHT_UOM_DESC     := p_pub_rec.WEIGHT_UOM_DESC;
    x_pvt_rec.VOLUME        := p_pub_rec.VOLUME;
    x_pvt_rec.VOLUME_UOM_CODE     := p_pub_rec.VOLUME_UOM_CODE;
    x_pvt_rec.VOLUME_UOM_DESC     := p_pub_rec.VOLUME_UOM_DESC;
    x_pvt_rec.ADDITIONAL_SHIPMENT_INFO    := p_pub_rec.ADDITIONAL_SHIPMENT_INFO;
    x_pvt_rec.CURRENCY_CODE     := p_pub_rec.CURRENCY_CODE;
    x_pvt_rec.CURRENCY_NAME     := p_pub_rec.CURRENCY_NAME;
    x_pvt_rec.ATTRIBUTE_CATEGORY    := p_pub_rec.ATTRIBUTE_CATEGORY;
    x_pvt_rec.ATTRIBUTE1      := p_pub_rec.ATTRIBUTE1;
    x_pvt_rec.ATTRIBUTE2      := p_pub_rec.ATTRIBUTE2;
    x_pvt_rec.ATTRIBUTE3      := p_pub_rec.ATTRIBUTE3;
    x_pvt_rec.ATTRIBUTE4      := p_pub_rec.ATTRIBUTE4;
    x_pvt_rec.ATTRIBUTE5      := p_pub_rec.ATTRIBUTE5;
    x_pvt_rec.ATTRIBUTE6      := p_pub_rec.ATTRIBUTE6;
    x_pvt_rec.ATTRIBUTE7      := p_pub_rec.ATTRIBUTE7;
    x_pvt_rec.ATTRIBUTE8      := p_pub_rec.ATTRIBUTE8;
    x_pvt_rec.ATTRIBUTE9      := p_pub_rec.ATTRIBUTE9;
    x_pvt_rec.ATTRIBUTE10     := p_pub_rec.ATTRIBUTE10;
    x_pvt_rec.ATTRIBUTE11     := p_pub_rec.ATTRIBUTE11;
    x_pvt_rec.ATTRIBUTE12     := p_pub_rec.ATTRIBUTE12;
    x_pvt_rec.ATTRIBUTE13     := p_pub_rec.ATTRIBUTE13;
    x_pvt_rec.ATTRIBUTE14     := p_pub_rec.ATTRIBUTE14;
    x_pvt_rec.ATTRIBUTE15     := p_pub_rec.ATTRIBUTE15;
    x_pvt_rec.TP_ATTRIBUTE_CATEGORY   := p_pub_rec.TP_ATTRIBUTE_CATEGORY;
    x_pvt_rec.TP_ATTRIBUTE1     := p_pub_rec.TP_ATTRIBUTE1;
    x_pvt_rec.TP_ATTRIBUTE2     := p_pub_rec.TP_ATTRIBUTE2;
    x_pvt_rec.TP_ATTRIBUTE3     := p_pub_rec.TP_ATTRIBUTE3;
    x_pvt_rec.TP_ATTRIBUTE4     := p_pub_rec.TP_ATTRIBUTE4;
    x_pvt_rec.TP_ATTRIBUTE5     := p_pub_rec.TP_ATTRIBUTE5;
    x_pvt_rec.TP_ATTRIBUTE6     := p_pub_rec.TP_ATTRIBUTE6;
    x_pvt_rec.TP_ATTRIBUTE7     := p_pub_rec.TP_ATTRIBUTE7;
    x_pvt_rec.TP_ATTRIBUTE8     := p_pub_rec.TP_ATTRIBUTE8;
    x_pvt_rec.TP_ATTRIBUTE9     := p_pub_rec.TP_ATTRIBUTE9;
    x_pvt_rec.TP_ATTRIBUTE10      := p_pub_rec.TP_ATTRIBUTE10;
    x_pvt_rec.TP_ATTRIBUTE11      := p_pub_rec.TP_ATTRIBUTE11;
    x_pvt_rec.TP_ATTRIBUTE12      := p_pub_rec.TP_ATTRIBUTE12;
    x_pvt_rec.TP_ATTRIBUTE13      := p_pub_rec.TP_ATTRIBUTE13;
    x_pvt_rec.TP_ATTRIBUTE14      := p_pub_rec.TP_ATTRIBUTE14;
    x_pvt_rec.TP_ATTRIBUTE15      := p_pub_rec.TP_ATTRIBUTE15;
    x_pvt_rec.GLOBAL_ATTRIBUTE_CATEGORY   := p_pub_rec.GLOBAL_ATTRIBUTE_CATEGORY;
    x_pvt_rec.GLOBAL_ATTRIBUTE1     := p_pub_rec.GLOBAL_ATTRIBUTE1;
    x_pvt_rec.GLOBAL_ATTRIBUTE2     := p_pub_rec.GLOBAL_ATTRIBUTE2;
    x_pvt_rec.GLOBAL_ATTRIBUTE3     := p_pub_rec.GLOBAL_ATTRIBUTE3;
    x_pvt_rec.GLOBAL_ATTRIBUTE4     := p_pub_rec.GLOBAL_ATTRIBUTE4;
    x_pvt_rec.GLOBAL_ATTRIBUTE5     := p_pub_rec.GLOBAL_ATTRIBUTE5;
    x_pvt_rec.GLOBAL_ATTRIBUTE6     := p_pub_rec.GLOBAL_ATTRIBUTE6;
    x_pvt_rec.GLOBAL_ATTRIBUTE7     := p_pub_rec.GLOBAL_ATTRIBUTE7;
    x_pvt_rec.GLOBAL_ATTRIBUTE8     := p_pub_rec.GLOBAL_ATTRIBUTE8;
    x_pvt_rec.GLOBAL_ATTRIBUTE9     := p_pub_rec.GLOBAL_ATTRIBUTE9;
    x_pvt_rec.GLOBAL_ATTRIBUTE10    := p_pub_rec.GLOBAL_ATTRIBUTE10;
    x_pvt_rec.GLOBAL_ATTRIBUTE11    := p_pub_rec.GLOBAL_ATTRIBUTE11;
    x_pvt_rec.GLOBAL_ATTRIBUTE12    := p_pub_rec.GLOBAL_ATTRIBUTE12;
    x_pvt_rec.GLOBAL_ATTRIBUTE13    := p_pub_rec.GLOBAL_ATTRIBUTE13;
    x_pvt_rec.GLOBAL_ATTRIBUTE14    := p_pub_rec.GLOBAL_ATTRIBUTE14;
    x_pvt_rec.GLOBAL_ATTRIBUTE15    := p_pub_rec.GLOBAL_ATTRIBUTE15;
    x_pvt_rec.GLOBAL_ATTRIBUTE16    := p_pub_rec.GLOBAL_ATTRIBUTE16;
    x_pvt_rec.GLOBAL_ATTRIBUTE17    := p_pub_rec.GLOBAL_ATTRIBUTE17;
    x_pvt_rec.GLOBAL_ATTRIBUTE18    := p_pub_rec.GLOBAL_ATTRIBUTE18;
    x_pvt_rec.GLOBAL_ATTRIBUTE19    := p_pub_rec.GLOBAL_ATTRIBUTE19;
    x_pvt_rec.GLOBAL_ATTRIBUTE20    := p_pub_rec.GLOBAL_ATTRIBUTE20;
    x_pvt_rec.CREATION_DATE     := p_pub_rec.CREATION_DATE;
    x_pvt_rec.CREATED_BY      := p_pub_rec.CREATED_BY;
    x_pvt_rec.LAST_UPDATE_DATE      := p_pub_rec.LAST_UPDATE_DATE;
    x_pvt_rec.LAST_UPDATED_BY     := p_pub_rec.LAST_UPDATED_BY;
    x_pvt_rec.LAST_UPDATE_LOGIN     := p_pub_rec.LAST_UPDATE_LOGIN;
    x_pvt_rec.PROGRAM_APPLICATION_ID    := p_pub_rec.PROGRAM_APPLICATION_ID;
    x_pvt_rec.PROGRAM_ID      := p_pub_rec.PROGRAM_ID;
    x_pvt_rec.PROGRAM_UPDATE_DATE   := p_pub_rec.PROGRAM_UPDATE_DATE;
    x_pvt_rec.REQUEST_ID      := p_pub_rec.REQUEST_ID;
    x_pvt_rec.COD_AMOUNT      := p_pub_rec.COD_AMOUNT;
    x_pvt_rec.COD_CURRENCY_CODE     := p_pub_rec.COD_CURRENCY_CODE;
    x_pvt_rec.COD_REMIT_TO      := p_pub_rec.COD_REMIT_TO;
    x_pvt_rec.COD_CHARGE_PAID_BY    := p_pub_rec.COD_CHARGE_PAID_BY;
    x_pvt_rec.PROBLEM_CONTACT_REFERENCE   := p_pub_rec.PROBLEM_CONTACT_REFERENCE;
    x_pvt_rec.PORT_OF_LOADING     := p_pub_rec.PORT_OF_LOADING;
    x_pvt_rec.PORT_OF_DISCHARGE     := p_pub_rec.PORT_OF_DISCHARGE;
    x_pvt_rec.FTZ_NUMBER      := p_pub_rec.FTZ_NUMBER;
    x_pvt_rec.ROUTED_EXPORT_TXN     := p_pub_rec.ROUTED_EXPORT_TXN;
    x_pvt_rec.ENTRY_NUMBER      := p_pub_rec.ENTRY_NUMBER;
    x_pvt_rec.ROUTING_INSTRUCTIONS    := p_pub_rec.ROUTING_INSTRUCTIONS;
    x_pvt_rec.IN_BOND_CODE      := p_pub_rec.IN_BOND_CODE;
    x_pvt_rec.SHIPPING_MARKS      := p_pub_rec.SHIPPING_MARKS;
    x_pvt_rec.SERVICE_LEVEL     := p_pub_rec.SERVICE_LEVEL;
    x_pvt_rec.MODE_OF_TRANSPORT     := p_pub_rec.MODE_OF_TRANSPORT;
    x_pvt_rec.ASSIGNED_TO_FTE_TRIPS   := p_pub_rec.ASSIGNED_TO_FTE_TRIPS;
    x_pvt_rec.PLANNED_FLAG              := FND_API.G_MISS_CHAR;
    x_pvt_rec.STATUS_CODE               := FND_API.G_MISS_CHAR;
    x_pvt_rec.BATCH_ID                  := FND_API.G_MISS_NUM;
    x_pvt_rec.HASH_VALUE                := FND_API.G_MISS_NUM;
    x_pvt_rec.SOURCE_HEADER_ID          := FND_API.G_MISS_NUM;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_DELIVERIES_GRP.map_grp_pvt',l_module_name);
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
  END map_grp_to_pvt;

-- The below procedue will be obsoleted after patchset I.
--========================================================================
-- PROCEDURE : Create_Update_Delivery         PUBLIC
--
-- PARAMETERS: p_api_version_number    known api versionerror buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--         p_delivery_info         Attributes for the delivery entity
--             p_delivery_name         Delivery name for update
--              x_delivery_id - delivery_Id of new delivery,
--             x_name - Name of delivery
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Creates or updates a record in wsh_new_deliveries table
--             with information specified in p_delivery_info
--========================================================================

  PROCEDURE Create_Update_Delivery(
    p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2,
    p_action_code            IN   VARCHAR2,
    p_delivery_info           IN OUT NOCOPY  Delivery_Pub_Rec_Type,
    p_delivery_name          IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
    x_delivery_id            OUT NOCOPY   NUMBER,
    x_name                   OUT NOCOPY   VARCHAR2)

  IS

  l_api_version_number CONSTANT NUMBER := 1.0;
  l_api_name           CONSTANT VARCHAR2(30):= 'Create_Update_Delivery';

  -- <insert here your local variables declaration>
  l_message VARCHAR2(50);
  l_num_errors NUMBER;
  l_num_warnings NUMBER;
  l_rec_attr_tab      wsh_new_deliveries_pvt.delivery_attr_tbl_type;
  l_delivery_in_rec   Del_In_Rec_Type;
  l_del_out_rec_tab   Del_Out_Tbl_Type;
  l_return_status     VARCHAR2(1);
  l_commit            VARCHAR2(100) := FND_API.G_FALSE;
    --
l_debug_on BOOLEAN;
    --
    l_module_name CONSTANT   VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_UPDATE_DELIVERY';


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
    IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name);
    END IF;
  -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call
      ( l_api_version_number
      , p_api_version_number
      , l_api_name
      , G_PKG_NAME
      )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize message stack if required
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;


    IF (p_action_code = 'UPDATE') THEN
      IF (p_delivery_name IS NOT NULL) OR (p_delivery_name <> FND_API.G_MISS_CHAR) THEN
        p_delivery_info.name := p_delivery_name;
      END IF;
    ELSIF ( p_action_code <> 'CREATE' ) THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_ACTION_CODE');
      FND_MESSAGE.SET_TOKEN('ACTION_CODE',p_action_code);
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      wsh_util_core.add_message(x_return_status);
    END IF;
    --
    map_grp_to_pvt(
      p_pub_rec  => p_delivery_info,
      x_pvt_rec  => l_rec_attr_tab(1),
      x_return_status => l_return_status);
    --
    IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name,'Return Status After Calling map_grp_to_pvt',l_return_status);
    END IF;
    --
    wsh_util_core.api_post_call(
      p_return_status => l_return_status,
      x_num_errors    => l_num_errors,
      x_num_warnings  => l_num_warnings);
    --
    l_delivery_in_rec.action_code := p_action_code;
    l_delivery_in_rec.caller := 'WSH_GRP';
    wsh_interface_grp.create_update_delivery(
      p_api_version_number     =>  p_api_version_number,
      p_init_msg_list          =>  p_init_msg_list,
      p_commit                 =>  l_commit,
      p_in_rec                 =>  l_delivery_in_rec,
      p_rec_attr_tab           =>  l_rec_attr_tab,
      x_del_out_rec_tab        =>  l_del_out_rec_tab,
      x_return_status          =>  l_return_status,
      x_msg_count              =>  x_msg_count,
      x_msg_data               =>  x_msg_data);
    --
    IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name,'Return Status After Calling create_update_delivery',l_return_status);
    END IF;
    --
    wsh_util_core.api_post_call(
      p_return_status => l_return_status,
      x_num_errors    => l_num_errors,
      x_num_warnings  => l_num_warnings,
      p_msg_data      => x_msg_data);
    --
    IF l_del_out_rec_tab.COUNT <> 0 THEN
      --
      x_delivery_id    := l_del_out_rec_tab(l_del_out_rec_tab.COUNT).delivery_id;
      x_name           := l_del_out_rec_tab(l_del_out_rec_tab.COUNT).name;
      --
    END IF;
    --
    IF l_num_warnings > 0 THEN
      x_return_status := wsh_util_core.g_ret_sts_warning;
    ELSE
      x_return_status := wsh_util_core.g_ret_sts_success; --bug 2398628
    END IF;
    --
    FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count
     , p_data  => x_msg_data
     ,  p_encoded => FND_API.G_FALSE
     );
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        ( p_count => x_msg_count
        , p_data  => x_msg_data
        , p_encoded => FND_API.G_FALSE
        );
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        ( p_count => x_msg_count
        , p_data  => x_msg_data
        , p_encoded => FND_API.G_FALSE
        );
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
     WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
           FND_MSG_PUB.Add_Exc_Msg
           ( G_PKG_NAME
           , '_x_'
           );
        END IF;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        ( p_count => x_msg_count
        , p_data  => x_msg_data
        , p_encoded => FND_API.G_FALSE
        );
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
  END Create_Update_Delivery;

-- The below procedue will be obsoleted after patchset I.
--========================================================================
-- PROCEDURE : Delivery_Action         PUBLIC
--
-- PARAMETERS: p_api_version_number    known api version error number
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_action_code           Delivery action code. Valid action codes are
--                                     'PLAN','UNPLAN',
--                                     'PACK','CONFIRM','RE-OPEN','IN-TRANSIT','CLOSE'
--                                     'ASSIGN-TRIP','UNASSIGN-TRIP','AUTOCREATE-TRIP'
--                                     'WT-VOL',
--                                     'PICK-RELEASE',
--                                     'DELETE'
--             p_delivery_id           Delivery identifier
--             p_delivery_name         Delivery name
--             p_asg_trip_id           Trip identifier for assignment
--             p_asg_trip_name         Trip name for assignment
--             p_asg_pickup_stop_id    Stop id for pickup assignment
--             p_asg_pickup_loc_id     Stop location for pickup assignment
--             p_asg_pickup_loc_code   Stop location code for pickup assignment
--             p_asg_pickup_arr_date   Stop location arrival date for pickup assignment
--             p_asg_pickup_dep_date   Stop location departure date for pickup assignment
--             p_asg_dropoff_stop_id   Stop id for dropoff assignment
--             p_asg_dropoff_loc_id    Stop location for dropoff assignment
--             p_asg_dropoff_loc_code  Stop location code for dropoff assignment
--             p_asg_dropoff_arr_date  Stop location arrival date for dropoff assignment
--             p_asg_dropoff_dep_date  Stop location departure date for dropoff assignment
--             p_sc_action_flag        Ship Confirm option - 'S', 'B', 'T', 'A', 'C'
--             p_sc_intransit_flag     Ship Confirm set in-transit flag
--             p_sc_close_trip_flag    Ship Confirm close trip flag
--             p_sc_create_bol_flag    Ship Confirm create BOL flag
--             p_sc_stage_del_flag     Ship Confirm create delivery for stage qnt flag
--             p_sc_trip_ship_method   Ship Confirm trip ship method
--             p_sc_actual_dep_date    Ship Confirm actual departure date
--             p_sc_report_set_id      Ship Confirm report set id
--             p_sc_report_set_name    Ship Confirm report set name
--             p_wv_override_flag      Override flag for weight/volume calc
--             x_trip_rows             Autocreated trip ids
--
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This procedure is used to perform an action specified in p_action_code
--             on an existing delivery identified by p_delivery_id/p_delivery_name.
--========================================================================
  PROCEDURE Delivery_Action
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2,
    p_action_code            IN   VARCHAR2,
    p_delivery_id            IN   NUMBER DEFAULT NULL,
    p_delivery_name          IN   VARCHAR2 DEFAULT NULL,
    p_asg_trip_id            IN   NUMBER DEFAULT NULL,
    p_asg_trip_name          IN   VARCHAR2 DEFAULT NULL,
    p_asg_pickup_stop_id     IN   NUMBER DEFAULT NULL,
    p_asg_pickup_loc_id      IN   NUMBER DEFAULT NULL,
    p_asg_pickup_stop_seq    IN   NUMBER DEFAULT NULL,
    p_asg_pickup_loc_code    IN   VARCHAR2 DEFAULT NULL,
    p_asg_pickup_arr_date    IN   DATE   DEFAULT NULL,
    p_asg_pickup_dep_date    IN   DATE   DEFAULT NULL,
    p_asg_dropoff_stop_id    IN   NUMBER DEFAULT NULL,
    p_asg_dropoff_loc_id     IN   NUMBER DEFAULT NULL,
    p_asg_dropoff_stop_seq   IN   NUMBER DEFAULT NULL,
    p_asg_dropoff_loc_code   IN   VARCHAR2 DEFAULT NULL,
    p_asg_dropoff_arr_date   IN   DATE   DEFAULT NULL,
    p_asg_dropoff_dep_date   IN   DATE   DEFAULT NULL,
    p_sc_action_flag         IN   VARCHAR2 DEFAULT 'S',
    p_sc_intransit_flag      IN   VARCHAR2 DEFAULT 'N',
    p_sc_close_trip_flag     IN   VARCHAR2 DEFAULT 'N',
    p_sc_create_bol_flag     IN   VARCHAR2 DEFAULT 'N',
    p_sc_stage_del_flag      IN   VARCHAR2 DEFAULT 'Y',
    p_sc_trip_ship_method    IN   VARCHAR2 DEFAULT NULL,
    p_sc_actual_dep_date     IN   DATE     DEFAULT NULL,
    p_sc_report_set_id       IN   NUMBER DEFAULT NULL,
    p_sc_report_set_name     IN   VARCHAR2 DEFAULT NULL,
    p_sc_defer_interface_flag IN  VARCHAR2 DEFAULT 'Y',
    p_sc_send_945_flag       IN   VARCHAR2 DEFAULT NULL,
    p_wv_override_flag       IN   VARCHAR2 DEFAULT 'N',
    x_trip_rows              OUT  NOCOPY WSH_UTIL_CORE.id_tab_type)
    --
  IS
    --
    l_api_version_number CONSTANT NUMBER := 1.0;
    l_api_name           CONSTANT VARCHAR2(30):= 'Delivery_Action';
    --
l_debug_on BOOLEAN;
    --
    l_module_name CONSTANT   VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELIVERY_ACTION';
    --
    --
    l_action_prms wsh_deliveries_grp.action_parameters_rectype;
    l_del_action_out_rec wsh_deliveries_grp.Delivery_Action_Out_Rec_Type;
    l_delivery_id_tab    wsh_util_core.id_tab_type;
    --
    l_delivery_id  NUMBER := p_delivery_id;
    --
    l_num_errors   NUMBER := 0;
    l_num_warnings NUMBER := 0;
    l_commit            VARCHAR2(100) := FND_API.G_FALSE;
    --
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
    IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name);
    END IF;
    --
  -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call
      ( l_api_version_number
      , p_api_version_number
      , l_api_name
      , G_PKG_NAME
      )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize message stack if required
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

   wsh_util_validate.validate_delivery_name(
     p_delivery_id   => l_delivery_id,
     p_delivery_name => p_delivery_name,
     x_return_status => x_return_status);
    --
    IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_delivery_name',x_return_status);
    END IF;
    --
    wsh_util_core.api_post_call(
      p_return_status => x_return_status,
      x_num_errors    => l_num_errors,
      x_num_warnings  => l_num_warnings);
    --
    l_action_prms.caller    := 'WSH_GRP';
    l_action_prms.action_code     := p_action_code;
    --
    -- initializing the action specific parameters
    l_action_prms.trip_id   := p_asg_trip_id;
    l_action_prms.trip_name   := p_asg_trip_name;
    l_action_prms.pickup_stop_id  := p_asg_pickup_stop_id;
    l_action_prms.pickup_loc_id   := p_asg_pickup_loc_id;
    l_action_prms.pickup_stop_seq := p_asg_pickup_stop_seq;
    l_action_prms.pickup_loc_code := p_asg_pickup_loc_code;
    l_action_prms.pickup_arr_date := p_asg_pickup_arr_date;
    l_action_prms.pickup_dep_date := p_asg_pickup_dep_date;
    l_action_prms.dropoff_stop_id := p_asg_dropoff_stop_id;
    l_action_prms.dropoff_loc_id  := p_asg_dropoff_loc_id;
    l_action_prms.dropoff_stop_seq  := p_asg_dropoff_stop_seq;
    l_action_prms.dropoff_loc_code  := p_asg_dropoff_loc_code;
    l_action_prms.dropoff_arr_date  := p_asg_dropoff_arr_date;
    l_action_prms.dropoff_dep_date  := p_asg_dropoff_dep_date;
    l_action_prms.action_flag     := p_sc_action_flag;
    l_action_prms.intransit_flag  := p_sc_intransit_flag;
    l_action_prms.close_trip_flag     := p_sc_close_trip_flag;
    l_action_prms.bill_of_lading_flag     := p_sc_create_bol_flag;
    l_action_prms.stage_del_flag      := p_sc_stage_del_flag;
    l_action_prms.ship_method_code    := p_sc_trip_ship_method;
    l_action_prms.actual_dep_date     := p_sc_actual_dep_date;
    l_action_prms.report_set_id   := p_sc_report_set_id;
    l_action_prms.report_set_name := p_sc_report_set_name;
    l_action_prms.defer_interface_flag  := p_sc_defer_interface_flag;
    l_action_prms.send_945_flag   := p_sc_send_945_flag;
    l_action_prms.override_flag   := p_wv_override_flag;
    --
    l_delivery_id_tab(1)    := l_delivery_id;
    --
    wsh_interface_grp.Delivery_Action(
      p_api_version_number     =>  p_api_version_number,
      p_init_msg_list          =>  p_init_msg_list,
      p_commit                 =>  l_commit,
      p_action_prms            =>  l_action_prms,
      p_delivery_id_tab        =>  l_delivery_id_tab,
      x_delivery_out_rec       =>  l_del_action_out_rec,
      x_return_status          =>  x_return_status,
      x_msg_count              =>  x_msg_count,
      x_msg_data               =>  x_msg_data);
    --
    IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name,'Return Status After Calling Delivery_Action',x_return_status);
    END IF;
    --
    wsh_util_core.api_post_call(
      p_return_status => x_return_status,
      x_num_errors    => l_num_errors,
      x_num_warnings  => l_num_warnings,
      p_msg_data      => x_msg_data);
    --
    IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name,'Number of Warnings is ',l_num_warnings);
      wsh_debug_sv.log(l_module_name,'Number of Errors is ',l_num_errors);
    END IF;
    --
    x_trip_rows      := l_del_action_out_rec.result_id_tab;

    --
    IF l_num_warnings > 0 THEN
      x_return_status := wsh_util_core.g_ret_sts_warning;
    ELSE
      x_return_status := wsh_util_core.g_ret_sts_success; --bug 2398628
    END IF;
    --
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count
      , p_data  => x_msg_data
      , p_encoded => FND_API.G_FALSE
      );
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        ( p_count => x_msg_count
        , p_data  => x_msg_data
        , p_encoded => FND_API.G_FALSE
        );
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        ( p_count => x_msg_count
        , p_data  => x_msg_data
        , p_encoded => FND_API.G_FALSE
        );
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
     WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
           FND_MSG_PUB.Add_Exc_Msg
           ( G_PKG_NAME
           , '_x_'
           );
        END IF;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        ( p_count => x_msg_count
        , p_data  => x_msg_data
        , p_encoded => FND_API.G_FALSE
        );
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --

  END Delivery_Action;

/*    ---------------------------------------------------------------------
    Procedure: Lock_Related_Entities

    Parameters:

    Description:  This procedure is the new API for locking the related entities
                  like STOP or TRIP, depending on the action.

    Created :   Patchset I
    ----------------------------------------------------------------------- */

PROCEDURE Lock_Related_Entities(
         p_rec_attr_tab     IN  WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type,
         p_action_prms      IN  action_parameters_rectype,
         x_valid_ids_tab    OUT NOCOPY WSH_UTIL_CORE.ID_TAB_TYPE,
         x_return_status    OUT NOCOPY VARCHAR2
          ) IS

  l_index   NUMBER;
  l_stop_index NUMBER;
  l_stop_rows wsh_util_core.id_tab_type;
  l_min_stop_seq NUMBER;
  l_max_stop_seq NUMBER;
  l_stop_seq     NUMBER;
  l_trip_id      NUMBER;
  l_dlvy_name    VARCHAR2(30);
  k      NUMBER := 0;

  CURSOR c_delivery_leg_stops(p_delivery_id NUMBER) IS
  SELECT dg.pick_up_stop_id,
     pu_stop.status_code  pu_status,
   dg.drop_off_stop_id,
     do_stop.status_code  do_status
  FROM   wsh_delivery_legs dg,
     wsh_trip_stops pu_stop,
     wsh_trip_stops do_stop
  WHERE  dg.delivery_id = p_delivery_id
  AND pu_stop.stop_id = dg.pick_up_stop_id
  AND do_stop.stop_id = dg.drop_off_stop_id;

  CURSOR c_stop_info(p_stop_id NUMBER) IS
  SELECT stop_sequence_number, trip_id
  FROM wsh_trip_stops
  WHERE stop_id = p_stop_id;
  --
  CURSOR c_min_max_seq(p_trip_id NUMBER) IS
  SELECT min(stop_sequence_number), max(stop_sequence_number)
  FROM wsh_trip_stops
  WHERE trip_id = p_trip_id;

  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_RELATED_ENTITIES';
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
      x_return_status := wsh_util_core.g_ret_sts_success;

        IF l_debug_on THEN
            WSH_DEBUG_SV.push(l_module_name);
            --
            WSH_DEBUG_SV.log(l_module_name, 'Action Code', p_action_prms.action_code);
            WSH_DEBUG_SV.log(l_module_name,'Input Table count', p_rec_attr_tab.count);
        END IF;

     l_index := p_rec_attr_tab.first;
     while l_index is not null
     loop
     -- {
         BEGIN
            SAVEPOINT lock_rel_ent_loop;
            k := 0;
            l_stop_rows.delete;

            IF p_rec_attr_tab(l_index).name is null
            THEN
               l_dlvy_name := wsh_new_deliveries_pvt.get_name(p_rec_attr_tab(l_index).delivery_id);
            ELSE
               l_dlvy_name := p_rec_attr_tab(l_index).name;
            END IF;

            FOR c_leg_rec IN c_delivery_leg_stops(p_rec_attr_tab(l_index).delivery_id)
            LOOP
            -- {
               IF c_leg_rec.pu_status <> 'CL' THEN
                  k:=k+1;  l_stop_rows(k) := c_leg_rec.pick_up_stop_id;
               END IF;
               IF c_leg_rec.do_status <> 'CL' THEN
                  k:=k+1;  l_stop_rows(k) := c_leg_rec.drop_off_stop_id;
               END IF;
            -- }
            END LOOP;

            l_stop_index := l_stop_rows.first;
            WHILE l_stop_index IS NOT NULL
            LOOP
            -- {
                IF l_debug_on THEN
                   wsh_debug_sv.log(l_module_name, 'call lock for stop', l_stop_rows(l_stop_index));
                END IF;
                -- First lock the stop
                wsh_trip_stops_pvt.lock_trip_stop_no_compare(
                        p_stop_id => l_stop_rows(l_stop_index)
                    );

                OPEN c_stop_info(l_stop_rows(l_stop_index));
                FETCH c_stop_info
                INTO l_stop_seq, l_trip_id;
                CLOSE c_stop_info;

                OPEN c_min_max_seq(l_trip_id);
                FETCH c_min_max_seq
                INTO  l_min_stop_seq, l_max_stop_seq;
                CLOSE c_min_max_seq;

                IF l_debug_on THEN
                      wsh_debug_sv.log(l_module_name, 'Min stop seq', l_min_stop_seq);
                      wsh_debug_sv.log(l_module_name, 'Max stop seq', l_max_stop_seq);
                      wsh_debug_sv.log(l_module_name, 'Stop seq', l_stop_seq);
                      wsh_debug_sv.log(l_module_name, 'Trip Id', l_trip_id);
                END IF;

                IF l_stop_seq = l_min_stop_seq
                     OR l_stop_seq = l_max_stop_seq
                THEN
                -- {
                      wsh_trips_pvt.lock_trip_no_compare(
                        p_trip_id => l_trip_id
                        );
                -- }
                END IF;
                --
                l_stop_index := l_stop_rows.next(l_stop_index);
            -- }
            END LOOP;

               x_valid_ids_tab(x_valid_ids_tab.COUNT + 1) := p_rec_attr_tab(l_index).delivery_id;

        EXCEPTION
          WHEN app_exception.application_exception or app_exception.record_lock_exception THEN
             ROLLBACK TO lock_rel_ent_loop;
             IF l_debug_on THEN
                wsh_debug_sv.log(l_module_name, 'Could not obtain lock of stop or trip for delivery', p_rec_attr_tab(l_index).delivery_id);
             END IF;
             FND_MESSAGE.SET_NAME('WSH', 'WSH_DLVY_STOP_TRIP_LOCK');
             FND_MESSAGE.SET_TOKEN('DLVY_NAME',l_dlvy_name);
               wsh_util_core.add_message(wsh_util_core.g_ret_sts_error,l_module_name);
                      --
         --
          WHEN others THEN
             IF l_debug_on THEN
                wsh_debug_sv.logmsg(l_module_name, 'When others in local block');
             END IF;
             ROLLBACK TO lock_rel_ent_loop;
             raise FND_API.G_EXC_UNEXPECTED_ERROR;

        END;
        l_index := p_rec_attr_tab.next(l_index);
     -- }
     end loop;

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'Valid ids tab count', x_valid_ids_tab.count);
      END IF;
      -- Check for valid_ids_tab count.
      -- If valid ids count > 0 ,but less than the input table count, then return warning
      -- If valid ids count = 0, then return error
      IF p_rec_attr_tab.count > 0
      THEN
      -- {
             IF x_valid_ids_tab.count = 0
             THEN
             -- {
                 RAISE FND_API.G_EXC_ERROR;
             ELSIF x_valid_ids_tab.count >0
               AND x_valid_ids_tab.count < p_rec_attr_tab.count
             THEN
                 RAISE WSH_UTIL_CORE.G_EXC_WARNING;
             -- }
            END IF;
      -- }
      END IF;

      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                x_return_status := FND_API.G_RET_STS_ERROR ;
                  --
                  IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
                  END IF;
                  --
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
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
            WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
       END IF;
--
        WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          WSH_UTIL_CORE.default_handler('WSH_DELIVERIES_GRP.Lock_Related_Entities');
          IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
             WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
          END IF;

    --

END Lock_Related_Entities;

--========================================================================
-- PROCEDURE : Get_Delivery_Status    PUBLIC
--
-- PARAMETERS:
--     p_api_version_number  known api version error number
--     p_init_msg_list       FND_API.G_TRUE to reset list
--     p_entity_type         either DELIVERY/DELIVERY DETAIL/LPN
--     p_entity_id           either delivery_id/delivery_detail_id/lpn_id
--     x_status_code         Status of delivery for the entity_type and
--                           entity id passed
--     x_return_status       return status
--     x_msg_count           number of messages in the list
--     x_msg_data            text of messages
--========================================================================
-- API added for bug 4632726
PROCEDURE Get_Delivery_Status (
          p_api_version_number   IN   NUMBER,
          p_init_msg_list        IN   VARCHAR2,
          p_entity_type          IN   VARCHAR2,
          p_entity_id            IN   NUMBER,
          x_status_code          OUT NOCOPY   VARCHAR2,
          x_return_status        OUT NOCOPY   VARCHAR2,
          x_msg_count            OUT NOCOPY   NUMBER,
          x_msg_data             OUT NOCOPY   VARCHAR2 )
IS
    --
    l_api_version_number CONSTANT NUMBER := 1.0;
    l_api_name           CONSTANT VARCHAR2(30):= 'Get_Delivery_Status';

    l_num_errors         NUMBER;
    l_num_warnings       NUMBER;
    l_return_status      VARCHAR2(1);
    --
    l_debug_on BOOLEAN;
    --
    l_module_name CONSTANT   VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_DELIVERY_STATUS';
    --
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
    IF l_debug_on THEN
        wsh_debug_sv.push(l_module_name);
        wsh_debug_sv.log (l_module_name, 'Entity Type', p_entity_type );
        wsh_debug_sv.log (l_module_name, 'Entity Id', p_entity_id );
    END IF;
    --
    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call
      ( l_api_version_number
      , p_api_version_number
      , l_api_name
      , G_PKG_NAME
      )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --

    IF ( p_entity_type is null or p_entity_id is null ) THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
      IF ( p_entity_type is null ) THEN
          FND_MESSAGE.SET_TOKEN('FIELD_NAME', 'P_ENTITY_TYPE');
      ELSIF ( p_entity_id is null ) THEN
          FND_MESSAGE.SET_TOKEN('FIELD_NAME', 'P_ENTITY_ID');
      END IF;
      x_return_status := wsh_util_core.g_ret_sts_error;
      wsh_util_core.add_message(x_return_status, l_module_name);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    --
    IF l_debug_on THEN
        wsh_debug_sv.logmsg(l_module_name, 'Calling Get_Delivery_Status', WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    WSH_UTIL_CORE.Get_Delivery_Status (
                  p_entity_type    =>  p_entity_type,
                  p_entity_id      =>  p_entity_id,
                  x_status_code    =>  x_status_code,
                  x_return_status  =>  l_return_status );
    --
    IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name, 'Return Status after Calling Get_Delivery_Status', l_return_status);
    END IF;
    --
    WSH_UTIL_CORE.api_post_call(
      p_return_status     => l_return_status,
      x_num_warnings      => l_num_warnings,
      x_num_errors        => l_num_errors);
    --

    --
    IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name, 'Status Code', x_status_code);
        wsh_debug_sv.pop (l_module_name);
    END IF;
    --
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get (
            p_count  => x_msg_count,
            p_data  =>  x_msg_data,
            p_encoded => FND_API.G_FALSE );
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'FND_API.G_EXC_ERROR exception has occured', WSH_DEBUG_SV.C_EXCEP_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name, 'EXCEPTION:FND_API.G_EXC_ERROR');
        END IF;
        --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get (
            p_count  => x_msg_count,
            p_data  =>  x_msg_data,
            p_encoded => FND_API.G_FALSE );
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured', WSH_DEBUG_SV.C_EXCEP_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name, 'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
        END IF;
        --
    WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
        wsh_util_core.default_handler('WSH_DELIVERY_VALIDATIONS.Get_Delivery_Status');
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM, WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name, 'EXCEPTION:OTHERS');
        END IF;
        --
END Get_Delivery_Status;




END WSH_DELIVERIES_GRP;

/
