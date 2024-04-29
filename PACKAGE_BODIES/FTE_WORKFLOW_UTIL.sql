--------------------------------------------------------
--  DDL for Package Body FTE_WORKFLOW_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_WORKFLOW_UTIL" AS
/* $Header: FTEWKFUB.pls 120.3 2005/08/12 13:52:02 schennal noship $ */

--===================
-- PUBLIC VARIABLES
--===================
    G_PKG_NAME CONSTANT VARCHAR2(30) := 'FTE_WORKFLOW_UTIL';

--========================================================================
-- CURSOR    : Get_Trip_Deliveries
--
-- PARAMETERS: c_trip_id       Trip Id
--
-- COMMENT   : Gets the deliveries assigned to the trip.
--========================================================================
    CURSOR Get_Trip_Deliveries(c_trip_id NUMBER)
    IS
        SELECT WDL.DELIVERY_ID
        FROM WSH_TRIP_STOPS WTS, WSH_DELIVERY_LEGS WDL
        WHERE WTS.STOP_ID = WDL.PICK_UP_STOP_ID
        AND WTS.TRIP_ID = c_trip_id;

--========================================================================
-- CURSOR    : Get_Dleg_Delivery
--
-- PARAMETERS: c_dleg_id       Delivery Leg Id
--
-- COMMENT   : Gets the delivery attached to the leg.
--========================================================================
    CURSOR Get_Dleg_Delivery(c_dleg_id NUMBER)
    IS
        SELECT WDL.DELIVERY_ID
        FROM WSH_DELIVERY_LEGS WDL
        WHERE WDL.DELIVERY_LEG_ID = c_dleg_id;

--========================================================================
-- CURSOR    : Get_Dleg_Trip
--
-- PARAMETERS: c_dleg_id       Delivery Leg Id
--
-- COMMENT   : Gets the trip to which the delivery leg is attached.
--========================================================================
    CURSOR Get_Dleg_Trip(c_dleg_id NUMBER)
    IS
        SELECT WTS.TRIP_ID
        FROM WSH_TRIP_STOPS WTS, WSH_DELIVERY_LEGS WDL
        WHERE WTS.STOP_ID = WDL.PICK_UP_STOP_ID
        AND WDL.DELIVERY_LEG_ID = c_dleg_id;

--========================================================================
-- CURSOR    : Get_Delivery_Org
--
-- PARAMETERS: c_del_id       Delivery Id
--
-- COMMENT   : Gets the organization id of the delivery
--========================================================================
    CURSOR Get_Delivery_Org(c_del_id NUMBER)
    IS
        SELECT ORGANIZATION_ID
        FROM WSH_NEW_DELIVERIES
        WHERE DELIVERY_ID = c_del_id;

--===================
-- PROCEDURES
--===================


--========================================================================
-- PROCEDURE : Single_Trip_Sel_Ser_Init
--
-- PARAMETERS: p_trip_id               Trip Id
--             x_return_status         Return status
--
-- COMMENT   : This procedure accepts a trip id and raises the Select Service
--             Initiated event for the trip.
--========================================================================
    PROCEDURE Single_Trip_Sel_Ser_Init(
                p_trip_id           IN NUMBER,
                x_return_status     OUT NOCOPY VARCHAR2)
    IS
        l_return_status     VARCHAR2(1);
        l_module_name       CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'SINGLE_TRIP_SEL_SER_INIT';
        l_debug_on          BOOLEAN;
    BEGIN
        l_debug_on := WSH_DEBUG_INTERFACE.g_debug;

        IF l_debug_on IS NULL
        THEN
            l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
        END IF;

        IF l_debug_on
        THEN
            WSH_DEBUG_SV.push(l_module_name);
            WSH_DEBUG_SV.log(l_module_name,'P_TRIP_ID',p_trip_id);
            WSH_DEBUG_SV.logmsg(l_module_name,'Raising event oracle.apps.fte.trip.svc.serviceselectioninitiated for trip '||p_trip_id);
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.RAISE_EVENT',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
        WSH_WF_STD.Raise_Event(
                p_entity_type   => 'TRIP',
                p_entity_id     =>  p_trip_id,
                p_event         => 'oracle.apps.fte.trip.svc.serviceselectioninitiated' ,
                x_return_status => l_return_status);

        IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
        OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
        THEN
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            IF l_debug_on
            THEN
                WSH_DEBUG_SV.logmsg(l_module_name, 'Error occurred in WSH_WF_STD.RAISE_EVENT');
                WSH_DEBUG_SV.logmsg(l_module_name, 'Unable to raise Select Service Init for trip '||p_trip_id);
            END IF;
        END IF;

        IF l_debug_on
        THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR
        THEN

            IF l_debug_on
            THEN
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
            END IF;
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        WHEN OTHERS
        THEN
            IF l_debug_on
            THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
            END IF;
            x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    END Single_Trip_Sel_Ser_Init;


