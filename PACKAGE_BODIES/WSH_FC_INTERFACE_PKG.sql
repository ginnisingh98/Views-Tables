--------------------------------------------------------
--  DDL for Package Body WSH_FC_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_FC_INTERFACE_PKG" AS
/* $Header: WSHFCIFB.pls 120.4 2006/08/12 00:34:46 wrudge noship $ */
-- ----------------------------------------------------------------------------------------
-- Package Name: WSH_FC_INTERFACE_PKG
--
-- Use ':set tabstop=3' in vi command line to see the proper alignment
-- Name: Calculate_Association_Level_Cost
--
-- Goal: Calcuate distributed cost amount from association level
--       to delivery detail level according to cost factor
-- Parameter: p_Association_Level : Level the freight cost associated with
--            p_Association_Entity_Id : Depending on association level, this
--            parameter could be delivery_id,
--            container_instance_id..
--
-- ----------------------------------------------------------------------------------------

g_container_relationship   ContainerRelationshipTabType;

-- -----------------------------------------------------------------------------------------
-- This procedure is get cost relevant info of the delivery detail line
-- assigned to a entitiy. The parameter list contains entity level which could be
-- TRIP, STOP, DELIVERY , DETAIL, CONTAINER. This is procedure will search all the details
-- within that level. Also, this procedure will copy the entity id which is above the
-- searched level to the output table x_Relevant_Info_Tab.
-- For example, p_level= 'DELIVERY', p_delivery_id = 12345, and p_stop_id = 5555.
-- This procedure will find all the delivery details assigned to delivery 12345, and copy
-- stop id 5555 to each record of the stop_id column.
-- private procedure, primarily used by get_XXX_level_breakdown so it get the info from the
-- PL/SQL table instead of doing a data fetch.
-- ------------------------------------------------------------------------------------------
--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_FC_INTERFACE_PKG';
--
PROCEDURE Get_Relevant_Info(
      p_level        IN VARCHAR2,
      p_container_id    IN NUMBER   DEFAULT NULL,
      p_delivery_id     IN NUMBER   DEFAULT NULL,
      p_stop_id      IN NUMBER   DEFAULT NULL,
      p_trip_id      IN NUMBER   DEFAULT NULL,
      x_Relevant_Info_Tab  IN OUT NOCOPY    RelavantInfoTabType,
      x_return_status      OUT NOCOPY    VARCHAR2 )
IS

CURSOR c_content_details( c_container_id NUMBER) IS
SELECT   wdd.delivery_detail_id,
   -- bug 3935583
   wdd.inventory_item_id,
   wdd.requested_quantity,
   wdd.shipped_quantity,
   wdd.requested_quantity_uom,
   wdd.net_weight,
   wdd.weight_uom_code,
   wdd.volume,
   wdd.volume_uom_code,
   wdd.container_flag
FROM wsh_delivery_details wdd, wsh_delivery_assignments_v wda
WHERE wda.parent_delivery_detail_id = c_container_id  and
      wda.delivery_detail_id = wdd.delivery_detail_id and
      wdd.oe_interfaced_flag = 'N' and
      wdd.released_status = 'C' and
      NVL(wdd.shipped_quantity , 0) > 0 ;

CURSOR c_delivery_details( c_delivery_id NUMBER) IS
SELECT   dd.delivery_detail_id,
   -- bug 3935583
   dd.inventory_item_id,
   dd.requested_quantity,
   dd.shipped_quantity,
   dd.requested_quantity_uom,
   dd.net_weight,
   dd.weight_uom_code,
   dd.volume,
   dd.volume_uom_code
FROM wsh_delivery_details dd,
     wsh_delivery_assignments_v da,
     wsh_new_deliveries nd,
     oe_order_lines_all ol
WHERE      dd.delivery_detail_id = da.delivery_detail_id AND
         da.delivery_id = nd.delivery_id AND
         da.delivery_id IS NOT NULL AND
           ol.line_id = dd.source_line_id AND
           dd.source_code = 'OE' and
           nd.delivery_id = c_delivery_id AND
           dd.container_flag = 'N' AND
           dd.oe_interfaced_flag = 'N' and
           dd.released_status = 'C' and
           NVL(dd.shipped_quantity, 0) > 0;


CURSOR c_pickup_deliveries (c_stop_id NUMBER) IS
SELECT dg.delivery_id
FROM   wsh_delivery_legs dg,
       wsh_new_deliveries dl,
       wsh_trip_stops st
WHERE    st.stop_id = dg.pick_up_stop_id AND
         st.stop_id = c_stop_id AND
         st.stop_location_id = dl.initial_pickup_location_id AND
         dg.delivery_id = dl.delivery_id;

CURSOR c_trip_stops (c_trip_id  NUMBER) IS
SELECT stop_id
FROM   wsh_trip_stops
WHERE  trip_id = c_trip_id
AND    nvl(shipments_type_flag,'O') IN ('O','M');

l_detail_info        c_delivery_details%ROWTYPE;
l_content_detail_info      c_content_details%ROWTYPE;
l_counter         NUMBER := 0;
l_delivery_id        NUMBER := 0;
l_stop_id         NUMBER := 0;
l_return_status         VARCHAR2(1) := WSH_UTIL_CORE.G_RET_STS_SUCCESS ;
l_container_id       NUMBER := 0;
l_parent_container_id      NUMBER := 0;
l_find_parent        VARCHAR2(1) := 'F';
i           NUMBER := 0;

WSH_FC_INFO_ERR         EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_RELEVANT_INFO';
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
       WSH_DEBUG_SV.log(l_module_name,'P_LEVEL',P_LEVEL);
       WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_ID',P_CONTAINER_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_STOP_ID',P_STOP_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_TRIP_ID',P_TRIP_ID);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'BEGINNING OF GET_RELEVANT_INFO , LEVEL: ' || P_LEVEL || ' CONTAINER ID: ' || P_CONTAINER_ID || ' DELIVERY ID: ' || P_DELIVERY_ID || ' STOP ID: ' || P_STOP_ID || ' TRIP ID: ' || P_TRIP_ID );
      END IF;
      --
   l_counter := x_Relevant_Info_Tab.count;

   IF p_level = 'CONTAINER' THEN
      -- --------------------------------------------------------------
      -- Example: container C1 contains D and container C2;
      --          container C2 contains C and container C3;
      --          container C3 contains A and B
      -- The output in x_Relevant_Info_Tab will be
      --          delivery_detail_id          container_id
      --         ---------------------       ---------------
      --              D                          C1
      --              C                          C2
      --              C                          C1
      --              A                          C3
      --              A                          C2
      --              A                          C1
      --              B                          C3
      --              B                          C2
      --              B                          C1
      -- Later to calculat the prorated cost for the container C1,
      -- the code search for the records with container_id = C1, it finds
      --  D, C, A, B; for cost associated with container C2, it finds
      --  C, A, B; for cost associated with container C3, it finds
      --  A and B
      -- ---------------------------------------------------------------

      OPEN c_content_details(p_container_id);
      LOOP
         FETCH c_content_details INTO l_content_detail_info;
         EXIT WHEN c_content_details%NOTFOUND;
         IF l_content_detail_info.container_flag ='N' THEN
            l_counter := l_counter + 1;
            x_Relevant_Info_Tab(l_counter).delivery_detail_id := l_content_detail_info.delivery_detail_id;
            x_Relevant_Info_Tab(l_counter).container_id := p_container_id;
            x_Relevant_Info_Tab(l_counter).delivery_id := p_delivery_id;
            x_Relevant_Info_Tab(l_counter).stop_id := p_stop_id;
            x_Relevant_Info_Tab(l_counter).trip_id := p_trip_id;
            -- bug 3935583
            x_Relevant_Info_Tab(l_counter).inventory_item_id :=  l_content_detail_info.inventory_item_id;
            x_Relevant_Info_Tab(l_counter).requested_quantity := l_content_detail_info.requested_quantity;
            x_Relevant_Info_Tab(l_counter).shipped_quantity := l_content_detail_info.shipped_quantity;
            x_Relevant_Info_Tab(l_counter).requested_quantity_uom := l_content_detail_info.requested_quantity_uom;
            x_Relevant_Info_Tab(l_counter).net_weight := l_content_detail_info.net_weight;
            x_Relevant_Info_Tab(l_counter).weight_uom_code := l_content_detail_info.weight_uom_code;
            x_Relevant_Info_Tab(l_counter).volume := l_content_detail_info.volume;
            x_Relevant_Info_Tab(l_counter).volume_uom_code := l_content_detail_info.volume_uom_code;
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name, 'X_RELEVANT_INFO_TAB ( '|| L_COUNTER || ' ) .DELIVERY_DETAIL_ID: ' || X_RELEVANT_INFO_TAB ( L_COUNTER ) .DELIVERY_DETAIL_ID );
              WSH_DEBUG_SV.logmsg(l_module_name, 'X_RELEVANT_INFO_TAB ( '|| L_COUNTER || ' ) .CONTAINER_ID: ' ||X_RELEVANT_INFO_TAB ( L_COUNTER ) .CONTAINER_ID );
              WSH_DEBUG_SV.logmsg(l_module_name, 'X_RELEVANT_INFO_TAB ( '|| L_COUNTER || ' ) .DELIVERY_ID: ' ||X_RELEVANT_INFO_TAB ( L_COUNTER ) .DELIVERY_ID );
              WSH_DEBUG_SV.logmsg(l_module_name, 'X_RELEVANT_INFO_TAB ( '|| L_COUNTER || ' ) .STOP_ID: ' || X_RELEVANT_INFO_TAB ( L_COUNTER ) .STOP_ID );
              WSH_DEBUG_SV.logmsg(l_module_name, 'X_RELEVANT_INFO_TAB ( '|| L_COUNTER || ' ) .TRIP_ID: ' || X_RELEVANT_INFO_TAB ( L_COUNTER ) .TRIP_ID );
              -- bug 3935583
              WSH_DEBUG_SV.logmsg(l_module_name, 'X_RELEVANT_INFO_TAB ( '|| L_COUNTER || ' ) .INVENTORY_ITEM_ID: ' || X_RELEVANT_INFO_TAB ( L_COUNTER ) .INVENTORY_ITEM_ID );
              WSH_DEBUG_SV.logmsg(l_module_name, 'X_RELEVANT_INFO_TAB ( '|| L_COUNTER || ' ) .REQUESTED_QUANTITY: ' ||X_RELEVANT_INFO_TAB ( L_COUNTER ) .REQUESTED_QUANTITY );
              WSH_DEBUG_SV.logmsg(l_module_name, 'X_RELEVANT_INFO_TAB ( '|| L_COUNTER || ' ) .SHIPPED_QUANTITY: ' ||X_RELEVANT_INFO_TAB ( L_COUNTER ) .SHIPPED_QUANTITY );
              WSH_DEBUG_SV.logmsg(l_module_name, 'X_RELEVANT_INFO_TAB ( '|| L_COUNTER || ' ) .REQUESTED_QUANTITY_UOM: ' ||X_RELEVANT_INFO_TAB ( L_COUNTER ) .REQUESTED_QUANTITY_UOM );
              WSH_DEBUG_SV.logmsg(l_module_name, 'X_RELEVANT_INFO_TAB ( '|| L_COUNTER || ' ) .NET_WEIGHT: ' || X_RELEVANT_INFO_TAB ( L_COUNTER ) .NET_WEIGHT );
              WSH_DEBUG_SV.logmsg(l_module_name, 'X_RELEVANT_INFO_TAB ( '|| L_COUNTER || ' ) .WEIGHT_UOM_CODE : ' || X_RELEVANT_INFO_TAB ( L_COUNTER ) .WEIGHT_UOM_CODE );
              WSH_DEBUG_SV.logmsg(l_module_name, 'X_RELEVANT_INFO_TAB ( '|| L_COUNTER || ' ) .VOLUME: ' ||X_RELEVANT_INFO_TAB ( L_COUNTER ) .VOLUME );
              WSH_DEBUG_SV.logmsg(l_module_name, 'X_RELEVANT_INFO_TAB ( '|| L_COUNTER || ' ) .VOLUME_UOM_CODE : ' ||X_RELEVANT_INFO_TAB ( L_COUNTER ) .VOLUME_UOM_CODE );
            END IF;
            --

            -- -------------------------------------------------------------------------------
            -- recursively checking the container relationship table, add same entry for
            -- each parent container
            -- -------------------------------------------------------------------------------
            l_container_id := p_container_id;
            LOOP
               l_find_parent := 'F';
               FOR i in  1 .. g_container_relationship.count LOOP
                  IF g_container_relationship(i).container_id = l_container_id THEN
                     l_parent_container_id := g_container_relationship(i).parent_container_id;
                     l_find_parent := 'T';
                     EXIT;
                  END IF;
               END LOOP;
               IF l_find_parent = 'T' THEN
                  -- copy the record again with container_id := l_parent_container_id;
                  l_counter := l_counter + 1;
                  x_Relevant_Info_Tab(l_counter).delivery_detail_id := l_content_detail_info.delivery_detail_id;
                  x_Relevant_Info_Tab(l_counter).container_id := l_parent_container_id;
                  x_Relevant_Info_Tab(l_counter).delivery_id := p_delivery_id;
                  x_Relevant_Info_Tab(l_counter).stop_id := p_stop_id;
                  x_Relevant_Info_Tab(l_counter).trip_id := p_trip_id;
                  -- bug 3935583
                  x_Relevant_Info_Tab(l_counter).inventory_item_id := l_content_detail_info.inventory_item_id;
                  x_Relevant_Info_Tab(l_counter).requested_quantity := l_content_detail_info.requested_quantity;
                  x_Relevant_Info_Tab(l_counter).shipped_quantity := l_content_detail_info.shipped_quantity;
                  x_Relevant_Info_Tab(l_counter).requested_quantity_uom := l_content_detail_info.requested_quantity_uom;
                  x_Relevant_Info_Tab(l_counter).net_weight := l_content_detail_info.net_weight;
                  x_Relevant_Info_Tab(l_counter).weight_uom_code := l_content_detail_info.weight_uom_code;
                  x_Relevant_Info_Tab(l_counter).volume := l_content_detail_info.volume;
                  x_Relevant_Info_Tab(l_counter).volume_uom_code := l_content_detail_info.volume_uom_code;
                  --
                  -- Debug Statements
                  --
                  IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name, 'X_RELEVANT_INFO_TAB ( '|| L_COUNTER || ' ) .DELIVERY_DETAIL_ID: ' || X_RELEVANT_INFO_TAB ( L_COUNTER ) .DELIVERY_DETAIL_ID );
                      WSH_DEBUG_SV.logmsg(l_module_name, 'X_RELEVANT_INFO_TAB ( '|| L_COUNTER || ' ) .CONTAINER_ID: ' ||X_RELEVANT_INFO_TAB ( L_COUNTER ) .CONTAINER_ID );
                      WSH_DEBUG_SV.logmsg(l_module_name, 'X_RELEVANT_INFO_TAB ( '|| L_COUNTER || ' ) .DELIVERY_ID: ' ||X_RELEVANT_INFO_TAB ( L_COUNTER ) .DELIVERY_ID );
                      WSH_DEBUG_SV.logmsg(l_module_name, 'X_RELEVANT_INFO_TAB ( '|| L_COUNTER || ' ) .STOP_ID: ' || X_RELEVANT_INFO_TAB ( L_COUNTER ) .STOP_ID );
                      WSH_DEBUG_SV.logmsg(l_module_name, 'X_RELEVANT_INFO_TAB ( '|| L_COUNTER || ' ) .TRIP_ID: ' || X_RELEVANT_INFO_TAB ( L_COUNTER ) .TRIP_ID );
                      -- bug 3935583
                      WSH_DEBUG_SV.logmsg(l_module_name, 'X_RELEVANT_INFO_TAB ( '|| L_COUNTER || ' ) .INVENTORY_ITEM_ID: ' || X_RELEVANT_INFO_TAB ( L_COUNTER ) .INVENTORY_ITEM_ID );
                      WSH_DEBUG_SV.logmsg(l_module_name, 'X_RELEVANT_INFO_TAB ( '|| L_COUNTER || ' ) .REQUESTED_QUANTITY: ' ||X_RELEVANT_INFO_TAB ( L_COUNTER ) .REQUESTED_QUANTITY );
                      WSH_DEBUG_SV.logmsg(l_module_name, 'X_RELEVANT_INFO_TAB ( '|| L_COUNTER || ' ) .SHIPPED_QUANTITY: ' ||X_RELEVANT_INFO_TAB ( L_COUNTER ) .SHIPPED_QUANTITY );
                      WSH_DEBUG_SV.logmsg(l_module_name, 'X_RELEVANT_INFO_TAB ( '|| L_COUNTER || ' ) .REQUESTED_QUANTITY_UOM: ' ||X_RELEVANT_INFO_TAB ( L_COUNTER ) .REQUESTED_QUANTITY_UOM );
                      WSH_DEBUG_SV.logmsg(l_module_name, 'X_RELEVANT_INFO_TAB ( '|| L_COUNTER || ' ) .NET_WEIGHT: ' || X_RELEVANT_INFO_TAB ( L_COUNTER ) .NET_WEIGHT );
                      WSH_DEBUG_SV.logmsg(l_module_name, 'X_RELEVANT_INFO_TAB ( '|| L_COUNTER || ' ) .WEIGHT_UOM_CODE : ' || X_RELEVANT_INFO_TAB ( L_COUNTER ) .WEIGHT_UOM_CODE );
                      WSH_DEBUG_SV.logmsg(l_module_name, 'X_RELEVANT_INFO_TAB ( '|| L_COUNTER || ' ) .VOLUME: ' ||X_RELEVANT_INFO_TAB ( L_COUNTER ) .VOLUME );
                      WSH_DEBUG_SV.logmsg(l_module_name, 'X_RELEVANT_INFO_TAB ( '|| L_COUNTER || ' ) .VOLUME_UOM_CODE : ' ||X_RELEVANT_INFO_TAB ( L_COUNTER ) .VOLUME_UOM_CODE );
                  END IF;
                  --
                  l_container_id := l_parent_container_id;
                  l_parent_container_id := 0;
               ELSE
                  EXIT;
               END IF;
            END LOOP;

         ELSE
            -- container has sub-container
            i := g_container_relationship.count + 1;
            g_container_relationship(i).container_id := l_content_detail_info.delivery_detail_id;
            g_container_relationship(i).parent_container_id := p_container_id;
            Get_Relevant_Info(
                p_level => 'CONTAINER',
                p_container_id => l_content_detail_info.delivery_detail_id,
                p_delivery_id => p_delivery_id,
                p_stop_id => p_stop_id,
                p_trip_id => p_trip_id,
                x_Relevant_Info_Tab => x_Relevant_Info_Tab,
                x_return_status => l_return_status );
         END IF;

         END LOOP;
         CLOSE c_content_details;


   ELSIF p_level = 'DELIVERY' THEN
      OPEN c_delivery_details(p_delivery_id);
      LOOP
         FETCH c_delivery_details INTO l_detail_info;
         EXIT WHEN c_delivery_details%NOTFOUND;
         l_counter := l_counter + 1;
         x_Relevant_Info_Tab(l_counter).delivery_detail_id := l_detail_info.delivery_detail_id;
         x_Relevant_Info_Tab(l_counter).delivery_id := p_delivery_id;
         x_Relevant_Info_Tab(l_counter).stop_id := p_stop_id;
         x_Relevant_Info_Tab(l_counter).trip_id := p_trip_id;
         -- bug 3935583
         x_Relevant_Info_Tab(l_counter).inventory_item_id := l_detail_info.inventory_item_id;
         x_Relevant_Info_Tab(l_counter).requested_quantity := l_detail_info.requested_quantity;
         x_Relevant_Info_Tab(l_counter).shipped_quantity := l_detail_info.shipped_quantity;
         x_Relevant_Info_Tab(l_counter).requested_quantity_uom := l_detail_info.requested_quantity_uom;
         x_Relevant_Info_Tab(l_counter).net_weight := l_detail_info.net_weight;
         x_Relevant_Info_Tab(l_counter).weight_uom_code := l_detail_info.weight_uom_code;
         x_Relevant_Info_Tab(l_counter).volume := l_detail_info.volume;
         x_Relevant_Info_Tab(l_counter).volume_uom_code := l_detail_info.volume_uom_code;
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name, 'X_RELEVANT_INFO_TAB ( '|| L_COUNTER || ' ) .DELIVERY_DETAIL_ID: ' || X_RELEVANT_INFO_TAB ( L_COUNTER ) .DELIVERY_DETAIL_ID );
             WSH_DEBUG_SV.logmsg(l_module_name, 'X_RELEVANT_INFO_TAB ( '|| L_COUNTER || ' ) .CONTAINER_ID: ' ||X_RELEVANT_INFO_TAB ( L_COUNTER ) .CONTAINER_ID );
             WSH_DEBUG_SV.logmsg(l_module_name, 'X_RELEVANT_INFO_TAB ( '|| L_COUNTER || ' ) .DELIVERY_ID: ' ||X_RELEVANT_INFO_TAB ( L_COUNTER ) .DELIVERY_ID );
             WSH_DEBUG_SV.logmsg(l_module_name, 'X_RELEVANT_INFO_TAB ( '|| L_COUNTER || ' ) .STOP_ID: ' || X_RELEVANT_INFO_TAB ( L_COUNTER ) .STOP_ID );
             -- bug 3935583
             WSH_DEBUG_SV.logmsg(l_module_name, 'X_RELEVANT_INFO_TAB ( '|| L_COUNTER || ' ) .INVENTORY_ITEM_ID: ' ||X_RELEVANT_INFO_TAB ( L_COUNTER ) .INVENTORY_ITEM_ID);
             WSH_DEBUG_SV.logmsg(l_module_name, 'X_RELEVANT_INFO_TAB ( '|| L_COUNTER || ' ) .REQUESTED_QUANTITY: ' ||X_RELEVANT_INFO_TAB ( L_COUNTER ) .REQUESTED_QUANTITY );
             WSH_DEBUG_SV.logmsg(l_module_name, 'X_RELEVANT_INFO_TAB ( '|| L_COUNTER || ' ) .SHIPPED_QUANTITY: ' ||X_RELEVANT_INFO_TAB ( L_COUNTER ) .SHIPPED_QUANTITY );
             WSH_DEBUG_SV.logmsg(l_module_name, 'X_RELEVANT_INFO_TAB ( '|| L_COUNTER || ' ) .REQUESTED_QUANTITY_UOM: ' ||X_RELEVANT_INFO_TAB ( L_COUNTER ) .REQUESTED_QUANTITY_UOM );
             WSH_DEBUG_SV.logmsg(l_module_name, 'X_RELEVANT_INFO_TAB ( '|| L_COUNTER || ' ) .NET_WEIGHT: ' || X_RELEVANT_INFO_TAB ( L_COUNTER ) .NET_WEIGHT );
             WSH_DEBUG_SV.logmsg(l_module_name, 'X_RELEVANT_INFO_TAB ( '|| L_COUNTER || ' ) .WEIGHT_UOM_CODE : ' || X_RELEVANT_INFO_TAB ( L_COUNTER ) .WEIGHT_UOM_CODE );
             WSH_DEBUG_SV.logmsg(l_module_name, 'X_RELEVANT_INFO_TAB ( '|| L_COUNTER || ' ) .VOLUME: ' ||X_RELEVANT_INFO_TAB ( L_COUNTER ) .VOLUME );
             WSH_DEBUG_SV.logmsg(l_module_name, 'X_RELEVANT_INFO_TAB ( '|| L_COUNTER || ' ) .VOLUME_UOM_CODE : ' ||X_RELEVANT_INFO_TAB ( L_COUNTER ) .VOLUME_UOM_CODE );
         END IF;
         --
      END LOOP;
      CLOSE c_delivery_details;

   ELSIF p_level = 'STOP' THEN
      OPEN c_pickup_deliveries(p_stop_id);
      LOOP
         FETCH c_pickup_deliveries INTO l_delivery_id;
         EXIT WHEN c_pickup_deliveries%NOTFOUND;
         Get_Relevant_Info(
             p_level => 'DELIVERY',
             p_delivery_id => l_delivery_id,
             p_stop_id => p_stop_id,
             p_trip_id => p_trip_id,
             x_Relevant_Info_Tab => x_Relevant_Info_Tab,
             x_return_status => l_return_status );
         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
               RAISE WSH_FC_INFO_ERR;
         END IF;
      END LOOP;
      CLOSE c_pickup_deliveries;

   ELSIF p_level = 'TRIP' THEN
      OPEN c_trip_stops(p_trip_id);
      LOOP
         FETCH c_trip_stops INTO l_stop_id;
         EXIT WHEN c_trip_stops%NOTFOUND;
         Get_Relevant_Info(
             p_level => 'STOP',
             p_stop_id => l_stop_id,
             p_trip_id => p_trip_id,
             x_Relevant_Info_Tab => x_Relevant_Info_Tab,
             x_return_status => l_return_status );
         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
               RAISE WSH_FC_INFO_ERR;
         END IF;
      END LOOP;
      CLOSE c_trip_stops;
   END IF;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'END OF GET_RELEVANT_INFO , LEVEL: ' || P_LEVEL || ' CONTAINER ID: ' || P_CONTAINER_ID || ' DELIVERY ID: ' || P_DELIVERY_ID || ' STOP ID: ' || P_STOP_ID || ' TRIP ID: ' || P_TRIP_ID );
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --

   EXCEPTION

      WHEN WSH_FC_INFO_ERR THEN
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,  'GET RELEVANT_INFO FAILED'  );
         END IF;
         --
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_FC_INFO_ERR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_FC_INFO_ERR');
END IF;
--
      WHEN others THEN
         WSH_UTIL_CORE.Default_Handler('WSH_FC_INTERFACE.Get_Relevant_Info');
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Get_Relevant_Info;


