--------------------------------------------------------
--  DDL for Package Body WSH_INTERFACE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_INTERFACE_GRP" as
/* $Header: WSHINGPB.pls 120.6 2007/11/16 06:32:22 sankarun noship $ */


--===================
-- CONSTANTS
--===================
G_PKG_NAME CONSTANT VARCHAR2(30) := 'WSH_INTERFACE_GRP';
-- add your constants here if any
--===================
-- PUBLIC VARS
--===================


PROCEDURE Rtrim_deliveries_action (
             p_in_rec  IN  WSH_DELIVERIES_GRP.action_parameters_rectype,
             p_out_rec OUT NOCOPY  WSH_DELIVERIES_GRP.action_parameters_rectype) IS
  l_debug_on BOOLEAN;
  l_module_name 		CONSTANT VARCHAR2(100) := 'wsh.plsql.' ||
                            G_PKG_NAME || '.' || 'Rtrim_deliveries_action';
BEGIN

   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      wsh_debug_sv.push (l_module_name, 'Rtrim_deliveries_action');
   END IF;

   p_out_rec := p_in_rec;

   p_out_rec.caller      := RTRIM(p_in_rec.caller);
   p_out_rec.action_code   := RTRIM(p_in_rec.action_code);
   p_out_rec.trip_name   := RTRIM(p_in_rec.trip_name);
   p_out_rec.pickup_loc_code := RTRIM(p_in_rec.pickup_loc_code);
   p_out_rec.pickup_stop_status := RTRIM(p_in_rec.pickup_stop_status);
   p_out_rec.dropoff_loc_code  := RTRIM(p_in_rec.dropoff_loc_code);
   p_out_rec.dropoff_stop_status:= RTRIM(p_in_rec.dropoff_stop_status);
   p_out_rec.action_flag   := RTRIM(p_in_rec.action_flag);
   p_out_rec.intransit_flag    := RTRIM(p_in_rec.intransit_flag);
   p_out_rec.close_trip_flag  := RTRIM(p_in_rec.close_trip_flag);
   --p_out_rec.create_bol_flag   := RTRIM(p_in_rec.create_bol_flag);
   p_out_rec.stage_del_flag    := RTRIM(p_in_rec.stage_del_flag);
   p_out_rec.bill_of_lading_flag := RTRIM(p_in_rec.bill_of_lading_flag);
   p_out_rec.override_flag   := RTRIM(p_in_rec.override_flag);
   p_out_rec.defer_interface_flag  := RTRIM(p_in_rec.defer_interface_flag);
   p_out_rec.ship_method_code:= RTRIM(p_in_rec.ship_method_code);
   p_out_rec.report_set_name:= RTRIM(p_in_rec.report_set_name);
   p_out_rec.send_945_flag  := RTRIM(p_in_rec.send_945_flag);
   p_out_rec.sc_rule_name:= RTRIM(p_in_rec.sc_rule_name);
   p_out_rec.action_type   := RTRIM(p_in_rec.action_type);
   p_out_rec.document_type:= RTRIM(p_in_rec.document_type);
   p_out_rec.reason_of_transport := RTRIM(p_in_rec.reason_of_transport);
   p_out_rec.description   := RTRIM(p_in_rec.description);

   IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;

EXCEPTION

   WHEN OTHERS THEN
      wsh_util_core.default_handler (
        'WSH_TRIP_STOPS_GRP.Rtrim_deliveries_action', l_module_name);
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured.'||
         ' Oracle error message is '|| SQLERRM,
                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;
      RAISE;

END Rtrim_deliveries_action;



--========================================================================
-- PROCEDURE : Derive_sc_rule_details         Internal API
--
-- Keep this a Local API for now
-- Ship Confirm Rule can be used from 11.5.10 onwards to Confirm a delivery
-- If Ship Confirm Rule is specified, derive all details from the Rule
-- If the delivery is not the last open on the trip, then trip options
-- should be ignored, this check should already be there in Group API
-- Ship Confirm Rule will not be picked by itself as it becomes in UI for
-- deliveries belonging to same Organizations.(we use rule specified in
-- Shipping Parameters).
-- User specified Ship Method,Report Set will also be ignored while using
-- SC Rule defaults
--========================================================================
PROCEDURE derive_sc_rule_details(p_rule_id         IN            NUMBER,
                                 p_rule_name       IN            VARCHAR2,
                                 p_delivery_id_tab IN            wsh_util_core.id_tab_type,
                                 x_out_params      IN OUT NOCOPY WSH_DELIVERIES_GRP.action_parameters_rectype,
                                 x_return_status      OUT NOCOPY VARCHAR2) IS

-- Use Ship Confirm Rule for the Organization
-- Also, get the default values for the Rule
-- actual_dep_date_default is not used
-- Send_945 is no longer used

  CURSOR get_sc_rule (p_rule_id NUMBER,p_rule_name VARCHAR2) IS
  SELECT wsc.name,
         wsc.ship_confirm_rule_id,
         wsc.ac_intransit_flag,
         wsc.ac_close_trip_flag,
         wsc.ac_bol_flag,
         wsc.ac_defer_interface_flag,
         wsc.report_set_id,
         NVL(wsc.ship_method_default_flag, 'R'),  -- frontport bug 4310141
         wsc.ship_method_code,
         wsc.effective_end_date,
         wsc.stage_del_flag,
         wsc.action_flag
    FROM wsh_ship_confirm_rules wsc
    WHERE ((p_rule_id IS NOT NULL AND wsc.ship_confirm_rule_id = p_rule_id)
          OR (p_rule_name IS NOT NULL AND wsc.name = p_rule_name))
      AND (sysdate between wsc.effective_start_date
               and nvl(wsc.effective_end_date,sysdate));

  -- Derive Report Set Name
  CURSOR Report_Set (p_report_set_id NUMBER) IS
  SELECT rs.name
  FROM wsh_report_sets rs
  WHERE rs.report_set_id = p_report_set_id;

  --frontport bug 4310141: check trip or delivery to default ship method.

  CURSOR Check_Trip (l_delivery_id NUMBER) IS
  select wts.trip_id
  from   wsh_delivery_legs wdl,
         wsh_trip_stops wts
  where  wdl.pick_up_stop_id = wts.stop_id
  and    wdl.delivery_id     = l_delivery_id
  and    rownum=1;

  CURSOR delivery_ship_method (l_delivery_id NUMBER) IS
  SELECT ship_method_code
  FROM   wsh_new_deliveries
  WHERE  delivery_id = l_delivery_id;

  -- Bug 4103142 - to get first trip for delivery
  CURSOR c_first_ship_method (p_delivery_id IN number)IS
  SELECT  wt.ship_method_code
  FROM    wsh_new_deliveries del,
          wsh_delivery_legs dlg,
          wsh_trip_stops st,
          wsh_trips wt
  WHERE   del.delivery_id                 = dlg.delivery_id
  AND     dlg.pick_up_stop_id             = st.stop_id
  AND     del.initial_pickup_location_id  = st.stop_location_id
  AND     st.trip_id                      = wt.trip_id
  AND     del.delivery_id                 = p_delivery_id
  AND     rownum = 1 ;

  l_sc_rule                  VARCHAR2(30);
  l_sc_rule_id               NUMBER;
  l_ac_intransit_flag        VARCHAR2(1);
  l_ac_close_flag            VARCHAR2(1);
  l_ac_bol_flag              VARCHAR2(1);
  l_ac_defer_interface_flag  VARCHAR2(1);
  l_report_set_id            NUMBER;
  l_ship_method_default_flag VARCHAR2(1);
  l_ship_method_code         VARCHAR2(30);
  l_effective_end_date       DATE;
  l_stage_del_flag           VARCHAR2(1);
  l_action_flag              VARCHAR2(1);

  l_trip_id               NUMBER;
  l_dist_ship_method_code VARCHAR2(30);
  l_temp_ship_method_code VARCHAR2(30);
  l_first_ship_method     BOOLEAN;

  l_api_version_number    CONSTANT NUMBER := 1.0;
  l_api_name              CONSTANT VARCHAR2(30) := 'derive_sc_rule_details';
  l_debug_on BOOLEAN;
  l_module_name           CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DERIVE_SC_RULE_DETAILS';
BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
  END IF;

  x_return_status := wsh_util_core.g_ret_sts_success;

  l_first_ship_method := TRUE;

  IF (p_rule_id IS NOT NULL OR p_rule_name IS NOT NULL) THEN
    OPEN get_sc_rule(p_rule_id,p_rule_name);
    FETCH get_sc_rule
     INTO l_sc_rule,
          l_sc_rule_id,
          l_ac_intransit_flag,
          l_ac_close_flag,
          l_ac_bol_flag,
          l_ac_defer_interface_flag,
          l_report_set_id,
          l_ship_method_default_flag,
          l_ship_method_code,
          l_effective_end_date,
          l_stage_del_flag,
          l_action_flag;

    IF get_sc_rule%NOTFOUND THEN
      fnd_message.set_name('WSH','WSH_ACTIVE_SC_RULE');
      CLOSE get_sc_rule;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'No Valid Rule found');
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      return;
    ELSE
      CLOSE get_sc_rule;
    END IF;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Ship Confirm Rule',l_sc_rule);
      WSH_DEBUG_SV.log(l_module_name,'Ship Confirm Rule id',l_sc_rule_id);
      WSH_DEBUG_SV.log(l_module_name,'In transit',l_ac_intransit_flag);
      WSH_DEBUG_SV.log(l_module_name,'Close',l_ac_close_flag);
      WSH_DEBUG_SV.log(l_module_name,'BOL flag',l_ac_bol_flag);
      WSH_DEBUG_SV.log(l_module_name,'Defer Interface flag',l_ac_defer_interface_flag);
      WSH_DEBUG_SV.log(l_module_name,'SC report set',l_report_set_id);
      WSH_DEBUG_SV.log(l_module_name,'SC ship method',l_ship_method_code);
      WSH_DEBUG_SV.log(l_module_name,'SC ship method default flag',l_ship_method_default_flag);
      WSH_DEBUG_SV.log(l_module_name,'Effective end date',l_effective_end_date);
      WSH_DEBUG_SV.log(l_module_name,'Stage Del flag',l_stage_del_flag);
      WSH_DEBUG_SV.log(l_module_name,'Action flag',l_action_flag);
    END IF;

    x_out_params.intransit_flag         := l_ac_intransit_flag;
    x_out_params.close_trip_flag        := l_ac_close_flag;
    x_out_params.report_set_id          := l_report_set_id;
    x_out_params.sc_rule_id             := l_sc_rule_id;
    x_out_params.sc_rule_name           := l_sc_rule;
    x_out_params.defer_interface_flag   := l_ac_defer_interface_flag;
    x_out_params.bill_of_lading_flag    := l_ac_bol_flag;
    x_out_params.stage_del_flag         := l_stage_del_flag;
    x_out_params.action_flag            := l_action_flag;

    IF x_out_params.report_set_id IS NOT NULL THEN
      OPEN report_set(x_out_params.report_set_id);
      FETCH report_set
       INTO x_out_params.report_set_name;
      IF report_set%NOTFOUND THEN
        x_out_params.report_set_id   := NULL;
        x_out_params.report_set_name := NULL;
        CLOSE report_set;
      ELSE
        CLOSE report_set;
      END IF;
    ELSE
      x_out_params.report_set_name := NULL;
    END IF;
  END IF;


  -- frontport bug 4319141
  -- Bug 4234111 : Derive ship method based on the Ship confirm rule's
  -- defaulting flag
  IF l_ship_method_default_flag = 'R' THEN
    x_out_params.ship_method_code := l_ship_method_code;
  ELSE
    l_dist_ship_method_code  := NULL;
    FOR i IN 1..p_delivery_id_tab.COUNT LOOP --{
      -- Find trip for the delivery
      l_trip_id := NULL;
      OPEN Check_Trip( p_delivery_id_tab (i));
      FETCH Check_Trip INTO l_trip_id;
      IF Check_Trip%NOTFOUND THEN
        l_trip_id := NULL;
      END IF;
      CLOSE Check_Trip;

      -- Check to see if Ship Method has to be set
      -- for Deliveries with Autocreate Trip
      IF (l_trip_id IS NULL) THEN --{
        OPEN delivery_ship_method (p_delivery_id_tab(i));
        FETCH delivery_ship_method INTO l_ship_method_code;
        CLOSE delivery_ship_method;
        IF l_first_ship_method THEN
           -- Initialize First Applicable Ship Method
           l_dist_ship_method_code := l_ship_method_code;
           l_first_ship_method := FALSE;
        END IF;
        l_temp_ship_method_code := l_ship_method_code;
        IF NVL(l_temp_ship_method_code,' ') <> NVL(l_dist_ship_method_code,' ') THEN
          -- Ship Methods are different for Deliveries,
          -- so Null Ship Method is returned
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Ship Methods are different');
          END IF;
          l_dist_ship_method_code := NULL;
          l_ship_method_code    := NULL;
          EXIT;
        END IF;
      END IF; --}
    END LOOP; --}

    -- Defaulted ship method from first trip if there is only a single delivery
    IF (p_delivery_id_tab.count = 1) THEN
      OPEN c_first_ship_method (p_delivery_id_tab(1));
      FETCH c_first_ship_method INTO l_temp_ship_method_code;
      IF c_first_ship_method%NOTFOUND THEN
        l_temp_ship_method_code := NULL;
      ELSE
        IF l_temp_ship_method_code IS NOT NULL THEN
          l_ship_method_code := l_temp_ship_method_code;
        END IF;
      END IF;
      CLOSE c_first_ship_method;
    END IF;
  END IF;
  x_out_params.ship_method_code := l_ship_method_code;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'x_out_params.ship_method_code', x_out_params.ship_method_code);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION

  WHEN others THEN
      wsh_util_core.default_handler('WSH_DELIVERY_LEGS_GRP.derive_sc_rule_details',l_module_name);
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;

