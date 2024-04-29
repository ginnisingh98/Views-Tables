--------------------------------------------------------
--  DDL for Package Body WSH_DELIVERY_DETAILS_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_DELIVERY_DETAILS_UTILITIES" as
/* $Header: WSHDDUTB.pls 120.7.12010000.2 2010/02/26 06:58:19 sankarun ship $ */


G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_DELIVERY_DETAILS_UTILITIES';

--Forward Declaration
-- TPW - Distributed Organization Changes
PROCEDURE Validate_Delivery_Line (
                   p_changed_attributes IN  WSH_INTERFACE.ChangedAttributeTabType,
                   x_return_status      OUT NOCOPY VARCHAR2 );


-- ------------------------------------------------------------------------------------
-- Start of comments
-- API name : Auto_Assign_Deliveries
-- Type: private, called by group API
-- Prereqs : None
-- Preconditions: Given a list of delivery details with same grouping
--                attributes.
--
-- Function: This procedure groups the delivery details respecting FTE
--   compibility constraints then assign them to deliveries with matching
--   grouping attributes
--
-- Input Parameters :
--   p_line_rows           : table of delivery details
--   p_group_by_header      :'Y': within an order, 'N': across orders
--   p_check_fte_compatibility : 'Y'- check fte compatibility (called from Process Deliveries)
--                             : 'N'- skip fte compatibility (called from Pick Release since the
--                                    compatibility has been checked already)
-- Output Parameters:
--
--   x_assigned_rows       : table of delivery details and delivery id it assigned to
--   x_unassigned_rows     : table of delivery detail IDs that are not appended
--   x_return_status       : return status
-- ------------------------------------------------------------------------------------
PROCEDURE Auto_Assign_Deliveries(
    p_line_rows               IN OUT NOCOPY wsh_delivery_autocreate.grp_attr_tab_type,
    p_group_by_header         IN  VARCHAR2,
    p_check_fte_compatibility IN  VARCHAR2,
    x_assigned_rows           OUT NOCOPY WSH_DELIVERY_DETAILS_UTILITIES.delivery_assignment_rec_tbl,
    x_unassigned_rows         OUT NOCOPY WSH_UTIL_CORE.Id_Tab_Type,
    x_appended_del_tbl        OUT NOCOPY WSH_UTIL_CORE.Id_Tab_Type,
    x_return_status           OUT NOCOPY VARCHAR2) IS



  --dummy tables for calling validate_constraint_main
  l_cc_del_attr_tab      WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type;
  l_cc_det_attr_tab      WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type;
  l_cc_trip_attr_tab     WSH_TRIPS_PVT.Trip_Attr_Tbl_Type;
  l_cc_stop_attr_tab     WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type;
  l_cc_in_ids            WSH_UTIL_CORE.id_tab_type;
  l_cc_fail_ids          WSH_UTIL_CORE.id_tab_type;
  l_cc_validate_result   VARCHAR2(1);
  l_cc_failed_records    WSH_FTE_COMP_CONSTRAINT_PKG.failed_line_tab_type;
  l_cc_line_groups       WSH_FTE_COMP_CONSTRAINT_PKG.line_group_tab_type;
  l_cc_group_info        WSH_FTE_COMP_CONSTRAINT_PKG.cc_group_tab_type;

  l_msg_count            NUMBER := 0;
  l_msg_data             VARCHAR2(2000);
  l_return_status        VARCHAR2(1);

  l_debug_on             BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'AUTO_ASSIGN_DELIVERIES';

  l_exception_message    VARCHAR2(2000);

  l_action_prms          WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type;
  l_defaults             WSH_GLBL_VAR_STRCT_GRP.dd_default_parameters_rec_type;
  l_action_out_rec       WSH_GLBL_VAR_STRCT_GRP.dd_action_out_rec_type;
  l_details_in_cc_group  WSH_GLBL_VAR_STRCT_GRP.delivery_details_Attr_tbl_Type;


  l_attr_tab             WSH_DELIVERY_AUTOCREATE.grp_attr_tab_type;
  l_group_info           WSH_DELIVERY_AUTOCREATE.grp_attr_tab_type;
  l_action_rec           WSH_DELIVERY_AUTOCREATE.action_rec_type;
  l_target_rec           WSH_DELIVERY_AUTOCREATE.grp_attr_rec_type;
  l_matched_entities     WSH_UTIL_CORE.id_tab_type;
  l_out_rec              WSH_DELIVERY_AUTOCREATE.out_rec_type;


  l_index                NUMBER;
  l_current_line         NUMBER;

  l_cc_groupExists       BOOLEAN;
  l_delivery_done        BOOLEAN;
  l_multiple_sub_groups  BOOLEAN;
  l_cc_group_ids         WSH_UTIL_CORE.id_tab_type;

  l_get_autocreate_del_criteria VARCHAR2(1);
  l_warning_num          NUMBER := 0;
  i                      NUMBER;
  j                      NUMBER;
  k                      NUMBER;
  log_exception_err      EXCEPTION;

  l_sc_FINAL             VARCHAR2(6000);
  l_sc_SELECT            VARCHAR2(2000);
  l_sc_FROM              VARCHAR2(2000);
  l_sc_WHERE             VARCHAR2(2000);
  v_CursorID             NUMBER := 0;
  l_sub_str              VARCHAR2(2000);
  l_str_length           NUMBER := 0;
  l_delivery_id          NUMBER := 0;
  l_exception_id         NUMBER := NULL;
  v_ignore               INTEGER;
  l_group_id             NUMBER := 0;
  l_date_scheduled       DATE := NULL;
  l_date_requested       DATE := NULL;

  -- OTM R12 : update delivery
  -- select d.ignore_for_planning is added

  CURSOR c_get_deliveries IS
  SELECT t.id, d.ignore_for_planning
  FROM wsh_tmp            t,
       wsh_new_deliveries d
  WHERE d.delivery_id = t.id
  AND NOT EXISTS (
      SELECT WDA.delivery_detail_id
      FROM wsh_delivery_assignments_v WDA,
           wsh_delivery_details       WDD
      WHERE WDA.delivery_detail_id = WDD.delivery_detail_id
      AND WDA.delivery_id = t.id
      AND WDA.delivery_id is not NULL
      AND WDD.source_code <> 'OE'
      AND wdd.container_flag = 'N')
  AND NOT EXISTS (
      -- deliveries in consolidations are ineligible
      SELECT 1
      FROM WSH_DELIVERY_LEGS WDL
      WHERE WDL.delivery_id = t.id
      AND   WDL.parent_delivery_leg_id IS NOT NULL
  )
  ORDER BY d.creation_date;


  -- OTM R12 : update delivery
  l_delivery_info_tab       WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type;
  l_delivery_info           WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type;
  l_new_interface_flag_tab  WSH_UTIL_CORE.COLUMN_TAB_TYPE;
  l_tms_update              VARCHAR2(1);
  l_trip_not_found          VARCHAR2(1);
  l_trip_info_rec           WSH_DELIVERY_VALIDATIONS.trip_info_rec_type;
  l_tms_version_number      WSH_NEW_DELIVERIES.TMS_VERSION_NUMBER%TYPE;
  l_ignore_for_planning     WSH_NEW_DELIVERIES.IGNORE_FOR_PLANNING%TYPE;
  l_otm_return_status       VARCHAR2(1); -- not to overwrite l_return_status
  l_gc3_is_installed        VARCHAR2(1);
  -- End of OTM R12 : update delivery