--========================================================================
-- PROCEDURE : Single_Del_Sel_Ser
--
-- PARAMETERS: p_del_id                Delivery Id
--             p_org_id                Organization Id
--             x_return_status         Return status
--
-- COMMENT   : This procedure accepts a delivery id and raises the Select Service
--             event for the delivery.
--========================================================================
    PROCEDURE Single_Del_Sel_Ser(
                p_del_id           IN NUMBER,
                p_org_id           IN NUMBER,
                x_return_status     OUT NOCOPY VARCHAR2)
    IS
        l_return_status     VARCHAR2(1);
        l_module_name       CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'SINGLE_DEL_SEL_SER';
        l_debug_on          BOOLEAN;
    BEGIN
        l_debug_on := WSH_DEBUG_INTERFACE.g_debug;

        IF l_debug_on IS NULL
        THEN
            l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
        END IF;

        IF l_debug_on
        THEN
            WSH_DEBUG_SV.push(l_module_name);
            WSH_DEBUG_SV.log(l_module_name,'P_DEL_ID',p_del_id);
            WSH_DEBUG_SV.log(l_module_name,'P_ORG_ID',p_org_id);
            WSH_DEBUG_SV.logmsg(l_module_name,'Raising event oracle.apps.wsh.delivery.svc.serviceselected for delivery '||p_del_id||', org '||p_org_id);
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.RAISE_EVENT',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
        WSH_WF_STD.Raise_Event(
                p_entity_type   => 'DELIVERY',
                p_entity_id     =>  p_del_id,
                p_event         => 'oracle.apps.fte.delivery.svc.serviceselected',
                p_organization_id =>  p_org_id,
                x_return_status => l_return_status);

        IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
        OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
        THEN
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            IF l_debug_on
            THEN
                WSH_DEBUG_SV.logmsg(l_module_name, 'Error occurred in WSH_WF_STD.RAISE_EVENT');
                WSH_DEBUG_SV.logmsg(l_module_name, 'Unable to raise Select Service for delivery '||p_del_id||', org '||p_org_id);
            END IF;
        END IF;

        IF l_debug_on
        THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR
        THEN

            IF l_debug_on
            THEN
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
            END IF;
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        WHEN OTHERS
        THEN
            IF l_debug_on
            THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
            END IF;
            x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    END Single_Del_Sel_Ser;



--========================================================================
-- PROCEDURE : Single_Del_Can_Ser
--
-- PARAMETERS: p_del_id                Delivery Id
--             p_org_id                Organization Id
--             x_return_status         Return status
--
-- COMMENT   : This procedure accepts a delivery id and raises the Cancel Service
--             event for the delivery.
--========================================================================
    PROCEDURE Single_Del_Can_Ser(
                p_del_id           IN NUMBER,
                p_org_id           IN NUMBER,
                x_return_status     OUT NOCOPY VARCHAR2)
    IS
        l_return_status     VARCHAR2(1);
        l_module_name       CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'SINGLE_DEL_CAN_SER';
        l_debug_on          BOOLEAN;
    BEGIN
        l_debug_on := WSH_DEBUG_INTERFACE.g_debug;

        IF l_debug_on IS NULL
        THEN
            l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
        END IF;

        IF l_debug_on
        THEN
            WSH_DEBUG_SV.push(l_module_name);
            WSH_DEBUG_SV.log(l_module_name,'P_DEL_ID',p_del_id);
            WSH_DEBUG_SV.log(l_module_name,'P_ORG_ID',p_org_id);
            WSH_DEBUG_SV.logmsg(l_module_name,'Raising event oracle.apps.wsh.delivery.svc.servicecancelled for delivery '||p_del_id||', org '||p_org_id);
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.RAISE_EVENT',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
        WSH_WF_STD.Raise_Event(
                p_entity_type   => 'DELIVERY',
                p_entity_id     =>  p_del_id,
                p_event         => 'oracle.apps.fte.delivery.svc.servicecancelled',
                p_organization_id =>  p_org_id,
                x_return_status => l_return_status);

        IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
        OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
        THEN
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            IF l_debug_on
            THEN
                WSH_DEBUG_SV.logmsg(l_module_name, 'Error occurred in WSH_WF_STD.RAISE_EVENT');
                WSH_DEBUG_SV.logmsg(l_module_name, 'Unable to raise Cancel Service for delivery '||p_del_id||', org '||p_org_id);
            END IF;
        END IF;

        IF l_debug_on
        THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR
        THEN

            IF l_debug_on
            THEN
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
            END IF;
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        WHEN OTHERS
        THEN
            IF l_debug_on
            THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
            END IF;
            x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    END Single_Del_Can_Ser;


