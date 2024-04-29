--------------------------------------------------------
--  DDL for Package Body CLN_CH_EVENT_SUBSCRIPTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CLN_CH_EVENT_SUBSCRIPTION_PKG" AS
/* $Header: ECXCHETB.pls 120.0 2005/08/25 04:44:07 nparihar noship $ */
   l_debug_level        NUMBER := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));
--  Package
--      CLN_CH_EVENT_SUBSCRIPTION_PKG
--
--  Purpose
--      Body of package CLN_CH_EVENT_SUBSCRIPTION_PKG. This package
--      is called to create or update collaboration based on events raised./updated by calling this package.
--

   -- Name
   --    CONVERT_TO_DATE
   -- Purpose
   --    This is internal procedure to convert the string into a date
   --
 FUNCTION CONVERT_TO_DATE(
        p_string                 VARCHAR2
   ) RETURN DATE
   IS
      l_date                     DATE;
   BEGIN
      l_date := NULL;
      BEGIN
        l_date := to_date(p_string,'YYYY/MM/DD HH24:MI:SS');
      EXCEPTION
         WHEN OTHERS THEN
              BEGIN
                 l_date := to_date(p_string,'YYYY/MM/DD');
              EXCEPTION
                 WHEN OTHERS THEN
                    l_date := NULL;
              END;
      END;
      RETURN l_date;
 END;


   -- Name
   --    GET_REFERENCE_ID
   -- Purpose
   --    This is internal procedure to get the reference id from ecx_oag_controlarea_tp_v,
   --    if not passed by the user
   --
   -- Arguments
   --
   -- Notes
   --    No specific notes.

 FUNCTION GET_REFERENCE_ID(
        p_event                 IN OUT NOCOPY WF_EVENT_T
   ) RETURN VARCHAR2
   IS
      l_evt_parameters               wf_parameter_list_t;
      l_ref_id                          VARCHAR2(250);
      l_context                         VARCHAR2(500);
      l_wf_item_type                    VARCHAR2(250);
      l_wf_item_key                     VARCHAR2(250);
      l_ecx_msg_event                   wf_event_t;
      l_from_system                     VARCHAR2(250);

   BEGIN
      IF (l_Debug_Level <= 2) THEN
              ecx_cln_debug_pub.Add('============ENTERING GET_REFERENCE_ID===============', 2);
      END IF;

      l_evt_parameters           := p_event.getParameterList();
      l_context                  := WF_EVENT.getValueForParameter('#CONTEXT',l_evt_parameters);
      IF (l_context IS NULL) THEN
          IF (l_Debug_Level <= 1) THEN
                  ecx_cln_debug_pub.Add('context is null', 1);
          END IF;

          RETURN NULL;
      END IF;
      l_wf_item_type             := rtrim(ltrim(SUBSTR(l_context, 1, INSTR(l_context, ':') - 1)));
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Item type got as '||l_wf_item_type , 1);
      END IF;

      l_wf_item_key              := rtrim(ltrim(SUBSTR(l_context, INSTR(l_context, ':') + 1)));
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Item key  got as '||l_wf_item_key , 1);
      END IF;

      l_ecx_msg_event            := wf_engine.GetItemAttrEvent(l_wf_item_type,l_wf_item_key,'ECX_EVENT_MESSAGE');
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Event is obtained' , 1);
      END IF;


        if l_ecx_msg_event.from_agent is not null
        then
                l_from_system := l_ecx_msg_event.from_agent.system;
        else
                l_from_system := wf_event.local_system_name;
        end if;

      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('System name : ' || l_from_system, 1);
      END IF;


      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Event name : ' || l_ecx_msg_event.GetEventName , 1);
              ecx_cln_debug_pub.Add('Event key : ' || l_ecx_msg_event.GetEventKey, 1);
      END IF;

      l_ref_id                   := l_from_system|| ':'
                                    || l_ecx_msg_event.GetEventName || ':'
                                    || l_ecx_msg_event.GetEventKey;
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Reference ID fetched as - ' || l_ref_id, 1);
      END IF;

      IF( instr(l_ref_id,'::') > 0 ) THEN  -- If the reference id got is invalid then don't use it
          IF (l_Debug_Level <= 1) THEN
                  ecx_cln_debug_pub.Add('Reference ID seems Invalid, so setting it to null', 1);
          END IF;

          l_ref_id := null;
      END IF;
      IF (l_Debug_Level <= 2) THEN
              ecx_cln_debug_pub.Add('============EXITING GET_REFERENCE_ID===============', 2);
      END IF;

      return l_ref_id;
   EXCEPTION
          WHEN OTHERS THEN
                IF (l_Debug_Level <= 2) THEN
                        ecx_cln_debug_pub.Add('============EXITING GET_REFERENCE_ID===============', 2);
                END IF;

                return NULL;
   END;

   -- Name
   --    CREATE_EVENT_SUB
   -- Purpose
   --    This is the public procedure which is used to get the parameters for the create
   --    collaboration event.This procedure in turn calls CREATE_COLLABORATION API.
   --
   -- Arguments
   --
   -- Notes
   --    No specific notes.

   FUNCTION CREATE_EVENT_SUB(
        p_subscription_guid             IN RAW,
        p_event                         IN OUT NOCOPY WF_EVENT_T
   ) RETURN VARCHAR2
   IS
      l_cln_ch_parameters               wf_parameter_list_t;

      l_ref_id                          VARCHAR2(100);
      l_xmlg_transaction_type           VARCHAR2(100);
      l_xmlg_transaction_subtype        VARCHAR2(100);
      l_xmlg_int_transaction_type       VARCHAR2(100);
      l_xmlg_int_transaction_subtype    VARCHAR2(100);
      l_xmlg_msg_id                     VARCHAR2(100);
      l_xmlg_internal_control_number    VARCHAR2(100);
      l_coll_type                       VARCHAR2(100);
      l_doc_type                        VARCHAR2(100);

      l_xmlg_document_id                VARCHAR2(256);
      l_error_msg                       VARCHAR2(255);
      l_debug_mode                      VARCHAR2(255);
      l_return_status                   VARCHAR2(255);
      l_doc_no                          VARCHAR2(255);
      l_partner_doc_no                  VARCHAR2(255);
      l_sender_protocol                 VARCHAR2(240);
      l_rosettanet_check_required       VARCHAR2(240);
      l_xml_event_key                   VARCHAR2(240);
      l_subscriber_list                 VARCHAR2(1000);
      l_msg_data                        VARCHAR2(2000);
      l_msg_text                        VARCHAR2(2000);

      l_resend_flag                     VARCHAR2(1);
      l_doc_dir                         VARCHAR2(3);

      l_app_id                          VARCHAR2(10);
      l_rel_no                          VARCHAR2(10);
      l_doc_rev_no                      VARCHAR2(10);
      l_tr_partner_type                 VARCHAR2(10);
      l_coll_pt                         VARCHAR2(20);

      l_collaboration_standard          VARCHAR2(30);
      l_doc_owner                       VARCHAR2(30);
      l_owner_role                      VARCHAR2(30);
      l_tr_partner_id                   VARCHAR2(30);
      l_tr_partner_site                 VARCHAR2(30);
      l_unique1                         VARCHAR2(30);
      l_unique2                         VARCHAR2(30);
      l_unique3                         VARCHAR2(30);
      l_unique4                         VARCHAR2(30);
      l_unique5                         VARCHAR2(30);

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

      l_error_code                      NUMBER;
      l_org_id                          NUMBER;
      l_resend_count                    NUMBER;
      l_coll_id                         NUMBER;

      l_dattribute1                     DATE;
      l_dattribute2                     DATE;
      l_dattribute3                     DATE;
      l_dattribute4                     DATE;
      l_dattribute5                     DATE;
      l_init_date                       DATE;
      l_doc_creation_date               DATE;
      l_doc_revision_date               DATE;

      l_rosettanet_check_required_b     BOOLEAN;


   BEGIN
      -- Sets the debug mode to be FILE
      --l_debug_mode := ecx_cln_debug_pub.Set_Debug_Mode('FILE');

      IF (l_Debug_Level <= 2) THEN
              ecx_cln_debug_pub.Add('==========ENTERING CLN_CREATE_EVENT_SUB===========', 2);
      END IF;

      l_cln_ch_parameters           := p_event.getParameterList();

      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('----------- PARAMETERS OBTAINED ----------', 1);
      END IF;


      l_subscriber_list:= WF_EVENT.getValueForParameter('SUBSCRIBER_LIST',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Subscriber List                 ----'||l_subscriber_list, 1);
      END IF;

      IF(l_subscriber_list is not null and instr(l_subscriber_list,'CLN') = 0) THEN
              IF (l_Debug_Level <= 1) THEN
                ecx_cln_debug_pub.Add('Subscriber list is not null and CLN is not there in the list', 1);
              END IF;
              RETURN 'SUCCESS'; -- No need to consume this event
           END IF;


      l_xmlg_msg_id                 := WF_EVENT.getValueForParameter('XMLG_MESSAGE_ID',l_cln_ch_parameters);
      l_xmlg_msg_id                 := replace(l_xmlg_msg_id,'.',''); -- There is an issue with Workflow
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('XMLG Message ID                 ----'||l_xmlg_msg_id, 1);
      END IF;


      l_xmlg_internal_control_number:= WF_EVENT.getValueForParameter('XMLG_INTERNAL_CONTROL_NUMBER',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('XMLG Internal Control Number    ----'||l_xmlg_internal_control_number, 1);
      END IF;


      l_xmlg_transaction_type       := WF_EVENT.getValueForParameter('XMLG_TRANSACTION_TYPE',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('XMLG Ext Transaction Type       ----'||l_xmlg_transaction_type, 1);
      END IF;


      l_xmlg_transaction_subtype    := WF_EVENT.getValueForParameter('XMLG_TRANSACTION_SUBTYPE',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('XMLG Ext Transaction Sub Type   ----'||l_xmlg_transaction_subtype, 1);
      END IF;


      l_xmlg_int_transaction_type   := WF_EVENT.getValueForParameter('XMLG_INTERNAL_TXN_TYPE',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('XMLG Int Transaction Type       ----'||l_xmlg_int_transaction_type, 1);
      END IF;


      l_xmlg_int_transaction_subtype:= WF_EVENT.getValueForParameter('XMLG_INTERNAL_TXN_SUBTYPE',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('XMLG Int Transaction Sub Type   ----'||l_xmlg_int_transaction_subtype, 1);
      END IF;


      l_xmlg_document_id            := WF_EVENT.getValueForParameter('XMLG_DOCUMENT_ID',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('XMLG Document ID                ----'||l_xmlg_document_id, 1);
      END IF;


      l_doc_dir                     := WF_EVENT.getValueForParameter('DOCUMENT_DIRECTION',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Document Direction              ----'||l_doc_dir, 1);
      END IF;


      l_tr_partner_type             := WF_EVENT.getValueForParameter('TRADING_PARTNER_TYPE',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Trading Partner Type            ----'||l_tr_partner_type, 1);
      END IF;


      l_tr_partner_id               := WF_EVENT.getValueForParameter('TRADING_PARTNER_ID',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Trading Partner ID              ----'||l_tr_partner_id, 1);
      END IF;


      l_tr_partner_site             := WF_EVENT.getValueForParameter('TRADING_PARTNER_SITE',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Trading Partner Site            ----'||l_tr_partner_site, 1);
      END IF;


      l_sender_protocol             := WF_EVENT.getValueForParameter('SENDER_COMPONENT',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Sender Protocol                 ----'||l_sender_protocol, 1);
      END IF;


      l_ref_id                      := WF_EVENT.getValueForParameter('REFERENCE_ID',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Reference ID                    ----'||l_ref_id, 1);
      END IF;


      l_doc_no                      := WF_EVENT.getValueForParameter('DOCUMENT_NO',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Document Number                 ----'||l_doc_no, 1);
      END IF;


      l_org_id                      := To_Number(WF_EVENT.getValueForParameter('ORG_ID',l_cln_ch_parameters));
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Org ID                          ----'||l_org_id, 1);
      END IF;


      l_rel_no                      := WF_EVENT.getValueForParameter('RELEASE_NO',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Release Number                  ----'||l_rel_no, 1);
      END IF;


      l_doc_rev_no                  := WF_EVENT.getValueForParameter('DOCUMENT_REVISION_NO',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Document Revision Number        ----'||l_doc_rev_no, 1);
      END IF;


      l_partner_doc_no              := WF_EVENT.getValueForParameter('PARTNER_DOCUMENT_NO',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Partner Document No             ----'||l_partner_doc_no, 1);
      END IF;


      l_resend_count                := To_Number(WF_EVENT.getValueForParameter('RESEND_COUNT',l_cln_ch_parameters));
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Resend Count                    ----'||l_resend_count, 1);
      END IF;


      l_doc_creation_date           := CONVERT_TO_DATE(WF_EVENT.getValueForParameter('DOCUMENT_CREATION_DATE',l_cln_ch_parameters));
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Document Creation Date          ----'||l_doc_creation_date, 1);
      END IF;


      l_doc_revision_date           := CONVERT_TO_DATE(WF_EVENT.getValueForParameter('DOCUMENT_REVISION_DATE',l_cln_ch_parameters));
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Document Revision Date          ----'||l_doc_revision_date, 1);
      END IF;


      l_coll_pt                     := WF_EVENT.getValueForParameter('COLLABORATION_POINT',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Collaboration Point             ----'||l_coll_pt, 1);
      END IF;


      l_unique1                     := WF_EVENT.getValueForParameter('UNIQUE_ID1',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Unique ID1                      ----'||l_unique1, 1);
      END IF;


      l_unique2                     := WF_EVENT.getValueForParameter('UNIQUE_ID2',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Unique ID2                      ----'||l_unique2, 1);
      END IF;

      l_unique3                     := WF_EVENT.getValueForParameter('UNIQUE_ID3',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Unique ID3                      ----'||l_unique3, 1);
      END IF;

      l_unique4                     := WF_EVENT.getValueForParameter('UNIQUE_ID4',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Unique ID4                      ----'||l_unique4, 1);
      END IF;

      l_unique5                     := WF_EVENT.getValueForParameter('UNIQUE_ID5',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Unique ID5                      ----'||l_unique5, 1);
      END IF;

      l_rosettanet_check_required   := WF_EVENT.getValueForParameter('ROSETTANET_CHECK_REQUIRED',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Rosettanet Check Required       ----'||l_rosettanet_check_required, 1);
      END IF;

      l_doc_owner                   := To_Number(WF_EVENT.getValueForParameter('DOCUMENT_OWNER',l_cln_ch_parameters));
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Document Owner                  ----'||l_doc_owner, 1);
      END IF;

      l_owner_role                  := WF_EVENT.getValueForParameter('OWNER_ROLE',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Owner Role                      ----'||l_owner_role, 1);
      END IF;

      l_msg_text                    := WF_EVENT.getValueForParameter('MESSAGE_TEXT',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Message Text                    ----'||l_msg_text, 1);
      END IF;

      l_collaboration_standard      := WF_EVENT.getValueForParameter('COLLABORATION_STANDARD',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Collaboration Standard           ----'||l_collaboration_standard, 1);
      END IF;

      l_xml_event_key              := WF_EVENT.getValueForParameter('XML_EVENT_KEY',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('XMLG Event Key                  ----'||l_xml_event_key, 1);
      END IF;

      l_app_id              := WF_EVENT.getValueForParameter('APPLICATION_ID',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Application ID                  ----'||l_app_id, 1);
      END IF;

      l_coll_type              := WF_EVENT.getValueForParameter('COLLABORATION_TYPE',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Collaboration Type              ----'||l_coll_type, 1);
      END IF;

      l_doc_type              := WF_EVENT.getValueForParameter('DOCUMENT_TYPE',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Document Type                   ----'||l_doc_type, 1);
      END IF;

      l_init_date              := CONVERT_TO_DATE(WF_EVENT.getValueForParameter('COLLABORATION_INITIATION_DATE',l_cln_ch_parameters));
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Initiation Date                 ----'||l_init_date, 1);
      END IF;

      l_attribute1             := WF_EVENT.getValueForParameter('ATTRIBUTE1',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE1                      ----'||l_attribute1, 1);
      END IF;

      l_attribute2             := WF_EVENT.getValueForParameter('ATTRIBUTE2',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE2                      ----'||l_attribute2, 1);
      END IF;

      l_attribute3             := WF_EVENT.getValueForParameter('ATTRIBUTE3',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE3                      ----'||l_attribute3, 1);
      END IF;

      l_attribute4             := WF_EVENT.getValueForParameter('ATTRIBUTE4',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE4                      ----'||l_attribute4, 1);
      END IF;

      l_attribute5             := WF_EVENT.getValueForParameter('ATTRIBUTE5',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE5                      ----'||l_attribute5, 1);
      END IF;

      l_attribute6             := WF_EVENT.getValueForParameter('ATTRIBUTE6',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE6                      ----'||l_attribute6, 1);
      END IF;

      l_attribute7             := WF_EVENT.getValueForParameter('ATTRIBUTE7',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE7                      ----'||l_attribute7, 1);
      END IF;

      l_attribute8             := WF_EVENT.getValueForParameter('ATTRIBUTE8',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE8                      ----'||l_attribute8, 1);
      END IF;

      l_attribute9             := WF_EVENT.getValueForParameter('ATTRIBUTE9',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE9                      ----'||l_attribute9, 1);
      END IF;

      l_attribute10            := WF_EVENT.getValueForParameter('ATTRIBUTE10',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE10                      ----'||l_attribute10, 1);
      END IF;

      l_attribute11            := WF_EVENT.getValueForParameter('ATTRIBUTE11',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE11                      ----'||l_attribute11, 1);
      END IF;

      l_attribute12            := WF_EVENT.getValueForParameter('ATTRIBUTE12',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE12                      ----'||l_attribute12, 1);
      END IF;

      l_attribute13            := WF_EVENT.getValueForParameter('ATTRIBUTE13',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE13                      ----'||l_attribute13, 1);
      END IF;

      l_attribute14            := WF_EVENT.getValueForParameter('ATTRIBUTE14',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE14                      ----'||l_attribute14, 1);
      END IF;

      l_attribute15            := WF_EVENT.getValueForParameter('ATTRIBUTE15',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE15                      ----'||l_attribute15, 1);
      END IF;

      l_dattribute1            := CONVERT_TO_DATE(WF_EVENT.getValueForParameter('DATTRIBUTE1',l_cln_ch_parameters));
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('DATTRIBUTE1                      ----'||l_dattribute1, 1);
      END IF;

      l_dattribute2            := CONVERT_TO_DATE(WF_EVENT.getValueForParameter('DATTRIBUTE2',l_cln_ch_parameters));
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('DATTRIBUTE2                      ----'||l_dattribute2, 1);
      END IF;

      l_dattribute3            := CONVERT_TO_DATE(WF_EVENT.getValueForParameter('DATTRIBUTE3',l_cln_ch_parameters));
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('DATTRIBUTE3                      ----'||l_dattribute3, 1);
      END IF;

      l_dattribute4            := CONVERT_TO_DATE(WF_EVENT.getValueForParameter('DATTRIBUTE4',l_cln_ch_parameters));
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('DATTRIBUTE4                      ----'||l_dattribute4, 1);
      END IF;

      l_dattribute5            := CONVERT_TO_DATE(WF_EVENT.getValueForParameter('DATTRIBUTE5',l_cln_ch_parameters));
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('DATTRIBUTE5                      ----'||l_dattribute5, 1);
      END IF;

      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('------------------------------------------', 1);
      END IF;



      IF (l_resend_count > 0) THEN
          l_resend_flag   :=     'Y';
      ELSE
          l_resend_flag   :=     'N';
      END IF;

      IF ( UPPER(l_rosettanet_check_required) = 'FALSE') THEN
          l_rosettanet_check_required_b := FALSE;
      ELSE
          l_rosettanet_check_required_b := TRUE;
      END IF;

      IF (l_ref_id IS NULL ) THEN -- If reference ID is not passed by caller, get defualt XMLG OAG rf id and set it to global variable
          CLN_CH_COLLABORATION_PKG.g_xmlg_oag_application_ref_id  :=  Get_Reference_id(p_event);
      END IF;

      CLN_CH_COLLABORATION_PKG.CREATE_COLLABORATION(
               x_return_status                  =>          l_return_status,
               x_msg_data                       =>          l_msg_data,
               p_app_id                         =>          l_app_id,
               p_ref_id                         =>          l_ref_id,
               p_org_id                         =>          l_org_id,
               p_rel_no                         =>          l_rel_no,
               p_doc_no                         =>          l_doc_no,
               p_doc_rev_no                     =>          l_doc_rev_no,
               p_xmlg_transaction_type          =>          l_xmlg_transaction_type,
               p_xmlg_transaction_subtype       =>          l_xmlg_transaction_subtype,
               p_xmlg_document_id               =>          l_xmlg_document_id,
               p_partner_doc_no                 =>          l_partner_doc_no,
               p_coll_type                      =>          l_coll_type,
               p_tr_partner_type                =>          l_tr_partner_type,
               p_tr_partner_id                  =>          l_tr_partner_id,
               p_tr_partner_site                =>          l_tr_partner_site,
               p_resend_flag                    =>          l_resend_flag,
               p_resend_count                   =>          l_resend_count,
               p_doc_owner                      =>          l_doc_owner,
               p_init_date                      =>          l_init_date,
               p_doc_creation_date              =>          l_doc_creation_date,
               p_doc_revision_date              =>          l_doc_revision_date,
               p_doc_type                       =>          l_doc_type,
               p_doc_dir                        =>          l_doc_dir,
               p_coll_pt                        =>          l_coll_pt,
               p_xmlg_msg_id                    =>          l_xmlg_msg_id,
               p_unique1                        =>          l_unique1,
               p_unique2                        =>          l_unique2,
               p_unique3                        =>          l_unique3,
               p_unique4                        =>          l_unique4,
               p_unique5                        =>          l_unique5,
               p_sender_component               =>          l_sender_protocol,
               p_rosettanet_check_required      =>          l_rosettanet_check_required_b,
               x_coll_id                        =>          l_coll_id,
               p_xmlg_internal_control_number   =>          l_xmlg_internal_control_number,
               p_xmlg_int_transaction_type      =>          l_xmlg_int_transaction_type,
               p_xmlg_int_transaction_subtype   =>          l_xmlg_int_transaction_subtype,
               p_msg_text                       =>          l_msg_text,
               p_xml_event_key                  =>          l_xml_event_key,
               p_collaboration_standard         =>          l_collaboration_standard,
               p_attribute1                     =>          l_attribute1,
               p_attribute2                     =>          l_attribute2,
               p_attribute3                     =>          l_attribute3,
               p_attribute4                     =>          l_attribute4,
               p_attribute5                     =>          l_attribute5,
               p_attribute6                     =>          l_attribute6,
               p_attribute7                     =>          l_attribute7,
               p_attribute8                     =>          l_attribute8,
               p_attribute9                     =>          l_attribute9,
               p_attribute10                    =>          l_attribute10,
               p_attribute11                    =>          l_attribute11,
               p_attribute12                    =>          l_attribute12,
               p_attribute13                    =>          l_attribute13,
               p_attribute14                    =>          l_attribute14,
               p_attribute15                    =>          l_attribute15,
               p_dattribute1                    =>          l_dattribute1,
               p_dattribute2                    =>          l_dattribute2,
               p_dattribute3                    =>          l_dattribute3,
               p_dattribute4                    =>          l_dattribute4,
               p_dattribute5                    =>          l_dattribute5,
               p_owner_role                     =>          l_owner_role  );



      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('COLLABORATION_ID got as  ----'||l_coll_id, 1);
              ecx_cln_debug_pub.Add('RETURN_STATUS got as     ----'||l_return_status, 1);
              ecx_cln_debug_pub.Add('MESSAGE_DATA got as      ----'||l_msg_data, 1);
      END IF;



      IF ( l_return_status <> 'S') THEN
           RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (l_Debug_Level <= 2) THEN
              ecx_cln_debug_pub.Add('============EXITING CLN_CREATE_EVENT_SUB============', 2);
      END IF;


      RETURN 'SUCCESS' ;

   EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
         l_error_code   :=SQLCODE;
         l_error_msg    :=SQLERRM;
         IF (l_Debug_Level <= 4) THEN
                 ecx_cln_debug_pub.Add('Error:' || l_error_code || ':' || l_error_msg || ':' || l_msg_data, 3);
                 ecx_cln_debug_pub.Add('============EXITING CLN_CREATE_EVENT_SUB============', 2);
         END IF;

         RETURN 'SUCCESS';

      WHEN OTHERS THEN
         l_error_code := SQLCODE;
         l_error_msg := SQLERRM;
         IF (l_Debug_Level <= 5) THEN
                 ecx_cln_debug_pub.Add('Error:' || l_error_code || ':' || l_error_msg, 3);
                 ecx_cln_debug_pub.Add('============EXITING CLN_CREATE_EVENT_SUB============', 2);
         END IF;

         RETURN 'SUCCESS';

   END CREATE_EVENT_SUB;



   -- Name
   --    UPDATE_EVENT_SUB
   -- Purpose
   --    This is the public procedure which is used to get the parameters for the update
   --    collaboration event.This procedure in turn calls UPDATE_COLLABORATION API.
   --
   -- Arguments
   --
   -- Notes
   --    No specific notes.

   FUNCTION UPDATE_EVENT_SUB(
        p_subscription_guid             IN RAW,
        p_event                         IN OUT NOCOPY WF_EVENT_T

   ) RETURN VARCHAR2
   IS
         l_cln_ch_parameters            wf_parameter_list_t;
         l_error_code                   NUMBER;
         l_coll_id                      NUMBER;
         l_resend_count                 NUMBER;
         l_dtl_coll_id                  NUMBER;
         l_org_id                       NUMBER;

         l_resend_flag                  VARCHAR2(3);
         l_doc_dir                      VARCHAR2(3);

         l_app_id                       VARCHAR2(10);
         l_rel_no                       VARCHAR2(10);
         l_disposition                  VARCHAR2(10);
         l_tr_partner_type              VARCHAR2(10);
         l_doc_rev_no                   VARCHAR2(10);
         l_doc_status                   VARCHAR2(10);

         l_coll_pt                      VARCHAR2(20);

         l_doc_owner                    VARCHAR2(30);
         l_owner_role                   VARCHAR2(30);
         l_collaboration_standard       VARCHAR2(30);
         l_tr_partner_id                VARCHAR2(30);
         l_tr_partner_site              VARCHAR2(30);
         l_unique1                      VARCHAR2(30);
         l_unique2                      VARCHAR2(30);
         l_unique3                      VARCHAR2(30);
         l_unique4                      VARCHAR2(30);
         l_unique5                      VARCHAR2(30);

         l_ref_id                       VARCHAR2(100);
         l_xmlg_transaction_type        VARCHAR2(100);
         l_xmlg_transaction_subtype     VARCHAR2(100);
         l_xmlg_int_transaction_type    VARCHAR2(100);
         l_xmlg_int_transaction_subtype VARCHAR2(100);
         l_xmlg_msg_id                  VARCHAR2(100);
         l_xmlg_internal_control_number VARCHAR2(100);
         l_coll_status                  VARCHAR2(100);
         l_doc_type                     VARCHAR2(100);

         l_attribute1                   VARCHAR2(150);
         l_attribute2                   VARCHAR2(150);
         l_attribute3                   VARCHAR2(150);
         l_attribute4                   VARCHAR2(150);
         l_attribute5                   VARCHAR2(150);
         l_attribute6                   VARCHAR2(150);
         l_attribute7                   VARCHAR2(150);
         l_attribute8                   VARCHAR2(150);
         l_attribute9                   VARCHAR2(150);
         l_attribute10                  VARCHAR2(150);
         l_attribute11                  VARCHAR2(150);
         l_attribute12                  VARCHAR2(150);
         l_attribute13                  VARCHAR2(150);
         l_attribute14                  VARCHAR2(150);
         l_attribute15                  VARCHAR2(150);

         l_xml_event_key                VARCHAR2(240);
         l_sender_protocol              VARCHAR2(240);
         l_rosettanet_check_required    VARCHAR2(240);

         l_partner_doc_no               VARCHAR2(255);
         l_doc_no                       VARCHAR2(255);
         l_org_ref                      VARCHAR2(255);
         l_error_msg                    VARCHAR2(255);
         l_debug_mode                   VARCHAR2(255);
         l_return_status                VARCHAR2(255);
         l_xmlg_document_id             VARCHAR2(256);

         l_subscriber_list              VARCHAR2(1000);
         l_msg_text                     VARCHAR2(2000);
         l_msg_data                     VARCHAR2(2000);

         l_doc_creation_date            DATE;
         l_doc_revision_date            DATE;
         l_dattribute1                  DATE;
         l_dattribute2                  DATE;
         l_dattribute3                  DATE;
         l_dattribute4                  DATE;
         l_dattribute5                  DATE;


         l_rosettanet_check_required_b  BOOLEAN;


   BEGIN
         -- Sets the debug mode to be FILE
      --l_debug_mode := ecx_cln_debug_pub.Set_Debug_Mode('FILE');

      IF (l_Debug_Level <= 2) THEN
              ecx_cln_debug_pub.Add('============ENTERING CLN_UPDATE_EVENT_SUB============', 2);
      END IF;


      l_cln_ch_parameters                := p_event.getParameterList();



      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('----------- PARAMETERS OBTAINED ----------', 1);
      END IF;

      l_subscriber_list:= WF_EVENT.getValueForParameter('SUBSCRIBER_LIST',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Subscriber List                 ----'||l_subscriber_list, 1);
      END IF;

      IF(l_subscriber_list is not null and instr(l_subscriber_list,'CLN') = 0) THEN
              IF (l_Debug_Level <= 1) THEN
                ecx_cln_debug_pub.Add('Subscriber list is not null and CLN is not there in the list', 1);
              END IF;
              RETURN 'SUCCESS'; -- No need to consume this event
           END IF;


      l_xmlg_msg_id                 := WF_EVENT.getValueForParameter('XMLG_MESSAGE_ID',l_cln_ch_parameters);
      l_xmlg_msg_id                 := replace(l_xmlg_msg_id,'.',''); -- There is an issue with Workflow
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('XMLG Message ID                 ----'||l_xmlg_msg_id, 1);
      END IF;


      l_xmlg_internal_control_number:= WF_EVENT.getValueForParameter('XMLG_INTERNAL_CONTROL_NUMBER',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('XMLG Internal Control Number    ----'||l_xmlg_internal_control_number, 1);
      END IF;


      l_xmlg_transaction_type       := WF_EVENT.getValueForParameter('XMLG_TRANSACTION_TYPE',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('XMLG Ext Transaction Type       ----'||l_xmlg_transaction_type, 1);
      END IF;


      l_xmlg_transaction_subtype    := WF_EVENT.getValueForParameter('XMLG_TRANSACTION_SUBTYPE',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('XMLG Ext Transaction Sub Type   ----'||l_xmlg_transaction_subtype, 1);
      END IF;


      l_xmlg_int_transaction_type   := WF_EVENT.getValueForParameter('XMLG_INTERNAL_TXN_TYPE',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('XMLG Int Transaction Type       ----'||l_xmlg_int_transaction_type, 1);
      END IF;


      l_xmlg_int_transaction_subtype:= WF_EVENT.getValueForParameter('XMLG_INTERNAL_TXN_SUBTYPE',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('XMLG Int Transaction Sub Type   ----'||l_xmlg_int_transaction_subtype, 1);
      END IF;


      l_xmlg_document_id            := WF_EVENT.getValueForParameter('XMLG_DOCUMENT_ID',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('XMLG Document ID                ----'||l_xmlg_document_id, 1);
      END IF;


      l_doc_dir                     := WF_EVENT.getValueForParameter('DOCUMENT_DIRECTION',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Document Direction              ----'||l_doc_dir, 1);
      END IF;


      l_tr_partner_type             := WF_EVENT.getValueForParameter('TRADING_PARTNER_TYPE',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Trading Partner Type            ----'||l_tr_partner_type, 1);
      END IF;


      l_tr_partner_id               := WF_EVENT.getValueForParameter('TRADING_PARTNER_ID',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Trading Partner ID              ----'||l_tr_partner_id, 1);
      END IF;


      l_tr_partner_site             := WF_EVENT.getValueForParameter('TRADING_PARTNER_SITE',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Trading Partner Site            ----'||l_tr_partner_site, 1);
      END IF;


      l_sender_protocol             := WF_EVENT.getValueForParameter('SENDER_COMPONENT',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Sender Protocol                 ----'||l_sender_protocol, 1);
      END IF;


      l_ref_id                      := WF_EVENT.getValueForParameter('REFERENCE_ID',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Reference ID                    ----'||l_ref_id, 1);
      END IF;


      l_doc_no                      := WF_EVENT.getValueForParameter('DOCUMENT_NO',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Document Number                 ----'||l_doc_no, 1);
      END IF;


      l_org_id                      := To_Number(WF_EVENT.getValueForParameter('ORG_ID',l_cln_ch_parameters));
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Org ID                          ----'||l_org_id, 1);
      END IF;


      l_rel_no                      := WF_EVENT.getValueForParameter('RELEASE_NO',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Release Number                  ----'||l_rel_no, 1);
      END IF;


      l_doc_rev_no                  := WF_EVENT.getValueForParameter('DOCUMENT_REVISION_NO',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Document Revision Number        ----'||l_doc_rev_no, 1);
      END IF;


      l_partner_doc_no              := WF_EVENT.getValueForParameter('PARTNER_DOCUMENT_NO',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Partner Document No             ----'||l_partner_doc_no, 1);
      END IF;


      l_resend_count                := To_Number(WF_EVENT.getValueForParameter('RESEND_COUNT',l_cln_ch_parameters));
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Resend Count                    ----'||l_resend_count, 1);
      END IF;


      l_doc_creation_date           := CONVERT_TO_DATE(WF_EVENT.getValueForParameter('DOCUMENT_CREATION_DATE',l_cln_ch_parameters));
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Document Creation Date          ----'||l_doc_creation_date, 1);
      END IF;


      l_doc_revision_date           := CONVERT_TO_DATE(WF_EVENT.getValueForParameter('DOCUMENT_REVISION_DATE',l_cln_ch_parameters));
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Document Revision Date          ----'||l_doc_revision_date, 1);
      END IF;


      l_coll_pt                     := WF_EVENT.getValueForParameter('COLLABORATION_POINT',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Collaboration Point             ----'||l_coll_pt, 1);
      END IF;


      l_unique1                     := WF_EVENT.getValueForParameter('UNIQUE_ID1',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Unique ID1                      ----'||l_unique1, 1);
      END IF;


      l_unique2                     := WF_EVENT.getValueForParameter('UNIQUE_ID2',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Unique ID2                      ----'||l_unique2, 1);
      END IF;


      l_unique3                     := WF_EVENT.getValueForParameter('UNIQUE_ID3',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Unique ID3                      ----'||l_unique3, 1);
      END IF;


      l_unique4                     := WF_EVENT.getValueForParameter('UNIQUE_ID4',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Unique ID4                      ----'||l_unique4, 1);
      END IF;


      l_unique5                     := WF_EVENT.getValueForParameter('UNIQUE_ID5',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Unique ID5                      ----'||l_unique5, 1);
      END IF;


      l_rosettanet_check_required   := WF_EVENT.getValueForParameter('ROSETTANET_CHECK_REQUIRED',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Rosettanet Check Required       ----'||l_rosettanet_check_required, 1);
      END IF;


      l_doc_owner                   := To_Number(WF_EVENT.getValueForParameter('DOCUMENT_OWNER',l_cln_ch_parameters));
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Document Owner                  ----'||l_doc_owner, 1);
      END IF;

      l_owner_role                  := WF_EVENT.getValueForParameter('OWNER_ROLE',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Owner Role                      ----'||l_owner_role, 1);
      END IF;



      l_coll_id                     := To_Number(WF_EVENT.getValueForParameter('COLLABORATION_ID',l_cln_ch_parameters));
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Collaboration ID                ----'||l_coll_id, 1);
      END IF;


      l_disposition                 := WF_EVENT.getValueForParameter('DISPOSITION',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Disposition                     ----'||l_disposition, 1);
      END IF;


      l_org_ref                     := WF_EVENT.getValueForParameter('ORIGINATOR_REFERENCE',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Originator Reference            ----'||l_org_ref, 1);
      END IF;


      l_doc_status                  := WF_EVENT.getValueForParameter('DOCUMENT_STATUS',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Document Status                 ----'||l_doc_status, 1);
      END IF;


      l_msg_text                    := WF_EVENT.getValueForParameter('MESSAGE_TEXT',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Message Text                    ----'||l_msg_text, 1);
      END IF;

      l_collaboration_standard      := WF_EVENT.getValueForParameter('COLLABORATION_STANDARD',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Collaboration Standard           ----'||l_collaboration_standard, 1);
      END IF;


      l_xml_event_key              := WF_EVENT.getValueForParameter('XML_EVENT_KEY',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('XMLG Event Key                  ----'||l_xml_event_key, 1);
      END IF;


      l_app_id              := WF_EVENT.getValueForParameter('APPLICATION_ID',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Application ID                  ----'||l_app_id, 1);
      END IF;

      l_coll_status              := WF_EVENT.getValueForParameter('COLLABORATION_STATUS',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Collaboration Status            ----'||l_coll_status, 1);
      END IF;

      l_doc_type              := WF_EVENT.getValueForParameter('DOCUMENT_TYPE',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Document Type                   ----'||l_doc_type, 1);
      END IF;

      l_attribute1             := WF_EVENT.getValueForParameter('ATTRIBUTE1',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE1                      ----'||l_attribute1, 1);
      END IF;

      l_attribute2             := WF_EVENT.getValueForParameter('ATTRIBUTE2',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE2                      ----'||l_attribute2, 1);
      END IF;

      l_attribute3             := WF_EVENT.getValueForParameter('ATTRIBUTE3',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE3                      ----'||l_attribute3, 1);
      END IF;

      l_attribute4             := WF_EVENT.getValueForParameter('ATTRIBUTE4',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE4                      ----'||l_attribute4, 1);
      END IF;

      l_attribute5             := WF_EVENT.getValueForParameter('ATTRIBUTE5',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE5                      ----'||l_attribute5, 1);
      END IF;

      l_attribute6             := WF_EVENT.getValueForParameter('ATTRIBUTE6',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE6                      ----'||l_attribute6, 1);
      END IF;

      l_attribute7             := WF_EVENT.getValueForParameter('ATTRIBUTE7',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE7                      ----'||l_attribute7, 1);
      END IF;

      l_attribute8             := WF_EVENT.getValueForParameter('ATTRIBUTE8',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE8                      ----'||l_attribute8, 1);
      END IF;

      l_attribute9             := WF_EVENT.getValueForParameter('ATTRIBUTE9',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE9                      ----'||l_attribute9, 1);
      END IF;

      l_attribute10            := WF_EVENT.getValueForParameter('ATTRIBUTE10',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE10                      ----'||l_attribute10, 1);
      END IF;

      l_attribute11            := WF_EVENT.getValueForParameter('ATTRIBUTE11',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE11                      ----'||l_attribute11, 1);
      END IF;

      l_attribute12            := WF_EVENT.getValueForParameter('ATTRIBUTE12',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE12                      ----'||l_attribute12, 1);
      END IF;

      l_attribute13            := WF_EVENT.getValueForParameter('ATTRIBUTE13',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE13                      ----'||l_attribute13, 1);
      END IF;

      l_attribute14            := WF_EVENT.getValueForParameter('ATTRIBUTE14',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE14                      ----'||l_attribute14, 1);
      END IF;

      l_attribute15            := WF_EVENT.getValueForParameter('ATTRIBUTE15',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE15                      ----'||l_attribute15, 1);
      END IF;

      l_dattribute1            := CONVERT_TO_DATE(WF_EVENT.getValueForParameter('DATTRIBUTE1',l_cln_ch_parameters));
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('DATTRIBUTE1                      ----'||l_dattribute1, 1);
      END IF;

      l_dattribute2            := CONVERT_TO_DATE(WF_EVENT.getValueForParameter('DATTRIBUTE2',l_cln_ch_parameters));
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('DATTRIBUTE2                      ----'||l_dattribute2, 1);
      END IF;

      l_dattribute3            := CONVERT_TO_DATE(WF_EVENT.getValueForParameter('DATTRIBUTE3',l_cln_ch_parameters));
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('DATTRIBUTE3                      ----'||l_dattribute3, 1);
      END IF;

      l_dattribute4            := CONVERT_TO_DATE(WF_EVENT.getValueForParameter('DATTRIBUTE4',l_cln_ch_parameters));
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('DATTRIBUTE4                      ----'||l_dattribute4, 1);
      END IF;

      l_dattribute5            := CONVERT_TO_DATE(WF_EVENT.getValueForParameter('DATTRIBUTE5',l_cln_ch_parameters));
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('DATTRIBUTE5                      ----'||l_dattribute5, 1);
      END IF;

      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('------------------------------------------', 1);
      END IF;


         IF ( UPPER(l_rosettanet_check_required) = 'FALSE') THEN
                  l_rosettanet_check_required_b := FALSE;
         ELSE
                  l_rosettanet_check_required_b := TRUE;
         END IF;


         IF ((l_resend_count > 0) AND ( l_resend_count IS NOT NULL )) THEN
                   l_resend_flag   :=     'Y';
         END IF;


      IF (l_ref_id IS NULL ) THEN -- If reference ID is not passed by caller, get defualt XMLG OAG rf id and set it to global variable
          CLN_CH_COLLABORATION_PKG.g_xmlg_oag_application_ref_id  :=  Get_Reference_id(p_event);
      END IF;

         CLN_CH_COLLABORATION_PKG.UPDATE_COLLABORATION(
             x_return_status                  => l_return_status,
             x_msg_data                       => l_msg_data,
             p_coll_id                        => l_coll_id,
             p_app_id                         => l_app_id,
             p_ref_id                         => l_ref_id,
             p_rel_no                         => l_rel_no,
             p_doc_no                         => l_doc_no,
             p_doc_rev_no                     => l_doc_rev_no,
             p_xmlg_transaction_type          => l_xmlg_transaction_type,
             p_xmlg_transaction_subtype       => l_xmlg_transaction_subtype,
             p_xmlg_document_id               => l_xmlg_document_id,
             p_resend_flag                    => l_resend_flag,
             p_resend_count                   => l_resend_count,
             p_disposition                    => l_disposition,
             p_coll_status                    => l_coll_status,
             p_doc_type                       => l_doc_type,
             p_doc_dir                        => l_doc_dir,
             p_coll_pt                        => l_coll_pt,
             p_org_ref                        => l_org_ref,
             p_doc_status                     => l_doc_status,
             p_notification_id                => NULL,
             p_msg_text                       => l_msg_text,
             p_bsr_verb                       => NULL,
             p_bsr_noun                       => NULL,
             p_bsr_rev                        => NULL,
             p_sdr_logical_id                 => NULL,
             p_sdr_component                  => NULL,
             p_sdr_task                       => NULL,
             p_sdr_refid                      => NULL,
             p_sdr_confirmation               => NULL,
             p_sdr_language                   => NULL,
             p_sdr_codepage                   => NULL,
             p_sdr_authid                     => NULL,
             p_sdr_datetime_qualifier         => NULL,
             p_sdr_datetime                   => NULL,
             p_sdr_timezone                   => NULL,
             p_attr1                          => NULL,
             p_attr2                          => NULL,
             p_attr3                          => NULL,
             p_attr4                          => NULL,
             p_attr5                          => NULL,
             p_attr6                          => NULL,
             p_attr7                          => NULL,
             p_attr8                          => NULL,
             p_attr9                          => NULL,
             p_attr10                         => NULL,
             p_attr11                         => NULL,
             p_attr12                         => NULL,
             p_attr13                         => NULL,
             p_attr14                         => NULL,
             p_attr15                         => NULL,
             p_xmlg_msg_id                    => l_xmlg_msg_id,
             p_unique1                        => l_unique1,
             p_unique2                        => l_unique2,
             p_unique3                        => l_unique3,
             p_unique4                        => l_unique4,
             p_unique5                        => l_unique5,
             p_tr_partner_type                => l_tr_partner_type,
             p_tr_partner_id                  => l_tr_partner_id,
             p_tr_partner_site                => l_tr_partner_site,
             p_sender_component               => l_sender_protocol,
             p_rosettanet_check_required      => l_rosettanet_check_required_b,
             x_dtl_coll_id                    => l_dtl_coll_id,
             p_xmlg_internal_control_number   => l_xmlg_internal_control_number,
             p_partner_doc_no                 => l_partner_doc_no,
             p_org_id                         => l_org_id,
             p_doc_creation_date              => l_doc_creation_date,
             p_doc_revision_date              => l_doc_revision_date,
             p_doc_owner                      => l_doc_owner,
             p_xmlg_int_transaction_type      => l_xmlg_int_transaction_type,
             p_xmlg_int_transaction_subtype   => l_xmlg_int_transaction_subtype,
             p_xml_event_key                  => l_xml_event_key,
             p_collaboration_standard         => l_collaboration_standard,
             p_attribute1                     => l_attribute1,
             p_attribute2                     => l_attribute2,
             p_attribute3                     => l_attribute3,
             p_attribute4                     => l_attribute4,
             p_attribute5                     => l_attribute5,
             p_attribute6                     => l_attribute6,
             p_attribute7                     => l_attribute7,
             p_attribute8                     => l_attribute8,
             p_attribute9                     => l_attribute9,
             p_attribute10                    => l_attribute10,
             p_attribute11                    => l_attribute11,
             p_attribute12                    => l_attribute12,
             p_attribute13                    => l_attribute13,
             p_attribute14                    => l_attribute14,
             p_attribute15                    => l_attribute15,
             p_dattribute1                    => l_dattribute1,
             p_dattribute2                    => l_dattribute2,
             p_dattribute3                    => l_dattribute3,
             p_dattribute4                    => l_dattribute4,
             p_dattribute5                    => l_dattribute5,
             p_owner_role                     => l_owner_role  );


         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('COLLABORATION_DETAIL_ID got as  ----'||l_dtl_coll_id, 1);
                 ecx_cln_debug_pub.Add('RETURN_STATUS got as     ----'||l_return_status, 1);
                 ecx_cln_debug_pub.Add('MESSAGE_DATA got as      ----'||l_msg_data, 1);
         END IF;


         IF ( l_return_status <> 'S') THEN
              RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF (l_Debug_Level <= 2) THEN
                 ecx_cln_debug_pub.Add('============EXITING CLN_UPDATE_EVENT_SUB============', 2);
         END IF;

         RETURN 'SUCCESS'  ;

   EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
                 l_error_code   :=SQLCODE;
                 l_error_msg    :=SQLERRM;
                 IF (l_Debug_Level <= 4) THEN
                         ecx_cln_debug_pub.Add('Error:' || l_error_code || ':' || l_error_msg, 3);
                         ecx_cln_debug_pub.Add('============EXITING CLN_UPDATE_EVENT_SUB============', 2);
                 END IF;

            RETURN 'SUCCESS';

         WHEN OTHERS THEN
            l_error_code := SQLCODE;
            l_error_msg := SQLERRM;
            IF (l_Debug_Level <= 5) THEN
                    ecx_cln_debug_pub.Add('Error:' || l_error_code || ':' || l_error_msg, 3);
                    ecx_cln_debug_pub.Add('============EXITING CLN_UPDATE_EVENT_SUB============', 2);
            END IF;

            RETURN 'SUCCESS';

   END UPDATE_EVENT_SUB;


   FUNCTION ADD_MESSAGES_EVENT_SUB(
        p_subscription_guid                     IN RAW,
        p_event                                 IN OUT NOCOPY WF_EVENT_T

   ) RETURN VARCHAR2
   IS
         l_cln_ch_parameters                    wf_parameter_list_t;

         l_error_code                           NUMBER;
         l_dtl_coll_id                          NUMBER;
         l_coll_id                              NUMBER;

         l_doc_dir                              VARCHAR2(3);
         l_app_id                               VARCHAR2(10);
         l_coll_pt                              VARCHAR2(20);

         l_ref1                                 VARCHAR2(30);
         l_ref2                                 VARCHAR2(30);
         l_ref3                                 VARCHAR2(30);
         l_ref4                                 VARCHAR2(30);
         l_ref5                                 VARCHAR2(30);
         l_unique1                              VARCHAR2(30);
         l_unique2                              VARCHAR2(30);
         l_unique3                              VARCHAR2(30);
         l_unique4                              VARCHAR2(30);
         l_unique5                              VARCHAR2(30);

         l_doc_type                             VARCHAR2(100);
         l_xmlg_msg_id                          VARCHAR2(100);
         l_ref_id                               VARCHAR2(100);
         l_xmlg_internal_control_number         VARCHAR2(100);
         l_xmlg_transaction_type                VARCHAR2(100);
         l_xmlg_transaction_subtype             VARCHAR2(100);
         l_xmlg_int_transaction_type            VARCHAR2(100);
         l_xmlg_int_transaction_subtype         VARCHAR2(100);

         l_xml_event_key                        VARCHAR2(240);
         l_error_msg                            VARCHAR2(255);
         l_debug_mode                           VARCHAR2(255);
         l_return_status                        VARCHAR2(255);
         l_xmlg_document_id                     VARCHAR2(256);

         l_subscriber_list                      VARCHAR2(1000);

         l_msg_data                             VARCHAR2(2000);
         l_msg_text                             VARCHAR2(2000);

   BEGIN
         -- Sets the debug mode to be FILE
         --l_debug_mode := ecx_cln_debug_pub.Set_Debug_Mode('FILE');

         IF (l_Debug_Level <= 2) THEN
                 ecx_cln_debug_pub.Add('============ENTERING ADD_MESSAGES_EVENT_SUB============', 2);
         END IF;

         l_cln_ch_parameters                := p_event.getParameterList();

         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('----------- PARAMETERS OBTAINED FROM EVENT ----------', 1);
         END IF;

         l_subscriber_list:= WF_EVENT.getValueForParameter('SUBSCRIBER_LIST',l_cln_ch_parameters);
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('Subscriber List                 ----'||l_subscriber_list, 1);
         END IF;

         IF(l_subscriber_list is not null and instr(l_subscriber_list,'CLN') = 0) THEN
            IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Subscriber list is not null and CLN is not there in the list', 1);
            END IF;
            RETURN 'SUCCESS'; -- No need to consume this event
         END IF;



         l_dtl_coll_id                      := To_Number(WF_EVENT.getValueForParameter('COLLABORATION_DETAIL_ID',l_cln_ch_parameters));
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('Collaboration Detail ID         ----'||l_dtl_coll_id, 1);
         END IF;


         l_ref1                             := WF_EVENT.getValueForParameter('REFERENCE_ID1',l_cln_ch_parameters);
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('Reference 1                     ----'||l_ref1, 1);
         END IF;


         l_ref2                             := WF_EVENT.getValueForParameter('REFERENCE_ID2',l_cln_ch_parameters);
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('Reference 2                     ----'||l_ref2, 1);
         END IF;


         l_ref3                             := WF_EVENT.getValueForParameter('REFERENCE_ID3',l_cln_ch_parameters);
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('Reference 3                     ----'||l_ref3, 1);
         END IF;


         l_ref4                             := WF_EVENT.getValueForParameter('REFERENCE_ID4',l_cln_ch_parameters);
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('Reference 4                     ----'||l_ref4, 1);
         END IF;


         l_ref5                             := WF_EVENT.getValueForParameter('REFERENCE_ID5',l_cln_ch_parameters);
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('Reference 5                     ----'||l_ref5, 1);
         END IF;


         l_msg_text                         := WF_EVENT.getValueForParameter('DETAIL_MESSAGE',l_cln_ch_parameters);
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('Detail Message                  ----'||l_msg_text, 1);
         END IF;


         l_coll_id                          := To_Number(WF_EVENT.getValueForParameter('COLLABORATION_ID',l_cln_ch_parameters));
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('Collaboration ID                ----'||l_coll_id, 1);
         END IF;


         l_doc_type                         := WF_EVENT.getValueForParameter('DOCUMENT_TYPE',l_cln_ch_parameters);
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('Document Type                   ----'||l_doc_type, 1);
         END IF;


         l_doc_dir                          := WF_EVENT.getValueForParameter('DOCUMENT_DIRECTION',l_cln_ch_parameters);
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('Document Direction              ----'||l_doc_dir, 1);
         END IF;


         l_coll_pt                          := WF_EVENT.getValueForParameter('COLLABORATION_POINT',l_cln_ch_parameters);
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('Collaboration Point             ----'||l_coll_pt, 1);
         END IF;


         l_xmlg_internal_control_number     := WF_EVENT.getValueForParameter('XMLG_INTERNAL_CONTROL_NUMBER',l_cln_ch_parameters);
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('Xmlg Internal Control Number    ----'||l_xmlg_internal_control_number, 1);
         END IF;


         l_xmlg_transaction_type            := WF_EVENT.getValueForParameter('XMLG_TRANSACTION_TYPE',l_cln_ch_parameters);
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('Xmlg Transaction Type           ----'||l_xmlg_transaction_type,1);
         END IF;


         l_xmlg_transaction_subtype         := WF_EVENT.getValueForParameter('XMLG_TRANSACTION_SUBTYPE',l_cln_ch_parameters);
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('Xmlg Transaction SubType        ----'||l_xmlg_transaction_subtype,1);
         END IF;


         l_xmlg_document_id                 := WF_EVENT.getValueForParameter('XMLG_DOCUMENT_ID',l_cln_ch_parameters);
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('Xmlg Document ID                ----'||l_xmlg_document_id,1);
         END IF;


         l_xmlg_int_transaction_type        := WF_EVENT.getValueForParameter('XMLG_INTERNAL_TXN_TYPE',l_cln_ch_parameters);
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('Xmlg Int Transaction Type       ----'||l_xmlg_int_transaction_type, 1);
         END IF;



         l_xmlg_int_transaction_subtype     := WF_EVENT.getValueForParameter('XMLG_INTERNAL_TXN_SUBTYPE',l_cln_ch_parameters);
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('Xmlg Int Transaction Sub Type   ----'||l_xmlg_int_transaction_subtype, 1);
         END IF;


         l_xml_event_key                    := WF_EVENT.getValueForParameter('XML_EVENT_KEY',l_cln_ch_parameters);
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('XMLG Event Key                  ----'||l_xml_event_key, 1);
         END IF;


      l_app_id              := WF_EVENT.getValueForParameter('APPLICATION_ID',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Application ID                  ----'||l_app_id, 1);
      END IF;

      l_xmlg_msg_id                 := WF_EVENT.getValueForParameter('XMLG_MESSAGE_ID',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('XMLG Message ID                 ----'||l_xmlg_msg_id, 1);
      END IF;

      l_ref_id                      := WF_EVENT.getValueForParameter('REFERENCE_ID',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Reference ID                    ----'||l_ref_id, 1);
      END IF;

      l_unique1                     := WF_EVENT.getValueForParameter('UNIQUE_ID1',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Unique ID1                      ----'||l_unique1, 1);
      END IF;


      l_unique2                     := WF_EVENT.getValueForParameter('UNIQUE_ID2',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Unique ID2                      ----'||l_unique2, 1);
      END IF;


      l_unique3                     := WF_EVENT.getValueForParameter('UNIQUE_ID3',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Unique ID3                      ----'||l_unique3, 1);
      END IF;


      l_unique4                     := WF_EVENT.getValueForParameter('UNIQUE_ID4',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Unique ID4                      ----'||l_unique4, 1);
      END IF;


      l_unique5                     := WF_EVENT.getValueForParameter('UNIQUE_ID5',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Unique ID5                      ----'||l_unique5, 1);
      END IF;


         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('-----------------------------------------------------', 1);
         END IF;


         CLN_CH_COLLABORATION_PKG.ADD_COLLABORATION_MESSAGES(
             x_return_status                    => l_return_status,
             x_msg_data                         => l_msg_data,
             p_dtl_coll_id                      => l_dtl_coll_id,
             p_ref1                             => l_ref1,
             p_ref2                             => l_ref2,
             p_ref3                             => l_ref3,
             p_ref4                             => l_ref4,
             p_ref5                             => l_ref5,
             p_dtl_msg                          => l_msg_text,
             p_coll_id                          => l_coll_id,
             p_xmlg_transaction_type            => l_xmlg_transaction_type,
             p_xmlg_transaction_subtype         => l_xmlg_transaction_subtype,
             p_xmlg_document_id                 => l_xmlg_document_id,
             p_doc_type                         => l_doc_type,
             p_doc_direction                    => l_doc_dir,
             p_coll_point                       => l_coll_pt,
             p_xmlg_internal_control_number     => l_xmlg_internal_control_number,
             p_xmlg_int_transaction_type        => l_xmlg_int_transaction_type,
             p_xmlg_int_transaction_subtype     => l_xmlg_int_transaction_subtype,
             p_xml_event_key                    => l_xml_event_key,
             p_xmlg_msg_id                      => l_xmlg_msg_id,
             p_app_id                           => l_app_id,
             p_ref_id                           => l_ref_id,
             p_unique1                          => l_unique1,
             p_unique2                          => l_unique2,
             p_unique3                          => l_unique3,
             p_unique4                          => l_unique4,
             p_unique5                          => l_unique5
             );


         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('RETURN_STATUS got as     ----'||l_return_status, 1);
         END IF;

         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('MESSAGE_DATA got as      ----'||l_msg_data, 1);
         END IF;


         IF ( l_return_status <> 'S') THEN
              RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF (l_Debug_Level <= 2) THEN
                 ecx_cln_debug_pub.Add('============EXITING ADD_MESSAGES_EVENT_SUB============', 2);
         END IF;

         RETURN 'SUCCESS'  ;

   EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
                 IF (l_Debug_Level <= 1) THEN
                         ecx_cln_debug_pub.Add('Error:' || l_msg_data , 3);
                 END IF;

                 IF (l_Debug_Level <= 2) THEN
                         ecx_cln_debug_pub.Add('============EXITING ADD_MESSAGES_EVENT_SUB============', 2);
                 END IF;

            RETURN 'SUCCESS';

         WHEN OTHERS THEN
            l_error_code := SQLCODE;
            l_error_msg := SQLERRM;
            IF (l_Debug_Level <= 4) THEN
                    ecx_cln_debug_pub.Add('Error:' || l_error_code || ':' || l_error_msg, 3);
                    ecx_cln_debug_pub.Add('============EXITING CLN_UPDATE_EVENT_SUB============', 2);
            END IF;

            RETURN 'SUCCESS';

   END ADD_MESSAGES_EVENT_SUB;


   -- Name
   --    ADD_COLLABORATION_EVENT_SUB
   -- Purpose
   --    This is the public procedure which is used to get the parameters for the update/create
   --    collaboration event.This procedure in turn calls CREATE_COLLABORATION or UPDATE_COLLABORATION API .
   --    based on the parameters passed.
   -- Arguments
   --
   -- Notes
   --    No specific notes.

   FUNCTION ADD_COLLABORATION_EVENT_SUB(
        p_subscription_guid             IN RAW,
        p_event                         IN OUT NOCOPY WF_EVENT_T

   ) RETURN VARCHAR2
   IS
         l_cln_ch_parameters            wf_parameter_list_t;

         l_error_code                   NUMBER;

         l_error_msg                    VARCHAR2(255);
         l_debug_mode                   VARCHAR2(255);
         l_return_status                VARCHAR2(255);

         l_msg_data                     VARCHAR2(2000);

         l_coll_id                      NUMBER;

         l_ref_id                       VARCHAR2(100);
         l_rel_no                       VARCHAR2(10);
         l_doc_no                       VARCHAR2(255);
         l_doc_rev_no                   VARCHAR2(10);
         l_xmlg_transaction_type        VARCHAR2(100);
         l_xmlg_transaction_subtype     VARCHAR2(100);
         l_xmlg_int_transaction_type    VARCHAR2(100);
         l_xmlg_int_transaction_subtype VARCHAR2(100);
         l_xmlg_document_id             VARCHAR2(256);
         l_resend_flag                  VARCHAR2(3);
         l_resend_count                 NUMBER;
         l_disposition                  VARCHAR2(10);
         l_tr_partner_type              VARCHAR2(10);
         l_tr_partner_id                VARCHAR2(30);
         l_tr_partner_site              VARCHAR2(30);
         l_unique1                      VARCHAR2(30);
         l_unique2                      VARCHAR2(30);
         l_unique3                      VARCHAR2(30);
         l_unique4                      VARCHAR2(30);
         l_unique5                      VARCHAR2(30);
         l_sender_protocol              VARCHAR2(240);
         l_rosettanet_check_required    VARCHAR2(240);
         l_rosettanet_check_required_b  BOOLEAN;
         l_doc_dir                      VARCHAR2(3);
         l_coll_pt                      VARCHAR2(20);
         l_org_ref                      VARCHAR2(255);
         l_doc_status                   VARCHAR2(10);
         l_msg_text                     VARCHAR2(2000);
         l_xmlg_msg_id                  VARCHAR2(100);
         l_dtl_coll_id                  NUMBER;
         l_partner_doc_no               VARCHAR2(255);
         l_xmlg_internal_control_number VARCHAR2(100);
         l_org_id                       NUMBER;
         l_doc_creation_date            DATE;
         l_doc_revision_date            DATE;
         l_doc_owner                    VARCHAR2(30);
         l_owner_role                   VARCHAR2(30);


         l_xml_event_key                VARCHAR2(240);
         l_collaboration_standard       VARCHAR2(30);
         l_subscriber_list              VARCHAR2(1000);

         l_app_id                       VARCHAR2(10);
         l_coll_type                    VARCHAR2(100);
         l_doc_type                     VARCHAR2(100);
         l_coll_status                  VARCHAR2(100);

         l_attribute1                   VARCHAR2(150);
         l_attribute2                   VARCHAR2(150);
         l_attribute3                   VARCHAR2(150);
         l_attribute4                   VARCHAR2(150);
         l_attribute5                   VARCHAR2(150);
         l_attribute6                   VARCHAR2(150);
         l_attribute7                   VARCHAR2(150);
         l_attribute8                   VARCHAR2(150);
         l_attribute9                   VARCHAR2(150);
         l_attribute10                  VARCHAR2(150);
         l_attribute11                  VARCHAR2(150);
         l_attribute12                  VARCHAR2(150);
         l_attribute13                  VARCHAR2(150);
         l_attribute14                  VARCHAR2(150);
         l_attribute15                  VARCHAR2(150);

         l_init_date                    DATE;
         l_dattribute1                  DATE;
         l_dattribute2                  DATE;
         l_dattribute3                  DATE;
         l_dattribute4                  DATE;
         l_dattribute5                  DATE;



   BEGIN
         -- Sets the debug mode to be FILE
      --l_debug_mode := ecx_cln_debug_pub.Set_Debug_Mode('FILE');

      IF (l_Debug_Level <= 2) THEN
              ecx_cln_debug_pub.Add('============ENTERING ADD_COLLABORATION_EVENT_SUB============', 2);
      END IF;

      l_cln_ch_parameters                := p_event.getParameterList();

      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('----------- PARAMETERS OBTAINED ----------', 1);
      END IF;

      l_subscriber_list:= WF_EVENT.getValueForParameter('SUBSCRIBER_LIST',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Subscriber List                 ----'||l_subscriber_list, 1);
      END IF;

      IF(l_subscriber_list is not null and instr(l_subscriber_list,'CLN') = 0) THEN
              IF (l_Debug_Level <= 1) THEN
                ecx_cln_debug_pub.Add('Subscriber list is not null and CLN is not there in the list', 1);
              END IF;
              RETURN 'SUCCESS'; -- No need to consume this event
           END IF;


      l_xmlg_msg_id                 := WF_EVENT.getValueForParameter('XMLG_MESSAGE_ID',l_cln_ch_parameters);
      l_xmlg_msg_id                 := replace(l_xmlg_msg_id,'.',''); -- There is an issue with Workflow
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('XMLG Message ID                 ----'||l_xmlg_msg_id, 1);
      END IF;


      l_xmlg_internal_control_number:= WF_EVENT.getValueForParameter('XMLG_INTERNAL_CONTROL_NUMBER',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('XMLG Internal Control Number    ----'||l_xmlg_internal_control_number, 1);
      END IF;


      l_xmlg_transaction_type       := WF_EVENT.getValueForParameter('XMLG_TRANSACTION_TYPE',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('XMLG Ext Transaction Type       ----'||l_xmlg_transaction_type, 1);
      END IF;


      l_xmlg_transaction_subtype    := WF_EVENT.getValueForParameter('XMLG_TRANSACTION_SUBTYPE',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('XMLG Ext Transaction Sub Type   ----'||l_xmlg_transaction_subtype, 1);
      END IF;


      l_xmlg_int_transaction_type   := WF_EVENT.getValueForParameter('XMLG_INTERNAL_TXN_TYPE',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('XMLG Int Transaction Type       ----'||l_xmlg_int_transaction_type, 1);
      END IF;


      l_xmlg_int_transaction_subtype:= WF_EVENT.getValueForParameter('XMLG_INTERNAL_TXN_SUBTYPE',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('XMLG Int Transaction Sub Type   ----'||l_xmlg_int_transaction_subtype, 1);
      END IF;


      l_xmlg_document_id            := WF_EVENT.getValueForParameter('XMLG_DOCUMENT_ID',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('XMLG Document ID                ----'||l_xmlg_document_id, 1);
      END IF;


      l_doc_dir                     := WF_EVENT.getValueForParameter('DOCUMENT_DIRECTION',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Document Direction              ----'||l_doc_dir, 1);
      END IF;


      l_tr_partner_type             := WF_EVENT.getValueForParameter('TRADING_PARTNER_TYPE',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Trading Partner Type            ----'||l_tr_partner_type, 1);
      END IF;


      l_tr_partner_id               := WF_EVENT.getValueForParameter('TRADING_PARTNER_ID',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Trading Partner ID              ----'||l_tr_partner_id, 1);
      END IF;


      l_tr_partner_site             := WF_EVENT.getValueForParameter('TRADING_PARTNER_SITE',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Trading Partner Site            ----'||l_tr_partner_site, 1);
      END IF;


      l_sender_protocol             := WF_EVENT.getValueForParameter('SENDER_COMPONENT',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Sender Protocol                 ----'||l_sender_protocol, 1);
      END IF;


      l_ref_id                      := WF_EVENT.getValueForParameter('REFERENCE_ID',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Reference ID                    ----'||l_ref_id, 1);
      END IF;


      l_doc_no                      := WF_EVENT.getValueForParameter('DOCUMENT_NO',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Document Number                 ----'||l_doc_no, 1);
      END IF;


      l_org_id                      := To_Number(WF_EVENT.getValueForParameter('ORG_ID',l_cln_ch_parameters));
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Org ID                          ----'||l_org_id, 1);
      END IF;


      l_rel_no                      := WF_EVENT.getValueForParameter('RELEASE_NO',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Release Number                  ----'||l_rel_no, 1);
      END IF;


      l_doc_rev_no                  := WF_EVENT.getValueForParameter('DOCUMENT_REVISION_NO',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Document Revision Number        ----'||l_doc_rev_no, 1);
      END IF;


      l_partner_doc_no              := WF_EVENT.getValueForParameter('PARTNER_DOCUMENT_NO',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Partner Document No             ----'||l_partner_doc_no, 1);
      END IF;


      l_resend_count                := To_Number(WF_EVENT.getValueForParameter('RESEND_COUNT',l_cln_ch_parameters));
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Resend Count                    ----'||l_resend_count, 1);
      END IF;


      l_doc_creation_date           := CONVERT_TO_DATE(WF_EVENT.getValueForParameter('DOCUMENT_CREATION_DATE',l_cln_ch_parameters));
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Document Creation Date          ----'||l_doc_creation_date, 1);
      END IF;


      l_doc_revision_date           := CONVERT_TO_DATE(WF_EVENT.getValueForParameter('DOCUMENT_REVISION_DATE',l_cln_ch_parameters));
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Document Revision Date          ----'||l_doc_revision_date, 1);
      END IF;


      l_coll_pt                     := WF_EVENT.getValueForParameter('COLLABORATION_POINT',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Collaboration Point             ----'||l_coll_pt, 1);
      END IF;


      l_unique1                     := WF_EVENT.getValueForParameter('UNIQUE_ID1',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Unique ID1                      ----'||l_unique1, 1);
      END IF;


      l_unique2                     := WF_EVENT.getValueForParameter('UNIQUE_ID2',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Unique ID2                      ----'||l_unique2, 1);
      END IF;


      l_unique3                     := WF_EVENT.getValueForParameter('UNIQUE_ID3',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Unique ID3                      ----'||l_unique3, 1);
      END IF;


      l_unique4                     := WF_EVENT.getValueForParameter('UNIQUE_ID4',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Unique ID4                      ----'||l_unique4, 1);
      END IF;


      l_unique5                     := WF_EVENT.getValueForParameter('UNIQUE_ID5',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Unique ID5                      ----'||l_unique5, 1);
      END IF;


      l_rosettanet_check_required   := WF_EVENT.getValueForParameter('ROSETTANET_CHECK_REQUIRED',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Rosettanet Check Required       ----'||l_rosettanet_check_required, 1);
      END IF;


      l_doc_owner                   := To_Number(WF_EVENT.getValueForParameter('DOCUMENT_OWNER',l_cln_ch_parameters));
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Document Owner                  ----'||l_doc_owner, 1);
      END IF;

      l_owner_role                  := WF_EVENT.getValueForParameter('OWNER_ROLE',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Owner Role                      ----'||l_owner_role, 1);
      END IF;


      l_coll_id                     := To_Number(WF_EVENT.getValueForParameter('COLLABORATION_ID',l_cln_ch_parameters));
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Collaboration ID                ----'||l_coll_id, 1);
      END IF;


      l_disposition                 := WF_EVENT.getValueForParameter('DISPOSITION',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Disposition                     ----'||l_disposition, 1);
      END IF;


      l_org_ref                     := WF_EVENT.getValueForParameter('ORIGINATOR_REFERENCE',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Originator Reference            ----'||l_org_ref, 1);
      END IF;


      l_doc_status                  := WF_EVENT.getValueForParameter('DOCUMENT_STATUS',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Document Status                 ----'||l_doc_status, 1);
      END IF;


      l_msg_text                    := WF_EVENT.getValueForParameter('MESSAGE_TEXT',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Message Text                    ----'||l_msg_text, 1);
      END IF;

      l_collaboration_standard      := WF_EVENT.getValueForParameter('COLLABORATION_STANDARD',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Collaboration Standard           ----'||l_collaboration_standard, 1);
      END IF;


      l_xml_event_key              := WF_EVENT.getValueForParameter('XML_EVENT_KEY',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('XMLG Event Key                  ----'||l_xml_event_key, 1);
      END IF;


      l_app_id              := WF_EVENT.getValueForParameter('APPLICATION_ID',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Application ID                  ----'||l_app_id, 1);
      END IF;

      l_coll_type              := WF_EVENT.getValueForParameter('COLLABORATION_TYPE',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Collaboration Type              ----'||l_coll_type, 1);
      END IF;

      l_doc_type              := WF_EVENT.getValueForParameter('DOCUMENT_TYPE',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Document Type                   ----'||l_doc_type, 1);
      END IF;

      l_init_date              := CONVERT_TO_DATE(WF_EVENT.getValueForParameter('COLLABORATION_INITIATION_DATE',l_cln_ch_parameters));
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Initiation Date                 ----'||l_init_date, 1);
      END IF;

      l_coll_status              := WF_EVENT.getValueForParameter('COLLABORATION_STATUS',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Collaboration Status            ----'||l_coll_status, 1);
      END IF;

      l_attribute1             := WF_EVENT.getValueForParameter('ATTRIBUTE1',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE1                      ----'||l_attribute1, 1);
      END IF;

      l_attribute2             := WF_EVENT.getValueForParameter('ATTRIBUTE2',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE2                      ----'||l_attribute2, 1);
      END IF;

      l_attribute3             := WF_EVENT.getValueForParameter('ATTRIBUTE3',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE3                      ----'||l_attribute3, 1);
      END IF;

      l_attribute4             := WF_EVENT.getValueForParameter('ATTRIBUTE4',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE4                      ----'||l_attribute4, 1);
      END IF;

      l_attribute5             := WF_EVENT.getValueForParameter('ATTRIBUTE5',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE5                      ----'||l_attribute5, 1);
      END IF;

      l_attribute6             := WF_EVENT.getValueForParameter('ATTRIBUTE6',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE6                      ----'||l_attribute6, 1);
      END IF;

      l_attribute7             := WF_EVENT.getValueForParameter('ATTRIBUTE7',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE7                      ----'||l_attribute7, 1);
      END IF;

      l_attribute8             := WF_EVENT.getValueForParameter('ATTRIBUTE8',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE8                      ----'||l_attribute8, 1);
      END IF;

      l_attribute9             := WF_EVENT.getValueForParameter('ATTRIBUTE9',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE9                      ----'||l_attribute9, 1);
      END IF;

      l_attribute10            := WF_EVENT.getValueForParameter('ATTRIBUTE10',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE10                      ----'||l_attribute10, 1);
      END IF;

      l_attribute11            := WF_EVENT.getValueForParameter('ATTRIBUTE11',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE11                      ----'||l_attribute11, 1);
      END IF;

      l_attribute12            := WF_EVENT.getValueForParameter('ATTRIBUTE12',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE12                      ----'||l_attribute12, 1);
      END IF;

      l_attribute13            := WF_EVENT.getValueForParameter('ATTRIBUTE13',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE13                      ----'||l_attribute13, 1);
      END IF;

      l_attribute14            := WF_EVENT.getValueForParameter('ATTRIBUTE14',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE14                      ----'||l_attribute14, 1);
      END IF;

      l_attribute15            := WF_EVENT.getValueForParameter('ATTRIBUTE15',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE15                      ----'||l_attribute15, 1);
      END IF;

      l_dattribute1            := CONVERT_TO_DATE(WF_EVENT.getValueForParameter('DATTRIBUTE1',l_cln_ch_parameters));
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('DATTRIBUTE1                      ----'||l_dattribute1, 1);
      END IF;

      l_dattribute2            := CONVERT_TO_DATE(WF_EVENT.getValueForParameter('DATTRIBUTE2',l_cln_ch_parameters));
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('DATTRIBUTE2                      ----'||l_dattribute2, 1);
      END IF;

      l_dattribute3            := CONVERT_TO_DATE(WF_EVENT.getValueForParameter('DATTRIBUTE3',l_cln_ch_parameters));
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('DATTRIBUTE3                      ----'||l_dattribute3, 1);
      END IF;

      l_dattribute4            := CONVERT_TO_DATE(WF_EVENT.getValueForParameter('DATTRIBUTE4',l_cln_ch_parameters));
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('DATTRIBUTE4                      ----'||l_dattribute4, 1);
      END IF;

      l_dattribute5            := CONVERT_TO_DATE(WF_EVENT.getValueForParameter('DATTRIBUTE5',l_cln_ch_parameters));
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('DATTRIBUTE5                      ----'||l_dattribute5, 1);
      END IF;



      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('------------------------------------------', 1);
      END IF;



      IF ( UPPER(l_rosettanet_check_required) = 'FALSE') THEN
           l_rosettanet_check_required_b := FALSE;
      ELSE
           l_rosettanet_check_required_b := TRUE;
      END IF;


      IF ((l_resend_count > 0) AND ( l_resend_count IS NOT NULL )) THEN
           l_resend_flag   :=     'Y';
      END IF;

      IF (l_ref_id IS NULL ) THEN -- If reference ID is not passed by caller, get defualt XMLG OAG rf id and set it to global variable
          CLN_CH_COLLABORATION_PKG.g_xmlg_oag_application_ref_id  :=  Get_Reference_id(p_event);
      END IF;


      CLN_CH_COLLABORATION_PKG.ADD_COLLABORATION(
             x_return_status                  => l_return_status,
             x_msg_data                       => l_msg_data,
             p_coll_id                        => l_coll_id,
             p_app_id                         => l_app_id,
             p_ref_id                         => l_ref_id,
             p_rel_no                         => l_rel_no,
             p_doc_no                         => l_doc_no,
             p_doc_rev_no                     => l_doc_rev_no,
             p_xmlg_transaction_type          => l_xmlg_transaction_type,
             p_xmlg_transaction_subtype       => l_xmlg_transaction_subtype,
             p_xmlg_document_id               => l_xmlg_document_id,
             p_resend_flag                    => l_resend_flag,
             p_resend_count                   => l_resend_count,
             p_disposition                    => l_disposition,
             p_coll_status                    => l_coll_status,
             p_coll_type                      => l_coll_type,
             p_doc_type                       => l_doc_type,
             p_doc_dir                        => l_doc_dir,
             p_coll_pt                        => l_coll_pt,
             p_org_ref                        => l_org_ref,
             p_doc_status                     => l_doc_status,
             p_notification_id                => NULL,
             p_msg_text                       => l_msg_text,
             p_attr1                          => NULL,
             p_attr2                          => NULL,
             p_attr3                          => NULL,
             p_attr4                          => NULL,
             p_attr5                          => NULL,
             p_attr6                          => NULL,
             p_attr7                          => NULL,
             p_attr8                          => NULL,
             p_attr9                          => NULL,
             p_attr10                         => NULL,
             p_attr11                         => NULL,
             p_attr12                         => NULL,
             p_attr13                         => NULL,
             p_attr14                         => NULL,
             p_attr15                         => NULL,
             p_xmlg_msg_id                    => l_xmlg_msg_id,
             p_unique1                        => l_unique1,
             p_unique2                        => l_unique2,
             p_unique3                        => l_unique3,
             p_unique4                        => l_unique4,
             p_unique5                        => l_unique5,
             p_tr_partner_type                => l_tr_partner_type,
             p_tr_partner_id                  => l_tr_partner_id,
             p_tr_partner_site                => l_tr_partner_site,
             p_sender_component               => l_sender_protocol,
             p_rosettanet_check_required      => l_rosettanet_check_required_b,
             x_dtl_coll_id                    => l_dtl_coll_id,
             p_xmlg_internal_control_number   => l_xmlg_internal_control_number,
             p_partner_doc_no                 => l_partner_doc_no,
             p_org_id                         => l_org_id,
             p_init_date                      => l_init_date,
             p_doc_creation_date              => l_doc_creation_date,
             p_doc_revision_date              => l_doc_revision_date,
             p_doc_owner                      => l_doc_owner,
             p_xmlg_int_transaction_type      => l_xmlg_int_transaction_type,
             p_xmlg_int_transaction_subtype   => l_xmlg_int_transaction_subtype,
             p_xml_event_key                  => l_xml_event_key,
             p_collaboration_standard         => l_collaboration_standard,
             p_attribute1                     => l_attribute1,
             p_attribute2                     => l_attribute2,
             p_attribute3                     => l_attribute3,
             p_attribute4                     => l_attribute4,
             p_attribute5                     => l_attribute5,
             p_attribute6                     => l_attribute6,
             p_attribute7                     => l_attribute7,
             p_attribute8                     => l_attribute8,
             p_attribute9                     => l_attribute9,
             p_attribute10                    => l_attribute10,
             p_attribute11                    => l_attribute11,
             p_attribute12                    => l_attribute12,
             p_attribute13                    => l_attribute13,
             p_attribute14                    => l_attribute14,
             p_attribute15                    => l_attribute15,
             p_dattribute1                    => l_dattribute1,
             p_dattribute2                    => l_dattribute2,
             p_dattribute3                    => l_dattribute3,
             p_dattribute4                    => l_dattribute4,
             p_dattribute5                    => l_dattribute5,
             p_owner_role                     => l_owner_role  );



         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('COLLABORATION_DETAIL_ID got as  ----'||l_dtl_coll_id, 1);
                 ecx_cln_debug_pub.Add('RETURN_STATUS got as            ----'||l_return_status, 1);
                 ecx_cln_debug_pub.Add('MESSAGE_DATA got as             ----'||l_msg_data, 1);
         END IF;


         IF ( l_return_status <> 'S') THEN
              RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF (l_Debug_Level <= 2) THEN
                 ecx_cln_debug_pub.Add('============EXITING ADD_COLLABORATION_EVENT_SUB============', 2);
         END IF;

         RETURN 'SUCCESS'  ;

   EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
                 l_error_code   :=SQLCODE;
                 l_error_msg    :=SQLERRM;
                 IF (l_Debug_Level <= 4) THEN
                         ecx_cln_debug_pub.Add('Error:' || l_error_code || ':' || l_error_msg, 3);
                         ecx_cln_debug_pub.Add('============EXITING ADD_COLLABORATION_EVENT_SUB============', 2);
                 END IF;

            RETURN 'SUCCESS';

         WHEN OTHERS THEN
            l_error_code := SQLCODE;
            l_error_msg := SQLERRM;
            IF (l_Debug_Level <= 5) THEN
                    ecx_cln_debug_pub.Add('Error:' || l_error_code || ':' || l_error_msg, 3);
                    ecx_cln_debug_pub.Add('============EXITING ADD_COLLABORATION_EVENT_SUB============', 2);
            END IF;

            RETURN 'SUCCESS';

   END ADD_COLLABORATION_EVENT_SUB;





   -- Name
   --    NOTIFICATION_EVENT_SUB
   -- Purpose
   --    This is the public procedure which is used to raise the notification
   --    event.This procedure in turn calls CLN_NP_PROCESSOR_PKG.PROCESS_NOTIF_ACTIONS_EVT API.
   --
   -- Arguments
   --
   -- Notes
   --    No specific notes.

   FUNCTION NOTIFICATION_EVENT_SUB(
        p_subscription_guid             IN RAW,
        p_event                         IN OUT NOCOPY WF_EVENT_T
   ) RETURN VARCHAR2
   IS
      l_cln_ch_parameters               wf_parameter_list_t;
      l_subscriber_list                 VARCHAR2(1000);
      l_debug_mode                      VARCHAR2(255);

      -- key parameters finding the Collaboration ID
      l_coll_id                         NUMBER;

      l_xmlg_internal_control_number    VARCHAR2(100);

      l_xmlg_msg_id                     VARCHAR2(100);

      l_ref_id                          VARCHAR2(100);

      l_xmlg_transaction_type           VARCHAR2(100);
      l_xmlg_transaction_subtype        VARCHAR2(100);
      l_xmlg_int_transaction_type       VARCHAR2(100);
      l_xmlg_int_transaction_subtype    VARCHAR2(100);
      l_xmlg_document_id                VARCHAR2(256);
      l_doc_dir                         VARCHAR2(3);
      l_tr_partner_id                   VARCHAR2(30);
      l_tr_partner_type                 VARCHAR2(10);
      l_tr_partner_site                 VARCHAR2(30);

      l_application_id                  VARCHAR2(10);

      l_unique1                         VARCHAR2(30);
      l_unique2                         VARCHAR2(30);
      l_unique3                         VARCHAR2(30);
      l_unique4                         VARCHAR2(30);
      l_unique5                         VARCHAR2(30);

      -- extra parameters required for notification module
      l_notification_code               VARCHAR2(30);
      l_notification_desc               VARCHAR2(1000);
      l_notification_status             VARCHAR2(30);

      l_collaboration_pt                VARCHAR2(20);
      l_collaboration_std               VARCHAR2(30);
      l_collaboration_type              VARCHAR2(30);

      -- extra attributes for batch mode
      l_attribute_name			VARCHAR2(150);
      l_attribute_value			VARCHAR2(150);
      l_batch_mode			VARCHAR2(2);
      l_notif_receiver_role		VARCHAR2(100);

      l_return_status                   VARCHAR2(255);
      l_return_msg                      VARCHAR2(1000);

      l_error_code                      NUMBER;
      l_error_msg                       VARCHAR2(255);

   BEGIN
      -- Sets the debug mode to be FILE
      --l_debug_mode := ecx_cln_debug_pub.Set_Debug_Mode('FILE');

      IF (l_Debug_Level <= 2) THEN
              ecx_cln_debug_pub.Add('==========ENTERING NOTIFICATION_EVENT_SUB===========', 2);
      END IF;

      l_cln_ch_parameters           := p_event.getParameterList();

      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('----------- PARAMETERS OBTAINED ----------', 1);
      END IF;


      l_subscriber_list:= WF_EVENT.getValueForParameter('SUBSCRIBER_LIST',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Subscriber List                 ----'||l_subscriber_list, 1);
      END IF;

      IF(l_subscriber_list is not null and instr(l_subscriber_list,'CLN') = 0) THEN
              IF (l_Debug_Level <= 1) THEN
                ecx_cln_debug_pub.Add('Subscriber list is not null and CLN is not there in the list', 1);
              END IF;
              RETURN 'SUCCESS'; -- No need to consume this event
      END IF;


      l_xmlg_msg_id                 := WF_EVENT.getValueForParameter('XMLG_MESSAGE_ID',l_cln_ch_parameters);
      l_xmlg_msg_id                 := replace(l_xmlg_msg_id,'.',''); -- There is an issue with Workflow
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('XMLG Message ID                 ----'||l_xmlg_msg_id, 1);
      END IF;


      l_xmlg_internal_control_number:= WF_EVENT.getValueForParameter('XMLG_INTERNAL_CONTROL_NUMBER',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('XMLG Internal Control Number    ----'||l_xmlg_internal_control_number, 1);
      END IF;


      l_xmlg_transaction_type       := WF_EVENT.getValueForParameter('XMLG_TRANSACTION_TYPE',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('XMLG Ext Transaction Type       ----'||l_xmlg_transaction_type, 1);
      END IF;


      l_xmlg_transaction_subtype    := WF_EVENT.getValueForParameter('XMLG_TRANSACTION_SUBTYPE',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('XMLG Ext Transaction Sub Type   ----'||l_xmlg_transaction_subtype, 1);
      END IF;


      l_xmlg_int_transaction_type   := WF_EVENT.getValueForParameter('XMLG_INTERNAL_TXN_TYPE',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('XMLG Int Transaction Type       ----'||l_xmlg_int_transaction_type, 1);
      END IF;


      l_xmlg_int_transaction_subtype:= WF_EVENT.getValueForParameter('XMLG_INTERNAL_TXN_SUBTYPE',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('XMLG Int Transaction Sub Type   ----'||l_xmlg_int_transaction_subtype, 1);
      END IF;


      l_xmlg_document_id            := WF_EVENT.getValueForParameter('XMLG_DOCUMENT_ID',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('XMLG Document ID                ----'||l_xmlg_document_id, 1);
      END IF;


      l_doc_dir                     := WF_EVENT.getValueForParameter('DOCUMENT_DIRECTION',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Document Direction              ----'||l_doc_dir, 1);
      END IF;


      l_tr_partner_type             := WF_EVENT.getValueForParameter('TRADING_PARTNER_TYPE',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Trading Partner Type            ----'||l_tr_partner_type, 1);
      END IF;


      l_tr_partner_id               := WF_EVENT.getValueForParameter('TRADING_PARTNER_ID',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Trading Partner ID              ----'||l_tr_partner_id, 1);
      END IF;


      l_tr_partner_site             := WF_EVENT.getValueForParameter('TRADING_PARTNER_SITE',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Trading Partner Site            ----'||l_tr_partner_site, 1);
      END IF;


      l_coll_id                      := To_Number(WF_EVENT.getValueForParameter('COLLABORATION_ID',l_cln_ch_parameters));
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Collaboration ID                ----'||l_coll_id, 1);
      END IF;



      l_collaboration_pt            := WF_EVENT.getValueForParameter('COLLABORATION_POINT',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Collaboration Point             ----'||l_collaboration_pt, 1);
      END IF;


      l_unique1                     := WF_EVENT.getValueForParameter('UNIQUE_ID1',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Unique ID1                      ----'||l_unique1, 1);
      END IF;


      l_unique2                     := WF_EVENT.getValueForParameter('UNIQUE_ID2',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Unique ID2                      ----'||l_unique2, 1);
      END IF;

      l_unique3                     := WF_EVENT.getValueForParameter('UNIQUE_ID3',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Unique ID3                      ----'||l_unique3, 1);
      END IF;

      l_unique4                     := WF_EVENT.getValueForParameter('UNIQUE_ID4',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Unique ID4                      ----'||l_unique4, 1);
      END IF;

      l_unique5                     := WF_EVENT.getValueForParameter('UNIQUE_ID5',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Unique ID5                      ----'||l_unique5, 1);
      END IF;

      l_application_id               := WF_EVENT.getValueForParameter('APPLICATION_ID',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Application ID                  ----'||l_application_id, 1);
      END IF;

      l_notification_code           := WF_EVENT.getValueForParameter('NOTIFICATION_CODE',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('NOTIFICATION_CODE               ----'||l_notification_code, 1);
      END IF;

      l_notification_desc           := WF_EVENT.getValueForParameter('NOTIFICATION_DESC',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('NOTIFICATION_DESC               ----'||l_notification_desc, 1);
      END IF;

      l_notification_status         := WF_EVENT.getValueForParameter('NOTIFICATION_STATUS',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('NOTIFICATION_STATUS             ----'||l_notification_status, 1);
      END IF;

---------- For Batch Mode  -----------

      l_attribute_name         := WF_EVENT.getValueForParameter('ATTRIBUTE_NAME',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE_NAME                  ----'||l_attribute_name, 1);
      END IF;

      l_attribute_value         := WF_EVENT.getValueForParameter('ATTRIBUTE_VALUE',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('ATTRIBUTE_VALUE                 ----'||l_attribute_value, 1);
      END IF;

      l_batch_mode         := WF_EVENT.getValueForParameter('BATCH_MODE_REQD',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('BATCH_MODE_REQD                 ----'||l_batch_mode, 1);
      END IF;

      l_notif_receiver_role         := WF_EVENT.getValueForParameter('NOTIFICATION_RECEIVER_ROLE',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('NOTIFICATION_RECEIVER_ROLE      ----'||l_notif_receiver_role, 1);
      END IF;

      l_collaboration_std         := WF_EVENT.getValueForParameter('COLLABORATION_STANDARD',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('COLLABORATION_STANDARD          ----'||l_collaboration_std, 1);
      END IF;

      l_collaboration_type         := WF_EVENT.getValueForParameter('COLLABORATION_TYPE',l_cln_ch_parameters);
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('COLLABORATION_TYPE              ----'||l_collaboration_type, 1);
      END IF;

      SELECT UPPER(l_batch_mode) INTO l_batch_mode FROM DUAL ;

      IF (l_batch_mode = 'Y') THEN

      		IF (l_Debug_Level <= 1) THEN
        	      ecx_cln_debug_pub.Add('Calling CLN_NP_PROCESSOR_PKG.PROCESS_NOTIF_ACTIONS_BATCH_EVT', 1);
      		END IF;


      		CLN_NP_PROCESSOR_PKG.PROCESS_NOTIF_BATCH_EVT(
      	          x_return_status                        => l_return_status,
      	          x_msg_data                             => l_return_msg,
		  p_attribute_name			 => l_attribute_name,
		  p_attribute_value			 => l_attribute_value,
		  p_notification_receiver		 => l_notif_receiver_role,
		  p_application_id                       => l_application_id,
		  p_collaboration_std  		         => l_collaboration_std,
		  p_collaboration_type  		 => l_collaboration_type,
	  	  p_collaboration_point  		 => l_collaboration_pt,
      	          p_notification_code                    => l_notification_code,
      	          p_notification_msg                     => l_notification_desc,
      	          p_notification_status                  => l_notification_status );

      		IF (l_Debug_Level <= 1) THEN
      		        ecx_cln_debug_pub.Add('RETURN_STATUS got as     ----'||l_return_status, 1);
      		        ecx_cln_debug_pub.Add('MESSAGE_DATA got as      ----'||l_return_msg, 1);
      		END IF;


      		IF ( l_return_status <> 'S') THEN
      		     RAISE FND_API.G_EXC_ERROR;
      		END IF;

      		IF (l_Debug_Level <= 2) THEN
      		        ecx_cln_debug_pub.Add('============EXITING NOTIFICATION_EVENT_SUB============', 2);
      		END IF;

      		RETURN 'SUCCESS' ;
      	END IF;
-------------

      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Calling CLN_NP_PROCESSOR_PKG.PROCESS_NOTIF_ACTIONS_EVT', 1);
      END IF;


      CLN_NP_PROCESSOR_PKG.PROCESS_NOTIF_ACTIONS_EVT(
                x_return_status                        => l_return_status,
                x_msg_data                             => l_return_msg,
                p_coll_id                              => l_coll_id,
                p_xmlg_transaction_type                => l_xmlg_transaction_type,
                p_xmlg_transaction_subtype             => l_xmlg_transaction_subtype,
                p_xmlg_int_transaction_type            => l_xmlg_int_transaction_type,
                p_xmlg_int_transaction_subtype         => l_xmlg_int_transaction_subtype,
                p_xmlg_document_id                     => l_xmlg_document_id,
                p_doc_dir                              => l_doc_dir,
                p_tr_partner_type                      => l_tr_partner_type,
                p_tr_partner_id                        => l_tr_partner_id,
                p_tr_partner_site                      => l_tr_partner_site,
                p_xmlg_msg_id                          => l_xmlg_msg_id,
                p_application_id                       => l_application_id,
                p_unique1                              => l_unique1,
                p_unique2                              => l_unique2,
                p_unique3                              => l_unique3,
                p_unique4                              => l_unique4,
                p_unique5                              => l_unique5,
                p_xmlg_internal_control_number         => l_xmlg_internal_control_number,
                p_collaboration_pt                     => l_collaboration_pt,
                p_notification_code                    => l_notification_code,
                p_notification_desc                    => l_notification_desc,
                p_notification_status                  => l_notification_status,
                p_notification_event                   => p_event );

      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('RETURN_STATUS got as     ----'||l_return_status, 1);
              ecx_cln_debug_pub.Add('MESSAGE_DATA got as      ----'||l_return_msg, 1);
      END IF;


      IF ( l_return_status <> 'S') THEN
           RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (l_Debug_Level <= 2) THEN
              ecx_cln_debug_pub.Add('============EXITING NOTIFICATION_EVENT_SUB============', 2);
      END IF;

      RETURN 'SUCCESS' ;

   EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
         l_error_code   :=SQLCODE;
         l_error_msg    :=SQLERRM;

         IF (l_Debug_Level <= 4) THEN
                 ecx_cln_debug_pub.Add('Error:' || l_error_code || ':' || l_error_msg || ':' || l_return_msg, 3);
                 ecx_cln_debug_pub.Add('============EXITING NOTIFICATION_EVENT_SUB============', 2);
         END IF;

         RETURN 'SUCCESS';

      WHEN OTHERS THEN
         l_error_code := SQLCODE;
         l_error_msg := SQLERRM;
         IF (l_Debug_Level <= 5) THEN
                 ecx_cln_debug_pub.Add('Error:' || l_error_code || ':' || l_error_msg, 3);
                 ecx_cln_debug_pub.Add('============EXITING NOTIFICATION_EVENT_SUB============', 2);
         END IF;

         RETURN 'SUCCESS';

   END NOTIFICATION_EVENT_SUB;


END CLN_CH_EVENT_SUBSCRIPTION_PKG;

/
