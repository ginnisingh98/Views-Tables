--------------------------------------------------------
--  DDL for Package Body WSH_TRIP_STOPS_ACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_TRIP_STOPS_ACTIONS" as
/* $Header: WSHSTACB.pls 120.4.12010000.2 2009/12/03 13:05:13 mvudugul ship $ */


--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_TRIP_STOPS_ACTIONS';
--


--OTM R12 Org-Specific. Declare of local procedure.
---------------------------------------------------------------------------
-- PROCEDURE LAST_PICKUP_STOP_CLOSED
--
-- parameters: p_trip_id -> the trip id to check for
--             p_stop_id -> the stop id to check for to skip because
--                          we will set this stop to close since this
--                          is called only in setClose procedure
--             x_last_pickup_stop_closed -> Returns 'Y' if the stop
--             closed is the last pickup stop.
--             x_eligible_for_asr --> Returns 'Y' if the trip information
--             is eligible to be send to OTM.
--             x_return_status --> Returns status of this procedure call.
-- Assumption : p_trip_id and p_stop_id as passed by the calling API
---------------------------------------------------------------------------

PROCEDURE last_pickup_stop_closed
        (p_trip_id                 IN WSH_TRIP_STOPS.TRIP_ID%TYPE,
         p_stop_id                 IN WSH_TRIP_STOPS.STOP_ID%TYPE,
         x_last_pickup_stop_closed OUT NOCOPY VARCHAR2,
         x_eligible_for_asr        OUT NOCOPY VARCHAR2,
         x_return_status           OUT NOCOPY VARCHAR2);
--OTM R12 End

PROCEDURE Confirm_Stop (
                           p_stop_id    IN NUMBER,
                           p_action_flag    IN  VARCHAR2,
                           p_intransit_flag IN  VARCHAR2,
                           p_close_flag    IN   VARCHAR2,
                           p_stage_del_flag   IN   VARCHAR2,
                           p_report_set_id  IN   NUMBER,
                           p_ship_method    IN   VARCHAR2,
                           p_actual_dep_date  IN   DATE,
                           p_bol_flag    IN   VARCHAR2,
                           p_defer_interface_flag  IN VARCHAR2,
                           x_return_status   OUT   NOCOPY VARCHAR2 ) IS


cursor get_pickup_del is
  select dg.delivery_id, st.stop_sequence_number,st.trip_id
  from   wsh_trip_stops st, wsh_delivery_legs dg, wsh_new_deliveries dl
  where  st.stop_id = p_stop_id
  and    dg.delivery_id = dl.delivery_id
  and    st.stop_location_id = dl.initial_pickup_location_id
  and    st.stop_id = dg.pick_up_stop_id
  AND    nvl(dl.shipment_direction,'O') IN ('O','IO')   -- J-IB-NPARIKH
  AND    dl.delivery_type = 'STANDARD' --sperera, MDC
  and    dl.status_code IN ( 'OP', 'PA', 'SA') ;

del_ids         wsh_util_core.id_tab_type;
stop_ids        wsh_util_core.id_tab_type;
dummy_ids       wsh_util_core.id_tab_type;
l_trip_tab      wsh_util_core.id_tab_type;

l_exceptions_tab  wsh_xc_util.XC_TAB_TYPE;
l_exp_logged      BOOLEAN := FALSE;
l_msg_count       NUMBER;
l_msg_data        VARCHAR2(4000);
l_exc_exist       VARCHAR2(1);
l_del_name        VARCHAR2(30);
l_num_warnings                  NUMBER;
l_num_errors                    NUMBER;

l_return_status VARCHAR2(1) := NULL;


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CONFIRM_STOP';
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
    WSH_DEBUG_SV.log(l_module_name,'Stop id'||p_stop_id);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  savepoint sp_confirm_stop ;
  stop_ids.delete;
  stop_ids(1) := p_stop_id;
  -- Get all the Pickup Deliveries
  del_ids.delete;
  FOR del_rec IN get_pickup_del LOOP
    del_ids(del_ids.COUNT + 1) := del_rec.delivery_id ;
    l_trip_tab(l_trip_tab.count + 1) := del_rec.trip_id;
  END LOOP;

  IF del_ids.COUNT <> 0 THEN
    -- Call Confirm_Delivery for del_ids
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Calling WSH_NEW_DELIVERY_ACTIONS.Confirm_Delivery');
    END IF;
    -- We always set the close_trip/set_intransit flags to 'N'
    -- since we manually close the stops if necessary after the
    -- call to confirm_delivery.
    WSH_NEW_DELIVERY_ACTIONS.Confirm_Delivery (
                           p_del_rows              => del_ids,
                           p_action_flag           => p_action_flag,
                           p_intransit_flag        => 'N',
                           p_close_flag            => 'N',
                           p_stage_del_flag        => p_stage_del_flag,
                           p_report_set_id         => p_report_set_id,
                           p_ship_method           => p_ship_method,
                           p_actual_dep_date       => p_actual_dep_date,
                           p_bol_flag              => p_bol_flag,
                           p_mc_bol_flag           => p_bol_flag,
                           p_defer_interface_flag  => p_defer_interface_flag,
                           p_send_945_flag         => NULL,
                           x_return_status         => l_return_status);
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Return status from WSHDEACB.Confirm_Delivery: ' || l_return_status);
    END IF;

    x_return_status := l_return_status ;

     IF x_return_status NOT IN ( WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ) THEN
        -- Bug#5864517: Needs to call Print_Label API irrespective of p_intransit_flag and p_close_flag
        --              flag values.
        -- Call Print Label for WMS
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Calling WSH_UTIL_CORE.Print_Label');
        END IF;
        WSH_UTIL_CORE.Print_Label(p_stop_ids => stop_ids,
                                  p_delivery_ids => dummy_ids,
                                  x_return_status => l_return_status);
        IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'Return status from WSH_UTIL_CORE.Print_Label : ' || l_return_status);
        END IF;
        IF l_return_status NOT IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ) THEN
        --{
            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING AND
                         x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                         x_return_status := l_return_status ;
            END IF;
        ELSE
            x_return_status := l_return_status ;
        --}
        END IF;

    END IF;
    -- Bug#5864517: End

-- Bug 2887720, move End-If back up to correct place
  END IF;


  IF x_return_status NOT IN ( WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ) THEN

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'In-transit flag'||p_intransit_flag);
        WSH_DEBUG_SV.log(l_module_name,'Close flag'||p_close_flag);
      END IF;
      IF p_intransit_flag = 'Y' OR p_close_flag = 'Y' THEN
        -- Call Change_Status for the Stop
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'IN IF CONDITION');
          WSH_DEBUG_SV.log(l_module_name,'Stop id'||stop_ids(1));
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_XC_UTIL.Check_Exceptions',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
         --l_exceptions_tab.delete;        //Commented for bugfix 4017720.
         l_exp_logged      := FALSE;
         l_exc_exist := 'N';

         FOR i in 1..del_ids.count LOOP

         -- Check if at least one delivery on the stop has an ITM exception logged.
         -- At this stage deliveries would have all their exceptions cleaned up
         -- except for ITM exceptions. Do not close stop if an ITM exception
         -- of severity 'ERROR' or 'WARNING' exists against the delivery.
            l_exceptions_tab.delete; --Bugfix 4017720

            WSH_XC_UTIL.Check_Exceptions (
                                        p_api_version           => 1.0,
                                        x_return_status         => l_return_status,
                                        x_msg_count             => l_msg_count,
                                        x_msg_data              => l_msg_data,
                                        p_logging_entity_id     => del_ids(i),
                                        p_logging_entity_name   => 'DELIVERY',
                                        p_consider_content      => 'N',
                                        x_exceptions_tab        => l_exceptions_tab
                                      );
             WSH_UTIL_CORE.api_post_call
                (
                    p_return_status => l_return_status,
                    x_num_warnings  => l_num_warnings,
                    x_num_errors    => l_num_errors
                );

            FOR exp_cnt in 1..l_exceptions_tab.COUNT LOOP
             IF l_exceptions_tab(exp_cnt).exception_behavior in ('ERROR', 'WARNING')  THEN

                l_exc_exist := 'Y';
                l_del_name := WSH_NEW_DELIVERIES_PVT.Get_Name(del_ids(i));
                EXIT;

             END IF;
           END LOOP;
           IF l_exc_exist = 'Y' THEN

              EXIT;

           END IF;

         END LOOP;

        -- Pack J, ITM -- Attempt to close the stop only if there are no  exceptions against it.

        IF l_exc_exist = 'N' THEN


          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Calling WSHSTACB.change_status');
          END IF;


          Change_Status ( p_stop_rows             => stop_ids,
                        p_action                => 'CLOSE',
                        p_actual_date           => p_actual_dep_date,
                        p_defer_interface_flag  => p_defer_interface_flag,
                        x_return_status         => l_return_status);
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Return status from WSHSTACB.change_status : ' || l_return_status);
          END IF;

          IF l_return_status NOT IN
           (WSH_UTIL_CORE.G_RET_STS_ERROR,
            WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ) THEN
            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING AND
               x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
               x_return_status := l_return_status ;
            END IF;

          ELSE
            x_return_status := l_return_status ;
          END IF;
        ELSE  -- If exceptions exist
              -- Bug 3402366, inform user stop will not be closed due to ITM exception
              -- on delivery.

             FND_MESSAGE.SET_NAME('WSH','WSH_EXP_COMPL_SCRN_REQD');
             FND_MESSAGE.SET_TOKEN('DEL_NAME',l_del_name);
             wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_SUCCESS);

        END IF;
      END IF;
  ELSE
    x_return_status := l_return_status ;
  END IF;

  IF x_return_status IN ( WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ) THEN
    rollback to sp_confirm_stop;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Return status from WSHSTACB.Confirm_Stop: '||x_return_status);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN others THEN
    wsh_util_core.default_handler('WSH_TRIP_STOPS_ACTIONS.CONFIRM_STOP');
    rollback to sp_confirm_stop;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Unexpected Error has Occured.Oracle error message is'||SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END;


PROCEDURE Check_Update_Stops (
		p_stop_rows		IN	 wsh_util_core.id_tab_type,
    p_action				IN	VARCHAR2,
--tkt
    p_caller                IN      VARCHAR2,
		x_return_status		OUT NOCOPY 	VARCHAR2) IS

CURSOR stop_info (l_stop_id NUMBER) IS
SELECT trip_id,
	  status_code
FROM   wsh_trip_stops
WHERE  stop_id = l_stop_id;

CURSOR stop_dropoffs (l_stop_id NUMBER) IS
SELECT dl.delivery_id
FROM   wsh_delivery_legs dg,
	   wsh_new_deliveries dl
WHERE  dg.delivery_id = dl.delivery_id AND
	  dg.drop_off_stop_id = l_stop_id AND
	  dl.status_code IN ('OP','PA', 'SA') -- sperera 940/945
			AND nvl(dl.shipment_direction,'O') IN ('O','IO');

CURSOR stop_pickups (l_stop_id NUMBER) IS
SELECT 1 from dual
WHERE exists ( select 1
FROM   wsh_delivery_legs dg,
	   wsh_new_deliveries dl
WHERE  dg.delivery_id = dl.delivery_id
AND	dg.pick_up_stop_id = l_stop_id
AND	dl.status_code in ('OP','PA', 'SA')  -- sperera 940/945
			AND nvl(dl.shipment_direction,'O') IN ('O','IO'));