END derive_sc_rule_details;

--========================================================================
-- PROCEDURE : Delivery_Action         Wrapper API      PUBLIC
--
-- PARAMETERS: p_api_version_number    known api version error number
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_action_prms           Record of caller, phase, action_code and other
--                                     parameters specific to the actions.
--	       p_rec_attr_tab          Table of Attributes for the delivery entity
--             x_delivery_out_rec      Record of output parameters based on the actions.
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This procedure is used to perform an action specified
--             in p_action_prms.action_code on an existing delivery identified
--             by p_rec_attr.delivery_id/p_rec_attr.name.
--========================================================================
  PROCEDURE Delivery_Action
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    p_commit                 IN   VARCHAR2 , -- default fnd_api.g_false
    p_action_prms            IN   WSH_DELIVERIES_GRP.action_parameters_rectype,
    p_delivery_id_tab        IN   wsh_util_core.id_tab_type,
    x_delivery_out_rec       OUT  NOCOPY WSH_DELIVERIES_GRP.Delivery_Action_Out_Rec_Type,
    x_return_status          OUT  NOCOPY VARCHAR2,
    x_msg_count              OUT  NOCOPY NUMBER,
    x_msg_data               OUT  NOCOPY VARCHAR2)
  IS
    --
    l_num_warnings           NUMBER := 0;
    l_num_errors             NUMBER := 0;
    l_index                  NUMBER;
    l_commit                 VARCHAR2(100) := FND_API.G_FALSE;
    l_init_msg_list          VARCHAR2(100) := FND_API.G_FALSE;
    --
    l_defaults_rec           wsh_deliveries_grp.default_parameters_rectype;
    --
    l_rec_attr_tab           wsh_new_deliveries_pvt.Delivery_Attr_Tbl_Type;
    l_action_prms            WSH_DELIVERIES_GRP.action_parameters_rectype;
    --
l_debug_on BOOLEAN;
    --
    l_module_name CONSTANT   VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELIVERY_ACTION_WRAPPER';
    --
    CURSOR l_dlvy_attr_csr( p_delivery_id IN NUMBER ) IS
    SELECT
        DELIVERY_ID
      , ORGANIZATION_ID
      , STATUS_CODE
      , PLANNED_FLAG
      , NAME
      , INITIAL_PICKUP_DATE
      , INITIAL_PICKUP_LOCATION_ID
      , ULTIMATE_DROPOFF_LOCATION_ID
      , ULTIMATE_DROPOFF_DATE
      , CUSTOMER_ID
      , INTMED_SHIP_TO_LOCATION_ID
      , SHIP_METHOD_CODE
      , DELIVERY_TYPE
      , CARRIER_ID
      , SERVICE_LEVEL
      , MODE_OF_TRANSPORT
      , shipment_direction
      , party_id
      , shipping_control
      --Added for bug 6625788
      , reason_of_transport
      , description
    FROM WSH_NEW_DELIVERIES
    WHERE delivery_id = p_delivery_id;
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
    SAVEPOINT DELIVERY_ACTION_WRAPPER_GRP;
    --
    IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name);
      wsh_debug_sv.log(l_module_name,'Caller is ', p_action_prms.caller);
      wsh_debug_sv.log(l_module_name,'Phase is ', p_action_prms.phase);
      wsh_debug_sv.log(l_module_name,'Action Code is ', p_action_prms.phase);
      wsh_debug_sv.log(l_module_name,'Total Number of Delivery Records', p_delivery_id_tab.COUNT);
    END IF;
    --
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --
    Rtrim_deliveries_action(p_action_prms,l_action_prms);

    -- For CONFIRM action, Ship Confirm Rule can be used from 11.5.10 onwards
    IF((p_action_prms.sc_rule_id IS NOT NULL OR p_action_prms.sc_rule_name IS NOT NULL)
       AND p_action_prms.action_code = 'CONFIRM') THEN
      derive_sc_rule_details(p_rule_id         => l_action_prms.sc_rule_id,
                             p_rule_name       => l_action_prms.sc_rule_name,
                             p_delivery_id_tab => p_delivery_id_tab,
                             x_out_params      => l_action_prms,
                             x_return_status   => x_return_status);
      IF l_debug_on THEN
        wsh_debug_sv.log (l_module_name,'After deriving SC Rule details', x_return_status);
        wsh_debug_sv.log (l_module_name,'x_return_status', x_return_status);
      END IF;

      wsh_util_core.api_post_call(
        p_return_status    =>x_return_status,
        x_num_warnings     =>l_num_warnings,
        x_num_errors       =>l_num_errors);
    END IF;
    -- End of Ship Confirm Rule Changes

    l_index := p_delivery_id_tab.FIRST;
    while l_index is not null loop
      open  l_dlvy_attr_csr(p_delivery_id_tab(l_index));
      fetch l_dlvy_attr_csr
      into  l_rec_attr_tab(l_index).delivery_id,
            l_rec_attr_tab(l_index).organization_id,
            l_rec_attr_tab(l_index).status_code,
            l_rec_attr_tab(l_index).planned_flag,
            l_rec_attr_tab(l_index).NAME,
            l_rec_attr_tab(l_index).INITIAL_PICKUP_DATE,
            l_rec_attr_tab(l_index).INITIAL_PICKUP_LOCATION_ID,
            l_rec_attr_tab(l_index).ULTIMATE_DROPOFF_LOCATION_ID,
            l_rec_attr_tab(l_index).ULTIMATE_DROPOFF_DATE,
            l_rec_attr_tab(l_index).CUSTOMER_ID,
            l_rec_attr_tab(l_index).INTMED_SHIP_TO_LOCATION_ID,
            l_rec_attr_tab(l_index).SHIP_METHOD_CODE,
            l_rec_attr_tab(l_index).DELIVERY_TYPE,
            l_rec_attr_tab(l_index).CARRIER_ID,
            l_rec_attr_tab(l_index).SERVICE_LEVEL,
            l_rec_attr_tab(l_index).MODE_OF_TRANSPORT,
            l_rec_attr_tab(l_index).shipment_direction,
            l_rec_attr_tab(l_index).party_id,
            l_rec_attr_tab(l_index).shipping_control,
            --Bug 6625788
            l_rec_attr_tab(l_index).reason_of_transport,
            l_rec_attr_tab(l_index).description;


      close l_dlvy_attr_csr;
      l_index := p_delivery_id_tab.NEXT(l_index);
    end loop;
    --
    wsh_deliveries_grp.Delivery_Action(
      p_api_version_number     =>  p_api_version_number,
      p_init_msg_list          =>  l_init_msg_list,
      p_commit                 =>  l_commit,
      p_action_prms            =>  l_action_prms,
      p_rec_attr_tab           =>  l_rec_attr_tab,
      x_delivery_out_rec       =>  x_delivery_out_rec,
      x_defaults_rec           =>  l_defaults_rec,
      x_return_status          =>  x_return_status,
      x_msg_count              =>  x_msg_count,
      x_msg_data               =>  x_msg_data);
    --
    IF l_debug_on THEN
      wsh_debug_sv.log (l_module_name,'x_return_status', x_return_status);
    END IF;

    wsh_util_core.api_post_call(
      p_return_status    =>x_return_status,
      x_num_warnings     =>l_num_warnings,
      x_num_errors       =>l_num_errors);

    IF l_num_warnings > 0 THEN
      RAISE WSH_UTIL_CORE.G_EXC_WARNING;
    END IF;
    --
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;
    --
    FND_MSG_PUB.Count_And_Get (
      p_count => x_msg_count,
      p_data  => x_msg_data);
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO DELIVERY_ACTION_WRAPPER_GRP;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
        (
         p_count  => x_msg_count,
         p_data  =>  x_msg_data,
         p_encoded => FND_API.G_FALSE
        );
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO DELIVERY_ACTION_WRAPPER_GRP;
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
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
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
      ROLLBACK TO DELIVERY_ACTION_WRAPPER_GRP;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_INTERFACE_GRP.DELIVERY_ACTION');
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
  END Delivery_Action;


PROCEDURE Rtrim_deliveries_blank_space (
                p_in_rec  IN  WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type,
                p_out_rec OUT NOCOPY  WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type) IS
  l_debug_on BOOLEAN;
  l_module_name 		CONSTANT VARCHAR2(100) := 'wsh.plsql.' ||
                            G_PKG_NAME || '.' || 'Rtrim_deliveries_blank_space';
