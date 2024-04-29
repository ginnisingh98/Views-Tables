--------------------------------------------------------
--  DDL for Package Body WSH_TRANSACTIONS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_TRANSACTIONS_UTIL" 
-- $Header: WSHXUTLB.pls 120.5.12010000.3 2009/12/03 16:10:26 mvudugul ship $
AS



--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_TRANSACTIONS_UTIL';
--
PROCEDURE Send_Document( p_entity_id IN NUMBER,
			 p_entity_type IN VARCHAR2,
			 p_action_type IN VARCHAR2,
			 p_document_type IN VARCHAR2,
			 p_organization_id IN NUMBER,
			 x_return_status OUT NOCOPY  VARCHAR2)

IS

wsh_invalid_doc_type EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SEND_DOCUMENT';
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
  WSH_DEBUG_SV.start_debug (p_entity_id);
  IF l_debug_on THEN
   wsh_debug_sv.push(l_module_name, 'Send_Document');
   wsh_debug_sv.log(l_module_name, 'p_entity_id',p_entity_id);
   wsh_debug_sv.log(l_module_name, 'p_entity_type',p_entity_type);
   wsh_debug_sv.log(l_module_name, 'p_action_type',p_action_type);
   wsh_debug_sv.log(l_module_name, 'p_document_type',p_document_type);
   wsh_debug_sv.log(l_module_name, 'p_organization_id',p_organization_id);
  END IF;

  IF ( p_document_type = 'SR' ) THEN


      Send_Shipment_Request ( p_entity_id,
                              p_entity_type,
                              p_action_type,
                              p_document_type,
                              p_organization_id,
                              x_return_status
			    );
  ELSIF ( p_document_type = 'SA' ) THEN
      WSH_TRANSACTIONS_TPW_UTIL.Send_Shipment_Advice( p_entity_id,
						      p_entity_type,
						      p_action_type,
						      p_document_type,
						      p_organization_id,
						      x_return_status
                             			    );
  ELSE
     raise wsh_invalid_doc_type;
  END IF;

  IF l_debug_on THEN
   wsh_debug_sv.pop (l_module_name);
  END IF;
  WSH_DEBUG_SV.stop_debug;

EXCEPTION

  WHEN	wsh_invalid_doc_type THEN
	x_return_status := wsh_util_core.g_ret_sts_error;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'wsh_invalid_doc_type exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_invalid_doc_type');
        END IF;
  WHEN	OTHERS THEN
	x_return_status := wsh_util_core.g_ret_sts_unexp_error;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
END Send_Document;

PROCEDURE Send_Shipment_Request ( p_entity_id IN NUMBER,
				  p_entity_type IN VARCHAR2,
				  p_action_type IN VARCHAR2,
				  p_document_type IN VARCHAR2,
				  p_organization_id IN NUMBER,
				  x_return_status OUT NOCOPY  VARCHAR2
				)
IS

l_wh_type VARCHAR2(30);
l_org_code VARCHAR2(3);
l_rel_stat_tmp VARCHAR2(1);
l_txn_id NUMBER;
l_entity_number VARCHAR2(30);
l_tmp NUMBER;
l_valid_del_tmp VARCHAR2(1);
l_packed_det_tmp VARCHAR2(1);
l_orig_txn_status VARCHAR2(2);
l_manifest_enabled_flag VARCHAR2(1);
x_valid_flag BOOLEAN;
l_assigned_to_trip VARCHAR2(1);
l_customer_id NUMBER;

l_txns_history_rec WSH_TRANSACTIONS_HISTORY_PKG.Txns_History_Record_Type;

cursor del_name_cur is
select name, customer_id from wsh_new_deliveries
where delivery_id = p_entity_id;

-- This cursor checks if the delivery contains all the delivery details associated their corresponding source_line_ids.
cursor valid_del_cur(p_delivery_id IN NUMBER) is
select distinct 'X'
from wsh_delivery_details wdd1,
wsh_delivery_assignments_v wda1,
wsh_delivery_details wdd2,
wsh_delivery_assignments_v wda2
where
wdd1.source_line_id = wdd2.source_line_id
and wdd1.delivery_detail_id = wda1.delivery_detail_id
and wdd1.container_flag='N'
and wda1.delivery_id = p_delivery_id
and wdd2.delivery_detail_id = wda2.delivery_detail_id
and wdd2.container_flag='N'
and (wda2.delivery_id <> p_delivery_id
     or wda2.delivery_id is null);

-- The cursors rel_status_tpw_cur, rel_status_cms_cur are used to ensure that the delivery details
-- associated to the correnponding delivery are eligible to be to sent out.
cursor rel_status_tpw_cur(p_delivery_id IN NUMBER) is
select distinct 'X'
from wsh_delivery_details wdd,
     wsh_delivery_assignments_v wda
where wdd.delivery_detail_id = wda.delivery_detail_id
and   wdd.container_flag = 'N'
and   wdd.released_status not in ('X', 'R', 'B')
and   wda.delivery_id =p_delivery_id;

cursor rel_status_cms_cur(p_delivery_id IN NUMBER) is
select distinct 'X'
from wsh_delivery_details wdd,
     wsh_delivery_assignments_v wda
where wdd.delivery_detail_id = wda.delivery_detail_id
and   wdd.container_flag = 'N'
and   wdd.released_status not in ('X','Y')
and   wda.delivery_id =p_delivery_id;

cursor orig_txn_hist_cur(p_entity_number IN VARCHAR2,
			p_tp_id IN NUMBER
                       ) is
select document_number,transaction_status
from wsh_transactions_history
where transaction_id = (
			select max(transaction_id)
			from wsh_transactions_history
			where entity_number = p_entity_number
			and trading_partner_id = p_tp_id
			and document_direction = 'O'
			--and transaction_status = 'ST'
			and action_type = 'A'
			);

cursor	det_pack_cms_cur(p_delivery_id IN NUMBER) is
select	distinct 'X'
from	wsh_delivery_details wdd,
	wsh_delivery_assignments_v wda
where	wda.delivery_id = p_delivery_id
and	wda.parent_delivery_detail_id is null
and	wda.delivery_detail_id = wdd.delivery_detail_id
and	wdd.container_flag='N';


--bug 2399697 and  2399687 fixed
cursor get_delivery_details(p_delivery_id IN NUMBER) is
select wdd.delivery_detail_id,
       wdd.source_header_id,
       wdd.source_line_id
from   wsh_delivery_details wdd,
       wsh_delivery_assignments_v wda
where  wda.delivery_id = p_delivery_id
and    wda.delivery_detail_id = wdd.delivery_detail_id
and    wdd.container_flag = 'N'
and    wda.delivery_id IS NOT NULL;


wsh_incorrect_org EXCEPTION;
wsh_invalid_delivery EXCEPTION;
wsh_tpw_del_det_rel_stat EXCEPTION;
wsh_cms_del_det_rel_stat EXCEPTION;
wsh_details_not_packed EXCEPTION;
wsh_insert_history_error EXCEPTION;
wsh_raise_event_error EXCEPTION;
wsh_delivery_locked EXCEPTION;
wsh_cancel_disallowed EXCEPTION;
wsh_del_assign_to_trip	EXCEPTION;

--bug 2399697 and 2399687 fixed
wsh_details_exceptions	EXCEPTION;
wsh_details_credit_hold	EXCEPTION;

-- 2444821
wsh_invalid_customer	EXCEPTION;
-- 2444821

--wsh_document_in_ip_er EXCEPTION;

x_exception_exist   Varchar2(1):='N';
x_severity_present  Varchar2(1):=NULL;
l_delivery_detail_id NUMBER;

l_warning_count NUMBER:=0;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SEND_SHIPMENT_REQUEST';
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
   wsh_debug_sv.log(l_module_name, 'p_entity_id',p_entity_id);
   wsh_debug_sv.log(l_module_name, 'p_entity_type',p_entity_type);
   wsh_debug_sv.log(l_module_name, 'p_action_type',p_action_type);
   wsh_debug_sv.log(l_module_name, 'p_document_type',p_document_type);
   wsh_debug_sv.log(l_module_name, 'p_organization_id',p_organization_id);
  END IF;


  l_wh_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type(p_organization_id	=> p_organization_id,
							    x_return_status	=> x_return_status,
							    p_delivery_id	=> p_entity_id);

  IF l_debug_on THEN
   wsh_debug_sv.log(l_module_name, 'l_wh_type,x_return_status',l_wh_type||','||x_return_status);
  END IF;

  IF ( l_wh_type IS NULL ) THEN
     select organization_code
     into  l_org_code
     from mtl_parameters
     where organization_id = p_organization_id;
     raise wsh_incorrect_org;
  END IF;

  IF l_debug_on THEN
   wsh_debug_sv.log(l_module_name, 'l_org_code',l_org_code);
  END IF;

  open del_name_cur;
  Fetch del_name_cur into l_entity_number, l_customer_id;
  close del_name_cur;

  IF l_debug_on THEN
   wsh_debug_sv.log(l_module_name, 'l_entity_number,l_customer_id',l_entity_number||','||l_customer_id);
  END IF;
  IF l_customer_id IS NULL  THEN
     raise wsh_invalid_customer;
  END IF;
  -- Initializing the Transactions_History Record.

  l_txns_history_rec.entity_number := l_entity_number;
  l_txns_history_rec.document_type := p_document_type;
  l_txns_history_rec.transaction_status := 'IP';
  l_txns_history_rec.entity_type := p_entity_type;
  l_txns_history_rec.action_type := p_action_type;
  l_txns_history_rec.trading_partner_id := p_organization_id;
  l_txns_history_rec.document_direction := 'O';
  l_txns_history_rec.item_type := 'WSHSUPI';

  select to_char(WSH_DOCUMENT_NUMBER_S.nextval) into l_txns_history_rec.document_number from dual;
  IF l_debug_on THEN
   wsh_debug_sv.log(l_module_name, 'DOCUMENT_NUMBER',l_txns_history_rec.document_number);
  END IF;