l_trip_id NUMBER;
l_status_code VARCHAR2(2);
l_old_trip_id NUMBER;
l_old_status_code VARCHAR2(2);
l_del_id	  NUMBER;
l_trip_stop_num NUMBER;
others EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_UPDATE_STOPS';
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

   IF (p_stop_rows.count = 0) THEN
	 RAISE others;
   END IF;

   l_trip_id := NULL;

   FOR i IN 1..p_stop_rows.count LOOP

	 l_trip_id := NULL;

	 OPEN stop_info(p_stop_rows(i));
	 FETCH stop_info INTO l_trip_id, l_status_code;
	 CLOSE stop_info;

	 IF (l_trip_id IS NULL) THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_STOP_NOT_FOUND');
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

	  IF (l_trip_id = l_old_trip_id) THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_STOP_UPDATE_SAME_TRIP');
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

	  IF (l_status_code = 'CL') THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_STOP_INVALID_STATUS');
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--
		FND_MESSAGE.SET_TOKEN('STOP_NAME',wsh_trip_stops_pvt.get_name(p_stop_rows(i),p_caller));
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

	 -- Check if there are any open deliveries dropped off at the stop. The stop
	 -- cannot be arrived or closed if this happens

	  l_del_id := NULL;

	  OPEN  stop_dropoffs (p_stop_rows(i));
	  FETCH stop_dropoffs INTO l_del_id;
	  CLOSE stop_dropoffs;

	  IF (l_del_id IS NOT NULL ) THEN

	 FND_MESSAGE.SET_NAME('WSH','WSH_STOP_PREV_NOT_CLOSED');
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	 END IF;
	 --
	 FND_MESSAGE.SET_TOKEN('STOP_NAME',wsh_trip_stops_pvt.get_name(p_stop_rows(i),p_caller));
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
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
   IF p_action <> 'ARRIVE' THEN
	  OPEN stop_pickups (p_stop_rows(i));
	  FETCH stop_pickups INTO l_trip_stop_num;

	  IF (stop_pickups%FOUND) THEN

		 FND_MESSAGE.SET_NAME('WSH','WSH_STOP_CLOSE_OP_PA_ERROR');
		 --
		 -- Debug Statements
		 --
		 IF l_debug_on THEN
		     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
		 END IF;
		 --
		 FND_MESSAGE.SET_TOKEN('STOP_NAME',wsh_trip_stops_pvt.get_name(p_stop_rows(i),p_caller));
		 x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
		 wsh_util_core.add_message(x_return_status);

	  END IF;
	  CLOSE stop_pickups;
	END IF;
	  l_old_trip_id := l_trip_id;
	  l_old_status_code := l_status_code;

	  <<loop_end>>
	  NULL;

   END LOOP;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
   EXCEPTION
	  WHEN others THEN
		wsh_util_core.default_handler('WSH_TRIP_STOPS_ACTIONS.CHECK_UPDATE');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Check_Update_Stops;

PROCEDURE Change_Status (
		p_stop_rows	 IN	 wsh_util_core.id_tab_type,
		p_action		IN	VARCHAR2,
		p_actual_date  IN   DATE,
		p_defer_interface_flag  IN VARCHAR2, -- bug 1578251
		x_return_status	OUT NOCOPY 	VARCHAR2,
                p_caller IN VARCHAR2) IS


l_return_status VARCHAR2(1);
others			EXCEPTION;
--
--
l_in_rec     WSH_TRIP_STOPS_VALIDATIONS.chkClose_in_rec_type;
l_out_rec    WSH_TRIP_STOPS_VALIDATIONS.chkClose_out_rec_type;
--
l_stopsProcessed                NUMBER;
l_stopsProcessedWarnings        NUMBER;
l_stopsNotProcessedWarnings     NUMBER;
--
l_num_warnings                  NUMBER;
l_num_errors                    NUMBER;
l_num_warnings_bak              NUMBER;
--
i                               NUMBER;
--
l_linked_stop_id                NUMBER;  --wr
-- Exceptions Project
l_msg_count       NUMBER;
l_msg_data        VARCHAR2(4000);
--
l_debug_on BOOLEAN;
--
l_stop_tab WSH_UTIL_CORE.id_tab_type;  -- DBI Project
l_dbi_rs                VARCHAR2(1);   -- DBI Project
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHANGE_STATUS';
l_wf_rs 	VARCHAR2(1);	-- Workflow Project

--
BEGIN
--{
    SAVEPOINT stop_chg_status_begin_sp;
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
       WSH_DEBUG_SV.log(l_module_name,'P_ACTUAL_DATE',P_ACTUAL_DATE);
       WSH_DEBUG_SV.log(l_module_name,'P_DEFER_INTERFACE_FLAG',P_DEFER_INTERFACE_FLAG);
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    l_num_warnings  := 0;
    l_num_errors    := 0;
    --
    l_stopsProcessed             := 0;
    l_stopsProcessedWarnings     := 0;
    l_stopsNotProcessedWarnings  := 0;
    --
    IF (p_stop_rows.count = 0)
    THEN
        RAISE others;
    END IF;
    --

    -- We cannot assume that the table has a gapless index sequence.
    i := p_stop_rows.FIRST;
    WHILE i IS NOT NULL
    LOOP
    --{
        BEGIN
        --{
            savepoint stop_chg_status_sp ;
            --
            l_num_warnings_bak := l_num_warnings;
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_num_warnings_bak',l_num_warnings_bak);
            END IF;
            --

            IF (p_action = 'CLOSE')
            THEN
            --{
                l_in_rec.stop_id      := p_stop_rows(i);
                l_in_rec.put_messages := TRUE;
                l_in_rec.caller       := p_caller;
                l_in_rec.actual_date  := p_actual_date;
                --
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_VALIDATIONS.CHECK_STOP_CLOSE',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                WSH_TRIP_STOPS_VALIDATIONS.check_stop_close
                    (
                        p_in_rec         => l_in_rec,
                        x_out_rec        => l_out_rec,
                        x_return_status  => l_return_status
                    );
                --
                IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                   WSH_DEBUG_SV.log(l_module_name,'l_out_rec.close_Allowed',l_out_rec.close_Allowed);
                END IF;
                --
                WSH_UTIL_CORE.api_post_call
                    (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                    );
                --
                IF l_out_rec.close_Allowed = 'Y'
                THEN
                    NULL;
                ELSIF l_out_rec.close_Allowed = 'YW'
                THEN
                    l_num_warnings := l_num_warnings + 1;
                ELSIF l_out_rec.close_Allowed = 'NW'
                THEN
                    l_num_warnings              := l_num_warnings + 1;
                    l_stopsNotProcessedWarnings := l_stopsNotProcessedWarnings + 1;
                    RAISE wsh_util_core.g_exc_warning;
                ELSE
                    l_num_errors   := l_num_errors   + 1;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
                --
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_ACTIONS.SETCLOSE',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                WSH_TRIP_STOPS_ACTIONS.setClose
                    (
                        p_in_rec                => l_in_rec,
                        p_in_rec1               => l_out_rec,
                        p_defer_interface_flag  => p_defer_interface_flag,
                        x_return_status         => l_return_status
                    );
                --
                WSH_UTIL_CORE.api_post_call
                    (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                    );
                --
                IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'After setclose-l_num_warnings',l_num_warnings);
                END IF;
                --
                --
                IF l_num_warnings > l_num_warnings_bak
                THEN
                    l_stopsProcessedWarnings := l_stopsProcessedWarnings + 1;
                ELSE
                    l_stopsProcessed         := l_stopsProcessed + 1;
                END IF;

                -- Close Exceptions for the Stop and its contents
                IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_XC_UTIL.Close_Exceptions',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                WSH_XC_UTIL.Close_Exceptions (
                                                p_api_version           => 1.0,
                                                x_return_status         => l_return_status,
                                                x_msg_count             => l_msg_count,
                                                x_msg_data              => l_msg_data,
                                                p_logging_entity_id     => p_stop_rows(i),
                                                p_logging_entity_name   => 'STOP',
                                                p_consider_content      => 'Y',
                                                p_caller                => p_caller
                                             ) ;

                WSH_UTIL_CORE.api_post_call
                       (
                           p_return_status => l_return_status,
                           x_num_warnings  => l_num_warnings,
                           x_num_errors    => l_num_errors
                       );
                IF ( l_return_status <>  WSH_UTIL_CORE.G_RET_STS_SUCCESS )  THEN
                     RAISE FND_API.G_EXC_ERROR;
                END IF;

            --}
            ELSIF (p_action = 'ARRIVE')
            THEN
            --{
                l_in_rec.stop_id      := p_stop_rows(i);
                l_in_rec.put_messages := TRUE;
                l_in_rec.caller       := p_caller;
                l_in_rec.actual_date  := p_actual_date;
                --
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_VALIDATIONS.CHECK_STOP_ARRIVE',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                WSH_TRIP_VALIDATIONS.check_stop_arrive
                    (
                        p_stop_id        => p_stop_rows(i),
                        x_linked_stop_id => l_linked_stop_id,  --wr if not null, must be open.
                        x_return_status  => l_return_status
                    );
                --
                --
                WSH_UTIL_CORE.api_post_call
                    (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                    );
                --
                UPDATE  wsh_trip_stops
                SET     status_code         = 'AR',
                        actual_arrival_date = nvl(p_actual_date, SYSDATE)
                WHERE   stop_id IN (p_stop_rows(i), l_linked_stop_id)  --wr
                RETURNING stop_id BULK COLLECT INTO l_stop_tab; -- Added for DBI Project;

   		--
                IF (SQL%NOTFOUND) THEN
                   FND_MESSAGE.SET_NAME('WSH','WSH_STOP_NOT_FOUND');
                   wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR);
                   l_num_errors   := l_num_errors   + 1;
                   RAISE FND_API.G_EXC_ERROR;
                END IF;
                --

		-- Workflow Project
        	-- Raise Stop Status change business event
        	IF l_debug_on THEN
        		WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.RAISE_EVENT',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
        	WSH_WF_STD.RAISE_EVENT( p_entity_type   =>      'STOP',
        	                        p_entity_id     =>      p_stop_rows(i),
                	                p_event         =>      'oracle.apps.wsh.stop.gen.arrived',
             	   	                x_return_status =>      l_wf_rs
                           	      );
                IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_WF_STD.RAISE_EVENT => ',l_wf_rs);
                END IF;

		IF l_linked_stop_id IS NOT NULL THEN
	                IF l_debug_on THEN
        	          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.RAISE_EVENT',WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;
	                WSH_WF_STD.RAISE_EVENT( p_entity_type   =>      'STOP',
		     		                p_entity_id     =>      l_linked_stop_id,
                	                        p_event         =>      'oracle.apps.wsh.stop.gen.arrived',
                        	                x_return_status =>      l_wf_rs
					     );
                	IF l_debug_on THEN
        	          WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_WF_STD.RAISE_EVENT => ',l_wf_rs);
	                END IF;
		END IF;
	        -- End of code for Workflow project

  --
        -- DBI Project
        -- Updating  WSH_TRIP_STOPS.
        -- Call DBI API after the Update.
        -- This API will also check for DBI Installed or not
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Stop Count -',l_stop_tab.count);
        END IF;
        WSH_INTEGRATION.DBI_Update_Trip_Stop_Log
          (p_stop_id_tab	=> l_stop_tab,
           p_dml_type		=> 'UPDATE',
           x_return_status      => l_dbi_rs);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
        END IF;
        IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
	   x_return_status := l_dbi_rs;
           ROLLBACK TO stop_chg_status_sp;
	  -- just pass this return status to caller API
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'DBI API Returned Unexpected error '||x_return_status);
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          return;
       END IF;
        -- End of Code for DBI Project
 --
                --
                IF l_num_warnings > l_num_warnings_bak
                THEN
                    l_stopsProcessedWarnings := l_stopsProcessedWarnings + 1;
                ELSE
                    l_stopsProcessed         := l_stopsProcessed + 1;
                END IF;
            --}
            END IF;
        --}
        EXCEPTION
        --{
            WHEN FND_API.G_EXC_ERROR
            THEN
            --{
                ROLLBACK to stop_chg_status_sp;
                --
                IF p_action = 'CLOSE'
                THEN
                    FND_MESSAGE.SET_NAME('WSH','WSH_STOP_CLOSE_ERROR');
                    FND_MESSAGE.SET_TOKEN('STOP_NAME', l_out_rec.stop_name);
                ELSIF p_action = 'ARRIVE'
                THEN
                    FND_MESSAGE.SET_NAME('WSH','WSH_STOP_ARRIVE_ERROR');
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    FND_MESSAGE.SET_TOKEN('stop_name',wsh_trip_stops_pvt.get_name(p_stop_rows(i),p_caller));
                END IF;
                --
                wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
            --}
            WHEN wsh_util_core.g_exc_warning
            THEN
            --{
                ROLLBACK to stop_chg_status_sp;
                --
                IF p_action = 'CLOSE'
                THEN
                    FND_MESSAGE.SET_NAME('WSH','WSH_STOP_CLOSE_ERROR');
                    FND_MESSAGE.SET_TOKEN('STOP_NAME', l_out_rec.stop_name);
                END IF;
                --
                wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_WARNING,l_module_name);
            --}
        --}
        END;
    --}
        i := p_stop_rows.next(i);
    END LOOP;
   --
    --
    IF l_debug_on THEN
       wsh_debug_sv.log(l_module_name, 'l_stopsProcessed', l_stopsProcessed);
       wsh_debug_sv.log(l_module_name, 'l_stopsProcessedWarnings', l_stopsProcessedWarnings);
       wsh_debug_sv.log(l_module_name, 'l_num_errors', l_num_errors);
       wsh_debug_sv.log(l_module_name, 'l_num_warnings', l_num_warnings);

    END IF;

    IF (l_stopsProcessed = 0 AND l_stopsProcessedWarnings = 0)
    OR l_num_errors     > 0
    THEN
        l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    ELSIF l_stopsProcessedWarnings    > 0
    OR    l_stopsNotProcessedWarnings > 0
    OR    l_num_warnings              > 0
    THEN
        l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    ELSE
        l_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    END IF;
    --
    x_return_status := l_return_status;
    --
    IF  ( p_stop_rows.count > 1 AND l_stopsProcessed <> p_stop_rows.count) OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING)
    THEN
    --{
         IF (p_action = 'CLOSE') THEN
           FND_MESSAGE.SET_NAME('WSH','WSH_STOP_CLOSE_SUMMARY');
         ELSE
           FND_MESSAGE.SET_NAME('WSH','WSH_STOP_ARRIVE_SUMMARY');
         END IF;
         --
         --
         FND_MESSAGE.SET_TOKEN('NUM_ERROR',l_num_errors);
         FND_MESSAGE.SET_TOKEN('NUM_SUCCESS',l_stopsProcessed);
         --
         --
         IF (p_action = 'CLOSE') THEN
           FND_MESSAGE.SET_TOKEN('NUMBER_WARN_ERROR',l_stopsNotProcessedWarnings);
           FND_MESSAGE.SET_TOKEN('NUM_WARN',l_stopsProcessedWarnings);
         ELSE
           FND_MESSAGE.SET_TOKEN('NUM_WARN',l_stopsProcessedWarnings+l_stopsNotProcessedWarnings);
         END IF;
         --
         wsh_util_core.add_message(l_return_status,l_module_name);
    --}
    END IF;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
