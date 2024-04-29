--------------------------------------------------------
--  DDL for Package Body WSH_TRANSACTIONS_FORM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_TRANSACTIONS_FORM_PKG" as
/* $Header: WSHINFMB.pls 120.2.12010000.4 2010/03/09 14:05:38 ueshanka ship $ */
--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_TRANSACTIONS_FORM_PKG';
--
PROCEDURE   process_wf_status( p_item_type        IN VARCHAR2,
                               p_event_key        IN VARCHAR2,
                               X_Return_Status    OUT NOCOPY  VARCHAR2)  IS


pragma AUTONOMOUS_TRANSACTION;

l_activity VARCHAR2(200);

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'process_wf_status';
--
BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
   wsh_debug_sv.push(l_module_name);
   wsh_debug_sv.log (l_module_name,'p_item_type',p_item_type);
   wsh_debug_sv.log (l_module_name,'p_event_key',p_event_key);
  END IF;

  x_return_status := wsh_util_core.g_ret_sts_success;

  IF (p_item_type = 'WSHTPWI' ) THEN
     l_activity := 'WSH_TPW_PROCESS_WF:POPULATE_BASE_TABLES';
  ELSIF (p_item_type = 'WSHSUPI' ) THEN
     l_activity := 'WSH_SUPPLIER_WF:WSH_PROCESS_DELIVERY';
  END IF;

  IF l_debug_on THEN
   wsh_debug_sv.log (l_module_name,'l_activity',l_activity);
  END IF;

  Savepoint l_wf_status;

  wf_engine.HandleError(
      itemtype => p_item_type,
      itemkey  => p_event_key,
      activity => l_activity,
      command  => 'SKIP',
      result   => 'SUCCESS'
  );

  COMMIT;

  IF l_debug_on THEN
   wsh_debug_sv.pop(l_module_name);
  END IF;

EXCEPTION
 WHEN OTHERS THEN
   Rollback to savepoint l_wf_status;
   X_return_Status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
   IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    wsh_debug_sv.stop_debug;
   END IF;
END process_wf_status;


/*=====================================================================================
PROCEDURE NAME : Process_form

This procedure looks at the Delivery ID , Trip id and Transaction Id and then call
Process_inbound  for further processing.
=======================================================================================*/

PROCEDURE   Process_form( P_delivery_id    IN NUMBER,
                          P_trip_id        IN NUMBER,
                          P_transaction_id IN NUMBER,
                          X_Return_Status    OUT NOCOPY  VARCHAR2)  IS


L_return_status          VARCHAR2(1);
l_wf_status            varchar2(40);
l_wf_result            varchar2(40);
l_result_code           varchar2(40);

WSH_FAILED_PROCESS     EXCEPTION;
-- LSP PROJECT : Get client_Code value for the given transactionId.
CURSOR history_cur IS
SELECT wth.document_type,wth.document_number,wth.orig_document_number,wth.document_direction,wth.transaction_status,wth.
       action_type,wth.entity_number,wth.entity_type,wth.trading_partner_id,wth.ecx_message_id,wth.
       event_name,wth.event_key,wth.internal_control_number,wth.item_type,wndi.client_code
FROM   WSH_TRANSACTIONS_HISTORY wth,
       WSH_NEW_DEL_INTERFACE wndi
WHERE  wth.transaction_id = P_transaction_id
AND    wth.entity_number = wndi.delivery_interface_id(+);