-- -----------------------------------------------------------------------------------------
-- PROCEDURE NAME: Get_Container_Level_Breakdown
-- This function returns the total number of units in UOM specified in the container
-- and lists the number of units for each delivery detail in the container
-- Calculate_container_level_cost calls this function to get the breakdown, then calculate
-- prorated cost propotionally according to the x_Cost_Break_Down table
-- ------------------------------------------------------------------------------------------
FUNCTION Get_Container_Level_Breakdown(
  p_Container_id                          IN     NUMBER
, p_Cost_Factor                           IN     VARCHAR2 DEFAULT NULL
, p_Relevant_Info_Tab                     IN     RelavantInfoTabType
, x_Cost_Breakdown                        IN OUT NOCOPY  CostBreakdownTabType
, x_return_status                         IN OUT NOCOPY  VARCHAR2
) RETURN NUMBER
IS


l_container_quantity                             NUMBER := 0;
l_standard_uom                                   VARCHAR2(3) := NULL;
l_quantity_in_st_uom                             NUMBER := 0;
l_counter                                        NUMBER := 0;
l_cost_factor                                    VARCHAR2(8) := NULL;
i                                                NUMBER := 0;
l_weight_as_cost_factor                         VARCHAR2(1) := 'T';
l_volume_as_cost_factor                         VARCHAR2(1) := 'T';
l_shipped_quantity_all_zero                     VARCHAR2(1) := 'T';


WSH_NULL_UOM      EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_CONTAINER_LEVEL_BREAKDOWN';
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
       WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_ID',P_CONTAINER_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_COST_FACTOR',P_COST_FACTOR);
       WSH_DEBUG_SV.log(l_module_name,'X_RETURN_STATUS',X_RETURN_STATUS);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name, 'BEGINNING OF GET_CONTAINER_LEVEL_BREAKDOWN: ' || P_CONTAINER_ID );
   END IF;
   --
   -- assume all the relevant info about all delivery details belongs the delivery
   -- have been populated in the table
   -- first, loop through the table, check # of delivery_deatils with non zero quantity and
   -- decide cost factor

   IF p_Cost_Factor is NULL THEN
      FOR i in 1 .. p_Relevant_Info_Tab.count LOOP
         IF p_Relevant_Info_Tab(i).container_id = p_container_id THEN
            IF p_Relevant_Info_Tab(i).shipped_quantity <> 0 THEN
               l_shipped_quantity_all_zero := 'F';
               IF p_Relevant_Info_Tab(i).net_weight is NULL OR
                  p_Relevant_Info_Tab(i).net_weight = 0 THEN
                  l_weight_as_cost_factor := 'F';
               END IF;
               IF p_Relevant_Info_Tab(i).volume is NULL OR
                  p_Relevant_Info_Tab(i).volume = 0 THEN
                  l_volume_as_cost_factor := 'F';
               END IF;
            END IF;
         END IF;
      END LOOP;
      IF l_weight_as_cost_factor = 'T' THEN
         l_cost_factor := 'WEIGHT';
      ELSIF l_volume_as_cost_factor = 'T' THEN
         l_cost_factor := 'VOLUME';
      ELSE
         l_cost_factor := 'QUANTITY';
      END IF;
   ELSE
      l_Cost_Factor := p_Cost_Factor;
   END IF;

   IF l_shipped_quantity_all_zero = 'T' THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return 0;
   END IF;

   l_counter := x_Cost_Breakdown.count;
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN HAS ' || L_COUNTER || ' RECORDS' );
   END IF;
   --

   IF (l_cost_factor = 'WEIGHT') THEN
         l_standard_uom := NULL;
         FOR i in 1 .. p_Relevant_Info_Tab.count LOOP
            IF p_Relevant_Info_Tab(i).container_id = p_container_id AND
               p_Relevant_Info_Tab(i).shipped_quantity <> 0 THEN
               IF l_standard_uom is NULL THEN
                  l_standard_uom := p_Relevant_Info_Tab(i).weight_uom_code;
               END IF;
               -- need to convert weight to same uom to do calculation
               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               --

               l_quantity_in_st_uom := WSH_WV_UTILS.convert_uom(
                 from_uom => p_Relevant_Info_Tab(i).weight_uom_code,
                 to_uom   => l_standard_uom,
                 quantity => p_Relevant_Info_Tab(i).net_weight,
                 item_id  => p_Relevant_Info_Tab(i).inventory_item_id);

               l_counter := l_counter + 1;
               x_Cost_Breakdown(l_counter).delivery_detail_id  := p_Relevant_Info_Tab(i).delivery_detail_id;
               x_Cost_Breakdown(l_counter).container_id        := p_Relevant_Info_Tab(i).container_id;
               x_Cost_Breakdown(l_counter).delivery_id         := p_Relevant_Info_Tab(i).delivery_id;
               x_Cost_Breakdown(l_counter).stop_id             := p_Relevant_Info_Tab(i).stop_id;
               x_Cost_Breakdown(l_counter).quantity            := l_quantity_in_st_uom;
               x_Cost_Breakdown(l_counter).uom                 := l_standard_uom;
               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .DELIVERY_DETAIL_ID: '|| X_COST_BREAKDOWN ( L_COUNTER ) .DELIVERY_DETAIL_ID );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .DELIVERY_ID: '|| X_COST_BREAKDOWN ( L_COUNTER ) .DELIVERY_ID );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .STOP_ID: '|| X_COST_BREAKDOWN ( L_COUNTER ) .STOP_ID );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .TRIP_ID: '|| X_COST_BREAKDOWN ( L_COUNTER ) .TRIP_ID );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .QUANTITY: '|| X_COST_BREAKDOWN ( L_COUNTER ) .QUANTITY );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .UOM: '|| X_COST_BREAKDOWN ( L_COUNTER ) .UOM );
               END IF;
               --
               l_container_quantity := l_container_quantity + l_quantity_in_st_uom;

            END IF;
         END LOOP;
   ELSIF (l_cost_factor = 'VOLUME') THEN
         l_standard_uom := NULL;
         FOR i in 1 .. p_Relevant_Info_Tab.count LOOP
            IF p_Relevant_Info_Tab(i).container_id = p_container_id AND
               p_Relevant_Info_Tab(i).shipped_quantity <> 0 THEN
               IF l_standard_uom is NULL THEN
                  l_standard_uom := p_Relevant_Info_Tab(i).volume_uom_code;
               END IF;
               -- need to convert weight to same uom to do calculation
               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               --
               l_quantity_in_st_uom := WSH_WV_UTILS.convert_uom(
                 from_uom => p_Relevant_Info_Tab(i).volume_uom_code,
                 to_uom   => l_standard_uom,
                 quantity => p_Relevant_Info_Tab(i).volume,
                 item_id  => p_Relevant_Info_Tab(i).inventory_item_id);

               l_counter := l_counter + 1;
               x_Cost_Breakdown(l_counter).delivery_detail_id  := p_Relevant_Info_Tab(i).delivery_detail_id;
               x_Cost_Breakdown(l_counter).container_id        := p_Relevant_Info_Tab(i).container_id;
               x_Cost_Breakdown(l_counter).delivery_id         := p_Relevant_Info_Tab(i).delivery_id;
               x_Cost_Breakdown(l_counter).stop_id             := p_Relevant_Info_Tab(i).stop_id;
               x_Cost_Breakdown(l_counter).quantity            := l_quantity_in_st_uom;
               x_Cost_Breakdown(l_counter).uom                 := l_standard_uom;
               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .DELIVERY_DETAIL_ID: '|| X_COST_BREAKDOWN ( L_COUNTER ) .DELIVERY_DETAIL_ID );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .DELIVERY_ID: '|| X_COST_BREAKDOWN ( L_COUNTER ) .DELIVERY_ID );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .STOP_ID: '|| X_COST_BREAKDOWN ( L_COUNTER ) .STOP_ID );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .TRIP_ID: '|| X_COST_BREAKDOWN ( L_COUNTER ) .TRIP_ID );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .QUANTITY: '|| X_COST_BREAKDOWN ( L_COUNTER ) .QUANTITY );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .UOM: '|| X_COST_BREAKDOWN ( L_COUNTER ) .UOM );
               END IF;
               --
               l_container_quantity := l_container_quantity + l_quantity_in_st_uom;
            END IF;
         END LOOP;
   ELSE
         l_standard_uom := NULL;
         FOR i in 1 .. p_Relevant_Info_Tab.count  LOOP
            IF p_Relevant_Info_Tab(i).container_id = p_container_id AND
               p_Relevant_Info_Tab(i).shipped_quantity <> 0 THEN
               -- shipped quantity
               IF l_standard_uom is NULL THEN
                  l_standard_uom := p_Relevant_Info_Tab(i).requested_quantity_uom;
               END IF;
               -- need to convert weight to same uom to do calculation
               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               -- 3935583, add item_id parameter
               l_quantity_in_st_uom := WSH_WV_UTILS.convert_uom(
                 from_uom => p_Relevant_Info_Tab(i).requested_quantity_uom,
                 to_uom   => l_standard_uom,
                 quantity => p_Relevant_Info_Tab(i).shipped_quantity,
                 item_id  => p_Relevant_Info_Tab(i).inventory_item_id);

               l_counter := l_counter + 1;
               x_Cost_Breakdown(l_counter).delivery_detail_id  := p_Relevant_Info_Tab(i).delivery_detail_id;
               x_Cost_Breakdown(l_counter).container_id        := p_Relevant_Info_Tab(i).container_id;
               x_Cost_Breakdown(l_counter).delivery_id         := p_Relevant_Info_Tab(i).delivery_id;
               x_Cost_Breakdown(l_counter).stop_id             := p_Relevant_Info_Tab(i).stop_id;
               x_Cost_Breakdown(l_counter).quantity            := l_quantity_in_st_uom;
               x_Cost_Breakdown(l_counter).uom                 := l_standard_uom;
               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .DELIVERY_DETAIL_ID: '|| X_COST_BREAKDOWN ( L_COUNTER ) .DELIVERY_DETAIL_ID );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .DELIVERY_ID: '|| X_COST_BREAKDOWN ( L_COUNTER ) .DELIVERY_ID );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .STOP_ID: '|| X_COST_BREAKDOWN ( L_COUNTER ) .STOP_ID );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .TRIP_ID: '|| X_COST_BREAKDOWN ( L_COUNTER ) .TRIP_ID );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .QUANTITY: '|| X_COST_BREAKDOWN ( L_COUNTER ) .QUANTITY );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .UOM: '|| X_COST_BREAKDOWN ( L_COUNTER ) .UOM );
               END IF;
               --
               l_container_quantity := l_container_quantity + l_quantity_in_st_uom;
            END IF;
         END LOOP;
   END IF; -- End of if cost factor is quantity

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name, 'END OF GET_CONTAINER_LEVEL_BREAKDOWN' );
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   return l_container_quantity;

   EXCEPTION

      WHEN WSH_NULL_UOM THEN
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,  'UOM CODE IS NULL'  );
         END IF;
         --
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_NULL_UOM exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_NULL_UOM');
END IF;
--
      WHEN others THEN
         WSH_UTIL_CORE.Default_Handler('WSH_FC_INTERFACE.Get_Container_Level_Breakdown');
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Get_Container_Level_Breakdown;



-- -----------------------------------------------------------------------------------------
-- PROCEDURE NAME: Get_Delivery_Level_Breakdown
-- This function returns the total number of units in the UOM specified in the delivery
-- and lists the number of units for each delivery detail in the delivery
-- Calculate_delivery_level_cost calls this function to get the breakdown, then calculate
-- prorated cost propotionally according to the x_Cost_Break_Down table
-- ------------------------------------------------------------------------------------------
FUNCTION Get_Delivery_Level_Breakdown(
  p_Delivery_id                           IN     NUMBER
, p_Cost_Factor                           IN     VARCHAR2 DEFAULT NULL
, p_Relevant_Info_Tab                     IN     RelavantInfoTabType
, x_Cost_Breakdown                        IN OUT NOCOPY  CostBreakdownTabType
, x_return_status                         IN OUT NOCOPY  VARCHAR2
) RETURN NUMBER
IS

l_delivery_quantity                              NUMBER := 0;
l_standard_uom                                   VARCHAR2(3) := NULL;
l_quantity_in_st_uom                             NUMBER := 0;
l_counter                                        NUMBER := 0;
l_cost_factor                                    VARCHAR2(8) := NULL;
i                                                NUMBER := 0;
l_weight_as_cost_factor                         VARCHAR2(1) := 'T';
l_volume_as_cost_factor                         VARCHAR2(1) := 'T';
l_shipped_quantity_all_zero                     VARCHAR2(1) := 'T';