--}
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO stop_chg_status_begin_sp;
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO stop_chg_status_begin_sp;
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
      --
    WHEN others THEN

      wsh_util_core.default_handler('WSH_NEW_DELIVERY_ACTIONS.CHANGE_STATUS',l_module_name);
      ROLLBACK TO stop_chg_status_begin_sp;
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Change_Status;

--wr removed the old I procedure that had been commented with
--   instructions to remove after ut.

PROCEDURE Plan (
		p_stop_rows			 IN	 wsh_util_core.id_tab_type,
		p_action				IN	VARCHAR2,
                p_caller                IN      VARCHAR2,
		x_return_status		OUT NOCOPY 	VARCHAR2) IS

CURSOR stop_dels (l_stop_id NUMBER) IS
SELECT dg.delivery_id
FROM   wsh_delivery_legs dg
WHERE  dg.pick_up_stop_id = l_stop_id;

CURSOR get_status(l_stop_id NUMBER) IS
select st.status_code, tr.status_code ,
        NVL(st.shipments_type_flag,'O')    -- J-IB-NPARIKH
from wsh_trip_stops st, wsh_trips tr
where st.stop_id = l_stop_id
and st.trip_id = tr.trip_id;

others	  EXCEPTION;

j		   BINARY_INTEGER;
l_num_error BINARY_INTEGER := 0;
l_num_warn  BINARY_INTEGER := 0;
l_del_rows  wsh_util_core.id_tab_type;
l_stop_status VARCHAR2(2);
l_trip_status VARCHAR2(2);
l_stop_id   NUMBER;

