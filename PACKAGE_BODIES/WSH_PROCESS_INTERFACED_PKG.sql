--------------------------------------------------------
--  DDL for Package Body WSH_PROCESS_INTERFACED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_PROCESS_INTERFACED_PKG" AS
/* $Header: WSHINPSB.pls 120.4.12010000.7 2010/04/07 10:57:23 ueshanka ship $ */


/*=====================================================================================

PROCEDURE NAME : Process_Inbound

This Procedure is called from the Workflow to Derive, Validate data in the Interface
tables and finally move it to the Base Tables.

This procedure looks at the Document Type and accordingly calls Ship Request API or
Ship Advice API for further processing.
=======================================================================================*/

   --
   G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_PROCESS_INTERFACED_PKG';
   --
   PROCEDURE process_inbound (
      l_trns_history_rec   IN       wsh_transactions_history_pkg.txns_history_record_type,
      x_return_status      OUT NOCOPY       VARCHAR2
   )
   IS

pragma AUTONOMOUS_TRANSACTION;
      invalid_doc_direction     EXCEPTION;
      invalid_doc_type          EXCEPTION;
      invalid_action_type       EXCEPTION;
      invalid_entity_type       EXCEPTION;
      l_delivery_interface_id	NUMBER;
      l_return_status           VARCHAR2 (1);
      t_return_status           VARCHAR2 (1);
	l_rs BOOLEAN;
	oe_debug_dir	VARCHAR2(255);
	oe_debug_file	VARCHAR2(255);
	wsh_debug_file	VARCHAR2(255);
	wsh_debug_dir VARCHAR2(255);
      x_delivery_id             NUMBER;

      --