BEGIN

   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      wsh_debug_sv.push (l_module_name, 'Rtrim_deliveries_blank_space');
   END IF;

   p_out_rec := p_in_rec;

   p_out_rec.NAME                       := RTRIM(p_in_rec.NAME);
   p_out_rec.DELIVERY_TYPE             := RTRIM(p_in_rec.DELIVERY_TYPE);
   p_out_rec.LOADING_ORDER_FLAG       := RTRIM(p_in_rec.LOADING_ORDER_FLAG);
   p_out_rec.LOADING_ORDER_DESC      := RTRIM(p_in_rec.LOADING_ORDER_DESC);
   p_out_rec.INITIAL_PICKUP_LOCATION_CODE :=
                                   RTRIM(p_in_rec.INITIAL_PICKUP_LOCATION_CODE);
   p_out_rec.ORGANIZATION_CODE          := RTRIM(p_in_rec.ORGANIZATION_CODE);
   p_out_rec.ULTIMATE_DROPOFF_LOCATION_CODE  :=
                               RTRIM(p_in_rec.ULTIMATE_DROPOFF_LOCATION_CODE);
   p_out_rec.CUSTOMER_NUMBER            := RTRIM(p_in_rec.CUSTOMER_NUMBER);
   p_out_rec.INTMED_SHIP_TO_LOCATION_CODE :=
                                 RTRIM(p_in_rec.INTMED_SHIP_TO_LOCATION_CODE);
   p_out_rec.POOLED_SHIP_TO_LOCATION_CODE:=
                                   RTRIM(p_in_rec.POOLED_SHIP_TO_LOCATION_CODE);
   p_out_rec.CARRIER_CODE            := RTRIM(p_in_rec.CARRIER_CODE);
   p_out_rec.SHIP_METHOD_CODE       := RTRIM(p_in_rec.SHIP_METHOD_CODE);
   p_out_rec.SHIP_METHOD_NAME      := RTRIM(p_in_rec.SHIP_METHOD_NAME);
   p_out_rec.FREIGHT_TERMS_CODE   := RTRIM(p_in_rec.FREIGHT_TERMS_CODE);
   p_out_rec.FOB_CODE           := RTRIM(p_in_rec.FOB_CODE);
   p_out_rec.FOB_NAME          := RTRIM(p_in_rec.FOB_NAME);
   p_out_rec.FOB_LOCATION_CODE:= RTRIM(p_in_rec.FOB_LOCATION_CODE);
   p_out_rec.WAYBILL         := RTRIM(p_in_rec.WAYBILL);
   p_out_rec.DOCK_CODE      := RTRIM(p_in_rec.DOCK_CODE);
   p_out_rec.ACCEPTANCE_FLAG  := RTRIM(p_in_rec.ACCEPTANCE_FLAG);
   p_out_rec.ACCEPTED_BY  := RTRIM(p_in_rec.ACCEPTED_BY);
   p_out_rec.ACKNOWLEDGED_BY:= RTRIM(p_in_rec.ACKNOWLEDGED_BY);
   p_out_rec.CONFIRMED_BY  := RTRIM(p_in_rec.CONFIRMED_BY);
   p_out_rec.ASN_STATUS_CODE := RTRIM(p_in_rec.ASN_STATUS_CODE);
   p_out_rec.WEIGHT_UOM_CODE            := RTRIM(p_in_rec.WEIGHT_UOM_CODE);
   p_out_rec.WEIGHT_UOM_DESC           := RTRIM(p_in_rec.WEIGHT_UOM_DESC);
   p_out_rec.VOLUME_UOM_CODE          := RTRIM(p_in_rec.VOLUME_UOM_CODE);
   p_out_rec.VOLUME_UOM_DESC         := RTRIM(p_in_rec.VOLUME_UOM_DESC);
   p_out_rec.ADDITIONAL_SHIPMENT_INFO:=
                                     RTRIM(p_in_rec.ADDITIONAL_SHIPMENT_INFO);
   p_out_rec.CURRENCY_CODE         := RTRIM(p_in_rec.CURRENCY_CODE);
   p_out_rec.CURRENCY_NAME        := RTRIM(p_in_rec.CURRENCY_NAME);
   p_out_rec.ATTRIBUTE_CATEGORY  := RTRIM(p_in_rec.ATTRIBUTE_CATEGORY);
   p_out_rec.ATTRIBUTE1         := RTRIM(p_in_rec.ATTRIBUTE1);
   p_out_rec.ATTRIBUTE2        := RTRIM(p_in_rec.ATTRIBUTE2);
   p_out_rec.ATTRIBUTE3       := RTRIM(p_in_rec.ATTRIBUTE3);
   p_out_rec.ATTRIBUTE4      := RTRIM(p_in_rec.ATTRIBUTE4);
   p_out_rec.ATTRIBUTE5     := RTRIM(p_in_rec.ATTRIBUTE5);
   p_out_rec.ATTRIBUTE6    := RTRIM(p_in_rec.ATTRIBUTE6);
   p_out_rec.ATTRIBUTE7   := RTRIM(p_in_rec.ATTRIBUTE7);
   p_out_rec.ATTRIBUTE8  := RTRIM(p_in_rec.ATTRIBUTE8);
   p_out_rec.ATTRIBUTE9 := RTRIM(p_in_rec.ATTRIBUTE9);
   p_out_rec.ATTRIBUTE10  := RTRIM(p_in_rec.ATTRIBUTE10);
   p_out_rec.ATTRIBUTE11 := RTRIM(p_in_rec.ATTRIBUTE11);
   p_out_rec.ATTRIBUTE12:= RTRIM(p_in_rec.ATTRIBUTE12);
   p_out_rec.ATTRIBUTE13  := RTRIM(p_in_rec.ATTRIBUTE13);
   p_out_rec.ATTRIBUTE14                := RTRIM(p_in_rec.ATTRIBUTE14);
   p_out_rec.ATTRIBUTE15               := RTRIM(p_in_rec.ATTRIBUTE15);
   p_out_rec.TP_ATTRIBUTE_CATEGORY    := RTRIM(p_in_rec.TP_ATTRIBUTE_CATEGORY);
   p_out_rec.TP_ATTRIBUTE1           := RTRIM(p_in_rec.TP_ATTRIBUTE1);
   p_out_rec.TP_ATTRIBUTE2          := RTRIM(p_in_rec.TP_ATTRIBUTE2);
   p_out_rec.TP_ATTRIBUTE3         := RTRIM(p_in_rec.TP_ATTRIBUTE3);
   p_out_rec.TP_ATTRIBUTE4        := RTRIM(p_in_rec.TP_ATTRIBUTE4);
   p_out_rec.TP_ATTRIBUTE5       := RTRIM(p_in_rec.TP_ATTRIBUTE5);
   p_out_rec.TP_ATTRIBUTE6      := RTRIM(p_in_rec.TP_ATTRIBUTE6);
   p_out_rec.TP_ATTRIBUTE7     := RTRIM(p_in_rec.TP_ATTRIBUTE7);
   p_out_rec.TP_ATTRIBUTE8    := RTRIM(p_in_rec.TP_ATTRIBUTE8);
   p_out_rec.TP_ATTRIBUTE9   := RTRIM(p_in_rec.TP_ATTRIBUTE9);
   p_out_rec.TP_ATTRIBUTE10 := RTRIM(p_in_rec.TP_ATTRIBUTE10);
   p_out_rec.TP_ATTRIBUTE11:= RTRIM(p_in_rec.TP_ATTRIBUTE11);
   p_out_rec.TP_ATTRIBUTE12  := RTRIM(p_in_rec.TP_ATTRIBUTE12);
   p_out_rec.TP_ATTRIBUTE13 := RTRIM(p_in_rec.TP_ATTRIBUTE13);
   p_out_rec.TP_ATTRIBUTE14:= RTRIM(p_in_rec.TP_ATTRIBUTE14);
   p_out_rec.TP_ATTRIBUTE15  := RTRIM(p_in_rec.TP_ATTRIBUTE15);
   p_out_rec.GLOBAL_ATTRIBUTE_CATEGORY:= RTRIM(p_in_rec.GLOBAL_ATTRIBUTE_CATEGORY);
   p_out_rec.GLOBAL_ATTRIBUTE1         := RTRIM(p_in_rec.GLOBAL_ATTRIBUTE1);
   p_out_rec.GLOBAL_ATTRIBUTE2        := RTRIM(p_in_rec.GLOBAL_ATTRIBUTE2);
   p_out_rec.GLOBAL_ATTRIBUTE3       := RTRIM(p_in_rec.GLOBAL_ATTRIBUTE3);
   p_out_rec.GLOBAL_ATTRIBUTE4      := RTRIM(p_in_rec.GLOBAL_ATTRIBUTE4);
   p_out_rec.GLOBAL_ATTRIBUTE5     := RTRIM(p_in_rec.GLOBAL_ATTRIBUTE5);
   p_out_rec.GLOBAL_ATTRIBUTE6    := RTRIM(p_in_rec.GLOBAL_ATTRIBUTE6);
   p_out_rec.GLOBAL_ATTRIBUTE7   := RTRIM(p_in_rec.GLOBAL_ATTRIBUTE7);
   p_out_rec.GLOBAL_ATTRIBUTE8  := RTRIM(p_in_rec.GLOBAL_ATTRIBUTE8);
   p_out_rec.GLOBAL_ATTRIBUTE9 := RTRIM(p_in_rec.GLOBAL_ATTRIBUTE9);
   p_out_rec.GLOBAL_ATTRIBUTE10  := RTRIM(p_in_rec.GLOBAL_ATTRIBUTE10);
   p_out_rec.GLOBAL_ATTRIBUTE11 := RTRIM(p_in_rec.GLOBAL_ATTRIBUTE11);
   p_out_rec.GLOBAL_ATTRIBUTE12:= RTRIM(p_in_rec.GLOBAL_ATTRIBUTE12);
   p_out_rec.GLOBAL_ATTRIBUTE13  := RTRIM(p_in_rec.GLOBAL_ATTRIBUTE13);
   p_out_rec.GLOBAL_ATTRIBUTE14 := RTRIM(p_in_rec.GLOBAL_ATTRIBUTE14);
   p_out_rec.GLOBAL_ATTRIBUTE15         := RTRIM(p_in_rec.GLOBAL_ATTRIBUTE15);
   p_out_rec.GLOBAL_ATTRIBUTE16        := RTRIM(p_in_rec.GLOBAL_ATTRIBUTE16);
   p_out_rec.GLOBAL_ATTRIBUTE17       := RTRIM(p_in_rec.GLOBAL_ATTRIBUTE17);
   p_out_rec.GLOBAL_ATTRIBUTE18      := RTRIM(p_in_rec.GLOBAL_ATTRIBUTE18);
   p_out_rec.GLOBAL_ATTRIBUTE19     := RTRIM(p_in_rec.GLOBAL_ATTRIBUTE19);
   p_out_rec.GLOBAL_ATTRIBUTE20    := RTRIM(p_in_rec.GLOBAL_ATTRIBUTE20);
   p_out_rec.COD_CURRENCY_CODE    := RTRIM(p_in_rec.COD_CURRENCY_CODE);
   p_out_rec.COD_REMIT_TO        := RTRIM(p_in_rec.COD_REMIT_TO);
   p_out_rec.COD_CHARGE_PAID_BY := RTRIM(p_in_rec.COD_CHARGE_PAID_BY);
   p_out_rec.PROBLEM_CONTACT_REFERENCE:= RTRIM(p_in_rec.PROBLEM_CONTACT_REFERENCE);
   p_out_rec.PORT_OF_LOADING           := RTRIM(p_in_rec.PORT_OF_LOADING);
   p_out_rec.PORT_OF_DISCHARGE        := RTRIM(p_in_rec.PORT_OF_DISCHARGE);
   p_out_rec.FTZ_NUMBER              := RTRIM(p_in_rec.FTZ_NUMBER);
   p_out_rec.ROUTED_EXPORT_TXN      := RTRIM(p_in_rec.ROUTED_EXPORT_TXN);
   p_out_rec.ENTRY_NUMBER          := RTRIM(p_in_rec.ENTRY_NUMBER);
   p_out_rec.ROUTING_INSTRUCTIONS := RTRIM(p_in_rec.ROUTING_INSTRUCTIONS);
   p_out_rec.IN_BOND_CODE        := RTRIM(p_in_rec.IN_BOND_CODE);
   p_out_rec.SHIPPING_MARKS     := RTRIM(p_in_rec.SHIPPING_MARKS);
   p_out_rec.SERVICE_LEVEL     := RTRIM(p_in_rec.SERVICE_LEVEL);
   p_out_rec.MODE_OF_TRANSPORT:= RTRIM(p_in_rec.MODE_OF_TRANSPORT);
   p_out_rec.ASSIGNED_TO_FTE_TRIPS := RTRIM(p_in_rec.ASSIGNED_TO_FTE_TRIPS);
   p_out_rec.AUTO_SC_EXCLUDE_FLAG       := RTRIM(p_in_rec.AUTO_SC_EXCLUDE_FLAG);
   p_out_rec.AUTO_AP_EXCLUDE_FLAG      := RTRIM(p_in_rec.AUTO_AP_EXCLUDE_FLAG);
/*3667348*/
   p_out_rec.REASON_OF_TRANSPORT      := RTRIM(p_in_rec.REASON_OF_TRANSPORT);
   p_out_rec.DESCRIPTION     := RTRIM(p_in_rec.DESCRIPTION);
   IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;

EXCEPTION

   WHEN OTHERS THEN
      wsh_util_core.default_handler (
        'WSH_TRIP_STOPS_GRP.Rtrim_deliveries_blank_space', l_module_name);
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured.'||
         ' Oracle error message is '|| SQLERRM,
                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;
      RAISE;

END Rtrim_deliveries_blank_space;
--========================================================================

-- I Harmonization: rvishnuv ******* Actions ******

-- I Harmonization: rvishnuv ******* Create/Update ******
--========================================================================
-- PROCEDURE : Create_Update_Delivery  Wrapper API      PUBLIC
--
-- PARAMETERS: p_api_version_number    known api version error buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_in_rec                Record for caller, phase
--                                     and action_code ( CREATE-UPDATE )
--	       p_rec_attr_tab          Table of Attributes for the delivery entity
--  	       x_del_out_rec           Record of delivery_id, and name of new deliveries,
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Creates or updates a record in wsh_new_deliveries table with information
--             specified in p_delivery_info
--========================================================================
  PROCEDURE Create_Update_Delivery
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    p_commit		     IN   VARCHAR2 , -- default fnd_api.g_false
    p_in_rec                 IN   WSH_DELIVERIES_GRP.Del_In_Rec_Type,
    p_rec_attr_tab	     IN   WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type,
    x_del_out_rec_tab        OUT  NOCOPY WSH_DELIVERIES_GRP.Del_Out_Tbl_Type,
    x_return_status          OUT  NOCOPY VARCHAR2,
    x_msg_count              OUT  NOCOPY NUMBER,
    x_msg_data               OUT  NOCOPY VARCHAR2)
  IS
    --
    l_num_warnings           NUMBER := 0;
    l_num_errors             NUMBER := 0;
    --
    --l_rec_attr_tab           wsh_new_deliveries_pvt.Delivery_Attr_Tbl_Type;
    --l_del_out_rec_tab        wsh_delveries_grp.Del_Out_Tbl_Type;
    --
l_debug_on BOOLEAN;
    --
    l_module_name CONSTANT   VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_UPDATE_DELIVERY_WRAPPER';
    l_commit                 VARCHAR2(100) := FND_API.G_FALSE;
    l_init_msg_list          VARCHAR2(100) := FND_API.G_FALSE;
    l_rec_attr_tab	     WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type;
    l_index                  NUMBER;
    l_in_rec                 WSH_DELIVERIES_GRP.Del_In_Rec_Type;
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
    SAVEPOINT CREATE_UPDATE_DEL_WRAP_GRP;
    --
    IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name);
      wsh_debug_sv.log(l_module_name,'Caller is ', p_in_rec.caller);
      wsh_debug_sv.log(l_module_name,'Phase is ', p_in_rec.phase);
      wsh_debug_sv.log(l_module_name,'Action Code is ', p_in_rec.phase);
      wsh_debug_sv.log(l_module_name,'Number of Records is ', p_rec_attr_tab.COUNT);
    END IF;
    --
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --
    l_in_rec := p_in_rec;
    l_in_rec.caller := RTRIM(p_in_rec.caller);
    l_in_rec.action_code := RTRIM(p_in_rec.action_code);

    l_index := p_rec_attr_tab.FIRST;
    WHILE l_index IS NOT NULL LOOP
       Rtrim_deliveries_blank_space(p_rec_attr_tab(l_index),
                                    l_rec_attr_tab(l_index));
       l_index := p_rec_attr_tab.NEXT(l_index);
    END LOOP;

    WSH_DELIVERIES_GRP.Create_Update_Delivery(
      p_api_version_number     =>  p_api_version_number,
      p_init_msg_list          =>  l_init_msg_list,
      p_commit		       =>  l_commit,
      p_in_rec                 =>  l_in_rec,
      p_rec_attr_tab	       =>  l_rec_attr_tab,
      x_del_out_rec_tab        =>  x_del_out_rec_tab,
      x_return_status          =>  x_return_status,
      x_msg_count              =>  x_msg_count,
      x_msg_data               =>  x_msg_data);
    --
    IF l_debug_on THEN
      wsh_debug_sv.log (l_module_name,'x_return_status', x_return_status);
    END IF;
    --
    wsh_util_core.api_post_call(
      p_return_status    =>x_return_status,
      x_num_warnings     =>l_num_warnings,
      x_num_errors       =>l_num_errors);
    --
    IF l_num_warnings > 0 THEN
      RAISE WSH_UTIL_CORE.G_EXC_WARNING;
    END IF;
    --
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;
    --
    FND_MSG_PUB.Count_And_Get (
      p_count => x_msg_count,
      p_data  => x_msg_data);
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO CREATE_UPDATE_DEL_WRAP_GRP;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
        (
         p_count  => x_msg_count,
         p_data  =>  x_msg_data,
         p_encoded => FND_API.G_FALSE
        );
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CREATE_UPDATE_DEL_WRAP_GRP;
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
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
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
      ROLLBACK TO CREATE_UPDATE_DEL_WRAP_GRP;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_INTERFACE_GRP.CREATE_UPDATE_DELIVERY');
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
--========================================================================