/* K proj
  IF ( l_wh_type = 'CMS' and p_action_type = 'D' ) THEN
     l_txns_history_rec.event_name := 'ORACLE.APPS.FTE.SSNO.CONFIRM';
  ELSE
*/
  l_txns_history_rec.event_name := 'oracle.apps.wsh.sup.ssro';
  --END IF;
  IF l_debug_on THEN
	wsh_debug_sv.log (l_module_name, 'Action Type ' , p_action_type);
	wsh_debug_sv.log (l_module_name, 'Delivery Id ' , p_entity_id);
	wsh_debug_sv.log (l_module_name, 'Document Type ' , p_document_type);
  END IF;
  IF ( p_action_type = 'A' ) THEN

     IF ( WSH_DELIVERY_UTIL.Is_SendDoc_Allowed(	p_entity_id,
				 		p_action_type,
					 	x_return_status)
	) THEN

       --bug 2399697 and 2399687 fixed
       IF  (p_entity_type = 'DLVY' ) THEN
         FOR detail_info IN get_delivery_details(p_entity_id) LOOP
           l_delivery_detail_id:= detail_info.delivery_detail_id;

           WSH_SHIP_CONFIRM_ACTIONS2.check_exception(
                        p_delivery_detail_id => detail_info.delivery_detail_id,
                        x_exception_exist => x_exception_exist,
                        x_severity_present => x_severity_present,
                        x_return_status => x_return_status);
            IF l_debug_on THEN
             wsh_debug_sv.log(l_module_name, 'check_exception x_exception_exist,x_severity_present,x_return_status',x_exception_exist||','||x_severity_present||','||x_return_status);
            END IF;

            IF (x_exception_exist = 'Y') THEN
                raise wsh_details_exceptions;
            END IF;

           wsh_details_validations.check_credit_holds(
               p_detail_id             => detail_info.delivery_detail_id,
               p_activity_type         => 'SHIP',
               p_source_line_id        => detail_info.source_line_id,
               p_source_header_id      => detail_info.source_header_id,
               p_source_code           => 'OE',
               p_init_flag             => 'Y',
               x_return_status         => x_return_status);
            IF l_debug_on THEN
             wsh_debug_sv.log(l_module_name, 'check_credit_holds x_return_status',x_return_status);
            END IF;

            IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                raise wsh_details_credit_hold;
            END IF;

         END LOOP;
       END IF;
       --bug 2399697 and 2399687 fixed

       /* heali
        -- bug fix 2312168
	open valid_del_cur(p_entity_id);
	Fetch valid_del_cur into l_valid_del_tmp;
	close valid_del_cur;

	IF ( nvl(l_valid_del_tmp,FND_API.G_MISS_CHAR) = 'X' ) THEN
	   raise wsh_invalid_delivery;
	END IF;
       */

        --heali bug 2399671
        IF  (p_entity_type = 'DLVY' ) THEN
               l_assigned_to_trip := WSH_Delivery_Validations.Del_Assigned_To_Trip
                                         (p_delivery_id =>  p_entity_id,
                                          x_return_status => x_return_status);

            IF l_debug_on THEN
             wsh_debug_sv.log(l_module_name, 'Del_Assigned_To_Trip x_return_status',x_return_status);
            END IF;
               IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                    IF l_debug_on THEN
                     wsh_debug_sv.pop(l_module_name, 'RETURN');
                    END IF;
                    RETURN;
               ELSIF l_assigned_to_trip = 'Y' THEN
                    raise wsh_del_assign_to_trip;
               END IF;
        END IF;
        --heali

	IF ( l_wh_type = 'TPW' ) THEN
	   open rel_status_tpw_cur(p_entity_id);
	   Fetch rel_status_tpw_cur into l_rel_stat_tmp;
	   close rel_status_tpw_cur;
	   IF l_rel_stat_tmp = 'X'   THEN
	      raise wsh_tpw_del_det_rel_stat;
   	   END IF;
	ELSIF ( l_wh_type = 'CMS' ) THEN
	   open rel_status_cms_cur(p_entity_id);
	   Fetch rel_status_cms_cur into l_rel_stat_tmp;
	   close rel_status_cms_cur;
	   IF l_rel_stat_tmp = 'X'  THEN
	      raise wsh_cms_del_det_rel_stat;
   	   END IF;

	   open det_pack_cms_cur(p_entity_id);
	   Fetch det_pack_cms_cur into l_packed_det_tmp;
	   close det_pack_cms_cur;

           IF l_packed_det_tmp = 'X'  THEN
	      raise wsh_details_not_packed;
	   END IF;


	END IF;


	WSH_DELIVERY_UTIL.Update_Dlvy_Status (p_entity_id,
				              p_action_type,
					      p_document_type,
                                              x_return_status);
	--commit;
	select 1 into l_tmp
	from wsh_new_deliveries
	where delivery_id = p_entity_id
	for update nowait;

        IF l_debug_on THEN
         wsh_debug_sv.log (l_module_name,'Update_Dlvy_Status-> x_return_status: ',x_return_status);
        END IF;

	IF ( x_return_status not in (WSH_UTIL_CORE.G_RET_STS_SUCCESS,WSH_UTIL_CORE.G_RET_STS_WARNING) ) THEN
	   raise wsh_insert_history_error;
        ELSE
          IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
             l_warning_count := l_warning_count + 1;
          END IF;
	END IF;
	WSH_EXTERNAL_INTERFACE_SV.RAISE_EVENT(l_txns_history_rec,
					      NULL,
					      x_return_status);
        IF l_debug_on THEN
         wsh_debug_sv.log (l_module_name,'RAISE_EVENT x_return_status: ',x_return_status);
        END IF;
	IF ( x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
	   raise wsh_raise_event_error;
	END IF;
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
     ELSE
	raise wsh_delivery_locked;
     END IF;

  ELSIF ( p_action_type = 'D' ) THEN  --{


     IF ( WSH_DELIVERY_UTIL.Is_SendDoc_Allowed(p_entity_id,
				 	     p_action_type,
					     x_return_status)
	) THEN --{

        -- K proj removed the condition on if l_wh_type = 'TPW'
        -- also removed the else part this condition.

	open orig_txn_hist_cur( l_entity_number, p_organization_id);
	Fetch orig_txn_hist_cur into l_txns_history_rec.orig_document_number, l_orig_txn_status;
	close orig_txn_hist_cur;
	--l_wh_type := 'CMS';

        /* Bug 2399483
        IF (l_orig_txn_status in ('IP','ER')) THEN
            raise wsh_document_in_ip_er;
        END IF;
        Bug 2399483
        */

        select 1 into l_tmp
        from wsh_new_deliveries
        where delivery_id = p_entity_id
        for update nowait;

        WSH_DELIVERY_UTIL.Update_Dlvy_Status (p_entity_id,
					         p_action_type,
						 p_document_type,
                                                 x_return_status);

	   --commit;
          IF l_debug_on THEN
           wsh_debug_sv.log (l_module_name,'Update_Dlvy_Status-> x_return_status: ',x_return_status);
          END IF;

	   WSH_EXTERNAL_INTERFACE_SV.RAISE_EVENT(l_txns_history_rec,
						 NULL,
					         x_return_status);
           IF l_debug_on THEN
            wsh_debug_sv.log (l_module_name,'RAISE_EVENT x_return_status: ',x_return_status);
           END IF;
	   IF ( x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
	      raise wsh_raise_event_error;
	   END IF;
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  	   --bmso l_txns_history_rec.transaction_status := 'ST';
     ELSE  --}{
	raise wsh_cancel_disallowed;
     END IF; --}

  END IF; --}

  IF (l_warning_count > 0 ) THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
  END IF;

 IF l_debug_on THEN
  wsh_debug_sv.pop (l_module_name);
 END IF;
EXCEPTION
  WHEN wsh_incorrect_org THEN
       x_return_status := wsh_util_core.g_ret_sts_error;
       FND_MESSAGE.Set_Name('WSH', 'WSH_INCORRECT_ORG');
       FND_MESSAGE.Set_Token('ORG_CODE', l_org_code);
       WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
       IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'wsh_incorrect_org exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_incorrect_org');
       END IF;
  WHEN wsh_invalid_delivery THEN
       x_return_status := wsh_util_core.g_ret_sts_error;
       FND_MESSAGE.Set_Name('WSH', 'WSH_INCOMPLETE_DELIVERY');
       FND_MESSAGE.Set_Token('DEL_NAME', l_entity_number);
       WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
       IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'wsh_invalid_delivery exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_invalid_delivery');
       END IF;
  WHEN wsh_details_not_packed THEN
       x_return_status := wsh_util_core.g_ret_sts_error;
       FND_MESSAGE.Set_Name('WSH', 'WSH_DEL_PACK_ITEMS_UNPACKED');
       FND_MESSAGE.Set_Token('DEL_NAME', l_entity_number);
       WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
       IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'wsh_details_not_packed exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_details_not_packed');
       END IF;
  WHEN wsh_tpw_del_det_rel_stat THEN
       x_return_status := wsh_util_core.g_ret_sts_error;
       FND_MESSAGE.Set_Name('WSH', 'WSH_TPW_DEL_DET_REL_STAT');
       FND_MESSAGE.Set_Token('DEL_NAME', l_entity_number);
       WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
       IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'wsh_tpw_del_det_rel_stat exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_tpw_del_det_rel_stat');
       END IF;
  WHEN wsh_cms_del_det_rel_stat THEN
       x_return_status := wsh_util_core.g_ret_sts_error;
       FND_MESSAGE.Set_Name('WSH', 'WSH_CMS_DEL_DET_REL_STAT');
       FND_MESSAGE.Set_Token('DEL_NAME', l_entity_number);
       WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
       IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'wsh_cms_del_det_rel_stat exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_cms_del_det_rel_stat');
       END IF;
  WHEN wsh_insert_history_error THEN
       IF ( p_action_type = 'A' ) THEN
	  WSH_DELIVERY_UTIL.Update_Dlvy_Status (p_entity_id,
						NULL,
						p_document_type,
                                                x_return_status);
	  --commit;
          x_return_status := wsh_util_core.g_ret_sts_error;
       ELSIF ( p_action_type = 'D' ) THEN
	  WSH_DELIVERY_UTIL.Update_Dlvy_Status (p_entity_id,
						'A',
						p_document_type,
                                                x_return_status);
	  --commit;
	  x_return_status := wsh_util_core.g_ret_sts_error;
       END IF;
       IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'wsh_insert_history_error exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_insert_history_error');
       END IF;
  WHEN wsh_raise_event_error THEN
       IF ( p_action_type = 'A' ) THEN
	  WSH_DELIVERY_UTIL.Update_Dlvy_Status (p_entity_id,
						NULL,
						p_document_type,
                                                x_return_status);
	  --commit;
          x_return_status := wsh_util_core.g_ret_sts_error;
       ELSIF ( p_action_type = 'D' ) THEN
	  WSH_DELIVERY_UTIL.Update_Dlvy_Status (p_entity_id,
						'A',
						p_document_type,
                                                x_return_status);
	  --commit;
	  x_return_status := wsh_util_core.g_ret_sts_error;
       ELSE
	  x_return_status := wsh_util_core.g_ret_sts_error;
       END IF;
       IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'wsh_raise_event_error exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_raise_event_error');
       END IF;
  WHEN wsh_delivery_locked THEN
       x_return_status := wsh_util_core.g_ret_sts_error;
       FND_MESSAGE.Set_Name('WSH', 'WSH_DELIVERY_LOCKED');
       FND_MESSAGE.Set_Token('DEL_NAME', l_entity_number);
       WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
       IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'wsh_delivery_locked exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_delivery_locked');
       END IF;
  WHEN wsh_cancel_disallowed THEN
       x_return_status := wsh_util_core.g_ret_sts_error;
       FND_MESSAGE.Set_Name('WSH', 'WSH_CANCEL_DISALLOWED');
       FND_MESSAGE.Set_Token('DEL_NAME', l_entity_number);
       WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
       IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'wsh_cancel_disallowed exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_cancel_disallowed');
       END IF;
  WHEN wsh_del_assign_to_trip THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_DEL_OUTBOUND_FAILED_TRIP');
        FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_entity_id));
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        wsh_util_core.add_message(x_return_status,l_module_name);
       IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'wsh_del_assign_to_trip exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_del_assign_to_trip');
       END IF;
  WHEN wsh_details_exceptions THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_XC_EXIST_DET');
        FND_MESSAGE.SET_TOKEN('DEL_DET_ID', to_char(l_delivery_detail_id));
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        wsh_util_core.add_message(x_return_status,l_module_name);
       IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'wsh_details_exceptions exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_details_exceptions');
       END IF;
  WHEN wsh_details_credit_hold THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_SR_CREDIT_HOLD_ERR');
        FND_MESSAGE.SET_TOKEN('DEL_NAME',l_entity_number);
        FND_MESSAGE.SET_TOKEN('DET_NAME',to_char(l_delivery_detail_id));
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        wsh_util_core.add_message(x_return_status,l_module_name);
       IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'wsh_details_credit_hold exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_details_credit_hold ');
       END IF;
  WHEN wsh_invalid_customer  THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_NO_CUST_DEF_ERROR');
        FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_entity_id));
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        wsh_util_core.add_message(x_return_status,l_module_name);
       IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'wsh_invalid_customer exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_invalid_customer');
       END IF;
  WHEN others THEN
       x_return_status := wsh_util_core.g_ret_sts_unexp_error;
       IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
       END IF;
