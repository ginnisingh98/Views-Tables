--------------------------------------------------------
--  DDL for Package Body M4U_UCC_ADAPTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."M4U_UCC_ADAPTER" AS
/* $Header: m4uinaqb.pls 120.0 2005/05/24 16:19:08 appldev noship $ */
        l_debug_level       NUMBER;
        G_PKG_NAME CONSTANT VARCHAR2(30) := 'm4u_ucc_adapter';
        -- Name
        --      set_aq_correlation
        -- Purpose
        --      sets the PROTOCOL_TYPE event attribute in the ECX_EVENT_MESSAGE item attribute
        --      This is in-turn used to set AQ correlation-id by the queue-handler
        -- Arguments
        --      itemtype                => WF item type
        --      itemkey                 => WF item key
        --      actid                   => WF act id
        --      funcmode                => WF func mode
        --      resultout               => result param
        -- Notes
        --      none
        FUNCTION pushtoAQ( clob_payload CLOB) RETURN VARCHAR2
        IS
                q_name          VARCHAR2(100);
                q_schema_name   VARCHAR2(50);
                jms_msg         SYS.AQ$_JMS_TEXT_MESSAGE;
                l_event_key     VARCHAR2(30) ;
                msg_id          RAW(16);
                l_msgid         RAW(16);
                l_rownum        NUMBER;
                l_nextval       NUMBER;
                l_event_name    VARCHAR2(256);
                l_event         wf_event_t;
                l_parameter_list WF_PARAMETER_LIST_T;
                enqueue_options dbms_aq.enqueue_options_t;
                msg_properties  dbms_aq.message_properties_t;
                x_out_msg_id    RAW(16);

        BEGIN
                q_schema_name   := 'APPLSYS'; -- code workaround, for GSCC error, needs to be resolved subsequently.
                q_name          := 'WF_JMS_IN';
                --q_name          := 'WF_JAVA_DEFERRED';
                l_event_name    := 'oracle.apps.m4u.inbound.ALL';

                IF (l_Debug_Level <= 2) THEN
                        cln_debug_pub.Add('=========== Entering m4u_ucc_adapter.pushtoAQ =========== ',2);
                END IF;

                SELECT  SYS_GUID()
                INTO            msg_id
                FROM            DUAL;

                SELECT  M4U_WLQID_S.nextval
                INTO            l_nextval
                FROM            DUAL;

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Payload clob created',1);
                END IF;

                l_parameter_list :=
                        WF_PARAMETER_LIST_T(
                                WF_PARAMETER_T('ECX_PARAMETER1',                0               ),
                                WF_PARAMETER_T('ECX_PARAMETER2',                'M4U'           ),
                                WF_PARAMETER_T('ECX_TRANSACTION_TYPE',          'M4U'           ),
                                WF_PARAMETER_T('ECX_TRANSACTION_SUBTYPE',       'GENERIC'       ),
                                WF_PARAMETER_T('ECX_PARTY_SITE_ID',             'UCCNET_HUB'    ),
                                WF_PARAMETER_T('ECX_DOCUMENT_ID',               l_nextval       ),
                                WF_PARAMETER_T('ECX_MSGID',                     msg_id          ),
                                WF_PARAMETER_T('ECX_MESSAGE_STANDARD',          'UCCNET'        )
                                                );

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Event created with the following paramters'  ,1);
                        cln_debug_pub.Add('ECX_PARAMETER1               - 0'            ,1);
                        cln_debug_pub.Add('ECX_PARAMETER2               - M4U'          ,1);
                        cln_debug_pub.Add('ECX_TRANSACTION_TYPE         - M4U'          ,1);
                        cln_debug_pub.Add('ECX_TRANSACTION_SUBTYPE      - GENERIC'      ,1);
                        cln_debug_pub.Add('ECX_PARTY_SITE_ID            - UCCNET_HUB'   ,1);
                        cln_debug_pub.Add('ECX_DOCUMENT_ID              - ' || l_nextval,1);
                        cln_debug_pub.Add('ECX_MSGID                    - ' || msg_id   ,1);
                        cln_debug_pub.Add('ECX_MESSAGE_STANDARD         - UCCNET'       ,1);
                END IF;



                wf_event_t.initialize(l_event);
                l_event.seteventname(l_event_name);
                l_event.seteventkey(l_nextval);
                l_event.seteventdata(clob_payload);
                l_event.setParameterList(l_parameter_list);

                wf_event_ojmstext_qh.SERIALIZE(l_event,jms_msg);

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Event to be enqueued initialized',2);
                END IF;

                dbms_aq.enqueue(
                        queue_name         => q_schema_name || '.' || q_name,
                        enqueue_options    => enqueue_options,
                        message_properties => msg_properties,
                        payload            => jms_msg,
                        msgid              => x_out_msg_id
                                );

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('dbms_aq.enqueue msgid returned - ' || x_out_msg_id,2);
                END IF;


                IF (l_Debug_Level <= 2) THEN
                        cln_debug_pub.Add('=========== Exiting m4u_ucc_adapter.pushtoAQ  normal - Success =========== ',2);
                END IF;

                RETURN 'SUCCESS';
  EXCEPTION
        WHEN OTHERS THEN
                IF (l_Debug_Level <= 5) THEN
                        cln_debug_pub.Add('Error                : ' || SQLCODE || ':' || SQLERRM, 5);
                END IF;
                IF (l_Debug_Level <= 2) THEN
                        cln_debug_pub.Add('=========== Exiting m4u_ucc_adapter.pushtoAQ  - on Exception =========== ',2);
                END IF;

                RETURN 'F:'||SQLERRM;
  END;
  BEGIN
        l_debug_level   := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));
END m4u_ucc_adapter;

/
