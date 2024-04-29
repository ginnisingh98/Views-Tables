--------------------------------------------------------
--  DDL for Package Body WSH_FTE_COMP_CONSTRAINT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_FTE_COMP_CONSTRAINT_GRP" as
/* $Header: WSHFTGPB.pls 120.6 2006/05/04 23:17:59 alksharm ship $ */

-- Global Variables

--   p_action_code  can be    G_ACTION_CREATE or G_ACTION_UPDATE

--========================================================================
-- PROCEDURE : validate_constraint         To be called by external module
--                                         Currently called by WMS only
--
-- PARAMETERS: p_api_version_number        Application standard : known API version number
--             p_init_msg_list             FND_API.G_TRUE to reset list
--             p_commit                    Application standard : to commit work
--             p_entity_tab                Table of entity records to validate
--                                         Currently supports Delivery and Trip
--             x_msg_count                 Number of messages in the list
--             x_msg_data                  Text of messages
--             x_return_status             Return status
-- COMMENT   : This procedure is used by external modules perform following actions
--             A. Update/Manually Create a delivery (UPD)
--             B. Update/Manually Create a Trip
--========================================================================

PROCEDURE validate_constraint(
             p_api_version_number     IN   NUMBER,
             p_init_msg_list          IN   VARCHAR2,
             p_commit                 IN   VARCHAR2    DEFAULT FND_API.G_FALSE,
             p_entity_tab             IN   OUT NOCOPY  wshfte_ccin_tab_type,
             x_msg_count              OUT  NOCOPY  NUMBER,
             x_msg_data               OUT  NOCOPY  VARCHAR2,
             x_return_status          OUT  NOCOPY  VARCHAR2)
IS

    i                          NUMBER := 0;
    k                          NUMBER := 0;
    l                          NUMBER := 0;
    l_return_status            VARCHAR2(1);
    l_api_version_number       CONSTANT NUMBER := 1.0;
    l_api_name                 CONSTANT VARCHAR2(30):= 'validate_constraint';

    l_validate_result          VARCHAR2(1) := 'S'; --  Constraint Validation result : S / F
    l_action_code              VARCHAR2(30) := NULL;
    l_dummy_exception_list     WSH_UTIL_CORE.column_tab_type;

    l_dummy_in_ids             WSH_UTIL_CORE.id_tab_type;   -- Either of the next two
    l_delivery_info            WSH_FTE_CONSTRAINT_FRAMEWORK.delivery_ccinfo_tab_type;
    l_delivery_rec             WSH_FTE_CONSTRAINT_FRAMEWORK.delivery_ccinfo_rec_type;
    l_dlvy_assigned_lines      WSH_FTE_CONSTRAINT_FRAMEWORK.detail_ccinfo_tab_type;
    l_target_trip              WSH_FTE_CONSTRAINT_FRAMEWORK.trip_ccinfo_rec_type;
    l_target_tripstops         WSH_FTE_CONSTRAINT_FRAMEWORK.target_tripstop_cc_rec_type;
    l_target_trip_assign_dels  WSH_FTE_CONSTRAINT_FRAMEWORK.delivery_ccinfo_tab_type;
    l_target_trip_dlvy_lines   WSH_FTE_CONSTRAINT_FRAMEWORK.detail_ccinfo_tab_type;
    l_target_trip_incl_stops   WSH_FTE_CONSTRAINT_FRAMEWORK.stop_ccinfo_tab_type;
    l_line_groups              WSH_FTE_COMP_CONSTRAINT_PKG.line_group_tab_type;
    l_group_info               WSH_FTE_COMP_CONSTRAINT_PKG.cc_group_tab_type;
    l_failed_lines             WSH_FTE_COMP_CONSTRAINT_PKG.failed_line_tab_type;

    l_trip_info                WSH_FTE_CONSTRAINT_FRAMEWORK.trip_ccinfo_tab_type;
    l_trip_rec                 WSH_FTE_CONSTRAINT_FRAMEWORK.trip_ccinfo_rec_type;
    l_trip_assigned_dels       WSH_FTE_CONSTRAINT_FRAMEWORK.delivery_ccinfo_tab_type;
    l_trip_dlvy_lines          WSH_FTE_CONSTRAINT_FRAMEWORK.detail_ccinfo_tab_type;
    l_trip_incl_stops          WSH_FTE_CONSTRAINT_FRAMEWORK.stop_ccinfo_tab_type;
    l_fail_trips               WSH_UTIL_CORE.id_tab_type;

    l_debug_on                 CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
    l_module_name              CONSTANT VARCHAR2(100) := 'wsh.plsql.' || g_package_name || '.' || 'validate_constraint';

