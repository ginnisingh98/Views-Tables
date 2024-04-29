--------------------------------------------------------
--  DDL for Package Body WSH_EXTERNAL_INTERFACE_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_EXTERNAL_INTERFACE_SV" AS
/* $Header: WSHEXINB.pls 120.3.12010000.6 2010/02/25 15:26:22 sankarun ship $ */

/*===========================================================================
|                                                                           |
| PROCEDURE NAME   Is_FTE_Installed                                         |
|                                                                           |
| DESCRIPTION	    This procedure checks if FTE is installed or not.        |
|                                                                           |
|                                                                           |
| MODIFICATION HISTORY                                                      |
|                                                                           |
|	02/20/02      Vijay Nandula   Created                                    |
|                                                                           |
============================================================================*/

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_EXTERNAL_INTERFACE_SV';
--


/*===========================================================================
|                                                                           |
| PROCEDURE NAME   Get_Warehouse_Type                                       |
|                                                                           |
| DESCRIPTION	    The procedure returns the warehouse type from the       |
|                  inventory tables.  Used to identify the instance is a    |
|                  a Third Party Warehouse or not.                          |
|                                                                           |
| MODIFICATION HISTORY                                                      |
|                                                                           |
|	02/20/02      Vijay Nandula   Created                               |
|                                                                           |
============================================================================*/

FUNCTION Get_Warehouse_Type ( p_organization_id   IN   NUMBER,
                              p_event_key         IN   VARCHAR2 DEFAULT NULL,
                              x_return_status     OUT NOCOPY   VARCHAR2,
			      p_delivery_id       IN   NUMBER DEFAULT NULL,
			      p_delivery_detail_id IN  NUMBER DEFAULT NULL,
                              p_carrier_id       IN   NUMBER DEFAULT NULL,
                              p_ship_method_code  IN VARCHAR2 DEFAULT NULL,
                              p_msg_display        IN  VARCHAR2 DEFAULT 'Y'
			    ) RETURN VARCHAR2
IS
cursor	wh_flag_cur IS
select	carrier_manifesting_flag,
	distributed_organization_flag
from	mtl_parameters
where	organization_id= p_organization_id;

cursor  valid_carrier_det_cur is
select  distinct wc.manifesting_enabled_flag
from    wsh_delivery_details wdd,
        wsh_carrier_services wcs,
        wsh_carriers wc,
        wsh_new_deliveries wnd,
        wsh_delivery_assignments_v wda
where   wdd.delivery_detail_id = p_delivery_detail_id
and     wdd.delivery_detail_id = wda.delivery_detail_id(+)
and     wda.delivery_id = wnd.delivery_id(+)
and     ( nvl(wnd.ship_method_code,wdd.ship_method_code) = wcs.ship_method_code
        or nvl(wnd.carrier_id,wdd.carrier_id) = wcs.carrier_id
        )
and     wcs.carrier_id  = wc.carrier_id;

cursor  valid_carrier_del_cur is
select  distinct wc.manifesting_enabled_flag
from	wsh_new_deliveries wnd,
        wsh_carrier_services wcs,
        wsh_carriers wc
where   wnd.delivery_id = p_delivery_id
and     (  wnd.ship_method_code = wcs.ship_method_code
	or wnd.carrier_id = wcs.carrier_id
	)
and     wcs.carrier_id  = wc.carrier_id;

cursor  c_valid_carrier is
select  distinct wc.manifesting_enabled_flag
from    wsh_carrier_services wcs,
        wsh_carriers wc
where   wcs.carrier_id=p_carrier_id
and     wcs.carrier_id  = wc.carrier_id;

cursor  c_valid_smc is
select  distinct wc.manifesting_enabled_flag
from    wsh_carrier_services wcs,
        wsh_carriers wc
where   wcs.ship_method_code = p_ship_method_code
and     wcs.carrier_id  = wc.carrier_id;

