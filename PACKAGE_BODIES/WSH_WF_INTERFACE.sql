--------------------------------------------------------
--  DDL for Package Body WSH_WF_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_WF_INTERFACE" AS
/* $Header: WSHWINTB.pls 120.5 2006/11/16 19:14:03 bsadri noship $ */

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_WF_INTERFACE';


PROCEDURE SCPOD_SHIPPING_STATUS(
                    itemtype IN VARCHAR2,
                    itemkey IN VARCHAR2,
                    actid IN NUMBER,
                    funcmode IN VARCHAR2,
                    resultout OUT NOCOPY VARCHAR2 ) IS

l_status_code WSH_NEW_DELIVERIES.STATUS_CODE%TYPE;
l_del_lines_count NUMBER;
l_return_status  VARCHAR2(1);


CURSOR get_delivery_status IS
SELECT status_code
FROM wsh_new_deliveries
WHERE delivery_id = to_number(itemkey);

CURSOR get_del_lines_count IS
SELECT count(*)
FROM wsh_delivery_assignments_v WDA,
     WSH_DELIVERY_DETAILS WDD
where
     WDA.delivery_detail_id=WDD.delivery_detail_id AND
     WDD.CONTAINER_FLAG = 'N' AND
     delivery_id = to_number(itemkey);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SCPOD_SHIPPING_STATUS';
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
    wsh_debug_sv.log(l_module_name, 'itemtype',itemtype);
    wsh_debug_sv.log(l_module_name, 'itemkey',itemkey);
    wsh_debug_sv.log(l_module_name, 'actid',actid);
    wsh_debug_sv.log(l_module_name, 'funcmode',funcmode);
END IF;

-- RUN mode - normal process execution
IF (funcmode = 'RUN') THEN

    OPEN get_delivery_status;
    FETCH get_delivery_status into l_status_code;
    CLOSE get_delivery_status ;
    resultout := 'COMPLETE:SHIPPED';
    IF (l_status_code =  'CL') THEN
        OPEN get_del_lines_count;
        FETCH get_del_lines_count into l_del_lines_count;
        CLOSE get_del_lines_count ;
        IF (l_del_lines_count = 0) THEN
            resultout := 'COMPLETE:NOT_SHIPPED';
        END IF;
    END IF;
    WF_ENGINE.SetItemAttrText(
                itemtype => itemtype,
                itemkey  => itemkey,
                aname    => 'NOTIFICATION_TO_ROLE',
                avalue   => FND_GLOBAL.USER_NAME);

    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
END IF;

IF (funcmode = 'CANCEL') THEN
    NULL;
    resultout := 'COMPLETE';
    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
END IF;

-- Other execution modes
resultout := '';
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
RETURN;
EXCEPTION

WHEN NO_DATA_FOUND THEN
    resultout := 'COMPLETE';
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'No record found for the entity.Oracle error message is '||
SQLERRM,WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NO_DATA_FOUND');
    END IF;
    wf_core.context('WSH_WF_INTERFACE',
                    'SCPOD_SHIPPING_STATUS',
                    itemtype,
                    itemkey,
                    to_char(actid),
                    funcmode);
    RAISE;
WHEN OTHERS THEN
    resultout := 'COMPLETE';
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
    SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    wf_core.context('WSH_WF_INTERFACE',
                    'SCPOD_SHIPPING_STATUS',
                    itemtype,
                    itemkey,
                    to_char(actid),
                    funcmode);
    RAISE;
END SCPOD_SHIPPING_STATUS;


----------------------------------------------------------
PROCEDURE SCPOD_C_MARK_INTRANSIT(
                    itemtype IN VARCHAR2,
                    itemkey IN VARCHAR2,
                    actid IN NUMBER,
                    funcmode IN VARCHAR2,
                    resultout OUT NOCOPY VARCHAR2 ) IS


l_delivery_id NUMBER;
l_pickup_stop_id NUMBER;
l_organization_id NUMBER;
l_actual_date DATE;

--l_init_msg_list VARCHAR2 := FND_API.G_FALSE;  -- fnd_api.g_true or fnd_api.g_false
--l_commit VARCHAR2 := FND_API.G_TRUE ;         -- fnd_api.g_true or fnd_api.g_false

l_action_prms WSH_TRIP_STOPS_GRP.action_parameters_rectype;

l_rec_attr_tab WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type;
l_stop_info WSH_TRIP_STOPS_PVT.trip_stop_rec_type;

l_stop_out_rec WSH_TRIP_STOPS_GRP.stopActionOutRecType;
l_def_rec WSH_TRIP_STOPS_GRP.default_parameters_rectype;

l_return_status  VARCHAR2(1);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

CURSOR get_pickup_stop_id IS
SELECT wts.stop_id
FROM   wsh_trip_stops    wts,
    wsh_delivery_legs  wdl,
    wsh_new_deliveries wnd
WHERE  wnd.delivery_id    = to_number(itemkey)
AND   wdl.delivery_id     = wnd.delivery_id
AND   wts.stop_id         = wdl.pick_up_stop_id
AND   wts.stop_location_id = wnd.initial_pickup_location_id;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SCPOD_C_MARK_INTRANSIT';


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
    wsh_debug_sv.log(l_module_name, 'itemtype',itemtype);
    wsh_debug_sv.log(l_module_name, 'itemkey',itemkey);
    wsh_debug_sv.log(l_module_name, 'actid',actid);
    wsh_debug_sv.log(l_module_name, 'funcmode',funcmode);
END IF;

IF (funcmode = 'RUN') THEN

    l_delivery_id := itemkey;
    l_organization_id := WF_ENGINE.GetItemAttrText(itemtype,itemkey,'ORG_ID',FALSE);
    l_actual_date := WF_ENGINE.GetItemAttrDate(itemtype,itemkey,'ACTUAL_DATE',FALSE);

    OPEN get_pickup_stop_id;
    FETCH get_pickup_stop_id into l_pickup_stop_id;
    CLOSE get_pickup_stop_id ;

    WSH_TRIP_STOPS_PVT.Populate_Record (l_pickup_stop_id,l_stop_info,l_return_status);
    l_rec_attr_tab(l_rec_attr_tab.COUNT + 1) := l_stop_info;

    l_action_prms.caller := 'PLSQL';
    l_action_prms.phase := NULL;
    l_action_prms.action_code := 'UPDATE-STATUS';
    l_action_prms.stop_action := 'CLOSE';
    l_action_prms.organization_id := l_organization_id;
    l_action_prms.actual_date := l_actual_date;
    l_action_prms.defer_interface_flag := 'Y';  -- Performed as another atomic transaction
    l_action_prms.report_set_id := NULL;
    l_action_prms.override_flag := 'N';  -- WT-VOL specific

    UPDATE WSH_NEW_DELIVERIES
	    SET del_wf_intransit_attr = 'P'
            WHERE delivery_id = l_delivery_id;

    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_GRP.STOP_ACTION ',
WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;

    WSH_TRIP_STOPS_GRP.Stop_Action (
        p_api_version_number    => 1.0,
        p_init_msg_list         => FND_API.G_FALSE,
        p_commit                => FND_API.G_FALSE,
        p_action_prms           => l_action_prms,
        p_rec_attr_tab          => l_rec_attr_tab,
        x_stop_out_rec          => l_stop_out_rec,
        x_def_rec               => l_def_rec,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data
        );

    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
    END IF;

    IF (l_return_status <>  wsh_util_core.g_ret_sts_error
              AND l_return_status <> wsh_util_core.G_RET_STS_UNEXP_ERROR) THEN
        UPDATE WSH_NEW_DELIVERIES
	    SET del_wf_intransit_attr = 'C'
            WHERE delivery_id = l_delivery_id;
        resultout := 'COMPLETE:SUCCESS';
        fnd_message.set_name('WSH', 'WSH_WF_SCPOD_INTRANSIT');
	l_msg_data := FND_MESSAGE.Get;
    ELSE
        UPDATE WSH_NEW_DELIVERIES
	    SET del_wf_intransit_attr = 'E'
            WHERE delivery_id = l_delivery_id;
        resultout := 'COMPLETE:FAILURE';
    END IF;

    WF_ENGINE.SetItemAttrText(
                itemtype => itemtype,
                itemkey  => itemkey,
                aname => 'SCPOD_INTRANSIT_MSG',
                avalue => l_msg_data);

    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
END IF;

IF (funcmode = 'CANCEL') THEN
    NULL;
    resultout := 'COMPLETE';
    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
END IF;

-- Other execution modes
IF l_debug_on THEN
   WSH_DEBUG_SV.pop(l_module_name);
END IF;
resultout := '';
RETURN;
EXCEPTION

WHEN NO_DATA_FOUND THEN
    resultout := 'COMPLETE:FAILURE';
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'No record found for the entity.Oracle error message is '||
SQLERRM,WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NO_DATA_FOUND');
    END IF;
    wf_core.context('WSH_WF_INTERFACE',
                    'SCPOD_C_MARK_INTRANSIT',
                    itemtype,
                    itemkey,
                    to_char(actid),
                    funcmode);
    RAISE;
WHEN OTHERS THEN
    resultout := 'COMPLETE:FAILURE';
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
    SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    wf_core.context('WSH_WF_INTERFACE',
                    'SCPOD_C_MARK_INTRANSIT',
                    itemtype,
                    itemkey,
                    to_char(actid),
                    funcmode);
    RAISE;

END SCPOD_C_MARK_INTRANSIT;
----------------------------------------------------------
PROCEDURE SCPOD_C_CLOSE_TRIP(
                    itemtype IN VARCHAR2,
                    itemkey IN VARCHAR2,
                    actid IN NUMBER,
                    funcmode IN VARCHAR2,
                    resultout OUT NOCOPY VARCHAR2 ) IS


l_delivery_id            NUMBER;
l_organization_id        NUMBER;
l_actual_date            DATE;
l_intransit_flag         VARCHAR2(1);
l_action_flag            VARCHAR2(1);
l_close_trip_flag        VARCHAR2(1);
l_stage_del_flag         VARCHAR2(1);
l_send_945_flag          VARCHAR2(1);
l_bill_of_lading_flag    VARCHAR2(1);
l_mc_bill_of_lading_flag VARCHAR2(1);
l_ship_method_code       VARCHAR2(30);
l_report_set_id          NUMBER;
l_sc_rule_id             NUMBER;


l_action_prms       WSH_DELIVERIES_GRP.action_parameters_rectype;
l_rec_attr_tab      WSH_NEW_DELIVERIES_PVT.delivery_attr_tbl_type;
l_delivery_info     WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type;

l_delivery_out_rec  WSH_DELIVERIES_GRP.delivery_action_out_rec_type;
l_defaults_rec      WSH_DELIVERIES_GRP.default_parameters_rectype;
l_return_status     VARCHAR2(1);
l_msg_count         NUMBER;
l_msg_data          VARCHAR2(32767);


l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SCPOD_C_CLOSE_TRIP';
l_debug_on BOOLEAN;

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
    wsh_debug_sv.log(l_module_name, 'itemtype',itemtype);
    wsh_debug_sv.log(l_module_name, 'itemkey',itemkey);
    wsh_debug_sv.log(l_module_name, 'actid',actid);
    wsh_debug_sv.log(l_module_name, 'funcmode',funcmode);
END IF;

