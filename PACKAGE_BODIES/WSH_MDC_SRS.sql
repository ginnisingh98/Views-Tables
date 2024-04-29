--------------------------------------------------------
--  DDL for Package Body WSH_MDC_SRS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_MDC_SRS" as
/* $Header: WSHMDSRB.pls 120.8.12000000.2 2007/01/24 18:13:31 bsadri ship $ */


--===================
-- PUBLIC VARIABLES
--===================
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_MDC_SRS';


--========================================================================
-- TYPE : Consolidation_Rec
--
-- COMMENT   : Holds the consolidation records created, along with the list
--             of deliveries going into the consolidation.
--========================================================================
TYPE Consolidation_Rec IS RECORD(
    consol_index    NUMBER,
    total_weight    NUMBER,
    weight_uom      VARCHAR2(3),
    delivery_tab   WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type
);


--========================================================================
-- TYPE : Consolidation_Tab
--
-- COMMENT   : Table of consolidation records created.
--========================================================================
TYPE Consolidation_Tab IS TABLE OF Consolidation_Rec INDEX BY binary_integer;


--===================
-- PROCEDURES
--===================

--========================================================================
-- PROCEDURE : Add_For_Consolidation
--
-- PARAMETERS: p_delivery_rec          Delivery record
--             p_del_weight            Delivery weight
--             p_weight_uom            Weight UOM
--             p_max_weight            Max consolidation trip weight
--             p_ignore_weight         Ignore consolidation trip weight flag
--             x_consol_tab            Consolidation records created
--             x_consol_index          Consolidation record index of the current delivery
--             x_return_status         Return status
--
-- COMMENT   : This procedure adds the delivery to existing consolidation
--             records, or creates a new consolidation record based on the
--             delivery weight and maximum weight allowed on the consolidation
--             trip. The procedure makes sure that max weight for consolidation
--             is not exceeded.
--========================================================================
PROCEDURE Add_For_Consolidation(
            p_delivery_rec    IN WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type,
            p_del_weight      IN NUMBER,
            p_weight_uom      IN VARCHAR2,
            p_max_weight      IN NUMBER,
                p_ignore_weight   IN BOOLEAN,
            x_consol_tab      IN OUT NOCOPY consolidation_tab,
            x_consol_index    OUT NOCOPY NUMBER,
            x_return_status   OUT NOCOPY VARCHAR2);

--========================================================================
-- FUNCTION : Copy_Record
--
-- PARAMETERS: p_del_ccinfo_rec        Input delivery record type
--             p_del_addnl_rec         Input delivery record type containing additional info
--             RETRUN type             Delivery record
--
-- COMMENT   : This function takes delivery records of types
--             WSH_FTE_CONSTRAINT_FRAMEWORK.delivery_ccinfo_rec_type and
--             WSH_MDC_SRS.addnl_del_attr_rec_type and copies the information
--             to a record of type WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type
--             and returns it.
--========================================================================
FUNCTION Copy_Record(
        p_del_ccinfo_rec    IN  WSH_FTE_CONSTRAINT_FRAMEWORK.delivery_ccinfo_rec_type,
        p_del_addnl_rec     IN  addnl_del_attr_rec_type)
        RETURN                  WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type
IS
x_delivery_rec      WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type;
BEGIN

    x_delivery_rec.delivery_id := p_del_ccinfo_rec.delivery_id;
    x_delivery_rec.name := p_del_ccinfo_rec.name;
    x_delivery_rec.organization_id := p_del_ccinfo_rec.organization_id;
    x_delivery_rec.status_code := p_del_ccinfo_rec.status_code;
    x_delivery_rec.planned_flag := p_del_ccinfo_rec.planned_flag;
    x_delivery_rec.initial_pickup_date := p_del_ccinfo_rec.initial_pickup_date;
    x_delivery_rec.initial_pickup_location_id := p_del_ccinfo_rec.initial_pickup_location_id;
    x_delivery_rec.ultimate_dropoff_location_id := p_del_ccinfo_rec.ultimate_dropoff_location_id;
    x_delivery_rec.ultimate_dropoff_date := p_del_ccinfo_rec.ultimate_dropoff_date;
    x_delivery_rec.customer_id := p_del_ccinfo_rec.customer_id;
    x_delivery_rec.intmed_ship_to_location_id := p_del_ccinfo_rec.intmed_ship_to_location_id;
    x_delivery_rec.ship_method_code := p_del_ccinfo_rec.ship_method_code;
    x_delivery_rec.delivery_type := p_del_ccinfo_rec.delivery_type;
    x_delivery_rec.carrier_id := p_del_ccinfo_rec.carrier_id;
    x_delivery_rec.service_level := p_del_ccinfo_rec.service_level;
    x_delivery_rec.mode_of_transport := p_del_ccinfo_rec.mode_of_transport;
    x_delivery_rec.shipment_direction := p_del_ccinfo_rec.shipment_direction;
    x_delivery_rec.party_id := p_del_ccinfo_rec.party_id;
    x_delivery_rec.shipping_control := p_del_ccinfo_rec.shipping_control;

    x_delivery_rec.fob_code := p_del_addnl_rec.fob_code;
    x_delivery_rec.freight_terms_code := p_del_addnl_rec.freight_terms_code;
    x_delivery_rec.loading_sequence := p_del_addnl_rec.loading_sequence;
    x_delivery_rec.gross_weight := p_del_addnl_rec.gross_weight;
    x_delivery_rec.weight_uom_code := p_del_addnl_rec.weight_uom_code;
    x_delivery_rec.ignore_for_planning := p_del_addnl_rec.ignore_for_planning;

    RETURN x_delivery_rec;
END Copy_Record;


--========================================================================
-- PROCEDURE : Schedule_Batch
--
-- PARAMETERS: errbuf                  Concurrent request error buffer
--             retcode                 Concurrent request return code
--             p_batch_id              Concurrent submission batch id
--             p_log_level             Concurrent request log level
--
-- COMMENT   : This procedure is the entry point of the MDC SRS request.
--             The procedure accepts the batch id for which consolidation
--             is requested.
--========================================================================
PROCEDURE Schedule_Batch(
        errbuf        OUT NOCOPY  VARCHAR2,
        retcode       OUT NOCOPY  VARCHAR2,
        p_batch_id    IN          NUMBER,
        p_log_level   IN          NUMBER)
IS

    l_return_status   VARCHAR2(1);
    l_num_errors      NUMBER := 0;
    l_num_warnings    NUMBER := 0;

    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);
    l_status          VARCHAR2(10);
    l_temp            BOOLEAN;
    l_completion_status         VARCHAR2(10);

    l_delivery_tab              WSH_FTE_CONSTRAINT_FRAMEWORK.delivery_ccinfo_tab_type;
    l_delivery_addnl_attr_tab   addnl_del_attr_tab_type;
    l_sel_del_attr              select_del_flags_rec_type;
    l_failed_records            WSH_UTIL_CORE.id_tab_type;
    l_failed_index              NUMBER;
    l_failed_del_id             NUMBER;
    l_group_by_flags            group_by_flags_rec_type;
    l_hash_string               VARCHAR2(1000);
    l_hash_value                NUMBER;
    l_group_index               NUMBER;
    l_group_tab                 grp_attr_tab_type;
    l_del_index                 NUMBER;
    l_cont_cnt                  NUMBER;
    l_trip_id                   NUMBER;
    l_unassign_trip_tab         WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type;
    l_action_params             WSH_DELIVERIES_GRP.action_parameters_rectype;
    l_rating_in_param_rec       WSH_FTE_INTEGRATION.rate_del_in_param_rec;
    l_rating_out_param_rec      WSH_FTE_INTEGRATION.rate_del_out_param_rec;
    l_consol_trip_id            WSH_UTIL_CORE.id_tab_type;
    l_consol_del_id             WSH_UTIL_CORE.id_tab_type;
    l_del_all                   WSH_UTIL_CORE.id_tab_type;
    l_trips_all                 WSH_UTIL_CORE.id_tab_type;
    l_dummy_exception_list      WSH_UTIL_CORE.Column_Tab_Type;
    l_dummy_in_ids              WSH_UTIL_CORE.id_tab_type;
    l_dummy_dlvy_asgnd_lines    WSH_FTE_CONSTRAINT_FRAMEWORK.detail_ccinfo_tab_type;
    l_dummy_tar_trip            WSH_FTE_CONSTRAINT_FRAMEWORK.trip_ccinfo_rec_type;
    l_dummy_tar_tstops          WSH_FTE_CONSTRAINT_FRAMEWORK.target_tripstop_cc_rec_type;
    l_dummy_tar_t_asgn_dels     WSH_FTE_CONSTRAINT_FRAMEWORK.delivery_ccinfo_tab_type;
    l_dummy_tar_t_dlvy_lines    WSH_FTE_CONSTRAINT_FRAMEWORK.detail_ccinfo_tab_type;
    l_dummy_tar_t_incl_stops    WSH_FTE_CONSTRAINT_FRAMEWORK.stop_ccinfo_tab_type;
    l_dummy_val_result          VARCHAR2(100);
    l_valid_hash                BOOLEAN := FALSE;
    l_hash_power                NUMBER := 24;
    l_hash_size                 NUMBER;
    l_hash_base                 NUMBER := 1;
    l_delivery_out_rec          WSH_DELIVERIES_GRP.Delivery_Action_Out_Rec_Type;
    l_defaults_rec              WSH_DELIVERIES_GRP.default_parameters_rectype;

    l_init_msg_list             VARCHAR2(1000);
    l_failed_lines              WSH_FTE_COMP_CONSTRAINT_PKG.failed_line_tab_type;
    l_line_groups               WSH_FTE_COMP_CONSTRAINT_PKG.line_group_tab_type;
    l_group_info                WSH_FTE_COMP_CONSTRAINT_PKG.cc_group_tab_type;
    l_action_prms               WSH_TRIPS_GRP.action_parameters_rectype;
    l_trip_out                  WSH_TRIPS_GRP.tripActionOutRecType;
    l_commit                    VARCHAR2(10);
    l_api_version_number        NUMBER := 1.0;
    l_debug_on                  BOOLEAN;
    l_exc_complete              EXCEPTION;
    l_org_type                  VARCHAR2(3);
    l_cms_org_flag              BOOLEAN := FALSE;
    l_del_cms                   VARCHAR2(3);
    l_cms_cur_val               VARCHAR2(1);

    i                NUMBER;
    j                NUMBER;
    k                NUMBER;
    m                NUMBER;

    l_module_name           CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SCHEDULE_BATCH';
    l_api_session_name      CONSTANT VARCHAR2(150) := G_PKG_NAME ||'.' || l_module_name;
    l_message       VARCHAR2(2000);

    CURSOR Get_Exist_trip(p_delivery_id NUMBER)
    IS
        SELECT COUNT(DELIVERY_LEG_ID)
        FROM WSH_DELIVERY_LEGS
        WHERE DELIVERY_ID = p_delivery_id;

    CURSOR Get_Trip(c_delivery_id NUMBER)
    IS
        SELECT WTS.TRIP_ID
        FROM WSH_TRIP_STOPS WTS, WSH_DELIVERY_LEGS WDL
        WHERE WTS.STOP_ID = WDL.PICK_UP_STOP_ID
        AND WDL.DELIVERY_ID = c_delivery_id;


    CURSOR Get_Cms_Org_Type(c_org_id NUMBER)
    IS
        SELECT CARRIER_MANIFESTING_FLAG
        FROM   MTL_PARAMETERS
        WHERE  ORGANIZATION_ID = c_org_id;

