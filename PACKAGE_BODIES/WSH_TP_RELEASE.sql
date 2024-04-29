--------------------------------------------------------
--  DDL for Package Body WSH_TP_RELEASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_TP_RELEASE" as
/* $Header: WSHTPRLB.pls 120.11.12010000.2 2008/12/22 12:59:44 selsubra ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_TP_RELEASE';

  c_routing_firm_flag CONSTANT VARCHAR2(1) := 'F';
  G_lc_days_profile   VARCHAR2(10);
  G_earliest_profile VARCHAR2(30);
  G_LDD_profile VARCHAR2(30);
  G_populate_date_profile VARCHAR2(1); --  Bug 4368984

  TYPE Distinct_Ids_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
-- START
-- Package for Transportation Planning Actions specific code
-- END

-- START
-- PROCEDURE change_ignoreplan_status
--
-- 1. Actions Ignore for Planning, Include for Planning can onlybe performed from the topmost entity.
--    If there is a line assigned to a delivery which is assigned to a trip, the action can only be
--    performed from the trip.
-- 2. If the user performs Ignore for Planning from the trip, the flag must get cascaded down to
--    all the deliveries, lines of that trip. If there are other trips associated with the deliveries
--    with a different ignore for planning, error. If there are multiple trips associated with
--    a delivery, all the trips must be selected and the action performed.
-- 3. TPW, Carrier Manifest lines, dels have to be always marked as ignore_for_plan
-- 4. When OTM is installed, third party instance lines can become included
--    for planning.
--
-- IMPORTANT NOTE (from bugs 5746444 and 5746110):
-- No new internal calls to this API should be added; the new calls
-- should go through the group API.  This is to enforce validation
-- consistently because this API does not have consistent validation when
-- entity is TRIP.  At this time (January 2007), there is no internal call
-- for this entity.
--
-- END

PROCEDURE change_ignoreplan_status
                   (p_entity        IN VARCHAR2,                     --'DLVY', 'DLVB', 'TRIP' dep on place from which it is called
                    p_in_ids        IN wsh_util_core.id_tab_type,    -- table of ids of above entity
                    p_action_code   IN VARCHAR2,                 -- either 'IGNORE_PLAN', 'INCLUDE_PLAN'
                    x_return_status OUT NOCOPY VARCHAR2) IS

CURSOR c_get_deliveries (p_tripid NUMBER) IS
SELECT dl.delivery_id, dl.planned_flag, dl.status_code, dl.ignore_for_planning, dl.name delivery_name,
       dl.organization_id organization_id,               -- LPN CONV. rv
       nvl(dl.shipment_direction,'O') shipment_direction -- LPN CONV. rv
FROM   wsh_trips t, wsh_trip_stops st, wsh_delivery_legs dg, wsh_new_deliveries dl
WHERE  t.trip_id = p_tripid AND
       st.trip_id = t.trip_id AND
       dg.pick_up_stop_id = st.stop_id AND
       dl.delivery_id = dg.delivery_id;

CURSOR c_get_dels_diff_ignoreflag (p_delid NUMBER, p_tripid NUMBER, p_ignoreplan VARCHAR2) IS
SELECT dl.name delivery_name, t.name trip_name
FROM   wsh_trips t, wsh_trip_stops st, wsh_delivery_legs dg, wsh_new_deliveries dl
WHERE  t.trip_id <> p_tripid AND
       st.trip_id = t.trip_id AND
       dg.pick_up_stop_id = st.stop_id AND
       dl.delivery_id = dg.delivery_id AND
       dl.delivery_id=p_delid AND
       (nvl(t.ignore_for_planning,'N')<>p_ignoreplan);
--       OR t.planned_flag='F'); --change in design - firm check not needed

CURSOR c_get_del_trips (p_delid NUMBER, p_tripid NUMBER) IS
SELECT t.trip_id, t.name trip_name
FROM   wsh_trips t, wsh_trip_stops st, wsh_delivery_legs dg
WHERE  t.trip_id <> p_tripid AND
       st.trip_id = t.trip_id AND
       dg.pick_up_stop_id = st.stop_id AND
       dg.delivery_id=p_delid;
--     AND t.planned_flag <> 'F'; --change in design - firm check not needed

CURSOR c_get_del_ignoreflag_difftrip (p_delid NUMBER, p_ignoreplan VARCHAR2) IS
SELECT dl.name delivery_name, t.name trip_name
FROM   wsh_trips t, wsh_trip_stops st, wsh_delivery_legs dg, wsh_new_deliveries dl
WHERE  st.trip_id = t.trip_id AND
       dg.pick_up_stop_id = st.stop_id AND
       dl.delivery_id = dg.delivery_id AND
       dl.delivery_id=p_delid AND
       ( nvl(t.ignore_for_planning, 'N')<>p_ignoreplan);
--       OR t.planned_flag='F'); --change in design - firm check not needed

CURSOR c_get_det_ignoreflag_diff_del (p_detailid NUMBER, p_ignoreplan VARCHAR2) IS
SELECT wnd.name delivery_name
FROM   wsh_delivery_assignments_v wda, wsh_new_deliveries wnd
WHERE  wda.delivery_id = wnd.delivery_id AND
       wda.delivery_id IS NOT NULL AND
       wda.delivery_detail_id=p_detailid AND
       (nvl(wnd.ignore_for_planning, 'N')<>p_ignoreplan);
--      OR wnd.planned_flag IN ('F', 'Y'));--change in design - firm check not needed

CURSOR c_get_lines(p_delid NUMBER) IS
SELECT dd.delivery_detail_id, dd.ignore_for_planning, dd.source_code, dd.container_flag,
       nvl(dd.line_direction,'O') line_direction, organization_id  -- LPN CONV. rv
FROM   wsh_delivery_details dd,
       wsh_delivery_assignments_v da
WHERE  da.delivery_id = p_delid AND
       da.delivery_id IS NOT NULL AND
       da.delivery_detail_id = dd.delivery_detail_id;

CURSOR c_get_det_org (p_detid NUMBER) IS
select organization_id, source_code, container_flag
from wsh_delivery_details
where delivery_detail_id=p_detid;

CURSOR c_get_del_org (p_delid NUMBER) IS
select organization_id, name delivery_name, delivery_type
from wsh_new_deliveries
where delivery_id=p_delid;

CURSOR c_get_container (p_detailid NUMBER) IS
select container_flag, container_name,
       organization_id,
       nvl(line_direction,'O') line_direction -- LPN CONV. rv
from wsh_delivery_details
where delivery_detail_id=p_detailid
and container_flag='Y';

CURSOR c_get_cont_lines(p_detailid NUMBER) IS
SELECT  delivery_detail_id
FROM  wsh_delivery_assignments_v
START WITH delivery_detail_id =p_detailid
CONNECT BY prior delivery_detail_id = parent_delivery_detail_id
and rownum < 10;

--see if detail is assigned to a container and a diff ignore/include plan action is being performed. if so, ask user to do it from topmost entity.
CURSOR c_get_det_ignoreflag_diff_cont (p_detailid NUMBER, p_ignoreplan VARCHAR2) IS
SELECT 'Y'
FROM   wsh_delivery_assignments_v wda, wsh_delivery_details wdd
WHERE  wda.delivery_detail_id = wdd.delivery_detail_id AND
       wda.parent_delivery_detail_id IS NOT NULL AND
       wdd.delivery_detail_id=p_detailid AND
       nvl(wdd.ignore_for_planning,'N')<>p_ignoreplan;


l_del_cur                c_get_deliveries%ROWTYPE;
--l_del_forlines_cur     c_get_del_forlines%ROWTYPE;
l_lines_cur              c_get_lines%ROWTYPE;
l_tmp_trip_ids           wsh_util_core.id_tab_type;
l_tmp_del_ids            wsh_util_core.id_tab_type;
l_tmp_det_ids            wsh_util_core.id_tab_type;
l_tmp_detail_ids         wsh_util_core.id_tab_type;
l_ignoreplan             VARCHAR2(1);
l_is_container           VARCHAR2(1);
l_container_name         wsh_delivery_details.container_name%TYPE;
l_num_error              NUMBER :=0;
l_warn                   NUMBER :=0;
l_return_status          VARCHAR2 (1);
l_wh_type                VARCHAR2(3);
l_okay                   VARCHAR2(1);
l_entity                 VARCHAR2(2000);
others                   EXCEPTION;
l_batch_size             NUMBER:=10000;

--OTM R12, glog proj
l_delivery_info_tab      WSH_NEW_DELIVERIES_PVT.DELIVERY_ATTR_TBL_TYPE;
l_delivery_info          WSH_NEW_DELIVERIES_PVT.DELIVERY_REC_TYPE;
l_new_interface_flag_tab WSH_UTIL_CORE.COLUMN_TAB_TYPE;
l_new_version_number_tab WSH_UTIL_CORE.ID_TAB_TYPE;
l_temp                   NUMBER;
l_msg_count              NUMBER;
l_msg_data               VARCHAR2(2000);
l_del_trip_tab           WMS_SHIPPING_INTERFACE_GRP.G_DLVY_TRIP_TBL;
l_tms_update             VARCHAR2(1);
l_gc3_is_installed       VARCHAR2(1);
l_is_delivery_empty      VARCHAR2(1);
l_tp_plan_name_update    VARCHAR2(1);

--end of OTM R12, glog proj

-- LPN CONV. rv
l_wms_org VARCHAR2(10) := 'N';
l_sync_tmp_wms_recTbl wsh_glbl_var_strct_grp.sync_tmp_recTbl_type;
l_sync_tmp_inv_recTbl wsh_glbl_var_strct_grp.sync_tmp_recTbl_type;
TYPE T_V1    is TABLE OF VARCHAR2(01);

l_cont_flag_tbl wsh_util_core.Column_Tab_Type;
l_line_dir_tbl wsh_util_core.Column_Tab_Type;
l_orgn_id_tbl wsh_util_core.id_Tab_Type;
--l_cont_flag_tbl T_V1 := T_V1();

l_child_cnt_counter NUMBER;
l_cnt_wms_counter NUMBER;
l_cnt_inv_counter NUMBER;
l_cont_org_id     NUMBER;
l_cont_line_dir   VARCHAR2(10);

-- LPN CONV. rv


--
l_debug_on               BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'change_ignoreplan_status';
--
BEGIN

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;

  IF l_debug_on IS NULL THEN
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
     WSH_DEBUG_SV.push(l_module_name);
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  --OTM R12, glog proj, use Global Variable
  l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED;

  -- If null, call the function
  IF l_gc3_is_installed IS NULL THEN
    l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED;
  END IF;
  -- Initialize these as they are used in UPDATE statement and in cases where
  -- these are not actually populated
  l_new_interface_flag_tab(1) := WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT;
  l_new_version_number_tab(1) := 1;
  -- end of OTM R12, glog proj

  IF ((WSH_UTIL_CORE.TP_IS_INSTALLED = 'Y' OR
       l_gc3_is_installed = 'Y') -- OTM R12, glog proj
    AND p_entity IN ('DLVY', 'DLVB', 'TRIP')
    AND p_in_ids is not null AND p_in_ids.COUNT>0) THEN

        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'p_entity',p_entity);
           WSH_DEBUG_SV.log(l_module_name,'P_in_IDs.COUNT',p_in_ids.count);
           WSH_DEBUG_SV.log(l_module_name,'p_action_code',p_action_code);
        END IF;

        --if lower level entity is passed and higher level entity has different
        --ignore for planning, error. same applies for TPW/manifesting carrier updates

        IF (p_action_code='IGNORE_PLAN') THEN
            l_ignoreplan:='Y';
        ELSE
            l_ignoreplan:='N';
        END IF;

        if p_entity='TRIP' then

         -- LPN CONV. rv
         l_cnt_wms_counter := 1;
         l_cnt_inv_counter := 1;
         -- LPN CONV. rv
          FOR i in 1..p_in_ids.COUNT LOOP

             l_tmp_del_ids.delete;
             l_tmp_detail_ids.delete;

             FOR l_del_cur IN c_get_deliveries(p_in_ids(i)) LOOP


               -- if delivery has other trips, check if those trips also have been selected for
               -- doing the action. if even one related trip has not been selected, it is a error
               -- this might also affect trips which are in list of p_in_ids but which
               -- does not have any other related trips (thru deliveries). This has been done for performance reasons

               l_okay:='F';
               FOR cur_othertrip IN c_get_del_trips(l_del_cur.delivery_id, p_in_ids(i)) LOOP
                 l_okay:='F';
                 FOR j IN p_in_ids.FIRST..p_in_ids.LAST LOOP
                    IF cur_othertrip.trip_id=p_in_ids(j) THEN
                       l_okay:='T';
                       GOTO next_deltrip;
                    END IF;
                 END LOOP;
                 IF l_okay='F' THEN -- atleast one of the trips the del is assigned to is not in list of ids
                    FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_IGNOREPLAN_ERROR');
                    FND_MESSAGE.SET_TOKEN('TRIP_NAME',wsh_trips_pvt.get_name(p_in_ids(i)));
                    FND_MESSAGE.SET_TOKEN('DEL_NAME',l_del_cur.delivery_name);
                    FND_MESSAGE.SET_TOKEN('REL_TRIP_NAME',cur_othertrip.trip_name);
                    wsh_util_core.add_message(WSH_UTIL_CORE.g_ret_sts_error,l_module_name);

                    FND_MESSAGE.SET_NAME('WSH','WSH_ALL_IGNORE_PLAN_ERROR');
                    l_entity := FND_MESSAGE.GET_STRING('WSH','WSH_ENTITY_TRIP');
                    FND_MESSAGE.SET_TOKEN('ENTITY',l_entity);
                    wsh_util_core.add_message(WSH_UTIL_CORE.g_ret_sts_error,l_module_name);
                    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                    IF l_debug_on THEN
                       WSH_DEBUG_SV.pop(l_module_name);
                    END IF;
                    RETURN;
                 END IF;
                 <<next_deltrip>>
                 null;
               END LOOP;

               --2. add check to see if del is TPW or CMS if action is 'INCLUDE_PLAN'
               IF l_ignoreplan='N' THEN
                 FOR cur IN c_get_del_org(l_del_cur.delivery_id) LOOP
                   l_wh_type := WSH_EXTERNAL_INTERFACE_SV.get_warehouse_type
                                               (p_organization_id => cur.organization_id,
                                                x_return_status   => l_return_status,
                                                p_delivery_id     => l_del_cur.delivery_id,
                                                p_msg_display   => 'N');


                   IF (nvl(l_wh_type, FND_API.G_MISS_CHAR) IN ('TPW','CMS')) THEN
                      IF l_debug_on THEN
                           WSH_DEBUG_SV.log(l_module_name,'Get_Warehouse_Type cur.organization_id,l_wh_type,l_return_status',cur.organization_id||l_wh_type||l_return_status);
                      END IF;

                      FND_MESSAGE.SET_NAME('WSH','WSH_IGNORE_PLAN_TPW_ERROR');
                      FND_MESSAGE.SET_TOKEN('DEL_NAME',cur.delivery_name);
                      wsh_util_core.add_message(WSH_UTIL_CORE.g_ret_sts_error,l_module_name);
                      l_num_error:=l_num_error+1;
                      GOTO next_trip;
                   END IF;
                   IF cur.delivery_type = 'CONSOLIDATION' THEN
                      FND_MESSAGE.SET_NAME('WSH','WSH_IGNORE_PLAN_MDC_ERROR');
                      FND_MESSAGE.SET_TOKEN('DEL_NAME',cur.delivery_name);
                      wsh_util_core.add_message(WSH_UTIL_CORE.g_ret_sts_error,l_module_name);
                      l_num_error:=l_num_error+1;
                      GOTO next_trip;
                   END IF;
                 END LOOP;
               END IF;

               --get details
               FOR l_det_cur IN c_get_lines(l_del_cur.delivery_id) LOOP
                  -- 5746444: disable this check when OTM is installed.
                  IF l_ignoreplan='N' AND l_det_cur.source_code='WSH'
                     and l_det_cur.container_flag='N'
                     AND l_gc3_is_installed = 'N' THEN   -- OTM R12
                     --do not allow lines in thrid party instance to be set to include for planning
                      FND_MESSAGE.SET_NAME('WSH','WSH_IGNORE_PLAN_TPW_ERROR');
                      FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(l_del_cur.delivery_id));
                      wsh_util_core.add_message(WSH_UTIL_CORE.g_ret_sts_error,l_module_name);
                      l_num_error:=l_num_error+1;
                      GOTO next_trip;
                  ELSE
                     l_tmp_detail_ids(l_tmp_detail_ids.COUNT+1):=l_det_cur.delivery_detail_id;

                     --
                     --LPN CONV. rv
                     --
                     IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
                     THEN
                     --{

                         l_wms_org := wsh_util_validate.check_wms_org(l_det_cur.organization_id);
                         --
                         IF(l_wms_org = 'Y' AND l_det_cur.container_flag IN ('Y','C')
                            AND l_det_cur.line_direction in ('O', 'IO')) THEN
                           l_sync_tmp_wms_recTbl.delivery_detail_id_tbl(l_cnt_wms_counter) := l_det_cur.delivery_detail_id;
                           l_sync_tmp_wms_recTbl.operation_type_tbl(l_cnt_wms_counter) := 'UPDATE';
                           l_cnt_wms_counter := l_cnt_wms_counter +1;
                         ELSIF (l_wms_org = 'N' AND l_det_cur.container_flag IN ('Y','C')
                                AND l_det_cur.line_direction in ('O', 'IO')) THEN
                           l_sync_tmp_inv_recTbl.delivery_detail_id_tbl(l_cnt_inv_counter) := l_det_cur.delivery_detail_id;
                           l_sync_tmp_inv_recTbl.operation_type_tbl(l_cnt_inv_counter) := 'UPDATE';
                           l_cnt_inv_counter := l_cnt_inv_counter +1;
                         END IF;
                     --}
                     END IF;
                     -- LPN CONV. rv
                     --
                  END IF;
               END LOOP;

               l_tmp_del_ids(l_tmp_del_ids.COUNT+1):=l_del_cur.delivery_id;

             END LOOP;

             SAVEPOINT before_update;

             -- LPN CONV. rv
             --
             IF l_debug_on THEN
               wsh_debug_sv.LOG(l_module_name, 'Count of l_sync_tmp_wms_recTbl', l_sync_tmp_wms_recTbl.delivery_detail_id_tbl.count);
               wsh_debug_sv.LOG(l_module_name, 'Count of l_sync_tmp_inv_recTbl', l_sync_tmp_inv_recTbl.delivery_detail_id_tbl.count);
             END IF;
             --
             --
             IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
             THEN
             --{
                 IF  WSH_WMS_LPN_GRP.GK_WMS_UPD_GRP
                 AND l_sync_tmp_wms_recTbl.delivery_detail_id_tbl.count > 0
                 THEN
                 --{
                     --
                     -- Debug Statements
                     --
                     IF l_debug_on THEN
                         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WMS_SYNC_TMP_PKG.MERGE_BULK',WSH_DEBUG_SV.C_PROC_LEVEL);
                     END IF;
                     --
                     WSH_WMS_SYNC_TMP_PKG.MERGE_BULK
                       (
                         p_sync_tmp_recTbl   => l_sync_tmp_wms_recTbl,
                         x_return_status     => l_return_status
                       );
                     --
                     IF l_debug_on THEN
                       wsh_debug_sv.log(l_module_name, 'Return status after the call to WSH_WMS_SYNC_TMP_PKG.MERGE_BULK is ', l_return_status);
                     END IF;
                     --
                     WSH_UTIL_CORE.API_POST_CALL
                       (
                         p_return_status    => l_return_status,
                         x_num_warnings     => l_warn,
                         x_num_errors       => l_num_error,
                         p_raise_error_flag => false
                       );
                     -- deleting the tables right here as they are being used in a loop.
                     l_sync_tmp_wms_recTbl.delivery_detail_id_tbl.delete;
                     l_sync_tmp_wms_recTbl.operation_type_tbl.delete;
                     --
                     IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
                       rollback to before_update;
                       GOTO next_trip;
                     END IF;
                     --
                 --}
                 ELSIF WSH_WMS_LPN_GRP.GK_INV_UPD_GRP
                 AND l_sync_tmp_inv_recTbl.delivery_detail_id_tbl.count > 0
                 THEN
                 --{
                     --
                     -- Debug Statements
                     --
                     IF l_debug_on THEN
                         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WMS_SYNC_TMP_PKG.MERGE_BULK',WSH_DEBUG_SV.C_PROC_LEVEL);
                     END IF;
                     --
                     WSH_WMS_SYNC_TMP_PKG.MERGE_BULK
                       (
                         p_sync_tmp_recTbl   => l_sync_tmp_inv_recTbl,
                         x_return_status     => l_return_status
                       );

                     --
                     IF l_debug_on THEN
                       wsh_debug_sv.log(l_module_name, 'Return status after the call to WSH_WMS_SYNC_TMP_PKG.MERGE_BULK is ', l_return_status);
                     END IF;
                     --
                     WSH_UTIL_CORE.API_POST_CALL
                       (
                         p_return_status    => l_return_status,
                         x_num_warnings     => l_warn,
                         x_num_errors       => l_num_error,
                         p_raise_error_flag => false
                       );
                     -- deleting the tables right here as they are being used in a loop.
                     l_sync_tmp_inv_recTbl.delivery_detail_id_tbl.delete;
                     l_sync_tmp_inv_recTbl.operation_type_tbl.delete;
                     --
                     IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
                       rollback to before_update;
                       GOTO next_trip;
                     END IF;
                     --
                 --}
                 END IF;
                 --
             --}
             END IF;
             -- LPN CONV. rv

             --update details
             IF l_tmp_detail_ids is not null and l_tmp_detail_ids.COUNT>0 THEN
                FORALL i in l_tmp_detail_ids.FIRST..l_tmp_detail_ids.LAST
                   UPDATE wsh_delivery_details
                   SET ignore_for_planning   = l_ignoreplan,
                       last_update_date      = sysdate,
                       last_updated_by       = FND_GLOBAL.USER_ID
                   WHERE delivery_detail_id=l_tmp_detail_ids(i);
                IF (SQL%NOTFOUND) THEN
                  rollback to before_update;
                  FND_MESSAGE.SET_NAME('WSH','WSH_IGNOREPLAN_UPDATE_ERROR');
                  l_entity := FND_MESSAGE.GET_STRING('WSH','WSH_ENTITY_TRIP');
                  FND_MESSAGE.SET_TOKEN('ENTITY',l_entity);
                  FND_MESSAGE.SET_TOKEN('NAME',wsh_trips_pvt.get_name(p_in_ids(i)));
                  wsh_util_core.add_message(WSH_UTIL_CORE.g_ret_sts_error,l_module_name);
                  l_num_error:=l_num_error+1;
                  GOTO next_trip;
                END IF;
                Check_Shipset_Ignoreflag( p_delivery_detail_ids=>l_tmp_detail_ids,
                            p_ignore_for_planning=>l_ignoreplan,
                            p_logexcep=>false,
                            x_return_status=>l_return_status );
                IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                  l_warn:=l_warn+1;
                END IF;
                IF l_return_status =  WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
                  raise OTHERS;
                END IF;
             END IF;

             --update dels
             IF l_tmp_del_ids is not null and l_tmp_del_ids.COUNT>0 THEN
                FORALL i in l_tmp_del_ids.FIRST..l_tmp_del_ids.LAST
                   UPDATE wsh_new_deliveries
                   SET ignore_for_planning   = l_ignoreplan,
                       last_update_date      = sysdate,
                       last_updated_by       = FND_GLOBAL.USER_ID
                   WHERE delivery_id=l_tmp_del_ids(i);

                IF (SQL%NOTFOUND) THEN
                  rollback to before_update;
                  FND_MESSAGE.SET_NAME('WSH','WSH_IGNOREPLAN_UPDATE_ERROR');
                  l_entity := FND_MESSAGE.GET_STRING('WSH','WSH_ENTITY_TRIP');
                  FND_MESSAGE.SET_TOKEN('ENTITY',l_entity);
                  FND_MESSAGE.SET_TOKEN('NAME',wsh_trips_pvt.get_name(p_in_ids(i)));
                  wsh_util_core.add_message(WSH_UTIL_CORE.g_ret_sts_error,l_module_name);
                  l_num_error:=l_num_error+1;
                  GOTO next_trip;
                ELSE --Added for bug 7611042 .More than zero rows updated. So calling the API to update the hash string
                  FOR i in l_tmp_del_ids.FIRST..l_tmp_del_ids.LAST LOOP
                    --{
                       --
                          IF l_debug_on THEN
                              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.TABLE_TO_RECORD',WSH_DEBUG_SV.C_PROC_LEVEL);
                          END IF;
                       --
                          WSH_NEW_DELIVERIES_PVT.TABLE_TO_RECORD(p_delivery_id => l_tmp_del_ids(i),
                                                                 x_delivery_rec => l_delivery_info,
                                                                 x_return_status => l_return_status);
                       --
                          IF l_debug_on THEN
                             wsh_debug_sv.log(l_module_name,'Return Status After Calling table_to_record ',l_return_status);
                          END IF;
                       --
                          IF l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                             rollback to before_update;
                             FND_MESSAGE.SET_NAME('WSH','WSH_IGNOREPLAN_UPDATE_ERROR');
                             l_entity := FND_MESSAGE.GET_STRING('WSH','WSH_ENTITY_TRIP');
                             FND_MESSAGE.SET_TOKEN('ENTITY',l_entity);
                             FND_MESSAGE.SET_TOKEN('NAME',wsh_trips_pvt.get_name(p_in_ids(i)));
                             wsh_util_core.add_message(WSH_UTIL_CORE.g_ret_sts_error,l_module_name);
                             l_num_error:=l_num_error+1;
                             goto next_trip;
                          END IF;
                       --
                          IF l_debug_on THEN
                              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_AUTOCREATE.CREATE_UPDATE_HASH',WSH_DEBUG_SV.C_PROC_LEVEL);
                          END IF;
                       --
                          WSH_DELIVERY_AUTOCREATE.CREATE_UPDATE_HASH(p_delivery_rec => l_delivery_info,
                                                                     x_return_status => l_return_status);
                       --
                          IF l_debug_on THEN
                             wsh_debug_sv.log(l_module_name,'Return Status After Calling create_update_hash ',l_return_status);
                          END IF;
                       --
                          IF l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                             rollback to before_update;
                             FND_MESSAGE.SET_NAME('WSH','WSH_IGNOREPLAN_UPDATE_ERROR');
                             l_entity := FND_MESSAGE.GET_STRING('WSH','WSH_ENTITY_TRIP');
                             FND_MESSAGE.SET_TOKEN('ENTITY',l_entity);
                             FND_MESSAGE.SET_TOKEN('NAME',wsh_trips_pvt.get_name(p_in_ids(i)));
                             wsh_util_core.add_message(WSH_UTIL_CORE.g_ret_sts_error,l_module_name);
                             l_num_error:=l_num_error+1;
                             goto next_trip;
                          END IF;
                       --
                          IF l_debug_on THEN
                              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.UPDATE_DELIVERY',WSH_DEBUG_SV.C_PROC_LEVEL);
                          END IF;
                       --
                          WSH_NEW_DELIVERIES_PVT.UPDATE_DELIVERY( p_rowid => NULL,
                                                                  p_delivery_info	=> l_delivery_info,
                                                                  x_return_status => l_return_status);
                       --
                          IF l_debug_on THEN
                             wsh_debug_sv.log(l_module_name,'Return Status After Calling update_delivery ',l_return_status);
                          END IF;
                       --
                          IF l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                             rollback to before_update;
                             FND_MESSAGE.SET_NAME('WSH','WSH_IGNOREPLAN_UPDATE_ERROR');
                             l_entity := FND_MESSAGE.GET_STRING('WSH','WSH_ENTITY_TRIP');
                             FND_MESSAGE.SET_TOKEN('ENTITY',l_entity);
                             FND_MESSAGE.SET_TOKEN('NAME',wsh_trips_pvt.get_name(p_in_ids(i)));
                             wsh_util_core.add_message(WSH_UTIL_CORE.g_ret_sts_error,l_module_name);
                             l_num_error:=l_num_error+1;
                             goto next_trip;
                          END IF;
                    --}
                  END LOOP;
                END IF;

             END IF;

             -- OTM R12, glog proj
             IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'Gc3 Installed:',l_gc3_is_installed);
               WSH_DEBUG_SV.log(l_module_name,'Ignore :',l_ignoreplan);
             END IF;

             -- MDC Changes, Updating Trip tp_plan_name when it is set to
             -- Ignore for Planning
             IF (l_gc3_is_installed = 'Y' AND l_ignoreplan = 'Y') THEN
               l_tp_plan_name_update := 'Y';
             ELSE
               l_tp_plan_name_update := 'N';
             END IF;

             IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'Tp Plan Name Update',l_tp_plan_name_update);
             END IF;

             --update trips
             -- OTM R12, glog proj, check the condition first and then update
             IF l_tp_plan_name_update = 'Y' THEN
               UPDATE wsh_trips
                  SET ignore_for_planning   = l_ignoreplan,
                      tp_plan_name          = NULL, -- OTM R12, glog proj
                      last_update_date      = sysdate,
                      last_updated_by       = FND_GLOBAL.USER_ID,
                      last_update_login     = FND_GLOBAL.LOGIN_ID -- OTM R12, glog proj
                WHERE trip_id=p_in_ids(i);

             ELSE -- l_tp_plan_name_update is null or N, do not update tp_plan_name
               UPDATE wsh_trips
                  SET ignore_for_planning   = l_ignoreplan,
                      last_update_date      = sysdate,
                      last_updated_by       = FND_GLOBAL.USER_ID,
                      last_update_login     = FND_GLOBAL.LOGIN_ID -- OTM R12, glog proj
                WHERE trip_id=p_in_ids(i);
             END IF;
             -- end of OTM R12, glog proj
             --

             IF (SQL%NOTFOUND) THEN
                  rollback to before_update;
                  FND_MESSAGE.SET_NAME('WSH','WSH_IGNOREPLAN_UPDATE_ERROR');
                  l_entity := FND_MESSAGE.GET_STRING('WSH','WSH_ENTITY_TRIP');
                  FND_MESSAGE.SET_TOKEN('ENTITY',l_entity);
                  FND_MESSAGE.SET_TOKEN('NAME',wsh_trips_pvt.get_name(p_in_ids(i)));
                  wsh_util_core.add_message(WSH_UTIL_CORE.g_ret_sts_error,l_module_name);
                  l_num_error:=l_num_error+1;
             END IF;

             <<next_trip>>
             null;
          END LOOP;

          --if all trips have problem show as error
          IF l_num_error>0 AND l_num_error=p_in_ids.COUNT THEN
             FND_MESSAGE.SET_NAME('WSH','WSH_ALL_IGNORE_PLAN_ERROR');
             l_entity := FND_MESSAGE.GET_STRING('WSH','WSH_ENTITY_TRIP');
             FND_MESSAGE.SET_TOKEN('ENTITY',l_entity);
             wsh_util_core.add_message(WSH_UTIL_CORE.g_ret_sts_error,l_module_name);
             x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
             IF l_debug_on THEN
                WSH_DEBUG_SV.pop(l_module_name);
             END IF;
             RETURN;
          ELSIF l_num_error>0 THEN
             x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
          END IF;

        elsif p_entity='DLVY' then

          -- LPN CONV. rv
          l_cnt_wms_counter := 1;
          l_cnt_inv_counter := 1;
          -- LPN CONV. rv
          FOR i in 1..p_in_ids.COUNT LOOP
               l_tmp_detail_ids.delete;

               --1. check if trip the del is assigned to has diff ignore_plan value or is firm
               FOR cur IN c_get_del_ignoreflag_difftrip(p_in_ids(i), l_ignoreplan) LOOP
                  FND_MESSAGE.SET_NAME('WSH','WSH_IGNORE_PLAN_ERROR');
                  FND_MESSAGE.SET_TOKEN('DEL_NAME',cur.delivery_name);
                  FND_MESSAGE.SET_TOKEN('TRIP_NAME',cur.trip_name);
                  wsh_util_core.add_message(WSH_UTIL_CORE.g_ret_sts_error,l_module_name);
                  l_num_error:=l_num_error+1;
                  GOTO next_del;
               END LOOP;

               --2. add check to see if del is TPW or CMS if action is 'INCLUDE_PLAN'
               -- LPN CONV. rv
               -- moved the if condition inside the loop
               FOR cur IN c_get_del_org(p_in_ids(i)) LOOP
                 --
                 IF l_ignoreplan='N' THEN
                   l_wh_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type
                                                    (p_organization_id => cur.organization_id,
                                                     x_return_status   => l_return_status,
                                                     p_delivery_id     => p_in_ids(i),
                                                     p_msg_display   => 'N');


                   IF (nvl(l_wh_type, FND_API.G_MISS_CHAR) IN ('TPW','CMS')) THEN
                      IF l_debug_on THEN
                          WSH_DEBUG_SV.log(l_module_name,'Get_Warehouse_Type cur.organization_id,l_wh_type,l_return_status',cur.organization_id||l_wh_type||l_return_status);
                      END IF;

                      FND_MESSAGE.SET_NAME('WSH','WSH_IGNORE_PLAN_TPW_ERROR');
                      FND_MESSAGE.SET_TOKEN('DEL_NAME',cur.delivery_name);
                      wsh_util_core.add_message(WSH_UTIL_CORE.g_ret_sts_error,l_module_name);
                      l_num_error:=l_num_error+1;
                      GOTO next_del;
                   END IF;
                   IF cur.delivery_type = 'CONSOLIDATION' THEN
                      FND_MESSAGE.SET_NAME('WSH','WSH_IGNORE_PLAN_MDC_ERROR');
                      FND_MESSAGE.SET_TOKEN('DEL_NAME',cur.delivery_name);
                      wsh_util_core.add_message(WSH_UTIL_CORE.g_ret_sts_error,l_module_name);
                      l_num_error:=l_num_error+1;
                      GOTO next_del;
                   END IF;
                 END IF;
               END LOOP;

               FOR l_det_cur IN c_get_lines(p_in_ids(i)) LOOP
                  --
                  -- 5746444: disable this check when OTM is not installed
                  --
                  IF l_ignoreplan='N' AND l_det_cur.source_code='WSH'
                     and l_det_cur.container_flag='N'
                     and l_gc3_is_installed = 'N' THEN   -- OTM R12
                     --do not allow lines in thrid party instance to be set to include for planning
                      FND_MESSAGE.SET_NAME('WSH','WSH_IGNORE_PLAN_TPW_ERROR');
                      FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(l_del_cur.delivery_id));
                      wsh_util_core.add_message(WSH_UTIL_CORE.g_ret_sts_error,l_module_name);
                      l_num_error:=l_num_error+1;
                      GOTO next_del;
                  ELSE
                      l_tmp_detail_ids(l_tmp_detail_ids.COUNT+1):=l_det_cur.delivery_detail_id;
                      --
                      -- LPN CONV. rv
                      --
                      IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
                      THEN
                      --{

                          l_wms_org := wsh_util_validate.check_wms_org(l_det_cur.organization_id);
                          --
                          IF(l_wms_org = 'Y' AND l_det_cur.container_flag IN ('Y','C')
                             AND l_det_cur.line_direction in ('O', 'IO')) THEN
                            l_sync_tmp_wms_recTbl.delivery_detail_id_tbl(l_cnt_wms_counter) := l_det_cur.delivery_detail_id;
                            l_sync_tmp_wms_recTbl.operation_type_tbl(l_cnt_wms_counter) := 'UPDATE';
                            l_cnt_wms_counter := l_cnt_wms_counter +1;
                          ELSIF (l_wms_org = 'N' AND l_det_cur.container_flag IN ('Y','C')
                                 AND l_det_cur.line_direction in ('O', 'IO')) THEN
                            l_sync_tmp_inv_recTbl.delivery_detail_id_tbl(l_cnt_inv_counter) := l_det_cur.delivery_detail_id;
                            l_sync_tmp_inv_recTbl.operation_type_tbl(l_cnt_inv_counter) := 'UPDATE';
                            l_cnt_inv_counter := l_cnt_inv_counter +1;
                          END IF;
                          --
                      --}
                      END IF;
                      -- LPN CONV. rv
                      --
                  END IF;
               END LOOP;

               SAVEPOINT before_update;
               --
               -- LPN CONV. rv
               --
               IF l_debug_on THEN
                 wsh_debug_sv.LOG(l_module_name, 'Count of l_sync_tmp_wms_recTbl', l_sync_tmp_wms_recTbl.delivery_detail_id_tbl.count);
                 wsh_debug_sv.LOG(l_module_name, 'Count of l_sync_tmp_inv_recTbl', l_sync_tmp_inv_recTbl.delivery_detail_id_tbl.count);
               END IF;
               --
               --
               IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
               THEN
               --{
                   IF  WSH_WMS_LPN_GRP.GK_WMS_UPD_GRP
                   AND l_sync_tmp_wms_recTbl.delivery_detail_id_tbl.count > 0
                   THEN
                   --{
                       --
                       -- Debug Statements
                       --
                       IF l_debug_on THEN
                           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WMS_SYNC_TMP_PKG.MERGE_BULK',WSH_DEBUG_SV.C_PROC_LEVEL);
                       END IF;
                       --
                       WSH_WMS_SYNC_TMP_PKG.MERGE_BULK
                         (
                           p_sync_tmp_recTbl   => l_sync_tmp_wms_recTbl,
                           x_return_status     => l_return_status
                         );
                       --
                       IF l_debug_on THEN
                         wsh_debug_sv.log(l_module_name, 'Return status after the call to WSH_WMS_SYNC_TMP_PKG.MERGE_BULK is ', l_return_status);
                       END IF;
                       --
                       WSH_UTIL_CORE.API_POST_CALL
                         (
                           p_return_status    => l_return_status,
                           x_num_warnings     => l_warn,
                           x_num_errors       => l_num_error,
                           p_raise_error_flag => false
                         );
                       -- deleting the tables right here as they are being used in a loop.
                       l_sync_tmp_wms_recTbl.delivery_detail_id_tbl.delete;
                       l_sync_tmp_wms_recTbl.operation_type_tbl.delete;
                       --
                       IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
                         ROLLBACK to before_update;
                         GOTO next_del;
                       END IF;
                       --
                   --}
                   ELSIF WSH_WMS_LPN_GRP.GK_INV_UPD_GRP
                   AND l_sync_tmp_inv_recTbl.delivery_detail_id_tbl.count > 0
                   THEN
                   --{
                       --
                       -- Debug Statements
                       --
                       IF l_debug_on THEN
                           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WMS_SYNC_TMP_PKG.MERGE_BULK',WSH_DEBUG_SV.C_PROC_LEVEL);
                       END IF;
                       --
                       WSH_WMS_SYNC_TMP_PKG.MERGE_BULK
                         (
                           p_sync_tmp_recTbl   => l_sync_tmp_inv_recTbl,
                           x_return_status     => l_return_status
                         );

                       --
                       IF l_debug_on THEN
                         wsh_debug_sv.log(l_module_name, 'Return status after the call to WSH_WMS_SYNC_TMP_PKG.MERGE_BULK is ', l_return_status);
                       END IF;
                       --
                       WSH_UTIL_CORE.API_POST_CALL
                         (
                           p_return_status    => l_return_status,
                           x_num_warnings     => l_warn,
                           x_num_errors       => l_num_error,
                           p_raise_error_flag => false
                         );
                       -- deleting the tables right here as they are being used in a loop.
                       l_sync_tmp_inv_recTbl.delivery_detail_id_tbl.delete;
                       l_sync_tmp_inv_recTbl.operation_type_tbl.delete;
                       --
                       IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
                         ROLLBACK to before_update;
                         GOTO next_del;
                       END IF;
                       --
                   --}
                   END IF;
               --}
               END IF;
               -- LPN CONV. rv

               --update details
	       -- bug 6369687: While Ship Confirming with 'Backorder All', ignore_for_planning for Delivery Detail should not be set to 'Y'.
               IF l_debug_on THEN
	         WSH_DEBUG_SV.log(l_module_name,'WSH_DELIVERIES_GRP.G_ACTION',WSH_DELIVERIES_GRP.G_ACTION);
	       END IF;
               IF NVL(WSH_DELIVERIES_GRP.G_ACTION,'UPDATE') <> 'CONFIRM' THEN
                 IF l_tmp_detail_ids is not null and l_tmp_detail_ids.COUNT>0 THEN
                  FORALL i in l_tmp_detail_ids.FIRST..l_tmp_detail_ids.LAST
                     UPDATE wsh_delivery_details
                     SET ignore_for_planning   = l_ignoreplan,
                         last_update_date      = sysdate,
                         last_updated_by       = FND_GLOBAL.USER_ID
                     WHERE delivery_detail_id=l_tmp_detail_ids(i);
                  IF (SQL%NOTFOUND) THEN
                    ROLLBACK to before_update;
                    FND_MESSAGE.SET_NAME('WSH','WSH_IGNOREPLAN_UPDATE_ERROR');
                    l_entity := FND_MESSAGE.GET_STRING('WSH','WSH_DELIVERY');
                    FND_MESSAGE.SET_TOKEN('ENTITY',l_entity);
                    FND_MESSAGE.SET_TOKEN('NAME',wsh_new_deliveries_pvt.get_name(p_in_ids(i)));
                    wsh_util_core.add_message(WSH_UTIL_CORE.g_ret_sts_error,l_module_name);
                    l_num_error:=l_num_error+1;
                    GOTO next_del;
                  END IF;
                  Check_Shipset_Ignoreflag( p_delivery_detail_ids=>l_tmp_detail_ids,
                              p_ignore_for_planning=>l_ignoreplan,
                              p_logexcep=>false,
                              x_return_status=>l_return_status );
                  IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                    l_warn:=l_warn+1;
                  END IF;
                  IF l_return_status =  WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
                    raise OTHERS;
                  END IF;
                 END IF;
	       END IF;
	       WSH_DELIVERIES_GRP.G_ACTION := NULL;

               -- OTM R12, glog proj
               IF l_gc3_is_installed = 'Y' THEN--{
                 -- initialize the variables, tables
                 l_delivery_info_tab.DELETE;
                 --l_new_interface_flag_tab.DELETE;
                 --l_new_version_number_tab.delete;
                 l_tms_update          := 'Y';
                 l_is_delivery_empty   := NULL;

                 WSH_DELIVERY_VALIDATIONS.get_delivery_information
                   (p_delivery_id   => p_in_ids(i),
                    x_delivery_rec  => l_delivery_info,
                    x_return_status => l_return_status);

                 IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'Return Status',l_return_status);
                 END IF;

                 IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR,
                                         WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
                   ROLLBACK to before_update;
                   l_num_error := l_num_error + 1;
                   GOTO next_del;
                 ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                   l_warn:=l_warn+1;
                 END IF;

                 l_delivery_info_tab(1) := l_delivery_info;

                 IF (l_ignoreplan = 'N') THEN--{
                   l_is_delivery_empty := WSH_NEW_DELIVERY_ACTIONS.IS_DELIVERY_EMPTY(p_in_ids(i));

                   IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name,'Is Delivery Empty',l_is_delivery_empty);
                   END IF;
                   IF (l_is_delivery_empty = 'E') THEN
                     ROLLBACK to before_update;
                     l_num_error := l_num_error + 1;
                     GOTO next_del;
                   END IF;

                   IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name,'Delivery Tms_interface_flag',l_delivery_info.tms_interface_flag);
                   END IF;

                   IF (nvl(l_delivery_info.tms_interface_flag,
                           WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT) =
                             WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT
                      AND l_is_delivery_empty = 'N') THEN--{
                     l_new_interface_flag_tab(1) :=  WSH_NEW_DELIVERIES_PVT.C_TMS_CREATE_REQUIRED;
                     l_new_version_number_tab(1) :=
                       nvl(l_delivery_info.tms_version_number, 1) + 1;
                   ELSIF
                     ((nvl(l_delivery_info.tms_interface_flag,
                           WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT)
                      IN (WSH_NEW_DELIVERIES_PVT.C_TMS_DELETE_REQUIRED,
                          WSH_NEW_DELIVERIES_PVT.C_TMS_DELETE_IN_PROCESS))
                      AND l_is_delivery_empty = 'N') THEN
                     l_new_interface_flag_tab(1) := WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_REQUIRED;
                     l_new_version_number_tab(1) :=
                       nvl(l_delivery_info.tms_version_number, 1) + 1;
                   ELSE
                     l_tms_update := 'N';
                   END IF;--}
                 ELSIF (l_ignoreplan = 'Y') THEN--} {

                   IF (nvl(l_delivery_info.tms_interface_flag,
                       WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT) IN
                       (WSH_NEW_DELIVERIES_PVT.C_TMS_CREATE_IN_PROCESS,
                        WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_REQUIRED,
                        WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_IN_PROCESS,
                        WSH_NEW_DELIVERIES_PVT.C_TMS_AWAITING_ANSWER,
                        WSH_NEW_DELIVERIES_PVT.C_TMS_ANSWER_RECEIVED)) THEN
                     l_new_interface_flag_tab(1) := WSH_NEW_DELIVERIES_PVT.C_TMS_DELETE_REQUIRED;
                     l_new_version_number_tab(1) :=
                       nvl(l_delivery_info.tms_version_number, 1) + 1;
                   ELSIF (nvl(l_delivery_info.tms_interface_flag,
                          WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT) =
                         (WSH_NEW_DELIVERIES_PVT.C_TMS_CREATE_REQUIRED)) THEN
                     l_new_interface_flag_tab(1) := WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT;
                     l_new_version_number_tab(1) :=
                       nvl(l_delivery_info.tms_version_number, 1);
                   ELSE
                     l_tms_update := 'N';
                   END IF;
                 END IF;--}

                 IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'l_tms_update',l_tms_update);
                 END IF;

                 -- have to call wms to check if deliveries being updated
                 -- are assigned to a trip being loaded
                 IF (wsh_util_validate.Check_Wms_Org(l_delivery_info.organization_id)='Y'
                    AND l_ignoreplan = 'N') THEN--{
                   l_del_trip_tab.delete;
                   l_temp := NULL;
                   l_del_trip_tab(1).delivery_id := p_in_ids(i);

                   --check delivery's current ignore for planning flag
                   IF (l_delivery_info.ignore_for_planning = 'Y') THEN--{
                     IF l_debug_on THEN
                       WSH_DEBUG_SV.logmsg(l_module_name,
                                       'Calling program unit WMS_SHIPPING_INTERFACE_GRP.PROCESS_DELIVERIES',
                                       WSH_DEBUG_SV.C_PROC_LEVEL);
                     END IF;

                     WMS_SHIPPING_INTERFACE_GRP.process_deliveries(
                       p_api_version     => 1.0,
                       p_init_msg_list   => wms_shipping_interface_grp.g_false,
                       p_commit          => wms_shipping_interface_grp.g_false,
                       p_validation_level=> wms_shipping_interface_grp.g_full_validation,
                       p_action          => wms_shipping_interface_grp.g_action_plan_delivery,
                       x_dlvy_trip_tbl   => l_del_trip_tab,
                       x_return_status   => l_return_status,
                       x_msg_count       => l_msg_count,
                       x_msg_data        => l_msg_data);

                     IF l_debug_on THEN
                       WSH_DEBUG_SV.log(l_module_name,'Return Status after WMS API Call',l_return_status);
                       WSH_DEBUG_SV.log(l_module_name,'Message Code',l_del_trip_tab(l_del_trip_tab.LAST).r_message_code);
                     END IF;

                     IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR,
                           WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
                       ROLLBACK to before_update;
                       l_num_error := l_num_error + 1;
                       GOTO next_del;
                     ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                       l_warn:=l_warn+1;
                     END IF;

                     l_temp := l_del_trip_tab.LAST;
                     IF (l_del_trip_tab(l_temp).r_message_code = 'WMS_DELIVERY_LOADED_TO_DOCK')
                     THEN--{
                       ROLLBACK to before_update;
                       FND_MESSAGE.SET_NAME(l_del_trip_tab(l_temp).r_message_appl,
                       l_del_trip_tab(l_temp).r_message_code);
                       FND_MESSAGE.SET_TOKEN(l_del_trip_tab(l_temp).r_message_token_name,
                       l_del_trip_tab(l_temp).r_message_token);
                       wsh_util_core.add_message(l_del_trip_tab(l_temp).r_message_type, l_module_name);
                       l_num_error:=l_num_error+1;
                       GOTO next_del;
                     END IF;  --}
                   END IF;--}
                 END IF;--}
               END IF;--}
               -- end of OTM R12, glog proj

               --update dels
               UPDATE wsh_new_deliveries
               SET ignore_for_planning   = l_ignoreplan,
                   -- OTM R12, glog proj, based on the l_tms_update flag set above
                   tms_interface_flag    = DECODE(l_tms_update,
                                           'Y', l_new_interface_flag_tab(1),
                                           tms_interface_flag),
                   tms_version_number    = DECODE(l_tms_update,
                                           'Y', l_new_version_number_tab(1),
                                           tms_version_number),
                   last_update_date      = sysdate,
                   last_updated_by       = FND_GLOBAL.USER_ID,
                   last_update_login     = FND_GLOBAL.LOGIN_ID -- OTM R12, glog proj
               WHERE delivery_id=p_in_ids(i);

               IF (SQL%NOTFOUND) THEN
                 ROLLBACK to before_update;
                 FND_MESSAGE.SET_NAME('WSH','WSH_IGNOREPLAN_UPDATE_ERROR');
                 l_entity := FND_MESSAGE.GET_STRING('WSH','WSH_DELIVERY');
                 FND_MESSAGE.SET_TOKEN('ENTITY',l_entity);
                 FND_MESSAGE.SET_TOKEN('NAME',wsh_new_deliveries_pvt.get_name(p_in_ids(i)));
                 wsh_util_core.add_message(WSH_UTIL_CORE.g_ret_sts_error,l_module_name);
                 l_num_error:=l_num_error+1;
                  goto next_del;
               ELSE --Added for bug 7611042 .More than zero rows updated. So calling the API to update the hash string
                    --{
                       --
                          IF l_debug_on THEN
                              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.TABLE_TO_RECORD',WSH_DEBUG_SV.C_PROC_LEVEL);
                          END IF;
                       --
                          WSH_NEW_DELIVERIES_PVT.TABLE_TO_RECORD(p_delivery_id => p_in_ids(i),
                                                                 x_delivery_rec => l_delivery_info,
                                                                 x_return_status => l_return_status);
                       --
                          IF l_debug_on THEN
                             wsh_debug_sv.log(l_module_name,'Return Status After Calling table_to_record ',l_return_status);
                          END IF;
                       --
                          IF l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                             rollback to before_update;
                             FND_MESSAGE.SET_NAME('WSH','WSH_IGNOREPLAN_UPDATE_ERROR');
                             l_entity := FND_MESSAGE.GET_STRING('WSH','WSH_DELIVERY');
                             FND_MESSAGE.SET_TOKEN('ENTITY',l_entity);
                             FND_MESSAGE.SET_TOKEN('NAME',wsh_new_deliveries_pvt.get_name(p_in_ids(i)));
                             wsh_util_core.add_message(WSH_UTIL_CORE.g_ret_sts_error,l_module_name);
                             l_num_error:=l_num_error+1;
                             goto next_del;
                          END IF;
                       --
                          IF l_debug_on THEN
                              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_AUTOCREATE.CREATE_UPDATE_HASH',WSH_DEBUG_SV.C_PROC_LEVEL);
                          END IF;
                       --
                          WSH_DELIVERY_AUTOCREATE.CREATE_UPDATE_HASH(p_delivery_rec => l_delivery_info,
                                                                     x_return_status => l_return_status);
                       --
                          IF l_debug_on THEN
                             wsh_debug_sv.log(l_module_name,'Return Status After Calling create_update_hash ',l_return_status);
                          END IF;
                       --
                          IF l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                             rollback to before_update;
                             FND_MESSAGE.SET_NAME('WSH','WSH_IGNOREPLAN_UPDATE_ERROR');
                             l_entity := FND_MESSAGE.GET_STRING('WSH','WSH_DELIVERY');
                             FND_MESSAGE.SET_TOKEN('ENTITY',l_entity);
                             FND_MESSAGE.SET_TOKEN('NAME',wsh_new_deliveries_pvt.get_name(p_in_ids(i)));
                             wsh_util_core.add_message(WSH_UTIL_CORE.g_ret_sts_error,l_module_name);
                             l_num_error:=l_num_error+1;
                             goto next_del;
                          END IF;
                       --
                          IF l_debug_on THEN
                              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.UPDATE_DELIVERY',WSH_DEBUG_SV.C_PROC_LEVEL);
                          END IF;
                       --
                          WSH_NEW_DELIVERIES_PVT.UPDATE_DELIVERY( p_rowid => NULL,
                                                                  p_delivery_info	=> l_delivery_info,
                                                                  x_return_status => l_return_status);
                       --
                          IF l_debug_on THEN
                             wsh_debug_sv.log(l_module_name,'Return Status After Calling update_delivery ',l_return_status);
                          END IF;
                       --
                          IF l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                             rollback to before_update;
                             FND_MESSAGE.SET_NAME('WSH','WSH_IGNOREPLAN_UPDATE_ERROR');
                             l_entity := FND_MESSAGE.GET_STRING('WSH','WSH_DELIVERY');
                             FND_MESSAGE.SET_TOKEN('ENTITY',l_entity);
                             FND_MESSAGE.SET_TOKEN('NAME',wsh_new_deliveries_pvt.get_name(p_in_ids(i)));
                             wsh_util_core.add_message(WSH_UTIL_CORE.g_ret_sts_error,l_module_name);
                             l_num_error:=l_num_error+1;
                             goto next_del;
                          END IF;
                    --}
               END IF;

               -- OTM R12, glog proj
               IF (l_gc3_is_installed = 'Y'
                   AND l_new_interface_flag_tab.COUNT > 0) THEN--{

                 IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,
                                       'Calling program unit WSH_XC_UTIL.LOG_OTM_EXCEPTION',
                                       WSH_DEBUG_SV.C_PROC_LEVEL);
                 END IF;

                 WSH_XC_UTIL.log_otm_exception(
                   p_delivery_info_tab      => l_delivery_info_tab,
                   p_new_interface_flag_tab => l_new_interface_flag_tab,
                   x_return_status          => l_return_status);

                 IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'Return Status after log_otm_exception',l_return_status);
                 END IF;

                 IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR,
                                         WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
                   ROLLBACK to before_update;
                   l_num_error := l_num_error + 1;
                   GOTO next_del;
                 ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                   l_warn := l_warn + 1;
                 END IF;

               END IF;--}
               -- end of OTM R12, glog proj

            <<next_del>>
            null;
          END LOOP;

          --if all dels have problem show as error
          IF l_num_error>0 AND l_num_error=p_in_ids.COUNT THEN
             FND_MESSAGE.SET_NAME('WSH','WSH_ALL_IGNORE_PLAN_ERROR');
             l_entity := FND_MESSAGE.GET_STRING('WSH','WSH_DELIVERY');
             FND_MESSAGE.SET_TOKEN('ENTITY',l_entity);
             wsh_util_core.add_message(WSH_UTIL_CORE.g_ret_sts_error,l_module_name);
             x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
             IF l_debug_on THEN
                WSH_DEBUG_SV.pop(l_module_name);
             END IF;
             RETURN;
          ELSIF l_num_error>0 THEN
             x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
          END IF;


        else
          --p_entity='DLVB'  (only 3 values for p_entity)

            FOR i in 1..p_in_ids.COUNT LOOP
             --1. check if del the detail is assigned to has diff ignore_plan value or the del is planned/firm
             FOR cur IN c_get_det_ignoreflag_diff_del(p_in_ids(i), l_ignoreplan) LOOP
                 FND_MESSAGE.SET_NAME('WSH','WSH_IGNORE_PLAN_ERROR_DETAIL');
                 FND_MESSAGE.SET_TOKEN('DET_ID',p_in_ids(i));
                 FND_MESSAGE.SET_TOKEN('DEL_NAME',cur.delivery_name);
                 wsh_util_core.add_message(WSH_UTIL_CORE.g_ret_sts_error,l_module_name);
                 l_num_error:=l_num_error+1;
                 GOTO next_det;
             END LOOP;

             --2. add check to see if detail is TPW or CMS if action is 'INCLUDE_PLAN'
             IF l_ignoreplan='N' THEN
               FOR cur IN c_get_det_org(p_in_ids(i)) LOOP
                   l_wh_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type
                                                 (p_organization_id => cur.organization_id,
                                                  x_return_status   => l_return_status,
                                                  p_delivery_detail_id    => p_in_ids(i),
                                                  p_msg_display   => 'N');

                   -- 5746444: disable this condition when OTM is installed
                   IF (nvl(l_wh_type, FND_API.G_MISS_CHAR) IN ('TPW','CMS'))
                      OR (cur.source_code='WSH' and cur.container_flag='N'
                          and l_gc3_is_installed = 'N' )
                   THEN
                      IF l_debug_on THEN
                           WSH_DEBUG_SV.log(l_module_name,'Get_Warehouse_Type cur.organization_id,l_wh_type,l_return_status',cur.organization_id||l_wh_type||l_return_status);
                           WSH_DEBUG_SV.log(l_module_name,'source_code, container_flag',cur.source_code||cur.container_flag);
                      END IF;

                      FND_MESSAGE.SET_NAME('WSH','WSH_IGNORE_PLAN_DETTPW_ERROR');
                      FND_MESSAGE.SET_TOKEN('DET_ID',p_in_ids(i));
                      wsh_util_core.add_message(WSH_UTIL_CORE.g_ret_sts_error,l_module_name);
                      l_num_error:=l_num_error+1;
                      GOTO next_det;
                   END IF;

               END LOOP;
             END IF;

             --3. check if line is assigned to a container. if so, user has to perform from topmost entity
             FOR cur IN c_get_det_ignoreflag_diff_cont(p_in_ids(i), l_ignoreplan) LOOP
                 FND_MESSAGE.SET_NAME('WSH','WSH_IGNOREPLAN_DET_ASSN_CONT');
                 FND_MESSAGE.SET_TOKEN('DET_ID',p_in_ids(i));
                 wsh_util_core.add_message(WSH_UTIL_CORE.g_ret_sts_error,l_module_name);
                 l_num_error:=l_num_error+1;
                 GOTO next_det;
             END LOOP;

             SAVEPOINT before_update;
             l_is_container :='N';
             FOR cur in c_get_container(p_in_ids(i)) LOOP
                 l_is_container   :=cur.container_flag;
                 l_container_name :=cur.container_name;
                 l_cont_org_id    := cur.organization_id;
                 l_cont_line_dir  := cur.organization_id;
             END LOOP;

             --If line is a container, get all lines inside and update them and then update container
             IF l_is_container='Y' THEN
                  --
                  l_tmp_detail_ids.delete;
                  l_tmp_detail_ids(l_tmp_detail_ids.COUNT+1):=p_in_ids(i);
                  FOR l_det_cur IN c_get_cont_lines(p_in_ids(i)) LOOP
                     l_tmp_detail_ids(l_tmp_detail_ids.COUNT+1):=l_det_cur.delivery_detail_id;
                  END LOOP;

                  --update all details in hierarchy
                  IF l_tmp_detail_ids is not null and l_tmp_detail_ids.COUNT>0 THEN
                     FORALL i in l_tmp_detail_ids.FIRST..l_tmp_detail_ids.LAST
                        UPDATE wsh_delivery_details
                        SET ignore_for_planning=l_ignoreplan,
                            last_update_date      = sysdate,
                            last_updated_by       = FND_GLOBAL.USER_ID
                        WHERE delivery_detail_id=l_tmp_detail_ids(i)
                        RETURNING container_flag, organization_id, line_direction bulk collect into l_cont_flag_tbl, l_orgn_id_tbl, l_line_dir_tbl; -- LPN CONV. rv
                     IF (SQL%NOTFOUND) THEN
                       rollback to before_update;
                       FND_MESSAGE.SET_NAME('WSH','WSH_IGNOREPLAN_UPDATE_ERROR');
                       l_entity := FND_MESSAGE.GET_STRING('WSH','WSH_CONTAINER');
                       FND_MESSAGE.SET_TOKEN('ENTITY',l_entity);
                       FND_MESSAGE.SET_TOKEN('NAME',l_container_name);
                       wsh_util_core.add_message(WSH_UTIL_CORE.g_ret_sts_error,l_module_name);
                       l_num_error:=l_num_error+1;
                       GOTO next_det;
                     END IF;

                     -- LPN CONV. rv
                     IF l_cont_flag_tbl.count > 0
                     AND WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
                     THEN
                     --{
                         --
                         l_cnt_wms_counter := 1;
                         l_cnt_inv_counter := 1;
                         --
                         FOR i in l_tmp_detail_ids.FIRST..l_tmp_detail_ids.LAST
                         LOOP
                         --{
                             --
                             -- LPN CONV. rv
                             l_wms_org := wsh_util_validate.check_wms_org(l_orgn_id_tbl(i));
                             -- LPN CONV. rv

                             IF (l_wms_org = 'Y' and l_cont_flag_tbl(i) = 'Y'
                                 and nvl(l_line_dir_tbl(i),'O') in ('O', 'IO')) THEN
                             --{
                                 l_sync_tmp_wms_recTbl.delivery_detail_id_tbl(l_cnt_wms_counter) := l_tmp_detail_ids(i);
                                 l_sync_tmp_wms_recTbl.operation_type_tbl(l_cnt_wms_counter) := 'UPDATE';
                                 l_cnt_wms_counter := l_cnt_wms_counter +1;
                             --}
                             ELSIF (l_wms_org = 'N' and l_cont_flag_tbl(i) = 'Y'
                                    and nvl(l_line_dir_tbl(i),'O') in ('O', 'IO')) THEN
                             --{
                                 l_sync_tmp_inv_recTbl.delivery_detail_id_tbl(l_cnt_inv_counter) := l_tmp_detail_ids(i);
                                 l_sync_tmp_inv_recTbl.operation_type_tbl(l_cnt_inv_counter) := 'UPDATE';
                                 l_cnt_inv_counter := l_cnt_inv_counter +1;

                             --}
                             END IF;
                         --}
                         END LOOP;
                         --
                         --
                         IF l_debug_on THEN
                           wsh_debug_sv.LOG(l_module_name, 'Count of l_sync_tmp_wms_recTbl', l_sync_tmp_wms_recTbl.delivery_detail_id_tbl.count);
                           wsh_debug_sv.LOG(l_module_name, 'Count of l_sync_tmp_inv_recTbl', l_sync_tmp_inv_recTbl.delivery_detail_id_tbl.count);
                         END IF;
                         --
                         --
                         IF  WSH_WMS_LPN_GRP.GK_WMS_UPD_GRP
                         AND l_sync_tmp_wms_recTbl.delivery_detail_id_tbl.count > 0
                         THEN
                         --{
                             --
                             -- Debug Statements
                             --
                             IF l_debug_on THEN
                                 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WMS_SYNC_TMP_PKG.MERGE_BULK',WSH_DEBUG_SV.C_PROC_LEVEL);
                             END IF;
                             --
                             WSH_WMS_SYNC_TMP_PKG.MERGE_BULK
                               (
                                 p_sync_tmp_recTbl   => l_sync_tmp_wms_recTbl,
                                 x_return_status     => l_return_status
                               );
                             --
                             IF l_debug_on THEN
                               wsh_debug_sv.log(l_module_name, 'Return status after the call to WSH_WMS_SYNC_TMP_PKG.MERGE_BULK is ', l_return_status);
                             END IF;
                             --
                             WSH_UTIL_CORE.API_POST_CALL
                               (
                                 p_return_status    => l_return_status,
                                 x_num_warnings     => l_warn,
                                 x_num_errors       => l_num_error,
                                 p_raise_error_flag => false
                               );
                             -- deleting the tables right here as they are being used in a loop.
                             l_sync_tmp_wms_recTbl.delivery_detail_id_tbl.delete;
                             l_sync_tmp_wms_recTbl.operation_type_tbl.delete;
                             --
                             IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
                               GOTO next_det;
                             END IF;
                             --
                         --}
                         ELSIF WSH_WMS_LPN_GRP.GK_INV_UPD_GRP
                         AND l_sync_tmp_inv_recTbl.delivery_detail_id_tbl.count > 0
                         THEN
                         --{
                             --
                             -- Debug Statements
                             --
                             IF l_debug_on THEN
                                 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WMS_SYNC_TMP_PKG.MERGE_BULK',WSH_DEBUG_SV.C_PROC_LEVEL);
                             END IF;
                             --
                             WSH_WMS_SYNC_TMP_PKG.MERGE_BULK
                               (
                                 p_sync_tmp_recTbl   => l_sync_tmp_inv_recTbl,
                                 x_return_status     => l_return_status
                               );

                             --
                             IF l_debug_on THEN
                               wsh_debug_sv.log(l_module_name, 'Return status after the call to WSH_WMS_SYNC_TMP_PKG.MERGE_BULK is ', l_return_status);
                             END IF;
                             --
                             WSH_UTIL_CORE.API_POST_CALL
                               (
                                 p_return_status    => l_return_status,
                                 x_num_warnings     => l_warn,
                                 x_num_errors       => l_num_error,
                                 p_raise_error_flag => false
                               );
                             -- deleting the tables right here as they are being used in a loop.
                             l_sync_tmp_inv_recTbl.delivery_detail_id_tbl.delete;
                             l_sync_tmp_inv_recTbl.operation_type_tbl.delete;
                             --
                             IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
                               GOTO next_det;
                             END IF;
                             --
                         --}
                         END IF;
                         --
                     --}
                     END IF;
                     -- LPN CONV. rv
                     Check_Shipset_Ignoreflag( p_delivery_detail_ids=>l_tmp_detail_ids,
                            p_ignore_for_planning=>l_ignoreplan,
                            p_logexcep=>false,
                            x_return_status=>l_return_status );
                     IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                      l_warn:=l_warn+1;
                    END IF;
                    IF l_return_status =  WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
                      raise OTHERS;
                    END IF;
                  END IF;
             ELSE --not a container

                  UPDATE wsh_delivery_details
                  SET ignore_for_planning   = l_ignoreplan,
                      last_update_date      = sysdate,
                      last_updated_by       = FND_GLOBAL.USER_ID
                  WHERE delivery_detail_id=p_in_ids(i);
                  IF (SQL%NOTFOUND) THEN
                     rollback to before_update;
                     FND_MESSAGE.SET_NAME('WSH','WSH_IGNOREPLAN_UPDATE_ERROR');
                     l_entity := FND_MESSAGE.GET_STRING('WSH','WSH_ENTITY_LINE');
                     FND_MESSAGE.SET_TOKEN('ENTITY',l_entity);
                     FND_MESSAGE.SET_TOKEN('NAME',p_in_ids(i));
                     wsh_util_core.add_message(WSH_UTIL_CORE.g_ret_sts_error,l_module_name);
                     l_num_error:=l_num_error+1;
                  END IF;
                  Check_Shipset_Ignoreflag( p_delivery_detail_id=>p_in_ids(i),
                            p_ignore_for_planning=>l_ignoreplan,
                            p_logexcep=>false,
                            x_return_status=>l_return_status );
                  IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                    l_warn:=l_warn+1;
                  END IF;
                  IF l_return_status =  WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
                    raise OTHERS;
                  END IF;
             END IF; --container

             <<next_det>>
             null;
            END LOOP;

            --if all details have problem show as error
            IF l_num_error>0 AND l_num_error=p_in_ids.COUNT THEN
               FND_MESSAGE.SET_NAME('WSH','WSH_ALL_IGNORE_PLAN_ERROR');
               l_entity := FND_MESSAGE.GET_STRING('WSH','WSH_ENTITY_LINE');
               FND_MESSAGE.SET_TOKEN('ENTITY',l_entity);
               wsh_util_core.add_message(WSH_UTIL_CORE.g_ret_sts_error,l_module_name);
               x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
               IF l_debug_on THEN
                  WSH_DEBUG_SV.pop(l_module_name);
               END IF;
               RETURN;
            ELSIF l_num_error>0 THEN
               x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
            END IF;
        end if; --entity
        IF l_warn>0 THEN
         FND_MESSAGE.SET_NAME('WSH','WSH_IGNORE_PLAN_WARN');
         wsh_util_core.add_message(WSH_UTIL_CORE.g_ret_sts_warning,l_module_name);
         x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        END IF;

  END IF; --tp_is_installed

  IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        wsh_util_core.default_handler('WSH_TP_RELEASE.change_ignoreplan_status');
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
END change_ignoreplan_status;

-- START
-- PROCEDURE firm_entity
--
-- 1. Making a trip as Routing and Contents Firm will make all associated deliveries to be
--    Routing and Contents Firm as well. In addition, if there are any other trips associated
--    to these deliveries they will become ATLEAST Routing Firm.
-- 2. Making a delivery as Routing and Contents Firm will make all associated trips to become
--    ATLEAST Routing Firm.
-- END

PROCEDURE firm_entity( p_entity        IN VARCHAR2,      --either 'DLVY' or 'TRIP'
                       p_entity_id     IN NUMBER,
                       x_return_status OUT NOCOPY VARCHAR2) IS

CURSOR c_deliveries (c_trip_id NUMBER) IS
SELECT dg.delivery_id
FROM   wsh_trips t,
       wsh_trip_stops st,
       wsh_delivery_legs dg
WHERE  t.trip_id = c_trip_id AND
       st.trip_id = t.trip_id AND
       dg.pick_up_stop_id = st.stop_id;

--for related trips
-- bug 3687559: we only need to look for unfirmed related trips
CURSOR c_trips (c_trip_id NUMBER, c_delid NUMBER) IS
SELECT t.trip_id
FROM   wsh_trips t,
       wsh_trip_stops st,
       wsh_delivery_legs dg
WHERE  t.trip_id <> c_trip_id AND
       st.trip_id = t.trip_id AND
       dg.pick_up_stop_id = st.stop_id AND
       dg.delivery_id=c_delid  AND
       NVL(t.planned_flag, 'N') = 'N';

--for related trips for this delivery, find atleast one delivery which is either planned/unplanned
--trip doesnot have to be firmed for this case. just planned is enough
CURSOR c_find_planunplandeliveries (c_tripid NUMBER, c_delid NUMBER) IS
SELECT dg.delivery_id
FROM   wsh_trips t,
       wsh_trip_stops st,
       wsh_delivery_legs dg,
       wsh_new_deliveries dl
WHERE  t.trip_id = c_tripid AND
       st.trip_id = t.trip_id AND
       dg.pick_up_stop_id = st.stop_id AND
       dg.delivery_id=dl.delivery_id AND
       dl.delivery_id<>c_delid AND
       dl.planned_flag IN ('Y','N') AND
       rownum=1;

/******DLVY*****/
--for related trips
-- Bug 3294663, bug 3687559 need to find trips and their firm status
CURSOR c_dlvy_trips (c_delid NUMBER) IS
SELECT distinct st.trip_id, t.planned_flag
FROM   wsh_trip_stops    st,
       wsh_delivery_legs dg,
       wsh_trips         t
