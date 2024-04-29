--------------------------------------------------------
--  DDL for Package Body WSH_TRIPS_ACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_TRIPS_ACTIONS" as
/* $Header: WSHTRACB.pls 120.26.12010000.4 2010/02/04 11:13:09 gbhargav ship $ */

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_TRIPS_ACTIONS';
--

g_int_mask              VARCHAR2(12) := 'S00000000000';
type numtabvc2 is table of number index by varchar2(2000);
TYPE g_num_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE g_v30_tbl_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

TYPE Del_Rec_Type IS RECORD (
     delivery_id  g_num_tbl_type,
     INITIAL_PICKUP_LOCATION_ID  g_v30_tbl_type,
     ULTIMATE_DROPOFF_LOCATION_ID  g_v30_tbl_type,
     MODE_OF_TRANSPORT  g_v30_tbl_type,
     service_level g_v30_tbl_type,
     carrier_id g_v30_tbl_type
);

-- SSN change
-- Global Variable to cache the sequencing mode
  G_STOP_SEQ_MODE NUMBER;

-- SSN change
-- New API to cache Stop sequence mode base on profile value
FUNCTION Get_Stop_Seq_Mode return Number is

  l_debug_on BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100):= 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_STOP_SEQ_MODE';

  -- OTM R12, glog proj
  l_gc3_is_installed VARCHAR2(1);

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

  --OTM R12, glog proj, use Global Variable
  l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED;

  -- If null, call the function
  IF l_gc3_is_installed IS NULL THEN
    l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED;
  END IF;
  -- end of OTM R12, glog proj

  -- OTM R12, glog project
  -- IF GC3 is INSTALLED, Mode should be SSN
  IF G_STOP_SEQ_MODE IS NULL THEN--{
    IF l_gc3_is_installed = 'Y' THEN
      G_STOP_SEQ_MODE := WSH_INTERFACE_GRP.G_STOP_SEQ_MODE_SSN;
    ELSE
      IF WSH_UTIL_CORE.FTE_IS_INSTALLED = 'Y' THEN
        G_STOP_SEQ_MODE := WSH_INTERFACE_GRP.G_STOP_SEQ_MODE_PAD;
      ELSIF fnd_profile.value('WSH_STOP_SEQ_MODE') = ('PAD') THEN
        G_STOP_SEQ_MODE := WSH_INTERFACE_GRP.G_STOP_SEQ_MODE_PAD;
      ELSE -- non-existent profile or any other value of fnd_profile.value(' WSH_STOP_SEQ_MODE') implies SSN
        G_STOP_SEQ_MODE := WSH_INTERFACE_GRP.G_STOP_SEQ_MODE_SSN;
      END IF;
    END IF;
  END IF;--}

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Internal Value of Sequence Mode',g_stop_seq_mode);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  Return G_STOP_SEQ_MODE;

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    -- Bug 4253334, default value is SSN mode
    RETURN nvl(G_STOP_SEQ_MODE, WSH_INTERFACE_GRP.G_STOP_SEQ_MODE_SSN);
END get_stop_seq_mode;

PROCEDURE Get_Trip_Defaults(p_trip_id in NUMBER,
                            p_trip_name in VARCHAR2 DEFAULT NULL,
                            x_def_rec IN OUT  NOCOPY WSH_TRIPS_GRP.default_parameters_rectype,
                            x_return_Status OUT NOCOPY varchar2 ) IS

  cursor get_pickup_stop (c_trip_id number) is
       select distinct st.stop_id, st.stop_location_id
       from   wsh_trip_stops st,
              wsh_delivery_legs dg
       where  st.trip_id = c_trip_id
       and    dg.pick_up_stop_id = st.stop_id;
   -- Bug 9002479 :  Select '1' changed to Select 1
   cursor get_pickup_delivery (c_stop_id number, c_stop_location_id number) is
       select 1
       from dual
       where exists (select dl.delivery_id
                     from   wsh_new_deliveries dl,
                            wsh_delivery_legs dg
                     where  dg.pick_up_stop_id = c_stop_id
                     and    dl.initial_pickup_location_id = c_stop_location_id
                     AND    nvl(dl.shipment_direction,'O') IN ('O','IO')   -- J-IB-NPARIKH
                     and    dl.delivery_id = dg.delivery_id );

  cursor get_org_id (c_trip_id number) is
       select distinct dl.organization_id
       from   wsh_trip_stops st, wsh_delivery_legs dg, wsh_new_deliveries dl
       where  st.trip_id = c_trip_id
       and    dg.delivery_id = dl.delivery_id
       and    st.stop_location_id = dl.initial_pickup_location_id
       and    st.stop_id = dg.pick_up_stop_id;

  cursor  get_doc_set (c_report_set_id NUMBER) is
       select name
       from   wsh_report_sets
       where  report_set_id = c_report_set_id;

  l_org_id                      number;
  l_temp_org_id                 number;
  l_param_info                  WSH_SHIPPING_PARAMS_PVT.Parameter_Rec_Typ ;

  -- Bug 3346237:Value for parameter Defer_interface to be taken from Global Parameters table.
  l_global_info                 WSH_SHIPPING_PARAMS_PVT.Global_Parameters_Rec_Typ;
  l_stop_id                     number;
  l_stop_location_id            number;
  l_exists                      number;
  -- Bug 9002479 :  increased size to 1000 from 100
  l_stop_location_code          varchar2(1000);
  l_return_status               varchar2(500);
  l_num_errors                  number;
  l_num_warning                 number;


l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Get_Trip_Defaults';
  e_trip_confirm_exception   EXCEPTION;


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
       WSH_DEBUG_SV.log(l_module_name,'p_trip_id', p_trip_id);
       WSH_DEBUG_SV.log(l_module_name,'p_trip_name', p_trip_name);
   END IF;

         x_return_status := wsh_util_core.g_ret_sts_success;

         open get_pickup_stop (p_trip_id);
         fetch get_pickup_stop into l_stop_id, l_stop_location_id;
         if get_pickup_stop%notfound then
            close get_pickup_stop;
            fnd_message.set_name('WSH','WSH_TRIP_NO_STOPS');
            fnd_message.set_token('TRIP_NAME',p_trip_name);
            x_return_status := wsh_util_core.g_ret_sts_error;
            raise e_trip_confirm_exception;
         else
            fetch get_pickup_stop into l_stop_id, l_stop_location_id;
            if get_pickup_stop%found then
               close get_pickup_stop;
               fnd_message.set_name('WSH','WSH_TRIP_MULTIPLE_PICKUPS');
               l_stop_location_code := fnd_message.get;
               x_def_rec.trip_multiple_pickup := 'Y';
            else
               close get_pickup_stop;
               l_stop_location_code := wsh_util_core.get_location_description(l_stop_location_id, 'NEW UI CODE');
               l_stop_location_code := substrb(l_stop_location_code, 1, 60);
               open get_pickup_delivery(l_stop_id, l_stop_location_id);
               fetch get_pickup_delivery into l_exists;
               if get_pickup_delivery%notfound then
                  close get_pickup_delivery;
                  fnd_message.set_name('WSH','WSH_TRIP_CONFIRM_MISSING_DEL');
                  fnd_message.set_token('TRIP',p_trip_name);
                  fnd_message.set_token('STOP_NAME',l_stop_location_code);
                  x_return_status := wsh_util_core.g_ret_sts_error;
                  raise e_trip_confirm_exception;
               else
                  close get_pickup_delivery;
                  x_def_rec.trip_multiple_pickup := 'N';
               end if;
            end if;
         end if;

             -- set properties and default values on block

         x_def_rec.stop_location_code := l_stop_location_code;

         open get_org_id (p_trip_id);
         fetch get_org_id into l_org_id ;
         if get_org_id%notfound then
            l_org_id := NULL;
         else
            fetch get_org_id into l_temp_org_id;
            if get_org_id%notfound then
               l_temp_org_id := NULL;
            end if;
         end if;
         close get_org_id;

         if l_org_id is not null then
            -- LSP PROJECT : just added parameter names in the call.
            wsh_shipping_params_pvt.get(p_organization_id => l_org_id, x_param_info    => l_param_info, x_return_status   => l_return_status);
            wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                                        x_num_warnings     =>l_num_warning,
                                        x_num_errors       =>l_num_errors);

        -- Bug 3346237:Value for parameter Defer_interface to be taken from Global Parameters table.
        wsh_shipping_params_pvt.Get_Global_Parameters(
                    x_param_info => l_global_info,
                    x_return_status => l_return_status);

        wsh_util_core.api_post_call(p_return_status  =>l_return_status,
                                        x_num_warnings     =>l_num_warning,
                                        x_num_errors       =>l_num_errors);

            x_def_rec.defer_interface_flag := l_global_info.defer_interface ;

        if l_temp_org_id is null then
               x_def_rec.report_set_id := l_param_info.delivery_report_set_id;
               open get_doc_set (l_param_info.delivery_report_set_id);
               fetch get_doc_set into x_def_rec.report_set_name;
               if get_doc_set%notfound then
                  x_def_rec.report_set_id := NULL;
                  x_def_rec.report_set_name := NULL;
               end if;
               close get_doc_set;
            end if;
         end if;

    IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
    END IF;

   EXCEPTION

   WHEN e_trip_confirm_exception THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      wsh_util_core.add_message(x_return_status,l_module_name);
      IF l_debug_on THEN
           wsh_debug_sv.log (l_module_name,'G_EXC_ERROR');
           WSH_DEBUG_SV.pop(l_module_name);
      END IF;

   WHEN OTHERS THEN

     wsh_util_core.default_handler('WSH_TRIPS_ACTIONS.Get_Trip_Defaults');

      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      IF l_debug_on THEN
           wsh_debug_sv.log (l_module_name,'Others',substr(sqlerrm,1,200));
           WSH_DEBUG_SV.pop(l_module_name);
      END IF;


END Get_Trip_Defaults;


PROCEDURE Confirm_Trip (
                         p_trip_id        IN   NUMBER,
                         p_action_flag    IN   VARCHAR2,
                         p_intransit_flag IN   VARCHAR2,
                         p_close_flag     IN   VARCHAR2,
                         p_stage_del_flag IN   VARCHAR2,
                         p_report_set_id  IN   NUMBER,
                         p_ship_method    IN   VARCHAR2,
                         p_actual_dep_date    IN    DATE,
                         p_bol_flag       IN   VARCHAR2,
                         p_defer_interface_flag  IN VARCHAR2,
             p_mbol_flag  IN VARCHAR2, -- Added MBOL flag
                         x_return_status  OUT  NOCOPY VARCHAR2) IS

cursor get_stops (c_stop_id NUMBER) is
  select stop_id
  from   wsh_trip_stops
  where  trip_id = p_trip_id
  and    stop_id = NVL(c_stop_id, stop_id)
  and    status_code IN ('OP','AR')
  and    nvl(SHIPMENTS_TYPE_FLAG, 'O') IN  ('O', 'M')  -- J Inbound Logistics jckwok
  order by stop_sequence_number asc ;

cursor get_pickup_stop is
  select t.stop_id
  from   wsh_trip_stops t,
         wsh_delivery_legs dg
  where  t.trip_id = p_trip_id
  and    dg.pick_up_stop_id = t.stop_id
  and    t.status_code IN ('OP','AR')
  and    nvl(SHIPMENTS_TYPE_FLAG, 'O') IN  ('O', 'M');  -- J Inbound Logistics jckwok

l_return_status VARCHAR2(1) := NULL;
first_stop      VARCHAR2(1) := NULL;
l_stop_id       NUMBER      := NULL;
invalid_stop    EXCEPTION;
trip_confirm_error EXCEPTION;
others          EXCEPTION;

--Bug#: 2867209 - Start
CURSOR c_stop_del_status(p_stop_id NUMBER) IS
SELECT 1
FROM   wsh_new_deliveries dl,
       wsh_delivery_legs dg,
       wsh_trip_stops st,
       wsh_trips t
WHERE  dl.delivery_id = dg.delivery_id AND
       (dg.pick_up_stop_id = st.stop_id OR dg.drop_off_stop_id = st.stop_id) AND
       st.trip_id = t.trip_id AND
       dl.STATUS_CODE <> 'CO' and
       st.stop_id = p_stop_id;

l_stop_del_close NUMBER;
l_is_action_not_performed BOOLEAN := TRUE;
--Bug#: 2867209 - End

-- Exceptions Project
l_exceptions_tab  wsh_xc_util.XC_TAB_TYPE;
l_exp_logged      BOOLEAN := FALSE;
check_exceptions  EXCEPTION;
l_msg_count       NUMBER;
l_msg_summary     VARCHAR2(4000);
l_msg_details     VARCHAR2(4000);
l_msg_data        VARCHAR2(4000);
x_msg_data        VARCHAR2(4000);
x_msg_count       NUMBER;

CURSOR c_trip_status IS
  SELECT status_code
  FROM   wsh_trips
  WHERE  trip_id = p_trip_id ;

l_trip_status VARCHAR2(2);

-- J MBOL
l_document_number VARCHAR2(50);
--
l_wf_rs VARCHAR2(1); --Workflow API return status
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CONFIRM_TRIP';
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
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       --
       WSH_DEBUG_SV.log(l_module_name,'P_TRIP_ID',P_TRIP_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_ACTION_FLAG',P_ACTION_FLAG);
       WSH_DEBUG_SV.log(l_module_name,'P_INTRANSIT_FLAG',P_INTRANSIT_FLAG);
       WSH_DEBUG_SV.log(l_module_name,'P_CLOSE_FLAG',P_CLOSE_FLAG);
       WSH_DEBUG_SV.log(l_module_name,'P_STAGE_DEL_FLAG',P_STAGE_DEL_FLAG);
       WSH_DEBUG_SV.log(l_module_name,'P_REPORT_SET_ID',P_REPORT_SET_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_SHIP_METHOD',P_SHIP_METHOD);
       WSH_DEBUG_SV.log(l_module_name,'P_ACTUAL_DEP_DATE',P_ACTUAL_DEP_DATE);
       WSH_DEBUG_SV.log(l_module_name,'P_BOL_FLAG',P_BOL_FLAG);
       WSH_DEBUG_SV.log(l_module_name,'P_DEFER_INTERFACE_FLAG',P_DEFER_INTERFACE_FLAG);
       WSH_DEBUG_SV.log(l_module_name,'P_MBOL_FLAG',P_MBOL_FLAG);

   END IF;
   --

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   IF p_trip_id IS NULL THEN
      RAISE others ;
   END IF;

   IF p_mbol_flag = 'Y' THEN
      WSH_MBOLS_PVT.Generate_MBOL(
                   p_trip_id          => p_trip_id,
               x_sequence_number  => l_document_number,
           x_return_status    => l_return_status );
      IF ( l_return_status <>  WSH_UTIL_CORE.G_RET_STS_SUCCESS )  THEN
          x_return_status := l_return_status;
          wsh_util_core.add_message(x_return_status);
          IF l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)  THEN
            raise TRIP_CONFIRM_ERROR;
          END IF;
      END IF;
   END IF;

   -- Check for Exceptions against Trip and its contents, only if trip is being set to In-Transit or Closed
   IF p_intransit_flag = 'Y' OR p_close_flag = 'Y' THEN
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_XC_UTIL.Check_Exceptions',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      l_exceptions_tab.delete;
      l_exp_logged      := FALSE;
      WSH_XC_UTIL.Check_Exceptions (
                                        p_api_version           => 1.0,
                                        x_return_status         => l_return_status,
                                        x_msg_count             =>  l_msg_count,
                                        x_msg_data              => l_msg_data,
                                        p_logging_entity_id     => p_trip_id ,
                                        p_logging_entity_name   => 'TRIP',
                                        p_consider_content      => 'Y',
                                        x_exceptions_tab        => l_exceptions_tab
                                      );
      IF ( l_return_status <>  WSH_UTIL_CORE.G_RET_STS_SUCCESS )  THEN
            x_return_status := l_return_status;
            wsh_util_core.add_message(x_return_status);
            IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)  THEN
               raise others;
            END IF;
      END IF;
      FOR exp_cnt in 1..l_exceptions_tab.COUNT LOOP
            IF l_exceptions_tab(exp_cnt).exception_behavior = 'ERROR' THEN
               IF l_exceptions_tab(exp_cnt).entity_name = 'TRIP' THEN
                  FND_MESSAGE.SET_NAME('WSH','WSH_XC_EXIST_ENTITY');
               ELSE
                  FND_MESSAGE.SET_NAME('WSH','WSH_XC_EXIST_CONTENTS');
               END IF;
               FND_MESSAGE.SET_TOKEN('ENTITY_NAME','Trip');
               FND_MESSAGE.SET_TOKEN('ENTITY_ID',l_exceptions_tab(exp_cnt).entity_id);
               FND_MESSAGE.SET_TOKEN('EXCEPTION_BEHAVIOR','Error');
               x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
               wsh_util_core.add_message(x_return_status);
               raise check_exceptions;
            ELSIF l_exceptions_tab(exp_cnt).exception_behavior = 'WARNING' THEN
               IF l_exceptions_tab(exp_cnt).entity_name = 'TRIP' THEN
                  FND_MESSAGE.SET_NAME('WSH','WSH_XC_EXIST_ENTITY');
                  FND_MESSAGE.SET_TOKEN('ENTITY_NAME','Trip');
                  FND_MESSAGE.SET_TOKEN('ENTITY_ID',l_exceptions_tab(exp_cnt).entity_id);
                  FND_MESSAGE.SET_TOKEN('EXCEPTION_BEHAVIOR','Warning');
                  x_return_status :=  WSH_UTIL_CORE.G_RET_STS_WARNING;
                  wsh_util_core.add_message(x_return_status);
               ELSIF NOT (l_exp_logged) THEN
                  FND_MESSAGE.SET_NAME('WSH','WSH_XC_EXIST_CONTENTS');
                  FND_MESSAGE.SET_TOKEN('ENTITY_NAME','Trip');
                  FND_MESSAGE.SET_TOKEN('ENTITY_ID',l_exceptions_tab(exp_cnt).entity_id);
                  FND_MESSAGE.SET_TOKEN('EXCEPTION_BEHAVIOR','Warning');
                  x_return_status :=  WSH_UTIL_CORE.G_RET_STS_WARNING;
                  l_exp_logged := TRUE;
                  wsh_util_core.add_message(x_return_status);
               END IF;
            END IF;
      END LOOP;
   END IF; -- end of check if trip is being set to In-Transit or Closed

   -- Check if Trip should be set In-Transit, then get the Pickup Stop
   --  ( If no Open Pickup Stop exists, then return to caller with success )
   -- Otherwise select all Stops
   IF p_intransit_flag = 'Y' AND p_close_flag = 'N' THEN
      OPEN get_pickup_stop;
      FETCH get_pickup_stop INTO l_stop_id;
      IF get_pickup_stop%NOTFOUND THEN
         CLOSE get_pickup_stop;
         GOTO loop_end ;
      END IF;
      CLOSE get_pickup_stop;
   ELSE
      l_stop_id := NULL;
   END IF;

   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'L_STOP_ID',L_STOP_ID);
   END IF;
   --

   g_rate_trip_id := null;

   FOR stop_rec IN get_stops(l_stop_id) LOOP

     savepoint sp_confirm_trip;

     IF l_stop_id IS NOT NULL AND stop_rec.stop_id <> l_stop_id THEN
        RAISE invalid_stop;
     END IF;

    --Bug# 2867209 - Start
      IF P_CLOSE_FLAG = 'N' THEN
        open c_stop_del_status(stop_rec.stop_id);
        FETCH c_stop_del_status INTO l_stop_del_close;
        IF c_stop_del_status%FOUND THEN
           l_is_action_not_performed := FALSE;
        END IF;
        close c_stop_del_status;
      END IF;
    --Bug# 2867209 - End

     IF first_stop IS NULL THEN
        first_stop := 'Y';
     ELSE
        first_stop := 'N';
     END IF;

     --
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_ACTIONS.Confirm_Stop',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     WSH_TRIP_STOPS_ACTIONS.Confirm_Stop  (
                                            p_stop_id               => stop_rec.stop_id,
                                            p_action_flag           => p_action_flag,
                                            p_intransit_flag        => p_intransit_flag,
                                            p_close_flag            => p_close_flag,
                                            p_stage_del_flag        => p_stage_del_flag,
                                            p_report_set_id         => p_report_set_id,
                                            p_ship_method           => p_ship_method,
                                            p_actual_dep_date       => p_actual_dep_date,
                                            p_bol_flag              => p_bol_flag,
                                            p_defer_interface_flag  => p_defer_interface_flag,
                                            x_return_status         => l_return_status
                                          );

     IF l_return_status =  WSH_UTIL_CORE.G_RET_STS_ERROR  THEN
        -- For first stop, always error out ; for others, treat as warning
        IF first_stop = 'Y' THEN
           x_return_status := l_return_status ;
           rollback to sp_confirm_trip;
           EXIT ;
        ELSE
           -- since it's not the first stop, it can be treated as warning
           x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING ;
        END IF;

     ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
        -- For Unexpected errors, always error out
        x_return_status := l_return_status ;
        rollback to sp_confirm_trip;
        EXIT ;

     ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
        x_return_status := l_return_status ;

     END IF;

   END LOOP ;

   -- Close Exceptions for the Trip and its contents, only if the Trip is Closed
   IF p_close_flag = 'Y' THEN
      -- Only in the case of ITM , Trip remains Open but Confirm_Stop returns success
      -- Hence before closing exceptions, check to see if Trip status has been changed
      -- If trip status is still Open, do not close the exceptions
      OPEN c_trip_status;
      FETCH c_trip_status INTO l_trip_status;
      IF c_trip_status%NOTFOUND THEN
         CLOSE c_trip_status;
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Trip not found :'||p_trip_id,WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         raise no_data_found;
      END IF;
      CLOSE c_trip_status;

      IF l_trip_status = 'CL' THEN
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_XC_UTIL.Close_Exceptions',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         WSH_XC_UTIL.Close_Exceptions (
                                           p_api_version           => 1.0,
                                           x_return_status         => l_return_status,
                                           x_msg_count             => l_msg_count,
                                           x_msg_data              => l_msg_data,
                                           p_logging_entity_id     => p_trip_id,
                                           p_logging_entity_name   => 'TRIP',
                                           p_consider_content      => 'Y'
                                        ) ;

         IF ( l_return_status <>  WSH_UTIL_CORE.G_RET_STS_SUCCESS )  THEN
               x_return_status := l_return_status;
               wsh_util_core.add_message(x_return_status);
               IF l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)  THEN
                  raise TRIP_CONFIRM_ERROR;
               END IF;
         END IF;
      END IF;
   END IF;

<<loop_end>>
  NULL;


   -- Bug 3374306
   IF x_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_CONFIRM_WARNING');
      wsh_util_core.add_message(x_return_status);
   END IF;

--Bug# 2867209 - Start
   IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'l_is_action_not_performed',l_is_action_not_performed);
   END IF;

  IF x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS AND P_CLOSE_FLAG = 'N' AND l_is_action_not_performed THEN
           FND_MESSAGE.SET_NAME('WSH','WSH_NO_CHANGE_ACTION');
       wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_WARNING);
  END IF;
--Bug# 2867209 - End
--

--Raise Event: Pick To Pod Workflow
  IF l_debug_on THEN
   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.RAISE_EVENT',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;

 WSH_WF_STD.Raise_Event(
                         p_entity_type => 'TRIP',
                         p_entity_id =>  p_trip_id,
                         p_event => 'oracle.apps.wsh.trip.gen.shipconfirmed' ,
                         x_return_status => l_wf_rs ) ;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Trip ID is  ',  p_trip_id );
    WSH_DEBUG_SV.log(l_module_name,'Return Status After Calling WSH_WF_STD.Raise_Event',l_wf_rs);
  END IF;
--Done Raise Event: Pick To Pod Workflow

-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--


EXCEPTION
   WHEN trip_confirm_error THEN
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'trip_confirm_error exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:trip_confirm_error');
        END IF;
        FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_CONFIRM_ERROR');
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        wsh_util_core.add_message(x_return_status);
        --
   WHEN check_exceptions THEN
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Check_Exceptions exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:Check_Exceptions');
        END IF;
        --
        WSH_UTIL_CORE.get_messages('N', l_msg_summary, l_msg_details, x_msg_count);
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,  L_MSG_SUMMARY  );
        END IF;
        --
        if x_msg_count > 1 then
           x_msg_data := l_msg_summary || l_msg_details;
        else
           x_msg_data := l_msg_summary;
        end if;


   WHEN others THEN
        rollback to sp_confirm_trip;
        x_return_status :=  WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
        wsh_util_core.default_handler('WSH_TRIPS_ACTIONS.CONFIRM_TRIP');
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
        WSH_UTIL_CORE.get_messages('N', l_msg_summary, l_msg_details, x_msg_count);
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,  L_MSG_SUMMARY  );
        END IF;
        --
        if x_msg_count > 1 then
           x_msg_data := l_msg_summary || l_msg_details;
        else
           x_msg_data := l_msg_summary;
        end if;

END;



PROCEDURE Plan(
      p_trip_rows    IN wsh_util_core.id_tab_type,
      p_action IN   VARCHAR2,
      x_return_status   OUT NOCOPY    VARCHAR2) IS

l_num_error  NUMBER := 0;
l_num_warn   NUMBER := 0;
l_trip_rows  wsh_util_core.id_tab_type;
l_trip_status VARCHAR2(2);
l_stop_status VARCHAR2(2);

cursor get_status(c_trip_id IN NUMBER) is
select status_code,
       NVL(shipments_type_flag,'O')   -- J-IB-NPARIKH
from wsh_trips
where trip_id = c_trip_id;

cursor get_stops(c_trip_id IN NUMBER) is
select 'Y'
from wsh_trip_stops
where trip_id = c_trip_id
and status_code <> 'OP'
and rownum = 1;

CURSOR c_istripfirm(p_tripid IN NUMBER) IS
select 'Y'
from wsh_trips
where trip_id=p_tripid AND
planned_flag='F';

l_tripfirm VARCHAR2(1);

others EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PLAN';
--
l_shipments_type_flag     VARCHAR2(30);
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
       WSH_DEBUG_SV.log(l_module_name,'P_ACTION',P_ACTION);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


   IF (p_trip_rows.count = 0) THEN
    raise others;
   END IF;

   FOR i IN 1..p_trip_rows.count LOOP

     --tkt removed code for validation of trip status for planning/firming

     IF (p_action IN ('PLAN', 'FIRM')) THEN
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_VALIDATIONS.CHECK_PLAN',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       --
       wsh_trip_validations.check_plan(p_trip_rows(i), x_return_status);
     ELSIF (p_action='UNPLAN') THEN
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_VALIDATIONS.CHECK_UNPLAN',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       --
       wsh_trip_validations.check_unplan(p_trip_rows(i), x_return_status);
     END IF;

     IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) OR (x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
      goto plan_error;
    ELSIF (x_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
      l_num_warn := l_num_warn + 1;
     END IF;

/* H integration ,this call is made from Group and Public API
TO DO
verify for the FORM */
/* End of H integration */
     /* J TP Release */

     IF p_action='FIRM' THEN
         wsh_tp_release.firm_entity( p_entity        => 'TRIP',
                                     p_entity_id     =>p_trip_rows(i),
                                     x_return_status =>x_return_status);
         IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
           IF x_return_status=WSH_UTIL_CORE.G_RET_STS_WARNING THEN
              l_num_warn := l_num_warn + 1;
           ELSE
              goto plan_error;
           END IF;
         END IF;

     ELSIF p_action IN ('PLAN','UNPLAN') THEN
         wsh_tp_release.unfirm_entity( p_entity      => 'TRIP',
                                     p_entity_id     =>p_trip_rows(i),
                                     p_action        =>p_action,
                                     x_return_status =>x_return_status);
         IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
           IF x_return_status=WSH_UTIL_CORE.G_RET_STS_WARNING THEN
              l_num_warn := l_num_warn + 1;
           ELSE
              goto plan_error;
           END IF;
         END IF;
     END IF;

    goto loop_end;

    <<plan_error>>

       IF (p_action = 'PLAN') THEN
         FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_PLAN_ERROR');
       ELSIF (p_action='FIRM') THEN
         FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_FIRM_ERROR');
       ELSE
         FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_INVALID_STATUS');
       END IF;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      FND_MESSAGE.SET_TOKEN('TRIP_NAME',wsh_trips_pvt.get_name(p_trip_rows(i)));
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      wsh_util_core.add_message(x_return_status);
      l_num_error := l_num_error + 1;

     <<loop_end>>
      null;

   END LOOP;

   IF (p_trip_rows.count > 1) THEN

     IF (l_num_error > 0) OR (l_num_warn > 0) THEN

       IF (p_action = 'PLAN') THEN
         FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_PLAN_SUMMARY');
         FND_MESSAGE.SET_TOKEN('NUM_WARN',l_num_warn);
       ELSIF (p_action = 'FIRM') THEN
         FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_FIRM_SUMMARY');
         FND_MESSAGE.SET_TOKEN('NUM_WARN',l_num_warn);
       ELSE
         FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_UNPLAN_SUMMARY');
       END IF;

      FND_MESSAGE.SET_TOKEN('NUM_ERROR',l_num_error);
      FND_MESSAGE.SET_TOKEN('NUM_SUCCESS',p_trip_rows.count - l_num_error - l_num_warn);

      IF (p_trip_rows.count = l_num_error) THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       ELSE
         x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
       END IF;

      wsh_util_core.add_message(x_return_status);

     ELSE
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
     END IF;

   END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
   EXCEPTION
     WHEN others THEN
      wsh_util_core.default_handler('WSH_TRIPS_ACTIONS.PLAN');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Plan;

PROCEDURE Change_Status (
      p_trip_id    IN    NUMBER,
      p_status_code  IN VARCHAR2,
      x_return_status   OUT NOCOPY    VARCHAR2) IS

i   BINARY_INTEGER;
/* H integration  for Multi Leg */
  l_stop_rec   WSH_TRIP_STOPS_PVT.TRIP_STOP_REC_TYPE;
  l_pub_stop_rec  WSH_TRIP_STOPS_PUB.TRIP_STOP_PUB_REC_TYPE;
  l_trip_rec   WSH_TRIPS_PVT.TRIP_REC_TYPE;
  l_pub_trip_rec  WSH_TRIPS_PUB.TRIP_PUB_REC_TYPE;
  l_return_status VARCHAR2(30);
  l_num_warn NUMBER := 0;

-- Exceptions Project
l_exceptions_tab  wsh_xc_util.XC_TAB_TYPE;
l_exp_logged      BOOLEAN := FALSE;
check_exceptions  EXCEPTION;
l_msg_count       NUMBER;
l_msg_data        VARCHAR2(4000);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHANGE_STATUS';
--
BEGIN
/* H integration  */
/* Could not find a place where this is being called*/
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
    WSH_DEBUG_SV.log(l_module_name,'P_TRIP_ID',P_TRIP_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_STATUS_CODE',P_STATUS_CODE);
END IF;

/**
-- J-IB-NPARIKH-{
--
-- stubbed out as no longer being called.
--
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     RETURN;
-- J-IB-NPARIKH-}
**/

-- Check for Exceptions if p_status_code = 'CL' or 'IT'
IF p_status_code IN ('IT','CL') THEN
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_XC_UTIL.Check_Exceptions',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   l_exceptions_tab.delete;
   l_exp_logged      := FALSE;
   WSH_XC_UTIL.Check_Exceptions (
                                     p_api_version           => 1.0,
                                     x_return_status         => l_return_status,
                                     x_msg_count             =>  l_msg_count,
                                     x_msg_data              => l_msg_data,
                                     p_logging_entity_id     => p_trip_id ,
                                     p_logging_entity_name   => 'TRIP',
                                     p_consider_content      => 'Y',
                                     x_exceptions_tab        => l_exceptions_tab
                                   );
   IF ( l_return_status <>  WSH_UTIL_CORE.G_RET_STS_SUCCESS )  THEN
         x_return_status := l_return_status;
         wsh_util_core.add_message(x_return_status);
         IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)  THEN
            raise FND_API.G_EXC_ERROR;
         END IF;
   END IF;
   FOR exp_cnt in 1..l_exceptions_tab.COUNT LOOP
         IF l_exceptions_tab(exp_cnt).exception_behavior = 'ERROR' THEN
            IF l_exceptions_tab(exp_cnt).entity_name = 'TRIP' THEN
               FND_MESSAGE.SET_NAME('WSH','WSH_XC_EXIST_ENTITY');
            ELSE
               FND_MESSAGE.SET_NAME('WSH','WSH_XC_EXIST_CONTENTS');
            END IF;
            FND_MESSAGE.SET_TOKEN('ENTITY_NAME','Trip');
            FND_MESSAGE.SET_TOKEN('ENTITY_ID',l_exceptions_tab(exp_cnt).entity_id);
            FND_MESSAGE.SET_TOKEN('EXCEPTION_BEHAVIOR','Error');
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            wsh_util_core.add_message(x_return_status);
            raise check_exceptions;
         ELSIF l_exceptions_tab(exp_cnt).exception_behavior = 'WARNING' THEN
            IF l_exceptions_tab(exp_cnt).entity_name = 'TRIP' THEN
               FND_MESSAGE.SET_NAME('WSH','WSH_XC_EXIST_ENTITY');
               FND_MESSAGE.SET_TOKEN('ENTITY_NAME','Trip');
               FND_MESSAGE.SET_TOKEN('ENTITY_ID',l_exceptions_tab(exp_cnt).entity_id);
               FND_MESSAGE.SET_TOKEN('EXCEPTION_BEHAVIOR','Warning');
               x_return_status :=  WSH_UTIL_CORE.G_RET_STS_WARNING;
               wsh_util_core.add_message(x_return_status);
            ELSIF NOT (l_exp_logged) THEN
               FND_MESSAGE.SET_NAME('WSH','WSH_XC_EXIST_CONTENTS');
               FND_MESSAGE.SET_TOKEN('ENTITY_NAME','Trip');
               FND_MESSAGE.SET_TOKEN('ENTITY_ID',l_exceptions_tab(exp_cnt).entity_id);
               FND_MESSAGE.SET_TOKEN('EXCEPTION_BEHAVIOR','Warning');
               x_return_status :=  WSH_UTIL_CORE.G_RET_STS_WARNING;
               l_exp_logged := TRUE;
               wsh_util_core.add_message(x_return_status);
            END IF;
         END IF;
   END LOOP;
END IF;

--
IF (WSH_UTIL_CORE.FTE_IS_INSTALLED = 'Y') THEN
 -- Get pvt type record structure for trip
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_GRP.GET_TRIP_DETAILS_PVT',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     wsh_trips_grp.get_trip_details_pvt
       (p_trip_id => p_trip_id,
        x_trip_rec => l_trip_rec,
        x_return_status => l_return_status);

     IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
     END IF;
     l_trip_rec.status_code := p_status_code;

     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_FTE_INTEGRATION.TRIP_STOP_VALIDATIONS',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     wsh_fte_integration.trip_stop_validations
      (p_stop_rec => l_stop_rec,
       p_trip_rec => l_trip_rec,
       p_action => 'UPDATE',
       x_return_status => l_return_status);

     IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
              l_num_warn := l_num_warn + 1;
            ELSE
      x_return_status := l_return_status;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
            END IF;
     END IF;

END IF;
/* End of H integration  */

 --Bug Fix 2993711 added last_update_date,last_updated_by,last_update_login --

  UPDATE wsh_trips
   SET status_code = p_status_code,
       last_update_date  = SYSDATE,
       last_updated_by   = fnd_global.user_id,
       last_update_login = fnd_global.login_id
   WHERE trip_id = p_trip_id;

IF (SQL%NOTFOUND) THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    RETURN;
   END IF;

-- Close Exceptions for the Trip and its contents
IF p_status_code IN ('IT','CL') THEN
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_XC_UTIL.Close_Exceptions',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   WSH_XC_UTIL.Close_Exceptions (
                                     p_api_version           => 1.0,
                                     x_return_status         => l_return_status,
                                     x_msg_count             => l_msg_count,
                                     x_msg_data              => l_msg_data,
                                     p_logging_entity_id     => p_trip_id,
                                     p_logging_entity_name   => 'TRIP',
                                     p_consider_content      => 'Y'
                                  ) ;

   IF ( l_return_status <>  WSH_UTIL_CORE.G_RET_STS_SUCCESS )  THEN
         x_return_status := l_return_status;
         wsh_util_core.add_message(x_return_status);
         IF l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)  THEN
            raise FND_API.G_EXC_ERROR;
         END IF;
   END IF;

   IF l_num_warn >0 THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
   ELSE
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   END IF;
END IF;

-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--

EXCEPTION
     WHEN check_exceptions THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Check_Exceptions exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:Check_Exceptions');
        END IF;
        --

     WHEN others THEN
        wsh_util_core.default_handler('WSH_TRIPS_ACTIONS.CHANGE_STATUS');
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --

END Change_Status;


-- J-IB-NPARIKH-{
--
--========================================================================
-- PROCEDURE : changeStatus
--
-- PARAMETERS: p_in_rec          Trip details record.
--             x_return_status   Return status of the API
--
--
-- COMMENT   : This procedure is called only from
--               - stop close API (to set trip to in-transit/closed)
--               - stop open API (to set trip to in-transit/open, for inbound only).
--             It performs the following steps:
--             01. Check that trip's new status is OP/IT/CL.
--             02. Check for exceptions against trip(part of J exceptions project) -- moved to stop validations api
--             03. If FTE is installed, callout to FTE for validations
--             04. Update trip with new status
--             05. TP Release actions - Change firm and ignore for plan status of trip
--             06. Close exceptions against trip, if set to in-transit/closed (part of J exceptions project)
--
--========================================================================
--
PROCEDURE changeStatus
            (
              p_in_rec             IN          WSH_TRIP_VALIDATIONS.ChgStatus_in_rec_type,
              x_return_status      OUT NOCOPY  VARCHAR2
            )
IS
--{
    --- TP release
    CURSOR c_getdels IS
    SELECT delivery_id
    FROM wsh_delivery_legs wdl, wsh_trip_stops wts
    WHERE wdl.pick_up_stop_id=wts.stop_id AND
        wts.trip_id=p_in_rec.trip_id;


    /* H integration  for Multi Leg */
    l_stop_rec   WSH_TRIP_STOPS_PVT.TRIP_STOP_REC_TYPE;
    l_trip_rec   WSH_TRIPS_PVT.TRIP_REC_TYPE;
    --
    --
    l_num_warnings          NUMBER;
    l_num_errors            NUMBER;
    l_return_status         VARCHAR2(30);
    --

    -- Exceptions Project
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(4000);

    l_trip_id_tab     wsh_util_core.id_tab_type;
    l_del_tmp_rows      wsh_util_core.id_tab_type;

    l_wf_rs 	VARCHAR2(1); 	-- Workflow Project
    l_debug_on    BOOLEAN;
    --
    l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'changeStatus';
--}
BEGIN
--{
    --SAVEPOINT trip_chgStatus_begin_sp;
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
      wsh_debug_sv.LOG(l_module_name, 'p_in_rec.trip_id         ', p_in_rec.trip_id         );
      wsh_debug_sv.LOG(l_module_name, 'p_in_rec.name            ', p_in_rec.name            );
      wsh_debug_sv.LOG(l_module_name, 'p_in_rec.new_Status_code ', p_in_rec.new_Status_code );
      wsh_debug_sv.LOG(l_module_name, 'p_in_rec.put_messages    ', p_in_rec.put_messages    );
      wsh_debug_sv.LOG(l_module_name, 'p_in_rec.manual_flag     ', p_in_rec.manual_flag     );
      wsh_debug_sv.LOG(l_module_name, 'p_in_rec.caller          ', p_in_rec.caller          );
      wsh_debug_sv.LOG(l_module_name, 'p_in_rec.actual_date     ', p_in_rec.actual_date     );
      wsh_debug_sv.LOG(l_module_name, 'p_in_rec.stop_id         ', p_in_rec.stop_id         );
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    l_num_warnings  := 0;
    l_num_errors    := 0;
    --
    IF p_in_rec.new_status_code NOT IN ('OP','IT','CL')
    THEN
    --{
          --
          -- Invalid status for trip, raise error.
          --
          FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_INVALID_STATUS');
          FND_MESSAGE.SET_TOKEN('TRIP_NAME','p_in_rec.name');
          wsh_util_core.add_message(wsh_util_core.g_ret_sts_error,l_module_name);
          RAISE FND_API.G_EXC_ERROR;
    --}
    END IF;
    --

    IF (WSH_UTIL_CORE.FTE_IS_INSTALLED = 'Y')
    THEN
    --{
         -- Get pvt type record structure for trip
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_GRP.GET_TRIP_DETAILS_PVT',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --
         wsh_trips_grp.get_trip_details_pvt
           (p_trip_id => p_in_rec.trip_id,
            x_trip_rec => l_trip_rec,
            x_return_status => l_return_status);
        --
        WSH_UTIL_CORE.api_post_call
            (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors
            );
        --
         l_trip_rec.status_code := p_in_rec.new_status_code;

         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_FTE_INTEGRATION.TRIP_STOP_VALIDATIONS',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --
         wsh_fte_integration.trip_stop_validations
          (p_stop_rec => l_stop_rec,
           p_trip_rec => l_trip_rec,
           p_action => 'UPDATE',
           x_return_status => l_return_status);
        --
        WSH_UTIL_CORE.api_post_call
            (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors
            );
        --
    --}
    END IF;
    /* End of H integration  */

     --Bug Fix 2993711 added last_update_date,last_updated_by,last_update_login --

      UPDATE wsh_trips
       SET status_code       = p_in_rec.new_status_code,
           last_update_date  = SYSDATE,
           last_updated_by   = fnd_global.user_id,
           last_update_login = fnd_global.login_id
       WHERE trip_id         = p_in_rec.trip_id;

    IF (SQL%NOTFOUND) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
   --
   --
   -- Workflow Project
   IF p_in_rec.new_status_code = 'IT' THEN
        -- Raise Initial Pickup Stop Closed Event
	IF l_debug_on THEN
	  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.RAISE_EVENT',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	WSH_WF_STD.RAISE_EVENT( p_entity_type   =>      'TRIP',
				p_entity_id     =>      p_in_rec.trip_id,
				p_event         =>      'oracle.apps.wsh.trip.gen.initialpickupstopclosed',
				x_return_status =>      l_wf_rs
			      );
	IF l_debug_on THEN
	  WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_WF_STD.RAISE_EVENT => ',l_wf_rs);
	END IF;
   ELSIF p_in_rec.new_status_code = 'CL' THEN
        -- Raise Ultimate Dropoff Stop Closed Event
	IF l_debug_on THEN
	  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.RAISE_EVENT',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	WSH_WF_STD.RAISE_EVENT( p_entity_type   =>      'TRIP',
				p_entity_id     =>      p_in_rec.trip_id,
				p_event         =>      'oracle.apps.wsh.trip.gen.ultimatedropoffstopclosed',
				x_return_status =>      l_wf_rs
			      );
	IF l_debug_on THEN
	  WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_WF_STD.RAISE_EVENT => ',l_wf_rs);
	END IF;
   END IF;
   -- End of code for Workflow Project

    --setting trip to in-transit, need to set delivery to be firmed
    --which will make trip to be atleast planned
    IF WSH_UTIL_CORE.TP_IS_INSTALLED='Y' AND l_trip_rec.ship_method_code is not null THEN
      IF l_trip_rec.mode_of_transport ='TRUCK' and l_trip_rec.vehicle_item_id is null THEN
         --if mode is truck, we can't plan/firm trip.
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Not trying to firm trip/delivery because mode is truck');
         END IF;
      ELSE -- mode and vehicle
          IF p_in_rec.new_status_code = 'IT' THEN

             l_del_tmp_rows.delete;
             FOR cur IN c_getdels LOOP
               l_del_tmp_rows(l_del_tmp_rows.COUNT+1):=cur.delivery_id;
             END LOOP;

             IF l_del_tmp_rows.COUNT>0 THEN
               wsh_new_delivery_actions.firm (p_del_rows      => l_del_tmp_rows,
                                           x_return_status => l_return_status);
               WSH_UTIL_CORE.api_post_call
                (
                    p_return_status => l_return_status,
                    x_num_warnings  => l_num_warnings,
                    x_num_errors    => l_num_errors
                );
             END IF;
          --closing trip => trip has to be firmed.all deliveries will be firmed as well
          ELSIF p_in_rec.new_status_code = 'CL' THEN
            l_trip_id_tab.delete;
            l_trip_id_tab(1):=p_in_rec.trip_id;
            Plan(
                 p_trip_rows       => l_trip_id_tab,
                 p_action          => 'FIRM',
                 x_return_status   => l_return_status);

            WSH_UTIL_CORE.api_post_call
                (
                    p_return_status => l_return_status,
                    x_num_warnings  => l_num_warnings,
                    x_num_errors    => l_num_errors
                );
          END IF;--p_status_code
      END IF;
    ELSIF WSH_UTIL_CORE.TP_IS_INSTALLED='Y' AND l_trip_rec.ship_method_code is null THEN
         --TP is installed and ship method is null, cannot make the trip as firmed
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Not trying to firm trip/delivery because ship method is null');
         END IF;
    END IF;
   --
   -- Close Exceptions for the Trip and its contents, if new status = 'CL' or 'IT'
   IF p_in_rec.new_status_code IN ('IT','CL') THEN
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_XC_UTIL.Close_Exceptions',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      WSH_XC_UTIL.Close_Exceptions (
                                        p_api_version           => 1.0,
                                        x_return_status         => l_return_status,
                                        x_msg_count             => l_msg_count,
                                        x_msg_data              => l_msg_data,
                                        p_logging_entity_id     => p_in_rec.trip_id,
                                        p_logging_entity_name   => 'TRIP',
                                        p_consider_content      => 'Y'
                                    ) ;

      IF ( l_return_status <>  WSH_UTIL_CORE.G_RET_STS_SUCCESS )  THEN
           x_return_status := l_return_status;
           wsh_util_core.add_message(x_return_status);
           IF l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)  THEN
              raise FND_API.G_EXC_ERROR;
           END IF;
      END IF;
   END IF;
   --
   --
   IF l_num_errors > 0
   THEN
        x_return_status         := WSH_UTIL_CORE.G_RET_STS_ERROR;
   ELSIF l_num_warnings > 0
   THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
   ELSE
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   END IF;
   --
   --
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
--}
EXCEPTION
--{
    WHEN FND_API.G_EXC_ERROR THEN

      --ROLLBACK TO trip_chgStatus_begin_sp;
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      --ROLLBACK TO trip_chgStatus_begin_sp;
      --
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
     WHEN others THEN
        wsh_util_core.default_handler('WSH_NEW_DELIVERY_ACTIONS.changeStatus',l_module_name);
        --
        --ROLLBACK TO trip_chgStatus_begin_sp;
        --
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
--}
END changeStatus;

--
--========================================================================
-- PROCEDURE : generateRoutingResponse
--
-- PARAMETERS: p_action_prms     Standard action parameters record
--             p_rec_attr_tab    Table of trip records
--             x_return_status   Return status of the API
--
--
-- COMMENT   : Trigger routing response for deliveries within trip.
--             This procedure finds all deliveries with initial pickup location on the trip.
--             For all such deliveries, it calls delivery-level group API to generate routing response
--             If there are no such deliveries among all input trips, it raises an error.
--
--========================================================================
PROCEDURE generateRoutingResponse
            (
              p_action_prms            IN   WSH_TRIPS_GRP.action_parameters_rectype,
              p_rec_attr_tab           IN   WSH_TRIPS_PVT.Trip_Attr_Tbl_Type,
              x_return_status          OUT     NOCOPY  VARCHAR2
            )
IS
--{
    l_num_warnings              NUMBER  := 0;
    l_num_errors                NUMBER  := 0;
    l_return_status             VARCHAR2(30);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(4000);
    --
    l_index                     NUMBER;
    --
    -- Get deliveries which have initial pickup location on the input trip
    --
    CURSOR dlvy_csr(p_trip_id NUMBER)
    IS
      SELECT  wdl.delivery_id, wt.name
      FROM    wsh_trip_stops wts,
              wsh_Delivery_legs wdl,
              wsh_new_deliveries wnd,
              wsh_trips wt
      WHERE   wt.trip_id                      = p_trip_id
      AND     wts.trip_id                     = p_trip_id
      AND     wdl.pick_up_stop_id             = wts.stop_id
      AND     wnd.delivery_id                 = wdl.delivery_id
      AND     nvl(wnd.shipment_direction,'O') NOT IN ('O','IO')   -- J-IB-NPARIKH
      AND     wnd.initial_pickup_location_id  = wts.stop_location_id;
    --
    --
    l_deliveryIdTbl       WSH_UTIL_CORE.key_value_tab_type;
    l_deliveryIdExtTbl    WSH_UTIL_CORE.key_value_tab_type;
    --
    l_action_prms wsh_deliveries_grp.action_parameters_rectype;
    l_del_action_out_rec wsh_deliveries_grp.Delivery_Action_Out_Rec_Type;
    l_delivery_id_tab             wsh_util_core.id_tab_type;
    l_trip_name                   VARCHAR2(30);
    l_cnt                         NUMBER;
    l_totalCnt                    NUMBER;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'generateRoutingResponse';
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
       wsh_debug_sv.log (l_module_name,'action_code',p_action_prms.action_code);
       wsh_debug_sv.log (l_module_name,'caller',p_action_prms.caller);
       wsh_debug_sv.log (l_module_name,'COUNT',p_rec_attr_tab.COUNT);
    END IF;
    --
    --
    l_cnt := 0;
    l_totalCnt := 0;
    --
    l_index := p_rec_attr_tab.FIRST;
    --
    --
    WHILE l_index IS NOT NULL
    LOOP
    --{
        l_cnt := 0;
        l_trip_name := NULL;
        --
        IF l_debug_on THEN
            wsh_debug_sv.log (l_module_name,'l_index',l_index);
            wsh_debug_sv.log (l_module_name,'trip_id',p_rec_attr_tab(l_index).trip_id);
        END IF;
        --
        -- Get deliveries which have initial pickup location on the input trip
        --
        FOR dlvy_rec IN dlvy_csr(p_rec_attr_tab(l_index).trip_id)
        LOOP
        --{
            l_trip_name := dlvy_rec.name;
            l_cnt       := l_cnt + 1;
            --
            --
            IF l_debug_on THEN
               wsh_debug_sv.log (l_module_name,'dlvy_rec.delivery_id',dlvy_rec.delivery_id);
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_CACHED_VALUE-l_deliveryIdTbl',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            -- Build a cache of unique delivery IDs
            --
            wsh_util_core.get_cached_value
              (
                p_cache_tbl         => l_deliveryIdTbl,
                p_cache_ext_tbl     => l_deliveryIdExtTbl,
                p_key               => dlvy_rec.delivery_id,
                p_value             => dlvy_rec.delivery_id,
                p_action            => 'PUT',
                x_return_status     => l_return_status
              );
            --
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            wsh_util_core.api_post_call
             (
               p_return_status => l_return_status,
               x_num_warnings  => l_num_warnings,
               x_num_errors    => l_num_errors
             );
        --}
        END LOOP;
        --
        l_totalCnt := l_totalCnt + l_cnt;
        --
        IF l_cnt = 0
        --AND l_trip_name IS NOT NULL
        THEN
        --{
            --
            -- Trip does not have any delivery with initial pickup location
            -- Put a warning message for the trip
            --
            --
            IF p_rec_attr_tab(l_index).trip_id IS NULL
            THEN
                FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_TRIP_NAME');
            ELSE
                FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_NO_PICKUP_ERROR');
                --FND_MESSAGE.SET_TOKEN('TRIP_NAME',NVL(l_trip_name,p_rec_attr_tab(l_index).trip_id));
                FND_MESSAGE.SET_TOKEN('TRIP_NAME',NVL(l_trip_name, wsh_trips_pvt.get_name( p_rec_attr_tab(l_index).trip_id)));
            END IF;
            --
            wsh_util_core.add_message(wsh_util_core.g_ret_sts_warning,l_module_name);
               l_num_warnings := NVL(l_num_warnings,0) + 1;
        --}
        END IF;
        --
        l_index := p_rec_attr_tab.NEXT(l_index);
    --}
    END LOOP;
    --
    --
    IF l_debug_on THEN
        wsh_debug_sv.log (l_module_name,'l_totalCnt',l_totalCnt);
    END IF;
    --
    --
    -- None of the trips have any delivery with initial pickup location
    -- Return with error.
    --
    IF l_totalCnt = 0
    THEN
    --{
        RAISE FND_API.G_EXC_ERROR;
    --}
    ELSE
    --{
        l_cnt := 0;
        --
        -- Convert Delivery ID cache into a contiguous table.
        --
        l_index := l_deliveryIdTbl.FIRST;
        --
        WHILE l_index IS NOT NULL
        LOOP
        --{
            l_cnt := l_cnt + 1;
            l_delivery_id_tab(l_cnt) := l_deliveryIdTbl(l_index).value;
            --
            l_index := l_deliveryIdTbl.NEXT(l_index);
        --}
        END LOOP;
        --
        --
        l_index := l_deliveryIdExtTbl.FIRST;
        --
        WHILE l_index IS NOT NULL
        LOOP
        --{
            l_cnt := l_cnt + 1;
            l_delivery_id_tab(l_cnt) := l_deliveryIdExtTbl(l_index).value;
            --
            l_index := l_deliveryIdExtTbl.NEXT(l_index);
        --}
        END LOOP;
        --
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit wsh_interface_grp.Delivery_Action',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        l_action_prms.caller        := p_action_prms.caller;
        l_action_prms.phase         := p_action_prms.phase;
        l_action_prms.action_code   := p_action_prms.action_code;
        --
        -- Call Delivery group API to generate routing response
        --
        wsh_interface_grp.Delivery_Action(
              p_api_version_number     =>  1.0,
              p_init_msg_list          =>  FND_API.G_FALSE,
              p_commit                 =>  FND_API.G_FALSE,
              p_action_prms            =>  l_action_prms,
              p_delivery_id_tab        =>  l_delivery_id_tab,
              x_delivery_out_rec       =>  l_del_action_out_rec,
              x_return_status          =>  l_return_status,
              x_msg_count              =>  l_msg_count,
              x_msg_data               =>  l_msg_data);
        --
        --
        IF l_debug_on THEN
                wsh_debug_sv.log(l_module_name,'Return Status After Calling generate_routing_response',l_return_status);
        END IF;
        --
        wsh_util_core.api_post_call(
            p_return_status    => l_return_status,
            x_num_warnings     => l_num_warnings,
            x_num_errors       => l_num_errors,
            p_msg_Data         => l_msg_data);
    --}
    END IF;
    --
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,
                            'Number of Errors='||l_num_errors||',Number of Warnings='||l_num_warnings);
    END IF;
    --
    IF l_num_errors > 0
    THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    ELSIF l_num_warnings > 0
    THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    ELSE
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    END IF;
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
--}
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
      wsh_util_core.default_handler('WSH_TRIPS_ACTIONS.generateRoutingResponse');
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
--}
END generateRoutingResponse;
--
--
-- J-IB-NPARIKH-}


/* Bug 4037457 */
--========================================================================
-- PROCEDURE : get_next_del_rows
--
-- PARAMETERS: p_del_tbl   Is a table of record for delivery lines
--             x_idx       This parameter indicates the index to
--                         table p_del_tbl, as a starting index.  It is
--                         an in/out parameter so it will be remembered
--                         by the calling API
--             x_del_rows  is a table of deliver_ids that can be grouped
--                         together.
--
--
-- COMMENT   : This procedure is called from autocreate_trip_wrp.  It returns
--             a table of deliveries that can be put together in a trip.  If
--             IF FTE is not installed then deliveries that contain same
--             mode of transport, service level and carrier are put
--             together.
--             IF FTE is installed in addition to the grouping above
--             if deliveries with mode_of_transport other than truck
--             have a different pick up or drop off then they will put
--             in a different trip
--             Once there are no deliveries to process parameter
--             x_idx is set to NULL.
--
--========================================================================
PROCEDURE get_next_del_rows( p_del_tbl  IN Del_Rec_Type,
                             x_idx      IN OUT NOCOPY NUMBER,
                             x_del_rows OUT NOCOPY wsh_util_core.id_tab_type,
                             x_return_status OUT NOCOPY VARCHAR) IS

--
   j NUMBER;
   l_fte_flag VARCHAR2(2) := 'N';

   -- the following 5 variables are defined as varchar2(30) since they
   -- will get their value from wsh_tmp table which has varchar2 columns

   l_pickup_location_id VARCHAR2(30);
   l_dropoff_location_id VARCHAR2(30);
   l_MODE_OF_TRANSPORT     VARCHAR2(30);
   l_service_level     VARCHAR2(30);
   l_carrier_id     VARCHAR2(30);
   --
   --
   l_delivery_id    NUMBER;
   l_counter NUMBER;
   l_debug_on BOOLEAN;
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_NEXT_DEL_ROWS';
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
     wsh_debug_sv.push(l_module_name);
     wsh_debug_sv.log(l_module_name, 'p_del_tbl.COUNT', p_del_tbl.delivery_id.COUNT);
   END IF;
   --

   IF (WSH_UTIL_CORE.FTE_IS_INSTALLED = 'Y') THEN
     l_fte_flag := 'Y';
   END IF;

   --If the x_idx is greater than the delivery_id.COUNT then
   -- return NULL to calling API to show that there is no more
   -- rows to process.

   IF x_idx > p_del_tbl.delivery_id.COUNT THEN
      x_idx := NULL;
   ELSE --{
      j := x_idx;
      l_delivery_id := p_del_tbl.delivery_id(j);
      l_pickup_location_id := p_del_tbl.INITIAL_PICKUP_LOCATION_ID(j);
      l_dropoff_location_id := p_del_tbl.ULTIMATE_DROPOFF_LOCATION_ID(j);
      l_MODE_OF_TRANSPORT := p_del_tbl.MODE_OF_TRANSPORT(j);
      l_service_level := p_del_tbl.service_level(j);
      l_carrier_id := p_del_tbl.carrier_id(j);

      l_counter := 1;
      FOR i IN j..p_del_tbl.delivery_id.COUNT LOOP --{
         --
         -- IF any of 3 components of Shipmethod changes, create a
         -- separate trip.
         --
         IF (NVL(p_del_tbl.MODE_OF_TRANSPORT(i),'~') <>
                  NVL(l_MODE_OF_TRANSPORT,'~'))
           OR
            (NVL(p_del_tbl.service_level(i),'~') <>
                  NVL(l_service_level,'~'))
           OR
            (NVL(p_del_tbl.carrier_id(i),'~') <>
                  NVL(l_carrier_id,'~'))
         THEN --{
            IF l_debug_on THEN
              wsh_debug_sv.log(l_module_name, 'SM l_delivery_id', l_delivery_id);
              wsh_debug_sv.log(l_module_name, 'p_del_tbl.delivery_id', p_del_tbl.delivery_id(i));
            END IF;
            EXIT;
         END IF; --}

         -- IF FTE is installed and the mode of transport is not
         -- Truck, then only deliveries with the same pickup, drop off
         -- should be grouped in one trip
         --
         IF  ( l_fte_flag = 'Y'
           AND NVL(p_del_tbl.MODE_OF_TRANSPORT(i),'~')  <> 'TRUCK'
           AND (l_dropoff_location_id <>
                   p_del_tbl.ULTIMATE_DROPOFF_LOCATION_ID(i)
                OR
                l_pickup_location_id <>
                p_del_tbl.INITIAL_PICKUP_LOCATION_ID(i)
               )
             )
         THEN
            IF l_debug_on THEN
              wsh_debug_sv.log(l_module_name, 'SF/ST l_delivery_id', l_delivery_id);
              wsh_debug_sv.log(l_module_name, 'p_del_tbl.delivery_id', p_del_tbl.delivery_id(i));
            END IF;
            EXIT;
         END IF;

         x_idx := x_idx + 1;
         x_del_rows(l_counter) := p_del_tbl.delivery_id(i);
         IF l_debug_on THEN
           wsh_debug_sv.log(l_module_name, 'p_del_tbl.delivery_id(i)',
                                               p_del_tbl.delivery_id(i));
         END IF;
         l_counter := l_counter + 1;

      END LOOP; --}
   END IF; --}
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name, 'x_idx', x_idx);
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   EXCEPTION
     --
     WHEN others THEN
      --
      wsh_util_core.default_handler('WSH_TRIPS_ACTIONS.GET_NEXT_DEL_ROWS');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END get_next_del_rows;


/* Bug 4037457 */
--========================================================================
-- PROCEDURE : sort_del
--
-- PARAMETERS: p_del_tbl record of table of deliveries that need to be
--                       sorted.
--             x_del_tbl This is the p_del_tbl sorted by the criteria
--                        mentioned in the comments.
--
--
-- COMMENT   : This procedure is called from autocreate_trip_wrp.  It sorts
--             the deliveries based on the p_del_tbl.MODE_OF_TRANSPORT,
--             service_level, carrier_id, pickup and then drop-off
--             locatio_id
--
--========================================================================
PROCEDURE sort_del( p_del_tbl IN Del_Rec_Type,
                    x_del_tbl OUT NOCOPY Del_Rec_Type,
                    x_return_status OUT NOCOPY VARCHAR) IS

--
   CURSOR c_sort_del IS
   SELECT id,
          column1,
          column2,
          column3,
          column4,
          column5
   FROM WSH_TMP
   WHERE flag = '~'
   order by column1, column2, column3, column4, column5;

   e_invalid_count  EXCEPTION;

   l_debug_on BOOLEAN;
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SORT_DEL';
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
     wsh_debug_sv.push(l_module_name);
     wsh_debug_sv.log(l_module_name, 'p_del_tbl.delivery_id.COUNT', p_del_tbl.delivery_id.COUNT);
   END IF;
   --
   IF p_del_tbl.delivery_id.COUNT < 1 THEN
      RAISE e_invalid_count;
   END IF;

   DELETE FROM wsh_tmp where flag = '~';


   FORALL i IN 1..p_del_tbl.delivery_id.count
    INSERT INTO wsh_tmp (id,
                         flag,
                         column1,
                         column2,
                         column3,
                         column4,
                         column5 )
                   VALUES(p_del_tbl.delivery_id(i),
                         '~',
                         p_del_tbl.MODE_OF_TRANSPORT(i),
                         p_del_tbl.service_level(i),
                         p_del_tbl.carrier_id(i),
                         p_del_tbl.INITIAL_PICKUP_LOCATION_ID(i),
                         p_del_tbl.ULTIMATE_DROPOFF_LOCATION_ID(i)
                   );


   OPEN c_sort_del;
   FETCH c_sort_del BULK COLLECT INTO x_del_tbl.delivery_id,
                         x_del_tbl.MODE_OF_TRANSPORT,
                         x_del_tbl.service_level,
                         x_del_tbl.carrier_id,
                         x_del_tbl.INITIAL_PICKUP_LOCATION_ID,
                         x_del_tbl.ULTIMATE_DROPOFF_LOCATION_ID;

   -- the column sequence determines the sorting

   CLOSE c_sort_del;

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name, 'x_del_tbl.COUNT', x_del_tbl.delivery_id.COUNT);
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   EXCEPTION
     --
     WHEN e_invalid_count THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'The input table is empty.' ,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:e_invalid_count');
      END IF;
      --
     WHEN others THEN
      --
      wsh_util_core.default_handler('WSH_TRIPS_ACTIONS.SORT_DEL');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END sort_del;

/* Bug 4037457 */
--========================================================================
-- PROCEDURE : autocreate_trip_wrp
--
-- PARAMETERS:
--
--
-- COMMENT   : This procedure is called by autocreate_trip_multi.  It is a
--             wrapper around procedure autocreate_trip.  It calls
--             sort_del to sort the deliveries then it calls
--             get_next_del_rows in a loop to get the group of
--             deliveries which can be sent in one trip.  It exists the
--             loop, once there are no more deliveries to process.
--
--========================================================================

PROCEDURE autocreate_trip_wrp(
         p_del_rows   IN    wsh_util_core.id_tab_type,
         p_entity     IN    VARCHAR2,
         x_trip_ids    OUT NOCOPY    wsh_util_core.id_tab_type,
         x_trip_names  OUT NOCOPY    wsh_util_core.Column_Tab_Type,
         x_return_status OUT NOCOPY  VARCHAR2,
         p_sc_pickup_date         IN      DATE   DEFAULT NULL,
         p_sc_dropoff_date        IN      DATE   DEFAULT NULL) IS

--
   l_idx number;

   CURSOR c_get_del_detail (v_delivery_id number) IS
      SELECT delivery_id,
             INITIAL_PICKUP_LOCATION_ID,
             ULTIMATE_DROPOFF_LOCATION_ID,
             MODE_OF_TRANSPORT,
             service_level,
             carrier_id
      FROM wsh_new_deliveries
      WHERE delivery_id = v_delivery_id;

   l_del_tbl Del_Rec_Type;
   l_del_tbl_not_sorted Del_Rec_Type;
   l_return_status varchar2(1);
   l_del_rows  wsh_util_core.id_tab_type;
   l_trip_id   NUMBER;
   l_trip_name  wsh_trips.name%TYPE;
   l_initial_pickup_location_id  NUMBER;
   l_ultimate_dropoff_location_id  NUMBER;
   l_num_warnings        NUMBER := 0;
   l_num_errors          NUMBER := 0;
   l_api_calls           NUMBER := 0;
   i                     NUMBER;

   l_debug_on BOOLEAN;
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'AUTOCREATE_TRIP_WRP';
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
     wsh_debug_sv.push(l_module_name);
     wsh_debug_sv.log(l_module_name, 'p_entity', p_entity);
     wsh_debug_sv.log(l_module_name, 'p_del_rows.COUNT', p_del_rows.COUNT);
     wsh_debug_sv.log(l_module_name, 'p_sc_pickup_date', p_sc_pickup_date);
     wsh_debug_sv.log(l_module_name, 'p_sc_dropoff_date', p_sc_dropoff_date);
     wsh_debug_sv.log(l_module_name, 'p_del_rows.count', p_del_rows.count);
   END IF;
   --
   l_idx := p_del_rows.FIRST;

   WHILE l_idx IS NOT NULL LOOP --{

      OPEN c_get_del_detail(p_del_rows(l_idx));
      FETCH c_get_del_detail INTO
      l_del_tbl_not_sorted.delivery_id(l_idx),
      l_del_tbl_not_sorted.INITIAL_PICKUP_LOCATION_ID(l_idx),
      l_del_tbl_not_sorted.ULTIMATE_DROPOFF_LOCATION_ID(l_idx),
      l_del_tbl_not_sorted.MODE_OF_TRANSPORT(l_idx),
      l_del_tbl_not_sorted.service_level(l_idx),
      l_del_tbl_not_sorted.carrier_id(l_idx) ;
      CLOSE c_get_del_detail;

      l_idx := p_del_rows.NEXT(l_idx);

   END LOOP; --}
   --
   -- If some delivereis contain mode of transport ('LTL' or "PARCEL')
   -- and have different pickup and drop-off locations then group these
   -- deliveries and create several trips for them.

   sort_del(l_del_tbl_not_sorted,l_del_tbl, l_return_status );
   wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors
   );
   l_idx := l_del_tbl.delivery_id.FIRST;

   WHILE l_idx IS NOT NULL LOOP --{
        --
        -- get the deliveries that can be grouped in one trip
        --
        get_next_del_rows( p_del_tbl       => l_del_tbl,
                           x_idx           => l_idx,
                           x_del_rows      => l_del_rows,
                           x_return_status => l_return_status);
         wsh_util_core.api_post_call(
             p_return_status => l_return_status,
             x_num_warnings  => l_num_warnings,
             x_num_errors    => l_num_errors
         );

        autocreate_trip(
           p_del_rows   => l_del_rows,
           p_entity     => p_entity,
           x_trip_id    => l_trip_id,
           x_trip_name  => l_trip_name,
           x_return_status => l_return_status,
           p_sc_pickup_date => p_sc_pickup_date,
           p_sc_dropoff_date => p_sc_dropoff_date);

        IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        wsh_util_core.api_post_call(
             p_return_status => l_return_status,
             x_num_warnings  => l_num_warnings,
             x_num_errors    => l_num_errors,
             p_raise_error_flag => FALSE
        );
        l_api_calls := l_api_calls + 1;
        l_del_rows.DELETE;
        x_trip_names(x_trip_names.count + 1) := l_trip_name;
        x_trip_ids(x_trip_ids.count + 1) := l_trip_id;

  END LOOP; --}


   IF l_num_errors = 0 AND l_num_warnings = 0 THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   ELSIF l_num_errors = l_api_calls THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   ELSE
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING ;
   END IF;

   IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   EXCEPTION
     --
     WHEN others THEN
      --
      wsh_util_core.default_handler('WSH_TRIPS_ACTIONS.AUTOCREATE_TRIP_WRP');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END autocreate_trip_wrp;

/* J TP Release */
--
-- Procedure:   Autocreate_Trip_multi
--              New procedure which gets the ignore_for_planning flag
--              and groups them on the basis of that.
PROCEDURE autocreate_trip_multi(
         p_del_rows   IN    wsh_util_core.id_tab_type,
         p_entity     IN    VARCHAR2,
         x_trip_ids    OUT NOCOPY    wsh_util_core.id_tab_type,
         x_trip_names  OUT NOCOPY    wsh_util_core.Column_Tab_Type,
         x_return_status OUT NOCOPY  VARCHAR2) IS

--OTM R12, glog proj
-- When OTM is installed and user performs autocreate Trip action
-- the trip would be created as Ignore for Planning(based on the delivery)
-- Autocreate trip action is not allowed on an Include for Planning Delivery
--
-- When OTM is not installed, the behavior is that Trips are
-- created as Include/Ignore for Planning based on the delivery
-- and Include for Planning if null value at delivery
CURSOR c_get_del_ignoreplan (p_delid IN NUMBER,p_ignore_flag IN VARCHAR2) IS
SELECT NVL(ignore_for_planning,p_ignore_flag) ignore_for_planning
FROM wsh_new_deliveries
WHERE delivery_id=p_delid;

l_ignore_ids        wsh_util_core.id_tab_type;
l_include_ids       wsh_util_core.id_tab_type;
l_return_status     VARCHAR2(1);
l_trip_id           NUMBER;
l_trip_name         wsh_trips.name%TYPE;
l_index             NUMBER;
l_trip_ids          wsh_util_core.id_tab_type;
l_trip_names        wsh_util_core.Column_Tab_Type;
l_gc3_is_installed  VARCHAR2(1); -- OTM R12, glog proj
l_ignore_flag       WSH_TRIPS.IGNORE_FOR_PLANNING%TYPE;  -- OTM R12, glog proj
l_count_error       NUMBER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'AUTOCREATE_TRIP_multi';
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
     wsh_debug_sv.log(l_module_name, 'p_entity', p_entity);
     wsh_debug_sv.log(l_module_name, 'p_del_rows.COUNT', p_del_rows.COUNT);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   --OTM R12, glog proj, use Global Variable
   l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED;

   -- If null, call the function
   IF l_gc3_is_installed IS NULL THEN
     l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED;
   END IF;

   IF l_gc3_is_installed = 'Y' THEN
     l_ignore_flag := 'Y';
   ELSE
     l_ignore_flag := 'N';
   END IF;
   -- end of OTM R12, glog proj


   -- OTM R12, glog project
   -- If gc3 is installed, sort Include and Ignore lines/deliveries
   IF (WSH_UTIL_CORE.TP_IS_INSTALLED = 'N') AND (l_gc3_is_installed = 'N') THEN
      --just call the core api
      autocreate_trip_wrp(
         p_del_rows      => p_del_rows,
         p_entity        => p_entity,
         x_trip_ids      => x_trip_ids,
         x_trip_names    => x_trip_names,
         x_return_status => x_return_status);
   ELSE
      l_index:=p_del_rows.FIRST;
      l_count_error := 0;
      WHILE l_index IS NOT NULL LOOP
        FOR cur in c_get_del_ignoreplan(p_del_rows(l_index),l_ignore_flag) LOOP
           IF cur.ignore_for_planning='Y' THEN
              l_ignore_ids(l_ignore_ids.COUNT+1):=p_del_rows(l_index);
           ELSE
             --OTM R12, glog proj
             -- only select the ignore_for_planning delivery for autocreate trip
             -- for include for planning delivery, give a error message and skip record
             -- The Code flow should not come to this branch, as TP installed would not
             -- be Yes, when GC3 is installed.
             IF l_gc3_is_installed = 'Y' THEN
               -- Raise a new generic error message here, just trip creation will not happen.
               ----- skip this delivery and not add to the list
               l_count_error := l_count_error + 1;
             ELSE
               l_include_ids(l_include_ids.COUNT+1):=p_del_rows(l_index);
             END IF;
             --
           END IF;
        END LOOP;
        l_index:=p_del_rows.NEXT(l_index);
      END LOOP;

      -- OTM R12, glog proj, count the number above and display a single error message
      -- as oppose to showing multiple error messages
      -- The process will continue, as the message will come up as a Information Note
      -- Only filtered deliveries will be considered for further processing
      IF l_count_error > 0 THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_OTM_CR_TRIP_SUMMARY');
        IF l_count_error = p_del_rows.count THEN
          WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
          l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          x_return_status := l_return_status;
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Count of Errors', l_count_error);
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          RETURN;
        ELSE
          WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_WARNING);
          l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
          x_return_status := l_return_status;
        END IF;
      END IF;

      --call autocreate_trip_core separately for these 2 ids
      IF l_ignore_ids is not null and l_ignore_ids.COUNT>0 THEN
         autocreate_trip_wrp(
           p_del_rows      => l_ignore_ids,
           p_entity        => p_entity,
           x_trip_ids      => l_trip_ids,
           x_trip_names    => l_trip_names,
           x_return_status => l_return_status);

         IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
           x_return_status:=l_return_status;
           IF l_debug_on THEN
              WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           RETURN;
         END IF;
         IF l_trip_ids.COUNT > 0 THEN
           FOR i in l_trip_ids.FIRST..l_trip_ids.LAST LOOP
              x_trip_ids(x_trip_ids.COUNT+1):=l_trip_ids(i);
              x_trip_names(x_trip_names.COUNT+1):=l_trip_names(i);
           END LOOP;
         END IF;
      END IF;

      IF l_include_ids is not null and l_include_ids.COUNT>0 THEN
         l_trip_ids.DELETE;
         l_trip_names.DELETE;
         autocreate_trip_wrp(
           p_del_rows      => l_include_ids,
           p_entity        => p_entity,
           x_trip_ids      => l_trip_ids,
           x_trip_names    => l_trip_names,
           x_return_status => l_return_status);


         IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
           x_return_status:=l_return_status;  -- Bug#3884302
           IF l_debug_on THEN
              WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           RETURN;
         END IF;
         IF l_trip_ids.COUNT > 0 THEN
           FOR i in l_trip_ids.FIRST..l_trip_ids.LAST LOOP
              x_trip_ids(x_trip_ids.COUNT+1):=l_trip_ids(i);
              x_trip_names(x_trip_names.COUNT+1):=l_trip_names(i);
           END LOOP;
         END IF;
      END IF;

      IF l_return_status=WSH_UTIL_CORE.G_RET_STS_WARNING THEN
         x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
      END IF;

   END IF; --tp_is_installed

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --

   EXCEPTION
     WHEN others THEN
      wsh_util_core.default_handler('WSH_TRIPS_ACTIONS.AUTOCREATE_TRIP_MULTI');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END autocreate_trip_multi;


PROCEDURE autocreate_trip(
         p_del_rows   IN    wsh_util_core.id_tab_type,
         p_entity     IN    VARCHAR2,
         x_trip_id    OUT NOCOPY    NUMBER,
         x_trip_name  OUT NOCOPY    VARCHAR2,
         x_return_status OUT NOCOPY  VARCHAR2,
         p_sc_pickup_date         IN      DATE   DEFAULT NULL,
         p_sc_dropoff_date        IN      DATE   DEFAULT NULL) IS

CURSOR check_assigned(p_del_id IN NUMBER) IS
SELECT delivery_id
FROM   wsh_delivery_legs
WHERE  delivery_id = p_del_id;

-- When OTM is installed and user performs autocreate Trip action
-- the trip would be created as Ignore for Planning(based on the delivery)
-- Autocreate trip action is not allowed on an Include for Planning Delivery
--
-- When OTM is not installed, the behavior is that Trips are
-- created as Include/Ignore for Planning based on the delivery
-- and Include for Planning if null value at delivery
CURSOR check_ship_method(p_del_id IN NUMBER,p_ignore_flag IN VARCHAR2) IS
SELECT ship_method_code, carrier_id, mode_of_transport, service_level,
       status_code,
       --OTM R12, glog proj
       NVL(ignore_for_planning,p_ignore_flag),
       initial_pickup_date, ultimate_dropoff_date , nvl(shipment_direction,'O')
FROM   wsh_new_deliveries
WHERE  delivery_id = p_del_id;

l_shipment_direction VARCHAR2(100);

CURSOR trip_stops(p_trip_id IN NUMBER) IS
SELECT stop_id,
     planned_departure_date,
     planned_arrival_date,
     NVL(shipments_type_flag,'O') shipments_type_flag  --J-IB-NPARIKH
FROM   wsh_trip_stops
WHERE  trip_id = p_trip_id
ORDER BY stop_sequence_number;   -- J-IB-NPARIKH

l_delivery_id         NUMBER;
l_trip_id             NUMBER;

l_ship_method         wsh_trips.ship_method_code%TYPE;
l_ship_method_old     wsh_trips.ship_method_code%TYPE;
l_carrier_id          wsh_trips.carrier_id%TYPE;
l_mode                wsh_trips.mode_of_transport%TYPE;
l_service_level       wsh_trips.service_level%TYPE;
l_carrier_id_old      wsh_trips.carrier_id%TYPE;
l_mode_old            wsh_trips.mode_of_transport%TYPE;
l_service_level_old   wsh_trips.service_level%TYPE;
l_ignore_for_planning wsh_trips.ignore_for_planning%TYPE;

l_status_code         VARCHAR2(30);

l_ship_method_flag    BOOLEAN := TRUE;

l_rowid               VARCHAR2(30);
l_trip_info           WSH_TRIPS_PVT.TRIP_REC_TYPE;
assigned_del_error    EXCEPTION;
l_return_status       VARCHAR2(1);
l_del_legs            WSH_UTIL_CORE.ID_TAB_TYPE;
l_good_dels           WSH_UTIL_CORE.ID_TAB_TYPE;

/* H integration  for Multi Leg */
l_num_warn            NUMBER := 0;
l_stop_rec            WSH_TRIP_STOPS_PVT.TRIP_STOP_REC_TYPE;
l_pub_stop_rec        WSH_TRIP_STOPS_PUB.TRIP_STOP_PUB_REC_TYPE;
l_trip_rec            WSH_TRIPS_PVT.TRIP_REC_TYPE;
l_pub_trip_rec        WSH_TRIPS_PUB.TRIP_PUB_REC_TYPE;
l_grp_trip_rec        WSH_TRIPS_GRP.TRIP_PUB_REC_TYPE;
--l_return_status     VARCHAR2(30);
l_fte_flag            VARCHAR2(1):= 'N';
--
l_debug_on            BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'AUTOCREATE_TRIP';
--
l_stop_in_rec       WSH_TRIP_STOPS_VALIDATIONS.chkClose_in_rec_type;
l_stop_processed    VARCHAR2(10);
-- Bug 3413364, skip the delivery if it does not have both initial pickup date and ultimate dropoff date
l_initial_pickup_date    DATE;
l_ultimate_dropoff_date  DATE;
l_num_skipped            NUMBER := 0;
l_stop_tab               WSH_UTIL_CORE.id_tab_type;  -- DBI Project
l_dbi_rs                 VARCHAR2(1);         -- DBI Project

l_trip_ids           WSH_UTIL_CORE.ID_TAB_TYPE;
l_success_trip_ids   WSH_UTIL_CORE.ID_TAB_TYPE;

l_gc3_is_installed   VARCHAR2(1); -- OTM R12, glog proj
l_ignore_flag        WSH_TRIPS.IGNORE_FOR_PLANNING%TYPE;  -- OTM R12, glog proj
l_count_error        NUMBER;

--
BEGIN
   -- Bug 3413364, skip the delivery if it does not have both initial pickup date and ultimate dropoff date
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   -- Create a list of deliveries that are unassigned. All other deliveries have
   -- error messages set.
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
     wsh_debug_sv.log(l_module_name, 'p_entity', p_entity);
     wsh_debug_sv.log(l_module_name, 'p_del_rows.COUNT', p_del_rows.COUNT);
     wsh_debug_sv.log(l_module_name, 'p_sc_pickup_date', p_sc_pickup_date);
     wsh_debug_sv.log(l_module_name, 'p_sc_dropoff_date', p_sc_dropoff_date);
   END IF;
   --

   --OTM R12, glog proj, use Global Variable
   l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED;
   l_count_error := 0;

   -- If null, call the function
   IF l_gc3_is_installed IS NULL THEN
     l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED;
   END IF;
   IF l_gc3_is_installed = 'Y' THEN
     l_ignore_flag := 'Y';
   ELSE
     l_ignore_flag := 'N';
   END IF;
   -- end of OTM R12, glog proj

   FOR i IN 1..p_del_rows.count LOOP --{
      l_delivery_id := NULL;
      --
      OPEN check_assigned(p_del_rows(i)) ;
      FETCH check_assigned INTO l_delivery_id;
      CLOSE check_assigned;
      --
      IF (l_delivery_id IS NOT NULL) THEN --{
        -- Bug 3535050 : Omit the error message, if autocreate_trip
        -- is called from delivery detail and if the trip has already
        -- been created as part of the rating module.
        --
        IF (p_entity = 'D') THEN
         --{
         FND_MESSAGE.SET_NAME('WSH','WSH_DEL_AU_TRIP_ASSIGN_DEL');
         FND_MESSAGE.SET_TOKEN('DEL_NAME',
                               wsh_new_deliveries_pvt.get_name(p_del_rows(i)));
         wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR);
         l_num_skipped := l_num_skipped + 1;
         --}
        END IF;
      ELSE
         --} {
         -- Bug 3413364, skip the delivery if it does not have both initial pickup date and ultimate dropoff date
         l_ship_method := NULL;
         --
         OPEN  check_ship_method(p_del_rows(i),l_ignore_flag);
         FETCH check_ship_method INTO
               l_ship_method, l_carrier_id, l_mode,
               l_service_level, l_status_code, l_ignore_for_planning,
               l_initial_pickup_date, l_ultimate_dropoff_date, l_shipment_direction;
         CLOSE check_ship_method;

         --OTM R12, glog proj
         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_gc3_is_installed',l_gc3_is_installed);
           WSH_DEBUG_SV.log(l_module_name,'l_ignore_for_planning',l_ignore_for_planning);
         END IF;

         IF l_gc3_is_installed = 'Y' AND l_ignore_for_planning = 'N' THEN--{
           -- Raise a new generic error message here, just trip creation will not happen.
           FND_MESSAGE.SET_NAME('WSH','WSH_OTM_CR_TRIP');
           WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
           ----- skip this delivery, handled towards the end
           l_num_skipped := l_num_skipped + 1;
           l_count_error := l_count_error + 1;
         ELSE--} {

           -- If the pick up date and drop off date are defaulted from the
           -- ship confirm API then use these dates. Bug 3913206
           --
           IF (p_sc_pickup_date IS NOT NULL) OR (p_sc_dropoff_date IS NOT NULL)
           THEN --{
             l_initial_pickup_date := p_sc_pickup_date;
             l_ultimate_dropoff_date := p_sc_dropoff_date;
           END IF; --}
           --
           -- Bug 3413364, skip the delivery if it does not have both initial pickup date and ultimate dropoff date
           IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'l_shipment_direction',l_shipment_direction);
           END IF;

           IF (l_initial_pickup_date is NULL or l_ultimate_dropoff_date is NULL)
             AND nvl(l_shipment_direction,'O') IN ('O', 'IO') THEN--{
             --
             FND_MESSAGE.SET_NAME('WSH','WSH_DEL_DATES_MISSING');
             FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_del_rows(i)));
             wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR);
             l_num_skipped := l_num_skipped + 1;
             --
           ELSE
             --} {
             l_good_dels(l_good_dels.count+1) := p_del_rows(i);
             -- Bug 3334363, compare the ship method components
             -- to check if the ship method/components of the delivery
             -- should be defaulted to the trip.
             IF (l_carrier_id IS NOT NULL) THEN
               IF (nvl(l_carrier_id_old, l_carrier_id) = l_carrier_id) THEN
                 l_carrier_id_old := l_carrier_id;
               ELSE
                 l_ship_method_flag := FALSE;
                 EXIT;
               END IF;
             END IF;
             --
             IF (l_mode IS NOT NULL) THEN
               IF (nvl(l_mode_old, l_mode) = l_mode) THEN
                 l_mode_old := l_mode;
               ELSE
                 l_ship_method_flag := FALSE;
                 EXIT;
               END IF;
             END IF;
             --
             IF (l_service_level IS NOT NULL) THEN
               IF (nvl(l_service_level_old, l_service_level) = l_service_level) THEN
                 l_service_level_old := l_service_level;
               ELSE
                 l_ship_method_flag := FALSE;
                 EXIT;
               END IF;
             END IF;
             --

             IF l_ship_method_old IS NULL THEN
               l_ship_method_old :=  l_ship_method;
             END IF;
           END IF;   --}   -- for null dates
         END IF;--} for OTM 12, glog proj,
     END IF;--} -- delivery_id is null
   END LOOP;--}

   -- OTM R12, glog proj, count the number above and display a single error message
   -- as oppose to showing multiple error messages
   -- The process will continue, as the message will come up as a Information Note
   -- Only filtered deliveries will be considered for further processing
   -- l_num_skipped is used towards the end to determine the return status out of this
   -- API - Error or Warning
   IF l_count_error > 0 THEN
     FND_MESSAGE.SET_NAME('WSH','WSH_OTM_CR_TRIP_SUMMARY');
     IF l_count_error = p_del_rows.count THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'Count of Errors', l_count_error);
         WSH_DEBUG_SV.pop(l_module_name);
       END IF;
       RETURN;
     ELSE -- x_return_status is populated at the end
       WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_WARNING);
     END IF;
   END IF;

   --
   IF (l_good_dels.count > 0) THEN
    --{
    IF (l_ship_method_flag) THEN
        l_trip_info.ship_method_code := l_ship_method_old;
        l_trip_info.carrier_id       := l_carrier_id_old;
        l_trip_info.mode_of_transport:= l_mode_old;
        l_trip_info.service_level    := l_service_level_old;
    END IF;
    --
    l_trip_info.ignore_for_planning := l_ignore_for_planning;
    l_trip_info.planned_flag    := 'N';
    l_trip_info.status_code   := 'OP';
    l_trip_info.creation_date  := SYSDATE;
    l_trip_info.created_by     := fnd_global.user_id;
    l_trip_info.last_update_date  := SYSDATE;
    l_trip_info.last_updated_by   := fnd_global.user_id;
    l_trip_info.last_update_login := fnd_global.login_id;
    --
    /* H integration */
    /* The trip level call should have been made at parent level */
    --
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_PVT.CREATE_TRIP',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    wsh_trips_pvt.create_trip(l_trip_info, l_rowid, x_trip_id, x_trip_name,x_return_status);
    --
    IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
     --
     IF l_debug_on THEN
       wsh_debug_sv.log(l_module_name, 'Return Status after calling create_trip', x_return_Status);
       WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
     RETURN;
     --
    END IF;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_LEGS_ACTIONS.ASSIGN_DELIVERIES',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    wsh_delivery_legs_actions.assign_deliveries(
               p_del_rows => l_good_dels,
               p_trip_id => x_trip_id,
               p_create_flag => 'Y',
               x_leg_rows => l_del_legs,
               x_return_status => x_return_status,
               p_caller => 'AUTOCREATE_TRIP',
               -- Bug 3913206
               p_sc_pickup_date => p_sc_pickup_date,
               p_sc_dropoff_date => p_sc_dropoff_date
               );
    --

    IF x_return_status in ( WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
     --
     IF l_debug_on THEN
       wsh_debug_sv.log(l_module_name, 'Return Status after calling wsh_delivery_legs_actions.assign_deliveries', x_return_Status);
       WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
     RETURN;
     --
    ELSE
     --{
     -- H integration
     --
     IF x_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
      l_num_warn := l_num_warn + 1;
     END IF;

     IF (WSH_UTIL_CORE.FTE_IS_INSTALLED = 'Y') THEN
       l_fte_flag := 'Y';
     END IF;
     --
     FOR st IN trip_stops(x_trip_id) LOOP
       --{
       IF (st.planned_departure_date IS NULL) THEN
         --{
         IF l_fte_flag = 'Y' THEN
          --{
          -- H integration
          -- Get pvt type record structure for stop
          --
          IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_GRP.GET_STOP_DETAILS_PVT',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          wsh_trip_stops_grp.get_stop_details_pvt
             (p_stop_id => st.stop_id,
              x_stop_rec => l_stop_rec,
              x_return_status => l_return_status);
          --
          IF x_return_status in ( WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
            --
            x_return_status := l_return_status;
            --
            IF l_debug_on THEN
              WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            --
            RETURN;
            --
          ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
             l_num_warn := l_num_warn + 1;
          END IF;
          --
          l_stop_rec.planned_departure_date := nvl(l_stop_rec.planned_arrival_date,SYSDATE);
          --
          IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_FTE_INTEGRATION.TRIP_STOP_VALIDATIONS',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          wsh_fte_integration.trip_stop_validations
            (p_stop_rec => l_stop_rec,
             p_trip_rec => l_trip_rec,
             p_action => 'UPDATE',
             x_return_status => l_return_status);
          --
          IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
           --
           IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
              l_num_warn := l_num_warn + 1;
           ELSE
              x_return_status := l_return_status;
              --
              IF l_debug_on THEN
               WSH_DEBUG_SV.pop(l_module_name);
              END IF;
              --
              RETURN;
           END IF;
           --
          END IF;
          --}
         END IF;
         --
         -- End of H integration
         --
         UPDATE wsh_trip_stops
         SET   planned_departure_date = nvl(planned_arrival_date, SYSDATE)
         WHERE  stop_id = st.stop_id;
         --}
       END IF;
       --
       IF (st.planned_arrival_date IS NULL) THEN
        --{
        IF l_fte_flag = 'Y' THEN
         --{
         -- H integration
         -- Get pvt type record structure for stop
         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_GRP.GET_STOP_DETAILS_PVT',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --
         wsh_trip_stops_grp.get_stop_details_pvt
           (p_stop_id => st.stop_id,
            x_stop_rec => l_stop_rec,
            x_return_status => l_return_status);
         --
         IF x_return_status in ( WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
           --
           IF l_debug_on THEN
             WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           --
           RETURN;
         ELSIF  l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
           l_num_warn := l_num_warn + 1;
         END IF;
         --
         l_stop_rec.planned_arrival_date := nvl(l_stop_rec.planned_departure_date,SYSDATE);
         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_FTE_INTEGRATION.TRIP_STOP_VALIDATIONS',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --
         wsh_fte_integration.trip_stop_validations
           (p_stop_rec => l_stop_rec,
            p_trip_rec => l_trip_rec,
            p_action => 'UPDATE',
            x_return_status => l_return_status);
         --
         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
          --
          IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            l_num_warn := l_num_warn + 1;
          ELSE
            x_return_status := l_return_status;
            --
            IF l_debug_on THEN
              WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            --
            RETURN;
          END IF;
          --
         END IF;
         --}
        END IF;
        --
        -- End of H integration
        UPDATE wsh_trip_stops
        SET   planned_arrival_date = nvl(planned_departure_date, SYSDATE)
        WHERE  stop_id = st.stop_id;
        --
        -- DBI Project
        -- Updating  WSH_TRIP_STOPS.
        -- Call DBI API after the Update.
        -- This API will also check for DBI Installed or not
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Stop id -',st.stop_id);
        END IF;
        l_stop_tab(1) := st.stop_id;
        WSH_INTEGRATION.DBI_Update_Trip_Stop_Log
          (p_stop_id_tab    => l_stop_tab,
           p_dml_type       => 'UPDATE',
           x_return_status      => l_dbi_rs);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
        END IF;
        IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
              x_return_status := l_dbi_rs;
              -- just pass this return status to caller API
             IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'DBI API Returned Unexpected error '||x_return_status);
                WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        return;
        END IF;
        -- End of Code for DBI Project

        --}
       END IF;
       --}
     END LOOP;

     -- SSN change
     -- Call to reset_stop_planned_dates API should be made
     -- only for profile = PAD
     IF WSH_TRIPS_ACTIONS.GET_STOP_SEQ_MODE  = WSH_INTERFACE_GRP.G_STOP_SEQ_MODE_PAD THEN
       -- re-set the dates according to sequence number
       -- bug 3516052
       l_trip_id := x_trip_id;

       WSH_TRIPS_ACTIONS.reset_stop_planned_dates( p_trip_id => l_trip_id,
                                p_caller        => 'WSH_AUTOCREATE_TRIP',
                                x_return_status => l_return_status);
       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
           l_num_warn := l_num_warn + 1;
         ELSE
           x_return_status := l_return_status;
           --
           IF l_debug_on THEN
             WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           --
           RETURN;
         END IF;
       END IF;
     ELSE
       -- call handle_internal_stop here for mode = SSN
       l_trip_ids(1) := x_trip_id;
       Handle_Internal_Stops
          (  p_trip_ids          =>  l_trip_ids,
             p_caller            => 'WSH_AUTOCREATE_TRIP',
             x_success_trip_ids  => l_success_trip_ids,
             x_return_status     => l_return_status);
       IF l_return_status in (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
         x_return_status := l_return_status;
         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         --
         RETURN;
       ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
         l_num_warn := l_num_warn + 1;
       END IF;
     END IF;   --if get_stop_seq_mode = PAD
     --}
    END IF;
    --}
   END IF; /* if good_dels.COUNT */
    IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_FLEXFIELD_UTILS.WRITE_DFF_ATTRIBUTES',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
           -- for bug 5948562, to populate values in additional trip information flexfield, when auto creating a trip
           wsh_flexfield_utils.WRITE_DFF_ATTRIBUTES
                                               (p_table_name => 'WSH_TRIPS',
                                                p_primary_id => x_trip_id,
                                                x_return_status => x_return_status);

  IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                  IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,  'PROC WSH_FLEXFIELD_UTILS.WRITE_DFF_ATTRIBUTES RETURNED ERROR'  );
                  END IF;
                  IF l_debug_on THEN
                     WSH_DEBUG_SV.pop(l_module_name);
                  END IF;
                  RETURN;
               END IF;
   --
   -- Bug 3413364, skip the delivery if it does not have both
   -- initial pickup date and ultimate dropoff date
   --
   IF l_num_skipped > 0 AND l_num_skipped = p_del_rows.count THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   ELSIF l_num_skipped > 0 or l_num_warn> 0  THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
   END IF;
   --
   -- TO DO: Add message for successful completion of action
   IF x_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
      FND_MESSAGE.SET_NAME('WSH', 'WSH_AUTOCREATE_TRIP_WARN');
      wsh_util_core.add_message(x_return_status);
   END IF;
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   EXCEPTION
     --
     WHEN others THEN
      --
      wsh_util_core.default_handler('WSH_TRIPS_ACTIONS.AUTOCREATE_TRIP');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END autocreate_trip;


--Compatibility Changes - removed trip_id, trip_name and added x_trip_rows

PROCEDURE autocreate_del_trip(
         p_line_rows     IN    wsh_util_core.id_tab_type,
         p_org_rows      IN    wsh_util_core.id_tab_type,
         p_max_detail_commit  IN NUMBER := 1000,
         x_del_rows      OUT   NOCOPY wsh_util_core.id_tab_type,
         x_trip_rows      OUT  NOCOPY wsh_util_core.id_tab_type,
         x_return_status    OUT NOCOPY VARCHAR2) IS

l_grouping_rows wsh_util_core.id_tab_type;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'AUTOCREATE_DEL_TRIP';

--Compatibility Changes
    l_cc_validate_result        VARCHAR2(1);
    l_cc_failed_records         WSH_FTE_COMP_CONSTRAINT_PKG.failed_line_tab_type;
    l_cc_line_groups            WSH_FTE_COMP_CONSTRAINT_PKG.line_group_tab_type;
    l_cc_group_info         WSH_FTE_COMP_CONSTRAINT_PKG.cc_group_tab_type;

    b_cc_linefailed         boolean;
    b_cc_groupidexists          boolean;
    l_id_tab_temp           wsh_util_core.id_tab_type;
    l_line_rows_temp            wsh_util_core.id_tab_type;
    l_cc_count_success          NUMBER;
    l_cc_count_group_ids        NUMBER;
    l_cc_count_rec          NUMBER;
    l_cc_group_ids          wsh_util_core.id_tab_type;
    l_cc_count_trip_rows        NUMBER;
    l_cc_count_del_rows         NUMBER;
    l_cc_count_grouping_rows        NUMBER;
    l_del_rows_temp         wsh_util_core.id_tab_type;
    --l_trip_name               VARCHAR2(30);
    l_cc_trip_id            wsh_util_core.id_tab_type;
    l_trip_id_tab           wsh_util_core.id_tab_type;
    l_cc_del_rows           wsh_util_core.id_tab_type;
    l_cc_grouping_rows          wsh_util_core.id_tab_type;
    l_cc_return_status          VARCHAR2(1);
--    l_trip_id             NUMBER;

    l_cc_upd_dlvy_intmed_ship_to    VARCHAR2(1);
    l_cc_upd_dlvy_ship_method       VARCHAR2(1);
    l_cc_dlvy_intmed_ship_to        NUMBER;
    l_cc_dlvy_ship_method       VARCHAR2(30);

    l_num_errors            NUMBER;
    l_num_warnings          NUMBER;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    --dummy tables for calling validate_constraint_mainper
    l_cc_del_attr_tab           WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type;
    l_cc_det_attr_tab           WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type;
    l_cc_trip_attr_tab          WSH_TRIPS_PVT.Trip_Attr_Tbl_Type;
    l_cc_stop_attr_tab          WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type;
    l_cc_in_ids             wsh_util_core.id_tab_type;
    l_cc_fail_ids       wsh_util_core.id_tab_type;

    CURSOR del_cur(p_dlvy_id NUMBER) IS
    SELECT SHIP_METHOD_CODE, INTMED_SHIP_TO_LOCATION_ID
    FROM wsh_new_deliveries
    WHERE delivery_id = p_dlvy_id;
    --and (SHIP_METHOD_CODE is not null OR INTMED_SHIP_TO_LOCATION_ID is not null);

    CURSOR trip_cur(p_trip_id NUMBER) IS
    SELECT SHIP_METHOD_CODE
    FROM wsh_trips
    WHERE trip_id = p_trip_id;
    --and SHIP_METHOD_CODE is not null;

    l_line_rows             wsh_util_core.id_tab_type:=p_line_rows;
--Compatibility Changes

/* J TP Release */
l_trip_ids wsh_util_core.id_tab_type;
l_trip_names wsh_util_core.column_tab_type;
l_tripindex NUMBER;

-- deliveryMerge
l_return_status         VARCHAR2(1);
Adjust_Planned_Flag_Err EXCEPTION;
--
BEGIN

   --
   -- Debug Statements
   --
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL--{
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;--}
   --
   IF l_debug_on THEN--{
       WSH_DEBUG_SV.push(l_module_name);
       --
       WSH_DEBUG_SV.log(l_module_name,'P_MAX_DETAIL_COMMIT',P_MAX_DETAIL_COMMIT);
   END IF;--}
   --
   --
   -- Debug Statements
   --
   IF l_debug_on THEN--{
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_AUTOCREATE.AUTOCREATE_DEL_ACROSS_ORGS',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;--}
   --
    --Compatibility Changes
    IF wsh_util_core.fte_is_installed = 'Y' THEN--{

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
         p_in_ids               =>  l_line_rows,
         x_fail_ids             =>  l_cc_fail_ids,
         x_validate_result          =>  l_cc_validate_result,
         x_failed_lines             =>  l_cc_failed_records,
         x_line_groups              =>  l_cc_line_groups,
         x_group_info               =>  l_cc_group_info,
         x_msg_count                =>  l_msg_count,
         x_msg_data                 =>  l_msg_data,
         x_return_status            =>  x_return_status);

      IF l_debug_on THEN--{
        wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_constraint_main',x_return_status);
        wsh_debug_sv.log(l_module_name,'validate_result After Calling validate_constraint_main',l_cc_validate_result);
        wsh_debug_sv.log(l_module_name,'msg_count After Calling validate_constraint_main',l_msg_count);
        wsh_debug_sv.log(l_module_name,'msg_data After Calling validate_constraint_main',l_msg_data);
        wsh_debug_sv.log(l_module_name,'fail_ids count After Calling validate_constraint_main',l_cc_failed_records.COUNT);
        wsh_debug_sv.log(l_module_name,'l_cc_line_groups.count count After Calling validate_constraint_main',l_cc_line_groups.COUNT);
        wsh_debug_sv.log(l_module_name,'group_info count After Calling validate_constraint_main',l_cc_group_info.COUNT);
      END IF;--}
      --


    IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
       OR (x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR AND l_cc_failed_records.COUNT=l_line_rows.COUNT)
    THEN--{
        --
        -- Debug Statements
        --
        IF l_debug_on THEN--{
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;--}
        --
        RETURN;
    END IF;--}

    IF l_cc_failed_records.COUNT>0 AND x_return_status=wsh_util_core.g_ret_sts_error THEN--{
         IF l_debug_on THEN--{
           WSH_DEBUG_SV.logmsg(l_module_name,'All dels have failed compatibility -> delivery and Trip not created');
         END IF;--}
         -- if one one delivery fails for auto create trip, all the lines should
         -- should be unassigned from the deliveries and the action should
         -- fail for all the lines. (pack J 2862777)
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         fnd_message.set_name('WSH', 'WSH_COMP_ACT_FAIL');
         wsh_util_core.add_message(x_return_status);
         IF l_debug_on THEN--{
             WSH_DEBUG_SV.pop(l_module_name);
         END IF;--}
         --
         RETURN;
    ELSIF l_cc_line_groups.COUNT>0 AND x_return_status=wsh_util_core.g_ret_sts_error THEN--}{

        --1. get the group ids by which the constraints API has grouped the lines
        l_cc_count_group_ids:=1;
        FOR i in l_cc_line_groups.FIRST..l_cc_line_groups.LAST LOOP --{
            b_cc_groupidexists:=FALSE;
            IF l_cc_group_ids.COUNT>0 THEN--{
             FOR j in l_cc_group_ids.FIRST..l_cc_group_ids.LAST LOOP--{
                IF (l_cc_line_groups(i).line_group_id=l_cc_group_ids(j)) THEN--{
                    b_cc_groupidexists:=TRUE;
                END IF;--}
             END LOOP;--}
            END IF;--}
            IF (NOT(b_cc_groupidexists)) THEN--{
                l_cc_group_ids(l_cc_count_group_ids):=l_cc_line_groups(i).line_group_id;
                l_cc_count_group_ids:=l_cc_count_group_ids+1;
            END IF;--}
        END LOOP;--}

        --2. from the group id table above, loop thru lines table to get the lines which belong
        --to each group and call autocreate_trip for each group

        FOR i in l_cc_group_ids.FIRST..l_cc_group_ids.LAST LOOP--{
            l_cc_count_rec:=1;
            FOR j in l_cc_line_groups.FIRST..l_cc_line_groups.LAST LOOP     --{
                IF l_cc_line_groups(j).line_group_id=l_cc_group_ids(i) THEN--{
                  l_id_tab_temp(l_cc_count_rec):=l_cc_line_groups(j).entity_line_id;
                  l_cc_count_rec:=l_cc_count_rec+1;
                END IF;--}
            END LOOP;--}

                --
            IF l_debug_on THEN--{
                    wsh_debug_sv.log(l_module_name,'id_tab_temp count ',l_id_tab_temp.COUNT);
            END IF;--}


           wsh_delivery_autocreate.autocreate_del_across_orgs(
                      p_line_rows => l_id_tab_temp,
                      p_org_rows => p_org_rows,
                      p_container_flag => 'N',
                      p_check_flag => 'N',
                      p_caller     => 'WSH_AUTO_CREATE_DEL_TRIP',
                      p_max_detail_commit => p_max_detail_commit,
                      x_del_rows => x_del_rows,
                      x_grouping_rows => l_grouping_rows,
                      x_return_status => x_return_status);

          --set the intermediate ship to, ship method to null if group rec from constraint validation has these as 'N'
          l_cc_upd_dlvy_intmed_ship_to:='Y';
                  l_cc_upd_dlvy_ship_method:='Y';
          IF l_cc_group_info.COUNT>0 THEN--{
           FOR j in l_cc_group_info.FIRST..l_cc_group_info.LAST LOOP--{
              IF l_cc_group_info(j).line_group_id=l_cc_group_ids(i) THEN--{
                l_cc_upd_dlvy_intmed_ship_to:=l_cc_group_info(j).upd_dlvy_intmed_ship_to;
                l_cc_upd_dlvy_ship_method:=l_cc_group_info(j).upd_dlvy_ship_method;
              END IF;--}
           END LOOP;--}
          END IF;--}

        IF l_debug_on THEN--{
                wsh_debug_sv.log(l_module_name,'l_cc_upd_dlvy_intmed_ship_to ',l_cc_upd_dlvy_intmed_ship_to);
                wsh_debug_sv.log(l_module_name,'l_cc_upd_dlvy_ship_method ',l_cc_upd_dlvy_ship_method);
                wsh_debug_sv.log(l_module_name,'l_delivery_ids_tbl.COUNT ',x_del_rows.COUNT);
                wsh_debug_sv.log(l_module_name,'l_grouping_tbl.COUNT ',l_grouping_rows.COUNT);
            wsh_debug_sv.log(l_module_name,'l_return_status after calling autocreate_del in comp ',x_return_status);
        END IF;--}

          IF l_cc_upd_dlvy_intmed_ship_to='N' OR l_cc_upd_dlvy_ship_method='N' THEN--{
             IF l_id_tab_temp.COUNT>0 THEN--{
                 FOR i in l_id_tab_temp.FIRST..l_id_tab_temp.LAST LOOP--{
                   FOR delcurtemp in del_cur(l_id_tab_temp(i)) LOOP--{
                        l_cc_dlvy_intmed_ship_to:=delcurtemp.INTMED_SHIP_TO_LOCATION_ID;
                        l_cc_dlvy_ship_method:=delcurtemp.SHIP_METHOD_CODE;
                        IF l_cc_upd_dlvy_intmed_ship_to='N' and l_cc_dlvy_intmed_ship_to IS NOT NULL THEN--{
                            update wsh_new_deliveries set INTMED_SHIP_TO_LOCATION_ID=null
                            where delivery_id=l_id_tab_temp(i);
                        END IF;--}
                        --IF l_cc_upd_dlvy_ship_method='N' and l_cc_dlvy_ship_method IS NOT NULL THEN
                        IF l_cc_upd_dlvy_ship_method='N' THEN--{
                            update wsh_new_deliveries
                            set SHIP_METHOD_CODE=null,
                                CARRIER_ID = null,
                                MODE_OF_TRANSPORT = null,
                                SERVICE_LEVEL = null
                            where delivery_id=l_id_tab_temp(i);
                        END IF;             --}
                  END LOOP;--}
                END LOOP;--}
             END IF;--}
          END IF;--}
          --set the intermediate ship to, ship method to null if group rec from constraint validation has these as 'N'

          IF l_cc_del_rows.COUNT=0 THEN--{
            l_cc_del_rows:=x_del_rows;
          ELSE--}{
            l_cc_count_del_rows:=l_cc_del_rows.COUNT;
            IF x_del_rows.COUNT>0 THEN--{
               FOR i in x_del_rows.FIRST..x_del_rows.LAST LOOP--{
                l_cc_del_rows(l_cc_count_del_rows+i):=x_del_rows(i);
               END LOOP;--}
            END IF;--}
          END IF;         --}

          IF l_cc_grouping_rows.COUNT=0 THEN--{
            l_cc_grouping_rows:=l_grouping_rows;
          ELSE--}{
            l_cc_count_grouping_rows:=l_cc_grouping_rows.COUNT;
            IF l_grouping_rows.COUNT>0 THEN--{
               FOR i in l_grouping_rows.FIRST..l_grouping_rows.LAST LOOP--{
                l_cc_grouping_rows(l_cc_count_grouping_rows+i):=l_grouping_rows(i);
               END LOOP;--}
            END IF;--}
          END IF;         --}

          IF (l_cc_return_status is not null AND l_cc_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN--{
              x_return_status:=l_cc_return_status;
          ELSIF (l_cc_return_status is not null AND l_cc_return_status=WSH_UTIL_CORE.G_RET_STS_WARNING AND x_return_status=WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN--}{
              x_return_status:=l_cc_return_status;
          ELSE--}{
              l_cc_return_status:=x_return_status;
          END IF;--}
              --
              --
        END LOOP;--}
        l_grouping_rows:=l_cc_grouping_rows;
        x_del_rows:=l_cc_del_rows;
        x_return_status:=l_cc_return_status;

        IF l_debug_on THEN--{
                wsh_debug_sv.log(l_module_name,'l_delivery_ids_tbl.COUNT after loop ',x_del_rows.COUNT);
                wsh_debug_sv.log(l_module_name,'l_grouping_tbl.COUNT after loop',l_grouping_rows.COUNT);
        END IF;--}

        ELSE -- line_group>0 }{

           wsh_delivery_autocreate.autocreate_del_across_orgs(
                  p_line_rows => p_line_rows,
                  p_org_rows => p_org_rows,
                  p_container_flag => 'N',
                  p_check_flag => 'N',
                  p_caller     => 'WSH_AUTO_CREATE_DEL_TRIP',
                  p_max_detail_commit => p_max_detail_commit,
                  x_del_rows => x_del_rows,
                  x_grouping_rows => l_grouping_rows,
                  x_return_status => x_return_status);

           --bug 2729742
             IF l_debug_on THEN--{
                    wsh_debug_sv.log(l_module_name,'l_cc_group_info.COUNT ',l_cc_group_info.COUNT);
             END IF;--}

             IF l_cc_group_info.COUNT>0 THEN--{
                  --set the intermediate ship to, ship method to null if group rec from constraint validation has these as 'N'
                  l_cc_upd_dlvy_intmed_ship_to:='Y';
                  l_cc_upd_dlvy_ship_method:='Y';
                  l_cc_upd_dlvy_intmed_ship_to:=l_cc_group_info(1).upd_dlvy_intmed_ship_to;
                  l_cc_upd_dlvy_ship_method:=l_cc_group_info(1).upd_dlvy_ship_method;

                  IF l_debug_on THEN--{

                    wsh_debug_sv.log(l_module_name,'l_cc_group_info.COUNT ',l_cc_group_info.COUNT);
                    wsh_debug_sv.log(l_module_name,'l_cc_upd_dlvy_intmed_ship_to ',l_cc_upd_dlvy_intmed_ship_to);
                    wsh_debug_sv.log(l_module_name,'l_cc_upd_dlvy_ship_method ',l_cc_upd_dlvy_ship_method);
                  END IF;--}

                  IF l_cc_upd_dlvy_intmed_ship_to='N' OR l_cc_upd_dlvy_ship_method='N' THEN--{
                     IF x_del_rows.COUNT>0 THEN--{
                       FOR i in x_del_rows.FIRST..x_del_rows.LAST LOOP--{
                          FOR delcurtemp in del_cur(x_del_rows(i)) LOOP--{
                             l_cc_dlvy_intmed_ship_to:=delcurtemp.INTMED_SHIP_TO_LOCATION_ID;
                             l_cc_dlvy_ship_method:=delcurtemp.SHIP_METHOD_CODE;
                             IF l_cc_upd_dlvy_intmed_ship_to='N' and l_cc_dlvy_intmed_ship_to IS NOT NULL THEN--{
                               update wsh_new_deliveries set INTMED_SHIP_TO_LOCATION_ID=null
                               where delivery_id=x_del_rows(i);
                             END IF;--}
                             --IF l_cc_upd_dlvy_ship_method='N' and l_cc_dlvy_ship_method IS NOT NULL THEN
                             IF l_cc_upd_dlvy_ship_method='N' THEN--{
                               update wsh_new_deliveries
                               set SHIP_METHOD_CODE=null,
                                CARRIER_ID = null,
                                MODE_OF_TRANSPORT = null,
                                SERVICE_LEVEL = null
                               where delivery_id=x_del_rows(i);
                             END IF;             --}
                          END LOOP;--}
                       END LOOP;--}
                     END IF;--}
                  END IF;--}
                  --set the intermediate ship to, ship method to null if group rec from constraint validation has these as 'N'
             END IF;--group_info.count>0--}
           --bug 2729742

        END IF;--line_groups is not null--}
    ELSE --}{
            --
       wsh_delivery_autocreate.autocreate_del_across_orgs(
                  p_line_rows => p_line_rows,
                  p_org_rows => p_org_rows,
                  p_container_flag => 'N',
                  p_check_flag => 'N',
                  p_caller     => 'WSH_AUTO_CREATE_DEL_TRIP',
                  p_max_detail_commit => p_max_detail_commit,
                  x_del_rows => x_del_rows,
                  x_grouping_rows => l_grouping_rows,
                  x_return_status => x_return_status);

    END IF;--}
    --Compatibility Changes

      --
      IF l_debug_on THEN--{
        wsh_debug_sv.log(l_module_name,'Return Status After Calling Autocreate_Del_across_orgs',x_return_status);
      END IF;--}


    IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) OR
        (x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN--{
        --
        -- Debug Statements
        --
        IF l_debug_on THEN--{
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;--}
        --
        RETURN;
    END IF;--}

--autocreate trip with all delivery lines
    --Compatibility Changes
    --initialize tables
    l_cc_failed_records.DELETE;
    l_cc_line_groups.DELETE;
    l_cc_group_ids.DELETE;
    l_id_tab_temp.DELETE;
    IF wsh_util_core.fte_is_installed = 'Y' THEN--{

       WSH_FTE_COMP_CONSTRAINT_PKG.validate_constraint_main(
         p_api_version_number   =>  1.0,
         p_init_msg_list        =>  FND_API.G_FALSE,
         p_entity_type          =>  'D',
         p_target_id            =>  null,
         p_action_code          =>  'AUTOCREATE-TRIP',
         p_del_attr_tab         =>  l_cc_del_attr_tab,
         p_det_attr_tab         =>  l_cc_det_attr_tab,
         p_trip_attr_tab        =>  l_cc_trip_attr_tab,
         p_stop_attr_tab        =>  l_cc_stop_attr_tab,
         p_in_ids               =>  x_del_rows,
         x_fail_ids             =>  l_cc_fail_ids,
         x_validate_result          =>  l_cc_validate_result,
         x_failed_lines             =>  l_cc_failed_records,
         x_line_groups              =>  l_cc_line_groups,
         x_group_info               =>  l_cc_group_info,
         x_msg_count                =>  l_msg_count,
         x_msg_data                 =>  l_msg_data,
         x_return_status            =>  x_return_status);

       IF l_debug_on THEN--{
         wsh_debug_sv.logmsg(l_module_name,'For autocreate_trip');
         wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_constraint_main',x_return_status);
         wsh_debug_sv.log(l_module_name,'validate_result After Calling validate_constraint_main',l_cc_validate_result);
         wsh_debug_sv.log(l_module_name,'msg_count After Calling validate_constraint_main',l_msg_count);
         wsh_debug_sv.log(l_module_name,'msg_data After Calling validate_constraint_main',l_msg_data);
         wsh_debug_sv.log(l_module_name,'fail_ids count After Calling validate_constraint_main',l_cc_failed_records.COUNT);
         wsh_debug_sv.log(l_module_name,'l_cc_line_groups.count count After Calling validate_constraint_main',l_cc_line_groups.COUNT);
         wsh_debug_sv.log(l_module_name,'group_info count After Calling validate_constraint_main',l_cc_group_info.COUNT);
       END IF;--}
       --

       IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN--{
        --
        -- Debug Statements
        --
            IF l_debug_on THEN--{
                WSH_DEBUG_SV.pop(l_module_name);
            END IF;--}
            --
            RETURN;
       END IF;--}

       --do nothing if all dels have errored out (deliveries shud be created and trip shud not be
       IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR AND l_cc_failed_records.COUNT > 0) THEN--{
         IF l_debug_on THEN--{
           WSH_DEBUG_SV.logmsg(l_module_name,'All dels have failed compatibility -> Trip not created');
         END IF;--}
         -- if one one delivery fails for auto create trip, all the lines should
         -- should be unassigned from the deliveries and the action should
         -- fail for all the lines. (pack J 2862777)
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         fnd_message.set_name('WSH', 'WSH_COMP_ACT_FAIL');
         wsh_util_core.add_message(x_return_status);
         IF l_debug_on THEN--{
             WSH_DEBUG_SV.pop(l_module_name);
         END IF;--}
         --
         RETURN;
       ELSIF l_cc_line_groups.COUNT>0 AND x_return_status=wsh_util_core.g_ret_sts_error THEN--}{

         --1. get the group ids by which the constraints API has grouped the lines
         l_cc_count_group_ids:=1;
         FOR i in l_cc_line_groups.FIRST..l_cc_line_groups.LAST LOOP --{
            b_cc_groupidexists:=FALSE;
            IF l_cc_group_ids.COUNT>0 THEN--{
               FOR j in l_cc_group_ids.FIRST..l_cc_group_ids.LAST LOOP--{
                IF (l_cc_line_groups(i).line_group_id=l_cc_group_ids(j)) THEN--{
                    b_cc_groupidexists:=TRUE;
                END IF;--}
               END LOOP;--}
            END IF;--}
            IF (NOT(b_cc_groupidexists)) THEN--{
                l_cc_group_ids(l_cc_count_group_ids):=l_cc_line_groups(i).line_group_id;
                l_cc_count_group_ids:=l_cc_count_group_ids+1;
            END IF;--}
         END LOOP;--}

         --2. from the group id table above, loop thru lines table to get the lines which belong
         --to each group and call autocreate_trip for each group

         FOR i in l_cc_group_ids.FIRST..l_cc_group_ids.LAST LOOP--{
            l_cc_count_rec:=1;
            FOR j in l_cc_line_groups.FIRST..l_cc_line_groups.LAST LOOP     --{
                IF l_cc_line_groups(j).line_group_id=l_cc_group_ids(i) THEN--{
                  l_id_tab_temp(l_cc_count_rec):=l_cc_line_groups(j).entity_line_id;
                  l_cc_count_rec:=l_cc_count_rec+1;
                END IF;--}
            END LOOP;--}

            --
            IF l_debug_on THEN--{
                wsh_debug_sv.log(l_module_name,'id_tab_temp count ',l_id_tab_temp.COUNT);
                wsh_debug_sv.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERY_ACTIONS.Adjust_Planned_Flag ');
            END IF;--}

            -- deliveryMerge
            WSH_NEW_DELIVERY_ACTIONS.Adjust_Planned_Flag(
           p_delivery_ids           => l_id_tab_temp,
           p_caller                 => 'WSH_DLMG',
           p_force_appending_limit  => 'N',
           p_call_lcss              => 'Y',
           p_event                  => NULL,
           x_return_status          => l_return_status);

            IF l_debug_on THEN                --{
                wsh_debug_sv.log(l_module_name,'Return status from WSH_NEW_DELIVERY_ACTIONS.Adjust_Planned_Flag ', l_return_status);
            END IF;--}

            IF l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)  THEN--{
               raise Adjust_Planned_Flag_Err;
            END IF;            --}

            /* J TP Release */
            autocreate_trip_multi(
                             p_del_rows      => l_id_tab_temp,
                             p_entity        => 'L',
                             x_trip_ids      => l_trip_ids,
                             x_trip_names    => l_trip_names,
                             x_return_status => x_return_status);

            --set the intermediate ship to, ship method to null if group rec from constraint validation has these as 'N'
            l_cc_upd_dlvy_ship_method:='Y';
            IF l_cc_group_info.COUNT>0 THEN--{
             FOR j in l_cc_group_info.FIRST..l_cc_group_info.LAST LOOP--{
              IF l_cc_group_info(j).line_group_id=l_cc_group_ids(i) THEN--{
                l_cc_upd_dlvy_ship_method:=l_cc_group_info(j).upd_dlvy_ship_method;
              END IF;--}
             END LOOP;--}
            END IF;--}

            IF l_debug_on THEN--{
                wsh_debug_sv.log(l_module_name,'l_cc_upd_dlvy_ship_method ',l_cc_upd_dlvy_ship_method);
                wsh_debug_sv.log(l_module_name,'l_trip_id ',l_trip_ids(1));
                wsh_debug_sv.log(l_module_name,'l_trip_name ',l_trip_names(1));
                wsh_debug_sv.log(l_module_name,'l_return_status after calling autocreate_trip in comp ',x_return_status);
            END IF;--}

            /* J TP Release */
            IF l_trip_ids is not null AND l_trip_ids.COUNT>0 THEN--{
             FOR l_tripindex IN l_trip_ids.FIRST..l_trip_ids.LAST LOOP--{
               IF l_cc_upd_dlvy_ship_method='N' THEN--{
                FOR tripcurtemp in trip_cur(l_trip_ids(l_tripindex)) LOOP--{
                            update wsh_trips
                            set SHIP_METHOD_CODE=null,
                                CARRIER_ID = null,
                                MODE_OF_TRANSPORT = null,
                                SERVICE_LEVEL = null
                            where trip_id=l_trip_ids(l_tripindex);
                END LOOP;--}
               END IF;--}
               --set the intermediate ship to, ship method to null if group rec from constraint validation has these as 'N'
                 l_cc_trip_id(l_cc_trip_id.COUNT+1):=l_trip_ids(l_tripindex);
             END LOOP;--}
            END IF;--}

            IF (l_cc_return_status is not null AND l_cc_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN--{
              x_return_status:=l_cc_return_status;
            ELSIF (l_cc_return_status is not null AND l_cc_return_status=WSH_UTIL_CORE.G_RET_STS_WARNING AND x_return_status=WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN--}{
              x_return_status:=l_cc_return_status;
            ELSE --}{
              l_cc_return_status:=x_return_status;
            END IF;--}
              --
         END LOOP;--}

         l_trip_id_tab:=l_cc_trip_id;
         x_return_status:=l_cc_return_status;

         IF l_debug_on THEN--{
                wsh_debug_sv.log(l_module_name,'l_trip_id_tab.COUNT after loop ',l_trip_id_tab.COUNT);
         END IF;--}

       ELSE --line_groups --}{
         --
            -- deliveryMerge
            WSH_NEW_DELIVERY_ACTIONS.Adjust_Planned_Flag(
           p_delivery_ids           => x_del_rows,
           p_caller                 => 'WSH_DLMG',
           p_force_appending_limit  => 'N',
           p_call_lcss              => 'Y',
           p_event                  => NULL,
           x_return_status          => l_return_status);

            IF l_debug_on THEN                --{
                wsh_debug_sv.log(l_module_name,'Return status from WSH_NEW_DELIVERY_ACTIONS.Adjust_Planned_Flag ', l_return_status);
            END IF;--}

            IF l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)  THEN--{
               raise Adjust_Planned_Flag_Err;
            END IF;         --}

            /* J TP Release */
            autocreate_trip_multi(
                             p_del_rows      => x_del_rows,
                             p_entity        => 'L',
                             x_trip_ids      => l_trip_id_tab,
                             x_trip_names    => l_trip_names,
                             x_return_status => x_return_status);

           --bug 2729742
           --set the intermediate ship to, ship method to null if group rec from constraint validation has these as 'N'
             IF l_debug_on THEN--{
                    wsh_debug_sv.log(l_module_name,'l_cc_group_info.COUNT ',l_cc_group_info.COUNT);
             END IF;--}

             IF l_cc_group_info.COUNT>0 THEN--{

                  l_cc_upd_dlvy_ship_method:='Y';
                  l_cc_upd_dlvy_ship_method:=l_cc_group_info(1).upd_dlvy_ship_method;

                  IF l_debug_on THEN--{

                    wsh_debug_sv.log(l_module_name,'l_cc_group_info.COUNT ',l_cc_group_info.COUNT);
                    wsh_debug_sv.log(l_module_name,'l_cc_upd_dlvy_ship_method ',l_cc_upd_dlvy_ship_method);
                  END IF;--}

                  IF l_cc_upd_dlvy_ship_method='N' and l_trip_id_tab is not null and l_trip_id_tab.COUNT>0 THEN--{
                   FOR l_tripindex IN l_trip_id_tab.FIRST..l_trip_id_tab.LAST LOOP--{
                    FOR tripcurtemp in trip_cur(l_trip_id_tab(l_tripindex)) LOOP--{
                            update wsh_trips
                            set SHIP_METHOD_CODE=null,
                                CARRIER_ID = null,
                                MODE_OF_TRANSPORT = null,
                                SERVICE_LEVEL = null
                            where trip_id=l_trip_id_tab(l_tripindex);
                    END LOOP;--}
                   END LOOP;--}
                  END IF;--}

                  --set the intermediate ship to, ship method to null if group rec from constraint validation has these as 'N'
             END IF;--group_info.count>0--}
           --bug 2729742

       END IF;--line_groups is not null--}

    ELSE --}{
            --
            -- deliveryMerge
       WSH_NEW_DELIVERY_ACTIONS.Adjust_Planned_Flag(
          p_delivery_ids           => x_del_rows,
          p_caller                 => 'WSH_DLMG',
          p_force_appending_limit  => 'N',
          p_call_lcss              => 'Y',
          p_event                  => NULL,
          x_return_status          => l_return_status);

       IF l_debug_on THEN                --{
           wsh_debug_sv.log(l_module_name,'Return status from WSH_NEW_DELIVERY_ACTIONS.Adjust_Planned_Flag ', l_return_status);
       END IF;--}

       IF l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)  THEN--{
          raise Adjust_Planned_Flag_Err;
       END IF; --}

       /* J TP Release */
       autocreate_trip_multi(
                             p_del_rows      => x_del_rows,
                             p_entity        => 'L',
                             x_trip_ids      => l_trip_id_tab,
                             x_trip_names    => l_trip_names,
                             x_return_status => x_return_status);

    END IF;--}
    --Compatibility Changes
    --autocreate trip
    x_trip_rows:=l_trip_id_tab;



   IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN--{
      --
      -- Debug Statements
      --
      IF l_debug_on THEN--{
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;--}
      --
      RETURN;
   END IF;--}

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   --
   -- Debug Statements
   --
   IF l_debug_on THEN--{
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;--}
   --

   EXCEPTION

     -- deliveryMerge
     WHEN Adjust_Planned_Flag_Err THEN
           FND_MESSAGE.SET_NAME('WSH', 'WSH_ADJUST_PLANNED_FLAG_ERR');
           WSH_UTIL_CORE.add_message(l_return_status,l_module_name);
           x_return_status := l_return_status;

           IF l_debug_on THEN--{
              WSH_DEBUG_SV.logmsg(l_module_name,'Adjust_Planned_Flag_Err exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:Adjust_Planned_Flag_Err');
           END IF;--}

     WHEN others THEN
      wsh_util_core.default_handler('WSH_TRIPS_ACTIONS.AUTOCREATE_DEL_TRIP');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;


--
-- Debug Statements
--
IF l_debug_on THEN--{
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;--}
--
END autocreate_del_trip;

PROCEDURE assign_trip( p_line_rows IN wsh_util_core.id_tab_type,
               p_trip_id   IN NUMBER,
               x_del_rows  OUT NOCOPY  wsh_util_core.id_tab_type,
               x_return_status OUT NOCOPY  VARCHAR2) IS

l_grouping_rows wsh_util_core.id_tab_type;
l_del_legs wsh_util_core.id_tab_type;
l_org_rows wsh_util_core.id_tab_type;

l_return_status       VARCHAR2(1);
reprice_required_err EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ASSIGN_TRIP';
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
       WSH_DEBUG_SV.log(l_module_name,'P_TRIP_ID',P_TRIP_ID);
   END IF;
   --
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_AUTOCREATE.AUTOCREATE_DEL_ACROSS_ORGS',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   wsh_delivery_autocreate.autocreate_del_across_orgs(
                  p_line_rows => p_line_rows,
                  p_org_rows => l_org_rows,
                  p_container_flag => 'N',
                  p_check_flag => 'N',
                  p_max_detail_commit => 1000,
                  x_del_rows => x_del_rows,
                  x_grouping_rows => l_grouping_rows,
                  x_return_status => x_return_status);

   IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) OR
    (x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
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
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_LEGS_ACTIONS.ASSIGN_DELIVERIES',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   wsh_delivery_legs_actions.assign_deliveries(
               p_del_rows => x_del_rows,
               p_trip_id => p_trip_id,
               p_create_flag => 'Y',
               x_leg_rows => l_del_legs,
               x_return_status => x_return_status
               );

   IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) OR
      (x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
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
                   WSH_DEBUG_SV.pop(l_module_name);
               END IF;
               --
   EXCEPTION
     WHEN reprice_required_err THEN
         x_return_status := l_return_status;
         fnd_message.set_name('WSH', 'WSH_REPRICE_REQUIRED_ERR');
      wsh_util_core.add_message(x_return_status);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'REPRICE_REQUIRED_ERR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:REPRICE_REQUIRED_ERR');
      END IF;
      --
     WHEN others THEN
      wsh_util_core.default_handler('WSH_TRIPS_ACTIONS.ASSIGN_TRIP');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END assign_trip;


PROCEDURE check_assign_trip (
      p_del_rows      IN    wsh_util_core.id_tab_type,
      p_trip_id       IN    NUMBER,
      p_pickup_stop_id  IN NUMBER := NULL,
      p_dropoff_stop_id  IN      NUMBER := NULL,
      p_pickup_location_id  IN     NUMBER := NULL,
      p_dropoff_location_id    IN    NUMBER := NULL,
      p_pickup_arr_date    IN    DATE := to_date(NULL),
      p_pickup_dep_date    IN    DATE := to_date(NULL),
      p_dropoff_arr_date     IN     DATE := to_date(NULL),
      p_dropoff_dep_date     IN     DATE := to_date(NULL),
      x_return_status    OUT   VARCHAR2) IS

CURSOR pickup_leg_check (l_delivery_id IN NUMBER) IS
SELECT dg.delivery_leg_id,
     st.stop_id
FROM   wsh_trip_stops st,
      wsh_delivery_legs dg
WHERE  dg.delivery_id = l_delivery_id AND
      dg.pick_up_stop_id = st.stop_id AND
      st.stop_location_id = p_pickup_location_id;

CURSOR dropoff_leg_check (l_delivery_id IN NUMBER) IS
SELECT dg.delivery_leg_id,
     st.stop_id
FROM   wsh_trip_stops st,
      wsh_delivery_legs dg
WHERE  dg.delivery_id = l_delivery_id AND
      dg.drop_off_stop_id = st.stop_id AND
      st.stop_location_id = p_dropoff_location_id;

l_delivery_leg_id NUMBER;
l_stop_id       NUMBER;

num_warn      NUMBER := 0;
num_error       NUMBER := 0;
warn_flag       BOOLEAN;
error_flag     BOOLEAN;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_ASSIGN_TRIP';
--
-- patchset J csun Stop Sequence Change
l_stop_details_rec WSH_TRIP_STOPS_VALIDATIONS.stop_details;
l_return_status    VARCHAR2(1);

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
      WSH_DEBUG_SV.log(l_module_name,'P_TRIP_ID',P_TRIP_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_PICKUP_STOP_ID',P_PICKUP_STOP_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_DROPOFF_STOP_ID',P_DROPOFF_STOP_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_PICKUP_LOCATION_ID',P_PICKUP_LOCATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_DROPOFF_LOCATION_ID',P_DROPOFF_LOCATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_PICKUP_ARR_DATE',P_PICKUP_ARR_DATE);
      -- Pack J csun Stop Sequence Change
      WSH_DEBUG_SV.log(l_module_name,'P_PICKUP_DEP_DATE',P_PICKUP_DEP_DATE);
      WSH_DEBUG_SV.log(l_module_name,'P_DROPOFF_ARR_DATE',P_DROPOFF_ARR_DATE);
      WSH_DEBUG_SV.log(l_module_name,'P_DROPOFF_DEP_DATE',P_DROPOFF_DEP_DATE);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF (p_pickup_location_id = p_dropoff_location_id) THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_STOP_LOCATIONS_SAME');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   wsh_util_core.add_message(x_return_status);
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    RETURN;
  END IF;

-- Loop through all deliveries

  FOR i IN 1..p_del_rows.count LOOP

   warn_flag := FALSE;
   error_flag := FALSE;

   l_delivery_leg_id := NULL;
   l_stop_id := NULL;

   OPEN pickup_leg_check (p_del_rows(i));
   FETCH pickup_leg_check INTO l_delivery_leg_id, l_stop_id;
   CLOSE pickup_leg_check;

   IF (l_delivery_leg_id IS NOT NULL) THEN

      FND_MESSAGE.SET_NAME('WSH','WSH_DEL_MULTIPLE_LEGS');
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_del_rows(i)));
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
     wsh_util_core.add_message(x_return_status);
     warn_flag := TRUE;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_LEGS_PVT.DELETE_DELIVERY_LEG',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      wsh_delivery_legs_pvt.delete_delivery_leg(NULL, l_delivery_leg_id, x_return_status);

   END IF;

   l_delivery_leg_id := NULL;
   l_stop_id := NULL;

   OPEN dropoff_leg_check (p_del_rows(i));
   FETCH dropoff_leg_check INTO l_delivery_leg_id, l_stop_id;
   CLOSE dropoff_leg_check;

   IF (l_delivery_leg_id IS NOT NULL) THEN

      FND_MESSAGE.SET_NAME('WSH','WSH_DEL_MULTIPLE_LEGS');
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_del_rows(i)));
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
     wsh_util_core.add_message(x_return_status);
     warn_flag := TRUE;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_LEGS_PVT.DELETE_DELIVERY_LEG',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      wsh_delivery_legs_pvt.delete_delivery_leg(NULL, l_delivery_leg_id, x_return_status);

   END IF;

   -- Security rule check for assigning

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_VALIDATIONS.CHECK_ASSIGN_TRIP',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   wsh_delivery_validations.check_assign_trip(
      p_delivery_id => p_del_rows(i),
      p_trip_id => p_trip_id,
      p_pickup_stop_id => p_pickup_stop_id,
      p_dropoff_stop_id => p_dropoff_stop_id,
      x_return_status => x_return_status);

   IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
     IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
      num_warn := num_warn + 1;
      ELSE
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
       END IF;
       --
       RETURN;
      END IF;
   END IF;

   IF (error_flag) THEN
      num_error := num_error + 1;
   ELSIF (warn_flag) THEN
      num_warn := num_warn + 1;
   END IF;

  END LOOP;

  IF (num_warn > 0) OR (num_error > 0) THEN
   x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
  END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  EXCEPTION
     WHEN others THEN
      wsh_util_core.default_handler('WSH_TRIPS_ACTIONS.CHECK_ASSIGN_TRIP');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END check_assign_trip;

--
--  Procedure:   process_dels_for_internal_locs
--  Parameters:
--               p_del_rows                                   list of deliveries to be assigned
--               p_trip_id                                    trip to be assigned to
--               p_pickup_stop_id, p_dropoff_stop_id          Parameters for assign trip
--               p_pickup_location_id, p_dropoff_location_id  Parameters for assign trip
--               x_pickup_stop_id                             Modified (if any) pickup_stop_id
--               x_dropoff_stop_id                            Modified (if any) dropoff_stop_id
--               x_pickup_location_id                         Modified (if any) pickup_location_id
--               x_dropoff_location_id                        Modified (if any) dropoff_location_id
--               x_dropoff_seq_num                            Populated if needed for SSN mode
--               x_return_status                              return status
--
--  Description:
--               Should be called only when user tries to assign delivery to trip
--               Autocreate trip should not call this
--               Process deliveries and trip to be assigned for internal
--               locations changes and if need be convert the pickup
--               stop/location and the dropoff stop/location
--               PICKUP
--               If pickup stop is chosen from assign-trip window, check
--               whether it is a internal location and caller is TP release
--               or FTE.If so, and if there is no other dropoff or pickup
--               at this location, convert the location for this stop to
--               be the physical location . WSH caller should not be able to
--               use a dummy location for pickup. If there is a dropoff at
--               this location, create a new stop with the physical location
--               and use this for pickup
--               DROPOFF
--               If dropoff stop is chosen from assign-trip window, check whether delivery's
--               dropoff is a internal location and
--               if the physical location corresponding to the internal  loc (del's dropoff)
--               is same as the dropoff chosen from assign-trip window, and if there is no
--               other delivery getting dropoff or pickedup at the stop's location, convert the location for
--               this stop to be the dummy location . Else create new dropoff stop with dummy loc

PROCEDURE process_dels_for_internal_locs(
      p_del_rows             IN    wsh_util_core.id_tab_type,
      p_trip_id              IN    NUMBER,
      p_pickup_stop_id       IN    NUMBER := NULL,
      p_dropoff_stop_id      IN    NUMBER := NULL,
      p_pickup_location_id   IN    NUMBER := NULL,
      p_dropoff_location_id  IN    NUMBER := NULL,
      p_caller               IN    VARCHAR2,
      x_return_status        OUT NOCOPY VARCHAR2,
      x_pickup_stop_id       OUT NOCOPY NUMBER,
      x_dropoff_stop_id      OUT NOCOPY NUMBER,
      x_pickup_location_id   OUT NOCOPY NUMBER,
      x_dropoff_location_id  OUT NOCOPY NUMBER,
      x_dropoff_seq_num      IN OUT NOCOPY NUMBER,
      x_internal_del_ids     OUT NOCOPY wsh_util_core.id_tab_type,
      x_del_ids              OUT NOCOPY wsh_util_core.id_tab_type
)
IS
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'process_dels_for_internal_locs';
  --
  l_debug_on BOOLEAN;

CURSOR get_stop_location (l_trip_stop_id IN NUMBER) IS
SELECT  stop_location_id
FROM   wsh_trip_stops
WHERE stop_id = l_trip_stop_id;

CURSOR c_any_activity_exists(p_stop_id IN NUMBER) IS
SELECT '1'
FROM wsh_delivery_legs wdl
WHERE (wdl.pick_up_stop_id=p_stop_id OR wdl.drop_off_stop_id=p_stop_id)
AND rownum=1;

CURSOR c_get_stops IS
SELECT stop_id, stop_location_id, status_code
FROM wsh_trip_stops
WHERE trip_id=p_trip_id
ORDER BY stop_sequence_number;

CURSOR delivery_info (del_id IN NUMBER) IS
SELECT  initial_pickup_location_id,
ultimate_dropoff_location_id
FROM    wsh_new_deliveries
WHERE delivery_id = del_id;

CURSOR C_DEL_PHYS_DROPOFF (del_id IN NUMBER, loc_id IN NUMBER) IS
SELECT  'Y'
FROM    wsh_new_deliveries
WHERE delivery_id = del_id
AND ultimate_dropoff_location_id=loc_id;

l_phys_trip_pickup_loc_id   NUMBER;
l_trip_pickup_loc_id        NUMBER;
l_trip_dropoff_loc_id       NUMBER;
l_physical_stop_id          NUMBER;
l_find_stop                 NUMBER;
l_trip_ids                  wsh_util_core.id_tab_type;
l_dummy_trip_ids            wsh_util_core.id_tab_type;
l_getstops_stop_id          wsh_util_core.id_tab_type;
l_getstops_stop_loc_id      wsh_util_core.id_tab_type;
l_getstops_status_code      WSH_UTIL_CORE.Column_Tab_Type;
l_is_stop_pickup            VARCHAR2(1):='N';
l_is_stop_dropoff           VARCHAR2(1):='N';
l_find_leg                  VARCHAR2(1);
b_physical_loc_updated      BOOLEAN:=FALSE;
l_phys_del_pickup_loc_id    NUMBER;
l_phys_del_dropoff_loc_id   NUMBER;
l_del_rows_count            NUMBER:=0;
l_phys_trip_dropoff_loc_id  NUMBER;
l_stop_rec_physical_loc_id  NUMBER;
l_return_status             VARCHAR2(30);
l_pickup_location_id        NUMBER;
l_dropoff_location_id       NUMBER;
l_pickup_stop_id            NUMBER;
l_dropoff_stop_id           NUMBER;
l_num_error                 NUMBER := 0;
l_num_warn                  NUMBER := 0;
bad_trip_stop               EXCEPTION;
l_internal_del_id_count     NUMBER := 0;
l_del_id_count              NUMBER := 0;
l_internal_del_ids          wsh_util_core.id_tab_type;
l_del_ids                   wsh_util_core.id_tab_type;
b_checkstopupdate           BOOLEAN:=TRUE;
b_checkdels                 BOOLEAN:=FALSE;
b_gotstops                  BOOLEAN:=FALSE;
l_del_phys_dropoff          VARCHAR2(1);

   FUNCTION derive_next_ssn(p_trip_id IN NUMBER,
                            p_stop_id IN NUMBER) RETURN NUMBER IS
     CURSOR c_stop_seqs IS
         -- get the SSNs of this stop and the next stop.
         SELECT ts2.stop_sequence_number
         FROM   wsh_trip_stops ts1, -- get this stop's SSN
                wsh_trip_stops ts2  -- then look for SSN and next SSN
         WHERE  ts1.stop_id = p_stop_id
         AND    ts2.trip_id = p_trip_id
         AND    ts2.stop_sequence_number >= ts1.stop_sequence_number
         AND    rownum <= 2
         ORDER BY ts2.stop_sequence_number;
     l_ssn NUMBER;
   BEGIN
     IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name, 'entering internal function derive_next_ssn, p_stop_id ', p_stop_id);
     END IF;

     l_ssn := NULL;

     -- first item is the linking stop
     -- second item is the next row if it exists.
     FOR s IN c_stop_seqs LOOP
        IF l_ssn IS NULL THEN
            l_ssn := s.stop_sequence_number + 1;
        ELSE
            IF l_ssn > s.stop_sequence_number THEN
              -- to ensure uniqueness and correct sequence,
              -- let us take the average which may have decimal places.
              l_ssn := ( (l_ssn-1) + s.stop_sequence_number) / 2;
            END IF;
        END IF;
     END LOOP;

     IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name, 'exiting internal function derive_next_ssn, returning l_ssn', l_ssn);
     END IF;
     RETURN l_ssn;

   EXCEPTION
      WHEN OTHERS THEN
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'exiting internal function derive_next_ssn, unhandled exception');
          END IF;
          RETURN 0;
   END;

BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
     WSH_DEBUG_SV.push(l_module_name);
     WSH_DEBUG_SV.log(l_module_name, 'p_caller', p_caller);
     WSH_DEBUG_SV.log(l_module_name, 'p_pickup_stop_id', p_pickup_stop_id);
     WSH_DEBUG_SV.log(l_module_name, 'p_pickup_location_id', p_pickup_location_id);
     WSH_DEBUG_SV.log(l_module_name, 'p_dropoff_stop_id', p_dropoff_stop_id);
     WSH_DEBUG_SV.log(l_module_name, 'p_dropoff_location_id', p_dropoff_location_id);
  END IF;
  --
  --
  x_return_status        :=WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  x_pickup_stop_id       :=p_pickup_stop_id;
  x_dropoff_stop_id      :=p_dropoff_stop_id;
  x_pickup_location_id   :=p_pickup_location_id;
  x_dropoff_location_id  :=p_dropoff_location_id;

   --1. Process the trip data
   IF (p_pickup_stop_id IS NOT NULL) THEN
      OPEN get_stop_location (p_pickup_stop_id);
      FETCH get_stop_location INTO l_trip_pickup_loc_id;
      IF (get_stop_location%NOTFOUND) THEN
         RAISE bad_trip_stop;
      END IF;
      CLOSE get_stop_location;
   END IF;

   IF (p_dropoff_stop_id IS NOT NULL) THEN
      OPEN get_stop_location (p_dropoff_stop_id);
      FETCH get_stop_location INTO l_trip_dropoff_loc_id;
      IF (get_stop_location%NOTFOUND) THEN
         RAISE bad_trip_stop;
      END IF;
      CLOSE get_stop_location;
   END IF;

   IF p_pickup_location_id IS NOT NULL THEN
      l_trip_pickup_loc_id := p_pickup_location_id;
   END IF;
   IF p_dropoff_location_id IS NOT NULL THEN
      l_trip_dropoff_loc_id := p_dropoff_location_id;
   END IF;

   --get the physical locations
   IF (p_pickup_stop_id IS NOT NULL OR p_pickup_location_id IS NOT NULL) THEN
             WSH_LOCATIONS_PKG.Convert_internal_cust_location(
               p_internal_cust_location_id   => l_trip_pickup_loc_id,
               x_internal_org_location_id    => l_phys_trip_pickup_loc_id,
               x_return_status               => l_return_status);
         IF l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)  THEN
            x_return_status:=l_return_status;
            RETURN;
         END IF;
         IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_phys_trip_pickup_loc_id',l_phys_trip_pickup_loc_id);
         END IF;
   END IF;

   --b) only in ASSIGN-TRIP cases we need to check for internal locs
   --If pickup stop is chosen from assign-trip window, check whether it is a
   --internal location and caller is TP release or FTE.If so, and if there
   --is no other dropoff or pickup at this location, convert the location for
   --this stop to be the physical location . WSH caller should not be able to
   --use a dummy location for pickup
   IF (p_pickup_stop_id IS NOT NULL OR p_pickup_location_id IS NOT NULL)
      AND l_phys_trip_pickup_loc_id IS NOT NULL THEN --which means internal loc

            IF (nvl(p_caller,'@@@') like 'FTE%'
                OR nvl(p_caller,'@@@') like 'WSH_TP_RELEASE%'
               ) THEN

               IF p_pickup_stop_id IS NOT NULL THEN
                  l_physical_stop_id:=null;

                  --find if prev. or next stop matches physical loc.
                  OPEN c_get_stops;
                  FETCH c_get_stops BULK COLLECT INTO l_getstops_stop_id,
                                        l_getstops_stop_loc_id,
                                        l_getstops_status_code;
                  CLOSE c_get_stops;
                  b_gotstops:=TRUE;

                  IF l_getstops_stop_id IS NOT NULL AND l_getstops_stop_id.count > 0 THEN
                     FOR j in l_getstops_stop_id.first .. l_getstops_stop_id.last LOOP
                        IF p_pickup_stop_id=l_getstops_stop_id(j) THEN
                           IF j>l_getstops_stop_id.first AND l_phys_trip_pickup_loc_id=l_getstops_stop_loc_id(j-1)
                              AND l_getstops_status_code(j-1) IN ('OP','AR') THEN
                               l_physical_stop_id:=l_getstops_stop_id(j-1);
                               EXIT;
                           ELSIF j<l_getstops_stop_id.last AND l_phys_trip_pickup_loc_id=l_getstops_stop_loc_id(j+1)
                                 AND l_getstops_status_code(j+1) IN ('OP','AR') THEN
                               l_physical_stop_id:=l_getstops_stop_id(j+1);
                               EXIT;
                           END IF;
                        END IF;
                     END LOOP;
                  END IF;

                  IF l_physical_stop_id IS NOT NULL THEN
                     --if we find a stop with same physical location in the
                     --trip, we use that for pickup
                     IF l_debug_on THEN
                       WSH_DEBUG_SV.log(l_module_name,'Caller is FTE/TP using pickup stop l_physical_stop_id',l_physical_stop_id);
                     END IF;
                     x_pickup_stop_id:=l_physical_stop_id;
                  ELSE  --l_physical_stop_id IS NULL
                     --make pickup loc = l_phys_trip_pickup_loc_id if there
                     --is no dropoff or pickup at this dummy stop
                     OPEN c_any_activity_exists (p_pickup_stop_id);
                     FETCH c_any_activity_exists INTO l_find_leg;

                     IF c_any_activity_exists%NOTFOUND THEN
                        IF l_debug_on THEN
                           WSH_DEBUG_SV.logmsg(l_module_name,'Caller is FTE/TP changing pickup loc to be l_phys_trip_pickup_loc_id');
                        END IF;

                        UPDATE wsh_trip_stops
                        SET stop_location_id= l_phys_trip_pickup_loc_id,
                            physical_location_id=null,
                            last_update_date      = sysdate,
                            last_updated_by       = FND_GLOBAL.USER_ID
                        WHERE stop_id=p_pickup_stop_id;

                        --set the l_trip_pickup_loc_id to point to the new value
                        x_pickup_location_id:=l_phys_trip_pickup_loc_id;
                     ELSE
                        --there is a leg associated with internal stop and user is trying to use this for pickup as well.
                        --in this case we create new stop with l_phys_trip_pickup_loc_id
                        IF l_debug_on THEN
                           WSH_DEBUG_SV.logmsg(l_module_name,'Caller is FTE/TP changing pickup stop to create new pickup stop with l_phys_trip_pickup_loc_id');
                        END IF;
                        x_pickup_stop_id:=null;
                        x_pickup_location_id:=l_phys_trip_pickup_loc_id;
                     END IF;

                     CLOSE c_any_activity_exists;

                  END IF;--l_physical_stop_id IS NOT NULL

               ELSE --p_pickup_stop_id is null
                  --set l_pickup_location_id as the physical location so that this loc will be used to create stop
                  IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'Caller is FTE/TP create new pickup stop with l_phys_trip_pickup_loc_id');
                  END IF;
                  x_pickup_location_id:=l_phys_trip_pickup_loc_id;
               END IF;

            ELSE--caller is WSH
               x_return_status:=WSH_UTIL_CORE.G_RET_STS_ERROR;
               FND_MESSAGE.SET_NAME('WSH','WSH_CANNOT_USE_DUMMY_PICKUP');
               IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.get_location_description',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               FND_MESSAGE.SET_TOKEN('STOP_NAME',SUBSTR(WSH_UTIL_CORE.get_location_description(l_phys_trip_pickup_loc_id, 'NEW UI CODE'),1,60));
               wsh_util_core.add_message(x_return_status,l_module_name);
               IF l_debug_on THEN
              WSH_DEBUG_SV.pop(l_module_name);
               END IF;
               RETURN;
            END IF;
   END IF; --p_pickpu_stop_id is not null


  --2. Process the deliveries
   FOR i IN 1..p_del_rows.count LOOP

     IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name, 'p_del_rows(i)', p_del_rows(i));
     END IF;

      l_pickup_location_id := NULL;
      l_dropoff_location_id := NULL;

      -- Fetch delivery information including initial_pickup_location,
      -- ultimate_dropoff_location
      OPEN delivery_info (p_del_rows(i));
      FETCH delivery_info INTO l_pickup_location_id, l_dropoff_location_id;
      CLOSE delivery_info;

     --
     IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name, 'l_pickup_location_id', l_pickup_location_id);
        wsh_debug_sv.log(l_module_name, 'l_dropoff_location_id', l_dropoff_location_id);
     END IF;


    --Check if del's pickup and dropoff are same location

    l_phys_del_dropoff_loc_id:=null;

    WSH_LOCATIONS_PKG.Convert_internal_cust_location(
               p_internal_cust_location_id   => l_dropoff_location_id,
               x_internal_org_location_id    => l_phys_del_dropoff_loc_id,
               x_return_status               => l_return_status);

    IF l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)  THEN
            x_return_status:=l_return_status;
            RETURN;
    END IF;


-- J Locations - only in ASSIGN-TRIP cases we need to check for internal locs
-- If dropoff stop is chosen from assign-trip window, check whether delivery's
-- dropoff is a internal location and
-- if the physical location corresponding to the internal  loc (del's dropoff)
-- is same as the dropoff chosen from assign-trip window, and if there is no
-- other dropoff or pickup at the stop's location, convert the location for
-- this stop to be the dummy location .
   IF (p_dropoff_stop_id IS NOT NULL OR p_dropoff_location_id IS NOT NULL) THEN

         l_find_leg:=null;

         --physical loc of del corresponds to dropoff stop for trip chosen,
         --convert stop with l_trip_dropoff_loc_id as stop loc to be stop with l_dropoff_loc_id as
         --stop_loc if no other activity is taking place in stop
         --if for a set of deliveries, internal stop is identified and changed per logic below,
         --we do not need to repeat the steps again for later deliveries

         IF l_phys_del_dropoff_loc_id IS NOT NULL AND l_phys_del_dropoff_loc_id=l_trip_dropoff_loc_id THEN
                   IF l_debug_on THEN
                      WSH_DEBUG_SV.log(l_module_name,'l_phys_del_dropoff_loc_id',l_phys_del_dropoff_loc_id);
                   END IF;
                   l_find_stop:=null;
                   l_internal_del_id_count:=l_internal_del_id_count+1;
                   l_internal_del_ids(l_internal_del_id_count):=p_del_rows(i);
                   --find if prev. or next stop matches del's dropoff loc.
                   IF NOT(b_gotstops) THEN
                      OPEN c_get_stops;
                      FETCH c_get_stops BULK COLLECT INTO l_getstops_stop_id,
                                        l_getstops_stop_loc_id,
                                        l_getstops_status_code;
                      CLOSE c_get_stops;
                      b_gotstops:=TRUE;
                   END IF;

                   IF l_getstops_stop_id IS NOT NULL AND l_getstops_stop_id.count > 0 THEN
                     FOR j in l_getstops_stop_id.first .. l_getstops_stop_id.last LOOP
                        IF p_dropoff_stop_id=l_getstops_stop_id(j) OR p_dropoff_location_id=l_getstops_stop_loc_id(j) THEN
                           IF j>l_getstops_stop_id.first AND l_dropoff_location_id=l_getstops_stop_loc_id(j-1)
                              AND l_getstops_status_code(j-1) IN ('OP') THEN
                               l_find_stop:=l_getstops_stop_id(j-1);
                               EXIT;
                           ELSIF j<l_getstops_stop_id.last AND l_dropoff_location_id=l_getstops_stop_loc_id(j+1)
                                 AND l_getstops_status_code(j+1) IN ('OP') THEN
                               l_find_stop:=l_getstops_stop_id(j+1);
                               EXIT;
                           END IF;
                        END IF;
                     END LOOP;
                   END IF;


                   --see if you can find stop with del's dropoff loc
                   IF l_find_stop IS NOT NULL THEN
                      IF l_debug_on THEN
                         WSH_DEBUG_SV.log(l_module_name,'existing stop used as dropoff',l_find_stop);
                      END IF;
                      x_dropoff_stop_id:=l_find_stop;
                      --set the l_trip_dropoff_loc_id to point to the new value
                      x_dropoff_location_id:=l_dropoff_location_id;
                   ELSE
                      IF p_dropoff_stop_id IS NOT NULL THEN
                         OPEN c_any_activity_exists (p_dropoff_stop_id);
                         FETCH c_any_activity_exists INTO l_find_leg;
                         IF c_any_activity_exists%NOTFOUND THEN
                            --change location only if other dels do not have same physical dropoff
                            IF NOT(b_checkdels) THEN
                                FOR k IN 1..p_del_rows.count LOOP
                                   OPEN c_del_phys_dropoff(p_del_rows(k), l_trip_dropoff_loc_id);
                                   FETCH c_del_phys_dropoff INTO l_del_phys_dropoff;
                                   IF c_del_phys_dropoff%FOUND THEN
                                      b_checkstopupdate:=FALSE;
                                      CLOSE c_del_phys_dropoff;
                                      EXIT;
                                   END IF;
                                   CLOSE c_del_phys_dropoff;
                                END LOOP;
                                b_checkdels:=TRUE;
                            END IF;

                            IF NOT(b_checkstopupdate) THEN
                               IF l_debug_on THEN
                                  WSH_DEBUG_SV.log(l_module_name,'Have to create new internal stop as del with physical dropoff has been passed',l_dropoff_location_id);
                               END IF;

                               IF  WSH_TRIPS_ACTIONS.GET_STOP_SEQ_MODE = WSH_INTERFACE_GRP.G_STOP_SEQ_MODE_SSN THEN
                                  x_dropoff_seq_num := derive_next_ssn(p_trip_id, x_dropoff_stop_id);
                                  IF l_debug_on THEN
                                  WSH_DEBUG_SV.log(l_module_name,'x_dropoff_seq_num adjusted', x_dropoff_seq_num);
                                 END IF;
                               END IF; -- SSN mode

                               x_dropoff_stop_id:=null;
                               x_dropoff_location_id:=l_dropoff_location_id;
                            ELSE
                               IF l_debug_on THEN
                                  WSH_DEBUG_SV.log(l_module_name,'changing stop location to internal location l_dropoff_location_id',l_dropoff_location_id);
                               END IF;

                               UPDATE wsh_trip_stops
                               SET stop_location_id= l_dropoff_location_id,
                                   physical_location_id=l_trip_dropoff_loc_id,
                                   last_update_date      = sysdate,
                                   last_updated_by       = FND_GLOBAL.USER_ID
                               WHERE stop_id=p_dropoff_stop_id;

                               --set the l_trip_dropoff_loc_id to point to the new value
                               x_dropoff_location_id:=l_dropoff_location_id;
                            END IF;
                         ELSE
                            IF l_debug_on THEN
                               WSH_DEBUG_SV.log(l_module_name,'Have to create new internal stop as existing physical stop has activities',l_dropoff_location_id);
                            END IF;

                            IF  WSH_TRIPS_ACTIONS.GET_STOP_SEQ_MODE = WSH_INTERFACE_GRP.G_STOP_SEQ_MODE_SSN THEN
                              x_dropoff_seq_num := derive_next_ssn(p_trip_id, x_dropoff_stop_id);
                              IF l_debug_on THEN
                               WSH_DEBUG_SV.log(l_module_name,'x_dropoff_seq_num adjusted', x_dropoff_seq_num);
                              END IF;
                            END IF;

                            x_dropoff_stop_id:=null;
                            x_dropoff_location_id:=l_dropoff_location_id;
                         END IF;
                         CLOSE c_any_activity_exists;
                      ELSE--p_dropoff_location_id is not null
                            x_dropoff_stop_id:=null;
                            x_dropoff_location_id:=l_dropoff_location_id;
                      END IF;
                   END IF;--l_find_stop

         ELSE  --regular deliveries
                   l_del_id_count:=l_del_id_count+1;
                   l_del_ids(l_del_id_count):=p_del_rows(i);
         END IF;--l_phys_del_dropoff_loc_id is not null
    ELSE  --regular deliveries
        l_del_id_count:=l_del_id_count+1;
        l_del_ids(l_del_id_count):=p_del_rows(i);
    END IF;--p_dropoff_stop_id is not null
   END LOOP;

  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'x_del_ids count', l_del_id_count);
     WSH_DEBUG_SV.log(l_module_name, 'x_internal_del_ids count', l_internal_del_id_count);
  END IF;

 x_internal_del_ids:=l_internal_del_ids;
 x_del_ids:=l_del_ids;

  --
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
     WSH_DEBUG_SV.log(l_module_name, 'x_pickup_stop_id', x_pickup_stop_id);
     WSH_DEBUG_SV.log(l_module_name, 'x_pickup_location_id', x_pickup_location_id);
     WSH_DEBUG_SV.log(l_module_name, 'x_dropoff_stop_id', x_dropoff_stop_id);
     WSH_DEBUG_SV.log(l_module_name, 'x_dropoff_location_id', x_dropoff_location_id);
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

  EXCEPTION
    WHEN bad_trip_stop THEN
      IF get_stop_location%isopen THEN
        close get_stop_location;
      END IF;
      FND_MESSAGE.SET_NAME('WSH','WSH_STOP_NOT_FOUND');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      wsh_util_core.add_message(x_return_status);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'BAD_TRIP_STOP exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:BAD_TRIP_STOP');
      END IF;
      --
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.DEFAULT_HANDLER(
                        'WSH_TRIPS_ACTIONS.process_dels_for_internal_locs',
                        l_module_name);

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END process_dels_for_internal_locs;

PROCEDURE assign_trip(
      p_del_rows      IN    wsh_util_core.id_tab_type,
      p_trip_id       IN    NUMBER,
      p_pickup_stop_id  IN NUMBER := NULL,
      p_pickup_stop_seq IN NUMBER := NULL,
      p_dropoff_stop_id  IN      NUMBER := NULL,
      p_dropoff_stop_seq    IN      NUMBER := NULL,
      p_pickup_location_id  IN     NUMBER := NULL,
      p_dropoff_location_id    IN    NUMBER := NULL,
      p_pickup_arr_date    IN    DATE := to_date(NULL),
      p_pickup_dep_date    IN    DATE := to_date(NULL),
      p_dropoff_arr_date     IN     DATE := to_date(NULL),
      p_dropoff_dep_date     IN     DATE := to_date(NULL),
      x_return_status    OUT   VARCHAR2,
      p_caller        IN      VARCHAR2
      ) IS

CURSOR get_pickup_stop (l_loc_id IN NUMBER, l_del_id IN NUMBER) IS
SELECT st.stop_id
FROM   wsh_trip_stops st,
     wsh_delivery_legs dg
WHERE  st.stop_location_id = l_loc_id AND
     dg.pick_up_stop_id = st.stop_id AND
     dg.delivery_id = l_del_id;

CURSOR get_dropoff_stop (l_loc_id IN NUMBER, l_del_id IN NUMBER) IS
SELECT st.stop_id
FROM   wsh_trip_stops st,
     wsh_delivery_legs dg
WHERE  st.stop_location_id = l_loc_id AND
     dg.drop_off_stop_id = st.stop_id AND
     dg.delivery_id = l_del_id;

l_del_legs wsh_util_core.id_tab_type;
l_stop_id       NUMBER;
l_return_status   VARCHAR2(1);

stop_not_found EXCEPTION;
others EXCEPTION;
/* H integration  for Multi Leg */
  l_stop_rec   WSH_TRIP_STOPS_PVT.TRIP_STOP_REC_TYPE;
  l_pub_stop_rec  WSH_TRIP_STOPS_PUB.TRIP_STOP_PUB_REC_TYPE;
  l_trip_rec   WSH_TRIPS_PVT.TRIP_REC_TYPE;
  l_pub_trip_rec  WSH_TRIPS_PUB.TRIP_PUB_REC_TYPE;
  l_num_warn  NUMBER := 0;
  l_num_err   NUMBER := 0;
  --l_return_status VARCHAR2(30);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ASSIGN_TRIP';
--
-- patchset J csun Stop Sequence Change
l_stop_details_rec WSH_TRIP_STOPS_VALIDATIONS.stop_details;

  l_del_rows            wsh_util_core.id_tab_type;
  l_pickup_stop_id      NUMBER;
  l_dropoff_stop_id     NUMBER;
  l_pickup_location_id  NUMBER;
  l_dropoff_location_id NUMBER;
  l_pickup_stop_seq     NUMBER;
  l_dropoff_stop_seq    NUMBER;
  l_trip_ids           wsh_util_core.id_tab_type;
  l_dummy_trip_ids     wsh_util_core.id_tab_type;
  l_del_ids            wsh_util_core.id_tab_type;
  l_internal_del_ids   wsh_util_core.id_tab_type;

  l_stop_seq_mode         NUMBER; --SSN

  --WF: CMR
  l_del_old_carrier_ids WSH_UTIL_CORE.ID_TAB_TYPE;
  l_wf_rs VARCHAR2(1);

BEGIN
/* The  validations for stop sequence number are already done before calling this */
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
  l_stop_seq_mode := WSH_TRIPS_ACTIONS.GET_STOP_SEQ_MODE;

  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_TRIP_ID',P_TRIP_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_PICKUP_STOP_ID',P_PICKUP_STOP_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_PICKUP_STOP_SEQ',P_PICKUP_STOP_SEQ);
      WSH_DEBUG_SV.log(l_module_name,'P_DROPOFF_STOP_ID',P_DROPOFF_STOP_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_DROPOFF_STOP_SEQ',P_DROPOFF_STOP_SEQ);
      WSH_DEBUG_SV.log(l_module_name,'P_PICKUP_LOCATION_ID',P_PICKUP_LOCATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_DROPOFF_LOCATION_ID',P_DROPOFF_LOCATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_PICKUP_ARR_DATE',P_PICKUP_ARR_DATE);
      -- Pack J csun Stop Sequence Change
      WSH_DEBUG_SV.log(l_module_name,'P_PICKUP_DEP_DATE',P_PICKUP_DEP_DATE);
      WSH_DEBUG_SV.log(l_module_name,'P_DROPOFF_ARR_DATE',P_DROPOFF_ARR_DATE);
      WSH_DEBUG_SV.log(l_module_name,'P_DROPOFF_DEP_DATE',P_DROPOFF_DEP_DATE);
      WSH_DEBUG_SV.log(l_module_name,'STOP SEQUENCE MODE',l_stop_seq_mode);

  END IF;
  --
  IF (p_del_rows.count = 0) THEN
   raise others;
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  -- Pack J csun Stop Sequence Change
  -- This is the change to sequence trip stops by
  -- planned arrival date rather than stop sequence number.
  -- the checking above was commented out since it is not applicable any more.
  IF ((p_pickup_location_id IS NOT NULL
     AND (p_pickup_arr_date IS NOT NULL OR p_pickup_dep_date IS NOT NULL))
     AND (p_dropoff_location_id IS NOT NULL
     AND (p_dropoff_arr_date IS NOT NULL OR p_dropoff_dep_date IS NOT NULL))
     ) THEN

    -- bug 3516052
    -- bug 4036204: We relax the restriction so that p_pickup_dep_date = p_dropoff_arr_date
    -- as long as p_pickup_arr_date >= p_dropoff_arr_date
    -- SSN Change, add conditional check
    IF (l_stop_seq_mode = WSH_INTERFACE_GRP.G_STOP_SEQ_MODE_PAD) AND
       ((p_pickup_dep_date > p_dropoff_arr_date) OR
        ((p_pickup_dep_date = p_dropoff_arr_date) AND
         (p_pickup_arr_date >= p_dropoff_arr_date)
        )
       )THEN
      FND_MESSAGE.SET_NAME('WSH', 'WSH_INVALID_PLANNED_DATE');
      FND_MESSAGE.SET_TOKEN('PICKUP_DATE',  fnd_date.date_to_displaydt(p_pickup_dep_date));
      FND_MESSAGE.SET_TOKEN('DROPOFF_DATE', fnd_date.date_to_displaydt(p_dropoff_arr_date));
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      wsh_util_core.add_message(x_return_status);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
    END IF;
  END IF;

/* End of H integration  04/01/2002 */

  -- Action check for assigning

  check_assign_trip(
      p_del_rows      =>   p_del_rows,
      p_trip_id       =>   p_trip_id,
      p_pickup_stop_id   =>   p_pickup_stop_id,
      p_dropoff_stop_id  =>   p_dropoff_stop_id,
      p_pickup_location_id  =>   p_pickup_location_id,
      p_dropoff_location_id    =>   p_dropoff_location_id,
      p_pickup_arr_date    => p_pickup_arr_date,
      p_pickup_dep_date    => p_pickup_dep_date,
      p_dropoff_arr_date     =>  p_dropoff_arr_date,
      p_dropoff_dep_date     =>  p_dropoff_dep_date,
      x_return_status    =>   x_return_status);

  IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   RETURN;
  END IF;

  l_pickup_stop_id      :=p_pickup_stop_id;
  l_dropoff_stop_id     :=p_dropoff_stop_id;
  l_pickup_location_id  :=p_pickup_location_id;
  l_dropoff_location_id :=p_dropoff_location_id;
  l_pickup_stop_seq     :=p_pickup_stop_seq;
  l_dropoff_stop_seq    :=p_dropoff_stop_seq;

/*CURRENTLY NOT IN USE
  --WF: CMR
  WSH_WF_STD.Get_Carrier(p_del_ids => p_del_rows,
                         x_del_old_carrier_ids => l_del_old_carrier_ids,
                         x_return_status => l_wf_rs);
*/
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit process_dels_for_internal_locs',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    process_dels_for_internal_locs(
      p_del_rows             => p_del_rows,
      p_trip_id              => p_trip_id,
      p_pickup_stop_id       => p_pickup_stop_id,
      p_dropoff_stop_id      => p_dropoff_stop_id,
      p_pickup_location_id   => p_pickup_location_id,
      p_dropoff_location_id  => p_dropoff_location_id,
      p_caller               => p_caller,
      x_return_status        => x_return_status,
      x_pickup_stop_id       => l_pickup_stop_id,
      x_dropoff_stop_id      => l_dropoff_stop_id,
      x_pickup_location_id   => l_pickup_location_id,
      x_dropoff_location_id  => l_dropoff_location_id,
      x_dropoff_seq_num      => l_dropoff_stop_seq,
      x_del_ids              => l_del_ids,
      x_internal_del_ids     => l_internal_del_ids);

    IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'process_dels_for_internal_locs return_status',x_return_status);
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      RETURN;
    END IF;

    -- SSN Change, add conditional check
    IF (l_stop_seq_mode = WSH_INTERFACE_GRP.G_STOP_SEQ_MODE_PAD) AND
      -- Bug 4017507: If we are creating a new stop, we need to resequence.
      (l_pickup_stop_id IS NULL OR l_dropoff_stop_id IS NULL)
    THEN
      l_pickup_stop_seq := NULL;
      l_dropoff_stop_seq := NULL;
    END IF;
    -- end of SSN Change, add conditional check

    IF l_internal_del_ids IS NOT NULL and l_internal_del_ids.count>0 THEN
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_LEGS_ACTIONS.ASSIGN_DELIVERIES for internal deliveries',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       wsh_delivery_legs_actions.assign_deliveries(
          p_del_rows => l_internal_del_ids,
          p_trip_id => p_trip_id,
          p_pickup_stop_id => l_pickup_stop_id,
          p_pickup_stop_seq => l_pickup_stop_seq,
          p_dropoff_stop_id => l_dropoff_stop_id,
          p_dropoff_stop_seq => l_dropoff_stop_seq,
          p_pickup_location_id => l_pickup_location_id,
          p_dropoff_location_id => l_dropoff_location_id,
          p_create_flag => 'Y',
          x_leg_rows => l_del_legs,
          x_return_status => l_return_status,
          p_caller        => p_caller,
          p_pickup_arr_date   => p_pickup_arr_date,
          p_pickup_dep_date   => p_pickup_dep_date,
          p_dropoff_arr_date  => p_dropoff_arr_date,
          p_dropoff_dep_date  => p_dropoff_dep_date);

        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'wsh_delivery_legs_actions.assign_deliveries return_status',l_return_status);
        END IF;

       IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
          x_return_status := l_return_status;
          IF l_debug_on THEN
             WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          RETURN;
       ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
          x_return_status := l_return_status;
       END IF;
    END IF;


    IF l_del_ids IS NOT NULL and l_del_ids.count>0 THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_LEGS_ACTIONS.ASSIGN_DELIVERIES for regular deliveries',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      wsh_delivery_legs_actions.assign_deliveries(
        p_del_rows => l_del_ids,
        p_trip_id => p_trip_id,
        p_pickup_stop_id => l_pickup_stop_id,
        p_pickup_stop_seq => l_pickup_stop_seq,
        p_dropoff_stop_id => p_dropoff_stop_id,
        p_dropoff_stop_seq => l_dropoff_stop_seq,
        p_pickup_location_id => l_pickup_location_id,
        p_dropoff_location_id => p_dropoff_location_id,
        p_create_flag => 'Y',
        x_leg_rows => l_del_legs,
        x_return_status => l_return_status,
        p_caller        => p_caller,
        p_pickup_arr_date   => p_pickup_arr_date,
        p_pickup_dep_date   => p_pickup_dep_date,
        p_dropoff_arr_date  => p_dropoff_arr_date,
        p_dropoff_dep_date  => p_dropoff_dep_date);

        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'wsh_delivery_legs_actions.assign_deliveries return_status',l_return_status);
        END IF;

        IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
          x_return_status := l_return_status;
          IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          RETURN;
        ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
          x_return_status := l_return_status;
        END IF;
    END IF;

  -- Pack J csun Stop Sequence Change
  -- resequence trip stops in the trip
  -- trip stops are re-sequenced based on planned arrival date
  l_stop_details_rec.stop_id := NULL;
  l_stop_details_rec.trip_id := p_trip_id;

  -- SSN change
  -- Call Reset_Stop_Seq_Numbers only if mode = PAD
  IF l_stop_seq_mode = WSH_INTERFACE_GRP.G_STOP_SEQ_MODE_PAD THEN
    -- need to resequence the stops' SSNs and validate their dates.
    WSH_TRIP_STOPS_ACTIONS.RESET_STOP_SEQ_NUMBERS(
      p_stop_details_rec => l_stop_details_rec,
      x_return_status => l_return_status );

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'return status from WSH_TRIP_STOPS_ACTIONS.RESET_STOP_SEQ_NUMBERS',l_return_status);
    END IF;

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
        l_num_warn := l_num_warn + 1;
      ELSE
        x_return_status := l_return_status;
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        RETURN;
      END IF;
    END IF;

    -- SSN change, call to Validate_stop_dates is also made only when mode = PAD
    -- 3516052
    -- call validate_stop_dates after all the changes had been applied to
    -- database
    WSH_TRIP_VALIDATIONS.Validate_Stop_Dates (
      p_trip_id                => p_trip_id,
      x_return_status          => l_return_status,
      p_caller                 => p_caller
      );

    IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name,'Return Status From WSH_TRIP_STOPS_VALIDATIONS.Validate_Stop_Dates for trip '||p_trip_id ,l_return_status);
    END IF;

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
        l_num_warn := l_num_warn + 1;
      ELSE
        x_return_status := l_return_status;
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        RETURN;
      END IF;
    END IF;
  END IF; -- if mode = PAD

  -- end of Stop Sequence Change

  /*CURRENTLY NOT IN USE
  --WF: CMR
  WSH_WF_STD.Handle_Trip_Carriers(p_trip_id => p_trip_id,
			          p_del_ids => p_del_rows,
			          p_del_old_carrier_ids => l_del_old_carrier_ids,
			          x_return_status => l_wf_rs);
*/
  IF (l_num_warn > 0 AND x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
  END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  EXCEPTION
    WHEN stop_not_found THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_STOP_NOT_FOUND');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      wsh_util_core.add_message(x_return_status);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'STOP_NOT_FOUND exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:STOP_NOT_FOUND');
      END IF;
      --
     WHEN others THEN
      wsh_util_core.default_handler('WSH_TRIPS_ACTIONS.ASSIGN_TRIP');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END assign_trip;


-- J: W/V Changes

-- Start of comments
-- API name : calc_stop_fill_percent
-- Type     : Public
-- Pre-reqs : None.
-- Function : Calculates the fill% of stop with specified W/V info
-- Parameters :
-- IN:
--    p_stop_id      IN NUMBER Required
--    p_gross_weight IN  NUMBER
--      Gross Wt. of the stop
--    p_volume       IN  NUMBER
--      Volume of the stop
-- OUT:
--    x_stop_fill_percent OUT NUMBER
--       gives the calculated fill%
--    x_return_status OUT VARCHAR2 Required
--       give the return status of API
-- Version : 1.0
-- End of comments

PROCEDURE calc_stop_fill_percent(
            p_stop_id           IN  NUMBER,
            p_gross_weight      IN  NUMBER,
            p_volume            IN  NUMBER,
            x_stop_fill_percent OUT NOCOPY NUMBER,
            x_return_status     OUT NOCOPY  VARCHAR2) IS

CURSOR c_get_stop_trip(c_stop_id IN NUMBER) IS
SELECT trip_id,
       weight_uom_code,
       volume_uom_code
FROM   wsh_trip_stops
WHERE  stop_id = c_stop_id;

CURSOR trip_vehicle_info (c_trip_id NUMBER) IS
SELECT vehicle_item_id,
       vehicle_organization_id
FROM   wsh_trips
WHERE  trip_id = c_trip_id;

CURSOR trip_info (c_trip_id NUMBER) IS
SELECT msi.maximum_load_weight,
       msi.internal_volume,
       msi.minimum_fill_percent,
       msi.weight_uom_code,
       msi.volume_uom_code,
       msi.organization_id
FROM   mtl_system_items msi,
       wsh_trips t
WHERE  msi.organization_id = t.vehicle_organization_id AND
       t.vehicle_item_id = msi.inventory_item_id AND
       t.trip_id = c_trip_id;

CURSOR org_info (c_trip_id NUMBER) IS
SELECT wsp.percent_fill_basis_flag
FROM   wsh_shipping_parameters wsp,
       wsh_trips t
WHERE  wsp.organization_id  = t.vehicle_organization_id AND
       t.trip_id = c_trip_id;

l_trip_id         NUMBER;
l_stop_wt_uom     VARCHAR2(3);
l_stop_vol_uom    VARCHAR2(3);
l_vehicle_item_id NUMBER;
l_vehicle_org_id  NUMBER;
l_trip_max_weight NUMBER;
l_trip_max_volume NUMBER;
l_trip_min_fill   NUMBER;
l_trip_weight_uom VARCHAR2(3);
l_trip_volume_uom VARCHAR2(3);
l_trip_org_id     NUMBER;
l_fill_basis      VARCHAR2(1);
l_wt_vol_tmp      NUMBER;

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CALC_STOP_FILL_PERCENT';

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
       --
       WSH_DEBUG_SV.log(l_module_name,'P_STOP_ID',P_STOP_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_GROSS_WEIGHT',P_GROSS_WEIGHT);
       WSH_DEBUG_SV.log(l_module_name,'P_VOLUME',P_VOLUME);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   -- Return if stop is null or if W/V is null
   IF p_stop_id is NULL OR (p_gross_weight is NULL AND p_volume is NULL) THEN
     IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     return;
   END IF;

   -- Check if stop exists. Find the associated trip
   OPEN  c_get_stop_trip(p_stop_id);
   FETCH c_get_stop_trip INTO l_trip_id, l_stop_wt_uom, l_stop_vol_uom;
   IF c_get_stop_trip%NOTFOUND THEN
     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Stop '||p_stop_id||' not found');
       WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     CLOSE c_get_stop_trip;
     return;
   END IF;
   CLOSE c_get_stop_trip;

   -- Get the Vehicle Info for the trip
   OPEN  trip_vehicle_info (l_trip_id);
   FETCH trip_vehicle_info INTO l_vehicle_item_id, l_vehicle_org_id;
   CLOSE trip_vehicle_info;

   -- Get the W/V attributes of the vehicle item
   IF (l_vehicle_item_id IS NOT NULL) AND (l_vehicle_org_id IS NOT NULL) THEN
     OPEN  trip_info (l_trip_id);
     FETCH trip_info
     INTO  l_trip_max_weight,
           l_trip_max_volume,
           l_trip_min_fill,
           l_trip_weight_uom,
           l_trip_volume_uom,
           l_trip_org_id;
     IF (trip_info%NOTFOUND) THEN
       CLOSE trip_info;
       FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_NOT_FOUND');
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       wsh_util_core.add_message(x_return_status);
     END IF;
     CLOSE trip_info;
   END IF;

   -- Get the fill basis of vehicle org
   IF (l_vehicle_org_id IS NOT NULL) THEN

     OPEN org_info (l_trip_id);
     FETCH org_info INTO l_fill_basis;

     IF (org_info%NOTFOUND) THEN
       l_fill_basis := 'W';
     END IF;

     CLOSE org_info;
   END IF;

   IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'l_vehicle_item_id '||l_vehicle_item_id||' l_vehicle_org_id '||l_vehicle_org_id||' l_fill_basis '||l_fill_basis);
     WSH_DEBUG_SV.logmsg(l_module_name,'l_trip_max_weight '||l_trip_max_weight||' l_trip_weight_uom '||l_trip_weight_uom||' l_trip_max_volume '||l_trip_max_volume||' l_trip_volume_uom '||l_trip_volume_uom);
   END IF;


   -- Calculate the fill%
   IF (l_vehicle_item_id IS NOT NULL) AND (l_vehicle_org_id IS NOT NULL) THEN

     IF (l_fill_basis = 'W') AND (l_trip_max_weight IS NOT NULL) AND (l_trip_weight_uom IS NOT NULL) THEN
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       --
       l_wt_vol_tmp := wsh_wv_utils.convert_uom(l_trip_weight_uom, l_stop_wt_uom, l_trip_max_weight);
       IF (l_wt_vol_tmp > 0) THEN
          x_stop_fill_percent := round( 100 * p_gross_weight / l_wt_vol_tmp);
       END IF;
     ELSIF (l_fill_basis = 'V') AND (l_trip_max_volume IS NOT NULL) AND (l_trip_volume_uom IS NOT NULL) THEN

       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       --
       l_wt_vol_tmp := wsh_wv_utils.convert_uom(l_trip_volume_uom, l_stop_vol_uom, l_trip_max_volume);
       IF (l_wt_vol_tmp > 0) THEN
          x_stop_fill_percent := round( 100 * p_volume / l_wt_vol_tmp );
       END IF;
     ELSE
       x_stop_fill_percent := NULL;
     END IF;

   END IF;

   IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'x_stop_fill_percent '||x_stop_fill_percent||' x_return_status '||x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
   END IF;

EXCEPTION
  WHEN others THEN
    IF c_get_stop_trip%ISOPEN THEN
      CLOSE c_get_stop_trip;
    END IF;
    IF trip_vehicle_info%ISOPEN THEN
      CLOSE trip_vehicle_info;
    END IF;
    IF trip_info%ISOPEN THEN
      CLOSE trip_info;
    END IF;
    IF org_info%ISOPEN THEN
      CLOSE org_info;
    END IF;
    wsh_util_core.default_handler('WSH_TRIPS_ACTIONS.CALC_STOP_FILL_PERCENT');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END calc_stop_fill_percent;

PROCEDURE trip_weight_volume( p_trip_rows IN wsh_util_core.id_tab_type,
               p_override_flag IN VARCHAR2,
               p_calc_wv_if_frozen IN VARCHAR2,
               p_start_departure_date IN DATE,
               p_calc_del_wv IN      VARCHAR2,
               x_return_status OUT NOCOPY  VARCHAR2,
               p_suppress_errors IN VARCHAR2 DEFAULT NULL,
--tkt
               p_caller                IN      VARCHAR2) IS
CURSOR trip_stop_info (l_trip_id NUMBER) IS
SELECT stop_id,
     weight_uom_code,
     volume_uom_code,
     status_code,
     departure_gross_weight,
     departure_net_weight,
     departure_volume,
     nvl(shipments_type_flag,'O'),
     nvl(wv_frozen_flag,'Y')
FROM   wsh_trip_stops
WHERE  trip_id = l_trip_id AND
      nvl(planned_departure_date, nvl(p_start_departure_date, FND_API.G_MISS_DATE))  >= nvl(p_start_departure_date, FND_API.G_MISS_DATE)
ORDER BY stop_sequence_number;


CURSOR lock_stop(c_stop_id NUMBER) IS
SELECT stop_id
FROM   wsh_trip_stops
WHERE  stop_id = c_stop_id
FOR UPDATE NOWAIT;


CURSOR start_stop_info (l_trip_id NUMBER) IS
SELECT stop_id,
     departure_gross_weight,
     departure_net_weight,
     departure_volume,
     weight_uom_code,
     volume_uom_code
FROM   wsh_trip_stops
WHERE  trip_id = l_trip_id AND
      nvl(planned_departure_date, nvl(p_start_departure_date, FND_API.G_MISS_DATE))  <= nvl(p_start_departure_date, FND_API.G_MISS_DATE) AND
     rownum = 1
ORDER BY stop_sequence_number DESC;

CURSOR last_stop (l_trip_id NUMBER) IS
SELECT stop_id
FROM   wsh_trip_stops
WHERE  trip_id = l_trip_id
AND    stop_sequence_number = ( SELECT MAX(wts.stop_sequence_number)
                                FROM   wsh_trip_stops wts
                                WHERE  wts.trip_id = l_trip_id );

CURSOR pickup_deliveries (l_stop_id IN NUMBER) IS
SELECT dl.delivery_id d_id,
     dl.weight_uom_code wt_uom,
     dl.volume_uom_code vol_uom,
     dl.gross_weight,
     dl.net_weight,
     dl.volume,
        dl.organization_id
FROM   wsh_trip_stops t,
     wsh_delivery_legs dg,
     wsh_new_deliveries dl
WHERE  t.stop_id = l_stop_id AND
     dg.pick_up_stop_id = t.stop_id AND
     dl.delivery_id = dg.delivery_id AND
     dg.parent_delivery_leg_id is NULL;

CURSOR dropoff_deliveries (l_stop_id NUMBER) IS
SELECT dl.delivery_id d_id,
       dl.organization_id
FROM   wsh_trip_stops t,
     wsh_delivery_legs dg,
     wsh_new_deliveries dl
WHERE  t.stop_id = l_stop_id AND
     dg.drop_off_stop_id = t.stop_id AND
     dl.delivery_id = dg.delivery_id AND
     dg.parent_delivery_leg_id is NULL;

CURSOR trip_info (l_trip_id NUMBER) IS
SELECT msi.maximum_load_weight,
     msi.internal_volume,
     msi.minimum_fill_percent,
     msi.weight_uom_code,
     msi.volume_uom_code,
     msi.organization_id
FROM   mtl_system_items msi,
     wsh_trips t
WHERE  msi.organization_id = t.vehicle_organization_id AND
     t.vehicle_item_id = msi.inventory_item_id AND
     t.trip_id = l_trip_id;

CURSOR org_info (l_trip_id NUMBER) IS
SELECT wsp.percent_fill_basis_flag
FROM   wsh_shipping_parameters wsp,
     wsh_trips t
WHERE  wsp.organization_id  = t.vehicle_organization_id AND
     t.trip_id = l_trip_id;

CURSOR trip_vehicle_info (l_trip_id NUMBER) IS
SELECT vehicle_item_id,
     vehicle_organization_id
FROM   wsh_trips
WHERE  trip_id = l_trip_id;


l_net_weight   NUMBER;
l_gross_weight NUMBER;
l_volume    NUMBER;
l_wt_vol_flag  VARCHAR2(1);
l_organization NUMBER;

l_total_net_weight NUMBER := 0;
l_total_gross_weight NUMBER := 0;
l_total_volume NUMBER := 0;

l_stop_id  NUMBER;
l_stop_wt_uom VARCHAR2(3);
l_stop_vol_uom VARCHAR2(3);
l_stop_fill_percent NUMBER;

l_last_stop_id  NUMBER;

l_start_stop_id NUMBER;
l_prev_wt_uom VARCHAR2(3);
l_prev_vol_uom VARCHAR2(3);

l_stop_status VARCHAR2(3);
l_tmp_dep_gross_wt NUMBER;
l_tmp_dep_net_wt NUMBER;
l_tmp_dep_vol NUMBER;
l_shipment_type_flag VARCHAR2(1);
l_wv_frozen_flag VARCHAR2(1);

l_trip_max_weight   NUMBER;
l_trip_max_volume   NUMBER;
l_trip_min_fill    NUMBER;
l_trip_weight_uom   VARCHAR2(3);
l_trip_volume_uom   VARCHAR2(3);
l_trip_org_id     NUMBER;

l_fill_basis      VARCHAR2(1);
l_org_name     VARCHAR2(60);
l_wt_vol_tmp      NUMBER;

l_vehicle_item_id   NUMBER;
l_vehicle_org_id  NUMBER;
l_num_error     NUMBER := 0;
l_num_warn       NUMBER := 0;
l_trip_num_warn       NUMBER := 0;
l_stop_num_warn       NUMBER := 0;

l_return_status    VARCHAR2(1);
g_return_status    VARCHAR2(1);
l_locked_stop_id   NUMBER := 0;
others EXCEPTION;
/* H integration  for Multi Leg */
  l_pub_stop_rec  WSH_TRIP_STOPS_PUB.TRIP_STOP_PUB_REC_TYPE;
  l_pub_trip_rec  WSH_TRIPS_PUB.TRIP_PUB_REC_TYPE;

--R12 MDC
l_total_pick_up_weight NUMBER := 0;
l_total_drop_off_weight NUMBER := 0;
l_total_pick_up_volume NUMBER := 0;
l_total_drop_off_volume NUMBER := 0;

TYPE Del_WV_Tab_Type IS TABLE OF pickup_deliveries%ROWTYPE INDEX BY BINARY_INTEGER;
pickup_del_tab     Del_WV_Tab_Type;

--Bug 9308056
l_pkup_dl_id_mod NUMBER;
l_dpoff_dl_id_mod NUMBER;

                                                  --
l_debug_on BOOLEAN;
                                                  --
                                                  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'TRIP_WEIGHT_VOLUME';
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
       WSH_DEBUG_SV.log(l_module_name,'P_OVERRIDE_FLAG',P_OVERRIDE_FLAG);
       WSH_DEBUG_SV.log(l_module_name,'P_CALC_WV_IF_FROZEN',P_CALC_WV_IF_FROZEN);
       WSH_DEBUG_SV.log(l_module_name,'P_START_DEPARTURE_DATE',P_START_DEPARTURE_DATE);
       WSH_DEBUG_SV.log(l_module_name,'P_CALC_DEL_WV',P_CALC_DEL_WV);
       WSH_DEBUG_SV.log(l_module_name,'P_SUPPRESS_ERRORS',P_SUPPRESS_ERRORS);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   IF (p_trip_rows.count = 0) THEN
      raise others;
   END IF;
   FOR i IN 1..p_trip_rows.count LOOP
     /*
     l_num_warn is used to calculate the no. of warnings in all trips, successful trips etc.
so use l_trip_num_warn to update for warnings and then if l_trip_num_warn is >1 at loop end,
increase l_num_warn by 1. In some cases, l_num_warn is directly updated and since it is directly
redirected to end of loop, those are okay.
     */
     l_trip_num_warn:=0;
     OPEN trip_vehicle_info (p_trip_rows(i));
     FETCH trip_vehicle_info INTO l_vehicle_item_id, l_vehicle_org_id;
     CLOSE trip_vehicle_info;
     pickup_del_tab.delete;

     --only open trip info if vehicle info found
     IF (l_vehicle_item_id IS NOT NULL) AND (l_vehicle_org_id IS NOT NULL) THEN
        OPEN trip_info (p_trip_rows(i));
        FETCH trip_info INTO l_trip_max_weight, l_trip_max_volume, l_trip_min_fill, l_trip_weight_uom, l_trip_volume_uom, l_trip_org_id;
        IF (trip_info%NOTFOUND) THEN
           CLOSE trip_info;
           FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_NOT_FOUND');
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           wsh_util_core.add_message(x_return_status);
           goto wt_vol_error;
        END IF;
        CLOSE trip_info;
     END IF;


     --only open trip info if vehicle info found
     IF (l_vehicle_org_id IS NOT NULL) THEN

        OPEN org_info (p_trip_rows(i));
        FETCH org_info INTO l_fill_basis;

        IF (org_info%NOTFOUND) THEN
           --Start of Bug 2415809
           FND_MESSAGE.SET_NAME('WSH','WSH_VEHICLE_ORG_FILLBASIS_NULL');
           --
           -- Debug Statements
           --
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_ORG_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           --
           FND_MESSAGE.SET_TOKEN('l_vehicle_org', WSH_UTIL_CORE.Get_Org_Name(l_vehicle_org_id));
           --End of Bug 2415809
           x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
           wsh_util_core.add_message(x_return_status);
           l_trip_num_warn:=l_trip_num_warn+1;
           l_fill_basis := 'W';
        END IF;

        CLOSE org_info;
     END IF;

     OPEN trip_stop_info (p_trip_rows(i));
     FETCH trip_stop_info INTO l_stop_id, l_stop_wt_uom, l_stop_vol_uom, l_stop_status, l_tmp_dep_gross_wt, l_tmp_dep_net_wt, l_tmp_dep_vol, l_shipment_type_flag, l_wv_frozen_flag;

     IF (trip_stop_info%NOTFOUND) THEN
        CLOSE trip_stop_info;
        -- start bug 2366163: go to next trip without error if caller does not need w/v.
        IF p_suppress_errors = 'Y' THEN
           goto loop_end;
        END IF;
        -- end bug 2366163
        FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_NO_STOPS');
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        FND_MESSAGE.SET_TOKEN('TRIP_NAME',wsh_trips_pvt.get_name(p_trip_rows(i)));
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        wsh_util_core.add_message(x_return_status);
        goto wt_vol_error;
     END IF;

     OPEN last_stop(p_trip_rows(i));
     FETCH last_stop INTO l_last_stop_id;
     IF last_stop%NOTFOUND THEN
        CLOSE last_stop;
        CLOSE trip_stop_info;
        -- start bug 2366163: go to next trip without error if caller does not need w/v.
        IF p_suppress_errors = 'Y' THEN
           goto loop_end;
        END IF;
        -- end bug 2366163
        FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_NO_STOPS');
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        FND_MESSAGE.SET_TOKEN('TRIP_NAME',wsh_trips_pvt.get_name(p_trip_rows(i)));
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        wsh_util_core.add_message(x_return_status);
        goto wt_vol_error;
     END IF;
     CLOSE last_stop;

     OPEN start_stop_info (p_trip_rows(i));
     FETCH start_stop_info INTO l_start_stop_id,
                     l_gross_weight,
                     l_net_weight,
                     l_volume,
                     l_prev_wt_uom,
                     l_prev_vol_uom;

     IF (start_stop_info%FOUND) THEN
        IF (l_prev_wt_uom IS NULL) OR (l_prev_vol_uom IS NULL) THEN
           CLOSE start_stop_info;
           -- start bug 2366163: go to next trip without error if caller does not need w/v.
           IF (p_suppress_errors = 'Y')THEN
             goto wt_vol_error;
           END IF;
           -- end bug 2366163
-- bug 2732503 , need a message only when FTE is installed
-- else continue
           IF (wsh_util_core.fte_is_installed <> 'Y') THEN
             goto loop_end;
           END IF;

           FND_MESSAGE.SET_NAME('WSH','WSH_STOP_UOM_NULL');
           --
           -- Debug Statements
           --
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           --
           FND_MESSAGE.SET_TOKEN('stop_name',wsh_trip_stops_pvt.get_name(l_start_stop_id,p_caller));
-- bug 2732503 , need a warning message only when FTE is installed
-- still will go to wt_vol_error
           x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
           wsh_util_core.add_message(x_return_status);
           l_num_warn := l_num_warn + 1;
           goto loop_end;
        END IF;
     END IF;

     CLOSE start_stop_info;
      /***********LOOP for stop start****************/
     l_stop_num_warn:=0;
     --increment l_stop_num_warn for this stop loop so that for each trip, l_num_warn will get updated max by 1
     LOOP

       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'*** Processing Stop '||l_stop_id||' ***');
       END IF;

       l_total_pick_up_weight := 0;
       l_total_drop_off_weight := 0;
       l_total_pick_up_volume  := 0;
       l_total_drop_off_volume := 0;



       IF (p_calc_wv_if_frozen = 'N' and l_wv_frozen_flag = 'Y') THEN

         l_total_gross_weight := l_total_gross_weight + l_tmp_dep_gross_wt;
         l_total_net_weight := l_total_net_weight + l_tmp_dep_net_wt;
         l_total_volume := l_total_volume + l_tmp_dep_vol;
         l_prev_wt_uom := l_stop_wt_uom;
         l_prev_vol_uom := l_stop_vol_uom;

         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Accumulated W/V after conversions are Gross '||l_total_gross_weight||' Net '||l_total_net_weight||' Vol '||l_total_volume);
           WSH_DEBUG_SV.logmsg(l_module_name,'WV Frozen '||l_wv_frozen_flag||'. Skipping the Stop W/V calculation.');
         END IF;
         --R12 MDC
         --Removing the goto statement because code needs to update the new pick_up/drop_off weight/volume columns even if frozen flag is Y
         -- Code has been added before the update statement to check the frozen flag
         -- Update existing wt/vol columns only if frozen_flag = N
         -- Update new wt/vol columns irrespective of frozen flag being Y or N.
         -- goto continue_next;

       END IF;

        IF (l_stop_wt_uom IS NULL) OR (l_stop_vol_uom IS NULL) THEN
           -- start bug 2366163: go to next trip without error if caller does not need w/v.
           IF (p_suppress_errors = 'Y')THEN
              goto loop_end;
           END IF;
           -- end bug 2366163
-- bug 2732503 , need a message only when FTE is installed
-- this will skip calculating wt/vol for all the stops
-- else continue
           IF (wsh_util_core.fte_is_installed <> 'Y') THEN
             goto loop_end;
           END IF;

           FND_MESSAGE.SET_NAME('WSH','WSH_STOP_UOM_NULL');
           --
           -- Debug Statements
           --
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           --
           FND_MESSAGE.SET_TOKEN('stop_name',wsh_trip_stops_pvt.get_name(l_stop_id,p_caller));
-- bug 2732503 , need a warning message only when FTE is installed
-- still will go to wt_vol_error
           x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
           wsh_util_core.add_message(x_return_status);
           l_stop_num_warn := l_stop_num_warn + 1;
           goto continue_next;
        END IF;

         --check if  stop status is closed, and weight, volume are not null
         --if NOT so, proceed
         -- ELSE proceeed to end of loop,  go to the next stop.
        IF NOT(l_stop_status='CL' AND l_shipment_type_flag = 'O') THEN

           --
           -- Debug Statements
           --
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           --
           l_total_net_weight := wsh_wv_utils.convert_uom(l_prev_wt_uom, l_stop_wt_uom, l_total_net_weight);
           --
           -- Debug Statements
           --
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           --
           l_total_gross_weight := wsh_wv_utils.convert_uom(l_prev_wt_uom, l_stop_wt_uom, l_total_gross_weight);
           --
           -- Debug Statements
           --
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           --
           l_volume := wsh_wv_utils.convert_uom(l_prev_vol_uom, l_stop_vol_uom, l_total_volume);

           g_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Processing Pickup Deliveries ...');
            END IF;

            FOR pkup_dl IN pickup_deliveries (l_stop_id) LOOP

                  IF p_calc_del_wv = 'Y' THEN --{
                  --
                  -- Debug Statements
                  --
                  IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.DELIVERY_WEIGHT_VOLUME',WSH_DEBUG_SV.C_PROC_LEVEL);
                  END IF;
                  --
                  wsh_wv_utils.delivery_weight_volume(
                    p_delivery_id       => pkup_dl.d_id,
                    p_update_flag       => 'Y',
                    p_calc_wv_if_frozen => p_calc_wv_if_frozen,
                    x_gross_weight      => l_gross_weight,
                    x_net_weight        => l_net_weight,
                    x_volume            => l_volume,
                    x_return_status     => l_return_status);

                  IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
                  OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                     FND_MESSAGE.SET_NAME('WSH','WSH_DEL_WT_VOL_FAILED');
                     --
                     -- Debug Statements
                     --
                     IF l_debug_on THEN
                         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
                     END IF;
                     --
                     FND_MESSAGE.SET_TOKEN('del_name',wsh_new_deliveries_pvt.get_name(pkup_dl.d_id));
                     g_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
                     wsh_util_core.add_message(g_return_status);
                  END IF;


                  ELSE

                  l_gross_weight    := pkup_dl.gross_weight;
                  l_net_weight      := pkup_dl.net_weight;
                  l_volume          := pkup_dl.volume;

                  END IF; --}

	       --Bug 9308056    replaced  pkup_dl.d_id  with l_pkup_dl_id_mod  ,  WSH_UTIL_CORE.C_INDEX_LIMIT value is 2147483648; -- power(2,31)
               l_pkup_dl_id_mod := MOD(pkup_dl.d_id,WSH_UTIL_CORE.C_INDEX_LIMIT) ;

               pickup_del_tab(l_pkup_dl_id_mod).d_id            := pkup_dl.d_id;
               pickup_del_tab(l_pkup_dl_id_mod).wt_uom          := pkup_dl.wt_uom;
               pickup_del_tab(l_pkup_dl_id_mod).vol_uom         := pkup_dl.vol_uom;
               pickup_del_tab(l_pkup_dl_id_mod).gross_weight    := l_gross_weight;
               pickup_del_tab(l_pkup_dl_id_mod).net_weight      := l_net_weight;
               pickup_del_tab(l_pkup_dl_id_mod).volume          := l_volume;
               pickup_del_tab(l_pkup_dl_id_mod).organization_id := pkup_dl.organization_id;

-- J: W/V Changes
               IF l_net_weight >= 0 THEN
                 IF pkup_dl.wt_uom <> l_stop_wt_uom THEN
                   IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
                   END IF;
                   --
                   IF l_net_weight > 0
                   THEN
                    l_total_net_weight := l_total_net_weight + wsh_wv_utils.convert_uom(pkup_dl.wt_uom, l_stop_wt_uom, l_net_weight);
                   ELSE
                    l_total_net_weight := l_total_net_weight + l_net_weight;
                   END IF;
                 ELSE
                   l_total_net_weight := l_total_net_weight + l_net_weight;
                 END IF;
               END IF;

               IF l_gross_weight >= 0 THEN
                 IF pkup_dl.wt_uom <> l_stop_wt_uom THEN
                   IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
                   END IF;
                   --
                   IF l_gross_weight > 0
                   THEN
                    l_total_gross_weight := l_total_gross_weight + wsh_wv_utils.convert_uom(pkup_dl.wt_uom, l_stop_wt_uom, l_gross_weight);
                    --R12 MDC
                    l_total_pick_up_weight := l_total_pick_up_weight + wsh_wv_utils.convert_uom(pkup_dl.wt_uom, l_stop_wt_uom, l_gross_weight);
                   ELSE
                    l_total_gross_weight := l_total_gross_weight + l_gross_weight;
                    --R12 MDC
                    l_total_pick_up_weight := l_total_pick_up_weight + l_gross_weight;
                   END IF;
                 ELSE
                   l_total_gross_weight := l_total_gross_weight + l_gross_weight;
                   --R12 MDC
                   l_total_pick_up_weight := l_total_pick_up_weight + l_gross_weight;
                 END IF;
               END IF;

               IF l_volume >= 0 THEN
                 IF pkup_dl.vol_uom <> l_stop_vol_uom THEN
                   IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
                   END IF;
                   --
                   IF l_volume > 0
                   THEN
                    l_total_volume := l_total_volume + wsh_wv_utils.convert_uom(pkup_dl.vol_uom, l_stop_vol_uom, l_volume);
                    --R12 MDC
                    l_total_pick_up_volume := l_total_pick_up_volume + wsh_wv_utils.convert_uom(pkup_dl.vol_uom, l_stop_vol_uom, l_volume);
                   ELSE
                    l_total_volume := l_total_volume + l_volume;
                    --R12 MDC
                    l_total_pick_up_volume := l_total_pick_up_volume + l_volume;
                   END IF;
                 ELSE
                   l_total_volume := l_total_volume + l_volume;
                   --R12 MDC
                   l_total_pick_up_volume := l_total_pick_up_volume + l_volume;
                 END IF;
               END IF;

               IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Accumulated W/V after conversions are Gross '||l_total_gross_weight||' Net '||l_total_net_weight||' Vol '||l_total_volume);
               END IF;


            END LOOP;

            IF (g_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
              x_return_status := g_return_status;
              l_stop_num_warn := l_stop_num_warn + 1;
            END IF;

            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'After Pickup LOOP, Gross '||l_total_gross_weight||' Net '||l_total_net_weight||' Vol '||l_total_volume);
              WSH_DEBUG_SV.logmsg(l_module_name,'Processing Dropoff Deliveries ...');
            END IF;


            FOR dpoff_dl IN dropoff_deliveries (l_stop_id) LOOP
               --Bug 9308056  replaced dpoff_dl.d_id with l_dpoff_dl_id_mod ,  WSH_UTIL_CORE.C_INDEX_LIMIT value is 2147483648; -- power(2,31)
               l_dpoff_dl_id_mod := MOD(dpoff_dl.d_id,WSH_UTIL_CORE.C_INDEX_LIMIT) ;
               IF pickup_del_tab.EXISTS(l_dpoff_dl_id_mod) THEN
                  IF pickup_del_tab(l_dpoff_dl_id_mod).d_id = dpoff_dl.d_id THEN
                    IF l_stop_id <> l_last_stop_id THEN
-- J: W/V Changes
                       IF pickup_del_tab(l_dpoff_dl_id_mod).net_weight > 0 THEN
                         IF pickup_del_tab(l_dpoff_dl_id_mod).wt_uom <> l_stop_wt_uom THEN
                           IF l_debug_on THEN
                             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
                           END IF;
                           --
                           l_total_net_weight := l_total_net_weight - wsh_wv_utils.convert_uom(pickup_del_tab(l_dpoff_dl_id_mod).wt_uom, l_stop_wt_uom , pickup_del_tab(l_dpoff_dl_id_mod).net_weight);
                         ELSE
                           l_total_net_weight := l_total_net_weight - pickup_del_tab(l_dpoff_dl_id_mod).net_weight;
                         END IF;
                       END IF;
                    END IF;

                    IF pickup_del_tab(l_dpoff_dl_id_mod).gross_weight > 0 THEN
                       IF pickup_del_tab(l_dpoff_dl_id_mod).wt_uom <> l_stop_wt_uom THEN
                          IF l_debug_on THEN
                             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
                          END IF;
                          --
                          IF l_stop_id <> l_last_stop_id THEN
                           l_total_gross_weight := l_total_gross_weight - wsh_wv_utils.convert_uom(pickup_del_tab(l_dpoff_dl_id_mod).wt_uom, l_stop_wt_uom, pickup_del_tab(l_dpoff_dl_id_mod).gross_weight);
                          END IF;
                          --R12 MDC
                          l_total_drop_off_weight := l_total_drop_off_weight + wsh_wv_utils.convert_uom(pickup_del_tab(l_dpoff_dl_id_mod).wt_uom, l_stop_wt_uom, pickup_del_tab(l_dpoff_dl_id_mod).gross_weight);
                       ELSE
                          IF l_stop_id <> l_last_stop_id THEN
                            l_total_gross_weight := l_total_gross_weight - pickup_del_tab(l_dpoff_dl_id_mod).gross_weight;
                          END IF;
                            --R12 MDC
                            l_total_drop_off_weight := l_total_drop_off_weight + pickup_del_tab(l_dpoff_dl_id_mod).gross_weight;
                         END IF;
                       END IF;

                    IF pickup_del_tab(l_dpoff_dl_id_mod).volume > 0 THEN
                       IF pickup_del_tab(l_dpoff_dl_id_mod).vol_uom <> l_stop_vol_uom THEN
                          IF l_debug_on THEN
                             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
                          END IF;
                           --
                          IF l_stop_id <> l_last_stop_id THEN
                            l_total_volume := l_total_volume - wsh_wv_utils.convert_uom(pickup_del_tab(l_dpoff_dl_id_mod).vol_uom, l_stop_vol_uom, pickup_del_tab(l_dpoff_dl_id_mod).volume);
                          END IF;
                          --R12 MDC
                          l_total_drop_off_volume := l_total_drop_off_volume + wsh_wv_utils.convert_uom(pickup_del_tab(l_dpoff_dl_id_mod).vol_uom, l_stop_vol_uom, pickup_del_tab(l_dpoff_dl_id_mod).volume);
                       ELSE
                          IF l_stop_id <> l_last_stop_id THEN
                             l_total_volume := l_total_volume - pickup_del_tab(l_dpoff_dl_id_mod).volume;
                          END IF;
                          --R12 MDC
                          l_total_drop_off_volume := l_total_drop_off_volume + pickup_del_tab(l_dpoff_dl_id_mod).volume;
                       END IF;
                     END IF;

                     IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Accumulated W/V after conversions are Gross '||l_total_gross_weight||' Net '||l_total_net_weight||' Vol '||l_total_volume);
                     END IF;

                  END IF;
               END IF;
            END LOOP;

            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'After Dropoff, LOOP, Gross '||l_total_gross_weight||' Net '||l_total_net_weight||' Vol '||l_total_volume);
            END IF;

            IF l_stop_id <> l_last_stop_id THEN
              -- Calculate fill_percent of stop
              --only if vehicle info found, calc. fill percent
              IF (l_vehicle_item_id IS NOT NULL) AND (l_vehicle_org_id IS NOT NULL) THEN
                 IF (l_fill_basis = 'W') AND (l_trip_max_weight IS NOT NULL) AND (l_trip_weight_uom IS NOT NULL) THEN
                    --
                    -- Debug Statements
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    l_wt_vol_tmp := wsh_wv_utils.convert_uom(l_trip_weight_uom, l_stop_wt_uom, l_trip_max_weight);
                    IF (l_wt_vol_tmp > 0) THEN
                       l_stop_fill_percent := round( 100 * l_total_gross_weight / l_wt_vol_tmp);
                    END IF;
                 ELSIF (l_fill_basis = 'V') AND (l_trip_max_volume IS NOT NULL) AND (l_trip_volume_uom IS NOT NULL) THEN

                    --
                    -- Debug Statements
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    l_wt_vol_tmp := wsh_wv_utils.convert_uom(l_trip_volume_uom, l_stop_vol_uom, l_trip_max_volume);
                    IF (l_wt_vol_tmp > 0) THEN
                       l_stop_fill_percent := round( 100 * l_total_volume / l_wt_vol_tmp );
                    END IF;
                 ELSE
                    l_stop_fill_percent := NULL;
                 END IF;

                 IF (l_stop_fill_percent < l_trip_min_fill) OR (l_stop_fill_percent > 100) THEN
                    FND_MESSAGE.SET_NAME('WSH','WSH_STOP_FILL_PC_EXCEEDED');
                    --
                    -- Debug Statements
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    FND_MESSAGE.SET_TOKEN('STOP_NAME',wsh_trip_stops_pvt.get_name(l_stop_id,p_caller));
                    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
                    wsh_util_core.add_message(x_return_status);
                    l_stop_num_warn := l_stop_num_warn + 1;
                 END IF;
              END IF;

            ELSE
              -- as this is the last stop for the trip, weight/volume/fill percent are 0
              -- pickup w/v also 0.
              IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'For last stop, assigning weight/volume/fill percent as zero ',WSH_DEBUG_SV.C_PROC_LEVEL);              END IF;
              --
              l_total_net_weight     := 0;
              l_total_gross_weight   := 0;
              l_total_volume         := 0;
              l_total_pick_up_weight := 0;
              l_total_pick_up_volume := 0;
              IF (l_vehicle_item_id IS NOT NULL) AND (l_vehicle_org_id IS NOT NULL) THEN
                 IF ((l_fill_basis = 'W') AND (l_trip_max_weight IS NOT NULL) AND (l_trip_weight_uom IS NOT NULL)) OR
                    ((l_fill_basis = 'V') AND (l_trip_max_volume IS NOT NULL) AND (l_trip_volume_uom IS NOT NULL)) THEN
                     l_stop_fill_percent  := 0;
                 ELSE
                     l_stop_fill_percent  := NULL;
                 END IF;
              END IF;
            END IF;

            /* H integration - J: W/V Changes */
            IF WSH_UTIL_CORE.FTE_IS_INSTALLED = 'Y' AND p_override_flag = 'Y' THEN
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Fte_Load_Tender',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;
              Fte_Load_Tender(
                p_stop_id       => l_stop_id,
                p_gross_weight  => l_total_gross_weight,
                p_net_weight    => l_total_net_weight,
                p_volume        => l_total_volume,
                p_fill_percent  => l_stop_fill_percent,
                x_return_status => l_return_status);

              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                  l_stop_num_warn := l_stop_num_warn + 1;
                ELSE
                  x_return_status := l_return_status;
                  IF l_debug_on THEN
                    WSH_DEBUG_SV.pop(l_module_name);
                  END IF;
                  --
                  RETURN;
                END IF;
              END IF;
            END IF;
            /* End of H integration - */

-- J: W/V Changes
            IF p_override_flag = 'Y' THEN
              OPEN lock_stop(l_stop_id);
              FETCH lock_stop INTO l_locked_stop_id;
              IF lock_stop%FOUND THEN

                    --R12 MDC
                    --UPDATE new columns pickup/dropoff weight/volume first

                    IF l_debug_on THEN
                       WSH_DEBUG_SV.log(l_module_name,'l_total_pick_up_weight', l_total_pick_up_weight);
                       WSH_DEBUG_SV.log(l_module_name,'l_total_drop_off_weight', l_total_drop_off_weight);
                       WSH_DEBUG_SV.log(l_module_name,'l_total_pick_up_volume', l_total_pick_up_volume);
                       WSH_DEBUG_SV.log(l_module_name,'l_total_drop_off_volume', l_total_drop_off_volume);
                    END IF;


                    UPDATE wsh_trip_stops
                    SET   pick_up_weight = l_total_pick_up_weight,
                          drop_off_weight = l_total_drop_off_weight,
                          pick_up_volume = l_total_pick_up_volume,
                          drop_off_volume = l_total_drop_off_volume
                    WHERE  stop_id = l_stop_id;

                    IF (SQL%NOTFOUND) THEN
                       FND_MESSAGE.SET_NAME('WSH','WSH_STOP_NOT_FOUND');
                       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                       wsh_util_core.add_message(x_return_status);
                       goto wt_vol_error;
                    END IF;

               --R12 MDC
               --UPDATE existing weight/volume columns only if frozen flag is Not Y
               IF NOT (p_calc_wv_if_frozen = 'N' and l_wv_frozen_flag = 'Y') THEN
                 UPDATE wsh_trip_stops
                    SET   departure_gross_weight = l_total_gross_weight,
                          departure_net_weight =  l_total_net_weight,
                          departure_volume = l_total_volume,
                          departure_fill_percent = l_stop_fill_percent,
                          wv_frozen_flag = 'N'
                    WHERE  stop_id = l_stop_id;
                 IF (SQL%NOTFOUND) THEN
                    FND_MESSAGE.SET_NAME('WSH','WSH_STOP_NOT_FOUND');
                    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                    wsh_util_core.add_message(x_return_status);
                    goto wt_vol_error;
                 END IF;
               END IF;

              END IF;
              CLOSE lock_stop;

            end if;
            --added ttrichy

            --below else for the condition when stop is closed and all the values
            --already exist=>no calculation needed
        ELSE
           l_total_net_weight := l_tmp_dep_net_wt;
           l_total_gross_weight :=l_tmp_dep_gross_wt;
           l_total_volume :=l_tmp_dep_vol;
        END IF;

       l_prev_wt_uom := l_stop_wt_uom;
       l_prev_vol_uom := l_stop_vol_uom;
       l_stop_fill_percent := NULL;

-- Bug 2732503,need to continue with no message
-- warning message is being set above
       <<continue_next>>
       null;

       FETCH trip_stop_info INTO l_stop_id, l_stop_wt_uom, l_stop_vol_uom, l_stop_status, l_tmp_dep_gross_wt, l_tmp_dep_net_wt, l_tmp_dep_vol, l_shipment_type_flag, l_wv_frozen_flag;

       EXIT WHEN (trip_stop_info%NOTFOUND);
     END LOOP;

     --need to have only 1 warning for a trip
     IF l_stop_num_warn>0 OR l_trip_num_warn>0  THEN
          l_num_warn := l_num_warn + 1;
     END IF;

     /*********LOOP for stop end***********/

     CLOSE trip_stop_info;

     goto loop_end;

     <<wt_vol_error>>

      FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_WT_VOL_ERROR');
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      FND_MESSAGE.SET_TOKEN('TRIP_NAME',wsh_trips_pvt.get_name(p_trip_rows(i)));
      wsh_util_core.add_message(x_return_status);
      IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
        l_num_error := l_num_error + 1;
      ELSIF (x_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
        l_num_warn := l_num_warn + 1;
      END IF;

     <<loop_end>>
     -- bug 2366163: make sure this cursor gets closed.
     IF trip_stop_info%ISOPEN THEN
        CLOSE trip_stop_info;
     END IF;

     IF lock_stop%ISOPEN THEN
        CLOSE lock_stop;
     END IF;

   END LOOP;
   /*********TRIP LOOP END*********/

   IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'RET STATUS-'||x_return_status);
     WSH_DEBUG_SV.log(l_module_name,'NUM WARN-'||l_num_warn);
     WSH_DEBUG_SV.log(l_module_name,'NUM ERR-'||l_num_error);
     WSH_DEBUG_SV.log(l_module_name,'TRIP ROW COUNT-'||p_trip_rows.count);
   END IF;
   IF (l_num_error > 0) OR (l_num_warn > 0) THEN
     -- Bug 3688384 Display separate message for one trip .
     IF (p_trip_rows.count = 1) and (l_num_error = 0) and (l_num_warn > 0) THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_WT_VOL_WARN');
    FND_MESSAGE.SET_TOKEN('TRIP_NAME',wsh_trips_pvt.get_name(p_trip_rows(1)));
     ELSIF (p_trip_rows.count = 1) and (l_num_error > 0) THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_WT_VOL_ERR');
    FND_MESSAGE.SET_TOKEN('TRIP_NAME',wsh_trips_pvt.get_name(p_trip_rows(1)));
     ELSIF (p_trip_rows.count > 1) then
     -- Bug 3688384 .
    FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_WT_VOL_SUMMARY');
    FND_MESSAGE.SET_TOKEN('NUM_WARN',l_num_warn);
    FND_MESSAGE.SET_TOKEN('NUM_ERROR',l_num_error);
    FND_MESSAGE.SET_TOKEN('NUM_SUCCESS',p_trip_rows.count - l_num_error - l_num_warn);
     END IF;
     IF (p_trip_rows.count = l_num_error) THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     ELSE
       x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
     END IF;

     wsh_util_core.add_message(x_return_status);

   ELSE
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   END IF;

   IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'RET STATUS-'||x_return_status);
     WSH_DEBUG_SV.log(l_module_name,'NUM WARN-'||l_num_warn);
     WSH_DEBUG_SV.log(l_module_name,'NUM ERR-'||l_num_error);
   END IF;
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   EXCEPTION
     WHEN others THEN
      IF lock_stop%ISOPEN THEN
         CLOSE lock_stop;
      END IF;
      wsh_util_core.default_handler('WSH_TRIPS_ACTIONS.TRIP_WEIGHT_VOLUME');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END trip_weight_volume;


PROCEDURE validate_stop_sequence ( p_trip_id IN NUMBER,
                     x_return_status OUT NOCOPY  VARCHAR2) IS

CURSOR stops IS
SELECT stop_id,
     stop_sequence_number,
     planned_arrival_date,
     planned_departure_date
FROM   wsh_trip_stops
WHERE  trip_id = p_trip_id
ORDER BY stop_sequence_number;

l_old_arrival_date   DATE;
l_old_departure_date DATE;
l_start_flag       BOOLEAN := TRUE;
l_stop_seq_num    NUMBER;

invalid_sequence   EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_STOP_SEQUENCE';
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
       WSH_DEBUG_SV.log(l_module_name,'P_TRIP_ID',P_TRIP_ID);
   END IF;
   --
   FOR s IN stops LOOP

    l_stop_seq_num := s.stop_sequence_number;

    IF (l_start_flag) THEN
      l_old_arrival_date := s.planned_arrival_date;
      l_old_departure_date := s.planned_departure_date;
     ELSE

      IF (s.planned_arrival_date IS NOT NULL) THEN
        IF (s.planned_arrival_date < nvl(l_old_arrival_date, s.planned_arrival_date)) THEN
         raise invalid_sequence;
         END IF;
        l_old_arrival_date := s.planned_arrival_date;
       END IF;

      IF (s.planned_departure_date IS NOT NULL) THEN
        IF (s.planned_departure_date < nvl(l_old_departure_date, s.planned_departure_date)) THEN
         raise invalid_sequence;
         END IF;
        l_old_departure_date := s.planned_departure_date;
       END IF;

     END IF;

   END LOOP;

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
   EXCEPTION
    WHEN invalid_sequence THEN
       FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_SEQUENCE_INVALID');
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      FND_MESSAGE.SET_TOKEN('TRIP_NAME',wsh_trips_pvt.get_name(p_trip_id));
      wsh_util_core.add_message(x_return_status);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'INVALID_SEQUENCE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INVALID_SEQUENCE');
      END IF;
      --
     WHEN others THEN
      wsh_util_core.default_handler('WSH_TRIPS_ACTIONS.VALIDATE_STOP_SEQUENCE');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END validate_stop_sequence;

PROCEDURE Check_Unassign_Trip(
      p_del_rows      IN    wsh_util_core.id_tab_type,
      x_trip_rows    OUT NOCOPY   wsh_util_core.id_tab_type,
      x_return_status    OUT NOCOPY    VARCHAR2) IS

cnt NUMBER := 0;
l_count NUMBER;
stmt_str VARCHAR2(2000) := NULL;
del_str  VARCHAR2(2000) := NULL;

TYPE deltripcurtype IS REF CURSOR;

deltrip_cv  deltripcurtype;

others EXCEPTION;


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_UNASSIGN_TRIP';
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
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   IF (p_del_rows.count = 0) THEN
     raise others;
   END IF;

   FOR i IN 1..p_del_rows.count - 1 LOOP
    del_str := del_str || to_char(p_del_rows(i)) || ',';
   END LOOP;

   del_str := del_str || to_char(p_del_rows(p_del_rows.count));

   -- bug 2374603: we cannot unassign from PLANNED trips
   --J can assign from planned trip
   stmt_str := 'select st.trip_id, count(*) '||
            'from   wsh_trip_stops st, wsh_delivery_legs dg, wsh_trips tr '||
            'where  dg.pick_up_stop_id = st.stop_id AND '||
                           'tr.trip_id = st.trip_id AND tr.planned_flag IN (''N'',''Y'') AND ' ||
         'dg.delivery_id IN (' || del_str || ') ' ||
            'group by st.trip_id '||
            'having count(*) = '||to_char(p_del_rows.count);

   OPEN deltrip_cv FOR stmt_str;

   LOOP
    cnt := cnt + 1;
    FETCH deltrip_cv INTO x_trip_rows(cnt), l_count;
    EXIT WHEN deltrip_cv%NOTFOUND;
   END LOOP;

   CLOSE deltrip_cv;

   IF (cnt = 1) THEN -- cnt := cnt + 1 before we exit loop above, so cnt is always > 0, bug 2434673.
     FND_MESSAGE.SET_NAME('WSH','WSH_DEL_MULTI_UNASSIGN_ERROR');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    wsh_util_core.add_message(x_return_status);
   END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
   EXCEPTION
     WHEN others THEN
      wsh_util_core.default_handler('WSH_TRIPS_ACTIONS.CHECK_UNASSIGN_TRIP');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Check_Unassign_Trip;


PROCEDURE Unassign_Trip(
      p_del_rows      IN    wsh_util_core.id_tab_type,
      p_trip_id         IN   NUMBER,
      x_return_status    OUT NOCOPY    VARCHAR2) IS

cursor get_trip_info(p_trip_id in number) is
SELECT name, planned_flag
FROM   wsh_trips
WHERE  trip_id = p_trip_id;


cursor get_consol_child_deliveries(p_trip_id in number, p_delivery_id in number) is
select l.delivery_id from wsh_delivery_legs l, wsh_trip_stops s
where l.delivery_id = p_delivery_id
and l.parent_delivery_leg_id is not null
and l.pick_up_stop_id = s.stop_id
and s.trip_id = p_trip_id;

l_trip_tab        WSH_UTIL_CORE.id_tab_type;
l_mdc_del_tab     WSH_UTIL_CORE.id_tab_type;
l_return_status   VARCHAR2(10);
l_trip_name       VARCHAR2(30);
l_planned_flag    wsh_trips.planned_flag%TYPE;
j                 NUMBER := 0;
unassign_deliveries_err   EXCEPTION;
reprice_required_err      EXCEPTION;
trip_not_found            EXCEPTION;
trip_planned              EXCEPTION;

--WF: CMR
l_del_old_carrier_ids WSH_UTIL_CORE.ID_TAB_TYPE;
l_wf_rs VARCHAR2(1);


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UNASSIGN_TRIP';
--
BEGIN

   -- bug 2374603: check that trip is not planned
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
       WSH_DEBUG_SV.log(l_module_name,'P_TRIP_ID',P_TRIP_ID);
   END IF;
   --
   OPEN   get_trip_info(p_trip_id);
   FETCH  get_trip_info INTO l_trip_name, l_planned_flag;
   IF get_trip_info%NOTFOUND THEN
     l_trip_name    := NULL;
     l_planned_flag := NULL;
   END IF;
   CLOSE  get_trip_info;

   IF l_trip_name IS NULL THEN
     l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     raise trip_not_found;
   END IF;

   IF l_planned_flag = 'F' THEN
     l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     raise trip_planned;
   END IF;

   --- MDC: Check if the deliveries are assigned to consol deliveries at this trip, and unassgin them from the consol delas well.
   FOR i in 1..p_del_rows.count LOOP
       j := j + 1;
       OPEN get_consol_child_deliveries(p_trip_id, p_del_rows(i));
       FETCH get_consol_child_deliveries
       INTO l_mdc_del_tab(j);
       IF get_consol_child_deliveries%NOTFOUND THEN
          l_mdc_del_tab.delete(j);
          j := j - 1;
       END IF;
       CLOSE get_consol_child_deliveries;
   END LOOP;

   IF l_mdc_del_tab.count > 0 THEN

      WSH_NEW_DELIVERY_ACTIONS.Unassign_Dels_from_Consol_Del(
          p_parent_del     => NULL,
          p_caller         => 'WSH_UNASSIGN_TRIP',
          p_del_tab        => l_mdc_del_tab,
          x_return_status  => l_return_status);
      IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
         raise unassign_deliveries_err;
      ELSE
         x_return_status := l_return_status;
      END IF;

   END IF;

   /*CURRENTLY NOT IN USE
   --WF: CMR
   WSH_WF_STD.Get_Carrier(p_del_ids => p_del_rows,
                          x_del_old_carrier_ids => l_del_old_carrier_ids,
                          x_return_status => l_wf_rs);
   */
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_LEGS_ACTIONS.UNASSIGN_DELIVERIES',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   wsh_delivery_legs_actions.unassign_deliveries( p_del_rows, p_trip_id, NULL, NULL, l_return_status);
   IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
      raise unassign_deliveries_err;
   ELSE
       x_return_status := l_return_status;
   END IF;

  /*CURRENTLY NOT IN USE
   --WF: CMR
   WSH_WF_STD.Handle_Trip_Carriers(p_trip_id => p_trip_id,
			           p_del_ids => p_del_rows,
			           p_del_old_carrier_ids => l_del_old_carrier_ids,
			           x_return_status => l_wf_rs);
  */

   l_trip_tab.delete;
   l_trip_tab(1) := p_trip_id;
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_LEGS_ACTIONS.MARK_REPRICE_REQUIRED',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required(
                p_entity_type    => 'TRIP',
                p_entity_ids     => l_trip_tab,
                x_return_status  => l_return_status);
   IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
      raise reprice_required_err;
   ELSE
      IF x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS  AND
         l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
         x_return_status := l_return_status;
      END IF;
   END IF;

 --
 -- Debug Statements
 --
 IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
 END IF;
 --
 EXCEPTION

     WHEN trip_not_found THEN
         x_return_status := l_return_status;
         fnd_message.set_name('WSH', 'WSH_TRIP_NOT_FOUND');
         wsh_util_core.add_message(x_return_status);

                 --
                 -- Debug Statements
                 --
                 IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'TRIP_NOT_FOUND exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                     WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:TRIP_NOT_FOUND');
                 END IF;
                 --
     WHEN unassign_deliveries_err THEN
         x_return_status := l_return_status;
      fnd_message.set_name('WSH', 'WSH_DEL_UNASSIGN_ERROR');
      fnd_message.set_token('TRIP_NAME', l_trip_name);
      wsh_util_core.add_message(x_return_status);

                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'UNASSIGN_DELIVERIES_ERR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:UNASSIGN_DELIVERIES_ERR');
                END IF;
                --
     WHEN reprice_required_err THEN
      x_return_status := l_return_status;
      fnd_message.set_name('WSH', 'WSH_REPRICE_REQUIRED_ERR');
      wsh_util_core.add_message(x_return_status);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'REPRICE_REQUIRED_ERR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:REPRICE_REQUIRED_ERR');
END IF;
--
     WHEN trip_planned THEN
        x_return_status := l_return_status;
        fnd_message.set_name('WSH', 'WSH_PLANNED_TRIP_NO_ACTION');
        fnd_message.set_token('TRIP_NAME', l_trip_name);
        wsh_util_core.add_message(x_return_status);

          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'TRIP_PLANNED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:TRIP_PLANNED');
          END IF;
          --
     WHEN others THEN
        IF get_trip_info%ISOPEN THEN
          CLOSE get_trip_info;
        END IF;
      wsh_util_core.default_handler('WSH_TRIPS_ACTIONS.UNASSIGN_TRIP');
   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;
     --
END Unassign_Trip;

-- Start of comments
-- API name : Fte_Load_Tender
-- Type     : Public
-- Pre-reqs : None.
-- Function : Calls the FTE API to check for any change in Stop Info
-- Parameters :
-- IN:
--    p_stop_id      IN NUMBER Required
--    p_gross_weight IN  NUMBER
--      Gross Wt. of the stop
--    p_net_weight IN  NUMBER
--      Net Wt. of the stop
--    p_volume       IN  NUMBER
--      Volume of the stop
--    p_fill_percent IN  NUMBER
--      Fill Percent of the stop
-- OUT:
--    x_return_status OUT VARCHAR2 Required
--       give the return status of API
-- Version : 1.0
-- End of comments

PROCEDURE Fte_Load_Tender(
            p_stop_id       IN NUMBER,
            p_gross_weight  IN NUMBER,
            p_net_weight    IN NUMBER,
            p_volume        IN NUMBER,
            p_fill_percent  IN NUMBER,
            x_return_status OUT NOCOPY  VARCHAR2) IS

l_stop_rec   WSH_TRIP_STOPS_PVT.TRIP_STOP_REC_TYPE;
l_trip_rec   WSH_TRIPS_PVT.TRIP_REC_TYPE;
l_return_status VARCHAR2(1);

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'FTE_LOAD_TENDER';

BEGIN

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'P_STOP_ID',P_STOP_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_GROSS_WEIGHT',P_GROSS_WEIGHT);
    WSH_DEBUG_SV.log(l_module_name,'P_NET_WEIGHT',P_NET_WEIGHT);
    WSH_DEBUG_SV.log(l_module_name,'P_VOLUME',P_VOLUME);
    WSH_DEBUG_SV.log(l_module_name,'P_FILL_PERCENT',P_FILL_PERCENT);
  END IF;
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  -- Get pvt type record structure for stop
  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_GRP.GET_STOP_DETAILS_PVT',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  wsh_trip_stops_grp.get_stop_details_pvt(
    p_stop_id => p_stop_id,
    x_stop_rec => l_stop_rec,
    x_return_status => l_return_status);

  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
    x_return_status := l_return_status;

    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    RETURN;
  END IF;

  l_stop_rec.departure_gross_weight := p_gross_weight;
  l_stop_rec.departure_net_weight   := p_net_weight;
  l_stop_rec.departure_volume       := p_volume;
  l_stop_rec.departure_fill_percent := p_fill_percent;

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_FTE_INTEGRATION.TRIP_STOP_VALIDATIONS',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  WSH_FTE_INTEGRATION.trip_stop_validations(
    p_stop_rec => l_stop_rec,
    p_trip_rec => l_trip_rec,
    p_action   => 'UPDATE',
    x_return_status => l_return_status);

  x_return_status := l_return_status;

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'x_return_status '||x_return_status);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN others THEN
    wsh_util_core.default_handler('WSH_TRIPS_ACTIONS.Fte_Load_Tender');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
END Fte_Load_Tender;


-- bug 3516052
-- -----------------------------------------------------------------------
-- Name
--   PROCEDURE Reset_Stop_Planned_Dates
-- Purpose
--   This procedure reset the stop planned dates to be 10 minutes apart
--   within a trip based on stop_sequence_number.
--   It is used by the upgrade script to upgrade 11.5.9 and 11.5.8 data.
--   It assumes that stop sequence numbers had been set correctly.
--   For 11.5.10 or later, make sure this is called after
--   reset_stop_seq_number
-- Input Parameters:
--   p_trip_ids : list of trip ids to be updated
--
-- Output Parameters:
--   x_success_trip_ids list of trip ids validated or udpated
--   x_return_status  - Success: if all of the trips are validated or updated
--                      Warning: if some of the trips are validated or updated
--                      Error  : if none of the trips are validated or updated
--                      Unexpected Error
-- ----------------------------------------------------------------------
PROCEDURE Reset_Stop_Planned_Dates
    (   p_trip_ids          IN         wsh_util_core.id_tab_type,
        p_caller            IN  VARCHAR2,
        x_success_trip_ids  OUT NOCOPY wsh_util_core.id_tab_type,
        x_return_status     OUT NOCOPY VARCHAR2)
IS

  CURSOR lock_stop(c_stop_id NUMBER) IS
  SELECT stop_id
  FROM   wsh_trip_stops
  WHERE  stop_id = c_stop_id
  FOR UPDATE NOWAIT;

  CURSOR c_trip_stops (c_trip_id NUMBER )IS
  SELECT wst.stop_sequence_number,
         wst.stop_id,
         wst.status_code,
         wst.planned_arrival_date,
         wst.planned_departure_date,
         wst.actual_arrival_date,
         wst.actual_departure_date
  FROM wsh_trip_stops wst,
       wsh_trips wtp
  WHERE wtp.status_code in ('OP', 'IT')
  AND   wtp.trip_id = c_trip_id
  AND   wtp.trip_id = wst.trip_id
  ORDER  BY wst.stop_sequence_number,wst.stop_id;

l_stop_rec        c_trip_stops%ROWTYPE;
l_last_stop_rec   c_trip_stops%ROWTYPE;

l_trip_ids           wsh_util_core.id_tab_type;
l_success_trip_ids   wsh_util_core.id_tab_type;
l_return_status      VARCHAR2(1);

l_update_flag     BOOLEAN;
l_trip_error      BOOLEAN;
l_first_stop      BOOLEAN;
l_locked_stop_id  NUMBER;
i                 NUMBER;
l_warn_num        NUMBER;
l_base_date       DATE;
l_debug_on        BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'RESET_STOP_PLANNED_DATES';

stop_locked EXCEPTION;

l_stop_tab WSH_UTIL_CORE.id_tab_type;  -- DBI Project
l_dbi_rs    VARCHAR2(1);               -- DBI Project

PRAGMA EXCEPTION_INIT(stop_locked, -00054);

BEGIN
  l_warn_num := 0;
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_trip_ids.count ', p_trip_ids.count);
  END IF;

  IF p_trip_ids.count = 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,' p_trip_ids.count is zero');
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    return;
  END IF;

  i:= p_trip_ids.first;
  WHILE i is not NULL LOOP
     savepoint  start_of_the_trip;
     l_trip_error := FALSE;
     l_first_stop := TRUE;
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'p_trip_ids('||i||') ==> '||p_trip_ids(i));
     END IF;
     OPEN c_trip_stops(p_trip_ids(i));
     LOOP
        FETCH c_trip_stops INTO  l_stop_rec;
        EXIT WHEN c_trip_stops%NOTFOUND;
        l_update_flag := FALSE;

         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_stop_rec.stop_sequence_number', l_stop_rec.stop_sequence_number);
            WSH_DEBUG_SV.log(l_module_name,'l_stop_rec.stop_id', l_stop_rec.stop_id);
            WSH_DEBUG_SV.log(l_module_name,'l_stop_rec.status_code', l_stop_rec.status_code);
            WSH_DEBUG_SV.log(l_module_name,'l_stop_rec.planned_arrival_date', to_char(l_stop_rec.planned_arrival_date, 'DD-MON-YYYY HH24:MI:SS'));
            WSH_DEBUG_SV.log(l_module_name,'l_stop_rec.planned_departure_date', to_char(l_stop_rec.planned_departure_date,'DD-MON-YYYY HH24:MI:SS'));
            WSH_DEBUG_SV.log(l_module_name,'l_stop_rec.actual_arrival_date',  to_char(l_stop_rec.actual_arrival_date,'DD-MON-YYYY HH24:MI:SS'));
            WSH_DEBUG_SV.log(l_module_name,'l_stop_rec.actual_departure_date', to_char(l_stop_rec.actual_departure_date,'DD-MON-YYYY HH24:MI:SS'));
         END IF;



        IF not l_first_stop AND l_stop_rec.status_code = 'OP' THEN
           -- update open stops only
           IF l_stop_rec.planned_arrival_date is NULL THEN
              l_update_flag := TRUE;
              l_stop_rec.planned_arrival_date := NVL(l_stop_rec.planned_departure_date, sysdate);
           END IF;


           IF l_last_stop_rec.status_code = 'OP' THEN
              -- the reviouse stop is Open
              l_base_date := greatest(
                          NVL(l_last_stop_rec.planned_arrival_date,NVL(l_last_stop_rec.planned_departure_date, sysdate)) ,
                          NVL(l_last_stop_rec.planned_departure_date, sysdate));
           ELSE
              -- consider actual arrival or departure date if the revious stop is Arrived or Closed
              l_base_date := greatest(
                          NVL(l_last_stop_rec.planned_arrival_date,NVL(l_last_stop_rec.planned_departure_date, sysdate)) ,
                          NVL(l_last_stop_rec.planned_departure_date, sysdate),
                          NVL(l_last_stop_rec.actual_departure_date, l_last_stop_rec.actual_arrival_date));
           END IF;

           IF l_stop_rec.planned_arrival_date <= l_base_date THEN
              l_stop_rec.planned_arrival_date := l_base_date  + WSH_TRIPS_ACTIONS.C_TEN_MINUTES;
              l_update_flag := TRUE;
           END IF;

           IF l_update_flag THEN
              IF l_stop_rec.planned_departure_date < l_stop_rec.planned_arrival_date THEN
                 l_stop_rec.planned_departure_date := l_stop_rec.planned_arrival_date;
              END IF;

              BEGIN
                 -- lock the trip stop
                 OPEN lock_stop(l_stop_rec.stop_id);
                 FETCH lock_stop INTO l_locked_stop_id;
                 UPDATE wsh_trip_stops
                 SET planned_arrival_date = l_stop_rec.planned_arrival_date,
                     planned_departure_date = l_stop_rec.planned_departure_date,
                     last_update_date  = SYSDATE,
                     last_updated_by   = FND_GLOBAL.user_id,
                     last_update_login = FND_GLOBAL.login_id
                 WHERE  stop_id = l_stop_rec.stop_id;

                 -- DBI Project
                 -- Updating  WSH_TRIP_STOPS.
                 -- Call DBI API after the Update.
                 -- This API will also check for DBI Installed or not
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Stop id -',l_stop_rec.stop_id);
                 END IF;
                 l_stop_tab(1) := l_stop_rec.stop_id;
                 WSH_INTEGRATION.DBI_Update_Trip_Stop_Log
                    (p_stop_id_tab    => l_stop_tab,
                     p_dml_type       => 'UPDATE',
                     x_return_status  => l_dbi_rs);

                IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
                END IF;
                IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
                    x_return_status := l_dbi_rs;
                    -- just pass this return status to caller API
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name,'DBI API Returned Unexpected error '||x_return_status);
                        WSH_DEBUG_SV.pop(l_module_name);
                    END IF;
                    return;
                END IF;
        -- End of Code for DBI Project

                 CLOSE lock_stop;

              EXCEPTION
                 WHEN stop_locked THEN
                    IF lock_stop%ISOPEN THEN
              CLOSE lock_stop;
                    END IF;
                    --
                    IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'ERROR: stop is locked, cannot update it');
                    END IF;
                    --
                    l_trip_error := TRUE;
                    exit;
                 WHEN OTHERS THEN
                    IF lock_stop%ISOPEN THEN
                      CLOSE lock_stop;
                    END IF;
                    l_trip_error := TRUE;
                    exit;
              END;
           END IF;
        END IF;
        -- stop the information about last queried stop
        l_last_stop_rec               := l_stop_rec;

    IF l_first_stop  THEN
       l_first_stop := FALSE;
    END IF;

     END LOOP;
     CLOSE c_trip_stops;

     -- call handle_internal_stop here
     l_trip_ids(1) := p_trip_ids(i);
     Handle_Internal_Stops
          (  p_trip_ids          =>  l_trip_ids,
             p_caller            => p_caller,
             x_success_trip_ids  => l_success_trip_ids,
             x_return_status     => l_return_status);
     IF l_return_status in (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
        l_trip_error := TRUE;
        exit;
     ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
        l_warn_num  := l_warn_num + 1;
     END IF;



     IF l_trip_error THEN
       rollback to  start_of_the_trip;
     ELSE
       x_success_trip_ids(x_success_trip_ids.count+1) := p_trip_ids(i);
     END IF;
  i := p_trip_ids.next(i);
  END LOOP;

  IF x_success_trip_ids.count = 0 THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  ELSIF x_success_trip_ids.count <  p_trip_ids.count
        OR  l_warn_num > 0 THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;

  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'x_return_status '||x_return_status);
    WSH_DEBUG_SV.log(l_module_name,'l_warn_num ', l_warn_num);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION


  WHEN others THEN
    IF lock_stop%ISOPEN THEN
       close lock_stop;
    END IF;
    IF c_trip_stops%ISOPEN THEN
       close c_trip_stops;
    END IF;
    wsh_util_core.default_handler('WSH_TRIPS_ACTIONS.reset_stop_planned_dates');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END reset_stop_planned_dates;


-- -----------------------------------------------------------------------
-- Name
--   PROCEDURE Reset_Stop_Planned_Dates
-- Purpose
--   This procedure reset the stop planned dates to be 10 minutes apart
--   within a trip based on stop_sequence_number.
--   It is used by the upgrade script to upgrade 11.5.9 and 11.5.8 data.
--   It assumes that stop sequence numbers had been set correctly.
--   For 11.5.10 or later, make sure this is called after
--   reset_stop_seq_number
-- Input Parameters:
--   p_trip_id : trip id to be udpated
--
-- Output Parameters:
--   x_success_trip_ids list of trip ids validated or udpated
--   x_return_status  - Success: if the trip is validated or updated
--                      Error  : if the trip could not be updated, usually due to locking issue
--                      Unexpected Error
-- ----------------------------------------------------------------------
PROCEDURE reset_stop_planned_dates
    (   p_trip_id           IN  NUMBER,
        p_caller            IN  VARCHAR2,
        x_return_status     OUT NOCOPY  VARCHAR2)
IS

l_trip_ids          wsh_util_core.id_tab_type;
l_success_trip_ids  wsh_util_core.id_tab_type;
l_return_status     VARCHAR2(1);
l_debug_on          BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'RESET_STOP_PLANNED_DATES';

BEGIN

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_trip_id ', p_trip_id);
  END IF;

  IF p_trip_id is NULL THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'ERROR: Trip ID is NULL');
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    return;
  END IF;
  l_trip_ids(1) := p_trip_id;
  WSH_TRIPS_ACTIONS.reset_stop_planned_dates
     ( p_trip_ids         => l_trip_ids,
       p_caller           => p_caller,
       x_success_trip_ids => l_success_trip_ids,
       x_return_status    => l_return_status);
  IF l_return_status  in (WSH_UTIL_CORE.G_RET_STS_ERROR , WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  ELSE
    x_return_status := l_return_status;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'x_return_status '||x_return_status);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION

  WHEN others THEN
    wsh_util_core.default_handler('WSH_TRIPS_ACTIONS.reset_stop_planned_dates');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END reset_stop_planned_dates;

--
-- -----------------------------------------------------------------------
-- Name
--   PROCEDURE Handle_Internal_Stops
--
-- Purpose
--   This procedure links/unlinks the internal stops with the physical
--   stops in the trip
--   This is called after trip stops are created, updated, deleted, or
--   upgraded. The main cursor respects the existing linking of the
--   stops and feches rows in the order that the linked dummy stop is
--   always immediately before the linked physical stop.
--
--   This procedure automatically resolves the date conflict caused by
--   date change of a linked physical stop or forming of a new link.
--   The caller of this procedure should always evaluate this particular logic
--   to see if it meets the new requirements.
--
--   Note: the API has forked logic to handle either sequencing mode
--         set by the profile WSH_STOP_SEQ_MODE.
--
--   Linking Rules:
--      1. One dummy stop is linked exactly to one physical stop
--      2. Linking happens when both dummy and physical are of OPEN status
--      3. if the stop is at dummy location, and the next stop is at the
--         mapping physical location, link the stop with next stop by
--         pupulating physical_stop_id
--      4. if the stop is at dummy location, and the previous stop is not
--         already linked and at the mapping physical location and there
--         does not exist a delivery picking up at the physical stop
--         and droping off at the dummy stop,
--         the dummy and physical stop should be flipped
--      5. when linking is in place, the planned dates of the dummy
--         location are always 10 second before the planned arrival
--         date of the linked physical stop. Any other stop which
--         has conflicted dates will be pushed to 10 second before the
--         next stop. One planned date change of a linked physical stop
--         could result in date changes of multiple stops in the trip.
--
--         If stop sequence mode is SSN, SSN of dummy will be offset
--         from the physical stop's SSN by -1. One SSN change could
--         result in SSN changes of multiple stops in the trip.
--         If SSNs become 0 or negative because of adjustments,
--         API will error out.
--
--      6. Date change on a linked physical location or forming a new link
--         could cause date conflict with existing stops.
--         When it happens, the dates of existing stops are automatically
--         updated to avoid the date conflicts only if sequencing mode is PAD.
--
--   Unlinking Rules:
--      1. Physical_stop_id of of a dummy stop is set to NULL to unlink
--         it from the physical stop.
--      2. Unlinking could happen to stops of OPEN or CLOSED status
--      3. Unlink the dummy stop if the physical_location_id <> location_id
--         of the physical stop
--
--      Note that in WSHSTGPB.pls, create_update_stop has logic to unlink
--      the dummy stop if its stop location is modified so that its physical
--      location does not match the physical stop's location and that
--      in this same file WSHSTGPB.pls (add_to_delete_list), deleting
--      a physical stop will also delete its linked dummy stop.
--
-- Therefore, it is sufficient for this API to only compare the physical
-- stop's location to decide whether to unlink.
--
-- Input Parameters:
--   p_trip_ids : list of trip ids to be processed
--   p_caller:    if the caller is 'WSH_TRIP_UPGRADE', it will check the
--                mapping of internal location. Otherwise, it just assume
--                tha mapping has been checked previously.
--
-- Output Parameters:
--   x_success_trip_ids list of trip ids processed
--   x_return_status  - Success: if all of the trips are validated or updated
--                      Warning: if some of the trips are validated or updated
--                      Error  : if none of the trips are validated or updated
--
-- ----------------------------------------------------------------------
PROCEDURE Handle_Internal_Stops
    (   p_trip_ids          IN  wsh_util_core.id_tab_type,
        p_caller            IN  VARCHAR2,
        x_success_trip_ids  OUT NOCOPY wsh_util_core.id_tab_type,
        x_return_status     OUT NOCOPY VARCHAR2)
IS
    --
    -- make a list of stops sequenced by PAD,
    -- accounting for unlinking events (i.e., physical locations
    -- of currently linked stops no longer match the stop locations of the
    -- physical stops)
    --    stops that remain linked dummy stops will be automatically synchronized
    --    with the physical stops (PAD/PDD by 10 seconds)
    -- SSN is not synchronized in this cursor because RESET_STOP_SEQ_NUMBERS
    -- will update the SSNs.
    --
CURSOR c_get_stops_PAD(c_trip_id NUMBER) IS
SELECT wts.stop_id,
       wts.stop_location_id,
       wts.physical_location_id,
       wts.physical_stop_id,
       wts.stop_sequence_number,

       -- conditions to keep the link to synchronize the columns:
       --    a. physical stop exists
       --    b. (physical location matches or dummy stop's status is Arrived)
       --
       -- The same DECODE structure must be maintained for these columns
       -- in this cursor:
       --             PLANNED_ARRIVAL_DATE,
       --             PLANNED_DEPARTURE_DATE,
       --             BREAK_LINK_FLAG,
       --         and ORDER BY first clause
       DECODE(
              DECODE(wts.physical_stop_id,
                     NULL, 0,
                     NVL(pts.stop_id,-1),
                           DECODE(wts.physical_location_id,
                                  pts.stop_location_id, 1,
                                  DECODE(wts.status_code,'AR',1, 0)
                                 ),
                     0 -- linked to a non-existent physical stop
                    ),
              1, (pts.planned_arrival_date - C_TEN_SECONDS),
              wts.planned_arrival_date)    PLANNED_ARRIVAL_DATE,

       DECODE(
              DECODE(wts.physical_stop_id,
                     NULL, 0,
                     NVL(pts.stop_id,-1),
                           DECODE(wts.physical_location_id,
                                  pts.stop_location_id, 1,
                                  DECODE(wts.status_code,'AR',1, 0)
                                ),
                     0 -- linked to a non-existent physical stop
                    ),
               1, (pts.planned_arrival_date - C_TEN_SECONDS),
              wts.planned_departure_date)    PLANNED_DEPARTURE_DATE,

       wts.stop_sequence_number  org_stop_seq_num,
       wts.planned_arrival_date org_pl_arr_date,
       wts.planned_departure_date org_pl_dep_date,
       wts.status_code,

       -- break_link_flag: 'Y' or 'N'
       -- The DECODE structure is slightly modified
       -- to decide whether link needs breaking.
       -- If stop is not linked (NULL), there is no link to break.
       -- If physical stop_id matches, check for need to break link.
       DECODE(
              DECODE(wts.physical_stop_id,
                     NULL, 1,  -- modified value because there is no link to break
                     NVL(pts.stop_id,-1),
                           DECODE(wts.physical_location_id,
                                  pts.stop_location_id, 1,
                                  DECODE(wts.status_code,'AR',1, 0)
                                 ),
                     0 -- linked to a non-existent physical stop
                    ),
              1, 'N',
              'Y')   BREAK_LINK_FLAG
FROM wsh_trip_stops wts,
     wsh_trip_stops pts
WHERE wts.trip_id = c_trip_id
      and wts.physical_stop_id = pts.stop_id(+)
ORDER BY
      -- we need to order by PAD;
      -- if stop stays linked, use its physical stop's PAD.
      -- second column is to ensure the dummy stop will precede
      -- physical stop (as non-NULL always precede NULL).
      DECODE(
              DECODE(wts.physical_stop_id,
                     NULL, 0,
                     NVL(pts.stop_id,-1),
                           DECODE(wts.physical_location_id,
                                  pts.stop_location_id, 1,
                                  DECODE(wts.status_code,'AR',1, 0)
                                 ),
                     0 -- linked to a non-existent physical stop
                    ),
              1, pts.planned_arrival_date,
              wts.planned_arrival_date
            ),
      pts.stop_id;

--
-- make a list of stops sequenced by SSN,
-- accounting for unlinking events (i.e,. physical locations
-- of currently linked stops no longer match the stop locations of the
-- physical stops)
--    stops that remain linked dummy stops will be automatically
--    synchronized with the physical stops (SSN will be offset by -1;
--    PAD/PDD by 10 seconds).
--
--
-- This cursor is derived from c_get_stops_PAD so that the ORDER BY clause
-- can be modified to sort the stops by SSN, instead of PAD.
--
--
CURSOR c_get_stops_SSN(c_trip_id NUMBER) IS
SELECT wts.stop_id,
       wts.stop_location_id,
       wts.physical_location_id,
       wts.physical_stop_id,

       -- conditions to keep the link to synchronize the columns:
       --    a. physical stop exists/matches
       --    b. (physical location matches or dummy stop's status is Arrived)
       --
       -- The same DECODE structure must be maintained for these columns
       -- in this cursor:
       --             STOP_SEQUENCE_NUMBER
       --             PLANNED_ARRIVAL_DATE,
       --             PLANNED_DEPARTURE_DATE,
       --             BREAK_LINK_FLAG,
       --         and ORDER BY first clause
       DECODE(
              DECODE(wts.physical_stop_id,
                     NULL, 0,
                     NVL(pts.stop_id,-1),
                           DECODE(wts.physical_location_id,
                                  pts.stop_location_id, 1,
                                  DECODE(wts.status_code,'AR',1, 0)
                                 ),
                     0 -- linked to a non-existent physical stop
                    ),
              1, (pts.stop_sequence_number - 1),
              wts.stop_sequence_number)    STOP_SEQUENCE_NUMBER,

       DECODE(
              DECODE(wts.physical_stop_id,
                     NULL, 0,
                     NVL(pts.stop_id,-1),
                           DECODE(wts.physical_location_id,
                                  pts.stop_location_id, 1,
                                  DECODE(wts.status_code,'AR',1, 0)
                                 ),
                     0 -- linked to a non-existent physical stop
                    ),
              1, (pts.planned_arrival_date - C_TEN_SECONDS),
              wts.planned_arrival_date)    PLANNED_ARRIVAL_DATE,

       DECODE(
              DECODE(wts.physical_stop_id,
                     NULL, 0,
                     NVL(pts.stop_id,-1),
                           DECODE(wts.physical_location_id,
                                  pts.stop_location_id, 1,
                                  DECODE(wts.status_code,'AR',1, 0)
                                 ),
                     0 -- linked to a non-existent physical stop
                    ),
               1, (pts.planned_arrival_date - C_TEN_SECONDS),
              wts.planned_departure_date)    PLANNED_DEPARTURE_DATE,

       wts.stop_sequence_number  org_stop_seq_num,
       wts.planned_arrival_date org_pl_arr_date,
       wts.planned_departure_date org_pl_dep_date,
       wts.status_code,

       -- break_link_flag: 'Y' or 'N'
       -- The DECODE structure is modified
       -- to decide whether link needs breaking.
       -- If stop is not linked (NULL), there is no link to break.
       -- If physical stop_id matches, check for delinking.
       -- Otherwise, the physical stop must have been deleted.
       DECODE(
              DECODE(wts.physical_stop_id,
                     NULL, 1,  -- no link to break
                     NVL(pts.stop_id,-1),
                           DECODE(wts.physical_location_id,
                                  pts.stop_location_id, 1,
                                  DECODE(wts.status_code,'AR',1, 0)
                                 ),
                     0 -- linked to a non-existent physical stop
                    ),
              1, 'N',
              'Y')   BREAK_LINK_FLAG
FROM wsh_trip_stops wts,
     wsh_trip_stops pts
WHERE wts.trip_id = c_trip_id
      and wts.physical_stop_id = pts.stop_id(+)
ORDER BY
      -- we need to order by SSN;
      -- if stop stays linked, use its physical stop's SSN.
      -- second column is to ensure the dummy stop will precede
      -- physical stop (as non-NULL always precede NULL).
      DECODE(
              DECODE(wts.physical_stop_id,
                     NULL, 0,
                     NVL(pts.stop_id,-1),
                           DECODE(wts.physical_location_id,
                                  pts.stop_location_id, 1,
                                  DECODE(wts.status_code,'AR',1, 0)
                                 ),
                     0 -- linked to a non-existent physical stop
                       -- (should never happen)
                    ),
              1, pts.stop_sequence_number,
              wts.stop_sequence_number
            ),
      pts.stop_id;

CURSOR c_flip_disallowed(c_dummy_stop_id NUMBER , c_physical_stop_id NUMBER ) IS
 select delivery_leg_id
 from
    wsh_delivery_legs wlg
 where
    pick_up_stop_id = c_physical_stop_id
    AND drop_off_stop_id = c_dummy_stop_id
    AND rownum = 1;

--
l_getstops_stop_id             wsh_util_core.id_tab_type;
l_getstops_stop_loc_id         wsh_util_core.id_tab_type;
l_getstops_phys_loc_id         wsh_util_core.id_tab_type;
l_getstops_phys_stop_id        wsh_util_core.id_tab_type;
l_getstops_stop_seq_num        wsh_util_core.id_tab_type;
l_getstops_pl_arr_date         wsh_util_core.date_tab_type;
l_getstops_pl_dep_date         wsh_util_core.date_tab_type;
l_getstops_org_stop_seq_num    wsh_util_core.id_tab_type;
l_getstops_org_pl_arr_date     wsh_util_core.date_tab_type;
l_getstops_org_pl_dep_date     wsh_util_core.date_tab_type;
l_getstops_status_code         WSH_UTIL_CORE.Column_Tab_Type;
l_getstops_break_link_flags    WSH_UTIL_CORE.Column_Tab_Type;

-- both the cursors c_get_stops_PAD and c_get_stops_SSN select identical fields
l_getstops_tmp                 c_get_stops_PAD%ROWTYPE;

i                        NUMBER;
j                        NUMBER;
l_delivery_leg_id        NUMBER;
l_warn_num               NUMBER;
l_debug_on               BOOLEAN;
l_update_flag            BOOLEAN;
l_push_date_allowed      BOOLEAN;
l_push_ssn_allowed       BOOLEAN;
l_return_status          VARCHAR2(1);
l_stop_details_rec       WSH_TRIP_STOPS_VALIDATIONS.stop_details;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Handle_Internal_Stops';
stop_locked              EXCEPTION;
get_physical_loc_err     EXCEPTION;
reset_stop_seq_number_error  EXCEPTION;
invalid_stop_date EXCEPTION;
invalid_stop_seq_num     EXCEPTION;
invalid_ssn_adjustment   EXCEPTION;
duplicate_stop_seq      EXCEPTION;

validate_stop_date_error EXCEPTION;
PRAGMA EXCEPTION_INIT(stop_locked, -00054);
l_dbi_rs                VARCHAR2(1); -- DBI Project

l_stop_seq_mode         NUMBER;

BEGIN
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  l_warn_num := 0;
  x_success_trip_ids.delete;

  l_stop_seq_mode := WSH_TRIPS_ACTIONS.GET_STOP_SEQ_MODE;

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_trip_ids.count ', p_trip_ids.count);
    WSH_DEBUG_SV.log(l_module_name,'p_caller ', p_caller);
  END IF;

  IF p_trip_ids.count = 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,' p_trip_ids.count is zero');
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    return;
  END IF;

  i:= p_trip_ids.first;
  WHILE i is not NULL LOOP
     SAVEPOINT start_of_the_trip;
     BEGIN
        l_update_flag := FALSE;
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'p_trip_ids('||i||') ==> '||p_trip_ids(i));
        END IF;

        IF l_stop_seq_mode = WSH_INTERFACE_GRP.G_STOP_SEQ_MODE_PAD THEN

          OPEN c_get_stops_PAD(p_trip_ids(i));
          FETCH c_get_stops_PAD BULK COLLECT INTO l_getstops_stop_id,
                                          l_getstops_stop_loc_id,
                                          l_getstops_phys_loc_id,
                                          l_getstops_phys_stop_id,
                                          l_getstops_stop_seq_num,
                                          l_getstops_pl_arr_date,
                                          l_getstops_pl_dep_date,
                                          l_getstops_org_stop_seq_num,
                                          l_getstops_org_pl_arr_date,
                                          l_getstops_org_pl_dep_date,
                                          l_getstops_status_code,
                                          l_getstops_break_link_flags;
          CLOSE c_get_stops_PAD;
        ELSE
          OPEN c_get_stops_SSN(p_trip_ids(i));
          FETCH c_get_stops_SSN BULK COLLECT INTO l_getstops_stop_id,
                                          l_getstops_stop_loc_id,
                                          l_getstops_phys_loc_id,
                                          l_getstops_phys_stop_id,
                                          l_getstops_stop_seq_num,
                                          l_getstops_pl_arr_date,
                                          l_getstops_pl_dep_date,
                                          l_getstops_org_stop_seq_num,
                                          l_getstops_org_pl_arr_date,
                                          l_getstops_org_pl_dep_date,
                                          l_getstops_status_code,
                                          l_getstops_break_link_flags;
          CLOSE c_get_stops_SSN;
        END IF;

        IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_getstops_stop_id.count', l_getstops_stop_id.count);
        END IF;
        IF l_getstops_stop_id.count > 0 THEN
           FOR j in l_getstops_stop_id.first .. l_getstops_stop_id.last LOOP
               IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'l_getstops_stop_id('||j||')', l_getstops_stop_id(j));
                 WSH_DEBUG_SV.log(l_module_name,'l_getstops_stop_loc_id('||j||')', l_getstops_stop_loc_id(j));
                 WSH_DEBUG_SV.log(l_module_name,'l_getstops_phys_loc_id('||j||')', l_getstops_phys_loc_id(j));
                 WSH_DEBUG_SV.log(l_module_name,'l_getstops_phys_stop_id('||j||')', l_getstops_phys_stop_id(j));
                 WSH_DEBUG_SV.log(l_module_name,'l_getstops_stop_seq_num('||j||')', l_getstops_stop_seq_num(j));
                 WSH_DEBUG_SV.log(l_module_name,'l_getstops_org_stop_seq_num('||j||')', l_getstops_org_stop_seq_num(j));
                 WSH_DEBUG_SV.log(l_module_name,'l_getstops_pl_arr_date('||j||')', to_char(l_getstops_pl_arr_date(j),'DD-MON-YYYY HH24:MI:SS'));
                 WSH_DEBUG_SV.log(l_module_name,'l_getstops_pl_dep_date('||j||')', to_char(l_getstops_pl_dep_date(j),'DD-MON-YYYY HH24:MI:SS'));
                 WSH_DEBUG_SV.log(l_module_name,'l_getstops_org_pl_arr_date('||j||')', to_char(l_getstops_org_pl_arr_date(j),'DD-MON-YYYY HH24:MI:SS'));
                 WSH_DEBUG_SV.log(l_module_name,'l_getstops_org_pl_dep_date('||j||')', to_char(l_getstops_org_pl_dep_date(j),'DD-MON-YYYY HH24:MI:SS'));
                 WSH_DEBUG_SV.log(l_module_name,'l_getstops_status_code('||j||')', l_getstops_status_code(j));
                 WSH_DEBUG_SV.log(l_module_name,'l_getstops_break_link_flags('||j||')', l_getstops_break_link_flags(j));
               END IF;
              IF p_caller = 'WSH_TRIP_UPGRADE' THEN
                 WSH_LOCATIONS_PKG.Convert_internal_cust_location(
                    p_internal_cust_location_id => l_getstops_stop_loc_id(j),
                    x_internal_org_location_id  => l_getstops_phys_loc_id(j),
                    x_return_status             => l_return_status);

                 IF l_return_status in (FND_API.G_RET_STS_UNEXP_ERROR, FND_API.G_RET_STS_ERROR) THEN
                    RAISE get_physical_loc_err;
                 END IF;
              END IF;

              IF l_getstops_phys_loc_id(j) is not NULL THEN
                 -- current stop is a dummy stop

                 IF l_getstops_phys_stop_id(j) is not NULL THEN
                    -- check if unlinking is necessary

                    IF l_getstops_break_link_flags(j) = 'Y' THEN
                      IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name,'unlink stop', l_getstops_stop_id(j));
                      END IF;
                      l_getstops_phys_stop_id(j) := NULL;
                      l_update_flag := TRUE;
                    END IF;
                 END IF;

                 -- check for linking to next stop or previous stop
                 IF l_getstops_stop_id.exists(j+1)
                    AND l_getstops_status_code(j) = 'OP'
                    AND l_getstops_status_code(j+1) = 'OP'
                    AND l_getstops_phys_loc_id(j) = l_getstops_stop_loc_id(j+1) THEN

                    -- link to next stop
                    IF l_debug_on THEN
                      WSH_DEBUG_SV.log(l_module_name,'link to next stop at stop', l_getstops_stop_id(j));
                    END IF;
                     l_getstops_phys_stop_id(j) := l_getstops_stop_id(j+1);
                     l_getstops_pl_arr_date(j) := l_getstops_pl_arr_date(j+1) - WSH_TRIPS_ACTIONS.C_TEN_SECONDS;
                     l_getstops_pl_dep_date(j) := l_getstops_pl_arr_date(j);
                     IF l_stop_seq_mode = WSH_INTERFACE_GRP.G_STOP_SEQ_MODE_SSN THEN
                       l_getstops_stop_seq_num(j) := l_getstops_stop_seq_num(j+1) - 1;
                     END IF;
                     l_update_flag := TRUE;
                 ELSIF l_getstops_stop_id.exists(j-1)
                    AND l_getstops_status_code(j) = 'OP'
                    AND l_getstops_status_code(j-1) = 'OP'
                    AND l_getstops_phys_loc_id(j) = l_getstops_stop_loc_id(j-1)
                    AND (NOT l_getstops_stop_id.exists(j-2) OR
                         NVL(l_getstops_phys_stop_id(j-2), -99) <> l_getstops_stop_id(j-1))
                    THEN
                      -- flip and link

                      OPEN c_flip_disallowed(l_getstops_stop_id(j), l_getstops_stop_id(j-1));
                      FETCH c_flip_disallowed INTO l_delivery_leg_id;
                      IF c_flip_disallowed%NOTFOUND THEN
                         IF l_debug_on THEN
                            WSH_DEBUG_SV.log(l_module_name,'flip and link at stop', l_getstops_stop_id(j));
                         END IF;
                         -- flip these two stops

                         l_getstops_tmp.stop_id                 := l_getstops_stop_id(j);
                         l_getstops_tmp.stop_location_id        := l_getstops_stop_loc_id(j);
                         l_getstops_tmp.physical_location_id    := l_getstops_phys_loc_id(j);
                         l_getstops_tmp.status_code             := l_getstops_status_code(j);

                         l_getstops_stop_id(j)                  := l_getstops_stop_id(j-1);
                         l_getstops_stop_loc_id(j)      := l_getstops_stop_loc_id(j-1);
                         l_getstops_phys_loc_id(j)      := l_getstops_phys_loc_id(j-1);
                         l_getstops_phys_stop_id(j)         := l_getstops_phys_stop_id(j-1);
                         l_getstops_pl_arr_date(j)      := l_getstops_pl_arr_date(j-1);
                         l_getstops_pl_dep_date(j)      := l_getstops_pl_dep_date(j-1);
                         l_getstops_status_code(j)      := l_getstops_status_code(j-1);

                         l_getstops_stop_id(j-1)                := l_getstops_tmp.stop_id;
                         l_getstops_stop_loc_id(j-1)            := l_getstops_tmp.stop_location_id;
                         l_getstops_phys_loc_id(j-1)            := l_getstops_tmp.physical_location_id;
                         l_getstops_status_code(j-1)            := l_getstops_tmp.status_code;
                         l_getstops_phys_stop_id(j-1)           := l_getstops_stop_id(j);  -- link
                         l_getstops_pl_arr_date(j-1)            := l_getstops_pl_arr_date(j) - WSH_TRIPS_ACTIONS.C_TEN_SECONDS;
                         l_getstops_pl_dep_date(j-1)            := l_getstops_pl_arr_date(j-1);

                         IF l_stop_seq_mode = WSH_INTERFACE_GRP.G_STOP_SEQ_MODE_SSN THEN
                           -- we need to adjust the sequence numbers of these stops flipped:
                           --   physical stop should retain the SSN.
                           --   dummy stop should have SSN subtracted by 1.
                           l_getstops_stop_seq_num(j) := l_getstops_stop_seq_num(j-1);
                           l_getstops_stop_seq_num(j-1) := l_getstops_stop_seq_num(j) - 1;
                         END IF;

                         l_update_flag := TRUE;
                      END IF;
                      CLOSE c_flip_disallowed;
                 END IF;
              END IF;
           END LOOP;

           IF l_stop_seq_mode = WSH_INTERFACE_GRP.G_STOP_SEQ_MODE_SSN THEN
             -- in SSN mode, resequencing a physical stop to be first
             -- could cause its linked dummy stop sequence to become 0
             -- or negative.
             -- Not an issue in PAD because SSNs will be renumbered.
             IF l_getstops_stop_seq_num(1) <= 0 THEN
                 RAISE invalid_ssn_adjustment;
             END IF;
           END IF;

           FOR j IN l_getstops_stop_id.first .. l_getstops_stop_id.last LOOP
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'j ', j );
                WSH_DEBUG_SV.log(l_module_name,'l_getstops_stop_id(j)' , l_getstops_stop_id(j));
                WSH_DEBUG_SV.log(l_module_name,'l_getstops_stop_seq_num(j)' , l_getstops_stop_seq_num(j));
                WSH_DEBUG_SV.log(l_module_name,'l_getstops_pl_arr_date(j)' , to_char(l_getstops_pl_arr_date(j), 'DD-MON-YYYY HH24:MI:SS'));
                WSH_DEBUG_SV.log(l_module_name,'l_getstops_phys_stop_id(j) ' , l_getstops_phys_stop_id(j) );
              END IF;
           END LOOP;

           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'loop backward checking for date or SSN conflict');
             WSH_DEBUG_SV.log(l_module_name,'l_getstops_stop_id.last', l_getstops_stop_id.last);
             WSH_DEBUG_SV.log(l_module_name,'l_getstops_stop_id.first' , l_getstops_stop_id.first);
           END IF;

           l_push_date_allowed := FALSE;
           l_push_ssn_allowed  := FALSE;
           j := l_getstops_stop_id.last;
           WHILE j is not null LOOP

             -- check backward for planned arrival date or SSN conflict
             -- bug 4248428: fixed issue with wrong error message by
             -- revising the conditions to check for or resolve conflict
             -- only when the current stop is dummy or dummy stop has pushed
             -- the preceding stop back.
             IF j > 1 and
                (l_getstops_phys_stop_id(j) is not NULL
                 OR l_push_date_allowed OR l_push_ssn_allowed) THEN

                IF l_stop_seq_mode = WSH_INTERFACE_GRP.G_STOP_SEQ_MODE_PAD THEN

                  IF l_getstops_pl_arr_date(j-1) >= l_getstops_pl_arr_date(j) THEN
                     IF l_debug_on THEN
                       WSH_DEBUG_SV.log(l_module_name,'arr date of prev stop conflict at stop' , l_getstops_stop_id(j));
                     END IF;
                     IF l_push_date_allowed or
                        (l_getstops_pl_arr_date(j) <> l_getstops_org_pl_arr_date(j) and
                        l_getstops_phys_stop_id(j) is not NULL ) THEN
                        -- the linked physical stop has been modified, it is ok to push
                        -- other stops to avoid the time conflict
                        l_getstops_pl_arr_date(j-1) := l_getstops_pl_arr_date(j) - WSH_TRIPS_ACTIONS.C_TEN_SECONDS;
                        l_getstops_pl_dep_date(j-1) := l_getstops_pl_arr_date(j-1);
                        l_update_flag := TRUE;
                        l_push_date_allowed := TRUE;
                     ELSE
                       raise invalid_stop_date;
                     END IF;
                  ELSIF l_getstops_pl_dep_date(j-1) >= l_getstops_pl_arr_date(j) THEN
                     IF l_debug_on THEN
                       WSH_DEBUG_SV.log(l_module_name,'dep date of prev stop conflict at stop' , l_getstops_stop_id(j-1));
                     END IF;
                     l_getstops_pl_dep_date(j-1) := l_getstops_pl_arr_date(j-1);
                     l_update_flag := TRUE;
                  END IF;

                ELSE -- mode is SSN

                  IF l_getstops_stop_seq_num(j-1) >= l_getstops_stop_seq_num(j) THEN
                     IF l_debug_on THEN
                       WSH_DEBUG_SV.log(l_module_name,'SSN of prev stop conflict at stop' , l_getstops_stop_id(j));
                     END IF;
                     IF l_push_ssn_allowed or
                        (l_getstops_stop_seq_num(j) <> l_getstops_org_stop_seq_num(j) and
                        l_getstops_phys_stop_id(j) is not NULL ) THEN
                        -- the linked physical stop has been modified, it is ok to push
                        -- other stops to avoid the SSN conflict.
                        l_getstops_stop_seq_num(j-1) := l_getstops_stop_seq_num(j) - 1;
                        IF l_getstops_stop_seq_num(j-1) <= 0 THEN
                          -- adjusting SSNs such that they become 0 or negative
                          -- is a corner-case that will return error.
                          RAISE invalid_ssn_adjustment;
                        END IF;
                        l_update_flag := TRUE;
                        l_push_ssn_allowed := TRUE;
                     ELSE
                         -- here the user has attempted to sandwich a stop
                         -- between the linked dummy stop and its
                         -- physical stop.
                         raise invalid_stop_seq_num;
                     END IF;
                  END IF;

                END IF;
             END IF;

             IF j > 1
                AND  l_stop_seq_mode = WSH_INTERFACE_GRP.G_STOP_SEQ_MODE_SSN THEN
               -- bug 4245339: check for non-unique SSN
               IF l_getstops_stop_seq_num(j-1)
                   = l_getstops_stop_seq_num(j) THEN
                 raise duplicate_stop_seq;
               END IF;
             END IF;

             j := l_getstops_stop_id.prior(j);

           END LOOP;
        END IF;

        IF l_update_flag or p_caller = 'WSH_CREATE_TRIP_STOP' THEN
           IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'updating stops ' , l_getstops_stop_id.count);
           END IF;
           FORALL j IN l_getstops_stop_id.first..l_getstops_stop_id.last
              UPDATE WSH_TRIP_STOPS
              SET
                PHYSICAL_LOCATION_ID    = l_getstops_phys_loc_id(j),
                PHYSICAL_STOP_ID        = l_getstops_phys_stop_id(j),
                PLANNED_ARRIVAL_DATE    = l_getstops_pl_arr_date(j),
                PLANNED_DEPARTURE_DATE  = l_getstops_pl_dep_date(j),
                STOP_SEQUENCE_NUMBER    = l_getstops_stop_seq_num(j),
                last_update_date        = SYSDATE,
                last_updated_by         = FND_GLOBAL.USER_ID,
                last_update_login       = FND_GLOBAL.LOGIN_ID
              WHERE  STOP_ID = l_getstops_stop_id(j);
           IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'done update' , l_getstops_stop_id.count);
           END IF;
            --
        -- DBI Project
        -- Updating  WSH_TRIP_STOPS.
        -- Call DBI API after the Update.
        -- This API will also check for DBI Installed or not
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Stop count -',l_getstops_stop_id.count);
        END IF;
	    WSH_INTEGRATION.DBI_Update_Trip_Stop_Log
          (p_stop_id_tab	=> l_getstops_stop_id,
           p_dml_type		=> 'UPDATE',
           x_return_status      => l_dbi_rs);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
        END IF;
        IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
	       x_return_status := l_dbi_rs;
	       rollback to start_of_the_trip;
           -- just pass this return status to caller API
           IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'DBI API Returned Unexpected error '||x_return_status);
            WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           return;
        END IF;

        -- End of Code for DBI Project

        END IF;
        IF l_stop_seq_mode = WSH_INTERFACE_GRP.G_STOP_SEQ_MODE_PAD THEN
          -- need to resequence the stops' SSNs and validate their dates.

          l_stop_details_rec.trip_id :=  p_trip_ids(i);
          --l_stop_details_rec.stop_id :=  NULL;
          --l_stop_details_rec.stop_sequence_number := NULL;

          WSH_TRIP_STOPS_ACTIONS.RESET_STOP_SEQ_NUMBERS(
                p_stop_details_rec => l_stop_details_rec,
                x_return_status => l_return_status);

          IF l_debug_on THEN
             wsh_debug_sv.log(l_module_name,'Return Status From WWSH_TRIP_STOPS_ACTIONS.RESET_STOP_SEQ_NUMBERS for trip '||p_trip_ids(i) ,l_return_status);
          END IF;

          IF l_return_status in ( WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
             raise reset_stop_seq_number_error;
          ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
             l_warn_num := l_warn_num + 1;
          END IF;

          WSH_TRIP_VALIDATIONS.Validate_Stop_Dates (
             p_trip_id               => p_trip_ids(i),
             x_return_status         => l_return_status);

          IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'Return Status From WSH_TRIP_STOPS_VALIDATIONS.Validate_Stop_Dates for trip '||p_trip_ids(i) ,l_return_status);
          END IF;

          IF l_return_status in ( WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
             raise validate_stop_date_error;
          ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
             l_warn_num := l_warn_num + 1;
          END IF;

        END IF;  -- PAD resequencing

        x_success_trip_ids(x_success_trip_ids.count+1) := p_trip_ids(i);

     EXCEPTION
       WHEN get_physical_loc_err THEN
          IF c_get_stops_PAD%ISOPEN THEN
             CLOSE c_get_stops_PAD;
          END IF;
          IF c_get_stops_SSN%ISOPEN THEN
             CLOSE c_get_stops_SSN;
          END IF;

          rollback to start_of_the_trip;

-- Handle Date Exception
       WHEN invalid_stop_date THEN
          rollback to start_of_the_trip;
         FND_MESSAGE.SET_NAME('WSH', 'WSH_BETWEEN_LINKED_STOPS');
         FND_MESSAGE.SET_TOKEN('DUMMY_STOP_DATE', fnd_date.date_to_displaydt(l_getstops_pl_arr_date(j)));
         FND_MESSAGE.SET_TOKEN('DUMMY_LOCATION_DESP',
            WSH_UTIL_CORE.Get_Location_Description (l_getstops_stop_loc_id(j),'NEW UI CODE INFO'));
         FND_MESSAGE.SET_TOKEN('PHYSICAL_STOP_DATE', fnd_date.date_to_displaydt(l_getstops_pl_arr_date(j+1)));
         FND_MESSAGE.SET_TOKEN('PHYSICAL_LOCATION_DESP',
         WSH_UTIL_CORE.Get_Location_Description (l_getstops_stop_loc_id(j+1),'NEW UI CODE INFO'));
         wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR);

-- Handle SSN Exception
       WHEN invalid_stop_seq_num THEN
          rollback to start_of_the_trip;
         FND_MESSAGE.SET_NAME('WSH', 'WSH_BETWEEN_LINKED_STOPS_SSN');
         FND_MESSAGE.SET_TOKEN('DUMMY_STOP_SEQ_NUM', l_getstops_stop_seq_num(j));
         FND_MESSAGE.SET_TOKEN('DUMMY_LOCATION_DESP',
            WSH_UTIL_CORE.Get_Location_Description (l_getstops_stop_loc_id(j),'NEW UI CODE INFO'));
         FND_MESSAGE.SET_TOKEN('PHYSICAL_STOP_SEQ_NUM', l_getstops_stop_seq_num(j+1));
         FND_MESSAGE.SET_TOKEN('PHYSICAL_LOCATION_DESP',
         WSH_UTIL_CORE.Get_Location_Description (l_getstops_stop_loc_id(j+1),'NEW UI CODE INFO'));
         wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR);

       WHEN invalid_ssn_adjustment THEN
          rollback to start_of_the_trip;
         FND_MESSAGE.SET_NAME('WSH', 'WSH_INVALID_SSN_ADJUSTMENT');
         wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR);

-- Handle non unique SSN exception (bug 4245339)
       WHEN duplicate_stop_seq THEN
          rollback to start_of_the_trip;
          FND_MESSAGE.SET_NAME('WSH','WSH_STOP_DUP_SEQUENCE');
          wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR);

       WHEN reset_stop_seq_number_error THEN
          rollback to start_of_the_trip;

       WHEN validate_stop_date_error THEN

          rollback to start_of_the_trip;

       WHEN Others THEN
          IF c_get_stops_PAD%ISOPEN THEN
             CLOSE c_get_stops_PAD;
          END IF;
          IF c_get_stops_SSN%ISOPEN THEN
             CLOSE c_get_stops_SSN;
          END IF;

          IF c_flip_disallowed%ISOPEN THEN
             CLOSE c_flip_disallowed;
          END IF;

          rollback to start_of_the_trip;
     END;

  i := p_trip_ids.next(i);
  END LOOP;

  IF x_success_trip_ids.count = 0 THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  ELSIF x_success_trip_ids.count <  p_trip_ids.count
        OR  l_warn_num > 0 THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'x_success_trip_ids.count', x_success_trip_ids.count);
    WSH_DEBUG_SV.logmsg(l_module_name,'x_return_status '||x_return_status);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION

  WHEN others THEN
    IF c_get_stops_PAD%ISOPEN THEN
       close c_get_stops_PAD;
    END IF;
    IF c_get_stops_SSN%ISOPEN THEN
       close c_get_stops_SSN;
    END IF;

    wsh_util_core.default_handler('WSH_TRIPS_ACTIONS.LINK_TO_REGULAR_STOPS');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END Handle_Internal_Stops;



PROCEDURE PROCESS_CARRIER_SELECTION (
        p_init_msg_list            IN            VARCHAR2 DEFAULT fnd_api.g_false,
        p_trip_id_tab              IN            wsh_util_core.id_tab_type,
        p_caller                   IN  VARCHAR2 DEFAULT NULL, -- WSH_FSTRX / WSH_PUB /  WSH_GROUP/ FTE
        x_msg_count                OUT NOCOPY    NUMBER,
        x_msg_data                 OUT NOCOPY    VARCHAR2,
        x_return_status            OUT NOCOPY  VARCHAR2)

IS

-- Cursor to get trip level information
   CURSOR c_get_trip_details(c_tripid IN NUMBER) is
   SELECT trip_id
      , name
      , planned_flag
      , status_code
      , carrier_id
      , mode_of_transport
      , service_level
      , ship_method_code
--      , track_only_flag,
      , consignee_carrier_ac_no
      , freight_terms_code
      , Load_tender_status
      , lane_id
      , rank_id
    FROM WSH_TRIPS
    WHERE trip_id = c_tripid;

-- Cursor to get stop level information
    CURSOR c_get_trip_stops(c_tripid IN NUMBER) is
    SELECT wts.STOP_ID
      , wts.TRIP_ID
      --To handle dummy locations #DUM_LOC(S)
      , wts.STOP_LOCATION_ID
      , wts.STATUS_CODE
      , wts.STOP_SEQUENCE_NUMBER
      , wts.PLANNED_ARRIVAL_DATE
      , wts.PLANNED_DEPARTURE_DATE
      , wts.ACTUAL_ARRIVAL_DATE
      , wts.ACTUAL_DEPARTURE_DATE
      --#DUM_LOC(S)
      , wts.PHYSICAL_LOCATION_ID
      --#DUM_LOC(E)
      , wts.PHYSICAL_STOP_ID
      , wts.pick_up_weight
      , wts.weight_uom_code
      , wts.pick_up_volume
      , wts.volume_uom_code
    FROM wsh_trip_stops wts
    WHERE wts.trip_id = c_tripid
    order by wts.STOP_SEQUENCE_NUMBER;

    CURSOR c_get_firststop_dlvy(c_stop_id IN NUMBER) IS
    SELECT wnd.DELIVERY_ID
      , wnd.CUSTOMER_ID
      , wnd.ORGANIZATION_ID
    FROM wsh_new_deliveries wnd,
         wsh_delivery_legs wdl,
         wsh_trip_stops wts1
    WHERE wnd.delivery_id = wdl.delivery_id
    AND   wdl.pick_up_stop_id = wts1.stop_id
    AND   wnd.initial_pickup_location_id = wts1.stop_location_id
    AND   nvl(wnd.shipping_control,'BUYER') <> 'SUPPLIER'
    AND   wts1.stop_id = c_stop_id;

    CURSOR c_get_laststop_dlvy(c_stop_id IN NUMBER) IS
    SELECT wnd.DELIVERY_ID
      , wnd.CUSTOMER_ID
      , wnd.ORGANIZATION_ID
    FROM wsh_new_deliveries wnd,
         wsh_delivery_legs wdl,
         wsh_trip_stops wts1
    WHERE wnd.delivery_id = wdl.delivery_id
    AND   wdl.drop_off_stop_id = wts1.stop_id
    AND   wnd.ultimate_dropoff_location_id = wts1.stop_location_id
    AND   nvl(wnd.shipping_control,'BUYER') <> 'SUPPLIER'
    AND   wts1.stop_id = c_stop_id;

/*
    CURSOR c_get_trip_cmove(c_trip_id IN NUMBER) IS
    SELECT MOVE_ID
    FROM   FTE_TRIP_MOVES
    WHERE  TRIP_ID = c_trip_id;
*/

CURSOR c_ship_to_site_use(c_location_id IN NUMBER) IS
SELECT SITE.SITE_USE_ID
FROM HZ_CUST_ACCT_SITES_ALL     ACCT_SITE,
 HZ_PARTY_SITES             PARTY_SITE,
 HZ_LOCATIONS               LOC,
 HZ_CUST_SITE_USES_ALL      SITE
WHERE
 SITE.SITE_USE_CODE = 'SHIP_TO'
 AND SITE.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID
 AND ACCT_SITE.PARTY_SITE_ID    = PARTY_SITE.PARTY_SITE_ID
 AND PARTY_SITE.LOCATION_ID     = LOC.LOCATION_ID
 AND LOC.LOCATION_ID = c_location_id;

--l_global_parameters       WSH_SHIPPING_PARAMS_PVT.Global_Parameters_Rec_Typ;

l_cs_trip_rec            cs_trip_rec_type;
l_cs_tripstops_tab       cs_stop_tab_type;
--l_stop_dlvy_tab          stop_delivery_tab_type;

i                NUMBER := 0;
j                NUMBER := 0;
rec_cnt                NUMBER := 0;
inp_itr                NUMBER := 0;
list_cnt               NUMBER := 0;
l_trip_id              NUMBER := 0;
l_rank_id              NUMBER := 0;
l_move_id              NUMBER := 0;
l_prev_trip_id         NUMBER := 0;
l_trip_result_type     VARCHAR2(30);
l_rank_result_cnt      NUMBER := 0;

l_organization_tab      WSH_UTIL_CORE.id_tab_type;
l_customer_tab          WSH_UTIL_CORE.id_tab_type;
l_organization_id       NUMBER := 0;
l_customer_id           NUMBER := 0;
l_delivery_id           NUMBER := 0;
l_customer_site_id      NUMBER := NULL;
l_rg_trip               BOOLEAN := TRUE;
--l_rg_trip_cnt           NUMBER := 0;
l_stop_organization_id_tab       WSH_UTIL_CORE.id_tab_type;
l_stop_customer_id_tab           WSH_UTIL_CORE.id_tab_type;
l_stop_delivery_id_tab           WSH_UTIL_CORE.id_tab_type;
l_base_weight_uom       VARCHAR2(3);
l_base_volume_uom       VARCHAR2(3);
l_pickup_weight_convert NUMBER := 0;
l_pickup_volume_convert NUMBER := 0;
l_total_pickup_weight   NUMBER := 0;
l_total_pickup_volume   NUMBER := 0;

l_commit                VARCHAR2(100) := FND_API.G_FALSE;
l_init_msg_list         VARCHAR2(100) := FND_API.G_FALSE;

l_trip_in_rec           WSH_TRIPS_GRP.tripInRecType;
l_trip_info_tab         WSH_TRIPS_PVT.Trip_Attr_Tbl_Type;
l_trip_out_rec_tab      WSH_TRIPS_GRP.Trip_Out_Tab_Type;

l_msg_count                   NUMBER;
l_msg_data                    VARCHAR2(2000);
l_return_message              VARCHAR2(2000);
l_return_status               VARCHAR2(1);

l_triporigin_intorg_id        NUMBER := 0;
l_initial_pickup_loc_id       NUMBER := 0;
l_initial_pickup_date         DATE;
l_tripdest_org_id             NUMBER := 0;
l_ultimate_dropoff_loc_id     NUMBER := 0;
l_ultimate_dropoff_date       DATE;

l_trip_rank_array             numtabvc2;


l_ranked_list          WSH_FTE_INTEGRATION.CARRIER_RANK_LIST_TBL_TYPE;
l_cs_input_tab         WSH_FTE_INTEGRATION.wsh_cs_entity_tab_type;
l_cs_result_tab        WSH_FTE_INTEGRATION.wsh_cs_result_tab_type;
l_cs_output_message_tab  WSH_FTE_INTEGRATION.wsh_cs_output_message_tab;

-- Debug Variables
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PROCESS_CARRIER_SELECTION';
BEGIN

      IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
      END IF;

      l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
       --
      IF l_debug_on IS NULL
      THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
      END IF;
      --

      IF l_debug_on THEN
       wsh_debug_sv.push(l_module_name);
       WSH_DEBUG_SV.logmsg(l_module_name,'p_init_msg_list : '||p_init_msg_list);
       WSH_DEBUG_SV.logmsg(l_module_name,'P_CALLER : '||P_CALLER);
      END IF;
      --
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

      SAVEPOINT before_trip_update;

      i := p_trip_id_tab.FIRST;
      IF i IS NOT NULL THEN
      LOOP

         l_rg_trip := TRUE;
         l_cs_tripstops_tab.DELETE;
         l_customer_id := NULL;
         l_triporigin_intorg_id := NULL;
         l_initial_pickup_loc_id := NULL;
         l_initial_pickup_date := NULL;
         l_tripdest_org_id := NULL;
         l_customer_site_id := NULL;
         l_ultimate_dropoff_loc_id := NULL;
         l_ultimate_dropoff_date := NULL;
         l_total_pickup_weight := 0;
         l_base_weight_uom := NULL;
         l_total_pickup_volume := 0;
         l_base_volume_uom := NULL;

         IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'trip_id '|| p_trip_id_tab(i));
         END IF;

         OPEN c_get_trip_details(p_trip_id_tab(i));
         FETCH c_get_trip_details INTO l_cs_trip_rec;
         CLOSE c_get_trip_details;

         -- Perform security checks from the TDD

/*
        Not allowed when

        o	Trip status  IT, CL
        o	Lane assigned
        o	Tender status  Tendered /Accepted
        o	Planning status  Planned, Firmed
        o	Continous Move  Part of

        -- Above handled in is_action_enabled
        -- This API should always be called through group API s


        -- Warning when trip already has an attached ranked list
*/

         OPEN c_get_trip_stops(p_trip_id_tab(i));
         FETCH c_get_trip_stops BULK COLLECT INTO l_cs_tripstops_tab;
         CLOSE c_get_trip_stops;

         IF l_cs_tripstops_tab.COUNT = 0 THEN
            FND_MESSAGE.SET_NAME('WSH','WSH_FTE_SEL_NO_STOPS');
            --FND_MESSAGE.SET_TOKEN('TRIPID',p_trip_id_tab(i));
            --FND_MSG_PUB.ADD;
            x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
            l_rg_trip := FALSE;
            WSH_UTIL_CORE.add_message(x_return_status);
         END IF;

         j:=l_cs_tripstops_tab.FIRST;
         IF j  IS NOT NULL THEN
         LOOP

            l_organization_id := NULL;
            IF l_base_weight_uom IS NULL THEN
               l_base_weight_uom := l_cs_tripstops_tab(j).weight_uom_code;
            END IF;

            IF l_base_volume_uom IS NULL THEN
               l_base_volume_uom := l_cs_tripstops_tab(j).volume_uom_code;
            END IF;
         -- Sum up pickup weight / volume of all stops / deliveries in this trip

            IF nvl(l_cs_tripstops_tab(j).PICK_UP_WEIGHT,0) <> 0 THEN

             IF l_cs_tripstops_tab(j).weight_uom_code <> l_base_weight_uom THEN
               l_pickup_weight_convert := WSH_WV_UTILS.Convert_Uom(
                                           from_uom => l_cs_tripstops_tab(j).weight_uom_code,
                                           to_uom   => l_base_weight_uom,
                                           quantity => l_cs_tripstops_tab(j).PICK_UP_WEIGHT);
             ELSE
               l_pickup_weight_convert := l_cs_tripstops_tab(j).PICK_UP_WEIGHT;
             END IF;
             l_total_pickup_weight := l_total_pickup_weight + l_pickup_weight_convert;
            END IF;

            IF nvl(l_cs_tripstops_tab(j).PICK_UP_volume,0) <> 0 THEN

             IF l_cs_tripstops_tab(j).volume_uom_code <> l_base_volume_uom THEN
               l_pickup_volume_convert := WSH_WV_UTILS.Convert_Uom(
                                           from_uom => l_cs_tripstops_tab(j).volume_uom_code,
                                           to_uom   => l_base_volume_uom,
                                           quantity => l_cs_tripstops_tab(j).PICK_UP_volume);
             ELSE
               l_pickup_volume_convert := l_cs_tripstops_tab(j).PICK_UP_volume;
             END IF;

               l_total_pickup_volume := l_total_pickup_volume + l_pickup_volume_convert;
            END IF;

            IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'stop_id '|| l_cs_tripstops_tab(j).stop_id);
                  WSH_DEBUG_SV.logmsg(l_module_name,'l_pickup_weight_convert '|| l_pickup_weight_convert);
                  WSH_DEBUG_SV.logmsg(l_module_name,'l_pickup_volume_convert '|| l_pickup_volume_convert);
                  WSH_DEBUG_SV.logmsg(l_module_name,'volume_uom_code '|| l_cs_tripstops_tab(j).volume_uom_code);
                  WSH_DEBUG_SV.logmsg(l_module_name,'l_base_volume_uom '|| l_base_volume_uom);
                  WSH_DEBUG_SV.logmsg(l_module_name,'weight_uom_code '|| l_cs_tripstops_tab(j).weight_uom_code);
                  WSH_DEBUG_SV.logmsg(l_module_name,'l_base_weight_uom '|| l_base_weight_uom);
             END IF;
         -- triporigin_internalorg_id is that of first stop / any delivery being picked up at the first stop of the trip
         -- organization_id is that of last stop / any delivery being dropped off at the last stop of the trip

            IF j IN (l_cs_tripstops_tab.FIRST,l_cs_tripstops_tab.LAST) THEN

               WSH_UTIL_CORE.get_org_from_location(
                   p_location_id         => nvl(l_cs_tripstops_tab(j).physical_location_id,l_cs_tripstops_tab(j).stop_location_id),
                   x_organization_tab    => l_organization_tab,
                   x_return_status       => l_return_status);

               /* If l_organization_tab.COUNT = 0 no organization_id is passed*/
               IF l_organization_tab.COUNT > 1 THEN
                  -- Get the organization_id of any delivery having initial_pick_up_loc_id / ultimate_dropoff_loc_id
                  -- at this location
                  -- If there are multiple organizations, use the first one obtained
                  IF j = l_cs_tripstops_tab.FIRST THEN
                     OPEN c_get_firststop_dlvy(l_cs_tripstops_tab(j).stop_id);
                     --FETCH c_get_firststop_dlvy BULK COLLECT INTO l_stop_dlvy_tab;
                     FETCH c_get_firststop_dlvy BULK COLLECT INTO l_stop_delivery_id_tab,l_stop_customer_id_tab,l_stop_organization_id_tab;
                     CLOSE c_get_firststop_dlvy;

                     --IF l_stop_dlvy_tab.COUNT > 0 THEN
                     IF l_stop_delivery_id_tab.COUNT > 0 THEN
                        --l_organization_id := l_stop_dlvy_tab(1).organization_id;
                        l_organization_id := l_stop_organization_id_tab(1);
                     ELSE
                        l_organization_id := l_organization_tab(1);
                     END IF;

                  ELSIF j = l_cs_tripstops_tab.LAST THEN
                     OPEN c_get_laststop_dlvy(l_cs_tripstops_tab(j).stop_id);
                     --FETCH c_get_laststop_dlvy BULK COLLECT INTO l_stop_dlvy_tab;
                     FETCH c_get_laststop_dlvy BULK COLLECT INTO l_stop_delivery_id_tab,l_stop_customer_id_tab,l_stop_organization_id_tab;
                     CLOSE c_get_laststop_dlvy;

                     --IF l_stop_dlvy_tab.COUNT > 0 THEN
                     IF l_stop_delivery_id_tab.COUNT > 0 THEN
                        --l_organization_id := l_stop_dlvy_tab(1).organization_id;
                        l_organization_id := l_stop_organization_id_tab(1);
                     ELSE
                        l_organization_id := l_organization_tab(1);
                     END IF;

                  END IF;

               ELSIF l_organization_tab.COUNT = 1 THEN
                  l_organization_id := l_organization_tab(1);
               END IF;

         -- customer_id is ship to customer_id (owner) of the last stop  (Only if it is a customer location)
         -- pickup_date and dropoff_date are the planned_departure and planned_arrival_dates of first and last stop

               --l_stop_dlvy_tab.DELETE;
               l_stop_delivery_id_tab.DELETE;
               l_stop_customer_id_tab.DELETE;
               l_stop_organization_id_tab.DELETE;

               -- Populate triporigin_internalorg_id OR organization_id
               IF j = l_cs_tripstops_tab.FIRST THEN
                  l_triporigin_intorg_id := l_organization_id;
                  l_initial_pickup_loc_id := nvl(l_cs_tripstops_tab(j).physical_location_id,l_cs_tripstops_tab(j).stop_location_id);
                  l_initial_pickup_date := l_cs_tripstops_tab(j).planned_departure_date;
               ELSIF j = l_cs_tripstops_tab.LAST THEN
                  l_tripdest_org_id := l_organization_id;
                  l_ultimate_dropoff_loc_id := nvl(l_cs_tripstops_tab(j).physical_location_id,l_cs_tripstops_tab(j).stop_location_id);
                  l_ultimate_dropoff_date := l_cs_tripstops_tab(j).planned_arrival_date;

                  WSH_UTIL_CORE.get_customer_from_loc(
                      p_location_id    => nvl(l_cs_tripstops_tab(j).physical_location_id,l_cs_tripstops_tab(j).stop_location_id),
                      x_customer_id_tab   => l_customer_tab,
                      x_return_status  => l_return_status);

                  /* If l_customer_tab.COUNT = 0 no customer_id is passed*/
                  IF l_customer_tab.COUNT > 1 THEN
                    -- Get the customer_id of any delivery having ultimate_dropoff_loc_id
                    -- at this location
                    -- If there are multiple customers, use the first one obtained

                     OPEN c_get_laststop_dlvy(l_cs_tripstops_tab(j).stop_id);
                     --FETCH c_get_laststop_dlvy BULK COLLECT INTO l_stop_dlvy_tab;
                     FETCH c_get_laststop_dlvy BULK COLLECT INTO l_stop_delivery_id_tab,l_stop_customer_id_tab,l_stop_organization_id_tab;
                     CLOSE c_get_laststop_dlvy;

                     --IF l_stop_dlvy_tab.COUNT > 0 THEN
                     IF l_stop_delivery_id_tab.COUNT > 0 THEN
                        --l_customer_id := l_stop_dlvy_tab(1).customer_id;
                        l_customer_id := l_stop_customer_id_tab(1);
                     ELSE
                        l_customer_id := l_customer_tab(1);
                     END IF;

                  ELSIF l_customer_tab.COUNT = 1 THEN
                     l_customer_id := l_customer_tab(1);
                  END IF;

                  --l_cs_input_tab(i).customer_id := l_customer_id;

               END IF;

            END IF;

            EXIT WHEN j = l_cs_tripstops_tab.LAST;
            j := l_cs_tripstops_tab.NEXT(j);

         END LOOP;
         --END IF;

         --
         --Determine the ship to site id.
         --

         OPEN c_ship_to_site_use(l_ultimate_dropoff_loc_id);
         FETCH c_ship_to_site_use INTO l_customer_site_id;
         IF c_ship_to_site_use%NOTFOUND THEN
          IF l_customer_id IS NOT NULL THEN
            FND_MESSAGE.SET_NAME('WSH','WSH_LOCATION_NO_SITE');
            --FND_MESSAGE.Set_Token('LOCATION',l_ultimate_dropoff_loc_id);
            FND_MESSAGE.Set_Token('TRIPNAME',l_cs_trip_rec.trip_name);
            x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
            l_rg_trip := FALSE;
          ELSE
            l_customer_site_id := NULL;
          END IF;
         END IF;
         CLOSE c_ship_to_site_use;

         IF l_rg_trip THEN

         --l_rg_trip_cnt := l_rg_trip_cnt + 1;
         IF l_cs_trip_rec.rank_id IS NOT NULL THEN
            l_trip_rank_array(TO_CHAR(l_cs_trip_rec.trip_id, g_int_mask)) := l_cs_trip_rec.rank_id;
         ELSE
            l_trip_rank_array(TO_CHAR(l_cs_trip_rec.trip_id, g_int_mask)) := NULL;
            --l_trip_rank_array(l_cs_trip_rec.trip_id) := NULL;
         END IF;

         -- freight_terms will not be used as an input for trip level call

         -- Populate into l_cs_input_tab
         -- only those trips which have non zero stops

         inp_itr := l_cs_input_tab.COUNT + 1;

         l_cs_input_tab(inp_itr).trip_id      := l_cs_trip_rec.trip_id; -- If input is trip
         l_cs_input_tab(inp_itr).trip_name    := l_cs_trip_rec.trip_name;
         --l_cs_input_tab(inp_itr).freight_terms_code   := l_cs_trip_rec.freight_terms_code;
         -- Stop level Info
         l_cs_input_tab(inp_itr).customer_id := l_customer_id;
         l_cs_input_tab(inp_itr).triporigin_internalorg_id := l_triporigin_intorg_id;
         l_cs_input_tab(inp_itr).initial_pickup_loc_id := l_initial_pickup_loc_id;
         l_cs_input_tab(inp_itr).initial_pickup_date := l_initial_pickup_date;
         l_cs_input_tab(inp_itr).organization_id := l_tripdest_org_id;
         l_cs_input_tab(inp_itr).customer_site_id := l_customer_site_id;
         l_cs_input_tab(inp_itr).ultimate_dropoff_loc_id := l_ultimate_dropoff_loc_id;
         l_cs_input_tab(inp_itr).ultimate_dropoff_date := l_ultimate_dropoff_date;
         l_cs_input_tab(inp_itr).gross_weight := l_total_pickup_weight;
         l_cs_input_tab(inp_itr).weight_uom_code  := l_base_weight_uom;
         l_cs_input_tab(inp_itr).volume       := l_total_pickup_volume;
         l_cs_input_tab(inp_itr).volume_uom_code  := l_base_volume_uom;

         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'trip_id '|| l_cs_input_tab(inp_itr).trip_id);
            WSH_DEBUG_SV.logmsg(l_module_name,'name '|| l_cs_input_tab(inp_itr).trip_name);
            --WSH_DEBUG_SV.logmsg(l_module_name,'freight_terms_code '|| l_cs_input_tab(inp_itr).freight_terms_code);
            WSH_DEBUG_SV.logmsg(l_module_name,'triporigin_internalorg_id '|| l_cs_input_tab(inp_itr).triporigin_internalorg_id);
            WSH_DEBUG_SV.logmsg(l_module_name,'initial_pickup_loc_id '|| l_cs_input_tab(inp_itr).initial_pickup_loc_id);
            WSH_DEBUG_SV.logmsg(l_module_name,'initial_pickup_date '|| l_cs_input_tab(inp_itr).initial_pickup_date);
            WSH_DEBUG_SV.logmsg(l_module_name,'customer_site_id '|| l_cs_input_tab(inp_itr).customer_site_id);
            WSH_DEBUG_SV.logmsg(l_module_name,'ultimate_dropoff_loc_id '|| l_cs_input_tab(inp_itr).ultimate_dropoff_loc_id);
            WSH_DEBUG_SV.logmsg(l_module_name,'customer_id '|| l_cs_input_tab(inp_itr).customer_id);
            WSH_DEBUG_SV.logmsg(l_module_name,'organization_id '|| l_cs_input_tab(inp_itr).organization_id);
            WSH_DEBUG_SV.logmsg(l_module_name,'ultimate_dropoff_date '|| l_cs_input_tab(inp_itr).ultimate_dropoff_date);
            WSH_DEBUG_SV.logmsg(l_module_name,'gross_weight '|| l_cs_input_tab(inp_itr).gross_weight);
            WSH_DEBUG_SV.logmsg(l_module_name,'weight_uom_code '|| l_cs_input_tab(inp_itr).weight_uom_code);
            WSH_DEBUG_SV.logmsg(l_module_name,'volume '|| l_cs_input_tab(inp_itr).volume);
            WSH_DEBUG_SV.logmsg(l_module_name,'volume_uom_code '|| l_cs_input_tab(inp_itr).volume_uom_code);
         END IF;

         END IF; -- l_rg_trip
         END IF;


         EXIT WHEN i = p_trip_id_tab.LAST;
         i := p_trip_id_tab.NEXT(i);

      END LOOP;
      END IF;

      -- Call Carrier Selection Engine
      -- TODO only if there are atleast one eligible trips

      IF l_cs_input_tab.COUNT > 0 THEN

      WSH_FTE_INTEGRATION.CARRIER_SELECTION(
                                          p_format_cs_tab           => l_cs_input_tab,
                                          p_messaging_yn            => 'Y',
                                          p_caller                  => p_caller,
                                          p_entity                  => 'TRIP',
                                          x_cs_output_tab           => l_cs_result_tab,
                                          x_cs_output_message_tab   => l_cs_output_message_tab,
                                          x_return_message          => l_return_message,
                                          x_return_status           => l_return_status);

      -- Handle results (Error out if multileg)

      IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_SUCCESS,WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN

       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'l_cs_result_tab.COUNT is '|| l_cs_result_tab.COUNT);
       END IF;
       IF (l_cs_result_tab.COUNT > 0)  THEN

         rec_cnt := l_cs_result_tab.FIRST;

         -- Loop through result tab in order to update trip for each trip

         -- l_cs_result_tab is ordered by trip_id, rank/leg_sequence
         -- There is one record in l_cs_result_tab per rank / leg output

         l_prev_trip_id := -1;
         list_cnt := 0;
         l_rank_result_cnt := 0;
         IF rec_cnt IS NOT NULL THEN
            LOOP
            --{
               l_trip_id := l_cs_result_tab(rec_cnt).trip_id;
               l_trip_result_type := l_cs_result_tab(rec_cnt).result_type;
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'l_trip_id is '|| l_trip_id);
                  WSH_DEBUG_SV.logmsg(l_module_name,'l_trip_result_type is '|| l_trip_result_type);
                  WSH_DEBUG_SV.logmsg(l_module_name,'rule_id is '|| l_cs_result_tab(rec_cnt).rule_id);
               END IF;

               IF l_trip_result_type = 'MULTILEG' THEN
                  IF l_trip_id <> l_prev_trip_id THEN
                     FND_MESSAGE.SET_NAME('WSH','WSH_FTE_CS_MULTILEG_TRIP');
                     FND_MESSAGE.SET_TOKEN('TRIPID',l_trip_id);
                     --FND_MSG_PUB.ADD;
                     x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
                     WSH_UTIL_CORE.add_message(x_return_status);
                  END IF;
               ELSIF l_trip_result_type = 'RANK' THEN
                  l_rank_result_cnt := l_rank_result_cnt + 1;
                  IF l_trip_id <> l_prev_trip_id THEN

                        -- Warning when trip already has an attached ranked list

                        --IF l_trip_rank_array(l_trip_id) IS NOT NULL THEN
                        IF l_trip_rank_array(TO_CHAR(l_trip_id, g_int_mask)) IS NOT NULL THEN
                           FND_MESSAGE.SET_NAME('WSH','WSH_FTE_CS_UPD_TRIP_RANK_LIST');
                           FND_MESSAGE.SET_TOKEN('TRIPID',l_trip_id);
                           --FND_MSG_PUB.ADD;
                           IF l_debug_on THEN
                              WSH_DEBUG_SV.logmsg(l_module_name,'Trip already has a ranked list ');
                           END IF;
                           x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
                           WSH_UTIL_CORE.add_message(x_return_status);
                        END IF;

                      --IF (l_cs_result_tab(rec_cnt).rank = 1) THEN
                        -- Has to update trip
                        -- Call WSH_TRIPS_GRP.create_update_trip to update trip if required

                        -- AG
                        l_trip_info_tab.DELETE;
                        --l_trip_in_rec.caller      := 'FTE_CARRIER_SELECTION_FORM';
                        -- AG bug found in local UT
                        l_trip_in_rec.caller      := 'FTE_ROUTING_GUIDE';
                        l_trip_in_rec.phase       := null;
                        l_trip_in_rec.action_code := 'UPDATE';

                        WSH_TRIPS_PVT.populate_record(
                           p_trip_id       => l_trip_id,
                           x_trip_info     => l_trip_info_tab(1),
                           x_return_status => l_return_status);

                        IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                           WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR))  THEN
                           raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;

                        --l_trip_info_tab(1).trip_id := l_trip_id;
                        -- rank_list_action takes care of updating rank_id for the trip
                        --l_trip_info_tab(1).rank_id := l_ranked_list(1).rank_id;

                        l_trip_info_tab(1).carrier_id := l_cs_result_tab(rec_cnt).carrier_id;
                        l_trip_info_tab(1).mode_of_transport := l_cs_result_tab(rec_cnt).mode_of_transport;
                        l_trip_info_tab(1).service_level := l_cs_result_tab(rec_cnt).service_level;
                        l_trip_info_tab(1).ship_method_code := l_cs_result_tab(rec_cnt).ship_method_code;
                        l_trip_info_tab(1).consignee_carrier_ac_no := l_cs_result_tab(rec_cnt).consignee_carrier_ac_no;
                        l_trip_info_tab(1).freight_terms_code := l_cs_result_tab(rec_cnt).freight_terms_code;
                        -- AG
                        l_trip_info_tab(1).routing_rule_id := l_cs_result_tab(rec_cnt).rule_id;
                        l_trip_info_tab(1).append_flag := 'Y';

                        WSH_TRIPS_GRP.Create_Update_Trip(
                          p_api_version_number => 1.0,
                          p_init_msg_list      => l_init_msg_list,
                          p_commit             => l_commit,
                          x_return_status      => l_return_status,
                          x_msg_count          => l_msg_count,
                          x_msg_data           => l_msg_data,
                          p_trip_info_tab      => l_trip_info_tab,
                          p_in_rec             => l_trip_in_rec,
                          x_out_tab            => l_trip_out_rec_tab);

                        --IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
                        IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                           raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;

                      --END IF;

                  END IF;

                  list_cnt := list_cnt + 1;
                  -- Build ranked list structure
                  l_ranked_list(list_cnt).TRIP_ID := l_trip_id;
                  l_ranked_list(list_cnt).SOURCE := 'RG';
                  l_ranked_list(list_cnt).RANK_SEQUENCE := l_cs_result_tab(rec_cnt).rank;
                  l_ranked_list(list_cnt).CARRIER_ID := l_cs_result_tab(rec_cnt).carrier_id;
                  l_ranked_list(list_cnt).SERVICE_LEVEL := l_cs_result_tab(rec_cnt).service_level;
                  l_ranked_list(list_cnt).MODE_OF_TRANSPORT := l_cs_result_tab(rec_cnt).mode_of_transport;
                  l_ranked_list(list_cnt).consignee_carrier_ac_no := l_cs_result_tab(rec_cnt).consignee_carrier_ac_no;
                  l_ranked_list(list_cnt).freight_terms_code := l_cs_result_tab(rec_cnt).freight_terms_code;
                  -- AG
                  l_ranked_list(list_cnt).call_rg_flag := 'N';

                  IF l_trip_id <> l_prev_trip_id THEN
                  --IF (l_cs_result_tab(rec_cnt).rank = 1) THEN
                     l_ranked_list(list_cnt).IS_CURRENT := 'Y';
                  ELSE
                     l_ranked_list(list_cnt).IS_CURRENT := 'N';
                  END IF;

                  IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'trip_id '|| l_trip_id);
                    WSH_DEBUG_SV.logmsg(l_module_name,'rank sequence '|| l_cs_result_tab(rec_cnt).rank);
                    WSH_DEBUG_SV.logmsg(l_module_name,'carrier_id '|| l_cs_result_tab(rec_cnt).carrier_id);
                    WSH_DEBUG_SV.logmsg(l_module_name,'service_level '|| l_cs_result_tab(rec_cnt).service_level);
                    WSH_DEBUG_SV.logmsg(l_module_name,'mode_of_transport '|| l_cs_result_tab(rec_cnt).mode_of_transport);
                    WSH_DEBUG_SV.logmsg(l_module_name,'consignee_carrier_ac_no '|| l_cs_result_tab(rec_cnt).consignee_carrier_ac_no);
                    WSH_DEBUG_SV.logmsg(l_module_name,'freight_terms_code '|| l_cs_result_tab(rec_cnt).freight_terms_code);
                  END IF;
                  -- For the last record in l_cs_result_tab attach ranked list here

                  -- Replace ranked list if the trip already had a ranked list attached

                  IF (rec_cnt = l_cs_result_tab.LAST) OR
                     (rec_cnt <> l_cs_result_tab.LAST AND l_cs_result_tab(l_cs_result_tab.NEXT(rec_cnt)).trip_id <> l_trip_id) THEN
                  --IF rec_cnt = l_cs_result_tab.LAST THEN

                     -- Call FTE_CARRIER_RANK_LIST_PVT.RANK_LIST_ACTION(

                        WSH_FTE_INTEGRATION.RANK_LIST_ACTION(
                        p_api_version        =>  1.0,
                        p_init_msg_list      =>  FND_API.G_FALSE,
                        x_return_status      =>  l_return_status,
                        x_msg_count          =>  l_msg_count,
                        x_msg_data           =>  l_msg_data,
                        p_action_code        =>  'REPLACE',
                        p_ranklist           =>  l_ranked_list,
                        p_trip_id             =>  l_trip_id,
                        p_rank_id            =>  l_rank_id
                        --x_ranklist           =>  l_ranked_list
                        );
                        IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                           raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                        l_ranked_list.DELETE;
                        list_cnt := 0;
                  END IF;

               END IF;

               l_prev_trip_id := l_trip_id;
           EXIT WHEN rec_cnt = l_cs_result_tab.LAST;
           rec_cnt := l_cs_result_tab.NEXT(rec_cnt);
            --}
          END LOOP;
        END IF;
        IF l_rank_result_cnt = 0 THEN
                  --
                  -- All results found are multileg, return an error
                  --
                  FND_MESSAGE.SET_NAME('WSH','WSH_FTE_CS_NO_RANKED_RESULT');
                  x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
                  WSH_UTIL_CORE.add_message(x_return_status);
                  --
                  -- Debug Statements
                  --
                  IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,  'NO RANKED RESULT FOUND FROM PROCESS CARRIER SELECTION '  );
                  END IF;
                  --

        END IF;
       ELSE -- l_cs_result_tab.COUNT = 0
                  --
                  -- No results at all where found, return a warning
                  --
                  FND_MESSAGE.SET_NAME('WSH','WSH_FTE_CS_NO_CARRIER_SELECTED');
                  x_return_status  := WSH_UTIL_CORE.G_RET_STS_WARNING;
                  WSH_UTIL_CORE.add_message(x_return_status);
                  --
                  -- Debug Statements
                  --
                  IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,  'NO CARRIER FOUND FROM PROCESS CARRIER SELECTION '  );
                  END IF;
                  --
       END IF;
      ELSE
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- TODO
      ELSE -- No eligible trips were found
                  FND_MESSAGE.SET_NAME('WSH','WSH_FTE_CS_NO_VALID_TRIPS');
                  x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
                  WSH_UTIL_CORE.add_message(x_return_status);
                  --
                  -- Debug Statements
                  --
                  IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,  'NO VALID TRIP FOUND FOR PROCESS CARRIER SELECTION '  );
                  END IF;
                  --
      END IF;

      -- Standard call to get message count and if count is 1,
      -- get message info.

      FND_MSG_PUB.Count_And_Get (
       p_count         =>      x_msg_count,
       p_data          =>      x_msg_data ,
       p_encoded       =>      FND_API.G_FALSE );

      IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name,'No. of messages stacked : ',to_char(x_msg_count));
       wsh_debug_sv.pop(l_module_name);
      END IF;

      --

EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO before_trip_update;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --

WHEN others THEN

    ROLLBACK TO before_trip_update;
    IF c_get_trip_details%ISOPEN THEN
       CLOSE c_get_trip_details;
    END IF;
    IF c_get_trip_stops%ISOPEN THEN
       CLOSE c_get_trip_stops;
    END IF;
    IF c_get_firststop_dlvy%ISOPEN THEN
       CLOSE c_get_firststop_dlvy;
    END IF;
    IF c_get_laststop_dlvy%ISOPEN THEN
       CLOSE c_get_laststop_dlvy;
    END IF;
    IF c_ship_to_site_use%ISOPEN THEN
       CLOSE c_ship_to_site_use;
    END IF;
/*
    IF c_get_trip_cmove%ISOPEN THEN
       CLOSE c_get_trip_cmove;
    END IF;
*/

    wsh_util_core.default_handler('WSH_TRIPS_ACTIONS.PROCESS_CARRIER_SELECTION');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END PROCESS_CARRIER_SELECTION;

--------------------------------------------------------------------------------------------
-- Name:       Remove_Consolidation
-- Purpose:    Removes the consolidation delivery from the trip.
--             If p_unassign_all is 'Y', it will also unassign all deliveries
--             from the trip.
--             If p_unassign_all is 'N', it will retain all the content
--             deliveries, directly or indirectly (through consol delivery)
--             assign to the trip, getting rid of the consol deliveries.
-- Parameters:
--             p_trip_id:       Trip that needs its children unassigned from.
--             p_unassign_all: 'Y'/'N'. If 'Y' will unassign all deliveries from
--                             the trip resulting in an empty trip.
--             x_return_status: return status.



PROCEDURE Remove_Consolidation(
                p_trip_id_tab   IN wsh_util_core.id_tab_type,
                p_unassign_all  IN VARCHAR2,
                p_caller        IN VARCHAR2,
                x_return_status OUT NOCOPY VARCHAR2) IS

cursor c_get_trip_deliveries(p_trip_id in number) is
select d.delivery_id, d.delivery_type
from wsh_new_deliveries d, wsh_trip_stops s, wsh_delivery_legs l
where d.delivery_id = l.delivery_id
and   l.pick_up_stop_id = s.stop_id
and   s.trip_id = p_trip_id
order by d.delivery_type;

l_delivery_tab wsh_util_core.id_tab_type;
l_delivery_type_tab wsh_util_core.column_tab_type;
l_consol_delivery_tab wsh_util_core.id_tab_type;
l_content_delivery_tab wsh_util_core.id_tab_type;
l_dummy_tab wsh_util_core.id_tab_type;
j NUMBER := 0;
k NUMBER := 0;

l_num_warnings              NUMBER  := 0;
l_num_errors                NUMBER  := 0;
l_return_status             VARCHAR2(30);


WSH_INVALID_ACTION          EXCEPTION;

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' ||
'Remove_Consolidation';

BEGIN

   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
     wsh_debug_sv.push (l_module_name);
     WSH_DEBUG_SV.log(l_module_name,'p_unassign_all', p_unassign_all);
     WSH_DEBUG_SV.log(l_module_name,'p_caller', p_caller);
   END IF;

   FOR i in 1..p_trip_id_tab.count LOOP

     IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'p_trip_id_tab', p_trip_id_tab(i));
     END IF;
     -- separate the consol deliveries from the content deliveries
     -- that are directly assigned to the trip
     l_delivery_tab.delete;
     l_consol_delivery_tab.delete;
     j := 0;
     k := 0;
     FOR del in c_get_trip_deliveries(p_trip_id_tab(i)) LOOP

         IF del.delivery_type = 'CONSOLIDATION' THEN
            j := j +1;
            l_consol_delivery_tab(j) := del.delivery_id;
         ELSE
            k := k+1;
            l_delivery_tab(k) := del.delivery_id;
         END IF;

     END LOOP;

     -- Unassign the consol deliveries from the trip
     IF (NVL(p_unassign_all, 'N') = 'N') AND l_consol_delivery_tab.count = 0 THEN
        RAISE WSH_INVALID_ACTION;
     END IF;

     FOR i in 1..l_consol_delivery_tab.count LOOP

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERY_ACTIONS.Unassign_Dels_from_Consol_Del',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        WSH_NEW_DELIVERY_ACTIONS.Unassign_Dels_from_Consol_Del(
          p_parent_del     => l_consol_delivery_tab(i),
          p_caller         => p_caller,
          p_del_tab        => l_dummy_tab,
          x_return_status  => l_return_status);

        wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );
     END LOOP;

     -- Unassign the content deliveries that are directly assigned to the trip.

     IF p_unassign_all = 'Y' THEN

        IF l_delivery_tab.count = 0 THEN
           RAISE WSH_INVALID_ACTION;
        END IF;
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_Trips_Actions.Unassign_Trip',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        WSH_Trips_Actions.Unassign_Trip(
                   p_del_rows         => l_delivery_tab,
                   p_trip_id          => p_trip_id_tab(i),
                   x_return_status    => l_return_status);

        wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );
     END IF;

   END LOOP;

   IF l_num_errors > 0
   THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   ELSIF l_num_warnings > 0
   THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
   ELSE
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   END IF;
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
EXCEPTION
  WHEN WSH_INVALID_ACTION THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    --
    -- Debug Statements
    FND_MESSAGE.SET_NAME('WSH','WSH_REMOVE_CONSOL_ERR');
    wsh_util_core.add_message(x_return_status);
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INVALID_ACTION exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_ACTION');
    END IF;

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
    END IF;
  WHEN OTHERS THEN
    wsh_util_core.default_handler('wsh_trips_actions',l_module_name);
      --
    IF l_debug_on THEN
      wsh_debug_sv.pop(l_module_name, 'EXCEPTION:OTHERS');
    END IF;

END Remove_Consolidation;
--

END WSH_TRIPS_ACTIONS;

/