BEGIN

   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name,'p_group_by_header', p_group_by_header);
      WSH_DEBUG_SV.log(l_module_name,'p_check_fte_compatibility', p_check_fte_compatibility);
   END IF;



   x_return_status  :=  WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   -- OTM R12
   l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED;

   IF (l_gc3_is_installed IS NULL) THEN
     l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED;
   END IF;
   -- End of OTM R12


   l_cc_in_ids.delete;


   IF l_debug_on THEN
      i := p_line_rows.FIRST;
      WHILE i is not NULL LOOP
         WSH_DEBUG_SV.log(l_module_name,' p_line_rows('||i||').entity_id', p_line_rows(i).entity_id);
      i := p_line_rows.next(i);
      END LOOP;
   END IF;



   WHILE p_line_rows.count > 0  LOOP

      l_current_line := p_line_rows.FIRST;

      l_sc_FINAL                                  := NULL;
      l_sc_SELECT                                 := NULL;
      l_sc_FROM                                   := NULL;
      l_sc_WHERE                                  := NULL;
      v_CursorID                                  := 0;


      -- put the rows with same group_id in l_cc_in_ids
      i := p_line_rows.FIRST;
      WHILE i is not NULL LOOP

         IF p_line_rows(l_current_line).group_id = p_line_rows(i).group_id THEN
            l_cc_in_ids(l_cc_in_ids.count+1) := p_line_rows(i).entity_id;

            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'   Get delivery detail: '||p_line_rows(i).entity_id );
            END IF;

         END IF;
         i := p_line_rows.next(i);
      END LOOP;

      l_multiple_sub_groups := FALSE;
      l_cc_line_groups.delete;


      -- construct
      IF wsh_util_core.fte_is_installed = 'Y'
         AND p_check_fte_compatibility = FND_API.G_TRUE
         AND l_cc_in_ids.count > 1 THEN
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_FTE_COMP_CONSTRAINT_PKG.validate_constraint_main');
         END IF;
         WSH_FTE_COMP_CONSTRAINT_PKG.validate_constraint_main(
             p_api_version_number   =>  1.0,
             p_init_msg_list        =>  FND_API.G_FALSE,
             p_entity_type          =>  'L',
             p_target_id            =>  null,
             p_action_code          =>  'AUTOCREATE-DEL',
             p_del_attr_tab         =>  l_cc_del_attr_tab,
             p_det_attr_tab         =>  l_cc_det_attr_tab,
             p_trip_attr_tab        =>  l_cc_trip_attr_tab,
             p_stop_attr_tab        =>  l_cc_stop_attr_tab,
             p_in_ids               =>  l_cc_in_ids,
             x_fail_ids             =>  l_cc_fail_ids,
             x_validate_result      =>  l_cc_validate_result,
             x_failed_lines         =>  l_cc_failed_records,
             -- passed out delivery detail id and the group id
             x_line_groups          =>  l_cc_line_groups,
             -- passed out group information
             x_group_info           =>  l_cc_group_info,
             x_msg_count            =>  l_msg_count,
             x_msg_data             =>  l_msg_data,
             x_return_status        =>  l_return_status);

         -- handle return status

         -- x_fail_ids and x_failed_lines are not populated for AUTOCREATE-DEL
         l_cc_group_ids.delete;

         IF l_cc_line_groups.COUNT > 0 AND l_return_status = wsh_util_core.g_ret_sts_error THEN

            i := l_cc_line_groups.FIRST;
            WHILE i is NOT NULL LOOP

               -- build l_cc_group_ids to hold the sub-group IDs
               l_cc_groupExists := FALSE ;

               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'l_cc_line_groups('|| i ||').entity_line_id: '||l_cc_line_groups(i).entity_line_id);
                  WSH_DEBUG_SV.logmsg(l_module_name,'l_cc_line_groups('|| i ||').line_group_id:  '||l_cc_line_groups(i).line_group_id);
               END IF;

               IF l_cc_group_ids.COUNT > 0 THEN
                  j := l_cc_group_ids.FIRST;
                  WHILE j is not NULL LOOP
                     IF l_cc_group_ids(j) = l_cc_line_groups(i).line_group_id THEN
                        l_cc_groupExists := TRUE;
                        exit;
                     END IF;
                  j := l_cc_group_ids.next(j);
                  END LOOP;
               END IF;
               IF (NOT(l_cc_groupExists)) THEN
                  l_cc_group_ids(l_cc_group_ids.count+1) := l_cc_line_groups(i).line_group_id;
                  IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'Add Sub-group '||l_cc_line_groups(i).line_group_id||' to table l_cc_group_ids' );
                  END IF;
               END IF;

               -- update p_line_rows with new sub_group ids
               k := p_line_rows.FIRST;
               WHILE k is not NULL LOOP
                  IF p_line_rows(k).entity_id = l_cc_line_groups(i).entity_line_id  THEN
                      -- correct the group_id with constraint group_id
                      p_line_rows(k).group_id := l_cc_line_groups(i).line_group_id;

                      IF l_debug_on THEN
                         WSH_DEBUG_SV.logmsg(l_module_name,'change group id of p_line_rows('||k||').entity_id '|| p_line_rows(k).entity_id||' to ' ||l_cc_line_groups(i).line_group_id);
                      END IF;

                      exit;
                  END IF;
                  k := p_line_rows.next(k);
               END LOOP;

            i := l_cc_line_groups.next(i);
            END LOOP;

            l_multiple_sub_groups := TRUE;

         END IF;

       END IF;  /* FTE is installed */

       -- No sub-group, l_cc_group_ids has only one record
       IF NOT l_multiple_sub_groups  THEN
            l_cc_group_ids(l_cc_group_ids.count+1) := p_line_rows(l_current_line).group_id;
       END IF;

       l_group_id := p_line_rows(l_current_line).group_id;

       l_action_rec.action := 'MATCH_GROUPS';
       l_action_rec.group_by_header_flag := p_group_by_header;
       l_action_rec.output_format_type := 'TEMP_TAB';
       l_target_rec.entity_type := 'DELIVERY';

       l_group_info.delete;
       l_attr_tab.delete;
       l_attr_tab(1) := p_line_rows(l_current_line);
       l_attr_tab(1).entity_type := 'DELIVERY_DETAIL';

       WSH_Delivery_Autocreate.Reset_WSH_TMP;

       wsh_delivery_autocreate.Find_Matching_Groups(
          p_attr_tab => l_attr_tab,
          p_action_rec => l_action_rec,
          p_target_rec => l_target_rec,
          p_group_tab  => l_group_info,
          x_matched_entities => l_matched_entities,
          x_out_rec => l_out_rec,
          x_return_status => x_return_status);

      -- execute the cursor
      OPEN c_get_deliveries;
      -- fetching the rows
      LOOP
         -- OTM R12 : update delivery, l_ignore_for_planning is added to cursor
         FETCH c_get_deliveries INTO l_delivery_id, l_ignore_for_planning;
         IF c_get_deliveries%NOTFOUND THEN
            CLOSE c_get_deliveries;
            EXIT;
         END IF;
            -- store column value in local variables

            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'   Fetched candidate delivery '|| to_char(l_delivery_id));
               WSH_DEBUG_SV.log(l_module_name,'   l_ignore_for_planning'||l_ignore_for_planning); -- OTM R12
            END IF;


         -- l_delivery_done indicastes if it needs to exit out of the sub-group loop
         -- If the assignment happens for the delivery, it needs to exist in order
         -- to advance to next delivery

         l_delivery_done := FALSE;

         -- loop through each sub group and try to assign the delivery details in the
         -- sub-group to the delivery

         l_index := l_cc_group_ids.FIRST;
         WHILE l_index is not null AND not l_delivery_done LOOP

            -- loop through each sub-group
            l_details_in_cc_group.delete;

            IF l_debug_on THEN
               i := l_cc_group_ids.FIRST;
               WHILE i is not NULL LOOP
                  WSH_DEBUG_SV.log(l_module_name,'   l_cc_group_ids('||i||') ', l_cc_group_ids(i));
               i := l_cc_group_ids.next(i);
               END LOOP;
            END IF;


            i := p_line_rows.FIRST;
            WHILE i is not NULL LOOP
               IF p_line_rows(i).group_id = l_cc_group_ids(l_index)  THEN
                  l_details_in_cc_group(l_details_in_cc_group.count+1).delivery_detail_id := p_line_rows(i).entity_id;
                  --
                  l_details_in_cc_group(l_details_in_cc_group.count).released_status       := p_line_rows(i).status_code;
                  l_details_in_cc_group(l_details_in_cc_group.count).organization_id       := p_line_rows(i).organization_id;
                  l_details_in_cc_group(l_details_in_cc_group.count).container_flag        := p_line_rows(i).container_flag;
                  l_details_in_cc_group(l_details_in_cc_group.count).source_code           := p_line_rows(i).source_code;
                  l_details_in_cc_group(l_details_in_cc_group.count).lpn_id                := p_line_rows(i).lpn_id;
                  l_details_in_cc_group(l_details_in_cc_group.count).customer_id           := p_line_rows(i).customer_id;
                  l_details_in_cc_group(l_details_in_cc_group.count).inventory_item_id     := p_line_rows(i).inventory_item_id;
                  l_details_in_cc_group(l_details_in_cc_group.count).ship_from_location_id := p_line_rows(i).ship_from_location_id;
                  l_details_in_cc_group(l_details_in_cc_group.count).ship_to_location_id   := p_line_rows(i).ship_to_location_id;
                  l_details_in_cc_group(l_details_in_cc_group.count).intmed_ship_to_location_id := p_line_rows(i).intmed_ship_to_location_id;
                  l_details_in_cc_group(l_details_in_cc_group.count).date_requested        := p_line_rows(i).date_requested;
                  l_details_in_cc_group(l_details_in_cc_group.count).date_scheduled        := p_line_rows(i).date_scheduled;
                  l_details_in_cc_group(l_details_in_cc_group.count).ship_method_code      := p_line_rows(i).ship_method_code;
                  l_details_in_cc_group(l_details_in_cc_group.count).carrier_id            := p_line_rows(i).carrier_id;
                  l_details_in_cc_group(l_details_in_cc_group.count).shipping_control      := p_line_rows(i).shipping_control;
                  l_details_in_cc_group(l_details_in_cc_group.count).party_id              := p_line_rows(i).party_id;
                  l_details_in_cc_group(l_details_in_cc_group.count).line_direction        := p_line_rows(i).line_direction;

                  --
               END IF;
               i := p_line_rows.next(i);
            END LOOP;

            -- reset date_scheduled and date_requested
            l_date_scheduled := NULL;
            l_date_requested := NULL;

            l_action_prms.action_code := 'ASSIGN';
            l_action_prms.delivery_id := l_delivery_id;
            l_action_prms.caller      := 'WSH_DLMG';


            -- assign delivery details of this sub-group to the delivery
            WSH_DELIVERY_DETAILS_GRP.Delivery_Detail_Action(
               p_api_version_number  => 1.0,
               p_init_msg_list       => FND_API.G_FALSE,
               p_commit              => FND_API.G_FALSE,
               x_return_status       => l_return_status,
               x_msg_count           => l_msg_count,
               x_msg_data            => l_msg_data,
               -- Procedure specific Parameters
               p_rec_attr_tab        => l_details_in_cc_group,
               p_action_prms         => l_action_prms,
               x_defaults            => l_defaults,
               x_action_out_rec      => l_action_out_rec);

            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'Return status from WSH_DELIVERY_DETAILS_GRP.Delivery_Detail_Action '|| l_return_status);
            END IF;

            -- OTM R12 : update delivery
            l_tms_update := 'N';
            l_new_interface_flag_tab(1) := NULL;

            -- delivery update will be done only for SUCCESS, WARNING case
            IF (l_return_status in (WSH_UTIL_CORE.G_RET_STS_SUCCESS,
                                    WSH_UTIL_CORE.G_RET_STS_WARNING) AND
                l_gc3_is_installed = 'Y' AND
                nvl(l_ignore_for_planning, 'N') = 'N') THEN
              -- l_otm_return_status is used here not to change l_return_status
              -- from the above API call
              l_otm_return_status := NULL;
              l_trip_not_found := 'N';

              --get trip information for delivery, no update when trip not OPEN
              WSH_DELIVERY_VALIDATIONS.get_trip_information
                           (p_delivery_id     => l_delivery_id,
                            x_trip_info_rec   => l_trip_info_rec,
                            x_return_status   => l_otm_return_status);

              IF (l_otm_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
                x_return_status := l_otm_return_status;
                IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Error in WSH_DELIVERY_VALIDATIONS.get_trip_information');
                  WSH_DEBUG_SV.pop(l_module_name);
                END IF;
                RETURN;
              END IF;

              IF (l_trip_info_rec.trip_id IS NULL) THEN
                l_trip_not_found := 'Y';
              END IF;

              -- only do changes when there's no trip or trip status is OPEN
              IF (l_trip_info_rec.status_code = 'OP' OR
                  l_trip_not_found = 'Y') THEN

                WSH_DELIVERY_VALIDATIONS.get_delivery_information(
                                      p_delivery_id   => l_delivery_id,
                                      x_delivery_rec  => l_delivery_info,
                                      x_return_status => l_otm_return_status);

                IF (l_otm_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
                  x_return_status := l_otm_return_status;
                  IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Error in WSH_DELIVERY_VALIDATIONS.get_delivery_information');
                    WSH_DEBUG_SV.pop(l_module_name);
                  END IF;
                  RETURN;
                END IF;


                -- checking that fob code, freight terms code, ship method code,
                -- carrier id, service level,or mode of transport is changed
                -- and delivery is include for planning, then update is required
                IF (nvl(l_delivery_info.fob_code, '@@') <>
                    NVL(l_delivery_info.fob_code,
                        nvl(l_attr_tab(1).fob_code, '@@')) OR
                    nvl(l_delivery_info.freight_terms_code, '@@') <>
                    NVL(l_delivery_info.freight_terms_code,
                        nvl(l_attr_tab(1).freight_terms_code, '@@')) OR
                    nvl(l_delivery_info.ship_method_code, '@@') <>
                    NVL(l_delivery_info.ship_method_code,
                        nvl(l_attr_tab(1).ship_method_code, '@@')) OR
                    nvl(l_delivery_info.carrier_id, -1) <>
                    NVL(l_delivery_info.carrier_id,
                        nvl(l_attr_tab(1).carrier_id, -1)) OR
                    nvl(l_delivery_info.service_level, '@@') <>
                    NVL(l_delivery_info.service_level,
                        nvl(l_attr_tab(1).service_level, '@@')) OR
                    nvl(l_delivery_info.mode_of_transport, '@@') <>
                    NVL(l_delivery_info.mode_of_transport,
                        nvl(l_attr_tab(1).mode_of_transport, '@@'))) THEN
                  IF (l_delivery_info.tms_interface_flag NOT IN
                      (WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT,
                       WSH_NEW_DELIVERIES_PVT.C_TMS_CREATE_REQUIRED,
                       WSH_NEW_DELIVERIES_PVT.C_TMS_DELETE_REQUIRED,
                       WSH_NEW_DELIVERIES_PVT.C_TMS_DELETE_IN_PROCESS,
                       WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_REQUIRED)) THEN
                    l_tms_update := 'Y';
                    l_delivery_info_tab(1) := l_delivery_info;
                    l_new_interface_flag_tab(1) := WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_REQUIRED;
                    l_tms_version_number := nvl(l_delivery_info.tms_version_number, 1) + 1;
                  END IF;
                END IF; -- checking the value differences
              END IF; -- IF ((l_trip_not_found = 'N' AND
            END IF; -- IF (l_gc3_is_installed = 'Y'

            -- End of OTM R12 : update delivery

            -- If there are some delivery details assigned to the delivery,
            -- we populate the assigned table and delete it from the main table

            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS  THEN

                  IF l_debug_on THEN
                    i := l_action_out_rec.result_id_tab.FIRST;
                    WHILE i is not NULL LOOP
                      WSH_DEBUG_SV.log(l_module_name, 'l_action_out_rec.result_id_tab('||i||')', l_action_out_rec.result_id_tab(i));
                    i :=  l_action_out_rec.result_id_tab.next(i);
                    END LOOP;
                  END IF;


                  -- this delivery is used, go to next delivery
                  l_delivery_done := TRUE;

                  i := l_details_in_cc_group.FIRST;
                  WHILE i is not NULL  LOOP

                     -- log_exception if Append Deliveries is turned on
                     IF l_attr_tab(1).batch_id is NULL THEN

                        FND_MESSAGE.SET_NAME('WSH', 'WSH_DEL_APPENDED');
                        FND_MESSAGE.SET_TOKEN('DELIVERY_DETAIL_ID' , to_char(l_details_in_cc_group(i).delivery_detail_id));
                        FND_MESSAGE.SET_TOKEN('DELIVERY_ID' , to_char(l_delivery_id));
                        l_exception_message := FND_MESSAGE.Get;

                        l_exception_id := NULL;

                        wsh_xc_util.log_exception(
                           p_api_version           => 1.0,
                           x_return_status         => l_return_status,
                           x_msg_count             => l_msg_count,
                           x_msg_data              => l_msg_data,
                           x_exception_id          => l_exception_id,
                           p_exception_location_id => l_details_in_cc_group(i).ship_from_location_id,
                           p_logged_at_location_id => l_details_in_cc_group(i).ship_from_location_id,
                           p_logging_entity        => 'SHIPPER',
                           p_logging_entity_id     => FND_GLOBAL.USER_ID,
                           p_exception_name        => 'WSH_DELIVERY_APPENDED',
                           p_message               => substrb(l_exception_message,1,2000),
                           p_delivery_id           => l_delivery_id,
                           p_delivery_detail_id    => l_details_in_cc_group(i).delivery_detail_id);


                        IF l_return_status in ( WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR , WSH_UTIL_CORE.G_RET_STS_ERROR  ) THEN
                           IF l_debug_on THEN
                              WSH_DEBUG_SV.log(l_module_name,' log_exception failed ');
                           END IF;
                           raise log_exception_err;
                        END IF;

                     END IF;

                     -- delete the processed record in p_line_rows
                     j := p_line_rows.FIRST;
                     WHILE j is not NULL LOOP
                        IF p_line_rows(j).entity_id  = l_details_in_cc_group(i).delivery_detail_id THEN
                           x_assigned_rows(x_assigned_rows.count+1).delivery_detail_id := p_line_rows(j).entity_id;
                           x_assigned_rows(x_assigned_rows.count).delivery_id := l_delivery_id;

                           IF l_debug_on THEN
                              WSH_DEBUG_SV.logmsg(l_module_name,'Added delivery_detail_id '||p_line_rows(j).entity_id||' to x_assigned_rows' );
                           END IF;
                           l_date_scheduled := least(NVL(l_date_scheduled,p_line_rows(j).date_scheduled), p_line_rows(j).date_scheduled);
                           l_date_requested := least(NVL(l_date_requested,p_line_rows(j).date_requested), p_line_rows(j).date_requested);
                           p_line_rows.delete(j);
                           exit;
                        END IF;
                        j := p_line_rows.next(j);
                     END LOOP;

                     i := l_details_in_cc_group.next(i);
                  END LOOP;

                  -- update  appended delivery
                  IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,  'UPDATING WSH_NEW_DELIVERIES ATTRIBUTES'  );
                      WSH_DEBUG_SV.log(l_module_name,  'intmed_ship_to_location_id', l_attr_tab(1).intmed_ship_to_location_id );
                      WSH_DEBUG_SV.log(l_module_name,  'fob_code', l_attr_tab(1).fob_code );
                      WSH_DEBUG_SV.log(l_module_name,  'freight_terms_code', l_attr_tab(1).freight_terms_code );
                      WSH_DEBUG_SV.log(l_module_name,  'carrier_id', l_attr_tab(1).carrier_id );
                      WSH_DEBUG_SV.log(l_module_name,  'date_scheduled', l_date_scheduled);
                      WSH_DEBUG_SV.log(l_module_name,  'date_requested', l_date_requested);
                      WSH_DEBUG_SV.log(l_module_name,  'service_level', l_attr_tab(1).service_level );
                      WSH_DEBUG_SV.log(l_module_name,  'mode_of_transport', l_attr_tab(1).mode_of_transport);
                      WSH_DEBUG_SV.log(l_module_name,  'source_header_id', l_attr_tab(1).source_header_id);

                      -- OTM R12 : update delivery
                      WSH_DEBUG_SV.log(l_module_name, 'l_gc3_is_installed', l_gc3_is_installed);
                      WSH_DEBUG_SV.log(l_module_name, 'l_tms_update', l_tms_update);
                      IF (l_tms_update = 'Y') THEN
                        WSH_DEBUG_SV.log(l_module_name, 'l_new_interface_flag_tab', l_new_interface_flag_tab(1));
                        WSH_DEBUG_SV.log(l_module_name, 'l_tms_version_number', l_tms_version_number);
                      END IF;
                      -- End of OTM R12 : update delivery
                  END IF;

                  UPDATE wsh_new_deliveries
                  SET    intmed_ship_to_location_id = NVL(intmed_ship_to_location_id,l_attr_tab(1).intmed_ship_to_location_id),
                         fob_code                   = NVL(fob_code,l_attr_tab(1).fob_code),
                         freight_terms_code         = NVL(freight_terms_code,l_attr_tab(1).freight_terms_code),
                         ship_method_code           = NVL(ship_method_code,l_attr_tab(1).ship_method_code),
                         carrier_id                 = NVL(carrier_id,l_attr_tab(1).carrier_id),
                         initial_pickup_date        = least(initial_pickup_date, l_date_scheduled),
                         -- bug 2466054 - switch between date_scheduled and date_requested
                         ultimate_dropoff_date      = greatest(least(initial_pickup_date, l_date_scheduled),
                                                               least(ultimate_dropoff_date,l_date_requested)),
                         service_level              = NVL(service_level,l_attr_tab(1).service_level),
                         mode_of_transport          = NVL(mode_of_transport,l_attr_tab(1).mode_of_transport),
                         source_header_id           = NVL(source_header_id, l_attr_tab(1).source_header_id),
                         last_update_date           = SYSDATE,
                         last_updated_by            = FND_GLOBAL.user_id,
                         last_update_login          = FND_GLOBAL.login_id,
                         -- OTM R12
                         TMS_INTERFACE_FLAG = decode(l_tms_update, 'Y', l_new_interface_flag_tab(1), nvl(TMS_INTERFACE_FLAG, WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT)),
                         TMS_VERSION_NUMBER = decode(l_tms_update, 'Y', l_tms_version_number, nvl(tms_version_number, 1))
                         -- End of OTM R12
                  WHERE  delivery_id = l_delivery_id;

                  -- OTM R12 : update delivery
                  IF (l_gc3_is_installed = 'Y' AND l_tms_update = 'Y') THEN
                    WSH_XC_UTIL.LOG_OTM_EXCEPTION(
                                p_delivery_info_tab      => l_delivery_info_tab,
                                p_new_interface_flag_tab => l_new_interface_flag_tab,
                                x_return_status          => l_otm_return_status);
                    IF (l_otm_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
                      x_return_status := l_otm_return_status;
                      IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Error in WSH_XC_UTIL.log_otm_exception');
                        WSH_DEBUG_SV.pop(l_module_name);
                      END IF;
                      RETURN;
                    END IF;
                  END IF;
                  -- End of OTM R12 : update delivery

                  x_appended_del_tbl(x_appended_del_tbl.count+1) := l_delivery_id;
                  -- delete the processed record in l_cc_group_ids
                  i := l_cc_group_ids.FIRST;
                  WHILE i is not NULL LOOP
                     IF l_cc_group_ids(i) = l_group_id THEN
                        l_cc_group_ids.delete(i);
                     END IF;
                     i := l_cc_group_ids.next(i);
                  END LOOP;

            ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING /* some of them are successfully
                  assigned */ THEN

               l_delivery_done := TRUE;
               IF l_action_out_rec.result_id_tab.count > 0 THEN
                  i := l_action_out_rec.result_id_tab.FIRST;
                  WHILE i is not NULL LOOP

                     IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name, 'l_action_out_rec.result_id_tab('||i||')', l_action_out_rec.result_id_tab(i));
                     END IF;

                     IF l_attr_tab(1).batch_id is NULL THEN

                      -- do not log exception when appending within a PR release
                        FND_MESSAGE.SET_NAME('WSH', 'WSH_DEL_APPENDED');
                        FND_MESSAGE.SET_TOKEN('DELIVERY_DETAIL_ID' , to_char(l_action_out_rec.result_id_tab(i)));
                        FND_MESSAGE.SET_TOKEN('DELIVERY_ID' , to_char(l_delivery_id));
                        l_exception_message := FND_MESSAGE.Get;

                        l_exception_id := NULL;

                        wsh_xc_util.log_exception(
                           p_api_version           => 1.0,
                           x_return_status         => l_return_status,
                           x_msg_count             => l_msg_count,
                           x_msg_data              => l_msg_data,
                           x_exception_id          => l_exception_id,
                           p_exception_handling    => 'NO_ACTION_REQUIRED',
                           p_exception_location_id => l_details_in_cc_group(l_details_in_cc_group.FIRST).ship_from_location_id,
                           p_logged_at_location_id => l_details_in_cc_group(l_details_in_cc_group.FIRST).ship_from_location_id,
                           p_logging_entity        => 'SHIPPER',
                           p_logging_entity_id     => FND_GLOBAL.USER_ID,
                           p_exception_name        => 'WSH_DELIVERY_APPENDED',
                           p_message               => substrb(l_exception_message,1,2000),
                           p_delivery_id           => l_delivery_id,
                           p_delivery_detail_id    => l_action_out_rec.result_id_tab(i));

                        IF l_return_status in ( WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR , WSH_UTIL_CORE.G_RET_STS_ERROR  ) THEN
                           IF l_debug_on THEN
                              WSH_DEBUG_SV.log(l_module_name,' log_exception failed ');
                           END IF;
                           raise log_exception_err;
                        END IF;

                     END IF;

                     -- delete the processed record in p_line_rows
                     j := p_line_rows.FIRST;
                     WHILE j is not NULL LOOP
                        IF p_line_rows(j).entity_id  = l_action_out_rec.result_id_tab(i) THEN
                           x_assigned_rows(x_assigned_rows.count+1).delivery_detail_id := p_line_rows(j).entity_id;
                           x_assigned_rows(x_assigned_rows.count).delivery_id := l_delivery_id;

                           IF l_debug_on THEN
                              WSH_DEBUG_SV.logmsg(l_module_name,'Added delivery_detail_id '||p_line_rows(j).entity_id||' to x_assigned_rows' );
                           END IF;
                           -- get the date_scheduled and date_requrested
                           l_date_scheduled := least(NVL(l_date_scheduled,p_line_rows(j).date_scheduled), p_line_rows(j).date_scheduled);
                           l_date_requested := least(NVL(l_date_requested,p_line_rows(j).date_requested), p_line_rows(j).date_requested);
                           p_line_rows.delete(j);
                           exit;
                        END IF;
                        j := p_line_rows.next(j);
                     END LOOP;

                     -- delete the assigned delivery details in l_details_in_cc_group
                     -- Has gap, need to modify later
                     k := l_details_in_cc_group.FIRST;
                     WHILE k is not null LOOP
                        IF l_details_in_cc_group(k).delivery_detail_id = l_action_out_rec.result_id_tab(i) THEN
                           l_details_in_cc_group.delete(k);
                           exit;
                        END IF;
                        k := l_details_in_cc_group.next(k);
                     END LOOP;

                  i := l_action_out_rec.result_id_tab.next(i);
                  END LOOP;

                  IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,  'UPDATING WSH_NEW_DELIVERIES ATTRIBUTES'  );
                      WSH_DEBUG_SV.log(l_module_name,  'intmed_ship_to_location_id', l_attr_tab(1).intmed_ship_to_location_id );
                      WSH_DEBUG_SV.log(l_module_name,  'fob_code', l_attr_tab(1).fob_code );
                      WSH_DEBUG_SV.log(l_module_name,  'freight_terms_code', l_attr_tab(1).freight_terms_code );
                      WSH_DEBUG_SV.log(l_module_name,  'carrier_id', l_attr_tab(1).carrier_id );
                      WSH_DEBUG_SV.log(l_module_name,  'date_scheduled', l_date_scheduled);
                      WSH_DEBUG_SV.log(l_module_name,  'date_requested', l_date_requested);
                      WSH_DEBUG_SV.log(l_module_name,  'service_level', l_attr_tab(1).service_level );
                      WSH_DEBUG_SV.log(l_module_name,  'mode_of_transport', l_attr_tab(1).mode_of_transport);
                      WSH_DEBUG_SV.log(l_module_name,  'source_header_id', l_attr_tab(1).source_header_id);
                      -- OTM R12 : update delivery
                      WSH_DEBUG_SV.log(l_module_name, 'l_gc3_is_installed', l_gc3_is_installed);
                      WSH_DEBUG_SV.log(l_module_name, 'l_tms_update', l_tms_update);
                      IF (l_tms_update = 'Y') THEN
                        WSH_DEBUG_SV.log(l_module_name, 'l_new_interface_flag_tab', l_new_interface_flag_tab(1));
                        WSH_DEBUG_SV.log(l_module_name, 'l_tms_version_number', l_tms_version_number);
                      END IF;
                      -- End of OTM R12 : update delivery
                  END IF;

                  UPDATE wsh_new_deliveries
                  SET    intmed_ship_to_location_id = NVL(intmed_ship_to_location_id,l_attr_tab(1).intmed_ship_to_location_id),
                         fob_code                   = NVL(fob_code,l_attr_tab(1).fob_code),
                         freight_terms_code         = NVL(freight_terms_code,l_attr_tab(1).freight_terms_code),
                         ship_method_code           = NVL(ship_method_code,l_attr_tab(1).ship_method_code),
                         carrier_id                 = NVL(carrier_id,l_attr_tab(1).carrier_id),
                         initial_pickup_date        = least(initial_pickup_date,l_date_scheduled),
                         -- bug 2466054 - switch between date_scheduled and date_requested
                         ultimate_dropoff_date      = greatest(least(initial_pickup_date,l_date_scheduled),
                                                               least(ultimate_dropoff_date,l_date_requested)),
                         service_level              = NVL(service_level,l_attr_tab(1).service_level),
                         mode_of_transport          = NVL(mode_of_transport,l_attr_tab(1).mode_of_transport),
                         source_header_id           = NVL(source_header_id, l_attr_tab(1).source_header_id),
                         last_update_date           = SYSDATE,
                         last_updated_by            = FND_GLOBAL.user_id,
                         last_update_login          = FND_GLOBAL.login_id,
                         -- OTM R12
                         TMS_INTERFACE_FLAG = decode(l_tms_update, 'Y', l_new_interface_flag_tab(1), nvl(TMS_INTERFACE_FLAG, WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT)),
                         TMS_VERSION_NUMBER = decode(l_tms_update, 'Y', l_tms_version_number, nvl(tms_version_number, 1))
                         -- End of OTM R12
                  WHERE  delivery_id = l_delivery_id;

                  -- OTM R12 : update delivery
                  IF (l_gc3_is_installed = 'Y' AND l_tms_update = 'Y') THEN
                    WSH_XC_UTIL.LOG_OTM_EXCEPTION(
                                p_delivery_info_tab      => l_delivery_info_tab,
                                p_new_interface_flag_tab => l_new_interface_flag_tab,
                                x_return_status          => l_otm_return_status);
                    IF (l_otm_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
                      x_return_status := l_otm_return_status;
                      IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Error in WSH_XC_UTIL.log_otm_exception');
                        WSH_DEBUG_SV.pop(l_module_name);
                      END IF;
                      RETURN;
                    END IF;
                  END IF;
                  -- End of OTM R12 : update delivery

                  x_appended_del_tbl(x_appended_del_tbl.count+1) := l_delivery_id;

               END IF;

               -- all of the delivery lines get assigned, but rate delivery or carrier selection
               -- are not successful

               IF l_action_out_rec.result_id_tab.count >= l_details_in_cc_group.count THEN
                  -- delete the processed record in l_cc_group_ids
                  i := l_cc_group_ids.FIRST;
                  WHILE i is not NULL LOOP
                     IF l_cc_group_ids(i) = l_group_id THEN
                        l_cc_group_ids.delete(i);
                     END IF;
                     i := l_cc_group_ids.next(i);
                  END LOOP;
               END IF;
            ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
            -- none of the delivery detail are assigned, it means that the delivery
            -- do not match the constraint requirement, we have to try another delivery

               NULL;

            ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
            -- searous error happens, skip to next sub-group

               i := p_line_rows.FIRST;
               WHILE i is not NULL LOOP
                  IF p_line_rows(i).group_id = l_group_id THEN
                     x_unassigned_rows(x_unassigned_rows.count+1):= p_line_rows(i).entity_id;
                     IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Added delivery_detail_id '||p_line_rows(i).entity_id||' to x_unassigned_rows' );
                     END IF;
                     p_line_rows.delete(i);
                  END IF;
                  i := p_line_rows.next(i);
               END LOOP;

               -- delete the processed record in l_cc_group_ids
               i := l_cc_group_ids.FIRST;

               WHILE i is not NULL LOOP
                  IF l_cc_group_ids(i) = l_group_id THEN
                     l_cc_group_ids.delete(i);
                     exit;
                  END IF;
                  i := l_cc_group_ids.next(i);
               END LOOP;

            END IF;   -- check the result of assignment


            l_index := l_cc_group_ids.next(l_index) ;
         END LOOP;  -- loop through each sub-group

         -- exit delivery loop
         IF l_cc_group_ids.count = 0  THEN
           CLOSE c_get_deliveries;
           EXIT;
         END IF;

      END LOOP; -- fetch delivery loop

      -- OTM R12, if the cursor is still open then close the cursor
      IF c_get_deliveries%ISOPEN THEN
         CLOSE c_get_deliveries;
      END IF;


      IF l_cc_group_ids.count > 0 THEN
         -- have exhausted all the candidate deliveies, move the delivery lines to
         -- unassigned table
         i := l_cc_group_ids.FIRST;
         WHILE i is not NULL LOOP

            -- this table has gaps
            IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name,'p_line_rows count', p_line_rows.count);
            END IF;
            j := p_line_rows.FIRST;
            WHILE j is not null LOOP

               IF p_line_rows(j).group_id = l_cc_group_ids(i) THEN
                  x_unassigned_rows(x_unassigned_rows.count+1):= p_line_rows(j).entity_id;
                  IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'Added delivery_detail_id '||p_line_rows(j).entity_id||' to x_unassigned_rows' );
                  END IF;
                  p_line_rows.delete(j);
               END IF;

               j := p_line_rows.NEXT(j);
            END LOOP;
            l_cc_group_ids.delete(i);
            i := l_cc_group_ids.NEXT(i);
         END LOOP;

      END IF ;

   END LOOP; -- p_line_rows loop


   IF l_debug_on THEN
      i := x_unassigned_rows.FIRST;
      WHILE i is not NULL LOOP
        WSH_DEBUG_SV.log(l_module_name,'x_unassigned_rows('||i||')' , x_unassigned_rows(i));
      i := x_unassigned_rows.next(i);
      END LOOP;
   END IF;


   IF x_unassigned_rows.count > 0 OR l_warning_num > 0 THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
   END IF;

   IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name, 'Return Status: '||x_return_status);
   END IF;



EXCEPTION

   WHEN log_exception_err THEN

      -- OTM R12 : if the cursor is still open then close the cursor
      IF c_get_deliveries%ISOPEN THEN
         CLOSE c_get_deliveries;
      END IF;

      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name, 'Log_exception returns error ');
      END IF;


   WHEN others THEN

      -- if the cursor is still open then close the cursor
      IF c_get_deliveries%ISOPEN THEN
         CLOSE c_get_deliveries;
      END IF;
      wsh_util_core.default_handler('WSH_DELIVERY_DETAILS_UTILITIES.Auto_Assign_Deliveries');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;