--========================================================================
-- PROCEDURE : Trip_Select_Service_Init
--
-- PARAMETERS: p_trip_id               Trip Id
--             x_return_status         Return status
--
-- COMMENT   : This procedure accepts a trip and calls the procedures which
--             raises the Service Selection Initiation for the trip and
--             Select Service event for all the deliveries assigned to the trip.
--========================================================================
    PROCEDURE Trip_Select_Service_Init(
                p_trip_id           IN NUMBER,
                x_return_status     OUT NOCOPY VARCHAR2)
    IS
        l_del_id            NUMBER;
        l_org_id            NUMBER;
        l_return_status     VARCHAR2(1);
        l_module_name       CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'TRIP_SELECT_SERVICE_INIT';
        l_debug_on          BOOLEAN;
    BEGIN

        l_debug_on := WSH_DEBUG_INTERFACE.g_debug;

        IF l_debug_on IS NULL
        THEN
            l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
        END IF;

        IF l_debug_on
        THEN
            WSH_DEBUG_SV.push(l_module_name);
            WSH_DEBUG_SV.log(l_module_name,'P_TRIP_ID',p_trip_id);
        END IF;

        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Raising Service Selection Initiated for the trip '||p_trip_id);
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit FTE_WORKFLOW_UTIL.SINGLE_TRIP_SEL_SER_INIT',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        Single_Trip_Sel_Ser_Init(
                    p_trip_id       => p_trip_id,
                    x_return_status => l_return_status);

        IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
        OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
        THEN
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            IF l_debug_on
            THEN
                WSH_DEBUG_SV.logmsg(l_module_name, 'Error occurred in FTE_WORKFLOW_UTIL.SINGLE_TRIP_SEL_SER_INIT');
                WSH_DEBUG_SV.logmsg(l_module_name, 'Raising Select Service Initiated for the trip '||p_trip_id||' failed');
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF l_debug_on
        THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Fetching the deliveries assigned to the trip');
        END IF;

        OPEN Get_Trip_Deliveries(p_trip_id);
        LOOP
            FETCH Get_Trip_Deliveries INTO l_del_id;
            EXIT WHEN Get_Trip_Deliveries%NOTFOUND;

            OPEN Get_Delivery_Org(l_del_id);
            FETCH Get_Delivery_Org INTO l_org_id;
            CLOSE Get_Delivery_Org;

            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Got delivery '||l_del_id);
                WSH_DEBUG_SV.logmsg(l_module_name,'Raising Service Selection for the delivery '||l_del_id);
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit FTE_WORKFLOW_UTIL.SINGLE_DEL_SEL_SER',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

            Single_Del_Sel_Ser(
                    p_del_id        => l_del_id,
                    p_org_id        => l_org_id,
                    x_return_status => l_return_status);

            IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
            OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
            THEN
                x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                IF l_debug_on
                THEN
                    WSH_DEBUG_SV.logmsg(l_module_name, 'Error occurred in FTE_WORKFLOW_UTIL.SINGLE_DEL_SEL_SER');
                    WSH_DEBUG_SV.logmsg(l_module_name, 'Raising Select Service for the delivery '||l_del_id||' failed');
                END IF;
            END IF;

        END LOOP;
        CLOSE Get_Trip_Deliveries;

        IF l_debug_on
        THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR
        THEN

            IF l_debug_on
            THEN
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
            END IF;
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        WHEN OTHERS
        THEN
            IF l_debug_on
            THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
            END IF;
            x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    END Trip_Select_Service_Init;