BEGIN

    IF WSH_UTIL_CORE.G_START_OF_SESSION_API is null
    THEN
        WSH_UTIL_CORE.G_START_OF_SESSION_API     := l_api_session_name;
    END IF;

    WSH_UTIL_CORE.Enable_Concurrent_Log_Print;

    IF p_log_level IS NOT NULL
    THEN
       WSH_UTIL_CORE.Set_Log_Level(p_log_level);
       WSH_UTIL_CORE.PrintMsg('p_log_level is ' || to_char(p_log_level));
    END IF;

    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;

    IF p_batch_id IS NULL
    THEN
        WSH_UTIL_CORE.PrintMsg('Batch Id is null');
        WSH_UTIL_CORE.PrintMsg('Error occurred in WSH_MDC_SRS.Schedule_Batch');
                l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','');
                errbuf := 'Error occurred in WSH_MDC_SRS.Schedule_Batch';
                retcode := '2';
        raise FND_API.G_EXC_ERROR;
    END IF;

    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        WSH_DEBUG_SV.log(l_module_name,'P_BATCH_ID',P_BATCH_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_LOG_LEVEL',P_LOG_LEVEL);
        WSH_DEBUG_SV.log(l_module_name,'Current Time is ',SYSDATE);
    END IF;


    l_commit := FND_API.G_FALSE;
    l_completion_status := 'NORMAL';

    -- get delivery selection parameters for the batch
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_MDC_SRS.Get_Batch_Parameters',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;

    Get_Batch_Parameters(
        p_batch_id        =>    p_batch_id,
        x_sel_del_attr    =>    l_sel_del_attr,
        x_return_status   =>    l_return_status);

    IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS)
    THEN
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,  'Got Batch Parameters'  );
        END IF;
    ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
    OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
    THEN
        WSH_UTIL_CORE.PrintMsg('Error occurred in WSH_MDC_SRS.Get_Batch_Parameters');
                l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','');
                errbuf := 'Error occurred in WSH_MDC_SRS.Get_Batch_Parameters';
                retcode := '2';
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Error occurred in WSH_MDC_SRS.Get_Batch_Parameters');
        END IF;
        raise FND_API.G_EXC_ERROR;
    END IF;


    -- check if the organization is TPW org
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_EXTERNAL_INTERFACE.SV.Get_Warehouse_type',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;

    l_org_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_type(
        p_organization_id    =>     l_sel_del_attr.org_id,
        x_return_status      =>     l_return_status);

    IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING)
    THEN
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'WSH_EXTERNAL_INTERFACE.SV.Get_Warehouse_type returned with warnings');
        END IF;
    ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
    OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
    THEN
        WSH_UTIL_CORE.PrintMsg('Error occurred in WSH_EXTERNAL_INTERFACE.SV.Get_Warehouse_type');
                l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','WSH_EXTERNAL_INTERFACE.SV.Get_Warehouse_type');
                errbuf := 'Error occurred in WSH_EXTERNAL_INTERFACE.SV.Get_Warehouse_type';
                retcode := '2';
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Error occurred in WSH_EXTERNAL_INTERFACE.SV.Get_Warehouse_type');
        END IF;
        raise FND_API.G_EXC_ERROR;
    END IF;

    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'Organization type '||l_org_type);
    END IF;

    IF l_org_type = 'TPW'
    THEN
        WSH_UTIL_CORE.PrintMsg('The Organization is TPW enabled. Quitting Consolidation.');
        raise l_exc_complete;
    END IF;

    -- set the organization cms enabled flag

    OPEN Get_Cms_Org_Type(l_sel_del_attr.org_id);
    FETCH Get_Cms_Org_Type INTO l_org_type;
    CLOSE Get_Cms_Org_Type;

    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'Organization CMS value '||l_org_type);
    END IF;

    IF l_org_type = 'Y'
    THEN
        l_cms_org_flag := TRUE;
    END IF;

    -- get deliveries for the set of parameters
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_MDC_SRS.Get_Deliveries',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;

    Get_Deliveries(
        p_sel_del_attr        =>    l_sel_del_attr,
        x_delivery_tab        =>    l_delivery_tab,
        x_delivery_addnl_attr_tab    =>    l_delivery_addnl_attr_tab,
        x_return_status       =>    l_return_status);

    IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS)
    THEN
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,  'Got Deliveries'  );
        END IF;
    ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
    THEN
        WSH_UTIL_CORE.PrintMsg('Error occurred in WSH_MDC_SRS.Get_Deliveries');
                l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','');
                errbuf := 'Error occurred in WSH_MDC_SRS.Get_Deliveries';
                retcode := '2';
        raise FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
    THEN
        WSH_UTIL_CORE.PrintMsg('No deliveries to consolidate');
                l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','');
                errbuf := 'Error occurred in WSH_MDC_SRS.Get_Deliveries';
                retcode := '2';
        raise FND_API.G_EXC_ERROR;
    END IF;

    IF l_delivery_tab.COUNT = 0
    THEN
        WSH_UTIL_CORE.PrintMsg('No deliveries selected for consolidation');
        raise l_exc_complete;
    ELSE
        WSH_UTIL_CORE.PrintMsg('The following deliveries are selected for consolidation');
        i := l_delivery_tab.FIRST;
        WHILE i IS NOT NULL
        LOOP
            WSH_UTIL_CORE.PrintMsg('  Delivery: '||l_delivery_tab(i).delivery_id);
            i := l_delivery_tab.next(i);
        END LOOP;
    END IF;


    -- check if deliveries are assigned to trips.
    -- If delivery has single leg, unassign it
    -- If delivery has multiple legs, ignore delivery
    -- IF cms enabled organization and cms enabled carrier, ignore delivery

    l_failed_index := 0;
    j := 0;
    IF((l_sel_del_attr.inc_del_assgnd_trip_flag = 'Y')
    OR(l_cms_org_flag))
    THEN
        i := l_delivery_tab.FIRST;
        WHILE i IS NOT NULL
        LOOP

            -- check if delivery is carrier manifested
            IF(l_cms_org_flag)
            THEN

                IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_EXTERNAL_INTERFACE.SV.Get_Warehouse_type',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;

                l_del_cms := null;
                l_del_cms := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type
                               ( p_organization_id => l_delivery_tab(i).organization_id,
                                 p_delivery_id     => l_delivery_tab(i).delivery_id,
                                 p_carrier_id      => l_delivery_tab(i).carrier_id,
                                 x_return_status   => l_return_status
                               );
                IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING)
                THEN
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_EXTERNAL_INTERFACE.SV.Get_Warehouse_type returned with warnings');
                    END IF;
                ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
                    OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
                THEN
                    WSH_UTIL_CORE.PrintMsg('Error occurred in WSH_EXTERNAL_INTERFACE.SV.Get_Warehouse_type');
                    WSH_UTIL_CORE.PrintMsg('Failed to get the manifest information. Removing delivery '||l_delivery_tab(i).delivery_id||' from consolidation');
                    l_completion_status := 'WARNING';
                    retcode := '1';

                    l_failed_records(l_failed_index) := l_delivery_tab(i).delivery_id;
                    k := l_delivery_tab.next(i);
                    l_delivery_tab.delete(i);
                    l_delivery_addnl_attr_tab.delete(i);
                    i := k;
                    l_failed_index := l_failed_index + 1;
                    GOTO LOOP_END;

                END IF;


                IF l_del_cms = 'CMS'
                THEN
                    WSH_UTIL_CORE.PrintMsg('Delivery '||l_delivery_tab(i).delivery_id||' is carrier manifesting enabled. Removing from consolidation');

                    k := l_delivery_tab.next(i);
                    l_delivery_tab.delete(i);
                    l_delivery_addnl_attr_tab.delete(i);
                    i := k;
                    GOTO LOOP_END;
                END IF;
            END IF;



            IF(l_sel_del_attr.inc_del_assgnd_trip_flag = 'Y')
            THEN

                OPEN Get_Exist_Trip(l_delivery_tab(i).delivery_id);
                FETCH Get_Exist_Trip INTO l_cont_cnt;
                CLOSE Get_Exist_Trip;


                IF l_cont_cnt > 0
                THEN
                    -- The delivery is assigned to trips
                    IF l_cont_cnt = 1
                    THEN
                        -- If the delivery has just one leg, unassign it
                        OPEN Get_Trip(l_delivery_tab(i).delivery_id);
                        FETCH Get_Trip INTO l_trip_id;
                        CLOSE Get_Trip;

                        IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,'Unassigning delivery '||l_delivery_tab(i).delivery_id||' from it''s delivery leg');
                            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERIES_GRP.Delivery_Action',WSH_DEBUG_SV.C_PROC_LEVEL);
                        END IF;
                        l_unassign_trip_tab(1) := Copy_Record(l_delivery_tab(i), l_delivery_addnl_attr_tab(i));

                        l_action_params.action_code := 'UNASSIGN-TRIP';
                        l_action_params.caller := 'FTE_CONSOL_SRS';
                        l_action_params.trip_id := l_trip_id;
                        WSH_DELIVERIES_GRP.Delivery_Action
                          ( p_api_version_number     => l_api_version_number,
                            p_init_msg_list          => l_init_msg_list,
                            p_commit                 => l_commit,
                            p_action_prms            => l_action_params,
                            p_rec_attr_tab           => l_unassign_trip_tab,
                            x_delivery_out_rec       => l_delivery_out_rec,
                            x_defaults_rec           => l_defaults_rec,
                            x_return_status          => l_return_status,
                            x_msg_count              => l_msg_count,
                            x_msg_data               => l_msg_data
                          );

                        IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS)
                        THEN
                            IF l_debug_on THEN
                                WSH_DEBUG_SV.logmsg(l_module_name, 'Delivery '||l_delivery_tab(i).delivery_id||' unassigned successfully');
                            END IF;
                        ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
                        OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
                        THEN
                            WSH_UTIL_CORE.PrintMsg('Error occurred in WSH_DELIVERIES_GRP.Delivery_Action');
                            FOR m in 1..l_msg_count
                            LOOP
                                l_message := fnd_msg_pub.get(m,'F');
                                l_message := replace(l_message,chr(0),' ');
                                WSH_UTIL_CORE.PrintMsg(l_message);
                                IF l_debug_on THEN
                                    WSH_DEBUG_SV.logmsg(l_module_name, l_message);
                                END IF;
                            END LOOP;

                            fnd_msg_pub.delete_msg();

                            WSH_UTIL_CORE.PrintMsg('Failed to unassign from trip. Removing delivery '||l_delivery_tab(i).delivery_id||' from consolidation');
                            l_completion_status := 'WARNING';
                            retcode := '1';

                            l_failed_records(l_failed_index) := l_delivery_tab(i).delivery_id;
                            k := l_delivery_tab.next(i);
                            l_delivery_tab.delete(i);
                            l_delivery_addnl_attr_tab.delete(i);
                            i := k;
                            l_failed_index := l_failed_index + 1;
                            GOTO LOOP_END;


                        ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING)
                        THEN
                            IF l_debug_on THEN
                                WSH_DEBUG_SV.logmsg(l_module_name, 'Delivery '||l_delivery_tab(i).delivery_id||' unassigned from trip with warnings');
                                FOR m in 1..l_msg_count
                                LOOP
                                    l_message := fnd_msg_pub.get(m,'F');
                                    l_message := replace(l_message,chr(0),' ');
                                    WSH_DEBUG_SV.logmsg(l_module_name, l_message);
                                END LOOP;
                            END IF;
                            fnd_msg_pub.delete_msg();
                        END IF;

                    ELSE
                        WSH_UTIL_CORE.PrintMsg('Delivery '||l_delivery_tab(i).delivery_id||' has mulitple legs. Removing from consolidation');

                        k := l_delivery_tab.next(i);
                        l_delivery_tab.delete(i);
                        l_delivery_addnl_attr_tab.delete(i);
                        i := k;
                        GOTO LOOP_END;
                    END IF;
                END IF;
            END IF;

            i := l_delivery_tab.next(i);
            <<LOOP_END>>
                null;
        END LOOP;
    END IF;


    IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Checking if FTE is installed');
    END IF;

    IF WSH_UTIL_CORE.fte_is_installed = 'Y'
    THEN
    --{
        -- group the deliveries based on constraints
        WSH_UTIL_CORE.PrintMsg('Grouping deliveries based on constraints');

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'FTE is installed');
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_FTE_CONSTRAINT_FRAMEWORK.validate_constraint_dlvy',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        WSH_FTE_CONSTRAINT_FRAMEWORK.validate_constraint_dlvy(
            p_init_msg_list        =>      l_init_msg_list,
            p_action_code          =>      'ACM',
            p_exception_list       =>      l_dummy_exception_list,
            p_in_ids               =>      l_dummy_in_ids,
            p_delivery_info        =>      l_delivery_tab,
            p_dlvy_assigned_lines  =>      l_dummy_dlvy_asgnd_lines,
            p_target_trip          =>      l_dummy_tar_trip,
            p_target_tripstops     =>      l_dummy_tar_tstops,
            p_target_trip_assign_dels  =>      l_dummy_tar_t_asgn_dels,
            p_target_trip_dlvy_lines   =>      l_dummy_tar_t_dlvy_lines,
            p_target_trip_incl_stops   =>      l_dummy_tar_t_incl_stops,
            x_validate_result      =>      l_dummy_val_result,
            x_line_groups          =>      l_line_groups,
            x_group_info           =>      l_group_info,
            x_failed_lines         =>      l_failed_lines,
            x_msg_count        =>      l_msg_count,
            x_msg_data         =>      l_msg_data,
            x_return_status    =>      l_return_status);

        IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS)
        OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
        THEN
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name, 'validate constraints call successful');
                WSH_DEBUG_SV.logmsg(l_module_name, 'Deliveries grouped based on constraints');
            END IF;
        ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
        THEN
            WSH_UTIL_CORE.PrintMsg('Error occurred in WSH_FTE_CONSTRAINT_FRAMEWORK.validate_constraint_dlvy');
            FOR m in 1..l_msg_count
            LOOP
                l_message := fnd_msg_pub.get(m,'F');
                l_message := replace(l_message,chr(0),' ');
                WSH_UTIL_CORE.PrintMsg(l_message);
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name, l_message);
                END IF;
            END LOOP;

            fnd_msg_pub.delete_msg();
            l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','');
            errbuf := 'Error occurred in WSH_FTE_CONSTRAINT_FRAMEWORK.validate_constraint_dlvy';
            retcode := '2';

            raise FND_API.G_EXC_ERROR;
        ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING)
        THEN
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name, 'validate constraints call successful with following warnings');
                FOR m in 1..l_msg_count
                LOOP
                    l_message := fnd_msg_pub.get(m,'F');
                    l_message := replace(l_message,chr(0),' ');
                    WSH_DEBUG_SV.logmsg(l_module_name, l_message);
                END LOOP;
            END IF;
            fnd_msg_pub.delete_msg();
        END IF;


        -- X_line_groups will have the entity_line_id (delivery_id) and line_group_id
        -- Updating the group_id in p_delivery_tab based on the output from x_line_groups
        i := l_line_groups.FIRST;
        -- FOR i in 1 .. l_line_groups.COUNT
        WHILE i IS NOT NULL
        LOOP
            l_delivery_addnl_attr_tab(l_line_groups(i).entity_line_id).group_id := l_line_groups(i).line_group_id;
            WSH_UTIL_CORE.PrintMsg('  Delivery: '||l_line_groups(i).entity_line_id||', Group: '||l_line_groups(i).line_group_id);
            i := l_line_groups.NEXT(i);
        END LOOP;

        -- Remove failed records
        i := l_failed_lines.FIRST;
        l_failed_index := l_failed_records.last + 1;
        -- FOR i in 1 .. l_failed_lines.COUNT
        WHILE i IS NOT NULL
        LOOP
        --{
            l_completion_status := 'WARNING';
            retcode := '1';

            l_failed_del_id := l_failed_lines(i).entity_line_id;
            l_failed_records(l_failed_index) := l_failed_del_id;
            l_delivery_tab.delete(l_failed_del_id);
            l_delivery_addnl_attr_tab.delete(l_failed_del_id);
            l_failed_index := l_failed_index + 1;
            i := l_failed_lines.NEXT(i);
            WSH_UTIL_CORE.PrintMsg('Delivery Id: '||l_failed_del_id||' failed constraint validation. Removing from consolidation');
        --}
        END LOOP;

        IF l_delivery_tab.COUNT = 0
        THEN
            WSH_UTIL_CORE.PrintMsg('All deliveries failed validation. Terminating concurrent request');
            raise l_exc_complete;
        END IF;

    --} -- if fte is installed
    END IF;


    -- get grouping rule
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_MDC_SRS.Get_Grouping_Attrs',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;

    Get_Grouping_Attrs(
        p_grouping_rule_id    =>    l_sel_del_attr.rule_id,
        x_group_by_flags    =>    l_group_by_flags,
        x_return_status     =>    l_return_status);

    IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS)
    THEN
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,  'Got Grouping Attrs'  );
        END IF;
    ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
    OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
    THEN
        WSH_UTIL_CORE.PrintMsg('Error occurred in WSH_MDC_SRS.Get_Grouping_Attrs');
                l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','');
                errbuf := 'Error occurred in WSH_MDC_SRS.Get_Grouping_Attrs';
                retcode := '2';
        raise FND_API.G_EXC_ERROR;
    END IF;


    -- set the intermediate location for the deliveries
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_MDC_SRS.Set_Intermediate_Location',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;

    Set_Intermediate_Location(
        p_consol_loc_id        =>    l_sel_del_attr.consol_ship_to_loc_id,
        p_override_ship_to_flag    =>    l_sel_del_attr.consol_shipto_override_flag,
        p_rule_zone_id             =>    l_group_by_flags.ship_to_zone,
        x_delivery_tab        =>    l_delivery_tab,
        x_delivery_addnl_attr_tab    =>    l_delivery_addnl_attr_tab,
        x_failed_records    =>    l_failed_records,
        x_return_status     =>    l_return_status);

    IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS)
    THEN
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Set Intermediate call successful');
        END IF;
    ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING)
    THEN
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Set Intermediate Location call completed with warnings');
        END IF;
        l_completion_status := 'WARNING';
        retcode := '1';
    ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
    OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
    THEN
        WSH_UTIL_CORE.PrintMsg('Error occurred in WSH_MDC_SRS.Set_Intermediate_Location');
        l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','');
        errbuf := 'Error occurred in WSH_MDC_SRS.Set_Intermediate_Location';
        retcode := '2';
        raise FND_API.G_EXC_ERROR;
    END IF;

    IF l_delivery_tab.COUNT = 0
    THEN
        WSH_UTIL_CORE.PrintMsg('All deliveries failed to get intermediate location. Terminating concurrent request');
        raise l_exc_complete;
    END IF;


    WSH_UTIL_CORE.PrintMsg('Grouping deliveries based on the rule');

    WHILE(l_valid_hash <> TRUE)
    LOOP
    --{
        -- reset loop variables, increament the hash size
        l_valid_hash := TRUE;
        l_hash_power := l_hash_power + 1;
        l_hash_size := power(2,l_hash_power);
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Creating hash values with hash power = '||l_hash_power);
        END IF;
        l_hash_base := 1;
        l_group_tab.DELETE;
        j := 0;
        i := l_delivery_tab.FIRST;
        --FOR l_index in 1 .. l_delivery_tab.COUNT
        WHILE i IS NOT NULL
        LOOP
        --{
            -- get hash value for the record
            --{
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_MDC_SRS.Get_Hash_Value',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            Get_Hash_Value(
                x_delivery_rec            =>    l_delivery_tab(i),
                x_delivery_addnl_attr_rec    =>    l_delivery_addnl_attr_tab(i),
                p_group_by_flags        =>    l_group_by_flags,
                p_hash_base             =>    l_hash_base,
                p_hash_size             =>    l_hash_size,
                x_hash_string           =>    l_hash_string,
                x_hash_value            =>    l_hash_value,
                x_return_status         =>    l_return_status);

            IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS)
            THEN
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,  'Got Hash Value'  );
                END IF;
            ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
            OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
            THEN
                WSH_UTIL_CORE.PrintMsg('Error occurred in WSH_MDC_SRS.Get_Hash_Value');
                l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','');
                errbuf := 'Error occurred in WSH_MDC_SRS.Get_Hash_Value';
                retcode := '2';
                raise FND_API.G_EXC_ERROR;
            END IF;


            l_delivery_addnl_attr_tab(i).hash_string := l_hash_string;
            l_delivery_addnl_attr_tab(i).hash_value := l_hash_value;

            -- group deliveries based on hash value
            l_group_index := l_hash_value;
            IF l_group_tab.EXISTS(l_group_index)
            THEN
            --{
                IF (l_group_tab(l_group_index).hash_string <> l_hash_string)
                THEN
                --{
                    -- hash value not unique
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name, 'Hash value not unique. Rebuilding hash table with bigger hash size');
                    END IF;
                    WSH_UTIL_CORE.PrintMsg('Hash conflict. Dropping and rebuilding rule based grouping.');
                    l_valid_hash := FALSE;
                    EXIT;
                --}
                END IF;
                -- add delivery to existing group
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name, 'Delivery '||l_delivery_addnl_attr_tab(i).delivery_id||' added to existing hash group '||l_group_tab(l_group_index).group_id);
                END IF;
                WSH_UTIL_CORE.PrintMsg('  Delivery: '||l_delivery_addnl_attr_tab(i).delivery_id||', Hash Group: '||l_group_tab(l_group_index).group_id);
                l_delivery_addnl_attr_tab(i).group_id := l_group_tab(l_group_index).group_id;
                l_del_index := l_group_tab(l_group_index).delivery_list.LAST;
                l_group_tab(l_group_index).delivery_list(l_del_index+1) := l_delivery_addnl_attr_tab(i).delivery_id;
            --}
            ELSE
            --{
                l_group_tab(l_group_index).hash_value := l_delivery_addnl_attr_tab(i).hash_value;
                l_group_tab(l_group_index).hash_string := l_delivery_addnl_attr_tab(i).hash_string;
                SELECT WSH_DELIVERY_GROUP_S.nextval INTO l_group_tab(l_group_index).group_id FROM DUAL;
                l_delivery_addnl_attr_tab(i).group_id := l_group_tab(l_group_index).group_id;
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name, 'Delivery '||l_delivery_addnl_attr_tab(i).delivery_id||' added to new hash group '||l_group_tab(l_group_index).group_id);
                END IF;
                WSH_UTIL_CORE.PrintMsg('  Delivery: '||l_delivery_addnl_attr_tab(i).delivery_id||', Hash Group: '||l_group_tab(l_group_index).group_id);
                l_group_tab(l_group_index).delivery_list(0) := l_delivery_addnl_attr_tab(i).delivery_id;
            --}
            END IF;
            --}

            i := l_delivery_tab.NEXT(i);
        --}
        END LOOP;

    --}
    END LOOP; -- created hash grouping


    -- create consolidations
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_MDC_SRS.Create_Consolidations',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    Create_Consolidations(
        x_delivery_tab              =>    l_delivery_tab,
        x_delivery_addnl_attr_tab   =>    l_delivery_addnl_attr_tab,
        p_group_tab                 =>    l_group_tab,
        p_max_trip_weight           =>    l_sel_del_attr.max_trip_weight,
        p_max_weight_uom            =>    l_sel_del_attr.max_trip_weight_uom,
        p_trip_name_prefix          =>    l_sel_del_attr.trip_name_prefix,
        x_consol_trip_id            =>    l_consol_trip_id,
        x_consol_del_id             =>    l_consol_del_id,
        x_trips_all                 =>    l_trips_all,
        x_failed_records            =>    l_failed_records,
        x_return_status             =>    l_return_status);

    IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS)
    THEN
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,  'Create Consolidations Successful');
        END IF;
    ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING)
    THEN
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,  'Create Consolidations completed with warnings');
        END IF;
        l_completion_status := 'WARNING';
        retcode := '1';

    ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
    OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
    THEN
        WSH_UTIL_CORE.PrintMsg('Error occurred in WSH_MDC_SRS.Create_Consolidations');
        l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','');
        errbuf := 'Error occurred in WSH_MDC_SRS.Create_Consolidations';
        retcode := '2';
        raise FND_API.G_EXC_ERROR;
    END IF;


    -- create deconsolidation trips
    IF(l_sel_del_attr.create_deconsol_trips_flag = 'Y')
    THEN
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Creating deconsolidation trips');
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_MDC_SRS.Create_Deconsol_Trips',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        Create_Deconsol_Trips(
            x_delivery_tab              =>    l_delivery_tab,
            x_delivery_addnl_attr_tab   =>    l_delivery_addnl_attr_tab,
            p_consol_trip_id            =>    l_consol_trip_id,
            p_trip_name_prefix          =>    l_sel_del_attr.trip_name_prefix,
            x_trips_all                 =>    l_trips_all,
            x_return_status             =>    l_return_status);

        IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS)
        THEN
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,  'Create Deconsolidation Trips Successful');
            END IF;
        ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING)
        THEN
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,  'Create Deconsolidation Trips completed with warnings');
            END IF;
                    l_completion_status := 'WARNING';
                    retcode := '1';
        ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
        OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
        THEN
            WSH_UTIL_CORE.PrintMsg('Error occurred in WSH_MDC_SRS.Create_Deconsol_Trips');
            l_completion_status := 'WARNING';
            retcode := '1';
        END IF;

    END IF;



    -- route trips
    IF(l_sel_del_attr.route_trips_flag = 'Y')
    THEN
        WSH_UTIL_CORE.PrintMsg('Routing the trips created');
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_ACTIONS.PROCESS_CARRIER_SELECTION',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
/*
        WSH_TRIPS_ACTIONS.PROCESS_CARRIER_SELECTION(
            p_init_msg_list    =>    l_init_msg_list,
            p_trip_id_tab       =>    l_trips_all,
            p_caller            =>    'FTE',
            x_msg_count         =>    l_msg_count,
            x_msg_data          =>    l_msg_data,
            x_return_status     =>    l_return_status);
*/

        l_action_prms.caller := 'WSH-GROUP';
        l_action_prms.action_code := 'SELECT-CARRIER';

        WSH_INTERFACE_GRP.Trip_Action(
            p_api_version_number     =>     l_api_version_number,
            p_init_msg_list          =>     l_init_msg_list,
            p_commit                 =>     l_commit,
            p_entity_id_tab          =>     l_trips_all,
            p_action_prms            =>     l_action_prms,
            x_trip_out_rec           =>     l_trip_out,
            x_return_status          =>     l_return_status,
            x_msg_count              =>     l_msg_count,
            x_msg_data               =>     l_msg_data);

        IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS)
        THEN
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,  'Routing Trips Successful');
            END IF;
        ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING)
        THEN
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,  'Routing Trips completed with warnings');
            END IF;
            FOR m in 1..l_msg_count
            LOOP
                l_message := fnd_msg_pub.get(m,'F');
                l_message := replace(l_message,chr(0),' ');
                WSH_UTIL_CORE.PrintMsg(l_message);
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name, l_message);
                END IF;
            END LOOP;

            fnd_msg_pub.delete_msg();

            l_completion_status := 'WARNING';
            retcode := '1';
        ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
        OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
        THEN
            WSH_UTIL_CORE.PrintMsg('Error occurred in WSH_TRIPS_ACTIONS.PROCESS_CARRIER_SELECTION');
            FOR m in 1..l_msg_count
            LOOP
                l_message := fnd_msg_pub.get(m,'F');
                l_message := replace(l_message,chr(0),' ');
                WSH_UTIL_CORE.PrintMsg(l_message);
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name, l_message);
                END IF;
            END LOOP;

            fnd_msg_pub.delete_msg();

            l_completion_status := 'WARNING';
            retcode := '1';
        END IF;

    END IF;


    -- rate deliveries
    IF(l_sel_del_attr.rate_trips_flag = 'Y')
    THEN

        j := 0;
        i := l_delivery_tab.FIRST;
        WHILE i IS NOT NULL
        LOOP
            l_del_all(j) := l_delivery_tab(i).delivery_id;
            j := j+ 1;
            i := l_delivery_tab.NEXT(i);
        END LOOP;

        i := l_consol_del_id.FIRST;
        WHILE i IS NOT NULL
        LOOP
            l_del_all(j) := l_consol_del_id(i);
            j := j+1;
            i := l_consol_del_id.NEXT(i);
        END LOOP;


        WSH_UTIL_CORE.PrintMsg('Rating Deliveries');
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_FTE_INTEGRATION.Rate_Delivery',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        l_rating_in_param_rec.seq_tender_flag := 'Y';
        l_rating_in_param_rec.action := 'RATE';
        l_rating_in_param_rec.delivery_id_list :=  l_del_all;
        WSH_FTE_INTEGRATION.Rate_Delivery (
            p_api_version       => l_api_version_number,
            p_init_msg_list     => l_init_msg_list,
            p_commit            => l_commit,
            p_in_param_rec      => l_rating_in_param_rec,
            x_out_param_rec     => l_rating_out_param_rec,
            x_return_status     => l_return_status,
            x_msg_count         => l_msg_count,
            x_msg_data          => l_msg_data);

        IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS)
        THEN
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,  'Rating Deliveries Successful');
            END IF;
        ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING)
        THEN
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,  'Rating Deliveries completed with warnings');
            END IF;
            l_completion_status := 'WARNING';
            retcode := '1';
        ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
        OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
        THEN
            WSH_UTIL_CORE.PrintMsg('Error occurred in WSH_FTE_INTEGRATION.Rate_Delivery');
            FOR m in 1..l_msg_count
            LOOP
                l_message := fnd_msg_pub.get(m,'F');
                l_message := replace(l_message,chr(0),' ');
                WSH_UTIL_CORE.PrintMsg(l_message);
            END LOOP;

            fnd_msg_pub.delete_msg();

            l_completion_status := 'WARNING';
            retcode := '1';
        END IF;

    END IF;

    IF l_completion_status = 'NORMAL'
    THEN
        retcode := '0';
        WSH_UTIL_CORE.PrintMsg('Delivery Consolidation completed successfully');
        IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name, 'WSH_MDC_SRS.Schedule_Batch completed successfully');
                WSH_DEBUG_SV.logmsg(l_module_name, 'Current time is '||SYSDATE);
        END IF;
    ELSIF l_completion_status = 'WARNING'
    THEN
        retcode := '1';
        WSH_UTIL_CORE.PrintMsg('Delivery Consolidation completed with warnings');
        IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name, 'WSH_MDC_SRS.Schedule_Batch completed with warnings');
                WSH_DEBUG_SV.logmsg(l_module_name, 'Current time is '||SYSDATE);
        END IF;
    END IF;
    COMMIT;

    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR
    THEN
        ROLLBACK;
        WSH_UTIL_CORE.PrintMsg('SQLCODE: '||sqlcode||' SQLERRM: '||sqlerrm);
        WSH_UTIL_CORE.PrintMsg('Exception occurred in SCHEDULE_BATCH');
        l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','');
        IF errbuf IS NULL
        THEN
            errbuf := 'Exception occurred in SCHEDULE_BATCH';
        END IF;
        retcode := '2';

        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
        END IF;

    WHEN l_exc_complete
    THEN
        retcode := '1';
        WSH_UTIL_CORE.PrintMsg('Delivery Consolidation completed successfully');
        IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name, 'WSH_MDC_SRS.Schedule_Batch completed successfully');
                WSH_DEBUG_SV.logmsg(l_module_name, 'Current time is '||SYSDATE);
        END IF;

        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;

    WHEN OTHERS
    THEN
        ROLLBACK;
        WSH_UTIL_CORE.PrintMsg('SQLCODE: '||sqlcode||' SQLERRM: '||sqlerrm);
        WSH_UTIL_CORE.PrintMsg('Exception occurred in SCHEDULE_BATCH');

        l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','');
        errbuf := 'Exception occurred in SCHEDULE_BATCH';
        retcode := '2';


        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;