-- I Harmonization: rvishnuv ******* Create/Update ******


    -- ---------------------------------------------------------------------
    -- Procedure:	Delivery_Detail_Action	Wrapper API
    --
    -- Parameters:
    --
    -- Description:  This procedure is the wrapper(overloaded) version for the
    --               main delivery_detail_group API. This is for use by public APIs
    --		 and by other product APIs. This signature does not have
    --               the form(UI) specific parameters
    -- Created :  Patchset I : Harmonization Project
    -- Created by: KVENKATE
    -- -----------------------------------------------------------------------
    PROCEDURE Delivery_Detail_Action
    (
    -- Standard Parameters
       p_api_version_number        IN       NUMBER,
       p_init_msg_list             IN 	    VARCHAR2,
       p_commit                    IN 	    VARCHAR2,
       x_return_status             OUT 	  NOCOPY  VARCHAR2,
       x_msg_count                 OUT 	  NOCOPY  NUMBER,
       x_msg_data                  OUT 	  NOCOPY  VARCHAR2,

    -- Procedure specific Parameters
       p_detail_id_tab             IN	    WSH_UTIL_CORE.id_tab_type,
       p_action_prms               IN	    WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type
,
       x_action_out_rec            OUT NOCOPY     WSH_GLBL_VAR_STRCT_GRP.dd_action_out_rec_type
    ) IS

        l_api_name              CONSTANT VARCHAR2(30)   := 'delivery_detail_action';
        l_api_version           CONSTANT NUMBER         := 1.0;
        --
	--
	l_return_status             VARCHAR2(32767);
	l_msg_count                 NUMBER;
	l_msg_data                  VARCHAR2(32767);
	l_program_name              VARCHAR2(32767);
        --
        --
        l_rec_attr_tab      WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type;
        l_action_prms       WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type
;
        l_action_out_rec    WSH_GLBL_VAR_STRCT_GRP.dd_action_out_rec_type;
        l_dummy_defaults    WSH_GLBL_VAR_STRCT_GRP.dd_default_parameters_rec_type;
        l_dummy_flag        VARCHAR2(32767);
	--
        CURSOR det_cur(p_det_id NUMBER) IS
           SELECT released_status,
                  organization_id,
                  container_flag,
                  source_code,
                  lpn_id,
                  CUSTOMER_ID,
                  INVENTORY_ITEM_ID,
                  SHIP_FROM_LOCATION_ID,
                  SHIP_TO_LOCATION_ID,
                  INTMED_SHIP_TO_LOCATION_ID,
                  DATE_REQUESTED,
                  DATE_SCHEDULED,
                  SHIP_METHOD_CODE,
                  CARRIER_ID,
                  shipping_control,
                  party_id,
/*J inbound logistics: new column jckwok */
                  line_direction,
                  source_line_id,
                  move_order_line_id  --R12, X-dock
           FROM wsh_delivery_details
           WHERE delivery_detail_id = p_det_id;

	l_number_of_errors    NUMBER := 0;
	l_number_of_warnings  NUMBER := 0;
	--
        l_counter             NUMBER := 0;
        l_index               NUMBER;
	--
l_debug_on BOOLEAN;
	--
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELIVERY_DETAIL_ACTION';
	--
  BEGIN
        -- Standard Start of API savepoint
        --
        l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
        --
        IF l_debug_on IS NULL
        THEN
            l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
        END IF;
        --
        SAVEPOINT   DEL_DETAIL_ACTION_WRAP_GRP;

        IF l_debug_on THEN
            WSH_DEBUG_SV.push(l_module_name);
            --
            WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION_NUMBER',P_API_VERSION_NUMBER);
            WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
            WSH_DEBUG_SV.log(l_module_name,'P_COMMIT',P_COMMIT);
            WSH_DEBUG_SV.log(l_module_name, 'Caller', p_action_prms.caller);
            WSH_DEBUG_SV.log(l_module_name, 'Phase', p_action_prms.phase);
            WSH_DEBUG_SV.log(l_module_name, 'Action Code', p_action_prms.action_code);
            WSH_DEBUG_SV.log(l_module_name, 'Input Table count', p_detail_id_tab.count);
        END IF;
        --

        IF FND_API.to_Boolean( p_init_msg_list )
	THEN
                FND_MSG_PUB.initialize;
        END IF;
	--
	--
        --  Initialize API return status to success
	x_return_status       := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_number_of_errors := 0;
	l_number_of_warnings := 0;


        IF(p_detail_id_tab.count = 0) THEN
           IF l_debug_on THEN
              wsh_debug_sv.log (l_module_name,'Input Table Count Zero');
           END IF;
           RAISE FND_API.G_EXC_ERROR;
        END IF;


       --Build the records to pass to the core group api
       l_index := p_detail_id_tab.FIRST;
       WHILE l_index IS NOT NULL
       LOOP
           l_rec_attr_tab(l_index).delivery_detail_id := p_detail_id_tab(l_index);

           OPEN det_cur(p_detail_id_tab(l_index));
           FETCH det_cur
           INTO l_rec_attr_tab(l_index).released_status,
                l_rec_attr_tab(l_index).organization_id,
                l_rec_attr_tab(l_index).container_flag,
                l_rec_attr_tab(l_index).source_code,
                l_rec_attr_tab(l_index).lpn_id,
                l_rec_attr_tab(l_index).CUSTOMER_ID,
                l_rec_attr_tab(l_index).INVENTORY_ITEM_ID,
                l_rec_attr_tab(l_index).SHIP_FROM_LOCATION_ID,
                l_rec_attr_tab(l_index).SHIP_TO_LOCATION_ID,
                l_rec_attr_tab(l_index).INTMED_SHIP_TO_LOCATION_ID,
                l_rec_attr_tab(l_index).DATE_REQUESTED,
                l_rec_attr_tab(l_index).DATE_SCHEDULED,
                l_rec_attr_tab(l_index).SHIP_METHOD_CODE,
                l_rec_attr_tab(l_index).CARRIER_ID,
                l_rec_attr_tab(l_index).shipping_control,
                l_rec_attr_tab(l_index).party_id,
                l_rec_attr_tab(l_index).line_direction,
                l_rec_attr_tab(l_index).source_line_id,
                l_rec_attr_tab(l_index).move_order_line_id; -- R12, X-dock

           IF det_cur%NOTFOUND THEN
              IF l_debug_on THEN
                 wsh_debug_sv.log (l_module_name,'Invalid Delivery Detail');
              END IF;
              CLOSE det_cur;
              RAISE FND_API.G_EXC_ERROR;
           END IF;

           CLOSE det_cur;

           l_index := p_detail_id_tab.NEXT(l_index);
       END LOOP;

       l_action_prms := p_action_prms;
       l_action_prms.Caller := RTRIM(p_action_prms.Caller);
       l_action_prms.Action_Code := RTRIM(p_action_prms.Action_Code);
       l_action_prms.delivery_name := RTRIM(p_action_prms.delivery_name);
       l_action_prms.wv_override_flag := RTRIM(p_action_prms.wv_override_flag);
       l_action_prms.container_name := RTRIM(p_action_prms.container_name);
       l_action_prms.container_flag := RTRIM(p_action_prms.container_flag);
       l_action_prms.delivery_flag := RTRIM(p_action_prms.delivery_flag);
       -- Call the Core Group API

            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIERY_DETAILS_GRP.DELIVERY_DETAIL_ACTION',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

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
           x_action_out_rec          => x_action_out_rec
           );

         --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

            wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data
               );


       IF l_number_of_warnings > 0 THEN
          RAISE WSH_UTIL_CORE.G_EXC_WARNING;
       END IF;

       -- Standard check of p_commit.
       IF FND_API.To_Boolean( p_commit ) THEN
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Commit Work');
         END IF;
          COMMIT WORK;
       END IF;

      FND_MSG_PUB.Count_And_Get
          (
            p_count  => x_msg_count,
            p_data  =>  x_msg_data
          );

       IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
       END IF;
       --
  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO DEL_DETAIL_ACTION_WRAP_GRP;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
                  --
                  IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
                  END IF;
                  --
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO DEL_DETAIL_ACTION_WRAP_GRP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
                  --
                  IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
                  END IF;
                  --
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
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
               WSH_UTIL_CORE.default_handler('WSH_INTERFACE_GRP.Delivery_Detail_Action');
                ROLLBACK TO DEL_DETAIL_ACTION_WRAP_GRP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
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
    --
    END Delivery_Detail_Action;

PROCEDURE Rtrim_details_blank_space (
        p_in_rec  IN  WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type,
        p_out_rec OUT NOCOPY  WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type) IS
  l_debug_on BOOLEAN;
  l_module_name 		CONSTANT VARCHAR2(100) := 'wsh.plsql.' ||
                                 G_PKG_NAME || '.' || 'Rtrim_details_blank_space';
BEGIN

   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      wsh_debug_sv.push (l_module_name, 'Rtrim_details_blank_space');
   END IF;

   p_out_rec := p_in_rec;

   p_out_rec.source_code		 := RTRIM(p_in_rec.source_code);
   p_out_rec.item_description := RTRIM(p_in_rec.item_description);
   p_out_rec.country_of_origin := RTRIM(p_in_rec.country_of_origin);
   p_out_rec.classification := RTRIM(p_in_rec.classification);
   p_out_rec.hold_code := RTRIM(p_in_rec.hold_code);
   p_out_rec.requested_quantity_uom := RTRIM(p_in_rec.requested_quantity_uom);
   p_out_rec.subinventory := RTRIM(p_in_rec.subinventory);
   p_out_rec.revision := RTRIM(p_in_rec.revision);
   p_out_rec.lot_number		 := RTRIM(p_in_rec.lot_number);
   p_out_rec.customer_requested_lot_flag := RTRIM(p_in_rec.customer_requested_lot_flag);
   -- frontport bug 5049214: trim both leading/trailing space of serial number
   p_out_rec.serial_number   := LTRIM(RTRIM(p_in_rec.serial_number));
   p_out_rec.to_serial_number   := LTRIM(RTRIM(p_in_rec.to_serial_number));
   p_out_rec.ship_method_code := RTRIM(p_in_rec.ship_method_code);
   p_out_rec.freight_terms_code	 := RTRIM(p_in_rec.freight_terms_code);
   p_out_rec.shipment_priority_code := RTRIM(p_in_rec.shipment_priority_code);
   p_out_rec.fob_code := RTRIM(p_in_rec.fob_code);
   p_out_rec.dep_plan_required_flag := RTRIM(p_in_rec.dep_plan_required_flag);
   p_out_rec.customer_prod_seq	 := RTRIM(p_in_rec.customer_prod_seq);
   p_out_rec.customer_dock_code := RTRIM(p_in_rec.customer_dock_code);
   p_out_rec.cust_model_serial_number := RTRIM(p_in_rec.cust_model_serial_number);
   p_out_rec.customer_job            := RTRIM(p_in_rec.customer_job);
   p_out_rec.customer_production_line:= RTRIM(p_in_rec.customer_production_line);
   p_out_rec.weight_uom_code	 := RTRIM(p_in_rec.weight_uom_code);
   p_out_rec.volume_uom_code := RTRIM(p_in_rec.volume_uom_code);
   p_out_rec.tp_attribute_category := RTRIM(p_in_rec.tp_attribute_category);
   p_out_rec.tp_attribute1		 := RTRIM(p_in_rec.tp_attribute1);
   p_out_rec.tp_attribute2	 := RTRIM(p_in_rec.tp_attribute2);
   p_out_rec.tp_attribute3 := RTRIM(p_in_rec.tp_attribute3);
   p_out_rec.tp_attribute4 := RTRIM(p_in_rec.tp_attribute4);
   p_out_rec.tp_attribute5		 := RTRIM(p_in_rec.tp_attribute5);
   p_out_rec.tp_attribute6	 := RTRIM(p_in_rec.tp_attribute6);
   p_out_rec.tp_attribute7 := RTRIM(p_in_rec.tp_attribute7);
   p_out_rec.tp_attribute8 := RTRIM(p_in_rec.tp_attribute8);
   p_out_rec.tp_attribute9		 := RTRIM(p_in_rec.tp_attribute9);
   p_out_rec.tp_attribute10	 := RTRIM(p_in_rec.tp_attribute10);
   p_out_rec.tp_attribute11 := RTRIM(p_in_rec.tp_attribute11);
   p_out_rec.tp_attribute12 := RTRIM(p_in_rec.tp_attribute12);
   p_out_rec.tp_attribute13	 := RTRIM(p_in_rec.tp_attribute13);
   p_out_rec.tp_attribute14	 := RTRIM(p_in_rec.tp_attribute14);
   p_out_rec.tp_attribute15 := RTRIM(p_in_rec.tp_attribute15);
   p_out_rec.attribute_category	 := RTRIM(p_in_rec.attribute_category);
   p_out_rec.attribute1	 := RTRIM(p_in_rec.attribute1);
   p_out_rec.attribute2 := RTRIM(p_in_rec.attribute2);
   p_out_rec.attribute3 := RTRIM(p_in_rec.attribute3);
   p_out_rec.attribute4		 := RTRIM(p_in_rec.attribute4);
   p_out_rec.attribute5	 := RTRIM(p_in_rec.attribute5);
   p_out_rec.attribute6 := RTRIM(p_in_rec.attribute6);
   p_out_rec.attribute7 := RTRIM(p_in_rec.attribute7);
   p_out_rec.attribute8		 := RTRIM(p_in_rec.attribute8);
   p_out_rec.attribute9	 := RTRIM(p_in_rec.attribute9);
   p_out_rec.attribute10 := RTRIM(p_in_rec.attribute10);
   p_out_rec.attribute11 := RTRIM(p_in_rec.attribute11);
   p_out_rec.attribute12		 := RTRIM(p_in_rec.attribute12);
   p_out_rec.attribute13	 := RTRIM(p_in_rec.attribute13);
   p_out_rec.attribute14 := RTRIM(p_in_rec.attribute14);
   p_out_rec.attribute15 := RTRIM(p_in_rec.attribute15);
   p_out_rec.mvt_stat_status	 := RTRIM(p_in_rec.mvt_stat_status);
   p_out_rec.released_flag := RTRIM(p_in_rec.released_flag);
   p_out_rec.ship_model_complete_flag:= RTRIM(p_in_rec.ship_model_complete_flag);
   p_out_rec.source_header_number := RTRIM(p_in_rec.source_header_number);
   p_out_rec.source_header_type_name := RTRIM(p_in_rec.source_header_type_name);
   p_out_rec.cust_po_number		 := RTRIM(p_in_rec.cust_po_number);
   p_out_rec.src_requested_quantity_uom := RTRIM(p_in_rec.src_requested_quantity_uom);
   p_out_rec.tracking_number	 := RTRIM(p_in_rec.tracking_number);
   p_out_rec.shipping_instructions := RTRIM(p_in_rec.shipping_instructions);
   p_out_rec.packing_instructions := RTRIM(p_in_rec.packing_instructions);
   p_out_rec.oe_interfaced_flag	 := RTRIM(p_in_rec.oe_interfaced_flag);
   p_out_rec.inv_interfaced_flag := RTRIM(p_in_rec.inv_interfaced_flag);
   p_out_rec.source_line_number := RTRIM(p_in_rec.source_line_number);
   p_out_rec.inspection_flag             := RTRIM(p_in_rec.inspection_flag);
   p_out_rec.released_status	 := RTRIM(p_in_rec.released_status);
   p_out_rec.container_flag := RTRIM(p_in_rec.container_flag);
   p_out_rec.container_type_code  := RTRIM(p_in_rec.container_type_code);
   p_out_rec.container_name		 := RTRIM(p_in_rec.container_name);
   p_out_rec.master_serial_number := RTRIM(p_in_rec.master_serial_number);
   p_out_rec.seal_code			 := RTRIM(p_in_rec.seal_code);
   p_out_rec.unit_number  		 := RTRIM(p_in_rec.unit_number);
   p_out_rec.currency_code	 := RTRIM(p_in_rec.currency_code);
   p_out_rec.preferred_grade      := RTRIM(p_in_rec.preferred_grade);
   p_out_rec.src_requested_quantity_uom2 := RTRIM(p_in_rec.src_requested_quantity_uom2);
   p_out_rec.requested_quantity_uom2    := RTRIM(p_in_rec.requested_quantity_uom2);
