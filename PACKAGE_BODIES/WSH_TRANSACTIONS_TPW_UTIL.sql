--------------------------------------------------------
--  DDL for Package Body WSH_TRANSACTIONS_TPW_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_TRANSACTIONS_TPW_UTIL" AS
/* $Header: WSHTXTPB.pls 120.1.12010000.3 2009/12/03 16:14:59 mvudugul ship $ */


   /*===========================================================================
   |                                                                           |
   | PROCEDURE NAME   Check_Cancel_Allowed_WF                                  |
   |                                                                           |
   | DESCRIPTION	    This procedure is called from the work flow to trigger   |
   |                  the procedure Check_Cancel_Allowed, which checks if the  |
   |                  cancellation for a transaction is allowed or not.        |
   |                                                                           |
   | MODIFICATION HISTORY                                                      |
   |                                                                           |
   |	02/18/02      Vijay Nandula   Created                                    |
   |                                                                           |
   ============================================================================*/

   --
   G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_TRANSACTIONS_TPW_UTIL';
   --
   PROCEDURE Check_Cancel_Allowed_WF ( P_item_type  IN    VARCHAR2,
                                       P_item_key   IN    VARCHAR2,
                                       P_actid      IN    NUMBER,
                                       P_funcmode   IN    VARCHAR2,
                                       X_resultout  OUT NOCOPY    VARCHAR2 )
   IS
      l_Return_Status  VARCHAR2(1);
      --
l_debug_on BOOLEAN;
      --
      l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_CANCEL_ALLOWED_WF';
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
      wsh_debug_sv.push(l_module_name, 'Check_Cancel_Allowed_WF');
      wsh_debug_sv.log(l_module_name, 'P_item_type',P_item_type);
      wsh_debug_sv.log(l_module_name, 'P_item_key',P_item_key);
      wsh_debug_sv.log(l_module_name, 'P_actid',P_actid);
      wsh_debug_sv.log(l_module_name, 'P_funcmode',P_funcmode);
     END IF;

      IF ( P_funcmode = 'RUN' ) THEN

         l_Return_Status := WSH_UTIL_CORE.g_ret_sts_success;

         WSH_TRANSACTIONS_TPW_UTIL.Check_Cancel_Allowed (P_item_type, P_item_key, l_Return_Status);
         IF l_debug_on THEN
          wsh_debug_sv.log (l_module_name, 'Return status after check_Cancel_Allowed ', l_Return_Status);
         END IF;

         IF ( l_Return_Status = WSH_UTIL_CORE.g_ret_sts_success ) THEN
           X_resultout := 'COMPLETE:SUCCESS';
         ELSE
            X_resultout := 'COMPLETE:ERROR';
         END IF;
      END IF;

    IF l_debug_on THEN
     wsh_debug_sv.log(l_module_name, 'X_resultout',X_resultout);
     wsh_debug_sv.pop(l_module_name);
    END IF;

   EXCEPTION
      WHEN OTHERS THEN
         X_resultout := 'COMPLETE:ERROR';
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
         RAISE;
   END Check_Cancel_Allowed_WF;


   /*===========================================================================
   |                                                                           |
   | PROCEDURE NAME   Send_Cbod_Success_WF                                     |
   |                                                                           |
   | DESCRIPTION	    This procedure is called from the work flow to trigger   |
   |                  the procedure Send_Cbod_Success, which sends a CBOD to   |
   |                  the supplier, if cancellation is successful.             |
   |                                                                           |
   | MODIFICATION HISTORY                                                      |
   |                                                                           |
   |	02/18/02      Vijay Nandula   Created                                    |
   |                                                                           |
   ============================================================================*/

   PROCEDURE Send_Cbod_Success_WF ( P_item_type  IN    VARCHAR2,
                                    P_item_key   IN    VARCHAR2,
                                    P_actid      IN    NUMBER,
                                    P_funcmode   IN    VARCHAR2,
                                    X_resultout  OUT NOCOPY    VARCHAR2 )
   IS
      l_Return_Status  VARCHAR2(1);
      --
l_debug_on BOOLEAN;
      --
      l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SEND_CBOD_SUCCESS_WF';
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
      wsh_debug_sv.push(l_module_name, 'Send_Cbod_Success_WF');
      wsh_debug_sv.log(l_module_name, 'P_item_type',P_item_type);
      wsh_debug_sv.log(l_module_name, 'P_item_key',P_item_key);
      wsh_debug_sv.log(l_module_name, 'P_actid',P_actid);
      wsh_debug_sv.log(l_module_name, 'P_funcmode',P_funcmode);
     END IF;

      IF ( P_funcmode = 'RUN' ) THEN

         l_Return_Status := WSH_UTIL_CORE.g_ret_sts_success;

         Send_Cbod_Success (P_item_type, P_item_key, l_Return_Status);
         IF l_debug_on THEN
          wsh_debug_sv.log (l_module_name, 'Return status after Send_Cbod_Success ', l_Return_Status);
         END IF;

         IF ( l_Return_Status = WSH_UTIL_CORE.g_ret_sts_success ) THEN
           X_resultout := 'COMPLETE:SUCCESS';
         ELSE
            X_resultout := 'COMPLETE:ERROR';
         END IF;
      END IF;

    IF l_debug_on THEN
     wsh_debug_sv.log(l_module_name, 'X_resultout',X_resultout);
     wsh_debug_sv.pop(l_module_name);
    END IF;

   EXCEPTION

      WHEN OTHERS THEN
         X_resultout := 'COMPLETE:ERROR';
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
         RAISE;
   END Send_Cbod_Success_WF;


   /*===========================================================================
   |                                                                           |
   | PROCEDURE NAME   Send_Cbod_Failure_WF                                     |
   |                                                                           |
   | DESCRIPTION	    This procedure is called from the work flow to trigger   |
   |                  the procedure Send_Cbod_Failure, which sends a COBD to   |
   |                  the supplier indicating the transaction or cancellation  |
   |                  is not processed successfully.                           |
   | MODIFICATION HISTORY                                                      |
   |                                                                           |
   |	02/18/02      Vijay Nandula   Created                                    |
   |                                                                           |
   ============================================================================*/

   PROCEDURE Send_Cbod_Failure_WF ( P_item_type  IN    VARCHAR2,
                                    P_item_key   IN    VARCHAR2,
                                    P_actid      IN    NUMBER,
                                    P_funcmode   IN    VARCHAR2,
                                    X_resultout  OUT NOCOPY    VARCHAR2 )
   IS
      l_Return_Status  VARCHAR2(1);
      --
l_debug_on BOOLEAN;
      --
      l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SEND_CBOD_FAILURE_WF';
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
      wsh_debug_sv.push(l_module_name, 'Send_Cbod_FailureWF');
      wsh_debug_sv.log(l_module_name, 'P_item_type',P_item_type);
      wsh_debug_sv.log(l_module_name, 'P_item_key',P_item_key);
      wsh_debug_sv.log(l_module_name, 'P_actid',P_actid);
      wsh_debug_sv.log(l_module_name, 'P_funcmode',P_funcmode);
     END IF;

      IF ( P_funcmode = 'RUN' ) THEN

         l_Return_Status := WSH_UTIL_CORE.g_ret_sts_success;

         Send_Cbod_Failure (P_item_type, P_item_key, l_Return_Status);
         IF l_debug_on THEN
          wsh_debug_sv.log (l_module_name, 'Return status after Send_Cbod_Failure ', l_Return_Status);
         END IF;

         IF ( l_Return_Status = WSH_UTIL_CORE.g_ret_sts_success ) THEN
           X_resultout := 'COMPLETE:SUCCESS';
         ELSE
            X_resultout := 'COMPLETE:ERROR';
         END IF;
      END IF;
    IF l_debug_on THEN
     wsh_debug_sv.log(l_module_name, 'X_resultout',X_resultout);
     wsh_debug_sv.pop(l_module_name);
    END IF;

   EXCEPTION

      WHEN OTHERS THEN
         X_resultout := 'COMPLETE:ERROR';
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
         RAISE;
   END Send_Cbod_Failure_WF;


   /*===========================================================================
   |                                                                           |
   | PROCEDURE NAME   Raise_Cancel_Event_WF                                    |
   |                                                                           |
   | DESCRIPTION	    This procedure is called from the work flow to trigger   |
   |                  the procedure Raise_Cancel_Event, which will raise an    |
   |                  event for cancelling the previous WF instance.           |
   |                                                                           |
   | MODIFICATION HISTORY                                                      |
   |                                                                           |
   |	02/18/02      Vijay Nandula   Created                                    |
   |                                                                           |
   ============================================================================*/

   PROCEDURE Raise_Cancel_Event_WF ( P_item_type  IN    VARCHAR2,
                                     P_item_key   IN    VARCHAR2,
                                     P_actid      IN    NUMBER,
                                     P_funcmode   IN    VARCHAR2,
                                     X_resultout  OUT NOCOPY    VARCHAR2 )
   IS
      l_Return_Status  VARCHAR2(1);
      --