invalid_stop exception;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PLAN';
--
l_shipments_type_flag VARCHAR2(30);
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
   IF (p_stop_rows.count = 0) THEN
	 raise others;
   END IF;

   FOR i IN 1..p_stop_rows.count LOOP

	  j := 0;
	  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
          --removed code checking for closed status as now firm/plan/unfirm can be done at any stage

	  FOR s IN stop_dels(p_stop_rows(i)) LOOP

		 j := j + 1;
	 l_del_rows(j) := s.delivery_id;


	  END LOOP;

	  IF (j > 0) THEN
	 IF (p_action = 'PLAN') THEN
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERY_ACTIONS.PLAN',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--
		wsh_new_delivery_actions.plan(l_del_rows, x_return_status);
		 ELSE
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERY_ACTIONS.UNPLAN',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--
		wsh_new_delivery_actions.unplan(l_del_rows, x_return_status);
		 END IF;
	  ELSE
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	  END IF;

	  IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) OR (x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN

	 IF (p_action = 'PLAN') THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_STOP_PLAN_ERROR');
		 ELSE
		FND_MESSAGE.SET_NAME('WSH','WSH_STOP_UNPLAN_ERROR');
		 END IF;

	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	 END IF;
	 --
	 FND_MESSAGE.SET_TOKEN('STOP_NAME',wsh_trip_stops_pvt.get_name(p_stop_rows(i),p_caller));
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	 wsh_util_core.add_message(x_return_status);
	 l_num_error := l_num_error + 1;

	  ELSIF (x_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
	 l_num_warn := l_num_warn + 1;
	  END IF;

   END LOOP;

   IF (p_stop_rows.count > 1) THEN

	  IF (l_num_error > 0) OR (l_num_warn > 0) THEN

	 IF (p_action = 'PLAN') THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_STOP_PLAN_SUMMARY');
		 ELSE
		FND_MESSAGE.SET_NAME('WSH','WSH_STOP_UNPLAN_SUMMARY');
		 END IF;

	 FND_MESSAGE.SET_TOKEN('NUM_ERROR',l_num_error);
	 FND_MESSAGE.SET_TOKEN('NUM_WARN',l_num_warn);
	 FND_MESSAGE.SET_TOKEN('NUM_SUCCESS',p_stop_rows.count - l_num_error - l_num_warn);
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
/*
	 IF (p_stop_rows.count = l_num_error) THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		 ELSE
		x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
		 END IF;
*/
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
	  WHEN invalid_stop then
	  IF (p_action = 'PLAN') THEN
			FND_MESSAGE.SET_NAME('WSH','WSH_STOP_PLAN_ERROR');
		 ELSE
			FND_MESSAGE.SET_NAME('WSH','WSH_STOP_UNPLAN_ERROR');
		 END IF;

		 FND_MESSAGE.SET_TOKEN('STOP_NAME',l_stop_id);
		 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		 wsh_util_core.add_message(x_return_status);
		 --
		 -- Debug Statements
		 --
		 IF l_debug_on THEN
		     WSH_DEBUG_SV.logmsg(l_module_name,'INVALID_STOP exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
		     WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INVALID_STOP');
		 END IF;
		 --
	  WHEN others THEN
		wsh_util_core.default_handler('WSH_TRIP_STOPS_ACTIONS.CHANGE_STATUS');
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




-- Procedure to calculate the Stop departure weight, volume
-- Input parameter stop id, gets trip id and calls the trip weight, volume
-- calculation API (more efficient)

PROCEDURE calc_stop_weight_volume( p_stop_rows IN wsh_util_core.id_tab_type,
				   p_override_flag IN VARCHAR2,
                                   p_calc_wv_if_frozen IN VARCHAR2,
			           x_return_status OUT NOCOPY  VARCHAR2,
--tkt
                                   p_caller        IN      VARCHAR2) IS
dummy_trip_ids wsh_util_core.id_tab_type;
l_stop_name  VARCHAR2(100);
l_override_flag    VARCHAR2(1);
l_suppress_errors  VARCHAR2(1);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CALC_STOP_WEIGHT_VOLUME';
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
END IF;
--
x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   -- bug 2366163: overload p_override_flag 'X' to suppress errors
   IF p_override_flag = 'X' THEN
      l_override_flag   := 'N';
      l_suppress_errors := 'Y';
   ELSE
      l_override_flag   := p_override_flag;
      l_suppress_errors := NULL;
   END IF;

   IF (p_stop_rows.count = 0) THEN
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	 FND_MESSAGE.SET_NAME('WSH','WSH_STOP_NOT_FOUND');
	 wsh_util_core.add_message(x_return_status);
   ELSE

	FOR i IN 1..p_stop_rows.count LOOP

	select trip_id into dummy_trip_ids(i)
	from wsh_trip_stops where stop_id=p_stop_rows(i);
	END LOOP;

   END IF;

--pass trip id for trip weight/vol. calc.
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_ACTIONS.TRIP_WEIGHT_VOLUME',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   wsh_trips_actions.trip_weight_volume(
			p_trip_rows            => dummy_trip_ids,
			p_override_flag        => l_override_flag,
                        p_calc_wv_if_frozen    => p_calc_wv_if_frozen,
			p_start_departure_date => NULL,
			p_suppress_errors      => l_suppress_errors,
                        x_return_status        => x_return_status,
                        p_caller               => p_caller);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
	 WHEN others THEN
		wsh_util_core.default_handler('WSH_TRIP_STOPS_ACTIONS.CALC_STOP_WEIGHT_VOLUME');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END calc_stop_weight_volume;
--
--
-- J-IB-NPARIKH-{
--
--
--========================================================================
-- PROCEDURE : autoCloseOpen
--
-- PARAMETERS: p_in_rec                Input Record  (Refer to WSHSTVLS.pls for description)
--             p_reopenStop            TRUE (open stop)/FALSE (close stop)
--             x_stop_processed        Input Stop was processed i.e. opened/closed. (Y/N)
--             x_return_status         Return status of API
--
-- COMMENT   : This API is used only by inbound logistics functionality during ASN/Receipt
--             integration for automatically closing/opening trip stops.
--             Parameter p_reopenStop will determine whether API will try to perform stop open or close
--             operation.
--
--             It performs following steps:
--             01. Check if stop can be closed or not.
--             02. If yes(even with warning), close the stop if p_reopenStop=FALSE
--                 02.01. Before calling stop close api, calculate stop close date.
--             03. If no(even with warning), open the stop if p_reopenStop=TRUE
--========================================================================
--
PROCEDURE autoCloseOpen
    (
        p_in_rec                IN          WSH_TRIP_STOPS_VALIDATIONS.chkClose_in_rec_type,
        p_reopenStop            IN          BOOLEAN DEFAULT FALSE,
        x_stop_processed        OUT NOCOPY  VARCHAR2,
        x_return_status         OUT NOCOPY  VARCHAR2
    )
IS
--{
    --
    l_return_status         VARCHAR2(1);
    l_num_warnings          NUMBER;
    l_num_errors            NUMBER;
    --
    l_actual_date           DATE    := NULL;
    l_in_rec                WSH_TRIP_STOPS_VALIDATIONS.chkClose_in_rec_type;
    l_out_rec               WSH_TRIP_STOPS_VALIDATIONS.chkClose_out_rec_type;
    --
    l_debug_on              BOOLEAN;
    --
    l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'autoCloseOpen';
    --
--}
BEGIN
--{
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
       WSH_DEBUG_SV.log(l_module_name,'P_in_rec.STOP_ID',P_in_rec.STOP_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_in_rec.put_messages',P_in_rec.put_messages);
       WSH_DEBUG_SV.log(l_module_name,'P_in_rec.caller',P_in_rec.caller);
       WSH_DEBUG_SV.log(l_module_name,'P_in_rec.actual_date',P_in_rec.actual_date);
       WSH_DEBUG_SV.log(l_module_name,'p_reopenStop',p_reopenStop);
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    x_stop_processed   := 'N';
    --
    l_in_rec              := p_in_rec;
    l_in_rec.put_messages := FALSE;
    -- Internal locations changes 10+ for Inbound
    l_in_rec.caller       := 'WSH_IB_'||p_in_rec.caller;
    --
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_in_rec.caller',l_in_rec.caller);
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_VALIDATIONS.CHECK_STOP_CLOSE',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    -- Check if stop can be closed or not.
    --
    WSH_TRIP_STOPS_VALIDATIONS.check_stop_close
        (
            p_in_rec         => l_in_rec,
            x_out_rec        => l_out_rec,
            x_return_status  => l_return_status
        );
    --
    WSH_UTIL_CORE.api_post_call
        (
            p_return_status => l_return_status,
            x_num_warnings  => l_num_warnings,
            x_num_errors    => l_num_errors
        );
    --
    IF l_out_rec.close_Allowed IN ('Y','YW')
    AND NOT(p_reopenStop)
    THEN
    --{
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_VALIDATIONS.get_stop_close_date',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        -- Stop can be closed and input parameter p_reopenStop is FALSE.
        -- First, determine the stop close date
        -- and then call stop close api
        --
        WSH_TRIP_STOPS_VALIDATIONS.get_stop_close_date
            (
                p_trip_id               => l_out_rec.trip_id,
                p_stop_id               => p_in_rec.stop_id,
                p_stop_sequence_number  => l_out_rec.stop_sequence_number,
                x_stop_close_date       => l_actual_date,
                x_return_status         => l_return_status
            );
        --
        WSH_UTIL_CORE.api_post_call
            (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors
            );
        --
        --
        l_in_rec.actual_date       := l_actual_date;
        l_in_rec.put_messages      := TRUE;
        --
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_ACTIONS.setClose',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        WSH_TRIP_STOPS_ACTIONS.setClose
            (
                p_in_rec                => l_in_rec,
                p_in_rec1               => l_out_rec,
                p_defer_interface_flag  => 'Y',
                x_return_status         => l_return_status
            );
        --
        WSH_UTIL_CORE.api_post_call
            (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors
            );
        --
        x_stop_processed   := 'Y';
    --}
    ELSIF p_reopenStop
    AND   l_out_rec.close_Allowed IN ('N','NW')
    THEN
    --{
        --
        -- Stop can not remain closed and input parameter p_reopenStop is TRUE.
        -- Call stop open api
        --
        l_in_rec.put_messages      := TRUE;
        --
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_ACTIONS.setOpen',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        WSH_TRIP_STOPS_ACTIONS.setOpen
            (
                p_in_rec                => l_in_rec,
                p_in_rec1               => l_out_rec,
                x_return_status         => l_return_status
            );
        --
        WSH_UTIL_CORE.api_post_call
            (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors
            );
        --
        x_stop_processed   := 'Y';
    --}
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
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
--}
EXCEPTION
      --
    WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

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

        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
        wsh_util_core.default_handler('WSH_TRIP_STOPS_ACTIONS.autoCloseOpen', l_module_name);
        IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
END autoCloseOpen;

--
--
--========================================================================
-- PROCEDURE : setClose
--
-- PARAMETERS: p_in_rec                Input Record  (Refer to WSHSTVLS.pls for description)
--             p_in_rec1               Input Record  (Refer to WSHSTVLS.pls for description)
--             p_defer_interface_Flag  Defer INV/OM Interface (Y/N)
--             x_return_status         Return status of API
--
-- PRE-REQS  : Caller should set all the attributes of input parameters p_in_rec and p_in_rec1.
--             Typically, this procedure gets called after call to
--             WSH_TRIP_STOPS_VALIDATIONS.check_stop_close, which in turn will set its out
--             parameter x_out_rec which can be passed as input (p_in_rec1) to this API.
--
--
-- COMMENT   : This API performs the stop close operation
--
--             It performs following steps:
--             01. Set deliveries starting from this stop to in-transit.
--             02. Unassign deliveries (starting from this stop) which cannot be set to in-transit
--                 02.01. Mark other delivery legs on this trip as reprice required.
--             03. Update stop status and actual departure date
--             04. Update pending interface flag to Y if it is initial pickup stop for any delivery.
--             05. If FTE is installed and none of the deliveries associated with stop are carrier
--                 manifest enabled, rate the trip (call FTE API)
--             06. If p_defere_interface_flag='N' then interface trip stop to OM and INV
--             07. Set deliveries ending at this stop to closed.
--             08. Change trip status to in-transit, if open. Change trip status to closed,
--                 if all stops closed.
--========================================================================
--
PROCEDURE setClose
    (
        p_in_rec               IN            WSH_TRIP_STOPS_VALIDATIONS.chkClose_in_rec_type,
        p_in_rec1              IN            WSH_TRIP_STOPS_VALIDATIONS.chkClose_out_rec_type,
        p_defer_interface_Flag IN            VARCHAR2,
        x_return_status           OUT NOCOPY VARCHAR2
    )
IS
--{
    -- Unused cursors are removed
    --
    l_return_status            VARCHAR2(1);
    l_num_warnings             NUMBER := 0;
    l_num_errors               NUMBER := 0;
    l_cnt                      NUMBER := 0;
    l_err_cnt                  NUMBER := 0;
    l_index                    NUMBER;
    --
    l_trip_tab                 wsh_util_core.id_tab_type;
    l_err_dlvy_id_tbl          wsh_util_core.id_tab_type;
    l_dlvy_id_tbl              wsh_util_core.id_tab_type;
    l_dlvy_orgid_tbl           wsh_util_core.id_tab_type;
    l_warehouse_type           VARCHAR2(30);
    l_cms_flag                 VARCHAR2(1);
    l_in_rec                   WSH_DELIVERY_VALIDATIONS.ChgStatus_in_rec_type;
    l_trip_in_rec              WSH_TRIP_VALIDATIONS.ChgStatus_in_rec_type;
    l_stop_in_rec              WSH_TRIP_STOPS_VALIDATIONS.chkClose_in_rec_type;
    --
    --
    l_stop_closed              VARCHAR2(10);
    l_stop_opened              VARCHAR2(10);
    l_stop_id                  NUMBER;
    l_stop_locationId          NUMBER;
    --
    l_debug_on                 BOOLEAN;
    --
    l_module_name CONSTANT     VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'setClose';

    l_action_params            WSH_FTE_INTEGRATION.rating_action_param_rec;
    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(2000);
    l_stop_tab                 WSH_UTIL_CORE.id_tab_type;  -- DBI Project
    l_dbi_rs                   VARCHAR2(1);       -- DBI Project
    l_wf_rs		       VARCHAR2(1);	   -- Workflow Project

    --OTM R12, glog proj
    l_last_pickup_stop_closed  VARCHAR2(1);
    l_tms_interface_flag       WSH_NEW_DELIVERIES.TMS_INTERFACE_FLAG%TYPE;
    l_gc3_is_installed         VARCHAR2(1);
    l_loop_counter             NUMBER;
    --

    --OTM R12 Org-Specific start
    l_eligible_for_asr         VARCHAR2(1);
    --
--}
BEGIN
--{
    --SAVEPOINT close_stop_begin_sp;
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
       WSH_DEBUG_SV.log(l_module_name,'P_in_rec.STOP_ID',P_in_rec.STOP_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_in_rec.put_messages',P_in_rec.put_messages);
       WSH_DEBUG_SV.log(l_module_name,'P_in_rec.caller',P_in_rec.caller);
       WSH_DEBUG_SV.log(l_module_name,'P_in_rec.actual_date',P_in_rec.actual_date);
       WSH_DEBUG_SV.log(l_module_name,'P_DEFER_INTERFACE_FLAG',P_DEFER_INTERFACE_FLAG);
       WSH_DEBUG_SV.log(l_module_name,'P_in_rec1.trip_id',P_in_rec1.trip_id);
       WSH_DEBUG_SV.log(l_module_name,'P_in_rec1.service_level',P_in_rec1.service_level);
       WSH_DEBUG_SV.log(l_module_name,'P_in_rec1.carrier_id',P_in_rec1.carrier_id);
       WSH_DEBUG_SV.log(l_module_name,'P_in_rec1.mode_of_transport',P_in_rec1.mode_of_transport);

    END IF;
    --
    x_return_status    := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    --OTM R12, glog proj, use Global Variable
    l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED;

    -- If null, call the function
    IF l_gc3_is_installed IS NULL THEN
      l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED;
    END IF;
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_gc3_is_installed ',l_gc3_is_installed);
    END IF;
    -- end of OTM R12, glog proj

    --
    --
    l_cnt     := 0;
    l_err_cnt := 0;
    l_num_warnings  := 0;
    l_num_errors    := 0;
    --
    -- In parameter will indicate deliveries starting from this stop
    -- loop thro' input delivery id table
    --
    l_index   := p_in_rec1.initial_pu_dlvy_recTbl.id_tbl.FIRST;
    --
    WHILE l_index IS NOT NULL
    LOOP
    --{
        l_in_rec.delivery_id    := p_in_rec1.initial_pu_dlvy_recTbl.id_tbl(l_index);
        l_in_rec.name           := p_in_rec1.initial_pu_dlvy_recTbl.name_tbl(l_index);
        l_in_rec.status_code    := p_in_rec1.initial_pu_dlvy_recTbl.statusCode_tbl(l_index);
        l_in_rec.put_messages   := TRUE; --p_in_rec.put_messages;
        l_in_rec.actual_date    := p_in_rec.actual_date;
        l_in_rec.manual_flag    := 'N';
        l_in_rec.caller         := p_in_rec.caller;
        l_in_rec.stop_id        := p_in_Rec.stop_id;
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit setInTransit',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        -- Set delivery to in-transit.
        --
        WSH_NEW_DELIVERY_ACTIONS.setInTransit
            (
               p_in_rec         => l_in_rec,
               x_return_status  => l_return_status
            );
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
        END IF;
        --
        --
        wsh_util_core.api_post_call
          (
            p_return_status     => l_return_status,
            x_num_warnings      => l_num_warnings,
            x_num_errors        => l_num_errors,
            p_raise_error_flag  => FALSE
          );
        --
        --
        IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
        THEN
        --{
             l_err_cnt := l_err_cnt + 1;
             --
             l_err_dlvy_id_tbl(l_err_cnt) := l_in_rec.delivery_id;
        --}
        ELSE
        --{
             l_cnt := l_cnt + 1;
             --
             l_dlvy_id_tbl(l_cnt)       := l_in_rec.delivery_id;
             l_dlvy_orgid_tbl(l_cnt)    := p_in_rec1.initial_pu_dlvy_recTbl.orgId_tbl(l_index);
        --}
        END IF;
        --
        l_index := p_in_rec1.initial_pu_dlvy_recTbl.id_tbl.NEXT(l_index);
    --}
    END LOOP;
    --
    IF l_cnt = 0
    AND l_err_cnt > 0
    THEN
    --{
        -- None of the candidate deliveries could be set to in-transit. Raise Error
        --
        RAISE FND_API.G_EXC_ERROR;
    --}
    END IF;
    --
    --
    IF p_in_rec1.initial_pu_err_dlvy_id_tbl.COUNT > 0
    THEN
    --{
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_LEGS_ACTIONS.UNASSIGN_DELIVERIES',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        -- Unassign deliveries (which were idenified during check_stop_close routine)
        -- which cannot be set to in-transit, from the trip
        --
        wsh_delivery_legs_actions.unassign_deliveries
            (
                p_del_rows          =>  p_in_rec1.initial_pu_err_dlvy_id_tbl,
                p_trip_id           =>  p_in_rec1.trip_id,
                p_pickup_stop_id    =>  NULL,
                p_dropoff_stop_id   =>  NULL,
                x_return_status     =>  l_return_status
            );
        --
        --
        wsh_util_core.api_post_call
          (
            p_return_status => l_return_status,
            x_num_warnings  => l_num_warnings,
            x_num_errors    => l_num_errors
          );
        --
    --}
    END IF;
    --
    --
    IF l_err_cnt > 0
    THEN
    --{
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_LEGS_ACTIONS.UNASSIGN_DELIVERIES',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        --
        -- Unassign deliveries which cannot be set to in-transit(due to errors
        -- (while setting delivery to in-transit), from the trip
        --
        wsh_delivery_legs_actions.unassign_deliveries
            (
                p_del_rows          =>  l_err_dlvy_id_tbl,
                p_trip_id           =>  p_in_rec1.trip_id,
                p_pickup_stop_id    =>  NULL,
                p_dropoff_stop_id   =>  NULL,
                x_return_status     =>  l_return_status
            );
        --
        wsh_util_core.api_post_call
          (
            p_return_status => l_return_status,
            x_num_warnings  => l_num_warnings,
            x_num_errors    => l_num_errors
          );
        --
    --}
    END IF;
    --
    --
    IF l_err_cnt > 0
    OR p_in_rec1.initial_pu_err_dlvy_id_tbl.COUNT > 0
    THEN
    --{
        l_trip_tab.delete;
        l_trip_tab(1) := p_in_rec1.trip_id;
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_LEGS_ACTIONS.MARK_REPRICE_REQUIRED',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        -- Dellvieries which could not be set to in-transit, were unassigned from trip.
        -- This changed trip contents and hence need to mark other deliveries on trip
        -- as reprice required
        --
        WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required (
             p_entity_type    => 'TRIP',
             p_entity_ids      => l_trip_tab,
             x_return_status  => l_return_status);
        --
        wsh_util_core.api_post_call
          (
            p_return_status => l_return_status,
            x_num_warnings  => l_num_warnings,
            x_num_errors    => l_num_errors
          );
        --
        FND_MESSAGE.SET_NAME('WSH','WSH_STOP_CLOSE_DEL_SUMMARY');
        FND_MESSAGE.SET_TOKEN('STOP_NAME',   p_in_rec1.stop_name);
        FND_MESSAGE.SET_TOKEN('NUM_SUCCESS', l_cnt);
        FND_MESSAGE.SET_TOKEN('NUM_ERROR',   l_err_cnt+p_in_rec1.initial_pu_err_dlvy_id_tbl.COUNT);
        l_num_warnings := l_num_warnings + 1;
        wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_WARNING);
    --}
    END IF;
    --
    IF l_cnt > 0
    THEN
    --{
        IF p_in_rec1.ship_method_code IS NOT NULL
        THEN
        --{
            -- Bug 1783103 and 2699764 :Ship Method and carrier at Ship Confirm is not reflected at Delivery
            -- To update deliveries with the ship method and carrier entered for the trips
            --
            FORALL i IN l_dlvy_id_tbl.FIRST..l_dlvy_id_tbl.LAST
            UPDATE wsh_new_deliveries
            SET    ship_method_code             = p_in_rec1.ship_method_code,
                   carrier_id                   = p_in_rec1.carrier_id,
                   service_level                = p_in_rec1.service_level,
                   mode_of_transport            = p_in_rec1.mode_of_transport,
                   last_update_date             = SYSDATE,
                   last_updated_by              = FND_GLOBAL.USER_ID,
                   last_update_login            = FND_GLOBAL.LOGIN_ID
            WHERE  delivery_id                  = l_dlvy_id_tbl(i)
            AND    NVL(ship_method_code,' ')   <> p_in_rec1.ship_method_code;
        --}
        END IF;
    --}
    END IF;
    --
    --
    -- Here we update the status for any stop and set the pending interface flag to 'Y' if
    -- it is the initial pickup stop of a delivery.
    --

    -- OTM R12, glog proj

    BEGIN--{

      IF (l_gc3_is_installed = 'Y') THEN --{
        --OTM R12 Org-Specific start.
        last_pickup_stop_closed(
                       p_trip_id => p_in_rec1.trip_id
                      ,p_stop_id => p_in_rec.stop_id
                      ,x_last_pickup_stop_closed => l_last_pickup_stop_closed
                      ,x_eligible_for_asr => l_eligible_for_asr
                      ,x_return_status    => l_return_status );
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'x_return_status',l_return_status);
          WSH_DEBUG_SV.log(l_module_name,'l_last_pickup_stop_closed',l_last_pickup_stop_closed);
          WSH_DEBUG_SV.log(l_module_name,'l_eligible_for_asr',l_eligible_for_asr);
        END IF;

        IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                               WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN

          IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'last_pickup_stop_closed return error');
          END IF;
          wsh_util_core.add_message(l_return_status);
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF l_last_pickup_stop_closed = 'Y' AND l_eligible_for_asr = 'Y' THEN --{
          l_tms_interface_flag := WSH_TRIP_STOPS_PVT.C_TMS_ACTUAL_REQUEST;
        ELSE
          l_tms_interface_flag := WSH_TRIP_STOPS_PVT.C_TMS_NOT_TO_BE_SENT;
        END IF; --}
        --OTM R12 End
      END IF; --} -- gc3 is installed
      --

    --
    -- Bug 3901377, actual_arrival_date could have been populated if stop was marked as arrived
    -- before. To preserve that date use an extra NVL
    UPDATE wsh_trip_stops
    SET    pending_interface_flag = DECODE(l_cnt,0,pending_interface_flag,'Y'),
           status_code            = 'CL',
           actual_departure_date  = NVL(p_in_rec.actual_date, SYSDATE),
           actual_arrival_date    = NVL(actual_arrival_date,NVL(p_in_rec.actual_date,SYSDATE)), -- Bug 3901377
           departure_seal_code    = NVL(departure_seal_code,p_in_rec1.trip_seal_code),
           tms_interface_flag     = l_tms_interface_flag, --OTM R12 Org-Specific.
           last_update_date       = sysdate,
           last_updated_by        = FND_GLOBAL.USER_ID,
           last_update_login      = FND_GLOBAL.LOGIN_ID
    WHERE  stop_id                IN (p_in_rec.stop_id,
                                      p_in_rec1.linked_stop_id) --wr
    RETURNING stop_id BULK COLLECT INTO l_stop_tab; -- Added for DBI Project
    --

   IF (SQL%NOTFOUND)
    THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_STOP_NOT_EXIST');
        FND_MESSAGE.SET_TOKEN('STOP_ID',p_in_rec.stop_id);
        wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR);
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    --
    --
    EXCEPTION
      WHEN others THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;--}
    --

	-- Workflow Project
	-- Raise Stop close business event
	IF l_debug_on THEN
	  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.RAISE_EVENT',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	WSH_WF_STD.RAISE_EVENT( p_entity_type   =>      'STOP',
				p_entity_id     =>      p_in_rec.stop_id,
				p_event         =>      'oracle.apps.wsh.stop.gen.closed',
				x_return_status =>      l_wf_rs
			      );
	IF l_debug_on THEN
	  WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_WF_STD.RAISE_EVENT => ',l_wf_rs);
	END IF;

	IF p_in_rec1.linked_stop_id IS NOT NULL THEN
		IF l_debug_on THEN
		  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.RAISE_EVENT',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		WSH_WF_STD.RAISE_EVENT( p_entity_type   =>      'STOP',
					p_entity_id     =>      p_in_rec1.linked_stop_id,
					p_event         =>      'oracle.apps.wsh.stop.gen.closed',
					x_return_status =>      l_wf_rs
				     );
		IF l_debug_on THEN
		  WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_WF_STD.RAISE_EVENT => ',l_wf_rs);
		END IF;
	END IF;
	-- End of code for Workflow project
  --
        -- DBI Project
        -- Updating  WSH_TRIP_STOPS.
        -- Call DBI API after the Update.
        -- This API will also check for DBI Installed or not
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Stop Count -',l_stop_tab.count);
        END IF;
        WSH_INTEGRATION.DBI_Update_Trip_Stop_Log
          (p_stop_id_tab	=> l_stop_tab,
           p_dml_type		=> 'UPDATE',
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
  --

    --
    /*  H integration: Pricing integration csun */
    IF WSH_UTIL_CORE.FTE_Is_Installed = 'Y'
    THEN
    --{
        -- Bug fix 2489164
        -- Find if the deliveries in the stop are carrier manifest enabled
        -- Even if one delivery is carrier manifest enabled, set the flag l_cms_tpw_flag to Y
        --
        l_cms_flag := 'N';
        --
        --
        --
        l_index := l_dlvy_id_tbl.FIRST;
        --
        WHILE l_index IS NOT NULL
        LOOP
        --{
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_EXTERNAL_INTERFACE_SV.GET_WAREHOUSE_TYPE',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            l_warehouse_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type
                                    (
                                         p_organization_id   => l_dlvy_orgid_tbl(l_index),
                                         x_return_status     => l_return_status,
                                         p_delivery_id       => l_dlvy_id_tbl(l_index)
                                    );
            --
            IF l_debug_on THEN
                wsh_debug_sv.log(l_module_name, 'Get WH type ret sts', l_return_status);
                wsh_debug_sv.log(l_module_name, 'Warehouse Type', l_warehouse_type);
            END IF;
            --
            --
            wsh_util_core.api_post_call
              (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors
              );
            --
            IF(nvl(l_warehouse_type, '!') = 'CMS') THEN
                 l_cms_flag := 'Y';
                 exit;
            END IF;
           --
           l_index := l_dlvy_id_tbl.NEXT(l_index);
        --}
        END LOOP;
        --
        --
        l_index := p_in_rec1.ultimate_do_dlvy_recTbl.id_tbl.FIRST;
        --
        WHILE l_index IS NOT NULL
        LOOP
        --{
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_EXTERNAL_INTERFACE_SV.GET_WAREHOUSE_TYPE',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            l_warehouse_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type
                                    (
                                         p_organization_id   => p_in_rec1.ultimate_do_dlvy_recTbl.orgId_tbl(l_index),
                                         x_return_status     => l_return_status,
                                         p_delivery_id       => p_in_rec1.ultimate_do_dlvy_recTbl.id_tbl(l_index)
                                    );
            --
            IF l_debug_on THEN
                wsh_debug_sv.log(l_module_name, 'Get WH type ret sts', l_return_status);
                wsh_debug_sv.log(l_module_name, 'Warehouse Type', l_warehouse_type);
            END IF;
            --
            --
            wsh_util_core.api_post_call
              (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors
              );
            --
            IF(nvl(l_warehouse_type, '!') = 'CMS') THEN
                 l_cms_flag := 'Y';
                 exit;
            END IF;
           --
           l_index := p_in_rec1.ultimate_do_dlvy_recTbl.id_tbl.NEXT(l_index);
        --}
        END LOOP;
        --
        -- Bug fix 2489164
        -- Call Shipment_Price_Consolidate API only for NON carrier manifest enabled cases
        IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name, 'l_cms_flag', l_cms_flag);
            wsh_debug_sv.log(l_module_name, 'WSH_TRIPS_ACTIONS.g_rate_trip_id',WSH_TRIPS_ACTIONS.g_rate_trip_id);
            wsh_debug_sv.log(l_module_name, 'p_in_rec1.trip_id',p_in_rec1.trip_id);
        END IF;
        --

        IF (nvl(WSH_TRIPS_ACTIONS.g_rate_trip_id,-99) <> p_in_rec1.trip_id) THEN --{
        IF ( nvl(l_cms_flag, 'N') = 'N')
           AND p_in_rec1.service_level is not null
           AND p_in_rec1.carrier_id is not null
           AND p_in_rec1.mode_of_transport is not null
        THEN
        -- Bug 3296121  call rate_trip only if all of these fileds are specified
        --{
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_FTE_INTEGRATION.Rate_Trip',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_TRIPS_ACTIONS.g_rate_trip_id := p_in_rec1.trip_id;

            l_action_params.caller := 'WSH';
            l_action_params.event  := 'SHIP-CONFIRM';
            l_action_params.action := 'RATE';
            l_action_params.trip_id_list(1) :=  p_in_rec1.trip_id;
            WSH_FTE_INTEGRATION.Rate_Trip (
               p_api_version        => 1.0,
               p_init_msg_list      => FND_API.G_FALSE,
               p_action_params      => l_action_params,
               p_commit             => FND_API.G_FALSE,
               x_return_status      => l_return_status,
               x_msg_count          => l_msg_count,
               x_msg_data           => l_msg_data);
            --
            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
            THEN
               FND_MESSAGE.SET_NAME('WSH','WSH_PRICE_CNSLD_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('TRIP_NAME',wsh_trips_pvt.get_name(p_in_rec1.trip_id));
               wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR);
               RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR
            -- Bug 3278059, treat warning from rate_trip as success
            THEN
            --{
                l_num_warnings := l_num_warnings + 1;
                --
                FND_MESSAGE.SET_NAME('WSH','WSH_PRICE_CNSLD_ERROR');
                FND_MESSAGE.SET_TOKEN('TRIP_NAME',wsh_trips_pvt.get_name(p_in_rec1.trip_id));
                wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_WARNING,l_module_name);
            --}
            END IF;
        --}
        END IF;
        END IF; --}
    --}
    END IF;
    --
    -- bug 1578251: defer submission of concurrent program to allow batch-processing.
     -- Call INV/OM interface only if atleast one delivery is picked up
           -- and if p_defer_interface_flag = 'N' (bug 1578251)
    /*2848835*/
    --
    --
    IF  l_cnt > 0 -- at least one delivery was set to in-transit
    AND NVL(p_defer_interface_flag, 'Y') = 'N'
    THEN
    --{
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIP_CONFIRM_ACTIONS.SHIP_CONFIRM_A_TRIP_STOP',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_ship_confirm_actions.ship_confirm_a_trip_stop
            (
                p_in_rec.stop_id,
                l_return_status
            );
        --
        IF l_debug_on THEN
          wsh_debug_sv.log(l_module_name, 'Return status ship_confirm_a_trip_stop', l_return_status);
        END IF;
        --
        --
        IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
        THEN
        --{
            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING
            THEN
                l_num_warnings := l_num_warnings + 1;
            ELSE
                l_num_errors   := l_num_errors + 1;
            END IF;
            --
            FND_MESSAGE.SET_NAME('WSH','WSH_STOP_CONFIRM_ERROR');
            FND_MESSAGE.SET_TOKEN('STOP_NAME',p_in_rec1.stop_name);
            FND_MESSAGE.SET_TOKEN('TRIP_NAME',p_in_rec1.trip_name);
            wsh_util_core.add_message(l_return_status,l_module_name);
        --}
        END IF;
    --}
    END IF;
    --
    --
    -- In parameter (p_in_rec1.ultimate_do_dlvy_recTbl) will indicate deliveries ending at this stop
    -- loop thro' input delivery id table
    --
    --
    l_index   := p_in_rec1.ultimate_do_dlvy_recTbl.id_tbl.FIRST;
    --
    WHILE l_index IS NOT NULL
    LOOP
    --{
        l_in_rec.delivery_id    := p_in_rec1.ultimate_do_dlvy_recTbl.id_tbl(l_index);
        l_in_rec.name           := p_in_rec1.ultimate_do_dlvy_recTbl.name_tbl(l_index);
        l_in_rec.status_code    := p_in_rec1.ultimate_do_dlvy_recTbl.statusCode_tbl(l_index);
        l_in_rec.put_messages   := TRUE; --p_in_rec.put_messages;
        l_in_rec.actual_date    := p_in_rec.actual_date;
        l_in_rec.manual_flag    := 'N';
        l_in_rec.caller         := p_in_rec.caller;
        l_in_rec.stop_id        := p_in_Rec.stop_id;
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERY_ACTIONS.setClose',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        -- Set delivery to close
        --
        WSH_NEW_DELIVERY_ACTIONS.setClose
            (
               p_in_rec         => l_in_rec,
               x_return_status  => l_return_status
            );
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
        END IF;
        --
        --
        wsh_util_core.api_post_call
          (
            p_return_status     => l_return_status,
            x_num_warnings      => l_num_warnings,
            x_num_errors        => l_num_errors
          );
        --
        --
        l_index := p_in_rec1.ultimate_do_dlvy_recTbl.id_tbl.NEXT(l_index);
    --}
    END LOOP;
    --
    --
    -- If trip's status has changed (set by caller, typically check_stop_Close)
    -- call API to update trip status
    --
    IF p_in_rec1.trip_status_code <> p_in_rec1.trip_new_status_code
    THEN
    --{
        l_trip_in_rec.trip_id            := p_in_rec1.trip_id;
        l_trip_in_rec.name               := p_in_rec1.trip_name;
        l_trip_in_rec.new_status_code    := p_in_rec1.trip_new_status_code;
        l_trip_in_rec.put_messages       := TRUE; --p_in_rec.put_messages;
        l_trip_in_rec.actual_date        := p_in_rec.actual_date;
        l_trip_in_rec.manual_flag        := 'N';
        l_trip_in_rec.caller             := p_in_rec.caller;
        l_trip_in_rec.stop_id            := p_in_Rec.stop_id;
        --
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_ACTIONS.CHANGESTATUS',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_trips_actions.changeStatus
            (
                p_in_rec        => l_trip_in_rec,
                x_return_status => l_return_status
            );
        --
        wsh_util_core.api_post_call
          (
            p_return_status     => l_return_status,
            x_num_warnings      => l_num_warnings,
            x_num_errors        => l_num_errors
          );
    --}
    END IF;
    --
    l_stop_closed              := 'N';
    --
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
      --
    WHEN FND_API.G_EXC_ERROR THEN
      --ROLLBACK TO close_stop_begin_sp;
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --ROLLBACK TO close_stop_begin_sp;
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
      wsh_util_core.default_handler('WSH_TRIP_STOPS_ACTIONS.setClose',l_module_name);
      --
      --ROLLBACK TO close_stop_begin_sp;
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
END setClose;