END Schedule_Batch;


--========================================================================
-- PROCEDURE : Get_Batch_Parameters
--
-- PARAMETERS: p_batch_id              Concurrent submission batch id
--             x_sel_del_attr          Delivery selection parameters
--             x_return_status         Return status
--
-- COMMENT   : This procedure gets the delivery selection criteria specified
--             for the batch.
--========================================================================
PROCEDURE Get_Batch_Parameters(
        p_batch_id        IN    NUMBER,
        x_sel_del_attr    OUT NOCOPY    select_del_flags_rec_type,
        x_return_status   OUT NOCOPY  VARCHAR2)
IS
    l_module_name           CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_BATCH_PARAMETERS';
    l_debug_on                  BOOLEAN;

    CURSOR Get_Batch(p_batch_id NUMBER) IS
       SELECT
        ORGANIZATION_ID,
        CONSOL_GROUPING_RULE_ID,
        CONSOL_SHIP_TO_LOCATION_ID,
        SHIP_TO_OVERIDE_FLAG,
        DELIVERY_NAME_FROM,
        DELIVERY_NAME_TO,
        PICKUP_START_DAYS,
        PICKUP_END_DAYS,
        DROPOFF_START_DAYS,
        DROPOFF_END_DAYS,
        PR_BATCH_ID,
        CUSTOMER_ID,
        FOB_CODE,
        FREIGHT_TERMS_CODE,
        CARRIER_ID,
        MODE_OF_TRANSPORT,
        SERVICE_LEVEL,
        LOADING_SEQUENCE,
        INTMED_SHIP_TO_LOCATION_ID,
        ULTI_SHIP_TO_LOCATION_ID,
        ULTI_SHIP_TO_REGION,
        ULTI_SHIP_TO_ZIP_FROM,
        ULTI_SHIP_TO_ZIP_TO,
        ULTI_SHIP_TO_ZONE,
        INCL_STAGED_DEL_FLAG,
        INCL_DEL_ASG_TRIPS_FLAG,
        CR_TRIP_TO_ULTM_SHIP_TO,
        ROUTE_TRIPS_FLAG,
        RATE_TRIPS_FLAG,
        TRIP_NAME_PREFIX,
        MAX_TRIP_WEIGHT,
        MAX_TRIP_WEIGHT_UOM
    FROM    WSH_CONSOL_BATCHES
    WHERE    BATCH_ID = p_batch_id;

BEGIN

    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;

    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        WSH_DEBUG_SV.log(l_module_name,'P_BATCH_ID',P_BATCH_ID);
        WSH_DEBUG_SV.log(l_module_name,'Current Time is ',SYSDATE);
    END IF;

    OPEN Get_Batch(p_batch_id);
    FETCH Get_Batch INTO x_sel_del_attr;
    CLOSE Get_Batch;

    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'x_sel_del_attr.org_id: '||x_sel_del_attr.org_id);
        WSH_DEBUG_SV.logmsg(l_module_name,'x_sel_del_attr.rule_id: '||x_sel_del_attr.rule_id);
        WSH_DEBUG_SV.logmsg(l_module_name,'x_sel_del_attr.consol_ship_to_loc_id: '||x_sel_del_attr.consol_ship_to_loc_id);
        WSH_DEBUG_SV.logmsg(l_module_name,'x_sel_del_attr.consol_shipto_override_flag: '||x_sel_del_attr.consol_shipto_override_flag);
        WSH_DEBUG_SV.logmsg(l_module_name,'x_sel_del_attr.delivery_name_from: '||x_sel_del_attr.delivery_name_from);
        WSH_DEBUG_SV.logmsg(l_module_name,'x_sel_del_attr.delivery_name_to: '||x_sel_del_attr.delivery_name_to);
        WSH_DEBUG_SV.logmsg(l_module_name,'x_sel_del_attr.pick_up_DATE_starts_within: '||x_sel_del_attr.pick_up_DATE_starts_within);
        WSH_DEBUG_SV.logmsg(l_module_name,'x_sel_del_attr.pick_up_DATE_ends_within: '||x_sel_del_attr.pick_up_DATE_ends_within);
        WSH_DEBUG_SV.logmsg(l_module_name,'x_sel_del_attr.drop_off_DATE_starts_within: '||x_sel_del_attr.drop_off_DATE_starts_within);
        WSH_DEBUG_SV.logmsg(l_module_name,'x_sel_del_attr.drop_off_DATE_ends_within: '||x_sel_del_attr.drop_off_DATE_ends_within);
        WSH_DEBUG_SV.logmsg(l_module_name,'x_sel_del_attr.pick_release_batch_id: '||x_sel_del_attr.pick_release_batch_id);
        WSH_DEBUG_SV.logmsg(l_module_name,'x_sel_del_attr.customer_id: '||x_sel_del_attr.customer_id);
        WSH_DEBUG_SV.logmsg(l_module_name,'x_sel_del_attr.fob_code: '||x_sel_del_attr.fob_code);
        WSH_DEBUG_SV.logmsg(l_module_name,'x_sel_del_attr.freight_terms_code: '||x_sel_del_attr.freight_terms_code);
        WSH_DEBUG_SV.logmsg(l_module_name,'x_sel_del_attr.carrier_id: '||x_sel_del_attr.carrier_id);
        WSH_DEBUG_SV.logmsg(l_module_name,'x_sel_del_attr.mode_of_transport: '||x_sel_del_attr.mode_of_transport);
        WSH_DEBUG_SV.logmsg(l_module_name,'x_sel_del_attr.service_level: '||x_sel_del_attr.service_level);
        WSH_DEBUG_SV.logmsg(l_module_name,'x_sel_del_attr.loading_sequence: '||x_sel_del_attr.loading_sequence);
        WSH_DEBUG_SV.logmsg(l_module_name,'x_sel_del_attr.intmed_ship_to_loc_id: '||x_sel_del_attr.intmed_ship_to_loc_id);
        WSH_DEBUG_SV.logmsg(l_module_name,'x_sel_del_attr.ulti_ship_to_loc_id: '||x_sel_del_attr.ulti_ship_to_loc_id);
        WSH_DEBUG_SV.logmsg(l_module_name,'x_sel_del_attr.ulti_ship_to_region_id: '||x_sel_del_attr.ulti_ship_to_region_id);
        WSH_DEBUG_SV.logmsg(l_module_name,'x_sel_del_attr.ulti_ship_to_zip_from: '||x_sel_del_attr.ulti_ship_to_zip_from);
        WSH_DEBUG_SV.logmsg(l_module_name,'x_sel_del_attr.ulti_ship_to_zip_to: '||x_sel_del_attr.ulti_ship_to_zip_to);
        WSH_DEBUG_SV.logmsg(l_module_name,'x_sel_del_attr.ulti_ship_to_zone_id: '||x_sel_del_attr.ulti_ship_to_zone_id);
        WSH_DEBUG_SV.logmsg(l_module_name,'x_sel_del_attr.inc_staged_del_flag: '||x_sel_del_attr.inc_staged_del_flag);
        WSH_DEBUG_SV.logmsg(l_module_name,'x_sel_del_attr.inc_del_assgnd_trip_flag: '||x_sel_del_attr.inc_del_assgnd_trip_flag);
        WSH_DEBUG_SV.logmsg(l_module_name,'x_sel_del_attr.create_deconsol_trips_flag: '||x_sel_del_attr.create_deconsol_trips_flag);
        WSH_DEBUG_SV.logmsg(l_module_name,'x_sel_del_attr.route_trips_flag: '||x_sel_del_attr.route_trips_flag);
        WSH_DEBUG_SV.logmsg(l_module_name,'x_sel_del_attr.rate_trips_flag: '||x_sel_del_attr.rate_trips_flag);
        WSH_DEBUG_SV.logmsg(l_module_name,'x_sel_del_attr.trip_name_prefix: '||x_sel_del_attr.trip_name_prefix);
        WSH_DEBUG_SV.logmsg(l_module_name,'x_sel_del_attr.max_trip_weight: '||x_sel_del_attr.max_trip_weight);
        WSH_DEBUG_SV.logmsg(l_module_name,'x_sel_del_attr.max_trip_weight_uom: '||x_sel_del_attr.max_trip_weight_uom);
    END IF;

    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