-- RUN mode - normal process execution
IF (funcmode = 'RUN') THEN

    l_delivery_id           := itemkey;
    l_organization_id       := WF_ENGINE.GetItemAttrText(itemtype,itemkey,'ORG_ID',FALSE);
    l_actual_date           := WF_ENGINE.GetItemAttrDate(itemtype,itemkey,'ACTUAL_DATE',FALSE);
    l_intransit_flag        := WF_ENGINE.GetItemAttrText(itemtype,itemkey,'INTRANSIT_FLAG',FALSE);
    l_action_flag           := WF_ENGINE.GetItemAttrText(itemtype,itemkey,'ACTION_FLAG',FALSE);
    l_close_trip_flag       := WF_ENGINE.GetItemAttrText(itemtype,itemkey,'CLOSE_TRIP_FLAG',FALSE);
    l_stage_del_flag        := WF_ENGINE.GetItemAttrText(itemtype,itemkey,'STAGE_DEL_FLAG',FALSE);
    l_send_945_flag         := WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SEND_945_FLAG',FALSE);
    l_bill_of_lading_flag   := WF_ENGINE.GetItemAttrText(itemtype,itemkey,'CREATE_BOL_FLAG',FALSE);
    l_mc_bill_of_lading_flag:= WF_ENGINE.GetItemAttrText(itemtype,itemkey,'CREATE_MC_BOL_FLAG',FALSE);
    l_ship_method_code      := WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SHIP_METHOD_CODE',FALSE);
    l_report_set_id         := WF_ENGINE.GetItemAttrNumber(itemtype,itemkey,'REPORT_SET_ID',FALSE);
    l_sc_rule_id            := WF_ENGINE.GetItemAttrNumber(itemtype,itemkey,'SC_RULE_ID',FALSE);


    WSH_NEW_DELIVERIES_PVT.Populate_Record (l_delivery_id,l_delivery_info,l_return_status);
    l_rec_attr_tab(l_rec_attr_tab.COUNT + 1) := l_delivery_info;

    l_action_prms.caller                := 'PLSQL';
    l_action_prms.phase                 :=  NULL;
    l_action_prms.action_code           := 'CLOSE';

    -- initializing the action specific parameters
    l_action_prms.trip_id               := NULL;
    l_action_prms.trip_name             := NULL;
    l_action_prms.pickup_stop_id        := NULL; -- p_asg_pickup_stop_id;
    l_action_prms.pickup_loc_id         := NULL; -- p_asg_pickup_loc_id;
    l_action_prms.pickup_stop_seq       := NULL; -- p_asg_pickup_stop_seq;
    l_action_prms.pickup_loc_code       := NULL; -- p_asg_pickup_loc_code;
    l_action_prms.pickup_arr_date       := NULL; -- p_asg_pickup_arr_date;
    l_action_prms.pickup_dep_date       := NULL; -- p_asg_pickup_dep_date;
    l_action_prms.dropoff_stop_id       := NULL; -- p_asg_dropoff_stop_id;
    l_action_prms.pickup_stop_status    := NULL;
    l_action_prms.dropoff_loc_id        := NULL; -- p_asg_dropoff_loc_id;
    l_action_prms.dropoff_stop_seq      := NULL; -- p_asg_dropoff_stop_seq;
    l_action_prms.dropoff_loc_code      := NULL; -- p_asg_dropoff_loc_code;
    l_action_prms.dropoff_arr_date      := NULL; -- p_asg_dropoff_arr_date;
    l_action_prms.dropoff_dep_date      := NULL; -- p_asg_dropoff_dep_date;
    l_action_prms.dropoff_stop_status   := NULL;

    l_action_prms.action_flag           := l_action_flag;
    l_action_prms.intransit_flag        := l_intransit_flag;
    l_action_prms.close_trip_flag       := l_close_trip_flag;
    l_action_prms.stage_del_flag        := l_stage_del_flag;
    l_action_prms.bill_of_lading_flag   := l_bill_of_lading_flag;
    l_action_prms.mc_bill_of_lading_flag:= nvl(l_mc_bill_of_lading_flag,l_bill_of_lading_flag);
    l_action_prms.ship_method_code      := l_ship_method_code;
    l_action_prms.actual_dep_date       := l_actual_date;
    l_action_prms.report_set_id         := l_report_set_id;
    l_action_prms.defer_interface_flag  :=  'Y';  -- Performed as another atomic transaction
    l_action_prms.send_945_flag         := l_send_945_flag;
    l_action_prms.override_flag         := 'N';  -- WT-VOL
    l_action_prms.sc_rule_id            := l_sc_rule_id;
    l_action_prms.organization_id       := l_organization_id;

    l_action_prms.report_set_name       := NULL;  -- the code finds it later
    l_action_prms.sc_rule_name          := NULL;  -- the code finds it later
    l_action_prms.action_type           := NULL;  -- Outbound-Document
    l_action_prms.document_type         := NULL;  -- Outbound-Document(ASN,BOL,MBOL,PS)

    l_action_prms.reason_of_transport   := NULL; -- GENERATE-PACK-SLIP
    l_action_prms.description           := NULL; -- GENERATE-PACK-SLIP
    l_action_prms.maxDelivs             := NULL; -- Trip Consolidation
    l_action_prms.ignore_ineligible_dels:= NULL; -- XXXXX
    l_action_prms.event                 := NULL; --ADJUST-PLANNED-FLAG
    l_action_prms.form_flag             := NULL; --PROCESS_CARRIER_SELECTION

    UPDATE WSH_NEW_DELIVERIES
	    SET del_wf_close_attr = 'P'
            WHERE delivery_id = l_delivery_id;

    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERIES_GRP.DELIVERY_ACTION',
WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;

  wsh_deliveries_grp.delivery_action(
        p_api_version_number     =>  1.0,
        p_init_msg_list          =>  FND_API.G_FALSE,
        p_commit                 =>  FND_API.G_FALSE,
        p_action_prms            =>  l_action_prms,
        p_rec_attr_tab           =>  l_rec_attr_tab,
        x_delivery_out_rec       =>  l_delivery_out_rec,
        x_defaults_rec           =>  l_defaults_rec,
        x_return_status          =>  l_return_status,
        x_msg_count              =>  l_msg_count,
        x_msg_data               =>  l_msg_data);

    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
    END IF;



    IF (l_return_status <>  wsh_util_core.g_ret_sts_error
              AND l_return_status <> wsh_util_core.G_RET_STS_UNEXP_ERROR) THEN
        UPDATE WSH_NEW_DELIVERIES
	    SET del_wf_close_attr = 'C'
            WHERE delivery_id = l_delivery_id;
        resultout := 'COMPLETE:SUCCESS';
        fnd_message.set_name('WSH', 'WSH_WF_SCPOD_CLOSED');
	l_msg_data := FND_MESSAGE.Get;
    ELSE
        UPDATE WSH_NEW_DELIVERIES
	    SET del_wf_close_attr = 'E'
            WHERE delivery_id = l_delivery_id;
        resultout := 'COMPLETE:FAILURE';
    END IF;

    WF_ENGINE.SetItemAttrText(
                itemtype => itemtype,
                itemkey  => itemkey,
                aname => 'SCPOD_DEL_CLOSE_MSG',
                avalue => l_msg_data);

    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
END IF;

IF (funcmode = 'CANCEL') THEN
    resultout := 'COMPLETE';
    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
END IF;

-- Other execution modes
IF l_debug_on THEN
   WSH_DEBUG_SV.pop(l_module_name);
END IF;
resultout := '';
RETURN;

EXCEPTION
WHEN NO_DATA_FOUND THEN
    resultout := 'COMPLETE:FAILURE';
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'No record found for the entity.Oracle error message is '||
SQLERRM,WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NO_DATA_FOUND');
    END IF;
    wf_core.context('WSH_WF_INTERFACE',
                    'SCPOD_C_CLOSE_TRIP',
                    itemtype,
                    itemkey,
                    to_char(actid),
                    funcmode);
    RAISE;
