--------------------------------------------------------
--  DDL for Package Body WSH_DELIVERY_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_DELIVERY_UTIL" 
-- $Header: WSHDLUTB.pls 120.0.12000000.2 2007/01/23 19:12:49 rvishnuv ship $
AS

/*===========================================================================
|                                                                           |
| PROCEDURE NAME   Update_Dlvy_Status                                       |
|                                                                           |
| DESCRIPTION      This procedure  is used to update the delivery status    |
|                  appropriately depending on the parameters passed.        |
|                                                                           |
| MODIFICATION HISTORY                                                      |
|                                                                           |
|    02/20/02      Ravikiran  Vishnuvajhala  Created                        |
|                                                                           |
============================================================================*/
--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_DELIVERY_UTIL';
--
procedure Update_Dlvy_Status(	p_delivery_id	IN NUMBER,
				p_action_code IN VARCHAR2 ,
				p_document_type IN VARCHAR2 ,
				x_return_status OUT NOCOPY  VARCHAR2
			    )
IS

--pragma AUTONOMOUS_TRANSACTION;

l_del_rows	wsh_util_core.id_tab_type;
l_planned_flag	varchar2(1);

wsh_plan_error EXCEPTION;
wsh_unplan_error EXCEPTION;
wsh_invalid_doc_type EXCEPTION;
wsh_invalid_action_type EXCEPTION;
l_return_status VARCHAR2(1);
l_valid_flag BOOLEAN;
l_warning_count NUMBER :=0;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_DLVY_STATUS';
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
  wsh_debug_sv.push(l_module_name, 'Update_Dlvy_Status');
  wsh_debug_sv.log(l_module_name, 'p_delivery_id',p_delivery_id);
  wsh_debug_sv.log(l_module_name, 'p_action_code',p_action_code);
  wsh_debug_sv.log(l_module_name, 'p_document_type',p_document_type);
 END IF;

  l_return_status :=wsh_util_core.g_ret_sts_success;

  -- It unlocks the delivery and sets it to 'OP' status if p_action_code is null
  -- Plan and Unplan APIs do not recognize the new statuses, therefore we have
  -- to call them only after the delivery status is set to 'OP'

  IF p_action_code IS NULL THEN

     update wsh_new_deliveries
     set status_code ='OP'
     where delivery_id = p_delivery_id
     and status_code IN ('SR','SC');

     l_del_rows(l_del_rows.COUNT + 1) := p_delivery_id;
     WSH_NEW_DELIVERY_ACTIONS.Unplan(p_del_rows	=> l_del_rows,
				     x_return_status => l_return_status);

     IF l_debug_on THEN
      wsh_debug_sv.log (l_module_name,'Unplan->x_return_status: ',l_return_status);
     END IF;

     IF ( l_return_status not in (wsh_util_core.g_ret_sts_success,wsh_util_core.g_ret_sts_warning) ) THEN
        raise wsh_unplan_error;
     ELSE
               IF (l_return_status = wsh_util_core.g_ret_sts_warning) THEN
                  WSH_DELIVERY_VALIDATIONS.check_smc(p_delivery_id => p_delivery_id,
                                                     x_valid_flag => l_valid_flag,
                                                     x_return_status => l_return_status);
                  IF l_debug_on THEN
                   wsh_debug_sv.log (l_module_name,'check_smc->x_return_status: ',l_return_status);
                  END IF;

                  IF (l_return_status <> wsh_util_core.g_ret_sts_success) THEN
                    raise wsh_plan_error;
                  ELSE
                     l_warning_count:=l_warning_count + 1;
                  END IF;
               END IF;
     END IF;
  ELSIF ( p_action_code = 'A' ) THEN
      IF p_document_type IS NULL THEN
	 raise wsh_invalid_doc_type;
      ELSIF (p_document_type = 'SR' ) THEN

	 select planned_flag into l_planned_flag
	 from wsh_new_deliveries
	 where delivery_id = p_delivery_id;

	 IF l_planned_flag = 'N' THEN

            l_del_rows(l_del_rows.COUNT + 1) := p_delivery_id;
            WSH_NEW_DELIVERY_ACTIONS.Plan( p_del_rows		=> l_del_rows,
	   				   x_return_status	=> l_return_status);

            IF l_debug_on THEN
             wsh_debug_sv.log (l_module_name,'plan->x_return_status: ',l_return_status);
            END IF;

            IF ( l_return_status not in (wsh_util_core.g_ret_sts_success,wsh_util_core.g_ret_sts_warning) ) THEN
	       raise wsh_plan_error;
            ELSE
               IF (l_return_status = wsh_util_core.g_ret_sts_warning) THEN
                  WSH_DELIVERY_VALIDATIONS.check_smc(p_delivery_id => p_delivery_id,
                                                     x_valid_flag => l_valid_flag,
                                                     x_return_status => l_return_status);
                  IF l_debug_on THEN
                   wsh_debug_sv.log (l_module_name,'check_smc->x_return_status: ',l_return_status);
                  END IF;

                  IF (l_return_status <> wsh_util_core.g_ret_sts_success) THEN
                    raise wsh_plan_error;
                  ELSE
                     l_warning_count:=l_warning_count + 1;
                  END IF;
               END IF;
            END IF;
	 END IF;
         update wsh_new_deliveries
         set status_code ='SR'
         where delivery_id = p_delivery_id
         and status_code = 'OP';
     ELSIF ( p_document_type = 'SA' ) THEN
	 update wsh_new_deliveries
	 set status_code ='SA'
	 where delivery_id = p_delivery_id
	 and status_code IN ('SR','SC');
     ELSE
	 raise wsh_invalid_doc_type;
     END IF;
  ELSIF (p_action_code = 'D' ) THEN
     update wsh_new_deliveries
     set status_code ='SC'
     where delivery_id = p_delivery_id
     and status_code = 'SR';
  ELSE
     raise wsh_invalid_action_type;
  END IF;

  IF l_debug_on THEN
   wsh_debug_sv.log (l_module_name,'l_return_status: ',l_return_status);
  END IF;

  IF (l_warning_count > 0 ) THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING ;
  ELSE
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  END IF;

  IF l_debug_on THEN
   wsh_debug_sv.pop (l_module_name);
  END IF;
  --commit;

EXCEPTION
WHEN wsh_plan_error THEN
     x_return_status := l_return_status;
     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'wsh_plan_error exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_plan_error');
     END IF;