WHERE  dg.pick_up_stop_id = st.stop_id AND
       dg.delivery_id=c_delid          AND
       st.trip_id = t.trip_id;

l_plannedflag      VARCHAR2(1);
l_deliveries_exist VARCHAR2(1);
l_entity           VARCHAR2(2000);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'firm_entity';
--

BEGIN

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;

  IF l_debug_on IS NULL THEN
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
     WSH_DEBUG_SV.push(l_module_name);
     WSH_DEBUG_SV.log(l_module_name,'p_entity',p_entity);
     WSH_DEBUG_SV.log(l_module_name,'p_entity_id',p_entity_id);
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

     SAVEPOINT before_firm;

     IF (p_entity='TRIP') THEN
        FOR del_cur IN c_deliveries(p_entity_id) LOOP

          wsh_delivery_validations.check_plan(p_delivery_id       => del_cur.delivery_id,
                                              x_return_status     => x_return_status);
          IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) OR (x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
              rollback to before_firm;
              FND_MESSAGE.SET_NAME('WSH','WSH_DELIVERY_CANNOT_FIRM');
              FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(del_cur.delivery_id));
              x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
              wsh_util_core.add_message(x_return_status);
              IF l_debug_on THEN
                WSH_DEBUG_SV.pop(l_module_name);
              END IF;
              RETURN;
           END IF;

          l_deliveries_exist:='Y';
          UPDATE wsh_new_deliveries
          SET planned_flag          = c_routing_firm_flag,
              last_update_date      = sysdate,
              last_updated_by       = FND_GLOBAL.USER_ID
          WHERE delivery_id = del_cur.delivery_id;
           --raise error to avoid inconsistency
           IF (SQL%NOTFOUND) THEN
              FND_MESSAGE.SET_NAME('WSH','WSH_FIRM_UPDATE_ERROR');
              l_entity := FND_MESSAGE.GET_STRING('WSH','WSH_DELIVERY');
              FND_MESSAGE.SET_TOKEN('ENTITY',l_entity);
              FND_MESSAGE.SET_TOKEN('NAME',wsh_new_deliveries_pvt.get_name(del_cur.delivery_id));
              x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
              wsh_util_core.add_message(x_return_status);
              IF l_debug_on THEN
                WSH_DEBUG_SV.pop(l_module_name);
              END IF;
              rollback to before_firm;
              RETURN;
           END IF;


          FOR l_trips_cur IN c_trips(p_entity_id,del_cur.delivery_id) LOOP

            wsh_trip_validations.check_plan(p_trip_id       => l_trips_cur.trip_id,
                                            x_return_status => x_return_status);
            IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) OR (x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
              rollback to before_firm;
              FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_CANNOT_FIRM');
              FND_MESSAGE.SET_TOKEN('TRIP_NAME',wsh_trips_pvt.get_name(l_trips_cur.trip_id));
              x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
              wsh_util_core.add_message(x_return_status);
              IF l_debug_on THEN
                WSH_DEBUG_SV.pop(l_module_name);
              END IF;
              RETURN;
            END IF;

            -- bug 3687559: related trips should become RF (not RCF)
            l_plannedflag:='Y';

            UPDATE wsh_trips
            SET planned_flag          = l_plannedflag,
                last_update_date      = sysdate,
                last_updated_by       = FND_GLOBAL.USER_ID
            WHERE trip_id = l_trips_cur.trip_id;
            --return error to avoid inconsistency
            IF (SQL%NOTFOUND) THEN
              FND_MESSAGE.SET_NAME('WSH','WSH_FIRM_UPDATE_ERROR');
              l_entity := FND_MESSAGE.GET_STRING('WSH','WSH_ENTITY_RELATED_TRIP');
              FND_MESSAGE.SET_TOKEN('ENTITY',l_entity);
              FND_MESSAGE.SET_TOKEN('NAME',wsh_trips_pvt.get_name(l_trips_cur.trip_id));
              x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
              wsh_util_core.add_message(x_return_status);
              IF l_debug_on THEN
                WSH_DEBUG_SV.pop(l_module_name);
              END IF;
              rollback to before_firm;
              RETURN;
            END IF;

          END LOOP;
        END LOOP;

        --if l_deliveries_exist is null, no deliveries exist for trip => trip can't be firmed
        IF l_deliveries_exist IS null THEN
           FND_MESSAGE.SET_NAME('WSH','WSH_FIRM_TRIP_ERROR');
           FND_MESSAGE.SET_TOKEN('TRIP_NAME',wsh_trips_pvt.get_name(p_entity_id));
           wsh_util_core.add_message(WSH_UTIL_CORE.g_ret_sts_error,l_module_name);
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           IF l_debug_on THEN
               WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           rollback to before_firm;
           RETURN;
        ELSE
          UPDATE wsh_trips
          SET planned_flag          = c_routing_firm_flag ,
              last_update_date      = sysdate,
              last_updated_by       = FND_GLOBAL.USER_ID
          WHERE trip_id = p_entity_id;
           IF (SQL%NOTFOUND) THEN
              FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_NOT_FOUND');
              x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
              wsh_util_core.add_message(x_return_status);
              IF l_debug_on THEN
                WSH_DEBUG_SV.pop(l_module_name);
              END IF;
              rollback to before_firm;
              RETURN;
           END IF;

        END IF;

      ELSIF (p_entity='DLVY') THEN
        FOR l_trips_cur IN  c_dlvy_trips(p_entity_id) LOOP

          l_plannedflag:='Y';  -- trip is found; if needed, make it RF.

          -- Bug 3687559: making delivery RCF should not upgrade trips to RCF.
          --       If trip is already RF or RCF, there is no need to validate or update it.
          -- Bug 3294663, When upgrading the delivery from NF to RCF, the trip will be upgraded from NF to RF (not RCF).
          -- When upgrading a delivery from CF to RCF, trip should be upgraded from NF to RF.
          -- When upgrading a delivery from NF to RCF, trip should be upgraded from RF to RF.

          IF NVL(l_trips_cur.planned_flag, 'N') = 'N' THEN
            wsh_trip_validations.check_plan(p_trip_id       => l_trips_cur.trip_id,
                                            x_return_status => x_return_status);
            IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) OR (x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                rollback to before_firm;
                FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_CANNOT_FIRM');
                FND_MESSAGE.SET_TOKEN('TRIP_NAME',wsh_trips_pvt.get_name(l_trips_cur.trip_id));
                x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                wsh_util_core.add_message(x_return_status);
                IF l_debug_on THEN
                  WSH_DEBUG_SV.pop(l_module_name);
                END IF;
                RETURN;
            END IF;

            UPDATE wsh_trips
            SET planned_flag          = l_plannedflag,
                last_update_date      = sysdate,
                last_updated_by       = FND_GLOBAL.USER_ID
            WHERE trip_id = l_trips_cur.trip_id;

            --return error to avoid inconsistency
            IF (SQL%NOTFOUND) THEN
                FND_MESSAGE.SET_NAME('WSH','WSH_FIRM_UPDATE_ERROR');
                l_entity := FND_MESSAGE.GET_STRING('WSH','WSH_ENTITY_RELATED_TRIP');
                FND_MESSAGE.SET_TOKEN('ENTITY',l_entity);
                FND_MESSAGE.SET_TOKEN('NAME',wsh_trips_pvt.get_name(l_trips_cur.trip_id));
                x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                wsh_util_core.add_message(x_return_status);
                IF l_debug_on THEN
                  WSH_DEBUG_SV.pop(l_module_name);
                END IF;
                rollback to before_firm;
                RETURN;
            END IF;
          END IF;

        END LOOP;

        --if l_plannedflag is null, no trip is associated => delivery can't be firmed
        IF l_plannedflag IS null THEN
           FND_MESSAGE.SET_NAME('WSH','WSH_FIRM_DELIVERY_ERROR');
           FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_entity_id));
           wsh_util_core.add_message(WSH_UTIL_CORE.g_ret_sts_error,l_module_name);
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           IF l_debug_on THEN
              WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           rollback to before_firm;
           RETURN;
        ELSE
           UPDATE wsh_new_deliveries
           SET planned_flag          = c_routing_firm_flag,
               last_update_date      = sysdate,
               last_updated_by       = FND_GLOBAL.USER_ID
           WHERE delivery_id = p_entity_id;

           IF (SQL%NOTFOUND) THEN
              FND_MESSAGE.SET_NAME('WSH','WSH_DEL_NOT_FOUND');
              x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
              wsh_util_core.add_message(x_return_status);
              IF l_debug_on THEN
                WSH_DEBUG_SV.pop(l_module_name);
              END IF;
              rollback to before_firm;
              RETURN;
           END IF;

        END IF;

      END IF;--p_entity

  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