l_debug_on BOOLEAN;
      --
      l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'RAISE_CANCEL_EVENT_WF';
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
      wsh_debug_sv.push(l_module_name, 'Raise_Cancel_Event_WF');
      wsh_debug_sv.log(l_module_name, 'P_item_type',P_item_type);
      wsh_debug_sv.log(l_module_name, 'P_item_key',P_item_key);
      wsh_debug_sv.log(l_module_name, 'P_actid',P_actid);
      wsh_debug_sv.log(l_module_name, 'P_funcmode',P_funcmode);
     END IF;

      IF ( P_funcmode = 'RUN' ) THEN

         l_Return_Status := WSH_UTIL_CORE.g_ret_sts_success;
         Raise_Cancel_Event (P_item_type, P_item_key, l_Return_Status);
         IF l_debug_on THEN
          wsh_debug_sv.log (l_module_name, 'Return status after Raise_Cancel_Event ', l_Return_Status);
         END IF;

         IF ( l_Return_Status = WSH_UTIL_CORE.g_ret_sts_success ) THEN
           X_resultout := 'COMPLETE:SUCCESS';
         ELSE
            X_resultout := 'COMPLETE:ERROR';
         END IF;
      END IF;

    IF l_debug_on THEN
     wsh_debug_sv.log(l_module_name, 'X_resultout',X_resultout);
     wsh_debug_sv.pop(l_module_name);
    END IF;
   EXCEPTION

      WHEN OTHERS THEN
         X_resultout := 'COMPLETE:ERROR';
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
         RAISE;
   END Raise_Cancel_Event_WF;

    -- ---------------------------------------------------------------------
    -- Procedure:	Raise_Close_Event_WF
    --
    -- Parameters:	Item_Type IN  VARCHAR2
    --                  Item_Key  IN  VARCHAR2
    --		       	Actid     IN  NUMBER
    --                  Funcmode  IN  VARCHAR2
    --                  Resultout OUT VARCHAR2
    --
    -- Description:  This procedure is called from Inbound workflow (WSHSTNDI) to
    --               trigger the API Raise_Close_Event that intern calls the business
    --               event oracle.apps.wsh.standalone.spwf to close all the previous
    --               error out revision of Shipment Request
    -- Created:     Standalone WMS Project
    -- -----------------------------------------------------------------------
   PROCEDURE Raise_Close_Event_WF ( P_item_type  IN    VARCHAR2,
                                     P_item_key   IN    VARCHAR2,
                                     P_actid      IN    NUMBER,
                                     P_funcmode   IN    VARCHAR2,
                                     X_resultout  OUT NOCOPY    VARCHAR2 )
   IS
      l_Return_Status  VARCHAR2(1);
      --
      l_debug_on BOOLEAN;
      --
      l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'RAISE_CLOSE_EVENT_WF';
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
      wsh_debug_sv.push(l_module_name, 'Raise_Close_Event_WF');
      wsh_debug_sv.log(l_module_name, 'P_item_type',P_item_type);
      wsh_debug_sv.log(l_module_name, 'P_item_key',P_item_key);
      wsh_debug_sv.log(l_module_name, 'P_actid',P_actid);
      wsh_debug_sv.log(l_module_name, 'P_funcmode',P_funcmode);
     END IF;

      IF ( P_funcmode = 'RUN' ) THEN

         l_Return_Status := WSH_UTIL_CORE.g_ret_sts_success;
         Raise_Close_Event (P_item_type, P_item_key, l_Return_Status);
         IF l_debug_on THEN
          wsh_debug_sv.log (l_module_name, 'Return status after Raise_Close_Event ', l_Return_Status);
         END IF;

         IF ( l_Return_Status = WSH_UTIL_CORE.g_ret_sts_success ) THEN
           X_resultout := 'COMPLETE:SUCCESS';
         ELSE
            X_resultout := 'COMPLETE:ERROR';
         END IF;
      END IF;

    IF l_debug_on THEN
     wsh_debug_sv.log(l_module_name, 'X_resultout',X_resultout);
     wsh_debug_sv.pop(l_module_name);
    END IF;
   EXCEPTION

      WHEN OTHERS THEN
         X_resultout := 'COMPLETE:ERROR';
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
         RAISE;
   END Raise_Close_Event_WF;


   /*===========================================================================
   |                                                                           |
   | PROCEDURE NAME   Send_Cbod_Success                                        |
   |                                                                           |
   | DESCRIPTION      This procedure sends a Conformation BOD to the supplier, |
   |                  if the cancellation requiest is successfully completed.  |
   |                                                                           |
   | MODIFICATION HISTORY                                                      |
   |                                                                           |
   |	02/18/02      Vijay Nandula   Created                                    |
   |                                                                           |
   ============================================================================*/

   PROCEDURE Send_Cbod_Success ( P_item_type      IN    VARCHAR2,
                                 P_item_key       IN    VARCHAR2,
                                 X_Return_Status  OUT NOCOPY    VARCHAR2 )
   IS
      l_txn_hist_record WSH_TRANSACTIONS_HISTORY_PKG.Txns_History_Record_Type;
      l_Return_Status   VARCHAR2 (1);
      l_Cbod_Status     VARCHAR2 (5) := '00';

      wsh_get_txns_hist_error EXCEPTION;
      wsh_raise_event_error EXCEPTION;
      --
      l_debug_on BOOLEAN;
      --
      l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SEND_CBOD_SUCCESS';
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
      wsh_debug_sv.push(l_module_name, 'Send_Cbod_Success');
      wsh_debug_sv.log(l_module_name, 'P_item_type',P_item_type);
      wsh_debug_sv.log(l_module_name, 'P_item_key',P_item_key);
     END IF;

      X_Return_Status := WSH_UTIL_CORE.g_ret_sts_success;

      WSH_TRANSACTIONS_HISTORY_PKG.Get_Txns_History ( P_item_type,
                                                      P_item_key,
                                                      'I',
                                                      'SR',
                                                      l_txn_hist_record,
                                                      l_Return_Status);
      IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name, 'Return status after Get_Txns_History ', l_Return_Status);
      END IF;

      IF (l_Return_Status <> WSH_UTIL_CORE.g_ret_sts_success ) THEN
         RAISE wsh_get_txns_hist_error;
      END IF;

      IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name, 'txn_history.Transaction Status ', l_txn_hist_record.transaction_status);
      END IF;
      -- Change the Event Name before calling Raise Event
      -- R12.1.1 STANDALONE PROJECT
      -- LSP PROJECT : consider LSP mode also.
      IF ( WMS_DEPLOY.WMS_DEPLOYMENT_MODE = 'D' OR (WMS_DEPLOY.WMS_DEPLOYMENT_MODE = 'L' AND l_txn_hist_record.client_code IS NOT NULL ) ) THEN
        l_txn_hist_record.Event_Name := 'oracle.apps.wsh.standalone.scbod';
      ELSE
        l_txn_hist_record.Event_Name := 'oracle.apps.wsh.tpw.scbod';
      END IF;

      l_txn_hist_record.Event_Key := NULL;

      WSH_EXTERNAL_INTERFACE_SV.Raise_Event ( l_txn_hist_record, l_Cbod_Status, l_Return_Status );

      IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name, 'Return status after Raise_Event ', l_Return_Status);
      END IF;

      IF (l_Return_Status <> WSH_UTIL_CORE.g_ret_sts_success ) THEN
         RAISE wsh_raise_event_error;
      END IF;

      IF l_debug_on THEN
       wsh_debug_sv.pop(l_module_name);
      END IF;
   EXCEPTION
      WHEN wsh_get_txns_hist_error THEN
         X_Return_Status := WSH_UTIL_CORE.g_ret_sts_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'wsh_get_txns_hist_error has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_get_txns_hist_error');
         END IF;

      WHEN wsh_raise_event_error THEN
         X_Return_Status := WSH_UTIL_CORE.g_ret_sts_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'wsh_raise_event_error exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_raise_event_error');
         END IF;

      WHEN OTHERS THEN
         X_Return_Status := WSH_UTIL_CORE.g_ret_sts_unexp_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
   END Send_Cbod_Success;


   /*===========================================================================
   |                                                                           |
   | PROCEDURE NAME   Send_Cbod_Failure                                        |
   |                                                                           |
   | DESCRIPTION	    This procedure sends a failure Conformation BOD to the   |
   |                  supplier if (a) a cancellation is not processed or (b)   |
   |                  if the cancellation is processed, then failure to the    |
   |                  work flow process which sent the original transaction.   |
   | MODIFICATION HISTORY                                                      |
   |                                                                           |
   |	02/18/02      Vijay Nandula   Created                                    |
   |                                                                           |
   ============================================================================*/

   PROCEDURE Send_Cbod_Failure ( P_item_type      IN    VARCHAR2,
                                 P_item_key       IN    VARCHAR2,
                                 X_Return_Status  OUT NOCOPY    VARCHAR2 )
   IS
      l_txn_hist_record WSH_TRANSACTIONS_HISTORY_PKG.Txns_History_Record_Type;
      l_Return_Status   VARCHAR2 (1);
      l_Cbod_Status     VARCHAR2 (5) := '99';

      l_Event_Name VARCHAR2 (120);
      l_Event_Key  VARCHAR2 (30);

      -- LSP PROJECT : added wndi table to get client_code from wndi.
      CURSOR l_txn_hist_cur (c_Orig_Document_Number VARCHAR2,
                             c_Trading_Partner_ID   NUMBER)
      IS
      SELECT wth.Event_Key,
             wth.Item_Type,
             wth.Internal_Control_Number
      FROM   wsh_transactions_history wth
      WHERE  wth.Transaction_ID = (SELECT MAX (Transaction_ID)
                               FROM   wsh_transactions_history
                               WHERE  Document_Number = c_Orig_Document_Number
                               AND    Trading_Partner_ID = c_Trading_Partner_ID
                               AND    Document_Direction = 'I'
                               AND    Action_Type = 'A');

      wsh_get_txns_hist_error  EXCEPTION;
      wsh_raise_event_error    EXCEPTION;
      wsh_orig_txns_hist_error EXCEPTION;
      --
