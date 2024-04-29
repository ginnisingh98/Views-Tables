--------------------------------------------------------
--  DDL for Package Body CLN_XMLG_EVENT_HANDLER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CLN_XMLG_EVENT_HANDLER_PKG" AS
/* $Header: ECXXMLGB.pls 120.1 2005/08/26 07:19:28 nparihar noship $ */
   l_debug_level        NUMBER := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));

-- Package
--   CLN_XMLG_EVENT_HANDLER_PKG
--
-- Purpose
--    Body of package CLN_XMLG_EVENT_HANDLER_PKG. This package captures the events raised
--    by XML Gateway and updates the collaboration history
--
-- History
--    May-20-2002       Viswanthan Umapathy         Created


-- Name
--    NOTIFIY_XMLG_IN_ERROR
-- Purpose
--   This procedure is called to update the collaboration history whenever
--   XMLG enconters an error in an inbound dcoument.
-- Arguments
--
-- Notes
--    No specific notes.

   PROCEDURE NOTIFIY_XMLG_IN_ERROR(
      x_return_status   OUT NOCOPY VARCHAR2,
      x_msg_data        OUT NOCOPY VARCHAR2,
      p_msg_id          IN  RAW,
      p_err_code        IN  VARCHAR2,
      p_err_desc        IN  VARCHAR2)
   IS
      l_coll_id                     NUMBER;
      l_party_id                    VARCHAR2(100);
      l_party_type                  VARCHAR2(100);
      l_np_tp_id                    VARCHAR2(100);
      l_app_id                      VARCHAR2(100);
      l_tp_location_code            VARCHAR2(255);
      l_doc_dir                     VARCHAR2(10);
      l_doc_no                      VARCHAR2(100);
      l_xmlg_tran_type              VARCHAR2(100);
      l_xmlg_tran_subtype           VARCHAR2(100);
      l_xmlg_doc_id                 VARCHAR2(255);
      l_app_ref_id                  VARCHAR2(1000);
      l_coll_type                   VARCHAR2(100);
      l_fnd_message                 VARCHAR2(1000);
      l_sender_component            VARCHAR2(50);
      l_email                       VARCHAR2(255);
      l_notification_flow_key       NUMBER(20);
      l_coll_exists_flag            BOOLEAN;
      l_rosettanet_check_required   BOOLEAN;
      l_int_con_no                  VARCHAR2(255);
      l_debug_mode                  VARCHAR2(255);
      l_error_code                  VARCHAR2(255);
      l_error_msg                   VARCHAR2(1000);
      l_message_standard            VARCHAR2(30);
      l_doc_type                    VARCHAR2(30);

   BEGIN

      -- Sets the debug mode to be FILE
      --l_debug_mode := ecx_cln_debug_pub.Set_Debug_Mode('FILE');

      IF (l_Debug_Level <= 2) THEN
              ecx_cln_debug_pub.Add('ENTERING NOTIFIY_XMLG_IN_ERROR', 2);
      END IF;

      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('With the following parameters:', 1);
              ecx_cln_debug_pub.Add('p_msg_id:' || p_msg_id, 1);
              ecx_cln_debug_pub.Add('p_err_code:' || p_err_code, 1);
              ecx_cln_debug_pub.Add('p_err_desc:' || p_err_desc, 1);
      END IF;


      --  Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_msg_data := 'Collaboration History is successfully updated with the error message';

      --  Getting trading partner details, transaction type, subtype, document id, etc..
      --  from ecx tables using message ID

      BEGIN
         --  Getting trading partner details, transaction type, subtype, document id, etc..
         --  from ecx tables using message ID
         SELECT header.tp_header_id , header.party_id, header.party_site_id,
                header.party_type, doclogs.internal_control_number, doclogs.attribute5,
                transaction.transaction_type, transaction.transaction_subtype,
                doclogs.document_number, doclogs.protocol_type, estd.standard_code
         INTO   l_np_tp_id, l_party_id, l_tp_location_code,
                l_party_type, l_int_con_no, l_app_ref_id,
                l_xmlg_tran_type, l_xmlg_tran_subtype,
                l_xmlg_doc_id, l_sender_component, l_message_standard
         FROM   ecx_doclogs doclogs, ecx_tp_details details, ecx_tp_headers header,
                ecx_ext_processes processes, ecx_transactions transaction, ecx_standards estd
         	WHERE  doclogs.msgid = HEXTORAW(p_msg_id) and
                doclogs.party_site_id = source_tp_location_code and
                doclogs.transaction_type = ext_type and
                doclogs.transaction_subtype = ext_subtype and
                header.tp_header_id = details.tp_header_id and
                details.ext_process_id  = processes.ext_process_id and
                processes.transaction_id = transaction.transaction_id and
                estd.standard_id = processes.standard_id and
               rownum < 2;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               IF (l_Debug_Level <= 1) THEN
                       ecx_cln_debug_pub.Add('INVALID_DATA_FOUND EXCEPTION IN ECX_DOCLOGS FOR MESSSAGE ID:' || p_msg_id, 1);
               END IF;

               SELECT internal_control_number, attribute5, transaction_type,
                      transaction_subtype, document_number, protocol_type, message_standard
               INTO   l_int_con_no, l_app_ref_id, l_xmlg_tran_type,
                      l_xmlg_tran_subtype, l_xmlg_doc_id, l_sender_component, l_message_standard
               FROM   ecx_doclogs
               WHERE  msgid = HEXTORAW(p_msg_id);
      END;


      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('l_np_tp_id:' || l_np_tp_id, 1);
              ecx_cln_debug_pub.Add('l_party_id:' || l_party_id, 1);
              ecx_cln_debug_pub.Add('l_tp_location_code:' || l_tp_location_code, 1);
              ecx_cln_debug_pub.Add('l_party_type:' || l_party_type, 1);
              ecx_cln_debug_pub.Add('l_int_con_no:' || l_int_con_no, 1);
              ecx_cln_debug_pub.Add('l_app_ref_id:' || l_app_ref_id, 1);

              ecx_cln_debug_pub.Add('Transaction Type:' || l_xmlg_tran_type, 1);
              ecx_cln_debug_pub.Add('Transaction Subtype:' || l_xmlg_tran_subtype, 1);
              ecx_cln_debug_pub.Add('Document ID:' || l_xmlg_doc_id, 1);
              ecx_cln_debug_pub.Add('Application reference ID from attribute5:' || l_app_ref_id, 1);
              ecx_cln_debug_pub.Add('Message Standard:' || l_message_standard, 1);
      END IF;



      SELECT DECODE(NVL(l_xmlg_tran_type, 'NULL'), 'NULL', '', l_xmlg_tran_type || ':') ||
             DECODE(NVL(l_xmlg_tran_subtype, 'NULL'), 'NULL', '', l_xmlg_tran_subtype || ':') ||
             DECODE(NVL(l_xmlg_doc_id, 'NULL'), 'NULL', '', l_xmlg_doc_id)
             INTO l_doc_no
             FROM DUAL;

      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('l_doc_no:' || l_doc_no, 1);
      END IF;

      CLN_CH_COLLABORATION_PKG.DEFAULT_XMLGTXN_MAPPING(
         x_return_status                => x_return_status,
         x_msg_data                     => x_msg_data,
         p_xmlg_transaction_type        => l_xmlg_tran_type,
         p_xmlg_transaction_subtype     => l_xmlg_tran_subtype,
         p_doc_dir                      => l_doc_dir,
         p_app_id                       => l_app_id,
         p_coll_type                    => l_coll_type,
         p_doc_type                     => l_doc_type);

      --  Getting Application Refernce ID by Calling GET_DATA_AREA_REFID
      IF l_app_ref_id IS NULL THEN
         CLN_CH_COLLABORATION_PKG.GET_DATA_AREA_REFID(p_msg_id, l_message_standard, l_app_ref_id, l_app_id, l_coll_type);
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('Application reference ID obtained thru payload parsing:'|| l_app_ref_id, 1);
         END IF;

      END IF;

      -- Collaboration exists ?
      l_coll_exists_flag := true;

      -- Getting Collaboration ID for the Application Refernce ID
      BEGIN
         SELECT collaboration_id
         INTO   l_coll_id
         FROM   CLN_COLL_HIST_HDR
         WHERE  APPLICATION_REFERENCE_ID = l_app_ref_id;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               l_coll_exists_flag := false;
      END;

      IF NOT l_coll_exists_flag THEN
         BEGIN
            SELECT collaboration_id
            INTO   l_coll_id
            FROM   CLN_COLL_HIST_HDR
            WHERE  xmlg_msg_id = p_msg_id;

            l_coll_exists_flag := true;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               l_coll_exists_flag := false;
         END;
      END IF;

      l_doc_dir := 'IN';
      l_rosettanet_check_required := FALSE;
      IF l_sender_component IS NOT NULL THEN
         l_rosettanet_check_required := TRUE;
      END IF;


      -- If collaboration doesn't exist
      IF NOT l_coll_exists_flag THEN

         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('Collaboration does not exist', 1);
         END IF;


         --  Getting Party ID
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('Party ID :' || l_party_id, 1);
         END IF;



         l_app_id := NVL(l_app_id,'701');
         l_coll_type := NVL(l_coll_type,'XMLG_ERROR');

         -- SELECT COMPONENT INTO l_sender_component FROM ECX_OAG_CBOD_V WHERE MSGID = p_msg_id;

         -- Create collaboration
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('CREATE_COLLABORATION: <Mandatory parameters>', 1);
                 ecx_cln_debug_pub.Add('l_app_id:' || l_app_id, 1);
                 ecx_cln_debug_pub.Add('l_coll_type:' || l_coll_type, 1);
                 ecx_cln_debug_pub.Add('l_party_id:' || l_party_id, 1);
                 ecx_cln_debug_pub.Add('l_doc_dir:' || l_doc_dir, 1);
                 ecx_cln_debug_pub.Add('l_sender_component:' || l_sender_component, 1);
         END IF;

         /*
         CLN_CH_COLLABORATION_PKG.CREATE_COLLABORATION(
            x_return_status                => x_return_status,
            x_msg_data                     => x_msg_data,
            p_ref_id                       => l_app_ref_id,
            p_doc_no                       => l_doc_no,
            p_resend_flag                  => 'N',
            p_resend_count                 => 0,
            p_doc_owner                    => FND_GLOBAL.USER_ID,
            p_init_date                    => sysdate,
            p_coll_pt                      => 'XML_GATEWAY',
            p_xmlg_msg_id                  => p_msg_id,
            p_sender_component             => l_sender_component,
            p_rosettanet_check_required    => l_rosettanet_check_required,
            x_coll_id                      => l_coll_id);
         */


         CLN_CH_COLLABORATION_PKG.CREATE_COLLABORATION(
            x_return_status                => x_return_status,
            x_msg_data                     => x_msg_data,
            p_app_id                       => l_app_id,
            p_ref_id                       => l_app_ref_id,
            p_org_id                       => NULL,
            p_rel_no                       => NULL,
            p_doc_no                       => l_doc_no,
            p_doc_rev_no                   => NULL,
            p_xmlg_transaction_type        => l_xmlg_tran_type,
            p_xmlg_transaction_subtype     => l_xmlg_tran_subtype,
            p_xmlg_document_id             => l_xmlg_doc_id,
            p_partner_doc_no               => NULL,
            p_coll_type                    => l_coll_type,
            p_tr_partner_type              => l_party_type,
            p_tr_partner_id                => l_party_id,
            p_tr_partner_site              => NULL,
            p_resend_flag                  => 'N',
            p_resend_count                 => 0,
            p_doc_owner                    => FND_GLOBAL.USER_ID,
            p_init_date                    => sysdate,
            p_doc_creation_date            => NULL,
            p_doc_revision_date            => NULL,
            p_doc_type                     => l_doc_type,
            p_doc_dir                      => l_doc_dir,
            p_coll_pt                      => 'B2B_SERVER',
            p_xmlg_msg_id                  => p_msg_id,
            p_unique1                      => NULL,
            p_unique2                      => NULL,
            p_unique3                      => NULL,
            p_unique4                      => NULL,
            p_unique5                      => NULL,
            p_sender_component             => l_sender_component,
            p_rosettanet_check_required    => l_rosettanet_check_required,
            x_coll_id                      => l_coll_id);
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_msg_data := 'Create Collaboration Failed:' || x_msg_data;
            IF (l_Debug_Level <= 1) THEN
                    ecx_cln_debug_pub.Add('ERROR:' || x_msg_data, 1);
            END IF;

            IF (l_Debug_Level <= 2) THEN
                    ecx_cln_debug_pub.Add('EXITING NOTIFIY_XMLG_IN_ERROR', 2);
            END IF;

            RETURN;
         END IF;
      ELSE
            IF (l_Debug_Level <= 1) THEN
                    ecx_cln_debug_pub.Add('Collaboration exists', 1);
            END IF;

      END IF; -- IF NOT l_coll_exists_flag THEN

      FND_MESSAGE.SET_NAME('CLN', 'CLN_MSG_XMLG_ERROR'); -- 'XML Gateway Error'
      l_fnd_message := FND_MESSAGE.GET;

      -- Update collaboration
      CLN_NP_PROCESSOR_PKG.PROCESS_NOTIFICATION(x_return_status, x_msg_data, NULL, l_app_ref_id,
                                                '99', l_fnd_message, p_err_code, p_err_desc,
                                                l_int_con_no, 'XML_GATEWAY', l_doc_dir, l_coll_id,NULL);
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         x_msg_data := 'Process Notification Failed:' || x_msg_data;
         IF (l_Debug_Level <= 4) THEN
                 ecx_cln_debug_pub.Add('ERROR:' || x_msg_data, 4);
         END IF;

         IF (l_Debug_Level <= 2) THEN
                 ecx_cln_debug_pub.Add('EXITING NOTIFIY_XMLG_IN_ERROR', 2);
         END IF;

         RETURN;
      END IF;
      EXCEPTION
         WHEN OTHERS THEN
            l_error_code := SQLCODE;
            l_error_msg := SQLERRM;
            x_msg_data :=  'ERROR: ' || l_error_code||' : '||l_error_msg;
            x_return_status := FND_API.G_RET_STS_ERROR;
            IF (l_Debug_Level <= 5) THEN
                    ecx_cln_debug_pub.Add(x_msg_data, 6);
                    ecx_cln_debug_pub.Add('EXITING NOTIFIY_XMLG_IN_ERROR', 2);
            END IF;

   END NOTIFIY_XMLG_IN_ERROR;

   -- Name
   --    CLN_XMLG_ERROR_SUBSCRIPTION_F
   -- Purpose
   --    This function subcribes to oracle.apps.ecx.processing.message.error which is generated
   --    by XML Gateway when it encounters a parsing error for an inbound document
   -- Arguments
   --
   -- Notes
   --    No specific notes.

   FUNCTION CLN_XMLG_PROCESSING_ERROR_F(
      p_subscription_guid  IN RAW,
      p_event  IN OUT NOCOPY WF_EVENT_T
      ) RETURN VARCHAR2
   IS
      l_msg_id      VARCHAR2(255);
      l_error_code  VARCHAR2(255);
      l_error_msg   VARCHAR2(1000);
      l_return_code VARCHAR2(255);
      l_return_msg  VARCHAR2(1000);
      l_debug_mode  VARCHAR2(255);
      i_cln_not_parameters   wf_parameter_list_t;
   BEGIN
      -- Sets the debug mode to be FILE
      --l_debug_mode := ecx_cln_debug_pub.Set_Debug_Mode('FILE');

      IF (l_Debug_Level <= 2) THEN
              ecx_cln_debug_pub.Add('ENTERING CLN_XMLG_PROCESSING_ERROR_F', 2);
      END IF;


      i_cln_not_parameters := p_event.getParameterList();

      l_msg_id := WF_EVENT.getValueForParameter('ECX_MSGID',i_cln_not_parameters);
      l_error_code := 'XMLG_IN01'; -- Error code not supplied by XMLGateway
      l_error_msg := WF_EVENT.getValueForParameter('ECX_ERROR_MSG',i_cln_not_parameters);
      NOTIFIY_XMLG_IN_ERROR(l_return_code, l_return_msg,
                                                        l_msg_id, l_error_code, l_error_msg);
      IF (l_Debug_Level <= 2) THEN
              ecx_cln_debug_pub.Add('EXITING CLN_XMLG_PROCESSING_ERROR_F', 2);
      END IF;

      RETURN 'SUCCESS';
   EXCEPTION
      WHEN OTHERS THEN
         l_error_code := SQLCODE;
         l_error_msg := SQLERRM;
         IF (l_Debug_Level <= 5) THEN
                 ecx_cln_debug_pub.Add('Error:' || l_error_code || ':' || l_error_msg, 3);
                 ecx_cln_debug_pub.Add('EXITING CLN_XMLG_PROCESSING_ERROR_Fw', 2);
         END IF;

         RETURN 'SUCCESS';
   END;

   -- Name
   --    CLN_XMLG_SETUP_ERROR_F
   -- Purpose
   --    This function subcribes to oracle.apps.ecx.inbound.message.receive which is generated
   --    by XML Gateway when it encounters a setup error for an inbound document
   -- Arguments
   --
   -- Notes
   --    No specific notes.

   FUNCTION CLN_XMLG_SETUP_ERROR_F(
      p_subscription_guid  IN RAW,
      p_event  IN OUT NOCOPY WF_EVENT_T
      ) RETURN VARCHAR2
   IS
      l_msg_id      VARCHAR2(255);
      l_error_code  VARCHAR2(255);
      l_error_msg   VARCHAR2(1000);
      l_return_code VARCHAR2(255);
      l_return_msg  VARCHAR2(1000);
      l_debug_mode  VARCHAR2(255);
      i_cln_not_parameters   wf_parameter_list_t;
   BEGIN
      -- Sets the debug mode to be FILE
      --l_debug_mode := ecx_cln_debug_pub.Set_Debug_Mode('FILE');

      IF (l_Debug_Level <= 2) THEN
              ecx_cln_debug_pub.Add('ENTERING CLN_XMLG_SETUP_ERROR_F', 2);
      END IF;


      i_cln_not_parameters := p_event.getParameterList();

      l_msg_id := WF_EVENT.getValueForParameter('ECX_MSGID',i_cln_not_parameters);
      l_error_code := 'XMLG_IN02'; -- Error code not supplied by XMLGateway
      SELECT processing_message INTO l_error_msg FROM ecx_in_process_v
      WHERE msgid = HEXTORAW(l_msg_id);
      NOTIFIY_XMLG_IN_ERROR(l_return_code, l_return_msg,
                                                        l_msg_id, l_error_code, l_error_msg);
      IF (l_Debug_Level <= 2) THEN
              ecx_cln_debug_pub.Add('EXITING CLN_XMLG_SETUP_ERROR_F', 2);
      END IF;

      RETURN 'SUCCESS';
   EXCEPTION
      WHEN OTHERS THEN
         l_error_code := SQLCODE;
         l_error_msg := SQLERRM;
         IF (l_Debug_Level <= 5) THEN
                 ecx_cln_debug_pub.Add('Error:' || l_error_code || ':' || l_error_msg, 5);
                 ecx_cln_debug_pub.Add('EXITING CLN_XMLG_SETUP_ERROR_F', 2);
         END IF;

         RETURN 'SUCCESS';
   END;

   -- Name
   --    CLN_XMLG_EVENT_SUB_F
   -- Purpose
   --    This function subcribes to oracle.apps.ecx.inbound.message.receive
   --    with source type 'EXTERNAL' and 'LOCAL', which is generated by XML Gateway
   --    when it receives an inbound document
   -- Arguments
   --
   -- Notes
   --    No specific notes.

   FUNCTION CLN_XMLG_EVENT_SUB_F(
      p_subscription_guid  IN RAW,
      p_event  IN OUT NOCOPY WF_EVENT_T
   ) RETURN VARCHAR2
   IS
      l_msg_id      VARCHAR2(255);
      l_error_code  VARCHAR2(255);
      l_error_msg   VARCHAR2(1000);
      l_return_code VARCHAR2(255);
      l_return_msg  VARCHAR2(1000);
      l_debug_mode  VARCHAR2(255);
      l_txn_type    VARCHAR2(100);
      l_txn_subtype VARCHAR2(100);
      l_direction   VARCHAR2(10);
      l_app_id      VARCHAR2(10);
      l_coll_type   VARCHAR2(100);
      l_doc_type    VARCHAR2(100);
      l_app_ref_id  VARCHAR2(255);
      l_coll_id     NUMBER;
      l_dtl_coll_id NUMBER;
      l_msg         VARCHAR2(1000);
      i_cln_not_parameters   wf_parameter_list_t;
      l_message_standard VARCHAR2(30);
   BEGIN
      -- Sets the debug mode to be FILE
      --l_debug_mode := ecx_cln_debug_pub.Set_Debug_Mode('FILE');

      IF (l_Debug_Level <= 2) THEN
              ecx_cln_debug_pub.Add('ENTERING CLN_XMLG_EVENT_SUB_F', 2);
      END IF;


      i_cln_not_parameters := p_event.getParameterList();

      l_msg_id := WF_EVENT.getValueForParameter('ECX_MSGID',i_cln_not_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Message ID:' || l_msg_id, 1);
      END IF;


      SELECT TRANSACTION_TYPE, TRANSACTION_SUBTYPE, DIRECTION, ATTRIBUTE5, message_standard
      INTO   l_txn_type, l_txn_subtype, l_direction, l_app_ref_id, l_message_standard
      FROM   ecx_doclogs
      WHERE  msgid = HEXTORAW(l_msg_id);

      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Transaction Type:' || l_txn_type, 1);
              ecx_cln_debug_pub.Add('Transaction Subtype:' || l_txn_subtype, 1);
              ecx_cln_debug_pub.Add('Direction:' || l_direction, 1);
              ecx_cln_debug_pub.Add('Application Reference ID:' || l_app_ref_id, 1);
      END IF;


      IF (l_txn_type = 'CLN' AND l_txn_subtype = 'NBOD') THEN
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('This message (Confirm BOD) will be processed by Notification Processor',1);
         END IF;

         IF (l_Debug_Level <= 2) THEN
                 ecx_cln_debug_pub.Add('EXITING CLN_XMLG_EVENT_SUB_F', 2);
         END IF;

         RETURN 'SUCCESS';
      END IF;

      CLN_CH_COLLABORATION_PKG.DEFAULT_XMLGTXN_MAPPING(
         x_return_status                => l_return_code,
         x_msg_data                     => l_return_msg,
         p_xmlg_transaction_type        => l_txn_type,
         p_xmlg_transaction_subtype     => l_txn_subtype,
         p_doc_dir                      => l_direction,
         p_app_id                       => l_app_id,
         p_coll_type                    => l_coll_type,
         p_doc_type                     => l_doc_type);
      -- IF l_return_code <> FND_API.G_RET_STS_SUCCESS THEN
      -- Procedure will return success even if there is NO_DATA_FOUND exception
      IF ((l_app_id IS NULL) OR (l_coll_type IS NULL) OR (l_doc_type IS NULL)) THEN
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('This message is not for oracle supply chain trading connector',1);
         END IF;

         IF (l_Debug_Level <= 2) THEN
                 ecx_cln_debug_pub.Add('EXITING CLN_XMLG_EVENT_SUB_F', 2);
         END IF;

         RETURN 'SUCCESS';
      END IF;

      IF l_app_ref_id IS NULL THEN
         CLN_CH_COLLABORATION_PKG.GET_DATA_AREA_REFID(l_msg_id, l_message_standard, l_app_ref_id, l_app_id, l_coll_type);
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('Application reference ID obtained thru payload parsing:'|| l_app_ref_id, 1);
         END IF;

      END IF;

      BEGIN
         SELECT collaboration_id
         INTO   l_coll_id
         FROM   CLN_COLL_HIST_HDR
         WHERE  APPLICATION_REFERENCE_ID = l_app_ref_id;
      EXCEPTION
           WHEN NO_DATA_FOUND THEN
              l_coll_id := NULL;
      END;

      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Collaboration ID:' || l_coll_id, 1);
      END IF;

      FND_MESSAGE.SET_NAME('CLN','CLN_NP_XMLEH_SUCCESS');
      l_msg := FND_MESSAGE.GET;
      IF l_coll_id IS NULL THEN
         CLN_CH_COLLABORATION_PKG.ADD_COLLABORATION(
            x_return_status                => l_return_code,
            x_msg_data                     => l_return_msg,
            -- p_resend_flag                  => 'N',
            -- p_resend_count                 => 0,
            -- p_doc_owner                    => FND_GLOBAL.USER_ID,
            -- p_init_date                    => sysdate,
            p_msg_text                     => l_msg,
            p_coll_pt                      => 'XML_GATEWAY',
            p_xmlg_msg_id                  => l_msg_id,
            x_dtl_coll_id                  => l_dtl_coll_id);
         IF l_return_code <> FND_API.G_RET_STS_SUCCESS THEN
            l_return_msg := 'Create Collaboration Failed:' || l_return_msg;
            IF (l_Debug_Level <= 4) THEN
                    ecx_cln_debug_pub.Add('ERROR:' || l_return_msg, 4);
            END IF;

            CLN_NP_PROCESSOR_PKG. NOTIFY_ADMINISTRATOR('While trying to create '
                                    || 'new collaboration for the inbound message ID#'
                                    || l_msg_id
                                    || ', the following error is encountered:'
                                    || l_return_msg);
            IF (l_Debug_Level <= 2) THEN
                    ecx_cln_debug_pub.Add('EXITING NOTIFIY_XMLG_IN_ERROR', 2);
            END IF;

            RETURN 'SUCCESS';
         END IF;
      ELSE
         CLN_CH_COLLABORATION_PKG.UPDATE_COLLABORATION(
            x_return_status                => l_return_code,
            x_msg_data                     => l_return_msg,
            p_msg_text                     => l_msg,
            p_coll_pt                      => 'XML_GATEWAY',
            p_doc_status                   => 'SUCCESS',
            p_coll_id                      => l_coll_id,
            -- p_xmlg_internal_control_number => NULL,
            p_xmlg_msg_id                  => l_msg_id,
            p_rosettanet_check_required    => FALSE,
            x_dtl_coll_id                  => l_dtl_coll_id);
      END IF;
      IF (l_Debug_Level <= 2) THEN
              ecx_cln_debug_pub.Add('EXITING CLN_XMLG_EVENT_SUB_F', 2);
      END IF;

      RETURN 'SUCCESS';
   EXCEPTION
      WHEN OTHERS THEN
         l_error_code := SQLCODE;
         l_error_msg := SQLERRM;
         IF (l_Debug_Level <= 5) THEN
                 ecx_cln_debug_pub.Add('Error:' || l_error_code || ':' || l_error_msg, 3);
                 ecx_cln_debug_pub.Add('EXITING CLN_XMLG_EVENT_SUB_F', 2);
         END IF;

         RETURN 'SUCCESS';
   END;

END CLN_XMLG_EVENT_HANDLER_PKG;

/