END Send_Shipment_Request;

PROCEDURE Get_Event_Key(p_item_type     IN VARCHAR2 DEFAULT NULL,
                        p_orig_doc_number IN VARCHAR2 DEFAULT NULL,
                        p_organization_id IN NUMBER,
                        p_event_name    IN VARCHAR2,
			p_delivery_name IN VARCHAR2 DEFAULT NULL,
			x_event_key	OUT NOCOPY  VARCHAR2,
                        x_return_status OUT NOCOPY  VARCHAR2
                       )
IS

cursor get_key is
select event_key
from wsh_transactions_history
where item_type = p_item_type
and document_number = p_orig_doc_number
and trading_partner_id = p_organization_id;

cursor	del_cur is
select	delivery_id
from	wsh_new_deliveries
where 	name = p_delivery_name
and	organization_id = p_organization_id;


l_event_code VARCHAR2(30);
l_event_key VARCHAR2(30);

l_temp NUMBER;
l_wh_type VARCHAR2(10);
l_delivery_id NUMBER;
wsh_invalid_event_name EXCEPTION;
wsh_invalid_delivery_name EXCEPTION;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_EVENT_KEY';
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
  wsh_debug_sv.push(l_module_name, 'Get_Event_Key');
  wsh_debug_sv.log (l_module_name, 'Event Name ' , p_event_name);
  wsh_debug_sv.log (l_module_name, 'Organization Id ' , p_organization_id);
  wsh_debug_sv.log (l_module_name, 'Delivery Name ' , p_delivery_name);
  wsh_debug_sv.log (l_module_name, 'Event Code ' , l_event_code);
 END IF;

  x_return_status := wsh_util_core.g_ret_sts_success;
  l_event_code := UPPER(SUBSTRB (p_event_name, INSTRB(p_event_name, '.', -1) + 1));
  IF l_event_code IN ('SPWF','SSAI','SSAO','CONFIRM') THEN
     -- R12.1.1 STANDALONE PROJECT
     -- LSP PROJECT : Consider LSP mode also.
     IF ( WMS_DEPLOY.WMS_DEPLOYMENT_MODE IN ('D','L') AND (l_event_code = 'SSAO')) THEN
        select wsh_transaction_s.nextval into l_temp from dual;
        x_event_key := to_char(l_temp);
     ELSE
        open get_key;
        Fetch get_key into x_event_key;
        close get_key;
     END IF;
  ELSIF l_event_code = 'SSRO' THEN
     IF p_delivery_name IS NOT NULL THEN
        open del_cur;
        fetch del_cur into l_delivery_id;
        close del_cur;
        select wsh_transaction_s.nextval into l_temp from dual;
        l_wh_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type( p_organization_id => p_organization_id,
								   x_return_status      => x_return_status,
								   p_delivery_id	=> l_delivery_id
							         );
       IF l_debug_on THEN
        wsh_debug_sv.log (l_module_name,'Get_Warehouse_Type l_wh_type,x_return_status',l_wh_type||','||x_return_status );
       END IF;
     ELSE
	raise wsh_invalid_delivery_name;
     END IF;
     x_event_key := l_wh_type || to_char(l_temp);
  ELSIF l_event_code IN ('SSRI','SCBOD')  THEN
     select wsh_transaction_s.nextval into l_temp from dual;
     x_event_key := to_char(l_temp);
  ELSE
     raise wsh_invalid_event_name;
  END IF;

 IF l_debug_on THEN
  WSH_DEBUG_SV.log(l_module_name, 'Event Key'|| x_event_key);
  wsh_debug_sv.pop(l_module_name);
 END IF;
EXCEPTION

  WHEN wsh_invalid_event_name THEN
       x_return_status := wsh_util_core.g_ret_sts_error;
       IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'wsh_invalid_event_name exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_invalid_event_name');
       END IF;
  WHEN wsh_invalid_delivery_name THEN
       x_return_status := wsh_util_core.g_ret_sts_error;
       IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'wsh_invalid_delivery_name exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_invalid_delivery_name');
       END IF;
  WHEN others THEN
       x_return_status := wsh_util_core.g_ret_sts_unexp_error;
       IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
       END IF;
END Get_Event_Key;


PROCEDURE Unlock_Delivery_WF( item_type 	IN	VARCHAR2,
			      item_key		IN	VARCHAR2,
			      actid		IN	NUMBER,
			      funcmode		IN	VARCHAR2,
			      resultout		OUT NOCOPY 	VARCHAR2
                       	    )
IS

CURSOR  c_delId_cur IS
SELECT	wnd.delivery_id
from	wsh_new_deliveries wnd,
	wsh_transactions_history wth
where	wnd.name = wth.entity_number
and	entity_type='DLVY'
and	wth.event_key = item_key
and	wth.item_type = item_type
and	wth.document_direction='O';

l_return_status VARCHAR2(1);
l_delivery_id		NUMBER;
wsh_unlock_error EXCEPTION;
wsh_del_not_found EXCEPTION;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UNLOCK_DELIVERY_WF';
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
  wsh_debug_sv.push(l_module_name, 'Unlock_Delivery_WF');
  wsh_debug_sv.log(l_module_name, 'item_type',item_type);
  wsh_debug_sv.log(l_module_name, 'item_key',item_key);
  wsh_debug_sv.log(l_module_name, 'actid',actid);
  wsh_debug_sv.log(l_module_name, 'funcmode',funcmode);
 END IF;


  IF ( funcmode = 'RUN' )  THEN

     open c_delId_cur;
     Fetch c_delId_cur into l_delivery_id;
     IF ( c_delId_cur%NOTFOUND ) THEN
        CLOSE c_delId_cur;
	resultout := 'COMPLETE:FAILURE';
	raise wsh_del_not_found;
     END IF;

     WSH_DELIVERY_UTIL.Update_Dlvy_Status(l_delivery_id,
					  NULL,
					  NULL,
				          l_return_status);
     IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name, 'l_return_status',l_return_status);
     END IF;

     IF ( l_return_status not in (WSH_UTIL_CORE.G_RET_STS_SUCCESS,WSH_UTIL_CORE.G_RET_STS_WARNING) ) THEN
	raise wsh_unlock_error;
     ELSE
	resultout := 'COMPLETE:SUCCESS';
        IF l_debug_on THEN
         wsh_debug_sv.log(l_module_name, 'resultout',resultout);
         wsh_debug_sv.pop (l_module_name,'RETURN');
        END IF;
        RETURN;
     END IF;

  END IF;

 IF l_debug_on THEN
  wsh_debug_sv.log(l_module_name, 'resultout',resultout);
  wsh_debug_sv.pop (l_module_name);
 END IF;