WSH_NULL_UOM      EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_DELIVERY_LEVEL_BREAKDOWN';
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
       WSH_DEBUG_SV.log(l_module_name,'P_COST_FACTOR',P_COST_FACTOR);
       WSH_DEBUG_SV.log(l_module_name,'X_RETURN_STATUS',X_RETURN_STATUS);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name, 'BEGINNING OF GET_DELIVERY_LEVEL_BREAKDOWN: ' || P_DELIVERY_ID );
   END IF;
   --
   -- assume all the relevant info about all delivery details belongs the delivery
   -- have been populated in the table
   -- first, loop through the table, check # of delivery_deatils with non zero quantity and

   -- decide cost factor
   IF p_Cost_Factor is NULL THEN
      FOR i in 1 .. p_Relevant_Info_Tab.count LOOP
         IF p_Relevant_Info_Tab(i).delivery_id = p_delivery_id THEN
            IF p_Relevant_Info_Tab(i).shipped_quantity <> 0 THEN
               l_shipped_quantity_all_zero := 'F';
               IF p_Relevant_Info_Tab(i).net_weight is NULL OR
                  p_Relevant_Info_Tab(i).net_weight = 0 THEN
                  l_weight_as_cost_factor := 'F';
               END IF;
               IF p_Relevant_Info_Tab(i).volume is NULL OR
                  p_Relevant_Info_Tab(i).volume = 0 THEN
                  l_volume_as_cost_factor := 'F';
               END IF;
            END IF;
         END IF;
      END LOOP;
      IF l_weight_as_cost_factor = 'T' THEN
         l_cost_factor := 'WEIGHT';
      ELSIF l_volume_as_cost_factor = 'T' THEN
         l_cost_factor := 'VOLUME';
      ELSE
         l_cost_factor := 'QUANTITY';
      END IF;
   ELSE
      l_Cost_Factor := p_Cost_Factor;
   END IF;

   IF l_shipped_quantity_all_zero = 'T' THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'SHIPPED_QUANTITY_ALL_ZERO IS TRUE' );
          WSH_DEBUG_SV.logmsg(l_module_name, 'EXIT OUT OF GET_DELIVERY_LEVEL_BREAKDOWN' );
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      return 0;
   END IF;

   l_counter := x_Cost_Breakdown.count;
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name, 'COST FACTOR: ' || L_COST_FACTOR );
       WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN HAS ' || L_COUNTER || ' RECORDS' );
   END IF;
   --

   IF (l_cost_factor = 'WEIGHT') THEN
         l_standard_uom := NULL;
         FOR i in 1 .. p_Relevant_Info_Tab.count LOOP
            IF p_Relevant_Info_Tab(i).delivery_id = p_delivery_id AND
               p_Relevant_Info_Tab(i).shipped_quantity <> 0 THEN
               IF l_standard_uom is NULL THEN
                  l_standard_uom := p_Relevant_Info_Tab(i).weight_uom_code;
               END IF;
               -- need to convert weight to same uom to do calculation
               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               -- bug 3935583 , passed value to item_id parameter
               l_quantity_in_st_uom := WSH_WV_UTILS.convert_uom(
                 from_uom => p_Relevant_Info_Tab(i).weight_uom_code,
                 to_uom   => l_standard_uom,
                 quantity => p_Relevant_Info_Tab(i).net_weight,
                 item_id  => p_Relevant_Info_Tab(i).inventory_item_id);

               l_counter := l_counter + 1;
               x_Cost_Breakdown(l_counter).delivery_detail_id  := p_Relevant_Info_Tab(i).delivery_detail_id;
               x_Cost_Breakdown(l_counter).delivery_id         := p_Relevant_Info_Tab(i).delivery_id;
               x_Cost_Breakdown(l_counter).stop_id             := p_Relevant_Info_Tab(i).stop_id;
               x_Cost_Breakdown(l_counter).quantity            := l_quantity_in_st_uom;
               x_Cost_Breakdown(l_counter).uom                 := l_standard_uom;
               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .DELIVERY_DETAIL_ID: '|| X_COST_BREAKDOWN ( L_COUNTER ) .DELIVERY_DETAIL_ID );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .DELIVERY_ID: '|| X_COST_BREAKDOWN ( L_COUNTER ) .DELIVERY_ID );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .STOP_ID: '|| X_COST_BREAKDOWN ( L_COUNTER ) .STOP_ID );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .TRIP_ID: '|| X_COST_BREAKDOWN ( L_COUNTER ) .TRIP_ID );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .QUANTITY: '|| X_COST_BREAKDOWN ( L_COUNTER ) .QUANTITY );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .UOM: '|| X_COST_BREAKDOWN ( L_COUNTER ) .UOM );
               END IF;
               --
               l_delivery_quantity := l_delivery_quantity + l_quantity_in_st_uom;

            END IF;
         END LOOP;
   ELSIF (l_cost_factor = 'VOLUME') THEN
         l_standard_uom := NULL;
         FOR i in 1 .. p_Relevant_Info_Tab.count LOOP
            IF p_Relevant_Info_Tab(i).delivery_id = p_delivery_id AND
               p_Relevant_Info_Tab(i).shipped_quantity <> 0 THEN
               IF l_standard_uom is NULL THEN
                  l_standard_uom := p_Relevant_Info_Tab(i).volume_uom_code;
               END IF;
               -- need to convert weight to same uom to do calculation
               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               -- bug 3935583 , passed value to item_id parameter
               l_quantity_in_st_uom := WSH_WV_UTILS.convert_uom(
                 from_uom => p_Relevant_Info_Tab(i).volume_uom_code,
                 to_uom   => l_standard_uom,
                 quantity => p_Relevant_Info_Tab(i).volume,
                 item_id  => p_Relevant_Info_Tab(i).inventory_item_id);
               l_counter := l_counter + 1;
               x_Cost_Breakdown(l_counter).delivery_detail_id  := p_Relevant_Info_Tab(i).delivery_detail_id;
               x_Cost_Breakdown(l_counter).delivery_id         := p_Relevant_Info_Tab(i).delivery_id;
               x_Cost_Breakdown(l_counter).stop_id             := p_Relevant_Info_Tab(i).stop_id;
               x_Cost_Breakdown(l_counter).quantity            := l_quantity_in_st_uom;
               x_Cost_Breakdown(l_counter).uom                 := l_standard_uom;
               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .DELIVERY_DETAIL_ID: '|| X_COST_BREAKDOWN ( L_COUNTER ) .DELIVERY_DETAIL_ID );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .DELIVERY_ID: '|| X_COST_BREAKDOWN ( L_COUNTER ) .DELIVERY_ID );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .STOP_ID: '|| X_COST_BREAKDOWN ( L_COUNTER ) .STOP_ID );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .TRIP_ID: '|| X_COST_BREAKDOWN ( L_COUNTER ) .TRIP_ID );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .QUANTITY: '|| X_COST_BREAKDOWN ( L_COUNTER ) .QUANTITY );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .UOM: '|| X_COST_BREAKDOWN ( L_COUNTER ) .UOM );
               END IF;

               l_delivery_quantity := l_delivery_quantity + l_quantity_in_st_uom;
            END IF;
         END LOOP;
   ELSE
         l_standard_uom := NULL;
         FOR i in 1 .. p_Relevant_Info_Tab.count  LOOP
            IF p_Relevant_Info_Tab(i).delivery_id = p_delivery_id AND
               p_Relevant_Info_Tab(i).shipped_quantity <> 0 THEN
               -- shipped quantity
               IF l_standard_uom is NULL THEN
                  l_standard_uom := p_Relevant_Info_Tab(i).requested_quantity_uom;
               END IF;
               -- need to convert weight to same uom to do calculation
               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               -- bug 3935583, passed value to item_id
               l_quantity_in_st_uom := WSH_WV_UTILS.convert_uom(
                 from_uom => p_Relevant_Info_Tab(i).requested_quantity_uom,
                 to_uom   => l_standard_uom,
                 quantity => p_Relevant_Info_Tab(i).shipped_quantity,
                 item_id  => p_Relevant_Info_Tab(i).inventory_item_id);
               l_counter := l_counter + 1;
               x_Cost_Breakdown(l_counter).delivery_detail_id  := p_Relevant_Info_Tab(i).delivery_detail_id;
               x_Cost_Breakdown(l_counter).delivery_id         := p_Relevant_Info_Tab(i).delivery_id;
               x_Cost_Breakdown(l_counter).stop_id             := p_Relevant_Info_Tab(i).stop_id;
               x_Cost_Breakdown(l_counter).quantity            := l_quantity_in_st_uom;
               x_Cost_Breakdown(l_counter).uom                 := l_standard_uom;
               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .DELIVERY_DETAIL_ID: '|| X_COST_BREAKDOWN ( L_COUNTER ) .DELIVERY_DETAIL_ID );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .DELIVERY_ID: '|| X_COST_BREAKDOWN ( L_COUNTER ) .DELIVERY_ID );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .STOP_ID: '|| X_COST_BREAKDOWN ( L_COUNTER ) .STOP_ID );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .TRIP_ID: '|| X_COST_BREAKDOWN ( L_COUNTER ) .TRIP_ID );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .QUANTITY: '|| X_COST_BREAKDOWN ( L_COUNTER ) .QUANTITY );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .UOM: '|| X_COST_BREAKDOWN ( L_COUNTER ) .UOM );
               END IF;
               --
               l_delivery_quantity := l_delivery_quantity + l_quantity_in_st_uom;
            END IF;
         END LOOP;
   END IF; -- End of if cost factor is quantity

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name, 'END OF GET_DELIVERY_LEVEL_BREAKDOWN' );
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   return l_delivery_quantity;

   EXCEPTION

      WHEN WSH_NULL_UOM THEN
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,  'UOM CODE IS NULL'  );
         END IF;
         --
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_NULL_UOM exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_NULL_UOM');
END IF;
--
      WHEN others THEN
         WSH_UTIL_CORE.Default_Handler('WSH_FC_INTERFACE.Get_Delivery_Level_Breakdown');
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Get_Delivery_Level_Breakdown;

-- -----------------------------------------------------------------------------------------
-- PROCEDURE NAME: Get_Stop_Level_Breakdown
-- This function returns the total number of units in the UOM specified in the stop
-- and lists the number of units for each delivery detail in the stop
-- Calculate_Stop_level_cost calls this function to get the breakdown, then calculate
-- prorated cost propotionally according to the x_Cost_Break_Down table
-- ------------------------------------------------------------------------------------------
FUNCTION Get_Stop_Level_Breakdown(
  p_Stop_id                               IN     NUMBER
, p_Cost_Factor                           IN     VARCHAR2 DEFAULT NULL
, p_Relevant_Info_Tab                     IN     RelavantInfoTabType
, x_Cost_Breakdown                        IN OUT NOCOPY  CostBreakdownTabType
, x_return_status                         OUT NOCOPY  VARCHAR2
) RETURN NUMBER
IS

l_stop_quantity                                 NUMBER := 0;
l_standard_uom                                   VARCHAR2(3) := NULL;
l_quantity_in_st_uom                             NUMBER := 0;
l_counter                                        NUMBER := 0;
l_cost_factor                                    VARCHAR2(8) := NULL;
i                                                NUMBER := 0;
l_weight_as_cost_factor                         VARCHAR2(1) := 'T';
l_volume_as_cost_factor                         VARCHAR2(1) := 'T';
l_shipped_quantity_all_zero                     VARCHAR2(1) := 'T';


WSH_NULL_UOM      EXCEPTION;


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_STOP_LEVEL_BREAKDOWN';
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
       WSH_DEBUG_SV.log(l_module_name,'P_STOP_ID',P_STOP_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_COST_FACTOR',P_COST_FACTOR);
       WSH_DEBUG_SV.log(l_module_name,'P_RELEVANT_INFO_TAB.COUNT',P_RELEVANT_INFO_TAB.count);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name, 'BEGINNING OF GET_STOP_LEVEL BREAKDOWN: ' || P_STOP_ID );
   END IF;
   --
   l_counter := x_Cost_Breakdown.count;


   -- decide cost factor
   IF p_Cost_Factor is NULL THEN
      FOR i in 1 .. p_Relevant_Info_Tab.count LOOP
         IF p_Relevant_Info_Tab(i).stop_id = p_stop_id THEN
            IF p_Relevant_Info_Tab(i).shipped_quantity <> 0 THEN
               l_shipped_quantity_all_zero := 'F';
               IF p_Relevant_Info_Tab(i).net_weight is NULL OR
                  p_Relevant_Info_Tab(i).net_weight = 0 THEN
                  l_weight_as_cost_factor := 'F';
               END IF;
               IF p_Relevant_Info_Tab(i).volume is NULL OR
                  p_Relevant_Info_Tab(i).volume = 0 THEN
                  l_volume_as_cost_factor := 'F';
               END IF;
            END IF;
         END IF;
      END LOOP;
      IF l_weight_as_cost_factor = 'T' THEN
         l_cost_factor := 'WEIGHT';
      ELSIF l_volume_as_cost_factor = 'T' THEN
         l_cost_factor := 'VOLUME';
      ELSE
         l_cost_factor := 'QUANTITY';
      END IF;
   ELSE
      l_Cost_Factor := p_Cost_Factor;
   END IF;

   IF l_shipped_quantity_all_zero = 'T' THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return 0;
   END IF;

   l_counter := x_Cost_Breakdown.count;
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN HAS ' || L_COUNTER || ' RECORDS' );
   END IF;
   --

   IF (l_cost_factor = 'WEIGHT') THEN
         l_standard_uom := NULL;
         FOR i in 1 .. p_Relevant_Info_Tab.count LOOP
            IF p_Relevant_Info_Tab(i).stop_id = p_stop_id AND
               p_Relevant_Info_Tab(i).shipped_quantity <> 0 THEN
               IF l_standard_uom is NULL THEN
                  l_standard_uom := p_Relevant_Info_Tab(i).weight_uom_code;
               END IF;
               -- need to convert weight to same uom to do calculation
               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               --
               -- bug 3935583, passed value to item_id
               l_quantity_in_st_uom := WSH_WV_UTILS.convert_uom(
                 from_uom => p_Relevant_Info_Tab(i).weight_uom_code,
                 to_uom   => l_standard_uom,
                 quantity => p_Relevant_Info_Tab(i).net_weight,
                 item_id  => p_Relevant_Info_Tab(i).inventory_item_id);
               l_counter := l_counter + 1;
               x_Cost_Breakdown(l_counter).delivery_detail_id  := p_Relevant_Info_Tab(i).delivery_detail_id;
               x_Cost_Breakdown(l_counter).delivery_id         := p_Relevant_Info_Tab(i).delivery_id;
               x_Cost_Breakdown(l_counter).stop_id             := p_Relevant_Info_Tab(i).stop_id;
               x_Cost_Breakdown(l_counter).quantity            := l_quantity_in_st_uom;
               x_Cost_Breakdown(l_counter).uom                 := l_standard_uom;
               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .DELIVERY_DETAIL_ID: '|| X_COST_BREAKDOWN ( L_COUNTER ) .DELIVERY_DETAIL_ID );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .DELIVERY_ID: '|| X_COST_BREAKDOWN ( L_COUNTER ) .DELIVERY_ID );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .STOP_ID: '|| X_COST_BREAKDOWN ( L_COUNTER ) .STOP_ID );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .TRIP_ID: '|| X_COST_BREAKDOWN ( L_COUNTER ) .TRIP_ID );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .QUANTITY: '|| X_COST_BREAKDOWN ( L_COUNTER ) .QUANTITY );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .UOM: '|| X_COST_BREAKDOWN ( L_COUNTER ) .UOM );
               END IF;
               --
               l_stop_quantity := l_stop_quantity + l_quantity_in_st_uom;

            END IF;
         END LOOP;
   ELSIF (l_cost_factor = 'VOLUME') THEN
         l_standard_uom := NULL;
         FOR i in 1 .. p_Relevant_Info_Tab.count LOOP
            IF p_Relevant_Info_Tab(i).stop_id = p_stop_id AND
               p_Relevant_Info_Tab(i).shipped_quantity <> 0 THEN
               IF l_standard_uom is NULL THEN
                  l_standard_uom := p_Relevant_Info_Tab(i).volume_uom_code;
               END IF;
               -- need to convert weight to same uom to do calculation
               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               -- 3935583 , passed value to item_id
               l_quantity_in_st_uom := WSH_WV_UTILS.convert_uom(
                 from_uom =>   p_Relevant_Info_Tab(i).volume_uom_code,
                 to_uom   =>   l_standard_uom,
                 quantity =>   p_Relevant_Info_Tab(i).volume,
                 item_id  =>   p_Relevant_Info_Tab(i).inventory_item_id);
               l_counter := l_counter + 1;
               x_Cost_Breakdown(l_counter).delivery_detail_id  := p_Relevant_Info_Tab(i).delivery_detail_id;
               x_Cost_Breakdown(l_counter).delivery_id         := p_Relevant_Info_Tab(i).delivery_id;
               x_Cost_Breakdown(l_counter).stop_id             := p_Relevant_Info_Tab(i).stop_id;
               x_Cost_Breakdown(l_counter).quantity            := l_quantity_in_st_uom;
               x_Cost_Breakdown(l_counter).uom                 := l_standard_uom;
               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .DELIVERY_DETAIL_ID: '|| X_COST_BREAKDOWN ( L_COUNTER ) .DELIVERY_DETAIL_ID );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .DELIVERY_ID: '|| X_COST_BREAKDOWN ( L_COUNTER ) .DELIVERY_ID );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .STOP_ID: '|| X_COST_BREAKDOWN ( L_COUNTER ) .STOP_ID );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .TRIP_ID: '|| X_COST_BREAKDOWN ( L_COUNTER ) .TRIP_ID );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .QUANTITY: '|| X_COST_BREAKDOWN ( L_COUNTER ) .QUANTITY );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .UOM: '|| X_COST_BREAKDOWN ( L_COUNTER ) .UOM );
               END IF;
               --
               l_stop_quantity := l_stop_quantity + l_quantity_in_st_uom;
            END IF;
         END LOOP;
   ELSE
         l_standard_uom := NULL;
         FOR i in 1 .. p_Relevant_Info_Tab.count  LOOP
            IF p_Relevant_Info_Tab(i).stop_id = p_stop_id AND
               p_Relevant_Info_Tab(i).shipped_quantity <> 0 THEN
               -- shipped quantity
               IF l_standard_uom is NULL THEN
                  l_standard_uom := p_Relevant_Info_Tab(i).requested_quantity_uom;
               END IF;
               -- need to convert weight to same uom to do calculation
               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               --
               l_quantity_in_st_uom := WSH_WV_UTILS.convert_uom(
                 from_uom =>  p_Relevant_Info_Tab(i).requested_quantity_uom,
                 to_uom   =>  l_standard_uom,
                 quantity =>  p_Relevant_Info_Tab(i).shipped_quantity,
                 item_id  =>  p_Relevant_Info_Tab(i).inventory_item_id);
               l_counter := l_counter + 1;
               x_Cost_Breakdown(l_counter).delivery_detail_id  := p_Relevant_Info_Tab(i).delivery_detail_id;
               x_Cost_Breakdown(l_counter).delivery_id         := p_Relevant_Info_Tab(i).delivery_id;
               x_Cost_Breakdown(l_counter).stop_id             := p_Relevant_Info_Tab(i).stop_id;
               x_Cost_Breakdown(l_counter).quantity            := l_quantity_in_st_uom;
               x_Cost_Breakdown(l_counter).uom                 := l_standard_uom;
               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .DELIVERY_DETAIL_ID: '|| X_COST_BREAKDOWN ( L_COUNTER ) .DELIVERY_DETAIL_ID );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .DELIVERY_ID: '|| X_COST_BREAKDOWN ( L_COUNTER ) .DELIVERY_ID );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .STOP_ID: '|| X_COST_BREAKDOWN ( L_COUNTER ) .STOP_ID );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .TRIP_ID: '|| X_COST_BREAKDOWN ( L_COUNTER ) .TRIP_ID );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .QUANTITY: '|| X_COST_BREAKDOWN ( L_COUNTER ) .QUANTITY );
                   WSH_DEBUG_SV.logmsg(l_module_name, 'X_COST_BREAKDOWN ( ' || L_COUNTER ||' ) .UOM: '|| X_COST_BREAKDOWN ( L_COUNTER ) .UOM );
               END IF;
               --
               l_stop_quantity := l_stop_quantity + l_quantity_in_st_uom;
            END IF;
         END LOOP;
   END IF; -- End of if cost factor is quantity

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'x_cost_breakdown.count',x_cost_breakdown.count);
       WSH_DEBUG_SV.log(l_module_name,'STOP QUANTITY',l_stop_quantity);
       WSH_DEBUG_SV.logmsg(l_module_name, 'END OF GET_STOP_LEVEL_BREAKDOWN' );
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   return l_stop_quantity;

   EXCEPTION

      WHEN WSH_NULL_UOM THEN
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,  'UOM CODE IS NULL'  );
         END IF;
         --
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_NULL_UOM exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_NULL_UOM');
END IF;
--
      WHEN others THEN
         WSH_UTIL_CORE.Default_Handler('WSH_FC_INTERFACE.Get_Stop_Level_Breakdown');
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Get_Stop_Level_Breakdown;

-- -----------------------------------------------------------------------------------------
-- PROCEDURE NAME: Calculate_Container_Level_Cost
-- ------------------------------------------------------------------------------------------