l_warehouse_type VARCHAR2 (3);
l_tpw_flag       VARCHAR2 (1);
l_cms_flag       VARCHAR2 (1);
l_manifest_enabled_flag       VARCHAR2 (1);
l_entity_name VARCHAR2 (100);
l_entity_id NUMBER;
l_otm_enabled_flag VARCHAR2 (1):= 'N';
wsh_org_event_key_null EXCEPTION;
wsh_ship_param_failed EXCEPTION;
l_shipping_param_info  WSH_SHIPPING_PARAMS_PVT.Parameter_Rec_Typ;
--
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_WAREHOUSE_TYPE';
l_otm_installed    VARCHAR2(1) ;
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
      wsh_debug_sv.push(l_module_name,'Get_Warehouse_Type');
      wsh_debug_sv.log (l_module_name,'Event Key', p_event_key);
      wsh_debug_sv.log (l_module_name,'Organization id', p_organization_id);
      wsh_debug_sv.log (l_module_name,'Delivery Id', p_delivery_id);
      wsh_debug_sv.log (l_module_name,'Delivery Detail Id', p_delivery_detail_id);
      wsh_debug_sv.log (l_module_name,'Carrier Id', p_carrier_id);
      wsh_debug_sv.log (l_module_name,'Ship Method Code', p_ship_method_code);
  END IF;

      --R12.1.1 STANDALONE PROJECT
      IF (WMS_DEPLOY.WMS_DEPLOYMENT_MODE = 'D') THEN
         -- Turn Off Distributed and CMS Modes if Standalone Mode is Set
         l_warehouse_type := NULL;

      ELSIF (p_event_key IS NOT NULL) THEN
        IF l_debug_on THEN
         wsh_debug_sv.log (l_module_name,'Event Key Not null', p_event_key);
        END IF;

         l_warehouse_type := SUBSTRB (p_event_key, 1, 3);
      ELSIF ( p_organization_id IS NULL ) THEN
           RAISE wsh_org_event_key_null;
      ELSE --{
     --bugfix 7190832
     l_otm_installed := WSH_UTIL_CORE.GC3_Is_Installed;
     --
     IF l_otm_installed = 'Y' THEN

      WSH_SHIPPING_PARAMS_PVT.Get(
             p_organization_id => p_organization_id,
             x_param_info      => l_shipping_param_info,
             x_return_status   => x_return_status);

       l_otm_enabled_flag := l_shipping_param_info.otm_enabled;

      IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'After call to WSH_SHIPPING_PARAMS_PVT.Get x_return_status ',x_return_status);
       WSH_DEBUG_SV.log(l_module_name,'l_shipping_param_info.otm_enabled',l_shipping_param_info.otm_enabled);
     END IF;
     --
     IF (x_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
       Raise wsh_ship_param_failed;
     END IF;
     --
     l_warehouse_type := NULL;
     END IF ;
     -- bugfix 7190832
     IF nvl(l_otm_enabled_flag,'!') = 'N' THEN

         OPEN  wh_flag_cur;
         FETCH wh_flag_cur INTO l_cms_flag, l_tpw_flag;
         CLOSE wh_flag_cur;
        IF l_debug_on THEN
         wsh_debug_sv.log (l_module_name,'TPW Flag', l_tpw_flag);
         wsh_debug_sv.log (l_module_name,'CMS Flag', l_cms_flag);
        END IF;
         IF ( NVL (l_tpw_flag, '!') = 'Y' ) THEN
            l_warehouse_type := 'TPW';
	     -- TPW - Distributed Organization Changes
 	     IF (FND_PROFILE.VALUE('WSH_SR_SOURCE') = 'B') THEN
 	            l_warehouse_type := 'TW2';
 	            IF l_debug_on THEN
 	                 wsh_debug_sv.log (l_module_name,'TW2 Flag', 'Y');
 	            END IF;
 	     END IF;
         ELSIF ( NVL (l_cms_flag, '!') = 'Y' ) THEN
           IF ( p_delivery_id IS NOT NULL ) THEN
		l_entity_name := 'Delivery';
		l_entity_id := p_delivery_id;
		open valid_carrier_del_cur;
		fetch valid_carrier_del_cur into l_manifest_enabled_flag;
		close valid_carrier_del_cur;
	    ELSIF ( p_delivery_detail_id IS NOT NULL ) THEN
		l_entity_name := 'Delivery Line';
		l_entity_id := p_delivery_detail_id;
		open valid_carrier_det_cur;
		fetch valid_carrier_det_cur into l_manifest_enabled_flag;
		close valid_carrier_det_cur;
            ELSIF (p_carrier_id is NOT NULL) THEN
                FOR cur IN c_valid_carrier LOOP
                  l_manifest_enabled_flag:=cur.manifesting_enabled_flag;
                END LOOP;
            ELSIF (p_ship_method_code is NOT NULL) THEN
                FOR cur IN c_valid_smc LOOP
                  l_manifest_enabled_flag:=cur.manifesting_enabled_flag;
                END LOOP;
            ELSE
               -- TPW - Distributed changes
               l_manifest_enabled_flag := 'Y';
	    END IF;

           IF l_debug_on THEN
            wsh_debug_sv.log (l_module_name,'Manifest Enabled Flag', l_manifest_enabled_flag);
           END IF;

	    IF ( nvl( l_manifest_enabled_flag, '!') = 'Y' ) THEN
               l_warehouse_type := 'CMS';
	    ELSE
               l_warehouse_type := NULL;
               IF (p_msg_display = 'Y' ) THEN
	            FND_MESSAGE.Set_Name('WSH', 'WSH_CARR_NOT_MANIFEST_ENABLED');
	            FND_MESSAGE.Set_Token('ENTITY_NAME', l_entity_name);
	            FND_MESSAGE.Set_Token('ENTITY_ID', l_entity_id);
                    WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
               END IF;
	    END IF;
	   END IF ;
         ELSE
            l_warehouse_type := NULL;
         END IF;
      END IF; --}

      x_return_status := WSH_UTIL_CORE.g_ret_sts_success;

      IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name, 'Warehouse Type' , l_warehouse_type);
       wsh_debug_sv.pop (l_module_name);
      END IF;

      RETURN l_warehouse_type;
   EXCEPTION
      WHEN wsh_org_event_key_null THEN
         x_return_status := WSH_UTIL_CORE.g_ret_sts_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'wsh_org_event_key_null exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_org_event_key_null');
         END IF;
         RETURN l_warehouse_type;
      WHEN wsh_ship_param_failed THEN
        x_return_status := WSH_UTIL_CORE.g_ret_sts_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'wsh_ship_param_failed exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_ship_param_failed');
         END IF;
         RETURN l_warehouse_type;

      WHEN OTHERS THEN
         x_return_status := WSH_UTIL_CORE.g_ret_sts_unexp_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
         RETURN l_warehouse_type;
   END Get_Warehouse_Type;


   /*===========================================================================
   |                                                                           |
   | PROCEDURE NAME   Raise_Event                                              |
   |                                                                           |
   | DESCRIPTION      This procedure raises an event in Work Flow.  It raises  |
   |                  an appropriate procedure depending on the parameters     |
   |                  passed.                                                  |
   |                                                                           |
   | MODIFICATION HISTORY                                                      |
   |                                                                           |
   |	02/20/02      Vijay Nandula   Created                                  |
   |                                                                           |
   ============================================================================*/

   PROCEDURE Raise_Event ( P_txn_hist_record   IN     WSH_TRANSACTIONS_HISTORY_PKG.Txns_History_Record_Type,
                           P_Cbod_Status       IN     VARCHAR2,
                           x_return_status     IN OUT NOCOPY  VARCHAR2)
   IS
      l_event_name VARCHAR2 (120);
      l_Event_Key  VARCHAR2 (30);

      l_Return_Status    VARCHAR2 (1);
      l_Transaction_Code VARCHAR2 (100);
      l_Org_ID           NUMBER;
      l_Party_Site_ID    NUMBER;
      l_txns_id          NUMBER;

      l_msg_parameter_list  WF_PARAMETER_LIST_T;
      l_cbod_parameter_list WF_PARAMETER_LIST_T;
      l_txn_hist_record WSH_TRANSACTIONS_HISTORY_PKG.Txns_History_Record_Type;
      -- LSP PROJECT : Added client_id
      CURSOR l_new_del_cur (l_name VARCHAR2) IS
      SELECT Nvl(mcp.trading_partner_site_id, wnd.Initial_Pickup_Location_ID) Tranding_partner_site_id,
	         wnd.ultimate_dropoff_location_id, 	--Notification change heali
             wnd.customer_id,			--Notification change heali
             wnd.client_id
      FROM   wsh_new_deliveries wnd,
             mtl_client_parameters_v mcp
      WHERE  wnd.Name = l_name
      AND    wnd.client_id = mcp.client_id (+);
      -- LSP PROJECT : end

      --Notification change heali
      CURSOR get_location(p_location_id NUMBER) IS
        SELECT  ui_location_code
        FROM    wsh_locations
        WHERE  wsh_location_id=p_location_id;

      CURSOR get_customer_name(p_customer_id NUMBER) IS
        SELECT HP.PARTY_NAME
        FROM   HZ_CUST_ACCOUNTS HCA, HZ_PARTIES HP
        WHERE  HP.PARTY_ID = HCA.PARTY_ID
        AND    HP.PARTY_ID = p_customer_id;

      l_del_name 		varchar2(240);
      l_sf_location 		varchar2(240);
      l_customer 		varchar2(240);
      l_st_location 		varchar2(240);
      l_subject			varchar2(240);
      l_ship_to_location_id	number;
      l_customer_id		number;
      --Notification change heali
      --R12.1.1 STANDALONE PROJECT
      l_wms_deployment_mode     varchar2(1);
      l_client_id               NUMBER; -- LSP PROJECT

      wsh_invalid_event_name  EXCEPTION;
      wsh_get_event_key_error EXCEPTION;
      wsh_invalid_delivery_no EXCEPTION;
      wsh_update_history      EXCEPTION;
      --