END Auto_Assign_Deliveries;


  -- ----------------------------------------------------------------------------------
  -- Start of comments
  -- API name : Append_to_Deliveries
  -- Type: private, called by group API
  -- Prereqs : None
  -- Function: Assign delivery lines to existing deliveries respecting
  --           grouping rules , across order options and FTE compatibility constraints.
  --           This procedure only append OE lines per design
  --           This procedure is called from Pick Release process or Process Deliveries SRS
  -- Input Parameters :
  --   p_delivery_detail_tbl : table of delivery details
  --   p_append_flag         : NULL  or 'Y' - check the appending_limit in shipping parameters for
  --                                  the organization, append delivery details only if
  --                                  appending_limit is not 'No'
  --
  --                           'N' -  do not append delivery details, in this case
  --                                  x_unappended_det_tbl is the same as p_delivery_detail_tbl
  --   p_group_by_header     : 'Y' - use source_header_id in grouping delivery details
  --                           'N' - do not use source_header_id in grouping delivery details
  --                           NULL - get the value from shipping_parameters to decide if
  --                           source_header_id should be used in grouping delivery details
  --
  --   p_commit                FND_API.G_TRUE  - commit
  --                           FND_API.G_FALSE - do not commit
  --
  --   p_lock_rows             FND_API.G_TRUE  - lock rows before append
  --                           FND_API.G_FALSE - do not lock rows befor append, usually the
  --                                             caller procedure already locks the rows
  --
  --   p_check_fte_compatibility FND_API.G_TRUE - needs to check compatibility when grouping
  --                                              the delivery lines
  --                             FND_API.G_FALSE - do not needs to check compatibility when
  --                                              the delivery lines, usually it has been
  --                                              checked by the caller procedure
  --
  --   x_appended_det_tbl    : table of delivery details and delivery id it successfully appended
  --
  --   x_unappended_det_tbl  : table of delivery detail IDs that are not appended
  --
  --   x_appended_del_tbl    : table of deliveries that got appended
  --
  --   x_return_status       : Success: mean calling problem can continue with next step
  --                         : Error or Unexpected Error: the autocreate delivery
  --                           process should not continue
  --
  -- ----------------------------------------------------------------------------------