--
--
--========================================================================
-- PROCEDURE : setOpen
--
-- PARAMETERS: p_in_rec                Input Record  (Refer to WSHSTVLS.pls for description)
--             p_in_rec1               Input Record  (Refer to WSHSTVLS.pls for description)
--             x_return_status         Return status of API
--
-- PRE-REQS  : Caller should set all the attributes of input parameters p_in_rec and p_in_rec1.
--             Typically, this procedure gets called after call to
--             WSH_TRIP_STOPS_VALIDATIONS.check_stop_close, which in turn will set its out
--             parameter x_out_rec which can be passed as input (p_in_rec1) to this API.
--
--
-- COMMENT   : This API performs the stop open operation. This is only required for
--             inbound logistics functionality while reverting ASN/Receipt or cancelling ASN.
--
--             It performs following steps:
--             01. Update stop status to open and actual departure date to null
--             02. Check the trip status (given by input parameter p_in_rec1.trip_status_code)
--                 02.01 If trip status is Closed, call WSH_TRIP_VALIDATIONS.check_close which
--                       will indicate if trip can be(or remain) closed or not. If not, set trip
--                       status to in-transit.
--                 02.02 If trip status is in-transit, call WSH_TRIP_VALIDATIONS.check_intransit which
--                       will indicate if trip can be(or remain) in-transit or not. If not, set trip
--                       status to open.
--========================================================================
--
PROCEDURE setOpen
    (
        p_in_rec               IN          WSH_TRIP_STOPS_VALIDATIONS.chkClose_in_rec_type,
        p_in_rec1              IN          WSH_TRIP_STOPS_VALIDATIONS.chkClose_out_rec_type,
        x_return_status        OUT NOCOPY  VARCHAR2
    )