l_debug_on BOOLEAN;
      --
      l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PROCESS_INBOUND';
      --
    -- Following 2 variables are added for bugfix #4070732
    l_api_session_name CONSTANT VARCHAR2(150) := G_PKG_NAME ||'.' || l_module_name;
    l_reset_flags BOOLEAN;

    -- K LPN CONV. rv
    l_lpn_in_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_in_rec_type;
    l_lpn_out_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_out_rec_type;
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(32767);
    -- K LPN CONV. rv
    --k proj bmso
    l_cancellation_in_progress      BOOLEAN := FALSE;
    CURSOR c_get_cancel_record (v_entity_number VARCHAR2)
    IS
    SELECT wth3.transaction_id,
        wth3.document_type,
        wth3.document_direction,
        wth3.document_number,
        wth3.orig_document_number,
        wth3.entity_number,
        wth3.entity_type,
        wth3.trading_partner_id,
        wth3.action_type,
        wth3.transaction_status,
        wth3.ecx_message_id,
        wth3.event_name,
        wth3.event_key ,
        wth3.item_type,
        wth3.internal_control_number,
        --R12.1.1 STANDALONE PROJECT
        wth3.document_revision,
        wth3.attribute_category,
        wth3.attribute1,
        wth3.attribute2,
        wth3.attribute3,
        wth3.attribute4,
        wth3.attribute5,
        wth3.attribute6,
        wth3.attribute7,
        wth3.attribute8,
        wth3.attribute9,
        wth3.attribute10,
        wth3.attribute11,
        wth3.attribute12,
        wth3.attribute13,
        wth3.attribute14,
        wth3.attribute15,
        NULL -- LSP PROJECT : just added for dependency for client_id
  FROM wsh_transactions_history wth1,
       wsh_transactions_history wth2,
       wsh_transactions_history wth3
  WHERE
  wth2.entity_number = v_entity_number
  AND wth2.document_direction = 'I'
  AND wth2.document_type = 'SA'
  AND wth1.event_key = wth2.event_key
  AND wth1.document_number = wth2.ORIG_DOCUMENT_NUMBER
  AND wth1.action_type = 'A'
  and wth1.document_direction  = 'O'
  and wth1.document_type       = 'SR'
  AND wth1.entity_type = 'DLVY'
  AND wth3.entity_number = wth1.entity_number
  AND wth3.document_type       = 'SR'
  AND wth3.document_direction  = 'O'
  AND wth3.action_type = 'D'
  ORDER BY wth1.transaction_id DESC;

  l_cancel_hist_record      c_get_cancel_record%ROWTYPE;
   BEGIN

   -- Bugfix 4070732
   IF WSH_UTIL_CORE.G_START_OF_SESSION_API is null
   THEN
       WSH_UTIL_CORE.G_START_OF_SESSION_API     := l_api_session_name;
       WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API := FALSE;
   END IF;

   -- End of Code Bugfix 4070732
      --
      l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
      --
      IF l_debug_on IS NULL
      THEN
          l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
      END IF;
      --
      wsh_debug_sv.start_debug (l_trns_history_rec.entity_number);

      /*
	wsh_debug_sv.start_other_app_debug(
	p_application	=> 'OE',
	x_debug_directory => oe_debug_dir,
	x_debug_file	=> oe_debug_file,
	x_return_status	=> l_return_status);

	wsh_debug_file	:= WSH_DEBUG_SV.G_FILE;
	wsh_debug_dir := WSH_DEBUG_SV.G_DIR;
      */
     IF l_debug_on THEN
      wsh_debug_sv.push (l_module_name, 'PROCESS_INBOUND');
      wsh_debug_sv.log (l_module_name,'DOCUMENT NUMBER',l_trns_history_rec.document_number);
      wsh_debug_sv.log (l_module_name,'DOC TYPE',l_trns_history_rec.document_type);
      wsh_debug_sv.log (l_module_name,'ACTION TYPE',l_trns_history_rec.action_type);
      wsh_debug_sv.log (l_module_name,'ENTITY NUMBER',l_trns_history_rec.entity_number);
      wsh_debug_sv.log (l_module_name,'ENTITY TYPE',l_trns_history_rec.entity_type);
      wsh_debug_sv.log (l_module_name,'DIRECTION',l_trns_history_rec.document_direction);
      wsh_debug_sv.log (l_module_name,'TRADING PARTNER',l_trns_history_rec.trading_partner_id);
      wsh_debug_sv.log (l_module_name,'ORIG DOC NUMBER',l_trns_history_rec.orig_document_number);
     END IF;

   IF (WMS_DEPLOY.WMS_DEPLOYMENT_MODE IN ('D','L')) THEN --{ LSP PROJECT : Consider LSP mode also
      IF  (l_trns_history_rec.document_number IS NOT NULL)
          AND (l_trns_history_rec.document_revision IS NOT NULL)
          AND (l_trns_history_rec.document_type IS NOT NULL)
          AND (l_trns_history_rec.action_type IS NOT NULL)
          AND (l_trns_history_rec.entity_number IS NOT NULL)
          AND (l_trns_history_rec.entity_type IS NOT NULL)
          AND (l_trns_history_rec.document_direction IS NOT NULL)
          AND (l_trns_history_rec.trading_partner_id IS NOT NULL)
      THEN

         IF l_debug_on THEN
	  wsh_debug_sv.log (l_module_name,'Parameters Not Null');
         END IF;

         IF (l_trns_history_rec.document_direction NOT IN ('I'))
         THEN
            RAISE invalid_doc_direction;
         END IF;

         IF (l_trns_history_rec.document_type NOT IN ('SR'))
         THEN
            RAISE invalid_doc_type;
         END IF;

         IF (l_trns_history_rec.action_type NOT IN ('A', 'C', 'D'))
         THEN
            RAISE invalid_action_type;
         END IF;

         IF (l_trns_history_rec.entity_type NOT IN ('DLVY_INT'))
         THEN
            RAISE invalid_entity_type;
         END IF;
      END IF;

      IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name,'Valid Parameters');
      END IF;

      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIPMENT_REQUEST_PKG.Process_Shipment_Request',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

      WSH_SHIPMENT_REQUEST_PKG.Process_Shipment_Request(
          p_transaction_rec     => l_trns_history_rec,
          p_commit_flag         => FND_API.G_TRUE,
          x_return_status       => l_return_status);

      IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSE
         IF NVL(x_return_status,wsh_util_core.g_ret_sts_success) =
                                wsh_util_core.g_ret_sts_success
         THEN
            x_return_status := l_return_status;
         END IF;
      END IF;

     ELSE --} {

	-- bug 2393138
      wsh_delivery_util.g_inbound_flag := TRUE;
	-- bug 2393138

      -- { frontport of 4317121
      --Deleting these cache tables to avoid session based problems
      WSH_INTERFACE_COMMON_ACTIONS.G_Update_Attributes_Tab.delete;
      WSH_INTERFACE_COMMON_ACTIONS.G_Packing_Detail_Tab.delete;
      WSH_INTERFACE_COMMON_ACTIONS.G_SERIAL_RANGE_TAB.delete;
      -- } frontport of 4317121

      IF  (l_trns_history_rec.document_number IS NOT NULL)
          AND (l_trns_history_rec.document_type IS NOT NULL)
          AND (l_trns_history_rec.action_type IS NOT NULL)
          AND (l_trns_history_rec.entity_number IS NOT NULL)
          AND (l_trns_history_rec.entity_type IS NOT NULL)
          AND (l_trns_history_rec.document_direction IS NOT NULL)
          AND (l_trns_history_rec.trading_partner_id IS NOT NULL)
      THEN

         IF l_debug_on THEN
	  wsh_debug_sv.log (l_module_name,'Parameters Not Null');
         END IF;

         IF (l_trns_history_rec.document_direction NOT IN ('I'))
         THEN
            RAISE invalid_doc_direction;
         END IF;

         IF (l_trns_history_rec.document_type NOT IN ('SR', 'SA'))
         THEN
            RAISE invalid_doc_type;
         END IF;

         IF (l_trns_history_rec.action_type NOT IN ('A', 'D'))
         THEN
            RAISE invalid_action_type;
         END IF;

         IF (l_trns_history_rec.entity_type NOT IN ('DLVY', 'DLVY_INT'))
         THEN
            RAISE invalid_entity_type;
         END IF;

         IF l_debug_on THEN
          wsh_debug_sv.log (l_module_name,'Valid Parameters');
         END IF;

         IF (l_trns_history_rec.entity_type = 'DLVY_INT')
         THEN

	      l_delivery_interface_id := to_number(l_trns_history_rec.entity_number);

	      Derive_ids (l_delivery_interface_id,l_trns_history_rec.document_type,l_return_status);

              IF l_debug_on THEN
		wsh_debug_sv.log (l_module_name,'After Calling Derive IDS l_return_status',l_return_status);
              END IF;

            IF (l_return_status = wsh_util_core.g_ret_sts_success) THEN

	       -- TPW - Distributed changes
               -- savepoint before_process NOT required since api
               -- wsh_inbound_ship_advice_pkg.process_ship_advice takes care of
               -- setting appropriate savepoints.

               IF (l_trns_history_rec.document_type = 'SR') THEN

                  wsh_inbound_ship_request_pkg.process_ship_request (
                     l_trns_history_rec.item_type,
                     l_trns_history_rec.event_key,
                     l_trns_history_rec.action_type,
                     l_delivery_interface_id,
                     x_delivery_id,
                     t_return_status
                  );

                  IF l_debug_on THEN
       		   wsh_debug_sv.log (l_module_name,'l_delivery_interface_id',l_delivery_interface_id);
       		   wsh_debug_sv.log (l_module_name,'x_delivery_id',x_delivery_id);
       		   wsh_debug_sv.log (l_module_name,'t_return_status',t_return_status);
                  END IF;

               ELSE
                  wsh_inbound_ship_advice_pkg.process_ship_advice (
                     l_delivery_interface_id,
		     l_trns_history_rec.event_key,
                     t_return_status
                  );

                  IF l_debug_on THEN
       		   wsh_debug_sv.log (l_module_name,'t_return_status',t_return_status);
                  END IF;

               END IF;

               x_return_status := t_return_status;

               IF (t_return_status = wsh_util_core.g_ret_sts_success)
               THEN --{

                  IF (l_trns_history_rec.document_type = 'SA') THEN --{
                     --k proj
                     -- if there is a cancellation workflow instance exist close
                     -- it. This happens when the cacellation is in progress,
                     -- but the user override the cancellation by processing
                     -- the SA from the message correction form.

                     IF WSH_TRANSACTIONS_UTIL.branch_cms_tpw_flow
                            (
                               p_event_key => l_trns_history_rec.event_key
                             )
                     THEN --{
                        OPEN c_get_cancel_record(l_trns_history_rec.entity_number);
                        FETCH c_get_cancel_record INTO l_cancel_hist_record;
                        IF c_get_cancel_record%FOUND THEN --{
                           WSH_TRANSACTIONS_UTIL.Check_cancellation_inprogress(
                               p_delivery_name => l_cancel_hist_record.entity_number,                            x_cancellation_in_progress => l_cancellation_in_progress,
                               x_return_status            => l_return_status
                           );
                           IF l_cancellation_in_progress THEN
                           -- Close the cancellation workflow instance
                              l_cancel_hist_record.Event_Name := 'ORACLE.APPS.FTE.SSNO.CONFIRM';
                              WSH_EXTERNAL_INTERFACE_SV.Raise_Event
                                      (
                                        l_cancel_hist_record, '99', l_Return_Status
                                      );
                           END IF;
                        END IF; --}
                        CLOSE c_get_cancel_record;
                     END IF; --}
                  END IF; --}

                  IF l_debug_on THEN
		   wsh_debug_sv.log (l_module_name,'Ship Request or Advice Succeeded');
                  END IF;

                 -- Update done only for 'SR' because , for 'SA', update
                 -- done in ship_advice_pkg

                  UPDATE wsh_transactions_history
                     SET transaction_status = 'SC',
                         entity_number = x_delivery_id,
                         entity_type = 'DLVY'
                   WHERE entity_type = 'DLVY_INT'
                     AND entity_number = to_char(l_delivery_interface_id)
		     AND document_type =  'SR';

		-- Delete only for 'SR' because for 'SA' delete done in ship_advice_pkg
		IF(l_trns_history_rec.document_type = 'SR') THEN
 			Delete_Interface_Records(
				L_Delivery_Interface_ID,
				X_Return_Status);
                  IF l_debug_on THEN
		   wsh_debug_sv.log (l_module_name, 'Return status after delete interface records', X_Return_Status);
                  END IF;
		END IF;

               ELSE --}
                  IF l_debug_on THEN
		   wsh_debug_sv.log (l_module_name, 'Ship Request or Advice error.');
                  END IF;

		-- Update done only for 'SR' because , for 'SA', update
		-- done in ship_advice_pkg
                  UPDATE wsh_transactions_history
                     SET transaction_status = 'ER'
                   WHERE entity_type = 'DLVY_INT'
                     AND entity_number = to_char(l_delivery_interface_id)
                     -- TPW - Distributed changes
                     AND document_type in ('SR', 'SA');

               END IF; -- if t_return_status

               --
               -- K LPN CONV. rv
               --
               IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
               THEN
               --{

                   WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                     (
                       p_in_rec             => l_lpn_in_sync_comm_rec,
                       x_return_status      => l_return_status,
                       x_out_rec            => l_lpn_out_sync_comm_rec
                     );
                   --
                   --
                   IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
                   END IF;
                   --
                   --
                   IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
                     RAISE FND_API.G_EXC_ERROR;
                   ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                   ELSE
                     IF NVL(x_return_status,wsh_util_core.g_ret_sts_success) =
                                            wsh_util_core.g_ret_sts_success
                     THEN
                        x_return_status := l_return_status;
                     END IF;
                   END IF;
               --}
               END IF;
               --
               -- K LPN CONV. rv
               --

		-- We need this commit so that the savepoints set in
		-- Process Ship Advice are committed
		-- Added on Mar 29th
               --
               -- Start code for Bugfix 4070732
               --
                IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
                --{
                   IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Process_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
                   END IF;

                   l_reset_flags := FALSE;

                   WSH_UTIL_CORE.Process_stops_for_load_tender(p_reset_flags   => l_reset_flags,
						       x_return_status => l_return_status);

                   IF l_debug_on THEN
                      WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                   END IF;

                   IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                           WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
                      RAISE FND_API.G_EXC_ERROR;
                   ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                   END IF;
                --}
                END IF;
                --
                -- End of code for Bugfix 4070732
                 --

		COMMIT;

	    ELSE
		x_return_status := wsh_util_core.g_ret_sts_error;
                -- Derive_ids returned error. Some validation has failed.
                --Need to update the status to Error. Otherwise, status will continue to 'IP'
                UPDATE wsh_transactions_history
                SET transaction_status = 'ER'
                WHERE entity_type = 'DLVY_INT'
                AND entity_number = to_char(l_delivery_interface_id)
                     AND document_type IN ('SR', 'SA');

                --
                -- K LPN CONV. rv
                --
                WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                  (
                    p_in_rec             => l_lpn_in_sync_comm_rec,
                    x_return_status      => l_return_status,
                    x_out_rec            => l_lpn_out_sync_comm_rec
                  );
                --
                --
                IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
                END IF;
                --
                --
                IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
                ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                --ELSE
                  --x_return_status := l_return_status;
                END IF;
                --
                -- K LPN CONV. rv
                --
                 --
                 -- Start code for Bugfix 4070732
                 --
                 IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
                 --{
                    IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Process_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
                   END IF;

                   l_reset_flags := FALSE;

                   WSH_UTIL_CORE.Process_stops_for_load_tender(p_reset_flags   => l_reset_flags,
						       x_return_status => l_return_status);

                   IF l_debug_on THEN
                      WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                   END IF;

                   IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                           WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
                      RAISE FND_API.G_EXC_ERROR;
                   ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                   END IF;
                 --}
                 END IF;
                 --
                 -- End of code for Bugfix 4070732
                 --
                COMMIT;

            END IF; -- End of IF (L_Return_Status ....

         ELSE -- if Not Null Check failed.
            x_return_status := wsh_util_core.g_ret_sts_error;
         END IF; -- Check for Null Values.

      END IF; -- End of (IF Entity_Type = 'DLVY_INT') ...

     END IF; --} --End of WMS_DEPLOYMENT_MODE

      --bug 4070732
      --End of the API handling of calls to process_stops_for_load_tender
      IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name)
      THEN
      --{
         IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
         --{
            l_reset_flags := TRUE;

            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Process_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

            WSH_UTIL_CORE.Process_stops_for_load_tender(p_reset_flags   => l_reset_flags,
                                                        x_return_status => l_return_status);

            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
            END IF;

            IF (
                ( l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR )
             OR ( l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR
                  AND x_return_status <> WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR )
             OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING
                  AND x_return_status NOT IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                    WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) )
               )
            THEN
            --{
               x_return_status := l_return_status;
            --}
            END IF;

          --}
          END IF;
       --}
       END IF;
      --bug 4070732

     IF l_debug_on THEN
      wsh_debug_sv.log (l_module_name,'Return Status',X_Return_Status);
      wsh_debug_sv.pop (l_module_name);
     END IF;

	--wsh_debug_sv.stop_other_app_debug('OE', l_return_status);
        wsh_debug_sv.stop_debug;
   EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
              IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
              END IF;
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --
             --
             -- Start code for Bugfix 4070732
             --
             IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name)
             THEN
             --{
                IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
                --{
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
                --}
                END IF;
              --}
             END IF;
             --
             -- End of Code Bugfix 4070732
             --

            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
               WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
             END IF;
                  --
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --
             --
             -- Start code for Bugfix 4070732
             --
             IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name)
             THEN
             --{
                IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
                --{
                  IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
                  END IF;

                  WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                     x_return_status => l_return_status);

                  IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                  END IF;
                --}
                END IF;
              --}
             END IF;
             --
             -- End of Code Bugfix 4070732
             --
             IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
             END IF;
                  --
      WHEN invalid_doc_direction
      THEN
         x_return_status := wsh_util_core.g_ret_sts_error;
          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
              IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
              END IF;
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --

	    -- Start code for Bugfix 4070732
	    --
            IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name)
            THEN
            --{
               IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
               --{
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
                --}
                END IF;
             --}
	      END IF;
	    --
	    -- End of Code Bugfix 4070732
	    --

         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'invalid_doc_direction exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:invalid_doc_direction');
         END IF;
	 wsh_debug_sv.stop_debug;
      WHEN invalid_doc_type
      THEN
         x_return_status := wsh_util_core.g_ret_sts_error;

          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
              IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
              END IF;
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --
	    --
	    -- Start code for Bugfix 4070732
	    --
            IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name)
            THEN
            --{
               IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
               --{
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
                --}
                END IF;
             --}
	      END IF;
	    --
	    -- End of Code Bugfix 4070732
	    --

         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'invalid_doc_type exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:invalid_doc_type');
         END IF;
	 wsh_debug_sv.stop_debug;
      WHEN invalid_action_type
      THEN
         x_return_status := wsh_util_core.g_ret_sts_error;
          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
              IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
              END IF;
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --

	    --
	    -- Start code for Bugfix 4070732
	    --
            IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name)
            THEN
            --{
               IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
               --{
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
                --}
                END IF;
             --}
	      END IF;
	    --
	    -- End of Code Bugfix 4070732
	    --

         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'invalid_action_type exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:invalid_action_type');
         END IF;
	 wsh_debug_sv.stop_debug;
      WHEN invalid_entity_type
      THEN
         x_return_status := wsh_util_core.g_ret_sts_error;

          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
              IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
              END IF;
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --
	    --
	    -- Start code for Bugfix 4070732
	    --
            IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name)
            THEN
            --{
               IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
               --{
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
                --}
                END IF;
             --}
	      END IF;
	    --
	    -- End of Code Bugfix 4070732
	    --

         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'invalid_entity_type exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:invalid_entity_type');
         END IF;
	 wsh_debug_sv.stop_debug;
      WHEN OTHERS
      THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         END IF;
          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --
	    --
	    -- Start code for Bugfix 4070732
	    --
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
	    --
	    -- End of Code Bugfix 4070732
	    --

         IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
	 wsh_debug_sv.stop_debug;
   END process_inbound;


