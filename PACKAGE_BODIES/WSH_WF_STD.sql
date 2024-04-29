--------------------------------------------------------
--  DDL for Package Body WSH_WF_STD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_WF_STD" AS
/* $Header: WSHWSTDB.pls 120.12.12010000.4 2010/03/11 07:33:06 sankarun ship $ */

G_PKG_NAME 	CONSTANT VARCHAR2(30):='WSH_WF_STD';
G_NO_WORKFLOW   CONSTANT VARCHAR2(30):='NO_WORLFLOW_98';

/*PROCEDURE Test_Events(p_entity_type IN VARCHAR2,
                      p_entity_id IN NUMBER,
                      p_send_date IN DATE,
                      p_event IN VARCHAR2) IS

l_return_status VARCHAR2(1);
l_exception_msg_count NUMBER;
l_exception_msg_data varchar2(2000);
l_exception_id NUMBER := NULL;
l_msg   varchar2(2000);
l_ship_from_location_id NUMBER := 207;--For testing purposes, change if not valid.

BEGIN

  l_msg := 'Event '||p_event||' raised on date '||p_send_date||' for entity '||p_entity_type||' with ID '||p_entity_id;

IF p_entity_type = 'DELIVERY' THEN

  wsh_xc_util.log_exception(
                            p_api_version             => 1.0,
                            x_return_status           => l_return_status,
                            x_msg_count               => l_exception_msg_count,
                            x_msg_data                => l_exception_msg_data,
                            x_exception_id            => l_exception_id ,
                            p_logged_at_location_id   => l_ship_from_location_id,
                            p_exception_location_id   => l_ship_from_location_id,
                            p_logging_entity          => 'SHIPPER',
                            p_logging_entity_id       => FND_GLOBAL.USER_ID,
                            p_exception_name          => 'WSH_WF_BES',
                            p_message                 => l_msg,
                            p_delivery_id             => p_entity_id
                           );

ELSIF p_entity_type = 'TRIP' THEN

  wsh_xc_util.log_exception(
                            p_api_version             => 1.0,
                            x_return_status           => l_return_status,
                            x_msg_count               => l_exception_msg_count,
                            x_msg_data                => l_exception_msg_data,
                            x_exception_id            => l_exception_id ,
                            p_logged_at_location_id   => l_ship_from_location_id,
                            p_exception_location_id   => l_ship_from_location_id,
                            p_logging_entity          => 'SHIPPER',
                            p_logging_entity_id       => FND_GLOBAL.USER_ID,
                            p_exception_name          => 'WSH_WF_BES',
                            p_message                 => l_msg,
                            p_trip_id                 => p_entity_id
                           );


ELSIF p_entity_type = 'STOP' THEN

  wsh_xc_util.log_exception(
                            p_api_version             => 1.0,
                            x_return_status           => l_return_status,
                            x_msg_count               => l_exception_msg_count,
                            x_msg_data                => l_exception_msg_data,
                            x_exception_id            => l_exception_id ,
                            p_logged_at_location_id   => l_ship_from_location_id,
                            p_exception_location_id   => l_ship_from_location_id,
                            p_logging_entity          => 'SHIPPER',
                            p_logging_entity_id       => FND_GLOBAL.USER_ID,
                            p_exception_name          => 'WSH_WF_BES',
                            p_message                 => l_msg,
                            p_trip_stop_id            => p_entity_id
                           );


ELSIF p_entity_type = 'LINE' THEN

  wsh_xc_util.log_exception(
                            p_api_version             => 1.0,
                            x_return_status           => l_return_status,
                            x_msg_count               => l_exception_msg_count,
                            x_msg_data                => l_exception_msg_data,
                            x_exception_id            => l_exception_id ,
                            p_logged_at_location_id   => l_ship_from_location_id,
                            p_exception_location_id   => l_ship_from_location_id,
                            p_logging_entity          => 'SHIPPER',
                            p_logging_entity_id       => FND_GLOBAL.USER_ID,
                            p_exception_name          => 'WSH_WF_BES',
                            p_message                 => l_msg,
                            p_delivery_detail_id      => p_entity_id
                           );

END IF;

END Test_Events;
*/
---------------------------------------------------------------------------------------
--
-- Procedure:       Start_Wf_Process
-- Parameters:      p_entity_type - 'TRIP','DELIVERY'
--		    p_entity_id   - TRIP_ID or DELIVERY_ID
--                  p_organization_id - The Organization Id
--
--                  x_process_started - 'Y' Process started;
--                                      'E' Process already exists
--                                      'N' Process not started
--                  x_return_status - Returns WSH_UTIL_CORE.G_RET_STS_SUCCESS if Success

-- Description:     This Procedure selects and starts a Tracking Workflow process
--                  for an entity - Trip/Delivery after checking if it is eligible.
--                  i.e.1) No Process exists already for the Entity
--                      2) Global and Shipping parameters for the entity admits
--                  Finally updates the WSH_NEW_DELIVERIES or WSH_TRIPS with the
--                  Process name that was launched.
--
---------------------------------------------------------------------------------------

PROCEDURE Start_Wf_Process(
		p_entity_type IN VARCHAR2,
		p_entity_id IN	NUMBER,
                p_organization_id IN NUMBER DEFAULT NULL,
                x_process_started OUT NOCOPY VARCHAR2,
		x_return_status OUT NOCOPY VARCHAR2) IS


l_itemtype VARCHAR2(30);
l_itemkey VARCHAR2(30);
l_process_name VARCHAR2(30);

CURSOR get_customer_name(p_delivery_id IN NUMBER) IS
SELECT substrb(party.party_name,1,50)
FROM
    hz_parties party,
    hz_cust_accounts cust_acct,
    wsh_new_deliveries wnd
WHERE
    cust_acct.cust_account_id = wnd.customer_id and
    cust_acct.party_id = party.party_id and
    wnd.delivery_id = p_delivery_id;

l_wf_process_exists VARCHAR2(1);
l_start_wf_process VARCHAR2(1);
l_return_status VARCHAR2(1);

l_customer_name VARCHAR2(50);
l_aname_num    wf_engine.nametabtyp;
l_avalue_num   wf_engine.numtabtyp;
l_aname_text   wf_engine.nametabtyp;
l_avalue_text  wf_engine.texttabtyp;

l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'START_WF_PROCESS';
l_debug_on BOOLEAN;

BEGIN

-- Debug Statements
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
    WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_TYPE',p_entity_type);
    WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_ID',p_entity_id);
    WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',p_organization_id);
END IF;

x_process_started := 'N';
x_return_status:=WSH_UTIL_CORE.G_RET_STS_SUCCESS;
SAVEPOINT	START_WF_PROCESS_UPDATE;

IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.CHECK_WF_EXISTS',
WSH_DEBUG_SV.C_PROC_LEVEL);
END IF;

Check_Wf_Exists(p_entity_type       => p_entity_type,
                p_entity_id         => p_entity_id,
		x_wf_process_exists => l_wf_process_exists,
		x_return_status     => l_return_status);

IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_wf_process_exists',l_wf_process_exists);
    WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
END IF;

IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
    x_return_status := l_return_status;
    IF l_debug_on THEN
	   WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
END IF;
IF (l_wf_process_exists = 'Y') THEN
    x_process_started := 'E';
    IF l_debug_on THEN
	   WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.CONFIRM_START_WF_PROCESS',
WSH_DEBUG_SV.C_PROC_LEVEL);
END IF;

Confirm_Start_Wf_Process(p_entity_type      => p_entity_type,
                         p_organization_id  => p_organization_id,
			 x_start_wf_process => l_start_wf_process,
			 x_return_status    => l_return_status);

IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_start_wf_process',l_start_wf_process);
    WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
END IF;

IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
    x_return_status := l_return_status;
    IF l_debug_on THEN
	   WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
END IF;
IF (l_start_wf_process = 'N') THEN
    IF l_debug_on THEN
	   WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
end if;

-- invoke the workflow
l_itemkey:=p_entity_id;

IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.PROCESS_SELECTOR',
WSH_DEBUG_SV.C_PROC_LEVEL);
END IF;

Process_Selector(p_entity_type     => p_entity_type,
                 p_entity_id       => p_entity_id,
		 p_organization_id => p_organization_id,
		 x_wf_process      => l_process_name,
		 x_return_status   => l_return_status);

IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_process_name',l_process_name);
    WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
END IF;

IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
    x_return_status := l_return_status;
    IF l_debug_on THEN
	   WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
END IF;

IF (l_process_name = G_NO_WORKFLOW) THEN
    IF l_debug_on THEN
	   WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
END IF;

IF (p_entity_type = 'DELIVERY') THEN
    l_itemtype:='WSHDEL';
ELSE
    l_itemtype:='WSHTRIP';
END IF;

WF_ENGINE.Createprocess(itemtype => l_itemtype,
                        itemkey  => l_itemkey,
			process  => l_process_name);

l_aname_num(1) := 'USER_ID';
l_avalue_num(1) := FND_GLOBAL.USER_ID;
l_aname_num(2) := 'APPLICATION_ID';
l_avalue_num(2) := FND_GLOBAL.RESP_APPL_ID;
l_aname_num(3) := 'RESPONSIBILITY_ID';
l_avalue_num(3) := FND_GLOBAL.RESP_ID;

WF_ENGINE.SetItemAttrNumberArray(
  	    itemtype => l_itemtype,
	    itemkey  => l_itemkey,
	    aname    => l_aname_num,
	    avalue   => l_avalue_num);

IF (p_entity_type = 'DELIVERY') THEN

    OPEN get_customer_name(p_entity_id);
    FETCH get_customer_name INTO l_customer_name;
    IF get_customer_name%NOTFOUND THEN
        l_customer_name := null; -- do not set CUSTOMER_NAME then
    END IF;
    CLOSE get_customer_name;

    l_aname_text(1) := 'DELIVERY_ID';
    l_avalue_text(1) := to_char(p_entity_id);
    l_aname_text(2) := 'ORG_ID';
    l_avalue_text(2) := to_char(p_organization_id);
    l_aname_text(3) := 'DELIVERY_NAME';
    l_avalue_text(3) := to_char(p_entity_id);
    l_aname_text(4) := 'NOTIFICATION_FROM_ROLE';
    l_avalue_text(4) := 'WFADMIN';
    l_aname_text(5) := 'NOTIFICATION_TO_ROLE';
    l_avalue_text(5) := FND_GLOBAL.USER_NAME;
    l_aname_text(6) := 'CUSTOMER_NAME';
    l_avalue_text(6) := l_customer_name;

    WF_ENGINE.SetItemAttrTextArray(
		itemtype => l_itemtype,
		itemkey  => l_itemkey,
		aname    => l_aname_text,
		avalue   => l_avalue_text);