EXCEPTION
    WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        rollback to before_firm;
        wsh_util_core.default_handler('WSH_TP_RELEASE.firm_entity');
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --

end firm_entity;

-- START
-- PROCEDURE unfirm_entity
--
-- 1. Downgrading a trip (to Routing Firm/Unfirm) will make the deliveries in the trip a Contents Firm.
--    If there are other trips associated to this delivery, those trips will become Routing Firm.
-- 2. Downgrading a delivery (to Contents Firm/Unfirm) will make the associated trips to become
--    Routing Firm.
-- 3. Unfirming trip will unfirm CM as well (if CM is firm) - not handled in this api but handled
--    at the group api level.
-- END

PROCEDURE unfirm_entity(
                       p_entity        IN VARCHAR2,         --either 'DLVY' or 'TRIP'
                       p_entity_id     IN NUMBER,
                       p_action        IN VARCHAR2,         --either 'PLAN' or 'UNPLAN'
                       x_return_status OUT NOCOPY VARCHAR2) IS

CURSOR c_deliveries IS
SELECT dg.delivery_id
FROM   wsh_trip_stops st,
       wsh_delivery_legs dg,
       wsh_new_deliveries nd
WHERE  st.trip_id = p_entity_id AND
       dg.pick_up_stop_id = st.stop_id AND
       nd.delivery_id=dg.delivery_id AND
       nd.planned_flag='F';