EXCEPTION
    WHEN OTHERS
    THEN
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
END Get_Batch_Parameters;

--========================================================================
-- PROCEDURE : Get_Deliveries
--
-- PARAMETERS: p_sel_del_attr          Delivery selection parameters
--             x_delivery_tab          Deliveries selected for consolidation
--             x_delivery_addnl_attr_tab         Deliveries selected for consolidation
--             x_return_status         Return status
--
-- COMMENT   : This procedure fetches the deliveries to be consolidated.
--========================================================================
PROCEDURE Get_Deliveries(
        p_sel_del_attr              IN            select_del_flags_rec_type,
        x_delivery_tab              OUT NOCOPY    WSH_FTE_CONSTRAINT_FRAMEWORK.delivery_ccinfo_tab_type,
        x_delivery_addnl_attr_tab   OUT NOCOPY    addnl_del_attr_tab_type,
        x_return_status             OUT NOCOPY           VARCHAR2)
IS
    l_delivery_rec          WSH_FTE_CONSTRAINT_FRAMEWORK.delivery_ccinfo_rec_type;
    l_delivery_addnl_rec    addnl_del_attr_rec_type;
    l_delivery_id           NUMBER;
    l_select_clause         varchar2(1000);
    l_from_clause           varchar2(1000);
    l_where_clause          varchar2(3000);
    l_query                 varchar2(5000);
    l_col_tab               WSH_UTIL_CORE.tbl_varchar;
    l_col_count             NUMBER;
    l_module_name           CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_DELIVERIES';
    l_debug_on              BOOLEAN;
    l_wc_index              NUMBER;


    c_deliveries        WSH_UTIL_CORE.RefCurType;
BEGIN

    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;

    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        WSH_DEBUG_SV.log(l_module_name,'Current Time is ',SYSDATE);

        WSH_DEBUG_SV.log(l_module_name,'p_sel_del_attr.org_id :',p_sel_del_attr.org_id);
        WSH_DEBUG_SV.log(l_module_name,'p_sel_del_attr.rule_id :',p_sel_del_attr.rule_id);
        WSH_DEBUG_SV.log(l_module_name,'p_sel_del_attr.consol_ship_to_loc_id :',p_sel_del_attr.consol_ship_to_loc_id);
        WSH_DEBUG_SV.log(l_module_name,'p_sel_del_attr.consol_shipto_override_flag :',p_sel_del_attr.consol_shipto_override_flag);
        WSH_DEBUG_SV.log(l_module_name,'p_sel_del_attr.delivery_name_from :',p_sel_del_attr.delivery_name_from);
        WSH_DEBUG_SV.log(l_module_name,'p_sel_del_attr.delivery_name_to :',p_sel_del_attr.delivery_name_to);
        WSH_DEBUG_SV.log(l_module_name,'p_sel_del_attr.pick_up_DATE_starts_within :',p_sel_del_attr.pick_up_DATE_starts_within);
        WSH_DEBUG_SV.log(l_module_name,'p_sel_del_attr.pick_up_DATE_ends_within :',p_sel_del_attr.pick_up_DATE_ends_within);
        WSH_DEBUG_SV.log(l_module_name,'p_sel_del_attr.drop_off_DATE_starts_within :',p_sel_del_attr.drop_off_DATE_starts_within);
        WSH_DEBUG_SV.log(l_module_name,'p_sel_del_attr.drop_off_DATE_ends_within :',p_sel_del_attr.drop_off_DATE_ends_within);
        WSH_DEBUG_SV.log(l_module_name,'p_sel_del_attr.pick_release_batch_id :',p_sel_del_attr.pick_release_batch_id);
        WSH_DEBUG_SV.log(l_module_name,'p_sel_del_attr.customer_id :',p_sel_del_attr.customer_id);
        WSH_DEBUG_SV.log(l_module_name,'p_sel_del_attr.fob_code :',p_sel_del_attr.fob_code);
        WSH_DEBUG_SV.log(l_module_name,'p_sel_del_attr.freight_terms_code :',p_sel_del_attr.freight_terms_code);
        WSH_DEBUG_SV.log(l_module_name,'p_sel_del_attr.carrier_id :',p_sel_del_attr.carrier_id);
        WSH_DEBUG_SV.log(l_module_name,'p_sel_del_attr.mode_of_transport :',p_sel_del_attr.mode_of_transport);
        WSH_DEBUG_SV.log(l_module_name,'p_sel_del_attr.service_level :',p_sel_del_attr.service_level);
        WSH_DEBUG_SV.log(l_module_name,'p_sel_del_attr.loading_sequence :',p_sel_del_attr.loading_sequence);
        WSH_DEBUG_SV.log(l_module_name,'p_sel_del_attr.intmed_ship_to_loc_id :',p_sel_del_attr.intmed_ship_to_loc_id);
        WSH_DEBUG_SV.log(l_module_name,'p_sel_del_attr.ulti_ship_to_loc_id :',p_sel_del_attr.ulti_ship_to_loc_id);
        WSH_DEBUG_SV.log(l_module_name,'p_sel_del_attr.ulti_ship_to_region_id :',p_sel_del_attr.ulti_ship_to_region_id);
        WSH_DEBUG_SV.log(l_module_name,'p_sel_del_attr.ulti_ship_to_zip_from :',p_sel_del_attr.ulti_ship_to_zip_from);
        WSH_DEBUG_SV.log(l_module_name,'p_sel_del_attr.ulti_ship_to_zip_to :',p_sel_del_attr.ulti_ship_to_zip_to);
        WSH_DEBUG_SV.log(l_module_name,'p_sel_del_attr.ulti_ship_to_zone_id :',p_sel_del_attr.ulti_ship_to_zone_id);
        WSH_DEBUG_SV.log(l_module_name,'p_sel_del_attr.inc_staged_del_flag :',p_sel_del_attr.inc_staged_del_flag);
        WSH_DEBUG_SV.log(l_module_name,'p_sel_del_attr.inc_del_assgnd_trip_flag :',p_sel_del_attr.inc_del_assgnd_trip_flag);
        WSH_DEBUG_SV.log(l_module_name,'p_sel_del_attr.create_deconsol_trips_flag :',p_sel_del_attr.create_deconsol_trips_flag);
        WSH_DEBUG_SV.log(l_module_name,'p_sel_del_attr.route_trips_flag :',p_sel_del_attr.route_trips_flag);
        WSH_DEBUG_SV.log(l_module_name,'p_sel_del_attr.rate_trips_flag :',p_sel_del_attr.rate_trips_flag);
        WSH_DEBUG_SV.log(l_module_name,'p_sel_del_attr.trip_name_prefix :',p_sel_del_attr.trip_name_prefix);
        WSH_DEBUG_SV.log(l_module_name,'p_sel_del_attr.max_trip_weight :',p_sel_del_attr.max_trip_weight);
        WSH_DEBUG_SV.log(l_module_name,'p_sel_del_attr.max_trip_weight_uom :',p_sel_del_attr.max_trip_weight_uom);
    END IF;


    l_select_clause := 'SELECT WND.DELIVERY_ID, WND.NAME, WND.ORGANIZATION_ID, WND.STATUS_CODE, WND.PLANNED_FLAG, WND.INITIAL_PICKUP_DATE,';
    l_select_clause := l_select_clause || ' WND.INITIAL_PICKUP_LOCATION_ID, WND.ULTIMATE_DROPOFF_LOCATION_ID, WND.ULTIMATE_DROPOFF_DATE,';
    l_select_clause := l_select_clause || ' WND.CUSTOMER_ID, WND.INTMED_SHIP_TO_LOCATION_ID, WND.SHIP_METHOD_CODE, WND.DELIVERY_TYPE, WND.CARRIER_ID,';
    l_select_clause := l_select_clause || ' WND.SERVICE_LEVEL, WND.MODE_OF_TRANSPORT, WND.SHIPMENT_DIRECTION, WND.PARTY_ID, WND.SHIPPING_CONTROL,';
    l_select_clause := l_select_clause || ' WND.FOB_CODE, WND.FREIGHT_TERMS_CODE, WND.LOADING_SEQUENCE, NVL(WND.GROSS_WEIGHT,0) GROSS_WEIGHT, WND.WEIGHT_UOM_CODE, WND.IGNORE_FOR_PLANNING ';
    l_from_clause := ' FROM WSH_NEW_DELIVERIES WND';
    l_where_clause := ' WHERE WND.STATUS_CODE = :stat_code_open AND WND.PLANNED_FLAG <> :planned_flag_f AND NVL(WND.SHIPMENT_DIRECTION,:ship_dir_o) IN (:ship_dir_o, :ship_dir_io) AND WND.DELIVERY_TYPE = :del_type_stan ';

    -- removing deliveries with null dates
    l_where_clause := l_where_clause || ' AND WND.INITIAL_PICKUP_DATE IS NOT NULL AND WND.ULTIMATE_DROPOFF_DATE IS NOT NULL ';

    --removing empty deliveries
    l_where_clause := l_where_clause || ' AND EXISTS( SELECT NULL FROM WSH_DELIVERY_ASSIGNMENTS INNER WHERE INNER.DELIVERY_ID = WND.DELIVERY_ID) ';

    l_col_count := 1;

    l_col_tab(l_col_count) := 'OP';
    l_col_count := l_col_count+1;

    l_col_tab(l_col_count) := 'F';
    l_col_count := l_col_count+1;

    l_col_tab(l_col_count) := 'O';
    l_col_count := l_col_count+1;

    l_col_tab(l_col_count) := 'O';
    l_col_count := l_col_count+1;

    l_col_tab(l_col_count) := 'IO';
    l_col_count := l_col_count+1;

    l_col_tab(l_col_count) := 'STANDARD';
    l_col_count := l_col_count+1;


    WSH_UTIL_CORE.PrintMsg('Delivery filtering criteria for the consolidation batch: ');

    IF p_sel_del_attr.delivery_name_from IS NOT NULL AND p_sel_del_attr.delivery_name_to IS NOT NULL
    THEN
        WSH_UTIL_CORE.PrintMsg('  Delivery name from: '||p_sel_del_attr.delivery_name_from);
        WSH_UTIL_CORE.PrintMsg('  Delivery name to: '||p_sel_del_attr.delivery_name_to);

	IF p_sel_del_attr.delivery_name_from = p_sel_del_attr.delivery_name_to
	THEN
	    SELECT INSTR(p_sel_del_attr.delivery_name_from,'%') INTO l_wc_index FROM DUAL;
	    IF l_wc_index = 0
	    THEN
		l_where_clause := l_where_clause || ' AND WND.NAME = :p_del_name';
		l_col_tab(l_col_count) := p_sel_del_attr.delivery_name_from;
		l_col_count := l_col_count+1;
	    ELSE
		l_where_clause := l_where_clause || ' AND WND.NAME LIKE :p_del_name';
		l_col_tab(l_col_count) := p_sel_del_attr.delivery_name_from;
		l_col_count := l_col_count+1;
	    END IF;
	ELSE
	    l_where_clause := l_where_clause || ' AND WND.NAME BETWEEN :p_del_from AND :p_del_to';
	    l_col_tab(l_col_count) := p_sel_del_attr.delivery_name_from;
	    l_col_count := l_col_count+1;
	    l_col_tab(l_col_count) := p_sel_del_attr.delivery_name_to;
	    l_col_count := l_col_count+1;
	END IF;
    END IF;

    IF p_sel_del_attr.org_id IS NOT NULL
    THEN
        WSH_UTIL_CORE.PrintMsg('  Organization: '||p_sel_del_attr.org_id);
        l_where_clause := l_where_clause || ' AND WND.ORGANIZATION_ID = :org_id';
        l_col_tab(l_col_count) := p_sel_del_attr.org_id;
        l_col_count := l_col_count+1;
    END IF;

    IF p_sel_del_attr.pick_up_date_starts_within IS NOT NULL
    THEN
        WSH_UTIL_CORE.PrintMsg('  Pick-up date starts within: '||p_sel_del_attr.pick_up_date_starts_within);
        l_where_clause := l_where_clause || ' AND WND.INITIAL_PICKUP_DATE >= SYSDATE + :p_pick_up_start_date';
        l_col_tab(l_col_count) := p_sel_del_attr.pick_up_date_starts_within;
        l_col_count := l_col_count+1;
    END IF;

    IF p_sel_del_attr.pick_up_date_ends_within IS NOT NULL
    THEN
        WSH_UTIL_CORE.PrintMsg('  Pick-up date ends within: '||p_sel_del_attr.pick_up_date_ends_within);
        l_where_clause := l_where_clause || ' AND WND.INITIAL_PICKUP_DATE <= SYSDATE + :p_pick_up_end_date';
        l_col_tab(l_col_count) := p_sel_del_attr.pick_up_date_ends_within;
        l_col_count := l_col_count+1;
    END IF;

    IF p_sel_del_attr.drop_off_date_starts_within IS NOT NULL
    THEN
        WSH_UTIL_CORE.PrintMsg('  Drop-off date starts within: '||p_sel_del_attr.drop_off_date_starts_within);
        l_where_clause := l_where_clause || ' AND WND.ULTIMATE_DROPOFF_DATE >= SYSDATE + :p_drop_off_start_date';
        l_col_tab(l_col_count) := p_sel_del_attr.drop_off_date_starts_within;
        l_col_count := l_col_count+1;
    END IF;

    IF p_sel_del_attr.drop_off_date_ends_within IS NOT NULL
    THEN
        WSH_UTIL_CORE.PrintMsg('  Drop-off date ends within: '||p_sel_del_attr.drop_off_date_ends_within);
        l_where_clause := l_where_clause || ' AND WND.ULTIMATE_DROPOFF_DATE <= SYSDATE + :p_drop_off_end_date';
        l_col_tab(l_col_count) := p_sel_del_attr.drop_off_date_ends_within;
        l_col_count := l_col_count+1;
    END IF;

    IF p_sel_del_attr.pick_release_batch_id IS NOT NULL
    THEN
        WSH_UTIL_CORE.PrintMsg('  Pick-Release batch: '||p_sel_del_attr.pick_release_batch_id);
        l_where_clause := l_where_clause || ' AND WND.BATCH_ID = :p_batch_id';
        l_col_tab(l_col_count) := p_sel_del_attr.pick_release_batch_id;
        l_col_count := l_col_count+1;
    END IF;

    IF p_sel_del_attr.fob_code IS NOT NULL
    THEN
        WSH_UTIL_CORE.PrintMsg('  FOB Code: '||p_sel_del_attr.fob_code);
        l_where_clause := l_where_clause || ' AND WND.FOB_CODE = :p_fob_code';
        l_col_tab(l_col_count) := p_sel_del_attr.fob_code;
        l_col_count := l_col_count+1;
    END IF;

    IF p_sel_del_attr.freight_terms_code IS NOT NULL
    THEN
        WSH_UTIL_CORE.PrintMsg('  Freight Terms Code: '||p_sel_del_attr.freight_terms_code);
        l_where_clause := l_where_clause || ' AND WND.FREIGHT_TERMS_CODE = :p_freight_terms_code';
        l_col_tab(l_col_count) := p_sel_del_attr.freight_terms_code;
        l_col_count := l_col_count+1;
    END IF;

    IF p_sel_del_attr.carrier_id IS NOT NULL
    THEN
        WSH_UTIL_CORE.PrintMsg('  Carrier ID: '||p_sel_del_attr.carrier_id);
        l_where_clause := l_where_clause || ' AND WND.CARRIER_ID = :p_carrier_id';
        l_col_tab(l_col_count) := p_sel_del_attr.carrier_id;
        l_col_count := l_col_count+1;
    END IF;

    IF p_sel_del_attr.mode_of_transport IS NOT NULL
    THEN
        WSH_UTIL_CORE.PrintMsg('  Mode of Transport: '||p_sel_del_attr.mode_of_transport);
        l_where_clause := l_where_clause || ' AND WND.MODE_OF_TRANSPORT = :p_mode_of_transport';
        l_col_tab(l_col_count) := p_sel_del_attr.mode_of_transport;
        l_col_count := l_col_count+1;
    END IF;

    IF p_sel_del_attr.service_level IS NOT NULL
    THEN
        WSH_UTIL_CORE.PrintMsg('  Service level: '||p_sel_del_attr.service_level);
        l_where_clause := l_where_clause || ' AND WND.SERVICE_LEVEL = :p_service_level';
        l_col_tab(l_col_count) := p_sel_del_attr.service_level;
        l_col_count := l_col_count+1;
    END IF;

    IF p_sel_del_attr.loading_sequence IS NOT NULL
    THEN
        WSH_UTIL_CORE.PrintMsg('  Loading sequence: '||p_sel_del_attr.loading_sequence);
        l_where_clause := l_where_clause || ' AND WND.LOADING_SEQUENCE = :p_loading_sequence';
        l_col_tab(l_col_count) := p_sel_del_attr.loading_sequence;
        l_col_count := l_col_count+1;
    END IF;

    IF p_sel_del_attr.customer_id IS NOT NULL
    THEN
        WSH_UTIL_CORE.PrintMsg('  Customer ID: '||p_sel_del_attr.customer_id);
        l_where_clause := l_where_clause || ' AND WND.CUSTOMER_ID = :p_customer_id';
        l_col_tab(l_col_count) := p_sel_del_attr.customer_id;
        l_col_count := l_col_count+1;
    END IF;

    IF p_sel_del_attr.intmed_ship_to_loc_id IS NOT NULL
    THEN
        WSH_UTIL_CORE.PrintMsg('  Intermediate Ship to Location: '||p_sel_del_attr.intmed_ship_to_loc_id);
        l_where_clause := l_where_clause || ' AND WND.INTMED_SHIP_TO_LOCATION_ID = :p_intmed_location_id';
        l_col_tab(l_col_count) := p_sel_del_attr.intmed_ship_to_loc_id;
        l_col_count := l_col_count+1;
    END IF;

    IF p_sel_del_attr.ulti_ship_to_loc_id IS NOT NULL
    THEN
        WSH_UTIL_CORE.PrintMsg('  Ulitmate Ship to Location: '||p_sel_del_attr.ulti_ship_to_loc_id);
        l_where_clause := l_where_clause || ' AND WND.ULTIMATE_DROPOFF_LOCATION_ID = :p_dropoff_location_id';
        l_col_tab(l_col_count) := p_sel_del_attr.ulti_ship_to_loc_id;
        l_col_count := l_col_count+1;
    END IF;

    IF p_sel_del_attr.ulti_ship_to_region_id IS NOT NULL
    THEN
        WSH_UTIL_CORE.PrintMsg('  Ultimate Ship to Region: '||p_sel_del_attr.ulti_ship_to_region_id);
        l_where_clause := l_where_clause || ' AND WND.ULTIMATE_DROPOFF_LOCATION_ID IN (SELECT LOCATION_ID FROM WSH_REGION_LOCATIONS  WHERE REGION_ID = :p_region_id)';
        l_col_tab(l_col_count) := p_sel_del_attr.ulti_ship_to_region_id;
        l_col_count := l_col_count+1;
    END IF;

    IF p_sel_del_attr.ulti_ship_to_zip_from IS NOT NULL OR p_sel_del_attr.ulti_ship_to_zip_to IS NOT NULL
    THEN
        l_from_clause := l_from_clause || ', WSH_LOCATIONS WL';
            l_where_clause := l_where_clause || ' AND WND.ULTIMATE_DROPOFF_LOCATION_ID = WL.WSH_LOCATION_ID';
    END IF;

    IF p_sel_del_attr.ulti_ship_to_zip_from IS NOT NULL
    THEN
        WSH_UTIL_CORE.PrintMsg('  Ultimate ship to zip(from): '||p_sel_del_attr.ulti_ship_to_zip_from);
        l_where_clause := l_where_clause || ' AND WL.POSTAL_CODE >= :p_zip_code_from';
        l_col_tab(l_col_count) := p_sel_del_attr.ulti_ship_to_zip_from;
        l_col_count := l_col_count+1;
    END IF;

    IF p_sel_del_attr.ulti_ship_to_zip_to IS NOT NULL
    THEN
        WSH_UTIL_CORE.PrintMsg('  Ultimate ship to zip(to): '||p_sel_del_attr.ulti_ship_to_zip_to);
        l_where_clause := l_where_clause || ' AND WL.POSTAL_CODE <= :p_zip_code_to';
        l_col_tab(l_col_count) := p_sel_del_attr.ulti_ship_to_zip_to;
        l_col_count := l_col_count+1;
    END IF;

    IF p_sel_del_attr.ulti_ship_to_zone_id IS NOT NULL
    THEN
        WSH_UTIL_CORE.PrintMsg('  Ultimate ship to zone: '||p_sel_del_attr.ulti_ship_to_zone_id);
        l_where_clause := l_where_clause || ' AND WND.ULTIMATE_DROPOFF_LOCATION_ID IN (SELECT LOCATION_ID FROM WSH_REGION_LOCATIONS WHERE REGION_ID IN (SELECT REGION_ID FROM  WSH_ZONE_REGIONS WHERE PARENT_REGION_ID = :p_zone_id))';
        l_col_tab(l_col_count) := p_sel_del_attr.ulti_ship_to_zone_id;
        l_col_count := l_col_count+1;
    END IF;

    IF p_sel_del_attr.inc_del_assgnd_trip_flag IS NULL
    THEN
        l_where_clause := l_where_clause || ' AND NOT EXISTS ( SELECT 1 FROM WSH_DELIVERY_LEGS WHERE DELIVERY_ID = WND.DELIVERY_ID AND ROWNUM < 2)';
    ELSE
        WSH_UTIL_CORE.PrintMsg('  Including deliveries assigned to trip');
    END IF;

    IF p_sel_del_attr.inc_staged_del_flag IS NULL
    THEN
        l_where_clause := l_where_clause || ' AND NOT EXISTS ( SELECT 1 FROM WSH_DELIVERY_ASSIGNMENTS WDA, WSH_DELIVERY_DETAILS WDD WHERE WDA.DELIVERY_ID = WND.DELIVERY_ID';
        l_where_clause := l_where_clause || ' AND WDA.DELIVERY_DETAIL_ID = WDD.DELIVERY_DETAIL_ID AND WDD.RELEASED_STATUS = :rel_stat_y AND ROWNUM < 2)';
        l_col_tab(l_col_count) := 'Y';
        l_col_count := l_col_count+1;

    ELSE
        WSH_UTIL_CORE.PrintMsg('  Including staged deliveries');
    END IF;

    -- is the delivery already consolidated?
    l_where_clause := l_where_clause || ' AND NOT EXISTS (SELECT 1 FROM WSH_DELIVERY_ASSIGNMENTS WDA, WSH_NEW_DELIVERIES CONSOL';
    l_where_clause := l_where_clause || ' WHERE WDA.DELIVERY_ID = WND.DELIVERY_ID AND WDA.PARENT_DELIVERY_ID = CONSOL.DELIVERY_ID AND CONSOL.INITIAL_PICKUP_LOCATION_ID = WND.INITIAL_PICKUP_LOCATION_ID AND ROWNUM < 2)';

    l_query := l_select_clause||l_from_clause||l_where_clause;

    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Query built : '||l_query);
    END IF;


    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.OpenDynamicCursor',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;

    WSH_UTIL_CORE.OpenDynamicCursor(c_deliveries, l_query, l_col_tab);

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Dynamic cursor open');
    END IF;

    LOOP
    --{
        FETCH c_deliveries INTO
            l_delivery_rec.delivery_id,
            l_delivery_rec.name,
            l_delivery_rec.organization_id,
            l_delivery_rec.status_code,
            l_delivery_rec.planned_flag,
            l_delivery_rec.initial_pickup_date,
            l_delivery_rec.initial_pickup_location_id,
            l_delivery_rec.ultimate_dropoff_location_id,
            l_delivery_rec.ultimate_dropoff_date,
            l_delivery_rec.customer_id,
            l_delivery_rec.intmed_ship_to_location_id,
            l_delivery_rec.ship_method_code,
            l_delivery_rec.delivery_type,
            l_delivery_rec.carrier_id,
            l_delivery_rec.service_level,
            l_delivery_rec.mode_of_transport,
            l_delivery_rec.shipment_direction,
            l_delivery_rec.party_id,
            l_delivery_rec.shipping_control,
            l_delivery_addnl_rec.fob_code,
            l_delivery_addnl_rec.freight_terms_code,
            l_delivery_addnl_rec.loading_sequence,
            l_delivery_addnl_rec.gross_weight,
            l_delivery_addnl_rec.weight_uom_code,
            l_delivery_addnl_rec.ignore_for_planning;

            l_delivery_rec.exists_in_database := 'Y';


        IF c_deliveries%NOTFOUND
        THEN
            EXIT;
        END IF;

        l_delivery_id := l_delivery_rec.delivery_id;
        l_delivery_addnl_rec.delivery_id := l_delivery_id;
        x_delivery_tab(l_delivery_id) := l_delivery_rec;
        x_delivery_addnl_attr_tab(l_delivery_id) := l_delivery_addnl_rec;

    --}
    END LOOP;

    CLOSE c_deliveries;


    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN OTHERS
    THEN
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
END Get_Deliveries;

