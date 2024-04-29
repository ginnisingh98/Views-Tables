--------------------------------------------------------
--  DDL for Package Body CLN_NP_PROCESSOR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CLN_NP_PROCESSOR_PKG" AS
/* $Header: ECXNPNPB.pls 120.0 2005/08/25 04:47:39 nparihar noship $ */
   l_debug_level        NUMBER := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));

--
--  Package
--    CLN_NP_PROCESSOR_PKG_NEW
--
--  Purpose
--    Spec of package CLN_NP_PROCESSOR_PKG_NEW
--    Based on the latesy CH enhancements, notification processing has been modified.
--  History
--    Mar-22-2001       Kodanda Ram         Created
--

-- This internal procedue fetches the next reason code in l_reason_code and updates the
-- l_position_code and l_all_reason_codes accordingly
PROCEDURE NEXT_PART(
   l_position_code      IN OUT NOCOPY  NUMBER,
   l_all_reason_codes   IN OUT NOCOPY  VARCHAR2,
   l_reason_code        IN OUT NOCOPY  VARCHAR2)
IS
BEGIN
   l_position_code := instr(l_all_reason_codes, fnd_global.local_chr(127));
   IF l_position_code = 0 THEN
      l_reason_code := l_all_reason_codes;
      l_all_reason_codes := NULL;
   ELSE
      l_reason_code := substr(l_all_reason_codes, 0, l_position_code-1);
      l_all_reason_codes := substr(l_all_reason_codes, l_position_code+1);
  END IF;
END NEXT_PART;




-- This procedure sends E-mail thru the workflow - NOTIFIY_SOMEONE
PROCEDURE SEND_MAIL(
   p_admin_or_tp        IN VARCHAR2,
   p_role               IN VARCHAR2,
   p_notification_code  IN VARCHAR2,
   p_notification_desc  IN VARCHAR2,
   p_notification_mesg  IN VARCHAR2,
   p_application_name   IN VARCHAR2,
   p_org_id             IN VARCHAR2,
   p_document_number    IN VARCHAR2,
   p_revision_number    IN VARCHAR2,
   p_release_number     IN VARCHAR2,
   p_collaboration_id   IN VARCHAR2,
   p_collaboration_type IN VARCHAR2)
IS
   l_notification_flow_key  NUMBER;
   l_debug_mode             VARCHAR2(255);
   l_embedded_notif_screen  VARCHAR2(5);
BEGIN
   -- Sets the debug mode to FILE
   --l_debug_mode := ecx_cln_debug_pub.Set_Debug_Mode('FILE');
   IF (l_Debug_Level <= 2) THEN
           ecx_cln_debug_pub.Add('ENTERING CLN_NP_PROCESSOR_PKG.SEND_MAIL', 2);
   END IF;

   IF (l_Debug_Level <= 1) THEN
           ecx_cln_debug_pub.Add('E-Mail to be sent to              :' || p_role , 1);
           ecx_cln_debug_pub.Add('With the following parameters     :', 1);
           ecx_cln_debug_pub.Add('TO_TP_OR_ADMIN                    :' || p_admin_or_tp, 1);
           ecx_cln_debug_pub.Add('P_Role                            :' || p_role, 1);
           ecx_cln_debug_pub.Add('NOTIFICATION_CODE                 :' || p_notification_code, 1);
           ecx_cln_debug_pub.Add('NOTIFICATION_DESC                 :' || p_notification_desc, 1);
           ecx_cln_debug_pub.Add('NOTIFICATION_MESSAGE              :' || p_notification_mesg, 1);
           ecx_cln_debug_pub.Add('APPLICATION_NAME                  :' || p_application_name, 1);
           ecx_cln_debug_pub.Add('ORG_ID                            :' || p_org_id, 1);
           ecx_cln_debug_pub.Add('DOCUMENT_NUMBER                   :' || p_document_number, 1);
           ecx_cln_debug_pub.Add('REVISION_NUMBER                   :' || p_revision_number, 1);
           ecx_cln_debug_pub.Add('RELEASE_NUMBER                    :' || p_revision_number, 1);
           ecx_cln_debug_pub.Add('RELEASE_NUMBER                    :' || p_release_number, 1);
           ecx_cln_debug_pub.Add('COLLABORATION_ID                  :' || p_collaboration_id, 1);
           ecx_cln_debug_pub.Add('COLLABORATION_TYPE                :' || p_collaboration_type, 1);
   END IF;

   l_embedded_notif_screen :=  FND_PROFILE.VALUE('CLN_EMBEDDED_NOT_SCREEN');
   IF (l_Debug_Level <= 1) THEN
           ecx_cln_debug_pub.Add('Embedded Notification reqd         :' || l_embedded_notif_screen , 1);
   END IF;

   SELECT cln_np_notification_workflow_s.nextval INTO l_notification_flow_key FROM dual;

   IF(l_embedded_notif_screen = 'N') THEN
           IF (l_Debug_Level <= 1) THEN
                   ecx_cln_debug_pub.Add('Calling CLN_NPNP/NOTIFY_SOMEONE', 1);
           END IF;

           WF_ENGINE.CreateProcess('CLN_NPNP', l_notification_flow_key, 'NOTIFY_SOMEONE');
   ELSE
           IF (l_Debug_Level <= 1) THEN
                   ecx_cln_debug_pub.Add('Calling CLN_NPNP/NOTIFY_SOMEONE_EMBEDDED_RGN', 1);
           END IF;

           WF_ENGINE.CreateProcess('CLN_NPNP', l_notification_flow_key, 'NOTIFY_SOMEONE_EMBEDDED_RGN');
   END IF;

   WF_ENGINE.SetItemAttrText('CLN_NPNP', l_notification_flow_key, 'TO_TP_OR_ADMIN', p_admin_or_tp);
   WF_ENGINE.SetItemAttrText('CLN_NPNP', l_notification_flow_key, 'NOTIFICATION_CODE', p_notification_code);
   WF_ENGINE.SetItemAttrText('CLN_NPNP', l_notification_flow_key, 'NOTIFICATION_DESC', p_notification_desc);
   WF_ENGINE.SetItemAttrText('CLN_NPNP', l_notification_flow_key, 'NOTIFICATION_MESSAGE', p_notification_mesg);
   WF_ENGINE.SetItemAttrText('CLN_NPNP', l_notification_flow_key, 'APPLICATION_NAME', p_application_name);
   WF_ENGINE.SetItemAttrText('CLN_NPNP', l_notification_flow_key, 'ORG_ID', p_org_id);
   WF_ENGINE.SetItemAttrText('CLN_NPNP', l_notification_flow_key, 'DOCUMENT_NUMBER', p_document_number);
   WF_ENGINE.SetItemAttrText('CLN_NPNP', l_notification_flow_key, 'REVISION_NUMBER', p_revision_number);
   WF_ENGINE.SetItemAttrText('CLN_NPNP', l_notification_flow_key, 'RELEASE_NUMBER', p_release_number);
   WF_ENGINE.SetItemAttrText('CLN_NPNP', l_notification_flow_key, 'COLLABORATION_ID', p_collaboration_id);
   WF_ENGINE.SetItemAttrText('CLN_NPNP', l_notification_flow_key, 'COLLABORATION_TYPE', p_collaboration_type);
   WF_ENGINE.SetItemAttrText('CLN_NPNP', l_notification_flow_key, 'CLN_PERFORMER', p_role);
   WF_ENGINE.StartProcess('CLN_NPNP', l_notification_flow_key);

   -- check the profile option whether the embedded region shd be sent or not
   -- if not then continue with the old code and if no, then we call different process


   IF (l_Debug_Level <= 2) THEN
           ecx_cln_debug_pub.Add('EXITING CLN_NP_PROCESSOR_PKG.SEND_MAIL', 2);
   END IF;

END SEND_MAIL;


-- Name
--    TAKE_ACTIONS_INTERNAL
-- Purpose
--    This procedure handles a notification by executing all the actions defined by the user
--    for this notification code. To make use of this API, teams should pass either p_coll_id,
--    or p_reference or p_int_con_no that will be used to identify the collaboration uniquely.
--
-- Arguments
--
-- Notes
--    No specific notes

PROCEDURE TAKE_ACTIONS_INTERNAL(
   x_ret_code                    OUT NOCOPY VARCHAR2,
   x_ret_desc                    OUT NOCOPY VARCHAR2,
   p_notification_code           IN VARCHAR2,
   p_notification_desc           IN VARCHAR2,
   p_tp_id                       IN VARCHAR2,
   p_reference                   IN VARCHAR2,
   p_statuslvl                   IN VARCHAR2,
   p_header_desc                 IN VARCHAR2,
   p_update_collaboration_flag   IN BOOLEAN,
   p_update_coll_mess_flag       IN BOOLEAN,
   p_all_notification_codes      IN VARCHAR2,
   p_int_con_no                  IN VARCHAR2,
   p_coll_point                  IN VARCHAR2,
   p_doc_dir                     IN VARCHAR2,
   p_coll_id                     IN NUMBER,
   x_dtl_coll_id                 IN OUT NOCOPY VARCHAR2,
   p_collaboration_standard      IN VARCHAR2,
   p_notification_event          IN WF_EVENT_T,
   p_application_id              IN NUMBER )