ELSIF(p_entity_type = 'TRIP') THEN

    WF_ENGINE.SetItemAttrText(
                itemtype => l_itemtype,
                itemkey  => l_itemkey,
                aname => 'TRIP_ID',
                avalue => to_char(p_entity_id));
END IF;

WF_ENGINE.Startprocess(itemtype => l_itemtype,
                       itemkey  => l_itemkey);

IF (p_entity_type = 'DELIVERY') THEN
    UPDATE WSH_NEW_DELIVERIES
        SET DELIVERY_WF_PROCESS=l_process_name
        WHERE delivery_id=p_entity_id;
ELSE
    UPDATE WSH_TRIPS
        SET TRIP_WF_PROCESS=l_process_name
        WHERE trip_id=p_entity_id;
END IF;
x_process_started:= 'Y';
IF l_debug_on THEN
   WSH_DEBUG_SV.pop(l_module_name);
END IF;



EXCEPTION
WHEN no_data_found THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'No record found for the entity.Oracle error message is '||
SQLERRM,WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NO_DATA_FOUND');
    END IF;
WHEN others THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
END Start_Wf_Process;

---------------------------------------------------------------------------------------
--
-- Procedure:       Start_Scpod_C_Process
-- Parameters:      p_entity_id   - DELIVERY_ID (Entity is always Delivery)
--                  p_organization_id - The Organization Id
--
--                  x_process_started - 'Y' Process started;
--                                      'E' Process already exists
--                                      'N' Process not started
--                  x_return_status - Returns WSH_UTIL_CORE.G_RET_STS_SUCCESS if Success
--
-- Description:     This Procedure starts the 'Ship to Deliver' controlling
--                  Workflow process for the Delivery after checking
--                  if it is eligible.
--                  i.e.1) No Process exists already for the Delivery
--                      2) Global and Shipping parameters for the entity admits
--
--
---------------------------------------------------------------------------------------

PROCEDURE Start_Scpod_C_Process(
		p_entity_id IN	NUMBER,
                p_organization_id IN NUMBER,
                x_process_started OUT NOCOPY VARCHAR2,
		x_return_status OUT NOCOPY VARCHAR2) IS


l_param_info WSH_SHIPPING_PARAMS_PVT.Parameter_Rec_Typ;
l_global_parameters WSH_SHIPPING_PARAMS_PVT.Global_Parameters_Rec_Typ;

l_itemtype VARCHAR2(30);
l_itemkey  VARCHAR2(30);

CURSOR get_org_code IS
SELECT organization_code
FROM MTL_PARAMETERS
WHERE organization_id  = p_organization_id;

CURSOR get_customer_name(p_delivery_id IN NUMBER) IS
SELECT substrb(party.party_name,1,50)
FROM
    hz_parties party,
    hz_cust_accounts cust_acct,
    wsh_new_deliveries wnd
WHERE
    cust_acct.cust_account_id = wnd.customer_id and
    cust_acct.party_id = party.party_id and
    wnd.delivery_id = p_delivery_id;

l_customer_name     VARCHAR2(50);
l_organization_code VARCHAR2(3);
l_custom_process_name VARCHAR2(30);

l_scpod_wf_process_exists VARCHAR2(1);
l_return_status VARCHAR2(1);

l_aname_num    wf_engine.nametabtyp;
l_avalue_num   wf_engine.numtabtyp;
l_aname_text   wf_engine.nametabtyp;
l_avalue_text  wf_engine.texttabtyp;

l_override_wf VARCHAR2(1);
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'START_SCPOD_C_PROCESS';
l_debug_on BOOLEAN;


BEGIN

-- Debug Statements
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
    WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_ID',p_entity_id);
    WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',p_organization_id);
END IF;
SAVEPOINT START_SCPOD_C_PROCESS_UPDATE;

l_itemtype := 'WSHDEL';
l_itemkey  := p_entity_id;
x_process_started := 'N';
x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

l_override_wf:= fnd_profile.value('WSH_OVERRIDE_SCPOD_WF');
IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'L_OVERRIDE_WF',l_override_wf);
END IF;
IF (nvl(l_override_wf,'N') = 'Y') THEN
    IF l_debug_on THEN
	   WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.CHECK_WF_EXISTS',
WSH_DEBUG_SV.C_PROC_LEVEL);
END IF;

check_wf_exists(p_entity_type       => 'DELIVERY_C',
                p_entity_id         => p_entity_id,
		x_wf_process_exists => l_scpod_wf_process_exists,
		x_return_status     => l_return_status);

IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'L_SCPOD_WF_PROCESS_EXISTS',l_scpod_wf_process_exists);
    WSH_DEBUG_SV.log(l_module_name,'L_RETURN_STATUS',l_return_status);
END IF;

IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
    x_return_status := l_return_status;
    IF l_debug_on THEN
	   WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
END IF;

IF (l_scpod_wf_process_exists = 'Y') THEN
    x_process_started := 'E';
    IF l_debug_on THEN
	   WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
ELSE

    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIPPING_PARAMS_PVT.GET',
WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;

    WSH_SHIPPING_PARAMS_PVT.Get(
            p_organization_id => p_organization_id,
            x_param_info      => l_param_info,
            x_return_status   => l_return_status);
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
    END IF;

    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
        x_return_status := l_return_status;
        IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        RETURN;
    END IF;

    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIPPING_PARAMS_PVT.GET_GLOBAL_PARAMETERS',
WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;

    WSH_SHIPPING_PARAMS_PVT.Get_Global_Parameters(x_Param_Info    => l_global_parameters,
                                                  x_return_status => l_return_status);

    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'L_RETURN_STATUS',l_return_status);
    END IF;

    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
        x_return_status := l_return_status;
        IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        RETURN;
    END IF;

    IF (NVL(l_global_parameters.ENABLE_SC_WF,'N') = 'Y' and NVL(l_param_info.ENABLE_SC_WF,'N') = 'Y') THEN
        -- Get custom process if any
        OPEN get_org_code;
        FETCH get_org_code into l_organization_code;
        CLOSE get_org_code ;

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.GET_CUSTOM_WF_PROCESS',
        WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        Get_Custom_Wf_Process(p_wf_process    => 'R_SCPOD_C',
	                      p_org_code      => l_organization_code,
			      x_wf_process    => l_custom_process_name,
			      x_return_status => l_return_status);
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_custom_process_name',l_custom_process_name);
            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
        END IF;

        IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            x_return_status := l_return_status;
            IF l_debug_on THEN
               WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            RETURN;
        END IF;

        WF_ENGINE.CreateProcess(itemtype => 'WSHDEL',
	                        itemkey  => p_entity_id,
				process  => l_custom_process_name);

	l_aname_num(1) := 'USER_ID';
	l_avalue_num(1) := FND_GLOBAL.USER_ID;
	l_aname_num(2) := 'APPLICATION_ID';
	l_avalue_num(2) := FND_GLOBAL.RESP_APPL_ID;
	l_aname_num(3) := 'RESPONSIBILITY_ID';
	l_avalue_num(3) := FND_GLOBAL.RESP_ID;

	WF_ENGINE.SetItemAttrNumberArray(
		    itemtype => l_itemtype,
		    itemkey  => l_itemkey,
		    aname    => l_aname_num,
		    avalue   => l_avalue_num);

	OPEN get_customer_name(p_entity_id);
	FETCH get_customer_name INTO l_customer_name;
	IF get_customer_name%NOTFOUND THEN
	l_customer_name := null; -- do not set CUSTOMER_NAME then
	END IF;
	CLOSE get_customer_name;

	l_aname_text(1) := 'DELIVERY_ID';
	l_avalue_text(1) := to_char(p_entity_id);
	l_aname_text(2) := 'ORG_ID';
	l_avalue_text(2) := to_char(p_organization_id);
	l_aname_text(3) := 'DELIVERY_NAME';
	l_avalue_text(3) := to_char(p_entity_id);
	l_aname_text(4) := 'NOTIFICATION_FROM_ROLE';
	l_avalue_text(4) := 'WFADMIN';
	l_aname_text(5) := 'NOTIFICATION_TO_ROLE';
	l_avalue_text(5) := FND_GLOBAL.USER_NAME;
	l_aname_text(6) := 'CUSTOMER_NAME';
	l_avalue_text(6) := l_customer_name;

	WF_ENGINE.SetItemAttrTextArray(
		    itemtype => l_itemtype,
		    itemkey  => l_itemkey,
		    aname    => l_aname_text,
		    avalue   => l_avalue_text);
        WF_ENGINE.StartProcess(itemtype => 'WSHDEL',
	                       itemkey  => p_entity_id);
        -- Add attributes
        UPDATE WSH_NEW_DELIVERIES
            SET delivery_scpod_wf_process=l_custom_process_name
            WHERE delivery_id=p_entity_id;
        x_process_started := 'Y';
    END IF;
END IF;

IF l_debug_on THEN
   WSH_DEBUG_SV.pop(l_module_name);
END IF;

EXCEPTION
WHEN others THEN
    WSH_WF_STD.Log_Wf_Exception(p_entity_type    => 'DELIVERY',
		                p_entity_id      => p_entity_id,
				p_logging_entity => 'SHIPPER',
				p_exception_name => 'WSH_LAUNCH_WF_FAILED',
				x_return_status  => l_return_status);

    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END Start_Scpod_C_Process;