EXCEPTION
  WHEN wsh_del_not_found THEN
	resultout := 'COMPLETE:FAILURE';
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'wsh_del_not_found exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_del_not_found');
        END IF;
        raise;
  WHEN wsh_unlock_error THEN
	resultout := 'COMPLETE:FAILURE';
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'wsh_unlock_error exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_unlock_error');
        END IF;
        raise;
  WHEN OTHERS THEN
	resultout := 'COMPLETE:FAILURE';
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        raise;
END  Unlock_Delivery_WF;

PROCEDURE update_atnms(  p_transaction_id       IN      number)

IS

  pragma AUTONOMOUS_TRANSACTION;
  l_debug_on BOOLEAN;

  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.'
    || 'UPDATE_ATNMS';

BEGIN
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name);
      wsh_debug_sv.log(l_module_name, 'p_transaction_id',p_transaction_id);
   END IF;

   UPDATE wsh_transactions_history
           SET transaction_status = 'ER'
           WHERE transaction_id = p_transaction_id;

   IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name, 'ROWCOUNT', SQL%ROWCOUNT);
   END IF;

   COMMIT;

  IF l_debug_on THEN
     wsh_debug_sv.pop (l_module_name);
  END IF;

EXCEPTION
     WHEN OTHERS THEN
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,
              'Unexpected error has occured. Oracle error message is '
               || SQLERRM, WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        raise;
END update_atnms;


PROCEDURE Process_Inbound_Delivery_WF(	Item_type 	IN	VARCHAR2,
					Item_key	IN	VARCHAR2,
					Actid		IN	NUMBER,
					Funcmode	IN	VARCHAR2,
					Resultout	OUT NOCOPY 	VARCHAR2
                       	 	     )

IS


l_txns_history_rec WSH_TRANSACTIONS_HISTORY_PKG.Txns_History_Record_Type;
l_return_status VARCHAR2(1);
l_document_type VARCHAR2(30);
--k proj
  l_cancellation_in_progress BOOLEAN := FALSE;
  l_num_warn   number := 0;
  l_num_err    number := 0;
  l_sr_trx_id  NUMBER;
  l_enity_number            wsh_transactions_history.entity_number%TYPE;

  CURSOR c_get_entity_number (v_trx_id NUMBER) IS --bmso
  SELECT wth1.entity_number , wth1.transaction_id
  FROM wsh_transactions_history wth1,
       wsh_transactions_history wth2
  WHERE wth1.action_type = 'A'
  AND wth1.entity_type = 'DLVY'
  AND wth1.document_type = 'SR'
  AND wth1.document_direction = 'O'
  AND wth1.document_number = wth2.ORIG_DOCUMENT_NUMBER
  AND wth1.event_key = wth2.event_key
  AND wth2.document_direction = 'I'
  AND wth2.transaction_id = v_trx_id
  AND wth2.document_type = 'SA'
  ORDER BY wth1.transaction_id desc;

  CURSOR c_get_cancel_record (v_sr_trx_id number) IS
  SELECT  wth2.transaction_id  ,
        wth2.document_type   ,
        wth2.document_direction      ,
        wth2.document_number ,
        wth2.orig_document_number    ,
        wth2.entity_number   ,
        wth2.entity_type     ,
        wth2.trading_partner_id      ,
        wth2.action_type     ,
        wth2.transaction_status ,
        wth2.ecx_message_id  ,
        wth2.event_name      ,
        wth2.event_key       ,
        wth2.item_type       ,
        wth2.internal_control_number ,
        -- R12.1.1 STANDALONE PROJECT
        wth2.document_revision,
        wth2.attribute_category      ,
        wth2.attribute1      ,
        wth2.attribute2      ,
        wth2.attribute3      ,
        wth2.attribute4      ,
        wth2.attribute5      ,
        wth2.attribute6      ,
        wth2.attribute7      ,
        wth2.attribute8      ,
        wth2.attribute9      ,
        wth2.attribute10     ,
        wth2.attribute11     ,
        wth2.attribute12     ,
        wth2.attribute13     ,
        wth2.attribute14     ,
        wth2.attribute15,
        NULL  -- LSP PROJECT : just added for dependency for client_id
  FROM wsh_transactions_history wth1,
       wsh_transactions_history wth2
  WHERE wth1.transaction_id = v_sr_trx_id
  AND wth2.entity_number = wth1.entity_number
  AND wth2.document_direction = 'O'
  AND wth2.document_type = 'SR'
  AND wth2.action_type = 'D'
  ORDER BY wth2.transaction_id desc;

  l_cancel_history_rec WSH_TRANSACTIONS_HISTORY_PKG.Txns_History_Record_Type;

wsh_process_inbound EXCEPTION;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PROCESS_INBOUND_DELIVERY_WF';
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
  wsh_debug_sv.push(l_module_name, 'Process_Inbound_Delivery_WF');
  wsh_debug_sv.log(l_module_name, 'item_type',item_type);
  wsh_debug_sv.log(l_module_name, 'item_key',item_key);
  wsh_debug_sv.log(l_module_name, 'actid',actid);
  wsh_debug_sv.log(l_module_name, 'funcmode',funcmode);
 END IF;


  IF ( funcmode = 'RUN' )  THEN

     IF ( item_type = 'WSHSUPI') THEN
	l_document_type := 'SA';
     ELSE
	l_document_type := 'SR';
     END IF;
     WSH_TRANSACTIONS_HISTORY_PKG.Get_Txns_History(
						    Item_type,
						    Item_key,
						    'I',
						    l_document_type,
						    l_txns_history_rec,
						    l_return_status
						  );
     IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name, 'Get_Txns_History l_return_status ',l_return_status);
     END IF;
     IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
	raise wsh_process_inbound;
     END IF;
     --k proj
     IF l_document_type = 'SA' AND branch_cms_tpw_flow(p_event_key => item_key)
     THEN --{

        OPEN c_get_entity_number(l_txns_history_rec.transaction_id);
        FETCH c_get_entity_number INTO l_enity_number, l_sr_trx_id;
        CLOSE c_get_entity_number;

        IF l_debug_on THEN
           wsh_debug_sv.log(l_module_name, 'l_enity_number ',l_enity_number);
           wsh_debug_sv.log(l_module_name, 'l_sr_trx_id ',l_sr_trx_id);
        END IF;

        IF l_txns_history_rec.transaction_status IN ('IP','ER') THEN --{


           Check_cancellation_inprogress (
                                   p_delivery_name   => l_enity_number,
                               --=> l_txns_history_rec.entity_number,
                                   x_cancellation_in_progress =>
                                                   l_cancellation_in_progress,
                                   x_return_status            => l_return_status
                                 );
           IF l_debug_on THEN
               wsh_debug_sv.log(l_module_name, 'l_return_status ',
                                                      l_return_status);
               wsh_debug_sv.log(l_module_name, 'l_cancellation_in_progress',
                                              l_cancellation_in_progress);
           END IF;

           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
              RAISE fnd_api.g_exc_error;
           END IF;

           IF l_cancellation_in_progress THEN

              update_atnms(l_txns_history_rec.transaction_id);
              RAISE fnd_api.g_exc_error;

           END IF;

        END IF; --}
     END IF; --}

     WSH_PROCESS_INTERFACED_PKG.Process_Inbound(l_txns_history_rec,
						l_return_status);
     IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name, 'Process_Inbound l_return_status ',l_return_status);
     END IF;

     IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
	raise wsh_process_inbound;
     ELSE
        -- send a CBOD to close the cancellation workflow instance bmso k proj

        IF branch_cms_tpw_flow(p_event_key => item_key)
          AND l_document_type = 'SA'
        THEN --{
           OPEN c_get_cancel_record(l_sr_trx_id);
           FETCH c_get_cancel_record INTO l_cancel_history_rec;

           IF c_get_cancel_record%FOUND THEN --{
              l_cancel_history_rec.Event_Name := 'ORACLE.APPS.FTE.SSNO.CONFIRM';

              WSH_EXTERNAL_INTERFACE_SV.Raise_Event (
                                                         l_cancel_history_rec,
                                                         '99',
                                                         l_Return_Status );
              wsh_util_core.api_post_call(
                  p_return_status => l_return_status,
                  x_num_warnings       => l_num_warn,
                  x_num_errors         => l_num_err);

           END IF; --}
           CLOSE c_get_cancel_record;
        END IF; --}

	resultout := 'COMPLETE:SUCCESS';
        IF l_debug_on THEN
         wsh_debug_sv.log(l_module_name, 'resultout',resultout);
         wsh_debug_sv.pop (l_module_name,'RETURN');
        END IF;
        RETURN;
     END IF;

  END IF;

 IF l_debug_on THEN
  wsh_debug_sv.log(l_module_name, 'resultout',resultout);
  wsh_debug_sv.pop (l_module_name);
 END IF;
EXCEPTION
  WHEN wsh_process_inbound THEN
	resultout := 'COMPLETE:FAILURE';
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'wsh_process_inbound exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_process_inbound');
        END IF;
        raise;
  WHEN fnd_api.g_exc_error THEN
	resultout := 'COMPLETE:FAILURE';
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'fnd_api.g_exc_error exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:fnd_api.g_exc_error');
        END IF;
        raise;
  WHEN OTHERS THEN
	resultout := 'COMPLETE:FAILURE';
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        raise;
END Process_Inbound_Delivery_WF;

    -- ------------------------------------------------------------------
    -- Procedure:	Process_Inbound_SR_WF
    --
    -- Parameters:	Item_Type IN  VARCHAR2
    --                  Item_Key  IN  VARCHAR2
    --		       	Actid     IN  NUMBER
    --                  Funcmode  IN  VARCHAR2
    --                  Resultout OUT VARCHAR2
    --
    -- Description:  This procedure is called from Inbound workflow (WSHSTNDI) to process
    --               the Inbound Shipment Request information sent by Host ERP system
    -- Created:     Standalone WMS Project
    -- -----------------------------------------------------------------------
