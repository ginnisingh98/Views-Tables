--------------------------------------------------------
--  DDL for Package Body CLN_ACK_PO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CLN_ACK_PO_PKG" AS
/* $Header: CLNACKPB.pls 120.2 2006/03/27 00:34:33 kkram noship $ */
   l_debug_level        NUMBER := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));
   TYPE t_line_num_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   l_line_num_tab t_line_num_tab;

--  Package
--      CLN_ACK_PO_PKG
--
--  Purpose
--      Body of package CLN_ACK_PO_PKG.
--
--  History
--      May-14-2002        Rahul Krishan         Created

   -- Name
   --    IS_ALREADY_PROCESSED_LINE
   -- Purpose
   --    Checks whether a line is already processed or not
   -- Arguments
   --   PO Line Num


      FUNCTION IS_ALREADY_PROCESSED_LINE(
         p_line_num             IN  VARCHAR2)
         RETURN BOOLEAN
      IS
           i           binary_integer;
      BEGIN
         IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('ENTERING PROCESS_ORDER_HEADER,p_requestor:' || p_line_num, 2);
         END IF;

           i := l_line_num_tab.first();
           while i is not null loop
             IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('next element:' || l_line_num_tab(i), 1);
             END IF;
             IF (l_line_num_tab(i) = p_line_num ) THEN
                IF (l_Debug_Level <= 2) THEN
                       cln_debug_pub.Add('EXITING PROCESS_ORDER_HEADER:Line is duplicate', 1);
                END IF;
                RETURN TRUE;
             END IF;
             i := l_line_num_tab.next(i);
           end loop;
           l_line_num_tab(l_line_num_tab.count()+1) := p_line_num;
           IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('EXITING PROCESS_ORDER_HEADER:Line is not duplicate', 1);
           END IF;
           RETURN FALSE;
      END;


   -- Name
   --    RAISE_UPDATE_EVENT
   -- Purpose
   --    This is the public procedure which raises an event to update collaboration passing these parameters so
   --    obtained.This procedure actually requires only three input parameters viz. p_coll_id, p_org_ref
   --    p_msg_text, p_internal_control_number but due to previous coding and its dependencies,
   --    the signature of this procedure is left as it is.The previously used code is simply commented out.
   --    This procedure is called from PROCESS_HEADER_LINES.
   --
   -- Arguments
   --
   -- Notes
   --    No specific notes.

   PROCEDURE RAISE_UPDATE_EVENT(
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_coll_id                      IN  NUMBER,
         p_doc_status                   IN  VARCHAR2,
         p_org_ref                      IN  VARCHAR2,
         p_disposition                  IN  VARCHAR2,
         p_msg_text                     IN  VARCHAR2,
         p_internal_control_number      IN  VARCHAR2 )

   IS
         l_cln_ch_parameters            wf_parameter_list_t;
         l_event_key                    NUMBER;
         l_rosettanet_check_required    VARCHAR2(10);
         l_error_code                   NUMBER;
         l_error_msg                    VARCHAR2(255);
         l_debug_mode                   VARCHAR2(255);
         l_msg_data                     VARCHAR2(255);

   BEGIN
         -- Sets the debug mode to be FILE
         --l_debug_mode := cln_debug_pub.Set_Debug_Mode('FILE');
         IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('-------- ENTERING RAISE_UPDATE_EVENT -----------', 2);
         END IF;

         --  Initialize API return status to success
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         l_msg_data      := 'Update event successfully raised';

         FND_MESSAGE.SET_NAME('CLN','CLN_CH_EVENT_RAISED');
         FND_MESSAGE.SET_TOKEN('EVENT','Update');
         x_msg_data := FND_MESSAGE.GET;

         SELECT  cln_generic_s.nextval INTO l_event_key FROM dual;

         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('----------- PARAMETERS OBTAINED ----------', 1);
                 cln_debug_pub.Add('Collaboration ID            ---- '||p_coll_id, 1);
                 cln_debug_pub.Add('Document Status             ---- '||p_doc_status, 1);
                 cln_debug_pub.Add('Disposition                 ---- '||p_disposition, 1);
                 cln_debug_pub.Add('Originator Reference (SO Number) ---- '||p_org_ref, 1);
                 cln_debug_pub.Add('Message Text                ---- '||p_msg_text, 1);
                 cln_debug_pub.Add('Internal Control Number     ---- '||p_internal_control_number, 1);
                 cln_debug_pub.Add('------------------------------------------', 1);
                 cln_debug_pub.Add('----------- SETTING DEFAULT VALUES ----------', 1);
         END IF;
         l_rosettanet_check_required  :=        'TRUE'          ;

         l_cln_ch_parameters := wf_parameter_list_t();
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('-------- SETTING EVENT PARAMETERS -----------', 1);
         END IF;
         WF_EVENT.AddParameterToList('COLLABORATION_ID', p_coll_id, l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('DOCUMENT_STATUS', p_doc_status, l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('DISPOSITION', p_disposition, l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('ORIGINATOR_REFERENCE', p_org_ref, l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('MESSAGE_TEXT', p_msg_text, l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('ROSETTANET_CHECK_REQUIRED',l_rosettanet_check_required,l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('XMLG_INTERNAL_CONTROL_NUMBER',p_internal_control_number,l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('PARTNER_DOCUMENT_NO',p_org_ref,l_cln_ch_parameters);
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('-------- EVENT PARAMETERS SET-----------', 1);
                 cln_debug_pub.Add('Workflow event- oracle.apps.cln.ch.collaboration.update', 1);
         END IF;

         WF_EVENT.Raise('oracle.apps.cln.ch.collaboration.update',l_event_key, NULL, l_cln_ch_parameters, NULL);
         IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('----------- EXITING RAISE_UPDATE_EVENT ------------', 2);
         END IF;


   EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
            l_error_code        := SQLCODE;
            l_error_msg         := SQLERRM;
            x_return_status     := FND_API.G_RET_STS_ERROR ;
            x_msg_data          := l_error_code||' : '||l_error_msg;
            IF (l_Debug_Level <= 6) THEN
                    cln_debug_pub.Add('Error:' || l_error_code || ':' || l_error_msg, 6);
                    cln_debug_pub.Add('----------- ERROR :EXITING RAISE_UPDATE_EVENT ------------', 6);
            END IF;

         WHEN OTHERS THEN
            l_error_code    := SQLCODE;
            l_error_msg     := SQLERRM;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MESSAGE.SET_NAME('CLN','CLN_CH_UNEXPECTED_ERROR');
            FND_MESSAGE.SET_TOKEN('ERRORCODE',l_error_code);
            FND_MESSAGE.SET_TOKEN('ERRORMSG',l_error_msg);
            x_msg_data      := FND_MESSAGE.GET;
            IF (l_Debug_Level <= 6) THEN
                    cln_debug_pub.Add('Unexpected Error:' || l_error_code || ':' || l_error_msg, 6);
                    cln_debug_pub.Add('----------- ERROR :EXITING RAISE_UPDATE_EVENT ------------', 2);
            END IF;

   END RAISE_UPDATE_EVENT;




   -- Name
   --    RAISE_ADD_MSG_EVENT
   -- Purpose
   --    This is the public procedure which is used to raise an event that add messages into collaboration history passing
   --    these parameters so obtained.This procedure is called
   --    from PROCESS_HEADER_LINES.
   --
   -- Arguments
   --
   -- Notes
   --    No specific notes.

   PROCEDURE RAISE_ADD_MSG_EVENT(
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_coll_id                      IN  NUMBER,
         p_ref1                         IN  VARCHAR2,
         p_ref2                         IN  VARCHAR2,
         p_ref3                         IN  VARCHAR2,
         p_ref4                         IN  VARCHAR2,
         p_ref5                         IN  VARCHAR2,
         p_dtl_msg                      IN  VARCHAR2,
         p_internal_control_number      IN  VARCHAR2 )

   IS
         l_cln_ch_parameters            wf_parameter_list_t;
         l_event_key                    NUMBER;
         l_error_code                   NUMBER;
         l_error_msg                    VARCHAR2(255);
         l_debug_mode                   VARCHAR2(255);
         l_msg_data                     VARCHAR2(255);

   BEGIN
         -- Sets the debug mode to be FILE
         --l_debug_mode := cln_debug_pub.Set_Debug_Mode('FILE');
         IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('-------- ENTERING RAISE_ADD_MSG_EVENT ------------', 2);
         END IF;

         --  Initialize API return status to success
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         l_msg_data     := 'Add Messages successfully raised';

         FND_MESSAGE.SET_NAME('CLN','CLN_CH_EVENT_RAISED');
         FND_MESSAGE.SET_TOKEN('EVENT','Add Messages');
         x_msg_data := FND_MESSAGE.GET;


         SELECT  cln_generic_s.nextval INTO l_event_key FROM dual;

         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('----------- PARAMETERS OBTAINED ----------',1);
                 cln_debug_pub.Add('Collaboration ID            ---- '||p_coll_id, 1);
                 cln_debug_pub.Add('Reference 1                 ---- '||p_ref1,1);
                 cln_debug_pub.Add('Reference 2                 ---- '||p_ref2,1);
                 cln_debug_pub.Add('Reference 3                 ---- '||p_ref3,1);
                 cln_debug_pub.Add('Reference 4                 ---- '||p_ref4,1);
                 cln_debug_pub.Add('Reference 5                 ---- '||p_ref5,1);
                 cln_debug_pub.Add('Detail Message              ---- '||p_dtl_msg,1);
                 cln_debug_pub.Add('Internal Control Number     ---- '||p_internal_control_number, 1);
                 cln_debug_pub.Add('------------------------------------------',1);
         END IF;


         l_cln_ch_parameters := wf_parameter_list_t();
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('---------- SETTING WORKFLOW PARAMETERS---------', 1);
         END IF;
         WF_EVENT.AddParameterToList('REFERENCE_ID1',p_ref1,l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('REFERENCE_ID2',p_ref2,l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('REFERENCE_ID3',p_ref3,l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('REFERENCE_ID4',p_ref4,l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('REFERENCE_ID5',p_ref5,l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('DETAIL_MESSAGE',p_dtl_msg,l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('COLLABORATION_ID', p_coll_id, l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('DOCUMENT_TYPE', 'ACKNOWLEDGE_PO', l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('DOCUMENT_DIRECTION', 'IN', l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('COLLABORATION_POINT', 'APPS', l_cln_ch_parameters);
         WF_EVENT.AddParameterToList('XMLG_INTERNAL_CONTROL_NUMBER',p_internal_control_number,l_cln_ch_parameters);
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('----------------------------------------------', 1);
                 cln_debug_pub.Add('Workflow event- oracle.apps.cln.ch.collaboration.addmessage', 1);
         END IF;

         WF_EVENT.Raise('oracle.apps.cln.ch.collaboration.addmessage',l_event_key, NULL, l_cln_ch_parameters, NULL);
         IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('--------- EXITING RAISE_ADD_MSG_EVENT -------------', 2);
         END IF;


   EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
            x_return_status :=FND_API.G_RET_STS_ERROR ;
            IF (l_Debug_Level <= 5) THEN
                    cln_debug_pub.Add('Error:' || x_msg_data, 4);
                    cln_debug_pub.Add('--------- ERROR :EXITING RAISE_ADD_MSG_EVENT -------------', 2);
            END IF;

         WHEN OTHERS THEN
            l_error_code        := SQLCODE;
            l_error_msg         := SQLERRM;
            x_return_status     :=FND_API.G_RET_STS_ERROR ;
            FND_MESSAGE.SET_NAME('CLN','CLN_CH_UNEXPECTED_ERROR');
            FND_MESSAGE.SET_TOKEN('ERRORCODE',l_error_code);
            FND_MESSAGE.SET_TOKEN('ERRORMSG',l_error_msg);
            x_msg_data          :=FND_MESSAGE.GET;
            IF (l_Debug_Level <= 2) THEN
                    cln_debug_pub.Add('Error:' || l_error_code || ':' || l_error_msg, 4);
                    cln_debug_pub.Add('--------- ERROR :EXITING RAISE_ADD_MSG_EVENT -------------', 2);
            END IF;

   END RAISE_ADD_MSG_EVENT;




  -- Name
  --   PROCESS_HEADER
  -- Purpose
  --    The main purpose of this procedure is to check whether the collaboration exists for
  --    for a particular reference id or not
  --
  -- Arguments
  --
  -- Notes
  --   No specific notes


 PROCEDURE PROCESS_HEADER(
        x_return_status             OUT NOCOPY VARCHAR2,
        x_msg_data                  OUT NOCOPY VARCHAR2,
        p_ref_id                    IN  VARCHAR2,
        p_sender_component          IN  VARCHAR2,
        p_po_number                 IN  VARCHAR2,
        p_release_number            IN  NUMBER,
        p_revision_number           IN  NUMBER,
        p_ackcode_header            IN  NUMBER,
        p_note                      IN  LONG,
        p_requestor                 IN  VARCHAR2,
        p_int_cont_num              IN  VARCHAR2,
        p_request_origin            IN  VARCHAR2,
        p_tp_header_id              IN  NUMBER,
        p_tp_id                     OUT NOCOPY VARCHAR2,
        p_tp_site_id                OUT NOCOPY VARCHAR2,
        x_cln_required              OUT NOCOPY VARCHAR2,
        x_collaboration_type        OUT NOCOPY VARCHAR2,
        x_coll_id                   OUT NOCOPY NUMBER,
        x_notification_code         OUT NOCOPY VARCHAR2,
        x_notification_status       OUT NOCOPY VARCHAR2,
        x_return_status_tp          OUT NOCOPY VARCHAR2,
        x_call_po_apis              OUT NOCOPY VARCHAR2 )

 IS
        l_error_code                NUMBER;
        l_txn_id                    NUMBER;
        l_error_msg                 VARCHAR2(255);
        l_msg_data                  VARCHAR2(255);
        l_debug_mode                VARCHAR2(255);
        l_update_reqd               BOOLEAN;
        l_action                    VARCHAR2(255);
        l_po_type                   VARCHAR2(50);
        l_request_type              VARCHAR2(50);
        l_error_id                  NUMBER;
        l_error_status              VARCHAR2(1000);
        l_tp_id                     NUMBER;
        l_tp_site_id                NUMBER;
        l_call_po_apis              VARCHAR2(10);
        l_po_ackcode                NUMBER;

 BEGIN

        -- Sets the debug mode to be FILE
        --l_debug_mode :=cln_debug_pub.Set_Debug_Mode('FILE');

        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('############################################################',1);
                cln_debug_pub.Add('###############   START OF XGM DEBUG FILE  #################',1);
                cln_debug_pub.Add('############################################################',1);
        END IF;

        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('---- Entering PROCESS_HEADER API ----- ', 2);
        END IF;

        -- Standard Start of API savepoint
        SAVEPOINT   CHECK_COLLABORATION_PUB;

        -- Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        l_msg_data      := 'ACKPO Header successfully consumed';
        l_call_po_apis  := 'YES';
        x_cln_required  := 'TRUE';


        -- Parameters received
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('----- PARAMETERS RECEIVED ------- ',1);
                cln_debug_pub.Add('Status received          - '||x_return_status,1);
                cln_debug_pub.Add('Message received         - '||x_msg_data,1);
                cln_debug_pub.Add('Reference ID             - '||p_ref_id,1);
                cln_debug_pub.Add('Sender Component         - '||p_sender_component,1);
                cln_debug_pub.Add('PO Number                - '||p_po_number,1);
                cln_debug_pub.Add('Release Number           - '||p_release_number,1);
                cln_debug_pub.Add('Revision Number          - '||p_revision_number,1);
                cln_debug_pub.Add('Ackcode at header level  - '||p_ackcode_header,1);
                cln_debug_pub.Add('Note                     - '||p_note,1);
                cln_debug_pub.Add('CLN reqd                 - '||x_cln_required,1);
                cln_debug_pub.Add('p_tp_header_id           - '|| p_tp_header_id, 1);
                cln_debug_pub.Add('Requestor                - '||p_requestor,1);
                cln_debug_pub.Add('Internal Ctrl Number     - '||p_int_cont_num,1);
                cln_debug_pub.Add('Request Origin           - '||p_request_origin,1);
                cln_debug_pub.Add('----------------------------------',1);
        END IF;

        l_line_num_tab.delete;-- Initialize array of PO lines


        -- Check whether collaboration can be created/upadted based on Profile, Protocol value
        CLN_CH_COLLABORATION_PKG.IS_UPDATE_REQUIRED(
            x_return_status             =>        x_return_status,
            x_msg_data                  =>        x_msg_data,
            p_doc_dir                   =>        'IN',
            p_xmlg_transaction_type     =>        null,
            p_xmlg_transaction_subtype  =>        null,
            p_tr_partner_type           =>        null,
            p_tr_partner_id             =>        null,
            p_tr_partner_site           =>        null,
            p_sender_component          =>        p_sender_component,
            x_update_reqd               =>        l_update_reqd);

        IF (x_return_status <> 'S') THEN
             FND_MESSAGE.SET_NAME('CLN','CLN_CH_REQD_CRITERIA_FAIL');
             x_msg_data         := FND_MESSAGE.GET;
             l_msg_data         :='Failed to verify the required criteria for updating/creating.collaboration';
             x_coll_id          :=null;
             x_cln_required     :='FALSE';
             RAISE FND_API.G_EXC_ERROR;
        ELSE
             IF (l_update_reqd <> TRUE) THEN
                x_cln_required  := 'FALSE';
                x_coll_id       :=  null;
             END IF;
        END IF;

        IF (x_cln_required <>'TRUE')THEN
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('CLN history need not be updated',1);
                        cln_debug_pub.Add('Defaulting Collaboration Type to ACKNOWLEDGE_PO',1);
                END IF;
                x_collaboration_type    :=      'ACKNOWLEDGE_PO';
        END IF;
        -- Getting Collaboration ID for the Application Refernce ID
        IF (x_cln_required = 'TRUE')THEN
                IF p_ref_id IS NULL THEN
                     IF (l_Debug_Level <= 1) THEN
                             cln_debug_pub.Add('Application Reference ID is null',1);
                     END IF;
                     FND_MESSAGE.SET_NAME('CLN','CLN_CH_PARAM_NULL');
                     FND_MESSAGE.SET_TOKEN('PARAM','Application reference ID');
                     x_coll_id       :=  null;
                     x_msg_data      := FND_MESSAGE.GET;
                     l_msg_data      :='Application reference ID is null';
                     RAISE FND_API.G_EXC_ERROR;
                END IF;

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Application Reference ID is not null',1);
                END IF;

                BEGIN
                     SELECT COLLABORATION_ID,COLLABORATION_TYPE
                     INTO x_coll_id,x_collaboration_type
                     FROM CLN_COLL_HIST_HDR
                     WHERE APPLICATION_REFERENCE_ID     =      p_ref_id;
                EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                         FND_MESSAGE.SET_NAME('CLN','CLN_CH_REFID_NOT_FOUND');
                         FND_MESSAGE.SET_TOKEN('PARAM','Application reference ID');
                         FND_MESSAGE.SET_TOKEN('REFID',p_ref_id);
                         x_msg_data   := FND_MESSAGE.GET;
                         x_coll_id       :=  null;
                         l_msg_data   :='Collaboration Not Found For Application reference ID :'||p_ref_id;
                      RAISE FND_API.G_EXC_ERROR;
                END;
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Collaboration ID retrieved as   : '||x_coll_id,1);
                        cln_debug_pub.Add('Collaboration Type retrieved as : '||x_collaboration_type,1);
                END IF;
        END IF;


        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Getting Trading partner details using TP_HEADER_ID',1);
        END IF;

        BEGIN
             SELECT  PARTY_ID, PARTY_SITE_ID
             INTO    l_tp_id, l_tp_site_id
             FROM    ECX_TP_HEADERS
             WHERE   TP_HEADER_ID = p_tp_header_id;
        EXCEPTION
             WHEN NO_DATA_FOUND THEN
                 IF (l_Debug_Level <= 2) THEN
                         cln_debug_pub.Add('TP details not found for the TP Header ID = '||p_tp_header_id,2);
                 END IF;
        END;

        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('Trading Partner ID       - '||l_tp_id,1);
                cln_debug_pub.Add('Trading Partner Site ID  - '||l_tp_site_id,1);
        END IF;

        p_tp_id                 := l_tp_id;
        p_tp_site_id            := l_tp_site_id;

        IF (x_collaboration_type = 'CANCEL_ORDER' OR x_collaboration_type = 'SUPP_CHANGE_ORDER') THEN
                l_call_po_apis  := 'NO';
                IF (l_Debug_Level <= 2) THEN
                        cln_debug_pub.Add('PO APIs should not be called....',1);
                END IF;
        END IF;


        IF (l_call_po_apis = 'YES') THEN
                IF (l_Debug_Level <= 2) THEN
                        cln_debug_pub.Add('--- Calling PO_CHG_REQUEST_GRP.initialize_chn_ack_inbound ----- ',1);
                END IF;
                PO_CHG_REQUEST_GRP.initialize_chn_ack_inbound (
                        p_requestor             => p_requestor,
                        p_int_cont_num          => p_int_cont_num,
                        p_request_origin        => p_request_origin,
                        p_tp_id                 => l_tp_id,
                        p_tp_site_id            => l_tp_site_id,
                        x_error_id              => l_error_id,
                        x_error_status          => l_error_status);

                IF (l_Debug_Level <= 2) THEN
                        cln_debug_pub.Add('ERROR ID             : ' || l_error_id,1);
                        cln_debug_pub.Add('ERROR STATUS         : ' || l_error_status,1);
                END IF;

                -- If initialize_chn_ack_inbound errored out
                IF l_error_id IS NOT NULL AND l_error_id <> 0 THEN
                     x_msg_data  :=   l_error_status;
                     l_msg_data  :=   l_error_status;
                     RAISE FND_API.G_EXC_ERROR;
                END IF;
                IF (l_Debug_Level <= 2) THEN
                        cln_debug_pub.Add('PO_CHG_REQUEST_GRP.initialize_chn_ack_inbound returned Success',1);
                END IF;
         END IF;

        l_action := x_collaboration_type;

        IF (x_collaboration_type <>  'ACKNOWLEDGE_PO') THEN
                BEGIN
                        IF((p_ackcode_header = 1) and (x_collaboration_type <> 'ORDER')) OR (p_ackcode_header not in (0,1,2,3)) THEN
                            FND_MESSAGE.SET_NAME('CLN','CLN_CH_ACKPO_INVALID_TAG_VALUE');
                            FND_MESSAGE.SET_TOKEN('TAG','ACKHEADER/ACKCODE');
                            x_msg_data  :=FND_MESSAGE.GET;
                            l_msg_data  :='Invalid value for ACKHEADER/ACKCODE tag.';
                            RAISE FND_API.G_EXC_ERROR;
                        END IF;

                        SELECT meaning INTO l_action FROM fnd_lookups
                        WHERE lookup_code = x_collaboration_type AND lookup_type = 'CLN_COLLABORATION_TYPE';
                        cln_debug_pub.Add('Collaboration Type found as  - '||l_action,1);

                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                             l_msg_data := 'Collaboration Type not found for the lookup_code as ORDER and lookup_type as CLN_COLLABORATION_TYPE ';
                             FND_MESSAGE.SET_NAME('CLN','CLN_CH_COLLABORATION_TYPE_NOT');
                             FND_MESSAGE.SET_TOKEN('TYPE','CLN_COLLABORATION_TYPE');
                             FND_MESSAGE.SET_TOKEN('CODE',l_action);
                             x_msg_data := FND_MESSAGE.GET;
                             RAISE FND_API.G_EXC_ERROR;
                END;
        ELSE
                l_action := 'Acknowledge PO';
        END IF;

        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('Action is set as                : '||l_action,1);
                cln_debug_pub.Add('Return status is                : '||x_return_status,1);
        END IF;

        -- get the sequence number for Transaction id.
        select  cln_generic_s.NEXTVAL INTO l_txn_id FROM DUAL;
        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('Transaction ID                  :' || l_txn_id, 1);
        END IF;

        -- Find the Request Type
        IF p_ackcode_header = 1 THEN
             l_request_type := 'CHANGE';
        ELSE
             l_request_type := 'ACKNOWLEDGE';
        END IF;
        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('PO Request Type is              : ' || l_request_type,1);
        END IF;

        -- Identify PO Type based on release number
        l_po_type := 'STANDARD';

        IF (p_release_number IS NOT NULL AND p_release_number > 0) THEN
             l_po_type := 'RELEASE';
        END IF;
        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('PO Type is                      : ' || l_po_type,1);
                cln_debug_pub.Add('--- Calling PO_CHG_REQUEST_GRP.validate_header ----- ',1);
        END IF;


        IF (l_call_po_apis = 'YES') THEN
            -- should not be called for 3A9 and 3A7 Response
            PO_CHG_REQUEST_GRP.validate_header (
               p_requestor               => p_requestor,
               p_int_cont_num            => p_int_cont_num,
               p_request_origin          => p_request_origin,
               p_request_type            => l_request_type,
               p_tp_id                   => l_tp_id,
               p_tp_site_id              => l_tp_site_id,
               p_po_number               => p_po_number,
               p_release_number          => p_release_number,
               p_po_type                 => l_po_type,
               -- Should not pass revision number
               p_revision_num            => NULL,
               x_error_id_in             => l_error_id,
               x_error_status_in         => l_error_status,
               x_error_id_out            => l_error_id,
               x_error_status_out        => l_error_status);

            IF (l_Debug_Level <= 2) THEN
                    cln_debug_pub.Add('ERROR ID             : ' || l_error_id,1);
                    cln_debug_pub.Add('ERROR STATUS         : ' || l_error_status,1);
            END IF;

            -- If validate header errored out
            IF l_error_id IS NOT NULL AND l_error_id <> 0 THEN
                x_msg_data  :=   l_error_status;
                l_msg_data  :=   l_error_status;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
            IF (l_Debug_Level <= 2) THEN
                    cln_debug_pub.Add('PO_CHG_REQUEST_GRP.validate_header returned Success',1);
            END IF;
        END IF;

        IF (l_call_po_apis = 'YES') THEN  -- should not be called for 3A9 and 3A8 Response
            IF (l_request_type = 'ACKNOWLEDGE') THEN
                    IF (l_Debug_Level <= 2) THEN
                            cln_debug_pub.Add('--- Calling PO_CHG_REQUEST_GRP.acknowledge_po ----- ',1);
                    END IF;
                    IF p_ackcode_header = 3 THEN    --If pending treat it as accept
                       l_po_ackcode := 0;
                    ELSE
                       l_po_ackcode := p_ackcode_header;
                    END IF;
                    PO_CHG_REQUEST_GRP.acknowledge_po(
                         p_requestor            => p_requestor,     -- Change requester or the acknowledging username
                         p_int_cont_num         => p_int_cont_num,  -- ECX's ICN. Used for integrity of request
                         p_request_type         => 'ACKNOWLEDGE',  -- ??'ACKNOWLEDGE'
                         p_tp_id                => l_tp_id,         -- vendor_id
                         p_tp_site_id           => l_tp_site_id,    -- vendor_site_id
                         p_po_number            => p_po_number,     -- PO # of the PO being modified or the Blanket's PO #
                         p_release_number       => p_release_number,-- Release number if the PO Type is release or null
                         p_po_type              => l_po_type,       -- PO Type??  -- RELEASE for release, STANDARD for others.
                         p_revision_num         => NULL,            -- Revision number of the PO or the release
                         p_ack_code             => l_po_ackcode,    -- 0 for accept/peding and 2 reject
                         p_ack_reason           => p_note,          --  comments
                         x_error_id             => l_error_id,      -- The error id will be 2, errors will go to the TP sysadmin
                         x_error_status         => l_error_status   -- Error message
                     );

                     IF (l_Debug_Level <= 2) THEN
                             cln_debug_pub.Add('ERROR ID             : ' || l_error_id,1);
                             cln_debug_pub.Add('ERROR STATUS         : ' || l_error_status,1);
                     END IF;

                     IF l_error_id IS NOT NULL AND l_error_id <> 0 THEN
                         x_msg_data  :=   l_error_status;
                         l_msg_data  :=   l_error_status;
                         RAISE FND_API.G_EXC_ERROR;
                     END IF;

                END IF;
        END IF;

        IF (p_ackcode_header = 0) or (p_ackcode_header = 3) THEN -- Pending is treated as accepted
                x_notification_code   := 'ACKPO_01';
        ELSIF (p_ackcode_header = 1) THEN
                x_notification_code   := 'ACKPO_03';
        ELSIF (p_ackcode_header = 2) THEN
                x_notification_code   := 'ACKPO_02';
        END IF;

        x_notification_status := 'SUCCESS';
        x_return_status_tp    := '00';
        x_call_po_apis        :=  l_call_po_apis;

        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('Notification Code set as     :'||x_notification_code,1);
                cln_debug_pub.Add('Notification Status set as   :'||x_notification_status,1);
                cln_debug_pub.Add('Return Status set as         :'||x_notification_code,1);
        END IF;

        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('---- Exiting PROCESS_HEADER API ----- ', 2);
        END IF;

 -- Exception Handling
 EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
             x_return_status    := FND_API.G_RET_STS_ERROR ;
             FND_MESSAGE.SET_NAME('CLN','CLN_CH_ACKPO_ERROR');
             FND_MESSAGE.SET_TOKEN('PONUM',p_po_number);
             FND_MESSAGE.SET_TOKEN('RELNUM',p_release_number);
             FND_MESSAGE.SET_TOKEN('REVNUM',p_revision_number);
             FND_MESSAGE.SET_TOKEN('MSG',x_msg_data);
             x_msg_data         := FND_MESSAGE.GET;
             x_call_po_apis     := 'NO';

             IF (l_Debug_Level <= 5) THEN
                     cln_debug_pub.Add(l_msg_data,4);
                     cln_debug_pub.Add('---- ERROR :Exiting PROCESS_HEADER  API ----- ', 2);
             END IF;


        WHEN OTHERS THEN
             l_error_code       :=SQLCODE;
             l_error_msg        :=SQLERRM;
             x_return_status    :=FND_API.G_RET_STS_UNEXP_ERROR ;
             FND_MESSAGE.SET_NAME('CLN','CLN_CH_UNEXPECTED_ERROR');
             FND_MESSAGE.SET_TOKEN('ERRORCODE',l_error_code);
             FND_MESSAGE.SET_TOKEN('ERRORMSG',l_error_msg);
             x_msg_data         :=FND_MESSAGE.GET;
             x_call_po_apis     := 'NO';

             FND_MESSAGE.SET_NAME('CLN','CLN_CH_ACKPO_ERROR');
             FND_MESSAGE.SET_TOKEN('PONUM',p_po_number);
             FND_MESSAGE.SET_TOKEN('RELNUM',p_release_number);
             FND_MESSAGE.SET_TOKEN('REVNUM',p_revision_number);
             FND_MESSAGE.SET_TOKEN('MSG',x_msg_data);
             x_msg_data         := FND_MESSAGE.GET;
             l_msg_data         :='Unexpected Error -'||l_error_code||' : '||l_error_msg;
             IF (l_Debug_Level <= 5) THEN
                     cln_debug_pub.Add(l_msg_data,6);
                     cln_debug_pub.Add('---- ERROR :Exiting PROCESS_HEADER API ----- ', 2);
             END IF;

 END PROCESS_HEADER;




    -- Name
    --   PROCESS_HEADER_LINES
    -- Purpose
    --   The main purpose of this procedure is to provide a sequence of actions that
    --   need to be taken to consume the Acknowledgement depending upon the ACKCODE
    --   value at the header level and on the Collaboration Type.
    -- Arguments
    --
    -- Notes
    --   No specific notes.

  PROCEDURE PROCESS_HEADER_LINES(
         x_return_status             IN OUT NOCOPY VARCHAR2,
         x_msg_data                  IN OUT NOCOPY VARCHAR2,
         p_requestor                 IN VARCHAR2,
         p_po_number                 IN VARCHAR2,
         p_release_number            IN NUMBER,
         p_revision_number           IN NUMBER,
         p_line_number               IN NUMBER,
         p_previous_line_number      IN OUT NOCOPY NUMBER,
         p_shipment_number           IN NUMBER,
         p_new_quantity              IN NUMBER,
         p_po_quantity_uom           IN VARCHAR2,
         p_po_price_currency         IN VARCHAR2,
         p_po_price_uom              IN VARCHAR2,
         p_new_price                 IN NUMBER,
         p_ackcode_header            IN NUMBER,
         p_ackcode_line              IN NUMBER,
         p_coll_id                   IN NUMBER,
         p_new_promised_date         IN DATE,
         p_collaboration_type        IN VARCHAR2,
         p_org_ref                   IN VARCHAR2,
         p_cln_required              IN VARCHAR2,
         p_internal_control_number   IN VARCHAR2,
         p_supplier_part_number      IN VARCHAR2,
         p_so_num                    IN VARCHAR2,
         p_so_line_num               IN NUMBER,
         p_so_line_status            IN VARCHAR2,
         p_reason                    IN VARCHAR2,
         p_tp_id                     IN VARCHAR2,
         p_tp_site_id                IN VARCHAR2,
         p_msg_dtl_screen            IN OUT NOCOPY VARCHAR2,
         p_msg_txt_lines             IN OUT NOCOPY VARCHAR2,
         p_if_collaboration_updated  IN OUT NOCOPY VARCHAR2,
         -- Additional parameters added for new Change_PO API to
         -- support split lines and cancellation at header and schedule level.
         p_supp_doc_ref              IN VARCHAR2 DEFAULT NULL,
         p_supp_line_ref             IN VARCHAR2 DEFAULT NULL,
         p_supplier_shipment_ref     IN VARCHAR2 DEFAULT NULL,
         p_parent_shipment_number    IN VARCHAR2 DEFAULT NULL)
  IS
         l_error_code                NUMBER;
         l_error_msg                 VARCHAR2(255);
         l_msg_data                  VARCHAR2(255);
         l_debug_mode                VARCHAR2(255);
         l_return_code               NUMBER;
         l_return_status             VARCHAR2(255);
         l_msg_txt_lines             VARCHAR2(2000);
         l_disposition               VARCHAR2(255);
         l_return_status_tp          VARCHAR2(255);
         l_dtl_status                VARCHAR2(255);
         l_txn_id                    NUMBER;
         l_po_type                   VARCHAR2(50);
         l_error_id                  NUMBER;
         l_error_status              VARCHAR2(1000);


  BEGIN

         -- Sets the debug mode to be FILE
         --l_debug_mode           := cln_debug_pub.Set_Debug_Mode('FILE');

         IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('----- Entering PROCESS_HEADER_LINES API ------- ',2);
         END IF;

         l_msg_txt_lines        := p_msg_txt_lines;

         IF(p_ackcode_header = 0) THEN
            l_disposition            := 'ACCEPTED';
         ELSIF (p_ackcode_header = 1) THEN
            l_disposition            := 'ACCEPTED';
         ELSIF(p_ackcode_header = 2) THEN
            l_disposition            := 'REJECTED';
         ELSIF (p_ackcode_header = 3) THEN
            l_disposition            := 'PENDING';
         END IF;

         l_msg_data     := 'ACKPO successfully consumed for PO : '||p_po_number||' with Line : '||p_line_number;

         -- Parameters received
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('----- PARAMETERS RECEIVED ------- ',1);
                 cln_debug_pub.Add('Status received          - '||x_return_status,1);
                 cln_debug_pub.Add('Message received         - '||x_msg_data,1);
                 cln_debug_pub.Add('PO Number                - '||p_po_number,1);
                 cln_debug_pub.Add('Release Number           - '||p_release_number,1);
                 cln_debug_pub.Add('Revision Number          - '||p_revision_number,1);
                 cln_debug_pub.Add('Previous Line  Number    - '||p_previous_line_number,1);
                 cln_debug_pub.Add('Line  Number             - '||p_line_number,1);
                 cln_debug_pub.Add('Shipment Number          - '||p_shipment_number,1);
                 cln_debug_pub.Add('New Quantity             - '||p_new_quantity,1);
                 cln_debug_pub.Add('New Price                - '||p_new_price,1);
                 cln_debug_pub.Add('Promised Date            - '||p_new_promised_date,1);
                 cln_debug_pub.Add('Ackcode at header level  - '||p_ackcode_header,1);
                 cln_debug_pub.Add('Ackcode at line level    - '||p_ackcode_line,1);
                 cln_debug_pub.Add('Collaboration Type       - '||p_collaboration_type,1);
                 cln_debug_pub.Add('Originator Reference     - '||p_org_ref,1);
                 cln_debug_pub.Add('Collaboration ID         - '||p_coll_id,1);
                 cln_debug_pub.Add('Detail Header Message    - '||p_msg_dtl_screen,1);
                 cln_debug_pub.Add('Detail Line Message      - '||p_msg_txt_lines,1);
                 cln_debug_pub.Add('Internal Control Number  - '||p_internal_control_number,1);
                 cln_debug_pub.Add('Collaboration Updated    - '||p_if_collaboration_updated,1);
                 cln_debug_pub.Add('Disposition              - '||l_disposition,1);
                 cln_debug_pub.Add('CLN reqd                 - '||p_cln_required,1);
                 cln_debug_pub.Add('CLN reqd                 - '||p_cln_required,1);
                 cln_debug_pub.Add('CLN reqd                 - '||p_cln_required,1);
                 cln_debug_pub.Add('CLN reqd                 - '||p_cln_required,1);
                 cln_debug_pub.Add('CLN reqd                 - '||p_cln_required,1);
                 cln_debug_pub.Add('----------------------------------',1);
         END IF;

         -- get the sequence number for Transaction id.
         select  cln_generic_s.NEXTVAL INTO l_txn_id FROM DUAL;
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Transaction ID:' || l_txn_id, 1);
         END IF;

         -- Identify PO Type based on release number

         l_po_type := 'STANDARD';

         IF (p_release_number IS NOT NULL AND p_release_number > 0) THEN
             l_po_type := 'RELEASE';
         END IF;
         cln_debug_pub.Add('PO Type is           : ' || l_po_type,1);


         IF((p_ackcode_header = 1 and p_ackcode_line = 1) AND ((p_collaboration_type = 'ORDER') or (p_collaboration_type = 'ACKNOWLEDGE_PO'))) THEN
                IF l_po_type = 'RELEASE' THEN
                    IF (l_Debug_Level <= 1) THEN
                            cln_debug_pub.Add('Calling PO_CHG_REQUEST_GRP.store_supplier_request API For PO Release',1);
                    END IF;
                    PO_CHG_REQUEST_GRP.store_supplier_request (
                          p_requestor         => p_requestor,
                          p_int_cont_num      => p_internal_control_number,
                          p_request_type      => 'CHANGE',
                          p_tp_id             => p_tp_id,
                          p_tp_site_id        => p_tp_site_id,
                          p_level             => 'SHIPMENT',
                          p_po_number         => p_po_number,
                          p_release_number    => p_release_number,
                          p_po_type           => 'RELEASE',
                          -- Should not pass revision nmumber, it keeps changing
                          p_revision_num      => NULL,
                          p_line_num          => p_line_number,
                          p_reason            => p_reason,
                          p_shipment_num      => p_shipment_number,
                          p_quantity          => p_new_quantity,
                          p_quantity_uom      => p_po_quantity_uom,
                          p_price             => p_new_price,
                          p_price_currency    => p_po_price_currency,
                          p_price_uom         => p_po_price_uom,
                          p_promised_date     => p_new_promised_date,
                          p_supplier_part_num => p_supplier_part_number,
                          p_so_number         => p_so_num,
                          p_so_line_number    => p_so_line_num,
                          p_ack_type          => 'MODIFICATION',
                          x_error_id_in       => l_error_id,
                          x_error_status_in   => l_error_status,
                          x_error_id_out      => l_error_id,
                          x_error_status_out  => l_error_status/*,
                          -- Supplier Line Reference added for new Change_PO API to
                          -- support split lines and cancellation at header and schedule level.
                          p_parent_shipment_number  => p_parent_shipment_number,
                          p_supplier_doc_ref  => p_supp_doc_ref,
                          p_supplier_line_ref => p_supp_line_ref,
                          p_supplier_shipment_ref => p_supplier_shipment_ref*/);



                      IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add('ERROR ID             : ' || l_error_id,1);
                      END IF;
                      IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add('ERROR STATUS         : ' || l_error_status,1);
                      END IF;

                      IF l_error_id IS NOT NULL AND l_error_id <> 0 THEN
                         x_msg_data  :=   l_error_status;
                         l_msg_data  :=   l_error_status;
                         RAISE FND_API.G_EXC_ERROR;
                      END IF;

                ELSE

                    IF (l_Debug_Level <= 1) THEN
                            cln_debug_pub.Add('Previous and new line number are not same..',1);
                    END IF;
                    IF (p_previous_line_number <> p_line_number) THEN
                        IF (l_Debug_Level <= 1) THEN
                                cln_debug_pub.Add('Calling PO_CHG_REQUEST_GRP.store_supplier_request API For Standard PO',1);
                                cln_debug_pub.Add('Call is at Line Level......',1);
                        END IF;
                        p_previous_line_number          :=  p_line_number;

                        IF IS_ALREADY_PROCESSED_LINE(p_line_number) THEN
                              -- Nothing to do since the changes happens only once per each po line
                              -- Collaboration history too is not updated
                              IF (l_Debug_Level <= 1) THEN
                                      cln_debug_pub.Add('Since this an already processed line, Nothing to do', 1);
                              END IF;
                              RETURN;
                        END IF;

                        IF l_error_id IS NULL OR l_error_id = 0 THEN
                           PO_CHG_REQUEST_GRP.store_supplier_request (
                                  p_requestor         => p_requestor,
                                  p_int_cont_num      => p_internal_control_number,
                                  p_request_type      => 'CHANGE',
                                  p_tp_id             => p_tp_id,
                                  p_tp_site_id        => p_tp_site_id,
                                  p_level             => 'LINE',
                                  p_po_number         => p_po_number,
                                  p_release_number    => p_release_number,
                                  p_po_type           => 'STANDARD',
                                  p_revision_num      => NULL,
                                  p_line_num          => p_line_number,
                                  p_reason            => p_reason,
                                  p_shipment_num      => p_shipment_number,
                                  p_quantity          => NULL,
                                  p_quantity_uom      => NULL,
                                  p_price             => p_new_price,
                                  p_price_currency    => p_po_price_currency,
                                  p_price_uom         => p_po_price_uom,
                                  p_promised_date     => NULL,
                                  p_supplier_part_num => p_supplier_part_number,
                                  p_so_number         => p_so_num,
                                  p_so_line_number    => p_so_line_num,
                                  p_ack_type          => 'MODIFICATION',
                                  x_error_id_in       => l_error_id,
                                  x_error_status_in   => l_error_status,
                                  x_error_id_out      => l_error_id,
                                  x_error_status_out  => l_error_status/*,
                                  -- Supplier Line Reference added for new Change_PO API to
                                  -- support split lines and cancellation at header and schedule level.
                                  p_parent_shipment_number  => p_parent_shipment_number,
                                  p_supplier_doc_ref  => p_supp_doc_ref,
                                  p_supplier_line_ref => p_supp_line_ref,
                                  p_supplier_shipment_ref => p_supplier_shipment_ref*/);


                            IF (l_Debug_Level <= 1) THEN
                                    cln_debug_pub.Add('ERROR ID             : ' || l_error_id,1);
                                    cln_debug_pub.Add('ERROR STATUS         : ' || l_error_status,1);
                            END IF;
                         END IF;
                     END IF;

                    IF (l_Debug_Level <= 1) THEN
                            cln_debug_pub.Add('Calling PO_CHG_REQUEST_GRP.store_supplier_request API For Standard PO',1);
                            cln_debug_pub.Add('Call is at Shipment Line Level......',1);
                    END IF;
                    PO_CHG_REQUEST_GRP.store_supplier_request (
                          p_requestor         => p_requestor,
                          p_int_cont_num      => p_internal_control_number,
                          p_request_type      => 'CHANGE',
                          p_tp_id             => p_tp_id,
                          p_tp_site_id        => p_tp_site_id,
                          p_level             => 'SHIPMENT',
                          p_po_number         => p_po_number,
                          p_release_number    => p_release_number,
                          p_po_type           => 'STANDARD',
                          p_revision_num      => NULL,
                          p_line_num          => p_line_number,
                          p_reason            => p_reason,
                          p_shipment_num      => p_shipment_number,
                          p_quantity          => p_new_quantity,
                          p_quantity_uom      => p_po_quantity_uom,
                          p_price             => NULL,
                          p_price_currency    => NULL,
                          p_price_uom         => NULL,
                          p_promised_date     => p_new_promised_date,
                          p_supplier_part_num => p_supplier_part_number,
                          p_so_number         => p_so_num,
                          p_so_line_number    => p_so_line_num,
                          p_ack_type          => 'MODIFICATION',
                          x_error_id_in       => l_error_id,
                          x_error_status_in   => l_error_status,
                          x_error_id_out      => l_error_id,
                          x_error_status_out  => l_error_status/*,
                          -- Supplier Line Reference added for new Change_PO API to
                          -- support split lines and cancellation at header and schedule level.
                          p_parent_shipment_number  => p_parent_shipment_number,
                          p_supplier_doc_ref  => p_supp_doc_ref,
                          p_supplier_line_ref => p_supp_line_ref,
                          p_supplier_shipment_ref => p_supplier_shipment_ref*/);


                    IF (l_Debug_Level <= 1) THEN
                            cln_debug_pub.Add('ERROR ID             : ' || l_error_id,1);
                            cln_debug_pub.Add('ERROR STATUS         : ' || l_error_status,1);
                    END IF;

                    IF l_error_id IS NOT NULL AND l_error_id <> 0 THEN
                         x_msg_data  :=   l_error_status;
                         l_msg_data  :=   l_error_status;
                         RAISE FND_API.G_EXC_ERROR;
                    END IF;

                END IF;

                IF l_error_id IS NOT NULL AND l_error_id <> 0 THEN
                     x_msg_data  :=   l_error_status;
                     l_msg_data  :=   l_error_status;
                     RAISE FND_API.G_EXC_ERROR;
                END IF;

    /*
                IF l_error_id IS NULL OR l_error_id = 0 THEN
                    cln_debug_pub.Add('Calling PO_CHG_REQUEST_GRP.process_supplier_request API',1);

                    PO_CHG_REQUEST_GRP.process_supplier_request (
                       p_int_cont_num      => p_internal_control_number,
                       x_error_id_in       => l_error_id,
                       x_error_status_in   => l_error_status,
                       x_error_id_out      => l_error_id,
                       x_error_status_out  => l_error_status
                    );

                    cln_debug_pub.Add('ERROR ID             : ' || l_error_id,1);
                    cln_debug_pub.Add('ERROR STATUS         : ' || l_error_status,1);
                END IF;
     */
         END IF;

         IF l_error_id IS NOT NULL AND l_error_id <> 0 THEN
               x_msg_data  :=   l_error_status;
               l_msg_data  :=   l_error_status;
               RAISE FND_API.G_EXC_ERROR;
         END IF;


        IF ((p_cln_required = 'TRUE') AND (p_if_collaboration_updated = 'FALSE'))THEN
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Call to Raise Update Event.....',1);
                END IF;
                RAISE_UPDATE_EVENT(
                      x_return_status                => x_return_status,
                      x_msg_data                     => x_msg_data,
                      p_coll_id                      => p_coll_id,
                      p_doc_status                   => 'SUCCESS',
                      p_org_ref                      => p_org_ref,
                      p_disposition                  => l_disposition,
                      p_msg_text                     => p_msg_dtl_screen,
                      p_internal_control_number      => p_internal_control_number );

                 IF(x_return_status <> 'S')THEN
                         p_if_collaboration_updated  := 'ERROR';
                         l_msg_data := 'Error in RAISE_UPDATE_EVENT API';
                         RAISE FND_API.G_EXC_ERROR;
                 END IF;
                 p_if_collaboration_updated      :=  'TRUE';
        END IF;

        IF(p_cln_required = 'TRUE') THEN
                 IF p_ackcode_line = 0 THEN
                        l_dtl_status          := 'Accepted';
                 ELSIF p_ackcode_line = 1 THEN
                        l_dtl_status          := 'Accepted With Changes';
                 ELSIF p_ackcode_line = 2 THEN
                        l_dtl_status          := 'Rejected';
                 ELSIF p_ackcode_line = 3 THEN
                        l_dtl_status          := 'Pending';
                 END IF;

                 IF (l_Debug_Level <= 1) THEN
                         cln_debug_pub.Add('Call to Raise Message Event.....',1);
                 END IF;
                 RAISE_ADD_MSG_EVENT(
                         x_return_status        => x_return_status,
                         x_msg_data             => x_msg_data,
                         p_coll_id              => p_coll_id,
                         p_ref1                 => l_dtl_status,
                         p_ref2                 => p_line_number,
                         p_ref3                 => p_shipment_number,
                         p_ref4                 => p_org_ref,
                         p_ref5                 => null,
                         p_dtl_msg              => l_msg_txt_lines,
                         p_internal_control_number      => p_internal_control_number );

                 IF(x_return_status <> 'S')THEN
                         p_if_collaboration_updated  := 'ERROR';
                         l_msg_data := 'Error in RAISE_ADD_MSG_EVENT API';
                         RAISE FND_API.G_EXC_ERROR;
                 END IF;

                 FND_MESSAGE.SET_NAME('CLN','CLN_CH_ACKPO_CONSUMED');
                 FND_MESSAGE.SET_TOKEN('PONUM',p_po_number);
                 x_msg_data           :=  FND_MESSAGE.GET;
        END IF;

        --p_msg_dtl_screen              :=  NULL;
        p_msg_txt_lines                 :=  NULL;
        x_return_status                 :=  FND_API.G_RET_STS_SUCCESS;

        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add(l_msg_data,1);
        END IF;
        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('------- Exiting PROCESS_HEADER_LINES API --------- ',2);
        END IF;

  -- Exception Handling
  EXCEPTION

         WHEN FND_API.G_EXC_ERROR THEN
              x_return_status           := FND_API.G_RET_STS_ERROR ;
              FND_MESSAGE.SET_NAME('CLN','CLN_CH_ACKPO_ERROR');
              FND_MESSAGE.SET_TOKEN('PONUM',p_po_number);
              FND_MESSAGE.SET_TOKEN('RELNUM',p_release_number);
              FND_MESSAGE.SET_TOKEN('REVNUM',p_revision_number);
              FND_MESSAGE.SET_TOKEN('MSG',x_msg_data);
              x_msg_data         := FND_MESSAGE.GET;
              IF (l_Debug_Level <= 5) THEN
                      cln_debug_pub.Add(l_msg_data,4);
                      cln_debug_pub.Add('------- ERROR :Exiting PROCESS_HEADER_LINES API --------- ',2);
              END IF;


         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              l_error_code              :=SQLCODE;
              l_error_msg               :=SQLERRM;
              x_return_status           :=FND_API.G_RET_STS_UNEXP_ERROR ;
              l_msg_data                :=l_error_code||' : '||l_error_msg;
              IF (l_Debug_Level <= 5) THEN
                      cln_debug_pub.Add(l_msg_data,6);
                      cln_debug_pub.Add('------- ERROR :Exiting PROCESS_HEADER_LINES API --------- ',2);
              END IF;

         WHEN OTHERS THEN
              l_error_code              :=SQLCODE;
              l_error_msg               :=SQLERRM;
              x_return_status           :=FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MESSAGE.SET_NAME('CLN','CLN_CH_UNEXPECTED_ERROR');
              FND_MESSAGE.SET_TOKEN('ERRORCODE',l_error_code);
              FND_MESSAGE.SET_TOKEN('ERRORMSG',l_error_msg);
              x_msg_data :=FND_MESSAGE.GET;
              l_msg_data         :='Unexpected Error in PROCESS_HEADER_LINES   -'||l_error_code||' : '||l_error_msg;
              IF (l_Debug_Level <= 5) THEN
                      cln_debug_pub.Add(l_msg_data,6);
                      cln_debug_pub.Add('------- ERROR :Exiting PROCESS_HEADER_LINES API --------- ',2);
              END IF;

 END PROCESS_HEADER_LINES;


   -- Name
   --   LOAD_CHANGES
   -- Purpose
   --   Call Process Supplier Request of Update_PO API to
   --   load all changes in to interface tables
   -- Arguments
   --   Internal Control Number
   -- Notes
   --   No Specific Notes

      PROCEDURE LOAD_CHANGES(
         p_call_po_apis                 IN  VARCHAR2,
         p_internal_ctrl_num            IN  VARCHAR2,
         p_requestor                    IN  VARCHAR2,
         p_request_origin               IN  VARCHAR2,
         p_tp_id                        IN  VARCHAR2,
         p_tp_site_id                   IN  VARCHAR2,
         x_return_status                IN OUT NOCOPY VARCHAR2,
         x_msg_data                     IN OUT NOCOPY VARCHAR2 )
      IS
         l_return_status                VARCHAR2(1000);
         l_return_msg                   VARCHAR2(2000);
         l_debug_mode                   VARCHAR2(300);
         l_error_code                   NUMBER;
         l_error_msg                    VARCHAR2(2000);
         l_error_id                     NUMBER;
         l_error_status                 VARCHAR2(1000);
         l_msg_data                     VARCHAR2(1000);
         l_errored_msg                  VARCHAR2(1000);
         l_errored_code                 NUMBER;

      BEGIN

         -- Sets the debug mode to be FILE
         --l_debug_mode           := cln_debug_pub.Set_Debug_Mode('FILE');
         l_error_id             := 0;

         IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('----- Entering LOAD_CHANGES API ------- ',2);
         END IF;

         l_msg_data     := 'Changes in PO successfully loaded';

         -- Parameters received
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('----- PARAMETERS RECEIVED ------- ',1);
                 cln_debug_pub.Add('Call PO APIs             - '||p_call_po_apis,1);
                 cln_debug_pub.Add('Internal Control Number  - '||p_internal_ctrl_num,1);
                 cln_debug_pub.Add('Requestor                - '||p_requestor,1);
                 cln_debug_pub.Add('Request Origin           - '||p_request_origin,1);
                 cln_debug_pub.Add('Trading Partner ID       - '||p_tp_id,1);
                 cln_debug_pub.Add('Trading Partner Site ID  - '||p_tp_site_id,1);
                 cln_debug_pub.Add('Return status got        - '||x_return_status,1);
                 cln_debug_pub.Add('Return msg got           - '||x_msg_data,1);
                 cln_debug_pub.Add('----------------------------------',1);
         END IF;


         IF p_call_po_apis <> 'YES' THEN
                RETURN;
         END IF;

         IF x_return_status = 'S' THEN
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Calling PO_CHG_REQUEST_GRP.process_supplier_request API',1);
                END IF;

                PO_CHG_REQUEST_GRP.process_supplier_request (
                      p_int_cont_num      => p_internal_ctrl_num,
                      x_error_id_in       => l_error_id,
                      x_error_status_in   => l_error_status,
                      x_error_id_out      => l_error_id,
                      x_error_status_out  => l_error_status
                );

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ERROR ID             : ' || l_error_id,1);
                        cln_debug_pub.Add('ERROR STATUS         : ' || l_error_status,1);
                END IF;

                IF l_error_id IS NOT NULL AND l_error_id <> 0 THEN
                      x_msg_data     :=   l_error_status;
                      l_msg_data     :=   l_error_status;
                      l_errored_msg  :=   l_error_status;
                      l_errored_code :=   0;
                END IF;
         END IF;

         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Calling PO_CHG_REQUEST_GRP.windup_chn_ack_inbound API',1);
         END IF;


         -- we have to call this even in case of error.
         PO_CHG_REQUEST_GRP.windup_chn_ack_inbound (
                p_requestor             => p_requestor,
                p_int_cont_num          => p_internal_ctrl_num,
                p_request_origin        => p_request_origin,
                p_tp_id                 => p_tp_id,
                p_tp_site_id            => p_tp_site_id,
                x_error_id_in           => l_error_id,
                x_error_status_in       => l_error_status,
                x_error_id_out          => l_error_id,
                x_error_status_out      => l_error_status
         );

         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('ERROR ID             : ' || l_error_id,1);
                 cln_debug_pub.Add('ERROR STATUS         : ' || l_error_status,1);
         END IF;

	 -- Whatever be the status of PO_CHG_REQUEST_GRP.windup_chn_ack_inbound API,
	 -- we are returning back the failure incase the initial code returned was error.
	 -- This code is deliberately called after the API call.
	 IF x_return_status <> 'S' THEN
	       l_msg_data  := x_msg_data;
	       RAISE FND_API.G_EXC_ERROR;
	 END IF;

	 IF ( l_errored_code = 0 ) THEN
               x_msg_data  := l_errored_msg;
               RAISE FND_API.G_EXC_ERROR;
	 END IF;

         IF l_error_id IS NOT NULL AND l_error_id <> 0 THEN
                x_msg_data  := l_error_status;
                l_msg_data  := l_error_status;
                RAISE FND_API.G_EXC_ERROR;
         END IF;

         x_return_status        := 'S';

         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add(l_msg_data,1);
         END IF;
         IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('----- EXITING LOAD_CHANGES WITH SUCCESS-----', 2);
         END IF;

         EXCEPTION
                WHEN FND_API.G_EXC_ERROR THEN
                     x_return_status           := FND_API.G_RET_STS_ERROR ;
                     IF (l_Debug_Level <= 5) THEN
                             cln_debug_pub.Add(l_msg_data,4);
                             cln_debug_pub.Add('------- ERROR :Exiting LOAD_CHANGES API --------- ',2);
                     END IF;

                WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                     l_error_code              :=SQLCODE;
                     l_error_msg               :=SQLERRM;
                     x_return_status           :=FND_API.G_RET_STS_UNEXP_ERROR ;
                     l_msg_data                :=l_error_code||' : '||l_error_msg;
                     IF (l_Debug_Level <= 5) THEN
                             cln_debug_pub.Add(l_msg_data,5);
                             cln_debug_pub.Add('------- ERROR :Exiting LOAD_CHANGES API --------- ',2);
                     END IF;

                WHEN OTHERS THEN
                     l_error_code              :=SQLCODE;
                     l_error_msg               :=SQLERRM;
                     x_return_status           :=FND_API.G_RET_STS_UNEXP_ERROR ;
                     FND_MESSAGE.SET_NAME('CLN','CLN_CH_UNEXPECTED_ERROR');
                     FND_MESSAGE.SET_TOKEN('ERRORCODE',l_error_code);
                     FND_MESSAGE.SET_TOKEN('ERRORMSG',l_error_msg);
                     x_msg_data :=FND_MESSAGE.GET;
                     l_msg_data         :='Unexpected Error in LOAD_CHANGES   -'||l_error_code||' : '||l_error_msg;
                     IF (l_Debug_Level <= 5) THEN
                             cln_debug_pub.Add(l_msg_data,5);
                             cln_debug_pub.Add('------- ERROR :Exiting LOAD_CHANGES API --------- ',2);
                     END IF;
      END LOAD_CHANGES;


  -- Name
  --   ACKPO_ERROR_HANDLER
  -- Purpose
  --
  -- Arguments
  --
  -- Notes
  --   No specific notes.

  PROCEDURE ACKPO_ERROR_HANDLER(
         x_return_status             IN OUT NOCOPY VARCHAR2,
         x_msg_data                  IN OUT NOCOPY VARCHAR2,
         p_po_number                 IN VARCHAR2,
         p_org_ref                   IN VARCHAR2,
         p_coll_id                   IN NUMBER,
         p_internal_control_number   IN VARCHAR2,
         x_notification_code         OUT NOCOPY VARCHAR2,
         x_notification_status       OUT NOCOPY VARCHAR2,
         x_return_status_tp          OUT NOCOPY VARCHAR2,
         p_cln_required              IN VARCHAR2 )

  IS
        l_error_code                NUMBER;
        l_error_msg                 VARCHAR2(2000);
        l_debug_mode                VARCHAR2(255);
        l_msg_data                  VARCHAR2(255);
        l_doc_status                VARCHAR2(255);
        l_msg_dtl_screen            VARCHAR2(2000);
        l_coll_status               VARCHAR2(255);
        l_msg_buffer                VARCHAR2(2000);

  BEGIN

        -- Sets the debug mode to be FILE
        --l_debug_mode :=cln_debug_pub.Set_Debug_Mode('FILE');

        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('------ Entering ACKPO_ERROR_HANDLER API ------ ', 2);
        END IF;

        -- Initialize API return status to success
        l_msg_data :='Parameters set to their correct values when the return status is ERROR';

        -- Parameters received
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('------  Parameters Received   ------ ', 1);
                cln_debug_pub.Add('Return Status                        - '||x_return_status,1);
                cln_debug_pub.Add('Message Data                         - '||x_msg_data,1);
                cln_debug_pub.Add('PO Number                            - '||p_po_number,1);
                cln_debug_pub.Add('Originator Reference                 - '||p_org_ref,1);
                cln_debug_pub.Add('Collaboration ID                     - '||p_coll_id,1);
                cln_debug_pub.Add('Internal Control Number              - '||p_internal_control_number,1);
                cln_debug_pub.Add('CLN Required                         - '||p_cln_required,1);
                cln_debug_pub.Add('------------------------------------- ', 1);

                cln_debug_pub.Add('Rollback all previous changes....',1);
        END IF;
        ROLLBACK TO CHECK_COLLABORATION_PUB;

        IF (p_coll_id  IS NULL) THEN --If not null take action will be done
             CLN_NP_PROCESSOR_PKG.NOTIFY_ADMINISTRATOR(x_msg_data);
             l_msg_data  :=  'Collaboration ID is null. Moving out of ERROR HANDLER API.';
----Changes made for rnet messages

---             RAISE  FND_API.G_EXC_ERROR;

----Changes made for rnet messages
        END IF;


        -- if collaboration id is null, then skip this API.
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('------ERROR status------',1);
        END IF;
        FND_MESSAGE.SET_NAME('CLN','CLN_CH_ERROR_PO_UPDATION');
        FND_MESSAGE.SET_TOKEN('POID',p_po_number);
        l_error_msg           :=  FND_MESSAGE.GET;
        l_error_msg           :=  l_error_msg || '--- Detail Error:' ||x_msg_data;
        x_notification_code   := 'ACKPO_04';
        x_notification_status := 'ERROR';
        x_return_status_tp    := '99';


        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('-----Parameters set ------ ',1);
                cln_debug_pub.Add('Msg for collaboration detail         - '||l_error_msg,1);
                cln_debug_pub.Add('--------------------------------------------------',1);
        END IF;

        l_msg_buffer := x_msg_data;-- preserving the error message

        IF(p_cln_required = 'TRUE') THEN
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('------Calling RAISE_UPDATE_EVENT with ERROR status------',1);
                END IF;
                RAISE_UPDATE_EVENT(
                        x_return_status                         => x_return_status,
                        x_msg_data                              => x_msg_data,
                        p_coll_id                               => p_coll_id,
                        p_doc_status                            => 'ERROR',
                        p_org_ref                               => p_org_ref,
                        p_disposition                           => NULL,
                        p_msg_text                              => l_error_msg,
                        p_internal_control_number               => p_internal_control_number );

                IF(x_return_status <> 'S')THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

                x_msg_data := l_msg_buffer; -- restoring the actual error msg.

         END IF;

         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add(l_msg_data,1);
         END IF;
         IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('------- Exiting ACKPO_ERROR_HANDLER API --------- ',2);
         END IF;



  -- Exception Handling
  EXCEPTION

         WHEN FND_API.G_EXC_ERROR THEN
              x_return_status           := FND_API.G_RET_STS_ERROR ;
              IF (l_Debug_Level <= 5) THEN
                      cln_debug_pub.Add(l_msg_data,4);
                      cln_debug_pub.Add('------- ERROR :Exiting ACKPO_ERROR_HANDLER API --------- ',2);
              END IF;

         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              l_error_code              :=SQLCODE;
              l_error_msg               :=SQLERRM;
              x_return_status           :=FND_API.G_RET_STS_UNEXP_ERROR ;
              l_msg_data                :=l_error_code||' : '||l_error_msg;
              IF (l_Debug_Level <= 5) THEN
                      cln_debug_pub.Add(l_msg_data,6);
                      cln_debug_pub.Add('------- ERROR :Exiting ACKPO_ERROR_HANDLER API --------- ',2);
              END IF;

         WHEN OTHERS THEN
              l_error_code              :=SQLCODE;
              l_error_msg               :=SQLERRM;
              x_return_status           :=FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MESSAGE.SET_NAME('CLN','CLN_CH_UNEXPECTED_ERROR');
              FND_MESSAGE.SET_TOKEN('ERRORCODE',l_error_code);
              FND_MESSAGE.SET_TOKEN('ERRORMSG',l_error_msg);
              x_msg_data :=FND_MESSAGE.GET;
              l_msg_data         :='Unexpected Error in ACKPO_ERROR_HANDLER   -'||l_error_code||' : '||l_error_msg;
              IF (l_Debug_Level <= 5) THEN
                      cln_debug_pub.Add(l_msg_data,6);
                      cln_debug_pub.Add('------- ERROR :Exiting ACKPO_ERROR_HANDLER API --------- ',2);
              END IF;

  END ACKPO_ERROR_HANDLER;



    -- Name
    --   PROCESS_HEADER_LINES
    -- Purpose
    --   This procedure is called from the Rosettanet XGMs.
    --   This procedure is used to process the headers level.
    -- Arguments
    --
    -- Notes
    --   No specific notes.

PROCEDURE PROCESS_HEADER_RN(
        x_return_status             OUT NOCOPY VARCHAR2,
        x_msg_data                  OUT NOCOPY VARCHAR2,
        p_sender_component          IN  VARCHAR2,
        p_po_number                 IN  VARCHAR2,
        p_release_number            IN  NUMBER,
        p_revision_number           IN  NUMBER,
        p_ackcode_header            IN  NUMBER,
        p_note                      IN  LONG,
        p_requestor                 IN  VARCHAR2,
        p_int_cont_num              IN  VARCHAR2,
        p_request_origin            IN  VARCHAR2,
        p_tp_header_id              IN  NUMBER,
        p_collaboration_type        IN  VARCHAR2,
        p_tp_id                     OUT NOCOPY VARCHAR2,
        p_tp_site_id                OUT NOCOPY VARCHAR2,
        x_cln_required              OUT NOCOPY VARCHAR2,
        x_notification_code         OUT NOCOPY VARCHAR2,
        x_notification_status       OUT NOCOPY VARCHAR2,
        x_return_status_tp          OUT NOCOPY VARCHAR2,
        x_call_po_apis              OUT NOCOPY VARCHAR2 )

 IS
        l_error_code                NUMBER;
        l_txn_id                    NUMBER;
        l_error_msg                 VARCHAR2(255);
        l_msg_data                  VARCHAR2(255);
        l_debug_mode                VARCHAR2(255);
        l_update_reqd               BOOLEAN;
        l_action                    VARCHAR2(255);
        l_po_type                   VARCHAR2(50);
        l_request_type              VARCHAR2(50);
        l_error_id                  NUMBER;
        l_error_status              VARCHAR2(1000);
        l_tp_id                     NUMBER;
        l_tp_site_id                NUMBER;
        l_call_po_apis              VARCHAR2(10);
        l_po_ackcode                NUMBER;

 BEGIN

        -- Sets the debug mode to be FILE
        --l_debug_mode :=cln_debug_pub.Set_Debug_Mode('FILE');

        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('############################################################',1);
                cln_debug_pub.Add('###############   START OF XGM DEBUG FILE  #################',1);
                cln_debug_pub.Add('############################################################',1);
        END IF;

        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('---- Entering PROCESS_HEADER API ----- ', 2);
        END IF;

        -- Standard Start of API savepoint
        SAVEPOINT   CHECK_COLLABORATION_PUB;

        -- Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        l_msg_data      := 'ACKPO Header successfully consumed';
        l_call_po_apis  := 'YES';
        x_cln_required  := 'TRUE';


        -- Parameters received
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('----- PARAMETERS RECEIVED ------- ',1);
                cln_debug_pub.Add('Status received          - '||x_return_status,1);
                cln_debug_pub.Add('Message received         - '||x_msg_data,1);
                cln_debug_pub.Add('Sender Component         - '||p_sender_component,1);
                cln_debug_pub.Add('PO Number                - '||p_po_number,1);
                cln_debug_pub.Add('Release Number           - '||p_release_number,1);
                cln_debug_pub.Add('Revision Number          - '||p_revision_number,1);
                cln_debug_pub.Add('Ackcode at header level  - '||p_ackcode_header,1);
                cln_debug_pub.Add('Note                     - '||p_note,1);
                cln_debug_pub.Add('CLN reqd                 - '||x_cln_required,1);
                cln_debug_pub.Add('p_tp_header_id           - '|| p_tp_header_id, 1);
                cln_debug_pub.Add('Requestor                - '||p_requestor,1);
                cln_debug_pub.Add('Internal Ctrl Number     - '||p_int_cont_num,1);
                cln_debug_pub.Add('Request Origin           - '||p_request_origin,1);
                cln_debug_pub.Add('Collaboration Type           - '||p_collaboration_type,1);
                cln_debug_pub.Add('----------------------------------',1);
        END IF;

        l_line_num_tab.delete;-- Initialize array of PO lines


        -- Check whether collaboration can be created/upadted based on Profile, Protocol value
        CLN_CH_COLLABORATION_PKG.IS_UPDATE_REQUIRED(
            x_return_status             =>        x_return_status,
            x_msg_data                  =>        x_msg_data,
            p_doc_dir                   =>        'IN',
            p_xmlg_transaction_type     =>        null,
            p_xmlg_transaction_subtype  =>        null,
            p_tr_partner_type           =>        null,
            p_tr_partner_id             =>        null,
            p_tr_partner_site           =>        null,
            p_sender_component          =>        p_sender_component,
            x_update_reqd               =>        l_update_reqd);

        IF (x_return_status <> 'S') THEN
             FND_MESSAGE.SET_NAME('CLN','CLN_CH_REQD_CRITERIA_FAIL');
             x_msg_data         := FND_MESSAGE.GET;
             l_msg_data         :='Failed to verify the required criteria for updating/creating.collaboration';
            -- x_coll_id          :=null;
             x_cln_required     :='FALSE';
             RAISE FND_API.G_EXC_ERROR;
        ELSE
             IF (l_update_reqd <> TRUE) THEN
                x_cln_required  := 'FALSE';
               -- x_coll_id       :=  null;
             END IF;
        END IF;

       /* IF (x_cln_required <>'TRUE')THEN
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('CLN history need not be updated',1);
                        cln_debug_pub.Add('Defaulting Collaboration Type to ACKNOWLEDGE_PO',1);
                END IF;
                x_collaboration_type    :=      'ACKNOWLEDGE_PO';
        END IF;
       */


        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Getting Trading partner details using TP_HEADER_ID',1);
        END IF;

        BEGIN
             SELECT  PARTY_ID, PARTY_SITE_ID
             INTO    l_tp_id, l_tp_site_id
             FROM    ECX_TP_HEADERS
             WHERE   TP_HEADER_ID = p_tp_header_id;
        EXCEPTION
             WHEN NO_DATA_FOUND THEN
                 IF (l_Debug_Level <= 2) THEN
                         cln_debug_pub.Add('TP details not found for the TP Header ID = '||p_tp_header_id,2);
                 END IF;
        END;

        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('Trading Partner ID       - '||l_tp_id,1);
                cln_debug_pub.Add('Trading Partner Site ID  - '||l_tp_site_id,1);
        END IF;

        p_tp_id                 := l_tp_id;
        p_tp_site_id            := l_tp_site_id;


        IF (l_call_po_apis = 'YES') THEN
                IF (l_Debug_Level <= 2) THEN
                        cln_debug_pub.Add('--- Calling PO_CHG_REQUEST_GRP.initialize_chn_ack_inbound ----- ',1);
                END IF;
                PO_CHG_REQUEST_GRP.initialize_chn_ack_inbound (
                        p_requestor             => p_requestor,
                        p_int_cont_num          => p_int_cont_num,
                        p_request_origin        => p_request_origin,
                        p_tp_id                 => l_tp_id,
                        p_tp_site_id            => l_tp_site_id,
                        x_error_id              => l_error_id,
                        x_error_status          => l_error_status);

                IF (l_Debug_Level <= 2) THEN
                        cln_debug_pub.Add('ERROR ID             : ' || l_error_id,1);
                        cln_debug_pub.Add('ERROR STATUS         : ' || l_error_status,1);
                END IF;

                -- If initialize_chn_ack_inbound errored out
                IF l_error_id IS NOT NULL AND l_error_id <> 0 THEN
                     x_msg_data  :=   l_error_status;
                     l_msg_data  :=   l_error_status;
                     RAISE FND_API.G_EXC_ERROR;
                END IF;
                IF (l_Debug_Level <= 2) THEN
                        cln_debug_pub.Add('PO_CHG_REQUEST_GRP.initialize_chn_ack_inbound returned Success',1);
                END IF;
         END IF;

        l_action := p_collaboration_type;

        IF (p_collaboration_type <>  'ACKNOWLEDGE_PO') THEN
                BEGIN
                        IF((p_ackcode_header = 1) and (p_collaboration_type <> 'ORDER')) OR (p_ackcode_header not in (0,1,2,3)) THEN
                            FND_MESSAGE.SET_NAME('CLN','CLN_CH_ACKPO_INVALID_TAG_VALUE');
                            FND_MESSAGE.SET_TOKEN('TAG','ACKHEADER/ACKCODE');
                            x_msg_data  :=FND_MESSAGE.GET;
                            l_msg_data  :='Invalid value for ACKHEADER/ACKCODE tag.';
                            RAISE FND_API.G_EXC_ERROR;
                        END IF;

                        SELECT meaning INTO l_action FROM fnd_lookups
                        WHERE lookup_code = p_collaboration_type AND lookup_type = 'CLN_COLLABORATION_TYPE';
                        cln_debug_pub.Add('Collaboration Type found as  - '||l_action,1);

                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                             l_msg_data := 'Collaboration Type not found for the lookup_code as ORDER and lookup_type as CLN_COLLABORATION_TYPE ';
                             FND_MESSAGE.SET_NAME('CLN','CLN_CH_COLLABORATION_TYPE_NOT');
                             FND_MESSAGE.SET_TOKEN('TYPE','CLN_COLLABORATION_TYPE');
                             FND_MESSAGE.SET_TOKEN('CODE',l_action);
                             x_msg_data := FND_MESSAGE.GET;
                             RAISE FND_API.G_EXC_ERROR;
                END;
        ELSE
                l_action := 'Acknowledge PO';
        END IF;

        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('Action is set as                : '||l_action,1);
                cln_debug_pub.Add('Return status is                : '||x_return_status,1);
        END IF;

        -- get the sequence number for Transaction id.
        select  cln_generic_s.NEXTVAL INTO l_txn_id FROM DUAL;
        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('Transaction ID                  :' || l_txn_id, 1);
        END IF;

        -- Find the Request Type
        IF p_ackcode_header = 1 THEN
             l_request_type := 'CHANGE';
        ELSE
             l_request_type := 'ACKNOWLEDGE';
        END IF;
        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('PO Request Type is              : ' || l_request_type,1);
        END IF;

        -- Identify PO Type based on release number
        l_po_type := 'STANDARD';

        IF (p_release_number IS NOT NULL AND p_release_number > 0) THEN
             l_po_type := 'RELEASE';
        END IF;
        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('PO Type is                      : ' || l_po_type,1);
                cln_debug_pub.Add('--- Calling PO_CHG_REQUEST_GRP.validate_header ----- ',1);
        END IF;


        IF (l_call_po_apis = 'YES') THEN
            -- should not be called for 3A9 and 3A7 Response
            PO_CHG_REQUEST_GRP.validate_header (
               p_requestor               => p_requestor,
               p_int_cont_num            => p_int_cont_num,
               p_request_origin          => p_request_origin,
               p_request_type            => l_request_type,
               p_tp_id                   => l_tp_id,
               p_tp_site_id              => l_tp_site_id,
               p_po_number               => p_po_number,
               p_release_number          => p_release_number,
               p_po_type                 => l_po_type,
               -- Should not pass revision number
               p_revision_num            => NULL,
               x_error_id_in             => l_error_id,
               x_error_status_in         => l_error_status,
               x_error_id_out            => l_error_id,
               x_error_status_out        => l_error_status);

            IF (l_Debug_Level <= 2) THEN
                    cln_debug_pub.Add('ERROR ID             : ' || l_error_id,1);
                    cln_debug_pub.Add('ERROR STATUS         : ' || l_error_status,1);
            END IF;

            -- If validate header errored out
            IF l_error_id IS NOT NULL AND l_error_id <> 0 THEN
                x_msg_data  :=   l_error_status;
                l_msg_data  :=   l_error_status;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
            IF (l_Debug_Level <= 2) THEN
                    cln_debug_pub.Add('PO_CHG_REQUEST_GRP.validate_header returned Success',1);
            END IF;
        END IF;

        IF (l_call_po_apis = 'YES') THEN  -- should not be called for 3A9 and 3A8 Response
            IF (l_request_type = 'ACKNOWLEDGE') THEN
                    IF (l_Debug_Level <= 2) THEN
                            cln_debug_pub.Add('--- Calling PO_CHG_REQUEST_GRP.acknowledge_po ----- ',1);
                    END IF;
                    IF p_ackcode_header = 3 THEN    --If pending treat it as accept
                       l_po_ackcode := 0;
                    ELSE
                       l_po_ackcode := p_ackcode_header;
                    END IF;
                    PO_CHG_REQUEST_GRP.acknowledge_po(
                         p_requestor            => p_requestor,     -- Change requester or the acknowledging username
                         p_int_cont_num         => p_int_cont_num,  -- ECX's ICN. Used for integrity of request
                         p_request_type         => 'ACKNOWLEDGE',  -- ??'ACKNOWLEDGE'
                         p_tp_id                => l_tp_id,         -- vendor_id
                         p_tp_site_id           => l_tp_site_id,    -- vendor_site_id
                         p_po_number            => p_po_number,     -- PO # of the PO being modified or the Blanket's PO #
                         p_release_number       => p_release_number,-- Release number if the PO Type is release or null
                         p_po_type              => l_po_type,       -- PO Type??  -- RELEASE for release, STANDARD for others.
                         p_revision_num         => NULL,            -- Revision number of the PO or the release
                         p_ack_code             => l_po_ackcode,    -- 0 for accept/peding and 2 reject
                         p_ack_reason           => p_note,          --  comments
                         x_error_id             => l_error_id,      -- The error id will be 2, errors will go to the TP sysadmin
                         x_error_status         => l_error_status   -- Error message
                     );

                     IF (l_Debug_Level <= 2) THEN
                             cln_debug_pub.Add('ERROR ID             : ' || l_error_id,1);
                             cln_debug_pub.Add('ERROR STATUS         : ' || l_error_status,1);
                     END IF;

                     IF l_error_id IS NOT NULL AND l_error_id <> 0 THEN
                         x_msg_data  :=   l_error_status;
                         l_msg_data  :=   l_error_status;
                         RAISE FND_API.G_EXC_ERROR;
                     END IF;

                END IF;
        END IF;

        IF (p_ackcode_header = 0) or (p_ackcode_header = 3) THEN -- Pending is treated as accepted
                x_notification_code   := 'ACKPO_01';
        ELSIF (p_ackcode_header = 1) THEN
                x_notification_code   := 'ACKPO_03';
        ELSIF (p_ackcode_header = 2) THEN
                x_notification_code   := 'ACKPO_02';
        END IF;

        x_notification_status := 'SUCCESS';
        x_return_status_tp    := '00';
        x_call_po_apis        :=  l_call_po_apis;

        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('Notification Code set as     :'||x_notification_code,1);
                cln_debug_pub.Add('Notification Status set as   :'||x_notification_status,1);
                cln_debug_pub.Add('Return Status set as         :'||x_notification_code,1);
        END IF;

        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('---- Exiting PROCESS_HEADER API ----- ', 2);
        END IF;

 -- Exception Handling
 EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
             x_return_status    := FND_API.G_RET_STS_ERROR ;
             FND_MESSAGE.SET_NAME('CLN','CLN_CH_ACKPO_ERROR');
             FND_MESSAGE.SET_TOKEN('PONUM',p_po_number);
             FND_MESSAGE.SET_TOKEN('RELNUM',p_release_number);
             FND_MESSAGE.SET_TOKEN('REVNUM',p_revision_number);
             FND_MESSAGE.SET_TOKEN('MSG',x_msg_data);
             x_msg_data         := FND_MESSAGE.GET;
             x_call_po_apis     := 'NO';

             IF (l_Debug_Level <= 5) THEN
                     cln_debug_pub.Add(l_msg_data,4);
                     cln_debug_pub.Add('---- ERROR :Exiting PROCESS_HEADER  API ----- ', 2);
             END IF;


        WHEN OTHERS THEN
             l_error_code       :=SQLCODE;
             l_error_msg        :=SQLERRM;
             x_return_status    :=FND_API.G_RET_STS_UNEXP_ERROR ;
             FND_MESSAGE.SET_NAME('CLN','CLN_CH_UNEXPECTED_ERROR');
             FND_MESSAGE.SET_TOKEN('ERRORCODE',l_error_code);
             FND_MESSAGE.SET_TOKEN('ERRORMSG',l_error_msg);
             x_msg_data         :=FND_MESSAGE.GET;
             x_call_po_apis     := 'NO';

             FND_MESSAGE.SET_NAME('CLN','CLN_CH_ACKPO_ERROR');
             FND_MESSAGE.SET_TOKEN('PONUM',p_po_number);
             FND_MESSAGE.SET_TOKEN('RELNUM',p_release_number);
             FND_MESSAGE.SET_TOKEN('REVNUM',p_revision_number);
             FND_MESSAGE.SET_TOKEN('MSG',x_msg_data);
             x_msg_data         := FND_MESSAGE.GET;
             l_msg_data         :='Unexpected Error -'||l_error_code||' : '||l_error_msg;
             IF (l_Debug_Level <= 5) THEN
                     cln_debug_pub.Add(l_msg_data,6);
                     cln_debug_pub.Add('---- ERROR :Exiting PROCESS_HEADER API ----- ', 2);
             END IF;

 END PROCESS_HEADER_RN;




    -- Name
    --   PROCESS_HEADER_LINES
    -- Purpose
    --   This procedure is called from RosettaNet xgms.
    --   The main purpose of this procedure is to provide a sequence of actions that
    --   need to be taken to consume the Acknowledgement depending upon the ACKCODE
    --   value at the header level and on the Collaboration Type.
    -- Arguments
    --
    -- Notes
    --   No specific notes.

  PROCEDURE PROCESS_HEADER_LINES_RN(
         x_return_status             IN OUT NOCOPY VARCHAR2,
         x_msg_data                  IN OUT NOCOPY VARCHAR2,
         p_requestor                 IN VARCHAR2,
         p_po_number                 IN VARCHAR2,
         p_release_number            IN NUMBER,
         p_revision_number           IN NUMBER,
         p_line_number               IN NUMBER,
         p_previous_line_number      IN OUT NOCOPY NUMBER,
         p_shipment_number           IN NUMBER,
         p_new_quantity              IN NUMBER,
         p_po_quantity_uom           IN VARCHAR2,
         p_po_price_currency         IN VARCHAR2,
         p_po_price_uom              IN VARCHAR2,
         p_new_price                 IN NUMBER,
         p_ackcode_header            IN NUMBER,
         p_ackcode_line              IN NUMBER,
         p_coll_id                   IN NUMBER,
         p_new_promised_date         IN DATE,
         p_collaboration_type        IN VARCHAR2,
         p_org_ref                   IN VARCHAR2,
         p_cln_required              IN VARCHAR2,
         p_internal_control_number   IN VARCHAR2,
         p_supplier_part_number      IN VARCHAR2,
         p_so_num                    IN VARCHAR2,
         p_so_line_num               IN NUMBER,
         p_so_line_status            IN VARCHAR2,
         p_reason                    IN VARCHAR2,
         p_tp_id                     IN VARCHAR2,
         p_tp_site_id                IN VARCHAR2,
         p_msg_dtl_screen            IN OUT NOCOPY VARCHAR2,
         p_msg_txt_lines             IN OUT NOCOPY VARCHAR2,
         p_if_collaboration_updated  IN OUT NOCOPY VARCHAR2,
         -- Additional parameters added for new Change_PO API to
         -- support split lines and cancellation at header and schedule level.
         p_supp_doc_ref              IN VARCHAR2 DEFAULT NULL,
         p_supp_line_ref             IN VARCHAR2 DEFAULT NULL,
         p_supplier_shipment_ref     IN VARCHAR2 DEFAULT NULL,
         p_parent_shipment_number    IN VARCHAR2 DEFAULT NULL)
  IS
         l_error_code                NUMBER;
         l_error_msg                 VARCHAR2(255);
         l_msg_data                  VARCHAR2(255);
         l_debug_mode                VARCHAR2(255);
         l_return_code               NUMBER;
         l_return_status             VARCHAR2(255);
         l_msg_txt_lines             VARCHAR2(2000);
         l_disposition               VARCHAR2(255);
         l_return_status_tp          VARCHAR2(255);
         l_dtl_status                VARCHAR2(255);
         l_txn_id                    NUMBER;
         l_po_type                   VARCHAR2(50);
         l_error_id                  NUMBER;
         l_error_status              VARCHAR2(1000);


  BEGIN

         -- Sets the debug mode to be FILE
         --l_debug_mode           := cln_debug_pub.Set_Debug_Mode('FILE');

         IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('----- Entering PROCESS_HEADER_LINES API ------- ',2);
         END IF;

         l_msg_txt_lines        := p_msg_txt_lines;

         IF(p_ackcode_header = 0) THEN
            l_disposition            := 'ACCEPTED';
         ELSIF (p_ackcode_header = 1) THEN
            l_disposition            := 'ACCEPTED';
         ELSIF(p_ackcode_header = 2) THEN
            l_disposition            := 'REJECTED';
         ELSIF (p_ackcode_header = 3) THEN
            l_disposition            := 'PENDING';
         END IF;

         l_msg_data     := 'ACKPO successfully consumed for PO : '||p_po_number||' with Line : '||p_line_number;

         -- Parameters received
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('----- PARAMETERS RECEIVED ------- ',1);
                 cln_debug_pub.Add('Status received          - '||x_return_status,1);
                 cln_debug_pub.Add('Message received         - '||x_msg_data,1);
                 cln_debug_pub.Add('PO Number                - '||p_po_number,1);
                 cln_debug_pub.Add('Release Number           - '||p_release_number,1);
                 cln_debug_pub.Add('Revision Number          - '||p_revision_number,1);
                 cln_debug_pub.Add('Previous Line  Number    - '||p_previous_line_number,1);
                 cln_debug_pub.Add('Line  Number             - '||p_line_number,1);
                 cln_debug_pub.Add('Shipment Number          - '||p_shipment_number,1);
                 cln_debug_pub.Add('New Quantity             - '||p_new_quantity,1);
                 cln_debug_pub.Add('New Price                - '||p_new_price,1);
                 cln_debug_pub.Add('Promised Date            - '||p_new_promised_date,1);
                 cln_debug_pub.Add('Ackcode at header level  - '||p_ackcode_header,1);
                 cln_debug_pub.Add('Ackcode at line level    - '||p_ackcode_line,1);
                 cln_debug_pub.Add('Collaboration Type       - '||p_collaboration_type,1);
                 cln_debug_pub.Add('Originator Reference     - '||p_org_ref,1);
                 cln_debug_pub.Add('Collaboration ID         - '||p_coll_id,1);
                 cln_debug_pub.Add('Detail Header Message    - '||p_msg_dtl_screen,1);
                 cln_debug_pub.Add('Detail Line Message      - '||p_msg_txt_lines,1);
                 cln_debug_pub.Add('Internal Control Number  - '||p_internal_control_number,1);
                 cln_debug_pub.Add('Collaboration Updated    - '||p_if_collaboration_updated,1);
                 cln_debug_pub.Add('Disposition              - '||l_disposition,1);
                 cln_debug_pub.Add('CLN reqd                 - '||p_cln_required,1);
                 cln_debug_pub.Add('CLN reqd                 - '||p_cln_required,1);
                 cln_debug_pub.Add('CLN reqd                 - '||p_cln_required,1);
                 cln_debug_pub.Add('CLN reqd                 - '||p_cln_required,1);
                 cln_debug_pub.Add('CLN reqd                 - '||p_cln_required,1);
                 cln_debug_pub.Add('----------------------------------',1);
         END IF;

         -- get the sequence number for Transaction id.
         select  cln_generic_s.NEXTVAL INTO l_txn_id FROM DUAL;
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Transaction ID:' || l_txn_id, 1);
         END IF;

         -- Identify PO Type based on release number

         l_po_type := 'STANDARD';

         IF (p_release_number IS NOT NULL AND p_release_number > 0) THEN
             l_po_type := 'RELEASE';
         END IF;
         cln_debug_pub.Add('PO Type is           : ' || l_po_type,1);


         IF((p_ackcode_header = 1 and p_ackcode_line = 1) AND ((p_collaboration_type = 'ORDER') or (p_collaboration_type = 'ACKNOWLEDGE_PO'))) THEN
                IF l_po_type = 'RELEASE' THEN
                    IF (l_Debug_Level <= 1) THEN
                            cln_debug_pub.Add('Calling PO_CHG_REQUEST_GRP.store_supplier_request API For PO Release',1);
                    END IF;
                    PO_CHG_REQUEST_GRP.store_supplier_request (
                          p_requestor         => p_requestor,
                          p_int_cont_num      => p_internal_control_number,
                          p_request_type      => 'CHANGE',
                          p_tp_id             => p_tp_id,
                          p_tp_site_id        => p_tp_site_id,
                          p_level             => 'SHIPMENT',
                          p_po_number         => p_po_number,
                          p_release_number    => p_release_number,
                          p_po_type           => 'RELEASE',
                          -- Should not pass revision nmumber, it keeps changing
                          p_revision_num      => NULL,
                          p_line_num          => p_line_number,
                          p_reason            => p_reason,
                          p_shipment_num      => p_shipment_number,
                          p_quantity          => p_new_quantity,
                          p_quantity_uom      => p_po_quantity_uom,
                          p_price             => p_new_price,
                          p_price_currency    => p_po_price_currency,
                          p_price_uom         => p_po_price_uom,
                          p_promised_date     => p_new_promised_date,
                          p_supplier_part_num => p_supplier_part_number,
                          p_so_number         => p_so_num,
                          p_so_line_number    => p_so_line_num,
                          p_ack_type          => 'MODIFICATION',
                          x_error_id_in       => l_error_id,
                          x_error_status_in   => l_error_status,
                          x_error_id_out      => l_error_id,
                          x_error_status_out  => l_error_status/*,
                          -- Supplier Line Reference added for new Change_PO API to
                          -- support split lines and cancellation at header and schedule level.
                          p_parent_shipment_number  => p_parent_shipment_number,
                          p_supplier_doc_ref  => p_supp_doc_ref,
                          p_supplier_line_ref => p_supp_line_ref,
                          p_supplier_shipment_ref => p_supplier_shipment_ref*/);



                      IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add('ERROR ID             : ' || l_error_id,1);
                      END IF;
                      IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add('ERROR STATUS         : ' || l_error_status,1);
                      END IF;

                      IF l_error_id IS NOT NULL AND l_error_id <> 0 THEN
                         x_msg_data  :=   l_error_status;
                         l_msg_data  :=   l_error_status;
                         RAISE FND_API.G_EXC_ERROR;
                      END IF;

                ELSE

                    IF (l_Debug_Level <= 1) THEN
                            cln_debug_pub.Add('Previous and new line number are not same..',1);
                    END IF;
                    IF (p_previous_line_number <> p_line_number) THEN
                        IF (l_Debug_Level <= 1) THEN
                                cln_debug_pub.Add('Calling PO_CHG_REQUEST_GRP.store_supplier_request API For Standard PO',1);
                                cln_debug_pub.Add('Call is at Line Level......',1);
                        END IF;
                        p_previous_line_number          :=  p_line_number;

                        IF IS_ALREADY_PROCESSED_LINE(p_line_number) THEN
                              -- Nothing to do since the changes happens only once per each po line
                              -- Collaboration history too is not updated
                              IF (l_Debug_Level <= 1) THEN
                                      cln_debug_pub.Add('Since this an already processed line, Nothing to do', 1);
                              END IF;
                              RETURN;
                        END IF;

                        IF l_error_id IS NULL OR l_error_id = 0 THEN
                           PO_CHG_REQUEST_GRP.store_supplier_request (
                                  p_requestor         => p_requestor,
                                  p_int_cont_num      => p_internal_control_number,
                                  p_request_type      => 'CHANGE',
                                  p_tp_id             => p_tp_id,
                                  p_tp_site_id        => p_tp_site_id,
                                  p_level             => 'LINE',
                                  p_po_number         => p_po_number,
                                  p_release_number    => p_release_number,
                                  p_po_type           => 'STANDARD',
                                  p_revision_num      => NULL,
                                  p_line_num          => p_line_number,
                                  p_reason            => p_reason,
                                  p_shipment_num      => p_shipment_number,
                                  p_quantity          => NULL,
                                  p_quantity_uom      => NULL,
                                  p_price             => p_new_price,
                                  p_price_currency    => p_po_price_currency,
                                  p_price_uom         => p_po_price_uom,
                                  p_promised_date     => NULL,
                                  p_supplier_part_num => p_supplier_part_number,
                                  p_so_number         => p_so_num,
                                  p_so_line_number    => p_so_line_num,
                                  p_ack_type          => 'MODIFICATION',
                                  x_error_id_in       => l_error_id,
                                  x_error_status_in   => l_error_status,
                                  x_error_id_out      => l_error_id,
                                  x_error_status_out  => l_error_status/*,
                                  -- Supplier Line Reference added for new Change_PO API to
                                  -- support split lines and cancellation at header and schedule level.
                                  p_parent_shipment_number  => p_parent_shipment_number,
                                  p_supplier_doc_ref  => p_supp_doc_ref,
                                  p_supplier_line_ref => p_supp_line_ref,
                                  p_supplier_shipment_ref => p_supplier_shipment_ref*/);


                            IF (l_Debug_Level <= 1) THEN
                                    cln_debug_pub.Add('ERROR ID             : ' || l_error_id,1);
                                    cln_debug_pub.Add('ERROR STATUS         : ' || l_error_status,1);
                            END IF;
                         END IF;
                     END IF;

                    IF (l_Debug_Level <= 1) THEN
                            cln_debug_pub.Add('Calling PO_CHG_REQUEST_GRP.store_supplier_request API For Standard PO',1);
                            cln_debug_pub.Add('Call is at Shipment Line Level......',1);
                    END IF;
                    PO_CHG_REQUEST_GRP.store_supplier_request (
                          p_requestor         => p_requestor,
                          p_int_cont_num      => p_internal_control_number,
                          p_request_type      => 'CHANGE',
                          p_tp_id             => p_tp_id,
                          p_tp_site_id        => p_tp_site_id,
                          p_level             => 'SHIPMENT',
                          p_po_number         => p_po_number,
                          p_release_number    => p_release_number,
                          p_po_type           => 'STANDARD',
                          p_revision_num      => NULL,
                          p_line_num          => p_line_number,
                          p_reason            => p_reason,
                          p_shipment_num      => p_shipment_number,
                          p_quantity          => p_new_quantity,
                          p_quantity_uom      => p_po_quantity_uom,
                          p_price             => NULL,
                          p_price_currency    => NULL,
                          p_price_uom         => NULL,
                          p_promised_date     => p_new_promised_date,
                          p_supplier_part_num => p_supplier_part_number,
                          p_so_number         => p_so_num,
                          p_so_line_number    => p_so_line_num,
                          p_ack_type          => 'MODIFICATION',
                          x_error_id_in       => l_error_id,
                          x_error_status_in   => l_error_status,
                          x_error_id_out      => l_error_id,
                          x_error_status_out  => l_error_status/*,
                          -- Supplier Line Reference added for new Change_PO API to
                          -- support split lines and cancellation at header and schedule level.
                          p_parent_shipment_number  => p_parent_shipment_number,
                          p_supplier_doc_ref  => p_supp_doc_ref,
                          p_supplier_line_ref => p_supp_line_ref,
                          p_supplier_shipment_ref => p_supplier_shipment_ref*/);


                    IF (l_Debug_Level <= 1) THEN
                            cln_debug_pub.Add('ERROR ID             : ' || l_error_id,1);
                            cln_debug_pub.Add('ERROR STATUS         : ' || l_error_status,1);
                    END IF;

                    IF l_error_id IS NOT NULL AND l_error_id <> 0 THEN
                         x_msg_data  :=   l_error_status;
                         l_msg_data  :=   l_error_status;
                         RAISE FND_API.G_EXC_ERROR;
                    END IF;

                END IF;

                IF l_error_id IS NOT NULL AND l_error_id <> 0 THEN
                     x_msg_data  :=   l_error_status;
                     l_msg_data  :=   l_error_status;
                     RAISE FND_API.G_EXC_ERROR;
                END IF;

    /*
                IF l_error_id IS NULL OR l_error_id = 0 THEN
                    cln_debug_pub.Add('Calling PO_CHG_REQUEST_GRP.process_supplier_request API',1);

                    PO_CHG_REQUEST_GRP.process_supplier_request (
                       p_int_cont_num      => p_internal_control_number,
                       x_error_id_in       => l_error_id,
                       x_error_status_in   => l_error_status,
                       x_error_id_out      => l_error_id,
                       x_error_status_out  => l_error_status
                    );

                    cln_debug_pub.Add('ERROR ID             : ' || l_error_id,1);
                    cln_debug_pub.Add('ERROR STATUS         : ' || l_error_status,1);
                END IF;
     */
         END IF;

         IF l_error_id IS NOT NULL AND l_error_id <> 0 THEN
               x_msg_data  :=   l_error_status;
               l_msg_data  :=   l_error_status;
               RAISE FND_API.G_EXC_ERROR;
         END IF;


        IF ((p_cln_required = 'TRUE') AND (p_if_collaboration_updated = 'FALSE'))THEN
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Call to Raise Update Event.....',1);
                END IF;
                RAISE_UPDATE_EVENT(
                      x_return_status                => x_return_status,
                      x_msg_data                     => x_msg_data,
                      p_coll_id                      => p_coll_id,
                      p_doc_status                   => 'SUCCESS',
                      p_org_ref                      => p_org_ref,
                      p_disposition                  => l_disposition,
                      p_msg_text                     => p_msg_dtl_screen,
                      p_internal_control_number      => p_internal_control_number );

                 IF(x_return_status <> 'S')THEN
                         p_if_collaboration_updated  := 'ERROR';
                         l_msg_data := 'Error in RAISE_UPDATE_EVENT API';
                         RAISE FND_API.G_EXC_ERROR;
                 END IF;
                 p_if_collaboration_updated      :=  'TRUE';
        END IF;

        IF(p_cln_required = 'TRUE') THEN
                 IF p_ackcode_line = 0 THEN
                        l_dtl_status          := 'Accepted';
                 ELSIF p_ackcode_line = 1 THEN
                        l_dtl_status          := 'Accepted With Changes';
                 ELSIF p_ackcode_line = 2 THEN
                        l_dtl_status          := 'Rejected';
                 ELSIF p_ackcode_line = 3 THEN
                        l_dtl_status          := 'Pending';
                 END IF;

                 IF (l_Debug_Level <= 1) THEN
                         cln_debug_pub.Add('Call to Raise Message Event.....',1);
                 END IF;
                 RAISE_ADD_MSG_EVENT(
                         x_return_status        => x_return_status,
                         x_msg_data             => x_msg_data,
                         p_coll_id              => p_coll_id,
                         p_ref1                 => l_dtl_status,
                         p_ref2                 => p_line_number,
                         p_ref3                 => p_shipment_number,
                         p_ref4                 => p_org_ref,
                         p_ref5                 => null,
                         p_dtl_msg              => l_msg_txt_lines,
                         p_internal_control_number      => p_internal_control_number );

                 IF(x_return_status <> 'S')THEN
                         p_if_collaboration_updated  := 'ERROR';
                         l_msg_data := 'Error in RAISE_ADD_MSG_EVENT API';
                         RAISE FND_API.G_EXC_ERROR;
                 END IF;

                 FND_MESSAGE.SET_NAME('CLN','CLN_CH_ACKPO_CONSUMED');
                 FND_MESSAGE.SET_TOKEN('PONUM',p_po_number);
                 x_msg_data           :=  FND_MESSAGE.GET;
        END IF;

        --p_msg_dtl_screen              :=  NULL;
        p_msg_txt_lines                 :=  NULL;
        x_return_status                 :=  FND_API.G_RET_STS_SUCCESS;

        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add(l_msg_data,1);
        END IF;
        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('------- Exiting PROCESS_HEADER_LINES API --------- ',2);
        END IF;

  -- Exception Handling
  EXCEPTION

         WHEN FND_API.G_EXC_ERROR THEN
              x_return_status           := FND_API.G_RET_STS_ERROR ;
              FND_MESSAGE.SET_NAME('CLN','CLN_CH_ACKPO_ERROR');
              FND_MESSAGE.SET_TOKEN('PONUM',p_po_number);
              FND_MESSAGE.SET_TOKEN('RELNUM',p_release_number);
              FND_MESSAGE.SET_TOKEN('REVNUM',p_revision_number);
              FND_MESSAGE.SET_TOKEN('MSG',x_msg_data);
              x_msg_data         := FND_MESSAGE.GET;
              IF (l_Debug_Level <= 5) THEN
                      cln_debug_pub.Add(l_msg_data,4);
                      cln_debug_pub.Add('------- ERROR :Exiting PROCESS_HEADER_LINES API --------- ',2);
              END IF;


         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              l_error_code              :=SQLCODE;
              l_error_msg               :=SQLERRM;
              x_return_status           :=FND_API.G_RET_STS_UNEXP_ERROR ;
              l_msg_data                :=l_error_code||' : '||l_error_msg;
              IF (l_Debug_Level <= 5) THEN
                      cln_debug_pub.Add(l_msg_data,6);
                      cln_debug_pub.Add('------- ERROR :Exiting PROCESS_HEADER_LINES API --------- ',2);
              END IF;

         WHEN OTHERS THEN
              l_error_code              :=SQLCODE;
              l_error_msg               :=SQLERRM;
              x_return_status           :=FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MESSAGE.SET_NAME('CLN','CLN_CH_UNEXPECTED_ERROR');
              FND_MESSAGE.SET_TOKEN('ERRORCODE',l_error_code);
              FND_MESSAGE.SET_TOKEN('ERRORMSG',l_error_msg);
              x_msg_data :=FND_MESSAGE.GET;
              l_msg_data         :='Unexpected Error in PROCESS_HEADER_LINES   -'||l_error_code||' : '||l_error_msg;
              IF (l_Debug_Level <= 5) THEN
                      cln_debug_pub.Add(l_msg_data,6);
                      cln_debug_pub.Add('------- ERROR :Exiting PROCESS_HEADER_LINES API --------- ',2);
              END IF;

 END PROCESS_HEADER_LINES_RN;




    -- Name
    --   CLN_GET_PO_ACK_CODE_RN
    -- Purpose
    --   This procedure is called from RosettaNet XGMs.
    --   This procedure is used to get the ACK_CODE fro ack_reason_code and ack_status_code
    -- Arguments
    --
    -- Notes
    --   No specific notes.

PROCEDURE CLN_GET_PO_ACK_CODE_RN (
         p_po_ack_reason_code   IN VARCHAR2,
         p_po_status_code       IN VARCHAR2,
         x_po_ack_code          OUT NOCOPY VARCHAR2) IS
BEGIN
        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('---- Entering CLN_GET_PO_AKC_CODE_RN API ----- ', 2);
        END IF;

        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('----- PARAMETERS RECEIVED ------- ',1);
                cln_debug_pub.Add('PO Ack Reason Code received          - '||p_po_ack_reason_code,1);
                cln_debug_pub.Add('PO Status Code received         - '||p_po_status_code,1);
        END IF;

        IF (p_po_ack_reason_code = 'Accept with changes' AND p_po_status_code = 'Accept')  THEN
        x_po_ack_code := 1;
        ELSIF  ( p_po_status_code = 0)  THEN
        x_po_ack_code :=  0;
        ELSIF  ( p_po_status_code = 2)  THEN
        x_po_ack_code :=  2;
        ELSIF  ( p_po_status_code = 3)  THEN
        x_po_ack_code :=  3;
        END IF;


		IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('---- Exiting CLN_GET_PO_AKC_CODE_RN API ----- ', 2);
        END IF;

END CLN_GET_PO_ACK_CODE_RN;


  PROCEDURE UPDATE_COLL_FOR_HDR_ONLY_MSG(
         x_return_status             IN OUT NOCOPY VARCHAR2,
         x_msg_data                  IN OUT NOCOPY VARCHAR2,
         p_ackcode_header            IN NUMBER,
         p_ackcode_line              IN NUMBER,
         p_coll_id                   IN NUMBER,
         p_org_ref                   IN VARCHAR2,
         p_cln_required              IN VARCHAR2,
         p_internal_control_number   IN VARCHAR2,
         p_so_num                    IN VARCHAR2,
         p_message                   IN OUT NOCOPY VARCHAR2,
         p_if_collaboration_updated  IN OUT NOCOPY VARCHAR2)
  IS
         l_error_code                NUMBER;
         l_error_msg                 VARCHAR2(255);
         l_msg_data                  VARCHAR2(255);
         l_debug_mode                VARCHAR2(255);
         l_return_code               NUMBER;
         l_return_status             VARCHAR2(255);
         l_disposition               VARCHAR2(255);
         l_error_id                  NUMBER;
         l_error_status              VARCHAR2(1000);


  BEGIN

	 IF (l_Debug_Level <= 2) THEN
		 cln_debug_pub.Add('----- Entering UPDATE_COLL_FOR_HDR_ONLY_MSG API ------- ',2);
	 END IF;
	 IF (l_Debug_Level <= 1) THEN
		 cln_debug_pub.Add('----- PARAMETERS RECEIVED ------- ',1);
		 cln_debug_pub.Add('Status received          - '||x_return_status,1);
		 cln_debug_pub.Add('Message received         - '||x_msg_data,1);
		 cln_debug_pub.Add('Ackcode at header level  - '||p_ackcode_header,1);
		 cln_debug_pub.Add('Originator Reference     - '||p_org_ref,1);
		 cln_debug_pub.Add('Collaboration ID         - '||p_coll_id,1);
		 cln_debug_pub.Add('Detail Header Message    - '||p_message,1);
		 cln_debug_pub.Add('Internal Control Number  - '||p_internal_control_number,1);
		 cln_debug_pub.Add('Collaboration Updated    - '||p_if_collaboration_updated,1);
		 cln_debug_pub.Add('CLN reqd                 - '||p_cln_required,1);
		 cln_debug_pub.Add('----------------------------------',1);
	 END IF;
	 IF ((p_cln_required = 'TRUE') AND (p_if_collaboration_updated = 'FALSE'))THEN

		 IF(p_ackcode_header = 0) THEN
		    l_disposition            := 'ACCEPTED';
		 ELSIF (p_ackcode_header = 1) THEN
		    l_disposition            := 'ACCEPTED';
		 ELSIF(p_ackcode_header = 2) THEN
		    l_disposition            := 'REJECTED';
		 ELSIF (p_ackcode_header = 3) THEN
		    l_disposition            := 'PENDING';
		 END IF;



		 -- Identify PO Type based on release number

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Call to Raise Update Event.....',1);
                END IF;
                RAISE_UPDATE_EVENT(
                      x_return_status                => x_return_status,
                      x_msg_data                     => x_msg_data,
                      p_coll_id                      => p_coll_id,
                      p_doc_status                   => 'SUCCESS',
                      p_org_ref                      => p_org_ref,
                      p_disposition                  => l_disposition,
                      p_msg_text                     => p_message,
                      p_internal_control_number      => p_internal_control_number );

                 IF(x_return_status <> 'S')THEN
                         p_if_collaboration_updated  := 'ERROR';
                         l_msg_data := 'Error in RAISE_UPDATE_EVENT API';
                         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;
                 p_if_collaboration_updated      :=  'TRUE';
        END IF;

        x_return_status                 :=  FND_API.G_RET_STS_SUCCESS;
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add(l_msg_data,1);
        END IF;
        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('------- Exiting UPDATE_COLL_FOR_HDR_ONLY_MSG API --------- ',2);
        END IF;

  -- Exception Handling
  EXCEPTION


         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              l_error_code              :=SQLCODE;
              l_error_msg               :=SQLERRM;
              x_return_status           :=FND_API.G_RET_STS_UNEXP_ERROR ;
              l_msg_data                :=l_error_code||' : '||l_error_msg;
              IF (l_Debug_Level <= 5) THEN
                      cln_debug_pub.Add(l_msg_data,6);
                      cln_debug_pub.Add('------- ERROR :Exiting UPDATE_COLL_FOR_HDR_ONLY_MSG API --------- ',2);
              END IF;

         WHEN OTHERS THEN
              l_error_code              :=SQLCODE;
              l_error_msg               :=SQLERRM;
              x_return_status           :=FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MESSAGE.SET_NAME('CLN','CLN_CH_UNEXPECTED_ERROR');
              FND_MESSAGE.SET_TOKEN('ERRORCODE',l_error_code);
              FND_MESSAGE.SET_TOKEN('ERRORMSG',l_error_msg);
              x_msg_data :=FND_MESSAGE.GET;
              l_msg_data         :='Unexpected Error in UPDATE_COLL_FOR_HDR_ONLY_MSG   -'||l_error_code||' : '||l_error_msg;
              IF (l_Debug_Level <= 5) THEN
                      cln_debug_pub.Add(l_msg_data,6);
                      cln_debug_pub.Add('------- ERROR :Exiting UPDATE_COLL_FOR_HDR_ONLY_MSG API --------- ',2);
              END IF;

 END UPDATE_COLL_FOR_HDR_ONLY_MSG;

END CLN_ACK_PO_PKG;

/