WHEN OTHERS THEN
    resultout := 'COMPLETE:FAILURE';
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
    SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    wf_core.context('WSH_WF_INTERFACE',
                    'SCPOD_C_CLOSE_TRIP',
                    itemtype,
                    itemkey,
                    to_char(actid),
                    funcmode);
    RAISE;

END SCPOD_C_CLOSE_TRIP;

----------------------------------------------------------
PROCEDURE SCPOD_C_RUN_INTERFACE(
                    itemtype IN VARCHAR2,
                    itemkey IN VARCHAR2,
                    actid IN NUMBER,
                    funcmode IN VARCHAR2,
                    resultout OUT NOCOPY VARCHAR2 ) IS


l_delivery_id NUMBER;
l_log_level   NUMBER;
l_request_id  NUMBER;

l_msg_buffer  VARCHAR2(1000);

l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SCPOD_C_RUN_INTERFACE';
l_debug_on    BOOLEAN;

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
    wsh_debug_sv.log(l_module_name, 'itemtype',itemtype);
    wsh_debug_sv.log(l_module_name, 'itemkey',itemkey);
    wsh_debug_sv.log(l_module_name, 'actid',actid);
    wsh_debug_sv.log(l_module_name, 'funcmode',funcmode);
END IF;

-- RUN mode - normal process execution
IF (funcmode = 'RUN') THEN
    l_delivery_id := itemkey;
    l_log_level   := 1;
    UPDATE WSH_NEW_DELIVERIES
	    SET del_wf_interface_attr = 'P'
            WHERE delivery_id = l_delivery_id;

    l_request_id := FND_REQUEST.submit_Request('WSH', 'WSHINTERFACE', '', '', FALSE,
				               'ALL',               -- mode
                                                '',                 -- stop
                                                l_delivery_id,      -- delivery
                                                l_log_level);       -- log level
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Request Id L_REQUEST_ID',l_request_id);
    END IF;

    IF (l_request_id = 0) THEN
	UPDATE WSH_NEW_DELIVERIES
	    SET del_wf_interface_attr = 'E'
            WHERE delivery_id = l_delivery_id;
	resultout := 'COMPLETE:FAILURE';
        fnd_message.set_name('WSH', 'WSH_DET_INV_INT_REQ_SUBMISSION');
        WSH_UTIL_CORE.ADD_MESSAGE(wsh_util_core.g_ret_sts_error,l_module_name);
    ELSE
        UPDATE WSH_NEW_DELIVERIES
	    SET del_wf_interface_attr = 'C'
            WHERE delivery_id = l_delivery_id;
	resultout := 'COMPLETE:SUCCESS';
        FND_MESSAGE.SET_NAME('WSH', 'WSH_DET_INV_INT_SUBMITTED');
        FND_MESSAGE.SET_TOKEN('REQ_ID', to_char(l_request_id));
        WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_SUCCESS,l_module_name);
    END IF;


    l_msg_buffer := FND_MESSAGE.Get;
    WF_ENGINE.SetItemAttrText(
                itemtype => itemtype,
                itemkey  => itemkey,
                aname => 'SCPOD_INTERFACE_MSG',
                avalue => l_msg_buffer);

    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;

END IF;

IF (funcmode = 'CANCEL') THEN
    NULL;
    resultout := 'COMPLETE';
    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
END IF;

-- Other execution modes
IF l_debug_on THEN
   WSH_DEBUG_SV.pop(l_module_name);
END IF;
resultout := '';
RETURN;
EXCEPTION
WHEN OTHERS THEN
    resultout := 'COMPLETE:FAILURE';
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
    SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    wf_core.context('WSH_WF_INTERFACE',
                    'SCPOD_C_RUN_INTERFACE',
                    itemtype,
                    itemkey,
                    to_char(actid),
                    funcmode);
    RAISE;

END SCPOD_C_RUN_INTERFACE;

----------------------------------------------------------
PROCEDURE SCPOD_C_PRINT_DOCSET(
                    itemtype IN VARCHAR2,
                    itemkey IN VARCHAR2,
                    actid IN NUMBER,
                    funcmode IN VARCHAR2,
                    resultout OUT NOCOPY VARCHAR2 ) IS

l_organization_id       NUMBER;
l_report_set_id         NUMBER;
l_dummy_doc_set         WSH_DOCUMENT_SETS.DOCUMENT_SET_TAB_TYPE;
l_delivery_ids          WSH_UTIL_CORE.id_tab_type;
l_dummy_rows1           WSH_UTIL_CORE.id_tab_type;
l_return_status  VARCHAR2(1);

e_print_doc_failed EXCEPTION;

l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SCPOD_C_PRINT_DOCSET';
l_debug_on BOOLEAN;

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
    wsh_debug_sv.log(l_module_name, 'itemtype',itemtype);
    wsh_debug_sv.log(l_module_name, 'itemkey',itemkey);
    wsh_debug_sv.log(l_module_name, 'actid',actid);
    wsh_debug_sv.log(l_module_name, 'funcmode',funcmode);
END IF;

-- RUN mode - normal process execution
IF (funcmode = 'RUN') THEN

    l_delivery_ids(l_delivery_ids.COUNT + 1) := itemkey;
    l_organization_id       := WF_ENGINE.GetItemAttrText(itemtype,itemkey,'ORG_ID',FALSE);
    l_report_set_id         := WF_ENGINE.GetItemAttrNumber(itemtype,itemkey,'REPORT_SET_ID',FALSE);

    IF (l_report_set_id is not null) THEN
	    IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DOCUMENT_SETS.PRINT_DOCUMENT_SETS',
	WSH_DEBUG_SV.C_PROC_LEVEL);
	    END IF;

	    wsh_document_sets.print_document_sets(
		p_report_set_id      => l_report_set_id ,
		p_organization_id    => l_organization_id,
		p_trip_ids           => l_dummy_rows1,
		p_stop_ids           => l_dummy_rows1,
		p_delivery_ids       => l_delivery_ids,
		p_document_param_info=> l_dummy_doc_set,
		x_return_status      => l_return_status);

	    IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
	    END IF;

	    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
	        raise e_print_doc_failed;
	    ELSE
 	        resultout := 'COMPLETE';
	    END IF;
    END IF;
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;

END IF;

IF (funcmode = 'CANCEL') THEN
    NULL;
    resultout := 'COMPLETE';
    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
END IF;

-- Other execution modes
IF l_debug_on THEN
   WSH_DEBUG_SV.pop(l_module_name);
