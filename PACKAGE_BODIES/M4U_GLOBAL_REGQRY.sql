--------------------------------------------------------
--  DDL for Package Body M4U_GLOBAL_REGQRY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."M4U_GLOBAL_REGQRY" AS
/* $Header: M4UQRREB.pls 120.2 2005/07/07 04:14:49 rkrishan noship $ */
   l_debug_level        NUMBER ;
   G_PKG_NAME CONSTANT     VARCHAR2(30)    := 'm4u_global_regqry';




        -- Name
        --      raise_regqry_event
        -- Purpose
        --      This procedure is called from a concurrent program.
        --      The 'oracle.apps.m4u.registryquery.generate' is raised with the supplied event parameters
        --      The sequence m4u_wlqid_sequence is used to obtain unique event key.
        -- Arguments
        -- Notes
        --
        PROCEDURE raise_regqry_event(
                x_errbuf                OUT NOCOPY VARCHAR2,
                x_retcode               OUT NOCOPY NUMBER,
                p_qr_ipgln              IN VARCHAR2,
                p_qr_gtin               IN VARCHAR2,
                p_qr_targtMarkt         IN VARCHAR2
          )
        IS
                l_event_key             VARCHAR2(50);
                l_event_parameters      wf_parameter_list_t;
                l_error_code            VARCHAR2(50);
                l_error_msg             VARCHAR2(50);
                l_msg_data              VARCHAR2(50);
                x_return_status         VARCHAR2(50);
                x_msg_data              VARCHAR2(100);

        BEGIN

                IF (l_debug_Level <= 2) THEN
                        cln_debug_pub.Add('M4U:----- Entering RAISE_REGQRY_EVENT  ------- ',2);
                END IF;


                -- Initialize API return status to success
                x_return_status         := FND_API.G_RET_STS_SUCCESS;
                l_msg_data              := 'Event for querying Global Registry raised';


                -- Parameters received
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('++++ PARAMETERS RECEIVED FROM CONCURRENT PROGRAM ++ ',1);
                        cln_debug_pub.Add('p_qr_ipgln            - '||p_qr_ipgln  ,1);
                        cln_debug_pub.Add('p_qr_gtin             - '||p_qr_gtin,1);
                        cln_debug_pub.Add('p_qr_targtMarkt       - '||p_qr_targtMarkt,1);
                        cln_debug_pub.Add('+++++++++++++++++++++++++++++++++++++++++++++++++++',1);
                END IF;

                -- Validation of the UCCnet parameters

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('++++++ VALIDATION OF THE UCCNET PARAMETERS ++++++ ',1);
                END IF;

                -- 1. Validation of the GLN
                IF NOT m4u_ucc_utils.validate_uccnet_attr
                                   (
                                        x_return_status         => x_return_status,
                                        x_msg_data              => x_msg_data,
                                        p_attr_type             => 'GLN',
                                        p_attr_value            => p_qr_ipgln
                                   )THEN
                         l_msg_data  := 'GLN validation failed';
                         RAISE FND_API.G_EXC_ERROR;
                END IF;

                -- 2. Validation of the GTIN
                IF NOT m4u_ucc_utils.validate_uccnet_attr(
                                        x_return_status         => x_return_status,
                                        x_msg_data              => x_msg_data,
                                        p_attr_type             => 'GTIN',
                                        p_attr_value            => p_qr_gtin
                                    )THEN
                         l_msg_data  := 'GTIN validation failed';
                         RAISE FND_API.G_EXC_ERROR;
                END IF;

                -- 3. Validation of the Target Market
                IF NOT m4u_ucc_utils.validate_uccnet_attr(
                                        x_return_status         => x_return_status,
                                        x_msg_data              => x_msg_data,
                                        p_attr_type             => 'TRGMKT',
                                        p_attr_value            => p_qr_targtMarkt
                                    )THEN
                         l_msg_data  := 'Target Market validation failed';
                         RAISE FND_API.G_EXC_ERROR;
                END IF;




                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('++++++ VALIDATION DONE WITH SUCCESS ++++++ ',1);
                END IF;

                -- obtain a unique event-id
                SELECT  m4u_wlqid_s.NEXTVAL
                INTO    l_event_key
                FROM    dual;

                l_event_key := 'M4U_QRYREG_' || l_event_key;

                -- pass Concurrent program parameters as event parameters,
                -- to be used in outboud xml generation map.

                l_event_parameters := wf_parameter_list_t();

                wf_event.AddParameterToList(
                                        p_name          => 'ECX_EVENT_KEY',
                                        p_value         => l_event_key,
                                        p_parameterlist => l_event_parameters   );
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ECX_EVENT_KEY                        - '||l_event_key,1);
                END IF;

                wf_event.AddParameterToList(
                                        p_name          => 'M4U_DOC_NO',
                                        p_value         => l_event_key,
                                        p_parameterlist => l_event_parameters   );
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('M4U_DOC_NO                           - '||l_event_key,1);
                END IF;

                IF (l_Debug_Level <= 1) THEN
                         cln_debug_pub.Add('ECX_PARAMETER2   - IP GLN            - '||p_qr_ipgln,1);
                END IF;
                wf_event.AddParameterToList(
                                        p_name          => 'ECX_PARAMETER2',
                                        p_value         => p_qr_ipgln,
                                        p_parameterlist => l_event_parameters   );
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ECX_PARAMETER2   - IP GLN            - '||p_qr_ipgln,1);
                END IF;


                wf_event.AddParameterToList(
                                        p_name          => 'ECX_PARAMETER3',
                                        p_value         => p_qr_gtin,
                                        p_parameterlist => l_event_parameters   );
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ECX_PARAMETER3   - GTIN              -'||p_qr_gtin,1);
                END IF;

                wf_event.AddParameterToList(
                                        p_name          => 'ECX_PARAMETER4',
                                        p_value         => p_qr_targtMarkt,
                                        p_parameterlist => l_event_parameters   );
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ECX_PARAMETER4   - Target Market     -'||p_qr_targtMarkt,1);
                END IF;

                wf_event.AddParameterToList(
                                        p_name          => 'ECX_TRANSACTION_TYPE',
                                        p_value         => 'M4U',
                                        p_parameterlist => l_event_parameters   );
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ECX_TRANSACTION_TYPE                 - M4U',1);
                END IF;

                wf_event.AddParameterToList(
                                        p_name          => 'ECX_TRANSACTION_SUBTYPE',
                                        p_value         => 'GBREGQRY',
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
                                        p_name          => 'M4U_CLN_COLL_TYPE',
                                        p_value         => 'M4U_REGISTRY_QUERY',
                                        p_parameterlist => l_event_parameters   );
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('M4U_CLN_COLL_TYPE                    - M4U_REGISTRY_QUERY');
                END IF;

                wf_event.AddParameterToList(
                                        p_name          => 'M4U_CLN_DOC_TYPE',
                                        p_value         => 'M4U_REGISTRY_QUERY',
                                        p_parameterlist => l_event_parameters   );
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('M4U_CLN_DOC_TYPE                     - M4U_REGISTRY_QUERY');
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
                        cln_debug_pub.Add('--  Raising Event oracle.apps.m4u.outboundwf.generate  -- ',1);
                        cln_debug_pub.Add('p_event_key                          - '||l_event_key ,1);
                END IF;


                -- raise event to trigger outbound wlq generation WF
                wf_event.raise(
                                --p_event_name            => 'oracle.apps.m4u.gbregistryqry.generate',
                                p_event_name            => 'oracle.apps.m4u.outboundwf.generate',
                                p_event_key             => l_event_key,
                                p_parameters            => l_event_parameters
                              );

                x_retcode  := 0;
                x_errbuf   := 'Successful';

                -- check the message
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add(l_msg_data,1);
                END IF;

                IF (l_Debug_Level <= 2) THEN
                        cln_debug_pub.Add('------- Exiting raise_regqry_event API --------- ',2);
                END IF;


        -- Exception Handling
        EXCEPTION
             WHEN FND_API.G_EXC_ERROR THEN
                    x_retcode          := 2 ;
                    x_errbuf           := x_msg_data;

                    IF (l_Debug_Level <= 5) THEN
                            cln_debug_pub.Add(l_msg_data,4);
                            cln_debug_pub.Add('Details: '||x_msg_data,4);
                            cln_debug_pub.Add('------- Exiting raise_regqry_event API --------- ',2);
                    END IF;


             WHEN OTHERS THEN
                    l_error_code       :=SQLCODE;
                    l_error_msg        :=SQLERRM;
                    x_retcode          :=2 ;

                    FND_MESSAGE.SET_NAME('CLN','CLN_CH_UNEXPECTED_ERROR');
                    FND_MESSAGE.SET_TOKEN('ERRORCODE',l_error_code);
                    FND_MESSAGE.SET_TOKEN('ERRORMSG',l_error_msg);
                    x_errbuf           := FND_MESSAGE.GET;

                    IF (l_Debug_Level <= 5) THEN
                            cln_debug_pub.Add(x_errbuf,6);
                            cln_debug_pub.Add('------- Exiting raise_regqry_event API --------- ',2);
                    END IF;
        END;

        -- Name
        --      process_gtin_resp
        -- Purpose
        --      This procedure is called from the XGM m4u_230_resp_gbreqry_in
        --      This procedure updates the UCCnet Registry-query collaboration with GTIN info
        -- Arguments
        --      RCIR Item Attributes
        --      p_success_flag                  - Query success/failure flag
        --      p_gtin_query_id                 - GTIN query Id
        --      p_ucc_doc_unique_id             - UCC Doc Unique ID
        --      p_xmlg_internal_control_no      - XMLG ICN from map
        --      x_return_status                 - API ret status
        --      x_msg_data                      - API ret msg
        -- Notes
        --      none
        PROCEDURE process_gtin_resp(
                p_gtin                          IN VARCHAR2,
                p_data_source                   IN VARCHAR2,
                p_target_market                 IN VARCHAR2,
                p_src_data_pool                 IN VARCHAR2,
                p_reg_data_pool                 IN VARCHAR2,
                p_name_of_info_provider         IN VARCHAR2,
                p_brand_owner_name              IN VARCHAR2,
                p_brand_owner_gln               IN VARCHAR2,
                p_brand_name                    IN VARCHAR2,
                p_trade_item_unit_desc          IN VARCHAR2,
                p_eanucc_code                   IN VARCHAR2,
                p_eanucc_type                   IN VARCHAR2,
                p_delivery_method               IN VARCHAR2,
                p_consumer_unit                 IN VARCHAR2,
                p_ord_unit                      IN VARCHAR2,
                p_effective_date                IN VARCHAR2,
                p_next_level_cnt                IN VARCHAR2,
                p_gross_wt                      IN VARCHAR2,
                p_gross_wt_uom                  IN VARCHAR2,
                p_height                        IN VARCHAR2,
                p_height_uom                    IN VARCHAR2,
                p_width                         IN VARCHAR2,
                p_width_uom                     IN VARCHAR2,
                p_depth                         IN VARCHAR2,
                p_depth_uom                     IN VARCHAR2,
                p_volume                        IN VARCHAR2,
                p_volume_uom                    IN VARCHAR2,
                p_net_content                   IN VARCHAR2,
                p_net_content_uom               IN VARCHAR2,
                p_net_wt                        IN VARCHAR2,
                p_net_wt_uom                    IN VARCHAR2,
                p_is_info_pvt                   IN VARCHAR2,
                p_success_flag                  IN VARCHAR2,
                p_gtin_query_id                 IN VARCHAR2,
                p_ucc_doc_unique_id             IN VARCHAR2,
                p_xmlg_internal_control_no      IN NUMBER,
                x_collab_dtl_id                 OUT NOCOPY NUMBER,
                x_return_status                 OUT NOCOPY VARCHAR2,
                x_msg_data                      OUT NOCOPY VARCHAR2 )
        IS
                l_error_code                    VARCHAR2(50);
                l_error_msg                     VARCHAR2(1000);
                l_disposition                   VARCHAR2(50);
                l_coll_status                   VARCHAR2(50);
                l_fnd_msg                       VARCHAR2(1000);
                l_doc_status                    VARCHAR2(50);
                l_item_measurmnts               VARCHAR2(2000);
                l_collab_detail_id              NUMBER;
        BEGIN

                -- Parameters received
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('---- m4u_global_regqry.process_gtin_resp ---- '             ,1);
                        cln_debug_pub.Add('p_gtin                       - '|| p_gtin               ,1);
                        cln_debug_pub.Add('p_data_source                - '|| p_data_source        ,1);
                        cln_debug_pub.Add('p_target_market              - '|| p_target_market  ,1);
                        cln_debug_pub.Add('p_src_data_pool              - '|| p_src_data_pool           ,1);
                        cln_debug_pub.Add('p_reg_data_pool              - '|| p_reg_data_pool    ,1);
                        cln_debug_pub.Add('p_name_of_info_provider      - '|| p_name_of_info_provider,1);
                        cln_debug_pub.Add('p_brand_owner_name           - '|| p_brand_owner_name   ,1);
                        cln_debug_pub.Add('p_brand_owner_gln            - '|| p_brand_owner_gln    ,1);
                        cln_debug_pub.Add('p_brand_name                 - '|| p_brand_name         ,1);
                        cln_debug_pub.Add('p_trade_item_unit_desc       - '|| p_trade_item_unit_desc,1);
                        cln_debug_pub.Add('p_eanucc_code                - '|| p_eanucc_code        ,1);
                        cln_debug_pub.Add('p_eanucc_type                - '|| p_eanucc_type        ,1);
                        cln_debug_pub.Add('p_delivery_method            - '|| p_delivery_method    ,1);
                        cln_debug_pub.Add('p_consumer_unit              - '|| p_consumer_unit      ,1);
                        cln_debug_pub.Add('p_ord_unit                   - '|| p_ord_unit           ,1);
                        cln_debug_pub.Add('p_effective_date             - '|| p_effective_date     ,1);
                        cln_debug_pub.Add('p_next_level_cnt             - '|| p_next_level_cnt     ,1);
                        cln_debug_pub.Add('p_gross_wt                   - '|| p_gross_wt           ,1);
                        cln_debug_pub.Add('p_gross_wt_uom               - '|| p_gross_wt_uom       ,1);
                        cln_debug_pub.Add('p_height                     - '|| p_height             ,1);
                        cln_debug_pub.Add('p_height_uom                 - '|| p_height_uom         ,1);
                        cln_debug_pub.Add('p_width                      - '|| p_width              ,1);
                        cln_debug_pub.Add('p_width_uom                  - '|| p_width_uom          ,1);
                        cln_debug_pub.Add('p_depth                      - '|| p_depth              ,1);
                        cln_debug_pub.Add('p_depth_uom                  - '|| p_depth_uom          ,1);
                        cln_debug_pub.Add('p_volume                     - '|| p_volume             ,1);
                        cln_debug_pub.Add('p_volume_uom                 - '|| p_volume_uom         ,1);
                        cln_debug_pub.Add('p_net_content                - '|| p_net_content        ,1);
                        cln_debug_pub.Add('p_net_content_uom            - '|| p_net_content_uom    ,1);
                        cln_debug_pub.Add('p_net_wt                     - '|| p_net_wt             ,1);
                        cln_debug_pub.Add('p_net_wt_uom                 - '|| p_net_wt_uom         ,1);
                        cln_debug_pub.Add('p_is_info_pvt                - '|| p_is_info_pvt        ,1);
                        cln_debug_pub.Add('p_success_flag               - '|| p_success_flag       ,1);
                        cln_debug_pub.Add('p_gtin_query_id              - '|| p_gtin_query_id      ,1);
                        cln_debug_pub.Add('p_ucc_doc_unique_id          - '|| p_ucc_doc_unique_id    ,1);
                        cln_debug_pub.Add('p_xmlg_internal_control_no   - '|| p_xmlg_internal_control_no    ,1);
                        cln_debug_pub.Add('-------------------------------------------'           ,1);
                END IF;


                -- set CLN Disposition, CLN Coll Status, CLN Doc status, CLN Message Text
                IF (UPPER(p_success_flag)   = 'TRUE') THEN
                        l_disposition   := 'ACCEPTED' ;
                        l_coll_status   := 'COMPLETED';
                        l_doc_status    := 'SUCCESS';
                        l_fnd_msg       := 'M4U_GTINQRY_SUCCESS';
                ELSE
                        l_disposition   := 'FAILED' ;
                        l_coll_status   := 'ERROR';
                        l_doc_status    := 'ERROR';
                        l_fnd_msg       := 'M4U_GTINQRY_FAILURE';
                END IF;

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('-- Update collaboration parameters set -',1);
                        cln_debug_pub.Add('Disposition          - '|| l_disposition ,1);
                        cln_debug_pub.Add('Collaboration Status - '|| l_coll_status ,1);
                        cln_debug_pub.Add('Document Status      - '|| l_doc_status  ,1);
                        cln_debug_pub.Add('FND Message          - '|| l_fnd_msg     ,1);
                        cln_debug_pub.Add('---------------------------------------' ,1);
                END IF;

                cln_ch_collaboration_pkg.update_collaboration(
                        x_return_status                  => x_return_status,
                        x_msg_data                       => x_msg_data,
                        p_coll_id                        => p_gtin_query_id,
                        p_msg_text                       => l_fnd_msg,
                        p_xmlg_msg_id                    => NULL,
                        p_xmlg_transaction_type          => 'M4U',
                        p_xmlg_transaction_subtype       => 'RESP_GTIN',
                        p_xmlg_int_transaction_type      => 'M4U',
                        p_xmlg_int_transaction_subtype   => 'RESP_GTIN',
                        p_doc_dir                        => 'IN',
                        p_doc_type                       => 'M4U_RESP_GTIN',
                        p_disposition                    => l_disposition,
                        p_doc_status                     => l_doc_status,
                        p_coll_status                    => l_coll_status,
                        p_xmlg_document_id               => NULL,
                        p_xmlg_internal_control_number   => p_xmlg_internal_control_no,
                        p_tr_partner_type                => m4u_ucc_utils.c_party_type,
                        p_tr_partner_id                  => m4u_ucc_utils.g_party_id,
                        p_tr_partner_site                => m4u_ucc_utils.g_party_site_id,
                        p_attribute2                     => p_target_market,
                        p_attribute3                     => p_gtin,
                        p_attribute4                     => p_name_of_info_provider,
                        p_attribute6                     => p_brand_owner_gln,
                        p_attribute7                     => p_brand_owner_name,
                        p_attribute8                     => p_ucc_doc_unique_id,
                        p_attribute9                     => p_trade_item_unit_desc,
                        p_attribute10                    => p_eanucc_code||'-'||p_eanucc_type,
                        p_attribute11                    => p_success_flag,
                        p_attribute13                    => p_delivery_method,
                        p_attribute14                    => p_is_info_pvt,
                        p_attribute15                    => p_brand_name,
                        p_dattribute1                    => sysdate,
                        p_dattribute2                    => null,
                        p_rosettanet_check_required      => false,
                        x_dtl_coll_id                    => l_collab_detail_id  );

                IF(x_return_status <> 'S') THEN
                        RAISE FND_API.G_EXC_ERROR;
                END IF;


                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('-- Update Collab API returns Values  -'           ,1);
                        cln_debug_pub.Add('Collab Detail Id         - '|| l_collab_detail_id ,1);
                        cln_debug_pub.Add('CLN API Return Status    - '|| x_return_status    ,1);
                        cln_debug_pub.Add('CLN return msg data      - '|| x_msg_data         ,1);
                END IF;

                -- assign the collab dtl id to out variable
                x_collab_dtl_id := l_collab_detail_id;

                -- check for error. If the return status is failure, move out with the
                -- collaboration detail id
                IF (UPPER(p_success_flag)   <> 'TRUE') THEN
                        IF (l_Debug_Level <= 1) THEN
                                cln_debug_pub.Add('-- Error Status :Returning  -'  ,1);
                                cln_debug_pub.Add('Collaboration Detail ID - '||l_collab_detail_id ,1);
                                cln_debug_pub.Add('Exiting - m4u_global_regqry.process_gtin_resp - Response status as false',2);
                        END IF;
                        RETURN;
                END IF;

                IF (
                   (p_gross_wt IS NULL) AND
                   (p_gross_wt_uom IS NULL) AND
                   (p_height_uom IS NULL) AND
                   (p_height IS NULL) AND
                   (p_width IS NULL) AND
                   (p_width_uom IS NULL) AND
                   (p_depth IS NULL) AND
                   (p_depth_uom IS NULL) AND
                   (p_volume IS NULL) AND
                   (p_volume_uom IS NULL) AND
                   (p_net_content IS NULL) AND
                   (p_net_content_uom IS NULL) AND
                   (p_net_wt IS NULL) AND
                   (p_net_wt_uom IS NULL)) THEN
                        IF (l_Debug_Level <= 1) THEN
                                cln_debug_pub.Add('Measurement Values all null. Information requestor different from content owner'  ,1);
                                cln_debug_pub.Add('Returning with success...'  ,1);
                                cln_debug_pub.Add('Exiting - m4u_global_regqry.process_gtin_resp Normal',2);
                        END IF;

                        RETURN;
                   END IF;


                l_item_measurmnts := 'Gross Wt - '||p_gross_wt
                                     ||'( '||p_gross_wt_uom||' )'
                                     ||' Height - '||p_height
                                     ||'( '||p_height_uom||' )'
                                     ||' Width  - '||p_width
                                     ||'( '||p_width_uom||' )'
                                     ||' Depth  - '||p_depth
                                     ||'( '||p_depth_uom||' )'
                                     ||' Volume - '||p_volume
                                     ||'( '||p_volume_uom||' )'
                                     ||' Net Content - '||p_net_content
                                     ||'( '||p_net_content_uom||' )'
                                     ||' Net Weight  - '||p_net_wt
                                     ||'( '||p_net_wt_uom||' )';

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('---- Item Measurements ---',1);
                        cln_debug_pub.Add(l_item_measurmnts,1);
                        cln_debug_pub.Add('---- ----------------- ---',1);
                END IF;

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('----- Call to Add Collaboration Messages -----',1);
                END IF;

                CLN_CH_COLLABORATION_PKG.ADD_COLLABORATION_MESSAGES(
                     x_return_status                    => x_return_status,
                     x_msg_data                         => x_msg_data,
                     p_dtl_coll_id                      => l_collab_detail_id,
                     p_ref1                             => 'Item Measurements',
                     p_dtl_msg                          => l_item_measurmnts
                );

                IF(x_return_status <> 'S') THEN
                        RAISE FND_API.G_EXC_ERROR;
                END IF;

                IF (l_Debug_Level <= 2) THEN
                        cln_debug_pub.Add('Exiting - m4u_global_regqry.process_gtin_resp Normal',2);
                END IF;

        EXCEPTION
             WHEN FND_API.G_EXC_ERROR THEN
                x_return_status := FND_API.G_RET_STS_ERROR ;
                IF (l_Debug_Level <= 4) THEN
                      cln_debug_pub.Add(x_msg_data,4);
                      cln_debug_pub.Add('------- Exiting m4u_global_regqry.process_gtin_resp - exception --------- ',2);
                END IF;

             WHEN OTHERS THEN
                l_error_code    := SQLCODE;
                l_error_msg     := SQLERRM;
                x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;

                FND_MESSAGE.SET_NAME('CLN','CLN_CH_UNEXPECTED_ERROR');
                FND_MESSAGE.SET_TOKEN('ERRORCODE',l_error_code);
                FND_MESSAGE.SET_TOKEN('ERRORMSG',l_error_msg);

                x_msg_data           := FND_MESSAGE.GET;

                IF (l_debug_level <= 5) THEN
                        cln_debug_pub.add(l_error_code || ':' || l_error_msg, 4);
                END IF;

                IF (l_debug_level <= 2) THEN
                        cln_debug_pub.add('Exiting m4u_global_regqry.process_gtin_resp - exception',2);
                        cln_debug_pub.add('====================================================',2);
                END IF;

        END;

        BEGIN
                l_debug_level           := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));
END m4u_global_regqry;

/