PROCEDURE Process_Inbound_SR_WF(	Item_type 	IN	VARCHAR2,
					Item_key	IN	VARCHAR2,
					Actid		IN	NUMBER,
					Funcmode	IN	VARCHAR2,
					Resultout	OUT NOCOPY 	VARCHAR2
                       	 	     )

IS


l_txns_history_rec WSH_TRANSACTIONS_HISTORY_PKG.Txns_History_Record_Type;
l_return_status VARCHAR2(1);
l_document_type VARCHAR2(30);

wsh_process_inbound EXCEPTION;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Process_Inbound_SR_WF';
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
  wsh_debug_sv.push(l_module_name, 'Process_Inbound_SR_WF');
  wsh_debug_sv.log(l_module_name, 'item_type',item_type);
  wsh_debug_sv.log(l_module_name, 'item_key',item_key);
  wsh_debug_sv.log(l_module_name, 'actid',actid);
  wsh_debug_sv.log(l_module_name, 'funcmode',funcmode);
 END IF;


  IF ( funcmode = 'RUN' )  THEN

     l_document_type := 'SR';
     WSH_TRANSACTIONS_HISTORY_PKG.Get_Txns_History(
						    Item_type,
						    Item_key,
						    'I',
						    l_document_type,
						    l_txns_history_rec,
						    l_return_status
						  );
     IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name, 'Get_Txns_History l_return_status ',l_return_status);
     END IF;
     IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
	raise wsh_process_inbound;
     END IF;

     WSH_PROCESS_INTERFACED_PKG.Process_Inbound(l_txns_history_rec,
						l_return_status);
     IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name, 'Process_Inbound l_return_status ',l_return_status);
     END IF;

     IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
	raise wsh_process_inbound;
     ELSE
	resultout := 'COMPLETE:SUCCESS';
        IF l_debug_on THEN
         wsh_debug_sv.log(l_module_name, 'resultout',resultout);
         wsh_debug_sv.pop (l_module_name,'RETURN');
        END IF;
        RETURN;
     END IF;

  END IF;

 IF l_debug_on THEN
  wsh_debug_sv.log(l_module_name, 'resultout',resultout);
  wsh_debug_sv.pop (l_module_name);
 END IF;
EXCEPTION
  WHEN wsh_process_inbound THEN
	resultout := 'COMPLETE:ERROR';
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'wsh_process_inbound exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_process_inbound');
        END IF;
  --      raise;
  WHEN fnd_api.g_exc_error THEN
	resultout := 'COMPLETE:ERROR';
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'fnd_api.g_exc_error exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:fnd_api.g_exc_error');
        END IF;
 --       raise;
  WHEN OTHERS THEN
	resultout := 'COMPLETE:ERROR';
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
--        raise;
END Process_Inbound_SR_WF;

PROCEDURE Update_Txn_Hist_Err_WF(	Item_type 	IN	VARCHAR2,
					Item_key	IN	VARCHAR2,
					Actid		IN	NUMBER,
					Funcmode	IN	VARCHAR2,
					Resultout	OUT NOCOPY 	VARCHAR2
                       	 	     )

IS
l_return_status VARCHAR2(1);
wsh_update_history EXCEPTION;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_TXN_HIST_ERR_WF';
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
  wsh_debug_sv.push(l_module_name, 'Update_Txn_Hist_Err_WF');
  wsh_debug_sv.log(l_module_name, 'item_type',item_type);
  wsh_debug_sv.log(l_module_name, 'item_key',item_key);
  wsh_debug_sv.log(l_module_name, 'actid',actid);
  wsh_debug_sv.log(l_module_name, 'funcmode',funcmode);
 END IF;


  IF ( funcmode = 'RUN' )  THEN
     Update_Txn_History ( Item_type,
			  Item_key,
			  'ER',
                          l_return_status
                        );
     IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name, 'Update_Txn_History l_return_status ',l_return_status);
     END IF;

     IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
	raise wsh_update_history;
     ELSE
	resultout := 'COMPLETE:SUCCESS';
        IF l_debug_on THEN
         wsh_debug_sv.log(l_module_name, 'resultout',resultout);
         wsh_debug_sv.pop(l_module_name, 'RETURN');
        END IF;
        RETURN;
     END IF;

  END IF;

 IF l_debug_on THEN
  wsh_debug_sv.pop (l_module_name);
 END IF;
EXCEPTION
  WHEN wsh_update_history THEN
	resultout := 'COMPLETE:FAILURE';
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'wsh_update_history exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_update_history');
        END IF;
        raise;
  WHEN OTHERS THEN
	resultout := 'COMPLETE:FAILURE';
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        raise;
END Update_Txn_Hist_Err_WF;

PROCEDURE Update_Txn_Hist_Success_WF(	Item_type 	IN	VARCHAR2,
					Item_key	IN	VARCHAR2,
					Actid		IN	NUMBER,
					Funcmode	IN	VARCHAR2,
					Resultout	OUT NOCOPY 	VARCHAR2
                       	 	     )

IS
l_return_status VARCHAR2(1);
wsh_update_history EXCEPTION;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_TXN_HIST_SUCCESS_WF';
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
  wsh_debug_sv.push(l_module_name, 'Update_Txn_Hist_Err_WF');
  wsh_debug_sv.log(l_module_name, 'item_type',item_type);
  wsh_debug_sv.log(l_module_name, 'item_key',item_key);
  wsh_debug_sv.log(l_module_name, 'actid',actid);
  wsh_debug_sv.log(l_module_name, 'funcmode',funcmode);
 END IF;

  IF ( funcmode = 'RUN' )  THEN
     Update_Txn_History ( Item_type,
			  Item_key,
			  'ST',
                          l_return_status
                        );
     IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name, 'Update_Txn_History l_return_status ',l_return_status);
     END IF;
     IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
	raise wsh_update_history;
     ELSE
	resultout := 'COMPLETE:SUCCESS';
        IF l_debug_on THEN
         wsh_debug_sv.log(l_module_name, 'resultout',resultout);
         wsh_debug_sv.pop(l_module_name, 'RETURN');
        END IF;
        RETURN;
     END IF;
  END IF;
 IF l_debug_on THEN
  wsh_debug_sv.pop (l_module_name);
 END IF;
EXCEPTION
  WHEN wsh_update_history THEN
	resultout := 'COMPLETE:FAILURE';
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'wsh_update_history exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_update_history');
        END IF;
	raise;
  WHEN OTHERS THEN
	resultout := 'COMPLETE:FAILURE';
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        raise;
END Update_Txn_Hist_Success_WF;

 ---------------------------------------------------------------------
    -- Procedure:	Update_Txn_Hist_Closed_WF
    --
    -- Parameters:	Item_Type IN  VARCHAR2
    --                  Item_Key  IN  VARCHAR2
    --		       	Actid     IN  NUMBER
    --                  Funcmode  IN  VARCHAR2
    --                  Resultout OUT VARCHAR2
    --
    -- Description:  This procedure is called from Inbound Workflow (WSHSTNDI) to Close
    --                all the previous error out Shipment Request revision of the workflow
    -- Created:     Standalone WMS Project
    -- -----------------------------------------------------------------------
PROCEDURE Update_Txn_Hist_Closed_WF(	Item_type 	IN	VARCHAR2,
					Item_key	IN	VARCHAR2,
					Actid		IN	NUMBER,
					Funcmode	IN	VARCHAR2,
					Resultout	OUT NOCOPY 	VARCHAR2
                       	 	     )

IS
l_return_status VARCHAR2(1);
wsh_update_history EXCEPTION;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_TXN_HIST_CLOSED_WF';
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
  wsh_debug_sv.push(l_module_name, 'Update_Txn_Hist_Closed_WF');
  wsh_debug_sv.log(l_module_name, 'item_type',item_type);
  wsh_debug_sv.log(l_module_name, 'item_key',item_key);
  wsh_debug_sv.log(l_module_name, 'actid',actid);
  wsh_debug_sv.log(l_module_name, 'funcmode',funcmode);
 END IF;

  IF ( funcmode = 'RUN' )  THEN
     Update_Txn_History ( Item_type,
			  Item_key,
			  'SC',
                          l_return_status
                        );
     IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name, 'Update_Txn_History l_return_status ',l_return_status);
     END IF;
     IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
	raise wsh_update_history;
     ELSE
	resultout := 'COMPLETE:SUCCESS';
        IF l_debug_on THEN
         wsh_debug_sv.log(l_module_name, 'resultout',resultout);
         wsh_debug_sv.pop(l_module_name, 'RETURN');
        END IF;
        RETURN;
     END IF;
  END IF;
 IF l_debug_on THEN
  wsh_debug_sv.pop (l_module_name);
 END IF;
EXCEPTION
  WHEN wsh_update_history THEN
	resultout := 'COMPLETE:FAILURE';
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'wsh_update_history exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_update_history');
        END IF;
	raise;
  WHEN OTHERS THEN
	resultout := 'COMPLETE:FAILURE';
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        raise;
END Update_Txn_Hist_Closed_WF;

PROCEDURE Update_Txn_History ( p_item_type     IN      VARCHAR2,
                               p_item_key      IN      VARCHAR2,
                               p_transaction_status IN VARCHAR2,
                               x_return_status OUT NOCOPY      VARCHAR2
                              )
IS


pragma AUTONOMOUS_TRANSACTION;

l_txns_history_rec WSH_TRANSACTIONS_HISTORY_PKG.Txns_History_Record_Type;
l_document_type VARCHAR2(2);
l_txn_direction VARCHAR2(1);
l_txn_id NUMBER;