PROCEDURE Append_to_Deliveries(
          p_delivery_detail_tbl     IN  WSH_UTIL_CORE.Id_Tab_Type,
          p_append_flag             IN  VARCHAR2,
          p_group_by_header         IN  VARCHAR2,
          p_commit                  IN  VARCHAR2,
          p_lock_rows               IN  VARCHAR2,
          p_check_fte_compatibility IN  VARCHAR2,
          x_appended_det_tbl        OUT NOCOPY WSH_DELIVERY_DETAILS_UTILITIES.delivery_assignment_rec_tbl,
          x_unappended_det_tbl      OUT NOCOPY WSH_UTIL_CORE.Id_Tab_Type,
          x_appended_del_tbl        OUT NOCOPY WSH_UTIL_CORE.Id_Tab_Type,
          x_return_status           OUT NOCOPY VARCHAR2) IS

  CURSOR get_line_details_check(c_detail_id NUMBER) IS
  SELECT   wdd.delivery_detail_id,
           wdd.ship_to_location_id,
           wdd.ship_from_location_id,
           wdd.customer_id,
           wdd.intmed_ship_to_location_id,
           wdd.fob_code,
           wdd.freight_terms_code,
           wdd.ship_method_code,
           wdd.carrier_id,
           wdd.source_header_id,
           wdd.deliver_to_location_id,
           wdd.organization_id,
           wdd.date_scheduled,
           wdd.date_requested,
           wdd.released_status,
           wdd.container_flag,
           wdd.shipping_control,
           wdd.party_id,
           wdd.line_direction,
           wdd.inventory_item_id,
           wdd.source_code,
           wdd.lpn_id,
           wsp.appending_limit,
	   wdd.ignore_for_planning --bugfix 7164767
  FROM     wsh_delivery_details wdd,
           wsh_delivery_assignments_v wda,
           wsh_shipping_parameters  wsp
  WHERE    wdd.delivery_detail_id = c_detail_id
           AND wda.delivery_detail_id = wdd.delivery_detail_id
           AND wda.delivery_id is NULL
           AND NVL(wdd.line_direction, 'O') in ('O', 'IO')
           AND wdd.source_code = 'OE'
           AND wdd.container_flag = 'N'
           AND wsp.organization_id   = wdd.organization_id;
           -- AND wsp.appending_limit <> 'N' ;

  l_warning_num               NUMBER := 0;
  l_return_status             VARCHAR2(1) ;

  l_detail_info               WSH_DELIVERY_AUTOCREATE.grp_attr_tab_type;

  l_unassigned_rows           WSH_UTIL_CORE.Id_Tab_Type;
  l_assgined_rows             WSH_DELIVERY_DETAILS_UTILITIES.delivery_assignment_rec_tbl;
  l_index                     NUMBER;
  l_delivery_detail_id        NUMBER;

  l_group_info                WSH_DELIVERY_AUTOCREATE.grp_attr_tab_type;
  l_action_rec                WSH_DELIVERY_AUTOCREATE.action_rec_type;
  l_target_rec                WSH_DELIVERY_AUTOCREATE.grp_attr_rec_type;
  l_matched_entities          WSH_UTIL_CORE.id_tab_type;
  l_out_rec                   WSH_DELIVERY_AUTOCREATE.out_rec_type;

  l_debug_on                  BOOLEAN;
  l_module_name               CONSTANT VARCHAR2(100) := 'wsh.plsql.' || g_pkg_name || '.' || 'Append_to_Deliveries';
  Auto_Assign_Deliveries_ERR  EXCEPTION;
  Group_Delivery_Details_ERR  EXCEPTION;
  l_appending_limit           VARCHAR2(1);
  i                           NUMBER;

  BEGIN

    SAVEPOINT START_OF_APPEND_DELIVERIES;
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       WSH_DEBUG_SV.log(l_module_name, 'p_append_flag', p_append_flag);
       WSH_DEBUG_SV.log(l_module_name, 'p_group_by_header', p_group_by_header);
       WSH_DEBUG_SV.log(l_module_name, 'p_commit', p_commit);
       WSH_DEBUG_SV.log(l_module_name, 'p_lock_rows', p_lock_rows);
       WSH_DEBUG_SV.log(l_module_name, 'p_check_fte_compatibility', p_check_fte_compatibility);
       WSH_DEBUG_SV.log(l_module_name, 'WSH_PICK_LIST.G_BATCH_ID', WSH_PICK_LIST.G_BATCH_ID);

    END IF;

    x_return_status  :=  WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    x_unappended_det_tbl.delete;  -- unappended list
    x_appended_det_tbl.delete;    -- successfully appended list
    x_appended_del_tbl.delete;    -- appended deliveries


    -- need to check append_limit in shipping parameters
    l_index := p_delivery_detail_tbl.FIRST;
    WHILE l_index is NOT NULL LOOP
       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'p_delivery_detail_tbl('||l_index||'): ',p_delivery_detail_tbl(l_index));
       END IF;


       OPEN get_line_details_check(p_delivery_detail_tbl(l_index));
       FETCH get_line_details_check INTO  l_detail_info(l_index).entity_id,
                                          l_detail_info(l_index).ship_to_location_id,
                                          l_detail_info(l_index).ship_from_location_id,
                                          l_detail_info(l_index).customer_id,
                                          l_detail_info(l_index).intmed_ship_to_location_id,
                                          l_detail_info(l_index).fob_code,
                                          l_detail_info(l_index).freight_terms_code,
                                          l_detail_info(l_index).ship_method_code,
                                          l_detail_info(l_index).carrier_id,
                                          l_detail_info(l_index).source_header_id,
                                          l_detail_info(l_index).deliver_to_location_id,
                                          l_detail_info(l_index).organization_id,
                                          l_detail_info(l_index).date_scheduled,
                                          l_detail_info(l_index).date_requested,
                                          l_detail_info(l_index).status_code,
                                          l_detail_info(l_index).container_flag,
                                          l_detail_info(l_index).shipping_control,
                                          l_detail_info(l_index).party_id,
                                          l_detail_info(l_index).line_direction,
                                          l_detail_info(l_index).inventory_item_id,
                                          l_detail_info(l_index).source_code,
                                          l_detail_info(l_index).lpn_id,
                                          l_appending_limit,
					  l_detail_info(l_index).ignore_for_planning; --bugfix 7164767


       IF get_line_details_check%NOTFOUND THEN
          x_unappended_det_tbl(x_unappended_det_tbl.count+1) := p_delivery_detail_tbl(l_index);
          l_detail_info.delete(l_index);
          CLOSE get_line_details_check;
          goto loop_end;
       ELSE
          CLOSE get_line_details_check;
          -- these are the lines that will be grouped
          IF p_lock_rows = FND_API.G_TRUE THEN
             -- lock the delivery detail record
             select delivery_detail_id into l_delivery_detail_id from wsh_delivery_details where
             delivery_detail_id = p_delivery_detail_tbl(l_index) for update nowait;
          END IF;
          IF NVL(p_append_flag, l_appending_limit) = 'N' and WSH_PICK_LIST.G_BATCH_ID is NULL THEN
             x_unappended_det_tbl(x_unappended_det_tbl.count+1) := l_detail_info(l_index).entity_id;
             l_detail_info.delete(l_index);
          ELSIF NVL(p_append_flag, l_appending_limit) = 'N' and WSH_PICK_LIST.G_BATCH_ID is NOT NULL THEN
             l_detail_info(l_index).batch_id := WSH_PICK_LIST.G_BATCH_ID;

          END IF;
       END IF;
       <<loop_end>>
       l_index := p_delivery_detail_tbl.next(l_index);
    END LOOP;



       IF l_debug_on THEN
          i := l_detail_info.FIRST;
          WHILE i is not NULL LOOP
               WSH_DEBUG_SV.log(l_module_name,' l_detail_info('||i||').entity_id', l_detail_info(i).entity_id);
          i := l_detail_info.next(i);
          END LOOP;
       END IF;



      IF l_detail_info.count > 0 THEN
         l_unassigned_rows.delete;

         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Group_Delivery_Details');
         END IF;

         l_action_rec.action := 'CREATE_GROUPS';
         l_action_rec.group_by_header_flag := p_group_by_header;

         WSH_DELIVERY_AUTOCREATE.Find_Matching_Groups(
            p_attr_tab => l_detail_info,
            p_action_rec => l_action_rec,
            p_target_rec => l_target_rec,
            p_group_tab  => l_group_info,
            x_matched_entities => l_matched_entities,
            x_out_rec => l_out_rec,
            x_return_status => l_return_status);

         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,' after calling Find_Matching_Groups');
               i := l_detail_info.FIRST;
               WHILE i is not NULL LOOP
                  WSH_DEBUG_SV.log(l_module_name,' l_detail_info('||i||').entity_id', l_detail_info(i).entity_id);
               i := l_detail_info.next(i);
               END LOOP;

         END IF;

         IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
               l_warning_num := l_warning_num + 1;
         ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR OR
               l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
               raise Group_Delivery_Details_ERR;
         END IF;

         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Return status from wsh_delivery_autocreate.Find_Matching_Groups: '|| l_return_status );
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Auto_Assign_Deliveries');
         END IF;

         Auto_Assign_Deliveries(
            p_line_rows               => l_detail_info,
            p_group_by_header         => p_group_by_header,
            p_check_fte_compatibility => p_check_fte_compatibility,
            x_assigned_rows           => x_appended_det_tbl,
            x_unassigned_rows         => l_unassigned_rows,
            x_appended_del_tbl        => x_appended_del_tbl,
            x_return_status           => l_return_status);

         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Return status from Auto_Assign_Deliveries: '|| l_return_status );
         END IF;

         IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            l_warning_num := l_warning_num + 1;
            IF l_unassigned_rows.count > 0 THEN
               l_index := l_unassigned_rows.FIRST;
               WHILE l_index IS NOT NULL LOOP
                  x_unappended_det_tbl(x_unappended_det_tbl.count+1) := l_unassigned_rows(l_index);
                  l_index := l_unassigned_rows.next(l_index);
               END LOOP;
            END IF;
            IF l_debug_on THEN
	       WSH_DEBUG_SV.log(l_module_name,'x_unappended_det_tbl.count', x_unappended_det_tbl.count);
            END IF;
         ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR OR
               l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
            raise Auto_Assign_Deliveries_ERR;
         END IF;


      IF p_commit = FND_API.G_TRUE THEN
         commit;
      END IF;

    END IF;

    IF x_unappended_det_tbl.count > 0 OR l_warning_num > 0 THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    END IF;

    IF l_debug_on THEN
       wsh_debug_sv.pop(l_module_name);
    END IF;

  EXCEPTION

    WHEN Group_Delivery_Details_ERR THEN
       ROLLBACK TO START_OF_APPEND_DELIVERIES;
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       FND_MESSAGE.SET_NAME('WSH', 'WSH_GRP_DETAILS_ERR');
       wsh_util_core.add_message(x_return_status, l_module_name);

       IF l_debug_on THEN
          wsh_debug_sv.logmsg(l_module_name, 'Group_Delivery_Details failed');
          wsh_debug_sv.pop(l_module_name, 'EXCEPTION:Group_Delivery_Details_ERR');
       END IF;

    WHEN Auto_Assign_Deliveries_ERR THEN
       ROLLBACK TO START_OF_APPEND_DELIVERIES;
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       FND_MESSAGE.SET_NAME('WSH', 'WSH_AUTO_ASSIGN_ERR');
       wsh_util_core.add_message(x_return_status, l_module_name);

       IF l_debug_on THEN
          wsh_debug_sv.logmsg(l_module_name, 'Auto_Assign_Deliveries failed');
          wsh_debug_sv.pop(l_module_name, 'EXCEPTION:Auto_Assign_Deliveries_ERR');
       END IF;

    WHEN Others THEN
       ROLLBACK TO START_OF_APPEND_DELIVERIES;
       -- release all the locks
       IF get_line_details_check%ISOPEN  THEN
          CLOSE get_line_details_check;
       END IF;

       x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
       wsh_util_core.default_handler('WSH_DELIVERY_DETAILS_UTILITIES.Append_to_Deliveries');
       IF l_debug_on THEN
          wsh_debug_sv.log(l_module_name, 'Unexpected error has occured. Oracle error message is ' || SQLERRM);
          wsh_debug_sv.pop(l_module_name, 'EXCEPTION:OTHERS');
       END IF;

 END Append_to_Deliveries;