IS
--{
    -- Following cursor is not used
    --
    CURSOR next_ib_stops_cur (p_trip_id IN NUMBER, p_stop_sequence_number IN NUMBER)
    IS
        SELECT stop_id, stop_sequence_number,
               NVL(shipments_type_flag,'O') shipments_type_flag
        FROM   wsh_trip_stops
        WHERE  trip_id                      = p_trip_id
        AND    stop_sequence_number         > p_stop_sequence_number
        AND    NVL(shipments_type_flag,'O') IN ( 'I','M')
        AND    status_code                  = 'CL'
        ORDER BY stop_sequence_number;
    --
    --
    -- Following cursor is not used
    --
    CURSOR ib_dropoff_stop_csr(p_pu_stop_id IN NUMBER, p_do_stop_id IN NUMBER)
    IS
        SELECT 1
        FROM   wsh_delivery_legs wdl,
               wsh_new_deliveries wnd
        WHERE  wdl.pick_up_stop_id  = p_pu_stop_id
        AND    wdl.drop_off_stop_id = p_do_stop_id
        AND    wdl.delivery_id      = wnd.delivery_id
        AND    NVL(wnd.shipment_direction,'O') NOT IN ('O','IO')
        AND    rownum = 1;

    -- Following cursor is not used
    --
    CURSOR ib_dlvy_csr(p_stop_id IN NUMBER)
    IS
        SELECT wnd.delivery_id, wts.stop_location_id, wnd.ultimate_dropoff_location_id
        FROM   wsh_delivery_legs wdl,
               wsh_new_deliveries wnd,
               wsh_trip_stops wts
        WHERE  wdl.drop_off_stop_id = p_stop_id
        AND    wts.stop_id          = p_stop_id
        AND    wdl.delivery_id      = wnd.delivery_id
        AND    NVL(wnd.shipment_direction,'O') NOT IN ('O','IO');


    -- Following cursor is not used
    --
    CURSOR next_leg_csr (p_stop_id IN NUMBER, p_delivery_id IN NUMBER) IS
    SELECT next_leg_do_stop.status_code                  do_stop_statusCode,
           NVL(next_leg_do_stop.shipments_type_flag,'O') do_stop_shipTypeFlag,
           next_leg_do_stop.stop_location_id             do_stop_locationId,
           next_leg_do_stop.stop_id                      do_stop_id,
           next_leg_pu_stop.status_code                  pu_stop_statusCode,
           NVL(next_leg_pu_stop.shipments_type_flag,'O') pu_stop_shipTypeFlag,
           next_leg_pu_stop.stop_location_id             pu_stop_locationId,
           next_leg_pu_stop.stop_id                      pu_stop_id,
           NVL(wnd.shipment_direction,'O')               shipment_direction,
           wnd.status_code                               dlvy_status_code,
           wnd.ultimatE_dropoff_location_id              dlvy_ultimate_doLocationId
    FROM   wsh_trip_stops next_leg_do_stop,
           wsh_trip_stops next_leg_pu_stop,
           wsh_trip_stops curr_leg_do_stop,
           wsh_delivery_legs next_leg,
           wsh_delivery_legs curr_leg,
           wsh_new_deliveries wnd
    WHERE  next_leg.drop_off_stop_id         = next_leg_do_stop.stop_id
    --AND    st1.status_code = 'OP'
    AND    next_leg.pick_up_stop_id          = next_leg_pu_stop.stop_id
    AND    next_leg_pu_stop.stop_location_id = curr_leg_do_stop.stop_location_id
    AND    next_leg.delivery_id              = curr_leg.delivery_id
    AND    curr_leg_do_stop.stop_id          = p_stop_id
    AND    curr_leg.drop_off_stop_id         = p_stop_id
    AND    wnd.delivery_id                   = curr_leg.delivery_id
    AND    wnd.delivery_id                   = p_delivery_id;
    --AND    NVL(wnd.shipment_direction,'O') NOT IN ('O','IO')

    --
    --
    l_return_status         VARCHAR2(1);
    l_num_warnings          NUMBER;
    l_num_errors            NUMBER;
    --
    --
    l_trip_Status_code      VARCHAR2(30);
    l_stop_opened           VARCHAR2(10);
    l_allowed               VARCHAR2(10);
    --
    l_trip_in_rec           WSH_TRIP_VALIDATIONS.ChgStatus_in_rec_type;
    l_stop_in_rec           WSH_TRIP_STOPS_VALIDATIONS.chkClose_in_rec_type;
    l_stop_id_tbl           WSH_UTIL_CORE.id_tab_type;
    l_stop_cnt              NUMBER := 0;
    l_index                 NUMBER;
    l_stop_id               NUMBER;
    l_stop_locationId       NUMBER;
    --
    l_debug_on              BOOLEAN;
    --
    l_stop_tab WSH_UTIL_CORE.id_tab_type; -- DBI Project
    l_dbi_rs              VARCHAR2(1);    -- DBI Project
    l_wf_rs		  VARCHAR2(1);    -- Workflow Project
    l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'setOpen';
    --
--}
BEGIN
--{
    --SAVEPOINT open_stop_begin_sp;
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
       WSH_DEBUG_SV.log(l_module_name,'P_in_rec.STOP_ID',P_in_rec.STOP_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_in_rec.put_messages',P_in_rec.put_messages);
       WSH_DEBUG_SV.log(l_module_name,'P_in_rec.caller',P_in_rec.caller);
       WSH_DEBUG_SV.log(l_module_name,'P_in_rec.actual_date',P_in_rec.actual_date);
       WSH_DEBUG_SV.log(l_module_name,'P_in_rec1.trip_status_code',P_in_rec1.trip_status_code);
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    --
    --
    l_num_warnings  := 0;
    l_num_errors    := 0;
    --
    --
    UPDATE wsh_trip_stops
    SET    status_code            = 'OP',
           actual_departure_date  = NULL,
           actual_arrival_date    = NULL, -- Bug 3901377
           --actual_departure_date  = nvl(p_in_rec.actual_date, SYSDATE),
           --departure_seal_code    = NVL(p_in_rec1.trip_seal_code, departure_seal_code),
           last_update_date       = sysdate,
           last_updated_by        = FND_GLOBAL.USER_ID,
           last_update_login      = FND_GLOBAL.LOGIN_ID
    WHERE  stop_id                = p_in_rec.stop_id
    RETURNING stop_id BULK COLLECT INTO l_stop_tab; -- Added for DBI Project;

    --
    IF (SQL%NOTFOUND)
    THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_STOP_NOT_EXIST');
        FND_MESSAGE.SET_TOKEN('STOP_ID',p_in_rec.stop_id);
        wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR);
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    --

	-- Workflow Project
	-- Raise Stop Open business event
	IF l_debug_on THEN
	  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.RAISE_EVENT',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	WSH_WF_STD.RAISE_EVENT( p_entity_type   =>      'STOP',
				p_entity_id     =>      p_in_rec.stop_id,
				p_event         =>      'oracle.apps.wsh.stop.gen.open',
				x_return_status =>      l_wf_rs
			      );
	IF l_debug_on THEN
	  WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_WF_STD.RAISE_EVENT => ',l_wf_rs);
	END IF;
	-- End of code for Workflow project
    --
        -- DBI Project
        -- Updating  WSH_TRIP_STOPS.
        -- Call DBI API after the Update.
        -- This API will also check for DBI Installed or not
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Stop Count -',l_stop_tab.count);
        END IF;
        WSH_INTEGRATION.DBI_Update_Trip_Stop_Log
          (p_stop_id_tab	=> l_stop_tab,
           p_dml_type		=> 'UPDATE',
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
   --

    --
    l_trip_status_code  := p_in_rec1.trip_status_code;
    --
    --
    l_stop_cnt := l_stop_cnt + 1;
    l_stop_id_tbl(l_stop_cnt) := p_in_rec.stop_id;
    --
    --
    --
    l_stop_opened              := 'N';
    --
    FOR next_ib_stops_rec IN next_ib_stops_cur
                                (
                                    p_trip_id               => p_in_rec1.trip_id,
                                    p_stop_sequence_number  => p_in_rec1.stop_sequence_number
                                )
    LOOP
    --{
        IF  next_ib_stops_rec.shipments_type_flag = 'I'
        AND l_stop_opened                         = 'N'
        THEN
        --{
            l_stop_in_rec.stop_id      := next_ib_stops_rec.stop_id;
            l_stop_in_rec.put_messages := FALSE;
            l_stop_in_rec.caller       := p_in_rec.caller;
            l_stop_in_rec.actual_date  := p_in_rec.actual_date;
            --
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_ACTIONS.autoCLOSE',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_TRIP_STOPS_ACTIONS.autoCloseOpen
                (
                    p_in_rec                => l_stop_in_rec,
                    p_reopenStop            => TRUE,
                    x_stop_processed        => l_stop_opened,
                    x_return_status         => l_return_status
                );
            --
            WSH_UTIL_CORE.api_post_call
                (
                    p_return_status => l_return_status,
                    x_num_warnings  => l_num_warnings,
                    x_num_errors    => l_num_errors
                );
        --}
        ELSE
        --{
            FOR ib_dropoff_stop_rec IN ib_dropoff_stop_csr
                                        (
                                            p_pu_stop_id    => p_in_rec.stop_id,
                                            p_do_stop_id    => next_ib_stops_rec.stop_id
                                        )
            LOOP
            --{
                l_stop_cnt := l_stop_cnt + 1;
                l_stop_id_tbl(l_stop_cnt) := next_ib_stops_rec.stop_id;
            --}
            END LOOP;
        --}
        END IF;
				--
				--
        IF l_stop_opened = 'Y'
        THEN
        --{
           EXIT;
        --}
        END IF;
    --}
    END LOOP;
    --
    --
    IF l_stop_opened = 'N'
    THEN
    --{
        IF l_trip_status_code = 'CL'
        THEN
        --{
            --
            -- Trip is Closed, call WSH_TRIP_VALIDATIONS.check_close which will indicate
            -- if trip can be(or remain) closed or not.
            --
            l_trip_in_rec.trip_id            := p_in_rec1.trip_id;
            l_trip_in_rec.name               := p_in_rec1.trip_name;
            l_trip_in_rec.new_status_code    := l_trip_status_code; --p_in_rec1.trip_new_status_code;
            l_trip_in_rec.put_messages       := FALSE; --p_in_rec.put_messages;
            l_trip_in_rec.actual_date        := p_in_rec.actual_date;
            l_trip_in_rec.manual_flag        := 'N';
            l_trip_in_rec.caller             := p_in_rec.caller;
            l_trip_in_rec.stop_id            := NULL; --p_in_Rec.stop_id;
            --
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_VALIDATIONS.check_close',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_TRIP_VALIDATIONS.check_close
                (
                   p_in_rec         => l_trip_in_rec,
                   x_return_status  => l_return_status,
                   x_allowed        => l_Allowed
                );
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                WSH_DEBUG_SV.log(l_module_name,'l_Allowed',l_Allowed);
            END IF;
            --
            wsh_util_core.api_post_call
              (
                p_return_status     => l_return_status,
                x_num_warnings      => l_num_warnings,
                x_num_errors        => l_num_errors
              );
            --
            --IF l_allowed <> 'Y'
            IF l_allowed NOT IN ( 'Y','YW')
            THEN
                l_trip_status_code := 'IT';
            END IF;
        --}
        END IF;
        --
        --
        IF l_trip_status_code = 'IT'
        THEN
        --{

            --
            -- Trip is in-transit, call WSH_TRIP_VALIDATIONS.check_inTransit which will indicate
            -- if trip can be(or remain) in-transit or not.
            --
            l_trip_in_rec.trip_id            := p_in_rec1.trip_id;
            l_trip_in_rec.name               := p_in_rec1.trip_name;
            l_trip_in_rec.new_status_code    := l_trip_status_code; --p_in_rec1.trip_new_status_code;
            l_trip_in_rec.put_messages       := FALSE; --p_in_rec.put_messages;
            l_trip_in_rec.actual_date        := p_in_rec.actual_date;
            l_trip_in_rec.manual_flag        := 'N';
            l_trip_in_rec.caller             := p_in_rec.caller;
            l_trip_in_rec.stop_id            := NULL; --p_in_Rec.stop_id;
            --
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_VALIDATIONS.check_inTransit',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_TRIP_VALIDATIONS.check_inTransit
                (
                   p_in_rec         => l_trip_in_rec,
                   x_return_status  => l_return_status,
                   x_allowed        => l_Allowed
                );
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                WSH_DEBUG_SV.log(l_module_name,'l_Allowed',l_Allowed);
            END IF;
            --
            wsh_util_core.api_post_call
              (
                p_return_status     => l_return_status,
                x_num_warnings      => l_num_warnings,
                x_num_errors        => l_num_errors
              );
            --
            --IF l_allowed <> 'Y'
            IF l_allowed NOT IN ( 'Y','YW')
            THEN
                l_trip_status_code := 'OP';
            END IF;
        --}
        END IF;
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_trip_status_code',l_trip_status_code);
        END IF;
        --
        --
        IF p_in_rec1.trip_status_code <> l_trip_status_code
        THEN
        --{

            l_trip_in_rec.trip_id            := p_in_rec1.trip_id;
            l_trip_in_rec.name               := p_in_rec1.trip_name;
            l_trip_in_rec.new_status_code    := l_trip_status_code;
            l_trip_in_rec.put_messages       := TRUE; --p_in_rec.put_messages;
            l_trip_in_rec.actual_date        := p_in_rec.actual_date;
            l_trip_in_rec.manual_flag        := 'N';
            l_trip_in_rec.caller             := p_in_rec.caller;
            l_trip_in_rec.stop_id            := p_in_Rec.stop_id;
            --
            --
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_ACTIONS.CHANGESTATUS',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            wsh_trips_actions.changeStatus
                (
                    p_in_rec        => l_trip_in_rec,
                    x_return_status => l_return_status
                );
            --
            wsh_util_core.api_post_call
              (
                p_return_status     => l_return_status,
                x_num_warnings      => l_num_warnings,
                x_num_errors        => l_num_errors
              );
        --}
        END IF;
    --}
    END IF;
    --
    --
    --

    l_index := l_stop_id_tbl.FIRST;
    l_stop_opened              := 'N';
    --
    --
    WHILE l_index IS NOT NULL
    LOOP
    --{
        FOR ib_dlvy_rec IN ib_dlvy_csr(l_stop_id_tbl(l_index))
        LOOP
        --{
            l_stop_locationId := ib_dlvy_rec.stop_location_Id;
            l_stop_Id         := l_stop_id_tbl(l_index);
            l_stop_opened              := 'N';
            --
            WHILE l_stop_locationId <> ib_dlvy_rec.ultimate_dropoff_location_id
            AND   l_stop_opened      = 'N'
            LOOP
            --{
                FOR next_leg_rec IN next_leg_csr(l_stop_id, ib_dlvy_rec.delivery_id)
                LOOP
                --{

                    --
                    IF next_leg_rec.pu_stop_shipTypeFlag = 'I'
                    AND next_leg_rec.pu_stop_statusCode   = 'CL'
                    THEN
                    --{
                        l_stop_in_rec.stop_id      := next_leg_rec.pu_stop_id;
                        l_stop_in_rec.put_messages := FALSE;
                        l_stop_in_rec.caller       := p_in_rec.caller;
                        l_stop_in_rec.actual_date  := p_in_rec.actual_date;
                        --
                        --
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_ACTIONS.autoCLOSE',WSH_DEBUG_SV.C_PROC_LEVEL);
                        END IF;
                        --
                        WSH_TRIP_STOPS_ACTIONS.autoCloseOpen
                            (
                                p_in_rec                => l_stop_in_rec,
                                p_reopenStop            => TRUE,
                                x_stop_processed        => l_stop_opened,
                                x_return_status         => l_return_status
                            );
                        --
                        WSH_UTIL_CORE.api_post_call
                            (
                                p_return_status => l_return_status,
                                x_num_warnings  => l_num_warnings,
                                x_num_errors    => l_num_errors
                            );
                    --}
                    END IF;
                    --
                    IF  l_stop_opened = 'N'
                    AND next_leg_rec.do_stop_shipTypeFlag = 'I'
                    AND next_leg_rec.do_stop_statusCode   = 'CL'
                    THEN
                    --{
                        l_stop_opened              := 'N';
                        --
                        l_stop_in_rec.stop_id      := next_leg_rec.do_stop_id;
                        l_stop_in_rec.put_messages := FALSE;
                        l_stop_in_rec.caller       := p_in_rec.caller;
                        l_stop_in_rec.actual_date  := p_in_rec.actual_date;
                        --
                        --
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_ACTIONS.autoCLOSE',WSH_DEBUG_SV.C_PROC_LEVEL);
                        END IF;
                        --
                        WSH_TRIP_STOPS_ACTIONS.autoCloseOpen
                            (
                                p_in_rec                => l_stop_in_rec,
                                p_reopenStop            => TRUE,
                                x_stop_processed        => l_stop_opened,
                                x_return_status         => l_return_status
                            );
                        --
                        WSH_UTIL_CORE.api_post_call
                            (
                                p_return_status => l_return_status,
                                x_num_warnings  => l_num_warnings,
                                x_num_errors    => l_num_errors
                            );
                    --}
                    END IF;
                    --
                    --
                    l_stop_locationId := next_leg_rec.do_stop_locationId;
                    l_stop_Id         := next_leg_rec.do_stop_id;
                --}
                END LOOP;  -- next leg
            --}
            END LOOP;
        --}
        END LOOP; -- dlvy
       --
       l_index := l_stop_id_tbl.NEXT(l_index);
    --}
    END LOOP;
    --
    --
    --
   --
   IF l_num_errors > 0
   THEN
        x_return_status         := WSH_UTIL_CORE.G_RET_STS_ERROR;
   ELSE
   --{
        FND_MESSAGE.SET_NAME('WSH','WSH_STOP_OPEN_MESSAGE');
        FND_MESSAGE.SET_TOKEN('STOP_NAME',p_in_rec1.stop_name);
        FND_MESSAGE.SET_TOKEN('TRIP_NAME',p_in_rec1.trip_name);
        wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_SUCCESS,l_module_name);
        --
        IF l_num_warnings > 0
        THEN
            x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        ELSE
            x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
        END IF;
   --}
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
      --
    WHEN FND_API.G_EXC_ERROR THEN

      --ROLLBACK TO open_stop_begin_sp;
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      --ROLLBACK TO open_stop_begin_sp;
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
        wsh_util_core.default_handler('WSH_TRIP_STOPS_ACTIONS.setOpen',l_module_name);
        --
        --ROLLBACK TO open_stop_begin_sp;
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
END setOpen;
--
--
-- J-IB-NPARIKH-}
--
--