--========================================================================
-- PROCEDURE : Set_Intermediate_Location
--
-- PARAMETERS: p_consol_loc_id         Default intermediate location id
--             p_override_ship_to_flag         Intermediate location override flag
--             p_rule_zone_id          Zone specified in the grouping rule
--             x_delivery_tab          Delivery records
--             x_delivery_addnl_attr_tab         Delivery records
--             x_failed_records        Deliveries which failed to get intermedidate location
--             x_return_status         Return status
--
-- COMMENT   : This procedure updates the delivery records with the intermediate
--             location. The intermediate location is fecthed by calling
--             constraints engine which futher checks the Regions form
--             for an intermediate location, if required. The default intermediate
--             location is applied if the constraints engine fails to fecth
--             an intermediate location. If the override flag is set,
--             all the deliveries are updated with the default value.
--========================================================================
PROCEDURE Set_Intermediate_Location(
        p_consol_loc_id            IN    NUMBER,
        p_override_ship_to_flag    IN    VARCHAR2,
        p_rule_zone_id             IN    NUMBER,
        x_delivery_tab             IN OUT NOCOPY    WSH_FTE_CONSTRAINT_FRAMEWORK.delivery_ccinfo_tab_type,
        x_delivery_addnl_attr_tab  IN OUT NOCOPY    addnl_del_attr_tab_type,
        x_failed_records           IN OUT NOCOPY    WSH_UTIL_CORE.id_tab_type,
        x_return_status            OUT NOCOPY    VARCHAR2)
IS
    l_deconsol_output_tab    WSH_FTE_CONSTRAINT_FRAMEWORK.deconsol_output_tab_type;
    l_delivery_id        NUMBER;
    l_failed_index       NUMBER;
    l_dummy_list        WSH_UTIL_CORE.id_tab_type;
    l_override_flag       BOOLEAN;
    l_init_msg_list        VARCHAR2(1000);
    l_msg_count        NUMBER;
    l_msg_data        VARCHAR2(2000);
    l_return_status        VARCHAR2(1);
    i                   NUMBER;
    m                   NUMBER;
    l_module_name       CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SET_INTERMEDIATE_LOCATION';
    l_debug_on          BOOLEAN;
    l_failed_flag       BOOLEAN;
    l_message           VARCHAR2(2000);
    l_int_loc           BOOLEAN;
    l_dummy_loc         NUMBER;
BEGIN

    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;

    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        WSH_DEBUG_SV.log(l_module_name,'p_consol_loc_id',p_consol_loc_id);
        WSH_DEBUG_SV.log(l_module_name,'p_override_ship_to_flag',p_override_ship_to_flag);
        WSH_DEBUG_SV.log(l_module_name,'p_rule_zone_id',p_rule_zone_id);
        WSH_DEBUG_SV.log(l_module_name,'Current Time is ',SYSDATE);
    END IF;

    WSH_UTIL_CORE.PrintMsg('Setting intermediate location for the deliveries');
    WSH_UTIL_CORE.PrintMsg('  Default intermediate location is '||p_consol_loc_id);
    IF p_override_ship_to_flag = 'Y'
    THEN
        l_override_flag := TRUE;
        WSH_UTIL_CORE.PrintMsg('  Note: Override flag is turned on');
    ELSE
        l_override_flag := FALSE;
        WSH_UTIL_CORE.PrintMsg('  Note: Override flag is turned off');
    END IF;

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    -- call constraints API to set the intermediate location
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_FTE_COMP_CONSTRAINT_PKG.validate_constraint_deconsol',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;

      WSH_FTE_CONSTRAINT_FRAMEWORK.validate_constraint_deconsol(
        p_init_msg_list        =>      l_init_msg_list,
        p_delivery_info        =>      x_delivery_tab,
        p_in_ids               =>      l_dummy_list,
        p_rule_to_zone_id      =>      p_rule_zone_id,
        p_rule_deconsol_location    =>    p_consol_loc_id,
        p_rule_override_deconsol    =>    l_override_flag,
        x_output_id_tab        =>      l_deconsol_output_tab,
        x_msg_count        =>      l_msg_count,
        x_msg_data        =>      l_msg_data,
        x_return_status        =>      l_return_status);

        IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS)
        THEN
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,  'Intermediate location set successfully for the deliveries');
            END IF;
        ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING)
        THEN
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,  'Intermediate location set with warnings');
            END IF;
        ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
        OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
        THEN
            WSH_UTIL_CORE.PrintMsg('Error occurred in WSH_FTE_COMP_CONSTRAINT_PKG.validate_constraint_deconsol');
            FOR m in 1..l_msg_count
            LOOP
                l_message := fnd_msg_pub.get(m,'F');
                l_message := replace(l_message,chr(0),' ');
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name, l_message);
                END IF;
                WSH_UTIL_CORE.PrintMsg(l_message);
            END LOOP;

            fnd_msg_pub.delete_msg();

            raise FND_API.G_EXC_ERROR;
        END IF;


    l_failed_index := x_failed_records.LAST;
    IF l_failed_index IS NULL
    THEN
        l_failed_index := 0;
    END IF;

    i := l_deconsol_output_tab.FIRST;
    --FOR i in 1 .. l_deconsol_output_tab.COUNT
    WHILE i IS NOT NULL
    LOOP
        l_delivery_id := l_deconsol_output_tab(i).entity_id;
        x_delivery_tab(l_delivery_id).intmed_ship_to_location_id := l_deconsol_output_tab(i).deconsol_location;

        --check if the location is an internal location
        IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,  'Internal Location check for '||l_deconsol_output_tab(i).deconsol_location);
        END IF;

        l_int_loc := FALSE;

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LOCATIONS_PKG.convert_internal_cust_location',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        WSH_LOCATIONS_PKG.convert_internal_cust_location(
                p_internal_cust_location_id => l_deconsol_output_tab(i).deconsol_location,
                x_internal_org_location_id  => l_dummy_loc,
                x_return_status             => l_return_status);

        IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS)
        THEN
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,  'Internal location checked successfully');
            END IF;
        ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING)
        THEN
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,  'Internal location checked with warnings');
            END IF;
        ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
        OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
        THEN
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,  'Internal location check errored out');
            END IF;
            --removing the delivery record from consolidation
            l_int_loc := TRUE;
        END IF;

        IF l_dummy_loc IS NOT NULL
        THEN
            l_int_loc := TRUE;
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,  'Location '||l_deconsol_output_tab(i).deconsol_location||' is an internal location');
            END IF;
        END IF;

        -- Remove validation failed records and records with internal locations
        IF ((l_deconsol_output_tab(i).validation_status = 'F')
        OR (l_int_loc = TRUE))
        THEN
            l_failed_flag := TRUE;
            l_failed_index := l_failed_index +1;
            x_failed_records(l_failed_index) := l_delivery_id;
            x_delivery_tab.delete(l_delivery_id);
            x_delivery_addnl_attr_tab.delete(l_delivery_id);
            x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
            WSH_UTIL_CORE.PrintMsg('Failed to get Intermediate Location. Removing delivery '||l_delivery_id||' from consolidation');
        ELSE
            WSH_UTIL_CORE.PrintMsg('  Delivery: '||l_deconsol_output_tab(i).entity_id||', Intermediate location: '||l_deconsol_output_tab(i).deconsol_location);
        END IF;
        i := l_deconsol_output_tab.NEXT(i);
    END LOOP;

    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR
    THEN
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
        END IF;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

    WHEN OTHERS
    THEN
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

END Set_Intermediate_Location;


--========================================================================
-- PROCEDURE : Get_Grouping_Attrs
--
-- PARAMETERS: p_grouping_rule_id      Consolidation grouping rule id
--             x_group_by_flags        Grouping attributes
--             x_return_status         Return status
--
-- COMMENT   : This procedure gets the grouping attributes for the
--             rule specified.
--========================================================================
PROCEDURE Get_Grouping_Attrs(
        p_grouping_rule_id    IN    NUMBER,
        x_group_by_flags      OUT NOCOPY    group_by_flags_rec_type,
        x_return_status       OUT NOCOPY   VARCHAR2)