BEGIN

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    IF l_debug_on THEN
     wsh_debug_sv.push (l_module_name);
    END IF;

    ---------------------------------------

    IF NOT FND_API.Compatible_API_Call
      ( l_api_version_number,
        p_api_version_number,
        l_api_name,
        g_package_name
       )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
    END IF;

    -----------------------------------------

    i := p_entity_tab.FIRST;
    IF i IS NOT NULL THEN
    LOOP

     -- Defaulted to Success
     p_entity_tab(i).x_validate_status := 'S';

     IF l_debug_on THEN
        wsh_debug_sv.logmsg(l_module_name,'entity type : '||p_entity_tab(i).p_entity_type);
        wsh_debug_sv.logmsg(l_module_name,'entity id : '||p_entity_tab(i).p_entity_id);
        wsh_debug_sv.logmsg(l_module_name,'action code : '||p_entity_tab(i).p_action_code);
     END IF;

     IF p_entity_tab(i).p_action_code <> G_ACTION_UPDATE THEN

        GOTO entity_nextpass;
     END IF;

     IF p_entity_tab(i).p_entity_type = G_TRIP THEN

       -- Populate l_trip_rec

		l_trip_info(i).TRIP_ID			:= p_entity_tab(i).p_entity_id;
     		l_trip_info(i).exists_in_database       :='Y';
     		l_trip_info(i).PLANNED_FLAG		:= p_entity_tab(i).p_PLANNED_FLAG;
     		l_trip_info(i).STATUS_CODE		:= p_entity_tab(i).p_STATUS_CODE;
     		l_trip_info(i).VEHICLE_ITEM_ID		:= p_entity_tab(i).p_VEH_ITEM_ID;
     		l_trip_info(i).CARRIER_ID		:= p_entity_tab(i).p_CARRIER_ID;
     		l_trip_info(i).SHIP_METHOD_CODE		:= p_entity_tab(i).p_SHIPMETHOD_CODE;
     		l_trip_info(i).VEHICLE_ORGANIZATION_ID	:= p_entity_tab(i).p_organization_id;
     		l_trip_info(i).SERVICE_LEVEL		:= p_entity_tab(i).p_SERVICE_LEVEL;
     		l_trip_info(i).MODE_OF_TRANSPORT	:= p_entity_tab(i).p_MODE_CODE;


     ELSIF p_entity_tab(i).p_entity_type = G_DELIVERY THEN

       -- Populate l_delivery_rec

      l_delivery_info(i).DELIVERY_ID                       := p_entity_tab(i).p_entity_id;
      l_delivery_info(i).exists_in_database                := 'Y';
      l_delivery_info(i).PLANNED_FLAG                      := p_entity_tab(i).p_PLANNED_FLAG;
      l_delivery_info(i).STATUS_CODE                       := p_entity_tab(i).p_STATUS_CODE;
      l_delivery_info(i).INITIAL_PICKUP_LOCATION_ID        := p_entity_tab(i).p_SHIP_FROM_LOCATION_ID;
      l_delivery_info(i).ULTIMATE_DROPOFF_LOCATION_ID      := p_entity_tab(i).p_SHIP_TO_LOCATION_ID;
      l_delivery_info(i).CUSTOMER_ID                       := p_entity_tab(i).p_CUSTOMER_ID;
      l_delivery_info(i).INTMED_SHIP_TO_LOCATION_ID        := p_entity_tab(i).p_INTMED_LOCATION_ID;
      l_delivery_info(i).SHIP_METHOD_CODE                  := p_entity_tab(i).p_SHIPMETHOD_CODE;
      l_delivery_info(i).CARRIER_ID                        := p_entity_tab(i).p_CARRIER_ID;
      l_delivery_info(i).ORGANIZATION_ID                   := p_entity_tab(i).p_ORGANIZATION_ID;
      l_delivery_info(i).SERVICE_LEVEL                     := p_entity_tab(i).p_SERVICE_LEVEL;
      l_delivery_info(i).MODE_OF_TRANSPORT                 := p_entity_tab(i).p_MODE_CODE;


      END IF;

       <<entity_nextpass>>

       EXIT WHEN i = p_entity_tab.LAST;
       i := p_entity_tab.NEXT(i);

    END LOOP;
    END IF;

     IF l_trip_info.COUNT > 0 THEN

       l_action_code := WSH_FTE_CONSTRAINT_FRAMEWORK.G_UPDATE_TRIP;

       WSH_FTE_CONSTRAINT_FRAMEWORK.validate_constraint_trip(
             p_init_msg_list            =>      p_init_msg_list,
             p_action_code              =>      l_action_code,
             p_exception_list           =>      l_dummy_exception_list,
             p_trip_info                =>      l_trip_info,
             p_trip_assigned_dels       =>      l_trip_assigned_dels,
             p_trip_dlvy_lines          =>      l_trip_dlvy_lines,
             p_trip_incl_stops          =>      l_trip_incl_stops,
             x_fail_trips               =>      l_fail_trips,
             x_validate_result          =>      l_validate_result,
             x_msg_count                =>      x_msg_count,
             x_msg_data                 =>      x_msg_data,
             x_return_status            =>      l_return_status);


           IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSE
              x_return_status := l_return_status;
                 IF l_debug_on THEN
                     wsh_debug_sv.logmsg(l_module_name,'failed line count : '||l_fail_trips.COUNT);
                 END IF;

              IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN

                 l:=p_entity_tab.FIRST;
                 IF l IS NOT NULL THEN
                 LOOP

                   -- LOOP over l_fail_trips
                   k:=l_fail_trips.FIRST;
                   IF k IS NOT NULL THEN
                   LOOP

                      IF p_entity_tab(l).p_entity_id = l_fail_trips(k) THEN
                         p_entity_tab(l).x_validate_status := 'F';
                         IF l_debug_on THEN
                            wsh_debug_sv.logmsg(l_module_name,'failed line : '||l_fail_trips(k)||' found for entity : '||p_entity_tab(l).p_entity_id);
                         END IF;
                         EXIT;
                      END IF;

                      EXIT WHEN k=l_fail_trips.LAST;
                      k:=l_fail_trips.NEXT(k);
                   END LOOP;
                   END IF;

                   EXIT WHEN l=p_entity_tab.LAST;
                   l:=p_entity_tab.NEXT(l);
                 END LOOP;
                 END IF;

              END IF;
           END IF;
     END IF; -- l_trip_info

     IF l_delivery_info.COUNT > 0 THEN

       l_action_code := WSH_FTE_CONSTRAINT_FRAMEWORK.G_UPDATE_DLVY;

       WSH_FTE_CONSTRAINT_FRAMEWORK.validate_constraint_dlvy(
             p_init_msg_list            =>      p_init_msg_list,
             p_action_code              =>      l_action_code,
             p_exception_list           =>      l_dummy_exception_list,
             p_in_ids                   =>      l_dummy_in_ids,
             p_delivery_info            =>      l_delivery_info,
             p_dlvy_assigned_lines      =>      l_dlvy_assigned_lines,
             p_target_trip              =>      l_target_trip,
             p_target_tripstops         =>      l_target_tripstops,
             p_target_trip_assign_dels  =>      l_target_trip_assign_dels,
             p_target_trip_dlvy_lines   =>      l_target_trip_dlvy_lines,
             p_target_trip_incl_stops   =>      l_target_trip_incl_stops,
             x_validate_result          =>      l_validate_result,
             x_line_groups              =>      l_line_groups,
             x_group_info               =>      l_group_info,
             x_failed_lines             =>      l_failed_lines,
             x_msg_count                =>      x_msg_count,
             x_msg_data                 =>      x_msg_data,
             x_return_status            =>      l_return_status);


           IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSE
              x_return_status := l_return_status;

              IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN

                 IF l_debug_on THEN
                     wsh_debug_sv.logmsg(l_module_name,'failed line count : '||l_failed_lines.COUNT);
                 END IF;

                 l:=p_entity_tab.FIRST;
                 IF l IS NOT NULL THEN
                 LOOP

                   -- LOOP over l_failed_lines
                   k:=l_failed_lines.FIRST;
                   IF k IS NOT NULL THEN
                   LOOP

                      IF p_entity_tab(l).p_entity_id = l_failed_lines(k).entity_line_id THEN
                         p_entity_tab(l).x_validate_status := 'F';
                         IF l_debug_on THEN
                            wsh_debug_sv.logmsg(l_module_name,'failed line : '||l_failed_lines(k).entity_line_id||' found for entity : '||p_entity_tab(l).p_entity_id);
                         END IF;

                         EXIT;
                      END IF;

                      EXIT WHEN k=l_failed_lines.LAST;
                      k:=l_failed_lines.NEXT(k);
                   END LOOP;
                   END IF;

                   EXIT WHEN l=p_entity_tab.LAST;
                   l:=p_entity_tab.NEXT(l);
                 END LOOP;
                 END IF;

              END IF;
           END IF;

     END IF;

     --
     IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN others THEN
      WSH_UTIL_CORE.default_handler('WSH_FTE_COMP_CONSTRAINT_GRP.validate_constraint');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --

END validate_constraint;

--***************************************************************************--
--========================================================================
-- PROCEDURE : is_valid_consol
--
-- PARAMETERS: p_init_msg_list             FND_API.G_TRUE to reset list
--             p_input_delivery_id_tab     Table of delivery records to process
--
--             p_target_consol_delivery_id target consol delivery
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
                          )
IS

l_cc_action_code                VARCHAR2(3);
l_validate_result               VARCHAR2(1) := 'S';
l_line_groups                   WSH_FTE_COMP_CONSTRAINT_PKG.line_group_tab_type;
l_group_info                    WSH_FTE_COMP_CONSTRAINT_PKG.cc_group_tab_type;
l_failed_lines                  WSH_FTE_COMP_CONSTRAINT_PKG.failed_line_tab_type;
l_msg_count                     NUMBER;
l_msg_data                      VARCHAR2(2000) := NULL;
l_return_status                 VARCHAR2(1);
l_in_ids                        WSH_UTIL_CORE.id_tab_type;
l_deconsol_location             NUMBER;
l_prev_deconsol_location        NUMBER;
l_consol_drop_off_loc           NUMBER;
l_consol_trip_id                NUMBER;
l_prev_consolidation_del        NUMBER;
l_pre_consolidation_del         NUMBER;
l_target_trip                   WSH_FTE_CONSTRAINT_FRAMEWORK.trip_ccinfo_rec_type;
l_target_trip_stop              WSH_FTE_CONSTRAINT_FRAMEWORK.target_tripstop_cc_rec_type;
d_itr                           NUMBER;
l_cc_exception_list             WSH_UTIL_CORE.Column_Tab_Type;
x_output_id_tab                 WSH_FTE_CONSTRAINT_FRAMEWORK.deconsol_output_tab_type;