WHEN wsh_unplan_error THEN
     x_return_status := l_return_status;
     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'wsh_unplan_error exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_unplan_error');
     END IF;
WHEN wsh_invalid_doc_type THEN
     x_return_status := wsh_util_core.g_ret_sts_error;
     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'wsh_invalid_doc_type exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_invalid_doc_type');
     END IF;
WHEN wsh_invalid_action_type THEN
     x_return_status := wsh_util_core.g_ret_sts_error;
     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'wsh_invalid_action_type exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_invalid_action_type');
     END IF;
WHEN others THEN
     x_return_status := wsh_util_core.g_ret_sts_unexp_error;
     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;
END Update_Dlvy_Status;


FUNCTION Is_SendDoc_Allowed( p_delivery_id	IN NUMBER,
			    p_action_code IN VARCHAR2 DEFAULT 'A',
			    x_return_status OUT NOCOPY  VARCHAR2)
RETURN BOOLEAN
IS

cursor del_status_cur is
select status_code, planned_flag
from wsh_new_deliveries
where delivery_id =p_delivery_id;

cursor det_tpw_cur is
select 'X'
from wsh_delivery_details wdd,
     wsh_delivery_assignments_v wda
where wdd.delivery_detail_id = wda.delivery_detail_id
and   wdd.container_flag='N'
and   wdd.source_code ='WSH'
and   wda.delivery_id=p_delivery_id
and   rownum = 1;

l_status_code VARCHAR2(2);
l_planned_flag VARCHAR2(1);
l_det_temp VARCHAR2(1);
--k proj bmso

CURSOR c_get_event_key (v_delivery_id number)  is
select wth.event_key, wth.item_type
from wsh_new_deliveries wnd,
wsh_transactions_history wth
where delivery_id =v_delivery_id
and wnd.name = wth.entity_number
and wth.document_direction = 'O'
and wth.document_type = 'SR'
and wth.action_type = 'A'
and wth.entity_type = 'DLVY'
order by transaction_id desc;

cursor c_inbound_txn_csr (v_event_key VARCHAR2, v_item_type VARCHAR2)  is
select 'X'
from wsh_transactions_history
where event_key = v_event_key
and   item_type = v_item_type
and   document_direction = 'I'
and   action_type = 'A'
and   document_type = 'SA'
order by transaction_id desc;

l_sa_exist  VARCHAR2(1);
l_event_key wsh_transactions_history.event_key%TYPE;
l_item_type wsh_transactions_history.item_type%TYPE;

wsh_del_not_found EXCEPTION;
wsh_invalid_action_code EXCEPTION;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'IS_SENDDOC_ALLOWED';
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
  wsh_debug_sv.push(l_module_name, 'Is_SendDoc_Allowed');
  wsh_debug_sv.log (l_module_name, 'p_delivery_id',p_delivery_id);
  wsh_debug_sv.log (l_module_name, 'p_action_code',p_action_code);
 END IF;

  open del_status_cur;
  Fetch del_status_cur into l_status_code, l_planned_flag;
  IF del_status_cur%NOTFOUND THEN
     close del_status_cur;
     raise wsh_del_not_found;
  END IF;
  IF del_status_cur%ISOPEN THEN
     close del_status_cur;
  END IF;
 IF l_debug_on THEN
  wsh_debug_sv.log (l_module_name, ' Status Code',l_status_code);
  wsh_debug_sv.log (l_module_name, ' Planned Flag', l_planned_flag);
 END IF;

  IF ( p_action_code = 'A' ) THEN

     IF ( l_status_code = 'OP') THEN
	open det_tpw_cur;
	fetch det_tpw_cur into l_det_temp;
	close det_tpw_cur;
	IF l_det_temp is null THEN
           IF l_debug_on THEN
            wsh_debug_sv.pop (l_module_name,'RETURN-TRUE');
           END IF;
	   RETURN TRUE;
	ELSE
           IF l_debug_on THEN
            wsh_debug_sv.pop (l_module_name,'RETURN-FALSE');
           END IF;
	   RETURN FALSE;
	END IF;
     ELSE
        IF l_debug_on THEN
         wsh_debug_sv.pop (l_module_name,'RETURN-FALSE');
        END IF;
	RETURN FALSE;
     END IF;
  ELSIF ( p_action_code = 'D' ) THEN
     IF ( l_status_code = 'SR' and  l_planned_flag IN ('Y', 'F') ) THEN

        --k proj bmso
        -- if for cancellation the Shipment Advice record exist and
        -- delivery status is in SR then do not allow the cancellation
        -- to be sent.

        OPEN c_get_event_key(p_delivery_id);
        FETCH c_get_event_key INTO l_event_key, l_item_type;
        CLOSE c_get_event_key;

        IF l_debug_on THEN
           wsh_debug_sv.log (l_module_name, 'l_event_key',l_event_key);
           wsh_debug_sv.log (l_module_name, 'l_item_type',l_item_type);
        END IF;

        OPEN c_inbound_txn_csr(l_event_key,l_item_type);
        FETCH c_inbound_txn_csr INTO l_sa_exist;
        CLOSE c_inbound_txn_csr;

        IF l_debug_on THEN
           wsh_debug_sv.log (l_module_name, 'l_sa_exist',l_sa_exist);
        END IF;

        IF l_sa_exist = 'X' THEN
           IF l_debug_on THEN
            wsh_debug_sv.pop (l_module_name,'RETURN-FALSE');
           END IF;
	   RETURN FALSE;
        ELSE
           IF l_debug_on THEN
            wsh_debug_sv.pop (l_module_name,'RETURN-TRUE');
           END IF;
	   RETURN TRUE;
        END IF;

     ELSE
        IF l_debug_on THEN
         wsh_debug_sv.pop (l_module_name,'RETURN-FALSE');
        END IF;
	RETURN FALSE;
     END IF;
  ELSE
       raise wsh_invalid_action_code;
  END IF;
  x_return_status :=  wsh_util_core.g_ret_sts_success;

 IF l_debug_on THEN
  wsh_debug_sv.pop (l_module_name);
 END IF;
EXCEPTION
  WHEN wsh_del_not_found THEN
       x_return_status := wsh_util_core.g_ret_sts_error;
       FND_MESSAGE.Set_Name('WSH', 'WSH_DEL_NOT_FOUND');
       WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
       IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'wsh_del_not_found exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_del_not_found');
       END IF;
       RETURN FALSE;
  WHEN wsh_invalid_action_code THEN
       x_return_status := wsh_util_core.g_ret_sts_error;
       IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'wsh_invalid_action_code exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_invalid_action_code');
       END IF;
       RETURN FALSE;
  WHEN others THEN
       x_return_status := wsh_util_core.g_ret_sts_unexp_error;
       IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
       END IF;
       RETURN FALSE;