IS
    l_module_name      CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_GROUPING_ATTRS';
    l_debug_on         BOOLEAN;
    l_rule_name        VARCHAR2(30);
    CURSOR Get_Attrs( p_rule_id    NUMBER) IS
    SELECT
        SHIP_FROM_FLAG,
        CUSTOMER_FLAG,
        INTMED_SHIP_TO_FLAG,
        CARRIER_FLAG,
        MODE_OF_TRANSPORT_FLAG,
        SERVICE_LEVEL_FLAG,
        FOB_FLAG,
        FREIGHT_TERMS_FLAG,
        LOADING_SEQUENCE_FLAG,
        SHIP_TO_CODE,
        SHIP_TO_COUNTRY_FLAG,
        SHIP_TO_STATE_FLAG,
        SHIP_TO_CITY_FLAG,
        SHIP_TO_POSTAL_CODE_FLAG,
        SHIP_TO_ZONE
    FROM    WSH_CONSOL_GROUPING_RULES
    WHERE    CONSOL_GROUPING_RULE_ID = p_rule_id;

    CURSOR Get_Rule_Name( p_rule_id    NUMBER) IS
    SELECT RULE_NAME
    FROM WSH_CONSOL_GROUPING_RULES
    WHERE CONSOL_GROUPING_RULE_ID = p_rule_id;