l_debug_on BOOLEAN;
      --
      l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'RAISE_EVENT';
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
      WSH_DEBUG_SV.log(l_module_name,'transaction_id',P_txn_hist_record.transaction_id);
      WSH_DEBUG_SV.log(l_module_name,'document_type',P_txn_hist_record.document_type);
      WSH_DEBUG_SV.log(l_module_name,'document_direction',P_txn_hist_record.document_direction);
      WSH_DEBUG_SV.log(l_module_name,'document_number',P_txn_hist_record.document_number);
      WSH_DEBUG_SV.log(l_module_name,'orig_document_number',P_txn_hist_record.orig_document_number);
      WSH_DEBUG_SV.log(l_module_name,'entity_number',P_txn_hist_record.entity_number);
      WSH_DEBUG_SV.log(l_module_name,'entity_type',P_txn_hist_record.entity_type);
      WSH_DEBUG_SV.log(l_module_name,'trading_partner_id',P_txn_hist_record.trading_partner_id);
      WSH_DEBUG_SV.log(l_module_name,'action_type',P_txn_hist_record.action_type);
      WSH_DEBUG_SV.log(l_module_name,'transaction_status',P_txn_hist_record.transaction_status);
      WSH_DEBUG_SV.log(l_module_name,'ecx_message_id',P_txn_hist_record.ecx_message_id);
      WSH_DEBUG_SV.log(l_module_name,'event_name',P_txn_hist_record.event_name);
      WSH_DEBUG_SV.log(l_module_name,'event_key',P_txn_hist_record.event_key);
      WSH_DEBUG_SV.log(l_module_name,'item_type',P_txn_hist_record.item_type);
      WSH_DEBUG_SV.log(l_module_name,'internal_control_number',P_txn_hist_record.internal_control_number);
      WSH_DEBUG_SV.log(l_module_name,'client_code',P_txn_hist_record.client_code);
     END IF;
      x_return_status := WSH_UTIL_CORE.g_ret_sts_success;

      l_txn_hist_record := P_txn_hist_record;

      -- Get the event name from the Transaction History Table.
      l_event_name := l_txn_hist_record.Event_Name;

      -- Check if the event name is valid or not.

      IF ( l_event_name NOT IN ('oracle.apps.wsh.sup.ssro',
                                'oracle.apps.wsh.sup.ssai',
                                'oracle.apps.wsh.tpw.ssri',
                                'oracle.apps.wsh.tpw.ssao',
                                'oracle.apps.wsh.tpw.spwf',
                                'oracle.apps.wsh.tpw.scbod',
                                --R12.1.1 STANDALONE PROJECT
                                'oracle.apps.wsh.standalone.ssri',
                                'oracle.apps.wsh.standalone.ssao',
                                'oracle.apps.wsh.standalone.scbod',
                                'oracle.apps.wsh.standalone.spwf',
                                'ORACLE.APPS.FTE.SSNO.CONFIRM') ) THEN
         RAISE wsh_invalid_event_name;
      END IF;

      -- Transaction Code is the last 4 or 5 letters after the dot from the Event Name.
      -- Eg:  'SSRO', 'SSAI' etc
      l_Transaction_Code := UPPER (SUBSTRB (l_event_name, INSTRB(l_Event_Name, '.', -1) + 1));

     IF l_debug_on THEN
      wsh_debug_sv.log (l_module_name, 'Transaction Code' , l_Transaction_Code);
     END IF;

      -- Get the Event Key for Raising an Event.
      --bmos k proj
      IF ( l_txn_hist_record.Event_Key IS NULL ) THEN
         WSH_TRANSACTIONS_UTIL.Get_Event_Key ( l_txn_hist_record.Item_Type,
                                               l_txn_hist_record.Orig_Document_Number,
                                               l_txn_hist_record.Trading_Partner_ID,
                                               l_txn_hist_record.Event_Name,
                                               l_txn_hist_record.entity_number,
                                               l_Event_Key,
                                               l_Return_Status );

        IF l_debug_on THEN
         wsh_debug_sv.log (l_module_name, 'Return status after get_event_key' , l_Return_Status);
        END IF;

         IF ( l_Return_Status <> WSH_UTIL_CORE.g_ret_sts_success ) THEN
            RAISE wsh_get_event_key_error;
         END IF;
         -- Assign the value to the Transaction History record.
         l_txn_hist_record.Event_Key := l_Event_Key;
      ELSE
         l_Event_Key := l_txn_hist_record.Event_Key;
      END IF;

      --R12.1.1 STANDALONE PROJECT
      l_wms_deployment_mode := WMS_DEPLOY.WMS_DEPLOYMENT_MODE;

       IF l_debug_on THEN
        wsh_debug_sv.log (l_module_name, 'Event Key' , l_Event_Key);
        wsh_debug_sv.log (l_module_name, 'Trading partner ID ' , l_txn_hist_record.Trading_Partner_ID);
        wsh_debug_sv.log (l_module_name, 'Entity Number ' , l_txn_hist_record.Entity_Number);
        wsh_debug_sv.log (l_module_name, 'WMS Deployment Mode ' , l_wms_deployment_mode);
       END IF;

      l_client_id := NULL; -- LSP PROJECT
      IF ( l_Transaction_Code IN ('SSRO', 'SSAO') ) THEN --{
        -- LSP PROJECT : Changed the cursor here.
        --OPEN  l_New_Del_Cur (l_txn_hist_record.Trading_Partner_ID, l_txn_hist_record.entity_number);
        OPEN  l_New_Del_Cur (l_txn_hist_record.entity_number);
        FETCH l_New_Del_Cur INTO l_Party_Site_ID,l_ship_to_location_id,l_customer_id,l_client_id;
        IF ( l_New_Del_Cur % NOTFOUND ) THEN
           CLOSE l_New_Del_Cur;
           RAISE wsh_invalid_delivery_no;
        END IF;
        CLOSE l_New_Del_Cur;
        IF l_debug_on THEN
          wsh_debug_sv.log (l_module_name, 'Client_id ', l_client_id);
          wsh_debug_sv.log (l_module_name, 'Party Site ID ', l_Party_Site_ID);
        END IF;

      END IF; --}

      IF ( l_Transaction_Code in ('SSRO', 'SSAO') ) THEN --{
         -- Generate the document number for outgoing documents.
         SELECT WSH_DOCUMENT_NUMBER_S.NEXTVAL
         INTO   l_txn_hist_record.Document_Number
         FROM   dual;
      END IF; --}


      IF ( l_Transaction_Code IN ('SSRO', 'SSAO') ) THEN --{
         -- LSP PROJECT : For LSP mode send party type as 'C' (Customer)
         IF (l_wms_deployment_mode = 'L' AND l_client_id IS NOT NULL) THEN
           WF_EVENT.AddParameterToList (p_name  => 'ECX_PARTY_ID',
                                        p_value => l_txn_hist_record.Trading_Partner_ID, -- LSP PROJECT Commented.
                                        p_parameterlist => l_msg_parameter_list);
           WF_EVENT.AddParameterToList (p_name  => 'ECX_PARTY_TYPE',
                                        p_value => 'C',
                                        p_parameterlist => l_msg_parameter_list);
         ELSE
           WF_EVENT.AddParameterToList (p_name  => 'ECX_PARTY_ID',
                                        p_value => l_Party_Site_ID,
                                        p_parameterlist => l_msg_parameter_list);
           WF_EVENT.AddParameterToList (p_name  => 'ECX_PARTY_TYPE',
                                        p_value => 'I',
                                        p_parameterlist => l_msg_parameter_list);
         END IF;
         -- LSP PROJECT : end
         WF_EVENT.AddParameterToList (p_name  => 'ECX_PARTY_SITE_ID',
                                      p_value => l_Party_Site_ID,
                                      p_parameterlist => l_msg_parameter_list);

         WF_EVENT.AddParameterToList (p_name  => 'ECX_DOCUMENT_ID',
                                      p_value => l_txn_hist_record.Document_Number,
                                      p_parameterlist => l_msg_parameter_list);

         WF_EVENT.AddParameterToList (p_name  => 'USER_ID',
                               p_value => FND_GLOBAL.USER_ID,
                               p_parameterlist => l_msg_parameter_list);
         --
         WF_EVENT.AddParameterToList (p_name  => 'APPLICATION_ID',
                               p_value => FND_GLOBAL.RESP_APPL_ID,
                               p_parameterlist => l_msg_parameter_list);
         --
         WF_EVENT.AddParameterToList (p_name  => 'RESPONSIBILITY_ID',
                               p_value => FND_GLOBAL.RESP_ID,
                               p_parameterlist => l_msg_parameter_list);

         IF ( l_txn_hist_record.document_type = 'SR' ) THEN --{
            WF_EVENT.AddParameterToList (p_name  => 'ECX_TRANSACTION_TYPE',
                                         p_value => 'FTE',
                                         p_parameterlist => l_msg_parameter_list);

            --Notification change heali
            l_del_name:= l_txn_hist_record.entity_number;

            IF (instrb(l_Event_Key,'TPW') <> 0 ) THEN --{
               IF (p_txn_hist_record.action_type='A' ) THEN
                  FND_MESSAGE.SET_NAME('WSH', 'WSH_SR_TPW_NOTIFY');
                  FND_MESSAGE.SET_TOKEN('DEL_NAME', l_del_name);
                  l_subject := FND_MESSAGE.get;
               ELSE
                  FND_MESSAGE.SET_NAME('WSH', 'WSH_SRC_TPW_NOTIFY');
                  FND_MESSAGE.SET_TOKEN('DEL_NAME', l_del_name);
                  l_subject := FND_MESSAGE.get;
               END IF;
            ELSIF (instrb(l_Event_Key,'CMS') <> 0) THEN --}{
               IF (p_txn_hist_record.action_type='A' ) THEN
                  FND_MESSAGE.SET_NAME('WSH', 'WSH_SR_CMS_NOTIFY');
                  FND_MESSAGE.SET_TOKEN('DEL_NAME', l_del_name);
                  l_subject := FND_MESSAGE.get;
               ELSE
                  FND_MESSAGE.SET_NAME('WSH', 'WSH_SRC_CMS_NOTIFY');
                  FND_MESSAGE.SET_TOKEN('DEL_NAME', l_del_name);
                  l_subject := FND_MESSAGE.get;
               END IF;
            END IF; --}

            IF l_debug_on THEN
              wsh_debug_sv.log (l_module_name, 'l_subject' , l_subject);
            END IF;

            WF_EVENT.AddParameterToList (p_name  => 'SUBJECT',
                                         p_value => l_subject,
                                         p_parameterlist => l_msg_parameter_list);


            IF (wf_core.translate('WF_HEADER_ATTR') = 'Y' ) THEN --{

               OPEN get_location(l_Party_Site_ID);
               FETCH get_location INTO l_sf_location;
               CLOSE get_location;

               OPEN get_location(l_ship_to_location_id);
               FETCH get_location INTO l_st_location;
               CLOSE get_location;

               OPEN get_customer_name(l_customer_id);
               FETCH get_customer_name INTO l_customer;
               CLOSE get_customer_name;

               IF l_debug_on THEN
                 wsh_debug_sv.log (l_module_name, 'l_del_name' ,l_del_name );
                 wsh_debug_sv.log (l_module_name, 'l_sf_location' ,l_sf_location );
                 wsh_debug_sv.log (l_module_name, 'l_customer' ,l_customer );
                 wsh_debug_sv.log (l_module_name, 'l_st_location' ,l_st_location);
               END IF;

               WF_EVENT.AddParameterToList (p_name  => 'DEL_NAME',
                                            p_value => l_del_name,
                                            p_parameterlist => l_msg_parameter_list);

               WF_EVENT.AddParameterToList (p_name  => 'SF_LOCATION',
                                            p_value => l_sf_location,
                                            p_parameterlist => l_msg_parameter_list);

               WF_EVENT.AddParameterToList (p_name  => 'CUSTOMER',
                                            p_value => l_customer,
                                            p_parameterlist => l_msg_parameter_list);

               WF_EVENT.AddParameterToList (p_name  => 'ST_LOCATION',
                                            p_value => l_st_location,
                                            p_parameterlist => l_msg_parameter_list);
            END IF; --}
            --Notification change heali

         ELSE --}{
            WF_EVENT.AddParameterToList (p_name  => 'ECX_TRANSACTION_TYPE',
                                         p_value => 'WSH',
                                         p_parameterlist => l_msg_parameter_list);
         END IF; --}

         --R12.1.1 STANDALONE PROJECT
         -- LSP PROJECT : For LSP pass transation sub type as SSNO-LSP
         IF (l_wms_deployment_mode = 'L' AND l_client_id IS NOT NULL) THEN
            WF_EVENT.AddParameterToList (p_name  => 'ECX_TRANSACTION_SUBTYPE',
                                         p_value => 'SSNO-LSP',
                                         p_parameterlist => l_msg_parameter_list);
         ELSIF (l_wms_deployment_mode = 'D') THEN
            WF_EVENT.AddParameterToList (p_name  => 'ECX_TRANSACTION_SUBTYPE',
                                         p_value => 'SSNO-STND',
                                         p_parameterlist => l_msg_parameter_list);
         ELSE
            WF_EVENT.AddParameterToList (p_name  => 'ECX_TRANSACTION_SUBTYPE',
                                         p_value => 'SSNO',
                                         p_parameterlist => l_msg_parameter_list);
         END IF;

         WF_EVENT.AddParameterToList (p_name  => 'USER',
                                      p_value => FND_GLOBAL.user_name,
                                      p_parameterlist => l_msg_parameter_list);
         WF_EVENT.AddParameterToList (p_name  => 'ECX_PARAMETER1',
                                      p_value => l_txn_hist_record.Action_Type,
                                      p_parameterlist => l_msg_parameter_list);
      ELSIF ( l_Transaction_Code = 'SCBOD' ) THEN --}
         WF_EVENT.AddParameterToList (p_name  => 'ECX_TRANSACTION_TYPE',
                                      p_value => 'ECX',
                                      p_parameterlist => l_Cbod_parameter_list);
         WF_EVENT.AddParameterToList (p_name  => 'ECX_TRANSACTION_SUBTYPE',
                                      p_value => 'CBODO',
                                      p_parameterlist => l_Cbod_parameter_list);
         WF_EVENT.AddParameterToList (p_name  => 'ECX_DOCUMENT_ID',
                                      p_value => l_txn_hist_record.Internal_Control_Number,
                                      p_parameterlist => l_Cbod_parameter_list);

         -- LSP PROJECT : For LSP mode send party type as 'C' (Customer)
         IF (l_wms_deployment_mode = 'L' OR l_txn_hist_record.client_code IS NOT NULL) THEN
           WF_EVENT.AddParameterToList (p_name  => 'ECX_PARTY_TYPE',
                                      p_value => 'C',
                                      p_parameterlist => l_Cbod_parameter_list);
         ELSE
           WF_EVENT.AddParameterToList (p_name  => 'ECX_PARTY_TYPE',
                                      p_value => 'I',
                                      p_parameterlist => l_Cbod_parameter_list);
         END IF;
         WF_EVENT.AddParameterToList (p_name  => 'CONFIRM_STATUSLVL',
                                      p_value => P_Cbod_Status,
                                      p_parameterlist => l_Cbod_parameter_list);
      ELSIF ( l_Transaction_Code = 'CONFIRM' ) THEN
         WF_EVENT.AddParameterToList (p_name => 'PARAMETER6',
                                      p_value => P_Cbod_Status,
                                      p_parameterlist => l_Cbod_parameter_list);
      END IF;

      --R12.1.1 STANDALONE PROJECT
      IF ( l_event_name NOT IN  ('oracle.apps.wsh.tpw.scbod' ,'ORACLE.APPS.FTE.SSNO.CONFIRM','oracle.apps.wsh.tpw.spwf', 'oracle.apps.wsh.standalone.scbod', 'oracle.apps.wsh.standalone.spwf')) THEN

         WSH_TRANSACTIONS_HISTORY_PKG.Create_Update_Txns_History ( l_txn_hist_record,
                                                                   l_txns_id,
                                                                   l_return_status );

        IF l_debug_on THEN
         wsh_debug_sv.log (l_module_name, 'Transaction History return status ' , l_Return_Status);
         wsh_debug_sv.log (l_module_name, 'Transaction History ID' , l_txns_id);
        END IF;

         IF ( l_Return_Status <> WSH_UTIL_CORE.g_ret_sts_success ) THEN
            RAISE wsh_update_history;
         END IF;
         -- Commit the data into the Transaction History table for the views.
         COMMIT;
      END IF;

      IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name, 'Before Raising Event');
      END IF;

      IF ( l_Transaction_Code IN ('SSRO', 'SSAO') ) THEN
         WF_EVENT.raise ( p_event_name => l_event_name,
                          p_event_key  => l_Event_Key,
                          p_parameters => l_msg_parameter_list );
      ELSIF ( l_Transaction_Code IN ('SCBOD', 'CONFIRM') ) THEN
         WF_EVENT.raise ( p_event_name => l_event_name,
                          p_event_key  => l_Event_Key,
                          p_parameters => l_Cbod_parameter_list );
      ELSE
         WF_EVENT.raise ( p_event_name => l_event_name,
                          p_event_key  => l_Event_Key );
      END IF;

      IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name, 'End of Raising Event');
       wsh_debug_sv.pop(l_module_name);
      END IF;
   EXCEPTION
      WHEN wsh_invalid_event_name THEN
         x_return_status := WSH_UTIL_CORE.g_ret_sts_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'wsh_invalid_event_name exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_invalid_event_name');
         END IF;

      WHEN wsh_get_event_key_error THEN
         x_return_status := WSH_UTIL_CORE.g_ret_sts_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'wsh_get_event_key_error exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_get_event_key_error');
         END IF;

      WHEN wsh_invalid_delivery_no THEN
         x_return_status := WSH_UTIL_CORE.g_ret_sts_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'wsh_invalid_delivery_no exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_invalid_delivery_no');
         END IF;

      WHEN wsh_update_history THEN
         x_return_status := WSH_UTIL_CORE.g_ret_sts_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'wsh_update_history exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_update_history');
         END IF;

      WHEN OTHERS THEN
         x_return_status := WSH_UTIL_CORE.g_ret_sts_unexp_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
   END Raise_Event;