l_debug_on BOOLEAN;
      --
      l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SEND_CBOD_FAILURE';
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
      wsh_debug_sv.push(l_module_name, 'Send_Cbod_Failure');
      wsh_debug_sv.log(l_module_name, 'P_item_type',P_item_type);
      wsh_debug_sv.log(l_module_name, 'P_item_key',P_item_key);
     END IF;

      X_Return_Status := WSH_UTIL_CORE.g_ret_sts_success;

      WSH_TRANSACTIONS_HISTORY_PKG.Get_Txns_History ( P_item_type,
                                                      P_item_key,
                                                      'I',
                                                      'SR',
                                                      l_txn_hist_record,
                                                      l_Return_Status );

      IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name, 'Return status after Get_Txns_History ', l_Return_Status);
      END IF;

      IF (l_Return_Status <> WSH_UTIL_CORE.g_ret_sts_success ) THEN
         RAISE wsh_get_txns_hist_error;
      END IF;

      -- Check if the error message is for the current WF or the Original WF
      -- If the Status is populated with 'success' then it is for original instance
      -- else it is for the current WF instance.
      IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name, 'Transaction Status ', l_txn_hist_record.Transaction_Status);
       wsh_debug_sv.log (l_module_name, 'Action Type ', l_txn_hist_record.Action_Type);
      END IF;

      -- Before calling the Raise Event Update the l_txn_hist_record.Event_Name
      -- with appropriate value. Is this 'oracle.apps.wsh.tpw.scbod' ??

      IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name, 'Before Calling the Raise_Event ', l_Cbod_Status);
      END IF;
      -- Change the Event Name before calling Raise Event
      -- R12.1.1 STANDALONE PROJECT
      -- LSP PROJECT : consider LSP mode also.
      IF ( WMS_DEPLOY.WMS_DEPLOYMENT_MODE = 'D' OR (WMS_DEPLOY.WMS_DEPLOYMENT_MODE = 'L' AND l_txn_hist_record.client_code IS NOT NULL)) THEN
        l_txn_hist_record.Event_Name := 'oracle.apps.wsh.standalone.scbod';
      ELSE

        IF (l_txn_hist_record.Transaction_Status = 'SC' AND
            l_txn_hist_record.Action_Type = 'D') THEN

           -- Get the original transaction record from the Transaction History table.
           OPEN  l_txn_hist_cur (l_txn_hist_record.Orig_Document_Number, l_txn_hist_record.Trading_Partner_ID);
           FETCH l_txn_hist_cur
           INTO  l_txn_hist_record.Event_Key,
                 l_txn_hist_record.Item_Type,
                 l_txn_hist_record.Internal_Control_Number;
           IF ( l_txn_hist_cur % NOTFOUND )THEN
              CLOSE l_txn_hist_cur;
              IF l_debug_on THEN
                wsh_debug_sv.log (l_module_name, 'No data found ');
              END IF;
              RAISE wsh_orig_txns_hist_error;
           END IF;
           CLOSE l_txn_hist_cur;
        END IF;

        l_txn_hist_record.Event_Name := 'oracle.apps.wsh.tpw.scbod';
      END IF;

      l_txn_hist_record.Event_Key := NULL;

      -- Call Raise Event procedure to raise the appropriate event.
      WSH_EXTERNAL_INTERFACE_SV.Raise_Event ( l_txn_hist_record, l_Cbod_Status, l_Return_Status );

      IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name, 'After calling the Raise_Event, Status ', l_Return_Status);
      END IF;

      IF (l_Return_Status <> WSH_UTIL_CORE.g_ret_sts_success ) THEN
         RAISE wsh_raise_event_error;
      END IF;

      IF l_debug_on THEN
       wsh_debug_sv.pop(l_module_name);
      END IF;
   EXCEPTION
      WHEN wsh_get_txns_hist_error THEN
         X_Return_Status := WSH_UTIL_CORE.g_ret_sts_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'wsh_get_txns_hist_error exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_get_txns_hist_error');
         END IF;

      WHEN wsh_orig_txns_hist_error THEN
         X_Return_Status := WSH_UTIL_CORE.g_ret_sts_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'wsh_orig_txns_hist_error exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_orig_txns_hist_error');
         END IF;

      WHEN wsh_raise_event_error THEN
         X_Return_Status := WSH_UTIL_CORE.g_ret_sts_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'wsh_raise_event_error exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_raise_event_error');
         END IF;

      WHEN OTHERS THEN
         X_Return_Status := WSH_UTIL_CORE.g_ret_sts_unexp_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
   END Send_Cbod_Failure;


   /*===========================================================================
   |                                                                           |
   | PROCEDURE NAME   Check_Cancel_Allowed                                     |
   |                                                                           |
   | DESCRIPTION	    This procedure checks if the cancellation request for a  |
   |                  transaction can be processed or not.  If allowed then    |
   |                  cancellation will be completed.                          |
   | MODIFICATION HISTORY                                                      |
   |                                                                           |
   |	02/18/02      Vijay Nandula   Created                                    |
   |                                                                           |
   ============================================================================*/

   PROCEDURE Check_Cancel_Allowed ( P_item_type  IN    VARCHAR2,
                                    P_item_key   IN    VARCHAR2,
                                    X_Return_Status OUT NOCOPY  VARCHAR2 )
   IS
      l_txn_hist_record      WSH_TRANSACTIONS_HISTORY_PKG.Txns_History_Record_Type;
      l_Return_Status   VARCHAR2 (1);
      l_new_del_status  VARCHAR2 (2);
      l_Event_Name      VARCHAR2 (120);
      l_Event_Key       VARCHAR2 (30);
      l_Delivery_ID     NUMBER;

      l_Orig_Entity_Number      VARCHAR2 (30);
      l_Orig_Trading_Partner_ID NUMBER;
      l_Orig_Transaction_Status VARCHAR2 (2);

      l_New_Del_Interface_ID NUMBER;
      -- LSP PROJECT : added wndi table to get client_code from wndi.
      CURSOR l_orig_txn_hist_cur (c_Orig_Document_Number VARCHAR2,
                                  c_Trading_Partner_ID   NUMBER)
      IS
      SELECT wth.Entity_Number,
             wth.Trading_Partner_ID,
             wth.Transaction_Status,
             wndi.client_code
      FROM   wsh_transactions_history wth,
             wsh_new_del_interface wndi
      WHERE  wth.Transaction_ID = (SELECT MAX (Transaction_ID)
                               FROM   wsh_transactions_history
                               WHERE  Document_Number = c_Orig_Document_Number
                               AND    Trading_Partner_ID = c_Trading_Partner_ID
                               AND    Document_Direction = 'I'
                               AND    Action_Type = 'A')
      AND wth.entity_number = wndi.delivery_interface_id (+);

      CURSOR l_new_del_status_cur (c_Delivery_Name VARCHAR2,
                                   c_Organization_ID NUMBER) IS
         SELECT status_code, Delivery_ID
         FROM   wsh_new_deliveries
         WHERE  Organization_id = c_Organization_ID
         AND    Name = c_Delivery_Name;
/*

      CURSOR l_new_del_interface_cur ( c_Name VARCHAR2,
                                       c_Org_ID NUMBER ) IS
         SELECT Delivery_Interface_id
         FROM   wsh_new_del_interface
         WHERE  Name = c_Name
         AND    Organization_ID = c_Org_ID;
*/

      l_client_code             VARCHAR2(200); -- LSP PROJECT
      --
      wsh_invalid_item_key      EXCEPTION;
      wsh_get_txns_hist_error   EXCEPTION;
      wsh_orig_txns_hist_error  EXCEPTION;
      wsh_update_history        EXCEPTION;
      wsh_del_interface_rec     EXCEPTION;
      wsh_invalid_delivery_no   EXCEPTION;
      wsh_del_interface_wrapper EXCEPTION;

      --
