--------------------------------------------------------
--  DDL for Package Body WSH_NEW_DELIVERY_ACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_NEW_DELIVERY_ACTIONS" as
/* $Header: WSHDEACB.pls 120.51.12010000.6 2010/02/03 14:08:13 anvarshn ship $ */


g_object_id_tab  WSH_NEW_DELIVERY_ACTIONS.TableNumbers;


  --
  G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_NEW_DELIVERY_ACTIONS';
  --

 -- Global variables used in Cont_Tobe_Unassigned and Get_Topmost_Unassignable_Cont
  g_container_lines      wsh_util_core.id_tab_type ;
  g_traversed_containers wsh_util_core.id_tab_type;

 /* Added the following global variable for Ship Message Customization project
  * for R12. This variable is accessed in procedure CONFIRM_DELIVERY. This
  * variable is used to cache the Message Severity Level */
  g_missing_inv_severity     VARCHAR2(10);

 --
 -- R12 Routing Guide (Start)
 --

TYPE wsh_cs_delivery_info_rec IS RECORD( l_delivery_id                  wsh_new_deliveries.delivery_id%TYPE,
		  		     l_dlvy_name		       	wsh_new_deliveries.name%TYPE,
		 		     l_organization_id             	wsh_new_deliveries.organization_id%TYPE,
				 	 l_gross_weight                	wsh_new_deliveries.gross_weight%TYPE,
					 l_weight_uom_code             	wsh_new_deliveries.weight_uom_code%TYPE,
					 l_volume                      	wsh_new_deliveries.volume%TYPE,
					 l_volume_uom_code             	wsh_new_deliveries.volume_uom_code%TYPE,
					 l_initial_pickup_location_id  	wsh_new_deliveries.initial_pickup_location_id%TYPE,
					 l_ultimate_dropoff_location_id	wsh_new_deliveries.ultimate_dropoff_location_id%TYPE,
					 l_customer_id                 	wsh_new_deliveries.customer_id%TYPE,
					 l_freight_terms_code          	wsh_new_deliveries.freight_terms_code%TYPE,
					 l_planned_flag                	wsh_new_deliveries.planned_flag%TYPE,
					 l_initial_pickup_date         	wsh_new_deliveries.initial_pickup_date%TYPE,
					 l_ultimate_dropoff_date      	wsh_new_deliveries.ultimate_dropoff_date%TYPE,
					 l_fob_code			wsh_new_deliveries.fob_code%TYPE,
                                         l_shipment_direction           wsh_new_deliveries.shipment_direction%TYPE,
                                         l_delivery_type                wsh_new_deliveries.delivery_type%TYPE,
					 l_trip_id			NUMBER);

TYPE wsh_cs_delivery_info_tab	IS TABLE OF wsh_cs_delivery_info_rec INDEX BY BINARY_INTEGER;
--
-- R12 Routing Guide (End)
--


-- Local API, used within this procedure only
FUNCTION check_last_del_trip(p_delivery_id IN NUMBER)
 return BOOLEAN ;

-- Local API, used within this procedure only
FUNCTION get_trip_status(p_delivery_id IN NUMBER,p_delivery_type IN VARCHAR2)
 return VARCHAR2 ;

   -- K: MDC: Forward declaration

   PROCEDURE Confirm_Consolidation_Delivery(
           p_consol_del_tab IN wsh_util_core.id_tab_type,
           x_return_status OUT NOCOPY VARCHAR2);

   PROCEDURE Create_Deconsol_Trips(
           p_deliveries_tab IN wsh_util_core.id_tab_type,
           x_return_status OUT NOCOPY VARCHAR2);


/* This procedure identifies the topmost container which contains only packed or unpacked staged line(s)
   that can be unassigned from the delivery. This procedure is initially called from Cont_Tobe_Unassigned
   for all the Staged Lines. This procedure then recursively checks if the container has only staged lines.
   If it has any empty containers or shipped lines, then the container cannot be unassigned. Only its
   children may be unassigned. The unassigned list is stored in g_container_lines package variable.
   Parameters :
                 p_curr_line_id    Delivery Detail Id of Container or Staged Line
                 p_staged_lines    Array of Staged Lines
                 l_return_status   Return Status
*/

PROCEDURE get_topmost_unassignable_cont ( p_curr_line_id  IN NUMBER,
                                          p_staged_lines  IN wsh_util_core.id_tab_type,
                                          x_return_status OUT NOCOPY  VARCHAR2
                                        )
IS

CURSOR get_container(detail_id NUMBER) IS
SELECT parent_delivery_detail_id
FROM   wsh_delivery_assignments_v
WHERE  delivery_detail_id = detail_id;

CURSOR get_lines (cont_id NUMBER) IS
SELECT delivery_detail_id
FROM   wsh_delivery_assignments_v
START WITH parent_delivery_detail_id = cont_id
CONNECT BY PRIOR delivery_detail_id = parent_delivery_detail_id;

l_container_id NUMBER := NULL;
l_detail_found BOOLEAN ;

x_immediate_contents  wsh_util_core.id_tab_type;

l_contents            wsh_util_core.id_tab_type;

get_lines_curr_fetch NUMBER;
get_lines_prev_fetch NUMBER;

l_return_status      VARCHAR2(1);


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_TOPMOST_UNASSIGNABLE_CONT';
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

  OPEN get_container (p_curr_line_id) ;
  FETCH get_container INTO l_container_id;
  IF get_container%NOTFOUND THEN
     CLOSE get_container;
     RAISE NO_DATA_FOUND;
  END IF;
  CLOSE get_container;

  IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Current line : '||p_curr_line_id||' , Container : '|| l_container_id);
  END IF;

  IF l_container_id IS NULL THEN
     -- Either it is an unpacked staged line or it is the topmost container
     FOR j IN 1..g_container_lines.COUNT LOOP
         IF ( p_curr_line_id  = g_container_lines(j) ) THEN
            GOTO END_PROC ;
         END IF;
     END LOOP;
     g_container_lines(g_container_lines.COUNT + 1) := p_curr_line_id ;
     GOTO END_PROC ;
  ELSE
     -- Check if this container has already been traversed
     FOR r in 1..g_traversed_containers.COUNT LOOP
         IF l_container_id = g_traversed_containers(r) THEN
            GOTO END_PROC;
         END IF;
     END LOOP;
  END IF;

  -- Check for all contents of Container
  get_lines_curr_fetch := 0;
  get_lines_prev_fetch := 0;
  l_contents.delete;
  OPEN get_lines(l_container_id);
  LOOP
     FETCH get_lines BULK COLLECT INTO x_immediate_contents LIMIT 100;
     get_lines_curr_fetch := get_lines%rowcount - get_lines_prev_fetch;
     EXIT WHEN ( get_lines_curr_fetch = 0 );
     FOR m IN 1..get_lines_curr_fetch LOOP
         l_contents(l_contents.COUNT + 1) := x_immediate_contents(m);
         l_detail_found := FALSE;
         -- Check if all the immediate lines in l_cont_id are present in staged lines list
         FOR n in 1..p_staged_lines.COUNT LOOP
             IF x_immediate_contents(m) = p_staged_lines(n) THEN
                IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Found Staged line :'||p_staged_lines(n));
                END IF;
                l_detail_found := TRUE;
                EXIT;
             END IF;
         END LOOP;

         IF ( NOT l_detail_found ) THEN
            -- Check if contents of Container are in Traversed Container List
            FOR p in 1..g_traversed_containers.COUNT LOOP
                IF x_immediate_contents(m) = g_traversed_containers(p) THEN
                   IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'Found Traversed Container :'||g_traversed_containers(p));
                   END IF;
                   l_detail_found := TRUE;
                   EXIT;
                END IF;
            END LOOP;
         END IF;

         IF ( NOT l_detail_found ) THEN
            -- Check if line or container is already marked as to be unassigned previously, if so, return to caller
            FOR j IN 1..g_container_lines.COUNT LOOP
                IF ( p_curr_line_id  = g_container_lines(j) ) THEN
                   IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'Found current line in Unassigned Container List :'||p_curr_line_id);
                   END IF;
                   GOTO END_PROC ;
                END IF;
            END LOOP;
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Found either shipped line, container_line or non-traversed path :'||x_immediate_contents(m));
            END IF;
            g_container_lines(g_container_lines.COUNT + 1) := p_curr_line_id ;
            GOTO END_PROC ;
         END IF;

     END LOOP;  -- get_lines_curr_fetch

     get_lines_prev_fetch := get_lines%rowcount;

  END LOOP;  -- get_lines cursor

  -- If all the lines in the Container are Staged Lines or other Container Lines, then call recursively for Container
  IF ( l_detail_found ) THEN
     -- Fail safe to close the open cursor before calling recursively
     IF get_lines%ISOPEN THEN
        CLOSE get_lines;
     END IF;
     FOR y in 1..l_contents.COUNT LOOP
         FOR z in 1..g_container_lines.COUNT LOOP
             IF l_contents(y) = g_container_lines(z) THEN
                g_container_lines(z) := -g_container_lines(z);
             END IF;
         END LOOP;
     END LOOP;
     g_traversed_containers(g_traversed_containers.count + 1) := l_container_id ;
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Recursive call for container :'||l_container_id);
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERY_ACTIONS.GET_TOPMOST_UNASSIGNABLE_CONT',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     get_topmost_unassignable_cont( l_container_id, p_staged_lines, l_return_status );
     IF l_return_status IN ( WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ) THEN
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,  'Return Status from WSH_NEW_DELIVERY_ACTIONS.GET_TOPMOST_UNASSIGNABLE_CONT : ', l_return_status);
        END IF;
        g_container_lines.delete;
        RAISE NO_DATA_FOUND;
     END IF;
  END IF;

  <<END_PROC>>
  IF get_lines%ISOPEN THEN
     CLOSE get_lines;
  END IF;

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --

EXCEPTION
  WHEN OTHERS THEN
       wsh_util_core.default_handler('WSH_NEW_DELIVERY_ACTIONS.Get_Topmost_Unassignable_Cont',l_module_name);
       x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
       IF get_lines%ISOPEN THEN
          CLOSE get_lines;
       END IF;
       IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name,'When Others');
       END IF;
END get_topmost_unassignable_cont;


/* This procedure takes input as staged lines and then calls get_topmost_unassignable_cont to
   see if the parent container(s) can also be unassigned. It then returns the list of lines or
   containers which should be unassigned back to the calling program.
*/
PROCEDURE Cont_ToBe_Unassigned ( p_staged_lines    IN wsh_util_core.id_tab_type,
                                 x_unassigned_cont OUT NOCOPY  wsh_util_core.id_tab_type,
                                 x_return_status   OUT NOCOPY  VARCHAR2
                               )
IS

l_return_status  VARCHAR2(1);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CONT_TOBE_UNASSIGNED';
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

  IF ( p_staged_lines.COUNT = 0 ) THEN
     IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     RETURN;
  END IF;

  g_container_lines.delete;
  g_traversed_containers.delete;

  FOR i in 1..p_staged_lines.COUNT LOOP
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERY_ACTIONS.GET_TOPMOST_UNASSIGNABLE_CONT',WSH_DEBUG_SV.C_PROC_LEVEL);
        WSH_DEBUG_SV.log(l_module_name,  'Staged Detail Line: ', p_staged_lines(i));
     END IF;
     --
     get_topmost_unassignable_cont( p_staged_lines(i), p_staged_lines, l_return_status );

     IF l_return_status IN ( WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ) THEN
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,  'Return Status from WSH_NEW_DELIVERY_ACTIONS.GET_TOPMOST_UNASSIGNABLE_CONT : ', l_return_status);
        END IF;
        x_unassigned_cont.delete;
        RAISE NO_DATA_FOUND;
     END IF;

  END LOOP;  -- main loop on p_staged_lines

  -- To assign only +ve values to the out parameter
  FOR z in 1..g_container_lines.COUNT LOOP
      IF g_container_lines(z) > 0 THEN
         x_unassigned_cont(x_unassigned_cont.COUNT + 1) := g_container_lines(z);
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,  'Containers/Lines to be Unassigned : ', g_container_lines(z));
        END IF;
      END IF;
  END LOOP;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--

EXCEPTION
  WHEN OTHERS THEN
       wsh_util_core.default_handler('WSH_NEW_DELIVERY_ACTIONS.Cont_ToBe_Unassigned',l_module_name);
       x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
       IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name,'When Others');
       END IF;
END Cont_ToBe_Unassigned;

-- bug 4505105
-- This procedure validates whether the containers
-- with in the given delivery are shippable or not
-- Validates Normal deliveries as well as Consol Deliveries.
PROCEDURE validate_del_containers (p_delivery_id IN NUMBER,
                                   p_del_type    IN VARCHAR2 DEFAULT 'STD',
                                   x_del_valid_flag OUT NOCOPY VARCHAR2,
                                   x_return_status OUT NOCOPY VARCHAR2)
IS
  --{
      --
      l_return_status  VARCHAR2(1);
      l_del_valid_flag  VARCHAR2(1);
      l_cnt_flag  VARCHAR2(1);

      cursor l_del_contents_csr (p_del_id IN NUMBER,
                                 p_cnt_flag IN VARCHAR2) is
      select 'N'
      from   wsh_delivery_assignments_v wda,
             wsh_delivery_details wdd,
             mtl_system_items msi
      where  wda.delivery_detail_id = wdd.delivery_detail_id
      and    wdd.inventory_item_id = msi.inventory_item_id
      and    wdd.organization_id = msi.organization_id
      and    nvl(msi.shippable_item_flag,'Y') = 'N'
      and    wdd.container_flag = p_cnt_flag
      and    wda.delivery_id = p_del_id;

      --
      l_debug_on BOOLEAN;
      --
      l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_DEL_CONTAINERS';
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
        WSH_DEBUG_SV.log(l_module_name,  'p_delivery_id is ', p_delivery_id);
        WSH_DEBUG_SV.logmsg(l_module_name,  ' Opening the cursor l_del_contents_csr');
      END IF;
      --
      IF (nvl(p_del_type, 'STD') = 'STD') THEN
        l_cnt_flag := 'Y';
      ELSE
        l_cnt_flag := 'C';
      END IF;
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      --
      open  l_del_contents_csr(p_delivery_id, l_cnt_flag);
      fetch l_del_contents_csr into l_del_valid_flag;
      close l_del_contents_csr;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,  'l_del_valid_flag is ', l_del_valid_flag);
      END IF;
      --
      x_del_valid_flag := nvl(l_del_valid_flag,'Y');

      IF (nvl(l_del_valid_flag,'Y') = 'N') THEN
        --
        FND_MESSAGE.SET_NAME('WSH','WSH_DEL_SC_CNT_ERROR');
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_delivery_id));
        wsh_util_core.add_message(wsh_util_core.g_ret_sts_error);
        --
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
      WHEN OTHERS THEN
        wsh_util_core.default_handler('WSH_NEW_DELIVERY_ACTIONS.VALIDATE_DEL_CONTAINERS',l_module_name);
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name,'When Others');
        END IF;

  --}
END validate_del_containers;
-- bug 4505105

/* J TP Release */
  PROCEDURE FIRM
  (p_del_rows   IN  wsh_util_core.id_tab_type,
   x_return_status  OUT NOCOPY  VARCHAR2) IS

  l_return_status VARCHAR2(1);
  l_net_weight  NUMBER;
  l_gross_weight  NUMBER;
  l_volume    NUMBER;
  l_num_error  BINARY_INTEGER := 0;
  l_num_warn    BINARY_INTEGER := 0;
  others    EXCEPTION;

  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'FIRM';
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

  FOR i IN 1..p_del_rows.count LOOP

    --  Check if Delivery can be planned
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_VALIDATIONS.CHECK_PLAN',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;

    wsh_delivery_validations.check_plan( p_del_rows(i), x_return_status);

    IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) OR (x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_DEL_FIRM_ERROR');

      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

      FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_del_rows(i)));
      wsh_util_core.add_message(x_return_status);
      l_num_error := l_num_error + 1;
      goto loop_end;
    ELSIF (x_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
      l_num_warn := l_num_warn + 1;
    END IF;

    wsh_tp_release.firm_entity( p_entity        => 'DLVY',
                                p_entity_id     =>p_del_rows(i),
                                x_return_status =>x_return_status);
    IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
           IF x_return_status=WSH_UTIL_CORE.G_RET_STS_WARNING THEN
              l_num_warn := l_num_warn + 1;
           ELSE
              l_num_error:=l_num_error+1;
           END IF;
    END IF;

    <<loop_end>>
    null;

  END LOOP;


  IF (p_del_rows.count = 1) THEN
    IF (l_num_warn > 0) AND (l_num_error = 0) THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    END IF;
  ELSIF (p_del_rows.count > 1) THEN
    IF (l_num_error > 0) OR (l_num_warn > 0) THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_DEL_FIRM_SUMMARY');
    FND_MESSAGE.SET_TOKEN('NUM_ERROR',l_num_error);
    FND_MESSAGE.SET_TOKEN('NUM_WARN',l_num_warn);
    FND_MESSAGE.SET_TOKEN('NUM_SUCCESS',p_del_rows.count - l_num_error - l_num_warn);

    IF (p_del_rows.count = l_num_error) THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    ELSE
       x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    END IF;

    wsh_util_core.add_message(x_return_status);
    ELSE
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    END IF;
  END IF;

  IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

  EXCEPTION
    WHEN others THEN
      wsh_util_core.default_handler('WSH_NEW_DELIVERY_ACTIONS.FIRM');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
  END FIRM;



-- -----------------------------------------------------------------------
-- Name
--   PROCEDURE Adjust_Planned_Flag
--
-- Purpose:
--   This procedure takes a list of deliveries and adjust the planned_flag
--   based on appending_limit of the organization.
--   If the delivery is alrady planned, it will ignore the delivery.
--   It never unplan the delivery. For WMS caller, if the appending_limit
--   matches the event it will plan the delivery.
--
-- Input Parameters:
--   p_delivery_ids - the list of deliveries to be processed
--   p_caller - 'WSH_DLMG' if it is called from delivery merge code
--              'WMS_%' if it is called by WMS
--   p_force_appending_limit - 'Y': set the planned_flag to 'Y' without checking
--                                  the value in shipping parameters
--                           - 'N': Check the appending_limit in shipping parameters
--                                  and plan the delivery if the appending limit has
--                                  been reached
--   p_call_lcss             - 'Y' :Call Carrier Selection and Rate Deliveries when
--                                  appending limit has been reached if the options
--                                  in shipping parameters are set
--                           - 'N' :do not call Carrier Selection and Rate Deliveries when
--                                  appending limit has been reached
--
--   p_event                 - 'A': start of packing
--                           - 'W': start of shipping
--                           - required if p_caller like WMS_%
--
-- Output Parameters:
--   x_return_status  - Success, Warning, Error, Unexpected Error
-- ----------------------------------------------------------------------

PROCEDURE Adjust_Planned_Flag(
   p_delivery_ids            IN wsh_util_core.id_tab_type,
   p_caller                  IN VARCHAR2,
   p_force_appending_limit   IN VARCHAR2,
   p_call_lcss               IN VARCHAR2,
   p_event                   IN VARCHAR2,
   x_return_status           OUT NOCOPY VARCHAR2,
   p_called_for_sc           IN  BOOLEAN default false) IS

   CURSOR c_isdelfirm(p_delid IN NUMBER) IS
   select 'Y'
   from wsh_new_deliveries
   where delivery_id=p_delid AND
   planned_flag='F';

   Cursor c_get_unplanned_delivery(p_delivery_id NUMBER) IS
   SELECT  wnd.organization_id, wnd.planned_flag , wnd.initial_pickup_location_id
   FROM    wsh_new_deliveries wnd
   WHERE   wnd.delivery_id = p_delivery_id AND
           wnd.status_code = 'OP' AND
           wnd.planned_flag = 'N' AND
           NVL(wnd.shipment_direction,'O') in ('O','IO');

   Cursor c_get_delivery(p_delivery_id NUMBER) IS
   SELECT  wnd.organization_id, wnd.planned_flag
   FROM    wsh_new_deliveries wnd
   WHERE   wnd.delivery_id = p_delivery_id AND
           wnd.status_code = 'OP' AND
           NVL(wnd.shipment_direction,'O') in ('O','IO');

   Cursor c_num_of_staged_lines(p_delivery_id NUMBER) IS
   SELECT count(wdd.delivery_detail_id)
   FROM   wsh_delivery_details wdd,
          wsh_delivery_assignments_v wda
   WHERE  wdd.delivery_detail_id = wda.delivery_detail_id AND
          wda.delivery_id = p_delivery_id AND
          wda.delivery_id is not NULL AND
          wdd.container_flag = 'N' AND
          wdd.source_code = 'OE' AND
          wdd.released_status in ('Y', 'C') AND
          NVL(wdd.line_direction,'O') in ('O','IO');

   Cursor c_get_line_status_in_delivery(p_delivery_id NUMBER) IS
   SELECT wdd.released_status
   FROM   wsh_delivery_details wdd,
          wsh_delivery_assignments_v wda
   WHERE  wdd.delivery_detail_id = wda.delivery_detail_id AND
          wda.delivery_id = p_delivery_id AND
          wda.delivery_id is not NULL AND
          wdd.container_flag = 'N' AND
          wdd.source_code = 'OE' AND
          NVL(wdd.line_direction,'O') in ('O','IO');

   l_num_error  BINARY_INTEGER := 0;
   l_num_warn    BINARY_INTEGER := 0;
   l_delfirm VARCHAR2(1);
   l_organization_id         WSH_SHIPPING_PARAMETERS.ORGANIZATION_ID%TYPE;
   l_planned_flag            WSH_NEW_DELIVERIES.PLANNED_FLAG%TYPE;
   l_initial_pickup_location_id  WSH_NEW_DELIVERIES.INITIAL_PICKUP_LOCATION_ID%TYPE;
   l_released_status         WSH_DELIVERY_DETAILS.RELEASED_STATUS%TYPE;
   l_num_of_staged_lines     NUMBER := 0;
   l_ignore_count            NUMBER := 0;
   l_delivery_detail_count   NUMBER := 0;
   l_delivery_id             NUMBER := 0;
   l_auto_rate_tbl           WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type;
   l_select_carrier_tbl      WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type;
   l_param_info              WSH_SHIPPING_PARAMS_PVT.Parameter_Rec_Typ;
   l_return_status           VARCHAR2(1);
   l_status_code             VARCHAR2(30) := 'OP';
   l_dels_to_update          WSH_UTIL_CORE.Id_Tab_Type;
   l_action_prms             WSH_DELIVERIES_GRP.action_parameters_rectype;
   l_delivery_out_rec        WSH_DELIVERIES_GRP.Delivery_Action_Out_Rec_Type;
   l_defaults_rec            WSH_DELIVERIES_GRP.default_parameters_rectype;
   l_msg_count               NUMBER;
   l_msg_data                VARCHAR2(2000);
   l_planned_flag_true       WSH_NEW_DELIVERIES.PLANNED_FLAG%TYPE; --bugfix 3778944

   l_debug_on                BOOLEAN;
   l_module_name             CONSTANT VARCHAR2(100) := 'wsh.plsql.' || g_pkg_name || '.' || 'Adjust_Planned_Flag';
   l_exception_message       VARCHAR2(2000);
   l_exception_id            NUMBER;
   Rate_Delivery_Err         EXCEPTION;
   Select_Carrier_Err        EXCEPTION;
   invalid_caller            EXCEPTION;
   invalid_event             EXCEPTION;
   record_locked             EXCEPTION;
   others                    EXCEPTION;
   l_assigned_to_trip        VARCHAR2(1) := NULL;

   PRAGMA EXCEPTION_INIT(record_locked, -54);

 BEGIN

    SAVEPOINT before_adjust_planned_flag;

    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
    END IF;

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


    l_select_carrier_tbl.delete;
    l_auto_rate_tbl.delete;
    l_dels_to_update.delete;

    IF l_debug_on THEN
       wsh_debug_sv.logmsg(l_module_name, 'P_CALLER: '|| p_caller);
       wsh_debug_sv.logmsg(l_module_name, 'P_FORCE_APPENDING_LIMIT: '|| p_force_appending_limit);
       wsh_debug_sv.logmsg(l_module_name, 'P_EVENT: '|| p_event);
    END IF;

    IF (p_delivery_ids.count = 0) THEN
       IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name,'no delivery');
       END IF;
       return;
    END IF;

    IF p_caller not like 'WSH_%' AND p_caller not like 'WMS_%' THEN
       raise invalid_caller ;
    END IF;


    IF p_force_appending_limit = 'Y' THEN

       FOR i in p_delivery_ids.FIRST .. p_delivery_ids.LAST LOOP

          IF p_delivery_ids(i) is NULL THEN
             goto loop_end;
          END IF;
          IF l_debug_on THEN
             wsh_debug_sv.logmsg(l_module_name, 'forcing appending limit, lock and plan the delivery');
          END IF;
          l_planned_flag := NULL;

          --  Check if Delivery can be planned
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_VALIDATIONS.CHECK_PLAN',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          wsh_delivery_validations.check_plan( p_delivery_ids(i), x_return_status,p_called_for_sc);

          IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) OR (x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
             FND_MESSAGE.SET_NAME('WSH','WSH_DEL_PLAN_ERROR');
             --
             -- Debug Statements
             --
             IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;
             --
             FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_delivery_ids(i)));
             wsh_util_core.add_message(x_return_status);
             l_num_error := l_num_error + 1;
             goto loop_end;
          ELSIF (x_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
            l_num_warn := l_num_warn + 1;
          END IF;

          l_delfirm:='N';
          FOR cur IN c_isdelfirm(p_delivery_ids(i)) LOOP
               l_delfirm:='Y';
               wsh_tp_release.unfirm_entity( p_entity      => 'DLVY',
                                           p_entity_id     =>p_delivery_ids(i),
                                           p_action        =>'PLAN',
                                           x_return_status =>x_return_status);
               IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                 IF x_return_status=WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                    l_num_warn := l_num_warn + 1;
                 ELSE
                    goto loop_end;
                 END IF;
               END IF;
          END LOOP;

          IF l_delfirm='N' THEN
             -- lock the delivery befor update
             l_delivery_id := p_delivery_ids(i);

             SELECT organization_id, planned_flag  INTO l_organization_id, l_planned_flag
                FROM wsh_new_deliveries
                WHERE delivery_id = p_delivery_ids(i)
                FOR UPDATE NOWAIT;

             IF (SQL%NOTFOUND) THEN
                FND_MESSAGE.SET_NAME('WSH','WSH_DEL_NOT_FOUND');
                x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                wsh_util_core.add_message(x_return_status);
                l_num_error := l_num_error + 1;
                goto loop_end;
             END IF;

             IF l_planned_flag = 'N' THEN
                -- set the planned_flag to 'Y'

                l_dels_to_update(l_dels_to_update.count+1) := p_delivery_ids(i);
                IF l_debug_on THEN
                   wsh_debug_sv.logmsg(l_module_name, 'Delivery '|| p_delivery_ids(i)||' is goinging to be planned');
                END IF;

                -- carrier selection and rate delivery when appending limit has been reached
                IF p_call_lcss = 'Y' and WSH_UTIL_CORE.FTE_Is_Installed = 'Y' THEN
                   OPEN c_get_unplanned_delivery(p_delivery_ids(i));
                   FETCH c_get_unplanned_delivery INTO l_organization_id, l_planned_flag, l_initial_pickup_location_id;
                   IF c_get_unplanned_delivery%NOTFOUND THEN
                      CLOSE c_get_unplanned_delivery;
                      goto loop_end;
                   END IF;
                   CLOSE c_get_unplanned_delivery;

                   IF l_debug_on THEN
                      wsh_debug_sv.logmsg(l_module_name, 'found delivery '|| p_delivery_ids(i) );
                   END IF;

                   l_assigned_to_trip :=  WSH_DELIVERY_VALIDATIONS.Del_Assigned_To_Trip(
                                             p_delivery_id => p_delivery_ids(i),
                                             x_return_status  => l_return_status);

                   WSH_SHIPPING_PARAMS_PVT.Get(
                      p_organization_id  => l_organization_id,
                      x_param_info       => l_param_info,
                      x_return_status    => l_return_status);

                   IF l_debug_on THEN
                      wsh_debug_sv.logmsg(l_module_name, 'Return status from WSH_SHIPPING_PARAMS_PVT.Get is :'||l_return_status );
                   END IF;


                   IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                      l_num_warn := l_num_warn + 1;
                   ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR OR
                         l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
                      FND_MESSAGE.Set_Name('WSH', 'WSH_PARAM_NOT_DEFINED');
                      FND_MESSAGE.Set_Token('ORGANIZAION_CODE',
                                             wsh_util_core.get_org_name(l_organization_id));
                      wsh_util_core.add_message(x_return_status,l_module_name);
                      l_num_error := l_num_error+1;
                      goto loop_end;
                   END IF;


                   IF NVL(l_param_info.AUTO_APPLY_ROUTING_RULES, 'D') = 'E'
                      AND l_assigned_to_trip = 'N' THEN
                      -- call carrier selection when appending limit is reached
                      l_select_carrier_tbl(l_select_carrier_tbl.count+1).delivery_id := p_delivery_ids(i);
                      l_select_carrier_tbl(l_select_carrier_tbl.count).organization_id := l_organization_id;
                      l_select_carrier_tbl(l_select_carrier_tbl.count).planned_flag:= 'Y';
                      l_select_carrier_tbl(l_select_carrier_tbl.count).status_code :=  'OP';
                   END IF;

                   IF NVL(l_param_info.AUTO_CALC_FGT_RATE_APPEND_DEL, 'N') = 'Y' THEN
                      -- autorate delivery when appending limit is reached
                      l_auto_rate_tbl(l_auto_rate_tbl.count+1).delivery_id := p_delivery_ids(i);
                      l_auto_rate_tbl(l_auto_rate_tbl.count).organization_id := l_organization_id;
                      l_auto_rate_tbl(l_auto_rate_tbl.count).planned_flag:= 'Y';
                      l_auto_rate_tbl(l_auto_rate_tbl.count).status_code :=  'OP';
                   END IF;

                END IF;
             -- IF p_call_lcss = 'Y' and WSH_UTIL_CORE.FTE_Is_Installed = 'Y' THEN
             END IF;
          END IF;
          <<loop_end>>
          null;

       END LOOP;


    ELSE

       FOR i in p_delivery_ids.FIRST .. p_delivery_ids.LAST LOOP
          IF l_debug_on THEN
              wsh_debug_sv.logmsg(l_module_name, 'checking delivery '|| p_delivery_ids(i) );
          END IF;

          IF  p_delivery_ids(i) is NULL THEN
             goto end_of_loop;
          END IF;

             OPEN c_get_unplanned_delivery(p_delivery_ids(i));
             FETCH c_get_unplanned_delivery INTO l_organization_id, l_planned_flag, l_initial_pickup_location_id;
             IF c_get_unplanned_delivery%NOTFOUND THEN
                CLOSE c_get_unplanned_delivery;
                goto end_of_loop;
             END IF;
             CLOSE c_get_unplanned_delivery;

             IF l_debug_on THEN
                 wsh_debug_sv.logmsg(l_module_name, 'found delivery '|| p_delivery_ids(i) );
             END IF;

             l_assigned_to_trip :=  WSH_DELIVERY_VALIDATIONS.Del_Assigned_To_Trip(
	                                p_delivery_id => p_delivery_ids(i),
                                        x_return_status  => l_return_status);

             WSH_SHIPPING_PARAMS_PVT.Get(
                p_organization_id  => l_organization_id,
                x_param_info       => l_param_info,
                x_return_status    => l_return_status);

             IF l_debug_on THEN
                wsh_debug_sv.logmsg(l_module_name, 'Return status from WSH_SHIPPING_PARAMS_PVT.Get is :'||l_return_status );
             END IF;
             -- handle return status

             IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                l_num_warn := l_num_warn + 1;
             ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR OR
                   l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
                FND_MESSAGE.Set_Name('WSH', 'WSH_PARAM_NOT_DEFINED');
                FND_MESSAGE.Set_Token('ORGANIZAION_CODE',
                                       wsh_util_core.get_org_name(l_organization_id));
                wsh_util_core.add_message(x_return_status,l_module_name);
                l_num_error := l_num_error+1;
                goto end_of_loop;
             END IF;


             IF p_caller like 'WSH_%' THEN

                IF l_debug_on THEN
                   wsh_debug_sv.logmsg(l_module_name, 'appending_limit for organization '|| to_char(l_organization_id)||' is : '|| l_param_info.appending_limit );
                END IF;

                l_ignore_count := 0;
                l_delivery_detail_count := 0;

                IF l_param_info.appending_limit = G_NO_APPENDING THEN
                   goto end_of_loop;
                ELSIF l_param_info.appending_limit = G_START_OF_STAGING THEN
                   -- as long as there is a sigle line which is after staging, we should set the planned flag
                   l_num_of_staged_lines := 0;
                   OPEN c_num_of_staged_lines(p_delivery_ids(i));
                   FETCH  c_num_of_staged_lines INTO l_num_of_staged_lines;
                   CLOSE c_num_of_staged_lines;

                   IF l_num_of_staged_lines > 0 THEN
                      l_delivery_id := p_delivery_ids(i);
                      l_planned_flag := NULL;

                      DECLARE
                        record_locked_test exception;
                        PRAGMA EXCEPTION_INIT(record_locked_test, -54);
                      BEGIN
                              SELECT planned_flag  INTO l_planned_flag
                                     FROM wsh_new_deliveries
                                     WHERE delivery_id = p_delivery_ids(i) AND status_code = 'OP'
                                     AND planned_flag = 'N'
                                     FOR UPDATE NOWAIT;

                      EXCEPTION
                        WHEN record_locked_test THEN
                           IF l_debug_on THEN
                              wsh_debug_sv.logmsg(l_module_name, 'Exception record_locked_test in the block');
                           END IF;
                           -- log exception
                           IF p_caller = 'WSH_DLMG' THEN
                               -- csun deliveryMerge (warning or error)
                               FND_MESSAGE.SET_NAME('WSH', 'WSH_PLAN_DELIVERY_FAIL');
                               FND_MESSAGE.SET_TOKEN('DELIVERY_ID' , to_char(p_delivery_ids(i)));
                               l_exception_message := FND_MESSAGE.Get;

                               l_exception_id := NULL;
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
                                  p_exception_name        => 'WSH_PLAN_DELIVERY_FAIL',
                                  p_message               => substrb(l_exception_message,1,2000),
                                  p_delivery_id           => p_delivery_ids(i),
                                  p_error_message         => 'W');
                           END IF;
                           l_num_error := l_num_error + 1;
                           goto end_of_loop;

                        WHEN OTHERS THEN
                          IF l_debug_on THEN
                              wsh_debug_sv.logmsg(l_module_name,'Exception others in the block');
                             wsh_debug_sv.pop(l_module_name, 'EXCEPTION:OTHERS');
                          END IF;
                          goto end_of_loop ;

                      END;

                      IF l_planned_flag is not NULL THEN
                         -- prepare to plan the delivery
                         wsh_delivery_validations.check_plan( p_delivery_ids(i), x_return_status,p_called_for_sc);

                         IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) OR (x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                            FND_MESSAGE.SET_NAME('WSH','WSH_DEL_PLAN_ERROR');
                            --
                            -- Debug Statements
                            --
                            IF l_debug_on THEN
                                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
                            END IF;
                            --
                            FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_delivery_ids(i)));
                            wsh_util_core.add_message(x_return_status);
                            l_num_error := l_num_error + 1;
                            goto end_of_loop;
                         ELSIF (x_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
                           l_num_warn := l_num_warn + 1;
                         END IF;

                         l_dels_to_update(l_dels_to_update.count+1) := p_delivery_ids(i);
                         IF l_debug_on THEN
                            wsh_debug_sv.logmsg(l_module_name, 'Delivery '|| p_delivery_ids(i)||' is goinging to be planned');
                         END IF;

                         IF p_call_lcss = 'Y' AND WSH_UTIL_CORE.FTE_Is_Installed = 'Y' THEN
                             IF NVL(l_param_info.AUTO_APPLY_ROUTING_RULES, 'D') = 'E'
                                AND l_assigned_to_trip = 'N' THEN
                                -- call carrier selection when appending limit is reached
                                l_select_carrier_tbl(l_select_carrier_tbl.count+1).delivery_id := p_delivery_ids(i);
                                l_select_carrier_tbl(l_select_carrier_tbl.count).organization_id := l_organization_id;
                                l_select_carrier_tbl(l_select_carrier_tbl.count).planned_flag:= 'Y';
                                l_select_carrier_tbl(l_select_carrier_tbl.count).status_code :=  'OP';
                             END IF;

                             IF NVL(l_param_info.AUTO_CALC_FGT_RATE_APPEND_DEL, 'N') = 'Y' THEN
                                -- autorate delivery when appending limit is reached
                                l_auto_rate_tbl(l_auto_rate_tbl.count+1).delivery_id := p_delivery_ids(i);
                                l_auto_rate_tbl(l_auto_rate_tbl.count).organization_id := l_organization_id;
                                l_auto_rate_tbl(l_auto_rate_tbl.count).planned_flag:= 'Y';
                                l_auto_rate_tbl(l_auto_rate_tbl.count).status_code :=  'OP';
                             END IF;
                         END IF;
                      END IF;
                   ELSE
                      goto end_of_loop;
                   END IF;

                ELSIF l_param_info.appending_limit = G_END_OF_STAGING THEN
                   OPEN c_get_line_status_in_delivery(p_delivery_ids(i));
                   LOOP
                      FETCH c_get_line_status_in_delivery INTO l_released_status;
                      EXIT WHEN c_get_line_status_in_delivery%NOTFOUND;

                      l_delivery_detail_count := l_delivery_detail_count + 1;

                      IF l_released_status in ('N','R','S','B') THEN
                         l_delivery_detail_count := 0;
                         l_ignore_count := 0;
                         EXIT;
                      ELSIF l_released_status in ('X','D') THEN
                         l_ignore_count := l_ignore_count + 1;
                      END IF;

                   END LOOP;
                   CLOSE c_get_line_status_in_delivery;

                   IF l_delivery_detail_count > 0 and
                      l_delivery_detail_count - l_ignore_count > 0 THEN
                      l_delivery_id := p_delivery_ids(i);
                      l_planned_flag := NULL;
                      --
                     DECLARE
                        record_locked_test exception;
                        PRAGMA EXCEPTION_INIT(record_locked_test, -54);
                      BEGIN
                         SELECT planned_flag  INTO l_planned_flag
                            FROM wsh_new_deliveries
                            WHERE delivery_id = p_delivery_ids(i) AND status_code = 'OP'
                                  AND planned_flag = 'N'
                            FOR UPDATE NOWAIT;

                      EXCEPTION
                        WHEN record_locked_test THEN
                           IF l_debug_on THEN
                              wsh_debug_sv.logmsg(l_module_name, 'Exception record_locked_test in the block');
                           END IF;
                           -- log exception
                           IF p_caller = 'WSH_DLMG' THEN
                               -- csun deliveryMerge (warning or error)
                               FND_MESSAGE.SET_NAME('WSH', 'WSH_PLAN_DELIVERY_FAIL');
                               FND_MESSAGE.SET_TOKEN('DELIVERY_ID' , to_char(p_delivery_ids(i)));
                               l_exception_message := FND_MESSAGE.Get;

                               l_exception_id := NULL;
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
                                  p_exception_name        => 'WSH_PLAN_DELIVERY_FAIL',
                                  p_message               => substrb(l_exception_message,1,2000),
                                  p_delivery_id           => p_delivery_ids(i),
                                  p_error_message         => 'W');
                           END IF;
                           l_num_error := l_num_error + 1;
                           goto end_of_loop;

                        WHEN OTHERS THEN
                          IF l_debug_on THEN
                              wsh_debug_sv.logmsg(l_module_name,'Exception others in the block');
                             wsh_debug_sv.pop(l_module_name, 'EXCEPTION:OTHERS');
                          END IF;
                          goto end_of_loop ;

                      END;
                      --

                      IF l_planned_flag is not NULL THEN

                         -- prepare to plan the delivery
                         wsh_delivery_validations.check_plan( p_delivery_ids(i), x_return_status,p_called_for_sc);

                         IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) OR (x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                            FND_MESSAGE.SET_NAME('WSH','WSH_DEL_PLAN_ERROR');
                            --
                            -- Debug Statements
                            --
                            IF l_debug_on THEN
                                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
                            END IF;
                            --
                            FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_delivery_ids(i)));
                            wsh_util_core.add_message(x_return_status);
                            l_num_error := l_num_error + 1;
                            goto end_of_loop;
                         ELSIF (x_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
                           l_num_warn := l_num_warn + 1;
                         END IF;

                         l_dels_to_update(l_dels_to_update.count+1) := p_delivery_ids(i);
                         IF l_debug_on THEN
                            wsh_debug_sv.logmsg(l_module_name, 'Delivery '|| p_delivery_ids(i)||' is goinging to be planned');
                         END IF;

                         IF p_call_lcss = 'Y' AND WSH_UTIL_CORE.FTE_Is_Installed = 'Y' THEN



                            IF NVL(l_param_info.AUTO_APPLY_ROUTING_RULES, 'D') = 'E' AND l_assigned_to_trip = 'N' THEN
                               -- perform carrier selection when appending limit is reached
                               l_select_carrier_tbl(l_select_carrier_tbl.count+1).delivery_id := p_delivery_ids(i);
                               l_select_carrier_tbl(l_select_carrier_tbl.count).organization_id := l_organization_id;
                               l_select_carrier_tbl(l_select_carrier_tbl.count).planned_flag:= 'Y';
                               l_select_carrier_tbl(l_select_carrier_tbl.count).status_code :=  'OP';
                            END IF;

                            IF NVL(l_param_info.AUTO_CALC_FGT_RATE_APPEND_DEL, 'N') = 'Y' THEN
                               -- autoreate delivery when appending limit is reached
                               l_auto_rate_tbl(l_auto_rate_tbl.count+1).delivery_id := p_delivery_ids(i);
                               l_auto_rate_tbl(l_auto_rate_tbl.count).organization_id := l_organization_id;
                               l_auto_rate_tbl(l_auto_rate_tbl.count).planned_flag:= 'Y';
                               l_auto_rate_tbl(l_auto_rate_tbl.count).status_code :=  'OP';
                            END IF;
                         END IF;
                      END IF;
                   END IF;

                END IF;


             ELSIF p_caller like 'WMS_%' THEN

                IF p_event is NULL OR
                   p_event not in (G_START_OF_PACKING,
                                   G_START_OF_SHIPPING ) THEN
                   raise invalid_event;
                END IF;

                IF l_param_info.appending_limit = p_event  THEN
                   IF l_debug_on THEN
                      wsh_debug_sv.logmsg(l_module_name, 'Called from WMS, Appending limit '|| l_param_info.appending_limit ||' has been reached, lock and plan the delivery');
                   END IF;
                   l_delivery_id := p_delivery_ids(i);
                   l_planned_flag := NULL;

                   SELECT planned_flag  INTO l_planned_flag
                      FROM wsh_new_deliveries
                      WHERE delivery_id = p_delivery_ids(i) AND status_code = 'OP'
                      FOR UPDATE NOWAIT;

                   IF l_planned_flag is not NULL THEN
                         -- prepare to plan the delivery
                         wsh_delivery_validations.check_plan( p_delivery_ids(i), x_return_status,p_called_for_sc);

                         IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) OR (x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                            FND_MESSAGE.SET_NAME('WSH','WSH_DEL_PLAN_ERROR');
                            --
                            -- Debug Statements
                            --
                            IF l_debug_on THEN
                                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
                            END IF;
                            --
                            FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_delivery_ids(i)));
                            wsh_util_core.add_message(x_return_status);
                            l_num_error := l_num_error + 1;
                            goto end_of_loop;
                         ELSIF (x_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
                           l_num_warn := l_num_warn + 1;
                         END IF;

                      l_dels_to_update(l_dels_to_update.count+1) := p_delivery_ids(i);

                      IF l_debug_on THEN
                         wsh_debug_sv.logmsg(l_module_name, 'Delivery '|| p_delivery_ids(i)||' is goinging to be planned');
                      END IF;

                      IF p_call_lcss = 'Y' AND WSH_UTIL_CORE.FTE_Is_Installed = 'Y' THEN
                         IF NVL(l_param_info.AUTO_APPLY_ROUTING_RULES, 'D') = 'E'
                            AND l_assigned_to_trip = ' N' THEN
                            l_select_carrier_tbl(l_select_carrier_tbl.count+1).delivery_id := p_delivery_ids(i);
                            l_select_carrier_tbl(l_select_carrier_tbl.count).organization_id := l_organization_id;
                            l_select_carrier_tbl(l_select_carrier_tbl.count).planned_flag:= 'Y';
                            l_select_carrier_tbl(l_select_carrier_tbl.count).status_code :=  l_status_code;
                         END IF;

                         IF NVL(l_param_info.AUTO_CALC_FGT_RATE_APPEND_DEL, 'N') = 'Y' THEN
                            l_auto_rate_tbl(l_auto_rate_tbl.count+1).delivery_id := p_delivery_ids(i);
                            l_auto_rate_tbl(l_auto_rate_tbl.count).organization_id := l_organization_id;
                            l_auto_rate_tbl(l_auto_rate_tbl.count).planned_flag:= 'Y';
                            l_auto_rate_tbl(l_auto_rate_tbl.count).status_code :=  l_status_code;
                         END IF;
                      END IF;
                   END IF;
                END IF;

             END IF;


          <<end_of_loop>>
          NULL;

       END LOOP;

    END IF;

     IF l_select_carrier_tbl.count > 0 THEN
       IF l_debug_on THEN
          wsh_debug_sv.logmsg(l_module_name, 'Call wsh_deliveries_grp.delivery_action for '|| to_char(l_select_carrier_tbl.count)||' deliveries');
       END IF;

       l_action_prms.action_code            := 'SELECT-CARRIER';
       l_action_prms.caller                 := p_caller;
       l_action_prms.phase                  := NULL;
       l_action_prms.ignore_ineligible_dels := 'Y';
       l_action_prms.form_flag              := 'N';

       IF l_debug_on THEN
          wsh_debug_sv.logmsg(l_module_name, 'Calling wsh_deliveries_grp.delivery_action SELECT-CARRIER with '||l_select_carrier_tbl.count||' deliveries');
       END IF;

       wsh_deliveries_grp.delivery_action(
          p_api_version_number => 1.0,
          p_init_msg_list      => FND_API.G_FALSE,
          p_commit             => FND_API.G_FALSE,
          p_action_prms        => l_action_prms,
          p_rec_attr_tab       => l_select_carrier_tbl,
          x_delivery_out_rec   => l_delivery_out_rec,
          x_defaults_rec       => l_defaults_rec,
          x_return_status      => l_return_status,
          x_msg_count          => l_msg_count,
          x_msg_data           => l_msg_data);

       IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING OR
          l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR  THEN
          l_num_warn := l_num_warn + 1;
       ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR OR
           l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
           raise Select_Carrier_Err;
       END IF;

     END IF;

     IF l_auto_rate_tbl.count > 0 THEN
       IF l_debug_on THEN
          wsh_debug_sv.logmsg(l_module_name, 'Calling wsh_deliveries_grp.delivery_action GET-FREIGHT-COSTS with '||l_auto_rate_tbl.count ||' deliveries');
       END IF;

       l_action_prms.action_code            := 'GET-FREIGHT-COSTS';
       l_action_prms.caller                 := 'WSH_DLMG';
       l_action_prms.phase                  := NULL;
       l_action_prms.ignore_ineligible_dels := 'Y';

       wsh_deliveries_grp.delivery_action(
          p_api_version_number => 1.0,
          p_init_msg_list      => FND_API.G_FALSE,
          p_commit             => FND_API.G_FALSE,
          p_action_prms        => l_action_prms,
          p_rec_attr_tab       => l_auto_rate_tbl,
          x_delivery_out_rec   => l_delivery_out_rec,
          x_defaults_rec       => l_defaults_rec,
          x_return_status      => l_return_status,
          x_msg_count          => l_msg_count,
          x_msg_data           => l_msg_data);


       IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING OR
          l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR  THEN
          l_num_warn := l_num_warn + 1;
       ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
             raise Rate_Delivery_Err;
       END IF;
     END IF;


    -- plan the deliveries
    l_planned_flag_true := 'Y'; --Bugfix 3778944
    IF l_dels_to_update.count > 0 THEN
       FORALL i in l_dels_to_update.FIRST .. l_dels_to_update.LAST
        update wsh_new_deliveries
        set planned_flag = l_planned_flag_true --Bugfix 3778944
        where delivery_id = l_dels_to_update(i);
    END IF;

    IF (p_delivery_ids.count = 1) THEN
       IF (l_num_warn > 0) AND (l_num_error = 0) THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
       END IF;
    ELSIF (p_delivery_ids.count > 1) THEN
       IF (l_num_error > 0) OR (l_num_warn > 0) THEN
          FND_MESSAGE.SET_NAME('WSH','WSH_DEL_PLAN_SUMMARY');
          FND_MESSAGE.SET_TOKEN('NUM_ERROR',l_num_error);
          FND_MESSAGE.SET_TOKEN('NUM_WARN',l_num_warn);
          FND_MESSAGE.SET_TOKEN('NUM_SUCCESS',p_delivery_ids.count - l_num_error - l_num_warn);

          IF (p_delivery_ids.count = l_num_error) THEN
             x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          ELSE
             x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
          END IF;
          wsh_util_core.add_message(x_return_status);
       ELSE
          x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
       END IF;
    END IF;

    IF l_num_error > 0 and l_num_error = p_delivery_ids.count THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    ELSIF l_num_warn > 0  OR l_num_error > 0 THEN
       x_return_status  :=  WSH_UTIL_CORE.G_RET_STS_WARNING;
    END IF;

    IF l_debug_on THEN
        wsh_debug_sv.pop(l_module_name, 'Return status: '|| x_return_status);
    END IF;

   EXCEPTION

    WHEN invalid_caller THEN
      rollback to before_adjust_planned_flag;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('WSH', 'WSH_ADJUST_PLANNED_CALLER');
      wsh_util_core.add_message(x_return_status,l_module_name);

      IF l_debug_on THEN
         wsh_debug_sv.pop(l_module_name, 'EXCEPTION:invalid_caller');
      END IF;

    WHEN invalid_event THEN
      rollback to before_adjust_planned_flag;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('WSH', 'WSH_ADJUST_PLANNED_EVENT');
      wsh_util_core.add_message(x_return_status,l_module_name);

      IF l_debug_on THEN
         wsh_debug_sv.pop(l_module_name, 'EXCEPTION:invalid_appending_limit');
      END IF;

    WHEN Rate_Delivery_Err THEN
         rollback to before_adjust_planned_flag;
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

         IF l_debug_on THEN
            wsh_debug_sv.logmsg(l_module_name, 'Rate Delivery failed');
            wsh_debug_sv.pop(l_module_name, 'EXCEPTION:Rate_Delivery_Err');
         END IF;

    WHEN Select_Carrier_Err THEN
         rollback to before_adjust_planned_flag;
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

         IF l_debug_on THEN
            wsh_debug_sv.logmsg(l_module_name, 'Carrier Selection failed');
            wsh_debug_sv.pop(l_module_name, 'EXCEPTION:Select_Carrier_Err');
         END IF;

    WHEN record_locked THEN
         rollback to before_adjust_planned_flag;

         IF c_get_unplanned_delivery%ISOPEN THEN
            CLOSE c_get_unplanned_delivery;
         END IF;

         IF c_num_of_staged_lines%ISOPEN THEN
            CLOSE c_num_of_staged_lines;
         END IF;

         IF c_get_line_status_in_delivery%ISOPEN THEN
            CLOSE c_get_line_status_in_delivery;
         END IF;

         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FND_MESSAGE.Set_Name('WSH', 'WSH_DLVY_LOCK_FAILED');
         FND_MESSAGE.Set_Token('ENTITY_NAME',to_char(l_delivery_id));
         wsh_util_core.add_message(x_return_status,l_module_name);

         wsh_util_core.default_handler('WSH_NEW_DELIVERY_ACTIONS.ADJUST_PLANNED_FLAG',l_module_name);
         IF l_debug_on THEN
           wsh_debug_sv.logmsg(l_module_name,'Delivery cannot be locked, Oracle error message is ' || SQLERRM);
           wsh_debug_sv.pop(l_module_name, 'EXCEPTION:record_locked');
         END IF;

    WHEN OTHERS THEN
         rollback to before_adjust_planned_flag;

         IF c_get_unplanned_delivery%ISOPEN THEN
            CLOSE c_get_unplanned_delivery;
         END IF;

         IF c_num_of_staged_lines%ISOPEN THEN
            CLOSE c_num_of_staged_lines;
         END IF;

         IF c_get_line_status_in_delivery%ISOPEN THEN
            CLOSE c_get_line_status_in_delivery;
         END IF;

         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         wsh_util_core.add_message(x_return_status,l_module_name);
         wsh_util_core.default_handler('WSH_DELIVERY_ACTIONS.ADJUST_PLANNED_FLAG',l_module_name);
         IF l_debug_on THEN
            wsh_debug_sv.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is ' || SQLERRM);
            wsh_debug_sv.pop(l_module_name, 'EXCEPTION:OTHERS');
         END IF;


END Adjust_Planned_Flag;

--
-- Procedure: Plan
-- Parameters:  p_del_rows - Delivery_Ids of deliveries to be planned
--    x_return_status - status of procedure call
-- Description: This procedure will Plan deliveries for shipment
--

PROCEDURE Plan
   (p_del_rows   IN  wsh_util_core.id_tab_type,
    x_return_status  OUT NOCOPY  VARCHAR2,
    p_called_for_sc  IN    BOOLEAN default false) IS


   others    EXCEPTION;


  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PLAN';
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

   Adjust_Planned_Flag(
      p_delivery_ids          => p_del_rows,
      p_caller                => 'WSH_DLMG',
      p_force_appending_limit => 'Y',
      p_call_lcss             => 'Y',
      x_return_status         => x_return_status,
      p_called_for_sc         => p_called_for_sc);


   --
   -- Debug Statements
   --
   IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
   END IF;

EXCEPTION
   WHEN others THEN
   wsh_util_core.default_handler('WSH_NEW_DELIVERY_ACTIONS.PLAN');
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


--
-- Procedure: Unplan
-- Parameters:  p_del_rows - Delivery_ids of deliveries to be unplanned
--    x_return_status - status of procedure call
-- Description: This procedure will unplan deliveries for shipment
--

  PROCEDURE Unplan
    (p_del_rows   IN  wsh_util_core.id_tab_type,
     x_return_status  OUT NOCOPY  VARCHAR2) IS

  l_num_error   NUMBER := 0;
  l_num_warn    NUMBER := 0;
  others    EXCEPTION;
  l_return_status  VARCHAR2(1);
  l_planned_flag_false       WSH_NEW_DELIVERIES.PLANNED_FLAG%TYPE; --bugfix 3778944

CURSOR c_isdelfirm(p_delid IN NUMBER) IS
select 'Y'
from wsh_new_deliveries
where delivery_id=p_delid AND
planned_flag='F';

l_delfirm VARCHAR2(1);

  --
l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UNPLAN';
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

  FOR i IN 1..p_del_rows.count LOOP

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_VALIDATIONS.CHECK_UNPLAN',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    wsh_delivery_validations.check_unplan( p_del_rows(i), x_return_status);

    IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) OR (x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_DEL_UNPLAN_ERROR');
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_del_rows(i)));
      wsh_util_core.add_message(x_return_status);
      l_num_error := l_num_error + 1;
    ELSE

      IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
        l_num_warn := l_num_warn + 1;
      END IF;

      l_delfirm:='N';
      FOR cur IN c_isdelfirm(p_del_rows(i)) LOOP
         l_delfirm:='Y';
         wsh_tp_release.unfirm_entity( p_entity      => 'DLVY',
                                     p_entity_id     =>p_del_rows(i),
                                     p_action        =>'UNPLAN',
                                     x_return_status =>x_return_status);
         IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
           IF x_return_status=WSH_UTIL_CORE.G_RET_STS_WARNING THEN
              l_num_warn := l_num_warn + 1;
           ELSE
              l_num_error := l_num_error + 1;
           END IF;
         END IF;
      END LOOP;

     IF l_delfirm='N' THEN
      -- Set planned flag to 'N'
        l_planned_flag_false := 'N'; --bugfix 3778944

        UPDATE wsh_new_deliveries
        SET planned_flag = l_planned_flag_false  --bugfix 3778944
        WHERE  delivery_id = p_del_rows(i);

        IF (SQL%NOTFOUND) THEN
          FND_MESSAGE.SET_NAME('WSH','WSH_DEL_NOT_FOUND');
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          wsh_util_core.add_message(x_return_status);
          l_num_error := l_num_error + 1;
        END IF;
     END IF;--l_del_firm=N

    END IF;

  END LOOP;


  IF (p_del_rows.count = 1) THEN
    IF (l_num_warn > 0) AND (l_num_error = 0) THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    END IF;
  ELSIF (p_del_rows.count > 1) THEN

    IF (l_num_error > 0) THEN

      FND_MESSAGE.SET_NAME('WSH','WSH_DEL_UNPLAN_SUMMARY');
      FND_MESSAGE.SET_TOKEN('NUM_ERROR',l_num_error);
      FND_MESSAGE.SET_TOKEN('NUM_SUCCESS',p_del_rows.count - l_num_error);

      IF (p_del_rows.count = l_num_error) THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      ELSE
         x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      END IF;

      wsh_util_core.add_message(x_return_status);
    ELSIF (l_num_warn > 0) THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
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
     wsh_util_core.default_handler('WSH_NEW_DELIVERY_ACTIONS.UNPLAN');
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
  END Unplan;

  PROCEDURE create_bol (
     p_delivery_id IN NUMBER,
     x_return_status OUT NOCOPY  VARCHAR2) IS

  CURSOR get_delivery_info IS
  SELECT dg.delivery_leg_id,
    dl.initial_pickup_location_id,
    t.ship_method_code,
    dl.organization_id,
    t.name
  FROM   wsh_new_deliveries dl,
    wsh_delivery_legs dg,
    wsh_trip_stops st,
    wsh_trips t
  WHERE  dl.delivery_id = p_delivery_id AND
    dl.delivery_id = dg.delivery_id AND
    dg.pick_up_stop_id = st.stop_id AND
    st.trip_id = t.trip_id;

 --performance fix : changed to get_ledger_id (LE Uptake) to get it from hr_organization_information
  --instead of org_organization_definitions
  CURSOR get_ledger_id (l_org_id NUMBER) IS
  SELECT hoi.org_information1 ledger_id
  from hr_organization_information hoi
  WHERE hoi.organization_id = l_org_id
  AND hoi.org_information_context = 'Accounting Information';

  --
  l_ledger_id  NUMBER;  --LE Uptake
  l_delivery_leg_id  NUMBER;
  l_pickup_location_id  NUMBER;
  l_ship_method_code  VARCHAR2(30);
  l_organization_id  NUMBER;
  l_document_number  VARCHAR2(50);
  l_pack_slip_flag    VARCHAR2(1);
  l_trip_name	      VARCHAR2(50);
  --
  x_msg_count      NUMBER;
  x_msg_data      VARCHAR2(2000);
  --
  wsh_create_document_error EXCEPTION;
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_BOL';
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
    --
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
    --
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  --
  OPEN  get_delivery_info;
  FETCH get_delivery_info INTO l_delivery_leg_id,
               l_pickup_location_id,
               l_ship_method_code,
               l_organization_id,
	       l_trip_name;
  CLOSE get_delivery_info;

   /* BUG 1393429
  SELECT ood.set_of_books_id INTO l_set_of_books_id
  FROM   org_organization_definitions ood
  WHERE  ood.organization_id = l_organization_id;
   */
--LE Uptake
  OPEN  get_ledger_id(l_organization_id);
  FETCH  get_ledger_id INTO l_ledger_id;

  IF (get_ledger_id%NOTFOUND) THEN
     FND_MESSAGE.SET_NAME('WSH','WSH_LEDGER_ID_NOT_FOUND');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    wsh_util_core.add_message(x_return_status);
     CLOSE get_ledger_id; -- bug  2045315
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
     RETURN;
  END IF;

  CLOSE  get_ledger_id;     --LE Uptake


  SAVEPOINT sp1;

  -- Create BOL

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'l_ship_method_code', l_ship_method_code);
  END IF;

  --
  -- Bug 2712087 : Do not create BOL if ship method is NULL
  --
  IF l_ship_method_code IS NULL THEN
   --
   IF l_debug_on THEN
    --
    WSH_DEBUG_SV.logmsg(l_module_name, 'Null ship Method, so do not create BOL');
    --
   END IF;
   --
   FND_MESSAGE.SET_NAME('WSH','WSH_BOL_NULL_SHIP_METHOD_ERROR');
   FND_MESSAGE.SET_TOKEN('TRIP_NAME', l_trip_name);
   x_return_status := wsh_util_core.g_ret_sts_error;
   wsh_util_core.add_message(x_return_status);
   --
   RAISE wsh_create_document_error;
   --

  ELSE
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DOCUMENT_PVT.CREATE_DOCUMENT',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    wsh_document_pvt.create_document
     (1.0,
      'F',
      NULL,
      NULL,
      x_return_status,
      x_msg_count,
      x_msg_data,
      'WSH_DELIVERY_LEGS',
      l_delivery_leg_id,
      665,
      l_pickup_location_id,
      'BOL',
      l_ship_method_code,
      /* Commented for Bugfix#1918342
      NULL, -- p_pod_flag,
      NULL, -- p_pod_by,
      NULL, -- p_pod_date,
      NULL, -- p_reason_of_transport,
      NULL, -- p_description,
      NULL, -- p_cod_amount,
      NULL, -- p_cod_currency_code,
      NULL, -- p_cod_remit_to,
      NULL, -- p_cod_charge_paid_by,
      NULL, -- p_problem_contact_reference,
      NULL, -- p_bill_freight_to,
      NULL, -- p_carried_by,
      NULL, -- p_port_of_loading,
      NULL, -- p_port_of_discharge,
      NULL, -- p_booking_office,
      NULL, -- p_booking_number,
      NULL, -- p_service_contract,
      NULL, -- p_shipper_export_ref,
      NULL, -- p_carrier_export_ref,
      NULL, -- p_bol_notify_party,
      NULL, -- p_supplier_code,
      NULL, -- p_aetc_number,
      NULL, -- p_shipper_signed_by,
      NULL, -- p_shipper_date,
      NULL, -- p_carrier_signed_by,
      NULL, -- p_carrier_date,
      NULL, -- p_bol_issue_office,
      NULL, -- p_bol_issued_by,
      NULL, -- p_bol_date_issued,
      NULL, -- p_shipper_hm_by,
      NULL, -- p_shipper_hm_date,
      NULL, -- p_carrier_hm_by,
      NULL, -- p_carrier_hm_date,     */
      l_ledger_id,
      'BOTH',
      200,
      l_document_number
     );
   --
   IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
     RAISE wsh_create_document_error;
   END IF;
   --
  END IF; /* if ship_method_code is null */
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
   EXCEPTION

    WHEN wsh_create_document_error THEN
     ROLLBACK TO sp1;
     x_return_status := wsh_util_core.g_ret_sts_error;
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'WSH_CREATE_DOCUMENT_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_CREATE_DOCUMENT_ERROR');
     END IF;
     --
  END create_bol;

-- Create Pack Slip

  PROCEDURE create_pack_slip (
            p_delivery_id IN NUMBER,
            x_return_status OUT NOCOPY  VARCHAR2) IS

  CURSOR get_delivery_info IS
  SELECT dl.initial_pickup_location_id,
    dl.organization_id
  FROM   wsh_new_deliveries dl
  WHERE  dl.delivery_id = p_delivery_id;

  CURSOR pack_slip_required (l_org_id NUMBER) IS
  SELECT pack_slip_required_flag
  FROM   wsh_shipping_parameters
  WHERE  organization_id = l_org_id;

  CURSOR get_pack_slip_number IS
  SELECT packing_slip_number
  FROM   wsh_packing_slips_db_v
  WHERE  delivery_id = p_delivery_id;

  --LE Uptake
 --performance fix : changed to get ledger_id to get it from hr_organization_information
  --instead of org_organization_definitions
  CURSOR get_ledger_id (l_org_id NUMBER) IS
  SELECT hoi.org_information1 ledger_id
  from hr_organization_information hoi
  WHERE hoi.organization_id = l_org_id
  AND hoi.org_information_context = 'Accounting Information';

  l_ledger_id  NUMBER;
  l_delivery_leg_id  NUMBER;
  l_pickup_location_id  NUMBER;
  l_ship_method_code  VARCHAR2(30);
  l_organization_id  NUMBER;
  l_document_number  VARCHAR2(50);
  l_pack_slip_flag    VARCHAR2(1) := NULL;
  l_pack_slip_number  VARCHAR2(50) := NULL;

  x_msg_count      NUMBER;
  x_msg_data      VARCHAR2(2000);


  wsh_create_document_error EXCEPTION;

   --
l_debug_on BOOLEAN;
   --
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_PACK_SLIP';
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
      WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  OPEN  get_delivery_info;
  FETCH get_delivery_info INTO l_pickup_location_id,
                l_organization_id;
  CLOSE get_delivery_info;

  /* BUG 1393429
  SELECT ood.set_of_books_id INTO l_set_of_books_id
  FROM   org_organization_definitions ood
  WHERE  ood.organization_id = l_organization_id;
  */

--LE Uptake
  OPEN  get_ledger_id(l_organization_id);
  FETCH  get_ledger_id INTO l_ledger_id;

  IF (get_ledger_id%NOTFOUND) THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_LEDGER_ID_NOT_FOUND');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    wsh_util_core.add_message(x_return_status);
    CLOSE  get_ledger_id; -- bug 2045315
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    RETURN;
  END IF;

  CLOSE  get_ledger_id;


/* Bug: 1527393
  OPEN  pack_slip_required (l_organization_id);
  FETCH pack_slip_required INTO l_pack_slip_flag;
  CLOSE pack_slip_required;
*/
  OPEN get_pack_slip_number;
  FETCH get_pack_slip_number INTO l_pack_slip_number;
  CLOSE get_pack_slip_number;

  SAVEPOINT sp2;
-- Bug: 1527393 Packslip should be generated irrespective of the required_flag in wsh_shipping_parameters.
  IF (l_pack_slip_number IS NULL) THEN
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DOCUMENT_PVT.CREATE_DOCUMENT',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     wsh_document_pvt.create_document
     (
       p_api_version        => 1.0,
       p_init_msg_list        => 'F',
       p_commit          => NULL,
       p_validation_level      => NULL,
       x_return_status        => x_return_status,
       x_msg_count          => x_msg_count,
       x_msg_data          => x_msg_data,
       p_entity_name        => 'WSH_NEW_DELIVERIES',
       p_entity_id          => p_delivery_id,
       p_application_id      => 665,
       p_location_id        => l_pickup_location_id,
       p_document_type        => 'PACK_TYPE',
       p_document_sub_type      => 'SALES_ORDER',
/* Commented for Bugfix#1918342
       p_pod_flag          => NULL, -- p_pod_flag,
       p_pod_by          => NULL, -- p_pod_by,
       p_pod_date          => NULL, -- p_pod_date,
       p_reason_of_transport    => NULL, -- p_reason_of_transport,
       p_description        => NULL, -- p_description,
       p_cod_amount        => NULL, -- p_cod_amount,
       p_cod_currency_code      => NULL, -- p_cod_currency_code,
       p_cod_remit_to        => NULL, -- p_cod_remit_to,
       p_cod_charge_paid_by    => NULL, -- p_cod_charge_paid_by,
       p_problem_contact_reference  => NULL, -- p_problem_contact_reference,
       p_bill_freight_to      => NULL, -- p_bill_freight_to,
       p_carried_by        => NULL, -- p_carried_by,
       p_port_of_loading      => NULL, -- p_port_of_loading,
       p_port_of_discharge      => NULL, -- p_port_of_discharge,
       p_booking_office      => NULL, -- p_booking_office,
       p_booking_number      => NULL, -- p_booking_number,
       p_service_contract      => NULL, -- p_service_contract,
       p_shipper_export_ref    => NULL, -- p_shipper_export_ref,
       p_carrier_export_ref    => NULL, -- p_carrier_export_ref,
       p_bol_notify_party      => NULL, -- p_bol_notify_party,
       p_supplier_code        => NULL, -- p_supplier_code,
       p_aetc_number        => NULL, -- p_aetc_number,
       p_shipper_signed_by      => NULL, -- p_shipper_signed_by,
       p_shipper_date        => NULL, -- p_shipper_date,
       p_carrier_signed_by      => NULL, -- p_carrier_signed_by,
       p_carrier_date        => NULL, -- p_carrier_date,
       p_bol_issue_office      => NULL, -- p_bol_issue_office,
       p_bol_issued_by        => NULL, -- p_bol_issued_by,
       p_bol_date_issued      => NULL, -- p_bol_date_issued,
       p_shipper_hm_by        => NULL, -- p_shipper_hm_by,
       p_shipper_hm_date      => NULL, -- p_shipper_hm_date,
       p_carrier_hm_by        => NULL, -- p_carrier_hm_by,
       p_carrier_hm_date      => NULL, -- p_carrier_hm_date,       */
       p_ledger_id      => l_ledger_id,     --LE Uptake
       p_consolidate_option    => 'BOTH',
       p_manual_sequence_number  => 200,
       x_document_number      => l_document_number
     );

     IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      RAISE wsh_create_document_error;
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

    WHEN wsh_create_document_error THEN
     ROLLBACK TO sp2;
     x_return_status := wsh_util_core.g_ret_sts_error;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_CREATE_DOCUMENT_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_CREATE_DOCUMENT_ERROR');
END IF;
--
 END create_pack_slip;


--  PROCEDURE Get_Delivery_Defaults
--  Ship confirm rule logic has been removed and moved
--  to UI and Integration API for Public API
--  This procedure will only derive the applicable defaults
--  based on input deliveries; the calling UI and integration API
--  will finalize the ship method based on ship confirm rule.
--  (references: frontport bugs 4310141 and 4178235)
PROCEDURE Get_Delivery_Defaults
    (p_del_rows               IN              wsh_util_core.id_tab_type,
     p_org_ids                IN              wsh_util_core.id_tab_type,
     p_client_ids             IN	      wsh_util_core.id_tab_type,	--Modified R12.1.1 LSP PROJECT
     p_ship_method_code_vals  IN              ship_method_type,
     x_autointransit_flag        OUT NOCOPY   VARCHAR2,
     x_autoclose_flag            OUT NOCOPY   VARCHAR2,
     x_report_set_id             OUT NOCOPY   NUMBER,   -- always NULL
     x_report_set_name           OUT NOCOPY   VARCHAR2, -- always NULL
     x_ship_method_name          OUT NOCOPY   VARCHAR2,
     x_return_status             OUT NOCOPY   VARCHAR2,
     x_sc_rule_id                OUT NOCOPY   NUMBER,
     x_ac_bol_flag               OUT NOCOPY   VARCHAR2,
     x_defer_interface_flag      OUT NOCOPY   VARCHAR2,
     x_sc_rule_name              OUT NOCOPY   VARCHAR2  -- always NULL

     ) IS

  CURSOR Report_Set (p_report_set_id NUMBER) IS
  SELECT rs.name,
    rs.report_set_id
  FROM wsh_report_sets rs
  WHERE rs.report_set_id = p_report_set_id;

  CURSOR Check_Trip (l_delivery_id NUMBER) IS
  select wts.trip_id
  from wsh_delivery_legs wdl, wsh_trip_stops wts
  where wdl.pick_up_stop_id=wts.stop_id
  and wdl.delivery_id=l_delivery_id
  and rownum=1;

  CURSOR sm_name(x_ship_method_code IN VARCHAR2) is
   SELECT meaning
   FROM   fnd_lookup_values_vl
   WHERE  lookup_code = x_ship_method_code
   AND  lookup_type = 'SHIP_METHOD'
   AND  view_application_id = 3;

-- Use Ship Confirm Rule for the Organization
-- Also, get the default values for the Rule
  CURSOR get_sc_rule (p_ship_confirm_rule_id NUMBER) IS
  SELECT wsc.name,
         wsc.ship_confirm_rule_id,
         wsc.ac_intransit_flag,
         wsc.ac_close_trip_flag,
         wsc.ac_bol_flag,
         wsc.ac_defer_interface_flag,
         wsc.report_set_id,
         wsc.ship_method_code,
         wsc.effective_end_date
    FROM wsh_ship_confirm_rules wsc
    WHERE wsc.ship_confirm_rule_id = p_ship_confirm_rule_id;

  l_trip_id              NUMBER;
  l_prev_organization_id NUMBER; -- to find out the Prev. Org. Id
  l_organization_id      NUMBER;
  l_all_orgids_match     BOOLEAN := TRUE;
  l_param_info           WSH_SHIPPING_PARAMS_PVT.Parameter_Rec_Typ;

  l_num_warn             NUMBER := 0;
  l_count                NUMBER := 0;

  temp_ship_method_code VARCHAR2(30);
  dist_ship_method_code VARCHAR2(30);

  trip_options          BOOLEAN := FALSE;
  ship_method_options   BOOLEAN := FALSE;
  first_ship_method     BOOLEAN := TRUE;
  l_last_del            BOOLEAN := FALSE;
  l_return_status       VARCHAR2(1);

  /*Modified R12.1.1 LSP PROJECT*/
  l_Client_id           NUMBER ;
  l_client_params       INV_CACHE.ct_rec_type;

  l_sc_rule_id  NUMBER;
  l_report_set_id  NUMBER;
  l_prev_Client_id NUMBER; -- to find out the Prev. Client Id
  /*Modified R12.1.1 LSP PROJECT*/

  others EXCEPTION;

  -- frontport bug 4310141 / Bug 4103142 - to get first trip for delivery
  CURSOR c_first_ship_method (p_delivery_id IN number)IS
  SELECT  wt.ship_method_code
  FROM    wsh_new_deliveries del,
          wsh_delivery_legs dlg,
          wsh_trip_stops st,
          wsh_trips wt
  WHERE   del.delivery_id = dlg.delivery_id
  AND     dlg.pick_up_stop_id = st.stop_id
  AND     del.initial_pickup_location_id = st.stop_location_id
  AND     st.trip_id = wt.trip_id
  AND     del.delivery_id = p_delivery_id
  AND     rownum < 3;



  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_DELIVERY_DEFAULTS';
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
      WSH_DEBUG_SV.logmsg(l_module_name,'Delivery Count'||p_del_rows.count);
      WSH_DEBUG_SV.logmsg(l_module_name,'Org id Count'||p_org_ids.count);
      WSH_DEBUG_SV.logmsg(l_module_name,'Ship Method Count'||p_ship_method_code_vals.count);
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    l_all_orgids_match := TRUE;

    IF (p_del_rows.count = 0) THEN
      RAISE others;
    END IF;

    l_count := p_org_ids.count;

    IF (p_org_ids.count = 1) THEN
      l_all_orgids_match := TRUE;
      l_organization_id  := p_org_ids(1);
      l_client_id        := p_client_ids(1); --Modified R12.1.1 LSP PROJECT
    END IF;

    IF (p_org_ids.count > 1) THEN
     begin
      FOR i IN 1..p_org_ids.count LOOP

       l_organization_id := p_org_ids(i);
       l_client_id       := p_client_ids(i); --Modified R12.1.1 LSP PROJECT
       IF ( i = 1 ) THEN
        l_prev_organization_id := l_organization_id;
        l_prev_client_id := l_client_id;      --Modified R12.1.1 LSP PROJECT
       END IF;

       IF  (l_prev_organization_id <> l_organization_id) OR (NVL(l_prev_client_id,-1) <> NVL(l_client_id,-1)) THEN
        l_all_orgids_match := FALSE;
        EXIT;  -- Exit from loop as soon as Orgs. differ
       END IF;
       l_prev_organization_id := l_organization_id;
      END LOOP;
     end;
    END IF;

    x_autointransit_flag := 'N';
    x_autoclose_flag     := 'N';


    IF (l_all_orgids_match = TRUE) THEN --{
     /*Modified R12.1.1 LSP PROJECT (rminocha)*/
      IF ( l_client_id IS NOT NULL ) THEN
      --{
           IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name, 'Calling INV_CACHE.GET_CLIENT_DEFAULT_PARAMETERS', WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           INV_CACHE.GET_CLIENT_DEFAULT_PARAMETERS(
               p_client_id             => l_client_id,
               x_client_parameters_rec => l_client_params,
               x_return_status         => l_return_status);

          l_param_info.delivery_report_set_id := l_client_params.client_rec.delivery_report_set_id;
          l_param_info.ship_confirm_rule_id :=l_client_params.client_rec.ship_confirm_rule_id;

      ELSE
/*Modified R12.1.1 LSP PROJECT*/

      WSH_SHIPPING_PARAMS_PVT.Get(
                       p_organization_id => l_organization_id,
                       x_param_info      => l_param_info,
                       x_return_status   => l_return_status);

      END IF;								--Modified R12.1.1 LSP PROJECT

      OPEN report_set(l_param_info.delivery_report_set_id);
      FETCH report_set INTO x_report_set_name, x_report_set_id;
      CLOSE report_set;

      -- Assign Ship Confirm Rule back to OUT parameter
      x_sc_rule_id := l_param_info.ship_confirm_rule_id;
    END IF; --}


    dist_ship_method_code  := '';

    -- Bug 2213342 : Ship Confirm Defaulting behavior
    FOR i IN 1..p_del_rows.count LOOP
      -- Find trip for the delivery
      l_trip_id := NULL;
      OPEN Check_Trip( p_del_rows (i));
      FETCH Check_Trip INTO l_trip_id;
      IF Check_Trip%NOTFOUND THEN
       l_trip_id := NULL;
      END IF;
      CLOSE Check_Trip;

      IF (l_trip_id IS NULL) THEN
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Trip id is null for delivery-'||p_del_rows(i))
;
        END IF;

        -- Check to see if Trip Options are already set
        IF NOT trip_options THEN
          trip_options := TRUE;
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Set Trip Options');
          END IF;

          x_autointransit_flag := 'Y';
          x_autoclose_flag     := 'Y';
        END IF;

        -- Check to see if Ship Method has to be set
        -- for Deliveries with Autocreate Trip
        IF NOT ship_method_options THEN
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Ship Method Options');
          END IF;

          IF first_ship_method THEN
            -- Initialize First Applicable Ship Method
            dist_ship_method_code := p_ship_method_code_vals(i);
            first_ship_method     := FALSE;
          END IF;
          temp_ship_method_code := p_ship_method_code_vals(i);
          IF NVL(temp_ship_method_code,' ') = NVL(dist_ship_method_code,' ') THEN
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Ship Methods are same null');
            END IF;

            NULL;
          ELSE
            -- Ship Methods are different for Deliveries, so Null Ship Method is returned
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Ship Methods are different');
            END IF;

            dist_ship_method_code := NULL;
            ship_method_options    := TRUE;
          END IF;
        END IF;
      ELSE  -- trip_id is not null, trip exists

        -- Find if this is the last delivery on the trip,
        -- then enable close options
        l_last_del := check_last_del_trip(p_del_rows(i));

        IF l_last_del THEN
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Last Delivery in Trip-'||p_del_rows(i));
          END IF;
          trip_options := TRUE; -- trip options should be allowed
          x_autointransit_flag := 'Y';
          x_autoclose_flag     := 'Y';
        END IF;
      END IF;
    END LOOP;

    -- frontport bug 4178235: Fix for bug 4147636
    -- Trip options viz. intransit flag, close trip flag, defer interface flag
    -- need to be disabled in the ship confirm dialogue box for cases
    -- where delivery is assigned to a trip and it is not the Final delivery
    -- in that trip.
    -- Earlier logic (before this fix) depended on setting autointransit_flag=N
    -- and autoclose_flag=N , so that UI could disable the trip options.
    --
    -- Issue with this logic is that the same two flags could be set to N
    -- because of ship confirm Rule.
    --
    -- To avoid conflict with values set by ship confirm rule,
    -- New Logic uses autointransit=D  and autoclose=D, (disable),
    -- so that UI should disable the trip options.
    --
    -- flags are set to Y or N depending on
    -- default value or based on the available ship confirm rule.

    IF NOT trip_options THEN
       x_autointransit_flag   := 'D';
       x_autoclose_flag       := 'D';
    END IF;

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'End Report Set id'||x_report_set_id);
      WSH_DEBUG_SV.logmsg(l_module_name,'End Report Set Name'||x_report_set_name);
      WSH_DEBUG_SV.logmsg(l_module_name,'End Ship Confirm Rule'||x_sc_rule_name);
      WSH_DEBUG_SV.logmsg(l_module_name,'End Ship Confirm Rule id'||x_sc_rule_id);
      WSH_DEBUG_SV.logmsg(l_module_name,'End In transit'||x_autointransit_flag);
      WSH_DEBUG_SV.logmsg(l_module_name,'End Close '||x_autoclose_flag);
      WSH_DEBUG_SV.logmsg(l_module_name,'End BOL flag '||x_ac_bol_flag);
      WSH_DEBUG_SV.logmsg(l_module_name,'End Defer Interface flag '||x_defer_interface_flag);
      WSH_DEBUG_SV.logmsg(l_module_name,'End ship method '||x_ship_method_name);
    END IF;

    -- frontport bug 4310141:
    -- Bug 4103142 defaulted ship method from first trip
    IF (p_del_rows.count = 1) AND x_ship_method_name IS NULL THEN
      -- 42588951: default trip only if rule not specified.
      -- dist_ship_method_code has the delivery's SM value.
      -- so that if the trip exists and has null SM, we can use delivery's SM.
      IF dist_ship_method_code IS NULL THEN
        dist_ship_method_code := p_ship_method_code_vals(1);
      END IF;

      OPEN c_first_ship_method (p_del_rows(1));
      FETCH c_first_ship_method INTO temp_ship_method_code;
      IF c_first_ship_method%NOTFOUND THEN
        temp_ship_method_code := NULL;
      ELSE
        IF temp_ship_method_code IS NOT NULL THEN
          dist_ship_method_code := temp_ship_method_code;
        END IF;
      END IF;
      CLOSE c_first_ship_method;
    END IF;

    IF x_ship_method_name IS NULL AND dist_ship_method_code IS NOT NULL THEN
      OPEN  sm_name(dist_ship_method_code);
      FETCH sm_name into x_ship_method_name;
      CLOSE sm_name;
    END IF;

    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --

  EXCEPTION
    WHEN others THEN
      wsh_util_core.default_handler('WSH_NEW_DELIVERY_ACTIONS.Get_Delivery_Defaults');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
  END Get_Delivery_Defaults;


-- Procedure: Confirm_Delivery
-- Parameters:  p_del_rows   - Delivery_ids of deliveries to be confirmed
--       p_action_flag   - 'S' for Ship Entered, Ship Unspecified Full
--                         'B' for Ship Entered, Backorder Unspecified
--                         'A' Ship All
--       p_intransit_flag - 'Y' for autocreate_trip closes first stop
--       p_close_flag - 'Y' closes autocreated trip and stops
--       p_stage_del_flag - 'Y' creates a new delivery for the staged lines
--       p_report_set_id - report set for delivery
--       p_ship_method - ship method for autocreated trip
--       p_actual_dep_date - actual departure date for pickup stop on autocreated trip
--       p_defer_interface_flag - 'Y' to skip concurrent program submission, bug 1578251
--       p_send_945_flag - 'Y' to trigger outbound shipment advice for delivery with WSH lines
--       x_return_status - status of procedure call
-- Description: This procedure will update shipped quantities of the details
--        on each delivery and confirms each delivery
--

  PROCEDURE Confirm_Delivery
    (p_del_rows   IN  wsh_util_core.id_tab_type,
     p_action_flag    IN  VARCHAR2,
     p_intransit_flag IN  VARCHAR2,
     p_close_flag    IN   VARCHAR2,
     p_stage_del_flag   IN   VARCHAR2,
     p_report_set_id  IN   NUMBER,
     p_ship_method    IN   VARCHAR2,
     p_actual_dep_date  IN   DATE,
     p_bol_flag    IN   VARCHAR2,
     p_mc_bol_flag    IN VARCHAR2,
     p_defer_interface_flag  IN VARCHAR2,
     p_send_945_flag  IN   VARCHAR2,
     p_autocreate_trip_flag  IN   varchar2 default 'Y',--heali :Shipment Advice change for trip Consolidation.
     x_return_status  OUT NOCOPY  VARCHAR2,
     p_caller               IN   VARCHAR2) IS


  record_locked        EXCEPTION;
  PRAGMA EXCEPTION_INIT(record_locked, -54);

  ship_confirm_error      EXCEPTION;

  -- Bug 1729723 : Updating number_of_lpn for delivery
  CURSOR number_of_lpn(l_delivery_id NUMBER) IS
  SELECT count(distinct wda.delivery_detail_id)
  FROM   wsh_delivery_assignments_v wda
  WHERE  wda.parent_delivery_detail_id is null
  AND LEVEL > 1
  CONNECT BY PRIOR wda.parent_delivery_detail_id = wda.delivery_detail_id
  START WITH wda.delivery_id = l_delivery_id;

  CURSOR Report_Set (l_organization_id NUMBER) IS
  SELECT rs.name, rs.report_set_id
  FROM   wsh_shipping_parameters sp,
      wsh_report_sets rs
  WHERE  sp.organization_id = l_organization_id AND
      rs.report_set_id = sp.delivery_report_set_id;

  CURSOR del_legs (l_delivery_id NUMBER) IS
  SELECT l1.pick_up_stop_id, l1.drop_off_stop_id, l1.delivery_leg_id, l2.delivery_id parent_delivery_id
  FROM   wsh_delivery_legs l1, wsh_delivery_legs l2
  WHERE  l1.delivery_id = l_delivery_id
  AND    l1.parent_delivery_leg_id = l2.delivery_leg_id(+);


  CURSOR get_consol_del (l_delivery_id NUMBER) IS
  SELECT l2.delivery_id parent_delivery_id
  FROM   wsh_delivery_legs l1, wsh_delivery_legs l2
  WHERE  l1.delivery_id = l_delivery_id
  AND    l1.parent_delivery_leg_id = l2.delivery_leg_id;



---BUG No:4241880.Cursor changed
  CURSOR get_freight(p_ship_method_code VARCHAR2,p_organization_id NUMBER) IS
  SELECT freight_code
  FROM   wsh_carriers wc,wsh_carrier_services wcs,wsh_org_carrier_services wocs
  WHERE  wc.carrier_id=wcs.carrier_id AND
	 wcs.carrier_service_id=wocs.carrier_service_id AND
	 wcs.ship_method_code = p_ship_method_code AND
	 wocs.organization_id = p_organization_id;
---BUG No:4241880.Cursor changed ends

/*
  CURSOR get_freight(p_ship_method_code VARCHAR2,p_organization_id NUMBER) IS -- Can this go ?!! pdo
  SELECT freight_code
  FROM   wsh_carrier_ship_methods_v
  WHERE  ship_method_code = p_ship_method_code AND
     organization_id = p_organization_id;
*/

  CURSOR user_name(l_user_id NUMBER ) is
  SELECT user_name
  FROM fnd_user
  WHERE user_id = l_user_id;

  CURSOR detail_info ( v_delivery_id in number ) IS
  SELECT da.parent_delivery_detail_id,
     dd.delivery_detail_id,
     dd.released_status ,
     dd.inspection_flag  ,
     dd.shipped_quantity ,
     dd.shipped_quantity2 ,
     dd.cycle_count_quantity ,
     dd.cycle_count_quantity2 ,
     dd.requested_quantity  ,
     dd.requested_quantity2 ,
     NVL(dd.picked_quantity,  dd.requested_quantity)  pick_qty,  -- overpicking
     NVL(dd.picked_quantity2, dd.requested_quantity2) pick_qty2,
     dd.organization_id ,
     dd.inventory_item_id ,
     dd.subinventory ,
     dd.locator_id,
     dd.source_code,   /*Bug 2096052 for OKE */
     dd.source_line_id		-- Consolidation of BO Delivery Details project
  FROM   wsh_delivery_details dd,
     wsh_delivery_assignments_v da
  WHERE  da.delivery_id = v_delivery_id AND
      da.delivery_id IS NOT NULL AND
      da.delivery_detail_id = dd.delivery_detail_id AND
      dd.container_flag = 'N';


  CURSOR Get_Trip(v_del_id NUMBER) IS
  SELECT wt.trip_id , wt.carrier_id, wt.ship_method_code, wt.mode_of_transport,
         --OTM R12
         wt.tp_plan_name
         --
  FROM wsh_delivery_legs wdl, wsh_trip_stops wts, wsh_trips wt
  WHERE wdl.pick_up_stop_id=wts.stop_id
  AND wdl.delivery_id=v_del_id
  AND wts.trip_id=wt.trip_id;

  CURSOR Get_Containers (v_delivery_detail_id NUMBER) IS
  SELECT delivery_detail_id
  FROM wsh_delivery_assignments_v
  WHERE delivery_detail_id <> v_delivery_detail_id
  START WITH delivery_detail_id = v_delivery_detail_id
  CONNECT BY PRIOR parent_delivery_detail_id = delivery_detail_id;

  CURSOR get_empty_containers(v_delivery_id NUMBER) IS
  SELECT da.delivery_detail_id
  FROM wsh_delivery_assignments_v da,
       WSH_DELIVERY_DETAILS  dd
  WHERE da.delivery_id = v_delivery_id
  AND da.delivery_detail_id = dd.delivery_detail_id
  AND dd.container_flag = 'Y'
  AND NOT EXISTS(
     SELECT delivery_detail_id
     FROM wsh_delivery_assignments_v da2
     WHERE da2.parent_delivery_detail_id = da.delivery_detail_id) ;

-- Bug 2713285, added batch_id
  CURSOR get_delivery_name(v_delivery_id NUMBER) IS
  SELECT name,batch_id,
         --OTM R12
         ignore_for_planning,
         tms_interface_flag
         --
  FROM wsh_new_deliveries
  WHERE delivery_id = v_delivery_id;

  -- J: W/V Changes
  CURSOR get_delivery_wv(v_delivery_id NUMBER) IS
  SELECT gross_weight,
         volume
  FROM   wsh_new_deliveries
  WHERE delivery_id = v_delivery_id;


  CURSOR Get_Del_First_Trip(v_del_id NUMBER) IS
  SELECT wts.trip_id
  FROM wsh_delivery_legs wdl, wsh_trip_stops wts, wsh_new_deliveries wnd
  WHERE wdl.pick_up_stop_id=wts.stop_id
  AND wnd.initial_pickup_location_id = wts.stop_location_id
  AND wnd.delivery_id = wdl.delivery_id
  AND wnd.delivery_id=v_del_id;


  --bug 3314353  -- jckwok
  CURSOR prev_stop_csr ( p_trip_id IN NUMBER, p_stop_sequence IN NUMBER) IS
  SELECT stop_id
  FROM wsh_trip_stops
  WHERE trip_id              = p_trip_id
  AND status_code         IN ('OP','AR')
  AND stop_sequence_number < p_stop_sequence
  AND nvl(shipments_type_flag,'0') <> 'I' --bugfix 3925963
  ORDER BY stop_sequence_number;

  --bug 3314353  -- jckwok
  CURSOR get_stops_csr (p_trip_id IN NUMBER) IS
  SELECT stop_id,shipments_type_flag,stop_location_id   --bugfix 3925963
  FROM wsh_trip_stops
  WHERE trip_id              = p_trip_id
  AND status_code         IN ('OP','AR')
  ORDER BY stop_sequence_number;

  --bugfix 3925963
  CURSOR get_trip_name_csr (p_first_trip_id NUMBER) IS
  Select wt.name
  from wsh_trips wt
  where wt.trip_id = p_first_trip_id;

--bug 3314353  -- jckwok
  CURSOR stop_sequence_number_csr (p_stop_id IN NUMBER) IS
  SELECT stop_sequence_number
  FROM wsh_trip_stops
  WHERE stop_id = p_stop_id;

  -- Added for bug 4493263
  CURSOR c_delv_trip_id_cursor( t_delivery_id NUMBER ) IS
  select distinct trip_id from wsh_trip_stops
  where stop_id in
       ( select distinct pick_up_stop_id
         from   wsh_delivery_legs
         where  delivery_id = t_delivery_id );


  l_batch_id        WSH_NEW_DELIVERIES.batch_id%TYPE;

  l_source_code     VARCHAR2(30);  /*Bug 2096052 */
  l_source_code_flag     VARCHAR2(1) := 'N';  /*Bug 2096052 */
  l_released_status   VARCHAR2(1);
  l_inspection_flag   VARCHAR2(1);
  l_container_id       NUMBER;
  l_ship_method_code     VARCHAR2(30);
  l_freight_code       VARCHAR2(30);
  l_delivery_detail_id   NUMBER;
  l_dummy_detail_id   NUMBER;
  l_detail_num       NUMBER;
  l_initial_pickup_date wsh_util_core.Date_tab_type;
  l_ultimate_dropoff_date  wsh_util_core.Date_tab_type;

  u_initial_pickup_date wsh_util_core.Date_tab_type; -- Bulk update variable
  u_ultimate_dropoff_date  wsh_util_core.Date_tab_type;

  l_organization_id   NUMBER ;
  l_num_warn         NUMBER :=0;
  l_num_error       NUMBER :=0;
  l_dd_organization_id   NUMBER ;
  l_inventory_item_id   NUMBER ;
  l_subinventory       VARCHAR2 (30);
  l_locator_id       NUMBER ;

  l_unassign_dds      wsh_util_core.id_tab_type;   -- Renamed the variable l_unassign_line_ids for BO Consolidation
  /* H integration: 945 cancel staged wrudge */
  l_cancel_line_ids   wsh_util_core.id_tab_type;

  l_assigned_counter   NUMBER;
  l_assigned_line_ids wsh_util_core.id_tab_type;
  l_assigned_cont_ids wsh_util_core.id_tab_type;
  l_assigned_orgs   wsh_util_core.id_tab_type;
  l_assigned_items     wsh_util_core.id_tab_type;
  l_assigned_subs   wsh_util_core.Column_Tab_Type;
  l_assigned_locs   wsh_util_core.id_Tab_Type;

  l_bo_rows       wsh_util_core.id_tab_type; -- Bug 1672188 : list of details to Backorder
  l_cc_rows       wsh_util_core.id_tab_type; -- Bug 1672188 : list of details to Backorder
  l_out_bo_rows     wsh_util_core.id_tab_type; -- Bug 1672188 : list of details to Backorder
  l_out_cc_rows     wsh_util_core.id_tab_type; --        list of new details that got backordered

  l_dd_org_ids       wsh_util_core.id_tab_type; --         list of details org ids
  l_item_ids       wsh_util_core.id_tab_type; --         list of details inventory_item_ids

  -- for non-transactable items
  l_inv_controls_rec    WSH_DELIVERY_DETAILS_INV.inv_control_flag_rec;
  dft_subinv        VARCHAR2(30);
  loc_restricted_flag  VARCHAR2(1);
  dft_loc_id        NUMBER;
  org_loc_ctl      NUMBER;
  sub_loc_ctl      NUMBER;
  item_loc_ctl      NUMBER;
  loc_ctl_code      NUMBER;

  g_line_inv_rec      WSH_DELIVERY_DETAILS_INV.line_inv_info;
  l_details_flag      BOOLEAN;

  l_ship_from_location  NUMBER;
  l_ship_to_location    NUMBER;

  l_dummy_rows      wsh_util_core.id_tab_type;
  l_dummy_rows1      wsh_util_core.id_tab_type;
  l_dummy_doc_set    wsh_document_sets.document_set_tab_type;

  l_trip_id        NUMBER;
  l_trip_name      VARCHAR2(30);
  l_return_status    VARCHAR2(1);

  l_requested_quantity  NUMBER;
  l_shipped_quantity    NUMBER;
  l_cycle_quantity    NUMBER;
  l_stage_quantity    NUMBER;
  l_del_status_code    VARCHAR2(2);
  l_status_code      WSH_UTIL_CORE.Column_Tab_Type  ;
  l_number_of_lpn    wsh_util_core.id_tab_type;
  u_status_code      WSH_UTIL_CORE.Column_Tab_Type  ;
  u_number_of_lpn    wsh_util_core.id_tab_type;
  /* H integration: 945 send document wrudge */
  u_organization_id    wsh_util_core.id_tab_type;
  u_wsh_lines_exist    wsh_util_core.id_tab_type;
  l_wsh_lines_exist    NUMBER;

  -- hverddin : Begin of OPM Changes Added Dual Quantities  31-OCT-00

  l_requested_quantity2   NUMBER;
  l_shipped_quantity2  NUMBER;
  l_cycle_quantity2    NUMBER;
  l_stage_quantity2    NUMBER;

  -- hverddin : End of OPM Changes Added Dual Quantities  31-OCT-00
  l_valid_flag      BOOLEAN; -- Check if ship_set is valid
  l_overfilled_flag    BOOLEAN;
  l_underfilled_flag    BOOLEAN;

  -- overpicking
  l_picked_quantity    NUMBER;
  l_picked_quantity2    NUMBER;
  l_unshipped_pick_quantity   NUMBER;
  l_unshipped_pick_quantity2  NUMBER;

  l_shp_dd_shipped_qtys   wsh_util_core.id_tab_type;
  l_shp_dd_shipped_qtys2  wsh_util_core.id_tab_type;
  l_shp_dd_cc_qtys    wsh_util_core.id_tab_type;
  l_shp_dd_cc_qtys2    wsh_util_core.id_tab_type;
  l_shp_dd_req_qtys    wsh_util_core.id_tab_type;
  l_shp_dd_ids      wsh_util_core.id_tab_type;    -- Bug 1672188 : list of details to to Ship
  l_shp_dd_items      wsh_util_core.id_tab_type ;  --      : list of items in details to Ship
  l_shp_dd_orgs      wsh_util_core.id_tab_type;   --       : list of org of details  to Ship
  l_shp_dd_subs      wsh_util_core.column_tab_type;   --       : list of subinventories of details to Ship
  l_shp_dd_locs      wsh_util_core.id_tab_type;   --       : list of locators of details to Ship
  l_shp_dd_cont_ids    wsh_util_core.id_tab_type;   --       : list of containers of details to Ship
  /* H integration: 945 check detail wrudge */
  l_shp_dd_source    wsh_util_core.column_tab_type;  --      : list of source_code of details to ship

  l_assigned_req_qtys  wsh_util_core.id_tab_type; --         list of details req qty
  l_assigned_shp_qtys  wsh_util_core.id_tab_type  ;
  l_assigned_cc_qtys    wsh_util_core.id_tab_type  ;
  l_assigned_req_qtys2  wsh_util_core.id_tab_type; --        list of details req qty2
  l_assigned_shp_qtys2  wsh_util_core.id_tab_type  ;
  l_assigned_cc_qtys2  wsh_util_core.id_tab_type  ;
  l_assigned_pick_qtys  wsh_util_core.id_tab_type; --        overpicking NVL(picked, requested)
  l_assigned_pick_qtys2   wsh_util_core.id_tab_type;
  l_assigned_overpick_qtys  wsh_util_core.id_tab_type; --      for backordering or cycle-counting overpicked quantities
  l_assigned_overpick_qtys2   wsh_util_core.id_tab_type;
  /* H integration: 945 assigned detail wrudge */
   l_assigned_source      wsh_util_core.column_tab_type;

  l_stop_rows      wsh_util_core.id_tab_type;
  u_stop_rows      wsh_util_core.id_tab_type; -- bug 2064810
  l_del_rows        wsh_util_core.id_tab_type;
  u_del_rows        wsh_util_core.id_tab_type;

  l_param_info      WSH_SHIPPING_PARAMS_PVT.Parameter_Rec_Typ;
  l_enforce_packing_flag  VARCHAR2(1) := 'N';

  l_cc_qtys        wsh_util_core.id_tab_type; --         list of details BO qty
  l_cc_req_qtys      wsh_util_core.id_tab_type  ;
  l_cc_overpick_qtys    wsh_util_core.id_tab_type  ;
  l_cc_qtys2        wsh_util_core.id_tab_type; --        list of details BO qty2
  l_cc_overpick_qtys2  wsh_util_core.id_tab_type  ;

  l_bo_qtys        wsh_util_core.id_tab_type; --         list of details BO qty
  l_bo_mode        VARCHAR2 (15) ;
  l_bo_req_qtys      wsh_util_core.id_tab_type  ;
  l_bo_overpick_qtys    wsh_util_core.id_tab_type  ;
  l_bo_qtys2        wsh_util_core.id_tab_type; --        list of details BO qty2
  l_bo_overpick_qtys2  wsh_util_core.id_tab_type  ;

  l_staged_dd_id      NUMBER ;
  l_new_detail_id    NUMBER ;
  l_stage_rows      wsh_util_core.id_tab_type ;

  l_backorder_all_flag  BOOLEAN  := TRUE ;
  l_stage_all_flag    BOOLEAN  ;
  l_inv_cntrl_flag    BOOLEAN ;
  l_inv_material_flag BOOLEAN;
  l_del_tmp_rows      wsh_util_core.id_tab_type;
  l_document_set_name  VARCHAR2 ( 50 );

  l_user_name      VARCHAR2(100);
  l_user_id        NUMBER ;
  l_login_id                       NUMBER;
  l_document_set_id    NUMBER ;
  l_gross_wt        NUMBER ;
  l_net_wt        NUMBER ;
  l_vol          NUMBER ;

  l_unpacked_flag    BOOLEAN ;
  --l_unassign_all_flag  BOOLEAN ;
  l_cont_exists_flag    BOOLEAN ;
  l_fill_status      VARCHAR2(2) ;

-- this variable will store fill status Bug 2878538
-- it will help saving the value from getting over ridden of l_fill_status
-- since l_fill_status variable gets overridden in a loop
  l_save_fill_status      VARCHAR2(2) := 'S';
  l_exception_exist   VARCHAR2(1);
  l_severity_present   VARCHAR2(1);

  l_pickup_stop_id    NUMBER ;
  l_dropoff_stop_id    NUMBER ;
  l_delivery_leg_id    NUMBER ;
  l_parent_delivery_id    NUMBER ;
  l_delivery_id      NUMBER ;

  l_gross_weight      NUMBER ;
  l_net_weight      NUMBER ;
  l_volume        NUMBER ;
  l_temp_line_id      NUMBER ;
  l_temp_source_code    VARCHAR2(5);
  l_max_quantity      NUMBER ;
  -- HW OPM added qty2
  l_max_quantity2    NUMBER ;
  l_msg_data        VARCHAR2(2000);
  l_msg_count      NUMBER;
  l_wms_delivery_id    wsh_util_core.id_tab_type ;
  --2121399
  TYPE Flag_Tab_Type IS TABLE OF BOOLEAN INDEX BY BINARY_INTEGER;
  l_unassign_all_flag_tab  Flag_Tab_Type ;
  --2121399

  l_label_status VARCHAR2(20);
  l_del_tab INV_LABEL_PUB.transaction_id_rec_type;

  l_close_del_cnt   NUMBER := 0;
  l_confirm_del_cnt NUMBER := 0;

  /*new variable */
  l_stop_rec          WSH_TRIP_STOPS_PVT.trip_stop_rec_type;
  l_trip_rec          WSH_TRIPS_PVT.trip_rec_type;
  -- bug 2263249
  l_wms_enabled_flag BOOLEAN;
  -- bug 2343058
  l_check_credit_init_flag BOOLEAN;

  x_unassigned_cont wsh_util_core.id_tab_type;
  l_msg_rec_count wsh_util_core.MsgCountType;
  l_error_exists  BOOLEAN;
  l_msg_table     WSH_INTEGRATION.MSG_TABLE ;
  l_count         NUMBER := 0;
  l_cont_name     VARCHAR2(100);
  l_empty_container NUMBER;
  l_delivery_name   VARCHAR2(100);


--Compatibility Changes
    l_cc_validate_result		VARCHAR2(1);
    l_cc_failed_records			WSH_FTE_COMP_CONSTRAINT_PKG.failed_line_tab_type;
    l_cc_group_info			WSH_FTE_COMP_CONSTRAINT_PKG.cc_group_tab_type;
    l_cc_line_groups			WSH_FTE_COMP_CONSTRAINT_PKG.line_group_tab_type;

    l_trip_info_tab			WSH_TRIPS_PVT.Trip_Attr_Tbl_Type;
    l_trip_id_tab_temp  		wsh_util_core.id_tab_type;
    l_cc_count_success			NUMBER;
    b_cc_linefailed			BOOLEAN;
    l_target_trip_id			NUMBER;
    b_tripalreadychecked                VARCHAR2(1);
    l_count_hashtrip                    NUMBER;

    --dummy tables for calling validate_constraint_wrapper
    l_cc_del_attr_tab	        WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type;
    l_cc_det_attr_tab	        WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type;
    l_cc_trip_attr_tab	        WSH_TRIPS_PVT.Trip_Attr_Tbl_Type;
    l_cc_stop_attr_tab	        WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type;
    l_cc_in_ids		        wsh_util_core.id_tab_type;
    l_cc_fail_ids		wsh_util_core.id_tab_type;
    l_cc_carrier_id             NUMBER;
    l_cc_mode                   VARCHAR2(30);
    G_HASH_TRIP                 wsh_util_core.id_tab_type;
--Compatibility Changes

    l_with_mc_trip_flag           Flag_Tab_Type;

  -- Variables added for Consolidation of BO Delivery Details project
  --
  l_global_parameters	    WSH_SHIPPING_PARAMS_PVT.Global_Parameters_Rec_Typ;
  l_assigned_source_lines   wsh_util_core.id_Tab_Type;
  l_unassign_backordered_dds    wsh_util_core.id_Tab_Type; --Stores the list of BackOrder/Cycle-Count delivery detail ids
  l_unassign_rel_status     wsh_util_core.Column_Tab_Type;
		-- Stores the corresponding Released_status of the delivery details in l_unassign_dds
  l_unassign_source_lines   wsh_util_core.id_Tab_Type;
		-- Stores the Source line ids of the delivery details that are going to be unassigned from the Delivery
  l_bo_line_ids		    wsh_util_core.id_Tab_Type;

  l_bo_source_lines   wsh_util_core.id_Tab_Type;
  l_cc_source_lines   wsh_util_core.id_Tab_Type;
  l_cons_flags        wsh_util_core.Column_Tab_Type;
  l_source_line_id	NUMBER;
  l_idx		NUMBER;
  l_cmp_idx	NUMBER;
  j		NUMBER;
  k		NUMBER;
  l_flag	VARCHAR2(1);
  l_close_confirm_flag VARCHAR2(1):= NULL;
  --

  -- Exception Changes
  l_exceptions_tab  wsh_xc_util.XC_TAB_TYPE;
  l_exp_logged      BOOLEAN := FALSE;

  -- Pack J, table indexed by delivery_id to store whether ITM screening is required.
  l_itm_exc_flag   wsh_util_core.column_Tab_Type;
  l_itm_stops_tab   wsh_util_core.column_Tab_Type;
  l_lines_in_delivery NUMBER;
  l_itm_exc_severity VARCHAR2(30);

  -- Checks if the itm exception is enabled and its severity.
  CURSOR c_exc_severity (c_exception_name VARCHAR2) IS
  SELECT  UPPER(default_severity)
  FROM            wsh_exception_definitions_vl
  WHERE   exception_name = c_exception_name
  AND     enabled = 'Y';

  l_carrier_rec                  WSH_CARRIERS_GRP.Carrier_Service_InOut_Rec_Type;
  l_del_first_trip    NUMBER;

  --bug 3314353
  l_pick_up_stop_sequence_num NUMBER;
  l_first_trip_id NUMBER;
  l_prev_stop_id NUMBER;

  -- bug 2283621
  l_more_dd_flag           BOOLEAN;
  l_more_material_dd_flag           BOOLEAN;
  l_inv_ctrl_dd_count      NUMBER;
  l_inv_material_dd_count      NUMBER;
  l_inv_ctrl_dd_ids        VARCHAR2(100);
  l_inv_material_dd_ids        VARCHAR2(100);
-- HW OPMCONV. Removed OPM variables

  -- Local Variables added for Bug 3118519

  l_more_flag              BOOLEAN      := TRUE;
  l_detail_count           NUMBER       := 0;
  l_invalid_details        VARCHAR2(100);
  l_token                  VARCHAR2(2000);
  l_sc_pickup_date         DATE;
  l_sc_dropoff_date        DATE;

  l_entity_name    VARCHAR2(1000);
  l_exc_beh_error  VARCHAR2(1000);
  l_exc_beh_warn   VARCHAR2(1000);

-- HW OPMCONV. Added a new variable
   l_error_DFF  BOOLEAN :=FALSE;


  --Bugfix 3925963
  l_shipments_type_flag  VARCHAR2(30);
  l_stop_location_id     NUMBER;
  l_stops_trip_name      VARCHAR2(30);
  l_inbound_stops_exists  BOOLEAN;
  l_stop_name            VARCHAR2(60);
  l_stop_name_list       VARCHAR2(10000);
  --

  --/== Workflow Changes
  l_scpod_wf_del_rows   wsh_util_core.id_tab_type;
  l_ctr          NUMBER;
  l_aname_text   wf_engine.nametabtyp;
  l_avalue_text  wf_engine.texttabtyp;
  l_aname_num    wf_engine.nametabtyp;
  l_avalue_num   wf_engine.numtabtyp;
  l_process_started VARCHAR2(1);
  l_enable_sc_wf    VARCHAR2(1);
  l_override_wf     VARCHAR2(1);
  l_wf_rs           VARCHAR2(1);
  l_defer_interface_flag VARCHAR2(1);
  --==/
  l_custom_severity varchar2(10);
  l_activity_code   varchar2(200) := 'SHIP_CONFIRM_MESSAGE' ;
  l_validation_code varchar2(200) := 'MISSING_CONTROLS';

  l_mdc_cl_del_tab wsh_util_core.id_tab_type;
  l_mdc_co_del_tab wsh_util_core.id_tab_type;
  l_mdc_index_i NUMBER;

  -- LPN CONV rv
  cursor l_delete_wms_empty_cnt_csr is
  select distinct wwst.delivery_detail_id
  from   wsh_wms_sync_tmp wwst,
         wsh_delivery_details wdd
  where  wwst.operation_type = 'DELETE'
  and    wdd.delivery_detail_id = wwst.delivery_detail_id
  and    wdd.container_flag = 'Y'
  and    wdd.lpn_id is not null;

  l_delete_cnt_id_tbl wsh_util_core.id_tab_type;
  -- LPN CONV rv
  -- bug 4505105
  l_del_valid_flag VARCHAR2(1);
  -- bug 4505105
  --Bug 5255366
  l_consol_del_doc_set wsh_util_core.id_tab_type;
  l_content_del_flag  BOOLEAN  := TRUE;

  --OTM R12
  l_ignore_for_planning  WSH_NEW_DELIVERIES.IGNORE_FOR_PLANNING%TYPE;
  l_tms_interface_flag   WSH_NEW_DELIVERIES.TMS_INTERFACE_FLAG%TYPE;
  l_otm_trip_id          WSH_TRIPS.TRIP_ID%TYPE;
  l_otm_carrier_id       WSH_NEW_DELIVERIES.CARRIER_ID%TYPE;
  l_otm_ship_method_code WSH_NEW_DELIVERIES.SHIP_METHOD_CODE%TYPE;
  l_otm_mode             WSH_NEW_DELIVERIES.MODE_OF_TRANSPORT%TYPE;
  l_otm_plan_name        WSH_TRIPS.TP_PLAN_NAME%TYPE;
  l_gc3_is_installed     VARCHAR2(1);
  --
  -- Bug 8555654 : begin
  l_period_id             NUMBER;
  l_open_past_period      BOOLEAN;
  l_opn_prd_chk_orgs      wsh_util_core.id_tab_type;
  -- Bug 8555654 : end

  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CONFIRM_DELIVERY';
  --
BEGIN

  -- 0. Get the user_id and user_name
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
            WSH_DEBUG_SV.log(l_module_name,'P_ACTION_FLAG',P_ACTION_FLAG);
            WSH_DEBUG_SV.log(l_module_name,'P_INTRANSIT_FLAG',P_INTRANSIT_FLAG);
            WSH_DEBUG_SV.log(l_module_name,'P_CLOSE_FLAG',P_CLOSE_FLAG);
            WSH_DEBUG_SV.log(l_module_name,'P_STAGE_DEL_FLAG',P_STAGE_DEL_FLAG);
            WSH_DEBUG_SV.log(l_module_name,'P_REPORT_SET_ID',P_REPORT_SET_ID);
            WSH_DEBUG_SV.log(l_module_name,'P_SHIP_METHOD',P_SHIP_METHOD);
            WSH_DEBUG_SV.log(l_module_name,'P_ACTUAL_DEP_DATE',P_ACTUAL_DEP_DATE);
            WSH_DEBUG_SV.log(l_module_name,'P_BOL_FLAG',P_BOL_FLAG);
            WSH_DEBUG_SV.log(l_module_name,'P_MC_BOL_FLAG',P_MC_BOL_FLAG);
            WSH_DEBUG_SV.log(l_module_name,'P_DEFER_INTERFACE_FLAG',P_DEFER_INTERFACE_FLAG);
            WSH_DEBUG_SV.log(l_module_name,'P_SEND_945_FLAG',P_SEND_945_FLAG);
        END IF;
        --
        l_login_id := FND_GLOBAL.login_id;
  l_user_id   := FND_GLOBAL.user_id ;
  l_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS ;

  --OTM R12
  l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED; -- this is global variable

  IF l_gc3_is_installed IS NULL THEN
    l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED; -- this is actual function
  END IF;
  --

  -- bug 2778035
  IF p_action_flag IS NULL
  OR p_action_flag NOT IN ('S', 'B', 'L', 'T', 'A', 'C', 'O') THEN
    FND_MESSAGE.SET_NAME('WSH', 'WSH_INVALID_SC_ACTION_FLAG');
    wsh_util_core.add_message(wsh_util_core.g_ret_sts_error);
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  -- bug 2778035

-- Fix for Bug 3944151
-- Using fnd_global.User_name for global G_USER_NAME
-- This is because before this fix, global g_user_name carried the previous user name
-- when one user logged out and another user logged back in the same mobile telnet session.

   G_USER_NAME := FND_GLOBAL.USER_NAME;

/*  if ( G_USER_NAME is NULL ) then
          open user_name(l_user_id);
    fetch user_name into G_USER_NAME ;
    if user_name%NOTFOUND then
      raise ship_confirm_error;
    end if;
    close user_name;
  end if ;
*/
-- End of fix for bug 3944151

/* Bug 2761304 : The following call is now made inside the loop*/

 /* WSH_UTIL_CORE.Store_Msg_In_Table (p_store_flag => TRUE,
                                    x_msg_rec_count => l_msg_rec_count,
                                    x_return_status => l_return_status);
  IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
    raise ship_confirm_error;
  END IF;*/

  l_user_name := G_USER_NAME ;
  SAVEPOINT start_ship_confirm_delivery ;

  l_document_set_id := p_report_set_id;

  l_enable_sc_wf := 'N';  --Workflow Changes

        -- bug 2343058
        l_check_credit_init_flag := TRUE;

  -- Code Shifted from below to execute irrespective of the If condition - Workflow Changes
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit 2WSH_SHIPPING_PARAMS_PVT.Get_Global_Parameters',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  WSH_SHIPPING_PARAMS_PVT.Get_Global_Parameters(l_global_parameters, l_return_status);
  IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
	      	          WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
	raise ship_confirm_error;
--      x_return_status := l_return_status;
--      wsh_util_core.add_message(x_return_status);
--      l_num_error := l_num_error + 1 ;
--      goto loop_end;
  END IF;


  FOR i IN 1..p_del_rows.count LOOP

  SAVEPOINT confirm_delivery_sp ;

/* Bug 2761304*/
  WSH_UTIL_CORE.Store_Msg_In_Table (p_store_flag => TRUE,
                                    x_msg_rec_count => l_msg_rec_count,
                                    x_return_status => l_return_status);

  -- Bug 3913206
  l_sc_pickup_date        := NULL;
  l_sc_dropoff_date       := NULL;

  IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
    raise ship_confirm_error;
  END IF;

-- Bug 2713285, movedthe code outside the loop,since it is for same delivery
-- added batch_id
  OPEN get_delivery_name(p_del_rows(i));
  FETCH get_delivery_name INTO l_delivery_name,
                               l_batch_id,
                               --OTM R12
                               l_ignore_for_planning,
                               l_tms_interface_flag;
                               --
  CLOSE get_delivery_name;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Delivery Name',l_delivery_name);
    WSH_DEBUG_SV.log(l_module_name,'Batch id',l_batch_id);
    --OTM R12
    WSH_DEBUG_SV.log(l_module_name,'ignore for planning',l_ignore_for_planning);
    WSH_DEBUG_SV.log(l_module_name,'tms interface flag',l_tms_interface_flag);
    --
  END IF;


    OPEN get_empty_containers(p_del_rows(i));
    LOOP
       FETCH get_empty_containers INTO l_empty_container;
       EXIT WHEN get_empty_containers%NOTFOUND;
       l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(l_empty_container);

       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'l_empty_container',l_empty_container);
          WSH_DEBUG_SV.log(l_module_name,'Empty Container',l_cont_name);
       END IF;

       FND_MESSAGE.SET_NAME('WSH','WSH_EMPTY_CONTAINER');
       FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
       FND_MESSAGE.SET_TOKEN('DEL_NAME',l_delivery_name);
       x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
       l_num_warn := l_num_warn + 1;
       wsh_util_core.add_message(x_return_status,l_module_name);
    END LOOP;
    CLOSE get_empty_containers;

    l_bo_rows.delete ;
    l_cc_rows.delete ;
    l_unassign_dds.delete ;
    -- Consolidation of BO Delivery Details project
    --
    l_bo_source_lines.delete;
    l_cc_source_lines.delete;
    l_assigned_source_lines.delete;
    l_unassign_rel_status.delete;
    l_unassign_source_lines.delete;
    l_bo_line_ids.delete;

    --
    /* H integration: 945 cancel staged wrudge */
    l_cancel_line_ids.delete;
    l_assigned_counter   := 0 ;
    l_assigned_line_ids.delete;
    l_assigned_cont_ids.delete;
    l_assigned_orgs.delete;
    l_assigned_items.delete;
    l_assigned_subs.delete;
    l_assigned_locs.delete;
    l_out_bo_rows.delete;
    l_out_cc_rows.delete;
    l_dd_org_ids.delete;
    l_item_ids.delete;

    /* H integration: 945 send document wrudge */
    l_wsh_lines_exist := 0;

    l_shp_dd_shipped_qtys.delete ;
    l_shp_dd_shipped_qtys2.delete ;
    l_shp_dd_cc_qtys.delete ;
    l_shp_dd_cc_qtys2.delete ;
    l_shp_dd_req_qtys.delete ;
    l_shp_dd_ids.delete ;
    l_shp_dd_items.delete ;
    l_shp_dd_orgs.delete ;
    l_shp_dd_subs.delete ;
    l_shp_dd_locs.delete ;
    l_shp_dd_cont_ids.delete ;
    /* H integration: 945 check detail wrudge */
    l_shp_dd_source.delete;

    l_assigned_req_qtys.delete ;
    l_assigned_shp_qtys.delete ;
    l_assigned_cc_qtys.delete ;

    l_assigned_req_qtys2.delete ;
    l_assigned_shp_qtys2.delete ;
    l_assigned_cc_qtys2.delete ;

    l_assigned_pick_qtys.delete;
    l_assigned_pick_qtys2.delete;
    l_assigned_overpick_qtys.delete;
    l_assigned_overpick_qtys2.delete;

    /* H integration: 945 assigned details wrudge */
    l_assigned_source.delete;

    l_stop_rows.delete ;
    l_del_rows.delete ;

    l_enforce_packing_flag  := 'N';

    l_bo_mode := 'UNRESERVE';

    l_cc_req_qtys.delete ;
    l_cc_overpick_qtys.delete ;
    l_cc_qtys.delete ;
    l_cc_qtys2.delete ;

    l_bo_qtys.delete ;
    l_bo_req_qtys.delete ;
    l_bo_overpick_qtys.delete ;
    l_bo_qtys2.delete ;

    L_stage_ROWS.delete ;

    l_organization_id := NULL ;
    l_ship_method_code   := NULL ;
    l_ship_from_location := NULL ;
    l_ship_to_location   := NULL ;
    l_gross_weight     := NULL ;
    l_net_weight     := NULL ;
    l_volume       := NULL ;

    l_del_status_code := NULL ;

    l_number_of_lpn(i)   := NULL;
    -- bug 2263249
    l_wms_enabled_flag   := FALSE;
    l_unassign_all_flag_tab(i) := TRUE ;
    l_inv_cntrl_flag := TRUE;
    l_inv_material_flag := TRUE;
    l_unpacked_flag := FALSE;
-- Set to False by default,Bug 2878538
    l_cont_exists_flag := FALSE;

    -- bug 2283621
    l_more_dd_flag := TRUE;
    l_more_material_dd_flag  := TRUE;
    l_inv_ctrl_dd_ids := NULL;
    l_inv_material_dd_ids := NULL;
    l_inv_ctrl_dd_count := 0;
    l_inv_material_dd_count  :=0 ;
    -- end 2283621

    l_with_mc_trip_flag(i)  := FALSE;

    --OTM R12, check OTM exceptions before ship confirm
    IF (l_gc3_is_installed = 'Y' AND NVL(l_ignore_for_planning, 'N') = 'N') THEN

      l_otm_trip_id          := NULL;
      l_otm_carrier_id       := NULL;
      l_otm_ship_method_code := NULL;
      l_otm_mode             := NULL;
      l_otm_plan_name        := NULL;

      OPEN get_trip(p_del_rows(i));
      FETCH get_trip INTO l_otm_trip_id,
                        l_otm_carrier_id,
                        l_otm_ship_method_code,
                        l_otm_mode,
                        l_otm_plan_name;

      IF (get_trip%NOTFOUND) THEN
        --if cursor not found, then leave the ship method as
        --p_ship_method so does not error out later
        l_otm_ship_method_code := p_ship_method;
      END IF;

      CLOSE get_trip;

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'trip id',l_otm_trip_id);
        WSH_DEBUG_SV.log(l_module_name,'carrier id',l_otm_carrier_id);
        WSH_DEBUG_SV.log(l_module_name,'ship method',l_otm_ship_method_code);
        WSH_DEBUG_SV.log(l_module_name,'mode',l_otm_mode);
        WSH_DEBUG_SV.log(l_module_name,'otm plan name',l_otm_plan_name);
      END IF;

      IF (p_ship_method IS NULL) THEN
        --if p_ship_method is NULL, means no changes to the ship method,
        --set l_otm_ship_method_code to NULL as well to avoid error later.
        l_otm_ship_method_code := p_ship_method;
      END IF;

      -- trip id is NULL, not assigned. Hence ignore the delivery for planning.
      -- (CR->NS and AW->DR for 'Not assigned' to an OTM trip Delivery).
      -- This update for the ignore_for_plan to 'Y' is needed to autocreate the trip
      -- for this delivery during ship conform.
      --

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INTERFACE_EXT_GRP.OTM_PRE_SHIP_CONFIRM',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

      WSH_INTERFACE_EXT_GRP.otm_pre_ship_confirm(
        p_delivery_id        => p_del_rows(i),
        p_delivery_name      => l_delivery_name,
        p_tms_interface_flag => l_tms_interface_flag,
        p_trip_id            => l_otm_trip_id,
        x_return_status      => l_return_status);

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Return Status after calling WSH_INTERFACE_EXT_GRP.OTM_PRE_SHIP_CONFIRM', l_return_status);
      END IF;

      IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_DEL_CONFIRM_ERROR');
        FND_MESSAGE.SET_TOKEN('DEL_NAME',l_delivery_name);

        WSH_UTIL_CORE.add_message(l_return_status, l_module_name);

        l_num_error := l_num_error + 1 ;
        GOTO loop_end;

      ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
        l_num_warn := l_num_warn + 1 ;
      END IF;

      --we are checking that otm_plan_name is NOT NULL meaning
      --OTM planned trip, and ship method code is being changed
      --during ship confirm flow, which is not allowed.
      --IF any ship method is NULL this will be skipped
      --the trip ship method l_otm_ship_method_code should not be
      --NULL for OTM trips.
      IF (l_otm_plan_name IS NOT NULL
          AND l_otm_ship_method_code <> p_ship_method ) THEN

        --
        --  Ship method on a delivery cannot be changed for an OTM trip
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'ship method on trip', l_otm_ship_method_code);
          WSH_DEBUG_SV.log(l_module_name,'ship method passed in ship confirm', p_ship_method);
          WSH_DEBUG_SV.logmsg(l_module_name,'ship method not allowed to change for otm trip');
        END IF;

        FND_MESSAGE.SET_NAME('WSH', 'WSH_OTM_SHIP_CONFIRM_ERROR');
        FND_MESSAGE.SET_TOKEN('DELIVERY_NAME', l_delivery_name);

        WSH_UTIL_CORE.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR, l_module_name);
        l_num_error := l_num_error + 1;
        GOTO loop_end;
      END IF;
    END IF;
    --END OTM R12

     -- 1. Fetch delivery info and lock it

     l_delivery_id     := p_del_rows(i) ;

     SELECT status_code ,
      initial_pickup_date ,
      ultimate_dropoff_date  ,
      organization_id ,
      ship_method_code ,
      initial_pickup_location_id,
      ultimate_dropoff_location_id ,
      gross_weight ,
      net_weight ,
      volume
     INTO   l_del_status_code,
      l_initial_pickup_date(i),
      l_ultimate_dropoff_date(i),
      l_organization_id ,
      l_ship_method_code ,
      l_ship_from_location,
      l_ship_to_location ,
      l_gross_weight ,
      l_net_weight ,
      l_volume
     FROM   wsh_new_deliveries
     WHERE  delivery_id = p_del_rows(i)
     AND    nvl(shipment_direction,'O') IN ('O','IO')    -- J-IB-NPARIKH
     FOR UPDATE NOWAIT;

     -- 2. Five checks performed here :
     --   a. If delivery is confirmed , skip it and go to next.
     IF (l_del_status_code = 'CO') THEN
       --  Although the name of this message looks like its an error , we are not
       -- really erroring out here.
       FND_MESSAGE.SET_NAME('WSH','WSH_SHIP_CONFIRM_ERROR');
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       --
       FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_del_rows(i)));
             wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_SUCCESS);
       goto loop_end ;
     END IF;

     --b. If delivery is neither OPEN nor PACKED , then set WARNING and go to next one

     IF NOT (  (l_del_status_code IN  ('OP', 'PA', 'SA'))) THEN  -- sperera 940/945
       FND_MESSAGE.SET_NAME('WSH','WSH_DEL_CONFIRM_MULTI_ERROR');
       x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
       l_num_warn := l_num_warn + 1;
       wsh_util_core.add_message(x_return_status);
       goto loop_end ;
     END IF;

     -- c. If ship Method is null , freight_code is null
     --    If not null , then its should have a an associated freight code.

     IF l_ship_method_code IS NULL THEN
       l_freight_code:=null;
     ELSE
       OPEN get_freight(l_ship_method_code,l_organization_id );
       FETCH get_freight INTO l_freight_code;

       IF (get_freight%NOTFOUND) THEN
         CLOSE get_freight;
         fnd_message.set_name('WSH','WSH_INVALID_FREIGHT_CODE');
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --
         FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_del_rows(i)));
         FND_MESSAGE.SET_TOKEN('SHIP_METHOD',l_ship_method_code);
         FND_MESSAGE.SET_TOKEN('ORG_ID',l_organization_id);
         wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_WARNING);
         x_return_Status := WSH_UTIL_CORE.G_RET_STS_WARNING ;
         l_num_warn := l_num_warn + 1 ;
             ELSE
         CLOSE get_freight;
       END IF;
     END IF;

     -- d. If Initial pickup date or ultimate dropoff date is null , then
     --    Set a warning , and default to sysdate .

     IF (l_initial_pickup_date(i) IS NULL)
             OR (l_ultimate_dropoff_date(i) IS NULL) THEN

       IF p_action_flag NOT IN ('C','O') THEN --{
          FND_MESSAGE.SET_NAME('WSH','WSH_DEL_DATES_NULL');
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

          l_num_warn := l_num_warn + 1;
       END IF; --}

       l_initial_pickup_date(i) :=  nvl(p_actual_dep_date, SYSDATE) ;
       l_ultimate_dropoff_date(i) :=  GREATEST(nvl(l_ultimate_dropoff_date(i),nvl(p_actual_dep_date,SYSDATE)), nvl(p_actual_dep_date,SYSDATE));
       -- Bug 3913206
       l_sc_pickup_date        := l_initial_pickup_date(i);
       l_sc_dropoff_date       := l_ultimate_dropoff_date(i);
     END IF;

     -- e. Validate Descriptive Flex-fields. If not valid , then warn and go to next one.

     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'l_sc_pickup_date',l_sc_pickup_date);
         WSH_DEBUG_SV.log(l_module_name,'l_sc_dropoff_date',l_sc_dropoff_date);
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_FLEXFIELD_UTILS.VALIDATE_DFF',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     wsh_flexfield_utils.Validate_DFF
       (p_table_name => 'WSH_NEW_DELIVERIES',
        p_primary_id => p_del_rows(i),
        x_return_status => x_return_status);

       IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
         FND_MESSAGE.SET_NAME('WSH','WSH_DEL_CONFIRM_ERROR');
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --
         FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_del_rows(i)));
         wsh_util_core.add_message(x_return_status);
         if ( x_return_status =  WSH_UTIL_CORE.G_RET_STS_ERROR )  then
           l_num_error := l_num_error + 1 ;
           goto loop_end ;
         else
           l_num_warn := l_num_warn + 1 ;
         end if ;
       END IF;

     -- bug 4505105
     l_del_valid_flag := 'Y';
     validate_del_containers(p_del_rows(i),
                             'STD',
                             l_del_valid_flag,
                             x_return_status);

     IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'x_return_status after calling validate_del_containers', x_return_status);
     END IF;

     IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
       FND_MESSAGE.SET_NAME('WSH','WSH_DEL_CONFIRM_ERROR');
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       --
       FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_del_rows(i)));
       wsh_util_core.add_message(x_return_status);
     END IF;
     --
     IF (nvl(l_del_valid_flag,'Y') = 'N') THEN
       l_num_error := l_num_error + 1 ;
       goto loop_end ;
     END IF;

     IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
       l_num_error := l_num_error + 1 ;
       goto loop_end ;
     ELSIF (x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
       l_num_error := l_num_error + 1 ;
       goto loop_end ;
     ELSIF (x_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
       l_num_warn := l_num_warn + 1 ;
     END IF;
     -- bug 4505105

     --bug 1941793
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.CHECK_WMS_ORG',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     if (wsh_util_validate.Check_Wms_Org(l_organization_id)='Y') then


              -- bug 2263249
              l_wms_enabled_flag := TRUE;

              l_wms_delivery_id(1):=p_del_rows(i);

       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WMS_SHIPPING_PUB.DEL_WSTT_RECS_BY_DELIVERY_ID',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       --
       WMS_SHIPPING_PUB.DEL_WSTT_RECS_BY_DELIVERY_ID(
            x_return_status  => l_return_status,
            x_msg_count   => l_msg_count,
            x_msg_data     => l_msg_data,
            p_commit     => 'F',
            p_init_msg_list  => 'F',
            p_api_version => 1.0, -- Bugfix 3561335
            p_delivery_ids   =>  l_wms_delivery_id);
       IF ( l_return_status <>  WSH_UTIL_CORE.G_RET_STS_SUCCESS )  THEN
         FND_MESSAGE.SET_NAME('WSH','WSH_INTG_ERROR');
         FND_MESSAGE.SET_TOKEN('API_NAME', 'WMS_SHIPPING_PUB.DEL_WSTT_RECS_BY_DELIVERY_ID');
         FND_MESSAGE.SET_TOKEN('MSG_TEXT', l_msg_data);
         x_return_status := l_return_status;
         wsh_util_core.add_message(x_return_status);
         IF ( l_return_status =  WSH_UTIL_CORE.G_RET_STS_ERROR OR
              l_return_status =  WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)  THEN
           l_num_error := l_num_error + 1 ;
           goto confirm_error_no_msg;
         ELSE
            l_num_warn := l_num_warn + 1 ;
         END IF;
       END IF;
     end if;
     --

	 -- Check for Exceptions against Delivery and Contents of Delivery
	 IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_XC_UTIL.Check_Exceptions',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     l_exceptions_tab.delete;
     l_exp_logged      := FALSE;
     WSH_XC_UTIL.Check_Exceptions (
                                     p_api_version           => 1.0,
                                     x_return_status         => l_return_status,
                                     x_msg_count             => l_msg_count,
                                     x_msg_data              => l_msg_data,
                                     p_logging_entity_id     => p_del_rows(i) ,
                                     p_logging_entity_name   => 'DELIVERY',
                                     p_consider_content      => 'Y',
                                     x_exceptions_tab        => l_exceptions_tab
                                   );

     IF ( l_return_status <>  WSH_UTIL_CORE.G_RET_STS_SUCCESS )  THEN
         x_return_status := l_return_status;
         wsh_util_core.add_message(x_return_status);
         IF ( l_return_status =  WSH_UTIL_CORE.G_RET_STS_ERROR OR
             l_return_status =  WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)  THEN
              l_num_error := l_num_error + 1 ;
              goto confirm_error_no_msg;
         ELSE
              l_num_warn := l_num_warn + 1 ;
         END IF;
     END IF;

     l_entity_name:=FND_MESSAGE.GET_STRING('WSH','WSH_DELIVERY');
     l_exc_beh_error:=FND_MESSAGE.GET_STRING('WSH','WSH_MESSAGE_TYPE_ERROR');
     l_exc_beh_warn:=FND_MESSAGE.GET_STRING('WSH','WSH_MESSAGE_TYPE_WARNING');

     FOR exp_cnt in 1..l_exceptions_tab.COUNT LOOP
         IF l_exceptions_tab(exp_cnt).exception_behavior = 'ERROR' THEN
            IF l_exceptions_tab(exp_cnt).entity_name = 'DELIVERY' THEN
               FND_MESSAGE.SET_NAME('WSH','WSH_XC_EXIST_ENTITY');
            ELSE
               FND_MESSAGE.SET_NAME('WSH','WSH_XC_EXIST_CONTENTS');
            END IF;
            FND_MESSAGE.SET_TOKEN('ENTITY_NAME',l_entity_name);
            FND_MESSAGE.SET_TOKEN('ENTITY_ID',wsh_new_deliveries_pvt.get_name(p_del_rows(i)));
            FND_MESSAGE.SET_TOKEN('EXCEPTION_BEHAVIOR',l_exc_beh_error);
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            wsh_util_core.add_message(x_return_status);
            l_num_error := l_num_error + 1 ;
            goto confirm_error_no_msg;
         ELSIF l_exceptions_tab(exp_cnt).exception_behavior = 'WARNING' THEN
            IF l_exceptions_tab(exp_cnt).entity_name = 'DELIVERY' THEN
               FND_MESSAGE.SET_NAME('WSH','WSH_XC_EXIST_ENTITY');
               FND_MESSAGE.SET_TOKEN('ENTITY_NAME',l_entity_name);
               FND_MESSAGE.SET_TOKEN('ENTITY_ID',wsh_new_deliveries_pvt.get_name(p_del_rows(i)));
               FND_MESSAGE.SET_TOKEN('EXCEPTION_BEHAVIOR',l_exc_beh_warn);
               x_return_status :=  WSH_UTIL_CORE.G_RET_STS_WARNING;
               wsh_util_core.add_message(x_return_status);
               l_num_warn := l_num_warn + 1 ;
            ELSIF NOT (l_exp_logged) THEN
               FND_MESSAGE.SET_NAME('WSH','WSH_XC_EXIST_CONTENTS');
               FND_MESSAGE.SET_TOKEN('ENTITY_NAME',l_entity_name);
               FND_MESSAGE.SET_TOKEN('ENTITY_ID',wsh_new_deliveries_pvt.get_name(p_del_rows(i)));
               FND_MESSAGE.SET_TOKEN('EXCEPTION_BEHAVIOR',l_exc_beh_warn);
               x_return_status :=  WSH_UTIL_CORE.G_RET_STS_WARNING;
               l_exp_logged := TRUE;
               wsh_util_core.add_message(x_return_status);
               l_num_warn := l_num_warn + 1 ;
            END IF;
         END IF;
     END LOOP;


     -- 3. Fetch delivery lines for the delivery

     l_assigned_counter := 0 ;
     l_lines_in_delivery := 0;

     OPEN detail_info ( p_del_rows(i) );
     LOOP

      l_detail_num := l_detail_num + 1;
      /*Bug 2096052 for OKE */
      l_source_code := NULL;
      /*end of 2096052 */

      l_container_id := NULL ;
      l_delivery_detail_id := NULL ;
      l_released_status  := NULL ;

      l_inspection_flag  := NULL ;
      l_shipped_quantity  := NULL ;
      l_shipped_quantity2  := NULL ;

      l_cycle_quantity  := NULL ;
      l_cycle_quantity2  := NULL ;
      l_requested_quantity  := NULL ;

      l_requested_quantity2  := NULL ;
      l_dd_organization_id  := NULL ;
      l_inventory_item_id  := NULL ;

      l_picked_quantity  := NULL;
      l_picked_quantity2 := NULL;

      l_subinventory  := NULL ;
      l_locator_id   := NULL ;

      FETCH detail_info INTO l_container_id, l_delivery_detail_id, l_released_status ,
                 l_inspection_flag , l_shipped_quantity , l_shipped_quantity2 ,
                 l_cycle_quantity , l_cycle_quantity2 , l_requested_quantity ,
                 l_requested_quantity2 ,
                 l_picked_quantity, l_picked_quantity2,
                 l_dd_organization_id ,l_inventory_item_id ,
                 l_subinventory ,  l_locator_id, l_source_code, l_source_line_id;
      /*Bug 2096052 added l_source_code for OKE */
					 -- Added l_source_line_id for the Consolidation of BO Delivery Details project

      IF detail_info%NOTFOUND AND l_lines_in_delivery = 0 THEN
         CLOSE detail_info;
         FND_MESSAGE.SET_NAME('WSH','WSH_EMPTY_DELIVERY');
         FND_MESSAGE.SET_TOKEN('DEL_NAME',l_delivery_name);
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         wsh_util_core.add_message(x_return_status);
         goto confirm_error_no_msg;
      END IF;

      EXIT WHEN detail_info%NOTFOUND;
      l_lines_in_delivery := l_lines_in_delivery + 1;

      -- This is a workaround to lock each individual line
      -- as locking in SELECT FOR UPDATE will not work
      -- on labels 8.1.6.3 and above because of the above mentioned reason
      -- This might have a performance hit

     /* remove after UT since the Check_Exceptions will supersede this

     -- check if exception exists for the delivery detail
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIP_CONFIRM_ACTIONS2.CHECK_EXCEPTION',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      WSH_SHIP_CONFIRM_ACTIONS2.check_exception(
            p_delivery_detail_id => l_delivery_detail_id,
            x_exception_exist => l_exception_exist,
            x_severity_present => l_severity_present,
            x_return_status => l_return_status);

      -- Bug 2461003 : Severity of Exception is Low, still reqd to resolve
      -- Modified to ensure that only High and Medium Severity are Errors while Low is treated as Warning
      IF (l_exception_exist = 'Y') THEN
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name, 'EXCEPTIONS EXIST FOR DELIVERY DETAIL ' || L_DELIVERY_DETAIL_ID|| ' , DURING SHIP CONFIRM' );
         END IF;
         --
         FND_MESSAGE.SET_NAME('WSH','WSH_XC_EXIST_DET');
         FND_MESSAGE.SET_TOKEN('DEL_DET_ID', to_char(l_delivery_detail_id));
         IF l_severity_present IN ('H','M') THEN
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            wsh_util_core.add_message(x_return_status);
            goto confirm_error;
         ELSIF l_severity_present = 'L' THEN
            x_return_status :=  WSH_UTIL_CORE.G_RET_STS_WARNING;
            wsh_util_core.add_message(x_return_status);
            l_num_warn := l_num_warn + 1 ;
         END IF;
      END IF;

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_delivery_detail_id'||l_delivery_detail_id);
      END IF;

      OPEN Get_Containers(l_delivery_detail_id);
      LOOP
        FETCH Get_Containers INTO l_container_id;
        EXIT WHEN Get_Containers%NOTFOUND;
        WSH_SHIP_CONFIRM_ACTIONS2.check_exception(
            p_delivery_detail_id => l_container_id,
            x_exception_exist => l_exception_exist,
            x_severity_present => l_severity_present,
            x_return_status => l_return_status);

        -- Bug 2461003 : Severity of Exception is Low, still reqd to resolve
        -- Modified to ensure that only High and Medium Severity are Errors while Low is treated as Warning
        IF (l_exception_exist = 'Y') THEN
           --
           -- Debug Statements
           --
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'EXCEPTIONS EXIST FOR CONTAINER ' || L_CONTAINER_ID|| ' , DURING SHIP CONFIRM' );
           END IF;
           --
           FND_MESSAGE.SET_NAME('WSH','WSH_XC_EXIST_DET');
           FND_MESSAGE.SET_TOKEN('DEL_DET_ID', to_char(l_container_id));
           IF l_severity_present IN ('H','M') THEN
              x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
              wsh_util_core.add_message(x_return_status);
              CLOSE Get_Containers;
              CLOSE detail_info;
              goto confirm_error;
           ELSIF l_severity_present = 'L' THEN
              x_return_status :=  WSH_UTIL_CORE.G_RET_STS_WARNING;
              wsh_util_core.add_message(x_return_status);
              l_num_warn := l_num_warn + 1 ;
           END IF;
        END IF;

      END LOOP;
      CLOSE Get_Containers;

      */

   -- Bug 3118519 : Validation for Additional Delivery Detail Information DFF.
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling WSH_FLEXFIELD_UTILS.VALIDATE_DFF to validate delivery details DFF',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      WSH_FLEXFIELD_UTILS.Validate_DFF(
                          p_table_name     =>  'WSH_DELIVERY_DETAILS',
                          p_primary_id     =>  l_delivery_detail_id,
                          x_return_status  =>  x_return_status);

 --
         IF l_debug_on THEN

            WSH_DEBUG_SV.logmsg(l_module_name,'Return status after calling Validate_DFF in DEACB is : '
                                            || x_return_status);
         END IF;
      IF ( x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR ) THEN
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'WSH_FLEXFIELD_UTILS.VALIDATE_DFF failed for delivery detail : '
                                            || l_delivery_detail_id,WSH_DEBUG_SV.C_PROC_LEVEL);
            WSH_DEBUG_SV.logmsg(l_module_name,'Return status after calling Validate_DFF in DEACB is : '
                                            || x_return_status);
         END IF;
         --
         l_num_error    := l_num_error + 1;
-- HW OPMCONV. Removed checking for org type

         l_error_DFF:= TRUE;
         l_detail_count := l_detail_count + 1;

         IF ( l_detail_count = 1 ) THEN
            l_invalid_details := l_delivery_detail_id;
         ELSIF ( l_detail_count <= 5 ) THEN
            l_invalid_details := l_invalid_details || ', ' || l_delivery_detail_id;
         ELSIF ( l_more_flag ) THEN
            l_more_flag := FALSE;
            l_invalid_details := l_invalid_details || '..';
         END IF;
      END IF;

    -- IF Condition added for Bug 3118519

    -- HW OPMCONV. Removed forking the code

    /* H integration: 945 send document wrudge */
    IF (l_source_code = 'WSH') THEN
      l_wsh_lines_exist := l_wsh_lines_exist + 1;
    END IF;


    /*Bug 2096052 added for OKE */
    IF (l_source_code = 'OKE' AND
      (p_action_flag = 'B' OR
       p_action_flag = 'O' OR
       p_action_flag = 'L' OR
       p_action_flag = 'C' OR
       l_cycle_quantity > 0)
     ) THEN
        l_source_code_flag := 'Y';
        FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_SHIP_MODE');
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        wsh_util_core.add_message(x_return_status);
        l_num_error := l_num_error + 1;
        CLOSE detail_info;
        goto confirm_error_no_msg;

    END IF;
    /*end of Bug 2096052 added for OKE */

      BEGIN
        SELECT delivery_detail_id  INTO   l_dummy_detail_id
        FROM   wsh_delivery_details
        WHERE  delivery_detail_id = l_delivery_detail_id
        FOR UPDATE NOWAIT;

        EXCEPTION
          WHEN record_locked THEN
            x_return_status :=  WSH_UTIL_CORE.G_RET_STS_WARNING;
            FND_MESSAGE.SET_NAME('WSH','WSH_DEL_LOCK_ERR');
            wsh_util_core.add_message(x_return_status);
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            CLOSE detail_info;
            goto confirm_error;
          WHEN OTHERS THEN
            RAISE;
      END;

      IF (l_released_status NOT IN ('X', 'Y')) THEN
         FND_MESSAGE.SET_NAME('WSH','WSH_DEL_DETAILS_UNRELEASED');
-- Bug 2713285
-- for cancelling or unassigning the lines from delivery thru Batch process
        IF l_batch_id IS NULL THEN
          x_return_status :=  WSH_UTIL_CORE.G_RET_STS_WARNING;
          l_num_warn := l_num_warn + 1 ;
        ELSE
          x_return_status :=  WSH_UTIL_CORE.G_RET_STS_ERROR;
          l_num_error := l_num_error + 1 ;
        END IF;

        wsh_util_core.add_message(x_return_status);
        WSH_NEW_DELIVERY_ACTIONS.g_error_level := 'E';
        --bug 2770400
        IF l_batch_id IS NOT NULL THEN
          -- in batch mode ,stop confirming the delivery
          wsh_util_core.add_message(x_return_status);
          CLOSE detail_info;
          goto confirm_error_no_msg;
        END IF;
-- End of Bug 2713285

         /* H integration: 945 cancel staged/unreleased wrudge */
         IF l_source_code = 'WSH' THEN
          l_cancel_line_ids(l_cancel_line_ids.count + 1) := l_delivery_detail_id;
         ELSE
          l_unassign_dds(l_unassign_dds.count + 1) := l_delivery_detail_id;
	  l_unassign_rel_status(l_unassign_rel_status.count + 1) := l_released_status;
	  l_unassign_source_lines(l_unassign_source_lines.count + 1) := l_source_line_id;  -- Bug#3246327
         END IF;
      ELSE
         -- check for inspection_flag

         IF ( l_inspection_flag = 'R') then
            FND_MESSAGE.SET_NAME('WSH','WSH_INSPECTION');
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
            l_num_warn := l_num_warn + 1;

            UPDATE WSH_DELIVERY_DETAILS
            SET INSPECTION_FLAG = 'I'
            WHERE DELIVERY_DETAIL_ID = l_dummy_detail_id ;

         END IF ;

         l_assigned_counter := l_assigned_counter + 1 ;
         l_assigned_line_ids ( l_assigned_counter ) := l_dummy_detail_id ;
         l_assigned_cont_ids ( l_assigned_counter ) := l_container_id ;
         l_assigned_req_qtys      ( l_assigned_counter ) := l_requested_quantity ;
         l_assigned_shp_qtys      ( l_assigned_counter ) := l_shipped_quantity   ;
         l_assigned_cc_qtys      ( l_assigned_counter ) := l_cycle_quantity ;
         l_assigned_shp_qtys2    ( l_assigned_counter ) := l_shipped_quantity2;
         l_assigned_cc_qtys2      ( l_assigned_counter ) := l_cycle_quantity2;
         l_assigned_req_qtys2    ( l_assigned_counter ) := l_requested_quantity2  ;
         l_assigned_pick_qtys    ( l_assigned_counter ) := l_picked_quantity;
         l_assigned_pick_qtys2    ( l_assigned_counter ) := l_picked_quantity2;
         l_assigned_overpick_qtys  ( l_assigned_counter ) := l_picked_quantity - l_requested_quantity ;
         l_assigned_overpick_qtys2  ( l_assigned_counter ) := l_picked_quantity2 - l_requested_quantity2 ;
         l_assigned_orgs   ( l_assigned_counter ) := l_dd_organization_id  ;
         l_assigned_items ( l_assigned_counter ) := l_inventory_item_id ;
         l_assigned_subs   ( l_assigned_counter ) := l_subinventory  ;
         l_assigned_locs   ( l_assigned_counter ) := l_locator_id ;
	 -- Consolidation of BO Delivery Details project
  	 l_assigned_source_lines (l_assigned_counter) := l_source_line_id;
         /* H integration: 940/945 wrudge */
         l_assigned_source   ( l_assigned_counter ) := l_source_code;

      END IF ; -- If released_status not in ( 'X' , 'Y' )

     END LOOP ;-- for unassigning unreleased lines.

     close  detail_info  ;

     -- Added for Bug 3118519
     -- HW OPMCONV. Removed forking the code

     IF ( l_error_DFF) THEN
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'WSH_FLEXFIELD_UTILS.VALIDATE_DFF validation failed for delivery detail(s)',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        l_token := FND_MESSAGE.Get_String('WSH', 'WSH_DETAIL_DFF_TITLE');

        FND_MESSAGE.Set_Name('WSH', 'WSH_DFF_DETAIL_EMPTY');
        FND_MESSAGE.Set_Token('DFF_TITLE', l_token);
        FND_MESSAGE.Set_Token('DETAIL_IDS', l_invalid_details);
        WSH_UTIL_CORE.Add_Message(x_return_status);

        IF ( x_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
           l_num_warn := l_num_warn;
        END IF;

        goto loop_end;

  END IF;

     -- 4. p_action_flag = O : If CYCLE COUNT all then cycle count all the reservations,
     -- backorder, clear inv controls and tracking number etc,
     -- unassign from delivery and close delivery, return

     IF (p_action_flag = 'O') THEN

               -- bug 2263249
               IF (l_wms_enabled_flag) THEN
                 --
                 -- Debug Statements
                 --
                 IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WMS_SHIPPING_LPN_UTILS_PUB.UPDATE_LPN_CONTEXT',WSH_DEBUG_SV.C_PROC_LEVEL);
                 END IF;
                 --
                 WMS_Shipping_LPN_Utils_PUB.update_lpn_context
                   (p_delivery_id   => p_del_rows(i),
                    x_return_status => l_return_status,
                    x_msg_count     => l_msg_count,
                    x_msg_data      => l_msg_data
                                                                 );
                 IF (l_return_status <>  WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                   FND_MESSAGE.SET_NAME('WSH','WSH_INTG_ERROR');
                   FND_MESSAGE.SET_TOKEN('API_NAME', 'WMS_SHIPPING_LPN_UTILS_PUB.UPDATE_LPN_CONTEXT');
                   FND_MESSAGE.SET_TOKEN('MSG_TEXT', l_msg_data);
                   x_return_status := l_return_status;
                   wsh_util_core.add_message(x_return_status);
                   IF (l_return_status =  WSH_UTIL_CORE.G_RET_STS_ERROR OR
                       l_return_status =  WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
                   THEN

                     l_num_error := l_num_error + 1 ;
                   ELSE
                     l_num_warn := l_num_warn + 1 ;
                   END IF;
                 END IF;
               END IF;
                -- end bug 2263249

        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIP_CONFIRM_ACTIONS2.BACKORDER',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --



        wsh_ship_confirm_actions2.backorder(
          p_detail_ids   => l_assigned_line_ids  ,
      	  p_line_ids	 => l_assigned_source_lines,	-- Consolidation of BO Delivery Details project
          p_bo_qtys => l_assigned_req_qtys ,   -- pass total requested_quantity for BO
          p_req_qtys     => l_assigned_req_qtys ,
          p_bo_qtys2     => l_assigned_req_qtys2 ,
          p_overpick_qtys  => l_assigned_overpick_qtys ,
          p_overpick_qtys2 => l_assigned_overpick_qtys2 ,
          p_bo_mode    => 'CYCLE_COUNT' ,
          x_out_rows     => l_out_cc_rows ,
	  x_cons_flags   => l_cons_flags,               -- Consolidation of BO Delivery Details project
          x_return_status  => l_return_status);

        IF ( l_return_status <>  WSH_UTIL_CORE.G_RET_STS_SUCCESS )
                    THEN
          IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR OR
              l_return_status =  WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
          THEN
                        l_num_error := l_num_error + 1 ;
                        goto confirm_error_no_msg;
          ELSE
            l_num_warn := l_num_warn + 1 ;
          END IF ;
        END IF ;
       -- 2131459 - remove goto update_delivery_status code
       l_unassign_all_flag_tab(i) := TRUE;

       -- 5. p_action_flag = C : If BACKORDER ALL then remove all reservations, clear inv controls and
       -- tracking number etc, unassign from delivery and close delivery, return

     ELSIF  ( p_action_flag = 'C' )  THEN

               -- bug 2263249
               IF (l_wms_enabled_flag) THEN
                   --
                   -- Debug Statements
                   --
                   IF l_debug_on THEN
                       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WMS_SHIPPING_LPN_UTILS_PUB.UPDATE_LPN_CONTEXT',WSH_DEBUG_SV.C_PROC_LEVEL);
                   END IF;
                   --
                   WMS_Shipping_LPN_Utils_PUB.update_lpn_context
                     (p_delivery_id   => p_del_rows(i),
                      x_return_status => l_return_status,
                      x_msg_count     => l_msg_count,
                      x_msg_data      => l_msg_data
                                                                 );
                   IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                     FND_MESSAGE.SET_NAME('WSH','WSH_INTG_ERROR');
                     FND_MESSAGE.SET_TOKEN('API_NAME', 'WMS_SHIPPING_LPN_UTILS_PUB.UPDATE_LPN_CONTEXT');
                     FND_MESSAGE.SET_TOKEN('MSG_TEXT', l_msg_data);
                     x_return_status := l_return_status;
                     wsh_util_core.add_message(x_return_status);
                     IF (l_return_status =  WSH_UTIL_CORE.G_RET_STS_ERROR OR
                        l_return_status =  WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)  THEN
                       l_num_error := l_num_error + 1 ;
                     ELSE
                       l_num_warn := l_num_warn + 1 ;
                     END IF;
                   END IF;
                 END IF;
                -- end bug 2263249

        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIP_CONFIRM_ACTIONS2.BACKORDER',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --

        wsh_ship_confirm_actions2.backorder(
            p_detail_ids    => l_assigned_line_ids  ,
       	    p_line_ids	    => l_assigned_source_lines,	  -- Consolidation of BO Delivery Details project
            p_bo_qtys    => l_assigned_req_qtys ,   -- pass total requested_quantity for BO
            p_req_qtys    => l_assigned_req_qtys ,
            p_bo_qtys2    => l_assigned_req_qtys2 ,
            p_overpick_qtys   => l_assigned_overpick_qtys ,
            p_overpick_qtys2  => l_assigned_overpick_qtys2 ,
            p_bo_mode    => 'UNRESERVE' ,
            x_out_rows    => l_out_bo_rows ,
	    x_cons_flags   => l_cons_flags,               -- Consolidation of BO Delivery Details project
            x_return_status   => l_return_status);

        IF (l_return_status <>  WSH_UTIL_CORE.G_RET_STS_SUCCESS )  THEN
          IF (l_return_status =  WSH_UTIL_CORE.G_RET_STS_ERROR OR
              l_return_status =  WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
                      THEN
            l_num_error := l_num_error + 1 ;
            goto confirm_error_no_msg;
          ELSE
            l_num_warn := l_num_warn + 1 ;
          END IF ;
        END IF ;
         --  2131459 - remove goto update_delivery_status code
        l_unassign_all_flag_tab(i) := TRUE;

     ELSE FOR j IN 1..l_assigned_line_ids.count LOOP

        -- 6a. p_action_flag = S : SHIP UNSPECIFIED QUANTITIES
        IF (p_action_flag = 'S') THEN

          l_shipped_quantity  := nvl(l_assigned_shp_qtys ( j ),  l_assigned_pick_qtys( j ));
          l_shipped_quantity2 := nvl(l_assigned_shp_qtys2 ( j ), l_assigned_pick_qtys2( j ));
          l_cycle_quantity  := nvl(l_assigned_cc_qtys( j ) , 0);
          l_cycle_quantity2   := l_assigned_cc_qtys2( j ) ;
          l_bo_mode := 'UNRESERVE';

        -- 6b. p_action_flag = B : BACKORDER  UNSPECIFIED QUANTITIES

        ELSIF (p_action_flag = 'B') THEN

          l_shipped_quantity  := nvl(l_assigned_shp_qtys ( j ) , 0);
          /* OPM BUG 2408223 - pupakare */
          l_shipped_quantity2 := l_assigned_shp_qtys2( j ) ;
          l_cycle_quantity  := nvl(l_assigned_cc_qtys( j ),  l_assigned_req_qtys ( j ) - l_shipped_quantity);
-- HW OPMCONV - Added Qty2
          l_cycle_quantity2 := nvl(l_assigned_cc_qtys2( j ), l_assigned_req_qtys2( j ) - nvl(l_shipped_quantity2,0));
          /* End Bug 2408223 */
          l_bo_mode      := 'UNRESERVE' ;

        -- 6c. p_action_flag = L : CYCLE_COUNT  UNSPECIFIED QUANTITIES

        ELSIF (p_action_flag = 'L') THEN

          l_shipped_quantity  := nvl(l_assigned_shp_qtys ( j ) , 0);
          /* OPM BUG 2408223 - pupakare */
          l_shipped_quantity2 := l_assigned_shp_qtys2( j ) ;
          l_cycle_quantity    := nvl(l_assigned_cc_qtys( j ) ,  l_assigned_req_qtys( j )  - l_shipped_quantity);
-- HW OPMCONV - Added nvl to shipped_qty2
          l_cycle_quantity2   := nvl(l_assigned_cc_qtys2( j ),  l_assigned_req_qtys2( j ) - nvl(l_shipped_quantity2,0));
          /* End Bug 2408223 */
                           IF l_debug_on THEN
            WSH_DEBUG_SV.push(l_module_name);
            --
            WSH_DEBUG_SV.log(l_module_name,'l_cycle_quantity2',l_cycle_quantity2);
            WSH_DEBUG_SV.log(l_module_name,'l_shipped_quantity2',l_shipped_quantity2);
            WSH_DEBUG_SV.log(l_module_name,'l_assigned_req_qtys2( j ',l_assigned_req_qtys2( j ));
            WSH_DEBUG_SV.log(l_module_name,'l_assigned_cc_qtys( j ) ',l_assigned_cc_qtys2( j ));

            WSH_DEBUG_SV.push(l_module_name);
            --
            WSH_DEBUG_SV.log(l_module_name,'l_cycle_quantity',l_cycle_quantity);
            WSH_DEBUG_SV.log(l_module_name,'l_shipped_quantity',l_shipped_quantity2);
            WSH_DEBUG_SV.log(l_module_name,'l_assigned_req_qtys( j ',l_assigned_req_qtys( j ));
            WSH_DEBUG_SV.log(l_module_name,'l_assigned_cc_qtys( j ) ',l_assigned_cc_qtys( j ));

end if;
          if ( l_assigned_shp_qtys ( j ) is null  ) then
              l_bo_mode      := 'CYCLE_COUNT' ;
          else
              l_bo_mode      := 'UNRESERVE' ;
          end if ;

        -- 6d. p_action_flag = T : STAGE  UNSPECIFIED QUANTITIES

        ELSIF (p_action_flag = 'T') THEN

          l_shipped_quantity  := nvl(l_assigned_shp_qtys ( j ), 0);
          l_shipped_quantity2 := l_assigned_shp_qtys2 ( j );
          l_cycle_quantity  := nvl(l_assigned_cc_qtys( j ), 0);
          l_cycle_quantity2   := l_assigned_cc_qtys2( j ) ;
          l_bo_mode      := 'UNRESERVE' ;

        -- 6e. p_action_flag = A : SHIP ALL

        ELSIF (p_action_flag = 'A') THEN
          -- Bug 2112196 : If ship All , then don't update shipped_quantity if its being overshiped.
          l_shipped_quantity  :=  greatest ( nvl(l_assigned_shp_qtys ( j ), 0),
                     l_assigned_pick_qtys( j ));
          l_shipped_quantity2 :=  greatest ( nvl(l_assigned_shp_qtys2 ( j ), 0),
                     l_assigned_pick_qtys2( j ));

          l_cycle_quantity  := 0;
          -- HW BUG#:2005977 added cycle quantity2
          l_cycle_quantity2 := NULL;

        END IF;

        -- If line is overpicked, we need to backorder/cycle-count the unshipped picked quantity in
        -- excess of the requested quantity.
        -- Important: original value of req_qtys must be used before unassigning staged quantities.
        l_unshipped_pick_quantity  := l_assigned_pick_qtys( j )
                         - GREATEST(l_assigned_req_qtys( j ), l_shipped_quantity);
        l_unshipped_pick_quantity2 := l_assigned_pick_qtys2( j )
                         - GREATEST(l_assigned_req_qtys2( j ), l_shipped_quantity2);


        -- 7. Unassign staged lines (split if necessary, store delivery detail ids)

        -- because of overpicking/overshipping, both quantities should be at minimum 0.
        --   quantity (picked-requested) cannot be staged.
        l_stage_quantity  := GREATEST(l_assigned_req_qtys( j )  - l_shipped_quantity-l_cycle_quantity, 0);
        l_stage_quantity2 := GREATEST(l_assigned_req_qtys2( j ) - l_shipped_quantity2-l_cycle_quantity2, 0);

-- HW Bug 3694454 For OPM if l_stage_quantity < .00001 due to small decimal mismatch in
-- Requested Quantity and picked quantity then make both quantities zero.
-- HW OPMCONV - Removed Branching
           IF (l_stage_quantity < .00001) THEN
              l_stage_quantity  := 0;
              l_stage_quantity2 := 0;
           END IF;

-- End Bug 3694454


        IF (l_stage_quantity > 0) THEN
         IF (l_stage_quantity =  l_assigned_req_qtys( j ) ) THEN
            l_staged_dd_id := l_assigned_line_ids( j );
         ELSE
              l_assigned_req_qtys( j ) := l_assigned_req_qtys( j ) - l_stage_quantity ;
              l_assigned_pick_qtys( j ):= l_assigned_pick_qtys( j ) - l_stage_quantity ;
              -- HW BUG#:2005977 added qty2 for OPM
              l_assigned_req_qtys2( j ) := l_assigned_req_qtys2( j ) - l_stage_quantity2 ;
              l_assigned_pick_qtys2( j ):= l_assigned_pick_qtys2( j ) - l_stage_quantity2 ;

          /* bug fix 1983460
          Now we pass a value 'Y' to the parameter 'p_manual_split' in the call
          to split_delivery_details. 'Y' is used only as a indicator to tell the
          split_delivery_details that the split call is for splitting the STAGED     quantity
          */

          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.SPLIT_DELIVERY_DETAILS',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          wsh_delivery_details_actions.split_delivery_details(
              p_from_detail_id => l_assigned_line_ids( j ),
              p_req_quantity   => l_stage_quantity,
              x_new_detail_id  => l_new_detail_id,
              x_return_status  => x_return_status,
              p_unassign_flag  => 'N',
              p_req_quantity2  => l_stage_quantity2,
              p_manual_split   => 'Y');

          IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                l_num_error := l_num_error + 1 ;
                goto confirm_error;
          ELSE
            l_staged_dd_id := l_new_detail_id;
          END IF;
        END IF; -- if stage quantity = requested quantity

           /* H integration: 945 cancel staged wrudge */
           IF l_assigned_source( j ) = 'WSH' THEN

-- Bug 2713285
-- for cancelling any line in delivery thru Batch process
             IF l_batch_id IS NOT NULL THEN
               FND_MESSAGE.SET_NAME('WSH','WSH_DEL_CANCEL_DET_ERROR');
               x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
               wsh_util_core.add_message(x_return_status);
               l_num_error := l_num_error + 1;
               goto confirm_error_no_msg;
             END IF;
-- Bug 2713285
             l_cancel_line_ids ( l_cancel_line_ids.count+1) := l_staged_dd_id;
           ELSE
             l_stage_rows(l_stage_rows.count + 1) := l_staged_dd_id;
           END IF;

      END IF; -- (l_stage_quantity > 0)


        -- Populate the tables to be passed as parameters for Backorder API.

        IF ( ( l_cycle_quantity > 0 )  OR  ( l_unshipped_pick_quantity > 0 ) )THEN
          if ( l_bo_mode = 'UNRESERVE') then
                 l_bo_rows ( l_bo_rows.count + 1  )   :=  l_assigned_line_ids ( j ) ;
		 -- Consolidation of BO Delivery Details project
		 l_bo_source_lines(l_bo_source_lines.count +1) := l_assigned_source_lines(j);
                 l_bo_qtys ( l_bo_qtys.count + 1  )   :=  l_cycle_quantity;
                 l_bo_req_qtys ( l_bo_req_qtys.count + 1 ):= l_assigned_req_qtys( j ) ;
                 l_bo_overpick_qtys ( l_bo_overpick_qtys.count + 1 ):= l_unshipped_pick_quantity;
                 l_bo_qtys2( l_bo_qtys2.count + 1  )   := l_cycle_quantity2 ;
                 l_bo_overpick_qtys2 ( l_bo_overpick_qtys2.count + 1 ):= l_unshipped_pick_quantity2;
          else
                 l_cc_rows ( l_cc_rows.count + 1  )   :=  l_assigned_line_ids ( j ) ;
		 -- Consolidation of BO Delivery Details project
		 l_cc_source_lines(l_cc_source_lines.count +1) := l_assigned_source_lines(j);
                 l_cc_qtys ( l_cc_qtys.count + 1  )   :=  l_cycle_quantity ;
          IF l_debug_on THEN
            WSH_DEBUG_SV.push(l_module_name);
            --
            WSH_DEBUG_SV.log(l_module_name,'l_cycle_quantity',l_cycle_quantity);
          END IF;

                 l_cc_req_qtys ( l_cc_req_qtys.count + 1 ):= l_assigned_req_qtys( j ) ;
                 l_cc_overpick_qtys ( l_cc_overpick_qtys.count + 1 ):= l_unshipped_pick_quantity ;

                 l_cc_qtys2( l_cc_qtys2.count + 1  )   := l_cycle_quantity2 ;
                 IF l_debug_on THEN
            WSH_DEBUG_SV.push(l_module_name);
            --
            WSH_DEBUG_SV.log(l_module_name,'l_cycle_quantity2',l_cycle_quantity2);
          END IF;
                 l_cc_overpick_qtys2( l_cc_overpick_qtys2.count + 1  )   := l_unshipped_pick_quantity2 ;
          end if ;
        END IF  ;

        IF (l_cycle_quantity <> l_assigned_req_qtys( j )) THEN
            l_backorder_all_flag := FALSE;
        END IF;

        IF ( l_shipped_quantity > 0 ) THEN
           l_shp_dd_ids( l_shp_dd_ids.count + 1 )     := l_assigned_line_ids( j );
           l_shp_dd_orgs( l_shp_dd_orgs.count + 1 )     := l_assigned_orgs( j );
           l_shp_dd_items( l_shp_dd_items.count + 1 )   := l_assigned_items( j );
           l_shp_dd_subs( l_shp_dd_subs.count + 1 )     := l_assigned_subs( j );
           l_shp_dd_locs( l_shp_dd_locs.count + 1 )     := l_assigned_locs( j );
           l_shp_dd_cont_ids ( l_shp_dd_cont_ids.count + 1 ) := l_assigned_cont_ids ( j );
           l_shp_dd_shipped_qtys ( l_shp_dd_shipped_qtys.count + 1 ) := l_shipped_quantity ;
           l_shp_dd_shipped_qtys2 ( l_shp_dd_shipped_qtys2.count + 1 ) := l_shipped_quantity2 ;
           l_shp_dd_cc_qtys ( l_shp_dd_cc_qtys.count + 1 ) := l_cycle_quantity ;
           l_shp_dd_cc_qtys2 ( l_shp_dd_cc_qtys2.count + 1 ) := l_cycle_quantity2 ;
           l_shp_dd_req_qtys  ( l_shp_dd_req_qtys .count + 1 ) :=  l_assigned_req_qtys( j );
           /* H integration: 945 check detail  wrudge */
           l_shp_dd_source( l_shp_dd_source.count + 1)     := l_assigned_source( j );
        END IF ;

        /* LG new OPM -- OM changes*/

-- HW OPMCONV. Removed forking the code

      END LOOP ; -- For all delivery details still assigned

     END IF ;  -- If P_action_flag

     -- 8. Update quantities based on p_action_flag for null values (shipped and cycle count)

     FORALL tmp_counter IN 1..l_shp_dd_ids.count
       UPDATE wsh_delivery_Details
       SET shipped_quantity  = l_shp_dd_shipped_qtys(tmp_counter),
           shipped_quantity2  = l_shp_dd_shipped_qtys2(tmp_counter),
           cycle_count_quantity = l_shp_dd_cc_qtys(tmp_counter),
           cycle_count_quantity2 = l_shp_dd_cc_qtys2(tmp_counter)
       WHERE  delivery_detail_id = l_shp_dd_ids(tmp_counter);

     IF (p_action_flag = 'A') THEN --bugfix 4070732
     --{
         -- J: W/V Changes
         -- Recalculate the W/V as the quantities would have changed
         FOR tmp_counter IN 1..l_shp_dd_ids.count LOOP
           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.Detail_Weight_Volume',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;

           WSH_WV_UTILS.Detail_Weight_Volume(
             p_delivery_detail_id => l_shp_dd_ids(tmp_counter),
             p_update_flag        => 'Y',
             p_post_process_flag  => 'Y',
             p_calc_wv_if_frozen  => 'N',
             x_net_weight         => l_net_weight,
             x_volume             => l_volume,
             x_return_status      => l_return_status);

           IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
             x_return_status := l_return_status;
             IF l_debug_on THEN
               WSH_DEBUG_SV.pop(l_module_name,'Detail_Weight_Volume returned '||l_return_status);
               WSH_DEBUG_SV.pop(l_module_name);
             END IF;
             return;
           END IF;
         END LOOP;

     --}
     END IF;

     -- HW Added fix from bug 2024384 to NULL SHIPPED_QUANTITY(S) and
     -- CYCLE_COUNT_QUANTITY(S)

     -- csun, Bug 2823512, if the transaction_temp_id is not NULL
     -- set the shipped_quantity to be requested_quantity

     FORALL tmp_counter IN 1..l_stage_rows.count
       UPDATE WSH_DELIVERY_DETAILS
       SET  -- TRACKING_NUMBER = NULL, Bug# 3632485
            SHIPPED_QUANTITY = DECODE (SERIAL_NUMBER, NULL,
                                       DECODE(TRANSACTION_TEMP_ID, NULL, NULL, PICKED_QUANTITY),
                                       PICKED_QUANTITY),
            SHIPPED_QUANTITY2 = DECODE (SERIAL_NUMBER, NULL,
                                       DECODE(TRANSACTION_TEMP_ID, NULL, NULL, PICKED_QUANTITY2),
                                       PICKED_QUANTITY2),
            CYCLE_COUNT_QUANTITY = DECODE (SERIAL_NUMBER, NULL ,
                                           DECODE(TRANSACTION_TEMP_ID, NULL, NULL, 0) , 0),
            CYCLE_COUNT_QUANTITY2 = DECODE (SERIAL_NUMBER, NULL,
                                           DECODE(TRANSACTION_TEMP_ID, NULL, NULL, 0), 0)
       WHERE  DELIVERY_DETAIL_ID = l_stage_rows(tmp_counter);

     -- J: W/V Changes
     -- Recalculate the W/V as the quantities would have changed with the above update


     -- 10. Backorder quantities and unassign(split if necessary)

     IF (l_cc_rows.count > 0 ) THEN

         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIP_CONFIRM_ACTIONS2.BACKORDER',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --

         wsh_ship_confirm_actions2.backorder(
          p_detail_ids => l_cc_rows ,
      	  p_line_ids   => l_cc_source_lines,  -- Consolidation of BO Delivery Details project
          p_bo_qtys => l_cc_qtys ,
          p_req_qtys   => l_cc_req_qtys ,
          p_bo_qtys2   => l_cc_qtys2 ,
          p_overpick_qtys   => l_cc_overpick_qtys ,
          p_overpick_qtys2  => l_cc_overpick_qtys2 ,
          p_bo_mode => 'CYCLE_COUNT' ,
          x_out_rows  => l_out_bo_rows ,
	  x_cons_flags   => l_cons_flags,               -- Consolidation of BO Delivery Details project
          x_return_status  => l_return_status);

          IF ( l_return_status <>  WSH_UTIL_CORE.G_RET_STS_SUCCESS )  THEN
             IF ( l_return_status =  WSH_UTIL_CORE.G_RET_STS_ERROR OR
            l_return_status =  WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)  THEN
              l_num_error := l_num_error + 1 ;
              goto confirm_error_no_msg;
             ELSE
               l_num_warn := l_num_warn + 1 ;
             END IF ;
          END IF ;

    END IF;

     IF (l_bo_rows.count > 0 ) THEN

         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIP_CONFIRM_ACTIONS2.BACKORDER',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --

         wsh_ship_confirm_actions2.backorder(
          p_detail_ids => l_bo_rows ,
       	  p_line_ids   => l_bo_source_lines,  -- Consolidation of BO Delivery Details project
          p_bo_qtys => l_bo_qtys ,
          p_req_qtys   => l_bo_req_qtys ,
          p_bo_qtys2   => l_bo_qtys2 ,
          p_overpick_qtys  => l_bo_overpick_qtys ,
          p_overpick_qtys2 => l_bo_overpick_qtys2 ,
          p_bo_mode => 'UNRESERVE' ,
          x_out_rows  => l_out_cc_rows ,
	  x_cons_flags   => l_cons_flags,               -- Consolidation of BO Delivery Details project
          x_return_status  => l_return_status);

          IF ( l_return_status <>  WSH_UTIL_CORE.G_RET_STS_SUCCESS )  THEN
             IF ( l_return_status =  WSH_UTIL_CORE.G_RET_STS_ERROR OR
              l_return_status =  WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)  THEN
              l_num_error := l_num_error + 1 ;
              goto confirm_error_no_msg;
             ELSE
               l_num_warn := l_num_warn + 1 ;
             END IF ;
          END IF ;

    END IF;



    -- 11  Check for holds and inventory controls of details to be shipped

    FOR dd_count IN 1..l_shp_dd_ids.count LOOP

      dft_subinv := NULL;
      dft_loc_id := NULL;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_VALIDATIONS.CHECK_DETAIL_FOR_CONFIRM',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      WSH_DELIVERY_VALIDATIONS.check_detail_for_confirm
          ( p_detail_id   => l_shp_dd_ids(dd_count),
            p_check_credit_init_flag => l_check_credit_init_flag, -- bug 2343058
            x_line_inv_flag_rec => l_inv_controls_rec,
            x_return_status => l_return_status);

      IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
           l_num_error := l_num_error + 1;
           raise ship_confirm_error;
        /* H integration: 945 check detail wrudge */
        ELSIF l_shp_dd_source(dd_count) = 'WSH' THEN
        /* new message: WSH_DEL_WSH_LINE_ERROR, token DEL_NAME  */
          FND_MESSAGE.SET_NAME('WSH','WSH_DEL_WSH_LINE_ERROR');
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(l_delivery_id));
          wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR);
          l_num_error := l_num_error + 1;
          goto confirm_error_no_msg;
        ELSE
-- Bug 2713285
-- for inventory control items, lines are unassigned from Delivery
-- thru batch process
          IF l_batch_id IS NOT NULL THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    IF l_inv_controls_rec.details_required_flag='Y' THEN --Bug 3773225
               FND_MESSAGE.SET_NAME('WSH','WSH_DEL_DETAILS_REQUIRED');
               wsh_util_core.add_message(x_return_status);
	    ELSIF l_inv_controls_rec.invalid_material_status_flag='Y' THEN --Material Status Impact
               FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_MATERIAL_STATUS');
               wsh_util_core.add_message(x_return_status);
            END IF;
	    l_num_error := l_num_error + 1;
            goto confirm_error_no_msg;
          END IF;
-- Bug 2713285

          l_unassign_dds(l_unassign_dds.count + 1) := l_shp_dd_ids(dd_count);
  	  l_unassign_rel_status(l_unassign_rel_status.count + 1) := 'Y';
 	  l_unassign_source_lines(l_unassign_source_lines.count + 1) := l_source_line_id;  -- Bug#3246327
          l_num_warn := l_num_warn + 1;

          /* Bug fix 2850555
          Need to set l_inv_cntrl_flag to FALSE ONLY when details_required_flag
          is set to Y by 'check_detail_for_confirm' procedure.
          Reason: For cases where inv controls are not really required, like
          the bug case where only HOLDS are a problem, l_inv_cntrl_flag
          should NOT be set to FALSE
          */

          if l_debug_on then
             wsh_debug_sv.log(l_module_name, 'l_inv_controls_rec.details_required_flag', l_inv_controls_rec.details_required_flag);
          end if;

          if nvl(l_inv_controls_rec.details_required_flag, 'N') = 'Y' then
             l_inv_cntrl_flag := FALSE;
             -- bug 2283621 - accumulate the l_inv_ctrl_dd_ids up to 5 delivery details
             -- l_unassign_dds can be used all because it could contain unreleased lines.
             l_inv_ctrl_dd_count := l_inv_ctrl_dd_count + 1;
             IF ( l_inv_ctrl_dd_count = 1 ) THEN
                l_inv_ctrl_dd_ids := l_unassign_dds(l_unassign_dds.count);
             ELSIF ( l_inv_ctrl_dd_count <= 5 ) THEN
                l_inv_ctrl_dd_ids := l_inv_ctrl_dd_ids || ', ' || l_unassign_dds(l_unassign_dds.count);
             ELSIF ( l_more_dd_flag ) THEN
                l_inv_ctrl_dd_ids := l_inv_ctrl_dd_ids || ',..';
                l_more_dd_flag := FALSE;
             END IF;
             -- end bug 2283621
          /***************************Material Status Project***************************************/
          ELSIF nvl(l_inv_controls_rec.invalid_material_status_flag, 'N') = 'Y' then
             l_inv_material_flag := FALSE;
             -- bug 2283621 - accumulate the l_inv_ctrl_dd_ids up to 5 delivery details
             -- l_unassign_dds can be used all because it could contain unreleased lines.
             l_inv_material_dd_count := l_inv_material_dd_count + 1;
             IF ( l_inv_material_dd_count = 1 ) THEN
                l_inv_material_dd_ids := l_unassign_dds(l_unassign_dds.count);
             ELSIF ( l_inv_material_dd_count <= 5 ) THEN
                l_inv_material_dd_ids := l_inv_ctrl_dd_ids || ', ' || l_unassign_dds(l_unassign_dds.count);
             ELSIF ( l_more_material_dd_flag ) THEN
                l_inv_material_dd_ids := l_inv_material_dd_ids || ',..';
                l_more_material_dd_flag := FALSE;
             END IF;
          /***************************Material Status Project***************************************/
          end if;

          x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING ;
        END IF;
      ELSE
        l_unassign_all_flag_tab(i) := FALSE ;

        IF (l_shp_dd_cont_ids(dd_count) IS NULL) THEN
          l_unpacked_flag := TRUE;
        ELSE
-- Bug 2878538
-- Cont exists flag should be set even if there is 1 container
-- else it will be FALSE by default
          l_cont_exists_flag := TRUE;
        END IF; -- (if container_id IS NULL)

       END IF; -- (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS)

       -- bug 2320388
       l_check_credit_init_flag := FALSE;

       -- Need to do this for non-transactable items to get default sub and loc

       IF (l_shp_dd_subs ( dd_count ) IS NULL) THEN
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_INV.DEFAULT_SUBINVENTORY',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --
         WSH_DELIVERY_DETAILS_INV.Default_Subinventory ( l_shp_dd_orgs ( dd_count ),
                                 l_shp_dd_items( dd_count ),
                                 dft_subinv,
                                 x_return_status);
         IF ( l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ) THEN
          raise ship_confirm_error;
         END IF;

       END IF;

       -- Removed Details_required from here , because it was already called in
       -- check_detail_for_confirm.

       IF ((NVL(l_shp_dd_subs ( dd_count ),dft_subinv) IS NOT NULL) AND (l_shp_dd_locs ( dd_count ) IS NULL)) THEN
           --
           -- Debug Statements
           --
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_INV.GET_ORG_LOC',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           --
           org_loc_ctl := WSH_DELIVERY_DETAILS_INV.Get_Org_Loc (l_shp_dd_orgs ( dd_count ));

           --
           -- Debug Statements
           --
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_INV.SUB_LOC_CTL',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           --
           sub_loc_ctl := WSH_DELIVERY_DETAILS_INV.Sub_Loc_Ctl (
                      nvl(l_shp_dd_subs ( dd_count ),dft_subinv),
                      l_shp_dd_orgs ( dd_count ));

           item_loc_ctl := l_inv_controls_rec.location_control_code;
           --
           -- Debug Statements
           --
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_INV.LOCATOR_CTL_CODE',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           --
           loc_ctl_code := WSH_DELIVERY_DETAILS_INV.Locator_Ctl_Code(
                             l_shp_dd_orgs ( dd_count ),
                             l_inv_controls_rec.restrict_loc,
                             org_loc_ctl,
                             sub_loc_ctl,
                             item_loc_ctl);

           IF ( loc_ctl_code <> 1 ) THEN
               IF ( l_inv_controls_rec.restrict_loc = 1) THEN
                 loc_restricted_flag := 'Y';
               ELSE
                 loc_restricted_flag := 'N';
               END IF;

               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_INV.DEFAULT_LOCATOR',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               --
               dft_loc_id := WSH_DELIVERY_DETAILS_INV.Default_Locator (
                                     l_shp_dd_orgs ( dd_count ),
                                     l_shp_dd_items ( dd_count ),
                                     NVL(l_shp_dd_subs ( dd_count ), dft_subinv),
                                     loc_restricted_flag);
           END IF;

           -- performance bug 5257207: SC-13, do this update only when needed.
           IF    (l_shp_dd_subs(dd_count) IS NULL AND dft_subinv IS NOT NULL)
              OR (dft_loc_id IS NOT NULL) THEN
             IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name, 'updating subinv/locator');
                WSH_DEBUG_SV.log(l_module_name, 'dft_subinv', dft_subinv);
                WSH_DEBUG_SV.log(l_module_name, 'dft_loc_id', dft_loc_id);
             END IF;
             update wsh_delivery_details set
               subinventory      = NVL(subinventory, dft_subinv),
               locator_id        = NVL(locator_id,   dft_loc_id)
             where delivery_detail_id = l_shp_dd_ids ( dd_count );
           END IF;

       END IF;
       -- End for non-transactable items

    END LOOP ;

    IF (NOT l_inv_cntrl_flag) THEN
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'g_missing_inv_severity - '|| g_missing_inv_severity);
        End If;
        If g_missing_inv_severity is null then
           g_missing_inv_severity := wsh_ru_actions.get_message_severity (wsh_new_delivery_actions.g_ship_confirm_act
                                                                         ,wsh_new_delivery_actions.g_missing_inv_cntl_msg);
        End If;

        -- bug 2283621 - pass the l_inv_ctrl_dd_ids to the warning message
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_inv_ctrl_dd_ids - '|| l_inv_ctrl_dd_ids);
           WSH_DEBUG_SV.log(l_module_name,'g_missing_inv_severity - '|| g_missing_inv_severity);
        END IF;

        If g_missing_inv_severity = 'E' then
            FND_MESSAGE.SET_NAME('WSH','WSH_DEL_DETAILS_INV_CONTROLS');
            FND_MESSAGE.Set_Token('DETAIL_IDS', l_inv_ctrl_dd_ids);
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            wsh_util_core.add_message(x_return_status);
            WSH_NEW_DELIVERY_ACTIONS.g_error_level := 'E';
            l_num_error := l_num_error + 1;
            goto confirm_error_no_msg;
        Else
            FND_MESSAGE.SET_NAME('WSH','WSH_DEL_DETAILS_INV_CONTROLS');
            FND_MESSAGE.Set_Token('DETAIL_IDS', l_inv_ctrl_dd_ids);
            x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
            wsh_util_core.add_message(x_return_status);
            WSH_NEW_DELIVERY_ACTIONS.g_error_level := 'E';
        End If;
    END IF;
    /***************************Material Status Project***************************************/
    IF (NOT l_inv_material_flag) THEN
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'g_missing_inv_severity - '|| g_missing_inv_severity);
        End If;
        If g_missing_inv_severity is null then
           g_missing_inv_severity := wsh_ru_actions.get_message_severity (
                                       wsh_new_delivery_actions.g_ship_confirm_act,
                                       wsh_new_delivery_actions.g_invalid_material_status_msg);
        End If;

        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_inv_material_dd_ids - '|| l_inv_material_dd_ids);
           WSH_DEBUG_SV.log(l_module_name,'g_missing_inv_severity - '|| g_missing_inv_severity);
        END IF;

        If g_missing_inv_severity = 'E' then
            FND_MESSAGE.SET_NAME('WSH','WSH_DETAILS_MATERIAL_STATUS');
            FND_MESSAGE.Set_Token('DETAIL_IDS', l_inv_material_dd_ids);
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            wsh_util_core.add_message(x_return_status);
            WSH_NEW_DELIVERY_ACTIONS.g_error_level := 'E';
            l_num_error := l_num_error + 1;
            goto confirm_error_no_msg;
        Else
            FND_MESSAGE.SET_NAME('WSH','WSH_DETAILS_MATERIAL_STATUS');
            FND_MESSAGE.Set_Token('DETAIL_IDS', l_inv_material_dd_ids);
            x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
            wsh_util_core.add_message(x_return_status);
            WSH_NEW_DELIVERY_ACTIONS.g_error_level := 'E';
        End If;
    END IF;
    /***************************Material Status Project***************************************/

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TPA_DELIVERY_PKG.CHECK_RELEASED_LINES',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    wsh_tpa_delivery_pkg.check_released_lines(
        p_del_rows(i), l_unassign_dds.count,
        l_detail_num-l_unassign_dds.count, l_return_status);

    IF ( l_return_status <>  WSH_UTIL_CORE.G_RET_STS_SUCCESS )  THEN
      IF ( l_return_status =  WSH_UTIL_CORE.G_RET_STS_ERROR OR
        l_return_status =  WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)  THEN
        l_num_error := l_num_error + 1 ;
      ELSE
        l_num_warn := l_num_warn + 1 ;
      END IF ;
      goto loop_end ;
    END IF ;


    -- Consolidation of BO Delivery Details project.
    -- At this point of time, some of the dd_ids in l_unassign_dds with released_status as 'B'
    -- might have been deleted by wsh_ship_confirm_actions2.backorder api.
    -- So checking whether dd_ids to be unassigned are already deleted.
    -- Do this only if there are lines to be unassigned AND there is atleast one delivery line BackOrdered.
    -- Begin
    IF (l_unassign_dds.COUNT > 0 AND (l_out_bo_rows.count > 0 OR l_out_cc_rows.count > 0)) THEN
    -- --{
	--
	-- Debug Statements
	--
        -- Shifted code to obtain Global parameters outside the Deliveries loop ***

        IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Back Order Consolidation Flag is set as '||l_global_parameters.consolidate_bo_lines, WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        IF (l_global_parameters.consolidate_bo_lines = 'Y') THEN
	-- --{
	   -- l_out_bo_rows contains list of dd_ids that were Backordered
	   -- l_out_cc_rows contains list of dd_ids that were Cycle Count
           IF (l_out_bo_rows.count > 0) THEN
	      l_unassign_backordered_dds := l_out_bo_rows;
	   ELSIF (l_out_cc_rows.count > 0) THEN
	      l_unassign_backordered_dds := l_out_cc_rows;
	   END IF;

	   -- Bug#3246327
	   --
	   -- Store backordered order line ids in the pl/sql table l_bo_line_ids
	   IF (l_bo_source_lines.count > 0) THEN
		l_bo_line_ids := l_bo_source_lines; -- Assign the partial backordered soure lines to l_bo_line_ids
	   ELSIF (l_cc_source_lines.count > 0 ) THEN -- Assign the partial cycle-count soure lines to l_bo_line_ids
		l_bo_line_ids := l_cc_source_lines;
	   ELSIF (l_assigned_source_lines.count > 0) THEN -- Assign the completely backordered or cycle-counted lines
                l_bo_line_ids := l_assigned_source_lines;
 	   END IF;

	   -- Bug#3317692
	   -- Compare l_unassign_source_lines and l_bo_line_ids and
	   -- delete the entry in l_unassign_source_lines if it is not there in l_bo_line_ids.
	   -- These changes are done to restrict the filtering of l_unassign_dds only
	   -- if the corresponding line is backordered.
	   l_idx := l_unassign_source_lines.FIRST;
	   WHILE l_idx IS NOT NULL LOOP
	   -- --{
	         l_flag := 'N';
	         l_cmp_idx := l_bo_line_ids.FIRST;
	         WHILE l_cmp_idx IS NOT NULL LOOP -- --{
                   IF (l_unassign_source_lines(l_idx) = l_bo_line_ids(l_cmp_idx)) THEN
	 	     l_flag := 'Y';
   	             EXIT;
	           END IF;
		   l_cmp_idx := l_bo_line_ids.NEXT(l_cmp_idx);
	         END LOOP;  -- --}
	         IF l_flag = 'N' THEN
  	           l_unassign_source_lines.DELETE(l_idx);
                 END IF;
	      l_idx := l_unassign_source_lines.NEXT(l_idx);
	   END LOOP;  -- --}
	   --

	   l_idx := l_unassign_dds.FIRST;
	   WHILE l_idx IS NOT NULL LOOP
	   -- --{
	   -- Loop thru' l_unassign_dds and check whether delivery_detail_id exists
	   -- in l_unassign_backordered_dds, if NOT then Delete that dd_id from l_unassign_dds because
	   -- it must already be physically deleted by the backorder API.
   	   -- [ This check should happen for dd_ids in l_unassign_dds, ONLY if the released_status is 'B'
	   -- and if the dd_id is under the backordered source line ]
	   -- Filter l_unassign_dds only if the corresponding Order line is backordered. ie., l_unassign_source_lines.EXISTS
	      IF (l_unassign_source_lines.EXISTS(l_idx) AND l_unassign_rel_status(l_idx) = 'B') THEN --{
    	         l_flag := 'N';
	         l_cmp_idx := l_unassign_backordered_dds.FIRST;
	         WHILE l_cmp_idx IS NOT NULL LOOP -- --{
                   IF (l_unassign_dds(l_idx) = l_unassign_backordered_dds(l_cmp_idx)) THEN
	 	     l_flag := 'Y';
   	             EXIT;
	           END IF;
		   l_cmp_idx := l_unassign_backordered_dds.NEXT(l_cmp_idx);
	         END LOOP;  -- --}
	         IF l_flag = 'N' THEN
  	           l_unassign_dds.DELETE(l_idx);
                 END IF;
	      END IF; --},  l_unassign_rel_status(l_idx) = 'B'
	      l_idx := l_unassign_dds.NEXT(l_idx);
	   END LOOP;  -- --}
	   -- Now, l_unassign_dds contains only the not-deleted dd_ids.

	   l_unassign_backordered_dds.DELETE;
	   j := l_unassign_dds.FIRST;
	   -- Following loop just puts the dd_ids in contiguous locations in the pl/sql table
	   WHILE j IS NOT NULL LOOP
	    	l_unassign_backordered_dds(l_unassign_backordered_dds.count+1) := l_unassign_dds(j);
	        j := l_unassign_dds.NEXT(j);
	   END LOOP;
	   l_unassign_dds.DELETE;
	   l_unassign_dds := l_unassign_backordered_dds;
	END IF; -- --}, l_global_parameters.consolidate_bo_lines
    END IF;  -- --}, l_unassign_dds.count > 0
    -- End, Consolidation of BO Delivery Details project

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.UNASSIGN_UNPACK_EMPTY_CONT',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;

    -- Unassign the lines marked for unassigning.
    WSH_DELIVERY_DETAILS_ACTIONS.unassign_unpack_empty_cont(
                          p_ids_tobe_unassigned  => l_unassign_dds ,
                          p_validate_flag        => 'N', -- want it to succeed in case of Planned Deliveries
                          x_return_status        => l_return_status
                         );

    IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                            WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR))
    THEN
      x_return_status := l_return_status;
      l_num_error := l_num_error + 1 ;
      goto loop_end;
    ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
      l_num_warn := l_num_warn + 1;
    END IF;

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERY_ACTIONS.CONT_TOBE_UNASSIGNED',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    -- Identify the Staged Lines or Containers to be Unassigned from the Delivery
    Cont_ToBe_Unassigned ( p_staged_lines    => l_stage_rows,
                           x_unassigned_cont => x_unassigned_cont,
                           x_return_status   => l_return_status
                         );

    IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                            WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR))
    THEN
      x_return_status := l_return_status;
      wsh_util_core.add_message(x_return_status);
      l_num_error := l_num_error + 1 ;
      goto loop_end;
    ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
      l_num_warn := l_num_warn + 1;
    END IF;

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.UNASSIGN_UNPACK_EMPTY_CONT',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    -- Unassign Containers or Staged Lines using new API
    WSH_DELIVERY_DETAILS_ACTIONS.unassign_unpack_empty_cont(
                          p_ids_tobe_unassigned => x_unassigned_cont ,
                          p_validate_flag   => 'N', -- want it to succeed for Planned Deliveries too
                          x_return_status   => l_return_status
                         );

    IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                            WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR))
    THEN
      x_return_status := l_return_status;
      l_num_error := l_num_error + 1 ;
      goto loop_end;
    ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
      l_num_warn := l_num_warn + 1;
    END IF;

    /* H integration: 945 cancel staged/unreleased */
    -- Cancel/delete lines marked for cancelling
    IF l_cancel_line_ids.count > 0 THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INTERFACE.DELETE_DETAILS',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      wsh_interface.delete_details(
        p_details_id     => l_cancel_line_ids,
        x_return_status   => l_return_status);

      IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
      /* new message: WSH_DEL_CANCEL_DET_ERROR, token DEL_NAME */
        FND_MESSAGE.SET_NAME('WSH','WSH_DEL_CANCEL_DET_ERROR');
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_del_rows(i)));
        x_return_status := l_return_status;
        wsh_util_core.add_message(x_return_status);
        l_num_error := l_num_error + 1 ;
        goto loop_end;
      END IF;
    END IF;

    -- Bug 5584951: Moved the call to after the call to unassign details.

    FOR tmp_counter IN 1..l_stage_rows.count LOOP
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.Detail_Weight_Volume',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;

       WSH_WV_UTILS.Detail_Weight_Volume(
         p_delivery_detail_id => l_stage_rows(tmp_counter),
         p_update_flag        => 'Y',
         p_post_process_flag  => 'Y',
         p_calc_wv_if_frozen  => 'N',
         x_net_weight         => l_net_weight,
         x_volume             => l_volume,
         x_return_status      => l_return_status);
        IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
          x_return_status := l_return_status;
          IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name,'Detail_Weight_Volume returned '||l_return_status);
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          return;
        END IF;
      END LOOP;

    -- Bug 2527887 : Moved this call after unassigning detail lines from delivery since the check will not work
    -- if the pending overpick lines are still assigned to the delivery
    -- 10.5 Make sure no source lines with at total requested qty of zero are shipped or left behind

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DETAILS_VALIDATIONS.CHECK_ZERO_REQ_CONFIRM',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    WSH_DETAILS_VALIDATIONS.check_zero_req_confirm(p_delivery_id => p_del_rows(i),
                                                   x_return_status => l_return_status);

    IF ( l_return_status <>  WSH_UTIL_CORE.G_RET_STS_SUCCESS )  THEN
       x_return_status := l_return_Status ;
       --wsh_util_core.add_message(x_return_status);
       l_delivery_id := p_del_rows(i);
       goto confirm_error_no_msg;
    END IF;


    -- Code Shifted from below 12. *** to here, since this is a mandatory step now - Workflow Changes
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIPPING_PARAMS_PVT.GET',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    WSH_SHIPPING_PARAMS_PVT.Get(
            p_organization_id => l_organization_id,
            x_param_info    => l_param_info,
            x_return_status   => l_return_status
     );


     IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
       FND_MESSAGE.Set_Name('WSH', 'WSH_PARAM_NOT_DEFINED');
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_ORG_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       --
       FND_MESSAGE.Set_Token('ORGANIZAION_CODE',
                     wsh_util_core.get_org_name(l_organization_id));
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       wsh_util_core.add_message(x_return_status);
                         WSH_NEW_DELIVERY_ACTIONS.g_error_level := 'E';
       goto confirm_error;
     END IF;
     --/== Workflow Changes
     l_enable_sc_wf := 'N';  --Workflow Changes
     l_override_wf:= fnd_profile.value('WSH_OVERRIDE_SCPOD_WF');
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'l_override_wf',l_override_wf);
         WSH_DEBUG_SV.log(l_module_name,'l_param_info.Enable_sc_wf',l_param_info.Enable_sc_wf);
         WSH_DEBUG_SV.log(l_module_name,'l_global_parameters.Enable_sc_wf',l_global_parameters.Enable_sc_wf);
         WSH_DEBUG_SV.log(l_module_name,'l_global_parameters.allow_future_ship_date',l_global_parameters.allow_future_ship_date);
     END IF;
     --
     IF  (l_param_info.Enable_sc_wf = 'Y' AND l_global_parameters.Enable_sc_wf = 'Y' AND nvl(l_override_wf,'N') = 'N') THEN
         -- Bug 8555654 : Should not start the workflow if ship confirm is going to fail due to actual dep. date validation.
         IF ( (nvl(p_actual_dep_date,sysdate) > sysdate)
              AND (nvl(l_global_parameters.allow_future_ship_date, 'N') = 'N')
              AND (p_intransit_flag = 'Y' OR p_close_flag = 'Y')  ) THEN
         --{
             l_enable_sc_wf := 'N';
         ELSE
             l_enable_sc_wf := 'Y';
         --}
         END IF;
         -- Bug 8555654 : : End
     END IF;
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'l_enable_sc_wf',l_enable_sc_wf);
     END IF;
     --
     --==/


     -- 9. If p_stage_del_flag= 'Y' then create deliveries for the stored delivery details above

     IF (p_stage_del_flag = 'Y') AND (l_stage_rows.count > 0) THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_AUTOCREATE.AUTOCREATE_DELIVERIES',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      wsh_delivery_autocreate.autocreate_deliveries(
      p_line_rows    => l_stage_rows ,
      p_init_flag   => 'Y' ,
      p_pick_release_flag => 'N' ,
      p_container_flag  => 'N' ,
      p_check_flag    => 'N' ,
      p_max_detail_commit => 1000,
      x_del_rows     => l_dummy_rows ,
      x_grouping_rows      => l_dummy_rows ,
      x_return_status  => l_return_status  ) ;

      IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
       l_num_warn := l_num_warn + 1;
      ELSIF (x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
       l_num_error := l_num_error + 1;
      END IF;

      --deliveryMerge
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERY_ACTIONS.Adjust_Planned_Flag',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      WSH_NEW_DELIVERY_ACTIONS.Adjust_Planned_Flag(
            p_delivery_ids          => l_dummy_rows,
            p_caller                => 'WSH_DLMG',
            p_force_appending_limit => 'N',
            p_call_lcss             => 'Y',
            p_event                 => NULL,
            x_return_status         => l_return_status);

      IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Adjust_Planned_Flag l_return_status',l_return_status);
      END IF;

      IF x_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        l_num_warn := l_num_warn + 1;
      ELSIF x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        l_num_error := l_num_error + 1;
      END IF;


     END IF;

    -- Bug 1729723 : Updating number_of_lpn for delivery , 1672188 : now doing it after unassignments.

    l_number_of_lpn(i)    := NULL;
    OPEN number_of_lpn(p_del_rows(i));
    FETCH number_of_lpn into l_number_of_lpn (i) ;
    CLOSE number_of_lpn;


    -- Check that all overpicked lines for  one source line are in the same delivery,
    -- so that we can guarantee that these lines will get interfaced to OM.
    -- we might look up CURSOR overpicked_outside_delivery( v_delivery_id in number ) or have new API...

    -- 12.  Calculate Weight volume etc
    --
    -- Debug Statements
    --
    --- Code to obtain Shipping parameters shifted from here *** - Workflow Changes
     l_enforce_packing_flag := l_param_info.enforce_packing_flag;

     -- Pack J, ITM -- Check if delivery needs to be marked for export compliance.
     l_itm_exc_severity := '-99';

     IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'severity of ITM exception',l_itm_exc_severity);
     END IF;

     IF l_param_info.export_screening_flag IN ('S', 'A') THEN


        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_VALIDATIONS.Check_ITM_Required',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --Bug 9326608 Changed l_itm_exc_flag to use i as index
        l_itm_exc_flag(i) :=  WSH_DELIVERY_VALIDATIONS.Check_ITM_Required
                                  (p_delivery_id => p_del_rows(i),
                                   x_return_status => l_return_status);
        IF l_debug_on THEN
           wsh_debug_sv.log(l_module_name,'Return Status After Calling WSH_DELIVERY_VALIDATIONS.Check_ITM_Required',l_return_status);
           WSH_DEBUG_SV.logmsg(l_module_name,'ITM flag: '||l_param_info.export_screening_flag);
           wsh_debug_sv.log(l_module_name,'l_itm_exc_flag for delivery: '|| p_del_rows(i),l_itm_exc_flag(i)); --Bug 9326608
        END IF;

        IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
           goto confirm_error;
        END IF;
        -- Find out the severity of the exception if it is enabled.
        --Bug 9326608 Changed l_itm_exc_flag to use i as index
        IF l_itm_exc_flag(i) = 'Y' THEN

           OPEN c_exc_severity('WSH_SC_REQ_EXPORT_COMPL');
           FETCH c_exc_severity INTO l_itm_exc_severity;
           CLOSE c_exc_severity;

        END IF;

           IF l_debug_on THEN
              wsh_debug_sv.log(l_module_name,'severity of ITM exception',l_itm_exc_severity);
           END IF;
     ELSE
        --Bug 9326608 Changed l_itm_exc_flag to use i as index
        l_itm_exc_flag(i) := 'N';

     END IF;


    -- J: W/V Changes
    -- 12.5 Give warning if delivery W/V is null depending on percent_fill_basis_flag

    IF (NOT l_unassign_all_flag_tab(i)) THEN
    -- Bug # 7580785:  Removed the call WSH_WV_UTILS.Delivery_Weight_Volume from here
    --                 as it is overriding the manually updated WMS LPN weights at the time of ship confirm.

      -- Get the latest W/V information.
      OPEN get_delivery_wv(p_del_rows(i));
      FETCH get_delivery_wv INTO l_gross_weight, l_volume;
      CLOSE get_delivery_wv;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Gross '||l_gross_weight||' Volume '||l_volume||' Fill basis '||l_param_info.percent_fill_basis_flag);
      END IF;

      IF (l_param_info.percent_fill_basis_flag = 'W' and l_gross_weight is NULL) THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_NULL_WV');
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        FND_MESSAGE.SET_TOKEN('ENTITY_TYPE','Delivery');
        FND_MESSAGE.SET_TOKEN('ENTITY_NAME',wsh_new_deliveries_pvt.get_name(p_del_rows(i)));
        FND_MESSAGE.SET_TOKEN('WV','Weight');
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        wsh_util_core.add_message(x_return_status);
        l_num_warn := l_num_warn + 1;
      END IF;

      IF (l_param_info.percent_fill_basis_flag = 'V' and l_volume is NULL) THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_NULL_WV');
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        FND_MESSAGE.SET_TOKEN('ENTITY_TYPE','Delivery');
        FND_MESSAGE.SET_TOKEN('ENTITY_NAME',wsh_new_deliveries_pvt.get_name(p_del_rows(i)));
        FND_MESSAGE.SET_TOKEN('WV','Volume');
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        wsh_util_core.add_message(x_return_status);
        l_num_warn := l_num_warn + 1;
      END IF;
    END IF;
    -- End J: W/V Changes

-- 2732719
-- Calculate fill pc of the containers in the delivery

      l_underfilled_flag := FALSE;
      l_overfilled_flag := FALSE;
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'COUNT -'||l_shp_dd_cont_ids.count);
      END IF;

      FOR rec_count in 1..l_shp_dd_cont_ids.count
      LOOP
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CHECK_FILL_PC',WSH_DEBUG_SV.C_PROC_LEVEL);
          WSH_DEBUG_SV.log(l_module_name,'Cont -'||l_shp_dd_cont_ids(rec_count));
        END IF;
        --
        wsh_wv_utils.check_fill_pc( p_container_instance_id => l_shp_dd_cont_ids(rec_count),
                                    x_fill_status           => l_fill_status,
                                    x_return_status         => l_return_status);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'RET STS -'||l_return_status);
          WSH_DEBUG_SV.log(l_module_name,'Fill St -'||l_fill_status);
          WSH_DEBUG_SV.log(l_module_name,'Fill St -'||l_save_fill_status);
        END IF;

        IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
            x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        ELSIF ( l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ) THEN
          raise ship_confirm_error;
        ELSIF (l_fill_status = 'U') THEN
          l_underfilled_flag := TRUE;
        ELSIF (l_fill_status = 'O') THEN
          l_overfilled_flag  := TRUE;
        END IF;

-- Bug 2878538
-- If l_save_fill_status is already saving U(nderfill) or O(verfill),then
-- don't override,else override if it is Null or S(uccess)
        IF nvl(l_save_fill_status,'X') = 'S' THEN
          l_save_fill_status := l_fill_status;
        END IF;

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Fill St -'||l_save_fill_status);
        END IF;

      END LOOP;

      l_fill_status := l_save_fill_status;

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'AFTER LOOP RET STS -'||l_return_status);
        WSH_DEBUG_SV.log(l_module_name,'AFTER LOOP SAV STS -'||l_save_fill_status);
        WSH_DEBUG_SV.log(l_module_name,'AFTER LOOP Fill St -'||l_fill_status);
      END IF;

-- 2732719
-- Calculate fill pc of the containers in the delivery


     --  Calculate weight volume for the delivery

     -- 13. Call check_confirm , it only has the TPA validations now.

     --  2131459 - added check for  l_unassign_all_flag_tab(i) and include steps 15 and 18 in this check
     IF (NOT l_unassign_all_flag_tab(i)) THEN



     -- Create trip from deconsol location to ultimate drop off
     -- consol deliveriers.

     IF l_mdc_co_del_tab.count > 0 THEN

        Create_Deconsol_Trips(p_deliveries_tab => p_del_rows,
                           x_return_status => l_return_status);

        IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
           raise ship_confirm_error;
        ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
           l_num_warn := l_num_warn + 1;
        END IF;


      END IF;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_VALIDATIONS.CHECK_CONFIRM',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      wsh_delivery_validations.check_confirm(
      p_delivery_id      => p_del_rows(i),
      p_actual_dep_date  => p_actual_dep_date,
      p_cont_exists_flag    => l_cont_exists_flag ,
      p_enforce_packing_flag  => l_enforce_packing_flag,
      p_ship_from_location  => l_ship_from_location,
      p_ship_to_location    => l_ship_to_location,
      p_freight_code      => l_freight_code ,
      p_overfilled_flag    => l_overfilled_flag,
      p_underfilled_flag    => l_underfilled_flag,
      p_organization_id    => l_organization_id ,
      p_initial_pickup_date   => l_initial_pickup_date(i),
      p_ultimate_dropoff_date => l_ultimate_dropoff_date(i),
      x_return_status  => l_return_status ) ;

       /*
       ** begin bug 2426743
       **    Warning should not set the message that delivery will not be confirmed.
       **    Error should rollback and not continue processing this delivery.
       */
       IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN

         FND_MESSAGE.SET_NAME('WSH','WSH_SHIP_CONFIRM_ERROR');
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
         goto confirm_error_no_msg;

       ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
-- Bug 2711786
-- for ship set,but this would include other validations done in
-- check_confirm API like for SMC also
         IF l_batch_id IS NOT NULL THEN
          -- FND_MESSAGE.SET_NAME('WSH','WSH_DEL_CANCEL_DET_ERROR');
          -- x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          -- wsh_util_core.add_message(x_return_status);
           l_num_error := l_num_error + 1;
           goto confirm_error_no_msg;
         END IF;
-- Bug 2711786

         --Ship Message Customization Project Change START
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'g_break_ship_set_or_smc ',g_break_ship_set_or_smc);
         END IF;
         If g_break_ship_set_or_smc > 0 then
            g_break_ship_set_or_smc := 0 ;
            l_num_error := l_num_error + 1;
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'l_num_error ',l_num_error);
               WSH_DEBUG_SV.logmsg(l_module_name,'g_break_ship_set_or_smc ',g_break_ship_set_or_smc);
            END IF;
            goto confirm_error_no_msg;
         End If;
         --Ship Message Customization Project Change END

         l_num_warn := l_num_warn + 1;
       END IF;
       /*
       ** end bug 2426743
       */

      -- Sequence delivery legs ( IS DONE IN CHECK_CONFIRM )

      IF (l_enforce_packing_flag = 'Y') THEN

        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TPA_DELIVERY_PKG.CHECK_DEL_UNPACKED',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_tpa_delivery_pkg.check_del_unpacked
                      (l_delivery_id,
                       l_cont_exists_flag,
                       l_unpacked_flag,
                       l_return_status);

        IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS)
                    THEN
            x_return_status := l_return_status;
          IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
            raise ship_confirm_error;
          ELSE
            l_num_warn := l_num_warn + 1;
          END IF;
        END IF;
      END IF;

      -- 15. Generate Packing Slip
      create_pack_slip(
        p_delivery_id => p_del_rows(i),
        x_return_status => l_return_status);

      IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
                    THEN
          l_num_error := l_num_error + 1;
          goto loop_end;
        ELSE
          FND_MESSAGE.SET_NAME('WSH','WSH_DEL_CREATE_PACK_SLIP_ERROR');
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
          l_num_warn := l_num_warn + 1;
        END IF;
      END IF;

      -- 18. if p_intransit_flag = 'Y' and autocreate trip then set the pickup stop to closed
      --   Autocreate trip if necessary (trip stuff)

      l_pickup_stop_id  := NULL ;
      l_dropoff_stop_id := NULL ;
      l_delivery_leg_id := NULL ;
      l_parent_delivery_id := NULL;
      l_trip_id    := NULL ;

      OPEN  del_legs (p_del_rows(i));
      FETCH del_legs
                   INTO l_pickup_stop_id,
                        l_dropoff_stop_id,
                        l_delivery_leg_id,
                        l_parent_delivery_id;
      CLOSE del_legs;

      -- Note that the above FETCH might miss some legs if the delivery is assigned to mult. legs!!!!!!!!

      -- K: MDC: collect the deliveries that
      -- have parent deliveries.
      -- Note that this table may not be gapless.
      IF l_parent_delivery_id IS NULL THEN

         OPEN get_consol_del(p_del_rows(i));
         FETCH get_consol_del
         INTO l_parent_delivery_id;
         CLOSE get_consol_del;

      END IF;

      IF l_parent_delivery_id IS NOT NULL THEN

         l_mdc_co_del_tab(i) := l_parent_delivery_id;

      END IF;

      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'delivery',p_del_rows(i));
        wsh_debug_sv.log(l_module_name,'l_pickup_stop_id',l_pickup_stop_id);
        wsh_debug_sv.log(l_module_name,'l_dropoff_stop_id',l_dropoff_stop_id);
        wsh_debug_sv.log(l_module_name,'l_delivery_leg_id',l_delivery_leg_id);
        wsh_debug_sv.log(l_module_name,'l_parent_delivery_id',l_parent_delivery_id);
      END IF;

       /* Bug 2313359 Trip Information is Lost */

       IF (l_pickup_stop_id IS NULL) THEN
         l_del_rows( 1 ) := p_del_rows(i);

         --Compatiblity Changes
         --for autocreatetrip if no ship method is provided do the compatibility check to see if trip can be created for the delivery else if ship method is provided, do the compatibility check before update trip call
         --bug 2811489 : call should be made regardless of ship_method being null
         IF wsh_util_core.fte_is_installed='Y' THEN

           WSH_FTE_COMP_CONSTRAINT_PKG.validate_constraint_main(
             p_api_version_number =>  1.0,
             p_init_msg_list      =>  FND_API.G_FALSE,
             p_entity_type        =>  'D',
             p_target_id          =>  l_target_trip_id,
             p_action_code        =>  'AUTOCREATE-TRIP',
             p_del_attr_tab       =>  l_cc_del_attr_tab,
             p_det_attr_tab       =>  l_cc_det_attr_tab,
             p_trip_attr_tab      =>  l_cc_trip_attr_tab,
             p_stop_attr_tab      =>  l_cc_stop_attr_tab,
             p_in_ids             =>  l_del_rows,
             x_fail_ids           =>  l_cc_fail_ids,
             x_validate_result          =>  l_cc_validate_result,
             x_failed_lines             =>  l_cc_failed_records,
             x_line_groups              =>  l_cc_line_groups,
             x_group_info               =>  l_cc_group_info,
             x_msg_count                =>  l_msg_count,
             x_msg_data                 =>  l_msg_data,
             x_return_status            =>  l_return_status);


           IF l_debug_on THEN
             wsh_debug_sv.logmsg(l_module_name,'Ship confirm with autocreatetrip and no ship method');
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
              IF l_cc_failed_records.COUNT>0 THEN

                      IF l_debug_on THEN
                          wsh_debug_sv.logmsg(l_module_name,'all lines errored in compatibility check');
                          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
                      END IF;

                      FND_MESSAGE.SET_NAME('WSH','WSH_DEL_COMP_FAILED');
                      FND_MESSAGE.SET_TOKEN('DEL_ID',wsh_new_deliveries_pvt.get_name(p_del_rows(i)));
                      x_return_status := l_return_status;
                      wsh_util_core.add_message(x_return_status);
                      goto confirm_error;
               ELSE
                      x_return_status:= WSH_UTIL_CORE.G_RET_STS_WARNING;
                      l_num_warn := l_num_warn + 1;
               END IF;
           ELSIF l_return_status=wsh_util_core.g_ret_sts_unexp_error THEN
                 x_return_status := l_return_status;
                 goto confirm_error;
           ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
               x_return_status := l_return_status;
               l_num_warn := l_num_warn + 1;
           END IF;
         END IF;
         --Compatiblity Changes

         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_ACTIONS.AUTOCREATE_TRIP',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --

         --heali :Shipment Advice change for trip Consolidation.
         IF (p_autocreate_trip_flag = 'Y' ) THEN
            wsh_trips_actions.autocreate_trip(
               p_del_rows => l_del_rows,
               x_trip_id  => l_trip_id,
               x_trip_name => l_trip_name,
               x_return_status => l_return_status,
               -- Bug 3913206
               p_sc_pickup_date => l_sc_pickup_date,
               p_sc_dropoff_date => l_sc_dropoff_date
   );

            IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS)
                     THEN
              x_return_status := l_return_status;
              FND_MESSAGE.SET_NAME('WSH','WSH_DEL_AUTOCREATE_TRIP_ERROR');

              IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;
              --
              FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_del_rows(i)));
              wsh_util_core.add_message(x_return_status);
              goto confirm_error;
            END IF;
          END IF;
       END IF;
       --heali :Shipment Advice change for trip Consolidation.


       -- Bug 2213342 : Ship Confirm Defaulting behavior
       IF l_trip_id IS NULL THEN

             --Compatibility Changes
             -- if trip already exists, need to check for must use constraints if carrier/mode is null
             IF wsh_util_core.fte_is_installed='Y' THEN
               l_trip_info_tab.delete;
               l_cc_count_success:=0;

               IF l_debug_on THEN
                   wsh_debug_sv.log(l_module_name,'HASH_TRIP count',G_HASH_TRIP.COUNT);
               END IF;

               FOR cur in Get_Trip(p_del_rows(i)) LOOP
                  b_tripalreadychecked:='N';
                  IF G_HASH_TRIP.COUNT>0 THEN
                   FOR l_count_hashtrip in G_HASH_TRIP.FIRST..G_HASH_TRIP.LAST LOOP
                    IF G_HASH_TRIP(l_count_hashtrip)=cur.trip_id THEN
                      b_tripalreadychecked:='Y';
                      IF l_debug_on THEN
                        wsh_debug_sv.log(l_module_name,'HASH_TRIP matched', cur.trip_id);
                      END IF;
                    END IF;
                   END LOOP;
                  END IF;

                  --IF (b_tripalreadychecked='N' and (cur.carrier_id is null or cur.mode_of_transport is null)) THEN
                  IF (b_tripalreadychecked='N' and
                      (cur.ship_method_code is null and (cur.carrier_id is null or cur.mode_of_transport is null))
                     ) THEN

                    IF l_debug_on THEN
                      wsh_debug_sv.log(l_module_name,'trip not already checked',cur.trip_id);
                    END IF;
                    l_cc_count_success:=l_cc_count_success+1;
                    l_trip_info_tab(l_cc_count_success).trip_id:=cur.trip_id;
                    l_trip_info_tab(l_cc_count_success).ship_method_code:=cur.ship_method_code;
                    l_trip_info_tab(l_cc_count_success).carrier_id:=cur.carrier_id;
                    l_trip_info_tab(l_cc_count_success).mode_of_transport:=cur.mode_of_transport;
                    G_HASH_TRIP(G_HASH_TRIP.COUNT+1):=cur.trip_id;
                  END IF;
               END LOOP;

               IF l_debug_on THEN
                   wsh_debug_sv.log(l_module_name,'l_trip_info_tab.COUNT : ',l_trip_info_tab.COUNT);
               END IF;


               IF l_trip_info_tab.COUNT>0 THEN

		  WSH_FTE_COMP_CONSTRAINT_PKG.validate_constraint_main(
                    p_api_version_number   =>  1.0,
                    p_init_msg_list        =>  FND_API.G_FALSE,
                    p_entity_type          =>  'T',
                    p_target_id            =>  l_target_trip_id,
                    p_action_code          =>  'UPDATE',
                    p_del_attr_tab         =>  l_cc_del_attr_tab,
                    p_det_attr_tab         =>  l_cc_det_attr_tab,
                    p_trip_attr_tab        =>  l_trip_info_tab,
                    p_stop_attr_tab        =>  l_cc_stop_attr_tab,
                    p_in_ids               =>  l_cc_in_ids,
                    x_fail_ids             =>  l_cc_fail_ids,
                    x_validate_result          =>  l_cc_validate_result,
                    x_failed_lines             =>  l_cc_failed_records,
                    x_line_groups              =>  l_cc_line_groups,
                    x_group_info               =>  l_cc_group_info,
                    x_msg_count                =>  l_msg_count,
                    x_msg_data                 =>  l_msg_data,
                    x_return_status            =>  l_return_status);

                 IF l_debug_on THEN
                   wsh_debug_sv.logmsg(l_module_name,'Ship confirm with trip already present');
                   wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_constraint_main',l_return_status);
                   wsh_debug_sv.log(l_module_name,'validate_result After Calling validate_constraint_main',l_cc_validate_result);
                   wsh_debug_sv.log(l_module_name,'msg_count After Calling validate_constraint_main',l_msg_count);
                   wsh_debug_sv.log(l_module_name,'msg_data After Calling validate_constraint_main',l_msg_data);
                   wsh_debug_sv.log(l_module_name,'fail_ids count After Calling validate_constraint_main',l_cc_fail_ids.COUNT);
                   wsh_debug_sv.log(l_module_name,'l_cc_line_groups.count count After Calling validate_constraint_main',l_cc_line_groups.COUNT);
                   wsh_debug_sv.log(l_module_name,'group_info count After Calling validate_constraint_main',l_cc_group_info.COUNT);
                   wsh_debug_sv.log(l_module_name,'HASH_TRIP trip_id',G_HASH_TRIP(1));
                 END IF;
                 --

                 IF l_return_status=wsh_util_core.g_ret_sts_error THEN
                   IF l_cc_fail_ids.COUNT>0 THEN

                      IF l_debug_on THEN
                          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit wsh_trips_pvt.get_name',WSH_DEBUG_SV.C_PROC_LEVEL);
                      END IF;

                      FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_COMP_FAILED');
                      FND_MESSAGE.SET_TOKEN('TRIP_ID',wsh_trips_pvt.get_name(l_cc_fail_ids(1)));
                      x_return_status := l_return_status;
                      wsh_util_core.add_message(x_return_status);
                      goto confirm_error;
                   ELSE
                      x_return_status:= WSH_UTIL_CORE.G_RET_STS_WARNING;
                      l_num_warn := l_num_warn + 1;
                   END IF;
                 ELSIF l_return_status=wsh_util_core.g_ret_sts_unexp_error THEN
                   x_return_status := l_return_status;
                   goto confirm_error;
                 ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                   x_return_status := l_return_status;
                   l_num_warn := l_num_warn + 1;
                 END IF;

               END IF;--for trip_tab count>0
             END IF;
             --Compatibility Changes

             -- bug 2432330: to show expected warning, code has to count deliveries with
             -- existing stops:
             -- delivery has existing trip and will not be set in transit or closed.
             l_close_confirm_flag := 'F';

	     l_with_mc_trip_flag(i)  := TRUE;


             IF p_ship_method IS NOT NULL THEN -- trip already exists...
             -- Bug 3347549 update the ship method components for
             -- the fisrt trip on the delivery.

                OPEN get_del_first_trip(p_del_rows(i));
                FETCH get_del_first_trip into l_del_first_trip;
                CLOSE get_del_first_trip;

                IF l_del_first_trip IS NULL THEN

                   FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_NOT_FOUND');
                   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                   wsh_util_core.add_message(x_return_status);
                   goto confirm_error;

                ELSE

                   l_carrier_rec.ship_method_code := p_ship_method;


                   WSH_CARRIERS_GRP.get_carrier_service_mode(
                      p_carrier_service_inout_rec => l_carrier_rec,
                      x_return_status => l_return_status);

                   IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                      goto confirm_error;
                   END IF;

                   BEGIN

                      WSH_TRIPS_PVT.lock_trip_no_compare(l_del_first_trip);

                   EXCEPTION

                      WHEN app_exception.application_exception OR app_exception.record_lock_exception THEN
                      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                      FND_MESSAGE.SET_NAME('WSH','WSH_DLVY_STOP_TRIP_LOCK');
                      FND_MESSAGE.SET_TOKEN('DLVY_NAME',wsh_new_deliveries_pvt.get_name(p_del_rows(i)));
                      wsh_util_core.add_message(x_return_status);
                      goto confirm_error;

                   END;

                   UPDATE wsh_trips
                   SET ship_method_code = p_ship_method,
                       service_level = l_carrier_rec.service_level,
                       mode_of_transport = l_carrier_rec.mode_of_transport,
                       carrier_id = l_carrier_rec.carrier_id
                   WHERE trip_id = l_del_first_trip;

                   IF (SQL%NOTFOUND) THEN
                     FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_NOT_FOUND');
                     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                     wsh_util_core.add_message(x_return_status);
                     goto confirm_error;
                   END IF;

                END IF;

             END IF;

       ELSE
         /* H integration - call MultiLeg FTE */
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
             (p_trip_id => l_trip_id,
              x_trip_rec => l_trip_rec,
              x_return_status => l_return_status);
           IF l_return_status <>WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
             x_return_status := l_return_status;
             wsh_util_core.add_message(x_return_status);
             goto confirm_error;
           END IF;

           -- this is the updated record
           l_trip_rec.ship_method_code :=
                         nvl(p_ship_method,l_trip_rec.ship_method_code);

           -- Call FTE
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

           /* H integration changes */
           IF l_return_status <>WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
             IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
               l_num_warn := l_num_warn + 1;
             ELSE
               x_return_status := l_return_status;
               wsh_util_core.add_message(x_return_status);
               goto confirm_error;
             END IF;
           END IF;
        END IF;

        /* End of H integration - call MultiLeg FTE */


         --Compatiblity Changes
         --for autocreatetrip if no ship method is provided do the compatibility check to see if trip can be created for the delivery else if ship method is provided, do the compatibility check before update trip call
         --bug 2811489 : call should be made regardless of ship_method being null
         IF wsh_util_core.fte_is_installed='Y' THEN

             --only one record
             l_trip_info_tab(1).trip_id:=l_trip_id;
             IF p_ship_method is not null THEN
                l_trip_info_tab(1).ship_method_code:=p_ship_method;
             ELSE -- ship method is not specified as an option, existing carrier, mode
                  -- have to be checked for must use constraints
                l_trip_info_tab(1).ship_method_code  :=l_trip_rec.ship_method_code;
                l_trip_info_tab(1).carrier_id        :=l_trip_rec.carrier_id;
                l_trip_info_tab(1).mode_of_transport :=l_trip_rec.mode_of_transport;
             END IF;

             WSH_FTE_COMP_CONSTRAINT_PKG.validate_constraint_main(
               p_api_version_number   =>  1.0,
               p_init_msg_list        =>  FND_API.G_FALSE,
               p_entity_type          =>  'T',
               p_target_id            =>  l_target_trip_id,
               p_action_code          =>  'UPDATE',
               p_del_attr_tab         =>  l_cc_del_attr_tab,
               p_det_attr_tab         =>  l_cc_det_attr_tab,
               p_trip_attr_tab        =>  l_trip_info_tab,
               p_stop_attr_tab        =>  l_cc_stop_attr_tab,
               p_in_ids               =>  l_cc_in_ids,
               x_fail_ids             =>  l_cc_fail_ids,
               x_validate_result          =>  l_cc_validate_result,
               x_failed_lines             =>  l_cc_failed_records,
               x_line_groups              =>  l_cc_line_groups,
               x_group_info               =>  l_cc_group_info,
               x_msg_count                =>  l_msg_count,
               x_msg_data                 =>  l_msg_data,
               x_return_status            =>  l_return_status);

           IF l_debug_on THEN
             wsh_debug_sv.logmsg(l_module_name,'Ship confirm with autocreatetrip and ship method');
             wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_constraint_main',l_return_status);
             wsh_debug_sv.log(l_module_name,'validate_result After Calling validate_constraint_main',l_cc_validate_result);
             wsh_debug_sv.log(l_module_name,'msg_count After Calling validate_constraint_main',l_msg_count);
             wsh_debug_sv.log(l_module_name,'msg_data After Calling validate_constraint_main',l_msg_data);
             wsh_debug_sv.log(l_module_name,'fail_ids count After Calling validate_constraint_main',l_cc_fail_ids.COUNT);
             wsh_debug_sv.log(l_module_name,'l_cc_line_groups.count count After Calling validate_constraint_main',l_cc_line_groups.COUNT);
             wsh_debug_sv.log(l_module_name,'group_info count After Calling validate_constraint_main',l_cc_group_info.COUNT);
           END IF;
           --

           IF l_return_status=wsh_util_core.g_ret_sts_error THEN
              IF l_cc_fail_ids.COUNT>0 THEN

                      IF l_debug_on THEN
                          wsh_debug_sv.logmsg(l_module_name,'all lines errored in compatibility check');
                          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
                      END IF;

                      FND_MESSAGE.SET_NAME('WSH','WSH_DEL_COMP_FAILED');
                      FND_MESSAGE.SET_TOKEN('DEL_ID',wsh_new_deliveries_pvt.get_name(p_del_rows(i)));
                      x_return_status := l_return_status;
                      wsh_util_core.add_message(x_return_status);
                      goto confirm_error;
               ELSE
                      x_return_status:= WSH_UTIL_CORE.G_RET_STS_WARNING;
                      l_num_warn := l_num_warn + 1;
               END IF;
           ELSIF l_return_status=wsh_util_core.g_ret_sts_unexp_error THEN
                 x_return_status := l_return_status;
                 goto confirm_error;
           ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                x_return_status := l_return_status;
               l_num_warn := l_num_warn + 1;
           END IF;
         END IF;
         --Compatiblity Changes

         -- Bug 3347549 Derive the ship method components for the trip.

         IF p_ship_method IS NOT NULL THEN

            l_carrier_rec.ship_method_code := p_ship_method;

            WSH_CARRIERS_GRP.get_carrier_service_mode(
                         p_carrier_service_inout_rec => l_carrier_rec,
                         x_return_status => l_return_status);

            IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
               x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
               goto confirm_error;
            END IF;

            UPDATE wsh_trips
            SET ship_method_code = p_ship_method,
                service_level = l_carrier_rec.service_level,
                mode_of_transport = l_carrier_rec.mode_of_transport,
                carrier_id = l_carrier_rec.carrier_id
            WHERE trip_id = l_trip_id;

            IF (SQL%NOTFOUND) THEN
              FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_NOT_FOUND');
              x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
              wsh_util_core.add_message(x_return_status);
              goto confirm_error;
            END IF;

         END IF;

       END IF;--l_trip_id is not null - autocreated trip

       IF l_debug_on THEN
          wsh_debug_sv.log(l_module_name,'p_intransit_flag', p_intransit_flag);
          wsh_debug_sv.log(l_module_name,'p_close_flag', p_close_flag);
          wsh_debug_sv.log(l_module_name,'l_itm_exc_severity', l_itm_exc_severity);
       END IF;
         /* Bug 2313359 move the code from above */
       --
       -- Bug 8555654 : Do not submit workflow for a delivery if it is going to
       --               fail as the actual departure date is outside of the current
       --               inventory open period.
       IF (l_enable_sc_wf = 'Y') THEN
       --{
           IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_organization_id',l_organization_id );
           END IF;
           IF (l_opn_prd_chk_orgs.EXISTS(l_organization_id)) THEN
           --{
               IF (l_opn_prd_chk_orgs(l_organization_id) = 1) THEN
                   l_enable_sc_wf := 'N';
               END IF;
           ELSE
               -- Check for open inventory period Error, if inventory
               -- period (corresponding to stop close date) is not open
               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INVTTMTX.TDATECHK',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               --
               invttmtx.tdatechk(l_organization_id, nvl(p_actual_dep_date,sysdate), l_period_id, l_open_past_period);
               IF (l_period_id <= 0) THEN
                   l_enable_sc_wf := 'N';
                   l_opn_prd_chk_orgs(l_organization_id) := 1;
               ELSE
                   l_opn_prd_chk_orgs(l_organization_id) := 0;
               END IF;
           --}
           END IF;
           IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_enable_sc_wf',l_enable_sc_wf);
           END IF;
       --}
       END IF;
       -- Bug 8555654 : : End
       --
       IF ((p_intransit_flag = 'Y'  OR p_close_flag = 'Y') AND (l_enable_sc_wf <> 'Y') )  THEN
           -- Now that the trip is created , fetch the delivery's  pickup_stop_id again.
           -- We do this only if severity 'ERROR', 'WARNING' ITM exceptions will not be
           -- logged against this delivery, as the stops attached to deliveries with
           -- 'ERROR', 'WARNING' ITM exceptions will not get closed.
           -- l_enable_sc_wf <> 'Y' - Workflow Changes

           OPEN  del_legs (p_del_rows(i));
           FETCH del_legs INTO l_pickup_stop_id,
                            l_dropoff_stop_id, l_delivery_leg_id,
                            l_parent_delivery_id;
           CLOSE del_legs;

           IF (l_itm_exc_severity IN ('ERROR', 'WARNING')) THEN

               l_itm_stops_tab(l_pickup_stop_id) := 'Y';
               l_itm_stops_tab(l_dropoff_stop_id) := 'Y';

               l_close_confirm_flag := 'F';

               FND_MESSAGE.SET_NAME('WSH','WSH_EXP_COMPL_SCRN_REQD');
               FND_MESSAGE.SET_TOKEN('DEL_NAME',l_delivery_name);
               wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_SUCCESS);

           ELSE

               l_stop_rows(l_stop_rows.count + 1 ) := l_pickup_stop_id;
               --u_stop_rows(u_stop_rows.count + 1 ) := l_pickup_stop_id;

               -- 19. if p_close_flag = 'Y' and autocreate trip close the drop off stop
               IF (p_close_flag = 'Y') THEN
                 l_stop_rows(l_stop_rows.count + 1 ) := l_dropoff_stop_id;
               --  u_stop_rows(u_stop_rows.count + 1 ) := l_dropoff_stop_id;
               END IF;

	       --bug 3314353  -- jckwok
	       OPEN get_del_first_trip(p_del_rows(i));
	       FETCH get_del_first_trip into l_first_trip_id;
	       CLOSE get_del_first_trip;
	       IF l_first_trip_id IS NULL THEN
		  FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_NOT_FOUND');
		  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		  wsh_util_core.add_message(x_return_status);
		  goto confirm_error;
	       END IF;
	       OPEN stop_sequence_number_csr(l_pickup_stop_id);
	       FETCH stop_sequence_number_csr INTO l_pick_up_stop_sequence_num;
               IF stop_sequence_number_csr%NOTFOUND THEN
                  CLOSE stop_sequence_number_csr;
                  RAISE NO_DATA_FOUND;
               END IF;
	       CLOSE stop_sequence_number_csr;

	       IF ((p_close_flag = 'Y') AND (p_intransit_flag = 'Y')) THEN
	         --{ bugfix 3925963
   	         l_inbound_stops_exists := false;
		 l_stop_name_list  := null;
	         OPEN get_stops_csr(l_first_trip_id);
	         LOOP
	           FETCH get_stops_csr INTO l_prev_stop_id,l_shipments_type_flag,l_stop_location_id;
                   exit when get_stops_csr%NOTFOUND;
                   IF nvl(l_shipments_type_flag,'O') = 'I'  THEN
		      l_inbound_stops_exists := true;
		      l_stop_name            := SUBSTRB(
                                                         WSH_UTIL_CORE.get_location_description
                                                          ( l_stop_location_id,
                                                            'NEW UI CODE'
                                                           ),
                                                          1,
                                                          60
                                                        );
		      IF l_stop_name_list is null THEN
                         l_stop_name_list := l_stop_name;
		      ELSE
                         l_stop_name_list := l_stop_name_list || ' , ' || l_stop_name;
		      END IF;
                   ELSE
   	             u_stop_rows(u_stop_rows.count+1) := l_prev_stop_id;
                   END IF;
		   --
	         END LOOP;
                 CLOSE get_stops_csr;
		 IF l_inbound_stops_exists THEN
                    OPEN get_trip_name_csr (l_first_trip_id);
		    FETCH get_trip_name_csr INTO l_stops_trip_name;
		    CLOSE get_trip_name_csr;
                    FND_MESSAGE.SET_NAME('WSH','WSH_PREV_IB_STOPS_NOT_CLOSED');
		    FND_MESSAGE.SET_TOKEN('TRIP_NAME', l_stops_trip_name);
		    FND_MESSAGE.SET_TOKEN('STOP_NAME_LIST', l_stop_name_list);
		    x_return_status :=  WSH_UTIL_CORE.G_RET_STS_WARNING;
                    wsh_util_core.add_message(x_return_status);
		 END IF;
		 --} bugfix 3925963
	       ELSIF ((p_close_flag = 'N') AND (p_intransit_flag = 'Y')) THEN
	         OPEN prev_stop_csr(l_first_trip_id, l_pick_up_stop_sequence_num);
	         LOOP
	           FETCH prev_stop_csr INTO l_prev_stop_id;
                   exit when prev_stop_csr%NOTFOUND;
	           u_stop_rows(u_stop_rows.count+1) := l_prev_stop_id;
	         END LOOP;
                 CLOSE prev_stop_csr;
                 u_stop_rows(u_stop_rows.count + 1 ) := l_pickup_stop_id;
               END IF;
	       --bug 3314353  -- jckwok

               l_close_confirm_flag := 'C';

           END IF;

       ELSE

           l_close_confirm_flag := 'F';

       END IF; -- end of p_in_transit_flag = Y

     END IF; -- end of IF (NOT l_unassign_all_flag_tab(i))

    IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_close_confirm_flag',l_close_confirm_flag );
    END IF;

    --set the close/confirm count accordingly
    IF(l_close_confirm_flag = 'C') THEN
      l_close_del_cnt := l_close_del_cnt +1;
    ELSIF(l_close_confirm_flag = 'F') THEN
      l_confirm_del_cnt := l_confirm_del_cnt +1;
    END IF;

    l_close_confirm_flag:=NULL;


     -- Set delivery status to confirm, set initial pickup date, ultimate dropoff date

     -- If all delivery_details from a delivery are being unassigned then set status to CLOSED
     -- ,unassign delivery from all trips it might be on and set a warning message

    IF l_unassign_all_flag_tab(i) THEN
        l_status_code(i) := 'CL';

        /* H integration: 940/945 WSH wrudge */
        -- we should get warning only if user doesn't expect to do unassign all.
        IF p_action_flag NOT IN ('C', 'O')  AND l_unassign_dds.count > 0 THEN

          FND_MESSAGE.SET_NAME('WSH','WSH_DEL_CONFIRM_UNASSIGN_ALL');
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
          WSH_NEW_DELIVERY_ACTIONS.g_error_level := 'E';
          l_num_warn := l_num_warn + 1;
        END IF;

        l_mdc_index_i := 0;
        FOR dg IN del_legs(p_del_rows(i)) LOOP
          --
          -- Debug Statements
          --
          --
          -- K: MDC Remove the delivery from the consol delivery and trip.
          IF dg.parent_delivery_id IS NOT NULL THEN
             l_mdc_cl_del_tab(1) := p_del_rows(i);
             l_mdc_co_del_tab.delete(i);
             WSH_NEW_DELIVERY_ACTIONS.Unassign_Dels_from_Consol_Del(
                       p_parent_del     => NULL,
                       p_caller         => p_caller,
                       p_del_tab        => l_mdc_cl_del_tab,
                       x_return_status  => l_return_status);
             l_mdc_cl_del_tab.delete;
             IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
               IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
                   l_num_warn := l_num_warn + 1;
               ELSE
                   x_return_status := l_return_status;
                   goto confirm_error;
               END IF;
             END IF;
          END IF;
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_LEGS_PVT.DELETE_DELIVERY_LEG',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          wsh_delivery_legs_pvt.delete_delivery_leg
                       (NULL, dg.delivery_leg_id, l_return_status);
          IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            --Bug 2108310
              IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
                l_num_warn := l_num_warn + 1;
              ELSE
                x_return_status := l_return_status;
                goto confirm_error;
              END IF;
            --Bug 2108310
          END IF;

       END LOOP;
     ELSE
      l_status_code(i) := 'CO';
     END IF;


    -- LASTLY,  populated the delivery columns  for bulk update

    u_del_rows( u_del_rows.count + 1)       := p_del_rows (i);
    u_status_code( u_del_rows.count )      := l_status_code(i);
    u_number_of_lpn( u_del_rows.count )    := l_number_of_lpn(i) ;
    u_initial_pickup_date(  u_del_rows.count )   := l_initial_pickup_date(i);
    u_ultimate_dropoff_date(  u_del_rows.count ) := l_ultimate_dropoff_date(i);
    /* H integration: 945 send document wrudge */
    u_organization_id( u_del_rows.count )   := l_organization_id;
    u_wsh_lines_exist( u_del_rows.count )   := l_wsh_lines_exist;
    --/==Workflow Changes
    IF (l_enable_sc_wf = 'Y') THEN
        l_scpod_wf_del_rows(l_scpod_wf_del_rows.count + 1) := u_del_rows.count;
    END IF;
    --==/

     goto loop_end;

     <<confirm_error>>

     FND_MESSAGE.SET_NAME('WSH','WSH_DEL_CONFIRM_ERROR');
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_del_rows(i)));
     wsh_util_core.add_message(x_return_status);

     /* H integration: 940/945 wrudge */
     <<confirm_error_no_msg>>
     ROLLBACK TO SAVEPOINT confirm_delivery_sp;
     l_num_error := l_num_error + 1;

     <<loop_end>>
     null;

     l_error_exists := FALSE;

/* Bug 2761304: Changed the following conditon from '=' to '>='. */

     IF (l_num_error >= 0) AND (l_wms_enabled_flag) THEN
       -- Bug 2942938: select all the 'W' message type from WSH_INTEGRATION.G_MSG_TABLE
		 -- also select hold 'E' messages for WMS org, since hold errors
                 -- bug 3455640 added 'WSH_INVALID_CATCHWEIGHT'
		 -- should prevent the delivery from being ship confirmed, not just unassign
       -- the delivery details
       l_count := 0;
       FOR i in 1..WSH_INTEGRATION.G_MSG_TABLE.COUNT LOOP
         IF ( WSH_INTEGRATION.G_MSG_TABLE(i).MESSAGE_TYPE = 'W' )  OR
            ( WSH_INTEGRATION.G_MSG_TABLE(i).MESSAGE_NAME in (
                   'WSH_HEADER_HOLD_ERROR',
                   'WSH_SHIP_LINE_HOLD_ERROR',
                   'WSH_DET_CREDIT_HOLD_ERROR',
                   'WSH_INVALID_CATCHWEIGHT') ) THEN
           l_count := l_count + 1;
           l_msg_table(l_count) := WSH_INTEGRATION.G_MSG_TABLE(i);
           IF l_debug_on THEN
			     WSH_DEBUG_SV.logmsg(l_module_name,'Msg '||i||' : '||WSH_INTEGRATION.G_MSG_TABLE(i).MESSAGE_TYPE||' '||WSH_INTEGRATION.G_MSG_TABLE(i).MESSAGE_NAME,WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
         END IF;
       END LOOP;
       -- Call WMS api to process the table of l_msg_table only for wms enabled org
       -- WMS: pass warnings to WMS for processing:
       WMS_SHIPPING_MESSAGES.PROCESS_SHIPPING_WARNING_MSGS(x_return_status  => l_return_status ,
                                                        x_msg_count      => l_msg_count ,
                                                        x_msg_data       => l_msg_data,
                                                        p_commit         => FND_API.g_false,
                                                        x_shipping_msg_tab  => l_msg_table);

       -- Check if there exists an 'E' message in the l_msg_table
       -- If there is then turn the message type to 'E' for the particular message name in
       -- WSH_INTEGRATION.G_MSG_TABLE
       FOR i in 1..l_msg_table.count LOOP
         IF ( l_msg_table(i).MESSAGE_TYPE = 'E' ) THEN
           l_error_exists := TRUE;
           FOR j in 1..WSH_INTEGRATION.G_MSG_TABLE.COUNT LOOP
             IF (l_msg_table(i).message_name = WSH_INTEGRATION.G_MSG_TABLE(j).MESSAGE_NAME) THEN
               WSH_INTEGRATION.G_MSG_TABLE(j).MESSAGE_TYPE := 'E';
             END IF;
           END LOOP;
         END IF;
       END LOOP;
       l_msg_table.delete;
     END IF;
     -- Call Store_Msg_In_Table Api to push the messages in WSH_INTEGRATION.G_MSG_TABLE to fnd stack
     WSH_UTIL_CORE.Store_Msg_In_Table (p_store_flag => FALSE,
                                       x_msg_rec_count => l_msg_rec_count,
                                       x_return_status => l_return_status);
     IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
       raise ship_confirm_error;
     END IF;
     -- If there is no Shipping error but WMS has turned one of the Warning to Error then set the l_num_error
     IF ( (l_num_error = 0) AND (l_error_exists) )THEN
       l_num_error := nvl(l_msg_rec_count.e_count,0) + nvl(l_msg_rec_count.u_count,0);
     END IF;

  end loop ;

  --delete the hash trip_ids stored
  G_HASH_TRIP.delete;

  -- Bug 2074768 : Check for tolerances now that all the delivery lines for all the deliveries have been updated.
  -- The need to check tolerances here arises because now we have all the deliveries that really will
  -- be ship confirmed.
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'p_del_rows count', p_del_rows.count);
  END IF;

  FOR i IN 1..p_del_rows.count LOOP

    -- HW OPM added l_max_quantity2
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_VALIDATIONS.CHECK_DELIVERY_FOR_TOLERANCES',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    wsh_Delivery_validations.check_delivery_for_tolerances (
      p_delivery_id => p_del_rows(i) ,
      x_source_line_id  => l_temp_line_id ,
      x_source_code  => l_temp_source_code ,
      x_max_quantity  => l_max_quantity ,
      x_max_quantity2   => l_max_quantity2 ,
      x_return_status   => l_return_status  ) ;

    if ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS  ) then
      x_return_status := l_return_Status ;
      wsh_util_core.add_message(x_return_status);
      l_num_error := l_num_error + 1;
      l_delivery_id := p_del_rows(i);
      raise ship_confirm_error ;
    end if ;

	-- Close Exceptions for the Delivery
	IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_XC_UTIL.Close_Exceptions',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    WSH_XC_UTIL.Close_Exceptions (
                                     p_api_version           => 1.0,
                                     x_return_status         => l_return_status,
                                     x_msg_count             => l_msg_count,
                                     x_msg_data              => l_msg_data,
                                     p_logging_entity_id     => p_del_rows(i),
                                     p_logging_entity_name   => 'DELIVERY',
                                     p_consider_content      => 'Y'
                                  ) ;

    IF ( l_return_status <>  WSH_UTIL_CORE.G_RET_STS_SUCCESS )  THEN
         x_return_status := l_return_status;
         wsh_util_core.add_message(x_return_status);
         IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
              l_num_error := l_num_error + 1 ;
              l_delivery_id := p_del_rows(i);
              raise ship_confirm_error;
         ELSE
              l_num_warn := l_num_warn + 1 ;
         END IF;
    END IF;



  END LOOP ;

  -- Create trip from deconsol location to ultimate drop off
  -- consol deliveriers.
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_mdc_co_del_tab count', l_mdc_co_del_tab.count);
  END IF;

  IF l_mdc_co_del_tab.count > 0 THEN

     Create_Deconsol_Trips(p_deliveries_tab => u_del_rows,
                           x_return_status => l_return_status);

     IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
        raise ship_confirm_error;
     ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
           l_num_warn := l_num_warn + 1;
     END IF;


  END IF;

  -- 19.55 Generate BOL if p_bol_flag is set
  -- 2121399
  -- Moved Create_Bol and Print_document_sets APIs outside the main For Loop and
  -- and placed it after the call to Check_Delivery_for_tolerances is made.
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'u_del_rows count', u_del_rows.count);
  END IF;

  FOR i IN 1..u_del_rows.count LOOP

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'i', i);
      WSH_DEBUG_SV.log(l_module_name,'l_with_mc_trip_flag count', l_with_mc_trip_flag.count);
      WSH_DEBUG_SV.log(l_module_name,'l_unassign_all_flag_tab count', l_unassign_all_flag_tab.count);
      WSH_DEBUG_SV.log(l_module_name,'u_status_code count', u_status_code.count);
      WSH_DEBUG_SV.log(l_module_name,'u_del_rows i', u_del_rows(i));
    END IF;

    OPEN  del_legs (u_del_rows(i));
    FETCH del_legs INTO l_pickup_stop_id, l_dropoff_stop_id, l_delivery_leg_id, l_parent_delivery_id;
    CLOSE del_legs;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_pickup_stop_id', l_pickup_stop_id);
      WSH_DEBUG_SV.log(l_module_name,'l_dropoff_stop_id', l_dropoff_stop_id);
      WSH_DEBUG_SV.log(l_module_name,'l_delivery_leg_id', l_delivery_leg_id);
      WSH_DEBUG_SV.log(l_module_name,'l_parent_delivery_id', l_parent_delivery_id);
    END IF;

     --Bug 5255366 (The above cursor can fetch parent-del-id of newly created trip hence can be null)
     --            (Hence the second fetch is required)
     IF l_parent_delivery_id IS NULL THEN

       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'p_del_rows i', p_del_rows(i));
       END IF;

         OPEN get_consol_del(p_del_rows(i));
         FETCH get_consol_del
         INTO l_parent_delivery_id;
         CLOSE get_consol_del;
     END IF;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_parent_delivery_id', l_parent_delivery_id);
    END IF;

    --Bug 3685366
    l_dummy_doc_set(1).bol_error_flag:='N';
    --

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'p_bol_flag', p_bol_flag);
      WSH_DEBUG_SV.log(l_module_name,'l_with_mc_trip_flag', l_with_mc_trip_flag(i));
      WSH_DEBUG_SV.log(l_module_name,'l_unassign_all_flag_tab', l_unassign_all_flag_tab(i));
      WSH_DEBUG_SV.log(l_module_name,'p_mc_bol_flag', p_mc_bol_flag);
    END IF;

    IF ((p_bol_flag ='Y') AND (NOT l_with_mc_trip_flag(i)) AND (NOT l_unassign_all_flag_tab(i)) AND (l_pickup_stop_id IS NOT NULL)) THEN

      --Bug 5255366
      IF l_parent_delivery_id IS NOT NULL THEN
         create_bol( p_delivery_id  => l_parent_delivery_id,
         x_return_status  =>    l_return_status);
      ELSE
         create_bol( p_delivery_id  => u_del_rows(i),
         x_return_status  =>    l_return_status);
      END IF;

       IF (l_return_status NOT IN (WSH_UTIL_CORE.G_RET_STS_SUCCESS,WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN

	IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
           l_num_error := l_num_error + 1;
        ELSE
     	   --Bug 3685366
	   l_dummy_doc_set(1).bol_error_flag:='Y';
	   --
	   FND_MESSAGE.SET_NAME('WSH','WSH_DEL_CREATE_BOL_ERROR');
           --
           -- Debug Statements
           --
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           --

	   FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(u_del_rows(i)));
           x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
           wsh_util_core.add_message(x_return_status);
           l_num_warn := l_num_warn + 1;
        END IF;
       END IF;

     ELSIF ((p_mc_bol_flag ='Y') AND l_with_mc_trip_flag(i) AND (NOT l_unassign_all_flag_tab(i)) AND (l_pickup_stop_id IS NOT NULL)) THEN

       --Bug 5255366
       IF l_parent_delivery_id IS NOT NULL THEN
          create_bol( p_delivery_id  => l_parent_delivery_id,
          x_return_status  =>    l_return_status);
       ELSE
          create_bol( p_delivery_id  => u_del_rows(i),
          x_return_status  =>    l_return_status);
       END IF;

       IF (l_return_status NOT IN (WSH_UTIL_CORE.G_RET_STS_SUCCESS,WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN

	IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
           l_num_error := l_num_error + 1;
        ELSE

	   -- Bug 3685366
	     l_dummy_doc_set(1).bol_error_flag:='Y';
	   --

	   FND_MESSAGE.SET_NAME('WSH','WSH_DEL_CREATE_BOL_ERROR');
           --
           -- Debug Statements
           --

	   IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           --
           FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(u_del_rows(i)));
           x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
           wsh_util_core.add_message(x_return_status);
           l_num_warn := l_num_warn + 1;
        END IF;
       END IF;

    END IF;

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'print doc set');
    END IF;

     --19.6. Print document set if p_report_set_id is specified

    IF (l_document_set_id IS NOT NULL) AND (NOT l_unassign_all_flag_tab(i)) THEN

       l_del_tmp_rows.delete;
       --Bug 5255366
       IF l_parent_delivery_id IS NOT NULL THEN
          l_del_tmp_rows(1) := l_parent_delivery_id;
       ELSE
          l_del_tmp_rows(1) := u_del_rows(i);
       END IF;

       -- Start of bugfix 4493263
       OPEN c_delv_trip_id_cursor(l_del_tmp_rows(1));
       LOOP
           FETCH c_delv_trip_id_cursor INTO l_dummy_doc_set(1).p_trip_id;
           EXIT WHEN c_delv_trip_id_cursor%NOTFOUND;
           --
           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name, 'Trip Id : ', l_dummy_doc_set(1).p_trip_id );
           END IF;
           --
       END LOOP;
       CLOSE c_delv_trip_id_cursor;
       -- End of bugfix 4493263
       --
       -- Debug Statements
       --
       IF(l_parent_delivery_id IS NOT NULL) THEN
	IF (l_consol_del_doc_set.COUNT >0 AND(l_consol_del_doc_set.EXISTS(l_parent_delivery_id)))  THEN
          l_content_del_flag := FALSE;
        END IF;
       END IF;
       IF l_content_del_flag THEN
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DOCUMENT_SETS.PRINT_DOCUMENT_SETS',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
       --
       wsh_document_sets.print_document_sets(
               p_report_set_id     =>   l_document_set_id ,
               p_organization_id     =>   NULL,
               p_trip_ids       =>    l_dummy_rows1,
               p_stop_ids       =>    l_dummy_rows1,
               p_delivery_ids     =>    l_del_tmp_rows,
               p_document_param_info   =>   l_dummy_doc_set,
               x_return_status     =>   l_return_status);

       IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
           l_num_error := l_num_error + 1;
          ELSE
           FND_MESSAGE.SET_NAME('WSH','WSH_DEL_DOC_SUB_ERROR');
           --
           -- Debug Statements
           --
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           --
           FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(u_del_rows(i)));
           x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
           wsh_util_core.add_message(x_return_status);
           l_num_warn := l_num_warn + 1;
          END IF;
       END IF;
      END IF;
    END IF;

 --Bug 5255366 (Storing Consol-del-Id in a tab so that multiple Doc set firing is avoided)
    IF l_parent_delivery_id IS NOT NULL THEN
       IF (NOT l_consol_del_doc_set.EXISTS(l_parent_delivery_id)) THEN
	  l_consol_del_doc_set(l_parent_delivery_id) := l_parent_delivery_id;
       END IF;
    END IF;
     --J TP Release : If TP is installed, confirmed delivery has to be planned
    --tkt
    IF (NOT l_unassign_all_flag_tab(i) and wsh_util_core.TP_IS_INSTALLED='Y') THEN

       l_del_tmp_rows.delete;
       l_del_tmp_rows(1) := u_del_rows(i);

       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit PLAN',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;

       PLAN(p_del_rows      => l_del_tmp_rows,
             x_return_status => l_return_status,
             p_called_for_sc => TRUE);

       IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
          IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR,WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
           l_num_error := l_num_error + 1;
          ELSE
             IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;
             FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(u_del_rows(i)));
             x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
             wsh_util_core.add_message(x_return_status);
             l_num_warn := l_num_warn + 1;
          END IF;
       END IF;

    END IF;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_itm_exc_flag count', l_itm_exc_flag.count);
    END IF;
    --Bug 9326608 Changed l_itm_exc_flag to use i as index
    IF l_itm_exc_flag(i) = 'Y' THEN

        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_VALIDATIONS.Log_ITM_Exception',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        WSH_DELIVERY_VALIDATIONS.Log_ITM_Exception
                                  (p_delivery_id => u_del_rows(i),
                                   p_action_type => 'SHIP_CONFIRM',
                                   p_ship_from_location_id =>  l_ship_from_location,
                                   x_return_status => l_return_status);

        IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
              l_num_error := l_num_error + 1 ;
              l_delivery_id := u_del_rows(i);
              raise ship_confirm_error;
        ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
              l_num_warn := l_num_warn + 1;
        END IF;

    END IF;

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERY_ACTIONS.UPDATE_LEG_SEQUENCE',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    wsh_new_delivery_actions.update_leg_sequence(
      p_delivery_id => u_del_rows(i),
      x_return_status => l_return_status);

    IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
       l_num_error := l_num_error + 1 ;
       l_delivery_id := u_del_rows(i);
       raise ship_confirm_error;
    ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
       l_num_warn := l_num_warn + 1;
    END IF;



  END LOOP ; ---key loop





  --/== Workflow Changes
  IF (p_intransit_flag = 'N') THEN
	l_defer_interface_flag := 'Y';
  ELSE
	l_defer_interface_flag :=  p_defer_interface_flag;
  END IF;
  --==/

  -- 2121399

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'u_number_of_lpn count', l_with_mc_trip_flag.count);
    WSH_DEBUG_SV.log(l_module_name,'u_initial_pickup_date count', u_initial_pickup_date.count);
    WSH_DEBUG_SV.log(l_module_name,'u_ultimate_dropoff_date count', u_ultimate_dropoff_date.count);
    WSH_DEBUG_SV.log(l_module_name,'u_status_code count', u_status_code.count);
  END IF;

  -- BULK UPDATE  FOR ALL DELIVERIES IN p_del_rows

  -- Update the delivery record with status code and confirm date
  -- 2052673  - modified the way in which the number_of_lpn is being updated.
        -- 2335270  included last_updated_by and last_update_login
  FORALL i IN 1..u_del_rows.count
    UPDATE wsh_new_deliveries
    SET status_code = u_status_code(i),
      confirm_date = sysdate,
    confirmed_by = nvl(confirmed_by, l_user_name),
      -- number_of_lpn = decode(u_number_of_lpn(i),0,null,u_number_of_lpn(i)) , --Bug 1729723
    number_of_lpn = decode(number_of_lpn, null, decode(u_number_of_lpn(i),0,null,u_number_of_lpn(i)), number_of_lpn),
    initial_pickup_date = u_initial_pickup_date(i) ,
    ultimate_dropoff_date = u_ultimate_dropoff_date(i) ,
    --OTM R12, when setting delivery to closed, set the tms flag
    TMS_INTERFACE_FLAG = DECODE(l_gc3_is_installed,
                                'Y', DECODE(NVL(u_status_code(i), 'XXXXX'),
                                            'CL', DECODE(NVL(tms_interface_flag,
                                                             WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT),
                                                         WSH_NEW_DELIVERIES_PVT.C_TMS_DELETE_REQUIRED,
                                                         WSH_NEW_DELIVERIES_PVT.C_TMS_DELETE_REQUIRED,
                                                         WSH_NEW_DELIVERIES_PVT.C_TMS_DELETE_IN_PROCESS,
                                                         WSH_NEW_DELIVERIES_PVT.C_TMS_DELETE_IN_PROCESS,
                                                         WSH_NEW_DELIVERIES_PVT.C_TMS_COMPLETED),
                                            NVL(tms_interface_flag,
                                                WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT)),
                                NVL(tms_interface_flag,
                                    WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT)),
    --END OTM R12
    last_update_date    = SYSDATE  ,
    last_updated_by    = l_user_id,
    last_update_login  = l_login_id,
    --/==Workflow Changes
    del_wf_intransit_attr = decode(p_intransit_flag,'Y','I','X'),
    del_wf_close_attr = decode(p_close_flag,'Y','I','X'),
    del_wf_interface_attr = decode(l_defer_interface_flag,'N','I','X')
    --==/
    WHERE  delivery_id = u_del_rows(i);

    IF l_mdc_co_del_tab.count > 0 THEN

        Confirm_Consolidation_Delivery(
             p_consol_del_tab   => l_mdc_co_del_tab,
             x_return_status    => l_return_status);

        IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
              raise ship_confirm_error;
        ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
              l_num_warn := l_num_warn + 1;
        END IF;

    END IF;


    --/== Workflow Changes - Controlling Workflow
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'L_ENABLE_SC_WF',l_enable_sc_wf);
        WSH_DEBUG_SV.log(l_module_name,'Controlling-scpod rows count',l_scpod_wf_del_rows.count);
    END IF;
    FOR k IN 1..l_scpod_wf_del_rows.count LOOP
        l_ctr := l_scpod_wf_del_rows(k);
	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.START_SCPOD_C_PROCESS',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

        WSH_WF_STD.Start_Scpod_C_Process( p_entity_id => u_del_rows(l_ctr),
                                          p_organization_id => u_organization_id(l_ctr),
                                          x_process_started => l_process_started,
                                          x_return_status => l_return_status);
	IF l_debug_on THEN
	    WSH_DEBUG_SV.log(l_module_name,'L_PROCESS_STARTED',l_process_started);
	    WSH_DEBUG_SV.log(l_module_name,'L_RETURN_STATUS',l_return_status);
	END IF;

        IF (l_process_started = 'Y' OR l_process_started = 'E')	THEN
		l_aname_text(l_aname_text.COUNT + 1) := 'INTRANSIT_FLAG';
		l_avalue_text(l_avalue_text.COUNT + 1) := P_INTRANSIT_FLAG;
		l_aname_text(l_aname_text.COUNT + 1) := 'ACTION_FLAG';
		l_avalue_text(l_avalue_text.COUNT + 1) := P_ACTION_FLAG;
		l_aname_text(l_aname_text.COUNT + 1) := 'CLOSE_TRIP_FLAG';
		l_avalue_text(l_avalue_text.COUNT + 1) := P_CLOSE_FLAG;
		l_aname_text(l_aname_text.COUNT + 1) := 'STAGE_DEL_FLAG';
		l_avalue_text(l_avalue_text.COUNT + 1) := P_STAGE_DEL_FLAG;
		l_aname_text(l_aname_text.COUNT + 1) := 'SEND_945_FLAG';
		l_avalue_text(l_avalue_text.COUNT + 1) := P_SEND_945_FLAG;
		l_aname_text(l_aname_text.COUNT + 1) := 'CREATE_BOL_FLAG';
		l_avalue_text(l_avalue_text.COUNT + 1) := P_BOL_FLAG;
		l_aname_text(l_aname_text.COUNT + 1) := 'CREATE_MC_BOL_FLAG';
		l_avalue_text(l_avalue_text.COUNT + 1) := P_MC_BOL_FLAG;
		l_aname_text(l_aname_text.COUNT + 1) := 'SHIP_METHOD_CODE';
		l_avalue_text(l_avalue_text.COUNT + 1) := p_ship_method;
		l_aname_text(l_aname_text.COUNT + 1) := 'DEFER_INTERFACE_FLAG';
   		l_avalue_text(l_avalue_text.COUNT + 1) := l_defer_interface_flag;


		WF_ENGINE.SetItemAttrTextArray(
			itemtype => 'WSHDEL',
			itemkey  => u_del_rows(l_ctr),
			aname    => l_aname_text,
			avalue   => l_avalue_text);

		l_aname_num(l_aname_num.COUNT + 1) := 'REPORT_SET_ID';
		l_avalue_num(l_avalue_num.COUNT + 1) := P_REPORT_SET_ID;

		WF_ENGINE.SetItemAttrNumberArray(
			itemtype => 'WSHDEL',
			itemkey  => u_del_rows(l_ctr),
			aname    => l_aname_num,
			avalue   => l_avalue_num);

		WF_ENGINE.SetItemAttrDate(
			itemtype => 'WSHDEL',
			itemkey => u_del_rows(l_ctr),
			aname => 'ACTUAL_DATE',
			avalue => P_ACTUAL_DEP_DATE);

          FND_MESSAGE.SET_NAME('WSH','WSH_WF_SCPOD_LAUNCHED');
          FND_MESSAGE.Set_Token('DEL_NAME',wsh_new_deliveries_pvt.get_name(u_del_rows(l_ctr)));
          wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_SUCCESS,l_module_name);

	END IF;
    END LOOP;
    -- Workflow Changes ==/

    FOR z IN 1..u_del_rows.count LOOP
    	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.Raise_Event',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

        WSH_WF_STD.Raise_Event(
                p_entity_type => 'DELIVERY',
                p_entity_id   => u_del_rows(z),
                p_event       => 'oracle.apps.wsh.delivery.gen.shipconfirmed',
                p_organization_id => u_organization_id(z),
                x_return_status   => l_wf_rs);
	IF l_debug_on THEN
	    WSH_DEBUG_SV.log(l_module_name,'L_WF_RS',l_wf_rs);
	END IF;

    END LOOP;

  /* H integration: 945 send document  wrudge */
  -- Send outbound documents if enabled and deliveries have WSH lines.
  IF p_send_945_flag = 'Y' THEN

    FOR i IN 1..u_del_rows.count LOOP
      IF u_wsh_lines_exist(i) > 0 THEN
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRANSACTIONS_UTIL.SEND_DOCUMENT',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_transactions_util.send_document(
        p_entity_id    => u_del_rows(i),
        p_entity_type  => 'DLVY',
        p_action_type  => 'A',
        p_document_type   => 'SA',
        p_organization_id => u_organization_id(i),
        x_return_status  => l_return_status);
        IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
            l_num_error := l_num_error + 1;
          ELSE
            /* new message: WSH_DEL_OUTBOUND_FAILED, token DEL_NAME */
            FND_MESSAGE.SET_NAME('WSH','WSH_DEL_OUTBOUND_FAILED');
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
            l_num_warn := l_num_warn + 1;
          END IF;
        END IF;
      END IF;  -- u_wsh_lines_exist(i) > 0
    END LOOP;

  END IF; -- p_send_945_flag = 'Y'



    -- Remove stops that have deliveries with ITM exceptions logged
    -- against them from the table of stops to be closed.

    if u_stop_rows.count > 0 then

       FOR i IN u_stop_rows.FIRST .. u_stop_rows.LAST LOOP

           IF l_itm_stops_tab.exists(u_stop_rows(i)) THEN

              u_stop_rows.delete(i);

           END IF;

       END LOOP;

    END IF;

    -- Close the Autocreated Trip-Stops

    if u_stop_rows.count > 0 then

       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_ACTIONS.CHANGE_STATUS',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       --
       wsh_trip_stops_actions.change_status(
            p_stop_rows => u_stop_rows,
            p_action  => 'CLOSE',
            p_actual_date => nvl(p_actual_dep_date,sysdate),
            p_defer_interface_flag => p_defer_interface_flag,   -- bug 1578251
            x_return_status => l_return_status,
--tkt
            p_caller => p_caller);

       IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
        x_return_status := l_return_status;
        IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
          l_num_warn := l_num_warn + 1;
        ELSE
          l_num_error := l_num_error + 1;
        END IF;
       END IF;

    End if ;

    -- LPN CONV rv
    -- Need to delete all the WMS LPNs that were unassigned and unpacked during Ship Confirm
    --
    IF (l_wms_enabled_flag) THEN
    --{
        for l_delete_cnt_rec in l_delete_wms_empty_cnt_csr loop
        --{
            --
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_ACTIONS.DELETE_CONTAINERS',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            wsh_container_actions.delete_containers (
              p_container_id  => l_delete_cnt_rec.delivery_detail_id,
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
              p_return_status => l_return_status,
              x_num_warnings  => l_num_error,
              x_num_errors    => l_num_warn,
              p_raise_error_flag => FALSE);
            --
        --}
        end loop;
    --}
    END IF;

   -- 20. set summary messages for warnings and errors

  IF (l_num_error > 0) THEN
     FND_MESSAGE.SET_NAME('WSH','WSH_DEL_CONFIRM_WARNING');
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     wsh_util_core.add_message(x_return_status);
     rollback to savepoint start_ship_confirm_delivery;

  ELSE

    -- Set Message as Number of Deliveries as Confirmed, In-Transit and Closed
    IF ( l_close_del_cnt <> 0 ) THEN

       FND_MESSAGE.SET_NAME('WSH','WSH_CL_DELIVERIES');
       FND_MESSAGE.SET_TOKEN('CL_DEL',l_close_del_cnt);
       wsh_util_core.add_message(x_return_status);

    END IF;

    IF  (l_confirm_del_cnt <> 0) THEN

       FND_MESSAGE.SET_NAME('WSH','WSH_CO_DELIVERIES');
       FND_MESSAGE.SET_TOKEN('CO_DEL',l_confirm_del_cnt);
       wsh_util_core.add_message(x_return_status);

    END IF;

    if (l_num_warn > 0) THEN
     FND_MESSAGE.SET_NAME('WSH','WSH_DEL_CONFIRM_WARNING');
     x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
     wsh_util_core.add_message(x_return_status);
    elsif (p_del_rows.count > 1) THEN
     -- bug 2523074 (frontported bug 2508132):
     -- if multiple deliveries are processed, show summary message,
     -- so that the user does not think the first message (e.g.,
     -- request number) applies to all deliveries.
     FND_MESSAGE.SET_NAME('WSH', 'WSH_DEL_CONFIRM_SUCCESS');
     wsh_util_core.add_message(x_return_status);
    else
     FND_MESSAGE.SET_NAME('WSH', 'WSH_ONE_DEL_CONFIRM_SUCCESS');
     wsh_util_core.add_message(x_return_status);
    end if;
  END IF;

  WSH_UTIL_CORE.Store_Msg_In_Table (p_store_flag => FALSE,
                                    x_msg_rec_count => l_msg_rec_count,
                                    x_return_status => l_return_status);
  IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
     raise ship_confirm_error;
  END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      IF (Get_Trip%ISOPEN) THEN
        CLOSE Get_Trip;
      END IF;

      IF (get_delivery_name%ISOPEN) THEN
        CLOSE get_delivery_name;
      END IF;

      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN ship_confirm_error  THEN

      IF (Get_Trip%ISOPEN) THEN
        CLOSE Get_Trip;
      END IF;

      IF (get_delivery_name%ISOPEN) THEN
        CLOSE get_delivery_name;
      END IF;

      FND_MESSAGE.SET_NAME('WSH','WSH_SHIP_CONFIRM_ERROR');
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(l_delivery_id));
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      wsh_util_core.add_message(x_return_status);
      WSH_UTIL_CORE.Store_Msg_In_Table (p_store_flag => FALSE,
                                        x_msg_rec_count => l_msg_rec_count,
                                        x_return_status => l_return_status);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'SHIP_CONFIRM_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:SHIP_CONFIRM_ERROR');
END IF;
--
    WHEN record_locked THEN

      IF (Get_Trip%ISOPEN) THEN
        CLOSE Get_Trip;
      END IF;

      IF (get_delivery_name%ISOPEN) THEN
        CLOSE get_delivery_name;
      END IF;

     FND_MESSAGE.SET_NAME('WSH','WSH_DEL_LOCK_ERR');
     wsh_util_core.add_message(x_return_status);
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     WSH_UTIL_CORE.Store_Msg_In_Table (p_store_flag => FALSE,
                                       x_msg_rec_count => l_msg_rec_count,
                                       x_return_status => l_return_status);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'RECORD_LOCKED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:RECORD_LOCKED');
END IF;
--
    WHEN others THEN

      IF (Get_Trip%ISOPEN) THEN
        CLOSE Get_Trip;
      END IF;

      IF (get_delivery_name%ISOPEN) THEN
        CLOSE get_delivery_name;
      END IF;

      IF get_del_first_trip%isopen THEN
         CLOSE get_del_first_trip;
      END IF;
      wsh_util_core.default_handler('WSH_NEW_DELIVERY_ACTIONS.CONFIRM_DELIVERY');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,  'UNEXPECTED ERROR : ' || SQLERRM  );
      END IF;
      --
      WSH_UTIL_CORE.Store_Msg_In_Table (p_store_flag => FALSE,
                                        x_msg_rec_count => l_msg_rec_count,
                                        x_return_status => l_return_status);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Confirm_Delivery ;


-- J-IB-NPARIKH---{
--
--========================================================================
-- PROCEDURE : setInTransit
--
-- PARAMETERS: p_in_rec          Delivery information record
--             x_return_status   Return status of the API
--
-- COMMENT   : This procedure sets delivery to in-transit.
--             This is called by stop close API/Group API
--
--             It performs the following steps:
--             01. Update delivery lines to status "C"
--             02. For containers, update shipped quantity to 1
--             03. Update INV/OE interface flag to N for non-containers
--             04. Update INV/OE interface flag to Null for containers
--             05. Update delivery status to IT
--             06. Update delivery initial pickup date to actual departure date of stop
--             07. Update delivery ultimate dropoff date based on actual departure date of stop
--             08. Close delivery exceptions (Pack J Exceptions project)
--
--========================================================================
--
PROCEDURE setInTransit
            (
              p_in_rec             IN          WSH_DELIVERY_VALIDATIONS.ChgStatus_in_rec_type,
              x_return_status      OUT NOCOPY  VARCHAR2
            )
IS
--{
    l_user_id     NUMBER;
    l_login_id    NUMBER;
    l_num_warnings          NUMBER;
    l_num_errors            NUMBER;
    --

    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(4000);
    l_return_status   VARCHAR2(1);

    l_detail_tab     WSH_UTIL_CORE.id_tab_type; -- DBI Project
    l_dbi_rs                      VARCHAR2(1); -- Return Status from DBI API

    --/== Workflow Changes
    l_org_id NUMBER;
    l_wf_rs VARCHAR2(1);
    l_override_wf VARCHAR2(1);
    l_del_entity_ids WSH_UTIL_CORE.column_tab_type;
    l_purged_count NUMBER;
    --==/

    -- LPN CONV. rv
    cursor l_get_cnt_attr_csr(p_delivery_id IN NUMBER) is
    select wdd.organization_id organization_id,
           nvl(wdd.line_direction,'O') line_direction,
           wdd.delivery_detail_id delivery_detail_id
    from   wsh_delivery_assignments_v wda,
           wsh_delivery_details wdd
    where  wda.delivery_detail_id = wdd.delivery_detail_id
    and    wdd.container_flag IN ('Y','C')
    and    nvl(wdd.line_direction,'O') IN ('O', 'IO')
    and    wda.delivery_id = p_delivery_id;

    l_wms_org VARCHAR2(10);
    l_sync_tmp_wms_recTbl wsh_glbl_var_strct_grp.sync_tmp_recTbl_type;
    l_sync_tmp_inv_recTbl wsh_glbl_var_strct_grp.sync_tmp_recTbl_type;

    l_child_cnt_counter NUMBER;
    l_cnt_wms_counter NUMBER;
    l_cnt_inv_counter NUMBER;
    -- LPN CONV. rv

    --R12.1.1 STANDALONE PROJECT
    l_pending_advice_flag  VARCHAR2(1);
    l_organization_id  NUMBER;
    l_warehouse_type   VARCHAR2(3);
    --
    -- LSP PROJECT
    l_standalone_mode  VARCHAR2(1);
    l_client_id_tab    WSH_UTIL_CORE.id_tab_type;
    -- LSP PROJECT

    l_debug_on    BOOLEAN;
    --
    l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'setInTransit';
--}
BEGIN
--{
    --SAVEPOINT dlvy_setInTransit_begin_sp;
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
      wsh_debug_sv.LOG(l_module_name, 'p_in_rec.DELIVERY_ID ', p_in_rec.delivery_id );
      wsh_debug_sv.LOG(l_module_name, 'p_in_rec.name        ', p_in_rec.name        );
      wsh_debug_sv.LOG(l_module_name, 'p_in_rec.status_code ', p_in_rec.status_code );
      wsh_debug_sv.LOG(l_module_name, 'p_in_rec.put_messages', p_in_rec.put_messages);
      wsh_debug_sv.LOG(l_module_name, 'p_in_rec.manual_flag ', p_in_rec.manual_flag );
      wsh_debug_sv.LOG(l_module_name, 'p_in_rec.caller      ', p_in_rec.caller      );
      wsh_debug_sv.LOG(l_module_name, 'p_in_rec.actual_date ', p_in_rec.actual_date );
      wsh_debug_sv.LOG(l_module_name, 'p_in_rec.stop_id     ', p_in_rec.stop_id     );
    END IF;
    --
    l_user_id       := FND_GLOBAL.user_id;
    l_login_id      := FND_GLOBAL.login_id;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    l_num_warnings  := 0;
    l_num_errors    := 0;

    --
    --
    -- Bug: 1563304 : Update all its delivery_details to 'C'
    -- Bug 1578251: update interfaced_flags = 'N' to improve
    --   performance in filtering records ready to interface
    --   but not yet interfaced.
    /* H Integration: 940/945 do not update cancelled delivery lines wrudge */
    --  Bug 2335270 : last_update_date = SYSDATE is included in
    --                the update statement
    --
    -- LPN CONV. rv
    --
    --
    IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
    THEN
    --{
        --l_child_cnt_counter := 1;
        l_cnt_wms_counter := 1;
        l_cnt_inv_counter := 1;
        FOR child_cnt_rec in l_get_cnt_attr_csr(p_in_rec.delivery_id)  LOOP
        --{
            --
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.CHECK_WMS_ORG',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            l_wms_org := wsh_util_validate.check_wms_org(child_cnt_rec.organization_id);
            --

            IF(l_wms_org = 'Y') THEN
              l_sync_tmp_wms_recTbl.delivery_detail_id_tbl(l_cnt_wms_counter) := child_cnt_rec.delivery_detail_id;
              l_sync_tmp_wms_recTbl.operation_type_tbl(l_cnt_wms_counter) := 'UPDATE';
              l_cnt_wms_counter := l_cnt_wms_counter +1;
            ELSIF (l_wms_org = 'N') THEN
              l_sync_tmp_inv_recTbl.delivery_detail_id_tbl(l_cnt_inv_counter) := child_cnt_rec.delivery_detail_id;
              l_sync_tmp_inv_recTbl.operation_type_tbl(l_cnt_inv_counter) := 'UPDATE';
              l_cnt_inv_counter := l_cnt_inv_counter +1;
            END IF;
            --
        --}
        END LOOP;
        --
        IF l_debug_on THEN
          wsh_debug_sv.LOG(l_module_name, 'Count of l_sync_tmp_wms_recTbl', l_sync_tmp_wms_recTbl.delivery_detail_id_tbl.count);
          wsh_debug_sv.LOG(l_module_name, 'Count of l_sync_tmp_inv_recTbl', l_sync_tmp_inv_recTbl.delivery_detail_id_tbl.count);
        END IF;
        --
        IF  (WSH_WMS_LPN_GRP.GK_WMS_UPD_STS OR WSH_WMS_LPN_GRP.GK_WMS_UPD_QTY)
        AND l_sync_tmp_wms_recTbl.delivery_detail_id_tbl.count > 0
        THEN
        --{
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
               WSH_DEBUG_SV.logmsg(l_module_name, 'Return status ' || l_return_status);
            END IF;
            --
            WSH_UTIL_CORE.API_POST_CALL
              (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors
              );
            --
        --}
        ELSIF (WSH_WMS_LPN_GRP.GK_INV_UPD_STS OR WSH_WMS_LPN_GRP.GK_INV_UPD_QTY)
        AND l_sync_tmp_inv_recTbl.delivery_detail_id_tbl.count > 0
        THEN
        --{
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
               WSH_DEBUG_SV.logmsg(l_module_name, 'Return status ' || l_return_status);
            END IF;
            --
            WSH_UTIL_CORE.API_POST_CALL
              (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors
              );
            --
        --}
        END IF;
    --}
    END IF;
    -- LPN CONV. rv
    UPDATE wsh_Delivery_details
    SET    released_Status     = 'C',
           shipped_quantity    = DECODE(container_flag, 'Y', 1, shipped_quantity),
           inv_interfaced_flag = DECODE(container_flag, 'N', NVL(inv_interfaced_flag,'N'), NULL),
           oe_interfaced_flag  = DECODE(container_flag, 'N', NVL(oe_interfaced_flag, 'N'), NULL),
           last_update_date    = SYSDATE,
           last_updated_by     = l_user_id,
           last_update_login   = l_login_id
    WHERE  delivery_detail_id IN (
                                    SELECT delivery_Detail_id
                                    FROM   wsh_delivery_assignments_v
                                    WHERE  delivery_id = p_in_rec.delivery_id
                                )
    AND    released_status    <> 'D'
    RETURNING delivery_detail_id,client_id BULK COLLECT INTO l_detail_tab,l_client_id_tab; -- Added for DBI Project, LSP PROJECT :Added l_client_id_tab
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Number of Lines updated',SQL%ROWCOUNT);
    END IF;
    --
    --
    -- DBI Project
    -- Update of wsh_delivery_details where requested_quantity/released_status
    -- are changed, call DBI API after the update.
    -- DBI API will check if DBI is installed
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Detail Count-',l_detail_tab.count);
    END IF;
    WSH_INTEGRATION.DBI_Update_Detail_Log
      (p_delivery_detail_id_tab => l_detail_tab,
       p_dml_type               => 'UPDATE',
       x_return_status          => l_dbi_rs);

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
    END IF;
    -- Only Handle Unexpected error
    IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- End of Code for DBI Project
    --
    -- R12.1.1 STANDALONE PROJECT
    l_pending_advice_flag := null;
    --
    -- LSP PROJECT :
    l_standalone_mode := WMS_DEPLOY.WMS_DEPLOYMENT_MODE;
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_standalone_mode',l_standalone_mode);
      WSH_DEBUG_SV.log(l_module_name,'l_client_id_tab.COUNT',l_client_id_tab.COUNT);
    END IF;
    IF (l_standalone_mode = 'D' OR (l_standalone_mode = 'L' and l_client_id_tab.COUNT > 0 )) THEN  --{
      l_pending_advice_flag := 'Y';
    ELSE
      l_organization_id := null;

      BEGIN

        SELECT organization_id
          INTO l_organization_id
          FROM wsh_new_deliveries
         WHERE delivery_id = p_in_rec.delivery_id;

      EXCEPTION
         WHEN OTHERS THEN
              NULL;
      END;

      IF (l_organization_id is not null) THEN

        l_warehouse_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type(
                               P_Organization_ID       => l_organization_id,
                               X_Return_Status         => l_return_status);

        IF l_debug_on THEN
            wsh_debug_sv.log (l_module_name, 'Return status from get warehouse type', l_return_status);
            wsh_debug_sv.log (l_module_name, 'Warehouse type ', l_warehouse_type);
        END IF;

        IF (l_warehouse_type = 'TPW') THEN
          l_pending_advice_flag := 'Y';
        END IF;

      END IF;

    END IF; --}

    UPDATE wsh_new_deliveries
    SET    initial_pickup_date   = p_in_rec.actual_date,
           ultimate_dropoff_date = GREATEST(
                                             NVL(ultimate_dropoff_date,p_in_rec.actual_date),
                                             p_in_rec.actual_date
                                           ),
           status_code           = 'IT',
           --R12.1.1 STANDALONE PROJECT
           pending_advice_flag   = l_pending_advice_flag,
           last_update_date      = SYSDATE  ,
           last_updated_by       = l_user_id,
           last_update_login     = l_login_id
    WHERE  delivery_id           = p_in_rec.delivery_id
    RETURNING organization_id INTO l_org_id;
    --
    IF (SQL%NOTFOUND)
    THEN
    --{
        FND_MESSAGE.SET_NAME('WSH','WSH_DEL_NOT_FOUND');
        l_num_errors := l_num_errors + 1;
        wsh_util_core.add_message(x_return_status,l_module_name);
    --}
    ELSE
        --/== Workflow Changes
        l_del_entity_ids(1) := p_in_rec.delivery_id;
        l_override_wf:= fnd_profile.value('WSH_OVERRIDE_SCPOD_WF');
        IF (l_override_wf = 'Y' AND WSH_WF_STD.Wf_Exists('DELIVERY_C',p_in_rec.delivery_id)) THEN
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.LOG_WF_EXCEPTION', WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            WSH_WF_STD.Log_Wf_Exception(p_entity_type    => 'DELIVERY',
	                                p_entity_id      => p_in_rec.delivery_id,
				        p_logging_entity => 'SHIPPER',
				        p_exception_name => 'WSH_DEL_SCPOD_PURGED',
				        x_return_status  => l_wf_rs);
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'L_WF_RS',l_wf_rs);
            END IF;

            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.PURGE_ENTITY', WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

	    WSH_WF_STD.Purge_Entity(p_entity_type   => 'DELIVERY',
				    p_entity_ids    => l_del_entity_ids,
				    p_docommit      => FALSE,
				    x_success_count => l_purged_count,
				    x_return_status => l_wf_rs);
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'L_PURGED_COUNT',l_purged_count);
                WSH_DEBUG_SV.log(l_module_name,'L_WF_RS',l_wf_rs);
	    END IF;

        END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.RAISE_EVENT',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	WSH_WF_STD.RAISE_EVENT(p_entity_type     =>  'DELIVERY',
			       p_entity_id       =>  p_in_rec.delivery_id,
			       p_event           =>  'oracle.apps.wsh.delivery.gen.setintransit',
			       p_organization_id =>  l_org_id,
			       x_return_status   =>  l_wf_rs);

	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_WF_STD.RAISE_EVENT => ',l_wf_rs);
	END IF;
        -- Workflow Changes ==/
    END IF;

   --

   -- Close Exceptions for delivery and its contents
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_XC_UTIL.Close_Exceptions',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   WSH_XC_UTIL.Close_Exceptions (
                                     p_api_version           => 1.0,
                                     x_return_status         => l_return_status,
                                     x_msg_count             => l_msg_count,
                                     x_msg_data              => l_msg_data,
                                     p_logging_entity_id     => p_in_rec.delivery_id,
                                     p_logging_entity_name   => 'DELIVERY',
                                     p_consider_content      => 'Y',
--tkt
                                     p_caller                => p_in_rec.caller
                                  ) ;

   IF ( l_return_status <>  WSH_UTIL_CORE.G_RET_STS_SUCCESS )  THEN
        x_return_status := l_return_status;
        wsh_util_core.add_message(x_return_status);
        IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)  THEN
              l_num_errors := l_num_errors + 1;
              RAISE FND_API.G_EXC_ERROR;
        ELSE
              l_num_warnings := l_num_warnings + 1 ;
        END IF;
   END IF;

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

      --ROLLBACK TO dlvy_setInTransit_begin_sp;
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      --ROLLBACK TO dlvy_setInTransit_begin_sp;
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
        wsh_util_core.default_handler('WSH_NEW_DELIVERY_ACTIONS.setInTransit',l_module_name);
        --
        --ROLLBACK TO dlvy_setInTransit_begin_sp;
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
END setInTransit;
--
--
--
--========================================================================
-- PROCEDURE : setClose
--
-- PARAMETERS: p_in_rec          Delivery information record
--             x_return_status   Return status of the API
--
-- COMMENT   : This procedure sets delivery to CLOSED.
--             This is called by stop close API/Group API
--
--             It performs the following steps:
--             01. Update delivery status to CL
--             02. Update delivery ultimate dropoff date based on actual departure date of stop
--             03. Close delivery exceptions (Pack J Exceptions project)
--             04. Close stops exclusively owened by delivery.
--
--========================================================================
--
PROCEDURE setClose
            (
              p_in_rec             IN          WSH_DELIVERY_VALIDATIONS.ChgStatus_in_rec_type,
              x_return_status      OUT NOCOPY  VARCHAR2
            )
IS
--{
    CURSOR delivery_stops_csr (p_delivery_id NUMBER)
    IS
    SELECT stop_id
    FROM   wsh_delivery_legs wdl,
           wsh_Trip_stops    wts
    WHERE  wdl.delivery_id = p_delivery_id
    AND    (
                wdl.pick_up_stop_id  = wts.stop_id
             OR wdl.drop_off_stop_id = wts.stop_id
           )
    AND    wts.status_code <> 'CL';
    --
    --
    l_num_warnings          NUMBER;
    l_num_errors            NUMBER;
    l_return_status         VARCHAR2(10);
    --
    l_user_id     NUMBER;
    l_login_id    NUMBER;
    l_cnt         NUMBER := 0;
    l_stop_rows   wsh_util_core.id_tab_type;

    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(4000);

    --/== Workflow Changes
    l_org_id NUMBER;
    l_wf_rs VARCHAR2(1);
    l_override_wf VARCHAR2(1);
    l_del_entity_ids WSH_UTIL_CORE.column_tab_type;
    l_purged_count NUMBER;
    --==/

    l_gc3_is_installed	   VARCHAR2(1); --OTM R12

    --
    l_debug_on    BOOLEAN;
    --
    l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'setClose';
--}
BEGIN
--{
    --SAVEPOINT dlvy_close_begin_sp;
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
      wsh_debug_sv.LOG(l_module_name, 'p_in_rec.DELIVERY_ID ', p_in_rec.delivery_id );
      wsh_debug_sv.LOG(l_module_name, 'p_in_rec.name        ', p_in_rec.name        );
      wsh_debug_sv.LOG(l_module_name, 'p_in_rec.status_code ', p_in_rec.status_code );
      wsh_debug_sv.LOG(l_module_name, 'p_in_rec.put_messages', p_in_rec.put_messages);
      wsh_debug_sv.LOG(l_module_name, 'p_in_rec.manual_flag ', p_in_rec.manual_flag );
      wsh_debug_sv.LOG(l_module_name, 'p_in_rec.caller      ', p_in_rec.caller      );
      wsh_debug_sv.LOG(l_module_name, 'p_in_rec.actual_date ', p_in_rec.actual_date );
    END IF;
    --
    l_user_id       := FND_GLOBAL.user_id;
    l_login_id      := FND_GLOBAL.login_id;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    l_num_warnings  := 0;
    l_num_errors    := 0;
    --
    --OTM R12
    l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED; -- this is global variable

    IF l_gc3_is_installed IS NULL THEN
      l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED; -- this is actual function
    END IF;
    --
    --
    UPDATE wsh_new_deliveries
    SET    ultimate_dropoff_date = GREATEST(
                                             nvl(ultimate_dropoff_date,p_in_rec.actual_date),
                                             p_in_rec.actual_date
                                           ),
           status_code           = 'CL',
           --OTM R12, when setting delivery to closed, set tms flag
           tms_interface_flag    = DECODE(l_gc3_is_installed,
                                          'Y', DECODE(NVL(tms_interface_flag,
                                                          WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT),
                                                      WSH_NEW_DELIVERIES_PVT.C_TMS_DELETE_REQUIRED,
                                                      WSH_NEW_DELIVERIES_PVT.C_TMS_DELETE_REQUIRED,
                                                      WSH_NEW_DELIVERIES_PVT.C_TMS_DELETE_IN_PROCESS,
                                                      WSH_NEW_DELIVERIES_PVT.C_TMS_DELETE_IN_PROCESS,
                                                      WSH_NEW_DELIVERIES_PVT.C_TMS_COMPLETED),
                                          NVL(tms_interface_flag,
                                              WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT)),
           --
           last_update_date      = SYSDATE  ,
           last_updated_by       = l_user_id,
           last_update_login     = l_login_id
    WHERE  delivery_id           = p_in_rec.delivery_id
    RETURNING organization_id INTO l_org_id;
    --
    IF (SQL%NOTFOUND)
    THEN
         FND_MESSAGE.SET_NAME('WSH','WSH_DEL_NOT_FOUND');
         wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR);
         RAISE FND_API.G_EXC_ERROR;
    END IF;
    --


    --/== Workflow Changes
    l_del_entity_ids(1) := p_in_rec.delivery_id;
    l_override_wf:= fnd_profile.value('WSH_OVERRIDE_SCPOD_WF');
    IF (l_override_wf = 'Y' AND WSH_WF_STD.Wf_Exists('DELIVERY_C',p_in_rec.delivery_id)) THEN
        WSH_WF_STD.Log_Wf_Exception('DELIVERY',
		p_in_rec.delivery_id,
		NULL,
		'SHIPPER',
		'WSH_DEL_SCPOD_PURGED',
		l_wf_rs);
	WSH_WF_STD.Purge_Entity(
		p_entity_type => 'DELIVERY',
		p_entity_ids  => l_del_entity_ids,
		p_docommit    => FALSE,
		x_success_count  => l_purged_count,
		x_return_status => l_wf_rs);
    END IF;


    IF l_debug_on THEN
	WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.RAISE_EVENT',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;

    WSH_WF_STD.RAISE_EVENT(p_entity_type  =>  'DELIVERY',
			p_entity_id       =>  p_in_rec.delivery_id,
			p_event           =>  'oracle.apps.wsh.delivery.gen.closed',
			p_organization_id =>  l_org_id,
			x_return_status   =>  l_wf_rs);

    IF l_debug_on THEN
	WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_WF_STD.RAISE_EVENT => ',l_wf_rs);
    END IF;
    -- Workflow Changes ==/

    -- Close Exceptions for delivery and its contents
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_XC_UTIL.Close_Exceptions',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    WSH_XC_UTIL.Close_Exceptions (
                                     p_api_version           => 1.0,
                                     x_return_status         => l_return_status,
                                     x_msg_count             => l_msg_count,
                                     x_msg_data              => l_msg_data,
                                     p_logging_entity_id     => p_in_rec.delivery_id,
                                     p_logging_entity_name   => 'DELIVERY',
                                     p_consider_content      => 'Y'
                                  ) ;

    IF ( l_return_status <>  WSH_UTIL_CORE.G_RET_STS_SUCCESS )  THEN
         x_return_status := l_return_status;
         wsh_util_core.add_message(x_return_status);
         IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)  THEN
               l_num_errors := l_num_errors + 1;
               RAISE FND_API.G_EXC_ERROR;
         ELSE
               l_num_warnings := l_num_warnings + 1 ;
         END IF;
    END IF;

    IF (p_in_rec.manual_flag = 'Y')
    THEN
    --{
       -- If manual Close then close any stops not closed.
       -- Assumption: check_close validates that the delivery
       -- exclusively owns these stops.
       --
       FOR delivery_stops_rec IN delivery_stops_csr(p_in_rec.delivery_id)
       LOOP
       --{
            l_cnt := l_cnt + 1;
            --
            l_stop_rows(l_cnt) := delivery_stops_rec.stop_id;
       --}
       END LOOP;
       --
       IF l_stop_rows.count > 0
       THEN
       --{
            -- since the delivery is CLOSED and it owns these stops exclusively,
            -- it is safe to set p_defer_interface_flag = 'Y'
               -- because nothing needs to be interfaced
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_ACTIONS.CHANGE_STATUS',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            wsh_trip_stops_actions.change_status
                (
                  p_stop_rows             => l_stop_rows,
                  p_action                => 'CLOSE',
                  p_actual_date           => p_in_rec.actual_date,
                  p_defer_interface_flag  => 'Y',   -- bug 1578251
                  x_return_status         => l_return_status,
--tkt
                  p_caller                => p_in_rec.caller
                );
            --
            wsh_util_core.api_post_call
              (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors
              );
            --
            --
       --}
       END IF;
    --}
    END IF;
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

      --ROLLBACK TO dlvy_close_begin_sp;
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      --ROLLBACK TO dlvy_close_begin_sp;
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
        wsh_util_core.default_handler('WSH_NEW_DELIVERY_ACTIONS.setClose',l_module_name);
        --
        --ROLLBACK TO dlvy_close_begin_sp;
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
-- J-IB-NPARIKH---}



  PROCEDURE change_Status ( p_del_rows  IN wsh_util_core.id_tab_type,
             p_action   IN VARCHAR2,
             p_actual_date  IN DATE,
             x_return_status OUT NOCOPY  VARCHAR2,
             p_caller               IN   VARCHAR2) IS

  CURSOR del_status (l_delivery_id NUMBER) IS
  SELECT status_code, name,organization_id
  FROM   wsh_new_deliveries
  WHERE  delivery_id = l_delivery_id;

  CURSOR delivery_leg_stops(l_delivery_id NUMBER) IS
  SELECT dg.pick_up_stop_id,
     pu_stop.status_code  pu_status,
   dg.drop_off_stop_id,
     do_stop.status_code  do_status
  FROM   wsh_delivery_legs dg,
     wsh_trip_stops pu_stop,
     wsh_trip_stops do_stop
  WHERE  dg.delivery_id = l_delivery_id
  AND pu_stop.stop_id = dg.pick_up_stop_id
  AND do_stop.stop_id = dg.drop_off_stop_id;

  trip_cnt NUMBER;
  l_old_status VARCHAR2(2);
  l_name VARCHAR2(30);
  l_status_code VARCHAR2(2);
  l_del_rows wsh_util_core.id_tab_type;

  l_delivery_id NUMBER;
  l_stop_rows wsh_util_core.id_tab_type;

  l_manual_flag  VARCHAR2(1);
  l_close_rs   VARCHAR2(1);

  l_num_error NUMBER := 0;
  k      NUMBER := 0;

  --bug 1929104
  l_actual_date date;

  others EXCEPTION;

  l_wf_rs VARCHAR2(1);    -- Workflow Changes

--  bug 2335270
  l_user_id  NUMBER;
  l_login_id NUMBER;
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHANGE_STATUS';
  --
  l_return_status    VARCHAR2(30);
  l_allowed          VARCHAR2(10);
  l_in_rec           WSH_DELIVERY_VALIDATIONS.ChgStatus_in_rec_type;
  --
  l_num_warnings          NUMBER;
  l_num_errors            NUMBER;
  l_num_dels_processed    NUMBER;
  l_organization_id       NUMBER;
  l_warehouse_type        VARCHAR2 (3);

  BEGIN
  --
  SAVEPOINT dlvy_chg_status_begin_sp;
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
  END IF;
  --
  --
  l_user_id := FND_GLOBAL.user_id;
  l_login_id := FND_GLOBAL.login_id;
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  --
  l_num_warnings  := 0;
  l_num_errors    := 0;
  l_num_dels_processed := 0;
  --

   IF (p_del_rows.count = 0) THEN
     raise others;
   END IF;

     -- Close called from Stop close or from UI.

     IF (p_actual_date IS NULL) THEN
      l_manual_flag := 'Y';
      l_actual_date := SYSDATE;
     ELSE
      l_manual_flag := 'N';
      l_actual_date := p_actual_date;
     END IF;
    --
   --FOR i IN 1..p_del_rows.count
   FOR i IN p_del_rows.FIRST..p_del_rows.LAST
   LOOP
   --{
        BEGIN
        --{
             SAVEPOINT dlvy_chg_status_sp;
             --
             OPEN  del_status (p_del_rows(i));
             FETCH del_status INTO l_old_status , l_name,l_organization_id;
             --
             -- J-IB-NPARIKH---{
             IF (del_status%NOTFOUND)
             THEN
                FND_MESSAGE.SET_NAME('WSH','WSH_DEL_NOT_FOUND');
                wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
                --CLOSE del_status;
                l_num_errors := l_num_errors + 1;
                RAISE FND_API.G_EXC_ERROR;
             END IF;
             -- J-IB-NPARIKH---}
             --
             --
             CLOSE del_status;

               IF (p_action = 'IN-TRANSIT')
               THEN
               --{
-- J-IB-NPARIKH---{
                    --
                    l_in_rec.delivery_id    := p_del_rows(i);
                    l_in_rec.name           := l_name;
                    l_in_rec.status_code    := l_old_status;
                    l_in_rec.put_messages   := TRUE;
                    l_in_rec.actual_date    := l_actual_date;
                    l_in_rec.manual_flag    := l_manual_flag;
--tkt
                    l_in_rec.caller         := p_caller;
                    --
                    --
                    -- Debug Statements
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_VALIDATIONS.check_inTransit',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    WSH_DELIVERY_VALIDATIONS.check_inTransit
                        (
                           p_in_rec         => l_in_rec,
                           x_return_status  => l_return_status,
                           x_allowed        => l_Allowed
                        );
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                        WSH_DEBUG_SV.log(l_module_name,'l_Allowed',l_Allowed);
                    END IF;
                    --
                    WSH_UTIL_CORE.api_post_call
                        (
                            p_return_status => l_return_status,
                            x_num_warnings  => l_num_warnings,
                            x_num_errors    => l_num_errors
                        );
                    --
                    IF l_Allowed = 'Y'
                    THEN
                        NULL;
                    ELSIF l_Allowed = 'YW'
                    THEN
                        l_num_warnings := l_num_warnings + 1;
                    ELSIF l_Allowed = 'NW'
                    THEN
                        l_num_warnings := l_num_warnings + 1;
                        RAISE wsh_util_core.g_exc_warning;
                    ELSE
                        l_num_errors   := l_num_errors   + 1;
                        RAISE FND_API.G_EXC_ERROR;
                    END IF;
                    --
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit setInTransit',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    setInTransit
                        (
                           p_in_rec         => l_in_rec,
                           x_return_status  => l_return_status
                        );
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                    END IF;
                    --
                    WSH_UTIL_CORE.api_post_call
                        (
                            p_return_status => l_return_status,
                            x_num_warnings  => l_num_warnings,
                            x_num_errors    => l_num_errors
                        );
                    --
                    l_num_dels_processed := l_num_dels_processed + 1;
               --}
               ELSIF (p_action = 'CLOSE')
               THEN
               --{
                    --
                    l_in_rec.delivery_id    := p_del_rows(i);
                    l_in_rec.name           := l_name;
                    l_in_rec.status_code    := l_old_status;
                    l_in_rec.put_messages   := TRUE;
                    l_in_rec.actual_date    := l_actual_date;
                    l_in_rec.manual_flag    := l_manual_flag;
--tkt
                    l_in_rec.caller         := p_caller;
                    --
                    --
                    -- Debug Statements
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_VALIDATIONS.check_inTransit',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    WSH_DELIVERY_VALIDATIONS.check_close
                        (
                           p_in_rec         => l_in_rec,
                           x_return_status  => l_return_status,
                           x_allowed        => l_Allowed
                        );
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                        WSH_DEBUG_SV.log(l_module_name,'l_Allowed',l_Allowed);
                    END IF;
                    --
                    WSH_UTIL_CORE.api_post_call
                        (
                            p_return_status => l_return_status,
                            x_num_warnings  => l_num_warnings,
                            x_num_errors    => l_num_errors
                        );
                    --
                    IF l_Allowed = 'Y'
                    THEN
                        NULL;
                    ELSIF l_Allowed = 'YW'
                    THEN
                        l_num_warnings := l_num_warnings + 1;
                    ELSIF l_Allowed = 'NW'
                    THEN
                        l_num_warnings := l_num_warnings + 1;
                        RAISE wsh_util_core.g_exc_warning;
                    ELSE
                        l_num_errors   := l_num_errors   + 1;
                        RAISE FND_API.G_EXC_ERROR;
                    END IF;
                    --
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit setClose',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    setClose
                        (
                           p_in_rec         => l_in_rec,
                           x_return_status  => l_return_status
                        );
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                    END IF;
                    --
                    WSH_UTIL_CORE.api_post_call
                        (
                            p_return_status => l_return_status,
                            x_num_warnings  => l_num_warnings,
                            x_num_errors    => l_num_errors
                        );
                    --
                    l_num_dels_processed := l_num_dels_processed + 1;
                    -- J-IB-NPARIKH---}

               --}
            ELSIF (p_action = 'PACK')
            THEN
            --{
                  --
                  -- Debug Statements
                  --
                  IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_VALIDATIONS.CHECK_PACK',WSH_DEBUG_SV.C_PROC_LEVEL);
                  END IF;
                  --
                  wsh_delivery_validations.check_pack(p_del_rows(i), l_return_status);
                        --
                        WSH_UTIL_CORE.api_post_call
                            (
                                p_return_status => l_return_status,
                                x_num_warnings  => l_num_warnings,
                                x_num_errors    => l_num_errors
                            );

                  l_status_code := 'PA';

                  l_num_dels_processed := l_num_dels_processed + 1;
            --}
              -- Included 'RE-OPEN' in this if condition
              -- To fix bug 2359880
              -- Public api WSHDEPBB.pls calls with action='RE-OPEN'
            ELSIF (p_action IN  ('REOPEN', 'RE-OPEN')) THEN
            --{
                  --
                  -- Debug Statements
                  --
                  IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_VALIDATIONS.CHECK_REOPEN',WSH_DEBUG_SV.C_PROC_LEVEL);
                  END IF;
                  --


                  -- Bug#3206399: Not Able to Re-open a Confirmed Delivery.
                  --
                  -- Call to check_reopen should return the status in local variable l_return_status.
                  -- (This variable is used in further calls)
                  -- x_return_status is assigned equal to l_return_status before exiting the
                  -- procedure.

                  -- wsh_delivery_validations.check_reopen(p_del_rows(i), x_return_status);

                   wsh_delivery_validations.check_reopen(p_del_rows(i), l_return_status);

                        --
                        WSH_UTIL_CORE.api_post_call
                            (
                                p_return_status => l_return_status,
                                x_num_warnings  => l_num_warnings,
                                x_num_errors    => l_num_errors
                            );
                        --

                  l_warehouse_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type(
                     P_Organization_ID       => l_organization_id,
                     X_Return_Status         => l_return_status);

                  IF l_debug_on THEN
                   wsh_debug_sv.log (l_module_name, 'Return status from get warehouse type', l_return_status);
                   wsh_debug_sv.log (l_module_name, 'Warehouse type ', l_warehouse_type);
                  END IF;

                  WSH_UTIL_CORE.api_post_call (
                                p_return_status => l_return_status,
                                x_num_warnings  => l_num_warnings,
                                x_num_errors    => l_num_errors);

                  IF (l_warehouse_type='TPW') THEN
                     l_status_code := 'SA';
                  ELSE
                     l_status_code := 'OP';
                  END IF;

                  IF l_debug_on THEN
                   wsh_debug_sv.log (l_module_name, 'l_status_code',l_status_code);
                  END IF;


                  update wsh_new_deliveries
                  set status_code           = l_status_code,
                      confirm_date          = null,--6453740
                      confirmed_by          = null,--6453740
                      last_update_date      = SYSDATE  ,
                      last_updated_by       = l_user_id,
                      last_update_login     = l_login_id
                  where delivery_id         = p_del_rows(i);

                IF (SQL%NOTFOUND) THEN
                  FND_MESSAGE.SET_NAME('WSH','WSH_DEL_NOT_FOUND');
                    wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR);
                   l_num_errors := l_num_errors + 1;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

                -- K: MDC:
                -- Reopen the consol delivery as well if it exists and is not open
                IF l_status_code = 'OP' THEN

                   -- bug 4891897, sql 15037864
                   -- removed wsh_new_deliveries d2

                   update wsh_new_deliveries d1
                      set d1.status_code           = l_status_code,
                          d1.last_update_date      = SYSDATE,
                          d1.last_updated_by       = l_user_id,
                          d1.last_update_login     = l_login_id
                    where d1.status_code = 'CO'
                      and exists (
                            select 'X'
                              from wsh_delivery_legs l1, wsh_delivery_legs l2
                             where l2.delivery_id = p_del_rows(i)
                               and l2.parent_delivery_leg_id = l1.delivery_leg_id
                               and l1.delivery_id = d1.delivery_id);
                 END IF;

		--/== Workflow Changes
		IF (l_status_code = 'OP') THEN
			IF l_debug_on THEN
				WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.RAISE_EVENT',WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;

			WSH_WF_STD.RAISE_EVENT(p_entity_type     =>  'DELIVERY',
					       p_entity_id       =>  p_del_rows(i),
					       p_event           =>  'oracle.apps.wsh.delivery.gen.open',
					       p_organization_id =>  l_organization_id,
					       x_return_status   =>  l_wf_rs);

			IF l_debug_on THEN
				WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_WF_STD.RAISE_EVENT => ',l_wf_rs);
			END IF;
		END IF;
		-- Workflow Changes ==/

		  l_num_dels_processed := l_num_dels_processed + 1;

            --}
            END IF;
       --}
       EXCEPTION
       --{
            WHEN FND_API.G_EXC_ERROR
            THEN
            --{
                ROLLBACK TO dlvy_chg_status_sp;
                --
                FND_MESSAGE.SET_NAME('WSH','WSH_DEL_CHANGE_STATUS_ERROR');
                FND_MESSAGE.SET_TOKEN('DEL_NAME',l_name);
                --
                wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
            --}
            WHEN wsh_util_core.g_exc_warning
            THEN
            --{
                ROLLBACK TO dlvy_chg_status_sp;
                --
                FND_MESSAGE.SET_NAME('WSH','WSH_DEL_CHANGE_STATUS_ERROR');
                FND_MESSAGE.SET_TOKEN('DEL_NAME',l_name);
                --
                wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_WARNING,l_module_name);
            --}
        --}
        END;
   --}
   END LOOP;
   --
   --
    IF l_num_dels_processed = 0
    THEN
        l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    ELSIF l_num_dels_processed < p_del_rows.count
    THEN
        l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    ELSIF l_num_warnings > 0
    THEN
        l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    ELSE
        l_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    END IF;
    --
    x_return_status := l_return_status;
    --
    IF p_del_rows.count > 1
    THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_DEL_CHANGE_STATUS_SUMMARY');
        FND_MESSAGE.SET_TOKEN('NUM_SUCCESS',l_num_dels_processed);
        FND_MESSAGE.SET_TOKEN('NUM_ERROR',p_del_rows.count - l_num_dels_processed);
        wsh_util_core.add_message(l_return_status,l_module_name);
    END IF;
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO dlvy_chg_status_begin_sp;
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO dlvy_chg_status_begin_sp;
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
      ROLLBACK TO dlvy_chg_status_begin_sp;
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
  END CHANGE_STATUS;


-- Following is old procedure as of I, which is replaced by proc. above in J
-- remove after ut

/* bug 2335270 Included last_update_date,last_updated_by and last_update_login
             in  wsh_new_deliveries and wsh_delivery_details */

-- J-IB-HEALI---{
PROCEDURE Complete_Leg_Sequence
      ( p_delivery_id   IN   NUMBER,
        p_update_flag   IN VARCHAR2,
        p_insert_msg    IN BOOLEAN default true,
        x_leg_count	OUT NOCOPY NUMBER,
        x_leg_complete	OUT NOCOPY varchar2,
        x_return_status OUT NOCOPY   VARCHAR2) IS

  CURSOR delivery_info IS
  SELECT initial_pickup_location_id,
    ultimate_dropoff_location_id
  FROM   wsh_new_deliveries
  WHERE  delivery_id = p_delivery_id;

  CURSOR count_legs IS
  SELECT count(*)
  FROM   wsh_delivery_legs
  WHERE  delivery_id = p_delivery_id;

  CURSOR pickup_delivery_legs(l_pickup_location_id IN NUMBER) IS
  SELECT dg.delivery_leg_id leg_id,
    st1.stop_location_id pickup,
    st2.stop_location_id dropoff
  FROM   wsh_delivery_legs dg,
    wsh_trip_stops st1,
    wsh_trip_stops st2
  WHERE  dg.delivery_id = p_delivery_id AND
    st1.stop_id = dg.pick_up_stop_id AND
    st2.stop_id = dg.drop_off_stop_id AND
    st1.stop_location_id = l_pickup_location_id;

  CURSOR dropoff_delivery_legs(l_pickup_location_id IN NUMBER) IS
  SELECT count(*)
  FROM   wsh_delivery_legs dg,
    wsh_trip_stops st1,
    wsh_trip_stops st2
  WHERE  dg.delivery_id = p_delivery_id AND
    st1.stop_id = dg.pick_up_stop_id AND
    st2.stop_id = dg.drop_off_stop_id AND
    st2.stop_location_id = l_pickup_location_id;

  l_leg_id         NUMBER;
  l_seq_num       NUMBER;
  l_pickup_location_id   NUMBER;
  l_dropoff_location_id  NUMBER;
  l_final_dropoff   NUMBER;
  l_leg_count     NUMBER := 0;
  l_count       NUMBER := 0;

  others EXCEPTION;

  l_debug_on BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Complete_Leg_Sequence';
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
      WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_UPDATE_FLAG',P_UPDATE_FLAG);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  x_leg_complete := 'N';


  OPEN delivery_info;
  FETCH delivery_info INTO l_pickup_location_id, l_dropoff_location_id;

  IF (delivery_info%NOTFOUND) THEN
     CLOSE delivery_info;

     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('WSH','WSH_DEL_NOT_FOUND');
     wsh_util_core.add_message(x_return_status);


     IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
     RETURN;
  END IF;

  l_final_dropoff := l_dropoff_location_id;

  IF (l_pickup_location_id IS NULL) OR (l_dropoff_location_id IS NULL)THEN
    raise others;
  END IF;
  CLOSE delivery_info;


  OPEN  count_legs;
  FETCH count_legs INTO l_leg_count;
  CLOSE count_legs;

  x_leg_count := l_leg_count;

  IF (l_leg_count = 0 OR l_leg_count IS NULL) THEN
     IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
     RETURN;
  END IF;


  l_seq_num := 0;

  LOOP --{
     OPEN  pickup_delivery_legs(l_pickup_location_id);
     FETCH pickup_delivery_legs INTO l_leg_id, l_pickup_location_id, l_dropoff_location_id;

     IF (pickup_delivery_legs%NOTFOUND) THEN
       CLOSE pickup_delivery_legs;
       EXIT;
     END IF;


     IF (l_leg_id IS NOT NULL) THEN
        l_seq_num := l_seq_num + 1;

        IF p_update_flag = 'Y' THEN
           UPDATE wsh_delivery_legs
            SET sequence_number = l_seq_num * 10
           WHERE delivery_leg_id = l_leg_id;

           IF (SQL%NOTFOUND) THEN
              x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

              FND_MESSAGE.SET_NAME('WSH','WSH_LEG_NOT_FOUND');
              wsh_util_core.add_message(x_return_status);

              IF l_debug_on THEN
                  WSH_DEBUG_SV.pop(l_module_name);
              END IF;
              --
              RETURN;
           END IF;
        END IF; /* added for p_update_flag */
      END IF; /* l_leg_id IS NOT NULL */


     FETCH pickup_delivery_legs INTO l_leg_id, l_pickup_location_id, l_dropoff_location_id;
     IF (pickup_delivery_legs%FOUND) THEN
        CLOSE pickup_delivery_legs;

        IF (p_insert_msg) THEN
           FND_MESSAGE.SET_NAME('WSH','WSH_DEL_MULTIPLE_LEGS');
           FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_delivery_id));
           wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR);
        END IF;

        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        RETURN;
    END IF;
    CLOSE pickup_delivery_legs;

     OPEN dropoff_delivery_legs(l_dropoff_location_id);
     FETCH dropoff_delivery_legs INTO l_count;
     CLOSE dropoff_delivery_legs;

     IF (l_count > 1) THEN
        IF (p_insert_msg) THEN
           FND_MESSAGE.SET_NAME('WSH','WSH_DEL_MULTIPLE_LEGS');
           FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_delivery_id));
           wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR);
        END IF;

        IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        RETURN;
    END IF;

     l_pickup_location_id := l_dropoff_location_id;
  END LOOP; --}



  IF (l_seq_num <> l_leg_count) THEN

     IF (p_insert_msg) THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_DEL_INVALID_FLOW');
        FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_delivery_id));
        wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR);
     END IF;
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
     RETURN;
  END IF;


  IF (l_final_dropoff <> l_dropoff_location_id) THEN
     x_leg_complete := 'NW';

     IF (p_insert_msg) THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_DEL_NO_ULTIMATE_DROPOFF');
        FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_delivery_id));
        wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR);
     END IF;
     RETURN;
  END IF;


  x_leg_complete := 'Y';

IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
     WHEN others THEN
      wsh_util_core.default_handler('WSH_NEW_DELIVERY_ACTIONS.Complete_Leg_Sequence');
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Complete_Leg_Sequence;


PROCEDURE Update_Leg_Sequence
      ( p_delivery_id   IN   NUMBER,
        p_update_flag    IN VARCHAR2,
        x_return_status OUT NOCOPY   VARCHAR2) IS

  l_leg_count           NUMBER := 0;
  l_leg_complete	varchar2(10);
  l_return_status	varchar2(1);

  l_debug_on BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_LEG_SEQUENCE';
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
      WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_UPDATE_FLAG',P_UPDATE_FLAG);
  END IF;


  Complete_Leg_Sequence
      ( p_delivery_id   => p_delivery_id,
        p_update_flag   => p_update_flag,
        x_leg_count     => l_leg_count,
        x_leg_complete  => l_leg_complete,
        x_return_status => l_return_status);

  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'After Call Complete_Leg_Sequence',l_return_status);
      WSH_DEBUG_SV.log(l_module_name,'l_leg_count',l_leg_count);
      WSH_DEBUG_SV.log(l_module_name,'l_leg_complete',l_leg_complete);
  END IF;

  IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
    IF (l_leg_complete='NW') THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    ELSIF (l_leg_complete='Y') THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    ELSIF (l_leg_complete='N') THEN
       IF (l_leg_count IS NULL or l_leg_count=0) THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
       ELSE
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       END IF;
    END IF;
  ELSE
     x_return_status:= l_return_status;
  END IF;


  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
--
EXCEPTION
   WHEN others THEN
     wsh_util_core.default_handler('WSH_NEW_DELIVERY_ACTIONS.UPDATE_LEG_SEQUENCE');
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Update_Leg_Sequence;



PROCEDURE Process_Leg_Sequence
      ( p_delivery_id   IN   NUMBER,
        p_update_del_flag    IN VARCHAR2,
        p_update_leg_flag    IN VARCHAR2,
        x_leg_complete	OUT NOCOPY boolean,
        x_return_status OUT NOCOPY   VARCHAR2) IS

  l_leg_count           NUMBER := 0;
  l_leg_complete	varchar2(10);
  l_update_flag		varchar2(1):='N';


  l_debug_on BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Process_Leg_Sequence';
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
      WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_UPDATE_del_FLAG',P_UPDATE_del_FLAG);
      WSH_DEBUG_SV.log(l_module_name,'P_UPDATE_leg_FLAG',P_UPDATE_leg_FLAG);
  END IF;


  Complete_Leg_Sequence
      ( p_delivery_id   => p_delivery_id,
        p_update_flag   => p_update_leg_flag,
        p_insert_msg    => false,
        x_leg_count     => l_leg_count,
        x_leg_complete  => l_leg_complete,
        x_return_status => x_return_status);

  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'After Call Complete_Leg_Sequence',x_return_status);
      WSH_DEBUG_SV.log(l_module_name,'l_leg_count',l_leg_count);
      WSH_DEBUG_SV.log(l_module_name,'l_leg_complete',l_leg_complete);
  END IF;

  IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
       IF (l_leg_complete = 'Y' ) THEN
          x_leg_complete := true;
          l_update_flag:='Y';
       ELSE
          x_leg_complete := false;
          l_update_flag:= null;
       END IF;


       IF (p_update_del_flag='Y') THEN
          UPDATE wsh_new_deliveries
            SET ITINERARY_COMPLETE = l_update_flag,
                last_update_date = sysdate,
                last_updated_by = FND_GLOBAL.USER_ID
          WHERE delivery_id= p_delivery_id;
       END IF;

  END IF;


  IF l_debug_on THEN
    IF (x_leg_complete) THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'x_leg_complete TRUE');
    ELSE
      WSH_DEBUG_SV.logmsg(l_module_name,'x_leg_complete FALSE');
    END IF;

    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
--
EXCEPTION
   WHEN others THEN
     wsh_util_core.default_handler('WSH_NEW_DELIVERY_ACTIONS.UPDATE_LEG_SEQUENCE');
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Process_Leg_Sequence;
-- J-IB-HEALI---}

--
-- Procedure: Generate_Loading_Seq
-- Parameters:  p_del_rows   - Delivery ids
--    x_return_status - status of procedure call
-- Description: This procedure is used to generate loading sequence for deliveries
--

  PROCEDURE Generate_Loading_Seq
    (p_del_rows   IN  wsh_util_core.id_tab_type,
     x_return_status  OUT NOCOPY  VARCHAR2) IS

  CURSOR loading_order (l_delivery_id NUMBER) IS
  SELECT loading_order_flag
  FROM   wsh_new_deliveries
  WHERE  delivery_id = l_delivery_id;

   -- Bug 1421549: Changed the logic for load sequencing
  cont_str VARCHAR2(1000) :=
  'SELECT dd.delivery_detail_id '||
  'FROM   wsh_delivery_details dd, '||
     'wsh_delivery_assignments_v da '||
  'WHERE  dd.delivery_detail_id = da.delivery_detail_id AND  '||
     'da.parent_delivery_detail_id = :cont_id AND '||
     'container_flag = ''N'' '||
  'ORDER  BY customer_prod_seq ';

-- This cursor fetches container_ids and average customer prod seq
-- numbers for lines in each container for a particular delivery. The
-- dynamic statement is used to add an ASC or DESC clause to the order by
-- based on Forward or Reverse loading order of the delivery

  stmt_str VARCHAR2(1000) :=
  'SELECT da.parent_delivery_detail_id, '||
    'avg(customer_prod_seq) avg_prod_seq, '||
    'count(*) '||
  'FROM   wsh_delivery_details dd, '||
    'wsh_delivery_assignments_v da '||
  'WHERE  dd.delivery_detail_id = da.delivery_detail_id AND '||
    'dd.customer_prod_seq IS NOT NULL AND '||
    'dd.container_flag = ''N'' AND '||
    'da.parent_delivery_detail_id IS NOT NULL AND '||
    'da.delivery_id IS NOT NULL AND '||
    'da.delivery_id = :del_id '||
  'GROUP BY parent_delivery_detail_id '||
  'ORDER BY avg_prod_seq ';

  TYPE detailcurtype IS REF CURSOR;
  TYPE contcurtype IS REF CURSOR;
  detailinfo_cv detailcurtype;
  continfo_cv contcurtype;

  l_cont_id  NUMBER;
  l_avg_prod_seq NUMBER;
  l_num_error   BINARY_INTEGER;
  l_cnt    BINARY_INTEGER;
  l_old_cnt  BINARY_INTEGER;
  l_lines_cnt   BINARY_INTEGER;
  l_order_flag  VARCHAR2(2);
  str1      VARCHAR2(5);
  cont1    VARCHAR2(5);
  l_delivery_detail_id NUMBER;
  l_cont_cnt  BINARY_INTEGER;

  others EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GENERATE_LOADING_SEQ';
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

  FOR i IN 1..p_del_rows.count LOOP

    OPEN  loading_order (p_del_rows(i));
    FETCH loading_order INTO l_order_flag;

     IF (loading_order%NOTFOUND) OR (l_order_flag IS NULL) THEN
    IF (loading_order%ISOPEN) THEN
       CLOSE loading_order;
      END IF;
    FND_MESSAGE.SET_NAME('WSH','WSH_DEL_INV_LOADING_ORDER');
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_del_rows(i)));
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    wsh_util_core.add_message(x_return_status);
    l_num_error := l_num_error + 1;
     goto loop_end;
     END IF;

    IF (loading_order%ISOPEN) THEN
      CLOSE loading_order;
     END IF;

-- Select containers for each delivery by ordering avg container prod seq num

    IF (l_order_flag = 'F') OR (l_order_flag = 'FI') THEN
    str1 := 'ASC';
     ELSE
    str1 := 'DESC';
    END IF;

     -- Bug 1421549: Changed the logic for load sequencing
     IF (l_order_flag = 'R') OR (l_order_flag = 'FI') THEN
     cont1 := 'DESC';
     ELSE
     cont1 := 'ASC';
     END IF;

    -- bug # 1716147. Fixed the incorrect messages issue
    l_cont_cnt  := 0;

    -- bug 3442398 moved this line from within the container loop to here
    l_cnt   := 0;

     OPEN detailinfo_cv FOR stmt_str || str1 USING p_del_rows(i);
    LOOP

      l_cont_id := null;

      FETCH detailinfo_cv INTO l_cont_id, l_avg_prod_seq, l_lines_cnt;

    -- Added by rvishnuv on 04/04/2001
    EXIT WHEN detailinfo_cv%NOTFOUND;

    l_cont_cnt  := l_cont_cnt + 1;


      -- Bug 1421549: Changed the logic for load sequencing
      OPEN  continfo_cv FOR cont_str || cont1 USING l_cont_id ;
      LOOP

      FETCH continfo_cv INTO l_delivery_detail_id ;

      EXIT WHEN continfo_cv%NOTFOUND;

      l_cnt := l_cnt + 1;

      UPDATE wsh_delivery_details
      SET load_seq_number = l_cnt
      WHERE  delivery_detail_id = l_delivery_detail_id;

      END LOOP;

    IF (l_cnt = 0) THEN
       IF (continfo_cv%ISOPEN) THEN
        CLOSE continfo_cv;
       END IF;
        FND_MESSAGE.SET_NAME('WSH','WSH_DEL_LOAD_SEQ_LINE_ERROR');
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       --
       FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_del_rows(i)));
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       wsh_util_core.add_message(x_return_status);
       l_num_error := l_num_error + 1;
       EXIT;
    END IF;

    IF (continfo_cv%ISOPEN) THEN
       CLOSE continfo_cv;
      END IF;

     END LOOP;

    IF (l_cont_cnt = 0) THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_DEL_LOAD_SEQ_CONT_ERROR');
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_del_rows(i)));
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    wsh_util_core.add_message(x_return_status);
    l_num_error := l_num_error + 1;
     END IF;


    IF (detailinfo_cv%ISOPEN) THEN
      CLOSE detailinfo_cv;
     END IF;

    <<loop_end>>
    null;

  END LOOP;

  IF (p_del_rows.count > 1) THEN
    IF (l_num_error > 0) THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_DEL_LOAD_SEQ_SUMMARY');
    FND_MESSAGE.SET_TOKEN('NUM_ERROR',l_num_error);
    FND_MESSAGE.SET_TOKEN('NUM_SUCCESS',p_del_rows.count - l_num_error);

    IF (p_del_rows.count = l_num_error) THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      ELSE
       x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      END IF;

    wsh_util_core.add_message(x_return_status);
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
    IF (continfo_cv%ISOPEN) THEN
       CLOSE continfo_cv;
      END IF;
    IF (detailinfo_cv%ISOPEN) THEN
       CLOSE detailinfo_cv;
    END IF;
     wsh_util_core.default_handler('WSH_NEW_DELIVERY_ACTIONS.GENERATE_LOADING_SEQ');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
  END Generate_Loading_Seq;


--
-- Procedure: Assign_Delivery_Update
-- Parameters:  p_delivery_id   - Delivery id
--       p_del_params - Parameters to update the delivery with
--    x_return_status - status of procedure call
-- Description: This procedure is used to update the delivery with grouping
--        attribute values from lines, while assigning lines to delivery
--

  PROCEDURE Assign_Delivery_Update
    (p_delivery_id    IN  NUMBER,
     p_del_params    IN   wsh_delivery_autocreate.grp_attr_rec_type,
     x_return_status  OUT NOCOPY  VARCHAR2) IS

  l_del_info wsh_new_deliveries_pvt.delivery_rec_type;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ASSIGN_DELIVERY_UPDATE';
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
      WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
  END IF;
  --
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.POPULATE_RECORD',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  wsh_new_deliveries_pvt.populate_record( p_delivery_id, l_del_info, x_return_status);

   IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
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
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_del_info.shipment_direction',l_del_info.shipment_direction);
    END IF;
    --

   IF NVL(l_del_info.shipment_direction,'O') IN ('O','IO')   -- J-IB-NPARIKH
   THEN
   --{
       -- Set optional grouping attributes for delivery.
       l_del_info.customer_id := nvl(l_del_info.customer_id, p_del_params.customer_id);
       l_del_info.intmed_ship_to_location_id := nvl(l_del_info.intmed_ship_to_location_id, p_del_params.intmed_ship_to_location_id);
       l_del_info.fob_code := nvl(l_del_info.fob_code, p_del_params.fob_code);
       l_del_info.freight_terms_code := nvl(l_del_info.freight_terms_code, p_del_params.freight_terms_code);
       l_del_info.ship_method_code := nvl(l_del_info.ship_method_code, p_del_params.ship_method_code);
       l_del_info.carrier_id := nvl(l_del_info.carrier_id, p_del_params.carrier_id);

       WSH_DELIVERY_AUTOCREATE.Create_Update_Hash(
               p_delivery_rec => l_del_info,
               x_return_status => x_return_status);


      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.UPDATE_DELIVERY',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      wsh_new_deliveries_pvt.update_delivery( null, l_del_info, x_return_status);

  --}
  END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  END Assign_Delivery_Update;

--
--
-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
--
-- finito  CArrier Selection FTE Integration Changes
-- **************************************************************************


-- J-IB-NPARIKH---{


-- ----------------------------------------------------------------------
-- Procedure:   update_freight_terms
-- Parameters:  p_delivery_id in  number
--              p_action_code   in varchar2
--                  'ASSIGN'  : Assign lines to delivery
--                  'UNASSIGN' : Unassign lines from delivery
--              p_line_freight_terms_code in varchar2
--                  NULL : Caller did not pass value
--                  'MIXED' : Lines assigned/unassigned have mixed/null freight terms
--                  Other value: All lines assigned/unassigned have same freight term , equal to this value
--              x_freight_terms_Code out varchar2
--                   Delivery's freight term code
-- Description: This procedure can be called after assign/unassign lines from delivery.
--
--              For action	ASSIGN :
--                   If delivery freight term is not null and new lines have different/null freight terms,
--                   update delivery freight term to NULL
--              For action	UNASSIGN :
--                   If delivery freight term is null and all existing lines in delivery have same freight
--                   term, update delivery with the same
--
--  ----------------------------------------------------------------------
PROCEDURE update_freight_terms
            (
               p_delivery_id             IN              NUMBER,
               p_action_code             IN              VARCHAR2 DEFAULT 'UNASSIGN',
               p_line_freight_terms_Code IN              VARCHAR2 DEFAULT NULL,
               x_freight_terms_Code      OUT    NOCOPY   VARCHAR2,
               x_return_status           OUT    NOCOPY   VARCHAR2
            )
IS
--{
    --
    -- Get delivery information
    --
    CURSOR dlvy_csr (p_delivery_id IN NUMBER)
    IS
        SELECT freight_terms_code, name,
               nvl(shipment_direction,'O') shipment_direction
        FROM   wsh_new_deliveries
        WHERE  delivery_id             = p_delivery_id;
    --
    --
    -- Lock delivery
    --
    CURSOR lock_dlvy_csr (p_delivery_id IN NUMBER)
    IS
        SELECT 1
        FROM   wsh_new_deliveries
        WHERE  delivery_id             = p_delivery_id
        FOR UPDATE OF freight_terms_code NOWAIT;
    --
    --
    CURSOR line_csr (p_delivery_id IN NUMBER)
    IS
        SELECT distinct freight_terms_code
        FROM   wsh_delivery_details wdd,
               wsh_delivery_assignments_v wda
        WHERE  wdd.delivery_detail_id      = wda.delivery_detail_id
        AND    wda.delivery_id             = p_delivery_id
        AND    NVL(wdd.container_flag,'N') = 'N';
    --
    l_has_lines               VARCHAR2(1);
    l_dlvy_freight_terms_code VARCHAR2(30);
    l_line_freight_terms_code VARCHAR2(30);
    l_shipment_direction      VARCHAR2(30);
    l_name                    VARCHAR2(100);
    l_cnt                     NUMBER;
    --
    e_locked exception  ;
    PRAGMA EXCEPTION_INIT(e_locked, -54);
    --
    e_end_of_api EXCEPTION;
    e_end_of_sub EXCEPTION;
    e_end_of_api1 EXCEPTION;
    --
    e_update     EXCEPTION;

    --
    l_debug_on                    BOOLEAN;
    --
    l_module_name        CONSTANT VARCHAR2(100) := 'wsh.plsql.' || g_pkg_name || '.' || 'update_freight_terms';
    --
--}
BEGIN
--{
    --
    l_debug_on := wsh_debug_interface.g_debug;
    --
    IF l_debug_on IS NULL THEN
      l_debug_on := wsh_debug_sv.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name);
      --
      wsh_debug_sv.LOG(l_module_name, 'P_DELIVERY_ID', p_delivery_id);
      wsh_debug_sv.LOG(l_module_name, 'p_action_code', p_action_code);
      wsh_debug_sv.LOG(l_module_name, 'p_line_freight_terms_Code', p_line_freight_terms_Code);
    END IF;
    --
    x_return_status := wsh_util_core.g_ret_sts_success;
    --
    --
    IF p_delivery_id IS NULL
    THEN
    --{
        --
        -- Delivery id is mandatory input
        --
        FND_MESSAGE.SET_NAME('WSH', 'WSH_REQUIRED_FIELD_NULL');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', 'p_delivery_id');
        RAISE FND_API.G_EXC_ERROR;
    --}
    END IF;
    --
    --
    OPEN dlvy_csr (p_delivery_id);
    --
    FETCH dlvy_csr
    INTO l_dlvy_freight_terms_code,l_name,l_shipment_direction;
    --
    IF dlvy_csr%NOTFOUND
    THEN
    --{
        --
        -- Raise error for invalid Delivery id
        --
        fnd_message.SET_name('WSH', 'WSH_DET_INVALID_DEL');
        RAISE FND_API.G_EXC_ERROR;
    --}
    END IF;
    --
    CLOSE dlvy_Csr;
    --
    --
    IF l_debug_on THEN
      wsh_debug_sv.LOG(l_module_name, 'l_dlvy_freight_terms_code', l_dlvy_freight_terms_code);
      wsh_debug_sv.LOG(l_module_name, 'l_name', l_name);
      wsh_debug_sv.LOG(l_module_name, 'l_shipment_direction', l_shipment_direction);
    END IF;
    --
    x_freight_terms_code := l_dlvy_freight_terms_code;
    --
    --
    IF l_shipment_direction IN ('O','IO')
    THEN
        --
        -- Operation not valid for outbound delivery
        --
        RAISE e_end_of_api;
    END IF;
    --
    FOR lock_dlvy_rec IN lock_dlvy_csr (p_delivery_id)
    LOOP
        NULL;
    END LOOP;
    --
    --
    BEGIN
    --{
        BEGIN
        --{
            IF  p_action_code='ASSIGN'
            THEN
            --{
                --
                IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_VALIDATIONS.has_lines',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                l_has_lines := WSH_DELIVERY_VALIDATIONS.has_lines
                                    (
                                        p_delivery_id => p_delivery_id
                                    );
                --
                --
                IF l_debug_on THEN
                  wsh_debug_sv.LOG(l_module_name, 'l_has_lines', l_has_lines);
                END IF;
                --
                --
                IF l_has_lines = 'Y'  -- If delivery has lines
                THEN
                --{

                    /*
                    IF l_dlvy_freight_terms_code IS NULL
                    THEN
                        RAISE e_end_of_api;
                    ELSE
                    --{
                    */
                        IF p_line_freight_terms_code IS NULL
                        THEN
                            --
                            -- Line-level freight terms not passed in.
                            -- We need to check delivery contents to determine the freight term
                            --
                            RAISE e_end_of_sub;
                        ELSIF p_line_freight_terms_code = NVL(l_dlvy_freight_terms_code,'MIXED')
                        THEN
                            --
                            -- Line-level freight terms is same as delivery's freight term
                            -- No need for any updates, goto end of api.
                            --
                            RAISE e_end_of_api;
                        ELSIF p_line_freight_terms_code = 'MIXED'
			                     THEN
                            --
                            -- Line-level freight terms are different.
                            -- We need to update delivery freight term to null
                            --
                            l_dlvy_freight_terms_code := NULL;
                            RAISE e_update;
                        ELSE
                            RAISE e_end_of_sub;
                        END IF;
                    --}
                    --END IF;

                --}
                /*--Assumption is that this api is called only after lines assigned to dlvy.
                ELSE
                --{
                    IF p_line_freight_terms_code IS NULL
                    THEN
                        RAISE e_end_of_api;
                    ELSIF p_line_freight_terms_code <> NVL(l_dlvy_freight_terms_code,'MIXED')
                    THEN
                        l_dlvy_freight_terms_code := p_line_freight_terms_code;
                        RAISE e_update;
                    ELSE
                        RAISE e_end_of_api;
                    END IF;
                --}
                */
                END IF;
            --}
            ELSIF p_action_code='UNASSIGN'
            THEN
            --{
                IF l_dlvy_freight_terms_code IS NOT NULL
                THEN
                    --
                    -- All lines in delivery have same freight term.
                    -- No need for update, goto end of api.
                    --
                    RAISE e_end_of_api1;
                END IF;
            --}
            END IF;
        --}
        EXCEPTION
            WHEN e_end_of_sub THEN
                NULL;
        END;
        --
        --
        l_dlvy_freight_terms_code := NULL;
        l_cnt                     := 0;
        --
        --
        -- Get distinct freight terms from delivery contents.
        -- If any line has null/different freight term, update delivery's freight term to Null.
        -- else  update delivery's freight term same as line's
        --
        FOR line_rec IN line_csr(p_delivery_id)
        LOOP
        --{
            l_cnt := l_cnt + 1;
            --
            --
            IF l_debug_on THEN
              wsh_debug_sv.LOG(l_module_name, 'line_rec.freight_Terms_code', line_rec.freight_Terms_code);
            END IF;
            --
            IF line_rec.freight_Terms_code IS NULL
            THEN
                l_dlvy_freight_terms_code := NULL;
                EXIT;
            ELSIF l_dlvy_freight_terms_code IS NULL
            THEN
                l_dlvy_freight_terms_code := line_rec.freight_Terms_code;
            ELSIF line_rec.freight_Terms_code <>  l_dlvy_freight_terms_code
            THEN
                l_dlvy_freight_terms_code := NULL;
                EXIT;
            END IF;
        --}
        END LOOP;
    --}
    EXCEPTION
        WHEN e_update THEN
            l_cnt := 1;
    END;
    --
    --
    IF l_cnt > 0
    THEN
    --{

        IF l_debug_on THEN
          wsh_debug_sv.LOGMSG(l_module_name, 'Updating delivery freight term to' || l_dlvy_freight_terms_code);
        END IF;
        --
        --OTM R12, this update here is done right after assign/unassign
        --of delivery lines, which means the
        --tms_interface_flag and tms_version_number should already be
        --reflecting the change in delivery,
        --no need to set them again.

        UPDATE wsh_new_deliveries
        SET    freight_terms_code = l_dlvy_freight_terms_code,
               last_update_date   = SYSDATE,
               last_updated_by    = FND_GLOBAL.USER_ID,
               last_update_login  = FND_GLOBAL.LOGIN_ID
        WHERE  delivery_id        = p_delivery_id;
        --
        IF (SQL%NOTFOUND)
        THEN
        --{
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            fnd_message.SET_name('WSH', 'WSH_DET_INVALID_DEL');
            RAISE FND_API.G_EXC_ERROR;
        --}
        END IF;
        --
        x_freight_terms_code := l_dlvy_freight_terms_code;

    --}
    END IF;
    --
    --
    IF l_debug_on THEN
      wsh_debug_sv.pop(l_module_name);
    END IF;
    --
--}
EXCEPTION
--{
    WHEN e_end_of_api THEN
        IF l_debug_on
        THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
    WHEN e_end_of_api1 THEN
        IF l_debug_on THEN
          wsh_debug_sv.LOGMSG(l_module_name, 'Updating delivery WHO columns ' );
        END IF;
        --
        UPDATE wsh_new_deliveries
        SET    last_update_date   = SYSDATE,
               last_updated_by    = FND_GLOBAL.USER_ID,
               last_update_login  = FND_GLOBAL.LOGIN_ID
        WHERE  delivery_id        = p_delivery_id;
        --
        IF (SQL%NOTFOUND)
        THEN
        --{
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            fnd_message.SET_name('WSH', 'WSH_DET_INVALID_DEL');
            WSH_UTIL_CORE.add_message (wsh_util_core.g_ret_sts_error,l_module_name);
        --}
        END IF;
        --
        IF l_debug_on
        THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := wsh_util_core.g_ret_sts_error;
        WSH_UTIL_CORE.add_message (wsh_util_core.g_ret_sts_error,l_module_name);
        --
        IF l_debug_on
        THEN
            WSH_DEBUG_SV.pop(l_module_name, 'EXCEPTION:FND_API.G_EXC_ERROR');
        END IF;
    WHEN e_locked THEN
        x_return_status := wsh_util_core.g_ret_sts_error;

        FND_MESSAGE.SET_NAME('WSH','WSH_DLVY_LOCK_FAILED');
        FND_MESSAGE.SET_TOKEN('ENTITY_NAME', l_name);
        WSH_UTIL_CORE.add_message (wsh_util_core.g_ret_sts_error,l_module_name);
        --
        IF l_debug_on
        THEN
            WSH_DEBUG_SV.pop(l_module_name, 'EXCEPTION:e_locked');
        END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      wsh_util_core.default_handler('WSH_NEW_DELIVERY_ACTIONS.update_freight_terms',l_module_name);
      --
      IF l_debug_on THEN
        wsh_debug_sv.pop(l_module_name, 'EXCEPTION:OTHERS');
      END IF;
--}
END update_freight_terms;
--
--
-- ----------------------------------------------------------------------
-- Procedure:   update_ship_from_location
--
-- Parameters:  p_delivery_id    Delivery ID
--              p_location_id    Ship from location ID (New value)
--              x_return_status  Return status of API
--
-- COMMENT   : This procedure is called from group API when
--             ship-from location is updated for inbound (not O/IO) delivery.
--
--             It performs the following steps:
--             01. Validate that input delivery id is not null and is a valid delivery.
--             02. Validate that input table of lines contain at least one record.
--             03. If delivery's ship-from location (current value) is not null(-1), return
--             04. Update ship-from location on all delivery lines.
--             05. Update ship-from location for stop associated with delivery's initial pickup location
--                 05.01 Make a call-out to FTE before stop update.
--             06. Update ship-from location for each delivery associated with same stop.
--             07. Put a warning message for each each delivery updated above.
--             08. Update ship-from location for lines of each delivery updated above.
--
--  ----------------------------------------------------------------------
--
PROCEDURE update_ship_from_location
            (
               p_delivery_id                 IN           NUMBER,
               p_location_id                 IN           NUMBER,
               x_return_status               OUT NOCOPY   VARCHAR2
            )
IS
--{
    --
    -- Get Delivery Info
    --
    CURSOR dlvy_csr (p_delivery_id IN NUMBER)
    IS
        SELECT wnd.name,
               initial_pickup_location_id
        FROM   wsh_new_deliveries wnd
        WHERE  delivery_id             = p_delivery_id;
    --
    l_dlvy_rec dlvy_csr%ROWTYPE;
    --
    --
    -- Get stop associated with initial pickup location of delivery.
    --
    CURSOR stop_csr(p_delivery_id IN NUMBER, p_location_id IN NUMBER)
    IS
        SELECT stop_id
        FROM   wsh_delivery_legs wdl,
               wsh_trip_stops    wts
        WHERE  wdl.delivery_id             = p_delivery_id
        AND    wdl.pick_up_stop_id         = wts.stop_id
        AND    wts.stop_location_id        = p_location_id;
    --
    --
    stop_rec stop_csr%ROWTYPE;
    --
    --
    -- Get all deliveries being picked up from the same stop.
    --
    CURSOR pickup_dlvy_csr (p_delivery_id IN NUMBER,p_stop_id IN NUMBER)
    IS
        SELECT wnd.delivery_id, wnd.name
        FROM   wsh_delivery_legs  wdl,
               wsh_new_deliveries wnd
        WHERE  pick_up_stop_id      = p_stop_id
        AND    wdl.delivery_id     <> p_delivery_id
        AND    wdl.delivery_id      = wnd.delivery_id;
    --
    --
    l_num_warnings                NUMBER := 0;
    l_num_errors                  NUMBER := 0;
    l_return_status               VARCHAR2(10);
    l_location_name               VARCHAR2(60);

    -- J+ Internal Location
    l_physical_stop_id            WSH_TRIP_STOPS.physical_stop_id%TYPE;
    l_physical_location_id        WSH_TRIP_STOPS.physical_location_id%TYPE;
    l_trip_id_tab                 wsh_util_core.id_tab_type;
    l_success_trip_ids            wsh_util_core.id_tab_type;
    -- End of J+ Internal Location
    l_stop_rec  WSH_TRIP_STOPS_PVT.TRIP_STOP_REC_TYPE;
    l_pub_stop_rec  WSH_TRIP_STOPS_PUB.TRIP_STOP_PUB_REC_TYPE;
    l_trip_rec  WSH_TRIPS_PVT.TRIP_REC_TYPE;
    --
    l_debug_on                    BOOLEAN;
    --
    l_module_name        CONSTANT VARCHAR2(100) := 'wsh.plsql.' || g_pkg_name || '.' || 'update_ship_from_location';
    --
--}
BEGIN
--{
    SAVEPOINT update_ship_from_location_sp;
    --
    l_debug_on := wsh_debug_interface.g_debug;
    --
    IF l_debug_on IS NULL THEN
      l_debug_on := wsh_debug_sv.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name);
      --
      wsh_debug_sv.LOG(l_module_name, 'P_DELIVERY_ID', p_delivery_id);
      wsh_debug_sv.LOG(l_module_name, 'p_location_id', p_location_id);
    END IF;
    --
    x_return_status := wsh_util_core.g_ret_sts_success;
    --
    --
    IF p_delivery_id IS NULL
    THEN
    --{
        --
        -- Delivery id is required field
        --
        FND_MESSAGE.SET_NAME('WSH', 'WSH_REQUIRED_FIELD_NULL');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', 'p_delivery_id');
        WSH_UTIL_CORE.add_message (wsh_util_core.g_ret_sts_error,l_module_name);
        --
        RAISE FND_API.G_EXC_ERROR;
    --}
    END IF;
    --
    --
    OPEN dlvy_csr(p_delivery_id);
    FETCH dlvy_csr INTO l_dlvy_rec;
    CLOSE dlvy_csr;
    --
    IF l_dlvy_rec.initial_pickup_location_id IS NULL
    THEN
    --{
        FND_MESSAGE.SET_NAME('WSH','WSH_DLVY_NOT_EXIST');
        FND_MESSAGE.SET_TOKEN('DELIVERY_ID', p_delivery_id);
        WSH_UTIL_CORE.add_message (wsh_util_core.g_ret_sts_error,l_module_name);
        --
        RAISE FND_API.G_EXC_ERROR;
    --}
    END IF;
    --
    --
    IF  l_dlvy_rec.initial_pickup_location_id  = WSH_UTIL_CORE.C_NULL_SF_LOCN_ID
    AND l_dlvy_rec.initial_pickup_location_id <> p_location_id
    THEN
    --{
        --
        -- Get stop associated with initial pickup location of delivery.
        --
        OPEN stop_csr(p_delivery_id,l_dlvy_rec.initial_pickup_location_id);
        FETCH stop_csr INTO stop_rec;
        CLOSE stop_csr;
        --
        /*
        UPDATE WSH_NEW_DELIVERIES
        SET    INITIAL_PICKUP_LOCATION_ID   = p_location_id,
               last_update_date             = SYSDATE,
               last_updated_by              = FND_GLOBAL.USER_ID,
               last_update_login            = FND_GLOBAL.LOGIN_ID
        WHERE  delivery_id                  = p_delivery_id;
        */
        --
        --
        UPDATE WSH_DELIVERY_DETAILS
        SET    SHIP_FROM_LOCATION_ID        = p_location_id,
               last_update_date             = SYSDATE,
               last_updated_by              = FND_GLOBAL.USER_ID,
               last_update_login            = FND_GLOBAL.LOGIN_ID
        WHERE  delivery_detail_id IN (
                                        SELECT delivery_detail_id
                                        FROM   wsh_delivery_assignments_v
                                        WHERE  delivery_id = p_delivery_id
                                     );
        --
        --
        IF stop_rec.stop_id IS NOT NULL
        THEN
        --{
               -- Get pvt type record structure for stop
               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_GRP.GET_STOP_DETAILS_PVT',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               --
               wsh_trip_stops_grp.get_stop_details_pvt
               (p_stop_id => stop_rec.stop_id,
               x_stop_rec => l_stop_rec,
               x_return_status => l_return_status);
                --
                wsh_util_core.api_post_call
                  (
                    p_return_status => l_return_status,
                    x_num_warnings  => l_num_warnings,
                    x_num_errors    => l_num_errors
                  );
                --
            -- Internal Locations J+
            -- Derive the physical location id
            IF l_stop_rec.stop_location_id <> p_location_id THEN -- New Location id
              IF l_debug_on THEN
                wsh_debug_sv.logmsg(l_module_name,'stop location id has been changed');
              END IF;
              -- Derive physical Location id for this new location
              WSH_LOCATIONS_PKG.Convert_internal_cust_location(
                p_internal_cust_location_id => p_location_id,
                x_internal_org_location_id  => l_physical_location_id, -- New physical Location id
                x_return_status             => l_return_status);

              IF l_debug_on THEN
                wsh_debug_sv.log(l_module_name,'New stop_location_id' , p_location_id);
                wsh_debug_sv.log(l_module_name,'Derived physical_location_id' , l_physical_location_id);
              END IF;
              -- delink the physical stop id
              IF nvl(l_stop_rec.physical_location_id, -99) <> nvl(l_physical_location_id, -99) THEN
                l_stop_rec.physical_stop_id := NULL;
                -- Nullify the physical stop id
                l_physical_stop_id := NULL;
                l_stop_rec.physical_location_id := l_physical_location_id; -- Populate record structure
              END IF;
            END IF;
            -- End of Internal Locations J+
               --
               /* H integration - call Multi Leg FTE */
            IF (WSH_UTIL_CORE.FTE_IS_INSTALLED = 'Y') THEN
               -- Code changes made in J+ along with Internal Locations
               -- Update the Input record structure which FTE uses to validate
               -- the new stop location
               l_stop_rec.stop_location_id := p_location_id;
               -- End of Code changes made in J+
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
                wsh_util_core.api_post_call
                  (
                    p_return_status => l_return_status,
                    x_num_warnings  => l_num_warnings,
                    x_num_errors    => l_num_errors
                  );
                --
            END IF;
            --
            --
            -- J+ Internal Locations, along with new location, update
            -- physical_stop_id and physical_location_id
            UPDATE wsh_trip_stops
            SET    stop_location_id             = p_location_id,
                   last_update_date             = SYSDATE,
                   last_updated_by              = FND_GLOBAL.USER_ID,
                   last_update_login            = FND_GLOBAL.LOGIN_ID,
                   physical_stop_id             = l_physical_stop_id, -- J+ Internal Locations
                   physical_location_id         = l_physical_location_id -- J+ Internal Locations
            WHERE  stop_id                      = stop_rec.stop_id;
            --

            -- Internal Locations J+
            -- Call Handle Internal Stops API to link the stops
            l_trip_id_tab(1) := l_stop_rec.trip_id;
            IF l_debug_on THEN
              wsh_debug_sv.log(l_module_name,'trip_id' , l_stop_rec.trip_id);
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_ACTIONS.Handle_Internal_Stops',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

            WSH_TRIPS_ACTIONS.Handle_Internal_Stops(
                   p_trip_ids          => l_trip_id_tab,
                   p_caller            => 'WSH_UPDATE_SHIP_FROM_LOC',
                   x_success_trip_ids  => l_success_trip_ids,
                   x_return_status     => l_return_status);

            wsh_util_core.api_post_call(
                   p_return_status => l_return_status,
                   x_num_warnings  => l_num_warnings,
                   x_num_errors    => l_num_errors);
            -- End of Internal Locations J+
            --

            l_location_name := NULL;
            --
            --
            -- Get all deliveries being picked up from the same stop.
            --
            FOR pickup_dlvy_rec IN pickup_dlvy_csr (p_delivery_id , stop_rec.stop_id)
            LOOP
            --{
                --OTM R12, this update is called by inbound so we
                --will not check tms flag here
                UPDATE WSH_NEW_DELIVERIES
                SET    INITIAL_PICKUP_LOCATION_ID   = p_location_id,
                       last_update_date             = SYSDATE,
                       last_updated_by              = FND_GLOBAL.USER_ID,
                       last_update_login            = FND_GLOBAL.LOGIN_ID
                WHERE  delivery_id                  = pickup_dlvy_rec.delivery_id;
                --
                --
                UPDATE WSH_DELIVERY_DETAILS
                SET    SHIP_FROM_LOCATION_ID        = p_location_id,
                       last_update_date             = SYSDATE,
                       last_updated_by              = FND_GLOBAL.USER_ID,
                       last_update_login            = FND_GLOBAL.LOGIN_ID
                WHERE  delivery_detail_id IN (
                                                SELECT delivery_detail_id
                                                FROM   wsh_delivery_assignments_v
                                                WHERE  delivery_id = pickup_dlvy_rec.delivery_id
                                             );
                --
                --
                IF l_location_name IS NULL
                THEN
                --{
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.get_location_description',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    l_location_name := SUBSTRB(
                                                WSH_UTIL_CORE.get_location_description
                                                  (
                                                    p_location_id,
                                                    'NEW UI CODE'
                                                  ),
                                                1,
                                                60
                                              );
                --}
                END IF;
                --
                --
                FND_MESSAGE.SET_NAME('WSH','WSH_DLVY_PU_LOCN_UPDATE');
                FND_MESSAGE.SET_TOKEN('DELIVERY_NAME', pickup_dlvy_rec.name);
                FND_MESSAGE.SET_TOKEN('LOCATION_NAME', l_location_name);
                WSH_UTIL_CORE.add_message (wsh_util_core.g_ret_sts_warning,l_module_name);
                l_num_warnings := l_num_warnings + 1;
            --}
            END LOOP;
        --}
        END IF;
    --}
    END IF;
    --
    --
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
    IF l_debug_on THEN
      wsh_debug_sv.pop(l_module_name);
    END IF;
    --
--}
EXCEPTION
--{
      --
    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO  update_ship_from_location_sp;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO  update_ship_from_location_sp;
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

        ROLLBACK TO  update_ship_from_location_sp;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
        wsh_util_core.default_handler('WSH_NEW_DELIVERY_ACTIONS.update_ship_from_location', l_module_name);
        IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
--}
END update_ship_from_location;

-- J-IB-NPARIKH---}

-- Look for Open deliveries in Trip
-- If any delivery exists with status = OPEN in the trip ,then RETURN FALSE
-- If no open delivery exists ,then RETURN TRUE
FUNCTION check_last_del_trip(p_delivery_id IN NUMBER)
 return BOOLEAN IS

-- First row found is enough

-- bug 4891897, sql 15038247
-- 1) wsh_delivery_trips_v is replaced with the join of
--    wsh_delivery_legs and wsh_trip_stops
-- 2) query is flattened instead of using the subquery for lower sharable memory

  CURSOR Check_Last_Trip (l_delivery_id NUMBER) IS
  SELECT s1.trip_id
    FROM wsh_trip_stops s1,
         wsh_delivery_legs dl1,
         wsh_new_deliveries d1,
         wsh_trip_stops s2,
         wsh_delivery_legs dl2
   WHERE d1.delivery_id <> l_delivery_id
     AND s1.stop_id = dl1.pick_up_stop_id
     AND d1.delivery_id = dl1.delivery_id
     AND d1.status_code = 'OP'
     AND d1.delivery_type = 'STANDARD'
     AND s2.trip_id = s1.trip_id
     AND s2.stop_id = dl2.pick_up_stop_id
     AND dl2.delivery_id = l_delivery_id
     AND rownum = 1;

  l_trip_id NUMBER;

    l_debug_on                    BOOLEAN;
    --
    l_module_name        CONSTANT VARCHAR2(100) := 'wsh.plsql.' || g_pkg_name || '.' || 'check_last_del_trip';
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
    --
   --
    wsh_debug_sv.LOG(l_module_name, 'P_DELIVERY_ID', p_delivery_id);
  END IF;

  OPEN check_last_trip(p_delivery_id);
  FETCH check_last_trip
   INTO l_trip_id;
  CLOSE check_last_trip;

  IF l_trip_id IS NOT NULL THEN -- found a open delivery
    IF l_debug_on THEN
      wsh_debug_sv.LOGMSG(l_module_name, 'Last Del on Trip-' || l_trip_id);
      wsh_debug_sv.pop(l_module_name);
    END IF;
    return FALSE;
  ELSE  -- no open delivery
    IF l_debug_on THEN
      wsh_debug_sv.LOGMSG(l_module_name, 'THIS IS LAST OPEN DELIVERY on TRIP');
      wsh_debug_sv.pop(l_module_name);
    END IF;
    return TRUE;
  END IF;

  IF l_debug_on THEN
    wsh_debug_sv.pop(l_module_name);
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    wsh_util_core.default_handler('wsh_new_delivery_actions.check_last_del_trip',l_module_name);
      --
    IF l_debug_on THEN
      wsh_debug_sv.pop(l_module_name, 'EXCEPTION:OTHERS');
    END IF;
    RETURN FALSE;
END check_last_del_trip;

-- ---------------------------------------------------------------------------
-- NAME:                GET_TRIP_STATUS
-- TYPE:                FUNCTION
-- PARAMETERS(IN):      p_delivery_id IN  NUMBER
--
-- RETURN:              MANY     - delivery is assigned to more than one trip
--                      SHARED   - trip to which this delivery is assigned is
--                                 shared with other deliveries
--                      HAS_LANE - trip to which this delivery is assigned has
--                                 Lane/Service assigned
--                      NONE     - delivery is not assigned to a trip
--                      ONE      - delivery is assigned to one trip and this
--                                 trip is not shared with other deliveries
-- DESCRIPTION:         get the relationship between the delivery and the trip
--
-- CALLED FROM PROCESS_CARRIER_SELECTION
-- ADDED BY HJPARK AS PART OF 11i10+ ENHANCEMENT 9/20/2004
-- ---------------------------------------------------------------------------
FUNCTION get_trip_status(p_delivery_id IN NUMBER,p_delivery_type IN VARCHAR2) return VARCHAR2 IS
--FUNCTION GET_TRIP_STATUS(p_delivery_id IN NUMBER) return VARCHAR2 IS

  l_debug_on        BOOLEAN;
  l_module_name     CONSTANT VARCHAR2(100) := 'wsh.plsql.'||g_pkg_name||'.'||'get_trip_status';

  l_count           NUMBER;
  l_delivery_leg_id NUMBER;
  l_trip_id         NUMBER;
  l_lane_id         NUMBER;

  CURSOR check_many_trips(x_delivery_id NUMBER) IS
  SELECT count(delivery_leg_id), min(delivery_leg_id)
    FROM wsh_delivery_legs
   WHERE delivery_id = x_delivery_id;

  CURSOR check_shared_trip(x_delivery_leg_id NUMBER) IS
  SELECT count(s.trip_id ), min(s.trip_id)
    FROM wsh_delivery_legs d, wsh_trip_stops s
   WHERE d.pick_up_stop_id = s.stop_id
     AND s.trip_id = (SELECT s1.trip_id
                        FROM wsh_trip_stops s1, wsh_delivery_legs d1
                       WHERE d1.delivery_leg_id = x_delivery_leg_id
                         AND s1.stop_id = d1.pick_up_stop_id);

  -- Hiding project
  -- count('CONSOLIDATION') should be 1

  CURSOR check_shared_trip_consol(x_delivery_leg_id NUMBER) IS
  SELECT count(*), min(s.trip_id)
  FROM wsh_new_deliveries n, wsh_delivery_legs d, wsh_trip_stops s
   WHERE n.delivery_id = d.delivery_id
     AND d.pick_up_stop_id = s.stop_id
     AND s.trip_id = (SELECT s1.trip_id
                        FROM wsh_trip_stops s1, wsh_delivery_legs d1
                       WHERE d1.delivery_leg_id = x_delivery_leg_id
                         AND s1.stop_id = d1.pick_up_stop_id)
     AND d.parent_delivery_leg_id IS NULL;

  CURSOR check_trip_lane(x_trip_id NUMBER) IS
  SELECT lane_id
    FROM wsh_trips
   WHERE trip_id = x_trip_id;

BEGIN

  l_debug_on := wsh_debug_interface.g_debug;
  IF l_debug_on IS NULL THEN
    l_debug_on := wsh_debug_sv.is_debug_enabled;
  END IF;
  IF l_debug_on THEN
    wsh_debug_sv.push(l_module_name);
    wsh_debug_sv.LOG(l_module_name, 'P_DELIVERY_ID', p_delivery_id);
  END IF;

  -- checks whether the delivery is assigned to a trip

  OPEN check_many_trips(p_delivery_id);
  FETCH check_many_trips INTO l_count, l_delivery_leg_id;
  CLOSE check_many_trips;

  IF (l_count = 0) THEN
    -- delivery is not assigned to a trip
    IF l_debug_on THEN
      wsh_debug_sv.LOGMSG(l_module_name, 'NONE');
      wsh_debug_sv.pop(l_module_name);
    END IF;
    return 'NONE';
  ELSIF (l_count > 1) THEN
    -- delivery is assigned to more than one trip
    IF l_debug_on THEN
      wsh_debug_sv.LOGMSG(l_module_name, 'MANY');
      wsh_debug_sv.pop(l_module_name);
    END IF;
    return 'MANY';
  END IF;


  -- comes here when the delivery is assigned to only one trip
  -- checks whether the trip is shared by more than one delivery

  IF p_delivery_type = 'CONSOLIDATION' THEN

  -- Hiding project
  -- A consol delivery can be assigned to only 1 trip
  -- But the trip can have other consol / regular / content deliveries on that trip
  -- The action should be allowed only if other deliveries in this trip
  -- are only the child content deliveries of this consol delivery

  OPEN check_shared_trip_consol(l_delivery_leg_id);
  FETCH check_shared_trip_consol INTO l_count,l_trip_id;
  CLOSE check_shared_trip_consol;

  IF (l_count > 1) THEN
    -- trip is shared by more than one delivery - Error
    IF l_debug_on THEN
      wsh_debug_sv.LOGMSG(l_module_name, 'SHARED');
      wsh_debug_sv.pop(l_module_name);
    END IF;
    return 'SHARED';
  END IF;

  ELSE

  OPEN check_shared_trip(l_delivery_leg_id);
  FETCH check_shared_trip INTO l_count, l_trip_id;
  CLOSE check_shared_trip;

  IF (l_count > 1) THEN
    -- trip is shared by more than one delivery - Error
    IF l_debug_on THEN
      wsh_debug_sv.LOGMSG(l_module_name, 'SHARED');
      wsh_debug_sv.pop(l_module_name);
    END IF;
    return 'SHARED';
  END IF;

  END IF;
  -- comes here when the trip is used only by this delivery, hence 1:1
  -- checks whether trip has lane assigned

  OPEN check_trip_lane(l_trip_id);
  FETCH check_trip_lane INTO l_lane_id;
  CLOSE check_trip_lane;

  IF l_lane_id is not NULL
  THEN
    IF l_debug_on THEN
      wsh_debug_sv.LOGMSG(l_module_name, 'HAS_LANE');
      wsh_debug_sv.pop(l_module_name);
    END IF;
    return 'HAS_LANE';
  ELSE
    IF l_debug_on THEN
      wsh_debug_sv.LOGMSG(l_module_name, 'ONE-'||l_trip_id);
      wsh_debug_sv.pop(l_module_name);
    END IF;
    return 'ONE-'||l_trip_id;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    wsh_util_core.default_handler('wsh_new_delivery_actions.get_trip_status',l_module_name);
      --
    IF l_debug_on THEN
      wsh_debug_sv.pop(l_module_name, 'EXCEPTION:OTHERS');
    END IF;

END GET_TRIP_STATUS;

--SBAKSHI(R12)
--***************************************************************************--
--========================================================================
-- FUNCTION  :  IS_DLVY_CONTENT      PRIVATE
--
-- PARAMETERS: p_delivery_id		Delivery Id
--
-- COMMENT   : Returns True if the delivery is content
--
--***************************************************************************--
FUNCTION IS_DLVY_CONTENT(p_delivery_id IN NUMBER)
	RETURN BOOLEAN
IS

/*
	When we query for a parent delivery of a delivery we
	should always use wsh_delivery_legs instead of wsh_delivery_assignments.
	If the child delivery does not have any lines attached to it,
	it will not have record in wda, whereas a console delivery and
	its children will always have a trip, and a record in wdl.
*/

CURSOR c_get_console_delivery (c_delivery_id IN NUMBER) IS
select pleg.delivery_id
from   wsh_delivery_legs pleg,
       wsh_delivery_legs cleg
where  pleg.delivery_leg_id = cleg.parent_delivery_leg_id
and    cleg.delivery_id = c_delivery_id;

l_delivery_id		NUMBER;
l_content_dlvy		BOOLEAN := FALSE;

l_debug_on         CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name      CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'IS_DLVY_CONTENT';

BEGIN

        --
        IF l_debug_on THEN
	       wsh_debug_sv.push (l_module_name);
        END IF;
        --

	OPEN  c_get_console_delivery(p_delivery_id) ;
	FETCH c_get_console_delivery INTO l_delivery_id;

	IF (l_delivery_id IS NOT NULL) THEN
		-- The dlvy is assigned to a console delivery
		l_content_dlvy := TRUE;
	END IF;
	CLOSE c_get_console_delivery;

	--
        IF l_debug_on THEN
	     wsh_debug_sv.pop(l_module_name);
        END IF;
        --
	RETURN l_content_dlvy;

EXCEPTION
WHEN OTHERS THEN

      IF c_get_console_delivery%ISOPEN THEN
         CLOSE c_get_console_delivery;
      END IF;

      WSH_UTIL_CORE.default_handler('WSH_NEW_DELIVERY_ACTIONS.IS_DLVY_CONTENT');
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;

END IS_DLVY_CONTENT;

--***************************************************************************--
--========================================================================
-- PROCEDURE : GET_SHIP_TO_SITE       PRIVATE
--
-- PARAMETERS: p_delivery_id	      Delivery Id
--	       x_site_id	      Customer Site Id.
--             x_return_status	      Return Status
--
-- COMMENT   : Returns the ship to site associated with the delivery.
--
--***************************************************************************--
PROCEDURE GET_SHIP_TO_SITE(p_delivery_id	IN	   NUMBER,
                           p_delivery_type      IN         VARCHAR2  DEFAULT NULL,
                           p_ultimate_dropoff_loc_id  IN NUMBER DEFAULT NULL,
			   x_site_id		OUT NOCOPY NUMBER,
			   x_return_status	OUT NOCOPY VARCHAR2)
IS

CURSOR c_get_ship_to_site IS
SELECT DISTINCT wdd.ship_to_site_use_id
FROM   wsh_delivery_details wdd,
       wsh_delivery_assignments wda
WHERE  wda.delivery_detail_id  =  wdd.delivery_detail_id
AND    wda.delivery_id         =  p_delivery_id
AND    wdd.ship_to_site_use_id IS NOT NULL;

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

l_site_tab			WSH_UTIL_CORE.ID_TAB_TYPE;
multiple_ship_to_site		EXCEPTION;
no_ship_to_site			EXCEPTION;

l_debug_on         CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name      CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_SHIP_TO_SITE';

BEGIN

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	--
        IF l_debug_on THEN
	       wsh_debug_sv.push (l_module_name);
        END IF;
	--

        IF p_delivery_type = 'STANDARD' THEN

	OPEN  c_get_ship_to_site;
	FETCH c_get_ship_to_site BULK COLLECT INTO l_site_tab;
	CLOSE c_get_ship_to_site;

	IF (l_site_tab.COUNT = 1) THEN
		x_site_id := l_site_tab(l_site_tab.FIRST);
	ELSIF (l_site_tab.COUNT = 0 ) THEN
		RAISE NO_SHIP_TO_SITE;
	ELSE
		RAISE MULTIPLE_SHIP_TO_SITE;
	END IF;

        ELSIF p_delivery_type = 'CONSOLIDATION' THEN

        OPEN c_ship_to_site_use(p_ultimate_dropoff_loc_id);
        FETCH c_ship_to_site_use INTO x_site_id;
        IF c_ship_to_site_use%NOTFOUND THEN
            x_site_id := NULL;
        END IF;
        CLOSE c_ship_to_site_use;

        END IF;


	--
	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;
        --
EXCEPTION

WHEN NO_SHIP_TO_SITE THEN
	 -- Delivery is not assoociated with a site.
	IF l_debug_on THEN
          wsh_debug_sv.logmsg(l_module_name, 'Delivery is not assoociated with a site');
	END IF;
	 FND_MESSAGE.SET_NAME('WSH','WSH_DLVY_NO_SITE');
         FND_MESSAGE.Set_Token('DELIVERY',p_delivery_id);
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	 WSH_UTIL_CORE.add_message(x_return_status);

	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;

WHEN MULTIPLE_SHIP_TO_SITE THEN

	 -- Delivery is associated with multiple sites
	IF l_debug_on THEN
          wsh_debug_sv.logmsg(l_module_name, 'Delivery is not assoociated with multiple sites');
	END IF;
	 FND_MESSAGE.SET_NAME('WSH','WSH_DLVY_MULT_SITE');
         FND_MESSAGE.Set_Token('DELIVERY',p_delivery_id);
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	 WSH_UTIL_CORE.add_message(x_return_status);

	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;

WHEN OTHERS THEN

	IF ( c_get_ship_to_site%ISOPEN) THEN
		CLOSE c_get_ship_to_site;
	END IF;
	--
        WSH_UTIL_CORE.default_handler('WSH_NEW_DELIVERY_ACTIONS.get_ship_to_site');
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
        --

	IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
        END IF;
       --
END GET_SHIP_TO_SITE;


--***************************************************************************--
--========================================================================
-- PROCEDURE : GET_SHIP_TO_CUSTOMER   PRIVATE
--
-- PARAMETERS:  p_ult_dropoff_loc_id   Drop off location id.
--		p_delivery_id	       Delivery Id.
--	        x_customer_id	       Customer Id.
--              x_return_status	       Return Status
--
-- COMMENT   : Returns the customer associated with the given location.
--
--***************************************************************************--
PROCEDURE GET_SHIP_TO_CUSTOMER( p_ult_dropoff_loc_id	IN  	   NUMBER,
				p_delivery_id		IN	   NUMBER,
				x_customer_id		OUT NOCOPY NUMBER,
				x_return_status		OUT NOCOPY VARCHAR2)
IS

CURSOR c_get_shipto_cust_from_loc (p_location_id IN NUMBER) IS
SELECT hcas.cust_account_id
FROM   wsh_locations wl,
       hz_party_sites hps,
       hz_cust_acct_sites_all hcas
WHERE  wl.wsh_location_id = p_location_id
AND    wl.location_source_code = 'HZ'
AND    wl.source_location_id = hps.location_id
AND    hps.party_site_id = hcas.party_site_id;


CURSOR c_get_shipto_cust_from_dlvy(p_delivery_id IN NUMBER) IS
SELECT distinct hcas.cust_account_id
FROM   hz_cust_site_uses_all hcsu,
       hz_cust_acct_sites_all hcas
 WHERE hcsu.cust_acct_site_id = hcas.cust_acct_site_id
 AND   hcsu.site_use_id IN (SELECT DISTINCT wdd.ship_to_site_use_id
			    FROM   wsh_delivery_details wdd,
				   wsh_delivery_assignments wda
 		            WHERE  wda.delivery_detail_id  = wdd.delivery_detail_id
		            AND     wda.delivery_id        = p_delivery_id);


l_cust_tab		WSH_UTIL_CORE.ID_TAB_TYPE;
no_cust_for_loc		EXCEPTION;
mult_cust_for_loc	EXCEPTION;

l_debug_on		CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name		CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_SHIP_TO_CUSTOMER';

BEGIN

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	--
        IF l_debug_on THEN
	       wsh_debug_sv.push (l_module_name);
        END IF;
	--

	OPEN  c_get_shipto_cust_from_loc(p_ult_dropoff_loc_id);
	FETCH c_get_shipto_cust_from_loc BULK COLLECT INTO l_cust_tab;
	CLOSE c_get_shipto_cust_from_loc;

	IF (l_cust_tab.COUNT=1) THEN
		x_customer_id := l_cust_tab(l_cust_tab.FIRST);
	ELSIF (l_cust_tab.COUNT = 0) THEN
		-- Location is not associated with a customer.
		RAISE NO_CUST_FOR_LOC;
	ELSE
		-- Multiple records have been returned.
		-- For the delivery get the delivery lines and use ship to site id
		-- to return the customer. check that each has the same customer.
		OPEN  c_get_shipto_cust_from_dlvy(p_delivery_id);
		FETCH c_get_shipto_cust_from_dlvy BULK COLLECT INTO l_cust_tab;
		CLOSE c_get_shipto_cust_from_dlvy;

		IF (l_cust_tab.COUNT=1) THEN
			x_customer_id := l_cust_tab(l_cust_tab.FIRST);
		ELSIF (l_cust_tab.COUNT=0) THEN
			RAISE NO_CUST_FOR_LOC;
		ELSE
			RAISE MULT_CUST_FOR_LOC;
		END IF;
	END IF;

	--
	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;
        --
EXCEPTION

	WHEN NO_CUST_FOR_LOC THEN
		IF l_debug_on THEN
                  wsh_debug_sv.logmsg(l_module_name, 'Location not associated with a customer');
		END IF;
		  -- Location not associated with a customer.
		 FND_MESSAGE.SET_NAME('WSH','WSH_CUST_NO_LOC');
         FND_MESSAGE.SET_TOKEN('DELIVERY',p_delivery_id);
		 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		 WSH_UTIL_CORE.add_message(x_return_status);

		IF l_debug_on THEN
		      WSH_DEBUG_SV.pop(l_module_name);
		END IF;
	WHEN MULT_CUST_FOR_LOC THEN
		 -- Location  associated with a multiple customers.
		IF l_debug_on THEN
                  wsh_debug_sv.logmsg(l_module_name, 'Location associated with multiple customers');
		END IF;
		 FND_MESSAGE.SET_NAME('WSH','WSH_CUST_MULT_LOC');
         FND_MESSAGE.SET_TOKEN('DELIVERY',p_delivery_id);
		 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		 WSH_UTIL_CORE.add_message(x_return_status);

		IF l_debug_on THEN
		      WSH_DEBUG_SV.pop(l_module_name);
		END IF;
	WHEN OTHERS THEN
		IF (c_get_shipto_cust_from_loc%ISOPEN) THEN
			CLOSE c_get_shipto_cust_from_loc;
		END IF;

		IF (c_get_shipto_cust_from_dlvy%ISOPEN) THEN
			CLOSE c_get_shipto_cust_from_dlvy;
		END IF;
		--
		WSH_UTIL_CORE.default_handler('WSH_NEW_DELIVERY_ACTIONS.get_ship_to_customer');
	        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
	        --
  		IF l_debug_on THEN
	          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		  WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
		END IF;
		--
END GET_SHIP_TO_CUSTOMER;

---------------------------------------------------------------------------------------
-- Procedure:   SET_PICK_UP_DROP_OFF_DATES
--
-- Parameters:  p_cs_mleg_result_tab     IN OUT table
--              x_return_message            Return Message
--              x_return_status             Return Status
--
-- COMMENT   : This procedure is called from Process_carrier_selection API
--		in order to get pick up and drop off dates for intermediate stops.
--		If Carrier selection API returns multileg output, the dates have to
--      determined.
--
--      Logic for determining the dates:
--
--      a) Find transit time between delivery leg's pick up and drop off stops
--      b) If transit time found
--          i. drop off date = pick up date +transit time
--      c) if transit time is not found, calculate total time between deliveries
--          pick up and drop off stops and divide it equally amongst all the delivery legs.
--
--  ----------------------------------------------------------------------

PROCEDURE SET_PICK_UP_DROP_OFF_DATES(
        p_cs_mleg_result_tab  IN OUT NOCOPY WSH_FTE_INTEGRATION.WSH_CS_RESULT_TAB_TYPE,
        x_return_status          OUT NOCOPY VARCHAR2,
        x_msg_count              OUT NOCOPY NUMBER,
        x_msg_data               OUT NOCOPY VARCHAR2
) IS

transit_time                NUMBER;
transit_time_found          BOOLEAN := TRUE;
from_location_id            NUMBER;
to_location_id              NUMBER;
ship_method                 VARCHAR2(60);
num_legs                    NUMBER;
num_days                    NUMBER;
num_hours                   NUMBER;
days_fraction               NUMBER;
rec_cnt                     NUMBER;
rec_cnt_prior               NUMBER;
pick_up_date                DATE;
drop_off_date               DATE;
initial_pick_up_date        DATE;
ultimate_drop_off_date      DATE;
d_itr                       NUMBER;

l_debug_on                  BOOLEAN;

l_module_name               CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SET_PICK_UP_DROP_OFF_DATES';

CURSOR get_transit_time(p_from_location_id  NUMBER,
                        p_to_location_id NUMBER,
                        p_ship_method VARCHAR2) IS

SELECT INTRANSIT_TIME
FROM MTL_INTERORG_SHIP_METHODS
WHERE FROM_LOCATION_ID = p_from_location_id
AND TO_LOCATION_ID = p_to_location_id
AND SHIP_METHOD = p_ship_method;

BEGIN
--{
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

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
    -- Obtain number of delivery legs, initial pick up date and ultimate drop off date for the delivery
    --

    num_legs := p_cs_mleg_result_tab.COUNT;
    initial_pick_up_date    := p_cs_mleg_result_tab(p_cs_mleg_result_tab.FIRST).pickup_date;
    ultimate_drop_off_date  := p_cs_mleg_result_tab(p_cs_mleg_result_tab.LAST).dropoff_date;

    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'No of legs :'||num_legs);
        WSH_DEBUG_SV.logmsg(l_module_name,'initial_pick_up_date :'||to_char(initial_pick_up_date, 'dd/mm/yyyy hh:mi:ss'));
        WSH_DEBUG_SV.logmsg(l_module_name,'ultimate_drop_off_date :'||to_char(ultimate_drop_off_date, 'dd/mm/yyyy hh:mi:ss'));
    END IF;


    rec_cnt := p_cs_mleg_result_tab.FIRST;

    IF rec_cnt IS NOT NULL THEN
        IF initial_pick_up_date = ultimate_drop_off_date   THEN
            LOOP
                rec_cnt_prior := p_cs_mleg_result_tab.PRIOR(rec_cnt);

                IF rec_cnt = p_cs_mleg_result_tab.FIRST THEN -- At first record
                    pick_up_date := initial_pick_up_date;
                ELSIF p_cs_mleg_result_tab(rec_cnt_prior).dropoff_date IS NOT NULL THEN
                    -- pick up date is one hour more than drop off date of last stop
                    pick_up_date := p_cs_mleg_result_tab(rec_cnt_prior).dropoff_date + 1/24;
                END IF;

                drop_off_date := pick_up_date + 1/144;

                p_cs_mleg_result_tab(rec_cnt).pickup_date := pick_up_date;
                p_cs_mleg_result_tab(rec_cnt).dropoff_date := drop_off_date;

                EXIT WHEN rec_cnt = p_cs_mleg_result_tab.LAST OR rec_cnt IS NULL;
                rec_cnt := p_cs_mleg_result_tab.NEXT(rec_cnt);
            END LOOP;
        ELSE


            --IF rec_cnt IS NOT NULL THEN

                LOOP
                --{
                    transit_time := null;
                    rec_cnt_prior := p_cs_mleg_result_tab.PRIOR(rec_cnt);

                    IF rec_cnt = p_cs_mleg_result_tab.FIRST THEN -- At first record
                        pick_up_date := initial_pick_up_date;
                    ELSIF p_cs_mleg_result_tab(rec_cnt_prior).dropoff_date IS NOT NULL THEN
                        -- pick up date is one hour more than drop off date of last stop
                        pick_up_date := p_cs_mleg_result_tab(rec_cnt_prior).dropoff_date + 1/24;
                    END IF;

                    p_cs_mleg_result_tab(rec_cnt).pickup_date := pick_up_date;

                    IF transit_time_found = TRUE THEN
                    --{
                        from_location_id :=  p_cs_mleg_result_tab(rec_cnt).initial_pickup_location_id;
                        to_location_id   :=  p_cs_mleg_result_tab(rec_cnt).ultimate_dropoff_location_id;
                        ship_method      :=  p_cs_mleg_result_tab(rec_cnt).ship_method_code;

                        OPEN get_transit_time (from_location_id, to_location_id, ship_method);
                            FETCH get_transit_time into transit_time;
                        CLOSE get_transit_time;

                        --
                        -- If transit time is not found for a leg, divide remaining time equally between different legs
                        --

                        IF transit_time IS NULL THEN
                        --{
                            transit_time_found := false;
                            num_days           := ultimate_drop_off_date - pick_up_date;
                            IF num_days > (num_legs-1)/24 THEN
                                days_fraction      := (num_days - (num_legs-2)/24)/ num_legs;
                            ELSE
                                days_fraction      := num_days / num_legs;
                            END IF;
                            drop_off_date      := pick_up_date + days_fraction;

                            p_cs_mleg_result_tab(rec_cnt).dropoff_date := drop_off_date;
                        --}
                        ELSE -- transit time is not null
                        --{
                            IF l_debug_on THEN
                                WSH_DEBUG_SV.log(l_module_name, 'transit_time_found', transit_time_found);
                                WSH_DEBUG_SV.log(l_module_name, 'from_location_id', from_location_id);
                                WSH_DEBUG_SV.log(l_module_name, 'to_location_id', to_location_id);
                                WSH_DEBUG_SV.log(l_module_name, 'ship_method', ship_method);
                                WSH_DEBUG_SV.log(l_module_name, 'transit_time', transit_time);
                            END IF;

                            IF rec_cnt = p_cs_mleg_result_tab.LAST THEN
                                drop_off_date := ultimate_drop_off_date;
                            ELSE
                                drop_off_date := pick_up_date + transit_time;
                            END IF;

                            IF drop_off_date < ultimate_drop_off_date THEN
                               p_cs_mleg_result_tab(rec_cnt).dropoff_date := drop_off_date;
                               num_legs := num_legs - 1;
                            ELSIF drop_off_date = ultimate_drop_off_date THEN
                                IF drop_off_date <= pick_up_date THEN
                                    p_cs_mleg_result_tab(rec_cnt).dropoff_date := drop_off_date + 1/24;
                                    ultimate_drop_off_date := ultimate_drop_off_date + 1/24;
                                END IF;
                                num_legs := num_legs - 1;
                            ELSE
                                transit_time_found := false;

                                IF p_cs_mleg_result_tab.EXISTS(rec_cnt_prior) THEN
                                    num_days := ultimate_drop_off_date - p_cs_mleg_result_tab(rec_cnt_prior).dropoff_date;
                                ELSE
                                    num_days := ultimate_drop_off_date - pick_up_date;
                                END IF;
                                IF num_days > (num_legs-1)/24 THEN
                                    days_fraction      := (num_days - (num_legs-2)/24)/ num_legs;
                                ELSE
                                    days_fraction      := num_days / num_legs;
                                END IF;
                                --days_fraction := num_days / num_legs;
                                drop_off_date := pick_up_date + days_fraction;
                                p_cs_mleg_result_tab(rec_cnt).dropoff_date := drop_off_date;
                            END IF;

                            IF l_debug_on THEN
                                WSH_DEBUG_SV.logmsg(l_module_name,'p_cs_mleg_result_tab(rec_cnt).pickup_date :'||to_char(p_cs_mleg_result_tab(rec_cnt).pickup_date, 'dd/mm/yyyy hh:mi:ss'));
                                WSH_DEBUG_SV.logmsg(l_module_name,'p_cs_mleg_result_tab(rec_cnt).dropoff_date :'||to_char(p_cs_mleg_result_tab(rec_cnt).dropoff_date,'dd/mm/yyyy hh:mi:ss'));
                             END IF;
                        --}
                        END IF;
                    --}
                    ELSE
                    --{
                        drop_off_date := pick_up_date + days_fraction;

                        IF drop_off_date > ultimate_drop_off_date OR rec_cnt = p_cs_mleg_result_tab.LAST THEN
                            drop_off_date := ultimate_drop_off_date;
                        END IF;

                        IF drop_off_date = ultimate_drop_off_date AND drop_off_date <= pick_up_date THEN
                            drop_off_date := drop_off_date + 1/24;
                            ultimate_drop_off_date := drop_off_date;
                        END IF;

                        p_cs_mleg_result_tab(rec_cnt).dropoff_date := drop_off_date;
                    --}
                    END IF;

                   --}
                    EXIT WHEN rec_cnt = p_cs_mleg_result_tab.LAST OR rec_cnt IS NULL;

                    rec_cnt := p_cs_mleg_result_tab.NEXT(rec_cnt);

                END LOOP;

            --END IF;

            d_itr := p_cs_mleg_result_tab.FIRST;

            IF d_itr IS NOT NULL THEN
                LOOP
                    IF p_cs_mleg_result_tab(d_itr).pickup_date = p_cs_mleg_result_tab(d_itr).dropoff_date THEN
                        p_cs_mleg_result_tab(d_itr).dropoff_date := p_cs_mleg_result_tab(d_itr).dropoff_date + 1/144;
                    END IF;

                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'p_cs_mleg_result_tab(d_itr).initial_pickup_location_id :'||p_cs_mleg_result_tab(d_itr).initial_pickup_location_id);
                        WSH_DEBUG_SV.logmsg(l_module_name,'p_cs_mleg_result_tab(d_itr).pickup_date :'||to_char(p_cs_mleg_result_tab(d_itr).pickup_date, 'dd/mm/yyyy hh:mi:ss'));
                        WSH_DEBUG_SV.logmsg(l_module_name,'p_cs_mleg_result_tab(d_itr).ultimate_dropoff_location_id :'||p_cs_mleg_result_tab(d_itr).ultimate_dropoff_location_id);
                        WSH_DEBUG_SV.logmsg(l_module_name,'p_cs_mleg_result_tab(d_itr).dropoff_date :'||to_char(p_cs_mleg_result_tab(d_itr).dropoff_date,'dd/mm/yyyy hh:mi:ss'));
                     END IF;

                    EXIT WHEN d_itr = p_cs_mleg_result_tab.LAST;
                    d_itr := p_cs_mleg_result_tab.NEXT(d_itr);
               END LOOP;
            END IF;
        END IF;
    END IF;

    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
--}
EXCEPTION

  WHEN OTHERS THEN

       wsh_util_core.default_handler('WSH_NEW_DELIVERY_ACTIONS.SET_PICK_UP_DROP_OFF_DATES',l_module_name);
       x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

       IF get_transit_time%ISOPEN THEN
          CLOSE get_transit_time;
       END IF;

       IF l_debug_on THEN

          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');

       END IF;

END SET_PICK_UP_DROP_OFF_DATES;

-- -------------------------------------------------------------------------- --
--                                                                            --
-- NAME:                FORMAT_DEL_UPDATE_TABLE                               --
--                                                                            --
-- TYPE:                PROCEDURE                                             --
--                                                                            --
--                                                                            --
-- PARAMETERS (IN):     p_del_id_tab        IN WSH_NEW_DELIVERY_ACTIONS.TableNumbers      --
--                      p_carrier_id_tab    IN WSH_NEW_DELIVERY_ACTIONS.TableNumbers      --
--                      p_service_level_tab IN WSH_NEW_DELIVERY_ACTIONS.TableVarchar30    --
--                      p_mode_tab          IN WSH_NEW_DELIVERY_ACTIONS.TableVarchar30    --
--                      p_freight_term_tab  IN WSH_NEW_DELIVERY_ACTIONS.TableVarchar30    --
--                      p_smc_tab           IN WSH_NEW_DELIVERY_ACTIONS.TableVarchar30    --
--                      p_org_del_id_tab    IN WSH_NEW_DELIVERY_ACTIONS.TableNumbers      --
--                      p_trip_id_tab       IN WSH_NEW_DELIVERY_ACTIONS.TableNumbers      --
--                                                                            --
-- PARAMETERS (OUT):    x_rec_attr_tab      OUT NOCOPY WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type --
--                      x_trip_info_tab     OUT NOCOPY WSH_TRIPS_PVT.Trip_Attr_Tbl_Type
--
--
-- RETURN:              none                                                  --
--                                                                            --
-- DESCRIPTION:         This procedure is used to format the record for       --
--                      updating the delivery table for carrier selection     --
--                                                                            --
--                                                                            --
-- CHANGE CONTROL LOG                                                         --
-- ------------------                                                         --
--                                                                            --
-- DATE        VERSION  BY        BUG      DESCRIPTION                        --
-- ----------  -------  --------  -------  ---------------------------------- --
-- 2002/12/09  I        ABLUNDEL  -------  Created                            --
-- Attribute passed initially						      --
-- p_del_id_tab         IN WSH_NEW_DELIVERY_ACTIONS.TableNumbers,		--
-- p_carrier_id_tab     IN WSH_NEW_DELIVERY_ACTIONS.TableNumbers,	      --
-- p_service_level_tab  IN WSH_NEW_DELIVERY_ACTIONS.TableVarchar30,	      --
-- p_mode_tab		IN WSH_NEW_DELIVERY_ACTIONS.TableVarchar30,	      --
-- p_freight_term_tab	IN WSH_NEW_DELIVERY_ACTIONS.TableVarchar30,	      --
-- p_smc_tab		IN WSH_NEW_DELIVERY_ACTIONS.TableVarchar30,	      --
--                                                                            --
-- -------------------------------------------------------------------------- --

-- Result table will be of type Shipping

PROCEDURE FORMAT_DEL_UPDATE_TABLE(--p_cs_result_tab     IN FTE_ACS_PKG.FTE_CS_RESULT_TAB_TYPE,
                    p_cs_result_tab       IN WSH_FTE_INTEGRATION.WSH_CS_RESULT_TAB_TYPE,
                    p_caller              IN  VARCHAR2 DEFAULT NULL,
                    x_rec_attr_tab        OUT NOCOPY WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type,
                    x_trip_info_tab       OUT NOCOPY WSH_TRIPS_PVT.Trip_Attr_Tbl_Type,
                    x_return_message            OUT NOCOPY VARCHAR2,
                    x_return_status             OUT NOCOPY VARCHAR2) IS

fmc             NUMBER;
fmct            NUMBER;
fm              NUMBER;

trpidx          NUMBER;
l_del_found     BOOLEAN;
l_error_code    NUMBER;
l_error_text    VARCHAR2(2000);
l_del_org_id    NUMBER;
l_prev_org_id   NUMBER;
l_skip_rtng_rule_ac_trip      VARCHAR2(1) := 'N';
l_param_value_info            WSH_SHIPPING_PARAMS_PVT.PARAMETER_VALUE_REC_TYP;
l_ignore_for_planning         WSH_TRIPS.ignore_for_planning%TYPE;
--
l_debug_on      BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'FORMAT_DEL_UPDATE_TABLE';
--
BEGIN

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
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

   IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'p_cs_result_tab.COUNT :'||p_cs_result_tab.COUNT);

   END IF;

   IF (p_cs_result_tab.COUNT > 0) THEN

      fmc  := 0;
      fmct := 0;
      l_prev_org_id := 0;

      fm  := p_cs_result_tab.FIRST;
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'p_cs_result_tab(fm).delivery_id :'||p_cs_result_tab(fm).delivery_id);
          WSH_DEBUG_SV.logmsg(l_module_name,'p_cs_result_tab(fm).trip_id :'||p_cs_result_tab(fm).trip_id);
      END IF;

      LOOP

        IF (p_cs_result_tab(fm).trip_id) is NULL THEN

          fmc  := fmc + 1;
          IF (p_cs_result_tab(fm).delivery_id is not null) THEN

            x_rec_attr_tab(fmc).DELIVERY_ID                    := p_cs_result_tab(fm).delivery_id;
            x_rec_attr_tab(fmc).NAME                           := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).PLANNED_FLAG                   := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).STATUS_CODE                    := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).DELIVERY_TYPE                  := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).LOADING_SEQUENCE               := FND_API.G_MISS_NUM;
            x_rec_attr_tab(fmc).LOADING_ORDER_FLAG             := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).INITIAL_PICKUP_DATE            := FND_API.G_MISS_DATE;
            x_rec_attr_tab(fmc).INITIAL_PICKUP_LOCATION_ID     := FND_API.G_MISS_NUM;
            x_rec_attr_tab(fmc).ORGANIZATION_ID                := FND_API.G_MISS_NUM;
            x_rec_attr_tab(fmc).ULTIMATE_DROPOFF_LOCATION_ID   := FND_API.G_MISS_NUM;
            x_rec_attr_tab(fmc).ULTIMATE_DROPOFF_DATE          := FND_API.G_MISS_DATE;
            x_rec_attr_tab(fmc).CUSTOMER_ID                    := FND_API.G_MISS_NUM;
            x_rec_attr_tab(fmc).INTMED_SHIP_TO_LOCATION_ID     := FND_API.G_MISS_NUM;
            x_rec_attr_tab(fmc).POOLED_SHIP_TO_LOCATION_ID     := FND_API.G_MISS_NUM;

	        -- Bug 4524023 (issue 1)
	        /*IF (p_cs_result_tab(fm).carrier_id is null) THEN
              x_rec_attr_tab(fmc).CARRIER_ID                  := FND_API.G_MISS_NUM;
            ELSE*/
            x_rec_attr_tab(fmc).CARRIER_ID                  := p_cs_result_tab(fm).carrier_id;

            --END IF;

            /*IF (p_cs_result_tab(fm).ship_method_code is null) THEN
              x_rec_attr_tab(fmc).SHIP_METHOD_CODE            := FND_API.G_MISS_CHAR;
            ELSE*/
            x_rec_attr_tab(fmc).SHIP_METHOD_CODE            := p_cs_result_tab(fm).ship_method_code;
            --END IF;

            IF (p_cs_result_tab(fm).freight_terms_code IS NULL) THEN
              x_rec_attr_tab(fmc).FREIGHT_TERMS_CODE          := FND_API.G_MISS_CHAR;
            ELSE
              x_rec_attr_tab(fmc).FREIGHT_TERMS_CODE          := p_cs_result_tab(fm).freight_terms_code;
            END IF;

            x_rec_attr_tab(fmc).FOB_CODE                      := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).FOB_LOCATION_ID               := FND_API.G_MISS_NUM;
            x_rec_attr_tab(fmc).WAYBILL                       := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).DOCK_CODE                     := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).ACCEPTANCE_FLAG               := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).ACCEPTED_BY                   := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).ACCEPTED_DATE                 := FND_API.G_MISS_DATE;
            x_rec_attr_tab(fmc).ACKNOWLEDGED_BY               := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).CONFIRMED_BY                  := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).CONFIRM_DATE                  := FND_API.G_MISS_DATE;
            x_rec_attr_tab(fmc).ASN_DATE_SENT                 := FND_API.G_MISS_DATE;
            x_rec_attr_tab(fmc).ASN_STATUS_CODE               := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).ASN_SEQ_NUMBER                := FND_API.G_MISS_NUM;
            x_rec_attr_tab(fmc).GROSS_WEIGHT                  := FND_API.G_MISS_NUM;
            x_rec_attr_tab(fmc).NET_WEIGHT                    := FND_API.G_MISS_NUM;
            x_rec_attr_tab(fmc).WEIGHT_UOM_CODE               := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).VOLUME                        := FND_API.G_MISS_NUM;
            x_rec_attr_tab(fmc).VOLUME_UOM_CODE               := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).ADDITIONAL_SHIPMENT_INFO      := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).CURRENCY_CODE                 := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).ATTRIBUTE_CATEGORY            := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).ATTRIBUTE1                    := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).ATTRIBUTE2                    := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).ATTRIBUTE3                    := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).ATTRIBUTE4                    := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).ATTRIBUTE5                    := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).ATTRIBUTE6                    := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).ATTRIBUTE7                    := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).ATTRIBUTE8                    := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).ATTRIBUTE9                    := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).ATTRIBUTE10                   := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).ATTRIBUTE11                   := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).ATTRIBUTE12                   := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).ATTRIBUTE13                   := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).ATTRIBUTE14                   := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).ATTRIBUTE15                   := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).TP_ATTRIBUTE_CATEGORY         := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).TP_ATTRIBUTE1                 := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).TP_ATTRIBUTE2                 := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).TP_ATTRIBUTE3                 := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).TP_ATTRIBUTE4                 := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).TP_ATTRIBUTE5                 := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).TP_ATTRIBUTE6                 := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).TP_ATTRIBUTE7                 := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).TP_ATTRIBUTE8                 := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).TP_ATTRIBUTE9                 := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).TP_ATTRIBUTE10                := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).TP_ATTRIBUTE11                := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).TP_ATTRIBUTE12                := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).TP_ATTRIBUTE13                := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).TP_ATTRIBUTE14                := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).TP_ATTRIBUTE15                := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).GLOBAL_ATTRIBUTE_CATEGORY     := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).GLOBAL_ATTRIBUTE1             := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).GLOBAL_ATTRIBUTE2             := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).GLOBAL_ATTRIBUTE3             := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).GLOBAL_ATTRIBUTE4             := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).GLOBAL_ATTRIBUTE5             := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).GLOBAL_ATTRIBUTE6             := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).GLOBAL_ATTRIBUTE7             := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).GLOBAL_ATTRIBUTE8             := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).GLOBAL_ATTRIBUTE9             := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).GLOBAL_ATTRIBUTE10            := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).GLOBAL_ATTRIBUTE11            := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).GLOBAL_ATTRIBUTE12            := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).GLOBAL_ATTRIBUTE13            := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).GLOBAL_ATTRIBUTE14            := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).GLOBAL_ATTRIBUTE15            := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).GLOBAL_ATTRIBUTE16            := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).GLOBAL_ATTRIBUTE17            := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).GLOBAL_ATTRIBUTE18            := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).GLOBAL_ATTRIBUTE19            := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).GLOBAL_ATTRIBUTE20            := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).CREATION_DATE                 := FND_API.G_MISS_DATE;
            x_rec_attr_tab(fmc).CREATED_BY                    := FND_API.G_MISS_NUM;
            x_rec_attr_tab(fmc).LAST_UPDATE_DATE              := FND_API.G_MISS_DATE;
            x_rec_attr_tab(fmc).LAST_UPDATED_BY               := FND_API.G_MISS_NUM;
            x_rec_attr_tab(fmc).LAST_UPDATE_LOGIN             := FND_API.G_MISS_NUM;
            x_rec_attr_tab(fmc).PROGRAM_APPLICATION_ID        := FND_API.G_MISS_NUM;
            x_rec_attr_tab(fmc).PROGRAM_ID                    := FND_API.G_MISS_NUM;
            x_rec_attr_tab(fmc).PROGRAM_UPDATE_DATE           := FND_API.G_MISS_DATE;
            x_rec_attr_tab(fmc).REQUEST_ID                    := FND_API.G_MISS_NUM;
            x_rec_attr_tab(fmc).BATCH_ID                      := FND_API.G_MISS_NUM;
            x_rec_attr_tab(fmc).HASH_VALUE                    := FND_API.G_MISS_NUM;
            x_rec_attr_tab(fmc).SOURCE_HEADER_ID              := FND_API.G_MISS_NUM;
            x_rec_attr_tab(fmc).NUMBER_OF_LPN                 := FND_API.G_MISS_NUM;
            x_rec_attr_tab(fmc).COD_AMOUNT                    := FND_API.G_MISS_NUM;
            x_rec_attr_tab(fmc).COD_CURRENCY_CODE             := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).COD_REMIT_TO                  := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).COD_CHARGE_PAID_BY            := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).PROBLEM_CONTACT_REFERENCE     := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).PORT_OF_LOADING               := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).PORT_OF_DISCHARGE             := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).FTZ_NUMBER                    := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).ROUTED_EXPORT_TXN             := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).ENTRY_NUMBER                  := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).ROUTING_INSTRUCTIONS          := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).IN_BOND_CODE                  := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).SHIPPING_MARKS                := FND_API.G_MISS_CHAR;

            /*IF (p_cs_result_tab(fm).service_level is null) THEN
              x_rec_attr_tab(fmc).SERVICE_LEVEL               := FND_API.G_MISS_CHAR;
            ELSE*/
            x_rec_attr_tab(fmc).SERVICE_LEVEL               := p_cs_result_tab(fm).service_level;
            --END IF;

            /*IF (p_cs_result_tab(fm).mode_of_transport is null) THEN
              x_rec_attr_tab(fmc).MODE_OF_TRANSPORT           := FND_API.G_MISS_CHAR;
            ELSE*/
            x_rec_attr_tab(fmc).MODE_OF_TRANSPORT           := p_cs_result_tab(fm).mode_of_transport;
            --END IF;

            x_rec_attr_tab(fmc).ASSIGNED_TO_FTE_TRIPS         := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).AUTO_SC_EXCLUDE_FLAG          := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).AUTO_AP_EXCLUDE_FLAG          := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).AP_BATCH_ID                   := FND_API.G_MISS_NUM;

  --        x_rec_attr_tab(fmc).ROWID                         := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).LOADING_ORDER_DESC            := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).ORGANIZATION_CODE             := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).ULTIMATE_DROPOFF_LOCATION_CODE:= FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).INITIAL_PICKUP_LOCATION_CODE  := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).CUSTOMER_NUMBER               := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).INTMED_SHIP_TO_LOCATION_CODE  := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).POOLED_SHIP_TO_LOCATION_CODE  := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).CARRIER_CODE                  := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).SHIP_METHOD_NAME              := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).FREIGHT_TERMS_NAME            := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).FOB_NAME                      := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).FOB_LOCATION_CODE             := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).WEIGHT_UOM_DESC               := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).VOLUME_UOM_DESC               := FND_API.G_MISS_CHAR;
            x_rec_attr_tab(fmc).CURRENCY_NAME                 := FND_API.G_MISS_CHAR;
          END IF;

        ELSE

          fmct := fmct + 1;

            IF (p_cs_result_tab(fm).delivery_id is not null) THEN

/*
-- Hiding project
                IF p_caller = 'WSH_AUTO_CREATE_DEL_TRIP' THEN

                    -- AG use organization_id from cs_result_tab
                    l_del_org_id := p_cs_result_tab(fm).organization_id;

                    IF l_del_org_id  <> l_prev_org_id THEN

                        l_param_value_info.organization_id := l_del_org_id;
                        l_param_value_info.param_name(1)   := 'SKIP_RTNG_RULE_AC_TRIP';

                        WSH_SHIPPING_PARAMS_PVT.Get(x_param_value_info       => l_param_value_info,
                                                    x_return_status          => x_return_status);
                        l_skip_rtng_rule_ac_trip := l_param_value_info.PARAM_VALUE_CHR(1);
                    END IF;
                END IF;
*/ -- Hiding project

                IF p_caller <> 'WSH_AUTO_CREATE_DEL_TRIP' THEN
/*
-- Hiding project
                IF p_caller <> 'WSH_AUTO_CREATE_DEL_TRIP' OR
                    (p_caller = 'WSH_AUTO_CREATE_DEL_TRIP' AND l_skip_rtng_rule_ac_trip <> 'Y') THEN
*/ -- Hiding project
                    x_trip_info_tab(fmct).TRIP_ID := p_cs_result_tab(fm).trip_id;

                    x_trip_info_tab(fmct).NAME                     := FND_API.G_MISS_CHAR;
                    --x_trip_info_tab(fmct).PLANNED_FLAG			   := FND_API.G_MISS_CHAR;
                    x_trip_info_tab(fmct).PLANNED_FLAG			   := 'N';
                    x_trip_info_tab(fmct).ARRIVE_AFTER_TRIP_ID	   := FND_API.G_MISS_NUM;
                    x_trip_info_tab(fmct).STATUS_CODE			   := 'OP';
                    x_trip_info_tab(fmct).VEHICLE_ITEM_ID		   := FND_API.G_MISS_NUM;
                    x_trip_info_tab(fmct).VEHICLE_ORGANIZATION_ID  := FND_API.G_MISS_NUM;
                    x_trip_info_tab(fmct).VEHICLE_NUMBER	       := FND_API.G_MISS_CHAR;
                    x_trip_info_tab(fmct).VEHICLE_NUM_PREFIX	   := FND_API.G_MISS_CHAR;

                    /*IF (p_cs_result_tab(fm).carrier_id is null) THEN
                      x_trip_info_tab(fmct).CARRIER_ID             := FND_API.G_MISS_NUM;
                    ELSE*/
                    x_trip_info_tab(fmct).CARRIER_ID             := p_cs_result_tab(fm).carrier_id;
                    --END IF;

                    /*IF (p_cs_result_tab(fm).ship_method_code is null) THEN
                      x_trip_info_tab(fmct).SHIP_METHOD_CODE       := FND_API.G_MISS_CHAR;
                    ELSE*/
                    x_trip_info_tab(fmct).SHIP_METHOD_CODE       := p_cs_result_tab(fm).ship_method_code;
                    --END IF;


                    IF (p_cs_result_tab(fm).consignee_carrier_ac_no is null) THEN
                        x_trip_info_tab(fmct).CONSIGNEE_CARRIER_AC_NO := FND_API.G_MISS_CHAR;
                    ELSE
                        x_trip_info_tab(fmct).CONSIGNEE_CARRIER_AC_NO := p_cs_result_tab(fm).consignee_carrier_ac_no;
                    END IF;

-- AG
-- cs_result_tab.rank stores rank_sequence
-- It is not same as trip's rank_id which has already been updated by FTE
-- rank_list_action API
                    x_trip_info_tab(fmct).RANK_ID := FND_API.G_MISS_NUM;

                    IF (p_cs_result_tab(fm).append_flag is null) THEN
                      x_trip_info_tab(fmct).APPEND_FLAG := FND_API.G_MISS_CHAR;
                    ELSE
                      x_trip_info_tab(fmct).APPEND_FLAG := p_cs_result_tab(fm).append_flag;
                    END IF;

-- AG Use rule_id from p_cs_result_tab and not routing_rule_id

                    IF (p_cs_result_tab(fm).rule_id  is null) THEN
                      x_trip_info_tab(fmct).ROUTING_RULE_ID := FND_API.G_MISS_NUM;
                    ELSE
                      x_trip_info_tab(fmct).ROUTING_RULE_ID := p_cs_result_tab(fm).rule_id ;
                    END IF;

                    x_trip_info_tab(fmct).ROUTE_ID			     := FND_API.G_MISS_NUM;
                    x_trip_info_tab(fmct).ROUTING_INSTRUCTIONS	 := FND_API.G_MISS_CHAR;
                    x_trip_info_tab(fmct).ATTRIBUTE_CATEGORY	 := FND_API.G_MISS_CHAR;
                    x_trip_info_tab(fmct).ATTRIBUTE1			 := FND_API.G_MISS_CHAR;
                    x_trip_info_tab(fmct).ATTRIBUTE2			 := FND_API.G_MISS_CHAR;
                    x_trip_info_tab(fmct).ATTRIBUTE3			 := FND_API.G_MISS_CHAR;
                    x_trip_info_tab(fmct).ATTRIBUTE4			 := FND_API.G_MISS_CHAR;
                    x_trip_info_tab(fmct).ATTRIBUTE5			 := FND_API.G_MISS_CHAR;
                    x_trip_info_tab(fmct).ATTRIBUTE6			 := FND_API.G_MISS_CHAR;
                    x_trip_info_tab(fmct).ATTRIBUTE7			 := FND_API.G_MISS_CHAR;
                    x_trip_info_tab(fmct).ATTRIBUTE8			 := FND_API.G_MISS_CHAR;
                    x_trip_info_tab(fmct).ATTRIBUTE9			 := FND_API.G_MISS_CHAR;
                    x_trip_info_tab(fmct).ATTRIBUTE10			 := FND_API.G_MISS_CHAR;
                    x_trip_info_tab(fmct).ATTRIBUTE11			 := FND_API.G_MISS_CHAR;
                    x_trip_info_tab(fmct).ATTRIBUTE12			 := FND_API.G_MISS_CHAR;
                    x_trip_info_tab(fmct).ATTRIBUTE13			 := FND_API.G_MISS_CHAR;
                    x_trip_info_tab(fmct).ATTRIBUTE14			 := FND_API.G_MISS_CHAR;
                    x_trip_info_tab(fmct).ATTRIBUTE15			 := FND_API.G_MISS_CHAR;
                    x_trip_info_tab(fmct).CREATION_DATE			 := SYSDATE;
                    x_trip_info_tab(fmct).CREATED_BY			 := fnd_global.user_id;
                    x_trip_info_tab(fmct).LAST_UPDATE_DATE		 := SYSDATE;
                    x_trip_info_tab(fmct).LAST_UPDATED_BY		 := fnd_global.user_id;
                    x_trip_info_tab(fmct).LAST_UPDATE_LOGIN		 := fnd_global.login_id;
                    x_trip_info_tab(fmct).PROGRAM_APPLICATION_ID := FND_API.G_MISS_NUM;
                    x_trip_info_tab(fmct).PROGRAM_ID			 := FND_API.G_MISS_NUM;
                    x_trip_info_tab(fmct).PROGRAM_UPDATE_DATE	 := FND_API.G_MISS_DATE;
                    x_trip_info_tab(fmct).REQUEST_ID			 := FND_API.G_MISS_NUM;

                    /*IF (p_cs_result_tab(fm).service_level is null) THEN
                      x_trip_info_tab(fmct).SERVICE_LEVEL := FND_API.G_MISS_CHAR;
                    ELSE*/
                      x_trip_info_tab(fmct).SERVICE_LEVEL := p_cs_result_tab(fm).service_level;
                    --END IF;

                    /*IF (p_cs_result_tab(fm).mode_of_transport is null) THEN
                      x_trip_info_tab(fmct).MODE_OF_TRANSPORT := FND_API.G_MISS_CHAR;
                    ELSE*/
                    x_trip_info_tab(fmct).MODE_OF_TRANSPORT := p_cs_result_tab(fm).mode_of_transport;
                    --END IF;

                    IF (p_cs_result_tab(fm).freight_terms_code is null) THEN
                      x_trip_info_tab(fmct).FREIGHT_TERMS_CODE := FND_API.G_MISS_CHAR;
                    ELSE
                      x_trip_info_tab(fmct).FREIGHT_TERMS_CODE := p_cs_result_tab(fm).freight_terms_code;
                    END IF;

                    x_trip_info_tab(fmct).CONSOLIDATION_ALLOWED	 := FND_API.G_MISS_CHAR;
                    x_trip_info_tab(fmct).LOAD_TENDER_STATUS	 := FND_API.G_MISS_CHAR;
                    x_trip_info_tab(fmct).ROUTE_LANE_ID		 := FND_API.G_MISS_NUM;
                    x_trip_info_tab(fmct).LANE_ID		 := FND_API.G_MISS_NUM;
                    x_trip_info_tab(fmct).SCHEDULE_ID		 := FND_API.G_MISS_NUM;
                    x_trip_info_tab(fmct).BOOKING_NUMBER	 := FND_API.G_MISS_CHAR;
                    x_trip_info_tab(fmct).ARRIVE_AFTER_TRIP_NAME := FND_API.G_MISS_CHAR;
                    x_trip_info_tab(fmct).SHIP_METHOD_NAME	 := FND_API.G_MISS_CHAR;
                    x_trip_info_tab(fmct).VEHICLE_ITEM_DESC	 := FND_API.G_MISS_CHAR;
                    x_trip_info_tab(fmct).VEHICLE_ORGANIZATION_CODE := FND_API.G_MISS_CHAR;

                END IF;
            END IF;

        END IF;  -- END of IF (p_trip_id_tab(trpidx) is NULL) THEN
--
         EXIT WHEN fm = p_cs_result_tab.LAST;
         fm := p_cs_result_tab.NEXT(fm);
    END LOOP;
   END IF;

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   RETURN;

EXCEPTION
   WHEN OTHERS THEN
      x_rec_attr_tab.DELETE;
      l_error_code := SQLCODE;
      l_error_text := SQLERRM;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'THE UNEXPECTED ERROR FROM WSH_NEW_DELIVERY_ACTIONS.FORMAT_DEL_UPDATE_TABLE IS ' ||l_error_text);
      END IF;
      --
      WSH_UTIL_CORE.default_handler('WSH_NEW_DELIVERY_ACTIONS.FORMAT_DEL_UPDATE_TABLE');
      WSH_UTIL_CORE.add_message(WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;

--
-- Debug Statements
--
IF l_debug_on THEN
   WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END FORMAT_DEL_UPDATE_TABLE;


PROCEDURE PROCESS_CARRIER_SELECTION(p_delivery_id_tab        IN OUT NOCOPY WSH_UTIL_CORE.Id_Tab_Type,
                                    p_batch_id               IN  NUMBER,
                                    p_form_flag              IN  VARCHAR2,
                                    p_organization_id	     IN  NUMBER DEFAULT NULL,
                                    p_caller                 IN  VARCHAR2 DEFAULT NULL,
                                    x_return_message         OUT NOCOPY  VARCHAR2,
                                    x_return_status          OUT NOCOPY  VARCHAR2) IS

--
-- Cursor to get delivery info from the table of delivery ids
-- Carrier selection is not required if delivery's ship from location id is null.
--
cursor c_get_del_info_by_del_id(x_delivery_id NUMBER) IS
select delivery_id,
       name,
       organization_id,
       gross_weight,
       weight_uom_code,
       volume,
       volume_uom_code,
       initial_pickup_location_id,
       ultimate_dropoff_location_id,
       customer_id,
       freight_terms_code,
       NULL,				-- planned_flag,
       initial_pickup_date,
       ultimate_dropoff_date,
       fob_code,
       shipment_direction,
       delivery_type,
       NULL				-- l_trip_id
from   wsh_new_deliveries
where  delivery_id = x_delivery_id
and    ship_method_code is null
AND    initial_pickup_location_id <> WSH_UTIL_CORE.C_NULL_SF_LOCN_ID   -- J-IB-NPARIKH
and    planned_flag NOT IN ('Y','F');

--
-- cursor to get delivery info from the delivery table (for Pick Release Call)
--

cursor c_get_del_info_by_batch_id( x_batch_id NUMBER,
                                   x_organization_id NUMBER
                                  ) IS
select delivery_id,
       name,
       organization_id,
       gross_weight,
       weight_uom_code,
       volume,
       volume_uom_code,
       initial_pickup_location_id,
       ultimate_dropoff_location_id,
       customer_id,
       freight_terms_code,
       NULL,		-- planned_flag,
       initial_pickup_date,
       ultimate_dropoff_date,
       fob_code,
       shipment_direction,
       delivery_type,
       NULL		-- l_trip_id
from   wsh_new_deliveries
where  batch_id = x_batch_id
and    organization_id = x_organization_id
and    ship_method_code is null
and    planned_flag NOT IN ('Y','F');

--
-- cursor to get delivery info from the delivery table (for form call)
-- BUG:2369435 - added planned_flag to cursor
--
cursor c_get_del_info_by_form(f_delivery_id NUMBER) IS
select delivery_id,
       name,
       organization_id,
       gross_weight,
       weight_uom_code,
       volume,
       volume_uom_code,
       initial_pickup_location_id,
       ultimate_dropoff_location_id,
       customer_id,
       freight_terms_code,
       planned_flag,
       initial_pickup_date,
       ultimate_dropoff_date,
       fob_code,
       shipment_direction,
       delivery_type,
       NULL		-- l_trip_id
from   wsh_new_deliveries
where  delivery_id = f_delivery_id;

CURSOR check_del_assigned(p_del_id IN NUMBER) IS
select  wts.trip_id,
        wt.rank_id
from    wsh_trip_stops wts,
        wsh_delivery_legs wdl,
        wsh_trips wt
where  wdl.delivery_id = p_del_id
and    wts.stop_id = wdl.pick_up_stop_id
and    wts.trip_id = wt.trip_id;

-- AG not required
/*
CURSOR get_org_for_delivery(p_del_id IN NUMBER) IS
select  wnd.organization_id
from    wsh_new_deliveries wnd
where  wnd.delivery_id = p_del_id;
*/


l_trip_id_tab                 WSH_NEW_DELIVERY_ACTIONS.TableNumbers;
l_return_status               VARCHAR2(1);                           -- returning error/success/warning
l_return_message              VARCHAR2(2000);                        -- hold a return error message
l_BatchSize                   PLS_INTEGER := 500;                    -- max rows from a batch fetch
l_current_rows                PLS_INTEGER;                           -- number of current rows fetched
l_remaining_rows              PLS_INTEGER;                           -- number of remaining rows left
l_previous_rows               PLS_INTEGER;                           -- rows previously processed
l_result_found_flag           VARCHAR2(1) := 'N';                    -- indicates a found result
l_messaging_yn                VARCHAR2(1);
l_y_planned_flag              VARCHAR2(1);

								     -- new parameter for getting
                                                                     -- shipping paramters
--
-- Variables used for error handling
--
l_error_code                  NUMBER;                                -- Oracle SQL Error Number
l_error_text                  VARCHAR2(2000);                        -- Oracle SQL Error Text

--
-- New variables added for new call to group constraint API to update delivery table
--

l_in_rec                      WSH_DELIVERIES_GRP.Del_In_Rec_Type;
l_trip_in_rec                 WSH_TRIPS_GRP.tripInRecType;
l_rec_attr_tab                WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type;
l_trip_info_tab	              WSH_TRIPS_PVT.Trip_Attr_Tbl_Type;
l_trip_out_rec_tab            WSH_TRIPS_GRP.Trip_Out_Tab_Type;
l_del_out_rec_tab             WSH_DELIVERIES_GRP.Del_Out_Tbl_Type;
l_msg_count                   NUMBER;
l_msg_data                    VARCHAR2(2000);
l_del_org_id                  NUMBER;
l_prev_org_id                 NUMBER;
l_trip_status                 VARCHAR2(50); -- get_trip_status
--alksharm
l_trip_id                     NUMBER;
l_prev_trip_id                NUMBER;
l_trip_name                   VARCHAR2(30);
l_delivery_id                 NUMBER;
list_cnt                      NUMBER;
l_cs_mleg_result_tab          WSH_FTE_INTEGRATION.WSH_CS_RESULT_TAB_TYPE;
l_ranked_list                 WSH_FTE_INTEGRATION.CARRIER_RANK_LIST_TBL_TYPE;

l_rank_id                     NUMBER;
l_trip_rank_seq               NUMBER;
l_skip_rtng_rule_ac_trip      VARCHAR2(1) := 'N';
-- sachin
 x_ranked_list                WSH_FTE_INTEGRATION.CARRIER_RANK_LIST_TBL_TYPE;
-- Rename


l_initial_pickup_date         DATE;
l_ultimate_dropoff_date       DATE;
i                             NUMBER;
j                             NUMBER;
k                             NUMBER;
l_global_param_rec            WSH_SHIPPING_PARAMS_PVT.Global_Parameters_Rec_Typ;
l_param_value_info            WSH_SHIPPING_PARAMS_PVT.PARAMETER_VALUE_REC_TYP;
l_prev_delivery_id            NUMBER;
l_start_index                 NUMBER;
l_end_index                   NUMBER;
rec_cnt                       NUMBER;
l_del_result_type             VARCHAR2(60);
l_rank_list_source            VARCHAR2(30);

--
-- sbakshi
--
l_carrier_sel_entity_tab      WSH_FTE_INTEGRATION.WSH_CS_ENTITY_TAB_TYPE;

l_carrier_sel_result_rec      WSH_FTE_INTEGRATION.WSH_CS_RESULT_REC_TYPE;

l_cs_result_tab               WSH_FTE_INTEGRATION.WSH_CS_RESULT_TAB_TYPE;
l_cs_output_message_tab       WSH_FTE_INTEGRATION.wsh_cs_output_message_tab;


l_dlvy_info_tab              wsh_cs_delivery_info_tab;
l_dlvy_info_rec              wsh_cs_delivery_info_rec;

itr                          NUMBER;
l_cnt                        NUMBER := 0;
l_start_search_level_flag    VARCHAR2(10) := 'SCOE';
l_param_rec                  WSH_SHIPPING_PARAMS_PVT.PARAMETER_VALUE_REC_TYP;
l_num_ranked_results         NUMBER;
-- sbakshi

-- Debug Variables
l_debug_on                    BOOLEAN;
--

l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PROCESS_CARRIER_SELECTION';

BEGIN
      --
      -- initialize the procedure return flags
      --
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
          WSH_DEBUG_SV.log(l_module_name,'P_BATCH_ID',P_BATCH_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_FORM_FLAG',P_FORM_FLAG);
          WSH_DEBUG_SV.log(l_module_name,'P_CALLER',P_CALLER);
      END IF;
      --

      x_return_status  := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      x_return_message := null;

      IF  WSH_UTIL_CORE.FTE_Is_Installed <> 'Y' THEN
        return;
      END IF;

      l_y_planned_flag := 'Y';

      IF ((p_batch_id is null) AND
          (p_delivery_id_tab.COUNT <= 0)) THEN
	   --
           -- Invalid input parameters means we will not be able to get delivery
           -- information, thus, we will not be able to call carrier selection,
           -- return to the calling procedure
           --

	   IF l_debug_on THEN
	       --
              WSH_DEBUG_SV.log(l_module_name,'P_BATCH_ID',P_BATCH_ID);
              WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID_TAB.COUNT',p_delivery_id_tab.COUNT);

	   END IF;

	   FND_MESSAGE.SET_NAME('WSH','WSH_FTE_CS_INVALID_INPUT');
           x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
           WSH_UTIL_CORE.add_message(x_return_status);
           --
           -- Debug Statements
           --
           IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,  'THE INPUT PARAMETERS ARE INVALID FOR THIS PROCEDURE'  );
           END IF;
           --

	   x_return_message := WSH_UTIL_CORE.G_RET_STS_ERROR;
           -- 2292513
           --
           -- Debug Statements
           --
           IF l_debug_on THEN
              WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           --
           RETURN;
      END IF;

      -- Pick Release
      IF (p_batch_id is not null) THEN

        l_result_found_flag := 'N';
        --
        -- Set the messaging flag
        --
        l_messaging_yn := 'N';
        l_previous_rows := 0;

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Using Cursor to get delivery info by batch id' );
        END IF;


        OPEN  c_get_del_info_by_batch_id(p_batch_id, p_organization_id);
            FETCH c_get_del_info_by_batch_id BULK COLLECT INTO l_dlvy_info_tab;
        CLOSE c_get_del_info_by_batch_id;

      -- Auto Apply routing rules is End of append delivery.
      ELSIF ((p_delivery_id_tab.COUNT > 0) AND
	     (p_batch_id is null) AND (p_form_flag = 'N'))  THEN

   	     l_messaging_yn := 'Y';


	     --FOR i IN p_delivery_id_tab.FIRST..p_delivery_id_tab.LAST LOOP
         itr := p_delivery_id_tab.FIRST;
         IF itr IS NOT NULL THEN
         LOOP

            IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Using Cursor to get delivery information-Number of Deliveries '||p_delivery_id_tab.COUNT || ' *** '|| p_delivery_id_tab(itr)|| ' *** ');
            END IF;

            OPEN  c_get_del_info_by_del_id(p_delivery_id_tab(itr));
                FETCH c_get_del_info_by_del_id INTO l_dlvy_info_rec;
            CLOSE c_get_del_info_by_del_id;

            /*IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name, 'l_dlvy_info_rec.delivery_id: *** : '|| l_dlvy_info_rec.delivery_id);
            END IF;*/

            IF (l_dlvy_info_rec.l_delivery_id IS NOT NULL) THEN
                l_dlvy_info_tab(l_cnt) := l_dlvy_info_rec;
                l_cnt := l_cnt+1 ;
            END IF;
            EXIT WHEN itr = p_delivery_id_tab.LAST;
            itr := p_delivery_id_tab.NEXT(itr);
          END LOOP;
        END IF;

    --Call from UI.
    ELSIF ((p_delivery_id_tab.COUNT > 0) AND
           (p_batch_id is null) AND
           (p_form_flag = 'Y')) THEN

        l_messaging_yn := 'Y';

        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Getting Information using Form');
           WSH_DEBUG_SV.logmsg(l_module_name,'Using Cursor to get delivery information-Number of Deliveries '||p_delivery_id_tab.COUNT);
        END IF;


	    FOR i IN p_delivery_id_tab.FIRST..p_delivery_id_tab.LAST LOOP

		 IF l_debug_on THEN
		     WSH_DEBUG_SV.logmsg(l_module_name,'DELIVERY  ID '||p_delivery_id_tab(i));
		 END IF;

  		 OPEN  c_get_del_info_by_form(p_delivery_id_tab(i));
            FETCH c_get_del_info_by_form INTO l_dlvy_info_rec;
		 CLOSE c_get_del_info_by_form;

         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'l_dlvy_info_rec.l_delivery_id: '|| l_dlvy_info_rec.l_delivery_id);
         END IF;

		 IF (l_dlvy_info_rec.l_delivery_id IS NOT NULL) THEN

			IF (l_dlvy_info_rec.l_planned_flag IN ('Y', 'F')) THEN
			    --
                -- Delivery is planned cannot do carrier selection
                --
                --
                -- [2003/01/29][I][ABLUNDEL][BUG# 2765987]
                -- Changed planned delivery to an ERROR from a WARNING
                --
                x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
                x_return_message := WSH_UTIL_CORE.G_RET_STS_ERROR;
                FND_MESSAGE.Set_Name('WSH', 'WSH_FTE_CS_PLAN_DEL');
                FND_MESSAGE.Set_Token('DELIVERY_ID',l_dlvy_info_rec.l_delivery_id);
                wsh_util_core.add_message(x_return_status);
                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,  'DELIVERY '||l_dlvy_info_rec.l_delivery_id||' IS A PLANNED DELIVERY , CARRIER SELECTION IS NOT ALLOWED'  );
                END IF;
                --
                -- 11i10+ change
             ELSE

			    l_trip_status := get_trip_status(l_dlvy_info_rec.l_delivery_id,l_dlvy_info_rec.l_delivery_type);
			    -- Delivery is assigned to more than one trip
                IF (l_trip_status = 'MANY') THEN

                    x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
                    x_return_message := WSH_UTIL_CORE.G_RET_STS_ERROR;
                    IF (substr(p_caller,1,3) = 'FTE') THEN
                        FND_MESSAGE.Set_Name('WSH','WSH_FTE_CS_TRIP_MANY_FTE');
                    ELSE
                        FND_MESSAGE.Set_Name('WSH','WSH_FTE_CS_TRIP_MANY');
                    END IF;
                    FND_MESSAGE.Set_Token('DELIVERY_ID',l_dlvy_info_rec.l_delivery_id);
                    wsh_util_core.add_message(x_return_status);

                    IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,'DELIVERY '||l_dlvy_info_rec.l_delivery_id||' IS ASSIGNED TO MANY TRIPS, CARRIER SELECTION IS NOT ALLOWED'  );
                    END IF;

			    -- Trip to which this delivery is assigned has more than one deliveries
		  	    ELSIF (l_trip_status = 'SHARED') THEN

                        x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
                        x_return_message := WSH_UTIL_CORE.G_RET_STS_ERROR;
                        IF (substr(p_caller,1,3) = 'FTE') THEN
                            FND_MESSAGE.Set_Name('WSH','WSH_FTE_CS_TRIP_SHARED_FTE');
                        ELSE
                            FND_MESSAGE.Set_Name('WSH', 'WSH_FTE_CS_TRIP_SHARED');
                        END IF;

					   FND_MESSAGE.Set_Token('DELIVERY_ID',l_dlvy_info_rec.l_delivery_id);
			                   wsh_util_core.add_message(x_return_status);

                        IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,  'DELIVERY '||l_dlvy_info_rec.l_delivery_id||' IS ASSIGNED TO A SHARED TRIP, CARRIER SELECTION IS NOT ALLOWED'  );
                        END IF;

                -- Trip to which this delivery is assigned has Lane/Service
                ELSIF (l_trip_status = 'HAS_LANE') THEN

                    x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
                    x_return_message := WSH_UTIL_CORE.G_RET_STS_ERROR;

                    IF (substr(p_caller,1,3) = 'FTE') THEN
                        FND_MESSAGE.Set_Name('WSH','WSH_FTE_CS_TRIP_HAS_LANE_FTE');
                    ELSE
                        FND_MESSAGE.Set_Name('WSH', 'WSH_FTE_CS_TRIP_HAS_LANE');
                    END IF;
                    FND_MESSAGE.Set_Token('DELIVERY_ID',l_dlvy_info_rec.l_delivery_id);
                    wsh_util_core.add_message(x_return_status);

                    IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,  'DELIVERY '||l_dlvy_info_rec.l_delivery_id||' IS ASSIGNED TO A TRIP WITH SERVICE, CARRIER SELECTION IS NOT ALLOWED'  );
                    END IF;

			     -- Delivery is not assigned to a trip Or
			     -- Delivery is assigned to one trip and this trip is not shared with other deliveries
			    ELSE   -- BUG:2369435

                    IF (substr(l_trip_status,1,3) = 'ONE') THEN
                        l_dlvy_info_rec.l_trip_id := to_number(substr(l_trip_status,5));
                    ELSE
                        l_dlvy_info_rec.l_trip_id := null;
                    END IF;
                    --Validate other things
                    l_dlvy_info_tab(l_cnt) := l_dlvy_info_rec;
                    l_cnt := l_cnt +1 ;
			     END IF;
			END IF;
		END IF;
	  END LOOP; -- FOR i IN p_delivery_id_tab.FISRT..p_delivery_id_tab.LAST LOOP
    END IF;


    IF (l_dlvy_info_tab.COUNT = 0) THEN
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'now exiting');
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        RETURN;
    END IF;

    l_cnt:= 0;

    i := l_dlvy_info_tab.FIRST;

    LOOP
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'l_cnt : '|| l_cnt);
        END IF;
	--
	-- If delivery is content do not add it.
	--
	IF NOT(is_dlvy_content(p_delivery_id =>l_dlvy_info_tab(i).l_delivery_id))
	THEN

		l_carrier_sel_entity_tab(l_cnt).delivery_id             := 	l_dlvy_info_tab(i).l_delivery_id;
		l_carrier_sel_entity_tab(l_cnt).delivery_name           := 	l_dlvy_info_tab(i).l_dlvy_name;
		l_carrier_sel_entity_tab(l_cnt).trip_id			:=      l_dlvy_info_tab(i).l_trip_id;
		l_carrier_sel_entity_tab(l_cnt).organization_id         := 	l_dlvy_info_tab(i).l_organization_id;
		l_carrier_sel_entity_tab(l_cnt).gross_weight            := 	l_dlvy_info_tab(i).l_gross_weight;
		l_carrier_sel_entity_tab(l_cnt).volume		        := 	l_dlvy_info_tab(i).l_volume;
		l_carrier_sel_entity_tab(l_cnt).initial_pickup_loc_id   := 	l_dlvy_info_tab(i).l_initial_pickup_location_id;
		l_carrier_sel_entity_tab(l_cnt).ultimate_dropoff_loc_id := 	l_dlvy_info_tab(i).l_ultimate_dropoff_location_id;

		l_carrier_sel_entity_tab(l_cnt).freight_terms_code      := 	l_dlvy_info_tab(i).l_freight_terms_code;
		l_carrier_sel_entity_tab(l_cnt).initial_pickup_date     := 	l_dlvy_info_tab(i).l_initial_pickup_date;

		l_carrier_sel_entity_tab(l_cnt).ultimate_dropoff_date   := 	l_dlvy_info_tab(i).l_ultimate_dropoff_date;
		l_carrier_sel_entity_tab(l_cnt).fob_code	        := 	l_dlvy_info_tab(i).l_fob_code;
        --
		-- In format carrier selection. If weight/volume UOM code is NULL then get the
		-- default uoms. (This statement is in accordance with previous code)
		--
		IF ((l_dlvy_info_tab(i).l_weight_uom_code is null) AND
		          (l_dlvy_info_tab(i).l_volume_uom_code is null)) THEN

			    WSH_WV_UTILS.get_default_uoms( p_organization_id => l_dlvy_info_tab(i).l_organization_id,
							   x_weight_uom_code => l_carrier_sel_entity_tab(l_cnt).weight_uom_code,
							   x_volume_uom_code => l_carrier_sel_entity_tab(l_cnt).volume_uom_code,
		                                           x_return_status   => l_return_status);


			    IF l_debug_on THEN
				 WSH_DEBUG_SV.logmsg(l_module_name,'Return Status after get_default_uoms'||l_return_status);
			    END IF;

                IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                    FND_MESSAGE.SET_NAME('WSH','WSH_DLVY_NO_UOM');
                    FND_MESSAGE.SET_TOKEN('DELIVERY',l_dlvy_info_tab(i).l_delivery_id);
                    WSH_UTIL_CORE.add_message(l_return_status);
                    l_carrier_sel_entity_tab.DELETE(l_cnt);
                    GOTO dlvy_nextpass;
               END IF;
        ELSE
            l_carrier_sel_entity_tab(l_cnt).weight_uom_code         := 	l_dlvy_info_tab(i).l_weight_uom_code;
            l_carrier_sel_entity_tab(l_cnt).volume_uom_code         := 	l_dlvy_info_tab(i).l_volume_uom_code;
        END IF;

		--
		--Determine the ship to site id. if delivery is not inbound
		--
        IF l_dlvy_info_tab(i).l_shipment_direction <> 'I' THEN
           --l_dlvy_info_tab(i).l_delivery_type <> 'CONSOLIDATION' THEN
		    get_ship_to_site(
                          p_delivery_id	  =>  l_dlvy_info_tab(i).l_delivery_id,
                          p_delivery_type =>  l_dlvy_info_tab(i).l_delivery_type,
                          p_ultimate_dropoff_loc_id => l_dlvy_info_tab(i).l_ultimate_dropoff_location_id,
                          x_site_id       =>  l_carrier_sel_entity_tab(l_cnt).customer_site_id,
                          x_return_status =>  l_return_status);

		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Return Status after get_ship_to_site '||l_return_status);
		END IF;

        IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
              l_carrier_sel_entity_tab.DELETE(l_cnt);
              GOTO dlvy_nextpass;
        END IF;
	END IF;

                --
		-- At this stage we need to determine : Whether to use ship to / Sold to customer.
		--
		l_param_rec.organization_id := l_dlvy_info_tab(i).l_organization_id;
		l_param_rec.param_name(1)   := 'EVAL_RULE_BASED_ON_SHIPTO_CUST';


		WSH_SHIPPING_PARAMS_PVT.Get(x_param_value_info => l_param_rec ,
					    x_return_status    => l_return_status);

		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Return Status after getting shipping params '||l_return_status);
		END IF;

	IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
              l_carrier_sel_entity_tab.DELETE(l_cnt);
              GOTO dlvy_nextpass;
        END IF;
		--
        --Evaluate Rules based on ship to customer
		--
	IF (l_param_rec.PARAM_VALUE_CHR.EXISTS(1) AND l_param_rec.PARAM_VALUE_CHR(1) = 'Y'
                AND l_dlvy_info_tab(i).l_shipment_direction <> 'I') AND
           l_dlvy_info_tab(i).l_delivery_type <> 'CONSOLIDATION' THEN

			get_ship_to_customer( p_ult_dropoff_loc_id => l_dlvy_info_tab(i).l_ultimate_dropoff_location_id,
					      p_delivery_id	   => l_dlvy_info_tab(i).l_delivery_id,
					      x_customer_id	   => l_carrier_sel_entity_tab(l_cnt).customer_id,
					      x_return_status	   => l_return_status);

			IF l_debug_on THEN
			    WSH_DEBUG_SV.logmsg(l_module_name,'Return Status after get_ship_to_customer'||l_return_status);
			END IF;

	    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                  l_carrier_sel_entity_tab.DELETE(l_cnt);
                  GOTO dlvy_nextpass;
            END IF;
        ELSE
            l_carrier_sel_entity_tab(l_cnt).customer_id  := l_dlvy_info_tab(i).l_customer_id;
        END IF;

        l_cnt := l_cnt+1;

    ELSE
		FND_MESSAGE.SET_NAME('WSH','WSH_FTE_CS_DLVY_CONTENT');
		FND_MESSAGE.SET_TOKEN('DELIVERY',l_dlvy_info_tab(i).l_delivery_id);
		WSH_UTIL_CORE.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR);
    END IF;

    <<dlvy_nextpass>>
    EXIT WHEN i = l_dlvy_info_tab.LAST;
    i := l_dlvy_info_tab.NEXT(i);
   END LOOP;

   IF (l_carrier_sel_entity_tab.COUNT=0) THEN
         IF l_debug_on THEN
           wsh_debug_sv.logmsg(l_module_name, 'None of the selected deliveries have been found as eligible for Carrier Selection');
         END IF;
         -- All deliveries are content.
         FND_MESSAGE.SET_NAME('WSH','WSH_FTE_CS_DLVY_ALL_CONTENT');
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         WSH_UTIL_CORE.add_message(x_return_status);
         IF l_debug_on THEN
              	WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         RETURN;
   END IF;

   --
   -- Call Carrier Selection Engine
   --

   WSH_FTE_INTEGRATION.CARRIER_SELECTION( p_format_cs_tab	    => l_carrier_sel_entity_tab,
                      p_messaging_yn	        => l_messaging_yn,
                      p_caller	                => p_caller,
                      p_entity                  => 'DLVY',
                      x_cs_output_tab	        => l_cs_result_tab,
                      x_cs_output_message_tab   => l_cs_output_message_tab,
                      x_return_message	        => l_return_message,
                      x_return_status	        => l_return_status);

  IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS OR l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING)
                                    AND (l_cs_result_tab.COUNT > 0)  THEN

    --
    -- at least one result is found
    -- Now do a bulk update for all the carrier selection result tables
    --
     l_rec_attr_tab.DELETE;
     l_del_out_rec_tab.DELETE;
     l_return_status := null;
     l_rank_list_source := 'RG';

     --
     -- set the input record and tables
     --
     l_in_rec.caller      := 'FTE_CARRIER_SELECTION_AUTO';
     l_in_rec.phase       := null;
     l_in_rec.action_code := 'UPDATE';


     l_trip_in_rec.caller      := 'FTE_ROUTING_GUIDE';
     l_trip_in_rec.phase       := null;
     l_trip_in_rec.action_code := 'UPDATE';

     list_cnt := 1;


     l_prev_delivery_id := 0;
     l_prev_org_id      := 0;
     l_start_index      := 0;
     l_end_index        := 0;

/*
-- Hiding project
     WSH_SHIPPING_PARAMS_PVT.Get_Global_Parameters( x_Param_Info => l_global_param_rec,
                                                    x_return_status => l_return_status);
*/ -- Hiding project

     rec_cnt := l_cs_result_tab.FIRST;

     -- Loop through result tab in order to create/update trip for each delivery
     IF rec_cnt IS NOT NULL THEN

     LOOP
      --{

        --
        l_delivery_id := l_cs_result_tab(rec_cnt).delivery_id;

        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'l_delivery_id', l_delivery_id);
            WSH_DEBUG_SV.log(l_module_name, 'l_prev_delivery_id', l_prev_delivery_id);
            WSH_DEBUG_SV.log(l_module_name, 'rec_cnt', rec_cnt);
        END IF;

        -- get the value of trip_id if delivery is assigned to trip
        IF l_delivery_id <> l_prev_delivery_id THEN
            l_trip_id := null;
            l_num_ranked_results := 1;
            OPEN check_del_assigned(l_delivery_id);
                FETCH check_del_assigned into l_trip_id, l_trip_rank_seq;
            CLOSE check_del_assigned;

            l_del_org_id := l_cs_result_tab(rec_cnt).organization_id;

/*
-- Hiding project
            IF l_del_org_id  <> l_prev_org_id THEN

                l_param_value_info.organization_id := l_del_org_id;
                l_param_value_info.param_name(1)   := 'SKIP_RTNG_RULE_AC_TRIP';

                WSH_SHIPPING_PARAMS_PVT.Get(x_param_value_info       => l_param_value_info,
                                            x_return_status          => l_return_status);
                l_skip_rtng_rule_ac_trip := l_param_value_info.PARAM_VALUE_CHR(1);
            END IF;
*/ -- Hiding project

        END IF;

        l_del_result_type := l_cs_result_tab(rec_cnt).result_type;

        -- If first delivery has 1 ranked result and 2nd delivery has multileg results.
        -- How will the rank for first get inserted into ranklist table

        -- Handled by moving rank list insertion in the same pass of the last result record
        -- for a delivery

        IF (l_del_result_type = 'RANK') THEN -- if single leg delivery
        --{
            IF (l_delivery_id <> l_prev_delivery_id) THEN
            --{
                --l_carrier_sel_result_rec := l_cs_result_tab(rec_cnt);

                IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name, 'l_num_ranked_results', l_num_ranked_results);
                    WSH_DEBUG_SV.log(l_module_name, 'p_caller', p_caller);
                    WSH_DEBUG_SV.log(l_module_name, 'l_skip_rtng_rule_ac_trip', l_skip_rtng_rule_ac_trip);
                    WSH_DEBUG_SV.log(l_module_name, 'list_cnt', list_cnt);
                END IF;

                --
                -- 1. For Manual flow, append_flag is always set to 'Y'
                -- For auto-flow, Check if only one ranked result is returned, set append flag to the value of
                -- global parameter EXPAND_CARRIER_RANKINGS, else set it to 'Y'
                --

                IF p_caller <> 'WSH_AUTO_CREATE_DEL_TRIP' THEN
/*
-- Hiding project
                IF p_caller <> 'WSH_AUTO_CREATE_DEL_TRIP' OR
                (p_caller = 'WSH_AUTO_CREATE_DEL_TRIP' AND l_skip_rtng_rule_ac_trip <> 'Y') THEN
*/ -- Hiding project
                --{
                    -- AG check that current record is not LAST
/*
-- Hiding project
                    IF p_caller IN ('WSH_AUTO_CREATE_DEL' ,'WSH_DLMG', 'WSH_AUTO_CREATE_DEL_TRIP')
                        AND ( rec_cnt = l_cs_result_tab.LAST OR
                            ( rec_cnt <> l_cs_result_tab.LAST AND l_cs_result_tab(l_cs_result_tab.NEXT(rec_cnt)).delivery_id <> l_delivery_id)) THEN
                    --{
                         l_cs_result_tab(rec_cnt).append_flag := l_global_param_rec.EXPAND_CARRIER_RANKINGS;
                    --}
                    ELSE
                    --{
                        l_cs_result_tab(rec_cnt).append_flag := 'Y';
                    --}
                    END IF;

                    IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name, 'append_flag', l_cs_result_tab(rec_cnt).append_flag);
                    END IF;
*/ -- Hiding project

                    IF l_trip_id IS NULL THEN
                    --{
                       --
                       -- If Pick up date is same as drop off date,
                       -- introduce a gap of 10 mins between pick up date and drop off date
                       --
                       l_carrier_sel_result_rec := l_cs_result_tab(rec_cnt);

                       IF l_carrier_sel_result_rec.pickup_date = l_carrier_sel_result_rec.dropoff_date THEN
                           l_carrier_sel_result_rec.dropoff_date := l_carrier_sel_result_rec.dropoff_date+(1/144);
                       END IF;

                       IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,'l_cs_result_tab(rec_cnt).pickup_date '||l_cs_result_tab(rec_cnt).pickup_date);
                            WSH_DEBUG_SV.logmsg(l_module_name,'l_cs_result_tab(rec_cnt).dropoff_date '||l_cs_result_tab(rec_cnt).dropoff_date);
                       END IF;
                        --
                        -- Since delivery not assigned to any trip( trip_id is null), and rank = 1, Create trip for the delivery
                        --
                        WSH_FTE_INTEGRATION.CARRIER_SEL_CREATE_TRIP(
                               p_delivery_id               => l_delivery_id,
                               p_carrier_sel_result_rec    => l_carrier_sel_result_rec,
                               x_trip_id                   => l_trip_id,
                               x_trip_name                 => l_trip_name,
                               x_return_message            => x_return_message,
                               x_return_status             => l_return_status);

                        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                            END IF;
                        END IF;

                        IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,'Return Status after calling CREATE_SEL_CREATE_TRIP '||x_return_status);
                            WSH_DEBUG_SV.logmsg(l_module_name,'Trip_id '||l_trip_id);
                        END IF;

                        l_ranked_list.DELETE;
                        list_cnt := 1;
                        l_num_ranked_results := 1;
                       --
                       -- set values in ranked list for rank #1 results
                       --
                       l_ranked_list(list_cnt).TRIP_ID                  := l_trip_id;
                       l_ranked_list(list_cnt).RANK_SEQUENCE            := l_cs_result_tab(rec_cnt).rank;
                       l_ranked_list(list_cnt).CARRIER_ID               := l_cs_result_tab(rec_cnt).carrier_id;
                       l_ranked_list(list_cnt).SERVICE_LEVEL            := l_cs_result_tab(rec_cnt).service_level;
                       l_ranked_list(list_cnt).MODE_OF_TRANSPORT        := l_cs_result_tab(rec_cnt).mode_of_transport;
                       l_ranked_list(list_cnt).CONSIGNEE_CARRIER_AC_NO  := l_cs_result_tab(rec_cnt).consignee_carrier_ac_no;
                       l_ranked_list(list_cnt).FREIGHT_TERMS_CODE       := l_cs_result_tab(rec_cnt).freight_terms_code;
                       l_ranked_list(list_cnt).SOURCE                   := l_rank_list_source;
                       l_ranked_list(list_cnt).IS_CURRENT               := 'Y';
                       l_ranked_list(list_cnt).CALL_RG_FLAG             := 'N';

                       IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,'Populated Ranked List for rank #1');
                       END IF;

                        --
                        -- set l_cs_result_tab(rec_cnt) := NULL so that this record is not updated in
                        -- the call to FORMAT_DEL_UPDATE_TABLE
                        --
                       l_cs_result_tab(rec_cnt) := NULL;

                    --}
                    ELSE -- for the case when delivery is already attached to trip, l_trip_id IS NOT NULL
                    --{
                        IF l_trip_rank_seq is NOT NULL THEN
                            FND_MESSAGE.SET_NAME('WSH','WSH_FTE_CS_UPD_TRIP_RANK_LIST');
                            FND_MESSAGE.SET_TOKEN('TRIPID',l_trip_id);
                            x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
                            WSH_UTIL_CORE.add_message(x_return_status);
                        END IF;

                        l_cs_result_tab(rec_cnt).trip_id := l_trip_id;

                        l_ranked_list(list_cnt).TRIP_ID             := l_trip_id;
                        l_ranked_list(list_cnt).RANK_SEQUENCE       := l_cs_result_tab(rec_cnt).rank;
                        l_ranked_list(list_cnt).CARRIER_ID          := l_cs_result_tab(rec_cnt).carrier_id;
                        l_ranked_list(list_cnt).SERVICE_LEVEL       := l_cs_result_tab(rec_cnt).service_level;
                        l_ranked_list(list_cnt).MODE_OF_TRANSPORT   := l_cs_result_tab(rec_cnt).mode_of_transport;
                        l_ranked_list(list_cnt).CONSIGNEE_CARRIER_AC_NO  := l_cs_result_tab(rec_cnt).consignee_carrier_ac_no;
                        l_ranked_list(list_cnt).FREIGHT_TERMS_CODE  := l_cs_result_tab(rec_cnt).freight_terms_code;
                        l_ranked_list(list_cnt).SOURCE              := l_rank_list_source;
                        l_ranked_list(list_cnt).IS_CURRENT          := 'Y';
                        l_ranked_list(list_cnt).CALL_RG_FLAG        := 'N';
                    --}
                    END IF;
                --}
                END IF;
            --}
            ELSE  -- l_delivery_id = l_prev_delivery_id
            --{
                l_num_ranked_results := l_num_ranked_results +1;

                IF p_caller <> 'WSH_AUTO_CREATE_DEL_TRIP' THEN
/*
-- Hiding project
                IF p_caller <> 'WSH_AUTO_CREATE_DEL_TRIP' OR
                    (p_caller = 'WSH_AUTO_CREATE_DEL_TRIP' AND l_skip_rtng_rule_ac_trip <> 'Y') THEN
*/ -- Hiding project
                --{
                    IF p_caller IN ('WSH_AUTO_CREATE_DEL' ,'WSH_DLMG', 'WSH_AUTO_CREATE_DEL_TRIP') THEN
                    --{

                    --
                    --  When Ranked List is created by RG engine during auto flow and if
                    --  only one ranked result is returned, set CALL_RG_FLAG flag to 'N'
                    --  If there are more than one ranked results, we'll set CALL_RG_FLAG flag to 'Y'
                    --
                        l_ranked_list(list_cnt).CALL_RG_FLAG    := 'Y';
                    --}
                    ELSE
                    --{
                        --
                        -- If caller is not Auto-Flow, build ranked list for other rank results as well
                        --
                        list_cnt := list_cnt + 1;

                        l_ranked_list(list_cnt).TRIP_ID         := l_trip_id;
                        l_ranked_list(list_cnt).RANK_SEQUENCE   := l_cs_result_tab(rec_cnt).rank;
                        l_ranked_list(list_cnt).CARRIER_ID      := l_cs_result_tab(rec_cnt).carrier_id;
                        l_ranked_list(list_cnt).SERVICE_LEVEL   := l_cs_result_tab(rec_cnt).service_level;
                        l_ranked_list(list_cnt).MODE_OF_TRANSPORT := l_cs_result_tab(rec_cnt).mode_of_transport;
                        l_ranked_list(list_cnt).CONSIGNEE_CARRIER_AC_NO  := l_cs_result_tab(rec_cnt).consignee_carrier_ac_no;
                        l_ranked_list(list_cnt).FREIGHT_TERMS_CODE       := l_cs_result_tab(rec_cnt).freight_terms_code;
                        l_ranked_list(list_cnt).SOURCE          := l_rank_list_source;
                        l_ranked_list(list_cnt).IS_CURRENT      := 'N';
                        l_ranked_list(list_cnt).CALL_RG_FLAG    := 'N';
                   --}
                    END IF;

                    IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name, 'l_ranked_list(list_cnt).CALL_RG_FLAG', l_ranked_list(list_cnt).CALL_RG_FLAG);
                    END IF;
                --}
                END IF;
                --
                -- set l_cs_result_tab(rec_cnt) := NULL so that this record is not updated in
                -- the call to FORMAT_DEL_UPDATE_TABLE
                --
                l_cs_result_tab(rec_cnt) := NULL;
            --}
            END IF;
            IF (rec_cnt = l_cs_result_tab.LAST OR
            (rec_cnt <> l_cs_result_tab.LAST AND l_cs_result_tab(l_cs_result_tab.NEXT(rec_cnt)).delivery_id <> l_delivery_id)) THEN
            --{
                IF p_caller <> 'WSH_AUTO_CREATE_DEL_TRIP' THEN
/*
-- Hiding project
                IF p_caller <> 'WSH_AUTO_CREATE_DEL_TRIP' OR
                    (p_caller = 'WSH_AUTO_CREATE_DEL_TRIP' AND l_skip_rtng_rule_ac_trip <> 'Y') THEN

                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name, 'calling RANK_LIST_ACTION');
                    END IF;

                    WSH_FTE_INTEGRATION.RANK_LIST_ACTION(
                               --p_api_version_number =>  1.0,
                               --p_init_msg_list      =>  FND_API.G_FALSE,
                               x_return_status      =>  l_return_status,
                               x_msg_count          =>  l_msg_count,
                               x_msg_data           =>  l_msg_data,
                               p_action_code        =>  'REPLACE',
                               p_ranklist           =>  l_ranked_list,
                               p_trip_id            =>  l_trip_id,
                               p_rank_id            =>  l_rank_id);

                    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                            raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                    END IF;
*/ -- Hiding project
                    l_ranked_list.DELETE;
                    list_cnt := 1;
                    l_num_ranked_results := 1;
                END IF;
            --}
            END IF;
        --}
        ELSIF (l_del_result_type = 'MULTILEG') THEN  -- if multileg delivery output
        --{

            IF l_trip_id IS NOT NULL THEN
            --{
                -- if delivery is already assigned to trip and multileg route to be created as per rule results
                 -- show error;
                FND_MESSAGE.SET_NAME('WSH','WSH_FTE_CS_DEL_MLEG_ASG_TRIP');
                FND_MESSAGE.SET_TOKEN('DELIVERY_ID',l_delivery_id);
                FND_MESSAGE.SET_TOKEN('TRIP_ID',l_trip_id);
                x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                WSH_UTIL_CORE.add_message(x_return_status);

                l_cs_result_tab(rec_cnt) := NULL;

                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'DELIVERY '||l_delivery_id || ' IS ALREADY ASSIGNED TO TRIP '||l_trip_id);
                END IF;
             --}
             ELSIF p_caller = 'WSH_AUTO_CREATE_DEL_TRIP' AND l_skip_rtng_rule_ac_trip = 'Y' THEN
             --{
                IF l_delivery_id <> l_prev_delivery_id THEN
                    FND_MESSAGE.SET_NAME('WSH','WSH_FTE_CS_MULTILEG');
                    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                    WSH_UTIL_CORE.add_message(x_return_status);
                END IF;

                l_cs_result_tab(rec_cnt) := NULL;
             --}
             ELSIF p_caller <> 'WSH_AUTO_CREATE_DEL_TRIP' OR
                    (p_caller = 'WSH_AUTO_CREATE_DEL_TRIP' AND l_skip_rtng_rule_ac_trip <> 'Y') THEN -- create trip for all the legs
             --{

                l_prev_delivery_id := 0;
                l_start_index := rec_cnt;
                i := 1;
                j := 1;

                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'l_start_index '||l_start_index);
                END IF;
                --
                -- For multileg results, first we need to get all the legs for a delivery
                -- in l_cs_mleg_result_tab. Then set pick up and drop off dates for leg pick
                -- up and drop off stops in a call to SET_PICK_UP_DROP_OFF_DATES API
                --

                IF l_delivery_id <> l_prev_delivery_id THEN
                   LOOP
                        l_cs_mleg_result_tab(i) := l_cs_result_tab(rec_cnt);

                        EXIT WHEN rec_cnt = l_cs_result_tab.LAST;
                        l_prev_delivery_id      := l_delivery_id;
                        rec_cnt                 := l_cs_result_tab.NEXT(rec_cnt);
                        l_delivery_id           := l_cs_result_tab(rec_cnt).delivery_id;
                        i := i + 1;
                        EXIT WHEN l_delivery_id <> l_prev_delivery_id;
                    END LOOP;

                    IF (rec_cnt <> l_cs_result_tab.FIRST AND rec_cnt <> l_cs_result_tab.LAST) THEN
                        rec_cnt         := l_cs_result_tab.PRIOR(rec_cnt);
                        l_delivery_id   := l_cs_result_tab(rec_cnt).delivery_id;
                    END IF;

                    l_end_index     := rec_cnt;

                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'l_end_index '||l_end_index);
                    END IF;

                    SET_PICK_UP_DROP_OFF_DATES(
                            p_cs_mleg_result_tab => l_cs_mleg_result_tab,
                            x_return_status    =>  x_return_status,
                            x_msg_count        =>  l_msg_count,
                            x_msg_data         =>  l_msg_data);

                    k := l_cs_mleg_result_tab.FIRST;

                    FOR j IN l_start_index .. l_end_index LOOP
                        --
                        -- Set pick up and drop off dates for each leg in result tab
                        -- and Create Trip for each leg
                        --
                        l_cs_result_tab(j).pickup_date  := l_cs_mleg_result_tab(k).pickup_date;
                        l_cs_result_tab(j).dropoff_date := l_cs_mleg_result_tab(k).dropoff_date;

                        IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,'l_cs_result_tab(j).pickup_date :'||to_char(l_cs_result_tab(j).pickup_date, 'dd/mm/yyyy hh:mi:ss'));
                            WSH_DEBUG_SV.logmsg(l_module_name,'l_cs_result_tab(j).initial_pickup_location_id: '||l_cs_result_tab(j).initial_pickup_location_id);
                            WSH_DEBUG_SV.logmsg(l_module_name,'l_cs_result_tab(j).dropoff_date :'||to_char(l_cs_result_tab(j).dropoff_date,'dd/mm/yyyy hh:mi:ss'));
                            WSH_DEBUG_SV.logmsg(l_module_name,'l_cs_result_tab(j).ultimate_dropoff_location_id: '||l_cs_result_tab(j).ultimate_dropoff_location_id);
                        END IF;

                        l_carrier_sel_result_rec := l_cs_result_tab(j);
                        WSH_FTE_INTEGRATION.CARRIER_SEL_CREATE_TRIP(
                                  p_delivery_id               => l_delivery_id,
                                  p_carrier_sel_result_rec    => l_carrier_sel_result_rec,
                                  x_trip_id                   => l_trip_id,
                                  x_trip_name                 => l_trip_name,
                                  x_return_message            => x_return_message,
                                  x_return_status             => l_return_status);

                         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                            END IF;
                        END IF;
                        l_cs_result_tab(j).trip_id              := l_trip_id;

                        IF p_caller IN ('WSH_AUTO_CREATE_DEL' ,'WSH_DLMG', 'WSH_AUTO_CREATE_DEL_TRIP') THEN
                            l_cs_result_tab(j).append_flag      := l_global_param_rec.EXPAND_CARRIER_RANKINGS;
                        ELSE
                            l_cs_result_tab(j).append_flag      := 'Y';
                        END IF;

                        l_ranked_list(list_cnt).TRIP_ID             := l_trip_id;
                        l_ranked_list(list_cnt).RANK_SEQUENCE       := l_carrier_sel_result_rec.rank;
                        l_ranked_list(list_cnt).CARRIER_ID          := l_carrier_sel_result_rec.carrier_id;
                        l_ranked_list(list_cnt).SERVICE_LEVEL       := l_carrier_sel_result_rec.service_level;
                        l_ranked_list(list_cnt).MODE_OF_TRANSPORT   := l_carrier_sel_result_rec.mode_of_transport;
                        l_ranked_list(list_cnt).CONSIGNEE_CARRIER_AC_NO  := l_carrier_sel_result_rec.consignee_carrier_ac_no;
                        l_ranked_list(list_cnt).FREIGHT_TERMS_CODE  := l_carrier_sel_result_rec.freight_terms_code;
                        l_ranked_list(list_cnt).SOURCE              := l_rank_list_source;
                        l_ranked_list(list_cnt).IS_CURRENT          := 'Y';
                        l_ranked_list(list_cnt).CALL_RG_FLAG        := 'N';

                        --
                        -- Create and attach ranked list to each trip
                        --

	                    WSH_FTE_INTEGRATION.RANK_LIST_ACTION(
--                           p_api_version_number =>  1.0,
--                           p_init_msg_list      =>  FND_API.G_FALSE,
                           x_return_status      =>  l_return_status,
                           x_msg_count          =>  l_msg_count,
                           x_msg_data           =>  l_msg_data,
                           p_action_code        =>  'REPLACE',
                           p_ranklist           =>  l_ranked_list,
                           p_trip_id            =>  l_trip_id,
                           p_rank_id            =>  l_rank_id);

                         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                            END IF;
                        END IF;
                        l_ranked_list.DELETE;
                        list_cnt := 1;

                        k := l_cs_mleg_result_tab.NEXT(k);

                   END LOOP;
                END IF;
              --}
             END IF;
           --}
       END IF;
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'set l_prev_delivery_id and l_prev_trip_id');
           WSH_DEBUG_SV.log(l_module_name, 'l_delivery_id', l_delivery_id);
           WSH_DEBUG_SV.log(l_module_name, 'l_trip_id', l_trip_id);
       END IF;
       l_prev_delivery_id := l_delivery_id;
       l_prev_trip_id     := l_trip_id;

       EXIT WHEN rec_cnt = l_cs_result_tab.LAST;
       rec_cnt := l_cs_result_tab.NEXT(rec_cnt);
      --}
      END LOOP;
    END IF;

    --
    -- Format the delivery table for the call to the group API
    --

    FORMAT_DEL_UPDATE_TABLE(p_cs_result_tab     => l_cs_result_tab,
                            p_caller            => p_caller,
                            x_rec_attr_tab      => l_rec_attr_tab,
                            x_trip_info_tab     => l_trip_info_tab,
                            x_return_status     => l_return_status,
                            x_return_message    => x_return_message);


    IF (l_rec_attr_tab.COUNT > 0) THEN
     --
     -- Update the deliveries table with the info
     --
        WSH_INTERFACE_GRP.Create_Update_Delivery(p_api_version_number => 1.0,
                                  p_init_msg_list      => 'F',
                                  p_commit             => null,
                                  p_in_rec             => l_in_rec,
                                  p_rec_attr_tab       => l_rec_attr_tab,
                                  x_del_out_rec_tab    => l_del_out_rec_tab,
                                  x_return_status      => l_return_status,
                                  x_msg_count          => l_msg_count,
                                  x_msg_data           => l_msg_data);


         IF ((l_return_status is not null) AND
         (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS)) THEN
            --
            -- delivery not updated
            --
            x_return_status  := l_return_status;
            WSH_UTIL_CORE.add_message(x_return_status);
                --
            -- Debug Statements
                --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,  'CARRIER SELECTION - AUTO CREATE - COULD NOT UPDATE DELIVERY');
            END IF;
                --
            x_return_message := l_msg_data;

            IF l_debug_on THEN
               WSH_DEBUG_SV.pop(l_module_name);
            END IF;
                --
            RETURN;
         END IF;

    END IF;



    IF (l_trip_info_tab.COUNT > 0) THEN
    --{
            WSH_INTERFACE_GRP.Create_Update_Trip(
               p_api_version_number => 1.0,
               p_init_msg_list      => 'F',
               p_commit             => null,
               x_return_status      => l_return_status,
               x_msg_count          => l_msg_count,
               x_msg_data           => l_msg_data,
               p_trip_info_tab      => l_trip_info_tab,
               p_in_rec             => l_trip_in_rec,
               x_out_tab            => l_trip_out_rec_tab);

            IF ((l_return_status is not null) AND
                 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS)) THEN

                --
                -- trip not updated
                --
                x_return_status  := l_return_status;
                WSH_UTIL_CORE.add_message(x_return_status);
                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,  'CARRIER SELECTION - FORM MANUAL - COULD NOT UPDATE TRIP');
                END IF;
                --
                x_return_message := l_msg_data;
                --
                -- Return back to the calling API or form
                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                   WSH_DEBUG_SV.pop(l_module_name);
                END IF;
                --
                RETURN;
            END IF;
      --}
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
   WHEN OTHERS THEN
      l_error_code := SQLCODE;
      l_error_text := SQLERRM;

      WSH_UTIL_CORE.default_handler('WSH_NEW_DELIVERY_ACTIONS.PROCESS_CARRIER_SELECTION');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      x_return_message := l_error_text;


      IF l_debug_on THEN
	WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END PROCESS_CARRIER_SELECTION;
--SBAKSHI(R12)


/**________________________________________________________________________
--
-- Name:
-- Assign_Del_to_Consol_Del
--
-- Purpose:
-- This API assigns a deliveries to a parent (consolidation)
-- delivery. If the caller is FTE consolidation SRS, we
-- assume that the child deliveries have already been validated
-- as eligible to be assigned to the parent delivery.
-- Parameters:
-- p_del_tab: Table of deliveries that need to be assigned
-- p_parent_del: Parent delivery id that will be assigne to
-- p_caller: Calling entity/action
-- x_return_status: status
**/

Procedure Assign_Del_to_Consol_Del(
          p_del_tab         IN WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type,
          p_parent_del_id   IN NUMBER,
          p_caller          IN VARCHAR2,
          x_return_status   OUT NOCOPY VARCHAR2) IS

-- make sure the parent is OPEN and is of type 'CONSOLIDATION'
CURSOR c_check_valid_parent(p_parent_del_id in NUMBER) IS
select s1.trip_id,
       l.pick_up_stop_id,
       l.drop_off_stop_id,
       l.delivery_leg_id,
       d.ultimate_dropoff_location_id dropoff_stop_location,
       s1.stop_location_id pickup_stop_location,
       t.ignore_for_planning,
       s1.planned_arrival_date pu_ar_date,
       s1.planned_departure_date pu_dep_date,
       s2.planned_arrival_date do_ar_date,
       s2.planned_departure_date do_dep_date
from wsh_trip_stops s1, wsh_trip_stops s2, wsh_delivery_legs l, wsh_new_deliveries d, wsh_trips t
where s1.stop_id = l.pick_up_stop_id
and s2.stop_id = l.drop_off_stop_id
and l.delivery_id = d.delivery_id
and d.delivery_id = p_parent_del_id
and d.status_code = 'OP'
and d.delivery_type = 'CONSOLIDATION'
and s1.trip_id = t.trip_id ;


-- make sure that the delivery is open, STANDARD and
-- is not assigned to a parent delivery.
cursor c_check_valid_child(p_delivery_id in number) is
select d.delivery_id
from wsh_new_deliveries d
where d.delivery_id = p_delivery_id
and d.status_code = 'OP'
and d.delivery_type = 'STANDARD'
and not exists (select 1 from wsh_delivery_legs
                where parent_delivery_leg_id is not null
                and delivery_id = d.delivery_id);
-- check if the delivery is assigned to a trip
/*cursor c_check_trips(p_delivery_id in number) is
select delivery_leg_id
from wsh_delivery_legs
where delivery_id = p_delivery_id
and rownum = 1;
*/
-- check if the trip the delivery is assigned to is valid
cursor c_check_trips(p_delivery_id in number) is
select l.delivery_leg_id, s1.trip_id
from wsh_delivery_legs l, wsh_trip_stops s1, wsh_new_deliveries d
where l.delivery_id = p_delivery_id
and   d.delivery_id = l.delivery_id
and   d.initial_pickup_location_id = s1.stop_location_id
and   s1.stop_id = l.pick_up_stop_id;

l_parent_trip_rec c_check_valid_parent%rowtype;
type l_trip_rec_tab_type is table of c_check_trips%rowtype index by binary_integer;
l_trip_rec_tab l_trip_rec_tab_type;


cursor c_get_top_child_details(p_delivery_id in number) is
select a.delivery_detail_id
from wsh_delivery_assignments a
where a.delivery_id is not null
and a.delivery_id = p_delivery_id
and a.type = 'O'
and a.parent_delivery_detail_id is null
and not exists
(select '1'
 from wsh_delivery_assignments b
 where a.delivery_detail_id = b.delivery_detail_id
 and b.type = 'C');

-- This cursor selects all the trips that are
-- assigned to all the deliveries that are
-- assigned to the original trip.
-- These trips will be set to ignore for planning
-- along with the original trip.

cursor c_get_trip_siblings(p_trip_id in number) is
select distinct s2.trip_id
from wsh_trip_stops s1, wsh_trip_stops s2,
     wsh_delivery_legs l1, wsh_delivery_legs l2
where s1.trip_id = p_trip_id
and s1.stop_id = l1.pick_up_stop_id
and l1.delivery_id = l2.delivery_id
and l2.pick_up_stop_id = s2.stop_id;


cursor c_chil_del_trips(p_delivery_id in number) is
select s.trip_id
from wsh_trip_stops s, wsh_delivery_legs l
where l.delivery_id = p_delivery_id
and   l.pick_up_stop_id = s.stop_id;

l_parent_trip_id NUMBER;
l_child_trip_id NUMBER;
l_parent_del_id NUMBER;
l_dropoff_loc_id NUMBER;
l_child_details_tab wsh_util_core.id_tab_type;
l_valid_children_tab wsh_util_core.id_tab_type;
l_unassigned_trips_tab wsh_util_core.id_tab_type;
l_assigned_trips_tab wsh_util_core.id_tab_type;
l_delivery_leg_id_dummy NUMBER;
l_trip_id_tab wsh_util_core.id_tab_type;
l_wv_delivery_tab wsh_util_core.id_tab_type;
l_unassign_dels wsh_util_core.id_tab_type;
l_ignore_plan_dels wsh_util_core.id_tab_type;
l_include_plan_dels wsh_util_core.id_tab_type;
l_change_plan_dels wsh_util_core.id_tab_type;
l_child_del_trips  wsh_util_core.id_tab_type;
l_child_del_trips_dummy  wsh_util_core.id_tab_type;
l_parent_del_tab wsh_util_core.id_tab_type;
l_intermediate_loc_id NUMBER;
l_dummy_child NUMBER;
l_gross_wt NUMBER;
l_net_wt NUMBER;
l_volume NUMBER;

l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
i NUMBER := 0;
j NUMBER := 0;
k NUMBER := 0;
l NUMBER := 0;
m NUMBER := 0;
n NUMBER := 0;
o NUMBER := 0;
p NUMBER := 0;
q NUMBER := 0;

l_num_warnings              NUMBER  := 0;
l_num_errors                NUMBER  := 0;
l_return_status             VARCHAR2(30);

l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Assig_Del_to_Consol_del';
l_debug_on BOOLEAN;

WSH_FAIL_ASSIGN_DEL_TO_CONSOL     EXCEPTION;
WSH_INVALID_PARENT EXCEPTION;
WSH_INVALID_CHILDREN EXCEPTION;
WSH_INVALID_DECONSOL_POINT EXCEPTION;
WSH_INVALID_TRIP EXCEPTION;


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
     WSH_DEBUG_SV.log(l_module_name,'p_parent_del_id', p_parent_del_id);
     WSH_DEBUG_SV.log(l_module_name,'p_caller', p_caller);
   END IF;

   OPEN c_check_valid_parent(p_parent_del_id);
   FETCH c_check_valid_parent INTO l_parent_trip_rec;
   IF c_check_valid_parent%NOTFOUND THEN
      CLOSE c_check_valid_parent;
      -- RAISE EXCEPTION
      RAISE WSH_INVALID_PARENT;
   END IF;
   CLOSE c_check_valid_parent;

   -- If caller is WSH_AUTOCREATE_CONSOL no need to validate as grouping of deliveries and
   -- deconsol point has already been figured out
   IF p_caller <> 'WSH_AUTOCREATE_CONSOL' THEN

      i := p_del_tab.FIRST;

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'p_del_tab.count', p_del_tab.count);
         WSH_DEBUG_SV.log(l_module_name,'p_del_tab.first', p_del_tab.first);
      END IF;
      WHILE i IS NOT NULL LOOP

        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'delivery: '||i, p_del_tab(i).delivery_id);
           WSH_DEBUG_SV.log(l_module_name,'initial_pickup_location_id: '||i, p_del_tab(i).initial_pickup_location_id);
           WSH_DEBUG_SV.log(l_module_name,'l_parent_trip_rec.pickup_stop_location: '||i, l_parent_trip_rec.pickup_stop_location);
        END IF;

        IF p_del_tab(i).initial_pickup_location_id = l_parent_trip_rec.pickup_stop_location THEN

          OPEN c_check_valid_child(p_del_tab(i).delivery_id);
          FETCH c_check_valid_child INTO l_dummy_child;
          IF c_check_valid_child%FOUND THEN
             IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_dummy_child', l_dummy_child);
             END IF;

             CLOSE  c_check_valid_child;
             OPEN c_check_trips(p_del_tab(i).delivery_id);
             FETCH c_check_trips INTO l_delivery_leg_id_dummy, l_child_trip_id;
             IF c_check_trips%NOTFOUND THEN
             -- This delivery is not assigned to any trip at pu location, so we can assign it to the trip.
             -- Nothing to validate.
                j := j+1;
                k := k+1;
                l_valid_children_tab(j) := p_del_tab(i).delivery_id;
                l_unassigned_trips_tab(k) := p_del_tab(i).delivery_id;
                IF p_del_tab(i).ignore_for_planning = 'Y' THEN
                   n := n + 1;
                   l_ignore_plan_dels(n) := p_del_tab(i).delivery_id;
                ELSE
                   o := o + 1;
                   l_include_plan_dels(o) := p_del_tab(i).delivery_id;
                END IF;

             ELSIF p_caller = 'WMS_AUTOCREATE_CONSOL' THEN
             -- Called by autocreate_consol_del for WMS, if the delivery is already
             -- assigned to trips, then they must be assigned to a valid trip since
             -- autocreate_consol_del already validates the trips.
                j := j+1;
                m := m+1;
                l_valid_children_tab(j) := p_del_tab(i).delivery_id;
                l_assigned_trips_tab(m) := p_del_tab(i).delivery_id;
             ELSE
             -- If we are assigning the delivery to an already existing parent delivery, ie. not being
             -- called by autocreate_consol_del and the delivery has at least one trip, we need to
             -- make sure that there is a valid trip on the delivery.

                IF l_child_trip_id <> l_parent_trip_rec.trip_id THEN
                   -- RAISE EXCEPTION
                   -- delivery is not in valid trip
                   CLOSE c_check_trips;
                   RAISE WSH_INVALID_TRIP;

                ELSE
                   l_unassign_dels(1) := p_del_tab(i).delivery_id;
                   IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'WSH_TRIPS_ACTIONS.Unassign_Trip',WSH_DEBUG_SV.C_PROC_LEVEL);
                   END IF;
                   WSH_TRIPS_ACTIONS.Unassign_Trip(p_del_rows => l_unassign_dels,
                                                   p_trip_id  => l_parent_trip_rec.trip_id,
                                                   x_return_status => l_return_status);

                   wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );

                   j := j+1;
                   k := k+1;
                   l_valid_children_tab(j) := p_del_tab(i).delivery_id;
                   l_unassigned_trips_tab(k) := p_del_tab(i).delivery_id;
                   IF p_del_tab(i).ignore_for_planning = 'Y' THEN
                      n := n + 1;
                      l_ignore_plan_dels(n) := p_del_tab(i).delivery_id;
                   ELSE
                      o := o + 1;
                      l_include_plan_dels(o) := p_del_tab(i).delivery_id;
                   END IF;
                END IF;
             END IF;
             CLOSE c_check_trips;
          END IF;
          IF c_check_valid_child%ISOPEN THEN
             CLOSE c_check_valid_child;
          END IF;

        END IF;
        i := p_del_tab.next(i);

      END LOOP;

   ELSE

      FOR i in 1..p_del_tab.count LOOP
        l_valid_children_tab(i) := p_del_tab(i).delivery_id;
        l_unassigned_trips_tab(i) := p_del_tab(i).delivery_id;
        IF p_del_tab(i).ignore_for_planning = 'Y' THEN
           n := n + 1;
           l_ignore_plan_dels(n) := p_del_tab(i).delivery_id;
        ELSE
           o := o + 1;
           l_include_plan_dels(o) := p_del_tab(i).delivery_id;
        END IF;
      END LOOP;

   END IF;



   IF l_valid_children_tab.count = 0 THEN
      -- ERROR!!!
      -- No valid deliveries were assigned to parent.
      RAISE WSH_INVALID_CHILDREN;

   END IF;

   BEGIN
     FOR i in 1..l_valid_children_tab.count LOOP
       WSH_DELIVERY_DETAILS_PKG.lock_wda_no_compare(p_delivery_id => l_valid_children_tab(i));
     END LOOP;

   EXCEPTION
     WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('WSH','WSH_DLVY_LOCK_FAILED');
        FND_MESSAGE.Set_Token('DEL_NAME', WSH_NEW_DELIVERIES_PVT.Get_Name(l_valid_children_tab(i)));
        WSH_UTIL_CORE.Add_Message(x_return_status);
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'WSH_DLVY_LOCK_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_DLVY_LOCK_FAILED');
        END IF;
        RETURN;
        --
   END;
   FORALL i in 1..l_valid_children_tab.count
         update wsh_delivery_assignments
         set type = 'O'
         where delivery_id = l_valid_children_tab(i)
         and delivery_id is not null
         and nvl(type, 'S') = 'S'
         and parent_delivery_detail_id is NULL;

   FOR i in 1..l_valid_children_tab.count LOOP

      OPEN c_get_top_child_details(l_valid_children_tab(i));
      FETCH c_get_top_child_details BULK COLLECT
      INTO l_child_details_tab;
      CLOSE c_get_top_child_details;

      Forall k in 1..l_child_details_tab.count
      INSERT INTO wsh_delivery_assignments (
      delivery_id,
      parent_delivery_id,
      delivery_detail_id,
      parent_delivery_detail_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      program_application_id,
      program_id,
      program_update_date,
      request_id,
      active_flag,
      delivery_assignment_id,
      type
      ) VALUES (
      l_valid_children_tab(i),
      p_parent_del_id,
      l_child_details_tab(k),
      NULL,
      SYSDATE,
      FND_GLOBAL.USER_ID,
      SYSDATE,
      FND_GLOBAL.USER_ID,
      FND_GLOBAL.USER_ID,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      wsh_delivery_assignments_s.nextval,
      'C'
      );


   END LOOP;


   -- Assign child delivery to parents' trip

   l_trip_id_tab(1) := l_parent_trip_rec.trip_id;

   IF l_include_plan_dels.count > 0 THEN

      IF l_parent_trip_rec.ignore_for_planning = 'Y' THEN
         -- Make the child deliveries ignore for planning before assignment.
         FOR i in 1..l_include_plan_dels.count LOOP

             OPEN c_chil_del_trips(l_include_plan_dels(i));
             FETCH c_chil_del_trips BULK COLLECT
             INTO l_child_del_trips_dummy;
             IF c_chil_del_trips%NOTFOUND THEN
                p := p + 1;
                l_change_plan_dels(p) := l_include_plan_dels(i);
             ELSE
                q := l_child_del_trips.count;
                FOR i in 1..l_child_del_trips_dummy.count LOOP
                    l_child_del_trips(q + i) := l_child_del_trips_dummy(i);
                END LOOP;
                l_child_del_trips_dummy.delete;
             END IF;
             CLOSE c_chil_del_trips;

         END LOOP;

         IF l_child_del_trips.count > 0 THEN

            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'WSH_TP_RELEASE.change_ignoreplan_status',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            WSH_TP_RELEASE.change_ignoreplan_status
                   (p_entity        => 'TRIP',
                    p_in_ids        => l_child_del_trips,
                    p_action_code   => 'IGNORE_PLAN',
                    x_return_status => l_return_status);

            wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );
         END IF;

         IF l_change_plan_dels.count > 0 THEN
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'WSH_TP_RELEASE.change_ignoreplan_status',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            WSH_TP_RELEASE.change_ignoreplan_status
                   (p_entity        => 'DLVY',
                    p_in_ids        => l_change_plan_dels,
                    p_action_code   => 'IGNORE_PLAN',
                    x_return_status => l_return_status);

            wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );
         END IF;

      END IF;

      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'WSH_TRIPS_ACTIONS.assign_trip for ignore plan = N',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      WSH_TRIPS_ACTIONS.assign_trip(
                p_del_rows            =>  l_include_plan_dels,
                p_trip_id             =>  l_trip_id_tab(1),
                p_pickup_stop_id      =>  l_parent_trip_rec.pick_up_stop_id,
                p_dropoff_stop_id     =>  l_parent_trip_rec.drop_off_stop_id,
                p_pickup_location_id  =>  l_parent_trip_rec.pickup_stop_location,
                p_dropoff_location_id =>  l_parent_trip_rec.dropoff_stop_location,
                p_pickup_arr_date     =>  l_parent_trip_rec.pu_ar_date,
                p_pickup_dep_date     =>  l_parent_trip_rec.pu_dep_date,
                p_dropoff_arr_date    =>  l_parent_trip_rec.do_ar_date,
                p_dropoff_dep_date    =>  l_parent_trip_rec.do_dep_date,
                x_return_status       =>  l_return_status);

      wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );
   END IF;

   IF NVL(l_parent_trip_rec.ignore_for_planning, 'N') = 'N' THEN
      -- Set ignore for planning flag of child deliveries and their related trips.
      l_trip_id_tab.delete;
      OPEN c_get_trip_siblings(l_parent_trip_rec.trip_id);
      FETCH c_get_trip_siblings BULK COLLECT
      INTO l_trip_id_tab;
      CLOSE c_get_trip_siblings;

      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'WSH_TP_RELEASE.change_ignoreplan_status',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      WSH_TP_RELEASE.change_ignoreplan_status
                   (p_entity        => 'TRIP',
                    p_in_ids        => l_trip_id_tab,
                    p_action_code   => 'IGNORE_PLAN',
                    x_return_status => l_return_status);

      wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );

   END IF;
   IF l_ignore_plan_dels.count > 0 THEN

      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'WSH_TRIPS_ACTIONS.assign_trip for ignore plan = Y',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

      WSH_TRIPS_ACTIONS.assign_trip(
                p_del_rows            =>  l_ignore_plan_dels,
                p_trip_id             =>  l_trip_id_tab(1),
                p_pickup_stop_id      =>  l_parent_trip_rec.pick_up_stop_id,
                p_dropoff_stop_id     =>  l_parent_trip_rec.drop_off_stop_id,
                p_pickup_location_id  =>  l_parent_trip_rec.pickup_stop_location,
                p_dropoff_location_id =>  l_parent_trip_rec.dropoff_stop_location,
                p_pickup_arr_date     =>  l_parent_trip_rec.pu_ar_date,
                p_pickup_dep_date     =>  l_parent_trip_rec.pu_dep_date,
                p_dropoff_arr_date    =>  l_parent_trip_rec.do_ar_date,
                p_dropoff_dep_date    =>  l_parent_trip_rec.do_dep_date,
                x_return_status       =>  l_return_status);



      wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );
   END IF;

   BEGIN

     FOR i in 1..l_valid_children_tab.count LOOP
       WSH_DELIVERY_LEGS_PVT.lock_dlvy_leg_no_compare(p_delivery_id => l_valid_children_tab(i));
     END LOOP;

   EXCEPTION
     WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('WSH','WSH_DLVY_LOCK_FAILED');
        FND_MESSAGE.Set_Token('DEL_NAME', WSH_NEW_DELIVERIES_PVT.Get_Name(l_valid_children_tab(i)));
        WSH_UTIL_CORE.Add_Message(x_return_status);
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'WSH_DLVY_LOCK_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_DLVY_LOCK_FAILED');
        END IF;
        RETURN;
        --
   END;
   -- Assign child delivery legs to parent
   FORALL i in 1..l_valid_children_tab.count
        update wsh_delivery_legs
        set parent_delivery_leg_id  = l_parent_trip_rec.delivery_leg_id
        where delivery_id = l_valid_children_tab(i)
        and pick_up_stop_id = l_parent_trip_rec.pick_up_stop_id;

   IF P_CALLER = 'WSH_AUTOCREATE_CONSOL' THEN
   -- Calculate Wt/Volume of the consolidation delivery
   -- if caller is WSH_AUTOCREATE_CONSOL.
   -- We recalculate the wt/vol of delivery during the assignment of
   -- consol lpns, so no need to do it here for WMS.

     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_WV_UTILS.Delivery_Weight_Volume',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     WSH_WV_UTILS.Delivery_Weight_Volume
                ( p_delivery_id    => p_parent_del_id,
                  p_update_flag    => 'Y',
                  p_calc_wv_if_frozen => 'N',
                  x_gross_weight   => l_gross_wt,
                  x_net_weight     => l_net_wt,
                  x_volume         => l_volume,
                  x_return_status  => l_return_status);

     wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );
   END IF;

   l_parent_del_tab(1) := p_parent_del_id;
   WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required(
                 p_entity_type => 'DELIVERY',
                 p_entity_ids   => l_parent_del_tab,
                 x_return_status => l_return_status);

   wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );



   IF l_valid_children_tab.count < p_del_tab.count THEN

      -- Not all deliveries were assigned to parent.
      FND_MESSAGE.SET_NAME('WSH', 'WSH_PARTIAL_CONSOL_ASSIGN');
      FND_MESSAGE.SET_TOKEN('DEL_COUNT', 'l_valid_children_tab.count');
      wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
      l_num_warnings := l_num_warnings + 1;
    END IF;

    IF l_num_errors > 0
    THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    ELSIF l_num_warnings > 0
    THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    ELSE
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    END IF;


IF l_debug_on THEN
wsh_debug_sv.pop(l_module_name);
END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    IF c_check_trips%ISOPEN THEN
      CLOSE c_check_trips;
    END IF;
    IF c_get_top_child_details%ISOPEN THEN
      CLOSE c_get_top_child_details;
    END IF;
    IF c_get_trip_siblings%ISOPEN THEN
      CLOSE c_get_trip_siblings;
    END IF;
    IF c_check_valid_parent%ISOPEN THEN
      CLOSE c_check_valid_parent;
    END IF;
    IF c_check_valid_child%ISOPEN THEN
      CLOSE c_check_valid_child;
    END IF;


    --
    -- Debug Statements
    --
    IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
    END IF;

 WHEN WSH_INVALID_TRIP THEN
   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    IF c_check_trips%ISOPEN THEN
      CLOSE c_check_trips;
    END IF;
    IF c_get_top_child_details%ISOPEN THEN
      CLOSE c_get_top_child_details;
    END IF;
    IF c_get_trip_siblings%ISOPEN THEN
      CLOSE c_get_trip_siblings;
    END IF;
    IF c_check_valid_parent%ISOPEN THEN
      CLOSE c_check_valid_parent;
    END IF;
    IF c_check_valid_child%ISOPEN THEN
      CLOSE c_check_valid_child;
    END IF;
   FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_TRIP');
   WSH_UTIL_CORE.Add_Message(x_return_status);
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
   WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INVALID_TRIP exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);

   WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_TRIP');
   END IF;

 WHEN WSH_INVALID_DECONSOL_POINT THEN
   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    IF c_check_trips%ISOPEN THEN
      CLOSE c_check_trips;
    END IF;
    IF c_get_top_child_details%ISOPEN THEN
      CLOSE c_get_top_child_details;
    END IF;
    IF c_get_trip_siblings%ISOPEN THEN
      CLOSE c_get_trip_siblings;
    END IF;
    IF c_check_valid_parent%ISOPEN THEN
      CLOSE c_check_valid_parent;
    END IF;
    IF c_check_valid_child%ISOPEN THEN
      CLOSE c_check_valid_child;
    END IF;
   FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_DECONSOL_POINT');
   WSH_UTIL_CORE.Add_Message(x_return_status);
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
   WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INVALID_DECONSOL_POINT exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);

   WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_DECONSOL_POINT');
   END IF;

 WHEN WSH_INVALID_CHILDREN THEN
   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    IF c_check_trips%ISOPEN THEN
      CLOSE c_check_trips;
    END IF;
    IF c_get_top_child_details%ISOPEN THEN
      CLOSE c_get_top_child_details;
    END IF;
    IF c_get_trip_siblings%ISOPEN THEN
      CLOSE c_get_trip_siblings;
    END IF;
    IF c_check_valid_parent%ISOPEN THEN
      CLOSE c_check_valid_parent;
    END IF;
    IF c_check_valid_child%ISOPEN THEN
      CLOSE c_check_valid_child;
    END IF;
   FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CHILDREN');
   WSH_UTIL_CORE.Add_Message(x_return_status);
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
   WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INVALID_CHILDREN exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);

   WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_CHILDREN');
   END IF;

 WHEN WSH_INVALID_PARENT THEN
    IF c_check_trips%ISOPEN THEN
      CLOSE c_check_trips;
    END IF;
    IF c_get_top_child_details%ISOPEN THEN
      CLOSE c_get_top_child_details;
    END IF;
    IF c_get_trip_siblings%ISOPEN THEN
      CLOSE c_get_trip_siblings;
    END IF;
    IF c_check_valid_parent%ISOPEN THEN
      CLOSE c_check_valid_parent;
    END IF;
    IF c_check_valid_child%ISOPEN THEN
      CLOSE c_check_valid_child;
    END IF;
   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_PARENT');
   WSH_UTIL_CORE.Add_Message(x_return_status);
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
   WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INVALID_PARENT exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);

   WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_PARENT');
   END IF;
   --

 WHEN WSH_FAIL_ASSIGN_DEL_TO_CONSOL THEN
    IF c_check_trips%ISOPEN THEN
      CLOSE c_check_trips;
    END IF;
    IF c_get_top_child_details%ISOPEN THEN
      CLOSE c_get_top_child_details;
    END IF;
    IF c_get_trip_siblings%ISOPEN THEN
      CLOSE c_get_trip_siblings;
    END IF;
    IF c_check_valid_parent%ISOPEN THEN
      CLOSE c_check_valid_parent;
    END IF;
    IF c_check_valid_child%ISOPEN THEN
      CLOSE c_check_valid_child;
    END IF;
   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   FND_MESSAGE.SET_NAME('WSH','WSH_FAIL_ASSIGN_DEL_TO_CONSOL');
   WSH_UTIL_CORE.Add_Message(x_return_status);
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
   WSH_DEBUG_SV.logmsg(l_module_name,'WSH_FAIL_ASSIGN_DEL_TO_CONSOL exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);

   WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_FAIL_ASSIGN_DEL_TO_CONSOL');
   END IF;
   --


  WHEN OTHERS THEN
    IF c_check_trips%ISOPEN THEN
      CLOSE c_check_trips;
    END IF;
    IF c_get_top_child_details%ISOPEN THEN
      CLOSE c_get_top_child_details;
    END IF;
    IF c_get_trip_siblings%ISOPEN THEN
      CLOSE c_get_trip_siblings;
    END IF;
    IF c_check_valid_parent%ISOPEN THEN
      CLOSE c_check_valid_parent;
    END IF;
    IF c_check_valid_child%ISOPEN THEN
      CLOSE c_check_valid_child;
    END IF;
    wsh_util_core.default_handler('wsh_new_delivery_actions.Assign_Del_to_Consol_Del',l_module_name);
      --
    IF l_debug_on THEN
      wsh_debug_sv.pop(l_module_name, 'EXCEPTION:OTHERS');
    END IF;

END Assign_Del_to_Consol_Del;

--
-- Name:
-- Unassign_Dels_from_Consol_Del
--
-- Purpose:
-- This API unassigns deliveries from a parent (consolidation)
-- delivery. If the parent delivery becomes empty we delete the
-- parent delivery. Currently this will be called with
-- assumption that all and only all deliveries in the parent
-- delivery will be unassigned all at the same time.
--
-- Parameters:
-- p_del_tab: Table of deliveries that need to be unassigned
-- p_parent_del_ids: Parent deliveries that will be unassigned from
-- and eventually deleted.
-- p_caller: Calling entity/action
-- x_return_status: status


Procedure Unassign_Dels_from_Consol_Del(
          p_parent_del     IN NUMBER,
          p_caller         IN VARCHAR2,
          p_del_tab        IN OUT NOCOPY wsh_util_core.id_tab_type,
          x_return_status  OUT NOCOPY VARCHAR2) IS

CURSOR c_check_parent_exists(p_child_delivery_id in number, p_parent_delivery_id in number) IS
select l1.delivery_id, l2.delivery_id, l1.delivery_leg_id, s.trip_id
from wsh_delivery_legs l1, wsh_delivery_legs l2, wsh_new_deliveries d, wsh_trip_stops s
where l1.parent_delivery_leg_id = l2.delivery_leg_id
and   l1.delivery_id = p_child_delivery_id
and   l2.delivery_id = NVL(p_parent_delivery_id, l2.delivery_id)
and   d.delivery_id = l1.delivery_id
and   d.status_code = 'OP'
and   s.stop_id = l1.pick_up_stop_id
order by s.trip_id, l2.delivery_id;

cursor c_check_children_exists(p_parent_delivery_id in number) is
select l1.delivery_id
from wsh_delivery_legs l1, wsh_delivery_legs l2
where l1.parent_delivery_leg_id = l2.delivery_leg_id
and   l2.delivery_id = p_parent_delivery_id
and rownum = 1;

CURSOR c_get_children(p_parent_delivery_id IN NUMBER) is
select l1.delivery_id, l1.delivery_leg_id, s.trip_id
from wsh_delivery_legs l1, wsh_delivery_legs l2, wsh_new_deliveries d, wsh_trip_stops s
where l1.parent_delivery_leg_id = l2.delivery_leg_id
and   l2.delivery_id = p_parent_delivery_id
and   d.delivery_id = l1.delivery_id
and   d.status_code = 'OP'
and   l1.pick_up_stop_id = s.stop_id;

CURSOR check_consol_lpns(p_delivery_id in number) is
select parent_delivery_detail_id
from wsh_delivery_assignments
where delivery_id = p_delivery_id
and delivery_id is not null
and parent_delivery_detail_id IS NOT NULL
and type = 'C'
and rownum = 1;

l_parent_dels_tab wsh_util_core.id_tab_type;
l_assigned_dels_tab wsh_util_core.id_tab_type;
l_trip_tab wsh_util_core.id_tab_type;
l_delete_parent_dels wsh_util_core.id_tab_type;
l_remaining_parent_dels wsh_util_core.id_tab_type;
l_child_legs_tab wsh_util_core.id_tab_type;
l_trip_tab_dummy wsh_util_core.id_tab_type;
l_distinct_parent_dels_tab wsh_util_core.id_tab_type;

l_parent_del_id_dummy NUMBER;
l_parent_lpn_id_dummy NUMBER;
l_child_leg_id_dummy NUMBER;
l_consol_lpn_dummy   NUMBER;
l_child_del_dummy     NUMBER;
l_trip_dummy     NUMBER;
l_detail_id           NUMBER;
l_parent_included     VARCHAR2(1);
l_dummy_id    NUMBER;
l_assigned_dels_dummy NUMBER;
l_parent_dels_dummy   NUMBER;
l_child_legs_dummy    NUMBER;
l_gross_weight        NUMBER;
l_net_weight          NUMBER;
l_volume             NUMBER;

i NUMBER := 0;
j NUMBER := 0;
k NUMBER := 0;
l NUMBER := 0;
m NUMBER := 0;

l_num_warnings              NUMBER  := 0;
l_num_errors                NUMBER  := 0;
l_return_status             VARCHAR2(30);

WSH_INVALID_CHILD_DELIVERIES EXCEPTION;
WSH_NO_OPEN_CHILD_DELIVERIES EXCEPTION;

l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Unassign_Dels_from_Consol_Del';
l_debug_on BOOLEAN;

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
        WSH_DEBUG_SV.log(l_module_name,'p_parent_del', p_parent_del);
        WSH_DEBUG_SV.log(l_module_name,'p_caller', p_caller);
        WSH_DEBUG_SV.log(l_module_name,'p_del_tab.count', p_del_tab.count);
      END IF;

      IF p_del_tab.count = 0 and p_parent_del IS NULL THEN

         -- raise exception
         RAISE WSH_INVALID_CHILD_DELIVERIES;

      ELSIF p_del_tab.count = 0 THEN

         -- unassign all children from the parent

         OPEN c_get_children(p_parent_del);
         FETCH c_get_children BULK COLLECT
         INTO l_assigned_dels_tab, l_child_legs_tab, l_trip_tab_dummy;
         CLOSE c_get_children;

	 IF (l_assigned_dels_tab.COUNT = 0) THEN
	   RAISE WSH_NO_OPEN_CHILD_DELIVERIES;
	 END IF;

         l_parent_dels_tab(1) := p_parent_del;
         l_trip_tab(1) := l_trip_tab_dummy(1);
         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_assigned_dels_tab(1)', l_assigned_dels_tab(1));
           WSH_DEBUG_SV.log(l_module_name,'l_child_legs_tab(1)', l_child_legs_tab(1));
           WSH_DEBUG_SV.log(l_module_name,'l_parent_dels_tab(1)', l_parent_dels_tab(1));
           WSH_DEBUG_SV.log(l_module_name,'l_trip_tab(1)', l_trip_tab(1));
         END IF;
      ELSE

      -- Check if the deliveries are assigned to parent dels.
        FOR del in 1..p_del_tab.count LOOP
          OPEN c_check_parent_exists(p_del_tab(del), p_parent_del);
          FETCH c_check_parent_exists
          INTO l_assigned_dels_dummy, l_parent_dels_dummy, l_child_legs_dummy, l_trip_dummy;
          IF c_check_parent_exists%FOUND THEN
             i := i + 1;
             l_assigned_dels_tab(i) := l_assigned_dels_dummy;
             l_parent_dels_tab(i) := l_parent_dels_dummy;
             l_child_legs_tab(i) := l_child_legs_dummy;
             l_trip_tab(i) := l_trip_dummy;
          END IF;
          CLOSE c_check_parent_exists;
        END LOOP;

      END IF;

      -- Check if the child deliveries have consol LPN's.
      -- If yes, do not unassign this delivery.
      -- and WSH cannot unpack from WMS orgs.

      FOR i in 1..l_assigned_dels_tab.count LOOP
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'looping thru del: ', l_assigned_dels_tab(i));
          END IF;

          OPEN check_consol_lpns(l_assigned_dels_tab(i));
          FETCH check_consol_lpns INTO l_consol_lpn_dummy;
            IF check_consol_lpns%FOUND THEN
               CLOSE check_consol_lpns;
               FND_MESSAGE.SET_NAME('WSH','WSH_FAIL_UNASSIGN_DEL_LPN');
               FND_MESSAGE.SET_TOKEN('DELIVERY_NAME', WSH_NEW_DELIVERIES_PVT.Get_Name(l_assigned_dels_tab(i)));
               l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
               wsh_util_core.add_message(l_return_status, l_module_name);
               wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );
            END IF;
          CLOSE check_consol_lpns;

          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'after looping thru del: ', l_assigned_dels_tab(i));
          END IF;

      END LOOP;

      IF l_assigned_dels_tab.count = 0 THEN

         -- None of the deliveries were assigned to parents

         RAISE WSH_INVALID_CHILD_DELIVERIES;


      END IF;

      BEGIN

        FOR i in 1..l_assigned_dels_tab.count LOOP
          WSH_DELIVERY_DETAILS_PKG.lock_wda_no_compare(p_delivery_id => l_assigned_dels_tab(i));
        END LOOP;

      EXCEPTION
        WHEN OTHERS THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           FND_MESSAGE.SET_NAME('WSH','WSH_DLVY_LOCK_FAILED');
           FND_MESSAGE.Set_Token('DEL_NAME', WSH_NEW_DELIVERIES_PVT.Get_Name(l_assigned_dels_tab(i)));
           WSH_UTIL_CORE.Add_Message(x_return_status);
           --
           -- Debug Statements
           --
           IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'WSH_DLVY_LOCK_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_DLVY_LOCK_FAILED');
           END IF;
           RETURN;
           --
      END;
      -- Delete the consolidation record for the child

      FORALL i in 1..l_assigned_dels_tab.count
         delete wsh_delivery_assignments
         where type = 'C'
         and delivery_id in l_assigned_dels_tab(i);

      -- Update the child deliveries record to indicate no consolidation.

      FORALL i in 1..l_assigned_dels_tab.count
         update wsh_delivery_assignments
         set type  = 'S'
         where delivery_id in l_assigned_dels_tab(i)
         and type = 'O';


      -- Unassign child delivery legs from the parents' trip/leg


      IF p_parent_del IS NOT NULL THEN

         l_distinct_parent_dels_tab(1) := p_parent_del;
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'only parent ', l_distinct_parent_dels_tab(1));
         END IF;

      ELSE

         FOR i in 1..l_assigned_dels_tab.count LOOP

            IF i = l_assigned_dels_tab.count OR l_parent_dels_tab(i) <> l_parent_dels_tab(i + 1) THEN

               k := k + 1;
               l_distinct_parent_dels_tab(k) := l_parent_dels_tab(i);
               IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'distinct parents ', l_distinct_parent_dels_tab(k));
               END IF;

            END IF;


         END LOOP;


      END IF;

      BEGIN

        FOR i in 1..l_child_legs_tab.count LOOP

          WSH_DELIVERY_LEGS_PVT.lock_dlvy_leg_no_compare(p_dlvy_leg_id => l_child_legs_tab(i));

        END LOOP;

      EXCEPTION
        WHEN OTHERS THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           FND_MESSAGE.SET_NAME('WSH','WSH_DLVY_DEL_LEG_LOCK');
           FND_MESSAGE.Set_Token('DEL_NAME', WSH_NEW_DELIVERIES_PVT.Get_Name(l_assigned_dels_tab(i)));
           WSH_UTIL_CORE.Add_Message(x_return_status);
           --
           -- Debug Statements
           --
           IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'WSH_DLVY_LOCK_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_DLVY_LOCK_FAILED');
           END IF;
           RETURN;
           --
      END;

      FORALL i in 1..l_child_legs_tab.count
      update wsh_delivery_legs
      set parent_delivery_leg_id = NULL
      where delivery_leg_id = l_child_legs_tab(i);


      -- Separate the empty parent deliveries.
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'l_distinct_parent_dels_tab.count ', l_distinct_parent_dels_tab.count);
      END IF;

      FOR i in 1..l_distinct_parent_dels_tab.count LOOP
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'loop thru del: ', l_distinct_parent_dels_tab(i));
      END IF;

          OPEN c_check_children_exists(l_distinct_parent_dels_tab(i));
          FETCH c_check_children_exists INTO l_dummy_id;
          IF c_check_children_exists%FOUND THEN
             l := l + 1;
             l_remaining_parent_dels(l) := l_distinct_parent_dels_tab(i);
             IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_remaining_parent_dels ', l_remaining_parent_dels(l));
             END IF;
           ELSE
             m := m + 1;
             l_delete_parent_dels(m) := l_distinct_parent_dels_tab(i);
             IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_delete_parent_dels ', l_delete_parent_dels(m));
             END IF;
           END IF;
           CLOSE c_check_children_exists;

      END LOOP;

      -- Delete the parent deliveries if empty. This will
      -- also take care of deleting the parents' legs as well

     IF l_delete_parent_dels.count > 0 THEN

       IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.Delete',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;


       WSH_UTIL_CORE.Delete(
        p_type            => 'DLVY',
        p_rows            => l_delete_parent_dels,
        p_caller          => p_caller,
        x_return_status   => l_return_status);

        -- Handle return status.
       wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );

     END IF;
     IF l_remaining_parent_dels.count > 0 THEN
      -- Update the wt/vol on the remaining parents.

       IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_WV_UTILS.Delivery_Weight_Volume',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;

       FOR i in 1..l_remaining_parent_dels.count LOOP

          WSH_WV_UTILS.Delivery_Weight_Volume (
                  p_delivery_id       => l_remaining_parent_dels(i),
                  p_update_flag       => 'Y',
                  p_calc_wv_if_frozen => 'N',
                  x_gross_weight      => l_gross_weight,
                  x_net_weight        => l_net_weight,
                  x_volume            => l_volume,
                  x_return_status     => l_return_status);

          wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );

       END LOOP;

       WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required(
                 p_entity_type => 'DELIVERY',
                 p_entity_ids   => l_remaining_parent_dels,
                 x_return_status => l_return_status);

       wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );

       Confirm_Consolidation_Delivery(
             p_consol_del_tab   => l_remaining_parent_dels,
             x_return_status    => l_return_status);

       wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );

    END IF;

    IF l_num_errors > 0
    THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    ELSIF l_num_warnings > 0
    THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    ELSE
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;

EXCEPTION
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

 WHEN WSH_NO_OPEN_CHILD_DELIVERIES THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       FND_MESSAGE.SET_NAME('WSH','WSH_NO_OPEN_DELIVERIES');
       WSH_UTIL_CORE.Add_Message(x_return_status);
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'WSH_NO_OPEN_CHILD_DELIVERIES exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);

       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_NO_OPEN_CHILD_DELIVERIES');
       END IF;
        --

 WHEN WSH_INVALID_CHILD_DELIVERIES THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CHILD_DELIVERIES');
       WSH_UTIL_CORE.Add_Message(x_return_status);
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INVALID_CHILD_DELIVERIES exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);

       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_CHILD_DELIVERIES');
       END IF;
        --
 WHEN OTHERS THEN
    wsh_util_core.default_handler('wsh_new_delivery_actions.Unassign_Dels_from_Consol_Del',l_module_name);
    --
    IF c_check_parent_exists%ISOPEN THEN
      CLOSE c_check_parent_exists;
    END IF;
    --
    IF c_check_children_exists%ISOPEN THEN
      CLOSE c_check_children_exists;
    END IF;
    --
    IF c_get_children%ISOPEN THEN
      CLOSE c_get_children;
    END IF;
    --
    IF check_consol_lpns%ISOPEN THEN
      CLOSE check_consol_lpns;
    END IF;
    --
    IF l_debug_on THEN
      wsh_debug_sv.pop(l_module_name, 'EXCEPTION:OTHERS');
    END IF;

END Unassign_Dels_from_Consol_Del;


PROCEDURE Confirm_Consolidation_Delivery(
           p_consol_del_tab IN wsh_util_core.id_tab_type,
           x_return_status OUT NOCOPY VARCHAR2) IS

cursor c_check_close_consol(p_del_id IN NUMBER) IS
select d.delivery_id
from wsh_delivery_legs l1, wsh_delivery_legs l2, wsh_new_deliveries d
where l1.parent_delivery_leg_id = l2.delivery_leg_id
and   l2.delivery_id = p_del_id
and   l1.delivery_id = d.delivery_id
and   d.status_code = 'OP'
and   rownum = 1;

l_u_consol_del_tab wsh_util_core.id_tab_type;
l_co_consol_del_tab wsh_util_core.id_tab_type;
l_number_of_lpn_tab wsh_util_core.id_tab_type;
l_delivery_id NUMBER;
l_lpn_number  NUMBER;
i NUMBER;
j NUMBER := 0;
l_exists_flag VARCHAR2(1);
l_lock_index NUMBER;


CURSOR c_get_child_lpn_number(p_delivery_id IN NUMBER) IS
select count(*)
from wsh_delivery_assignments da,
     wsh_delivery_details dd
where da.type = 'C'
and   da.parent_delivery_detail_id IS NULL
and   da.delivery_detail_id = dd.delivery_detail_id
and   dd.container_flag = 'Y'
and   da.parent_delivery_id = p_delivery_id
and   da.parent_delivery_id IS NOT NULL;

CURSOR c_get_consol_lpn_number(p_delivery_id in NUMBER) IS
select count(*)
from wsh_delivery_assignments
where type = 'S'
and delivery_id = p_delivery_id;

-- bug 4505105
cursor l_get_consol_del_org_csr (p_del_id IN NUMBER) is
select organization_id
from   wsh_new_deliveries
where  delivery_id = p_del_id;

l_return_status VARCHAR2(1);
l_del_valid_flag VARCHAR2(1);
l_org_id  NUMBER := 0;
l_num_warnings  NUMBER := 0;
l_num_err  NUMBER := 0;

-- bug 4505105


l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Confirm_Consolidation_Delivery';
l_debug_on BOOLEAN;

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
     END IF;

     -- bug 4505105
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
     -- bug 4505105

  -- collect the unique parent deliveries.
  -- p_consol_del_tab may not be gapless and
  -- may contain duplicates.
  i := p_consol_del_tab.FIRST;
  WHILE i IS NOT NULL LOOP
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Inside  WHILE i IS NOT NULL LOOP');
    END IF;
    l_exists_flag := 'N';
    FOR k in 1..l_u_consol_del_tab.count LOOP
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Inside FOR k in 1..l_u_consol_del_tab.count LOOP');
        END IF;
        IF l_u_consol_del_tab(k) = p_consol_del_tab(i) THEN
           l_exists_flag := 'Y';
           EXIT;
        END IF;
    END LOOP;
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'after FOR k in 1..l_u_consol_del_tab.count LOOP');
    END IF;
    IF l_exists_flag = 'N' THEN
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'i is', i);
           WSH_DEBUG_SV.log(l_module_name,'p_consol_del_tab(i)', p_consol_del_tab(i));
           WSH_DEBUG_SV.log(l_module_name,'l_u_consol_del_tab.count', l_u_consol_del_tab.count);
        END IF;
       l_u_consol_del_tab(l_u_consol_del_tab.count + 1) := p_consol_del_tab(i);
       OPEN c_check_close_consol(p_consol_del_tab(i));
       FETCH c_check_close_consol INTO l_delivery_id;
       IF c_check_close_consol%NOTFOUND THEN
          -- bug 4505105
          l_del_valid_flag := 'Y';
          l_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
          -- Keeping it commented because as of today
          -- this procedure will be called only for WMS org.
          --l_org_id := NULL;
          --open l_get_consol_del_org_csr(p_consol_del_tab(i));
          --fetch l_get_consol_del_org_csr into l_org_id;
          --close l_get_consol_del_org_csr;
          --IF (l_org_id is not null
          --    and wsh_util_validate.Check_Wms_Org(l_org_id)='Y'
          --   )
          --THEN
          --{
              validate_del_containers(p_consol_del_tab(i),
                                      'CONSOL',
                                      l_del_valid_flag,
                                      l_return_status);

              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_return_status after calling validate_del_containers', l_return_status);
              END IF;

              IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
                l_num_warnings := l_num_warnings + 1;
              END IF;
          --}
          --END IF;

          IF (nvl(l_del_valid_flag,'Y') = 'Y') THEN
            --
            j:= j+1;
            l_co_consol_del_tab(j) := p_consol_del_tab(i);
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_co_consol_del_tab(j)', l_co_consol_del_tab(j));
            END IF;
            --
          ELSE
            --
            l_num_warnings := l_num_warnings + 1;
            l_num_err := l_num_err + 1;
            --
          END IF;
          -- bug 4505105
       END IF;
       CLOSE c_check_close_consol;
       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'after c_check_close_consol');
       END IF;
    END IF;
  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'i', i);
  END IF;

  i := p_consol_del_tab.next(i);

  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'i', i);
  END IF;

  END LOOP;
  IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'After WHILE i IS NOT NULL LOOP');
  END IF;

  -- bug 4505105
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Count of consol deliveries to be processed is ', l_u_consol_del_tab.count);
    WSH_DEBUG_SV.log(l_module_name,'Count of errored deliveries is ', l_num_err);
  END IF;

  IF (l_num_err >= l_u_consol_del_tab.count AND l_num_err > 0) THEN
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'None of the Deliveries are eligible of Ship Confirm');
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  -- bug 4505105

  BEGIN
     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_co_consol_del_tab.count', l_co_consol_del_tab.count);
     END IF;

     FOR l in 1..l_co_consol_del_tab.count LOOP
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_co_consol_del_tab(l)', l_co_consol_del_tab(l));
        END IF;
        l_lock_index := l;
        WSH_NEW_DELIVERIES_PVT.Lock_Dlvy_No_Compare(l_co_consol_del_tab(l));

        l_lpn_number := 0;
        OPEN c_get_child_lpn_number(l_co_consol_del_tab(l));
        FETCH c_get_child_lpn_number
        INTO  l_lpn_number;
        CLOSE c_get_child_lpn_number;

        l_number_of_lpn_tab(l) := NVL(l_lpn_number, 0);
        l_lpn_number := 0;

        OPEN c_get_consol_lpn_number(l_co_consol_del_tab(l));
        FETCH c_get_consol_lpn_number
        INTO  l_lpn_number;
        CLOSE c_get_consol_lpn_number;

        l_number_of_lpn_tab(l) := l_number_of_lpn_tab(l) + NVL(l_lpn_number, 0);

     END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       FND_MESSAGE.SET_NAME('WSH','WSH_DLVY_LOCK_FAILED');
       FND_MESSAGE.Set_Token('ENTITY_NAME', WSH_NEW_DELIVERIES_PVT.Get_Name(l_co_consol_del_tab(l_lock_index)));
       WSH_UTIL_CORE.Add_Message(x_return_status);
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_DLVY_LOCK_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_DLVY_LOCK_FAILED');
       END IF;
       RETURN;
       --
  END;
  IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'after lock');
  END IF;
  IF l_co_consol_del_tab.count > 0 THEN
     FORALL m in 1..l_co_consol_del_tab.count
     UPDATE wsh_new_deliveries
     SET status_code = 'CO',
      number_of_lpn = decode(number_of_lpn, NULL, l_number_of_lpn_tab(m), number_of_lpn)
     WHERE delivery_id = l_co_consol_del_tab(m);
  END IF;

  -- bug 4505105
  IF (l_num_warnings > 0 and x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
  ELSE
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  END IF;
  -- bug 4505105

EXCEPTION
    -- bug 4505105
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    -- bug 4505105
  WHEN OTHERS THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    wsh_util_core.default_handler('wsh_new_delivery_actions.Confirm_Consolidation_Delivery',l_module_name);
      --
    IF l_debug_on THEN
      wsh_debug_sv.pop(l_module_name, 'EXCEPTION:OTHERS');
    END IF;

END Confirm_Consolidation_Delivery;


PROCEDURE Create_Deconsol_Trips(p_deliveries_tab IN wsh_util_core.id_tab_type,
                                x_return_status OUT NOCOPY VARCHAR2) IS
CURSOR c_del_info(p_delivery_id IN NUMBER) IS
SELECT parent.ultimate_dropoff_location_id pu_location,
       stop.planned_departure_date pu_date,
       child.ultimate_dropoff_location_id do_location,
       child.ultimate_dropoff_date do_date,
       child.ship_method_code,
       child.carrier_id,
       child.service_level,
       child.mode_of_transport,
       child.ignore_for_planning
FROM   wsh_new_deliveries child,
       wsh_new_deliveries parent,
       wsh_delivery_legs child_leg,
       wsh_delivery_legs parent_leg,
       wsh_trip_stops stop
WHERE  child_leg.delivery_id = p_delivery_id
AND    child_leg.parent_delivery_leg_id = parent_leg.delivery_leg_id
AND    child_leg.delivery_id = child.delivery_id
AND    parent_leg.delivery_id = parent.delivery_id
AND    child_leg.drop_off_stop_id = stop.stop_id
AND    child.ultimate_dropoff_location_id <> parent.ultimate_dropoff_location_id;

CURSOR c_second_leg(p_delivery_id IN NUMBER) IS
SELECT stop.trip_id
FROM   wsh_delivery_legs leg,
       wsh_trip_stops stop
WHERE  leg.parent_delivery_leg_id IS NULL
AND    leg.delivery_id = p_delivery_id
AND    leg.pick_up_stop_id = stop.stop_id;

l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Create_Deconsol_Trips';
l_debug_on BOOLEAN;


l_del_tab wsh_util_core.id_tab_type;
l_trip_tab wsh_util_core.id_tab_type;


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
l_num_warnings  NUMBER := 0;
l_num_errors  NUMBER := 0;
l_do_date   DATE;
i NUMBER;

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
END IF;

x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

i := p_deliveries_tab.FIRST;

WHILE i is NOT NULL LOOP


  FOR del in c_del_info(p_deliveries_tab(i)) LOOP

     l_del_tab(1) := p_deliveries_tab(i);

     -- Unassign all non-consol trips attached to
     -- delivery.

     FOR trip in c_second_leg(p_deliveries_tab(i)) LOOP

         WSH_TRIPS_ACTIONS.Unassign_Trip(
                p_del_rows           => l_del_tab,
                p_trip_id            => trip.trip_id,
                x_return_status      => l_return_status);

         WSH_UTIL_CORE.Api_Post_Call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );
     END LOOP;


     -- Create Trip

     l_trip_in_rec.caller := 'WSH_CONSOL';
     l_trip_in_rec.phase := NULL;
     l_trip_in_rec.action_code := 'CREATE';

     l_trip_info_tab.DELETE;
     l_trip_info_tab(1).ignore_for_planning := del.ignore_for_planning;
     l_trip_info_tab(1).ship_method_code := del.ship_method_code;
     l_trip_info_tab(1).service_level := del.service_level;
     l_trip_info_tab(1).mode_of_transport := del.mode_of_transport;
     l_trip_info_tab(1).carrier_id := del.carrier_id;

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

    wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );

    -- Assign delivery to trip

    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Assigning to deconsol trip');
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_ACTIONS.assign_trip',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;


    IF del.pu_date < del.do_date THEN
       l_do_date := del.do_date;
    ELSE
       l_do_date := del.pu_date + 1;
    END IF;

    WSH_TRIPS_ACTIONS.assign_trip(
                p_del_rows            =>  l_del_tab,
                p_trip_id             =>  l_trip_out_rec_tab(l_trip_out_rec_tab.FIRST).trip_id,
                p_pickup_location_id  =>  del.pu_location,
                p_dropoff_location_id =>  del.do_location,
                p_pickup_arr_date     =>  del.pu_date,
                p_pickup_dep_date     =>  del.pu_date,
                p_dropoff_arr_date    =>  l_do_date,
                p_dropoff_dep_date    =>  l_do_date,
                x_return_status       =>  l_return_status);

    wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );
  END LOOP;
i := p_deliveries_tab.NEXT(i);

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

IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
  WHEN OTHERS THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    wsh_util_core.default_handler('wsh_new_delivery_actions.Confirm_Consolidation_Delivery',l_module_name);
      --
    IF l_debug_on THEN
      wsh_debug_sv.pop(l_module_name, 'EXCEPTION:OTHERS');
    END IF;

END Create_Deconsol_Trips;


  --OTM R12
  ----------------------------------------------------------
  -- FUNCTION IS_DELIVERY_EMPTY
  --
  -- parameters:	p_delivery_id	delivery id to check for emptiness
  --
  -- description:	This procedure checks the delivery to see if there's any detail
  -- 			lines on the delivery.  Returns Y if yes, N if no, and E if errors out
  ----------------------------------------------------------
  FUNCTION IS_DELIVERY_EMPTY (p_delivery_id IN NUMBER) RETURN VARCHAR2 IS

  CURSOR c_delivery_detail_count(p_del_id IN NUMBER) IS
    SELECT 1
    FROM   wsh_delivery_assignments wda,
           wsh_delivery_details wdd
    WHERE  wda.delivery_id = p_del_id
    AND    wda.delivery_detail_id = wdd.delivery_detail_id
    AND    wdd.container_flag = 'N';

  l_count        NUMBER;
  l_return_value VARCHAR2(1);

  l_debug_on     BOOLEAN;
  --
  l_module_name  CONSTANT VARCHAR2(100) := 'wsh.plsql.' || g_pkg_name || '.' || 'IS_DELIVERY_EMPTY';
  --
  BEGIN

    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name, 'delivery id', p_delivery_id);
    END IF;

    l_count := 0;

    l_return_value := 'Y';  --defaulting to empty

    IF (p_delivery_id IS NOT NULL) THEN
      OPEN c_delivery_detail_count(p_delivery_id);
      FETCH c_delivery_detail_count INTO l_count;

      IF (c_delivery_detail_count%FOUND) THEN -- not empty

        IF l_debug_on THEN
          wsh_debug_sv.logmsg(l_module_name, 'Delivery is not empty');
        END IF;
        l_return_value := 'N';
      ELSE  -- empty
        IF l_debug_on THEN
          wsh_debug_sv.logmsg(l_module_name, 'Delivery is empty');
        END IF;
      	l_return_value := 'Y';
      END IF;
      CLOSE c_delivery_detail_count;
    ELSE
      l_return_value := WSH_UTIL_CORE.G_RET_STS_ERROR;
    END IF;

    IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name, 'RETURN VALUE', l_return_value);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --

    RETURN l_return_value;
  EXCEPTION

    WHEN OTHERS THEN
      wsh_util_core.default_handler('wsh_new_delivery_actions.is_delivery_empty',l_module_name);
      --
      IF (c_delivery_detail_count%ISOPEN) THEN
        CLOSE c_delivery_detail_count;
      END IF;
      l_return_value := WSH_UTIL_CORE.G_RET_STS_ERROR;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        wsh_debug_sv.LOG(l_module_name, 'RETURN VALUE', l_return_value);
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN l_return_value;
  END IS_DELIVERY_EMPTY;
  --END OTM R12

END WSH_NEW_DELIVERY_ACTIONS;

/
