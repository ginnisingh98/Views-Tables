--------------------------------------------------------
--  DDL for Package Body CLN_NP_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CLN_NP_UTILS_PKG" AS
/* $Header: CLNNPUTLB.pls 115.0 2003/10/31 07:21:06 vumapath noship $ */
-- Package
--   CLN_NP_UTILS_PKG
--
-- Purpose
--    Specification of package body: CLN_NP_UTILS_PKG.
--    This package bundles all the utility functions of
--    notification Processing module for processing inbound messages
--
-- History
--    Oct-16-2003       Viswanthan Umapathy         Created

l_debug_level        NUMBER := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));

   -- Name
   --    UPDATE_COLLABORATION
   -- Purpose
   --    This procedure raises collaboration update event to update a collaboration.
   --    passing all the procedure parameters as event parameters
   -- Arguments
   --
   -- Notes
   --    No specific notes.

   PROCEDURE UPDATE_COLLABORATION(
      x_return_status      OUT NOCOPY VARCHAR2,
      x_msg_data           OUT NOCOPY VARCHAR2,
      p_ref_id             IN  VARCHAR2,
      p_doc_no             IN  VARCHAR2,
      p_part_doc_no        IN  VARCHAR2,
      p_msg_text           IN  VARCHAR2,
      p_status_code        IN  NUMBER,
      p_int_ctl_num        IN  NUMBER,
      p_tp_header_id       IN  NUMBER)
   IS
      l_cln_ch_parameters  wf_parameter_list_t;
      l_event_key          NUMBER;
      l_error_code         NUMBER;
      l_error_msg          VARCHAR2(2000);
      l_debug_mode         VARCHAR2(255);
      l_doc_status         VARCHAR2(255);
   BEGIN
      -- Sets the debug mode to be FILE
      l_debug_mode := cln_debug_pub.Set_Debug_Mode('FILE');

      IF (l_Debug_Level <= 2) THEN
         cln_debug_pub.Add('ENTERING UPDATE_COLLABORATION', 2);
      END IF;

      --  Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      FND_MESSAGE.SET_NAME('CLN','CLN_CH_EVENT_RAISED');
      FND_MESSAGE.SET_TOKEN('EVENT','Update');
      x_msg_data := FND_MESSAGE.GET;

      SELECT cln_generic_s.nextval INTO l_event_key FROM dual;

      IF (l_Debug_Level <= 1) THEN
         cln_debug_pub.Add('With the following parameters', 1);
         cln_debug_pub.Add('p_ref_id' || p_ref_id, 1);
         cln_debug_pub.Add('p_doc_no:' || p_doc_no, 1);
         cln_debug_pub.Add('p_status_code:' || p_status_code, 1);
         cln_debug_pub.Add('p_msg_text:' || p_msg_text, 1);
         cln_debug_pub.Add('p_part_doc_no:' || p_part_doc_no, 1);
         cln_debug_pub.Add('p_int_ctl_num:' || p_int_ctl_num, 1);
         cln_debug_pub.Add('p_tp_header_id:' || p_tp_header_id, 1);
      END IF;

      IF p_status_code = 0 THEN
         l_doc_status := 'SUCCESS';
      -- ELSIF p_status_code = 1 THEN
      --    l_doc_status := 'ERROR';
      ELSE
         l_doc_status := 'ERROR';
      END IF;

      IF (l_Debug_Level <= 1) THEN
         cln_debug_pub.Add('l_doc_status:' || l_doc_status, 1);
      END IF;

      l_cln_ch_parameters := wf_parameter_list_t();

      WF_EVENT.AddParameterToList('XMLG_INTERNAL_CONTROL_NUMBER', p_int_ctl_num, l_cln_ch_parameters);
      WF_EVENT.AddParameterToList('REFERENCE_ID', p_ref_id, l_cln_ch_parameters);

      WF_EVENT.AddParameterToList('DOCUMENT_NO', p_doc_no, l_cln_ch_parameters);
      WF_EVENT.AddParameterToList('PARTNER_DOCUMENT_NO', p_part_doc_no, l_cln_ch_parameters);
      WF_EVENT.AddParameterToList('ORIGINATOR_REFERENCE', p_doc_no, l_cln_ch_parameters);

      WF_EVENT.AddParameterToList('DOCUMENT_STATUS', l_doc_status, l_cln_ch_parameters);
      WF_EVENT.AddParameterToList('MESSAGE_TEXT', p_msg_text, l_cln_ch_parameters);

      WF_EVENT.Raise('oracle.apps.cln.ch.collaboration.update',
                          l_event_key, NULL, l_cln_ch_parameters, NULL);

      IF (l_Debug_Level <= 1) THEN
         cln_debug_pub.Add('Workflow event- oracle.apps.cln.ch.collaboration.update raised', 1);
      END IF;

      IF (l_Debug_Level <= 2) THEN
         cln_debug_pub.Add('EXITING UPDATE_COLLABORATION', 2);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         l_error_code    := SQLCODE;
         l_error_msg     := SQLERRM;
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_msg_data      := l_error_code || ':' || l_error_msg;
         IF (l_Debug_Level <= 6) THEN
            cln_debug_pub.Add(x_msg_data, 4);
         END IF;
         IF (l_Debug_Level <= 2) THEN
            cln_debug_pub.Add('EXITING UPDATE_COLLABORATION', 2);
         END IF;
   END UPDATE_COLLABORATION;



   -- Name
   --    ADD_COLLABORATION_MESSAGE
   -- Purpose
   --    This procedure raise event to add messages into collaboration history
   --    passing all the procedure parameters as event parameters
   -- Arguments
   --    Internal Control Number
   --    Reference 1 to 5
   --    Message Text
   -- Notes
   --    No specific notes.

         PROCEDURE ADD_COLLABORATION_MESSAGE(
            x_return_status        OUT NOCOPY VARCHAR2,
            x_msg_data             OUT NOCOPY VARCHAR2,
            p_ictrl_no             IN  NUMBER,
            p_ref1                 IN  VARCHAR2,
            p_ref2                 IN  VARCHAR2,
            p_ref3                 IN  VARCHAR2,
            p_ref4                 IN  VARCHAR2,
            p_ref5                 IN  VARCHAR2,
            p_dtl_msg              IN  VARCHAR2)
         IS
            l_cln_ch_parameters    wf_parameter_list_t;
            l_event_key            NUMBER;
            l_error_code           NUMBER;
            l_error_msg            VARCHAR2(2000);
            l_debug_mode           VARCHAR2(255);
            l_msg_data             VARCHAR2(2000);
         BEGIN
            -- Sets the debug mode to be FILE
            l_debug_mode :=cln_debug_pub.Set_Debug_Mode('FILE');

            IF (l_Debug_Level <= 2) THEN
               cln_debug_pub.Add('ENTERING ADD_COLLABORATION_MESSAGE', 2);
            END IF;

            -- Parameters received
            IF (l_Debug_Level <= 1) THEN
               cln_debug_pub.Add('With the following parameters',1);
               cln_debug_pub.Add('p_ictrl_no           - ' || p_ictrl_no,1);
               cln_debug_pub.Add('p_ref1               - ' || p_ref1,1);
               cln_debug_pub.Add('p_ref2               - ' || p_ref2,1);
               cln_debug_pub.Add('p_ref3               - ' || p_ref3,1);
               cln_debug_pub.Add('p_ref4               - ' || p_ref4,1);
               cln_debug_pub.Add('p_ref5               - ' || p_ref5,1);
               cln_debug_pub.Add('p_dtl_msg            - ' || p_dtl_msg,1);
            END IF;

            -- Initialize API return status to success
            x_return_status := FND_API.G_RET_STS_SUCCESS;
            FND_MESSAGE.SET_NAME('CLN', 'CLN_G_RET_MSG_SUCCESS');
            x_msg_data := FND_MESSAGE.GET;


            SELECT cln_generic_s.nextval INTO l_event_key FROM dual;

            l_cln_ch_parameters := wf_parameter_list_t();

            WF_EVENT.AddParameterToList('REFERENCE_ID1', p_ref1, l_cln_ch_parameters);
            WF_EVENT.AddParameterToList('REFERENCE_ID2', p_ref2, l_cln_ch_parameters);
            WF_EVENT.AddParameterToList('REFERENCE_ID3', p_ref3, l_cln_ch_parameters);
            WF_EVENT.AddParameterToList('REFERENCE_ID4', p_ref4, l_cln_ch_parameters);
            WF_EVENT.AddParameterToList('REFERENCE_ID5', p_ref5, l_cln_ch_parameters);
            WF_EVENT.AddParameterToList('DETAIL_MESSAGE', p_dtl_msg, l_cln_ch_parameters);
            WF_EVENT.AddParameterToList('XMLG_INTERNAL_CONTROL_NUMBER', p_ictrl_no, l_cln_ch_parameters);
            -- WF_EVENT.AddParameterToList('DOCUMENT_TYPE', 'SALES_ORDER', l_cln_ch_parameters);
            WF_EVENT.AddParameterToList('DOCUMENT_DIRECTION', 'IN', l_cln_ch_parameters);
            -- Not required since defaulted to APPS
            -- WF_EVENT.AddParameterToList('COLLABORATION_POINT', 'APPS', l_cln_ch_parameters);

            WF_EVENT.Raise('oracle.apps.cln.ch.collaboration.addmessage',
                               l_event_key, NULL, l_cln_ch_parameters, NULL);

            IF (l_Debug_Level <= 1) THEN
               cln_debug_pub.Add('Workflow event- oracle.apps.cln.ch.collaboration.addmessage', 1);
            END IF;

            IF (l_Debug_Level <= 2) THEN
               cln_debug_pub.Add('EXITING ADD_COLLABORATION_MESSAGE', 2);
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               l_error_code    := SQLCODE;
               l_error_msg     := SQLERRM;
               x_return_status := FND_API.G_RET_STS_ERROR;
               x_msg_data        := l_error_code || ':' || l_error_msg;
               IF (l_Debug_Level <= 6) THEN
                  cln_debug_pub.Add(x_msg_data, 4);
               END IF;
               IF (l_Debug_Level <= 2) THEN
                  cln_debug_pub.Add('EXITING ADD_COLLABORATION_MESSAGE', 2);
               END IF;
         END ADD_COLLABORATION_MESSAGE;



   -- Name
   --    GET_FND_MESSSAGE
   -- Purpose
   --    Gets the FND message for the given message name
   --    substituting the token values
   -- Arguments
   --    FND message name
   --    Token Name
   --    Token Value
   -- Notes
   --    No specific notes

      PROCEDURE GET_FND_MESSSAGE(
         p_fnd_message_name IN  VARCHAR2,
         p_token_name1      IN  VARCHAR2,
         p_token_value1     IN  VARCHAR2,
         p_token_name2      IN  VARCHAR2,
         p_token_value2     IN  VARCHAR2,
         p_message          OUT NOCOPY VARCHAR2
         )
      IS
         l_return_msg       VARCHAR2(2000);
         l_debug_mode       VARCHAR2(300);
         l_error_code       NUMBER;
         l_error_msg        VARCHAR2(2000);
      BEGIN

         -- Sets the debug mode to be FILE
         l_debug_mode := cln_debug_pub.Set_Debug_Mode('FILE');

         IF (l_Debug_Level <= 2) THEN
            cln_debug_pub.Add('ENTERING GET_FND_MESSSAGE', 2);
         END IF;

         IF (l_Debug_Level <= 1) THEN
            cln_debug_pub.Add('With the following parameters:', 1);
            cln_debug_pub.Add('p_fnd_message_name:'   || p_fnd_message_name, 1);
            cln_debug_pub.Add('p_token_name1:'        || p_token_name1, 1);
            cln_debug_pub.Add('p_token_value1:'       || p_token_value1, 1);
            cln_debug_pub.Add('p_token_name2:'        || p_token_name2, 1);
            cln_debug_pub.Add('p_token_value2:'       || p_token_value2, 1);
         END IF;

         FND_MESSAGE.SET_NAME('CLN', p_fnd_message_name);
         IF p_token_name1 IS NOT NULL THEN
            FND_MESSAGE.SET_TOKEN(p_token_name1, p_token_value1);
         END IF;
         IF p_token_name2 IS NOT NULL THEN
            FND_MESSAGE.SET_TOKEN(p_token_name2, p_token_value2);
         END IF;
         p_message := FND_MESSAGE.GET;

         IF (l_Debug_Level <= 1) THEN
            cln_debug_pub.Add('p_message:' || p_message, 1);
         END IF;

         IF (l_Debug_Level <= 2) THEN
            cln_debug_pub.Add('EXITING GET_FND_MESSSAGE', 2);
         END IF;

      EXCEPTION
         WHEN OTHERS THEN
            l_error_code    := SQLCODE;
            l_error_msg     := SQLERRM;
            l_return_msg      := l_error_code||' : '||l_error_msg;
            cln_debug_pub.Add(l_return_msg, 3);
            l_return_msg := 'While trying to get the FND message '
                                    || ' for '
                                    || p_fnd_message_name
                                    || ', the following error is encountered:'
                                    || l_return_msg;
            IF (l_Debug_Level <= 6) THEN
               cln_debug_pub.Add(l_return_msg, 3);
            END IF;
            IF (l_Debug_Level <= 2) THEN
               cln_debug_pub.Add('EXITING GET_FND_MESSSAGE', 2);
            END IF;
      END GET_FND_MESSSAGE;




   -- Name
   --   CALL_TAKE_ACTIONS
   -- Purpose
   --   Invokes Notification Processor TAKE_ACTIONS according to the parameter.
   -- Arguments
   --
   -- Notes
   --   No specific notes.

      PROCEDURE CALL_TAKE_ACTIONS(
         p_itemtype        IN VARCHAR2,
         p_itemkey         IN VARCHAR2,
         p_actid           IN NUMBER,
         p_funcmode        IN VARCHAR2,
         x_resultout       IN OUT NOCOPY VARCHAR2)
     IS
         l_doc_status         VARCHAR2(100);
         l_trp_id             VARCHAR2(100);
         l_app_ref_id         VARCHAR2(255);
         l_return_status      VARCHAR2(1000);
         l_return_msg         VARCHAR2(2000);
         l_error_code         NUMBER;
         l_error_msg          VARCHAR2(2000);
         l_msg_data           VARCHAR2(1000);
         l_not_msg            VARCHAR2(1000);
         l_debug_mode         VARCHAR2(255);
         l_tp_id              NUMBER;
         l_ret_status         VARCHAR2(5);
         l_cbod_statuslvl     VARCHAR2(5);
         l_int_ctl_num        NUMBER;
         l_not_code1          VARCHAR2(255);
         l_not_code_desc1     VARCHAR2(2000);
         l_tp_type            VARCHAR2(255);
      BEGIN

         -- Sets the debug mode to be FILE
         l_debug_mode :=cln_debug_pub.Set_Debug_Mode('FILE');

         x_resultout:='Yes';

         IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('ENTERING CALL_TAKE_ACTIONS API', 2);
         END IF;

         IF (l_Debug_Level <= 1) THEN
            cln_debug_pub.Add('Parameters:', 1);
         END IF;

         -- Internal Control Number
         l_int_ctl_num := to_number(wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER1', TRUE));
            IF (l_Debug_Level <= 1) THEN
               cln_debug_pub.Add('l_int_ctl_num:' || l_int_ctl_num, 1);
            END IF;

         -- Application Reference ID
         l_app_ref_id := wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER4', TRUE);
            IF (l_Debug_Level <= 1) THEN
               cln_debug_pub.Add('l_app_ref_id:' || l_app_ref_id, 1);
            END IF;

         -- Document Status
         l_doc_status := wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER5', TRUE);
            IF (l_Debug_Level <= 1) THEN
               cln_debug_pub.Add('l_doc_status:' || l_doc_status, 1);
            END IF;

         -- TP Header ID
         l_trp_id := wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER10', TRUE);
            IF (l_Debug_Level <= 1) THEN
               cln_debug_pub.Add('l_tp_id:' || l_trp_id, 1);
            END IF;

         -- Confirm BOD Status lvl
         l_cbod_statuslvl := wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER2', TRUE);
            IF (l_Debug_Level <= 1) THEN
               cln_debug_pub.Add('l_cbod_statuslvl:' || l_cbod_statuslvl, 1);
            END IF;


         -- If either statuslvl or document status is available, set the other one
         IF l_doc_status IS NOT NULL THEN -- Set the value of statuslvl based on document status
	    IF l_cbod_statuslvl IS NULL THEN
	       IF (l_doc_status = 'SUCCESS') THEN
                  wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER2', '00');
               ELSE -- Assertion l_doc_status = 'ERROR'
                  wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER2', '99');
               END IF;
            END IF;
         ELSE -- Set the value of document status based on statuslvl
	    IF l_cbod_statuslvl IS NOT NULL THEN
	       IF (l_cbod_statuslvl = '00') THEN
                  wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER5', 'SUCCESS');
               ELSE -- Assertion l_cbod_statuslvl = '99'
                  wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER5', 'ERROR');
               END IF;
            END IF;
	 END IF;

         -- Notification Code1
         l_not_code1 := wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER6', TRUE);
            IF (l_Debug_Level <= 1) THEN
               cln_debug_pub.Add('l_not_code1:' || l_not_code1, 1);
            END IF;

         -- Notification Code Description1
         l_not_code_desc1 := wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER7', TRUE);
            IF (l_Debug_Level <= 1) THEN
               cln_debug_pub.Add('l_not_code_desc1:' || l_not_code_desc1, 1);
            END IF;


         -- Trading Partner Type
         l_tp_type := wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER8', TRUE);
            IF (l_Debug_Level <= 1) THEN
               cln_debug_pub.Add('l_tp_type:' || l_tp_type, 1);
            END IF;

         -- For futurte use
         -- l_unused := wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER9', TRUE);


         CLN_UTILS.GET_TRADING_PARTNER(l_trp_id, l_tp_id);
            IF (l_Debug_Level <= 1) THEN
               cln_debug_pub.Add('Trading Partner ID:' || l_tp_id, 1);
            END IF;


         IF l_not_code1 IS NOT NULL AND LENGTH(TRIM(l_not_code1)) > 0 THEN
            CLN_NP_PROCESSOR_PKG.TAKE_ACTIONS(
               x_ret_code            => l_return_status,
               x_ret_desc            => l_return_msg,
               p_notification_code   => l_not_code1,
               p_notification_desc   => l_not_code_desc1,
               p_status              => l_doc_status,
               p_tp_id               => to_char(l_tp_id),
               p_reference           => l_app_ref_id,
               p_coll_point          => 'APPS',
               p_int_con_no          => l_int_ctl_num);
            IF l_return_status <> 'S' THEN
               IF (l_Debug_Level <= 6) THEN
                  cln_debug_pub.Add('CALL_TAKE_ACTIONS CALL FAILED', 6);
               END IF;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;

         IF (l_Debug_Level <= 2) THEN
            cln_debug_pub.Add('EXITING CALL_TAKE_ACTIONS API', 2);
         END IF;

      EXCEPTION
         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            IF (l_Debug_Level <= 6) THEN
               cln_debug_pub.Add(l_return_msg, 6);
            END IF;

            CLN_NP_PROCESSOR_PKG.NOTIFY_ADMINISTRATOR(l_return_msg);
            IF (l_Debug_Level <= 2) THEN
                    cln_debug_pub.Add('EXITING CALL_TAKE_ACTIONS API', 2);
            END IF;

         WHEN OTHERS THEN
            l_error_code  := SQLCODE;
            l_error_msg   := SQLERRM;
            l_not_msg := l_error_code || ':' || l_error_msg;
            IF (l_Debug_Level <= 6) THEN
               cln_debug_pub.Add(l_not_msg, 6);
            END IF;

            CLN_NP_PROCESSOR_PKG.NOTIFY_ADMINISTRATOR(l_not_msg);
            IF (l_Debug_Level <= 2) THEN
               cln_debug_pub.Add('EXITING CALL_TAKE_ACTIONS API', 2);
            END IF;
    END CALL_TAKE_ACTIONS;



END CLN_NP_UTILS_PKG;

/