PROCEDURE Calculate_Container_Level_Cost(
  p_Container_id                                IN     NUMBER
, p_Freight_Cost_Type_Code                      IN     VARCHAR2
, p_Freight_Cost_Id                             IN     NUMBER
, p_Freight_Cost_Amount                         IN     NUMBER
, p_From_Currency_code                          IN     VARCHAR2
, p_Conversion_Type_Code                        IN     WSH_FREIGHT_COSTS.CONVERSION_TYPE_CODE%TYPE
, p_Conversion_Rate                             IN     WSH_FREIGHT_COSTS.CONVERSION_RATE%TYPE
, p_Relevant_Info_Tab                           IN     RelavantInfoTabType
, x_Prorated_Freight_Cost                       IN OUT NOCOPY  ProratedCostTabType
, x_return_status                                  OUT NOCOPY  VARCHAR2
)
IS

l_distributed_cost                               NUMBER := 0;
l_round_distributed_cost                         NUMBER := 0;
l_rest_amount                                    NUMBER := 0;
l_counter                                        NUMBER := 0;
l_cost_brk_count                                 NUMBER := 0;
l_prorated_cost_count                            NUMBER := 0;
l_container_quantity                             NUMBER := 0;
l_Cost_Breakdown                                 CostBreakdownTabType;
l_return_status                                  VARCHAR2(10) := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


WSH_ROUND_AMOUNT_ERROR     EXCEPTION;
WSH_GET_BREAKDOWN_ERR      EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CALCULATE_CONTAINER_LEVEL_COST';
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
       WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_ID',P_CONTAINER_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_COST_TYPE_CODE',P_FREIGHT_COST_TYPE_CODE);
       WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_COST_ID',P_FREIGHT_COST_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_COST_AMOUNT',P_FREIGHT_COST_AMOUNT);
       WSH_DEBUG_SV.log(l_module_name,'P_FROM_CURRENCY_CODE',P_FROM_CURRENCY_CODE);

       WSH_DEBUG_SV.log(l_module_name,'P_RELEVANT_INFO_TAB.COUNT',P_RELEVANT_INFO_TAB.count);

   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name, 'BEGINNING OF CALCULATE_CONTAINER_LEVEL COST: '|| P_CONTAINER_ID );
   END IF;
   --
   -- get the cost factor across the whole container

   l_container_quantity := Get_Container_Level_Breakdown(
               p_container_id => p_container_id,
               p_Relevant_Info_Tab => p_Relevant_Info_Tab,
               x_Cost_Breakdown => l_Cost_Breakdown,
               x_return_status   => l_return_status
               );


   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         RAISE WSH_GET_BREAKDOWN_ERR;
   END IF;


   l_cost_brk_count := l_Cost_Breakdown.count;
   l_prorated_cost_count := x_Prorated_Freight_Cost.count;
   l_rest_amount := p_Freight_Cost_Amount;
   IF l_cost_brk_count > 0 THEN
      FOR l_counter IN 1..(l_cost_brk_count -1) LOOP
         l_prorated_cost_count := l_prorated_cost_count +1;
         l_distributed_cost := p_Freight_Cost_Amount * ( l_Cost_Breakdown(l_counter).quantity / l_container_quantity);
         Round_Cost_Amount(l_distributed_cost, p_From_Currency_Code, l_round_distributed_cost, l_return_status);
         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            RAISE WSH_ROUND_AMOUNT_ERROR;
         END IF;
         x_Prorated_Freight_Cost(l_prorated_cost_count).delivery_detail_id := l_Cost_Breakdown(l_counter).delivery_detail_id;
         x_Prorated_Freight_Cost(l_prorated_cost_count).freight_cost_type_code := p_freight_cost_type_code;
         x_Prorated_Freight_Cost(l_prorated_cost_count).freight_cost_id := p_freight_cost_id;
         x_Prorated_Freight_Cost(l_prorated_cost_count).amount := l_round_distributed_cost;
         x_Prorated_Freight_Cost(l_prorated_cost_count).currency_code := p_from_currency_code;
         x_Prorated_Freight_Cost(l_prorated_cost_count).conversion_type_code := p_conversion_type_code;
         x_Prorated_Freight_Cost(l_prorated_cost_count).conversion_rate:= p_conversion_rate;

         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_PRORATED_COST_COUNT ||' ) .DELIVERY_DETAIL_ID: '||X_PRORATED_FREIGHT_COST ( L_PRORATED_COST_COUNT ).DELIVERY_DETAIL_ID );
             WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_PRORATED_COST_COUNT ||' ) .FREIGHT_COST_TYPE_CODE: '||X_PRORATED_FREIGHT_COST ( L_PRORATED_COST_COUNT ).FREIGHT_COST_TYPE_CODE );
             WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_PRORATED_COST_COUNT ||' ) .FREIGHT_COST_ID: '||X_PRORATED_FREIGHT_COST ( L_PRORATED_COST_COUNT ).FREIGHT_COST_ID );
             WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_PRORATED_COST_COUNT ||' ) .AMOUNT: '||X_PRORATED_FREIGHT_COST ( L_PRORATED_COST_COUNT ).AMOUNT );
             WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_PRORATED_COST_COUNT ||' ) .CURRENCY_CODE: '||X_PRORATED_FREIGHT_COST ( L_PRORATED_COST_COUNT).CURRENCY_CODE );
             WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_PRORATED_COST_COUNT ||' ) .CONVERSION_TYPE_CODE: '||X_PRORATED_FREIGHT_COST ( L_PRORATED_COST_COUNT ).CONVERSION_TYPE_CODE );
             WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_PRORATED_COST_COUNT ||' ) .CONVERSION_RATE: '||X_PRORATED_FREIGHT_COST ( L_PRORATED_COST_COUNT ).CONVERSION_RATE );
         END IF;
         --
         l_rest_amount := l_rest_amount - l_round_distributed_cost;
      END LOOP;

      -- last record
      l_prorated_cost_count := l_prorated_cost_count +1;
      l_distributed_cost := l_rest_amount;
      Round_Cost_Amount(l_distributed_cost, p_From_Currency_Code, l_round_distributed_cost, l_return_status);
      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         RAISE WSH_ROUND_AMOUNT_ERROR;
      END IF;
      x_Prorated_Freight_Cost(l_prorated_cost_count).delivery_detail_id := l_Cost_Breakdown(l_cost_brk_count).delivery_detail_id;
      x_Prorated_Freight_Cost(l_prorated_cost_count).freight_cost_type_code := p_freight_cost_type_code;
      x_Prorated_Freight_Cost(l_prorated_cost_count).freight_cost_id := p_freight_cost_id;
      x_Prorated_Freight_Cost(l_prorated_cost_count).amount := l_round_distributed_cost;
      x_Prorated_Freight_Cost(l_prorated_cost_count).currency_code := p_from_currency_code;
      x_Prorated_Freight_Cost(l_prorated_cost_count).conversion_type_code := p_conversion_type_code;
      x_Prorated_Freight_Cost(l_prorated_cost_count).conversion_rate:= p_conversion_rate;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_PRORATED_COST_COUNT ||' ) .DELIVERY_DETAIL_ID: '||X_PRORATED_FREIGHT_COST ( L_PRORATED_COST_COUNT ) .DELIVERY_DETAIL_ID );
          WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_PRORATED_COST_COUNT ||' ) .FREIGHT_COST_TYPE_ID: '||X_PRORATED_FREIGHT_COST ( L_PRORATED_COST_COUNT ) .FREIGHT_COST_TYPE_CODE );
          WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_PRORATED_COST_COUNT ||' ) .FREIGHT_COST_ID: '||X_PRORATED_FREIGHT_COST ( L_PRORATED_COST_COUNT ) .FREIGHT_COST_ID );
          WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_PRORATED_COST_COUNT ||' ) .AMOUNT: '||X_PRORATED_FREIGHT_COST ( L_PRORATED_COST_COUNT ) .AMOUNT );
          WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_PRORATED_COST_COUNT ||' ) .CURRENCY_CODE: '||X_PRORATED_FREIGHT_COST ( L_PRORATED_COST_COUNT ) .CURRENCY_CODE );
          WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_PRORATED_COST_COUNT ||' ) .CONVERSION_TYPE_CODE: '||X_PRORATED_FREIGHT_COST ( L_PRORATED_COST_COUNT ) .CONVERSION_TYPE_CODE );
          WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_PRORATED_COST_COUNT ||' ) .CONVERSION_RATE: '||X_PRORATED_FREIGHT_COST ( L_PRORATED_COST_COUNT ) .CONVERSION_RATE );

      END IF;
      --
   END IF;

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name, 'END OF CALCULATE_CONTAINER_LEVEL_COST' );
     WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --

EXCEPTION

   WHEN WSH_GET_BREAKDOWN_ERR THEN
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,  'GET COST BREAKDOWN ERROR AT CONTAINER ' || P_CONTAINER_ID  );
         END IF;
         --
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_GET_BREAKDOWN_ERR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_GET_BREAKDOWN_ERR');
END IF;
--
   WHEN WSH_ROUND_AMOUNT_ERROR THEN
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,  'GET ROUND AMOUNT ERROR AT CONTAINER ' || P_CONTAINER_ID  );
         END IF;
         --
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_ROUND_AMOUNT_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_ROUND_AMOUNT_ERROR');
END IF;
--
      WHEN others THEN
         WSH_UTIL_CORE.Default_Handler('WSH_FC_INTERFACE.Calculate_Container_Level_Cost');
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Calculate_Container_Level_Cost;


-- -----------------------------------------------------------------------------------------
-- PROCEDURE NAME: Calculate_Detail_Level_Cost
-- ------------------------------------------------------------------------------------------


PROCEDURE Calculate_Detail_Level_Cost(
  p_Delivery_Detail_Id                          IN     NUMBER
, p_Freight_Cost_Type_Code                      IN    VARCHAR2
, p_Freight_cost_id                        IN     NUMBER
, p_Freight_Cost_Amount                         IN     NUMBER
, p_From_Currency_code                          IN     VARCHAR2
, p_Conversion_Type_Code                        IN     WSH_FREIGHT_COSTS.CONVERSION_TYPE_CODE%TYPE
, p_Conversion_Rate                             IN     WSH_FREIGHT_COSTS.CONVERSION_RATE%TYPE
, p_Relevant_Info_Tab                           IN     RelavantInfoTabType
, x_Prorated_Freight_Cost                       IN OUT NOCOPY  ProratedCostTabType
, x_return_status                                  OUT NOCOPY  VARCHAR2
)
IS

l_next_table_id                  NUMBER;
l_number_container               NUMBER;
l_container_flag                 VARCHAR2(1);
l_return_status                  VARCHAR2(30);


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CALCULATE_DETAIL_LEVEL_COST';
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
       WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_DETAIL_ID',P_DELIVERY_DETAIL_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_COST_TYPE_CODE',P_FREIGHT_COST_TYPE_CODE);
       WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_COST_ID',P_FREIGHT_COST_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_COST_AMOUNT',P_FREIGHT_COST_AMOUNT);
       WSH_DEBUG_SV.log(l_module_name,'P_FROM_CURRENCY_CODE',P_FROM_CURRENCY_CODE);
       WSH_DEBUG_SV.log(l_module_name,'P_FROM_CURRENCY_CODE',P_CONVERSION_TYPE_CODE);
       WSH_DEBUG_SV.log(l_module_name,'P_FROM_CURRENCY_CODE',P_CONVERSION_RATE);

       WSH_DEBUG_SV.log(l_module_name,'P_RELEVANT_INFO_TAB.COUNT',P_RELEVANT_INFO_TAB.count);

   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   l_next_table_id := x_Prorated_Freight_Cost.COUNT + 1;
   x_Prorated_Freight_Cost(l_next_table_id).delivery_detail_id := p_delivery_detail_id;
   x_Prorated_Freight_Cost(l_next_table_id).freight_cost_type_code := p_freight_cost_type_code;
   x_prorated_Freight_Cost(l_next_table_id).freight_cost_id := p_freight_cost_id;
   x_prorated_Freight_Cost(l_next_table_id).amount := p_Freight_Cost_Amount;
   x_prorated_Freight_Cost(l_next_table_id).currency_code := p_From_Currency_code;
   x_prorated_Freight_Cost(l_next_table_id).conversion_type_code := p_conversion_type_code;
   x_prorated_Freight_Cost(l_next_table_id).conversion_rate := p_conversion_rate;

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_NEXT_TABLE_ID ||' ) .DELIVERY_DETAIL_ID: '||X_PRORATED_FREIGHT_COST ( L_NEXT_TABLE_ID ) .DELIVERY_DETAIL_ID );
       WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_NEXT_TABLE_ID ||' ) .FREIGHT_COST_TYPE_CODE: '||X_PRORATED_FREIGHT_COST ( L_NEXT_TABLE_ID ) .FREIGHT_COST_TYPE_CODE );
       WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_NEXT_TABLE_ID ||' ) .FREIGHT_COST_ID: '||X_PRORATED_FREIGHT_COST ( L_NEXT_TABLE_ID ) .FREIGHT_COST_ID );
       WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_NEXT_TABLE_ID ||' ) .AMOUNT: '||X_PRORATED_FREIGHT_COST ( L_NEXT_TABLE_ID ) .AMOUNT );
       WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_NEXT_TABLE_ID ||' ) .CURRENCY_CODE: '||X_PRORATED_FREIGHT_COST ( L_NEXT_TABLE_ID ) .CURRENCY_CODE );
       WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_NEXT_TABLE_ID ||' ) .CONVERSION_TYPE_CODE: '||X_PRORATED_FREIGHT_COST ( L_NEXT_TABLE_ID ) .CONVERSION_TYPE_CODE );
       WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_NEXT_TABLE_ID ||' ) .CONVERSION_RATE: '||X_PRORATED_FREIGHT_COST ( L_NEXT_TABLE_ID ) .CONVERSION_RATE );

     WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
Exception
         WHEN others THEN
         WSH_UTIL_CORE.Default_Handler('WSH_FC_INTERFACE.Calculate_Detail_Level_Cost');
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
             WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
         --
END Calculate_Detail_Level_Cost;

-- -----------------------------------------------------------------------
-- API name: Calculate_Delivery_Level_Cost
-- Type: private
-- Function: need to add a cost_factor parameter, this procedure may be called in
-- calculating the trip or trip stop level cost, the cost_factor is pre-decided in the
-- trip or trip stop level before it pass to calculate_delivery_level_cost
-- Parameters: added optional p_cost_factor
-- Notes:   please use :set tabstop=3 to view this file in vi to get
--          proper alignment
--
-- ------------------------------------------------------------------------

PROCEDURE Calculate_Delivery_Level_Cost(
  p_Delivery_Id                                 IN     NUMBER
, p_Freight_Cost_Type_Code                      IN     VARCHAR2
, p_Freight_Cost_Id                             IN     NUMBER
, p_Freight_Cost_Amount                         IN     NUMBER
, p_From_Currency_Code                          IN     VARCHAR2
, p_Conversion_Type_Code                        IN     WSH_FREIGHT_COSTS.CONVERSION_TYPE_CODE%TYPE
, p_Conversion_Rate                             IN     WSH_FREIGHT_COSTS.CONVERSION_RATE%TYPE
, p_Relevant_Info_Tab                           IN     RelavantInfoTabType
, x_Prorated_Freight_Cost                       IN OUT NOCOPY  ProratedCostTabType
, x_return_status                               OUT NOCOPY  VARCHAR2
)
IS

l_distributed_cost                               NUMBER := 0;
l_round_distributed_cost                         NUMBER := 0;
l_rest_amount                                    NUMBER := 0;
l_counter                                        NUMBER := 0;
l_cost_brk_count                                 NUMBER := 0;
l_prorated_cost_count                            NUMBER := 0;
l_delivery_quantity                                 NUMBER := 0;
l_Cost_Breakdown                                 CostBreakdownTabType;
l_return_status                                  VARCHAR2(10) := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

WSH_ROUND_AMOUNT_ERROR     EXCEPTION;
WSH_GET_BREAKDOWN_ERR      EXCEPTION;


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CALCULATE_DELIVERY_LEVEL_COST';
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
       WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_COST_TYPE_CODE',P_FREIGHT_COST_TYPE_CODE);
       WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_COST_ID',P_FREIGHT_COST_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_COST_AMOUNT',P_FREIGHT_COST_AMOUNT);
       WSH_DEBUG_SV.log(l_module_name,'P_FROM_CURRENCY_CODE',P_FROM_CURRENCY_CODE);
       WSH_DEBUG_SV.log(l_module_name,'P_CONVERSION_TYPE_CODE',P_CONVERSION_TYPE_CODE);
       WSH_DEBUG_SV.log(l_module_name,'P_CONVERSION_RATE',P_CONVERSION_RATE);

       WSH_DEBUG_SV.log(l_module_name,'P_RELEVANT_INFO_TAB.COUNT',P_RELEVANT_INFO_TAB.count);

   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
                    --
                    -- Debug Statements
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name, 'BEGINNING OF CALCULATE_DELIVERY_LEVEL_COST , DELIVERY_ID: '|| P_DELIVERY_ID || ' FREIGHT_COST_ID: ' || P_FREIGHT_COST_ID );
                    END IF;
                    --
   -- get the cost factor across the whole stop
   -- needs to pass the delivery id as well

   l_delivery_quantity := Get_Delivery_Level_Breakdown(
                          p_delivery_id   => p_delivery_id,
                          p_Relevant_Info_Tab => p_Relevant_Info_Tab,
                          x_Cost_Breakdown => l_Cost_Breakdown,
                          x_return_status => l_return_status
                        );


   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         RAISE WSH_GET_BREAKDOWN_ERR;
   END IF;

   l_cost_brk_count := l_Cost_Breakdown.count;
   l_prorated_cost_count := x_Prorated_Freight_Cost.count;
   l_rest_amount := p_Freight_Cost_Amount;
   IF l_cost_brk_count > 0 THEN
      FOR l_counter IN 1..(l_cost_brk_count -1) LOOP
         l_prorated_cost_count := l_prorated_cost_count +1;
         l_distributed_cost := p_Freight_Cost_Amount * ( l_Cost_Breakdown(l_counter).quantity / l_delivery_quantity);
         Round_Cost_Amount(l_distributed_cost, p_From_Currency_Code, l_round_distributed_cost, l_return_status);
         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            RAISE WSH_ROUND_AMOUNT_ERROR;
         END IF;
         x_Prorated_Freight_Cost(l_prorated_cost_count).delivery_detail_id := l_Cost_Breakdown(l_counter).delivery_detail_id;
         x_Prorated_Freight_Cost(l_prorated_cost_count).freight_cost_type_code := p_freight_cost_type_code;
         x_Prorated_Freight_Cost(l_prorated_cost_count).freight_cost_id := p_freight_cost_id;
         x_Prorated_Freight_Cost(l_prorated_cost_count).amount := l_round_distributed_cost;
         x_Prorated_Freight_Cost(l_prorated_cost_count).currency_code := p_from_currency_code;
         x_Prorated_Freight_Cost(l_prorated_cost_count).conversion_type_code := p_conversion_type_code;
         x_Prorated_Freight_Cost(l_prorated_cost_count).conversion_rate := p_conversion_rate;
         l_rest_amount := l_rest_amount - l_round_distributed_cost;
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_PRORATED_COST_COUNT ||' ) .DELIVERY_DETAIL_ID: '||X_PRORATED_FREIGHT_COST ( L_PRORATED_COST_COUNT ) .DELIVERY_DETAIL_ID );
             WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_PRORATED_COST_COUNT ||' ) .FREIGHT_COST_TYPE_CODE: '||X_PRORATED_FREIGHT_COST ( L_PRORATED_COST_COUNT ) .FREIGHT_COST_TYPE_CODE );
             WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_PRORATED_COST_COUNT ||' ) .FREIGHT_COST_ID: '||X_PRORATED_FREIGHT_COST ( L_PRORATED_COST_COUNT ) .FREIGHT_COST_ID );
             WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_PRORATED_COST_COUNT ||' ) .AMOUNT: '||X_PRORATED_FREIGHT_COST ( L_PRORATED_COST_COUNT ) .AMOUNT );
             WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_PRORATED_COST_COUNT ||' ) .CURRENCY_CODE: '||X_PRORATED_FREIGHT_COST ( L_PRORATED_COST_COUNT ) .CURRENCY_CODE );
             WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_PRORATED_COST_COUNT ||' ) .CONVERSION_TYPE_CODE: '||X_PRORATED_FREIGHT_COST ( L_PRORATED_COST_COUNT ) .CONVERSION_TYPE_CODE );
             WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_PRORATED_COST_COUNT ||' ) .CONVERSION_RATE: '||X_PRORATED_FREIGHT_COST ( L_PRORATED_COST_COUNT ) .CONVERSION_RATE );
         END IF;
         --
      END LOOP;
      -- last record
      l_prorated_cost_count := l_prorated_cost_count +1;
      l_distributed_cost := l_rest_amount;
      Round_Cost_Amount(l_distributed_cost, p_From_Currency_Code, l_round_distributed_cost, l_return_status);
      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         RAISE WSH_ROUND_AMOUNT_ERROR;
      END IF;
      x_Prorated_Freight_Cost(l_prorated_cost_count).delivery_detail_id := l_Cost_Breakdown(l_cost_brk_count).delivery_detail_id;
      x_Prorated_Freight_Cost(l_prorated_cost_count).freight_cost_type_code := p_freight_cost_type_code;
      x_Prorated_Freight_Cost(l_prorated_cost_count).freight_cost_id := p_freight_cost_id;
      x_Prorated_Freight_Cost(l_prorated_cost_count).amount := l_round_distributed_cost;
      x_Prorated_Freight_Cost(l_prorated_cost_count).currency_code := p_from_currency_code;
      x_Prorated_Freight_Cost(l_prorated_cost_count).conversion_type_code := p_conversion_type_code;
      x_Prorated_Freight_Cost(l_prorated_cost_count).conversion_rate := p_conversion_rate;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_PRORATED_COST_COUNT ||' ) .DELIVERY_DETAIL_ID: '||X_PRORATED_FREIGHT_COST ( L_PRORATED_COST_COUNT ) .DELIVERY_DETAIL_ID );
          WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_PRORATED_COST_COUNT ||' ) .FREIGHT_COST_TYPE_CODE: '||X_PRORATED_FREIGHT_COST ( L_PRORATED_COST_COUNT ) .FREIGHT_COST_TYPE_CODE );
          WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_PRORATED_COST_COUNT ||' ) .FREIGHT_COST_ID: '||X_PRORATED_FREIGHT_COST ( L_PRORATED_COST_COUNT ) .FREIGHT_COST_ID );
          WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_PRORATED_COST_COUNT ||' ) .AMOUNT: '||X_PRORATED_FREIGHT_COST ( L_PRORATED_COST_COUNT ) .AMOUNT );
          WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_PRORATED_COST_COUNT ||' ) .CURRENCY_CODE: '||X_PRORATED_FREIGHT_COST ( L_PRORATED_COST_COUNT ) .CURRENCY_CODE );
          WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_PRORATED_COST_COUNT ||' ) .CONVERSION_TYPE_CODE: '||X_PRORATED_FREIGHT_COST ( L_PRORATED_COST_COUNT ) .CONVERSION_TYPE_CODE );
          WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_PRORATED_COST_COUNT ||' ) .CONVERSION_RATE: '||X_PRORATED_FREIGHT_COST ( L_PRORATED_COST_COUNT ) .CONVERSION_RATE );
      END IF;
      --

   END IF;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'END OF CALCULATE_DELIVERY_LEVEL_COST' );
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
EXCEPTION

   WHEN WSH_GET_BREAKDOWN_ERR THEN
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,  'GET COST BREAKDOWN ERROR AT DELIVERY ' || P_DELIVERY_ID  );
         END IF;
         --
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_GET_BREAKDOWN_ERR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_GET_BREAKDOWN_ERR');
END IF;
--
   WHEN WSH_ROUND_AMOUNT_ERROR THEN
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,  'GET ROUND AMOUNT ERROR AT DELIVERY' || P_DELIVERY_ID  );
         END IF;
         --
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_ROUND_AMOUNT_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_ROUND_AMOUNT_ERROR');
END IF;
--
   WHEN others THEN
         WSH_UTIL_CORE.Default_Handler('WSH_FC_INTERFACE.Calculate_Delivery_Level_Cost');
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Calculate_Delivery_Level_Cost;