---------------------------------------------------------------------------------------
--
-- Procedure:       process_selector
-- Parameters:      p_entity_type - 'TRIP','DELIVERY'
--  		        p_entity_id   - TRIP_ID or DELIVERY_ID
--                  p_organization_id - The Organization Id
--
--                  x_wf_process - Returns the process selected for the Entity
--                  x_return_status - Returns WSH_UTIL_CORE.G_RET_STS_SUCCESS if Success
--
-- Description:     This Procedure selects the process for the entities based on the
--                  various criteria
--                  Delivery:
--                  1) FTE Installed
--                  Criteria currently not used: 1) Picking Required
--                                               2) Export Screening Required
--                  Return G_NO_WORKFLOW in the following cases:
--                                           1) TPW enabled organization
--                                           2) Shipment direction (Inbound/Outbound)
--                  Trip:
--                  1) FTE Installed
---------------------------------------------------------------------------------------

PROCEDURE process_selector(
		p_entity_type IN VARCHAR2,
		p_entity_id IN	NUMBER,
		p_organization_id IN NUMBER,
		x_wf_process OUT NOCOPY VARCHAR2,
                x_return_status OUT NOCOPY VARCHAR2) IS

CURSOR get_ship_dir_control IS
SELECT shipment_direction,shipping_control
FROM WSH_NEW_DELIVERIES WHERE delivery_id=p_entity_id;

l_param_info WSH_SHIPPING_PARAMS_PVT.Parameter_Rec_Typ;

CURSOR get_org_code IS
SELECT organization_code
FROM MTL_PARAMETERS
WHERE organization_id  = p_organization_id;

CURSOR get_non_pickable_count IS
SELECT count(*)
FROM wsh_delivery_assignments_v wda,
     wsh_delivery_details wdd
WHERE
     wda.delivery_id = p_entity_id
     AND wda.delivery_detail_id = wdd.delivery_detail_id
     AND wdd.container_flag = 'N'
     AND wdd.pickable_flag <> 'Y' ;

l_organization_code VARCHAR2(3);

-- l_screening_flag      VARCHAR2(1);
l_wh_type             VARCHAR2(30);
l_process_identifier  NUMBER;
-- l_non_pick_eligible_count NUMBER;
l_shipment_direction  VARCHAR2(30);
l_shipping_control    VARCHAR2(30);
l_custom_process_name VARCHAR2(30);

l_fte_installed VARCHAR2(1);
-- l_screening_req VARCHAR2(1);
-- l_tpw_org       VARCHAR2(1);
-- l_picking_req   VARCHAR2(1);


l_return_status VARCHAR2(30);

e_invalid_org       EXCEPTION;
e_process_not_found EXCEPTION;

l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PROCESS_SELECTOR';
l_debug_on BOOLEAN;


BEGIN

-- Debug Statements
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
    WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_TYPE',p_entity_type);
    WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_ID',p_entity_id);
    WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',p_organization_id);
END IF;

l_fte_installed := 'N';
-- l_screening_req := 'N';
-- l_tpw_org       := 'N';
-- l_picking_req   := 'N';

x_return_status:=WSH_UTIL_CORE.G_RET_STS_SUCCESS;
-- CHECK IF FTE INSTALLED
IF (WSH_UTIL_CORE.FTE_IS_INSTALLED = 'Y') THEN
	l_fte_installed := 'Y';
END IF;

IF (p_entity_type = 'TRIP') THEN
	x_wf_process := 'R_TRIP_GEN';
	--Currently not in use
	/*IF ( l_fte_installed = 'Y') THEN
		x_wf_process := 'R_TRIP_FTE_GEN';
	ELSE
		x_wf_process := 'R_TRIP_GEN';
	END IF;*/
ELSIF (p_entity_type = 'DELIVERY') THEN

	-- SHIPMENT DIRECTION AND CONTROL.
	OPEN get_ship_dir_control;
	FETCH get_ship_dir_control into l_shipment_direction,l_shipping_control;
	CLOSE get_ship_dir_control ;
	IF (l_shipment_direction = 'I') THEN
	/*SR	IF (l_shipping_control = 'SUPPLIER') THEN
			x_wf_process := 'R_DEL_FTE_SUPPLIER';
		ELSE
			x_wf_process := 'R_DEL_FTE_BUYER';
		END IF;       SR*/
        x_wf_process := G_NO_WORKFLOW;
        IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
        END IF;
    	RETURN;
	END IF;

	-- CHECK IF EXPORT SCREENING REQUIRED
	/*SR
	IF l_debug_on THEN
	WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIPPING_PARAMS_PVT.GET', WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

        WSH_SHIPPING_PARAMS_PVT.Get(
    	    p_organization_id => p_organization_id,
	    x_param_info      => l_param_info,
    	    x_return_status   => l_return_status);
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
        END IF;

        IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            x_return_status := l_return_status;
            IF l_debug_on THEN
                WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            RETURN;                         --Double check it
        ELSE
            l_screening_flag := NVL(l_param_info.EXPORT_SCREENING_FLAG,'N');
        END IF;

        IF (l_screening_flag <> 'N') THEN	-- assuming only N,A,C,S
	    l_screening_req := 'Y';
        END IF;
        SR*/


    -- CHECK IF ORGANIZATION IS TPW ENABLED
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_EXTERNAL_INTERFACE_SV.GET_WAREHOUSE_TYPE',
WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;

    l_wh_type:=WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type(p_organization_id => p_organization_id,
						            p_delivery_id     => p_entity_id,
						            x_return_status   => l_return_status);
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
    END IF;

    IF ( l_return_status <> WSH_UTIL_CORE.g_ret_sts_success) THEN
	raise e_invalid_org;       -- the api returns error when no org id is sent; unexp error
    END IF;
    -- TPW - Distributed Organization Changes
    -- Arcsing the file in R12.0 branchline even though this project is done in 12.1 branch
    -- due to dual-maintenance. Changes will NOT have any significane in R12.0 branchline
    -- until the 'TPW - Distributed Organization Changes' are backported to R120.
    -- Workflow should be disalbed for TW2 enabled Organizaiton
    --IF ( nvl(l_wh_type,'@') = 'TPW') THEN
    IF ( nvl(l_wh_type,'@') IN ('TPW', 'TW2')) THEN
	-- l_tpw_org := 'Y';
        x_wf_process := G_NO_WORKFLOW;
        IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
        END IF;
    	RETURN;
    END IF;


    -- CHECK IF PICKING REQUIRED. Check for these conditions:
    --    1. OKE lines - pickable flag is always 'N' (source_code checking not required)
    --    2. TPW lines - pickable flag is sometimes 'Y' hence the check for TPW
    --    3. Non transactable lines - pickable flag is not 'Y'
        /*SR
	OPEN get_non_pickable_count;
	FETCH get_non_pickable_count into l_non_pick_eligible_count;
	CLOSE get_non_pickable_count ;

	IF (l_non_pick_eligible_count > 0 or l_tpw_org = 'Y') THEN
		l_picking_req := 'N';
        ELSE
	        l_picking_req := 'Y';
	END IF;

	IF (l_fte_installed = 'N' AND l_screening_req = 'N' AND l_tpw_org = 'N' AND l_picking_req = 'Y') THEN
		x_wf_process := 'R_DEL_GEN';
	ELSIF (l_fte_installed = 'N' AND l_screening_req = 'N' AND l_tpw_org = 'N' AND l_picking_req = 'N') THEN
		x_wf_process:= 'R_DEL_SHP';
	ELSIF (l_fte_installed = 'N' AND l_screening_req = 'Y' AND l_tpw_org = 'N' AND l_picking_req = 'Y') THEN
		x_wf_process:= 'R_DEL_ITM_GEN';
	ELSIF (l_fte_installed = 'N' AND l_screening_req = 'Y' AND l_tpw_org = 'N' AND l_picking_req = 'N') THEN
		x_wf_process:= 'R_DEL_ITM_SHP';
	ELSIF (l_fte_installed = 'Y' AND l_screening_req = 'N' AND l_tpw_org = 'N' AND l_picking_req = 'Y') THEN
		x_wf_process:= 'R_DEL_FTE_GEN';
	ELSIF (l_fte_installed = 'Y' AND l_screening_req = 'N' AND l_tpw_org = 'N' AND l_picking_req = 'N') THEN
		x_wf_process:= 'R_DEL_FTE_SHP';
	ELSIF (l_fte_installed = 'Y' AND l_screening_req = 'N' AND l_tpw_org = 'Y' AND l_picking_req = 'N') THEN
		x_wf_process:= 'R_DEL_FTE_TPW';
	ELSIF (l_fte_installed = 'Y' AND l_screening_req = 'Y' AND l_tpw_org = 'N' AND l_picking_req = 'Y') THEN
		x_wf_process:= 'R_DEL_FTE_ITM_GEN';
	ELSIF (l_fte_installed = 'Y' AND l_screening_req = 'Y' AND l_tpw_org = 'N' AND l_picking_req = 'N') THEN
		x_wf_process:= 'R_DEL_FTE_ITM_SHP';
	ELSIF (l_fte_installed = 'Y' AND l_screening_req = 'Y' AND l_tpw_org = 'Y' AND l_picking_req = 'N') THEN
		x_wf_process:= 'R_DEL_FTE_ITM_TPW';
	END IF;
        SR*/

	x_wf_process := 'R_DEL_GEN';
	--Currenly not in use.
	/*IF ( l_fte_installed = 'Y') THEN
		x_wf_process := 'R_DEL_FTE_GEN';
	ELSE
		x_wf_process := 'R_DEL_GEN';
	END IF;*/

END IF;

IF (x_wf_process is null) THEN
    RAISE e_process_not_found;
END IF;

OPEN get_org_code;
FETCH get_org_code into l_organization_code;
CLOSE get_org_code ;

IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.GET_CUSTOM_WF_PROCESS',
WSH_DEBUG_SV.C_PROC_LEVEL);
END IF;

Get_Custom_Wf_Process(p_wf_process    => x_wf_process,
                      p_org_code      => l_organization_code,
		      x_wf_process    => l_custom_process_name,
		      x_return_status => l_return_status);
IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_custom_process_name',l_custom_process_name);
    WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
END IF;

IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
    x_return_status := l_return_status;
    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
ELSE
    x_wf_process:=l_custom_process_name;
END IF;
IF l_debug_on THEN
   WSH_DEBUG_SV.pop(l_module_name);