IS
   l_application_id              NUMBER(10);
   l_application_name            VARCHAR2(100);
   l_collaboration_type          VARCHAR2(30);
   l_document_owner              VARCHAR2(30);
   l_notification_flow_key       NUMBER(20);
   l_concurrent_request_sts      NUMBER;
   l_email                       VARCHAR2(255);
   l_procedure_call_statement    VARCHAR2(255);
   l_cln_not_parameters          wf_parameter_list_t;
   l_org_id                      VARCHAR2(100);
   l_document_number             VARCHAR2(100);
   l_revision_number             VARCHAR2(100);
   l_release_number              VARCHAR2(100);
   l_collaboration_id            VARCHAR2(100);
   l_doc_type                    VARCHAR2(100);
   l_document_status             VARCHAR2(100);
   l_collaboration_status        VARCHAR2(10);
   l_all_notification_codes      VARCHAR2(100);
   l_notification_updation_code  VARCHAR2(100);
   l_delivery_confirmation_code  VARCHAR2(100);
   l_notify_default_admin_flag   BOOLEAN;
   l_tp_id                       VARCHAR2(100);
   l_doc_dir                     VARCHAR2(5);
   l_return_status               VARCHAR2(1000);
   l_msg_data                    VARCHAR2(1000);
   l_debug_mode                  VARCHAR2(255);
   l_msg_id                      VARCHAR2(255);
   l_xmlg_transaction_type       VARCHAR2(100);
   l_xmlg_transaction_subtype    VARCHAR2(100);
   l_xmlg_document_id            VARCHAR2(255);
   l_ret_code                    NUMBER;
   l_ret_msg                     VARCHAR2(1000);
   l_error_code                  NUMBER;
   l_error_msg                   VARCHAR2(1000);
   l_admin_email                 VARCHAR2(1000);
   l_role                        VARCHAR2(1000);
   l_temp                        VARCHAR2(100);

   -- Cursor to retrieve all the user defined actions
   CURSOR Get_ACTIONS( p_notification_code VARCHAR2, p_coll_point VARCHAR2, p_application_id NUMBER, p_collaboration_type VARCHAR2) IS
   SELECT codes.notification_message,details.action_dtl_id, details.action_code, details.attribute1,
      details.attribute2, details.attribute3, details.attribute4, details.attribute5, details.attribute6,
      details.attribute7, details.attribute8, details.attribute9, details.attribute10, details.attribute11,
      details.attribute12, details.attribute13, details.attribute14, details.attribute15
   FROM CLN_NOTIFICATION_CODES codes, CLN_NOTIFICATION_ACTION_HDR header, CLN_NOTIFICATION_ACTION_DTL details
   WHERE codes.NOTIFICATION_CODE = p_notification_code and codes.collaboration_point = p_coll_point
      and header.notification_id = codes.notification_id and header.application_id = p_application_id
      and header.collaboration_type = p_collaboration_type and header.ACTION_HDR_ID = details.ACTION_HDR_ID
      and details.active_flag = 'Y'
   ORDER BY details.ACTION_DTL_ID;

   BEGIN
      -- Sets the debug mode to be FILE
      --l_debug_mode := ecx_cln_debug_pub.Set_Debug_Mode('FILE');
      IF (l_Debug_Level <= 2) THEN
              ecx_cln_debug_pub.Add('ENTERING CLN_NP_PROCESSOR_PKG.TAKE_ACTIONS_INTERNAL', 2);
      END IF;

      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('With the following parameters:', 1);
              ecx_cln_debug_pub.Add('p_notification_code:' || p_notification_code, 1);
              ecx_cln_debug_pub.Add('p_notification_desc:' || p_notification_desc, 1);
              ecx_cln_debug_pub.Add('p_tp_id:' || p_tp_id, 1);
              ecx_cln_debug_pub.Add('p_reference:' || p_reference, 1);
              ecx_cln_debug_pub.Add('p_statuslvl:' || p_statuslvl, 1);
              ecx_cln_debug_pub.Add('p_header_desc:' || p_header_desc, 1);
              ecx_cln_debug_pub.Add('p_collaboration_standard:' || p_collaboration_standard, 1);
      END IF;


      IF(p_update_collaboration_flag) THEN
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('p_update_collaboration_flag:TRUE', 1);
         END IF;
      ELSE
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('p_update_collaboration_flag:FALSE', 1);
         END IF;
      END IF;

      IF(p_update_coll_mess_flag) THEN
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('p_update_coll_mess_flag:TRUE', 1);
         END IF;
      ELSE
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('p_update_coll_mess_flag:FALSE', 1);
         END IF;
      END IF;

      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('p_all_notification_codes:' || p_all_notification_codes, 1);
              ecx_cln_debug_pub.Add('p_int_con_no:' || p_int_con_no, 1);
              ecx_cln_debug_pub.Add('p_coll_point:' || p_coll_point, 1);
              ecx_cln_debug_pub.Add('p_doc_dir:' || p_doc_dir, 1);
              ecx_cln_debug_pub.Add('Collaboration ID:' || p_coll_id, 1);
      END IF;


      x_ret_code := FND_API.G_RET_STS_SUCCESS;
      FND_MESSAGE.SET_NAME('CLN', 'CLN_SUCCESS'); -- 'Success'
      x_ret_desc := FND_MESSAGE.GET;


      BEGIN
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('Take Actions :' || p_notification_code, 1);
         END IF;

         -- Query collaboration history header for information using the reference
         IF ( (p_coll_id IS NOT NULL) AND (LENGTH(TRIM(p_coll_id)) <> 0) ) THEN
            SELECT application_id, collaboration_type, org_id, document_no,
                   doc_revision_no, release_no, collaboration_id, document_owner
            INTO   l_application_id, l_collaboration_type, l_org_id, l_document_number,
                   l_revision_number, l_release_number, l_collaboration_id, l_document_owner
            FROM CLN_COLL_HIST_HDR
            WHERE collaboration_id = p_coll_id;
         ELSIF ( (p_reference IS NOT NULL) AND (LENGTH(TRIM(p_reference)) <> 0) ) THEN
            SELECT application_id, collaboration_type, org_id, document_no,
                   doc_revision_no, release_no, collaboration_id,document_owner
            INTO   l_application_id, l_collaboration_type, l_org_id, l_document_number,
                   l_revision_number, l_release_number, l_collaboration_id, l_document_owner
            FROM CLN_COLL_HIST_HDR
            WHERE APPLICATION_REFERENCE_ID = p_reference;
         ELSIF (p_int_con_no IS NOT NULL) THEN -- added 28 June 2004.
            SELECT application_id, collaboration_type, org_id, document_no,
                   doc_revision_no, release_no, collaboration_id, l_document_owner
            INTO   l_application_id, l_collaboration_type, l_org_id, l_document_number,
                   l_revision_number, l_release_number, l_collaboration_id, l_document_owner
            FROM CLN_COLL_HIST_HDR
            WHERE xmlg_internal_control_number = p_int_con_no;
         END IF;

         l_tp_id := p_tp_id;

         IF p_tp_id is NULL THEN
            GET_TRADING_PARTNER_DETAILS( l_return_status, l_ret_msg, p_int_con_no, l_tp_id);
            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               -- x_ret_desc := l_ret_msg;
               -- RAISE FND_API.G_EXC_ERROR;
               l_tp_id := NULL;
            END IF;
         END IF;

         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('l_tp_id:' || l_tp_id, 1);
                 ecx_cln_debug_pub.Add('Queried the following from Collaboration History', 1);
                 ecx_cln_debug_pub.Add('l_application_id:' || l_application_id, 1);
                 ecx_cln_debug_pub.Add('l_collaboration_type:' || l_collaboration_type, 1);
                 ecx_cln_debug_pub.Add('l_org_id:' || l_org_id, 1);
                 ecx_cln_debug_pub.Add('l_document_number:' || l_document_number, 1);
                 ecx_cln_debug_pub.Add('l_revision_number:' || l_revision_number, 1);
                 ecx_cln_debug_pub.Add('l_release_number:' || l_release_number, 1);
                 ecx_cln_debug_pub.Add('l_collaboration_id:' || l_collaboration_id, 1);
         END IF;


         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               -- INVALID REFERENCE
               FND_MESSAGE.SET_NAME('CLN', 'CLN_INVALID_REFERENCE'); -- 'Invalid reference'
               x_ret_desc := FND_MESSAGE.GET;

               IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('Collaboration does not exist or Invalid Collaboration', 1);
               END IF;

               -- removed 28June 2004.Now, we intend to support the case
               -- when no collaboration is there
               --RAISE FND_API.G_EXC_ERROR;
      END;

      -- Obtain the value of CLN_DELIVERY_CONFIRMATION_CODE  profile option - Default B2B_02
      l_delivery_confirmation_code :=  FND_PROFILE.VALUE('CLN_DELIVERY_CONFIRMATION_CODE');

      IF l_delivery_confirmation_code IS NULL THEN

         FND_MESSAGE.SET_NAME('CLN', 'CLN_PO_DEL_CONFIRM_NOT_FOUND');
         -- 'Profile option - CLN_DELIVERY_CONFIRMATION_CODE - Not found'
         x_ret_desc := FND_MESSAGE.GET;
         RAISE FND_API.G_EXC_ERROR;

      END IF;

      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Profile option - CLN_DELIVERY_CONFIRMATION_CODE:' || l_delivery_confirmation_code, 1);
      END IF;


      -- If the notification code is delivery confirmation code then call delivery confirmation API
      IF p_notification_code = l_delivery_confirmation_code THEN

         -- Get the txn type, txn subtype, xmlg doc id, xmlg msg id
         -- of the last outbound message for this collaboration
         SELECT  xmlg_transaction_type, xmlg_transaction_subtype, xmlg_document_id, xmlg_msg_id
         INTO    l_xmlg_transaction_type, l_xmlg_transaction_subtype, l_xmlg_document_id, l_msg_id
         FROM    CLN_COLL_HIST_DTL where collaboration_dtl_id =
                    (SELECT MAX(collaboration_dtl_id) FROM  CLN_COLL_HIST_DTL
                     WHERE document_direction = 'OUT' AND collaboration_id = l_collaboration_id);

         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('l_xmlg_transaction_type:' || l_xmlg_transaction_type, 1);
                 ecx_cln_debug_pub.Add('l_xmlg_transaction_subtype:' || l_xmlg_transaction_subtype, 1);
                 ecx_cln_debug_pub.Add('l_xmlg_document_id:' || l_xmlg_document_id, 1);
         END IF;


         -- We are assuming that the first message after any out bound will be delviery confirmation
         IF (l_msg_id IS NULL ) OR (TRIM(l_msg_id) = '') THEN
            BEGIN
               -- Query ECX_DOCLOGS for message ID using transaction type , transaction subtype and document id
               SELECT msgid
               INTO l_msg_id
               FROM ECX_DOCLOGS
               WHERE transaction_type = l_xmlg_transaction_type AND
                     transaction_subtype = l_xmlg_transaction_subtype AND document_number = l_xmlg_document_id
                     AND direction = 'OUT';
               IF (l_Debug_Level <= 1) THEN
                       ecx_cln_debug_pub.Add('Quried ECX_DOCLOGS for l_msg_id:' || l_msg_id, 1);
               END IF;

               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     -- INVALID TRANSACTION TYPE,TRANSACTION SUBTYPE AND DOCUMENT ID
                     FND_MESSAGE.SET_NAME('CLN', 'CLN_INVALID_TRAN_DATA');
                     -- 'Unable to call delivery confirmation: Invalid transaction type, transaction subtype and document id'
                     x_ret_desc := FND_MESSAGE.GET;
                     RAISE FND_API.G_EXC_ERROR;
            END;
         END IF;

         -- Call Delivery Confirmation API
         ECX_ERRORLOG.external_system(l_msg_id, 0, 'Success', sysdate, l_ret_code, l_ret_msg);
         IF l_ret_code <> 0 THEN
            FND_MESSAGE.SET_NAME('CLN', 'CLN_ERROR_DELIVERY_CONFIRM_API');
            -- 'Error while calling delivery confirmation API:' || l_ret_msg;
            FND_MESSAGE.SET_TOKEN('ERRMESSAGE', l_ret_msg);
            x_ret_desc := FND_MESSAGE.GET;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('Executed delivery confirmation API:' || l_ret_code || ':' || l_ret_msg, 1);
         END IF;

      END IF; -- Delivery Comfirmation


      IF p_update_collaboration_flag THEN
         IF p_statuslvl = '00' THEN
            l_document_status := 'SUCCESS';
            l_collaboration_status := 'STARTED';
         ELSIF p_statuslvl = '99' THEN
            l_document_status := 'ERROR';
            l_collaboration_status := 'ERROR';
         END IF;

         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('l_document_status:' || l_document_status, 1);
                 ecx_cln_debug_pub.Add('l_collaboration_status:' || l_collaboration_status, 1);
         END IF;

         l_all_notification_codes := rtrim(p_all_notification_codes);

         IF ( substr(l_all_notification_codes,-1) )= ':' THEN
            l_all_notification_codes := substr( l_all_notification_codes, 0, length(l_all_notification_codes) - 1);
         END IF;

         IF l_tp_id IS NULL THEN
            IF p_coll_point = 'B2B_SERVER' THEN
               l_doc_type := 'CONFIRM_BOD';
               l_doc_dir := 'IN';
            ELSE
               l_doc_type := null;
               l_doc_dir := p_doc_dir;
            END IF;

            IF (l_Debug_Level <= 2) THEN
                    ecx_cln_debug_pub.Add('INVOKING CLN_CH_COLLABORATION_PKG.UPDATE_COLLABORATION', 2);
            END IF;

            CLN_CH_COLLABORATION_PKG.UPDATE_COLLABORATION(
               x_return_status                => l_return_status,
               x_msg_data                     => l_msg_data,
               p_msg_text                     => p_header_desc,
               p_coll_status                  => l_collaboration_status,
               p_doc_type                     => l_doc_type,
               p_doc_dir                      => l_doc_dir,
               p_coll_pt                      => p_coll_point,
               p_doc_status                   => l_document_status,
               p_notification_id              => l_all_notification_codes,
               p_coll_id                      => l_collaboration_id,
               p_xmlg_internal_control_number => p_int_con_no,
               p_xmlg_msg_id                  => NULL,
               p_rosettanet_check_required    => FALSE,
               x_dtl_coll_id                  => x_dtl_coll_id,
               p_collaboration_standard       => p_collaboration_standard);
         ELSE
            IF (l_Debug_Level <= 2) THEN
                    ecx_cln_debug_pub.Add('INVOKING CLN_CH_COLLABORATION_PKG.UPDATE_COLLABORATION', 2);
            END IF;

            CLN_CH_COLLABORATION_PKG.UPDATE_COLLABORATION(
               x_return_status                => l_return_status,
               x_msg_data                     => l_msg_data,
               p_msg_text                     => p_header_desc,
               p_coll_pt                      => p_coll_point,
               p_doc_status                   => l_document_status,
               p_notification_id              => l_all_notification_codes,
               p_coll_id                      => l_collaboration_id,
               p_xmlg_internal_control_number => p_int_con_no,
               p_xmlg_msg_id                  => NULL,
               p_rosettanet_check_required    => FALSE,
               x_dtl_coll_id                  => x_dtl_coll_id,
               p_collaboration_standard       => p_collaboration_standard);
         END IF;

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_ret_desc := l_msg_data;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF (l_Debug_Level <= 2) THEN
                 ecx_cln_debug_pub.Add('COMPLETED CLN_CH_COLLABORATION_PKG.UPDATE_COLLABORATION', 2);
         END IF;

      END IF;

      -- Add messages
      IF p_update_coll_mess_flag THEN
         CLN_CH_COLLABORATION_PKG.ADD_COLLABORATION_MESSAGES(
            x_return_status   => l_return_status,
            x_msg_data        => l_msg_data,
            p_dtl_coll_id     => x_dtl_coll_id,
            p_ref1            => p_notification_code,
            p_dtl_msg         => p_notification_desc);

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_ret_desc := l_msg_data;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF (l_Debug_Level <= 2) THEN
                 ecx_cln_debug_pub.Add('COMPLETED CLN_CH_COLLABORATION_PKG.ADD_COLLABORATION_MESSAGES', 2);
         END IF;

      END IF;

      -- Query fnd_application_vl for application name using application id
      BEGIN
         SELECT application_name INTO l_application_name
         FROM fnd_application_vl
         WHERE application_id = l_application_id;
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('Queried the following from fnd_application_vl using application id:'|| l_application_id, 1);
                 ecx_cln_debug_pub.Add('l_application_name:' || l_application_name, 1);
         END IF;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               -- INVALID APPLICATION ID
               FND_MESSAGE.SET_NAME('CLN', 'CLN_INVALID_APPL_ID'); -- 'Invalid application id'
               x_ret_desc := FND_MESSAGE.GET;
               RAISE FND_API.G_EXC_ERROR;
      END;


      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Action parameters:');
              ecx_cln_debug_pub.Add('APPLICATION_ID:' || l_application_id);
              ecx_cln_debug_pub.Add('COLLABORATION_ID:' || l_collaboration_id);
              ecx_cln_debug_pub.Add('COLLABORATION_TYPE:' || l_collaboration_type);
              ecx_cln_debug_pub.Add('REFERENCE_ID:' || p_reference);
              ecx_cln_debug_pub.Add('TRADING_PARTNER_ID:' || l_tp_id);
              ecx_cln_debug_pub.Add('HEADER_DESCRIPTION:' || p_header_desc);
              ecx_cln_debug_pub.Add('NOTIFICATION_DESCRIPTION:' || p_notification_desc);
              ecx_cln_debug_pub.Add('NOTIFICATION_CODE:' || p_notification_code);
              ecx_cln_debug_pub.Add('STATUS:' || p_statuslvl);
      END IF;

      -- if notification code is not null then only do this step
      -- else check if any of the three Send_mail_tp/ send_mail_admin/ send_mail_docowner
      -- is set, we call SEND_MAIL API.
      FOR c_actions IN Get_actions(p_notification_code, p_coll_point, l_application_id, l_collaboration_type) LOOP
         BEGIN
         SAVEPOINT ACTION;
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('Obtained cursor row for action code:' || c_actions.action_code, 1);
         END IF;


         IF c_actions.action_code = 'START_WORKFLOW' THEN
            -- attribute1 => Item , attribute2 => Process
            SELECT cln_np_notification_workflow_s.nextval INTO l_notification_flow_key FROM dual;
            IF (l_Debug_Level <= 2) THEN
                    ecx_cln_debug_pub.Add('INVOKING WF_ENGINE.CreateProcess:' || ':' || c_actions.attribute1 || l_notification_flow_key
                                     || ':' || c_actions.attribute2, 2);
            END IF;

            WF_ENGINE.CreateProcess(c_actions.attribute1, l_notification_flow_key, c_actions.attribute2);
            IF (l_Debug_Level <= 2) THEN
                    ecx_cln_debug_pub.Add('INVOKING WF_ENGINE.CreateProcess:' || ':' || c_actions.attribute1 || l_notification_flow_key || ':' || c_actions.attribute2, 2);
            END IF;

            -- Set attributes
            -- pass on the object of type wf_event_t also here.
            IF(p_notification_event IS NOT NULL) THEN
                WF_ENGINE.SetItemAttrEvent(c_actions.attribute1,l_notification_flow_key, 'EVENT_OBJ', p_notification_event);
            END IF;

            WF_ENGINE.SetItemAttrText(c_actions.attribute1,l_notification_flow_key, 'APPLICATION_ID', l_application_id);
            WF_ENGINE.SetItemAttrText(c_actions.attribute1,l_notification_flow_key, 'COLLABORATION_ID', l_collaboration_id);
            WF_ENGINE.SetItemAttrText(c_actions.attribute1,l_notification_flow_key, 'COLLABORATION_TYPE', l_collaboration_type);
            WF_ENGINE.SetItemAttrText(c_actions.attribute1,l_notification_flow_key, 'REFERENCE_ID', p_reference);
            WF_ENGINE.SetItemAttrText(c_actions.attribute1,l_notification_flow_key, 'TRADING_PARTNER_ID', l_tp_id);
            WF_ENGINE.SetItemAttrText(c_actions.attribute1,l_notification_flow_key, 'HEADER_DESCRIPTION', p_header_desc);
            WF_ENGINE.SetItemAttrText(c_actions.attribute1,l_notification_flow_key, 'NOTIFICATION_DESCRIPTION', p_notification_desc);
            WF_ENGINE.SetItemAttrText(c_actions.attribute1,l_notification_flow_key, 'NOTIFICATION_CODE', p_notification_code);
            WF_ENGINE.SetItemAttrText(c_actions.attribute1,l_notification_flow_key, 'STATUS', p_statuslvl);
            IF (l_Debug_Level <= 2) THEN
                    ecx_cln_debug_pub.Add('INVOKING WF_ENGINE.StartProcess:' || c_actions.attribute1 || ':' || l_notification_flow_key, 2);
            END IF;

            WF_ENGINE.StartProcess(c_actions.attribute1,l_notification_flow_key);
            IF (l_Debug_Level <= 2) THEN
                    ecx_cln_debug_pub.Add('COMPLETED WF_ENGINE.StartProcess:' || c_actions.attribute1 || ':' || l_notification_flow_key, 2);
            END IF;
         ELSIF c_actions.action_code = 'NOTIFY_ADMINISTRATOR' THEN
            l_notify_default_admin_flag := TRUE;
            IF c_actions.attribute1 IS NOT NULL THEN
               SEND_MAIL('Administrator', c_actions.attribute1, p_notification_code, c_actions.notification_message, p_notification_desc,
                          l_application_name, l_org_id, l_document_number, l_revision_number,
                          l_release_number, l_collaboration_id, l_collaboration_type);
               l_notify_default_admin_flag := FALSE;
            END IF;
            IF c_actions.attribute2 IS NOT NULL THEN
               SEND_MAIL('Administrator', c_actions.attribute2, p_notification_code, c_actions.notification_message, p_notification_desc,
                         l_application_name, l_org_id, l_document_number, l_revision_number,
                         l_release_number, l_collaboration_id, l_collaboration_type);
               l_notify_default_admin_flag := FALSE;
            END IF;
            IF c_actions.attribute3 IS NOT NULL THEN
               SEND_MAIL('Administrator', c_actions.attribute3, p_notification_code, c_actions.notification_message, p_notification_desc,
                          l_application_name, l_org_id, l_document_number, l_revision_number,
                          l_release_number, l_collaboration_id, l_collaboration_type);
               l_notify_default_admin_flag := FALSE;
            END IF;
            IF c_actions.attribute4 IS NOT NULL THEN
               SEND_MAIL('Administrator', c_actions.attribute4, p_notification_code, c_actions.notification_message, p_notification_desc,
                          l_application_name, l_org_id, l_document_number, l_revision_number,
                          l_release_number, l_collaboration_id, l_collaboration_type);
               l_notify_default_admin_flag := FALSE;
            END IF;
            IF c_actions.attribute5 IS NOT NULL THEN
               SEND_MAIL('Administrator', c_actions.attribute5, p_notification_code, c_actions.notification_message, p_notification_desc,
                          l_application_name, l_org_id, l_document_number, l_revision_number,
                          l_release_number, l_collaboration_id, l_collaboration_type);
               l_notify_default_admin_flag := FALSE;
            END IF;
            IF c_actions.attribute6 IS NOT NULL THEN
               SEND_MAIL('Administrator', c_actions.attribute6, p_notification_code, c_actions.notification_message, p_notification_desc,
                          l_application_name, l_org_id, l_document_number, l_revision_number,
                          l_release_number, l_collaboration_id, l_collaboration_type);
               l_notify_default_admin_flag := FALSE;
            END IF;
            IF c_actions.attribute7 IS NOT NULL THEN
               SEND_MAIL('Administrator', c_actions.attribute7, p_notification_code, c_actions.notification_message, p_notification_desc,
                          l_application_name, l_org_id, l_document_number, l_revision_number,
                          l_release_number, l_collaboration_id, l_collaboration_type);
               l_notify_default_admin_flag := FALSE;
            END IF;
            IF c_actions.attribute8 IS NOT NULL THEN
               SEND_MAIL('Administrator', c_actions.attribute8, p_notification_code, c_actions.notification_message, p_notification_desc,
                          l_application_name, l_org_id, l_document_number, l_revision_number,
                          l_release_number, l_collaboration_id, l_collaboration_type);
               l_notify_default_admin_flag := FALSE;
            END IF;
            IF c_actions.attribute9 IS NOT NULL THEN
               SEND_MAIL('Administrator', c_actions.attribute9, p_notification_code, c_actions.notification_message, p_notification_desc,
                          l_application_name, l_org_id, l_document_number, l_revision_number,
                          l_release_number, l_collaboration_id, l_collaboration_type);
               l_notify_default_admin_flag := FALSE;
            END IF;
            IF c_actions.attribute10 IS NOT NULL THEN
               SEND_MAIL('Administrator', c_actions.attribute10, p_notification_code, c_actions.notification_message, p_notification_desc,
                          l_application_name, l_org_id, l_document_number, l_revision_number,
                          l_release_number, l_collaboration_id, l_collaboration_type);
               l_notify_default_admin_flag := FALSE;
            END IF;
            IF c_actions.attribute11 IS NOT NULL THEN
               SEND_MAIL('Administrator', c_actions.attribute11, p_notification_code, c_actions.notification_message, p_notification_desc,
                          l_application_name, l_org_id, l_document_number, l_revision_number,
                          l_release_number, l_collaboration_id, l_collaboration_type);
               l_notify_default_admin_flag := FALSE;
            END IF;
            IF c_actions.attribute12 IS NOT NULL THEN
               SEND_MAIL('Administrator', c_actions.attribute12, p_notification_code, c_actions.notification_message, p_notification_desc,
                          l_application_name, l_org_id, l_document_number, l_revision_number,
                          l_release_number, l_collaboration_id, l_collaboration_type);
               l_notify_default_admin_flag := FALSE;
            END IF;
            IF c_actions.attribute13 IS NOT NULL THEN
               SEND_MAIL('Administrator', c_actions.attribute13, p_notification_code, c_actions.notification_message, p_notification_desc,
                          l_application_name, l_org_id, l_document_number, l_revision_number,
                          l_release_number, l_collaboration_id, l_collaboration_type);
               l_notify_default_admin_flag := FALSE;
            END IF;
            IF c_actions.attribute14 IS NOT NULL THEN
               SEND_MAIL('Administrator', c_actions.attribute14, p_notification_code, c_actions.notification_message, p_notification_desc,
                          l_application_name, l_org_id, l_document_number, l_revision_number,
                          l_release_number, l_collaboration_id, l_collaboration_type);
               l_notify_default_admin_flag := FALSE;
            END IF;
            IF c_actions.attribute15 IS NOT NULL THEN
               SEND_MAIL('Administrator', c_actions.attribute15, p_notification_code, c_actions.notification_message, p_notification_desc,
                          l_application_name, l_org_id, l_document_number, l_revision_number,
                          l_release_number, l_collaboration_id, l_collaboration_type);
               l_notify_default_admin_flag := FALSE;
            END IF;
            IF l_notify_default_admin_flag = TRUE THEN
               -- Get administrator e-mail from profile value
               IF (l_Debug_Level <= 1) THEN
                       ecx_cln_debug_pub.Add('Administrator Roles not specified', 1);
               END IF;

               l_role := FND_PROFILE.VALUE('CLN_ADMINISTRATOR');
               IF (l_Debug_Level <= 1) THEN
                       ecx_cln_debug_pub.Add('Administrator Profile Role or E-Mail:' || l_email, 1);
               END IF;
               BEGIN
                  SELECT 'x'
                  INTO l_temp
                  FROM WF_ROLES
                  WHERE NAME =  l_role
                    AND rownum < 2;
               EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                  IF (l_Debug_Level <= 1) THEN
                          ecx_cln_debug_pub.Add('CLN Administrator Profile has email(not role)', 1);
                  END IF;
                  l_email := l_role;
                  l_role := 'CLN_ADMINISTRATOR';
                  SELECT email_address
                  INTO  l_admin_email
                  FROM WF_USERS
                  WHERE NAME = 'CLN_ADMINISTRATOR';
                  IF (l_Debug_Level <= 1) THEN
                          ecx_cln_debug_pub.Add('Administrator Role E-Mail:' || l_admin_email, 1);
                  END IF;
                  IF( l_email <> l_admin_email or l_admin_email is null) THEN
                     WF_DIRECTORY.SetAdHocUserAttr (USER_NAME => l_role, EMAIL_ADDRESS => l_email);
                  END IF;

               END;

               SEND_MAIL('Administrator', l_role, p_notification_code, c_actions.notification_message, p_notification_desc,
                          l_application_name, l_org_id, l_document_number, l_revision_number,
                          l_release_number, l_collaboration_id, l_collaboration_type);
            END IF;
         ELSIF c_actions.action_code = 'NOTIFY_DOC_OWNER' THEN
            BEGIN
                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('Entering notify document Owner', 1);
                END IF;

                SELECT OWNER_ROLE
                INTO l_role
                FROM CLN_COLL_HIST_HDR
                where COLLABORATION_ID = l_collaboration_id;

                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('Notification Receiver '||l_role, 1);
                END IF;

                BEGIN
                   SELECT 'x'
                   INTO l_temp
                   FROM WF_ROLES
                   WHERE NAME =  l_role
                     AND rownum < 2;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                        IF (l_Debug_Level <= 1) THEN
                                ecx_cln_debug_pub.Add('CLN Administrator Profile has email(not role)', 1);
                        END IF;

                        l_email := l_role;
                        l_role := 'CLN_ADMINISTRATOR';

                        SELECT email_address
                        INTO  l_admin_email
                        FROM WF_USERS
                        WHERE NAME = 'CLN_ADMINISTRATOR';

                        IF (l_Debug_Level <= 1) THEN
                                ecx_cln_debug_pub.Add('Administrator Role E-Mail:' || l_admin_email, 1);
                        END IF;

                        IF( l_email <> l_admin_email or l_admin_email is null) THEN
                           WF_DIRECTORY.SetAdHocUserAttr (USER_NAME => l_role, EMAIL_ADDRESS => l_email);
                        END IF;
                END;

                SEND_MAIL('Administrator', l_role, p_notification_code, c_actions.notification_message, p_notification_desc,
                          l_application_name, l_org_id, l_document_number, l_revision_number,
                          l_release_number, l_collaboration_id, l_collaboration_type);
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                   -- No Document Owner Found
                   IF (l_Debug_Level <= 4) THEN
                           ecx_cln_debug_pub.Add('No Document Owner Found', 3);
                   END IF;

            END;
         ELSIF c_actions.action_code = 'NOTIFY_TRADING_PARTNER' THEN
            BEGIN
               IF (l_Debug_Level <= 1) THEN
                       ecx_cln_debug_pub.Add('Entering notify trading partner', 1);
               END IF;
               SELECT company_admin_email
               INTO l_email
               FROM ecx_tp_headers
               where tp_header_id = l_tp_id;
               IF (l_Debug_Level <= 1) THEN
                       ecx_cln_debug_pub.Add('Queried the following from ecx_tp_headers using l_tp_id:' || l_tp_id, 1);
                       ecx_cln_debug_pub.Add('l_email:' || l_email, 1);
               END IF;
               l_role := null;
               l_temp := null;
               WF_DIRECTORY.CreateAdHocUser(name => l_role, display_name => l_temp, email_address => l_email, expiration_date => sysdate + 10);

               IF (l_Debug_Level <= 1) THEN
                          ecx_cln_debug_pub.Add('Before callling send_mail to trading partner- trading partner role : ' || l_role, 1);
               END IF;

               SEND_MAIL('Trading Partner', l_role, p_notification_code, c_actions.notification_message, p_notification_desc,
                          l_application_name, l_org_id, l_document_number, l_revision_number,
                          l_release_number, l_collaboration_id, l_collaboration_type);
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
               -- Invalid trading partner
               IF (l_Debug_Level <= 4) THEN
                       ecx_cln_debug_pub.Add('Invalid trading partner: Unable to notify trading partner:' || l_tp_id, 3);
               END IF;

               -- FND_MESSAGE.SET_NAME('CLN', 'CLN_INVALID_TRADING_PARTNER'); -- 'Invalid trading partner'
               -- x_ret_desc := FND_MESSAGE.GET;
               -- RAISE FND_API.G_EXC_ERROR;
            END;
         ELSIF c_actions.action_code = 'RAISE_EVENT' THEN
              l_cln_not_parameters := wf_parameter_list_t();
              WF_EVENT.AddParameterToList('ApplicationId', l_application_id, l_cln_not_parameters);
              WF_EVENT.AddParameterToList('CollaborationId', l_collaboration_id, l_cln_not_parameters);
              WF_EVENT.AddParameterToList('CollaborationType', l_collaboration_type, l_cln_not_parameters);
              WF_EVENT.AddParameterToList('ReferenceId', p_reference, l_cln_not_parameters);
              WF_EVENT.AddParameterToList('TradingPartnerID', l_tp_id, l_cln_not_parameters);
              WF_EVENT.AddParameterToList('HeaderDescription', p_header_desc, l_cln_not_parameters);
              WF_EVENT.AddParameterToList('NotificationDescription', p_notification_desc, l_cln_not_parameters);
              WF_EVENT.AddParameterToList('NotificationCode', p_notification_code, l_cln_not_parameters);
              WF_EVENT.AddParameterToList('Status', p_statuslvl, l_cln_not_parameters);
              -- User defined parameters
              IF c_actions.attribute2 IS NOT NULL THEN
                 WF_EVENT.AddParameterToList('Attribute1', c_actions.attribute2, l_cln_not_parameters);
              END IF;
              IF c_actions.attribute3 IS NOT NULL THEN
                 WF_EVENT.AddParameterToList('Attribute2', c_actions.attribute3, l_cln_not_parameters);
              END IF;
              IF c_actions.attribute4 IS NOT NULL THEN
                 WF_EVENT.AddParameterToList('Attribute3', c_actions.attribute4, l_cln_not_parameters);
              END IF;
              IF c_actions.attribute5 IS NOT NULL THEN
                 WF_EVENT.AddParameterToList('Attribute4', c_actions.attribute5, l_cln_not_parameters);
              END IF;
              IF c_actions.attribute6 IS NOT NULL THEN
                 WF_EVENT.AddParameterToList('Attribute5', c_actions.attribute6, l_cln_not_parameters);
              END IF;
              IF c_actions.attribute7 IS NOT NULL THEN
                 WF_EVENT.AddParameterToList('Attribute6', c_actions.attribute7, l_cln_not_parameters);
              END IF;
              IF c_actions.attribute8 IS NOT NULL THEN
                 WF_EVENT.AddParameterToList('Attribute7', c_actions.attribute8, l_cln_not_parameters);
              END IF;
              IF c_actions.attribute9 IS NOT NULL THEN
                 WF_EVENT.AddParameterToList('Attribute8', c_actions.attribute9, l_cln_not_parameters);
              END IF;
              IF c_actions.attribute10 IS NOT NULL THEN
                 WF_EVENT.AddParameterToList('Attribute9', c_actions.attribute10, l_cln_not_parameters);
              END IF;
              IF c_actions.attribute11 IS NOT NULL THEN
                 WF_EVENT.AddParameterToList('Attribute10', c_actions.attribute11, l_cln_not_parameters);
              END IF;
              IF c_actions.attribute12 IS NOT NULL THEN
                 WF_EVENT.AddParameterToList('Attribute11', c_actions.attribute12, l_cln_not_parameters);
              END IF;
              IF c_actions.attribute13 IS NOT NULL THEN
                 WF_EVENT.AddParameterToList('Attribute12', c_actions.attribute13, l_cln_not_parameters);
              END IF;
              IF c_actions.attribute14 IS NOT NULL THEN
                 WF_EVENT.AddParameterToList('Attribute13', c_actions.attribute14, l_cln_not_parameters);
              END IF;
              IF c_actions.attribute15 IS NOT NULL THEN
                 WF_EVENT.AddParameterToList('Attribute14', c_actions.attribute15, l_cln_not_parameters);
              END IF;
              SELECT cln_np_notification_workflow_s.nextval INTO l_notification_flow_key FROM dual;
              WF_EVENT.Raise(c_actions.attribute1, l_notification_flow_key, NULL, l_cln_not_parameters, NULL);
         ELSIF c_actions.action_code = 'PROCEDURE_CALL' THEN
            IF (l_Debug_Level <= 1) THEN
                    ecx_cln_debug_pub.Add('UserDefined PL/SQL API :' || c_actions.attribute1, 1);
                    ecx_cln_debug_pub.Add('UserDefined PL/SQL API Mode:' || c_actions.attribute3, 1);
            END IF;

            IF c_actions.attribute3 = 'CONCURRENT' THEN
               SELECT cln_np_notification_workflow_s.nextval INTO l_notification_flow_key FROM dual;
               IF (l_Debug_Level <= 2) THEN
                       ecx_cln_debug_pub.Add('INVOKING WF_ENGINE.CreateProcess:' || ':CLN_NP' || l_notification_flow_key || ':CALL_API_CONC', 2);
               END IF;

               WF_ENGINE.CreateProcess('CLN_NPNP', l_notification_flow_key, 'CALL_API_CONC');
               IF (l_Debug_Level <= 2) THEN
                       ecx_cln_debug_pub.Add('COMPLETED WF_ENGINE.CreateProcess:' || ':CLN_NP' || l_notification_flow_key || ':CALL_API_CONC', 2);
               END IF;

               WF_ENGINE.SetItemAttrText('CLN_NPNP',l_notification_flow_key, 'PROCEDURE_NAME', c_actions.attribute1);
               WF_ENGINE.SetItemAttrText('CLN_NPNP',l_notification_flow_key, 'APPLICATION_ID', l_application_id);
               WF_ENGINE.SetItemAttrText('CLN_NPNP',l_notification_flow_key, 'COLLABORATION_ID', l_collaboration_id);
               WF_ENGINE.SetItemAttrText('CLN_NPNP',l_notification_flow_key, 'COLLABORATION_TYPE', l_collaboration_type);
               WF_ENGINE.SetItemAttrText('CLN_NPNP',l_notification_flow_key, 'REFERENCE_ID', p_reference);
               WF_ENGINE.SetItemAttrText('CLN_NPNP',l_notification_flow_key, 'TRADING_PARTNER_ID', l_tp_id);
               WF_ENGINE.SetItemAttrText('CLN_NPNP',l_notification_flow_key, 'HEADER_DESC', p_header_desc);
               WF_ENGINE.SetItemAttrText('CLN_NPNP',l_notification_flow_key, 'NOTIFICATION_DESC', p_notification_desc);
               WF_ENGINE.SetItemAttrText('CLN_NPNP',l_notification_flow_key, 'NOTIFICATION_CODE', p_notification_code);
               WF_ENGINE.SetItemAttrText('CLN_NPNP',l_notification_flow_key, 'STATUS', p_statuslvl);
               IF (l_Debug_Level <= 2) THEN
                       ecx_cln_debug_pub.Add('INVOKING WF_ENGINE.StartProcess:' || ':CLN_NP' || l_notification_flow_key || ':CALL_API_CONC', 2);
               END IF;

               WF_ENGINE.StartProcess('CLN_NPNP', l_notification_flow_key);
               IF (l_Debug_Level <= 2) THEN
                       ecx_cln_debug_pub.Add('COMPLETED WF_ENGINE.StartProcess:' || ':CLN_NP' || l_notification_flow_key, 2);
               END IF;

            ELSE
               l_cln_not_parameters := wf_parameter_list_t();
               WF_EVENT.AddParameterToList('ApplicationId', l_application_id, l_cln_not_parameters);
               WF_EVENT.AddParameterToList('CollaborationId', l_collaboration_id, l_cln_not_parameters);
               WF_EVENT.AddParameterToList('CollaborationType', l_collaboration_type, l_cln_not_parameters);
               WF_EVENT.AddParameterToList('ReferenceId', p_reference, l_cln_not_parameters);
               WF_EVENT.AddParameterToList('TradingPartnerID', l_tp_id, l_cln_not_parameters);
               WF_EVENT.AddParameterToList('HeaderDescription', p_header_desc, l_cln_not_parameters);
               WF_EVENT.AddParameterToList('NotificationDescription', p_notification_desc, l_cln_not_parameters);
               WF_EVENT.AddParameterToList('NotificationCode', p_notification_code, l_cln_not_parameters);
               WF_EVENT.AddParameterToList('Status', p_statuslvl, l_cln_not_parameters);
               l_procedure_call_statement := 'begin ' || c_actions.attribute1 || '(:l_cln_not_parameters); end;';
               execute immediate l_procedure_call_statement using l_cln_not_parameters;
            END IF;
         ELSE
            FND_MESSAGE.SET_NAME('CLN', 'CLN_INVALID_ACTION_DEFINED'); -- 'Invalid action defined'
            x_ret_desc := FND_MESSAGE.GET;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
         EXCEPTION
            WHEN FND_API.G_EXC_ERROR THEN
               ROLLBACK TO ACTION;
               IF (l_Debug_Level <= 5) THEN
                       ecx_cln_debug_pub.Add('Rolledback transaction', 6);
                       ecx_cln_debug_pub.Add(x_ret_desc, 6);
               END IF;

               NOTIFY_ADMINISTRATOR('While trying to execute user defined actions as part of '
                                    || 'notification processing for inbound confirmbod for the '
                                    || 'collaboration ID#'
                                    || l_collaboration_id
                                    || ', the following error is encountered:'
                                    || x_ret_desc);
               IF (l_Debug_Level <= 2) THEN
                       ecx_cln_debug_pub.Add('Proceeding with the next action', 6);
               END IF;
            WHEN OTHERS THEN

               ROLLBACK TO ACTION;
               IF (l_Debug_Level <= 5) THEN
                       ecx_cln_debug_pub.Add('Rolledback transaction', 6);
               END IF;

               l_error_code := SQLCODE;
               l_error_msg := SQLERRM;
               IF (l_Debug_Level <= 5) THEN
                       ecx_cln_debug_pub.Add(l_error_code || ':' || l_error_msg, 6);
               END IF;

               NOTIFY_ADMINISTRATOR('While trying to execute user defined actions as part of '
                                    || 'notification processing for inbound confirmbod for the '
                                    || 'collaboration ID#'
                                    || l_collaboration_id
                                    || ', the following error is encountered:'
                                    || l_error_code || ':' || l_error_msg);
               IF (l_Debug_Level <= 5) THEN
                       ecx_cln_debug_pub.Add('Proceeding with the next action', 6);
               END IF;

         END;
      END Loop;
      IF (l_Debug_Level <= 2) THEN
              ecx_cln_debug_pub.Add('EXITING CLN_NP_PROCESSOR_PKG.TAKE_ACTIONS_INTERNAL', 2);
      END IF;

   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         x_ret_code := FND_API.G_RET_STS_ERROR;
         IF (l_Debug_Level <= 5) THEN
                 ecx_cln_debug_pub.Add(x_ret_desc, 6);
                 ecx_cln_debug_pub.Add('EXITING CLN_NP_PROCESSOR_PKG.TAKE_ACTIONS_INTERNAL', 2);
         END IF;

      WHEN OTHERS THEN
         l_error_code := SQLCODE;
         l_error_msg := SQLERRM;
         x_ret_code := FND_API.G_RET_STS_UNEXP_ERROR ;
         x_ret_desc := l_error_code || ':' || l_error_msg;
         IF (l_Debug_Level <= 5) THEN
                 ecx_cln_debug_pub.Add(x_ret_desc,6);
                 ecx_cln_debug_pub.Add('EXITING CLN_NP_PROCESSOR_PKG.TAKE_ACTIONS_INTERNAL', 2);
         END IF;

   END TAKE_ACTIONS_INTERNAL;