l_debug_on BOOLEAN;
      --
      l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_CANCEL_ALLOWED';
      --
      --Bugfix 4070732
      l_api_session_name CONSTANT VARCHAR2(150) := G_PKG_NAME ||'.' || l_module_name;
   BEGIN
     --Bugfix 4070732
     IF WSH_UTIL_CORE.G_START_OF_SESSION_API is null THEN
       WSH_UTIL_CORE.G_START_OF_SESSION_API     := l_api_session_name;
       WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API := FALSE;
     END IF;
     --
     l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
     --
     IF l_debug_on IS NULL
     THEN
         l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
     END IF;
     --
     IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name, 'Check_Cancel_Allowed');
      wsh_debug_sv.log(l_module_name, 'P_item_type',P_item_type);
      wsh_debug_sv.log(l_module_name, 'P_item_key',P_item_key);
     END IF;


      X_Return_Status := WSH_UTIL_CORE.g_ret_sts_success;

      IF ( P_item_type IS NULL OR
           P_item_key  IS NULL ) THEN
         RAISE wsh_invalid_item_key;
      END IF;

      -- Get the record from the Transaction History Table.
      WSH_TRANSACTIONS_HISTORY_PKG.Get_Txns_History ( P_item_type,
                                                      P_item_key,
                                                      'I',
                                                      'SR',
                                                      l_txn_hist_record,
                                                      l_Return_Status );

      IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name, 'Return status after Get_Txns_History ', l_Return_Status);
      END IF;

      IF (l_Return_Status <> WSH_UTIL_CORE.g_ret_sts_success ) THEN
         RAISE wsh_get_txns_hist_error;
      END IF;

      -- Get the Delivery Interface ID from wsh_new_del_interface table for the given record
      -- in the transaction history table.