END IF;


EXCEPTION
WHEN e_invalid_org THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Invalid Organization Id passed',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:E_INVALID_ORG');
    END IF;
WHEN e_process_not_found THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Process not found for the current Setup parameters',
WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:E_PROCESS_NOT_FOUND');
    END IF;
WHEN others THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END process_selector;

---------------------------------------------------------------------------------------
--
-- Procedure:       Raise_Event
-- Parameters:      p_entity_type - 'TRIP','DELIVERY','LINE','STOP'
--  		    p_entity_id   - TRIP_ID, DELIVERY_ID, DELIVERY_DETAIL_ID,STOP_ID
--                  p_event       - The Event to be raised
--                  p_event_data  - Optional Event data to be sent while raising the event
--                  p_parameters  - Optional Parameters to be sent while raising the event
--                  p_send_date   - Optional date to indicate when the event should
--                                  become available for subscription processing.
--                  p_organization_id - The Organization Id
--
--                  x_return_status - Returns WSH_UTIL_CORE.G_RET_STS_SUCCESS if Success
--
-- Description:     This Procedure raises the event in the following scenario
--                  1) If a Process already exists for this Entity
--                  2) If no process exists, checks the Global and Shipping parameters
--                     for raising events and raises accordingly
---------------------------------------------------------------------------------------

PROCEDURE Raise_Event(
		p_entity_type IN VARCHAR2,
		p_entity_id IN VARCHAR2,
		p_event IN VARCHAR2,
                p_event_data IN CLOB DEFAULT NULL,
                p_parameters IN wf_parameter_list_t DEFAULT NULL,
                p_send_date IN DATE DEFAULT SYSDATE,
		p_organization_id IN NUMBER DEFAULT NULL,
		x_return_status OUT NOCOPY VARCHAR2) IS


l_param_info        WSH_SHIPPING_PARAMS_PVT.Parameter_Rec_Typ;
l_global_parameters WSH_SHIPPING_PARAMS_PVT.Global_Parameters_Rec_Typ;
l_parameters        WF_PARAMETER_LIST_T;
l_raise_event       BOOLEAN;
l_wf_process_exists VARCHAR2(1);
l_return_status     VARCHAR2(1);

e_org_required EXCEPTION;

l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'RAISE_EVENT';
l_debug_on BOOLEAN;


BEGIN

-- Debug Statements
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
    WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_TYPE',p_entity_type);
    WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_ID',p_entity_id);
    WSH_DEBUG_SV.log(l_module_name,'P_EVENT',p_event);
    WSH_DEBUG_SV.log(l_module_name,'P_SEND_DATE',p_send_date);
    WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',p_organization_id);
END IF;

x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
l_raise_event := FALSE;

IF (p_entity_type IN ('DELIVERY','LINE') AND p_organization_id IS NULL ) THEN
    raise e_org_required;
END IF;

-- Raise event if a workflow process exists
IF (p_entity_type = 'TRIP' or p_entity_type = 'DELIVERY') THEN

	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.CHECK_WF_EXISTS',
	WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	check_wf_exists(p_entity_type       => p_entity_type,
	                p_entity_id         => p_entity_id,
			x_wf_process_exists => l_wf_process_exists,
			x_return_status     => l_return_status);

	IF l_debug_on THEN
	    WSH_DEBUG_SV.log(l_module_name,'l_wf_process_exists',l_wf_process_exists);
	    WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
	END IF;

	IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
	    x_return_status := l_return_status;
	    IF l_debug_on THEN
	       WSH_DEBUG_SV.pop(l_module_name);
	    END IF;
	    RETURN;
	END IF;

	IF (l_wf_process_exists = 'Y') THEN
            l_raise_event := TRUE;
	END IF;
END IF;

-- Get Global event parameters and raise event accordingly
IF ( NOT l_raise_event) THEN
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIPPING_PARAMS_PVT.GET_GLOBAL_PARAMETERS',
	WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	WSH_SHIPPING_PARAMS_PVT.Get_Global_Parameters(x_Param_Info    => l_global_parameters,
	                                              x_return_status => l_return_status);

	IF l_debug_on THEN
	    WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
	END IF;

	IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
	    x_return_status := l_return_status;
	    IF l_debug_on THEN
	       WSH_DEBUG_SV.pop(l_module_name);
	    END IF;
	    RETURN;
	END IF;

	IF ((p_entity_type = 'TRIP' OR p_entity_type = 'STOP')
	        AND NVL(l_global_parameters.RAISE_BUSINESS_EVENTS,'N')='Y') THEN
	    l_raise_event := TRUE;
	END IF;
END IF;

-- Get Shipping event parameters and raise event accordingly
IF ( NOT l_raise_event AND p_organization_id is not null) THEN
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIPPING_PARAMS_PVT.GET',
	WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	WSH_SHIPPING_PARAMS_PVT.Get(
		p_organization_id => p_organization_id,
		x_param_info      => l_param_info,
		x_return_status   => l_return_status);

	IF l_debug_on THEN
	    WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
	END IF;

	IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
	    x_return_status := l_return_status;
	    IF l_debug_on THEN
	       WSH_DEBUG_SV.pop(l_module_name);
	    END IF;
	    RETURN;
	END IF;

	IF (NVL(l_param_info.RAISE_BUSINESS_EVENTS,'N')='Y' and NVL(l_global_parameters.RAISE_BUSINESS_EVENTS,'N')='Y')
	THEN
	    l_raise_event := TRUE;
	END IF;
END IF;

IF (l_raise_event) THEN
	IF (p_parameters IS NOT NULL) THEN
	    l_parameters := p_parameters;
	END IF;

        WF_EVENT.AddParameterToList (p_name  => p_entity_type || '_ID',
	    			     p_value => p_entity_id,
			             p_parameterlist => l_parameters);
        WF_EVENT.AddParameterToList (p_name  => 'SEND_DATE',
                                     p_value => p_send_date,
			             p_parameterlist => l_parameters);

	WF_EVENT.raise(
		p_event_name  => p_event,
		p_event_key   => p_entity_id,
		p_event_data  => p_event_data,
		p_parameters  => l_parameters,
		p_send_date   => p_send_date);

/* This Procedure Call was just added to test business events.

   Test_Events(p_entity_type => p_entity_type,
            p_entity_id => p_entity_id,
            p_send_date => p_send_date,
            p_event => p_event);

*/
END IF;

IF l_debug_on THEN
	WSH_DEBUG_SV.pop(l_module_name);
END IF;

EXCEPTION
WHEN e_org_required THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Organization Id Required.Oracle error message is '||
SQLERRM,WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:E_ORG_REQUIRED');
    END IF;

WHEN others THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END Raise_Event;

---------------------------------------------------------------------------------------
-- Procedure:       confirm_start_wf_process
-- Parameters:      p_entity_type - 'TRIP','DELIVERY'
--                  p_organization_id - The Organization Id
--
--                  x_start_wf_process - Returns 'Y' if process can be started, else 'N'
--                  x_return_status - Returns WSH_UTIL_CORE.G_RET_STS_SUCCESS if Success
--
-- Description:     This Procedure obtains the Global and Shipping parameter
--                  values for 'Enable Tracking Workflows' and determines
--                  if a process can be started by,
--                  Global-TW	Shipping-TW Eligible Workflow Entity
--                  ---------   ----------- -------------------------
--                  None	    Delivery	None
--                  None	    None	    None
--                  Trip	    Delivery	Trip
--                  Trip	    None	    Trip
--                  Delivery	Delivery	Delivery
--                  Delivery	None	    None
--                  Both	    Delivery	Both
--                  Both	    None	    Trip
---------------------------------------------------------------------------------------

PROCEDURE confirm_start_wf_process(
		p_entity_type IN VARCHAR2,
		p_organization_id IN NUMBER,
                x_start_wf_process OUT NOCOPY VARCHAR2,
		x_return_status OUT NOCOPY VARCHAR2) IS

l_param_info WSH_SHIPPING_PARAMS_PVT.Parameter_Rec_Typ;
l_global_parameters WSH_SHIPPING_PARAMS_PVT.Global_Parameters_Rec_Typ;

l_global_enable_tracking_wfs VARCHAR2(30);
l_shipping_enable_tracking_wfs VARCHAR2(30);

l_return_status VARCHAR2(1);

l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CONFIRM_START_WF_PROCESS';
l_debug_on BOOLEAN;


BEGIN

-- Debug Statements
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
    WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_TYPE',p_entity_type);
    WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',p_organization_id);
END IF;

x_start_wf_process := 'N';
x_return_status:=WSH_UTIL_CORE.G_RET_STS_SUCCESS;

-- Get Global and Shipping event parameters and raise event accordingly

IF (p_entity_type <> 'TRIP') THEN

	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIPPING_PARAMS_PVT.GET',
	WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	WSH_SHIPPING_PARAMS_PVT.Get(
		p_organization_id => p_organization_id,
		x_param_info      => l_param_info,
		x_return_status   => l_return_status);
	IF l_debug_on THEN
	    WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
	END IF;

	IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
	    x_return_status := l_return_status;
	    IF l_debug_on THEN
	       WSH_DEBUG_SV.pop(l_module_name);
	    END IF;
	    RETURN;
	ELSE
	    l_shipping_enable_tracking_wfs:=NVL(l_param_info.ENABLE_TRACKING_WFS,'NONE');
	END IF;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIPPING_PARAMS_PVT.GET_GLOBAL_PARAMETERS',
WSH_DEBUG_SV.C_PROC_LEVEL);
END IF;

WSH_SHIPPING_PARAMS_PVT.Get_Global_Parameters(x_Param_Info    => l_global_parameters,
                                              x_return_status => l_return_status);

IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
END IF;


IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
    x_return_status := l_return_status;
    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
ELSE
    l_global_enable_tracking_wfs:= NVL(l_global_parameters.ENABLE_TRACKING_WFS,'NONE');
END IF;


IF (l_global_enable_tracking_wfs = 'NONE') THEN
    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
	RETURN;
ELSIF ( (l_global_enable_tracking_wfs = 'TRIP' or l_global_enable_tracking_wfs = 'BOTH') and p_entity_type =
'TRIP') THEN
	x_start_wf_process := 'Y';
    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
	RETURN;