-- Name
--    PROCESS_NOTIFICATION
-- Purpose
--    Spec of package CLN_NP_PROCESSOR_PKG
--    Based on the notification code, fetches the notification actions
--    and executes the actions that are defined by the user.
--    The actions can be one of the following : Raise Event, Start Workflow,
--    Notify Administartor, Notify Trading Pratner and Call user Procedure.
--    This package is triggered by Notification Message Map when a Notification BOD arraives,
--    XML Gateway Error Handling.
-- Arguments
--    p_tp_id                     Trading Partner ID
--    notification_code           Notification Code Received
--    p_reference                 Application Reference ID
--    p_statuslvl                 '00' for Sucess and '99' for Error
--    p_header_desc               Header description
--    p_reason_code               Comma seperated list of notification code
--    p_line_desc                 Line description
--    p_int_con_no                Internal Control Number
--    p_coll_point                Collaboration Point
--    p_doc_dir                   Document Direction
-- Notes
--    No specific notes

PROCEDURE PROCESS_NOTIFICATION(
   x_ret_code          OUT NOCOPY VARCHAR2,
   x_ret_desc          OUT NOCOPY VARCHAR2,
   p_tp_id             IN  VARCHAR2,
   p_reference         IN  VARCHAR2,
   p_statuslvl         IN  VARCHAR2,
   p_header_desc       IN  VARCHAR2,
   p_reason_code       IN  VARCHAR2,
   p_line_desc         IN  VARCHAR2,
   p_int_con_no        IN  VARCHAR2,
   p_coll_point        IN  VARCHAR2,
   p_doc_dir           IN  VARCHAR2,
   p_coll_id           IN  NUMBER,
   p_collaboration_standard IN VARCHAR2)