-- -----------------------------------------------------------------------
-- API name: Calculate_Stop_Level_Cost
-- Type: private
-- Function:
-- Parameters:
-- Notes:   please use :set tabstop=3 to view this file in vi to get
--          proper alignment
--
-- ------------------------------------------------------------------------
PROCEDURE Calculate_Stop_Level_Cost(
  p_Stop_Id                                     IN     NUMBER
, p_Freight_Cost_Type_Code                      IN    VARCHAR2
, p_Freight_Cost_Id                             IN     NUMBER
, p_Freight_Cost_Amount                         IN     NUMBER
, p_From_Currency_Code                          IN     VARCHAR2
, p_Conversion_Type_Code                        IN     WSH_FREIGHT_COSTS.CONVERSION_TYPE_CODE%TYPE
, p_Conversion_Rate                             IN     WSH_FREIGHT_COSTS.CONVERSION_RATE%TYPE
, p_Relevant_Info_Tab                           IN     RelavantInfoTabType
, x_Prorated_Freight_Cost                       IN OUT NOCOPY  ProratedCostTabType
, x_return_status                               OUT NOCOPY  VARCHAR2
)
IS

l_distributed_cost                               NUMBER := 0;
l_round_distributed_cost                         NUMBER := 0;
l_rest_amount                                    NUMBER := 0;
l_counter                                        NUMBER := 0;
l_cost_brk_count                                 NUMBER := 0;
l_prorated_cost_count                            NUMBER := 0;
l_stop_quantity                                  NUMBER := 0;
l_Cost_Breakdown                                 CostBreakdownTabType;
l_return_status                                  VARCHAR2(10) := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

WSH_ROUND_AMOUNT_ERROR     EXCEPTION;
WSH_GET_BREAKDOWN_ERR      EXCEPTION;



--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CALCULATE_STOP_LEVEL_COST';
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
       WSH_DEBUG_SV.log(l_module_name,'P_STOP_ID',P_STOP_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_COST_TYPE_CODE',P_FREIGHT_COST_TYPE_CODE);
       WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_COST_ID',P_FREIGHT_COST_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_COST_AMOUNT',P_FREIGHT_COST_AMOUNT);
       WSH_DEBUG_SV.log(l_module_name,'P_FROM_CURRENCY_CODE',P_FROM_CURRENCY_CODE);
       WSH_DEBUG_SV.log(l_module_name,'P_CONVERSION_TYPE_CODE',P_CONVERSION_TYPE_CODE);
       WSH_DEBUG_SV.log(l_module_name,'P_CONVERSION_RATE',P_CONVERSION_RATE);

       WSH_DEBUG_SV.log(l_module_name,'P_RELEVANT_INFO_TAB.COUNT',P_RELEVANT_INFO_TAB.count);

/*       WSH_DEBUG_SV.log(l_module_name,'P_RELEVANT_INFO_TAB.delivery_detail_id',P_RELEVANT_INFO_TAB.delivery_detail_id);
       WSH_DEBUG_SV.log(l_module_name,'P_RELEVANT_INFO_TAB.container_id',P_RELEVANT_INFO_TAB.container_id);
       WSH_DEBUG_SV.log(l_module_name,'P_RELEVANT_INFO_TAB.delivery_id',P_RELEVANT_INFO_TAB.delivery_id);
       WSH_DEBUG_SV.log(l_module_name,'P_RELEVANT_INFO_TAB.stop_id',P_RELEVANT_INFO_TAB.stop_id);
       WSH_DEBUG_SV.log(l_module_name,'P_RELEVANT_INFO_TAB.trip_id',P_RELEVANT_INFO_TAB.trip_id);
       WSH_DEBUG_SV.log(l_module_name,'P_RELEVANT_INFO_TAB.requested_quantity',P_RELEVANT_INFO_TAB.requested_quantity);
       WSH_DEBUG_SV.log(l_module_name,'P_RELEVANT_INFO_TAB.shipped_quantity',P_RELEVANT_INFO_TAB.shipped_quantity);
       WSH_DEBUG_SV.log(l_module_name,'P_RELEVANT_INFO_TAB.requested_quantity_Uom',P_RELEVANT_INFO_TAB.requested_quantity_uom);
       WSH_DEBUG_SV.log(l_module_name,'P_RELEVANT_INFO_TAB.net_weight',P_RELEVANT_INFO_TAB.net_weight);
       WSH_DEBUG_SV.log(l_module_name,'P_RELEVANT_INFO_TAB.weight_uom_code',P_RELEVANT_INFO_TAB.weight_uom_code);
       WSH_DEBUG_SV.log(l_module_name,'P_RELEVANT_INFO_TAB.volume',P_RELEVANT_INFO_TAB.volume);
       WSH_DEBUG_SV.log(l_module_name,'P_RELEVANT_INFO_TAB.volume_uom_code',P_RELEVANT_INFO_TAB.volume_uom_code);
*/
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
                    --
                    -- Debug Statements
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name, 'BEGINNING OF CALCULATE_STOP_LEVEL COST: '|| P_STOP_ID || ' FREIGHT COST ID: '|| P_FREIGHT_COST_ID );
                    END IF;
                    --
   -- get the cost factor across the whole stop
   -- needs to pass the stop id as well

   l_stop_quantity := Get_Stop_Level_Breakdown(
                          p_Stop_id => p_stop_id,
                          p_Relevant_Info_Tab => p_Relevant_Info_Tab,
                          x_Cost_Breakdown => l_Cost_Breakdown,
                          x_return_status => l_return_status
                        );


   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         RAISE WSH_GET_BREAKDOWN_ERR;
   END IF;

   l_cost_brk_count := l_Cost_Breakdown.count;
   l_prorated_cost_count := x_Prorated_Freight_Cost.count;
   l_rest_amount := p_Freight_Cost_Amount;
   IF l_cost_brk_count > 0 THEN
      FOR l_counter IN 1..(l_cost_brk_count -1) LOOP
         l_prorated_cost_count := l_prorated_cost_count +1;
         l_distributed_cost := p_Freight_Cost_Amount * ( l_Cost_Breakdown(l_counter).quantity / l_stop_quantity);
         Round_Cost_Amount(l_distributed_cost, p_From_Currency_Code, l_round_distributed_cost, l_return_status);
         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            RAISE WSH_ROUND_AMOUNT_ERROR;
         END IF;
         x_Prorated_Freight_Cost(l_prorated_cost_count).delivery_detail_id := l_Cost_Breakdown(l_counter).delivery_detail_id;
         x_Prorated_Freight_Cost(l_prorated_cost_count).freight_cost_type_code := p_freight_cost_type_code;
         x_Prorated_Freight_Cost(l_prorated_cost_count).freight_cost_id := p_freight_cost_id;
         x_Prorated_Freight_Cost(l_prorated_cost_count).amount := l_round_distributed_cost;
         x_Prorated_Freight_Cost(l_prorated_cost_count).currency_code := p_from_currency_code;
         x_Prorated_Freight_Cost(l_prorated_cost_count).conversion_type_code := p_conversion_type_code;
         x_Prorated_Freight_Cost(l_prorated_cost_count).conversion_rate := p_conversion_rate;

         l_rest_amount := l_rest_amount - l_round_distributed_cost;
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_PRORATED_COST_COUNT ||' ) .DELIVERY_DETAIL_ID: '||X_PRORATED_FREIGHT_COST ( L_PRORATED_COST_COUNT ) .DELIVERY_DETAIL_ID );
             WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_PRORATED_COST_COUNT ||' ) .FREIGHT_COST_TYPE_CODE: '||X_PRORATED_FREIGHT_COST ( L_PRORATED_COST_COUNT ) .FREIGHT_COST_TYPE_CODE );
             WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_PRORATED_COST_COUNT ||' ) .FREIGHT_COST_ID: '||X_PRORATED_FREIGHT_COST ( L_PRORATED_COST_COUNT ) .FREIGHT_COST_ID );
             WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_PRORATED_COST_COUNT ||' ) .AMOUNT: '||X_PRORATED_FREIGHT_COST ( L_PRORATED_COST_COUNT ) .AMOUNT );
             WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_PRORATED_COST_COUNT ||' ) .CURRENCY_CODE: '||X_PRORATED_FREIGHT_COST ( L_PRORATED_COST_COUNT ) .CURRENCY_CODE );
             WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_PRORATED_COST_COUNT ||' ) .CONVERSION_TYPE_CODE: '||X_PRORATED_FREIGHT_COST ( L_PRORATED_COST_COUNT ) .CONVERSION_TYPE_CODE );
             WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_PRORATED_COST_COUNT ||' ) .CONVERSION_RATE: '||X_PRORATED_FREIGHT_COST ( L_PRORATED_COST_COUNT ) .CONVERSION_RATE );
         END IF;
         --

      END LOOP;
      -- last record
      l_prorated_cost_count := l_prorated_cost_count +1;
      l_distributed_cost := l_rest_amount;
      Round_Cost_Amount(l_distributed_cost, p_From_Currency_Code, l_round_distributed_cost, l_return_status);
      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         RAISE WSH_ROUND_AMOUNT_ERROR;
      END IF;
      x_Prorated_Freight_Cost(l_prorated_cost_count).delivery_detail_id := l_Cost_Breakdown(l_cost_brk_count).delivery_detail_id;
      x_Prorated_Freight_Cost(l_prorated_cost_count).freight_cost_type_code := p_freight_cost_type_code;
      x_Prorated_Freight_Cost(l_prorated_cost_count).freight_cost_id := p_freight_cost_id;
      x_Prorated_Freight_Cost(l_prorated_cost_count).amount := l_round_distributed_cost;
      x_Prorated_Freight_Cost(l_prorated_cost_count).currency_code := p_from_currency_code;
      x_Prorated_Freight_Cost(l_prorated_cost_count).conversion_type_code := p_conversion_type_code;
      x_Prorated_Freight_Cost(l_prorated_cost_count).conversion_rate := p_conversion_rate;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_PRORATED_COST_COUNT ||' ) .DELIVERY_DETAIL_ID: '||X_PRORATED_FREIGHT_COST ( L_PRORATED_COST_COUNT ) .DELIVERY_DETAIL_ID );
          WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_PRORATED_COST_COUNT ||' ) .FREIGHT_COST_TYPE_CODE: '||X_PRORATED_FREIGHT_COST ( L_PRORATED_COST_COUNT ) .FREIGHT_COST_TYPE_CODE );
          WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_PRORATED_COST_COUNT ||' ) .FREIGHT_COST_ID: '||X_PRORATED_FREIGHT_COST ( L_PRORATED_COST_COUNT ) .FREIGHT_COST_ID );
          WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_PRORATED_COST_COUNT ||' ) .AMOUNT: '||X_PRORATED_FREIGHT_COST ( L_PRORATED_COST_COUNT ) .AMOUNT );
          WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_PRORATED_COST_COUNT ||' ) .CURRENCY_CODE: '||X_PRORATED_FREIGHT_COST ( L_PRORATED_COST_COUNT ) .CURRENCY_CODE );
          WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_PRORATED_COST_COUNT ||' ) .CONVERSION_TYPE_CODE: '||X_PRORATED_FREIGHT_COST ( L_PRORATED_COST_COUNT ) .CONVERSION_TYPE_CODE );
          WSH_DEBUG_SV.logmsg(l_module_name, 'X_PRORATED_FREIGHT_COST ( ' || L_PRORATED_COST_COUNT ||' ) .CONVERSION_RATE: '||X_PRORATED_FREIGHT_COST ( L_PRORATED_COST_COUNT ) .CONVERSION_RATE );
      END IF;
      --
   END IF;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'END OF CALCULATE_STOP_LEVEL_COST' );
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
EXCEPTION

   WHEN WSH_GET_BREAKDOWN_ERR THEN
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,  'GET COST BREAKDOWN ERROR AT STOP ' || P_STOP_ID  );
         END IF;
         --
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_GET_BREAKDOWN_ERR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_GET_BREAKDOWN_ERR');
END IF;
--
   WHEN WSH_ROUND_AMOUNT_ERROR THEN
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,  'GET ROUND AMOUNT ERROR AT STOP' || P_STOP_ID  );
         END IF;
         --
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_ROUND_AMOUNT_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_ROUND_AMOUNT_ERROR');
END IF;
--
   WHEN others THEN
         WSH_UTIL_CORE.Default_Handler('WSH_FC_INTERFACE.Calculate_Stop_Level_Cost');
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Calculate_Stop_Level_Cost;


-- -----------------------------------------------------------------------
-- PROCEDURE NAME: Calculate_Trip_Level_Cost
-- This procedure evenly distributes the trip level cost to all the
-- stops having pickup deliveries.
-- For freight cost at all other levels, the cost
-- is distributed according to weight , volume, or shipped quantity propotionally.
-- ------------------------------------------------------------------------
PROCEDURE Calculate_Trip_Level_Cost(
  p_Trip_Id                                     IN     NUMBER
, p_Stop_ID                                     IN     NUMBER DEFAULT NULL
, p_Delivery_ID                                 IN     NUMBER DEFAULT NULL
, p_Freight_Cost_Type_Code                      IN     VARCHAR2
, p_Freight_Cost_Id                             IN     NUMBER
, p_Freight_Cost_Amount                         IN     NUMBER
, p_From_Currency_Code                          IN     VARCHAR2
, p_Conversion_Type_Code                        IN     WSH_FREIGHT_COSTS.CONVERSION_TYPE_CODE%TYPE
, p_Conversion_Rate                             IN     WSH_FREIGHT_COSTS.CONVERSION_RATE%TYPE
, p_Relevant_Info_Tab                           IN     RelavantInfoTabType
, x_Prorated_Freight_Cost                       IN OUT NOCOPY  ProratedCostTabType
, x_return_status                               OUT NOCOPY  VARCHAR2
)
IS

CURSOR C_Sharing_Stops IS
SELECT distinct st.stop_id
FROM wsh_trip_stops st,
     wsh_new_deliveries nd,
     wsh_delivery_legs  dl,
     wsh_delivery_assignments_v da,
     wsh_delivery_details dd
WHERE
     st.trip_id = p_trip_id and
     st.stop_id = dl.pick_up_stop_id and
     dl.delivery_id = nd.delivery_id and
     st.stop_location_id = nd.initial_pickup_location_id and
     da.delivery_detail_id = dd.delivery_detail_id and
     dd.shipped_quantity > 0 and
     dd.container_flag = 'N' and
     da.delivery_id IS NOT NULL and
     da.delivery_id = nd.delivery_id and
     nvl(dd.line_direction,'O') IN ('O','IO');

l_number_of_stops                                NUMBER := 0;
i                                                NUMBER := 0;
l_distributed_cost                               NUMBER := 0;
l_stop_id                                        NUMBER := 0;
l_cost_per_stop                                  NUMBER := 0;
l_round_cost_per_stop                            NUMBER := 0;
l_remained_cost                                  NUMBER := 0;
l_Cost_Breakdown                                 CostBreakdownTabType;
l_return_status                                  VARCHAR2(10) := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


WSH_ROUND_AMOUNT_ERROR     EXCEPTION;


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CALCULATE_TRIP_LEVEL_COST';
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
       WSH_DEBUG_SV.log(l_module_name,'P_STOP_ID',P_STOP_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_COST_TYPE_CODE',P_FREIGHT_COST_TYPE_CODE);
       WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_COST_ID',P_FREIGHT_COST_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_COST_AMOUNT',P_FREIGHT_COST_AMOUNT);
       WSH_DEBUG_SV.log(l_module_name,'P_FROM_CURRENCY_CODE',P_FROM_CURRENCY_CODE);
       WSH_DEBUG_SV.log(l_module_name,'P_CONVERSION_TYPE_CODE',P_CONVERSION_TYPE_CODE);
       WSH_DEBUG_SV.log(l_module_name,'P_CONVERSION_RATE',P_CONVERSION_RATE);


       WSH_DEBUG_SV.log(l_module_name,'P_RELEVANT_INFO_TAB.COUNT',P_RELEVANT_INFO_TAB.count);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
                    --
                    -- Debug Statements
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name, 'BEGINNING OF CALCULATE TRIP LEVEL COST:' || P_TRIP_ID || ' FREIGHT COST ID: '|| P_FREIGHT_COST_ID );
                    END IF;
                    --