END Is_SendDoc_Allowed;

PROCEDURE Check_Updates_Allowed( p_changed_attributes IN WSH_INTERFACE.ChangedAttributeTabType,
				 p_source_code IN VARCHAR2,
				 x_update_allowed OUT NOCOPY  VARCHAR2,
				 x_return_status OUT NOCOPY  VARCHAR2)
IS

cursor	del_cur ( p_source_line_id IN NUMBER ) is
select	count(*)
from	wsh_new_deliveries wnd,
	wsh_delivery_assignments_v wda,
	wsh_delivery_details wdd
where	wnd.status_code in ('SR','SC')
--and	wnd.planned_flag = 'Y'
and	wda.delivery_id = wnd.delivery_id
and	wda.delivery_detail_id = wdd.delivery_detail_id
and	wdd.container_flag ='N'
and	wdd.source_line_id = p_source_line_id
and	wdd.source_code = p_source_code;

cursor	det_org_cur ( p_source_line_id IN NUMBER ) is
select	organization_id,
	delivery_detail_id
from	wsh_delivery_details
where	source_code= p_source_code
and	source_line_id = p_source_line_id
and 	rownum = 1;

l_counter NUMBER;
l_dCount NUMBER;
l_organization_id NUMBER;
l_delivery_detail_id NUMBER;
l_wh_type VARCHAR2(30);

l_del_rows wsh_util_core.id_tab_type;
l_status_code_tab wsh_util_core.id_tab_type;
l_planned_flag_tab wsh_util_core.id_tab_type;

l_char_temp VARCHAR2(1);
l_return_status VARCHAR2(1);
l_source_line_id NUMBER;

wsh_update_not_allowed EXCEPTION;
wsh_invalid_org EXCEPTION;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_UPDATES_ALLOWED';
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
  wsh_debug_sv.push(l_module_name, 'Check_Updates_Allowed');
  wsh_debug_sv.log (l_module_name, 'p_source_code',p_source_code);
 END IF;

  l_return_status := wsh_util_core.g_ret_sts_success;

  IF not WSH_DELIVERY_UTIL.G_INBOUND_FLAG  THEN

     FOR l_counter IN p_changed_attributes.FIRST ..p_changed_attributes.LAST LOOP

     IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name,'original_source_line_id:',p_changed_attributes(l_counter).original_source_line_id);
      wsh_debug_sv.log (l_module_name, 'source_line_id: ',p_changed_attributes(l_counter).source_line_id);
      wsh_debug_sv.log (l_module_name, 'action_flag',p_changed_attributes(l_counter).action_flag);
     END IF;

         IF (p_changed_attributes(l_counter).action_flag <> 'I' ) THEN
            --bug 2320115 fixed
            IF (p_changed_attributes(l_counter).action_flag = 'S' ) THEN
             l_source_line_id := nvl(p_changed_attributes(l_counter).original_source_line_id,p_changed_attributes(l_counter).source_line_id);
            ELSE
             l_source_line_id := p_changed_attributes(l_counter).source_line_id;
            END IF;

            open det_org_cur( l_source_line_id);
            --bug 2320115 fixed

            Fetch det_org_cur into l_organization_id, l_delivery_detail_id;

	    IF ( det_org_cur%FOUND ) THEN
               close det_org_cur;
               l_wh_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type(p_organization_id	=> l_organization_id,
								         x_return_status	=> l_return_status,
								         p_delivery_detail_id	=> l_delivery_detail_id);

               IF l_debug_on THEN
                wsh_debug_sv.log(l_module_name,'l_wh_type,l_return_status',l_wh_type||','||l_return_status);
               END IF;

               IF ( l_return_status <> wsh_util_core.g_ret_sts_success ) THEN
	          raise wsh_invalid_org;
               END IF;
               -- if the warehouse is either a Third Party Warehouse or a Carrier Manifesting System.
               IF ( nvl(l_wh_type, FND_API.G_MISS_CHAR) IN ( 'TPW', 'CMS' )) THEN
	         open del_cur(l_source_line_id);
	         FETCH del_cur into l_dCount;
	         close del_cur;
	         IF l_dCount > 0 THEN
	            raise wsh_update_not_allowed;
	         END IF;
               END IF;
	    END IF;
	    IF det_org_cur%ISOPEN THEN
               close det_org_cur;
	    END IF;
         END IF;
     END LOOP;
  END IF;
  IF l_return_status = wsh_util_core.g_ret_sts_success THEN
     x_update_allowed := 'Y';
  END IF;
  x_return_status := l_return_status;
 IF l_debug_on THEN
  wsh_debug_sv.pop (l_module_name);
 END IF;
EXCEPTION
	WHEN wsh_update_not_allowed THEN
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	   FND_MESSAGE.SET_NAME('WSH', 'WSH_UPDATE_NOT_ALLOWED');
	   WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
	   x_update_allowed := 'N';
          IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'wsh_update_not_allowed exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_update_not_allowed');
          END IF;
	WHEN wsh_invalid_org THEN
	   x_return_status := l_return_status;
	   x_update_allowed := 'N';
          IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'wsh_invalid_org exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_invalid_org');
          END IF;
	WHEN OTHERS THEN
	   x_return_status  := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	   x_update_allowed := 'N';
	   WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_DELIVERY_UTIL.Check_Updates_Allowed',l_module_name);
           IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
           END IF;
END Check_Updates_Allowed;

PROCEDURE Check_Actions_Allowed(x_entity_ids IN OUT NOCOPY  WSH_UTIL_CORE.Id_Tab_Type,
				p_entity_name IN VARCHAR2,
				p_action IN VARCHAR2,
				p_delivery_id IN NUMBER,
				x_err_entity_ids OUT NOCOPY  WSH_UTIL_CORE.Id_Tab_Type,
				x_return_status	OUT NOCOPY    VARCHAR2
				)
IS

-- Cursors get the delivery status based on the entity_ids

cursor  trip_to_del_cur(p_trip_id IN NUMBER) is
select  wnd.organization_id,
        wnd.status_code,
        wnd.planned_flag,
	wnd.delivery_id