PROCEDURE RESET_STOP_SEQ_NUMBERS
    (   p_stop_details_rec     IN  OUT NOCOPY  WSH_TRIP_STOPS_VALIDATIONS.stop_details,
        x_return_status        OUT NOCOPY  VARCHAR2
    ) IS


CURSOR get_max_closed_seq (c_trip_id number) is
   SELECT max(stop_sequence_number)
   FROM   wsh_trip_stops
   WHERE  trip_id = c_trip_id
          AND status_code in ('AR', 'CL');
-- Bug 3814592
-- look for open stops higher than closed/arrived stops
-- Mixed trip can have open stops which have lower sequence number
-- than closed/arrived stops
CURSOR get_all_open_stops( c_trip_id number,
                           c_sequence_number NUMBER) is
    SELECT planned_arrival_date,
           stop_id,
           physical_stop_id   -- SSN change
    FROM wsh_trip_stops
    WHERE  trip_id = c_trip_id
      and status_code = 'OP'
      and (stop_sequence_number > c_sequence_number -- Update existing stops
           OR stop_sequence_number < 1)  -- Newly created stops
    FOR update nowait
    ORDER BY 1, 2;

l_stop_rec_tab   WSH_TRIP_STOPS_VALIDATIONS.stop_details_tab;
l_max_seq_number NUMBER;
l_trip_id_tmp NUMBER;
l_locking_stops  VARCHAR2(1);
i                NUMBER;
l_trip_id_tab    wsh_util_core.id_tab_type;

--SSN Change, new variables/constants
l_normal_seq_offset number := 10;
l_seq_offset number;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'RESET_STOP_SEQ_NUMBERS';
RECORD_LOCKED    EXCEPTION;
PRAGMA EXCEPTION_INIT(RECORD_LOCKED, -00054);