-- HW OPMCONV - No need for sublot
-- p_out_rec.sublot_number             := RTRIM(p_in_rec.sublot_number);
   p_out_rec.pickable_flag            := RTRIM(p_in_rec.pickable_flag);
   p_out_rec.original_subinventory   := RTRIM(p_in_rec.original_subinventory);

   IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;

EXCEPTION

   WHEN OTHERS THEN
      wsh_util_core.default_handler (
        'WSH_TRIP_STOPS_GRP.Rtrim_details_blank_space', l_module_name);
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured.'||
         ' Oracle error message is '|| SQLERRM,
                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;
      RAISE;

END Rtrim_details_blank_space;

    -- ---------------------------------------------------------------------
    -- Procedure:	Create_Update_Delivery_Detail	Wrapper API
    --
    -- Parameters:
    --
    -- Description:  This procedure is the new API for wrapping the logic of CREATE/UPDATE of delivery details
    -- Created    : Patchset I - Harmonization Project
    -- Created By : KVENKATE
    -- -----------------------------------------------------------------------

    PROCEDURE Create_Update_Delivery_Detail
    (
       -- Standard Parameters
       p_api_version_number	 IN	 NUMBER,
       p_init_msg_list           IN 	 VARCHAR2,
       p_commit                  IN 	 VARCHAR2,
       x_return_status           OUT NOCOPY	 VARCHAR2,
       x_msg_count               OUT NOCOPY	 NUMBER,
       x_msg_data                OUT NOCOPY	 VARCHAR2,

       -- Procedure Specific Parameters
       p_detail_info_tab         IN 	WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type,
       p_IN_rec                  IN  	WSH_GLBL_VAR_STRCT_GRP.detailInRecType,
       x_OUT_rec                 OUT NOCOPY	WSH_GLBL_VAR_STRCT_GRP.detailOutRecType
    ) IS

        l_api_name              CONSTANT VARCHAR2(30)   := 'Create_Update_Delivery_Detail';
        l_api_version           CONSTANT NUMBER         := 1.0;
        --
	--
	l_return_status             VARCHAR2(32767);
	l_msg_count                 NUMBER;
	l_msg_data                  VARCHAR2(32767);
	l_program_name              VARCHAR2(32767);
        --
	l_number_of_errors    NUMBER := 0;
	l_number_of_warnings  NUMBER := 0;
	--
        l_counter             NUMBER := 0;

        l_valid_index_tab     wsh_util_core.id_tab_type;
        l_delivery_id         NUMBER;
        l_delivery_detail_rec WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type
;
        l_in_rec         WSH_GLBL_VAR_STRCT_GRP.detailInRecType;
        l_out_rec        WSH_GLBL_VAR_STRCT_GRP.detailOutRecType;
        l_detail_info_tab  WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type;
        l_index          NUMBER;
	--
        CURSOR det_to_del_cur(p_detail_id NUMBER) IS
           SELECT wda.delivery_id
           FROM wsh_delivery_assignments_v wda
           WHERE wda.delivery_detail_id = p_detail_id;
        --
l_debug_on BOOLEAN;
	--
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_UPDATE_DELIVERY_DETAIL';
	--

  BEGIN

        -- Standard Start of API savepoint
        --
        l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
        --
        IF l_debug_on IS NULL
        THEN
            l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
        END IF;
        --
        SAVEPOINT   CREATE_UPD_DEL_DET_WRAP_GRP;
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.push(l_module_name);
            --
            WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION_NUMBER',P_API_VERSION_NUMBER);
            WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
            WSH_DEBUG_SV.log(l_module_name,'P_COMMIT',P_COMMIT);
        END IF;
        --
        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
	THEN
                FND_MSG_PUB.initialize;
        END IF;
	--
	--
        --  Initialize API return status to success
	x_return_status       := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_number_of_errors := 0;
	l_number_of_warnings := 0;


        l_in_rec := p_in_rec;
        l_in_rec.caller := RTRIM(p_in_rec.caller);
        l_in_rec.action_code := RTRIM(p_in_rec.action_code);
        l_in_rec.container_item_name := RTRIM(p_in_rec.container_item_name);
        l_in_rec.organization_code := RTRIM(p_in_rec.organization_code);
        l_in_rec.name_prefix := RTRIM(p_in_rec.name_prefix);
        l_in_rec.name_suffix := RTRIM(p_in_rec.name_suffix);
        l_in_rec.container_name := RTRIM(p_in_rec.container_name);

        -- Call Core Group API

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_GRP.CREATE_UPDATE_DELIVERY_DETAIL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        l_index := p_detail_info_tab.FIRST;
        WHILE l_index IS NOT NULL LOOP
           Rtrim_details_blank_space(p_detail_info_tab(l_index),
                                     l_detail_info_tab(l_index));
           l_index := p_detail_info_tab.NEXT(l_index);
        END LOOP;

        wsh_delivery_details_grp.Create_Update_Delivery_Detail(
            p_api_version_number      =>  p_api_version_number,
            p_init_msg_list           =>  FND_API.G_FALSE,
            p_commit                  =>  FND_API.G_FALSE,
            x_return_status           =>  l_return_status,
            x_msg_count               =>  l_msg_count,
            x_msg_data                =>  l_msg_data,
            p_detail_info_tab         =>  l_detail_info_tab,
            p_IN_rec                  =>  l_in_rec,
            x_OUT_rec                 =>  x_out_rec
            );

                  --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
                  --
        wsh_util_core.api_post_call(
              p_return_status => l_return_status,
              x_num_warnings  => l_number_of_warnings,
              x_num_errors    => l_number_of_errors,
              p_msg_data      => l_msg_data
          );

       IF l_number_of_warnings > 0 THEN
          RAISE WSH_UTIL_CORE.G_EXC_WARNING;
       END IF;

       -- Standard check of p_commit.
       IF FND_API.To_Boolean( p_commit ) THEN
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Commit Work');
         END IF;
          COMMIT WORK;
       END IF;

       FND_MSG_PUB.Count_And_Get
         (
          p_count  => x_msg_count,
          p_data  =>  x_msg_data
         );

      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
--
  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO CREATE_UPD_DEL_DET_WRAP_GRP;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
                  --
                  IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
                  END IF;
                  --
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO CREATE_UPD_DEL_DET_WRAP_GRP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );

                  --
                  IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
                  END IF;
        --
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
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
               WSH_UTIL_CORE.default_handler('WSH_INTERFACE_GRP.Create_Update_Delivery_Detail');
                ROLLBACK TO CREATE_UPD_DEL_DET_WRAP_GRP;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
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
  END Create_Update_Delivery_Detail;



/*------------------------------------------------------------
  PROCEDURE Trip_Action  This is the wrapper for the
            Trip action
-------------------------------------------------------------*/

PROCEDURE Trip_Action
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    p_commit                 IN   VARCHAR2,
    p_entity_id_tab          IN   wsh_util_core.id_tab_type,
    p_action_prms            IN   WSH_TRIPS_GRP.action_parameters_rectype,
    x_trip_out_rec           OUT  NOCOPY WSH_TRIPS_GRP.tripActionOutRecType,
    x_return_status          OUT  NOCOPY VARCHAR2,
    x_msg_count              OUT  NOCOPY NUMBER,
    x_msg_data               OUT  NOCOPY VARCHAR2)
