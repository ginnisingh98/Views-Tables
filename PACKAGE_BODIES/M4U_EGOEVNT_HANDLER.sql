--------------------------------------------------------
--  DDL for Package Body M4U_EGOEVNT_HANDLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."M4U_EGOEVNT_HANDLER" AS
/* $Header: M4UEGOHB.pls 120.0 2005/05/24 16:19:24 appldev noship $ */
   l_debug_level        NUMBER ;
   G_PKG_NAME CONSTANT     VARCHAR2(30)    := 'm4u_egoevnt_handler';


   -- Name
   --      EGO_EVENT_SUB
   -- Purpose
   --      This function is used to get the parameters from the EGO event
   --      'oracle.apps.ego.gtin.uccnetEvent'.This procedure in turn raises
   --      event for triggering the generic M4U workflow after setting the
   --      default parameters.
   -- Arguments
   --
   -- Notes
   --    No specific notes.

   FUNCTION EGO_EVENT_SUB(
        p_subscription_guid             IN RAW,
        p_event                         IN OUT NOCOPY WF_EVENT_T
   ) RETURN VARCHAR2

   IS
      l_m4u_parameters                  wf_parameter_list_t;

      l_batch_mode                      VARCHAR2(2);

      l_target_market                   VARCHAR2(50);
      l_tp_gln                          VARCHAR2(50);

      l_xmlg_transaction_type           VARCHAR2(100);
      l_xmlg_transaction_subtype        VARCHAR2(100);
      l_coll_type                       VARCHAR2(100);
      l_xml_event_key                   VARCHAR2(240);
      l_xmlg_document_id                VARCHAR2(256);
      l_error_msg                       VARCHAR2(255);
      l_debug_mode                      VARCHAR2(255);

      l_error_code                      NUMBER;
      l_gtin_count                      NUMBER;
      l_ego_batch_id                    NUMBER;
      l_ego_subbatch_id                 NUMBER;

      l_doc_type                        VARCHAR2(100);
      l_owner_role                      VARCHAR2(100);

      l_doc_no                          VARCHAR2(255);
      l_partner_doc_no                  VARCHAR2(255);

      l_msg_data                        VARCHAR2(2000);
      l_create_msg_text                 VARCHAR2(2000);


      l_event_key                       VARCHAR2(50);

      l_ecx_parameter1                  VARCHAR2(150);
      l_ecx_parameter2                  VARCHAR2(150);
      l_ecx_parameter3                  VARCHAR2(150);
      l_ecx_parameter4                  VARCHAR2(150);
      l_ecx_parameter5                  VARCHAR2(150);

      l_attribute1                      VARCHAR2(150);
      l_attribute2                      VARCHAR2(150);
      l_attribute3                      VARCHAR2(150);
      l_attribute4                      VARCHAR2(150);
      l_attribute5                      VARCHAR2(150);
      l_attribute6                      VARCHAR2(150);
      l_attribute7                      VARCHAR2(150);
      l_attribute8                      VARCHAR2(150);
      l_attribute9                      VARCHAR2(150);
      l_attribute10                     VARCHAR2(150);
      l_attribute11                     VARCHAR2(150);
      l_attribute12                     VARCHAR2(150);
      l_attribute13                     VARCHAR2(150);
      l_attribute14                     VARCHAR2(150);
      l_attribute15                     VARCHAR2(150);

      l_org_id                          NUMBER;

      l_dattribute1                     DATE;
      l_dattribute2                     DATE;
      l_dattribute3                     DATE;
      l_dattribute4                     DATE;
      l_dattribute5                     DATE;

      l_event_type                    ego_uccnet_events.event_type%TYPE;
      l_event_action                  ego_uccnet_events.event_action%TYPE;
      l_gtin                          ego_uccnet_events.gtin%TYPE;
      l_top_gtin                      ego_uccnet_events.top_gtin%TYPE;
      l_doc_owner                     ego_uccnet_events.last_updated_by%TYPE;
      l_item_number                   mtl_system_items_kfv.concatenated_segments%TYPE;

   BEGIN

      -- Sets the debug mode to be FILE
      --l_debug_mode := cln_debug_pub.Set_Debug_Mode('FILE');

      IF (l_Debug_Level <= 2) THEN
              cln_debug_pub.Add('==========ENTERING EGO_EVENT_SUB ===========', 2);
      END IF;

      l_m4u_parameters         := p_event.getParameterList();

      -- parameters obtained with the ego event.
      IF (l_Debug_Level <= 1) THEN
              cln_debug_pub.Add('----------- PARAMETERS OBTAINED ----------', 1);
      END IF;

      l_ego_batch_id           := WF_EVENT.getValueForParameter('ECX_DOCUMENT_ID',l_m4u_parameters);
      IF (l_Debug_Level <= 1) THEN
              cln_debug_pub.Add('ECX DOCUMENT ID -EGO BATCH ID   ----'||l_ego_batch_id, 1);
      END IF;

      l_ego_subbatch_id        := WF_EVENT.getValueForParameter('ECX_PARAMETER1',l_m4u_parameters);
      IF (l_Debug_Level <= 1) THEN
              cln_debug_pub.Add('ECX Param1 -EGO SUB BATCH ID    ----'||l_ego_subbatch_id, 1);
      END IF;

      IF (l_Debug_Level <= 1) THEN
              cln_debug_pub.Add('------------------------------------------', 1);
      END IF;

      -- default values
      l_xmlg_transaction_type         := 'M4U';
      l_xmlg_transaction_subtype      := 'UNKNOWN';
      l_coll_type                     := 'UNKNOWN';
      l_doc_type                      := 'UNKNOWN';

      l_create_msg_text               := 'M4U_REGISTRATION_INITIATED';
      l_batch_mode                    := 'N';
      l_xmlg_document_id              := l_ego_batch_id || ':' || l_ego_subbatch_id;
      IF (l_Debug_Level <= 1) THEN
            cln_debug_pub.Add('ECX document id                 ----'|| l_xmlg_document_id, 1);
      END IF;

      -- obtain a unique event-id
      SELECT  m4u_wlqid_s.NEXTVAL
      INTO    l_xml_event_key
      FROM    dual;

      l_xml_event_key := 'M4U_EGOEVT_'|| l_xml_event_key;
      IF (l_Debug_Level <= 1) THEN
            cln_debug_pub.Add('XML EVENT KEY                    ----'||l_xml_event_key,1);
      END IF;

       /* get count of events, in case of REGISTRATION                         */
       /* if count > 1, we use RCIR in Batch mode for Registering the items    */
       /* else we go for simple RCIR message                                   */
       SELECT   count(*), event_type
       INTO     l_gtin_count, l_event_type
       FROM     ego_uccnet_events
       WHERE    batch_id        = l_ego_batch_id
           AND  subbatch_id     = l_ego_subbatch_id
           AND  gtin            = top_gtin
       group by event_type;

       IF (l_Debug_Level <= 1) THEN
            cln_debug_pub.Add('Returned from SELECT query ..>>> ', 1);
            cln_debug_pub.Add('Row Count   -- '||l_gtin_count, 1);
            cln_debug_pub.Add('Event Type  -- '||l_event_type, 1);
       END IF;

       IF (l_event_type = 'REGISTRATION') THEN
             l_xmlg_transaction_type         := 'M4U';
             l_xmlg_transaction_subtype      := 'RCIR';
             l_doc_type                      := 'M4U_RCIR';

             IF (l_gtin_count > 1) THEN
                   l_doc_type                := 'M4U_RCIR_BATCH';
                   l_ecx_parameter5          := 'RCIR_BATCH';
                   l_batch_mode              := 'Y';

                   wf_event.AddParameterToList(
                        p_name          => 'ECX_PARAMETER5',
                        p_value         => l_ecx_parameter5,
                        p_parameterlist => l_m4u_parameters   );
                   IF (l_Debug_Level <= 1) THEN
                         cln_debug_pub.Add('ECX_PARAMETER5                       - '||l_ecx_parameter5,1);
                   END IF;
             END IF;
       ELSIF (l_event_type = 'PUBLICATION') THEN
                l_xmlg_transaction_type         := 'M4U';
                l_xmlg_transaction_subtype      := 'CIN';
                l_doc_type                      := 'M4U_CIN';
       END IF;


       IF (l_gtin_count = 1) THEN
             IF (l_Debug_Level <= 1) THEN
                   cln_debug_pub.Add('Gtin count = 1, Querying the table for more attributes...>> ', 1);
             END IF;

             SELECT  e.event_action, e.gtin, e.top_gtin,
                     e.last_updated_by,e.target_market, e.tp_gln,
                     e.organization_id, f.user_name, mtlkfv.concatenated_segments
             INTO    l_event_action, l_gtin, l_top_gtin,
                     l_doc_owner, l_target_market, l_tp_gln,
                     l_org_id, l_owner_role, l_item_number
             FROM    ego_uccnet_events e,
                     fnd_user f,
                     mtl_system_items_kfv mtlkfv
             WHERE   e.batch_id          = l_ego_batch_id
               AND   e.subbatch_id       = l_ego_subbatch_id
               AND   e.gtin              = e.top_gtin
               AND   e.event_type        = l_event_type
               AND   e.INVENTORY_ITEM_ID = mtlkfv.INVENTORY_ITEM_ID
               AND   e.ORGANIZATION_ID   = mtlkfv.ORGANIZATION_ID
               AND   e.last_updated_by   = f.user_id(+);

             IF (l_Debug_Level <= 1) THEN
                   cln_debug_pub.Add('Returned from SELECT query ..>>> ', 1);
                   cln_debug_pub.Add('Event Action                      - '||l_event_action, 1);
                   cln_debug_pub.Add('Gtin                              - '||l_gtin, 1);
                   cln_debug_pub.Add('Top GTIN                          - '||l_top_gtin, 1);
                   cln_debug_pub.Add('Doc Owner                         - '||l_doc_owner, 1);
                   cln_debug_pub.Add('Target Market                     - '||l_target_market, 1);
                   cln_debug_pub.Add('TP GLN                            - '||l_tp_gln, 1);
                   cln_debug_pub.Add('ORG ID                            - '||l_org_id, 1);
                   cln_debug_pub.Add('Owner Role                        - '||l_owner_role, 1);
                   cln_debug_pub.Add('Item Number                       - '||l_item_number, 1);
             END IF;

             -- setting the values for the attributes of the generic workflow
             l_coll_type     := l_doc_type||'_'||l_event_action;

             wf_event.AddParameterToList(
                     p_name          => 'M4U_DOC_NO',
                     p_value         => l_gtin,
                     p_parameterlist => l_m4u_parameters   );

             IF (l_Debug_Level <= 1) THEN
                   cln_debug_pub.Add('M4U_DOC_NO                           - '||l_gtin,1);
             END IF;

             wf_event.AddParameterToList(
                     p_name          => 'M4U_PARTNER_DOC_NO',
                     p_value         => l_item_number,
                     p_parameterlist => l_m4u_parameters   );

             IF (l_Debug_Level <= 1) THEN
                   cln_debug_pub.Add('M4U_PARTNER_DOC_NO                   - '||l_item_number,1);
             END IF;

             wf_event.AddParameterToList(
                     p_name          => 'M4U_DOC_OWNER',
                     p_value         => l_doc_owner,
                     p_parameterlist => l_m4u_parameters   );

             IF (l_Debug_Level <= 1) THEN
                   cln_debug_pub.Add('M4U_DOC_OWNER                        - '||l_doc_owner,1);
             END IF;

             wf_event.AddParameterToList(
                     p_name          => 'M4U_OWNER_ROLE',
                     p_value         => l_owner_role,
                     p_parameterlist => l_m4u_parameters   );

             IF (l_Debug_Level <= 1) THEN
                   cln_debug_pub.Add('M4U_OWNER_ROLE                       - '||l_owner_role,1);
             END IF;
       END IF;



       -- pass parameters as event parameters,
       -- to be used in outboud xml generation map.

       wf_event.AddParameterToList(
             p_name          => 'ECX_EVENT_KEY',
             p_value         => l_xml_event_key,
             p_parameterlist => l_m4u_parameters   );

       IF (l_Debug_Level <= 1) THEN
             cln_debug_pub.Add('ECX_EVENT_KEY                        - '||l_xml_event_key,1);
       END IF;

       wf_event.AddParameterToList(
             p_name          => 'ECX_TRANSACTION_TYPE',
             p_value         => l_xmlg_transaction_type,
             p_parameterlist => l_m4u_parameters   );
       IF (l_Debug_Level <= 1) THEN
             cln_debug_pub.Add('ECX_TRANSACTION_TYPE                 - '||l_xmlg_transaction_type,1);
       END IF;

       wf_event.AddParameterToList(
             p_name          => 'ECX_TRANSACTION_SUBTYPE',
             p_value         => l_xmlg_transaction_subtype,
             p_parameterlist => l_m4u_parameters   );
       IF (l_Debug_Level <= 1) THEN
             cln_debug_pub.Add('ECX_TRANSACTION_SUBTYPE              - '||l_xmlg_transaction_subtype,1);
       END IF;

       wf_event.AddParameterToList(
             p_name          => 'M4U_CLN_COLL_TYPE',
             p_value         => l_coll_type,
             p_parameterlist => l_m4u_parameters   );
       IF (l_Debug_Level <= 1) THEN
             cln_debug_pub.Add('M4U_CLN_COLL_TYPE                    - '||l_coll_type,1);
       END IF;

       wf_event.AddParameterToList(
             p_name          => 'M4U_CLN_DOC_TYPE',
             p_value         => l_doc_type,
             p_parameterlist => l_m4u_parameters   );
       IF (l_Debug_Level <= 1) THEN
             cln_debug_pub.Add('M4U_CLN_DOC_TYPE                     - '||l_doc_type,1);
       END IF;


       wf_event.AddParameterToList(
             p_name          => 'ECX_PARAMETER4',
             p_value         => l_ego_subbatch_id,
             p_parameterlist => l_m4u_parameters   );
       IF (l_Debug_Level <= 1) THEN
             cln_debug_pub.Add('ECX_PARAMETER4                       - '||l_ego_subbatch_id,1);
       END IF;

       wf_event.AddParameterToList(
             p_name          => 'ECX_PARAMETER2',
             p_value         => l_ego_batch_id,
             p_parameterlist => l_m4u_parameters   );
       IF (l_Debug_Level <= 1) THEN
             cln_debug_pub.Add('ECX_PARAMETER2                       - '||l_ego_batch_id,1);
       END IF;

       wf_event.AddParameterToList(
             p_name          => 'ECX_PARAMETER3',
             p_value         => l_event_type,
             p_parameterlist => l_m4u_parameters   );
       IF (l_Debug_Level <= 1) THEN
             cln_debug_pub.Add('ECX_PARAMETER3                       - '||l_event_type,1);
       END IF;


       wf_event.AddParameterToList(
             p_name          => 'ECX_DOCUMENT_ID',
             p_value         => l_xmlg_document_id,
             p_parameterlist => l_m4u_parameters   );
       IF (l_Debug_Level <= 1) THEN
             cln_debug_pub.Add('ECX_DOCUMENT_ID                      - '||l_xmlg_document_id,1);
       END IF;

       wf_event.AddParameterToList(
             p_name          => 'MESSAGE_TEXT',
             p_value         => l_create_msg_text,
             p_parameterlist => l_m4u_parameters   );
       IF (l_Debug_Level <= 1) THEN
             cln_debug_pub.Add('MESSAGE_TEXT                         - '||l_create_msg_text,1);
       END IF;

       wf_event.AddParameterToList(
             p_name          => 'ATTRIBUTE1',
             p_value         => m4u_ucc_utils.g_host_gln,
             p_parameterlist => l_m4u_parameters   );
       IF (l_Debug_Level <= 1) THEN
             cln_debug_pub.Add('ATTRIBUTE1                           - '||m4u_ucc_utils.g_host_gln,1);
       END IF;

       wf_event.AddParameterToList(
             p_name          => 'ATTRIBUTE2',
             p_value         => l_target_market,
             p_parameterlist => l_m4u_parameters   );
       IF (l_Debug_Level <= 1) THEN
             cln_debug_pub.Add('ATTRIBUTE2                           - '||l_target_market,1);
       END IF;

       wf_event.AddParameterToList(
             p_name          => 'ATTRIBUTE3',
             p_value         => l_ego_batch_id,
             p_parameterlist => l_m4u_parameters   );
       IF (l_Debug_Level <= 1) THEN
             cln_debug_pub.Add('ATTRIBUTE3                           - '||l_ego_batch_id,1);
       END IF;

       wf_event.AddParameterToList(
             p_name          => 'ATTRIBUTE4',
             p_value         => l_ego_subbatch_id,
             p_parameterlist => l_m4u_parameters   );
       IF (l_Debug_Level <= 1) THEN
             cln_debug_pub.Add('ATTRIBUTE4                           - '||l_ego_subbatch_id,1);
       END IF;

       wf_event.AddParameterToList(
             p_name          => 'ATTRIBUTE5',
             p_value         => m4u_ucc_utils.g_supp_gln,
             p_parameterlist => l_m4u_parameters   );
       IF (l_Debug_Level <= 1) THEN
             cln_debug_pub.Add('ATTRIBUTE5                           - '||m4u_ucc_utils.g_supp_gln,1);
       END IF;

       wf_event.AddParameterToList(
             p_name          => 'ATTRIBUTE6',
             p_value         => l_tp_gln,
             p_parameterlist => l_m4u_parameters   );
       IF (l_Debug_Level <= 1) THEN
             cln_debug_pub.Add('ATTRIBUTE6                           - '||l_tp_gln,1);
       END IF;

       wf_event.AddParameterToList(
             p_name          => 'ATTRIBUTE12',
             p_value         => l_xmlg_document_id,
             p_parameterlist => l_m4u_parameters   );
       IF (l_Debug_Level <= 1) THEN
             cln_debug_pub.Add('ATTRIBUTE12                          - '||l_xmlg_document_id,1);
       END IF;

       wf_event.AddParameterToList(
             p_name          => 'M4U_BATCH_MODE',
             p_value         => l_batch_mode,
             p_parameterlist => l_m4u_parameters   );
       IF (l_Debug_Level <= 1) THEN
             cln_debug_pub.Add('M4U_BATCH_MODE                       - '||l_batch_mode,1);
       END IF;

       -- set event parameters, end
       IF (l_Debug_Level <= 1) THEN
             cln_debug_pub.Add('--  Raising Event oracle.apps.m4u.outboundwf.generate  -- ',1);
             cln_debug_pub.Add('p_event_key                          - '||l_xml_event_key ,1);
       END IF;

       -- raise event to trigger outbound wlq generation WF
       wf_event.raise(
                          p_event_name            => 'oracle.apps.m4u.outboundwf.generate',
                          p_event_key             => l_xml_event_key,
                          p_parameters            => l_m4u_parameters
                     );

       -- check the message
      IF (l_Debug_Level <= 2) THEN
              cln_debug_pub.Add('============EXITING EGO_EVENT_SUB============', 2);
      END IF;

      RETURN 'SUCCESS' ;

   EXCEPTION
      WHEN OTHERS THEN
         l_error_code := SQLCODE;
         l_error_msg := SQLERRM;
         IF (l_Debug_Level <= 5) THEN
                 cln_debug_pub.Add('Error:' || l_error_code || ':' || l_error_msg, 3);
                 cln_debug_pub.Add('============EXITING EGO_EVENT_SUB============', 2);
         END IF;

         RETURN 'SUCCESS';

   END EGO_EVENT_SUB;

   BEGIN
         l_debug_level        := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));

END m4u_egoevnt_handler;


/