--for related trips
CURSOR c_trips (p_delid NUMBER) IS
SELECT t.trip_id
FROM   wsh_trips t,
       wsh_trip_stops st,
       wsh_delivery_legs dg
WHERE  t.trip_id <> p_entity_id AND
       st.trip_id = t.trip_id AND
       dg.pick_up_stop_id = st.stop_id AND
       dg.delivery_id=p_delid
       and t.planned_flag='F';

/******DLVY*****/
--for related trips
CURSOR c_dlvy_trips IS
SELECT t.trip_id
FROM   wsh_trips t,
       wsh_trip_stops st,
       wsh_delivery_legs dg
WHERE  st.trip_id = t.trip_id AND
       dg.pick_up_stop_id = st.stop_id AND
       dg.delivery_id=p_entity_id
       and t.planned_flag='F';

CURSOR c_gettripplannedflag IS
select planned_flag
from wsh_trips
where trip_id=p_entity_id;

l_tripplan VARCHAR2(1);

l_action VARCHAR2(1);
l_entity VARCHAR2(2000);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'unfirm_entity';
--
begin

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;

  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_entity',p_entity);
    WSH_DEBUG_SV.log(l_module_name,'p_entity_id',p_entity_id);
    WSH_DEBUG_SV.log(l_module_name,'p_action',p_action);
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF p_action='PLAN' THEN
    l_action:='Y';
  ELSIF p_action='UNPLAN' THEN
    l_action:='N';
  END IF;

  SAVEPOINT before_unfirm;

  IF (p_entity='TRIP') THEN

       OPEN c_gettripplannedflag;
       FETCH c_gettripplannedflag INTO l_tripplan;
       CLOSE c_gettripplannedflag;

       UPDATE wsh_trips
       SET planned_flag          = l_action,
           last_update_date      = sysdate,
           last_updated_by       = FND_GLOBAL.USER_ID
       WHERE trip_id = p_entity_id;

       IF (SQL%NOTFOUND) THEN
              FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_NOT_FOUND');
              x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
              wsh_util_core.add_message(x_return_status);
              IF l_debug_on THEN
                WSH_DEBUG_SV.pop(l_module_name);
              END IF;
              rollback to before_unfirm;
              RETURN;
       END IF;

     --if l_tripplan is F, all dels are F, so cursor fetches all deliveries
     --else if l_tripplan=Y and user is trying to unplan, see if F deliveries exist
     --and make them Y and related trips as Y if F

     IF l_tripplan='F' OR (l_tripplan='Y' and l_action='N') THEN
       FOR del_cur IN c_deliveries LOOP
         --set all deliveries as 'PLAN' irrespective of whether trip is being reduced to planned/unplanned
         --as unplanned trip may have planned deliveries, unless (bug 3294663) the trip is being set to RF
         --from RCF (l_action = 'Y') in which case the delivery will remain at RCF.
         UPDATE wsh_new_deliveries
         SET planned_flag          = decode(l_action, 'Y', planned_flag, 'Y'),
             last_update_date      = sysdate,
             last_updated_by       = FND_GLOBAL.USER_ID
         WHERE delivery_id = del_cur.delivery_id;
           --raise error to avoid inconsistency
           IF (SQL%NOTFOUND) THEN
              FND_MESSAGE.SET_NAME('WSH','WSH_FIRM_UPDATE_ERROR');
              l_entity := FND_MESSAGE.GET_STRING('WSH','WSH_DELIVERY');
              FND_MESSAGE.SET_TOKEN('ENTITY',l_entity);
              FND_MESSAGE.SET_TOKEN('NAME',wsh_new_deliveries_pvt.get_name(del_cur.delivery_id));
              x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
              wsh_util_core.add_message(x_return_status);
              IF l_debug_on THEN
                WSH_DEBUG_SV.pop(l_module_name);
              END IF;
              rollback to before_unfirm;
              RETURN;
           END IF;


         FOR l_trips_cur IN c_trips(del_cur.delivery_id) LOOP
           UPDATE wsh_trips
           SET planned_flag          = 'Y',
               last_update_date      = sysdate,
               last_updated_by       = FND_GLOBAL.USER_ID
           WHERE trip_id = l_trips_cur.trip_id;
            --raise error to avoid inconsistency
            IF (SQL%NOTFOUND) THEN
              FND_MESSAGE.SET_NAME('WSH','WSH_FIRM_UPDATE_ERROR');
              l_entity := FND_MESSAGE.GET_STRING('WSH','WSH_ENTITY_RELATED_TRIP');
              FND_MESSAGE.SET_TOKEN('ENTITY',l_entity);
              FND_MESSAGE.SET_TOKEN('NAME',wsh_trips_pvt.get_name(l_trips_cur.trip_id));
              x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
              wsh_util_core.add_message(x_return_status);
              IF l_debug_on THEN
                WSH_DEBUG_SV.pop(l_module_name);
              END IF;
              rollback to before_unfirm;
              RETURN;
            END IF;

         END LOOP;
       END LOOP;
     END IF; --trip plan flag = F or (trip_plan=Y and del plan flag=F)
  ELSIF p_entity='DLVY' THEN

       UPDATE wsh_new_deliveries
       SET planned_flag          = l_action,
           last_update_date      = sysdate,
           last_updated_by       = FND_GLOBAL.USER_ID
       WHERE delivery_id = p_entity_id;

       IF (SQL%NOTFOUND) THEN
              FND_MESSAGE.SET_NAME('WSH','WSH_DEL_NOT_FOUND');
              x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
              wsh_util_core.add_message(x_return_status);
              IF l_debug_on THEN
                WSH_DEBUG_SV.pop(l_module_name);
              END IF;
              rollback to before_unfirm;
              RETURN;
       END IF;

       FOR cur_deltrip IN c_dlvy_trips LOOP
         UPDATE wsh_trips
         SET planned_flag          = 'Y',
             last_update_date      = sysdate,
             last_updated_by       = FND_GLOBAL.USER_ID
         WHERE trip_id = cur_deltrip.trip_id;

         --raise error to avoid inconsistency
         IF (SQL%NOTFOUND) THEN
              FND_MESSAGE.SET_NAME('WSH','WSH_FIRM_UPDATE_ERROR');
              l_entity := FND_MESSAGE.GET_STRING('WSH','WSH_ENTITY_RELATED_TRIP');
              FND_MESSAGE.SET_TOKEN('ENTITY',l_entity);
              FND_MESSAGE.SET_TOKEN('NAME',wsh_trips_pvt.get_name(p_entity_id));
              x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
              wsh_util_core.add_message(x_return_status);
              IF l_debug_on THEN
                WSH_DEBUG_SV.pop(l_module_name);
              END IF;
              rollback to before_unfirm;
              RETURN;
         END IF;
       END LOOP;

  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        wsh_util_core.default_handler('WSH_TP_RELEASE.unfirm_entity');
        rollback to before_unfirm;
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --

end unfirm_entity;

PROCEDURE calculate_lpn_tpdates(p_delivery_detail_id NUMBER,
                                x_updated_flag  OUT NOCOPY VARCHAR2,
                                x_delivery_id   OUT NOCOPY NUMBER,
                                x_return_status OUT NOCOPY VARCHAR2);
PROCEDURE refresh_lpn_hierarchy_dates(l_lpndetail_ids IN wsh_util_core.id_tab_type,
                                      x_upd_del_tab   OUT NOCOPY wsh_util_core.id_tab_type,
                                      x_return_status OUT NOCOPY VARCHAR2);
PROCEDURE calculate_del_tpdates(l_del_ids IN wsh_util_core.id_tab_type,
                                l_refresh_lpn_flag IN VARCHAR2,
                                x_return_status OUT NOCOPY VARCHAR2);

--needs to be changed based on Roy's email and after talking to Hema
--to be used only if source_code='OE'. OKE lines will already be populated
/**
 *   Calculates the TP dates based on the OE dates provided.
 *  The calculation is based on the profile values Earliest_Profile and LDD Profile.
*/
PROCEDURE calculate_tp_dates(
              p_request_date_type IN VARCHAR2,
              p_latest_acceptable_date IN DATE,
              p_promise_date IN DATE,
              p_schedule_arrival_date IN DATE,
              p_schedule_ship_date IN DATE,
              p_earliest_acceptable_date IN DATE,
              p_demand_satisfaction_date IN DATE,
              p_source_line_id NUMBER,
              p_source_code IN     VARCHAR2,
              p_organization_id NUMBER,
              p_inventory_item_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2,
              x_earliest_pickup_date OUT NOCOPY DATE,
              x_latest_pickup_date OUT NOCOPY DATE,
              x_earliest_dropoff_date OUT NOCOPY DATE,
              x_latest_dropoff_date OUT NOCOPY DATE
              ) IS


l_request_date_type VARCHAR(20);
l_days_profile NUMBER;
item_type VARCHAR2(10);
--
l_earliest_pickup_date DATE;
l_latest_pickup_date DATE;
l_earliest_dropoff_date DATE;
l_latest_dropoff_date DATE;

l_deldetail_creation_date DATE;
l_delivery_detail_id NUMBER;
l_split_delivery_detail_id NUMBER;
l_creation_date DATE;
l_latest_acceptable_date DATE;
l_promise_date  DATE;
l_earliest_acceptable_date DATE;
l_demand_satisfaction_date DATE;

l_inventory_item_id NUMBER;
l_organization_id NUMBER;
l_atp_flag VARCHAR(1);


CURSOR c_oe_item_id(p_source_line_id IN NUMBER) IS
 SELECT ship_from_org_id,inventory_item_id
  FROM OE_ORDER_LINES_ALL
  WHERE line_id = p_source_line_id;

CURSOR c_dd_item_id(p_source_line_id IN NUMBER,p_source_code IN VARCHAR2) IS
  SELECT organization_id,inventory_item_id,delivery_detail_id,split_from_delivery_detail_id,creation_date
    FROM WSH_DELIVERY_DETAILS
    WHERE source_line_id = p_source_line_id
     AND source_code = p_source_code;

CURSOR c_min_ddcreation_date(p_source_line_id IN NUMBER,p_source_code IN VARCHAR2) IS
  SELECT min(creation_date)
    FROM WSH_DELIVERY_DETAILS
    WHERE source_line_id = p_source_line_id
     AND source_code = p_source_code;

CURSOR c_atp_flag_info(p_inventory_item_id IN NUMBER,p_org_id IN NUMBER) IS
  SELECT  ATP_FLAG
     FROM MTL_SYSTEM_ITEMS
     WHERE   inventory_item_id = p_inventory_item_id
      AND  organization_id = p_org_id;



--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'calculate_tp_dates';
--


l_earliestprofile_EAD CONSTANT VARCHAR2(20) :=  'EAR_ACC_DATE';
l_earliestprofile_LD CONSTANT VARCHAR2(20) :=  'SAME_SHIP_DELIVER';

l_LDDprofile_LPS  CONSTANT VARCHAR2(20) := 'LAD_PD_SCH';
l_LDDprofile_PS CONSTANT VARCHAR2(10) := 'PD_SCH';
l_LDDprofile_S CONSTANT VARCHAR2(10) := 'SCH_DATE';
l_modified VARCHAR2(1);
adjustDates BOOLEAN := FALSE;

others     EXCEPTION;

BEGIN

  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


    --
    IF l_debug_on THEN
       wsh_debug_sv.push(l_module_name, 'calculate_tp_dates');
       wsh_debug_sv.log (l_module_name,'p_request_date_type', p_request_date_type);
       wsh_debug_sv.log (l_module_name,'p_latest_acceptable_date', p_latest_acceptable_date);
       wsh_debug_sv.log (l_module_name,'p_promise_date', p_promise_date);
       wsh_debug_sv.log (l_module_name,'p_schedule_arrival_date',p_schedule_arrival_date);
       wsh_debug_sv.log (l_module_name,'p_schedule_ship_date',p_schedule_ship_date);
       wsh_debug_sv.log (l_module_name,'p_earliest_acceptable_date', p_earliest_acceptable_date);
       wsh_debug_sv.log (l_module_name,'p_demand_staisfaction_date', p_demand_satisfaction_date);
       wsh_debug_sv.log (l_module_name,'p_source_line_id', p_source_line_id);
       wsh_debug_sv.log (l_module_name,'p_source_code', p_source_code);
       wsh_debug_sv.log (l_module_name,'p_organization_id', p_organization_id);
       wsh_debug_sv.log (l_module_name,'p_inventory_item_id', p_inventory_item_id);
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CUSTOM_PUB.calculate_tp_dates',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;


    WSH_CUSTOM_PUB.calculate_tp_dates(
              p_source_line_id        => p_source_line_id,
              p_source_code           => p_source_code,
              x_earliest_pickup_date  => l_earliest_pickup_date,
              x_latest_pickup_date    => l_latest_pickup_date,
              x_earliest_dropoff_date => l_earliest_dropoff_date,
              x_latest_dropoff_date   => l_latest_dropoff_date,
              x_modified              => l_modified);

    IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name,'l_modified', l_modified);
    END IF;

    IF l_modified='Y' THEN -- use results from customized call, go directly to end of procedure
       x_earliest_pickup_date  := l_earliest_pickup_date;
       x_latest_pickup_date    := l_latest_pickup_date;
       x_earliest_dropoff_date := l_earliest_dropoff_date;
       x_latest_dropoff_date   := l_latest_dropoff_date;

      IF l_debug_on THEN
         wsh_debug_sv.logmsg (l_module_name,'Results from customized call...');
         wsh_debug_sv.log (l_module_name,'l_earliest_pickup_date', l_earliest_pickup_date);
         wsh_debug_sv.log (l_module_name,'l_latest_pickup_date', l_latest_pickup_date);
         wsh_debug_sv.log (l_module_name,'l_earliest_dropoff_date', l_earliest_dropoff_date);
         wsh_debug_sv.log (l_module_name,'l_latest_dropoff_date', l_latest_dropoff_date);
      END IF;

    ELSE -- l_modified='N' - use our calculation

    --Bug 3816115
    IF G_LDD_profile IS NULL THEN
    G_LDD_profile      := NVL(FND_PROFILE.VALUE('ONT_SHIP_DEADLINE_SEQUENCE'),
                              l_LDDprofile_LPS);
    END IF;
    IF G_earliest_profile IS NULL THEN
       G_earliest_profile := NVL(FND_PROFILE.VALUE('ONT_EARLY_SHIP_DATE_SOURCE'),
                              l_earliestprofile_EAD);
    END IF;

    IF l_debug_on THEN
      wsh_debug_sv.log (l_module_name,'G_LDD_profile', G_LDD_profile);
      wsh_debug_sv.log (l_module_name,'G_earliest_profile', G_earliest_profile);
    END IF;

    --Bug 3816115
    IF G_lc_days_profile IS NULL THEN
       G_lc_days_profile :=  NVL(FND_PROFILE.VALUE('FTE_LATESHIP_OFFSET_DAYS'), 90);
    END IF;
    --
    BEGIN
      l_days_profile := TO_NUMBER(G_lc_days_profile);
    EXCEPTION
      WHEN others THEN
        l_days_profile := 0;
    END;
    --
    IF l_days_profile < 0 THEN
      l_days_profile := 0;
    END IF;
    --
    IF l_debug_on THEN
     wsh_debug_sv.log(l_module_name, 'l_days_profile', l_days_profile);
    END IF;
    --
    -- Bug 4368984
    -- Populate lastest ship/delivery date
    IF G_populate_date_profile IS NULL THEN
       G_populate_date_profile :=  NVL(FND_PROFILE.VALUE('WSH_POPULATE_LATEST_SHIP_DELIVERY_DATE'), 'N');
    END IF;

    IF l_debug_on THEN
      wsh_debug_sv.log (l_module_name,'G_populate_date_profile', G_populate_date_profile);
    END IF;
    --

    IF p_request_date_type IS NULL THEN
      l_request_date_type := 'SHIP';
    ELSE
      l_request_date_type := p_request_date_type;
    END IF;
    IF (p_organization_id IS NULL OR p_organization_id = FND_API.G_MISS_NUM)
      OR (p_inventory_item_id IS NULL OR p_inventory_item_id  = FND_API.G_MISS_NUM) THEN

      OPEN c_dd_item_id(p_source_line_id,p_source_code);
      FETCH c_dd_item_id INTO  l_organization_id,l_inventory_item_id,
                                l_delivery_detail_id,l_split_delivery_detail_id,l_creation_date;
      IF c_dd_item_id%NOTFOUND THEN
        CLOSE c_dd_item_id;
        l_deldetail_creation_date := sysdate;
        OPEN  c_oe_item_id(p_source_line_id);
        FETCH c_oe_item_id INTO l_organization_id,l_inventory_item_id;
        IF c_oe_item_id%NOTFOUND THEN
          CLOSE c_oe_item_id;
          raise others;
        END IF;
        IF c_oe_item_id%ISOPEN THEN
          CLOSE c_oe_item_id;
        END IF;
      ELSE
        IF l_split_delivery_detail_id is NULL THEN
          l_deldetail_creation_date := l_creation_date;
        ELSE
          OPEN c_min_ddcreation_date(p_source_line_id,p_source_code);
          FETCH c_min_ddcreation_date INTO l_creation_date;
          CLOSE c_min_ddcreation_date;
          l_deldetail_creation_date := l_creation_date;
        END IF;
      END IF;
      IF c_dd_item_id%ISOPEN THEN
        CLOSE c_dd_item_id;
      END IF;
    ELSE
      OPEN c_min_ddcreation_date(p_source_line_id,p_source_code);
      FETCH c_min_ddcreation_date INTO l_creation_date;
      CLOSE c_min_ddcreation_date;
      l_deldetail_creation_date := l_creation_date;
      l_inventory_item_id := p_inventory_item_id;
      l_organization_id := p_organization_id;
    END IF;

    OPEN c_atp_flag_info(l_inventory_item_id,l_organization_id);
    FETCH c_atp_flag_info INTO l_atp_flag;
    IF c_atp_flag_info%NOTFOUND THEN
      CLOSE c_atp_flag_info;
      raise others;
    END IF;
    IF c_atp_flag_info%ISOPEN THEN
      CLOSE c_atp_flag_info;
    END IF;
    IF (l_atp_flag ='Y') OR (l_atp_flag = 'C') THEN
      item_type := 'ATP';
    ELSE
      item_type := 'NON-ATP';
    END IF;