--========================================================================
-- PROCEDURE : Trip_Cancel_Service
--
-- PARAMETERS: p_trip_id               Trip Id
--             x_return_status         Return status
--
-- COMMENT   : This procedure accepts a trip and calls the procedures which
--             raises the Cancel Service event for all the deliveries
--             assigned to the trip.
--========================================================================
    PROCEDURE Trip_Cancel_Service(
            p_trip_id           IN NUMBER,
            x_return_status     OUT NOCOPY VARCHAR2)

    IS
        l_del_id            NUMBER;
        l_org_id            NUMBER;
        l_return_status     VARCHAR2(1);
        l_module_name       CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'TRIP_CANCEL_SERVICE';
        l_debug_on          BOOLEAN;
    BEGIN

        l_debug_on := WSH_DEBUG_INTERFACE.g_debug;

        IF l_debug_on IS NULL
        THEN
            l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
        END IF;

        IF l_debug_on
        THEN
            WSH_DEBUG_SV.push(l_module_name);
            WSH_DEBUG_SV.log(l_module_name,'P_TRIP_ID',p_trip_id);
        END IF;

        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

        IF l_debug_on
        THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Fetching the deliveries assigned to the trip');
        END IF;

        OPEN Get_Trip_Deliveries(p_trip_id);
        LOOP
            FETCH Get_Trip_Deliveries INTO l_del_id;
            EXIT WHEN Get_Trip_Deliveries%NOTFOUND;

            OPEN Get_Delivery_Org(l_del_id);
            FETCH Get_Delivery_Org INTO l_org_id;
            CLOSE Get_Delivery_Org;

            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Got delivery '||l_del_id);
                WSH_DEBUG_SV.logmsg(l_module_name,'Raising Service Cancellation for the delivery '||l_del_id);
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit FTE_WORKFLOW_UTIL.SINGLE_DEL_CAN_SER',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

            Single_Del_Can_Ser(
                    p_del_id        => l_del_id,
                    p_org_id        => l_org_id,
                    x_return_status => l_return_status);

            IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
            OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
            THEN
                x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                IF l_debug_on
                THEN
                    WSH_DEBUG_SV.logmsg(l_module_name, 'Error occurred in FTE_WORKFLOW_UTIL.SINGLE_DEL_CAN_SER');
                    WSH_DEBUG_SV.logmsg(l_module_name, 'Raising Cancel Service for the delivery '||l_del_id||' failed');
                END IF;
            END IF;

        END LOOP;
        CLOSE Get_Trip_Deliveries;

        IF l_debug_on
        THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR
        THEN

            IF l_debug_on
            THEN
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
            END IF;
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        WHEN OTHERS
        THEN
            IF l_debug_on
            THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
            END IF;
            x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    END Trip_Cancel_Service;


    --========================================================================
-- PROCEDURE : Dleg_Select_Service
--
-- PARAMETERS: p_dleg_id               Delivery Leg Id
--             x_return_status         Return status
--
-- COMMENT   : This procedure accepts a delivery leg and calls the procedures which
--             raises the Select Service Event for the delivery and Select Service
--             Initiation event for the trip to which the delivery is assigned.
--========================================================================
    PROCEDURE Dleg_Select_Service(
                p_dleg_id           IN NUMBER,
                x_return_status     OUT NOCOPY VARCHAR2)
    IS
        l_trip_id           NUMBER;
        l_del_id            NUMBER;
        l_org_id            NUMBER;
        l_return_status     VARCHAR2(1);
        l_module_name       CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'DLEG_SELECT_SERVICE';
        l_debug_on          BOOLEAN;
    BEGIN
        l_debug_on := WSH_DEBUG_INTERFACE.g_debug;

        IF l_debug_on IS NULL
        THEN
            l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
        END IF;

        IF l_debug_on
        THEN
            WSH_DEBUG_SV.push(l_module_name);
            WSH_DEBUG_SV.log(l_module_name,'P_DLEG_ID',p_dleg_id);
        END IF;

        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

        OPEN Get_Dleg_Delivery(p_dleg_id);
        FETCH Get_Dleg_Delivery INTO l_del_id;
        CLOSE Get_Dleg_Delivery;

        IF l_del_id IS NULL
        THEN
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Failed to fetch the delivery associated with the delivery leg');
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        OPEN Get_Delivery_Org(l_del_id);
        FETCH Get_Delivery_Org INTO l_org_id;
        CLOSE Get_Delivery_Org;

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Raising Service Selection for the delivery '||l_del_id);
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit FTE_WORKFLOW_UTIL.SINGLE_DEL_SEL_SER',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        Single_Del_Sel_Ser(
                    p_del_id        => l_del_id,
                    p_org_id        => l_org_id,
                    x_return_status => l_return_status);

        IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
        OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
        THEN
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            IF l_debug_on
            THEN
                WSH_DEBUG_SV.logmsg(l_module_name, 'Error occurred in FTE_WORKFLOW_UTIL.SINGLE_DEL_SEL_SER');
                WSH_DEBUG_SV.logmsg(l_module_name, 'Raising Select Service for the delivery '||l_del_id||' failed');
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Fetching trip to which the delivery '||l_del_id||' is assigned');
        END IF;

        OPEN Get_Dleg_Trip(p_dleg_id);
        FETCH Get_Dleg_Trip INTO l_trip_id;
        CLOSE Get_Dleg_Trip;

        IF l_trip_id IS NOT NULL
        THEN

            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Found trip '||l_trip_id);
                WSH_DEBUG_SV.logmsg(l_module_name,'Raising Service Selection Initiated for the trip '||l_trip_id);
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit FTE_WORKFLOW_UTIL.SINGLE_TRIP_SEL_SER_INIT',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

            Single_Trip_Sel_Ser_Init(
                    p_trip_id       => l_trip_id,
                    x_return_status => l_return_status);

            IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
            OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
            THEN
                x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                IF l_debug_on
                THEN
                    WSH_DEBUG_SV.logmsg(l_module_name, 'Error occurred in FTE_WORKFLOW_UTIL.SINGLE_TRIP_SEL_SER_INIT');
                    WSH_DEBUG_SV.logmsg(l_module_name, 'Raising Select Service for the trip '||l_trip_id||' failed');
                END IF;
            END IF;
        ELSE
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'No trip found trip');
            END IF;
        END IF;

        IF l_debug_on
        THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR
        THEN

            IF l_debug_on
            THEN
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
            END IF;
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        WHEN OTHERS
        THEN
            IF l_debug_on
            THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
            END IF;
            x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    END Dleg_Select_Service;