END IF;
resultout := '';
RETURN;
EXCEPTION
WHEN e_print_doc_failed THEN
    resultout := 'COMPLETE';
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Print Document Sets failed.Oracle error message is '||
SQLERRM,WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:E_PRINT_DOC_FAILED');
    END IF;
    wf_core.context('WSH_WF_INTERFACE',
                    'SCPOD_C_PRINT_DOCSET',
                    itemtype,
                    itemkey,
                    to_char(actid),
                    funcmode);
    RAISE;
WHEN OTHERS THEN
    resultout := 'COMPLETE';
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
    SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    wf_core.context('WSH_WF_INTERFACE',
                    'SCPOD_C_PRINT_DOCSET',
                    itemtype,
                    itemkey,
                    to_char(actid),
                    funcmode);
    RAISE;
END SCPOD_C_PRINT_DOCSET;


----------------------------------------------------------
PROCEDURE SCPOD_C_INTRANSIT_CK(
                    itemtype IN VARCHAR2,
                    itemkey IN VARCHAR2,
                    actid IN NUMBER,
                    funcmode IN VARCHAR2,
                    resultout OUT NOCOPY VARCHAR2 ) IS

l_intransit_flag VARCHAR2(1);

l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SCPOD_C_INTRANSIT_CK';
l_debug_on BOOLEAN;

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
    wsh_debug_sv.log(l_module_name, 'itemtype',itemtype);
    wsh_debug_sv.log(l_module_name, 'itemkey',itemkey);
    wsh_debug_sv.log(l_module_name, 'actid',actid);
    wsh_debug_sv.log(l_module_name, 'funcmode',funcmode);
END IF;

-- RUN mode - normal process execution
IF (funcmode = 'RUN') THEN
    l_intransit_flag := WF_ENGINE.GetItemAttrText(itemtype,itemkey,'INTRANSIT_FLAG',TRUE);
    IF (l_intransit_flag = 'Y') THEN
        resultout := 'COMPLETE:Y';
    ELSE
        resultout := 'COMPLETE:N';
    END IF;
    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
END IF;

IF (funcmode = 'CANCEL') THEN
    NULL;
    resultout := 'COMPLETE';
    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
END IF;

-- Other execution modes
IF l_debug_on THEN
   WSH_DEBUG_SV.pop(l_module_name);
END IF;
resultout := '';
RETURN;
EXCEPTION
WHEN OTHERS THEN
    resultout := 'COMPLETE';
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
    SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    wf_core.context('WSH_WF_INTERFACE',
                    'SCPOD_C_INTRANSIT_CK',
                    itemtype,
                    itemkey,
                    to_char(actid),
                    funcmode);
    RAISE;
END SCPOD_C_INTRANSIT_CK;

----------------------------------------------------------
PROCEDURE SCPOD_C_INTERFACE_CK(
                    itemtype IN VARCHAR2,
                    itemkey IN VARCHAR2,
                    actid IN NUMBER,
                    funcmode IN VARCHAR2,
                    resultout OUT NOCOPY VARCHAR2 ) IS

l_defer_interface_flag VARCHAR2(1);

l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SCPOD_C_INTERFACE_CK';
l_debug_on BOOLEAN;

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
    wsh_debug_sv.log(l_module_name, 'itemtype',itemtype);
    wsh_debug_sv.log(l_module_name, 'itemkey',itemkey);
    wsh_debug_sv.log(l_module_name, 'actid',actid);
    wsh_debug_sv.log(l_module_name, 'funcmode',funcmode);
END IF;

-- RUN mode - normal process execution
IF (funcmode = 'RUN') THEN
    l_defer_interface_flag := WF_ENGINE.GetItemAttrText(itemtype,itemkey,'DEFER_INTERFACE_FLAG',FALSE);
    IF (l_defer_interface_flag = 'Y') THEN
        resultout := 'COMPLETE:Y';
    ELSE
        resultout := 'COMPLETE:N';
    END IF;
    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
END IF;

IF (funcmode = 'CANCEL') THEN
    NULL;
    resultout := 'COMPLETE';
    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
END IF;

-- Other execution modes
IF l_debug_on THEN
   WSH_DEBUG_SV.pop(l_module_name);
END IF;
resultout := '';
RETURN;

EXCEPTION
WHEN OTHERS THEN
    resultout := 'COMPLETE';
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
    SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    wf_core.context('WSH_WF_INTERFACE',
                    'SCPOD_C_INTERFACE_CK',
                    itemtype,
                    itemkey,
                    to_char(actid),
                    funcmode);
    RAISE;
END SCPOD_C_INTERFACE_CK;

----------------------------------------------------------
PROCEDURE SCPOD_C_CLOSE_TRIP_CK(
                    itemtype IN VARCHAR2,
                    itemkey IN VARCHAR2,
                    actid IN NUMBER,
                    funcmode IN VARCHAR2,
                    resultout OUT NOCOPY VARCHAR2 ) IS

l_close_flag VARCHAR2(1);

l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SCPOD_C_CLOSE_TRIP_CK';
l_debug_on BOOLEAN;

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
    wsh_debug_sv.log(l_module_name, 'itemtype',itemtype);
    wsh_debug_sv.log(l_module_name, 'itemkey',itemkey);
    wsh_debug_sv.log(l_module_name, 'actid',actid);
    wsh_debug_sv.log(l_module_name, 'funcmode',funcmode);
END IF;

-- RUN mode - normal process execution
IF (funcmode = 'RUN') THEN
    l_close_flag := WF_ENGINE.GetItemAttrText(itemtype,itemkey,'CLOSE_TRIP_FLAG',FALSE);
    IF (l_close_flag = 'Y') THEN
        resultout := 'COMPLETE:Y';
    ELSE
        resultout := 'COMPLETE:N';
    END IF;
    IF l_debug_on THEN
	WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
END IF;

IF (funcmode = 'CANCEL') THEN
    NULL;
    resultout := 'COMPLETE';
    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
END IF;

-- Other execution modes
IF l_debug_on THEN
   WSH_DEBUG_SV.pop(l_module_name);
END IF;
resultout := '';
RETURN;
EXCEPTION
WHEN OTHERS THEN
    resultout := 'COMPLETE';
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
    SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    wf_core.context('WSH_WF_INTERFACE',
                    'SCPOD_C_CLOSE_TRIP_CK',
                    itemtype,
                    itemkey,
                    to_char(actid),
                    funcmode);
    RAISE;
END SCPOD_C_CLOSE_TRIP_CK;