ELSIF ( (l_global_enable_tracking_wfs = 'DELIVERY' or l_global_enable_tracking_wfs = 'BOTH') and
          l_shipping_enable_tracking_wfs = 'DELIVERY' and p_entity_type = 'DELIVERY' ) THEN
	x_start_wf_process := 'Y';
    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
	RETURN;
END IF;
IF l_debug_on THEN
   WSH_DEBUG_SV.pop(l_module_name);
END IF;

EXCEPTION
WHEN others THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
END confirm_start_wf_process;

---------------------------------------------------------------------------------------
-- Procedure:       Check_Wf_Exists
-- Parameters:      p_entity_type - 'TRIP','DELIVERY','DELIVERY_C'(controlling)
--  		    p_entity_id   - TRIP_ID or DELIVERY_ID
--
--                  x_wf_process_exists - Returns 'Y' if Wf exists, else 'N'
--                          IF DELIVERY_C then returns 'Y' only if Cntll wf exists
--                  x_return_status - Returns WSH_UTIL_CORE.G_RET_STS_SUCCESS if Success
--
-- Description:     This Procedure checks from WSH_NEW_DELIVERIES or WSH_TRIPS
--                  if a workflow process has been started for this entity.
---------------------------------------------------------------------------------------

PROCEDURE Check_Wf_Exists(
		p_entity_type IN VARCHAR2,
		p_entity_id IN NUMBER,
                x_wf_process_exists OUT NOCOPY VARCHAR2,
		x_return_status OUT NOCOPY VARCHAR2) IS

CURSOR get_trip_wf_name(l_trip_id IN NUMBER) IS
select trip_wf_process
from wsh_trips where trip_id=l_trip_id;

CURSOR get_delivery_wf_name(l_delivery_id IN NUMBER) IS
select delivery_wf_process,delivery_scpod_wf_process
from wsh_new_deliveries where delivery_id = l_delivery_id;

l_process_name VARCHAR2(30);
l_scpod_process_name VARCHAR2(30);
e_invalid_type EXCEPTION;

l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_WF_EXISTS';
l_debug_on BOOLEAN;


BEGIN

-- Debug Statements
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
    WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_TYPE',p_entity_type);
    WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_ID',p_entity_id);
END IF;

x_return_status:=WSH_UTIL_CORE.G_RET_STS_SUCCESS;

-- Get the Process name from Entity Tables
IF (p_entity_type = 'TRIP') THEN
    OPEN get_trip_wf_name(p_entity_id);
    FETCH get_trip_wf_name into l_process_name;
    CLOSE get_trip_wf_name ;
ELSIF (p_entity_type IN ('DELIVERY','DELIVERY_C')) THEN
    OPEN get_delivery_wf_name(p_entity_id);
    FETCH get_delivery_wf_name into l_process_name,l_scpod_process_name;
    CLOSE get_delivery_wf_name ;
ELSE
    RAISE e_invalid_type;
END IF;

IF (p_entity_type = 'DELIVERY_C') THEN
    IF (l_scpod_process_name is null) THEN
        x_wf_process_exists:='N';
    ELSE
        x_wf_process_exists:='Y';
    END IF;
    IF l_debug_on THEN
	WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
END IF;

IF (l_process_name is null AND l_scpod_process_name is null) THEN
    x_wf_process_exists:='N';
ELSE
    x_wf_process_exists:='Y';
END IF;

IF l_debug_on THEN
   WSH_DEBUG_SV.pop(l_module_name);
END IF;

EXCEPTION
WHEN e_invalid_type THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Invalid Entity type passed.Oracle error message is '||
SQLERRM,WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:E_INVALID_TYPE');
    END IF;
WHEN no_data_found THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'No record found for the entity.Oracle error message is '||
SQLERRM,WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NO_DATA_FOUND');
    END IF;
WHEN others THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END check_wf_exists;
---------------------------------------------------------------------------------------

FUNCTION Wf_Exists(p_entity_type IN VARCHAR2,
                   p_entity_id IN NUMBER) RETURN
BOOLEAN IS
l_wf_process_exists VARCHAR2(1);
l_return_status     VARCHAR2(1);
BEGIN

Check_Wf_Exists(p_entity_type => p_entity_type,
		p_entity_id   => p_entity_id,
                x_wf_process_exists => l_wf_process_exists,
		x_return_status     => l_return_status);
IF (l_wf_process_exists = 'Y') THEN
	RETURN TRUE;
ELSE
	RETURN FALSE;
END IF;
END Wf_Exists;
---------------------------------------------------------------------------------------
-- Procedure:       Get_Custom_Wf_Process
-- Parameters:      p_wf_process - The Process selected for the enity
--          		p_org_code - The organization code
--
--                  x_wf_process - Returns the custom process name specified
--                                 with the lookups else the orginial process
--                  x_return_status - Returns WSH_UTIL_CORE.G_RET_STS_SUCCESS if Success
--
-- Description:     This Procedure queries from the WSH_LOOKUPS for any custom
--                  process name specified by the User through the lookups for
--                  a particular process else returns the original process
---------------------------------------------------------------------------------------

PROCEDURE Get_Custom_Wf_Process(
		p_wf_process IN VARCHAR2,
		p_org_code IN VARCHAR2,
		x_wf_process OUT NOCOPY VARCHAR2,
                x_return_status OUT NOCOPY VARCHAR2) IS
l_custom_process VARCHAR2(80);

CURSOR get_custom_process IS
select meaning
from WSH_LOOKUPS where lookup_type = p_wf_process and lookup_code = p_org_code
and sysdate between nvl(start_date_active,sysdate) and nvl(end_date_active,sysdate)
and enabled_flag='Y';

CURSOR get_gen_custom_process IS
select meaning
from WSH_LOOKUPS where lookup_type = p_wf_process and lookup_code = 'ALL'
and sysdate between nvl(start_date_active,sysdate) and nvl(end_date_active,sysdate)
and enabled_flag='Y';

l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_CUSTOM_WF_PROCESS';
l_debug_on BOOLEAN;


BEGIN

-- Debug Statements
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
    WSH_DEBUG_SV.log(l_module_name,'P_WF_PROCESS',p_wf_process);
    WSH_DEBUG_SV.log(l_module_name,'P_ORG_CODE',p_org_code);
END IF;

x_return_status:=WSH_UTIL_CORE.G_RET_STS_SUCCESS;

OPEN get_custom_process;
FETCH get_custom_process into l_custom_process;

IF get_custom_process%NOTFOUND THEN
  OPEN get_gen_custom_process;
  FETCH get_gen_custom_process INTO l_custom_process;
  IF get_gen_custom_process%NOTFOUND THEN
	x_wf_process := p_wf_process;
	RETURN;
  END IF;
  CLOSE get_gen_custom_process;
END IF ;
CLOSE get_custom_process ;

IF (l_custom_process is not null) THEN
	x_wf_process := l_custom_process;
END IF;

IF l_debug_on THEN
   WSH_DEBUG_SV.pop(l_module_name);
END IF;

EXCEPTION
WHEN others THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured.
Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
END Get_Custom_Wf_Process;
---------------------------------------------------------------------------------------
-- Procedure:       Purge_Entity
-- Parameters:      p_entity_type - TRIP / DELIVERY
--                  p_entity_ids  - Ids of entities to be purged
--                  p_action      - CLOSE / PURGE
--                  p_docommit    - Specify TRUE/FALSE to indicate whether
--                                  to commit data while purging.
--
--                  x_purged_count - No. of entities successfully purged/closed
--                  x_return_status - Returns WSH_UTIL_CORE.G_RET_STS_SUCCESS if Success
--
-- Description:     This Procedure finds out the Item status for every entity id.
--                  If it is complete then purges it, if not complete aborts the process
--                  and then purges the item.
--                  If p_action is CLOSE alone then aborts the process if not completed.
---------------------------------------------------------------------------------------
Procedure Purge_Entity(
               p_entity_type IN VARCHAR2,
               p_entity_ids IN WSH_UTIL_CORE.column_tab_type,
               p_action IN VARCHAR2 DEFAULT 'PURGE',
               p_docommit IN BOOLEAN DEFAULT FALSE,
	       x_success_count OUT NOCOPY NUMBER,
               x_return_status OUT NOCOPY VARCHAR2) IS

l_wf_status VARCHAR2(30);   -- COMPLETE/ERROR/SUSPENDED
l_result VARCHAR2(30);
l_itemtype VARCHAR2(30);

l_suc_entity_ids WSH_UTIL_CORE.column_tab_type;

l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PURGE_ENTITY';
l_debug_on BOOLEAN;

BEGIN

-- Debug Statements
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
    WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_TYPE',p_entity_type);
    WSH_DEBUG_SV.log(l_module_name,'P_ACTION',p_action);
    WSH_DEBUG_SV.log(l_module_name,'P_DOCOMMIT',p_docommit);
END IF;

x_return_status:=WSH_UTIL_CORE.G_RET_STS_SUCCESS;
SAVEPOINT	PURGE_ENTITY_UPDATE;

IF (p_entity_type = 'TRIP') THEN
    l_itemtype := 'WSHTRIP';
ELSE
    l_itemtype := 'WSHDEL';
END IF;

FOR i IN 1..p_entity_ids.COUNT LOOP
    IF ( Wf_Exists(p_entity_type, p_entity_ids(i))) THEN
	BEGIN
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_IDS(I)',p_entity_ids(i));
        END IF;
        --
	WF_ENGINE.ItemStatus(itemtype => l_itemtype,
	                     itemkey  => p_entity_ids(I),
			     status   => l_wf_status,
			     result   => l_result);

	IF (l_wf_status <> 'COMPLETE') THEN
	    WF_ENGINE.AbortProcess(itemtype => l_itemtype,
	                           itemkey  => p_entity_ids(i)); -- ,l_wf_end_result);
	    IF (p_action = 'PURGE') THEN
        WF_PURGE.Items(itemtype => l_itemtype,
				   itemkey  => p_entity_ids(i),
				   docommit => p_docommit,
           force => TRUE);
		    WF_PURGE.Total(itemtype => l_itemtype,
				   itemkey  => p_entity_ids(i),
				   docommit => p_docommit);
	    END IF;
	ELSE
	    IF (p_action = 'PURGE') THEN
	    WF_purge.Items(itemtype => l_itemtype,
			   itemkey  => p_entity_ids(i),
			   docommit => p_docommit);
	    END IF;
	END IF;

	l_suc_entity_ids(l_suc_entity_ids.count + 1) :=  p_entity_ids(i);
	EXCEPTION
	WHEN OTHERS THEN
	    IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_EXCEP_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	    END IF;
	END;
    END IF;