IS
   l_all_reason_codes          VARCHAR2(255);
   l_reason_code               VARCHAR2(100);
   l_position_code             NUMBER;
   l_all_reason_desc           VARCHAR2(2000);
   l_reason_desc               VARCHAR2(1000);
   l_position_desc             NUMBER;
   l_success                   BOOLEAN;
   l_update_collaboration_flag BOOLEAN; -- For updating collaboration history only once
   l_dtl_coll_id               NUMBER(10);
   l_debug_mode                VARCHAR2(255);
   l_return_code               VARCHAR2(1000);
   l_return_desc               VARCHAR2(1000);
   l_error_code                NUMBER;
   l_error_msg                 VARCHAR2(1000);
BEGIN
   SAVEPOINT PROCESS_NOTIFICATION;
   -- Sets the debug mode to be FILE
   --l_debug_mode := ecx_cln_debug_pub.Set_Debug_Mode('FILE');
   IF (l_Debug_Level <= 2) THEN
           ecx_cln_debug_pub.Add('ENTERING CLN_NP_PROCESSOR_PKG.PROCESS_NOTIFICATION', 2);
   END IF;

   IF (l_Debug_Level <= 1) THEN
           ecx_cln_debug_pub.Add('With the following parameters:', 1);
           ecx_cln_debug_pub.Add('p_tp_id:' || p_tp_id, 1);
           ecx_cln_debug_pub.Add('p_reference:' || p_reference, 1);
           ecx_cln_debug_pub.Add('p_statuslvl:' || p_statuslvl, 1);
           ecx_cln_debug_pub.Add('p_header_desc:' || p_header_desc, 1);
           ecx_cln_debug_pub.Add('p_reason_code:' || p_reason_code, 1);
           ecx_cln_debug_pub.Add('p_line_desc:' || p_line_desc, 1);
           ecx_cln_debug_pub.Add('p_int_con_no:' || p_int_con_no, 1);
           ecx_cln_debug_pub.Add('p_coll_point:' || p_coll_point, 1);
           ecx_cln_debug_pub.Add('p_doc_dir:' || p_doc_dir, 1);
           ecx_cln_debug_pub.Add('p_coll_id:' || p_coll_id, 1);
           ecx_cln_debug_pub.Add('p_collaboration_standard:' || p_collaboration_standard, 1);
   END IF;


   x_ret_code := FND_API.G_RET_STS_SUCCESS;
   FND_MESSAGE.SET_NAME('CLN', 'CLN_SUCCESS'); -- 'Success'
   x_ret_desc := FND_MESSAGE.GET;

   l_update_collaboration_flag := TRUE; -- IF TRUE collaboration is updated
   IF p_reason_code = ':' or p_reason_code IS NULL THEN
      l_all_reason_codes := NULL;
      TAKE_ACTIONS_INTERNAL(l_return_code, l_return_desc, p_statuslvl, l_reason_desc,
                            p_tp_id, p_reference, p_statuslvl, p_header_desc,
                            l_update_collaboration_flag, true, p_reason_code,
                            p_int_con_no, p_coll_point, p_doc_dir,
                            p_coll_id, l_dtl_coll_id,p_collaboration_standard, null,null);
      IF l_return_code <> FND_API.G_RET_STS_SUCCESS THEN
         x_ret_desc := l_return_desc;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      l_update_collaboration_flag := FALSE; -- no need to update second or third time
   ELSE
      SELECT REPLACE(p_reason_code, '::', ':') INTO l_all_reason_codes FROM DUAL;
      SELECT REPLACE(p_line_desc, '::', ':') INTO l_all_reason_desc FROM DUAL;
      l_position_code := 0;
      l_position_desc := 0;
   END IF;

   WHILE l_all_reason_codes IS NOT NULL LOOP
      NEXT_PART(l_position_code,l_all_reason_codes,l_reason_code);
      NEXT_PART(l_position_desc,l_all_reason_desc,l_reason_desc);
      TAKE_ACTIONS_INTERNAL(l_return_code, l_return_desc, l_reason_code, l_reason_desc,
                            p_tp_id, p_reference, p_statuslvl, p_header_desc,
                            l_update_collaboration_flag, true, p_reason_code,
                            p_int_con_no, p_coll_point, p_doc_dir,
                            p_coll_id, l_dtl_coll_id,p_collaboration_standard,null,null);
      IF l_return_code <> FND_API.G_RET_STS_SUCCESS THEN
         x_ret_desc := l_return_desc;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      l_update_collaboration_flag := FALSE; -- no need to update second or third time
   END LOOP;
   IF (l_Debug_Level <= 2) THEN
           ecx_cln_debug_pub.Add('EXITING CLN_NP_PROCESSOR_PKG.PROCESS_NOTIFICATION', 2);
   END IF;

   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO PROCESS_NOTIFICATION;
         IF (l_Debug_Level <= 5) THEN
                 ecx_cln_debug_pub.Add('Rolledback transaction',5);
         END IF;

         x_ret_code := FND_API.G_RET_STS_ERROR;
         IF (l_Debug_Level <= 5) THEN
                 ecx_cln_debug_pub.Add(x_ret_desc, 6);
         END IF;

         NOTIFY_ADMINISTRATOR('Notification processing for inbound confirmbod '
                              || 'for the collaboration ID#'
                              || p_coll_id
                              || ', encountered the following error:'
                              || x_ret_desc);
         IF (l_Debug_Level <= 5) THEN
                 ecx_cln_debug_pub.Add('EXITING CLN_NP_PROCESSOR_PKG.PROCESS_NOTIFICATION', 2);
         END IF;

      WHEN OTHERS THEN
         ROLLBACK TO PROCESS_NOTIFICATION;
         IF (l_Debug_Level <= 5) THEN
                 ecx_cln_debug_pub.Add('Rolledback transaction');
         END IF;

         l_error_code := SQLCODE;
         l_error_msg := SQLERRM;
         x_ret_code := FND_API.G_RET_STS_UNEXP_ERROR;
         NOTIFY_ADMINISTRATOR('Notification processing for inbound confirmbod '
                              || 'for the collaboration ID#'
                              || p_coll_id
                              || ', encountered the following error:'
                              || l_error_code || ':' || l_error_msg);
         IF (l_Debug_Level <= 5) THEN
                 ecx_cln_debug_pub.Add(x_ret_desc, 6);
         END IF;

         NOTIFY_ADMINISTRATOR(x_ret_desc);
         IF (l_Debug_Level <= 5) THEN
                 ecx_cln_debug_pub.Add('EXITING CLN_NP_PROCESSOR_PKG.PROCESS_NOTIFICATION', 2);
         END IF;