IS

   l_rec_attr_tab           WSH_TRIPS_PVT.Trip_Attr_Tbl_Type;
   l_action_prms            WSH_TRIPS_GRP.action_parameters_rectype;
   l_num_warning            NUMBER := 0;
   l_num_errors             NUMBER := 0;
   l_next                   NUMBER;
   l_index                  NUMBER;
   l_trip_id                NUMBER;
   l_status_code            wsh_trips.status_code%TYPE;
   l_planned_flag           wsh_trips.planned_flag%TYPE;
   l_lane_id                wsh_trips.lane_id%TYPE;
   l_load_tender_status     wsh_trips.load_tender_status%TYPE;
   l_shipments_type_flag    VARCHAR2(30);
   l_trip_out_rec           WSH_TRIPS_GRP.tripActionOutRecType;
   l_return_status          VARCHAR2(1000);
   l_ignore_for_planning    WSH_TRIPS.IGNORE_FOR_PLANNING%TYPE; --OTM R12, glog proj

   l_debug_on BOOLEAN;
   l_def_rec                WSH_TRIPS_GRP.default_parameters_rectype;
   --
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.'
                                                       || 'TRIP_ACTION WRAPPER';

    CURSOR c_attributes(p_trip_id NUMBER) IS
      SELECT  trip_id
             ,planned_flag
             ,lane_id
             ,load_tender_status
             ,status_code
             ,shipments_type_flag
             ,ignore_for_planning -- OTM R12, glog proj
      FROM WSH_TRIPS
      WHERE trip_id = p_trip_id;


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
       wsh_debug_sv.push (l_module_name);
       wsh_debug_sv.log (l_module_name,'phase', p_action_prms.phase);
   END IF;

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   l_action_prms    := p_action_prms;
   l_action_prms.caller := RTRIM(p_action_prms.caller);
   l_action_prms.action_code := RTRIM(p_action_prms.action_code);
   l_action_prms.override_flag := RTRIM(p_action_prms.override_flag);
   l_action_prms.trip_name := RTRIM(p_action_prms.trip_name);

   IF l_action_prms.phase IS NULL THEN
      l_action_prms.phase := 1;
   END IF;

   l_index := p_entity_id_tab.FIRST;

   WHILE l_index IS NOT NULL LOOP
     OPEN c_attributes(p_entity_id_tab(l_index));
     FETCH c_attributes  INTO
       l_trip_id,
       l_planned_flag,
       l_lane_id,
       l_load_tender_status,
       l_status_code,
       l_shipments_type_flag,
       l_ignore_for_planning; -- OTM R12, glog proj
       IF (c_attributes%NOTFOUND) THEN
          CLOSE c_attributes;
          --fnd_message.set_name('WSH','WSH_BAD_ENTITY');
          --fnd_message.set_token('ID',p_entity_id_tab(l_index));
          IF l_debug_on THEN
             wsh_debug_sv.log (l_module_name,'WSH_BAD_ENTITY');
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
       l_rec_attr_tab(l_index).status_code := l_status_code;
       l_rec_attr_tab(l_index).trip_id := l_trip_id;
       l_rec_attr_tab(l_index).planned_flag := l_planned_flag;
       l_rec_attr_tab(l_index).lane_id := l_lane_id;
       l_rec_attr_tab(l_index).load_tender_status := l_load_tender_status;
       l_rec_attr_tab(l_index).shipments_type_flag := l_shipments_type_flag;
       l_rec_attr_tab(l_index).ignore_for_planning := l_ignore_for_planning;--OTM R12, glog proj

       -- OTM R12, glog proj, add debug messages
       IF l_debug_on THEN
         wsh_debug_sv.log (l_module_name,'Trip id', l_trip_id);
         wsh_debug_sv.log (l_module_name,'Status Code', l_status_code);
         wsh_debug_sv.log (l_module_name,'Planned Flag', l_planned_flag);
         wsh_debug_sv.log (l_module_name,'Lane id', l_lane_id);
         wsh_debug_sv.log (l_module_name,'Load Tender Status', l_load_tender_status);
         wsh_debug_sv.log (l_module_name,'Shipment Type Flag', l_shipments_type_flag);
         wsh_debug_sv.log (l_module_name,'Ignore for Planning', l_ignore_for_planning);
       END IF;

     CLOSE c_attributes;

     l_index := p_entity_id_tab.NEXT(l_index);
   END LOOP;

   WSH_TRIPS_GRP.Trip_Action
   ( p_api_version_number     => p_api_version_number,
     p_init_msg_list          => p_init_msg_list,
     p_commit                 => p_commit,
     p_action_prms            => l_action_prms,
     p_rec_attr_tab           => l_rec_attr_tab,
     x_trip_out_rec           => l_trip_out_rec,
     x_def_rec                => l_def_rec,
     x_return_status          => l_return_status,
     x_msg_count              => x_msg_count,
     x_msg_data               => x_msg_data
   );

   IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name,'x_return_status', x_return_status);
   END IF;

   wsh_util_core.api_post_call(p_return_status    =>l_return_status,
                               x_num_warnings     =>l_num_warning,
                               x_num_errors       =>l_num_errors);

   x_return_status := l_return_status;

   IF l_num_warning > 0 THEN
      RAISE WSH_UTIL_CORE.G_EXC_WARNING;
   END IF;
   FND_MSG_PUB.Count_And_Get
   ( p_count => x_msg_count
   , p_data  => x_msg_data
   );

   IF l_debug_on THEN

        WSH_DEBUG_SV.pop(l_module_name);
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count
      , p_data  => x_msg_data
      );
      IF l_debug_on THEN
           wsh_debug_sv.log (l_module_name,'G_EXC_ERROR');
           WSH_DEBUG_SV.pop(l_module_name);
      END IF;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count
      , p_data  => x_msg_data
      );
      IF l_debug_on THEN
           wsh_debug_sv.log (l_module_name,'G_EXC_UNEXPECTED_ERROR');
           WSH_DEBUG_SV.pop(l_module_name);
      END IF;
   WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count
      , p_data  => x_msg_data
      );
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      IF l_debug_on THEN
           wsh_debug_sv.log (l_module_name,'G_EXC_WARNING');
           WSH_DEBUG_SV.pop(l_module_name);
      END IF;
   WHEN OTHERS THEN
     wsh_util_core.default_handler('WSH_TRIPS_GRP.TRIP_ACTION',
                                                            l_module_name);
      FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count
      , p_data  => x_msg_data
      );

      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      IF l_debug_on THEN
           wsh_debug_sv.log (l_module_name,'Error',substr(sqlerrm,1,200));
           WSH_DEBUG_SV.pop(l_module_name);
      END IF;

END Trip_Action;


/*------------------------------------------------------------
  PROCEDURE Stop_Action  This is the wrapper for the
            stop action
-------------------------------------------------------------*/
PROCEDURE Stop_Action
(   p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    p_commit                 IN   VARCHAR2,
    p_entity_id_tab          IN   wsh_util_core.id_tab_type,
    p_action_prms            IN   WSH_TRIP_STOPS_GRP.action_parameters_rectype,
    x_stop_out_rec           OUT  NOCOPY WSH_TRIP_STOPS_GRP.stopActionOutRecType,
    x_return_status          OUT  NOCOPY VARCHAR2,
    x_msg_count              OUT  NOCOPY NUMBER,
    x_msg_data               OUT  NOCOPY VARCHAR2)
IS

   --l_stop_id_tab            wsh_util_core.id_tab_type;
   l_rec_attr_tab           WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type;
   l_action_prms            WSH_TRIP_STOPS_GRP.action_parameters_rectype;
   l_num_warning            NUMBER := 0;
   l_num_errors             NUMBER := 0;
   l_return_status          varchar2(1000);
   l_index                  NUMBER;
   l_stop_id                NUMBER;
   --l_stop_location_id       NUMBER;
   l_status_code            wsh_trip_stops.status_code%TYPE;
   l_stop_out_rec           WSH_TRIP_STOPS_GRP.stopActionOutRecType;

l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.'
                                                       || 'STOP_ACTION WRAPPER';
  l_def_rec                 WSH_TRIP_STOPS_GRP.default_parameters_rectype;

   CURSOR c_attributes(p_stop_id NUMBER)  IS
      SELECT  stop_id
             ,status_code
             ,trip_id
             ,stop_location_id
             ,stop_sequence_number
             ,PLANNED_ARRIVAL_DATE
             ,PLANNED_DEPARTURE_DATE
             ,actual_arrival_date
             ,actual_departure_date
             ,shipments_type_flag
     -- csun 10+ internal location change
             ,physical_location_id
             ,physical_stop_id
      FROM WSH_TRIP_STOPS
      WHERE stop_id = p_stop_id;

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
       wsh_debug_sv.push (l_module_name);
       wsh_debug_sv.log (l_module_name,'phase', p_action_prms.phase);
   END IF;

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   l_action_prms    := p_action_prms;
   l_action_prms.caller := RTRIM(p_action_prms.caller);
   l_action_prms.action_code := RTRIM(p_action_prms.action_code);
   l_action_prms.stop_action := RTRIM(p_action_prms.stop_action);
   l_action_prms.defer_interface_flag := RTRIM(p_action_prms.defer_interface_flag);
   l_action_prms.override_flag := RTRIM(p_action_prms.override_flag);

   IF l_action_prms.phase IS NULL THEN
      l_action_prms.phase := 1;
   END IF;

   l_index := p_entity_id_tab.FIRST;
   WHILE l_index IS NOT NULL LOOP
      OPEN c_attributes(p_entity_id_tab(l_index));
      FETCH c_attributes  INTO
        l_rec_attr_tab(l_index).stop_id,
        l_rec_attr_tab(l_index).status_code,
        l_rec_attr_tab(l_index).trip_id,
        l_rec_attr_tab(l_index).stop_location_id,
        l_rec_attr_tab(l_index).stop_sequence_number,
        l_rec_attr_tab(l_index).planned_arrival_date,
        l_rec_attr_tab(l_index).planned_departure_date,
        l_rec_attr_tab(l_index).actual_arrival_date,
        l_rec_attr_tab(l_index).actual_departure_date,
        l_rec_attr_tab(l_index).shipments_type_flag,
        l_rec_attr_tab(l_index).physical_location_id,
        l_rec_attr_tab(l_index).physical_stop_id;

        IF (c_attributes%NOTFOUND) THEN
           CLOSE c_attributes;
           IF l_debug_on THEN
              wsh_debug_sv.log (l_module_name,'WSH_BAD_ENTITY');
           END IF;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
      CLOSE c_attributes;
      l_index := p_entity_id_tab.NEXT(l_index);
   END LOOP;


   WSH_TRIP_STOPS_GRP.Stop_Action (
    p_api_version_number    => p_api_version_number,
    p_init_msg_list         => p_init_msg_list,
    p_commit                => p_commit,
    p_action_prms           => l_action_prms,
    p_rec_attr_tab          => l_rec_attr_tab,
    x_stop_out_rec          => l_stop_out_rec,
    x_def_rec               => l_def_rec,
    x_return_status         => l_return_status,
    x_msg_count             => x_msg_count,
    x_msg_data              =>x_msg_data
   );

   IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name,'l_return_status', l_return_status);
   END IF;

   wsh_util_core.api_post_call(p_return_status    =>l_return_status,
                               x_num_warnings     =>l_num_warning,
                               x_num_errors       =>l_num_errors);

   IF l_num_warning > 0 THEN
      RAISE WSH_UTIL_CORE.G_EXC_WARNING;
   END IF;

   x_return_status := l_return_status;

   FND_MSG_PUB.Count_And_Get
   ( p_count => x_msg_count
   , p_data  => x_msg_data
   );

   IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count
      , p_data  => x_msg_data
      );
      IF l_debug_on THEN
           wsh_debug_sv.log (l_module_name,'G_EXC_ERROR');
           WSH_DEBUG_SV.pop(l_module_name);
      END IF;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count
      , p_data  => x_msg_data
      );
      IF l_debug_on THEN
           wsh_debug_sv.log (l_module_name,'G_EXC_UNEXPECTED_ERROR');
           WSH_DEBUG_SV.pop(l_module_name);
      END IF;
   WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count
      , p_data  => x_msg_data
      );
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      IF l_debug_on THEN
           wsh_debug_sv.log (l_module_name,'G_EXC_WARNING');
           WSH_DEBUG_SV.pop(l_module_name);
      END IF;
   WHEN OTHERS THEN
     wsh_util_core.default_handler('WSH_TRIP_STOPS_GRP.STOP_ACTION',
                                                            l_module_name);
      FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count
      , p_data  => x_msg_data
      );

      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      IF l_debug_on THEN
           wsh_debug_sv.log (l_module_name,'Error',substr(sqlerrm,1,200));
           WSH_DEBUG_SV.pop(l_module_name);
      END IF;

END Stop_Action;

--heali


PROCEDURE Rtrim_stops_blank_space (
                p_in_rec  IN  WSH_TRIP_STOPS_PVT.trip_stop_rec_type,
                p_out_rec OUT NOCOPY  WSH_TRIP_STOPS_PVT.trip_stop_rec_type) IS
  l_debug_on BOOLEAN;
  l_module_name 		CONSTANT VARCHAR2(100) := 'wsh.plsql.' ||
                                 G_PKG_NAME || '.' || 'Rtrim_stops_blank_space';
BEGIN

   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      wsh_debug_sv.push (l_module_name, 'Rtrim_stops_blank_space');
   END IF;

   p_out_rec := p_in_rec;

   p_out_rec.STATUS_CODE := RTRIM(p_in_rec.STATUS_CODE);
   p_out_rec.WEIGHT_UOM_CODE := RTRIM(p_in_rec.WEIGHT_UOM_CODE);
   p_out_rec.VOLUME_UOM_CODE := RTRIM(p_in_rec.VOLUME_UOM_CODE);
   p_out_rec.DEPARTURE_SEAL_CODE := RTRIM(p_in_rec.DEPARTURE_SEAL_CODE);
   p_out_rec.TP_ATTRIBUTE_CATEGORY := RTRIM(p_in_rec.TP_ATTRIBUTE_CATEGORY);
   p_out_rec.TP_ATTRIBUTE1 := RTRIM(p_in_rec.TP_ATTRIBUTE1);
   p_out_rec.TP_ATTRIBUTE2 := RTRIM(p_in_rec.TP_ATTRIBUTE2);
   p_out_rec.TP_ATTRIBUTE3 := RTRIM(p_in_rec.TP_ATTRIBUTE3);
   p_out_rec.TP_ATTRIBUTE4 := RTRIM(p_in_rec.TP_ATTRIBUTE4);
   p_out_rec.TP_ATTRIBUTE5 := RTRIM(p_in_rec.TP_ATTRIBUTE5);
   p_out_rec.TP_ATTRIBUTE6 := RTRIM(p_in_rec.TP_ATTRIBUTE6);
   p_out_rec.TP_ATTRIBUTE7 := RTRIM(p_in_rec.TP_ATTRIBUTE7);
   p_out_rec.TP_ATTRIBUTE8 := RTRIM(p_in_rec.TP_ATTRIBUTE8);
   p_out_rec.TP_ATTRIBUTE9 := RTRIM(p_in_rec.TP_ATTRIBUTE9);
   p_out_rec.TP_ATTRIBUTE10 := RTRIM(p_in_rec.TP_ATTRIBUTE10);
   p_out_rec.TP_ATTRIBUTE11 := RTRIM(p_in_rec.TP_ATTRIBUTE11);
   p_out_rec.TP_ATTRIBUTE12 := RTRIM(p_in_rec.TP_ATTRIBUTE12);
   p_out_rec.TP_ATTRIBUTE13 := RTRIM(p_in_rec.TP_ATTRIBUTE13);
   p_out_rec.TP_ATTRIBUTE14 := RTRIM(p_in_rec.TP_ATTRIBUTE14);
   p_out_rec.TP_ATTRIBUTE15 := RTRIM(p_in_rec.TP_ATTRIBUTE15);
   p_out_rec.ATTRIBUTE_CATEGORY := RTRIM(p_in_rec.ATTRIBUTE_CATEGORY);
   p_out_rec.ATTRIBUTE1 := RTRIM(p_in_rec.ATTRIBUTE1);
   p_out_rec.ATTRIBUTE2 := RTRIM(p_in_rec.ATTRIBUTE2);
   p_out_rec.ATTRIBUTE3 := RTRIM(p_in_rec.ATTRIBUTE3);
   p_out_rec.ATTRIBUTE4 := RTRIM(p_in_rec.ATTRIBUTE4);
   p_out_rec.ATTRIBUTE5 := RTRIM(p_in_rec.ATTRIBUTE5);
   p_out_rec.ATTRIBUTE6 := RTRIM(p_in_rec.ATTRIBUTE6);
   p_out_rec.ATTRIBUTE7 := RTRIM(p_in_rec.ATTRIBUTE7);
   p_out_rec.ATTRIBUTE8 := RTRIM(p_in_rec.ATTRIBUTE8);
   p_out_rec.ATTRIBUTE9 := RTRIM(p_in_rec.ATTRIBUTE9);
   p_out_rec.ATTRIBUTE10 := RTRIM(p_in_rec.ATTRIBUTE10);
   p_out_rec.ATTRIBUTE11 := RTRIM(p_in_rec.ATTRIBUTE11);
   p_out_rec.ATTRIBUTE12 := RTRIM(p_in_rec.ATTRIBUTE12);
   p_out_rec.ATTRIBUTE13 := RTRIM(p_in_rec.ATTRIBUTE13);
   p_out_rec.ATTRIBUTE14 := RTRIM(p_in_rec.ATTRIBUTE14);
   p_out_rec.ATTRIBUTE15 := RTRIM(p_in_rec.ATTRIBUTE15);
   p_out_rec.TRACKING_DRILLDOWN_FLAG := RTRIM(p_in_rec.TRACKING_DRILLDOWN_FLAG);
   p_out_rec.TRACKING_REMARKS := RTRIM(p_in_rec.TRACKING_REMARKS);
   p_out_rec.TRIP_NAME := RTRIM(p_in_rec.TRIP_NAME);
   p_out_rec.STOP_LOCATION_CODE := RTRIM(p_in_rec.STOP_LOCATION_CODE);
   p_out_rec.WEIGHT_UOM_DESC := RTRIM(p_in_rec.WEIGHT_UOM_DESC);
   p_out_rec.VOLUME_UOM_DESC := RTRIM(p_in_rec.VOLUME_UOM_DESC);
   p_out_rec.PENDING_INTERFACE_FLAG := RTRIM(p_in_rec.PENDING_INTERFACE_FLAG);

   IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;