l_cc_delivery_info	        WSH_FTE_CONSTRAINT_FRAMEWORK.delivery_ccinfo_tab_type;
l_cc_dlvy_assigned_lines	WSH_FTE_CONSTRAINT_FRAMEWORK.detail_ccinfo_tab_type;
l_cc_target_trip_assign_dels	WSH_FTE_CONSTRAINT_FRAMEWORK.delivery_ccinfo_tab_type;
l_cc_target_trip_dlvy_lines	WSH_FTE_CONSTRAINT_FRAMEWORK.detail_ccinfo_tab_type;
l_cc_target_trip_incl_stops	WSH_FTE_CONSTRAINT_FRAMEWORK.stop_ccinfo_tab_type;
l_delivery_info                 WSH_FTE_CONSTRAINT_FRAMEWORK.delivery_ccinfo_tab_type;

l_module_name            CONSTANT VARCHAR2(100) := 'wsh.plsql.' || g_package_name || '.' || 'is_valid_consol';
l_debug_on               CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;

CURSOR c_get_dlvy_drop_off_location(c_delivery_id IN NUMBER) IS
SELECT
   wnd.ULTIMATE_DROPOFF_LOCATION_ID
FROM wsh_new_deliveries wnd
WHERE wnd.delivery_id = c_delivery_id;