from    wsh_new_deliveries wnd,
        wsh_delivery_legs wdl,
        wsh_trip_stops wts1,
        wsh_trip_stops wts2,
        wsh_trips wt
where   wnd.delivery_id = wdl.delivery_id
and     wts1.stop_id = wdl.PICK_UP_STOP_ID
and     wts2.stop_id = wdl.DROP_OFF_STOP_ID
and     wts1.trip_id = wt.trip_id
and     wts2.trip_id = wt.trip_id
and     wt.trip_id   = p_trip_id
and     rownum = 1;

cursor  stop_to_del_cur( p_stop_id IN NUMBER ) is
select  wnd.organization_id,
        wnd.status_code,
        wnd.planned_flag,
	wnd.delivery_id
from    wsh_new_deliveries wnd,
        wsh_delivery_legs wdl
where   wnd.delivery_id = wdl.delivery_id
and     wdl.pick_up_stop_id = p_stop_id
and     rownum = 1;


cursor	det_to_del_cur( p_del_det_id IN NUMBER ) is
select	wnd.organization_id,
	wnd.status_code,
	wnd.planned_flag,
	wnd.delivery_id
from    wsh_new_deliveries wnd,
	wsh_delivery_assignments_v wda
where 	wnd.delivery_id = wda.delivery_id
and	wda.delivery_detail_id = p_del_det_id;

cursor	del_cur( p_delivery_id IN NUMBER ) is
select	organization_id,
	status_code,
	planned_flag
from	wsh_new_deliveries
where	delivery_id=p_delivery_id;


-- Cursor to get the org_id for delivery_detail_id
-- Cursor to check if the Instance is a Third Party Warehouse Instance
cursor	det_cur(p_del_det_id IN NUMBER ) is
select	organization_id,
	source_code,
	container_flag
from	wsh_delivery_details
where	delivery_detail_id = p_del_det_id;


cursor	del_to_det_cur( p_delivery_id IN NUMBER ) is
select	distinct 'X'
from	wsh_delivery_details wdd,
	wsh_delivery_assignments_v wda
where	wda.delivery_id = p_delivery_id
and	wdd.delivery_detail_id = wda.delivery_detail_id
and	wdd.source_code = 'WSH'
and	wdd.container_flag = 'N';

--performance fix - no need to join to wnd
cursor	stop_to_det_cur( p_stop_id IN NUMBER ) is
select	'X'
from	wsh_delivery_details wdd,
	wsh_delivery_assignments_v wda,
	wsh_delivery_legs wdl
where	wdl.pick_up_stop_id = p_stop_id
and     wda.delivery_id is not null
and	wda.delivery_id = wdl.delivery_id
and	wdd.delivery_detail_id = wda.delivery_detail_id
and	wdd.source_code = 'WSH'
and	wdd.container_flag = 'N'
and     rownum=1;

cursor	trip_to_det_cur( p_trip_id IN NUMBER ) is
select	distinct 'X'
from	wsh_delivery_details wdd,
	wsh_new_deliveries wnd,
	wsh_delivery_assignments_v wda,
	wsh_delivery_legs wdl,
	wsh_trip_stops wts1,
	wsh_trip_stops wts2,
	wsh_trips wt
where	wt.trip_id   = p_trip_id
and	wts1.trip_id = wt.trip_id
and     wts2.trip_id = wt.trip_id
and 	wts1.stop_id = wdl.pick_up_stop_id
and     wts2.stop_id = wdl.drop_off_stop_id
and	wnd.delivery_id = wdl.delivery_id
and	wda.delivery_id = wnd.delivery_id
and	wdd.delivery_detail_id = wda.delivery_detail_id
and	wdd.source_code = 'WSH'
and	wdd.container_flag = 'N';

cursor	det_stat_cur( p_delivery_id IN NUMBER) is
select	distinct 'X'
from	wsh_delivery_details wdd,
	wsh_delivery_assignments_v wda
where	wdd.source_code = 'WSH'
and	wdd.container_flag = 'N'
and	wdd.delivery_detail_id = wda.delivery_detail_id
and	wda.delivery_id = p_delivery_id;

cursor	valid_shpmnt_advice_cur(p_delivery_id IN NUMBER,
				p_tp_id IN NUMBER
                       	      ) is
select	'X'
from	wsh_transactions_history
where	transaction_id = (
                        select	max(transaction_id)
                        from	wsh_transactions_history wth,
				wsh_new_deliveries wnd
                        where	wth.entity_number = wnd.name
                        and	wth.trading_partner_id = p_tp_id
			and 	wnd.delivery_id	= p_delivery_id
                        )
and	document_direction='I'
and	action_type = 'A';


l_entity_ids WSH_UTIL_CORE.Id_Tab_Type;
l_err_entity_ids WSH_UTIL_CORE.Id_Tab_Type;

l_organization_id NUMBER;
l_delivery_id NUMBER;
l_delivery_detail_id NUMBER;
l_planned_flag VARCHAR2(1);
l_status_code VARCHAR2(2);
l_source_code VARCHAR2(30);
l_cnt_flag VARCHAR2(2);
l_counter NUMBER;
l_wh_type VARCHAR2(30);

l_tpw_temp VARCHAR2(1);
l_atd_tpw_temp VARCHAR2(1);
l_valid_shpt_advc_tmp VARCHAR2(1);
l_return_status VARCHAR2(1);