-- Latest Ship Date(Ship) and Latest Delivery Date(Arrival) Calculation
    IF ((p_latest_acceptable_date IS NOT NULL) AND
            (to_char(p_latest_acceptable_date,'HH24:MI') = '00:00') OR  (to_char(p_latest_acceptable_date,'HH24:MI') = '00:01')) THEN

      l_latest_acceptable_date := to_date((to_char(p_latest_acceptable_date,'mm-dd-yy')||' 23:59:00'),'mm-dd-yy HH24:MI:SS');

    ELSE

      l_latest_acceptable_date := p_latest_acceptable_date;

    END IF;

    IF ((p_promise_date IS NOT NULL) AND
    (to_char(p_promise_date,'HH24:MI') = '00:00') OR (to_char(p_promise_date,'HH24:MI') = '00:01')) THEN
      l_promise_date := to_date((to_char(p_promise_date,'mm-dd-yy')||' 23:59:00'),'mm-dd-yy HH24:MI:SS');
    ELSE
      l_promise_date := p_promise_date;
    END IF;

    IF l_request_date_type='SHIP' THEN
      --
      IF G_LDD_profile =l_LDDprofile_LPS  THEN
        l_latest_pickup_date:=nvl(l_latest_acceptable_date, nvl(l_promise_date, p_schedule_ship_date ));
      ELSIF G_LDD_profile =l_LDDprofile_PS THEN
        l_latest_pickup_date:=nvl(l_promise_date, p_schedule_ship_date );
      ELSIF G_LDD_profile = l_LDDprofile_S THEN
        l_latest_pickup_date:=p_schedule_ship_date ;
      END IF;
      --
    ELSIF l_request_date_type='ARRIVAL' THEN
      --
      IF G_LDD_profile =l_LDDprofile_LPS  THEN
        l_latest_dropoff_date:=nvl(l_latest_acceptable_date, nvl(l_promise_date, p_schedule_arrival_date ));
      ELSIF G_LDD_profile =l_LDDprofile_PS THEN
        l_latest_dropoff_date:=nvl(l_promise_date, p_schedule_arrival_date );
      ELSIF G_LDD_profile =l_LDDprofile_S THEN
        l_latest_dropoff_date:=p_schedule_arrival_date ;
      END IF;
      --
    END IF;

-- END Latest Ship Date(Ship) and Latest Delivery Date(Arrival) Calculation


  IF l_request_date_type='SHIP' THEN
    --{
    -- Earliest Ship Date Calculation
    IF ((p_earliest_acceptable_date IS NOT NULL) AND
    (to_char(p_earliest_acceptable_date,'HH24:MI') = '00:00') OR (to_char(p_earliest_acceptable_date,'HH24:MI') = '23:59')) THEN

      l_earliest_acceptable_date := to_date((to_char(p_earliest_acceptable_date,'mm-dd-yy')||' 00:01:00'),'mm-dd-yy HH24:MI:SS');

    ELSE
      l_earliest_acceptable_date := p_earliest_acceptable_date;
    END IF;
    --
    IF p_demand_satisfaction_date IS NOT NULL THEN
      l_demand_satisfaction_date := to_date((to_char(p_demand_satisfaction_date,'mm-dd-yy')||' 00:01:00'),'mm-dd-yy HH24:MI:SS');
    ELSE
      l_demand_satisfaction_date := NULL;
    END IF;
    --
    IF item_type='ATP' THEN
      --{
      IF G_earliest_profile=l_earliestprofile_EAD THEN
        IF (p_earliest_acceptable_date is null) OR (p_demand_satisfaction_date > p_earliest_acceptable_date) THEN
          l_earliest_pickup_date := l_demand_satisfaction_date;
        ELSE
          l_earliest_pickup_date := l_earliest_acceptable_date;
        END IF;
      END IF;
      --
      IF G_earliest_profile=l_earliestprofile_LD THEN
        IF (p_demand_satisfaction_date is null) OR (l_latest_pickup_date > p_demand_satisfaction_date) THEN
          IF l_latest_pickup_date IS NOT NULL THEN
            l_earliest_pickup_date := to_date((to_char(l_latest_pickup_date,'mm-dd-yy')||' 00:01:00'),'mm-dd-yy HH24:MI:SS');
           ELSE
            l_earliest_pickup_date := NULL;
          END IF;
        ELSE
          l_earliest_pickup_date := l_demand_satisfaction_date;
        END IF;
      END IF;
      --}
    ELSE
      --{
      IF G_earliest_profile=l_earliestprofile_EAD THEN
        IF l_earliest_acceptable_date IS NOT NULL THEN
          l_earliest_pickup_date := l_earliest_acceptable_date;
        ELSE
          l_earliest_pickup_date := l_deldetail_creation_date;
        END IF;
      END IF;
      --
      IF G_earliest_profile=l_earliestprofile_LD THEN
        IF l_latest_pickup_date IS NOT NULL THEN
          l_earliest_pickup_date := to_date((to_char(l_latest_pickup_date,'mm-dd-yy')||' 00:01:00'),'mm-dd-yy HH24:MI:SS');
        ELSE
          l_earliest_pickup_date := NULL;
        END IF;
      END IF;
      --}
    END IF;

-- End of Earliest Ship Date Calculation

-- Earliest/Latest Delivery Date Calculation
  l_earliest_dropoff_date := NULL;

  -- Bug 4368984
  IF G_populate_date_profile = 'Y' THEN
    l_latest_dropoff_date := to_date((to_char(p_schedule_arrival_date,'mm-dd-yy')||' 23:59:00'),'mm-dd-yy HH24:MI:SS');
  ELSE
    l_latest_dropoff_date := NULL;
  END IF;
  --
-- End Earliest/Latest Delivery Date Calculation
  --}
  END IF;  -- date_type is 'SHIP'


  IF l_request_date_type='ARRIVAL' THEN
    -- Earliest Ship Date Calculation
    IF item_type='ATP' THEN
      IF (p_demand_satisfaction_date is not null) THEN
        l_earliest_pickup_date := to_date((to_char(p_demand_satisfaction_date,'mm-dd-yy')||' 00:01:00'),'mm-dd-yy HH24:MI:SS');
      ELSE
        l_earliest_pickup_date := NULL;
      END IF;
    ELSE
      l_earliest_pickup_date := l_deldetail_creation_date;
    END IF;
    -- End of Earliest Ship Date Calculation


    -- Latest Ship Date Calculation

      -- Bug 4368984
      IF G_populate_date_profile = 'Y' THEN
        l_latest_pickup_date := to_date((to_char(p_schedule_ship_date,'mm-dd-yy')||' 23:59:00'),'mm-dd-yy HH24:MI:SS');
      ELSE
        l_latest_pickup_date := l_latest_dropoff_date+l_days_profile;
      END IF;
      --

    -- End of Latest Ship Date Calculation

    -- Earliest Delivery Date Calculation
    IF (p_earliest_acceptable_date is not null) AND
        ((to_char(p_earliest_acceptable_date,'HH24:MI') = '00:00') OR (to_char(p_earliest_acceptable_date,'HH24:MI') = '23:59')) THEN

      l_earliest_acceptable_date := to_date((to_char(p_earliest_acceptable_date,'mm-dd-yy')||' 00:01:00'),'mm-dd-yy HH24:MI:SS');

    ELSE
      l_earliest_acceptable_date := p_earliest_acceptable_date;
    END IF;

    IF G_earliest_profile=l_earliestprofile_EAD THEN
          l_earliest_dropoff_date:=l_earliest_acceptable_date;
    ELSIF G_earliest_profile=l_earliestprofile_LD THEN
          IF (l_latest_dropoff_date is not null) THEN
            l_earliest_dropoff_date:= to_date((to_char(l_latest_dropoff_date,'mm-dd-yy')||' 00:01:00'),'mm-dd-yy HH24:MI:SS');
          ELSE
            l_earliest_dropoff_date := NULL;
          END IF;
    END IF;
    -- End of Earliest Delivery Date Calculation

  END IF; -- date_type is 'Arrival'
  --
  x_earliest_pickup_date  := l_earliest_pickup_date;
  x_latest_pickup_date    := l_latest_pickup_date;
  x_earliest_dropoff_date := l_earliest_dropoff_date;
  x_latest_dropoff_date   := l_latest_dropoff_date;

  IF ((to_char(x_earliest_pickup_date,'HH24:MI') = '00:00') OR (to_char(x_earliest_pickup_date,'HH24:MI') = '23:59')) THEN
      x_earliest_pickup_date := to_date((to_char(x_earliest_pickup_date,'MM-DD-YYYY')||' 00:01:00'),'MM-DD-YYYY HH24:MI:SS');
  END IF;
  IF ((to_char(x_earliest_dropoff_date,'HH24:MI') = '00:00') OR (to_char(x_earliest_dropoff_date,'HH24:MI') = '23:59')) THEN
      x_earliest_dropoff_date := to_date((to_char(x_earliest_dropoff_date,'MM-DD-YYYY')||' 00:01:00'),'MM-DD-YYYY HH24:MI:SS');
  END IF;
  IF ((to_char(x_latest_pickup_date,'HH24:MI') = '00:00') OR (to_char(x_latest_pickup_date,'HH24:MI') = '23:59')) THEN
      x_latest_pickup_date := to_date((to_char(x_latest_pickup_date,'MM-DD-YYYY')||' 23:59:00'),'MM-DD-YYYY HH24:MI:SS');
  END IF;
  IF ((to_char(x_latest_dropoff_date,'HH24:MI') = '00:00') OR (to_char(x_latest_dropoff_date,'HH24:MI') = '23:59')) THEN
      x_latest_dropoff_date := to_date((to_char(x_latest_dropoff_date,'MM-DD-YYYY')||' 23:59:00'),'MM-DD-YYYY HH24:MI:SS');
  END IF;

  --bug 3798349 : if earliest dates happen to be > latest dates, set latest=earliest
  --and log exception against detail
  --if earliest dates timecomponent is 00:00 or 23:59, it should be adjusted to 00:01
  --if latest dates timecomponent is 00:00 or 23:59, it should be adjusted to 23:59
  IF x_earliest_pickup_date > x_latest_pickup_date
  OR x_earliest_dropoff_date > x_latest_dropoff_date THEN
      OPEN c_dd_item_id(p_source_line_id,p_source_code);
      LOOP

         FETCH c_dd_item_id INTO  l_organization_id,l_inventory_item_id,
                                l_delivery_detail_id,l_split_delivery_detail_id,l_creation_date;

         EXIT WHEN c_dd_item_id%NOTFOUND;
         adjustDates := TRUE;
         IF x_earliest_pickup_date > x_latest_pickup_date THEN
             log_tpdate_exception('LINE',l_delivery_detail_id,TRUE,x_earliest_pickup_date,x_latest_pickup_date);
         END IF;

         IF x_earliest_dropoff_date > x_latest_dropoff_date THEN
             log_tpdate_exception('LINE',l_delivery_detail_id,FALSE,x_earliest_dropoff_date,x_latest_dropoff_date);
         END IF;
      END LOOP;
      CLOSE c_dd_item_id;
      IF adjustDates THEN
        IF x_earliest_pickup_date > x_latest_pickup_date THEN
          x_latest_pickup_date := x_earliest_pickup_date;
        END IF;

        IF x_earliest_dropoff_date > x_latest_dropoff_date THEN
          x_latest_dropoff_date := x_earliest_dropoff_date;
        END IF;
      END IF;
  END IF;

  END IF; --l_modified='Y'

  --
  IF l_debug_on THEN
     wsh_debug_sv.log (l_module_name,'x_earliest_pickup_date', x_earliest_pickup_date);
     wsh_debug_sv.log (l_module_name,'x_latest_pickup_date', x_latest_pickup_date);
     wsh_debug_sv.log (l_module_name,'x_earliest_dropoff_date', x_earliest_dropoff_date);
     wsh_debug_sv.log (l_module_name,'x_latest_dropoff_date', x_latest_dropoff_date);
     WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION
      WHEN OTHERS THEN
         x_return_status := WSH_UTIL_CORE.g_ret_sts_unexp_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
END calculate_tp_dates;

/**
*  calculate_cont_del_tpdates calculates TPdates for the Deliveries and containers.
*  p_entity takes in three values DLVY, LPN and DLVB
*  If DLVY p_entity_ids are to be deliveryIds (This will also update underlying containers if any)
*  If LPN  p_entity_ids are to be ContainerId(delivery_detail_ids with container flag 'Y')
*  If DLVB  p_entity_ids are to be delivery_detail_ids. From the delivery_detail_ids delivery_ids,container_ids
*   are derived.
*   If the delivery_detail_id is assigned to delivery_id the corresponding delivery_id is added to delivery_list.
*   If the  delivery_detail_id is packed in container the corresponding container_id(delivery_detail_id)
*        is added to container_list
*   If the delivery_detail_id  itself is container then it is added to container_list
*   Atlast the tp dates are calculated for sorted delivery_list and container_list.
*/

PROCEDURE calculate_cont_del_tpdates(p_entity IN VARCHAR2,
                                     p_entity_ids IN wsh_util_core.id_tab_type,
                                     x_return_status OUT NOCOPY VARCHAR2) IS

  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'calculate_cont_del_tpdates';
  --
  l_debug_on BOOLEAN;

  l_earliest_mpickup_date DATE;
  l_earliest_mdropoff_date DATE;
  l_latest_mpickup_date DATE;
  l_latest_mdropoff_date DATE;


  dlvry_ids Distinct_Ids_tab;
  detail_ids Distinct_Ids_tab;


  CURSOR c_MasterLPN_del_id(p_delivery_detail_id IN NUMBER) IS
    SELECT  wda.parent_delivery_detail_id,wda.delivery_id,container_flag
      FROM  wsh_delivery_details wdd,wsh_delivery_assignments_v wda
      WHERE wda.delivery_detail_id = wdd.delivery_detail_id
        AND wda.delivery_detail_id = p_delivery_detail_id;

  l_entity_id NUMBER;
  l_delivery_id  NUMBER;
  l_mas_detail_id NUMBER;
  l_container_flag VARCHAR(2);


  l_del_ids wsh_util_core.id_tab_type;
  l_dummy_ids wsh_util_core.id_tab_type;
  l_lpndetail_ids wsh_util_core.id_tab_type;

  del_index NUMBER;
  detail_index NUMBER;

  j BINARY_INTEGER;
  others exception;

BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    wsh_debug_sv.push(l_module_name);
    wsh_debug_sv.log (l_module_name,'p_entity', p_entity);
    wsh_debug_sv.log (l_module_name,'p_entity_ids.count', p_entity_ids.count);
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  --
  --

  IF p_entity = 'DLVY' THEN
    IF p_entity_ids.count > 0 THEN
      calculate_del_tpdates(
         l_del_ids => p_entity_ids,
         l_refresh_lpn_flag => 'Y',
         x_return_status => x_return_status);

      IF x_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
          return;
      END IF;
    END IF;
  ELSIF p_entity = 'LPN' THEN
      IF p_entity_ids.count > 0 THEN
          refresh_lpn_hierarchy_dates(l_lpndetail_ids => p_entity_ids,
                                      x_upd_del_tab   => l_del_ids,
                                      x_return_status => x_return_status);

          IF ( l_del_ids.COUNT > 0 ) THEN
             calculate_del_tpdates( l_del_ids => l_del_ids,
                                    l_refresh_lpn_flag => 'N',
                                    x_return_status => x_return_status );
             IF x_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
               raise OTHERS;
             END IF;
          END IF;

    END IF;
  ELSIF p_entity ='DLVB' THEN
    FOR i IN 1..p_entity_ids.count LOOP
      l_entity_id := p_entity_ids(i);
      OPEN c_MasterLPN_del_id(l_entity_id);
      FETCH c_MasterLPN_del_id INTO l_mas_detail_id,l_delivery_id,l_container_flag;
      IF c_MasterLPN_del_id%FOUND THEN
        IF l_delivery_id IS NOT NULL THEN
          dlvry_ids(l_delivery_id) := l_delivery_id;
        ELSIF l_container_flag = 'Y' THEN
          detail_ids(l_entity_id) := l_entity_id;
        ELSIF l_mas_detail_id IS NOT NULL THEN
          detail_ids(l_mas_detail_id) := l_mas_detail_id;
        END IF;
      END IF;
      CLOSE c_MasterLPN_del_id;
    END LOOP;
    del_index := 1;
    detail_index :=1;

    j := detail_ids.FIRST;
    IF j IS NOT NULL THEN
      WHILE j iS NOT NULL LOOP
        l_lpndetail_ids(detail_index) := detail_ids(j);
        detail_index := detail_index + 1;
        j := detail_ids.NEXT(j);
      END LOOP;
      refresh_lpn_hierarchy_dates(l_lpndetail_ids => l_lpndetail_ids,
                                      x_upd_del_tab   => l_dummy_ids,
                                      x_return_status => x_return_status);
      IF x_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
          return;
      END IF;
    END IF;

    j := dlvry_ids.FIRST;
    IF j IS NOT NULL THEN
      WHILE j iS NOT NULL LOOP
        l_del_ids(del_index) := dlvry_ids(j);
        del_index := del_index + 1;
        j := dlvry_ids.NEXT(j);
      END LOOP;
      calculate_del_tpdates( l_del_ids => l_del_ids,
                             l_refresh_lpn_flag => 'Y',
                             x_return_status => x_return_status );

      IF x_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
          return;
      END IF;
    END IF;


  END IF;

  --
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.DEFAULT_HANDLER(
                        'WSH_TP_RELEASE.calculate_cont_del_tpdates',
                        l_module_name);

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
END calculate_cont_del_tpdates;