PROCEDURE Validate_Item (    p_concatenated_segments IN VARCHAR2,
                             p_organization_id IN NUMBER,
                             x_inventory_item_id OUT NOCOPY  VARCHAR2,
                             x_return_status OUT NOCOPY  VARCHAR2
                           )

IS
cursor	get_item_id_cur is
select	inventory_item_id
from	mtl_system_items_kfv
where	concatenated_segments = p_concatenated_segments
and	organization_id = p_organization_id;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_ITEM';
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
  wsh_debug_sv.log (l_module_name, 'Item Name ', p_concatenated_segments);
  wsh_debug_sv.log (l_module_name, 'Org Id  ', p_organization_id);
 END IF;

  IF ( p_concatenated_segments is not null and p_organization_id is not null ) THEN
     open get_item_id_cur;
     Fetch get_item_id_cur into x_inventory_item_id;

     IF get_item_id_cur%NOTFOUND THEN
        x_return_status := wsh_util_core.g_ret_sts_error;
     ELSE
        x_return_status := wsh_util_core.g_ret_sts_success;
     END IF;
     close get_item_id_cur;
  ELSE
     x_return_status := wsh_util_core.g_ret_sts_success;
  END IF;

 IF l_debug_on THEN
  wsh_debug_sv.pop (l_module_name);
 END IF;