wsh_delivery_locked EXCEPTION;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_ACTIONS_ALLOWED';
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
  wsh_debug_sv.push(l_module_name, 'Check_Actions_Allowed');
  wsh_debug_sv.log (l_module_name, 'Entity Name',p_entity_name);
  wsh_debug_sv.log (l_module_name, 'Action Code',p_action);
 END IF;

  IF ( p_action = 'ASSIGN_TO_DELIVERY') THEN
     open det_stat_cur(p_delivery_id);
     Fetch det_stat_cur into l_atd_tpw_temp;
     close det_stat_cur;
     IF l_atd_tpw_temp is not null THEN
	raise wsh_delivery_locked;
     ELSE
	open del_cur(p_delivery_id);
	Fetch del_cur into l_organization_id, l_status_code, l_planned_flag;
	close del_cur;
        IF l_debug_on THEN
         wsh_debug_sv.log (l_module_name, 'Organization_id',l_organization_id);
         wsh_debug_sv.log (l_module_name, 'Status Code',l_status_code);
        END IF;

	IF ( l_status_code IN ('SR','SC') and l_planned_flag IN ('Y','F') ) THEN
	   raise wsh_delivery_locked;
	ELSE
	   l_entity_ids := x_entity_ids;
	END IF;
     END IF;
  ELSIF (p_entity_name='DLVB' and p_action IN ('FREIGHT_COSTS','CREATE_CONTAINERS', 'CALC_WT_VOL',
	 'RATE_WITH_UPS', 'UPS_TIME_IN_TRANSIT','UPS_ADDRESS_VALIDATION', 'UPS_TRACKING')) THEN
     l_entity_ids := x_entity_ids;
  ELSIF (p_entity_name='DLVY' and p_action IN ('FREIGHT_COSTS', 'CALC_WT_VOL', 'RATE_WITH_UPS',
	 'UPS_TIME_IN_TRANSIT','UPS_ADDRESS_VALIDATION', 'UPS_TRACKING', 'UNASSIGN_FROM_TRIP',
	 'PRINT_DOC_SET','CLOSE') ) THEN
     l_entity_ids := x_entity_ids;
  ELSIF (p_entity_name='STOP' and p_action IN ('FREIGHT_COSTS','CALC_WT_VOL','PRINT_DOC_SET',
	 'UPDATE_STATUS')) THEN
     l_entity_ids := x_entity_ids;
  ELSIF (p_entity_name='TRIP' and p_action IN ('PLAN', 'UNPLAN', 'FREIGHT_COSTS','CALC_WT_VOL',
	 'PRINT_DOC_SET')) THEN
     l_entity_ids := x_entity_ids;
  ELSE
     FOR l_counter IN x_entity_ids.FIRST..x_entity_ids.LAST LOOP
        IF ( p_entity_name = 'TRIP') THEN
   	   IF ( p_action = 'LAUNCH_PICK_RELEASE') THEN

              open trip_to_del_cur(x_entity_ids(l_counter));
              fetch trip_to_del_cur into l_organization_id, l_status_code, l_planned_flag,l_delivery_id;
              close trip_to_del_cur;

             IF l_debug_on THEN
              wsh_debug_sv.log (l_module_name, 'Organization Id',l_organization_id);
              wsh_debug_sv.log (l_module_name, 'Status Code',l_status_code);
              wsh_debug_sv.log (l_module_name, 'Planned Flag',l_planned_flag);
              wsh_debug_sv.log (l_module_name, 'Delivery Id',l_delivery_id);
             END IF;

	      IF ( l_status_code IN ('SR', 'SC') AND l_planned_flag IN ('Y', 'F') ) THEN
	         l_err_entity_ids(l_err_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
	      ELSE
	         l_wh_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type(p_organization_id => l_organization_id,
                                                                           x_return_status   => l_return_status,
									   p_delivery_id     => l_delivery_id,
                                                                           p_msg_display     => 'N');
                 IF l_debug_on THEN
                  wsh_debug_sv.log (l_module_name, 'l_wh_type,l_return_status',l_wh_type||','||l_return_status);
                 END IF;

	         IF ( nvl(l_wh_type, FND_API.G_MISS_CHAR) = 'TPW' ) THEN
	            open trip_to_det_cur(x_entity_ids(l_counter));
	            Fetch trip_to_det_cur into l_tpw_temp;
	            close trip_to_det_cur;
	            IF ( l_tpw_temp is null ) THEN
	               l_err_entity_ids(l_err_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
	            ELSE
	               l_entity_ids(l_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
	            END IF;
	         ELSE
	            l_entity_ids(l_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
	         END IF;
	      END IF;
           ELSE
	      l_entity_ids(l_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
	   END IF;

        ELSIF ( p_entity_name = 'STOP' ) THEN

	   IF ( p_action ='LAUNCH_PICK_RELEASE') THEN

              open stop_to_del_cur(x_entity_ids(l_counter));
              fetch stop_to_del_cur into l_organization_id, l_status_code, l_planned_flag, l_delivery_id;
              close stop_to_del_cur;

             IF l_debug_on THEN
              wsh_debug_sv.log (l_module_name, 'Organization Id',l_organization_id);
              wsh_debug_sv.log (l_module_name, 'Status Code',l_status_code);
              wsh_debug_sv.log (l_module_name, 'Planned Flag',l_planned_flag);
              wsh_debug_sv.log (l_module_name, 'Delivery Id',l_delivery_id);
             END IF;

	      IF ( l_status_code IN ('SR', 'SC') AND l_planned_flag IN ('Y', 'F') ) THEN
	         l_err_entity_ids(l_err_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
	      ELSE
	         l_wh_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type(p_organization_id => l_organization_id,
                                                                           x_return_status   => l_return_status,
									   p_delivery_id     => l_delivery_id,
                                                                           p_msg_display     => 'N');

                 IF l_debug_on THEN
                  wsh_debug_sv.log (l_module_name, 'l_wh_type,l_return_status',l_wh_type||','||l_return_status);
                 END IF;

	         IF ( nvl(l_wh_type, FND_API.G_MISS_CHAR) = 'TPW' ) THEN
	            open stop_to_det_cur(x_entity_ids(l_counter));
	            Fetch stop_to_det_cur into l_tpw_temp;
	            close stop_to_det_cur;
	            IF ( l_tpw_temp is null ) THEN
	               l_err_entity_ids(l_err_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
	            ELSE
	               l_entity_ids(l_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
	            END IF;
	         ELSE
	            l_entity_ids(l_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
	         END IF;
	      END IF;
           ELSIF ( p_action IN ('PLAN', 'UNPLAN' )) THEN
	      open stop_to_det_cur(x_entity_ids(l_counter));
	      Fetch stop_to_det_cur into l_tpw_temp;
	      close stop_to_det_cur;
	      IF ( l_tpw_temp is not null ) THEN
	         l_entity_ids(l_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
	      ELSE
	         open stop_to_del_cur(x_entity_ids(l_counter));
	         fetch stop_to_del_cur into l_organization_id, l_status_code, l_planned_flag, l_delivery_id;
                 close stop_to_del_cur;

                IF l_debug_on THEN
                 wsh_debug_sv.log (l_module_name, 'Organization Id',l_organization_id);
                 wsh_debug_sv.log (l_module_name, 'Status Code',l_status_code);
                 wsh_debug_sv.log (l_module_name, 'Planned Flag',l_planned_flag);
                 wsh_debug_sv.log (l_module_name, 'Delivery Id',l_delivery_id);
                END IF;

	         IF ( l_status_code IN ('SR', 'SC') AND l_planned_flag IN ('Y','F') ) THEN
	            l_err_entity_ids(l_err_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
	         ELSE
	            l_wh_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type(p_organization_id => l_organization_id,
                                                                              x_return_status   => l_return_status,
									      p_delivery_id     => l_delivery_id);
                    IF l_debug_on THEN
                     wsh_debug_sv.log (l_module_name, 'l_wh_type,l_return_status',l_wh_type||','||l_return_status);
                    END IF;

		    IF ( nvl(l_wh_type, FND_API.G_MISS_CHAR) IN ('TPW','CMS') ) THEN
		       l_err_entity_ids(l_err_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
		    ELSE
		       l_entity_ids(l_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
		    END IF;
	         END IF;
	      END IF;
 	   ELSE
	      l_entity_ids(l_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
	   END IF;


        ELSIF ( p_entity_name = 'DLVY' ) THEN

	   open del_cur(x_entity_ids(l_counter));
	   Fetch del_cur into l_organization_id, l_status_code, l_planned_flag;
	   close del_cur;

          IF l_debug_on THEN
           wsh_debug_sv.log (l_module_name, 'Organization Id',l_organization_id);
           wsh_debug_sv.log (l_module_name, 'Status Code',l_status_code);
           wsh_debug_sv.log (l_module_name, 'Planned Flag',l_planned_flag);
          END IF;

	   IF ( p_action IN ('LAUNCH_PICK_RELEASE','AUTO_PACK','AUTO_PACK_MASTER','PACK') ) THEN

	      IF ( l_status_code IN ('SR', 'SC') AND l_planned_flag IN ('Y','F') ) THEN
	         l_err_entity_ids(l_err_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
	      ELSE
	         l_wh_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type(p_organization_id => l_organization_id,
                                                                           x_return_status   => l_return_status,
									   p_delivery_id     => x_entity_ids(l_counter),
                                                                           p_msg_display     => 'N');
                    IF l_debug_on THEN
                     wsh_debug_sv.log (l_module_name, 'l_wh_type,l_return_status',l_wh_type||','||l_return_status);
                    END IF;
	         IF ( nvl(l_wh_type, FND_API.G_MISS_CHAR) = 'TPW' ) THEN
	            open del_to_det_cur(x_entity_ids(l_counter));
	            Fetch del_to_det_cur into l_tpw_temp;
	            close del_to_det_cur;
	            IF ( l_tpw_temp is null ) THEN
	               l_err_entity_ids(l_err_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
	            ELSE
	               l_entity_ids(l_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
	            END IF;
	         ELSE
	            l_entity_ids(l_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
	         END IF;
	      END IF;
	   ELSIF ( p_action IN ('PLAN','UNPLAN') ) THEN
	      IF ( l_status_code IN ('SR', 'SC') AND l_planned_flag IN ('Y','F') ) THEN
	         l_err_entity_ids(l_err_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
	      ELSE
	         l_entity_ids(l_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
	      END IF;
	   ELSIF ( p_action ='GEN_LOAD_SEQ' ) THEN
	      IF ( l_status_code IN ('SR', 'SC') AND l_planned_flag IN ('Y','F') ) THEN
	         l_wh_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type(p_organization_id => l_organization_id,
                                                                           x_return_status   => l_return_status,
									   p_delivery_id     => x_entity_ids(l_counter),
                                                                           p_msg_display     => 'N');
                    IF l_debug_on THEN
                     wsh_debug_sv.log (l_module_name, 'l_wh_type,l_return_status',l_wh_type||','||l_return_status);
                    END IF;
	         IF ( nvl(l_wh_type, FND_API.G_MISS_CHAR) = 'TPW' ) THEN
		    l_err_entity_ids(l_err_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
	         ELSE
		    l_entity_ids(l_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
	         END IF;
	      ELSE
	         l_entity_ids(l_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
	      END IF;
	   ELSIF ( p_action = 'REOPEN' ) THEN
	      IF ( l_status_code = 'CO' ) THEN
	         open del_to_det_cur(x_entity_ids(l_counter));
	         Fetch del_to_det_cur into l_tpw_temp;
	         close del_to_det_cur;
	         IF ( l_tpw_temp is null ) THEN
	            l_wh_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type(p_organization_id => l_organization_id,
                                                                              x_return_status   => l_return_status,
									      p_delivery_id     => x_entity_ids(l_counter),
                                                                              p_msg_display     => 'N');
                    IF l_debug_on THEN
                     wsh_debug_sv.log (l_module_name, 'l_wh_type,l_return_status',l_wh_type||','||l_return_status);
                    END IF;
                    IF ( nvl(l_wh_type, FND_API.G_MISS_CHAR) = 'CMS' ) THEN
                       l_err_entity_ids(l_err_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
                    ELSE
                       l_entity_ids(l_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
                    END IF;
	            l_entity_ids(l_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
	         ELSE
                    l_err_entity_ids(l_err_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
	         END IF;
	      ELSE
	         l_wh_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type(p_organization_id => l_organization_id,
                                                                           x_return_status   => l_return_status,
									   p_delivery_id     => x_entity_ids(l_counter),
                                                                           p_msg_display     => 'N');
                    IF l_debug_on THEN
                     wsh_debug_sv.log (l_module_name, 'l_wh_type,l_return_status',l_wh_type||','||l_return_status);
                    END IF;
                 IF ( nvl(l_wh_type, FND_API.G_MISS_CHAR) = 'CMS' ) THEN
                    l_err_entity_ids(l_err_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
                 ELSE
                    l_entity_ids(l_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
                 END IF;
	      END IF;
	   ELSIF ( p_action ='SHIP_CONFIRM' ) THEN
	      IF ( l_status_code IN ( 'SR', 'SC' )) THEN
                 l_err_entity_ids(l_err_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
              ELSE
	         l_wh_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type(p_organization_id => l_organization_id,
                                                                           x_return_status   => l_return_status,
									   p_delivery_id     => x_entity_ids(l_counter),
                                                                           p_msg_display     => 'N');
                    IF l_debug_on THEN
                     wsh_debug_sv.log (l_module_name, 'l_wh_type,l_return_status',l_wh_type||','||l_return_status);
                    END IF;
	         IF ( nvl(l_wh_type, FND_API.G_MISS_CHAR) = 'CMS' ) THEN
		    open del_to_det_cur(x_entity_ids(l_counter));
	            Fetch del_to_det_cur into l_tpw_temp;
	            close del_to_det_cur;
	            IF ( l_tpw_temp IS NULL ) THEN
		       IF ( l_status_code = 'OP' ) THEN
			   open valid_shpmnt_advice_cur(x_entity_ids(l_counter), l_organization_id);
			   fetch valid_shpmnt_advice_cur into l_valid_shpt_advc_tmp;
			   close valid_shpmnt_advice_cur;
			   IF ( l_valid_shpt_advc_tmp IS NOT NULL ) THEN
			      l_entity_ids(l_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
			   ELSE
			      l_err_entity_ids(l_err_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
			   END IF;
		       ELSE
			   l_entity_ids(l_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
		       END IF;
	            ELSE
		       l_entity_ids(l_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
	            END IF;
		 ELSE
		    l_entity_ids(l_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
		 END IF;
	      END IF;
	   ELSIF ( p_action IN ('OUTBOUND_DOCUMENT','TRANSACTION_HISTORY') ) THEN
	      l_wh_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type(p_organization_id => l_organization_id,
                                                                        x_return_status   => l_return_status,
									p_delivery_id     => x_entity_ids(l_counter));
                    IF l_debug_on THEN
                     wsh_debug_sv.log (l_module_name, 'l_wh_type,l_return_status',l_wh_type||','||l_return_status);
                    END IF;
	      IF ( nvl(l_wh_type, FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR ) THEN
		 open det_stat_cur(x_entity_ids(l_counter));
		 fetch det_stat_cur into l_atd_tpw_temp;
		 close det_stat_cur;
		 IF ( l_atd_tpw_temp IS NULL ) THEN
		    l_err_entity_ids(l_err_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
		 ELSE
		    l_entity_ids(l_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
		 END IF;
              ELSIF ( nvl(l_wh_type, FND_API.G_MISS_CHAR) IN ('CMS','TPW') ) THEN
		 IF ( l_status_code = 'OP' ) THEN
		    open valid_shpmnt_advice_cur(x_entity_ids(l_counter), l_organization_id);
		    fetch valid_shpmnt_advice_cur into l_valid_shpt_advc_tmp;
		    close valid_shpmnt_advice_cur;
		    IF ( l_valid_shpt_advc_tmp IS NULL ) THEN
		       l_entity_ids(l_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
		    ELSE
		       l_err_entity_ids(l_err_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
		    END IF;
		 ELSE
		    l_entity_ids(l_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
		 END IF;
              ELSE
                 l_err_entity_ids(l_err_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
	      END IF;
	   ELSIF ( p_action IN ('AUTO_CREATE_TRIP','ASSIGN_TO_TRIP')) THEN
	      IF ( l_status_code = 'SA' ) THEN
		 l_entity_ids(l_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
	      ELSE
	         l_wh_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type(p_organization_id => l_organization_id,
                                                                           x_return_status   => l_return_status,
									   p_delivery_id     => x_entity_ids(l_counter),
                                                                           p_msg_display     => 'N');

                    IF l_debug_on THEN
                     wsh_debug_sv.log (l_module_name, 'l_wh_type,l_return_status',l_wh_type||','||l_return_status);
                    END IF;
                 IF ( nvl(l_wh_type, FND_API.G_MISS_CHAR) in ( 'CMS','TPW') ) THEN
	            open del_to_det_cur(x_entity_ids(l_counter));
	            fetch del_to_det_cur into l_tpw_temp;
	            close del_to_det_cur;
	            IF ( l_tpw_temp IS NULL ) THEN
                       l_err_entity_ids(l_err_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
	            ELSE
		       l_entity_ids(l_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
	            END IF;
                 ELSE
                    l_entity_ids(l_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
	         END IF;
	      END IF;
	   ELSIF ( p_action IN ('GENERATE_BOL','GENERATE_PS')) THEN
     		 open det_stat_cur(x_entity_ids(l_counter));
     		 Fetch det_stat_cur into l_atd_tpw_temp;
     		 close det_stat_cur;
     		 IF ( l_atd_tpw_temp is not null ) THEN
	            l_entity_ids(l_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
		    --raise wsh_delivery_locked;
     		 ELSE
		    open del_cur(p_delivery_id);
		    Fetch del_cur into l_organization_id, l_status_code, l_planned_flag;
		    close del_cur;
                   IF l_debug_on THEN
        	    wsh_debug_sv.log (l_module_name, 'Organization_id',l_organization_id);
        	    wsh_debug_sv.log (l_module_name, 'Status Code',l_status_code);
                   END IF;
		    IF ( l_status_code IN ('SR', 'SC') AND l_planned_flag IN ('Y','F') ) THEN
		       raise wsh_delivery_locked;
		    ELSE
		       l_wh_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type(p_organization_id  => l_organization_id,
                                                                	         x_return_status         => l_return_status,
									         p_delivery_id		=> x_entity_ids(l_counter),
                                                                                 p_msg_display     => 'N');
                    IF l_debug_on THEN
                     wsh_debug_sv.log (l_module_name, 'l_wh_type,l_return_status',l_wh_type||','||l_return_status);
                    END IF;
	   	       IF ( nvl(l_wh_type, FND_API.G_MISS_CHAR) IN ('TPW','CMS') ) THEN
	      		   raise wsh_delivery_locked;
	   	       ELSE
	      		   l_entity_ids := x_entity_ids;
	   	       END IF;
		    END IF;
     		 END IF;
	   ELSE
	      l_entity_ids(l_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
	   END IF;

        ELSIF ( p_entity_name = 'DLVB' ) THEN

           open det_to_del_cur(x_entity_ids(l_counter));
           Fetch det_to_del_cur into l_organization_id, l_status_code, l_planned_flag, l_delivery_id;

          IF l_debug_on THEN
           wsh_debug_sv.log (l_module_name, 'Organization Id',l_organization_id);
           wsh_debug_sv.log (l_module_name, 'Status Code',l_status_code);
           wsh_debug_sv.log (l_module_name, 'Planned Flag',l_planned_flag);
           wsh_debug_sv.log (l_module_name, 'Delivery Id',l_delivery_id);
          END IF;

	   IF ( p_action IN ('CYCLE_COUNT','LAUNCH_PICK_RELEASE','AUTO_PACK','AUTO_PACK_MASTER',
			     'PACK','UNPACK','PACKING_WORKBENCH') ) THEN
              IF ( det_to_del_cur%NOTFOUND ) THEN
                 close det_to_del_cur;
		 open det_cur(x_entity_ids(l_counter));
		 Fetch det_cur into l_organization_id, l_source_code, l_cnt_flag;
		 close det_cur;
	         l_wh_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type(p_organization_id => l_organization_id,
                                                                           x_return_status   => l_return_status,
									   p_delivery_id     => l_delivery_id,
									   p_delivery_detail_id => x_entity_ids(l_counter),
                                                                           p_msg_display     => 'N');
                    IF l_debug_on THEN
                     wsh_debug_sv.log (l_module_name, 'l_wh_type,l_return_status',l_wh_type||','||l_return_status);
                    END IF;
	      	 IF ( nvl(l_wh_type, FND_API.G_MISS_CHAR) = 'TPW' ) THEN
	            IF ( l_source_code = 'WSH' and l_cnt_flag = 'N' ) THEN
	               l_entity_ids(l_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
	            ELSE
	               l_err_entity_ids(l_err_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
	            END IF;
	         ELSE
	            l_entity_ids(l_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
	         END IF;
              ELSE
		 IF ( l_status_code IN ('SR', 'SC') AND l_planned_flag IN ('Y','F') ) THEN
		    l_err_entity_ids(l_err_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
		 ELSE
	            l_wh_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type(p_organization_id => l_organization_id,
                                                                              x_return_status   => l_return_status,
									      p_delivery_id     => l_delivery_id,
                                                                              p_delivery_detail_id => x_entity_ids(l_counter),
                                                                              p_msg_display     => 'N');
                    IF l_debug_on THEN
                     wsh_debug_sv.log (l_module_name, 'l_wh_type,l_return_status',l_wh_type||','||l_return_status);
                    END IF;
                    IF ( nvl(l_wh_type, FND_API.G_MISS_CHAR) = 'TPW' ) THEN
                       open det_cur(x_entity_ids(l_counter));
		       Fetch det_cur into l_organization_id, l_source_code, l_cnt_flag;
		       close det_cur;
	               IF ( l_source_code = 'WSH' and l_cnt_flag = 'N' ) THEN
                          l_entity_ids(l_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
                       ELSE
                          l_err_entity_ids(l_err_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
                       END IF;
                    ELSE
                       l_entity_ids(l_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
                    END IF;
                 END IF;
              END IF;

	   ELSIF ( p_action = 'SPLIT_LINE') THEN
              IF ( det_to_del_cur%NOTFOUND ) THEN
                 close det_to_del_cur;
	         l_entity_ids(l_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
	      ELSIF ( nvl(l_status_code, FND_API.G_MISS_CHAR) IN ('SR', 'SC') AND nvl(l_planned_flag,FND_API.G_MISS_CHAR) IN ('Y','F') ) THEN
	         l_err_entity_ids(l_err_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
	      ELSE
	         l_entity_ids(l_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
	      END IF;
	   ELSIF ( p_action = 'UNASSIGN_FROM_DELIVERY') THEN
              IF ( det_to_del_cur%NOTFOUND ) THEN
                 close det_to_del_cur;
	         l_entity_ids(l_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
	      ELSIF ( nvl(l_status_code, FND_API.G_MISS_CHAR) IN ('SR', 'SC', 'SA') AND nvl(l_planned_flag,FND_API.G_MISS_CHAR) IN ('Y','F') ) THEN
	         l_err_entity_ids(l_err_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
	      ELSE
		 open det_cur(x_entity_ids(l_counter));
		 Fetch det_cur into l_organization_id, l_source_code, l_cnt_flag;
		 close det_cur;
	         IF ( l_source_code = 'WSH' and l_cnt_flag = 'N' ) THEN
	            l_err_entity_ids(l_err_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
	         ELSE
	            l_entity_ids(l_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
	         END IF;
	      END IF;
	   ELSIF ( p_action = 'AUTO_CREATE_TRIP') THEN
              IF ( det_to_del_cur%NOTFOUND ) THEN
                 close det_to_del_cur;
		 open det_cur(x_entity_ids(l_counter));
		 Fetch det_cur into l_organization_id, l_source_code, l_cnt_flag;
		 close det_cur;
	         l_wh_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type(p_organization_id => l_organization_id,
                                                                           x_return_status   => l_return_status,
									   p_delivery_id     => l_delivery_id,
                                                                           p_delivery_detail_id => x_entity_ids(l_counter),
                                                                           p_msg_display     => 'N');
                    IF l_debug_on THEN
                     wsh_debug_sv.log (l_module_name, 'l_wh_type,l_return_status',l_wh_type||','||l_return_status);
                    END IF;
		 IF ( nvl(l_wh_type, FND_API.G_MISS_CHAR) in ('CMS','TPW')) THEN
                    open det_cur(x_entity_ids(l_counter));
		    Fetch det_cur into l_organization_id, l_source_code, l_cnt_flag;
		    close det_cur;
	            IF ( l_source_code = 'WSH' and l_cnt_flag = 'N' ) THEN
                       l_entity_ids(l_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
                    ELSE
                       l_err_entity_ids(l_err_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
                    END IF;
		 ELSE
                    l_entity_ids(l_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
		 END IF;
	      ELSE
		 l_err_entity_ids(l_err_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
	      END IF;
	   ELSE
	      l_entity_ids(l_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
	   END IF;
	   IF ( det_to_del_cur%ISOPEN ) THEN
              close det_to_del_cur;
	   END IF;
        ELSE
	   l_entity_ids(l_entity_ids.COUNT + 1) := x_entity_ids(l_counter);
        END IF;

     END LOOP;
  END IF;

  IF ( l_entity_ids.COUNT = x_entity_ids.COUNT ) THEN
      l_return_status := wsh_util_core.g_ret_sts_success;
  ELSIF ( l_entity_ids.COUNT = 0 ) THEN
      raise wsh_delivery_locked;
  ELSIF ( l_entity_ids.COUNT < x_entity_ids.COUNT ) THEN
      x_entity_ids := l_entity_ids;
      x_err_entity_ids := l_err_entity_ids;
      l_return_status := wsh_util_core.g_ret_sts_warning;
  END IF;
  x_return_status := l_return_status;
 IF l_debug_on THEN
  wsh_debug_sv.pop (l_module_name);
 END IF;
EXCEPTION
        WHEN wsh_delivery_locked THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'wsh_delivery_locked exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_delivery_locked');
           END IF;
        WHEN others THEN
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
           END IF;
END Check_Actions_Allowed;

END WSH_DELIVERY_UTIL;

/