/**
*  calculate_del_tpdates calculates TPdates for the Deliveries.
*  l_del_ids is the list of deliveries for which tpdates have to be calculated or recalculated
*/
PROCEDURE calculate_del_tpdates(l_del_ids IN wsh_util_core.id_tab_type,
                                l_refresh_lpn_flag IN VARCHAR2,
                                x_return_status OUT NOCOPY VARCHAR2
                                ) IS

  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'calculate_del_tpdates';

  --
  l_debug_on BOOLEAN;
  --
  l_initial_mpickup_date DATE;
  l_ultimate_mdropoff_date DATE;
  l_earliest_mpickup_date DATE;
  l_earliest_mdropoff_date DATE;
  l_latest_mpickup_date DATE;
  l_latest_mdropoff_date DATE;
  l_max_schedule_date DATE;
  l_min_schedule_date DATE;
  l_min_request_date DATE;
  l_max_request_date DATE;
  l_min_detSch_date  DATE;
  l_min_detReq_date  DATE;
  l_max_detSch_date  DATE;
  l_delivery_id NUMBER;
  l_masdet_id wsh_util_core.id_tab_type;
  l_dummy_ids wsh_util_core.id_tab_type;
  l_del_date_calc_method  VARCHAR(1);
  l_shp_dir VARCHAR2(5);
  others EXCEPTION;

  -- BugFix 3570954 - Start
  CURSOR get_delivery_for_lock (p_delivery_id IN NUMBER) IS
    SELECT earliest_pickup_date,
	   earliest_dropoff_date,
	   latest_pickup_date,
	   latest_dropoff_date,
	   initial_pickup_date,
	   ultimate_dropoff_date,
           ignore_for_planning --OTM R12
    FROM   WSH_NEW_DELIVERIES
    WHERE  delivery_id = p_delivery_id
    FOR UPDATE NOWAIT;

  l_delivery_rec   get_delivery_for_lock%rowtype;
  lock_detected	EXCEPTION;
  PRAGMA EXCEPTION_INIT( lock_detected, -00054);
  -- BugFix 3570954 - End


  CURSOR get_LPNS(p_delivery_id IN NUMBER)  IS
      SELECT  wdd.delivery_detail_id,wda.delivery_id
        FROM  wsh_delivery_details wdd,wsh_delivery_assignments_v wda
        WHERE wda.delivery_detail_id = wdd.delivery_detail_id
          AND wdd.container_flag = 'Y'
      --    AND wda.parent_delivery_detail_id IS NULL
          AND wda.delivery_id = p_delivery_id;


  CURSOR max_min_det_deltp_dates(p_delivery_id IN NUMBER)  IS
    SELECT  max(wdd.earliest_pickup_date),max(wdd.earliest_dropoff_date),
            min(wdd.latest_pickup_date),min(wdd.latest_dropoff_date),
            min(wdd.date_scheduled), min(wdd.date_requested), max(wdd.date_scheduled)
      FROM  wsh_delivery_details wdd,wsh_delivery_assignments_v wda
      WHERE wda.delivery_detail_id = wdd.delivery_detail_id
        AND wda.parent_delivery_detail_id IS NULL
      AND wda.delivery_id = p_delivery_id;


  CURSOR max_min_om_deltp_dates(p_delivery_id IN NUMBER)  IS
  SELECT max(date_scheduled) , min(date_scheduled),min(date_requested),max(date_requested)
    FROM  wsh_delivery_details wdd,wsh_delivery_assignments_v wda
    WHERE wda.delivery_detail_id = wdd.delivery_detail_id
        AND delivery_id =p_delivery_id;

  CURSOR is_inbound_dropshp(p_delivery_id IN NUMBER) IS
  SELECT shipment_direction
    FROM wsh_new_deliveries
    WHERE delivery_id =p_delivery_id
    AND shipment_direction IN ('I','D');

  l_global_param_rec_type WSH_SHIPPING_PARAMS_PVT.Global_Parameters_Rec_Typ;

  --OTM R12, glog proj
  l_delivery_info_tab      WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type;
  l_delivery_info          WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type;
  l_new_interface_flag_tab WSH_UTIL_CORE.COLUMN_TAB_TYPE;
  l_tms_update             VARCHAR2(1);
  l_trip_not_found         VARCHAR2(1);
  l_trip_info_rec          WSH_DELIVERY_VALIDATIONS.trip_info_rec_type;
  l_tms_version_number     WSH_NEW_DELIVERIES.TMS_VERSION_NUMBER%TYPE;
  l_return_status          VARCHAR2(1);
  l_gc3_is_installed       VARCHAR2(1);
  --l_sysdate                DATE;
  e_gc3_exception          EXCEPTION;
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
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  --

  --
  --OTM R12, glog proj, use Global Variable
  l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED;

  -- If null, call the function
  IF l_gc3_is_installed IS NULL THEN
    l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED;
  END IF;
  -- Initialize these as they are used in UPDATE statement and in cases where
  -- these are not actually populated
  l_new_interface_flag_tab(1) := WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT;
  -- end of OTM R12, glog proj

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIPPING_PARAMS_PVT. Get_Global_Parameters',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  WSH_SHIPPING_PARAMS_PVT.Get_Global_Parameters(l_global_param_rec_type,
                                                x_return_status);
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'After calling Get_Global_Parameters',
                     x_return_status );
  END IF;
  --
  IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  END IF;
  --
  l_del_date_calc_method := l_global_param_rec_type.DEL_DATE_CALC_METHOD;
  --
  IF l_del_date_calc_method IS NULL THEN
    l_del_date_calc_method := 'S';
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'l_del_date_calc_method: ' || l_del_date_calc_method);
  END IF;
  --
  FOR i IN 1..l_del_ids.count LOOP
    --{
    l_delivery_id := l_del_ids(i);
    IF ( l_refresh_lpn_flag = 'Y' ) THEN

      --
      FOR master_lpns_rec IN get_LPNS(l_delivery_id) LOOP
        --{
        l_masdet_id(1) :=master_lpns_rec.delivery_detail_id;

        refresh_lpn_hierarchy_dates(l_lpndetail_ids => l_masdet_id, x_upd_del_tab => l_dummy_ids, x_return_status => x_return_status);

        --
        IF x_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
          raise others;
        END IF;
        --}
      END LOOP;
      --
    END IF;

    OPEN max_min_det_deltp_dates(l_delivery_id);
    FETCH max_min_det_deltp_dates INTO
          l_earliest_mpickup_date, l_earliest_mdropoff_date,
          l_latest_mpickup_date,l_latest_mdropoff_date,
          l_min_detSch_date, l_min_detReq_date, l_max_detSch_date;
    --
    IF max_min_det_deltp_dates%NOTFOUND THEN
      l_earliest_mpickup_date   := NULL;
      l_earliest_mdropoff_date  := NULL;
      l_latest_mpickup_date     := NULL;
      l_latest_mdropoff_date    := NULL;
      l_min_detReq_date         := NULL;
      l_min_detSch_date         := NULL;
    END IF;
    --
    IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name, 'l_earliest_mpickup_date',
                       l_earliest_mpickup_date);
      wsh_debug_Sv.log(l_module_name, 'l_earliest_mdropoff_date',
                       l_earliest_mdropoff_date);
      wsh_debug_sv.log(l_module_name, 'l_latest_mpickup_date',
                       l_latest_mpickup_date);
      wsh_debug_sv.log(l_module_name, 'l_latest_mdropoff_date',
                       l_latest_mdropoff_date);
      wsh_debug_sv.log(l_module_name, 'l_min_detSch_date',
                       l_min_detSch_date);
      wsh_debug_sv.log(l_module_name, 'l_min_detReq_date',
                       l_min_detReq_date);
      wsh_debug_sv.log(l_module_name, 'l_max_detSch_date',
                       l_max_detSch_date);
    END IF;
    --
    IF (l_latest_mpickup_date IS NOT NULL AND
        l_earliest_mpickup_date IS NOT NULL) AND
       (l_latest_mpickup_date < l_earliest_mpickup_date)
    THEN
        --
        --exception will be logged per Jeff's email on 08/05/2004
        --if the user does not want it, they can change the exception to information only
        --and avoid the warnings
        log_tpdate_exception('DLVY',l_delivery_id,TRUE,l_earliest_mpickup_date,l_latest_mpickup_date);
        l_latest_mpickup_date := l_earliest_mpickup_date;
        --
    END IF;
    --
    IF (l_latest_mdropoff_date IS NOT NULL AND
        l_earliest_mdropoff_date  IS NOT NULL) AND
       (l_latest_mdropoff_date < l_earliest_mdropoff_date)
    THEN
        --
        log_tpdate_exception('DLVY',l_delivery_id,FALSE,l_earliest_mdropoff_date,l_latest_mdropoff_date);
        l_latest_mdropoff_date := l_earliest_mdropoff_date;
        --
    END IF;
    --
   OPEN is_inbound_dropshp(l_delivery_id);
   FETCH is_inbound_dropshp INTO l_shp_dir;
   IF is_inbound_dropshp%NOTFOUND THEN
      l_shp_dir := NULL;
   END IF;
   CLOSE is_inbound_dropshp;

    IF l_del_date_calc_method = 'S' AND l_shp_dir IS NULL THEN
      --{

      --
      OPEN max_min_om_deltp_dates(l_delivery_id);
      FETCH max_min_om_deltp_dates INTO
            l_max_schedule_date, l_min_schedule_date,
            l_min_request_date, l_max_request_date;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'l_max_schedule_date', l_max_schedule_date);
        WSH_DEBUG_SV.log(l_module_name, 'l_min_schedule_date', l_min_schedule_date);
        WSH_DEBUG_SV.log(l_module_name, 'l_min_request_date', l_min_request_date);
        WSH_DEBUG_SV.log(l_module_name, 'l_max_request_date', l_max_request_date);
      END IF;
      --
      IF max_min_om_deltp_dates%FOUND THEN
        --{
        --
        l_initial_mpickup_date := l_max_schedule_date;
        --
        IF (l_min_request_date IS NOT NULL AND
            l_min_schedule_date  IS NOT NULL) THEN
           --{
           IF (l_min_request_date > l_min_schedule_date) THEN
            l_ultimate_mdropoff_date := l_min_request_date ;
           ELSE
            l_ultimate_mdropoff_date := l_min_schedule_date;
           END IF;
           --}
        END IF;
        --
        IF l_min_request_date IS NULL  THEN
          l_ultimate_mdropoff_date := l_min_schedule_date;
        END IF;
        --
        IF l_min_schedule_date IS NULL  THEN
          l_ultimate_mdropoff_date := l_min_request_date ;
        END IF;
        --}
      ELSE
        --
        l_initial_mpickup_date   := NULL;
        l_ultimate_mdropoff_date := NULL;
        --
      END IF;
      --}
    ELSE /* Delivery Date calc method is E  and line direction is inbound or drop ship*/
      --{
      l_initial_mpickup_date   := l_earliest_mpickup_date;
      l_ultimate_mdropoff_date := l_latest_mdropoff_date;
      --
      -- Bug 3451919  - if the initial or ultimate dates are null, use the default option for calculation
      -- For IPD (if null), calculate using schedule date only for outbound
       IF l_shp_dir IS NULL AND (l_initial_mpickup_date IS NULL) THEN
       --{
       l_initial_mpickup_date := l_max_detSch_date;
       --
       --}
      END IF;
      IF (l_ultimate_mdropoff_date IS NULL) THEN
       --{
       l_ultimate_mdropoff_date := GREATEST(l_min_detReq_date,
                                            l_min_detSch_date);
       --
       --}
      END IF;
      --}
    END IF;

    IF l_ultimate_mdropoff_date < l_initial_mpickup_date OR
       l_ultimate_mdropoff_date IS NULL THEN
        --
       l_ultimate_mdropoff_date := l_initial_mpickup_date;
        --
    END IF;
    --
    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name, 'l_initial_mpickup_date', l_initial_mpickup_date );
       WSH_DEBUG_SV.log(l_module_name, 'l_ultimate_mdropoff_date', l_ultimate_mdropoff_date);
       WSH_DEBUG_SV.log(l_module_name, 'GC3_IS_INSTALLED', l_gc3_is_installed);
    END IF;
    --

    OPEN get_delivery_for_lock(l_delivery_id); -- BugFix 3570954
    FETCH get_delivery_for_lock INTO l_delivery_rec; -- BugFix 3570954

    --OTM R12, check for tms update
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Ignore for Planning:',l_delivery_rec.ignore_for_planning);
    END IF;
    IF l_gc3_is_installed = 'Y' AND
       NVL(l_delivery_rec.ignore_for_planning, 'N') = 'N' THEN--{

      l_tms_update         := 'N';
      l_trip_not_found     := 'N';
      l_tms_version_number := 1;
      --l_sysdate            := TO_CHAR(SYSDATE,'DD-MON-RRRR HH24:MI:SS');
      l_delivery_info_tab.DELETE;
      --l_new_interface_flag_tab.DELETE;

      --get trip information for delivery, no update when trip not OPEN
      WSH_DELIVERY_VALIDATIONS.get_trip_information
        (p_delivery_id     => l_delivery_id,
         x_trip_info_rec   => l_trip_info_rec,
         x_return_status   => l_return_status);

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'Return Status after WSH_DELIVERY_VALIDATIONS.get_trip_information', l_return_status);
      END IF;

      IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
        x_return_status := l_return_status;
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Error in WSH_DELIVERY_VALIDATIONS.get_trip_information');
        END IF;
        RAISE e_gc3_exception;
      END IF;

      IF (l_trip_info_rec.trip_id IS NULL) THEN
        l_trip_not_found := 'Y';
      END IF;

      -- only do changes when there's no trip or trip status is OPEN
      -- Checking for Only status_code = OP or l_trip_not_found=Y will
      -- suffice, no need for NVL or l_trip_not_found=N
      IF ((l_trip_info_rec.status_code = 'OP') OR
          (l_trip_not_found = 'Y')) THEN--{

        WSH_DELIVERY_VALIDATIONS.get_delivery_information(
          p_delivery_id   => l_delivery_id,
          x_delivery_rec  => l_delivery_info,
          x_return_status => l_return_status);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'Return Status after WSH_DELIVERY_VALIDATIONS.get_delivery_information', l_return_status);
        END IF;

        IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
          x_return_status := l_return_status;
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Error in WSH_DELIVERY_VALIDATIONS.get_delivery_information');
          END IF;
          RAISE e_gc3_exception;
        END IF;

        l_delivery_info_tab(1) := l_delivery_info;

        --checking the value differences for the relevant critical fields
        --if any of the earliest/latest dates are changed and delivery is include for planning, then
        --update is needed
        IF (nvl(l_delivery_info.EARLIEST_PICKUP_DATE, fnd_api.g_miss_date) <> nvl(l_earliest_mpickup_date, fnd_api.g_miss_date) OR
             nvl(l_delivery_info.LATEST_PICKUP_DATE, fnd_api.g_miss_date) <> nvl(l_latest_mpickup_date, fnd_api.g_miss_date) OR
             nvl(l_delivery_info.EARLIEST_DROPOFF_DATE, fnd_api.g_miss_date) <> nvl(l_earliest_mdropoff_date, fnd_api.g_miss_date) OR
             nvl(l_delivery_info.LATEST_DROPOFF_DATE, fnd_api.g_miss_date) <> nvl(l_latest_mdropoff_date, fnd_api.g_miss_date)
           ) THEN--{

          IF (NVL(l_delivery_info.tms_interface_flag, WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT) IN
            (WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT,
             WSH_NEW_DELIVERIES_PVT.C_TMS_CREATE_REQUIRED,
             WSH_NEW_DELIVERIES_PVT.C_TMS_DELETE_REQUIRED,
             WSH_NEW_DELIVERIES_PVT.C_TMS_DELETE_IN_PROCESS,
             WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_REQUIRED)) THEN
            l_tms_update := 'N';
          ELSE
            l_tms_update := 'Y';
            l_new_interface_flag_tab(1) :=  WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_REQUIRED;
            l_tms_version_number := NVL(l_delivery_info.tms_version_number, 1) + 1;
          END IF;
        ELSE
          l_tms_update := 'N';
        END IF;--}
      END IF; --}
    END IF; --}

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_tms_update flag', l_tms_update);
    END IF;
    --END OTM R12

    UPDATE WSH_NEW_DELIVERIES
    SET  earliest_pickup_date = l_earliest_mpickup_date,
         earliest_dropoff_date = l_earliest_mdropoff_date,
         latest_pickup_date = l_latest_mpickup_date,
         latest_dropoff_date =  l_latest_mdropoff_date,
         initial_pickup_date = l_initial_mpickup_date,
         ultimate_dropoff_date = l_ultimate_mdropoff_date,
         --OTM R12, glog proj
        TMS_INTERFACE_FLAG = DECODE(l_tms_update,
                                     'Y', l_new_interface_flag_tab(1),
                                     NVL(TMS_INTERFACE_FLAG, WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT)),
        TMS_VERSION_NUMBER = DECODE(l_tms_update,
                                     'Y', l_tms_version_number,
                                     NVL(tms_version_number, 1)),
         --
         last_update_date      = sysdate,
         last_updated_by       = FND_GLOBAL.USER_ID,
         last_update_login     = FND_GLOBAL.LOGIN_ID
    WHERE delivery_id = l_delivery_id;

    --OTM R12
    IF (l_gc3_is_installed = 'Y' AND l_tms_update = 'Y') THEN--{

      WSH_XC_UTIL.log_otm_exception(
        p_delivery_info_tab      => l_delivery_info_tab,
        p_new_interface_flag_tab => l_new_interface_flag_tab,
        x_return_status          => l_return_status);

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_return_status after log_otm_exception', l_return_status);
      END IF;

      IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
        x_return_status := l_return_status;
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Error in WSH_XC_UTIL.log_otm_exception');
        END IF;
        RAISE e_gc3_exception;
      END IF;
    END IF;--}
    --

    IF get_delivery_for_lock%ISOPEN THEN
      CLOSE get_delivery_for_lock; -- BugFix 3570954
    END IF;

    --
    IF max_min_det_deltp_dates%ISOPEN THEN
      CLOSE max_min_det_deltp_dates;
    END IF;
    --
    IF max_min_om_deltp_dates%ISOPEN THEN
      CLOSE max_min_om_deltp_dates;
    END IF;
    --}
  END LOOP;
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  EXCEPTION
    WHEN e_gc3_exception THEN
      -- OTM R12, glog proj, Close the cursors which are OPEN
      IF get_delivery_for_lock%ISOPEN THEN
        CLOSE get_delivery_for_lock;
      END IF;

      IF max_min_det_deltp_dates%ISOPEN THEN
        CLOSE max_min_det_deltp_dates;
      END IF;

      IF max_min_om_deltp_dates%ISOPEN THEN
        CLOSE max_min_om_deltp_dates;
      END IF;

      IF is_inbound_dropshp%ISOPEN THEN
        CLOSE is_inbound_dropshp;
      END IF;

      -- The APIs which errored out would have set appropriate message
      x_return_status := WSH_UTIL_CORE.g_ret_sts_error;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Error Calculating TP Dates');
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;

    WHEN lock_detected THEN -- BugFix 3570954

      -- OTM R12, glog proj, Close the cursors which are OPEN
      IF get_delivery_for_lock%ISOPEN THEN
        CLOSE get_delivery_for_lock;
      END IF;

      IF max_min_det_deltp_dates%ISOPEN THEN
        CLOSE max_min_det_deltp_dates;
      END IF;

      IF max_min_om_deltp_dates%ISOPEN THEN
        CLOSE max_min_om_deltp_dates;
      END IF;

      IF is_inbound_dropshp%ISOPEN THEN
        CLOSE is_inbound_dropshp;
      END IF;

      FND_MESSAGE.SET_NAME('WSH','WSH_NO_LOCK');
      x_return_status := WSH_UTIL_CORE.g_ret_sts_error;
      wsh_util_core.add_message(WSH_UTIL_CORE.g_ret_sts_error,l_module_name);

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Cannot lock delivery for update',l_delivery_id);
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;

    WHEN OTHERS THEN
      -- OTM R12, glog proj, Close the cursors which are OPEN
      IF get_delivery_for_lock%ISOPEN THEN
        CLOSE get_delivery_for_lock;
      END IF;

      IF max_min_det_deltp_dates%ISOPEN THEN
        CLOSE max_min_det_deltp_dates;
      END IF;

      IF max_min_om_deltp_dates%ISOPEN THEN
        CLOSE max_min_om_deltp_dates;
      END IF;

      IF is_inbound_dropshp%ISOPEN THEN
        CLOSE is_inbound_dropshp;
      END IF;

      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.DEFAULT_HANDLER(
                        'WSH_TP_RELEASE.calculate_del_tpdates',
                        l_module_name);

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;