END PROCESS_NOTIFICATION;



-- Name
--    TAKE_ACTIONS
-- Purpose
--    This procedure performs all the user defined actions for the specified comma seperated list of notification codes
-- Arguments
--    p_notification_code           Comma seperated list of notification code
--    p_notification_desc           Comma seperated list of notification description
--    p_status                      SUCCESS/ERROR
--    p_tp_id                       Trading Partner ID
--    p_reference                   Application Reference ID
--    p_coll_point                  Collaboration Point
--    p_int_con_no                  Internal Control number
-- Notes
--    No specific notes


PROCEDURE TAKE_ACTIONS(
   x_ret_code            OUT NOCOPY VARCHAR2,
   x_ret_desc            OUT NOCOPY VARCHAR2,
   p_notification_code   IN VARCHAR2,
   p_notification_desc   IN VARCHAR2,
   p_status              IN VARCHAR2,
   p_tp_id               IN VARCHAR2,
   p_reference           IN VARCHAR2,
   p_coll_point          IN VARCHAR2,
   p_int_con_no          IN VARCHAR2)
IS
   l_dtl_coll_id         NUMBER(10);
   l_statuslvl           VARCHAR2(10);
   l_return_code         VARCHAR2(1000);
   l_return_msg          VARCHAR2(1000);
   l_debug_mode          VARCHAR2(255);
BEGIN
   SAVEPOINT TAKE_ACTIONS;
   -- Sets the debug mode to be FILE
   --l_debug_mode := ecx_cln_debug_pub.Set_Debug_Mode('FILE');
   IF (l_Debug_Level <= 2) THEN
           ecx_cln_debug_pub.Add('ENTERING CLN_NP_PROCESSOR_PKG.TAKE_ACTIONS', 2);
   END IF;


   x_ret_code := FND_API.G_RET_STS_SUCCESS;
   FND_MESSAGE.SET_NAME('CLN', 'CLN_SUCCESS'); -- 'Success'
   x_ret_desc := FND_MESSAGE.GET;

   IF p_status = 'SUCCESS' THEN
      l_statuslvl := '00';
   ELSE
      l_statuslvl := '99';
   END IF;

   TAKE_ACTIONS_INTERNAL(l_return_code,
                         l_return_msg,
                         p_notification_code,
                         p_notification_desc,
                         p_tp_id,
                         p_reference,
                         l_statuslvl,
                         null,
                         false,
                         false,
                         null,
                         p_int_con_no,
                         p_coll_point,
                         null,
                         null,
                         l_dtl_coll_id,
                         null, null, null);
   IF l_return_code <> FND_API.G_RET_STS_SUCCESS THEN
      x_ret_desc := l_return_msg;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   IF (l_Debug_Level <= 2) THEN
           ecx_cln_debug_pub.Add('EXITING CLN_NP_PROCESSOR_PKG.TAKE_ACTIONS', 2);
   END IF;

   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO TAKE_ACTIONS;
         IF (l_Debug_Level <= 5) THEN
                 ecx_cln_debug_pub.Add('Rolledback transaction');
         END IF;

         x_ret_code := FND_API.G_RET_STS_ERROR;
         IF (l_Debug_Level <= 5) THEN
                 ecx_cln_debug_pub.Add(x_ret_desc, 6);
                 ecx_cln_debug_pub.Add('EXITING CLN_NP_PROCESSOR_PKG.TAKE_ACTIONS', 2);
         END IF;

      WHEN OTHERS THEN
         ROLLBACK TO TAKE_ACTIONS;
         IF (l_Debug_Level <= 5) THEN
                 ecx_cln_debug_pub.Add('Rolledback transaction');
         END IF;

         l_return_code := SQLCODE;
         l_return_msg := SQLERRM;
         x_ret_code := FND_API.G_RET_STS_UNEXP_ERROR;
         x_ret_desc := l_return_code||' : '||l_return_msg;
         IF (l_Debug_Level <= 5) THEN
                 ecx_cln_debug_pub.Add(x_ret_desc, 6);
                 ecx_cln_debug_pub.Add('EXITING CLN_NP_PROCESSOR_PKG.TAKE_ACTIONS', 2);
         END IF;

END TAKE_ACTIONS;

-- Name
--    GET_DELIMITER
-- Purpose
--    This function returns the delimiter character used to delimit a list of notification code/description
-- Arguments
--
-- Notes
--    No specific notes.

FUNCTION GET_DELIMITER RETURN VARCHAR2
IS
   l_delimter_chr  VARCHAR2(1);
BEGIN
   l_delimter_chr := fnd_global.local_chr(127);
RETURN l_delimter_chr;
END;


-- Name
--   GET_TRADING_PARTNER_DETAILS
-- Purpose
--   This procedure gets the trading partner id based on the internal control number
-- Arguments
--
-- Notes
--   No specific notes.

PROCEDURE GET_TRADING_PARTNER_DETAILS(
   x_return_status                OUT NOCOPY VARCHAR2,
   x_msg_data                     OUT NOCOPY VARCHAR2,
   p_xmlg_internal_control_number IN  NUMBER,
   p_tr_partner_id                IN OUT NOCOPY VARCHAR2)
IS
   l_error_code          NUMBER;
   l_msg_data            VARCHAR2(2000);
   l_error_msg           VARCHAR2(2000);
   l_return_code         VARCHAR2(2000);
   l_return_msg          VARCHAR2(2000);
   l_debug_mode          VARCHAR2(255);