/*
      OPEN l_new_del_interface_cur ( l_txn_hist_record.Entity_Number,
                                     l_txn_hist_record.Trading_Partner_ID );
      FETCH l_new_del_interface_cur INTO l_New_Del_Interface_ID;
      CLOSE l_new_del_interface_cur;
*/

      l_New_Del_Interface_ID := to_number(l_txn_hist_record.Entity_Number);


      IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name, 'Delivery Interface ID' , l_New_Del_Interface_ID);
      END IF;

      -- Get the Transaction Record for the Original transaction (which has addition)
      OPEN  l_orig_txn_hist_cur (l_txn_hist_record.Orig_Document_Number, l_txn_hist_record.Trading_Partner_ID);
      FETCH l_orig_txn_hist_cur
      INTO  l_Orig_Entity_Number, l_Orig_Trading_Partner_ID, l_Orig_Transaction_Status,l_client_code; -- LSP PROJECT.

      IF ( l_orig_txn_hist_cur % NOTFOUND ) THEN
         CLOSE l_orig_txn_hist_cur;
         IF l_debug_on THEN
           wsh_debug_sv.log (l_module_name, 'Original Record Not Found ');
         END IF;
         RAISE wsh_orig_txns_hist_error;
      END IF;
      CLOSE l_orig_txn_hist_cur;

      IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name, 'Txn Status for original record ', l_Orig_Transaction_Status);
      END IF;

      -- R12.1.1 STANDALONE PROJECT
      -- LSP PROJECT : consider LSP mode also.
      IF (WMS_DEPLOY.WMS_DEPLOYMENT_MODE = 'D' OR (WMS_DEPLOY.WMS_DEPLOYMENT_MODE = 'L' AND l_client_code IS NOT NULL)) OR ( l_Orig_Transaction_Status = 'IP' ) THEN
         l_txn_hist_record.transaction_status := 'ER';
         WSH_TRANSACTIONS_HISTORY_PKG.Create_Update_Txns_History ( l_txn_hist_record,
                                                                   l_txn_hist_record.transaction_id,
                                                                   l_Return_Status );
         IF l_debug_on THEN
            wsh_debug_sv.log (l_module_name, 'Return status after Create_Update_Txns_History ', l_Return_Status);
         END IF;
         IF ( l_Return_Status <> WSH_UTIL_CORE.g_ret_sts_success ) THEN
            RAISE wsh_update_history;
         END IF;

         WSH_PROCESS_INTERFACED_PKG.delete_interface_records ( l_New_Del_Interface_ID,
                                                               l_Return_Status );
         IF l_debug_on THEN
          wsh_debug_sv.log (l_module_name, 'Return status after delete_interface_records ', l_Return_Status);
         END IF;

         IF ( l_Return_Status <> WSH_UTIL_CORE.g_ret_sts_success ) THEN
            RAISE wsh_del_interface_rec;
         END IF;

         X_Return_Status := WSH_UTIL_CORE.g_ret_sts_error;

	 --Bugfix 4070732 {
         IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
           IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
             IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;

             WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                       x_return_status => l_return_status);

             IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
             END IF;

                  IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                     x_return_status := l_return_status;
                  END IF;

           END IF;
         END IF;
         --}
	 -- End of bug 4070732

         IF l_debug_on THEN
          wsh_debug_sv.pop(l_module_name);
         END IF;
         RETURN;
      ELSIF ( l_Orig_Transaction_Status = 'ER' ) THEN

         WSH_PROCESS_INTERFACED_PKG.delete_interface_records ( l_New_Del_Interface_ID,
                                                               l_Return_Status );
         IF l_debug_on THEN
          wsh_debug_sv.log (l_module_name, 'Return status after delete_interface_records ', l_Return_Status);
         END IF;

         IF ( l_Return_Status <> WSH_UTIL_CORE.g_ret_sts_success ) THEN
            RAISE wsh_del_interface_rec;
         END IF;

         l_txn_hist_record.transaction_status := 'SC';
         WSH_TRANSACTIONS_HISTORY_PKG.Create_Update_Txns_History ( l_txn_hist_record,
                                                                   l_txn_hist_record.transaction_id,
                                                                   l_Return_Status );
         IF l_debug_on THEN
          wsh_debug_sv.log (l_module_name, 'Return status after Create_Update_Txns_History ', l_Return_Status);
         END IF;
         IF ( l_Return_Status <> WSH_UTIL_CORE.g_ret_sts_success ) THEN
            RAISE wsh_update_history;
         END IF;

	 --Bugfix 4070732 {
         IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
           IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
             IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;

             WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                         x_return_status => l_return_status);

             IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
             END IF;

            IF (
                ( l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR )
             OR ( l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR
                  AND x_return_status <> WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR )
               )
            THEN
            --{
               x_return_status := l_return_status;
            --}
            ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING
              AND x_return_status <> WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
            THEN
               x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            END IF;

           END IF;
         END IF;
         --}
	 -- End of bug 4070732

         IF l_debug_on THEN
          wsh_debug_sv.pop(l_module_name);
         END IF;
         RETURN;

      END IF;

      OPEN l_new_del_status_cur (l_Orig_Entity_Number, l_Orig_Trading_Partner_ID);
      FETCH l_new_del_status_cur INTO l_new_del_status, l_Delivery_ID;
      IF (l_new_del_status_cur % NOTFOUND) THEN
         IF l_debug_on THEN
            wsh_debug_sv.log (l_module_name, 'No data found for l_new_del_status_cur');
         END IF;
         CLOSE l_new_del_status_cur;
         RAISE wsh_invalid_delivery_no;
      END IF;
      CLOSE l_new_del_status_cur;

      IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name, 'Delivery Name' , l_txn_hist_record.entity_number);
       wsh_debug_sv.log (l_module_name, 'Delivery Status' , l_new_del_status);
      END IF;

      IF ( l_new_del_status IN ('CL', 'IT', 'CO') ) THEN
         l_txn_hist_record.transaction_status := 'ER';
         WSH_TRANSACTIONS_HISTORY_PKG.Create_Update_Txns_History ( l_txn_hist_record,
                                                                   l_txn_hist_record.transaction_id,
                                                                   l_Return_Status );
        IF l_debug_on THEN
         wsh_debug_sv.log (l_module_name, 'Return status after Create_Update_Txns_History ', l_Return_Status);
        END IF;
         IF ( l_Return_Status <> WSH_UTIL_CORE.g_ret_sts_success ) THEN
            RAISE wsh_update_history;
         END IF;


         X_Return_Status := WSH_UTIL_CORE.g_ret_sts_error;

	 --Bugfix 4070732 {
         IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
           IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
             IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;

             WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                       x_return_status => l_return_status);


             IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
             END IF;

                  IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                     x_return_status := l_return_status;
                  END IF;

           END IF;
         END IF;
         --}
	 -- End of bug 4070732

        IF l_debug_on THEN
         wsh_debug_sv.pop(l_module_name);
        END IF;
         RETURN;
      END IF;

      IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name, 'New Delivery Interface ID' , l_new_del_interface_id);
       wsh_debug_sv.log (l_module_name, 'Delivery ID' , l_delivery_id);
      END IF;

      WSH_INTERFACE_COMMON_ACTIONS.Delivery_Interface_Wrapper (l_New_Del_Interface_ID,
                                                               'CANCEL',
                                                               l_Delivery_ID,
                                                               l_Return_Status );

      IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name, 'Return status after Delivery_Interface_Wrapper ', l_Return_Status);
      END IF;

      IF ( l_Return_Status <> WSH_UTIL_CORE.g_ret_sts_success ) THEN
         RAISE wsh_del_interface_wrapper;
      ELSE
         l_txn_hist_record.transaction_status := 'SC';

         WSH_TRANSACTIONS_HISTORY_PKG.Create_Update_Txns_History ( l_txn_hist_record,
                                                                   l_txn_hist_record.transaction_id,
                                                                   l_Return_Status );

        IF l_debug_on THEN
         wsh_debug_sv.log (l_module_name, 'Return status after Create_Update_Txns_History ', l_Return_Status);
        END IF;

         IF (l_Return_Status <> WSH_UTIL_CORE.g_ret_sts_success ) THEN
            RAISE wsh_update_history;
         END IF;

         WSH_PROCESS_INTERFACED_PKG.delete_interface_records ( l_New_Del_Interface_ID,
                                                               l_Return_Status );

        IF l_debug_on THEN
         wsh_debug_sv.log (l_module_name, 'Return status after delete_interface_records ', l_Return_Status);
        END IF;

         IF ( l_Return_Status <> WSH_UTIL_CORE.g_ret_sts_success ) THEN
            RAISE wsh_del_interface_rec;
         END IF;
      END IF;

      --bug 4070732
      --End of the API handling of calls to process_stops_for_load_tender
      IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name)
      THEN
      --{
         IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
         --{

            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Process_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

            WSH_UTIL_CORE.Process_stops_for_load_tender(p_reset_flags   => TRUE,
                                                        x_return_status => l_return_status);

            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
            END IF;

            IF (
                ( l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR )
             OR ( l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR
                  AND x_return_status <> WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR )
               )
            THEN
            --{
               x_return_status := l_return_status;
            --}
            ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING
              AND x_return_status <> WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
            THEN
               x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            END IF;


          --}
          END IF;
       --}
       END IF;
      --bug 4070732

     IF l_debug_on THEN
      wsh_debug_sv.pop(l_module_name);
     END IF;

   EXCEPTION
      WHEN wsh_invalid_item_key THEN
         X_Return_Status := WSH_UTIL_CORE.g_ret_sts_error;

	 --Bugfix 4070732 {
         IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
           IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
             IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;

             WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                       x_return_status => l_return_status);

             IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
             END IF;


             IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
             END IF;

           END IF;
         END IF;
         --}
	 -- End of bug 383969

         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'wsh_invalid_item_key exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_invalid_item_key');
         END IF;

      WHEN wsh_get_txns_hist_error THEN
         X_Return_Status := WSH_UTIL_CORE.g_ret_sts_error;
	 --Bugfix 4070732 {
         IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
           IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
             IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;

             WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                       x_return_status => l_return_status);


             IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
             END IF;

             IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
             END IF;

           END IF;
         END IF;
         --}
	 -- End of bug 383969

         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'wsh_get_txns_hist_error exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_get_txns_hist_error');
         END IF;

      WHEN wsh_orig_txns_hist_error THEN
         X_Return_Status := WSH_UTIL_CORE.g_ret_sts_error;
	 --Bugfix 4070732 {
         IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
           IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
             IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;

             WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                       x_return_status => l_return_status);


             IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
             END IF;

             IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
             END IF;
           END IF;
         END IF;
         --}
	 -- End of bug 383969

         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'wsh_orig_txns_hist_error exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_orig_txns_hist_error');
         END IF;

      WHEN wsh_update_history THEN
         X_return_status := WSH_UTIL_CORE.g_ret_sts_error;

	 --Bugfix 4070732 {
         IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
           IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
             IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;

             WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                       x_return_status => l_return_status);


             IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
             END IF;

             IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
             END IF;

           END IF;
         END IF;
         --}
	 -- End of bug 383969

	 IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'wsh_update_history exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_update_history');
         END IF;

      WHEN wsh_del_interface_rec THEN
         X_Return_Status := WSH_UTIL_CORE.g_ret_sts_error;

	 --Bugfix 4070732 {
         IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
           IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
             IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;

             WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                       x_return_status => l_return_status);

             IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
             END IF;


             IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
             END IF;

           END IF;
         END IF;
         --}
	 -- End of bug 383969

	 IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'wsh_del_interface_rec exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_del_interface_rec');
         END IF;

      WHEN wsh_invalid_delivery_no THEN
         X_return_status := WSH_UTIL_CORE.g_ret_sts_error;

	 --Bugfix 4070732 {
         IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
           IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
             IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;

             WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                       x_return_status => l_return_status);


             IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
             END IF;

             IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
             END IF;

           END IF;
         END IF;
         --}
	 -- End of bug 383969

	 IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'wsh_invalid_delivery_no exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_invalid_delivery_no');
         END IF;

      WHEN wsh_del_interface_wrapper THEN
         l_txn_hist_record.transaction_status := 'ER';
         WSH_TRANSACTIONS_HISTORY_PKG.Create_Update_Txns_History ( l_txn_hist_record,
                                                                   l_txn_hist_record.transaction_id,
                                                                   l_Return_Status );
         IF ( l_Return_Status <> WSH_UTIL_CORE.g_ret_sts_success ) THEN
            X_Return_Status := WSH_UTIL_CORE.g_ret_sts_unexp_error;
         END IF;

         X_Return_Status := WSH_UTIL_CORE.g_ret_sts_error;

	 --Bugfix 4070732 {
         IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
           IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
             IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;

             WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                       x_return_status => l_return_status);


             IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
             END IF;

             IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
             END IF;

           END IF;
         END IF;
         --}
	 -- End of bug 383969

         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'wsh_del_interface_wrapper exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_del_interface_wrapper');
         END IF;

      WHEN OTHERS THEN
         X_Return_Status := WSH_UTIL_CORE.g_ret_sts_unexp_error;

	 --Bugfix 4070732 {
         IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
           IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
             IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;

             WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                       x_return_status => l_return_status);


             IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
             END IF;

           END IF;
         END IF;
         --}
	 -- End of bug 383969

         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
   END Check_Cancel_Allowed;


   /*===========================================================================
   |                                                                           |
   | PROCEDURE NAME   Raise_Cancel_Event                                       |
   |                                                                           |
   | DESCRIPTION	    This procedure raises a WF event for cancelling the      |
   |                  previous WF instance.                                    |
   | MODIFICATION HISTORY                                                      |
   |                                                                           |
   |	02/18/02      Vijay Nandula   Created                                    |
   |                                                                           |
   ============================================================================*/

   PROCEDURE Raise_Cancel_Event ( P_item_type  IN    VARCHAR2,
                                  P_item_key   IN    VARCHAR2,
                                  X_return_Status OUT NOCOPY  VARCHAR2 )
   IS
      l_txn_hist_record  WSH_TRANSACTIONS_HISTORY_PKG.Txns_History_Record_Type;
      l_orig_txn_hist_record  WSH_TRANSACTIONS_HISTORY_PKG.Txns_History_Record_Type;
      l_Return_Status    VARCHAR2 (1);
      l_Event_Name VARCHAR2 (120);
      l_Event_Key  VARCHAR2 (30);

      CURSOR l_txn_hist_cur (c_Item_Type VARCHAR2,
                             c_Item_Key  VARCHAR2)
      IS
      SELECT wth1.Transaction_ID,
             wth1.Document_Type,
             wth1.Document_Direction,
             wth1.Document_Number,
             wth1.Orig_Document_Number,
             wth1.Entity_Number,
             wth1.Entity_Type,
             wth1.Trading_Partner_ID,
             wth1.Action_Type,
             wth1.Transaction_Status,
             wth1.ECX_Message_ID,
             wth1.Event_Name,
             wth1.Event_Key,
             wth1.Item_Type,
             wth1.Internal_Control_Number,
             -- R12.1.1 STANDALONE PROJECT
             wth1.document_revision,
             wth1.Attribute_Category,
             wth1.Attribute1,
             wth1.Attribute2,
             wth1.Attribute3,
             wth1.Attribute4,
             wth1.Attribute5,
             wth1.Attribute6,
             wth1.Attribute7,
             wth1.Attribute8,
             wth1.Attribute9,
             wth1.Attribute10,
             wth1.Attribute11,
             wth1.Attribute12,
             wth1.Attribute13,
             wth1.Attribute14,
             wth1.Attribute15,
             NULL   -- LSP PROJECT
      FROM   wsh_transactions_history wth1,
             wsh_transactions_history wth2
      WHERE  wth2.Item_Type = c_Item_Type
      AND    wth2.Event_Key = c_Item_Key
      AND    wth1.Document_Number = wth2.Orig_Document_Number
      AND    wth1.Trading_Partner_ID = wth2.Trading_Partner_ID
      AND    wth1.Document_Direction = 'I'
      AND    wth1.Action_Type = 'A';

      wsh_orig_txns_hist_error EXCEPTION;
      wsh_raise_event_error EXCEPTION;
      --