--========================================================================
-- PROCEDURE : Dleg_Cancel_Service
--
-- PARAMETERS: p_dleg_id               Delivery Leg Id
--             x_return_status         Return status
--
-- COMMENT   : This procedure accepts a delivery leg and calls the procedure which
--             raises the Cancel Service Event for the delivery.
--========================================================================
    PROCEDURE Dleg_Cancel_Service(
                p_dleg_id           IN NUMBER,
                x_return_status     OUT NOCOPY VARCHAR2)
    IS
        l_del_id        NUMBER;
        l_org_id            NUMBER;
        l_return_status VARCHAR2(1);
        l_module_name       CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'DLEG_CANCEL_SERVICE';
        l_debug_on          BOOLEAN;
    BEGIN
        l_debug_on := WSH_DEBUG_INTERFACE.g_debug;

        IF l_debug_on IS NULL
        THEN
            l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
        END IF;

        IF l_debug_on
        THEN
            WSH_DEBUG_SV.push(l_module_name);
            WSH_DEBUG_SV.log(l_module_name,'P_DLEG_ID',p_dleg_id);
        END IF;

        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

        OPEN Get_Dleg_Delivery(p_dleg_id);
        FETCH Get_Dleg_Delivery INTO l_del_id;
        CLOSE Get_Dleg_Delivery;

        IF l_del_id IS NULL
        THEN
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Failed to fetch the delivery associated with the delivery leg');
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        OPEN Get_Delivery_Org(l_del_id);
        FETCH Get_Delivery_Org INTO l_org_id;
        CLOSE Get_Delivery_Org;

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Raising Cancel Service for the delivery '||l_del_id);
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit FTE_WORKFLOW_UTIL.SINGLE_DEL_CAN_SER',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        Single_Del_Can_Ser(
                p_del_id        => l_del_id,
                p_org_id        => l_org_id,
                x_return_status => l_return_status);

        IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
        OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
        THEN
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            IF l_debug_on
            THEN
                WSH_DEBUG_SV.logmsg(l_module_name, 'Error occurred in FTE_WORKFLOW_UTIL.SINGLE_DEL_CAN_SER');
                WSH_DEBUG_SV.logmsg(l_module_name, 'Raising Cancel Service for the delivery '||l_del_id||' failed');
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF l_debug_on
        THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR
        THEN

            IF l_debug_on
            THEN
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
            END IF;
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        WHEN OTHERS
        THEN
            IF l_debug_on
            THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
            END IF;
            x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    END Dleg_Cancel_Service;


END FTE_WORKFLOW_UTIL;

/
