--------------------------------------------------------
--  DDL for Package Body WSH_FTE_CONSTRAINT_FRAMEWORK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_FTE_CONSTRAINT_FRAMEWORK" as
/* $Header: WSHFCFWB.pls 120.11.12010000.2 2010/01/22 08:57:48 gbhargav ship $ */

-- Global Variables

    G_PKG_NAME CONSTANT VARCHAR2(30) := 'WSH_FTE_CONSTRAINT_FRAMEWORK';

    g_itm_mustuse_cache		item_item_mustuse_tab_type ;
    g_itmloc_mustuse_cache	item_location_mustuse_tab_type;
    g_itm_exclusive_cache	item_exclusive_tab_type;
    g_fac_exclusive_cache	fac_exclusive_tab_type;

    g_customer_mustuse_location		    WSH_UTIL_CORE.id_tab_type;
    g_location_mustuse_location		    WSH_UTIL_CORE.id_tab_type;
    g_org_mustuse_location		        WSH_UTIL_CORE.id_tab_type;
    g_region_mustuse_constraints        WSH_UTIL_CORE.id_tab_type;
    g_region_mustuse_location           WSH_UTIL_CORE.id_tab_type;

    --#REG-ZON
    -- Region Constraint Cache used for iterating purpose.
    g_reg_const_cache           comp_constraint_tab_type;
    g_regloc_loc_cache	        loc_reg_constraint_tab_type;
    --#REG-ZON

    g_unexp_char		VARCHAR2(30) := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    g_unexp_num			NUMBER       := -999999;

    --#REG-ZON
    g_const_not_present		    NUMBER := -9999;
    g_incl_cons_not_present     NUMBER := -1111;
    g_loc_reg_not_validated     NUMBER := -3333;
    l_reg_hash_base             NUMBER := 1;
    l_reg_hash_size             NUMBER := power(2, 25);
     --#REG-ZON

    --Cache size constant
    g_cache_max_size		NUMBER := power(2,31);
    --

    --Cache for retriving Customer/Supplier/Carrier/Organization from locations.
    --g_customer_from_location		WSH_UTIL_CORE.id_tab_type;
    g_customer_from_location            WSH_UTIL_CORE.tbl_varchar;
    g_supplier_from_location		WSH_UTIL_CORE.id_tab_type;
    g_carrier_from_location		WSH_UTIL_CORE.id_tab_type;
    g_loc_from_org			WSH_UTIL_CORE.id_tab_type;
    g_organization_from_location	WSH_UTIL_CORE.tbl_varchar;

    --

    g_get_carrier_failed                EXCEPTION;
    g_get_customer_failed               EXCEPTION;
    g_get_supplier_failed               EXCEPTION;
    g_get_mast_org_failed               EXCEPTION;
    g_get_carrmode_failed               EXCEPTION;
    g_get_vehicletype_failed            EXCEPTION;



    CURSOR c_get_trip_details(c_trip_id IN NUMBER) IS
    SELECT wdd.DELIVERY_DETAIL_ID
      , wdl.DELIVERY_ID
      , 'Y'
      , wdd.CUSTOMER_ID
      , wdd.INVENTORY_ITEM_ID
      , wdd.SHIP_FROM_LOCATION_ID
      , wdd.ORGANIZATION_ID
      , wdd.SHIP_TO_LOCATION_ID
      , wdd.INTMED_SHIP_TO_LOCATION_ID
      , wdd.RELEASED_STATUS
      , wdd.CONTAINER_FLAG
      , wdd.DATE_REQUESTED
      , wdd.DATE_SCHEDULED
      , wdd.SHIP_METHOD_CODE
      , wdd.CARRIER_ID
      , wdd.PARTY_ID
      , nvl(wdd.LINE_DIRECTION,'O')
      , nvl(wdd.SHIPPING_CONTROL,'BUYER')
      , NULL -- AGDUMMY
    FROM wsh_delivery_details wdd,
         wsh_delivery_assignments_v wda,
         wsh_delivery_legs wdl,
         wsh_trip_stops wts1
    WHERE wdd.delivery_detail_id = wda.delivery_detail_id
    AND   nvl(wdd.shipping_control,'BUYER') <> 'SUPPLIER'
    AND   wda.delivery_id = wdl.delivery_id
    AND   wdl.pick_up_stop_id = wts1.stop_id
    AND   wts1.trip_id = c_trip_id;


    CURSOR c_get_trip_details_std(c_trip_id IN NUMBER) IS
    SELECT wdd.DELIVERY_DETAIL_ID
      , wdl.DELIVERY_ID
      , 'Y'
      , wdd.CUSTOMER_ID
      , wdd.INVENTORY_ITEM_ID
      , wdd.SHIP_FROM_LOCATION_ID
      , wdd.ORGANIZATION_ID
      , wdd.SHIP_TO_LOCATION_ID
      , wdd.INTMED_SHIP_TO_LOCATION_ID
      , wdd.RELEASED_STATUS
      , wdd.CONTAINER_FLAG
      , wdd.DATE_REQUESTED
      , wdd.DATE_SCHEDULED
      , wdd.SHIP_METHOD_CODE
      , wdd.CARRIER_ID
      , wdd.PARTY_ID
      , nvl(wdd.LINE_DIRECTION,'O')
      , nvl(wdd.SHIPPING_CONTROL,'BUYER')
      , NULL -- AGDUMMY
    FROM wsh_delivery_details wdd,
         wsh_delivery_assignments_v wda,
         wsh_delivery_legs wdl,
         wsh_trip_stops wts1,
         wsh_new_deliveries wnd
    WHERE wdd.delivery_detail_id = wda.delivery_detail_id
    AND   nvl(wdd.shipping_control,'BUYER') <> 'SUPPLIER'
    AND   wda.delivery_id = wdl.delivery_id
    AND   wdl.pick_up_stop_id = wts1.stop_id
    AND   wts1.trip_id = c_trip_id
    AND   wnd.delivery_id = wdl.delivery_id
    AND   wnd.delivery_type = 'STANDARD';

    CURSOR c_get_trip_details_consol(c_trip_id IN NUMBER) IS
    SELECT wdd.DELIVERY_DETAIL_ID
      , wdl1.DELIVERY_ID
      , 'Y'
      , wdd.CUSTOMER_ID
      , wdd.INVENTORY_ITEM_ID
      , wdd.SHIP_FROM_LOCATION_ID
      , wdd.ORGANIZATION_ID
      , wdd.SHIP_TO_LOCATION_ID
      , wdd.INTMED_SHIP_TO_LOCATION_ID
      , wdd.RELEASED_STATUS
      , wdd.CONTAINER_FLAG
      , wdd.DATE_REQUESTED
      , wdd.DATE_SCHEDULED
      , wdd.SHIP_METHOD_CODE
      , wdd.CARRIER_ID
      , wdd.PARTY_ID
      , nvl(wdd.LINE_DIRECTION,'O')
      , nvl(wdd.SHIPPING_CONTROL,'BUYER')
      , NULL -- AGDUMMY
    FROM wsh_delivery_details wdd,
         wsh_delivery_assignments_v wda,
         wsh_trip_stops wts1,
         wsh_delivery_legs wdl1,
         wsh_delivery_legs wdl2,
         wsh_new_deliveries wnd
    WHERE wdd.delivery_detail_id = wda.delivery_detail_id
    AND   nvl(wdd.shipping_control,'BUYER') <> 'SUPPLIER'
    AND   wda.delivery_id = wdl1.delivery_id
    AND   wdl1.parent_delivery_leg_id = wdl2.delivery_leg_id
    AND   wdl2.pick_up_stop_id = wts1.stop_id
    AND   wts1.trip_id = c_trip_id
    AND   wnd.delivery_id = wdl2.delivery_id
    AND   wnd.delivery_type = 'CONSOLIDATION';

    CURSOR c_get_trip_dlvy(c_trip_id IN NUMBER) IS
    SELECT wnd.DELIVERY_ID
      , c_trip_id
      , 'Y'
      , wnd.NAME
      , wnd.PLANNED_FLAG
      , wnd.STATUS_CODE
      , wnd.INITIAL_PICKUP_DATE
      , wnd.INITIAL_PICKUP_LOCATION_ID
      , wnd.ULTIMATE_DROPOFF_LOCATION_ID
      , wnd.ULTIMATE_DROPOFF_DATE
      , wnd.CUSTOMER_ID
      , wnd.INTMED_SHIP_TO_LOCATION_ID
      , wnd.SHIP_METHOD_CODE
      , wnd.DELIVERY_TYPE
      , wnd.CARRIER_ID
      , wnd.ORGANIZATION_ID
      , wnd.SERVICE_LEVEL
      , wnd.MODE_OF_TRANSPORT
      , wnd.PARTY_ID
      , nvl(wnd.SHIPMENT_DIRECTION,'O')
      , nvl(wnd.SHIPPING_CONTROL,'BUYER')
      , NULL -- AGDUMMY
    FROM wsh_new_deliveries wnd,
         wsh_delivery_legs wdl,
         wsh_trip_stops wts1
    WHERE wnd.delivery_id = wdl.delivery_id
    AND   wdl.pick_up_stop_id = wts1.stop_id
    AND   nvl(wnd.shipping_control,'BUYER') <> 'SUPPLIER'
    AND   wts1.trip_id = c_trip_id;

    CURSOR c_get_trip_stops(c_tripid IN NUMBER) is
    SELECT wts.STOP_ID
      , 'Y' as exists_in_database
      , wts.TRIP_ID
      --To handle dummy locations #DUM_LOC(S)
      , NVL(wts.PHYSICAL_LOCATION_ID,wts.STOP_LOCATION_ID)
      , wts.STATUS_CODE
      , wts.STOP_SEQUENCE_NUMBER
      , wts.PLANNED_ARRIVAL_DATE
      , wts.PLANNED_DEPARTURE_DATE
      , wts.ACTUAL_ARRIVAL_DATE
      , wts.ACTUAL_DEPARTURE_DATE
      --#DUM_LOC(S)
      , wts.PHYSICAL_LOCATION_ID
      --#DUM_LOC(E)
      --#SBAKSHI
      , wts.PHYSICAL_STOP_ID
    FROM wsh_trip_stops wts
    WHERE wts.trip_id = c_tripid
    order by wts.PLANNED_ARRIVAL_DATE;

    CURSOR c_get_dlvy(c_delivery_id IN NUMBER) IS
    SELECT wnd.DELIVERY_ID
      , NULL
      , 'Y'
      , wnd.NAME
      , wnd.PLANNED_FLAG
      , wnd.STATUS_CODE
      , wnd.INITIAL_PICKUP_DATE
      , wnd.INITIAL_PICKUP_LOCATION_ID
      , wnd.ULTIMATE_DROPOFF_LOCATION_ID
      , wnd.ULTIMATE_DROPOFF_DATE
      , wnd.CUSTOMER_ID
      , wnd.INTMED_SHIP_TO_LOCATION_ID
      , wnd.SHIP_METHOD_CODE
      , wnd.DELIVERY_TYPE
      , wnd.CARRIER_ID
      , wnd.ORGANIZATION_ID
      , wnd.SERVICE_LEVEL
      , wnd.MODE_OF_TRANSPORT
      , wnd.PARTY_ID
      , nvl(wnd.SHIPMENT_DIRECTION,'O')
      , nvl(wnd.SHIPPING_CONTROL,'BUYER')
      , NULL  -- AGDUMMY
    FROM wsh_new_deliveries wnd
    WHERE wnd.delivery_id = c_delivery_id;

    CURSOR c_get_details(c_delivery_id IN NUMBER) IS
    SELECT wdd.DELIVERY_DETAIL_ID
      , wda.DELIVERY_ID
      , 'Y'
      , wdd.CUSTOMER_ID
      , wdd.INVENTORY_ITEM_ID
      , wdd.SHIP_FROM_LOCATION_ID
      , wdd.ORGANIZATION_ID
      , wdd.SHIP_TO_LOCATION_ID
      , wdd.INTMED_SHIP_TO_LOCATION_ID
      , wdd.RELEASED_STATUS
      , wdd.CONTAINER_FLAG
      , wdd.DATE_REQUESTED
      , wdd.DATE_SCHEDULED
      , wdd.SHIP_METHOD_CODE
      , wdd.CARRIER_ID
      , wdd.PARTY_ID
      , nvl(wdd.LINE_DIRECTION,'O')
      , nvl(wdd.SHIPPING_CONTROL,'BUYER')
      , NULL --AGDUMMY
    FROM wsh_delivery_details wdd,
         wsh_delivery_assignments_v wda
    WHERE wdd.delivery_detail_id = wda.delivery_detail_id
    AND   nvl(wdd.shipping_control,'BUYER') <> 'SUPPLIER'
    AND   wda.delivery_id = c_delivery_id;


    CURSOR c_get_details_consol(c_delivery_id IN NUMBER) IS
    SELECT wdd.DELIVERY_DETAIL_ID
      , wda.DELIVERY_ID
      , 'Y'
      , wdd.CUSTOMER_ID
      , wdd.INVENTORY_ITEM_ID
      , wdd.SHIP_FROM_LOCATION_ID
      , wdd.ORGANIZATION_ID
      , wdd.SHIP_TO_LOCATION_ID
      , wdd.INTMED_SHIP_TO_LOCATION_ID
      , wdd.RELEASED_STATUS
      , wdd.CONTAINER_FLAG
      , wdd.DATE_REQUESTED
      , wdd.DATE_SCHEDULED
      , wdd.SHIP_METHOD_CODE
      , wdd.CARRIER_ID
      , wdd.PARTY_ID
      , nvl(wdd.LINE_DIRECTION,'O')
      , nvl(wdd.SHIPPING_CONTROL,'BUYER')
      , NULL --AGDUMMY
    FROM wsh_delivery_details wdd,
         wsh_delivery_assignments_v wda,
         wsh_delivery_legs wdl1,
         wsh_delivery_legs wdl2
    WHERE wdd.delivery_detail_id = wda.delivery_detail_id
    AND   nvl(wdd.shipping_control,'BUYER') <> 'SUPPLIER'
    AND   wda.delivery_id = wdl1.delivery_id --c_delivery_id
    AND   wdl1.parent_delivery_leg_id = wdl2.delivery_leg_id
    AND   wdl2.delivery_id = c_delivery_id
    AND   wda.delivery_id is not null;

    CURSOR c_get_stop_location(c_stop_id IN NUMBER) IS
	   --#DUM_LOC(S)
    SELECT nvl(wts.physical_location_id,wts.stop_location_id),
	   --#DUM_LOC(E)
	   wts.stop_sequence_number,wts.planned_arrival_date
    FROM   wsh_trip_stops wts
    WHERE  wts.stop_id = c_stop_id
    order by wts.planned_arrival_date;

    -- AGDUMMY
    -- This cursor might return both the dummy and the physical stop
    CURSOR c_get_stop(c_location_id IN NUMBER,c_trip_id IN NUMBER) IS
    SELECT wts.stop_sequence_number,wts.planned_arrival_date
    FROM   wsh_trip_stops wts
	   --#DUM_LOC(S)
    WHERE  nvl(wts.physical_location_id,wts.stop_location_id) = c_location_id
	   --#DUM_LOC(E)
    AND    wts.trip_id = c_trip_id;


    TYPE entity_info_rec_type IS RECORD
        (entity_info_index                      NUMBER,
         entity_id                              NUMBER,
         entity_type                            VARCHAR2(30));

    TYPE entity_info_tab_type IS TABLE OF entity_info_rec_type INDEX BY BINARY_INTEGER;

    TYPE entity_rec_type IS RECORD (
         entity_id                      NUMBER,
         group_id                       NUMBER,
         ship_method_code               VARCHAR2(30),
         carrier_id                     NUMBER,
         mode_of_transport              VARCHAR2(30),
         organization_id                NUMBER,
         inventory_item_id              NUMBER,
         intmed_ship_to_location_id     NUMBER,
         initial_pickup_location_id     NUMBER,
         ultimate_dropoff_location_id   NUMBER,
         initial_pickup_date     DATE,
         ultimate_dropoff_date   DATE,
         physical_dropoff_location_id   NUMBER, -- AGDUMMY
         customer_id                    NUMBER,
         party_id                       NUMBER,
         shipment_direction             VARCHAR2(30),
         shipping_control               VARCHAR2(30) );

    TYPE entity_tab_type IS TABLE OF entity_rec_type INDEX BY BINARY_INTEGER;

    TYPE item_rec_type IS RECORD (
         line_id                       NUMBER,
         item_id                       NUMBER,
         org_id                        NUMBER );

    TYPE item_tab_type IS TABLE OF item_rec_type INDEX BY BINARY_INTEGER;

    TYPE entity_group_tab_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

    /*TYPE line_constraint_rec_type IS RECORD (
       line_constraint_index                    NUMBER
     , entity_type                              VARCHAR2(30)
     , entity_line_id                           NUMBER
     , constraint_id                            NUMBER
     , constraint_class_code                    VARCHAR2(30)
     , violation_type                           VARCHAR2(1)
     );

    TYPE line_constraint_tab_type IS TABLE OF line_constraint_rec_type INDEX BY BINARY_INTEGER;*/

    TYPE dleg_stops_rec_type IS RECORD (
       delivery_leg_id                          NUMBER
     , sequence_number                          NUMBER
     , pick_up_stop_id                          NUMBER
     , drop_off_stop_id                         NUMBER
     , pick_up_loc_id                           NUMBER
     , drop_off_loc_id                          NUMBER
     , pick_up_loc_pa_date                      DATE
     , drop_off_loc_pa_date                     DATE
     , trip_id                                  NUMBER
     , delivery_id                              NUMBER
     );

-- Utility APIs
--***************************************************************************--

FUNCTION entity_exists(
                 p_entity_id IN NUMBER,
                 p_entity_table IN WSH_UTIL_CORE.id_tab_type,
                 x_found_index  OUT NOCOPY NUMBER) RETURN BOOLEAN
IS

      z          NUMBER := 0;
      FOUND      BOOLEAN:= FALSE;

      l_debug_on          CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
      l_module_name       CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'entity_exists';
BEGIN
    IF l_debug_on THEN
      WSH_DEBUG_SV.push (l_module_name);
      WSH_DEBUG_SV.logmsg(l_module_name,'p_entity_id : '||p_entity_id||' p_entity_table count : '||p_entity_table.COUNT);
    END IF;
    --
      z := p_entity_table.FIRST;
      IF z IS NOT NULL THEN
         LOOP
	        IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,' z : '||z||' p_entity_table(z) : '||p_entity_table(z));
                END IF;

                IF p_entity_table(z) = p_entity_id THEN
                   FOUND := TRUE;
                   x_found_index := z;
	           IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,' exiting as p_entity_id found');
                   END IF;
                   EXIT;
                END IF;

                EXIT WHEN z= p_entity_table.LAST;
                z:= p_entity_table.NEXT(z);

         END LOOP;
      END IF;
      IF FOUND THEN
	    IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,' returning true');
         END IF;
      ELSE
	    IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'returning false');
         END IF;
      END IF;
      IF l_debug_on THEN
        wsh_debug_sv.pop (l_module_name);
      END IF;
      RETURN FOUND;
END entity_exists;


--***************************************************************************--
--========================================================================
-- PROCEDURE :  refresh_cache            PRIVATE
--
-- PARAMETERS: x_return_status           Return Status
-- COMMENT   :
--             Refreshes constraint related database cache s
--             if middletier session (ICX session) is changed
--========================================================================

PROCEDURE refresh_cache (
             x_return_status    OUT  NOCOPY  VARCHAR2 )
IS

    l_session_id        NUMBER  := 0;

    l_debug_on          CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
    l_module_name       CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'refresh_cache';

BEGIN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    --
    IF l_debug_on THEN
      wsh_debug_sv.push (l_module_name);
    END IF;
    --

    l_session_id := icx_sec.g_session_id;

    IF l_debug_on THEN
       wsh_debug_sv.logmsg(l_module_name,'g_comp_class_tab count : '||g_comp_class_tab.COUNT);
       wsh_debug_sv.logmsg(l_module_name,'g_comp_constraint_tab count : '||g_comp_constraint_tab.COUNT);
       wsh_debug_sv.logmsg(l_module_name,'g_session_id : '||g_session_id||' Current session id : '||l_session_id);
    END IF;

    IF g_session_id IS NULL OR l_session_id <> g_session_id THEN
       -- Delete constraint cache
       g_comp_class_tab.DELETE;
       g_comp_constraint_tab.DELETE;
       --Delete Region Constaint Cache.
       g_reg_const_cache.DELETE;
       g_regloc_loc_cache.DELETE;

       g_session_id := l_session_id;

       IF l_debug_on THEN
	   wsh_debug_sv.logmsg(l_module_name,'Constraints Cache cleared');
       END IF;

    END IF;

    --
    IF l_debug_on THEN
      wsh_debug_sv.pop (l_module_name);
    END IF;
    --

EXCEPTION
    WHEN others THEN
      WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.refresh_cache');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END refresh_cache;

--***************************************************************************
--
--========================================================================
-- FUNCTION :  get_compclass_code          PRIVATE
--
-- PARAMETERS: p_comp_class_id             Input compatibility class id
--             x_severity                  Ouput severity setting
-- COMMENT   : This information is cached
-- To retrieve compatibility class code
-- and severity setting for a compatibility class id
--========================================================================

FUNCTION get_compclass_code(
             p_comp_class_id          IN NUMBER,
             x_severity               OUT NOCOPY VARCHAR2) RETURN VARCHAR2
IS

    CURSOR c_get_comp_class_info(c_comp_class_id IN NUMBER) IS
    SELECT *
    FROM   WSH_FTE_COMP_CLASSES
    WHERE  COMPATIBILITY_CLASS_ID = c_comp_class_id;

    l_comp_class_rec   WSH_FTE_COMP_CLASSES%ROWTYPE;
    i                  NUMBER := 0;
    l_result           VARCHAR2(30)  := NULL;
    l_hash_value       NUMBER := 0;

    l_debug_on         CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
    l_module_name      CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'get_compclass_code';

BEGIN
    --
    IF l_debug_on THEN
      wsh_debug_sv.push (l_module_name);
    END IF;
    --

    i:=g_comp_class_tab.FIRST;

    IF i IS NOT NULL THEN
      LOOP
        IF g_comp_class_tab(i).compatibility_class_id = p_comp_class_id THEN
           x_severity := g_comp_class_tab(i).CONSTRAINT_VIOLATION;
           l_result := g_comp_class_tab(i).compatibility_class_code;
           EXIT;
        END IF;

        EXIT WHEN i=g_comp_class_tab.LAST;
        i := g_comp_class_tab.NEXT(i);
      END LOOP;
    END IF;

    IF l_result IS NULL THEN

      OPEN  c_get_comp_class_info(p_comp_class_id);
      FETCH c_get_comp_class_info INTO l_comp_class_rec;
      CLOSE c_get_comp_class_info;

      l_result := l_comp_class_rec.compatibility_class_code;
      x_severity := l_comp_class_rec.CONSTRAINT_VIOLATION;

    END IF;

    --
    IF l_debug_on THEN
      wsh_debug_sv.pop (l_module_name);
    END IF;
    --
    RETURN l_result;

EXCEPTION
    WHEN others THEN
      IF c_get_comp_class_info%ISOPEN THEN
         CLOSE c_get_comp_class_info;
      END IF;
      WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.get_compclass_code');
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
      RETURN g_unexp_char;
END get_compclass_code;

--***************************************************************************--
--
--========================================================================
-- FUNCTION :  get_compclass_id            PRIVATE
--
-- PARAMETERS: p_comp_class_code           Input compatibility clas code
-- COMMENT   : This information is cached
-- To retrieve compatibility class id
-- for a compatibility class code
--========================================================================

FUNCTION get_compclass_id(
             p_comp_class_code          IN VARCHAR2) RETURN NUMBER
IS

    CURSOR c_get_comp_class_info(c_comp_class_code IN VARCHAR2) IS
    SELECT *
    FROM   WSH_FTE_COMP_CLASSES
    WHERE  COMPATIBILITY_CLASS_CODE = c_comp_class_code;

    l_hash_value       NUMBER:=0;
    l_comp_class_rec   WSH_FTE_COMP_CLASSES%ROWTYPE;

    l_debug_on         CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
    l_module_name      CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'get_compclass_id';

BEGIN

    --
    IF l_debug_on THEN
      wsh_debug_sv.push (l_module_name);
    END IF;
    --
    l_hash_value := dbms_utility.get_hash_value(
                                  name => p_comp_class_code,
                                  base => g_hash_base,
                                  hash_size =>g_hash_size );

    IF NOT (g_comp_class_tab.EXISTS(l_hash_value) AND
            g_comp_class_tab(l_hash_value).compatibility_class_code = p_comp_class_code) THEN
       OPEN c_get_comp_class_info(p_comp_class_code);
       FETCH c_get_comp_class_info INTO l_comp_class_rec;
       g_comp_class_tab(l_hash_value) := l_comp_class_rec;
       CLOSE c_get_comp_class_info;
    END IF;
    --
    IF l_debug_on THEN
      wsh_debug_sv.pop (l_module_name);
    END IF;
    --

    RETURN g_comp_class_tab(l_hash_value).compatibility_class_id;

EXCEPTION
    WHEN others THEN
      IF c_get_comp_class_info%ISOPEN THEN
         CLOSE c_get_comp_class_info;
      END IF;
      WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.get_compclass_id');
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
      RETURN g_unexp_num;

END get_compclass_id;

--***************************************************************************--
--========================================================================
-- PROCEDURE : get_constraint_display      Called by constraint Wrapper API
--                                         and FTE constraint UI
--
-- PARAMETERS: p_constraint_id             Constraint id to get information about
--             x_obj1_display              Display name of constraint object1 in input constraint
--             x_obj1_parent_display       Display name of constraint object1 parent
--             x_obj2_display              Display name of constraint object2 in input constraint
--             x_obj2_parent_display       Display name of constraint object2 parent
--             x_condition_display         Display name of constraint type
--                                         (Exclusive / Inclusive) in input constraint
--             x_fac1_company_type         Display name of company type if constraint object1
--                                         is a facility
--             x_fac1_company_name         Display name of company name if constraint object1
--                                         is a facility
--             x_fac2_company_type         Display name of company type if constraint object2
--                                         is a facility
--             x_fac2_company_name         Display name of company name if constraint object2
--                                         is a facility
--             x_comp_class_code           Display meaning of compatibility class code
--                                         for the input constraint
--             x_severity                  Display meaning of severity setting of the
--                                         compatibility class for the input constraint
--             x_return_status             Return status
-- COMMENT   : This procedure is used to perform for following actions
--             Takes as input a constraint id
--             and returns the names of the objects
--             which are associated by this constraint definition
--========================================================================

PROCEDURE get_constraint_display(
             p_constraint_id           IN NUMBER,
             x_obj1_display            OUT NOCOPY      VARCHAR2,
             x_obj1_parent_display     OUT NOCOPY      VARCHAR2,
             x_obj2_display            OUT NOCOPY      VARCHAR2,
             x_obj2_parent_display     OUT NOCOPY      VARCHAR2,
             x_condition_display       OUT NOCOPY      VARCHAR2,
             x_fac1_company_type       OUT NOCOPY      VARCHAR2,
             x_fac1_company_name       OUT NOCOPY      VARCHAR2,
             x_fac2_company_type       OUT NOCOPY      VARCHAR2,
             x_fac2_company_name       OUT NOCOPY      VARCHAR2,
             x_comp_class_code         OUT NOCOPY      VARCHAR2,
             x_severity                OUT NOCOPY      VARCHAR2,
             x_return_status           OUT NOCOPY      VARCHAR2 )
IS

    CURSOR c_get_constraint_info(c_constraint_id IN NUMBER) IS
    SELECT *
    FROM   WSH_FTE_COMP_CONSTRAINTS
    WHERE  COMPATIBILITY_ID = c_constraint_id;

    l_comp_type1       VARCHAR2(3);
    l_comp_type2       VARCHAR2(3);
    l_fac_company_type VARCHAR2(30) := NULL;
    l_fac_company_name VARCHAR2(2000) := NULL;
    l_severity         VARCHAR2(30);
    l_constraint_rec   WSH_FTE_COMP_CONSTRAINTS%ROWTYPE;

    l_debug_on         CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
    l_module_name      CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'get_constraint_display';

BEGIN

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    IF l_debug_on THEN
       wsh_debug_sv.push(l_module_name);
    END IF;

    -- object1_type values : ORG CUS FAC CAR MOD ITM

    OPEN c_get_constraint_info(p_constraint_id);
    FETCH c_get_constraint_info INTO l_constraint_rec;
    CLOSE c_get_constraint_info;

    x_comp_class_code := get_compclass_code(
             p_comp_class_id          => l_constraint_rec.compatibility_class_id,
             x_severity               => x_severity);

    IF x_comp_class_code = g_unexp_char THEN
      IF l_debug_on THEN
         wsh_debug_sv.log(l_module_name,'Unexpected error from get_compclass_code ');
      END IF;
       raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_comp_type1       := SUBSTR(x_comp_class_code,1,3);
    l_comp_type2       := SUBSTR(x_comp_class_code,5,3);

    IF l_constraint_rec.CONSTRAINT_OBJECT1_ID IS NOT NULL THEN

       IF l_debug_on THEN
         wsh_debug_sv.log(l_module_name,'Calling WSH_FTE_INTEGRATION.get_cc_object_name for CONSTRAINT_OBJECT1_ID ');
       END IF;
       x_obj1_display := WSH_FTE_INTEGRATION.get_cc_object_name(
             p_object_type             =>        l_constraint_rec.CONSTRAINT_OBJECT1_TYPE,
             x_fac_company_name        =>        l_fac_company_name,
             x_fac_company_type        =>        l_fac_company_type,
             p_object_parent_id        =>        l_constraint_rec.OBJECT1_SOURCE_ID,
             p_object_value_num        =>        l_constraint_rec.CONSTRAINT_OBJECT1_ID );

    ELSIF l_constraint_rec.CONSTRAINT_OBJECT1_VALUE_CHAR IS NOT NULL THEN

       IF l_debug_on THEN
         wsh_debug_sv.log(l_module_name,'Calling WSH_FTE_INTEGRATION.get_cc_object_name for CONSTRAINT_OBJECT1_VALUE_CHAR ');
       END IF;
       x_obj1_display := WSH_FTE_INTEGRATION.get_cc_object_name(
             p_object_type             =>        l_constraint_rec.CONSTRAINT_OBJECT1_TYPE,
             x_fac_company_name        =>        l_fac_company_name,
             x_fac_company_type        =>        l_fac_company_type,
             p_object_value_char       =>        l_constraint_rec.CONSTRAINT_OBJECT1_VALUE_CHAR);

    END IF;

    IF x_obj1_display = g_unexp_char THEN
      IF l_debug_on THEN
         wsh_debug_sv.log(l_module_name,'Unexpected error from get_cc_object_name ');
      END IF;
       raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    x_fac1_company_type := l_fac_company_type;
    x_fac1_company_name := l_fac_company_name;

    IF l_constraint_rec.CONSTRAINT_OBJECT2_ID IS NOT NULL THEN

       IF l_debug_on THEN
         wsh_debug_sv.log(l_module_name,'Calling WSH_FTE_INTEGRATION.get_cc_object_name for CONSTRAINT_OBJECT2_ID ');
       END IF;
       x_obj2_display := WSH_FTE_INTEGRATION.get_cc_object_name(
             p_object_type             =>        l_constraint_rec.CONSTRAINT_OBJECT2_TYPE,
             x_fac_company_name        =>        l_fac_company_name,
             x_fac_company_type        =>        l_fac_company_type,
             p_object_parent_id        =>        l_constraint_rec.OBJECT2_SOURCE_ID,
             p_object_value_num        =>        l_constraint_rec.CONSTRAINT_OBJECT2_ID );

    ELSIF l_constraint_rec.CONSTRAINT_OBJECT2_VALUE_CHAR IS NOT NULL THEN

       IF l_debug_on THEN
         wsh_debug_sv.log(l_module_name,'Calling WSH_FTE_INTEGRATION.get_cc_object_name for CONSTRAINT_OBJECT2_VALUE_CHAR ');
       END IF;
       x_obj2_display := WSH_FTE_INTEGRATION.get_cc_object_name(
             p_object_type             =>        l_constraint_rec.CONSTRAINT_OBJECT2_TYPE,
             x_fac_company_name        =>        l_fac_company_name,
             x_fac_company_type        =>        l_fac_company_type,
             p_object_value_char       =>        l_constraint_rec.CONSTRAINT_OBJECT2_VALUE_CHAR);

    END IF;

    IF x_obj2_display = g_unexp_char THEN
      IF l_debug_on THEN
         wsh_debug_sv.log(l_module_name,'Unexpected error from get_cc_object_name ');
      END IF;
       raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    x_fac2_company_type := l_fac_company_type;
    x_fac2_company_name := l_fac_company_name; -- Can return vehicle class code in case a constraint has been defined with vehicle type

    IF l_constraint_rec.OBJECT1_SOURCE_ID IS NOT NULL THEN

    -- Patch I : Supports only ORG as parent for Item

       x_obj1_parent_display := WSH_FTE_INTEGRATION.get_cc_object_name(
             p_object_type             =>        'ORG',
             x_fac_company_name        =>        l_fac_company_name,
             x_fac_company_type        =>        l_fac_company_type ,
             p_object_value_num        =>        l_constraint_rec.OBJECT1_SOURCE_ID);

    IF x_obj1_parent_display = g_unexp_char THEN
       raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    END IF;

    IF l_constraint_rec.OBJECT2_SOURCE_ID IS NOT NULL THEN

       x_obj2_parent_display := WSH_FTE_INTEGRATION.get_cc_object_name(
             p_object_type             =>        'ORG',
             x_fac_company_name        =>        l_fac_company_name,
             x_fac_company_type        =>        l_fac_company_type ,
             p_object_value_num        =>        l_constraint_rec.OBJECT2_SOURCE_ID);

    IF x_obj2_parent_display = g_unexp_char THEN
       raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    END IF;

    x_condition_display := WSH_XC_UTIL.Get_Lookup_Meaning(
                p_lookup_code     =>   l_constraint_rec.CONSTRAINT_TYPE,
                p_lookup_type     =>   'WSH_FTE_CONSTRAINT_TYPE'
                );

    IF x_condition_display IS NULL THEN
       raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF l_comp_type1 = 'FAC' AND l_constraint_rec.CONSTRAINT_OBJECT1_TYPE <> 'FAC' THEN
       x_obj1_display := FND_MESSAGE.GET_STRING('FTE','FTE_COMP_ALL_FACILITIES')||' '||x_obj1_display;
    ELSIF l_comp_type2 = 'FAC' AND l_constraint_rec.CONSTRAINT_OBJECT2_TYPE <> 'FAC' THEN
       x_obj2_display := FND_MESSAGE.GET_STRING('FTE','FTE_COMP_ALL_FACILITIES')||' '||x_obj2_display;
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
    WHEN OTHERS THEN
      IF c_get_constraint_info%ISOPEN THEN
         CLOSE c_get_constraint_info;
      END IF;
      WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.get_constraint_display');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END get_constraint_display;


--***************************************************************************--
--========================================================================
-- PROCEDURE : remove_duplicate_const  PRIVATE
--
-- PARAMETERS: p_failed_constraints       Violated Constraints table, may have duplicate entries.
--	       x_failed_constraints	  Violated Constraints table, after removing duplicate entries.
--             x_return_status            Return status
-- COMMENT   : Is used to remove duplicate constraints.
--========================================================================
PROCEDURE remove_duplicate_const(
	p_failed_constraints	IN  OUT  NOCOPY line_constraint_tab_type,
	x_return_status		OUT NOCOPY VARCHAR2)
IS
	i			NUMBER;
	j			NUMBER;
	k			NUMBER;
	l_del_flag		BOOLEAN;

	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' ||'remove_duplicate_const';
	l_debug_on    CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;

BEGIN

 x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

 IF l_debug_on THEN
       wsh_debug_sv.push(l_module_name);
       wsh_debug_sv.logmsg(l_module_name,'No. of constraints:'||p_failed_constraints.COUNT);
 END IF;

 i:= p_failed_constraints.FIRST;

 IF i IS NOT NULL THEN
 LOOP

   j := p_failed_constraints.NEXT(i);

   l_del_flag := FALSE;
   IF j IS NOT NULL THEN
     LOOP

	IF (p_failed_constraints(i).constraint_id=p_failed_constraints(j).constraint_id) THEN
	    k := j;
	    l_del_flag := TRUE;
	    IF l_debug_on THEN
	       wsh_debug_sv.logmsg (l_module_name,'Constraint '||p_failed_constraints(i).constraint_id ||' appears more than once');
	    END IF;
	END IF;

	EXIT WHEN j = p_failed_constraints.LAST;

	j := p_failed_constraints.NEXT(j);

	IF (l_del_flag) THEN
	   p_failed_constraints.DELETE(k);
	   l_del_flag := FALSE;
	END IF;

     END LOOP;

     -- If element is present at last position,We need to delete outside the loop.
     IF (l_del_flag) THEN
	p_failed_constraints.DELETE(k);
        l_del_flag := FALSE;
     END IF;
   END IF;

   EXIT WHEN i = p_failed_constraints.LAST;
   i := p_failed_constraints.NEXT(i);

 END LOOP;
 END IF;

 IF l_debug_on THEN
    wsh_debug_sv.logmsg(l_module_name,'No. of constraints after deleting duplicate constraints:'||to_char(p_failed_constraints.COUNT));
    WSH_DEBUG_SV.pop(l_module_name);
 END IF;

EXCEPTION
WHEN others THEN
   WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.remove_duplicate_const');
   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
   END IF;
    --
END remove_duplicate_const;


--***************************************************************************--
--========================================================================
-- PROCEDURE : get_carrier_from_loc       PRIVATE
--
-- PARAMETERS: p_location_id              Input Location id
--             x_carrier_id               Carrier at the input location
--             x_return_status            Return status
-- COMMENT   :
-- Returns the carrier id of the carrier
-- having a location at input wsh location id
--========================================================================
PROCEDURE get_carrier_from_loc(
              p_location_id    IN  NUMBER,
              x_carrier_id     OUT NOCOPY  NUMBER,
              x_return_status  OUT NOCOPY  VARCHAR2)
IS

    CURSOR c_get_carrier(c_location_id IN NUMBER) IS
    SELECT wc.carrier_id
    FROM   wsh_locations wl,
           hz_party_sites hps,
           hz_parties     hp,
           wsh_carriers   wc
    WHERE  wl.wsh_location_id = c_location_id
    AND    wl.location_source_code = 'HZ'
    AND    wl.source_location_id = hps.location_id
    AND    hps.party_id = hp.party_id
    AND    hp.party_id = wc.carrier_id;

    l_debug_on    CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
    l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'get_carrier_from_loc';

BEGIN

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    IF l_debug_on THEN
       wsh_debug_sv.push(l_module_name);
    END IF;


    IF ( p_location_id < g_cache_max_size  and g_carrier_from_location.EXISTS(p_location_id)) THEN

	x_carrier_id := g_carrier_from_location(p_location_id);
	IF (x_carrier_id = -1) THEN
	    x_carrier_id := NULL;
	END IF;

    ELSE

   	--Does not exist in the cache.
	OPEN  c_get_carrier(p_location_id);
        FETCH c_get_carrier INTO x_carrier_id;
	IF c_get_carrier%NOTFOUND THEN
	       x_carrier_id := NULL;
	END IF;
	CLOSE c_get_carrier;

	IF (p_location_id < g_cache_max_size ) THEN
	    g_carrier_from_location(p_location_id) := nvl(x_carrier_id,-1);
	END IF;

    END IF;

    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Returning carrier id : '|| x_carrier_id ||' for location : ' ||p_location_id);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --

EXCEPTION
    WHEN others THEN
      IF c_get_carrier%ISOPEN THEN
            CLOSE c_get_carrier;
      END IF;
      WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.get_carrier_from_loc');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END get_carrier_from_loc;

--***************************************************************************--
--========================================================================
-- PROCEDURE : get_customer_from_loc      PRIVATE
--
-- PARAMETERS: p_location_id              Input Location id
--             x_customer_id              Carrier at the input location
--             x_return_status            Return status
-- COMMENT   :
-- Returns the customer id of the customer
-- having a location at input wsh location id
--========================================================================

PROCEDURE get_customer_from_loc(
              p_location_id    IN  NUMBER,
              --x_customer_id     OUT NOCOPY  NUMBER,
              x_customer_id_tab     OUT NOCOPY  WSH_UTIL_CORE.id_tab_type,
              x_return_status  OUT NOCOPY  VARCHAR2)
IS

    CURSOR c_get_customer(c_location_id IN NUMBER) IS
    SELECT hcas.cust_account_id
    FROM   wsh_locations wl,
           hz_party_sites hps,
           hz_cust_acct_sites_all hcas
    WHERE  wl.wsh_location_id = c_location_id
    AND    wl.location_source_code = 'HZ'
    AND    wl.source_location_id = hps.location_id
    AND    hps.party_site_id = hcas.party_site_id;

    l_customer_id_tab   WSH_UTIL_CORE.id_tab_type;
    itr                    NUMBER := 0;
    i                      NUMBER := 0;
    l_return_status        VARCHAR2(1);
    l_cust_string          VARCHAR2(2000);

    l_debug_on    CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
    l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'get_customer_from_loc';

BEGIN

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    IF l_debug_on THEN
       wsh_debug_sv.push(l_module_name);
    END IF;

    IF ( p_location_id < g_cache_max_size  and g_customer_from_location.EXISTS(p_location_id)) THEN

	wsh_util_core.get_idtab_from_string(
        	p_string	 => g_customer_from_location(p_location_id),
		x_id_tab	 => l_customer_id_tab,
		x_return_status  => l_return_status);

	IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
  	    raise FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	itr := l_customer_id_tab.FIRST;

	IF (l_customer_id_tab(itr) <> -1) THEN

	   x_customer_id_tab:=l_customer_id_tab;

	END IF;

	IF l_debug_on THEN
	   wsh_debug_sv.push(l_module_name);
	END IF;

/*
	x_customer_id := g_customer_from_location(p_location_id);

	IF (x_customer_id = -1) THEN
		x_customer_id := NULL;
	END IF;
*/
    ELSE

	--Does not exist in the cache.
	OPEN c_get_customer(p_location_id);
	FETCH c_get_customer BULK COLLECT INTO l_customer_id_tab;
/*
	IF c_get_customer%NOTFOUND THEN
		 x_customer_id := NULL;
	END IF;
*/
	CLOSE c_get_customer;

	x_customer_id_tab := l_customer_id_tab;

	IF (p_location_id < g_cache_max_size ) THEN

	  itr:=l_customer_id_tab.FIRST;

	  IF (itr) IS NULL THEN
	        l_cust_string := '-1';
	  ELSE

	     wsh_util_core.get_string_from_idtab(
	    	p_id_tab	 => l_customer_id_tab,
		x_string	 => l_cust_string,
		x_return_status  => l_return_status);

	     IF l_debug_on THEN
		 WSH_DEBUG_SV.logmsg(l_module_name,'Org String '||l_cust_string);
	     END IF;

	     IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
  		 raise FND_API.G_EXC_UNEXPECTED_ERROR;
  	     END IF;

	  END IF;

	  g_customer_from_location(p_location_id) := l_cust_string;

	END IF;

/*
	IF (p_location_id < g_cache_max_size ) THEN
	   g_customer_from_location(p_location_id) := nvl(x_customer_id,-1);
	END IF;
*/

    END IF;

    --
    IF l_debug_on THEN
	i := x_customer_id_tab.FIRST;
	IF (i IS NOT NULL) THEN

	    WSH_DEBUG_SV.logmsg(l_module_name,'Number of Customers for the location '||p_location_id||'is :'|| x_customer_id_tab.COUNT);
	    LOOP
	       WSH_DEBUG_SV.logmsg(l_module_name,'Customer_id :'||x_customer_id_tab(i));
           EXIT WHEN i = x_customer_id_tab.LAST;
	       i  := x_customer_id_tab.NEXT(i);
	    END LOOP;

	ELSE
	    WSH_DEBUG_SV.logmsg(l_module_name,'No Organization assocaited with location '||p_location_id);

	END IF;

      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
/*

    IF ( p_location_id < g_cache_max_size  and g_customer_from_location.EXISTS(p_location_id)) THEN
	x_customer_id := g_customer_from_location(p_location_id);

	IF (x_customer_id = -1) THEN
		x_customer_id := NULL;
	END IF;
    ELSE

	--Does not exist in the cache.
	OPEN c_get_customer(p_location_id);
	FETCH c_get_customer INTO x_customer_id;
	IF c_get_customer%NOTFOUND THEN
		 x_customer_id := NULL;
	END IF;
	CLOSE c_get_customer;

	IF (p_location_id < g_cache_max_size ) THEN
	   g_customer_from_location(p_location_id) := nvl(x_customer_id,-1);
	END IF;

    END IF;

    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Returning customer id : '|| x_customer_id || ' for location : '||p_location_id);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
*/

EXCEPTION
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
        IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
    WHEN others THEN
      IF c_get_customer%ISOPEN THEN
         CLOSE c_get_customer;
      END IF;
      WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.get_customer_from_loc');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END get_customer_from_loc;

--***************************************************************************--
--========================================================================
-- PROCEDURE : get_supplier_from_loc      PRIVATE
--
-- PARAMETERS: p_location_id              Input Location id
--             x_supplier_id              supplier at the input location
--             x_return_status            Return status
-- COMMENT   :
-- Returns the supplier id of the supplier
-- having a location at input wsh location id
--========================================================================

PROCEDURE get_supplier_from_loc(
              p_location_id    IN  NUMBER,
              x_supplier_id     OUT NOCOPY  NUMBER,
              x_return_status  OUT NOCOPY  VARCHAR2)
IS

    CURSOR c_get_supplier(c_location_id IN NUMBER) IS
    SELECT hz.party_id
    FROM   hz_parties hz,
           po_vendors po,
           hz_relationships rel,
           hz_party_sites hps,
           wsh_locations wl
    WHERE  wl.wsh_location_id = c_location_id
    AND    wl.location_source_code = 'HZ'
    AND    wl.source_location_id = hps.location_id
    AND    rel.relationship_type = 'POS_VENDOR_PARTY'
    and    rel.object_id = hz.party_id
    and    rel.object_table_name = 'HZ_PARTIES'
    and    rel.object_type = 'ORGANIZATION'
    and    rel.subject_table_name = 'PO_VENDORS'
    and    rel.subject_id = po.vendor_id
    and    rel.subject_type = 'POS_VENDOR'
    AND    hps.party_id = hz.party_id;

    l_debug_on    CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
    l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'get_supplier_from_loc';

BEGIN

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    IF l_debug_on THEN
       wsh_debug_sv.push(l_module_name);
    END IF;


    IF (p_location_id < g_cache_max_size  and g_supplier_from_location.EXISTS(p_location_id)) THEN

	x_supplier_id := g_supplier_from_location(p_location_id);
	IF (x_supplier_id = -1) THEN
		x_supplier_id := NULL;
	END IF;

    ELSE
	    --Does not exist in the cache.
	    OPEN c_get_supplier(p_location_id);
	    FETCH c_get_supplier INTO x_supplier_id;
	    IF c_get_supplier%NOTFOUND THEN
	       x_supplier_id := NULL;
	    END IF;
	    CLOSE c_get_supplier;

	    IF (p_location_id < g_cache_max_size ) THEN
	      g_supplier_from_location(p_location_id) := nvl(x_supplier_id,-1);
	    END IF;

    END IF;

    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Returning supplier id : '|| x_supplier_id || ' for location :'|| p_location_id);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --

EXCEPTION
    WHEN others THEN
      IF c_get_supplier%ISOPEN THEN
         CLOSE c_get_supplier;
      END IF;
      WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.get_supplier_from_loc');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END get_supplier_from_loc;


--#DUM_LOC(S)
--***************************************************************************--
--========================================================================
-- PROCEDURE : get_org_from_location      PRIVATE
--
-- PARAMETERS: p_location_id              Input Location id
--             x_organization_tab         Organizations for the input location
--             x_return_status            Return status
-- COMMENT   :
--	       Returns table of organizations for location.
--========================================================================
PROCEDURE get_org_from_location(
         p_location_id	       IN  NUMBER,
         x_organization_tab    OUT NOCOPY  WSH_UTIL_CORE.id_tab_type,
         x_return_status       OUT NOCOPY  VARCHAR2)
IS
	CURSOR c_get_org_from_loc(c_location_id IN NUMBER) IS
	SELECT owner_party_id
	FROM   wsh_location_owners
	WHERE  owner_type = 1
        AND    wsh_location_id = c_location_id
	AND    owner_party_id <> -1 ;


	l_organization_tab	WSH_UTIL_CORE.id_tab_type;

	itr			NUMBER;
	i			NUMBER;
	l_return_status		VARCHAR2(1);
	l_org_string		VARCHAR2(32767);

	l_debug_on		CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
        l_module_name		CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'get_org_from_location';

BEGIN
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   IF l_debug_on THEN
       wsh_debug_sv.push(l_module_name);
   END IF;

   IF (p_location_id < g_cache_max_size and g_organization_from_location.EXISTS(p_location_id)) THEN

	wsh_util_core.get_idtab_from_string(
        	p_string	 => g_organization_from_location(p_location_id),
		x_id_tab	 => l_organization_tab,
		x_return_status  => l_return_status);

	IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
  	    raise FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	itr := l_organization_tab.FIRST;

	IF (l_organization_tab(itr) <> -1) THEN

	   x_organization_tab:=l_organization_tab;

	END IF;

	IF l_debug_on THEN
	   wsh_debug_sv.push(l_module_name);
	END IF;

    ELSE

	--Does not exist in the cache.
	OPEN  c_get_org_from_loc(p_location_id);
	FETCH c_get_org_from_loc BULK COLLECT INTO l_organization_tab;
	CLOSE c_get_org_from_loc;

	x_organization_tab := l_organization_tab;

	IF (p_location_id < g_cache_max_size ) THEN

	  itr:=l_organization_tab.FIRST;

	  IF (itr) IS NULL THEN
	        l_org_string := '-1';
	  ELSE

	     wsh_util_core.get_string_from_idtab(
	    	p_id_tab	 => l_organization_tab,
		x_string	 => l_org_string,
		x_return_status  => l_return_status);

	     IF l_debug_on THEN
		 WSH_DEBUG_SV.logmsg(l_module_name,'Org String '||l_org_string);
	     END IF;

	     IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
  		 raise FND_API.G_EXC_UNEXPECTED_ERROR;
  	     END IF;

	  END IF;

	  g_organization_from_location(p_location_id) := l_org_string;

	END IF;

      END IF;

      -- BUG 4120043 : Replaced FOR loop by iteration using NEXT.
      IF l_debug_on THEN

	i := x_organization_tab.FIRST;
	IF (i IS NOT NULL) THEN

	    WSH_DEBUG_SV.logmsg(l_module_name,'Number of Organizations for the location '||p_location_id||'is :'|| x_organization_tab.COUNT);
	    LOOP
	       WSH_DEBUG_SV.logmsg(l_module_name,'Organization_id :'||x_organization_tab(i));
           EXIT WHEN i = x_organization_tab.LAST;
	       i  := x_organization_tab.NEXT(i);
	    END LOOP;

	ELSE
	    WSH_DEBUG_SV.logmsg(l_module_name,'No Organization assocaited with location '||p_location_id);

	END IF;

	WSH_DEBUG_SV.pop(l_module_name);

      END IF;
      --

EXCEPTION
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
       IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
    WHEN others THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

      IF c_get_org_from_loc%ISOPEN THEN
         CLOSE c_get_org_from_loc;
      END IF;

      WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.get_org_from_loc');

      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END get_org_from_location;

--#DUM_LOC(E)


--
-- Bug 4142393:TST11510.1CU.2:ENCOUNTERING UNEXPECTED ERROR IN DLWB, WHILE SPLITTING THE DEL'RY
--
--***************************************************************************--
--========================================================================
-- PROCEDURE : get_loc_for_org            PRIVATE
--
-- PARAMETERS: p_org_id                   Input Organization id
--             x_location_id              Location id corresponding to the organization.
--             x_return_status            Return status
-- COMMENT   :
--             Returns the corresponding location for the organziation.
--            (The procedure handles cases where org is not associated with a location)
--========================================================================
PROCEDURE get_loc_for_org(
              p_org_id	       IN  NUMBER,
              x_location_id    OUT NOCOPY  NUMBER,
              x_return_status  OUT NOCOPY  VARCHAR2)
IS
          --Bug 4891887
	 /*CURSOR c_org_to_loc (v_org_id NUMBER) IS
         SELECT location_id
         FROM	wsh_ship_from_orgs_v
         WHERE  organization_id = v_org_id;*/

 	 l_debug_on    CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
         l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'get_loc_for_org';

BEGIN

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    IF l_debug_on THEN
       wsh_debug_sv.push(l_module_name);
    END IF;


    IF ( p_org_id < g_cache_max_size  and g_loc_from_org.EXISTS(p_org_id)) THEN

	x_location_id := g_loc_from_org(p_org_id);
	IF (x_location_id = -1) THEN
	    x_location_id := NULL;
	END IF;

    ELSE

   	--Does not exist in the cache.
	--Bug 4891887
	/*OPEN  c_org_to_loc(p_org_id);
        FETCH c_org_to_loc INTO x_location_id;

	IF    c_org_to_loc%NOTFOUND THEN
	       x_location_id := NULL;
	END IF;

	CLOSE c_org_to_loc;*/
	--Bug 4891887 and 4891881 Calling Utilcore package
	G_CALLING_API :='CONSTRAINT';
	WSH_UTIL_CORE.Get_Location_Id(
	                              p_mode=>'ORG',
	                              p_source_id=>p_org_id,
				      x_location_id=>x_location_id,
				      x_api_status=>x_return_status,
				      p_transfer_location=>FALSE);
        G_CALLING_API :=NULL;

	IF (p_org_id < g_cache_max_size ) THEN
	    g_loc_from_org(p_org_id) := nvl(x_location_id,-1);
	END IF;

    END IF;

    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Returning location id : '|| x_location_id ||' for Organization: ' ||p_org_id);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --

EXCEPTION
    WHEN others THEN
      G_CALLING_API :=NULL;
         --Bug 4891887
      /*IF c_org_to_loc%ISOPEN THEN
            CLOSE c_org_to_loc;
      END IF;*/

      WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.get_loc_for_org');

      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END get_loc_for_org;


--***************************************************************************--
--========================================================================
-- PROCEDURE : stack_messages             PRIVATE
--
-- PARAMETERS: p_failed_constraints       Table of violated constraint records
--             x_msg_count                Number of messages in the list
--             x_msg_data                 Text of messages
--             x_return_status            Return status
-- COMMENT   :
-- Stacks constraint violation messages
-- inpto the FND message stack
--========================================================================
PROCEDURE stack_messages (
             p_failed_constraints       IN  OUT NOCOPY line_constraint_tab_type,
             x_msg_count                OUT NOCOPY NUMBER,
             x_msg_data                 OUT NOCOPY VARCHAR2,
             x_return_status            OUT NOCOPY VARCHAR2)
IS

    i                       NUMBER:=0;
    l_return_status         VARCHAR2(1);
    l_entity                VARCHAR2(2000);
    l_entity_id             NUMBER;
    l_object1_name          VARCHAR2(2000);
    l_object1_parent_name   VARCHAR2(2000);
    l_object2_name          VARCHAR2(2000);
    l_object2_parent_name   VARCHAR2(2000);
    l_condition             VARCHAR2(100);
    l_fac1_company_type     VARCHAR2(2000);
    l_fac1_company_name     VARCHAR2(2000);
    l_fac2_company_type     VARCHAR2(2000);
    l_fac2_company_name     VARCHAR2(2000);
    l_class_type            VARCHAR2(100);
    l_class_meaning         VARCHAR2(2000);
    l_severity              VARCHAR2(100);
    l_severity_meaning      VARCHAR2(2000);
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000) := NULL;

    g_object_name_failed    EXCEPTION;

    l_module_name           CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'stack_messages';
    l_debug_on              CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;

BEGIN

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    IF l_debug_on THEN
       wsh_debug_sv.push(l_module_name);
       wsh_debug_sv.log (l_module_name,'No. of constraints violated : ',to_char(p_failed_constraints.COUNT));
    END IF;
    -- Loop pver p_failed_constraints and add messages

    FND_MSG_PUB.Count_And_Get (
     p_count         =>      l_msg_count,
     p_data          =>      l_msg_data ,
     p_encoded       =>      FND_API.G_FALSE );

    IF l_debug_on THEN
      wsh_debug_sv.log (l_module_name,'No. of messages already in stack : ',to_char(l_msg_count));
      --WSH_DEBUG_SV.pop(l_module_name);
    END IF;

    -- Remove duplicate constraints,from p_failed_constraints table.
    -- Unique constraints stored in l_failed_constraints table.

    remove_duplicate_const(
	p_failed_constraints	=> p_failed_constraints,
	x_return_status		=> l_return_status);


    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
             raise FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
    END IF;

    i := p_failed_constraints.FIRST;
    IF i IS NOT NULL THEN
     LOOP

     IF p_failed_constraints(i).constraint_id IS NOT NULL THEN

      IF l_debug_on THEN
         --wsh_debug_sv.push(l_module_name);
         wsh_debug_sv.log (l_module_name,'constraint id violated : ',to_char(p_failed_constraints(i).constraint_id));
      END IF;

      get_constraint_display(
             p_constraint_id           => p_failed_constraints(i).constraint_id,
             x_obj1_display            => l_object1_name,
             x_obj1_parent_display     => l_object1_parent_name,
             x_obj2_display            => l_object2_name,
             x_obj2_parent_display     => l_object2_parent_name,
             x_condition_display       => l_condition,
             x_fac1_company_type       => l_fac1_company_type,
             x_fac1_company_name       => l_fac1_company_name,
             x_fac2_company_type       => l_fac2_company_type,
             x_fac2_company_name       => l_fac2_company_name,
             x_comp_class_code         => l_class_type,
             x_severity                => l_severity,
             x_return_status           => l_return_status );

      IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      l_class_meaning := WSH_XC_UTIL.Get_Lookup_Meaning(
                p_lookup_code     =>   l_class_type,
                p_lookup_type     =>   'WSH_FTE_COMP_CLASSES'
                );

      IF l_class_meaning IS NULL THEN
         raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      l_severity_meaning := WSH_XC_UTIL.Get_Lookup_Meaning(
                p_lookup_code     =>   l_severity,
                p_lookup_type     =>   'WSH_FTE_VIOLATION_SEVERITY'
                );

      IF l_severity_meaning IS NULL THEN
         raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF p_failed_constraints(i).entity_type = G_DELIVERY THEN
         l_entity := FND_MESSAGE.GET_STRING('FTE','FTE_ENTITY_DELIVERY');
      ELSIF p_failed_constraints(i).entity_type = G_DEL_DETAIL THEN
         l_entity := FND_MESSAGE.GET_STRING('FTE','FTE_ENTITY_DELIVERY_DETAIL');
      ELSIF p_failed_constraints(i).entity_type = G_DELIVERY_LEG THEN
         l_entity := FND_MESSAGE.GET_STRING('FTE','FTE_ENTITY_DELIVERY_LEG');
      ELSIF p_failed_constraints(i).entity_type = G_TRIP THEN
         l_entity := FND_MESSAGE.GET_STRING('FTE','FTE_ENTITY_TRIP');
      ELSIF p_failed_constraints(i).entity_type = G_STOP THEN
         l_entity := FND_MESSAGE.GET_STRING('FTE','FTE_ENTITY_STOP');
      ELSIF p_failed_constraints(i).entity_type = G_LANE THEN
         l_entity := FND_MESSAGE.GET_STRING('FTE','FTE_ENTITY_LANE');
      ELSIF p_failed_constraints(i).entity_type = G_CAR_SERVICE THEN
         l_entity := FND_MESSAGE.GET_STRING('FTE','FTE_ENTITY_CARRIER_SERVICE');
      ELSIF p_failed_constraints(i).entity_type = G_LOCATION THEN
         l_entity := FND_MESSAGE.GET_STRING('FTE','FTE_ENTITY_LOCATION');
      END IF;

      l_entity_id := (p_failed_constraints(i).entity_line_id);

      FND_MESSAGE.SET_NAME('FTE','FTE_COMP_VALIDATION_MESSAGE');
      FND_MESSAGE.SET_TOKEN('ENTITY',l_entity);
      FND_MESSAGE.SET_TOKEN('ID',to_char(l_entity_id));
      FND_MESSAGE.SET_TOKEN('TYPE',l_class_meaning);
      FND_MESSAGE.SET_TOKEN('OBJECT1',l_object1_name);
      FND_MESSAGE.SET_TOKEN('CONDITION',l_condition);
      FND_MESSAGE.SET_TOKEN('OBJECT2',l_object2_name);
      FND_MESSAGE.SET_TOKEN('SEVERITY',l_severity_meaning);
      FND_MSG_PUB.ADD;

      IF l_debug_on THEN
         wsh_debug_sv.log (l_module_name,'constraint found : ',to_char(i));
         wsh_debug_sv.log (l_module_name,'entity ',l_entity);
         wsh_debug_sv.log (l_module_name,'entity id ',to_char(l_entity_id));
         wsh_debug_sv.log (l_module_name,'class type ',l_class_type);
         wsh_debug_sv.log (l_module_name,'object1 name ',l_object1_name);
         wsh_debug_sv.log (l_module_name,'condition ',l_condition);
         wsh_debug_sv.log (l_module_name,'object2 name ',l_object2_name);
         wsh_debug_sv.log (l_module_name,'severity ',l_severity);
      END IF;
     END IF; -- constraint_id IS NOT NULL

     EXIT WHEN i = p_failed_constraints.LAST;
     i := p_failed_constraints.NEXT(i);

     END LOOP;
    END IF;

   -- Standard call to get message count and if count is 1,
   -- get message info.

    FND_MSG_PUB.Count_And_Get (
     p_count         =>      x_msg_count,
     p_data          =>      x_msg_data ,
     p_encoded       =>      FND_API.G_FALSE );

    IF l_debug_on THEN
      wsh_debug_sv.log (l_module_name,'No. of messages stacked : ',to_char(x_msg_count));
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;

EXCEPTION
    WHEN g_object_name_failed THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,'get_constraint_display failed ');
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
    WHEN others THEN
      WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.stack_messages');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END stack_messages;


--***************************************************************************--
--========================================================================
-- PROCEDURE : create_valid_entity_group  PRIVATE
--                                        Called by the delivery and delivery detail
--                                        API to build group
--
-- PARAMETERS: p_entity_rec               Record of input delivery OR delivery line
--             p_group_tab                Output group table incremented by a new group for the
--                                        input entity
--             x_return_status            Return status
-- COMMENT   : Output group in which entities can be put together
--
--========================================================================

PROCEDURE create_valid_entity_group(
                  p_entity_rec            IN OUT NOCOPY  entity_rec_type,
                  p_group_tab             IN OUT NOCOPY  WSH_FTE_COMP_CONSTRAINT_PKG.cc_group_tab_type,
                  x_return_status         OUT NOCOPY     VARCHAR2)
IS

    l_group_count    NUMBER :=   p_group_tab.COUNT;

    l_module_name    CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'create_valid_entity_group';
    l_debug_on       CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;

BEGIN

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    IF l_debug_on THEN
       wsh_debug_sv.push(l_module_name);
    END IF;

    p_group_tab(l_group_count+1).group_index := l_group_count+1;
    p_group_tab(l_group_count+1).line_group_id := l_group_count+1;

    p_entity_rec.group_id := p_group_tab(l_group_count+1).line_group_id;

    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --

EXCEPTION
    WHEN others THEN
      WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.create_valid_entity_group');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END create_valid_entity_group;

--***************************************************************************--
--========================================================================
-- PROCEDURE : populate_constraint_cache  PRIVATE
--
-- PARAMETERS: p_comp_class_code          Input compatibility class code
--             x_return_status            Return status
-- COMMENT   : Builds the database session caches
--             for constraint definitions
--========================================================================

PROCEDURE populate_constraint_cache(
          p_comp_class_code          IN      VARCHAR2 DEFAULT NULL,
          x_return_status            OUT NOCOPY    VARCHAR2)
IS

    CURSOR c_get_constraint_info(c_comp_class_id IN NUMBER) IS
    SELECT *
    FROM   WSH_FTE_COMP_CONSTRAINTS
    WHERE  COMPATIBILITY_CLASS_ID = nvl(c_comp_class_id,COMPATIBILITY_CLASS_ID)
    AND    nvl(trunc(EFFECTIVE_DATE_FROM,'DDD'),trunc(sysdate,'DDD')) <= trunc(sysdate,'DDD')
    AND    nvl(trunc(EFFECTIVE_DATE_TO,'DDD'),trunc(sysdate,'DDD')) >= trunc(sysdate,'DDD');

    l_hash_string      VARCHAR2(200):=NULL;
    l_hash_value       NUMBER:=0;
    l_comp_class_id    NUMBER:=NULL;
    l_constraint_rec   WSH_FTE_COMP_CONSTRAINTS%ROWTYPE;

    l_module_name      CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'populate_constraint_cache';
    l_debug_on         CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;

BEGIN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       WSH_DEBUG_SV.logmsg(l_module_name,'p_comp_class_code : '||p_comp_class_code);
    END IF;

    IF p_comp_class_code IS NOT NULL THEN
       l_comp_class_id := get_compclass_id(p_comp_class_code);

       IF l_comp_class_id = g_unexp_num THEN
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       --
       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Called get_compclass_id comp_class_id : '||l_comp_class_id);
       END IF;
       --
    END IF;

    -- Potentially when this API is called in case of a hash collision,
    -- the constraints cache will get rebuilt with all constraint definitions
    -- not only the constraint types that existed before the collision
    -- The only potential impact is more memory

    OPEN c_get_constraint_info(l_comp_class_id);
    LOOP
       FETCH c_get_constraint_info INTO l_constraint_rec;
       EXIT WHEN c_get_constraint_info%NOTFOUND;

       l_hash_string :=        (l_comp_class_id)||'-'||l_constraint_rec.constraint_object1_type||'-'||nvl(       to_char(l_constraint_rec.constraint_object1_id),
          l_constraint_rec.constraint_object1_value_char)||'-'||       (nvl(l_constraint_rec.object1_source_id,-9999))||
          '-'||l_constraint_rec.constraint_object2_type||'-'||nvl(to_char(l_constraint_rec.constraint_object2_id),l_constraint_rec.constraint_object2_value_char)||'-'||       (nvl(l_constraint_rec.object2_source_id,-9999));

       l_hash_value := dbms_utility.get_hash_value(
                                  name => l_hash_string,
                                  base => g_hash_base,
                                  hash_size => g_hash_size );
       --
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'l_hash_string : '||l_hash_string);
         WSH_DEBUG_SV.logmsg(l_module_name,'l_hash_value : '||l_hash_value);
       END IF;
       --

       IF NOT g_comp_constraint_tab.EXISTS(l_hash_value) THEN
          g_comp_constraint_tab(l_hash_value) := l_constraint_rec;
       END IF;

    END LOOP;
    CLOSE c_get_constraint_info;

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
      IF c_get_constraint_info%ISOPEN THEN
         CLOSE c_get_constraint_info;
      END IF;
      WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.populate_constraint_cache');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END populate_constraint_cache;


--***************************************************************************--
--========================================================================
-- FUNCTION  : check_cache               PRIVATE
--
-- PARAMETERS: p_hash_value              Input hash value
--             p_hash_string             Input hash string corresponding to l_hash_value
--             x_return_status           Return Status
-- COMMENT   : Checks in global constraint cache if a record corresponding to
--             l_hash_value and l_hash_string exists
--             checks if hash string also matches for a match in hash value
--             If it does not, constructs new hash value by increasing hash size
--             and keeps on comparing
--             Returns FALSE if there is no valid match
--========================================================================

FUNCTION check_cache (
             p_hash_value       IN   NUMBER,
             p_hash_string      IN   VARCHAR2 ) RETURN BOOLEAN
IS

    l_hashval_exists    BOOLEAN := TRUE;
    l_hash_value        NUMBER := 0;
    lg_hash_string      VARCHAR2(2000) := NULL;
    l_return_status     VARCHAR2(1);

    l_debug_on          CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
    l_module_name       CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'check_cache';

BEGIN

    --
    IF l_debug_on THEN
      wsh_debug_sv.push (l_module_name);
      wsh_debug_sv.logmsg(l_module_name,'p_hash_value : '||p_hash_value);
      wsh_debug_sv.logmsg(l_module_name,'p_hash_string : '||p_hash_string);
    END IF;
    --

    IF p_hash_value IS NULL OR p_hash_string IS NULL THEN
       --
       IF l_debug_on THEN
          wsh_debug_sv.pop (l_module_name);
       END IF;
       --
       RETURN FALSE;
    END IF;

    IF g_comp_constraint_tab.EXISTS(p_hash_value) THEN

       lg_hash_string := (g_comp_constraint_tab(p_hash_value).compatibility_class_id)||'-'||g_comp_constraint_tab(p_hash_value).constraint_object1_type||'-'||nvl(to_char(g_comp_constraint_tab(p_hash_value).constraint_object1_id),
       g_comp_constraint_tab(p_hash_value).constraint_object1_value_char)||'-'||(nvl(g_comp_constraint_tab(p_hash_value).object1_source_id,-9999))||
       '-'||g_comp_constraint_tab(p_hash_value).constraint_object2_type||'-'||nvl(to_char(g_comp_constraint_tab(p_hash_value).constraint_object2_id),g_comp_constraint_tab(p_hash_value).constraint_object2_value_char)||
       '-'||(nvl(g_comp_constraint_tab(p_hash_value).object2_source_id,-9999));

       IF l_debug_on THEN
          wsh_debug_sv.logmsg(l_module_name,'lg_hash_string : '||lg_hash_string);
       END IF;

       IF NOT lg_hash_string = p_hash_string THEN
          -- Hash collision with current g_hash_size for input p_hash_value
          l_hashval_exists := FALSE;
          WHILE NOT l_hashval_exists LOOP
           g_hash_size := g_hash_size + 1;

           -- Delete current constraint cache and
           -- rebuild current constraint cache with higher g_hash_size

           g_comp_constraint_tab.DELETE;

           populate_constraint_cache(
               --p_hash_size                =>    g_hash_size,
               x_return_status            =>    l_return_status) ;

           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                 raise FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
           END IF;

           --
           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Called populate_constraint_cache return status : '||l_return_status);
           END IF;
           --

           l_hash_value := dbms_utility.get_hash_value(
                                  name => p_hash_string,
                                  base => g_hash_base,
                                  hash_size => g_hash_size );

           IF g_comp_constraint_tab.EXISTS(l_hash_value) THEN

              lg_hash_string := (g_comp_constraint_tab(l_hash_value).compatibility_class_id)||'-'||g_comp_constraint_tab(l_hash_value).constraint_object1_type||'-'||nvl(to_char(g_comp_constraint_tab(l_hash_value).constraint_object1_id),
              g_comp_constraint_tab(l_hash_value).constraint_object1_value_char)||'-'||(nvl(g_comp_constraint_tab(l_hash_value).object1_source_id,-9999))||
              '-'||g_comp_constraint_tab(l_hash_value).constraint_object2_type||'-'||nvl(to_char(g_comp_constraint_tab(l_hash_value).constraint_object2_id),g_comp_constraint_tab(l_hash_value).constraint_object2_value_char)||
              '-'||(nvl(g_comp_constraint_tab(l_hash_value).object2_source_id,-9999));

              IF l_debug_on THEN
                 wsh_debug_sv.logmsg(l_module_name,'lg_hash_string : '||lg_hash_string);
              END IF;

              IF lg_hash_string = p_hash_string THEN
                 -- Constraint found in new cache
                 l_hashval_exists := TRUE;
              ELSE
                 -- Still collision
                 l_hashval_exists := FALSE;
              END IF;
           ELSE
              -- No match in new cache for input hash string
              l_hashval_exists := FALSE;
              EXIT;
           END IF;

          END LOOP;

       END IF;

    ELSE

       l_hashval_exists := FALSE;

    END IF;

    --
    IF l_debug_on THEN
      wsh_debug_sv.pop (l_module_name);
    END IF;
    --

    RETURN l_hashval_exists;

EXCEPTION
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.check_cache');
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
      RETURN FALSE;
      WHEN others THEN
      WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.check_cache');
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
      RETURN FALSE;
END check_cache;



--DUM_LOC
--***************************************************************************--
--========================================================================
-- FUNCTION  : SORT_STOP_TABLE_ASC  PRIVATE
--
-- COMMENT   : Sorts  p_stop_table in ASCENDING order depending on PLANNED_ARRIVAL_DATE.
--             In case two stops have the same PLANNED_ARRIVAL_DATE, Dummy locations
--             appear before original locations.
--	       SELECTION SORT - used to reduce the number of swaps
--========================================================================
PROCEDURE sort_stop_table_asc
		(p_stop_table		IN	      stop_ccinfo_tab_type,
		 x_sort_stop_table      OUT NOCOPY    stop_ccinfo_tab_type,
		 x_return_status	OUT NOCOPY    VARCHAR2)

IS

     min_pos		NUMBER;
     j			NUMBER;
     l_swap_rec		stop_ccinfo_rec_type;
     l_stop_table	stop_ccinfo_tab_type;

     l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' ||'sort_stop_table_asc';
     l_debug_on    CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;

BEGIN

  IF l_debug_on THEN
          WSH_DEBUG_SV.push(l_module_name);
  END IF;

  x_return_status   := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  l_stop_table      := p_stop_table;

  FOR i IN l_stop_table.FIRST..l_stop_table.LAST
  LOOP
	min_pos := i;
	j := l_stop_table.NEXT(i);

	IF  j is NOT NULL THEN
	LOOP

	   IF ( l_stop_table(j).PLANNED_ARRIVAL_DATE < l_stop_table(min_pos).PLANNED_ARRIVAL_DATE) THEN
		min_pos := j ;
        ELSIF (l_stop_table(j).PLANNED_ARRIVAL_DATE = l_stop_table(min_pos).PLANNED_ARRIVAL_DATE
		  AND (l_stop_table(min_pos).PHYSICAL_LOCATION_ID IS  NULL AND
		       l_stop_table(j).PHYSICAL_LOCATION_ID IS NOT NULL))
	   THEN
		min_pos := j;
	   END IF;

	   EXIT WHEN j= l_stop_table.LAST;
       j:= l_stop_table.NEXT(j);
     END LOOP;
     END IF;

	 IF ( i <> min_pos ) THEN
		 l_swap_rec  := l_stop_table(i);
		 l_stop_table(i) := l_stop_table(min_pos);
		 l_stop_table(min_pos)  := l_swap_rec;
	 END IF;

   END LOOP;

   x_sort_stop_table := l_stop_table;

   IF l_debug_on THEN

	  WSH_DEBUG_SV.logmsg(l_module_name,'Number of entries in Sorted table : '||x_sort_stop_table.count);
	  FOR i in x_sort_stop_table.FIRST..x_sort_stop_table.LAST
  	  LOOP
	    WSH_DEBUG_SV.logmsg(l_module_name,i||'STOP_ID'||x_sort_stop_table(i).STOP_ID||'Planned Arrival date '||x_sort_stop_table(i).PLANNED_ARRIVAL_DATE);
	  END LOOP;
 	  WSH_DEBUG_SV.pop(l_module_name);
   END IF;

EXCEPTION
WHEN OTHERS THEN
      WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.sort_stop_table_asc');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
END sort_stop_table_asc;
--DUM_LOC(E)



--#REG-ZON
--***************************************************************************--
--
--========================================================================
-- PROCEDURE :  populate_reg_mustuse_cache            PRIVATE
--
-- PARAMETERS:  p_reg_class_id            REG-FAC Constraint Class Id.
--		x_return_status           Return Status
-- COMMENT   :  The cache constains Region -Facitlity MUST-USE constraints.
--
--========================================================================
PROCEDURE populate_reg_mustuse_cache(
             p_reg_class_id             IN  NUMBER,
	     x_return_status            OUT NOCOPY    VARCHAR2)
IS

    CURSOR c_get_constraint_info(c_comp_class_id IN NUMBER) IS
    SELECT *
    FROM   WSH_FTE_COMP_CONSTRAINTS
    WHERE  COMPATIBILITY_CLASS_ID = c_comp_class_id
    AND    CONSTRAINT_TYPE        = 'I'
    AND    nvl(trunc(EFFECTIVE_DATE_FROM,'DDD'),trunc(sysdate,'DDD')) <= trunc(sysdate,'DDD')
    AND    nvl(trunc(EFFECTIVE_DATE_TO,'DDD'),trunc(sysdate,'DDD')) >= trunc(sysdate,'DDD');

    itr                NUMBER := 0;
    l_constraint_rec   WSH_FTE_COMP_CONSTRAINTS%ROWTYPE;
    l_module_name      CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'populate_reg_const_cache';
    l_debug_on         CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;

BEGIN

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
    END IF;

    --
    -- Cache needs to be populated only once in a Session.
    --

    IF (g_reg_const_cache.COUNT=0) THEN

       IF l_debug_on THEN
	  WSH_DEBUG_SV.logmsg(l_module_name,'Populating g_reg_const_cache ');
       END IF;

       OPEN c_get_constraint_info(p_reg_class_id);
       /* Does not work in 8i
       FETCH c_get_constraint_info BULK COLLECT INTO g_reg_const_cache;
       */

       LOOP
       FETCH c_get_constraint_info INTO l_constraint_rec;
       EXIT WHEN c_get_constraint_info%NOTFOUND;

       itr := itr + 1;
       g_reg_const_cache(itr) := l_constraint_rec;

       END LOOP;
       CLOSE c_get_constraint_info;

    END IF;

    --
    IF l_debug_on THEN
	WSH_DEBUG_SV.logmsg(l_module_name,' Number of entries in g_reg_const_cache : '||g_reg_const_cache.count);
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
EXCEPTION
  WHEN others THEN
      IF c_get_constraint_info%ISOPEN THEN
         CLOSE c_get_constraint_info;
      END IF;

      WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.populate_reg_mustuse_cache');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END populate_reg_mustuse_cache;


--***************************************************************************--
--
--========================================================================
-- PROCEDURE : add_region_constraint     PRIVATE
--
--PARAMETERS:  p_location_id		    Location id
--	       p_object2_id		    Facility ID
--	       p_constraint_id		    Constraint ID
--					    ( Id is g_const_not_present when constraint
--                                          is not present between entities)
--	       p_constraint_type	    Constraint Type - E/I
--	       x_return_status              Return Status
-- COMMENT   :
--	       Add  constraints to the location-facility cache.
--	       The cache is stores following results
--             a) LOCATION - FACILITY (INCLUSIVE CONSTRAINT/EXCLUSIVE)
--                (Store location Facility which has inclusive constraint)
--		  Location id - Facility ID - Constraint ID - I
--		  Location id - Facility ID - Constraint ID - E
--             b) LOCATION - FACILITY (EXCLUSIVE CONSTRAINT)
--                (Store locations which have no exclusive  constriant)
--                Location id - (-9999) - (-1111)  - I
--========================================================================
PROCEDURE add_region_constraint(
	  p_location_id		IN	   NUMBER
	, p_object2_id		IN	   NUMBER
	, p_constraint_id	IN	   NUMBER
	, p_constraint_type	IN   	   VARCHAR2
	, x_return_status       OUT NOCOPY VARCHAR2)
IS

itr			NUMBER;
l_count			NUMBER;
l_region_hash_str	VARCHAR2(200);
l_region_hash_val	NUMBER;
l_module_name		CONSTANT VARCHAR2(100):= 'wsh.plsql.' ||G_PKG_NAME ||'.' ||'add_region_constraint';
l_debug_on		CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;

BEGIN
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    --
    IF l_debug_on THEN
       wsh_debug_sv.push (l_module_name);
       wsh_debug_sv.logmsg(l_module_name,'p_location_id : '||p_location_id);
       wsh_debug_sv.logmsg(l_module_name,'p_object2_id  : '||p_object2_id);
       wsh_debug_sv.logmsg(l_module_name,'p_constraint_id  : '||p_constraint_id);
       wsh_debug_sv.logmsg(l_module_name,'p_constraint_type: '||p_constraint_type);
    END IF;
    --

    l_region_hash_str :=    p_location_id  ||'-'
		         || p_object2_id   ||'-'
		         || p_constraint_type;

    l_region_hash_val := dbms_utility.get_hash_value(
	  		 name => l_region_hash_str,
			 base => l_reg_hash_base,
		         hash_size =>l_reg_hash_size );

    IF l_debug_on THEN
	  WSH_DEBUG_SV.logmsg(l_module_name,'l_region_hash_str : '||l_region_hash_str);
          WSH_DEBUG_SV.logmsg(l_module_name,'l_region_hash_val : '||l_region_hash_val);
    END IF;


    IF NOT (g_regloc_loc_cache.EXISTS(l_region_hash_val)) THEN
	  g_regloc_loc_cache(l_region_hash_val).location_id	:= p_location_id;
	  g_regloc_loc_cache(l_region_hash_val).object2_id	:= p_object2_id	;
	  g_regloc_loc_cache(l_region_hash_val).constraint_id 	:= p_constraint_id;
	  g_regloc_loc_cache(l_region_hash_val).constraint_type	:= p_constraint_type;
	  g_regloc_loc_cache(l_region_hash_val).hash_string     := l_region_hash_str;
    ELSE
	 -- Hash Collision has occured.
	 -- Need to resolve it using Linear Probing.
	 -- Iterate from the current position to check till found.

	  IF l_debug_on THEN
	     WSH_DEBUG_SV.logmsg(l_module_name,'HASH COLLISION for hash string :'||l_region_hash_str);
	     WSH_DEBUG_SV.logmsg(l_module_name,'HASH value at COLLISION        :'||l_region_hash_val);
          END IF;

	  itr := l_region_hash_val+1;

	  LOOP
	     EXIT WHEN NOT(g_regloc_loc_cache.EXISTS(itr));
	     itr:=itr+1;
	  END LOOP;

	  IF l_debug_on THEN
	     WSH_DEBUG_SV.logmsg(l_module_name,'HASH COLLISION resolved at position:'||itr);
          END IF;

	  --Empty Space has been found.
	  g_regloc_loc_cache(itr).location_id	  := p_location_id;
	  g_regloc_loc_cache(itr).object2_id	  := p_object2_id	;
	  g_regloc_loc_cache(itr).constraint_id   := p_constraint_id;
	  g_regloc_loc_cache(itr).constraint_type := p_constraint_type;
	  g_regloc_loc_cache(itr).hash_string     := l_region_hash_str;

     END IF;

     --
     IF l_debug_on THEN
        wsh_debug_sv.pop (l_module_name);
     END IF;
     --

EXCEPTION
WHEN others THEN

      WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.add_region_constraint');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END add_region_constraint;


--************************************************************************
--
--========================================================================
-- FUNCTION :  get_region_constraint          PRIVATE
--
-- PARAMETERS:   p_location_id		      Location id
--		 p_object2_id		      Facility ID
--		 p_constraint_type	      Constraint Type - E/I
--		 x_return_status              Return Status
--
-- COMMENT   :  This procedure is used to retrieve the constraint id for a Region-FAC
--		constrait. The cache stores location id of object 1 and object 2
--========================================================================

FUNCTION get_region_constraint
     (    p_location_id		IN	   NUMBER
	, p_object2_id		IN	   NUMBER
	, p_constraint_type	IN   	   VARCHAR2
	, x_return_status       OUT NOCOPY VARCHAR2) RETURN NUMBER
IS

     itr		NUMBER;
     l_count		NUMBER;
     l_slot_checked     NUMBER;
     l_region_hash_str	VARCHAR2(200);
     l_region_hash_val	NUMBER;
     l_module_name	CONSTANT VARCHAR2(100):= 'wsh.plsql.' ||G_PKG_NAME ||'.' ||'get_region_constraint';
     l_debug_on		CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
     l_constraint_id    NUMBER;

BEGIN

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    --
    IF l_debug_on THEN
       wsh_debug_sv.push (l_module_name);
       wsh_debug_sv.logmsg(l_module_name,'p_location_id : '||p_location_id);
       wsh_debug_sv.logmsg(l_module_name,'p_object2_id  : '||p_object2_id);
    END IF;
    --

    l_region_hash_str :=  p_location_id  ||'-'
		        || p_object2_id  ||'-'
	                || p_constraint_type;

    l_region_hash_val := dbms_utility.get_hash_value(
	 		 name => l_region_hash_str,
			 base => l_reg_hash_base,
		         hash_size =>l_reg_hash_size );


        IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'l_region_hash_str : '||l_region_hash_str);
            WSH_DEBUG_SV.logmsg(l_module_name,'l_region_hash_val : '||l_region_hash_val);
        END IF;

        IF (NOT g_regloc_loc_cache.EXISTS(l_region_hash_val)) THEN
	     -- implies entry was not made
	     l_constraint_id := g_loc_reg_not_validated;

	    IF l_debug_on THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,'Location has not been validated before');
            END IF;

	ELSIF (g_regloc_loc_cache(l_region_hash_val).hash_string = l_region_hash_str) THEN
	     -- Implies entry is present there
	     l_constraint_id :=g_regloc_loc_cache(l_region_hash_val).constraint_id;

	ELSE
	     -- A collision has occured;

	   IF l_debug_on THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,'Collision occured while retriving constraint');
           END IF;

	   itr		  := l_region_hash_val+1;
	   l_count	  := g_regloc_loc_cache.COUNT;
	   l_slot_checked := 1;

	   --
	   -- We need to check total slots checked and total number
	   -- of entries present , because in cases where entry is
	   -- not present we will get in an infinite loop.
	   --

	   LOOP

	      EXIT WHEN (g_regloc_loc_cache(itr).hash_string = l_region_hash_str)
			OR (l_slot_checked=l_count);
	      itr:=itr+1;
	      l_slot_checked:=l_slot_checked+1;

	   END LOOP;

	   IF (l_slot_checked = l_count) THEN
	        -- it implies could not find through the cache
	        l_constraint_id := g_loc_reg_not_validated;
	        IF l_debug_on THEN
		   WSH_DEBUG_SV.logmsg(l_module_name,'Location has not been validated before');
		END IF;
           ELSE
	        -- found in the cache.
  	        l_constraint_id := g_regloc_loc_cache(itr).constraint_id;
	   END IF;

        END IF;

    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'l_constraint_id : '||l_constraint_id);
	WSH_DEBUG_SV.pop (l_module_name);
    END IF;
    --

    RETURN l_constraint_id ;

EXCEPTION
WHEN OTHERS THEN

      WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.get_region_constraint');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END get_region_constraint;

/*
For  handling cases where we have both an inclusive constraint and an exclusive constraint
Code change in validate_region_constraint

    If inclusive constraint is found at zone level then
      if the zone table has multiple enteries.
	 LOOP through table of zones to see if COMPLEMENT CONSTRAINT is present
	      if (COMPLEMENT - CONSTRIANT ) then
		 it implies we have both inclusive and exclusive constriant
		 NONE SHOULD APPLY.
		 RETURN .
	      END IF;
	 Iterate through the table
	 END LOOP;
      End if
     End if
*/
--========================================================================
--
--========================================================================
-- PROCEDURE : validate_region_constraint        PRIVATE
--
-- PARAMETERS:
--             p_location_id              Constraint Object1 id
--             p_constraint_type          Constraint Type : Exclusive/Inclusive
--             p_object2_val_num          Constraint Object2 id
--             x_validate_result          Constraint Validation result : S / E / W
--             x_failed_constraint        failed constraint id in case of failure, null if success
--             x_return_status            Return status
-- COMMENT   :
--      This is an internal procedure to determine if exclusive region/zone facility
--      constraint  has been defined for a given Region/Zone and facility
--      This procedure is called from WSH_FTE_COMP_CONSTRAINT_PKG.validate_constraint.
--      The procedure First validates Region Level Constraints and then Zone
--      Level constraints.
--========================================================================

PROCEDURE validate_region_constraint(
             p_location_id              IN	      NUMBER   DEFAULT NULL,
	     p_constraint_type          IN	      VARCHAR2 DEFAULT 'E',
	     p_object2_val_num          IN	      NUMBER   DEFAULT NULL,
	     x_validate_result          OUT NOCOPY    VARCHAR2,
             x_failed_constraint        OUT NOCOPY    line_constraint_rec_type,
             x_return_status            OUT NOCOPY    VARCHAR2)
IS
    l_region_tab         WSH_UTIL_CORE.ID_TAB_TYPE;
    l_zone_tab		 WSH_UTIL_CORE.ID_TAB_TYPE;
    l_module_name        CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'validate_region_constraint';
    l_debug_on           CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
    l_comp_class_code    CONSTANT VARCHAR2(30) := G_REGION_FACILITY;
    l_complement_constraint_type  VARCHAR2(1);
    l_comp_const_exists           BOOLEAN :=FALSE;

    l_hash_value         NUMBER;
    l_comp_class_id      NUMBER:=0;
    l_master_org_id      NUMBER:=0;
    r_itr		 NUMBER;
    z_itr                NUMBER;
    c_itr		 NUMBER;

    l_object1_id         NUMBER:=0;
    l_object2_id         NUMBER:=p_object2_val_num;
    l_zone_id            NUMBER;
    l_region_id          NUMBER;
    c_zone_id		 NUMBER;
    c_zone_hash_value	 NUMBER;
    c_zone_hash_string   VARCHAR2(200);
    l_reg_hash_string    VARCHAR2(200);
    l_reg_hash_value	 NUMBER;
    l_zone_hash_string   VARCHAR2(200);
    l_zone_hash_value    NUMBER;

    l_constraint_id	 NUMBER;
    l_return_status      VARCHAR2(1);

BEGIN

        IF l_debug_on THEN
          WSH_DEBUG_SV.push(l_module_name);
          WSH_DEBUG_SV.logmsg(l_module_name,'Location Id       '||p_location_id);
          WSH_DEBUG_SV.logmsg(l_module_name,'Object2 val num : '||p_object2_val_num);
        END IF;

        x_return_status   := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
        x_validate_result := 'S';

        l_hash_value := dbms_utility.get_hash_value(
                                  name => l_comp_class_code,
                                  base => g_hash_base,
                                  hash_size =>g_hash_size );

        IF NOT (g_comp_class_tab.EXISTS(l_hash_value) AND
             g_comp_class_tab(l_hash_value).compatibility_class_code = l_comp_class_code) THEN

             populate_constraint_cache(
	 	p_comp_class_code  =>  l_comp_class_code,
	        x_return_status    =>  l_return_status) ;

            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                   raise FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            END IF;

	    --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Return status after calling populate_constraint_cache  : '||l_return_status);
            END IF;
            --
        END IF;

        --
        -- Check in the Hash, If found in the cache then Return.
 	-- Passing the validation parameters.
        --

 	l_constraint_id := get_region_constraint(
		          p_location_id	    => p_location_id
		       ,  p_object2_id	    => l_object2_id
		       ,  p_constraint_type => p_constraint_type
		       ,  x_return_status   => l_return_status);


        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

        --
	-- Exclusive constraint is present.
	-- Cache stores exclusive constriants that have been validated.
	--


	IF  (l_constraint_id <> g_loc_reg_not_validated) THEN

	   IF  (l_constraint_id <> g_const_not_present) THEN

		x_validate_result := g_comp_class_tab(l_hash_value).constraint_violation;
                x_failed_constraint.constraint_id := l_constraint_id;
                x_failed_constraint.constraint_class_code := l_comp_class_code;
                x_failed_constraint.violation_type := g_comp_class_tab(l_hash_value).constraint_violation;

	   END IF;
	   --
           IF l_debug_on THEN
		 IF (l_constraint_id = g_const_not_present) THEN
		     wsh_debug_sv.logmsg(l_module_name,'Region level constraints not present for location '||p_location_id);
		 ELSE
  	             wsh_debug_sv.logmsg(l_module_name,'Region level constraint '||l_constraint_id||' present for location '||p_location_id);
		 END IF;
		 WSH_DEBUG_SV.pop(l_module_name);
	   END IF;
           --
   	   RETURN;

	END IF;

	IF l_debug_on THEN
	    wsh_debug_sv.logmsg(l_module_name,'Validating Region/Zone level constraints for location '||p_location_id);
	END IF;


	l_comp_class_id := g_comp_class_tab(l_hash_value).compatibility_class_id;


	WSH_REGIONS_SEARCH_PKG.Get_All_RegionId_Matches(
		 p_location_id		=> p_location_id,
		 p_use_cache		=> TRUE,
		 p_lang_code		=> USERENV('LANG'),
		 x_region_tab		=> l_region_tab,
		 x_return_status        => l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

	--
	r_itr:= l_region_tab.FIRST;

	IF r_itr IS NOT NULL THEN
	    LOOP
          	-- Object id is the current region id
		l_region_id 	    := l_region_tab(r_itr);

		IF l_debug_on THEN
			wsh_debug_sv.logmsg(l_module_name,'Validating for Region :'||l_region_id);
		END IF;

		l_reg_hash_string   :=   l_comp_class_id||'-'
	    	                      ||'REG'||'-'
				      ||l_region_id||'-'
				      ||(-9999)||'-'
				      ||'FAC'||'-'
                                      || to_char(l_object2_id)||'-'
                                      ||(-9999);

	        l_reg_hash_value := dbms_utility.get_hash_value(
					name => l_reg_hash_string,
	                                base => g_hash_base,
		                        hash_size =>g_hash_size);

		IF check_cache(l_reg_hash_value,l_reg_hash_string) THEN

			IF g_comp_constraint_tab(l_reg_hash_value).constraint_type = p_constraint_type THEN
		             x_validate_result := g_comp_class_tab(l_hash_value).constraint_violation;
                             x_failed_constraint.constraint_id := g_comp_constraint_tab(l_reg_hash_value).compatibility_id;
                             x_failed_constraint.constraint_class_code := l_comp_class_code;
                             x_failed_constraint.violation_type := g_comp_class_tab(l_hash_value).constraint_violation;

			     --
			     -- We have a constraint for the location which we need to
			     -- add to our region constraint cache.
			     --
			     add_region_constraint(
				  p_location_id	       => p_location_id
			 	 ,p_object2_id	       => l_object2_id
				 ,p_constraint_id      => g_comp_constraint_tab(l_reg_hash_value).compatibility_id
				 ,p_constraint_type    => p_constraint_type
				 ,x_return_status      => l_return_status);

			      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
				   raise FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			     END IF;

			     IF l_debug_on THEN
			           wsh_debug_sv.pop(l_module_name);
			     END IF;
			     RETURN;

			END IF;
                END IF;

                -- l_object1_id currently holds the region id
		WSH_REGIONS_SEARCH_PKG.Get_All_Zone_Matches(
			p_region_id		=> l_region_id,
			x_zone_tab		=> l_zone_tab,
			x_return_status         => l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	          IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
		      raise FND_API.G_EXC_UNEXPECTED_ERROR;
	          END IF;
  	        END IF;

		z_itr:= l_zone_tab.FIRST;
		-- Region may not belong to any zone.
    	        IF z_itr IS NOT NULL THEN
		LOOP
		      l_zone_id 	    := l_zone_tab(z_itr);

		      IF l_debug_on THEN
			  wsh_debug_sv.logmsg(l_module_name,'Validating for Zone :'||l_zone_id);
		      END IF;

		      l_zone_hash_string    := l_comp_class_id||'-'
	    	                               ||'ZON'||'-'
				               ||l_zone_id||'-'
				               || (-9999)||'-'
				               ||'FAC'||'-'
                                               ||to_char(l_object2_id)||'-'
                                               ||(-9999);

		      l_zone_hash_value := dbms_utility.get_hash_value(
					name => l_zone_hash_string,
	                                base => g_hash_base,
		                        hash_size =>g_hash_size);


		       IF check_cache(l_zone_hash_value,l_zone_hash_string) THEN
			  IF g_comp_constraint_tab(l_zone_hash_value).constraint_type = p_constraint_type THEN

			     --	It implies  a constraint has been found.
			     -- Check if we have constraint of another type.
			     --

 			     IF (l_zone_tab.COUNT > 1) THEN

				l_comp_const_exists :=FALSE;

				IF (p_constraint_type ='E') THEN
				    l_complement_constraint_type :='I';
			        ELSE
				    l_complement_constraint_type :='E';
			        END IF;

				c_itr := l_zone_tab.FIRST;

  				LOOP
				   c_zone_id := l_zone_tab(c_itr);
				   c_zone_hash_string := l_comp_class_id||'-'
		    	                               ||'ZON'||'-'
					               || c_zone_id||'-'
					               || (-9999)||'-'
					               ||'FAC'||'-'
						       ||to_char(l_object2_id)||'-'
			                               ||(-9999);

				   c_zone_hash_value := dbms_utility.get_hash_value(
							name => c_zone_hash_string,
							base => g_hash_base,
							hash_size =>g_hash_size);

				   IF check_cache(c_zone_hash_value,c_zone_hash_string) THEN
				      IF g_comp_constraint_tab(c_zone_hash_value).constraint_type = l_complement_constraint_type THEN
				        -- Both inclusive and exclusive constraints have been defined
					IF l_debug_on THEN
				            WSH_DEBUG_SV.logmsg(l_module_name,'Both Inclusive and Exclusive Zone level constraints defined for location'||p_location_id);
					END IF;
	       			        l_comp_const_exists:= TRUE;
					EXIT;
				       END IF;
			 	   END IF;

			          EXIT WHEN c_itr = l_zone_tab.LAST;
			          c_itr:= l_zone_tab.NEXT(c_itr);
				  END LOOP;

				END IF;

			        --
				--If complement constraint exist it means we need to
	  		        --check the next level
				--

				IF NOT(l_comp_const_exists) THEN
					x_validate_result := g_comp_class_tab(l_hash_value).constraint_violation;
					x_failed_constraint.constraint_id := g_comp_constraint_tab(l_zone_hash_value).compatibility_id;
	                                x_failed_constraint.constraint_class_code := l_comp_class_code;
		                        x_failed_constraint.violation_type := g_comp_class_tab(l_hash_value).constraint_violation;

			           add_region_constraint(
			     	        p_location_id	       => p_location_id
			 	       ,p_object2_id	       => l_object2_id
				       ,p_constraint_id      => g_comp_constraint_tab(l_zone_hash_value).compatibility_id
				       ,p_constraint_type    => p_constraint_type
				       ,x_return_status      => l_return_status);


                	  	   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
				     IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
				        raise FND_API.G_EXC_UNEXPECTED_ERROR;
				     END IF;
			           END IF;

		 	           IF l_debug_on THEN
				      wsh_debug_sv.pop(l_module_name);
                                   END IF;
  		            	   RETURN;
				END IF;	--not (l_comp_const_exist)
			    END IF;
                        END IF;

		 EXIT WHEN z_itr = l_zone_tab.LAST;
                 z_itr:= l_zone_tab.NEXT(z_itr);
	         END LOOP;
   	         END IF;

	    EXIT WHEN r_itr = l_region_tab.LAST;
            r_itr:= l_region_tab.NEXT(r_itr);
	END LOOP;
    END IF;

    --
    -- If we reach here we do not have any constraint present
    -- between location and the object.
    --
    IF l_debug_on THEN
	wsh_debug_sv.logmsg(l_module_name,'No Region/Zone level constraint present for location :'||p_location_id);
    END IF;

    add_region_constraint(
			  p_location_id	       => p_location_id
		 	 ,p_object2_id	       => l_object2_id
			 ,p_constraint_id      => g_const_not_present
			 ,p_constraint_type    => p_constraint_type
			 ,x_return_status      => l_return_status);

    IF l_debug_on THEN
        wsh_debug_sv.pop(l_module_name);
    END IF;

EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;

      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,'unexpected_error');
      END IF;
      --
WHEN OTHERS THEN
      --
      WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.validate_region_constraint');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,'unexpected_error');
      END IF;

      --
END validate_region_constraint;



/*
For handling both inclusive and exclusive constraints
strategy  is before adding Zone in the ERROR stack see
whether any exclusive constriant exist for that location.
Chagne has to be made at this point only.

Suppose we have zone A, B
For zone A should include FAC X,
    zone B should not include FAC X
Only in such a case the constraints should cancel out,
In cases zone A should include FAC Y
  	 zone B should not include FAC X
Constraint should not cancel.

Pseudo Code -

For Zone -

1) After iterating through Zone Cache, if we find an Inclusive Constraint
   that has not been satisfied, then store the facility id in variable 'K'

   IF NUMBER of Zones for the region is greater than 1
      Make the Hash String of the type
		(Zone-in-tab),FAC - K, Exclusive
      Search in the cache, if found in the cache it implies we have both
      an inclusive and exclusive constraint.
      Change status found to found, and Validation Result to 'S'
   END LOOP;
*/
--***************************************************************************--
--
--========================================================================
-- PROCEDURE : check_reg_incl_facilities PRIVATE
--
-- PARAMETERS:
--             p_entity_type              Entity for which check is running
--             p_entity_id                Entity id for which check is running
--             p_location_id              Constraint Object1 id
--             p_location_list            Table of location ids to be checked as
--                                        constraint object 2
--             x_validate_result          Constraint Validation result : S / E / W
--             x_failed_constraint        failed constraint table
--             x_return_status            Return status
-- COMMENT   :
-- For a given location id , the procedure will validate for must use
-- constraints against a list of locations.
--========================================================================

PROCEDURE check_reg_incl_facilities(
            p_entity_type              IN      VARCHAR2,
            p_entity_id                IN      NUMBER,
            p_location_id              IN      NUMBER,
            p_location_list            IN      WSH_UTIL_CORE.id_tab_type,
            x_validate_result          OUT NOCOPY     VARCHAR2,
            x_failed_constraint        IN  OUT NOCOPY  line_constraint_tab_type,
            x_return_status            OUT NOCOPY     VARCHAR2)
IS

   l_hash_value           NUMBER;
   l_validate_result      VARCHAR2(1);
   l_region_tab           WSH_UTIL_CORE.ID_TAB_TYPE;
   l_zone_tab		  WSH_UTIL_CORE.ID_TAB_TYPE;
   l_comp_class_code      VARCHAR2(30) := G_REGION_FACILITY;
   l_reg_comp_class_id    NUMBER :=0;

   r_itr		  NUMBER :=0;
   z_itr                  NUMBER :=0;
   itr                    NUMBER :=0;

   failed_cons_last       NUMBER := x_failed_constraint.COUNT;
   l_fail_rec_cont        NUMBER :=0;

   l_constraint_found     BOOLEAN :=FALSE;
   l_region_id		  NUMBER  :=0;
   l_reg_hash_string	  VARCHAR2(200);
   l_reg_hash_str_const   VARCHAR2(200);
   l_reg_hash_value	  NUMBER;

   l_constraint_id        NUMBER;


   add_constraint	   BOOLEAN;
   l_fac_id		   NUMBER;
   ex_itr		   NUMBER;
   ex_zone_id		   NUMBER;
   l_zone_hash_excl_string VARCHAR2(200);
   l_zone_hash_excl_value  NUMBER;


   l_zone_id              NUMBER :=0;
   l_zone_hash_string     VARCHAR2(200);
   l_zone_hash_str_const  VARCHAR2(200);
   l_zone_hash_value      NUMBER;

   l_return_status        VARCHAR2(1);

   l_module_name          CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME ||'.'||'check_reg_incl_facilities';
   l_debug_on             CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;

BEGIN

    x_return_status   := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    x_validate_result := 'F';
    l_validate_result := 'F';

    IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name);
      WSH_DEBUG_SV.logmsg(l_module_name,'Object 1 Location id  : '||p_location_id);
      WSH_DEBUG_SV.logmsg(l_module_name,'Location list  count  : '||p_location_list.count);
    END IF;

    -- Check whether NO inclusive constriant occurs for the given location id
    -- If NO constraints found then return with status 'S'

    l_constraint_id := get_region_constraint(
			 p_location_id	 => p_location_id
		       , p_object2_id	 => g_const_not_present
		       , p_constraint_type => 'I'
		       , x_return_status   => l_return_status);


    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
    END IF;


    IF (l_constraint_id = g_incl_cons_not_present) THEN
        -- No constraint present for the location
        x_validate_result := 'S';

	IF l_debug_on THEN
	  WSH_DEBUG_SV.logmsg(l_module_name,'No REG/ZON Inclusive constraints defined for location - '||p_location_id);
	  wsh_debug_sv.pop(l_module_name);
	END IF;

	RETURN;
    END IF;

    --
    -- Populate REG-FAC cache.
    --

    l_hash_value := dbms_utility.get_hash_value(
                             name => l_comp_class_code,
                             base => g_hash_base,
                             hash_size =>g_hash_size);

    IF NOT (g_comp_class_tab.EXISTS(l_hash_value) AND
            g_comp_class_tab(l_hash_value).compatibility_class_code = l_comp_class_code) THEN

       populate_constraint_cache(
          p_comp_class_code          =>    l_comp_class_code,
          x_return_status            =>    l_return_status) ;

      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Called populate_constraint_cache return status : '||l_return_status);
      END IF;
      --

      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

    END IF;

    l_reg_comp_class_id := g_comp_class_tab(l_hash_value).COMPATIBILITY_CLASS_ID;

    WSH_REGIONS_SEARCH_PKG.Get_All_RegionId_Matches(
	 p_location_id		=> p_location_id,
	 p_use_cache		=> TRUE,
	 p_lang_code		=> USERENV('LANG'),
	 x_region_tab		=> l_region_tab,
	 x_return_status        => l_return_status);

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
    END IF;

    -- ITERATE THROUGH THE REGION TAB.
    r_itr:= l_region_tab.FIRST;

    l_fail_rec_cont := failed_cons_last;

    IF (r_itr IS NOT NULL) THEN

	LOOP

	    l_region_id          := l_region_tab(r_itr);

	    IF l_debug_on THEN
		   wsh_debug_sv.logmsg(l_module_name,'Validating inclusive constraints for Region :'||l_region_id);
	    END IF;

	    l_reg_hash_str_const := l_reg_comp_class_id||'-'
	    	                   ||'REG'||'-'
				   ||l_region_id||'-'
				   ||(-9999)||'-'
				   ||'FAC'||'-' ;

	    itr := p_location_list.FIRST;

            IF itr IS NOT NULL THEN
     	       LOOP
		  --
		  IF l_debug_on THEN
		     WSH_DEBUG_SV.logmsg(l_module_name,'p_location_list  : '||p_location_list(itr));
		  END IF;
	          --
	          l_reg_hash_string:=l_reg_hash_str_const||(p_location_list(itr))||'-'||(-9999);

		  l_reg_hash_value := dbms_utility.get_hash_value(
	                                  name => l_reg_hash_string,
		                          base => g_hash_base,
			                  hash_size =>g_hash_size );
		  --
		  IF l_debug_on THEN
		     WSH_DEBUG_SV.logmsg(l_module_name,'l_reg_hash_string : '||l_reg_hash_string);
		     WSH_DEBUG_SV.logmsg(l_module_name,'l_reg_hash_value  : '||l_reg_hash_value);
		  END IF;
	          --

		  IF check_cache(l_reg_hash_value,l_reg_hash_string) THEN
		      IF g_comp_constraint_tab(l_reg_hash_value).constraint_type = 'I' THEN
		           x_validate_result := 'S';
		           l_validate_result := 'S';
			   l_constraint_found:= TRUE;

			   IF l_debug_on THEN
			      wsh_debug_sv.logmsg(l_module_name,'Inclusive Constraint Found ');
			   END IF;

			   EXIT;
		       END IF;
		  END IF;

		  EXIT WHEN itr =p_location_list.LAST;
	     	  itr := p_location_list.NEXT(itr);

	       END LOOP;
            END IF;

            IF NOT (l_constraint_found) THEN

	    -- Implies constraint was not found
	    -- Loop over the constraints table , with current region id

                IF (nvl(g_reg_const_cache.count,0)=0) THEN

			populate_reg_mustuse_cache(
			          p_reg_class_id  => l_reg_comp_class_id,
			          x_return_status => l_return_status);
                	--
                        IF l_debug_on THEN
                              WSH_DEBUG_SV.logmsg(l_module_name,'Called populate_reg_mustuse_cache return status:'||l_return_status);
                        END IF;
                        --

                        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
                              END IF;
                        END IF;
		END IF;

		itr := g_reg_const_cache.FIRST;

		IF itr IS NOT NULL THEN
		    LOOP
		       IF l_debug_on THEN
		          WSH_DEBUG_SV.logmsg(l_module_name,' Itr : '||itr);
		       END IF;

		       IF  g_reg_const_cache(itr).CONSTRAINT_OBJECT1_TYPE = 'REG' AND
                           g_reg_const_cache(itr).CONSTRAINT_OBJECT1_ID = l_region_id
       		       THEN
	                   --
			   IF l_debug_on THEN
		                WSH_DEBUG_SV.logmsg(l_module_name,' Input has  Inclusive constraint: '||g_reg_const_cache(itr).compatibility_id);
		           END IF;
		           --
	                   l_fail_rec_cont  := l_fail_rec_cont + 1;
	   	           x_failed_constraint(l_fail_rec_cont).constraint_id  := g_reg_const_cache(itr).compatibility_id;
		           x_failed_constraint(l_fail_rec_cont).entity_type    := p_entity_type;
		           x_failed_constraint(l_fail_rec_cont).entity_line_id := p_entity_id;
		           x_failed_constraint(l_fail_rec_cont).constraint_class_code := G_REGION_FACILITY;
			   x_failed_constraint(l_fail_rec_cont).violation_type := g_comp_class_tab(l_hash_value).constraint_violation;
			   l_validate_result := g_comp_class_tab(l_hash_value).constraint_violation;
		           l_constraint_found :=TRUE;

                       END IF;

		       EXIT WHEN itr=g_reg_const_cache.LAST;
		       itr := g_reg_const_cache.NEXT(itr);
	            END LOOP;
                END IF;

	     END IF; --(If NOT (l_constraint_found) THEN )

             --Check for the zone level constraint
	     --Inclusive zone level constraints to be treated as OR.

	     IF NOT(l_constraint_found) THEN

		  IF l_debug_on THEN
		     WSH_DEBUG_SV.logmsg(l_module_name,' Calling WSH_REGIONS_SEARCH_PKG.Get_All_Zone_Matches ');
		  END IF;
		  WSH_REGIONS_SEARCH_PKG.Get_All_Zone_Matches(
			 p_region_id		=> l_region_id,
			 x_zone_tab		=> l_zone_tab,
			 x_return_status        => l_return_status);

		 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
		      raise FND_API.G_EXC_UNEXPECTED_ERROR;
	           END IF;
		 END IF;

	         z_itr:= l_zone_tab.FIRST;

                  -- Check if zone level constraints are present.

		 IF (z_itr IS NOT NULL) THEN

		     LOOP

			l_zone_id := l_zone_tab(z_itr);

  		        IF l_debug_on THEN
			    wsh_debug_sv.logmsg(l_module_name,'Validating inclusive constraints for Zone :'||l_zone_id);
			END IF;

			l_zone_hash_str_const := l_reg_comp_class_id||'-'
		     				 ||'ZON'||'-'
                                 		 ||l_zone_id||'-'
					         ||(-9999)||'-'
					         ||'FAC'||'-';

		        IF l_debug_on THEN
		           WSH_DEBUG_SV.logmsg(l_module_name,'Zone hash constant is : '||l_zone_hash_str_const);
		        END IF;

			itr := p_location_list.FIRST;

			IF itr IS NOT NULL THEN
	     	           LOOP
			     --
			     IF l_debug_on THEN
			         WSH_DEBUG_SV.logmsg(l_module_name,'p_location_list  : '||p_location_list(itr));
			     END IF;
			     --
			     l_zone_hash_string:=l_zone_hash_str_const ||(p_location_list(itr))||'-'||(-9999);

	   		     l_zone_hash_value := dbms_utility.get_hash_value(
 		                              name => l_zone_hash_string,
				              base => g_hash_base,
			                      hash_size =>g_hash_size );
                	      --
   			      IF l_debug_on THEN
			          WSH_DEBUG_SV.logmsg(l_module_name,'l_zone_hash_string : '||l_zone_hash_string);
		                  WSH_DEBUG_SV.logmsg(l_module_name,'l_zone_hash_value  : '||l_zone_hash_value);
       		              END IF;
                              --

		              IF check_cache(l_zone_hash_value,l_zone_hash_string) THEN
			        IF g_comp_constraint_tab(l_zone_hash_value).constraint_type = 'I' THEN
				   x_validate_result := 'S';
  		                   l_validate_result := 'S';
				   l_constraint_found:= TRUE;

				   IF l_debug_on THEN
				      wsh_debug_sv.logmsg(l_module_name,'Inclusive Constraint Found');
				   END IF;
				   EXIT;
	                        END IF;
		              END IF;

			      EXIT WHEN itr =p_location_list.LAST;
                       	      itr := p_location_list.NEXT(itr);
 		           END LOOP;
		   	 END IF;

		         EXIT WHEN z_itr =l_zone_tab.LAST;
		         z_itr := l_zone_tab.NEXT(z_itr);

		      END LOOP;


		      IF NOT (l_constraint_found) THEN
		      -- loop over the zones against locations to check the constraints
                      z_itr:= l_zone_tab.FIRST;

                      LOOP
	  	           l_zone_id := l_zone_tab(z_itr);
			   itr := g_reg_const_cache.FIRST;

                       	   IF itr IS NOT NULL THEN
		           LOOP

				IF  g_reg_const_cache(itr).CONSTRAINT_OBJECT1_TYPE = 'ZON' AND
                                    g_reg_const_cache(itr).CONSTRAINT_OBJECT1_ID   = l_zone_id
		                THEN
	            	            --
                		    IF l_debug_on THEN
		                      WSH_DEBUG_SV.logmsg(l_module_name,' Zone :'||l_zone_id||' for Input has constraint:(Check for INCL/EXCL constraint '||g_reg_const_cache(itr).compatibility_id);
		                    END IF;

				    add_constraint := TRUE;

				    --Check whether any exclusive constraint occurs ZONES In the location and the FACILITY.
				    --If exists then it is not a  failed constraint, set add_constraint to FALSE appropriately.

				    IF (l_zone_tab.count > 1 ) THEN

					l_fac_id := g_reg_const_cache(itr).CONSTRAINT_OBJECT2_ID;

					ex_itr := l_zone_tab.FIRST;

					LOOP

					  ex_zone_id := l_zone_tab(ex_itr);

					  IF (ex_zone_id <> l_zone_id) THEN

						l_zone_hash_excl_string := l_reg_comp_class_id||'-'
				     					  ||'ZON'||'-'
		                                 			  ||ex_zone_id||'-'
								          ||(-9999)||'-'
								          ||'FAC'||'-'
							  	          ||to_char(l_fac_id)||'-'
			        		                          ||(-9999);

						l_zone_hash_excl_value := dbms_utility.get_hash_value(
			 		                              name => l_zone_hash_excl_string,
							              base => g_hash_base,
								      hash_size =>g_hash_size );


					       IF check_cache(l_zone_hash_excl_value,l_zone_hash_excl_string) THEN
					          IF g_comp_constraint_tab(l_zone_hash_excl_value).constraint_type = 'E' THEN
							-- both inclusive and excluive constraint is present.
							-- Need not enter the constriant in the list.
							IF l_debug_on THEN
							    wsh_debug_sv.logmsg(l_module_name,'Both inclusive and exclusive constraint found for the location ');
							END IF;
							add_constraint := FALSE;
							EXIT;
					          END IF;
					       END IF;

					   END IF;

					  EXIT WHEN ex_itr = l_zone_tab.LAST;
					  ex_itr:= l_zone_tab.NEXT(ex_itr);
					END LOOP;
				    END IF;

				    --
                		    -- Add to the x_failed_constraint if add_constraint is TRUE;
				    --
		                    IF (add_constraint) THEN

					    l_fail_rec_cont := l_fail_rec_cont + 1;
				            x_failed_constraint(l_fail_rec_cont).constraint_id := g_reg_const_cache(itr).compatibility_id;
               		                    x_failed_constraint(l_fail_rec_cont).entity_type   := p_entity_type;
				            x_failed_constraint(l_fail_rec_cont).entity_line_id:= p_entity_id;
					    x_failed_constraint(l_fail_rec_cont).constraint_class_code := G_REGION_FACILITY;
	                		    x_failed_constraint(l_fail_rec_cont).violation_type := g_comp_class_tab(l_hash_value).constraint_violation;
				            l_validate_result := g_comp_class_tab(l_hash_value).constraint_violation;
			                    l_constraint_found :=TRUE;
				    END IF;

				END IF;

				EXIT WHEN itr=g_reg_const_cache.LAST;
		                itr := g_reg_const_cache.NEXT(itr);

			     END LOOP;
                             END IF;

			EXIT WHEN z_itr=l_zone_tab.LAST;
		        z_itr := l_zone_tab.NEXT(z_itr);
			END LOOP;

	 	  END IF;
		END IF;-- (zone itr  is not null)
             END IF;  -- (if not constraint FOUND);

	 EXIT WHEN (r_itr = l_region_tab.LAST) OR (l_constraint_found);

	 r_itr:= l_region_tab.NEXT(r_itr);

	 END LOOP;
      END IF;


      IF NOT l_constraint_found THEN
   	  x_validate_result := 'S';

	  -- Maintain the location ID as no constraint is present
	  -- at REGION and ZONE level

	   IF l_debug_on THEN
		   wsh_debug_sv.logmsg(l_module_name,'No Inclusive Region/Zone constraint present for location '||p_location_id);
	   END IF;

	   add_region_constraint(
	          p_location_id	       => p_location_id
	 	 ,p_object2_id	       => g_const_not_present
		 ,p_constraint_id      => g_incl_cons_not_present
		 ,p_constraint_type    => 'I'
		 ,x_return_status      => l_return_status);


            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                   raise FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            END IF;

      ELSE

	  IF l_validate_result = 'W' THEN
             x_validate_result := 'W';
          END IF;

      END IF;

      IF l_debug_on THEN
         wsh_debug_sv.pop(l_module_name);
      END IF;

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
      WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.check_reg_incl_facilities');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
END check_reg_incl_facilities;


--***************************************************************************--
--
--========================================================================
-- PROCEDURE : validate_constraint        PRIVATE
--
-- PARAMETERS: p_comp_class_code          Compatibility class code
--             p_constraint_type          Constraint Type : Exclusive / Inclusive
--             p_object1_type	          Constraint Object1 Type
--             p_object1_parent_id        Constraint Object1 Parent id
--                                        Required only if object1 = Item
--             p_object1_val_num          Constraint Object1 id
--             p_object1_val_char         Constraint Object1 character code
--             p_object1_physical_id      Physical Location Id - Passed in only for CUS_FAC for Customer Facility
--             p_object2_type	          Constraint Object2 Type
--             p_object2_parent_id        Constraint Object2 Parent id
--             p_object2_val_num          Constraint Object2 id
--             p_object2_val_char         Constraint Object2 character code
--                                        Currently used for Mode of Transport code only
--             p_direct_shipment          Is the shipment multileg
--             x_validate_result          Constraint Validation result : S / E / W
--             x_failed_constraint        failed constraint id in case of failure, null if success
--             x_return_status            Return status
-- COMMENT   :
--      This is an internal procedure to determine if two objects
--      have a constraint defined between them under the scope of a particular compatibility class
--      Hence, returns constraint severity
--      1. Passed I : if a constraint for this combination exists of type 'I'
--      2. Passed E : if a constraint for this combination exists of type 'E'

--      Assumes object1 and object2 have been passed as the class requires/defines
--========================================================================

PROCEDURE validate_constraint(
             p_comp_class_code          IN      VARCHAR2,
             p_constraint_type          IN      VARCHAR2 DEFAULT 'E',
             p_object1_type	        IN      VARCHAR2 DEFAULT NULL,
             p_object1_parent_id        IN      NUMBER   DEFAULT NULL,
             p_object1_val_char         IN      VARCHAR2 DEFAULT NULL,
             p_object1_val_num          IN      NUMBER   DEFAULT NULL,
             p_object1_physical_id	IN	NUMBER	 DEFAULT NULL,
	         p_object2_type	        IN      VARCHAR2 DEFAULT NULL,
             p_object2_parent_id        IN      NUMBER   DEFAULT NULL,
             p_object2_val_char         IN      VARCHAR2 DEFAULT NULL,
             p_object2_val_num          IN      NUMBER   DEFAULT NULL,
             p_direct_shipment          IN      BOOLEAN  DEFAULT FALSE,
             x_validate_result          OUT NOCOPY    VARCHAR2,
             x_failed_constraint        OUT NOCOPY    line_constraint_rec_type,
             x_return_status            OUT NOCOPY    VARCHAR2)
IS

    l_return_status    VARCHAR2(1);

    l_location_id       NUMBER:=0;
    l_master_org_id     NUMBER:=0;
    l_carrier_id        NUMBER:=0;
    --l_customer_id       NUMBER:=0;
    l_customer_id_tab   WSH_UTIL_CORE.id_tab_type;
    l_supplier_id       NUMBER:=0;
    l_object1_type      VARCHAR2(30):=NULL;
    l_object1_id        NUMBER:=0;
    l_object1_parent_id NUMBER:=p_object1_parent_id;
    l_object2_type      VARCHAR2(30):=NULL;
    l_object2_id        NUMBER:=0;
    l_object2_val_char  VARCHAR2(30):=NULL;
    l_object1_typesub   VARCHAR2(30):=NULL;
    l_object2_typesub   VARCHAR2(30):=NULL;
    l_comp_type1        VARCHAR2(3) := SUBSTR(p_comp_class_code,1,3);
    l_comp_type2        VARCHAR2(3) := SUBSTR(p_comp_class_code,5,3);

    l_comp_class_id     NUMBER:=0;
    l_hash_value        NUMBER;
    l1_hash_value       NUMBER;
    l11_hash_value      NUMBER;
    l_hash_active       NUMBER;
    l2_hash_value       NUMBER;
    l3_hash_value       NUMBER;
    l4_hash_value       NUMBER;
    l1_hash_string      VARCHAR2(200);
    l11_hash_string     VARCHAR2(200);
    l2_hash_string      VARCHAR2(200);
    l3_hash_string      VARCHAR2(200);
    l4_hash_string      VARCHAR2(200);
    l_itm_hash_value    NUMBER;
    l_itm_hash_string   VARCHAR2(200);
    l_fac_hash_value    NUMBER;
    l_fac_hash_string   VARCHAR2(200);

    --DUM_LOC(S)
    l_organization_tab  WSH_UTIL_CORE.id_tab_type;
    l_org_itr		NUMBER;
    itr                 NUMBER :=0;
    --DUM_LOC(E)

    l_module_name       CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'validate_constraint';
    l_debug_on          CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;

BEGIN

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    x_validate_result := 'S';

    IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name);
      WSH_DEBUG_SV.logmsg(l_module_name,'Input comp class code : '||p_comp_class_code);
      WSH_DEBUG_SV.logmsg(l_module_name,'p_constraint_type : '||p_constraint_type);
      WSH_DEBUG_SV.logmsg(l_module_name,'Input Object1 type : '||p_object1_type);
      WSH_DEBUG_SV.logmsg(l_module_name,'Input Object2 type : '||p_object2_type);
      WSH_DEBUG_SV.logmsg(l_module_name,'Object1 val num : '||p_object1_val_num);
      WSH_DEBUG_SV.logmsg(l_module_name,'Object 1 parent : '||l_object1_parent_id);
      WSH_DEBUG_SV.logmsg(l_module_name,'Object2 val num : '||p_object2_val_num);
      WSH_DEBUG_SV.logmsg(l_module_name,'Object 2 val char : '||p_object2_val_char);
      IF p_direct_shipment THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'p_direct_shipment is true');
      ELSE
       WSH_DEBUG_SV.logmsg(l_module_name,'p_direct_shipment is false');
      END IF;
    END IF;

    --return if object2 is NULL
    IF (p_object1_val_num IS NULL OR (p_object2_val_num IS NULL AND p_object2_val_char IS NULL)) OR
       (p_comp_class_code = G_CUSTOMER_CUSTOMER AND p_object1_val_num = p_object2_val_num) THEN
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Returning x_validate_result : '||x_validate_result);
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
    END IF;

    IF g_is_tp_installed IS NULL THEN
     g_is_tp_installed := WSH_UTIL_CORE.TP_Is_Installed;
    END IF;
    -- Must pass in object types when CLASS code contains FAC

    l_object1_typesub := nvl(p_object1_type,l_comp_type1);
    l_object2_typesub := nvl(p_object2_type,l_comp_type2);


    --#DUM_LOC(S)
/*
     Pseudo Code :

     1) IF p_comp_class_code = G_CUSTOMER_FACILITY, p_object1_type = G_FACILITY
        and (p_object1_physical_id IS NOT NULL) THEN

	- get all the organizations for the location id .
	- Call validate constriant recursively.
	  The moment we find a constraint we return back.
	  We do not do any further validations.

	--AGDUMMY :
	No constraints can exist for a dummy customer facility

     --For Dummy locations we have only ORG-FAC constraints.
*/

    IF (p_comp_class_code = G_CUSTOMER_FACILITY) AND (l_object1_typesub = G_FACILITY)
	AND (p_object1_physical_id IS NOT NULL) THEN

	IF l_debug_on THEN
	   WSH_DEBUG_SV.logmsg(l_module_name,'Validating CUS-FAC constraint for dummy location, Finding corresponding Organizations');
	END IF;

	--get_org_from_location(
	WSH_UTIL_CORE.get_org_from_location(
              p_location_id	  => p_object1_physical_id,
              x_organization_tab  => l_organization_tab,
              x_return_status     => l_return_status);

	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'l_return_status:'||l_return_status);
            WSH_DEBUG_SV.logmsg(l_module_name,'Organizations Returned:'||l_organization_tab.Count);
	END IF;

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
          IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;

	l_org_itr := l_organization_tab.FIRST;

	IF l_org_itr IS NOT NULL THEN
           LOOP
	        IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Organizations id:'||l_organization_tab(l_org_itr));
              WSH_DEBUG_SV.logmsg(l_module_name,'Validating ORG_FAC for the dummy location ');
            END IF;

	        validate_constraint(
                  p_comp_class_code    => G_SHIPORG_FACILITY,
                  p_constraint_type    => p_constraint_type,
	              p_object1_type       => G_COMP_ORG, -- AGDUMMY
                  p_object1_val_num    => l_organization_tab(l_org_itr),
     	          p_object2_type       => p_object2_type,
                  p_object2_val_num    => p_object2_val_num,
                  p_direct_shipment    => p_direct_shipment,
                  x_validate_result    => x_validate_result,
                  x_failed_constraint  => x_failed_constraint,
                  x_return_status      => x_return_status);

	         IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                   IF x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
                 END IF;

		-- When we are getting a constraint at org level we return.
                -- If x_validate_result <> S , it implies a constraint has been
		-- violated.

		EXIT WHEN (x_validate_result <> 'S' OR l_org_itr= l_organization_tab.LAST);
                l_org_itr:= l_organization_tab.NEXT(l_org_itr);

	     END LOOP;
	   END IF;
	   --
	   IF l_debug_on THEN
		 WSH_DEBUG_SV.logmsg(l_module_name,'Validation for CUS-FAC, Dummy locations over');
		 WSH_DEBUG_SV.logmsg(l_module_name,'Returning x_validate_result : '||x_validate_result);
		 WSH_DEBUG_SV.logmsg(l_module_name,'Returning x_return_status :   '||x_return_status);
	     WSH_DEBUG_SV.pop(l_module_name);
	   END IF;
           --
	   RETURN;
     END IF;
    --#DUM_LOC(E)

    IF (l_object1_typesub = 'ITM' AND g_is_tp_installed = 'Y') THEN
       l_object1_parent_id := null;
    END IF;

    -- Check ITM specific exclusive constraint cache s here
    -- If a combination of ITM-CAR/MOD/VEH/FAC cache record exists
    -- get result from that record and return
    -- proceed if does not exist in cache

    IF l_object1_typesub = 'ITM' AND p_constraint_type = 'E' THEN

      l_itm_hash_string :=p_comp_class_code||'-'||nvl(l_object1_parent_id,-9999)||'-'||p_object1_val_num||'-'||nvl(to_char(p_object2_val_num),p_object2_val_char);

      l_itm_hash_value := dbms_utility.get_hash_value(
                                  name => l_itm_hash_string,
                                  base => g_hash_base,
                                  hash_size =>g_hash_size );

      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'l_itm_hash_string : '||l_itm_hash_string);
         WSH_DEBUG_SV.logmsg(l_module_name,'l_itm_hash_value : '||l_itm_hash_value);
      END IF;
      --

      IF g_itm_exclusive_cache.EXISTS(l_itm_hash_value) AND
       g_itm_exclusive_cache(l_itm_hash_value).hash_string = l_itm_hash_string THEN
       -- Found in cache
       x_validate_result := g_itm_exclusive_cache(l_itm_hash_value).validate_result;
          --
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Found in g_itm_exclusive_cache with hash string : '||l_itm_hash_string);
            WSH_DEBUG_SV.logmsg(l_module_name,'Returning x_validate_result : '||x_validate_result);
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          --
          RETURN;  -- Done with as found for the input types

      END IF;
    END IF;

    -- Check FAC specific exclusive constraint cache s here
    -- If a combination of FAC-CAR/MOD/VEH cache record exists
    -- get result from that record and return
    -- proceed if does not exist in cache

    IF l_comp_type1 = 'FAC' AND p_constraint_type = 'E' THEN

      l_fac_hash_string := p_comp_class_code||'-'||l_object1_typesub||'-'||p_object1_val_num||'-'||nvl(to_char(p_object2_val_num),p_object2_val_char);

      l_fac_hash_value := dbms_utility.get_hash_value(
                                name => l_fac_hash_string,
                                base => g_hash_base,
                                hash_size =>g_hash_size );
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'l_fac_hash_string : '||l_fac_hash_string);
         WSH_DEBUG_SV.logmsg(l_module_name,'l_fac_hash_value : '||l_fac_hash_value);
      END IF;
      --

      IF g_fac_exclusive_cache.EXISTS(l_fac_hash_value) AND
       g_fac_exclusive_cache(l_fac_hash_value).hash_string = l_fac_hash_string THEN
       -- Found in cache
       x_validate_result := g_fac_exclusive_cache(l_fac_hash_value).validate_result;
          --
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Found in g_fac_exclusive_cache with hash string : '||l_fac_hash_string);
            WSH_DEBUG_SV.logmsg(l_module_name,'Returning x_validate_result : '||x_validate_result);
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          --
          RETURN;  -- Done with as found for the input types

      END IF;

    END IF;

    -- Alternatively the package can store internal numeric
    -- values for each of the compatibility classes and use that to index the table
    -- which will help avoiding hash creation
    l_hash_value := dbms_utility.get_hash_value(
                                  name => p_comp_class_code,
                                  base => g_hash_base,
                                  hash_size =>g_hash_size );

    -- Hash collision
    --IF NOT g_comp_class_tab.EXISTS(l_hash_value) THEN
    IF NOT (g_comp_class_tab.EXISTS(l_hash_value) AND
            g_comp_class_tab(l_hash_value).compatibility_class_code = p_comp_class_code) THEN

      populate_constraint_cache(
          p_comp_class_code          =>    p_comp_class_code,
          x_return_status            =>    l_return_status) ;

      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Called populate_constraint_cache return status : '||l_return_status);
      END IF;
      --
    END IF;

    l_comp_class_id := g_comp_class_tab(l_hash_value).compatibility_class_id;

    -- For facility specific constraints if type  = facility then need to search only for
    -- constraints in that class for that facility(location), but if the type = company, then
    -- need to check if any constraints exist for that class for any of the locations
    -- being used by that company
    -- A constraint defined for a location applies to all companies using that location ?

    -- First check input combination types, if it has constraint_type = E, return failure
    -- Following special rules apply to facility specific constraints
    -- If not returned failure above :
    -- 1. ORG_FAC : object2_type = FAC, get carrier for input FAC, check
    --              Also check if anything is defined for master ORG if not found for input ORG
    -- 2. CUS_FAC : object1_type = FAC, object2_type = FAC, get carrier for obj2 FAC, check
    --              object1_type = CUS, object2_type = FAC, get carrier for obj2 FAC, check
    -- 3. ITM_FAC : object2_type = FAC, get carrier for obj2 FAC, check
    --                                  get customer for obj2 FAC, check
    --                                  get supplier for obj1 FAC, check
    -- 4. FAC_CAR : object1_type = FAC, get carrier for obj1 FAC, check
    --                                  get customer for obj1 FAC, check
    --                                  get supplier for obj1 FAC, check
    -- 5. FAC_MOD : object1_type = FAC, get carrier for obj1 FAC, check
    --                                  get customer for obj1 FAC, check
    --                                  get supplier for obj1 FAC, check
    -- 6. SUP_FAC : object1_type = FAC, object2_type = FAC, get carrier for obj2 FAC, check
    --              object1_type = SUP, object2_type = FAC, get carrier for obj2 FAC, check
    -- 7. FAC_VEH : object1_type = FAC, get carrier for obj1 FAC, check
    --                                  get customer for obj1 FAC, check
    --                                  get supplier for obj1 FAC, check

    -- When checking above classes with higher level TYPE at FAC side,
    -- ONLY checks existence of an I constraint at that level
    -- ie. does not go down the level to check
    -- though goes up to check for a location if required

    -- Can you have MUST USE at a lower level
    -- and CAN'T USE at a higher level
    -- NO - Does not make sense

    -- Can you have CAN'T USE at a lower level
    -- and MUST USE at a higher level (Means any facility of that parent)
    -- YES -  lower level takes precedence

    -- Need a data structure for hashing constraints
    -- hash by class+obj1 type+obj1+obj1 parent+obj2 type+obj2+obj2 parent
    -- As this combination defines a unique key

    -- Nothing needs to be done when storing the constraint definition
    -- as it will not have organization_id if TP is installed

    l1_hash_string :=        (l_comp_class_id)||'-'||l_object1_typesub||'-'||nvl(       to_char(p_object1_val_num),p_object1_val_char)||'-'||       (nvl(l_object1_parent_id,-9999))||
    '-'||l_object2_typesub||'-'||nvl(       to_char(p_object2_val_num),p_object2_val_char)||'-'||       (nvl(p_object2_parent_id,-9999));


    l1_hash_value := dbms_utility.get_hash_value(
                                  name => l1_hash_string,
                                  base => g_hash_base,
                                  hash_size =>g_hash_size );

    --
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'l1_hash_string : '||l1_hash_string);
       WSH_DEBUG_SV.logmsg(l_module_name,'l1_hash_value : '||l1_hash_value);
    END IF;
    --

    IF p_comp_class_code = G_CUSTOMER_CUSTOMER THEN

      l11_hash_string :=        (l_comp_class_id)||'-'||l_object1_typesub||'-'||to_char(p_object2_val_num)||'-'||(nvl(p_object2_parent_id,-9999))||
      '-'||l_object2_typesub||'-'||to_char(p_object1_val_num)||'-'||(nvl(l_object1_parent_id,-9999));

      l11_hash_value := dbms_utility.get_hash_value(
                                  name => l11_hash_string,
                                  base => g_hash_base,
                                  hash_size =>g_hash_size );

      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'l11_hash_string : '||l11_hash_string);
        WSH_DEBUG_SV.logmsg(l_module_name,'l11_hash_value : '||l11_hash_value);
      END IF;
      --

    ELSIF p_comp_class_code = G_SHIPORG_FACILITY THEN

      WSH_UTIL_CORE.get_master_from_org(
              p_org_id         => p_object1_val_num,
              x_master_org_id  => l_master_org_id,
              x_return_status  => l_return_status);

      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
          IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
          raise g_get_mast_org_failed;
         END IF;
      END IF;

      IF l_master_org_id <> p_object1_val_num THEN -- Input ORG is child of l_master_org_id

         l11_hash_string :=        (l_comp_class_id)||'-'||l_object1_typesub||'-'||to_char(l_master_org_id)||'-'||(nvl(l_object1_parent_id,-9999))||
         '-'||l_object2_typesub||'-'||to_char(p_object2_val_num)||'-'||(nvl(p_object2_parent_id,-9999));

         l11_hash_value := dbms_utility.get_hash_value(
                                  name => l11_hash_string,
                                  base => g_hash_base,
                                  hash_size =>g_hash_size );

         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'l11_hash_string : '||l11_hash_string);
            WSH_DEBUG_SV.logmsg(l_module_name,'l11_hash_value : '||l11_hash_value);
         END IF;
         --

      END IF;

    END IF;

    -- How to handle constraint types in execution (Inclusive / exclusive ?)

    -- For this set of input, check the global table
    -- If the record exists (can be at most one)
    --                      and constraint type = E, return error
    --                      and constraint type = I, return success
    -- If it does not exist : Need to check all the records with obj1
    --                        For each record, construct the hash and cache structure

    IF check_cache(l1_hash_value,l1_hash_string) THEN

       IF g_comp_constraint_tab(l1_hash_value).constraint_type = p_constraint_type THEN
          x_validate_result := g_comp_class_tab(l_hash_value).constraint_violation;
          x_failed_constraint.constraint_id := g_comp_constraint_tab(l1_hash_value).compatibility_id;
          x_failed_constraint.constraint_class_code := p_comp_class_code;
          x_failed_constraint.violation_type := g_comp_class_tab(l_hash_value).constraint_violation;

          -- Create the ITM specific cache for exclusive constraints here
          IF l_object1_typesub = 'ITM' AND p_constraint_type = 'E' THEN

             g_itm_exclusive_cache(l_itm_hash_value).hash_string := l_itm_hash_string ;
             g_itm_exclusive_cache(l_itm_hash_value).comp_class_code := p_comp_class_code ;
             g_itm_exclusive_cache(l_itm_hash_value).item_id := p_object1_val_num ;
             g_itm_exclusive_cache(l_itm_hash_value).itemorg_id := l_object1_parent_id ;
             g_itm_exclusive_cache(l_itm_hash_value).object2_id := p_object2_val_num ;
             g_itm_exclusive_cache(l_itm_hash_value).object2_char := p_object2_val_char ;
             g_itm_exclusive_cache(l_itm_hash_value).validate_result := x_validate_result ;

             --
             IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Created in g_itm_exclusive_cache with hash string : '||l_itm_hash_string);
             END IF;
             --
          END IF;

          -- Create the FAC specific cache for exclusive constraints here
          IF l_comp_type1 = 'FAC' AND p_constraint_type = 'E' THEN

             g_fac_exclusive_cache(l_fac_hash_value).hash_string := l_fac_hash_string ;
             g_fac_exclusive_cache(l_fac_hash_value).comp_class_code := p_comp_class_code ;
             g_fac_exclusive_cache(l_fac_hash_value).object1_type := l_object1_typesub ;
             g_fac_exclusive_cache(l_fac_hash_value).object1_id := p_object1_val_num ;
             g_fac_exclusive_cache(l_fac_hash_value).object2_id := p_object2_val_num ;
             g_fac_exclusive_cache(l_fac_hash_value).object2_char := p_object2_val_char ;
             g_fac_exclusive_cache(l_fac_hash_value).validate_result := x_validate_result ;

             --
             IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Created in g_fac_exclusive_cache with hash string : '||l_fac_hash_string);
             END IF;
             --
          END IF;

          --
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Returning x_validate_result : '||x_validate_result);
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          --

          RETURN;  -- Done with as found for the input types

       END IF;

    ELSIF (p_comp_class_code = G_CUSTOMER_CUSTOMER AND check_cache(l11_hash_value,l11_hash_string)) OR
          (l11_hash_value IS NOT NULL AND p_comp_class_code = G_SHIPORG_FACILITY AND check_cache(l11_hash_value,l11_hash_string)) THEN

       IF g_comp_constraint_tab(l11_hash_value).constraint_type = p_constraint_type THEN
          x_validate_result := g_comp_class_tab(l_hash_value).constraint_violation;
          x_failed_constraint.constraint_id := g_comp_constraint_tab(l11_hash_value).compatibility_id;
          x_failed_constraint.constraint_class_code := p_comp_class_code;
          x_failed_constraint.violation_type := g_comp_class_tab(l_hash_value).constraint_violation;

          --
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Returning x_validate_result : '||x_validate_result);
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          --
          RETURN;  -- Done with as found for the input types

       END IF;

    END IF;

    IF ((p_comp_class_code = G_FACILITY_CARRIER OR p_comp_class_code = G_FACILITY_MODE OR p_comp_class_code = G_FACILITY_VEHICLE) AND
       l_object1_typesub = G_FACILITY) THEN

       l_location_id := p_object1_val_num;

       get_carrier_from_loc(
                   p_location_id    =>  l_location_id,
                   x_carrier_id     =>  l_carrier_id,
                   x_return_status  =>  l_return_status);

       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
          IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
          raise g_get_carrier_failed;
         END IF;
       END IF;

       l_object1_type := G_COMP_CARRIER;
       l_object1_id := l_carrier_id;
       l_object1_parent_id := null;
       l_object2_type := l_object2_typesub;
       l_object2_id := p_object2_val_num;
       l_object2_val_char := p_object2_val_char;


       IF l_carrier_id IS NOT NULL THEN

          l2_hash_string :=        (l_comp_class_id)||'-'||l_object1_type||'-'||       (l_object1_id)||'-'||       (nvl(l_object1_parent_id,-9999))||
          '-'||l_object2_type||'-'||nvl(       to_char(l_object2_id),l_object2_val_char)||'-'||       (-9999);

          l2_hash_value := dbms_utility.get_hash_value(
                                  name => l2_hash_string,
                                  base => g_hash_base,
                                  hash_size =>g_hash_size );

          --
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'l2_hash_string : '||l2_hash_string);
            WSH_DEBUG_SV.logmsg(l_module_name,'l2_hash_value : '||l2_hash_value);
          END IF;
          --

         IF check_cache(l2_hash_value,l2_hash_string) THEN
           IF g_comp_constraint_tab(l2_hash_value).constraint_type = p_constraint_type THEN
              x_validate_result := g_comp_class_tab(l_hash_value).constraint_violation;
              x_failed_constraint.constraint_id := g_comp_constraint_tab(l2_hash_value).compatibility_id;
              x_failed_constraint.constraint_class_code := p_comp_class_code;
              x_failed_constraint.violation_type := g_comp_class_tab(l_hash_value).constraint_violation;

              --
              IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Returning x_validate_result : '||x_validate_result);
                 WSH_DEBUG_SV.pop(l_module_name);
              END IF;
              --
              RETURN;  -- Done with as found for the input types

           END IF;

         END IF;
       END IF;

       --get_customer_from_loc(
       WSH_UTIL_CORE.get_customer_from_loc(
                   p_location_id     =>  l_location_id,
                   --x_customer_id     =>  l_customer_id,
                   x_customer_id_tab   =>  l_customer_id_tab,
                   x_return_status  =>  l_return_status);

       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
          IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
          raise g_get_customer_failed;
         END IF;
       END IF;

       itr := l_customer_id_tab.FIRST;
       IF itr IS NOT NULL THEN
       LOOP
       --IF l_customer_id IS NOT NULL THEN

         l_object1_type := G_COMP_CUSTOMER;
         --l_object1_id := l_customer_id;
         l_object1_id := l_customer_id_tab(itr);
         l_object1_parent_id := null;
         l_object2_type := l_object2_typesub;
         l_object2_id := p_object2_val_num;
         l_object2_val_char := p_object2_val_char;


        l3_hash_string :=        (l_comp_class_id)||'-'||l_object1_type||'-'||       (l_object1_id)||'-'||       (nvl(l_object1_parent_id,-9999))||
    '-'||l_object2_type||'-'||nvl(       to_char(l_object2_id),l_object2_val_char)||'-'||       (-9999);

        l3_hash_value := dbms_utility.get_hash_value(
                                  name => l3_hash_string,
                                  base => g_hash_base,
                                  hash_size =>g_hash_size );

        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'l3_hash_string : '||l3_hash_string);
          WSH_DEBUG_SV.logmsg(l_module_name,'l3_hash_value : '||l3_hash_value);
        END IF;
        --

        IF check_cache(l3_hash_value,l3_hash_string) THEN
           IF g_comp_constraint_tab(l3_hash_value).constraint_type = p_constraint_type THEN
              x_validate_result := g_comp_class_tab(l_hash_value).constraint_violation;
              x_failed_constraint.constraint_id := g_comp_constraint_tab(l3_hash_value).compatibility_id;
              x_failed_constraint.constraint_class_code := p_comp_class_code;
              x_failed_constraint.violation_type := g_comp_class_tab(l_hash_value).constraint_violation;

              --
              IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Returning x_validate_result : '||x_validate_result);
                 WSH_DEBUG_SV.pop(l_module_name);
              END IF;
              --
              RETURN;  -- Done with as found for the input types

           END IF;

        END IF; -- check_cache(l1_hash_value,l1_hash_string)

       EXIT WHEN itr = l_customer_id_tab.LAST;
       itr := l_customer_id_tab.NEXT(itr);

       END LOOP;

       END IF; -- l_customer_id IS NOT NULL

       get_supplier_from_loc(
                   p_location_id     =>  l_location_id,
                   x_supplier_id     =>  l_supplier_id,
                   x_return_status  =>  l_return_status);

       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
          IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
          raise g_get_supplier_failed;
         END IF;
       END IF;

       IF l_supplier_id IS NOT NULL THEN

         l_object1_type := G_COMP_SUPPLIER;
         l_object1_id := l_supplier_id;
         l_object1_parent_id := null;
         l_object2_type := l_object2_typesub;
         l_object2_id := p_object2_val_num;
         l_object2_val_char := p_object2_val_char;


        l4_hash_string :=        (l_comp_class_id)||'-'||l_object1_type||'-'||       (l_object1_id)||'-'||       (nvl(l_object1_parent_id,-9999))||
    '-'||l_object2_type||'-'||nvl(       to_char(l_object2_id),l_object2_val_char)||'-'||       (-9999);

        l4_hash_value := dbms_utility.get_hash_value(
                                  name => l4_hash_string,
                                  base => g_hash_base,
                                  hash_size =>g_hash_size );

        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'l4_hash_string : '||l4_hash_string);
          WSH_DEBUG_SV.logmsg(l_module_name,'l4_hash_value : '||l4_hash_value);
        END IF;
        --

        IF check_cache(l4_hash_value,l4_hash_string) THEN
           IF g_comp_constraint_tab(l4_hash_value).constraint_type = p_constraint_type THEN
              x_validate_result := g_comp_class_tab(l_hash_value).constraint_violation;
              x_failed_constraint.constraint_id := g_comp_constraint_tab(l4_hash_value).compatibility_id;
              x_failed_constraint.constraint_class_code := p_comp_class_code;
              x_failed_constraint.violation_type := g_comp_class_tab(l_hash_value).constraint_violation;

              --
              IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Returning x_validate_result : '||x_validate_result);
                 WSH_DEBUG_SV.pop(l_module_name);
              END IF;
              --
              RETURN;  -- Done with as found for the input types

           END IF;

        END IF; -- check_cache(l4_hash_value,l4_hash_string)
       END IF; -- l_supplier_id IS NOT NULL
    END IF;

    -- Validate for REG-FAC constrait
    -- Constraint type should be ORG_FAC, CUS_FAC, SUP_FAC
    -- Validates only exclusive constraints
    -- Object 1 type should be FAC or ORG.

    -- Do not call validate_region_constraint for inclusive constraint
    -- if the call is for a single leg delivery

     IF ( p_comp_class_code IN (G_SHIPORG_FACILITY,G_CUSTOMER_FACILITY,G_SUPPLIER_FACILITY)
         --AND p_object1_type IN (G_FACILITY,G_COMP_ORG)
	 --AND p_object2_type = G_FACILITY
         AND l_object1_typesub IN (G_FACILITY,G_COMP_ORG)
	 AND l_object2_typesub = G_FACILITY
         AND (p_constraint_type = 'E' OR NOT (p_direct_shipment)) )
     THEN

             -- Pseudo Code -
         -- 1. Validate for the location.
         -- 2. In case we have a Master Org then we have to validate constraints at
         --    Master Org level if Constraits are not present at org level.

         IF (p_comp_class_code = G_SHIPORG_FACILITY  AND l_object1_typesub = G_COMP_ORG) THEN

         --
         -- Bug 4142393:Replaced call to WSH_UTIL_CORE.ORG_TO_LOCATION by get_loc_for_org
         --

                get_loc_for_org(
                  p_org_id	       => p_object1_val_num,
                  x_location_id    => l_location_id,
                  x_return_status  => x_return_status);


                IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                    IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                       raise FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
                END IF;
         ELSE
              l_location_id := p_object1_val_num;
         END IF;

       --
       -- Bug 4142393:Region constraints are validated only when location id is not NULL
       --

       IF (l_location_id IS NOT NULL) THEN

          validate_region_constraint(
             p_location_id       => l_location_id,
	         p_constraint_type   => p_constraint_type,
	         p_object2_val_num   => p_object2_val_num,
             x_validate_result   => x_validate_result,
             x_failed_constraint => x_failed_constraint,
             x_return_status     => x_return_status);

          IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
		   raise FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
	  END IF;

        END IF;

        --  We need to validate Exclusive constraints for master Org in the following scenario.
	--  a) Master Org exists for the organization.
	--  b) x_validate_result is 'S' , this implies we had no constraint at org level

        IF (l_master_org_id <> p_object1_val_num) AND (x_validate_result ='S')
	    AND (p_comp_class_code=G_SHIPORG_FACILITY) AND (l_object1_typesub = G_COMP_ORG) THEN


	  --
          -- Bug 4142393:Replaced call to WSH_UTIL_CORE.ORG_TO_LOCATION by get_loc_for_org
          --

           get_loc_for_org(
              p_org_id	       => l_master_org_id,
              x_location_id    => l_location_id,
              x_return_status  => x_return_status);

 	   IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	       IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
		   raise FND_API.G_EXC_UNEXPECTED_ERROR;
	        END IF;
  	   END IF;

	  --
          -- Bug 4142393:Region constraints are validated only when location id is not NULL
          --

	   IF (l_location_id IS NOT NULL) THEN

	     validate_region_constraint(
                p_location_id       => l_location_id,
	        p_constraint_type   => p_constraint_type,
		p_object2_val_num   => p_object2_val_num,
                x_validate_result   => x_validate_result,
                x_failed_constraint => x_failed_constraint,
                x_return_status     => x_return_status);

              IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	         IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
		    raise FND_API.G_EXC_UNEXPECTED_ERROR;
	         END IF;
	      END IF;

	    END IF;

	END IF; --(If master org Exists)

    END IF;--( End of Validate Region Level Constraints)

    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Returning x_validate_result : '||x_validate_result);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --

EXCEPTION

    WHEN g_get_mast_org_failed THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,' get_mast_org failed ');
      END IF;
      --
    WHEN g_get_carrier_failed THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,' get_carrier failed ');
      END IF;
      --
    WHEN g_get_customer_failed THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,' get_customer failed ');
      END IF;
      --
    WHEN g_get_supplier_failed THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,' get_supplier failed ');
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
    WHEN others THEN
      WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.validate_constraint');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END validate_constraint;


--***************************************************************************--
--
--========================================================================
-- PROCEDURE : check_inclusive_facilities PRIVATE
--
-- PARAMETERS: p_comp_class_code          Compatibility class code
--             p_entity_type              Entity for which check is running
--             p_entity_id                Entity id for which check is running
--             p_object1_type	          Constraint Object1 Type
--             p_object1_physical_id      Physical Location Id - Passed in only for CUS_FAC for Customer Facility
--             p_attribute_id             Constraint Object1 id
--             p_parent_id                Constraint Object1 Parent id
--             p_location_list            Table of location ids to be checked as
--                                        constraint object 2
--             p_direct_shipment          Is the shipment multileg
--             x_validate_result          Constraint Validation result : S / E / W
--             x_failed_constraint        failed constraint table
--             x_return_status            Return status
-- COMMENT   :
-- For a given parameter 1 of a constraint definition
-- and a list of locations which could be parameter2
-- determines if parameter 1 is compatible with the location list
-- Applies to following constraint types :
-- A. Org - Facility
-- B. Customer - Facility
-- C. Supplier - Facility
-- D. Item - Facility
-- Assumes object1 and object2 have been passed as the class requires/defines
--========================================================================

PROCEDURE check_inclusive_facilities(
            p_comp_class_code          IN      VARCHAR2,
            p_entity_type              IN      VARCHAR2,
            p_entity_id                IN      NUMBER,
            p_object1_type             IN      VARCHAR2 DEFAULT NULL,
            p_object1_physical_id      IN      NUMBER	DEFAULT NULL,
	        p_attribute_id             IN      NUMBER,
            p_parent_id                IN      NUMBER DEFAULT NULL,
            p_location_list            IN      WSH_UTIL_CORE.id_tab_type,
            p_direct_shipment          IN      BOOLEAN DEFAULT FALSE,
            x_validate_result          OUT NOCOPY     VARCHAR2,
            x_failed_constraint        IN  OUT NOCOPY  line_constraint_tab_type,
            x_return_status            OUT NOCOPY     VARCHAR2)
IS

    l_object1_type         VARCHAR2(30):=NULL;
    l_return_status        VARCHAR2(1);
    l_validate_result      VARCHAR2(1);   -- S / F
    l_parent_id            NUMBER := p_parent_id;  -- Only for item
    l_carrier_id           NUMBER :=0;
    l_customer_id          NUMBER :=0;
    l_hash_value           NUMBER :=0;
    l_hash_active          NUMBER:=0;
    l_master_org_id        NUMBER:=0;
    l_master_org           BOOLEAN := FALSE;
    l1_hash_value          NUMBER;
    l11_hash_value         NUMBER;
    l2_hash_value          NUMBER;
    l21_hash_value         NUMBER;
    l3_hash_value          NUMBER;
    l31_hash_value         NUMBER;
    l1_hash_string         VARCHAR2(200);
    l11_hash_string        VARCHAR2(200);
    l2_hash_string         VARCHAR2(200);
    l21_hash_string        VARCHAR2(200);
    l3_hash_string         VARCHAR2(200);
    l31_hash_string        VARCHAR2(200);
    l_comp_class_id        NUMBER :=0;
    failed_cons_last       NUMBER:= x_failed_constraint.COUNT;
    l                      NUMBER :=0;
    k                      NUMBER :=0;
    i                      NUMBER :=0;
    l_incl_cons            BOOLEAN := FALSE;

    l_location_id	       NUMBER :=0;

    --DUM_LOC(S)
    l_organization_tab	   WSH_UTIL_CORE.id_tab_type;
    l_org_itr		       NUMBER;
    l_failed_constraint    line_constraint_tab_type;
    l_itr		           NUMBER;
    --DUM_LOC(E)

    l_module_name          CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'check_inclusive_facilities';
    l_debug_on             CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;

BEGIN

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    x_validate_result := 'F';
    l_validate_result := 'F';

    IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name);
      WSH_DEBUG_SV.logmsg(l_module_name,'Input comp class code : '||p_comp_class_code);
      WSH_DEBUG_SV.logmsg(l_module_name,'Input Object1 type : '||p_object1_type);
      WSH_DEBUG_SV.logmsg(l_module_name,'Object1 val num : '||p_attribute_id);
      WSH_DEBUG_SV.logmsg(l_module_name,'Object 1 parent : '||l_parent_id);
      WSH_DEBUG_SV.logmsg(l_module_name,'Object2 count  : '||p_location_list.count);
      IF p_direct_shipment THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'p_direct_shipment is true');
      ELSE
       WSH_DEBUG_SV.logmsg(l_module_name,'p_direct_shipment is false');
      END IF;
    END IF;

    --return if object1 is NULL
    IF p_attribute_id IS NULL THEN
    --IF p_attribute_id IS NULL OR p_location_list.count = 0 THEN
      x_validate_result := 'S';
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Returning x_validate_result : '||x_validate_result);
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
    END IF;

    IF p_object1_type IS NULL THEN
    IF p_comp_class_code = G_SHIPORG_FACILITY THEN
       l_object1_type := 'ORG';
    ELSIF p_comp_class_code = G_CUSTOMER_FACILITY THEN
       l_object1_type := 'CUS';
    ELSIF p_comp_class_code = G_SUPPLIER_FACILITY THEN
       l_object1_type := 'SUP';
    ELSIF p_comp_class_code = G_ITEM_FACILITY THEN
       l_object1_type := 'ITM';
    END IF;
    ELSE
       l_object1_type := p_object1_type;
    END IF;

    -- AGDUMMY - Put the dummy cus fac to org conversion code here
    -- Note that for dummy customer facilities, no constraints can exist
    -- For Dummy customer faciliter only ORG_FAC constraints can exist.

    -- For dummy constraints we validate all the ORG_FAC constraints that are
    -- associated with the location.

    IF (p_comp_class_code = G_CUSTOMER_FACILITY) AND (l_object1_type = G_FACILITY)
	AND (p_object1_physical_id IS NOT NULL) THEN

	--get_org_from_location(
	WSH_UTIL_CORE.get_org_from_location(
              p_location_id	  => p_object1_physical_id,
              x_organization_tab  => l_organization_tab,
              x_return_status     => l_return_status);


	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'l_return_status:'||l_return_status);
        WSH_DEBUG_SV.logmsg(l_module_name,'Organizations Returned:'||l_organization_tab.Count);
	END IF;


	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
          IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;

	l_org_itr := l_organization_tab.FIRST;

	IF l_org_itr IS NOT NULL THEN
          LOOP

	   check_inclusive_facilities(
		p_comp_class_code         => G_SHIPORG_FACILITY,
		p_entity_type             => p_entity_type,
		p_entity_id               => p_entity_id,
                p_object1_type            => G_COMP_ORG     ,
                p_attribute_id            => l_organization_tab(l_org_itr),
                p_location_list           => p_location_list,
                p_direct_shipment         => p_direct_shipment,
                x_validate_result         => x_validate_result,
                x_failed_constraint       => x_failed_constraint,
                x_return_status           => x_return_status);

	       IF l_debug_on THEN
	   	   WSH_DEBUG_SV.logmsg(l_module_name,'Returning x_validate_result : '||x_validate_result);
		   WSH_DEBUG_SV.logmsg(l_module_name,'Returning x_return_status :   '||x_return_status);
	       END IF;

	       IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	         IF x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
	            raise FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;
               END IF;

	   -- When we are getting a constraint at org level we return.
     	   -- Need to add constraints to the level.

               EXIT WHEN (x_validate_result <> 'S' OR l_org_itr= l_organization_tab.LAST);
               l_org_itr:= l_organization_tab.NEXT(l_org_itr);
            END LOOP;

	  ELSE
		--No organizations exist for the location.
		x_validate_result := 'S';
	  END IF;
          --

	  IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Returning x_validate_result : '||x_validate_result);
             WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          --
          RETURN;

     END IF;
    --#DUM_LOC(E)

    l_hash_value := dbms_utility.get_hash_value(
                                  name => p_comp_class_code,
                                  base => g_hash_base,
                                  hash_size =>g_hash_size );

    -- If g_comp_class_tab has a recrd for p_comp_class_code
    -- but g_comp_constraint_tab does not have records for p_comp_class_code
    -- it will be a problem
    IF NOT (g_comp_class_tab.EXISTS(l_hash_value) AND
            g_comp_class_tab(l_hash_value).compatibility_class_code = p_comp_class_code) THEN

      populate_constraint_cache(
          p_comp_class_code          =>    p_comp_class_code,
          x_return_status            =>    l_return_status) ;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Called populate_constraint_cache return status : '||l_return_status);
      END IF;
      --

      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

    END IF;

    l_comp_class_id := g_comp_class_tab(l_hash_value).COMPATIBILITY_CLASS_ID;

    -- If any of the locations in the list belong to
    -- For org facility on RHS, type = FAC and location id is stored
    -- 1. object2 type = FAC and object2 id = location_id
    -- 2. For ORG_FAC : object2 type = CAR and object2 id = carrier_id (get carrier for location)
    --              Also check if anything is defined for master ORG if not found for input ORG
    -- 3. For CUS_FAC : object2 type = CAR and object2 id = carrier_id (get carrier for location)
    -- 4. For ITM_FAC : object2 type = CAR and object2 id = carrier_id (get carrier for location)
    --                  object2 type = CUS and object2 id = customer_id (get customer for location)
    --                  object2 type = SUP and object2 id = supplier_id (get supplier for location)
    -- 5. For SUP_FAC : object2 type = CAR and object2 id = carrier_id (get carrier for location)
    -- Return success

    IF p_comp_class_code = G_SHIPORG_FACILITY THEN

          WSH_UTIL_CORE.get_master_from_org(
              p_org_id         => p_attribute_id,
              x_master_org_id  => l_master_org_id,
              x_return_status  => l_return_status);

      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
         IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
            raise g_get_mast_org_failed;
         END IF;
      END IF;

      IF l_master_org_id <> p_attribute_id THEN -- Input ORG is child of l_master_org_id

         l_master_org := TRUE;

      END IF;

    END IF;

    IF g_is_tp_installed IS NULL THEN
     g_is_tp_installed := WSH_UTIL_CORE.TP_Is_Installed;
    END IF;

    IF (l_object1_type = 'ITM' AND g_is_tp_installed = 'Y') THEN
       l_parent_id := NULL;
    END IF;

    i := p_location_list.FIRST;
    IF i IS NOT NULL THEN
      LOOP

       --
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'p_location_list  : '||p_location_list(i));
       END IF;
       --

    -- Need a data structure for hashing constraints
    -- hash by class+obj1 type+obj1+obj1 parent+obj2 type+obj2+obj2 parent
    -- As this combination defines a unique key

       l1_hash_string :=        (l_comp_class_id)||'-'||l_object1_type||'-'||       (p_attribute_id)||'-'||       (nvl(l_parent_id,-9999))||
       '-'||'FAC'||'-'||       (p_location_list(i))||'-'||       (-9999);

       l1_hash_value := dbms_utility.get_hash_value(
                                  name => l1_hash_string,
                                  base => g_hash_base,
                                  hash_size =>g_hash_size );
       --
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'l1_hash_string : '||l1_hash_string);
         WSH_DEBUG_SV.logmsg(l_module_name,'l1_hash_value : '||l1_hash_value);
       END IF;
       --

       IF l_master_org THEN

          l11_hash_string := (l_comp_class_id)||'-'||l_object1_type||'-'||to_char(l_master_org_id)||'-'||(nvl(l_parent_id,-9999))||
          '-'||'FAC'||'-'||to_char(p_location_list(i))||'-'||(-9999);

          l11_hash_value := dbms_utility.get_hash_value(
                                  name => l11_hash_string,
                                  base => g_hash_base,
                                  hash_size =>g_hash_size );

          --
          IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'l11_hash_string : '||l11_hash_string);
             WSH_DEBUG_SV.logmsg(l_module_name,'l11_hash_value : '||l11_hash_value);
          END IF;
          --

       END IF;

       IF check_cache(l1_hash_value,l1_hash_string) THEN

           IF g_comp_constraint_tab(l1_hash_value).constraint_type = 'I' THEN

              x_validate_result := 'S';
              l_validate_result := 'S';
              EXIT;

           END IF;

       ELSIF l_master_org AND check_cache(l11_hash_value,l11_hash_string) THEN

           IF g_comp_constraint_tab(l11_hash_value).constraint_type = 'I' THEN

              x_validate_result := 'S';
              l_validate_result := 'S';
              EXIT;

           END IF;

       END IF;

       EXIT WHEN i=p_location_list.LAST;
       i := p_location_list.NEXT(i);

      END LOOP;
    END IF;

    IF x_validate_result = 'F' THEN
      -- LOOP over g_comp_constraint_tab
      l := failed_cons_last;
      k := g_comp_constraint_tab.FIRST;
      IF k IS NOT NULL THEN
       LOOP

        IF g_comp_constraint_tab(k).compatibility_class_id = l_comp_class_id AND
           g_comp_constraint_tab(k).CONSTRAINT_OBJECT1_TYPE = l_object1_type AND
           nvl(g_comp_constraint_tab(k).OBJECT1_SOURCE_ID,-9999) = nvl(l_parent_id,-9999) AND
           (g_comp_constraint_tab(k).CONSTRAINT_OBJECT1_ID = p_attribute_id OR
           (l_master_org AND g_comp_constraint_tab(k).CONSTRAINT_OBJECT1_ID = l_master_org_id)) THEN

           --
           IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,' Input has constraint : '||g_comp_constraint_tab(k).compatibility_id);
           END IF;
           --

           IF g_comp_constraint_tab(k).constraint_type = 'I' THEN

             -- Add to the x_failed_constraint
             l := l + 1;
             x_failed_constraint(l).constraint_id := g_comp_constraint_tab(k).compatibility_id;
             x_failed_constraint(l).entity_type := p_entity_type;
             x_failed_constraint(l).entity_line_id := p_entity_id;
             x_failed_constraint(l).constraint_class_code := p_comp_class_code;
             x_failed_constraint(l).violation_type := g_comp_class_tab(l_hash_value).constraint_violation;
             l_validate_result := g_comp_class_tab(l_hash_value).constraint_violation;
             l_incl_cons := TRUE;

           END IF;
        END IF;

        EXIT WHEN k=g_comp_constraint_tab.LAST;
        k := g_comp_constraint_tab.NEXT(k);

       END LOOP;
      END IF;

   IF NOT l_incl_cons THEN

        IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,' Checking to see if we need to call check_reg_incl_facilities');
              WSH_DEBUG_SV.logmsg(l_module_name,' p_comp_class_code : '||p_comp_class_code);
              WSH_DEBUG_SV.logmsg(l_module_name,' l_object1_type : '|| l_object1_type);
        END IF;

	IF (p_comp_class_code IN ( G_SHIPORG_FACILITY, G_CUSTOMER_FACILITY, G_SUPPLIER_FACILITY)
	    AND l_object1_type IN (G_FACILITY,G_COMP_ORG)
            AND NOT (p_direct_shipment))
	THEN

	      -- We need to validate Region Level Constraints;
	      IF (p_comp_class_code = G_SHIPORG_FACILITY) THEN

                  --
		  -- Bug 4142393:Replaced call to WSH_UTIL_CORE.ORG_TO_LOCATION by get_loc_for_org
		  --

		  get_loc_for_org(
			p_org_id	 => p_attribute_id,
			x_location_id    => l_location_id,
			x_return_status  => x_return_status);

	 	   IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		       IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
			   raise FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
	  	   END IF;

	      ELSE
	          l_location_id := p_attribute_id;
	      END IF;

    	      --
	      --Bug 4142393:check_reg_incl_facilities is called only when location id is not null
	      --

	      IF (l_location_id IS NOT NULL) THEN

	              IF l_debug_on THEN
		         WSH_DEBUG_SV.logmsg(l_module_name,' calling check_reg_incl_facilities for input');
		      END IF;

		      -- We have the location id .
		      -- Call validate inclusive locations to get the result.
		      -- This API will return the results it finds.

		      check_reg_incl_facilities(
		            p_entity_type       => p_entity_type,
			    p_entity_id         => p_entity_id,
			    p_location_id       => l_location_id,
		            p_location_list     => p_location_list,
			    x_validate_result   => x_validate_result,
			    x_failed_constraint => x_failed_constraint,
			    x_return_status     => x_return_status);

		      IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	   		   IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
				raise FND_API.G_EXC_UNEXPECTED_ERROR;
			   END IF;
 		      END IF;

	       END IF;

  	      -- Master org is there , we need to validate for the master Org also.

	       IF (l_master_org) AND (x_validate_result = 'S') THEN

		 --
		 -- Bug 4142393:Replaced call to WSH_UTIL_CORE.ORG_TO_LOCATION by get_loc_for_org
	         --

		 get_loc_for_org(
			p_org_id	 => l_master_org_id,
		        x_location_id    => l_location_id,
			x_return_status  => x_return_status);

	 	   IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		       IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
			   raise FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
  		   END IF;

		--
		--Bug 4142393:check_reg_incl_facilities is called only when location id is not null
		--

		IF (l_location_id IS NOT NULL) THEN

			IF l_debug_on THEN
				WSH_DEBUG_SV.logmsg(l_module_name,' calling check_reg_incl_facilities for master org of input org');
			END IF;

			check_reg_incl_facilities(
			    p_entity_type       => p_entity_type,
			    p_entity_id         => p_entity_id,
			    p_location_id       => l_location_id,
			    p_location_list     => p_location_list,
			    x_validate_result   => x_validate_result,
			    x_failed_constraint => x_failed_constraint,
			    x_return_status     => x_return_status);

			 IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			    IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
			       raise FND_API.G_EXC_UNEXPECTED_ERROR;
			    END IF;
			 END IF;

		  END IF;

	     END IF;

	ELSE
	      x_validate_result := 'S';
	END IF;  -- (p_comp_class_code IN (G_SHIPORG_FACILITY, G_CUSTOMER_FACILITY)

      ELSE

         IF l_validate_result = 'W' THEN
            x_validate_result := 'W';
         END IF;

      END IF;

    END IF;

    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Returning x_validate_result : '||x_validate_result);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --

EXCEPTION
    WHEN g_get_mast_org_failed THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,' get_mast_org failed ');
      END IF;
      --
    WHEN g_get_carrier_failed THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,' get_carrier failed ');
      END IF;
      --
    WHEN g_get_customer_failed THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,' get_customer failed ');
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
    WHEN others THEN
      WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.check_inclusive_facilities');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END check_inclusive_facilities;

--***************************************************************************--
--========================================================================
-- PROCEDURE : check_inclusive_object2    PRIVATE
--
-- PARAMETERS: p_comp_class_code          Compatibility class code
--             p_entity_type              Entity for which check is running
--             p_entity_id                Entity id for which check is running
--             p_object1_type	          Constraint Object1 Type
--             p_object1_parent_id        Constraint Object1 Parent id
--                                        Required only if object1 = Item
--             p_object1_val_num          Constraint Object1 id
--             p_object2_type	          Constraint Object2 Type
--             p_object2_val_num          Constraint Object2 id
--             p_object2_val_char         Constraint Object2 character code
--             x_out_object2_num          Id of constraint object2 if constraint found
--             x_out_object2_char         Code of constraint object2 if constraint found
--             x_validate_result          Constraint Validation result : S / E / W
--             x_failed_constraint        failed constraint table
--             x_return_status            Return status
-- COMMENT   :
-- For a given parameter 1 of a constraint definition
-- and a parameter2
-- determines if parameter 1 is compatible with parameter2
-- Applies to following constraint types :
-- A. Facility - Carrier
-- B. Facility - Mode
-- C. Facility - Vehicle
-- D. Item - Carrier
-- E. Item - Mode
-- F. Item - Vehicle
-- Assumes object1 and object2 have been passed as the class requires/defines
--========================================================================


PROCEDURE check_inclusive_object2(
            p_comp_class_code            IN      VARCHAR2,
            p_entity_type                IN      VARCHAR2,
            p_entity_id                  IN      NUMBER,
            p_object1_type               IN      VARCHAR2,
            p_object1_val_num            IN      NUMBER,
            p_object1_parent_id          IN      NUMBER DEFAULT NULL,
            p_object2_type               IN      VARCHAR2,
            p_object2_val_num            IN      NUMBER DEFAULT NULL,
            p_object2_val_char           IN      VARCHAR2 DEFAULT NULL,
            x_out_object2_num            OUT NOCOPY     NUMBER,
            x_out_object2_char           OUT NOCOPY     VARCHAR2,
            x_validate_result            OUT NOCOPY     VARCHAR2,
            x_failed_constraint          IN OUT NOCOPY  line_constraint_tab_type,
            x_return_status              OUT NOCOPY     VARCHAR2)
IS

    --l_object1_type         VARCHAR2(30):=NULL;
    l_return_status        VARCHAR2(1);
    l_carrier_id           NUMBER :=0;
    l_customer_id          NUMBER :=0;
    l_customer_id_tab   WSH_UTIL_CORE.id_tab_type;
    l_supplier_id          NUMBER:=0;
    l_object1_parent_id    NUMBER := p_object1_parent_id;
    l_hash_value           NUMBER :=0;
    l1_hash_value          NUMBER;
    l2_hash_value          NUMBER;
    l3_hash_value          NUMBER;
    l4_hash_value          NUMBER;
    l1_hash_string         VARCHAR2(200);
    l2_hash_string         VARCHAR2(200);
    l3_hash_string         VARCHAR2(200);
    l4_hash_string         VARCHAR2(200);
    l_comp_class_id        NUMBER :=0;
    l_compclass_severity   VARCHAR2(30):=NULL;
    failed_cons_last       NUMBER:= x_failed_constraint.COUNT;
    itr                    NUMBER :=0;
    l                      NUMBER :=0;
    k                      NUMBER :=0;
    l_incl_cons            BOOLEAN := FALSE;
    l_object1_typesub      VARCHAR2(30):=NULL;
    l_object2_typesub      VARCHAR2(30):=NULL;
    l_comp_type1           VARCHAR2(3) := SUBSTR(p_comp_class_code,1,3);
    l_comp_type2           VARCHAR2(3) := SUBSTR(p_comp_class_code,5,3);

    l_module_name          CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'check_inclusive_object2';
    l_debug_on             CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;

BEGIN

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    x_validate_result := 'F';
    x_out_object2_num          :=  NULL;
    x_out_object2_char         :=  NULL;

    IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name);
      WSH_DEBUG_SV.logmsg(l_module_name,'Input comp class code : '||p_comp_class_code);
      WSH_DEBUG_SV.logmsg(l_module_name,'Input Object1 type : '||p_object1_type);
      WSH_DEBUG_SV.logmsg(l_module_name,'Input Object2 type : '||p_object2_type);
      WSH_DEBUG_SV.logmsg(l_module_name,'Object1 val num : '||p_object1_val_num);
      WSH_DEBUG_SV.logmsg(l_module_name,'Object 1 parent : '||l_object1_parent_id);
      WSH_DEBUG_SV.logmsg(l_module_name,'Object2 val num : '||p_object2_val_num);
      WSH_DEBUG_SV.logmsg(l_module_name,'Object 2 val char : '||p_object2_val_char);
    END IF;

    --return if object1 is NULL
    IF p_object1_val_num IS NULL THEN
      x_validate_result := 'S';
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Returning x_validate_result : '||x_validate_result);
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
    END IF;

    -- Must pass in object types when CLASS code contains FAC

    l_object1_typesub := nvl(p_object1_type,l_comp_type1);
    l_object2_typesub := nvl(p_object2_type,l_comp_type2);

    l_hash_value := dbms_utility.get_hash_value(
                                  name => p_comp_class_code,
                                  base => g_hash_base,
                                  hash_size =>g_hash_size );

    --IF NOT g_comp_class_tab.EXISTS(l_hash_value) THEN
    IF NOT (g_comp_class_tab.EXISTS(l_hash_value) AND
            g_comp_class_tab(l_hash_value).compatibility_class_code = p_comp_class_code) THEN

      populate_constraint_cache(
          p_comp_class_code          =>    p_comp_class_code,
          x_return_status            =>    l_return_status) ;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Called populate_constraint_cache with return status : '||l_return_status);
      END IF;
      --

      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

    END IF;

    l_comp_class_id := g_comp_class_tab(l_hash_value).COMPATIBILITY_CLASS_ID;
    l_compclass_severity := g_comp_class_tab(l_hash_value).CONSTRAINT_VIOLATION;

    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Comp class id : '||l_comp_class_id);
      WSH_DEBUG_SV.logmsg(l_module_name,'l_compclass_severity : '||l_compclass_severity);
    END IF;
    --

    IF g_is_tp_installed IS NULL THEN
     g_is_tp_installed := WSH_UTIL_CORE.TP_Is_Installed;
    END IF;

    --IF (l_object1_typesub = 'ITM' AND WSH_UTIL_CORE.TP_Is_Installed = 'Y') THEN
    IF (l_object1_typesub = 'ITM' AND g_is_tp_installed = 'Y') THEN
       l_object1_parent_id := NULL;
    END IF;


    -- If the location belongs to an I constraint for obj2
    -- 1. object1 type = FAC and object1 id = location_id
    -- 2. For FAC_CAR : object1 type = CAR and object1 id = carrier_id (get carrier for location)
    -- 3. For FAC_MOD : object1 type = CAR and object1 id = carrier_id (get carrier for location)
    --                  object1 type = CUS and object1 id = customer_id (get customer for location)
    -- 4. For FAC_VEH : object1 type = CAR and object1 id = carrier_id (get carrier for location)
    --                  object1 type = SUP and object1 id = supplier_id (get supplier for location)
    -- Return success

    IF p_object2_val_num IS NOT NULL OR p_object2_val_char IS NOT NULL THEN

    -- Need a data structure for hashing constraints
    -- hash by class+obj1 type+obj1+obj1 parent+obj2 type+obj2+obj2 parent
    -- As this combination defines a unique key

        l1_hash_string :=        (l_comp_class_id)||'-'||l_object1_typesub||'-'||       (p_object1_val_num)||'-'||       (nvl(l_object1_parent_id,-9999))||
        '-'||l_object2_typesub||'-'||nvl(       to_char(p_object2_val_num),p_object2_val_char)||'-'||       (-9999);

        l1_hash_value := dbms_utility.get_hash_value(
                                  name => l1_hash_string,
                                  base => g_hash_base,
                                  hash_size =>g_hash_size );
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'l1_hash_string : '||l1_hash_string);
           WSH_DEBUG_SV.logmsg(l_module_name,'l1_hash_value : '||l1_hash_value);
        END IF;
        --


        IF check_cache(l1_hash_value,l1_hash_string) THEN

          IF g_comp_constraint_tab(l1_hash_value).constraint_type = 'I' THEN

              x_validate_result := 'S';
              --
              IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Returning x_validate_result : '||x_validate_result);
                 WSH_DEBUG_SV.pop(l_module_name);
              END IF;
              --
              RETURN;

          END IF;

        END IF;
    END IF; -- object2 NOT NULL

    IF l_object1_typesub = 'FAC' THEN

      get_carrier_from_loc(
                   p_location_id    =>  p_object1_val_num,
                   x_carrier_id     =>  l_carrier_id,
                   x_return_status  =>  l_return_status);

      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
         IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
            raise g_get_carrier_failed;
         END IF;
      END IF;

      IF p_object2_val_num IS NOT NULL OR p_object2_val_char IS NOT NULL THEN
        -- For phase I, not doing fac as org - car/mode

        IF l_carrier_id IS NOT NULL THEN

           l2_hash_string :=        (l_comp_class_id)||'-'||'CAR'||'-'||       (l_carrier_id)||'-'||       (-9999)||
           '-'||l_object2_typesub||'-'||nvl(       to_char(p_object2_val_num),p_object2_val_char)||'-'||       (-9999);

           l2_hash_value := dbms_utility.get_hash_value(
                                  name => l2_hash_string,
                                  base => g_hash_base,
                                  hash_size =>g_hash_size );
           --
           IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'l2_hash_string : '||l2_hash_string);
              WSH_DEBUG_SV.logmsg(l_module_name,'l2_hash_value : '||l2_hash_value);
           END IF;
           --


           IF check_cache(l2_hash_value,l2_hash_string) THEN

              IF g_comp_constraint_tab(l2_hash_value).constraint_type = 'I' THEN

                 x_validate_result := 'S';
                 --
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Returning x_validate_result : '||x_validate_result);
                    WSH_DEBUG_SV.pop(l_module_name);
                 END IF;
                 --
                 RETURN;

              END IF;

           END IF;
        END IF; -- l_carrier_id
      END IF; -- object2 NOT NULL

      --get_customer_from_loc(
      WSH_UTIL_CORE.get_customer_from_loc(
                   p_location_id    =>  p_object1_val_num,
                   --x_customer_id    =>  l_customer_id,
                   x_customer_id_tab    =>  l_customer_id_tab,
                   x_return_status  =>  l_return_status);

      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
         IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
            raise g_get_customer_failed;
         END IF;
      END IF;

       itr := l_customer_id_tab.FIRST;
       IF itr IS NOT NULL THEN
        LOOP

            IF p_object2_val_num IS NOT NULL OR p_object2_val_char IS NOT NULL THEN
            --IF l_customer_id IS NOT NULL THEN
                IF l_customer_id_tab(itr) IS NOT NULL THEN

                    l3_hash_string :=        (l_comp_class_id)||'-'||'CUS'||'-'||       (l_customer_id_tab(itr))||'-'||       (-9999)||
                    '-'||l_object2_typesub||'-'||nvl(       to_char(p_object2_val_num),p_object2_val_char)||'-'||       (-9999);

                    l3_hash_value := dbms_utility.get_hash_value(
                    name => l3_hash_string,
                    base => g_hash_base,
                    hash_size =>g_hash_size );
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'l3_hash_string : '||l3_hash_string);
                        WSH_DEBUG_SV.logmsg(l_module_name,'l3_hash_value : '||l3_hash_value);
                    END IF;
                    --


                    IF check_cache(l3_hash_value,l3_hash_string) THEN

                        IF g_comp_constraint_tab(l3_hash_value).constraint_type = 'I' THEN

                            x_validate_result := 'S';
                            --
                            IF l_debug_on THEN
                                WSH_DEBUG_SV.logmsg(l_module_name,'Returning x_validate_result : '||x_validate_result);
                                WSH_DEBUG_SV.pop(l_module_name);
                            END IF;
                            --
                            RETURN;

                        END IF;

                    END IF;

                END IF; -- object2 NOT NULL
            END IF; -- object2 NOT NULL
            EXIT WHEN itr = l_customer_id_tab.LAST;
            itr := l_customer_id_tab.NEXT(itr);

        END LOOP;

       END IF; -- l_customer_id

      get_supplier_from_loc(
                   p_location_id    =>  p_object1_val_num,
                   x_supplier_id     =>  l_supplier_id,
                   x_return_status  =>  l_return_status);

      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
         IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
            raise g_get_supplier_failed;
         END IF;
      END IF;

      IF p_object2_val_num IS NOT NULL OR p_object2_val_char IS NOT NULL THEN
        -- For phase I, not doing fac as org - car/mode

       IF l_supplier_id IS NOT NULL THEN

        l4_hash_string :=        (l_comp_class_id)||'-'||'SUP'||'-'||       (l_supplier_id)||'-'||       (-9999)||
    '-'||l_object2_typesub||'-'||nvl(       to_char(p_object2_val_num),p_object2_val_char)||'-'||       (-9999);

        l4_hash_value := dbms_utility.get_hash_value(
                                  name => l4_hash_string,
                                  base => g_hash_base,
                                  hash_size =>g_hash_size );
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'l4_hash_string : '||l4_hash_string);
          WSH_DEBUG_SV.logmsg(l_module_name,'l4_hash_value : '||l4_hash_value);
        END IF;
        --


        IF check_cache(l4_hash_value,l4_hash_string) THEN

          IF g_comp_constraint_tab(l4_hash_value).constraint_type = 'I' THEN

             x_validate_result := 'S';
             --
             IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Returning x_validate_result : '||x_validate_result);
               WSH_DEBUG_SV.pop(l_module_name);
             END IF;
             --
             RETURN;

          END IF;

        END IF;
       END IF; -- l_supplier_id
      END IF; -- object2 NOT NULL

        -- For phase I, not doing fac as org - car/mode

    END IF;  -- FAC

    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,' x_validate_result before checking constraints cache : '||x_validate_result||' g_comp_constraint_tab count :' ||g_comp_constraint_tab.COUNT||' l_comp_class_id : '||l_comp_class_id);
    END IF;
    --

    IF x_validate_result = 'F' THEN
      -- LOOP over g_comp_constraint_tab
      l := failed_cons_last;
      k := g_comp_constraint_tab.FIRST;
      IF k IS NOT NULL THEN
       LOOP


        IF g_comp_constraint_tab(k).compatibility_class_id = l_comp_class_id AND
           ((g_comp_constraint_tab(k).CONSTRAINT_OBJECT1_TYPE = l_object1_typesub AND
           nvl(g_comp_constraint_tab(k).OBJECT1_SOURCE_ID,-9999) = nvl(l_object1_parent_id,-9999) AND
           g_comp_constraint_tab(k).CONSTRAINT_OBJECT1_ID = p_object1_val_num) OR
           (l_object1_typesub = 'FAC' AND
            l_carrier_id IS NOT NULL AND
            g_comp_constraint_tab(k).CONSTRAINT_OBJECT1_TYPE = 'CAR' AND
            g_comp_constraint_tab(k).CONSTRAINT_OBJECT1_ID = l_carrier_id) OR
           (l_object1_typesub = 'FAC' AND
            l_supplier_id IS NOT NULL AND
            g_comp_constraint_tab(k).CONSTRAINT_OBJECT1_TYPE = 'SUP' AND
            g_comp_constraint_tab(k).CONSTRAINT_OBJECT1_ID = l_supplier_id) OR
           (l_object1_typesub = 'FAC' AND
            l_customer_id IS NOT NULL AND
            g_comp_constraint_tab(k).CONSTRAINT_OBJECT1_TYPE = 'CUS' AND
            g_comp_constraint_tab(k).CONSTRAINT_OBJECT1_ID = l_customer_id)) THEN
           --
           IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,' Input has constraint : '||g_comp_constraint_tab(k).compatibility_id);
           END IF;
           --

           IF g_comp_constraint_tab(k).constraint_type = 'I' THEN

           -- Add to the x_failed_constraint
             l := l + 1;
             x_failed_constraint(l).constraint_id := g_comp_constraint_tab(k).compatibility_id;
             x_failed_constraint(l).entity_type := p_entity_type;
             x_failed_constraint(l).entity_line_id := p_entity_id;
             x_failed_constraint(l).constraint_class_code := p_comp_class_code;
             x_failed_constraint(l).violation_type := l_compclass_severity;

             --
             IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,' x_out_object2_num : '||x_out_object2_num||' x_out_object2_char : '||x_out_object2_char);
             END IF;
             --

             IF (( x_out_object2_num IS NOT NULL OR x_out_object2_char IS NOT NULL) AND
                 ( g_comp_constraint_tab(k).constraint_object1_type <> 'FAC')) OR
                (x_out_object2_num IS NULL AND x_out_object2_char IS NULL) THEN
             -- Company level must use overrides facility level must use if both defined

             x_out_object2_num  := g_comp_constraint_tab(k).constraint_object2_id;
             x_out_object2_char := g_comp_constraint_tab(k).constraint_object2_value_char;

             END IF;

             IF l_compclass_severity = 'E' THEN
                l_incl_cons := TRUE;
             END IF;

           END IF;
        END IF;

        EXIT WHEN k=g_comp_constraint_tab.LAST;
        k := g_comp_constraint_tab.NEXT(k);

       END LOOP;
      END IF;

      IF NOT l_incl_cons THEN

           x_validate_result := 'S';

      END IF;

    END IF;

    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Returning x_validate_result : '||x_validate_result);
      WSH_DEBUG_SV.logmsg(l_module_name,' x_out_object2_num : '||x_out_object2_num);
      WSH_DEBUG_SV.logmsg(l_module_name,' x_out_object2_char : '||x_out_object2_char);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --

EXCEPTION
    WHEN g_get_carrier_failed THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,' get_carrier failed ');
      END IF;
      --
    WHEN g_get_customer_failed THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,' get_customer failed ');
      END IF;
      --
    WHEN g_get_supplier_failed THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,' get_supplier failed ');
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
    WHEN others THEN
      WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.check_inclusive_object2');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END check_inclusive_object2;

--***************************************************************************--

--========================================================================
-- PROCEDURE : search_itm_fac_incl        PRIVATE
--
-- PARAMETERS: p_comp_class_tab           Table of Compatibility class codes to check
--             p_items_tab                Table of item ids to validate
--             p_entity_type              Entity for which check is running
--             p_entity_id                Entity id for which check is running
--             p_locations_list           Table of location ids to be checked
--             x_validate_result          Constraint Validation result : S / E / W
--             x_failed_constraints       Failed constraint table
--             x_return_status            Return status
-- COMMENT   :
-- Checks whether all input items
-- have same/different must use carrier/mode/vehicle
-- compared to the list of input location id s
-- If different, violation
--========================================================================

PROCEDURE search_itm_fac_incl (
              p_comp_class_tab      IN  WSH_UTIL_CORE.Column_Tab_Type,
              p_items_tab           IN  item_tab_type,
              p_entity_type         IN  VARCHAR2,
              p_entity_id           IN  NUMBER,
              p_locations_list      IN  WSH_UTIL_CORE.id_tab_type,
              x_validate_result     OUT NOCOPY    VARCHAR2,
              x_failed_constraints  IN OUT NOCOPY line_constraint_tab_type,
              x_return_status       OUT NOCOPY    VARCHAR2 )
IS

      l_return_status             VARCHAR2(1) := 'S';
      l_const_count               NUMBER := x_failed_constraints.COUNT;
      l_validate_result           VARCHAR2(1) := 'S';
      l_validate_carrier_result   VARCHAR2(1) := 'S';
      l_validate_vehicle_result   VARCHAR2(1) := 'S';
      l_validate_mode_result      VARCHAR2(1) := 'S';
      l_validate_itmcar_result    VARCHAR2(1) := 'S';
      l_validate_itmveh_result    VARCHAR2(1) := 'S';
      l_validate_itmmode_result   VARCHAR2(1) := 'S';
      l_out_object2_vehnum        NUMBER := NULL;
      l_out_object2_num           NUMBER := NULL;
      l_out_object2_dummy_num     NUMBER := NULL;
      l_out_object2_char          VARCHAR2(30) := NULL;
      l_out_object2_dummy_char    VARCHAR2(30) := NULL;
      l_out_object2_itm_num       NUMBER := NULL;
      l_out_object2_itm_char      VARCHAR2(30) := NULL;
      i                           NUMBER :=  0;
      j                           NUMBER :=  0;
      l_item_org_id               NUMBER := null;
      l_hash_string               VARCHAR2(200);
      l_hash_value                NUMBER:=0;
      l_fac_hash_string           VARCHAR2(200);

      l_module_name               CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'search_itm_fac_incl';
      l_debug_on                  CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;

BEGIN

      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      x_validate_result := 'S';

      IF l_debug_on THEN
         wsh_debug_sv.push(l_module_name);
      END IF;

      IF g_is_tp_installed IS NULL THEN
         g_is_tp_installed := WSH_UTIL_CORE.TP_Is_Installed;
      END IF;

      i := p_locations_list.FIRST;
      IF i IS NOT NULL THEN
        LOOP

          l_validate_result := 'S';
          l_validate_carrier_result := 'S';
          l_validate_vehicle_result := 'S';
          l_validate_mode_result := 'S';
          l_validate_itmcar_result := 'S';
          l_validate_itmveh_result := 'S';
          l_validate_itmmode_result := 'S';
          l_out_object2_num := NULL;
          l_out_object2_vehnum := NULL;
          l_out_object2_char := NULL;
          l_out_object2_itm_num := NULL;
          l_out_object2_itm_char := NULL;

          l_fac_hash_string := p_locations_list(i)||'-';

          IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'i : '||i||' p_locations_list(i) : '||p_locations_list(i));
          END IF;

          IF p_comp_class_tab.EXISTS(G_FACILITY_CARRIER_NUM) THEN

             check_inclusive_object2(
                 p_comp_class_code          =>      G_FACILITY_CARRIER,
                 p_entity_type              =>      p_entity_type,
                 p_entity_id                =>      p_entity_id,
                 p_object1_type             =>      'FAC',
                 p_object1_val_num          =>      p_locations_list(i),
                 p_object2_type             =>      'CAR',
                 x_out_object2_num          =>      l_out_object2_num,
                 x_out_object2_char         =>      l_out_object2_dummy_char,
                 x_validate_result          =>      l_validate_carrier_result,
                 x_failed_constraint        =>      x_failed_constraints,
                 x_return_status            =>      l_return_status);

             IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                   raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
             END IF;

            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'l_validate_carrier_result : '||l_validate_carrier_result);
            END IF;

          END IF;



          IF p_comp_class_tab.EXISTS(G_FACILITY_MODE_NUM) THEN

             check_inclusive_object2(
                 p_comp_class_code          =>      G_FACILITY_MODE,
                 p_entity_type              =>      p_entity_type,
                 p_entity_id                =>      p_entity_id,
                 p_object1_type             =>      'FAC',
                 p_object1_val_num          =>      p_locations_list(i),
                 p_object2_type             =>      'MOD',
                 x_out_object2_num          =>      l_out_object2_dummy_num,
                 x_out_object2_char         =>      l_out_object2_char,
                 x_validate_result          =>      l_validate_mode_result,
                 x_failed_constraint        =>      x_failed_constraints,
                 x_return_status            =>      l_return_status);

             IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                   raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
             END IF;

             IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'l_validate_mode_result : '||l_validate_mode_result);
             END IF;

          END IF;

          IF p_comp_class_tab.EXISTS(G_FACILITY_VEHICLE_NUM) THEN

             check_inclusive_object2(
                 p_comp_class_code          =>      G_FACILITY_VEHICLE,
                 p_entity_type              =>      p_entity_type,
                 p_entity_id                =>      p_entity_id,
                 p_object1_type             =>      'FAC',
                 p_object1_val_num          =>      p_locations_list(i),
                 p_object2_type             =>      'VHT',
                 x_out_object2_num          =>      l_out_object2_vehnum,
                 x_out_object2_char         =>      l_out_object2_dummy_char,
                 x_validate_result          =>      l_validate_vehicle_result,
                 x_failed_constraint        =>      x_failed_constraints,
                 x_return_status            =>      l_return_status);

             IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                   raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
             END IF;

             IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'l_validate_vehicle_result : '||l_validate_vehicle_result);
             END IF;

          END IF;

          IF l_validate_carrier_result = 'F' OR l_validate_mode_result = 'F'
             OR l_validate_vehicle_result = 'F' THEN
             IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,' p_items_tab COUNT : '||p_items_tab.COUNT);
             END IF;

            j := p_items_tab.FIRST;
            IF j IS NOT NULL THEN
              LOOP

                -- Performance bug 3432495
                -- form unique combination of
                -- locationid-item-org and mark for each combination
                -- whether carrier/mode/vehicle check is successful

                -- Any subsequent combination will be checked against that
                -- list of unique combinations first
                -- and if not found, then only proceed to call the
                -- following API s which will end up adding that
                -- combination to this list

                IF l_debug_on THEN
                       WSH_DEBUG_SV.logmsg(l_module_name,'p_items_tab(j).item_id : '||p_items_tab(j).item_id||'p_items_tab(j).org_id : '||p_items_tab(j).org_id);
                END IF;

                --IF WSH_UTIL_CORE.TP_Is_Installed = 'N' THEN
                IF g_is_tp_installed = 'N' THEN
                   l_item_org_id := p_items_tab(j).org_id;
                END IF;

                l_hash_string := l_fac_hash_string || p_items_tab(j).item_id||'-'||nvl(l_item_org_id,-9999);

                l_hash_value := dbms_utility.get_hash_value(
                                    name => l_hash_string,
                                    base => g_hash_base,
                                    hash_size =>g_hash_size );

                -- Hash collision

                IF g_itmloc_mustuse_cache.EXISTS(l_hash_value) AND
                    g_itmloc_mustuse_cache(l_hash_value).hash_string = l_hash_string THEN
                    IF l_debug_on THEN
                       WSH_DEBUG_SV.logmsg(l_module_name,'g_itmloc_mustuse_cache has record with hash value : '||l_hash_value);
                       WSH_DEBUG_SV.logmsg(l_module_name,'g_itmloc_mustuse_cache carrier result : '||g_itmloc_mustuse_cache(l_hash_value).carrier_result);
                       WSH_DEBUG_SV.logmsg(l_module_name,'g_itmloc_mustuse_cache mode result : '||g_itmloc_mustuse_cache(l_hash_value).mode_result);
                       WSH_DEBUG_SV.logmsg(l_module_name,'g_itmloc_mustuse_cache vehicle result : '||g_itmloc_mustuse_cache(l_hash_value).vehicle_result);
                    END IF;

                   IF g_itmloc_mustuse_cache(l_hash_value).carrier_result = 'F' OR
                      g_itmloc_mustuse_cache(l_hash_value).mode_result = 'F' OR
                      g_itmloc_mustuse_cache(l_hash_value).vehicle_result = 'F' THEN
                        IF l_debug_on THEN
                           WSH_DEBUG_SV.logmsg(l_module_name,'g_itmloc_mustuse_cache record has failure ');
                        END IF;
                        l_validate_result := 'F';
                        EXIT;
                   END IF;

                ELSE

                -- populate g_itmloc_mustuse_cache

                g_itmloc_mustuse_cache(l_hash_value).target_location_id := p_locations_list(i);
                g_itmloc_mustuse_cache(l_hash_value).input_item_id := p_items_tab(j).item_id;
                g_itmloc_mustuse_cache(l_hash_value).input_itemorg_id := l_item_org_id;
                g_itmloc_mustuse_cache(l_hash_value).hash_string := l_hash_string;
                g_itmloc_mustuse_cache(l_hash_value).carrier_result := 'S';
                g_itmloc_mustuse_cache(l_hash_value).mode_result := 'S';
                g_itmloc_mustuse_cache(l_hash_value).vehicle_result := 'S';
                IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'g_itmloc_mustuse_cache record created with hash value : '||l_hash_value);
                END IF;

                IF p_comp_class_tab.EXISTS(G_ITEM_CARRIER_NUM) AND l_validate_carrier_result = 'F' THEN

                  check_inclusive_object2(
                       p_comp_class_code          =>      G_ITEM_CARRIER,
                       p_entity_type              =>      G_DEL_DETAIL,
                       p_entity_id                =>      p_items_tab(j).line_id,
                       p_object1_type             =>      'ITM',
                       p_object1_val_num          =>      p_items_tab(j).item_id,
                       p_object1_parent_id        =>      p_items_tab(j).org_id,
                       p_object2_type             =>      'CAR',
                       x_out_object2_num          =>      l_out_object2_itm_num,
                       x_out_object2_char         =>      l_out_object2_itm_char,
                       x_validate_result          =>      l_validate_itmcar_result,
                       x_failed_constraint        =>      x_failed_constraints,
                       x_return_status            =>      l_return_status);

                  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                     IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                     END IF;
                  END IF;

                  IF l_validate_itmcar_result = 'F' AND
                     l_out_object2_itm_num <> l_out_object2_num THEN
                     l_validate_result := 'F';
                     g_itmloc_mustuse_cache(l_hash_value).carrier_result := 'F';
                     --EXIT;
                  END IF;

                END IF;

                IF p_comp_class_tab.EXISTS(G_ITEM_MODE_NUM) AND l_validate_mode_result = 'F' THEN

                  check_inclusive_object2(
                       p_comp_class_code          =>      G_ITEM_MODE,
                       p_entity_type              =>      G_DEL_DETAIL,
                       p_entity_id                =>      p_items_tab(j).line_id,
                       p_object1_type             =>      'ITM',
                       p_object1_val_num          =>      p_items_tab(j).item_id,
                       p_object1_parent_id        =>      p_items_tab(j).org_id,
                       p_object2_type             =>      'MOD',
                       x_out_object2_num          =>      l_out_object2_itm_num,
                       x_out_object2_char         =>      l_out_object2_itm_char,
                       x_validate_result          =>      l_validate_itmmode_result,
                       x_failed_constraint        =>      x_failed_constraints,
                       x_return_status            =>      l_return_status);

                  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                     IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                     END IF;
                  END IF;

                  IF l_validate_itmmode_result = 'F' AND
                     l_out_object2_itm_char <> l_out_object2_char THEN
                     l_validate_result := 'F';
                     g_itmloc_mustuse_cache(l_hash_value).mode_result := 'F';
                     --EXIT;
                  END IF;

                END IF;

                IF p_comp_class_tab.EXISTS(G_ITEM_VEHICLE_NUM) AND l_validate_vehicle_result = 'F' THEN

                  check_inclusive_object2(
                       p_comp_class_code          =>      G_ITEM_VEHICLE,
                       p_entity_type              =>      G_DEL_DETAIL,
                       p_entity_id                =>      p_items_tab(j).line_id,
                       p_object1_type             =>      'ITM',
                       p_object1_val_num          =>      p_items_tab(j).item_id,
                       p_object1_parent_id        =>      p_items_tab(j).org_id,
                       p_object2_type             =>      'VHT',
                       x_out_object2_num          =>      l_out_object2_itm_num,
                       x_out_object2_char         =>      l_out_object2_itm_char,
                       x_validate_result          =>      l_validate_itmveh_result,
                       x_failed_constraint        =>      x_failed_constraints,
                       x_return_status            =>      l_return_status);

                  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                     IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                     END IF;
                  END IF;

                  IF l_validate_itmveh_result = 'F' AND
                     l_out_object2_itm_num <> l_out_object2_vehnum THEN
                     l_validate_result := 'F';
                     g_itmloc_mustuse_cache(l_hash_value).vehicle_result := 'F';
                     --EXIT;
                  END IF;

                END IF;

                --END IF; -- Facility check result

                END IF; -- ELSE of hash found

                IF l_debug_on THEN
                       WSH_DEBUG_SV.logmsg(l_module_name,'g_itmloc_mustuse_cache carrier result : '||g_itmloc_mustuse_cache(l_hash_value).carrier_result);
                       WSH_DEBUG_SV.logmsg(l_module_name,'g_itmloc_mustuse_cache mode result : '||g_itmloc_mustuse_cache(l_hash_value).mode_result);
                       WSH_DEBUG_SV.logmsg(l_module_name,'g_itmloc_mustuse_cache vehicle result : '||g_itmloc_mustuse_cache(l_hash_value).vehicle_result);
                END IF;

                EXIT WHEN j = p_items_tab.LAST;
                j := p_items_tab.NEXT(j);

              END LOOP;
            END IF;
            END IF; -- Facility check result

          IF l_validate_result = 'F' THEN
             x_validate_result := 'F';
             EXIT;
          END IF;

          EXIT WHEN i = p_locations_list.LAST;
          i := p_locations_list.NEXT(i);

        END LOOP;
      END IF;

      IF ( l_const_count < x_failed_constraints.COUNT) AND
         x_validate_result <> 'F' THEN

         x_failed_constraints.DELETE(l_const_count+1,x_failed_constraints.COUNT);

      END IF;

      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Returning x_validate_result : '||x_validate_result);
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
         WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.search_itm_fac_incl');
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --

END search_itm_fac_incl;

--***************************************************************************--

--========================================================================
-- PROCEDURE : search_group_itm           PRIVATE
--
-- PARAMETERS: p_comp_class_tab           Table of Compatibility class codes to check
--             p_entity_rec               Table of item ids to validate
--             p_target_rec               Table of item ids to validate
--             x_validate_result          Constraint Validation result : S / E / W
--             x_failed_constraints       failed constraint table in case of failure, null if success
--             x_return_status            Return status
-- COMMENT   :
-- Checks whether input item in p_entity_rec
-- have same/different must use carrier/mode/vehicle
-- compared to the input item in p_target_rec
-- If different, violation
--========================================================================

PROCEDURE search_group_itm (
              p_comp_class_tab      IN   WSH_UTIL_CORE.Column_Tab_Type,
              p_entity_rec          IN   entity_rec_type,
              p_target_rec          IN   entity_rec_type,
              x_validate_result     OUT NOCOPY      VARCHAR2,
              x_failed_constraints  IN OUT NOCOPY   line_constraint_tab_type,
              x_return_status       OUT NOCOPY      VARCHAR2 )
IS

    l_return_status             VARCHAR2(1);
    l_const_count               NUMBER := x_failed_constraints.COUNT;
    i                           NUMBER := 0;
    l_entity_id                 NUMBER := 0;
    l_item_id                   NUMBER := 0;
    l_org_id                    NUMBER := 0;
    l_validate_carrier_result   VARCHAR2(1) := 'S';
    l_validate_vehicle_result   VARCHAR2(1) := 'S';
    l_validate_mode_result      VARCHAR2(1) := 'S';
    l_out_object2_vehnum        NUMBER := NULL;
    l_out_object2_num           NUMBER := NULL;
    l_out_object2_char          VARCHAR2(30) := NULL;
    l_prev_out_object2_vehnum   NUMBER := NULL;
    l_prev_out_object2_num      NUMBER := NULL;
    l_prev_out_object2_char     VARCHAR2(30) := NULL;

    l_input_item_org_id         NUMBER := null;
    l_target_item_org_id        NUMBER := null;
    l_hash_string               VARCHAR2(200);
    l_hash_value                NUMBER:=0;

    l_module_name               CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'search_group_itm';
    l_debug_on                  CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;

BEGIN

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    x_validate_result := 'S';

    IF l_debug_on THEN
       wsh_debug_sv.push(l_module_name);
    END IF;

    IF g_is_tp_installed IS NULL THEN
         g_is_tp_installed := WSH_UTIL_CORE.TP_Is_Installed;
    END IF;

    IF p_entity_rec.inventory_item_id = p_target_rec.inventory_item_id THEN
       IF g_is_tp_installed = 'Y' OR
          p_entity_rec.organization_id = p_target_rec.organization_id THEN
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Returning without check as input and target items are the same');
            WSH_DEBUG_SV.logmsg(l_module_name,'Returning x_validate_result : '||x_validate_result);
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          return;
       END IF;

    ELSE
       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'p_entity_rec.inventory_item_id : '||p_entity_rec.inventory_item_id);
          WSH_DEBUG_SV.logmsg(l_module_name,'p_entity_rec.organization_id : '||p_entity_rec.organization_id);
          WSH_DEBUG_SV.logmsg(l_module_name,'p_target_rec.inventory_item_id : '||p_target_rec.inventory_item_id);
          WSH_DEBUG_SV.logmsg(l_module_name,'p_target_rec.organization_id : '||p_target_rec.organization_id);
       END IF;

    END IF;

    -- Performance bug 3432495
    -- proceed forward only for each unique combination of
    -- entityitem-entityorg-targetitem-targetorg
    -- for each unique combination also record whether carrier/mode/vehicle
    -- is failure or successful

    -- For all subsequent combinations, the result used
    -- will be as found for the first combination

    IF g_is_tp_installed = 'N' THEN
       l_input_item_org_id := p_entity_rec.organization_id;
       l_target_item_org_id := p_target_rec.organization_id;
    END IF;

    l_hash_string := p_entity_rec.inventory_item_id||'-'||nvl(l_input_item_org_id,-9999)||'-';
    l_hash_string := l_hash_string || p_target_rec.inventory_item_id||'-'||nvl(l_target_item_org_id,-9999);

    l_hash_value := dbms_utility.get_hash_value(
                                    name => l_hash_string,
                                    base => g_hash_base,
                                    hash_size =>g_hash_size );

    IF g_itm_mustuse_cache.EXISTS(l_hash_value) AND
         g_itm_mustuse_cache(l_hash_value).hash_string = l_hash_string THEN

      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Found g_itm_mustuse_cache record with hash value : '||l_hash_value);
      END IF;
      IF g_itm_mustuse_cache(l_hash_value).carrier_result = 'F'
OR
         g_itm_mustuse_cache(l_hash_value).mode_result = 'F' OR
         g_itm_mustuse_cache(l_hash_value).vehicle_result = 'F' THEN

         x_validate_result := 'F';
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'g_itm_mustuse_cache record has failure ');
         END IF;
      END IF;
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Returning x_validate_result : '||x_validate_result);
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      return;

    ELSE

    FOR i IN 1..2 LOOP

      IF i = 1 THEN
         l_entity_id := p_entity_rec.entity_id;
         l_item_id := p_entity_rec.inventory_item_id;
         l_org_id := p_entity_rec.organization_id;

      ELSIF i = 2 THEN
         l_entity_id := p_target_rec.entity_id;
         l_item_id := p_target_rec.inventory_item_id;
         l_org_id := p_target_rec.organization_id;

      END IF;

      IF i = 2 THEN
      -- populate g_itm_mustuse_cache
      g_itm_mustuse_cache(l_hash_value).input_item_id := p_entity_rec.inventory_item_id;
      g_itm_mustuse_cache(l_hash_value).input_itemorg_id := l_input_item_org_id;
      g_itm_mustuse_cache(l_hash_value).target_item_id := p_target_rec.inventory_item_id;
      g_itm_mustuse_cache(l_hash_value).target_itemorg_id := l_target_item_org_id;
      g_itm_mustuse_cache(l_hash_value).hash_string := l_hash_string;
      g_itm_mustuse_cache(l_hash_value).carrier_result := 'S';
      g_itm_mustuse_cache(l_hash_value).mode_result := 'S';
      g_itm_mustuse_cache(l_hash_value).vehicle_result := 'S';
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Creating g_itm_mustuse_cache record with hash value : '||l_hash_value);
      END IF;
      END IF;

      IF p_comp_class_tab.EXISTS(G_ITEM_CARRIER_NUM) THEN

        check_inclusive_object2(
             p_comp_class_code          =>      G_ITEM_CARRIER,
             p_entity_type              =>      G_DEL_DETAIL,
             p_entity_id                =>      l_entity_id,
             p_object1_type             =>      'ITM',
             p_object1_val_num          =>      l_item_id,
             p_object1_parent_id        =>      l_org_id,
             p_object2_type             =>      'CAR',
             x_out_object2_num          =>      l_out_object2_num,
             x_out_object2_char         =>      l_out_object2_char,
             x_validate_result          =>      l_validate_carrier_result,
             x_failed_constraint        =>      x_failed_constraints,
             x_return_status            =>      l_return_status);

        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

        IF l_validate_carrier_result = 'F' THEN
           IF i = 2 AND l_prev_out_object2_num IS NOT NULL THEN
              IF l_out_object2_num <> l_prev_out_object2_num THEN
                 x_validate_result := 'F';
                 g_itm_mustuse_cache(l_hash_value).carrier_result := 'F';
                 --EXIT;
              END IF;
           END IF;
        END IF;
        l_prev_out_object2_num := l_out_object2_num;

      END IF;

      IF p_comp_class_tab.EXISTS(G_ITEM_MODE_NUM) THEN

        check_inclusive_object2(
             p_comp_class_code          =>      G_ITEM_MODE,
             p_entity_type              =>      G_DEL_DETAIL,
             p_entity_id                =>      l_entity_id,
             p_object1_type             =>      'ITM',
             p_object1_val_num          =>      l_item_id,
             p_object1_parent_id        =>      l_org_id,
             p_object2_type             =>      'MOD',
             x_out_object2_num          =>      l_out_object2_num,
             x_out_object2_char         =>      l_out_object2_char,
             x_validate_result          =>      l_validate_mode_result,
             x_failed_constraint        =>      x_failed_constraints,
             x_return_status            =>      l_return_status);

        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

        IF l_validate_mode_result = 'F' THEN
           IF i = 2 AND l_prev_out_object2_char IS NOT NULL THEN
              IF l_out_object2_char <> l_prev_out_object2_char THEN
                 x_validate_result := 'F';
                 g_itm_mustuse_cache(l_hash_value).mode_result := 'F';
                 --EXIT;
              END IF;
           END IF;
        END IF;
        l_prev_out_object2_char := l_out_object2_char;

      END IF;

      IF p_comp_class_tab.EXISTS(G_ITEM_VEHICLE_NUM) THEN

        check_inclusive_object2(
             p_comp_class_code          =>      G_ITEM_VEHICLE,
             p_entity_type              =>      G_DEL_DETAIL,
             p_entity_id                =>      l_entity_id,
             p_object1_type             =>      'ITM',
             p_object1_val_num          =>      l_item_id,
             p_object1_parent_id        =>      l_org_id,
             p_object2_type             =>      'VHT',
             x_out_object2_num          =>      l_out_object2_vehnum,
             x_out_object2_char         =>      l_out_object2_char,
             x_validate_result          =>      l_validate_vehicle_result,
             x_failed_constraint        =>      x_failed_constraints,
             x_return_status            =>      l_return_status);

        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

        IF l_validate_vehicle_result = 'F' THEN
           IF i = 2 AND l_prev_out_object2_vehnum IS NOT NULL THEN
              IF l_out_object2_vehnum <> l_prev_out_object2_vehnum THEN
                 x_validate_result := 'F';
                 g_itm_mustuse_cache(l_hash_value).vehicle_result := 'F';
                 --EXIT;
              END IF;
           END IF;
        END IF;
        l_prev_out_object2_vehnum := l_out_object2_vehnum;

      END IF;

    END LOOP;

    END IF; -- cache check

    IF ( l_const_count < x_failed_constraints.COUNT) AND
         x_validate_result <> 'F' THEN

         x_failed_constraints.DELETE(l_const_count+1,x_failed_constraints.COUNT);

    END IF;

    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Returning x_validate_result : '||x_validate_result);
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
      WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.search_group_itm');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --

END search_group_itm;


--***************************************************************************--
--========================================================================
-- PROCEDURE : search_matching_group      PRIVATE
--
-- PARAMETERS: p_entity_type              Entity for which check is running
--             p_action_code              Current action that required constraint check
--                                        Used only for Call from delivery API
--             p_children_info            Table of children delivery details of the input delivery
--                                        Used only for Call from delivery API
--             p_comp_class_tab           Table of Compatibility class codes to check
--             p_target_stops_info        Input pickup and dropoff stop/location of the delivery(s)
--                                        in the target trip in case of assign delivery to trip
--             p_entity_rec               Input entity record for which a group is being searched
--                                        Can be delivery or delivery detail
--             p_entity_tab               Table of entity records already formed
--             p_group_tab                Table of group records which are being searched
--             x_validate_result          Constraint Validation result : S / E / W
--             x_failed_constraints       failed constraint table
--             x_group_id                 Matching group id from the list p_group_tab
--                                        for the input p_entity_rec
--                                        Returns -999 if nothing is found
--             x_found                    Whether a matching group has been found
--             x_return_status            Return status
-- COMMENT   :
-- For a given entity which can be delivery or delivery detail
-- determines if a group of entities can be found from the current list of groups
-- where the input entity can be placed satisfying constraints
--========================================================================

PROCEDURE search_matching_group(
                  p_entity_type           IN    VARCHAR2,
                  p_action_code           IN    VARCHAR2,
                  p_children_info         IN    detail_ccinfo_tab_type,
                  p_comp_class_tab        IN    WSH_UTIL_CORE.Column_Tab_Type,
                  p_target_stops_info     IN    target_tripstop_cc_rec_type,
                  p_entity_rec            IN    entity_rec_type,
                  p_target_trip_id        IN    NUMBER DEFAULT NULL,
                  p_entity_tab            IN    entity_tab_type,
                  p_group_tab             IN    WSH_FTE_COMP_CONSTRAINT_PKG.cc_group_tab_type,
                  x_failed_constraints    IN OUT NOCOPY    line_constraint_tab_type,
                  x_group_id              OUT NOCOPY       NUMBER,
                  x_found                 OUT NOCOPY       BOOLEAN,
                  x_return_status         OUT NOCOPY       VARCHAR2)
IS

    i                           NUMBER := 0;
    j                           NUMBER := 0;
    k                           NUMBER := 0;
    l                           NUMBER := 0;
    m                           NUMBER := 0;
    l_inp_items_cnt             NUMBER := 0;
    l_tgt_items_cnt             NUMBER := 0;
    l_const_count               NUMBER := 0;
    l_return_status             VARCHAR2(1);
    l_inp_dlvy_cus              BOOLEAN := TRUE;
    l_cuscus_checked            BOOLEAN := FALSE;
    l_curr_dlvy_cus             BOOLEAN := TRUE;
    l_checked_cus1_fac           BOOLEAN := FALSE;
    l_checked_cus2_fac           BOOLEAN := FALSE;
    l_checked_sup_fac           BOOLEAN := FALSE;
    l_validate_orgfac_result    VARCHAR2(1) := 'S';
    l_validate_cusfac_result    VARCHAR2(1) := 'S';
    l_validate_supfac_result    VARCHAR2(1) := 'S';
    l_validate_itmfac_result    VARCHAR2(1) := 'S';
    l_validate_cuscus_result    VARCHAR2(1) := 'S';
    l_validate_itmin_result     VARCHAR2(1) := 'S';
    l_validate_itmfacin_result  VARCHAR2(1) := 'S';
    l_validate_itmfacin_result2 VARCHAR2(1) := 'S';
    --l_validate_loop_result      VARCHAR2(1) := 'S';
    l_facility_id               NUMBER := 0;
    l_items_tab                 item_tab_type;
    l_target_items_tab          item_tab_type;
    l_locations_list            WSH_UTIL_CORE.id_tab_type;
    l_inp_locations_list        WSH_UTIL_CORE.id_tab_type;
    l_failed_constraint         line_constraint_rec_type;
    l_entity_rec                entity_rec_type;
    l_target_rec                entity_rec_type;
    l_check_pickup              BOOLEAN := FALSE;
    l_check_dropoff             BOOLEAN := FALSE;
    l_pu_sequencenum            NUMBER := NULL;
    l_pu_pa_date                DATE;
    l_do_sequencenum            NUMBER := NULL;
    l_do_pa_date                DATE;
    l_entity_id                 NUMBER := 0;
    l_shipment_direction        VARCHAR2(30) := NULL;
    l_org_id                    NUMBER := 0;
    l_cust_id                   NUMBER := 0;
    l_custfac_id                NUMBER := 0;
    l_supl_id                   NUMBER := 0;
    l_suplfac_id                NUMBER := 0;
    l_ini_pu_loc_id             NUMBER := 0;
    l_ult_do_loc_id             NUMBER := 0;

    --DUM_LOC
    l_physical_custfac_id	NUMBER := 0;
    --DUM_LOC
    l_obj_check_pickup          BOOLEAN := FALSE;
    l_obj_check_dropoff         BOOLEAN := FALSE;
    l_obj_itm_check_pickup          BOOLEAN := FALSE;
    l_obj_itm_check_dropoff         BOOLEAN := FALSE;

    l_module_name               CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'search_matching_group';
    l_debug_on                  CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;

BEGIN

    -- for assign delivery to trip
    -- might not need to check against locations of all other deliveries in a group
    -- for autocreate trip, still need to

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    IF l_debug_on THEN
       wsh_debug_sv.push(l_module_name);
    END IF;

      -- checks itm-itm , cus-cus
      -- itm-fac with pickup / dropoff locations
      -- com-fac, cus-fac with pickup / dropoff locations
      -- for every delivery
      -- against every other delivery

    IF NOT p_comp_class_tab.EXISTS(G_CUSTOMER_CUSTOMER_NUM) AND
       NOT p_comp_class_tab.EXISTS(G_ITEM_CARRIER_NUM) AND
       NOT p_comp_class_tab.EXISTS(G_ITEM_VEHICLE_NUM) AND
       NOT p_comp_class_tab.EXISTS(G_ITEM_MODE_NUM) THEN

      IF p_entity_type = 'DLVB' THEN
         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         --
         RETURN;
      END IF;
      l_cuscus_checked := TRUE;
    END IF;

    IF p_entity_rec.customer_id IS NULL THEN
       l_inp_dlvy_cus := FALSE;
    END IF;

    x_group_id  := -999; -- Means not found
    x_found     := FALSE;

    IF p_entity_type = 'DLVY' THEN

       l_inp_locations_list(l_inp_locations_list.COUNT + 1) := p_entity_rec.initial_pickup_location_id;
       l_inp_locations_list(l_inp_locations_list.COUNT + 1) := p_entity_rec.ultimate_dropoff_location_id;

    END IF;

    j := p_group_tab.FIRST;
    IF j IS NOT NULL THEN
      LOOP -- over p_group_tab

        l_items_tab.DELETE;
        l_locations_list.DELETE;
        l_target_items_tab.DELETE;
        --l_inp_locations_list.DELETE;
        --l_validate_orgfac_result := 'S';
        --l_validate_cusfac_result := 'S';
        --l_validate_supfac_result := 'S';
        --l_validate_itmfac_result := 'S';
        l_validate_cuscus_result := 'S';
        l_validate_itmin_result  := 'S';
        l_validate_itmfacin_result  := 'S';
        l_validate_itmfacin_result2 := 'S';

        k := p_entity_tab.FIRST;
        IF k IS NOT NULL THEN
          LOOP -- over p_entity_tab (for every other delivery)

           --l_items_tab.DELETE;
           l_curr_dlvy_cus := TRUE;
           l_checked_cus1_fac := FALSE;
           l_checked_cus2_fac := FALSE;
           l_checked_sup_fac := FALSE;
           --l_validate_loop_result := 'S';
           l_facility_id := NULL;
           l_check_pickup := FALSE;
           l_check_dropoff := FALSE;

	   IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'p_group_tab(j).line_group_id : '||p_group_tab(j).line_group_id);
                WSH_DEBUG_SV.logmsg(l_module_name,'p_entity_tab(k).entity_id : '||p_entity_tab(k).entity_id);
                WSH_DEBUG_SV.logmsg(l_module_name,'p_entity_tab(k).group_id : '||p_entity_tab(k).group_id);
           END IF;

           IF (p_entity_tab(k).entity_id = p_entity_rec.entity_id) OR
               (p_entity_tab(k).group_id <> p_group_tab(j).line_group_id) THEN  -- check against same group
               GOTO dlvy_nextpass;
           END IF;

           IF p_entity_tab(k).customer_id IS NULL THEN
               l_curr_dlvy_cus := FALSE;
           END IF;

           IF p_action_code = G_ASSIGN_DLVY_TRIP THEN

             -- p_target_stops_info.pickup_stop_id/dropoff_stop_id
             -- can be null but the stop location might already exist in
             -- the target trip
             -- In that case the following facility related
             -- checks are not necessary

	     IF p_target_stops_info.pickup_stop_id IS NULL THEN
                -- check if delivery's initial pu location id already exists
                -- in target trip
                OPEN c_get_stop(p_entity_rec.initial_pickup_location_id,p_target_trip_id);
                FETCH c_get_stop INTO l_pu_sequencenum,l_pu_pa_date;
                CLOSE c_get_stop;

             END IF;

             IF p_target_stops_info.dropoff_stop_id IS NULL THEN
                -- check if delivery's ultimate do location id already exists
                -- in target trip
                  OPEN c_get_stop(p_entity_rec.ultimate_dropoff_location_id,p_target_trip_id);
                  FETCH c_get_stop INTO l_do_sequencenum,l_do_pa_date;
                  CLOSE c_get_stop;
             END IF;

             IF p_target_stops_info.pickup_stop_id IS NULL AND
                l_pu_sequencenum IS NULL AND
                p_target_stops_info.pickup_location_id IS NULL AND
                (p_entity_rec.initial_pickup_location_id <> p_entity_tab(k).initial_pickup_location_id
                AND p_entity_rec.initial_pickup_location_id <> p_entity_tab(k).ultimate_dropoff_location_id)
             THEN
                  l_check_pickup := TRUE;
             END IF;

	     IF p_target_stops_info.dropoff_stop_id IS NULL AND
                l_do_sequencenum IS NULL AND
                p_target_stops_info.dropoff_location_id IS NULL AND
                (p_entity_rec.ultimate_dropoff_location_id <> p_entity_tab(k).ultimate_dropoff_location_id
                AND p_entity_rec.ultimate_dropoff_location_id <> p_entity_tab(k).initial_pickup_location_id)
             THEN
                  l_check_dropoff := TRUE;
             END IF;

           ELSIF p_action_code = G_AUTOCRT_DLVY_TRIP OR p_action_code = G_AUTOCRT_MDC THEN
             -- TODO
             -- Should ideally check dates here to determine what is intermediate stop
             IF (p_entity_rec.initial_pickup_location_id <> p_entity_tab(k).initial_pickup_location_id
                AND p_entity_rec.initial_pickup_location_id <> p_entity_tab(k).ultimate_dropoff_location_id)
             THEN
                 l_check_pickup := TRUE;
             END IF;

	     IF (p_entity_rec.ultimate_dropoff_location_id <> p_entity_tab(k).ultimate_dropoff_location_id
                AND p_entity_rec.ultimate_dropoff_location_id <> p_entity_tab(k).initial_pickup_location_id)
             THEN
                 l_check_dropoff := TRUE;
             END IF;

	   END IF;

           IF ((p_entity_type = 'DLVY' AND NOT l_cuscus_checked AND
             l_inp_dlvy_cus AND l_curr_dlvy_cus ) OR
             (p_entity_type = 'DLVB')) AND
             (p_entity_rec.customer_id <> p_entity_tab(k).customer_id) THEN

              l_cuscus_checked := TRUE;

              validate_constraint(   --  checks only negative constraints
                 p_comp_class_code          =>      G_CUSTOMER_CUSTOMER,
                 p_object1_type             =>      'CUS',
                 p_object2_type             =>      'CUS',
                 p_object1_val_num          =>      p_entity_rec.customer_id,
                 p_object2_val_num          =>      p_entity_tab(k).customer_id,
                 x_validate_result          =>      l_validate_cuscus_result,
                 x_failed_constraint        =>      l_failed_constraint,
                 x_return_status            =>      l_return_status);

              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;
              END IF;


              IF l_validate_cuscus_result <> 'S' THEN
                  l_failed_constraint.line_constraint_index := x_failed_constraints.COUNT+1;
                  l_failed_constraint.entity_type := p_entity_type;
                  l_failed_constraint.entity_line_id := p_entity_rec.entity_id;
                  x_failed_constraints(x_failed_constraints.COUNT+1) := l_failed_constraint;
                  IF l_validate_cuscus_result = 'E' THEN
                     EXIT;
                  END IF;
              END IF;
           END IF;

           IF (p_entity_type = 'DLVB') AND
            ((p_entity_rec.inventory_item_id <> p_entity_tab(k).inventory_item_id) OR
             (g_is_tp_installed = 'N' AND p_entity_rec.organization_id <> p_entity_tab(k).organization_id))  THEN


               l_const_count  := x_failed_constraints.COUNT;

               search_group_itm (
                      p_comp_class_tab      =>   p_comp_class_tab,
                      p_entity_rec          =>   p_entity_rec,
                      p_target_rec          =>   p_entity_tab(k),
                      x_validate_result     =>   l_validate_itmin_result,
                      x_failed_constraints  =>   x_failed_constraints,
                      x_return_status       =>   l_return_status);

               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                     raise FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
               END IF;

               IF ( l_const_count < x_failed_constraints.COUNT) THEN

                  x_failed_constraints.DELETE(l_const_count+1,x_failed_constraints.COUNT);

               END IF;

               IF l_validate_itmin_result = 'F' THEN
                  EXIT;
               END IF;

           END IF;

           IF p_entity_type = 'DLVB' THEN
                GOTO dlvy_nextpass;
           END IF;

           IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'p_children_info COUNT :'||p_children_info.COUNT);
           END IF;

	   l := p_children_info.FIRST;

	   IF l IS NOT NULL THEN -- --{
              LOOP    -- over p_children_info (for input dlvy entity)

                 IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'delivery_id of curr child :'||p_children_info(l).delivery_id||' p_entity_rec.entity_id : '||p_entity_rec.entity_id);
                 END IF;
                 IF (p_children_info(l).delivery_id <> p_entity_rec.entity_id) THEN
                    GOTO inpdlvyline_nextpass;
                 END IF;

                 l_obj_itm_check_pickup := FALSE;
                 l_obj_itm_check_dropoff := FALSE;

		 -- TODO
		 -- check if object2 is intermediate discretionary routing point
	         -- for object1
		    IF p_entity_tab(k).initial_pickup_date > p_entity_rec.initial_pickup_date AND
	                p_entity_tab(k).initial_pickup_date < p_entity_rec.ultimate_dropoff_date THEN
			    l_obj_itm_check_pickup := TRUE;
            END IF;

	         IF p_entity_tab(k).ultimate_dropoff_date > p_entity_rec.initial_pickup_date AND
			p_entity_tab(k).ultimate_dropoff_date < p_entity_rec.ultimate_dropoff_date THEN
			    l_obj_itm_check_dropoff := TRUE;
		    END IF;

             l_inp_items_cnt := l_items_tab.COUNT;
             l_items_tab(l_inp_items_cnt + 1).line_id := p_children_info(l).delivery_detail_id;
             l_items_tab(l_inp_items_cnt + 1).item_id := p_children_info(l).inventory_item_id;
	         l_items_tab(l_inp_items_cnt + 1).org_id  := p_children_info(l).organization_id;

	     IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'l_inp_items_cnt : '||to_char(l_inp_items_cnt + 1));
                WSH_DEBUG_SV.logmsg(l_module_name,'l_items_tab.COUNT :'||l_items_tab.COUNT);
             END IF;

		 -- cus-cus for input lines against other delivery if not before
                 IF (NOT l_cuscus_checked) AND (NOT l_inp_dlvy_cus) AND (l_curr_dlvy_cus) AND
                    (p_children_info(l).customer_id IS NOT NULL) AND
                    (p_children_info(l).customer_id <> p_entity_tab(k).customer_id) THEN -- --{

                   validate_constraint(   --  checks only negative constraints
                     p_comp_class_code          =>      G_CUSTOMER_CUSTOMER,
                     p_object1_type             =>      'CUS',
                     p_object2_type             =>      'CUS',
                     p_object1_val_num          =>      p_children_info(l).customer_id,
                     p_object2_val_num          =>      p_entity_tab(k).customer_id,
                     x_validate_result          =>      l_validate_cuscus_result,
                     x_failed_constraint        =>      l_failed_constraint,
                     x_return_status            =>      l_return_status);

                   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                         raise FND_API.G_EXC_UNEXPECTED_ERROR;
                      END IF;
                   END IF;

                   IF l_validate_cuscus_result <> 'S' THEN
                    l_failed_constraint.line_constraint_index := x_failed_constraints.COUNT+1;
                    l_failed_constraint.entity_type := p_entity_type;
                    l_failed_constraint.entity_line_id := p_entity_rec.entity_id;
                    x_failed_constraints(x_failed_constraints.COUNT+1) := l_failed_constraint;
                    IF l_validate_cuscus_result = 'E' THEN
                       EXIT;
                    END IF;
                   END IF;

                 END IF; -- --}

                 -- As Item - Item scoped out for phase I,

                 IF ((NOT l_cuscus_checked) AND (NOT l_curr_dlvy_cus)
                    AND ( l_inp_dlvy_cus OR p_children_info(l).customer_id IS NOT NULL)) OR
                    (p_comp_class_tab.EXISTS(G_ITEM_CARRIER_NUM) OR
                     p_comp_class_tab.EXISTS(G_ITEM_MODE_NUM) ) THEN -- --{

                   m := p_children_info.FIRST;
                   IF m IS NOT NULL THEN -- --{
                     LOOP    -- over p_children_info (for other dlvy )

                        IF (p_children_info(m).delivery_id <> p_entity_tab(k).entity_id) THEN
                           GOTO othdlvyline_nextpass;
                        END IF;

                        l_obj_itm_check_pickup := FALSE;
                        l_obj_itm_check_dropoff := FALSE;
                        -- Build a list of items in p_entity_tab here

                        l_tgt_items_cnt := l_target_items_tab.COUNT;
                        l_target_items_tab(l_tgt_items_cnt + 1).line_id := p_children_info(m).delivery_detail_id;
                        l_target_items_tab(l_tgt_items_cnt + 1).item_id := p_children_info(m).inventory_item_id;
                        l_target_items_tab(l_tgt_items_cnt + 1).org_id  := p_children_info(m).organization_id;

	                IF p_children_info(m).customer_id IS NOT NULL THEN

			            IF l_inp_dlvy_cus AND
                              p_entity_rec.customer_id <> p_children_info(m).customer_id THEN
                               -- cus-cus for input delivey against other lines if not before

                               validate_constraint(   --  checks only negative constraints
                                   p_object1_type             =>      'CUS',
                                   p_object2_type             =>      'CUS',
                                   p_comp_class_code          =>      G_CUSTOMER_CUSTOMER,
                                   p_object1_val_num          =>      p_entity_rec.customer_id,
                                   p_object2_val_num          =>      p_children_info(m).customer_id,
                                   x_validate_result          =>      l_validate_cuscus_result,
                                   x_failed_constraint        =>      l_failed_constraint,
                                   x_return_status            =>      l_return_status);

                               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                                  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                                     raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                  END IF;
                               END IF;

                               IF l_validate_cuscus_result <> 'S' THEN
                                l_failed_constraint.line_constraint_index := x_failed_constraints.COUNT+1;
                                l_failed_constraint.entity_type := p_entity_type;
                                l_failed_constraint.entity_line_id := p_entity_rec.entity_id;
                                x_failed_constraints(x_failed_constraints.COUNT+1) := l_failed_constraint;
                                IF l_validate_cuscus_result = 'E' THEN
                                   EXIT;
                                END IF;
                               END IF;

                           ELSIF p_children_info(l).customer_id IS NOT NULL AND
                                 p_children_info(l).customer_id <> p_children_info(m).customer_id  THEN
                               -- cus-cus for input lines against other lines if not before

                                validate_constraint(   --  checks only negative constraints
                                     p_comp_class_code          =>      G_CUSTOMER_CUSTOMER,
                                     p_object1_type             =>      'CUS',
                                     p_object2_type             =>      'CUS',
                                     p_object1_val_num          =>      p_children_info(l).customer_id,
                                     p_object2_val_num          =>      p_children_info(m).customer_id,
                                     x_validate_result          =>      l_validate_cuscus_result,
                                     x_failed_constraint        =>      l_failed_constraint,
                                     x_return_status            =>      l_return_status);

                                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                                    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                                       raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                    END IF;
                                END IF;

                                IF l_validate_cuscus_result <> 'S' THEN
                                 l_failed_constraint.line_constraint_index := x_failed_constraints.COUNT+1;
                                 --l_failed_constraint.entity_type := p_entity_type;
                                 --l_failed_constraint.entity_line_id := p_entity_rec.entity_id;
                                 l_failed_constraint.entity_type := G_DEL_DETAIL;
                                 l_failed_constraint.entity_line_id := p_children_info(l).delivery_detail_id;
                                 x_failed_constraints(x_failed_constraints.COUNT+1) := l_failed_constraint;
                                 IF l_validate_cuscus_result = 'E' THEN
                                    EXIT;
                                 END IF;
                                END IF;

                           END IF; -- l_inp_d

                        END IF; -- p_children_info(m).customer_id IS NOT NULL

                        l_const_count  := x_failed_constraints.COUNT;

                        l_entity_rec.entity_id := p_children_info(l).delivery_detail_id;
                        l_entity_rec.organization_id := p_children_info(l).organization_id;
                        l_entity_rec.inventory_item_id := p_children_info(l).inventory_item_id;
                        l_entity_rec.customer_id := p_children_info(l).customer_id;

                        l_target_rec.entity_id := p_children_info(m).delivery_detail_id;
                        l_target_rec.organization_id := p_children_info(m).organization_id;
                        l_target_rec.inventory_item_id := p_children_info(m).inventory_item_id;
                        l_target_rec.customer_id := p_children_info(m).customer_id;
                        --
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,'Created l_target_rec for assigned line : '||p_children_info(m).delivery_detail_id);
                        END IF;
                        --

                      IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,' l_entity_rec.inventory_item_id: '||l_entity_rec.inventory_item_id);
                        WSH_DEBUG_SV.logmsg(l_module_name,' l_target_rec.inventory_item_id: '||l_target_rec.inventory_item_id);
                        WSH_DEBUG_SV.logmsg(l_module_name,' l_entity_rec.organization_id: '||l_entity_rec.organization_id);
                        WSH_DEBUG_SV.logmsg(l_module_name,' l_target_rec.organization_id: '||l_target_rec.organization_id);
                        WSH_DEBUG_SV.logmsg(l_module_name,' g_is_tp_installed: '||g_is_tp_installed);
                      END IF;

                      IF ((l_entity_rec.inventory_item_id <> l_target_rec.inventory_item_id) OR
                        (g_is_tp_installed = 'N' AND l_entity_rec.organization_id <> l_target_rec.organization_id))  THEN
                        search_group_itm (
                            p_comp_class_tab      =>   p_comp_class_tab,
                            p_entity_rec          =>   l_entity_rec,
                            p_target_rec          =>   l_target_rec,
                            x_validate_result     =>   l_validate_itmin_result,
                            x_failed_constraints  =>   x_failed_constraints,
                            x_return_status       =>   l_return_status);

                        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                               raise FND_API.G_EXC_UNEXPECTED_ERROR;
                            END IF;
                        END IF;

                        IF ( l_const_count < x_failed_constraints.COUNT) THEN

                            x_failed_constraints.DELETE(l_const_count+1,x_failed_constraints.COUNT);

                        END IF;

                        IF l_validate_itmin_result = 'F' THEN
                           EXIT;
                        END IF;
                      END IF;

                        <<othdlvyline_nextpass>>

                        EXIT WHEN m= p_children_info.LAST;
                        m:= p_children_info.NEXT(m);

                     END LOOP;

                     IF l_validate_cuscus_result = 'E' OR l_validate_itmin_result = 'F' THEN
                        --l_validate_loop_result = 'F' OR l_validate_itmfac_result = 'E' THEN
                        --l_validate_loop_result = 'F' THEN
                        EXIT; -- exit out of input delivery line group
                              -- as some customer of target delivery line
                              -- violates against this input dlvy / line customer
                     END IF;

                   END IF; -- --}

                 END IF; -- --}
                 <<inpdlvyline_nextpass>>

                 EXIT WHEN l= p_children_info.LAST;
                 l:= p_children_info.NEXT(l);

              END LOOP;

              --IF l_validate_cuscus_result = 'E' OR l_validate_itmfac_result = 'E' OR
              IF l_validate_cuscus_result = 'E' OR
                 l_validate_itmin_result = 'F' THEN
                 --l_validate_loop_result = 'F' THEN
                 EXIT; -- exit out of target dlvy loop
                       -- as some item of input delivery
                       -- violates against this delivery facility / customer
              END IF;

           END IF; -- --}
           IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'l_items_tab.COUNT :'||l_items_tab.COUNT);
           END IF;

           IF l_check_pickup THEN

               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,' l_locations_list.COUNT : '||l_locations_list.COUNT||' initial_pickup loc : '||p_entity_tab(k).initial_pickup_location_id);
               END IF;

               l_locations_list(l_locations_list.COUNT + 1) := p_entity_tab(k).initial_pickup_location_id;
           END IF;
           IF l_check_dropoff THEN

               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,' l_locations_list.COUNT : '||l_locations_list.COUNT||' ultimate dropoff loc : '||p_entity_tab(k).ultimate_dropoff_location_id);
               END IF;

               l_locations_list(l_locations_list.COUNT + 1) := p_entity_tab(k).ultimate_dropoff_location_id;
           END IF;

           <<dlvy_nextpass>>

           EXIT WHEN k= p_entity_tab.LAST;
           k:= p_entity_tab.NEXT(k);

          END LOOP;
        END IF;

        -- Bug found in omfut11i
        -- Not checking list of locations of p_entity_rec
        -- against list of items in p_entity_tab in the current group

        IF p_entity_type = 'DLVY' AND l_locations_list.COUNT <> 0 THEN

           -- l_items_tab is list of items of p_entity_rec
           -- l_locations_list is list of locations of p_entity_tab

           l_const_count   := x_failed_constraints.COUNT;

           search_itm_fac_incl(
                       p_comp_class_tab     =>  p_comp_class_tab,
                       p_entity_type        =>  G_DELIVERY,
                       p_entity_id          =>  p_entity_rec.entity_id,
                       p_items_tab          =>  l_items_tab,
                       p_locations_list     =>  l_locations_list,
                       x_validate_result    =>  l_validate_itmfacin_result,
                       x_failed_constraints =>  x_failed_constraints,
                       x_return_status      =>  l_return_status);

           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                 raise FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
           END IF;

           IF ( l_const_count < x_failed_constraints.COUNT) THEN

               x_failed_constraints.DELETE(l_const_count+1,x_failed_constraints.COUNT);

           END IF;
        END IF;

        IF p_entity_type = 'DLVY' AND l_target_items_tab.COUNT <> 0 THEN

           -- l_target_items_tab is list of items of p_entity_tab
           -- l_inp_locations_list is list of locations of p_entity_rec

           l_const_count   := x_failed_constraints.COUNT;

           search_itm_fac_incl(
                       p_comp_class_tab     =>  p_comp_class_tab,
                       p_entity_type        =>  G_DELIVERY,
                       p_entity_id          =>  p_entity_rec.entity_id,
                       p_items_tab          =>  l_target_items_tab,
                       p_locations_list     =>  l_inp_locations_list,
                       x_validate_result    =>  l_validate_itmfacin_result2,
                       x_failed_constraints =>  x_failed_constraints,
                       x_return_status      =>  l_return_status);

           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                 raise FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
           END IF;

           IF ( l_const_count < x_failed_constraints.COUNT) THEN

               x_failed_constraints.DELETE(l_const_count+1,x_failed_constraints.COUNT);

           END IF;
        END IF;

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,' l_validate_cuscus_result: '||l_validate_cuscus_result);
            --WSH_DEBUG_SV.logmsg(l_module_name,' l_validate_itmfac_result: '||l_validate_itmfac_result);
            --WSH_DEBUG_SV.logmsg(l_module_name,' l_validate_orgfac_result: '||l_validate_orgfac_result);
            --WSH_DEBUG_SV.logmsg(l_module_name,' l_validate_loop_result: '||l_validate_loop_result);
            WSH_DEBUG_SV.logmsg(l_module_name,' l_validate_itmin_result: '||l_validate_itmin_result);
            WSH_DEBUG_SV.logmsg(l_module_name,' l_validate_itmfacin_result: '||l_validate_itmfacin_result);
            WSH_DEBUG_SV.logmsg(l_module_name,' l_validate_itmfacin_result2: '||l_validate_itmfacin_result2);
        END IF;

        --IF l_validate_cuscus_result <> 'E' AND l_validate_itmfac_result <> 'E'
        IF l_validate_cuscus_result <> 'E'
           --AND l_validate_orgfac_result <> 'E'
           --AND l_validate_loop_result <> 'F'
           AND l_validate_itmin_result <> 'F' AND l_validate_itmfacin_result <> 'F' AND l_validate_itmfacin_result2 <> 'F' THEN
                   x_group_id  := p_group_tab(j).line_group_id;
                   x_found     := TRUE;
                   EXIT; -- exit out of target group loop
                         -- as input delivery will belong to this group
        END IF;

        <<grp_nextpass>>

        EXIT WHEN j= p_group_tab.LAST;
        j:= p_group_tab.NEXT(j);

      END LOOP;
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
      WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.search_matching_group');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END search_matching_group;


PROCEDURE check_dleg_discretionary(
                 p_entity_type         IN VARCHAR2,
                 p_entity_id           IN NUMBER,
                 p_delivery_rec        IN delivery_ccinfo_rec_type,
                 p_comp_class_tab      IN WSH_UTIL_CORE.column_tab_type,
                 p_dleg_pick_up_loc_id  IN NUMBER,
                 p_dleg_drop_off_loc_id IN NUMBER,
                 p_dleg_pick_up_stop_id  IN NUMBER DEFAULT NULL,
                 p_dleg_drop_off_stop_id  IN NUMBER DEFAULT NULL,
                 p_detail_tab            IN detail_ccinfo_tab_type,
                 p_carrier               IN NUMBER,
                 p_mode                  IN VARCHAR2,
                 p_vehicle_type          IN NUMBER DEFAULT NULL,
                 x_failed_constraints  IN OUT NOCOPY line_constraint_tab_type,
                 x_validate_result     OUT NOCOPY VARCHAR2,
                 x_return_status       OUT NOCOPY VARCHAR2)
IS

    j                           NUMBER := 0;
    i                           NUMBER := 0;
    l_return_status             VARCHAR2(1);
    l_facility_id               NUMBER := 0;
    l_stop_id                   NUMBER := 0;
    l_failed_constraint         line_constraint_rec_type;
    l_validate_orgfac_result    VARCHAR2(1) := 'S';
    l_validate_cusfac_result    VARCHAR2(1) := 'S';
    l_validate_supfac_result    VARCHAR2(1) := 'S';
    l_validate_result           VARCHAR2(1) := 'S';
    l_physical_location_id      NUMBER := NULL;
    l_validate_itmfac_result    VARCHAR2(1) := 'S';
    l_validate_itmcar_result    VARCHAR2(1) := 'S';
    l_validate_itmveh_result    VARCHAR2(1) := 'S';
    l_validate_itmmod_result    VARCHAR2(1) := 'S';

    l_debug_on                  CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
    l_module_name               CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'check_dleg_discretionary';

BEGIN

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    x_validate_result := 'S';

    IF l_debug_on THEN
        wsh_debug_sv.push(l_module_name);
    END IF;

    -- ORG - FAC, CUS - FAC for delivery's org/cus against dleg's locations if sequence number
    --           of the dleg is non first/last in the delivery
    -- Not possible to check Inclusive constraint here
    -- as do not know all other stops
    -- sequence number is present but inclusive constraints are checked at the trip level only

    -- Supplier - Facility

       IF p_comp_class_tab.EXISTS(G_SHIPORG_FACILITY_NUM) AND
            p_delivery_rec.shipment_direction <> 'D' THEN
         -- Also need to check for constraints which have been defined for
         -- all facilities of a company

         --IF p_dleg_pick_up_loc_id IS NOT NULL AND p_dleg_pick_up_stop_id IS NULL AND
         IF p_dleg_pick_up_loc_id IS NOT NULL AND
            p_delivery_rec.initial_pickup_location_id <> p_dleg_pick_up_loc_id AND
            p_delivery_rec.ultimate_dropoff_location_id <> p_dleg_pick_up_loc_id THEN

           validate_constraint(   --  checks only negative constraints
             p_comp_class_code          =>      G_SHIPORG_FACILITY,
             p_object2_type             =>      'FAC',
             p_object1_val_num          =>      p_delivery_rec.organization_id,
             p_object2_val_num          =>      p_dleg_pick_up_loc_id,
             x_validate_result          =>      l_validate_orgfac_result,
             x_failed_constraint        =>      l_failed_constraint,
             x_return_status            =>      l_return_status);

           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                 raise FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
           END IF;

           IF l_validate_orgfac_result <> 'S' THEN
              l_failed_constraint.line_constraint_index := x_failed_constraints.COUNT+1;
              l_failed_constraint.entity_type :=  p_entity_type;
              l_failed_constraint.entity_line_id := p_entity_id;
              x_failed_constraints(x_failed_constraints.COUNT+1) := l_failed_constraint;
              IF l_validate_orgfac_result = 'E' THEN
               x_validate_result := 'F';
               l_validate_result := 'F';
              END IF;
           END IF;

         END IF;

         --IF p_dleg_drop_off_loc_id IS NOT NULL AND p_dleg_drop_off_stop_id IS NULL AND
         IF p_dleg_drop_off_loc_id IS NOT NULL AND
            p_delivery_rec.ultimate_dropoff_location_id <> p_dleg_drop_off_loc_id AND
            p_delivery_rec.initial_pickup_location_id <> p_dleg_drop_off_loc_id THEN

           validate_constraint(   --  checks only negative constraints
             p_comp_class_code          =>      G_SHIPORG_FACILITY,
             p_object2_type             =>      'FAC',
             p_object1_val_num          =>      p_delivery_rec.organization_id,
             p_object2_val_num          =>      p_dleg_drop_off_loc_id,
             x_validate_result          =>      l_validate_orgfac_result,
             x_failed_constraint        =>      l_failed_constraint,
             x_return_status            =>      l_return_status);

           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                 raise FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
           END IF;

           IF l_validate_orgfac_result <> 'S' THEN
              l_failed_constraint.line_constraint_index := x_failed_constraints.COUNT+1;
              l_failed_constraint.entity_type :=  p_entity_type;
              l_failed_constraint.entity_line_id := p_entity_id;
              x_failed_constraints(x_failed_constraints.COUNT+1) := l_failed_constraint;
              IF l_validate_orgfac_result = 'E' THEN
               x_validate_result := 'F';
               l_validate_result := 'F';
              END IF;
           END IF;

         END IF; -- p_delivery_rec.ultimate_dropoff_location_id

       END IF;

         -- CUS_FAC : for customer facility ie. ship to location as param1 as well
       IF p_comp_class_tab.EXISTS(G_CUSTOMER_FACILITY_NUM) AND
            p_delivery_rec.shipment_direction <> 'I' THEN

         FOR i IN 1..2 LOOP

           IF i = 1 THEN
              l_facility_id := p_dleg_pick_up_loc_id;
              l_stop_id := p_dleg_pick_up_stop_id;
           ELSE
              l_facility_id := p_dleg_drop_off_loc_id;
              l_stop_id := p_dleg_drop_off_stop_id;
           END IF;

           --IF l_facility_id IS NOT NULL AND l_stop_id IS NULL AND
           IF l_facility_id IS NOT NULL AND
              p_delivery_rec.initial_pickup_location_id <> l_facility_id AND p_delivery_rec.ultimate_dropoff_location_id <> l_facility_id THEN
             IF p_delivery_rec.customer_id IS NOT NULL THEN

                   validate_constraint(   --  checks only negative constraints
                     p_comp_class_code          =>      G_CUSTOMER_FACILITY,
                     p_object1_type             =>      'CUS',
                     p_object2_type             =>      'FAC',
                     p_object1_val_num          =>      p_delivery_rec.customer_id,
                     p_object2_val_num          =>      l_facility_id,
                     x_validate_result          =>      l_validate_cusfac_result,
                     x_failed_constraint        =>      l_failed_constraint,
                     x_return_status            =>      l_return_status);

                   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                         raise FND_API.G_EXC_UNEXPECTED_ERROR;
                      END IF;
                   END IF;

                   IF l_validate_cusfac_result <> 'S' THEN
                      l_failed_constraint.line_constraint_index := x_failed_constraints.COUNT+1;
                      l_failed_constraint.entity_type :=  p_entity_type;
                      l_failed_constraint.entity_line_id := p_entity_id;
                      x_failed_constraints(x_failed_constraints.COUNT+1) := l_failed_constraint;
                      IF l_validate_cusfac_result = 'E' THEN
                       x_validate_result := 'F';
                       l_validate_result := 'F';
                      END IF;
                   END IF;
             END IF; -- p_delivery_rec.customer_id IS NOT NULL

             IF p_delivery_rec.ultimate_dropoff_location_id IS NOT NULL THEN

                   validate_constraint(   --  checks only negative constraints
                     p_comp_class_code          =>      G_CUSTOMER_FACILITY,
                     p_object1_type             =>      'FAC',
                     p_object2_type             =>      'FAC',
                     p_object1_val_num          =>      p_delivery_rec.ultimate_dropoff_location_id,
                     p_object1_physical_id      =>      p_delivery_rec.physical_dropoff_location_id,
                     p_object2_val_num          =>      l_facility_id,
                     x_validate_result          =>      l_validate_cusfac_result,
                     x_failed_constraint        =>      l_failed_constraint,
                     x_return_status            =>      l_return_status);

                   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                         raise FND_API.G_EXC_UNEXPECTED_ERROR;
                      END IF;
                   END IF;


                   IF l_validate_cusfac_result <> 'S' THEN
                      l_failed_constraint.line_constraint_index := x_failed_constraints.COUNT+1;
                      l_failed_constraint.entity_type :=  p_entity_type;
                      l_failed_constraint.entity_line_id := p_entity_id;
                      x_failed_constraints(x_failed_constraints.COUNT+1) := l_failed_constraint;
                      IF l_validate_cusfac_result = 'E' THEN
                       x_validate_result := 'F';
                       l_validate_result := 'F';
                      END IF;
                   END IF;
             END IF; -- p_delivery_rec.ULTIMATE_DROPOFF_LOCATION_ID IS NOT NULL
            END IF;  -- p_delivery_rec.ultimate_dropoff_location_id

         END LOOP;

       END IF; -- G_CUSTOMER_FACILITY

       IF p_comp_class_tab.EXISTS(G_SUPPLIER_FACILITY_NUM) AND
            p_delivery_rec.shipment_direction <> 'O' THEN

         FOR i IN 1..2 LOOP

           IF i = 1 THEN
              l_facility_id := p_dleg_pick_up_loc_id;
              l_stop_id := p_dleg_pick_up_stop_id;
           ELSE
              l_facility_id := p_dleg_drop_off_loc_id;
              l_stop_id := p_dleg_drop_off_stop_id;
           END IF;

           --IF l_facility_id IS NOT NULL AND l_stop_id IS NULL AND
           IF l_facility_id IS NOT NULL AND
              p_delivery_rec.initial_pickup_location_id <> l_facility_id AND p_delivery_rec.ultimate_dropoff_location_id <> l_facility_id THEN
             IF p_delivery_rec.party_id IS NOT NULL THEN

                   validate_constraint(   --  checks only negative constraints
                     p_comp_class_code          =>      G_SUPPLIER_FACILITY,
                     p_object1_type             =>      'SUP',
                     p_object2_type             =>      'FAC',
                     p_object1_val_num          =>      p_delivery_rec.party_id,
                     p_object2_val_num          =>      l_facility_id,
                     x_validate_result          =>      l_validate_supfac_result,
                     x_failed_constraint        =>      l_failed_constraint,
                     x_return_status            =>      l_return_status);

                   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                         raise FND_API.G_EXC_UNEXPECTED_ERROR;
                      END IF;
                   END IF;


                   IF l_validate_supfac_result <> 'S' THEN
                      l_failed_constraint.line_constraint_index := x_failed_constraints.COUNT+1;
                      l_failed_constraint.entity_type :=  p_entity_type;
                      l_failed_constraint.entity_line_id := p_entity_id;
                      x_failed_constraints(x_failed_constraints.COUNT+1) := l_failed_constraint;
                      IF l_validate_supfac_result = 'E' THEN
                       x_validate_result := 'F';
                       l_validate_result := 'F';
                      END IF;
                   END IF;
             END IF; -- p_delivery_rec.party_id IS NOT NULL

             IF p_delivery_rec.initial_pickup_location_id IS NOT NULL THEN

                   validate_constraint(   --  checks only negative constraints
                     p_comp_class_code          =>      G_SUPPLIER_FACILITY,
                     p_object1_type             =>      'FAC',
                     p_object2_type             =>      'FAC',
                     p_object1_val_num          =>      p_delivery_rec.initial_pickup_location_id,
                     p_object2_val_num          =>      l_facility_id,
                     x_validate_result          =>      l_validate_supfac_result,
                     x_failed_constraint        =>      l_failed_constraint,
                     x_return_status            =>      l_return_status);

                   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                         raise FND_API.G_EXC_UNEXPECTED_ERROR;
                      END IF;
                   END IF;

                   IF l_validate_supfac_result <> 'S' THEN
                      l_failed_constraint.line_constraint_index := x_failed_constraints.COUNT+1;
                      l_failed_constraint.entity_type :=  p_entity_type;
                      l_failed_constraint.entity_line_id := p_entity_id;
                      x_failed_constraints(x_failed_constraints.COUNT+1) := l_failed_constraint;
                      IF l_validate_supfac_result = 'E' THEN
                       x_validate_result := 'F';
                       l_validate_result := 'F';
                      END IF;
                   END IF;
             END IF; -- p_delivery_rec.initial_pickup_location_id IS NOT NULL
           END IF;  -- p_delivery_rec.ultimate_dropoff_location_id

         END LOOP;

       END IF; -- G_SUPPLIER_FACILITY

            -- TODOAG (DONE)
            -- check p_delivery_rec 's item against p_target_stops_info.pickup/dropoff_location_id
	    -- only if it is not null and p_target_stops_info.pickup/dropoff_stop_id s have not been passed (null)

       -- LOOP over input items
       j := p_detail_tab.FIRST;
       IF j IS NOT NULL THEN
        LOOP

          IF  p_detail_tab(j).delivery_id <> p_delivery_rec.delivery_id THEN
             GOTO det_next;
          END IF;

	  IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'p_entity_type : '||p_entity_type);
          END IF;

	    --SBAKSHI (ITM_FAC)
         --IF p_dleg_pick_up_loc_id IS NOT NULL AND p_dleg_pick_up_stop_id IS NULL AND
         IF p_dleg_pick_up_loc_id IS NOT NULL AND
            p_delivery_rec.initial_pickup_location_id <> p_dleg_pick_up_loc_id AND
            p_delivery_rec.ultimate_dropoff_location_id <> p_dleg_pick_up_loc_id THEN

	      -- A new delivery leg is being created, We need to validate for ITM_FAC constraint
              -- for the new location ie  p_target_stops_info.pickup_location_id

               IF p_comp_class_tab.EXISTS(G_ITEM_FACILITY_NUM) THEN

		 validate_constraint(   --  checks only negative constraints
                  p_comp_class_code          =>  G_ITEM_FACILITY,
                  p_object1_type             =>  'ITM',
                  p_object1_parent_id        =>  p_detail_tab(j).organization_id,
                  p_object1_val_num          =>  p_detail_tab(j).inventory_item_id,
                  p_object2_type             =>  'FAC',
                  p_object2_val_num          =>  p_dleg_pick_up_loc_id,
                  x_validate_result          =>  l_validate_itmfac_result,
                  x_failed_constraint        =>  l_failed_constraint,
                  x_return_status            =>  l_return_status);

                  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                       raise FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
                  END IF;

                  IF l_validate_itmfac_result <> 'S' THEN
                      l_failed_constraint.line_constraint_index := x_failed_constraints.COUNT+1;
                      l_failed_constraint.entity_type := G_DEL_DETAIL;
                      l_failed_constraint.entity_line_id := p_detail_tab(j).delivery_detail_id;
                      x_failed_constraints(x_failed_constraints.COUNT+1) := l_failed_constraint;

		    IF l_validate_itmfac_result = 'E' THEN
                       x_validate_result := 'F';
                       l_validate_result := 'F';
                    END IF;
                   END IF;

		END IF;

	      END IF;

         --IF p_dleg_drop_off_loc_id IS NOT NULL AND p_dleg_drop_off_stop_id IS NULL AND
         IF p_dleg_drop_off_loc_id IS NOT NULL AND
            p_delivery_rec.ultimate_dropoff_location_id <> p_dleg_drop_off_loc_id AND
            p_delivery_rec.initial_pickup_location_id <> p_dleg_drop_off_loc_id THEN

		IF p_comp_class_tab.EXISTS(G_ITEM_FACILITY_NUM) THEN


		  validate_constraint(   --  checks only negative constraints
                     p_comp_class_code          =>  G_ITEM_FACILITY,
                     p_object1_type             =>  'ITM',
                     p_object1_parent_id        =>  p_detail_tab(j).organization_id,
                     p_object1_val_num          =>  p_detail_tab(j).inventory_item_id,
                     p_object2_type             =>  'FAC',
                     p_object2_val_num          =>  p_dleg_drop_off_loc_id,
                     x_validate_result          =>  l_validate_itmfac_result,
                     x_failed_constraint        =>  l_failed_constraint,
                     x_return_status            =>  l_return_status);

                    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                         raise FND_API.G_EXC_UNEXPECTED_ERROR;
                      END IF;
                    END IF;

                 IF l_validate_itmfac_result <> 'S' THEN
                   l_failed_constraint.line_constraint_index := x_failed_constraints.COUNT+1;
                   l_failed_constraint.entity_type := G_DEL_DETAIL;
                   l_failed_constraint.entity_line_id := p_detail_tab(j).delivery_detail_id;
                   x_failed_constraints(x_failed_constraints.COUNT+1) := l_failed_constraint;
                   IF l_validate_itmfac_result = 'E' THEN
                      x_validate_result := 'F';
                      l_validate_result := 'F';
                   END IF;
                 END IF;
               END IF;

	    END IF;

	  --SBAKSHI (ITM_FAC)

          IF p_comp_class_tab.EXISTS(G_ITEM_MODE_NUM) AND
             p_mode IS NOT NULL THEN

           validate_constraint(   --  checks only negative constraints
             p_comp_class_code          =>      G_ITEM_MODE,
             p_object1_type             =>      'ITM',
             p_object1_parent_id        =>      p_detail_tab(j).organization_id,
             p_object2_type             =>      'MOD',
             p_object1_val_num          =>      p_detail_tab(j).inventory_item_id,
             p_object2_val_char         =>      p_mode,
             x_validate_result          =>      l_validate_itmmod_result,
             x_failed_constraint        =>      l_failed_constraint,  -- id
             x_return_status            =>      l_return_status);

           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                 raise FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
           END IF;

           IF l_validate_itmmod_result <> 'S' THEN
              l_failed_constraint.line_constraint_index := x_failed_constraints.COUNT+1;
              l_failed_constraint.entity_type := G_DEL_DETAIL;
              l_failed_constraint.entity_line_id := p_detail_tab(j).delivery_detail_id;
              x_failed_constraints(x_failed_constraints.COUNT+1) := l_failed_constraint;
              IF l_validate_itmmod_result = 'E' THEN
                 x_validate_result := 'F';
                 l_validate_result := 'F';
              END IF;
           END IF;

         END IF;

         IF p_comp_class_tab.EXISTS(G_ITEM_CARRIER_NUM) AND
            p_carrier IS NOT NULL THEN

           validate_constraint(   --  checks only negative constraints
             p_comp_class_code          =>      G_ITEM_CARRIER,
             p_object1_type             =>      'ITM',
             p_object1_parent_id        =>      p_detail_tab(j).organization_id,
             p_object2_type             =>      'CAR',
             p_object1_val_num          =>      p_detail_tab(j).inventory_item_id,
             p_object2_val_num          =>      p_carrier,
             x_validate_result          =>      l_validate_itmcar_result,
             x_failed_constraint        =>      l_failed_constraint,  -- id
             x_return_status            =>      l_return_status);

           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                 raise FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
           END IF;

           IF l_validate_itmcar_result <> 'S' THEN
              l_failed_constraint.line_constraint_index := x_failed_constraints.COUNT+1;
              l_failed_constraint.entity_type := G_DEL_DETAIL;
              l_failed_constraint.entity_line_id := p_detail_tab(j).delivery_detail_id;
              x_failed_constraints(x_failed_constraints.COUNT+1) := l_failed_constraint;
              IF l_validate_itmcar_result = 'E' THEN
                 x_validate_result := 'F';
                 l_validate_result := 'F';
              END IF;
           END IF;

         END IF;

         IF p_comp_class_tab.EXISTS(G_ITEM_VEHICLE_NUM) AND
            p_vehicle_type IS NOT NULL THEN

           validate_constraint(   --  checks only negative constraints
             p_comp_class_code          =>      G_ITEM_VEHICLE,
             p_object1_type             =>      'ITM',
             p_object1_parent_id        =>      p_detail_tab(j).organization_id,
             p_object2_type             =>      'VHT',
             p_object1_val_num          =>      p_detail_tab(j).inventory_item_id,
             p_object2_val_num          =>      p_vehicle_type,
             x_validate_result          =>      l_validate_itmveh_result,
             x_failed_constraint        =>      l_failed_constraint,  -- id
             x_return_status            =>      l_return_status);

           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                 raise FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
           END IF;

           IF l_validate_itmveh_result <> 'S' THEN
              l_failed_constraint.line_constraint_index := x_failed_constraints.COUNT+1;
              l_failed_constraint.entity_type := G_DEL_DETAIL;
              l_failed_constraint.entity_line_id := p_detail_tab(j).delivery_detail_id;
              x_failed_constraints(x_failed_constraints.COUNT+1) := l_failed_constraint;
              IF l_validate_itmveh_result = 'E' THEN
                 x_validate_result := 'F';
                 l_validate_result := 'F';
              END IF;
           END IF;

         END IF;

         <<det_next>>

         EXIT WHEN j= p_detail_tab.LAST;
         j:= p_detail_tab.NEXT(j);

        END LOOP; -- p_detail_tab
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
      WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.check_dleg_discretionary');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END check_dleg_discretionary;

--***************************************************************************--
--
--========================================================================
-- PROCEDURE : check_dlvy_against_trip    PRIVATE
--
-- PARAMETERS: p_entity_type              Entity for which check is running
--             p_entity_id                Entity id for which check is running
--             p_delivery_rec             Input delivery record
--             p_detail_tab               Children detail records of input delivery record
--             p_comp_class_tab           Table of Compatibility class codes to check
--             p_target_stops_info        Input pickup and dropoff stop/location of the delivery(s)
--                                        in the target trip in case of assign delivery to trip
--             p_target_trip              Target trip record
--             p_target_tripstops         Children stops already present in target trip
--             p_target_dlvy              Childrent deliveries already present in target trip
--             p_target_dlvy_lines        Childrent delivery details already present in target trip
--             x_failed_constraints       Failed constraint table
--             x_validate_result          Constraint Validation result : S / F
--             x_return_status            Return status
-- COMMENT   :
-- For a given delivery and a target trip
-- determines if the delivery can be assigned to the target trip
-- satisfying exclusive constraints
--========================================================================

PROCEDURE check_dlvy_against_trip(
                 p_entity_type         IN VARCHAR2,
                 p_entity_id           IN NUMBER,
                 p_delivery_rec        IN delivery_ccinfo_rec_type,
                 p_detail_tab          IN detail_ccinfo_tab_type,
                 p_comp_class_tab      IN WSH_UTIL_CORE.column_tab_type,
                 p_target_stops_info   IN target_tripstop_cc_rec_type,
                 p_target_trip         IN trip_ccinfo_rec_type,
                 p_target_tripstops    IN stop_ccinfo_tab_type,
                 p_target_dlvy         IN delivery_ccinfo_tab_type,
                 p_target_dlvy_lines   IN detail_ccinfo_tab_type,
                 x_failed_constraints  IN OUT NOCOPY line_constraint_tab_type,
                 x_validate_result     OUT NOCOPY VARCHAR2,
                 x_return_status       OUT NOCOPY VARCHAR2)
IS

    --SBAKSHI
    CURSOR c_get_pickup_dropoff_dates(p_delivery_id IN NUMBER, p_trip_id IN NUMBER) IS
    SELECT wts1.planned_arrival_date, wts2.planned_arrival_date
    FROM   wsh_trip_stops wts1, wsh_trip_stops wts2, wsh_delivery_legs wdl
    WHERE  wts1.trip_id = p_trip_id
    AND    wts2.trip_id = p_trip_id
    AND    wdl.delivery_id = p_delivery_id
    AND    wts1.stop_id = wdl.pick_up_stop_id
    AND    wts2.stop_id = wdl.drop_off_stop_id;


    l_checked_dlvb_cnt          NUMBER := 0;
    l_checked_dlvy_cnt          NUMBER := 0;
    z                           NUMBER := 0;
    j                           NUMBER := 0;
    k                           NUMBER := 0;
    l                           NUMBER := 0;
    m                           NUMBER := 0;
    l_inp_customer_id           NUMBER := 0;
    --#SBAKSHI(08/24)
    l_idx			NUMBER := 0;
    --#SBAKSHI(08/24)
    l_carrier                   NUMBER := NULL;
    l_location_id               NUMBER := NULL;
    l_vehicle_type              NUMBER := NULL;
    l_mode                      VARCHAR2(30) := NULL;
    l_service_level             VARCHAR2(30) := NULL;
    l_carrier_service_inout_rec WSH_CARRIERS_GRP.Carrier_Service_InOut_Rec_Type;
    l_inp_items_cnt             NUMBER := 0;
    l_const_count               NUMBER := 0;
    l_return_status             VARCHAR2(1);
    l_inp_dlvy_cus              BOOLEAN := TRUE;
    l_curr_dlvy_cus             BOOLEAN := TRUE;
    l_cusfac_checked            BOOLEAN := FALSE;
    l_supfac_checked            BOOLEAN := FALSE;
    l_checked_cus_fac           BOOLEAN := FALSE;
    l_cuscus_checked            BOOLEAN := FALSE;
    l_dlvycuscus_checked        BOOLEAN := FALSE;
    l_targetdlvy_cusfac_checked BOOLEAN := FALSE;
    l_targetdlvy_supfac_checked BOOLEAN := FALSE;
    l_validate_result           VARCHAR2(1) := 'S';
    l_validate_cuscus_result    VARCHAR2(1) := 'S';
    l_validate_carrier_result   VARCHAR2(1) := 'S';
    l_validate_vehicle_result   VARCHAR2(1) := 'S';
    l_validate_mode_result      VARCHAR2(1) := 'S';
    l_validate_orgfac_result    VARCHAR2(1) := 'S';
    l_validate_cusfac_result    VARCHAR2(1) := 'S';
    l_validate_supfac_result    VARCHAR2(1) := 'S';
    l_validate_itmfac_result    VARCHAR2(1) := 'S';
    l_failed_constraint         line_constraint_rec_type;
    l_validate_itmcar_result    VARCHAR2(1) := 'S';
    l_validate_itmveh_result    VARCHAR2(1) := 'S';
    l_validate_itmmod_result    VARCHAR2(1) := 'S';
    l_validate_itmin_result     VARCHAR2(1) := 'S';
    l_validate_itmfacin_result  VARCHAR2(1) := 'S';
    l_items_tab                 item_tab_type;
    l_locations_list            WSH_UTIL_CORE.id_tab_type;
    l_entity_rec                entity_rec_type;
    l_target_rec                entity_rec_type;
    l_pu_location_id            NUMBER := NULL;
    l_pu_sequencenum            NUMBER := NULL;
    l_pu_pa_date                DATE;
    l_do_location_id            NUMBER := NULL;
    l_do_sequencenum            NUMBER := NULL;
    l_do_pa_date                DATE;
    l_checked_inpdlvb           WSH_UTIL_CORE.id_tab_type;
    l_checked_target_dlvy       WSH_UTIL_CORE.id_tab_type;

    l_vehicle_name              VARCHAR2(2000);
    l_vehicle_org_name          VARCHAR2(240);

    l_input_pu_location_id      NUMBER := NULL;
    l_input_do_location_id      NUMBER := NULL;
    l_dleg_loc_id               NUMBER := NULL;
    p                           NUMBER := NULL;


    l_module_name               CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'check_dlvy_against_trip';
    l_debug_on                  CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;

    --SBAKSHI
    l_trp_dlvy_pickup_date      DATE;
    l_trp_dlvy_dropoff_date	DATE;

    --SBAKSHI

BEGIN

    -- for assign delivery to trip
    -- might not need to check against all stops of the target trip

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    x_validate_result := 'S';

    IF l_debug_on THEN
        wsh_debug_sv.push(l_module_name);
        WSH_DEBUG_SV.logmsg(l_module_name,'p_entity_type    '||p_entity_type);
	WSH_DEBUG_SV.logmsg(l_module_name,'target_tripstop count '|| p_target_tripstops.COUNT);
        WSH_DEBUG_SV.logmsg(l_module_name,'target_dlvy count '|| p_target_dlvy.COUNT);
        WSH_DEBUG_SV.logmsg(l_module_name,'target_dlvy_lines count '|| p_target_dlvy_lines.COUNT);
        WSH_DEBUG_SV.logmsg(l_module_name,'p_delivery_rec.initial_pickup_location '|| p_delivery_rec.initial_pickup_location_id);
        WSH_DEBUG_SV.logmsg(l_module_name,'p_delivery_rec.ultimate_dropoff_location '|| p_delivery_rec.ultimate_dropoff_location_id);
        WSH_DEBUG_SV.logmsg(l_module_name,'p_target_stops_info.pickup_location_id '|| p_target_stops_info.pickup_location_id);
        WSH_DEBUG_SV.logmsg(l_module_name,'p_target_stops_info.dropoff_location_id '|| p_target_stops_info.dropoff_location_id);
    END IF;

         -- Here check the delivery against target trip for exclusive constraints
         -- com -fac, cus - fac, itm - fac for each delivery against trip stops
         -- Are we going to get planned stop sequence of pickup and dropoff stop of delivery
         -- itm -mod, itm - car and fac-mod, fac-car
         -- Need not check fac -car/mod if called for a dleg
         -- org - car, org - mode will not be stored in constraints table 11/6
         -- itm - itm, cus - cus
         -- Any delivery that is violating, remove from the group

     -- Check fac-mod, fac-car
     -- between p_delivery_rec and p_target_trip
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'p_target_trip.carrier_id    '||p_target_trip.carrier_id);
        WSH_DEBUG_SV.logmsg(l_module_name,'p_target_trip.mode_of_transport    '||p_target_trip.mode_of_transport);
        WSH_DEBUG_SV.logmsg(l_module_name,'p_target_trip.ship_method_code    '||p_target_trip.ship_method_code);
    END IF;

    IF (p_target_trip.carrier_id IS NULL OR p_target_trip.mode_of_transport IS NULL) AND
         (p_target_trip.ship_method_code IS NOT NULL) THEN

      l_carrier_service_inout_rec.ship_method_code := p_target_trip.ship_method_code;

      WSH_CARRIERS_GRP.get_carrier_service_mode(
               p_carrier_service_inout_rec   =>  l_carrier_service_inout_rec,
               x_return_status               =>  l_return_status);

      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
         IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
         raise g_get_carrmode_failed;
        END IF;
      END IF;

      l_carrier := l_carrier_service_inout_rec.carrier_id;
      l_mode    := l_carrier_service_inout_rec.mode_of_transport;

    END IF; -- p_target_trip.carrier_id IS NULL OR ..

      -- If carrier_id or mode is passed in, then those get preference for validation
      -- If they are not, they are derived from ship method if that is passed

    IF p_target_trip.carrier_id IS NOT NULL THEN
       l_carrier := p_target_trip.carrier_id;
    END IF;
    IF p_target_trip.MODE_OF_TRANSPORT IS NOT NULL THEN
       l_mode := p_target_trip.MODE_OF_TRANSPORT;
    END IF;

    IF (p_target_trip.VEHICLE_ITEM_ID IS NOT NULL AND p_target_trip.VEHICLE_ORGANIZATION_ID IS NOT NULL) THEN

      WSH_FTE_INTEGRATION.get_vehicle_type(
               p_vehicle_item_id     =>  p_target_trip.VEHICLE_ITEM_ID,
               p_vehicle_org_id      =>  p_target_trip.VEHICLE_ORGANIZATION_ID,
               x_vehicle_type_id     =>  l_vehicle_type,
               x_return_status       =>  l_return_status);

      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
         IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
            l_vehicle_name := WSH_UTIL_CORE.get_item_name (p_item_id => p_target_trip.VEHICLE_ITEM_ID,
                                                           p_organization_id => p_target_trip.VEHICLE_ORGANIZATION_ID);
            l_vehicle_org_name := WSH_UTIL_CORE.get_org_name (p_organization_id => p_target_trip.VEHICLE_ORGANIZATION_ID);
            FND_MESSAGE.SET_NAME('WSH','WSH_VEHICLE_TYPE_UNDEFINED');
            FND_MESSAGE.SET_TOKEN('ITEM',l_vehicle_name);
            FND_MESSAGE.SET_TOKEN('ORGANIZATION',l_vehicle_org_name);
            FND_MSG_PUB.ADD;
            --raise g_get_vehicletype_failed;
         END IF;
      END IF;

    END IF; -- p_target_trip.VEHICLE_ITEM_ID IS NOT NULL AND ..

    -- When the code comes here,
    -- for DLVY, only pickup/dropoff stop/location NULL case needs to be
    -- taken care of for facility - car/mod/veh
    -- for DLEG, it never needs to be checked
    -- dleg trip search will find any trip having either dleg pu loc OR do loc
    -- Hence should do fac-car/mod/veh check if a stop not already exists
    -- in the target trip with that location

    -- Even when pickup/drop off stop ids are null,
    -- the delivery's initial pu/ultimate do stops might already
    -- exist in the target trip

    IF p_target_stops_info.pickup_stop_id IS NOT NULL THEN

         OPEN c_get_stop_location(p_target_stops_info.pickup_stop_id);
         FETCH c_get_stop_location INTO l_pu_location_id,l_pu_sequencenum,l_pu_pa_date;
         CLOSE c_get_stop_location;

         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'l_pu_location_id    '||l_pu_location_id);
            WSH_DEBUG_SV.logmsg(l_module_name,'l_pu_sequencenum    '||l_pu_sequencenum);
            WSH_DEBUG_SV.logmsg(l_module_name,'l_pu_pa_date    '||l_pu_pa_date);
        END IF;

    ELSIF p_target_stops_info.pickup_location_id IS NOT NULL THEN

       l_pu_location_id := p_target_stops_info.pickup_location_id;
       --IF p_entity_type <> 'DLEG' THEN
       --IF p_target_stops_info.pickup_stop_seq IS NOT NULL THEN
       IF p_target_stops_info.pickup_stop_pa_date IS NOT NULL THEN
         l_pu_pa_date := p_target_stops_info.pickup_stop_pa_date;
         l_pu_sequencenum := p_target_stops_info.pickup_stop_seq;
       ELSE

         -- p_target_stops_info.pickup_location_id has to be a stop location of this trip
         -- for the input delivery leg to match this trip  HB 07/01/03
         -- we need to consider all stop locations after that stop location
         OPEN c_get_stop(p_target_stops_info.pickup_location_id,p_target_trip.trip_id);
         FETCH c_get_stop INTO l_pu_sequencenum,l_pu_pa_date;
         CLOSE c_get_stop;

         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'l_pu_location_id 11    '||p_target_stops_info.pickup_location_id);
            WSH_DEBUG_SV.logmsg(l_module_name,'l_pu_sequencenum 11   '||l_pu_sequencenum);
            WSH_DEBUG_SV.logmsg(l_module_name,'l_pu_pa_date  11  '||l_pu_pa_date);
        END IF;

       END IF;

    ELSIF p_target_stops_info.pickup_stop_id IS NULL THEN
       -- check if delivery's initial pu location id already exists
       -- in target trip
         OPEN c_get_stop(p_delivery_rec.initial_pickup_location_id,p_target_trip.trip_id);
         FETCH c_get_stop INTO l_pu_sequencenum,l_pu_pa_date;
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'rowcount c_get_stop : '|| c_get_stop%rowcount ||' for deliverys initial pu : '||p_delivery_rec.initial_pickup_location_id);
         END IF;
         CLOSE c_get_stop;

    END IF;

    IF p_target_stops_info.dropoff_stop_id IS NOT NULL THEN

         OPEN c_get_stop_location(p_target_stops_info.dropoff_stop_id);
         FETCH c_get_stop_location INTO l_do_location_id,l_do_sequencenum,l_do_pa_date;
         CLOSE c_get_stop_location;

    ELSIF p_target_stops_info.dropoff_location_id IS NOT NULL THEN

       l_do_location_id := p_target_stops_info.dropoff_location_id;
       --IF p_entity_type <> 'DLEG' THEN
       --IF p_target_stops_info.dropoff_stop_seq IS NOT NULL THEN
       IF p_target_stops_info.dropoff_stop_pa_date IS NOT NULL THEN
         l_do_pa_date := p_target_stops_info.dropoff_stop_pa_date;
         l_do_sequencenum := p_target_stops_info.dropoff_stop_seq;
       ELSE
         OPEN c_get_stop(p_target_stops_info.dropoff_location_id,p_target_trip.trip_id);
         FETCH c_get_stop INTO l_do_sequencenum,l_do_pa_date;
         CLOSE c_get_stop;

       END IF;

    ELSIF p_target_stops_info.dropoff_stop_id IS NULL THEN
       -- check if delivery's ultimate do location id already exists
       -- in target trip
         OPEN c_get_stop(p_delivery_rec.ultimate_dropoff_location_id,p_target_trip.trip_id);
         FETCH c_get_stop INTO l_do_sequencenum,l_do_pa_date;
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'rowcount c_get_stop : '|| c_get_stop%rowcount ||' for deliverys ultimate do : '||p_delivery_rec.ultimate_dropoff_location_id);
         END IF;
         CLOSE c_get_stop;
    END IF;

    -- TODOAG
    -- check p_delivery_rec 's org/cus/sup against p_target_stops_info.pickup/dropoff_location_id
    -- only if it is not null and p_target_stops_info.pickup/dropoff_stop_id s have not been passed (null)
    -- the following check only applies to dleg creation from WSH
    -- for assign del to trip from FTE, this check is not required as there
    -- the check is already performed at the dleg creation time
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'p_entity_type: '||p_entity_type);
    END IF;
    IF p_entity_type <> 'DLEG' THEN

       check_dleg_discretionary(
                 p_entity_type           => G_DELIVERY,
                 p_entity_id             => p_delivery_rec.delivery_id,
                 p_delivery_rec          => p_delivery_rec,
                 p_comp_class_tab        => p_comp_class_tab,
                 p_dleg_pick_up_loc_id   => p_target_stops_info.pickup_location_id,
                 p_dleg_drop_off_loc_id  => p_target_stops_info.dropoff_location_id,
                 p_dleg_pick_up_stop_id  => p_target_stops_info.pickup_stop_id,
                 p_dleg_drop_off_stop_id => p_target_stops_info.dropoff_stop_id,
                 p_detail_tab            => p_detail_tab,
                 p_carrier               => l_carrier,
                 p_mode                  => l_mode,
                 p_vehicle_type          => l_vehicle_type,
                 x_failed_constraints    => x_failed_constraints,
                 x_validate_result       => l_validate_result,
                 x_return_status         => l_return_status);

       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                 raise FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
       END IF;

       IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'l_pu_sequencenum '|| l_pu_sequencenum||' l_do_sequencenum '||l_do_sequencenum);
        WSH_DEBUG_SV.logmsg(l_module_name,'l_pu_pa_date '|| to_char(l_pu_pa_date,'DD-MON-YYYY HH24:MI:SS')||' l_do_pa_date '||to_char(l_do_pa_date,'DD-MON-YYYY HH24:MI:SS'));
       END IF;
    END IF;


    FOR i IN 1..2 LOOP

        -- Do the checks in calling procedure if pickup/dropoff stop/location ids have been passed

        IF i = 1 THEN

	   IF p_target_stops_info.pickup_stop_id IS NULL AND
              l_pu_sequencenum IS NULL AND -- To take care if stop already existed
              p_target_stops_info.pickup_location_id IS NULL THEN
                l_location_id := p_delivery_rec.initial_pickup_location_id;
           ELSE
              -- Nothing to check
		GOTO next_pass;
	   END IF;
        ELSIF i = 2 THEN
           IF p_target_stops_info.dropoff_stop_id IS NULL AND
              l_do_sequencenum IS NULL AND
              p_target_stops_info.dropoff_location_id IS NULL THEN
                l_location_id := p_delivery_rec.ultimate_dropoff_location_id;

	   ELSE
                -- Nothing to check
                GOTO next_pass;
           END IF;
        END IF;

        IF p_comp_class_tab.EXISTS(G_FACILITY_VEHICLE_NUM) AND
            p_entity_type <> 'DLEG' AND
            l_vehicle_type IS NOT NULL THEN

            validate_constraint(
             p_comp_class_code          =>      G_FACILITY_VEHICLE,
             p_object1_type             =>      'FAC',
             p_object1_val_num          =>      l_location_id,
             p_object2_type             =>      'VHT',
             p_object2_val_num          =>      l_vehicle_type,
             x_validate_result          =>      l_validate_vehicle_result,
             x_failed_constraint        =>      l_failed_constraint,
             x_return_status            =>      l_return_status);

            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                  raise FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            END IF;

            IF l_validate_vehicle_result <> 'S' THEN
              l_failed_constraint.line_constraint_index := x_failed_constraints.COUNT+1;
              l_failed_constraint.entity_type := p_entity_type;
              l_failed_constraint.entity_line_id := p_entity_id;
              x_failed_constraints(x_failed_constraints.COUNT+1) := l_failed_constraint;
              IF l_validate_vehicle_result = 'E' THEN
               l_validate_result := 'F';
              END IF;
            END IF;
        END IF;

        IF p_comp_class_tab.EXISTS(G_FACILITY_CARRIER_NUM) AND
            p_entity_type <> 'DLEG' AND
            l_carrier IS NOT NULL THEN

            validate_constraint(
             p_comp_class_code          =>      G_FACILITY_CARRIER,
             p_object1_type             =>      'FAC',
             p_object1_val_num          =>      l_location_id,
             p_object2_type             =>      'CAR',
             p_object2_val_num          =>      l_carrier,
             x_validate_result          =>      l_validate_carrier_result,
             x_failed_constraint        =>      l_failed_constraint,
             x_return_status            =>      l_return_status);

            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                  raise FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            END IF;

            IF l_validate_carrier_result <> 'S' THEN
              l_failed_constraint.line_constraint_index := x_failed_constraints.COUNT+1;
              l_failed_constraint.entity_type := p_entity_type;
              l_failed_constraint.entity_line_id := p_entity_id;
              x_failed_constraints(x_failed_constraints.COUNT+1) := l_failed_constraint;
              IF l_validate_carrier_result = 'E' THEN
               l_validate_result := 'F';
              END IF;
            END IF;
	END IF;

        IF p_comp_class_tab.EXISTS(G_FACILITY_MODE_NUM) AND
            p_entity_type <> 'DLEG' AND
            l_mode IS NOT NULL THEN

            validate_constraint(
             p_comp_class_code          =>      G_FACILITY_MODE,
             p_object1_type             =>      'FAC',
             p_object1_val_num          =>      l_location_id,
             p_object2_type             =>      'MOD',
             p_object2_val_char          =>     l_mode,
             x_validate_result          =>      l_validate_mode_result,
             x_failed_constraint        =>      l_failed_constraint,
             x_return_status            =>      l_return_status);

            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                  raise FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            END IF;

            IF l_validate_mode_result <> 'S' THEN
              l_failed_constraint.line_constraint_index := x_failed_constraints.COUNT+1;
              l_failed_constraint.entity_type := p_entity_type;
              l_failed_constraint.entity_line_id := p_entity_id;
              x_failed_constraints(x_failed_constraints.COUNT+1) := l_failed_constraint;
              IF l_validate_mode_result = 'E' THEN
               l_validate_result := 'F';
              END IF;
            END IF;

        END IF;

    <<next_pass>>
    null;

    END LOOP;



-- AGMULT
-- comment out only discretionary routing point checks inside the loop
-- not everything inside the loop

    --LOOP  -- Over Trip stops
    k := p_target_tripstops.FIRST;

    IF k IS NOT NULL THEN

     LOOP

      l_locations_list.DELETE;
      l_items_tab.DELETE;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'target_tripstop id '|| p_target_tripstops(k).stop_id||' target_tripstop sequence '||p_target_tripstops(k).stop_sequence_number||' arriv date '||p_target_tripstops(k).planned_arrival_date);
        WSH_DEBUG_SV.logmsg(l_module_name,'target_tripstop location_id '|| p_target_tripstops(k).stop_location_id||' target_tripstop physical_location_id :'||p_target_tripstops(k).physical_location_id);
      END IF;

       --LOOP  -- Over p_detail_tab
      j := p_detail_tab.FIRST;
      IF j IS NOT NULL THEN
        LOOP

         IF  p_detail_tab(j).delivery_id <> p_delivery_rec.delivery_id THEN
             GOTO inpdet_nextpass;
         END IF;

         l_inp_customer_id := NULL;
         IF p_delivery_rec.customer_id IS NOT NULL THEN
             l_inp_customer_id := p_delivery_rec.customer_id;
         ELSIF p_detail_tab(j).customer_id IS NOT NULL THEN
              l_inp_customer_id := p_detail_tab(j).customer_id;
         END IF;

         IF ( p_comp_class_tab.EXISTS(G_CUSTOMER_CUSTOMER_NUM) AND
             l_inp_customer_id IS NOT NULL AND
             NOT l_dlvycuscus_checked) OR
             ( p_comp_class_tab.EXISTS(G_ITEM_CARRIER_NUM) OR
               p_comp_class_tab.EXISTS(G_ITEM_VEHICLE_NUM) OR
               p_comp_class_tab.EXISTS(G_ITEM_MODE_NUM) ) THEN
          --LOOP  -- Over p_target_dlvy

	 l := p_target_dlvy.FIRST;
         IF l IS NOT NULL THEN
          LOOP

                -- Skip this delivery if already checked

                IF entity_exists(p_target_dlvy(l).delivery_id,l_checked_target_dlvy,z) THEN
                --IF l_checked_target_dlvy.EXISTS(p_target_dlvy(l).delivery_id) THEN
                   GOTO next_target_dlvy;
                END IF;

          	-- SBAKSHI (TODOAG)
		-- Get the  planned arrival and depature date for the trip and the delivery.

		-- TODOAG get these dates in one cursor
                -- get planned arrival dates for both the stops as for stop sequencing that is used

		-- Using one cursor.

		OPEN c_get_pickup_dropoff_dates(p_target_dlvy(l).delivery_id,p_target_trip.trip_id);
		FETCH c_get_pickup_dropoff_dates INTO l_trp_dlvy_pickup_date, l_trp_dlvy_dropoff_date;
		CLOSE c_get_pickup_dropoff_dates;

		l_checked_dlvy_cnt := l_checked_dlvy_cnt + 1;
                l_checked_target_dlvy(l_checked_dlvy_cnt) := p_target_dlvy(l).delivery_id;
                --l_checked_target_dlvy(p_target_dlvy(l).delivery_id) := p_target_dlvy(l).delivery_id;

                l_cuscus_checked := FALSE;
                l_validate_cuscus_result := 'S';
                -- cus - cus if customer is at p_delivery_rec level and  p_target_dlvy level
                -- or customer is at p_detail_tab level and p_target_dlvy level

		IF p_target_dlvy(l).customer_id IS NOT NULL AND
                 l_inp_customer_id <> p_target_dlvy(l).customer_id THEN

                  l_cuscus_checked := TRUE;
                  l_dlvycuscus_checked := TRUE;


              validate_constraint(   --  checks only negative constraints
               p_comp_class_code          =>      G_CUSTOMER_CUSTOMER,
               p_object1_type             =>      'CUS',
               p_object2_type             =>      'CUS',
               p_object1_val_num          =>      l_inp_customer_id,
               p_object2_val_num          =>      p_target_dlvy(l).customer_id,
               x_validate_result          =>      l_validate_cuscus_result,
               x_failed_constraint        =>      l_failed_constraint,  -- id
               x_return_status            =>      l_return_status);

              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;
              END IF;

              IF l_validate_cuscus_result <> 'S' THEN
                l_failed_constraint.line_constraint_index := x_failed_constraints.COUNT+1;
                l_failed_constraint.entity_type := p_entity_type;
                l_failed_constraint.entity_line_id := p_entity_id;
                x_failed_constraints(x_failed_constraints.COUNT+1) := l_failed_constraint;
                IF l_validate_cuscus_result = 'E' THEN
                   l_validate_result := 'F';
                END IF;
              END IF;

             END IF;

         -- also check the children deliveries of the target trip against input delivery leg's locations
         -- for exclusive org -fac, cus - fac, sup - fac, itm - fac
         -- p_target_dlvy against p_target_stops_info or p_delivery_rec
         -- If p_target_stops_info.pick_up_stop_id and/or p_target_stops_info.drop_off_stop_id is populated
         -- then the check for that location is not required
         -- ELSE if p_target_stops_info.pick_up_location_id and/or p_target_stops_info.drop_off_location_id is populated
         -- check against those locations
         -- ELSE check against p_delivery_rec 's locations

          -- TODOAG
          -- Check only if input delivery leg's locations lie between p_target_dlvy 's pickup and dropoff loc on
          -- p_target_trip
          -- following checks which use p_target_dlvy(l).initial_pickup/ultimate_dropoff_date to
          -- determine the intermediate loc is not correct
          -- for each p_target_dlvy(l), the leg pickup and dropoff date in the target trip p_target_trip should be
          -- obtained and then used for this check
          -- write a new cursor which gets the pickup and dropoff stop dates for
          -- the delivery leg of p_target_dlvy(l) in p_target_trip and use those dates instead

             l_input_pu_location_id := NULL;
             l_input_do_location_id := NULL;

	     IF p_target_stops_info.pickup_stop_id IS NULL THEN

		-- Check only when new stops will be created in the target trip
                -- Here, We want to do this check only either p_target_stops_info.pickup_location_id is NOT NULL
                -- OR p_target_stops_info.pickup_location_id is NULL and p_delivery_rec.initial_pickup_location_id
                -- not already exists in the trip

               IF p_target_stops_info.pickup_location_id IS NOT NULL THEN

                -- TODOAG
                -- instead use the leg dates as obtained above using the new cursor
            --    IF (p_target_dlvy(l).initial_pickup_date < l_pu_pa_date AND
            --        p_target_dlvy(l).ultimate_dropoff_date > l_pu_pa_date ) THEN

		 --sbakshi(TODOAG)

		 IF ( l_trp_dlvy_pickup_date < l_pu_pa_date AND
                      l_trp_dlvy_dropoff_date > l_pu_pa_date ) THEN

                    -- Check p_target_dlvy 's org, cus, sup against p_target_stops_info.pickup_location_id
                    l_input_pu_location_id := p_target_stops_info.pickup_location_id;

                    IF l_debug_on THEN
                       WSH_DEBUG_SV.logmsg(l_module_name,'Checking p_target_dlvy against p_target_stops_info.pickup_location_id :'|| p_target_stops_info.pickup_location_id);
                    END IF;

                END IF;
               ELSIF l_pu_pa_date IS NULL THEN

                -- TODOAG
                -- instead use the leg dates as obtained above using the new cursor
--                IF (p_target_dlvy(l).initial_pickup_date < p_delivery_rec.initial_pickup_date AND
--                    p_target_dlvy(l).ultimate_dropoff_date > p_delivery_rec.initial_pickup_date ) THEN

		 --sbakshi(TODOAG)

		 IF ( l_trp_dlvy_pickup_date < p_delivery_rec.initial_pickup_date AND
                      l_trp_dlvy_dropoff_date > p_delivery_rec.initial_pickup_date ) THEN


                    -- Check p_target_dlvy 's org, cus, sup against p_delivery_rec.initial_pickup_location_id
                    l_input_pu_location_id := p_delivery_rec.initial_pickup_location_id;

                    IF l_debug_on THEN
                       WSH_DEBUG_SV.logmsg(l_module_name,'Checking p_target_dlvy against p_delivery_rec.initial_pickup_location_id :'|| p_delivery_rec.initial_pickup_location_id);
                    END IF;

                END IF;
               END IF;
             END IF;

             IF p_target_stops_info.dropoff_stop_id IS NULL THEN
                -- Here, We want to do this check only either p_target_stops_info.dropoff_location_id is NOT NULL
                -- OR p_target_stops_info.dropoff_location_id is NULL and p_delivery_rec.ultimate_dropoff_location_id
                -- not already exists in the trip

               IF p_target_stops_info.dropoff_location_id IS NOT NULL THEN

                -- TODOAG
                -- instead use the leg dates as obtained above using the new cursor

--		IF (p_target_dlvy(l).initial_pickup_date < l_do_pa_date AND
--                    p_target_dlvy(l).ultimate_dropoff_date > l_do_pa_date ) THEN


		--sbakshi(TODOAG)
		IF (l_trp_dlvy_pickup_date  < l_do_pa_date AND
                    l_trp_dlvy_dropoff_date > l_do_pa_date ) THEN


                    -- Check p_target_dlvy 's org, cus, sup against p_target_stops_info.dropoff_location_id
                    l_input_do_location_id := p_target_stops_info.dropoff_location_id;

                    IF l_debug_on THEN
                       WSH_DEBUG_SV.logmsg(l_module_name,'Checking p_target_dlvy against p_target_stops_info.dropoff_location_id :'|| p_target_stops_info.dropoff_location_id);
                    END IF;

                END IF;
               ELSIF l_do_pa_date IS NULL THEN

                -- TODOAG
                -- instead use the leg dates as obtained above using the new cursor

--		IF (p_target_dlvy(l).initial_pickup_date < p_delivery_rec.ultimate_dropoff_date AND
--                    p_target_dlvy(l).ultimate_dropoff_date > p_delivery_rec.ultimate_dropoff_date ) THEN

		--sbakshi(TODOAG)
		IF (l_trp_dlvy_pickup_date  < p_delivery_rec.ultimate_dropoff_date AND
                    l_trp_dlvy_dropoff_date > p_delivery_rec.ultimate_dropoff_date ) THEN

                    -- Check p_target_dlvy 's org, cus, sup against p_delivery_rec.ultimate_dropoff_location_id
                    l_input_do_location_id := p_delivery_rec.ultimate_dropoff_location_id;

                    IF l_debug_on THEN
                       WSH_DEBUG_SV.logmsg(l_module_name,'Checking p_target_dlvy against p_delivery_rec.ultimate_dropoff_location_id :'|| p_delivery_rec.ultimate_dropoff_location_id);
                    END IF;
                END IF;
               END IF;
             END IF;

	  --LOOP -- Over p_target_dlvy_lines for p_target_dlvy
          m := p_target_dlvy_lines.FIRST;
          IF m IS NOT NULL THEN
                LOOP

                 IF  p_target_dlvy_lines(m).delivery_id <> p_target_dlvy(l).delivery_id THEN
                     GOTO tardet_nextpass;
                 END IF;

                     -- cus - cus if not already for this p_target_dlvy
                     -- against p_delivery_rec OR p_detail_tab level

                 IF p_target_dlvy_lines(m).customer_id IS NOT NULL AND
                     l_inp_customer_id <> p_target_dlvy_lines(m).customer_id AND
                     NOT l_cuscus_checked THEN

                   l_dlvycuscus_checked := TRUE;

                   validate_constraint(   --  checks only negative constraints
                    p_comp_class_code          =>      G_CUSTOMER_CUSTOMER,
                    p_object1_type             =>      'CUS',
                    p_object2_type             =>      'CUS',
                    p_object1_val_num          =>      l_inp_customer_id,
                    p_object2_val_num          =>      p_target_dlvy_lines(m).customer_id,
                    x_validate_result          =>      l_validate_cuscus_result,
                    x_failed_constraint        =>      l_failed_constraint,  -- id
                    x_return_status            =>      l_return_status);

                   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                         raise FND_API.G_EXC_UNEXPECTED_ERROR;
                      END IF;
                   END IF;

                   IF l_validate_cuscus_result <> 'S' THEN
                     l_failed_constraint.line_constraint_index := x_failed_constraints.COUNT+1;
                     l_failed_constraint.entity_type := p_entity_type;
                     l_failed_constraint.entity_line_id := p_entity_id;
                     x_failed_constraints(x_failed_constraints.COUNT+1) := l_failed_constraint;
                     IF l_validate_cuscus_result = 'E' THEN
                        l_validate_result := 'F';
                     END IF;
                   END IF;

                 END IF;

                 -- itm - itm against p_detail_tab
                 -- p_children_info(l) and p_children_info(m)

                 l_entity_rec.entity_id := p_detail_tab(j).delivery_detail_id;
                 l_entity_rec.organization_id := p_detail_tab(j).organization_id;
                 l_entity_rec.inventory_item_id := p_detail_tab(j).inventory_item_id;
                 l_entity_rec.customer_id := p_detail_tab(j).customer_id;

                 l_target_rec.entity_id := p_target_dlvy_lines(m).delivery_detail_id;
                 l_target_rec.organization_id := p_target_dlvy_lines(m).organization_id;
                 l_target_rec.inventory_item_id := p_target_dlvy_lines(m).inventory_item_id;
                 l_target_rec.customer_id := p_target_dlvy_lines(m).customer_id;
                 --
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Created l_target_rec for assigned line : '||p_target_dlvy_lines(m).delivery_detail_id);
                 END IF;
                 --

                 IF ((l_entity_rec.inventory_item_id <> l_target_rec.inventory_item_id) OR
                        (g_is_tp_installed = 'N' AND l_entity_rec.organization_id <> l_target_rec.organization_id))  THEN

                 search_group_itm (
                    p_comp_class_tab      =>   p_comp_class_tab,
                    p_entity_rec          =>   l_entity_rec,
                    p_target_rec          =>   l_target_rec,
                    x_validate_result     =>   l_validate_itmin_result,
                    x_failed_constraints  =>   x_failed_constraints,
                    x_return_status       =>   l_return_status);

                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                       raise FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
                 END IF;

                 IF l_validate_itmin_result = 'F' THEN
                    l_validate_result := 'F';
                     EXIT;
                 END IF;
                 END IF;

                  <<tardet_nextpass>>

                EXIT WHEN m= p_target_dlvy_lines.LAST;
                m:= p_target_dlvy_lines.NEXT(m);

                END LOOP;

                IF l_validate_itmin_result = 'F' THEN
                   l_validate_result := 'F';
                   EXIT;
                END IF;

                END IF;

                <<next_target_dlvy>>

                EXIT WHEN l= p_target_dlvy.LAST;
                l:= p_target_dlvy.NEXT(l);

            END LOOP; -- over p_target_dlvy

            IF l_validate_itmin_result = 'F' THEN
               l_validate_result := 'F';
               EXIT;
            END IF;

          END IF;

         END IF; -- l_inp_customer

         l_inp_items_cnt := l_items_tab.COUNT;
         l_items_tab(l_inp_items_cnt + 1).line_id := p_detail_tab(j).delivery_detail_id;
         l_items_tab(l_inp_items_cnt + 1).item_id := p_detail_tab(j).inventory_item_id;
         l_items_tab(l_inp_items_cnt + 1).org_id  := p_detail_tab(j).organization_id;

         <<inpdet_nextpass>>

         EXIT WHEN j= p_detail_tab.LAST;
         j:= p_detail_tab.NEXT(j);

        END LOOP; -- p_detail_tab

        -- Checks whether all details in the delivery
        -- have same/different must use carrier/mode/vehicle
        -- compared to this stop of the target trip
        -- If different, violation

        IF l_locations_list.COUNT = 1 THEN

          search_itm_fac_incl(
                     p_comp_class_tab      =>   p_comp_class_tab,
                     p_entity_type         =>   G_TRIP,
                     p_entity_id           =>   p_target_trip.trip_id,
                     p_items_tab           =>   l_items_tab,
                     p_locations_list      =>   l_locations_list,
                     x_validate_result     =>   l_validate_itmfacin_result,
                     x_failed_constraints  =>   x_failed_constraints,
                     x_return_status       =>   l_return_status);

          IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
          END IF;

        END IF;

        IF l_validate_itmin_result = 'F' OR l_validate_itmfacin_result = 'F' THEN
          l_validate_result := 'F';
          EXIT;
        END IF;

       END IF;

       <<tarstop_nextpass>>
       EXIT WHEN k= p_target_tripstops.LAST;
       k:= p_target_tripstops.NEXT(k);

     END LOOP; -- p_target_trip_stops
    END IF;

    IF l_validate_result = 'F' THEN
       x_validate_result := 'F';
    END IF;

    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --

EXCEPTION
    WHEN g_get_carrmode_failed THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,' get carrier-mode failed ');
      END IF;
      --
    WHEN g_get_vehicletype_failed THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,' get vehicletype failed ');
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
    WHEN others THEN
      IF c_get_stop%ISOPEN THEN
         CLOSE c_get_stop;
      END IF;
      IF c_get_stop_location%ISOPEN THEN
         CLOSE c_get_stop_location;
      END IF;
      IF c_get_pickup_dropoff_dates%ISOPEN THEN
         CLOSE c_get_pickup_dropoff_dates;
      END IF;
      WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.check_dlvy_against_trip');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END check_dlvy_against_trip;


--***************************************************************************--
--
--========================================================================
-- PROCEDURE : check_act_positive         PRIVATE
--
-- PARAMETERS: p_comp_class_tab           Table of Compatibility class codes to check
--             p_item_id                  Item id for which check is running
--             p_item_org_id              Organization id for the input Item id
--             p_delivery_rec             Input delivery record
--             x_failed_constraints       Failed constraint table
--             x_validate_result          Constraint Validation result : S / F
--             x_return_status            Return status
-- COMMENT   :
-- Applies to autocreate trip only
-- For a given delivery
-- Check pickup, drop off locations
-- and all items
-- against delivery's ship method
-- for Inclusive constraint
-- If different, violation
-- Used to determine whether for any resulting trip
-- delivery level shipmethod should not be updated to the trip
--========================================================================

PROCEDURE check_act_positive (
             p_comp_class_tab     IN WSH_UTIL_CORE.column_tab_type,
             p_item_id            IN NUMBER DEFAULT NULL,
             p_item_org_id        IN NUMBER DEFAULT NULL,
             p_delivery_rec       IN entity_rec_type,
             x_failed_constraint  IN OUT NOCOPY line_constraint_tab_type,
             x_validate_result    OUT NOCOPY VARCHAR2 ,
             x_return_status      OUT NOCOPY VARCHAR2)
IS

    i                             NUMBER:=0;
    l_carrier                     NUMBER := NULL;
    l_location_id                 NUMBER:=0;
    l_out_object2_num             NUMBER:=0;
    l_out_object2_char            VARCHAR2(30):=NULL;
    l_const_count                 NUMBER := x_failed_constraint.COUNT;

    l_return_status               VARCHAR2(1);
    l_mode                        VARCHAR2(30) := NULL;
    l_service_level               VARCHAR2(30) := NULL;
    l_carrier_service_inout_rec   WSH_CARRIERS_GRP.Carrier_Service_InOut_Rec_Type;
    l_validate_carrier_result     VARCHAR2(1) := 'S';
    l_validate_mode_result        VARCHAR2(1) := 'S';

    l_module_name                 CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'check_act_positive';
    l_debug_on                    CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;

BEGIN

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    x_validate_result := 'S';

    IF l_debug_on THEN
       wsh_debug_sv.push(l_module_name);
    END IF;

    IF (p_delivery_rec.carrier_id IS NULL OR p_delivery_rec.mode_of_transport IS NULL) AND
       (p_delivery_rec.ship_method_code IS NOT NULL) THEN
        l_carrier_service_inout_rec.ship_method_code := p_delivery_rec.ship_method_code;

        WSH_CARRIERS_GRP.get_carrier_service_mode(
                   p_carrier_service_inout_rec   =>  l_carrier_service_inout_rec,
                   x_return_status               =>  l_return_status);

        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
           IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
              raise g_get_carrmode_failed;
           END IF;
        END IF;
        l_carrier := l_carrier_service_inout_rec.carrier_id;
        l_mode    := l_carrier_service_inout_rec.mode_of_transport;
    END IF;

    -- If carrier_id or mode is passed in, then those get preference for validation
    -- If they are not, they are derived from ship method if that is passed

    IF p_delivery_rec.carrier_id IS NOT NULL THEN
       l_carrier := p_delivery_rec.carrier_id;
    END IF;
    IF p_delivery_rec.mode_of_transport IS NOT NULL THEN
       l_mode := p_delivery_rec.mode_of_transport;
    END IF;

    IF l_carrier IS NULL AND l_mode IS NULL THEN
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
     RETURN;
    END IF;

    -- Check success and l_carrier, l_mode non null

    IF p_item_id IS NOT NULL AND p_item_org_id IS NOT NULL THEN

       -- need to check ITM - CAR/MOD against delivery_rec's ship_method

        IF p_comp_class_tab.EXISTS(G_ITEM_MODE_NUM) THEN

         check_inclusive_object2(
             p_comp_class_code          =>      G_ITEM_MODE,
             p_entity_type              =>      G_DEL_DETAIL,
             p_entity_id                =>      p_item_id,
             p_object1_type             =>      'ITM',
             p_object1_val_num          =>      p_item_id,
             p_object1_parent_id        =>      p_item_org_id,
             p_object2_type             =>      'MOD',
             p_object2_val_char          =>     l_mode,
             x_out_object2_num          =>      l_out_object2_num,
             x_out_object2_char         =>      l_out_object2_char,
             x_validate_result          =>      l_validate_mode_result,
             x_failed_constraint        =>      x_failed_constraint,
             x_return_status            =>      l_return_status);

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;

         IF l_validate_mode_result = 'F' THEN
            x_validate_result := 'F';
         END IF;

         END IF;

        IF p_comp_class_tab.EXISTS(G_ITEM_CARRIER_NUM) AND x_validate_result = 'S' THEN

         check_inclusive_object2(
             p_comp_class_code          =>      G_ITEM_CARRIER,
             p_entity_type              =>      G_DEL_DETAIL,
             p_entity_id                =>      p_item_id,
             p_object1_type             =>      'ITM',
             p_object1_val_num          =>      p_item_id,
             p_object1_parent_id        =>      p_item_org_id,
             p_object2_type             =>      'CAR',
             p_object2_val_num          =>      l_carrier,
             x_out_object2_num          =>      l_out_object2_num,
             x_out_object2_char         =>      l_out_object2_char,
             x_validate_result          =>      l_validate_carrier_result,
             x_failed_constraint        =>      x_failed_constraint,
             x_return_status            =>      l_return_status);

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;

         IF l_validate_carrier_result = 'F' THEN
            x_validate_result := 'F';
         END IF;

        END IF;

    ELSE

        FOR i IN 1..2 LOOP

          IF i = 1 THEN
             l_location_id := p_delivery_rec.INITIAL_PICKUP_LOCATION_ID;
          ELSIF i = 2 THEN
             l_location_id := p_delivery_rec.ULTIMATE_DROPOFF_LOCATION_ID;
          END IF;

          IF l_location_id IS NOT NULL THEN

            IF p_comp_class_tab.EXISTS(G_FACILITY_MODE_NUM) THEN

             check_inclusive_object2(
                 p_comp_class_code          =>      G_FACILITY_MODE,
                 p_entity_type              =>      G_DELIVERY,
                 p_entity_id                =>      p_delivery_rec.entity_id,
                 p_object1_type             =>      'FAC',
                 p_object1_val_num          =>      l_location_id,
                 p_object2_type             =>      'MOD',
                 p_object2_val_char          =>     l_mode,
                 x_out_object2_num          =>      l_out_object2_num,
                 x_out_object2_char         =>      l_out_object2_char,
                 x_validate_result          =>      l_validate_mode_result,
                 x_failed_constraint        =>      x_failed_constraint,
                 x_return_status            =>      l_return_status);

             IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                   raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
             END IF;

             IF l_validate_mode_result = 'F' THEN
                x_validate_result := 'F';
                EXIT;
             END IF;

            END IF;

            IF p_comp_class_tab.EXISTS(G_FACILITY_CARRIER_NUM) THEN

             check_inclusive_object2(
                 p_comp_class_code          =>      G_FACILITY_CARRIER,
                 p_entity_type              =>      G_DELIVERY,
                 p_entity_id                =>      p_delivery_rec.entity_id,
                 p_object1_type             =>      'FAC',
                 p_object1_val_num          =>      l_location_id,
                 p_object2_type             =>      'CAR',
                 p_object2_val_num          =>      l_carrier,
                 x_out_object2_num          =>      l_out_object2_num,
                 x_out_object2_char         =>      l_out_object2_char,
                 x_validate_result          =>      l_validate_carrier_result,
                 x_failed_constraint        =>      x_failed_constraint,
                 x_return_status            =>      l_return_status);

             IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                   raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
             END IF;

             IF l_validate_carrier_result = 'F' THEN
                x_validate_result := 'F';
                EXIT;
             END IF;

            END IF;
          END IF; -- l_location_id non null

        END LOOP;

       -- need to check delivery_rec's facilities against delivery_rec's shipmethod
    END IF;

    IF ( l_const_count < x_failed_constraint.COUNT) THEN

         x_failed_constraint.DELETE(l_const_count+1,x_failed_constraint.COUNT);

    END IF;

    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --

EXCEPTION
    WHEN g_get_carrmode_failed THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,' get carrier-mode failed ');
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
    WHEN others THEN
      WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.check_act_positive');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --

END check_act_positive;

--***************************************************************************--
--
--========================================================================
-- PROCEDURE : check_act_carmode          PRIVATE
--
-- PARAMETERS: p_comp_class_tab           Table of Compatibility class codes to check
--             p_delivery_rec             Input delivery record
--             p_group_locations          List of non pickup, non drop off locations
--                                        of the delivery in the potential trip
--             x_failed_constraint        Failed constraint table
--             x_validate_result          Constraint Validation result : S / F
--             x_return_status            Return status
-- COMMENT   :
-- Applies to autocreate trip only
-- For a given delivery
-- Check pickup drop off locations
-- and all non pickup, drop off locations possible in the potential trip
-- to make sure they all have same
-- carrier/mode/vehicle for Inclusive constraint
-- If different, violation
--========================================================================

PROCEDURE check_act_carmode (
             p_comp_class_tab     IN WSH_UTIL_CORE.column_tab_type,
             p_delivery_rec       IN OUT NOCOPY entity_rec_type,
             p_group_locations    IN WSH_UTIL_CORE.id_tab_type,
             x_failed_constraint  IN OUT NOCOPY line_constraint_tab_type,
             x_validate_result    OUT NOCOPY VARCHAR2 ,
             x_return_status      OUT NOCOPY VARCHAR2)
IS

    i                             NUMBER :=0;
    l_return_status               VARCHAR2(1) := NULL;
    l_validate_carrier_result     VARCHAR2(1) := 'S';
    l_validate_vehicle_result     VARCHAR2(1) := 'S';
    l_validate_mode_result        VARCHAR2(1) := 'S';
    l_location_id                 NUMBER :=0;
    l_out_object2_num             NUMBER := NULL;
    l_out_object2_vehnum          NUMBER := NULL;
    l_out_object2_char            VARCHAR2(30) := NULL;
    l_prev_out_object2_num        NUMBER := NULL;
    l_prev_out_object2_vehnum     NUMBER := NULL;
    l_prev_out_object2_char       VARCHAR2(30) := NULL;
    l_const_count                 NUMBER := x_failed_constraint.COUNT;

    l_module_name                 CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'check_act_carmode';
    l_debug_on                    CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;

BEGIN

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    x_validate_result := 'S';

    IF l_debug_on THEN
       wsh_debug_sv.push(l_module_name);
    END IF;

    FOR i IN 1..2 LOOP
    -- Facility  - Vehicle

      IF i = 1 THEN
         l_location_id := p_delivery_rec.INITIAL_PICKUP_LOCATION_ID;
      ELSIF i = 2 THEN
         l_location_id := p_delivery_rec.ULTIMATE_DROPOFF_LOCATION_ID;
      END IF;

      IF l_location_id IS NOT NULL THEN

        IF p_comp_class_tab.EXISTS(G_FACILITY_CARRIER_NUM) THEN

              check_inclusive_object2(
               p_comp_class_code          =>      G_FACILITY_CARRIER,
               p_entity_type              =>      G_DELIVERY,
               p_entity_id                =>      p_delivery_rec.entity_id,
               p_object1_type             =>      'FAC',
               p_object1_val_num          =>      l_location_id,
               p_object2_type             =>      'CAR',
               x_out_object2_num          =>      l_out_object2_num,
               x_out_object2_char         =>      l_out_object2_char,
               x_validate_result          =>      l_validate_carrier_result,
               x_failed_constraint        =>      x_failed_constraint,
               x_return_status            =>      l_return_status);

              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;
              END IF;

              IF l_validate_carrier_result = 'F' THEN
                 IF i = 2 AND l_prev_out_object2_num IS NOT NULL THEN
                    IF l_out_object2_num <> l_prev_out_object2_num THEN
                       x_validate_result := 'F';
                       EXIT;
                    END IF;
                 END IF;
              END IF;

        END IF;

        IF p_comp_class_tab.EXISTS(G_FACILITY_MODE_NUM) THEN

              check_inclusive_object2(
               p_comp_class_code          =>      G_FACILITY_MODE,
               p_entity_type              =>      G_DELIVERY,
               p_entity_id                =>      p_delivery_rec.entity_id,
               p_object1_type             =>      'FAC',
               p_object1_val_num          =>      l_location_id,
               p_object2_type             =>      'MOD',
               x_out_object2_num          =>      l_out_object2_num,
               x_out_object2_char         =>      l_out_object2_char,
               x_validate_result          =>      l_validate_mode_result,
               x_failed_constraint        =>      x_failed_constraint,
               x_return_status            =>      l_return_status);

              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;
              END IF;

              IF l_validate_mode_result = 'F' THEN
                 IF i = 2 AND l_prev_out_object2_char IS NOT NULL THEN
                    IF l_out_object2_char <> l_prev_out_object2_char THEN
                       x_validate_result := 'F';
                       EXIT;
                    END IF;
                 END IF;
              END IF;

        END IF;

        IF p_comp_class_tab.EXISTS(G_FACILITY_VEHICLE_NUM) THEN

              check_inclusive_object2(
               p_comp_class_code          =>      G_FACILITY_VEHICLE,
               p_entity_type              =>      G_DELIVERY,
               p_entity_id                =>      p_delivery_rec.entity_id,
               p_object1_type             =>      'FAC',
               p_object1_val_num          =>      l_location_id,
               p_object2_type             =>      'VHT',
               x_out_object2_num          =>      l_out_object2_vehnum,
               x_out_object2_char         =>      l_out_object2_char,
               x_validate_result          =>      l_validate_vehicle_result,
               x_failed_constraint        =>      x_failed_constraint,
               x_return_status            =>      l_return_status);

              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;
              END IF;

              IF l_validate_vehicle_result = 'F' THEN
                 IF i = 2 AND l_prev_out_object2_vehnum IS NOT NULL THEN
                    IF l_out_object2_vehnum <> l_prev_out_object2_vehnum THEN
                       x_validate_result := 'F';
                       EXIT;
                    END IF;
                 END IF;
              END IF;

        END IF;

      END IF; -- l_location_id not null

      l_prev_out_object2_num := l_out_object2_num;
      l_prev_out_object2_vehnum := l_out_object2_vehnum;
      l_prev_out_object2_char := l_out_object2_char;

    END LOOP;

   -- Now check against other locations in the same group
   -- Is it really checking current delivery's location against other locations in
   -- p_group_locations ??? 5/21
   -- Yes, as the below part checks against l_prev_out_object2_num which could be populated
   -- above even in case of success

    IF x_validate_result = 'S' THEN
     i := p_group_locations.FIRST;
     IF i IS NOT NULL THEN
       LOOP

        -- Facility  - Vehicle

        IF p_group_locations(i) IS NOT NULL THEN

          IF p_comp_class_tab.EXISTS(G_FACILITY_CARRIER_NUM) THEN

                check_inclusive_object2(
                 p_comp_class_code          =>      G_FACILITY_CARRIER,
                 p_entity_type              =>      G_DELIVERY,
                 p_entity_id                =>      p_delivery_rec.entity_id,
                 p_object1_type             =>      'FAC',
                 p_object1_val_num          =>      p_group_locations(i),
                 p_object2_type             =>      'CAR',
                 x_out_object2_num          =>      l_out_object2_num,
                 x_out_object2_char         =>      l_out_object2_char,
                 x_validate_result          =>      l_validate_carrier_result,
                 x_failed_constraint        =>      x_failed_constraint,
                 x_return_status            =>      l_return_status);

                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                      raise FND_API.G_EXC_UNEXPECTED_ERROR;
                   END IF;
                END IF;

                IF l_validate_carrier_result = 'F' THEN
                   IF l_prev_out_object2_num IS NOT NULL THEN
                      IF l_out_object2_num <> l_prev_out_object2_num THEN
                         x_validate_result := 'F';
                         EXIT;
                      END IF;
                   END IF;
                END IF;

          END IF;

          IF p_comp_class_tab.EXISTS(G_FACILITY_MODE_NUM) THEN

                check_inclusive_object2(
                 p_comp_class_code          =>      G_FACILITY_MODE,
                 p_entity_type              =>      G_DELIVERY,
                 p_entity_id                =>      p_delivery_rec.entity_id,
                 p_object1_type             =>      'FAC',
                 p_object1_val_num          =>      p_group_locations(i),
                 p_object2_type             =>      'MOD',
                 x_out_object2_num          =>      l_out_object2_num,
                 x_out_object2_char         =>      l_out_object2_char,
                 x_validate_result          =>      l_validate_mode_result,
                 x_failed_constraint        =>      x_failed_constraint,
                 x_return_status            =>      l_return_status);

                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                      raise FND_API.G_EXC_UNEXPECTED_ERROR;
                   END IF;
                END IF;

                IF l_validate_mode_result = 'F' THEN
                   IF l_prev_out_object2_char IS NOT NULL THEN
                      IF l_out_object2_char <> l_prev_out_object2_char THEN
                         x_validate_result := 'F';
                         EXIT;
                      END IF;
                   END IF;
                END IF;

          END IF;

          IF p_comp_class_tab.EXISTS(G_FACILITY_VEHICLE_NUM) THEN

                check_inclusive_object2(
                 p_comp_class_code          =>      G_FACILITY_VEHICLE,
                 p_entity_type              =>      G_DELIVERY,
                 p_entity_id                =>      p_delivery_rec.entity_id,
                 p_object1_type             =>      'FAC',
                 p_object1_val_num          =>      p_group_locations(i),
                 p_object2_type             =>      'VHT',
                 x_out_object2_num          =>      l_out_object2_vehnum,
                 x_out_object2_char         =>      l_out_object2_char,
                 x_validate_result          =>      l_validate_vehicle_result,
                 x_failed_constraint        =>      x_failed_constraint,
                 x_return_status            =>      l_return_status);

                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                      raise FND_API.G_EXC_UNEXPECTED_ERROR;
                   END IF;
                END IF;

                IF l_validate_vehicle_result = 'F' THEN
                   IF l_prev_out_object2_vehnum IS NOT NULL THEN
                      IF l_out_object2_vehnum <> l_prev_out_object2_vehnum THEN
                         x_validate_result := 'F';
                         EXIT;
                      END IF;
                   END IF;
                END IF;

          END IF;

        END IF; -- l_location_id not null

        IF l_out_object2_num IS NOT NULL THEN
           l_prev_out_object2_num := l_out_object2_num;
        END IF;
        IF l_out_object2_vehnum IS NOT NULL THEN
           l_prev_out_object2_vehnum := l_out_object2_vehnum;
        END IF;
        IF l_out_object2_char IS NOT NULL THEN
           l_prev_out_object2_char := l_out_object2_char;
        END IF;

        EXIT WHEN i = p_group_locations.LAST;
        i := p_group_locations.NEXT(i);

       END LOOP;
     END IF; -- l_location_id not null
    ELSE
       p_delivery_rec.entity_id := null;
    END IF; -- x_validate_result

    -- If returning success, any constraint that failed should be deleted
    IF x_validate_result = 'S' AND
       ( l_const_count < x_failed_constraint.COUNT ) THEN

       x_failed_constraint.DELETE(l_const_count+1,x_failed_constraint.COUNT);

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
      WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.check_act_carmode');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --

END check_act_carmode;

--***************************************************************************--

--========================================================================
-- FUNCTION :  is_last_trip                PUBLIC
--
-- PARAMETERS: p_delivery_id               Input delivery
--             p_initial_pu_loc_id         Delivery's initial pickup location
--             p_ultimate_do_loc_id        Delivery's ultimate dropoff location
--             p_target_stops_in_trip      Input pickup and dropoff stop/location of the delivery(s)
--                                         in the target trip in case of assign delivery to trip
--             p_target_trip_id            Target trip
--             x_return_status             Return status
-- COMMENT   :
-- Applicable to Assign delivery to trip only
-- Determines whether the target trip is the last trip for an input delivery
-- in order to finish the multileg delivery
--========================================================================

FUNCTION is_last_trip (
            p_delivery_id           IN NUMBER,
            p_initial_pu_loc_id     IN NUMBER DEFAULT NULL,
            p_ultimate_do_loc_id    IN NUMBER DEFAULT NULL,
            p_target_trip_id        IN NUMBER,
            p_target_stops_in_trip  IN target_tripstop_cc_rec_type,
            x_return_status         OUT NOCOPY VARCHAR2 ) RETURN BOOLEAN
IS

    CURSOR c_get_dlvy_locs(c_delivery_id IN NUMBER) IS
    SELECT initial_pickup_location_id,
           ultimate_dropoff_location_id
    FROM   wsh_new_deliveries
    WHERE  delivery_id = c_delivery_id;

    -- AGDUMMY
    -- all the stop_location_id
    -- AGDUMMY Start with a leg whose pickup loc is not a dropoff stop of another leg of that delivery

    CURSOR c_get_dlegs(c_delivery_id IN NUMBER) IS
    SELECT * from
    wsh_constraint_dleg_tmp v -- global temporary table
    where v.delivery_id = c_delivery_id
    CONNECT BY PRIOR v.drop_off_stop_location_id = v.pick_up_stop_location_id
    START WITH v.pick_up_stop_location_id NOT IN (select nvl(a.physical_location_id,a.stop_location_id)
              from wsh_delivery_legs c,wsh_trip_stops a where
              c.delivery_id = c_delivery_id and
              c.drop_off_stop_id = a.stop_id
              );

    l_stop_id              NUMBER := 0;
    l_count                NUMBER := 0;
    l_break_count          NUMBER := 0;
    l_result               BOOLEAN := FALSE;
    l_sequence             BOOLEAN := FALSE;
    l_first_pu_loc         NUMBER := NULL;
    l_prev_do_loc          NUMBER := NULL;
    l_dropoff_loc_id       NUMBER := NULL;
    l_dropoff_seq_id       NUMBER := NULL;
    l_dropoff_pa_date      DATE;
    l_pickup_loc_id        NUMBER := NULL;
    l_pickup_seq_id        NUMBER := NULL;
    l_pickup_pa_date       DATE;
    l_dlvy_dotrip_loc_id   NUMBER := NULL;
    l_dlvy_putrip_loc_id   NUMBER := NULL;
    l_initial_pu_loc_id    NUMBER := NULL;
    l_ultimate_do_loc_id   NUMBER := NULL;
    l_root2                NUMBER := NULL;
    l_leaf1                NUMBER := NULL;
    l_dleg_rec             dleg_stops_rec_type;

    l_tmp_count            NUMBER := NULL;
    --#DUM_LOC(S)
    l_physical_location_id NUMBER;
    l_return_status        VARCHAR2(1) := NULL;
    --#DUM_LOC(E)

    l_module_name          CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'is_last_trip';
    l_debug_on             CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;

BEGIN

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       WSH_DEBUG_SV.logmsg(l_module_name,'Input delivery : '||p_delivery_id);
    END IF;

    IF p_initial_pu_loc_id IS NULL OR p_ultimate_do_loc_id IS NULL THEN
       OPEN c_get_dlvy_locs(p_delivery_id);
       FETCH c_get_dlvy_locs INTO l_initial_pu_loc_id,l_ultimate_do_loc_id;
       CLOSE c_get_dlvy_locs;
       --AGDUMMY
       --Made the changes outside if condition.

       --#DUM_LOC(S)
    --Check if ultimate drop off location is a dummy location
    WSH_LOCATIONS_PKG.CONVERT_INTERNAL_CUST_LOCATION(
         p_internal_cust_location_id  => l_ultimate_do_loc_id,
         x_internal_org_location_id   => l_physical_location_id,
         x_return_status              => l_return_status);

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END IF;

    IF (l_physical_location_id IS NOT NULL) THEN
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Location '||l_ultimate_do_loc_id||' is a dummy location');
      END IF;
      --
      l_ultimate_do_loc_id:= l_physical_location_id;
    END IF;
    --#DUM_LOC(E)

    ELSE
       -- AGDUMMY
       -- Ultimate dropoff location_id is already passed as converted to physical if dummy by the caller
       l_initial_pu_loc_id  := p_initial_pu_loc_id;
       l_ultimate_do_loc_id := p_ultimate_do_loc_id;
    END IF;

    -- Optionally can use p_target_tripstops table
    -- to search for delivery's initial/ultimate locations

    -- AGDUMMY
    -- p_target_stops_in_trip's dropoff_location_id already converted by the caller
    -- to physical_location_id if it was dummy

    IF p_target_stops_in_trip.dropoff_stop_id IS NULL THEN
       -- check if delivery's ultimate do location id already exists
       -- in target trip
         OPEN c_get_stop(l_ultimate_do_loc_id,p_target_trip_id);
         FETCH c_get_stop INTO l_dropoff_seq_id,l_dropoff_pa_date;
         CLOSE c_get_stop;
         IF l_dropoff_seq_id IS NOT NULL THEN
            l_dropoff_loc_id := l_ultimate_do_loc_id;
         END IF;
    ELSIF p_target_stops_in_trip.dropoff_stop_id IS NOT NULL THEN

       OPEN c_get_stop_location(p_target_stops_in_trip.dropoff_stop_id);
       FETCH c_get_stop_location INTO l_dropoff_loc_id,l_dropoff_seq_id,l_dropoff_pa_date;
       CLOSE c_get_stop_location;

    END IF;

    IF p_target_stops_in_trip.pickup_stop_id IS NULL THEN
       -- check if delivery's initial pu location id already exists
       -- in target trip
         OPEN c_get_stop(l_initial_pu_loc_id,p_target_trip_id);
         FETCH c_get_stop INTO l_pickup_seq_id,l_pickup_pa_date;
         CLOSE c_get_stop;
         IF l_pickup_seq_id IS NOT NULL THEN
            l_pickup_loc_id := l_initial_pu_loc_id;
         END IF;
    ELSIF p_target_stops_in_trip.pickup_stop_id IS NOT NULL THEN

       OPEN c_get_stop_location(p_target_stops_in_trip.pickup_stop_id);
       FETCH c_get_stop_location INTO l_pickup_loc_id,l_pickup_seq_id,l_pickup_pa_date;
       CLOSE c_get_stop_location;

    END IF;

    -- Either an existing stop of the target trip is chosen as
    -- pickup/dropoff or a new location is chosen

    -- The assumption will be if
    -- input pickup stop/location is null, this trip is the first dleg in sequence
    -- input dropoff stop/loc is null, this trip is the last dleg in sequence

    -- Found out that if input pickup/dropoff stop/location is NULL,
    -- creates a new stop in the trip only if a stop with that location not already exists

    l_dlvy_putrip_loc_id := nvl(nvl(p_target_stops_in_trip.pickup_location_id,l_pickup_loc_id),l_initial_pu_loc_id);
    l_dlvy_dotrip_loc_id := nvl(nvl(p_target_stops_in_trip.dropoff_location_id,l_dropoff_loc_id),l_ultimate_do_loc_id);


       -- Find out that if from the first to last trip on which the delivery
       -- will be on, all the delvery legs are connected
       -- and delivery's initial pickup and ultimate dropoff locations are satisfied

       IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'del initial pickup : '||l_initial_pu_loc_id||' del ultimate dropoff : '||l_ultimate_do_loc_id);
             WSH_DEBUG_SV.logmsg(l_module_name,'l_pickup_loc_id : '||l_pickup_loc_id||' l_dropoff_loc_id : '||l_dropoff_loc_id);
             WSH_DEBUG_SV.logmsg(l_module_name,'l_dlvy_dotrip_loc_id : '||l_dlvy_dotrip_loc_id||' l_dlvy_putrip_loc_id : '||l_dlvy_putrip_loc_id);
       END IF;

    l_count := 0;
    l_break_count := 0;
    l_result := TRUE;
    l_sequence := TRUE;

    /*
    SELECT COUNT(*)
    INTO l_tmp_count
    FROM wsh_constraint_dleg_tmp
    WHERE delivery_id = p_delivery_id;

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Currently have :'||l_tmp_count||' rows into wsh_constraint_dleg_tmp for delivery : '||p_delivery_id);
    END IF;
    */

    OPEN c_get_dlegs(p_delivery_id);
    LOOP
          FETCH c_get_dlegs INTO l_dleg_rec;
          EXIT WHEN c_get_dlegs%NOTFOUND;
          IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'dleg id :'||l_dleg_rec.delivery_leg_id||' pickup loc id : '||l_dleg_rec.pick_up_loc_id||' dropoff loc :'||l_dleg_rec.drop_off_loc_id);
             WSH_DEBUG_SV.logmsg(l_module_name,'pickup stop : '||l_dleg_rec.pick_up_stop_id||' dropoff stop :'||l_dleg_rec.drop_off_stop_id);
          END IF;

          l_count := l_count + 1;
          IF l_count > 1 THEN
             -- dlegs can have arbitrary sequence number
             IF l_dleg_rec.pick_up_loc_id <> l_prev_do_loc THEN
             -- There is a break in dleg sequence
             -- 09/24 The connect by query can return dlegs
             -- in improper sequence
             -- But the current dleg can finish multileg
             -- delivery only if no of breaks = 1
                l_result := FALSE;
                l_sequence := FALSE;
                l_break_count := l_break_count + 1;
                -- take care of the fact that
                -- input pickup/dropoff stop can be null
                -- but they already exist in the trip
                IF l_break_count = 1 THEN
                   l_root2 := l_dleg_rec.pick_up_loc_id;
                   l_leaf1 := l_prev_do_loc;
                   IF l_dleg_rec.pick_up_loc_id = l_dlvy_dotrip_loc_id AND
                      l_prev_do_loc = l_dlvy_putrip_loc_id THEN
                        l_result := TRUE;
                   END IF;
                END IF;

             END IF;

          ELSE
             l_first_pu_loc := l_dleg_rec.pick_up_loc_id;
          END IF;
          l_prev_do_loc := l_dleg_rec.drop_off_loc_id;
    END LOOP;
    CLOSE c_get_dlegs;

    IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'l_first_pu_loc : '||l_first_pu_loc||' l_prev_do_loc : '||l_prev_do_loc||' l_break_count : '||l_break_count);
             WSH_DEBUG_SV.logmsg(l_module_name,'l_root2 : '||l_root2||' l_leaf1 : '||l_leaf1);
    END IF;

    IF l_result THEN

       -- Means either of
       -- 1. all the existing delivery legs are in sequence OR no dleg existing currently
       -- 2. there is a break in existing delivery legs and
       --    current input pick_up location and drop_off location fills that gap

          IF l_sequence THEN -- 1 in above
             IF l_count >= 1 THEN -- Atleast one leg already exists
                -- If all the existing delivery legs are in sequence
                -- needs to make sure delivery's ini pu and ult do
                -- are satisfied and the current dleg will complete the
                -- multileg delivery sequence from origin to
                -- destination
                IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Atleast one dleg exists and they are in sequence');
                END IF;

               IF NOT ( (l_first_pu_loc = l_dlvy_dotrip_loc_id AND l_initial_pu_loc_id = l_dlvy_putrip_loc_id AND l_prev_do_loc = l_ultimate_do_loc_id) OR
                (l_prev_do_loc = l_dlvy_putrip_loc_id AND l_ultimate_do_loc_id = l_dlvy_dotrip_loc_id AND l_first_pu_loc = l_initial_pu_loc_id) ) THEN
                  -- The current delivery leg fits in the beginning
                  -- or end of the delivery leg

                  l_result := FALSE;

               END IF;

             ELSE -- No leg exists currently
                IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'No dleg exists currently for the input delivery');
                END IF;
                -- need to make sure delivery's initial pickup and
                -- ultimate dropoffs are satisfied

               IF NOT ( ( l_dlvy_putrip_loc_id = l_initial_pu_loc_id ) AND
                  (l_dlvy_dotrip_loc_id = l_ultimate_do_loc_id) ) THEN

                  l_result := FALSE;

               END IF;

             END IF;
          ELSE -- Case 2 above
             -- For case 2 need to make sure delivery's initial pickup and
             -- ultimate dropoffs are satisfied

             IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'there is a break in current leg sequences for the input delivery and current dleg fits in that break');
             END IF;
             IF NOT (l_first_pu_loc = l_initial_pu_loc_id AND
                l_prev_do_loc = l_ultimate_do_loc_id ) THEN
                  l_result := FALSE;
             END IF;
          END IF;

    ELSE
          -- 09/24 The connect by query can return dlegs
          -- in improper sequence
          -- But the current dleg can finish multileg
          -- delivery only if no of breaks = 1
          IF (NOT l_sequence) AND l_break_count = 1 THEN

             IF l_first_pu_loc = l_dlvy_dotrip_loc_id AND
                   l_prev_do_loc = l_dlvy_putrip_loc_id THEN

                IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Dlegs have not been returned in proper hierarchical sequence by the connect by query');
                   WSH_DEBUG_SV.logmsg(l_module_name,'there is a break in current leg sequences for the input delivery and current dleg fits in that break');
                END IF;

              IF (l_root2 = l_initial_pu_loc_id AND
                l_leaf1 = l_ultimate_do_loc_id ) THEN
                l_result := TRUE;
              END IF;
             END IF;

          ELSE
             IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'There is a break in already existing dleg sequence and the current dleg does not fit in that break');
             END IF;
          END IF;
    END IF;

    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --

    RETURN l_result;

EXCEPTION
    WHEN others THEN
      IF c_get_stop%ISOPEN THEN
         CLOSE c_get_stop;
      END IF;
      IF c_get_stop_location%ISOPEN THEN
         CLOSE c_get_stop_location;
      END IF;
      IF c_get_dlegs%ISOPEN THEN
         CLOSE c_get_dlegs;
      END IF;
      WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.is_last_trip');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      RETURN FALSE;

END is_last_trip;

--***************************************************************************--

--========================================================================
-- PROCEDURE : get_intmed_stops           PRIVATE
--
-- PARAMETERS: p_delivery_id              Input delivery id
--             p_pickup_loc_id            Input pickup location id in the target trip
--                                        for the delivery in case of assign delivery to trip
--             p_dropoff_loc_id           Input dropoff location id in the target trip
--                                        for the delivery in case of assign delivery to trip
--             x_num_dlegs                Number of existing delivery legs for this delivery
--             x_stop_locations           List of output locations
--             x_return_status            Return status
-- COMMENT   :
-- Applies to assign delivery to trip
-- update/delete stop
-- For a given delivery
-- determine all stop locations in all existing trips the delivery is currently on
-- except the delivery's initial pickup location and ultimate dropoff location
--========================================================================

PROCEDURE get_intmed_stops (
              p_delivery_id         IN  NUMBER,
              p_pickup_loc_id       IN  NUMBER,
              p_dropoff_loc_id      IN  NUMBER,
              x_num_dlegs           OUT NOCOPY    NUMBER,
              x_stop_locations      OUT NOCOPY    WSH_UTIL_CORE.id_tab_type,
              x_return_status       OUT NOCOPY    VARCHAR2)
IS

    -- AGDUMMY
    -- all the stop_location_id

    -- delivery's ultimate_drop_off is converted to
    -- corresponding physical_location_id already if it was a dummy location

    CURSOR c_get_stops(c_delivery_id IN NUMBER) IS
    --#DUM_LOC(S)
    SELECT nvl(wts1.physical_location_id,wts1.stop_location_id) pickup_stop_loc,
	   wts1.stop_sequence_number pickup_stop_seq,
	   nvl(wts2.physical_location_id,wts2.stop_location_id) dropoff_stop_loc ,
	   wts2.stop_sequence_number dropoff_stop_seq,
           wdl.sequence_number,wt.trip_id
    --#DUM_LOC(E)
    FROM   wsh_new_deliveries wnd,
           wsh_delivery_legs wdl,
           wsh_trips wt,
           wsh_trip_stops wts1,
           wsh_trip_stops wts2
    WHERE  wnd.delivery_id = c_delivery_id
    AND    wdl.delivery_id = wnd.delivery_id
    AND    wdl.pick_up_stop_id = wts1.stop_id
    AND    wdl.drop_off_stop_id = wts2.stop_id
    AND    wts1.trip_id = wt.trip_id
    AND    wts2.trip_id = wt.trip_id;

    z                                  NUMBER := 0;
    l_stop_loc_cnt                     NUMBER := 0;
    l_pickup_stop_loc                  NUMBER := 0;
    l_pickup_stop_seq                  NUMBER := 0;
    l_dropoff_stop_loc                 NUMBER := 0;
    l_dropoff_stop_seq                 NUMBER := 0;
    l_sequence_number                  NUMBER := 0;
    l_trip_id                          NUMBER := 0;
    l_stop_location_id                 NUMBER := 0;

    l_module_name                      CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'get_intmed_stops';
    l_debug_on                         CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;

BEGIN

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    IF l_debug_on THEN
       wsh_debug_sv.push(l_module_name);
    END IF;

    x_num_dlegs := 0;
    OPEN c_get_stops(p_delivery_id);
    LOOP

       FETCH c_get_stops INTO l_pickup_stop_loc, l_pickup_stop_seq,
             l_dropoff_stop_loc, l_dropoff_stop_seq, l_sequence_number, l_trip_id;
       EXIT WHEN c_get_stops%NOTFOUND;
       x_num_dlegs := x_num_dlegs + 1;

       IF l_pickup_stop_loc <> p_pickup_loc_id THEN
          --IF NOT x_stop_locations.EXISTS(l_pickup_stop_loc) THEN
          IF NOT entity_exists(l_pickup_stop_loc,x_stop_locations,z) THEN
             IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Adding trip pickup stop location id : '||l_pickup_stop_loc);
             END IF;
             l_stop_loc_cnt := l_stop_loc_cnt + 1;
             x_stop_locations(l_stop_loc_cnt) := l_pickup_stop_loc;
             --x_stop_locations(l_pickup_stop_loc) := l_pickup_stop_loc;
          END IF;
       END IF;

       IF l_dropoff_stop_loc <> p_dropoff_loc_id THEN
          --IF NOT x_stop_locations.EXISTS(l_dropoff_stop_loc) THEN
          IF NOT entity_exists(l_dropoff_stop_loc,x_stop_locations,z) THEN
             IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Adding trip dropoff stop location id : '||l_dropoff_stop_loc);
             END IF;
             l_stop_loc_cnt := l_stop_loc_cnt + 1;
             x_stop_locations(l_stop_loc_cnt) := l_dropoff_stop_loc;
             --x_stop_locations(l_dropoff_stop_loc) := l_dropoff_stop_loc;
          END IF;
       END IF;


    END LOOP;
    CLOSE c_get_stops;

    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'x_num_dlegs : '||x_num_dlegs);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --

EXCEPTION
    WHEN others THEN
      IF c_get_stops%ISOPEN THEN
         CLOSE c_get_stops;
      END IF;
      WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.get_intmed_stops');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;

END get_intmed_stops;

--***************************************************************************--
--========================================================================
-- PROCEDURE : append_current_trip_stops  PRIVATE
--
-- PARAMETERS: p_action_code              Current constraint validation action
--                                        Can be 'ADT' or 'ACT'
--             p_target_stop_info         Input pickup and dropoff stop/location of the delivery(s)
--                                        in the target trip in case of assign delivery to trip
--             p_target_tripstops         Children stops already present in target trip
--             p_entity                   Input entity record for which a group is being searched
--                                        Can be delivery
--             p_entity_all               Table of delivery records in the current action
--             x_stop_locations           List of output locations
--             x_return_status            Return status
-- COMMENT   :
-- Applies to assign delivery to trip and autocreate trip only
-- For a given delivery
-- determine all stop locations in the target trip and
-- the sister deliveries, which are between the delivery's
-- pickup and dropoff location in the target / potential trip
--========================================================================

PROCEDURE append_current_trip_stops (
             p_action_code         IN   VARCHAR2,
             p_target_trip_id      IN   NUMBER DEFAULT NULL,
             p_target_stop_info    IN   target_tripstop_cc_rec_type,
             p_target_tripstops    IN   stop_ccinfo_tab_type,
             p_entity              IN   entity_rec_type,
             p_entity_all          IN   entity_tab_type,
             x_stop_locations      IN OUT NOCOPY   WSH_UTIL_CORE.id_tab_type,
             x_return_status       OUT NOCOPY      VARCHAR2)
IS

    l                              NUMBER := NULL;
    i                              NUMBER := NULL;
    z                              NUMBER := 0;
    l_stop_loc_cnt                 NUMBER := x_stop_locations.COUNT;
    l_pu_location_id               NUMBER := NULL;
    l_pu_sequencenum               NUMBER := NULL;
    l_pu_pa_date                   DATE;
    l_do_location_id               NUMBER := NULL;
    l_do_sequencenum               NUMBER := NULL;
    l_do_pa_date                   DATE;

    --#SBAKSHI(08/24)
    l_idx			   NUMBER := 0;
    --#SBAKSHI(08/24)

    l_module_name                  CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'append_current_trip_stops';
    l_debug_on                     CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;

BEGIN

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    IF l_debug_on THEN
       wsh_debug_sv.push(l_module_name);
    END IF;

    IF p_action_code = G_ASSIGN_DLVY_TRIP THEN

      IF p_target_stop_info.pickup_stop_id IS NOT NULL THEN

         OPEN c_get_stop_location(p_target_stop_info.pickup_stop_id);
         FETCH c_get_stop_location INTO l_pu_location_id,l_pu_sequencenum,l_pu_pa_date;
         CLOSE c_get_stop_location;

      ELSIF p_target_stop_info.pickup_location_id IS NOT NULL THEN

         l_pu_location_id := p_target_stop_info.pickup_location_id;
         l_pu_sequencenum := p_target_stop_info.pickup_stop_seq;
         l_pu_pa_date := p_target_stop_info.pickup_stop_pa_date;

      ELSIF p_target_stop_info.pickup_stop_id IS NULL THEN
       -- check if delivery's initial pu location id already exists
       -- in target trip
         OPEN c_get_stop(p_entity.initial_pickup_location_id,p_target_trip_id);
         FETCH c_get_stop INTO l_pu_sequencenum,l_pu_pa_date;
         CLOSE c_get_stop;
         IF l_pu_sequencenum IS NOT NULL THEN
            l_pu_location_id := p_entity.initial_pickup_location_id;
         END IF;

      END IF;

      IF p_target_stop_info.dropoff_stop_id IS NOT NULL THEN

         OPEN c_get_stop_location(p_target_stop_info.dropoff_stop_id);
         FETCH c_get_stop_location INTO l_do_location_id,l_do_sequencenum,l_do_pa_date;
         CLOSE c_get_stop_location;

      ELSIF p_target_stop_info.dropoff_location_id IS NOT NULL THEN

         l_do_location_id := p_target_stop_info.dropoff_location_id;
         l_do_sequencenum := p_target_stop_info.dropoff_stop_seq;
         l_do_pa_date := p_target_stop_info.dropoff_stop_pa_date;

      ELSIF p_target_stop_info.dropoff_stop_id IS NULL THEN
       -- check if delivery's ultimate do location id already exists
       -- in target trip
         OPEN c_get_stop(p_entity.ultimate_dropoff_location_id,p_target_trip_id);
         FETCH c_get_stop INTO l_do_sequencenum,l_do_pa_date;
         CLOSE c_get_stop;
         IF l_do_sequencenum IS NOT NULL THEN
            l_do_location_id := p_entity.ultimate_dropoff_location_id;
         END IF;

      END IF;
      IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'l_pu_location_id : '||l_pu_location_id||' l_pu_sequencenum : '||l_pu_sequencenum||' l_do_location_id : '||l_do_location_id||' l_do_sequencenum : '||l_do_sequencenum);
               WSH_DEBUG_SV.logmsg(l_module_name,'l_pu_pa_date : '||to_char(l_pu_pa_date,'DD-MON-YYYY HH24:MI:SS')||' l_do_pa_date : '||to_char(l_do_pa_date,'DD-MON-YYYY HH24:MI:SS'));
      END IF;

    END IF;

    l := p_entity_all.FIRST;
    IF l IS NOT NULL THEN
        LOOP -- Over each entity in that group

            --
            IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'for entity : '||p_entity.entity_id||' searching entity : '||p_entity_all(l).entity_id);
                  WSH_DEBUG_SV.logmsg(l_module_name,'outside entity group id : '||p_entity.group_id||' searching entity group id : '||p_entity_all(l).group_id);
                  WSH_DEBUG_SV.logmsg(l_module_name,'locations for entity : '||p_entity.initial_pickup_location_id||' : '||p_entity.ultimate_dropoff_location_id);
                  WSH_DEBUG_SV.logmsg(l_module_name,'locations for searching entity : '||p_entity_all(l).initial_pickup_location_id||' : '||p_entity_all(l).ultimate_dropoff_location_id);
            END IF;
            --

            IF p_entity_all(l).entity_id = p_entity.entity_id OR
                   p_entity.group_id <> p_entity_all(l).group_id THEN
                   GOTO subennextpass;
            END IF;

            -- Need to consider sequence number
            -- If l_pu_location_id and l_do_location_id both are null
            -- then can not consider sequence number as in that case sequence number
            -- is arbitrary for new stops

            IF l_pu_location_id IS NULL AND l_do_location_id IS NULL THEN

              IF ( p_entity_all(l).initial_pickup_location_id <> p_entity.initial_pickup_location_id)
              THEN

                      --IF NOT x_stop_locations.EXISTS(p_entity_all(l).initial_pickup_location_id) THEN
                      IF NOT entity_exists(p_entity_all(l).initial_pickup_location_id,x_stop_locations,z) THEN
                          l_stop_loc_cnt := l_stop_loc_cnt + 1;
                          x_stop_locations(l_stop_loc_cnt) := p_entity_all(l).initial_pickup_location_id;
                          --x_stop_locations(p_entity_all(l).initial_pickup_location_id) := p_entity_all(l).initial_pickup_location_id;
                      END IF;

              END IF;

              IF (p_entity_all(l).ultimate_dropoff_location_id <> p_entity.ultimate_dropoff_location_id)
              THEN

                      --IF NOT x_stop_locations.EXISTS(p_entity_all(l).ultimate_dropoff_location_id) THEN
                      IF NOT entity_exists(p_entity_all(l).ultimate_dropoff_location_id,x_stop_locations,z) THEN
                          l_stop_loc_cnt := l_stop_loc_cnt + 1;
                          x_stop_locations(l_stop_loc_cnt) := p_entity_all(l).ultimate_dropoff_location_id;
                          --x_stop_locations(p_entity_all(l).ultimate_dropoff_location_id) := p_entity_all(l).ultimate_dropoff_location_id;
                      END IF;

              END IF;

            -- For following 2 cases what happens if pickup sequence numbers become
            -- greater than drop off sequence numbers ??

            ELSIF l_pu_location_id IS NOT NULL AND l_do_location_id IS NULL THEN

              IF (p_entity_all(l).ultimate_dropoff_location_id <> p_entity.ultimate_dropoff_location_id)
              THEN

                      --IF NOT x_stop_locations.EXISTS(p_entity_all(l).ultimate_dropoff_location_id) THEN
                      IF NOT entity_exists(p_entity_all(l).ultimate_dropoff_location_id,x_stop_locations,z) THEN
                          l_stop_loc_cnt := l_stop_loc_cnt + 1;
                          x_stop_locations(l_stop_loc_cnt) := p_entity_all(l).ultimate_dropoff_location_id;
                          --x_stop_locations(p_entity_all(l).ultimate_dropoff_location_id) := p_entity_all(l).ultimate_dropoff_location_id;
                      END IF;

              END IF;

            ELSIF l_do_location_id IS NOT NULL AND l_pu_location_id IS NULL THEN

              IF ( p_entity_all(l).initial_pickup_location_id <> p_entity.initial_pickup_location_id)
              THEN

                      --IF NOT x_stop_locations.EXISTS(p_entity_all(l).initial_pickup_location_id) THEN
                      IF NOT entity_exists(p_entity_all(l).initial_pickup_location_id,x_stop_locations,z) THEN
                          l_stop_loc_cnt := l_stop_loc_cnt + 1;
                          x_stop_locations(l_stop_loc_cnt) := p_entity_all(l).initial_pickup_location_id;
                          --x_stop_locations(p_entity_all(l).initial_pickup_location_id) := p_entity_all(l).initial_pickup_location_id;
                      END IF;

              END IF;

            END IF;

            <<subennextpass>>

            EXIT WHEN l= p_entity_all.LAST;
            l:= p_entity_all.NEXT(l);
        END LOOP;
    END IF;

    IF p_action_code = G_ASSIGN_DLVY_TRIP THEN

       i := p_target_tripstops.FIRST;
       IF i IS NOT NULL THEN
           LOOP -- over p_target_tripstops

            -- Select only those stops which lie between(inclusive) stop sequence numbers
            -- of the input delivery's pickup and dropoff stops in this target trip

            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'for child stop : '||p_target_tripstops(i).stop_id||' location : '||p_target_tripstops(i).stop_location_id||' sequence : '||
               p_target_tripstops(i).stop_sequence_number||' Planned Arrival Date : '||p_target_tripstops(i).planned_arrival_date);
            END IF;
            --

      -- AGDUMMY
      -- Check if this stop is a physical stop corresponding to an already checked dummy stop
      -- If Yes, skip the check

	    -- Should we include the tripstop always
            -- if input pickup/drop off stop/location both are null

	    --SBAKSHI (pseudo)
            -- p_target_tripstops is sorted according to planned_arrival_dates.
            -- Dummy stop and physical stop will occur in adjacent positions.
	    -- Dummy stop and then the physical stop.
	    -- In case previous record is for a dummy location,Do not add the current record.

	    l_idx := 	p_target_tripstops.prior(i);

	    IF (p_target_tripstops(i).stop_location_id <> p_entity.initial_pickup_location_id
               AND ( p_target_tripstops(i).planned_arrival_date > nvl(l_pu_pa_date,p_entity.initial_pickup_date) ) )
               AND (p_target_tripstops(i).stop_location_id <> p_entity.ultimate_dropoff_location_id
               AND ( p_target_tripstops(i).planned_arrival_date <= nvl(l_do_pa_date,p_entity.ultimate_dropoff_date) ) )
               AND NOT (l_idx IS NOT NULL AND p_target_tripstops(l_idx).physical_location_id IS NOT NULL
	                AND p_target_tripstops(i).trip_id = p_target_tripstops(l_idx).trip_id
			AND p_target_tripstops(i).stop_location_id = p_target_tripstops(l_idx).physical_location_id)
            THEN

                   IF NOT entity_exists(p_target_tripstops(i).stop_location_id,x_stop_locations,z) THEN
                   IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'Adding target trip stop location id : '||p_target_tripstops(i).stop_location_id);
                   END IF;
                   l_stop_loc_cnt := l_stop_loc_cnt + 1;
                   x_stop_locations(l_stop_loc_cnt) := p_target_tripstops(i).stop_location_id;
                   --x_stop_locations(p_target_tripstops(i).stop_location_id) := p_target_tripstops(i).stop_location_id;
            END IF;

            END IF;

            EXIT WHEN i= p_target_tripstops.LAST;
            i:= p_target_tripstops.NEXT(i);
	   END LOOP;
       END IF;

    END IF;

    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --

EXCEPTION
    WHEN others THEN
      IF c_get_stop_location%ISOPEN THEN
         CLOSE c_get_stop_location;
      END IF;
      WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.append_current_trip_stops');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;

END append_current_trip_stops;


--***************************************************************************--
--========================================================================
-- PROCEDURE : validate_positive_constraint PRIVATE
--
-- PARAMETERS: p_action_code                Current constraint validation action
--                                          Can be 'ADT' or 'ACT'
--             p_comp_class_tab             Table of Compatibility class codes to check
--             p_entity_tab                 Table of delivery records in the current action
--             p_group_tab                  Table of entity group records currently formed
--             p_detail_tab                 Children detail records of input delivery record
--             p_target_trip                Target trip record
--             p_target_tripstops           Children stops already present in target trip
--             p_target_stops_info          Input pickup and dropoff stop/location of the delivery(s)
--                                          in the target trip in case of assign delivery to trip
--             x_line_groups                Includes Successful and warning lines
--                                          after constraint check
--                                          Contains information of which input delivery should
--                                          be grouped in which output group for trip creation
--             x_failed_lines               Table of input delivery lines that failed
--                                          constraint check
--             x_failed_constraints         Failed constraint table
--             x_return_status              Return status
-- COMMENT   :
-- Applicable for autocreate trip and assign delivery to trip
-- For a given delivery and a target trip
-- determines if the delivery can be assigned to the target trip
-- OR trip can be created
-- satisfying inclusive constraints
--========================================================================

PROCEDURE validate_positive_constraint(
                    p_action_code         IN VARCHAR2,
                    p_comp_class_tab      IN WSH_UTIL_CORE.column_tab_type,
                    p_entity_tab          IN OUT NOCOPY entity_tab_type,
                    p_group_tab           IN OUT NOCOPY WSH_FTE_COMP_CONSTRAINT_PKG.cc_group_tab_type,
                    p_detail_tab          IN detail_ccinfo_tab_type,
                    p_target_trip         IN trip_ccinfo_rec_type,
                    p_target_tripstops    IN stop_ccinfo_tab_type,
                    p_target_stops_info   IN target_tripstop_cc_rec_type,
                    x_line_groups         OUT NOCOPY    WSH_FTE_COMP_CONSTRAINT_PKG.line_group_tab_type,
                    x_failed_lines        IN OUT NOCOPY WSH_FTE_COMP_CONSTRAINT_PKG.failed_line_tab_type,
                    x_failed_constraints  IN OUT NOCOPY line_constraint_tab_type,
                    x_return_status       OUT NOCOPY    VARCHAR2)
IS

      i                           NUMBER := 0;
      j                           NUMBER := 0;
      k                           NUMBER := 0;
      t                           NUMBER := x_failed_lines.COUNT;
      l                           NUMBER := 0;
      m                           NUMBER := 0;
      o                           NUMBER := 0;
      p                           NUMBER := 0;
      l_carrier                   NUMBER := NULL;
      l_vehicle_type              NUMBER := NULL;
      l_mode                      VARCHAR2(30) := NULL;
      l_service_level             VARCHAR2(30) := NULL;
      l_carrier_service_inout_rec WSH_CARRIERS_GRP.Carrier_Service_InOut_Rec_Type;
      l_out_object2_num           NUMBER:=0;
      l_out_object2_char          VARCHAR2(30):=NULL;
      l_linegroup_indx            NUMBER := 0;
      l_return_status             VARCHAR2(1);
      l_inp_dlvy_cus              BOOLEAN := TRUE;
      l_cuscus_checked            BOOLEAN := FALSE;
      l_curr_dlvy_cus             BOOLEAN := TRUE;
      l_cusfac_checked            BOOLEAN := FALSE;
      l_supfac_checked            BOOLEAN := FALSE;
      l_checked_cus_fac           BOOLEAN := FALSE;
      l_checked_cus_fac           BOOLEAN := FALSE;
      l_checked_cus_fac           BOOLEAN := FALSE;
      l_cuscus_checked            BOOLEAN := FALSE;
      l_acd_result                VARCHAR2(1) := 'S';
      l_act_result                VARCHAR2(1) := 'S';
      l_const_count               NUMBER      := 0;
      l_validate_cuscus_result    VARCHAR2(1) := 'S';
      l_validate_carrier_result   VARCHAR2(1) := 'S';
      l_validate_vehicle_result   VARCHAR2(1) := 'S';
      l_validate_mode_result      VARCHAR2(1) := 'S';
      l_validate_orgfac_result    VARCHAR2(1) := 'S';
      l_validate_cusfac_result    VARCHAR2(1) := 'S';
      l_validate_supfac_result    VARCHAR2(1) := 'S';
      l_validate_itmfac_result    VARCHAR2(1) := 'S';
      l_failed_constraint         line_constraint_rec_type;
      l_validate_itmcar_result    VARCHAR2(1) := 'S';
      l_validate_itmveh_result    VARCHAR2(1) := 'S';
      l_validate_itmmod_result    VARCHAR2(1) := 'S';
      l_item_result               VARCHAR2(1) := 'S';
      l_stop_locations            WSH_UTIL_CORE.id_tab_type;
      l_failed_group              WSH_UTIL_CORE.id_tab_type;
      l_pu_checked                BOOLEAN := FALSE;
      l_do_checked                BOOLEAN := FALSE;
      l_pu_car_failed             BOOLEAN := FALSE;
      l_pu_mod_failed             BOOLEAN := FALSE;
      l_pu_veh_failed             BOOLEAN := FALSE;
      l_do_car_failed             BOOLEAN := FALSE;
      l_do_mod_failed             BOOLEAN := FALSE;
      l_do_veh_failed             BOOLEAN := FALSE;
      l_last_trip                 BOOLEAN := FALSE;
      l_vehicle_name              VARCHAR2(2000);
      l_vehicle_org_name          VARCHAR2(240);

      l_direct_shipment           BOOLEAN := TRUE;
      l_num_dlegs                 NUMBER      := 0;

      l_delivery_ids              WSH_UTIL_CORE.id_tab_type;
      l_tmp_count                 NUMBER := 0;

    l_module_name                 CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'validate_positive_constraint';
    l_debug_on                    CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;

BEGIN

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    IF l_debug_on THEN
       wsh_debug_sv.push(l_module_name);
       WSH_DEBUG_SV.logmsg(l_module_name,'p_target_stops_info.pickup_location_id : '||p_target_stops_info.pickup_location_id);
       WSH_DEBUG_SV.logmsg(l_module_name,'p_target_stops_info.dropoff_location_id : '||p_target_stops_info.dropoff_location_id);
    END IF;

    IF (p_target_trip.carrier_id IS NULL OR p_target_trip.MODE_OF_TRANSPORT IS NULL) AND
       (p_target_trip.ship_method_code IS NOT NULL) THEN
      l_carrier_service_inout_rec.ship_method_code := p_target_trip.ship_method_code;

      WSH_CARRIERS_GRP.get_carrier_service_mode(
               p_carrier_service_inout_rec   =>  l_carrier_service_inout_rec,
               x_return_status       =>  l_return_status);

      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
         IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
         raise g_get_carrmode_failed;
        END IF;
      END IF;
      l_carrier := l_carrier_service_inout_rec.carrier_id;
      l_mode    := l_carrier_service_inout_rec.mode_of_transport;

    END IF; -- p_target_trip.carrier_id IS NULL OR ..

    -- If carrier_id or mode is passed in, then those get preference for validation
    -- If they are not, they are derived from ship method if that is passed

    IF p_target_trip.carrier_id IS NOT NULL THEN
       l_carrier := p_target_trip.carrier_id;
    END IF;
    IF p_target_trip.MODE_OF_TRANSPORT IS NOT NULL THEN
       l_mode := p_target_trip.MODE_OF_TRANSPORT;
    END IF;

    IF (p_target_trip.VEHICLE_ITEM_ID IS NOT NULL AND p_target_trip.VEHICLE_ORGANIZATION_ID IS NOT NULL) THEN

      WSH_FTE_INTEGRATION.get_vehicle_type(
               p_vehicle_item_id     =>  p_target_trip.VEHICLE_ITEM_ID,
               p_vehicle_org_id      =>  p_target_trip.VEHICLE_ORGANIZATION_ID,
               x_vehicle_type_id     =>  l_vehicle_type,
               x_return_status       =>  l_return_status);

      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
         IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
            l_vehicle_name := WSH_UTIL_CORE.get_item_name (p_item_id => p_target_trip.VEHICLE_ITEM_ID,
                                                           p_organization_id => p_target_trip.VEHICLE_ORGANIZATION_ID);
            l_vehicle_org_name := WSH_UTIL_CORE.get_org_name (p_organization_id => p_target_trip.VEHICLE_ORGANIZATION_ID);
            FND_MESSAGE.SET_NAME('WSH','WSH_VEHICLE_TYPE_UNDEFINED');
            FND_MESSAGE.SET_TOKEN('ITEM',l_vehicle_name);
            FND_MESSAGE.SET_TOKEN('ORGANIZATION',l_vehicle_org_name);
            FND_MSG_PUB.ADD;
         --raise g_get_vehicletype_failed;
        END IF;
      END IF;

    END IF; -- p_target_trip.VEHICLE_ITEM_ID IS NOT NULL AND ..

    IF p_action_code = G_ASSIGN_DLVY_TRIP THEN

        IF p_target_stops_info.pickup_location_id IS NOT NULL THEN

         l_pu_checked := TRUE;

         IF p_comp_class_tab.EXISTS(G_FACILITY_CARRIER_NUM) AND
            l_carrier IS NOT NULL AND p_target_stops_info.pickup_stop_id IS NULL THEN

            check_inclusive_object2(
             p_comp_class_code          =>      G_FACILITY_CARRIER,
             p_entity_type              =>      G_LOCATION,
             p_entity_id                =>      p_target_stops_info.pickup_location_id,
             p_object1_type             =>      'FAC',
             p_object1_val_num          =>      p_target_stops_info.pickup_location_id,
             p_object2_type             =>      'CAR',
             p_object2_val_num          =>      l_carrier,
             x_out_object2_num          =>      l_out_object2_num,
             x_out_object2_char         =>      l_out_object2_char,
             x_validate_result          =>      l_validate_carrier_result,
             x_failed_constraint        =>      x_failed_constraints,
             x_return_status            =>      l_return_status);

            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                  raise FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            END IF;

            IF l_validate_carrier_result = 'F' THEN

               l_pu_car_failed := TRUE;

            END IF;

         END IF;

         IF p_comp_class_tab.EXISTS(G_FACILITY_MODE_NUM) AND
            l_mode IS NOT NULL AND p_target_stops_info.pickup_stop_id IS NULL THEN

            check_inclusive_object2(
             p_comp_class_code          =>      G_FACILITY_MODE,
             p_entity_type              =>      G_LOCATION,
             p_entity_id                =>      p_target_stops_info.pickup_location_id,
             p_object1_type             =>      'FAC',
             p_object1_val_num          =>      p_target_stops_info.pickup_location_id,
             p_object2_type             =>      'MOD',
             p_object2_val_char         =>      l_mode,
             x_out_object2_num          =>      l_out_object2_num,
             x_out_object2_char         =>      l_out_object2_char,
             x_validate_result          =>      l_validate_mode_result,
             x_failed_constraint        =>      x_failed_constraints,
             x_return_status            =>      l_return_status);

            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                  raise FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            END IF;

            IF l_validate_mode_result = 'F' THEN

               l_pu_mod_failed := TRUE;

            END IF;

         END IF;

         IF p_comp_class_tab.EXISTS(G_FACILITY_VEHICLE_NUM) AND
            l_vehicle_type IS NOT NULL AND p_target_stops_info.pickup_stop_id IS NULL THEN

            check_inclusive_object2(
             p_comp_class_code          =>      G_FACILITY_VEHICLE,
             p_entity_type              =>      G_LOCATION,
             p_entity_id                =>      p_target_stops_info.pickup_location_id,
             p_object1_type             =>      'FAC',
             p_object1_val_num          =>      p_target_stops_info.pickup_location_id,
             p_object2_type             =>      'VHT',
             p_object2_val_num          =>      l_vehicle_type,
             x_out_object2_num          =>      l_out_object2_num,
             x_out_object2_char         =>      l_out_object2_char,
             x_validate_result          =>      l_validate_vehicle_result,
             x_failed_constraint        =>      x_failed_constraints,
             x_return_status            =>      l_return_status);

            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                  raise FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            END IF;

            IF l_validate_vehicle_result = 'F' THEN

               l_pu_veh_failed := TRUE;

            END IF;

         END IF;

        END IF;

        IF p_target_stops_info.dropoff_location_id IS NOT NULL THEN

         l_do_checked := TRUE;

         IF p_comp_class_tab.EXISTS(G_FACILITY_CARRIER_NUM) AND
            l_carrier IS NOT NULL AND p_target_stops_info.dropoff_stop_id IS NULL THEN

            check_inclusive_object2(
             p_comp_class_code          =>      G_FACILITY_CARRIER,
             p_entity_type              =>      G_LOCATION,
             p_entity_id                =>      p_target_stops_info.dropoff_location_id,
             p_object1_type             =>      'FAC',
             p_object1_val_num          =>      p_target_stops_info.dropoff_location_id,
             p_object2_type             =>      'CAR',
             p_object2_val_num          =>      l_carrier,
             x_out_object2_num          =>      l_out_object2_num,
             x_out_object2_char         =>      l_out_object2_char,
             x_validate_result          =>      l_validate_carrier_result,
             x_failed_constraint        =>      x_failed_constraints,
             x_return_status            =>      l_return_status);

            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                  raise FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            END IF;

            IF l_validate_carrier_result = 'F' THEN

               l_do_car_failed := TRUE;

            END IF;

         END IF;

         IF p_comp_class_tab.EXISTS(G_FACILITY_MODE_NUM) AND
            l_mode IS NOT NULL AND p_target_stops_info.dropoff_stop_id IS NULL THEN

            check_inclusive_object2(
             p_comp_class_code          =>      G_FACILITY_MODE,
             p_entity_type              =>      G_LOCATION,
             p_entity_id                =>      p_target_stops_info.dropoff_location_id,
             p_object1_type             =>      'FAC',
             p_object1_val_num          =>      p_target_stops_info.dropoff_location_id,
             p_object2_type             =>      'MOD',
             p_object2_val_char         =>      l_mode,
             x_out_object2_num          =>      l_out_object2_num,
             x_out_object2_char         =>      l_out_object2_char,
             x_validate_result          =>      l_validate_mode_result,
             x_failed_constraint        =>      x_failed_constraints,
             x_return_status            =>      l_return_status);

            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                  raise FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            END IF;

            IF l_validate_mode_result = 'F' THEN

               l_do_mod_failed := TRUE;

            END IF;

         END IF;

         IF p_comp_class_tab.EXISTS(G_FACILITY_VEHICLE_NUM) AND
            l_vehicle_type IS NOT NULL AND p_target_stops_info.dropoff_stop_id IS NULL THEN

            check_inclusive_object2(
             p_comp_class_code          =>      G_FACILITY_VEHICLE,
             p_entity_type              =>      G_LOCATION,
             p_entity_id                =>      p_target_stops_info.dropoff_location_id,
             p_object1_type             =>      'FAC',
             p_object1_val_num          =>      p_target_stops_info.dropoff_location_id,
             p_object2_type             =>      'VHT',
             p_object2_val_num          =>      l_vehicle_type,
             x_out_object2_num          =>      l_out_object2_num,
             x_out_object2_char         =>      l_out_object2_char,
             x_validate_result          =>      l_validate_vehicle_result,
             x_failed_constraint        =>      x_failed_constraints,
             x_return_status            =>      l_return_status);

            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                  raise FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            END IF;

            IF l_validate_vehicle_result = 'F' THEN

               l_do_veh_failed := TRUE;

            END IF;

         END IF;

        END IF;

    END IF;

    -- First check org -fac, cus -fac, itm -fac for every entity
    -- against other locations in the same group
    -- Supplier - Facility


    IF p_action_code = G_ASSIGN_DLVY_TRIP THEN

    -- LOOP over p_entity_tab to populate l_delivery_ids dense table
    -- use it to bulk insert into the global temp table
    p := p_entity_tab.FIRST;
    IF p IS NOT NULL THEN
        LOOP -- Over each entity in that group

          o := o+1;
          l_delivery_ids(o) := p_entity_tab(p).entity_id;

          EXIT WHEN p = p_entity_tab.LAST;
          p:= p_entity_tab.NEXT(p);
        END LOOP;
    END IF;

    IF l_delivery_ids.COUNT > 0 THEN

    IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Inserting into wsh_constraint_dleg_tmp ');
    END IF;


    FORALL q in l_delivery_ids.FIRST..l_delivery_ids.LAST
    INSERT INTO wsh_constraint_dleg_tmp (
    SELECT wdl.delivery_leg_id,wdl.sequence_number,
           wdl.pick_up_stop_id, wdl.drop_off_stop_id,
           nvl(wts1.physical_location_id,wts1.stop_location_id) ,
           nvl(wts2.physical_location_id,wts2.stop_location_id) ,
           wts1.planned_arrival_date ,
           wts2.planned_arrival_date ,
           wts1.trip_id,
           wdl.delivery_id
    FROM   wsh_delivery_legs wdl,
           wsh_trip_stops wts1,
           wsh_trip_stops wts2
    WHERE  wdl.delivery_id = l_delivery_ids(q)
    AND    wdl.pick_up_stop_id = wts1.stop_id
    AND    wdl.drop_off_stop_id = wts2.stop_id
    AND    wdl.delivery_leg_id NOT IN
           ( select wcdt.delivery_leg_id
             from wsh_constraint_dleg_tmp wcdt
             where wcdt.delivery_leg_id = wdl.delivery_leg_id)
    );

    /*
    SELECT COUNT(*)
    INTO l_tmp_count
    FROM wsh_constraint_dleg_tmp;

    IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Inserted :'||l_tmp_count||' rows into wsh_constraint_dleg_tmp ');
    END IF;
    */

    ELSE
       IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'No records present in l_delivery_ids');
       END IF;
    END IF;
    END IF;

    k := p_entity_tab.FIRST;
    IF k IS NOT NULL THEN
        LOOP -- Over each entity in that group

          IF p_entity_tab(k).shipping_control = 'SUPPLIER' THEN
             GOTO entity_nextpass;
          END IF;

          l_stop_locations.DELETE;
          l_item_result := 'S';
          l_last_trip := FALSE;
          l_direct_shipment := TRUE;

          -- If ADT check locations of p_entity_tab(k) against carrier,mode of p_target_trip

          -- Check delivery's initial pickup only if that location is the pickup of that
          -- delivery in that trip. Same applies to ultimate dropoff.
          -- So if input pickup_stop_id has been passed, this check does not apply.
          -- Same for dropoff_stop_id.
          -- Applies against pickup_location_id/dropoff_location_id if they have been input

          IF p_action_code = G_ASSIGN_DLVY_TRIP THEN

	    IF l_debug_on THEN
	       WSH_DEBUG_SV.logmsg(l_module_name,'p_entity_tab(k).entity_id : '||p_entity_tab(k).entity_id);
	       WSH_DEBUG_SV.logmsg(l_module_name,'p_entity_tab(k).initial_pickup_location_id : '||p_entity_tab(k).initial_pickup_location_id);
	       WSH_DEBUG_SV.logmsg(l_module_name,'p_entity_tab(k).ultimate_dropoff_location_id : '||p_entity_tab(k).ultimate_dropoff_location_id);
	    END IF;
            -- Take care that for pickup/dropoff location id input same check is not done
            -- more than once

      -- Facility  - Vehicle

           IF p_comp_class_tab.EXISTS(G_FACILITY_CARRIER_NUM) AND
              l_carrier IS NOT NULL THEN

            IF p_target_stops_info.pickup_stop_id IS NULL AND ( NOT l_pu_checked) THEN

              check_inclusive_object2(
               p_comp_class_code          =>      G_FACILITY_CARRIER,
               p_entity_type              =>      G_DELIVERY,
               p_entity_id                =>      p_entity_tab(k).entity_id,
               p_object1_type             =>      'FAC',
               p_object1_val_num          =>      p_entity_tab(k).initial_pickup_location_id,
               p_object2_type             =>      'CAR',
               p_object2_val_num          =>      l_carrier,
               x_out_object2_num          =>      l_out_object2_num,
               x_out_object2_char         =>      l_out_object2_char,
               x_validate_result          =>      l_validate_carrier_result,
               x_failed_constraint        =>      x_failed_constraints,
               x_return_status            =>      l_return_status);

              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;
              END IF;

              IF l_validate_carrier_result = 'F' THEN
                 p_entity_tab.DELETE(k);
                 t := t+1;
                 x_failed_lines(t).failed_line_index := t;
                 x_failed_lines(t).entity_line_id := k;
                 GOTO entity_nextpass;
              END IF;

            ELSIF l_pu_checked AND l_pu_car_failed THEN

                 p_entity_tab.DELETE(k);
                 t := t+1;
                 x_failed_lines(t).failed_line_index := t;
                 x_failed_lines(t).entity_line_id := k;
                 GOTO entity_nextpass;

            END IF;

            IF p_target_stops_info.dropoff_stop_id IS NULL AND ( NOT l_do_checked) THEN

              check_inclusive_object2(
               p_comp_class_code          =>      G_FACILITY_CARRIER,
               p_entity_type              =>      G_DELIVERY,
               p_entity_id                =>      p_entity_tab(k).entity_id,
               p_object1_type             =>      'FAC',
               p_object1_val_num          =>      p_entity_tab(k).ultimate_dropoff_location_id,
               p_object2_type             =>      'CAR',
               p_object2_val_num          =>      l_carrier,
               x_out_object2_num          =>      l_out_object2_num,
               x_out_object2_char         =>      l_out_object2_char,
               x_validate_result          =>      l_validate_carrier_result,
               x_failed_constraint        =>      x_failed_constraints,
               x_return_status            =>      l_return_status);

              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;
              END IF;

              IF l_validate_carrier_result = 'F' THEN
                 p_entity_tab.DELETE(k);
                 t := t+1;
                 x_failed_lines(t).failed_line_index := t;
                 x_failed_lines(t).entity_line_id := k;
                 GOTO entity_nextpass;
              END IF;

            ELSIF l_do_checked AND l_do_car_failed THEN

                 p_entity_tab.DELETE(k);
                 t := t+1;
                 x_failed_lines(t).failed_line_index := t;
                 x_failed_lines(t).entity_line_id := k;
                 GOTO entity_nextpass;

            END IF;

           END IF;

           IF p_comp_class_tab.EXISTS(G_FACILITY_MODE_NUM) AND
              l_mode IS NOT NULL THEN

            IF p_target_stops_info.pickup_stop_id IS NULL AND ( NOT l_pu_checked) THEN

              check_inclusive_object2(
               p_comp_class_code          =>      G_FACILITY_MODE,
               p_entity_type              =>      G_DELIVERY,
               p_entity_id                =>      p_entity_tab(k).entity_id,
               p_object1_type             =>      'FAC',
               p_object1_val_num          =>      p_entity_tab(k).initial_pickup_location_id,
               p_object2_type             =>      'MOD',
               p_object2_val_char         =>      l_mode,
               x_out_object2_num          =>      l_out_object2_num,
               x_out_object2_char         =>      l_out_object2_char,
               x_validate_result          =>      l_validate_mode_result,
               x_failed_constraint        =>      x_failed_constraints,
               x_return_status            =>      l_return_status);

              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;
              END IF;

              IF l_validate_mode_result = 'F' THEN
                 p_entity_tab.DELETE(k);
                 t := t+1;
                 x_failed_lines(t).failed_line_index := t;
                 x_failed_lines(t).entity_line_id := k;
                 GOTO entity_nextpass;
              END IF;

            ELSIF l_pu_checked AND l_pu_mod_failed THEN

                 p_entity_tab.DELETE(k);
                 t := t+1;
                 x_failed_lines(t).failed_line_index := t;
                 x_failed_lines(t).entity_line_id := k;
                 GOTO entity_nextpass;

            END IF;

            IF p_target_stops_info.dropoff_stop_id IS NULL AND ( NOT l_do_checked) THEN

              check_inclusive_object2(
               p_comp_class_code          =>      G_FACILITY_MODE,
               p_entity_type              =>      G_DELIVERY,
               p_entity_id                =>      p_entity_tab(k).entity_id,
               p_object1_type             =>      'FAC',
               p_object1_val_num          =>      p_entity_tab(k).ultimate_dropoff_location_id,
               p_object2_type             =>      'MOD',
               p_object2_val_char         =>      l_mode,
               x_out_object2_num          =>      l_out_object2_num,
               x_out_object2_char         =>      l_out_object2_char,
               x_validate_result          =>      l_validate_mode_result,
               x_failed_constraint        =>      x_failed_constraints,
               x_return_status            =>      l_return_status);

              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                     raise FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
              END IF;

              IF l_validate_mode_result = 'F' THEN
                 p_entity_tab.DELETE(k);
                 t := t+1;
                 x_failed_lines(t).failed_line_index := t;
                 x_failed_lines(t).entity_line_id := k;
                 GOTO entity_nextpass;
              END IF;

            ELSIF l_do_checked AND l_do_mod_failed THEN

                 p_entity_tab.DELETE(k);
                 t := t+1;
                 x_failed_lines(t).failed_line_index := t;
                 x_failed_lines(t).entity_line_id := k;
                 GOTO entity_nextpass;

            END IF;

           END IF;
           IF p_comp_class_tab.EXISTS(G_FACILITY_VEHICLE_NUM) AND
              l_vehicle_type IS NOT NULL THEN

            IF p_target_stops_info.pickup_stop_id IS NULL AND ( NOT l_pu_checked) THEN

              check_inclusive_object2(
               p_comp_class_code          =>      G_FACILITY_VEHICLE,
               p_entity_type              =>      G_DELIVERY,
               p_entity_id                =>      p_entity_tab(k).entity_id,
               p_object1_type             =>      'FAC',
               p_object1_val_num          =>      p_entity_tab(k).initial_pickup_location_id,
               p_object2_type             =>      'VHT',
               p_object2_val_num          =>      l_vehicle_type,
               x_out_object2_num          =>      l_out_object2_num,
               x_out_object2_char         =>      l_out_object2_char,
               x_validate_result          =>      l_validate_vehicle_result,
               x_failed_constraint        =>      x_failed_constraints,
               x_return_status            =>      l_return_status);

              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                     IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                     END IF;
              END IF;

              IF l_validate_vehicle_result = 'F' THEN
                 p_entity_tab.DELETE(k);
                 t := t+1;
                 x_failed_lines(t).failed_line_index := t;
                 x_failed_lines(t).entity_line_id := k;
                 GOTO entity_nextpass;
              END IF;

            ELSIF l_pu_checked AND l_pu_veh_failed THEN

                 p_entity_tab.DELETE(k);
                 t := t+1;
                 x_failed_lines(t).failed_line_index := t;
                 x_failed_lines(t).entity_line_id := k;
                 GOTO entity_nextpass;

            END IF;

            IF p_target_stops_info.dropoff_stop_id IS NULL AND ( NOT l_do_checked) THEN

              check_inclusive_object2(
               p_comp_class_code          =>      G_FACILITY_VEHICLE,
               p_entity_type              =>      G_DELIVERY,
               p_entity_id                =>      p_entity_tab(k).entity_id,
               p_object1_type             =>      'FAC',
               p_object1_val_num          =>      p_entity_tab(k).ultimate_dropoff_location_id,
               p_object2_type             =>      'VHT',
               p_object2_val_num          =>      l_vehicle_type,
               x_out_object2_num          =>      l_out_object2_num,
               x_out_object2_char         =>      l_out_object2_char,
               x_validate_result          =>      l_validate_vehicle_result,
               x_failed_constraint        =>      x_failed_constraints,
               x_return_status            =>      l_return_status);

              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                      raise FND_API.G_EXC_UNEXPECTED_ERROR;
                   END IF;
              END IF;

              IF l_validate_vehicle_result = 'F' THEN
                 p_entity_tab.DELETE(k);
                 t := t+1;
                 x_failed_lines(t).failed_line_index := t;
                 x_failed_lines(t).entity_line_id := k;
                 GOTO entity_nextpass;
              END IF;

            ELSIF l_do_checked AND l_do_veh_failed THEN

                 p_entity_tab.DELETE(k);
                 t := t+1;
                 x_failed_lines(t).failed_line_index := t;
                 x_failed_lines(t).entity_line_id := k;
                 GOTO entity_nextpass;

            END IF;

           END IF;

             -- 1. First determine if after assigning to this trip, the delivery
             --    is complete

            l_last_trip := is_last_trip (
                               p_delivery_id        => p_entity_tab(k).entity_id,
                               p_initial_pu_loc_id  => p_entity_tab(k).initial_pickup_location_id,
                               p_ultimate_do_loc_id => p_entity_tab(k).ultimate_dropoff_location_id,
                               p_target_trip_id       => p_target_trip.trip_id,
                               p_target_stops_in_trip => p_target_stops_info,
                               x_return_status        => l_return_status);

            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;
            END IF;


             -- 2. If Yes, proceed to determine all stops from first trip to last trip

            IF l_last_trip THEN

                -- Start from first trip
                -- Obtain list of stops excluding delivery's initial_pickup and ultimate dropoff
                -- proceed to next trip and obtain all stops of the delivery on it
                -- continue like this

                IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Trip : '||p_target_trip.trip_id||' is last_trip for current delivery : '||p_entity_tab(k).entity_id);
                END IF;

                get_intmed_stops (
                    p_delivery_id         =>    p_entity_tab(k).entity_id,
                    p_pickup_loc_id       =>    p_entity_tab(k).initial_pickup_location_id,
                    p_dropoff_loc_id      =>    p_entity_tab(k).ultimate_dropoff_location_id,
                    x_num_dlegs           =>    l_num_dlegs,
                    x_stop_locations      =>    l_stop_locations,
                    x_return_status       =>    l_return_status);

                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                      raise FND_API.G_EXC_UNEXPECTED_ERROR;
                   END IF;
                END IF;

                -- Even if number of dlegs is 1, it means the current assignment
                -- will make it a multileg delivery

                --IF l_stop_locations.COUNT > 0 THEN
                IF l_num_dlegs >= 1 THEN
                   IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'current delivery : '||p_entity_tab(k).entity_id||' has '||l_num_dlegs||' delivery legs now and hence will not be direct shipment');
                   END IF;

                   l_direct_shipment := FALSE;
                END IF;
                 --No need to append all the trip stops as they are not to be used.
            END IF;

	  END IF;

          --
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'l_stop_locations count : '||l_stop_locations.COUNT);
          END IF;
          --

          IF p_action_code = G_AUTOCRT_DLVY_TRIP OR p_action_code = G_AUTOCRT_MDC THEN
          -- check if locations of p_entity_tab has
          -- a different must be carrier / mode than any other location in l_stop_locations
          -- If Yes, create a new group for that
             l_const_count   := x_failed_constraints.COUNT;

             check_act_carmode (
                      p_comp_class_tab     => p_comp_class_tab,
                      p_delivery_rec       => p_entity_tab(k),
                      p_group_locations    => l_stop_locations,
                      x_failed_constraint  => x_failed_constraints,
                      x_validate_result    => l_act_result,
                      x_return_status      => l_return_status);

             IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;
             END IF;

             IF l_act_result = 'F' THEN

               IF p_entity_tab(k).entity_id IS NULL THEN
                 p_entity_tab.DELETE(k);
                 t := t+1;
                 x_failed_lines(t).failed_line_index := t;
                 x_failed_lines(t).entity_line_id := k;
                 GOTO entity_nextpass;

               ELSE
                 -- Remove p_entity_tab(k) from its current group if it still exists
                 -- create a new group for it
                 IF ( l_const_count < x_failed_constraints.COUNT) THEN

                      x_failed_constraints.DELETE(l_const_count+1,x_failed_constraints.COUNT);

                 END IF;

                 create_valid_entity_group(
                    p_entity_rec            => p_entity_tab(k), -- IN OUT
                    p_group_tab             => p_group_tab, -- IN OUT
                    x_return_status         => l_return_status);
                 --
                 IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Called create_valid_entity_group return status : '||l_return_status);
                 END IF;
                 --

                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                      raise FND_API.G_EXC_UNEXPECTED_ERROR;
                   END IF;
                 END IF;

                   -- Also remove group record if it does not have children inside

               END IF;
             END IF;

          END IF; -- ACT

            -- Check org , cus of p_entity_tab(k) against l_stop_locations

      -- 1.
      -- Inclusive facilities should be checked only if the current target trip is found to be
      -- the last trip that the input delivery is being assigned to
      -- The list of locations for checking inclusive constraints then will include
      -- all stops between first pickup and last dropoff of the delivery
      -- in all the trips that the delivery is on
      -- Take extra care in identifying intersecting stops of the trips as well
      -- Stop sequence number determines sequence of the stops

      -- 2.
      -- Hence
      -- For checking exclusive constraints
      -- create a list of locations between delivery's pickup and dropoff in target trip
      -- that need to be checked
      -- validate org, cus, sup, itm - facility constraint for each delivery
      -- against this list each time assign delivery to trip happens

      -- 3.
      -- For inclusive constraints
      -- determine if the current target trip is the last dleg of the current delivery
      -- If yes, create a list of intermediate stop locations considering all trips as 1 above
      -- validate org, cus, sup, itm - facility constraint for each delivery against this list

      -- Supplier - Facility
          -- alksharm
          -- When the action code is G_AUTOCRT_MDC, must use discretionary routing point checks
          -- if any will be ignored as those will be enforced later as part of deconsol
          -- location derivation for a delivery.

          IF  p_action_code = G_AUTOCRT_DLVY_TRIP OR
             (p_action_code = G_ASSIGN_DLVY_TRIP AND l_last_trip) THEN

           IF p_comp_class_tab.EXISTS(G_SHIPORG_FACILITY_NUM) AND
              p_entity_tab(k).shipment_direction <> 'D' THEN

              check_inclusive_facilities(
                    p_comp_class_code          =>      G_SHIPORG_FACILITY,
                    p_entity_type              =>      G_DELIVERY,
                    p_entity_id                =>      p_entity_tab(k).entity_id,
                    p_attribute_id             =>      p_entity_tab(k).organization_id,
                    p_location_list            =>      l_stop_locations,
                    p_direct_shipment          =>      l_direct_shipment,
                    x_validate_result          =>      l_validate_orgfac_result,
                    x_failed_constraint        =>      x_failed_constraints,
                    x_return_status            =>      l_return_status);

                  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                     IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                     END IF;
                  END IF;

              IF l_validate_orgfac_result = 'F' THEN
                 p_entity_tab.DELETE(k);
                 t := t+1;
                 x_failed_lines(t).failed_line_index := t;
                 x_failed_lines(t).entity_line_id := k;
                 GOTO entity_nextpass;
              END IF;

           END IF;

           IF p_comp_class_tab.EXISTS(G_CUSTOMER_FACILITY_NUM) AND
              p_entity_tab(k).shipment_direction <> 'I' THEN

              -- Need to check for a customer location
              -- or all locations of a customer

              check_inclusive_facilities(
                    p_comp_class_code          =>      G_CUSTOMER_FACILITY,
                    p_entity_type              =>      G_DELIVERY,
                    p_entity_id                =>      p_entity_tab(k).entity_id,
                    p_object1_type             =>      'FAC',
                    p_object1_physical_id      =>      p_entity_tab(k).physical_dropoff_location_id,
                    p_attribute_id             =>      p_entity_tab(k).ultimate_dropoff_location_id,
                    p_location_list            =>      l_stop_locations,
                    p_direct_shipment          =>      l_direct_shipment,
                    x_validate_result          =>      l_validate_cusfac_result,
                    x_failed_constraint        =>      x_failed_constraints,
                    x_return_status            =>      l_return_status);

                   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                         raise FND_API.G_EXC_UNEXPECTED_ERROR;
                      END IF;
                   END IF;

              IF l_validate_cusfac_result = 'F' THEN
                 p_entity_tab.DELETE(k);
                 t := t+1;
                 x_failed_lines(t).failed_line_index := t;
                 x_failed_lines(t).entity_line_id := k;
                 GOTO entity_nextpass;
              END IF;


              check_inclusive_facilities(
                    p_comp_class_code          =>      G_CUSTOMER_FACILITY,
                    p_entity_type              =>      G_DELIVERY,
                    p_entity_id                =>      p_entity_tab(k).entity_id,
                    p_object1_type             =>      'CUS',
                    p_attribute_id             =>      p_entity_tab(k).customer_id,
                    p_location_list            =>      l_stop_locations,
                    p_direct_shipment          =>      l_direct_shipment,
                    x_validate_result          =>      l_validate_cusfac_result,
                    x_failed_constraint        =>      x_failed_constraints,
                    x_return_status            =>      l_return_status);

                   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                         raise FND_API.G_EXC_UNEXPECTED_ERROR;
                      END IF;
                   END IF;

              IF l_validate_cusfac_result = 'F' THEN
                 p_entity_tab.DELETE(k);
                 t := t+1;
                 x_failed_lines(t).failed_line_index := t;
                 x_failed_lines(t).entity_line_id := k;
                 GOTO entity_nextpass;
              END IF;

           END IF;

           IF p_comp_class_tab.EXISTS(G_SUPPLIER_FACILITY_NUM) AND
              p_entity_tab(k).shipment_direction <> 'O' THEN

              -- Need to check for a customer location
              -- or all locations of a customer

              check_inclusive_facilities(
                    p_comp_class_code          =>      G_SUPPLIER_FACILITY,
                    p_entity_type              =>      G_DELIVERY,
                    p_entity_id                =>      p_entity_tab(k).entity_id,
                    p_object1_type             =>      'FAC',
                    p_attribute_id             =>      p_entity_tab(k).initial_pickup_location_id,
                    p_location_list            =>      l_stop_locations,
                    p_direct_shipment          =>      l_direct_shipment,
                    x_validate_result          =>      l_validate_supfac_result,
                    x_failed_constraint        =>      x_failed_constraints,
                    x_return_status            =>      l_return_status);

                   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                         raise FND_API.G_EXC_UNEXPECTED_ERROR;
                      END IF;
                   END IF;

              IF l_validate_supfac_result = 'F' THEN
                 p_entity_tab.DELETE(k);
                 t := t+1;
                 x_failed_lines(t).failed_line_index := t;
                 x_failed_lines(t).entity_line_id := k;
                 GOTO entity_nextpass;
              END IF;


              check_inclusive_facilities(
                    p_comp_class_code          =>      G_SUPPLIER_FACILITY,
                    p_entity_type              =>      G_DELIVERY,
                    p_entity_id                =>      p_entity_tab(k).entity_id,
                    p_object1_type             =>      'SUP',
                    p_attribute_id             =>      p_entity_tab(k).party_id,
                    p_location_list            =>      l_stop_locations,
                    p_direct_shipment          =>      l_direct_shipment,
                    x_validate_result          =>      l_validate_supfac_result,
                    x_failed_constraint        =>      x_failed_constraints,
                    x_return_status            =>      l_return_status);

                   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                         raise FND_API.G_EXC_UNEXPECTED_ERROR;
                      END IF;
                   END IF;

              IF l_validate_supfac_result = 'F' THEN
                 p_entity_tab.DELETE(k);
                 t := t+1;
                 x_failed_lines(t).failed_line_index := t;
                 x_failed_lines(t).entity_line_id := k;
                 GOTO entity_nextpass;
              END IF;

           END IF;

          END IF;

          IF (p_action_code = G_AUTOCRT_DLVY_TRIP OR  p_action_code = G_AUTOCRT_MDC) AND
              (p_entity_tab(k).ship_method_code IS NOT NULL OR
               p_entity_tab(k).carrier_id IS NOT NULL OR
               p_entity_tab(k).mode_of_transport IS NOT NULL) AND
             NOT l_failed_group.EXISTS(p_entity_tab(k).group_id) THEN

             -- Check initial,drop off locations
             -- and all items in that sequence
             -- against delivery's ship method
             -- for Inclusive constraint
             -- if for any delivery a violation is found,
             -- mark upd_ship_method = 'N' for that delivery's group
             -- and no need to check for any other delivery in that group

                check_act_positive (
                      p_comp_class_tab     => p_comp_class_tab,
                      p_delivery_rec       => p_entity_tab(k),
                      x_failed_constraint  => x_failed_constraints,
                      x_validate_result    => l_acd_result,
                      x_return_status      => l_return_status);

                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                     IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                     END IF;
                END IF;

                IF l_acd_result = 'F' THEN
                   l_failed_group(p_entity_tab(k).group_id) := p_entity_tab(k).group_id;
                   p_group_tab(p_entity_tab(k).group_id).upd_dlvy_ship_method := 'N';

                END IF;


          END IF;

          m := p_detail_tab.FIRST;
          IF m IS NOT NULL THEN
           LOOP -- Over each entity in that group

            IF p_detail_tab(m).delivery_id <> p_entity_tab(k).entity_id THEN
                GOTO detail_nextpass;
            END IF;

             -- Check itm of p_detail_tab(m) against l_stop_locations
            IF  p_action_code = G_AUTOCRT_DLVY_TRIP OR
               (p_action_code = G_ASSIGN_DLVY_TRIP AND l_last_trip) THEN

             IF p_comp_class_tab.EXISTS(G_ITEM_FACILITY_NUM) THEN

                check_inclusive_facilities(
                   p_comp_class_code          =>      G_ITEM_FACILITY,
                   p_entity_type              =>      G_DEL_DETAIL,
                   p_entity_id                =>      p_detail_tab(m).delivery_detail_id,
                   p_attribute_id             =>      p_detail_tab(m).inventory_item_id,
                   p_parent_id                =>      p_detail_tab(m).organization_id,
                   p_location_list            =>      l_stop_locations,
                   p_direct_shipment          =>      l_direct_shipment,
                   x_validate_result          =>      l_validate_itmfac_result,
                   x_failed_constraint        =>      x_failed_constraints,
                   x_return_status            =>      l_return_status);

                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                       raise FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
                END IF;

                IF l_validate_itmfac_result = 'F' THEN
                   l_item_result := 'F';
                END IF;

             END IF;
            END IF;

            IF p_action_code = G_ASSIGN_DLVY_TRIP THEN

             -- Item - Vehicle

             IF p_comp_class_tab.EXISTS(G_ITEM_CARRIER_NUM) AND
                l_carrier IS NOT NULL THEN

                check_inclusive_object2(
                 p_comp_class_code          =>      G_ITEM_CARRIER,
                 p_entity_type              =>      G_DEL_DETAIL,
                 p_entity_id                =>      p_detail_tab(m).delivery_detail_id,
                 p_object1_type             =>      'ITM',
                 p_object1_val_num          =>      p_detail_tab(m).inventory_item_id,
                 p_object1_parent_id        =>      p_detail_tab(m).organization_id,  -- Only for item
                 p_object2_type             =>      'CAR',
                 p_object2_val_num          =>      l_carrier,
                 x_out_object2_num          =>      l_out_object2_num,
                 x_out_object2_char         =>      l_out_object2_char,
                 x_validate_result          =>      l_validate_carrier_result,
                 x_failed_constraint        =>      x_failed_constraints,
                 x_return_status            =>      l_return_status);

                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                      raise FND_API.G_EXC_UNEXPECTED_ERROR;
                   END IF;
                END IF;

                IF l_validate_carrier_result = 'F' THEN
                   l_item_result := 'F';
                END IF;

             END IF;

             IF p_comp_class_tab.EXISTS(G_ITEM_VEHICLE_NUM) AND
                l_vehicle_type IS NOT NULL THEN

                check_inclusive_object2(
                 p_comp_class_code          =>      G_ITEM_VEHICLE,
                 p_entity_type              =>      G_DEL_DETAIL,
                 p_entity_id                =>      p_detail_tab(m).delivery_detail_id,
                 p_object1_type             =>      'ITM',
                 p_object1_val_num          =>      p_detail_tab(m).inventory_item_id,
                 p_object1_parent_id        =>      p_detail_tab(m).organization_id,  -- Only for item
                 p_object2_type             =>      'VHT',
                 p_object2_val_num          =>      l_vehicle_type,
                 x_out_object2_num          =>      l_out_object2_num,
                 x_out_object2_char         =>      l_out_object2_char,
                 x_validate_result          =>      l_validate_vehicle_result,
                 x_failed_constraint        =>      x_failed_constraints,
                 x_return_status            =>      l_return_status);

                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                      raise FND_API.G_EXC_UNEXPECTED_ERROR;
                   END IF;
                END IF;

                IF l_validate_vehicle_result = 'F' THEN
                   l_item_result := 'F';
                END IF;

             END IF;

             IF p_comp_class_tab.EXISTS(G_ITEM_MODE_NUM) AND
                l_mode IS NOT NULL THEN

                check_inclusive_object2(
                 p_comp_class_code          =>      G_ITEM_MODE,
                 p_entity_type              =>      G_DEL_DETAIL,
                 p_entity_id                =>      p_detail_tab(m).delivery_detail_id,
                 p_object1_type             =>      'ITM',
                 p_object1_val_num          =>      p_detail_tab(m).inventory_item_id,
                 p_object1_parent_id        =>      p_detail_tab(m).organization_id,  -- Only for item
                 p_object2_type             =>      'MOD',
                 p_object2_val_char          =>      l_mode,
                 x_out_object2_num          =>      l_out_object2_num,
                 x_out_object2_char         =>      l_out_object2_char,
                 x_validate_result          =>      l_validate_mode_result,
                 x_failed_constraint        =>      x_failed_constraints,
                 x_return_status            =>      l_return_status);

                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                      raise FND_API.G_EXC_UNEXPECTED_ERROR;
                   END IF;
                END IF;

                IF l_validate_mode_result = 'F' THEN
                   l_item_result := 'F';
                END IF;

             END IF;
            END IF; -- G_ASSIGN_TRIP

            IF (p_action_code = G_AUTOCRT_DLVY_TRIP OR  p_action_code = G_AUTOCRT_MDC) AND
             (p_entity_tab(k).ship_method_code IS NOT NULL OR
              p_entity_tab(k).carrier_id IS NOT NULL OR
              p_entity_tab(k).mode_of_transport IS NOT NULL) AND
            NOT l_failed_group.EXISTS(p_entity_tab(k).group_id) THEN

               check_act_positive (
                     p_comp_class_tab     => p_comp_class_tab,
                     p_item_id            => p_detail_tab(m).inventory_item_id,
                     p_item_org_id        => p_detail_tab(m).organization_id,
                     p_delivery_rec       => p_entity_tab(k),
                     x_failed_constraint  => x_failed_constraints,
                     x_validate_result    => l_acd_result,
                     x_return_status      => l_return_status);

               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                     raise FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
               END IF;

               IF l_acd_result = 'F' THEN
                  l_failed_group(p_entity_tab(k).group_id) := p_entity_tab(k).group_id;
                  p_group_tab(p_entity_tab(k).group_id).upd_dlvy_ship_method := 'N';
               END IF;

            END IF;

            <<detail_nextpass>>

            EXIT WHEN m= p_detail_tab.LAST;
            m:= p_detail_tab.NEXT(m);
           END LOOP;

          END IF;

           --IF l_validate_itmfac_result = 'F' OR l_item_result = 'F' THEN
          IF l_item_result = 'F' THEN
                p_entity_tab.DELETE(k);
                t := t+1;
                x_failed_lines(t).failed_line_index := t;
                x_failed_lines(t).entity_line_id := k;
                GOTO entity_nextpass;
          END IF;

                -- Populate x_line_groups table
          l_linegroup_indx := l_linegroup_indx + 1;
          x_line_groups(l_linegroup_indx).line_group_index := l_linegroup_indx;
          x_line_groups(l_linegroup_indx).entity_line_id   := p_entity_tab(k).entity_id;
          x_line_groups(l_linegroup_indx).line_group_id    := p_entity_tab(k).group_id;

          -- END IF;   -- It was here for null protection of above loop

          <<entity_nextpass>>
          --
          IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'p_entity_tab : FIRST -  '||p_entity_tab.FIRST||' NEXT - '||p_entity_tab.NEXT(k)||' LAST - '||p_entity_tab.LAST||' COUNT - '||p_entity_tab.COUNT);
          END IF;
          --

          -- Check whether NEXT works with DELETE
          EXIT WHEN ( k = p_entity_tab.LAST OR p_entity_tab.COUNT = 0 OR p_entity_tab.NEXT(k) IS NULL);
          k:= p_entity_tab.NEXT(k);
        END LOOP;
    END IF;

    --
    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --

EXCEPTION
    WHEN g_get_carrmode_failed THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,' get carrier-mode failed ');
      END IF;
      --
    WHEN g_get_vehicletype_failed THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,' get vehicletype failed ');
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
    WHEN others THEN
      WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.validate_positive_constraint');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --

END validate_positive_constraint;

--***************************************************************************--

--========================================================================
-- PROCEDURE : check_upd_dlvy             PRIVATE
--
-- PARAMETERS: p_delivery_rec             Input delivery record
--             p_detail_tab               Children detail records of input delivery record
--             p_comp_class_tab           Table of Compatibility class codes to check
--             x_failed_constraints       Failed constraint table
--             x_validate_result          Constraint Validation result : S / F
--             x_return_status            Return status
-- COMMENT   :
-- Applicable for Manual create / Update of a delivery
-- For a given delivery
-- determines if the delivery can be updated to have the input record structure
-- satisfying all constraints
--========================================================================

PROCEDURE check_upd_dlvy(
                 p_delivery_rec        IN delivery_ccinfo_rec_type,
                 p_detail_tab          IN detail_ccinfo_tab_type,
                 p_comp_class_tab      IN WSH_UTIL_CORE.Column_Tab_Type,
                 x_failed_constraints  IN OUT NOCOPY line_constraint_tab_type,
                 x_validate_result     OUT NOCOPY VARCHAR2,
                 x_return_status       OUT NOCOPY VARCHAR2)
IS

    j                           NUMBER := 0;
    l_carrier                   NUMBER := 0;
    l_mode                      VARCHAR2(30);
    l_service_level             VARCHAR2(30) := NULL;
    l_carrier_service_inout_rec WSH_CARRIERS_GRP.Carrier_Service_InOut_Rec_Type;
    l_return_status             VARCHAR2(1);
    l_validate_result           VARCHAR2(1);
    l_failed_constraint         line_constraint_rec_type;
    l_validate_faccar_result    VARCHAR2(1) := 'S';
    l_validate_facmod_result    VARCHAR2(1) := 'S';
    l_validate_itmcar_result    VARCHAR2(1) := 'S';
    l_validate_itmmod_result    VARCHAR2(1) := 'S';

    l_module_name               CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'check_upd_dlvy';
    l_debug_on                  CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
BEGIN

    x_validate_result := 'S';
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    IF l_debug_on THEN
       wsh_debug_sv.push(l_module_name);
    END IF;

    IF (p_delivery_rec.carrier_id IS NULL OR p_delivery_rec.MODE_OF_TRANSPORT IS NULL) AND
       (p_delivery_rec.ship_method_code IS NOT NULL) THEN

    l_carrier_service_inout_rec.ship_method_code := p_delivery_rec.ship_method_code;
    WSH_CARRIERS_GRP.get_carrier_service_mode(
             p_carrier_service_inout_rec   =>  l_carrier_service_inout_rec,
             x_return_status       =>  l_return_status);

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
       IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       raise g_get_carrmode_failed;
       END IF;
    END IF;
    l_carrier := l_carrier_service_inout_rec.carrier_id;
    l_mode    := l_carrier_service_inout_rec.mode_of_transport;

    END IF; -- p_delivery_rec.carrier_id IS NULL OR ..

    -- If carrier_id or mode is passed in, then those get preference for validation
    -- If they are not, they are derived from ship method if that is passed

    IF p_delivery_rec.carrier_id IS NOT NULL THEN
       l_carrier := p_delivery_rec.carrier_id;
    END IF;
    IF p_delivery_rec.mode_of_transport IS NOT NULL THEN
       l_mode := p_delivery_rec.mode_of_transport;
    END IF;

    -- Check delivery's stop locations for FAC - CAR/MOD

    IF p_comp_class_tab.EXISTS(G_FACILITY_CARRIER_NUM) AND
          l_carrier IS NOT NULL THEN

      validate_constraint(
             p_comp_class_code          =>      G_FACILITY_CARRIER,
             p_object1_type             =>      'FAC',
             p_object1_val_num          =>      p_delivery_rec.initial_pickup_location_id,
             p_object2_type             =>      'CAR',
             p_object2_val_num          =>      l_carrier,
             x_validate_result          =>      l_validate_faccar_result,
             x_failed_constraint        =>      l_failed_constraint,
             x_return_status            =>      l_return_status);

      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

      IF l_validate_faccar_result <> 'S' THEN
         l_failed_constraint.line_constraint_index := x_failed_constraints.COUNT+1;
         l_failed_constraint.entity_type :=  G_DELIVERY;
         l_failed_constraint.entity_line_id :=  p_delivery_rec.delivery_id;
         x_failed_constraints(x_failed_constraints.COUNT+1) := l_failed_constraint;

         IF l_validate_faccar_result = 'E' THEN
            x_validate_result := 'F';
            l_validate_result := 'F';
         END IF;
      END IF;
         -- Success can override Failure

      validate_constraint(
             p_comp_class_code          =>      G_FACILITY_CARRIER,
             p_object1_type             =>      'FAC',
             p_object1_val_num          =>      p_delivery_rec.ultimate_dropoff_location_id,
             p_object2_type             =>      'CAR',
             p_object2_val_num          =>      l_carrier,
             x_validate_result          =>      l_validate_faccar_result,
             x_failed_constraint        =>      l_failed_constraint,
             x_return_status            =>      l_return_status);

      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

      IF l_validate_faccar_result <> 'S' THEN
        l_failed_constraint.line_constraint_index := x_failed_constraints.COUNT+1;
        l_failed_constraint.entity_type :=  G_DELIVERY;
        l_failed_constraint.entity_line_id :=  p_delivery_rec.delivery_id;
        x_failed_constraints(x_failed_constraints.COUNT+1) := l_failed_constraint;

        IF l_validate_faccar_result = 'E' THEN
           x_validate_result := 'F';
         l_validate_result := 'F';
        END IF;
      END IF;

    END IF;

    IF p_comp_class_tab.EXISTS(G_FACILITY_MODE_NUM) AND
          l_mode IS NOT NULL THEN

      validate_constraint(
             p_comp_class_code          =>      G_FACILITY_MODE,
             p_object1_type             =>      'FAC',
             p_object1_val_num          =>      p_delivery_rec.initial_pickup_location_id,
             p_object2_type             =>      'MOD',
             p_object2_val_char         =>     l_mode ,
             x_validate_result          =>      l_validate_facmod_result,
             x_failed_constraint        =>      l_failed_constraint,
             x_return_status            =>      l_return_status);

      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

      IF l_validate_facmod_result <> 'S' THEN
        l_failed_constraint.line_constraint_index := x_failed_constraints.COUNT+1;
        l_failed_constraint.entity_type :=  G_DELIVERY;
        l_failed_constraint.entity_line_id :=  p_delivery_rec.delivery_id;
        x_failed_constraints(x_failed_constraints.COUNT+1) := l_failed_constraint;

        IF l_validate_facmod_result = 'E' THEN
         x_validate_result := 'F';
         l_validate_result := 'F';
        END IF;

      END IF;

      validate_constraint(
             p_comp_class_code          =>      G_FACILITY_MODE,
             p_object1_type             =>      'FAC',
             p_object1_val_num          =>      p_delivery_rec.ultimate_dropoff_location_id,
             p_object2_type             =>      'MOD',
             p_object2_val_char         =>     l_mode ,
             x_validate_result          =>      l_validate_facmod_result,
             x_failed_constraint        =>      l_failed_constraint,
             x_return_status            =>      l_return_status);

      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

      IF l_validate_facmod_result <> 'S' THEN
        l_failed_constraint.line_constraint_index := x_failed_constraints.COUNT+1;
        l_failed_constraint.entity_type :=  G_DELIVERY;
        l_failed_constraint.entity_line_id :=  p_delivery_rec.delivery_id;
        x_failed_constraints(x_failed_constraints.COUNT+1) := l_failed_constraint;

        IF l_validate_facmod_result = 'E' THEN
         x_validate_result := 'F';
         l_validate_result := 'F';
        END IF;
      END IF;

    END IF;

    -- Check delivery lines items for ITM - CAR/MOD

    IF l_carrier IS NOT NULL OR
       l_mode IS NOT NULL THEN

      --LOOP  -- Over children of the dleg
      j := p_detail_tab.FIRST;
      IF j IS NOT NULL THEN
        LOOP

           -- ITM - CAR/MOD for detail's item against dleg's carrier, mode

           IF p_comp_class_tab.EXISTS(G_ITEM_MODE_NUM) AND
              l_mode IS NOT NULL THEN

               validate_constraint(   --  checks only negative constraints
                 p_comp_class_code          =>      G_ITEM_MODE,
                 p_object1_type             =>      'ITM',
                 p_object1_parent_id        =>      p_detail_tab(j).organization_id,
                 p_object2_type             =>      'MOD',
                 p_object1_val_num          =>      p_detail_tab(j).inventory_item_id,
                 p_object2_val_char          =>     l_mode ,
                 x_validate_result          =>      l_validate_itmmod_result,
                 x_failed_constraint        =>      l_failed_constraint,  -- id
                 x_return_status            =>      l_return_status);

               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                     raise FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
               END IF;

               IF l_validate_itmmod_result <> 'S' THEN
                  l_failed_constraint.line_constraint_index := x_failed_constraints.COUNT+1;
                  l_failed_constraint.entity_type :=  G_DEL_DETAIL;
                  l_failed_constraint.entity_line_id :=  p_detail_tab(j).delivery_detail_id;
                  x_failed_constraints(x_failed_constraints.COUNT+1) := l_failed_constraint;

                  IF l_validate_itmmod_result = 'E' THEN
                   x_validate_result := 'F';
                   l_validate_result := 'F';
                  END IF;

               END IF;

           END IF;

           IF p_comp_class_tab.EXISTS(G_ITEM_CARRIER_NUM) AND
              l_carrier IS NOT NULL THEN

               validate_constraint(   --  checks only negative constraints
                 p_comp_class_code          =>      G_ITEM_CARRIER,
                 p_object1_type             =>      'ITM',
                 p_object1_parent_id        =>      p_detail_tab(j).organization_id,
                 p_object2_type             =>      'CAR',
                 p_object1_val_num          =>      p_detail_tab(j).inventory_item_id,
                 p_object2_val_num          =>      l_carrier,
                 x_validate_result          =>      l_validate_itmcar_result,
                 x_failed_constraint        =>      l_failed_constraint,  -- id
                 x_return_status            =>      l_return_status);

               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                     raise FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
               END IF;

               IF l_validate_itmcar_result <> 'S' THEN
                  l_failed_constraint.line_constraint_index := x_failed_constraints.COUNT+1;
                  l_failed_constraint.entity_type :=  G_DEL_DETAIL;
                  l_failed_constraint.entity_line_id :=  p_detail_tab(j).delivery_detail_id;
                  x_failed_constraints(x_failed_constraints.COUNT+1) := l_failed_constraint;

                  IF l_validate_itmcar_result = 'E' THEN
                   x_validate_result := 'F';
                   l_validate_result := 'F';
                  END IF;

               END IF;

           END IF;

           EXIT WHEN j = p_detail_tab.LAST;
           j := p_detail_tab.NEXT(j);

        END LOOP;
      END IF;

    END IF; -- not null

    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --

EXCEPTION
    WHEN g_get_carrmode_failed THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,' get carrier-mode failed ');
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
    WHEN others THEN
      WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.check_upd_dlvy');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --

END check_upd_dlvy;

--========================================================================
-- PROCEDURE : validate_constraint_dlvy    Called by constraint Wrapper API
--                                         and the Group API.
--
-- PARAMETERS: p_init_msg_list             FND_API.G_TRUE to reset list
--             p_action_code               Predefined action code
--             p_exception_list            Compatibility classes to skip if any
--                                         indexed by class code numbers
--             p_in_ids                    Table of delivery ids to process
--                                         Either of the next two should be passed
--             p_delivery_info             Table of delivery records to process
--                                         Only one of p_in_ids and p_delivery_info should be passed
--             p_dlvy_assigned_lines       Table of assigned delivery details of
--                                         input deliveries. Pass if queried information available
--                                         If not passed, the API will query
--             p_target_trip               Applicable for Assign delivery to Trip only
--                                         Record of target trip information
--             p_target_tripstops          Input pickup and dropoff stop/location of the delivery(s)
--                                         in that target trip
--             p_target_trip_assign_dels   Table of deliveries in target trip
--                                         If not passed, the API will query
--             p_target_trip_dlvy_lines    Table of delivery details in target trip
--                                         If not passed, the API will query
--             p_target_trip_incl_stops    Table of tripstops already in the target trip_
--                                         If not passed, the API will query
--             x_validate_result           Constraint Validation result : S / F
--             x_line_groups               Includes Successful and warning lines
--                                         after constraint check
--                                         Contains information of which input delivery should
--                                         be grouped in which output group for trip creation
--             x_group_info                Output groups for input deliveries
--             x_failed_lines              Table of input delivery lines that failed
--                                         constraint check
--             x_msg_count                 Number of messages in the list
--             x_msg_data                  Text of messages
--             x_return_status             Return status
-- COMMENT   : This procedure is used to perform for following actions
--             Can be called for
--             A. Autocreate Trip (ACT)
--             B. Assign Delivery to Trip (ADT)
--             C. Update a delivery (UPD)
--             D. Manually create a delivery (CRD)
--             When specifying a target trip, group all deliveries that are being planned
--             to the target trip
--========================================================================

PROCEDURE validate_constraint_dlvy(
             p_init_msg_list            IN            VARCHAR2 DEFAULT fnd_api.g_false,
             p_action_code              IN            VARCHAR2 DEFAULT NULL,
             p_exception_list           IN            WSH_UTIL_CORE.Column_Tab_Type,
             p_in_ids                   IN            WSH_UTIL_CORE.id_tab_type,
             p_delivery_info            IN            delivery_ccinfo_tab_type,
             p_dlvy_assigned_lines      IN            detail_ccinfo_tab_type,
             p_target_trip              IN            trip_ccinfo_rec_type,
             p_target_tripstops         IN OUT NOCOPY target_tripstop_cc_rec_type,
             p_target_trip_assign_dels  IN            delivery_ccinfo_tab_type,
             p_target_trip_dlvy_lines   IN            detail_ccinfo_tab_type,
             p_target_trip_incl_stops   IN            stop_ccinfo_tab_type,
             x_validate_result          OUT NOCOPY    VARCHAR2,
             x_line_groups              OUT NOCOPY    WSH_FTE_COMP_CONSTRAINT_PKG.line_group_tab_type,
             x_group_info               OUT NOCOPY    WSH_FTE_COMP_CONSTRAINT_PKG.cc_group_tab_type,
             x_failed_lines             OUT NOCOPY    WSH_FTE_COMP_CONSTRAINT_PKG.failed_line_tab_type,
             x_msg_count                OUT NOCOPY    NUMBER,
             x_msg_data                 OUT NOCOPY    VARCHAR2,
             x_return_status            OUT NOCOPY    VARCHAR2)
IS

    CURSOR c_gettripdetails (l_tripid IN NUMBER) is
    SELECT TRIP_ID, 'Y'as EXISTS_IN_DATABASE, NAME, PLANNED_FLAG, STATUS_CODE, VEHICLE_ITEM_ID, VEHICLE_NUMBER,
    CARRIER_ID, SHIP_METHOD_CODE, VEHICLE_ORGANIZATION_ID, VEHICLE_NUM_PREFIX, SERVICE_LEVEL,
    MODE_OF_TRANSPORT
    FROM wsh_trips where trip_id=l_tripid;

    cursor c_gettrip(l_deliveryid IN NUMBER) is
    select wts.TRIP_ID
    from wsh_trip_stops wts, wsh_delivery_legs wdl
    where wdl.delivery_id =l_deliveryid AND
    wdl.pick_up_stop_id = wts.stop_id;

    k                            NUMBER:=0;
    l                            NUMBER:=0;
    i                            NUMBER:=0;
    j                            NUMBER:=0;
    l_end_count                  NUMBER:= 0;
    l_start_count                NUMBER:= 0;
    l_trip_del_cnt               NUMBER:=0;
    l_trip_detail_cnt            NUMBER:=0;
    l_trip_stops_cnt             NUMBER:=0;
    l_group_id                   NUMBER:=0;
    l_failed_lc                  NUMBER:=0;
    l_linegroup_indx             NUMBER:=0;
    l_return_status              VARCHAR2(1);
    l_validate_result            VARCHAR2(1);
    l_comp_class_tab             WSH_UTIL_CORE.column_tab_type;
    l_entity_tab                 entity_tab_type;
    l_group_tab                  entity_group_tab_type;
    l_group_tab1                 WSH_FTE_COMP_CONSTRAINT_PKG.cc_group_tab_type;
    l_found                      BOOLEAN := FALSE;
    l_failed_constraints         line_constraint_tab_type;
    l_failed_constraint          line_constraint_rec_type;
    l_delivery_rec               delivery_ccinfo_rec_type;
    l_detail_rec                 detail_ccinfo_rec_type;
    l_stop_rec                   stop_ccinfo_rec_type;
    l_delivery_info              delivery_ccinfo_tab_type;
    l_dlvy_assigned_lines        detail_ccinfo_tab_type;
    l_target_trip                trip_ccinfo_rec_type;
    l_target_trip_assign_dels    delivery_ccinfo_tab_type;
    l_target_trip_dlvy_lines     detail_ccinfo_tab_type;
    l_target_trip_incl_stops     stop_ccinfo_tab_type;
    l_detail_tab                 WSH_UTIL_CORE.id_tab_type;
    l_delivery_tab               WSH_UTIL_CORE.id_tab_type;
    l_exists_tab                 WSH_UTIL_CORE.column_tab_type;
    l_customer_tab               WSH_UTIL_CORE.id_tab_type;
    l_item_tab                   WSH_UTIL_CORE.id_tab_type;
    l_shipfrom_loc_tab           WSH_UTIL_CORE.id_tab_type;
    l_org_tab                    WSH_UTIL_CORE.id_tab_type;
    l_shipto_loc_tab             WSH_UTIL_CORE.id_tab_type;
    l_intmed_shipto_loc_tab      WSH_UTIL_CORE.id_tab_type;
    l_rel_stat_tab               WSH_UTIL_CORE.column_tab_type;
    l_cont_flag_tab              WSH_UTIL_CORE.column_tab_type;
    l_date_req_tab               WSH_UTIL_CORE.Date_Tab_Type;
    l_date_sch_tab               WSH_UTIL_CORE.Date_Tab_Type;
    l_carrier_tab                WSH_UTIL_CORE.id_tab_type;
    l_shipmethod_tab             WSH_UTIL_CORE.column_tab_type;
    l_party_tab                  WSH_UTIL_CORE.id_tab_type;
    l_line_direction_tab         WSH_UTIL_CORE.column_tab_type;
    l_shipping_control_tab       WSH_UTIL_CORE.column_tab_type;
    l_supp_control_tab           WSH_UTIL_CORE.id_tab_type;
    --DUM_COMP
    l_dum_tab			 WSH_UTIL_CORE.id_tab_type;
    --DUM_COMP
    --SBAKSHI (8/24)
    l_target_trip_incl_sort_stops stop_ccinfo_tab_type;
    --SBAKSHI (8/24)

    l_group_count                NUMBER:=0;
    l_carrier                    NUMBER := NULL;
    l_vehicle_type               NUMBER := NULL;
    l_mode                       VARCHAR2(30) := NULL;
    l_service_level              VARCHAR2(30) := NULL;
    l_carrier_service_inout_rec  WSH_CARRIERS_GRP.Carrier_Service_InOut_Rec_Type;
    l_location_id                NUMBER := NULL;
    l_validate_carrier_result    VARCHAR2(1) := 'S';
    l_validate_vehicle_result    VARCHAR2(1) := 'S';
    l_validate_mode_result       VARCHAR2(1) := 'S';
    l_dummy_failed_lines         WSH_FTE_COMP_CONSTRAINT_PKG.failed_line_tab_type;
    l_dummy_failed_lc            NUMBER:=0;
    l_upd_delivery_rec           delivery_ccinfo_rec_type;
    g_invalid_action_code        EXCEPTION;
    l_vehicle_name               VARCHAR2(2000);
    l_vehicle_org_name           VARCHAR2(240);

    l_module_name                CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'validate_constraint_dlvy';
    l_debug_on                   CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;

    --#DUM_LOC(S)
    l_physical_location_id	 NUMBER;
    --#DUM_LOC(E)
    l_delivery_info_mod NUMBER ; --Bug 9222910


BEGIN

    x_validate_result := 'S';
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    g_itm_mustuse_cache.DELETE;
    g_itmloc_mustuse_cache.DELETE;
    g_itm_exclusive_cache.DELETE;
    g_fac_exclusive_cache.DELETE;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
    END IF;

    IF l_debug_on THEN
       wsh_debug_sv.push(l_module_name);
       WSH_DEBUG_SV.logmsg(l_module_name,'p_init_msg_list : '||p_init_msg_list);
    END IF;

    -- Action codes : ACT, ADT, UPD, CRD

    IF p_action_code NOT IN (G_AUTOCRT_DLVY_TRIP,G_ASSIGN_DLVY_TRIP,G_UPDATE_DLVY,G_CREATE_DLVY,G_AUTOCRT_MDC) OR
          p_action_code IS NULL THEN
          RAISE g_invalid_action_code;
    END IF;

    IF p_action_code IN (G_UPDATE_DLVY,G_CREATE_DLVY) AND p_delivery_info.COUNT = 0 THEN
           RAISE g_invalid_action_code;
    END IF;

    refresh_cache(l_return_status);

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
    END IF;

    -- Assumes p_comp_class_tab and p_exception_list are indexed by
    -- compatibility class codes

    IF NOT p_exception_list.EXISTS(G_FACILITY_MODE_NUM) THEN
      l_comp_class_tab(G_FACILITY_MODE_NUM) := G_FACILITY_MODE;
    END IF;
    IF NOT p_exception_list.EXISTS(G_FACILITY_CARRIER_NUM) THEN
      l_comp_class_tab(G_FACILITY_CARRIER_NUM) := G_FACILITY_CARRIER;
    END IF;
    IF NOT p_exception_list.EXISTS(G_FACILITY_VEHICLE_NUM) THEN
      l_comp_class_tab(G_FACILITY_VEHICLE_NUM) := G_FACILITY_VEHICLE;
    END IF;
    IF NOT p_exception_list.EXISTS(G_ITEM_MODE_NUM) THEN
      l_comp_class_tab(G_ITEM_MODE_NUM) := G_ITEM_MODE;
    END IF;
    IF NOT p_exception_list.EXISTS(G_ITEM_CARRIER_NUM) THEN
      l_comp_class_tab(G_ITEM_CARRIER_NUM) := G_ITEM_CARRIER;
    END IF;
    IF NOT p_exception_list.EXISTS(G_ITEM_VEHICLE_NUM) THEN
      l_comp_class_tab(G_ITEM_VEHICLE_NUM) := G_ITEM_VEHICLE;
    END IF;
    IF NOT p_exception_list.EXISTS(G_SHIPORG_FACILITY_NUM) THEN
       l_comp_class_tab(G_SHIPORG_FACILITY_NUM) := G_SHIPORG_FACILITY;
    END IF;
    IF NOT p_exception_list.EXISTS(G_CUSTOMER_FACILITY_NUM) THEN
       l_comp_class_tab(G_CUSTOMER_FACILITY_NUM) := G_CUSTOMER_FACILITY;
    END IF;
    IF NOT p_exception_list.EXISTS(G_SUPPLIER_FACILITY_NUM) THEN
       l_comp_class_tab(G_SUPPLIER_FACILITY_NUM) := G_SUPPLIER_FACILITY;
    END IF;
    IF NOT p_exception_list.EXISTS(G_ITEM_FACILITY_NUM) THEN
       l_comp_class_tab(G_ITEM_FACILITY_NUM) := G_ITEM_FACILITY;
    END IF;
    IF NOT p_exception_list.EXISTS(G_CUSTOMER_CUSTOMER_NUM) THEN
       l_comp_class_tab(G_CUSTOMER_CUSTOMER_NUM) := G_CUSTOMER_CUSTOMER;
    END IF;

    -- Assign delivery details to delivery
    -- does not update any grouping attributes for the delivery AS 10/18
    -- Populate l_delivery_info

    IF p_delivery_info.COUNT = 0 THEN
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'p_in_ids passed count : '||p_in_ids.COUNT);
      END IF;
      --
      i := p_in_ids.FIRST;

      IF i IS NOT NULL THEN
      LOOP

         -- c_get_dlvy is a global cursor.
	 -- We are fetching entire information for a particluar record.

	    OPEN  c_get_dlvy(p_in_ids(i));
          FETCH c_get_dlvy into l_delivery_info(i);
        CLOSE c_get_dlvy;

	 --#DUM_LOC(S)
	 -- Delivery's ultimate_dropoff_location_id to be converted to physical internal
	 -- location if it is a dummy location.
	 -- We have to use the API for this purpose.

	 WSH_LOCATIONS_PKG.CONVERT_INTERNAL_CUST_LOCATION(
             p_internal_cust_location_id  => l_delivery_info(i).ultimate_dropoff_location_id,
             x_internal_org_location_id   => l_physical_location_id,
             x_return_status              => l_return_status);

	 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
	       raise FND_API.G_EXC_UNEXPECTED_ERROR;
	    END IF;
  	 END IF;

	 --physical location id is not null implies- A dummy location.
	 IF (l_physical_location_id IS NOT NULL) THEN
  	      --
	      IF l_debug_on THEN
		  WSH_DEBUG_SV.logmsg(l_module_name,'Location '||l_delivery_info(i).ultimate_dropoff_location_id||' is a dummy location');
	      END IF;
	      --
	      l_delivery_info(i).ultimate_dropoff_location_id := l_physical_location_id;
              -- AGDUMMY TODO populate physical_dropoff_location_id
              l_delivery_info(i).physical_dropoff_location_id := l_physical_location_id;
	 END IF;
         --#DUM_LOC(E)

         OPEN c_gettrip(p_in_ids(i));
         FETCH c_gettrip into l_delivery_info(i).TRIP_ID;
         CLOSE c_gettrip;

  	      --
	      IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'l_delivery_info(i).initial_pickup_location_id : '||l_delivery_info(i).initial_pickup_location_id);
       WSH_DEBUG_SV.logmsg(l_module_name,'l_delivery_info(i).ultimate_dropoff_location_id : '||l_delivery_info(i).ultimate_dropoff_location_id);
	      END IF;
	      --
         EXIT WHEN i = p_in_ids.LAST;
         i := p_in_ids.NEXT(i);

      END LOOP;
      END IF;

    ELSE
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'p_delivery_info passed count : '||p_delivery_info.COUNT);
      END IF;
      --

      i := p_delivery_info.FIRST;
      IF i IS NOT NULL THEN
       LOOP
       --{
        IF ( p_delivery_info(i).INITIAL_PICKUP_LOCATION_ID IS NULL OR
           p_delivery_info(i).ULTIMATE_DROPOFF_LOCATION_ID IS NULL OR
           p_delivery_info(i).CUSTOMER_ID IS NULL OR
           p_delivery_info(i).ORGANIZATION_ID IS NULL OR
           p_delivery_info(i).PARTY_ID IS NULL OR
           p_delivery_info(i).SHIPMENT_DIRECTION IS NULL OR
           p_delivery_info(i).SHIPPING_CONTROL IS NULL ) AND
           p_action_code = G_UPDATE_DLVY THEN

           -- l_upd_delivery_rec may have a dummy location,
           -- Changing l_delivery_info,ultimate dropoff location id handles this case.

	       OPEN c_get_dlvy(p_delivery_info(i).DELIVERY_ID);
             FETCH c_get_dlvy INTO l_upd_delivery_rec;
           CLOSE c_get_dlvy;

        END IF;

	    l_delivery_info(i).DELIVERY_ID                       := p_delivery_info(i).DELIVERY_ID;
        l_delivery_info(i).TRIP_ID                           := p_delivery_info(i).TRIP_ID;
        l_delivery_info(i).EXISTS_IN_DATABASE                := p_delivery_info(i).EXISTS_IN_DATABASE;
        l_delivery_info(i).NAME                              := p_delivery_info(i).NAME;
        l_delivery_info(i).PLANNED_FLAG                      := p_delivery_info(i).PLANNED_FLAG;
        l_delivery_info(i).STATUS_CODE                       := p_delivery_info(i).STATUS_CODE;
        l_delivery_info(i).INITIAL_PICKUP_DATE               := p_delivery_info(i).INITIAL_PICKUP_DATE;
        l_delivery_info(i).INITIAL_PICKUP_LOCATION_ID        := nvl(p_delivery_info(i).INITIAL_PICKUP_LOCATION_ID,l_upd_delivery_rec.INITIAL_PICKUP_LOCATION_ID);
        l_delivery_info(i).ULTIMATE_DROPOFF_LOCATION_ID      := nvl(p_delivery_info(i).ULTIMATE_DROPOFF_LOCATION_ID,l_upd_delivery_rec.ULTIMATE_DROPOFF_LOCATION_ID);
        l_delivery_info(i).ULTIMATE_DROPOFF_DATE             := p_delivery_info(i).ULTIMATE_DROPOFF_DATE;
        l_delivery_info(i).CUSTOMER_ID                       := nvl(p_delivery_info(i).CUSTOMER_ID,l_upd_delivery_rec.CUSTOMER_ID);
        l_delivery_info(i).INTMED_SHIP_TO_LOCATION_ID        := p_delivery_info(i).INTMED_SHIP_TO_LOCATION_ID;
        l_delivery_info(i).SHIP_METHOD_CODE                  := p_delivery_info(i).SHIP_METHOD_CODE;
        l_delivery_info(i).DELIVERY_TYPE                     := p_delivery_info(i).DELIVERY_TYPE;
        l_delivery_info(i).CARRIER_ID                        := p_delivery_info(i).CARRIER_ID;
        l_delivery_info(i).ORGANIZATION_ID                   := nvl(p_delivery_info(i).ORGANIZATION_ID,l_upd_delivery_rec.ORGANIZATION_ID);
        l_delivery_info(i).SERVICE_LEVEL                     := p_delivery_info(i).SERVICE_LEVEL;
        l_delivery_info(i).MODE_OF_TRANSPORT                 := p_delivery_info(i).MODE_OF_TRANSPORT;
        l_delivery_info(i).PARTY_ID                          := nvl(p_delivery_info(i).PARTY_ID,l_upd_delivery_rec.PARTY_ID);
        l_delivery_info(i).SHIPMENT_DIRECTION                := nvl(nvl(p_delivery_info(i).SHIPMENT_DIRECTION,l_upd_delivery_rec.SHIPMENT_DIRECTION),'O');
        l_delivery_info(i).SHIPPING_CONTROL                  := nvl(nvl(p_delivery_info(i).SHIPPING_CONTROL,l_upd_delivery_rec.SHIPPING_CONTROL),'BUYER');

  	      --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'p_delivery_info(i).initial_pickup_location_id : '||p_delivery_info(i).initial_pickup_location_id);
            WSH_DEBUG_SV.logmsg(l_module_name,'p_delivery_info(i).ultimate_dropoff_location_id : '||p_delivery_info(i).ultimate_dropoff_location_id);
            WSH_DEBUG_SV.logmsg(l_module_name,'l_delivery_info(i).initial_pickup_location_id : '||l_delivery_info(i).initial_pickup_location_id);
            WSH_DEBUG_SV.logmsg(l_module_name,'l_delivery_info(i).ultimate_dropoff_location_id : '||l_delivery_info(i).ultimate_dropoff_location_id);
        END IF;
	      --
         --#DUM_LOC(S)
	    WSH_LOCATIONS_PKG.CONVERT_INTERNAL_CUST_LOCATION(
             p_internal_cust_location_id  => l_delivery_info(i).ultimate_dropoff_location_id,
             x_internal_org_location_id   => l_physical_location_id,
             x_return_status              => l_return_status);

	  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
	       raise FND_API.G_EXC_UNEXPECTED_ERROR;
	    END IF;
  	  END IF;

	  IF (l_physical_location_id IS NOT NULL) THEN
  	      --
	      IF l_debug_on THEN
		  WSH_DEBUG_SV.logmsg(l_module_name,'Location '||l_delivery_info(i).ultimate_dropoff_location_id||' is a dummy location');
	      END IF;
	      --
	      l_delivery_info(i).ultimate_dropoff_location_id := l_physical_location_id;
              -- AGDUMMY TODO
          l_delivery_info(i).physical_dropoff_location_id := l_physical_location_id;
  	  END IF;
          --#DUM_LOC(E)

        EXIT WHEN i = p_delivery_info.LAST;
        i := p_delivery_info.NEXT(i);
       --}
       END LOOP;
      END IF;
    END IF;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'l_delivery_info created : '||l_delivery_info.COUNT);
    END IF;
    --

    IF p_dlvy_assigned_lines.COUNT = 0 THEN

      l_end_count := 0;
      l_start_count := 0;
      i := l_delivery_info.FIRST;
      IF i IS NOT NULL THEN
      LOOP
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'l_delivery_info : delivery id : '||l_delivery_info(i).delivery_id||' exists in db :'||l_delivery_info(i).exists_in_database);
      END IF;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'l_delivery_info(i).delivery_type : '||l_delivery_info(i).delivery_type);
        --l_delivery_info(i).delivery_type := 'STANDARD';
        --WSH_DEBUG_SV.logmsg(l_module_name,'l_delivery_info(i).delivery_type : '||l_delivery_info(i).delivery_type);
      END IF;
      --
      -- G_CREATE_DLVY should have 'N'
      IF l_delivery_info(i).exists_in_database = 'Y' THEN  -- Assigned lines have not been passed
      l_start_count := l_end_count + 1;

      IF l_delivery_info(i).delivery_type = 'STANDARD' THEN
          OPEN c_get_details(l_delivery_info(i).delivery_id);
          FETCH c_get_details BULK COLLECT INTO
                l_detail_tab,l_delivery_tab,l_exists_tab,l_customer_tab,l_item_tab,l_shipfrom_loc_tab,
                l_org_tab,l_shipto_loc_tab,l_intmed_shipto_loc_tab,
                l_rel_stat_tab,l_cont_flag_tab,l_date_req_tab,l_date_sch_tab,
                l_shipmethod_tab,l_carrier_tab,l_party_tab,l_line_direction_tab
               ,l_shipping_control_tab,l_dum_tab;
          --DUM_COMPILE (NULL)
          CLOSE c_get_details;
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'after c_get_details: '||l_detail_tab.COUNT);
          END IF;
       ELSE
          OPEN c_get_details_consol(l_delivery_info(i).delivery_id);
          FETCH c_get_details_consol BULK COLLECT INTO
                l_detail_tab,l_delivery_tab,l_exists_tab,l_customer_tab,l_item_tab,l_shipfrom_loc_tab,
                l_org_tab,l_shipto_loc_tab,l_intmed_shipto_loc_tab,
                l_rel_stat_tab,l_cont_flag_tab,l_date_req_tab,l_date_sch_tab,
                l_shipmethod_tab,l_carrier_tab,l_party_tab,l_line_direction_tab
               ,l_shipping_control_tab,l_dum_tab;
          --DUM_COMPILE (NULL)
          CLOSE c_get_details_consol;
       END IF;


      END IF;

      IF l_detail_tab.COUNT > 0 THEN
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'l_detail_tab.COUNT : '||l_detail_tab.COUNT);
         END IF;
         l_end_count := l_end_count + l_detail_tab.COUNT;
         k := 0;

	 FOR j IN l_start_count .. l_end_count LOOP

	   k := k+1;
           l_dlvy_assigned_lines(j).delivery_detail_id := l_detail_tab(k);
           l_dlvy_assigned_lines(j).delivery_id := l_delivery_tab(k);
           l_dlvy_assigned_lines(j).exists_in_database := 'Y';
           l_dlvy_assigned_lines(j).CUSTOMER_ID := l_customer_tab(k);
           l_dlvy_assigned_lines(j).INVENTORY_ITEM_ID := l_item_tab(k);
           l_dlvy_assigned_lines(j).SHIP_FROM_LOCATION_ID := l_shipfrom_loc_tab(k);
           l_dlvy_assigned_lines(j).ORGANIZATION_ID := l_org_tab(k);
           l_dlvy_assigned_lines(j).SHIP_TO_LOCATION_ID := l_shipto_loc_tab(k);
           l_dlvy_assigned_lines(j).INTMED_SHIP_TO_LOCATION_ID := l_intmed_shipto_loc_tab(k);
           l_dlvy_assigned_lines(j).RELEASED_STATUS := l_rel_stat_tab(k);
           l_dlvy_assigned_lines(j).CONTAINER_FLAG := l_cont_flag_tab(k);
           l_dlvy_assigned_lines(j).DATE_REQUESTED  := l_date_req_tab(k);
           l_dlvy_assigned_lines(j).DATE_SCHEDULED := l_date_sch_tab(k);
           l_dlvy_assigned_lines(j).SHIP_METHOD_CODE := l_shipmethod_tab(k);
           l_dlvy_assigned_lines(j).CARRIER_ID := l_carrier_tab(k);
           l_dlvy_assigned_lines(j).PARTY_ID := l_party_tab(k);
           l_dlvy_assigned_lines(j).LINE_DIRECTION := l_line_direction_tab(k);
           l_dlvy_assigned_lines(j).SHIPPING_CONTROL := l_shipping_control_tab(k);


	   --#DUM_LOC(S)
	   -- Delivery detail's Dummy ship_to_location_id has to be converted to physical internal
	   -- location

	   WSH_LOCATIONS_PKG.CONVERT_INTERNAL_CUST_LOCATION(
	      p_internal_cust_location_id  => l_dlvy_assigned_lines(j).ship_to_location_id,
              x_internal_org_location_id   => l_physical_location_id,
              x_return_status              => l_return_status);

 	   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	     IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
	        raise FND_API.G_EXC_UNEXPECTED_ERROR;
	     END IF;
    	   END IF;

  	   IF (l_physical_location_id IS NOT NULL) THEN
  	      --
	      IF l_debug_on THEN
		  WSH_DEBUG_SV.logmsg(l_module_name,'Location '||l_dlvy_assigned_lines(j).ship_to_location_id||' is a dummy location');
	      END IF;
	      --
	      l_dlvy_assigned_lines(j).ship_to_location_id:= l_physical_location_id;
              -- AGDUMMY TODO
              l_dlvy_assigned_lines(j).physical_ship_to_location_id := l_physical_location_id;
	   END IF;
           --#DUM_LOC(E)

	END LOOP;
      END IF;

      EXIT WHEN i=l_delivery_info.LAST;
      i := l_delivery_info.NEXT(i);
      END LOOP;
      END IF;
    ELSE

      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'p_dlvy_assigned_lines passed : '||p_dlvy_assigned_lines.COUNT);
      END IF;
      --
      i := p_dlvy_assigned_lines.FIRST;
      IF i IS NOT NULL THEN
       LOOP

             l_dlvy_assigned_lines(i).delivery_detail_id := p_dlvy_assigned_lines(i).delivery_detail_id;
             l_dlvy_assigned_lines(i).delivery_id := p_dlvy_assigned_lines(i).delivery_id;
             l_dlvy_assigned_lines(i).exists_in_database := p_dlvy_assigned_lines(i).exists_in_database;
             l_dlvy_assigned_lines(i).CUSTOMER_ID := p_dlvy_assigned_lines(i).CUSTOMER_ID;
             l_dlvy_assigned_lines(i).INVENTORY_ITEM_ID := p_dlvy_assigned_lines(i).INVENTORY_ITEM_ID;
             l_dlvy_assigned_lines(i).SHIP_FROM_LOCATION_ID := p_dlvy_assigned_lines(i).SHIP_FROM_LOCATION_ID;
             l_dlvy_assigned_lines(i).ORGANIZATION_ID := p_dlvy_assigned_lines(i).ORGANIZATION_ID;
             l_dlvy_assigned_lines(i).SHIP_TO_LOCATION_ID := p_dlvy_assigned_lines(i).SHIP_TO_LOCATION_ID;
             l_dlvy_assigned_lines(i).INTMED_SHIP_TO_LOCATION_ID := p_dlvy_assigned_lines(i).INTMED_SHIP_TO_LOCATION_ID;
             l_dlvy_assigned_lines(i).RELEASED_STATUS := p_dlvy_assigned_lines(i).RELEASED_STATUS;
             l_dlvy_assigned_lines(i).CONTAINER_FLAG := p_dlvy_assigned_lines(i).CONTAINER_FLAG;
             l_dlvy_assigned_lines(i).DATE_REQUESTED  := p_dlvy_assigned_lines(i).DATE_REQUESTED;
             l_dlvy_assigned_lines(i).DATE_SCHEDULED := p_dlvy_assigned_lines(i).DATE_SCHEDULED;
             l_dlvy_assigned_lines(i).SHIP_METHOD_CODE := p_dlvy_assigned_lines(i).SHIP_METHOD_CODE;
             l_dlvy_assigned_lines(i).CARRIER_ID := p_dlvy_assigned_lines(i).CARRIER_ID;
             l_dlvy_assigned_lines(i).party_id := p_dlvy_assigned_lines(i).party_id;
             l_dlvy_assigned_lines(i).line_direction := p_dlvy_assigned_lines(i).line_direction;
             l_dlvy_assigned_lines(i).shipping_control := nvl(p_dlvy_assigned_lines(i).shipping_control,'BUYER');

	     --#DUM_LOC(S)
	     WSH_LOCATIONS_PKG.CONVERT_INTERNAL_CUST_LOCATION(
		 p_internal_cust_location_id  => l_dlvy_assigned_lines(i).ship_to_location_id,
                 x_internal_org_location_id   => l_physical_location_id,
                 x_return_status              => l_return_status);

	     IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
	          raise FND_API.G_EXC_UNEXPECTED_ERROR;
	       END IF;
    	 END IF;

 	     IF (l_physical_location_id IS NOT NULL) THEN
  	        --
	        IF l_debug_on THEN
		        WSH_DEBUG_SV.logmsg(l_module_name,'Location '||l_dlvy_assigned_lines(i).ship_to_location_id||' is a dummy location');
   	        END IF;
	        --
	        l_dlvy_assigned_lines(i).ship_to_location_id:= l_physical_location_id;
                -- AGDUMMY TODO
            l_dlvy_assigned_lines(i).physical_ship_to_location_id := l_physical_location_id;
  	     END IF;
             --#DUM_LOC(E)

	 EXIT WHEN i = p_dlvy_assigned_lines.LAST;
         i := p_dlvy_assigned_lines.NEXT(i);
         END LOOP;
      END IF;
    END IF;

    IF p_action_code = G_ASSIGN_DLVY_TRIP THEN

     IF p_target_trip.trip_id IS NOT NULL  THEN
                                                        --  has been passed
       IF p_target_trip_assign_dels.COUNT = 0 THEN
          OPEN c_get_trip_dlvy(p_target_trip.trip_id); -- or container_id
          LOOP
               FETCH c_get_trip_dlvy INTO l_delivery_rec;
      	       EXIT WHEN c_get_trip_dlvy%NOTFOUND;

	       --#DUM_LOC(S)
	        WSH_LOCATIONS_PKG.CONVERT_INTERNAL_CUST_LOCATION(
		        p_internal_cust_location_id  => l_delivery_rec.ultimate_dropoff_location_id,
	            x_internal_org_location_id   => l_physical_location_id,
                x_return_status              => l_return_status);

	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
  		        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
		            raise FND_API.G_EXC_UNEXPECTED_ERROR;
	            END IF;
	       END IF;

	       IF (l_physical_location_id IS NOT NULL) THEN
  	         --
	         IF l_debug_on THEN
		        WSH_DEBUG_SV.logmsg(l_module_name,'Location '||l_delivery_rec.ultimate_dropoff_location_id||' is a dummy location');
	         END IF;
	         --
	         l_delivery_rec.ultimate_dropoff_location_id := l_physical_location_id;
                 -- AGDUMMY TODO
             l_delivery_rec.physical_dropoff_location_id := l_physical_location_id;
	       END IF;
               --#DUM_LOC(E)

	       l_trip_del_cnt := l_trip_del_cnt + 1;
               l_target_trip_assign_dels(l_trip_del_cnt) := l_delivery_rec;
           END LOOP;
           CLOSE c_get_trip_dlvy;
       ELSE
       l := p_target_trip_assign_dels.FIRST;
       LOOP
           l_target_trip_assign_dels(l) := p_target_trip_assign_dels(l);
           -- AGDUMMY

	   --#DUM_LOC(S)
	    WSH_LOCATIONS_PKG.CONVERT_INTERNAL_CUST_LOCATION(
		p_internal_cust_location_id  => l_target_trip_assign_dels(l).ultimate_dropoff_location_id,
	        x_internal_org_location_id   => l_physical_location_id,
                x_return_status              => l_return_status);

	   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
  	      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
		  raise FND_API.G_EXC_UNEXPECTED_ERROR;
	      END IF;
	   END IF;

	   IF (l_physical_location_id IS NOT NULL) THEN
  	      --
	      IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Location '||l_target_trip_assign_dels(l).ultimate_dropoff_location_id||' is a dummy location');
	      END IF;
	      --
	      l_target_trip_assign_dels(l).ultimate_dropoff_location_id := l_physical_location_id;
              -- AGDUMMY TODO
              l_target_trip_assign_dels(l).physical_dropoff_location_id := l_physical_location_id;
	   END IF;
           --#DUM_LOC(E)

	   EXIT WHEN l = p_target_trip_assign_dels.LAST;
           l := p_target_trip_assign_dels.NEXT(l);
       END LOOP;
       END IF;

       IF p_target_trip_dlvy_lines.COUNT = 0  THEN --AND p_action_code <> G_ASSIGN_DLVY_TRIP
          IF p_action_code = G_ASSIGN_DLVY_TRIP THEN
              OPEN c_get_trip_details_std(p_target_trip.trip_id); -- or container_id
              LOOP
                   FETCH c_get_trip_details_std INTO l_detail_rec;
                   EXIT WHEN c_get_trip_details_std%NOTFOUND;

               --#DUM_LOC(S)
                   WSH_LOCATIONS_PKG.CONVERT_INTERNAL_CUST_LOCATION(
                   p_internal_cust_location_id  => l_detail_rec.ship_to_location_id,
                   x_internal_org_location_id   => l_physical_location_id,
                   x_return_status              => l_return_status);

                   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                            raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                   END IF;

               IF (l_physical_location_id IS NOT NULL) THEN
                 --
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Location '||l_detail_rec.ship_to_location_id||' is a dummy location');
                 END IF;
                 --
                 l_detail_rec.ship_to_location_id:= l_physical_location_id;
                     -- AGDUMMY TODO
                 l_detail_rec.physical_ship_to_location_id := l_physical_location_id;
               END IF;
                   --#DUM_LOC(E)

               l_trip_detail_cnt := l_trip_detail_cnt + 1;
               l_target_trip_dlvy_lines(l_trip_detail_cnt) := l_detail_rec;
              END LOOP;
              CLOSE c_get_trip_details_std;
         ELSE
            OPEN c_get_trip_details(p_target_trip.trip_id); -- or container_id
              LOOP
                   FETCH c_get_trip_details INTO l_detail_rec;
                   EXIT WHEN c_get_trip_details%NOTFOUND;

               --#DUM_LOC(S)
                   WSH_LOCATIONS_PKG.CONVERT_INTERNAL_CUST_LOCATION(
                   p_internal_cust_location_id  => l_detail_rec.ship_to_location_id,
                   x_internal_org_location_id   => l_physical_location_id,
                   x_return_status              => l_return_status);

                   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                            raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                   END IF;

               IF (l_physical_location_id IS NOT NULL) THEN
                 --
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Location '||l_detail_rec.ship_to_location_id||' is a dummy location');
                 END IF;
                 --
                 l_detail_rec.ship_to_location_id:= l_physical_location_id;
                     -- AGDUMMY TODO
                 l_detail_rec.physical_ship_to_location_id := l_physical_location_id;
               END IF;
                   --#DUM_LOC(E)

               l_trip_detail_cnt := l_trip_detail_cnt + 1;
               l_target_trip_dlvy_lines(l_trip_detail_cnt) := l_detail_rec;
              END LOOP;
              CLOSE c_get_trip_details;
         END IF;
       ELSE
        l := p_target_trip_dlvy_lines.FIRST;
       LOOP
           l_target_trip_dlvy_lines(l) := p_target_trip_dlvy_lines(l);

	   --#DUM_LOC(S)
	   WSH_LOCATIONS_PKG.CONVERT_INTERNAL_CUST_LOCATION(
	      p_internal_cust_location_id  => l_target_trip_dlvy_lines(l).ship_to_location_id,
              x_internal_org_location_id   => l_physical_location_id,
              x_return_status              => l_return_status);

 	   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	     IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
	        raise FND_API.G_EXC_UNEXPECTED_ERROR;
	     END IF;
    	   END IF;

  	   IF (l_physical_location_id IS NOT NULL) THEN
  	      --
	      IF l_debug_on THEN
		  WSH_DEBUG_SV.logmsg(l_module_name,'Location '||l_target_trip_dlvy_lines(l).ship_to_location_id||' is a dummy location');
	      END IF;
	      --
	      l_target_trip_dlvy_lines(l).ship_to_location_id:= l_physical_location_id;
              -- AGDUMMY TODO
              l_target_trip_dlvy_lines(l).physical_ship_to_location_id := l_physical_location_id;
	   END IF;
           --#DUM_LOC(E)

	   EXIT WHEN l = p_target_trip_dlvy_lines.LAST;
	   l := p_target_trip_dlvy_lines.NEXT(l);
        END LOOP;
       END IF;

       IF p_target_trip_incl_stops.COUNT = 0 THEN
          OPEN c_get_trip_stops(p_target_trip.trip_id); -- or container_id
          LOOP
               --#DUM_LOC(S)
	       --Made changes in the cursor only.
	       --#DUM_LOC(E)
	       FETCH c_get_trip_stops INTO l_stop_rec;
               EXIT WHEN c_get_trip_stops%NOTFOUND;
	       l_trip_stops_cnt := l_trip_stops_cnt + 1;
               l_target_trip_incl_stops(l_trip_stops_cnt) := l_stop_rec;
          END LOOP;
          CLOSE c_get_trip_stops;
       ELSE

	/* SBAKSHI 8/24
	   We should have p_target_trip_incl_stops sorted by planned arrival date
	   p_target_trip_incl_stops is IN RECORD record
	   Need to make a local record structure, for this purpose.
	   l_target_sort_trip_incl_stops
	*/

   	   sort_stop_table_asc(
		 p_stop_table	   => p_target_trip_incl_stops,
		 x_sort_stop_table => l_target_trip_incl_sort_stops,
		 x_return_status   => l_return_status);


 	   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	     IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
	        raise FND_API.G_EXC_UNEXPECTED_ERROR;
	     END IF;
      END IF;

	 -- l := p_target_trip_incl_stops.FIRST;

	   l := l_target_trip_incl_sort_stops.FIRST;

	   LOOP
           --l_target_trip_incl_stops(l) := p_target_trip_incl_stops(l);
	     l_target_trip_incl_stops(l) := l_target_trip_incl_sort_stops(l);

	   -- AGDUMMY
           -- Use physical_location_id from the record structure instead
           -- Also sort the input p_target_trip_incl_stops by planned_arrival_date
           -- One trip can have more than one set of dummy-physical stop pairs - wrudge 8/20
	   --#DUM_LOC(S) (Using the record structure)

	   IF (l_target_trip_incl_stops(l).physical_location_id IS NOT NULL) THEN
	       --
	       IF l_debug_on THEN
		   WSH_DEBUG_SV.logmsg(l_module_name,'Location '||l_target_trip_incl_stops(l).stop_location_id||' is a dummy location');
	       END IF;
	       --
	       l_target_trip_incl_stops(l).stop_location_id:=l_target_trip_incl_stops(l).physical_location_id;
	   END IF;
	   --#DUM_LOC(E)

	   --  EXIT WHEN l = p_target_trip_incl_stops.LAST;
           --  l := p_target_trip_incl_stops.NEXT(l);

	   EXIT WHEN l = l_target_trip_incl_sort_stops.LAST;
	   l := l_target_trip_incl_sort_stops.NEXT(l);

 	   -- SBAKSHI 8/24
	   END LOOP;

       END IF;

       OPEN c_gettripdetails(p_target_trip.trip_id);
       FETCH c_gettripdetails into l_target_trip;
       CLOSE c_gettripdetails;
     END IF;

     -- AGDUMMY
     -- Convert the PICKUP and DROPOFF for p_target_tripstops

     -- #DUM_LOC(S)
     -- p_target_tripstops.PICKUP_LOCATION_ID

     WSH_LOCATIONS_PKG.CONVERT_INTERNAL_CUST_LOCATION(
	 p_internal_cust_location_id  => p_target_tripstops.pickup_location_id,
        x_internal_org_location_id   => l_physical_location_id,
        x_return_status              => l_return_status);

     IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
           raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
     END IF;

     IF (l_physical_location_id IS NOT NULL) THEN
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Location '||p_target_tripstops.pickup_location_id||' is a dummy location');
        END IF;
	--
	    p_target_tripstops.pickup_location_id:=l_physical_location_id;
     END IF;

     --	p_target_tripstops.DROPOFF_LOCATION_ID

     WSH_LOCATIONS_PKG.CONVERT_INTERNAL_CUST_LOCATION(
	    p_internal_cust_location_id  => p_target_tripstops.dropoff_location_id,
        x_internal_org_location_id   => l_physical_location_id,
        x_return_status              => l_return_status);

     IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
           raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
     END IF;

     IF (l_physical_location_id IS NOT NULL) THEN
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Location '||p_target_tripstops.dropoff_location_id||' is a dummy location');
        END IF;
	--
	    p_target_tripstops.dropoff_location_id:=l_physical_location_id;
     END IF;
     --#DUM_LOC(E)

     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'p_target_tripstops.PICKUP_STOP_ID '||p_target_tripstops.PICKUP_STOP_ID);
        WSH_DEBUG_SV.logmsg(l_module_name,'p_target_tripstops.PICKUP_STOP_SEQ '||p_target_tripstops.PICKUP_STOP_SEQ);
        WSH_DEBUG_SV.logmsg(l_module_name,'p_target_tripstops.DROPOFF_STOP_ID '||p_target_tripstops.DROPOFF_STOP_ID);
        WSH_DEBUG_SV.logmsg(l_module_name,'p_target_tripstops.DROPOFF_STOP_SEQ '||p_target_tripstops.DROPOFF_STOP_SEQ);
        WSH_DEBUG_SV.logmsg(l_module_name,'p_target_tripstops.PICKUP_LOCATION_ID '||p_target_tripstops.PICKUP_LOCATION_ID);
        WSH_DEBUG_SV.logmsg(l_module_name,'p_target_tripstops.DROPOFF_LOCATION_ID '||p_target_tripstops.DROPOFF_LOCATION_ID);
     END IF;
     --
    END IF; -- G_ASSIGN_DLVY_TRIP
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'After populating table structures for action code '||p_action_code);
    END IF;
    --

    -- Populate assigned details
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'After populating l_comp_class_tab count : '||l_comp_class_tab.COUNT);
    END IF;
    --

    /*
    Auto create trip for delivery 	ACT	COM_FAC CUS_FAC CUS_CUS ITM_FAC ITM_ITM

    Assign deliveries to trip	        ADT	COM_FAC CUS_FAC CUS_CUS ITM_FAC ITM_ITM
                                                FAC_MOD FAC_VEH FAC_CAR ITM_MOD ITM_CAR ITM_VEH

    Update (delivery, delivery leg)	UPD 	(Mode -FAC_MOD, ITM_MOD Carrier - ITM_CAR,FAC_CAR
    */

     -- Assumptions :
     -- 1. When you are here and have a delivery that means
     --    within a delivery, all attributes are valid
     -- When assigning deliveries to a trip
     -- 1. It creates trips for deliveries which do not have a trip at that point
     -- 2. If the deliveries under creation all have same ship method, it defaults that to the trip
     -- 3. Creates stops only for initial pickup and ultimate droppff, ignores intermediate
     -- 4. When creating trip stops creates sequence numbers arbitrarily
     --    ascending (eg. 10, 20, 30 etc.) as it finds new locations from the
     --    list of delivery
     -- 5. Assign to trip can pass a delivery and a target trip and
     --    override pickup stop and dropoff stop of those of the delivery
     -- 6. All validations on trip stops are based on stop sequence number and
     --    not stop dates

     -- Record types : Child, entity, group
     -- Child : child id, entity id
     -- Entity : entity id, pickup, dropoff, org, customer, group id
     -- Group : Group id
     -- Here entity : Delivery
     -- For every delivery : search existing groups if can be added
     -- If not, create a new group else add to the matching group and proceed
     -- search routine should take entity record as well as children table


      -- This loop checks only itm-itm and cus-cus for every delivery
      -- against every other delivery
      -- also itm-fac with pickup / dropoff locations of other delivery
      -- also com-fac, cus-fac with pickup / dropoff locations of other delivery

      -- Following done for ACT and ADT
      -- Valid groups created looking at only Exclusive constraints

     --
     --DUM_LOC We have modified record p_target_tripstops to store physical locations
     --in case of dummy locations.

    IF p_action_code = G_ASSIGN_DLVY_TRIP AND
       ( p_target_tripstops.pickup_location_id IS NOT NULL OR
         p_target_tripstops.dropoff_location_id IS NOT NULL ) THEN

    IF (l_target_trip.carrier_id IS NULL OR l_target_trip.MODE_OF_TRANSPORT IS NULL) AND
         (l_target_trip.ship_method_code IS NOT NULL) THEN

      l_carrier_service_inout_rec.ship_method_code := l_target_trip.ship_method_code;
      WSH_CARRIERS_GRP.get_carrier_service_mode(
               p_carrier_service_inout_rec   =>  l_carrier_service_inout_rec,
               x_return_status		     =>  l_return_status);

      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
         IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
         raise g_get_carrmode_failed;
        END IF;
      END IF;
      l_carrier := l_carrier_service_inout_rec.carrier_id;
      l_mode    := l_carrier_service_inout_rec.mode_of_transport;

    END IF; -- l_target_trip.carrier_id IS NULL OR ..
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'target trip carrier : '||l_target_trip.carrier_id||' Mode : '||l_target_trip.mode_of_transport||' ship method : '||l_target_trip.ship_method_code);
    END IF;

      -- If carrier_id or mode is passed in, then those get preference for validation
      -- If they are not, they are derived from ship method if that is passed

    IF l_target_trip.carrier_id IS NOT NULL THEN
       l_carrier := l_target_trip.carrier_id;
    END IF;
    IF l_target_trip.mode_of_transport IS NOT NULL THEN
       l_mode := l_target_trip.mode_of_transport;
    END IF;

    IF (l_target_trip.VEHICLE_ITEM_ID IS NOT NULL AND l_target_trip.VEHICLE_ORGANIZATION_ID IS NOT NULL) THEN

      WSH_FTE_INTEGRATION.get_vehicle_type(
               p_vehicle_item_id     =>  l_target_trip.VEHICLE_ITEM_ID,
               p_vehicle_org_id      =>  l_target_trip.VEHICLE_ORGANIZATION_ID,
               x_vehicle_type_id     =>  l_vehicle_type,
               x_return_status       =>  l_return_status);

      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
         IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
            l_vehicle_name := WSH_UTIL_CORE.get_item_name (p_item_id => l_target_trip.VEHICLE_ITEM_ID,
                                                           p_organization_id => l_target_trip.VEHICLE_ORGANIZATION_ID);
            l_vehicle_org_name := WSH_UTIL_CORE.get_org_name (p_organization_id => l_target_trip.VEHICLE_ORGANIZATION_ID);
            FND_MESSAGE.SET_NAME('WSH','WSH_VEHICLE_TYPE_UNDEFINED');
            FND_MESSAGE.SET_TOKEN('ITEM',l_vehicle_name);
            FND_MESSAGE.SET_TOKEN('ORGANIZATION',l_vehicle_org_name);
            FND_MSG_PUB.ADD;
            --raise g_get_vehicletype_failed;
         END IF;
      END IF;

    END IF; -- l_target_trip.VEHICLE_ITEM_ID IS NOT NULL AND ..

    FOR i IN 1..2 LOOP

        -- Do the checks in calling procedure if pickup/dropoff stop/location ids have been passed

        IF i = 1 THEN
           IF p_target_tripstops.pickup_location_id IS NOT NULL AND
              p_target_tripstops.pickup_stop_id IS NULL THEN
                l_location_id := p_target_tripstops.pickup_location_id;
                IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'target pickup location id not null');
                END IF;
           -- ELSIF p_target_tripstops.pickup_stop_id IS NOT NULL THEN
           -- If the pickupstop does not already exist in the target trip
           -- check here, if already exists then do not check
           -- not possible, p_target_tripstops.pickup_stop_id IS NOT NULL
           -- implies it already exists in the target trip
           ELSE
              -- Nothing to check
                GOTO next_pass;
           END IF;
        ELSIF i = 2 THEN
           IF p_target_tripstops.dropoff_location_id IS NOT NULL AND
              p_target_tripstops.dropoff_stop_id IS NULL THEN
                l_location_id := p_target_tripstops.dropoff_location_id;
                IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'target dropoff location id not null');
                END IF;
           ELSE
              -- Nothing to check
                GOTO next_pass;
           END IF;
        END IF;
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'i : '||i||' l_location_id : '||l_location_id);
        END IF;
        --

        IF l_comp_class_tab.EXISTS(G_FACILITY_VEHICLE_NUM) AND
            l_vehicle_type IS NOT NULL THEN

            validate_constraint(
             p_comp_class_code          =>      G_FACILITY_VEHICLE,
             p_object1_type             =>      'FAC',
             p_object1_val_num          =>      l_location_id,
             p_object2_type             =>      'VHT',
             p_object2_val_num          =>      l_vehicle_type,
             x_validate_result          =>      l_validate_vehicle_result,
             x_failed_constraint        =>      l_failed_constraint,
             x_return_status            =>      l_return_status);

            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                  raise FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            END IF;

            IF l_validate_vehicle_result <> 'S' THEN
              l_failed_constraint.line_constraint_index := l_failed_constraints.COUNT+1;
              l_failed_constraint.entity_type := G_LOCATION;
              l_failed_constraint.entity_line_id := l_location_id;
              l_failed_constraints(l_failed_constraints.COUNT+1) := l_failed_constraint;
              IF l_validate_vehicle_result = 'E' THEN
               x_validate_result := 'F';
              END IF;
            END IF;

        END IF;

        IF l_comp_class_tab.EXISTS(G_FACILITY_CARRIER_NUM) AND
            l_carrier IS NOT NULL THEN

            validate_constraint(
             p_comp_class_code          =>      G_FACILITY_CARRIER,
             p_object1_type             =>      'FAC',
             p_object1_val_num          =>      l_location_id,
             p_object2_type             =>      'CAR',
             p_object2_val_num          =>      l_carrier,
             x_validate_result          =>      l_validate_carrier_result,
             x_failed_constraint        =>      l_failed_constraint,
             x_return_status            =>      l_return_status);

            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                  raise FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            END IF;

            IF l_validate_carrier_result <> 'S' THEN
              l_failed_constraint.line_constraint_index := l_failed_constraints.COUNT+1;
              l_failed_constraint.entity_type := G_LOCATION;
              l_failed_constraint.entity_line_id := l_location_id;
              l_failed_constraints(l_failed_constraints.COUNT+1) := l_failed_constraint;
              IF l_validate_carrier_result = 'E' THEN
               x_validate_result := 'F';
              END IF;
            END IF;

        END IF;

        IF l_comp_class_tab.EXISTS(G_FACILITY_MODE_NUM) AND
            l_mode IS NOT NULL THEN

            validate_constraint(
             p_comp_class_code          =>      G_FACILITY_MODE,
             p_object1_type             =>      'FAC',
             p_object1_val_num          =>      l_location_id,
             p_object2_type             =>      'MOD',
             p_object2_val_char          =>     l_mode,
             x_validate_result          =>      l_validate_mode_result,
             x_failed_constraint        =>      l_failed_constraint,
             x_return_status            =>      l_return_status);

            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                  raise FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            END IF;

            IF l_validate_mode_result <> 'S' THEN
              l_failed_constraint.line_constraint_index := l_failed_constraints.COUNT+1;
              l_failed_constraint.entity_type := G_LOCATION;
              l_failed_constraint.entity_line_id := l_location_id;
              l_failed_constraints(l_failed_constraints.COUNT+1) := l_failed_constraint;
              IF l_validate_mode_result = 'E' THEN
               x_validate_result := 'F';
              END IF;
            END IF;

        END IF;

    <<next_pass>>
    null;

    END LOOP;

    END IF;

    k := l_delivery_info.FIRST;
    IF k IS NOT NULL THEN
      LOOP

        -- Skip if shipping control is SUPPLIER
        --Bug 9222910   replaced  l_delivery_info(k).delivery_id with l_delivery_info_mod  ,  WSH_UTIL_CORE.C_INDEX_LIMIT value is 2147483648; -- power(2,31)
        l_delivery_info_mod := MOD(l_delivery_info(k).delivery_id , WSH_UTIL_CORE.C_INDEX_LIMIT) ;

        IF l_delivery_info(k).shipping_control = 'SUPPLIER' THEN

            l_supp_control_tab(l_delivery_info_mod) := l_delivery_info(k).delivery_id;
            GOTO next_delivery;

        END IF;

        l_group_id         :=0;
        l_found            := FALSE;


        IF p_action_code IN (G_AUTOCRT_DLVY_TRIP,G_ASSIGN_DLVY_TRIP, G_AUTOCRT_MDC) THEN

         l_entity_tab(l_delivery_info_mod).entity_id := l_delivery_info(k).delivery_id;
         l_entity_tab(l_delivery_info_mod).organization_id := l_delivery_info(k).organization_id;
         l_entity_tab(l_delivery_info_mod).initial_pickup_location_id := l_delivery_info(k).initial_pickup_location_id;
         l_entity_tab(l_delivery_info_mod).ultimate_dropoff_location_id := l_delivery_info(k).ultimate_dropoff_location_id;
         l_entity_tab(l_delivery_info_mod).initial_pickup_date := l_delivery_info(k).initial_pickup_date;
         l_entity_tab(l_delivery_info_mod).ultimate_dropoff_date := l_delivery_info(k).ultimate_dropoff_date;
         l_entity_tab(l_delivery_info_mod).physical_dropoff_location_id := l_delivery_info(k).physical_dropoff_location_id;
         l_entity_tab(l_delivery_info_mod).intmed_ship_to_location_id := l_delivery_info(k).intmed_ship_to_location_id;
         l_entity_tab(l_delivery_info_mod).ship_method_code := l_delivery_info(k).ship_method_code;
         l_entity_tab(l_delivery_info_mod).carrier_id := l_delivery_info(k).carrier_id;
         l_entity_tab(l_delivery_info_mod).mode_of_transport := l_delivery_info(k).mode_of_transport;
         l_entity_tab(l_delivery_info_mod).customer_id := l_delivery_info(k).customer_id;
         l_entity_tab(l_delivery_info_mod).party_id := l_delivery_info(k).party_id;
         l_entity_tab(l_delivery_info_mod).shipment_direction := l_delivery_info(k).shipment_direction;
         l_entity_tab(l_delivery_info_mod).shipping_control := l_delivery_info(k).shipping_control;
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Created l_entity_tab with index : '||l_delivery_info_mod||' for delivery index '||k);
       WSH_DEBUG_SV.logmsg(l_module_name,'l_entity_tab(l_delivery_info_mod).entity_id : '||l_entity_tab(l_delivery_info_mod).entity_id);
       WSH_DEBUG_SV.logmsg(l_module_name,'l_entity_tab(l_delivery_info_mod).initial_pickup_location_id : '||l_entity_tab(l_delivery_info_mod).initial_pickup_location_id);
       WSH_DEBUG_SV.logmsg(l_module_name,'l_entity_tab(l_delivery_info_mod).ultimate_dropoff_location_id : '||l_entity_tab(l_delivery_info_mod).ultimate_dropoff_location_id);
       WSH_DEBUG_SV.logmsg(l_module_name,'l_delivery_info(k).initial_pickup_location_id : '||l_delivery_info(k).initial_pickup_location_id);
       WSH_DEBUG_SV.logmsg(l_module_name,'l_delivery_info(k).ultimate_dropoff_location_id : '||l_delivery_info(k).ultimate_dropoff_location_id);
         END IF;
         --

         IF k <> l_delivery_info.FIRST THEN

            search_matching_group(
                  p_entity_type           => 'DLVY',
                  p_action_code           => p_action_code,
                  p_children_info         => l_dlvy_assigned_lines,
                  p_comp_class_tab        => l_comp_class_tab,
                  p_target_stops_info     => p_target_tripstops,
                  p_entity_rec            => l_entity_tab(l_delivery_info_mod),  --Bug 9222910
                  p_target_trip_id        => l_target_trip.trip_id,
                  p_entity_tab            => l_entity_tab,
                  p_group_tab             => x_group_info,
                  x_failed_constraints    => l_failed_constraints,
                  x_group_id              => l_group_id,
                  x_found                 => l_found,
                  x_return_status         => l_return_status);
            --
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Called search_matching_group return status : '||l_return_status||' Group found ? '||l_group_id);
            END IF;
            --

            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                  raise FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            END IF;

         END IF;

         IF l_found THEN
              l_entity_tab(l_delivery_info_mod).group_id := l_group_id; --Bug 9222910
         ELSE

              create_valid_entity_group(
                  p_entity_rec            => l_entity_tab(l_delivery_info_mod),  --Bug 9222910
                  p_group_tab             => x_group_info,
                  x_return_status         => l_return_status);
              --
              IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Called create_valid_entity_group return status : '||l_return_status);
              END IF;
              --

              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                     raise FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
              END IF;

         END IF;

      -- Following done only for ADT
         IF p_action_code = G_ASSIGN_DLVY_TRIP THEN

         -- Here check the delivery against target trip for exclusive constraints
         -- com -fac, cus - fac, itm - fac for each delivery against trip stops
         -- itm -mod, itm - car and fac-mod, fac-car
         -- org - car, org - mode will not be stored in constraints table 11/6
         -- itm - itm, cus - cus
         -- Any delivery that is violating, remove from the group

            check_dlvy_against_trip(
                 p_entity_type         => 'DLVY',
                 p_delivery_rec        => l_delivery_info(k),
                 p_entity_id           => l_delivery_info(k).delivery_id,
                 p_detail_tab          => l_dlvy_assigned_lines,
                 p_comp_class_tab      => l_comp_class_tab,
                 p_target_stops_info   => p_target_tripstops,
                 p_target_trip         => l_target_trip,
                 p_target_tripstops    => l_target_trip_incl_stops,
                 p_target_dlvy         => l_target_trip_assign_dels,
                 p_target_dlvy_lines   => l_target_trip_dlvy_lines,
                 x_failed_constraints  => l_failed_constraints,
                 x_validate_result     => l_validate_result,
                 x_return_status       => l_return_status);
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Called check_dlvy_against_trip return status : '||l_return_status||' validate result : '||l_validate_result);
            END IF;
            --

            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                   raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
            END IF;

            IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_SUCCESS,WSH_UTIL_CORE.G_RET_STS_WARNING)
               THEN
               IF l_validate_result = 'F' THEN
                  -- Remove delivery from the line group
                  -- add to the failed lines
                  l_failed_lc := l_failed_lc + 1;
                  l_entity_tab.DELETE(l_delivery_info_mod); --Bug 9222910
                  x_failed_lines(l_failed_lc).entity_line_id := l_delivery_info(k).delivery_id;
                  x_failed_lines(l_failed_lc).failed_line_index := l_failed_lc;

               END IF;

            END IF;

         END IF; -- ADT

         l_dummy_failed_lc := l_dummy_failed_lc + 1;
         l_dummy_failed_lines(l_dummy_failed_lc).entity_line_id := l_delivery_info(k).delivery_id;
         l_dummy_failed_lines(l_dummy_failed_lc).failed_line_index := l_dummy_failed_lc;

         -- Populate x_line_groups table if l_entity_tab(l_delivery_info_mod) exists
         -- Best place to populate x_line_groups is in
         -- validate_positive_constraint as that has the latest l_entity_tab

        END IF; -- ADT ACT

        IF p_action_code IN (G_UPDATE_DLVY,G_CREATE_DLVY) THEN

         -- Need to skip an Inbound delivery
         -- if the trip's status is "In Transit" or "Closed"

         IF l_delivery_info(k).status_code IN ('IT','CL') AND
               l_delivery_info(k).shipment_direction = 'I' THEN
               GOTO next_delivery;
         END IF;

         check_upd_dlvy(
                 p_delivery_rec        => l_delivery_info(k),
                 p_detail_tab          => l_dlvy_assigned_lines,
                 p_comp_class_tab      => l_comp_class_tab,
                 x_failed_constraints  => l_failed_constraints,
                 x_validate_result     => l_validate_result,
                 x_return_status       => l_return_status);
         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Called check_upd_dlvy return status : '||l_return_status||' validate result : '||l_validate_result);
         END IF;
         --

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN

               raise FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;

         IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_SUCCESS,WSH_UTIL_CORE.G_RET_STS_WARNING) THEN

            IF l_validate_result = 'F' THEN
               -- Remove delivery from the line group
               -- add to the failed lines
               l_failed_lc := l_failed_lc + 1;
               x_failed_lines(l_failed_lc).entity_line_id := l_delivery_info(k).delivery_id;
               x_failed_lines(l_failed_lc).failed_line_index := l_failed_lc;

               --
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Adding failed delivery : '||l_delivery_info(k).delivery_id);
               END IF;
               --

            ELSE

               -- Populate x_line_groups table
               l_linegroup_indx := l_linegroup_indx + 1;
               x_line_groups(l_linegroup_indx).line_group_index := l_linegroup_indx;
               x_line_groups(l_linegroup_indx).entity_line_id   := l_delivery_info(k).delivery_id;

               --
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Adding to linegroup delivery : '||l_delivery_info(k).delivery_id);
               END IF;
               --

            END IF;

         END IF;


        END IF;

        <<next_delivery>>

        EXIT WHEN k = l_delivery_info.LAST;
        k := l_delivery_info.NEXT(k);

      END LOOP;
    END IF;

    IF p_action_code IN (G_AUTOCRT_DLVY_TRIP,G_ASSIGN_DLVY_TRIP, G_AUTOCRT_MDC) AND
        (l_supp_control_tab.COUNT <> l_delivery_info.COUNT) THEN
      -- For each group / target trip
      -- find out list of stops to be created
      -- validate org - fac, cus - fac, itm -fac for must be constraints for each delivery
      -- shipmethod for the trip is populated only if all deliveries have same
      -- hence no need to validate fac - car fac - mode, itm - car, itm - mode for ACT
      -- For ADT : for each delivery validate these against those of the trip

      -- If ACT
      -- For each group created,
      -- check for violating group elements
      -- considering only positive constraints
      -- Remove group elements (deliveries) that are violating
      -- Handle more than one facilities (item also here or at dlvb ?) in same trip (group)
      -- having different must be carrier / mode
      -- : Put them in separate groups

      -- If ADT
      -- For each group created, check against target trip
      -- for positive constraints
      -- Remove violating group elements (deliveries) from the group


      validate_positive_constraint(
                    p_action_code         => p_action_code,
                    p_comp_class_tab      => l_comp_class_tab,
                    p_entity_tab          => l_entity_tab,
                    p_group_tab           => x_group_info,
                    p_detail_tab          => l_dlvy_assigned_lines,
                    p_target_trip         => l_target_trip,
                    p_target_tripstops    => l_target_trip_incl_stops,
                    p_target_stops_info   => p_target_tripstops,
                    x_line_groups         => x_line_groups,
                    x_failed_lines        => x_failed_lines,
                    x_failed_constraints  => l_failed_constraints,
                    x_return_status       => l_return_status);
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Called validate_positive_constraint return status : '||l_return_status);
      END IF;
      --

      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

    END IF; -- ACT ADT

    IF l_supp_control_tab.COUNT > 0 THEN

        -- Populate line_groups and group
        -- Add to x_group_info
        l_group_count := x_group_info.COUNT + 1;
        x_group_info(l_group_count).group_index := l_group_count;
        x_group_info(l_group_count).line_group_id := l_group_count;

        i := l_supp_control_tab.FIRST;
        LOOP

           -- Populate x_line_groups table
           l_linegroup_indx := x_line_groups.COUNT + 1;
           x_line_groups(l_linegroup_indx).line_group_index := l_linegroup_indx;
           x_line_groups(l_linegroup_indx).entity_line_id   := l_supp_control_tab(i);
           x_line_groups(l_linegroup_indx).line_group_id    := l_group_count;

           EXIT WHEN i=l_supp_control_tab.LAST;
           i := l_supp_control_tab.NEXT(i);
        END LOOP;

    END IF;

    IF x_validate_result = 'F' THEN  -- Means for G_ASSIGN_DLVY_TRIP
    /*
    IF l_validate_vehicle_result = 'E' OR l_validate_mode_result = 'E' OR
       l_validate_carrier_result = 'E' THEN  -- Means for G_ASSIGN_DLVY_TRIP
    */
                                             -- one or more of the input locations have failed
        IF x_failed_lines.COUNT > 0 THEN
           x_failed_lines.DELETE;
        END IF;
        -- Need to populate all input lines into x_failed_lines
        i := l_dummy_failed_lines.FIRST;
        LOOP

           x_failed_lines(i) := l_dummy_failed_lines(i);

           EXIT WHEN i=l_dummy_failed_lines.LAST;
           i := l_dummy_failed_lines.NEXT(i);
        END LOOP;

        -- delete entries from x_group_info and x_line_groups
        --x_group_info.DELETE;
        --x_line_groups.DELETE;
    ELSIF x_group_info.COUNT > 1 OR x_failed_lines.COUNT > 0 THEN  -- Supplier controlled can be 2
        x_validate_result := 'F';
        IF x_group_info.COUNT > 1 AND p_action_code = G_ASSIGN_DLVY_TRIP THEN
           -- Put all input lines in incompatible groups into failed lines

           -- After changing the logic to form groups in case of
           -- assign, the following list of groups will only contain
           -- mutually incompatible groups
           -- not the always successful groups
           i := x_group_info.FIRST;
           LOOP

             -- Will not delete these lines from linegroups
             -- Hence for this case the sum of failed lines and
             -- lines in linegroups will exceed number of input lines
             -- by these lines in linegroups
             -- Will not delete these incompatible groups
             j := x_line_groups.FIRST;
             LOOP

                IF x_line_groups(j).line_group_id <> x_group_info(i).line_group_id THEN
                   GOTO next_linegroup;
                END IF;

                -- Add to failed lines
                l_failed_lc := x_failed_lines.COUNT + 1;
                x_failed_lines(l_failed_lc).entity_line_id := x_line_groups(j).entity_line_id;
                x_failed_lines(l_failed_lc).failed_line_index := l_failed_lc;


                <<next_linegroup>>

                EXIT WHEN j=x_line_groups.LAST;
                j := x_line_groups.NEXT(j);
             END LOOP;

             EXIT WHEN i=x_group_info.LAST;
             i := x_group_info.NEXT(i);
           END LOOP;
        END IF;
    END IF;

    IF x_failed_lines.COUNT = 0 AND (p_action_code = G_AUTOCRT_DLVY_TRIP OR p_action_code = G_AUTOCRT_MDC) THEN
        l_failed_constraints.DELETE;
    END IF;

    --  Loop over l_failed_constraints to add to the mesage stack

    stack_messages (
             p_failed_constraints       => l_failed_constraints,
             x_msg_count                => x_msg_count,
             x_msg_data                 => x_msg_data,
             x_return_status            => l_return_status);
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Called stack_messages return status : '||l_return_status);
    END IF;
    --

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
    END IF;

    -- Now can get x_validate_result = 'F' with x_group_info.COUNT = 1 and
    -- x_failed_lines.COUNT = 0 in case of assign delivery to trip
    -- Means there is violation for input pickup/dropoff stop/location

    IF x_validate_result = 'F' THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

    ELSIF l_failed_constraints.COUNT > 0 THEN

        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
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
      WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.validate_constraint_dlvy');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --

END validate_constraint_dlvy;

--***************************************************************************--

--========================================================================
-- PROCEDURE : validate_constraint_dleg    Called by constraint Wrapper API
--                                         and the Lane search API.
--
-- PARAMETERS: p_init_msg_list             FND_API.G_TRUE to reset list
--             p_action_code               Predefined action code
--             p_exception_list            Compatibility classes to skip if any
--                                         indexed by class code numbers
--             p_delivery_leg_rec          Input delivery leg record
--             p_target_trip               Table of target trips for delivery leg trip search
--             p_target_lane               Table of target lane for delivery leg lane search
--             x_succ_trips                List of input trips that passed constraint check
--             x_succ_lanes                List of input lanes that passed constraint check
--             x_validate_result           Constraint Validation result : S / F
--             x_msg_count                 Number of messages in the list
--             x_msg_data                  Text of messages
--             x_return_status             Return status
-- COMMENT   : This procedure is used to perform for following actions
--             A. Lane search for delivery leg (DLS)
--========================================================================

PROCEDURE validate_constraint_dleg(
             p_init_msg_list            IN      VARCHAR2 DEFAULT fnd_api.g_false,
             p_action_code              IN      VARCHAR2 DEFAULT NULL,
             p_exception_list           IN      WSH_UTIL_CORE.Column_Tab_Type,
             p_delivery_leg_rec         IN      dleg_ccinfo_rec_type,
             p_target_trip              IN      trip_ccinfo_tab_type,
             p_target_lane              IN      lane_ccinfo_tab_type,
             x_succ_trips               OUT NOCOPY  WSH_UTIL_CORE.id_tab_type,
             x_succ_lanes               OUT NOCOPY  WSH_UTIL_CORE.id_tab_type,
             x_validate_result          OUT NOCOPY  VARCHAR2,
             x_msg_count                OUT NOCOPY  NUMBER,
             x_msg_data                 OUT NOCOPY  VARCHAR2,
             x_return_status            OUT NOCOPY  VARCHAR2)

IS

    cursor get_num_child_dlegs(p_delivery_leg_id IN NUMBER) IS
    SELECT
        count(*)
    FROM wsh_delivery_legs
    WHERE parent_delivery_leg_id = p_delivery_leg_id;

    l_orig_dlvy_puloc           NUMBER:=0;
    l_orig_dlvy_udloc           NUMBER:=0;
    l_intmed_leg                BOOLEAN:=FALSE;
    l_out_object2_num           NUMBER:=0;
    l_out_object2_char          VARCHAR2(30):=NULL;

    j                           NUMBER := 0;
    i                           NUMBER := 0;
    l_num_child_deliveries      NUMBER := 0;
    l_return_status             VARCHAR2(1);
    l_validate_excl_result      VARCHAR2(1) := 'S';
    l_carrier                   NUMBER := NULL;
    l_vehicle_type              NUMBER := NULL;
    l_mode                      VARCHAR2(30) := NULL;
    l_service_level             VARCHAR2(30) := NULL;
    l_carrier_service_inout_rec WSH_CARRIERS_GRP.Carrier_Service_InOut_Rec_Type;
    l_facility_id               NUMBER := 0;
    l_failed_constraint         line_constraint_rec_type;
    l_failed_constraints        line_constraint_tab_type;
    l_validate_carrier_result   VARCHAR2(1) := 'S';
    l_validate_vehicle_result   VARCHAR2(1) := 'S';
    l_validate_mode_result      VARCHAR2(1) := 'S';
    l_validate_orgfac_result    VARCHAR2(1) := 'S';
    l_validate_cusfac_result    VARCHAR2(1) := 'S';
    l_validate_supfac_result    VARCHAR2(1) := 'S';
    l_validate_itmfac_result    VARCHAR2(1) := 'S';
    l_validate_faccar_result    VARCHAR2(1) := 'S';
    l_validate_facveh_result    VARCHAR2(1) := 'S';
    l_validate_facmod_result    VARCHAR2(1) := 'S';
    l_validate_itmcar_result    VARCHAR2(1) := 'S';
    l_validate_itmveh_result    VARCHAR2(1) := 'S';
    l_validate_itmmod_result    VARCHAR2(1) := 'S';
    l_validate_result           VARCHAR2(1) := 'S';

    l_comp_class_tab            WSH_UTIL_CORE.Column_Tab_Type;
    l_detail_rec                detail_ccinfo_rec_type;
    l_dlvy_rec                  delivery_ccinfo_rec_type;
    l_dleg_dlvy_rec             delivery_ccinfo_rec_type;
    l_stop_rec                  stop_ccinfo_rec_type;
    l_detail_tab                detail_ccinfo_tab_type;
    l_trip_detail_tab           detail_ccinfo_tab_type;
    l_trip_dlvy_tab             delivery_ccinfo_tab_type;
    l_trip_stops_tab            stop_ccinfo_tab_type;
    l_target_tripstops          target_tripstop_cc_rec_type;
    l_entity_tab                entity_tab_type;
    l_line_groups               WSH_FTE_COMP_CONSTRAINT_PKG.line_group_tab_type;
    l_failed_lines              WSH_FTE_COMP_CONSTRAINT_PKG.failed_line_tab_type;
    l_group_info                WSH_FTE_COMP_CONSTRAINT_PKG.cc_group_tab_type;

    l_delivery_leg_rec          dleg_ccinfo_rec_type;
    l_physical_location_id      NUMBER := NULL;

    l_debug_on                  CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
    l_module_name               CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'validate_constraint_dleg';

BEGIN
    x_validate_result := 'S';
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    g_itm_mustuse_cache.DELETE;
    g_itmloc_mustuse_cache.DELETE;
    g_itm_exclusive_cache.DELETE;
    g_fac_exclusive_cache.DELETE;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
    END IF;

    IF l_debug_on THEN
       wsh_debug_sv.push(l_module_name);
       WSH_DEBUG_SV.logmsg(l_module_name,'p_init_msg_list : '||p_init_msg_list);
    END IF;

    refresh_cache(l_return_status);

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
    END IF;

    /*
    Lane search for a delivery leg	DLS	FAC_MOD, FAC_CAR, ITM_CAR ITM_MOD
    : Input one dleg, table of lanes
    Output valid lanes

    Searching trip for a delivery leg	DST	CUS_CUS
    :Input one dleg, table of trips             ITM_FAC ITM_MOD ITM_CAR ITM_VEH
     Output : valid trips

    Creating  a delivery leg	        CDL	COM_FAC CUS_FAC FAC_MOD FAC_CAR ITM_FAC
                                                ITM_MOD ITM_CAR SUP_FAC

    Editing                             UDL     COM_FAC CUS_FAC ITM_FAC FAC_MOD FAC_CAR
                                                ITM_MOD ITM_CAR SUP_FAC
    */

     IF NOT p_exception_list.EXISTS(G_FACILITY_MODE_NUM) THEN
        l_comp_class_tab(G_FACILITY_MODE_NUM) := G_FACILITY_MODE;
     END IF;
     IF NOT p_exception_list.EXISTS(G_FACILITY_CARRIER_NUM) THEN
        l_comp_class_tab(G_FACILITY_CARRIER_NUM) := G_FACILITY_CARRIER;
     END IF;
     IF NOT p_exception_list.EXISTS(G_FACILITY_VEHICLE_NUM) THEN
        l_comp_class_tab(G_FACILITY_VEHICLE_NUM) := G_FACILITY_VEHICLE;
     END IF;
     IF NOT p_exception_list.EXISTS(G_ITEM_MODE_NUM) THEN
        l_comp_class_tab(G_ITEM_MODE_NUM) := G_ITEM_MODE;
     END IF;
     IF NOT p_exception_list.EXISTS(G_ITEM_CARRIER_NUM) THEN
        l_comp_class_tab(G_ITEM_CARRIER_NUM) := G_ITEM_CARRIER;
     END IF;
     IF NOT p_exception_list.EXISTS(G_ITEM_VEHICLE_NUM) THEN
        l_comp_class_tab(G_ITEM_VEHICLE_NUM) := G_ITEM_VEHICLE;
     END IF;
     IF NOT p_exception_list.EXISTS(G_SHIPORG_FACILITY_NUM) THEN
        l_comp_class_tab(G_SHIPORG_FACILITY_NUM) := G_SHIPORG_FACILITY;
     END IF;
     IF NOT p_exception_list.EXISTS(G_CUSTOMER_FACILITY_NUM) THEN
        l_comp_class_tab(G_CUSTOMER_FACILITY_NUM) := G_CUSTOMER_FACILITY;
     END IF;
     IF NOT p_exception_list.EXISTS(G_SUPPLIER_FACILITY_NUM) THEN
        l_comp_class_tab(G_SUPPLIER_FACILITY_NUM) := G_SUPPLIER_FACILITY;
     END IF;
     IF NOT p_exception_list.EXISTS(G_ITEM_FACILITY_NUM) THEN
        l_comp_class_tab(G_ITEM_FACILITY_NUM) := G_ITEM_FACILITY;
     END IF;
     IF NOT p_exception_list.EXISTS(G_CUSTOMER_CUSTOMER_NUM) THEN
        l_comp_class_tab(G_CUSTOMER_CUSTOMER_NUM) := G_CUSTOMER_CUSTOMER;
     END IF;

    -- AG



    OPEN get_num_child_dlegs(p_delivery_leg_rec.delivery_leg_id);
        FETCH get_num_child_dlegs into l_num_child_deliveries;
    CLOSE get_num_child_dlegs;

    /*IF l_debug_on THEN
        wsh_debug_sv.logmsg('p_delivery_leg_rec.delivery_leg_id : '||p_delivery_leg_rec.delivery_leg_id);
   END IF;*/
     IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'p_delivery_leg_rec.delivery_leg_id : '||p_delivery_leg_rec.delivery_leg_id);
          END IF;
    IF l_num_child_deliveries > 0 THEN
        OPEN c_get_details_consol(p_delivery_leg_rec.delivery_id);
        LOOP
           FETCH c_get_details_consol INTO l_detail_rec;
           EXIT WHEN c_get_details_consol%NOTFOUND;

          /* IF l_debug_on THEN
                wsh_debug_sv.logmsg('l_detail_rec.COUNT: '||l_detail_rec.COUNT);
           END IF;*/

        -- AGDUMMY
        -- Convert ultimate_dropoff if dummy to physical
        -- TODO

        --#DUM_LOC(S)
        --Check if ultimate drop off location is a dummy location
        WSH_LOCATIONS_PKG.CONVERT_INTERNAL_CUST_LOCATION(
             p_internal_cust_location_id  => l_detail_rec.ship_to_location_id,
             x_internal_org_location_id   => l_physical_location_id,
             x_return_status              => l_return_status);

        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

        IF (l_physical_location_id IS NOT NULL) THEN
          --
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Location '||l_detail_rec.ship_to_location_id||' is a dummy location');
          END IF;
          --
          l_detail_rec.ship_to_location_id := l_physical_location_id;
          l_detail_rec.physical_ship_to_location_id := l_physical_location_id;
        END IF;
        --#DUM_LOC(E)

           l_detail_tab(l_detail_tab.COUNT+1) := l_detail_rec;
        END LOOP;
        CLOSE c_get_details_consol;
    ELSE
        OPEN c_get_details(p_delivery_leg_rec.delivery_id);
        LOOP
           FETCH c_get_details INTO l_detail_rec;
           EXIT WHEN c_get_details%NOTFOUND;


        -- AGDUMMY
        -- Convert ultimate_dropoff if dummy to physical
        -- TODO

        --#DUM_LOC(S)
        --Check if ultimate drop off location is a dummy location
        WSH_LOCATIONS_PKG.CONVERT_INTERNAL_CUST_LOCATION(
             p_internal_cust_location_id  => l_detail_rec.ship_to_location_id,
             x_internal_org_location_id   => l_physical_location_id,
             x_return_status              => l_return_status);

        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

        IF (l_physical_location_id IS NOT NULL) THEN
          --
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Location '||l_detail_rec.ship_to_location_id||' is a dummy location');
          END IF;
          --
          l_detail_rec.ship_to_location_id := l_physical_location_id;
          l_detail_rec.physical_ship_to_location_id := l_physical_location_id;
        END IF;
        --#DUM_LOC(E)

           l_detail_tab(l_detail_tab.COUNT+1) := l_detail_rec;
        END LOOP;
        CLOSE c_get_details;
    END IF;

    OPEN c_get_dlvy(p_delivery_leg_rec.delivery_id);
    FETCH c_get_dlvy INTO l_dleg_dlvy_rec;
    CLOSE c_get_dlvy;

    -- AGDUMMY
    -- Convert ultimate_dropoff if dummy to physical
    -- TODO

    --#DUM_LOC(S)
    --Check if ultimate drop off location is a dummy location
    WSH_LOCATIONS_PKG.CONVERT_INTERNAL_CUST_LOCATION(
         p_internal_cust_location_id  => l_dleg_dlvy_rec.ultimate_dropoff_location_id,
         x_internal_org_location_id   => l_physical_location_id,
         x_return_status              => l_return_status);

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END IF;

    IF (l_physical_location_id IS NOT NULL) THEN
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Location '||l_dleg_dlvy_rec.ultimate_dropoff_location_id||' is a dummy location');
      END IF;
      --
      l_dleg_dlvy_rec.ultimate_dropoff_location_id := l_physical_location_id;
      l_dleg_dlvy_rec.physical_dropoff_location_id := l_physical_location_id;
    END IF;
    --#DUM_LOC(E)

    l_orig_dlvy_puloc := l_dleg_dlvy_rec.initial_pickup_location_id;
    l_orig_dlvy_udloc := l_dleg_dlvy_rec.ultimate_dropoff_location_id;

    --#DUM_LOC(S)
    --Check if input dleg's drop off location is a dummy location
    l_delivery_leg_rec := p_delivery_leg_rec;

    WSH_LOCATIONS_PKG.CONVERT_INTERNAL_CUST_LOCATION(
         p_internal_cust_location_id  => p_delivery_leg_rec.dropoffstop_location_id,
         x_internal_org_location_id   => l_physical_location_id,
         x_return_status              => l_return_status);

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END IF;

    IF (l_physical_location_id IS NOT NULL) THEN
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Location '||p_delivery_leg_rec.dropoffstop_location_id||' is a dummy location');
      END IF;
      --
      l_delivery_leg_rec.dropoffstop_location_id := l_physical_location_id;
      --p_delivery_leg_rec.physical_dropoff_location_id := l_physical_location_id;
    END IF;
    --#DUM_LOC(E)

    -- For DLL
    -- API for DST, CDL, UDL internally calls this

    -- For DLL

    IF p_action_code = G_DLEG_LANE_SEARCH THEN

      --LOOP -- over target lanes
      i := p_target_lane.FIRST;
      IF i IS NOT NULL THEN
        LOOP

           l_validate_faccar_result := 'S';
           l_validate_facmod_result := 'S';
           l_validate_itmcar_result := 'S';
           l_validate_itmmod_result := 'S';
           l_validate_result := 'S';

           IF l_dleg_dlvy_rec.shipping_control = 'SUPPLIER' THEN
              GOTO lane_nextpass;
           END IF;

           IF l_comp_class_tab.EXISTS(G_FACILITY_CARRIER_NUM) THEN

             check_inclusive_object2(
                 p_comp_class_code          =>      G_FACILITY_CARRIER,
                 p_entity_type              =>      G_DELIVERY_LEG,
                 p_entity_id                =>      l_delivery_leg_rec.delivery_leg_id,
                 p_object1_type             =>      'FAC',
                 p_object1_val_num          =>      l_delivery_leg_rec.pickupstop_location_id,
                 p_object2_type             =>      'CAR',
                 p_object2_val_num          =>      p_target_lane(i).carrier_id,
                 x_out_object2_num          =>      l_out_object2_num,
                 x_out_object2_char         =>      l_out_object2_char,
                 x_validate_result          =>      l_validate_carrier_result,
                 x_failed_constraint        =>      l_failed_constraints,
                 x_return_status            =>      l_return_status);

             IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                   raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
             END IF;

             IF l_validate_carrier_result = 'F' THEN
                x_validate_result := 'F';
                l_validate_result := 'F';
                GOTO lane_nextpass;
             END IF;

             check_inclusive_object2(
                 p_comp_class_code          =>      G_FACILITY_CARRIER,
                 p_entity_type              =>      G_DELIVERY_LEG,
                 p_entity_id                =>      l_delivery_leg_rec.delivery_leg_id,
                 p_object1_type             =>      'FAC',
                 p_object1_val_num          =>      l_delivery_leg_rec.dropoffstop_location_id,
                 p_object2_type             =>      'CAR',
                 p_object2_val_num          =>      p_target_lane(i).carrier_id,
                 x_out_object2_num          =>      l_out_object2_num,
                 x_out_object2_char         =>      l_out_object2_char,
                 x_validate_result          =>      l_validate_carrier_result,
                 x_failed_constraint        =>      l_failed_constraints,
                 x_return_status            =>      l_return_status);

             IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                   raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
             END IF;

             IF l_validate_carrier_result = 'F' THEN
                 x_validate_result := 'F';
                 l_validate_result := 'F';
                 GOTO lane_nextpass;
             END IF;

           END IF;

           IF l_comp_class_tab.EXISTS(G_FACILITY_MODE_NUM) THEN

             check_inclusive_object2(
                 p_comp_class_code          =>      G_FACILITY_MODE,
                 p_entity_type              =>      G_DELIVERY_LEG,
                 p_entity_id                =>      l_delivery_leg_rec.delivery_leg_id,
                 p_object1_type             =>      'FAC',
                 p_object1_val_num          =>      l_delivery_leg_rec.pickupstop_location_id,
                 p_object2_type             =>      'MOD',
                 p_object2_val_char         =>      p_target_lane(i).mode_of_transportation_code,
                 x_out_object2_num          =>      l_out_object2_num,
                 x_out_object2_char         =>      l_out_object2_char,
                 x_validate_result          =>      l_validate_mode_result,
                 x_failed_constraint        =>      l_failed_constraints,
                 x_return_status            =>      l_return_status);

             IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                   raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
             END IF;

             IF l_validate_mode_result = 'F' THEN
                x_validate_result := 'F';
                l_validate_result := 'F';
                GOTO lane_nextpass;
             END IF;

             check_inclusive_object2(
                 p_comp_class_code          =>      G_FACILITY_MODE,
                 p_entity_type              =>      G_DELIVERY_LEG,
                 p_entity_id                =>      l_delivery_leg_rec.delivery_leg_id,
                 p_object1_type             =>      'FAC',
                 p_object1_val_num          =>      l_delivery_leg_rec.dropoffstop_location_id,
                 p_object2_type             =>      'MOD',
                 p_object2_val_char         =>      p_target_lane(i).mode_of_transportation_code,
                 x_out_object2_num          =>      l_out_object2_num,
                 x_out_object2_char         =>      l_out_object2_char,
                 x_validate_result          =>      l_validate_mode_result,
                 x_failed_constraint        =>      l_failed_constraints,
                 x_return_status            =>      l_return_status);

             IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                   raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
             END IF;

             IF l_validate_mode_result = 'F' THEN
                x_validate_result := 'F';
                l_validate_result := 'F';
                GOTO lane_nextpass;
             END IF;


           END IF;

           -- Proceed to check Exclusive constraints
           -- only if success

           -- FAC - CAR/MOD for dleg's locations against lane's carrier, mode

           IF l_comp_class_tab.EXISTS(G_FACILITY_CARRIER_NUM) AND
              p_target_lane(i).carrier_id IS NOT NULL THEN

             validate_constraint(
                 p_comp_class_code          =>      G_FACILITY_CARRIER,
                 p_object1_type             =>      'FAC',
                 p_object1_val_num          =>      l_delivery_leg_rec.pickupstop_location_id,
                 p_object2_type             =>      'CAR',
                 p_object2_val_num          =>      p_target_lane(i).carrier_id,
                 x_validate_result          =>      l_validate_faccar_result,
                 x_failed_constraint        =>      l_failed_constraint,
                 x_return_status            =>      l_return_status);

             IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                   raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
             END IF;

             IF l_validate_faccar_result <> 'S' THEN
                  l_failed_constraint.line_constraint_index := l_failed_constraints.COUNT+1;
                  l_failed_constraint.entity_type :=  G_DELIVERY_LEG;
                  l_failed_constraint.entity_line_id :=  l_delivery_leg_rec.delivery_leg_id;
                  l_failed_constraints(l_failed_constraints.COUNT+1) := l_failed_constraint;

                  IF l_validate_faccar_result = 'E' THEN
                     x_validate_result := 'F';
                     l_validate_result := 'F';
                  END IF;
             END IF;
             -- Success can override Failure

             validate_constraint(
                 p_comp_class_code          =>      G_FACILITY_CARRIER,
                 p_object1_type             =>      'FAC',
                 p_object1_val_num          =>      l_delivery_leg_rec.dropoffstop_location_id,
                 p_object2_type             =>      'CAR',
                 p_object2_val_num          =>      p_target_lane(i).carrier_id,
                 x_validate_result          =>      l_validate_faccar_result,
                 x_failed_constraint        =>      l_failed_constraint,
                 x_return_status            =>      l_return_status);

             IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                   raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
             END IF;

             IF l_validate_faccar_result <> 'S' THEN
                  l_failed_constraint.line_constraint_index := l_failed_constraints.COUNT+1;
                  l_failed_constraint.entity_type :=  G_DELIVERY_LEG;
                  l_failed_constraint.entity_line_id :=  l_delivery_leg_rec.delivery_leg_id;
                  l_failed_constraints(l_failed_constraints.COUNT+1) := l_failed_constraint;

                  IF l_validate_faccar_result = 'E' THEN
                     x_validate_result := 'F';
                     l_validate_result := 'F';
                  END IF;
             END IF;

           END IF;

           IF l_comp_class_tab.EXISTS(G_FACILITY_MODE_NUM) AND
              p_target_lane(i).mode_of_transportation_code IS NOT NULL THEN

             validate_constraint(
                 p_comp_class_code          =>      G_FACILITY_MODE,
                 p_object1_type             =>      'FAC',
                 p_object1_val_num          =>      l_delivery_leg_rec.pickupstop_location_id,
                 p_object2_type             =>      'MOD',
                 p_object2_val_char         =>      p_target_lane(i).mode_of_transportation_code,
                 x_validate_result          =>      l_validate_facmod_result,
                 x_failed_constraint        =>      l_failed_constraint,
                 x_return_status            =>      l_return_status);

             IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                   raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
             END IF;

             IF l_validate_facmod_result <> 'S' THEN
                  l_failed_constraint.line_constraint_index := l_failed_constraints.COUNT+1;
                  l_failed_constraint.entity_type :=  G_DELIVERY_LEG;
                  l_failed_constraint.entity_line_id :=  l_delivery_leg_rec.delivery_leg_id;
                  l_failed_constraints(l_failed_constraints.COUNT+1) := l_failed_constraint;

                  IF l_validate_facmod_result = 'E' THEN
                   x_validate_result := 'F';
                   l_validate_result := 'F';
                  END IF;

             END IF;

             validate_constraint(
                 p_comp_class_code          =>      G_FACILITY_MODE,
                 p_object1_type             =>      'FAC',
                 p_object1_val_num          =>      l_delivery_leg_rec.dropoffstop_location_id,
                 p_object2_type             =>      'MOD',
                 p_object2_val_char         =>      p_target_lane(i).mode_of_transportation_code,
                 x_validate_result          =>      l_validate_facmod_result,
                 x_failed_constraint        =>      l_failed_constraint,
                 x_return_status            =>      l_return_status);

             IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                   raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
             END IF;

             IF l_validate_facmod_result <> 'S' THEN
                  l_failed_constraint.line_constraint_index := l_failed_constraints.COUNT+1;
                  l_failed_constraint.entity_type :=  G_DELIVERY_LEG;
                  l_failed_constraint.entity_line_id :=  l_delivery_leg_rec.delivery_leg_id;
                  l_failed_constraints(l_failed_constraints.COUNT+1) := l_failed_constraint;

                  IF l_validate_facmod_result = 'E' THEN
                   x_validate_result := 'F';
                   l_validate_result := 'F';
                  END IF;
             END IF;

           END IF;
           --LOOP -- Over dleg's children details
           j := l_detail_tab.FIRST;
           IF j IS NOT NULL THEN
             LOOP

                -- ITM - CAR/MOD for detail's item against lane's carrier, mode
             -- Inclusive constraints
             -- Not to check item levl inclusive constraints
             -- when entity = delivery/dleg

              IF l_comp_class_tab.EXISTS(G_ITEM_CARRIER_NUM) THEN

                  check_inclusive_object2(
                   p_comp_class_code          =>      G_ITEM_CARRIER,
                   p_entity_type              =>      G_DEL_DETAIL,
                   p_entity_id                =>      l_detail_tab(j).delivery_detail_id,
                   p_object1_type             =>      'ITM',
                   p_object1_parent_id        =>      l_detail_tab(j).organization_id,
                   p_object1_val_num          =>      l_detail_tab(j).inventory_item_id,
                   p_object2_type             =>      'CAR',
                   p_object2_val_num          =>      p_target_lane(i).carrier_id,
                   x_out_object2_num          =>      l_out_object2_num,
                   x_out_object2_char         =>      l_out_object2_char,
                   x_validate_result          =>      l_validate_carrier_result,
                   x_failed_constraint        =>      l_failed_constraints,
                   x_return_status            =>      l_return_status);

                  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                     IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                     END IF;
                  END IF;

                  IF l_validate_carrier_result = 'F' THEN
                     x_validate_result := 'F';
                     l_validate_result := 'F';
                     EXIT;
                  END IF;

              END IF;

              IF l_comp_class_tab.EXISTS(G_ITEM_MODE_NUM) THEN

                  check_inclusive_object2(
                   p_comp_class_code          =>      G_ITEM_MODE,
                   p_entity_type              =>      G_DEL_DETAIL,
                   p_entity_id                =>      l_detail_tab(j).delivery_detail_id,
                   p_object1_type             =>      'ITM',
                   p_object1_parent_id        =>      l_detail_tab(j).organization_id,
                   p_object1_val_num          =>      l_detail_tab(j).inventory_item_id,
                   p_object2_type             =>      'MOD',
                   p_object2_val_char         =>      p_target_lane(i).mode_of_transportation_code,
                   x_out_object2_num          =>      l_out_object2_num,
                   x_out_object2_char         =>      l_out_object2_char,
                   x_validate_result          =>      l_validate_mode_result,
                   x_failed_constraint        =>      l_failed_constraints,
                   x_return_status            =>      l_return_status);

                  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                       raise FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
                  END IF;

                  IF l_validate_mode_result = 'F' THEN
                     x_validate_result := 'F';
                     l_validate_result := 'F';
                     EXIT;
                  END IF;

              END IF;

              IF l_comp_class_tab.EXISTS(G_ITEM_MODE_NUM) THEN

                 validate_constraint(   --  checks only negative constraints
                   p_comp_class_code          =>      G_ITEM_MODE,
                   p_object1_type             =>      'ITM',
                   p_object1_parent_id        =>      l_detail_tab(j).organization_id,
                   p_object2_type             =>      'MOD',
                   p_object1_val_num          =>      l_detail_tab(j).inventory_item_id,
                   p_object2_val_char         =>      p_target_lane(i).mode_of_transportation_code,
                   x_validate_result          =>      l_validate_itmmod_result,
                   x_failed_constraint        =>      l_failed_constraint,
                   x_return_status            =>      l_return_status);

                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                       raise FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
                 END IF;

                 -- For exclusive constraints error with one detail in the group is error
                 -- But, for inclusive constraints success with one detail in the group is success

                 IF l_validate_itmmod_result <> 'S' THEN
                    l_failed_constraint.line_constraint_index := l_failed_constraints.COUNT+1;
                    l_failed_constraint.entity_type :=  G_DEL_DETAIL;
                    l_failed_constraint.entity_line_id :=  l_detail_tab(j).delivery_detail_id;
                    l_failed_constraints(l_failed_constraints.COUNT+1) := l_failed_constraint;

                    IF l_validate_itmmod_result = 'E' THEN
                     x_validate_result := 'F';
                     l_validate_result := 'F';
                    END IF;

                 END IF;

              END IF;

              IF l_comp_class_tab.EXISTS(G_ITEM_CARRIER_NUM) THEN

                 validate_constraint(   --  checks only negative constraints
                   p_comp_class_code          =>      G_ITEM_CARRIER,
                   p_object1_type             =>      'ITM',
                   p_object1_parent_id        =>      l_detail_tab(j).organization_id,
                   p_object2_type             =>      'CAR',
                   p_object1_val_num          =>      l_detail_tab(j).inventory_item_id,
                   p_object2_val_num          =>      p_target_lane(i).carrier_id,
                   x_validate_result          =>      l_validate_itmcar_result,
                   x_failed_constraint        =>      l_failed_constraint,
                   x_return_status            =>      l_return_status);

                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                       raise FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
                 END IF;

                 -- For exclusive constraints error with one detail in the group is error
                 -- But, for inclusive constraints success with one detail in the group is success

                 IF l_validate_itmcar_result <> 'S' THEN
                    l_failed_constraint.line_constraint_index := l_failed_constraints.COUNT+1;
                    l_failed_constraint.entity_type :=  G_DEL_DETAIL;
                    l_failed_constraint.entity_line_id :=  l_detail_tab(j).delivery_detail_id;
                    l_failed_constraints(l_failed_constraints.COUNT+1) := l_failed_constraint;

                    IF l_validate_itmcar_result = 'E' THEN
                     x_validate_result := 'F';
                     l_validate_result := 'F';
                    END IF;

                 END IF;

              END IF;

              <<det_nextpass>>

              EXIT WHEN j = l_detail_tab.LAST;
              j := l_detail_tab.NEXT(j);

             END LOOP;
           END IF;

           <<lane_nextpass>>

           IF l_validate_result = 'S' THEN
           -- populate x_succ_lanes
              x_succ_lanes(x_succ_lanes.COUNT+1) := p_target_lane(i).lane_id;

           END IF;

           EXIT WHEN i = p_target_lane.LAST;
           i := p_target_lane.NEXT(i);

        END LOOP;
      END IF;

    END IF;    --  DLS

    -- For DST

    IF p_action_code = G_DLEG_TRIP_SEARCH THEN

      --LOOP -- over target trips
      i := p_target_trip.FIRST;
      IF i IS NOT NULL THEN
        LOOP

          l_validate_faccar_result := 'S';
          l_validate_facmod_result := 'S';
          l_validate_itmcar_result := 'S';
          l_validate_itmmod_result := 'S';
          l_validate_result := 'S';
          l_validate_excl_result := 'S';
          l_carrier := NULL;
          l_mode := NULL;
          l_service_level := NULL;

          IF l_dleg_dlvy_rec.shipping_control = 'SUPPLIER' THEN
             GOTO next_trip;
          END IF;

           -- FAC - CAR/MOD for dleg's locations against trip's carrier, mode

           -- Inclusive constraints
           -- Proceed to check Exclusive constraints
           -- only if success
           -- ITM - CAR/MOD


          OPEN c_get_trip_details(p_target_trip(i).trip_id);
          LOOP
              FETCH c_get_trip_details INTO l_detail_rec;
              EXIT WHEN c_get_trip_details%NOTFOUND;


    -- AGDUMMY
    -- Convert ship_to if dummy to physical
    -- TODO

    --#DUM_LOC(S)
    --Check if ultimate drop off location is a dummy location
    WSH_LOCATIONS_PKG.CONVERT_INTERNAL_CUST_LOCATION(
         p_internal_cust_location_id  => l_detail_rec.ship_to_location_id,
         x_internal_org_location_id   => l_physical_location_id,
         x_return_status              => l_return_status);

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END IF;

    IF (l_physical_location_id IS NOT NULL) THEN
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Location '||l_detail_rec.ship_to_location_id||' is a dummy location');
      END IF;
      --
      l_detail_rec.ship_to_location_id := l_physical_location_id;
      l_detail_rec.physical_ship_to_location_id := l_physical_location_id;
    END IF;
    --#DUM_LOC(E)

              l_trip_detail_tab(l_trip_detail_tab.COUNT+1) := l_detail_rec;
          END LOOP;
          CLOSE c_get_trip_details;

          OPEN c_get_trip_dlvy(p_target_trip(i).trip_id);
          LOOP
              FETCH c_get_trip_dlvy INTO l_dlvy_rec;
              EXIT WHEN c_get_trip_dlvy%NOTFOUND;


    -- AGDUMMY
    -- Convert ultimate_dropoff if dummy to physical
    -- TODO

    --#DUM_LOC(S)
    --Check if ultimate drop off location is a dummy location
    WSH_LOCATIONS_PKG.CONVERT_INTERNAL_CUST_LOCATION(
         p_internal_cust_location_id  => l_dlvy_rec.ultimate_dropoff_location_id,
         x_internal_org_location_id   => l_physical_location_id,
         x_return_status              => l_return_status);

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END IF;

    IF (l_physical_location_id IS NOT NULL) THEN
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Location '||l_dlvy_rec.ultimate_dropoff_location_id||' is a dummy location');
      END IF;
      --
      l_dlvy_rec.ultimate_dropoff_location_id := l_physical_location_id;
      l_dlvy_rec.physical_dropoff_location_id := l_physical_location_id;
    END IF;
    --#DUM_LOC(E)

              l_trip_dlvy_tab(l_trip_dlvy_tab.COUNT+1) := l_dlvy_rec;
          END LOOP;
          CLOSE c_get_trip_dlvy;

          OPEN c_get_trip_stops(p_target_trip(i).trip_id);
          LOOP
              FETCH c_get_trip_stops INTO l_stop_rec;
              EXIT WHEN c_get_trip_stops%NOTFOUND;

              l_trip_stops_tab(l_trip_stops_tab.COUNT+1) := l_stop_rec;
          END LOOP;
          CLOSE c_get_trip_stops;

          -- As this only filters open trip results by constraint violations,
          -- the moment a violation is found for an input trip
          -- no more violations are checked for that trip

          -- Need to check Inclusive facility as parameter2 constraints as well
          -- Call validate_positive_constraint

          l_entity_tab(l_dleg_dlvy_rec.delivery_id).entity_id := l_dleg_dlvy_rec.delivery_id;
          l_entity_tab(l_dleg_dlvy_rec.delivery_id).organization_id := l_dleg_dlvy_rec.organization_id;
          l_entity_tab(l_dleg_dlvy_rec.delivery_id).initial_pickup_location_id := l_dleg_dlvy_rec.initial_pickup_location_id;
          l_entity_tab(l_dleg_dlvy_rec.delivery_id).ultimate_dropoff_location_id := l_dleg_dlvy_rec.ultimate_dropoff_location_id;
         l_entity_tab(l_dleg_dlvy_rec.delivery_id).initial_pickup_date := l_dleg_dlvy_rec.initial_pickup_date;
         l_entity_tab(l_dleg_dlvy_rec.delivery_id).ultimate_dropoff_date := l_dleg_dlvy_rec.ultimate_dropoff_date;
          l_entity_tab(l_dleg_dlvy_rec.delivery_id).physical_dropoff_location_id := l_dleg_dlvy_rec.physical_dropoff_location_id;
          l_entity_tab(l_dleg_dlvy_rec.delivery_id).intmed_ship_to_location_id := l_dleg_dlvy_rec.intmed_ship_to_location_id;
          l_entity_tab(l_dleg_dlvy_rec.delivery_id).ship_method_code := l_dleg_dlvy_rec.ship_method_code;
          l_entity_tab(l_dleg_dlvy_rec.delivery_id).carrier_id := l_dleg_dlvy_rec.carrier_id;
          l_entity_tab(l_dleg_dlvy_rec.delivery_id).mode_of_transport := l_dleg_dlvy_rec.mode_of_transport;
          l_entity_tab(l_dleg_dlvy_rec.delivery_id).customer_id := l_dleg_dlvy_rec.customer_id;
          l_entity_tab(l_dleg_dlvy_rec.delivery_id).party_id := l_dleg_dlvy_rec.party_id;
          l_entity_tab(l_dleg_dlvy_rec.delivery_id).shipment_direction := l_dleg_dlvy_rec.shipment_direction;
          l_entity_tab(l_dleg_dlvy_rec.delivery_id).shipping_control := l_dleg_dlvy_rec.shipping_control;
          --
          IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Created l_entity_tab with index : '||l_dleg_dlvy_rec.delivery_id);
          END IF;
          --

          l_target_tripstops.pickup_stop_id        := l_delivery_leg_rec.pick_up_stop_id;
          l_target_tripstops.dropoff_stop_id       := l_delivery_leg_rec.drop_off_stop_id;
          l_target_tripstops.pickup_location_id    := l_delivery_leg_rec.pickupstop_location_id;
          l_target_tripstops.dropoff_location_id   := l_delivery_leg_rec.dropoffstop_location_id;
          -- AG 10+
          l_target_tripstops.pickup_stop_pa_date    := l_delivery_leg_rec.pickup_stop_pa_date;
          l_target_tripstops.dropoff_stop_pa_date   := l_delivery_leg_rec.dropoff_stop_pa_date;

          create_valid_entity_group(
                  p_entity_rec            => l_entity_tab(l_dleg_dlvy_rec.delivery_id),
                  p_group_tab             => l_group_info,
                  x_return_status         => l_return_status);
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Called create_valid_entity_group return status : '||l_return_status);
          END IF;
          --

          IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                 raise FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
          END IF;

          validate_positive_constraint(
                    p_action_code         => G_ASSIGN_DLVY_TRIP,
                    p_comp_class_tab      => l_comp_class_tab,
                    p_entity_tab          => l_entity_tab,
                    p_group_tab           => l_group_info,
                    p_detail_tab          => l_detail_tab,
                    p_target_trip         => p_target_trip(i),
                    p_target_tripstops    => l_trip_stops_tab,
                    p_target_stops_info   => l_target_tripstops,
                    x_line_groups         => l_line_groups,
                    x_failed_lines        => l_failed_lines,
                    x_failed_constraints  => l_failed_constraints,
                    x_return_status       => l_return_status);
          --
          IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Called validate_positive_constraint return status : '||l_return_status);
             WSH_DEBUG_SV.logmsg(l_module_name,'l_failed_lines count : '||l_failed_lines.COUNT);
          END IF;
          --

          IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                 raise FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
          ELSIF l_failed_lines.COUNT > 0 THEN
              x_validate_result := 'F';
              l_validate_result := 'F';
          END IF;

          IF l_validate_result = 'S' THEN

           check_dlvy_against_trip(
                     p_entity_type         => 'DLEG',
                     p_entity_id           => l_delivery_leg_rec.delivery_leg_id,
                     p_delivery_rec        => l_dleg_dlvy_rec,
                     p_detail_tab          => l_detail_tab,
                     p_comp_class_tab      => l_comp_class_tab,
                     p_target_stops_info   => l_target_tripstops,
                     p_target_trip         => p_target_trip(i),
                     p_target_tripstops    => l_trip_stops_tab,
                     p_target_dlvy         => l_trip_dlvy_tab,
                     p_target_dlvy_lines   => l_trip_detail_tab,
                     x_failed_constraints  => l_failed_constraints,
                     x_validate_result     => l_validate_excl_result,
                     x_return_status       => l_return_status);

           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
             IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
           END IF;

           IF l_validate_excl_result = 'F' THEN
                   x_validate_result := 'F';
                   l_validate_result := 'F';
           END IF;

          END IF; -- l_validate_result = 'S'

          <<next_trip>>

          IF l_validate_result = 'S' THEN
           -- populate x_succ_trips
              x_succ_trips(x_succ_trips.COUNT+1) := p_target_trip(i).trip_id;

          END IF;

          EXIT WHEN i = p_target_trip.LAST;
          i := p_target_trip.NEXT(i);

        END LOOP;
      END IF;

    END IF;   -- DST

    -- For DCE

    IF p_action_code IN (G_UPDATE_DLEG,G_DLEG_CRT) AND
       l_dleg_dlvy_rec.shipping_control <> 'SUPPLIER' THEN

    -- FAC - CAR/MOD for dleg against dleg's locations

       IF l_comp_class_tab.EXISTS(G_FACILITY_CARRIER_NUM) AND
          l_delivery_leg_rec.carrier_id IS NOT NULL THEN

            validate_constraint(
             p_comp_class_code          =>      G_FACILITY_CARRIER,
             p_object1_type             =>      'FAC',
             p_object1_val_num          =>      l_delivery_leg_rec.pickupstop_location_id,
             p_object2_type             =>      'CAR',
             p_object2_val_num          =>      l_delivery_leg_rec.carrier_id,
             x_validate_result          =>      l_validate_faccar_result,
             x_failed_constraint        =>      l_failed_constraint,
             x_return_status            =>      l_return_status);

            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                  raise FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            END IF;

            IF l_validate_faccar_result <> 'S' THEN
              l_failed_constraint.line_constraint_index := l_failed_constraints.COUNT+1;
              l_failed_constraint.entity_type :=  G_DELIVERY_LEG;
              l_failed_constraint.entity_line_id :=  l_delivery_leg_rec.delivery_leg_id;
              l_failed_constraints(l_failed_constraints.COUNT+1) := l_failed_constraint;

              IF l_validate_faccar_result = 'E' THEN
                 x_validate_result := 'F';
                 l_validate_result := 'F';
              END IF;
            END IF;
         -- Success can override Failure

            validate_constraint(
             p_comp_class_code          =>      G_FACILITY_CARRIER,
             p_object1_type             =>      'FAC',
             p_object1_val_num          =>      l_delivery_leg_rec.dropoffstop_location_id,
             p_object2_type             =>      'CAR',
             p_object2_val_num          =>      l_delivery_leg_rec.carrier_id,
             x_validate_result          =>      l_validate_faccar_result,
             x_failed_constraint        =>      l_failed_constraint,
             x_return_status            =>      l_return_status);

            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                  raise FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            END IF;

            IF l_validate_faccar_result <> 'S' THEN
              l_failed_constraint.line_constraint_index := l_failed_constraints.COUNT+1;
              l_failed_constraint.entity_type :=  G_DELIVERY_LEG;
              l_failed_constraint.entity_line_id :=  l_delivery_leg_rec.delivery_leg_id;
              l_failed_constraints(l_failed_constraints.COUNT+1) := l_failed_constraint;

              IF l_validate_faccar_result = 'E' THEN
                 x_validate_result := 'F';
                l_validate_result := 'F';
              END IF;
            END IF;

       END IF;

       IF l_comp_class_tab.EXISTS(G_FACILITY_MODE_NUM) AND
          l_delivery_leg_rec.MODE_OF_TRANSPORT IS NOT NULL THEN

            validate_constraint(
             p_comp_class_code          =>      G_FACILITY_MODE,
             p_object1_type             =>      'FAC',
             p_object1_val_num          =>      l_delivery_leg_rec.pickupstop_location_id,
             p_object2_type             =>      'MOD',
             p_object2_val_char         =>      l_delivery_leg_rec.mode_of_transport,
             x_validate_result          =>      l_validate_facmod_result,
             x_failed_constraint        =>      l_failed_constraint,
             x_return_status            =>      l_return_status);

            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                  raise FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            END IF;

            IF l_validate_facmod_result <> 'S' THEN
              l_failed_constraint.line_constraint_index := l_failed_constraints.COUNT+1;
              l_failed_constraint.entity_type :=  G_DELIVERY_LEG;
              l_failed_constraint.entity_line_id :=  l_delivery_leg_rec.delivery_leg_id;
              l_failed_constraints(l_failed_constraints.COUNT+1) := l_failed_constraint;

              IF l_validate_facmod_result = 'E' THEN
               x_validate_result := 'F';
               l_validate_result := 'F';
              END IF;

            END IF;

            validate_constraint(
             p_comp_class_code          =>      G_FACILITY_MODE,
             p_object1_type             =>      'FAC',
             p_object1_val_num          =>      l_delivery_leg_rec.dropoffstop_location_id,
             p_object2_type             =>      'MOD',
             p_object2_val_char         =>      l_delivery_leg_rec.mode_of_transport,
             x_validate_result          =>      l_validate_facmod_result,
             x_failed_constraint        =>      l_failed_constraint,
             x_return_status            =>      l_return_status);

            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                  raise FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            END IF;

            IF l_validate_facmod_result <> 'S' THEN
              l_failed_constraint.line_constraint_index := l_failed_constraints.COUNT+1;
              l_failed_constraint.entity_type :=  G_DELIVERY_LEG;
              l_failed_constraint.entity_line_id :=  l_delivery_leg_rec.delivery_leg_id;
              l_failed_constraints(l_failed_constraints.COUNT+1) := l_failed_constraint;

              IF l_validate_facmod_result = 'E' THEN
               x_validate_result := 'F';
               l_validate_result := 'F';
              END IF;
            END IF;

       END IF;

       check_dleg_discretionary(
                 p_entity_type          => G_DELIVERY_LEG,
                 p_entity_id            => l_delivery_leg_rec.delivery_leg_id,
                 p_delivery_rec         => l_dleg_dlvy_rec,
                 p_comp_class_tab       => l_comp_class_tab,
                 p_dleg_pick_up_loc_id  => l_delivery_leg_rec.pickupstop_location_id,
                 p_dleg_drop_off_loc_id => l_delivery_leg_rec.dropoffstop_location_id,
                 p_detail_tab           => l_detail_tab,
                 p_carrier              => l_delivery_leg_rec.carrier_id,
                 p_mode                 => l_delivery_leg_rec.mode_of_transport,
                 x_failed_constraints   => l_failed_constraints,
                 x_validate_result      => l_validate_result,
                 x_return_status        => l_return_status);

           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                 raise FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
           END IF;

           IF l_validate_result = 'F' THEN
              x_validate_result := l_validate_result;
           END IF;


    END IF;

     --  Loop over l_failed_constraints to add to the mesage stack

    stack_messages (
             p_failed_constraints       => l_failed_constraints,
             x_msg_count                => x_msg_count,
             x_msg_data                 => x_msg_data,
             x_return_status            => l_return_status);

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
    END IF;

    IF x_validate_result = 'F' THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    ELSIF l_failed_constraints.COUNT > 0 THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    END IF;

    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --

EXCEPTION
    WHEN g_get_carrmode_failed THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,' get carrier-mode failed ');
      END IF;
      --
    WHEN g_get_vehicletype_failed THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,' get vehicletype failed ');
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
    WHEN others THEN
      WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.validate_constraint_dleg');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END validate_constraint_dleg;


--***************************************************************************--
--========================================================================
-- PROCEDURE : validate_constraint_dlvb    Called by constraint Wrapper API
--                                         and the Group API.
--
-- PARAMETERS: p_init_msg_list             FND_API.G_TRUE to reset list
--             p_action_code               Predefined action code
--             p_exception_list            Compatibility classes to skip if any
--                                         indexed by class code numbers
--             p_in_ids                    Table of delivery ids to process
--                                         Either of the next two should be passed
--             p_del_detail_info           Table of delivery detail records to process
--                                         Only one of p_in_ids and p_del_detail_info should be passed
--             p_target_delivery           Applicable for Assign delivery detail to delivery only
--                                         Record of target delivery information
--             p_target_container          Applicable for Assign delivery detail to container only
--                                         Record of target container information
--                                         If not passed, the API will query
--             p_dlvy_assigned_lines       Table of delivery details already in target
--                                         delivery or target container
--                                         If not passed, the API will query
--             x_validate_result           Constraint Validation result : S / F
--             x_failed_lines              Table of input delivery lines that failed
--                                         constraint check
--             x_line_groups               Includes Successful and warning lines
--                                         after constraint check
--                                         Contains information of which input delivery should
--                                         be grouped in which output group for trip creation
--             x_group_info                Output groups for input deliveries
--             x_msg_count                 Number of messages in the list
--             x_msg_data                  Text of messages
--             x_return_status             Return status
-- COMMENT   : This procedure is used to perform for following actions
--             A. Autocreate Delivery (ACD)
--             B. Assign detail to Delivery (ADD)
--             C. Packing (PKG)
--             When specifying a target delivery, group all delivery lines that are being planned
--             to the target delivery
--========================================================================

PROCEDURE validate_constraint_dlvb(
             p_init_msg_list            IN      VARCHAR2 DEFAULT fnd_api.g_false,
             p_action_code              IN      VARCHAR2 DEFAULT NULL,
             p_exception_list           IN      WSH_UTIL_CORE.Column_Tab_Type,
             p_in_ids                   IN      WSH_UTIL_CORE.id_tab_type,
             p_del_detail_info          IN      detail_ccinfo_tab_type,
             p_target_delivery          IN      delivery_ccinfo_rec_type,
             p_target_container         IN      detail_ccinfo_rec_type,
             p_dlvy_assigned_lines      IN      detail_ccinfo_tab_type,
             x_validate_result          OUT NOCOPY    VARCHAR2,
             x_failed_lines             OUT NOCOPY    WSH_FTE_COMP_CONSTRAINT_PKG.failed_line_tab_type,
             x_line_groups              OUT NOCOPY    WSH_FTE_COMP_CONSTRAINT_PKG.line_group_tab_type,
             x_group_info               OUT NOCOPY    WSH_FTE_COMP_CONSTRAINT_PKG.cc_group_tab_type,
             x_msg_count                OUT NOCOPY    NUMBER,
             x_msg_data                 OUT NOCOPY    VARCHAR2,
             x_return_status            OUT NOCOPY    VARCHAR2)
IS

    CURSOR c_get_assigned_lines_cont(c_container_id IN NUMBER) IS
    SELECT wdd.DELIVERY_DETAIL_ID,wda.DELIVERY_ID,'Y',wdd.CUSTOMER_ID,
           wdd.INVENTORY_ITEM_ID,wdd.SHIP_FROM_LOCATION_ID,wdd.ORGANIZATION_ID,
           wdd.SHIP_TO_LOCATION_ID,wdd.INTMED_SHIP_TO_LOCATION_ID,wdd.RELEASED_STATUS,
           wdd.CONTAINER_FLAG,wdd.DATE_REQUESTED,wdd.DATE_SCHEDULED,wdd.SHIP_METHOD_CODE,
           wdd.CARRIER_ID,wdd.party_id,nvl(wdd.line_direction,'O')
           ,nvl(wdd.shipping_control,'BUYER'),NULL

    FROM   WSH_DELIVERY_DETAILS wdd,
           wsh_delivery_assignments_v wda
    WHERE  wda.DELIVERY_DETAIL_ID = wdd.DELIVERY_DETAIL_ID
    AND    nvl(wdd.shipping_control,'BUYER') <> 'SUPPLIER'
    AND    wda.PARENT_DELIVERY_DETAIL_ID = c_container_id;

    CURSOR c_get_line_details(c_detail_id IN NUMBER) IS
    SELECT wdd.DELIVERY_DETAIL_ID,null,'Y',wdd.CUSTOMER_ID,
           wdd.INVENTORY_ITEM_ID,wdd.SHIP_FROM_LOCATION_ID,wdd.ORGANIZATION_ID,
           wdd.SHIP_TO_LOCATION_ID,wdd.INTMED_SHIP_TO_LOCATION_ID,wdd.RELEASED_STATUS,
           wdd.CONTAINER_FLAG,wdd.DATE_REQUESTED,wdd.DATE_SCHEDULED,wdd.SHIP_METHOD_CODE,
           wdd.CARRIER_ID,wdd.party_id,nvl(wdd.line_direction,'O')
           ,nvl(wdd.shipping_control,'BUYER'),NULL
           --DUM_LOC
    FROM   WSH_DELIVERY_DETAILS wdd
    WHERE  wdd.DELIVERY_DETAIL_ID = c_detail_id;

    CURSOR c_getdelivery(c_detail_id IN NUMBER) IS
    SELECT wda.DELIVERY_ID
    FROM   wsh_delivery_assignments_v wda
    WHERE  wda.delivery_detail_id = c_detail_id;

    i                                    NUMBER:=0;
    j                                    NUMBER:=0;
    k                                    NUMBER:=0;
    l                                    NUMBER:=0;
    m                                    NUMBER:=0;
    n                                    NUMBER:=0;
    o                                    NUMBER:=0;
    p                                    NUMBER:=0;
    q                                    NUMBER:=0;
    s                                    NUMBER:=0;
    t                                    NUMBER:=0;
    l_assigned_line_cnt                  NUMBER:=0;
    l_group_count                        NUMBER:=0;
    l_failed_lc                          NUMBER:=0;
    l_input_target_id                    NUMBER:=0;
    l_group_id                           NUMBER:=0;
    l_linegroup_indx                     NUMBER:=0;
    l_item_org_id                        NUMBER:=0;
    l_item_id                            NUMBER:=0;
    l_customer_id                        NUMBER:=0;
    l_carrier                            NUMBER := NULL;
    l_found                              BOOLEAN := FALSE;
    l_failed_line_added                  BOOLEAN := FALSE;
    l_mode                               VARCHAR2(30) := NULL;
    l_service_level                      VARCHAR2(30) := NULL;
    l_carrier_service_inout_rec          WSH_CARRIERS_GRP.Carrier_Service_InOut_Rec_Type;
    l_intmed_location_id                 NUMBER:=0;
    l_hash_string                        VARCHAR2(200);
    l_hash_value                         NUMBER:=0;
    l_return_status                      VARCHAR2(1);
    l_validate_result                    VARCHAR2(1);
    l_validate_item_result               VARCHAR2(1);
    l_validate_customer_result           VARCHAR2(1);
    l_validate_carrier_result            VARCHAR2(1);
    l_validate_mode_result               VARCHAR2(1);
    l_validate_intmed_result             VARCHAR2(1);
    l_input_comp_class                   BOOLEAN := FALSE;
    l_input_assign_lines                 BOOLEAN := FALSE;
    l_item_check_cus                     BOOLEAN := FALSE;
    l_comp_class_tab                     WSH_UTIL_CORE.Column_Tab_Type;
    l_detail_rec                         detail_ccinfo_rec_type;
    l_line_group_rec                     WSH_FTE_COMP_CONSTRAINT_PKG.line_group_rec_type;
    l_linegroup_rec                      WSH_FTE_COMP_CONSTRAINT_PKG.cc_group_rec_type;
    l_failed_constraint                  line_constraint_rec_type;
    l_failed_constraints                 line_constraint_tab_type;
    l_entity_tab                         entity_tab_type;
    l_target_rec                         entity_rec_type;
    l_validate_itmin_result              VARCHAR2(1);
    l_inp_items_cnt                      NUMBER := 0;
    l_validate_itmfacin_result           VARCHAR2(1) := 'S';
    l_items_tab                          item_tab_type;
    l_locations_list                     WSH_UTIL_CORE.id_tab_type;
    l_supp_control_tab                   WSH_UTIL_CORE.id_tab_type;
    l_target_delivery                    delivery_ccinfo_rec_type;
    l_target_container                   detail_ccinfo_rec_type;
    l_del_detail_info                    detail_ccinfo_tab_type;
    l_dlvy_assigned_lines                detail_ccinfo_tab_type;
    l_dummy_assigned_lines               detail_ccinfo_tab_type;
    l_target_tripstops                   target_tripstop_cc_rec_type;

    --#DUM_LOC(S)
    l_physical_location_id		 NUMBER;
    --#DUM_LOC(E)

    g_invalid_action_code                EXCEPTION;
    g_invalid_input                      EXCEPTION;
    l_debug_on                           CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
    l_module_name                        CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'validate_constraint_dlvb';

BEGIN

    x_validate_result := 'S'; --  Constraint Validation result : S / F
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    g_itm_mustuse_cache.DELETE;
    g_itmloc_mustuse_cache.DELETE;
    g_itm_exclusive_cache.DELETE;
    g_fac_exclusive_cache.DELETE;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
    END IF;

    IF l_debug_on THEN
        wsh_debug_sv.push(l_module_name);
        WSH_DEBUG_SV.logmsg(l_module_name,'p_init_msg_list : '||p_init_msg_list);
    END IF;

    -- Action codes : ACD, ADD, PKG
    -- Assumes p_comp_class_tab and p_exception_list are indexed by
    -- compatibility class codes

    IF p_action_code NOT IN (G_AUTOCRT_DLVY,G_PACK_DLVB,G_ASSIGN_DLVB_DLVY) OR
       p_action_code IS NULL THEN
       RAISE g_invalid_action_code;
    END IF;

    refresh_cache(l_return_status);

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
    END IF;

    IF NOT p_exception_list.EXISTS(G_CUSTOMER_CUSTOMER_NUM) THEN
     l_comp_class_tab(G_CUSTOMER_CUSTOMER_NUM) := G_CUSTOMER_CUSTOMER;
    END IF;
     -- 12/17 : For now packing will not conside item - car/mod for grouping
    IF p_action_code IN (G_AUTOCRT_DLVY,G_ASSIGN_DLVB_DLVY) THEN
       IF NOT p_exception_list.EXISTS(G_ITEM_MODE_NUM) THEN
        l_comp_class_tab(G_ITEM_MODE_NUM) := G_ITEM_MODE;
       END IF;
       IF NOT p_exception_list.EXISTS(G_ITEM_CARRIER_NUM) THEN
        l_comp_class_tab(G_ITEM_CARRIER_NUM) := G_ITEM_CARRIER;
       END IF;
       IF NOT p_exception_list.EXISTS(G_ITEM_VEHICLE_NUM) THEN
        l_comp_class_tab(G_ITEM_VEHICLE_NUM) := G_ITEM_VEHICLE;
       END IF;
       IF NOT p_exception_list.EXISTS(G_ITEM_FACILITY_NUM) THEN
        l_comp_class_tab(G_ITEM_FACILITY_NUM) := G_ITEM_FACILITY;
       END IF;
     -- Assign delivery details to delivery
     -- does not update any grouping attributes for the delivery AS 10/18
     -- What about packing a detail to a container ?

       IF NOT p_exception_list.EXISTS(G_FACILITY_MODE_NUM) THEN
        l_comp_class_tab(G_FACILITY_MODE_NUM) := G_FACILITY_MODE;
       END IF;
       IF NOT p_exception_list.EXISTS(G_FACILITY_CARRIER_NUM) THEN
        l_comp_class_tab(G_FACILITY_CARRIER_NUM) := G_FACILITY_CARRIER;
       END IF;
       IF NOT p_exception_list.EXISTS(G_FACILITY_VEHICLE_NUM) THEN
        l_comp_class_tab(G_FACILITY_VEHICLE_NUM) := G_FACILITY_VEHICLE;
       END IF;
       IF NOT p_exception_list.EXISTS(G_SHIPORG_FACILITY_NUM) THEN
        l_comp_class_tab(G_SHIPORG_FACILITY_NUM) := G_SHIPORG_FACILITY;
       END IF;
       IF NOT p_exception_list.EXISTS(G_CUSTOMER_FACILITY_NUM) THEN
        l_comp_class_tab(G_CUSTOMER_FACILITY_NUM) := G_CUSTOMER_FACILITY;
       END IF;
       IF NOT p_exception_list.EXISTS(G_SUPPLIER_FACILITY_NUM) THEN
        l_comp_class_tab(G_SUPPLIER_FACILITY_NUM) := G_SUPPLIER_FACILITY;
       END IF;
    END IF;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'After populating l_comp_class_tab count : '||l_comp_class_tab.COUNT);
    END IF;
    --
    -- Populate l_del_detail_info

    IF p_del_detail_info.COUNT = 0 THEN
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Passed p_in_ids count : '||p_in_ids.COUNT);
      END IF;
      --

      i := p_in_ids.FIRST;

      IF i IS NOT NULL THEN
        LOOP
           OPEN c_get_line_details(p_in_ids(i));
           FETCH c_get_line_details into l_del_detail_info(i);
           CLOSE c_get_line_details;

           --#DUM_LOC(S)
	   WSH_LOCATIONS_PKG.CONVERT_INTERNAL_CUST_LOCATION(
	      p_internal_cust_location_id  => l_del_detail_info(i).ship_to_location_id,
              x_internal_org_location_id   => l_physical_location_id,
              x_return_status              => l_return_status);

 	   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	     IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
	        raise FND_API.G_EXC_UNEXPECTED_ERROR;
	     END IF;
    	   END IF;

  	   IF (l_physical_location_id IS NOT NULL) THEN
  	      --
	      IF l_debug_on THEN
		  WSH_DEBUG_SV.logmsg(l_module_name,'Location '||l_del_detail_info(i).ship_to_location_id||' is a dummy location');
	      END IF;
	      --
	      l_del_detail_info(i).ship_to_location_id:= l_physical_location_id;
              -- AGDUMMY TODO
              l_del_detail_info(i).physical_ship_to_location_id:= l_physical_location_id;
	   END IF;
           --#DUM_LOC(E)

	   OPEN  c_getdelivery(p_in_ids(i));
           FETCH c_getdelivery into l_del_detail_info(i).DELIVERY_ID;
           CLOSE c_getdelivery;

           EXIT WHEN i = p_in_ids.LAST;
           i := p_in_ids.NEXT(i);

        END LOOP;
      END IF;

    ELSE
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Passed p_del_detail_info count : '||p_del_detail_info.COUNT);
      END IF;
      --

      i := p_del_detail_info.FIRST;
      IF i IS NOT NULL THEN
        LOOP

          l_del_detail_info(i).DELIVERY_DETAIL_ID          := p_del_detail_info(i).DELIVERY_DETAIL_ID;
          l_del_detail_info(i).DELIVERY_ID                 := p_del_detail_info(i).DELIVERY_ID;
          l_del_detail_info(i).exists_in_database          := p_del_detail_info(i).exists_in_database;
          l_del_detail_info(i).CUSTOMER_ID                 := p_del_detail_info(i).CUSTOMER_ID;
          l_del_detail_info(i).INVENTORY_ITEM_ID           := p_del_detail_info(i).INVENTORY_ITEM_ID;
          l_del_detail_info(i).RELEASED_STATUS             := p_del_detail_info(i).RELEASED_STATUS;
          l_del_detail_info(i).DATE_REQUESTED              := p_del_detail_info(i).DATE_REQUESTED;
          l_del_detail_info(i).SHIP_FROM_LOCATION_ID       := p_del_detail_info(i).SHIP_FROM_LOCATION_ID;
          l_del_detail_info(i).SHIP_TO_LOCATION_ID         := p_del_detail_info(i).SHIP_TO_LOCATION_ID;
          l_del_detail_info(i).DATE_SCHEDULED              := p_del_detail_info(i).DATE_SCHEDULED;
          l_del_detail_info(i).CONTAINER_FLAG              := p_del_detail_info(i).CONTAINER_FLAG;
          l_del_detail_info(i).INTMED_SHIP_TO_LOCATION_ID  := p_del_detail_info(i).INTMED_SHIP_TO_LOCATION_ID;
          l_del_detail_info(i).SHIP_METHOD_CODE            := p_del_detail_info(i).SHIP_METHOD_CODE;
          l_del_detail_info(i).CARRIER_ID                  := p_del_detail_info(i).CARRIER_ID;
          l_del_detail_info(i).PARTY_ID                    := p_del_detail_info(i).PARTY_ID;
          l_del_detail_info(i).LINE_DIRECTION              := p_del_detail_info(i).LINE_DIRECTION;
          l_del_detail_info(i).SHIPPING_CONTROL            := nvl(p_del_detail_info(i).SHIPPING_CONTROL,'BUYER');
          l_del_detail_info(i).ORGANIZATION_ID             := p_del_detail_info(i).ORGANIZATION_ID;

	  --#DUM_LOC(S)
	  WSH_LOCATIONS_PKG.CONVERT_INTERNAL_CUST_LOCATION(
	      p_internal_cust_location_id  => l_del_detail_info(i).ship_to_location_id,
              x_internal_org_location_id   => l_physical_location_id,
              x_return_status              => l_return_status);

 	  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
	       raise FND_API.G_EXC_UNEXPECTED_ERROR;
	    END IF;
    	  END IF;

  	  IF (l_physical_location_id IS NOT NULL) THEN
  	      --
	      IF l_debug_on THEN
		  WSH_DEBUG_SV.logmsg(l_module_name,'Location '||l_del_detail_info(i).ship_to_location_id||' is a dummy location');
	      END IF;
	      --
	      l_del_detail_info(i).ship_to_location_id:= l_physical_location_id;
              -- AGDUMMY TODO
              l_del_detail_info(i).physical_ship_to_location_id:= l_physical_location_id;
	  END IF;
	  --#DUM_LOC(E)

          EXIT WHEN i = p_del_detail_info.LAST;
          i := p_del_detail_info.NEXT(i);

        END LOOP;
      END IF;

    END IF;

    IF p_target_delivery.delivery_id IS NOT NULL THEN

       OPEN c_get_dlvy(p_target_delivery.delivery_id);
       FETCH c_get_dlvy into l_target_delivery;
       CLOSE c_get_dlvy;

       --#DUM_LOC(S)
       WSH_LOCATIONS_PKG.CONVERT_INTERNAL_CUST_LOCATION(
          p_internal_cust_location_id  => l_target_delivery.ultimate_dropoff_location_id,
          x_internal_org_location_id   => l_physical_location_id,
          x_return_status              => l_return_status);

       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
	       raise FND_API.G_EXC_UNEXPECTED_ERROR;
	    END IF;
       END IF;

       IF (l_physical_location_id IS NOT NULL) THEN
  	  --
	  IF l_debug_on THEN
	     WSH_DEBUG_SV.logmsg(l_module_name,'Location '||l_target_delivery.ultimate_dropoff_location_id||' is a dummy location');
	  END IF;
	  --
	 l_target_delivery.ultimate_dropoff_location_id := l_physical_location_id;
         -- AGDUMMY TODO
         l_target_delivery.physical_dropoff_location_id := l_physical_location_id;
       END IF;
       --#DUM_LOC(E)

     ELSIF p_target_container.delivery_detail_id IS NOT NULL THEN

	--#DUM_LOC(Q) Do we change for containers.
        --Verify.
        -- Yes

       OPEN c_get_line_details(p_target_container.delivery_detail_id);
       FETCH c_get_line_details into l_target_container;
       CLOSE c_get_line_details;

	--#DUM_LOC(S)
       WSH_LOCATIONS_PKG.CONVERT_INTERNAL_CUST_LOCATION(
	  p_internal_cust_location_id  => l_target_container.ship_to_location_id,
          x_internal_org_location_id   => l_physical_location_id,
          x_return_status              => l_return_status);

       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
	    raise FND_API.G_EXC_UNEXPECTED_ERROR;
	  END IF;
       END IF;

       IF (l_physical_location_id IS NOT NULL) THEN
  	    --
	    IF l_debug_on THEN
	       WSH_DEBUG_SV.logmsg(l_module_name,'Location '||l_target_container.ship_to_location_id||' is a dummy location');
	    END IF;
	    --
	    l_target_container.ship_to_location_id:= l_physical_location_id;
            -- AGDUMMY TODO
            l_target_container.physical_ship_to_location_id := l_physical_location_id;
       END IF;
       --#DUM_LOC(E)
    END IF;


    IF p_dlvy_assigned_lines.COUNT = 0 THEN
     IF ( l_target_delivery.delivery_id IS NOT NULL
       AND l_target_delivery.exists_in_database = 'Y') THEN
	      --
          --  has been passed
          IF l_target_delivery.delivery_type = 'STANDARD' THEN
              OPEN c_get_details(l_target_delivery.delivery_id); -- or container_id
              LOOP
                   FETCH c_get_details INTO l_detail_rec;
                   EXIT WHEN c_get_details%NOTFOUND;

               --#DUM_LOC(S)
                   WSH_LOCATIONS_PKG.CONVERT_INTERNAL_CUST_LOCATION(
                       p_internal_cust_location_id  => l_detail_rec.ship_to_location_id,
                       x_internal_org_location_id   => l_physical_location_id,
                       x_return_status              => l_return_status);

               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                   raise FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;
                   END IF;

               IF (l_physical_location_id IS NOT NULL) THEN
             --
                 IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Location '||l_detail_rec.ship_to_location_id||' is a dummy location');
                 END IF;
                 --
                 l_detail_rec.ship_to_location_id:= l_physical_location_id;
                     -- AGDUMMY TODO
                     l_detail_rec.physical_ship_to_location_id := l_physical_location_id;
               END IF;
                   --#DUM_LOC(E)
                   l_assigned_line_cnt := l_assigned_line_cnt + 1;
                   l_dlvy_assigned_lines(l_assigned_line_cnt) := l_detail_rec;
              END LOOP;
              CLOSE c_get_details;
          ELSE
              OPEN c_get_details_consol(l_target_delivery.delivery_id); -- or container_id
              LOOP
                   FETCH c_get_details_consol INTO l_detail_rec;
                   EXIT WHEN c_get_details%NOTFOUND;

               --#DUM_LOC(S)
                   WSH_LOCATIONS_PKG.CONVERT_INTERNAL_CUST_LOCATION(
                       p_internal_cust_location_id  => l_detail_rec.ship_to_location_id,
                       x_internal_org_location_id   => l_physical_location_id,
                       x_return_status              => l_return_status);

               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                   raise FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;
                   END IF;

               IF (l_physical_location_id IS NOT NULL) THEN
             --
                 IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Location '||l_detail_rec.ship_to_location_id||' is a dummy location');
                 END IF;
                 --
                 l_detail_rec.ship_to_location_id:= l_physical_location_id;
                     -- AGDUMMY TODO
                     l_detail_rec.physical_ship_to_location_id := l_physical_location_id;
               END IF;
                   --#DUM_LOC(E)
                   l_assigned_line_cnt := l_assigned_line_cnt + 1;
                   l_dlvy_assigned_lines(l_assigned_line_cnt) := l_detail_rec;
              END LOOP;
              CLOSE c_get_details_consol;
          END IF;
          ---
     ELSIF ( l_target_container.delivery_detail_id IS NOT NULL
          AND l_target_container.exists_in_database = 'Y') THEN  --  Check to see if target delivery/contain.

          OPEN c_get_assigned_lines_cont(l_target_container.delivery_detail_id); -- or container_id
          LOOP
               FETCH c_get_assigned_lines_cont INTO l_detail_rec;
               EXIT WHEN c_get_assigned_lines_cont%NOTFOUND;

	       --#DUM_LOC(S)
	       WSH_LOCATIONS_PKG.CONVERT_INTERNAL_CUST_LOCATION(
	           p_internal_cust_location_id  => l_detail_rec.ship_to_location_id,
                   x_internal_org_location_id   => l_physical_location_id,
                   x_return_status              => l_return_status);

 	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
	           raise FND_API.G_EXC_UNEXPECTED_ERROR;
	         END IF;
    	       END IF;

  	       IF (l_physical_location_id IS NOT NULL) THEN
  		 --
	         IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Location '||l_detail_rec.ship_to_location_id||' is a dummy location');
	         END IF;
	         --
	        l_detail_rec.ship_to_location_id:= l_physical_location_id;
                -- AGDUMMY TODO
                l_detail_rec.physical_ship_to_location_id := l_physical_location_id;
	       END IF;
               --#DUM_LOC(E)

	       l_assigned_line_cnt := l_assigned_line_cnt + 1;
               l_dlvy_assigned_lines(l_assigned_line_cnt) := l_detail_rec;
          END LOOP;
          CLOSE c_get_assigned_lines_cont;
     END IF;
     --
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Created l_dlvy_assigned_lines count : '||l_dlvy_assigned_lines.COUNT);
     END IF;
     --
    ELSE
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Passed p_dlvy_assigned_lines count : '||p_dlvy_assigned_lines.COUNT);
      END IF;
      --

      i := p_dlvy_assigned_lines.FIRST;
      IF i IS NOT NULL THEN
        LOOP

               l_dlvy_assigned_lines(i).delivery_detail_id := p_dlvy_assigned_lines(i).delivery_detail_id;
               l_dlvy_assigned_lines(i).delivery_id := p_dlvy_assigned_lines(i).delivery_id;
               l_dlvy_assigned_lines(i).exists_in_database := p_dlvy_assigned_lines(i).exists_in_database;
               l_dlvy_assigned_lines(i).CUSTOMER_ID := p_dlvy_assigned_lines(i).CUSTOMER_ID;
               l_dlvy_assigned_lines(i).INVENTORY_ITEM_ID := p_dlvy_assigned_lines(i).INVENTORY_ITEM_ID;
               l_dlvy_assigned_lines(i).SHIP_FROM_LOCATION_ID := p_dlvy_assigned_lines(i).SHIP_FROM_LOCATION_ID;
               l_dlvy_assigned_lines(i).ORGANIZATION_ID := p_dlvy_assigned_lines(i).ORGANIZATION_ID;
               l_dlvy_assigned_lines(i).SHIP_TO_LOCATION_ID := p_dlvy_assigned_lines(i).SHIP_TO_LOCATION_ID;
               l_dlvy_assigned_lines(i).INTMED_SHIP_TO_LOCATION_ID := p_dlvy_assigned_lines(i).INTMED_SHIP_TO_LOCATION_ID;
               l_dlvy_assigned_lines(i).RELEASED_STATUS := p_dlvy_assigned_lines(i).RELEASED_STATUS;
               l_dlvy_assigned_lines(i).CONTAINER_FLAG := p_dlvy_assigned_lines(i).CONTAINER_FLAG;
               l_dlvy_assigned_lines(i).DATE_REQUESTED  := p_dlvy_assigned_lines(i).DATE_REQUESTED;
               l_dlvy_assigned_lines(i).DATE_SCHEDULED := p_dlvy_assigned_lines(i).DATE_SCHEDULED;
               l_dlvy_assigned_lines(i).SHIP_METHOD_CODE := p_dlvy_assigned_lines(i).SHIP_METHOD_CODE;
               l_dlvy_assigned_lines(i).CARRIER_ID := p_dlvy_assigned_lines(i).CARRIER_ID;
               l_dlvy_assigned_lines(i).PARTY_ID := p_dlvy_assigned_lines(i).PARTY_ID;
               l_dlvy_assigned_lines(i).LINE_DIRECTION := p_dlvy_assigned_lines(i).LINE_DIRECTION;
               l_dlvy_assigned_lines(i).SHIPPING_CONTROL := nvl(p_dlvy_assigned_lines(i).SHIPPING_CONTROL,'BUYER');

               --#DUM_LOC(S)
	       WSH_LOCATIONS_PKG.CONVERT_INTERNAL_CUST_LOCATION(
	           p_internal_cust_location_id  => l_dlvy_assigned_lines(i).ship_to_location_id,
                   x_internal_org_location_id   => l_physical_location_id,
                   x_return_status              => l_return_status);

 	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	          IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
	              raise FND_API.G_EXC_UNEXPECTED_ERROR;
	          END IF;
    	       END IF;

               IF (l_physical_location_id IS NOT NULL) THEN
  	          --
	          IF l_debug_on THEN
		     WSH_DEBUG_SV.logmsg(l_module_name,'Location '||l_dlvy_assigned_lines(i).ship_to_location_id||' is a dummy location');
   	          END IF;
	          --
	          l_dlvy_assigned_lines(i).ship_to_location_id:= l_physical_location_id;
                  -- AGDUMMY TODO
                  l_dlvy_assigned_lines(i).physical_ship_to_location_id := l_physical_location_id;
	       END IF;
               --#DUM_LOC(E)

	       EXIT WHEN i = p_dlvy_assigned_lines.LAST;
               i := p_dlvy_assigned_lines.NEXT(i);

        END LOOP;
      END IF;

    END IF;

     --  As per meeting on 10/18 : IGNORE GROUPING CRITERIA and do checks independently
     --  framework APIs will be called just before calling action appropriate private APIs

     -- The group line rec should have item and customer populated with the value of the first line
     -- For each subsequent line, check those with these values,
     -- if match, add to this group, if does not, create a new one
     -- ( The following checks are required for ACD )
     -- If WSH does not default from line to delivery,
     -- 1. any line that has violating item against its intmed ship to, ship method and last 2  being
     -- YES in grp crit, should error
     -- 2. any line that has violating ship from, ship to against ship method with ship method
     -- being YES in grp crit, should error
     -- 3. any line that has violating intmed ship to against ship method with both being
     -- YES in grp crit, should error
     -- 4. any line that has violating org, cus against its intmed ship to and last 1  being
     -- YES in grp crit, should error
     -- These 4 errors can be resolved by passing a hint to WSH that, even if grp crt is YES,
     -- do not default

     -- ( The following checks are required for ADD )
     -- For ADD returns whether 1. All input lines can be assigned to the target delivery
     -- If not, 2.Group of input lines how they can be grouped to create delivery
     -- 3. Input lines which can be assigned to the target delivery (line_group_id = delivery_id)
     -- Group input lines by item - item, cus - cus constraints first
     -- For each detail, find out if item satisfies delivery mode, carrier,intmed ship to
     -- and customer satisfies delivery customer / delivery already existing customers
     -- and item satisfies delivery already existing items


    j := l_del_detail_info.FIRST;
    IF j IS NOT NULL THEN
      LOOP

         -- Skip if SHIPPING_CONTROL is SUPPLIER

         IF l_del_detail_info(j).shipping_control = 'SUPPLIER' THEN

            l_supp_control_tab(l_del_detail_info(j).delivery_detail_id) := l_del_detail_info(j).delivery_detail_id;
            GOTO detail_nextpass;

         END IF;

         l_mode := null;
         l_service_level := NULL;
         l_carrier := null;
         l_intmed_location_id := null;
         l_group_id         :=0;
         l_found            := FALSE;
         l_failed_line_added := FALSE;

         l_validate_itmin_result    := 'S';
         l_validate_carrier_result  := 'S';
         l_validate_customer_result := 'S';
         l_validate_mode_result    := 'S';
         l_validate_intmed_result    := 'S';
         l_items_tab.DELETE;
         l_locations_list.DELETE;

         l_inp_items_cnt := l_items_tab.COUNT;
         l_items_tab(l_inp_items_cnt + 1).line_id := l_del_detail_info(j).delivery_detail_id;
         l_items_tab(l_inp_items_cnt + 1).item_id := l_del_detail_info(j).inventory_item_id;
         l_items_tab(l_inp_items_cnt + 1).org_id  := l_del_detail_info(j).organization_id;

         l_locations_list(l_locations_list.COUNT + 1) := l_del_detail_info(j).ship_from_location_id;
         l_locations_list(l_locations_list.COUNT + 1) := l_del_detail_info(j).ship_to_location_id;

         search_itm_fac_incl(
                     p_comp_class_tab      =>     l_comp_class_tab,
                     p_entity_type         =>     G_DEL_DETAIL,
                     p_entity_id           =>     l_del_detail_info(j).delivery_detail_id,
                     p_items_tab           =>     l_items_tab,
                     p_locations_list      =>     l_locations_list,
                     x_validate_result     =>     l_validate_itmfacin_result,
                     x_failed_constraints  =>     l_failed_constraints,
                     x_return_status       =>     l_return_status);

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;

         IF l_validate_itmfacin_result = 'F' THEN
                   IF NOT l_failed_line_added THEN
                     -- Discard line (detail) from this group
                     -- populate failed lines
                     l_failed_lc := l_failed_lc + 1;
                     x_failed_lines(l_failed_lc).entity_line_id := l_del_detail_info(j).delivery_detail_id;
                     x_failed_lines(l_failed_lc).failed_line_index := l_failed_lc;
                     l_failed_line_added := TRUE;
                   END IF;
             GOTO detail_nextpass;
         END IF;

         l_entity_tab(l_del_detail_info(j).delivery_detail_id).entity_id := l_del_detail_info(j).delivery_detail_id;
         l_entity_tab(l_del_detail_info(j).delivery_detail_id).organization_id := l_del_detail_info(j).organization_id;
         l_entity_tab(l_del_detail_info(j).delivery_detail_id).inventory_item_id := l_del_detail_info(j).inventory_item_id;
         l_entity_tab(l_del_detail_info(j).delivery_detail_id).customer_id := l_del_detail_info(j).customer_id;
         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Created l_entity_tab with index : '||l_del_detail_info(j).delivery_detail_id||' for detail index '||j);
         END IF;
         --

         IF j <> l_del_detail_info.FIRST THEN

            search_matching_group(
                  p_entity_type           => 'DLVB',
                  p_action_code           => p_action_code,
                  p_children_info         => l_dummy_assigned_lines,
                  p_comp_class_tab        => l_comp_class_tab,
                  p_target_stops_info     => l_target_tripstops,
                  p_entity_rec            => l_entity_tab(l_del_detail_info(j).delivery_detail_id),
                  p_entity_tab            => l_entity_tab, -- IN
                  p_group_tab             => x_group_info, -- IN
                  x_failed_constraints    => l_failed_constraints, -- IN OUT NOCOPY
                  x_group_id              => l_group_id, -- OUT
                  x_found                 => l_found, -- OUT
                  x_return_status         => l_return_status);
            --
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Called search_matching_group return status : '||l_return_status||' Group found ? '||l_group_id);
            END IF;
            --

            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                  raise FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            END IF;

         END IF; -- FIRST

         IF l_found THEN
               l_entity_tab(l_del_detail_info(j).delivery_detail_id).group_id := l_group_id;
               --
               IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Adding detail : '||l_del_detail_info(j).delivery_detail_id||' to_group : '||l_group_id);
               END IF;
               --
         ELSE
              create_valid_entity_group(
                  p_entity_rec    => l_entity_tab(l_del_detail_info(j).delivery_detail_id),
                  p_group_tab     => x_group_info, -- IN OUT
                  x_return_status => l_return_status);
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Called create_valid_entity_group return status : '||l_return_status);
              END IF;
              --

              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                     raise FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;
              END IF;
         END IF;

         -- Populate x_line_groups table with l_entity_tab(l_del_detail_info(j).delivery_detail_id)

         -- Populate x_line_groups table
         l_linegroup_indx := l_linegroup_indx + 1;
         x_line_groups(l_linegroup_indx).line_group_index := l_linegroup_indx;
         x_line_groups(l_linegroup_indx).entity_line_id   := l_del_detail_info(j).delivery_detail_id;
         x_line_groups(l_linegroup_indx).line_group_id   := l_entity_tab(l_del_detail_info(j).delivery_detail_id).group_id;


         -- Groups have already been created at this point x_group_info
         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Current detail is in x_group_info with group id : '||l_entity_tab(l_del_detail_info(j).delivery_detail_id).group_id);
         END IF;
         --
         --  END : Potential method to group details
         --  Returns valid groups of input lines

         -- If PKG with no target container
         -- go to next pass here

         IF (p_action_code = G_PACK_DLVB AND l_target_container.delivery_detail_id IS NULL) THEN
            GOTO detail_nextpass;
         END IF;

         --  START : Potential method to compare input details with target dlvy lines as per
         --  ITM - ITM and CUS - CUS constraints

         IF p_action_code = G_ASSIGN_DLVB_DLVY THEN
           IF l_comp_class_tab.EXISTS(G_CUSTOMER_CUSTOMER_NUM) AND
              l_target_delivery.customer_id <> l_del_detail_info(j).customer_id THEN

             l_item_check_cus := TRUE;

             validate_constraint(
                    p_comp_class_code          =>      G_CUSTOMER_CUSTOMER,
                    p_object1_val_num          =>      l_target_delivery.customer_id,
                    p_object2_val_num          =>      l_del_detail_info(j).customer_id,
                    x_validate_result          =>      l_validate_customer_result,
                    x_failed_constraint        =>      l_failed_constraint,
                    x_return_status            =>      l_return_status);

             IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                  raise FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
             END IF;

             IF l_validate_customer_result <> 'S' THEN
              l_failed_constraint.line_constraint_index := l_failed_constraints.COUNT+1;
              l_failed_constraint.entity_type :=  G_DEL_DETAIL;
              l_failed_constraint.entity_line_id :=  l_del_detail_info(j).delivery_detail_id;
              l_failed_constraints(l_failed_constraints.COUNT+1) := l_failed_constraint;
              IF l_validate_customer_result = 'E' THEN
                   l_validate_result := 'E';
                   IF NOT l_failed_line_added THEN
                     x_line_groups.DELETE(l_linegroup_indx);
                     -- Discard line (detail) from this group
                     -- populate failed lines
                     l_failed_lc := l_failed_lc + 1;
                     x_failed_lines(l_failed_lc).entity_line_id := l_del_detail_info(j).delivery_detail_id;
                     x_failed_lines(l_failed_lc).failed_line_index := l_failed_lc;
                     l_failed_line_added := TRUE;
                   END IF;
              END IF;

             END IF;
             l_item_check_cus := FALSE;

            END IF;

         END IF;

         IF (p_action_code = G_PACK_DLVB) OR
            (p_action_code = G_ASSIGN_DLVB_DLVY) THEN

         -- Still need to check itm - itm and/or cus - cus
         -- between input lines and target delivery lines

            k := l_dlvy_assigned_lines.FIRST;

            IF k IS NOT NULL THEN
              LOOP

                  l_item_org_id := l_dlvy_assigned_lines(k).organization_id;
                  l_item_id := l_dlvy_assigned_lines(k).inventory_item_id;
                  l_customer_id := l_dlvy_assigned_lines(k).customer_id;

                  IF l_item_check_cus AND
                     l_del_detail_info(j).customer_id <> l_customer_id THEN

                    validate_constraint(
                      p_comp_class_code          =>      G_CUSTOMER_CUSTOMER,
                      p_object1_val_num          =>      l_del_detail_info(j).customer_id,
                      p_object2_val_num          =>      l_customer_id,
                      x_validate_result          =>      l_validate_customer_result,
                      x_failed_constraint        =>      l_failed_constraint,
                      x_return_status            =>      l_return_status);

                    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN

                          raise FND_API.G_EXC_UNEXPECTED_ERROR;
                       END IF;
                    END IF;

                    IF l_validate_customer_result <> 'S' THEN
                     l_failed_constraint.line_constraint_index := l_failed_constraints.COUNT+1;
                     l_failed_constraint.entity_type :=  G_DEL_DETAIL;
                     l_failed_constraint.entity_line_id :=  l_del_detail_info(j).delivery_detail_id;
                     l_failed_constraints(l_failed_constraints.COUNT+1) := l_failed_constraint;
                         IF l_validate_customer_result = 'E' THEN
                            l_validate_result := 'E';
                          IF NOT l_failed_line_added THEN
                            x_line_groups.DELETE(l_linegroup_indx);
                            -- Discard line (detail) from this group
                            -- populate failed lines
                            l_failed_lc := l_failed_lc + 1;
                            x_failed_lines(l_failed_lc).entity_line_id := l_del_detail_info(j).delivery_detail_id;
                            x_failed_lines(l_failed_lc).failed_line_index := l_failed_lc;
                            l_failed_line_added := TRUE;
                          END IF;
                         END IF;
                    END IF;

                  END IF;

                 -- itm - car/mod must use check between
                 -- p_children_info(l) and p_children_info(m)

                  IF (p_action_code = G_ASSIGN_DLVB_DLVY) THEN

                     l_target_rec.entity_id := l_dlvy_assigned_lines(k).delivery_detail_id;
                     l_target_rec.organization_id := l_dlvy_assigned_lines(k).organization_id;
                     l_target_rec.inventory_item_id := l_dlvy_assigned_lines(k).inventory_item_id;
                     l_target_rec.customer_id := l_dlvy_assigned_lines(k).customer_id;
                     --
                     IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Created l_target_rec for assigned line : '||l_dlvy_assigned_lines(k).delivery_detail_id);
                     END IF;
                     --

                     IF ((l_entity_tab(l_del_detail_info(j).delivery_detail_id).inventory_item_id <> l_target_rec.inventory_item_id) OR
                        (g_is_tp_installed = 'N' AND l_entity_tab(l_del_detail_info(j).delivery_detail_id).organization_id <> l_target_rec.organization_id))  THEN

                     search_group_itm (
                        p_comp_class_tab      =>   l_comp_class_tab,
                        p_entity_rec          =>   l_entity_tab(l_del_detail_info(j).delivery_detail_id),
                        p_target_rec          =>   l_target_rec,
                        x_validate_result     =>   l_validate_itmin_result,
                        x_failed_constraints  =>   l_failed_constraints,
                        x_return_status       =>   l_return_status);

                     IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                           raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                     END IF;

                     IF l_validate_itmin_result = 'F' THEN
                         IF NOT l_failed_line_added THEN
                           x_line_groups.DELETE(l_linegroup_indx);
                           -- Discard line (detail) from this group
                           -- populate failed lines
                           l_failed_lc := l_failed_lc + 1;
                           x_failed_lines(l_failed_lc).entity_line_id := l_del_detail_info(j).delivery_detail_id;
                           x_failed_lines(l_failed_lc).failed_line_index := l_failed_lc;
                           l_failed_line_added := TRUE;
                         END IF;
                         EXIT;
                     END IF;
                     END IF;
                  END IF;

                  EXIT WHEN k = l_dlvy_assigned_lines.LAST;
                  k := l_dlvy_assigned_lines.NEXT(k);

              END LOOP;
            END IF;

            IF l_validate_itmin_result = 'F' THEN
               GOTO detail_nextpass;
            END IF;

         --  END : Potential method to compare input details with target dlvy lines as per
         --  ITM - ITM and CUS - CUS constraints

         END IF;

         IF p_action_code = G_PACK_DLVB OR
            (l_target_delivery.ship_method_code IS NULL AND
             l_target_delivery.carrier_id IS NULL AND
             l_target_delivery.mode_of_transport IS NULL AND
             p_action_code = G_ASSIGN_DLVB_DLVY)
            OR (l_del_detail_info(j).ship_method_code IS NULL AND
                l_del_detail_info(j).carrier_id IS NULL AND
                p_action_code = G_AUTOCRT_DLVY) THEN

            GOTO detail_nextpass;
         END IF;

         IF p_action_code = G_ASSIGN_DLVB_DLVY THEN
           IF l_target_delivery.ship_method_code IS NOT NULL THEN
            l_carrier_service_inout_rec.ship_method_code := l_target_delivery.ship_method_code;
            WSH_CARRIERS_GRP.get_carrier_service_mode(
                     p_carrier_service_inout_rec   =>  l_carrier_service_inout_rec,
                     x_return_status       =>  l_return_status);

               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                  IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
                     raise FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
                  raise g_get_carrmode_failed;
                 END IF;
               END IF;
               l_carrier := l_carrier_service_inout_rec.carrier_id;
               l_mode    := l_carrier_service_inout_rec.mode_of_transport;
           END IF;
           IF l_target_delivery.carrier_id IS NOT NULL THEN
              l_carrier := l_target_delivery.carrier_id;
           END IF;
           IF l_target_delivery.mode_of_transport IS NOT NULL THEN
              l_mode := l_target_delivery.mode_of_transport;
           END IF;
         ELSIF p_action_code = G_AUTOCRT_DLVY THEN
           IF l_del_detail_info(j).ship_method_code IS NOT NULL THEN
            l_carrier_service_inout_rec.ship_method_code := l_del_detail_info(j).ship_method_code;
            WSH_CARRIERS_GRP.get_carrier_service_mode(
                     p_carrier_service_inout_rec   =>  l_carrier_service_inout_rec,
                     x_return_status       =>  l_return_status);

            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
                   raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
                raise g_get_carrmode_failed;
               END IF;
            END IF;
            l_carrier := l_carrier_service_inout_rec.carrier_id;
            l_mode    := l_carrier_service_inout_rec.mode_of_transport;
           END IF;
           IF l_del_detail_info(j).carrier_id IS NOT NULL THEN
               l_carrier := l_del_detail_info(j).carrier_id;
           END IF;
         END IF;

         IF l_comp_class_tab.EXISTS(G_ITEM_CARRIER_NUM) AND l_carrier IS NOT NULL THEN

           validate_constraint(
             p_comp_class_code          =>      G_ITEM_CARRIER,
             p_object1_parent_id        =>      l_del_detail_info(j).organization_id,
             p_object1_val_num          =>      l_del_detail_info(j).inventory_item_id,
             p_object2_val_num          =>      l_carrier,
             x_validate_result          =>      l_validate_carrier_result,
             x_failed_constraint        =>      l_failed_constraint,
             x_return_status            =>      l_return_status);

           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                 raise FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
           END IF;

           IF l_validate_carrier_result <> 'S' THEN
              l_failed_constraint.line_constraint_index := l_failed_constraints.COUNT+1;
              l_failed_constraint.entity_type :=  G_DEL_DETAIL;
              l_failed_constraint.entity_line_id :=  l_del_detail_info(j).delivery_detail_id;
              l_failed_constraints(l_failed_constraints.COUNT+1) := l_failed_constraint;
              IF l_validate_carrier_result = 'E' THEN
               IF p_action_code = G_ASSIGN_DLVB_DLVY THEN
                  l_validate_result := 'E';
                     -- populate failed lines
                  IF NOT l_failed_line_added THEN
                      l_failed_lc := l_failed_lc + 1;
                      x_failed_lines(l_failed_lc).entity_line_id := l_del_detail_info(j).delivery_detail_id;
                      x_failed_lines(l_failed_lc).failed_line_index := l_failed_lc;
                     -- Discard line (detail) from this group
                      x_line_groups.DELETE(l_linegroup_indx);
                      l_failed_line_added := TRUE;
                  END IF;
               END IF;
               x_group_info(l_entity_tab(l_del_detail_info(j).delivery_detail_id).group_id).upd_dlvy_ship_method     := 'N';
              END IF;
           END IF;

         END IF;

         IF l_comp_class_tab.EXISTS(G_ITEM_MODE_NUM) AND l_mode IS NOT NULL THEN

           validate_constraint(
             p_comp_class_code          =>      G_ITEM_MODE,
             p_object1_parent_id        =>      l_del_detail_info(j).organization_id,
             p_object1_val_num          =>      l_del_detail_info(j).inventory_item_id,
             p_object2_val_char         =>      l_mode,
             x_validate_result          =>      l_validate_mode_result,
             x_failed_constraint        =>      l_failed_constraint,
             x_return_status            =>      l_return_status);

           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                 raise FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
           END IF;

           IF l_validate_mode_result <> 'S' THEN
            l_failed_constraint.line_constraint_index := l_failed_constraints.COUNT+1;
            l_failed_constraint.entity_type :=  G_DEL_DETAIL;
            l_failed_constraint.entity_line_id :=  l_del_detail_info(j).delivery_detail_id;
            l_failed_constraints(l_failed_constraints.COUNT+1) := l_failed_constraint;
            IF l_validate_mode_result = 'E' THEN
               IF p_action_code = G_ASSIGN_DLVB_DLVY THEN
                  l_validate_result := 'E';
                     -- populate failed lines
                  IF NOT l_failed_line_added THEN
                      l_failed_lc := l_failed_lc + 1;
                      x_failed_lines(l_failed_lc).entity_line_id := l_del_detail_info(j).delivery_detail_id;
                      x_failed_lines(l_failed_lc).failed_line_index := l_failed_lc;
                     -- Discard line (detail) from this group
                      x_line_groups.DELETE(l_linegroup_indx);
                      l_failed_line_added := TRUE;
                  END IF;
               END IF;
               x_group_info(l_entity_tab(l_del_detail_info(j).delivery_detail_id).group_id).upd_dlvy_ship_method     := 'N';
            END IF;
           END IF;

         END IF;

         IF p_action_code = G_ASSIGN_DLVB_DLVY THEN
            GOTO detail_nextpass;
         END IF;
         IF l_carrier IS NOT NULL THEN

           IF l_comp_class_tab.EXISTS(G_FACILITY_CARRIER_NUM) THEN
              validate_constraint(
                 p_comp_class_code          =>      G_FACILITY_CARRIER,
                 p_object1_type             =>      'FAC',
                 p_object1_val_num          =>      l_del_detail_info(j).ship_from_location_id,
                 p_object2_val_num          =>      l_carrier,
                 x_validate_result          =>      l_validate_carrier_result,
                 x_failed_constraint        =>      l_failed_constraint,
                 x_return_status            =>      l_return_status);

               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                     raise FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
               END IF;

               IF l_validate_carrier_result <> 'S' THEN
                l_failed_constraint.line_constraint_index := l_failed_constraints.COUNT+1;
                l_failed_constraint.entity_type :=  G_DEL_DETAIL;
                l_failed_constraint.entity_line_id :=  l_del_detail_info(j).delivery_detail_id;
                l_failed_constraints(l_failed_constraints.COUNT+1) := l_failed_constraint;
                IF l_validate_carrier_result = 'E' THEN
                   x_group_info(l_entity_tab(l_del_detail_info(j).delivery_detail_id).group_id).upd_dlvy_ship_method     := 'N';
                END IF;
               END IF;

             -- If ship to location is also assumed to be customer site
             -- then need to check constraint with object1_type = CUSTOMER as well
               validate_constraint(
                 p_comp_class_code          =>      G_FACILITY_CARRIER,
                 p_object1_type             =>      'FAC',
                 p_object1_val_num          =>      l_del_detail_info(j).ship_to_location_id,
                 p_object2_val_num          =>      l_carrier,
                 x_validate_result          =>      l_validate_carrier_result,
                 x_failed_constraint        =>      l_failed_constraint,
                 x_return_status            =>      l_return_status);

               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                     raise FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
               END IF;

               IF l_validate_carrier_result <> 'S' THEN
                l_failed_constraint.line_constraint_index := l_failed_constraints.COUNT+1;
                l_failed_constraint.entity_type :=  G_DEL_DETAIL;
                l_failed_constraint.entity_line_id :=  l_del_detail_info(j).delivery_detail_id;
                l_failed_constraints(l_failed_constraints.COUNT+1) := l_failed_constraint;
                IF l_validate_carrier_result = 'E' THEN
                   -- populate failed lines
                   x_group_info(l_entity_tab(l_del_detail_info(j).delivery_detail_id).group_id).upd_dlvy_ship_method     := 'N';
                END IF;
               END IF;

           END IF;
         END IF; -- l_carrier

         IF l_mode IS NOT NULL THEN

           IF l_comp_class_tab.EXISTS(G_FACILITY_MODE_NUM) THEN

               validate_constraint(
                 p_comp_class_code          =>      G_FACILITY_MODE,
                 p_object1_type             =>      'FAC',
                 p_object1_val_num          =>      l_del_detail_info(j).ship_from_location_id,
                 p_object2_val_char         =>      l_mode,
                 x_validate_result          =>      l_validate_mode_result,
                 x_failed_constraint        =>      l_failed_constraint,
                 x_return_status            =>      l_return_status);

               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                     raise FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
               END IF;

               IF l_validate_mode_result <> 'S' THEN
                l_failed_constraint.line_constraint_index := l_failed_constraints.COUNT+1;
                l_failed_constraint.entity_type :=  G_DEL_DETAIL;
                l_failed_constraint.entity_line_id :=  l_del_detail_info(j).delivery_detail_id;
                l_failed_constraints(l_failed_constraints.COUNT+1) := l_failed_constraint;
                IF l_validate_mode_result = 'E' THEN
                         -- populate failed lines
                   x_group_info(l_entity_tab(l_del_detail_info(j).delivery_detail_id).group_id).upd_dlvy_ship_method     := 'N';
                END IF;
               END IF;

               validate_constraint(
                 p_comp_class_code          =>      G_FACILITY_MODE,
                 p_object1_type             =>      'FAC',
                 p_object1_val_num          =>      l_del_detail_info(j).ship_to_location_id,
                 p_object2_val_char         =>      l_mode,
                 x_validate_result          =>      l_validate_mode_result,
                 x_failed_constraint        =>      l_failed_constraint,
                 x_return_status            =>      l_return_status);

               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                     raise FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
               END IF;

               IF l_validate_mode_result <> 'S' THEN
                l_failed_constraint.line_constraint_index := l_failed_constraints.COUNT+1;
                l_failed_constraint.entity_type :=  G_DEL_DETAIL;
                l_failed_constraint.entity_line_id :=  l_del_detail_info(j).delivery_detail_id;
                l_failed_constraints(l_failed_constraints.COUNT+1) := l_failed_constraint;
                IF l_validate_mode_result = 'E' THEN
                         -- populate failed lines
                   x_group_info(l_entity_tab(l_del_detail_info(j).delivery_detail_id).group_id).upd_dlvy_ship_method     := 'N';
                END IF;
               END IF;

           END IF;
         END IF; -- l_mode

         <<detail_nextpass>>

         EXIT WHEN j = l_del_detail_info.LAST;
         j := l_del_detail_info.NEXT(j);
      END LOOP;
    END IF;

    IF l_supp_control_tab.COUNT > 0 THEN

        -- Populate line_groups and group

        -- Add to x_group_info
        l_group_count := x_group_info.COUNT + 1;
        x_group_info(l_group_count).group_index := l_group_count;
        x_group_info(l_group_count).line_group_id := l_group_count;

        i := l_supp_control_tab.FIRST;
        LOOP

           -- Populate x_line_groups table
           l_linegroup_indx := x_line_groups.COUNT + 1;
           x_line_groups(l_linegroup_indx).line_group_index := l_linegroup_indx;
           x_line_groups(l_linegroup_indx).entity_line_id   := l_supp_control_tab(i);
           x_line_groups(l_linegroup_indx).line_group_id    := l_group_count;

           EXIT WHEN i=l_supp_control_tab.LAST;
           i := l_supp_control_tab.NEXT(i);
        END LOOP;

    END IF;

    -- Populate x_validate_result
    IF x_group_info.COUNT > 1 OR x_failed_lines.COUNT > 0 THEN
        x_validate_result := 'F';
        IF x_group_info.COUNT > 1 AND p_action_code = G_ASSIGN_DLVB_DLVY THEN
           -- Put all input lines in incompatible groups into failed lines

           -- After changing the logic to form groups in case of
           -- assign, the following list of groups will only contain
           -- mutually incompatible groups
           -- not the always successful groups
           i := x_group_info.FIRST;
           LOOP

             -- Will not delete these lines from linegroups
             -- Hence for this case the sum of failed lines and
             -- lines in linegroups will exceed number of input lines
             -- by these lines in linegroups
             -- Will not delete these incompatible groups
             j := x_line_groups.FIRST;
             LOOP

                IF x_line_groups(j).line_group_id <> x_group_info(i).line_group_id THEN
                   GOTO next_linegroup;
                END IF;

                -- Add to failed lines
                l_failed_lc := x_failed_lines.COUNT + 1;
                x_failed_lines(l_failed_lc).entity_line_id := x_line_groups(j).entity_line_id;
                x_failed_lines(l_failed_lc).failed_line_index := l_failed_lc;
                <<next_linegroup>>
                EXIT WHEN j=x_line_groups.LAST;
                j := x_line_groups.NEXT(j);
             END LOOP;

             EXIT WHEN i=x_group_info.LAST;
             i := x_group_info.NEXT(i);
           END LOOP;
        END IF;
    END IF;

    IF x_failed_lines.COUNT = 0 AND p_action_code = G_AUTOCRT_DLVY THEN
       l_failed_constraints.DELETE;
    END IF;

    --  Loop over l_failed_constraints to add to the mesage stack

    stack_messages (
             p_failed_constraints       => l_failed_constraints,
             x_msg_count                => x_msg_count,
             x_msg_data                 => x_msg_data,
             x_return_status            => l_return_status);

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
    END IF;

    IF x_validate_result = 'F' THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    ELSIF l_failed_constraints.COUNT > 0 THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    END IF;

    --
    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --

EXCEPTION
    WHEN g_get_carrmode_failed THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,' get carrier-mode failed ');
      END IF;
      --
    WHEN g_invalid_action_code THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,' invalid_action_code ');
      END IF;
      --
    WHEN g_invalid_input THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,' invalid_input ');
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
    WHEN others THEN
      WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.validate_constraint_dlvb');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END validate_constraint_dlvb;


--***************************************************************************
--
--========================================================================
-- PROCEDURE : validate_constraint_trip    Called by constraint Wrapper API
--                                         and the Group API.
--
-- PARAMETERS: p_init_msg_list             FND_API.G_TRUE to reset list
--             p_action_code               Predefined action code
--             p_exception_list            Compatibility classes to skip if any
--                                         indexed by class code numbers
--             p_trip_info                 Table of Trip records to process
--             p_trip_assigned_dels        Table of delivery records already in the trip
--                                         If not passed, the API will query
--             p_trip_dlvy_lines           Table of delivery details already in the trip
--                                         If not passed, the API will query
--             p_trip_incl_stops           Table of Stop records already in the trip
--                                         If not passed, the API will query
--             x_fail_trips                Table of input trips that failed constraint check
--             x_validate_result           Constraint Validation result : S / F
--             x_msg_count                 Number of messages in the list
--             x_msg_data                  Text of messages
--             x_return_status             Return status
-- COMMENT   : This procedure is used to perform for following actions
--             A. Update an existing trip (UPT)
--========================================================================

PROCEDURE validate_constraint_trip(
             p_init_msg_list            IN      VARCHAR2 DEFAULT fnd_api.g_false,
             p_action_code              IN      VARCHAR2 DEFAULT NULL,
             p_exception_list           IN      WSH_UTIL_CORE.Column_Tab_Type,
             p_trip_info                IN      trip_ccinfo_tab_type,
             p_trip_assigned_dels       IN      delivery_ccinfo_tab_type,
             p_trip_dlvy_lines          IN      detail_ccinfo_tab_type,
             p_trip_incl_stops          IN      stop_ccinfo_tab_type,
             x_fail_trips               OUT NOCOPY    WSH_UTIL_CORE.id_tab_type,
             x_validate_result          OUT NOCOPY    VARCHAR2,
             x_msg_count                OUT NOCOPY    NUMBER,
             x_msg_data                 OUT NOCOPY    VARCHAR2,
             x_return_status            OUT NOCOPY    VARCHAR2)
IS

    j                                   NUMBER := 0;
    k                                   NUMBER := 0;
    l                                   NUMBER := 0;
    l_carrier                           NUMBER := 0;
    l_vehicle_type                      NUMBER := 0;
    l_mode                              VARCHAR2(30);
    l_service_level                     VARCHAR2(30) := NULL;
    l_carrier_service_inout_rec         WSH_CARRIERS_GRP.Carrier_Service_InOut_Rec_Type;
    l_trip_del_cnt                      NUMBER := 0;
    l_trip_detail_cnt                   NUMBER := 0;
    l_trip_stops_cnt                    NUMBER := 0;
    l_out_object2_num                   NUMBER:=0;
    l_out_object2_char                  VARCHAR2(30):=NULL;
    l_comp_class_tab                    WSH_UTIL_CORE.Column_Tab_Type;
    l_return_status                     VARCHAR2(1);
    l_failed_constraint                 line_constraint_rec_type;
    l_failed_constraints                line_constraint_tab_type;
    l_curr_trip_added                   BOOLEAN := FALSE;
    l_validate_mode_result              VARCHAR2(1) := 'S';
    l_validate_carrier_result           VARCHAR2(1) := 'S';
    l_validate_vehicle_result           VARCHAR2(1) := 'S';
    l_validate_faccar_result            VARCHAR2(1) := 'S';
    l_validate_facveh_result            VARCHAR2(1) := 'S';
    l_validate_facmod_result            VARCHAR2(1) := 'S';
    l_validate_itmveh_result            VARCHAR2(1) := 'S';
    l_validate_itmcar_result            VARCHAR2(1) := 'S';
    l_validate_itmmod_result            VARCHAR2(1) := 'S';
    l_validate_in_result                VARCHAR2(1) := 'S';
    l_validate_ex_result                VARCHAR2(1) := 'S';
    l_delivery_rec                      delivery_ccinfo_rec_type;
    l_detail_rec                        detail_ccinfo_rec_type;
    l_stop_rec                          stop_ccinfo_rec_type;
    l_trip_assigned_dels                delivery_ccinfo_tab_type;
    l_trip_dlvy_lines                   detail_ccinfo_tab_type;
    l_trip_incl_stops                   stop_ccinfo_tab_type;
    l_vehicle_name                      VARCHAR2(2000);
    l_vehicle_org_name                  VARCHAR2(240);

    --#DUM_LOC(S)
    l_physical_location_id		NUMBER;
    --#DUM_LOC(E)

    --SBAKSHI(8/24)
    l_trip_incl_stops_sort		stop_ccinfo_tab_type;
    l_idx				NUMBER;
    --SBAKSHI(8/24)
    l_debug_on                          CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
    l_module_name                       CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'validate_constraint_trip';

BEGIN

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    x_validate_result := 'S';

    g_itm_mustuse_cache.DELETE;
    g_itmloc_mustuse_cache.DELETE;
    g_itm_exclusive_cache.DELETE;
    g_fac_exclusive_cache.DELETE;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
    END IF;

    IF l_debug_on THEN
       wsh_debug_sv.push(l_module_name);
       WSH_DEBUG_SV.logmsg(l_module_name,'p_init_msg_list : '||p_init_msg_list);
    END IF;

    refresh_cache(l_return_status);

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
    END IF;

    IF NOT p_exception_list.EXISTS(G_FACILITY_MODE_NUM) THEN
      l_comp_class_tab(G_FACILITY_MODE_NUM) := G_FACILITY_MODE;
    END IF;
    IF NOT p_exception_list.EXISTS(G_FACILITY_CARRIER_NUM) THEN
      l_comp_class_tab(G_FACILITY_CARRIER_NUM) := G_FACILITY_CARRIER;
    END IF;
    IF NOT p_exception_list.EXISTS(G_FACILITY_VEHICLE_NUM) THEN
      l_comp_class_tab(G_FACILITY_VEHICLE_NUM) := G_FACILITY_VEHICLE;
    END IF;
    IF NOT p_exception_list.EXISTS(G_ITEM_MODE_NUM) THEN
      l_comp_class_tab(G_ITEM_MODE_NUM) := G_ITEM_MODE;
    END IF;
    IF NOT p_exception_list.EXISTS(G_ITEM_CARRIER_NUM) THEN
      l_comp_class_tab(G_ITEM_CARRIER_NUM) := G_ITEM_CARRIER;
    END IF;
    IF NOT p_exception_list.EXISTS(G_ITEM_VEHICLE_NUM) THEN
      l_comp_class_tab(G_ITEM_VEHICLE_NUM) := G_ITEM_VEHICLE;
    END IF;

    j := p_trip_info.FIRST;
    IF j IS NOT NULL THEN
    LOOP
    IF p_trip_assigned_dels.COUNT = 0 THEN

          OPEN c_get_trip_dlvy(p_trip_info(j).trip_id); -- or container_id
          LOOP
               FETCH c_get_trip_dlvy INTO l_delivery_rec;
               EXIT WHEN c_get_trip_dlvy%NOTFOUND;

	       --#DUM_LOC(S)
	       WSH_LOCATIONS_PKG.CONVERT_INTERNAL_CUST_LOCATION(
	             p_internal_cust_location_id  => l_delivery_rec.ultimate_dropoff_location_id,
	             x_internal_org_location_id   => l_physical_location_id,
		     x_return_status              => l_return_status);

	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
	            raise FND_API.G_EXC_UNEXPECTED_ERROR;
	         END IF;
  	       END IF;

	       IF (l_physical_location_id IS NOT NULL) THEN
  	         --
	         IF l_debug_on THEN
		     WSH_DEBUG_SV.logmsg(l_module_name,'Location '||l_delivery_rec.ultimate_dropoff_location_id||' is a dummy location');
	         END IF;
	         --
	         l_delivery_rec.ultimate_dropoff_location_id := l_physical_location_id;
                 -- AGDUMMY TODO
                 l_delivery_rec.physical_dropoff_location_id := l_physical_location_id;
	       END IF;
               --#DUM_LOC(E)

	       l_trip_del_cnt := l_trip_del_cnt + 1;
               l_trip_assigned_dels(l_trip_del_cnt) := l_delivery_rec;
          END LOOP;
          CLOSE c_get_trip_dlvy;
    END IF;

    IF p_trip_dlvy_lines.COUNT = 0 THEN

          OPEN c_get_trip_details_std(p_trip_info(j).trip_id); -- or container_id
          LOOP
               FETCH c_get_trip_details_std INTO l_detail_rec;
               EXIT WHEN c_get_trip_details_std%NOTFOUND;
               --#DUM_LOC(S)
	       WSH_LOCATIONS_PKG.CONVERT_INTERNAL_CUST_LOCATION(
	  	      p_internal_cust_location_id  => l_detail_rec.ship_to_location_id,
	          x_internal_org_location_id   => l_physical_location_id,
              x_return_status              => l_return_status);

	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
	         END IF;
	       END IF;

	       IF (l_physical_location_id IS NOT NULL) THEN
  	          --
	          IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Location '||l_detail_rec.ship_to_location_id||' is a dummy location');
	          END IF;
	          --
	          l_detail_rec.ship_to_location_id:= l_physical_location_id;
                  -- AGDUMMY TODO
                  l_detail_rec.physical_ship_to_location_id := l_physical_location_id;
	       END IF;
                --#DUM_LOC(E)
	       l_trip_detail_cnt := l_trip_detail_cnt + 1;
               l_trip_dlvy_lines(l_trip_detail_cnt) := l_detail_rec;
          END LOOP;
          CLOSE c_get_trip_details_std;
    END IF;

    IF p_trip_incl_stops.COUNT = 0 THEN

          OPEN c_get_trip_stops(p_trip_info(j).trip_id); -- or container_id
          LOOP
	       -- Cursor c_get_trip_stops handles the case of returning physical locations
	       -- for the dummy location.
	       FETCH c_get_trip_stops INTO l_stop_rec;
               EXIT WHEN c_get_trip_stops%NOTFOUND;
               l_trip_stops_cnt := l_trip_stops_cnt + 1;
               l_trip_incl_stops(l_trip_stops_cnt) := l_stop_rec;

	  END LOOP;
          CLOSE c_get_trip_stops;

    END IF;

    EXIT WHEN j = p_trip_info.LAST;
    j := p_trip_info.NEXT(j);
    END LOOP;
    END IF;

    IF p_trip_assigned_dels.COUNT <> 0 THEN

	l := p_trip_assigned_dels.FIRST;
        LOOP
           l_trip_assigned_dels(l) := p_trip_assigned_dels(l);

	   --#DUM_LOC(S)
	   WSH_LOCATIONS_PKG.CONVERT_INTERNAL_CUST_LOCATION(
             p_internal_cust_location_id  => l_trip_assigned_dels(l).ultimate_dropoff_location_id,
             x_internal_org_location_id   => l_physical_location_id,
             x_return_status              => l_return_status);

	   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	     IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
	        raise FND_API.G_EXC_UNEXPECTED_ERROR;
	     END IF;
  	   END IF;

	   IF (l_physical_location_id IS NOT NULL) THEN
  	      --
	      IF l_debug_on THEN
		  WSH_DEBUG_SV.logmsg(l_module_name,'Location '||l_trip_assigned_dels(l).ultimate_dropoff_location_id||' is a dummy location');
	      END IF;
	      --
	      l_trip_assigned_dels(l).ultimate_dropoff_location_id := l_physical_location_id;
              -- AGDUMMY TODO
              l_trip_assigned_dels(l).physical_dropoff_location_id := l_physical_location_id;
	   END IF;
           --#DUM_LOC(E)

           EXIT WHEN l = p_trip_assigned_dels.LAST;
           l := p_trip_assigned_dels.NEXT(l);
        END LOOP;

    END IF;

    IF p_trip_dlvy_lines.COUNT <> 0 THEN

        l := p_trip_dlvy_lines.FIRST;
        LOOP
           l_trip_dlvy_lines(l) := p_trip_dlvy_lines(l);
           --#DUM_LOC(S)
	   WSH_LOCATIONS_PKG.CONVERT_INTERNAL_CUST_LOCATION(
	      p_internal_cust_location_id  => l_trip_dlvy_lines(l).ship_to_location_id,
              x_internal_org_location_id   => l_physical_location_id,
              x_return_status              => l_return_status);

 	   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	     IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
	        raise FND_API.G_EXC_UNEXPECTED_ERROR;
	     END IF;
    	   END IF;

  	   IF (l_physical_location_id IS NOT NULL) THEN
  	      --
	      IF l_debug_on THEN
		  WSH_DEBUG_SV.logmsg(l_module_name,'Location '||l_trip_dlvy_lines(l).ship_to_location_id||' is a dummy location');
	      END IF;
	      --
	      l_trip_dlvy_lines(l).ship_to_location_id:= l_physical_location_id;
              -- AGDUMMY TODO
              l_trip_dlvy_lines(l).physical_ship_to_location_id := l_physical_location_id;
	   END IF;
           --#DUM_LOC(E)

	   EXIT WHEN l = p_trip_dlvy_lines.LAST;
           l := p_trip_dlvy_lines.NEXT(l);
        END LOOP;
    END IF;

    IF p_trip_incl_stops.COUNT <> 0 THEN

	/* SBAKSHI 8/24
	   We should have p_trip_incl_stops sorted by planned arrival date
	   p_trip_incl_stops is IN RECORD  record
	   Need to make a local record structure l_trip_incl_stops_sort for this purpose
	*/

	sort_stop_table_asc(
	   p_stop_table	   => p_trip_incl_stops,
	   x_sort_stop_table => l_trip_incl_stops_sort,
	   x_return_status   => l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
	    raise FND_API.G_EXC_UNEXPECTED_ERROR;
	  END IF;
    	END IF;

	-- l := p_trip_incl_stops.FIRST;
  	l := l_trip_incl_stops_sort.FIRST;

	LOOP
           -- AGDUMMY
           -- Sort them in terms of planned_arrival_date
	   -- l_trip_incl_stops(l) := p_trip_incl_stops(l);

	   l_trip_incl_stops(l) := l_trip_incl_stops_sort(l);
	   --#DUM_LOC(S)
	   -- IF (p_trip_incl_stops(l).physical_location_id IS NOT NULL)  THEN
	   IF (l_trip_incl_stops_sort(l).physical_location_id IS NOT NULL)  THEN
		 l_trip_incl_stops(l).stop_location_id := l_trip_incl_stops(l).physical_location_id;
	   END IF;
	   --#DUM_LOC(E)
 	   -- EXIT WHEN l = p_trip_incl_stops.LAST;
           -- l := p_trip_incl_stops.NEXT(l);

	   EXIT WHEN l = l_trip_incl_stops_sort.LAST;
	   l := l_trip_incl_stops_sort.NEXT(l);
	END LOOP;

    END IF;
    --SBAKSHI 8/24 (E)

    -- Only for action code = UPT
    -- Can update trip's carrier , mode, vehicle

    -- Need to check FAC - CAR,MOD    ITM - CAR,MOD

    --LOOP  -- Over input trips
    j := p_trip_info.FIRST;
    IF j IS NOT NULL THEN
      LOOP

        l_validate_faccar_result := 'S';
        l_validate_facmod_result := 'S';
        l_validate_facveh_result := 'S';
        l_validate_itmcar_result := 'S';
        l_validate_itmmod_result := 'S';
        l_validate_itmveh_result := 'S';
        l_validate_mode_result   := 'S';
        l_validate_carrier_result := 'S';
        l_validate_vehicle_result := 'S';
        l_validate_in_result := 'S';
        l_validate_ex_result := 'S';
        l_curr_trip_added := FALSE;
        l_carrier         := NULL;
        l_mode            := NULL;
        l_service_level   := NULL;
        l_vehicle_type    := NULL;

        IF (p_trip_info(j).carrier_id IS NULL OR p_trip_info(j).mode_of_transport IS NULL) AND
           (p_trip_info(j).ship_method_code IS NOT NULL) THEN

          l_carrier_service_inout_rec.ship_method_code := p_trip_info(j).ship_method_code;
          WSH_CARRIERS_GRP.get_carrier_service_mode(
                   p_carrier_service_inout_rec   =>  l_carrier_service_inout_rec,
                   x_return_status       =>  l_return_status);

          IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
             IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
             raise g_get_carrmode_failed;
            END IF;
          END IF;
          l_carrier := l_carrier_service_inout_rec.carrier_id;
          l_mode    := l_carrier_service_inout_rec.mode_of_transport;

        END IF; -- p_trip_info(j).carrier_id IS NULL OR ..

        -- If carrier_id or mode is passed in, then those get preference for validation
        -- If they are not, they are derived from ship method if that is passed

        IF p_trip_info(j).carrier_id IS NOT NULL THEN
           l_carrier := p_trip_info(j).carrier_id;
        END IF;
        IF p_trip_info(j).mode_of_transport IS NOT NULL THEN
           l_mode := p_trip_info(j).mode_of_transport;
        END IF;

        IF (p_trip_info(j).VEHICLE_ITEM_ID IS NOT NULL AND p_trip_info(j).VEHICLE_ORGANIZATION_ID IS NOT NULL) THEN

          WSH_FTE_INTEGRATION.get_vehicle_type(
                   p_vehicle_item_id     =>  p_trip_info(j).VEHICLE_ITEM_ID,
                   p_vehicle_org_id      =>  p_trip_info(j).VEHICLE_ORGANIZATION_ID,
                   x_vehicle_type_id     =>  l_vehicle_type,
                   x_return_status       =>  l_return_status);

          IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
             IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
              IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
               l_vehicle_name := WSH_UTIL_CORE.get_item_name (p_item_id => p_trip_info(j).VEHICLE_ITEM_ID,
                                                           p_organization_id => p_trip_info(j).VEHICLE_ORGANIZATION_ID);
               l_vehicle_org_name := WSH_UTIL_CORE.get_org_name (p_organization_id => p_trip_info(j).VEHICLE_ORGANIZATION_ID);
               FND_MESSAGE.SET_NAME('WSH','WSH_VEHICLE_TYPE_UNDEFINED');
               FND_MESSAGE.SET_TOKEN('ITEM',l_vehicle_name);
               FND_MESSAGE.SET_TOKEN('ORGANIZATION',l_vehicle_org_name);
               FND_MSG_PUB.ADD;
              --raise g_get_vehicletype_failed;
             END IF;
          END IF;

        END IF; -- p_trip_info(j).VEHICLE_ITEM_ID IS NOT NULL AND ..


        --LOOP  -- Over each stop of this input trip
        k := l_trip_incl_stops.FIRST;
        IF k IS NOT NULL THEN
          LOOP

        -- AGDUMMY
        -- If for a trip,
        -- a dummy stop has already been checked, then
        -- any other stop in that trip that
        -- has the stop_location_id same as that of the physical_location_id of the already checked
        -- dummy stop, should not be checked.

        -- When ordered by planned_arrival_date, these two stops would come sequentially
        -- one exactly after the other always - wrudge 8/20/04

        -- Need to consider Facility - Vehicle and Item - Vehicle as well

            IF l_comp_class_tab.EXISTS(G_FACILITY_MODE_NUM) THEN

               check_inclusive_object2(
                 p_comp_class_code          =>      G_FACILITY_MODE,
                 p_entity_type              =>      G_TRIP,
                 p_entity_id                =>      p_trip_info(j).trip_id,
                 p_object1_type             =>      'FAC',
                 p_object1_val_num          =>      l_trip_incl_stops(k).stop_location_id,
                 p_object2_type             =>      'MOD',
                 p_object2_val_char         =>      l_mode,
                 x_out_object2_num          =>      l_out_object2_num,
                 x_out_object2_char         =>      l_out_object2_char,
                 x_validate_result          =>      l_validate_mode_result,
                 x_failed_constraint        =>      l_failed_constraints,
                 x_return_status            =>      l_return_status);

               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                     raise FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
               END IF;

               IF l_validate_mode_result = 'F' THEN
                  l_validate_in_result := 'E';
               END IF;

            END IF;

            IF l_comp_class_tab.EXISTS(G_FACILITY_CARRIER_NUM) THEN

               check_inclusive_object2(
                 p_comp_class_code          =>      G_FACILITY_CARRIER,
                 p_entity_type              =>      G_TRIP,
                 p_entity_id                =>      p_trip_info(j).trip_id,
                 p_object1_type             =>      'FAC',
                 p_object1_val_num          =>      l_trip_incl_stops(k).stop_location_id,
                 p_object2_type             =>      'CAR',
                 p_object2_val_num          =>      l_carrier,
                 x_out_object2_num          =>      l_out_object2_num,
                 x_out_object2_char         =>      l_out_object2_char,
                 x_validate_result          =>      l_validate_carrier_result,
                 x_failed_constraint        =>      l_failed_constraints,
                 x_return_status            =>      l_return_status);

               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                     raise FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
               END IF;

               IF l_validate_carrier_result = 'F' THEN
                  l_validate_in_result := 'E';
               END IF;

            END IF;

            IF l_comp_class_tab.EXISTS(G_FACILITY_VEHICLE_NUM) THEN

               check_inclusive_object2(
                 p_comp_class_code          =>      G_FACILITY_VEHICLE,
                 p_entity_type              =>      G_TRIP,
                 p_entity_id                =>      p_trip_info(j).trip_id,
                 p_object1_type             =>      'FAC',
                 p_object1_val_num          =>      l_trip_incl_stops(k).stop_location_id,
                 p_object2_type             =>      'VHT',
                 p_object2_val_num          =>      l_vehicle_type,
                 x_out_object2_num          =>      l_out_object2_num,
                 x_out_object2_char         =>      l_out_object2_char,
                 x_validate_result          =>      l_validate_vehicle_result,
                 x_failed_constraint        =>      l_failed_constraints,
                 x_return_status            =>      l_return_status);

               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                     raise FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
               END IF;

               IF l_validate_vehicle_result = 'F' THEN
                  l_validate_in_result := 'E';
               END IF;

            END IF;

            IF l_validate_in_result = 'E' THEN
               EXIT;
            END IF;

             -- Validate FAC - CAR  FAC - MOD against the stop locations
	     -- Need to consider Facility - Vehicle

            IF l_comp_class_tab.EXISTS(G_FACILITY_CARRIER_NUM) THEN

               validate_constraint(
                 p_comp_class_code          =>      G_FACILITY_CARRIER,
                 p_object1_type             =>      'FAC',
                 p_object1_val_num          =>      l_trip_incl_stops(k).stop_location_id,
                 p_object2_type             =>      'CAR',
                 p_object2_val_num          =>      l_carrier,
                 x_validate_result          =>      l_validate_faccar_result,
                 x_failed_constraint        =>      l_failed_constraint,
                 x_return_status            =>      l_return_status);

               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                     raise FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
               END IF;

               IF l_validate_faccar_result <> 'S' THEN
                  l_failed_constraint.line_constraint_index := l_failed_constraints.COUNT+1;
                  l_failed_constraint.entity_type :=  G_TRIP;
                  l_failed_constraint.entity_line_id :=  p_trip_info(j).trip_id;
                  l_failed_constraints(l_failed_constraints.COUNT+1) := l_failed_constraint;
                  IF l_validate_faccar_result = 'E' THEN
                     l_validate_ex_result := 'E';
                  END IF;
               END IF;

            END IF;

            IF l_comp_class_tab.EXISTS(G_FACILITY_MODE_NUM) THEN

               validate_constraint(
                 p_comp_class_code          =>      G_FACILITY_MODE,
                 p_object1_type             =>      'FAC',
                 p_object1_val_num          =>      l_trip_incl_stops(k).stop_location_id,
                 p_object2_type             =>      'MOD',
                 p_object2_val_char         =>      l_mode,
                 x_validate_result          =>      l_validate_facmod_result,
                 x_failed_constraint        =>      l_failed_constraint,
                 x_return_status            =>      l_return_status);

               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                     raise FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
               END IF;

               IF l_validate_facmod_result <> 'S' THEN
                  l_failed_constraint.line_constraint_index := l_failed_constraints.COUNT+1;
                  l_failed_constraint.entity_type :=  G_TRIP;
                  l_failed_constraint.entity_line_id :=  p_trip_info(j).trip_id;
                  l_failed_constraints(l_failed_constraints.COUNT+1) := l_failed_constraint;
                  IF l_validate_facmod_result = 'E' THEN
                     l_validate_ex_result := 'E';
                  END IF;
               END IF;

            END IF;

            IF l_comp_class_tab.EXISTS(G_FACILITY_VEHICLE_NUM) THEN

               validate_constraint(
                 p_comp_class_code          =>      G_FACILITY_VEHICLE,
                 p_object1_type             =>      'FAC',
                 p_object1_val_num          =>      l_trip_incl_stops(k).stop_location_id,
                 p_object2_type             =>      'VHT',
                 p_object2_val_num          =>      l_vehicle_type,
                 x_validate_result          =>      l_validate_facveh_result,
                 x_failed_constraint        =>      l_failed_constraint,
                 x_return_status            =>      l_return_status);

               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                     raise FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
               END IF;

               IF l_validate_facveh_result <> 'S' THEN
                  l_failed_constraint.line_constraint_index := l_failed_constraints.COUNT+1;
                  l_failed_constraint.entity_type :=  G_TRIP;
                  l_failed_constraint.entity_line_id :=  p_trip_info(j).trip_id;
                  l_failed_constraints(l_failed_constraints.COUNT+1) := l_failed_constraint;
                  IF l_validate_facveh_result = 'E' THEN
                     l_validate_ex_result := 'E';
                  END IF;
               END IF;

            END IF;

            <<next_stop>>

            EXIT WHEN k = l_trip_incl_stops.LAST;

	    l_idx := k ;
	    k	  := l_trip_incl_stops.NEXT(k);

	    --SBAKSHI(8/24) (S)
	    --Check can be put here,in case the next record is the physical stop,
	    --then move two times, Skip the record over here.
	    --Pseudo code -  IF both locations are specified then
            -- TODO Should we use physical_stop_id ?

	    IF (l_trip_incl_stops(k).trip_id = l_trip_incl_stops(l_idx).trip_id
		     AND
		l_trip_incl_stops(k).stop_location_id=l_trip_incl_stops(l_idx).physical_location_id)
	    THEN

		--
		--Current record is for the physical location, we need to skip it .
		--In case it is the last record we need to exit,otherwise skip.
		--

		IF (k = l_trip_incl_stops.LAST) THEN
			EXIT ;
		ELSE
			k:= l_trip_incl_stops.NEXT(k);
		END IF;

	    END IF;
	    --SBAKSHI(8/24) (E)

	  END LOOP;

	END IF;

        IF l_validate_ex_result = 'E' OR l_validate_in_result = 'E' THEN

           x_validate_result := 'F';
           x_fail_trips(x_fail_trips.COUNT+1) := p_trip_info(j).trip_id;
           l_curr_trip_added := TRUE;
           l_validate_in_result := 'S';
           l_validate_ex_result := 'S';
           --
           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Added failed trip because of stops : '|| p_trip_info(j).trip_id);
           END IF;
           --
        END IF;

        --LOOP -- over each dlvy line of this input trip
        l := l_trip_dlvy_lines.FIRST;
        IF l IS NOT NULL THEN
          LOOP

          -- Need to skip an Inbound delivery line
          -- if the trip's status is "In Transit" or "Closed"

            --IF p_trip_info(j).STATUS_CODE IN ('IT','CL') AND
            IF l_trip_dlvy_lines(l).released_status IN ('C','L') AND
               l_trip_dlvy_lines(l).line_direction = 'I' THEN
               GOTO line_nextpass;
            END IF;

        -- Need to consider Item - Vehicle

            IF l_comp_class_tab.EXISTS(G_ITEM_MODE_NUM) THEN

               check_inclusive_object2(
                 p_comp_class_code          =>      G_ITEM_MODE,
                 p_entity_type              =>      G_DEL_DETAIL,
                 p_entity_id                =>      l_trip_dlvy_lines(l).delivery_detail_id,
                 p_object1_type             =>      'ITM',
                 p_object1_parent_id        =>      l_trip_dlvy_lines(l).organization_id,
                 p_object1_val_num          =>      l_trip_dlvy_lines(l).inventory_item_id,
                 p_object2_type             =>      'MOD',
                 p_object2_val_char         =>      l_mode,
                 x_out_object2_num          =>      l_out_object2_num,
                 x_out_object2_char         =>      l_out_object2_char,
                 x_validate_result          =>      l_validate_mode_result,
                 x_failed_constraint        =>      l_failed_constraints,
                 x_return_status            =>      l_return_status);

               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                     raise FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
               END IF;

               IF l_validate_mode_result = 'F' THEN
                  l_validate_in_result := 'E';
               END IF;

            END IF;

            IF l_comp_class_tab.EXISTS(G_ITEM_CARRIER_NUM) THEN

               check_inclusive_object2(
                 p_comp_class_code          =>      G_ITEM_CARRIER,
                 p_entity_type              =>      G_DEL_DETAIL,
                 p_entity_id                =>      l_trip_dlvy_lines(l).delivery_detail_id,
                 p_object1_type             =>      'ITM',
                 p_object1_parent_id        =>      l_trip_dlvy_lines(l).organization_id,
                 p_object1_val_num          =>      l_trip_dlvy_lines(l).inventory_item_id,
                 p_object2_type             =>      'CAR',
                 p_object2_val_num          =>      l_carrier,
                 x_out_object2_num          =>      l_out_object2_num,
                 x_out_object2_char         =>      l_out_object2_char,
                 x_validate_result          =>      l_validate_carrier_result,
                 x_failed_constraint        =>      l_failed_constraints,
                 x_return_status            =>      l_return_status);

               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                     raise FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
               END IF;

               IF l_validate_carrier_result = 'F' THEN
                  l_validate_in_result := 'E';
               END IF;

            END IF;

            IF l_comp_class_tab.EXISTS(G_ITEM_VEHICLE_NUM) THEN

               check_inclusive_object2(
                 p_comp_class_code          =>      G_ITEM_VEHICLE,
                 p_entity_type              =>      G_DEL_DETAIL,
                 p_entity_id                =>      l_trip_dlvy_lines(l).delivery_detail_id,
                 p_object1_type             =>      'ITM',
                 p_object1_parent_id        =>      l_trip_dlvy_lines(l).organization_id,
                 p_object1_val_num          =>      l_trip_dlvy_lines(l).inventory_item_id,
                 p_object2_type             =>      'VHT',
                 p_object2_val_num          =>      l_vehicle_type,
                 x_out_object2_num          =>      l_out_object2_num,
                 x_out_object2_char         =>      l_out_object2_char,
                 x_validate_result          =>      l_validate_vehicle_result,
                 x_failed_constraint        =>      l_failed_constraints,
                 x_return_status            =>      l_return_status);

               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                     raise FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
               END IF;

               IF l_validate_vehicle_result = 'F' THEN
                  l_validate_in_result := 'E';
               END IF;

            END IF;

            IF l_validate_in_result = 'E' THEN
               EXIT;
            END IF;

             -- Validate ITM - CAR  ITM - MOD against the items
    	     -- Need to consider Item - Vehicle

            IF l_comp_class_tab.EXISTS(G_ITEM_MODE_NUM) THEN

               validate_constraint(   --  checks only negative constraints
                 p_comp_class_code          =>      G_ITEM_MODE,
                 p_object1_type             =>      'ITM',
                 p_object1_parent_id        =>      l_trip_dlvy_lines(l).organization_id,
                 p_object2_type             =>      'MOD',
                 p_object1_val_num          =>      l_trip_dlvy_lines(l).inventory_item_id,
                 p_object2_val_char         =>      l_mode,
                 x_validate_result          =>      l_validate_itmmod_result,
                 x_failed_constraint        =>      l_failed_constraint,  -- id
                 x_return_status            =>      l_return_status);

               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                     raise FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
               END IF;

               IF l_validate_itmmod_result <> 'S' THEN
                  l_failed_constraint.line_constraint_index := l_failed_constraints.COUNT+1;
                  l_failed_constraint.entity_type :=  G_DEL_DETAIL;
                  l_failed_constraint.entity_line_id :=  l_trip_dlvy_lines(l).delivery_detail_id;
                  l_failed_constraints(l_failed_constraints.COUNT+1) := l_failed_constraint;
                  IF l_validate_itmmod_result = 'E' THEN
                     l_validate_ex_result := 'E';
                  END IF;
               END IF;

            END IF;

            IF l_comp_class_tab.EXISTS(G_ITEM_CARRIER_NUM) THEN

               validate_constraint(   --  checks only negative constraints
                 p_comp_class_code          =>      G_ITEM_CARRIER,
                 p_object1_type             =>      'ITM',
                 p_object1_parent_id        =>      l_trip_dlvy_lines(l).organization_id,
                 p_object2_type             =>      'CAR',
                 p_object1_val_num          =>      l_trip_dlvy_lines(l).inventory_item_id,
                 p_object2_val_num          =>      l_carrier,
                 x_validate_result          =>      l_validate_itmcar_result,
                 x_failed_constraint        =>      l_failed_constraint,  -- id
                 x_return_status            =>      l_return_status);

               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                     raise FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
               END IF;

               IF l_validate_itmcar_result <> 'S' THEN
                  l_failed_constraint.line_constraint_index := l_failed_constraints.COUNT+1;
                  l_failed_constraint.entity_type :=  G_DEL_DETAIL;
                  l_failed_constraint.entity_line_id :=  l_trip_dlvy_lines(l).delivery_detail_id;
                  l_failed_constraints(l_failed_constraints.COUNT+1) := l_failed_constraint;
                  IF l_validate_itmcar_result = 'E' THEN
                     l_validate_ex_result := 'E';
                  END IF;
               END IF;

            END IF;

            IF l_comp_class_tab.EXISTS(G_ITEM_VEHICLE_NUM) THEN

               validate_constraint(   --  checks only negative constraints
                 p_comp_class_code          =>      G_ITEM_VEHICLE,
                 p_object1_type             =>      'ITM',
                 p_object1_parent_id        =>      l_trip_dlvy_lines(l).organization_id,
                 p_object2_type             =>      'VHT',
                 p_object1_val_num          =>      l_trip_dlvy_lines(l).inventory_item_id,
                 p_object2_val_num          =>      l_vehicle_type,
                 x_validate_result          =>      l_validate_itmveh_result,
                 x_failed_constraint        =>      l_failed_constraint,  -- id
                 x_return_status            =>      l_return_status);

               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                     raise FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
               END IF;

               IF l_validate_itmveh_result <> 'S' THEN
                  l_failed_constraint.line_constraint_index := l_failed_constraints.COUNT+1;
                  l_failed_constraint.entity_type :=  G_DEL_DETAIL;
                  l_failed_constraint.entity_line_id :=  l_trip_dlvy_lines(l).delivery_detail_id;
                  l_failed_constraints(l_failed_constraints.COUNT+1) := l_failed_constraint;
                  IF l_validate_itmveh_result = 'E' THEN
                     l_validate_ex_result := 'E';
                  END IF;
               END IF;

            END IF;

            <<line_nextpass>>

            EXIT WHEN l = l_trip_dlvy_lines.LAST;
            l := l_trip_dlvy_lines.NEXT(l);

          END LOOP;
        END IF;

        IF l_validate_in_result = 'E' OR l_validate_ex_result = 'E' THEN

           x_validate_result := 'F';
           IF NOT l_curr_trip_added THEN
             x_fail_trips(x_fail_trips.COUNT+1) := p_trip_info(j).trip_id;
             --
             IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Added failed trip because of items : '|| p_trip_info(j).trip_id);
             END IF;
             --
           END IF;

        END IF;

        EXIT WHEN j = p_trip_info.LAST;
        j := p_trip_info.NEXT(j);

      END LOOP;
    END IF;

    stack_messages (
             p_failed_constraints       => l_failed_constraints,
             x_msg_count                => x_msg_count,
             x_msg_data                 => x_msg_data,
             x_return_status            => l_return_status);

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
    END IF;

    IF x_validate_result = 'F' THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    ELSIF l_failed_constraints.COUNT > 0 THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    END IF;

    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'failed trip count : '|| x_fail_trips.COUNT);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --

EXCEPTION
    WHEN g_get_carrmode_failed THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,' get carrier-mode failed ');
      END IF;
      --
    WHEN g_get_vehicletype_failed THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,' get vehicletype failed ');
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
    WHEN others THEN
      WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.validate_constraint_trip');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END validate_constraint_trip;


--***************************************************************************
--
--========================================================================
-- PROCEDURE : validate_constraint_stop    Called by constraint Wrapper API
--                                         and the Group API.
--
-- PARAMETERS: p_init_msg_list             FND_API.G_TRUE to reset list
--             p_action_code               Predefined action code
--             p_exception_list            Compatibility classes to skip if any
--                                         indexed by class code numbers
--             p_stop_info                 Table of Stop records to process
--             p_parent_trip_info          Table of Parent Trip records
--                                         If not passed, the API will query
--             x_fail_stops                Table of input stops that failed constraint check
--             x_validate_result           Constraint Validation result : S / F
--             x_msg_count                 Number of messages in the list
--             x_msg_data                  Text of messages
--             x_return_status             Return status
-- COMMENT   : This procedure is used to perform for following actions
--             A. Create a new stop ( CTS)
--             B. Update an existing stop (UPS)
--             C. Delete a stop (DTS)
--========================================================================

--Changes for DUM_LOC
--Modified table p_stop_info in the beginning to get physical locations for dummy locations.


PROCEDURE validate_constraint_stop(
             p_init_msg_list            IN	         VARCHAR2 DEFAULT fnd_api.g_false,
             p_action_code              IN	         VARCHAR2 DEFAULT NULL,
             p_exception_list           IN	         WSH_UTIL_CORE.Column_Tab_Type,
             p_stop_info                IN               stop_ccinfo_tab_type,
             p_parent_trip_info         IN	         trip_ccinfo_tab_type,
             x_fail_stops               OUT NOCOPY       WSH_UTIL_CORE.id_tab_type,
             x_validate_result          OUT NOCOPY       VARCHAR2,
             x_msg_count                OUT NOCOPY       NUMBER,
             x_msg_data                 OUT NOCOPY       VARCHAR2,
             x_return_status            OUT NOCOPY       VARCHAR2)
IS

    CURSOR c_gettripdetails (l_stop_id IN NUMBER) is
    SELECT wt.TRIP_ID, 'Y'as exists_in_database, wt.NAME, wt.PLANNED_FLAG, wt.STATUS_CODE, wt.VEHICLE_ITEM_ID, wt.VEHICLE_NUMBER,
    wt.CARRIER_ID, wt.SHIP_METHOD_CODE, wt.VEHICLE_ORGANIZATION_ID, wt.VEHICLE_NUM_PREFIX, wt.SERVICE_LEVEL,
    wt.MODE_OF_TRANSPORT
    FROM wsh_trips wt, wsh_trip_stops wts
    WHERE wts.stop_id = l_stop_id
    AND   wts.trip_id=  wt.trip_id;

    CURSOR c_gettripinfo (l_trip_id IN NUMBER) is
    SELECT wt.TRIP_ID, 'Y'as exists_in_database, wt.NAME, wt.PLANNED_FLAG, wt.STATUS_CODE, wt.VEHICLE_ITEM_ID, wt.VEHICLE_NUMBER,
    wt.CARRIER_ID, wt.SHIP_METHOD_CODE, wt.VEHICLE_ORGANIZATION_ID, wt.VEHICLE_NUM_PREFIX, wt.SERVICE_LEVEL,
    wt.MODE_OF_TRANSPORT
    FROM wsh_trips wt
    WHERE wt.trip_id = l_trip_id;

    CURSOR c_get_dlvy_stops(c_delivery_id IN NUMBER,c_trip_id IN NUMBER) IS
    SELECT wts1.stop_sequence_number pickup_stop_seq,
           wts2.stop_sequence_number dropoff_stop_seq,
           wts1.planned_arrival_date pickup_stop_pa_date,
           wts2.planned_arrival_date dropoff_stop_pa_date
    FROM   wsh_new_deliveries wnd,
           wsh_delivery_legs wdl,
           wsh_trip_stops wts1,
           wsh_trip_stops wts2
    WHERE  wnd.delivery_id = c_delivery_id
    AND    wdl.delivery_id = wnd.delivery_id
    AND    wdl.pick_up_stop_id = wts1.stop_id
    AND    wdl.drop_off_stop_id = wts2.stop_id
    AND    wts1.trip_id = c_trip_id;

    z                                   NUMBER := 0;
    j                                   NUMBER := 0;
    k                                   NUMBER := 0;
    l                                   NUMBER := 0;
    m                                   NUMBER := 0;
    q                                   NUMBER := 0;
    l_carrier                           NUMBER := NULL;
    l_vehicle_type                      NUMBER := NULL;
    l_mode                              VARCHAR2(30) := NULL;
    l_service_level                     VARCHAR2(30) := NULL;
    l_carrier_service_inout_rec         WSH_CARRIERS_GRP.Carrier_Service_InOut_Rec_Type;
    l_trips_cnt                         NUMBER := 0;
    l_trip_del_cnt                      NUMBER := 0;
    l_trip_detail_cnt                   NUMBER := 0;
    l_trip_stop_cnt                     NUMBER := 0;
    l_out_object2_num                   NUMBER:=0;
    l_out_object2_char                  VARCHAR2(30):=NULL;
    l_added_stop                        BOOLEAN := FALSE;
    l_return_status                     VARCHAR2(1);
    l_comp_class_tab                    WSH_UTIL_CORE.Column_Tab_Type;
    l_failed_constraint                 line_constraint_rec_type;
    l_failed_constraints                line_constraint_tab_type;
    l_failed_constraints_dummy          line_constraint_tab_type;
    l_validate_faccar_result            VARCHAR2(1) := 'S';
    l_validate_facmod_result            VARCHAR2(1) := 'S';
    l_validate_facveh_result            VARCHAR2(1) := 'S';
    l_validate_orgfac_result            VARCHAR2(1) := 'S';
    l_validate_cusfac_result            VARCHAR2(1) := 'S';
    l_validate_supfac_result            VARCHAR2(1) := 'S';
    l_validate_supfacin_result          VARCHAR2(1) := 'S';
    l_validate_cusfacin_result          VARCHAR2(1) := 'S';
    l_validate_itmfac_result            VARCHAR2(1) := 'S';
    l_validate_in_result                VARCHAR2(1) := 'S';
    l_validate_vehicle_result           VARCHAR2(1) := 'S';
    l_validate_carrier_result           VARCHAR2(1) := 'S';
    l_validate_mode_result              VARCHAR2(1) := 'S';
    l_validate_dlvy_result              VARCHAR2(1) := 'S';
    l_validate_dlvb_result              VARCHAR2(1) := 'S';
    l_parent_trip_info                  trip_ccinfo_tab_type ;
    l_trip_rec                          trip_ccinfo_rec_type;
    l_delivery_rec                      delivery_ccinfo_rec_type;
    l_detail_rec                        detail_ccinfo_rec_type;
    l_stop_rec                          stop_ccinfo_rec_type;
    l_trip_assigned_dels                delivery_ccinfo_tab_type;
    l_trip_dlvy_lines                   detail_ccinfo_tab_type;
    --l_trip_children_stops               stop_ccinfo_tab_type;
    l_pickup_stop_seq                   NUMBER     := 0;
    l_dropoff_stop_seq                  NUMBER     := 0;
    l_pu_pa_date                        DATE;
    l_do_pa_date                        DATE;
    l_sibling_locations                 WSH_UTIL_CORE.id_tab_type;
    l_old_stop_location_id              NUMBER     := NULL;
    l_old_stop_seq_num                  NUMBER     := -999;
    l_old_stop_pa_date                  DATE;
    l_mustuse_loc_id                    NUMBER     := NULL;
    l_vehicle_name                      VARCHAR2(2000);
    l_vehicle_org_name                  VARCHAR2(240);

    l_direct_shipment                   BOOLEAN := TRUE;
    l_num_dlegs                         NUMBER  := 0;

    --#DUM_LOC(S)
    l_physical_location_id		NUMBER;
    --#DUM_LOC(E)

    --SBAKSHI (8/24)
    l_idx				NUMBER;
    l_stop_info				stop_ccinfo_tab_type;
    --SBAKSHI (8/24)

    l_debug_on                          CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
    l_module_name                       CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'validate_constraint_stop';

BEGIN

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    x_validate_result := 'S';

    g_itm_mustuse_cache.DELETE;
    g_itmloc_mustuse_cache.DELETE;
    g_itm_exclusive_cache.DELETE;
    g_fac_exclusive_cache.DELETE;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
    END IF;

    IF l_debug_on THEN
       wsh_debug_sv.push(l_module_name);
       WSH_DEBUG_SV.logmsg(l_module_name,'p_init_msg_list : '||p_init_msg_list);
    END IF;

    refresh_cache(l_return_status);

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
    END IF;

    IF NOT p_exception_list.EXISTS(G_FACILITY_MODE_NUM) THEN
      l_comp_class_tab(G_FACILITY_MODE_NUM) := G_FACILITY_MODE;
    END IF;
    IF NOT p_exception_list.EXISTS(G_FACILITY_CARRIER_NUM) THEN
      l_comp_class_tab(G_FACILITY_CARRIER_NUM) := G_FACILITY_CARRIER;
    END IF;
    IF NOT p_exception_list.EXISTS(G_FACILITY_VEHICLE_NUM) THEN
      l_comp_class_tab(G_FACILITY_VEHICLE_NUM) := G_FACILITY_VEHICLE;
    END IF;
    IF NOT p_exception_list.EXISTS(G_ITEM_FACILITY_NUM) THEN
      l_comp_class_tab(G_ITEM_FACILITY_NUM) := G_ITEM_FACILITY;
    END IF;
    IF NOT p_exception_list.EXISTS(G_SHIPORG_FACILITY_NUM) THEN
      l_comp_class_tab(G_SHIPORG_FACILITY_NUM) := G_SHIPORG_FACILITY;
    END IF;
    IF NOT p_exception_list.EXISTS(G_CUSTOMER_FACILITY_NUM) THEN
      l_comp_class_tab(G_CUSTOMER_FACILITY_NUM) := G_CUSTOMER_FACILITY;
    END IF;
    IF NOT p_exception_list.EXISTS(G_SUPPLIER_FACILITY_NUM) THEN
      l_comp_class_tab(G_SUPPLIER_FACILITY_NUM) := G_SUPPLIER_FACILITY;
    END IF;

    -- #LOC_DUM(S)
    -- Replacing dummy locations by physical locations.
    -- #LOC_DUM(E)

    -- AGDUMMY
    -- Rather use nvl(p_stop_info(itr).physical_location_id,p_stop_info(itr).stop_location_id) everywhere
    -- We do not want to loose p_stop_info(itr).stop_location_id

    -- AGDUMMY
    -- Let's create a local l_stop_info
    -- which will store the sorted (by planned_arrival_date) p_stop_info
    -- This is to skip the check for the physical stop if already a dummy has been checked
    -- when they both exist in the same trip

    -- When the input stop table contains a dummy stop, but not  the corresponding physical stop
    -- dummy stop will still be checked
    -- For the reverse case, there is no way to figure out this stop is a physical stop and hence
    -- validation will be performed for it


    -- AGDUMMY TODO
    -- Sort the table outside the LOOP

	--SBAKSHI - Sorting the p_stop_info table.
      sort_stop_table_asc(
	p_stop_table	  => p_stop_info,
	x_sort_stop_table => l_stop_info,
	x_return_status   => l_return_status);

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
	    raise FND_API.G_EXC_UNEXPECTED_ERROR;
	  END IF;
    END IF;

    IF p_parent_trip_info.COUNT = 0 THEN

     --Replacing p_stop_info by l_stop_info
     -- j := p_stop_info.FIRST;
     j := l_stop_info.FIRST;

     IF j IS NOT NULL THEN
      LOOP
         IF l_stop_info(j).stop_id IS NOT NULL AND p_action_code <> G_CRT_TRIP_STOP THEN
          OPEN c_gettripdetails(l_stop_info(j).stop_id);
          LOOP
               FETCH c_gettripdetails INTO l_trip_rec;
               EXIT WHEN c_gettripdetails%NOTFOUND;
               l_trips_cnt := l_trips_cnt + 1;
               l_parent_trip_info(l_trips_cnt) := l_trip_rec;
          END LOOP;
          CLOSE c_gettripdetails;
         ELSIF l_stop_info(j).trip_id IS NOT NULL THEN
          OPEN c_gettripinfo(l_stop_info(j).trip_id);
          LOOP
               FETCH c_gettripinfo INTO l_trip_rec;
               EXIT WHEN c_gettripinfo%NOTFOUND;
               l_trips_cnt := l_trips_cnt + 1;
               l_parent_trip_info(l_trips_cnt) := l_trip_rec;
          END LOOP;
          CLOSE c_gettripinfo;
         ELSE
          IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Input stop index - '||j||' has null stop_id and trip_id');
          END IF;
         END IF;
         EXIT WHEN j = l_stop_info.LAST;
         j := l_stop_info.NEXT(j);
      END LOOP;
     END IF;
    ELSIF p_parent_trip_info.COUNT <> 0 THEN

        l := p_parent_trip_info.FIRST;
        LOOP
           l_parent_trip_info(l) := p_parent_trip_info(l);
           EXIT WHEN l = p_parent_trip_info.LAST;
           l := p_parent_trip_info.NEXT(l);
        END LOOP;

    END IF;


    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Input stop count : '||l_stop_info.COUNT);
        WSH_DEBUG_SV.logmsg(l_module_name,'parent trip count : '||p_parent_trip_info.COUNT||' local trip count : '||l_parent_trip_info.COUNT);
    END IF;

    -- Only for action code = UPS
    -- Also create CTS, DTS
    -- Can update stop's location , planned arrival date
    -- Can't update stop location if any delivery is present

    --LOOP  -- Over input stops
    j := l_stop_info.FIRST;
    IF j IS NOT NULL THEN

     LOOP

      l_added_stop := FALSE;
      l_validate_faccar_result   := 'S';
      l_validate_facveh_result   := 'S';
      l_validate_facmod_result   := 'S';
      l_validate_orgfac_result   := 'S';
      l_validate_cusfac_result   := 'S';
      l_validate_supfac_result   := 'S';
      l_validate_cusfacin_result := 'S';
      l_validate_supfacin_result := 'S';
      l_validate_itmfac_result   := 'S';
      l_validate_in_result       := 'S';
      l_validate_carrier_result  := 'S';
      l_validate_vehicle_result  := 'S';
      l_validate_mode_result     := 'S';
      l_validate_dlvy_result     := 'S';
      l_validate_dlvb_result     := 'S';
      l_old_stop_pa_date         := NULL;

      IF l_debug_on THEN
   	 WSH_DEBUG_SV.logmsg(l_module_name,'Input stop index : '||j||' stop id : '||l_stop_info(j).stop_id||' location : '||nvl(l_stop_info(j).physical_location_id,l_stop_info(j).stop_location_id)||
      ' Sequence : '||l_stop_info(j).stop_sequence_number||' trip id : '||l_stop_info(j).trip_id);
 	 WSH_DEBUG_SV.logmsg(l_module_name,'Planned arrival date : '||to_char(l_stop_info(j).planned_arrival_date,'DD-MON-YYYY HH24:MI:SS')||' Planned departure date : '||
         to_char(l_stop_info(j).planned_departure_date,'DD-MON-YYYY HH24:MI:SS'));
      END IF;

      -- AGDUMMY
      -- Skip this stop if it is the physical stop corresponding to
      -- an already processed dummy stop in the l_stop_info table
      -- TODO skip not done

      -- Fetch old data for the current stop
      -- if it is being updated
      -- this information will be required for inclusive constraint check
      -- related to stop sequence number update

      l_mustuse_loc_id := nvl(l_stop_info(j).physical_location_id,l_stop_info(j).stop_location_id);

      IF p_action_code = G_UPDATE_STOP THEN
         -- Changes made in cursor c_get_stop_location.
	 -- To ensure dummy locations are replaced by physical locations.

	 OPEN  c_get_stop_location(l_stop_info(j).stop_id);
         FETCH c_get_stop_location INTO l_old_stop_location_id, l_old_stop_seq_num,l_old_stop_pa_date;
	 CLOSE c_get_stop_location;

	 IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Input stop values before this update : location_id : '||l_old_stop_location_id||' seq_num : '||l_old_stop_seq_num||' Planned arrival date : '||to_char(l_old_stop_pa_date,'DD-MON-YYYY HH24:MI:SS'));
         END IF;

         l_mustuse_loc_id := l_old_stop_location_id;

      END IF;

      IF p_action_code <> G_DELETE_STOP THEN

       --LOOP  -- Over parent trips
       k := l_parent_trip_info.FIRST;
       IF k IS NOT NULL THEN
        LOOP

           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'For stop : '||l_stop_info(j).stop_id);
             WSH_DEBUG_SV.logmsg(l_module_name,'Stops trip : '||l_stop_info(j).trip_id);
             WSH_DEBUG_SV.logmsg(l_module_name,'Current Trip : '||l_parent_trip_info(k).trip_id);
           END IF;

           IF l_stop_info(j).trip_id <> l_parent_trip_info(k).trip_id THEN
               GOTO next_trip;
           END IF;

           l_carrier                   := NULL;
           l_mode                      := NULL;
           l_service_level             := NULL;
           l_vehicle_type              := NULL;

           IF (l_parent_trip_info(k).carrier_id IS NULL OR l_parent_trip_info(k).mode_of_transport IS NULL) AND
              (l_parent_trip_info(k).ship_method_code IS NOT NULL) THEN

              l_carrier_service_inout_rec.ship_method_code := l_parent_trip_info(k).ship_method_code;

	      WSH_CARRIERS_GRP.get_carrier_service_mode(
                    p_carrier_service_inout_rec =>  l_carrier_service_inout_rec,
                    x_return_status		=>  l_return_status);

              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                  IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
                  raise g_get_carrmode_failed;
                 END IF;
              END IF;

	      l_carrier := l_carrier_service_inout_rec.carrier_id;
              l_mode    := l_carrier_service_inout_rec.mode_of_transport;

           END IF; -- l_parent_trip_info(k).carrier_id IS NULL OR ..

           -- If carrier_id or mode is passed in, then those get preference for validation
           -- If they are not, they are derived from ship method if that is passed

           IF l_parent_trip_info(k).carrier_id IS NOT NULL THEN
              l_carrier := l_parent_trip_info(k).carrier_id;
           END IF;

	   IF l_parent_trip_info(k).mode_of_transport IS NOT NULL THEN
              l_mode := l_parent_trip_info(k).mode_of_transport;
           END IF;

           IF (l_parent_trip_info(k).vehicle_item_id IS NOT NULL AND l_parent_trip_info(k).vehicle_organization_id IS NOT NULL) THEN

              WSH_FTE_INTEGRATION.get_vehicle_type(
                    p_vehicle_item_id     =>  l_parent_trip_info(k).vehicle_item_id,
                    p_vehicle_org_id      =>  l_parent_trip_info(k).vehicle_organization_id,
                    x_vehicle_type_id     =>  l_vehicle_type,
                    x_return_status       =>  l_return_status);

              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                 IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;
               l_vehicle_name := WSH_UTIL_CORE.get_item_name (p_item_id => l_parent_trip_info(k).VEHICLE_ITEM_ID,
                                                           p_organization_id => l_parent_trip_info(k).VEHICLE_ORGANIZATION_ID);
               l_vehicle_org_name := WSH_UTIL_CORE.get_org_name (p_organization_id => l_parent_trip_info(k).VEHICLE_ORGANIZATION_ID);
               FND_MESSAGE.SET_NAME('WSH','WSH_VEHICLE_TYPE_UNDEFINED');
               FND_MESSAGE.SET_TOKEN('ITEM',l_vehicle_name);
               FND_MESSAGE.SET_TOKEN('ORGANIZATION',l_vehicle_org_name);
               FND_MSG_PUB.ADD;
                END IF;
              END IF;

           END IF; -- l_parent_trip_info(k).VEHICLE_ITEM_ID IS NOT NULL AND ..

         -- Need to consider Facility - Vehicle

           IF l_comp_class_tab.EXISTS(G_FACILITY_MODE_NUM) AND
               l_mode IS NOT NULL THEN

              check_inclusive_object2(
                  p_comp_class_code          =>      G_FACILITY_MODE,
                  p_entity_type              =>      G_TRIP,
                  p_entity_id                =>      l_parent_trip_info(k).trip_id,
                  p_object1_type             =>      'FAC',
                  p_object1_val_num          =>      nvl(l_stop_info(j).physical_location_id,l_stop_info(j).stop_location_id),
		  p_object2_type             =>      'MOD',
                  p_object2_val_char         =>      l_mode,
                  x_out_object2_num          =>      l_out_object2_num,
                  x_out_object2_char         =>      l_out_object2_char,
                  x_validate_result          =>      l_validate_mode_result,
                  x_failed_constraint        =>      l_failed_constraints,
                  x_return_status            =>      l_return_status);

              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                     raise FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;
              END IF;

              IF l_validate_mode_result = 'F' THEN
                   l_validate_in_result := 'F';
              END IF;

           END IF;

           IF l_comp_class_tab.EXISTS(G_FACILITY_CARRIER_NUM) AND
               l_carrier IS NOT NULL THEN

              check_inclusive_object2(
                  p_comp_class_code          =>     G_FACILITY_CARRIER,
                  p_entity_type              =>     G_TRIP,
                  p_entity_id                =>     l_parent_trip_info(k).trip_id,
                  p_object1_type             =>     'FAC',
                  p_object1_val_num          =>      nvl(l_stop_info(j).physical_location_id,l_stop_info(j).stop_location_id),
                  p_object2_type             =>     'CAR',
                  p_object2_val_num          =>     l_carrier,
                  x_out_object2_num          =>     l_out_object2_num,
                  x_out_object2_char         =>     l_out_object2_char,
                  x_validate_result          =>     l_validate_carrier_result,
                  x_failed_constraint        =>     l_failed_constraints,
                  x_return_status            =>     l_return_status);

              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;
              END IF;

              IF l_validate_carrier_result = 'F' THEN
                l_validate_in_result := 'F';
              END IF;

           END IF;

           IF l_comp_class_tab.EXISTS(G_FACILITY_VEHICLE_NUM) AND
               l_vehicle_type IS NOT NULL THEN

              check_inclusive_object2(
                  p_comp_class_code          =>      G_FACILITY_VEHICLE,
                  p_entity_type              =>      G_TRIP,
                  p_entity_id                =>      l_parent_trip_info(k).trip_id,
                  p_object1_type             =>      'FAC',
                  p_object1_val_num          =>      nvl(l_stop_info(j).physical_location_id,l_stop_info(j).stop_location_id),
                  p_object2_type             =>      'VHT',
                  p_object2_val_num          =>      l_vehicle_type,
                  x_out_object2_num          =>      l_out_object2_num,
                  x_out_object2_char         =>      l_out_object2_char,
                  x_validate_result          =>      l_validate_vehicle_result,
                  x_failed_constraint        =>      l_failed_constraints,
                  x_return_status            =>      l_return_status);

              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;
              END IF;

              IF l_validate_vehicle_result = 'F' THEN
                 l_validate_in_result := 'F';
              END IF;

           END IF;

           IF l_validate_in_result = 'F' THEN
                EXIT;
           END IF;


           -- Need to consider Facility - Vehicle
           -- Validate FAC - CAR  FAC - MOD, FAC - VEH for the stop locations
           -- against parent trip's carrier, mode, vehicle

           IF l_comp_class_tab.EXISTS(G_FACILITY_CARRIER_NUM) AND
               l_carrier IS NOT NULL THEN

              validate_constraint(
                  p_comp_class_code          =>      G_FACILITY_CARRIER,
                  p_object1_type             =>      'FAC',
		          p_object1_val_num          =>      nvl(l_stop_info(j).physical_location_id,l_stop_info(j).stop_location_id),
                  p_object2_type             =>      'CAR',
                  p_object2_val_num          =>      l_carrier,
                  x_validate_result          =>      l_validate_faccar_result,
                  x_failed_constraint        =>      l_failed_constraint,
                  x_return_status            =>      l_return_status);

              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                 raise FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
              END IF;

              IF l_validate_faccar_result <> 'S' THEN
                   l_failed_constraint.line_constraint_index := l_failed_constraints.COUNT+1;
                   l_failed_constraint.entity_type :=  G_TRIP;
                   l_failed_constraint.entity_line_id :=  l_parent_trip_info(k).trip_id;
                   l_failed_constraints(l_failed_constraints.COUNT+1) := l_failed_constraint;
              END IF;

           END IF;

           IF l_comp_class_tab.EXISTS(G_FACILITY_MODE_NUM) AND
               l_mode IS NOT NULL THEN

              validate_constraint(
                  p_comp_class_code          =>      G_FACILITY_MODE,
                  p_object1_type             =>      'FAC',
                  p_object1_val_num          =>      nvl(l_stop_info(j).physical_location_id,l_stop_info(j).stop_location_id),
                  p_object2_type             =>      'MOD',
                  p_object2_val_char         =>      l_mode,
                  x_validate_result          =>      l_validate_facmod_result,
                  x_failed_constraint        =>      l_failed_constraint,
                  x_return_status            =>      l_return_status);

              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                 raise FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
              END IF;

              IF l_validate_facmod_result <> 'S' THEN
                   l_failed_constraint.line_constraint_index := l_failed_constraints.COUNT+1;
                   l_failed_constraint.entity_type :=  G_TRIP;
                   l_failed_constraint.entity_line_id :=  l_parent_trip_info(k).trip_id;
                   l_failed_constraints(l_failed_constraints.COUNT+1) := l_failed_constraint;
              END IF;

           END IF;

           IF l_comp_class_tab.EXISTS(G_FACILITY_VEHICLE_NUM) AND
               l_vehicle_type IS NOT NULL THEN
               --l_parent_trip_info(k).carrier_id IS NOT NULL THEN

              validate_constraint(
                  p_comp_class_code          =>      G_FACILITY_VEHICLE,
                  p_object1_type             =>      'FAC',
                  p_object1_val_num          =>      nvl(l_stop_info(j).physical_location_id,l_stop_info(j).stop_location_id),
                  p_object2_type             =>      'VHT',
                  p_object2_val_num          =>      l_vehicle_type,
                  x_validate_result          =>      l_validate_facveh_result,
                  x_failed_constraint        =>      l_failed_constraint,
                  x_return_status            =>      l_return_status);

              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                 raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
              END IF;

              IF l_validate_facveh_result <> 'S' THEN
                   l_failed_constraint.line_constraint_index := l_failed_constraints.COUNT+1;
                   l_failed_constraint.entity_type :=  G_TRIP;
                   l_failed_constraint.entity_line_id :=  l_parent_trip_info(k).trip_id;
                   l_failed_constraints(l_failed_constraints.COUNT+1) := l_failed_constraint;
              END IF;

           END IF;

           IF l_validate_faccar_result = 'E' OR l_validate_facmod_result = 'E'  OR
              l_validate_facveh_result = 'E' THEN

              -- One stop has only one parent trip
              EXIT;

           END IF;

           -- What about manual deletion of a stop ?
           -- If the current input stop is the only 'must use' for org/cus/itm of dlvy/dlvb
           -- in parent trip, then prevent deletion;
           -- call modified validate_constraint with p_constraint_type = 'I'
           -- Returns 'S'/'W'/'E' between combinations sent to it
           -- if error (this location is must use), call
           --             check_inclusive_facilities for all other non pick/drop stops in this trip
           --             if success, proceed with deletion for the input stop
           --             else, prevent deletion of the input stop
           -- else, proceed with deletion for the input stop
           -- otherwise go ahead
              null;

           <<next_trip>>

           EXIT WHEN k = l_parent_trip_info.LAST;
           k := l_parent_trip_info.NEXT(k);

	  END LOOP;
        END IF;

      END IF; -- p_action_code <> G_DELETE_STOP


      IF l_validate_carrier_result = 'F' OR l_validate_mode_result = 'F' OR
         l_validate_vehicle_result = 'F' OR
         l_validate_faccar_result = 'E' OR l_validate_facmod_result = 'E' OR
         l_validate_facveh_result = 'E'

      THEN

         x_validate_result := 'F';
         x_fail_stops(x_fail_stops.COUNT+1) := l_stop_info(j).stop_id;
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Added failed stop : '|| l_stop_info(j).stop_id);
         END IF;
         --

      END IF;

      EXIT WHEN j = l_stop_info.LAST;

      l_idx := j;
      j     := l_stop_info.NEXT(j);

      --SBAKSHI(8/24) (S)
      --Check can be put here,in case the next record is the physical stop,
      --then move two times, Skip the record over here.
      -- TODO Should we use physical_stop_id ?

      IF (l_stop_info(j).trip_id = l_stop_info(l_idx).trip_id
		 AND
	  l_stop_info(j).stop_location_id=l_stop_info(l_idx).physical_location_id)
      THEN
	--
	--Current record is for the physical location, we need to advance further.
	--In case we are at the last trip we need to exit,otherwise skip the record.
	--

	   IF (j = l_stop_info.LAST) THEN
	         EXIT ;
	   ELSE
	        j:= l_stop_info.NEXT(j);
	   END IF;

       END IF;
       --SBAKSHI(8/24) (E)

     END LOOP;

    END IF;

    stack_messages (
             p_failed_constraints       => l_failed_constraints,
             x_msg_count                => x_msg_count,
             x_msg_data                 => x_msg_data,
             x_return_status            => l_return_status);

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
    END IF;

    IF x_validate_result = 'F' THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    ELSIF
     l_failed_constraints.COUNT > 0 THEN

        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    END IF;

    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'failed stop count : '|| x_fail_stops.COUNT);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --

EXCEPTION
    WHEN g_get_carrmode_failed THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,' get carrier-mode failed ');
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
    WHEN others THEN
      WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.validate_constraint_stop');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END validate_constraint_stop;

--***************************************************************************--
--========================================================================
-- PROCEDURE : validate_exclusive_constraints   PRIVATE
--
-- PARAMETERS: p_delivery_rec                   Input delivery record
--             p_rule_deconsol_location         input location id to be validated
--                                              against exclusive constraints
--             x_validate_result                Constraint validation result
--             x_return_status                  Return status
-- COMMENT   : This procedure is used to perform for following actions
--             Takes input delivery record and deconsol location id
--             Checks if the input location it can be used as deconsol location
--             Validate ALL exclusive discretionary routing point constraints
--              1. Customer - Facility
--              2. Region / Zone - Facility
--              3. Organization - Facility
--              4. Item - Facility
--========================================================================

PROCEDURE validate_exclusive_constraints(p_delivery_rec IN WSH_FTE_CONSTRAINT_FRAMEWORK.delivery_ccinfo_rec_type,
                                        p_rule_deconsol_location IN NUMBER,
                                        x_validate_result   OUT NOCOPY VARCHAR2,
                                        x_return_status     OUT NOCOPY VARCHAR2
)

IS
l_validate_result           VARCHAR2(1) := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
l_return_status             VARCHAR2(1) := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
l_failed_constraint         WSH_FTE_CONSTRAINT_FRAMEWORK.line_constraint_rec_type;
l_details_info              WSH_FTE_CONSTRAINT_FRAMEWORK.detail_ccinfo_tab_type;
i_det                       NUMBER;
l_module_name               CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'validate_exclusive_constraints';
l_debug_on                  CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_location_id               NUMBER;

CURSOR c_get_details(c_delivery_id IN NUMBER) IS
SELECT wdd.DELIVERY_DETAIL_ID
  , wda.DELIVERY_ID
  , 'Y'
  , wdd.CUSTOMER_ID
  , wdd.INVENTORY_ITEM_ID
  , wdd.SHIP_FROM_LOCATION_ID
  , wdd.ORGANIZATION_ID
  , wdd.SHIP_TO_LOCATION_ID
  , wdd.INTMED_SHIP_TO_LOCATION_ID
  , wdd.RELEASED_STATUS
  , wdd.CONTAINER_FLAG
  , wdd.DATE_REQUESTED
  , wdd.DATE_SCHEDULED
  , wdd.SHIP_METHOD_CODE
  , wdd.CARRIER_ID
  , wdd.PARTY_ID
  , nvl(wdd.LINE_DIRECTION,'O')
  , nvl(wdd.SHIPPING_CONTROL,'BUYER')
  , NULL
FROM wsh_delivery_details wdd,
     wsh_delivery_assignments_v wda
WHERE wdd.delivery_detail_id = wda.delivery_detail_id
AND   nvl(wdd.shipping_control,'BUYER') <> 'SUPPLIER'
AND   wda.delivery_id = c_delivery_id;

BEGIN

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    x_validate_result := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    IF l_debug_on THEN
      wsh_debug_sv.push (l_module_name);
    END IF;

    IF p_delivery_rec.ultimate_dropoff_location_id IS NOT NULL THEN
    --{

        IF l_debug_on THEN
            wsh_debug_sv.logmsg (l_module_name, 'p_delivery_rec.ultimate_dropoff_location_id: ' || p_delivery_rec.ultimate_dropoff_location_id);
            wsh_debug_sv.logmsg (l_module_name, 'p_rule_deconsol_location: '||p_rule_deconsol_location);
        END IF;

        validate_constraint(   --  checks only negative constraints
             p_comp_class_code          =>      WSH_FTE_CONSTRAINT_FRAMEWORK.G_CUSTOMER_FACILITY,
             p_object1_type             =>      'FAC',
             p_object2_type             =>      'FAC',
             p_object1_val_num          =>      p_delivery_rec.ultimate_dropoff_location_id,
             p_object1_physical_id      =>      p_delivery_rec.physical_dropoff_location_id,
             p_object2_val_num          =>      p_rule_deconsol_location,
             x_validate_result          =>      l_validate_result,
             x_failed_constraint        =>      l_failed_constraint,
             x_return_status            =>      l_return_status);

        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


        IF l_debug_on THEN
            wsh_debug_sv.logmsg (l_module_name, 'Customer FAC-FAC l_validate_result: '||l_validate_result);
        END IF;

        IF l_validate_result = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
            x_return_status := l_return_status;
            x_validate_result := l_validate_result;

            IF l_debug_on THEN
                wsh_debug_sv.push(l_module_name);
                wsh_debug_sv.log (l_module_name,'constraint id violated : ',to_char(l_failed_constraint.constraint_id));
                wsh_debug_sv.log (l_module_name,'entity_type : ',to_char(l_failed_constraint.entity_type));
                wsh_debug_sv.log (l_module_name,'constraint_class_code : ',to_char(l_failed_constraint.constraint_class_code));
                wsh_debug_sv.log (l_module_name,'violation_type : ',to_char(l_failed_constraint.violation_type));
                wsh_debug_sv.logmsg(l_module_name, 'Constraint Violation Error. Ship to Customer Location'||p_delivery_rec.ultimate_dropoff_location_id||' can not use '||p_rule_deconsol_location|| ' as deconsolidation location');
            END IF;
            IF l_debug_on THEN
                wsh_debug_sv.pop (l_module_name);
            END IF;
            return;
        END IF;

    --}
    END IF; -- p_delivery_rec.ULTIMATE_DROPOFF_LOCATION_ID IS NOT NULL

    IF p_delivery_rec.customer_id IS NOT NULL THEN
    --{
        IF l_debug_on THEN
          wsh_debug_sv.logmsg (l_module_name, 'p_delivery_rec.customer_id: ' || p_delivery_rec.customer_id);
          wsh_debug_sv.logmsg (l_module_name, 'p_rule_deconsol_location: '||p_rule_deconsol_location);
        END IF;

        validate_constraint(   --  checks only negative constraints
         p_comp_class_code          =>      WSH_FTE_CONSTRAINT_FRAMEWORK.G_CUSTOMER_FACILITY,
         p_object1_type             =>      'CUS',
         p_object2_type             =>      'FAC',
         p_object1_val_num          =>      p_delivery_rec.customer_id,
         p_object2_val_num          =>      p_rule_deconsol_location,
         x_validate_result          =>      l_validate_result,
         x_failed_constraint        =>      l_failed_constraint,
         x_return_status            =>      l_return_status);

        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF l_debug_on THEN
          wsh_debug_sv.logmsg (l_module_name, 'CUS-FAC l_validate_result: '||l_validate_result);
        END IF;

        IF l_validate_result = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
            x_return_status := l_return_status;
            x_validate_result := l_validate_result;
            IF l_debug_on THEN
                wsh_debug_sv.push(l_module_name);
                wsh_debug_sv.log (l_module_name,'constraint id violated : ',to_char(l_failed_constraint.constraint_id));
                wsh_debug_sv.log (l_module_name,'entity_type : ',to_char(l_failed_constraint.entity_type));
                wsh_debug_sv.log (l_module_name,'constraint_class_code : ',to_char(l_failed_constraint.constraint_class_code));
                wsh_debug_sv.log (l_module_name,'violation_type : ',to_char(l_failed_constraint.violation_type));
                wsh_debug_sv.logmsg(l_module_name, 'Constraint Violation Error. Customer '||p_delivery_rec.customer_id||' can not use '||p_rule_deconsol_location|| ' as deconsolidation location');
            END IF;
            IF l_debug_on THEN
                wsh_debug_sv.pop (l_module_name);
            END IF;
            return;
        END IF;
    --}
    END IF; -- p_delivery_rec.customer_id IS NOT NULL



    -- Validate Region/Zone - Facility Constraints for Ultimate drop off location

   /*validate_region_constraint(
         p_location_id       => p_delivery_rec.ultimate_dropoff_location_id,
         p_object2_val_num   => p_rule_deconsol_location,
         x_validate_result   => l_validate_result,
         x_failed_constraint => l_failed_constraint,
         x_return_status     => l_return_status);

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
       raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF l_debug_on THEN
        wsh_debug_sv.logmsg (l_module_name, 'Region/Zone - Facility constraint for ship to location l_validate_result: '||l_validate_result);
    END IF;

    IF l_validate_result = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
        x_return_status := l_return_status;
        x_validate_result := l_validate_result;
        IF l_debug_on THEN
            wsh_debug_sv.logmsg(l_module_name, 'Region/Zone - Facility Constraint Violation Error. Ship to  Location'||p_delivery_rec.ultimate_dropoff_location_id||' can not use '||p_rule_deconsol_location|| ' as deconsolidation location');
        END IF;
        return;
    END IF;*/

    -- Validate Ship From Organization-Facility Constraints

    IF p_delivery_rec.organization_id IS NOT NULL THEN

        IF l_debug_on THEN
          wsh_debug_sv.logmsg (l_module_name, 'organization_id: ' || p_delivery_rec.organization_id);
          wsh_debug_sv.logmsg (l_module_name, 'p_rule_deconsol_location: '||p_rule_deconsol_location);
        END IF;

        validate_constraint(
                 p_comp_class_code          =>      WSH_FTE_CONSTRAINT_FRAMEWORK.G_SHIPORG_FACILITY,
                 p_object2_type             =>      'FAC',
                 p_object1_val_num          =>      p_delivery_rec.organization_id,
                 p_object2_val_num          =>      p_rule_deconsol_location,
                 x_validate_result          =>      l_validate_result,
                 x_failed_constraint        =>      l_failed_constraint,
                 x_return_status            =>      l_return_status);

        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF l_debug_on THEN
            wsh_debug_sv.logmsg (l_module_name, 'ORG - FAC l_validate_result: '||l_validate_result);
        END IF;

        IF l_validate_result = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
            x_return_status := l_return_status;
            x_validate_result := l_validate_result;
            IF l_debug_on THEN
                wsh_debug_sv.push(l_module_name);
                wsh_debug_sv.log (l_module_name,'constraint id violated : ',to_char(l_failed_constraint.constraint_id));
                wsh_debug_sv.log (l_module_name,'entity_type : ',to_char(l_failed_constraint.entity_type));
                wsh_debug_sv.log (l_module_name,'constraint_class_code : ',to_char(l_failed_constraint.constraint_class_code));
                wsh_debug_sv.log (l_module_name,'violation_type : ',to_char(l_failed_constraint.violation_type));
                wsh_debug_sv.logmsg(l_module_name, 'Constraint Violation Error. Ship From Organization'|| p_delivery_rec.organization_id ||' can not use '||p_rule_deconsol_location|| ' as deconsolidation location');
            END IF;
            IF l_debug_on THEN
                wsh_debug_sv.pop (l_module_name);
            END IF;
            return;
        END IF;
    END IF;

    -- Validate Region/Zone - Facility Constraints for Ship From Organization

    IF (p_delivery_rec.organization_id IS NOT NULL) THEN

        get_loc_for_org(
          p_org_id	       => p_delivery_rec.organization_id,
          x_location_id    => l_location_id,
          x_return_status  => x_return_status);

        IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

      /*  validate_region_constraint(
             p_location_id       => p_delivery_rec.ultimate_dropoff_location_id,
             p_object2_val_num   => p_rule_deconsol_location,
             x_validate_result   => l_validate_result,
             x_failed_constraint => l_failed_constraint,
             x_return_status     => l_return_status);

        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF l_debug_on THEN
            wsh_debug_sv.logmsg (l_module_name, 'Region/Zone - Facility constraint for ship to location l_validate_result: '||l_validate_result);
        END IF;

        IF l_validate_result = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
            x_return_status := l_return_status;
            x_validate_result := l_validate_result;
            IF l_debug_on THEN
                wsh_debug_sv.logmsg(l_module_name, 'Region/Zone - Facility Constraint Violation Error. Ship to  Location'||p_delivery_rec.ultimate_dropoff_location_id||' can not use '||p_rule_deconsol_location|| ' as deconsolidation location');
            END IF;
            return;
        END IF;*/
     END IF;

    -- For validating ITEM-FACILITY constraints, get items in delivery using cursor c_get_details
    -- and validate exclusive constraints for each item

    IF p_delivery_rec.delivery_id IS NOT NULL THEN

        OPEN c_get_details(p_delivery_rec.delivery_id);
            FETCH c_get_details BULK COLLECT INTO l_details_info;
        CLOSE c_get_details;

        i_det := l_details_info.FIRST;

        IF i_det IS NOT NULL THEN
            LOOP

                IF l_debug_on THEN
                  wsh_debug_sv.logmsg (l_module_name, 'organization_id: ' || l_details_info(i_det).organization_id);
                  wsh_debug_sv.logmsg (l_module_name, 'inventory_item_id: '||l_details_info(i_det).inventory_item_id);
                END IF;

                validate_constraint(   --  checks only negative constraints
                     p_comp_class_code          =>  WSH_FTE_CONSTRAINT_FRAMEWORK.G_ITEM_FACILITY,
                     p_object1_type             =>  'ITM',
                     p_object1_parent_id        =>  l_details_info(i_det).organization_id,
                     p_object1_val_num          =>  l_details_info(i_det).inventory_item_id,
                     p_object2_type             =>  'FAC',
                     p_object2_val_num          =>  p_rule_deconsol_location,
                     x_validate_result          =>  l_validate_result,
                     x_failed_constraint        =>  l_failed_constraint,
                     x_return_status            =>  l_return_status);

                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

                IF l_debug_on THEN
                    wsh_debug_sv.logmsg (l_module_name, 'ITM - FAC l_validate_result: '||l_validate_result);
                END IF;

                IF l_validate_result = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
                    x_return_status := l_return_status;
                    x_validate_result := l_validate_result;
                    IF l_debug_on THEN
                        wsh_debug_sv.push(l_module_name);
                        wsh_debug_sv.log (l_module_name,'constraint id violated : ',to_char(l_failed_constraint.constraint_id));
                        wsh_debug_sv.log (l_module_name,'entity_type : ',to_char(l_failed_constraint.entity_type));
                        wsh_debug_sv.log (l_module_name,'constraint_class_code : ',to_char(l_failed_constraint.constraint_class_code));
                        wsh_debug_sv.log (l_module_name,'violation_type : ',to_char(l_failed_constraint.violation_type));
                        wsh_debug_sv.logmsg(l_module_name, 'Constraint Violation Error. Item'|| l_details_info(i_det).inventory_item_id ||' can not use '||p_rule_deconsol_location|| ' as deconsolidation location');
                    END IF;
                    IF l_debug_on THEN
                        wsh_debug_sv.pop (l_module_name);
                    END IF;
                    return;
                END IF;

             EXIT WHEN i_det = l_details_info.LAST OR l_validate_result <> 'S' OR l_return_status <> 'S' ;
             i_det := l_details_info.NEXT(i_det);
             END LOOP;
         END IF;
    END IF;

    IF l_debug_on THEN
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
      IF c_get_details%ISOPEN THEN
         CLOSE c_get_details;
      END IF;
      WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.validate_exclusive_constraints');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;

END validate_exclusive_constraints;

--***************************************************************************--
--========================================================================
-- PROCEDURE : get_must_use_facility            PRIVATE
--
-- PARAMETERS: p_delivery_rec                   Input delivery record
--             x_deconsol_location              Output deconsolidation location
--             x_return_status                  Return status
-- COMMENT   : This procedure is used to perform for following actions
--             Takes input delivery record
--             Finds deconsolidation location for the delivery based on
--             Inclusive constraints defined.
--             Checks for the following constraints
--              1. Ship to location - facility
--              2. customer - facility
--              3. Ship from org - facility
--========================================================================

PROCEDURE get_must_use_facility(p_delivery_rec IN WSH_FTE_CONSTRAINT_FRAMEWORK.delivery_ccinfo_rec_type,
                                x_deconsol_location OUT NOCOPY NUMBER,
                                x_return_status     OUT NOCOPY VARCHAR2)

IS
l_ship_from_location_id  NUMBER;
l_ship_to_location_id    NUMBER;
l_customer_id            NUMBER;
l_region_tab             WSH_UTIL_CORE.ID_TAB_TYPE;
l_zone_tab               WSH_UTIL_CORE.ID_TAB_TYPE;
l_deconsol_location      NUMBER;
l_debug_on               CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
r_itr                    NUMBER;
z_itr                    NUMBER;
l_region_id              NUMBER;
l_zone_id                NUMBER;
l_return_status		     VARCHAR2(1);
l_constr_region_id       NUMBER;
l_constr_location_id     NUMBER;
l_constr_org_id          NUMBER;
l_module_name            CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'get_must_use_facility';

-- AG add compatibility_class_id = 2
-- as otherwise there is a small chance of wrongly picking up
-- a supplier facility - facility constraint
CURSOR c_get_must_use_location (c_object1_type VARCHAR2, c_object1_id NUMBER, c_class_id NUMBER) IS
SELECT constraint_object2_id from wsh_fte_comp_constraints
WHERE constraint_object2_type = 'FAC'
AND constraint_object1_type = c_object1_type
AND constraint_object1_id = c_object1_id
AND Constraint_type = 'I'
AND compatibility_class_id = c_class_id  -- 2 for Cus_FAC
AND    nvl(trunc(EFFECTIVE_DATE_FROM,'DDD'),trunc(sysdate,'DDD')) <= trunc(sysdate,'DDD')
AND    nvl(trunc(EFFECTIVE_DATE_TO,'DDD'),trunc(sysdate,'DDD')) >= trunc(sysdate,'DDD');

/*CURSOR c_get_must_use_cus_fac (c_object1_id NUMBER) IS
SELECT constraint_object2_id from wsh_fte_comp_constraints
WHERE constraint_object1_type = 'CUS'
AND constraint_object2_type = 'FAC'
AND constraint_object1_id = c_object1_id
AND Constraint_type = 'I'
AND    nvl(trunc(EFFECTIVE_DATE_FROM,'DDD'),trunc(sysdate,'DDD')) <= trunc(sysdate,'DDD')
AND    nvl(trunc(EFFECTIVE_DATE_TO,'DDD'),trunc(sysdate,'DDD')) >= trunc(sysdate,'DDD');*/

CURSOR c_get_region_incl_constraints IS
SELECT constraint_object1_id, constraint_object2_id from wsh_fte_comp_constraints
WHERE constraint_type = 'I'
AND compatibility_class_id=12
AND    nvl(trunc(EFFECTIVE_DATE_FROM,'DDD'),trunc(sysdate,'DDD')) <= trunc(sysdate,'DDD')
AND    nvl(trunc(EFFECTIVE_DATE_TO,'DDD'),trunc(sysdate,'DDD')) >= trunc(sysdate,'DDD')
ORDER BY creation_date;

BEGIN

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    IF l_debug_on THEN
       wsh_debug_sv.push(l_module_name);
    END IF;

    -- get ship to location for the delivery
    -- For this location, find must use facility using defined inclusive constraint.
    -- Check in cache first, if not found in cache, get from cursor c_get_must_use_location

    l_ship_to_location_id := p_delivery_rec.ULTIMATE_DROPOFF_LOCATION_ID;

    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'l_ship_to_location_id: '|| l_ship_to_location_id);
    END IF;

    IF ( l_ship_to_location_id < g_cache_max_size  and g_location_mustuse_location.EXISTS(l_ship_to_location_id)) THEN

        l_deconsol_location := g_location_mustuse_location(l_ship_to_location_id);
    ELSE
        --Does not exist in the cache.
        -- Compatibility_class_id is 2 for CUS_FAC constraints
        OPEN  c_get_must_use_location( 'FAC', l_ship_to_location_id, 2);
            FETCH c_get_must_use_location INTO l_deconsol_location;
            IF c_get_must_use_location%NOTFOUND THEN
                   l_deconsol_location := NULL;
            END IF;
        CLOSE c_get_must_use_location;

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'l_deconsol_location for ship To Location using CUS_FAC constraints : '|| l_deconsol_location);
        END IF;


        IF (l_ship_to_location_id < g_cache_max_size AND l_deconsol_location IS NOT NULL) THEN
            g_location_mustuse_location(l_ship_to_location_id) := l_deconsol_location;
        END IF;
    END IF;

    -- If deconsol location not found from must use constraint on ship to location,
    -- fetch region level constraints and populate g_region_mustuse_location cache
    -- with region id and corresponding must use location id for all region level constraints
    -- defined.

    IF l_deconsol_location IS NULL THEN
    --{

        IF g_region_mustuse_constraints.COUNT = 0 THEN
            OPEN c_get_region_incl_constraints;
                LOOP
                    FETCH c_get_region_incl_constraints INTO  l_constr_region_id, l_constr_location_id;
                    EXIT WHEN c_get_region_incl_constraints%NOTFOUND;
                    g_region_mustuse_location(l_constr_region_id) := l_constr_location_id;
                END LOOP;
            CLOSE c_get_region_incl_constraints;
        END IF;

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'g_region_mustuse_location.COUNT : '|| g_region_mustuse_location.COUNT);
        END IF;

    	WSH_REGIONS_SEARCH_PKG.Get_All_RegionId_Matches(
             p_location_id		=> l_ship_to_location_id,
             p_use_cache		=> TRUE,
             p_lang_code		=> USERENV('LANG'),
             x_region_tab		=> l_region_tab,
             x_return_status    => l_return_status);

	    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

        r_itr:= l_region_tab.FIRST;

        IF r_itr IS NOT NULL THEN
            LOOP
                l_region_id := l_region_tab(r_itr);

                IF l_region_id < g_cache_max_size AND g_region_mustuse_location.EXISTS(l_region_id) THEN
                    l_deconsol_location := g_region_mustuse_location(l_region_id);
                END IF;

                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'l_deconsol_location from g_region_mustuse_location: '|| l_deconsol_location);
                END IF;

                -- If deconsolidation location found, populate it in cache
                -- Else, search for zone level constraints

                IF (l_ship_to_location_id < g_cache_max_size AND l_deconsol_location IS NOT NULL) THEN
                    g_location_mustuse_location(l_ship_to_location_id) := l_deconsol_location;
                ELSIF l_deconsol_location IS NULL THEN
                    WSH_REGIONS_SEARCH_PKG.Get_All_Zone_Matches(
                      p_region_id		    => l_region_id,
                      x_zone_tab		    => l_zone_tab,
                      x_return_status       => l_return_status);

                     IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                          raise FND_API.G_EXC_UNEXPECTED_ERROR;
                       END IF;
                    END IF;

                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'l_zone_tab.COUNT: '|| l_zone_tab.COUNT);
                    END IF;

                    IF l_zone_tab.COUNT > 0 THEN
                        z_itr:= l_zone_tab.FIRST;
                        IF z_itr IS NOT NULL THEN
                            LOOP
                                l_zone_id := l_zone_tab(z_itr);
                                IF l_zone_id < g_cache_max_size AND g_region_mustuse_location.EXISTS(l_zone_id) THEN
                                    l_deconsol_location := g_region_mustuse_location(l_zone_id);
                                END IF;
                                EXIT WHEN z_itr = l_zone_tab.LAST OR l_deconsol_location IS NOT NULL;
                                z_itr:= l_zone_tab.NEXT(z_itr);
                            END LOOP;
                        END IF;
                    END IF; -- end l_zone_tab.count >0
                END IF;

                EXIT WHEN r_itr = l_region_tab.LAST OR l_deconsol_location IS NOT NULL;
                r_itr:= l_region_tab.NEXT(r_itr);
	        END LOOP;
        END IF;

        IF (l_ship_to_location_id < g_cache_max_size AND l_deconsol_location IS NOT NULL) THEN
            g_location_mustuse_location(l_ship_to_location_id) := l_deconsol_location;
        ELSE
            g_location_mustuse_location(l_ship_to_location_id) := -1;
        END IF;
    --}
    END IF;

    -- If deconsolidation location not found, search for Customer - Facility constraints.


    IF l_deconsol_location IS NULL OR l_deconsol_location = -1 THEN

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'p_delivery_rec.CUSTOMER_ID: '|| p_delivery_rec.CUSTOMER_ID);
        END IF;

        l_customer_id := p_delivery_rec.CUSTOMER_ID;

        IF ( l_customer_id < g_cache_max_size  and g_customer_mustuse_location.EXISTS(l_customer_id)) THEN
            l_deconsol_location := g_customer_mustuse_location(l_customer_id);
            IF (l_deconsol_location = -1) THEN
                l_deconsol_location := NULL;
            END IF;
        ELSE
            --Does not exist in the cache.
            -- Compatibility_class_id is 2 for CUS_FAC constraints

            OPEN  c_get_must_use_location('CUS', l_customer_id, 2);
                FETCH c_get_must_use_location INTO l_deconsol_location;
                IF c_get_must_use_location%NOTFOUND THEN
                       l_deconsol_location := NULL;
                END IF;
            CLOSE c_get_must_use_location;

            IF (l_customer_id < g_cache_max_size AND l_deconsol_location IS NOT NULL) THEN
                g_customer_mustuse_location(l_customer_id) := l_deconsol_location;
            END IF;
        END IF;

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'l_deconsol_location from customer inclusive constraints: '|| l_deconsol_location);
        END IF;
    END IF;

    -- If no constraints defined for customer, search for Ship From ORG_FAC constraints

    IF l_deconsol_location IS NULL OR l_deconsol_location = -1 THEN

        l_constr_org_id := p_delivery_rec.organization_id;

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'p_delivery_rec.organization_id: '|| l_constr_org_id);
        END IF;

        IF (l_constr_org_id IS NOT NULL) THEN

            /*get_loc_for_org(
                p_org_id	       => p_delivery_rec.organization_id,
                x_location_id    => l_ship_from_location_id,
                x_return_status  => x_return_status);

            IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
            END IF;*/

            IF ( l_constr_org_id < g_cache_max_size AND g_org_mustuse_location.EXISTS(l_constr_org_id)) THEN

                l_deconsol_location := g_org_mustuse_location(l_constr_org_id);
            ELSE
                --Does not exist in the cache.
                -- Compatibility_class_id is 1 for CUS_FAC constraints
                OPEN  c_get_must_use_location('ORG', l_constr_org_id, 1);
                    FETCH c_get_must_use_location INTO l_deconsol_location;
                    IF c_get_must_use_location%NOTFOUND THEN
                           l_deconsol_location := NULL;
                    END IF;
                CLOSE c_get_must_use_location;
                -- Add to cache
                IF (l_constr_org_id < g_cache_max_size AND l_deconsol_location IS NOT NULL) THEN
                    g_org_mustuse_location(l_constr_org_id) := l_deconsol_location;
                ELSE
                    g_org_mustuse_location(l_constr_org_id) := -1;
                END IF;
            END IF;
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'l_deconsol_location from org inclusive constraints: '|| l_deconsol_location);
            END IF;

        END IF;

    END IF;

    -- If deconsol location not found from must use constraint on ship from location,
    -- fetch region level constraints and populate g_region_mustuse_location cache
    -- with region id and corresponding must use location id for all region level constraints
    -- defined.

    IF l_deconsol_location IS NULL OR l_deconsol_location = -1 THEN
    --{

        get_loc_for_org(
            p_org_id	       => p_delivery_rec.organization_id,
            x_location_id    => l_ship_from_location_id,
            x_return_status  => x_return_status);

        IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        IF g_region_mustuse_constraints.COUNT = 0 THEN
            OPEN c_get_region_incl_constraints;
                LOOP
                    FETCH c_get_region_incl_constraints INTO  l_constr_region_id, l_constr_location_id;
                    EXIT WHEN c_get_region_incl_constraints%NOTFOUND;
                    g_region_mustuse_location(l_constr_region_id) := l_constr_location_id;
                END LOOP;
            CLOSE c_get_region_incl_constraints;
        END IF;

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'g_region_mustuse_location.COUNT : '|| g_region_mustuse_location.COUNT);
        END IF;

    	WSH_REGIONS_SEARCH_PKG.Get_All_RegionId_Matches(
             p_location_id		=> l_ship_from_location_id,
             p_use_cache		=> TRUE,
             p_lang_code		=> USERENV('LANG'),
             x_region_tab		=> l_region_tab,
             x_return_status    => l_return_status);

	    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

        r_itr:= l_region_tab.FIRST;

        IF r_itr IS NOT NULL THEN
            LOOP
                l_region_id := l_region_tab(r_itr);

                IF l_region_id < g_cache_max_size AND g_region_mustuse_location.EXISTS(l_region_id) THEN
                    l_deconsol_location := g_region_mustuse_location(l_region_id);
                END IF;

                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'l_deconsol_location from g_region_mustuse_location: '|| l_deconsol_location);
                END IF;

                -- If deconsolidation location found, populate it in cache
                -- Else, search for zone level constraints

                IF (l_ship_to_location_id < g_cache_max_size AND l_deconsol_location IS NOT NULL) THEN
                    g_location_mustuse_location(l_ship_from_location_id) := l_deconsol_location;
                ELSIF l_deconsol_location IS NULL THEN
                    WSH_REGIONS_SEARCH_PKG.Get_All_Zone_Matches(
                      p_region_id		    => l_region_id,
                      x_zone_tab		    => l_zone_tab,
                      x_return_status       => l_return_status);

                     IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                          raise FND_API.G_EXC_UNEXPECTED_ERROR;
                       END IF;
                    END IF;

                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'l_zone_tab.COUNT: '|| l_zone_tab.COUNT);
                    END IF;

                    IF l_zone_tab.COUNT > 0 THEN
                        z_itr:= l_zone_tab.FIRST;
                        IF z_itr IS NOT NULL THEN
                            LOOP
                                l_zone_id := l_zone_tab(z_itr);
                                IF l_zone_id < g_cache_max_size AND g_region_mustuse_location.EXISTS(l_zone_id) THEN
                                    l_deconsol_location := g_region_mustuse_location(l_zone_id);
                                END IF;
                                EXIT WHEN z_itr = l_zone_tab.LAST OR l_deconsol_location IS NOT NULL;
                                z_itr:= l_zone_tab.NEXT(z_itr);
                            END LOOP;
                        END IF;
                    END IF;
                END IF;

                EXIT WHEN r_itr = l_region_tab.LAST OR l_deconsol_location IS NOT NULL;
                r_itr:= l_region_tab.NEXT(r_itr);
	        END LOOP;
        END IF;
        IF (l_ship_from_location_id < g_cache_max_size AND l_deconsol_location IS NOT NULL) THEN
            g_location_mustuse_location(l_ship_from_location_id) := l_deconsol_location;
        ELSE
            g_location_mustuse_location(l_ship_from_location_id) := -1;
        END IF;
    --}
    END IF;
    IF l_deconsol_location <> -1 THEN
        x_deconsol_location := l_deconsol_location;
    END IF;

    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
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
      IF c_get_must_use_location%ISOPEN THEN
         CLOSE c_get_must_use_location;
      END IF;
      /*IF c_get_must_use_cus_fac%ISOPEN THEN
         CLOSE c_get_must_use_cus_fac;
      END IF;*/
      IF c_get_region_incl_constraints%ISOPEN THEN
         CLOSE c_get_region_incl_constraints;
      END IF;

      WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.get_must_use_facility');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;

END get_must_use_facility;

--***************************************************************************--
--========================================================================
-- PROCEDURE : VALIDATE_CONSTRAINT_DECONSOL
--
-- PARAMETERS: p_init_msg_list             FND_API.G_TRUE to reset list
--             p_delivery_info             Table of delivery records to process
--                                         Only one of p_in_ids and p_delivery_info should be passed
--             p_in_ids                    Table of delivery ids to process
--             p_rule_deconsol_location    Default deconsolidation location passed
--             p_rule_override_deconsol    If true, default deconsolidation location passed
--                                         takes precedence.
--             x_output_id_tab             Output tab with deconsol location specified for deliveries
--             x_msg_count                 Number of messages in the list
--             x_msg_data                  Text of messages
--             x_return_status             Return status
-- COMMENT   : This procedure is to find deconsolidation locations for a group of deliveries passed
--
--             Deconsolidation location is searched for in the following sequence
--                if override flag is true
--                    if fte is installed
--                        check exclusive constraints
--                        if constraint faliure - error out del
--                   else
--                        set given loc as intermediate location
--                else
--                    get inter-med loc for delivery
--                    if fte is installed
--                       if intermediate loc not null
--                            check exclusive constraints - in case of failure - error out delivery
--                        else if null
--                            check inclusive contraints to get must use location
--                            if loc found
--                                check exclusive constraints for this location
--                            else if not found
--                                get deconsol location provided in region zones form
--                                if loc found
--                                    check exclusive constraints
--                                    if constraints faliure -  error out del
--                                else
--                                    check constraints on supplied location
--                                    use supplied location
--                    else if fte not installed
--                        check region-zones to get location
--                            if loc found
--                                use location found
--                            else
--                                use supplied location
--========================================================================

PROCEDURE validate_constraint_deconsol( p_init_msg_list          IN  VARCHAR2 DEFAULT fnd_api.g_false,
                                        p_delivery_info          IN  OUT NOCOPY delivery_ccinfo_tab_type,
                                        p_in_ids                 IN  wsh_util_core.id_tab_type,
                                        p_rule_deconsol_location IN  NUMBER default NULL,
                                        p_rule_override_deconsol IN  BOOLEAN  DEFAULT  FALSE,
                                        p_rule_to_zone_id        IN  NUMBER  DEFAULT  NULL,
                                        p_caller                 IN  VARCHAR2 DEFAULT NULL,
                                        x_output_id_tab          OUT NOCOPY deconsol_output_tab_type,
                                        x_return_status          OUT NOCOPY VARCHAR2,
                                        x_msg_count              OUT NOCOPY NUMBER,
                                        x_msg_data               OUT NOCOPY VARCHAR2
) IS

    l_return_status		        VARCHAR2(1);
    j                           NUMBER := 0;
    i                           NUMBER := 0;
    l_facility_id               NUMBER := 0;
    l_stop_id                   NUMBER := 0;
    --l_delivery_info             delivery_ccinfo_tab_type;
    l_failed_constraint         WSH_FTE_CONSTRAINT_FRAMEWORK.line_constraint_rec_type;
    l_validate_result           VARCHAR2(1) := 'S';
    l_physical_location_id      NUMBER := NULL;
    l_intermed_ship_to_loc_id   NUMBER;
    l_rule_deconsol_location    NUMBER;
    l_debug_on                  CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
    l_module_name               CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_CONSTRAINT_DECONSOL';
    rec_cnt                     NUMBER;
    l_region_tab                WSH_REGIONS_SEARCH_PKG.region_deconsol_Tab_Type;
    l_success                   VARCHAR2(1) := 'S';
    l_failure                   VARCHAR2(1) := 'F';
    l_zone_index                NUMBER := 0;
    l_msg_count                 NUMBER := 0;
    l_msg_data                  VARCHAR2(2000) := NULL;

    cursor c_gettrip(l_deliveryid IN NUMBER) is
    select wts.TRIP_ID
    from wsh_trip_stops wts, wsh_delivery_legs wdl
    where wdl.delivery_id =l_deliveryid AND
    wdl.pick_up_stop_id = wts.stop_id;


    CURSOR c_get_dlvy(c_delivery_id IN NUMBER) IS
    SELECT wnd.DELIVERY_ID
      , NULL
      , 'Y'
      , wnd.NAME
      , wnd.PLANNED_FLAG
      , wnd.STATUS_CODE
      , wnd.INITIAL_PICKUP_DATE
      , wnd.INITIAL_PICKUP_LOCATION_ID
      , wnd.ULTIMATE_DROPOFF_LOCATION_ID
      , wnd.ULTIMATE_DROPOFF_DATE
      , wnd.CUSTOMER_ID
      , wnd.INTMED_SHIP_TO_LOCATION_ID
      , wnd.SHIP_METHOD_CODE
      , wnd.DELIVERY_TYPE
      , wnd.CARRIER_ID
      , wnd.ORGANIZATION_ID
      , wnd.SERVICE_LEVEL
      , wnd.MODE_OF_TRANSPORT
      , wnd.PARTY_ID
      , nvl(wnd.SHIPMENT_DIRECTION,'O')
      , nvl(wnd.SHIPPING_CONTROL,'BUYER')
      , NULL  -- AGDUMMY
    FROM wsh_new_deliveries wnd
    WHERE wnd.delivery_id = c_delivery_id;

BEGIN

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    refresh_cache(l_return_status);

    IF l_debug_on THEN
      wsh_debug_sv.push (l_module_name);
      WSH_DEBUG_SV.logmsg(l_module_name,'p_delivery_info.COUNT: '||p_delivery_info.COUNT);
    END IF;

    IF p_delivery_info.COUNT = 0 THEN

        i := p_in_ids.FIRST;

        IF i IS NOT NULL THEN
            LOOP

                -- Fetch entire information for a particular record.

                OPEN  c_get_dlvy(p_in_ids(i));
                    FETCH c_get_dlvy into p_delivery_info(i);
                CLOSE c_get_dlvy;

                --#DUM_LOC(S)
                -- Delivery's ultimate_dropoff_location_id to be converted to physical internal
                -- location if it is a dummy location.
                -- We have to use the API for this purpose.

                WSH_LOCATIONS_PKG.CONVERT_INTERNAL_CUST_LOCATION(
                 p_internal_cust_location_id  => p_delivery_info(i).ultimate_dropoff_location_id,
                 x_internal_org_location_id   => l_physical_location_id,
                 x_return_status              => l_return_status);

                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
                END IF;

                --physical location id is not null implies- A dummy location.
                IF (l_physical_location_id IS NOT NULL) THEN
                --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Location '||p_delivery_info(i).ultimate_dropoff_location_id||' is a dummy location');
                    END IF;
                --
                    p_delivery_info(i).ultimate_dropoff_location_id := l_physical_location_id;
                    p_delivery_info(i).physical_dropoff_location_id := l_physical_location_id;
                END IF;
                --#DUM_LOC(E)

                OPEN c_gettrip(p_in_ids(i));
                    FETCH c_gettrip into p_delivery_info(i).TRIP_ID;
                CLOSE c_gettrip;

                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'p_delivery_info(i).delivery_id : '||p_delivery_info(i).delivery_id);
                    WSH_DEBUG_SV.logmsg(l_module_name,'p_delivery_info(i).initial_pickup_location_id : '||p_delivery_info(i).initial_pickup_location_id);
                    WSH_DEBUG_SV.logmsg(l_module_name,'p_delivery_info(i).ultimate_dropoff_location_id : '||p_delivery_info(i).ultimate_dropoff_location_id);
                    WSH_DEBUG_SV.logmsg(l_module_name,'p_delivery_info(i).intmed_ship_to_location_id : '||p_delivery_info(i).intmed_ship_to_location_id);
                END IF;
                --
                EXIT WHEN i = p_in_ids.LAST;
                i := p_in_ids.NEXT(i);
            END LOOP;
        END IF;
    END IF; -- p_delivery_info.COUNT = 0



    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'p_delivery_info.COUNT: '||p_delivery_info.COUNT);
        WSH_DEBUG_SV.logmsg(l_module_name, 'WSH_FTE_CONSTRAINT_FRAMEWORK.g_is_fte_installed: '||WSH_FTE_CONSTRAINT_FRAMEWORK.g_is_fte_installed);
        --WSH_DEBUG_SV.logmsg(l_module_name,'p_rule_override_deconsol: '||p_rule_override_deconsol);
    END IF;

    -- Loop through deliveries to set deconsol location for each delivery

    rec_cnt := p_delivery_info.FIRST;

    IF rec_cnt IS NOT NULL THEN
    --{
        LOOP
        --{
            IF p_delivery_info(rec_cnt).shipping_control = 'SUPPLIER'  THEN
                GOTO del_nextpass;
            END IF;
            IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'p_delivery_info(rec_cnt).delivery_id : '||p_delivery_info(rec_cnt).delivery_id);
            END IF;

            IF p_rule_override_deconsol = TRUE AND p_rule_deconsol_location IS NULL THEN
            --{
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'p_rule_override_deconsol = TRUE AND p_rule_deconsol_location IS NULL');
                END IF;
                x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                IF l_debug_on THEN
                    wsh_debug_sv.pop (l_module_name);
                END IF;
                return;
            --}
            ELSIF p_rule_override_deconsol = TRUE AND p_rule_deconsol_location IS NOT NULL THEN
            --{

                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'p_rule_override_deconsol = TRUE AND p_rule_deconsol_location IS NOT NULL');
                END IF;

                IF WSH_FTE_CONSTRAINT_FRAMEWORK.g_is_fte_installed = 'Y' THEN
                --{
                --
                -- FTE is installed, validate exclusive constraints for location supplied
                --
                    VALIDATE_EXCLUSIVE_CONSTRAINTS(p_delivery_rec            => p_delivery_info(rec_cnt),
                                                   p_rule_deconsol_location  => p_rule_deconsol_location,
                                                   x_validate_result         => l_validate_result,
                                                   x_return_status           => l_return_status);

                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'VALIDATE_EXCLUSIVE_CONSTRAINTS l_validate_result : '||l_validate_result);
                        WSH_DEBUG_SV.logmsg(l_module_name,'VALIDATE_EXCLUSIVE_CONSTRAINTS l_return_status : '||l_return_status);
                    END IF;

                    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR  OR l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
                         raise FND_API.G_EXC_UNEXPECTED_ERROR;
                    ELSE
                        IF l_validate_result = l_success THEN
                            x_output_id_tab(rec_cnt).deconsol_location := p_rule_deconsol_location;
                            x_output_id_tab(rec_cnt).entity_id := p_delivery_info(rec_cnt).delivery_id;
                            x_output_id_tab(rec_cnt).validation_status := l_success;
                            p_delivery_info(rec_cnt).intmed_ship_to_location_id := p_rule_deconsol_location;
                        ELSE
                            x_output_id_tab(rec_cnt).deconsol_location := NULL;
                            x_output_id_tab(rec_cnt).entity_id := p_delivery_info(rec_cnt).delivery_id;
                            x_output_id_tab(rec_cnt).validation_status := l_failure;
                            p_delivery_info(rec_cnt).intmed_ship_to_location_id := NULL;
                        END IF;
                    END IF;

                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'deconsol_location: '||x_output_id_tab(rec_cnt).deconsol_location);
                        WSH_DEBUG_SV.logmsg(l_module_name,'entity_id: '||x_output_id_tab(rec_cnt).entity_id);
                        WSH_DEBUG_SV.logmsg(l_module_name,'validation_status: '||x_output_id_tab(rec_cnt).validation_status);
                    END IF;

                    GOTO del_nextpass;
                --}
                ELSE
                --{
                    -- since fte is not installed and over-ride flag is true, set supplied location as
                    -- intermediate location
                    x_output_id_tab(rec_cnt).deconsol_location := p_rule_deconsol_location;
                    x_output_id_tab(rec_cnt).entity_id := p_delivery_info(rec_cnt).delivery_id;
                    x_output_id_tab(rec_cnt).validation_status := l_success;
                    p_delivery_info(rec_cnt).intmed_ship_to_location_id := p_rule_deconsol_location;

                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'deconsol_location: '||x_output_id_tab(rec_cnt).deconsol_location);
                        WSH_DEBUG_SV.logmsg(l_module_name,'entity_id: '||x_output_id_tab(rec_cnt).entity_id);
                        WSH_DEBUG_SV.logmsg(l_module_name,'validation_status: '||x_output_id_tab(rec_cnt).validation_status);
                    END IF;
                --}
                END IF;
                GOTO del_nextpass;
            --}
            ELSIF p_rule_override_deconsol = FALSE THEN
            --{
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'p_rule_override_deconsol IS FALSE');
                END IF;
                l_intermed_ship_to_loc_id := p_delivery_info(rec_cnt).intmed_ship_to_location_id;

                IF WSH_FTE_CONSTRAINT_FRAMEWORK.g_is_fte_installed = 'Y' THEN
                --{
                    IF l_intermed_ship_to_loc_id IS NOT NULL THEN
                    --{
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,'l_intermed_ship_to_loc_id: '|| l_intermed_ship_to_loc_id);
                        END IF;

                        VALIDATE_EXCLUSIVE_CONSTRAINTS(p_delivery_rec            => p_delivery_info(rec_cnt),
                                                       p_rule_deconsol_location  => l_intermed_ship_to_loc_id,
                                                       x_validate_result         => l_validate_result,
                                                       x_return_status           => l_return_status);

                        IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,'VALIDATE_EXCLUSIVE_CONSTRAINTS_validate_result : '||l_validate_result);
                            WSH_DEBUG_SV.logmsg(l_module_name,'VALIDATE_EXCLUSIVE_CONSTRAINTS_return_status : '||l_return_status);
                        END IF;

                        IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR  OR l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
                            raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        ELSE
                            IF l_validate_result = l_success THEN
                                x_output_id_tab(rec_cnt).deconsol_location := l_intermed_ship_to_loc_id;
                                x_output_id_tab(rec_cnt).entity_id := p_delivery_info(rec_cnt).delivery_id;
                                x_output_id_tab(rec_cnt).validation_status := l_success;
                                p_delivery_info(rec_cnt).intmed_ship_to_location_id := l_intermed_ship_to_loc_id;
                            ELSE
                                x_output_id_tab(rec_cnt).deconsol_location := NULL;
                                x_output_id_tab(rec_cnt).entity_id := p_delivery_info(rec_cnt).delivery_id;
                                x_output_id_tab(rec_cnt).validation_status := l_failure;
                                p_delivery_info(rec_cnt).intmed_ship_to_location_id := NULL;
                            END IF;

                            IF l_debug_on THEN
                                WSH_DEBUG_SV.logmsg(l_module_name,'deconsol_location: '||x_output_id_tab(rec_cnt).deconsol_location);
                                WSH_DEBUG_SV.logmsg(l_module_name,'entity_id: '||x_output_id_tab(rec_cnt).entity_id);
                                WSH_DEBUG_SV.logmsg(l_module_name,'validation_status: '||x_output_id_tab(rec_cnt).validation_status);
                            END IF;

                            GOTO del_nextpass;
                        END IF;
                    --}
                    ELSE
                    --{

                    -- intermediate location for delivery is NULL, get intermediate location from
                    -- must use constraints defined for the location

                        IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,'l_intermed_ship_to_loc_id IS NULL ');
                        END IF;

                        get_must_use_facility(p_delivery_rec => p_delivery_info(rec_cnt),
                                              x_deconsol_location => l_rule_deconsol_location,
                                              x_return_status   => l_return_status);

                        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                            END IF;
                        END IF;

                        IF l_rule_deconsol_location IS NOT NULL THEN
                        --{
                            VALIDATE_EXCLUSIVE_CONSTRAINTS(p_delivery_rec            => p_delivery_info(rec_cnt),
                                                           p_rule_deconsol_location  => l_rule_deconsol_location,
                                                           x_validate_result         => l_validate_result,
                                                           x_return_status           => l_return_status);

                            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR  OR l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                            ELSE
                                IF l_validate_result = l_success THEN
                                    x_output_id_tab(rec_cnt).deconsol_location := l_rule_deconsol_location;
                                    x_output_id_tab(rec_cnt).entity_id := p_delivery_info(rec_cnt).delivery_id;
                                    x_output_id_tab(rec_cnt).validation_status := l_success;
                                    p_delivery_info(rec_cnt).intmed_ship_to_location_id := l_rule_deconsol_location;
                                ELSE
                                    x_output_id_tab(rec_cnt).deconsol_location := NULL;
                                    x_output_id_tab(rec_cnt).entity_id := p_delivery_info(rec_cnt).delivery_id;
                                    x_output_id_tab(rec_cnt).validation_status := l_failure;
                                    p_delivery_info(rec_cnt).intmed_ship_to_location_id := NULL;
                                END IF;

                                IF l_debug_on THEN
                                    WSH_DEBUG_SV.logmsg(l_module_name,'deconsol_location: '||x_output_id_tab(rec_cnt).deconsol_location);
                                    WSH_DEBUG_SV.logmsg(l_module_name,'entity_id: '||x_output_id_tab(rec_cnt).entity_id);
                                    WSH_DEBUG_SV.logmsg(l_module_name,'validation_status: '||x_output_id_tab(rec_cnt).validation_status);
                                END IF;

                                GOTO del_nextpass;
                            END IF;
                        --}
                        ELSE
                        --{
                            -- Must use location not found from inclusive constraints.
                            -- obtain deconsol location specified through Regions and Zones Form

                            IF l_debug_on THEN
                                WSH_DEBUG_SV.logmsg(l_module_name,'p_delivery_info(rec_cnt).ULTIMATE_DROPOFF_LOCATION_ID: '||p_delivery_info(rec_cnt).ULTIMATE_DROPOFF_LOCATION_ID);
                            END IF;

                            WSH_REGIONS_SEARCH_PKG.get_all_region_deconsols
                                                ( p_location_id		    => p_delivery_info(rec_cnt).ULTIMATE_DROPOFF_LOCATION_ID,
                                                 p_use_cache		    => TRUE,
                                                 p_lang_code		    => USERENV('LANG'),
                                                 p_zone_flag            => TRUE,
                                                 p_rule_to_zone_id      => p_rule_to_zone_id,
                                                 p_caller               => p_caller,
                                                 x_region_consol_tab	=> l_region_tab,
                                                 x_return_status        => l_return_status);

                            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                END IF;
                            END IF;

                            --
                            -- First check if l_region_tab contains a zone matching
                            -- to p_rule_to_zone_id passed.
                            -- If yes, set the deconsol location for that zone
                            -- otherwise, set the deconsol location for the region where region_type <>10 (i.e.zone)
                            --
                            IF l_region_tab.COUNT > 0 THEN
                                --IF p_caller like 'WMS%' THEN
                                    l_rule_deconsol_location := l_region_tab(l_region_tab.FIRST).Deconsol_location;
                            ELSIF p_rule_deconsol_location IS NOT NULL THEN
                                l_rule_deconsol_location := p_rule_deconsol_location;
                            END IF;

                            IF l_rule_deconsol_location IS NOT NULL THEN

                                VALIDATE_EXCLUSIVE_CONSTRAINTS(p_delivery_rec            => p_delivery_info(rec_cnt),
                                                               p_rule_deconsol_location  => l_rule_deconsol_location,
                                                               x_validate_result         => l_validate_result,
                                                               x_return_status           => l_return_status);

                                IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR  OR l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
                                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                ELSE
                                    IF l_validate_result = l_success THEN
                                        x_output_id_tab(rec_cnt).deconsol_location := l_rule_deconsol_location;
                                        x_output_id_tab(rec_cnt).entity_id := p_delivery_info(rec_cnt).delivery_id;
                                        x_output_id_tab(rec_cnt).validation_status := l_success;
                                        p_delivery_info(rec_cnt).intmed_ship_to_location_id := l_rule_deconsol_location;
                                    ELSE
                                        x_output_id_tab(rec_cnt).deconsol_location := NULL;
                                        x_output_id_tab(rec_cnt).entity_id := p_delivery_info(rec_cnt).delivery_id;
                                        x_output_id_tab(rec_cnt).validation_status := l_failure;
                                        p_delivery_info(rec_cnt).intmed_ship_to_location_id := NULL;
                                    END IF;

                                    IF l_debug_on THEN
                                        WSH_DEBUG_SV.logmsg(l_module_name,'deconsol_location: '||x_output_id_tab(rec_cnt).deconsol_location);
                                        WSH_DEBUG_SV.logmsg(l_module_name,'entity_id: '||x_output_id_tab(rec_cnt).entity_id);
                                        WSH_DEBUG_SV.logmsg(l_module_name,'validation_status: '||x_output_id_tab(rec_cnt).validation_status);
                                    END IF;

                                    GOTO del_nextpass;
                                END IF;
                            ELSE
                                x_output_id_tab(rec_cnt).deconsol_location := NULL;
                                x_output_id_tab(rec_cnt).entity_id := p_delivery_info(rec_cnt).delivery_id;
                                x_output_id_tab(rec_cnt).validation_status := l_failure;
                                p_delivery_info(rec_cnt).intmed_ship_to_location_id := NULL;
                            END IF;
                        --}
                        END IF;
                    --}
                    END IF;
                --}
                ELSE -- if Fte is not installed, Use deconsol location from regions if intmed_shipto of the delivery is NULL,
                     -- if not found, use supplied value
                --{

                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'FTE installation status: '|| WSH_FTE_CONSTRAINT_FRAMEWORK.g_is_fte_installed);
                    END IF;
                    -- AG if intmed_shipto of the delivery is NOT NULL return that
                    -- else do the following

                    IF l_intermed_ship_to_loc_id IS NOT NULL THEN
                    --{
                                x_output_id_tab(rec_cnt).deconsol_location := l_intermed_ship_to_loc_id;
                                x_output_id_tab(rec_cnt).entity_id := p_delivery_info(rec_cnt).delivery_id;
                                x_output_id_tab(rec_cnt).validation_status := l_success;
                                p_delivery_info(rec_cnt).intmed_ship_to_location_id := l_intermed_ship_to_loc_id;
                    -- }
                    ELSE -- if
                    --{

                    WSH_REGIONS_SEARCH_PKG.get_all_region_deconsols
                                           ( p_location_id		    => p_delivery_info(rec_cnt).ULTIMATE_DROPOFF_LOCATION_ID,
                                             p_use_cache		    => TRUE,
                                             p_lang_code		    => USERENV('LANG'),
                                             p_zone_flag            => TRUE,
                                             p_rule_to_zone_id      => p_rule_to_zone_id,
                                             p_caller               => p_caller,
                                             x_region_consol_tab	=> l_region_tab,
                                             x_return_status        => l_return_status);

                    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                            raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                    END IF;

                    IF l_region_tab.COUNT > 0 THEN

                        --IF p_caller like 'WMS%' THEN
                            l_rule_deconsol_location := l_region_tab(l_region_tab.FIRST).Deconsol_location;
                        --l_rule_deconsol_location := l_region_tab(l_region_tab.FIRST).Deconsol_location;
                    ELSIF p_rule_deconsol_location IS NOT NULL THEN
                        l_rule_deconsol_location := p_rule_deconsol_location;
                    END IF;

                    IF l_rule_deconsol_location IS NOT NULL THEN
                        x_output_id_tab(rec_cnt).deconsol_location := l_rule_deconsol_location;
                        x_output_id_tab(rec_cnt).entity_id := p_delivery_info(rec_cnt).delivery_id;
                        x_output_id_tab(rec_cnt).validation_status := l_success;
                        p_delivery_info(rec_cnt).intmed_ship_to_location_id := l_rule_deconsol_location;

                        IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,'deconsol_location: '||x_output_id_tab(rec_cnt).deconsol_location);
                            WSH_DEBUG_SV.logmsg(l_module_name,'entity_id: '||x_output_id_tab(rec_cnt).entity_id);
                            WSH_DEBUG_SV.logmsg(l_module_name,'validation_status: '||x_output_id_tab(rec_cnt).validation_status);
                        END IF;
                    ELSE
                        x_output_id_tab(rec_cnt).deconsol_location := NULL;
                        x_output_id_tab(rec_cnt).entity_id := p_delivery_info(rec_cnt).delivery_id;
                        x_output_id_tab(rec_cnt).validation_status := l_failure;
                        p_delivery_info(rec_cnt).intmed_ship_to_location_id := NULL;
                    END IF;
                    --}
                    END IF;

                -- }
                END IF;
            --}
            END IF;

            <<del_nextpass>>

            EXIT WHEN rec_cnt = p_delivery_info.LAST;
            rec_cnt := p_delivery_info.NEXT(rec_cnt);
        --}
        END LOOP;
    --}
    END IF;

    FND_MSG_PUB.Count_And_Get (
        p_count         =>      l_msg_count,
        p_data          =>      l_msg_data ,
        p_encoded       =>      FND_API.G_FALSE );

    IF l_debug_on THEN
        wsh_debug_sv.log (l_module_name,'No. of messages already in stack : ',to_char(l_msg_count));
        WSH_DEBUG_SV.pop(l_module_name);
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
      IF c_gettrip%ISOPEN THEN
         CLOSE c_gettrip;
      END IF;
      IF c_get_dlvy%ISOPEN THEN
         CLOSE c_get_dlvy;
      END IF;
      WSH_UTIL_CORE.default_handler('WSH_FTE_CONSTRAINT_FRAMEWORK.validate_constraint_deconsol');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;

END validate_constraint_deconsol;

END WSH_FTE_CONSTRAINT_FRAMEWORK;


/