l_debug_on BOOLEAN;
      --
      l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'RAISE_CANCEL_EVENT';
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
      wsh_debug_sv.push(l_module_name, 'Raise_Cancel_Event');
      wsh_debug_sv.log(l_module_name, 'P_item_type',P_item_type);
      wsh_debug_sv.log(l_module_name, 'P_item_key',P_item_key);
     END IF;

      X_Return_Status := WSH_UTIL_CORE.g_ret_sts_success;

      OPEN  l_txn_hist_cur (P_Item_Type, P_Item_Key);
      FETCH l_txn_hist_cur
      INTO  l_orig_txn_hist_record;
      IF ( l_txn_hist_cur % NOTFOUND ) THEN
         IF l_debug_on THEN
            wsh_debug_sv.log (l_module_name, 'No data found for l_txn_hist_cur ');
         END IF;

         CLOSE l_txn_hist_cur;
         RAISE wsh_orig_txns_hist_error;
      END IF;
      CLOSE l_txn_hist_cur;

      l_orig_txn_hist_record.Event_Name := 'oracle.apps.wsh.tpw.spwf';
      IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name, 'Before Raise_Event : Event Name ' , l_orig_txn_hist_record.Event_Name);
       wsh_debug_sv.log (l_module_name, 'Event key ' , l_orig_txn_hist_record.Event_Key);
      END IF;
      WSH_EXTERNAL_INTERFACE_SV.Raise_Event ( l_orig_txn_hist_record,
                                              NULL,
                                              l_Return_Status );

      IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name, 'Return status after Raise_Event ', l_Return_Status);
      END IF;

      IF (l_Return_Status <> WSH_UTIL_CORE.g_ret_sts_success ) THEN
         RAISE wsh_raise_event_error;
      END IF;

      IF l_debug_on THEN
       wsh_debug_sv.pop(l_module_name);
      END IF;
   EXCEPTION
      WHEN wsh_orig_txns_hist_error THEN
         X_Return_Status := WSH_UTIL_CORE.g_ret_sts_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'wsh_orig_txns_hist_error exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_orig_txns_hist_error');
         END IF;

      WHEN wsh_raise_event_error THEN
         X_Return_Status := WSH_UTIL_CORE.g_ret_sts_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'wsh_raise_event_error exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_raise_event_error');
         END IF;

      WHEN OTHERS THEN
         X_Return_Status := WSH_UTIL_CORE.g_ret_sts_unexp_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
   END Raise_Cancel_Event;

    -- R12.1.1 STANDALONE PROJECT
    -- ---------------------------------------------------------------------
    -- Procedure:	Raise_Close_Event
    --
    -- Parameters:	P_Item_Type IN  VARCHAR2
    --                  P_Item_Key  IN  VARCHAR2
    --		       	X_return_Status VARCHAR2
    --
    -- Description:  This procedure is called from Raise_Close_Event_WF API to
    --               trigger the business event oracle.apps.wsh.standalone.spwf and
    ---              close all the previous error out revision of Shipment Request
    -- Created:     Standalone WMS Project
    -- -----------------------------------------------------------------------
   PROCEDURE Raise_Close_Event  ( P_item_type  IN    VARCHAR2,
                                  P_item_key   IN    VARCHAR2,
                                  X_return_Status OUT NOCOPY  VARCHAR2 )
   IS

      pragma AUTONOMOUS_TRANSACTION;

      l_txn_hist_record  WSH_TRANSACTIONS_HISTORY_PKG.Txns_History_Record_Type;
      l_orig_txn_hist_record  WSH_TRANSACTIONS_HISTORY_PKG.Txns_History_Record_Type;
      l_Return_Status    VARCHAR2 (1);
      l_Event_Name VARCHAR2 (120);
      l_Event_Key  VARCHAR2 (30);

      CURSOR l_stnd_txn_hist_cur (c_Item_Type VARCHAR2,
                                  c_Item_Key  VARCHAR2)
      IS
      SELECT wth1.Transaction_ID,
             wth1.Document_Type,
             wth1.Document_Direction,
             wth1.Document_Number,
             wth1.Document_Number Orig_Document_Number,
             wth1.Entity_Number,
             wth1.Entity_Type,
             wth1.Trading_Partner_ID,
             wth1.Action_Type,
             wth1.Transaction_Status,
             wth1.ECX_Message_ID,
             wth1.Event_Name,
             wth1.Event_Key,
             wth1.Item_Type,
             wth1.Internal_Control_Number,
             wth1.document_revision,
             wth1.Attribute_Category,
             wth1.Attribute1,
             wth1.Attribute2,
             wth1.Attribute3,
             wth1.Attribute4,
             wth1.Attribute5,
             wth1.Attribute6,
             wth1.Attribute7,
             wth1.Attribute8,
             wth1.Attribute9,
             wth1.Attribute10,
             wth1.Attribute11,
             wth1.Attribute12,
             wth1.Attribute13,
             wth1.Attribute14,
             wth1.Attribute15,
             NULL -- LSP PROJECT
      FROM   wsh_transactions_history wth1,
             wsh_transactions_history wth2
      WHERE  wth2.Item_Type = c_Item_Type
      AND    wth2.Event_Key = c_Item_Key
      AND    wth1.Document_Number = wth2.Document_Number
      AND    wth1.Trading_Partner_ID = wth2.Trading_Partner_ID
      AND    wth1.Document_Revision < wth2.Document_Revision
      AND    wth1.Document_Direction = 'I'
      AND    wth2.Document_Direction = 'I'
      AND    wth1.Transaction_Status in ('AP', 'ER')
      AND    wth1.Event_Name is not null
      AND    wth1.Event_Key is not null;

      wsh_orig_txns_hist_error EXCEPTION;
      wsh_raise_event_error EXCEPTION;
      --
      l_debug_on BOOLEAN;
      --
      l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'RAISE_CLOSE_EVENT';
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
      wsh_debug_sv.push(l_module_name, 'Raise_Close_Event');
      wsh_debug_sv.log(l_module_name, 'P_item_type',P_item_type);
      wsh_debug_sv.log(l_module_name, 'P_item_key',P_item_key);
     END IF;

      X_Return_Status := WSH_UTIL_CORE.g_ret_sts_success;

      FOR l_orig_txn_hist_record IN l_stnd_txn_hist_cur(P_Item_Type, P_Item_Key) LOOP

        l_orig_txn_hist_record.Event_Name := 'oracle.apps.wsh.standalone.spwf';

        IF l_debug_on THEN
         wsh_debug_sv.log (l_module_name, 'Before Raise_Event : Event Name ' , l_orig_txn_hist_record.Event_Name);
         wsh_debug_sv.log (l_module_name, 'Event key ' , l_orig_txn_hist_record.Event_Key);
        END IF;

        WSH_EXTERNAL_INTERFACE_SV.Raise_Event ( l_orig_txn_hist_record,
                                                NULL,
                                                l_Return_Status );

        IF l_debug_on THEN
         wsh_debug_sv.log (l_module_name, 'Return status after Raise_Event ', l_Return_Status);
        END IF;

        IF (l_Return_Status <> WSH_UTIL_CORE.g_ret_sts_success ) THEN
           RAISE wsh_raise_event_error;
        END IF;

      END LOOP;

      COMMIT;

      IF l_debug_on THEN
       wsh_debug_sv.pop(l_module_name);
      END IF;
   EXCEPTION
      WHEN wsh_orig_txns_hist_error THEN
         X_Return_Status := WSH_UTIL_CORE.g_ret_sts_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'wsh_orig_txns_hist_error exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_orig_txns_hist_error');
         END IF;

      WHEN wsh_raise_event_error THEN
         X_Return_Status := WSH_UTIL_CORE.g_ret_sts_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'wsh_raise_event_error exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_raise_event_error');
         END IF;

      WHEN OTHERS THEN
         X_Return_Status := WSH_UTIL_CORE.g_ret_sts_unexp_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
   END Raise_Close_Event;

   /*===========================================================================
   |                                                                           |
   | PROCEDURE NAME   Send_Shipment_Advice                                     |
   |                                                                           |
   | DESCRIPTION	    This procedure checks if Warehouse Shipping Advice needs |
   |                  to be sent to the Supplier instance or not.  If it is    |
   |                  required, an event is raised to send the transaction.    |
   | MODIFICATION HISTORY                                                      |
   |                                                                           |
   |	02/18/02      Vijay Nandula   Created                                    |
   |                                                                           |
   ============================================================================*/

   PROCEDURE Send_Shipment_Advice ( P_Entity_ID        IN  NUMBER,
                                    P_Entity_Type      IN  VARCHAR2,
                                    P_Action_Type      IN  VARCHAR2,
                                    P_Document_Type    IN  VARCHAR2,
                                    P_Org_ID           IN  NUMBER,
                                    X_Return_Status    OUT NOCOPY  VARCHAR2 )
   IS
      CURSOR l_orig_txn_hist_cur (c_Entity_Number VARCHAR2,
                                  c_Org_ID        NUMBER)
      IS
      SELECT wth1.Document_Number,
             wth1.Transaction_Status,
             wth1.Event_Key
      FROM   wsh_transactions_history wth1
      WHERE  Transaction_ID = (SELECT MAX (Transaction_ID)
                               FROM   wsh_transactions_history
                               WHERE  Entity_Number = c_Entity_Number
                               AND    Trading_Partner_ID = c_Org_ID
                               AND    Entity_Type = 'DLVY'
                               AND    Action_Type = 'A'
                               AND    Document_Direction = 'I'
                               AND    Document_Type = 'SR');