BEGIN

   -- Sets the debug mode to be FILE
   --l_debug_mode := ecx_cln_debug_pub.Set_Debug_Mode('FILE');
   IF (l_Debug_Level <= 2) THEN
           ecx_cln_debug_pub.Add('ENTERING CLN_NP_PROCESSOR_PKG.GET_TRADING_PARTNER_DETAILS', 2);
   END IF;


   x_return_status := FND_API.G_RET_STS_SUCCESS;
   FND_MESSAGE.SET_NAME('CLN', 'CLN_SUCCESS'); -- 'Success'
   x_msg_data := FND_MESSAGE.GET;

   BEGIN
      SELECT  to_char(eth.tp_header_id)
      INTO    p_tr_partner_id
      FROM    ECX_DOCLOGS doclogs, ecx_ext_processes eep, ecx_tp_details etd, ecx_tp_headers eth, ecx_standards estd
      WHERE   doclogs.internal_control_number = p_xmlg_internal_control_number
      AND     eep.ext_type                    = doclogs.transaction_type
      AND     eep.ext_subtype                 = doclogs.transaction_subtype
      AND     eep.standard_id                 = estd.standard_id
      AND     estd.standard_code              = doclogs.message_standard
      AND     eep.ext_process_id              = etd.ext_process_id
      AND     etd.source_tp_location_code     = doclogs.party_site_id
      AND     eep.direction                   = 'IN'
      AND     eth.party_type                  = NVL(doclogs.party_type,eth.party_type);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('CLN','CLN_CH_TP_DETAILS_NOT_FOUND');
            x_msg_data := FND_MESSAGE.GET;
            RAISE FND_API.G_EXC_ERROR;
         WHEN TOO_MANY_ROWS THEN
            FND_MESSAGE.SET_NAME('CLN','CLN_CH_TP_DETAILS_NOT_FOUND');
            x_msg_data := FND_MESSAGE.GET;
            RAISE FND_API.G_EXC_ERROR;
   END;
   IF (l_Debug_Level <= 1) THEN
           ecx_cln_debug_pub.Add('p_tr_partner_id:' || p_tr_partner_id, 1);
   END IF;

   IF (l_Debug_Level <= 2) THEN
           ecx_cln_debug_pub.Add('EXITING GET_TRADING_PARTNER_DETAILS', 2);
   END IF;

   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
           IF (l_Debug_Level <= 5) THEN
                   ecx_cln_debug_pub.Add(x_msg_data, 4);
                   ecx_cln_debug_pub.Add('EXITING CLN_NP_PROCESSOR_PKG.GET_TRADING_PARTNER_DETAILS', 2);
           END IF;

     WHEN OTHERS THEN
           l_error_code := SQLCODE;
           l_error_msg := SQLERRM;
           x_msg_data := l_error_code || ':' || l_error_msg;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           IF (l_Debug_Level <= 5) THEN
                   ecx_cln_debug_pub.Add(x_msg_data, 6);
                   ecx_cln_debug_pub.Add('EXITING CLN_NP_PROCESSOR_PKG.GET_TRADING_PARTNER_DETAILS', 2);
           END IF;

   END GET_TRADING_PARTNER_DETAILS;



-- Name
--   NOTIFY_ADMINISTRATOR
-- Purpose
--   Sends a mail to the administrator
-- Arguments
--   Message to be send to the administrator
-- Notes
--   No specific notes.

PROCEDURE NOTIFY_ADMINISTRATOR(
   p_message IN VARCHAR2
)
IS
   l_notification_flow_key  NUMBER(20);
   l_email VARCHAR2(100);
   l_debug_mode VARCHAR2(255);
   l_error_code NUMBER;
   l_error_msg VARCHAR2(2000);
   l_admin_email VARCHAR2(1000);
   l_role        VARCHAR2(1000);
   l_temp        VARCHAR2(100);
BEGIN

   -- Sets the debug mode to be FILE
   --l_debug_mode := ecx_cln_debug_pub.Set_Debug_Mode('FILE');

   IF (l_Debug_Level <= 2) THEN
           ecx_cln_debug_pub.Add('ENTERING CLN_NP_PROCESSOR_PKG.NOTIFY_ADMINISTRATOR', 2);
   END IF;


   l_role := FND_PROFILE.VALUE('CLN_ADMINISTRATOR');
   IF (l_Debug_Level <= 1) THEN
           ecx_cln_debug_pub.Add('Administrator Profile Role or E-Mail:' || l_email, 1);
   END IF;

   BEGIN
      SELECT 'x'
      INTO l_temp
      FROM WF_ROLES
      WHERE NAME =  l_role
        AND rownum < 2;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('CLN Administrator Profile has email(not role)', 1);
      END IF;
      l_email := l_role;
      l_role := 'CLN_ADMINISTRATOR';
      SELECT email_address
      INTO  l_admin_email
      FROM WF_USERS
      WHERE NAME = 'CLN_ADMINISTRATOR';
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Administrator Role E-Mail:' || l_admin_email, 1);
      END IF;
      IF( l_email <> l_admin_email or l_admin_email is null) THEN
         WF_DIRECTORY.SetAdHocUserAttr (USER_NAME => l_role, EMAIL_ADDRESS => l_email);
      END IF;

   END;


   IF (l_Debug_Level <= 1) THEN
           ecx_cln_debug_pub.Add('About to start workflow', 1);
   END IF;


   SELECT cln_np_notification_workflow_s.nextval INTO l_notification_flow_key FROM dual;
   IF (l_Debug_Level <= 1) THEN
           ecx_cln_debug_pub.Add('Process Item Key to send a mail to administrator:' || l_notification_flow_key, 1);
   END IF;
   WF_ENGINE.CreateProcess('CLN_NPNP', l_notification_flow_key, 'NOTIFY');
   WF_ENGINE.SetItemAttrText('CLN_NPNP', l_notification_flow_key, 'NOTIFICATION_CONTENT', p_message);
   WF_ENGINE.SetItemAttrText('CLN_NPNP', l_notification_flow_key, 'CLN_PERFORMER', l_role );
   WF_ENGINE.StartProcess('CLN_NPNP', l_notification_flow_key);

   IF (l_Debug_Level <= 2) THEN
           ecx_cln_debug_pub.Add('EXITING CLN_NP_PROCESSOR_PKG.NOTIFY_ADMINISTRATOR', 2);
   END IF;

   EXCEPTION
      WHEN OTHERS THEN
         l_error_code := SQLCODE;
         l_error_msg := SQLERRM;
         IF (l_Debug_Level <= 5) THEN
                 ecx_cln_debug_pub.Add(l_error_code || ':' || l_error_msg, 6);
                 ecx_cln_debug_pub.Add('Failed to send a mail to administrator', 3);
                 ecx_cln_debug_pub.Add('EXITING CLN_NP_PROCESSOR_PKG.NOTIFY_ADMINISTRATOR', 2);
         END IF;

END NOTIFY_ADMINISTRATOR;




-- Name
--    PROCESS_NOTIF_ACTIONS_EVT
-- Purpose
--    This procedure handles a notification by executing all the actions defined by the user
--    for a given notification code.
--
-- Arguments
--
-- Notes
--    No specific notes

PROCEDURE PROCESS_NOTIF_ACTIONS_EVT(
         x_return_status                        OUT NOCOPY VARCHAR2,
         x_msg_data                             OUT NOCOPY VARCHAR2,
         p_coll_id                              IN  NUMBER,
         p_xmlg_transaction_type                IN  VARCHAR2,
         p_xmlg_transaction_subtype             IN  VARCHAR2,
         p_xmlg_int_transaction_type            IN  VARCHAR2,
         p_xmlg_int_transaction_subtype         IN  VARCHAR2,
         p_xmlg_document_id                     IN  VARCHAR2,
         p_doc_dir                              IN  VARCHAR2,
         p_tr_partner_type                      IN  VARCHAR2,
         p_tr_partner_id                        IN  VARCHAR2,
         p_tr_partner_site                      IN  VARCHAR2,
         p_xmlg_msg_id                          IN  VARCHAR2,
         p_application_id                       IN  VARCHAR2,
         p_unique1                              IN  VARCHAR2,
         p_unique2                              IN  VARCHAR2,
         p_unique3                              IN  VARCHAR2,
         p_unique4                              IN  VARCHAR2,
         p_unique5                              IN  VARCHAR2,
         p_xmlg_internal_control_number         IN  NUMBER,
         p_collaboration_pt                     IN  VARCHAR2,
         p_notification_code                    IN  VARCHAR2,
         p_notification_desc                    IN  VARCHAR2,
         p_notification_status                  IN  VARCHAR2,
         p_notification_event                   IN  WF_EVENT_T )

IS
         l_coll_id                              NUMBER;
         l_error_code                           NUMBER;

         l_application_name                     VARCHAR2(100);

         l_error_msg                            VARCHAR2(2000);
         l_msg_data                             VARCHAR2(2000);
         l_xmlg_internal_control_number         NUMBER;
         l_xmlg_msg_id                          VARCHAR2(100);
         l_xmlg_transaction_type                VARCHAR2(100);
         l_xmlg_transaction_subtype             VARCHAR2(100);
         l_xmlg_int_transaction_type            VARCHAR2(100);
         l_xmlg_int_transaction_subtype         VARCHAR2(100);
         l_xmlg_document_id                     VARCHAR2(256);
         l_doc_dir                              VARCHAR2(240);
         l_tr_partner_type                      VARCHAR2(30);
         l_tr_partner_id                        VARCHAR2(256);
         l_tr_partner_site                      VARCHAR2(256);
         l_application_id                       VARCHAR2(10);
         l_collaboration_pt                     VARCHAR2(20);

         l_notification_code                    VARCHAR2(30);
         l_notification_desc                    VARCHAR2(1000);
         l_notification_status                  VARCHAR2(30);

         l_unique1                              VARCHAR2(30);
         l_unique2                              VARCHAR2(30);
         l_unique3                              VARCHAR2(30);
         l_unique4                              VARCHAR2(30);
         l_unique5                              VARCHAR2(30);

         l_statuslvl                            VARCHAR2(10);

         l_admin_email                          VARCHAR2(1000);
         l_role                                 VARCHAR2(1000);
         l_temp                                 VARCHAR2(100);
         l_email                                VARCHAR2(255);
         l_return_status                        VARCHAR2(1000);
         l_sender_component                     VARCHAR2(500);
         l_xml_event_key                        VARCHAR2(240);
         l_coll_type                            VARCHAR2(30);
         l_return_msg                           VARCHAR2(1000);
         l_return_code                          VARCHAR2(1000);
         l_org_id                               VARCHAR2(100);
         l_collaboration_standard               VARCHAR2(30);
         l_doc_type                             VARCHAR2(100);
         l_document_number                      VARCHAR2(255);

         l_dtl_coll_id                          NUMBER;