END calculate_del_tpdates;

/**
*  refresh_lpn_hierarchy_dates calculates TPdates for the Containers.
*  l_lpndetail_ids is the list of containers or items of containers for the which container tpdates
*  have to be calculated or recalculated
*  The LPN dates ripple upwards, So all the outer contaniers tpdates are recalculated.
*/
PROCEDURE refresh_lpn_hierarchy_dates(l_lpndetail_ids IN wsh_util_core.id_tab_type,
                                      x_upd_del_tab   OUT NOCOPY wsh_util_core.id_tab_type,
                                      x_return_status OUT NOCOPY VARCHAR2) IS

  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'refresh_lpn_hierarchy_dates';
  --
  l_debug_on BOOLEAN;
  --
  l_detail_tab                 WSH_UTIL_CORE.id_tab_type;
  l_container_flag    VARCHAR(2);
  --Added for bug 5234326
  l_updated_flag      VARCHAR2(1);
  l_delivery_id       NUMBER;


  CURSOR Outer_LPNS(p_delivery_detail_id IN NUMBER) IS
  SELECT parent_delivery_detail_id
	 FROM wsh_delivery_assignments_v
	 START WITH delivery_detail_id = p_delivery_detail_id
	 CONNECT BY PRIOR parent_delivery_detail_id = delivery_detail_id;

  CURSOR isContainer(p_delivery_detail_id IN NUMBER) IS
    SELECT Container_flag
    FROM wsh_delivery_details
    WHERE delivery_detail_id = p_delivery_detail_id;

  OTHERS EXCEPTION;
BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  --
  --

  FOR i IN 1..l_lpndetail_ids.count LOOP
    -- The Input Deilvery_Detail_Id
   IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'Input Container', l_lpndetail_ids(i));
   END IF;
   calculate_lpn_tpdates(p_delivery_detail_id=> l_lpndetail_ids(i),
                          x_updated_flag=> l_updated_flag,
                          x_delivery_id => l_delivery_id,
                          x_return_status=> x_return_status);
    IF x_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
      raise OTHERS;
    END IF;

    --Added for bug 5234326
    IF ( l_updated_flag = 'Y' ) THEN

      -- Outer Containers
      OPEN Outer_LPNS(l_lpndetail_ids(i));
      FETCH Outer_LPNS BULK COLLECT INTO l_detail_tab;
      CLOSE Outer_LPNS;
      IF l_detail_tab.count > 0 THEN
        FOR j IN  l_detail_tab.FIRST..l_detail_tab.LAST  LOOP
          IF l_detail_tab(j) IS NOT NULL THEN
            -- Removed Container Flag check for bug 5234326
            IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name, 'Outer', l_detail_tab(j));
            END IF;
            calculate_lpn_tpdates(p_delivery_detail_id=> l_detail_tab(j),
                                x_delivery_id => l_delivery_id,
                                x_updated_flag=> l_updated_flag,
                                x_return_status=> x_return_status);
            IF x_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
              raise OTHERS;
            END IF;
            IF (l_updated_flag = 'N') THEN
              EXIT;
            END IF;
          END IF;
        END LOOP;
      -- Outer Containers
      END IF;
    END IF;

    IF (l_delivery_id is not null) THEN
       x_upd_del_tab(x_upd_del_tab.COUNT+1) := l_delivery_id;
    END IF;

  END LOOP;
  --
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.DEFAULT_HANDLER(
                        'WSH_TP_RELEASE.refresh_lpn_hierarchy_dates',
                        l_module_name);

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END refresh_lpn_hierarchy_dates;

/**
*  calculate_lpn_tpdates calculates TPdates for the Container.
*  p_delivery_detail_id is the continer for which tpdates ids calculated
*/
PROCEDURE calculate_lpn_tpdates(p_delivery_detail_id NUMBER,
                                x_updated_flag  OUT NOCOPY VARCHAR2,
                                x_delivery_id   OUT NOCOPY NUMBER,
                                x_return_status OUT NOCOPY VARCHAR2) IS

  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'calculate_lpn_tpdates';
  --
  l_debug_on BOOLEAN;
  --

  l_earliest_mpickup_date DATE;
  l_earliest_mdropoff_date DATE;
  l_latest_mpickup_date DATE;
  l_latest_mdropoff_date DATE;
  l_delivery_detail_id NUMBER;



  CURSOR max_min_tp_dates(c_delivery_detail_id IN NUMBER)     IS
        SELECT max(earliest_pickup_date),max(earliest_dropoff_date),min(latest_pickup_date),min(latest_dropoff_date)
        FROM wsh_delivery_assignments_v wda,wsh_delivery_details wdd
        WHERE wda.delivery_detail_id = wdd.delivery_detail_id
         AND parent_delivery_detail_id =  c_delivery_detail_id;

   -- K LPN CONV. rv
   l_wms_org          VARCHAR2(10) := 'N';
   l_sync_tmp_rec     wsh_glbl_var_strct_grp.sync_tmp_rec_type;
   l_line_direction   VARCHAR2(10);
   l_organization_id  NUMBER;
   l_cnt_flag         VARCHAR2(10);
   l_return_status    VARCHAR2(10);
   -- K LPN CONV. rv



BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  --
  --
 OPEN max_min_tp_dates(p_delivery_detail_id);
 FETCH max_min_tp_dates INTO l_earliest_mpickup_date,l_earliest_mdropoff_date,l_latest_mpickup_date,l_latest_mdropoff_date;
  IF max_min_tp_dates%FOUND THEN
    IF(l_latest_mpickup_date IS NOT NULL AND l_earliest_mpickup_date IS NOT NULL) AND
        (l_latest_mpickup_date < l_earliest_mpickup_date)
     THEN
      log_tpdate_exception('LPN',p_delivery_detail_id,TRUE,l_earliest_mpickup_date,l_latest_mpickup_date);
      l_latest_mpickup_date := l_earliest_mpickup_date;
     END IF;
     IF (l_latest_mdropoff_date IS NOT NULL AND  l_earliest_mdropoff_date  IS NOT NULL) AND
          (l_latest_mdropoff_date < l_earliest_mdropoff_date)
     THEN
      log_tpdate_exception('LPN',p_delivery_detail_id,FALSE,l_earliest_mdropoff_date,l_latest_mdropoff_date);
      l_latest_mdropoff_date := l_earliest_mdropoff_date;
    END IF;
  ELSE
    l_earliest_mpickup_date   := NULL;
    l_earliest_mdropoff_date  := NULL;
    l_latest_mpickup_date     := NULL;
    l_latest_mdropoff_date    := NULL;
  END IF;

    -- Bug 5234326: Update TP dates in WDD only if there is a change
  UPDATE WSH_DELIVERY_DETAILS
  SET  earliest_pickup_date = l_earliest_mpickup_date,
       earliest_dropoff_date = l_earliest_mdropoff_date,
       latest_pickup_date = l_latest_mpickup_date,
       latest_dropoff_date =  l_latest_mdropoff_date,
       last_update_date      = sysdate,
       last_updated_by       = FND_GLOBAL.USER_ID
  WHERE delivery_detail_id = p_delivery_detail_id
  AND   ( nvl(earliest_pickup_date, sysdate)  <> nvl(l_earliest_mpickup_date, sysdate)
       OR nvl(earliest_dropoff_date, sysdate) <> nvl(earliest_dropoff_date, sysdate)
       OR nvl(latest_pickup_date, sysdate)    <> nvl(latest_pickup_date, sysdate)
       OR nvl(latest_dropoff_date, sysdate)   <> nvl(latest_dropoff_date, sysdate) );
  IF ( SQL%ROWCOUNT > 0 ) THEN
    x_updated_flag := 'Y';
  ELSE
    x_updated_flag := 'N';
    x_delivery_id  := NULL;
  END IF;
  IF max_min_tp_dates%ISOPEN  THEN
    CLOSE max_min_tp_dates;
  END IF;


  -- LPN CONV. rv
  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'l_cnt_flag', l_cnt_flag);
     WSH_DEBUG_SV.log(l_module_name, 'l_organization_id', l_organization_id);
     WSH_DEBUG_SV.log(l_module_name, 'l_line_direction', l_line_direction);
  END IF;
  --
  IF (l_cnt_flag = 'Y' and nvl(l_line_direction,'O') in ('O', 'IO'))
  AND WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
  THEN
  --{
      l_wms_org := wsh_util_validate.check_wms_org(l_organization_id);
      IF (WSH_WMS_LPN_GRP.GK_WMS_UPD_DATE and l_wms_org = 'Y')
        OR
        (WSH_WMS_LPN_GRP.GK_INV_UPD_DATE and l_wms_org = 'N')
      THEN
      --{
          --
          l_sync_tmp_rec.delivery_detail_id := p_delivery_detail_id;
          l_sync_tmp_rec.operation_type := 'UPDATE';
          --
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WMS_SYNC_TMP_PKG.MERGE',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          WSH_WMS_SYNC_TMP_PKG.MERGE
          (
            p_sync_tmp_rec      => l_sync_tmp_rec,
            x_return_status     => x_return_status
          );

          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
          END IF;
          --
          IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Error occured in WSH_WMS_SYNC_TMP_PKG.MERGE');
              WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            return;
          END IF;
          --
      --}
      END IF;
  --}
  END IF;
  --
  -- LPN CONV. rv
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.DEFAULT_HANDLER(
                        'WSH_TP_RELEASE.calculate_lpn_tpdates(delivery_id)',
                        l_module_name);

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END calculate_lpn_tpdates;

PROCEDURE log_tpdate_exception(p_entity VARCHAR2,
                               p_entity_id NUMBER,
                               p_pick_up BOOLEAN,
                               early_date DATE,
                               latest_date DATE
                              ) IS

    CURSOR c_det_location_id(p_delivery_detail_id IN NUMBER)      IS
        SELECT ship_from_location_id
        FROM wsh_delivery_details wdd
        WHERE delivery_detail_id = p_delivery_detail_id;

    CURSOR c_del_location_id(p_delivery_id IN NUMBER)     IS
        SELECT wdd.ship_from_location_id
        FROM wsh_delivery_details wdd ,wsh_delivery_assignments_v wda
        WHERE wdd.delivery_detail_id = wda.delivery_detail_id
          AND delivery_id = p_delivery_id
          AND ROWNUM = 1;


l_api_version     NUMBER := 1.0;
l_return_status   VARCHAR2(1);
l_msg_count   NUMBER;
l_msg_data    VARCHAR2(6000);
l_exception_id    NUMBER;

l_validation_level      NUMBER default  FND_API.G_VALID_LEVEL_FULL;


l_exception_message1     varchar2(2000);
l_exception_message2     varchar2(2000);
l_exception_message     varchar2(2000);
l_exception_name        varchar2(30);

l_location_id           NUMBER;
l_logging_entity        VARCHAR2(50);

BEGIN


l_exception_name    := 'WSH_INVALID_TPDATES';
l_logging_entity    := 'SHIPPER';

IF p_pick_up THEN
       FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_TPDATES_SHIP');
       FND_MESSAGE.SET_TOKEN('EARLIEST', FND_DATE.DATE_TO_CANONICAL(early_date));
       FND_MESSAGE.SET_TOKEN('LATEST', FND_DATE.DATE_TO_CANONICAL(latest_date));
       l_exception_message := FND_MESSAGE.GET;
ELSE
       FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_TPDATES_DELIVERY');
       FND_MESSAGE.SET_TOKEN('EARLIEST', FND_DATE.DATE_TO_CANONICAL(early_date));
       FND_MESSAGE.SET_TOKEN('LATEST', FND_DATE.DATE_TO_CANONICAL(latest_date));
       l_exception_message := FND_MESSAGE.GET;
END IF;

  IF p_entity = 'DLVY' THEN

    OPEN c_del_location_id(p_entity_id);
    FETCH c_del_location_id INTO l_location_id;
    CLOSE c_del_location_id;
    IF l_location_id IS NOT NULL THEN
      WSH_XC_UTIL.log_exception(
            p_api_version            => l_api_version,
            p_init_msg_list          => FND_API.G_FALSE,
            p_commit                 => FND_API.G_FALSE,
            p_validation_level       => l_validation_level,
            x_return_status          => l_return_status,
            x_msg_count              => l_msg_count,
            x_msg_data               => l_msg_data,
            x_exception_id           => l_exception_id,
            p_exception_location_id  => l_location_id,
            p_logged_at_location_id  => l_location_id,
            p_logging_entity         => l_logging_entity,
            p_logging_entity_id      => FND_GLOBAL.USER_ID,
            p_exception_name         => l_exception_name,
            p_message                => l_exception_message,
            p_delivery_id            => p_entity_id,
            p_delivery_name          => to_char(p_entity_id)
      );
    END IF;
  ELSIF p_entity IN ('LPN','LINE') THEN
    OPEN c_det_location_id(p_entity_id);
    FETCH c_det_location_id INTO l_location_id;
    CLOSE c_det_location_id;
    IF l_location_id IS NOT NULL THEN
      WSH_XC_UTIL.log_exception(
        p_api_version            => l_api_version,
        p_init_msg_list          => FND_API.G_FALSE,
        p_commit                 => FND_API.G_FALSE,
        p_validation_level       => l_validation_level,
        x_return_status          => l_return_status,
        x_msg_count              => l_msg_count,
        x_msg_data               => l_msg_data,
        x_exception_id           => l_exception_id,
        p_exception_location_id  => l_location_id,
        p_logged_at_location_id  => l_location_id,
        p_logging_entity         => l_logging_entity,
        p_logging_entity_id      => FND_GLOBAL.USER_ID,
        p_exception_name         => l_exception_name,
        p_message                => l_exception_message,
        p_delivery_detail_id     => p_entity_id
      );
    END IF;
  END IF;


END log_tpdate_exception;

/**
*  Check_Shipset_Ignoreflag Checks if the p_delivery_detail_id ignore_for_planning
*  is different from other lines ignore_for_palnning which are in same ship set.
*  If so exception is logged if p_logexcep is True otherwise warinig message is thrown.
*/
PROCEDURE Check_Shipset_Ignoreflag( p_delivery_detail_ids wsh_util_core.id_tab_type,
                                    p_ignore_for_planning VARCHAR2,
                                    p_logexcep boolean,
                                    x_return_status OUT NOCOPY VARCHAR2) IS

  CURSOR c_check_ignore_for_planning(c_delivery_detail_id NUMBER) IS
  SELECT   wdd.ignore_for_planning,a.ship_from_location_id
  FROM     wsh_delivery_details wdd ,
          (SELECT  source_code,source_header_id,ship_set_id,ship_from_location_id
           FROM wsh_delivery_details
           WHERE  delivery_detail_id = c_delivery_detail_id) a
  WHERE
      wdd.delivery_detail_id <>  c_delivery_detail_id	  AND
      nvl(wdd.ignore_for_planning,'N') <> p_ignore_for_planning AND
      wdd.ship_set_id = a.ship_set_id AND
      wdd.source_header_id = a.source_header_id AND
      wdd.source_code= a.source_code  AND
      rownum <= 1;


  l_api_version     NUMBER := 1.0;
  l_src_hdr_id NUMBER;
	l_ship_set_id NUMBER;
  l_src_code VARCHAR(5);
  l_delivery_detail_id NUMBER;
  l_exception_message     varchar2(2000);
  l_exception_name        varchar2(30);
  l_exception_id          NUMBER;
  l_location_id           NUMBER;
  l_logging_entity        VARCHAR2(50);
  l_validation_level      NUMBER default  FND_API.G_VALID_LEVEL_FULL;
  l_msg_count             NUMBER;
  l_msg_data    VARCHAR2(200);
  l_ignore_for_planning   VARCHAR2 (1);
  l_return_status VARCHAR2(1);
  others EXCEPTION;

  --
  l_debug_on               BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Check_Shipset_Ignoreflag';
  --
  BEGIN

    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    IF l_debug_on IS NULL THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;

    IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name,'p_ignore_for_planning',p_ignore_for_planning);
      WSH_DEBUG_SV.log(l_module_name,'p_logexcep',p_logexcep);
    END IF;

    l_exception_name    := 'WSH_SHPST_IGNRE_FR_PLNG';
    l_logging_entity    := 'SHIPPER';
    FOR j IN p_delivery_detail_ids.FIRST..p_delivery_detail_ids.LAST LOOP
      l_delivery_detail_id :=p_delivery_detail_ids(j);
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_delivery_detail_id',l_delivery_detail_id);
      END IF;
      OPEN c_check_ignore_for_planning(l_delivery_detail_id);
      FETCH c_check_ignore_for_planning INTO l_ignore_for_planning,l_location_id;
      IF c_check_ignore_for_planning%FOUND THEN
        IF p_logexcep THEN
          -- LOG EXCEPTION
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Log exception l_location_id',l_location_id);
          END IF;
          IF l_location_id IS NOT NULL THEN
            FND_MESSAGE.SET_NAME('WSH','WSH_SHIPSET_IGNORE_FOR_PLANG');
            FND_MESSAGE.SET_TOKEN('ENTITY',l_delivery_detail_id);
            l_exception_message := FND_MESSAGE.GET;
            WSH_XC_UTIL.log_exception(
              p_api_version            => l_api_version,
              p_init_msg_list          => FND_API.G_FALSE,
              p_commit                 => FND_API.G_FALSE,
              p_validation_level       => l_validation_level,
              x_return_status          => l_return_status,
              x_msg_count              => l_msg_count,
              x_msg_data               => l_msg_data,
              x_exception_id           => l_exception_id,
              p_exception_location_id  => l_location_id,
              p_logged_at_location_id  => l_location_id,
              p_logging_entity         => l_logging_entity,
              p_logging_entity_id      => FND_GLOBAL.USER_ID,
              p_exception_name         => l_exception_name,
              p_message                => l_exception_message,
              p_delivery_detail_id     => l_delivery_detail_id
            );
          END IF;
          IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
             x_return_status := l_return_status;
            raise OTHERS;
          END IF;
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'L_EXCEPTION_ID',L_EXCEPTION_ID);
            WSH_DEBUG_SV.log(l_module_name,'x_return_status',l_return_status);
          END IF;
        ELSE
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Log waring l_delivery_detail_id',l_delivery_detail_id);
          END IF;
          x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
          FND_MESSAGE.SET_NAME('WSH','WSH_SHIPSET_IGNORE_FOR_PLANG');
          FND_MESSAGE.SET_TOKEN('ENTITY',l_delivery_detail_id);
          wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_WARNING,l_module_name);
        END IF;
      END IF;
      CLOSE c_check_ignore_for_planning;
    END LOOP;
  --
  --
  IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  EXCEPTION
    WHEN OTHERS THEN
    IF c_check_ignore_for_planning%ISOPEN THEN
        CLOSE c_check_ignore_for_planning;
    END IF;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    wsh_util_core.default_handler('WSH_TP_RELEASE.Check_Shipset_Ignoreflag');
    --
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| x_return_status||SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END Check_Shipset_Ignoreflag;

PROCEDURE Check_Shipset_Ignoreflag( p_delivery_detail_id NUMBER,
                                    p_ignore_for_planning VARCHAR2,
                                    p_logexcep boolean,
                                    x_return_status OUT NOCOPY VARCHAR2) IS

p_delivery_detail_ids wsh_util_core.id_tab_type;

BEGIN
  p_delivery_detail_ids(0) := p_delivery_detail_id;
  Check_Shipset_Ignoreflag( p_delivery_detail_ids=>p_delivery_detail_ids,
                            p_ignore_for_planning=>p_ignore_for_planning,
                            p_logexcep=>p_logexcep,
                            x_return_status=>x_return_status );
END Check_Shipset_Ignoreflag;


END WSH_TP_RELEASE;

/