/* get number of stops with pickup deliveries in this trip */
select count(distinct st.stop_id) into l_number_of_stops
from wsh_trip_stops st,
     wsh_new_deliveries nd,
     wsh_delivery_legs  dl,
     wsh_delivery_assignments_v da,
     wsh_delivery_details dd
where
     st.trip_id = p_trip_id and
     st.stop_id = dl.pick_up_stop_id and
     dl.delivery_id = nd.delivery_id and
     st.stop_location_id = nd.initial_pickup_location_id and
     da.delivery_detail_id = dd.delivery_detail_id and
     dd.shipped_quantity > 0 and
     dd.container_flag = 'N' and
     da.delivery_id IS NOT NULL and
     da.delivery_id = nd.delivery_id and
     nvl(dd.line_direction,'O') IN ('O','IO');

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name, 'NUMBER OF STOPS WITH FREIGHT COST IN TRIP '||P_TRIP_ID || ' IS: ' || L_NUMBER_OF_STOPS );
END IF;
--
IF l_number_of_stops > 0 THEN

   l_cost_per_stop := p_Freight_Cost_Amount/ l_number_of_stops;
      Round_Cost_Amount(l_cost_per_stop, p_From_Currency_Code, l_round_cost_per_stop, l_return_status);
      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         RAISE WSH_ROUND_AMOUNT_ERROR;
      END IF;

   OPEN C_Sharing_Stops;
   i := 0;
   l_distributed_cost := 0;

   LOOP
      FETCH C_Sharing_Stops into l_stop_id;
      EXIT WHEN C_Sharing_Stops%NOTFOUND;
      i := i + 1;
      IF i < l_number_of_stops THEN
         Calculate_Stop_Level_Cost(
           p_Stop_Id => l_stop_id
         , p_Freight_Cost_Type_Code => p_Freight_Cost_Type_Code
         , p_Freight_Cost_Id => p_Freight_cost_id
         , p_Freight_Cost_Amount => l_round_cost_per_stop
         , p_From_Currency_Code => p_From_Currency_Code
         , p_conversion_type_code => p_conversion_type_code
         , p_conversion_rate => p_conversion_rate
         , p_Relevant_Info_Tab => p_Relevant_Info_Tab
         , x_Prorated_Freight_Cost => x_Prorated_Freight_Cost
         , x_return_status => x_return_status
         );
         l_distributed_cost := l_distributed_cost + l_round_cost_per_stop;
      ELSE
         -- last stop in the trip
         l_remained_cost := p_Freight_Cost_Amount - l_distributed_cost;
         Calculate_Stop_Level_Cost(
           p_Stop_Id => l_stop_id
         , p_Freight_Cost_Type_Code => p_Freight_Cost_Type_Code
         , p_Freight_Cost_Id => p_Freight_cost_id
         , p_Freight_Cost_Amount => l_remained_cost
         , p_From_Currency_Code => p_From_Currency_Code
         , p_conversion_type_code => p_conversion_type_code
         , p_conversion_rate => p_conversion_rate
         , p_Relevant_Info_Tab => p_Relevant_Info_Tab
         , x_Prorated_Freight_Cost => x_Prorated_Freight_Cost
         , x_return_status => x_return_status
         );
      END IF;
   END LOOP;

CLOSE C_Sharing_Stops;
END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name, 'END OF CALCULATE TRIP LEVEL COST' );
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION

   WHEN WSH_ROUND_AMOUNT_ERROR THEN
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,  'GET ROUND AMOUNT ERROR AT TRIP ' || P_TRIP_ID  );
         END IF;
         --
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_ROUND_AMOUNT_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_ROUND_AMOUNT_ERROR');
END IF;
--
   WHEN others THEN
         WSH_UTIL_CORE.Default_Handler('WSH_FC_INTERFACE.Calculate_Trip_Level_Cost');
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Calculate_Trip_Level_Cost;

-- -----------------------------------------------------------------------------------------
-- PROCEDURE NAME: Round_Cost_Amount
-- ------------------------------------------------------------------------------------------
PROCEDURE Round_Cost_Amount(
  p_Amount                          IN     NUMBER
, p_Currency_Code                IN     VARCHAR2
, x_Round_Amount                    OUT NOCOPY  NUMBER
, x_return_status                OUT NOCOPY  VARCHAR2
)
IS

l_precision                      NUMBER;
l_minimum_accountable_unit       NUMBER;

WSH_NO_CURRENCY                  EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ROUND_COST_AMOUNT';
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
       WSH_DEBUG_SV.log(l_module_name,'P_AMOUNT',P_AMOUNT);
       WSH_DEBUG_SV.log(l_module_name,'P_CURRENCY_CODE',P_CURRENCY_CODE);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   SELECT precision, nvl(minimum_accountable_unit, 0)
   INTO l_precision, l_minimum_accountable_unit
   FROM fnd_currencies
   WHERE currency_code = p_Currency_Code;
   IF SQL%NOTFOUND THEN
      RAISE WSH_NO_CURRENCY;
   END IF;

   x_Round_Amount := Round(p_Amount, l_precision);


--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'x_round_amount',x_round_amount);
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION

   WHEN WSH_NO_CURRENCY THEN
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,  'THE FREIGHT COST CURRENCY IS NOT RECOGNIZED IN THE SYSTEM'  );
         END IF;
         --
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_NO_CURRENCY exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_NO_CURRENCY');
END IF;
--
   WHEN others THEN
         WSH_UTIL_CORE.Default_Handler('WSH_FC_INTERFACE.Round_Cost_Amount');
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Round_Cost_Amount;


-- -----------------------------------------------------------------------------------------
-- PROCEDURE NAME: Source_Line_Level_Cost
-- ------------------------------------------------------------------------------------------
PROCEDURE Source_Line_Level_Cost(
  p_stop_id                         IN     NUMBER
, p_prorated_freight_cost           IN     ProratedCostTabType
, x_Final_Cost                      IN OUT NOCOPY  OMInterfaceCostTabType
, x_return_status                   OUT NOCOPY  VARCHAR2
)

IS


CURSOR C_OE_Curr_Info (c_delivery_detail_id  NUMBER)
IS
SELECT h.transactional_curr_code,
       h.conversion_type_code,
       h.conversion_rate_date,
       h.conversion_rate,
       l.line_id,
       l.header_id
FROM oe_order_headers_all h, oe_order_lines_all l, wsh_delivery_details wdd
WHERE wdd.delivery_detail_id = c_delivery_detail_id AND
      wdd.source_line_id = l.line_id AND
      wdd.source_code = 'OE' and
      l.header_id = h.header_id;

l_OE_Curr_Rec C_OE_Curr_Info%ROWTYPE;


CURSOR C_ACTUAL_DEPARTURE_DATE IS
SELECT actual_departure_date
FROM WSH_TRIP_STOPS
WHERE stop_id = p_stop_id;


i                                NUMBER := 0;
j                                NUMBER := 0;
l_source_line_id                 NUMBER := 0;
l_next_tab_id                    NUMBER := 0;
l_amount                         NUMBER := 0;
l_line_currency_code             VARCHAR2(15) := NULL;
l_conversion_date                DATE;
l_conversion_type                VARCHAR2(30) := NULL;

l_new_source_line_id             BOOLEAN := TRUE;
l_max_roll_days                  NUMBER := 0;
l_actual_departure_date          DATE := NULL;
l_converted_amount               NUMBER := 0;
l_denominator                    NUMBER := 0;
l_numerator                      NUMBER := 0;
l_rate                           NUMBER := 0;
l_rate_exists                    VARCHAR2(1) := 'N' ;
oe_currency_not_exist            EXCEPTION;
no_user_defined_rate             EXCEPTION;
WSH_NO_ACTUALL_DEPARTURE_DATE    EXCEPTION;
WSH_STOP_NOT_FOUND               EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SOURCE_LINE_LEVEL_COST';
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
       WSH_DEBUG_SV.log(l_module_name,'P_STOP_ID',P_STOP_ID);
       WSH_DEBUG_SV.log(l_module_name,'p_prorated_freight_cost.COUNT',p_prorated_freight_cost.COUNT);
/*
       WSH_DEBUG_SV.log(l_module_name,'p_prorated_freight_cost.delivery_detail_id',p_prorated_freight_cost.delivery_detail_id);
       WSH_DEBUG_SV.log(l_module_name,'p_prorated_freight_cost.freight_cost_type_code',p_prorated_freight_cost.freight_cost_type_code);
       WSH_DEBUG_SV.log(l_module_name,'p_prorated_freight_cost.freight_cost_id',p_prorated_freight_cost.freight_cost_id);
       WSH_DEBUG_SV.log(l_module_name,'p_prorated_freight_cost.amount',p_prorated_freight_cost.amount);
       WSH_DEBUG_SV.log(l_module_name,'p_prorated_freight_cost.currency_code',p_prorated_freight_cost.currency_code);
       WSH_DEBUG_SV.log(l_module_name,'p_prorated_freight_cost.conversion_type_code',p_prorated_freight_cost.conversion_type_code);
       WSH_DEBUG_SV.log(l_module_name,'p_prorated_freight_cost.conversion_rate',p_prorated_freight_cost.conversion_rate);

*/
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name, 'BEGINNING OF SOURCE_LINE_LEVEL_COST , STOP_ID: '|| P_STOP_ID );
   END IF;
   --
   l_next_tab_id := x_Final_Cost.COUNT + 1;
   <<Outer_LOOP>>
   FOR i IN 1 .. p_prorated_freight_cost.count

   LOOP

      OPEN C_OE_Curr_Info(p_prorated_freight_cost(i).delivery_detail_id);
      FETCH C_OE_Curr_Info INTO l_OE_Curr_Rec;
      IF (C_OE_Curr_Info%NOTFOUND) THEN
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name, 'C_OE_CURR_INFO DOES NOT FETCH A RECORD' );
         END IF;
         --
      END IF;
      CLOSE C_OE_Curr_Info;

      IF (l_oe_curr_rec.transactional_curr_code IS NULL) THEN
         RAISE oe_Currency_Not_Exist;
      ELSE
         l_line_currency_code := l_OE_Curr_Rec.transactional_curr_code;
      END IF;

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'l_OE_Curr_Rec.conversion_type_code',l_OE_Curr_Rec.conversion_type_code );
         WSH_DEBUG_SV.log(l_module_name, 'l_OE_Curr_Rec.conversion_rate_date', to_char(l_OE_Curr_Rec.conversion_rate_date, 'DD-MON-YY HH24:MI:SS'));
         WSH_DEBUG_SV.log(l_module_name, 'l_OE_Curr_Rec.conversion_rate', to_char(l_OE_Curr_Rec.conversion_rate));
      END IF;
      -- bug 3455978
      l_conversion_type := NVL(l_OE_Curr_Rec.conversion_type_code, 'Corporate');

      IF (l_oe_curr_rec.conversion_rate_date IS NOT NULL) THEN
         l_conversion_date := l_oe_curr_rec.conversion_rate_date;
      ELSE
         IF l_actual_departure_date is NULL THEN
            OPEN C_ACTUAL_DEPARTURE_DATE;
            FETCH C_ACTUAL_DEPARTURE_DATE INTO l_actual_departure_date;
            IF C_ACTUAL_DEPARTURE_DATE%NOTFOUND THEN
                  CLOSE C_ACTUAL_DEPARTURE_DATE;
                  raise WSH_STOP_NOT_FOUND;
            END IF;
            CLOSE C_ACTUAL_DEPARTURE_DATE;
            IF l_actual_departure_date IS NULL THEN
                  raise WSH_NO_ACTUALL_DEPARTURE_DATE;
            END IF;
         END IF;
         l_conversion_date := l_actual_departure_date;
      END IF;

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'l_conversion_type', l_conversion_type);
         WSH_DEBUG_SV.log(l_module_name,'l_OE_Curr_Rec.conversion_rate', to_char(l_OE_Curr_Rec.conversion_rate));
         WSH_DEBUG_SV.log(l_module_name,'l_conversion_date', to_char(l_conversion_date, 'DD-MON-YY HH24:MI:SS'));
      END IF;

      l_max_roll_days := 300;

      l_new_source_line_id := TRUE;

      <<Inner_Loop>>
      -- merge the entries which share the same source_line_id and freight_cost_id
      FOR j in 1 .. x_Final_Cost.COUNT
      LOOP

         IF (x_Final_Cost(j).source_line_id = l_OE_Curr_Rec.line_id AND
             x_Final_Cost(j).freight_cost_id = p_prorated_freight_cost(i).freight_cost_id) THEN

            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit GL_CURRENCY_API.IS_FIXED_RATE',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            IF (GL_CURRENCY_API.Is_Fixed_Rate(p_prorated_freight_cost(i).currency_code, l_line_currency_code, l_conversion_date) = 'Y') THEN
               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name, 'ADDING P_PRORATED_FREIGHT_COST ( ' || I ||' ) TO X_FINAL_COST ( '||J||' ) USING FIXED RATE' );
               END IF;
               --
               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit GL_CURRENCY_API.CONVERT_AMOUNT',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               --
               x_Final_Cost(j).amount := x_Final_Cost(j).amount + GL_CURRENCY_API.convert_amount(
                     p_prorated_freight_cost(i).currency_code, l_line_currency_code, l_conversion_date, NVL(p_prorated_freight_cost(i).conversion_type_code,l_conversion_type), p_prorated_freight_cost(i).amount);
            -- bug 3455978  use the conversion_type_code from wsh_freight_costs
            ELSIF (p_prorated_freight_cost(i).conversion_type_code = 'User') THEN
               IF (p_prorated_freight_cost(i).conversion_rate IS NOT NULL) THEN
                  --
                  -- Debug Statements
                  --
                  IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name, 'ADDING P_PRORATED_FREIGHT_COST ( ' || I ||' ) TO X_FINAL_COST ( '||J||' ) USING THE RATE OF THE FREIGHT COST, CONVERSION RATE:' ||to_char(p_prorated_freight_cost(i).conversion_rate ));
                  END IF;
                  --
                  x_Final_Cost(j).amount := x_Final_Cost(j).amount + p_prorated_freight_cost(i).amount * p_prorated_freight_cost(i).conversion_rate;

               ELSE
                  --
                  -- Debug Statements
                  --
                  IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name, 'CONVERSION_TYPE IS USER BUT NO CONVERSION_RATE DEFINED IN FREIGHT COST , PROCESS_FREIGHT_COST FAILED' );
                  END IF;
                  --
                  RAISE No_User_Defined_Rate;
               END IF;
            ELSIF (l_conversion_type = 'User') THEN
               IF (l_OE_Curr_Rec.conversion_rate IS NOT NULL) THEN
                  --
                  -- Debug Statements
                  --
                  IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name, 'ADDING P_PRORATED_FREIGHT_COST ( ' || I ||' ) TO X_FINAL_COST ( '||J||' ) USING USER SPCIFIED RATE , CONVERSION RATE:' ||L_OE_CURR_REC.CONVERSION_RATE );
                  END IF;
                  --
                  x_Final_Cost(j).amount := x_Final_Cost(j).amount + p_prorated_freight_cost(i).amount * l_oe_curr_rec.conversion_rate;
               ELSE
                  --
                  -- Debug Statements
                  --
                  IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name, 'CONVERSION_TYPE IS USER BUT NO CONVERSION_RATE DEFINED IN OM PART EITHER , PROCESS_FREIGHT_COST FAILED' );
                  END IF;
                  --
                  RAISE No_User_Defined_Rate;
               END IF;
            ELSE

               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit GL_CURRENCY_API.RATE_EXISTS',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               --
               l_rate_exists := GL_CURRENCY_API.Rate_Exists(
                  x_from_currency   => p_prorated_freight_cost(i).currency_code,
                  x_to_currency     => l_line_currency_code,
                  x_conversion_date => l_conversion_date,
                  x_conversion_type => NVL(p_prorated_freight_cost(i).conversion_type_code,l_conversion_type)
                  );
               IF (l_rate_exists = 'Y') THEN
                  --
                  -- Debug Statements
                  --
                  IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name, 'ADDING P_PRORATED_FREIGHT_COST ( ' || I ||' ) TO X_FINAL_COST ( '||J||' ) USING FLOATING RATE DECIDED BY CONVERSION DATE' || TO_CHAR ( L_CONVERSION_DATE, 'DD-MON-YY HH24:MI:SS' ) );
                  END IF;
                  --
                  --
                  -- Debug Statements
                  --
                  IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit GL_CURRENCY_API.CONVERT_AMOUNT',WSH_DEBUG_SV.C_PROC_LEVEL);
                  END IF;
                  --
                  -- bug 4135443
                  x_Final_Cost(j).amount := x_Final_Cost(j).amount +
                    GL_CURRENCY_API.convert_amount(p_prorated_freight_cost(i).currency_code,
                                                   l_line_currency_code,
                                                   l_conversion_date,
                                                   NVL(p_prorated_freight_cost(i).conversion_type_code,l_conversion_type),
                                                   p_prorated_freight_cost(i).amount);
               ELSE
                  --
                  -- Debug Statements
                  --
                  IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name, 'ADDING P_PRORATED_FREIGHT_COST ( ' || I ||' ) TO X_FINAL_COST ( '||J||' ) , NO RATE EXISTS , CONVERT TO CLOSEST AMOUNT , CONVERSION DATE:'|| TO_CHAR ( L_CONVERSION_DATE, 'DD-MON-YY HH24:MI:SS') );
                  END IF;
                  --
                  --
                  -- Debug Statements
                  --
                  IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit GL_CURRENCY_API.CONVERT_CLOSEST_AMOUNT',WSH_DEBUG_SV.C_PROC_LEVEL);
                  END IF;
                  --
                  GL_CURRENCY_API.convert_closest_amount(
                     x_from_currency   => p_prorated_freight_cost(i).currency_code,
                     x_to_currency     => l_line_currency_code,
                     x_conversion_date => l_conversion_date,
                     x_conversion_type => NVL(p_prorated_freight_cost(i).conversion_type_code,l_conversion_type),
                     x_user_rate       => l_OE_Curr_Rec.conversion_rate,
                     x_amount          => p_prorated_freight_cost(i).amount,
                     x_max_roll_days   => l_max_roll_days,
                     x_converted_amount=> l_converted_amount,
                     x_denominator     => l_denominator,
                     x_numerator       => l_numerator,
                     x_rate            => l_rate);
                     x_Final_Cost(j).amount := x_Final_Cost(j).amount + l_converted_amount;
               END IF;
            END IF;
            l_new_source_line_id := FALSE;
         END IF;
      END LOOP Inner_Loop;

      IF (l_new_source_line_id = TRUE) THEN
         l_next_tab_id := x_Final_Cost.COUNT + 1;

         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit GL_CURRENCY_API.IS_FIXED_RATE',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --
         IF (GL_CURRENCY_API.Is_Fixed_Rate(p_prorated_freight_cost(i).currency_code, l_line_currency_code, l_conversion_date) = 'Y') THEN
               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name, 'SET P_PRORATED_FREIGHT_COST ( ' || I ||' ) TO X_FINAL_COST ( '||L_NEXT_TAB_ID||' ) USING FIXED RATE , CONVERSION DATE:' || TO_CHAR ( L_CONVERSION_DATE,'DD-MON-YY HH24:MI:SS' ) );
               END IF;
               --
               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit GL_CURRENCY_API.CONVERT_AMOUNT',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               --
               x_Final_Cost(l_next_tab_id).amount :=
               GL_CURRENCY_API.convert_amount(
                  p_prorated_freight_cost(i).currency_code,
                  l_line_currency_code,
                  l_conversion_date,
                  NVL(p_prorated_freight_cost(i).conversion_type_code,l_conversion_type),
                  p_prorated_freight_cost(i).amount);
         -- bug 3455978  use the conversion_type_code from wsh_freight_costs
         ELSIF (p_prorated_freight_cost(i).conversion_type_code = 'User') THEN
            IF (p_prorated_freight_cost(i).conversion_rate IS NOT NULL) THEN
               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name, 'SET P_PRORATED_FREIGHT_COST ( ' || I ||' ) TO X_FINAL_COST ( '||L_NEXT_TAB_ID||' ) USING THE RATE OF THE FREIGHT COST , CONVERSION RATE:' ||to_char(p_prorated_freight_cost(i).conversion_rate) );
               END IF;
               --
               x_Final_Cost(l_next_tab_id).amount := p_prorated_freight_cost(i).amount * p_prorated_freight_cost(i).conversion_rate;
            ELSE
               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name, 'CONVERSION_TYPE IS USER BUT NO CONVERSION_RATE DEFINED IN FREIGHT COST EITHER , PROCESS_FREIGHT_COST FAILED' );
               END IF;
               --
               RAISE No_User_Defined_Rate;
            END IF;
         ELSIF (l_conversion_type = 'User') THEN
            IF (l_OE_Curr_Rec.conversion_rate IS NOT NULL) THEN
               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name, 'SET P_PRORATED_FREIGHT_COST ( ' || I ||' ) TO X_FINAL_COST ( '||L_NEXT_TAB_ID||' ) USING USER SPCIFIED RATE , CONVERSION RATE:' ||L_OE_CURR_REC.CONVERSION_RATE );
               END IF;
               --
               x_Final_Cost(l_next_tab_id).amount := p_prorated_freight_cost(i).amount * l_oe_curr_rec.conversion_rate;
            ELSE
               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name, 'CONVERSION_TYPE IS USER BUT NO CONVERSION_RATE DEFINED IN OM PART EITHER , PROCESS_FREIGHT_COST FAILED' );
               END IF;
               --
               RAISE No_User_Defined_Rate;
            END IF;
         ELSE
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit GL_CURRENCY_API.RATE_EXISTS',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            l_rate_exists := GL_CURRENCY_API.Rate_Exists(
               x_from_currency   => p_prorated_freight_cost(i).currency_code,
               x_to_currency     => l_line_currency_code,
               x_conversion_date => l_conversion_date,
               x_conversion_type => NVL(p_prorated_freight_cost(i).conversion_type_code,l_conversion_type)
               );
            IF (l_rate_exists = 'Y') THEN
               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name, 'SET P_PRORATED_FREIGHT_COST ( '|| I ||' ) TO X_FINAL_COST ( '||L_NEXT_TAB_ID||' ) USING FLOATING RATE DECIDED BY CONVERSION DATE:' || TO_CHAR ( L_CONVERSION_DATE, 'DD-MON-YY HH24:MI:SS' ) );
                   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit GL_CURRENCY_API.CONVERT_AMOUNT',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               --
               -- bug 4135443
               x_Final_Cost(l_next_tab_id).amount := GL_CURRENCY_API.convert_amount (
                                                     p_prorated_freight_cost(i).currency_code, l_line_currency_code,
                                                     l_conversion_date,
                                                     NVL(p_prorated_freight_cost(i).conversion_type_code,l_conversion_type),
                                                     p_prorated_freight_cost(i).amount);
            ELSE
               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name, 'SET P_PRORATED_FREIGHT_COST ( ' || I ||' ) TO X_FINAL_COST ( '||L_NEXT_TAB_ID||' ) , NO RATE EXISTS , CONVERT TO CLOSEST AMOUNT , CONVERSION DATE:'||
                   TO_CHAR ( L_CONVERSION_DATE , 'DD-MON-YY HH24:MI:SS') );
                   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit GL_CURRENCY_API.CONVERT_CLOSEST_AMOUNT',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               --
               --
               GL_CURRENCY_API.convert_closest_amount(
                  x_from_currency   => p_prorated_freight_cost(i).currency_code,
                  x_to_currency     => l_line_currency_code,
                  x_conversion_date => l_conversion_date,
                  x_conversion_type => NVL(p_prorated_freight_cost(i).conversion_type_code,l_conversion_type),
                  x_user_rate       => l_OE_Curr_Rec.conversion_rate,
                  x_amount          => p_prorated_freight_cost(i).amount,
                  x_max_roll_days   => l_max_roll_days,
                  x_converted_amount=> l_converted_amount,
                  x_denominator     => l_denominator,
                  x_numerator       => l_numerator,
                  x_rate            => l_rate);
               x_Final_Cost(l_next_tab_id).amount := l_converted_amount;
            END IF;
         END IF;
         x_Final_Cost(l_next_tab_id).freight_cost_type_code := p_prorated_freight_cost(i).freight_cost_type_code;
         x_Final_Cost(l_next_tab_id).freight_cost_id := p_prorated_freight_cost(i).freight_cost_id;
         x_Final_Cost(l_next_tab_id).source_line_id := l_OE_Curr_Rec.line_id;
         x_Final_Cost(l_next_tab_id).source_header_id := l_OE_Curr_Rec.header_id;
         x_Final_Cost(l_next_tab_id).currency_code := l_line_currency_code;
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name, 'X_FINAL_COST ( ' || L_NEXT_TAB_ID || ' ) .FREIGHT_COST_TYPE_CODE: '|| X_FINAL_COST ( L_NEXT_TAB_ID ) .FREIGHT_COST_TYPE_CODE );
             WSH_DEBUG_SV.logmsg(l_module_name, 'X_FINAL_COST ( ' || L_NEXT_TAB_ID || ' ) .FREIGHT_COST_ID: '|| X_FINAL_COST ( L_NEXT_TAB_ID ) .FREIGHT_COST_ID );
             WSH_DEBUG_SV.logmsg(l_module_name, 'X_FINAL_COST ( ' || L_NEXT_TAB_ID || ' ) .SOURCE_LINE_ID: '|| X_FINAL_COST ( L_NEXT_TAB_ID ) .SOURCE_LINE_ID );
             WSH_DEBUG_SV.logmsg(l_module_name, 'X_FINAL_COST ( ' || L_NEXT_TAB_ID || ' ) .SOURCE_HEADER_ID: '|| X_FINAL_COST ( L_NEXT_TAB_ID ) .SOURCE_HEADER_ID );
             WSH_DEBUG_SV.logmsg(l_module_name, 'X_FINAL_COST ( ' || L_NEXT_TAB_ID || ' ) .CURRENCY_CODE: '|| X_FINAL_COST ( L_NEXT_TAB_ID ) .CURRENCY_CODE );
             WSH_DEBUG_SV.logmsg(l_module_name, 'X_FINAL_COST ( ' || L_NEXT_TAB_ID || ' ) .AMOUNT: '|| X_FINAL_COST ( L_NEXT_TAB_ID ) .AMOUNT );
         END IF;
         --
      END IF;
   END LOOP Outer_Loop;
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name, 'END OF SOURCE_LINE_LEVEL_COST , STOP_ID: '|| P_STOP_ID );
     WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   EXCEPTION
      WHEN WSH_STOP_NOT_FOUND THEN
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,  'STOP '|| P_STOP_ID || ' NOT FOUND'  );
         END IF;
         --
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'WSH_STOP_NOT_FOUND exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
             WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_STOP_NOT_FOUND');
         END IF;
         --
      WHEN WSH_NO_ACTUALL_DEPARTURE_DATE THEN
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,  'NO ACTUAL DEPARTURE DATE FOR STOP '|| P_STOP_ID  );
         END IF;
         --
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'WSH_NO_ACTUALL_DEPARTURE_DATE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
             WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_NO_ACTUALL_DEPARTURE_DATE');
         END IF;
         --
      WHEN GL_CURRENCY_API.No_Rate THEN
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,  'PROCESS FREIGHT COSTS FAILED BECUASE NO RATE EXISTS BETWEEN THESE TWO CURRENCY'  );
         END IF;
         --
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'GL_CURRENCY_API.NO_RATE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
             WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:GL_CURRENCY_API.NO_RATE');
         END IF;
         --
      WHEN GL_CURRENCY_API.Invalid_Currency THEN
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,  'INVALID CURRENCY FOR FROM CURRENCY_CODE OR TO CURRENCY_CODE'  );
         END IF;
         --
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'GL_CURRENCY_API.INVALID_CURRENCY exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
             WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:GL_CURRENCY_API.INVALID_CURRENCY');
         END IF;
         --
      WHEN Oe_currency_Not_Exist THEN
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,  'CURRENCY_CODE FROM OM HEADER TABLE DOES NOT EXIST'  );
         END IF;
         --
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'OE_CURRENCY_NOT_EXIST exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
             WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OE_CURRENCY_NOT_EXIST');
         END IF;
         --
      WHEN no_user_defined_rate THEN
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,  'FREIGHT COST API FAILED BECAUSE CONVERSION_TYPE IS USER BUG NO USER-DEFINED RATE EXISTS'  );
         END IF;
         --
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'NO_USER_DEFINED_RATE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
             WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NO_USER_DEFINED_RATE');
         END IF;
         --
      WHEN others THEN
         WSH_UTIL_CORE.Default_Handler('WSH_FC_INTERFACE.Source_line_level_cost');
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Source_Line_Level_Cost;