END LOOP;

IF (p_entity_type = 'DELIVERY') THEN
    FORALL i IN 1..l_suc_entity_ids.count
    UPDATE WSH_NEW_DELIVERIES
    SET delivery_wf_process=NULL,
        delivery_scpod_wf_process=NULL,
	del_wf_intransit_attr=NULL,
	del_wf_interface_attr=NULL,
	del_wf_close_attr=NULL
    WHERE  delivery_id = l_suc_entity_ids(i);
ELSIF (p_entity_type = 'TRIP') THEN
    FORALL i IN 1..l_suc_entity_ids.count
    UPDATE WSH_TRIPS
    SET trip_wf_process=NULL
    WHERE  trip_id=l_suc_entity_ids(i);
END IF;

x_success_count := l_suc_entity_ids.count;
/*
IF (l_suc_entity_ids.count = 0) THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;
ELSIF (p_entity_ids.count <> l_suc_entity_ids.count) THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING ;
ELSIF (p_entity_ids.count = l_suc_entity_ids.count) THEN
    x_return_status:=WSH_UTIL_CORE.G_RET_STS_SUCCESS;
END IF;
*/
IF l_debug_on THEN
   WSH_DEBUG_SV.pop(l_module_name);
END IF;


EXCEPTION
WHEN others THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END Purge_Entity;


---------------------------------------------------------------------------------------
--
-- Procedure:       Log_Wf_Exception
-- Parameters:      p_entity_type - 'DELIVERY',
--                  p_entity_id   - DELIVERY_ID
--                  p_ship_from_location_id - The Ship from Location Id
--                  p_exception_name  WSH_LAUNCH_WF_FAILED
--                                    WSH_DEL_SCPOD_PURGED
--
--                  x_return_status - Returns WSH_UTIL_CORE.G_RET_STS_SUCCESS if Success
--
-- Description:     This Procedure logs an exception against the specified Entity
--
--
---------------------------------------------------------------------------------------

PROCEDURE Log_Wf_Exception(p_entity_type IN VARCHAR2,
                           p_entity_id IN NUMBER,
                           p_ship_from_location_id in NUMBER DEFAULT NULL,
			   p_logging_entity IN VARCHAR2,
                           p_exception_name in VARCHAR2,
                           x_return_status out nocopy VARCHAR2) IS

l_exception_name varchar2(30);
l_msg   varchar2(2000);
l_exception_msg_count NUMBER;
l_exception_msg_data varchar2(2000);
l_exception_id NUMBER := NULL;
l_ship_from_location_id NUMBER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOG_WF_EXCEPTION';

BEGIN

--
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
--
IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;
--
IF l_debug_on THEN
    wsh_debug_sv.push(l_module_name);
    wsh_debug_sv.log(l_module_name, 'P_ENTITY_TYPE',p_entity_type);
    wsh_debug_sv.log(l_module_name, 'P_ENTITY_ID',p_entity_id);
    wsh_debug_sv.log(l_module_name, 'P_SHIP_FROM_LOCATION_ID',p_ship_from_location_id);
    wsh_debug_sv.log(l_module_name, 'P_LOGGING_ENTITY',p_logging_entity);
    wsh_debug_sv.log(l_module_name, 'P_EXCEPTION_NAME',p_exception_name);
END IF;

IF (p_ship_from_location_id IS NULL AND p_entity_type = 'DELIVERY') THEN
    SELECT INITIAL_PICKUP_LOCATION_ID INTO l_ship_from_location_id
    FROM WSH_NEW_DELIVERIES
    WHERE delivery_id = p_entity_id;
ELSE
    l_ship_from_location_id := p_ship_from_location_id;
END IF;

IF (p_exception_name = 'WSH_DEL_SCPOD_PURGED') THEN
    l_msg := FND_MESSAGE.Get_String('WSH','WSH_DEL_SCPOD_TERMINATED');
ELSIF (p_exception_name = 'WSH_LAUNCH_WF_FAILED') THEN
    l_msg := FND_MESSAGE.Get_String('WSH','WSH_LAUNCH_WF_FAILED');
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_XC_UTIL.Log_Exception',
WSH_DEBUG_SV.C_PROC_LEVEL);
END IF;

IF (p_entity_type = 'DELIVERY') THEN
	wsh_xc_util.log_exception(
		     p_api_version             => 1.0,
		     x_return_status           => x_return_status,
		     x_msg_count               => l_exception_msg_count,
		     x_msg_data                => l_exception_msg_data,
		     x_exception_id            => l_exception_id ,
		     p_logged_at_location_id   => l_ship_from_location_id,
		     p_exception_location_id   => l_ship_from_location_id,
		     p_logging_entity          => p_logging_entity,
		     p_logging_entity_id       => FND_GLOBAL.USER_ID,
		     p_exception_name          => p_exception_name,
		     p_message                 => l_msg,
		     p_delivery_id             => p_entity_id
		     );
END IF;
IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_XC_UTIL.Log_Exception',x_return_status);
    WSH_DEBUG_SV.log(l_module_name,'L_EXCEPTION_MSG_COUNT',l_exception_msg_count);
    WSH_DEBUG_SV.log(l_module_name,'L_EXCEPTION_MSG_DATA',l_exception_msg_data);
    WSH_DEBUG_SV.log(l_module_name,'L_EXCEPTION_ID',l_exception_id);
END IF;

IF l_debug_on THEN
	WSH_DEBUG_SV.pop(l_module_name);
END IF;


EXCEPTION
WHEN others THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    IF l_debug_on THEN
	WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
END Log_Wf_Exception;

--========================================================================================
-- FUNCTION  : GET_WF_NAME
--             This function will return the workflow process name associated with the entity
--             with respect to p_entity_type
--
--             If encountered any exception/error , NULL will be returned.
--
-- SCOPE     : PRIVATE
-- PARAMETERS: p_entity_type     Entity for which proceess_name is being looked.
--                               DELIVERY   /   Delivery Flow - Generic
--                               DELIVERY_C /   Ship To Deliver subprocess
--                               TRIP       /   Trip Flow - Generic
--
--             p_entity_id       Unique identifier for the entity i.e., Delivery_id / Trip_id.
--
-- COMMENT   : This Function will fetch and return the process_name associated with the entity
--             and the type which were passed as parameters.
--
--             This function is introduced as part of bugfix 8706771 .
--========================================================================================
FUNCTION GET_WF_NAME(p_entity_type IN VARCHAR2,
                     p_entity_id IN NUMBER) RETURN
VARCHAR2 IS
l_module_name CONSTANT  VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_WF_NAME';
l_debug_on BOOLEAN;
l_process_name VARCHAR2(30);
l_scpod_process_name VARCHAR2(30);

CURSOR get_trip_wf_name(l_trip_id IN NUMBER) IS
select trip_wf_process
from wsh_trips where trip_id=l_trip_id;

CURSOR get_delivery_wf_name(l_delivery_id IN NUMBER) IS
select delivery_wf_process,delivery_scpod_wf_process
from wsh_new_deliveries where delivery_id = l_delivery_id;

ENTITY_NOT_FOUND exception;
INVALID_ENTITY_TYPE exception;

BEGIN

-- Debug Statements
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
    WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_TYPE',p_entity_type);
    WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_ID',p_entity_id);
END IF;

-- Get the Process name from Entity Tables
IF (p_entity_type = 'TRIP') THEN
    OPEN get_trip_wf_name(p_entity_id);
    FETCH get_trip_wf_name into l_process_name;

    IF get_trip_wf_name%NOTFOUND THEN
        CLOSE get_trip_wf_name;
        RAISE ENTITY_NOT_FOUND;
    END IF;

    CLOSE get_trip_wf_name ;

    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_process_name',l_process_name);
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN l_process_name;
ELSIF (p_entity_type = 'DELIVERY') THEN
    OPEN get_delivery_wf_name(p_entity_id);
    FETCH get_delivery_wf_name into l_process_name,l_scpod_process_name;

    IF get_delivery_wf_name%NOTFOUND THEN
        CLOSE get_delivery_wf_name;
        RAISE ENTITY_NOT_FOUND;
    END IF;

    CLOSE get_delivery_wf_name ;

    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_process_name',l_process_name);
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN l_process_name;
ELSIF (p_entity_type = 'DELIVERY_C') THEN
    OPEN get_delivery_wf_name(p_entity_id);
    FETCH get_delivery_wf_name into l_process_name,l_scpod_process_name;

    IF get_delivery_wf_name%NOTFOUND THEN
        CLOSE get_delivery_wf_name;
        RAISE ENTITY_NOT_FOUND;
    END IF;

    CLOSE get_delivery_wf_name ;

    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_process_name',l_scpod_process_name);
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN l_scpod_process_name;
ELSE
    RAISE INVALID_ENTITY_TYPE;
END IF;

IF l_debug_on THEN
   WSH_DEBUG_SV.pop(l_module_name);
END IF;

EXCEPTION
WHEN ENTITY_NOT_FOUND THEN
    IF get_trip_wf_name%ISOPEN THEN
        close get_trip_wf_name;
    END IF;

    IF get_delivery_wf_name%ISOPEN THEN
        close get_delivery_wf_name;
    END IF;

    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Expected error has occured. Oracle error message is '||p_entity_type||' entity '||p_entity_id||' does not exists',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:ENTITY_NOT_FOUND');
    END IF;

    RETURN NULL;