/*=======================================================================================

PROCEDURE NAME : Derive_IDs

This Procedure is called from the WSH_PROCESS_INTERFACED_PKG.Process_Inbound Procedure
to Derive, Validate data in the Interface tables and update ID columns in interface tables.
This procedure includes calls to various APIs available in Shipping.

Only fields which are not being Derived/validated by any of the Public APIs(which will be
called subsequently) are Derived/Validated here.

If all the fields are successfully derived/Validated, the ID columns will be updated in
the Interface tables.
=======================================================================================*/


   PROCEDURE derive_ids (
      p_delivery_interface_id   IN       NUMBER,
      p_document_type           IN       VARCHAR2,
      x_return_status           OUT NOCOPY       VARCHAR2
   )
   IS
      CURSOR delivery_cur
      IS
         SELECT name, organization_code, customer_number,
                intmed_ship_to_location_code, initial_pickup_location_code,
                ultimate_dropoff_location_code, customer_name,
		-- TPW - Distributed changes
                ship_to_customer_name,
                ship_to_address1, ship_to_address2, ship_to_address3, ship_to_address4,
                ship_to_city, ship_to_state, ship_to_postal_code, ship_to_country
           FROM wsh_new_del_interface
          WHERE delivery_interface_id = p_delivery_interface_id
	  AND INTERFACE_ACTION_CODE = '94X_INBOUND';
      --bug 3920178
      CURSOR c_loc_org_check(p_delivery_id NUMBER, p_org_id NUMBER) IS
      SELECT 'X'
      FROM HZ_CUST_ACCT_SITES_ALL HCAS,
       HZ_CUST_SITE_USES_ALL HCSU,
       HZ_CUST_ACCOUNTS HCA,
       HZ_PARTY_SITES HPS,
       WSH_LOCATIONS WL,
       WSH_NEW_DELIVERIES WND
      WHERE wnd.delivery_id = p_delivery_id
      AND wnd.ultimate_dropoff_location_id = wl.wsh_location_id
      AND wl.location_source_code = 'HZ'
      AND wl.source_location_id = hps.location_id
      AND  HCSU.CUST_ACCT_SITE_ID = HCAS.CUST_ACCT_SITE_ID
      AND  HCAS.PARTY_SITE_ID = HPS.PARTY_SITE_ID
      AND  HCAS.CUST_ACCOUNT_ID = HCA.CUST_ACCOUNT_ID
      AND  HCSU.SITE_USE_CODE = 'SHIP_TO'
      AND  HCSU.STATUS = 'A'
      AND  HCAS.STATUS = 'A'
      AND  HCA.STATUS = 'A'
      AND  HCAS.ORG_ID = HCSU.ORG_ID
      AND WND.CUSTOMER_ID=  HCAS.cust_account_id
      AND HCAS.ORG_ID = p_org_id;
      -- removed the NVL from org_id k proj
      CURSOR delivery_detail_cur
      IS
         SELECT wddi.item_number, wddi.customer_item_number, wddi.organization_code,
                wddi.ship_from_location_code, wddi.ship_to_location_code,
                wddi.deliver_to_location_code, wddi.customer_number, wddi.subinventory,
                wddi.revision, wddi.lot_number, wddi.locator_id,
                wddi.intmed_ship_to_location_code, wddi.delivery_detail_interface_id,
		wddi.customer_name, wddi.container_flag,
		-- TPW - Distributed changes
                wddi.locator_code
           FROM wsh_del_details_interface wddi, wsh_del_assgn_interface wdai
          WHERE wdai.delivery_interface_id = p_delivery_interface_id
            AND wddi.delivery_detail_interface_id =
                                             wdai.delivery_detail_interface_id
	    AND wddi.INTERFACE_ACTION_CODE = '94X_INBOUND'
            AND wdai.INTERFACE_ACTION_CODE = '94X_INBOUND';


	CURSOR dlvy_id_cur(l_del_name VARCHAR2) IS
	SELECT delivery_id, ultimate_dropoff_location_id
	FROM wsh_new_deliveries
	WHERE name=l_del_name;

      -- bug 3920178
      CURSOR c_org_oper_unit(p_organization_id IN NUMBER) IS
      SELECT to_number(org_information3)
      FROM hr_organization_information
      WHERE organization_id = p_organization_id
      AND org_information_context = 'Accounting Information';

      interface_errors_rec             wsh_interface_validations_pkg.interface_errors_rec_type;
      l_del_count                      NUMBER;
      l_dlvy_id				NUMBER;
      l_d_temp_status                  VARCHAR2 (10)                          := ' ';
      l_dd_temp_status                 VARCHAR2 (10)                          := ' ';
      -- TPW - Distributed changes - New Variable added
      l_loc_temp_status                VARCHAR2 (10)                          := ' ';
      l_intmed_ship_to_location_id     wsh_new_del_interface.intmed_ship_to_location_id%TYPE;
      l_customer_id                    wsh_new_del_interface.customer_id%TYPE;
      l_org_id                         wsh_new_del_interface.organization_id%TYPE;
      l_initial_pickup_location_id     wsh_new_del_interface.initial_pickup_location_id%TYPE;
      l_ultimate_dropoff_location_id   wsh_new_del_interface.ultimate_dropoff_location_id%TYPE;
      l_inventory_item_id              wsh_del_details_interface.inventory_item_id%TYPE;
      l_customer_item_id               wsh_del_details_interface.customer_item_number%TYPE;
      l_det_org_id                     wsh_del_details_interface.organization_id%TYPE;
      l_ship_from_location_id          wsh_del_details_interface.ship_from_location_id%TYPE;
      l_ship_to_location_id            wsh_del_details_interface.ship_to_location_id%TYPE;
      l_det_intmed_shipto              wsh_del_details_interface.intmed_ship_to_location_id%TYPE;
      l_deliver_to_location_id         wsh_del_details_interface.intmed_ship_to_location_id%TYPE;
      l_intpickup_location_id          wsh_del_details_interface.intmed_ship_to_location_id%TYPE;
      l_det_customer_id                wsh_del_details_interface.customer_number%TYPE;
      x_result                         BOOLEAN;
      l_seg_array                      fnd_flex_ext.segmentarray;
      l_detail_customer_name		VARCHAR2(360);
      l_dlvy_customer_name		VARCHAR2(360);
      l_op_unit_id                      NUMBER;
      l_line_op_unit_id                 NUMBER;

      l_ship_to_site_use_id            wsh_del_details_interface.ship_to_site_use_id%TYPE;
      l_deliver_to_site_use_id         wsh_del_details_interface.deliver_to_site_use_id%TYPE;
      l_dummy_site_use_id              NUMBER;
      l_dummy                          VARCHAR2(10);

      -- TPW - Distributed changes
      l_ship_to_cust_id                number;
      l_return_status                  varchar2(1);
      l_warehouse_type                 varchar2(10);
      l_locator_id                     number;
      l_ou_org_id                         wsh_new_del_interface.organization_id%TYPE;

      invalid_delivery_int_id          EXCEPTION;
      invalid_delivery_name	       EXCEPTION;
      invalid_customer_name            EXCEPTION;
      -- TPW - Distributed changes
      get_warehouse_type_failed        EXCEPTION;

	--