-- LSP PROJECT : Added client_id
CURSOR l_new_del_status_cur ( c_Delivery_ID VARCHAR2, c_Organization_ID NUMBER ) IS
SELECT Name, status_code,client_id
FROM   wsh_new_deliveries
WHERE  Organization_id = c_Organization_ID
AND    Delivery_ID = c_Delivery_ID;

CURSOR l_del_details_cur (c_Delivery_ID NUMBER, c_Org_ID NUMBER) IS
SELECT 'X'
FROM   wsh_delivery_details wdd,
       wsh_delivery_assignments_v  wda,
       wsh_new_deliveries   wnd
WHERE  wdd.container_flag = 'N'
AND    wdd.source_code = 'WSH'
AND    wdd.Delivery_Detail_ID = wda.Delivery_Detail_ID
AND    wda.Delivery_ID = wnd.Delivery_ID
AND    wnd.Delivery_ID = c_Delivery_ID
AND    wnd.Organization_ID = c_Org_ID
AND    rownum = 1;

cursor	l_check_resend_cur(p_entity_number VARCHAR2 ) is
select	transaction_status from wsh_transactions_history
where	transaction_id =(select max(transaction_id) from wsh_transactions_history
where	entity_number= p_entity_number
and	trading_partner_id=p_org_id
and	document_direction = 'O'
and	document_type ='SA'
and	entity_type ='DLVY'
and	action_type = 'A');

CURSOR get_delivery_details(cp_entity_id NUMBER) IS
SELECT  'X'
FROM   	wsh_delivery_details wdd,
	wsh_delivery_assignments_v  wda,
        mtl_system_items msi
WHERE  wdd.container_flag = 'N'
AND    wdd.released_status <> 'D'
AND    nvl(wdd.inv_interfaced_flag,'N') <> 'Y'
AND    wdd.Delivery_Detail_ID = wda.Delivery_Detail_ID
AND    msi.inventory_item_id = wdd.inventory_item_id
AND    msi.organization_id     = wdd.organization_id
AND    msi.serial_number_control_code IN (2,5,6)
AND    wda.Delivery_ID = cp_entity_id
AND    rownum = 1;

      l_orig_document_number    VARCHAR2 (120);
      l_orig_Transaction_Status VARCHAR2 (2);
      l_orig_Event_Key          VARCHAR2 (240);
      l_curr_txn_hist_record  WSH_TRANSACTIONS_HISTORY_PKG.Txns_History_Record_Type;
      l_Return_Status   VARCHAR2 (1);
      l_new_del_status  VARCHAR2 (2);
      l_Del_Name        VARCHAR2 (30);
      l_txn_Status      VARCHAR2 (2);
      l_del_detail_x    VARCHAR2 (1);
      l_delivery_details	VARCHAR2(1);
      -- R12.1.1 STANDALONE PROJECT
      l_wms_deployment_mode     VARCHAR2(1);
      l_client_id               NUMBER; -- LSP PROJECT

      wsh_invalid_delivery_id        EXCEPTION;
      wsh_invalid_entity_type        EXCEPTION;
      wsh_invalid_action_type        EXCEPTION;
      wsh_invalid_doc_type           EXCEPTION;
      wsh_orig_txns_hist_error       EXCEPTION;
      wsh_orig_txn_hist_error_status EXCEPTION;
      wsh_invalid_del_status         EXCEPTION;
      wsh_del_details_error          EXCEPTION;
      wsh_raise_event_error          EXCEPTION;
      wsh_sa_resend_error            EXCEPTION;
      wsh_serial_no_inv_interface    EXCEPTION;
      -- R12.1.1 STANDALONE PROJECT
      wsh_interface_to_om_failed     EXCEPTION;
      --