cursor c_get_status (v_trx_id NUMBER)
  IS select TRANSACTION_STATUS
  FROM wsh_transactions_history
  WHERE transaction_id = v_trx_id;

  l_trx_status      wsh_transactions_history.transaction_status%TYPE;
  -- TPW - Distribution Changes
  l_trns_history_rec      WSH_TRANSACTIONS_HISTORY_PKG.Txns_History_Record_Type;
  --R12.1.1 STANDALONE PROJECT
  l_wms_deploy_mode VARCHAR2(1);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PROCESS_FORM';
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
      WSH_DEBUG_SV.start_debug (P_transaction_id);
      wsh_debug_sv.push(l_module_name, 'PROCESS_FORM');
      wsh_debug_sv.log (l_module_name,'Transaction ID', P_Transaction_id);
      wsh_debug_sv.log (l_module_name,'DELIVERY ID', P_delivery_id);
   END IF;

   IF (P_transaction_id  IS NOT NULL ) THEN  --{
      -- R12.1.1 STANDALONE PROJECT
      l_wms_deploy_mode := WMS_DEPLOY.WMS_DEPLOYMENT_MODE;
      --
      IF l_debug_on THEN
         wsh_debug_sv.log (l_module_name,'l_wms_deploy_mode', l_wms_deploy_mode);
      END IF;
      --
      FOR history_rec in history_cur
      LOOP

         IF l_debug_on THEN
            wsh_debug_sv.log (l_module_name,'Document Number', history_rec.DOCUMENT_NUMBER);
            wsh_debug_sv.log (l_module_name,'transaction_status', history_rec.transaction_status);
            wsh_debug_sv.log (l_module_name,'document_type', history_rec.document_type);
            wsh_debug_sv.log (l_module_name,'client code',history_rec.client_code);
         END IF;

         -- TPW - Distribution Changes - Start
         -- Populate Txn History Record details into l_trns_history_rec variable,
         -- so that it can be passed to Process_Inbound API
         IF ( history_rec.document_type = 'SA' AND
              history_rec.item_type IS NULL AND
              history_rec.event_key IS NULL )
         THEN
            l_trns_history_rec.DOCUMENT_TYPE        := history_rec.DOCUMENT_TYPE;
            l_trns_history_rec.DOCUMENT_NUMBER      := history_rec.DOCUMENT_NUMBER;
            l_trns_history_rec.ORIG_DOCUMENT_NUMBER := history_rec.ORIG_DOCUMENT_NUMBER;
            l_trns_history_rec.DOCUMENT_DIRECTION   := history_rec.DOCUMENT_DIRECTION;
            l_trns_history_rec.TRANSACTION_STATUS   := history_rec.TRANSACTION_STATUS;
            l_trns_history_rec.ACTION_TYPE          := history_rec.ACTION_TYPE;
            l_trns_history_rec.ENTITY_NUMBER        := history_rec.ENTITY_NUMBER;
            l_trns_history_rec.ENTITY_TYPE          := history_rec.ENTITY_TYPE;
            l_trns_history_rec.TRADING_PARTNER_ID   := history_rec.TRADING_PARTNER_ID;
            l_trns_history_rec.ECX_MESSAGE_ID       := history_rec.ECX_MESSAGE_ID;
            l_trns_history_rec.EVENT_NAME           := history_rec.EVENT_NAME;
            l_trns_history_rec.EVENT_KEY            := history_rec.EVENT_KEY;
            l_trns_history_rec.ITEM_TYPE            := history_rec.ITEM_TYPE;
            l_trns_history_rec.INTERNAL_CONTROL_NUMBER := history_rec.INTERNAL_CONTROL_NUMBER;
         END IF;
         -- TPW - Distribution Changes - End

         --
         IF history_rec.transaction_status = 'ER'
         THEN --{
            IF history_rec.document_type = 'SR' THEN --{

               --R12.1.1 STANDALONE PROJECT
               IF (l_wms_deploy_mode = 'D' OR ( l_wms_deploy_mode = 'L' and history_rec.client_code IS NOT NULL)) THEN --{ LSP PROJECT : Consider LSP mode also

                  IF l_debug_on THEN
                   wsh_debug_sv.logmsg(l_module_name, 'Item Type: '||history_rec.item_type||' Event Key: '||history_rec.event_key);
                  END IF;
                  --
                  IF (history_rec.item_type is not null) and (history_rec.event_key is not null) THEN

                     IF l_debug_on THEN
                      wsh_debug_sv.logmsg(l_module_name, 'Calling wf_engine.handleError');
                     END IF;
                     wf_engine.handleError(
                              itemType => history_rec.item_type,
                              itemKey  => history_rec.event_key,
                              activity => 'WSH_STAND_PROCESS_WF:POPULATE_BASE_TABLES',
                              command  => 'RETRY',
                              result   => NULL
                            );
                  ELSE
                     --
                     IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIPMENT_REQUEST_PKG.Process_Shipment_Request', WSH_DEBUG_SV.C_PROC_LEVEL);
                     END IF;
                     --
                     WSH_SHIPMENT_REQUEST_PKG.Process_Shipment_Request(
                       p_commit_flag          => FND_API.G_TRUE,
                       p_transaction_status   => history_rec.transaction_status,
                       p_client_code          => null, -- LSP PROJECT
                       p_from_document_number => null,
                       p_to_document_number   => null,
                       p_from_creation_date   => null,
                       p_to_creation_date     => null,
                       p_transaction_id       => p_transaction_id,
                       x_return_status        => l_return_status);
                     --
                     IF l_debug_on THEN
                        wsh_debug_sv.log (l_module_name,'l_return_status', l_return_status);
                     END IF;
                     --
                  END IF;
                  --
               ELSE --} {
                  wf_engine.handleError(
                           itemType => history_rec.item_type,
                           itemKey  => history_rec.event_key,
                           activity => 'WSH_TPW_PROCESS_WF:POPULATE_BASE_TABLES',
                           command  => 'RETRY',
                           result   => NULL
                         );
               END IF; --}
            ELSE --}{
               -- TPW - Distribution Changes - Start
               -- Call WF API to process the SA data if its workflow driven otherwise call Process_Inbound API.
               IF (history_rec.item_type is not null) and (history_rec.event_key is not null) THEN
                  --
                  IF l_debug_on THEN
                     wsh_debug_sv.logmsg(l_module_name,
                        'Calling wf_engine.handleError');
                  END IF;
                  --
                  wf_engine.handleError(
                           itemType => history_rec.item_type,
                           itemKey  => history_rec.event_key,
                           activity => 'WSH_SUPPLIER_WF:WSH_PROCESS_DELIVERY',
                           command  => 'RETRY',
                           result   => NULL
                         );
               ELSE
                  --
                  IF l_debug_on THEN
                     wsh_debug_sv.logmsg(l_module_name, 'Calling WSH_PROCESS_INTERFACED_PKG.Process_Inbound');
                  END IF;
                  --
                  -- Call process inbound
                  WSH_PROCESS_INTERFACED_PKG.Process_Inbound(
                                             l_trns_history_rec => l_trns_history_rec,
                                             x_return_status    => l_return_status );

                  --
                  IF l_debug_on THEN
                     wsh_debug_sv.log (l_module_name,'Process_Inbound: l_return_status', l_return_status);
                  END IF;
                  --
               END IF;
               -- TPW - Distribution Changes - End
            END IF; --}
            --COMMIT; as per code review
         ELSIF history_rec.transaction_status = 'AP'
         THEN --}{
            --
            -- TPW - Distribution Changes
            -- Call Process_shipment_Request api if document type is SR
            IF history_rec.document_type = 'SR' AND
               ( l_wms_deploy_mode = 'D' OR ( l_wms_deploy_mode = 'L' and history_rec.client_code IS NOT NULL)) THEN --{ LSP PROJECT : Consider LSP mode also

               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIPMENT_REQUEST_PKG.Process_Shipment_Request', WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;

               WSH_SHIPMENT_REQUEST_PKG.Process_Shipment_Request(
                 p_commit_flag          => FND_API.G_TRUE,
                 p_transaction_status   => history_rec.transaction_status,
                 p_client_code          => null, -- LSP PROJECT
                 p_from_document_number => null,
                 p_to_document_number   => null,
                 p_from_creation_date   => null,
                 p_to_creation_date     => null,
                 p_transaction_id       => p_transaction_id,
                 x_return_status        => l_return_status);

               IF l_debug_on THEN
                  wsh_debug_sv.log (l_module_name,'l_return_status', l_return_status);
               END IF;

            -- TPW - Distribution Changes
            -- Call Process_Inbound api, if document type is SA and its NOT triggered from WF
            -- If Txn Status is 'AP' then SA process is NOT triggered from WF.
            -- } {
            ELSIF ( history_rec.document_type = 'SA' )
            THEN
               --
               IF l_debug_on THEN
                  wsh_debug_sv.logmsg(l_module_name, 'For Txn Status AP, Calling WSH_PROCESS_INTERFACED_PKG.Process_Inbound');
               END IF;
               --
               -- Call process inbound
               WSH_PROCESS_INTERFACED_PKG.Process_Inbound(
                                            l_trns_history_rec => l_trns_history_rec,
                                            x_return_status    => l_return_status );

               --
               IF l_debug_on THEN
                  wsh_debug_sv.log (l_module_name,'For Txn Status AP, Process_Inbound: l_return_status', l_return_status);
               END IF;
               --
            -- TPW - Distribution Changes
            -- Added Comments: Not sure why API wf_engine.completeActivity is invoked, since
            -- Txn History record populated from XML Gateway will be with Txn Status 'IP'
            ELSE --} {
               IF l_debug_on THEN
                  wsh_debug_sv.logmsg(l_module_name,
                       'Calling wf_engine.completeActivity');
               END IF;
               --
               wf_engine.completeActivity (
                          itemtype => history_rec.item_type,
                          itemkey  => history_rec.event_key,
                          activity => 'WSH_SUPPLIER_WF:CONTINUE_SHIPMENT_ADVICE',
                          result   => l_result_code);
               --COMMIT; as percode review
            END IF; --}
         END IF; --}

         --
         OPEN c_get_status(P_transaction_id);
         FETCH c_get_status INTO l_trx_status;
         CLOSE c_get_status;

         IF l_debug_on THEN
            wsh_debug_sv.log (l_module_name,'l_trx_status'
                                               , l_trx_status);
         END IF;

         IF l_trx_status <> 'SC' THEN
            RAISE WSH_FAILED_PROCESS;
         END IF;
      END LOOP;

      IF l_debug_on THEN
         wsh_debug_sv.log (l_module_name,'After loop');
      END IF;
   END IF; --}
   IF l_debug_on THEN
      wsh_debug_sv.pop(l_module_name);
      wsh_debug_sv.stop_debug;
   END IF;
EXCEPTION
   WHEN WSH_FAILED_PROCESS THEN
   x_return_status := wsh_util_core.g_ret_sts_error;
   FND_MESSAGE.Set_Name('WSH', 'WSH_FAILED_PROCESS');
   WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
   IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_FAILED_PROCESS exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_FAILED_PROCESS');
    wsh_debug_sv.stop_debug;
   END IF;

   WHEN OTHERS THEN
   X_return_Status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
   IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    wsh_debug_sv.stop_debug;
   END IF;
END process_form;
END WSH_TRANSACTIONS_FORM_PKG;

/