-- -----------------------------------------------------------------------------------------
-- PROCEDURE NAME: Calculate_Freight_Costs
-- ------------------------------------------------------------------------------------------

PROCEDURE Calculate_Freight_Costs(
  p_stop_id       IN     NUMBER
, x_Freight_Costs               OUT NOCOPY  OMInterfaceCostTabType
, x_return_status    OUT NOCOPY  VARCHAR2
)
IS

CURSOR C_Trip_Level_FC
IS
SELECT a.trip_id, a.freight_cost_id, a.unit_amount, a.currency_code,
       c.freight_cost_type_code
       , a.conversion_type_code, a.conversion_rate
FROM wsh_freight_costs a,
     wsh_trip_stops b,
     wsh_freight_cost_types c
WHERE a.trip_id = b.trip_id and
      b.stop_id = p_stop_id and
      c.freight_cost_type_id = a.freight_cost_type_id and
      /* H projects: pricing integration csun
         only line_type_code NULL, PRICE, CHARGE should be
         interfaced to OM
       */
      NVL(a.line_type_code, 'CHARGE') in ('PRICE', 'CHARGE')
      AND    nvl(b.shipments_type_flag,'O') IN ('O','M')
      AND a.unit_amount   IS NOT NULL  -- bug 5447870: skip NULL records
      AND a.currency_code IS NOT NULL;

temp_trip_fc_rec C_Trip_Level_FC%ROWTYPE;


CURSOR C_Stop_Level_FC
IS
SELECT a.stop_id, a.freight_cost_id, a.unit_amount, a.currency_code,
       b.freight_cost_type_code
       , a.conversion_type_code, a.conversion_rate
FROM wsh_freight_costs a,
     wsh_freight_cost_types b
WHERE a.stop_id = p_stop_id and
      a.freight_cost_type_id = b.freight_cost_type_id and
      /* H projects: pricing integration csun
         only line_type_code NULL, PRICE, CHARGE should be
         interfaced to OM
       */
      NVL(a.line_type_code, 'CHARGE') in ('PRICE', 'CHARGE')
      AND a.unit_amount   IS NOT NULL  -- bug 5447870: skip NULL records
      AND a.currency_code IS NOT NULL;

temp_stop_fc_rec C_Stop_Level_FC%ROWTYPE;


CURSOR C_Delivery_Level_FC
IS
SELECT  wnd.delivery_id, wfc.freight_cost_id,
        wfc.unit_amount, wfc.currency_code,
        wft.freight_cost_type_code
        , wfc.conversion_type_code, wfc.conversion_rate
FROM    wsh_freight_costs wfc,
        wsh_freight_cost_types wft,
        wsh_delivery_legs wdl,
        wsh_new_deliveries wnd,
        wsh_trip_stops wts
WHERE   wts.stop_id = p_stop_id and
        wts.stop_id = wdl.pick_up_stop_id and
        wts.stop_location_id = wnd.initial_pickup_location_id and
        wdl.delivery_id = wnd.delivery_id and
        wfc.delivery_id = wdl.delivery_id and
        wfc.freight_cost_type_id = wft.freight_cost_type_id and
        /* H projects: pricing integration csun
           pricing engine calculated freight costs are always at delivery detail level,
           however those lines also have delivery id populated, so those lines should be
           excluded from delivery level FC calculation
         */
        NVL(wfc.line_type_code, 'CHARGE') in ('PRICE', 'CHARGE') and
        NVL(wfc.charge_source_code, 'MANUAL')= 'MANUAL' and
        nvl(wnd.shipment_direction,'O') IN ('O','IO')
        AND wfc.unit_amount   IS NOT NULL  -- bug 5447870: skip NULL records
        AND wfc.currency_code IS NOT NULL
        order by wnd.delivery_id;

temp_Delivery_fc_rec C_Delivery_Level_FC%ROWTYPE;

CURSOR C_Container_Level_FC
IS
SELECT   distinct
        wfc.delivery_detail_id,
        wfc.freight_cost_id,
        wfc.unit_amount,
        wfc.currency_code,
        wft.freight_cost_type_code,
        wfc.conversion_type_code,
        wfc.conversion_rate
FROM  wsh_delivery_assignments_v wda,
   wsh_delivery_details wdd,
   wsh_freight_costs wfc,
   wsh_freight_cost_types wft,
   wsh_delivery_legs wdl,
   wsh_new_deliveries wnd,
   wsh_trip_stops wts
WHERE wts.stop_id = wdl.pick_up_stop_id and
        wts.stop_id = p_stop_id and
   wts.stop_location_id = wnd.initial_pickup_location_id and
        wdl.delivery_id = wnd.delivery_id and
   wda.delivery_id = wdl.delivery_id and
   wda.delivery_id IS NOT NULL and
   wda.parent_delivery_detail_id = wdd.delivery_detail_id and
   wdd.container_flag = 'Y' and
   wdd.source_code='WSH' and
   wfc.delivery_detail_id = wdd.delivery_detail_id  and
        wfc.freight_cost_type_id = wft.freight_cost_type_id and
        NVL(wfc.line_type_code, 'CHARGE') in ('PRICE' ,'CHARGE','TLPRICE','TLCHARGE') and
   nvl(wdd.line_direction,'O') IN ('O','IO')
   AND wfc.unit_amount   IS NOT NULL  -- bug 5447870: skip NULL records
   AND wfc.currency_code IS NOT NULL;


temp_container_fc_rec C_Container_Level_FC%ROWTYPE;

CURSOR C_Detail_Level_FC
IS
SELECT
   wfc.delivery_detail_id,
   wfc.freight_cost_id,
   wfc.unit_amount,
   wfc.currency_code,
   wft.freight_cost_type_code
   , wfc.conversion_type_code, wfc.conversion_rate
FROM  wsh_delivery_assignments_v wda,
   wsh_delivery_details wdd,
   oe_order_lines_all ol,
   wsh_freight_costs wfc,
   wsh_freight_cost_types wft,
   wsh_delivery_legs wdl,
   wsh_new_deliveries wnd,
   wsh_trip_stops wts
WHERE wts.stop_id = wdl.pick_up_stop_id and
        wts.stop_id = p_stop_id and
   wts.stop_location_id = wnd.initial_pickup_location_id and
        wdl.delivery_id = wnd.delivery_id and
   wda.delivery_id = wdl.delivery_id and
   wda.delivery_id IS NOT NULL and
   wda.delivery_detail_id = wdd.delivery_detail_id and
   wdd.container_flag = 'N' and
   ol.line_id = wdd.source_line_id and
   wdd.source_code = 'OE' and
   wfc.delivery_detail_id = wdd.delivery_detail_id  and
        wfc.freight_cost_type_id = wft.freight_cost_type_id and
   wdd.container_flag = 'N' and
        wdd.oe_interfaced_flag = 'N' and
        wdd.released_status = 'C' and
        NVL(wdd.shipped_quantity, 0) > 0 and
        NVL(wfc.line_type_code, 'CHARGE') in ('PRICE' ,'CHARGE','TLPRICE','TLCHARGE') --TKT
   AND wfc.unit_amount   IS NOT NULL  -- bug 5447870: skip NULL records
   AND wfc.currency_code IS NOT NULL;


temp_detail_fc_rec C_Detail_Level_FC%ROWTYPE;

l_prorated_freight_cost       ProratedCostTabType;
l_return_status               VARCHAR2(5);
l_Relevant_Info_Tab           RelavantInfoTabType;
l_already_got_info            VARCHAR2(1) := 'F';
l_got_container_info          VARCHAR2(1) := 'F';
i                             NUMBER := 0;
l_old_delivery_id             NUMBER DEFAULT NULL;
l_all_deliveries_calculated   VARCHAR2(1) := 'F';