EXCEPTION
	WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.g_ret_sts_unexp_error;
	IF get_item_id_cur%ISOPEN THEN
	   close get_item_id_cur;
	END IF;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
END Validate_Item;

PROCEDURE Validate_Ship_To ( p_customer_name IN VARCHAR2,
			     p_location IN VARCHAR2,
			     x_customer_id OUT NOCOPY  NUMBER,
			     x_location_id OUT NOCOPY  NUMBER,
			     x_return_status OUT NOCOPY  VARCHAR2,
			     p_site_use_code IN VARCHAR2 DEFAULT 'SHIP_TO',
			     x_site_use_id OUT NOCOPY  NUMBER,
                             p_org_id      IN NUMBER DEFAULT NULL
			   )
IS

-- Patchset I : Locations Project. kvenkate.
l_loc_rec       WSH_MAP_LOCATION_REGION_PKG.loc_rec_type;
l_location_id   NUMBER;
l_return_status VARCHAR2(1);

cursor	get_loc_id_cur is
SELECT  HL.LOCATION_ID,
	HCA.CUST_ACCOUNT_ID,
	HCSU.SITE_USE_ID
FROM	HZ_CUST_ACCOUNTS HCA,
	HZ_PARTIES HP,
        HZ_CUST_SITE_USES_ALL HCSU,
        HZ_CUST_ACCT_SITES_ALL HCAS,