BEGIN
         IF (l_Debug_Level <= 2) THEN
                ecx_cln_debug_pub.Add('ENTERING CLN_NP_PROCESSOR_PKG.PROCESS_NOTIF_ACTIONS_EVT', 2);
         END IF;

         --  Initialize API return status to success
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         l_msg_data     := 'Notifications Processing Successfully completed';

         -- get the paramaters passed
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('==========Parameters Received=============',1);
                 ecx_cln_debug_pub.Add('COLLABORATION ID                    ----- >>>'||p_coll_id,1);
                 ecx_cln_debug_pub.Add('APPLCATION ID                       ----- >>>'||p_application_id,1);
                 ecx_cln_debug_pub.Add('XMLG EXT TRANSACTION TYPE           ----- >>>'||p_xmlg_transaction_type,1);
                 ecx_cln_debug_pub.Add('XMLG EXT TRANSACTION SUBTYPE        ----- >>>'||p_xmlg_transaction_subtype,1);
                 ecx_cln_debug_pub.Add('XMLG INT TRANSACTION TYPE           ----- >>>'||p_xmlg_int_transaction_type,1);
                 ecx_cln_debug_pub.Add('XMLG INT TRANSACTION SUBTYPE        ----- >>>'||p_xmlg_int_transaction_subtype,1);
                 ecx_cln_debug_pub.Add('XMLG DOCUMENT ID                    ----- >>>'||p_xmlg_document_id,1);
                 ecx_cln_debug_pub.Add('DOCUMENT DIRECTION                  ----- >>>'||p_doc_dir,1);
                 ecx_cln_debug_pub.Add('COLLABORATION POINT                 ----- >>>'||p_collaboration_pt,1);
                 ecx_cln_debug_pub.Add('XMLG MESSAGE ID                     ----- >>>'||p_xmlg_msg_id,1);
                 ecx_cln_debug_pub.Add('UNIQUE 1                            ----- >>>'||p_unique1,1);
                 ecx_cln_debug_pub.Add('UNIQUE 2                            ----- >>>'||p_unique2,1);
                 ecx_cln_debug_pub.Add('UNIQUE 3                            ----- >>>'||p_unique3,1);
                 ecx_cln_debug_pub.Add('UNIQUE 4                            ----- >>>'||p_unique4,1);
                 ecx_cln_debug_pub.Add('UNIQUE 5                            ----- >>>'||p_unique5,1);
                 ecx_cln_debug_pub.Add('TRADING PARTNER TYPE                ----- >>>'||p_tr_partner_type,1);
                 ecx_cln_debug_pub.Add('TRADING PARTNER ID                  ----- >>>'||p_tr_partner_id,1);
                 ecx_cln_debug_pub.Add('TRADING PARTNER SITE                ----- >>>'||p_tr_partner_site,1);
                 ecx_cln_debug_pub.Add('XMLG INTERNAL CONTROL NO            ----- >>>'||p_xmlg_internal_control_number,1);
                 ecx_cln_debug_pub.Add('NOTIFICATION CODE                   ----- >>>'||p_notification_code,1);
                 ecx_cln_debug_pub.Add('NOTIFICATION DESC                   ----- >>>'||p_notification_desc,1);
                 ecx_cln_debug_pub.Add('NOTIFICATION STATUS                 ----- >>>'||p_notification_status,1);
                 ecx_cln_debug_pub.Add('=========================================================',1);
         END IF;



         -- assigning parameter to local variables
         l_xmlg_internal_control_number   :=    p_xmlg_internal_control_number;
         l_xmlg_msg_id                    :=    p_xmlg_msg_id;
         l_xmlg_transaction_type          :=    p_xmlg_transaction_type;
         l_xmlg_transaction_subtype       :=    p_xmlg_transaction_subtype;
         l_xmlg_int_transaction_type      :=    p_xmlg_int_transaction_type;
         l_xmlg_int_transaction_subtype   :=    p_xmlg_int_transaction_subtype;
         l_xmlg_document_id               :=    p_xmlg_document_id;
         l_doc_dir                        :=    p_doc_dir;
         l_tr_partner_type                :=    p_tr_partner_type;
         l_tr_partner_id                  :=    p_tr_partner_id;
         l_tr_partner_site                :=    p_tr_partner_site;
         l_application_id                 :=    p_application_id;
         l_coll_id                        :=    p_coll_id;
         l_unique1                        :=    p_unique1;
         l_unique2                        :=    p_unique2;
         l_unique3                        :=    p_unique3;
         l_unique4                        :=    p_unique4;
         l_unique5                        :=    p_unique5;
         l_xmlg_internal_control_number   :=    p_xmlg_internal_control_number;
         l_collaboration_pt               :=    p_collaboration_pt;
         l_notification_code              :=    p_notification_code;
         l_notification_desc              :=    p_notification_desc;
         l_notification_status            :=    p_notification_status;


         -- Getting External Transaction type and Subtype associated with Internal transaction type
         -- and Internal transaction subtype
         IF((l_xmlg_int_transaction_type IS NOT NULL) AND (l_xmlg_int_transaction_subtype IS NOT NULL) AND (l_tr_partner_id IS NOT NULL) AND (l_tr_partner_site IS NOT NULL)) THEN
                IF ((l_xmlg_transaction_type IS NULL) OR (l_xmlg_transaction_subtype IS NULL)) THEN

                     IF (l_Debug_Level <= 1) THEN
                             ecx_cln_debug_pub.Add('Getting values for External Transaction type and SubType and msg standard',1);
                     END IF;

                     BEGIN
                                SELECT ecxproc.EXT_TYPE,ecxproc.EXT_SUBTYPE
                                INTO l_xmlg_transaction_type, l_xmlg_transaction_subtype
                                FROM ecx_tp_headers eth, ecx_tp_details etd, ECX_TRANSACTIONS ecxtrans, ECX_EXT_PROCESSES ecxproc, ecx_standards estd
                                WHERE eth.party_id                = l_tr_partner_id
                                AND eth.party_site_id             = l_tr_partner_site
                                AND eth.party_type                = nvl(l_tr_partner_type, eth.party_type)
                                AND eth.tp_header_id              = etd.tp_header_id
                                AND etd.ext_process_id            = ecxproc.ext_process_id
                                AND ecxtrans.transaction_id       = ecxproc.transaction_id
                                AND ecxtrans.transaction_type     = l_xmlg_int_transaction_type
                                AND ecxtrans.transaction_subtype  = l_xmlg_int_transaction_subtype
                                AND ecxproc.direction             = nvl(l_doc_dir,ecxproc.direction)
                                AND estd.standard_id              = ecxproc.standard_id;

                                IF (l_Debug_Level <= 1) THEN
                                        ecx_cln_debug_pub.Add('====Parameters Received From ECX_TRANSACTIONS/ECX_EXT_PROCESSES====',1);
                                        ecx_cln_debug_pub.Add('XMLG EXT TRANSACTION TYPE      ----- >>>'||l_xmlg_transaction_type,1);
                                        ecx_cln_debug_pub.Add('XMLG EXT TRANSACTION SUBTYPE   ----- >>>'||l_xmlg_transaction_subtype,1);
                                        ecx_cln_debug_pub.Add('==================================================================',1);
                                END IF;

                     EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                        FND_MESSAGE.SET_NAME('CLN', 'CLN_CH_TRANSACTION_NOT_FOUND');
                                        x_msg_data := FND_MESSAGE.GET;
                                        l_msg_data := 'Unable to find External Transaction Type/ Subtype';

                                        RAISE FND_API.G_EXC_ERROR;

                                WHEN TOO_MANY_ROWS THEN
                                        FND_MESSAGE.SET_NAME('CLN', 'CLN_CH_EXCESS_TXN_FOUND');
                                        x_msg_data := FND_MESSAGE.GET;
                                        l_msg_data      := 'More then one row found for the same transaction detail';
                                        RAISE FND_API.G_EXC_ERROR;
                     END;
                END IF;
         END IF;


         -- Retrieving Collaboration ID incase the the collaboration id supplied by user is null
         --check whether the collaboration is being recorded or not at first instance
         IF l_coll_id IS NULL THEN

                IF (l_Debug_Level <= 1) THEN
                     ecx_cln_debug_pub.Add('Collaboration ID passed as null',1);
                     ecx_cln_debug_pub.Add('==========Call to FIND_COLLABORATION_ID API=============',1);
                END IF;

                CLN_CH_COLLABORATION_PKG.FIND_COLLABORATION_ID(
                        x_return_status                        => x_return_status,
                        x_msg_data                             => x_msg_data,
                        x_coll_id                              => l_coll_id,
                        p_app_id                               => l_application_id,
                        p_coll_type                            => null,
                        p_ref_id                               => null,
                        p_xmlg_transaction_type                => l_xmlg_transaction_type,
                        p_xmlg_transaction_subtype             => l_xmlg_transaction_subtype,
                        p_xmlg_int_transaction_type            => l_xmlg_int_transaction_type,
                        p_xmlg_int_transaction_subtype         => l_xmlg_int_transaction_subtype,
                        p_tr_partner_type                      => l_tr_partner_type,
                        p_tr_partner_id                        => l_tr_partner_id,
                        p_tr_partner_site                      => l_tr_partner_site,
                        p_xmlg_document_id                     => l_xmlg_document_id,
                        p_doc_dir                              => l_doc_dir,
                        p_xmlg_msg_id                          => l_xmlg_msg_id,
                        p_unique1                              => l_unique1,
                        p_unique2                              => l_unique2,
                        p_unique3                              => l_unique3,
                        p_unique4                              => l_unique4,
                        p_unique5                              => l_unique5,
                        p_xmlg_internal_control_number         => l_xmlg_internal_control_number,
                        p_xml_event_key                        => null);

                IF ( x_return_status <> 'S') THEN
                        l_msg_data  := 'Error in FIND_COLLABORATION_ID - ' || x_msg_data;
                        -- l_msg_data is set to appropriate value by FIND_COLLABORATION_ID
                        -- RAISE FND_API.G_EXC_ERROR;

                        -- we are not throwing any error here so as to make this module
                        -- work even when no collaboration exists
                END IF;
         END IF;

         -- Call the API to get the trading partner set up details
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('==========Call to GET_TRADING_PARTNER_DETAILS API=============',1);
         END IF;

        CLN_CH_COLLABORATION_PKG.GET_TRADING_PARTNER_DETAILS(
                 x_return_status                        => x_return_status,
                 x_msg_data                             => x_msg_data,
                 p_xmlg_internal_control_number         => l_xmlg_internal_control_number,
                 p_xmlg_msg_id                          => l_xmlg_msg_id,
                 p_xmlg_transaction_type                => l_xmlg_transaction_type,
                 p_xmlg_transaction_subtype             => l_xmlg_transaction_subtype,
                 p_xmlg_int_transaction_type            => l_xmlg_int_transaction_type,
                 p_xmlg_int_transaction_subtype         => l_xmlg_int_transaction_subtype,
                 p_xmlg_document_id                     => l_xmlg_document_id,
                 p_doc_dir                              => l_doc_dir,
                 p_tr_partner_type                      => l_tr_partner_type,
                 p_tr_partner_id                        => l_tr_partner_id,
                 p_tr_partner_site                      => l_tr_partner_site,
                 p_sender_component                     => l_sender_component,
                 p_xml_event_key                        => l_xml_event_key,
                 p_collaboration_standard               => l_collaboration_standard);

         IF ( x_return_status <> 'S') THEN
                 l_msg_data  := 'Error in GET_TRADING_PARTNER_DETAILS ';
                 -- x_msg_data is set to appropriate value by GET_TRADING_PARTNER_DETAILS
                 RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF (l_Debug_Level <= 1) THEN
                 -- call the API to get the default parameters through XMLG settings
                 ecx_cln_debug_pub.Add('==========Call to DEFAULT_XMLGTXN_MAPPING API=============',1);
         END IF;

         CLN_CH_COLLABORATION_PKG.DEFAULT_XMLGTXN_MAPPING(
                x_return_status                => x_return_status,
                x_msg_data                     => x_msg_data,
                p_xmlg_transaction_type        => l_xmlg_transaction_type,
                p_xmlg_transaction_subtype     => l_xmlg_transaction_subtype,
                p_doc_dir                      => l_doc_dir,
                p_app_id                       => l_application_id,
                p_coll_type                    => l_coll_type,
                p_doc_type                     => l_doc_type );

         IF ( x_return_status <> 'S') THEN
                l_msg_data      := 'Error in DEFAULT_XMLGTXN_MAPPING';
                -- x_msg_data is set to appropriate value by DEFAULT_XMLGTXN_MAPPING
                -- RAISE FND_API.G_EXC_ERROR;
                -- No need to set up defaulting data when no collaboration exists
         END IF;


         IF(l_notification_code IS NULL) THEN
               x_return_status := FND_API.G_RET_STS_SUCCESS ;
               RETURN;
         END IF;

         IF l_notification_status = 'SUCCESS' THEN
                l_statuslvl := '00';
         ELSE
                l_statuslvl := '99';
         END IF;

         -- if send_mail is not null, directly call send_mail api.
         -- if notification_code is not null, then proceed further else return.

         CLN_NP_PROCESSOR_PKG.TAKE_ACTIONS_INTERNAL(
                x_ret_code                    => x_return_status,
                x_ret_desc                    => x_msg_data,
                p_notification_code           => l_notification_code,
                p_notification_desc           => l_notification_desc,
                p_tp_id                       => l_tr_partner_id,
                p_reference                   => null,
                p_statuslvl                   => l_statuslvl,
                p_header_desc                 => null,
                p_update_collaboration_flag   => false,
                p_update_coll_mess_flag       => false,
                p_all_notification_codes      => null,
                p_int_con_no                  => l_xmlg_internal_control_number,
                p_coll_point                  => l_collaboration_pt,
                p_doc_dir                     => l_doc_dir,
                p_coll_id                     => l_coll_id,
                x_dtl_coll_id                 => l_dtl_coll_id,
                p_collaboration_standard      => null,
                p_notification_event          => p_notification_event,
                p_application_id              => l_application_id  );


        IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                l_msg_data  := 'Error in TAKE_ACTIONS_INTERNAL API ';
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF (l_Debug_Level <= 2) THEN
                ecx_cln_debug_pub.Add('EXITING CLN_NP_PROCESSOR_PKG.PROCESS_NOTIF_ACTIONS_EVT', 2);
        END IF;

   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         x_return_status        := FND_API.G_RET_STS_ERROR;
         IF (l_Debug_Level <= 5) THEN
                 ecx_cln_debug_pub.Add('EXITING CLN_NP_PROCESSOR_PKG.PROCESS_NOTIF_ACTIONS_EVT', 2);
         END IF;

      WHEN OTHERS THEN
         l_return_code   := SQLCODE;
         l_return_msg    := SQLERRM;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_msg_data      := l_return_code||' : '||x_msg_data;

         IF (l_Debug_Level <= 5) THEN
                 ecx_cln_debug_pub.Add(x_msg_data, 6);
                 ecx_cln_debug_pub.Add('EXITING CLN_NP_PROCESSOR_PKG.PROCESS_NOTIF_ACTIONS_EVT', 2);
         END IF;

END PROCESS_NOTIF_ACTIONS_EVT;


-- Name
--    PROCESS_NOTIF_BATCH_EVT
-- Purpose
--    This procedure handles a Batch notification request by executing all the actions
--    defined by the user for a given notification code.
--
-- Arguments
--
-- Notes
--    No specific notes

PROCEDURE PROCESS_NOTIF_BATCH_EVT(
      	  x_return_status                        OUT NOCOPY VARCHAR2,
      	  x_msg_data                             OUT NOCOPY VARCHAR2,
	  p_attribute_name			 IN  VARCHAR2,
	  p_attribute_value			 IN  VARCHAR2,
	  p_notification_receiver		 IN  VARCHAR2,
	  p_application_id                       IN  VARCHAR2,
	  p_collaboration_std  		         IN  VARCHAR2,
	  p_collaboration_type  		 IN  VARCHAR2,
	  p_collaboration_point  		 IN  VARCHAR2,
      	  p_notification_code                    IN  VARCHAR2,
      	  p_notification_msg                     IN  VARCHAR2,
      	  p_notification_status                  IN  VARCHAR2 )