l_debug_on BOOLEAN;
	--
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DERIVE_IDS';
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
      wsh_debug_sv.push (l_module_name, 'DERIVE_IDS');
      wsh_debug_sv.log (l_module_name,'DELIVERY_INTERFACE_ID',p_delivery_interface_id);
     END IF;

      /* Check if the values passed are valid */

      IF (p_delivery_interface_id IS NULL)
      THEN
         RAISE invalid_delivery_int_id;
      END IF;

      SELECT COUNT (delivery_interface_id)
        INTO l_del_count
        FROM wsh_new_del_interface
       WHERE delivery_interface_id = p_delivery_interface_id
	AND INTERFACE_ACTION_CODE = '94X_INBOUND';

      IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name, 'l_del_count',l_del_count);
      END IF;

      IF (l_del_count <> 1)
      THEN
         RAISE invalid_delivery_int_id;
      END IF;

      FOR delivery_rec IN delivery_cur
      LOOP
       IF l_debug_on THEN
        wsh_debug_sv.log (l_module_name,'Inside Delivery Rec Loop');
	wsh_debug_sv.log (l_module_name, 'Delivery Attributes');
	wsh_debug_sv.log (l_module_name, 'Delivery Name', delivery_rec.name);
	wsh_debug_sv.log (l_module_name, 'Org Code', delivery_rec.organization_code);
	wsh_debug_sv.log (l_module_name, 'Initial pickup', delivery_rec.initial_pickup_location_code);
	wsh_debug_sv.log (l_module_name, 'Ultimate Dropoff', delivery_rec.ultimate_dropoff_location_code);
	wsh_debug_sv.log (l_module_name, 'IntMed ShipTo', delivery_rec.intmed_ship_to_location_code);
	wsh_debug_sv.log (l_module_name, 'Customer Name', delivery_rec.customer_name);
       END IF;

         WSH_UTIL_VALIDATE.Validate_Org (
            l_org_id,
            delivery_rec.organization_code,
            x_return_status);

        IF l_debug_on THEN
         wsh_debug_sv.log (l_module_name,'Status after validate_org',x_return_status);
	END IF;

         IF (x_return_status <> wsh_util_core.g_ret_sts_success)
         THEN
            interface_errors_rec.p_token1 := 'Organization_Code';
            interface_errors_rec.p_value1 := delivery_rec.organization_code;
            l_d_temp_status := 'INVALID';
         END IF;
        --bug 3920178

       -- TPW - Distributed changes
       -- check for warehouse type
       l_warehouse_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type(
                P_Organization_ID       => l_org_id,
                X_Return_Status         => l_return_status);

       IF l_debug_on THEN
          wsh_debug_sv.log (l_module_name, 'Return status from get warehouse type', l_return_status);
          wsh_debug_sv.log (l_module_name, 'Warehouse type ', l_warehouse_type);
       END IF;

       IF(l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                raise get_warehouse_type_failed;
       END IF;


        OPEN c_org_oper_unit (l_org_id);
        FETCH c_org_oper_unit INTO l_op_unit_id;
        CLOSE c_org_oper_unit;

        IF l_op_unit_id IS NULL THEN
        --{
           --
           IF l_debug_on THEN
            wsh_debug_sv.logmsg(l_module_name, 'Error: Location Org match not found');
            END IF;
           --

         interface_errors_rec.p_token1 := 'Operating_unit';
         interface_errors_rec.p_value1 := NULL;
         l_d_temp_status := 'INVALID';

        --}
        END IF;

        -- TPW - Distributed changes
        WSH_UTIL_VALIDATE.Validate_Location(
           l_initial_pickup_location_id,
           delivery_rec.initial_pickup_location_code,
           x_return_status);

        IF l_debug_on THEN
           wsh_debug_sv.log (l_module_name,'Status after Initial_pickup_location ',x_return_status);
        END IF;

        IF (x_return_status <> wsh_util_core.g_ret_sts_success)
        THEN
           interface_errors_rec.p_token2 := 'Initial Pickup Location Code';
           interface_errors_rec.p_value2 := delivery_rec.initial_pickup_location_code;
           l_d_temp_status := 'INVALID';
        END IF;

        -- TPW - Distributed changes
        IF (p_document_type = 'SA' AND (nvl(l_warehouse_type, '!') = 'TW2')) THEN --{
                IF l_debug_on THEN
                  wsh_debug_sv.log (l_module_name, 'Validating Customer Name');
                END IF;

                --Calling Get_Operating_Unit to get the org_id of the organization_id
                l_ou_org_id := WSH_UTIL_CORE.Get_Operating_Unit (p_organization_id => l_org_id);
                --Set the Policy Context before calling OM API
                MO_GLOBAL.set_policy_context('S', l_ou_org_id);

                IF ( delivery_rec.customer_name is not null )
                THEN
                   --
                   IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name, 'Calling OE_Value_To_Id.Sold_To_Org', WSH_DEBUG_SV.C_PROC_LEVEL);
                   END IF;
                   --
                   l_customer_id := OE_Value_To_Id.Sold_To_Org(
                                         p_sold_to_org     => delivery_rec.customer_name,
                                         p_customer_number => NULL );

                   --
                   IF l_debug_on THEN
                      WSH_DEBUG_SV.log(l_module_name, 'SoldTo Customer derived from Customer Name', l_customer_id );
                   END IF;
                   --

                   IF nvl(l_customer_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN
                      l_customer_id := null;
                      IF (x_return_status <> wsh_util_core.g_ret_sts_success)
                      THEN
                         interface_errors_rec.p_token3 := 'Customer Name';
                         interface_errors_rec.p_value3 := delivery_rec.customer_name;
                         l_d_temp_status := 'INVALID';
                      END IF;

                   END IF;
                END IF;

                -- Ship-To Customer
                IF l_debug_on THEN
                  wsh_debug_sv.log (l_module_name, 'Validating Ship To Customer Name');
                END IF;
                IF (delivery_rec.ship_to_customer_name is not null)
                THEN
                   --Check if ShipTo Customer is same as SoldTo
                   IF ( delivery_rec.ship_to_customer_name = delivery_rec.customer_name )
                   THEN
                      l_ship_to_cust_id := l_customer_id;
                   ELSE
                      --
                      IF l_debug_on THEN
                         WSH_DEBUG_SV.logmsg(l_module_name, 'Calling OE_Value_To_Id.Sold_To_Org to derive Ship-To customer', WSH_DEBUG_SV.C_PROC_LEVEL);
			 WSH_DEBUG_SV.logmsg(l_module_name, 'delivery_rec.ship_to_customer_name ='||delivery_rec.ship_to_customer_name, WSH_DEBUG_SV.C_PROC_LEVEL);
                      END IF;
                      --
                      l_ship_to_cust_id := OE_Value_To_Id.Sold_To_Org(
                                            p_sold_to_org     => delivery_rec.ship_to_customer_name,
                                            p_customer_number => NULL );

		      WSH_DEBUG_SV.logmsg(l_module_name, 'l_ship_to_cust_id = '||l_ship_to_cust_id, WSH_DEBUG_SV.C_PROC_LEVEL);

                      IF nvl(l_ship_to_cust_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN
                         l_ship_to_cust_id := null;
                         IF (x_return_status <> wsh_util_core.g_ret_sts_success)
                         THEN
                            interface_errors_rec.p_token3 := 'Ship To Customer Name';
                            interface_errors_rec.p_value3 := delivery_rec.ship_to_customer_name;
                            l_d_temp_status := 'INVALID';
                         END IF;
                      END IF;
                   END IF;

                   IF (l_ship_to_cust_id is not null) THEN

                      IF (delivery_rec.ship_to_address1 is not null)
                      THEN
                         --
                         IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name, 'Calling OE_Value_To_Id.Ship_To_Org', WSH_DEBUG_SV.C_PROC_LEVEL);
                         END IF;
                         --
                         l_ship_to_site_use_id :=
                               OE_Value_To_Id.Ship_To_Org(
                                        p_ship_to_address1    => delivery_rec.ship_to_address1,
                                        p_ship_to_address2    => delivery_rec.ship_to_address2,
                                        p_ship_to_address3    => delivery_rec.ship_to_address3,
                                        p_ship_to_address4    => delivery_rec.ship_to_address4,
                                        p_ship_to_location    => NULL,
                                        p_ship_to_org         => NULL,
                                        p_sold_to_org_id      => l_ship_to_cust_id,
                                        p_ship_to_city        => delivery_rec.ship_to_city,
                                        p_ship_to_state       => delivery_rec.ship_to_state,
                                        p_ship_to_postal_code => delivery_rec.ship_to_postal_code,
                                        p_ship_to_country     => delivery_rec.ship_to_country,
                                        p_ship_to_customer_id => l_ship_to_cust_id);

                         --
                         IF l_debug_on THEN
                            WSH_DEBUG_SV.log(l_module_name, 'ShipTo Site Use Id', l_ship_to_site_use_id);
                         END IF;
                         IF ( nvl(l_ship_to_site_use_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM )
                         THEN
                            l_ship_to_site_use_id := null;
                            IF (x_return_status <> wsh_util_core.g_ret_sts_success)
                            THEN
                               interface_errors_rec.p_token3 := 'Ship To Address';
                               interface_errors_rec.p_value3 := delivery_rec.ship_to_address1;
                               l_d_temp_status := 'INVALID';
                            END IF;
                         END IF;
                      END IF;

                      IF l_ship_to_site_use_id is not null THEN
                            WSH_UTIL_CORE.GET_LOCATION_ID('CUSTOMER SITE',
                               l_ship_to_site_use_id,
                               l_ultimate_dropoff_location_id,
                               l_return_status);
                           IF l_debug_on THEN
                             WSH_DEBUG_SV.logmsg(l_module_name, 'l_return_status '||l_return_status||' Ult Loc Id '||l_ultimate_dropoff_location_id);
                           END IF;
                      END IF;
                   END IF;
                END IF;

        ELSE --} {


	-- derive the delivery id for Shipment Advice inbound
	IF(p_document_type = 'SA') THEN
		OPEN dlvy_id_cur(delivery_rec.name);
		FETCH dlvy_id_cur INTO l_dlvy_id, l_ship_to_location_id;

		IF(dlvy_id_cur%NOTFOUND) THEN
			raise invalid_delivery_name;
		END IF;

		CLOSE dlvy_id_cur;
	END IF; -- if p_document_type = SA

	-- Logic to handle cases where delivery does not have customer information
	-- Select the distinct customer_name from this delivery's delivery details
	-- If there is more than one distinct customer_name at the delivery detail level,
	-- Raise an exception because that is an invalid case

	IF(delivery_rec.customer_name IS NULL) THEN
               IF l_debug_on THEN
		wsh_debug_sv.log (l_module_name, 'Delivery Rec customer name is null');
               END IF;

		BEGIN
			SELECT DISTINCT customer_name
			INTO l_detail_customer_name
			FROM wsh_del_details_interface wddi, wsh_del_assgn_interface wdai
			WHERE wddi.delivery_detail_interface_id = wdai.delivery_detail_interface_id
			AND wddi.customer_name IS NOT NULL
			AND wdai.delivery_interface_id = p_delivery_interface_id
			AND wddi.INTERFACE_ACTION_CODE = '94X_INBOUND'
			AND wdai.INTERFACE_ACTION_CODE = '94X_INBOUND';
                        IF l_debug_on THEN
		  	 wsh_debug_sv.log (l_module_name, 'Detail Rec distinct customer name', l_detail_customer_name);
                        END IF;

			IF l_detail_customer_name IS NOT NULL THEN
				delivery_rec.customer_name := l_detail_customer_name;
			ELSE
				raise invalid_customer_name;
			END IF;

		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				raise invalid_customer_name;
			WHEN TOO_MANY_ROWS THEN
                               IF l_debug_on THEN
				wsh_debug_sv.log (l_module_name, 'Multiple distinct customer_names for details');
                               END IF;
				raise invalid_customer_name;
		END;
	END IF; -- if delivery_rec.customer_name

	-- store the delivery rec customer name for possible use at delivery detail level
	l_dlvy_customer_name := delivery_rec.customer_name;

	IF(delivery_rec.intmed_ship_to_location_code IS NOT NULL) THEN
         IF l_debug_on THEN
	  wsh_debug_sv.log (l_module_name, 'Organization id for delivery ' || l_org_id);
         END IF;

		WSH_EXTERNAL_INTERFACE_SV.Validate_Ship_To(
			p_customer_name		=> delivery_rec.customer_name,
			p_location		=> delivery_rec.intmed_ship_to_location_code,
			x_customer_id		=> l_customer_id,
			x_location_id		=> l_intmed_ship_to_location_id,
			x_return_status		=> x_return_status,
                        p_site_use_code		=> 'SHIP_TO',
                        x_site_use_id		=> l_dummy_site_use_id);


                IF l_debug_on THEN
        	 wsh_debug_sv.log (l_module_name,'Status after Intmed_ship_to_location_code',x_return_status);
                END IF;

	         IF (x_return_status <> wsh_util_core.g_ret_sts_success) THEN
	            interface_errors_rec.p_token2 := 'Intmed_Ship_To_Location_Code';
        	    interface_errors_rec.p_value2 := delivery_rec.intmed_ship_to_location_code;
	            l_d_temp_status := 'INVALID';
        	 END IF;
	END IF;

        IF l_debug_on THEN
	 wsh_debug_sv.log (l_module_name, 'Organization id for delivery - 2 ' || l_org_id);
        END IF;
        IF p_document_type <> 'SA' THEN --{ bug 3920178

	   WSH_EXTERNAL_INTERFACE_SV.Validate_Ship_To(
			p_customer_name 	=> delivery_rec.customer_name,
			p_location 		=> delivery_rec.ultimate_dropoff_location_code,
			x_customer_id 		=> l_customer_id,
			x_location_id 		=> l_ultimate_dropoff_location_id,
			x_return_status 	=> x_return_status,
                        p_site_use_code		=> 'SHIP_TO',
                        x_site_use_id		=> l_dummy_site_use_id,
                        p_org_id                => l_op_unit_id);

        IF l_debug_on THEN
         wsh_debug_sv.log (l_module_name,'Status after ultimate_dropoff_location ',x_return_status);
        END IF;

         IF (x_return_status <> wsh_util_core.g_ret_sts_success)
         THEN
            interface_errors_rec.p_token5 := 'Ultimate Dropoff Location Code';
            interface_errors_rec.p_value5 := delivery_rec.ultimate_dropoff_location_code;
            l_d_temp_status := 'INVALID';
         END IF;
       END IF; -- bug 3920178 }
      END IF; --}

         /* Update ID fields in interface table only if all the validations succeeded */

        IF l_debug_on THEN
	 wsh_debug_sv.log (l_module_name, 'l_d_temp_status',l_d_temp_status);
        END IF;

         IF (l_d_temp_status <> 'INVALID')
         THEN
            UPDATE wsh_new_del_interface
               SET delivery_id = decode(p_document_type, 'SA',l_dlvy_id,delivery_id),
		   customer_id = l_customer_id,
                   organization_id = l_org_id,
                   intmed_ship_to_location_id = l_intmed_ship_to_location_id,
                   initial_pickup_location_id = l_initial_pickup_location_id,
                   ultimate_dropoff_location_id = l_ultimate_dropoff_location_id
             WHERE delivery_interface_id = p_delivery_interface_id;

            -- TPW - Distributed changes
            IF nvl(WSH_INBOUND_SHIP_ADVICE_PKG.G_WAREHOUSE_TYPE, '!') in ('TPW', 'CMS') THEN
                 UPDATE wsh_del_legs_interface
                 SET delivery_id = l_dlvy_id
                 WHERE delivery_interface_id = p_delivery_interface_id;
	    END IF;
         END IF;

         IF (l_d_temp_status = 'INVALID')
         THEN
            interface_errors_rec.p_interface_table_name := 'WSH_NEW_DEL_INTERFACE';
            interface_errors_rec.p_interface_id := p_delivery_interface_id;
            wsh_interface_validations_pkg.log_interface_errors (
				p_interface_errors_rec   =>interface_errors_rec,
				p_api_name   =>'WSH_EXTERNAL_INTERFACE_SV.Validate_Ship_To',
				x_return_status  =>x_return_status);
            IF l_debug_on THEN
	     wsh_debug_sv.log (l_module_name, 'log_interface_errors x_return_status',x_return_status);
            END IF;
         END IF;
      END LOOP;

      -- TPW - Distributed changes
      IF l_debug_on THEN
         wsh_debug_sv.log (l_module_name, '*** Validating Delivery details interface ***');
      END IF;

      FOR delivery_detail_rec IN delivery_detail_cur
      LOOP

         l_locator_id := null;
         l_loc_temp_status := ' ';

	 -- Validation for Org
         WSH_UTIL_VALIDATE.Validate_Org(
		l_det_org_id,
		delivery_detail_rec.organization_code,
		x_return_status);

         IF l_debug_on THEN
          wsh_debug_sv.log (l_module_name, 'Organization Code' , delivery_detail_rec.organization_code);
          wsh_debug_sv.log (l_module_name, 'Derived Org id', l_det_org_id);
          wsh_debug_sv.log (l_module_name, 'Status after validate org for detail',x_return_status);
         END IF;

         IF (x_return_status = wsh_util_core.g_ret_sts_error)
         THEN
            interface_errors_rec.p_token1 := 'Organization Code';
            interface_errors_rec.p_value1 :=delivery_detail_rec.organization_code;
            l_dd_temp_status := 'INVALID';
         END IF;
        --bug 3920178

        OPEN c_org_oper_unit (l_det_org_id);
        FETCH c_org_oper_unit INTO l_line_op_unit_id;
        CLOSE c_org_oper_unit;


        IF l_line_op_unit_id IS NULL
        THEN
        --{
           --
           IF l_debug_on THEN
            wsh_debug_sv.logmsg(l_module_name, 'Error: Location Org match not found');
            END IF;
           --

         interface_errors_rec.p_token1 := 'Operating_unit'; --bmso
         interface_errors_rec.p_value1 := NULL;
         l_d_temp_status := 'INVALID';

        --}
        END IF;


	-- Validation for Item
	WSH_EXTERNAL_INTERFACE_SV.Validate_Item (
		p_concatenated_segments => Delivery_Detail_Rec.Item_Number,
                             p_organization_id =>L_Det_org_ID,
                             x_inventory_item_id => L_Inventory_Item_ID,
                             x_return_status  =>X_Return_Status);

         IF l_debug_on THEN
	  wsh_debug_sv.log (l_module_name, 'Return status after validate item',X_Return_Status);
     	  wsh_debug_sv.log (l_module_name, 'Item Number', Delivery_Detail_Rec.Item_Number);
	  wsh_debug_sv.log (l_module_name, 'Derived Item Id', L_Inventory_Item_ID);
         END IF;
	IF (x_return_status <> WSH_UTIL_CORE.g_ret_sts_success) Then
         Interface_Errors_rec.P_token2 := 'Item Number';
         Interface_Errors_rec.P_value2 := Delivery_Detail_Rec.Item_Number;
         L_DD_Temp_Status := 'INVALID';
	End If;

	/*
	WSH_UTIL_VALIDATE. Validate_Item(L_Customer_item_ID,
			                      Delivery_Detail_Rec.Customer_Item_Number,
                                        L_Det_org_ID,
                                        L_Seg_Array,
                                        X_Return_Status);

       IF (x_return_status <> WSH_UTIL_CORE.g_ret_sts_success) Then
         Interface_Errors_rec.P_token3 := 'Customer Item Number';
         Interface_Errors_rec.P_value3 := Delivery_Detail_Rec.Customer_Item_Number;
            L_DD_Temp_Status := 'INVALID';
       End If;   */

       IF nvl(l_warehouse_type, '!') in ('TW2') THEN -- {
	 -- Validation for Locator Id
         If (Delivery_Detail_Rec.locator_id is null) and (Delivery_Detail_Rec.Locator_code is not null) THEN
           WSH_UTIL_VALIDATE.Validate_Locator_Code (
             p_locator_code => Delivery_Detail_Rec.Locator_code,
             p_organization_id =>L_Det_org_ID,
             x_locator_id => l_locator_id,
             x_return_status  =>X_Return_Status);

           IF l_debug_on THEN
  	     wsh_debug_sv.log (l_module_name, 'Return status after Validate Locator Code',X_Return_Status);
       	     wsh_debug_sv.log (l_module_name, 'Locator Code', Delivery_Detail_Rec.Locator_code);
  	     wsh_debug_sv.log (l_module_name, 'Derived Locator Id', l_locator_id);
           END IF;
  	   IF (x_return_status <> WSH_UTIL_CORE.g_ret_sts_success) Then
             Interface_Errors_rec.P_token3 := 'Locator Code';
             Interface_Errors_rec.P_value3 := Delivery_Detail_Rec.Locator_code;
             l_loc_temp_status := 'INVALID';
  	   End If;
         Else
          l_locator_id := Delivery_Detail_Rec.locator_id;
         END IF;

       ELSE

	 -- Validation for Ship From
         WSH_UTIL_VALIDATE.Validate_Location(
		l_ship_from_location_id,
		delivery_detail_rec.ship_from_location_code,
		x_return_status);

         IF (x_return_status = wsh_util_core.g_ret_sts_error)
         THEN
            interface_errors_rec.p_token4 := 'Ship From Location Code';
            interface_errors_rec.p_value4 := delivery_detail_rec.ship_from_location_code;
            l_dd_temp_status := 'INVALID';
         END IF;

	-- Logic for delivery detail customer_name
	-- If the detail does not have a customer name, get the delivery's customer_name
	-- If the delivery customer_name is also null, then raise an exception. Invalid case.
	IF(delivery_detail_rec.customer_name IS NULL) THEN
		IF(l_dlvy_customer_name IS NOT NULL) THEN
			delivery_detail_rec.customer_name := l_dlvy_customer_name;
		ELSE
			raise invalid_customer_name;
		END IF;
	END IF;

	-- Validation for Ship To
	-- Ship To does not at the container level , in the inbound message
	-- Hence we need to validate the ship to only for non-containers.
	IF (delivery_detail_rec.container_flag = 'N') THEN
         IF l_debug_on THEN
	  wsh_debug_sv.log (l_module_name, 'Organization id for delivery detail ',l_det_org_id);
         END IF;
         IF p_document_type <> 'SA' THEN --{ bug 3920178
		WSH_EXTERNAL_INTERFACE_SV.Validate_Ship_To(
			p_customer_name 	=> delivery_detail_rec.customer_name,
			p_location 		=> delivery_detail_rec.ship_to_location_code,
			x_customer_id 		=> l_det_customer_id,
			x_location_id 		=> l_ship_to_location_id,
			x_return_status 	=> x_return_status,
                        p_site_use_code		=> 'SHIP_TO',
                        x_site_use_id		=> l_ship_to_site_use_id);

                 IF l_debug_on THEN
	          wsh_debug_sv.log (l_module_name, 'Validate_Ship_To x_return_status',x_return_status );
                 END IF;

        	 IF (x_return_status <> wsh_util_core.g_ret_sts_success) THEN
	            interface_errors_rec.p_token5 := 'Ship To Location Code';
        	    interface_errors_rec.p_value5 := delivery_detail_rec.ship_to_location_code;
	            l_dd_temp_status := 'INVALID';
        	 END IF;
	END IF;

	-- Validation for Int_Med Ship To
	IF(delivery_detail_rec.intmed_ship_to_location_code IS NOT NULL) THEN
         IF l_debug_on THEN
	  wsh_debug_sv.log (l_module_name, 'Organization id for delivery detail - 2' ,l_det_org_id);
         END IF;
		WSH_EXTERNAL_INTERFACE_SV.Validate_Ship_To(
			p_customer_name 	=> delivery_detail_rec.customer_name,
			p_location 		=> delivery_detail_rec.intmed_ship_to_location_code,
			x_customer_id 		=> l_det_customer_id,
			x_location_id 		=> l_det_intmed_shipto,
			x_return_status 	=> x_return_status,
                        p_site_use_code		=> 'SHIP_TO',
                        x_site_use_id		=> l_ship_to_site_use_id);

                 IF l_debug_on THEN
	          wsh_debug_sv.log (l_module_name, 'Validate_Ship_To x_return_status',x_return_status );
                 END IF;
        	 IF (x_return_status <> wsh_util_core.g_ret_sts_success) THEN
	            interface_errors_rec.p_token6 := 'IntMed ShipTo Location Code';
        	    interface_errors_rec.p_value6 := delivery_detail_rec.intmed_ship_to_location_code;
	            l_dd_temp_status := 'INVALID';
        	 END IF;
	END IF;

	-- Validation for Deliver To
	IF (delivery_detail_rec.container_flag = 'N') THEN
         IF l_debug_on THEN
	  wsh_debug_sv.log (l_module_name, 'Organization id for delivery detail' ,l_det_org_id);
         END IF;

		WSH_EXTERNAL_INTERFACE_SV.Validate_Ship_To(
			p_customer_name 	=> delivery_detail_rec.customer_name,
			p_location 		=> delivery_detail_rec.deliver_to_location_code,
			x_customer_id 		=> l_det_customer_id,
			x_location_id 		=> l_deliver_to_location_id,
			x_return_status 	=> x_return_status,
                        p_site_use_code		=> 'DELIVER_TO',
                        --bug 3960768
                        --x_site_use_id		=> l_ship_to_site_use_id);
                        x_site_use_id		=> l_deliver_to_site_use_id);

                 IF l_debug_on THEN
	          wsh_debug_sv.log (l_module_name, 'Validate_Ship_To x_return_status',x_return_status );
                 END IF;

        	 IF (x_return_status <> wsh_util_core.g_ret_sts_success) THEN
	            interface_errors_rec.p_token7 := 'Deliver To Location Code';
        	    interface_errors_rec.p_value7 := delivery_detail_rec.deliver_to_location_code;
	            l_dd_temp_status := 'INVALID';
        	 END IF;
          END IF; --} matches if p_document_type <> SA
	END IF;

	/*
         wsh_util_validate.validate_customer(l_det_customer_id,
						         delivery_detail_rec.customer_number,
						         x_return_status);

         IF (x_return_status <> wsh_util_core.g_ret_sts_success)
         THEN
            interface_errors_rec.p_token8 := 'Customer Number';
            interface_errors_rec.p_value8 := delivery_detail_rec.customer_number;
            l_dd_temp_status := 'INVALID';
         END IF;
	*/

         /* Call validation APIs for Lot and Subinventory etc which are not validated
         in any of the APIs which will be called to populate data into base tables for
         a 940 Transaction */

         IF (p_document_type = 'SR')
         THEN
            IF (delivery_detail_rec.subinventory IS NOT NULL)
            THEN
               wsh_delivery_details_inv.validate_subinventory (p_subinventory      => delivery_detail_rec.subinventory,
							       p_organization_id   => l_det_org_id,
							       p_inventory_item_id => l_inventory_item_id,
							       x_return_status     => x_return_status,
							       x_result => x_result);

               IF (x_return_status <> wsh_util_core.g_ret_sts_success)
               THEN
                  interface_errors_rec.p_token9 := 'Subinventory';
                  interface_errors_rec.p_value9 := delivery_detail_rec.subinventory;
                  l_dd_temp_status := 'INVALID';
               END IF;
            END IF;

            IF (delivery_detail_rec.revision IS NOT NULL)
            THEN
               wsh_delivery_details_inv.validate_revision (delivery_detail_rec.revision,
							                 l_det_org_id,
						                       l_inventory_item_id,
							                 x_return_status,
							                 x_result
               );

               IF (x_return_status <> wsh_util_core.g_ret_sts_success)
               THEN
                  interface_errors_rec.p_token10 := 'Revision';
                  interface_errors_rec.p_value10 := delivery_detail_rec.revision;
                  l_dd_temp_status := 'INVALID';
               END IF;
            END IF;

            IF (delivery_detail_rec.lot_number IS NOT NULL)
            THEN
               wsh_delivery_details_inv.validate_lot_number (p_lot_number        => delivery_detail_rec.lot_number,
							     p_organization_id   => l_det_org_id,
							     p_inventory_item_id => l_inventory_item_id,
							     p_subinventory      => delivery_detail_rec.subinventory,
							     p_revision          => delivery_detail_rec.revision,
							     p_locator_id        => delivery_detail_rec.locator_id,
							     x_return_status     => x_return_status,
							     x_result            => x_result);

               IF (x_return_status <> wsh_util_core.g_ret_sts_success)
               THEN
                  interface_errors_rec.p_token11 := 'Lot Number';
                  interface_errors_rec.p_value11 := delivery_detail_rec.lot_number;
                  l_dd_temp_status := 'INVALID';
               END IF;
            END IF;

         END IF; -- End of IF (P_Document_Type ='SR' ....
       END IF; --}

         /* Update ID fields in interface table only if all the validations succeeded */
       IF l_debug_on THEN
	wsh_debug_sv.log (l_module_name, 'Delivery ID', l_dlvy_id);
	wsh_debug_sv.log (l_module_name, 'l_dd_temp_status', l_dd_temp_status);
        wsh_debug_sv.log (l_module_name, 'l_loc_temp_status', l_loc_temp_status);
       END IF;

         IF (l_dd_temp_status <> 'INVALID')
         THEN
            UPDATE wsh_del_details_interface
               SET inventory_item_id = l_inventory_item_id,
                   customer_item_id = l_customer_item_id,
                   organization_id = l_det_org_id,
                   ship_from_location_id = l_ship_from_location_id,
                   ship_to_location_id = l_ship_to_location_id,
                   intmed_ship_to_location_id = l_det_intmed_shipto,
                   deliver_to_location_id = l_deliver_to_location_id,
                   customer_id = l_det_customer_id,
		   ship_to_site_use_id = l_ship_to_site_use_id,
		   deliver_to_site_use_id = l_deliver_to_site_use_id,
                   org_id                 = l_line_op_unit_id,
                   -- TPW - Distributed changes
                   locator_id = l_locator_id,
		   source_header_id = decode(p_document_type, 'SR', l_dlvy_id, source_header_id)
             WHERE delivery_detail_interface_id = delivery_detail_rec.delivery_detail_interface_id;

         END IF;

         -- TPW - Distributed changes - added l_loc_temp_status status check
         IF (l_dd_temp_status = 'INVALID' or l_loc_temp_status = 'INVALID' )
         THEN
            interface_errors_rec.p_interface_table_name := 'WSH_DEL_DETAILS_INTERFACE';
            interface_errors_rec.p_interface_id := delivery_detail_rec.delivery_detail_interface_id;
            wsh_interface_validations_pkg.log_interface_errors (
					p_interface_errors_rec   =>interface_errors_rec,
                                        p_api_name   => 'wsh_delivery_details_inv.validate_lot_number',
					x_return_status =>x_return_status);
             IF l_debug_on THEN
	      wsh_debug_sv.log (l_module_name, 'log_interface_errors x_return_status', x_return_status);
             END IF;
         END IF;
      END LOOP;

      IF  (l_dd_temp_status <> 'INVALID') AND (l_d_temp_status <> 'INVALID')
      THEN
         x_return_status := wsh_util_core.g_ret_sts_success;
      ELSE
         x_return_status := wsh_util_core.g_ret_sts_error;
      END IF;

      wsh_debug_sv.pop (l_module_name);
   EXCEPTION
	WHEN invalid_delivery_name THEN
		IF(dlvy_id_cur%ISOPEN) THEN
			CLOSE dlvy_id_cur;
		END IF;
		x_return_status :=  wsh_util_core.g_ret_sts_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'invalid_delivery_name exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:invalid_delivery_name');
         END IF;

      WHEN invalid_delivery_int_id THEN
         x_return_status := wsh_util_core.g_ret_sts_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'invalid_delivery_int_id exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:invalid_delivery_int_id');
         END IF;
      WHEN invalid_customer_name THEN
		x_return_status :=  wsh_util_core.g_ret_sts_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'invalid_customer_name exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:invalid_customer_name');
         END IF;
      WHEN get_warehouse_type_failed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'get_warehouse_type_failed exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:get_warehouse_type_failed');
        END IF;
      WHEN OTHERS THEN
         x_return_status := wsh_util_core.g_ret_sts_unexp_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
   END derive_ids;