WHEN INVALID_ENTITY_TYPE THEN
    IF get_trip_wf_name%ISOPEN THEN
        close get_trip_wf_name;
    END IF;

    IF get_delivery_wf_name%ISOPEN THEN
        close get_delivery_wf_name;
    END IF;

    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Expected error has occured. Oracle error message is INVALID_ENTITY_TYPE passed: '||p_entity_type,WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INVALID_ENTITY_TYPE');
    END IF;

    RETURN NULL;

WHEN OTHERS THEN
    IF get_trip_wf_name%ISOPEN THEN
        close get_trip_wf_name;
    END IF;

    IF get_delivery_wf_name%ISOPEN THEN
        close get_delivery_wf_name;
    END IF;

    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

    RETURN NULL;

END GET_WF_NAME;

--========================================================================================
-- FUNCTION  : WF_ENGINE_EVENT
--             This function will derive the workflow process name for the trip/delivery
--             and pass the event to those processes which are waiting to receive the
--             corresponding event by calling WF API wf_engine.event.
--
--             The return status could be SUCCESS/ERROR
--             This API must be called only from wsh_wf_std.instance_default_rule
-- SCOPE     : PRIVATE
-- PARAMETERS: p_subscription_guid     Unique identifier of the subscription for B.Event.
--
--             p_event                 Event info containing even name,event id , etc.,
--
-- COMMENT   : This Function is used to derive the delivery generic/ship to deliver/trip
--             workflow process name and then pass the event information to those processes
--             to receive this event passed.
--             The return status could be SUCCESS/ERROR which will be reported to business
--             event system via api wsh_wf_std.instance_default_rule
--
--             This function is introduced as part of bugfix 8706771 and this is replacement
--             for function wsh_wf_std.instance_default_rule
--========================================================================================
FUNCTION WF_ENGINE_EVENT (p_subscription_guid in raw,
				p_event in out nocopy WF_EVENT_T) return
VARCHAR2 is
l_eventname VARCHAR2(240);
l_wf_pr_name VARCHAR2(30);
l_eventkey  VARCHAR2(240);
l_entityid   VARCHAR2(240);

l_raise_exception   BOOLEAN;
e_entityid_notfound EXCEPTION;
e_event_error       EXCEPTION;


l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'WF_ENGINE_EVENT';

BEGIN

--Get the EventName and EventKey from p_event to local variable
l_eventname := p_event.getEventName;
l_eventkey  := p_event.getEventKey;
l_raise_exception := FALSE;

-- Debug Statements
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
    WSH_DEBUG_SV.log(l_module_name,'l_eventname',l_eventname);
    WSH_DEBUG_SV.log(l_module_name,'l_eventkey',l_eventkey);
END IF;

l_entityid := l_eventkey;

-- Out Agent/To Agent/Priority/Workflow Type/Workflow Process
-- We dont have any of the above specified in our business event subscriptions which are responsible for triggering the shipping workflow.
-- Due to this we are not doing anything w.r.t input parameter p_subscription_guid and it disappears in this function without doing any processing.
-- If in future we specify any value for these fileds.Then we need to add code here so that those things will be communicated/Set before calling wf_engine.event.
-- Need to refer API WF_RULE.INSTANCE_DEFAULT_RULE for the code to be added.

IF (l_entityid is not NULL) THEN   --{ If l_entityid is not null
    p_event.SetEventKey(l_entityid);
    BEGIN

       IF (l_eventname = 'oracle.apps.wsh.delivery.pik.pickinitiated' OR
           l_eventname = 'oracle.apps.wsh.delivery.gen.shipconfirmed' OR
           l_eventname = 'oracle.apps.wsh.delivery.gen.open' OR
           l_eventname = 'oracle.apps.wsh.delivery.gen.setintransit' OR
           l_eventname = 'oracle.apps.wsh.delivery.gen.closed' OR
           l_eventname = 'oracle.apps.wsh.delivery.gen.interfaced') THEN   -- Events specific to delivery workflow.
       --{
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.GET_WF_NAME', WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;

           l_wf_pr_name := GET_WF_NAME('DELIVERY',l_entityid);

           IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'DELIVERY: l_wf_pr_name',l_wf_pr_name);
           END IF;

           --Call wf_engine.event only if any process is associated to the entity
           IF l_wf_pr_name IS NOT NULL THEN
           --{
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_ENGINE.EVENT', WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;

               WF_ENGINE.EVENT(itemtype => 'WSHDEL',
                               itemkey => l_entityid,
                               process_name => l_wf_pr_name,
                               event_message => p_event);
           ELSE
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.GET_WF_NAME', WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;

               l_wf_pr_name := GET_WF_NAME('DELIVERY_C',l_entityid);

               IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'DELIVERY_C: l_wf_pr_name',l_wf_pr_name);
               END IF;

               IF l_wf_pr_name IS NOT NULL THEN
                   IF l_debug_on THEN
                       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_ENGINE.EVENT', WSH_DEBUG_SV.C_PROC_LEVEL);
                   END IF;

                   WF_ENGINE.EVENT(itemtype => 'WSHDEL',
                                   itemkey => l_entityid,
                                   process_name => l_wf_pr_name,
                                   event_message => p_event);
               END IF;
           --}
           END IF;
       ELSIF (l_eventname = 'oracle.apps.wsh.trip.gen.initialpickupstopclosed' OR
              l_eventname = 'oracle.apps.wsh.trip.gen.ultimatedropoffstopclosed') THEN -- Events specific to Trip workflow

           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.GET_WF_NAME', WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;

           l_wf_pr_name := GET_WF_NAME('TRIP',l_entityid);

           IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'TRIP: l_wf_pr_name',l_wf_pr_name);
           END IF;

           IF l_wf_pr_name IS NOT NULL THEN
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_ENGINE.EVENT', WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;

               wf_engine.Event(itemtype => 'WSHTRIP',
                               itemkey => l_entityid,
                               process_name => l_wf_pr_name,
                               event_message => p_event);
           END IF;

       --}
       END IF;

    EXCEPTION
        WHEN others THEN
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Exception :'||Wf_Core.Error_Name||' Occured', WSH_DEBUG_SV.C_EXCEP_LEVEL);
            END IF;

            IF (Wf_Core.Error_Name = 'WFENG_EVENT_NOTFOUND') THEN
                Wf_Core.Clear;
            ELSE
	        l_raise_exception:=TRUE;
            END IF;
    END;

ELSE
    raise e_entityid_notfound;