IS


         l_error_code                           NUMBER;
	 l_attribute_name			VARCHAR2(150);
         l_attribute_value			VARCHAR2(150);
         l_attribute_col_value			VARCHAR2(150);
         l_notif_receiver_role			VARCHAR2(100);
         l_application_name                     VARCHAR2(100);
         l_notification_flow_key  		NUMBER;

         l_error_msg                            VARCHAR2(2000);
         l_msg_data                             VARCHAR2(2000);
         l_application_id                       VARCHAR2(10);
         l_collaboration_pt                     VARCHAR2(20);

         l_notification_code                    VARCHAR2(30);
         l_notification_desc                    VARCHAR2(1000);
         l_notification_msg                     VARCHAR2(1000);
         l_notification_dtls                    VARCHAR2(1000);
         l_notification_status                  VARCHAR2(30);

	 l_collaboration_std               	VARCHAR2(30);
         l_collaboration_type              	VARCHAR2(30);

         l_admin_email                          VARCHAR2(1000);
         l_role                                 VARCHAR2(1000);
         l_temp                                 VARCHAR2(100);
         l_email                                VARCHAR2(255);
         l_return_status                        VARCHAR2(1000);
         l_return_msg                           VARCHAR2(1000);
         l_return_code                          VARCHAR2(1000);
         l_org_id                               VARCHAR2(100);
         l_collaboration_standard               VARCHAR2(30);

BEGIN
         IF (l_Debug_Level <= 2) THEN
                ecx_cln_debug_pub.Add('ENTERING CLN_NP_PROCESSOR_PKG.PROCESS_NOTIF_BATCH_EVT', 2);
         END IF;

         --  Initialize API return status to success
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         l_msg_data     := 'Batch Notification Processing Successfully completed';

         -- get the paramaters passed
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('==========Parameters Received=============',1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE NAME                      ----- >>>'||p_attribute_name,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE VALUE                     ----- >>>'||p_attribute_value,1);
                 ecx_cln_debug_pub.Add('APPLICATION ID                      ----- >>>'||p_application_id,1);
                 ecx_cln_debug_pub.Add('COLLABORATION STD                   ----- >>>'||p_collaboration_std,1);
                 ecx_cln_debug_pub.Add('COLLABORATION TYPE                  ----- >>>'||p_collaboration_type,1);
                 ecx_cln_debug_pub.Add('COLLABORATION POINT                 ----- >>>'||p_collaboration_point,1);
                 ecx_cln_debug_pub.Add('NOTIFICATION RECEIVER               ----- >>>'||p_notification_receiver,1);
                 ecx_cln_debug_pub.Add('NOTIFICATION CODE                   ----- >>>'||p_notification_code,1);
                 ecx_cln_debug_pub.Add('NOTIFICATION DESC                   ----- >>>'||p_notification_msg,1);
                 ecx_cln_debug_pub.Add('NOTIFICATION STATUS                 ----- >>>'||p_notification_status,1);
                 ecx_cln_debug_pub.Add('=========================================================',1);
         END IF;

         -- assigning parameter to local variables
         l_attribute_name   		:=    p_attribute_name;
         l_attribute_value              :=    p_attribute_value;
         l_notif_receiver_role          :=    p_notification_receiver;
         l_application_id		:=    p_application_id;
         l_collaboration_std		:=    p_collaboration_std;

       	 IF (l_Debug_Level <= 4) THEN
           	ecx_cln_debug_pub.Add('Getting the Application Name from the Application ID as '||l_application_id, 1);
       	 END IF;


         -- Query fnd_application_vl for application name using application id
      	 BEGIN
      	   	SELECT application_name
      	   	INTO l_application_name
      	   	FROM fnd_application_vl
      	   	WHERE application_id = l_application_id;

      	   	IF (l_Debug_Level <= 1) THEN
           	      ecx_cln_debug_pub.Add('Queried the following from fnd_application_vl using application id:'|| l_application_id, 1);
           	      ecx_cln_debug_pub.Add('APPLICATION NAME           	     ----- >>>'||l_application_name, 1);
      	   	END IF;

      	 EXCEPTION
      	      WHEN NO_DATA_FOUND THEN
      	         -- INVALID APPLICATION ID
      	         FND_MESSAGE.SET_NAME('CLN', 'CLN_INVALID_APPL_ID'); -- 'Invalid application id'
      	         x_msg_data := FND_MESSAGE.GET;
       	         RAISE FND_API.G_EXC_ERROR;
      	 END;

         IF(l_attribute_name IS NULL) OR (l_attribute_value IS NULL) THEN
      	         FND_MESSAGE.SET_NAME('CLN','CLN_CH_BATCH_PARAM_NULL');
      	         x_msg_data := FND_MESSAGE.GET;
       	         RAISE FND_API.G_EXC_ERROR;
         END IF;

       	 IF (l_Debug_Level <= 4) THEN
           	  ecx_cln_debug_pub.Add('Queried the display setup using application id/collaboration standard/attribute name as :'|| l_application_id||'/'||l_collaboration_std||'/'||l_attribute_name, 1);
       	 END IF;


	 -- GET THE ATTRIBUTE COLUMN NAME
         BEGIN
		SELECT tl.display_label
		INTO l_attribute_col_value
		FROM CLN_CH_DISPLAY_LABELS_DTL_tl tl, CLN_CH_DISPLAY_LABELS_DTL_VL vl, CLN_CH_DISPLAY_LABELS_hdr hdr
		WHERE tl.guid 	= vl.guid
		AND parent_guid = hdr.guid
		AND collaboration_standard 	= l_collaboration_std
		AND application_id         	= l_application_id
		AND cln_columns            	= l_attribute_name
		AND collaboration_type IS NULL
		AND LANGUAGE = USERENV('LANG');

      	   	IF (l_Debug_Level <= 1) THEN
           	      ecx_cln_debug_pub.Add('ATTRIBUTE COLUMN VALUE              ----- >>>'||l_attribute_col_value, 1);
      	   	END IF;

      	 EXCEPTION
      	      WHEN NO_DATA_FOUND THEN
      	         -- DISPLAY SETUP NOT DONE
      	         FND_MESSAGE.SET_NAME('CLN', 'CLN_DISPLAY_SETUP_ERROR');
      	         FND_MESSAGE.SET_TOKEN('APPLID',l_application_id);
		 FND_MESSAGE.SET_TOKEN('COLLSTD',l_collaboration_std);

       	   	 IF (l_Debug_Level <= 4) THEN
           	      ecx_cln_debug_pub.Add('Display SetUp Not Found forapplication id/collaboration standard/attribute name as :'|| l_application_id||'/'||l_collaboration_std||'/'||l_attribute_name, 4);
       	   	 END IF;

      	         x_msg_data := FND_MESSAGE.GET;
       	         RAISE FND_API.G_EXC_ERROR;
      	 END;

       	 IF (l_Debug_Level <= 4) THEN
           	ecx_cln_debug_pub.Add('Getting the Notification desc for Code  ----- >>>'||p_notification_code, 1);
       	 END IF;

         IF(p_collaboration_point IS NOT NULL AND p_notification_code IS NOT NULL) THEN
         	BEGIN
			SELECT codestl.NOTIFICATION_MESSAGE
			INTO l_notification_desc
			FROM CLN_NOTIFICATION_CODES codes, CLN_NOTIFICATION_CODES_TL codestl
			WHERE codes.NOTIFICATION_ID = codestl.NOTIFICATION_ID
			AND NOTIFICATION_CODE = p_notification_code
			AND COLLABORATION_POINT = p_collaboration_point
			AND LANGUAGE = USERENV('LANG');

      	 	  	IF (l_Debug_Level <= 1) THEN
         	  	      ecx_cln_debug_pub.Add('Queried the Notification Codes Setup', 1);
         	  	      ecx_cln_debug_pub.Add('NOTIFICATION DESC                   ----- >>>'||l_notification_desc, 1);
      	 	  	END IF;

      	 	EXCEPTION
      	 	     WHEN NO_DATA_FOUND THEN
      	 	        -- DISPLAY SETUP NOT DONE
       	 	  	 IF (l_Debug_Level <= 4) THEN
         	  	      ecx_cln_debug_pub.Add('No setup found for Notification Code ---- >>>'||p_notification_code, 4);
       	 	  	 END IF;
       	 	  	 l_notification_desc	:= 'xxxxxxxxxx';
      	 	END;
      	 ELSE
	  	l_notification_desc	:= 'xxxxxxxxxx';
      	 END IF;


	 IF(l_notif_receiver_role IS NULL) THEN
    	 	IF (l_Debug_Level <= 1) THEN
         	  	ecx_cln_debug_pub.Add('Notification Receiver Defaulted to CLN:Admimistrator', 1);
       	 	END IF;

	 	l_notif_receiver_role := FND_PROFILE.VALUE('CLN_ADMINISTRATOR');

    	 	IF (l_Debug_Level <= 1) THEN
         	  	ecx_cln_debug_pub.Add('Notification Receiver                ---- >>>'||l_notif_receiver_role, 1);
       	 	END IF;
	 END IF;

         BEGIN
                   SELECT 'x'
                   INTO l_temp
                   FROM WF_ROLES
                   WHERE NAME =  l_notif_receiver_role
                   AND rownum < 2;

         EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                        IF (l_Debug_Level <= 1) THEN
                                ecx_cln_debug_pub.Add('CLN Administrator Profile has email(not role)', 1);
                        END IF;

                        l_email := l_notif_receiver_role;
                        l_role := 'CLN_ADMINISTRATOR';

                        SELECT email_address
                        INTO  l_admin_email
                        FROM WF_USERS
                        WHERE NAME = 'CLN_ADMINISTRATOR';

                        IF (l_Debug_Level <= 1) THEN
                                ecx_cln_debug_pub.Add('Administrator Role E-Mail:' || l_admin_email, 1);
                        END IF;

                        IF( l_email <> l_admin_email or l_admin_email is null) THEN
                           WF_DIRECTORY.SetAdHocUserAttr (USER_NAME => l_role, EMAIL_ADDRESS => l_email);
                        END IF;
         END;


	 SELECT cln_np_notification_workflow_s.nextval INTO l_notification_flow_key FROM dual;


	 ------------ get the notification details -----------
      	 FND_MESSAGE.SET_NAME('CLN', 'CLN_NOTIF_DTLS');
      	 FND_MESSAGE.SET_TOKEN('ATTRNAME',l_attribute_col_value);
	 FND_MESSAGE.SET_TOKEN('ATTRVALUE',p_attribute_value);
	 l_notification_dtls := FND_MESSAGE.GET;

       	 IF (l_Debug_Level <= 4) THEN
               ecx_cln_debug_pub.Add('l_notification_dtls    : '||l_notification_dtls , 4);
       	 END IF;

      	 -------------

    	 IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Calling CLN_NPNP/NOTIFY_BATCH', 1);
   	 END IF;


   	 WF_ENGINE.CreateProcess('CLN_NPNP', l_notification_flow_key, 'NOTIFY_BATCH');
   	 WF_ENGINE.SetItemAttrText('CLN_NPNP', l_notification_flow_key, 'APPLICATION_NAME', l_application_name);
   	 WF_ENGINE.SetItemAttrText('CLN_NPNP', l_notification_flow_key, 'APPLICATION_ID', l_application_id);
   	 WF_ENGINE.SetItemAttrText('CLN_NPNP', l_notification_flow_key, 'COLLABORATION_STD', p_collaboration_std);
	 WF_ENGINE.SetItemAttrText('CLN_NPNP', l_notification_flow_key, 'NOTIFICATION_CODE', p_notification_code);
   	 WF_ENGINE.SetItemAttrText('CLN_NPNP', l_notification_flow_key, 'NOTIFICATION_MESSAGE', p_notification_msg);
   	 WF_ENGINE.SetItemAttrText('CLN_NPNP', l_notification_flow_key, 'NOTIFICATION_DESC', l_notification_desc);
   	 WF_ENGINE.SetItemAttrText('CLN_NPNP', l_notification_flow_key, 'NOTIFICATION_DTLS', l_notification_dtls);
   	 WF_ENGINE.SetItemAttrText('CLN_NPNP', l_notification_flow_key, 'ATTRIBUTE_COL_NAME', p_attribute_name);
   	 WF_ENGINE.SetItemAttrText('CLN_NPNP', l_notification_flow_key, 'ATTRIBUTE_COL_VALUE', l_attribute_col_value);
   	 WF_ENGINE.SetItemAttrText('CLN_NPNP', l_notification_flow_key, 'ATTRIBUTE_VALUE', p_attribute_value);
   	 WF_ENGINE.SetItemAttrText('CLN_NPNP', l_notification_flow_key, 'CLN_PERFORMER', l_notif_receiver_role);
   	 WF_ENGINE.StartProcess('CLN_NPNP', l_notification_flow_key);

   	 IF (l_Debug_Level <= 2) THEN
   	         ecx_cln_debug_pub.Add('EXITING CLN_NP_PROCESSOR_PKG.SEND_MAIL', 2);
   	 END IF;


         IF (l_Debug_Level <= 2) THEN
                ecx_cln_debug_pub.Add('EXITING CLN_NP_PROCESSOR_PKG.PROCESS_NOTIF_BATCH_EVT', 2);
         END IF;

   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         x_return_status        := FND_API.G_RET_STS_ERROR;
         IF (l_Debug_Level <= 5) THEN
                 ecx_cln_debug_pub.Add('EXITING CLN_NP_PROCESSOR_PKG.PROCESS_NOTIF_BATCH_EVT', 2);
         END IF;

      WHEN OTHERS THEN
         l_return_code   := SQLCODE;
         l_return_msg    := SQLERRM;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_msg_data      := l_return_code||' : '||x_msg_data;

         IF (l_Debug_Level <= 5) THEN
                 ecx_cln_debug_pub.Add(x_msg_data, 6);
                 ecx_cln_debug_pub.Add('EXITING CLN_NP_PROCESSOR_PKG.PROCESS_NOTIF_BATCH_EVT', 2);
         END IF;

END PROCESS_NOTIF_BATCH_EVT;

END CLN_NP_PROCESSOR_PKG;

/