wsh_update_history EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_TXN_HISTORY';
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
  wsh_debug_sv.log(l_module_name, 'p_item_type',p_item_type);
  wsh_debug_sv.log(l_module_name, 'p_item_key',p_item_key);
  wsh_debug_sv.log(l_module_name, 'p_transaction_status',p_transaction_status);
 END IF;

  IF ( p_item_type = 'WSHSUPI' ) THEN
     l_document_type := 'SR';
     l_txn_direction := 'O';
  -- R12.1.1 STANDALONE PROJECT
  ELSIF (( p_item_type = 'WSHTPWI' AND p_transaction_status = 'ER' ) OR (p_item_type = 'WSHSTNDI')) THEN
     l_txn_direction := 'I';
     l_document_type := 'SR';
  ELSE
     l_document_type := 'SA';
     l_txn_direction := 'O';
  END IF;
  WSH_TRANSACTIONS_HISTORY_PKG.Get_Txns_History( p_item_type,
						 p_item_key,
						 l_txn_direction,
						 l_document_type,
						 l_txns_history_rec,
						 x_return_status );
  IF l_debug_on THEN
   wsh_debug_sv.log(l_module_name, 'Get_Txns_History x_return_status',x_return_status);
  END IF;

  l_txns_history_rec.transaction_status := p_transaction_status;
  IF ( x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
     raise wsh_update_history;
  END IF;

  WSH_TRANSACTIONS_HISTORY_PKG.Create_Update_Txns_History ( l_txns_history_rec,
                                                            l_txn_id,
                                                            x_return_status );
  IF l_debug_on THEN
   wsh_debug_sv.log(l_module_name, 'Create_Update_Txns_History x_return_status',x_return_status);
  END IF;

  IF ( x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
     raise wsh_update_history;
  ELSE
     COMMIT;
  END IF;

 IF l_debug_on THEN
  wsh_debug_sv.pop (l_module_name);
 END IF;
EXCEPTION
  WHEN wsh_update_history THEN
	x_return_status := wsh_util_core.g_ret_sts_error;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'wsh_update_history exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_update_history');
        END IF;
  WHEN OTHERS THEN
	x_return_status := wsh_util_core.g_ret_sts_error;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
END Update_Txn_History;

PROCEDURE WSHSUPI_SELECTOR(             Item_type       IN      VARCHAR2,
                                        Item_key        IN      VARCHAR2,
                                        Actid           IN      NUMBER,
                                        Funcmode        IN      VARCHAR2,
                                        Resultout       IN OUT NOCOPY   VARCHAR2
                                     ) IS
l_user_id       NUMBER;
l_resp_id       NUMBER;
l_resp_appl_id  NUMBER;
l_org_id        NUMBER;
l_current_org_id        NUMBER;
l_client_org_id NUMBER;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'WSHSUPI_SELECTOR';
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
       wsh_debug_sv.start_debug('wf_context');
       IF l_debug_on THEN
        wsh_debug_sv.push(l_module_name, 'WSHSUPI_SELECTOR');
        wsh_debug_sv.log (l_module_name, 'Item Type', Item_type);
        wsh_debug_sv.log (l_module_name, 'Item_Key', Item_key);
        wsh_debug_sv.log (l_module_name, 'Funcmode', Funcmode);
       END IF;

        IF(funcmode = 'RUN') THEN
                Resultout := 'COMPLETE';
        ELSIF(funcmode = 'SET_CTX') THEN
                l_user_id := wf_engine.GetItemAttrNumber(
                                'WSHSUPI',
                                Item_key,
                                'USER_ID');
                 l_resp_appl_id := wf_engine.GetItemAttrNumber(
                             'WSHSUPI',
                             Item_key,
                             'APPLICATION_ID');

                  l_resp_id := wf_engine.GetItemAttrNumber(
                             'WSHSUPI',
                             Item_key,
                             'RESPONSIBILITY_ID');

                IF(l_resp_appl_id IS NULL OR l_resp_id IS NULL) THEN
                        RAISE no_data_found;
                ELSE
                        FND_GLOBAL.Apps_Initialize(l_user_id, l_resp_id, l_resp_appl_id);
                END IF;
                Resultout := 'COMPLETE';
        ELSIF(funcmode = 'TEST_CTX') THEN


                         Resultout := 'TRUE';

        END IF; -- if funcmode = run

       IF l_debug_on THEN
        wsh_debug_sv.log (l_module_name, 'Resultout', Resultout);
        wsh_debug_sv.pop(l_module_name);
       END IF;
        wsh_debug_sv.stop_debug;
EXCEPTION
WHEN OTHERS THEN
        resultout := 'COMPLETE:FAILURE';
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        wsh_debug_sv.stop_debug;
        RAISE;
END WSHSUPI_SELECTOR;

  --k proj

  /*---------------------------------------------------------------------

   FUNCTION :                   branch_cms_tpw_flow
   Parameter:                   p_event_key

   Comments :

   This function is used to branch the flow of the cancellation for TPW
   and CMS.  If the cancellation is done for CMS, this function will return
   TRUE.  In future (if it is decided that CMS and TPW have same flow for
   cancellation) this function returns always TRUE;

  ---------------------------------------------------------------------*/

  FUNCTION branch_cms_tpw_flow (p_event_key  IN         VARCHAR2)
  RETURN BOOLEAN IS

  l_cms_flow   BOOLEAN := FALSE;
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' ||
                                                        'BRANCH_CMS_TPW_FLOW';
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
        wsh_debug_sv.log(l_module_name, 'p_event_key',p_event_key);
     END IF;

     IF p_event_key LIKE 'CMS%' THEN
        l_cms_flow := TRUE;
     END IF;

     IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name, 'l_cms_flow',l_cms_flow);
        wsh_debug_sv.pop(l_module_name);
     END IF;

     RETURN l_cms_flow;

  EXCEPTION

     WHEN OTHERS THEN
        wsh_util_core.default_handler('WSH_TRANSACTIONS_UTIL.branch_cms_tpw_flow');
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,
             'Unexpected error has occured. Oracle error message is '||
              substr(SQLERRM,1,200), WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;

  END branch_cms_tpw_flow;


  /*---------------------------------------------------------------------

   PROCEDURE :                   Check_cancellation_inprogress
   Parameters:                   p_delivery_id
                                 x_cancellation_in_progress
                                 x_return_status

   Comments  :

   This procedure is used to determine if there is a cancellation in progress
   for CMS flow.  A cancellation is in progress if the supplier has sent a
   cancel message, but no CBOD confirmation/rejection has arrived yet.

  ---------------------------------------------------------------------*/

  PROCEDURE Check_cancellation_inprogress
                     (
                       p_delivery_name  IN   VARCHAR2,
                       x_cancellation_in_progress OUT NOCOPY BOOLEAN ,
                       x_return_status OUT NOCOPY VARCHAR2
                     )
  IS

  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' ||
                                              'CHECK_CANCELLATION_INPROGRESS';
  --
  l_status                    VARCHAR2(5);
  l_event_key                 VARCHAR2(250);

  CURSOR c_del_status (v_delivery_name   varchar2) IS
  SELECT status_code
  FROM wsh_new_deliveries
  WHERE name = v_delivery_name;

  CURSOR c_get_event_key(v_delivery_name  NUMBER) IS
  SELECT event_key
  FROM wsh_transactions_history
  WHERE ENTITY_NUMBER = v_delivery_name
  AND ENTITY_TYPE = 'DLVY'
  AND ACTION_TYPE = 'D'
  AND document_direction = 'O'
  ORDER BY transaction_id DESC;
  --bmso
  l_wf_status VARCHAR2(30);
  l_result VARCHAR2(30);
  e_success                    EXCEPTION;
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
        wsh_debug_sv.log(l_module_name, 'p_delivery_name',p_delivery_name);
     END IF;

     x_cancellation_in_progress := FALSE;

     OPEN c_del_status(p_delivery_name);
        FETCH c_del_status INTO l_status;
        IF c_del_status%NOTFOUND THEN
           IF l_debug_on THEN
              wsh_debug_sv.logmsg(l_module_name, 'ERROR Invalid delivery');
           END IF;
           FND_MESSAGE.Set_Name('WSH', 'WSH_DEL_NOT_FOUND');
           WSH_UTIL_CORE.add_message (wsh_util_core.g_ret_sts_error,l_module_name);
           CLOSE c_del_status;
           RAISE fnd_api.g_exc_error;
        END IF;
        IF l_debug_on THEN
           wsh_debug_sv.log(l_module_name, 'l_status',l_status);
        END IF;

        IF l_status <> 'SC' THEN
           x_cancellation_in_progress := FALSE;
           RAISE e_success;
        END IF;
     CLOSE c_del_status;

     -- IF cancellation rejection comes and the status of the delivery is
     -- SC then we need to see if the second workflow instance
     -- (cancellation workflow) is still active

     OPEN c_get_event_key(p_delivery_name);
     FETCH c_get_event_key INTO l_event_key;
     IF c_get_event_key%NOTFOUND THEN

        IF l_debug_on THEN
           wsh_debug_sv.logmsg(l_module_name, 'Cannot find the transaction history record');
        END IF;

        x_cancellation_in_progress := FALSE;
        CLOSE c_get_event_key;

     ELSE --{

        CLOSE c_get_event_key;

        IF l_debug_on THEN
           wsh_debug_sv.log(l_module_name, 'l_event_key',l_event_key);
           wsh_debug_sv.logmsg(l_module_name, 'calling program WF_ENGINE.ItemStatus',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        WF_ENGINE.ItemStatus(
               itemtype => 'WSHSUPI',
               itemkey  => l_event_key,
               status   => l_wf_status,
               result   => l_result
        );

        -- values COMPLETE,SUSPENDED,ACTIVE,ERROR

        IF l_wf_status IN ('COMPLETE','SUSPENDED') THEN
           x_cancellation_in_progress := FALSE;
        ELSE
           x_cancellation_in_progress := TRUE;
        END IF;


     END IF; --}


     x_return_status := wsh_util_core.g_ret_sts_success;

     IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name, 'x_cancellation_in_progress',
                                                  x_cancellation_in_progress);
        wsh_debug_sv.pop(l_module_name);
     END IF;


  EXCEPTION

     WHEN e_success THEN
         x_return_status := wsh_util_core.g_ret_sts_success;
         --
         IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name, 'x_cancellation_in_progress',
                                                x_cancellation_in_progress);
            wsh_debug_sv.pop(l_module_name);
         END IF;

     WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
         --
         IF l_debug_on THEN
            wsh_debug_sv.logmsg(l_module_name, 'FND_API.G_EXC_ERROR exception has occured.', wsh_debug_sv.c_excep_level);
            wsh_debug_sv.pop(l_module_name, 'EXCEPTION:FND_API.G_EXC_ERROR');
         END IF;
     WHEN OTHERS THEN
        x_return_status := wsh_util_core.g_ret_sts_unexp_error;
        wsh_util_core.default_handler('WSH_TRANSACTIONS_UTIL.check_cancellation_inprogress',l_module_name);
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,
             'Unexpected error has occured. Oracle error message is '||
              substr(SQLERRM,1,200), WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;

  END Check_cancellation_inprogress;


  /*---------------------------------------------------------------------

   PROCEDURE :                   Check_cancellation_wf
   Parameters:                   item_type
                                 item_key
                                 actid
                                 funcmode
                                 resultout

   Comments  :

   This procedure is called from workflow and will determine if there is a
   Cancellation in process for CMS system.

  ---------------------------------------------------------------------*/

  PROCEDURE Check_cancellation_wf (
                              item_type         IN      VARCHAR2,
                              item_key          IN      VARCHAR2,
                              actid             IN      NUMBER,
                              funcmode          IN      VARCHAR2,
                              resultout         OUT NOCOPY      VARCHAR2
                            )
  IS

  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' ||
                                              'CHECK_CANCELLATION_WF';
  --
  l_delivery_name             varchar2(30);
  l_cancellation_in_progress BOOLEAN := FALSE;
  l_return_status            VARCHAR2(1);
  l_num_warn                 NUMBER := 0;
  l_num_err                  NUMBER := 0;
  l_transaction_id           NUMBER;

  --
  CURSOR  c_del_name_cur (v_item_key varchar2, v_item_type VARCHAR2) IS --bmso
  SELECT  wth2.entity_number ,  wth1.transaction_id
  FROM    wsh_transactions_history wth1,
          wsh_transactions_history wth2
  where   wth1.entity_type='DLVY_INT'
  and     wth1.event_key = v_item_key
  and     wth1.item_type = v_item_type
  and     wth1.document_type = 'SA'
  and     wth1.document_direction='I'
  and     wth1.action_type = 'A'
  AND     wth2.entity_type = 'DLVY'
  AND     wth2.document_type = 'SR'
  AND     wth2.action_type = 'A'
  AND     wth2.document_direction = 'O'
  AND     wth2.item_type = v_item_type
  AND     wth2.event_key = v_item_key
  ORDER BY wth1.transaction_id desc;



  e_send_no   EXCEPTION;
  e_send_yes  EXCEPTION;
  BEGIN

     --
     l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
     --
     IF l_debug_on IS NULL
     THEN
         l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
     END IF;
     --
     SAVEPOINT s_Check_cancellation_wf ;

     IF l_debug_on THEN
