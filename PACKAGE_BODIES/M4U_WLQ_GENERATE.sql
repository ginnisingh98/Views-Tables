--------------------------------------------------------
--  DDL for Package Body M4U_WLQ_GENERATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."M4U_WLQ_GENERATE" AS
/* $Header: m4uwlqgb.pls 120.1 2005/06/09 01:50:58 appldev  $ */

        G_PKG_NAME CONSTANT     VARCHAR2(30)    := 'm4u_wlq_generate';
        l_debug_level           NUMBER;

        -- Name
        --      raise_wlq_event
        -- Purpose
        --      This procedure is called from a concurrent program.
        --      The the event 'oracle.apps.m4u.worklistquery' is raised with the supplied event parameters
        --      The sequence m4u_wlqid_sequence is used to obtain unique event key.
        -- Arguments
        --      x_err_buf                       => API param for concurrent program calls
        --      x_retcode                       => API param for concurrent program calls
        --      p_wlq_type                      => The type of notifications from Worklist to be queried
        --      p_wlq_status                    => The status of notifications to be queried
        -- Notes
        --      Status is expected to be UnREAD to avoid duplicate processing of notifications.
        PROCEDURE raise_wlq_event(
                                x_errbuf        OUT NOCOPY VARCHAR2,
                                x_retcode       OUT NOCOPY NUMBER,
                                p_wlq_type      IN VARCHAR2,
                                p_wlq_status    IN VARCHAR2
                                )
        IS
                l_event_key             VARCHAR2(50);
                l_event_parameters      wf_parameter_list_t;
                l_error_code            VARCHAR2(50);
                l_error_msg             VARCHAR2(50);

                l_wlq_type              VARCHAR2(50);
                l_wlq_status            VARCHAR2(50);
        BEGIN

                IF (l_debug_Level <= 2) THEN
                        cln_debug_pub.Add('M4U:----- Entering RAISE_WLQ_EVENT  ------- ',2);
                END IF;

                -- Parameters received
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('== PARAMETERS RECEIVED FROM CONCURRENT PROGRAM== ',1);
                        cln_debug_pub.Add('p_wlq_tye            - '||p_wlq_type  ,1);
                        cln_debug_pub.Add('p_wlq_status         - '||p_wlq_status,1);
                        cln_debug_pub.Add('=====================================',1);
                END IF;

                IF (p_wlq_type = 'Batch Notification')THEN
                        l_wlq_type := 'BatchNotification';
                ELSIF (p_wlq_type = 'Catalogue Item Confirmation')THEN
                        l_wlq_type := 'CATALOGUE_ITEM_CONFIRMATION';
                ELSIF (p_wlq_type = 'Request for Catalogue Item Notification')THEN
                        l_wlq_type :='REQUEST_FOR_NOTIFICATION';
                END IF;

                IF (p_wlq_status = 'All')THEN
                        l_wlq_status    := 'ALL';
                ELSIF (p_wlq_status = 'Unread')THEN
                        l_wlq_status    := 'UNREAD' ;
                END IF;

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('== PARAMETERS DEFAULTED == ',1);
                        cln_debug_pub.Add('l_wlq_tye            - '||l_wlq_type  ,1);
                        cln_debug_pub.Add('l_wlq_status         - '||l_wlq_status,1);
                        cln_debug_pub.Add('=====================================',1);
                END IF;

                -- obtain a unique event-id
                SELECT  m4u_wlqid_s.NEXTVAL
                INTO    l_event_key
                FROM    dual;

                l_event_key := 'M4U_WLQ_' || l_event_key;

                -- pass Concurrent program parameters as event parameters, to be used in outboud xml generation map.

                l_event_parameters := wf_parameter_list_t();

                wf_event.AddParameterToList(
                                        p_name          => 'ECX_PARAMETER1',
                                        p_value         => l_event_key,
                                        p_parameterlist => l_event_parameters   );

                wf_event.AddParameterToList(
                                        p_name          => 'ECX_PARAMETER2',
                                        p_value         => l_wlq_status,
                                        p_parameterlist => l_event_parameters   );

                wf_event.AddParameterToList(
                                        p_name          => 'ECX_PARAMETER3',
                                        p_value         => l_wlq_type,
                                        p_parameterlist => l_event_parameters   );

                wf_event.AddParameterToList(
                                        p_name          => 'ECX_TRANSACTION_TYPE',
                                        p_value         => 'M4U',
                                        p_parameterlist => l_event_parameters   );
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ECX_TRANSACTION_TYPE                 - M4U',1);
                END IF;

                wf_event.AddParameterToList(
                                        p_name          => 'ECX_TRANSACTION_SUBTYPE',
                                        p_value         => 'WLQ',
                                        p_parameterlist => l_event_parameters   );
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ECX_TRANSACTION_SUBTYPE              - GBREGQRY',1);
                END IF;

                wf_event.AddParameterToList(
                                        p_name          => 'ECX_DOCUMENT_ID',
                                        p_value         => l_event_key,
                                        p_parameterlist => l_event_parameters   );
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ECX_DOCUMENT_ID                      - '||l_event_key,1);
                END IF;

                wf_event.AddParameterToList(
                                        p_name          => 'ECX_EVENT_KEY',
                                        p_value         => l_event_key,
                                        p_parameterlist => l_event_parameters   );
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ECX_EVENT_KEY                        - '||l_event_key,1);
                END IF;

                wf_event.AddParameterToList(
                                        p_name          => 'M4U_CLN_COLL_TYPE',
                                        p_value         => 'M4U_WLQ',
                                        p_parameterlist => l_event_parameters   );
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('M4U_CLN_COLL_TYPE                    - '||l_event_key,1);
                END IF;


                wf_event.AddParameterToList(
                                        p_name          => 'M4U_DOC_NO',
                                        p_value         => l_event_key,
                                        p_parameterlist => l_event_parameters   );
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('M4U_DOC_NO                           - '||l_event_key,1);
                END IF;

                wf_event.AddParameterToList(
                                        p_name          => 'M4U_CLN_DOC_TYPE',
                                        p_value         => 'M4U_WLQ',
                                        p_parameterlist => l_event_parameters   );
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('M4U_CLN_DOC_TYPE                     - M4U_WLQ',1);
                END IF;


                wf_event.AddParameterToList(
                                        p_name          => 'ATTRIBUTE1',
                                        p_value         => m4u_ucc_utils.g_host_gln,
                                        p_parameterlist => l_event_parameters   );
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ATTRIBUTE1                           - '||m4u_ucc_utils.g_host_gln,1);
                END IF;


                wf_event.AddParameterToList(
                                        p_name          => 'ATTRIBUTE5',
                                        p_value         => m4u_ucc_utils.g_supp_gln,
                                        p_parameterlist => l_event_parameters   );
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ATTRIBUTE5                           - '||m4u_ucc_utils.g_supp_gln,1);
                END IF;


                wf_event.AddParameterToList(
                                        p_name          => 'ATTRIBUTE12',
                                        p_value         => l_event_key,
                                        p_parameterlist => l_event_parameters   );
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ATTRIBUTE12                          - '||l_event_key,1);
                END IF;


                -- set event parameters, end

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('== Raising Event oracle.apps.m4u.outboundwf.generate == ',1);
                        cln_debug_pub.Add('p_event_key          - '||l_event_key ,1);
                END IF;


                -- raise event to trigger outbound wlq generation WF
                wf_event.raise(
                                p_event_name            => 'oracle.apps.m4u.outboundwf.generate',
                                p_event_key             => l_event_key,
                                p_parameters            => l_event_parameters
                                );


                -- return with success
                x_errbuf        := 'Successful';
                x_retcode       := 0;

                IF (l_Debug_Level <= 2) THEN
                        cln_debug_pub.Add('M4U:------- Exiting RAISE_WLQ_EVENT  - Normal --------- ',2);
                END IF;


        -- Exception Handling
        EXCEPTION
                WHEN OTHERS THEN
                        l_error_code       :=SQLCODE;
                        l_error_msg        :=SQLERRM;
                        x_retcode          :=2 ;
                        x_errbuf           :='Unexpected Error in raise Query-Worklist event - '||l_error_code||' : '||l_error_msg;
                IF (l_Debug_Level <= 5) THEN
                        cln_debug_pub.Add(x_errbuf,5);
                END IF;
                IF (l_Debug_Level <= 2) THEN
                        cln_debug_pub.Add('------- Exiting RAISE_WLQ_EVENT  - Exception --------- ',2);
                END IF;
        END;

        BEGIN
                l_debug_level           := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));
END m4u_wlq_generate;

/