BEGIN

    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;

    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        WSH_DEBUG_SV.log(l_module_name,'p_grouping_rule_id',p_grouping_rule_id);
        WSH_DEBUG_SV.log(l_module_name,'Current Time is ',SYSDATE);
    END IF;

    OPEN Get_Attrs(p_grouping_rule_id);
    FETCH Get_Attrs INTO x_group_by_flags;
    CLOSE Get_Attrs;

    OPEN Get_Rule_Name(p_grouping_rule_id);
    FETCH Get_Rule_Name INTO l_rule_name;
    CLOSE Get_Rule_Name;

    WSH_UTIL_CORE.PrintMsg('Rule used for consolidation: '''||l_rule_name||'''');

    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
EXCEPTION
    WHEN OTHERS
    THEN
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
END Get_Grouping_Attrs;

--========================================================================
-- PROCEDURE : Get_Hash_Value
--
-- PARAMETERS: p_delivery_rec          Delivery record
--             p_delivery_addnl_attr_rec          Delivery record
--             p_group_by_flags        Grouping attributes
--             p_hash_base             Hash base
--             p_hash_size             Hash size
--             x_hash_string           Hash string
--             x_hash_value            Hash value
--             x_return_status         Return status
--
-- COMMENT   : This procedure takes the delivery records and the
--             grouping attributes and return the hash value. The hash
--             size and base also needs to be passed.
--             The procedure also clears out all the non-grouping
--             attributes from the delivery records
--========================================================================
PROCEDURE Get_Hash_Value(
        x_delivery_rec              IN OUT NOCOPY    WSH_FTE_CONSTRAINT_FRAMEWORK.delivery_ccinfo_rec_type,
        x_delivery_addnl_attr_rec   IN OUT NOCOPY    addnl_del_attr_rec_type,
        p_group_by_flags            IN    group_by_flags_rec_type,
        p_hash_base                 IN    NUMBER,
        p_hash_size                 IN    NUMBER,
        x_hash_string               OUT NOCOPY  VARCHAR2,
        x_hash_value                OUT NOCOPY  NUMBER,
        x_return_status             OUT NOCOPY   VARCHAR2)
IS
    l_country    VARCHAR2(120);
    l_state        VARCHAR2(120);
    l_city        VARCHAR2(120);
    l_postal_code    VARCHAR2(60);
    l_zone        VARCHAR2(1);
    l_temp        NUMBER;
    l_module_name           CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_HASH_VALUE';
    l_debug_on                  BOOLEAN;

    CURSOR Get_Loc_Details( c_location_id NUMBER) IS
    SELECT COUNTRY, STATE, CITY, POSTAL_CODE
    FROM WSH_LOCATIONS
    WHERE WSH_LOCATION_ID = c_location_id;

    CURSOR Check_Zone_Location
                ( c_zone_region_id    NUMBER,
                  c_location_id       NUMBER)
    IS
    SELECT REGION_ID
    FROM WSH_REGION_LOCATIONS
    WHERE LOCATION_ID = c_location_id
    AND REGION_ID IN (SELECT REGION_ID
                      FROM WSH_ZONE_REGIONS
                      WHERE PARENT_REGION_ID = c_zone_region_id);

BEGIN

    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;

    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        WSH_DEBUG_SV.log(l_module_name,'Current Time is ',SYSDATE);
            WSH_DEBUG_SV.log(l_module_name,'x_delivery_rec.delivery_id :',x_delivery_rec.delivery_id);
        WSH_DEBUG_SV.log(l_module_name,'p_group_by_flags.ship_from :',p_group_by_flags.ship_from);
        WSH_DEBUG_SV.log(l_module_name,'p_group_by_flags.customer :',p_group_by_flags.customer);
        WSH_DEBUG_SV.log(l_module_name,'p_group_by_flags.intmed_ship_to :',p_group_by_flags.intmed_ship_to);
        WSH_DEBUG_SV.log(l_module_name,'p_group_by_flags.carrier :',p_group_by_flags.carrier);
        WSH_DEBUG_SV.log(l_module_name,'p_group_by_flags.mode_of_transport :',p_group_by_flags.mode_of_transport);
        WSH_DEBUG_SV.log(l_module_name,'p_group_by_flags.service_level :',p_group_by_flags.service_level);
        WSH_DEBUG_SV.log(l_module_name,'p_group_by_flags.fob :',p_group_by_flags.fob);
        WSH_DEBUG_SV.log(l_module_name,'p_group_by_flags.freight_terms :',p_group_by_flags.freight_terms);
        WSH_DEBUG_SV.log(l_module_name,'p_group_by_flags.loading_sequence :',p_group_by_flags.loading_sequence);
        WSH_DEBUG_SV.log(l_module_name,'p_group_by_flags.ship_to_lcode :',p_group_by_flags.ship_to_code);
        WSH_DEBUG_SV.log(l_module_name,'p_group_by_flags.ship_to_country :',p_group_by_flags.ship_to_country);
        WSH_DEBUG_SV.log(l_module_name,'p_group_by_flags.ship_to_state :',p_group_by_flags.ship_to_state);
        WSH_DEBUG_SV.log(l_module_name,'p_group_by_flags.ship_to_city :',p_group_by_flags.ship_to_city);
        WSH_DEBUG_SV.log(l_module_name,'p_group_by_flags.ship_to_postal_code :',p_group_by_flags.ship_to_postal_code);
        WSH_DEBUG_SV.log(l_module_name,'p_group_by_flags.ship_to_zone :',p_group_by_flags.ship_to_zone);
    END IF;

    x_hash_string := x_delivery_rec.initial_pickup_location_id || '-' || x_delivery_rec.intmed_ship_to_location_id
             || '-' || x_delivery_addnl_attr_rec.group_id;

    IF(p_group_by_flags.customer = 'Y')
    THEN
        x_hash_string := x_hash_string || '-' || x_delivery_rec.customer_id;
    ELSE
        x_delivery_rec.customer_id := null;
    END IF;

    IF(p_group_by_flags.carrier = 'Y')
    THEN
        x_hash_string := x_hash_string || '-' || x_delivery_rec.carrier_id;
    ELSE
        x_delivery_rec.carrier_id := null;
    END IF;

    IF(p_group_by_flags.mode_of_transport = 'Y')
    THEN
        x_hash_string := x_hash_string || '-' || x_delivery_rec.mode_of_transport;
    ELSE
        x_delivery_rec.mode_of_transport := null;
    END IF;

    IF(p_group_by_flags.service_level = 'Y')
    THEN
        x_hash_string := x_hash_string || '-' || x_delivery_rec.service_level;
    ELSE
        x_delivery_rec.service_level := null;
    END IF;

    IF(p_group_by_flags.fob = 'Y')
    THEN
        x_hash_string := x_hash_string || '-' || x_delivery_addnl_attr_rec.fob_code;
    ELSE
        x_delivery_addnl_attr_rec.fob_code := null;
    END IF;

    IF(p_group_by_flags.freight_terms = 'Y')
    THEN
        x_hash_string := x_hash_string || '-' || x_delivery_addnl_attr_rec.freight_terms_code;
    ELSE
        x_delivery_addnl_attr_rec.freight_terms_code := null;
    END IF;

    IF(p_group_by_flags.loading_sequence = 'Y')
    THEN
        x_hash_string := x_hash_string || '-' || x_delivery_addnl_attr_rec.loading_sequence;
    ELSE
        x_delivery_addnl_attr_rec.loading_sequence := null;
    END IF;

    IF(p_group_by_flags.ship_to_code = 'L')
    THEN
        x_hash_string := x_hash_string || '-' || x_delivery_rec.ultimate_dropoff_location_id;
    END IF;

    IF(p_group_by_flags.ship_to_code = 'R')
    THEN

        OPEN Get_Loc_Details(x_delivery_rec.ultimate_dropoff_location_id);
        FETCH Get_Loc_Details INTO l_country, l_state, l_city, l_postal_code;
        IF(p_group_by_flags.ship_to_country = 'Y')
        THEN
            x_hash_string := x_hash_string || '-' || l_country;
        END IF;

        IF(p_group_by_flags.ship_to_state = 'Y')
        THEN
            x_hash_string := x_hash_string || '-' || l_state;
        END IF;

        IF(p_group_by_flags.ship_to_city = 'Y')
        THEN
            x_hash_string := x_hash_string || '-' || l_city;
        END IF;

        IF(p_group_by_flags.ship_to_postal_code = 'Y')
        THEN
            x_hash_string := x_hash_string || '-' || l_postal_code;
        END IF;

        CLOSE Get_Loc_Details;
    END IF;

    -- handle zone
    -- currently grouping is done as follows
    -- 1. delivery belongs to the specified zone
    -- 2. delivery does not belong to the specified zone
    IF(p_group_by_flags.ship_to_code = 'Z')
    THEN
        IF(p_group_by_flags.ship_to_zone IS NOT NULL)
        THEN
            l_zone := 'N';
            OPEN Check_Zone_Location
                        (c_zone_region_id   =>  p_group_by_flags.ship_to_zone,
                         c_location_id      =>  x_delivery_rec.ultimate_dropoff_location_id);
             LOOP
                FETCH Check_Zone_Location INTO l_temp;
                EXIT WHEN Check_Zone_Location%NOTFOUND;
                l_zone := 'Y';
                EXIT;
             END LOOP;
             CLOSE Check_Zone_Location;
             x_hash_string := x_hash_string || '-' || l_zone;
        END IF;
    END IF;

    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'hash string :'||x_hash_string);
    END IF;

    x_hash_value := dbms_utility.get_hash_value(
            name => x_hash_string,
            base => p_hash_base,
            hash_size => p_hash_size );

    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'hash value :'||x_hash_value);
    END IF;

    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN OTHERS
    THEN
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

END Get_Hash_Value;


--========================================================================
-- PROCEDURE : Create_Consolidations
--
-- PARAMETERS: x_delivery_tab          Delivery records
--             x_delivery_addnl_attr_tab          Delivery records
--             p_group_tab             Groups created
--             p_max_trip_weight       Max weight of consolidation trip
--             p_max_weight_uom        Max weight uom
--             p_trip_name_prefix      Consolidation trip name prefix
--             x_consol_trip_id        Consolidation trip ids
--             x_consol_del_id         Consolidation delivery ids
--             x_trips_all             List of all the trips created
--             x_failed_records        Records that failed consolidation
--             x_return_status         Return status
--
-- COMMENT   : This procedure takes the delivery records and the
--             groups created and creates consolidated deliveries.
--             The max consolidation trip weight and trip name prefix
--             can also be specified.
--========================================================================
PROCEDURE Create_Consolidations(
        x_delivery_tab              IN OUT NOCOPY    WSH_FTE_CONSTRAINT_FRAMEWORK.delivery_ccinfo_tab_type,
        x_delivery_addnl_attr_tab   IN OUT NOCOPY    addnl_del_attr_tab_type,
        p_group_tab                 IN    grp_attr_tab_type,
        p_max_trip_weight           IN    NUMBER,
        p_max_weight_uom            IN    VARCHAR2,
        p_trip_name_prefix          IN    VARCHAR2,
        x_consol_trip_id            OUT NOCOPY    WSH_UTIL_CORE.id_tab_type,
        x_consol_del_id             OUT NOCOPY    WSH_UTIL_CORE.id_tab_type,
        x_trips_all                 OUT NOCOPY    WSH_UTIL_CORE.id_tab_type,
        x_failed_records            OUT NOCOPY    WSH_UTIL_CORE.id_tab_type,
        x_return_status             OUT NOCOPY   VARCHAR2)
IS

    l_trip_weight_flag    BOOLEAN := FALSE;
    l_consol_index            NUMBER; -- relative count of record in consol tab
    l_del_tab_grp        WSH_UTIL_CORE.id_tab_type;
    l_d_id            NUMBER;
    l_del_weight        NUMBER;
    l_failed_index        NUMBER;
    l_del_rec             WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type;
    l_action_params        WSH_DELIVERIES_GRP.Action_Parameters_Rectype;
    l_consol_tab        consolidation_tab;
    l_init_msg_list        VARCHAR2(1000);
    l_delivery_out_rec    WSH_DELIVERIES_GRP.Delivery_Action_Out_Rec_Type;
    l_defaults_rec        WSH_DELIVERIES_GRP.Default_Parameters_Rectype;
    l_index             NUMBER;
    l_consol_count      NUMBER; -- count of consolidations so far
    l_count             NUMBER; -- l_consol_count + l_consol_index
    l_mesg_count        NUMBER;
    l_mesg_data         VARCHAR2(2000);
    l_return_status     VARCHAR2(1);
    l_message           VARCHAR2(2000);
    l_trips_all_count   NUMBER;
    l_api_version_number    NUMBER := 1.0;
    l_commit    VARCHAR2(10);
    i           NUMBER;
    j           NUMBER;
    k           NUMBER;
    m           NUMBER;
    l_module_name      CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_CONSOLIDATIONS';
    l_debug_on         BOOLEAN;

BEGIN

    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;

    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        WSH_DEBUG_SV.log(l_module_name,'delivery count',x_delivery_tab.COUNT);
        WSH_DEBUG_SV.log(l_module_name,'group count',p_group_tab.COUNT);
        WSH_DEBUG_SV.log(l_module_name,'trip max weight',p_max_trip_weight);
        WSH_DEBUG_SV.log(l_module_name,'trip weight uom',p_max_weight_uom);
        WSH_DEBUG_SV.log(l_module_name,'trip name prefix',p_trip_name_prefix);
        WSH_DEBUG_SV.log(l_module_name,'Current Time is ',SYSDATE);
    END IF;

    l_commit := FND_API.g_false;
    IF (p_max_trip_weight IS NOT NULL AND p_max_weight_uom IS NOT NULL)
    THEN
        l_trip_weight_flag := TRUE;
    END IF;

    WSH_UTIL_CORE.PrintMsg('Creating consolidations');
    IF l_trip_weight_flag
    THEN
        WSH_UTIL_CORE.PrintMsg('  Note: Consolidation trip weight threshold is '||p_max_trip_weight||' '||p_max_weight_uom);
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Consolidation Trip weight taken into consideration');
        END IF;
    ELSE
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Consolidation Trip weight ignored');
        END IF;
    END IF;

    l_failed_index := x_failed_records.LAST;
    IF l_failed_index IS NULL
    THEN
        l_failed_index := 0;
    END IF;


    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    l_consol_count := 0;
    l_trips_all_count := 0;
    i := p_group_tab.FIRST;
--    FOR l_index_i IN 1 .. p_group_tab.COUNT
    WHILE i IS NOT NULL
    LOOP
    --{
        --p_consol_del_id is a table of consolidation deliveries created
        l_del_tab_grp := p_group_tab(i).delivery_list;
        l_consol_tab.DELETE;
        j := l_del_tab_grp.FIRST;
        WSH_UTIL_CORE.PrintMsg('  Consolidating for group '||p_group_tab(i).group_id);
        --FOR l_index_j IN 1 .. l_del_tab_grp.COUNT
        WHILE j IS NOT NULL
        LOOP
        --{
            l_d_id := l_del_tab_grp(j);
            -- Check for the max trip weight
            IF l_trip_weight_flag = TRUE
            THEN
                l_del_weight := x_delivery_addnl_attr_tab(l_d_id).gross_weight;
                -- Convert to the common uom of max trip weight
                IF x_delivery_addnl_attr_tab(l_d_id).weight_uom_code <> p_max_weight_uom
                THEN
                    l_del_weight := WSH_WV_UTILS.convert_uom(
                                x_delivery_addnl_attr_tab(l_d_id).weight_uom_code,
                                p_max_weight_uom,
                                x_delivery_addnl_attr_tab(l_d_id).gross_weight,
                                0);
                END IF;

                -- weight of current delivery exceeds threshold
                IF (l_del_weight > p_max_trip_weight)
                THEN
                    --The delivery's weight exceeds the threshold.
                    --Delete the delivery
                    l_failed_index := l_failed_index +1;
                    x_failed_records(l_failed_index) := l_d_id;
                    x_delivery_tab.DELETE(l_d_id);
                    x_delivery_addnl_attr_tab.DELETE(l_d_id);
                    WSH_UTIL_CORE.PrintMsg('Delivery '||l_d_id||' weight exceeds threshold. Removing from consolidation');
                    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;

                ELSE
                    l_del_rec := Copy_Record(x_delivery_tab(l_d_id),x_delivery_addnl_attr_tab(l_d_id));
                    IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_MDC_SRS.Add_For_Consolidation',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;

                    Add_For_Consolidation(
                        p_delivery_rec    => l_del_rec,
                        p_del_weight      => l_del_weight,
                        p_weight_uom      => p_max_weight_uom,
                        p_max_weight      => p_max_trip_weight,
                        p_ignore_weight   => FALSE,
                        x_consol_tab      => l_consol_tab,
                        x_consol_index    => l_consol_index,
                        x_return_status   => l_return_status); -- relative index in the consolidation table

                    IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS)
                    THEN
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,  'Delivery added for consolidation');
                        END IF;
                    ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING)
                    THEN
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,  'Delivery added with warning');
                        END IF;
                    ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
                    OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
                    THEN
                        WSH_UTIL_CORE.PrintMsg('Could not add delivery for consolidation');
                        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                        raise FND_API.G_EXC_ERROR;
                    END IF;

                    x_delivery_addnl_attr_tab(l_d_id).consol_index := l_consol_index + l_consol_count;

                END IF;

            ELSE -- weight flag is not checked
                l_del_rec := Copy_Record(x_delivery_tab(l_d_id),x_delivery_addnl_attr_tab(l_d_id));
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_MDC_SRS.Add_For_Consolidation',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;

                Add_For_Consolidation(
                    p_delivery_rec    => l_del_rec,
                    p_del_weight      => l_del_weight,
                    p_weight_uom      => null,
                    p_max_weight      => -1,
                    p_ignore_weight   => TRUE,
                    x_consol_tab      => l_consol_tab,
                    x_consol_index    => l_consol_index,
                    x_return_status   => l_return_status); -- relative index in the consolidation table

                IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS)
                THEN
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,  'Delivery added for consolidation');
                    END IF;
                ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING)
                THEN
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,  'Delivery added with warning');
                    END IF;
                ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
                OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
                THEN
                    WSH_UTIL_CORE.PrintMsg('Could not add delivery for consolidation');
                    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                    raise FND_API.G_EXC_ERROR;
                END IF;

                x_delivery_addnl_attr_tab(l_d_id).consol_index := l_consol_index + l_consol_count;

            END IF; --end if for the trip weight check

            j := l_del_tab_grp.NEXT(j);
        --}
        END LOOP;    -- end loop for the deliveries belonging to same group

        IF l_consol_tab.COUNT > 0 --if there are consolidations
        THEN
        --{
            l_action_params.action_code := 'CREATE-CONSOL-DEL';
            l_action_params.caller := 'WSH_CONSOL_SRS';
            l_action_params.trip_name := p_trip_name_prefix;

            k := l_consol_tab.FIRST;
            WHILE k IS NOT NULL
            LOOP
            --{

                --  Create consol deliveries
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Creating consolidation delivery for consolidation no. '||l_consol_tab(k).consol_index);
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERIES_GRP.Delivery_ACTION',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;

                WSH_DELIVERIES_GRP.Delivery_ACTION(
                        p_api_version_number     => l_api_version_number,
                        p_init_msg_list          => l_init_msg_list,
                        p_commit                 => l_commit,
                        p_action_prms            => l_action_params,
                        p_rec_attr_tab           => l_consol_tab(k).delivery_tab,
                        x_delivery_out_rec       => l_delivery_out_rec,
                        x_defaults_rec           => l_defaults_rec,
                        x_return_status          => l_return_status,
                        x_msg_count              => l_mesg_count,
                        x_msg_data               => l_mesg_data);

                IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS)
                THEN
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name, 'Consolidation Created successfully');
                    END IF;
                ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
                OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
                THEN
                    WSH_UTIL_CORE.PrintMsg('Error occurred in WSH_DELIVERIES_GRP.Delivery_ACTION');
                    FOR i in 1..l_mesg_count
                    LOOP
                        l_message := fnd_msg_pub.get(m,'F');
                        l_message := replace(l_message,chr(0),' ');
                        WSH_UTIL_CORE.PrintMsg(l_message);
                    END LOOP;

                    fnd_msg_pub.delete_msg();
                    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                    raise FND_API.G_EXC_ERROR;
                ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING)
                THEN
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name, 'Created consolidations with following warnings');
                        FOR i in 1..l_mesg_count
                        LOOP
                            l_message := fnd_msg_pub.get(m,'F');
                            l_message := replace(l_message,chr(0),' ');
                            WSH_DEBUG_SV.logmsg(l_module_name, l_message);
                        END LOOP;
                    END IF;
                    fnd_msg_pub.delete_msg();
                    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
                END IF;

                l_index := l_delivery_out_rec.valid_ids_tab.FIRST;
                IF l_index IS NOT NULL
                THEN
                    l_count := l_consol_tab(k).consol_index + l_consol_count;
                    x_consol_del_id(l_count) := l_delivery_out_rec.result_id_tab(l_index);
                    x_consol_trip_id(l_count) := l_delivery_out_rec.valid_ids_tab(l_index);
                    -- Store trip id in a table for future calls to rating/ routing
                    x_trips_all(l_trips_all_count) := x_consol_trip_id(l_count);
                    l_trips_all_count := l_trips_all_count+1;
                END IF;
                WSH_UTIL_CORE.PrintMsg('    Consolidation Index: '||l_consol_tab(k).consol_index||', Consol Delivery: '||x_consol_del_id(l_count)||', Consol Trip: '||x_consol_trip_id(l_count));
                k := l_consol_tab.NEXT(k);
            --}
            END LOOP;
        --}
        END IF;
        l_consol_count := l_consol_count + l_consol_tab.COUNT;
        i := p_group_tab.NEXT(i);

    --}
    END LOOP;    -- end loop for table of groups

    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR
    THEN
        WSH_UTIL_CORE.PrintMsg('Exception occurred in Create_Consolidation');
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
        END IF;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    WHEN OTHERS
    THEN
        WSH_UTIL_CORE.PrintMsg('SQLCODE: '||sqlcode||' SQLERRM: '||sqlerrm);
        WSH_UTIL_CORE.PrintMsg('Exception occurred in Create_Consolidation');
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;

END Create_Consolidations;


--========================================================================
-- PROCEDURE : Create_Deconsol_Trips
--
-- PARAMETERS: x_delivery_tab          Delivery records
--             x_delivery_addnl_attr_tab          Delivery records
--             p_consol_trip_id        Consolidation trip ids
--             x_trips_all             List of all the trips created
--             x_return_status         Return status
--
-- COMMENT   : This procedure takes the delivery records and and creates
--             cdeconsolidation trips for the deliveries.
--========================================================================
PROCEDURE Create_Deconsol_Trips(
        x_delivery_tab              IN OUT NOCOPY    WSH_FTE_CONSTRAINT_FRAMEWORK.delivery_ccinfo_tab_type,
        x_delivery_addnl_attr_tab   IN OUT NOCOPY    addnl_del_attr_tab_type,
        p_consol_trip_id            IN    WSH_UTIL_CORE.id_tab_type,
        p_trip_name_prefix          IN    VARCHAR2,
        x_trips_all                 IN OUT NOCOPY    WSH_UTIL_CORE.id_tab_type,
        x_return_status             OUT NOCOPY   VARCHAR2)
IS
    l_trip_in_rec        WSH_TRIPS_GRP.tripInRecType;
    l_init_msg_list        VARCHAR2(100);
    l_api_version_number    NUMBER := 1.0;
    l_commit        VARCHAR2(10);
    l_return_status        VARCHAR2(1);
    l_msg_count        NUMBER;
    l_msg_data        VARCHAR2(2000);
    l_trip_info_tab        WSH_TRIPS_PVT.Trip_Attr_Tbl_Type;
    l_trip_info_rec        WSH_TRIPS_PVT.trip_rec_type;
    l_trip_out_rec_tab    WSH_TRIPS_GRP.Trip_Out_Tab_Type;
    l_trip_id        NUMBER;
    l_del_id         NUMBER;
    l_trip_name        VARCHAR2(30);
    l_stop_in_rec       WSH_TRIP_STOPS_GRP.stopInRecType;
    l_pickup_stop_info    WSH_TRIP_STOPS_PVT.Trip_Stop_Rec_Type;
    l_pickup_rec_attr_tab    WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type;
    l_pickup_stop_out_tab    WSH_TRIP_STOPS_GRP.stop_out_tab_type;
    l_dropoff_stop_info    WSH_TRIP_STOPS_PVT.Trip_Stop_Rec_Type;
    l_dropoff_rec_attr_tab    WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type;
    l_dropoff_stop_out_tab    WSH_TRIP_STOPS_GRP.stop_out_tab_type;
    l_stop_wt_vol_out_tab    WSH_TRIP_STOPS_GRP.Stop_Wt_Vol_tab_type;
    l_action_prms        WSH_DELIVERIES_GRP.action_parameters_rectype;
    l_rec_attr_tab        WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type;
    l_delivery_out_rec    WSH_DELIVERIES_GRP.Delivery_Action_Out_Rec_Type;
    l_defaults_rec        WSH_DELIVERIES_GRP.default_parameters_rectype;
    l_unplan_action_prms  WSH_TRIPS_GRP.action_parameters_rectype;
    l_unplan_rec_attr   WSH_TRIPS_PVT.Trip_Attr_Tbl_Type;
    l_unplan_dummy_out    WSH_TRIPS_GRP.tripActionOutRecType;
    l_unplan_dummy_def    WSH_TRIPS_GRP.default_parameters_rectype;
    l_trips_all_count     NUMBER;
    l_trip_cr_flag BOOLEAN;
    i       NUMBER;
    m       NUMBER;
    l_module_name       CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_DECONSOL_TRIPS';
    l_debug_on          BOOLEAN;
    l_message           VARCHAR2(2000);

    CURSOR Get_Intermediate_Dropoff_Date(c_trip_id  NUMBER) IS
        SELECT PLANNED_ARRIVAL_DATE
        FROM WSH_TRIP_STOPS
        WHERE TRIP_ID = c_trip_id
        ORDER BY STOP_SEQUENCE_NUMBER DESC;

BEGIN

    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;

    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        WSH_DEBUG_SV.log(l_module_name,'Current Time is ',SYSDATE);
    END IF;

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    WSH_UTIL_CORE.PrintMsg('Creating deconsolidation trips');
    i := x_delivery_tab.FIRST;
    l_trips_all_count := x_trips_all.LAST+1;

    --    FOR i IN x_delivery_tab.FIRST .. x_delivery_tab.LAST
    WHILE i IS NOT NULL
    LOOP
        BEGIN
            l_trip_cr_flag := FALSE;

            -- Checking if the deconsol location is same as ultimate dropoff
            -- Do not create deconsol trip in such case
            IF x_delivery_tab(i).intmed_ship_to_location_id = x_delivery_tab(i).ultimate_dropoff_location_id
            THEN
                WSH_UTIL_CORE.PrintMsg('Not creating deconsol trip for the delivery '||x_delivery_tab(i).delivery_id);
            ELSE

                SAVEPOINT CREATE_TRIP;
                l_del_id := x_delivery_tab(i).delivery_id;
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Creating deconsol trip for delivery '||l_del_id);
                END IF;

                OPEN Get_Intermediate_Dropoff_Date(p_consol_trip_id(x_delivery_addnl_attr_tab(i).consol_index));
                FETCH Get_Intermediate_Dropoff_Date INTO x_delivery_addnl_attr_tab(i).intermediate_pickup_date;
                CLOSE Get_Intermediate_Dropoff_Date;

                IF x_delivery_tab(i).ultimate_dropoff_date IS NULL
                OR x_delivery_tab(i).ultimate_dropoff_date <= x_delivery_addnl_attr_tab(i).intermediate_pickup_date
                THEN
                    x_delivery_tab(i).ultimate_dropoff_date := x_delivery_addnl_attr_tab(i).intermediate_pickup_date + 1;
                END IF;

                -- Create a trip for the delivery
                l_trip_in_rec.caller := 'WSH';
                l_trip_in_rec.phase := NULL;
                l_trip_in_rec.action_code := 'CREATE';

		l_trip_info_tab.DELETE;

                l_commit := FND_API.g_false;
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Creating deconsol trip');
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_GRP.Create_Update_Trip',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;

                WSH_TRIPS_GRP.Create_Update_Trip(
                    p_api_version_number => l_api_version_number,
                    p_init_msg_list      => l_init_msg_list,
                    p_commit         => l_commit,
                    x_return_status      => l_return_status,
                    x_msg_count      => l_msg_count,
                    x_msg_data       => l_msg_data,
                    p_trip_info_tab      => l_trip_info_tab,
                    p_in_rec         => l_trip_in_rec,
                    x_out_tab        => l_trip_out_rec_tab);


                IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS)
                THEN
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name, 'Created trip succesfully');
                    END IF;
                ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
                OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
                THEN
                    WSH_UTIL_CORE.PrintMsg('Error occurred in WSH_TRIPS_GRP.Create_Update_Trip');
                    IF l_debug_on THEN
                        FOR m in 1..l_msg_count
                        LOOP
                            l_message := fnd_msg_pub.get(m,'F');
                            l_message := replace(l_message,chr(0),' ');
                            WSH_DEBUG_SV.logmsg(l_module_name,l_message);
                        END LOOP;
                    END IF;
                    fnd_msg_pub.delete_msg();
                    raise FND_API.G_EXC_ERROR;

                ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING)
                THEN
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Trip created with warnings');
                        FOR m in 1..l_msg_count
                        LOOP
                            l_message := fnd_msg_pub.get(m,'F');
                            l_message := replace(l_message,chr(0),' ');
                            WSH_DEBUG_SV.logmsg(l_module_name,l_message);
                        END LOOP;
                    END IF;
                    fnd_msg_pub.delete_msg();
                END IF;

                l_trip_id := l_trip_out_rec_tab(l_trip_out_rec_tab.FIRST).trip_id;
                l_trip_name := l_trip_out_rec_tab(l_trip_out_rec_tab.FIRST).trip_name;


                IF p_trip_name_prefix IS NOT NULL
                THEN
                    -- Rename the trip by attaching the prefix
                   l_trip_in_rec.caller := 'WSH';
                   l_trip_in_rec.phase := NULL;
                   l_trip_in_rec.action_code := 'UPDATE';

                   l_trip_info_rec.trip_id := l_trip_id;
                   l_trip_name := p_trip_name_prefix ||'-'||l_trip_name;
                   l_trip_info_rec.name := l_trip_name;
                   l_trip_info_tab(0) := l_trip_info_rec;

                   IF l_debug_on THEN
                       WSH_DEBUG_SV.logmsg(l_module_name,'Renaming deconsol trip, attaching prefix '||p_trip_name_prefix);
                       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_GRP.Create_Update_Trip',WSH_DEBUG_SV.C_PROC_LEVEL);
                   END IF;


                   WSH_TRIPS_GRP.Create_Update_Trip(
                            p_api_version_number => l_api_version_number,
                            p_init_msg_list      => l_init_msg_list,
                            p_commit             => l_commit,
                            x_return_status      => l_return_status,
                            x_msg_count          => l_msg_count,
                            x_msg_data           => l_msg_data,
                            p_trip_info_tab      => l_trip_info_tab,
                            p_in_rec             => l_trip_in_rec,
                            x_out_tab            => l_trip_out_rec_tab);


                   IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS)
                   THEN
                       IF l_debug_on THEN
                           WSH_DEBUG_SV.logmsg(l_module_name, 'Renamed trip succesfully');
                       END IF;
                   ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
                   OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
                   THEN
                       WSH_UTIL_CORE.PrintMsg('Error occurred in WSH_TRIPS_GRP.Create_Update_Trip');
                       IF l_debug_on THEN
                           FOR m in 1..l_msg_count
                           LOOP
                               l_message := fnd_msg_pub.get(m,'F');
                               l_message := replace(l_message,chr(0),' ');
                               WSH_DEBUG_SV.logmsg(l_module_name,l_message);
                           END LOOP;
                       END IF;
                       fnd_msg_pub.delete_msg();
                       raise FND_API.G_EXC_ERROR;

                   ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING)
                   THEN
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,'Trip renamed with warnings');
                            FOR m in 1..l_msg_count
                            LOOP
                                l_message := fnd_msg_pub.get(m,'F');
                                l_message := replace(l_message,chr(0),' ');
                                WSH_DEBUG_SV.logmsg(l_module_name,l_message);
                            END LOOP;
                        END IF;
                        fnd_msg_pub.delete_msg();
                   END IF;

                END IF;

                --Store trip id in a table for future calls to routing/ rating
                x_trips_all(l_trips_all_count) := l_trip_id;
                l_trips_all_count := l_trips_all_count+1;
                l_trip_cr_flag := TRUE;

                -- Update delivery tab with trip_id created
                x_delivery_addnl_attr_tab(i).deconsol_trip_id := l_trip_id;
                x_delivery_addnl_attr_tab(i).deconsol_trip_name := l_trip_name;


                -- Ignore trip for planning

                l_unplan_action_prms.caller := 'WSH';
                l_unplan_action_prms.action_code := 'IGNORE_PLAN';

                l_unplan_rec_attr(1).trip_id := l_trip_id;




                WSH_TRIPS_GRP.Trip_Action
                    ( p_api_version_number     => l_api_version_number,
                      p_init_msg_list          => l_init_msg_list,
                      p_commit                 => l_commit,
                      p_action_prms            => l_unplan_action_prms,
                      p_rec_attr_tab           => l_unplan_rec_attr,
                      x_trip_out_rec           => l_unplan_dummy_out,
                      x_def_rec                => l_unplan_dummy_def,
                      x_return_status          => l_return_status,
                      x_msg_count              => l_msg_count,
                      x_msg_data               => l_msg_data);

                IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS)
                THEN
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name, 'Trip unplanned succesfully');
                    END IF;
                ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
                OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
                THEN
                    WSH_UTIL_CORE.PrintMsg('Error occurred in WSH_TRIPS_GRP.Trip_Action');
                    IF l_debug_on THEN
                        FOR m in 1..l_msg_count
                        LOOP
                            l_message := fnd_msg_pub.get(m,'F');
                            l_message := replace(l_message,chr(0),' ');
                            WSH_DEBUG_SV.logmsg(l_module_name,l_message);
                        END LOOP;
                    END IF;
                    fnd_msg_pub.delete_msg();
                    raise FND_API.G_EXC_ERROR;

                ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING)
                THEN
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Trip unplanned with warnings');
                        FOR m in 1..l_msg_count
                        LOOP
                            l_message := fnd_msg_pub.get(m,'F');
                            l_message := replace(l_message,chr(0),' ');
                            WSH_DEBUG_SV.logmsg(l_module_name,l_message);
                        END LOOP;
                    END IF;
                    fnd_msg_pub.delete_msg();
                END IF;



                --Create pickup stop for the trip using intermediate_ship_to

                l_pickup_stop_info.TRIP_ID := l_trip_id;
                l_pickup_stop_info.STOP_LOCATION_ID:= x_delivery_tab(i).intmed_ship_to_location_id;
                l_pickup_stop_info.planned_arrival_date := x_delivery_addnl_attr_tab(i).intermediate_pickup_date;
                l_pickup_stop_info.planned_departure_date := x_delivery_addnl_attr_tab(i).intermediate_pickup_date;
                l_pickup_rec_attr_tab(1):=l_pickup_stop_info;

                l_stop_in_rec.caller := 'WSH';
                l_stop_in_rec.phase := NULL;
                l_stop_in_rec.action_code := 'CREATE';
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Creating pickup stop');
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_GRP.CREATE_UPDATE_STOP',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;

                WSH_TRIP_STOPS_GRP.CREATE_UPDATE_STOP(
                    p_api_version_number    => l_api_version_number,
                    p_init_msg_list         => l_init_msg_list,
                    p_commit                => l_commit,
                    p_in_rec                => l_stop_in_rec,
                    p_rec_attr_tab          => l_pickup_rec_attr_tab,
                    x_stop_out_tab          => l_pickup_stop_out_tab,
                    x_return_status         => l_return_status,
                    x_msg_count             => l_msg_count,
                    x_msg_data              => l_msg_data,
                    x_stop_wt_vol_out_tab   => l_stop_wt_vol_out_tab);

                IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS)
                THEN
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name, 'Pickup Stop created succesfully');
                    END IF;
                ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
                OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
                THEN
                    WSH_UTIL_CORE.PrintMsg('Error occurred in WSH_TRIP_STOPS_GRP.CREATE_UPDATE_STOP');
                    IF l_debug_on THEN
                        FOR m in 1..l_msg_count
                        LOOP
                            l_message := fnd_msg_pub.get(m,'F');
                            l_message := replace(l_message,chr(0),' ');
                            WSH_DEBUG_SV.logmsg(l_module_name,l_message);
                        END LOOP;
                    END IF;
                    fnd_msg_pub.delete_msg();
                    raise FND_API.G_EXC_ERROR;

                ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING)
                THEN
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Pickup Stop created with warnings');
                        FOR m in 1..l_msg_count
                        LOOP
                            l_message := fnd_msg_pub.get(m,'F');
                            l_message := replace(l_message,chr(0),' ');
                            WSH_DEBUG_SV.logmsg(l_module_name,l_message);
                        END LOOP;
                    END IF;
                    fnd_msg_pub.delete_msg();
                END IF;

                -- Create Dropoff stop using ultimate_ship_to
                l_dropoff_stop_info.TRIP_ID := l_trip_id;
                l_dropoff_stop_info.STOP_LOCATION_ID:= x_delivery_tab(i).ultimate_dropoff_location_id;
                l_dropoff_stop_info.planned_arrival_date := x_delivery_tab(i).ultimate_dropoff_date;
                l_dropoff_stop_info.planned_departure_date := x_delivery_tab(i).ultimate_dropoff_date;
                l_dropoff_rec_attr_tab(1):=l_dropoff_stop_info;
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Creating dropoff stop');
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_GRP.CREATE_UPDATE_STOP',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;


                WSH_TRIP_STOPS_GRP.CREATE_UPDATE_STOP(
                    p_api_version_number    => l_api_version_number,
                    p_init_msg_list         => l_init_msg_list,
                    p_commit                => l_commit,
                    p_in_rec                => l_stop_in_rec,
                    p_rec_attr_tab          => l_dropoff_rec_attr_tab,
                    x_stop_out_tab          => l_dropoff_stop_out_tab,
                    x_return_status         => l_return_status,
                    x_msg_count             => l_msg_count,
                    x_msg_data              => l_msg_data,
                    x_stop_wt_vol_out_tab   => l_stop_wt_vol_out_tab);

                IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS)
                THEN
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name, 'Dropoff Stop created succesfully');
                    END IF;
                ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
                OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
                THEN
                    WSH_UTIL_CORE.PrintMsg('Error occurred in WSH_TRIP_STOPS_GRP.CREATE_UPDATE_STOP');
                    IF l_debug_on THEN
                        FOR m in 1..l_msg_count
                        LOOP
                            l_message := fnd_msg_pub.get(m,'F');
                            l_message := replace(l_message,chr(0),' ');
                            WSH_DEBUG_SV.logmsg(l_module_name,l_message);
                        END LOOP;
                    END IF;
                    fnd_msg_pub.delete_msg();
                    raise FND_API.G_EXC_ERROR;

                ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING)
                THEN
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Dropoff Stop created with warnings');
                        FOR m in 1..l_msg_count
                        LOOP
                            l_message := fnd_msg_pub.get(m,'F');
                            l_message := replace(l_message,chr(0),' ');
                            WSH_DEBUG_SV.logmsg(l_module_name,l_message);
                        END LOOP;
                    END IF;
                    fnd_msg_pub.delete_msg();
                END IF;

                -- Assign delivery to the trip

                l_action_prms.caller :='WSH';
                l_action_prms.phase :=NULL;

                l_action_prms.action_code := 'ASSIGN-TRIP';
                l_action_prms.trip_id := l_trip_id;
                l_action_prms.trip_name := l_trip_name;

                l_action_prms.pickup_stop_id := l_pickup_stop_out_tab(l_pickup_stop_out_tab.FIRST).stop_id;
                l_action_prms.pickup_loc_id := x_delivery_tab(i).intmed_ship_to_location_id;
                l_action_prms.pickup_arr_date := x_delivery_addnl_attr_tab(i).intermediate_pickup_date;
                l_action_prms.pickup_dep_date := x_delivery_addnl_attr_tab(i).intermediate_pickup_date;

                l_action_prms.dropoff_stop_id := l_dropoff_stop_out_tab(l_dropoff_stop_out_tab.FIRST).stop_id;
                l_action_prms.dropoff_loc_id :=    x_delivery_tab(i).ultimate_dropoff_location_id;
                l_action_prms.dropoff_arr_date := x_delivery_tab(i).ultimate_dropoff_date;
                l_action_prms.dropoff_dep_date := x_delivery_tab(i).ultimate_dropoff_date;

                l_rec_attr_tab(1).delivery_id := x_delivery_tab(i).delivery_id;
                l_rec_attr_tab(1).organization_id := x_delivery_tab(i).organization_id;
                l_rec_attr_tab(1).status_code := x_delivery_tab(i).status_code;
                l_rec_attr_tab(1).planned_flag := x_delivery_tab(i).planned_flag;
                l_rec_attr_tab(1).NAME := x_delivery_tab(i).NAME;
                l_rec_attr_tab(1).INITIAL_PICKUP_DATE := x_delivery_tab(i).INITIAL_PICKUP_DATE;
                l_rec_attr_tab(1).INITIAL_PICKUP_LOCATION_ID := x_delivery_tab(i).INITIAL_PICKUP_LOCATION_ID;
                l_rec_attr_tab(1).ULTIMATE_DROPOFF_LOCATION_ID := x_delivery_tab(i).ULTIMATE_DROPOFF_LOCATION_ID;
                l_rec_attr_tab(1).ULTIMATE_DROPOFF_DATE := x_delivery_tab(i).ULTIMATE_DROPOFF_DATE;
                l_rec_attr_tab(1).CUSTOMER_ID := x_delivery_tab(i).CUSTOMER_ID;
                l_rec_attr_tab(1).INTMED_SHIP_TO_LOCATION_ID := x_delivery_tab(i).INTMED_SHIP_TO_LOCATION_ID;
                l_rec_attr_tab(1).SHIP_METHOD_CODE := x_delivery_tab(i).SHIP_METHOD_CODE;
                l_rec_attr_tab(1).DELIVERY_TYPE := x_delivery_tab(i).DELIVERY_TYPE;
                l_rec_attr_tab(1).CARRIER_ID := x_delivery_tab(i).CARRIER_ID;
                l_rec_attr_tab(1).SERVICE_LEVEL := x_delivery_tab(i).SERVICE_LEVEL;
                l_rec_attr_tab(1).MODE_OF_TRANSPORT := x_delivery_tab(i).MODE_OF_TRANSPORT;
                l_rec_attr_tab(1).shipment_direction := x_delivery_tab(i).shipment_direction;
                l_rec_attr_tab(1).party_id := x_delivery_tab(i).party_id;
                l_rec_attr_tab(1).shipping_control := x_delivery_tab(i).shipping_control;

                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Assigning delivery to trip');
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERIES_GRP.Delivery_Action',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;


                WSH_DELIVERIES_GRP.Delivery_Action(
                    p_api_version_number     =>  l_api_version_number,
                    p_init_msg_list      =>  l_init_msg_list,
                    p_commit         =>  l_commit,
                    p_action_prms        =>  l_action_prms,
                    p_rec_attr_tab       =>  l_rec_attr_tab,
                    x_delivery_out_rec       =>  l_delivery_out_rec,
                    x_defaults_rec       =>  l_defaults_rec,
                    x_return_status      =>  l_return_status,
                    x_msg_count          =>  l_msg_count,
                    x_msg_data           =>  l_msg_data);

                IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS)
                THEN
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name, 'Assigned delivery to trip succesfully');
                    END IF;
                ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
                OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
                THEN
                    WSH_UTIL_CORE.PrintMsg('Error occurred in WSH_DELIVERIES_GRP.Delivery_Action');
                    IF l_debug_on THEN
                        FOR m in 1..l_msg_count
                        LOOP
                            l_message := fnd_msg_pub.get(m,'F');
                            l_message := replace(l_message,chr(0),' ');
                            WSH_DEBUG_SV.logmsg(l_module_name,l_message);
                        END LOOP;
                    END IF;
                    fnd_msg_pub.delete_msg();
                    raise FND_API.G_EXC_ERROR;

                ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING)
                THEN
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Assigned delivery to trip with warnings');
                        FOR m in 1..l_msg_count
                        LOOP
                            l_message := fnd_msg_pub.get(m,'F');
                            l_message := replace(l_message,chr(0),' ');
                            WSH_DEBUG_SV.logmsg(l_module_name,l_message);
                        END LOOP;
                    END IF;
                    fnd_msg_pub.delete_msg();
                END IF;
                WSH_UTIL_CORE.PrintMsg('  Delivery: '||x_delivery_tab(i).delivery_id||', Trip: '||l_trip_name);

            END IF;

            i := x_delivery_tab.NEXT(i);

        EXCEPTION
            WHEN FND_API.G_EXC_ERROR
            THEN
                ROLLBACK TO CREATE_TRIP;
                WSH_UTIL_CORE.PrintMsg('Exception occurred while creating deconsol trip for delivery '||l_del_id);
                x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                i := x_delivery_tab.NEXT(i);
                IF l_trip_cr_flag
                THEN
                    x_trips_all(l_trips_all_count) := null;
                    l_trips_all_count := l_trips_all_count-1;
                END IF;
            WHEN OTHERS
            THEN
                ROLLBACK TO CREATE_TRIP;
                WSH_UTIL_CORE.PrintMsg('Exception occurred while creating deconsol trip for delivery '||l_del_id);
                x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                END IF;
                i := x_delivery_tab.NEXT(i);
                IF l_trip_cr_flag
                THEN
                    x_trips_all(l_trips_all_count) := null;
                    l_trips_all_count := l_trips_all_count-1;
                END IF;
        END;
    END LOOP;
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR
    THEN
        WSH_UTIL_CORE.PrintMsg('Exception occurred in Create_Deconsol_Trip');
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
        END IF;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    WHEN OTHERS
    THEN
        WSH_UTIL_CORE.PrintMsg('SQLCODE: '||sqlcode||' SQLERRM: '||sqlerrm);
        WSH_UTIL_CORE.PrintMsg('Exception occurred in Create_Deconsol_Trip');
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
END Create_Deconsol_Trips;

PROCEDURE Add_For_Consolidation(
            p_delivery_rec    IN WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type,
            p_del_weight      IN NUMBER,
            p_weight_uom      IN VARCHAR2,
            p_max_weight      IN NUMBER,
            p_ignore_weight   IN BOOLEAN,
            x_consol_tab      IN OUT NOCOPY consolidation_tab,
            x_consol_index    OUT NOCOPY NUMBER,
            x_return_status   OUT NOCOPY VARCHAR2)
IS
    i               NUMBER;
    l_consol_rec    consolidation_rec;
    l_del_count     NUMBER;
    l_consol_count  NUMBER;
    l_module_name   CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ADD_FOR_CONSOLIDATION';
    l_debug_on      BOOLEAN;

BEGIN

    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;

    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        WSH_DEBUG_SV.log(l_module_name,'delivery_id ',p_delivery_rec.delivery_id);
        WSH_DEBUG_SV.log(l_module_name,'Current Time is ',SYSDATE);
    END IF;

    l_consol_count := x_consol_tab.LAST;
    IF l_consol_count IS NULL
    THEN
        l_consol_count := 0;
    END IF;

    i := x_consol_tab.FIRST;
    WHILE i IS NOT NULL
    LOOP
    --{
        IF x_consol_tab(i).total_weight + p_del_weight <= p_max_weight -- check for weight
        OR p_ignore_weight = TRUE    -- no need to check weight. add to the first record
        THEN
            -- found a consolidation which can accomodate the delivery
            l_del_count := x_consol_tab(i).delivery_tab.LAST;
            x_consol_tab(i).delivery_tab(l_del_count + 1) := p_delivery_rec;
            x_consol_tab(i).total_weight := x_consol_tab(i).total_weight + p_del_weight;
            x_consol_index := x_consol_tab(i).consol_index;
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Adding to existing consolidation group');
            END IF;
            EXIT;
        END IF;

        i := x_consol_tab.NEXT(i);
    --}
    END LOOP;

    -- no match found
    IF i IS NULL
    THEN
        -- make a new rec
        l_consol_rec.consol_index := l_consol_count + 1;
        l_consol_rec.total_weight := p_del_weight;
        l_consol_rec.weight_uom := p_weight_uom;
        l_consol_rec.delivery_tab(1) := p_delivery_rec;
        x_consol_tab(l_consol_count+1) := l_consol_rec;
        x_consol_index := l_consol_rec.consol_index;
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Creating new consolidation group');
        END IF;

    END IF;

    WSH_UTIL_CORE.PrintMsg('    Delivery: '||p_delivery_rec.delivery_id||', Consolidation Index: '||x_consol_index);
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
EXCEPTION
    WHEN OTHERS
    THEN
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
END Add_For_Consolidation;

END WSH_MDC_SRS;


/