--	ORG_ORGANIZATION_DEFINITIONS OOD,
        HZ_PARTY_SITES HPS,
        HZ_LOCATIONS HL
WHERE   HCSU.CUST_ACCT_SITE_ID          = HCAS.CUST_ACCT_SITE_ID
AND     HCAS.PARTY_SITE_ID              = HPS.PARTY_SITE_ID
AND     HCSU.SITE_USE_CODE              IN ( p_site_use_code, 'SHIP_TO')
AND     HCSU.STATUS                     = 'A'
--AND 	HCAS.ORG_ID			= HCSU.ORG_ID
--AND	HCSU.ORG_ID			= OOD.OPERATING_UNIT
--AND	OOD.ORGANIZATION_ID		= p_organization_id
AND     HPS.LOCATION_ID                 = HL.LOCATION_ID
AND     HCSU.LOCATION                   = p_location
AND	HCAS.CUST_ACCOUNT_ID	  	= HCA.CUST_ACCOUNT_ID
AND     HP.PARTY_ID			= HCA.PARTY_ID
AND    HCAS.ORG_ID            = NVL(p_org_id , HCAS.ORG_ID)
AND 	HP.PARTY_NAME			= p_customer_name
; --bmso

--bug 3920178 {
--use related customer's location
CURSOR c_rel_cust_loc_cur IS
     SELECT HPS.LOCATION_ID,
             HCA.CUST_ACCOUNT_ID,
             HCSU.SITE_USE_ID
      FROM   HZ_CUST_SITE_USES_ALL HCSU,
             HZ_CUST_ACCT_SITES_ALL HCAS,
             HZ_PARTY_SITES HPS,
             HZ_CUST_ACCOUNTS HCA,
           HZ_CUST_ACCT_RELATE_ALL HCAR,
             HZ_PARTIES HP
      WHERE  HCSU.CUST_ACCT_SITE_ID = HCAS.CUST_ACCT_SITE_ID
      AND    HCAS.PARTY_SITE_ID     = HPS.PARTY_SITE_ID
      AND    HCAS.CUST_ACCOUNT_ID   = HCAR.CUST_ACCOUNT_ID
      AND    HCSU.SITE_USE_CODE     IN (p_site_use_code, 'SHIP_TO')
      AND    HCSU.STATUS            = 'A'
      AND    HCAS.STATUS            = 'A'
      AND    HCA.STATUS             = 'A'
      AND    HCSU.location          =  p_location
      AND    HCA.CUST_ACCOUNT_ID    = HCAR.RELATED_CUST_ACCOUNT_ID
      AND    HCAR.SHIP_TO_FLAG      = 'Y'
      AND    NVL(HCAS.ORG_ID, -999) = NVL(HCSU.ORG_ID , -999)
      AND    HCAS.ORG_ID            = NVL(p_org_id , HCAS.ORG_ID)
      AND     HP.PARTY_ID    = HCA.PARTY_ID
      AND     HP.PARTY_NAME  = p_customer_name;

--bug 3920178 }


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_SHIP_TO';
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
  wsh_debug_sv.push(l_module_name, 'Validate_Ship_To');
  wsh_debug_sv.log (l_module_name, 'Customer Name ', p_customer_name);
  wsh_debug_sv.log (l_module_name, 'Location  ', p_location);
  wsh_debug_sv.log (l_module_name, 'Site Use Code  ', p_site_use_code);
  wsh_debug_sv.log (l_module_name, 'operating unit  ', p_org_id);
 END IF;

  IF ( p_customer_name is not null and p_location is not null ) THEN
       IF l_debug_on THEN
          wsh_debug_sv.logmsg(l_module_name, 'Using get_loc_id_cur');
       END IF;
     open get_loc_id_cur;
     Fetch get_loc_id_cur into l_location_id, x_customer_id, x_site_use_id;

     IF get_loc_id_cur%NOTFOUND THEN
     --{ bug 3920178 begin
       IF l_debug_on THEN
          wsh_debug_sv.logmsg(l_module_name, 'Using c_rel_cust_loc_cur');
       END IF;
       OPEN c_rel_cust_loc_cur;
       FETCH c_rel_cust_loc_cur INTO l_location_id, x_customer_id, x_site_use_id;

       IF c_rel_cust_loc_cur%NOTFOUND THEN
          l_location_id := NULL;
       END IF;

       close c_rel_cust_loc_cur;
     --}
     END IF;
     close get_loc_id_cur;

     IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name, 'l_location_id', l_location_id);
     END IF;

     IF l_location_id IS NULL THEN