CURSOR c_get_consol_dlvy(c_delivery_id IN NUMBER) IS
SELECT
   wda.parent_delivery_id
FROM wsh_delivery_assignments wda
WHERE wda.delivery_id = c_delivery_id
AND TYPE= 'C';

CURSOR c_get_dlvy_trip_id(c_delivery_id IN NUMBER) IS
SELECT
    wts.TRIP_ID, 'Y'as EXISTS_IN_DATABASE, wt. NAME, wt.PLANNED_FLAG, wt.STATUS_CODE,
    wt.VEHICLE_ITEM_ID, wt.VEHICLE_NUMBER, wt.CARRIER_ID, wt.SHIP_METHOD_CODE,
    wt.VEHICLE_ORGANIZATION_ID, wt.VEHICLE_NUM_PREFIX, wt.SERVICE_LEVEL, wt.MODE_OF_TRANSPORT
FROM wsh_trip_stops wts, wsh_delivery_legs wdl, wsh_trips wt
WHERE wdl.delivery_id = c_delivery_id
AND wdl.pick_up_stop_id = wts.stop_id
AND wts.trip_id = wt.trip_id;


BEGIN
--{
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    IF l_debug_on THEN
      wsh_debug_sv.push (l_module_name);
    END IF;

    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'p_target_consol_delivery_id' || p_target_consol_delivery_id);
    END IF;

    l_deconsol_location := NULL;

    IF WSH_FTE_CONSTRAINT_FRAMEWORK.g_is_fte_installed = 'Y' THEN
        --
        -- check if deliveries do not have any conflicting constraints so that
        -- they can be put in one group
        --
        l_cc_action_code := WSH_FTE_CONSTRAINT_FRAMEWORK.G_AUTOCRT_MDC;

        WSH_FTE_CONSTRAINT_FRAMEWORK.validate_constraint_dlvy(
                 p_init_msg_list            =>	p_init_msg_list,
                 p_action_code              =>	l_cc_action_code,
                 p_exception_list           =>	l_cc_exception_list,
                 p_delivery_info            =>	l_cc_delivery_info,
                 p_in_ids			=>	p_input_delivery_id_tab,
                 p_dlvy_assigned_lines      =>	l_cc_dlvy_assigned_lines,
                 p_target_trip              =>      l_target_trip,
                 p_target_tripstops         =>      l_target_trip_stop,
                 p_target_trip_assign_dels  =>	l_cc_target_trip_assign_dels,
                 p_target_trip_dlvy_lines   =>	l_cc_target_trip_dlvy_lines,
                 p_target_trip_incl_stops   =>	l_cc_target_trip_incl_stops,
                 x_validate_result          =>	l_validate_result,
                 x_failed_lines             =>	l_failed_lines,
                 x_line_groups              =>	l_line_groups,
                 x_group_info               =>	l_group_info,
                 x_msg_count                =>	l_msg_count,
                 x_msg_data                 =>	l_msg_data,
                 x_return_status            =>	l_return_status);

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'l_return_status ' || l_return_status);
            WSH_DEBUG_SV.logmsg(l_module_name,'l_group_info.COUNT ' || l_group_info.COUNT);
            WSH_DEBUG_SV.logmsg(l_module_name,'l_failed_lines.COUNT ' || l_failed_lines.COUNT);
        END IF;
        --
        -- If more than one group formed, error out
        --
        -- AG number of groups is record structure l_group_info not l_line_groups
        --IF l_line_groups.COUNT > 1 OR l_failed_lines.COUNT > 0 OR (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
        IF l_group_info.COUNT > 1 OR l_failed_lines.COUNT > 0 OR (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
                AND l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
        -- AG
        -- Treat l_return_status = WARNING as success

            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('WSH','WSH_CONSOL_VALIDATION_ERROR');
            FND_MSG_PUB.ADD;
            IF l_debug_on THEN
                wsh_debug_sv.pop (l_module_name);
            END IF;
            RETURN;
        END IF;

    END IF; -- FTE is installed -- Bug 5194370

    --{

    --
    -- loop through deliveries in order to find deconsolidation location for each delivery
    --

    d_itr := p_input_delivery_id_tab.FIRST;

    IF d_itr IS NOT NULL THEN
    --{
        LOOP
        --{
            l_in_ids(1) := p_input_delivery_id_tab(d_itr);

            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'p_input_delivery_id_tab ' || p_input_delivery_id_tab(d_itr));
            END IF;

            -- AG
            -- Still has not implemented latest comments
            -- skattama

            OPEN c_get_consol_dlvy(l_in_ids(1));
            FETCH c_get_consol_dlvy INTO l_pre_consolidation_del;
            CLOSE c_get_consol_dlvy;
            IF l_pre_consolidation_del IS NOT NULL THEN
              IF l_prev_consolidation_del IS NULL THEN
                l_prev_consolidation_del := l_pre_consolidation_del;
              ELSIF l_prev_consolidation_del <> l_pre_consolidation_del OR l_pre_consolidation_del <> p_target_consol_delivery_id THEN
                x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                FND_MESSAGE.SET_NAME('WSH','WSH_MULTICONSOL_ERROR');
                FND_MSG_PUB.ADD;
                IF l_debug_on THEN
                    wsh_debug_sv.pop (l_module_name);
                END IF;
                RETURN;
              END IF;
            END IF;
            -- skattama

            WSH_FTE_CONSTRAINT_FRAMEWORK.validate_constraint_deconsol(
                                    p_init_msg_list          => p_init_msg_list,
                                    p_delivery_info          => l_delivery_info,
                                    p_in_ids                 => l_in_ids,
                                    p_caller                 => p_caller,
                                    x_output_id_tab          => x_output_id_tab,
                                    x_return_status          => l_return_status,
                                    x_msg_count              => l_msg_count,
                                    x_msg_data               => l_msg_data);

            --
            -- If deconsolidation location found for any of the
            -- delivery is different, error out
            --

            IF x_output_id_tab(1).validation_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN

                IF l_delivery_info.COUNT > 0 THEN
                   l_delivery_info.DELETE;
                END IF;

                l_deconsol_location :=   x_output_id_tab(x_output_id_tab.FIRST).deconsol_location;

                IF l_prev_deconsol_location IS NULL THEN
                    l_prev_deconsol_location := l_deconsol_location;
                END IF;

                IF l_deconsol_location <> l_prev_deconsol_location THEN
                    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                    FND_MESSAGE.SET_NAME('WSH','WSH_CONSOL_VALIDATION_ERROR');
                    FND_MSG_PUB.ADD;
                    IF l_debug_on THEN
                        wsh_debug_sv.pop (l_module_name);
                    END IF;
                    RETURN;
                END IF;
            ELSE
                x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                FND_MESSAGE.SET_NAME('WSH','WSH_CONSOL_VALIDATION_ERROR');
                FND_MSG_PUB.ADD;
                IF l_debug_on THEN
                    wsh_debug_sv.pop (l_module_name);
                END IF;
                RETURN;
            END IF;
            EXIT WHEN d_itr = p_input_delivery_id_tab.LAST;
            d_itr := p_input_delivery_id_tab.NEXT(d_itr);
            l_prev_deconsol_location := l_deconsol_location;
       --}
       END LOOP;
    --}
    END IF;

    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'l_deconsol_location' || l_deconsol_location);
    END IF;

        -- AG
    IF l_deconsol_location IS NOT NULL AND p_target_consol_delivery_id IS NOT NULL THEN
    --IF p_target_consol_delivery_id IS NOT NULL THEN
    --{

        -- get ultimate drop off location for target consol

        OPEN c_get_dlvy_drop_off_location(p_target_consol_delivery_id);
            FETCH c_get_dlvy_drop_off_location INTO l_consol_drop_off_loc;
        CLOSE c_get_dlvy_drop_off_location;

        --
        -- if drop off location for consol is same as that of deconsol location of
        -- input delivery, check if deliveries do not have any conflicting constraints with
        -- deliveries in target consol
        --

        -- AG
        IF l_consol_drop_off_loc = l_deconsol_location THEN
        --{
            IF WSH_FTE_CONSTRAINT_FRAMEWORK.g_is_fte_installed = 'Y' THEN -- Bug 5194370
                OPEN c_get_dlvy_trip_id(p_target_consol_delivery_id);
                    FETCH c_get_dlvy_trip_id INTO l_target_trip;
                CLOSE c_get_dlvy_trip_id;

                l_target_trip_stop.dropoff_location_id   := l_deconsol_location;

                l_cc_action_code := WSH_FTE_CONSTRAINT_FRAMEWORK.G_ASSIGN_DLVY_TRIP;

                WSH_FTE_CONSTRAINT_FRAMEWORK.validate_constraint_dlvy(
                 p_init_msg_list            =>	p_init_msg_list,
                 p_action_code              =>	l_cc_action_code,
                 p_exception_list           =>	l_cc_exception_list,
                 p_delivery_info            =>	l_cc_delivery_info,
                 p_in_ids		        =>	p_input_delivery_id_tab,
                 p_dlvy_assigned_lines      =>	l_cc_dlvy_assigned_lines,
                 p_target_trip              =>      l_target_trip,
                 p_target_tripstops         =>      l_target_trip_stop,
                 p_target_trip_assign_dels  =>	l_cc_target_trip_assign_dels,
                 p_target_trip_dlvy_lines   =>	l_cc_target_trip_dlvy_lines,
                 p_target_trip_incl_stops   =>	l_cc_target_trip_incl_stops,
                 x_validate_result          =>	l_validate_result,
                 x_failed_lines             =>	l_failed_lines,
                 x_line_groups              =>	l_line_groups,
                 x_group_info               =>	l_group_info,
                 x_msg_count                =>	l_msg_count,
                 x_msg_data                 =>	l_msg_data,
                 x_return_status            =>	l_return_status);

                -- AG
                -- Treat warning as Success

                IF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS OR l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
                    x_deconsolidation_location := l_deconsol_location;
                ELSE
                   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                   FND_MESSAGE.SET_NAME('WSH','WSH_CONSOL_VALIDATION_ERROR');
                   FND_MSG_PUB.ADD;
                   IF l_debug_on THEN
                        wsh_debug_sv.pop (l_module_name);
                    END IF;
                   RETURN;
                END IF;
            ELSE -- Bug 5194370
                x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
                x_deconsolidation_location := l_deconsol_location;
            END IF;

        --}
        ELSE
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('WSH','WSH_CONSOL_VALIDATION_ERROR');
            FND_MSG_PUB.ADD;
            IF l_debug_on THEN
                wsh_debug_sv.pop (l_module_name);
            END IF;
            RETURN;
        END IF;
    --}
    --ELSE
    -- AG
    -- If input deliveries do not get back any deconsol_location above
    -- should they rather be allowed to be assigned to p_target_consol_delivery_id
    ELSIF p_target_consol_delivery_id IS NOT NULL THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('WSH','WSH_CONSOL_VALIDATION_ERROR');
        FND_MSG_PUB.ADD;
        IF l_debug_on THEN
            wsh_debug_sv.pop (l_module_name);
        END IF;
        RETURN;
    ELSIF l_deconsol_location IS NOT NULL THEN
        x_deconsolidation_location := l_deconsol_location;
    END IF;

    FND_MSG_PUB.Count_And_Get (
     p_count         =>      x_msg_count,
     p_data          =>      x_msg_data ,
     p_encoded       =>      FND_API.G_FALSE );

    IF l_debug_on THEN
      wsh_debug_sv.log (l_module_name,'No. of messages stacked : ',to_char(x_msg_count));
      wsh_debug_sv.pop (l_module_name);
    END IF;

 EXCEPTION

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;

WHEN OTHERS THEN
      IF c_get_dlvy_drop_off_location%ISOPEN THEN
         CLOSE c_get_dlvy_drop_off_location;
      END IF;
      IF c_get_dlvy_trip_id%ISOPEN THEN
         CLOSE c_get_dlvy_trip_id;
      END IF;
      WSH_UTIL_CORE.default_handler('WSH_FTE_COMP_CONSTRAINT_GRP.is_valid_consol');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
--}
END is_valid_consol;

END WSH_FTE_COMP_CONSTRAINT_GRP;


/