END IF;   --{ If l_entityid is not nulls

IF l_raise_exception THEN
    raise e_event_error;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;

RETURN 'SUCCESS';

EXCEPTION
    WHEN e_entityid_notfound THEN
        WF_CORE.CONTEXT('WSH_WF_STD', 'WF_ENGINE_EVENT',p_event.getEventName( ), p_subscription_guid);
        WF_EVENT.setErrorInfo(p_event, 'ERROR');

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Associated Entity Id not found. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_EXCEP_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:E_ENTITYID_NOTFOUND');
        END IF;

        RETURN 'ERROR';

    WHEN e_event_error THEN
        WF_CORE.CONTEXT('WSH_WF_STD', 'WF_ENGINE_EVENT',p_event.getEventName( ), p_subscription_guid);
        WF_EVENT.setErrorInfo(p_event, 'ERROR');

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Some Entities had errors while raising events. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_EXCEP_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:E_EVENT_ERROR');
        END IF;

        RETURN 'ERROR';

    WHEN others THEN
        WF_CORE.CONTEXT('WSH_WF_STD', 'WF_ENGINE_EVENT',p_event.getEventName( ), p_subscription_guid);
        WF_EVENT.setErrorInfo(p_event, 'ERROR');

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;

        RETURN 'ERROR';
END WF_ENGINE_EVENT;

---------------------------------------------------------------------------------------
FUNCTION Instance_Default_Rule (p_subscription_guid in raw,
				p_event in out nocopy WF_EVENT_T) return
VARCHAR2 is
--performance bug 5220516: make this API as efficient as possible
-- by commenting the unnecessary assignment; this variable is
-- used only in the code that is currently commented.
--l_eventname VARCHAR2(240);
/*           bugfix 8706771
l_eventkey  VARCHAR2(240);
l_entityid   VARCHAR2(240);
l_pik_status VARCHAR2(30);
l_svc_status VARCHAR2(30);

CURSOR get_trip(l_wf_item_key IN VARCHAR2) IS
SELECT trip_id
FROM WSH_TRIPS
WHERE wf_item_key = l_wf_item_key;

CURSOR get_trip_del(l_trip_id IN NUMBER) IS
select delivery_id
from WSH_DELIVERY_LEGS wdl,
     WSH_TRIP_STOPS wts
where wdl.pick_up_stop_id = wts.stop_id and
      wts.trip_id = l_trip_id;

CURSOR get_delivery(l_event_key IN VARCHAR2) IS
SELECT delivery_id
FROM WSH_NEW_DELIVERIES WND,
     WSH_TRANSACTIONS_HISTORY WTH
WHERE WTH.event_key = l_event_key and
      WTH.entity_type = 'DLVY' and
      WTH.entity_number = WND.name;

CURSOR get_act_status(l_eventkey IN VARCHAR2,l_act_name IN VARCHAR2) IS
SELECT activity_status_code
FROM WF_ITEM_ACTIVITY_STATUSES_V
WHERE item_type = 'WSHDEL'
   AND item_key = l_eventkey
   AND activity_name = l_act_name;

l_return_status     VARCHAR2(30);
l_raise_exception   BOOLEAN;
e_entityid_notfound EXCEPTION;
e_event_error       EXCEPTION;

*/  -- Bugfix 8706771
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Instance_Default_Rule';
l_return_status     VARCHAR2(30);

BEGIN
-- De-supporting the usage of this API code logic due to bug 8706771.
-- Removing all the code inside the begin block and commenting almost all local variables in the declaration part.
-- From now on this API will just redirect the call to the newly created API WSH_WF_STD.WF_ENGINE_EVENT.
-- This API is not removed since the subscription of business event has this one specified.SO instead of making changes there,
-- we are still keeping the skeleton of this API as it is,but redirecting the code logic to new API.
-- For more details refer bug 8706771.

-- Debug Statements
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
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.WF_ENGINE_EVENT', WSH_DEBUG_SV.C_PROC_LEVEL);
END IF;

l_return_status := WF_ENGINE_EVENT( p_subscription_guid => p_subscription_guid,
                                    p_event => p_event);
IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
    WSH_DEBUG_SV.pop(l_module_name);
END IF;

RETURN l_return_status;

EXCEPTION
WHEN OTHERS THEN
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
RETURN 'ERROR';
END;
---------------------------------------------------------------------------------------
-- This procedure sets the global G_RESET_APPS_CONTEXT to TRUE
---------------------------------------------------------------------------------------
PROCEDURE RESET_APPS_CONTEXT_ON IS
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'RESET_APPS_CONTEXT_ON';
l_debug_on BOOLEAN;
--
BEGIN

WSH_WF_STD.G_RESET_APPS_CONTEXT := TRUE;
IF l_debug_on THEN
   WSH_DEBUG_SV.push(l_module_name);
   WSH_DEBUG_SV.pop(l_module_name);
END IF;

END RESET_APPS_CONTEXT_ON;

---------------------------------------------------------------------------------------
-- This procedure sets the global G_RESET_APPS_CONTEXT to FALSE
---------------------------------------------------------------------------------------
PROCEDURE RESET_APPS_CONTEXT_OFF IS
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'RESET_APPS_CONTEXT_OFF';
l_debug_on BOOLEAN;
--
BEGIN

WSH_WF_STD.G_RESET_APPS_CONTEXT := FALSE;
IF l_debug_on THEN
   WSH_DEBUG_SV.push(l_module_name);
   WSH_DEBUG_SV.pop(l_module_name);
END IF;

END RESET_APPS_CONTEXT_OFF;

/* CURRENTLY NOT IN USE
PROCEDURE Get_Carrier(p_del_ids IN WSH_UTIL_CORE.ID_TAB_TYPE,
                      x_del_old_carrier_ids OUT NOCOPY WSH_UTIL_CORE.ID_TAB_TYPE,
                      x_return_status OUT NOCOPY VARCHAR2) IS

l_module_name CONSTANT  VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_CARRIER';
l_debug_on BOOLEAN;

CURSOR c_tripordel_carrier (p_delivery_id IN NUMBER) IS
SELECT
NVL(wt.carrier_id, wnd.carrier_id) carrier_id
FROM
wsh_trips wt,
wsh_delivery_legs wdl,
wsh_trip_stops wts,
wsh_new_deliveries wnd
WHERE wts.trip_id = wt.trip_id
AND   wdl.pick_up_stop_id = wts.stop_id
AND   wnd.initial_pickup_location_id = wts.stop_location_id
AND   wnd.delivery_id = wdl.delivery_id
AND   wnd.delivery_id = p_delivery_id;

CURSOR c_del_carrier (p_delivery_id IN NUMBER) IS
SELECT
carrier_id
FROM
wsh_new_deliveries
WHERE delivery_id = p_delivery_id;

l_carrier_id NUMBER;
l_return_status VARCHAR2(1);

BEGIN

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;

  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  FOR i IN p_del_ids.FIRST..p_del_ids.LAST
  LOOP
    --If Trip has a carrier pick it, otherwise get the delivery one.
    OPEN c_tripordel_carrier(p_delivery_id => p_del_ids(i));
    FETCH c_tripordel_carrier INTO l_carrier_id;
    IF c_tripordel_carrier%NOTFOUND THEN
        IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'No Rows returned from Cursor c_tripordel_carrier', WSH_DEBUG_SV.C_STMT_LEVEL);
        END IF;
      OPEN c_del_carrier(p_delivery_id => p_del_ids(i));
      FETCH c_del_carrier INTO l_carrier_id;
      CLOSE c_del_carrier;
    END IF;
    CLOSE c_tripordel_carrier;
    x_del_old_carrier_ids(i) := l_carrier_id;
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Delivery ID  '||p_del_ids(i)||'has Trip/Delivery carrier '||l_carrier_id, WSH_DEBUG_SV.C_STMT_LEVEL);
    END IF;
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    wsh_util_core.default_handler('WSH_WF_STD.GET_CARRIER');
                IF l_debug_on THEN
                --{
                        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
                --}
                END IF;
END Get_Carrier;

PROCEDURE Handle_Trip_Carriers(p_trip_id IN NUMBER,
			       p_del_ids IN WSH_UTIL_CORE.ID_TAB_TYPE,
			       p_del_old_carrier_ids IN WSH_UTIL_CORE.ID_TAB_TYPE,
			       x_return_status OUT NOCOPY VARCHAR2) IS

l_del_new_carrier_ids WSH_UTIL_CORE.ID_TAB_TYPE;
l_return_status VARCHAR2(1);

BEGIN

    Get_Carrier(p_del_ids => p_del_ids,
                x_del_old_carrier_ids => l_del_new_carrier_ids,
	        x_return_status => l_return_status);

    FOR i IN p_del_ids.FIRST..p_del_ids.LAST
    LOOP
      Assign_Unassign_Carrier(p_delivery_id => p_del_ids(i),
    			      p_old_carrier_id => p_del_old_carrier_ids(i),
                              p_new_carrier_id => l_del_new_carrier_ids(i),
                              x_return_status => l_return_status);
    END LOOP;
END Handle_Trip_Carriers;

PROCEDURE Assign_Unassign_Carrier(p_delivery_id IN NUMBER,
			          p_old_carrier_id IN NUMBER,
                                  p_new_carrier_id IN NUMBER,
                                  x_return_status OUT NOCOPY VARCHAR2) IS

l_module_name CONSTANT  VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Assign_Unassign_Carrier';
l_debug_on BOOLEAN;

l_return_status VARCHAR2(1);
l_wf_rs VARCHAR2(1);

CURSOR c_get_del_info (p_delivery_id IN NUMBER) IS
SELECT
organization_id,
delivery_wf_process
FROM
wsh_new_deliveries
WHERE delivery_id = p_delivery_id;

CURSOR c_get_carrier_name (p_carrier_id IN NUMBER) IS
SELECT
carrier_name
FROM
wsh_carriers_v
WHERE carrier_id = p_carrier_id;

l_org_id NUMBER;
l_del_wf VARCHAR2(30);
l_carrier_name VARCHAR2(360);

BEGIN

        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

        l_debug_on := WSH_DEBUG_INTERFACE.g_debug;

        IF l_debug_on IS NULL THEN
                l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
        END IF;

     OPEN c_get_del_info(p_delivery_id => p_delivery_id);
     FETCH c_get_del_info INTO l_org_id, l_del_wf;
     CLOSE c_get_del_info;

     IF (l_del_wf = 'R_DEL_FTE_GEN') THEN

       IF ((p_old_carrier_id IS NULL) AND (p_new_carrier_id IS NOT NULL)) THEN

        --Carrier on the delivery getting assigned for first time.
        WSH_WF_STD.RAISE_EVENT(p_entity_type => 'DELIVERY',
                             p_entity_id => p_delivery_id,
                             p_event => 'oracle.apps.wsh.delivery.gen.carrierselected',
	                     p_organization_id => l_org_id,
			     x_return_status => l_wf_rs);

      ELSIF ((p_old_carrier_id IS NOT NULL) AND (p_new_carrier_id IS NULL)) THEN

        --Carrier on the Delivery getting nulled out/cancelled.
        WSH_WF_STD.RAISE_EVENT(p_entity_type => 'DELIVERY',
                             p_entity_id => p_delivery_id,
                             p_event => 'oracle.apps.wsh.delivery.gen.carriercancelled',
			     p_organization_id => l_org_id,
			     x_return_status => l_wf_rs);

      ELSIF ((p_old_carrier_id IS NOT NULL) AND (p_new_carrier_id IS NOT NULL) AND
             (p_old_carrier_id <> p_new_carrier_id)) THEN

        --Change in carrier from existing one to a new one.
        WSH_WF_STD.RAISE_EVENT(p_entity_type => 'DELIVERY',
                             p_entity_id => p_delivery_id,
                             p_event => 'oracle.apps.wsh.delivery.gen.carriercancelled',
			     p_organization_id => l_org_id,
			     x_return_status => l_wf_rs);

        WSH_WF_STD.RAISE_EVENT(p_entity_type => 'DELIVERY',
                             p_entity_id => p_delivery_id,
                             p_event => 'oracle.apps.wsh.delivery.gen.carrierselected',
			     p_organization_id => l_org_id,
			     x_return_status => l_wf_rs);
      END IF;--Check for old and new Carrier_id values.

      WF_ENGINE.SetItemAttrNumber(itemtype => 'WSHDEL',
                                  itemkey  => p_delivery_id,
                                  aname    => 'CARRIER_ID',
                                  avalue   => p_new_carrier_id);

      OPEN c_get_carrier_name(p_carrier_id => p_new_carrier_id);
      FETCH c_get_carrier_name INTO l_carrier_name;
      CLOSE c_get_carrier_name;

      WF_ENGINE.SetItemAttrText(itemtype => 'WSHDEL',
                                  itemkey  => p_delivery_id,
                                  aname    => 'CARRIER_NAME',
                                  avalue   => l_carrier_name);

    END IF; --Check for Delivery Workflow Name.

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    wsh_util_core.default_handler('WSH_WF_STD.Assign_Unassign_Carrier');
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
END Assign_Unassign_Carrier;


PROCEDURE Get_Deliveries(p_trip_id IN NUMBER,
                         x_del_ids OUT NOCOPY WSH_UTIL_CORE.ID_TAB_TYPE,
			 x_return_status OUT NOCOPY VARCHAR2) IS

CURSOR c_dels(p_trip_id IN NUMBER) IS
SELECT
wnd.delivery_id
FROM
wsh_new_deliveries wnd,
wsh_delivery_legs wdl,
wsh_trip_stops wts
WHERE
wts.trip_id = p_trip_id AND
wts.stop_id = wdl.pick_up_stop_id AND
wnd.initial_pickup_location_id = wts.stop_location_id AND
wdl.delivery_id = wnd.delivery_id;

BEGIN

  OPEN c_dels(p_trip_id => p_trip_id);
  FETCH c_dels BULK COLLECT INTO x_del_ids;
  CLOSE c_dels;

END Get_Deliveries;
*/

END WSH_WF_STD;

/