--bmso do we need to start the debugger
        wsh_debug_sv.push(l_module_name);
        wsh_debug_sv.log(l_module_name, 'item_type',item_type);
        wsh_debug_sv.log(l_module_name, 'item_key',item_key);
        wsh_debug_sv.log(l_module_name, 'actid',actid);
        wsh_debug_sv.log(l_module_name, 'funcmode',funcmode);
     END IF;

     IF ( funcmode = 'RUN' )  THEN --{
        IF branch_cms_tpw_flow(p_event_key => item_key) THEN --{
           --get the delivery name
           OPEN c_del_name_cur(item_key, item_type);
           FETCH c_del_name_cur INTO l_delivery_name, l_transaction_id;
           IF c_del_name_cur%NOTFOUND THEN
              IF l_debug_on THEN
                 wsh_debug_sv.logmsg(l_module_name, 'Error, invalid interface delivery');
              END IF;
              CLOSE c_del_name_cur;
              RAISE fnd_api.g_exc_error;
           END IF;
           CLOSE c_del_name_cur;

           IF l_debug_on THEN
              wsh_debug_sv.log(l_module_name, 'l_delivery_name',l_delivery_name);
              wsh_debug_sv.log(l_module_name, 'l_transaction_id',l_transaction_id);
           END IF;
           -- see if there is any cancelation pending
           Check_cancellation_inprogress (
                                   p_delivery_name           => l_delivery_name,
                                   x_cancellation_in_progress =>
                                                   l_cancellation_in_progress,
                                   x_return_status            => l_return_status
                                 );

           wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings       => l_num_warn,
               x_num_errors         => l_num_err);

           IF l_cancellation_in_progress THEN --{

              UPDATE wsh_transactions_history
              SET TRANSACTION_STATUS = 'AP'
              WHERE transaction_id = l_transaction_id;

              IF SQL%ROWCOUNT <> 1 THEN

                 IF l_debug_on THEN
                    wsh_debug_sv.log(l_module_name, 'Error in updating the transaction hsitory record to status AP',SQL%ROWCOUNT);
                 END IF;
                 RAISE FND_API.g_exc_error;
              END IF;
              RAISE e_send_yes;

           ELSE  --}{

              RAISE e_send_no;

           END IF; --}

        ELSE  --}{
              RAISE e_send_no;
        END IF; --}

     END IF; --}

     IF l_debug_on THEN
        wsh_debug_sv.pop(l_module_name);
     END IF;


  EXCEPTION


     WHEN e_send_no THEN
        resultout := 'COMPLETE:N';
        IF l_debug_on THEN
           wsh_debug_sv.log(l_module_name, 'resultout', resultout);
           wsh_debug_sv.pop(l_module_name);
        END IF;

     WHEN e_send_yes THEN
        resultout := 'COMPLETE:Y';
        IF l_debug_on THEN
           wsh_debug_sv.log(l_module_name, 'resultout', resultout);
           wsh_debug_sv.pop(l_module_name);
        END IF;

     WHEN fnd_api.g_exc_unexpected_error THEN