/*=======================================================================================

PROCEDURE NAME : Delete_Interface_Records

This Procedure will be used to delete record in the different interface tables, after data
is populated in the base tables ????

=======================================================================================*/

   PROCEDURE delete_interface_records (
      p_delivery_interface_id   IN       NUMBER,
      x_return_status           OUT NOCOPY       VARCHAR2
   )
   IS
      l_transaction_status   wsh_transactions_history.transaction_status%TYPE;
      invalid_delete         EXCEPTION;
      invalid_delivery       EXCEPTION;

      CURSOR detail_interface_ids
      IS
         SELECT delivery_detail_interface_id, del_assgn_interface_id
           FROM wsh_del_assgn_interface
          WHERE delivery_interface_id = p_delivery_interface_id
	  AND INTERFACE_ACTION_CODE = '94X_INBOUND';

      CURSOR ids
      IS
         SELECT wdli.delivery_leg_interface_id,
                wdli.pick_up_stop_interface_id,
                wdli.drop_off_stop_interface_id, wtsi.trip_interface_id
           FROM wsh_del_legs_interface wdli, wsh_trip_stops_interface wtsi
          WHERE wdli.delivery_interface_id = p_delivery_interface_id
            AND wdli.pick_up_stop_interface_id = wtsi.stop_interface_id
 	    AND wdli.INTERFACE_ACTION_CODE = '94X_INBOUND'
	    AND wtsi.INTERFACE_ACTION_CODE = '94X_INBOUND';

      l_del_count            NUMBER;
      --