-- TPW - Distributed Organization Changes - Start
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Check_Updates_Allowed
--
-- PARAMETERS:
--       p_changed_attributes   => Delivery Details changed attributes
--       p_source_code          => Source Code
--       x_update_allowed       => Update Allowed Flag
--       x_return_status        => Return Status of API (S,E,U)
--
-- COMMENT:
--       API will not allow updates other than Ordered Quantity and Order
--       Quantity UOM, if
--       1) Organization is Distributed Enabled Org (TW2)
--       2) Delivery line corresponding to order line is associated with
--          Shipment batch.
--       Increase in quantity is always allowed
--       For decrease in quantity, there should be delivery line(s) which are
--       not yet assigned to Shipment Batch atleast for quantity being cancelled.
--=============================================================================
--
PROCEDURE Check_Updates_Allowed(
          p_changed_attributes IN  WSH_INTERFACE.ChangedAttributeTabType,
          p_source_code        IN  VARCHAR2,
          x_update_allowed     OUT NOCOPY  VARCHAR2,
          x_return_status      OUT NOCOPY  VARCHAR2)
IS
   CURSOR c_del_details ( c_source_line_id IN NUMBER )
   IS
   select organization_id,
          src_requested_quantity,
          src_requested_quantity_uom,
          requested_quantity,
          requested_quantity_uom,
          inventory_item_id
   from   wsh_delivery_details
   where  source_code= p_source_code
   and    released_status not in ( 'D', 'C' )
   and    shipment_batch_id is not null
   and    source_line_id = c_source_line_id
   and    rownum = 1;

   CURSOR c_open_detail_qty (c_source_line_id IN NUMBER)
   IS
   select nvl(sum(requested_quantity), 0)
   from   wsh_delivery_details
   where  source_code = p_source_code
   and    released_status in ( 'R', 'X', 'B' ) -- Check with klr
   and    source_line_id = c_source_line_id
   and    shipment_batch_id is null
   and    shipment_line_number is null;

   l_return_status          VARCHAR2(1);
   l_wh_type                VARCHAR2(30);

   l_source_line_id         NUMBER;
   l_open_qty               NUMBER;
   l_change_quantity        NUMBER;
   l_converted_open_qty     NUMBER;
   l_converted_ordered_qty  NUMBER;
   l_new_src_requested_quantity   NUMBER;

   wsh_update_not_allowed   EXCEPTION;
   wsh_invalid_org          EXCEPTION;

   l_detail_rec             c_del_details%ROWTYPE;
   --
   l_debug_on               BOOLEAN;
   l_module_name CONSTANT   VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Check_Updates_Allowed';
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
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name, 'p_changed_attributes.count',p_changed_attributes.count);
      WSH_DEBUG_SV.log(l_module_name, 'p_source_code', p_source_code);
   END IF;
   --
   x_return_status     := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   IF not WSH_DELIVERY_UTIL.G_INBOUND_FLAG and
      p_source_code = 'OE' -- check with klr
   THEN
   --{ Inbound Flag If - Starts
      FOR l_counter IN p_changed_attributes.FIRST ..p_changed_attributes.LAST
      LOOP
      --{ Loop Starts
         --
         IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'original_source_line_id:',p_changed_attributes(l_counter).original_source_line_id);
            wsh_debug_sv.log (l_module_name, 'source_line_id: ',p_changed_attributes(l_counter).source_line_id);
            wsh_debug_sv.log (l_module_name, 'action_flag',p_changed_attributes(l_counter).action_flag);
         END IF;
         --

         IF (p_changed_attributes(l_counter).action_flag <> 'I' ) THEN
         --{ Action Flag If - Starts
            IF (p_changed_attributes(l_counter).action_flag = 'S' ) THEN
               l_source_line_id := nvl(p_changed_attributes(l_counter).original_source_line_id, p_changed_attributes(l_counter).source_line_id);
            ELSE
               l_source_line_id := p_changed_attributes(l_counter).source_line_id;
            END IF;

            open  c_del_details(l_source_line_id);
            Fetch c_del_details into l_detail_rec;

            IF ( c_del_details%FOUND ) THEN
               close c_del_details;
               l_wh_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type(
                                       p_organization_id    => l_detail_rec.organization_id,
                                       x_return_status      => l_return_status );

               IF l_debug_on THEN
                  wsh_debug_sv.log(l_module_name,'l_wh_type,l_return_status',l_wh_type||','||l_return_status);
               END IF;

               IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
                  raise wsh_invalid_org;
               END IF;

               IF ( nvl(l_wh_type, FND_API.G_MISS_CHAR) = 'TW2' ) THEN
                  --
                  IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name, 'Calling Validate_Delivery_Line', WSH_DEBUG_SV.C_PROC_LEVEL);
                  END IF;
                  --
                  Validate_Delivery_Line (
                           p_changed_attributes => p_changed_attributes,
                           x_return_status      => l_return_status );

                  --
                  IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name, 'Return Status of WSH_DELIVERY_DETAILS_PUB.Split_Line', l_return_status);
                  END IF;
                  --

                  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                     --
                     IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name, 'Error: CMS changes other than Quantity and Quantity UOM');
                     END IF;
                     --
                     raise wsh_update_not_allowed;
                  END IF;

                  OPEN  c_open_detail_qty(l_source_line_id);
                  FETCH c_open_detail_qty into l_open_qty;
                  CLOSE c_open_detail_qty;

                  l_converted_open_qty := l_open_qty;

                  --Convert Open quantity to Src Requested Quantity UOM(if UOM does not match)
                  IF l_detail_rec.requested_quantity_uom <> l_detail_rec.src_requested_quantity_uom THEN
                     --
                     IF l_debug_on THEN
                         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
                     END IF;
                     --
                     l_converted_open_qty := WSH_WV_UTILS.Convert_Uom(
                            l_detail_rec.requested_quantity_uom,
                            l_detail_rec.src_requested_quantity_uom, -- Converting UOM using any detail
                            l_open_qty,
                            l_detail_rec.inventory_item_id);
                  END IF;

                  l_converted_ordered_qty := p_changed_attributes(l_counter).ordered_quantity;

                  --Convert OM Ordered Quantity to Src Requested Quantity UOM(if UOM does not match)
                  IF l_detail_rec.src_requested_quantity_uom <> p_changed_attributes(l_counter).order_quantity_uom THEN
                     --
                     IF l_debug_on THEN
                         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
                     END IF;
                     --
                     l_converted_ordered_qty := WSH_WV_UTILS.Convert_Uom(
                            p_changed_attributes(l_counter).order_quantity_uom,
                            l_detail_rec.src_requested_quantity_uom, -- Converting UOM using any detail
                            p_changed_attributes(l_counter).ordered_quantity,
                            l_detail_rec.inventory_item_id);
                  END IF;

                  l_change_quantity := l_detail_rec.src_requested_quantity - l_converted_ordered_qty;

                  --
                  IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name, 'Open Quantity', l_open_qty);
                     WSH_DEBUG_SV.log(l_module_name, 'Converted Open Quantity', l_converted_open_qty);
                     WSH_DEBUG_SV.log(l_module_name, 'Ordered Quantity', p_changed_attributes(l_counter).ordered_quantity);
                     WSH_DEBUG_SV.log(l_module_name, 'Converted Ordered Quantity', l_converted_ordered_qty);
                     WSH_DEBUG_SV.log(l_module_name, 'Source Requested Quantity', l_detail_rec.src_requested_quantity);
                     WSH_DEBUG_SV.log(l_module_name, 'Change in quantity', l_change_quantity );
                  END IF;
                  --

                  --During CMS, Raise error if open quantity available for cancelleation is less than quantity cancelled from OM
                  IF l_converted_open_qty < l_change_quantity AND
                     l_detail_rec.src_requested_quantity > l_converted_ordered_qty
                  THEN
                     --
                     IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name, 'During CMS Actual Cancel Quantity available ' || l_converted_open_qty ||
                                              ' is less than cancel quantity requested ' || l_change_quantity ||
                                              '(UOM => ' || l_detail_rec.src_requested_quantity_uom || ')');
                     END IF;
                     --
                     raise wsh_update_not_allowed;
                  END IF;
               END IF;
            END IF;

            IF c_del_details%ISOPEN THEN
               close c_del_details;
            END IF;
         --} Action Flag If - Ends
         END IF;
      --} Loop Ends
      END LOOP;
   --} Inbound Flag If - Ends
   END IF;

   x_update_allowed := 'Y';

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'x_update_allowed', x_update_allowed);
      WSH_DEBUG_SV.log(l_module_name, 'Return Status', x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION
   WHEN wsh_update_not_allowed THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('WSH', 'WSH_UPDATE_NOT_ALLOWED');
      WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
      x_update_allowed := 'N';
      IF c_del_details%ISOPEN THEN
         close c_del_details;
      END IF;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'Error occured while spliting line');
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_update_not_allowed');
      END IF;
      --
   WHEN wsh_invalid_org THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_update_allowed := 'N';
      IF c_del_details%ISOPEN THEN
         close c_del_details;
      END IF;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'Error occured while spliting line');
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_invalid_org');
      END IF;
      --
   WHEN others THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Rolling back the transactions');
      END IF;
      --
      IF c_del_details%ISOPEN THEN
         close c_del_details;
      END IF;
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
END Check_Updates_Allowed;
--
--=============================================================================
-- PRIVATE PROCEDURE :
--       Validate_Delivery_Line
--
-- PARAMETERS:
--       p_changed_attributes   => Delivery Details changed attributes
--       x_return_status        => Return Status of API (S,E,U)
--
-- COMMENT:
--       API to check if any attributes other than Ordered Quantity and Order
--       Quantity UOM is updated during CMS(Change Management System) from OM.
--
--=============================================================================
--
PROCEDURE Validate_Delivery_Line (
                   p_changed_attributes IN  WSH_INTERFACE.ChangedAttributeTabType,
                   x_return_status      OUT NOCOPY VARCHAR2 )
