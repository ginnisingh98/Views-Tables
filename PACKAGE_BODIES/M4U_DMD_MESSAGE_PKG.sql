--------------------------------------------------------
--  DDL for Package Body M4U_DMD_MESSAGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."M4U_DMD_MESSAGE_PKG" AS
 /* $Header: M4UDMSGB.pls 120.5 2007/08/29 10:23:17 bsaratna noship $ */

  PROCEDURE create_dom_from_clob_pvt
  (
        p_xml         IN                CLOB,
        x_dom         OUT NOCOPY        xmldom.domdocument
  )
  IS
        l_prsr              xmlparser.parser;
  BEGIN
        m4u_dmd_utils.log('Entering m4u_dmd_messages.create_dom_from_clob_pvt',2);

        l_prsr := xmlparser.newparser;
        m4u_dmd_utils.log('Got XMLparser handle'        ,2);

        xmlparser.setValidationMode(l_prsr, FALSE);
        xmlparser.setPreserveWhiteSpace(l_prsr, TRUE);
        m4u_dmd_utils.log('Set parser properties'       ,2);

        xmlparser.parseCLOB (l_prsr, p_xml);
        m4u_dmd_utils.log('Parse clob successfull'      ,2);

        x_dom := xmlparser.getdocument (l_prsr);
        m4u_dmd_utils.log('XML dom obtained'            ,2);

        xmlparser.freeparser (l_prsr);
        m4u_dmd_utils.log('Exiting m4u_dmd_messages.create_dom_from_clob_pvt',2);

   END create_dom_from_clob_pvt;

    PROCEDURE send_rfcin
    (
        p_user_gln              IN VARCHAR2,
        p_retailer_gln          IN VARCHAR2,
        p_datapool_gln          IN VARCHAR2,

        p_reload_flag           IN VARCHAR2,
        p_info_provider_gln     IN VARCHAR2,
        p_tgt_mkt_country       IN VARCHAR2,
        p_tgt_mkt_subdiv        IN VARCHAR2,
        p_gtin                  IN VARCHAR2,
        p_cat_type              IN VARCHAR2,
        p_cat_code              IN VARCHAR2,
        x_msg_id                OUT NOCOPY  VARCHAR2,
        x_ret_sts               OUT NOCOPY  VARCHAR2,
        x_ret_msg               OUT NOCOPY  VARCHAR2
    ) AS
        l_msg_id      VARCHAR2(30);
        l_doc_id      VARCHAR2(30);
        l_ret_sts     VARCHAR2(1);
        l_ret_msg     VARCHAR2(4000);
        l_err_msg     VARCHAR2(4000);
        l_err_api     VARCHAR2(100) := 'm4u_dmd_message_pkg.send_rfcin';
        l_user_id     VARCHAR2(100);
    BEGIN


        m4u_dmd_utils.log('Entering m4u_dmd_request.send_rfcin'             ,2);


        m4u_dmd_utils.log('====================================='           ,1);
        m4u_dmd_utils.log('p_user_gln       -|' || p_user_gln         || '|',1);
        m4u_dmd_utils.log('p_retailer_gln   -|' || p_retailer_gln     || '|',1);
        m4u_dmd_utils.log('p_datapool_gln   -|' || p_datapool_gln     || '|',1);

        m4u_dmd_utils.log('p_reload_flag    -|' || p_reload_flag      || '|',1);
        m4u_dmd_utils.log('p_tgt_mkt_country-|' || p_tgt_mkt_country  || '|',1);
        m4u_dmd_utils.log('p_tgt_mkt_subdiv -|' || p_tgt_mkt_subdiv   || '|',1);
        m4u_dmd_utils.log('p_gtin           -|' || p_gtin             || '|',1);
        m4u_dmd_utils.log('p_cat_type       -|' || p_cat_type         || '|',1);
        m4u_dmd_utils.log('p_cat_code       -|' || p_cat_code         || '|',1);
        m4u_dmd_utils.log('p_info_prv_gln   -|' || p_info_provider_gln|| '|',1);


        l_user_id := m4u_dmd_utils.get_gln_user(p_user_gln);

        m4u_dmd_utils.log('l_user_id        -|' || l_user_id          || '|',1);
        m4u_dmd_utils.log('====================================='           ,1);

        m4u_dmd_utils.log('Call m4u_dmd_requests.create_request'  ,1);
        m4u_dmd_requests.create_request
        (
                p_type                => m4u_dmd_utils.c_type_rfcin,
                p_direction           => m4u_dmd_utils.c_dir_out,
                p_status              => m4u_dmd_utils.c_sts_ready,
                p_msg_timstamp        => sysdate,
                p_orig_msg_id         => 'GENERATE',

                p_sender_gln          => p_user_gln,
                p_receiver_gln        => p_datapool_gln,
                p_rep_party_gln       => p_retailer_gln,
                p_user_gln            => p_user_gln,
                p_user_id             => l_user_id,

                x_msg_id              => l_msg_id,
                x_ret_sts             => l_ret_sts,
                x_ret_msg             => l_ret_msg
         );

        m4u_dmd_utils.log('l_ret_sts - |' || l_ret_sts || '|',1);
        m4u_dmd_utils.log('l_ret_msg - |' || l_ret_msg || '|',1);
        m4u_dmd_utils.log('l_msg_id  - |' || l_msg_id  || '|',1);

        IF l_ret_sts <> fnd_api.g_ret_sts_success THEN
            l_err_msg := l_ret_msg;
            RAISE fnd_api.g_exc_error;
        END IF;

        m4u_dmd_utils.log('Call m4u_dmd_requests.create_document'  ,1);

        m4u_dmd_requests.create_document
        (
                p_msg_id                => l_msg_id,
                p_type                  => m4u_dmd_utils.c_type_rfcin,
                p_action                => m4u_dmd_utils.c_action_add,
                p_doc_status            => m4u_dmd_utils.c_sts_ready,
                p_func_status           => null,
                p_processing_msg        => null,
                p_timestamp             => sysdate,
                p_orig_doc_id           => 'GENERATE',

                p_top_gtin              => p_gtin,
                p_info_provider_gln     => p_info_provider_gln,
                p_data_rcpt_gln         => nvl(p_retailer_gln,p_user_gln),
                p_tgt_mkt_ctry          => p_tgt_mkt_country,
                p_tgt_mkt_div           => p_tgt_mkt_subdiv,

                p_param1                => substr(p_reload_flag,1,50),
                p_param2                => substr(p_cat_type,1,50),
                p_param3                => substr(p_cat_code,1,50),

                x_doc_id                => l_doc_id,
                x_ret_sts               => l_ret_sts,
                x_ret_msg               => l_ret_msg
        );

        m4u_dmd_utils.log('l_ret_sts - |' || l_ret_sts || '|',1);
        m4u_dmd_utils.log('l_ret_msg - |' || l_ret_msg || '|',1);
        m4u_dmd_utils.log('l_doc_id  - |' || l_doc_id  || '|',1);

        IF l_ret_sts <> fnd_api.g_ret_sts_success THEN
                l_err_msg := l_ret_msg;
                RAISE fnd_api.g_exc_error;
        END IF;

        x_ret_sts := fnd_api.g_ret_sts_success;
        x_ret_msg := '';
        x_msg_id  := l_msg_id;

        m4u_dmd_utils.log('Exiting m4u_dmd_request.send_rfcin - Success' ,2);
        RETURN; --success

    EXCEPTION
        WHEN OTHERS THEN
                m4u_dmd_utils.handle_error(l_err_api,l_err_msg,
                            SQLCODE,SQLERRM,x_ret_sts,x_ret_msg);
                RETURN; --fail
    END send_rfcin;

    PROCEDURE send_cis
    (
        p_cis_name              IN VARCHAR2,

        p_user_gln              IN VARCHAR2,
        p_retailer_gln          IN VARCHAR2,
        p_datapool_gln          IN VARCHAR2,

        p_operation             IN VARCHAR2,
        p_info_provider_gln     IN VARCHAR2,
        p_tgt_mkt_country       IN VARCHAR2,
        p_tgt_mkt_subdiv        IN VARCHAR2,
        p_gtin                  IN VARCHAR2,
        p_cat_type              IN VARCHAR2,
        p_cat_code              IN VARCHAR2,
        x_msg_id                OUT NOCOPY  VARCHAR2,
        x_ret_sts               OUT NOCOPY  VARCHAR2,
        x_ret_msg               OUT NOCOPY  VARCHAR2

    ) AS
        l_ret_sts     VARCHAR2(1);
        l_ret_msg     VARCHAR2(4000);
        l_msg_id      VARCHAR2(30);
        l_doc_id      VARCHAR2(30);
        l_err_msg     VARCHAR2(4000);
        l_err_api     VARCHAR2(30) := 'm4u_dmd_message_pkg.send_cis';
        l_user_id     VARCHAR2(100);
    BEGIN

        m4u_dmd_utils.log('Entering m4u_dmd_request.send_cis',                2);
        m4u_dmd_utils.log('=====================================',            1);
        m4u_dmd_utils.log('p_cis_name        -|' || p_cis_name         || '|',1);
        m4u_dmd_utils.log('p_user_gln        -|' || p_user_gln         || '|',1);
        m4u_dmd_utils.log('p_retailer_gln    -|' || p_retailer_gln     || '|',1);
        m4u_dmd_utils.log('p_datapool_gln    -|' || p_datapool_gln     || '|',1);
        m4u_dmd_utils.log('p_operation       -|' || p_operation        || '|',1);
        m4u_dmd_utils.log('p_tgt_mkt_country -|' || p_tgt_mkt_country  || '|',1);
        m4u_dmd_utils.log('p_tgt_mkt_subdiv  -|' || p_tgt_mkt_subdiv   || '|',1);
        m4u_dmd_utils.log('p_gtin            -|' || p_gtin             || '|',1);
        m4u_dmd_utils.log('p_cat_type        -|' || p_cat_type         || '|',1);
        m4u_dmd_utils.log('p_cat_code        -|' || p_cat_code         || '|',1);
        m4u_dmd_utils.log('p_info_prv_gln    -|' || p_info_provider_gln|| '|',1);


        l_user_id := m4u_dmd_utils.get_gln_user(p_user_gln);


        m4u_dmd_utils.log('l_user_id        -|' || l_user_id           || '|',1);
        m4u_dmd_utils.log('=====================================',            1);
        m4u_dmd_utils.log('Call m4u_dmd_requests.create_request'  ,           1);

        m4u_dmd_requests.create_request
        (
                p_type                => m4u_dmd_utils.c_type_cis,
                p_direction           => m4u_dmd_utils.c_dir_out,
                p_status              => m4u_dmd_utils.c_sts_ready,
                p_msg_timstamp        => sysdate,
                p_orig_msg_id         => 'GENERATE',

                p_sender_gln          => p_user_gln,
                p_receiver_gln        => p_datapool_gln,
                p_rep_party_gln       => p_retailer_gln,
                p_user_gln            => p_user_gln,
                p_user_id             => l_user_id,

                x_msg_id              => l_msg_id,
                x_ret_sts             => l_ret_sts,
                x_ret_msg             => l_ret_msg
         );

        m4u_dmd_utils.log('l_ret_sts - |' || l_ret_sts || '|',1);
        m4u_dmd_utils.log('l_ret_msg - |' || l_ret_msg || '|',1);
        m4u_dmd_utils.log('l_msg_id  - |' || l_msg_id  || '|',1);

        IF l_ret_sts <> fnd_api.g_ret_sts_success THEN
                l_err_msg := l_ret_msg;
                RAISE fnd_api.g_exc_error;
        END IF;

        m4u_dmd_utils.log('Call m4u_dmd_requests.create_document'  ,1);
        m4u_dmd_requests.create_document
        (
                p_msg_id                => l_msg_id,
                p_type                  => m4u_dmd_utils.c_type_cis,
                p_action                => p_operation,
                p_doc_status            => m4u_dmd_utils.c_sts_ready,
                p_func_status           => null,
                p_processing_msg        => null,
                p_orig_doc_id           => 'GENERATE',

                p_top_gtin              => p_gtin,
                p_info_provider_gln     => p_info_provider_gln,
                p_data_rcpt_gln         => nvl(p_retailer_gln,p_user_gln),
                p_tgt_mkt_ctry          => p_tgt_mkt_country,
                p_tgt_mkt_div           => p_tgt_mkt_subdiv,

                p_param1                => null,
                p_param2                => substr(p_cat_type,1,50),
                p_param3                => substr(p_cat_code,1,50),
                p_lparam1               => substr(p_cis_name,1,100),

                x_doc_id                => l_doc_id,
                x_ret_sts               => l_ret_sts,
                x_ret_msg               => l_ret_msg
        );

        m4u_dmd_utils.log('l_ret_sts - |' || l_ret_sts || '|',1);
        m4u_dmd_utils.log('l_ret_msg - |' || l_ret_msg || '|',1);
        m4u_dmd_utils.log('l_doc_id  - |' || l_doc_id  || '|',1);

        IF l_ret_sts <> fnd_api.g_ret_sts_success THEN
                l_err_msg := l_ret_msg;
                RAISE fnd_api.g_exc_error;
        END IF;

        x_ret_sts := fnd_api.g_ret_sts_success;
        x_ret_msg := '';
        x_msg_id  := l_msg_id;

        m4u_dmd_utils.log('Exiting m4u_dmd_request.send_cis - Success' ,2);
        RETURN; --success


    EXCEPTION
        WHEN OTHERS THEN
                m4u_dmd_utils.handle_error(l_err_api,l_err_msg,
                            SQLCODE,SQLERRM,x_ret_sts,x_ret_msg);
                RETURN; --fail
    END send_cis;

    PROCEDURE send_cin_ack
    (
        p_cin_msg_id     IN          VARCHAR2,
        x_msg_id         OUT NOCOPY  VARCHAR2,
        x_ret_sts        OUT NOCOPY  VARCHAR2,
        x_ret_msg        OUT NOCOPY  VARCHAR2
    ) AS
        l_ret_sts       VARCHAR2(1);
        l_ret_msg       VARCHAR2(4000);
        l_msg_id        VARCHAR2(30);
        l_err_msg       VARCHAR2(4000);
        l_err_api       VARCHAR2(50) := 'm4u_dmd_message_pkg.send_cin_ack';
        l_payload_id    VARCHAR2(30);
        l_datapool_gln  VARCHAR2(100);
        l_retailer_gln  VARCHAR2(100);
        l_user_gln      VARCHAR2(100);
        l_user_id       VARCHAR2(100);
    BEGIN

        m4u_dmd_utils.log('Entering m4u_dmd_message_pkg.send_cin_ack'      ,2);
        m4u_dmd_utils.log('p_msg_id     - |' || p_cin_msg_id     || '|',2);

        SELECT  payload_id, sender_gln, receiver_gln, rep_party_gln
        INTO    l_payload_id,l_datapool_gln, l_user_gln, l_retailer_gln
        FROM    m4u_dmd_messages
        WHERE   msg_id = p_cin_msg_id;

        m4u_dmd_utils.log('l_payload_id   - |' || l_payload_id   || '|',1);
        m4u_dmd_utils.log('l_datapool_gln - |' || l_datapool_gln || '|',1);
        m4u_dmd_utils.log('l_user_gln     - |' || l_user_gln     || '|',1);
        m4u_dmd_utils.log('l_retailer_gln - |' || l_retailer_gln || '|',1);

        l_user_id := m4u_dmd_utils.get_gln_user(l_user_gln);

        m4u_dmd_utils.log('Call m4u_dmd_requests.create_request'  ,1);
        m4u_dmd_requests.create_request
        (
                p_type                => m4u_dmd_utils.c_type_cin_ack,
                p_direction           => m4u_dmd_utils.c_dir_out,
                p_status              => m4u_dmd_utils.c_sts_ready,
                p_ref_msg_id          => p_cin_msg_id,
                p_orig_msg_id         => 'GENERATE',
                p_msg_timstamp        => sysdate,
                p_payload_id          => l_payload_id,

                p_sender_gln          => l_user_gln,
                p_receiver_gln        => l_datapool_gln,
                p_rep_party_gln       => l_retailer_gln,
                p_user_gln            => l_user_gln,
                p_user_id             => l_user_id,

                x_msg_id              => l_msg_id,
                x_ret_sts             => l_ret_sts,
                x_ret_msg             => l_ret_msg
         );
        m4u_dmd_utils.log('l_ret_sts - |' || l_ret_sts || '|',1);
        m4u_dmd_utils.log('l_ret_msg - |' || l_ret_msg || '|',1);
        m4u_dmd_utils.log('l_msg_id  - |' || l_msg_id  || '|',1);


        IF l_ret_sts <> fnd_api.g_ret_sts_success THEN
                l_err_msg := l_ret_msg;
                RAISE fnd_api.g_exc_error;
        END IF;

        x_ret_sts := fnd_api.g_ret_sts_success;
        x_ret_msg := '';

        m4u_dmd_utils.log('Exiting m4u_dmd_request.send_cin_ack - Success' ,2);
        RETURN; --success

    EXCEPTION
        WHEN OTHERS THEN
                m4u_dmd_utils.handle_error(l_err_api,l_err_msg,
                            SQLCODE,SQLERRM,x_ret_sts,x_ret_msg);
                RETURN; --fail
    END send_cin_ack;


    PROCEDURE send_cic
    (
        p_payload    IN          CLOB,
        x_msg_id     OUT NOCOPY  VARCHAR2,
        x_ret_sts    OUT NOCOPY  VARCHAR2,
        x_ret_msg    OUT NOCOPY  VARCHAR2
    ) AS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_ret_sts       VARCHAR2(1);
        l_ret_msg       VARCHAR2(4000);
        l_err_msg       VARCHAR2(4000);
        l_err_api       VARCHAR2(30) := 'm4u_dmd_message_pkg.send_cic';
        l_msg_id        VARCHAR2(30);
        l_doc_id        VARCHAR2(30);
        l_payload_id    VARCHAR2(30);
        l_doc_rec       m4u_dmd_documents%ROWTYPE;
        l_dom           xmldom.domdocument;

        l_doc_node      xmldom.domnode;
        l_doc_count     NUMBER;
        l_doc_idx       NUMBER;
        l_doc_nodes     xmldom.domnodelist;

        l_msg_node      xmldom.domnode;
        l_msg_count     NUMBER;
        l_msg_idx       NUMBER;
        l_msg_nodes     xmldom.domnodelist;

        l_user_id       VARCHAR2(100);
        l_user_gln      VARCHAR2(100);
        l_datapool_gln  VARCHAR2(100);
        l_retailer_gln  VARCHAR2(100);
        l_cin_msg_id    VARCHAR2(100);
    BEGIN

        m4u_dmd_utils.log('Entering m4u_dmd_request.send_cic'            ,2);
        m4u_dmd_utils.log('len(p_payload) - ' || length(p_payload) || '|',1);

        -- Create payload
        -- parsing will allow us to update cin doc records
        -- right here, avoiding bpel callback
        m4u_dmd_utils.log('Call m4u_dmd_requests.create_payload'  ,1);
        m4u_dmd_requests.create_payload
        (
                p_xml           => p_payload,
                p_type          => m4u_dmd_utils.c_type_resp_ebm,
                p_dir           => m4u_dmd_utils.c_dir_out,
                x_payload_id    => l_payload_id,
                x_ret_sts       => l_ret_sts,
                x_ret_msg       => l_ret_msg
        );

        m4u_dmd_utils.log('l_ret_sts    - |' || l_ret_sts   || '|',1);
        m4u_dmd_utils.log('l_ret_msg    - |' || l_ret_msg   || '|',1);
        m4u_dmd_utils.log('l_payload_id - |' || l_payload_id|| '|',1);

        IF l_ret_sts <> fnd_api.g_ret_sts_success THEN
            l_err_msg := l_ret_msg;
            RAISE fnd_api.g_exc_error;
        END IF;

        m4u_dmd_utils.log('Call create_dom_from_clob_pvt'  ,1);
        create_dom_from_clob_pvt
        (
                p_xml         => p_payload,
                x_dom         => l_dom
        );
        m4u_dmd_utils.log('DOM object created'  ,1);

        l_msg_nodes := xslprocessor.selectnodes (xmldom.makenode (l_dom),
                '/*[local-name()="SyncItemPublicationConfirmationEBM"]' ||
                '/*[local-name()="DataArea"]'                           ||
                '/*[local-name()="SyncItemPublicationConfirmation"]');

        l_msg_count:=  xmldom.getlength (l_msg_nodes);



        m4u_dmd_utils.log('l_msg_count  -|' ||l_msg_count || ' |',1);


        FOR l_msg_idx IN 0..l_msg_count - 1
        LOOP
                m4u_dmd_utils.log('Processing l_msg_idx    -|' ||l_msg_idx || ' |' ,1);
                l_msg_node := xmldom.item(l_msg_nodes,l_msg_idx);

                l_cin_msg_id := xslprocessor.valueof (l_msg_node,
                                            './*[local-name()="ItemPublicationIdentification"]'
                                         || '/*[local-name()="AlternateIdentification"]'
                                         || '/*[local-name()="ID"]');

                m4u_dmd_utils.log('CIN l_cin_msg_id   -|' ||l_cin_msg_id || ' |',1);
                m4u_dmd_utils.log('Query m4u_dmd_documents for CIN info'        ,1);

                SELECT  receiver_gln, sender_gln, rep_party_gln
                INTO    l_user_gln, l_datapool_gln, l_retailer_gln
                FROM    m4u_dmd_messages
                WHERE   orig_msg_id = l_cin_msg_id;

                m4u_dmd_utils.log('l_user_gln     -|' ||l_user_gln              || '|',1);
                m4u_dmd_utils.log('l_datapool_gln -|' ||l_datapool_gln          || '|',1);
                m4u_dmd_utils.log('l_retailer_gln -|' ||l_retailer_gln          || '|',1);

                l_user_id := m4u_dmd_utils.get_gln_user(l_user_gln);

                m4u_dmd_utils.log('l_user_id     -|' ||l_user_id                || '|',1);

                m4u_dmd_utils.log('Call to m4u_dmd_requests.create_request'  ,1);
                m4u_dmd_requests.create_request
                (
                        p_type                => m4u_dmd_utils.c_type_cic,
                        p_direction           => m4u_dmd_utils.c_dir_out,
                        p_status              => m4u_dmd_utils.c_sts_ready,
                        p_msg_timstamp        => sysdate,
                        p_payload_id          => l_payload_id,
                        p_orig_msg_id         => 'GENERATE',

                        p_sender_gln          => l_user_gln,
                        p_receiver_gln        => l_datapool_gln,
                        p_rep_party_gln       => l_retailer_gln,
                        p_user_gln            => l_user_gln,
                        p_user_id             => l_user_id,

                        x_msg_id              => l_msg_id,
                        x_ret_sts             => l_ret_sts,
                        x_ret_msg             => l_ret_msg
                );

                m4u_dmd_utils.log('l_ret_sts - |' || l_ret_sts || '|',1);
                m4u_dmd_utils.log('l_ret_msg - |' || l_ret_msg || '|',1);
                m4u_dmd_utils.log('l_msg_id  - |' || l_msg_id  || '|',1);


                IF l_ret_sts <> fnd_api.g_ret_sts_success THEN
                        l_err_msg := l_ret_msg;
                        RAISE fnd_api.g_exc_error;
                END IF;

                l_doc_nodes :=  xslprocessor.selectnodes (l_msg_node,
                        './*[local-name()="ItemPublicationLineConfirmation"]');

                l_doc_count:=  xmldom.getlength (l_doc_nodes);
                m4u_dmd_utils.log('l_doc_count  -|' ||l_doc_count || ' |',1);


                FOR l_doc_idx IN 0..l_doc_count - 1
                LOOP
                        m4u_dmd_utils.log('l_doc_idx    -|' ||l_doc_idx || ' |' ,1);

                        l_doc_node               := xmldom.item(l_doc_nodes,l_doc_idx);

                        l_doc_rec.orig_doc_id    := xslprocessor.valueof (l_doc_node,
                                                    './*[local-name()="ItemPublicationLineIdentification"]'
                                                 || '/*[local-name()="AlternateIdentification"]'
                                                 || '/*[local-name()="ID"]');
                        m4u_dmd_utils.log('CIN orig_doc_id   -|' ||l_doc_rec.orig_doc_id || ' |',1);

                        l_doc_rec.parameter1    := xslprocessor.valueof (l_doc_node,
                                                './*[local-name()="ProcessingStatus"]/*[local-name()="Code"]');

                        m4u_dmd_utils.log('Query m4u_dmd_documents for ref_doc_id',1);
                        SELECT  top_gtin, action, info_provider_gln,
                                data_recepient_gln,target_market_country,
                                doc_id
                        INTO    l_doc_rec.top_gtin, l_doc_rec.action, l_doc_rec.info_provider_gln,
                                l_doc_rec.data_recepient_gln, l_doc_rec.target_market_country,
                                l_doc_rec.ref_doc_id
                        FROM    m4u_dmd_documents
                        WHERE   orig_doc_id =  l_doc_rec.orig_doc_id;

                        m4u_dmd_utils.log('top_gtin     -|' ||l_doc_rec.top_gtin              || '|',1);
                        m4u_dmd_utils.log('sub_type     -|' ||l_doc_rec.action                || '|',1);
                        m4u_dmd_utils.log('info_gln     -|' ||l_doc_rec.info_provider_gln     || '|',1);
                        m4u_dmd_utils.log('rcpt_gln     -|' ||l_doc_rec.data_recepient_gln    || '|',1);
                        m4u_dmd_utils.log('tgt_ctry     -|' ||l_doc_rec.target_market_country || '|',1);


                        m4u_dmd_requests.create_document
                        (
                                p_msg_id                => l_msg_id,
                                p_type                  => m4u_dmd_utils.c_type_cic,
                                p_action                => l_doc_rec.action,
                                p_doc_status            => m4u_dmd_utils.c_sts_ready,
                                p_ref_doc_id            => l_doc_rec.ref_doc_id,
                                p_orig_doc_id           => 'GENERATE',
                                p_func_status           => null,
                                p_processing_msg        => null,

                                p_top_gtin              => l_doc_rec.top_gtin,
                                p_info_provider_gln     => l_doc_rec.info_provider_gln,
                                p_data_rcpt_gln         => nvl(l_doc_rec.data_recepient_gln,l_user_gln),
                                p_tgt_mkt_ctry          => l_doc_rec.target_market_country,
                                p_param1                => l_doc_rec.parameter1,
                                p_lparam1               => l_doc_rec.orig_doc_id,

                                p_payload_id            => l_payload_id,
                                p_payload_type          => m4u_dmd_utils.c_type_resp_ebm,
                                p_payload_dir           => m4u_dmd_utils.c_dir_out,

                                x_doc_id                => l_doc_id,
                                x_ret_sts               => l_ret_sts,
                                x_ret_msg               => l_ret_msg
                        );

                        m4u_dmd_utils.log('l_ret_sts    - |' || l_ret_sts   || '|',1);
                        m4u_dmd_utils.log('l_ret_msg    - |' || l_ret_msg   || '|',1);
                        m4u_dmd_utils.log('l_doc_id     - |' || l_doc_id    || '|',1);


                        IF l_ret_sts <> fnd_api.g_ret_sts_success THEN
                            l_err_msg := l_ret_msg;
                            RAISE fnd_api.g_exc_error;
                        END IF;
                END LOOP;

                m4u_dmd_utils.log('Processed l_msg_idx    -|' ||l_msg_idx || ' |' ,1);


        END LOOP;


        x_ret_sts := fnd_api.g_ret_sts_success;
        x_ret_msg := '';

        m4u_dmd_utils.log('Exiting m4u_dmd_request.send_cic - Success' ,2);
        COMMIT;
        RETURN; --success

    EXCEPTION
        WHEN OTHERS THEN
                ROLLBACK;
                m4u_dmd_utils.handle_error(l_err_api,l_err_msg,
                            SQLCODE,SQLERRM,x_ret_sts,x_ret_msg);
                RETURN; --fail
    END send_cic;




    PROCEDURE receive_cin
    (
        p_payload       IN              CLOB,
        x_msg_id        OUT NOCOPY      VARCHAR2,
        x_ret_sts       OUT NOCOPY      VARCHAR2,
        x_ret_msg       OUT NOCOPY      VARCHAR2
    ) AS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_ret_sts       VARCHAR2(1);
        l_ret_msg       VARCHAR2(4000);
        l_err_msg       VARCHAR2(4000);
        l_err_api       VARCHAR2(50) := 'm4u_dmd_message_pkg.receive_cin';
        l_cin_msg_id    VARCHAR2(30);
        l_cin_ack_msg_id VARCHAR2(30);
        l_doc_id        VARCHAR2(30);
        l_payload_id    VARCHAR2(30);

        l_msg_timestamp VARCHAR2(30);
        l_orig_msg_id   VARCHAR2(80);
        l_sender_gln    VARCHAR2(30);
        l_receiver_gln  VARCHAR2(30);
        l_doc_timestamp VARCHAR2(30);
        l_orig_doc_id   VARCHAR2(80);
        l_operation     VARCHAR2(30);
        l_top_gtin      VARCHAR2(30);
        l_info_prov_gln VARCHAR2(30);
        l_tgt_mkt_ctry  VARCHAR2(30);
        l_cin_status    VARCHAR2(30);
        l_data_rcpt_gln VARCHAR2(30);

        l_dom           xmldom.domdocument;
        l_node          xmldom.domnode;
        l_doc_nodes     xmldom.domnodelist;
        l_doc_count     NUMBER;
        l_doc_idx       NUMBER;

    BEGIN

        m4u_dmd_utils.log('Entering m4u_dmd_request.receive_cin'         ,2);
        m4u_dmd_utils.log('len(p_payload) - ' || length(p_payload) || '|',1);

        m4u_dmd_utils.log('Call m4u_dmd_requests.create_payload'  ,1);

        m4u_dmd_requests.create_payload
        (
                p_xml           => p_payload,
                p_type          => m4u_dmd_utils.c_type_cin,
                p_dir           => m4u_dmd_utils.c_dir_in,
                x_payload_id    => l_payload_id,
                x_ret_sts       => l_ret_sts,
                x_ret_msg       => l_ret_msg
        );


        m4u_dmd_utils.log('l_ret_sts    - |' || l_ret_sts   || '|',1);
        m4u_dmd_utils.log('l_ret_msg    - |' || l_ret_msg   || '|',1);
        m4u_dmd_utils.log('l_payload_id - |' || l_payload_id|| '|',1);

        IF l_ret_sts <> fnd_api.g_ret_sts_success THEN
            l_err_msg := l_ret_msg;
            RAISE fnd_api.g_exc_error;
        END IF;

        m4u_dmd_utils.log('Call create_dom_from_clob_pvt'  ,1);
        create_dom_from_clob_pvt
        (
                p_xml         => p_payload,
                x_dom         => l_dom
        );
        m4u_dmd_utils.log('DOM object created'  ,1);

        l_node          := xmldom.makenode (l_dom);
        l_msg_timestamp := xslprocessor.valueof
                        (l_node,'//*[local-name()="header"]/*[local-name()="creationDateTime"]');
        l_sender_gln    := xslprocessor.valueof
                        (l_node,'//*[local-name()="header"]/*[local-name()="sender"]');
        l_receiver_gln  := xslprocessor.valueof
                        (l_node,'//*[local-name()="header"]/*[local-name()="receiver"]');
        l_orig_msg_id   := xslprocessor.valueof
                        (l_node,'//*[local-name()="header"]/*[local-name()="messageId"]');
        l_data_rcpt_gln := xslprocessor.valueof
                        (l_node,'//*[local-name()="catalogueItemNotification"]' ||
                        '/*[local-name()="header"]/*[local-name()="dataRecipientGLN"]');


        m4u_dmd_utils.log('l_msg_timestamp -|' ||l_msg_timestamp || '|',1);
        m4u_dmd_utils.log('l_orig_msg_id   -|' ||l_orig_msg_id   || '|',1);
        m4u_dmd_utils.log('l_sender_gln    -|' ||l_sender_gln    || '|',1);
        m4u_dmd_utils.log('l_receiver_gln  -|' ||l_receiver_gln  || '|',1);
        m4u_dmd_utils.log('l_data_rcpt_gln -|' ||l_data_rcpt_gln || '|',1);

        m4u_dmd_utils.log('Call m4u_dmd_requests.create_request'  ,1);


        m4u_dmd_requests.create_request
        (
                p_type                => m4u_dmd_utils.c_type_cin,
                p_direction           => m4u_dmd_utils.c_dir_in,
                p_status              => m4u_dmd_utils.c_sts_ready,
                p_msg_timstamp        => m4u_dmd_utils.date_xml_to_db(l_msg_timestamp),
                p_orig_msg_id         => l_orig_msg_id,
                p_payload_id          => l_payload_id,

                p_sender_gln          => l_sender_gln,
                p_receiver_gln        => l_receiver_gln,
                p_rep_party_gln       => l_data_rcpt_gln,

                x_msg_id              => l_cin_msg_id,
                x_ret_sts             => l_ret_sts,
                x_ret_msg             => l_ret_msg
         );



        m4u_dmd_utils.log('l_ret_sts - |' || l_ret_sts || '|',1);
        m4u_dmd_utils.log('l_ret_msg - |' || l_ret_msg || '|',1);
        m4u_dmd_utils.log('l_msg_id  - |' || l_cin_msg_id|| '|',1);


        IF l_ret_sts <> fnd_api.g_ret_sts_success THEN
                l_err_msg := l_ret_msg;
                RAISE fnd_api.g_exc_error;
        END IF;


        l_doc_nodes :=  xslprocessor.selectnodes (l_node,'/*[local-name()="envelope"]/*[local-name()="catalogueItemNotification"]/*[local-name()="document"]');
        l_doc_count :=  xmldom.getlength (l_doc_nodes);
        m4u_dmd_utils.log('l_doc_count  -|' ||l_doc_count || ' |',1);

        FOR l_doc_idx IN 0..l_doc_count - 1
        LOOP
                m4u_dmd_utils.log('l_doc_idx    -|' ||l_doc_idx || ' |' ,1);

                l_node          := xmldom.item(l_doc_nodes,l_doc_idx);


                l_orig_doc_id   := xslprocessor.valueof(l_node,'documentId');
                l_operation     := xslprocessor.valueof(l_node,'hierarchyInformation/operation');
                l_top_gtin      := xslprocessor.valueof(l_node,'hierarchyInformation/publishedGTIN');
                l_info_prov_gln := xslprocessor.valueof(l_node,'hierarchyInformation/informationProviderGLN');
                l_tgt_mkt_ctry  := xslprocessor.valueof(l_node,'hierarchyInformation/targetMarket');
                l_cin_status    := xslprocessor.valueof(l_node,'hierarchyInformation/documentStatus');
                l_doc_timestamp := xslprocessor.valueof(l_node,'item[1]/publicationDate');

                m4u_dmd_utils.log('l_operation  -|' ||l_operation      || ' |',1);
                m4u_dmd_utils.log('l_top_gtin   -|' ||l_top_gtin       || ' |',1);
                m4u_dmd_utils.log('info_gln     -|' ||l_info_prov_gln  || ' |',1);
                m4u_dmd_utils.log('l_tg_mkt_gln -|' ||l_tgt_mkt_ctry   || ' |',1);
                m4u_dmd_utils.log('l_cin_status -|' ||l_cin_status     || ' |',1);
                m4u_dmd_utils.log('l_orig_doc_id-|' ||l_orig_doc_id    || ' |',1);


                m4u_dmd_requests.create_document
                (
                        p_msg_id                => l_cin_msg_id,
                        p_type                  => m4u_dmd_utils.c_type_cin,
                        p_action                => l_operation,
                        p_doc_status            => m4u_dmd_utils.c_sts_ready,
                        p_func_status           => null,
                        p_processing_msg        => null,
                        p_orig_doc_id           => l_orig_doc_id,
                        p_timestamp             => m4u_dmd_utils.date_xml_to_db(l_doc_timestamp),

                        p_top_gtin              => l_top_gtin,
                        p_info_provider_gln     => l_info_prov_gln,
                        p_data_rcpt_gln         => l_data_rcpt_gln,
                        p_tgt_mkt_ctry          => l_tgt_mkt_ctry,
                        p_tgt_mkt_div           => null,

                        p_payload_id            => l_payload_id,
                        p_payload_type          => m4u_dmd_utils.c_type_cin,
                        p_payload_dir           => m4u_dmd_utils.c_dir_in,

                        x_doc_id                => l_doc_id,
                        x_ret_sts               => l_ret_sts,
                        x_ret_msg               => l_ret_msg
                );

                m4u_dmd_utils.log('l_ret_sts    - |' || l_ret_sts   || '|',1);
                m4u_dmd_utils.log('l_ret_msg    - |' || l_ret_msg   || '|',1);
                m4u_dmd_utils.log('l_doc_id     - |' || l_doc_id    || '|',1);


                IF l_ret_sts <> fnd_api.g_ret_sts_success THEN
                    l_err_msg := l_ret_msg;
                    RAISE fnd_api.g_exc_error;
                END IF;
        END LOOP;


        m4u_dmd_utils.log('Call m4u_dmd_requests.send_cin_ack'  ,1);
        send_cin_ack
        (
                p_cin_msg_id     => l_cin_msg_id,
                x_msg_id         => l_cin_ack_msg_id,
                x_ret_sts        => l_ret_sts,
                x_ret_msg        => l_ret_msg
        );


        m4u_dmd_utils.log('l_ret_sts        - |' || l_ret_sts       || '|',1);
        m4u_dmd_utils.log('l_ret_msg        - |' || l_ret_msg       || '|',1);
        m4u_dmd_utils.log('l_cin_ack_msg_id - |' || l_cin_ack_msg_id|| '|',1);

        IF l_ret_sts <> fnd_api.g_ret_sts_success THEN
                l_err_msg := l_ret_msg;
                RAISE fnd_api.g_exc_error;
        END IF;

        x_ret_sts := fnd_api.g_ret_sts_success;
        x_ret_msg := '';
        x_msg_id  := l_cin_msg_id;

        m4u_dmd_utils.log('Exiting m4u_dmd_request.send_cic - Success' ,2);
        COMMIT;
        RETURN; --success


    EXCEPTION
        WHEN OTHERS THEN
                ROLLBACK;
                m4u_dmd_utils.handle_error(l_err_api,l_err_msg,
                            SQLCODE,SQLERRM,x_ret_sts,x_ret_msg);

    END receive_cin;


 END m4u_dmd_message_pkg;

/