WSH_TRIP_FC_ERROR       EXCEPTION;
WSH_STOP_FC_ERROR       EXCEPTION;
WSH_DELIVERY_FC_ERROR   EXCEPTION;
WSH_DETAIL_FC_ERROR     EXCEPTION;
WSH_CONTAINER_FC_ERROR  EXCEPTION;
WSH_FC_GET_INFO_ERR     EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CALCULATE_FREIGHT_COSTS';
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
       WSH_DEBUG_SV.log(l_module_name,'P_STOP_ID',P_STOP_ID);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name, 'BEGINNING OF CALCULATE_FREIGHT_COST , STOP_ID:'|| P_STOP_ID );

   END IF;
   --
   OPEN C_Trip_Level_FC;
   <<Trip_Loop>>
   LOOP
      FETCH C_Trip_Level_FC INTO temp_trip_fc_rec;
      EXIT Trip_Loop WHEN C_Trip_Level_FC%NOTFOUND;
      IF l_already_got_info = 'F' THEN
         Get_Relevant_Info(
            p_level=> 'TRIP',
            p_trip_id => temp_trip_fc_rec.trip_id,
            x_Relevant_Info_Tab  => l_Relevant_Info_Tab,
            x_return_status => l_return_status );
         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            RAISE WSH_FC_GET_INFO_ERR;
         END IF;
         l_already_got_info := 'T';
      END IF;

      Calculate_Trip_Level_Cost(
         p_trip_id => temp_trip_fc_rec.trip_id,
         p_stop_id => p_stop_id,
         p_Freight_Cost_Type_Code => temp_trip_fc_rec.freight_cost_type_code,
         p_freight_cost_id => temp_trip_fc_rec.freight_cost_id,
         p_freight_cost_amount => temp_trip_fc_rec.unit_amount,
         p_from_currency_code => temp_trip_fc_rec.currency_code,
         p_conversion_type_code => temp_trip_fc_rec.conversion_type_code,
         p_conversion_rate => temp_trip_fc_rec.conversion_rate,
         p_Relevant_Info_Tab  => l_Relevant_Info_Tab,
         x_Prorated_Freight_Cost => l_prorated_freight_cost,
         x_return_status => l_return_status);
         -- check the status
      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         RAISE WSH_TRIP_FC_ERROR;
      END IF;
   END LOOP Trip_Loop;
   CLOSE C_Trip_Level_FC;

   -- calculate stop level freight cost
   OPEN C_Stop_Level_FC;
   <<Stop_Loop>>
   LOOP
      FETCH C_Stop_Level_FC INTO temp_stop_fc_rec;
      EXIT Stop_Loop WHEN C_Stop_Level_FC%NOTFOUND;
      IF l_already_got_info = 'F' THEN
          Get_Relevant_Info(
          p_level=> 'STOP',
          p_stop_id => temp_stop_fc_rec.stop_id,
          x_Relevant_Info_Tab => l_Relevant_Info_Tab,
          x_return_status => l_return_status );
          IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            RAISE WSH_FC_GET_INFO_ERR;
          END IF;
          l_already_got_info := 'T';
      END IF;

      Calculate_Stop_Level_Cost(
         p_stop_id => temp_stop_fc_rec.stop_id,
         p_Freight_Cost_Type_Code   => temp_stop_fc_rec.freight_cost_type_code,
         p_freight_cost_id => temp_stop_fc_rec.freight_cost_id,
         p_freight_cost_amount =>   temp_stop_fc_rec.unit_amount,
         p_from_currency_code => temp_stop_fc_rec.currency_code,
         p_conversion_type_code => temp_stop_fc_rec.conversion_type_code,
         p_conversion_rate => temp_stop_fc_rec.conversion_rate,
         p_Relevant_Info_Tab  => l_Relevant_Info_Tab,
         x_Prorated_freight_cost => l_prorated_freight_cost,
         x_return_status => l_return_status);
      -- check the status
      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         RAISE WSH_STOP_FC_ERROR;
      END IF;
   END LOOP Stop_Loop;
   CLOSE C_Stop_Level_FC;

   l_all_deliveries_calculated :=  l_already_got_info ;
   -- Calculate Delivery level freight cost
   OPEN C_Delivery_Level_FC;
   <<Delivery_Loop>>
   LOOP
      FETCH C_Delivery_Level_FC INTO temp_Delivery_fc_rec;
      EXIT Delivery_Loop WHEN C_Delivery_Level_FC%NOTFOUND;

      IF l_all_deliveries_calculated = 'F' THEN
         IF l_old_delivery_id = temp_Delivery_fc_rec.delivery_id THEN
            l_already_got_info := 'T';
         ELSE
            l_old_delivery_id := temp_Delivery_fc_rec.delivery_id;
            l_already_got_info := 'F';
         END IF;
      END IF;
      IF l_already_got_info = 'F' THEN
         Get_Relevant_Info(
          p_level=> 'DELIVERY',
          p_delivery_id => temp_Delivery_fc_rec.delivery_id,
          x_Relevant_Info_Tab => l_Relevant_Info_Tab,
          x_return_status => l_return_status );
          IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            RAISE WSH_FC_GET_INFO_ERR;
          END IF;
          l_already_got_info := 'T';
      END IF;

      Calculate_Delivery_Level_Cost(
         p_delivery_id => temp_Delivery_fc_rec.delivery_id,
         p_Freight_Cost_Type_Code   => temp_Delivery_fc_rec.freight_cost_type_code,
         p_Freight_Cost_Id => temp_Delivery_fc_rec.freight_cost_id,
         p_Freight_Cost_Amount => temp_Delivery_fc_rec.unit_amount,
         p_From_Currency_Code => temp_Delivery_fc_rec.currency_code,
         p_conversion_type_code => temp_Delivery_fc_rec.conversion_type_code,
         p_conversion_rate => temp_Delivery_fc_rec.conversion_rate,
         p_Relevant_Info_Tab => l_Relevant_Info_Tab,
         x_Prorated_Freight_Cost => l_prorated_freight_cost,
         x_return_status => l_return_status);
      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         RAISE WSH_DELIVERY_FC_ERROR;
      END IF;
   END LOOP Delivery_Loop;
   CLOSE C_Delivery_Level_FC;

   OPEN C_Container_Level_FC;
   <<Container_FC_Loop>>
   LOOP
      l_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      FETCH C_Container_Level_FC INTO temp_container_fc_rec;
      EXIT Container_FC_Loop WHEN C_Container_Level_FC%NOTFOUND;
      l_got_container_info := 'F';
      FOR i in 1 .. l_Relevant_Info_Tab.count LOOP
         IF l_Relevant_Info_Tab(i).container_id = temp_container_fc_rec.delivery_detail_id THEN
            l_got_container_info := 'T';
            exit;
         END IF;
      END LOOP;
      IF l_got_container_info = 'F' THEN
         g_container_relationship.delete;
         Get_Relevant_Info(
             p_level=> 'CONTAINER',
             p_container_id => temp_container_fc_rec.delivery_detail_id ,
             x_Relevant_Info_Tab => l_Relevant_Info_Tab,
             x_return_status => l_return_status );
          IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            RAISE WSH_FC_GET_INFO_ERR;
          END IF;
      END IF;

      Calculate_Container_Level_Cost(
            p_container_id=>temp_container_fc_rec.delivery_detail_id,
            p_Freight_Cost_Type_Code   => temp_container_fc_rec.freight_cost_type_code,
            p_freight_cost_id=>temp_container_fc_rec.freight_cost_id,
            p_freight_cost_amount=>temp_container_fc_rec.unit_amount,
            p_from_currency_code=>temp_container_fc_rec.currency_code,
            p_conversion_type_code => temp_container_fc_rec.conversion_type_code,
            p_conversion_rate      => temp_container_fc_rec.conversion_rate,
            p_relevant_info_tab=>l_Relevant_Info_Tab,
            x_prorated_freight_cost=>l_prorated_freight_cost,
            x_return_status=>l_return_status);
      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         RAISE WSH_CONTAINER_FC_ERROR;
      END IF;

   END LOOP Container_FC_LOOP;
   CLOSE C_Container_Level_FC;

   -- Calculate Delivery detail level
   OPEN C_detail_level_fc;
   <<Detail_Loop>>
   LOOP
      l_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      FETCH C_detail_level_fc INTO temp_detail_fc_rec;
      EXIT Detail_Loop WHEN C_detail_level_fc%NOTFOUND;

      Calculate_Detail_Level_Cost(
         p_delivery_detail_id=>temp_detail_fc_rec.delivery_detail_id,
         p_Freight_Cost_Type_Code   => temp_detail_fc_rec.freight_cost_type_code,
         p_freight_cost_id=>temp_detail_fc_rec.freight_cost_id,
         p_freight_cost_amount=>temp_detail_fc_rec.unit_amount,
         p_from_currency_code=>temp_detail_fc_rec.currency_code,
         p_conversion_type_code => temp_detail_fc_rec.conversion_type_code,
         p_conversion_rate => temp_detail_fc_rec.conversion_rate,
         p_relevant_info_tab=>l_Relevant_Info_Tab,
         x_prorated_freight_cost=>l_prorated_freight_cost,
         x_return_status=>l_return_status);
      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         RAISE WSH_DETAIL_FC_ERROR;
      END IF;
   END LOOP Detail_Loop;
   CLOSE C_detail_level_fc;

   l_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   Source_Line_Level_Cost(
      p_stop_id                  =>       p_stop_id,
      p_prorated_freight_cost    =>       l_prorated_freight_cost,
      x_final_cost               =>       x_freight_costs,
      x_return_status            =>       l_return_status
      );
   IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'SOURCE_LINE_LEVEL_COST API FAILED' );
      END IF;
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   END IF;

   IF x_freight_costs.COUNT = 0 THEN
      -- this indicates there is not freight cost for this stop
      -- process_freight_cost will check this field the second time
      -- process_freight_cost is called for the same stop, if it sees
      -- x_freight_costs(1).freight_cost_id = -9999, it returns immediately
      x_freight_costs(1).freight_cost_id := -9999;
   END IF;

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name, 'END OF CALCULATE_FREIGHT_COST' );
     WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION

   WHEN WSH_TRIP_FC_ERROR THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,  'CALCULATE_TRIP_LEVEL_COST FAILED'  );
      END IF;
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_TRIP_FC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_TRIP_FC_ERROR');
END IF;
--
   WHEN WSH_STOP_FC_ERROR THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,  'CALCULATE_STOP_LEVEL_COST FAILED'  );
      END IF;
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_STOP_FC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_STOP_FC_ERROR');
END IF;
--
   WHEN WSH_DELIVERY_FC_ERROR THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,  'CALCULATE_DELIVERY_LEVEL_COST FAILED'  );
      END IF;
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_DELIVERY_FC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_DELIVERY_FC_ERROR');
END IF;
--
   WHEN WSH_CONTAINER_FC_ERROR THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,  'CALCULATE_CONTAINER_LEVEL_COST FAILED'  );
      END IF;
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_CONTAINER_FC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_CONTAINER_FC_ERROR');
END IF;
--
   WHEN WSH_DETAIL_FC_ERROR THEN
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,  'CALCULATE_DETAIL_LEVEL_COST FAILED'  );
         END IF;
         --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_DETAIL_FC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_DETAIL_FC_ERROR');
END IF;
--
   WHEN WSH_FC_GET_INFO_ERR THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,  'GET RELEVANT INFO FAILED'  );
      END IF;
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_FC_GET_INFO_ERR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_FC_GET_INFO_ERR');
END IF;
--
   WHEN others THEN
         WSH_UTIL_CORE.Default_Handler('WSH_FC_INTERFACE.Calculate_Freight_Costs');
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Calculate_Freight_Costs;

--HVOP heali
PROCEDURE Process_Freight_Costs(
  p_stop_id             IN     NUMBER
, p_start_index         IN     NUMBER
, p_line_id_tbl         IN     OE_WSH_BULK_GRP.T_NUM
, x_freight_costs_all   IN OUT NOCOPY  OMInterfaceCostTabType
, x_freight_costs       IN OUT NOCOPY  OE_Ship_Confirmation_Pub.Ship_Adj_Rec_Type
, x_end_index       	OUT NOCOPY  NUMBER
, x_return_status       OUT NOCOPY  VARCHAR2
) IS
i                                   NUMBER;
j                                   NUMBER;
l_return_status                     VARCHAR2(30);
l_table_id                          NUMBER;
l_delivery_id                       NUMBER;
l_stop_id                           NUMBER;
l_trip_id                           NUMBER;

Calculate_failed                    EXCEPTION;
l_line_index                        NUMBER;

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PROCESS_FREIGHT_COSTS';

BEGIN
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       WSH_DEBUG_SV.log(l_module_name,'P_STOP_ID',P_STOP_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_start_index',p_start_index);
       WSH_DEBUG_SV.log(l_module_name,'P_LINE_ID_TBL.count',P_LINE_ID_TBL.count);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


   IF x_Freight_Costs_ALL.count = 0 THEN
      Calculate_Freight_Costs(
         p_stop_id      =>       p_stop_id,
         x_freight_costs      =>       x_Freight_Costs_ALL,
         x_return_status      =>       l_return_status
         );
      IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
         RAISE Calculate_failed;
      END IF;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'X_FREIGHT_COSTS_ALL.COUNT = '|| X_FREIGHT_COSTS_ALL.COUNT );
      END IF;
   ELSE
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'SKIP CALCULATE_FREIGHT_COSTS' );
      END IF;
   END IF;


   IF x_Freight_Costs_ALL(1).freight_cost_id <> -9999 THEN
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'NUMBER OF ELEMENTS IN P_LINE_ID_TBL IS : ' || P_LINE_ID_TBL.COUNT );
      END IF;

      <<Prorate_Loop>>
      FOR i IN 1 .. x_Freight_Costs_All.Count LOOP
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'I = '||I );
         END IF;

         l_line_index := -9999;

         -- assign line index to corresponding cost record
         <<Line_Index_Loop>>
         FOR l_line_counter IN p_start_index .. p_line_id_tbl.COUNT
         LOOP
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'P_LINE_ID.TBL('||L_LINE_COUNTER||'):'||P_LINE_ID_TBL(L_LINE_COUNTER));
            END IF;

            --HVOP heali

            IF (x_Freight_Costs_ALL(i).source_line_id = p_line_id_tbl(l_line_counter))THEN
               l_table_id := x_freight_costs.line_id.count + 1;
               l_line_index := l_line_counter;
               EXIT Line_Index_Loop;
            END IF;
         END LOOP Line_Index_Loop;

         IF (l_line_index = -9999) THEN
           GOTO Next_Cost_Record;
         END IF;

         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'SOURCE LINE ID = '||X_FREIGHT_COSTS_ALL(I).SOURCE_LINE_ID );
           WSH_DEBUG_SV.log(l_module_name, 'l_table_id',l_table_id);
         END IF;

         x_freight_costs.cost_id.extend;
         x_freight_costs.cost_id(l_table_id) := x_Freight_Costs_ALL(i).freight_cost_id;
         x_freight_costs.automatic_flag.extend;
         x_freight_costs.automatic_flag(l_table_id) := 'N';
         x_freight_costs.list_line_type_code.extend;
         x_freight_costs.list_line_type_code(l_table_id) := 'COST';
         x_freight_costs.charge_type_code.extend;
         x_freight_costs.charge_type_code(l_table_id) := x_Freight_Costs_ALL(i).freight_cost_type_code;
         x_freight_costs.header_id.extend;
         x_freight_costs.header_id(l_table_id) := x_Freight_Costs_ALL(i).source_header_id;
         x_freight_costs.line_id.extend;
         x_freight_costs.line_id(l_table_id) := x_Freight_Costs_ALL(i).source_line_id;
         x_freight_costs.adjusted_amount.extend;
         x_freight_costs.adjusted_amount(l_table_id) := x_Freight_Costs_ALL(i).amount;
         x_freight_costs.arithmetic_operator.extend;
         x_freight_costs.arithmetic_operator(l_table_id) := 'AMT';
         x_freight_costs.operation.extend;
         x_freight_costs.operation(l_table_id) := OE_GLOBALS.G_OPR_CREATE;


        IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'cost_id',x_freight_costs.cost_id(l_table_id));
         WSH_DEBUG_SV.log(l_module_name,'automatic_flag',x_freight_costs.automatic_flag(l_table_id));
         WSH_DEBUG_SV.log(l_module_name,'list_line_type_code',x_freight_costs.list_line_type_code(l_table_id));
         WSH_DEBUG_SV.log(l_module_name,'charge_type_code',x_freight_costs.charge_type_code(l_table_id));
         WSH_DEBUG_SV.log(l_module_name,'header_id',x_freight_costs.header_id(l_table_id));
         WSH_DEBUG_SV.log(l_module_name,'line_id',x_freight_costs.line_id(l_table_id));
         WSH_DEBUG_SV.log(l_module_name,'adjusted_amount',x_freight_costs.adjusted_amount(l_table_id));
         WSH_DEBUG_SV.log(l_module_name,'arithmetic_operator',x_freight_costs.arithmetic_operator(l_table_id));
         WSH_DEBUG_SV.log(l_module_name,'operation',x_freight_costs.operation(l_table_id));
        END IF;


        <<Next_Cost_Record>>
        NULL;
      END LOOP Prorate_Loop;
   END IF;



   IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
   END IF;
EXCEPTION
   WHEN Calculate_failed THEN
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,  'CALCULATE_FREIGHT_COST API FAILED'  );
         END IF;
        --
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'CALCULATE_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
             WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:CALCULATE_FAILED');
         END IF;

   WHEN others THEN
         WSH_UTIL_CORE.Default_Handler('WSH_FC_INTERFACE.Process_Freight_Costs');
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
             WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
END Process_Freight_Costs;


FUNCTION Prorate_Freight_Charge(
  p_delivery_detail_id                            IN     NUMBER
, p_charge_id                                     IN     NUMBER
)
RETURN NUMBER
IS

CURSOR C_Details_Assigned(p_source_line_id NUMBER)
IS
SELECT delivery_detail_id
FROM wsh_delivery_details
WHERE source_line_id = p_source_line_id
   AND source_code = 'OE'
   AND container_flag = 'N';

l_number_details_assigned                        NUMBER := 0;
l_line_id                                        NUMBER;
l_charge_line_id                                 NUMBER;
l_detail_id                                      NUMBER;
l_amount                                         NUMBER;
l_uom                                            VARCHAR2(3);
l_unit                                           NUMBER;
l_unit_in_st_uom                                 NUMBER;
l_standard_uom                                   VARCHAR2(3);
l_total_units                                    NUMBER := 0;
l_distributed_charge                             NUMBER := 0;
l_check                                          NUMBER := 0;
l_round_distributed_charge                       NUMBER := 0;
l_currency_code                                  VARCHAR2(15);
l_rest_amount                                    NUMBER;
l_temp_table_id                                  NUMBER;
Input_Inconsistent                               EXCEPTION;
l_return_status                                  VARCHAR2(10);
l_inventory_item_id                              NUMBER;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PRORATE_FREIGHT_CHARGE';
--
BEGIN
   -- User delivery detail to find source line id instead of selecting from
   -- oe_charge_lines_v because each source_line_id could have multiple charges
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
       WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_DETAIL_ID',P_DELIVERY_DETAIL_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_CHARGE_ID',P_CHARGE_ID);
   END IF;
   --
   SELECT wsh.source_line_id
   INTO l_line_id
   FROM wsh_delivery_details wsh, oe_order_lines_all l
   WHERE wsh.delivery_detail_id = p_delivery_detail_id AND
         wsh.source_line_id = l.line_id and
         wsh.source_code = 'OE';

   SELECT COUNT(*)
   INTO l_check
   FROM oe_charge_lines_v
   WHERE line_id = l_line_id AND charge_id = p_charge_id;

   IF (l_check = 0) THEN
      RAISE Input_Inconsistent;
   END IF;

   -- first, get the number of delivery details associated with this source_line_id
   SELECT COUNT(*)
   INTO l_number_details_assigned
   FROM wsh_delivery_details
   WHERE source_line_id = l_line_id and
         source_code = 'OE';

   -- Fetch uom of the first detail as standard uom
   OPEN C_Details_Assigned(l_line_id);
   FETCH C_Details_Assigned INTO l_detail_id;
   CLOSE C_Details_Assigned;

   SELECT requested_quantity_uom
   INTO l_standard_uom
   FROM wsh_delivery_details
   WHERE delivery_detail_id = l_detail_id;

   OPEN C_Details_Assigned(l_line_id);
   LOOP
      FETCH C_Details_Assigned INTO l_detail_id;
              EXIT WHEN C_Details_Assigned%NOTFOUND;

      SELECT shipped_quantity, requested_quantity_uom, inventory_item_id
      INTO l_unit, l_uom , l_inventory_item_id
      FROM wsh_delivery_details
      WHERE delivery_detail_id = l_detail_id;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      -- 3935583
      l_unit_in_st_uom := WSH_WV_UTILS.convert_uom(
        from_uom =>  l_uom,
        to_uom   =>  l_standard_uom,
        quantity =>  l_unit,
        item_id  =>  l_inventory_item_id);
      l_total_units := l_total_units + l_unit_in_st_uom;
   END LOOP;

   CLOSE C_Details_Assigned;

   SELECT charge_amount, currency_code
   INTO l_amount, l_currency_code
   FROM oe_charge_lines_v
   WHERE charge_id = p_charge_id;

   SELECT shipped_quantity, requested_quantity_uom , inventory_item_id
   INTO l_unit, l_uom , l_inventory_item_id
   FROM wsh_delivery_details
   WHERE delivery_detail_id = p_delivery_detail_id;

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   -- 3935583
   l_unit_in_st_uom := WSH_WV_UTILS.convert_uom(
      from_uom =>  l_uom,
      to_uom   =>  l_standard_uom,
      quantity =>  l_unit,
      item_id  =>  l_inventory_item_id);

   l_distributed_charge := l_amount * (l_unit_in_st_uom/l_total_units);
   Round_Cost_Amount(l_distributed_charge, l_Currency_Code, l_round_distributed_charge, l_return_status);

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   RETURN(l_round_distributed_charge);

   EXCEPTION
      WHEN input_inconsistent THEN
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'INPUT_INCONSISTENT exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INPUT_INCONSISTENT');
END IF;
--
         RETURN (-9999);
         --WSH_UTIL_CORE.println('The parameter passed in conflict with each other');

END Prorate_Freight_Charge;


-- Name           Get_Cost_Factor
-- Purpose        dummy function
--                      Since TPA does not support deleting obsolete APIs,
--                      this function needs to remain in this package
--                      (bug 1948149).
--
-- TPA Selector   WSH_TPA_SELECTOR_PKG.FreightCostTP
FUNCTION Get_Cost_Factor(
  p_delivery_id                   IN     NUMBER
, p_container_instance_id          IN     NUMBER
, x_return_status                    OUT NOCOPY     VARCHAR2
) RETURN VARCHAR2 IS
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_COST_FACTOR';
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
      WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_INSTANCE_ID',P_CONTAINER_INSTANCE_ID);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  RETURN '';
END Get_Cost_Factor;


END WSH_FC_INTERFACE_PKG;


/