EXCEPTION

   WHEN OTHERS THEN
      wsh_util_core.default_handler (
        'WSH_TRIP_STOPS_GRP.Rtrim_stops_blank_space', l_module_name);
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured.'||
         ' Oracle error message is '|| SQLERRM,
                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;
      RAISE;

END Rtrim_stops_blank_space;


--========================================================================
-- PROCEDURE : Create_Update_Stop      Wrapper  API
--
-- PARAMETERS: p_api_version_number    known api versionerror buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             p_commit                'T'/'F'
--             p_in_rec                stopInRecType
--             p_rec_attr_tab          Table of Attributes for the stop entity
--             p_stop_OUT_tab          Table of Output Attributes for the stop entity
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This calls core API WSH_TRIP_STOPS_GRP.CREATE_UPDATE_STOP
--========================================================================
PROCEDURE CREATE_UPDATE_STOP(
        p_api_version_number    IN NUMBER,
        p_init_msg_list         IN VARCHAR2,
        p_commit                IN VARCHAR2,
        p_in_rec                IN WSH_TRIP_STOPS_GRP.stopInRecType,
        p_rec_attr_tab          IN WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type,
        x_stop_out_tab          OUT NOCOPY WSH_TRIP_STOPS_GRP.stop_out_tab_type,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2) IS

l_api_version_number    CONSTANT NUMBER := 1.0;
l_api_name              CONSTANT VARCHAR2(30) := 'Create_Update_Stop';
l_debug_on BOOLEAN;
l_module_name           CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_UPDATE_STOP';

l_num_warnings           NUMBER := 0;
l_num_errors             NUMBER := 0;
l_rec_attr_tab           WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type;
l_index                  NUMBER;
l_in_rec                 WSH_TRIP_STOPS_GRP.stopInRecType;
l_stop_wt_vol_out_tab	 WSH_TRIP_STOPS_GRP.Stop_Wt_Vol_tab_type; --bug 2796095

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
   SAVEPOINT create_update_stop_wrap_grp;

   IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name);
      wsh_debug_sv.log(l_module_name,'Caller is ', p_in_rec.caller);
      wsh_debug_sv.log(l_module_name,'Phase is ', p_in_rec.phase);
      wsh_debug_sv.log(l_module_name,'Action Code is ', p_in_rec.action_code);
      wsh_debug_sv.log(l_module_name,'Number of Records is ', p_rec_attr_tab.COUNT);
   END IF;

   l_in_rec := p_in_rec;
   l_in_rec.caller := RTRIM(p_in_rec.caller);
   l_in_rec.action_code := RTRIM(p_in_rec.action_code);

   l_index := p_rec_attr_tab.FIRST;
   WHILE l_index IS NOT NULL LOOP
      Rtrim_stops_blank_space(p_rec_attr_tab(l_index),
                              l_rec_attr_tab(l_index));
      l_index := p_rec_attr_tab.NEXT(l_index);
   END LOOP;

   WSH_TRIP_STOPS_GRP.CREATE_UPDATE_STOP(
        p_api_version_number    => p_api_version_number,
        p_init_msg_list         => p_init_msg_list,
        p_commit                => p_commit,
        p_in_rec                => l_in_rec,
        p_rec_attr_tab          => l_rec_attr_tab,
        x_stop_out_tab          => x_stop_out_tab,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data,
        x_stop_wt_vol_out_tab   => l_stop_wt_vol_out_tab  --bug 2796095
     );

    wsh_util_core.api_post_call(
      p_return_status    =>x_return_status,
      x_num_warnings     =>l_num_warnings,
      x_num_errors       =>l_num_errors);
    --
    IF l_num_warnings > 0 THEN
      RAISE WSH_UTIL_CORE.G_EXC_WARNING;
    END IF;
    --
    FND_MSG_PUB.Count_And_Get (
      p_count => x_msg_count,
      p_data  => x_msg_data);
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_update_stop_wrap_grp;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
        (
         p_count  => x_msg_count,
         p_data  =>  x_msg_data,
         p_encoded => FND_API.G_FALSE
        );
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_update_stop_wrap_grp;
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
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
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
    WHEN OTHERS THEN
      ROLLBACK TO create_update_stop_wrap_grp;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_INTERFACE_GRP.CREATE_UPDATE_STOP');
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
END Create_Update_Stop;


PROCEDURE Rtrim_trips_blank_space (
                p_in_rec  IN  WSH_TRIPS_PVT.trip_rec_type,
                p_out_rec OUT NOCOPY  WSH_TRIPS_PVT.trip_rec_type) IS
  l_debug_on BOOLEAN;
  l_module_name 		CONSTANT VARCHAR2(100) := 'wsh.plsql.' ||
                                 G_PKG_NAME || '.' || 'Rtrim_trips_blank_space';
BEGIN

   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      wsh_debug_sv.push (l_module_name, 'Rtrim_trips_blank_space');
   END IF;

   p_out_rec := p_in_rec;

   p_out_rec.NAME           := RTRIM(p_in_rec.NAME);
   p_out_rec.PLANNED_FLAG  := RTRIM(p_in_rec.PLANNED_FLAG);
   p_out_rec.STATUS_CODE  := RTRIM(p_in_rec.STATUS_CODE);
   p_out_rec.VEHICLE_NUMBER       := RTRIM(p_in_rec.VEHICLE_NUMBER);
   p_out_rec.VEHICLE_NUM_PREFIX  := RTRIM(p_in_rec.VEHICLE_NUM_PREFIX);
   p_out_rec.SHIP_METHOD_CODE   := RTRIM(p_in_rec.SHIP_METHOD_CODE);
   p_out_rec.ROUTING_INSTRUCTIONS  := RTRIM(p_in_rec.ROUTING_INSTRUCTIONS);
   p_out_rec.ATTRIBUTE_CATEGORY   := RTRIM(p_in_rec.ATTRIBUTE_CATEGORY);
   p_out_rec.ATTRIBUTE1          := RTRIM(p_in_rec.ATTRIBUTE1);
   p_out_rec.ATTRIBUTE2        := RTRIM(p_in_rec.ATTRIBUTE2);
   p_out_rec.ATTRIBUTE3       := RTRIM(p_in_rec.ATTRIBUTE3);
   p_out_rec.ATTRIBUTE4      := RTRIM(p_in_rec.ATTRIBUTE4);
   p_out_rec.ATTRIBUTE5     := RTRIM(p_in_rec.ATTRIBUTE5);
   p_out_rec.ATTRIBUTE6    := RTRIM(p_in_rec.ATTRIBUTE6);
   p_out_rec.ATTRIBUTE7   := RTRIM(p_in_rec.ATTRIBUTE7);
   p_out_rec.ATTRIBUTE8                  := RTRIM(p_in_rec.ATTRIBUTE8);
   p_out_rec.ATTRIBUTE9                 := RTRIM(p_in_rec.ATTRIBUTE9);
   p_out_rec.ATTRIBUTE10               := RTRIM(p_in_rec.ATTRIBUTE10);
   p_out_rec.ATTRIBUTE11              := RTRIM(p_in_rec.ATTRIBUTE11);
   p_out_rec.ATTRIBUTE12             := RTRIM(p_in_rec.ATTRIBUTE12);
   p_out_rec.ATTRIBUTE13            := RTRIM(p_in_rec.ATTRIBUTE13);
   p_out_rec.ATTRIBUTE14           := RTRIM(p_in_rec.ATTRIBUTE14);
   p_out_rec.ATTRIBUTE15          := RTRIM(p_in_rec.ATTRIBUTE15);
   p_out_rec.SERVICE_LEVEL:= RTRIM(p_in_rec.SERVICE_LEVEL);
   p_out_rec.MODE_OF_TRANSPORT:= RTRIM(p_in_rec.MODE_OF_TRANSPORT);
   p_out_rec.FREIGHT_TERMS_CODE:= RTRIM(p_in_rec.FREIGHT_TERMS_CODE);
   p_out_rec.CONSOLIDATION_ALLOWED:= RTRIM(p_in_rec.CONSOLIDATION_ALLOWED);
   p_out_rec.LOAD_TENDER_STATUS:= RTRIM(p_in_rec.LOAD_TENDER_STATUS);
   p_out_rec.BOOKING_NUMBER:= RTRIM(p_in_rec.BOOKING_NUMBER);
   p_out_rec.ARRIVE_AFTER_TRIP_NAME:= RTRIM(p_in_rec.ARRIVE_AFTER_TRIP_NAME);
   p_out_rec.SHIP_METHOD_NAME:= RTRIM(p_in_rec.SHIP_METHOD_NAME);
   p_out_rec.VEHICLE_ITEM_DESC:= RTRIM(p_in_rec.VEHICLE_ITEM_DESC);
   p_out_rec.VEHICLE_ORGANIZATION_CODE:= RTRIM(p_in_rec.VEHICLE_ORGANIZATION_CODE);
   p_out_rec.VESSEL                  := RTRIM(p_in_rec.VESSEL);
   p_out_rec.VOYAGE_NUMBER          := RTRIM(p_in_rec.VOYAGE_NUMBER);
   p_out_rec.PORT_OF_LOADING       := RTRIM(p_in_rec.PORT_OF_LOADING);
   p_out_rec.PORT_OF_DISCHARGE    := RTRIM(p_in_rec.PORT_OF_DISCHARGE);
   p_out_rec.WF_NAME             := RTRIM(p_in_rec.WF_NAME);
   p_out_rec.WF_PROCESS_NAME    := RTRIM(p_in_rec.WF_PROCESS_NAME);
   p_out_rec.WF_ITEM_KEY       := RTRIM(p_in_rec.WF_ITEM_KEY);
   p_out_rec.WAIT_TIME_UOM    := RTRIM(p_in_rec.WAIT_TIME_UOM);
  p_out_rec.CARRIER_RESPONSE       := RTRIM(p_in_rec.CARRIER_RESPONSE);
  p_out_rec.OPERATOR       := RTRIM(p_in_rec.OPERATOR);
   p_out_rec.CARRIER_REFERENCE_NUMBER := RTRIM(p_in_rec.CARRIER_REFERENCE_NUMBER);
   p_out_rec.CONSIGNEE_CARRIER_AC_NO  := RTRIM(p_in_rec.CONSIGNEE_CARRIER_AC_NO);

   IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;

EXCEPTION

   WHEN OTHERS THEN
      wsh_util_core.default_handler (
        'WSH_TRIP_STOPS_GRP.Rtrim_trips_blank_space', l_module_name);
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured.'||
         ' Oracle error message is '|| SQLERRM,
                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;
      RAISE;

END Rtrim_trips_blank_space;
--========================================================================
-- PROCEDURE : Create_Update_Trip      Wrapper API
--
-- PARAMETERS: p_api_version_number    known api versionerror buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_trip_info_tab         Table of Attributes for the trip entity
--             p_IN_rec                Input Attributes for the trip entity
--             p_OUT_rec               Table of output Attributes for the trip entity
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This calls Core API WSH_TRIPS_GRP.Create_Update_Trip.
--========================================================================
PROCEDURE Create_Update_Trip(
        p_api_version_number     IN     NUMBER,
        p_init_msg_list          IN     VARCHAR2,
        p_commit                 IN     VARCHAR2,
        x_return_status          OUT    NOCOPY VARCHAR2,
        x_msg_count              OUT    NOCOPY NUMBER,
        x_msg_data               OUT    NOCOPY VARCHAR2,
        p_trip_info_tab          IN     WSH_TRIPS_PVT.Trip_Attr_Tbl_Type,
        p_In_rec                 IN     WSH_TRIPS_GRP.tripInRecType,
        x_Out_Tab                OUT    NOCOPY WSH_TRIPS_GRP.trip_Out_Tab_Type) IS