----------------------------------------------------------
PROCEDURE ITM_AT_SHIP_CONFIRM(
                    itemtype IN VARCHAR2,
                    itemkey IN VARCHAR2,
                    actid IN NUMBER,
                    funcmode IN VARCHAR2,
                    resultout OUT NOCOPY VARCHAR2 ) IS

l_screening_flag VARCHAR2(1);
l_param_info WSH_SHIPPING_PARAMS_PVT.Parameter_Rec_Typ;
l_organization_id NUMBER;

l_return_status VARCHAR2(30);
e_param_not_defined EXCEPTION;

l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ITM_AT_SHIP_CONFIRM';
l_debug_on BOOLEAN;

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
    wsh_debug_sv.log(l_module_name, 'itemtype',itemtype);
    wsh_debug_sv.log(l_module_name, 'itemkey',itemkey);
    wsh_debug_sv.log(l_module_name, 'actid',actid);
    wsh_debug_sv.log(l_module_name, 'funcmode',funcmode);
END IF;

-- RUN mode - normal process execution
IF (funcmode = 'RUN') THEN

    l_screening_flag := 'N';
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIPPING_PARAMS_PVT.GET',
WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;

    l_organization_id := WF_ENGINE.GetItemAttrText(itemtype,itemkey,'ORG_ID',FALSE);
    WSH_SHIPPING_PARAMS_PVT.Get(p_organization_id => l_organization_id,
	                        x_param_info      => l_param_info,
                                x_return_status   => l_return_status);
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
    END IF;

    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
	raise e_param_not_defined;
    ELSE
        l_screening_flag := NVL(l_param_info.EXPORT_SCREENING_FLAG,'N');
    END IF;

    IF (l_screening_flag = 'A' OR l_screening_flag = 'S') THEN	-- assuming only N,A,C,S
        resultout := 'COMPLETE:YES';
    ELSE
        resultout := 'COMPLETE:NO';
    END IF;
    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
END IF;

IF (funcmode = 'CANCEL') THEN
    NULL;
    resultout := 'COMPLETE';
    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
END IF;

-- Other execution modes
IF l_debug_on THEN
   WSH_DEBUG_SV.pop(l_module_name);
END IF;
resultout := '';
RETURN;
EXCEPTION
WHEN E_PARAM_NOT_DEFINED THEN
    resultout := 'COMPLETE:';
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'No shipping parameters found for this organization'||
SQLERRM,WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:E_PARAM_NOT_DEFINED');
    END IF;
    wf_core.context('WSH_WF_INTERFACE',
                    'ITM_AT_SHIP_CONFIRM',
                    itemtype,
                    itemkey,
                    to_char(actid),
                    funcmode);
    RAISE;
WHEN OTHERS THEN
    resultout := 'COMPLETE:';
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
    SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    wf_core.context('WSH_WF_INTERFACE',
                    'ITM_AT_SHIP_CONFIRM',
                    itemtype,
                    itemkey,
                    to_char(actid),
                    funcmode);
    RAISE;

END ITM_AT_SHIP_CONFIRM;
----------------------------------------------------------
PROCEDURE ITM_AT_DEL_CR(
                    itemtype IN VARCHAR2,
                    itemkey IN VARCHAR2,
                    actid IN NUMBER,
                    funcmode IN VARCHAR2,
                    resultout OUT NOCOPY VARCHAR2 ) IS

l_screening_flag VARCHAR2(1);
l_param_info WSH_SHIPPING_PARAMS_PVT.Parameter_Rec_Typ;
l_organization_id NUMBER;

l_return_status VARCHAR2(30);
e_param_not_defined EXCEPTION;

l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ITM_AT_DEL_CR';
l_debug_on BOOLEAN;

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
    wsh_debug_sv.log(l_module_name, 'itemtype',itemtype);
    wsh_debug_sv.log(l_module_name, 'itemkey',itemkey);
    wsh_debug_sv.log(l_module_name, 'actid',actid);
    wsh_debug_sv.log(l_module_name, 'funcmode',funcmode);
END IF;

-- RUN mode - normal process execution
IF (funcmode = 'RUN') THEN

    l_screening_flag := 'N';
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIPPING_PARAMS_PVT.GET',
WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;

    l_organization_id := WF_ENGINE.GetItemAttrText(itemtype,itemkey,'ORG_ID',FALSE);
    WSH_SHIPPING_PARAMS_PVT.Get(p_organization_id => l_organization_id,
	                        x_param_info      => l_param_info,
                                x_return_status   => l_return_status);
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
    END IF;

    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
	raise e_param_not_defined;
    ELSE
        l_screening_flag := NVL(l_param_info.EXPORT_SCREENING_FLAG,'N');
    END IF;

    IF (l_screening_flag = 'A' OR l_screening_flag = 'C') THEN	-- assuming only N,A,C,S
        resultout := 'COMPLETE:YES';
    ELSE
        resultout := 'COMPLETE:NO';
    END IF;
    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
END IF;

IF (funcmode = 'CANCEL') THEN
    NULL;
    resultout := 'COMPLETE';
    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
END IF;

-- Other execution modes
IF l_debug_on THEN
   WSH_DEBUG_SV.pop(l_module_name);
END IF;
resultout := '';
RETURN;
EXCEPTION
WHEN E_PARAM_NOT_DEFINED THEN
    resultout := 'COMPLETE:NO';
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'No shipping parameters found for this organization'||
SQLERRM,WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:E_PARAM_NOT_DEFINED');
    END IF;
    wf_core.context('WSH_WF_INTERFACE',
                    'ITM_AT_DEL_CR',
                    itemtype,
                    itemkey,
                    to_char(actid),
                    funcmode);
    RAISE;
WHEN OTHERS THEN
    resultout := 'COMPLETE:NO';
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
    SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    wf_core.context('WSH_WF_INTERFACE',
                    'ITM_AT_DEL_CR',
                    itemtype,
                    itemkey,
                    to_char(actid),
                    funcmode);
    RAISE;

END ITM_AT_DEL_CR;

----------------------------------------------------------

PROCEDURE SCPOD_C_SUBMIT_ITM(
                    itemtype IN VARCHAR2,
                    itemkey IN VARCHAR2,
                    actid IN NUMBER,
                    funcmode IN VARCHAR2,
                    resultout OUT NOCOPY VARCHAR2 ) IS