BEGIN

  SAVEPOINT begin_reset_stop_seq;
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'Stop id ', p_stop_details_rec.stop_id);
    WSH_DEBUG_SV.log(l_module_name,'Trip id ', p_stop_details_rec.trip_id);
    WSH_DEBUG_SV.log(l_module_name,'Stop sequence number ', p_stop_details_rec.stop_sequence_number);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  l_locking_stops := 'N';

  -- lock trip p_trip_id;
  WSH_TRIPS_PVT.lock_trip_no_compare(p_stop_details_rec.trip_id);

  l_locking_stops := 'Y';

  open get_max_closed_seq( p_stop_details_rec.trip_id);
  fetch get_max_closed_seq into l_max_seq_number;

  close get_max_closed_seq;

  IF l_max_seq_number is NULL THEN
     l_max_seq_number := 0;
  END IF;

  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'maximum sequence number from cursor get_max_closed_seq',l_max_seq_number );
  END IF;

  l_stop_rec_tab.delete;

  -- If the trip stop were created by patchset 11.5.7 or older, the trip stop sequence number should
  -- always be -99 regardless of the planned_arrival_date and status_code.
  -- If the trip stops were created by patchset 11.5.8 or 11.5.9, the trip stop sequence numbers
  -- could be any number entered by users, but users must close the trip stops in order.
  -- The code is based on the assumption that the sequence number of a open stop is always geater
  -- than or equal to the sequence number of any closed or arrived trip stop.

  -- Bug 3814592, add l_max_seq_number to the cursor where clause
  -- renumber only open stops which have higher sequence number than
  -- closed/arrived stops on trip

  open get_all_open_stops(p_stop_details_rec.trip_id,l_max_seq_number);
  loop
    i := l_stop_rec_tab.count+1;
    -- SSN change, fetch physical_stop_id
    fetch get_all_open_stops
     into l_stop_rec_tab(i).planned_arrival_date,
          l_stop_rec_tab(i).stop_id,l_stop_rec_tab(i).physical_stop_id ;
    exit when get_all_open_stops%NOTFOUND;
  end loop;

  -- SSN Change
  l_seq_offset := l_normal_seq_offset;

  i := l_stop_rec_tab.first;
  WHILE i is not NULL LOOP
     IF l_stop_rec_tab(i).stop_id is not NULL THEN
       -- SSN change
       -- Logic to offset linked dummy stop by -1
       IF l_stop_rec_tab(i).physical_stop_id is NOT NULL THEN
         -- to retain -1 offset with next physical stop
         l_max_seq_number := l_max_seq_number + l_normal_seq_offset - 1;
         l_seq_offset := 1;  -- next physical stop will be +1 after this linked dummy stop.
       ELSE
         l_max_seq_number := l_max_seq_number + l_seq_offset;
         l_seq_offset := l_normal_seq_offset; -- always reset for next normal stop.
       END IF;

        update wsh_trip_stops set stop_sequence_number = l_max_seq_number
        where stop_id = l_stop_rec_tab(i).stop_id;

        IF l_debug_on THEN
  	   WSH_DEBUG_SV.logmsg(l_module_name,'updated stop '||l_stop_rec_tab(i).stop_id||' with sequence number '||to_char(l_max_seq_number));
        END IF;
        IF p_stop_details_rec.stop_id = l_stop_rec_tab(i).stop_id THEN
  	   p_stop_details_rec.stop_sequence_number := l_max_seq_number;
        END IF;
        i := l_stop_rec_tab.next(i);
     ELSE
        exit;
     END IF;
  END LOOP;

  IF get_all_open_stops%ISOPEN THEN
     close get_all_open_stops;
  END IF;

  -- Need to compute all stops weight/volumes since the sequence would have changed
  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_ACTIONS.trip_weight_volume',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;

  l_trip_id_tab(1) := p_stop_details_rec.trip_id;
  WSH_TRIPS_ACTIONS.trip_weight_volume(
    p_trip_rows            => l_trip_id_tab,
    p_override_flag        => 'Y',
    p_calc_wv_if_frozen    => 'N',
    p_start_departure_date => to_date(NULL),
    p_calc_del_wv          => 'N',
    x_return_status        => x_return_status,
    p_suppress_errors      => 'Y');

  IF x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Error calculating trip wt/vol');
    END IF;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

  EXCEPTION

   WHEN RECORD_LOCKED
        OR app_exception.application_exception
        OR app_exception.record_lock_exception THEN
      ROLLBACK TO begin_reset_stop_seq;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      IF get_all_open_stops%ISOPEN THEN
           close get_all_open_stops;
      END IF;

      IF l_locking_stops = 'N' THEN
         FND_MESSAGE.SET_NAME('WSH', 'WSH_TRIP_LOCK_FAILED');
         FND_MESSAGE.SET_TOKEN('ENTITY_NAME',to_char(l_trip_id_tmp));
         wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'ERROR: Failed to lock trip ID '||to_char(l_trip_id_tmp));
            WSH_DEBUG_SV.POP(l_module_name, 'EXCEPTION:RECORD_LOCKED');
         END IF;
      ELSE
         FND_MESSAGE.SET_NAME('WSH', 'WSH_NO_LOCK');
         wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'ERROR: Failed to lock trip stops belong to trip l_trip_id_tmp' );
            WSH_DEBUG_SV.POP(l_module_name, 'EXCEPTION:RECORD_LOCKED');
         END IF;
      END IF;

   WHEN OTHERS THEN

        wsh_util_core.default_handler('WSH_TRIP_STOPS_ACTIONS.reset_stop_sequence_numbers',l_module_name);
        IF get_all_open_stops%ISOPEN THEN
           close get_all_open_stops;
        END IF;
        ROLLBACK TO begin_reset_stop_seq;
        IF get_all_open_stops%ISOPEN THEN
           close get_all_open_stops;
        END IF;

        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;

END RESET_STOP_SEQ_NUMBERS;


  -- OTM R12, glog proj
  ---------------------------------------------------------------------------
  -- PROCEDURE LAST_PICKUP_STOP_CLOSED
  --
  -- parameters: p_trip_id -> the trip id to check for
  --             p_stop_id -> the stop id to check for to skip because
  --                          we will set this stop to close since this
  --                          is called only in setClose procedure
  --             x_last_pickup_stop_closed -> Returns 'Y' if its the stop
  --             closed is the last pickup stop.
  --             x_eligible_for_asr --> Returns 'Y' is the trip information
  --             is eligible to be send to OTM.
  --             x_return_status --> Returns status of this procedure call.
  -- Assumption : p_trip_id and p_stop_id as passed by the calling API
  ---------------------------------------------------------------------------

  PROCEDURE LAST_PICKUP_STOP_CLOSED
    (p_trip_id                 IN WSH_TRIP_STOPS.TRIP_ID%TYPE,
     p_stop_id                 IN WSH_TRIP_STOPS.STOP_ID%TYPE,
     x_last_pickup_stop_closed OUT NOCOPY VARCHAR2,
     x_eligible_for_asr        OUT NOCOPY VARCHAR2,
     x_return_status           OUT NOCOPY VARCHAR2) IS

  --OTM R12 Org-Specific. (Reviewed by perf team)
  CURSOR pickup_stop_csr IS
  SELECT stop_id
    FROM ( SELECT wts.stop_id
             FROM wsh_trip_stops wts
            WHERE wts.trip_id = p_trip_id
              AND wts.status_code IN ( 'OP', 'AR')
              AND EXISTS ( SELECT 'c'
                            FROM wsh_delivery_legs wdl
                           WHERE wdl.pick_up_stop_id = wts.stop_id)
            ORDER BY wts.stop_sequence_number DESC)
   WHERE ROWNUM = 1;

  -- LSP PROJECT : checking OTM enabled flag on client parameters.
  --OTM R12 Org-Specific (Reviewed by perf team)
  CURSOR check_eligible_for_asr_csr IS
  SELECT 1
    FROM wsh_trip_stops     wts
        ,wsh_delivery_legs  wdl
        ,wsh_new_deliveries wnd
   WHERE wts.trip_id = p_trip_id
     AND wts.stop_id = wdl.pick_up_stop_id
     AND wdl.delivery_id = wnd.delivery_id
     AND EXISTS ( SELECT 1
                    FROM wsh_shipping_parameters wsp
                   WHERE wnd.organization_id = wsp.organization_id
                     AND wsp.otm_enabled = 'Y' AND wnd.client_ID IS NULL
                  UNION ALL
                  SELECT 1
                    FROM mtl_client_parameters_v mcp
                   WHERE wnd.client_id = mcp.client_id
                     AND mcp.otm_enabled = 'Y' AND wnd.client_ID IS NOT NULL )
     AND NOT EXISTS ( SELECT 1
                        FROM wsh_trip_stops     wts
                            ,wsh_delivery_legs  wdl
                            ,wsh_new_deliveries wnd
                       WHERE wts.trip_id = p_trip_id
                         AND wts.stop_id = wdl.pick_up_stop_id
                         AND wdl.delivery_id = wnd.delivery_id
                         AND ( EXISTS ( SELECT 1
                                          FROM mtl_parameters mtlp
                                         WHERE mtlp.organization_id = wnd.organization_id
                                           AND mtlp.distributed_organization_flag = 'Y')
                               OR wnd.delivery_type = 'CONSOLIDATION'))
     AND ROWNUM = 1;
  --OTM R12

  --OTM R12 Org-Specific start.
  l_stop_id         wsh_trip_stops.stop_id%TYPE;
  l_id              NUMBER;
  --OTM R12 End ;

  l_debug_on     BOOLEAN;
  --
  l_module_name  CONSTANT VARCHAR2(100) := 'wsh.plsql.' || g_pkg_name || '.' || 'LAST_PICKUP_STOP_CLOSED';
  --
  BEGIN

    l_debug_on := wsh_debug_interface.g_debug;
    --
    IF l_debug_on IS NULL THEN
      l_debug_on := wsh_debug_sv.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name);
      wsh_debug_sv.LOG(l_module_name, 'p_trip_id', p_trip_id);
      wsh_debug_sv.LOG(l_module_name, 'p_stop_id', p_stop_id);
    END IF;

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    x_last_pickup_stop_closed := 'N';

    -- This API is not exposed to end user, so no message needed here
    -- the developers need to know the mandatory parameters
    IF p_trip_id IS NULL OR p_stop_id IS NULL THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,
                'Please specify p_trip_id and p_stop_id');
        wsh_debug_sv.pop(l_module_name, 'ERROR EXCEPTION');
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --OTM R12 Org-Specific start.
    OPEN pickup_stop_csr;
    FETCH pickup_stop_csr INTO l_stop_id;
    CLOSE pickup_stop_csr;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_stop_id', l_stop_id );
    END IF;

    IF l_stop_id = p_stop_id THEN --{
      x_last_pickup_stop_closed := 'Y';
    ELSE
      x_last_pickup_stop_closed := 'N';
    END IF; --}

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'x_last_pickup_stop_closed',
            x_last_pickup_stop_closed );
    END IF;

    --If last pickup stop closed then check whether any of the delivery orgs
    --in the trip is TPW. If any orgs are TPW then dont send trip info to OTM.
    --If the delivery is part of MDC then don't sent trip info to OTM.
    --If warehouse is not TPW and included delivery not part of MDC then
    --check whether any of the deliveries in the trip belong to OTM enabed
    --orgs. If so set the flag to send trip info to OTM.
    IF x_last_pickup_stop_closed = 'Y' THEN --{
      OPEN check_eligible_for_asr_csr;
      FETCH check_eligible_for_asr_csr INTO l_id ;
      IF check_eligible_for_asr_csr%FOUND THEN
        x_eligible_for_asr := 'Y';
      ELSE
        x_eligible_for_asr := 'N';
      END IF;
      CLOSE check_eligible_for_asr_csr;
    END IF; --}
    IF x_eligible_for_asr IS NULL THEN
      x_eligible_for_asr := 'N';
    END IF;
    --OTM R12 End

    IF l_debug_on THEN
      wsh_debug_sv.LOG(l_module_name, 'x_eligible_for_asr', x_eligible_for_asr);
      wsh_debug_sv.LOG(l_module_name, 'x_last_pickup_stop_closed',
                                       x_last_pickup_stop_closed);
      wsh_debug_sv.LOG(l_module_name, 'x_return_status', x_return_status);
      wsh_debug_sv.pop(l_module_name);
    END IF;

  EXCEPTION
    --OTM R12 Org-Specific start.
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      IF pickup_stop_csr%ISOPEN THEN
        CLOSE pickup_stop_csr;
      END IF;
      IF check_eligible_for_asr_csr%ISOPEN THEN
        CLOSE check_eligible_for_asr_csr;
      END IF;

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,
                'Oracle error '||SQLERRM,
                WSH_DEBUG_SV.C_EXCEP_LEVEL);
        wsh_debug_sv.pop(l_module_name, 'FND_API.G_EXC_ERROR');
      END IF;

    --OTM R12 End
    WHEN OTHERS THEN
      IF pickup_stop_csr%ISOPEN THEN
        CLOSE pickup_stop_csr;
      END IF;
      IF check_eligible_for_asr_csr%ISOPEN THEN
        CLOSE check_eligible_for_asr_csr;
      END IF;

      wsh_util_core.default_handler('wsh_trip_stops_actions.last_pickup_stop_closed',
                                        l_module_name);
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,
                'Unexpected Error has Occured.Oracle error message is'||SQLERRM,
                WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        wsh_debug_sv.pop(l_module_name, 'EXCEPTION:OTHERS');
      END IF;

  END LAST_PICKUP_STOP_CLOSED;

END WSH_TRIP_STOPS_ACTIONS;

/