l_api_version_number    CONSTANT NUMBER := 1.0;
l_api_name              CONSTANT VARCHAR2(30) := 'Create_Update_Trip';
l_debug_on BOOLEAN;
l_index                 NUMBER;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_UPDATE_TRIP';

l_num_warnings           NUMBER := 0;
l_num_errors             NUMBER := 0;
l_trip_info_tab          WSH_TRIPS_PVT.Trip_Attr_Tbl_Type;
l_In_rec                 WSH_TRIPS_GRP.tripInRecType;

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
   SAVEPOINT create_update_trip_wrap_grp;

   IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name);
      wsh_debug_sv.log(l_module_name,'Caller is ', p_in_rec.caller);
      wsh_debug_sv.log(l_module_name,'Phase is ', p_in_rec.phase);
      wsh_debug_sv.log(l_module_name,'Action Code is ', p_in_rec.action_code);
      wsh_debug_sv.log(l_module_name,'Number of Records is ', p_trip_info_tab.COUNT);
   END IF;

   l_in_rec := p_in_rec;
   l_in_rec.caller := RTRIM(p_in_rec.caller);
   l_in_rec.action_code := RTRIM(p_in_rec.action_code);

   l_index := p_trip_info_tab.FIRST;
   WHILE l_index IS NOT NULL LOOP
      Rtrim_trips_blank_space(p_trip_info_tab(l_index),
                                       l_trip_info_tab(l_index));
      l_index := p_trip_info_tab.NEXT(l_index);
   END LOOP;

   WSH_TRIPS_GRP.Create_Update_Trip(
        p_api_version_number     => p_api_version_number,
        p_init_msg_list          => p_init_msg_list,
        p_commit                 => p_commit,
        x_return_status          => x_return_status,
        x_msg_count              => x_msg_count,
        x_msg_data               => x_msg_data,
        p_trip_info_tab          => l_trip_info_tab,
        p_In_rec                 => l_In_rec,
        x_Out_tab                => x_Out_Tab);

    wsh_util_core.api_post_call(
      p_return_status    =>x_return_status,
      x_num_warnings     =>l_num_warnings,
      x_num_errors       =>l_num_errors);
    --
    IF l_num_warnings > 0 THEN
      RAISE WSH_UTIL_CORE.G_EXC_WARNING;
    END IF;
    --
    FND_MSG_PUB.Count_And_Get (
      p_count => x_msg_count,
      p_data  => x_msg_data);
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_update_trip_wrap_grp;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
        (
         p_count  => x_msg_count,
         p_data  =>  x_msg_data,
         p_encoded => FND_API.G_FALSE
        );
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_update_trip_wrap_grp;
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
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
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
    WHEN OTHERS THEN
      ROLLBACK TO create_update_trip_wrap_grp;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_INTERFACE_GRP.CREATE_UPDATE_TRIP');
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
END Create_Update_Trip;


PROCEDURE Rtrim_freightcost_blank_space (
              p_in_rec  IN  WSH_FREIGHT_COSTS_PVT.Freight_Cost_Rec_Type,
              p_out_rec OUT NOCOPY  WSH_FREIGHT_COSTS_PVT.Freight_Cost_Rec_Type) IS
  l_debug_on BOOLEAN;
  l_module_name 		CONSTANT VARCHAR2(100) := 'wsh.plsql.' ||
                           G_PKG_NAME || '.' || 'Rtrim_freightcost_blank_space';
BEGIN

   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      wsh_debug_sv.push (l_module_name, 'Rtrim_freightcost_blank_space');
   END IF;

   p_out_rec := p_in_rec;

   p_out_rec.CALCULATION_METHOD := RTRIM(p_in_rec.CALCULATION_METHOD);
   p_out_rec.UOM               := RTRIM(p_in_rec.UOM);
   p_out_rec.CURRENCY_CODE    := RTRIM(p_in_rec.CURRENCY_CODE);
   p_out_rec.CONVERSION_TYPE_CODE  := RTRIM(p_in_rec.CONVERSION_TYPE_CODE);
   p_out_rec.ATTRIBUTE_CATEGORY:= RTRIM(p_in_rec.ATTRIBUTE_CATEGORY);
   p_out_rec.ATTRIBUTE1:= RTRIM(p_in_rec.ATTRIBUTE1);
   p_out_rec.ATTRIBUTE2:= RTRIM(p_in_rec.ATTRIBUTE2);
   p_out_rec.ATTRIBUTE3	:= RTRIM(p_in_rec.ATTRIBUTE3);
   p_out_rec.ATTRIBUTE4	:= RTRIM(p_in_rec.ATTRIBUTE4);
   p_out_rec.ATTRIBUTE5	:= RTRIM(p_in_rec.ATTRIBUTE5);
   p_out_rec.ATTRIBUTE6:= RTRIM(p_in_rec.ATTRIBUTE6);
   p_out_rec.ATTRIBUTE7:= RTRIM(p_in_rec.ATTRIBUTE7);
   p_out_rec.ATTRIBUTE8:= RTRIM(p_in_rec.ATTRIBUTE8);
   p_out_rec.ATTRIBUTE9	:= RTRIM(p_in_rec.ATTRIBUTE9);
   p_out_rec.ATTRIBUTE10	:= RTRIM(p_in_rec.ATTRIBUTE10);
   p_out_rec.ATTRIBUTE11	:= RTRIM(p_in_rec.ATTRIBUTE11);
   p_out_rec.ATTRIBUTE12	:= RTRIM(p_in_rec.ATTRIBUTE12);
   p_out_rec.ATTRIBUTE13  	:= RTRIM(p_in_rec.ATTRIBUTE13);
   p_out_rec.ATTRIBUTE14:= RTRIM(p_in_rec.ATTRIBUTE14);
   p_out_rec.ATTRIBUTE15:= RTRIM(p_in_rec.ATTRIBUTE15);
   p_out_rec.CHARGE_SOURCE_CODE:= RTRIM(p_in_rec.CHARGE_SOURCE_CODE);
   p_out_rec.LINE_TYPE_CODE:= RTRIM(p_in_rec.LINE_TYPE_CODE);
   p_out_rec.ESTIMATED_FLAG:= RTRIM(p_in_rec.ESTIMATED_FLAG);
   p_out_rec.FREIGHT_CODE  := RTRIM(p_in_rec.FREIGHT_CODE);
   p_out_rec.TRIP_NAME    := RTRIM(p_in_rec.TRIP_NAME);
   p_out_rec.DELIVERY_NAME    := RTRIM(p_in_rec.DELIVERY_NAME);
   p_out_rec.FREIGHT_COST_TYPE := RTRIM(p_in_rec.FREIGHT_COST_TYPE);

   IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;

EXCEPTION

   WHEN OTHERS THEN
      wsh_util_core.default_handler (
        'WSH_TRIP_STOPS_GRP.Rtrim_freightcost_blank_space', l_module_name);
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured.'||
         ' Oracle error message is '|| SQLERRM,
                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;
      RAISE;

END Rtrim_freightcost_blank_space;


PROCEDURE Create_Update_Freight_Costs(
        p_api_version_number     IN     NUMBER,
        p_init_msg_list          IN     VARCHAR2,
        p_commit                 IN     VARCHAR2,
        x_return_status          OUT    NOCOPY VARCHAR2,
        x_msg_count              OUT    NOCOPY NUMBER,
        x_msg_data               OUT    NOCOPY VARCHAR2,
        p_freight_info_tab       IN     WSH_FREIGHT_COSTS_GRP.freight_rec_tab_type,
        p_in_rec                 IN     WSH_FREIGHT_COSTS_GRP.freightInRecType,
        x_out_tab                OUT    NOCOPY WSH_FREIGHT_COSTS_GRP.freight_out_tab_type) IS

l_api_version_number    CONSTANT NUMBER := 1.0;
l_api_name              CONSTANT VARCHAR2(30) := 'Create_Update_Freight_Costs';
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Create_Update_Freight_Costs';

l_num_warnings           NUMBER := 0;
l_num_errors             NUMBER := 0;
l_freight_info_tab       WSH_FREIGHT_COSTS_GRP.freight_rec_tab_type;
l_index                  NUMBER;
l_in_rec                 WSH_FREIGHT_COSTS_GRP.freightInRecType;

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
   SAVEPOINT Create_Update_Freight_Costs_WG;

   IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name);
      wsh_debug_sv.log(l_module_name,'Caller is ', p_in_rec.caller);
      wsh_debug_sv.log(l_module_name,'Phase is ', p_in_rec.phase);
      wsh_debug_sv.log(l_module_name,'Action Code is ', p_in_rec.action_code);
   END IF;

   l_in_rec    := p_in_rec;
   l_in_rec.caller := RTRIM(p_in_rec.caller);
   l_in_rec.action_code := RTRIM(p_in_rec.action_code);

   l_index := p_freight_info_tab.FIRST;
   WHILE l_index IS NOT NULL LOOP
      Rtrim_freightcost_blank_space(p_freight_info_tab(l_index),
                                    l_freight_info_tab(l_index));
      l_index := p_freight_info_tab.NEXT(l_index);
   END LOOP;

   WSH_FREIGHT_COSTS_GRP.Create_Update_Freight_Costs(
      p_api_version_number     => p_api_version_number,
      p_init_msg_list          => p_init_msg_list,
      p_commit                 => p_commit,
      x_return_status          => x_return_status,
      x_msg_count              => x_msg_count,
      x_msg_data               => x_msg_data,
      p_freight_info_tab       => l_freight_info_tab,
      p_in_rec                 => l_in_rec,
      x_out_tab                => x_out_tab );

    wsh_util_core.api_post_call(
      p_return_status    =>x_return_status,
      x_num_warnings     =>l_num_warnings,
      x_num_errors       =>l_num_errors);
    --
    IF l_num_warnings > 0 THEN
      RAISE WSH_UTIL_CORE.G_EXC_WARNING;
    END IF;
    --
    FND_MSG_PUB.Count_And_Get (
      p_count => x_msg_count,
      p_data  => x_msg_data);
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Create_Update_Freight_Costs_WG;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
        (
         p_count  => x_msg_count,
         p_data  =>  x_msg_data,
         p_encoded => FND_API.G_FALSE
        );
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Update_Freight_Costs_WG;
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
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
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
    WHEN OTHERS THEN
      ROLLBACK TO Create_Update_Freight_Costs_WG;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_INTERFACE_GRP.CREATE_UPDATE_FREIGHT_COSTS');
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
END Create_Update_Freight_costs;
-- heali

--========================================================================
-- PROCEDURE : Update_Delivery_Leg  Wrapper API      PUBLIC
--
-- PARAMETERS: p_api_version_number    known api version error buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_in_rec                Record for caller, phase
--                                     and action_code ('UPDATE' )
--             p_delivery_leg_tab      Table of Attributes for the delivery leg entity
--             x_out_rec               for future usage.
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Updates a record in wsh_delivery_legs table with information
--             specified in p_delivery_leg_tab. Please note that as per perfomance
--             standards, if you need to update a field to null, then use the
--             fnd_api.g_miss_(num/char/date) value for that field. If a field
--             has a null value, it will not be updated.

PROCEDURE Update_Delivery_Leg(
          p_api_version_number     IN     NUMBER,
          p_init_msg_list          IN     VARCHAR2,
          p_commit                 IN     VARCHAR2,
          p_delivery_leg_tab       IN     WSH_DELIVERY_LEGS_GRP.dlvy_leg_tab_type,
          p_in_rec                 IN     WSH_DELIVERY_LEGS_GRP.action_parameters_rectype,
          x_out_rec                OUT    NOCOPY WSH_DELIVERY_LEGS_GRP.action_out_rec_type,
          x_return_status          OUT    NOCOPY VARCHAR2,
          x_msg_count              OUT    NOCOPY NUMBER,
          x_msg_data               OUT    NOCOPY VARCHAR2) IS


l_api_version_number    CONSTANT NUMBER := 1.0;
l_api_name              CONSTANT VARCHAR2(30) := 'Update_Delivery_Leg';
l_debug_on BOOLEAN;
l_module_name           CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_DELIVERY_LEGS';

BEGIN

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
  END IF;

  WSH_DELIVERY_LEGS_GRP.Update_Delivery_Leg(
    p_api_version_number     => p_api_version_number,
    p_init_msg_list          => p_init_msg_list,
    p_commit                 => p_commit,
    p_delivery_leg_tab       => p_delivery_leg_tab,
    p_in_rec                 => p_in_rec,
    x_out_rec                => x_out_rec,
    x_return_status          => x_return_status,
   x_msg_count              => x_msg_count,
   x_msg_data               => x_msg_data);

  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;


EXCEPTION

  WHEN others THEN
      wsh_util_core.default_handler('WSH_DELIVERY_LEGS_GRP.Update_Delivery_Leg',l_module_name);
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;

END Update_Delivery_Leg;


END WSH_INTERFACE_GRP;

/