--bug 3920178 end
        raise fnd_api.g_exc_error;
     ELSE --{
        -- Patchset I : Locations Project. kvenkate.
        -- Call Transfer Location API

        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_MAP_LOCATION_REGION_PKG.TRANSFER_LOCATION',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        WSH_MAP_LOCATION_REGION_PKG.Transfer_Location(
            p_source_type           => 'HZ',
            p_source_location_id    => l_location_id,
            p_online_region_mapping => FALSE,
            p_transfer_location     => TRUE,
            x_loc_rec               => l_loc_rec,
            x_return_status         => l_return_status);

        -- Success or Warning to be treated as success
        -- Since warning of transfer location not to be treated as invalid ship to
         IF l_return_status NOT IN(wsh_util_core.g_ret_sts_success, wsh_util_core.g_ret_sts_warning) THEN
            raise fnd_api.g_exc_error;
         END IF;
        x_location_id := l_loc_rec.WSH_LOCATION_ID;
        x_return_status := wsh_util_core.g_ret_sts_success;
     END IF; --}
     -- close get_loc_id_cur; bug 3920178
  ELSE
     x_return_status := wsh_util_core.g_ret_sts_success;
  END IF;

 IF l_debug_on THEN
  wsh_debug_sv.log(l_module_name, 'Location Id', x_location_id);
  wsh_debug_sv.log(l_module_name, 'Customer Id', x_customer_id);
  wsh_debug_sv.log(l_module_name, 'Site Use Id', x_site_use_id);
  wsh_debug_sv.pop (l_module_name);
 END IF;
EXCEPTION
        WHEN fnd_api.g_exc_error THEN
          x_return_status := wsh_util_core.g_ret_sts_error;
	IF get_loc_id_cur%ISOPEN THEN
	   close get_loc_id_cur;
	END IF;
           IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
           END IF;
	WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.g_ret_sts_unexp_error;
	IF get_loc_id_cur%ISOPEN THEN
	   close get_loc_id_cur;
	END IF;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;

END Validate_Ship_To;


END WSH_EXTERNAL_INTERFACE_SV;

/
