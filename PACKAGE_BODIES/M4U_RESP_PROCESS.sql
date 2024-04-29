--------------------------------------------------------
--  DDL for Package Body M4U_RESP_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."M4U_RESP_PROCESS" AS
/* $Header: m4urespb.pls 120.2 2006/05/11 03:29:27 bsaratna noship $ */


        g_debug_level           NUMBER ;
        G_PKG_NAME CONSTANT     VARCHAR2(30)    := 'm4u_resp_process';


        -- Name
        --      add_error_to_cln_hist
        -- Purpose
        --      This generic procedure is used to add error messages to CLN History
        -- Arguments
        --      p_error_code                    - UCCnet specific error code
        --      p_error_message                 - UCCnet generated error description
        --      p_error_type                    - 'ERROR',(haven't seen anything else)
        --      p_collab_detail_id              - collaboration-history detail id to be updated
        --      p_ucc_doc_unique_id             - uccnet generated document identifer for inbound payload
        --      p_xmlg_internal_control_no      - XMLG ICN for debug purpose only
        --      x_return_status                 - return_status (S-Success/F-failure)
        --      x_msg_data                      - return message (if any)
        -- Notes
        --      Adds error-information to collaboration history detail messages

        PROCEDURE add_error_to_cln_hist(
                                p_error_code                    IN VARCHAR2,
                                p_error_type                    IN VARCHAR2,
                                p_error_message                 IN VARCHAR2,
                                p_collab_detail_id              IN VARCHAR2,
                                p_ucc_doc_unique_id             IN VARCHAR2,
                                p_xmlg_internal_control_no      IN VARCHAR2,
                                x_return_status                 OUT NOCOPY      VARCHAR2,
                                x_msg_data                      OUT NOCOPY      VARCHAR2 )

        IS
                l_error_code            NUMBER;
                l_error_msg             VARCHAR2(2000);
                l_event_key             VARCHAR2(255);
                l_event_name            VARCHAR2(100);
                l_error_description     VARCHAR2(2000);
                l_event_parameters      wf_parameter_list_t;
        BEGIN
                l_event_name := 'oracle.apps.cln.ch.collaboration.addmessage';

                IF (g_debug_Level <= 2) THEN
                        cln_debug_pub.Add('===============================================', 2);
                        cln_debug_pub.Add('Entering m4u_resp_process.add_error_to_cln_hist', 2);
                END IF;

                IF (g_debug_Level <= 1) THEN
                        cln_debug_pub.Add('-- Received parameters -- ', 1);
                        cln_debug_pub.Add('p_error_code                         --' || p_error_code , 1);
                        cln_debug_pub.Add('p_error_type                         --' || p_error_type , 1);
                        cln_debug_pub.Add('p_error_message                      --' || p_error_message, 1);
                        cln_debug_pub.Add('p_collab_detail_id                   --' || p_collab_detail_id, 1);
                        cln_debug_pub.Add('p_ucc_doc_unique_id                  --' || p_ucc_doc_unique_id, 1);
                        cln_debug_pub.Add('p_xmlg_internal_control_no           --' || p_xmlg_internal_control_no, 1);
                END IF;

                l_event_parameters      := wf_parameter_list_t();

                l_error_description     := p_error_type || ', ' || p_error_code || ', ' ||  p_error_message;

                --create unique key for each event using CLN sequence
                SELECT cln_collaboration_msg_id_s.nextval INTO l_event_key FROM dual ;

                IF (g_debug_Level <= 1) THEN
                        cln_debug_pub.Add('Raising Add Message Event ', 1);
                        cln_debug_pub.Add('p_event_key                  -- ' || l_event_key, 1);
                        cln_debug_pub.Add('COLLABORATION_DETAIL_ID      -- ' || p_collab_detail_id, 1);
                        cln_debug_pub.Add('DETAIL_MESSAGE               -- ' || l_error_description, 1);
                        cln_debug_pub.Add('p_event_name                 -- ' || l_event_name, 1);
                END IF;

                -- set event parameters for CLN Add Message Event
                wf_event.AddParameterToList(
                                        p_name          => 'COLLABORATION_DETAIL_ID',
                                        p_value         => p_collab_detail_id,
                                        p_parameterlist => l_event_parameters   );

                wf_event.AddParameterToList(
                                        p_name          => 'DETAIL_MESSAGE',
                                        p_value         => l_error_description,
                                        p_parameterlist => l_event_parameters   );


                -- add CLN event to add error messages as to collaboration history
                wf_event.raise(
                                p_event_name            => l_event_name,
                                p_event_key                     => l_event_key,
                                p_parameters            => l_event_parameters
                                );

                -- return success
                x_return_status := 'S';
                x_msg_data      := l_event_name || ' raised';


                IF (g_debug_Level <= 2) THEN
                        cln_debug_pub.Add('Exiting m4u_resp_process.add_error_to_cln_hist - normal',2);
                        cln_debug_pub.Add('=======================================================',2);
                END IF;

        EXCEPTION
              WHEN OTHERS THEN

                        -- log exception and exit.
                        l_error_code    := SQLCODE;
                        l_error_msg     := SQLERRM;
                        x_return_status := 'F';
                        x_msg_data      := ' - Unexpected error in m4u_resp_process.add_error_to_cln_hist - ' || l_error_code || ':' || l_error_msg;

                        IF (g_debug_Level <= 5) THEN
                                cln_debug_pub.Add(l_error_code || ':' || l_error_msg, 4);
                        END IF;

                        IF (g_debug_Level <= 2) THEN
                                cln_debug_pub.Add('Exiting m4u_resp_process.add_error_to_cln_hist - exception',2);
                                cln_debug_pub.Add('==========================================================',2);
                        END IF;

        END add_error_to_cln_hist;


        -- Name
        --      process_cic_notification
        -- Purpose
        --      This process is called for each CIC notification received from a Retailer(in worklist query response)
        --      The Worklist-Query of the type/topic CatalogueItemConfirmation/RoutedDocument
        --      contains CIC notifications issued by retailers
        --      The ego_uccnet_events table, and CLN Collaboration need to be updated
        --      When the catalogueItemConfirmationState is "REJECTED|SYNCHRONIZED" an event needs to be
        --      raised to move the item-publication WF which is blocked at this stage.
        -- Arguments
        --      p_gtin                          => GTIN of item notified
        --      p_supp_gln                      => Supplier GLN
        --      p_target_market                 => Code of target market
        --      p_retailer_gln                  => GLN of ratiler to whom notification is sent
        --      p_cic_unique_id                 => Unique creator ID of CIC document generated by reatiler
        --      p_cic_state                     => State of CIC notification
        --      p_cin_unique_id                 => Unique creator of CIN for which this CIC was generated
        --      p_ucc_doc_unique_id             => Unique document identifier of wLQ response generated by UCCnet
        --      p_xmlg_internal_colntrol_no     => XMLG internal control no. from map
        --      x_return_status                 => Collaboration history detail-id, to be used for further processing
        --      x_return_status                 => return_status (s-Success/F-failure)
        --      x_msg_data                      => return message
        -- Notes
        --      (GTIN + Supplier GLN + Target Code) identify a unique item registered in the UCCnet registry.
        --      p_cin_unique_id = CLN Id for collaboration of outbound document

        PROCEDURE process_cic_notification(
                                p_gtin                                  IN      VARCHAR2,
                                p_supp_gln                              IN      VARCHAR2,
                                p_target_market                         IN      vARCHAR2,
                                p_retailer_gln                          IN      VARCHAR2,
                                p_cic_unique_id                         IN      VARCHAR2,
                                p_cic_state                             IN      VARCHAR2,
                                p_cin_unique_id                         IN      VARCHAR2,
                                p_ucc_doc_unique_id                     IN      VARCHAR2,
                                p_xmlg_internal_control_no              IN      NUMBER,
                                x_collab_detail_id                      OUT     NOCOPY  NUMBER,
                                x_return_status                         OUT     NOCOPY  VARCHAR2,
                                x_msg_data                              OUT     NOCOPY  VARCHAR2 )
        IS
                l_error_code            NUMBER;
                l_error_msg             VARCHAR2(2000);
                l_disposition           VARCHAR2(50);
                l_fnd_msg               VARCHAR2(50);
                l_doc_status            VARCHAR2(50);
                l_return_status         VARCHAR2(50);
                l_coll_status           VARCHAR2(50);
                l_msg_data              VARCHAR2(2000);
                l_msg_count             VARCHAR2(50);
                l_notif_mesg            VARCHAR2(400);
                l_event_name            VARCHAR2(100);
                l_event_key             VARCHAR2(30);
                l_apc_disposition       VARCHAR2(30);
                l_event_params          wf_parameter_list_t;
        BEGIN
                l_event_name := 'oracle.apps.cln.np.processnotification';
                IF (g_debug_Level <= 2) THEN
                        cln_debug_pub.Add('-- Entering m4u_resp_process.process_cic_notification -- ', 2);
                END IF;

                IF (g_debug_Level <= 1) THEN
                        cln_debug_pub.Add('-- with paramters -- ', 1);
                        cln_debug_pub.Add('p_gtin                       -- ' || p_gtin, 1);
                        cln_debug_pub.Add('p_supp_gln                   -- ' || p_supp_gln, 1);
                        cln_debug_pub.Add('p_target_market              -- ' || p_target_market, 1);
                        cln_debug_pub.Add('p_retialer_gln               -- ' || p_retailer_gln, 1);
                        cln_debug_pub.Add('p_cic_unique_id              -- ' || p_cic_unique_id, 1);
                        cln_debug_pub.Add('p_cic_state                  -- ' || p_cic_state, 1);
                        cln_debug_pub.Add('p_cin_unique_id              -- ' || p_cin_unique_id, 1);
                        cln_debug_pub.Add('p_ucc_doc_unique_id          -- ' || p_ucc_doc_unique_id, 1);
                        cln_debug_pub.Add('p_xmlg_internal_control_no   -- ' || p_xmlg_internal_control_no, 1);
                END IF;



                -- set CLN Dispostion, CLN Coll Status based on CIC state
                IF (UPPER(p_cic_state) = 'REVIEW')            THEN
                        l_disposition      := 'REVIEWED';
                        l_coll_status      := 'INITIATED';
                        l_fnd_msg          := 'M4U_CIC_INITIATED';
                        l_apc_disposition  := 'REVIEW';
                ELSIF (UPPER(p_cic_state) = 'SYNCHRONISED')   THEN
                        l_disposition      := 'SYNCH';
                        l_coll_status      := 'COMPLETED';
                        l_fnd_msg          := 'M4U_CIC_COMPLETED';
                        l_apc_disposition  := 'SYNCHRONIZED';
                ELSIF (UPPER(p_cic_state) = 'ACCEPTED')       THEN
                        l_disposition      := 'ACCEPTED';
                        l_coll_status      := 'INITIATED';
                        l_fnd_msg          := 'M4U_CIC_INITIATED';
                        l_apc_disposition  := 'ACCEPTED';
                ELSIF (UPPER(p_cic_state) = 'REJECTED')       THEN
                        l_disposition      := 'REJECTED';
                        l_coll_status      := 'ERROR';
                        l_fnd_msg          := 'M4U_CIC_REJECTED';
                        l_apc_disposition  := 'REJECTED';
                END IF;

                l_doc_status := 'SUCCESS';


                -- Make API call to update APC event disposition
                IF (g_debug_Level <= 1) THEN
                        cln_debug_pub.Add('-- Calling API EGO_UCCNET_EVENTS_PUB.UPDATE_EVENT_DISPOSITION --',1);
                        cln_debug_pub.Add(' disposition_code  -- '|| l_apc_disposition,1);
                        cln_debug_pub.Add(' disposition_date  -- '|| sysdate,1);
                        cln_debug_pub.Add(' p_cln_id          -- '|| p_cin_unique_id,1);
                END IF;


                EGO_UCCNET_EVENTS_PUB.UPDATE_EVENT_DISPOSITION
                (
                        p_api_version           => 1.0,
                        p_commit                => FND_API.g_FALSE,
                        p_init_msg_list         => FND_API.G_FALSE,
                        p_cln_id                => p_cin_unique_id,
                        p_disposition_code      => l_apc_disposition,
                        p_disposition_date      => sysdate,
                        x_return_status         => l_return_status,
                        x_msg_count             => l_msg_count,
                        x_msg_data              => l_msg_data
                );

                IF (g_debug_Level <= 1) THEN
                        cln_debug_pub.Add('-- UPDATE_EVENT_DISPOSITION returned --',1);
                        cln_debug_pub.Add(' x_return_status     -- '|| l_return_status,1);
                        cln_debug_pub.Add(' x_msg_count         -- '|| l_msg_count,1);
                        cln_debug_pub.Add(' x_msg_data          -- '|| l_msg_data,1);
                END IF;

                -- Direct call needed, since CLN Detail Id, is required for further processing
                -- of map., CLN will defualt the rest of the parameters.
                IF (g_debug_Level <= 1) THEN
                        cln_debug_pub.add('updating collaboration history  for cln_id   - ' || p_cin_unique_id,1);
                END IF;

                cln_ch_collaboration_pkg.update_collaboration(
                        x_return_status                  => x_return_status,
                        x_msg_data                       => x_msg_data,
                        p_coll_id                        => p_cin_unique_id,
                        p_msg_text                       => l_fnd_msg,
                        p_xmlg_msg_id                    => NULL,
                        p_xmlg_transaction_type          => 'M4U',
                        p_xmlg_transaction_subtype       => 'RESP_CIC',
                        p_xmlg_int_transaction_type      => 'M4U',
                        p_xmlg_int_transaction_subtype   => 'RESP_CIC',
                        p_doc_dir                        => 'IN',
                        p_doc_type                       => 'M4U_RESP_CIC',
                        p_disposition                    => l_disposition,
                        p_doc_status                     => l_doc_status,
                        p_coll_status                    => l_coll_status,
                        p_xmlg_document_id               => NULL,
                        p_xmlg_internal_control_number   => p_xmlg_internal_control_no,
                        p_tr_partner_type                => m4u_ucc_utils.c_party_type,
                        p_tr_partner_id                  => m4u_ucc_utils.g_party_id,
                        p_tr_partner_site                => m4u_ucc_utils.g_party_site_id,
                        p_attribute2                     => p_target_market,
                        p_attribute5                     => p_supp_gln,
                        p_attribute6                     => p_retailer_gln,
                        p_attribute8                     => p_ucc_doc_unique_id,
                        p_attribute10                    => p_cic_unique_id,
                        p_attribute11                    => p_cic_state,
                        p_doc_no                         => p_gtin,
                        p_dattribute1                    => sysdate,
                        p_rosettanet_check_required      => false,
                        x_dtl_coll_id                    => x_collab_detail_id  );

                IF (g_debug_Level <= 1) THEN
                        cln_debug_pub.add('collaboration history updated for cln_id     - ' || p_cin_unique_id,1);
                        cln_debug_pub.add('Collab_detail_id     - ' || x_collab_detail_id,1);
                        cln_debug_pub.add('x_return_status      - ' || x_return_status,1);
                        cln_debug_pub.add('x_msg_data           - ' || x_msg_data,1);
                END IF;
                x_msg_data      :=   x_msg_data || ' ; EGO API update - ' || l_msg_data ;

                IF x_return_status <> 'S' THEN
                        x_msg_data := 'Failure occured while processing CIC message in Query Worklist response - ' || x_msg_data;
                END IF;

                l_notif_mesg    := 'Catalogue Item Confirmation received with following details';

                l_event_params  := wf_parameter_list_t();

                wf_event.AddParameterToList(
                                        p_name          => 'COLLABORATION_ID',
                                        p_value         => p_cin_unique_id,
                                        p_parameterlist => l_event_params   );

                wf_event.AddParameterToList(
                                        p_name          => 'COLLABORATION_POINT',
                                        p_value         => 'APPS',
                                        p_parameterlist => l_event_params   );

                wf_event.AddParameterToList(
                                        p_name          => 'APPLICATION_ID',
                                        p_value         => m4u_ucc_utils.c_resp_appl_id,
                                        p_parameterlist => l_event_params   );

                wf_event.AddParameterToList(
                                        p_name          => 'NOTIFICATION_CODE',
                                        p_value         => 'M4UCIC',
                                        p_parameterlist => l_event_params   );

                wf_event.AddParameterToList(
                                        p_name          => 'NOTIFICATION_STATUS',
                                        p_value         => l_coll_status,
                                        p_parameterlist => l_event_params   );

                wf_event.AddParameterToList(
                                        p_name          => 'NOTIFICATION_DESC',
                                        p_value         => l_notif_mesg,
                                        p_parameterlist => l_event_params   );


                l_event_key     := 'RESP_CIC_' || p_cic_unique_id;

                IF (g_debug_Level <= 2) THEN
                        cln_debug_pub.add('--- raising Business Event ---',1);
                        cln_debug_pub.add('Event-name  - ' || l_event_name,1);
                        cln_debug_pub.add('event-value -'  || l_event_key ,1);
                END IF;

                -- raise event to trigger CLN Notifcations
                wf_event.raise(
                                p_event_name            => l_event_name,
                                p_event_key             => l_event_key,
                                p_parameters            => l_event_params
                                );

                IF (g_debug_Level <= 2) THEN
                        cln_debug_pub.add('Exiting m4u_resp_process.process_cic_notification - normal',2);
                        cln_debug_pub.add('==========================================================',2);
                END IF;
        EXCEPTION
                WHEN OTHERS THEN
                        -- log exception and exit.
                        l_error_code            := SQLCODE;
                        l_error_msg             := SQLERRM;
                        x_return_status         := 'F';
                        x_msg_data              := ' - Unexpected error occred while processing CIC message from Query Worklist response - ' || l_error_code || ':' || l_error_msg;


                        IF (g_debug_Level <= 5) THEN
                                cln_debug_pub.add(l_error_code || ':' || l_error_msg, 5);
                        END IF;

                        IF (g_debug_Level <= 2) THEN
                                cln_debug_pub.add('Exiting m4u_resp_process.process_cic_notification - exception',2);
                                cln_debug_pub.add('=============================================================',2);
                        END IF;

        END process_cic_notification;


        -- Name
        --      process_cic_additional_info
        -- Purpose
        --      This process is called to cater for additional attributes obtained in
        --      CIC notification received from a Retailer(in worklist query response)

        PROCEDURE process_cic_additional_info(
                                p_cln_id                IN  NUMBER,
                                p_cic_code              IN  VARCHAR2,
                                p_cic_description       IN  VARCHAR2,
                                p_cic_action_needed     IN  VARCHAR2,
                                p_collab_detail_id      IN  NUMBER,
                                x_return_status         OUT NOCOPY VARCHAR2,
                                x_msg_data              OUT NOCOPY VARCHAR2 )
        IS
                l_error_code            NUMBER;
                l_msg_count             VARCHAR2(50);
                l_return_status         VARCHAR2(50);

                l_error_msg             VARCHAR2(2000);
                l_coll_dtl_msg          VARCHAR2(2000);
                l_msg_data              VARCHAR2(2000);

                --l_add_cic_info          EGO_UCCNET_EVENTS_PVT.ADD_CIC_INFO_TBL_TYPE;
                --l_add_cic_info          EGO_UCCNET_EVENTS_PVT.ADD_CIC_INFO_TYPE;

        BEGIN
                IF (g_debug_Level <= 2) THEN
                        cln_debug_pub.Add('-- Entering m4u_resp_process.process_cic_additional_info -- ', 2);
                END IF;

                IF (g_debug_Level <= 1) THEN
                        cln_debug_pub.Add('-- with paramters -- ', 1);
                        cln_debug_pub.Add('p_cln_id                -- ' || p_cln_id, 1);
                        cln_debug_pub.Add('p_cic_code              -- ' || p_cic_code, 1);
                        cln_debug_pub.Add('p_cic_description       -- ' || p_cic_description, 1);
                        cln_debug_pub.Add('p_cic_action_needed     -- ' || p_cic_action_needed, 1);
                        cln_debug_pub.Add('p_collab_detail_id      -- ' || p_collab_detail_id, 1);
                END IF;

                -- adding the values for the ADD_CIC_INFO_TBL_TYPE type
                IF (g_debug_Level <= 1) THEN
                        cln_debug_pub.Add('Adding the values for the ADD_CIC_INFO_TBL_TYPE type', 1);
                END IF;


                IF (g_debug_Level <= 1) THEN
                        cln_debug_pub.Add('-- Calling EGO_UCCNET_EVENTS_PUB.ADD_ADDITIONAL_CIC_INFO-- ', 1);
                END IF;

                ego_uccnet_events_pub.ADD_ADDITIONAL_CIC_INFO (
                        p_api_version           => 1.0
                       ,p_commit                => FND_API.g_FALSE
                       ,p_init_msg_list         => FND_API.g_FALSE
                       ,p_cln_id                => p_cln_id
                       ,p_cic_code              => p_cic_code
                       ,p_cic_description       => p_cic_description
                       ,p_cic_action_needed     => p_cic_action_needed
                       ,x_return_status         => l_return_status
                       ,x_msg_count             => l_msg_count
                       ,x_msg_data              => l_msg_data
                );

                IF (g_debug_Level <= 1) THEN
                        cln_debug_pub.Add('-- ADD_ADDITIONAL_CIC_INFO returned --',1);
                        cln_debug_pub.Add(' x_return_status     -- '|| l_return_status,1);
                        cln_debug_pub.Add(' x_msg_count         -- '|| l_msg_count,1);
                        cln_debug_pub.Add(' x_msg_data          -- '|| l_msg_data,1);
                END IF;

                -- defaulting the message for the add collaboration msg API
                IF (g_debug_Level <= 1) THEN
                        cln_debug_pub.Add('-- Defaulting the value for add collaboration msg ', 1);
                END IF;

                l_coll_dtl_msg := 'Desc - '||p_cic_description||
                                  '  '||
                                  'Action -  '||p_cic_action_needed;

                IF (g_debug_Level <= 1) THEN
                        cln_debug_pub.Add('-- l_coll_dtl_msg  '||l_coll_dtl_msg, 1);
                END IF;


                -- Direct call needed, since CLN Detail Id, is required for further processing
                -- of map., CLN will defualt the rest of the parameters.
                IF (g_debug_Level <= 1) THEN
                        cln_debug_pub.add('updating collaboration history messages for cln_dtl_id   - ' || p_collab_detail_id,1);
                END IF;


                cln_ch_collaboration_pkg.ADD_COLLABORATION_MESSAGES(
                         x_return_status        => x_return_status,
                         x_msg_data             => x_msg_data,
                         p_dtl_coll_id          => p_collab_detail_id,
                         p_ref1                 => p_cic_code,
                         p_dtl_msg              => l_coll_dtl_msg);

                IF (g_debug_Level <= 1) THEN
                        cln_debug_pub.add('collaboration history messages updated for cln_dtl_id     - ' || p_collab_detail_id,1);
                        cln_debug_pub.add('x_return_status      - ' || x_return_status,1);
                        cln_debug_pub.add('x_msg_data           - ' || x_msg_data,1);
                END IF;

                x_msg_data      :=   x_msg_data || ' Collaboration Add Messages update - ' || l_msg_data ;

                IF x_return_status <> 'S' THEN
                        x_msg_data := 'Failure occured while processing CIC message in Query Worklist response - ' || x_msg_data;
                END IF;

                IF (g_debug_Level <= 2) THEN
                        cln_debug_pub.add('Exiting m4u_resp_process.process_cic_additional_info - normal',2);
                        cln_debug_pub.add('==========================================================',2);
                END IF;
        EXCEPTION
                WHEN OTHERS THEN
                        -- log exception and exit.
                        l_error_code            := SQLCODE;
                        l_error_msg             := SQLERRM;
                        x_return_status         := 'F';
                        x_msg_data              := ' - Unexpected error occred while processing CIC message from Query Worklist response - ' || l_error_code || ':' || l_error_msg;


                        IF (g_debug_Level <= 5) THEN
                                cln_debug_pub.add(l_error_code || ':' || l_error_msg, 5);
                        END IF;

                        IF (g_debug_Level <= 2) THEN
                                cln_debug_pub.add('Exiting m4u_resp_process.process_cic_additional_info - exception',2);
                                cln_debug_pub.add('=============================================================',2);
                        END IF;

        END process_cic_additional_info;


        --      process_cic_trade_item
        -- Purpose
        --      This process is called if the optional trade-item information is sent along with the CIC document
        --      The Worklist-Query of the type/topic CatalogueItemConfirmation/RoutedDocument
        --        contains CIC notifications issued by retailers
        --      No processing is defined for this, dummy procedure call
        -- Arguments
        --      p_gtin                          => GTIN of item received as part of CIC
        --      p_supp_gln                      => Supplier GLN of item received as part of CIC
        --      p_target_market                 => Target market code of item received as part of CIC
        --      p_reailter_gln                  => GLN of retailer who generated the CIC
        --      p_cic_unique_id                 => uniquecreatorID of CIC document
        --      p_cic_state                     => State of CIC
        --      p_cin_unique_id                 => uniqueCreatorId of CIN for which this CIC is generated
        --      p_ucc_doc_unique_id             => uniqueCreatorId of UCCnet generated WLQ response
        --      p_xmlg_internal_colntrol_no     => XMLG map ICN
        --      x_collab_detail_id              => Collaboration history detail-id, to be used for further processing
        --      x_return_status                 => return_status (s-Success/F-failure)
        --      x_msg_data                      => return message
        -- Notes
        --      (GTIN + Supplier GLN + Target Code) identify a unique item registered in the UCCnet registry.

        PROCEDURE process_cic_trade_item(
                p_gtin                          IN      VARCHAR2,
                p_supp_gln                      IN      VARCHAR2,
                p_target_market                 IN      vARCHAR2,
                p_retailer_gln                  IN      VARCHAR2,
                p_cic_unique_id                 IN      VARCHAR2,
                p_cic_state                     IN      VARCHAR2,
                p_cin_unique_id                 IN      VARCHAR2,
                p_ucc_doc_unique_id             IN      VARCHAR2,
                p_xmlg_internal_control_no      IN      NUMBER,
                x_collab_detail_id              OUT     NOCOPY  NUMBER,
                x_return_status                 OUT     NOCOPY  VARCHAR2,
                x_msg_data                      OUT     NOCOPY  VARCHAR2 )
        IS
                l_error_code                    NUMBER;
                l_error_msg                     VARCHAR2(2000);
        BEGIN


                IF (g_debug_Level <= 2) THEN
                        cln_debug_pub.Add('==================================================', 2);
                        cln_debug_pub.Add('Entering - m4u_resp_process.process_cic_trade_item', 2);
                END IF;



                IF (g_debug_Level <= 1) THEN
                        cln_debug_pub.Add('-- Received parameters -- ', 1);
                        cln_debug_pub.Add('p_gtin                        --' || p_gtin, 1);
                        cln_debug_pub.Add('p_supp_gln                    --' || p_supp_gln, 1);
                        cln_debug_pub.Add('p_target_market               --' || p_target_market, 1);
                        cln_debug_pub.Add('p_retailer_gln                --' || p_retailer_gln, 1);
                        cln_debug_pub.Add('p_cic_unique_id               --' || p_cic_unique_id, 1);
                        cln_debug_pub.Add('p_cic_state                   --' || p_cic_state, 1);
                        cln_debug_pub.Add('p_cin_unique_id               --' || p_cin_unique_id, 1);
                        cln_debug_pub.Add('p_ucc_doc_unique_id           --' || p_ucc_doc_unique_id, 1);
                        cln_debug_pub.Add('p_xmlg_internal_control_no    --' || p_xmlg_internal_control_no, 1);
                END IF;

                x_return_status := 'S';
                x_msg_data      := 'CIC trade_item succesfully processed';

                IF (g_debug_Level <= 2) THEN
                        cln_debug_pub.add('Exiting process_cic_trade_item - normal',2);
                        cln_debug_pub.add('=======================================',2);
                END IF;

        EXCEPTION
              WHEN OTHERS THEN

                        -- log exception and exit.
                        l_error_code            := SQLCODE;
                        l_error_msg             := SQLERRM;
                        x_return_status         := 'F';
                        x_msg_data              := ' - Unexpected error while Processing CIC trade-item information, in Query Worklist Response - ' || l_error_code || ':' || l_error_msg;

                        IF (g_debug_Level <= 5) THEN
                                cln_debug_pub.add(l_error_code || ':' || l_error_msg, 4);
                        END IF;

                        IF (g_debug_Level <= 2) THEN
                                cln_debug_pub.add('Exiting m4u_resp_process.process_cic_trade_item - exception',2);
                                cln_debug_pub.add('===========================================================',2);
                        END IF;

        END process_cic_trade_item;


        -- Name
        --      process_CIC_fication
        -- Purpose
        --      This process is called for each RCIR command in a transaction batch.
        --      The Worklist-query response contains status of each of the RCIR command
        --      The ego_uccnet_events table, and CLN Collaboration need to be updated
        --    The Collaboration Detail Id is an out parameter, to be used subsequently for updating error messsages.
        -- Arguments
        --      p_gtin                          => The GTIN of the Item published in the Batch
        --      p_supp_gln                      => Unique GLN of Supplier
        --      p_target_market                 => target market to which the item is to be published
        --      p_rcir_batch_id                 => The Batch_Id of the Batch in which the RCIR command was sent
        --      p_rcir_command_success          => TRUE/FALSE flag, indicates if Item-Registration was successful
        --      p_rcir_command_unique_id        => Unique Creartor Id of RCIR command (command level)
        --      p_rcir_command_validation_key   => Unique validation key, received for successful registration.
        --      p_ucc_doc_unique_id             => Unique UCCnet generated identifier for the document
        --      p_xmlg_internal_control_no      => XMLG Generated Unique Id for Document
        --      x_collab_detail_id              => The collab_detail_id returned by CLN Update CH API call.
        --      x_return_status                 => return_status (s-Success/F-failure)
        --      x_msg_data                      => return message
        -- Notes
        --      (GTIN + Supplier GLN + Target Code) identify a unique item registered in the UCCnet registry.
        PROCEDURE process_rcir_notification(
                                p_gtin                          IN      VARCHAR2,
                                p_supp_gln                      IN      VARCHAR2,
                                p_target_market                 IN      VARCHAR2,
                                p_rcir_batch_id                 IN      VARCHAR2,
                                p_rcir_command_unique_id        IN      VARCHAR2,
                                p_rcir_command_success          IN      VARCHAR2,
                                p_rcir_command_validation_key   IN      VARCHAR2,
                                p_ucc_doc_unique_id             IN      VARCHAR2,
                                p_xmlg_internal_control_no      IN      NUMBER,
                                x_collab_detail_id              OUT     NOCOPY  NUMBER,
                                x_return_status                 OUT     NOCOPY  VARCHAR2,
                                x_msg_data                      OUT     NOCOPY  VARCHAR2 )
        IS
                l_error_code    NUMBER;
                l_error_msg     VARCHAR2(2000);
                l_return_status VARCHAR2(50);
                l_disposition   VARCHAR2(50);
                l_msg_data      VARCHAR2(2000);
                l_msg_text      VARCHAR2(50);
                l_msg_count     VARCHAR2(50);
                l_coll_status   VARCHAR2(50);
                l_doc_status    VARCHAR2(50);
                l_fnd_msg       VARCHAR2(50);
                l_apc_disposition VARCHAR2(50);
        BEGIN

                IF (g_debug_Level <= 2) THEN
                        cln_debug_pub.Add('=====================================', 2);
                        cln_debug_pub.Add('Entering -- process_rcir_notification', 2);
                END IF;

                IF (g_debug_Level <= 1) THEN
                        cln_debug_pub.Add('-- Received parameters               -- ', 1);
                        cln_debug_pub.Add('p_gtin                                       --' || p_gtin, 1);
                        cln_debug_pub.Add('p_supp_gln                           --' || p_supp_gln, 1);
                        cln_debug_pub.Add('p_target_market                      --' || p_target_market, 1);
                        cln_debug_pub.Add('p_rcir_batch_id                              --' || p_rcir_batch_id, 1);
                        cln_debug_pub.Add('p_rcir_command_unique_id             --' || p_rcir_command_unique_id, 1);
                        cln_debug_pub.Add('p_rcir_command_success               --' || p_rcir_command_success, 1);
                        cln_debug_pub.Add('p_rcir_command_validation_key        --' || p_rcir_command_validation_key, 1);
                        cln_debug_pub.Add('p_ucc_doc_unique_id                  --' || p_ucc_doc_unique_id, 1);
                        cln_debug_pub.Add('p_xmlg_internal_control_no           --' || p_xmlg_internal_control_no, 1);
                END IF;


                -- set CLN Disposition, CLN Coll Status, CLN Doc status, CLN Message Text
                IF (UPPER(p_rcir_command_success)   = 'TRUE') THEN
                        l_disposition   := 'ACCEPTED' ;
                        l_msg_text      := 'COMPLETED';
                        l_coll_status   := 'COMPLETED';
                        l_doc_status    := 'SUCCESS';
                        l_fnd_msg       := 'M4U_RCIR_SUCCESS';
                        l_apc_disposition := 'PROCESSED';
                ELSE
                        l_disposition   := 'FAILED' ;
                        l_msg_text      := 'REJECTED' ;
                        l_coll_status   := 'ERROR';
                        l_doc_status    := 'ERROR';
                        l_fnd_msg       := 'M4U_RCIR_FAILURE';
                        l_apc_disposition := 'FAILED';
                END IF;



                IF (g_debug_Level <= 1) THEN
                        cln_debug_pub.Add('--- updating following columns of ego_uccnet_events --',1);
                        cln_debug_pub.Add(' disposition_code  -- '|| l_apc_disposition,1);
                        cln_debug_pub.Add(' disposition_date  -- '|| sysdate,1);
                        cln_debug_pub.Add(' last_updated_by   -- '|| 1,1);
                        cln_debug_pub.Add(' last_updated_date -- '|| sysdate ,1);
                        cln_debug_pub.Add('-- where - CLN Id  -- '|| p_rcir_command_unique_id,1);
                END IF;

                -- Make API call to update APC event disposition
                IF (g_debug_Level <= 1) THEN
                        cln_debug_pub.Add('-- Calling API EGO_UCCNET_EVENTS_PUB.UPDATE_EVENT_DISPOSITION --',1);
                        cln_debug_pub.Add(' disposition_code    -- '|| l_disposition,1);
                        cln_debug_pub.Add(' disposition_date    -- '|| sysdate,1);
                        cln_debug_pub.Add(' p_cln_id            -- '|| p_rcir_command_unique_id,1);
                END IF;

                EGO_UCCNET_EVENTS_PUB.UPDATE_EVENT_DISPOSITION
                (
                        p_api_version           => 1.0,
                        p_commit                => FND_API.g_FALSE,
                        p_init_msg_list         => FND_API.G_FALSE,
                        p_cln_id                => p_rcir_command_unique_id,
                        p_disposition_code      => l_apc_disposition,
                        p_disposition_date      => sysdate,
                        x_return_status         => x_return_status,
                        x_msg_count             => l_msg_count,
                        x_msg_data              => l_msg_data
                );


                IF (g_debug_Level <= 1) THEN
                        cln_debug_pub.Add('-- UPDATE_EVENT_DISPOSITION returned --',1);
                        cln_debug_pub.Add(' x_return_status-- '|| x_return_status,1);
                        cln_debug_pub.Add(' x_msg_count    -- '|| l_msg_count,1);
                        cln_debug_pub.Add(' x_msg_data     -- '|| l_msg_data,1);
                END IF;

                -- Direct call needed, since CLN Detail Id, is required for further processing
                -- of map., CLN will defualt the rest of the parameters.
                IF (g_debug_Level <= 1) THEN
                        cln_debug_pub.add('updating collaboration history  for cln_id   - ' || p_rcir_command_unique_id,1);
                END IF;

                cln_ch_collaboration_pkg.update_collaboration(
                        x_return_status                  => x_return_status,
                        x_msg_data                       => x_msg_data,
                        p_coll_id                        => p_rcir_command_unique_id,
                        p_msg_text                       => l_fnd_msg,
                        p_xmlg_msg_id                    => NULL,
                        p_xmlg_transaction_type          => 'M4U',
                        p_xmlg_transaction_subtype       => 'RESP_BATCH',
                        p_xmlg_int_transaction_type      => 'M4U',
                        p_xmlg_int_transaction_subtype   => 'RESP_BATCH',
                        p_doc_dir                        => 'IN',
                        p_doc_type                       => 'M4U_RESP_BATCH',
                        p_disposition                    => l_disposition,
                        p_doc_status                     => l_doc_status,
                        p_coll_status                    => l_coll_status,
                        p_xmlg_document_id               => NULL,
                        p_xmlg_internal_control_number   => p_xmlg_internal_control_no,
                        p_tr_partner_type                => m4u_ucc_utils.c_party_type,
                        p_tr_partner_id                  => m4u_ucc_utils.g_party_id,
                        p_tr_partner_site                => m4u_ucc_utils.g_party_site_id,
                        p_attribute2                     => p_target_market,
                        p_attribute5                     => p_supp_gln,
                        p_attribute8                     => p_ucc_doc_unique_id,
                        p_attribute9                     => p_rcir_command_validation_key,
                        p_dattribute1                    => sysdate,
                        p_attribute11                    => p_rcir_command_success,
                        p_doc_no                         => p_gtin,
                        p_rosettanet_check_required      => false,
                        x_dtl_coll_id                    => x_collab_detail_id  );



                IF (g_debug_Level <= 1) THEN
                        cln_debug_pub.Add('Update collaboration returned');
                        cln_debug_pub.Add('Collaboration detail id      - ' || x_collab_detail_id , 1);
                        cln_debug_pub.Add('Return status                - ' || x_return_status, 1);
                        cln_debug_pub.Add('Message data                 - ' || x_msg_data, 1);
                END IF;

                x_msg_data      :=   x_msg_data || ' ; EGO API update - ' || l_msg_data ;

                IF x_return_status <> 'S' THEN
                        x_msg_data := 'Failure occured while processing RCIR Batch Notification in Query Worklist Response - ' || x_msg_data;
                END IF;

                IF (g_debug_Level <= 2) THEN
                        cln_debug_pub.Add('Exiting m4u_resp_process.process_rcir_notification - normal',2);
                        cln_debug_pub.Add('===========================================================',2);
                END IF;

        EXCEPTION
              WHEN OTHERS THEN
                        -- log exception and exit.
                        l_error_code    := SQLCODE;
                        l_error_msg     := SQLERRM;
                        x_return_status := 'F';
                        x_msg_data      := ' - Unexpected error in Processing RCIR notification in Query Worklist Response - ' || l_error_code || ':' || l_error_msg;


                        IF (g_debug_Level <= 5) THEN
                                cln_debug_pub.Add(l_error_code || ':' || l_error_msg, 4);
                        END IF;

                        IF (g_debug_Level <= 2) THEN
                                cln_debug_pub.Add('Exiting m4u_resp_process.process_rcir_notification - exception',2);
                                cln_debug_pub.Add('==============================================================',2);
                        END IF;

        END process_rcir_notification;


        -- Name
        --      process_rcir_batch_list
        -- Purpose
        --      process all RCIR-BATCHes received in a Worlist-query Batch Notification reponse
        --      raise event, for each batch-id to move corresponding WF block
        -- Arguments
        --      p_rcir_batch_id_list            => distinct RCIR batch_ids which have been processed
        --                                         are concatenated into a string, delimited by ':' string.
        --      p_rcir_batch_count              => Count of number of Batch_ids in the above string
        --      p_ucc_doc_unique_id             => unique UCCnet generated document identifer
        --      p_xmlg_internal_control_no      => XML Gateway generated Internal Control Number for document
        --      x_return_status                 => return_status (s-Success/F-failure)
        --      x_msg_data                      => return message
        -- Notes
        --      Sample input to this procedure would be
        --      p_rcir_batch_id_list - rcir1@rcir2@rcir3@
        --      p_rcir_batch_count   - 3

        PROCEDURE process_rcir_batch_list(
                                p_rcir_batch_id_list            IN      VARCHAR2,
                                p_rcir_batch_count              IN      NUMBER,
                                p_ucc_doc_unique_id             IN      VARCHAR2,
                                p_xmlg_internal_control_no      IN      vARCHAR2,
                                x_return_status                 OUT NOCOPY      VARCHAR2,
                                x_msg_data                              OUT NOCOPY      VARCHAR2 )
        IS
                l_prev_pos              NUMBER;
                l_cur_pos               NUMBER;
                l_batch_id              VARCHAR2(50);
                l_error_code            NUMBER;
                l_error_msg             VARCHAR2(2000);
                l_notif_mesg            VARCHAR2(400);
                l_event_name            VARCHAR2(100);
                l_event_key             VARCHAR2(50);
                l_owner_role            VARCHAR2(50);
                l_event_params          wf_parameter_list_t;

        BEGIN
                l_event_name := 'oracle.apps.cln.np.processnotification';

                IF (g_debug_Level <= 2) THEN
                        cln_debug_pub.Add('=================================================', 2);
                        cln_debug_pub.Add('Entering m4u_resp_process.process_rcir_batch_list', 2);
                END IF;

                IF (g_debug_Level <= 1) THEN
                        cln_debug_pub.Add('-- with paramerters --', 1);
                        cln_debug_pub.Add('p_rcir_batch_id_list -- ' || p_rcir_batch_id_list, 1);
                        cln_debug_pub.Add('p_rcir_batch_count   -- ' || p_rcir_batch_count, 1);
                        cln_debug_pub.Add('p_rcir_batch_count   -- ' || p_ucc_doc_unique_id, 1);
                        cln_debug_pub.Add('p_rcir_batch_count   -- ' || p_xmlg_internal_control_no, 1);
                END IF;

                l_event_params          := wf_parameter_list_t();
                l_prev_pos              := 1;

                -- for each RCIR Batch_Id present in the DSV string
                FOR i in 1 .. p_rcir_batch_count LOOP
                        -- parsing logic begins
                        l_cur_pos       := INSTR(p_rcir_batch_id_list,'@',1,i);
                        l_batch_id      := SUBSTR(p_rcir_batch_id_list,l_prev_pos,l_cur_pos-l_prev_pos);
                        l_prev_pos      := l_cur_pos+1;
                        -- parsing logic ends,

                        -- now variable l_batch_id, contains the next RCIR batch_id to process
                        IF (g_debug_Level <= 1) THEN
                                cln_debug_pub.add('processing batch_id - ' || l_batch_id, 1);
                        END IF;

                        BEGIN
                                SELECT  owner_role
                                INTO    l_owner_role
                                FROM    cln_coll_hist_hdr
                                WHERE   attribute12 = l_batch_id AND rownum < 2
                                        AND xmlg_transaction_type = 'M4U';
                        EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                        l_owner_role := fnd_profile.value('CLN_ADMINISTRATOR');
                        END;

                        IF (g_debug_Level <= 1) THEN
                                cln_debug_pub.add('Batch owner role obtained as -- '|| l_owner_role, 1);
                        END IF;

                        l_notif_mesg    := 'RCIR Batch status received';

                        l_event_params  := wf_parameter_list_t();

                        wf_event.AddParameterToList(
                                p_name          => 'ATTRIBUTE_NAME',
                                p_value         => 'ATTRIBUTE12',
                                p_parameterlist => l_event_params   );

                        wf_event.AddParameterToList(
                                p_name          => 'ATTRIBUTE_VALUE',
                                p_value         => l_batch_id,
                                p_parameterlist => l_event_params  );

                        wf_event.AddParameterToList(
                                p_name          => 'BATCH_MODE_REQD',
                                p_value         => 'Y',
                                p_parameterlist => l_event_params   );


                        wf_event.AddParameterToList(
                                p_name          => 'COLLABORATION_POINT',
                                p_value         => 'APPS',
                              p_parameterlist   => l_event_params   );

                        wf_event.AddParameterToList(
                                p_name          => 'COLLABORATION_STANDARD',
                                p_value         => 'UCCNET',
                                p_parameterlist => l_event_params   );

                        wf_event.AddParameterToList(
                                p_name          => 'APPLICATION_ID',
                                p_value         => m4u_ucc_utils.c_resp_appl_id,
                                p_parameterlist => l_event_params   );

                        wf_event.AddParameterToList(
                                p_name          => 'NOTIFICATION_CODE',
                                p_value         => 'M4UBATCH',
                                p_parameterlist => l_event_params   );

                        wf_event.AddParameterToList(
                                p_name          => 'NOTIFICATION_STATUS',
                                p_value         => 'SUCCESS',
                                p_parameterlist => l_event_params   );

                        wf_event.AddParameterToList(
                                p_name          => 'NOTIFICATION_DESC',
                                p_value         => l_notif_mesg,
                                p_parameterlist => l_event_params   );

                        wf_event.AddParameterToList(
                                p_name          => 'NOTIFICATION_RECEIVER_ROLE',
                                p_value         => l_owner_role,
                                p_parameterlist => l_event_params   );

                        l_event_key := 'RESP_BATCH_' || l_batch_id;


                        IF (g_debug_Level <= 2) THEN
                                cln_debug_pub.add('--- raising Business Event ---',1);
                                cln_debug_pub.add('Event-name  - ' || l_event_name,1);
                                cln_debug_pub.add('event-value -'  || l_event_key ,1);
                        END IF;

                        -- raise event to trigger CLN Notifcations
                        wf_event.raise(
                                p_event_name            => l_event_name,
                                p_event_key             => l_event_key,
                                p_parameters            => l_event_params
                                       );




                        IF (g_debug_Level <= 1) THEN
                                cln_debug_pub.Add('Raising event name - ' || l_event_name, 1);
                                cln_debug_pub.Add('        event key -- ' || l_batch_id, 1);
                        END IF;
                END LOOP;



                x_return_status := 'S';
                x_msg_data      := 'RCIR Batch-list succesfully processed';

                IF (g_debug_Level <= 2) THEN
                        cln_debug_pub.Add('Exiting m4u_resp_process.process_rcir_batch_list - normal',2);
                        cln_debug_pub.Add('=========================================================',2);
                END IF;

        EXCEPTION
                WHEN OTHERS THEN
                        -- log exception and exit.

                        l_error_code    := SQLCODE;
                        l_error_msg     := SQLERRM;
                        x_return_status := 'F';
                        x_msg_data      := ' - Unexpected error while raising notification for RCIR batches - ' || l_error_code || ':' || l_error_msg;


                        IF (g_debug_Level <= 5) THEN
                                cln_debug_pub.Add(l_error_code || ':' || l_error_msg, 4);
                        END IF;

                        IF (g_debug_Level <= 2) THEN
                                cln_debug_pub.Add('Exiting m4u_resp_process.process_rcir_batch_list - exception',2);
                                cln_debug_pub.Add('============================================================',2);
                        END IF;

        END process_rcir_batch_list;


        -- Name
        --      process_wlq_response
        -- Purpose
        --      This process is called once for a Worklist query response document processed
        --      This is done to update the cLN Collaboration Id corresponding to the WLQ send
        -- Arguments
        --      p_wlq_message_id                => Used as CLN_Id for the WLQ Collaboration
        --      p_wlq_success_flag              => TRUE/FALSE flag, correspond to WLQ, generally true.
        --      p_ucc_unique_id                 => Unique document identifer for payload, from UCC
        --      p_xmlg_internal_control_no      => XMLG generated Unique Id for inbound document
        --      x_collab_detail_id              => collaboration history detail id
        --      x_return_status                 => return_status (s-Success/F-failure)
        --      x_msg_data                      => return message
        -- Notes
        --      No specific notes.

        PROCEDURE process_wlq_response(
                                p_wlq_message_id                VARCHAR2,
                                p_wlq_success_flag              VARCHAR2,
                                p_wlq_response_type             VARCHAR2,
                                p_ucc_doc_unique_id             VARCHAR2,
                                p_xmlg_internal_control_no      VARCHAR2,
                                x_collab_detail_id              OUT NOCOPY NUMBER,
                                x_return_status                 OUT NOCOPY VARCHAR2,
                                x_msg_data                      OUT NOCOPY VARCHAR2 )
        IS
                l_error_code            NUMBER;
                l_error_msg             VARCHAR2(2000);
                l_disposition           VARCHAR2(50);
                l_msg_text              VARCHAR2(50);
                l_doc_status            VARCHAR2(50);
                l_coll_status           VARCHAR2(50);
                l_return_status         VARCHAR2(20);
                l_msg_data              VARCHAR2(2000);
                l_collab_detail_id      VARCHAR2(50);
                l_fnd_msg               VARCHAR2(50);
                l_coll_type             VARCHAR2(50);
                l_doc_type              VARCHAR2(50);
        BEGIN
                IF (g_debug_Level <= 2) THEN
                        cln_debug_pub.Add('=====================================================', 2);
                        cln_debug_pub.Add('-- Entering m4u_resp_process.process_wlq_response -- ', 2);
                END IF;

                IF (g_debug_Level <= 1) THEN
                        cln_debug_pub.Add('-- with paramters -- ', 1);
                        cln_debug_pub.Add('p_wlq_message_id             -- ' || p_wlq_message_id , 1);
                        cln_debug_pub.Add('p_wlq_success_flag           -- ' || p_wlq_success_flag, 1);
                        cln_debug_pub.Add('p_wlq_response_type          -- ' || p_wlq_response_type, 1);
                        cln_debug_pub.Add('p_ucc_doc_unique_id          -- ' || p_ucc_doc_unique_id, 1);
                        cln_debug_pub.Add('p_xmlg_internal_control_no   -- ' || p_xmlg_internal_control_no, 1);
                END IF;


                l_doc_type := 'M4U_' || p_wlq_response_type;

                SELECT  collaboration_type
                INTO    l_coll_type
                FROM    cln_coll_hist_hdr
                WHERE   collaboration_id = p_wlq_message_id;

                -- set CLN Dispositon, CLN Coll Status, CLN Message Text, CLN Doc Status

                IF (UPPER(p_wlq_success_flag) = 'TRUE') THEN
                        l_disposition   := 'ACCEPTED';
                        l_msg_text      := 'COMPLETED';
                        l_doc_status    := 'SUCCESS';
                        l_coll_status   := 'COMPLETED';
                        l_fnd_msg       := 'M4U_WLQ_COMPLETED';

                        IF l_coll_type = 'M4U_PARTY_QUERY' THEN
                                l_doc_type := 'M4U_RESP_PARTY';
                                l_fnd_msg  := 'M4U_PARTYQRY_SUCCESS';
                        END IF;
                ELSE
                        l_disposition   := 'FAILED';
                        l_msg_text      := 'REJECTED';
                        l_doc_status    := 'ERROR';
                        l_coll_status   := 'ERROR';
                        l_fnd_msg       := 'M4U_WLQ_FAILURE';
                END IF;

                -- Direct call needed, since CLN Detail Id, is required for further processing
                -- of map., CLN will defualt the rest of the parameters.
                IF (g_debug_Level <= 1) THEN
                        cln_debug_pub.add('updating collaboration history  for cln_id   - ' || p_wlq_message_id,1);
                END IF;

                cln_ch_collaboration_pkg.update_collaboration(
                        x_return_status                  => x_return_status,
                        x_msg_data                       => x_msg_data,
                        p_coll_id                        => p_wlq_message_id,
                        p_msg_text                       => l_fnd_msg,
                        p_xmlg_msg_id                    => NULL,
                        p_xmlg_transaction_type          => 'M4U',
                        p_xmlg_transaction_subtype       => p_wlq_response_type,
                        p_xmlg_int_transaction_type      => 'M4U',
                        p_xmlg_int_transaction_subtype   => p_wlq_response_type,
                        p_doc_dir                        => 'IN',
                        p_doc_type                       => l_doc_type,
                        p_disposition                    => l_disposition,
                        p_doc_status                     => l_doc_status,
                        p_coll_status                    => l_coll_status,
                        p_xmlg_document_id               => NULL,
                        p_xmlg_internal_control_number   => p_xmlg_internal_control_no,
                        p_tr_partner_type                => m4u_ucc_utils.c_party_type,
                        p_tr_partner_id                  => m4u_ucc_utils.g_party_id,
                        p_tr_partner_site                => m4u_ucc_utils.g_party_site_id,
                        p_attribute8                     => p_ucc_doc_unique_id,
                        p_dattribute1                    => sysdate,
                        p_attribute11                    => p_wlq_success_flag,
                        p_rosettanet_check_required      => false,
                        x_dtl_coll_id                    => x_collab_detail_id  );



                IF (g_debug_Level <= 1) THEN
                        cln_debug_pub.add('collaboration history updated for CLN_uniqueid       - ' || p_wlq_message_id,1);
                        cln_debug_pub.add('Collab_detail_id     - ' || x_collab_detail_id,1);
                        cln_debug_pub.add('x_return_status      - ' || x_return_status,1);
                        cln_debug_pub.add('x_msg_data   - ' || x_msg_data,1);
                END IF;

                IF x_return_status <> 'S' THEN
                        x_msg_data := 'Failure occured while processing collaboration history on Query Response - ' || x_msg_data;
                END IF;

                IF (g_debug_Level <= 2) THEN
                        cln_debug_pub.add('Exiting m4u_resp_process.process_wlq_response - normal',2);
                        cln_debug_pub.add('======================================================',2);
                END IF;
        EXCEPTION
              WHEN OTHERS THEN

                        -- log exception and exit.
                        l_error_code    := SQLCODE;
                        l_error_msg     := SQLERRM;
                        x_return_status := 'F';
                        x_msg_data       := ' - Unexpected error occured while processing Query-Worklist Response -  ' || l_error_code || ':' || l_error_msg;


                        IF (g_debug_Level <= 5) THEN
                                cln_debug_pub.add(l_error_code || ':' || l_error_msg, 4);
                        END IF;

                        IF (g_debug_Level <= 2) THEN
                                cln_debug_pub.add('Exiting m4u_resp_process.process_wlq_response - exception',2);
                                cln_debug_pub.add('=========================================================',2);
                        END IF;

        END process_wlq_response;


        -- Name
        --      process_rcir_ack
        -- Purpose
        --      This process is called processing the synchronous Ack received from UCCnet for RCIR messages
        --      *The CLN Collaboration is updated with the response, and event is raised to move WF block*
        --      There is no need for this now.
        -- Arguments
        --      p_ack_type                      => Used as CLN_Id for the WLQ Collaboration
        --      p_command_unique_id             => Unique id of command for which response is received
        --      p_command_success               => Success/failure flag of command for which response is received
        --      p_command_validation_key        => validation key if command is succesfully processed
        --      p_xmlg_internal_control_no      => XMLG generated Unique Id for inbound document
        --      p_ucc_doc_unique_id             => UCCnet generated UniqueId for response
        --      x_collab_detail_id              => collab deatil-id to be returned to map
        --      x_return_status                 => return_status (s-Success/F-failure)
        --      x_msg_data                      => return message
        -- Notes
        --      No specific notes.
        PROCEDURE process_rcir_ack(
                                p_gtin                          IN      VARCHAR2,
                                p_supp_gln                      IN      VARCHAR2,
                                p_target_market                 IN      VARCHAR2,
                                p_command_unique_id             IN      VARCHAR2,
                                p_command_success               IN      VARCHAR2,
                                p_command_validation_key        IN      VARCHAR2,
                                p_ucc_doc_unique_id             IN      VARCHAR2,
                                p_xmlg_internal_control_no      IN      NUMBER,
                                x_collab_detail_id              OUT     NOCOPY NUMBER,
                                x_return_status                 OUT     NOCOPY VARCHAR2,
                                x_msg_data                      OUT     NOCOPY VARCHAR2 )
        IS
                l_error_code            NUMBER;
                l_error_msg             VARCHAR2(2000);
                l_doc_status            VARCHAR2(50);
                l_return_status         VARCHAR2(50);
                l_disposition           VARCHAR2(20);
                l_msg_count             VARCHAR2(50);
                l_msg_data              VARCHAR2(2000);
                l_coll_status           VARCHAR2(50);
                l_notif_mesg            VARCHAR2(100);
                l_event_name            VARCHAR2(100);
                l_event_params          wf_parameter_list_t;
                l_event_key             VARCHAR2(50);
                l_fnd_msg               VARCHAR2(50);
                l_apc_disposition       VARCHAR2(50);
                l_coll_type             VARCHAR2(50);
        BEGIN
                l_event_name := 'oracle.apps.cln.np.processnotification';

                IF (g_debug_Level <= 2) THEN
                        cln_debug_pub.Add('==================================================', 2);
                        cln_debug_pub.Add('-- Entering m4u_resp_process.process_rcir_ack  -- ', 2);
                END IF;

                IF (g_debug_Level <= 1) THEN
                        cln_debug_pub.Add('-- with paramters -- ', 1);
                        cln_debug_pub.Add('p_gtin                       -- ' || p_gtin, 1);
                        cln_debug_pub.Add('p_supp_gln                   -- ' || p_supp_gln, 1);
                        cln_debug_pub.Add('p_target_market              -- ' || p_target_market, 1);
                        cln_debug_pub.Add('p_command_unique_id          -- ' || p_command_unique_id, 1);
                        cln_debug_pub.Add('p_command_success            -- ' || p_command_success, 1);
                        cln_debug_pub.Add('p_command_validation_key     -- ' || p_command_validation_key, 1);
                        cln_debug_pub.Add('p_ucc_doc_unique_id          -- ' || p_ucc_doc_unique_id, 1);
                        cln_debug_pub.Add('p_xmlg_internal_contrlo_no   -- ' || p_xmlg_internal_control_no, 1);
                END IF;

                -- since same procedure is being used to process RCIR Ack, GTIN Query Ack
                -- and diff processing requirement for each of these messages
                SELECT  collaboration_type
                INTO    l_coll_type
                FROM    cln_coll_hist_hdr
                WHERE   collaboration_id = p_command_unique_id;

                IF (g_debug_Level <= 1) THEN
                        cln_debug_pub.Add('CLN Collaboration Type retrieved as - ' || l_coll_type, 1);
                END IF;


                -- set CLN Message Text, CLN Disposition, CLN Doc status, CLN coll status
                IF (UPPER(p_command_success)   = 'TRUE') THEN
                        l_disposition := 'ACCEPTED' ;
                        l_apc_disposition := 'PROCESSED';
                        l_coll_status := 'COMPLETED';
                        l_doc_status  := 'SUCCESS';
                        l_fnd_msg     := 'M4U_RCIR_SUCCESS';
                ELSE
                        l_disposition := 'FAILED' ;
                        l_apc_disposition := 'FAILED';
                        l_coll_status := 'ERROR';
                        l_doc_status  := 'ERROR';
                        l_fnd_msg     := 'M4U_RCIR_FAILURE';
                END IF;

                -- set a diff message than RCIR ack for Query message failure response
                IF l_coll_type = 'M4U_REGISTRY_QUERY' THEN
                        l_fnd_msg     := 'M4U_GTINQRY_FAILURE';
                END IF;

                -- Make API call to update APC event disposition only if it is a M4U_RCIR response
                IF l_coll_type <> 'M4U_REGISTRY_QUERY' THEN

                        IF (g_debug_Level <= 1) THEN
                                cln_debug_pub.Add('-- Calling API EGO_UCCNET_EVENTS_PUB.UPDATE_EVENT_DISPOSITION --',1);
                                cln_debug_pub.Add(' disposition_code    -- '|| l_apc_disposition,1);
                                cln_debug_pub.Add(' disposition_date    -- '|| sysdate,1);
                                cln_debug_pub.Add(' p_cln_id            -- '|| p_command_unique_id,1);
                        END IF;


                        EGO_UCCNET_EVENTS_PUB.UPDATE_EVENT_DISPOSITION
                        (
                                p_api_version           => 1.0,
                                p_commit                => FND_API.g_FALSE,
                                p_init_msg_list         => FND_API.G_FALSE,
                                p_cln_id                => p_command_unique_id,
                                p_disposition_code      => l_apc_disposition,
                                p_disposition_date      => sysdate,
                                x_return_status         => l_return_status,
                                x_msg_count             => l_msg_count,
                                x_msg_data              => l_msg_data
                        );


                        IF (g_debug_Level <= 1) THEN
                                cln_debug_pub.add('ego_uccnet_events disposition updated');
                                cln_debug_pub.add('p_cln_id             - ' || p_command_unique_id,1);
                                cln_debug_pub.add('p_disposition_code   - ' || l_apc_disposition,1);
                                cln_debug_pub.add('p_disposition_date   - ' || sysdate,1);
                                cln_debug_pub.add('-- return values --',1);
                                cln_debug_pub.add('x_return_status      - ' || l_return_status,1);
                                cln_debug_pub.add('x_msg_count          - ' || l_msg_count,1);
                                cln_debug_pub.add('x_msg_data           - ' || l_msg_data,1);
                        END IF;
                END IF;


                -- Direct call needed, since CLN Detail Id, is required for further processing
                -- of map., CLN will defualt the rest of the parameters.
                IF (g_debug_Level <= 1) THEN
                        cln_debug_pub.add('updating collaboration history  for cln_id   - ' || p_command_unique_id,1);
                END IF;

                CLN_CH_COLLABORATION_PKG.UPDATE_COLLABORATION
                (
                        x_return_status                         => x_return_status,
                        x_msg_data                              => x_msg_data,
                        p_coll_id                               => p_command_unique_id,
                        p_msg_text                              => l_fnd_msg,
                        p_xmlg_msg_id                           => NULL,
                        p_xmlg_int_transaction_type             => 'M4U',
                        p_xmlg_int_transaction_subtype          => 'RESP_ACK',
                        p_xmlg_transaction_type                 => 'M4U',
                        p_xmlg_transaction_subtype              => 'RESP_ACK',
                        p_doc_dir                               => 'IN',
                        p_doc_type                              => 'M4U_RESP_ACK',
                        p_disposition                           => l_disposition,
                        p_doc_status                            => l_doc_status,
                        p_coll_status                           => l_coll_status,
                        p_tr_partner_type                       => m4u_ucc_utils.c_party_type,
                        p_tr_partner_id                         => m4u_ucc_utils.g_party_id,
                        p_tr_partner_site                       => m4u_ucc_utils.g_party_site_id,
                        p_rosettanet_check_required             => FALSE,
                        x_dtl_coll_id                           => x_collab_detail_id,
                        p_xmlg_internal_control_number          => p_xmlg_internal_control_no,
                        p_doc_creation_date                     => sysdate,
                        p_attribute2                            => p_target_market,
                        p_attribute5                            => p_supp_gln,
                        p_attribute8                            => p_ucc_doc_unique_id,
                        p_attribute9                            => p_command_validation_key,
                        p_attribute11                           => p_command_success,
                        p_dattribute1                           => sysdate,
                        p_doc_no                                => p_gtin

                );

                x_msg_data      := x_msg_data || ' - ' || l_msg_data;
                IF (g_debug_Level <= 1) THEN
                        cln_debug_pub.add('collaboration history updated for cln_id     - ' || p_command_unique_id,1);
                        cln_debug_pub.add('Collab_detail_id     - ' || x_collab_detail_id,1);
                        cln_debug_pub.add('x_return_status      - ' || x_return_status,1);
                        cln_debug_pub.add('x_msg_data           - ' || x_msg_data,1);
                END IF;

                -- Raise CLN notification event only for a M4U_RCIR response
                IF l_coll_type <> 'M4U_REGISTRY_QUERY' THEN

                        l_notif_mesg    := 'Acknowledgement received for RCIR, from UCCnet with following details';

                        l_event_params  := wf_parameter_list_t();

                        wf_event.AddParameterToList(
                                p_name          => 'COLLABORATION_ID',
                                p_value         => p_command_unique_id,
                                p_parameterlist => l_event_params   );

                        wf_event.AddParameterToList(
                                p_name          => 'COLLABORATION_POINT',
                                p_value         => 'APPS',
                                p_parameterlist => l_event_params   );

                        wf_event.AddParameterToList(
                                p_name          => 'APPLICATION_ID',
                                p_value         => m4u_ucc_utils.c_resp_appl_id,
                                p_parameterlist => l_event_params   );

                        wf_event.AddParameterToList(
                                p_name          => 'NOTIFICATION_CODE',
                                p_value         => 'M4URCIR',
                                p_parameterlist => l_event_params   );

                        wf_event.AddParameterToList(
                                p_name          => 'NOTIFICATION_STATUS',
                                p_value         => l_coll_status,
                                p_parameterlist => l_event_params   );

                        wf_event.AddParameterToList(
                                p_name          => 'NOTIFICATION_DESC',
                                p_value         => l_notif_mesg,
                                p_parameterlist => l_event_params   );

                        l_event_key     := 'RESP_ACK_RCIR_' || p_command_unique_id;


                        IF (g_debug_Level <= 1) THEN
                                cln_debug_pub.add('--- raising Business Event ---',1);
                                cln_debug_pub.add('Event-name  - ' || l_event_name,1);
                                cln_debug_pub.add('event-value -'  || l_event_key ,1);
                        END IF;

                        -- raise event for notification
                        wf_event.raise(
                                p_event_name            => l_event_name,
                                p_event_key             => l_event_key,
                                p_parameters            => l_event_params
                                );



                END IF;

                IF (x_return_status <> 'S') THEN
                        x_msg_data := 'Failure occured which processing RCIR Acknowledgement from UCCnet, - ' || x_msg_data;
                END IF;


                IF (g_debug_Level <= 2) THEN
                        cln_debug_pub.add('Exiting m4u_resp_process.process_rcir_ack - normal',2);
                        cln_debug_pub.add('==================================================',2);
                END IF;
        EXCEPTION
              WHEN OTHERS THEN

                        -- log exception and exit.
                        l_error_code            := SQLCODE;
                        l_error_msg             := SQLERRM;
                        x_return_status         := 'F';
                        x_msg_data              := ' - Unexpected error in while processing RCIR acknowledgement - ' || l_error_code || ':' || l_error_msg;


                        IF (g_debug_Level <= 5) THEN
                                cln_debug_pub.add(l_error_code || ':' || l_error_msg, 4);
                        END IF;

                        IF (g_debug_Level <= 2) THEN
                                cln_debug_pub.add('Exiting m4u_resp_process.process_rcir_ack - exception',2);
                                cln_debug_pub.add('=====================================================',2);
                        END IF;

        END process_rcir_ack;




        -- Name
        --      process_rcir_batch_ack
        -- Purpose
        --      This is used to process the RCIR Batch message
        --      In case of success, the individual RCIR collaborations are updated (status set to initiated)
        --      **In case of failure, the business event is raised to move WF block**
        --      Removing this as this is not  required.
        -- Arguments
        --      p_command_unique_id             => Unique id of batch
        --      p_supp_gln                      => unique GLN of supplier
        --      p_command_success               => Success/failure flag of command for which response is received
        --      p_ucc_doc_unique_id             => UCCnet generated UniqueId for response
        --      p_xmlg_internal_control_no      => XMLG generated Unique Id for inbound document
        --      x_collab_detail_id              => collab deatil-id to be returned to map
        --      x_return_status                 => return_status (s-Success/F-failure)
        --      x_msg_data                      => return message
        -- Notes
        --      No specific notes.
        PROCEDURE process_rcir_batch_ack(
                                p_command_unique_id             IN      VARCHAR2,
                                p_supp_gln                      IN      VARCHAR2,
                                p_command_success               IN      VARCHAR2,
                                p_ucc_doc_unique_id             IN      VARCHAR2,
                                p_xmlg_internal_control_no      IN      NUMBER,
                                x_collab_detail_id              OUT     NOCOPY NUMBER,
                                x_return_status                 OUT     NOCOPY VARCHAR2,
                                x_msg_data                      OUT     NOCOPY VARCHAR2 )

        IS
                l_error_code            NUMBER;
                l_error_msg             VARCHAR2(2000);
                l_doc_status            VARCHAR2(50);
                l_return_status         VARCHAR2(50);
                l_disposition           VARCHAR2(50);
                l_msg_data              VARCHAR2(2000);
                l_msg_count             VARCHAR2(50);
                l_coll_status           VARCHAR2(50);
                l_error_flag            VARCHAR2(50);
                l_notif_mesg            VARCHAR2(100);
                l_event_name            VARCHAR2(100);
                l_owner_role            VARCHAR2(100);
                l_event_params          wf_parameter_list_t;
                l_event_key             VARCHAR2(50);
                l_fnd_msg               VARCHAR2(50);
                l_apc_disposition       VARCHAR2(50);

                CURSOR  c_clnid_for_batch (p_batch_id VARCHAR) IS
                        SELECT  collaboration_id
                        FROM    cln_coll_hist_hdr
                        WHERE   attribute12 =  p_batch_id
                        AND xmlg_transaction_type = 'M4U';

        BEGIN
                l_event_name := 'oracle.apps.cln.np.processnotification';

                IF (g_debug_Level <= 2) THEN
                        cln_debug_pub.Add('=======================================================', 2);
                        cln_debug_pub.Add('-- Entering m4u_resp_process.process_rcir_batch_ack -- ', 2);
                END IF;

                IF (g_debug_Level <= 1) THEN
                        cln_debug_pub.Add('-- with parameters -- ', 1);
                        cln_debug_pub.Add('p_command_unique_id          -- ' || p_command_unique_id, 1);
                        cln_debug_pub.Add('p_supp_gln                   -- ' || p_supp_gln, 1);
                        cln_debug_pub.Add('p_command_success            -- ' || p_command_success, 1);
                        cln_debug_pub.Add('p_ucc_doc_unique_id          -- ' || p_ucc_doc_unique_id, 1);
                        cln_debug_pub.Add('p_xmlg_internal_control_no   -- ' || p_xmlg_internal_control_no, 1);
                END IF;

                -- set CLN message, CLN Doc status, CLN disposition, CLN Coll Status
                IF (UPPER(p_command_success)   = 'TRUE') THEN
                        l_disposition := 'PENDING' ;
                        l_coll_status := 'INITIATED';
                        l_doc_status  := 'SUCCESS';
                        l_fnd_msg     := 'M4U_RCIR_BATCH_ACCEPTED';
                        l_apc_disposition := 'PROCESSED';
                ELSE
                        l_disposition := 'FAILED' ;
                        l_coll_status := 'ERROR';
                        l_doc_status  := 'ERROR';
                        l_fnd_msg     := 'M4U_RCIR_BATCH_REJECTED';
                        l_apc_disposition := 'FAILED';
                END IF;

                -- for every CLN-ID corresponding to individual rcir commands in the batch
                -- 1. update ego_uccnet_table disposition.
                -- 2. update CLN Collaboration.
                FOR rec_cln_id IN c_clnid_for_batch(p_command_unique_id) LOOP


                        IF (UPPER(p_command_success)   <> 'TRUE') THEN
                                -- Make API call to update APC event disposition
                                IF (g_debug_Level <= 1) THEN
                                        cln_debug_pub.Add('-- Calling API EGO_UCCNET_EVENTS_PUB.UPDATE_EVENT_DISPOSITION --',1);
                                        cln_debug_pub.Add(' disposition_code    -- '|| l_apc_disposition,1);
                                        cln_debug_pub.Add(' disposition_date    -- '|| sysdate,1);
                                        cln_debug_pub.Add(' p_cln_id            -- '|| rec_cln_id.collaboration_id,1);
                                END IF;

                                EGO_UCCNET_EVENTS_PUB.UPDATE_EVENT_DISPOSITION
                                (
                                        p_api_version           => 1.0,
                                        p_commit                => FND_API.g_FALSE,
                                        p_init_msg_list         => FND_API.G_FALSE,
                                        p_cln_id                => rec_cln_id.collaboration_id,
                                        p_disposition_code      => l_apc_disposition,
                                        p_disposition_date      => sysdate,
                                        x_return_status         => l_return_status,
                                        x_msg_count             => l_msg_count,
                                        x_msg_data              => l_msg_data
                                );

                                IF (g_debug_Level <= 1) THEN
                                        cln_debug_pub.Add('-- UPDATE_EVENT_DISPOSITION returned --',1);
                                        cln_debug_pub.Add(' x_return_status     -- '    || l_return_status,1);
                                        cln_debug_pub.Add(' x_msg_count         -- '    || l_msg_count,1);
                                        cln_debug_pub.Add(' x_msg_data          -- '    || l_msg_data,1);
                                END IF;

                        END IF;

                        -- Direct call needed, since CLN Detail Id, is required for further processing
                        -- of map., CLN will defualt the rest of the parameters.
                        IF (g_debug_Level <= 1) THEN
                                cln_debug_pub.add('updating collaboration history  for cln_id   - ' || rec_cln_id.collaboration_id,1);
                        END IF;

                        CLN_CH_COLLABORATION_PKG.UPDATE_COLLABORATION
                        (
                                x_return_status                         => x_return_status,
                                x_msg_data                              => x_msg_data,
                                p_coll_id                               => rec_cln_id.collaboration_id ,
                                p_msg_text                              => l_fnd_msg,
                                p_xmlg_msg_id                           => NULL,
                                p_xmlg_int_transaction_type             => 'M4U',
                                p_xmlg_int_transaction_subtype          => 'RESP_ACK',
                                p_xmlg_transaction_type                 => 'M4U',
                                p_xmlg_transaction_subtype              => 'RESP_ACK',
                                p_doc_dir                               => 'IN',
                                p_doc_type                              => 'M4U_RESP_ACK',
                                p_disposition                           => l_disposition,
                                p_doc_status                            => l_doc_status,
                                p_coll_status                           => l_coll_status,
                                p_tr_partner_type                       => m4u_ucc_utils.c_party_type,
                                p_tr_partner_id                         => m4u_ucc_utils.g_party_id,
                                p_tr_partner_site                       => m4u_ucc_utils.g_party_site_id,
                                p_rosettanet_check_required             => FALSE,
                                x_dtl_coll_id                           => x_collab_detail_id,
                                p_xmlg_internal_control_number          => p_xmlg_internal_control_no,
                                p_doc_creation_date                     => sysdate,
                                p_attribute8                            => p_ucc_doc_unique_id,
                                p_attribute10                           => p_command_unique_id,
                                p_attribute11                           => 'FALSE'
                        );


                        IF (g_debug_Level <= 1) THEN
                                cln_debug_pub.add('collaboration history updated for cln_id     - ' || rec_cln_id.collaboration_id,1);
                                cln_debug_pub.add('Collab_detail_id     - ' || x_collab_detail_id,1);
                                cln_debug_pub.add('x_return_status      - ' || x_return_status,1);
                                cln_debug_pub.add('x_msg_data           - ' || x_msg_data,1);
                        END IF;


                        IF x_return_status <> 'S' THEN
                                l_error_flag := 'TRUE';
                                l_error_msg  := 'Failure occured while updating collaboration history on RCIR Batch response - ' || x_msg_data;
                        END IF;



                END LOOP;

                IF UPPER(p_command_success) <> 'TRUE' THEN


                        l_notif_mesg    := 'RCIR Batch Payload Rejected by UCCnet';

                        l_event_params  := wf_parameter_list_t();


                        wf_event.AddParameterToList(
                                        p_name          => 'ATTRIBUTE_NAME',
                                        p_value         => 'ATTRIBUTE12',
                                        p_parameterlist => l_event_params   );


                        wf_event.AddParameterToList(
                                        p_name          => 'ATTRIBUTE_VALUE',
                                        p_value         => p_command_unique_id,
                                        p_parameterlist => l_event_params   );

                        wf_event.AddParameterToList(
                                        p_name          => 'BATCH_MODE_REQD',
                                        p_value         => 'Y',
                                        p_parameterlist => l_event_params   );

                        wf_event.AddParameterToList(
                                        p_name          => 'COLLABORATION_POINT',
                                        p_value         => 'APPS',
                                        p_parameterlist => l_event_params   );

                        wf_event.AddParameterToList(
                                        p_name          => 'COLLABORATION_STANDARD',
                                        p_value         => 'UCCNET',
                                        p_parameterlist => l_event_params   );

                        wf_event.AddParameterToList(
                                        p_name          => 'APPLICATION_ID',
                                        p_value         => m4u_ucc_utils.c_resp_appl_id,
                                        p_parameterlist => l_event_params   );

                        wf_event.AddParameterToList(
                                        p_name          => 'NOTIFICATION_CODE',
                                        p_value         => 'M4UBCHAK',
                                        p_parameterlist => l_event_params   );

                        wf_event.AddParameterToList(
                                        p_name          => 'NOTIFICATION_STATUS',
                                        p_value         => l_coll_status,
                                        p_parameterlist => l_event_params   );

                        wf_event.AddParameterToList(
                                        p_name          => 'NOTIFICATION_DESC',
                                        p_value         => l_notif_mesg,
                                        p_parameterlist => l_event_params   );


                        BEGIN
                                SELECT  owner_role
                                INTO    l_owner_role
                                FROM    cln_coll_hist_hdr
                                WHERE   attribute12 = p_command_unique_id AND rownum < 2
                                AND xmlg_transaction_type = 'M4U';
                        EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                        l_owner_role := fnd_profile.value('CLN_ADMINISTRATOR');
                                END;

                        wf_event.AddParameterToList(
                                p_name          => 'NOTIFICATION_RECEIVER_ROLE',
                                p_value         => l_owner_role,
                                p_parameterlist => l_event_params   );


                        l_event_key     := 'M4U_RCIR_BATCH_AK_' || p_command_unique_id;

                        IF (g_debug_Level <= 1) THEN
                                cln_debug_pub.add('--- raising Business Event ---',1);
                                cln_debug_pub.add('Event-name  - ' || l_event_name,1);
                                cln_debug_pub.add('event-value -'  || l_event_key ,1);
                        END IF;

                        -- raise event to trigger outbound wlq generation WF
                        wf_event.raise(
                               p_event_name            => l_event_name,
                               p_event_key             => l_event_key,
                               p_parameters            => l_event_params
                                 );
                END IF;


                IF l_error_flag = 'TRUE' THEN
                        x_return_status := 'F';
                        x_msg_data      := l_error_msg;
                ELSE
                        x_return_status := 'S';
                        x_msg_data      := 'Successfully updated all RCIR-Batch collaborations on RCIR Batch response';
                END IF;

                IF (g_debug_Level <= 2) THEN
                        cln_debug_pub.add('Exiting m4u_resp_process.process_rcir_batch_ack - normal',2);
                        cln_debug_pub.add('========================================================',2);
                END IF;
        EXCEPTION
              WHEN OTHERS THEN
                        -- log exception and exit.
                        l_error_code            := SQLCODE;
                        l_error_msg             := SQLERRM;
                        x_return_status         := 'F';
                        x_msg_data              := ' - Unexpected error while processing RCIR Batch response - ' || l_error_code || ':' || l_error_msg;


                        IF (g_debug_Level <= 5) THEN
                                cln_debug_pub.add(l_error_code || ':' || l_error_msg, 4);
                        END IF;

                        IF (g_debug_Level <= 2) THEN
                                cln_debug_pub.add('Exiting m4u_resp_process.process_rcir_batch_ack - exception',2);
                                cln_debug_pub.add('===========================================================',2);
                        END IF;

        END process_rcir_batch_ack;


        -- Name
        --      process_cin_ack
        -- Purpose
        --      This process is called for processing the synchronous Ack received from UCCnet for CIN messages
        --      The CLN Collaboration, ego_uccnet_events table are updated with the response
        --      A CLN notification event is raised.
        -- Arguments
        --      p_command_unique_id             => Unique id of command for which response is received
        --      p_supp_gln                      => datasource/gln of document originator
        --      p_command_success               => Success/failure flag of command for which response is received
        --      p_command_validation_key        => validation key if command is succesfully processed
        --      p_ucc_doc_unique_id             => UCCnet generated UniqueId for response document
        --      p_xmlg_internal_control_no      => XMLG generated Unique Id for inbound document
        --      x_collab_detail_id              => collab deatil-id to be returned to map
        --      x_return_status                 => return_status (S-Success/F-failure)
        --      x_msg_data                      => return message
        -- Notes
        --      No specific notes.
        PROCEDURE process_cin_ack(
                                p_command_unique_id             IN      VARCHAR2,
                                p_supp_gln                      IN      VARCHAR2,
                                p_command_success               IN      VARCHAR2,
                                p_command_validation_key        IN      VARCHAR2,
                                p_ucc_doc_unique_id             IN      VARCHAR2,
                                p_xmlg_internal_control_no      IN      NUMBER,
                                x_collab_detail_id              OUT     NOCOPY NUMBER,
                                x_return_status                 OUT     NOCOPY VARCHAR2,
                                x_msg_data                      OUT     NOCOPY VARCHAR2 )
        IS
                l_error_code            NUMBER;
                l_error_msg             VARCHAR2(2000);
                l_doc_status            VARCHAR2(50);
                l_return_status         VARCHAR2(50);
                l_disposition           VARCHAR2(50);
                l_msg_data              VARCHAR2(2000);
                l_coll_status           VARCHAR2(50);
                l_msg_count             VARCHAR2(50);
                l_notif_mesg            VARCHAR2(100);
                l_event_name            VARCHAR2(100);
                l_event_params          wf_parameter_list_t;
                l_event_key             VARCHAR2(50);
                l_fnd_msg               VARCHAR2(50);
                l_apc_disposition       VARCHAR2(50);
        BEGIN
                l_event_name := 'oracle.apps.cln.np.processnotification';

                IF (g_debug_Level <= 2) THEN
                        cln_debug_pub.Add('================================================', 2);
                        cln_debug_pub.Add('-- Entering m4u_resp_process.process_cin_ack -- ', 2);
                END IF;

                IF (g_debug_Level <= 1) THEN
                        cln_debug_pub.Add('-- with paramters -- ', 1);
                        cln_debug_pub.Add('p_command_unique_id          -- ' || p_command_unique_id, 1);
                        cln_debug_pub.Add('p_supp_gln                   -- ' || p_command_unique_id, 1);
                        cln_debug_pub.Add('p_command_success            -- ' || p_command_success, 1);
                        cln_debug_pub.Add('p_command_validation_key     -- ' || p_command_validation_key, 1);
                        cln_debug_pub.Add('p_ucc_doc_unique_id          -- ' || p_ucc_doc_unique_id, 1);
                        cln_debug_pub.Add('p_xmlg_internal_contrlo_no   -- ' || p_xmlg_internal_control_no, 1);
                END IF;

                -- set CLN Disposition, CLN Document status, CLN status

                -- set CLN Message Text based on command sucess/failure parameter
                IF (UPPER(p_command_success)   = 'TRUE') THEN
                        l_disposition   := 'PENDING' ;
                        l_coll_status   := 'INITIATED';
                        l_doc_status    := 'SUCCESS';
                        l_fnd_msg       := 'M4U_CIN_AK_SUCCESS';
                        l_apc_disposition := 'PROCESSED';
                ELSE
                        l_disposition   := 'FAILED' ;
                        l_coll_status   := 'ERROR';
                        l_doc_status    := 'ERROR';
                        l_fnd_msg       := 'M4U_CIN_AK_FAILURE';
                        l_apc_disposition := 'FAILED';
                END IF;

                -- Make API call to update APC event disposition
                IF (g_debug_Level <= 1) THEN
                        cln_debug_pub.Add('-- Calling API EGO_UCCNET_EVENTS_PUB.UPDATE_EVENT_DISPOSITION --',1);
                        cln_debug_pub.Add(' disposition_code    -- '|| l_apc_disposition,1);
                        cln_debug_pub.Add(' disposition_date    -- '|| sysdate,1);
                        cln_debug_pub.Add(' p_cln_id                    -- '|| p_command_unique_id,1);
                END IF;

                EGO_UCCNET_EVENTS_PUB.UPDATE_EVENT_DISPOSITION
                (
                        p_api_version           => 1.0,
                        p_commit                => FND_API.g_FALSE,
                        p_init_msg_list         => FND_API.G_FALSE,
                        p_cln_id                => p_command_unique_id,
                        p_disposition_code      => l_apc_disposition,
                        p_disposition_date      => sysdate,
                        x_return_status         => l_return_status,
                        x_msg_count             => l_msg_count,
                        x_msg_data              => l_msg_data
                );

                IF (g_debug_Level <= 1) THEN
                        cln_debug_pub.Add('-- UPDATE_EVENT_DISPOSITION returned --',1);
                        cln_debug_pub.Add(' x_return_status     -- '|| l_return_status,1);
                        cln_debug_pub.Add(' x_msg_count         -- '|| l_msg_count,1);
                        cln_debug_pub.Add(' x_msg_data          -- '|| l_msg_data,1);
                END IF;


                -- Direct call needed, since CLN Detail Id, is required for further processing
                -- of map., CLN will defualt the rest of the parameters.
                IF (g_debug_Level <= 1) THEN
                        cln_debug_pub.add('updating collaboration history  for cln_id   - ' || p_command_unique_id,1);
                END IF;

                CLN_CH_COLLABORATION_PKG.UPDATE_COLLABORATION
                (
                        x_return_status                         => x_return_status,
                        x_msg_data                              => x_msg_data,
                        p_coll_id                               => p_command_unique_id ,
                        p_msg_text                              => l_fnd_msg,
                        p_xmlg_msg_id                           => NULL,
                        p_xmlg_int_transaction_type             => 'M4U',
                        p_xmlg_int_transaction_subtype          => 'RESP_ACK',
                        p_xmlg_transaction_type                 => 'M4U',
                        p_xmlg_transaction_subtype              => 'RESP_ACK',
                        p_doc_dir                               => 'IN',
                        p_doc_type                              => 'M4U_RESP_ACK',
                        p_disposition                           => l_disposition,
                        p_doc_status                            => l_doc_status,
                        p_coll_status                           => l_coll_status,
                        p_tr_partner_type                       => m4u_ucc_utils.c_party_type,
                        p_tr_partner_id                         => m4u_ucc_utils.g_party_id,
                        p_tr_partner_site                       => m4u_ucc_utils.g_party_site_id,
                        p_rosettanet_check_required             => FALSE,
                        x_dtl_coll_id                           => x_collab_detail_id,
                        p_xmlg_internal_control_number          => p_xmlg_internal_control_no,
                        p_doc_creation_date                     => sysdate,
                        p_attribute8                            => p_ucc_doc_unique_id,
                        p_attribute9                            => p_command_validation_key,
                        p_attribute11                           => p_command_success
                );


                IF (g_debug_Level <= 1) THEN
                        cln_debug_pub.add('collaboration history updated for cln_id     - ' || p_command_unique_id,1);
                        cln_debug_pub.add('Collab_detail_id     - ' || x_collab_detail_id,1);
                        cln_debug_pub.add('x_return_status      - ' || x_return_status,1);
                        cln_debug_pub.add('x_msg_data           - ' || x_msg_data,1);
                END IF;

                IF x_return_status <> 'S' THEN
                        x_msg_data := 'Error occured while processing response from UCCnet for CIN message - ' || x_msg_data;
                END IF;

                l_notif_mesg    := 'Acknowledgement received from UCCnet for CIN message';

                l_event_params  := wf_parameter_list_t();
                wf_event.AddParameterToList(
                                       p_name          => 'COLLABORATION_ID',
                                       p_value         => p_command_unique_id,
                                       p_parameterlist => l_event_params   );

                wf_event.AddParameterToList(
                                       p_name          => 'COLLABORATION_POINT',
                                       p_value         => 'APPS',
                                       p_parameterlist => l_event_params   );

                wf_event.AddParameterToList(
                                       p_name          => 'APPLICATION_ID',
                                       p_value         => m4u_ucc_utils.c_resp_appl_id,
                                       p_parameterlist => l_event_params   );

                wf_event.AddParameterToList(
                                       p_name          => 'NOTIFICATION_CODE',
                                       p_value         => 'M4UCINAK',
                                       p_parameterlist => l_event_params   );

                wf_event.AddParameterToList(
                                       p_name          => 'NOTIFICATION_STATUS',
                                       p_value         => l_coll_status,
                                       p_parameterlist => l_event_params   );

                wf_event.AddParameterToList(
                                       p_name          => 'NOTIFICATION_DESC',
                                       p_value         => l_notif_mesg,
                                       p_parameterlist => l_event_params   );

                l_event_key     := 'M4U_CINAK_' || p_command_unique_id;

                IF (g_debug_Level <= 1) THEN
                        cln_debug_pub.add('--- raising Business Event ---',1);
                        cln_debug_pub.add('Event-name  - ' || l_event_name,1);
                        cln_debug_pub.add('event-value -'  || l_event_key ,1);
                END IF;

                -- raise event to trigger outbound wlq generation WF
                wf_event.raise(
                               p_event_name            => l_event_name,
                               p_event_key             => l_event_key,
                               p_parameters            => l_event_params
                              );

                IF (g_debug_Level <= 2) THEN
                        cln_debug_pub.add('Exiting m4u_resp_process.process_cin_ack - normal',2);
                        cln_debug_pub.add('=================================================',2);
                END IF;
        EXCEPTION
                WHEN OTHERS THEN
                        -- log exception and exit.
                        l_error_code    := SQLCODE;
                        l_error_msg     := SQLERRM;
                        x_return_status := 'F';
                        x_msg_data       := ' - Unexpected error while processing CIN response - ' || l_error_code || ':' || l_error_msg;


                        IF (g_debug_Level <= 5) THEN
                                cln_debug_pub.add(l_error_code || ':' || l_error_msg, 4);
                        END IF;

                        IF (g_debug_Level <= 2) THEN
                                cln_debug_pub.add('Exiting m4u_resp_process.process_cin_ack - exception',2);
                                cln_debug_pub.add('====================================================',2);
                        END IF;
        END process_cin_ack;


        -- Name
        --      process_rfcin_notification
        -- Purpose
        --      This process is called for processing the "Request For Catalogue Item Notification" notifiacation
        --      from UCCnet. These notifications are recived as part of Worklistquery Responses where the
        --      filter in the Query is name = "REQUEST_FOR_NOTIFICATION".
        --      A CLN collaboration is to be created for this messsage.
        --      A CLN Notification is to be raised on for each of these responses received.
        -- Arguments
        --      p_wlq_message_id                => Unique identifier Worklist-query for which this notification is received as response
        --      p_target_market_country         => Retailer wants notification for item(s) of this target market
        --      p_target_market_subdivision     => Retailer wants notification for item(s) of this target market sub division
        --      p_gtin                          => Retailer wants notification for this specific GTIN
        --      p_data_recipient                => GLN of (this) supplier
        --      p_data_source                   => Datasoure
        --      p_recipient_data_pool           => Datapool of recipient
        --      p_classification_category       => Retailer wants notification for items of this Category
        --      p_rfcin_unique_id               => unique command level id of RFCIN command
        --      p_rfcin_owner_gln               => GLN of retailer who issued this command
        --      p_reload_flag                   => flag specifies whether retailer wants new GTIN or reload exisiting data
        --      p_ucc_doc_unique_id             => unique id of UCCnet message(worklist query response)
        --      p_xmlg_internal_control_no      => XMLG generated internal control number
        --      x_return_status                 => out param. ret status from CLN API call
        --      x_msg_data                      => out param. ret message from CLN API call
        -- Notes
        --      No specific notes.
        PROCEDURE process_rfcin_notification(
                                p_wlq_message_id                        IN      VARCHAR2,
                                p_target_market_country                 IN      VARCHAR2,
                                p_target_market_subdivision             IN      VARCHAR2,
                                p_gtin                                  IN      VARCHAR2,
                                p_data_recipient                        IN      VARCHAR2,
                                p_data_source                           IN      VARCHAR2,
                                p_recipient_data_pool                   IN      VARCHAR2,
                                p_classification_category               IN      VARCHAR2,
                                p_rfcin_unique_id                       IN      VARCHAR2,
                                p_rfcin_owner_gln                       IN      VARCHAR2,
                                p_reload_flag                           IN      VARCHAR2,
                                p_rfcin_creation_date                   IN      VARCHAR2,
                                p_ucc_doc_unique_id                     IN      VARCHAR2,
                                p_xmlg_internal_control_no              IN      NUMBER,
                                x_return_status                         OUT     NOCOPY VARCHAR2,
                                x_msg_data                              OUT NOCOPY VARCHAR2 )


        IS
                l_error_code    VARCHAR2(50);
                l_error_msg     VARCHAR2(255);
                l_return_status VARCHAR2(50);
                l_msg_data      VARCHAR2(255);
                l_coll_id       VARCHAR2(50);
                l_notif_mesg    VARCHAR2(400);
                l_event_name    VARCHAR2(100);
                l_event_key     VARCHAR2(50);
                l_event_params  wf_parameter_list_t;
        BEGIN

                        l_event_name := 'oracle.apps.cln.np.processnotification';

                        IF (g_debug_Level <= 2) THEN
                                cln_debug_pub.Add('-- Entering m4u_resp_process.process_rfcin_notification -- ', 2);
                        END IF;

                        IF (g_debug_Level <= 1) THEN
                                cln_debug_pub.Add('-- with paramters -- ', 1);
                                cln_debug_pub.Add('p_wlq_message_id             -- ' || p_wlq_message_id, 1);
                                cln_debug_pub.Add('p_target_market_country      -- ' || p_target_market_country, 1);
                                cln_debug_pub.Add('p_target_market_subdivision  -- ' || p_target_market_subdivision, 1);
                                cln_debug_pub.Add('p_gtin                       -- ' || p_gtin, 1);
                                cln_debug_pub.Add('p_data_recipient             -- ' || p_data_recipient, 1);
                                cln_debug_pub.Add('p_data_source                -- ' || p_data_source, 1);
                                cln_debug_pub.Add('p_recipient_data_pool        -- ' || p_recipient_data_pool, 1);
                                cln_debug_pub.Add('p_classification_category    -- ' || p_classification_category, 1);
                                cln_debug_pub.Add('p_rfcin_unique_id            -- ' || p_rfcin_unique_id, 1);
                                cln_debug_pub.Add('p_rfcin_owner_gln            -- ' || p_rfcin_owner_gln, 1);
                                cln_debug_pub.Add('p_reload_flag                -- ' || p_reload_flag, 1);
                                cln_debug_pub.Add('p_rfcin_creation_date        -- ' || p_rfcin_creation_date, 1);
                                cln_debug_pub.Add('p_ucc_doc_unique_id          -- ' || p_ucc_doc_unique_id, 1);
                                cln_debug_pub.Add('p_xmlg_internal_control_no   -- ' || p_xmlg_internal_control_no, 1);
                        END IF;

                        IF (g_debug_Level <= 1) THEN
                                cln_debug_pub.add('Calling Create Collaboration API',1);
                        END IF;

                        cln_ch_collaboration_pkg.create_collaboration (
                                        x_return_status               => l_return_status,
                                        x_msg_data                    => l_msg_data,
                                        p_app_id                      => m4u_ucc_utils.c_resp_appl_id,
                                        p_ref_id                      => NULL,
                                        p_org_id                      => m4u_ucc_utils.g_org_id,
                                        p_rel_no                      => NULL,
                                        p_doc_no                      => p_rfcin_unique_id,
                                        p_doc_owner                   => NULL,
                                        p_xmlg_int_transaction_type   => 'M4U',
                                        p_xmlg_int_transaction_subtype=> 'RESP_RFCIN',
                                        p_xmlg_transaction_type       => 'M4U',
                                        p_xmlg_transaction_subtype    => 'RESP_RFCIN',
                                        p_xmlg_document_id            => p_ucc_doc_unique_id,
                                        p_coll_type                   => 'M4U_RFCIN',
                                        p_tr_partner_type             => m4u_ucc_utils.c_party_type,
                                        p_tr_partner_site             => m4u_ucc_utils.g_party_site_id,
                                        p_doc_creation_date           => sysdate,
                                        p_doc_revision_date           => sysdate,
                                        p_init_date                   => sysdate,
                                        p_doc_type                    => 'M4U_RESP_RFCIN',
                                        p_doc_dir                     => 'IN',
                                        p_coll_pt                     => 'XML_GATEWAY',
                                        p_xmlg_msg_id                 => NULL,
                                        p_rosettanet_check_required   => FALSE,
                                        x_coll_id                     => l_coll_id,
                                        p_msg_text                    => 'M4U_RFCIN_RECEIVED',
                                        p_xml_event_key               => NULL,
                                        p_xmlg_internal_control_number=> p_xmlg_internal_control_no,
                                        p_attribute1                  => p_recipient_data_pool,
                                        p_attribute2                  => p_target_market_country,
                                        p_attribute5                  => m4u_ucc_utils.g_supp_gln,
                                        p_attribute6                  => p_rfcin_owner_gln,
                                        p_attribute8                  => p_ucc_doc_unique_id,
                                        p_attribute9                  => p_gtin,
                                        p_attribute10                 => p_rfcin_unique_id,
                                        p_attribute12                 => p_wlq_message_id,
                                        p_attribute13                 => p_target_market_subdivision,
                                        p_attribute14                 => p_reload_flag,
                                        p_attribute15                 => p_classification_category,
                                        p_partner_doc_no              => NULL,
                                        p_collaboration_standard      => 'UCCNET'
                                        );

                        IF (g_debug_Level <= 1) THEN
                                cln_debug_pub.add('create Collaboration returned ---',1);
                                cln_debug_pub.add('Collab_detail_id     - ' || l_coll_id,1);
                                cln_debug_pub.add('x_return_status      - ' || l_return_status,1);
                                cln_debug_pub.add('x_msg_data           - ' || l_msg_data,1);
                        END IF;

                        x_return_status := l_return_status;
                        x_msg_data      := l_msg_data;

                        IF(l_return_status <> 'S') THEN
                                RETURN;
                                IF (g_debug_Level <= 2) THEN
                                        cln_debug_pub.add('Exiting process_rfcin_notification - ' || l_return_status,2);
                                        cln_debug_pub.add('===========================================',2);
                                END IF;
                        END IF;

                        l_notif_mesg    := 'Request For CIN, received on with following details';

                        l_event_params  := wf_parameter_list_t();
                        wf_event.AddParameterToList(
                                        p_name          => 'COLLABORATION_ID',
                                        p_value         => l_coll_id,
                                        p_parameterlist => l_event_params   );

                        wf_event.AddParameterToList(
                                        p_name          => 'COLLABORATION_POINT',
                                        p_value         => 'APPS',
                                        p_parameterlist => l_event_params   );

                        wf_event.AddParameterToList(
                                        p_name          => 'APPLICATION_ID',
                                        p_value         => m4u_ucc_utils.c_resp_appl_id,
                                        p_parameterlist => l_event_params   );

                        wf_event.AddParameterToList(
                                        p_name          => 'NOTIFICATION_CODE',
                                        p_value         => 'M4URFCIN',
                                        p_parameterlist => l_event_params   );

                        wf_event.AddParameterToList(
                                        p_name          => 'NOTIFICATION_STATUS',
                                        p_value         => 'SUCCESS',
                                        p_parameterlist => l_event_params   );

                        wf_event.AddParameterToList(
                                        p_name          => 'NOTIFICATION_DESC',
                                        p_value         => l_notif_mesg,
                                        p_parameterlist => l_event_params   );


                        l_event_key     := 'RESP_RFCIN_' || l_coll_id;

                        IF (g_debug_Level <= 1) THEN
                                cln_debug_pub.Add('-- CLN notification raised -- event_key ' || l_event_key, 1);
                        END IF;

                        -- raise event to trigger outbound wlq generation WF
                        wf_event.raise(
                                p_event_name            => l_event_name,
                                p_event_key             => l_event_key,
                                p_parameters            => l_event_params
                                );

                        IF (g_debug_Level <= 2) THEN
                                cln_debug_pub.Add('-- Exiting m4u_resp_process.process_rfcin_notification success-- ', 2);
                        END IF;



                        RETURN;
        EXCEPTION
                WHEN OTHERS THEN

                        -- log exception and exit.
                        l_error_code            := SQLCODE;
                        l_error_msg             := SQLERRM;
                        x_return_status         := 'F';
                        x_msg_data              := ' - Unexpected error in m4u_resp_process.process_rfcin_notification' || l_error_code || ':' || l_error_msg;


                        IF (g_debug_Level <= 5) THEN
                                cln_debug_pub.add(l_error_code || ':' || l_error_msg, 4);
                        END IF;

                        IF (g_debug_Level <= 2) THEN
                                cln_debug_pub.add('Exiting process_rfcin_notification - exception',2);
                                cln_debug_pub.add('==============================================',2);
                        END IF;
        END;


        BEGIN
                g_debug_level   := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));
END m4u_resp_process;

/