l_debug_on BOOLEAN;
      --
      l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELETE_INTERFACE_RECORDS';
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
      wsh_debug_sv.push (l_module_name, 'DELETE INTERFACE RECORDS');
      wsh_debug_sv.log ( l_module_name, 'DELIVERY INTERFACE ID', p_delivery_interface_id);
     END IF;

      SELECT COUNT (*)
        INTO l_del_count
        FROM wsh_new_del_interface
       WHERE delivery_interface_id = p_delivery_interface_id
	AND INTERFACE_ACTION_CODE = '94X_INBOUND';

      IF (l_del_count <> 0)
      THEN
         FOR ids_rec IN ids
         LOOP

            DELETE wsh_del_legs_interface
            WHERE  delivery_leg_interface_id = ids_rec.delivery_leg_interface_id
		AND INTERFACE_ACTION_CODE = '94X_INBOUND';

            --Added for bug 7615007
            DELETE  wsh_freight_costs_interface
            WHERE   delivery_leg_interface_id = ids_rec.delivery_leg_interface_id
                    AND INTERFACE_ACTION_CODE = '94X_INBOUND';

            DELETE wsh_trip_stops_interface
            WHERE stop_interface_id IN
                              (ids_rec.pick_up_stop_interface_id,
                               ids_rec.drop_off_stop_interface_id
                              )
		AND INTERFACE_ACTION_CODE = '94X_INBOUND';

            --Added for bug 7615007
            DELETE  wsh_freight_costs_interface
            WHERE   stop_interface_id IN
                              (ids_rec.pick_up_stop_interface_id,
                               ids_rec.drop_off_stop_interface_id
                              )
                    AND INTERFACE_ACTION_CODE = '94X_INBOUND';

            DELETE wsh_trips_interface
            WHERE trip_interface_id = ids_rec.trip_interface_id
		AND INTERFACE_ACTION_CODE = '94X_INBOUND';

            --Added for bug 7615007
            DELETE  wsh_freight_costs_interface
            WHERE   trip_interface_id = ids_rec.trip_interface_id
                    AND INTERFACE_ACTION_CODE = '94X_INBOUND';

         END LOOP; -- End of FOR IDs_Rec IN IDs LOOP

         FOR detail_interface_ids_rec IN detail_interface_ids
         LOOP
            DELETE wsh_del_details_interface
             WHERE delivery_detail_interface_id = detail_interface_ids_rec.delivery_detail_interface_id
		AND INTERFACE_ACTION_CODE = '94X_INBOUND';

            --Added for bug 7615007
            DELETE  wsh_freight_costs_interface
            WHERE   delivery_detail_interface_id = detail_interface_ids_rec.delivery_detail_interface_id
                AND INTERFACE_ACTION_CODE = '94X_INBOUND';

            DELETE wsh_del_assgn_interface
             WHERE delivery_detail_interface_id = detail_interface_ids_rec.delivery_detail_interface_id
		AND INTERFACE_ACTION_CODE = '94X_INBOUND';
         END LOOP; -- End of FOR Details_Interface_IDs_Rec ...

         DELETE wsh_new_del_interface
          WHERE delivery_interface_id = p_delivery_interface_id
		AND INTERFACE_ACTION_CODE = '94X_INBOUND';

         --Added for bug 7615007
         DELETE   wsh_freight_costs_interface
         WHERE    delivery_interface_id = p_delivery_interface_id
                  AND INTERFACE_ACTION_CODE = '94X_INBOUND';

         x_return_status := wsh_util_core.g_ret_sts_success;
      ELSE -- IF Delivery Doesnot exists
         RAISE invalid_delivery;
      END IF;

      wsh_debug_sv.pop (l_module_name);
   EXCEPTION
      WHEN invalid_delivery
      THEN
         x_return_status := wsh_util_core.g_ret_sts_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'invalid_delivery exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:invalid_delivery');
         END IF;
      WHEN invalid_delete
      THEN
         x_return_status := wsh_util_core.g_ret_sts_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'invalid_delete exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:invalid_delete');
         END IF;
      WHEN OTHERS
      THEN
         x_return_status := wsh_util_core.g_ret_sts_unexp_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
   END delete_interface_records;

 --R12.1.1 STANDALONE PROJECT - Added new API