l_delivery_id     NUMBER;
l_organization_id NUMBER;
l_return_status   VARCHAR2(1);
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SCPOD_C_SUBMIT_ITM';
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
    wsh_debug_sv.push(l_module_name);
    wsh_debug_sv.log(l_module_name, 'itemtype',itemtype);
    wsh_debug_sv.log(l_module_name, 'itemkey',itemkey);
    wsh_debug_sv.log(l_module_name, 'actid',actid);
    wsh_debug_sv.log(l_module_name, 'funcmode',funcmode);
END IF;

-- RUN mode - normal process execution
IF (funcmode = 'RUN') THEN
    l_delivery_id := itemkey;
    l_organization_id       := WF_ENGINE.GetItemAttrText(itemtype,itemkey,'ORG_ID',FALSE);


    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ITM_EXPORT_SCREENING.SCREEN_EVENT_DELIVERIES',
WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;

    WSH_ITM_EXPORT_SCREENING.Screen_Event_Deliveries (
                x_return_status            => l_return_status,
                p_organization_id          => l_organization_id,
                p_delivery_from_id         => l_delivery_id ,
                p_delivery_to_id           => l_delivery_id,
                p_event_name               => 'SHIP_CONFIRM',
                p_ship_method_code         => null,
                p_pickup_date_from         => null,
                p_pickup_date_to           => null);
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
    END IF;

    IF (l_return_status <>  wsh_util_core.g_ret_sts_error
              AND l_return_status <> wsh_util_core.G_RET_STS_UNEXP_ERROR) THEN
        resultout := 'COMPLETE:';
    ELSE
        resultout := '';
    END IF;
RETURN;
END IF;

IF (funcmode = 'CANCEL') THEN
    resultout := 'COMPLETE';
    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
END IF;
-- Other execution modes
IF l_debug_on THEN
   WSH_DEBUG_SV.pop(l_module_name);
END IF;
resultout := '';
RETURN;
EXCEPTION
WHEN OTHERS THEN
-- The line below records this function call in the error
-- system in the case of an exception.
wf_core.context('XX_ITEM_TYPE', 'XX_ACTIVITY_NAME',
itemtype, itemkey, to_char(actid),
funcmode);
RAISE;
END SCPOD_C_SUBMIT_ITM;

----------------------------------------------------------

PROCEDURE SCPOD_SCWF_STATUS(
                    itemtype IN VARCHAR2,
                    itemkey IN VARCHAR2,
                    actid IN NUMBER,
                    funcmode IN VARCHAR2,
                    resultout OUT NOCOPY VARCHAR2 ) IS

CURSOR get_global_parameters IS
SELECT enable_sc_wf
FROM WSH_GLOBAL_PARAMETERS;

CURSOR get_shipping_parameters(p_org_id IN NUMBER) IS
SELECT enable_sc_wf
FROM WSH_SHIPPING_PARAMETERS
WHERE organization_id = p_org_id;

CURSOR get_org_code(p_org_id IN NUMBER) IS
SELECT organization_code
FROM MTL_PARAMETERS
WHERE organization_id = p_org_id;

l_gl_enable_sc_flag VARCHAR2(1);
l_sp_enable_sc_flag VARCHAR2(1);
l_organization_id   NUMBER;
l_organization_code VARCHAR2(3);
l_override_wf       VARCHAR2(1);
l_return_status     VARCHAR2(1);
l_scpod_wf_process_exists VARCHAR2(1);
l_custom_process_name     VARCHAR2(30);
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SCPOD_SCWF_STATUS';
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
    wsh_debug_sv.push(l_module_name);
    wsh_debug_sv.log(l_module_name, 'itemtype',itemtype);
    wsh_debug_sv.log(l_module_name, 'itemkey',itemkey);
    wsh_debug_sv.log(l_module_name, 'actid',actid);
    wsh_debug_sv.log(l_module_name, 'funcmode',funcmode);
END IF;

-- RUN mode - normal process execution
IF (funcmode = 'RUN') THEN

    l_organization_id := WF_ENGINE.GetItemAttrText(itemtype,itemkey,'ORG_ID',FALSE);
    OPEN get_global_parameters;
    FETCH get_global_parameters into l_gl_enable_sc_flag;
    CLOSE get_global_parameters ;

    OPEN get_shipping_parameters(l_organization_id);
    FETCH get_shipping_parameters into l_sp_enable_sc_flag;
    CLOSE get_shipping_parameters ;

    l_override_wf:= fnd_profile.value('WSH_OVERRIDE_SCPOD_WF');

    IF (NVL(l_gl_enable_sc_flag,'N') = 'Y' AND NVL(l_sp_enable_sc_flag,'N') = 'Y'
                                           AND l_override_wf = 'N') THEN

	OPEN get_org_code(l_organization_id);
        FETCH get_org_code into l_organization_code;
        CLOSE get_org_code ;

	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.GET_CUSTOM_WF_PROCESS', WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
        WSH_WF_STD.Get_Custom_Wf_Process(p_wf_process    => 'R_SCPOD_C',
	                      p_org_code      => l_organization_code,
			      x_wf_process    => l_custom_process_name,
			      x_return_status => l_return_status);
	IF l_debug_on THEN
	    WSH_DEBUG_SV.log(l_module_name,'L_SCPOD_WF_PROCESS_EXISTS',l_scpod_wf_process_exists);
	    WSH_DEBUG_SV.log(l_module_name,'L_RETURN_STATUS',l_return_status);
	END IF;

	IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND l_custom_process_name is null) THEN
            l_custom_process_name := 'R_SCPOD_C';
	END IF;

	UPDATE WSH_NEW_DELIVERIES
            SET delivery_scpod_wf_process=l_custom_process_name
            WHERE delivery_id=to_number(itemkey);
        resultout := 'COMPLETE:ENABLED';
    ELSE
        resultout := 'COMPLETE:DISABLED';
    END IF;
    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
END IF;
IF (funcmode = 'CANCEL') THEN
    NULL;
    resultout := 'COMPLETE';
    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
END IF;

-- Other execution modes
IF l_debug_on THEN
   WSH_DEBUG_SV.pop(l_module_name);
END IF;
resultout := '';
RETURN;

EXCEPTION
WHEN NO_DATA_FOUND THEN
    resultout := 'COMPLETE';
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'No record found for the entity.Oracle error message is '||
SQLERRM,WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NO_DATA_FOUND');
    END IF;
    wf_core.context('WSH_WF_INTERFACE',
                    'SCPOD_SCWF_STATUS',
                    itemtype,
                    itemkey,
                    to_char(actid),
                    funcmode);
    RAISE;