IS
   CURSOR c_delivery_line_info(c_line_id NUMBER)
   IS
   select wdd.*
   from   wsh_delivery_details     wdd
   where  wdd.source_line_id = c_line_id
   and    wdd.source_code = 'OE'
   and    wdd.released_status not in ( 'D', 'C' )
   and    wdd.shipment_batch_id is not null
   and    wdd.shipment_line_number is not null
   and    rownum = 1;

   l_delivery_line_info  c_delivery_line_info%ROWTYPE;

   --
   l_debug_on BOOLEAN;
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Validate_Delivery_Line';
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
   END IF;
   --

   x_return_status := WSH_UTIl_CORE.G_RET_STS_SUCCESS;

   FOR i in p_changed_attributes.FIRST .. p_changed_attributes.LAST
   LOOP
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'source_line_id', p_changed_attributes(i).source_line_id );
      END IF;
      --

      IF p_changed_attributes(i).ordered_quantity = 0 THEN
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Ordered Quantity for line is zero, so do not validate');
         END IF;
         --
         EXIT;
      END IF;

      OPEN  c_delivery_line_info(p_changed_attributes(i).source_line_id);
      FETCH c_delivery_line_info INTO l_delivery_line_info;
      IF c_delivery_line_info%NOTFOUND THEN
         EXIT;
      END IF;
      CLOSE c_delivery_line_info;

      /*
      -- Just for debugging
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'p_changed_attributes(i).shipping_instructions', p_changed_attributes(i).shipping_instructions );
         WSH_DEBUG_SV.log(l_module_name, 'l_delivery_line_info.shipping_instructions', l_delivery_line_info.shipping_instructions );
         WSH_DEBUG_SV.logmsg(l_module_name, 'arrival_set_id                 => ' || p_changed_attributes(i).arrival_set_id                || ' , => ' || l_delivery_line_info.arrival_set_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'ato_line_id                    => ' || p_changed_attributes(i).ato_line_id                   || ' , => ' || l_delivery_line_info.ato_line_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'attribute1                     => ' || p_changed_attributes(i).attribute1                    || ' , => ' || l_delivery_line_info.attribute1 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'attribute10                    => ' || p_changed_attributes(i).attribute10                   || ' , => ' || l_delivery_line_info.attribute10 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'attribute11                    => ' || p_changed_attributes(i).attribute11                   || ' , => ' || l_delivery_line_info.attribute11 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'attribute12                    => ' || p_changed_attributes(i).attribute12                   || ' , => ' || l_delivery_line_info.attribute12 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'attribute13                    => ' || p_changed_attributes(i).attribute13                   || ' , => ' || l_delivery_line_info.attribute13 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'attribute14                    => ' || p_changed_attributes(i).attribute14                   || ' , => ' || l_delivery_line_info.attribute14 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'attribute15                    => ' || p_changed_attributes(i).attribute15                   || ' , => ' || l_delivery_line_info.attribute15 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'attribute2                     => ' || p_changed_attributes(i).attribute2                    || ' , => ' || l_delivery_line_info.attribute2 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'attribute3                     => ' || p_changed_attributes(i).attribute3                    || ' , => ' || l_delivery_line_info.attribute3 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'attribute4                     => ' || p_changed_attributes(i).attribute4                    || ' , => ' || l_delivery_line_info.attribute4 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'attribute5                     => ' || p_changed_attributes(i).attribute5                    || ' , => ' || l_delivery_line_info.attribute5 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'attribute6                     => ' || p_changed_attributes(i).attribute6                    || ' , => ' || l_delivery_line_info.attribute6 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'attribute7                     => ' || p_changed_attributes(i).attribute7                    || ' , => ' || l_delivery_line_info.attribute7 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'attribute8                     => ' || p_changed_attributes(i).attribute8                    || ' , => ' || l_delivery_line_info.attribute8 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'attribute9                     => ' || p_changed_attributes(i).attribute9                    || ' , => ' || l_delivery_line_info.attribute9 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'attribute_category             => ' || p_changed_attributes(i).attribute_category            || ' , => ' || l_delivery_line_info.attribute_category );
         WSH_DEBUG_SV.logmsg(l_module_name, 'cancelled_quantity             => ' || p_changed_attributes(i).cancelled_quantity            || ' , => ' || l_delivery_line_info.cancelled_quantity );
         WSH_DEBUG_SV.logmsg(l_module_name, 'cancelled_quantity2            => ' || p_changed_attributes(i).cancelled_quantity2           || ' , => ' || l_delivery_line_info.cancelled_quantity2 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'carrier_id                     => ' || p_changed_attributes(i).carrier_id                    || ' , => ' || l_delivery_line_info.carrier_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'classification                 => ' || p_changed_attributes(i).classification                || ' , => ' || l_delivery_line_info.classification );
         WSH_DEBUG_SV.logmsg(l_module_name, 'commodity_code_cat_id          => ' || p_changed_attributes(i).commodity_code_cat_id         || ' , => ' || l_delivery_line_info.commodity_code_cat_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'container_flag                 => ' || p_changed_attributes(i).container_flag                || ' , => ' || l_delivery_line_info.container_flag );
         WSH_DEBUG_SV.logmsg(l_module_name, 'container_name                 => ' || p_changed_attributes(i).container_name                || ' , => ' || l_delivery_line_info.container_name );
         WSH_DEBUG_SV.logmsg(l_module_name, 'container_type_code            => ' || p_changed_attributes(i).container_type_code           || ' , => ' || l_delivery_line_info.container_type_code );
         WSH_DEBUG_SV.logmsg(l_module_name, 'country_of_origin              => ' || p_changed_attributes(i).country_of_origin             || ' , => ' || l_delivery_line_info.country_of_origin );
         WSH_DEBUG_SV.logmsg(l_module_name, 'currency_code                  => ' || p_changed_attributes(i).currency_code                 || ' , => ' || l_delivery_line_info.currency_code );
         WSH_DEBUG_SV.logmsg(l_module_name, 'cust_model_serial_number       => ' || p_changed_attributes(i).cust_model_serial_number      || ' , => ' || l_delivery_line_info.cust_model_serial_number );
         WSH_DEBUG_SV.logmsg(l_module_name, 'cust_po_number                 => ' || p_changed_attributes(i).cust_po_number                || ' , => ' || l_delivery_line_info.cust_po_number );
         WSH_DEBUG_SV.logmsg(l_module_name, 'customer_dock_code             => ' || p_changed_attributes(i).customer_dock_code            || ' , => ' || l_delivery_line_info.customer_dock_code );
         WSH_DEBUG_SV.logmsg(l_module_name, 'customer_id                    => ' || p_changed_attributes(i).customer_id                   || ' , => ' || l_delivery_line_info.customer_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'customer_item_id               => ' || p_changed_attributes(i).customer_item_id              || ' , => ' || l_delivery_line_info.customer_item_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'customer_job                   => ' || p_changed_attributes(i).customer_job                  || ' , => ' || l_delivery_line_info.customer_job );
         WSH_DEBUG_SV.logmsg(l_module_name, 'customer_prod_seq              => ' || p_changed_attributes(i).customer_prod_seq             || ' , => ' || l_delivery_line_info.customer_prod_seq );
         WSH_DEBUG_SV.logmsg(l_module_name, 'customer_production_line       => ' || p_changed_attributes(i).customer_production_line      || ' , => ' || l_delivery_line_info.customer_production_line );
         WSH_DEBUG_SV.logmsg(l_module_name, 'customer_requested_lot_flag    => ' || p_changed_attributes(i).customer_requested_lot_flag   || ' , => ' || l_delivery_line_info.customer_requested_lot_flag );
         WSH_DEBUG_SV.logmsg(l_module_name, 'cycle_count_quantity           => ' || p_changed_attributes(i).cycle_count_quantity          || ' , => ' || l_delivery_line_info.cycle_count_quantity );
         WSH_DEBUG_SV.logmsg(l_module_name, 'cycle_count_quantity2          => ' || p_changed_attributes(i).cycle_count_quantity2         || ' , => ' || l_delivery_line_info.cycle_count_quantity2 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'date_requested                 => ' || p_changed_attributes(i).date_requested                || ' , => ' || l_delivery_line_info.date_requested );
         WSH_DEBUG_SV.logmsg(l_module_name, 'date_scheduled                 => ' || p_changed_attributes(i).date_scheduled                || ' , => ' || l_delivery_line_info.date_scheduled );
         WSH_DEBUG_SV.logmsg(l_module_name, 'deliver_to_contact_id          => ' || p_changed_attributes(i).deliver_to_contact_id         || ' , => ' || l_delivery_line_info.deliver_to_contact_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'deliver_to_org_id              => ' || p_changed_attributes(i).deliver_to_org_id             || ' , => ' || l_delivery_line_info.deliver_to_site_use_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'delivered_quantity             => ' || p_changed_attributes(i).delivered_quantity            || ' , => ' || l_delivery_line_info.delivered_quantity );
         WSH_DEBUG_SV.logmsg(l_module_name, 'delivered_quantity2            => ' || p_changed_attributes(i).delivered_quantity2           || ' , => ' || l_delivery_line_info.delivered_quantity2 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'delivery_detail_id             => ' || p_changed_attributes(i).delivery_detail_id            || ' , => ' || l_delivery_line_info.delivery_detail_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'dep_plan_required_flag         => ' || p_changed_attributes(i).dep_plan_required_flag        || ' , => ' || l_delivery_line_info.dep_plan_required_flag );
         WSH_DEBUG_SV.logmsg(l_module_name, 'detail_container_item_id       => ' || p_changed_attributes(i).detail_container_item_id      || ' , => ' || l_delivery_line_info.detail_container_item_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'fill_percent                   => ' || p_changed_attributes(i).fill_percent                  || ' , => ' || l_delivery_line_info.fill_percent );
         WSH_DEBUG_SV.logmsg(l_module_name, 'fob_code                       => ' || p_changed_attributes(i).fob_code                      || ' , => ' || l_delivery_line_info.fob_code );
         WSH_DEBUG_SV.logmsg(l_module_name, 'freight_class_cat_id           => ' || p_changed_attributes(i).freight_class_cat_id          || ' , => ' || l_delivery_line_info.freight_class_cat_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'freight_terms_code             => ' || p_changed_attributes(i).freight_terms_code            || ' , => ' || l_delivery_line_info.freight_terms_code );
         WSH_DEBUG_SV.logmsg(l_module_name, 'gross_weight                   => ' || p_changed_attributes(i).gross_weight                  || ' , => ' || l_delivery_line_info.gross_weight );
         WSH_DEBUG_SV.logmsg(l_module_name, 'hazard_class_id                => ' || p_changed_attributes(i).hazard_class_id               || ' , => ' || l_delivery_line_info.hazard_class_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'hold_code                      => ' || p_changed_attributes(i).hold_code                     || ' , => ' || l_delivery_line_info.hold_code );
         WSH_DEBUG_SV.logmsg(l_module_name, 'inspection_flag                => ' || p_changed_attributes(i).inspection_flag               || ' , => ' || l_delivery_line_info.inspection_flag );
         WSH_DEBUG_SV.logmsg(l_module_name, 'intmed_ship_to_contact_id      => ' || p_changed_attributes(i).intmed_ship_to_contact_id     || ' , => ' || l_delivery_line_info.intmed_ship_to_contact_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'inv_interfaced_flag            => ' || p_changed_attributes(i).inv_interfaced_flag           || ' , => ' || l_delivery_line_info.inv_interfaced_flag );
         WSH_DEBUG_SV.logmsg(l_module_name, 'inventory_item_id              => ' || p_changed_attributes(i).inventory_item_id             || ' , => ' || l_delivery_line_info.inventory_item_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'item_description               => ' || p_changed_attributes(i).item_description              || ' , => ' || l_delivery_line_info.item_description );
         WSH_DEBUG_SV.logmsg(l_module_name, 'load_seq_number                => ' || p_changed_attributes(i).load_seq_number               || ' , => ' || l_delivery_line_info.load_seq_number );
         WSH_DEBUG_SV.logmsg(l_module_name, 'locator_id                     => ' || p_changed_attributes(i).locator_id                    || ' , => ' || l_delivery_line_info.locator_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'lot_number                     => ' || p_changed_attributes(i).lot_number                    || ' , => ' || l_delivery_line_info.lot_number );
         WSH_DEBUG_SV.logmsg(l_module_name, 'lpn_content_id                 => ' || p_changed_attributes(i).lpn_content_id                || ' , => ' || l_delivery_line_info.lpn_content_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'lpn_id                         => ' || p_changed_attributes(i).lpn_id                        || ' , => ' || l_delivery_line_info.lpn_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'master_container_item_id       => ' || p_changed_attributes(i).master_container_item_id      || ' , => ' || l_delivery_line_info.master_container_item_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'master_serial_number           => ' || p_changed_attributes(i).master_serial_number          || ' , => ' || l_delivery_line_info.master_serial_number );
         WSH_DEBUG_SV.logmsg(l_module_name, 'maximum_load_weight            => ' || p_changed_attributes(i).maximum_load_weight           || ' , => ' || l_delivery_line_info.maximum_load_weight );
         WSH_DEBUG_SV.logmsg(l_module_name, 'maximum_volume                 => ' || p_changed_attributes(i).maximum_volume                || ' , => ' || l_delivery_line_info.maximum_volume );
         WSH_DEBUG_SV.logmsg(l_module_name, 'minimum_fill_percent           => ' || p_changed_attributes(i).minimum_fill_percent          || ' , => ' || l_delivery_line_info.minimum_fill_percent );
         WSH_DEBUG_SV.logmsg(l_module_name, 'move_order_line_id             => ' || p_changed_attributes(i).move_order_line_id            || ' , => ' || l_delivery_line_info.move_order_line_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'movement_id                    => ' || p_changed_attributes(i).movement_id                   || ' , => ' || l_delivery_line_info.movement_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'mvt_stat_status                => ' || p_changed_attributes(i).mvt_stat_status               || ' , => ' || l_delivery_line_info.mvt_stat_status );
         WSH_DEBUG_SV.logmsg(l_module_name, 'net_weight                     => ' || p_changed_attributes(i).net_weight                    || ' , => ' || l_delivery_line_info.net_weight );
         WSH_DEBUG_SV.logmsg(l_module_name, 'oe_interfaced_flag             => ' || p_changed_attributes(i).oe_interfaced_flag            || ' , => ' || l_delivery_line_info.oe_interfaced_flag );
         WSH_DEBUG_SV.logmsg(l_module_name, 'order_quantity_uom             => ' || p_changed_attributes(i).order_quantity_uom            || ' , => ' || l_delivery_line_info.src_requested_quantity_uom );
         WSH_DEBUG_SV.logmsg(l_module_name, 'ordered_quantity               => ' || p_changed_attributes(i).ordered_quantity              || ' , => ' || l_delivery_line_info.src_requested_quantity );
         WSH_DEBUG_SV.logmsg(l_module_name, 'ordered_quantity2              => ' || p_changed_attributes(i).ordered_quantity2             || ' , => ' || l_delivery_line_info.src_requested_quantity2 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'ordered_quantity_uom2          => ' || p_changed_attributes(i).ordered_quantity_uom2         || ' , => ' || l_delivery_line_info.src_requested_quantity_uom2 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'org_id                         => ' || p_changed_attributes(i).org_id                        || ' , => ' || l_delivery_line_info.org_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'organization_id                => ' || p_changed_attributes(i).organization_id               || ' , => ' || l_delivery_line_info.organization_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'original_subinventory          => ' || p_changed_attributes(i).original_subinventory         || ' , => ' || l_delivery_line_info.original_subinventory );
         WSH_DEBUG_SV.logmsg(l_module_name, 'packing_instructions           => ' || p_changed_attributes(i).packing_instructions          || ' , => ' || l_delivery_line_info.packing_instructions );
         WSH_DEBUG_SV.logmsg(l_module_name, 'pickable_flag                  => ' || p_changed_attributes(i).pickable_flag                 || ' , => ' || l_delivery_line_info.pickable_flag );
         WSH_DEBUG_SV.logmsg(l_module_name, 'picked_quantity                => ' || p_changed_attributes(i).picked_quantity               || ' , => ' || l_delivery_line_info.picked_quantity );
         WSH_DEBUG_SV.logmsg(l_module_name, 'picked_quantity2               => ' || p_changed_attributes(i).picked_quantity2              || ' , => ' || l_delivery_line_info.picked_quantity2 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'preferred_grade                => ' || p_changed_attributes(i).preferred_grade               || ' , => ' || l_delivery_line_info.preferred_grade );
         WSH_DEBUG_SV.logmsg(l_module_name, 'project_id                     => ' || p_changed_attributes(i).project_id                    || ' , => ' || l_delivery_line_info.project_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'quality_control_quantity       => ' || p_changed_attributes(i).quality_control_quantity      || ' , => ' || l_delivery_line_info.quality_control_quantity );
         WSH_DEBUG_SV.logmsg(l_module_name, 'quality_control_quantity2      => ' || p_changed_attributes(i).quality_control_quantity2     || ' , => ' || l_delivery_line_info.quality_control_quantity2 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'received_quantity              => ' || p_changed_attributes(i).received_quantity             || ' , => ' || l_delivery_line_info.received_quantity );
         WSH_DEBUG_SV.logmsg(l_module_name, 'received_quantity2             => ' || p_changed_attributes(i).received_quantity2            || ' , => ' || l_delivery_line_info.received_quantity2 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'released_status                => ' || p_changed_attributes(i).released_status               || ' , => ' || l_delivery_line_info.released_status );
         WSH_DEBUG_SV.logmsg(l_module_name, 'request_id                     => ' || p_changed_attributes(i).request_id                    || ' , => ' || l_delivery_line_info.request_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'revision                       => ' || p_changed_attributes(i).revision                      || ' , => ' || l_delivery_line_info.revision );
         WSH_DEBUG_SV.logmsg(l_module_name, 'seal_code                      => ' || p_changed_attributes(i).seal_code                     || ' , => ' || l_delivery_line_info.seal_code );
         WSH_DEBUG_SV.logmsg(l_module_name, 'serial_number                  => ' || p_changed_attributes(i).serial_number                 || ' , => ' || l_delivery_line_info.serial_number );
         WSH_DEBUG_SV.logmsg(l_module_name, 'ship_from_org_id               => ' || p_changed_attributes(i).ship_from_org_id              || ' , => ' || l_delivery_line_info.organization_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'ship_model_complete_flag       => ' || p_changed_attributes(i).ship_model_complete_flag      || ' , => ' || l_delivery_line_info.ship_model_complete_flag );
         WSH_DEBUG_SV.logmsg(l_module_name, 'ship_set_id                    => ' || p_changed_attributes(i).ship_set_id                   || ' , => ' || l_delivery_line_info.ship_set_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'ship_to_contact_id             => ' || p_changed_attributes(i).ship_to_contact_id            || ' , => ' || l_delivery_line_info.ship_to_contact_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'ship_to_org_id                 => ' || p_changed_attributes(i).ship_to_org_id                || ' , => ' || l_delivery_line_info.ship_to_site_use_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'ship_to_site_use_id            => ' || p_changed_attributes(i).ship_to_site_use_id           || ' , => ' || l_delivery_line_info.ship_to_site_use_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'ship_tolerance_above           => ' || p_changed_attributes(i).ship_tolerance_above          || ' , => ' || l_delivery_line_info.ship_tolerance_above );
         WSH_DEBUG_SV.logmsg(l_module_name, 'ship_tolerance_below           => ' || p_changed_attributes(i).ship_tolerance_below          || ' , => ' || l_delivery_line_info.ship_tolerance_below );
         WSH_DEBUG_SV.logmsg(l_module_name, 'shipment_priority_code         => ' || p_changed_attributes(i).shipment_priority_code        || ' , => ' || l_delivery_line_info.shipment_priority_code );
         WSH_DEBUG_SV.logmsg(l_module_name, 'shipped_quantity               => ' || p_changed_attributes(i).shipped_quantity              || ' , => ' || l_delivery_line_info.shipped_quantity );
         WSH_DEBUG_SV.logmsg(l_module_name, 'shipped_quantity2              => ' || p_changed_attributes(i).shipped_quantity2             || ' , => ' || l_delivery_line_info.shipped_quantity2 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'shipping_instructions          => ' || p_changed_attributes(i).shipping_instructions         || ' , => ' || l_delivery_line_info.shipping_instructions );
         WSH_DEBUG_SV.logmsg(l_module_name, 'shipping_method_code           => ' || p_changed_attributes(i).shipping_method_code          || ' , => ' || l_delivery_line_info.ship_method_code );
         WSH_DEBUG_SV.logmsg(l_module_name, 'sold_to_contact_id             => ' || p_changed_attributes(i).sold_to_contact_id            || ' , => ' || l_delivery_line_info.sold_to_contact_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'sold_to_org_id                 => ' || p_changed_attributes(i).sold_to_org_id                || ' , => ' || l_delivery_line_info.customer_id);
         WSH_DEBUG_SV.logmsg(l_module_name, 'source_code                    => ' || p_changed_attributes(i).source_code                   || ' , => ' || l_delivery_line_info.source_code );
         WSH_DEBUG_SV.logmsg(l_module_name, 'source_header_id               => ' || p_changed_attributes(i).source_header_id              || ' , => ' || l_delivery_line_info.source_header_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'source_header_number           => ' || p_changed_attributes(i).source_header_number          || ' , => ' || l_delivery_line_info.source_header_number );
         WSH_DEBUG_SV.logmsg(l_module_name, 'source_header_type_id          => ' || p_changed_attributes(i).source_header_type_id         || ' , => ' || l_delivery_line_info.source_header_type_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'source_header_type_name        => ' || p_changed_attributes(i).source_header_type_name       || ' , => ' || l_delivery_line_info.source_header_type_name );
         WSH_DEBUG_SV.logmsg(l_module_name, 'source_line_id                 => ' || p_changed_attributes(i).source_line_id                || ' , => ' || l_delivery_line_info.source_line_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'source_line_set_id             => ' || p_changed_attributes(i).source_line_set_id            || ' , => ' || l_delivery_line_info.source_line_set_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'split_from_delivery_detail_id  => ' || p_changed_attributes(i).split_from_delivery_detail_id || ' , => ' || l_delivery_line_info.split_from_delivery_detail_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'src_requested_quantity         => ' || p_changed_attributes(i).src_requested_quantity        || ' , => ' || l_delivery_line_info.src_requested_quantity );
         WSH_DEBUG_SV.logmsg(l_module_name, 'src_requested_quantity2        => ' || p_changed_attributes(i).src_requested_quantity2       || ' , => ' || l_delivery_line_info.src_requested_quantity2 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'src_requested_quantity_uom     => ' || p_changed_attributes(i).src_requested_quantity_uom    || ' , => ' || l_delivery_line_info.src_requested_quantity_uom );
         WSH_DEBUG_SV.logmsg(l_module_name, 'src_requested_quantity_uom2    => ' || p_changed_attributes(i).src_requested_quantity_uom2   || ' , => ' || l_delivery_line_info.src_requested_quantity_uom2 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'subinventory                   => ' || p_changed_attributes(i).subinventory                  || ' , => ' || l_delivery_line_info.subinventory );
         WSH_DEBUG_SV.logmsg(l_module_name, 'task_id                        => ' || p_changed_attributes(i).task_id                       || ' , => ' || l_delivery_line_info.task_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'to_serial_number               => ' || p_changed_attributes(i).to_serial_number              || ' , => ' || l_delivery_line_info.to_serial_number );
         WSH_DEBUG_SV.logmsg(l_module_name, 'top_model_line_id              => ' || p_changed_attributes(i).top_model_line_id             || ' , => ' || l_delivery_line_info.top_model_line_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'tp_attribute1                  => ' || p_changed_attributes(i).tp_attribute1                 || ' , => ' || l_delivery_line_info.tp_attribute1 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'tp_attribute10                 => ' || p_changed_attributes(i).tp_attribute10                || ' , => ' || l_delivery_line_info.tp_attribute10 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'tp_attribute11                 => ' || p_changed_attributes(i).tp_attribute11                || ' , => ' || l_delivery_line_info.tp_attribute11 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'tp_attribute12                 => ' || p_changed_attributes(i).tp_attribute12                || ' , => ' || l_delivery_line_info.tp_attribute12 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'tp_attribute13                 => ' || p_changed_attributes(i).tp_attribute13                || ' , => ' || l_delivery_line_info.tp_attribute13 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'tp_attribute14                 => ' || p_changed_attributes(i).tp_attribute14                || ' , => ' || l_delivery_line_info.tp_attribute14 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'tp_attribute15                 => ' || p_changed_attributes(i).tp_attribute15                || ' , => ' || l_delivery_line_info.tp_attribute15 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'tp_attribute2                  => ' || p_changed_attributes(i).tp_attribute2                 || ' , => ' || l_delivery_line_info.tp_attribute2 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'tp_attribute3                  => ' || p_changed_attributes(i).tp_attribute3                 || ' , => ' || l_delivery_line_info.tp_attribute3 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'tp_attribute4                  => ' || p_changed_attributes(i).tp_attribute4                 || ' , => ' || l_delivery_line_info.tp_attribute4 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'tp_attribute5                  => ' || p_changed_attributes(i).tp_attribute5                 || ' , => ' || l_delivery_line_info.tp_attribute5 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'tp_attribute6                  => ' || p_changed_attributes(i).tp_attribute6                 || ' , => ' || l_delivery_line_info.tp_attribute6 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'tp_attribute7                  => ' || p_changed_attributes(i).tp_attribute7                 || ' , => ' || l_delivery_line_info.tp_attribute7 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'tp_attribute8                  => ' || p_changed_attributes(i).tp_attribute8                 || ' , => ' || l_delivery_line_info.tp_attribute8 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'tp_attribute9                  => ' || p_changed_attributes(i).tp_attribute9                 || ' , => ' || l_delivery_line_info.tp_attribute9 );
         WSH_DEBUG_SV.logmsg(l_module_name, 'tp_attribute_category          => ' || p_changed_attributes(i).tp_attribute_category         || ' , => ' || l_delivery_line_info.tp_attribute_category );
         WSH_DEBUG_SV.logmsg(l_module_name, 'tracking_number                => ' || p_changed_attributes(i).tracking_number               || ' , => ' || l_delivery_line_info.tracking_number );
         WSH_DEBUG_SV.logmsg(l_module_name, 'transaction_temp_id            => ' || p_changed_attributes(i).transaction_temp_id           || ' , => ' || l_delivery_line_info.transaction_temp_id );
         WSH_DEBUG_SV.logmsg(l_module_name, 'unit_number                    => ' || p_changed_attributes(i).unit_number                   || ' , => ' || l_delivery_line_info.unit_number );
         WSH_DEBUG_SV.logmsg(l_module_name, 'unit_price                     => ' || p_changed_attributes(i).unit_price                    || ' , => ' || l_delivery_line_info.unit_price );
         WSH_DEBUG_SV.logmsg(l_module_name, 'volume                         => ' || p_changed_attributes(i).volume                        || ' , => ' || l_delivery_line_info.volume );
         WSH_DEBUG_SV.logmsg(l_module_name, 'volume_uom_code                => ' || p_changed_attributes(i).volume_uom_code               || ' , => ' || l_delivery_line_info.volume_uom_code );
         WSH_DEBUG_SV.logmsg(l_module_name, 'weight_uom_code                => ' || p_changed_attributes(i).weight_uom_code               || ' , => ' || l_delivery_line_info.weight_uom_code );
         WSH_DEBUG_SV.logmsg(l_module_name, 'filled_volume                  => ' || p_changed_attributes(i).filled_volume                 || ' , => ' || l_delivery_line_info.filled_volume );
         WSH_DEBUG_SV.logmsg(l_module_name, 'Changed Subinventory           => ' || p_changed_attributes(i).subinventory                  || ' , => ' || l_delivery_line_info.original_subinventory );
      END IF;
      --
      */

      IF (
             ( ( nvl(p_changed_attributes(i).arrival_set_id, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.arrival_set_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).arrival_set_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).ato_line_id, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.ato_line_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).ato_line_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).attribute1, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.attribute1, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).attribute1 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).attribute10, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.attribute10, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).attribute10 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).attribute11, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.attribute11, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).attribute11 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).attribute12, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.attribute12, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).attribute12 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).attribute13, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.attribute13, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).attribute13 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).attribute14, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.attribute14, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).attribute14 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).attribute15, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.attribute15, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).attribute15 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).attribute2, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.attribute2, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).attribute2 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).attribute3, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.attribute3, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).attribute3 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).attribute4, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.attribute4, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).attribute4 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).attribute5, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.attribute5, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).attribute5 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).attribute6, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.attribute6, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).attribute6 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).attribute7, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.attribute7, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).attribute7 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).attribute8, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.attribute8, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).attribute8 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).attribute9, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.attribute9, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).attribute9 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).attribute_category, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.attribute_category, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).attribute_category = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).cancelled_quantity, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.cancelled_quantity, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).cancelled_quantity = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).cancelled_quantity2, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.cancelled_quantity2, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).cancelled_quantity2 = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).carrier_id, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.carrier_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).carrier_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).classification, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.classification, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).classification = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).commodity_code_cat_id, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.commodity_code_cat_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).commodity_code_cat_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).container_flag, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.container_flag, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).container_flag = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).container_name, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.container_name, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).container_name = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).container_type_code, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.container_type_code, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).container_type_code = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).country_of_origin, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.country_of_origin, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).country_of_origin = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).currency_code, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.currency_code, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).currency_code = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).cust_model_serial_number, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.cust_model_serial_number, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).cust_model_serial_number = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).cust_po_number, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.cust_po_number, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).cust_po_number = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).customer_dock_code, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.customer_dock_code, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).customer_dock_code = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).customer_id, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.customer_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).customer_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).customer_job, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.customer_job, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).customer_job = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).customer_prod_seq, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.customer_prod_seq, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).customer_prod_seq = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).customer_production_line, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.customer_production_line, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).customer_production_line = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).customer_requested_lot_flag, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.customer_requested_lot_flag, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).customer_requested_lot_flag = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).cycle_count_quantity, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.cycle_count_quantity, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).cycle_count_quantity = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).cycle_count_quantity2, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.cycle_count_quantity2, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).cycle_count_quantity2 = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).date_requested, FND_API.G_MISS_DATE) = nvl(l_delivery_line_info.date_requested, FND_API.G_MISS_DATE ) )
              or ( p_changed_attributes(i).date_requested = FND_API.G_MISS_DATE ) )
         and ( (  nvl(p_changed_attributes(i).date_scheduled, FND_API.G_MISS_DATE) = nvl(l_delivery_line_info.date_scheduled, FND_API.G_MISS_DATE ) )
              or ( p_changed_attributes(i).date_scheduled = FND_API.G_MISS_DATE ) )
         and ( (  nvl(p_changed_attributes(i).deliver_to_contact_id, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.deliver_to_contact_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).deliver_to_contact_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).deliver_to_org_id, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.deliver_to_site_use_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).deliver_to_org_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).delivered_quantity, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.delivered_quantity, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).delivered_quantity = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).delivered_quantity2, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.delivered_quantity2, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).delivered_quantity2 = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).delivery_detail_id, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.delivery_detail_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).delivery_detail_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).dep_plan_required_flag, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.dep_plan_required_flag, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).dep_plan_required_flag = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).detail_container_item_id, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.detail_container_item_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).detail_container_item_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).fill_percent, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.fill_percent, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).fill_percent = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).fob_code, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.fob_code, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).fob_code = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).freight_class_cat_id, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.freight_class_cat_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).freight_class_cat_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).freight_terms_code, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.freight_terms_code, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).freight_terms_code = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).gross_weight, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.gross_weight, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).gross_weight = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).hazard_class_id, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.hazard_class_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).hazard_class_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).hold_code, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.hold_code, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).hold_code = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).inspection_flag, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.inspection_flag, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).inspection_flag = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).intmed_ship_to_contact_id, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.intmed_ship_to_contact_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).intmed_ship_to_contact_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).inv_interfaced_flag, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.inv_interfaced_flag, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).inv_interfaced_flag = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).inventory_item_id, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.inventory_item_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).inventory_item_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).item_description, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.item_description, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).item_description = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).load_seq_number, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.load_seq_number, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).load_seq_number = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).locator_id, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.locator_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).locator_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).lot_number, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.lot_number, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).lot_number = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).lpn_content_id, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.lpn_content_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).lpn_content_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).lpn_id, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.lpn_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).lpn_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).master_container_item_id, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.master_container_item_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).master_container_item_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).master_serial_number, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.master_serial_number, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).master_serial_number = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).maximum_load_weight, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.maximum_load_weight, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).maximum_load_weight = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).maximum_volume, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.maximum_volume, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).maximum_volume = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).minimum_fill_percent, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.minimum_fill_percent, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).minimum_fill_percent = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).move_order_line_id, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.move_order_line_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).move_order_line_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).movement_id, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.movement_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).movement_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).mvt_stat_status, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.mvt_stat_status, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).mvt_stat_status = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).net_weight, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.net_weight, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).net_weight = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).oe_interfaced_flag, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.oe_interfaced_flag, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).oe_interfaced_flag = FND_API.G_MISS_CHAR ) )
      -- Only ordered quantity and uom is allowed to update as part of CMS.
      /*
         and ( (  nvl(p_changed_attributes(i).order_quantity_uom, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.src_requested_quantity_uom, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).order_quantity_uom = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).ordered_quantity, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.src_requested_quantity, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).ordered_quantity = FND_API.G_MISS_NUM ) )
      */
         and ( (  nvl(p_changed_attributes(i).ordered_quantity2, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.src_requested_quantity2, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).ordered_quantity2 = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).ordered_quantity_uom2, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.src_requested_quantity_uom2, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).ordered_quantity_uom2 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).org_id, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.org_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).org_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).organization_id, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.organization_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).organization_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).subinventory, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.original_subinventory, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).subinventory = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).packing_instructions, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.packing_instructions, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).packing_instructions = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).pickable_flag, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.pickable_flag, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).pickable_flag = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).picked_quantity, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.picked_quantity, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).picked_quantity = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).picked_quantity2, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.picked_quantity2, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).picked_quantity2 = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).preferred_grade, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.preferred_grade, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).preferred_grade = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).project_id, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.project_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).project_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).quality_control_quantity, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.quality_control_quantity, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).quality_control_quantity = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).quality_control_quantity2, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.quality_control_quantity2, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).quality_control_quantity2 = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).received_quantity, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.received_quantity, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).received_quantity = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).received_quantity2, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.received_quantity2, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).received_quantity2 = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).released_status, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.released_status, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).released_status = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).request_id, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.request_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).request_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).revision, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.revision, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).revision = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).seal_code, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.seal_code, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).seal_code = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).serial_number, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.serial_number, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).serial_number = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).ship_from_org_id, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.organization_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).ship_from_org_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).ship_model_complete_flag, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.ship_model_complete_flag, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).ship_model_complete_flag = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).ship_set_id, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.ship_set_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).ship_set_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).ship_to_contact_id, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.ship_to_contact_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).ship_to_contact_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).ship_to_org_id, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.ship_to_site_use_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).ship_to_org_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).ship_to_site_use_id, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.ship_to_site_use_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).ship_to_site_use_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).ship_tolerance_above, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.ship_tolerance_above, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).ship_tolerance_above = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).ship_tolerance_below, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.ship_tolerance_below, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).ship_tolerance_below = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).shipment_priority_code, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.shipment_priority_code, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).shipment_priority_code = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).shipped_quantity, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.shipped_quantity, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).shipped_quantity = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).shipped_quantity2, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.shipped_quantity2, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).shipped_quantity2 = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).shipping_instructions, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.shipping_instructions, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).shipping_instructions = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).shipping_method_code, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.ship_method_code, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).shipping_method_code = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).sold_to_contact_id, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.sold_to_contact_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).sold_to_contact_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).sold_to_org_id, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.customer_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).sold_to_org_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).source_code, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.source_code, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).source_code = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).source_header_id, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.source_header_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).source_header_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).source_header_number, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.source_header_number, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).source_header_number = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).source_header_type_id, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.source_header_type_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).source_header_type_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).source_header_type_name, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.source_header_type_name, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).source_header_type_name = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).source_line_id, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.source_line_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).source_line_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).source_line_set_id, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.source_line_set_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).source_line_set_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).split_from_delivery_detail_id, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.split_from_delivery_detail_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).split_from_delivery_detail_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).src_requested_quantity, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.src_requested_quantity, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).src_requested_quantity = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).src_requested_quantity2, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.src_requested_quantity2, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).src_requested_quantity2 = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).src_requested_quantity_uom, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.src_requested_quantity_uom, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).src_requested_quantity_uom = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).src_requested_quantity_uom2, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.src_requested_quantity_uom2, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).src_requested_quantity_uom2 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).task_id, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.task_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).task_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).to_serial_number, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.to_serial_number, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).to_serial_number = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).top_model_line_id, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.top_model_line_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).top_model_line_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).tp_attribute1, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.tp_attribute1, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).tp_attribute1 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).tp_attribute10, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.tp_attribute10, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).tp_attribute10 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).tp_attribute11, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.tp_attribute11, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).tp_attribute11 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).tp_attribute12, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.tp_attribute12, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).tp_attribute12 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).tp_attribute13, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.tp_attribute13, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).tp_attribute13 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).tp_attribute14, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.tp_attribute14, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).tp_attribute14 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).tp_attribute15, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.tp_attribute15, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).tp_attribute15 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).tp_attribute2, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.tp_attribute2, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).tp_attribute2 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).tp_attribute3, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.tp_attribute3, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).tp_attribute3 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).tp_attribute4, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.tp_attribute4, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).tp_attribute4 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).tp_attribute5, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.tp_attribute5, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).tp_attribute5 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).tp_attribute6, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.tp_attribute6, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).tp_attribute6 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).tp_attribute7, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.tp_attribute7, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).tp_attribute7 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).tp_attribute8, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.tp_attribute8, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).tp_attribute8 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).tp_attribute9, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.tp_attribute9, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).tp_attribute9 = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).tp_attribute_category, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.tp_attribute_category, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).tp_attribute_category = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).tracking_number, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.tracking_number, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).tracking_number = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).transaction_temp_id, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.transaction_temp_id, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).transaction_temp_id = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).unit_number, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.unit_number, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).unit_number = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).unit_price, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.unit_price, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).unit_price = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).volume, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.volume, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).volume = FND_API.G_MISS_NUM ) )
         and ( (  nvl(p_changed_attributes(i).volume_uom_code, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.volume_uom_code, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).volume_uom_code = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).weight_uom_code, FND_API.G_MISS_CHAR) = nvl(l_delivery_line_info.weight_uom_code, FND_API.G_MISS_CHAR ) )
              or ( p_changed_attributes(i).weight_uom_code = FND_API.G_MISS_CHAR ) )
         and ( (  nvl(p_changed_attributes(i).filled_volume, FND_API.G_MISS_NUM) = nvl(l_delivery_line_info.filled_volume, FND_API.G_MISS_NUM ) )
              or ( p_changed_attributes(i).filled_volume = FND_API.G_MISS_NUM ) )
          )
      THEN
         --Nothing has been changed
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'INSIDE VALIDATION SUCCESS' );
         END IF;
         --
         x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      ELSE
         --Raise Error
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Attributes does not match so returning error' );
         END IF;
         --
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      END IF;
   END LOOP;

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'Return Status',x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION
   WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.Default_Handler('WSH_SHIPMENT_REQUEST_PKG.Validate_Delivery_Line');
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Validate_Delivery_Line;

-- TPW - Distributed Organization Changes - End



END WSH_DELIVERY_DETAILS_UTILITIES;



/