--bmso how do we rollback;
--also COMPLETE:FAILURE does not exist for this
         rollback to s_Check_cancellation_wf;
         resultout := 'COMPLETE:FAILURE';
         --
         IF l_debug_on THEN
            wsh_debug_sv.logmsg(l_module_name, 'fnd_api.g_exc_unexpected_error exception has occured.', wsh_debug_sv.c_excep_level);
            wsh_debug_sv.pop(l_module_name, 'EXCEPTION:fnd_api.g_exc_unexpected_error');
         END IF;
         RAISE;

     WHEN fnd_api.g_exc_error THEN
         rollback to s_Check_cancellation_wf;
         resultout := 'COMPLETE:FAILURE';
         --
         IF l_debug_on THEN
            wsh_debug_sv.logmsg(l_module_name, 'FND_API.G_EXC_ERROR exception has occured.', wsh_debug_sv.c_excep_level);
            wsh_debug_sv.pop(l_module_name, 'EXCEPTION:FND_API.G_EXC_ERROR');
         END IF;

         RAISE;
     WHEN OTHERS THEN
        resultout := 'COMPLETE:FAILURE';
        wsh_util_core.default_handler('WSH_TRANSACTIONS_UTIL.check_cancellation_wf');
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,
             'Unexpected error has occured. Oracle error message is '||
              substr(SQLERRM,1,200), WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
         RAISE;

  END check_cancellation_wf;



  /*---------------------------------------------------------------------

   PROCEDURE :                   process_cbod_wf
   Parameters:                   item_type
                                 item_key
                                 actid
                                 funcmode
                                 resultout

   Comments  :

   This procedure is called from workflow and will determine if there is a
   Cancellation in process for CMS system.

  ---------------------------------------------------------------------*/

  PROCEDURE process_cbod_wf (
                              item_type         IN      VARCHAR2,
                              item_key          IN      VARCHAR2,
                              actid             IN      NUMBER,
                              funcmode          IN      VARCHAR2,
                              resultout         OUT NOCOPY      VARCHAR2
                            )
  IS

  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' ||
                                              'PROCESS_CBOD_WF';
  --
  l_cbod_status             VARCHAR2(5);
  l_sr_hist_record WSH_TRANSACTIONS_HISTORY_PKG.Txns_History_Record_Type;
  l_entity_number WSH_TRANSACTIONS_HISTORY.entity_number%TYPE;
  l_result_code VARCHAR2(50);
  l_transaction_status  VARCHAR2(5);
  l_trx_id      NUMBER;
  l_return_status VARCHAR2(2);
  l_sa_exist  BOOLEAN := FALSE;
  l_param_list  wf_parameter_list_t;

  --

  l_del_interface_id     NUMBER;

  CURSOR c_get_trx_id (v_name varchar2) IS --bmso
  SELECT wth2.transaction_id, wth2.transaction_status,
         to_number(wth2.entity_number)
  FROM wsh_transactions_history wth1,
       wsh_transactions_history wth2
  WHERE wth1.entity_number = v_name
  AND wth1.action_type = 'A'
  AND wth1.entity_type = 'DLVY'
  AND wth1.document_type = 'SR'
  AND wth1.document_direction = 'O'
  AND wth1.document_number = wth2.ORIG_DOCUMENT_NUMBER
  AND wth1.event_key = wth2.event_key
  AND wth2.document_direction = 'I'
  AND wth2.document_type = 'SA';


  CURSOR c_get_sr_record (v_entity_number varchar2) IS --bmso
  SELECT transaction_id,
        document_type,
        document_direction,
        document_number,
        orig_document_number,
        entity_number,
        entity_type,
        trading_partner_id,
        action_type,
        transaction_status,
        ecx_message_id,
        event_name,
        event_key ,
        item_type,
        internal_control_number,
        -- R12.1.1 STANDALONE PROJECT
        document_revision,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        NULL  -- LSP PROJECT : just added for dependency for client_id
  FROM wsh_transactions_history
  WHERE
  entity_number = v_entity_number
  AND action_type = 'A'
  AND entity_type = 'DLVY'
  and document_direction  = 'O'
  and document_type       = 'SR'
  ORDER BY transaction_id DESC;

  CURSOR c_get_del_status (v_delivery_name VARCHAR2) IS
  SELECT status_code
  FROM wsh_new_deliveries
  WHERE name = v_delivery_name;

  l_status wsh_new_deliveries.status_code%TYPE;

  cursor c_get_cancel_rec (v_item_type VARCHAR2, v_item_key VARCHAR2)
  IS
  SELECT entity_number
  FROM  wsh_transactions_history
  WHERE item_type = v_item_type
  AND   event_key = v_item_key
  AND   document_direction = 'O'
  AND   document_type = 'SR'
  AND   ACTION_TYPE = 'D'
  ORDER BY transaction_id desc;

  cursor c_sr_instance (v_item_type VARCHAR2, v_item_key VARCHAR2)
  IS
  SELECT 1
  FROM  wsh_transactions_history
  WHERE item_type = v_item_type
  AND   event_key = v_item_key
  AND   document_direction = 'O'
  AND   document_type = 'SR'
  AND   ACTION_TYPE = 'A'
  ORDER BY transaction_id desc;

  l_dummy   NUMBER;

  e_send_true   EXCEPTION;
  e_send_false  EXCEPTION;
  BEGIN

     --
     l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
     --
     IF l_debug_on IS NULL
     THEN
         l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
     END IF;
     --
     SAVEPOINT s_process_cbod ;

     IF l_debug_on THEN
        wsh_debug_sv.push(l_module_name);
        wsh_debug_sv.log(l_module_name, 'item_type',item_type);
        wsh_debug_sv.log(l_module_name, 'item_key',item_key);
        wsh_debug_sv.log(l_module_name, 'actid',actid);
        wsh_debug_sv.log(l_module_name, 'funcmode',funcmode);
     END IF;

     IF ( funcmode = 'RUN' )  THEN --{
        IF branch_cms_tpw_flow(p_event_key => item_key) THEN --{

           -- get the history record for cancellation

           OPEN c_get_cancel_rec(item_type, item_key);
           FETCH c_get_cancel_rec INTO l_entity_number;

           IF c_get_cancel_rec%NOTFOUND THEN --{

              --If the cancel record is not found then it could be the
              -- case the the first work flow istance is being closed
              -- by the cancellation workflow.  This case happens when a
              -- CBOD confirmation arriaves at the cancellation workflow.

              CLOSE c_get_cancel_rec;

              OPEN c_sr_instance(item_type, item_key);
              FETCH c_sr_instance INTO l_dummy;
              IF c_sr_instance%NOTFOUND THEN --{
                 IF l_debug_on THEN
                    wsh_debug_sv.logmsg(l_module_name,
                                      'Error: Could not find record in transaction history');
                 END IF;
                 CLOSE c_sr_instance;
                 RAISE e_send_false;
              END IF; --}

              CLOSE c_sr_instance;

              -- close the workflow
              RAISE e_send_true;

           END IF; --}
           CLOSE c_get_cancel_rec;

           -- If for some reason the shipment advice has been processed through
           -- the message correction form and the cancellation workflow was
           -- not closed then close the cancellation workflow as a CBOD reject.

           OPEN c_get_del_status (l_entity_number);
           FETCH c_get_del_status INTO l_status;
           IF c_get_del_status%NOTFOUND THEN
              FND_MESSAGE.Set_Name('WSH', 'WSH_DEL_NOT_FOUND');
              WSH_UTIL_CORE.add_message (wsh_util_core.g_ret_sts_error,l_module_name);
              CLOSE c_get_del_status;
              RAISE e_send_false;
           END IF;
           CLOSE c_get_del_status;

           IF l_status IN ('CO','IT','CL','SA') THEN --{
              IF l_debug_on THEN
                 wsh_debug_sv.logmsg(l_module_name, 'Calling wf_engine.setItemAttribute');
              END IF;
              wf_engine.setItemAttrText
                           (
                              itemType => item_type,
                              itemKey  => item_key,
                              aname    => 'PARAMETER6',
                              avalue   => '99'
                           );
              RAISE e_send_true;

           END IF; --}

           --get the Shipment Request record
           OPEN c_get_sr_record(l_entity_number);
           FETCH c_get_sr_record INTO l_sr_hist_record;
           IF c_get_sr_record%NOTFOUND THEN
              IF l_debug_on THEN
                 wsh_debug_sv.log(l_module_name,
                        'Error: Could not find Shipment Request record for ',
                         l_entity_number);
              END IF;
              CLOSE c_get_sr_record;
              RAISE e_send_false;
           END IF;
           CLOSE c_get_sr_record;

           --get the transaction_id for the Shipment Advice record

           OPEN c_get_trx_id(l_entity_number);
           FETCH c_get_trx_id INTO l_trx_id , l_transaction_status,
               l_del_interface_id;
           IF c_get_trx_id%NOTFOUND THEN
              l_sa_exist := FALSE;
              IF l_debug_on THEN
                 wsh_debug_sv.log(l_module_name,
                                   'No SA record exist for ',
                                    l_entity_number);
              END IF;
           ELSE
             l_sa_exist := TRUE;
           END IF;
           CLOSE c_get_trx_id;

           IF l_debug_on THEN
                 wsh_debug_sv.log(l_module_name,'l_sa_exist',l_sa_exist);
                 wsh_debug_sv.log(l_module_name,'l_transaction_status',
                                                       l_transaction_status);
                 wsh_debug_sv.log(l_module_name,'l_trx_id',l_trx_id);
                 wsh_debug_sv.log(l_module_name,'l_del_interface_id',
                                                         l_del_interface_id);
           END IF;

           l_cbod_status := wf_engine.GetItemAttrText(
                                'WSHSUPI',
                                Item_key,
                                'PARAMETER6');
           IF l_debug_on THEN
                 wsh_debug_sv.log(l_module_name,'l_cbod_status',l_cbod_status);
           END IF;
           IF l_cbod_status = '00' THEN --{ confirmation


              --IF Shipment Advice record exist then change the status to 'SX'

              IF l_sa_exist  THEN --{

                -- Delete the interface record

                WSH_PROCESS_INTERFACED_PKG.delete_interface_records (
                    p_delivery_interface_id   => l_del_interface_id,
                    x_return_status           => l_Return_Status
                 ) ;

                 IF (l_Return_Status NOT IN  (WSH_UTIL_CORE.g_ret_sts_success,
                                WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
                    RAISE e_send_false;
                 END IF;

                 --Update the status_code for shipment advice record to 'SX'

                 UPDATE wsh_transactions_history
                 SET transaction_status= 'SX',
                 entity_number = l_entity_number,
                 entity_type = 'DLVY'
                 WHERE
                 transaction_id = l_trx_id; --bmso

              END IF; --}


              -- Raise the event for the first workflow instance to finish.

              l_sr_hist_record.Event_Name := 'ORACLE.APPS.FTE.SSNO.CONFIRM';

              WSH_EXTERNAL_INTERFACE_SV.Raise_Event ( l_sr_hist_record, '99',
                                                            l_Return_Status );

              IF l_debug_on THEN
               wsh_debug_sv.log (l_module_name, 'Return status after Raise_Event ', l_Return_Status);
              END IF;

              IF (l_Return_Status <> WSH_UTIL_CORE.g_ret_sts_success ) THEN
                 RAISE e_send_false;
              END IF;


           ELSE  --}{ rejection
              IF l_sa_exist THEN  --{
                 IF l_transaction_status = 'ER' THEN --{

                    wf_engine.handleError(
                                   itemType => l_sr_hist_record.item_type,
                                   itemKey  => l_sr_hist_record.event_key,
                                   activity => 'WSH_SUPPLIER_WF:WSH_PROCESS_DELIVERY',
                                   command  => 'RETRY',
                                   result   => NULL
                                 );

                 ELSIF l_transaction_status = 'AP' THEN --}{

                    wf_engine.completeActivity (
                               itemtype => l_sr_hist_record.item_type,
                               itemkey  => l_sr_hist_record.event_key,
                               activity => 'WSH_SUPPLIER_WF:CONTINUE_SHIPMENT_ADVICE',
                               result   => l_result_code);

                 END IF; --}
              END IF; --}
           END IF; --}
        END IF;  --}

        RAISE e_send_true;

     END IF; --}

     IF l_debug_on THEN
        wsh_debug_sv.pop(l_module_name);
     END IF;


  EXCEPTION


     WHEN e_send_true THEN
        resultout := 'COMPLETE:T';
        IF l_debug_on THEN
           wsh_debug_sv.log(l_module_name, 'resultout', resultout);
           wsh_debug_sv.pop(l_module_name);
        END IF;

     WHEN e_send_false THEN
        resultout := 'COMPLETE:F';
        IF l_debug_on THEN
           wsh_debug_sv.log(l_module_name, 'resultout', resultout);
           wsh_debug_sv.pop(l_module_name);
        END IF;

     WHEN OTHERS THEN
        resultout := 'COMPLETE:FAILURE';
        wsh_util_core.default_handler('WSH_TRANSACTIONS_UTIL.process_cbod_wf');
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,
             'Unexpected error has occured. Oracle error message is '||
              substr(SQLERRM,1,200), WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        RAISE;
  END process_cbod_wf;

END WSH_TRANSACTIONS_UTIL;

/