l_debug_on BOOLEAN;
      --
      l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SEND_SHIPMENT_ADVICE';
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
      wsh_debug_sv.push(l_module_name, 'Send_Shipment_Advice');
      wsh_debug_sv.log (l_module_name, 'P_Entity_ID ', P_Entity_ID);
      wsh_debug_sv.log (l_module_name, 'P_Entity_Type ', P_Entity_Type);
      wsh_debug_sv.log (l_module_name, 'P_Action_Type ', P_Action_Type);
      wsh_debug_sv.log (l_module_name, 'P_Document_Type ', P_Document_Type);
      wsh_debug_sv.log (l_module_name, 'P_Org_ID ', P_Org_ID);
     END IF;

      X_Return_Status := WSH_UTIL_CORE.g_ret_sts_success;

      IF ( P_Entity_TYPE <> 'DLVY' ) THEN
         RAISE wsh_invalid_entity_type;
      ELSIF ( P_Action_TYPE <> 'A' ) THEN
         RAISE wsh_invalid_action_type;
      ELSIF ( P_Document_TYPE <> 'SA' ) THEN
         RAISE wsh_invalid_doc_type;
      END IF;

      -- Get the Original Delivery Number and status from the delivery table.
      OPEN l_new_del_status_cur (P_Entity_ID,
                                 P_Org_ID);
      FETCH l_new_del_status_cur INTO l_Del_Name, l_new_del_status,l_client_id; -- LSP PROJECT

      IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name, 'Delivery Name' , l_Del_Name);
       wsh_debug_sv.log (l_module_name, 'Delivery Status' , l_new_del_status);
       wsh_debug_sv.log (l_module_name, 'Client Id' , l_client_id); -- LSP PROJECT
      END IF;

      IF (l_new_del_status_cur % NOTFOUND) THEN
         IF l_debug_on THEN
            wsh_debug_sv.log (l_module_name, 'No Data found for l_new_del_status_cur');
         END IF;
         CLOSE l_new_del_status_cur;
         RAISE wsh_invalid_delivery_id;
      END IF;
      CLOSE l_new_del_status_cur;

      -- R12.1.1 STANDALONE PROJECT
      l_wms_deployment_mode := WMS_DEPLOY.WMS_DEPLOYMENT_MODE;
      -- LSP PROJECT : consider LSP mode also.
      IF (l_wms_deployment_mode = 'D' OR (l_wms_deployment_mode = 'L' AND l_client_id IS NOT NULL )) THEN
         IF (l_new_del_status NOT IN ('IT', 'CL')) THEN
           RAISE wsh_invalid_del_status;
         END IF;

      ELSIF ( l_new_del_status NOT IN ('CL', 'IT', 'CO') ) THEN
         RAISE wsh_invalid_del_status;

      ELSE
         OPEN l_del_details_cur (P_Entity_ID, P_Org_ID);
         FETCH l_del_details_cur INTO l_del_detail_x;
         CLOSE l_del_details_cur;
         IF l_debug_on THEN
          wsh_debug_sv.log (l_module_name, 'Value of l_del_details_cur ' , l_del_detail_x);
         END IF;
         IF (NVL (l_del_detail_x, '-') <> 'X') THEN
            RAISE wsh_del_details_error;
         END IF;

         OPEN get_delivery_details(p_entity_id);
         FETCH get_delivery_details INTO l_delivery_details;
         IF l_debug_on THEN
            wsh_debug_sv.log (l_module_name, 'Value of l_delivery_details' ,l_delivery_details);
         END IF;
         CLOSE get_delivery_details;

         IF (NVL (l_delivery_details, '-') = 'X') THEN
            RAISE wsh_serial_no_inv_interface;
         END IF;

      END IF;

      open l_check_resend_cur( l_Del_Name );
      fetch l_check_resend_cur into l_txn_Status;
      close l_check_resend_cur;

      IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name, 'Outbound Transaction Status' , l_txn_Status);
      END IF;
      if ( nvl(l_txn_Status, 'ER') <> 'ER' ) THEN
	 raise wsh_sa_resend_error;
      end if;

      -- R12.1.1 STANDALONE PROJECT
      -- LSP PROJECT : consider LSP mode also.
      IF (l_wms_deployment_mode = 'D' OR (l_wms_deployment_mode = 'L' AND l_client_id IS NOT NULL )) THEN --{
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIP_CONFIRM_ACTIONS.Process_Delivery_To_OM',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        WSH_SHIP_CONFIRM_ACTIONS.Process_Delivery_To_OM (
           p_delivery_id   => p_entity_id,
           x_return_status => l_return_status);

        IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
           RAISE wsh_interface_to_om_failed;
        END IF;
      ELSE
        -- Get the Original record from the Transaction History Table for the Delivery.
        OPEN l_orig_txn_hist_cur (l_Del_Name, P_Org_ID);
        FETCH l_orig_txn_hist_cur
        INTO  l_orig_document_number, l_orig_Transaction_Status, l_orig_Event_Key;
        IF (l_orig_txn_hist_cur % NOTFOUND) THEN
           IF l_debug_on THEN
            wsh_debug_sv.log (l_module_name, 'No Data found for l_orig_txn_hist_cur');
           END IF;
           CLOSE l_orig_txn_hist_cur;
           RAISE wsh_orig_txns_hist_error;
        END IF;
        CLOSE l_orig_txn_hist_cur;

        -- If the Original transaction status is Error or In process then we cannot send a
        -- Shipping Advice back to the Supplier.
        IF l_debug_on THEN
         wsh_debug_sv.log (l_module_name, 'Orig Transaction Status' , l_orig_Transaction_Status);
        END IF;
        IF ( l_orig_Transaction_Status IN ('ER', 'IP') ) THEN
           RAISE wsh_orig_txn_hist_error_status;
        END IF;
      END IF; --}
      -- R12.1.1 STANDALONE PROJECT
      IF l_debug_on THEN
       wsh_debug_sv.logmsg (l_module_name, 'Updating Delivery Pending_Advice_Flag Status to Null');
      END IF;
      UPDATE wsh_new_deliveries
      SET    pending_advice_flag    = NULL,
             last_update_date       = SYSDATE,
             last_updated_by        = fnd_global.user_id,
             program_application_id = fnd_global.prog_appl_id,
             program_id             = fnd_global.conc_program_id,
             program_update_date    = SYSDATE,
             request_id             = fnd_global.conc_request_id
      WHERE  delivery_id            = P_Entity_ID;

      -- Build a Transaction Record for the current transaction
      l_curr_txn_hist_record.Document_Type         := P_Document_Type;
      l_curr_txn_hist_record.Document_Direction    := 'O';
      l_curr_txn_hist_record.Entity_Number         := l_Del_Name;
      l_curr_txn_hist_record.Entity_Type           := P_Entity_TYPE;
      -- LSP PROJECT.
      IF (l_wms_deployment_mode = 'L' AND l_client_id IS NOT NULL ) THEN
      --{
        SELECT party_id
        INTO   l_curr_txn_hist_record.Trading_Partner_ID
        FROM   hz_cust_accounts_all
        WHERE  cust_account_id = l_client_id;
      ELSE
        l_curr_txn_hist_record.Trading_Partner_ID    := P_Org_ID;
      --}
      END IF;
      IF l_debug_on THEN
        wsh_debug_sv.log (l_module_name, 'Trading Partner Id ' , l_curr_txn_hist_record.Trading_Partner_ID);
      END IF;
      -- LSP PROJECT : End
      l_curr_txn_hist_record.Action_Type           := P_Action_Type;
      l_curr_txn_hist_record.Transaction_Status    := 'IP';
      -- R12.1.1 STANDALONE PROJECT
      -- LSP PROJECT : consider LSP mode also.
      IF (l_wms_deployment_mode = 'D' OR (l_wms_deployment_mode = 'L' AND l_client_id IS NOT NULL )) THEN
        l_curr_txn_hist_record.Event_Name            := 'oracle.apps.wsh.standalone.ssao';
        l_curr_txn_hist_record.Item_Type             := 'WSHSTNDO';
      ELSE
        l_curr_txn_hist_record.Orig_Document_Number  := l_orig_Document_Number;
        l_curr_txn_hist_record.Event_Name            := 'oracle.apps.wsh.tpw.ssao';
        l_curr_txn_hist_record.Item_Type             := 'WSHTPWI';
      END IF;
      l_curr_txn_hist_record.Event_Key             := l_orig_Event_Key;

      -- Raise event will insert the record into the transaction history table
      -- for the current transaction.
      IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name, 'Before Raise_Event');
      END IF;

      WSH_EXTERNAL_INTERFACE_SV.Raise_Event ( l_curr_txn_hist_record,
                                              NULL,
                                              l_Return_Status );

      IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name, 'After Raise_Event , return status ' , l_Return_Status);
      END IF;

      IF (l_Return_Status <> WSH_UTIL_CORE.g_ret_sts_success ) THEN
         RAISE wsh_raise_event_error;
      END IF;

      IF l_debug_on THEN
       wsh_debug_sv.pop(l_module_name);
      END IF;

   EXCEPTION
      WHEN wsh_invalid_delivery_id THEN
         X_Return_Status := WSH_UTIL_CORE.g_ret_sts_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'wsh_invalid_delivery_id exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_invalid_delivery_id');
         END IF;

      WHEN wsh_invalid_entity_type THEN
         X_Return_Status := WSH_UTIL_CORE.g_ret_sts_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'wsh_invalid_entity_type exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_invalid_entity_type');
         END IF;

      WHEN wsh_invalid_action_type THEN
         X_Return_Status := WSH_UTIL_CORE.g_ret_sts_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'wsh_invalid_action_type exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_invalid_action_type');
         END IF;

      WHEN wsh_invalid_doc_type THEN
         X_Return_Status := WSH_UTIL_CORE.g_ret_sts_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'wsh_invalid_doc_type exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_invalid_doc_type');
         END IF;

      WHEN wsh_orig_txns_hist_error THEN
         X_Return_Status := WSH_UTIL_CORE.g_ret_sts_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'wsh_orig_txns_hist_error exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_orig_txns_hist_error');
         END IF;

      WHEN wsh_orig_txn_hist_error_status THEN
         X_Return_Status := WSH_UTIL_CORE.g_ret_sts_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'wsh_orig_txns_hist_error exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_orig_txns_hist_error');
         END IF;
       -- R12.1.1 STANDALONE PROJECT
      WHEN wsh_interface_to_om_failed THEN
         X_Return_Status := WSH_UTIL_CORE.g_ret_sts_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'wsh_interface_to_om_failed exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_interface_to_om_failed');
         END IF;

      WHEN wsh_invalid_del_status THEN
         X_Return_Status := WSH_UTIL_CORE.g_ret_sts_error;
         FND_MESSAGE.Set_Name ('WSH', 'WSH_INVALID_DELIVERY_STATUS');
         WSH_UTIL_CORE.Add_Message (x_return_status,l_module_name);
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'wsh_invalid_del_status exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_invalid_del_status');
         END IF;

      WHEN wsh_del_details_error THEN
         X_Return_Status := WSH_UTIL_CORE.g_ret_sts_error;
         FND_MESSAGE.Set_Name ('WSH', 'WSH_DEL_DETAIL_ERROR');
         WSH_UTIL_CORE.Add_Message (x_return_status,l_module_name);
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'wsh_del_details_error exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_del_details_error');
         END IF;

      WHEN wsh_raise_event_error THEN
         X_Return_Status := WSH_UTIL_CORE.g_ret_sts_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'wsh_raise_event_error exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_raise_event_error');
         END IF;
      WHEN wsh_sa_resend_error THEN
         X_Return_Status := WSH_UTIL_CORE.g_ret_sts_error;
         FND_MESSAGE.Set_Name ('WSH', 'WSH_SA_RESEND_ERROR');
	 FND_MESSAGE.SET_TOKEN('DEL_NAME',l_del_name);
         WSH_UTIL_CORE.Add_Message (x_return_status,l_module_name);
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'wsh_sa_resend_error exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_sa_resend_error');
         END IF;

      WHEN wsh_serial_no_inv_interface THEN
         X_Return_Status := WSH_UTIL_CORE.g_ret_sts_error;
         FND_MESSAGE.Set_Name ('WSH', 'WSH_SERIAL_NO_INV_INTERFACE');
         FND_MESSAGE.SET_TOKEN('DEL_NAME',l_del_name);
         WSH_UTIL_CORE.Add_Message (x_return_status,l_module_name);
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'wsh_serial_no_inv_interface exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_serial_no_inv_interface');
         END IF;

      WHEN OTHERS THEN
         X_Return_Status := WSH_UTIL_CORE.g_ret_sts_unexp_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
   END Send_Shipment_Advice;


END WSH_TRANSACTIONS_TPW_UTIL;


/