/*=======================================================================================

PROCEDURE NAME : Delete_Interface_Records

This Procedure will be used to delete record in the different interface tables, after data
is populated in the base tables

=======================================================================================*/

   PROCEDURE delete_interface_records (
      p_del_interface_id_tbl       IN         WSH_UTIL_CORE.Id_Tab_Type,
      p_del_det_interface_id_tbl   IN         WSH_UTIL_CORE.Id_Tab_Type,
      p_del_assgn_interface_id_tbl IN         WSH_UTIL_CORE.Id_Tab_Type,
      p_del_error_interface_id_tbl IN         WSH_UTIL_CORE.Id_Tab_Type,
      p_det_error_interface_id_tbl IN         WSH_UTIL_CORE.Id_Tab_Type,
      x_return_status              OUT NOCOPY VARCHAR2
   )
   IS
      l_debug_on BOOLEAN;
      l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELETE_INTERFACE_RECORDS';

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
      wsh_debug_sv.push (l_module_name, 'DELETE INTERFACE RECORDS');
      wsh_debug_sv.log ( l_module_name, 'p_del_interface_id_tbl.COUNT', p_del_interface_id_tbl.COUNT);
      wsh_debug_sv.log ( l_module_name, 'p_del_det_interface_id_tbl.COUNT', p_del_det_interface_id_tbl.COUNT);
      wsh_debug_sv.log ( l_module_name, 'p_del_assgn_interface_id_tbl.COUNT', p_del_assgn_interface_id_tbl.COUNT);
      wsh_debug_sv.log ( l_module_name, 'p_del_error_interface_id_tbl.COUNT', p_del_error_interface_id_tbl.COUNT);
      wsh_debug_sv.log ( l_module_name, 'p_det_error_interface_id_tbl.COUNT', p_det_error_interface_id_tbl.COUNT);
     END IF;

     x_return_status := wsh_util_core.g_ret_sts_success;
     --
     IF (p_det_error_interface_id_tbl.COUNT > 0) THEN
       FORALL i in p_det_error_interface_id_tbl.FIRST..p_det_error_interface_id_tbl.LAST
         DELETE FROM wsh_interface_errors
         WHERE  interface_error_id = p_det_error_interface_id_tbl(i);
       --
       IF l_debug_on THEN
        wsh_debug_sv.logmsg ( l_module_name, 'Deleted '||SQL%ROWCOUNT||' Records from wsh_interface_errors');
       END IF;
       --
     END IF;
     --
     IF (p_del_error_interface_id_tbl.COUNT > 0) THEN
       FORALL i in p_del_error_interface_id_tbl.FIRST..p_del_error_interface_id_tbl.LAST
         DELETE FROM wsh_interface_errors
         WHERE  interface_error_id = p_del_error_interface_id_tbl(i);
       --
       IF l_debug_on THEN
         wsh_debug_sv.logmsg ( l_module_name, 'Deleted '||SQL%ROWCOUNT||' Records from wsh_interface_errors');
       END IF;
       --
     END IF;
     --
     IF (p_del_assgn_interface_id_tbl.COUNT > 0) THEN
       FORALL i in p_del_assgn_interface_id_tbl.FIRST..p_del_assgn_interface_id_tbl.LAST
         DELETE FROM wsh_del_assgn_interface
         WHERE  del_assgn_interface_id = p_del_assgn_interface_id_tbl(i);
       --
       IF l_debug_on THEN
        wsh_debug_sv.logmsg ( l_module_name, 'Deleted '||SQL%ROWCOUNT||' Records from wsh_del_assgn_interface');
       END IF;
       --
     END IF;
     --
     IF (p_del_det_interface_id_tbl.COUNT > 0) THEN
       FORALL i in p_del_det_interface_id_tbl.FIRST..p_del_det_interface_id_tbl.LAST
         DELETE FROM wsh_del_details_interface
         WHERE  delivery_detail_interface_id = p_del_det_interface_id_tbl(i);
       --
       IF l_debug_on THEN
        wsh_debug_sv.logmsg ( l_module_name, 'Deleted '||SQL%ROWCOUNT||' Records from wsh_del_details_interface');
       END IF;
       --
     END IF;
     --
     IF (p_del_interface_id_tbl.COUNT > 0) THEN
       FORALL i in p_del_interface_id_tbl.FIRST..p_del_interface_id_tbl.LAST
         DELETE FROM wsh_new_del_interface
         WHERE  delivery_interface_id = p_del_interface_id_tbl(i);
       --
       IF l_debug_on THEN
        wsh_debug_sv.logmsg ( l_module_name, 'Deleted '||SQL%ROWCOUNT||' Records from wsh_new_del_interface');
       END IF;
       --
     END IF;
     --
     IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name, 'Return Status',x_return_status);
       wsh_debug_sv.pop (l_module_name);
     END IF;
     --
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := wsh_util_core.g_ret_sts_unexp_error;
	 --
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
	 --
   END delete_interface_records;

END wsh_process_interfaced_pkg;

/