WHEN OTHERS THEN
    resultout := 'COMPLETE';
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
    SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    wf_core.context('WSH_WF_INTERFACE',
                    'SCPOD_SCWF_STATUS',
                    itemtype,
                    itemkey,
                    to_char(actid),
                    funcmode);
    RAISE;
END SCPOD_SCWF_STATUS;
----------------------------------------------------------
/* CURRENTLY NOT IN USE
PROCEDURE Manifesting_Status(
                    itemtype IN VARCHAR2,
                    itemkey IN VARCHAR2,
                    actid IN NUMBER,
                    funcmode IN VARCHAR2,
                    resultout OUT NOCOPY VARCHAR2 ) IS

CURSOR get_manifest_status(l_delivery_id NUMBER) IS
SELECT count(wnd.delivery_id)
FROM wsh_new_deliveries wnd,
     mtl_parameters mp,
     wsh_carriers wc
WHERE  wnd.organization_id = mp.organization_id
AND    wnd.carrier_id = wc.carrier_id
AND    wc.manifesting_enabled_flag = 'Y'
AND    mp.carrier_manifesting_flag = 'Y'
AND    wnd.delivery_id = l_delivery_id;

l_delivery_id NUMBER;
l_manifest_enabled NUMBER;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'MANIFESTING_STATUS';
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
    wsh_debug_sv.push(l_module_name);
    wsh_debug_sv.log(l_module_name, 'itemtype',itemtype);
    wsh_debug_sv.log(l_module_name, 'itemkey',itemkey);
    wsh_debug_sv.log(l_module_name, 'actid',actid);
    wsh_debug_sv.log(l_module_name, 'funcmode',funcmode);
END IF;

-- RUN mode - normal process execution
IF (funcmode = 'RUN') THEN

    l_delivery_id := itemkey;
    OPEN get_manifest_status(l_delivery_id);
    FETCH get_manifest_status into l_manifest_enabled;
    CLOSE get_manifest_status ;

    IF (l_manifest_enabled = 1) THEN
        resultout := 'COMPLETE:ENABLED';
    ELSE
        resultout := 'COMPLETE:DISABLED';
    END IF;
    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
END IF;
IF (funcmode = 'CANCEL') THEN
    NULL;
    resultout := 'COMPLETE';
    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
END IF;

-- Other execution modes
IF l_debug_on THEN
   WSH_DEBUG_SV.pop(l_module_name);
END IF;
resultout := '';
RETURN;

EXCEPTION
WHEN NO_DATA_FOUND THEN
    resultout := 'COMPLETE';
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'No record found for the entity.Oracle error message is '||
SQLERRM,WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NO_DATA_FOUND');
    END IF;
    wf_core.context('WSH_WF_INTERFACE',
                    'MANIFESTING_STATUS',
                    itemtype,
                    itemkey,
                    to_char(actid),
                    funcmode);
    RAISE;
WHEN OTHERS THEN
    resultout := 'COMPLETE';
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
    SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    wf_core.context('WSH_WF_INTERFACE',
                    'MANIFESTING_STATUS',
                    itemtype,
                    itemkey,
                    to_char(actid),
                    funcmode);
    RAISE;
END Manifesting_Status;
----------------------------------------------------------
*/

PROCEDURE Selector(
		itemtype IN VARCHAR2,
		itemkey IN VARCHAR2,
		actid IN NUMBER,
		funcmode IN VARCHAR2,
		resultout OUT NOCOPY VARCHAR2) IS

l_user_id             NUMBER;
l_resp_id             NUMBER;
l_resp_appl_id        NUMBER;
l_org_id              NUMBER;
l_current_org_id      NUMBER;
l_client_org_id       NUMBER;

--
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SELECTOR';
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
    wsh_debug_sv.push(l_module_name);
    wsh_debug_sv.log(l_module_name, 'itemtype',itemtype);
    wsh_debug_sv.log(l_module_name, 'itemkey',itemkey);
    wsh_debug_sv.log(l_module_name, 'actid',actid);
    wsh_debug_sv.log(l_module_name, 'funcmode',funcmode);
END IF;

-- Currently RUN mode is not being used. We are using the WSH_WF_STD pkg functions
-- to find out the process that needs to be launched and are passing that
-- process name in the createprocess call.
IF (funcmode='RUN') THEN
	resultout:='COMPLETE';
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	RETURN;
END IF;

-- Engine calls SET_CTX just before activity execution
-- The workflow engine calls the selector function
-- in the SET_CTX mode to set the database context
-- correctly for executing a function activity.
IF (funcmode = 'SET_CTX') THEN
-- FND_GLOBAL.Apps_Initialize(FND_GLOBAL.USER_ID,FND_GLOBAL.RESP_ID, FND_GLOBAL.RESP_APPL_ID);

   -- Any caller that calls the WF_ENGINE can set this to TRUE in which case
   -- we will reset apps context to that of the user who created the wf item.
   IF WSH_WF_STD.G_RESET_APPS_CONTEXT THEN
	l_org_id :=  to_number(wf_engine.GetItemAttrText( itemtype,itemkey,'ORG_ID'));

        IF l_org_id is null THEN
             RAISE NO_DATA_FOUND;
        ELSE
             -- Set the database session context
	     MO_GLOBAL.set_policy_context ('S', l_org_id);
             -- FND_GLOBAL.Apps_Initialize(l_user_id, l_resp_id, l_resp_appl_id);
        END IF;
    END IF;
    resultout:='COMPLETE';
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
END IF;
IF (funcmode = 'TEST_CTX') THEN
    IF WSH_WF_STD.G_RESET_APPS_CONTEXT THEN
	l_org_id :=  to_number(wf_engine.GetItemAttrText( itemtype,itemkey,'ORG_ID'));
	IF l_debug_on THEN
            wsh_debug_sv.log (l_module_name, 'l_wf_org_id', l_org_id);
	END IF;
        IF l_org_id IS NULL THEN
            resultout := 'TRUE';  -- No Org to match against .. Single Org Env..
        ELSE -- Org Id is not null
             -- Fetch Current Env Org.
            IF l_debug_on THEN
                wsh_debug_sv.log (l_module_name, 'l_current_org_id', MO_GLOBAL.get_current_org_id);
            END IF;
            IF NVL(MO_GLOBAL.get_current_org_id, -99) <> l_org_id THEN
                resultout := 'FALSE';
            ELSE
                resultout := 'TRUE';
            END IF;
        END IF; -- if org_id is null
    ELSE
	resultout := 'TRUE';
    END IF;

    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
END IF;

END Selector;

END WSH_WF_INTERFACE;

/
