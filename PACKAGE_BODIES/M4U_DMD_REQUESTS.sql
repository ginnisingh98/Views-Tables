--------------------------------------------------------
--  DDL for Package Body M4U_DMD_REQUESTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."M4U_DMD_REQUESTS" AS
/* $Header: M4UDREQB.pls 120.3 2007/09/12 06:57:29 bsaratna noship $ */

  -- Table handler for m4u_dmd_messages
  -- create request record based on input paramters
  -- returns created message_id, api return status
  PROCEDURE create_request
  (
        p_type                IN  VARCHAR2,
        p_direction           IN  VARCHAR2,
        p_status              IN  VARCHAR2 := NULL,
        p_ref_msg_id          IN  VARCHAR2 := NULL,
        p_orig_msg_id         IN  VARCHAR2 := NULL,
        p_msg_timstamp        IN  DATE     := NULL,
        p_payload_id          IN  VARCHAR2 := NULL,
        p_sender_gln          IN  VARCHAR2 := NULL,
        p_receiver_gln        IN  VARCHAR2 := NULL,
        p_rep_party_gln       IN  VARCHAR2 := NULL,
        p_user_gln            IN  VARCHAR2 := NULL,
        p_user_id             IN  VARCHAR2 := NULL,
        x_msg_id              OUT NOCOPY VARCHAR2,
        x_ret_sts             OUT NOCOPY VARCHAR2,
        x_ret_msg             OUT NOCOPY VARCHAR2
  )
  IS
        l_msg_id        VARCHAR2(30);
        l_err_api       VARCHAR2(50)    := 'm4u_dmd_requests.create_request';
        l_err_msg       VARCHAR2(2000);
        l_param         VARCHAR2(100);
        l_value         VARCHAR2(4000);
        l_orig_msg_id   VARCHAR2(80);
  BEGIN

        m4u_dmd_utils.log('Entering m4u_dmd_request.create_request'     ,2);
        m4u_dmd_utils.log('p_type          -|'|| p_type            ||'|',1);
        m4u_dmd_utils.log('p_direction     -|'|| p_direction       ||'|',1);
        m4u_dmd_utils.log('p_status        -|'|| p_status          ||'|',1);
        m4u_dmd_utils.log('p_ref_msg_id    -|'|| p_ref_msg_id      ||'|',1);
        m4u_dmd_utils.log('p_orig_msg_id   -|'|| p_orig_msg_id     ||'|',1);
        m4u_dmd_utils.log('p_msg_timstamp  -|'|| p_msg_timstamp    ||'|',1);
        m4u_dmd_utils.log('p_payload_id    -|'|| p_payload_id      ||'|',1);

        m4u_dmd_utils.log('p_sender_gln    -|'|| p_sender_gln      ||'|',1);
        m4u_dmd_utils.log('p_receiver_gln  -|'|| p_receiver_gln    ||'|',1);
        m4u_dmd_utils.log('p_rep_party_gln -|'|| p_rep_party_gln   ||'|',1);
        m4u_dmd_utils.log('p_user_gln      -|'|| p_user_gln        ||'|',1);
        m4u_dmd_utils.log('p_user_id       -|'|| p_user_id         ||'|',1);




        --validation block begins
        BEGIN
                m4u_dmd_utils.log('Entering validation block',2);
                l_param := '';
                l_value := '';

                IF NOT m4u_dmd_utils.valid_type('MSG_TYPE',p_type,false) THEN
                        l_param := 'MSG_TYPE';
                        l_value := p_type;
                ELSIF NOT m4u_dmd_utils.valid_type('DIRECTION',p_direction,false)  THEN
                        l_param := 'DIRECTION';
                        l_value := p_direction;
                ELSIF NOT m4u_dmd_utils.valid_type('MSG_STATUS',p_status,false)  THEN
                        l_param := 'MSG_STATUS';
                        l_value := p_status;
                ELSIF NOT m4u_dmd_utils.valid_msg_id(p_ref_msg_id,true)  THEN
                        l_param := 'REF_MSG_ID';
                        l_value := p_ref_msg_id;
                ELSIF NOT m4u_dmd_utils.valid_len(p_orig_msg_id,1,80,true)  THEN
                        l_param := 'ORIG_MSG_ID';
                        l_value := p_orig_msg_id;
                ELSIF NOT m4u_dmd_utils.valid_payload_id(p_payload_id,true)  THEN
                        l_param := 'PAYLOAD_ID';
                        l_value := p_payload_id;

                ELSIF NOT m4u_dmd_utils.valid_gln(p_sender_gln,false)  THEN
                        l_param := 'SENDER_GLN';
                        l_value := p_sender_gln;
                ELSIF NOT m4u_dmd_utils.valid_gln(p_receiver_gln,false)  THEN
                        l_param := 'RECEIVER_GLN';
                        l_value := p_receiver_gln;
                ELSIF NOT m4u_dmd_utils.valid_gln(p_rep_party_gln,true)  THEN
                        l_param := 'REP_PARTY_GLN';
                        l_value := p_rep_party_gln;
                ELSIF p_direction = m4u_dmd_utils.c_dir_out
                 AND  NOT m4u_dmd_utils.valid_gln(p_user_gln,false)  THEN
                        l_param := 'USER_GLN';
                        l_value := p_user_gln;
                ELSIF p_direction = m4u_dmd_utils.c_dir_out
                 AND  NOT m4u_dmd_utils.valid_len(p_user_id,1,30,false)  THEN
                        l_param := 'USER_ID';
                        l_value := p_user_id;
                END IF;

                IF l_param IS NOT NULL THEN
                        l_err_msg := m4u_dmd_utils.get_inv_param_msg
                                     (l_err_api,l_param,l_value);
                        RAISE fnd_api.g_exc_error;
                END IF;
                m4u_dmd_utils.log('Exiting validation block - success',2);
        END;
        --validation block ends


        SELECT m4u_dmd_msgid_s.nextval
        INTO   l_msg_id
        FROM   DUAL;


        m4u_dmd_utils.log('l_msg_id        -|'|| l_msg_id     ||'|',1);
        m4u_dmd_utils.log('insert into m4u_dmd_messages'           ,1);



        IF p_orig_msg_id = 'GENERATE' THEN
                --<type>.<date>.<retrycount>.<msgid>
                l_orig_msg_id  := p_type || '.' || to_char(sysdate,'DD-MM-RR') || '.' || '0' || '.' || l_msg_id;
        ELSE
                l_orig_msg_id := p_orig_msg_id;
        END IF;

        INSERT INTO m4u_dmd_messages
        (
        msg_id, ref_msg_id, type, direction, status, retry_count,
        orig_msg_id, sender_gln, receiver_gln, rep_party_gln,
        user_gln,user_id, msg_timestamp, payload_id,
        last_update_date, last_updated_by,creation_date, created_by,last_update_login
        )
        VALUES
        (
        l_msg_id, p_ref_msg_id,p_type, p_direction, p_status, 0,
        l_orig_msg_id, p_sender_gln, p_receiver_gln, p_rep_party_gln,
        p_user_gln,p_user_id, p_msg_timstamp, p_payload_id,
        sysdate, FND_GLOBAL.user_id,sysdate, FND_GLOBAL.user_id, FND_GLOBAL.login_id
        );


        m4u_dmd_utils.log('Exiting m4u_dmd_request.create_request - Success',2);

        x_ret_sts := fnd_api.g_ret_sts_success;
        x_ret_msg := '';
        x_msg_id  := l_msg_id;

        RETURN;

  EXCEPTION
        WHEN OTHERS THEN
                x_msg_id  := -1;
                m4u_dmd_utils.handle_error(l_err_api,l_err_msg,
                SQLCODE,SQLERRM,x_ret_sts,x_ret_msg);
  END create_request;


  -- Table handler for m4u_dmd_payloads
  -- store payload record passed as input clob
  -- returns payload id identify record
  PROCEDURE  create_payload
  (
        p_xml           IN         CLOB,
        p_type          IN         VARCHAR2,
        p_dir           IN         VARCHAR2,
        x_payload_id    OUT NOCOPY VARCHAR2,
        x_ret_sts       OUT NOCOPY VARCHAR2,
        x_ret_msg       OUT NOCOPY VARCHAR2
  )
  IS
        l_payload_id            NUMBER;
        l_payload_evt_key       VARCHAR2(100);
        l_params                wf_parameter_list_t;
        l_err_api               VARCHAR2(50)    := 'm4u_dmd_requests.create_payload';
        l_err_msg               VARCHAR2(2000);
        l_param                 VARCHAR2(100);
        l_value                 VARCHAR2(4000);

  BEGIN
        m4u_dmd_utils.log('Entering m4u_dmd_request.create_payload',2);
        m4u_dmd_utils.log('p_type          -|'|| p_type       ||'|',1);
        m4u_dmd_utils.log('p_dir           -|'|| p_dir        ||'|',1);
        m4u_dmd_utils.log('length(p_xml)   -|'|| length(p_xml)||'|',1);


        --validation block begins
        BEGIN
                m4u_dmd_utils.log('Entering validation block',2);
                l_param := '';
                l_value := '';

                IF NOT m4u_dmd_utils.valid_type('PAYLOAD_TYPE',p_type,false)  THEN
                        l_param := 'PAYLOAD_TYPE';
                        l_value := p_type;
                ELSIF NOT m4u_dmd_utils.valid_type('DIRECTION',p_dir,false)  THEN
                        l_param := 'DIRECTION';
                        l_value := p_dir;
                END IF;

                IF l_param IS NOT NULL THEN
                        l_err_msg := m4u_dmd_utils.get_inv_param_msg
                                     (l_err_api,l_param,l_value);
                        RAISE fnd_api.g_exc_error;
                END IF;
                m4u_dmd_utils.log('Exiting validation block - success',2);
        END;
        --validation block ends

        SELECT m4u_dmd_payloadid_s.NEXTVAL
        INTO l_payload_id
        FROM dual;

        m4u_dmd_utils.log('l_payload_id    -|'|| l_payload_id ||'|',1);
        m4u_dmd_utils.log('insert into m4u_dmd_payloads'           ,1);



        INSERT INTO m4u_dmd_payloads
        (
        payload_id, payload, type, direction,
        last_update_date, last_updated_by,creation_date,created_by, last_update_login
        )
        VALUES
        (
        l_payload_id, p_xml, p_type,p_dir, sysdate, FND_GLOBAL.user_id,
        sysdate,FND_GLOBAL.user_id, FND_GLOBAL.login_id
        );


        --Raise CLN event
        BEGIN
                --set key
                l_payload_evt_key := sysdate || '.' || l_payload_id;

                --set params
                l_params := wf_parameter_list_t();
                wf_event.addParameterToList('PAYLOAD_TYPE',     p_type,         l_params);
                wf_event.addParameterToList('PAYLOAD_DIR',      p_dir,          l_params);
                wf_event.addParameterToList('PAYLOAD_ID',       l_payload_id,   l_params);

                --raise event
                wf_event.raise
                (
                        p_event_name    => m4u_dmd_utils.c_payload_event,
                        p_event_key     => l_payload_evt_key,
                        p_parameters    => l_params
                );

                m4u_dmd_utils.log('l_payload_evt_key - |' || l_payload_evt_key || '|',2);
        EXCEPTION
                WHEN OTHERS THEN
                        m4u_dmd_utils.log('m4u_dmd_messages.create_payload',             6);
                        m4u_dmd_utils.log('Unexpected error while raising payload event',6);
                        m4u_dmd_utils.log(SQLCODE || SQLERRM,                            6);
        END;

        m4u_dmd_utils.log('Exiting m4u_dmd_request.create_payload - Success',2);
        x_ret_sts   := fnd_api.g_ret_sts_success;
        x_ret_msg   := '';
        x_payload_id:= l_payload_id;

  EXCEPTION
        WHEN OTHERS THEN
                x_payload_id := -1;
                m4u_dmd_utils.handle_error(l_err_api,l_err_msg,
                SQLCODE,SQLERRM,x_ret_sts,x_ret_msg);
  END create_payload;


  -- Table handler for m4u_dmd_payloads
  -- create document record based on input paramters
  -- valid msg_id is a mandatory parameter
  -- 1-n relationship between requests and documents
  PROCEDURE create_document
  (
        p_msg_id                IN VARCHAR2,
        p_type                  IN VARCHAR2,
        p_action                IN VARCHAR2,
        p_doc_status            IN VARCHAR2,
        p_func_status           IN VARCHAR2,
        p_timestamp             IN DATE     := NULL,
        p_processing_msg        IN VARCHAR2 := NULL,
        p_ref_doc_id            IN VARCHAR2 := NULL,
        p_orig_doc_id           IN VARCHAR2 := NULL,
        p_top_gtin              IN VARCHAR2 := NULL,
        p_info_provider_gln     IN VARCHAR2 := NULL,
        p_data_rcpt_gln         IN VARCHAR2 := NULL,
        p_tgt_mkt_ctry          IN VARCHAR2 := NULL,
        p_tgt_mkt_div           IN VARCHAR2 := NULL,
        p_param1                IN VARCHAR2 := NULL,
        p_param2                IN VARCHAR2 := NULL,
        p_param3                IN VARCHAR2 := NULL,
        p_param4                IN VARCHAR2 := NULL,
        p_param5                IN VARCHAR2 := NULL,
        p_lparam1               IN VARCHAR2 := NULL,
        p_lparam2               IN VARCHAR2 := NULL,
        p_lparam3               IN VARCHAR2 := NULL,
        p_lparam4               IN VARCHAR2 := NULL,
        p_lparam5               IN VARCHAR2 := NULL,
        p_payload_id            IN VARCHAR2 := NULL,
        p_payload_dir           IN VARCHAR2 := NULL,
        p_payload_type          IN VARCHAR2 := NULL,
        x_doc_id                OUT NOCOPY VARCHAR2,
        x_ret_sts               OUT NOCOPY VARCHAR2,
        x_ret_msg               OUT NOCOPY VARCHAR2
  )
  IS
        l_doc_id                VARCHAR2(30);
        l_cln_evt_key           VARCHAR2(30);
        l_cln_evt_params        wf_parameter_list_t;
        l_err_api               VARCHAR2(50)    := 'm4u_dmd_requests.create_document';
        l_err_msg               VARCHAR2(2000);
        l_param                 VARCHAR2(100);
        l_value                 VARCHAR2(4000);
        l_orig_doc_id           VARCHAR2(80);

  BEGIN
        --TBD: code to validate inputs


        m4u_dmd_utils.log('Entering m4u_dmd_request.create_document'         ,2);
        m4u_dmd_utils.log('p_msg_id           -|'|| p_msg_id            ||'|',1);
        m4u_dmd_utils.log('p_type             -|'|| p_type              ||'|',1);
        m4u_dmd_utils.log('p_action           -|'|| p_action            ||'|',1);
        m4u_dmd_utils.log('p_doc_status       -|'|| p_doc_status        ||'|',1);
        m4u_dmd_utils.log('p_func_status      -|'|| p_func_status       ||'|',1);
        m4u_dmd_utils.log('p_processing_msg   -|'|| p_processing_msg    ||'|',1);
        m4u_dmd_utils.log('p_ref_doc_id       -|'|| p_ref_doc_id        ||'|',1);
        m4u_dmd_utils.log('p_orig_doc_id      -|'|| p_orig_doc_id       ||'|',1);
        m4u_dmd_utils.log('p_timestamp        -|'|| p_timestamp         ||'|',1);

        m4u_dmd_utils.log('p_top_gtin         -|'|| p_top_gtin          ||'|',1);
        m4u_dmd_utils.log('p_info_provider_gln-|'|| p_info_provider_gln ||'|',1);
        m4u_dmd_utils.log('p_data_rcpt_gln    -|'|| p_data_rcpt_gln     ||'|',1);
        m4u_dmd_utils.log('p_tgt_mkt_ctry     -|'|| p_tgt_mkt_ctry      ||'|',1);
        m4u_dmd_utils.log('p_tgt_mkt_div      -|'|| p_tgt_mkt_div       ||'|',1);

        m4u_dmd_utils.log('p_param1           -|'|| p_param1            ||'|',1);
        m4u_dmd_utils.log('p_param2           -|'|| p_param2            ||'|',1);
        m4u_dmd_utils.log('p_param3           -|'|| p_param3            ||'|',1);
        m4u_dmd_utils.log('p_param4           -|'|| p_param4            ||'|',1);
        m4u_dmd_utils.log('p_param5           -|'|| p_param5            ||'|',1);
        m4u_dmd_utils.log('p_lparam1          -|'|| p_lparam1           ||'|',1);
        m4u_dmd_utils.log('p_lparam2          -|'|| p_lparam2           ||'|',1);
        m4u_dmd_utils.log('p_lparam3          -|'|| p_lparam3           ||'|',1);
        m4u_dmd_utils.log('p_lparam4          -|'|| p_lparam4           ||'|',1);
        m4u_dmd_utils.log('p_lparam5          -|'|| p_lparam5           ||'|',1);

        m4u_dmd_utils.log('p_payload_id       -|'|| p_payload_id        ||'|',1);
        m4u_dmd_utils.log('p_payload_dir      -|'|| p_payload_dir       ||'|',1);
        m4u_dmd_utils.log('p_payload_type     -|'|| p_payload_type      ||'|',1);

        --validation block begins
        BEGIN
                l_param := '';
                l_value := '';

                m4u_dmd_utils.log('Entering validation block',2);

                -- validate id, type, status params
                IF NOT m4u_dmd_utils.valid_type('DOC_TYPE',p_type,false)  THEN
                        l_param := 'DOC_TYPE';
                        l_value := p_type;
                ELSIF NOT m4u_dmd_utils.valid_type('ACTION',p_action,false)  THEN
                        l_param := 'ACTION';
                        l_value := p_action;
                ELSIF NOT m4u_dmd_utils.valid_type('DOC_STATUS',p_doc_status,false)  THEN
                        l_param := 'DOC_STATUS';
                        l_value := p_doc_status;
                ELSIF NOT m4u_dmd_utils.valid_msg_id(p_msg_id,false)  THEN
                        l_param := 'MSG_ID';
                        l_value := p_msg_id;
                ELSIF NOT m4u_dmd_utils.valid_doc_id(p_ref_doc_id,true)  THEN
                        l_param := 'REF_DOC_ID';
                        l_value := p_ref_doc_id;
                ELSIF NOT m4u_dmd_utils.valid_len(p_orig_doc_id ,0,80,true)  THEN
                        l_param := 'ORIG_DOC_ID';
                        l_value := p_orig_doc_id ;
                ELSIF NOT m4u_dmd_utils.valid_len(p_processing_msg,0,400,true)  THEN
                        l_param := 'PROCESSING_MSG';
                        l_value :=  p_processing_msg ;

                -- validate extensible params
                ELSIF NOT m4u_dmd_utils.valid_len(p_param1,0,50,true)  THEN
                        l_param := 'PARAM1';
                        l_value := p_param1;
                ELSIF NOT m4u_dmd_utils.valid_len(p_param2,0,50,true)  THEN
                        l_param := 'PARAM2';
                        l_value := p_param2;
                ELSIF NOT m4u_dmd_utils.valid_len(p_param3,0,50,true)  THEN
                        l_param := 'PARAM3';
                        l_value := p_param3;
                ELSIF NOT m4u_dmd_utils.valid_len(p_param4,0,50,true)  THEN
                        l_param := 'PARAM4';
                        l_value := p_param4;
                ELSIF NOT m4u_dmd_utils.valid_len(p_param5,0,50,true)  THEN
                        l_param := 'PARAM5';
                        l_value := p_param5;
                ELSIF NOT m4u_dmd_utils.valid_len(p_lparam1,0,400,true)  THEN
                        l_param := 'LPARAM1';
                        l_value := p_lparam1;
                ELSIF NOT m4u_dmd_utils.valid_len(p_lparam2,0,400,true)  THEN
                        l_param := 'LPARAM2';
                        l_value := p_lparam2;
                ELSIF NOT m4u_dmd_utils.valid_len(p_lparam3,0,400,true)  THEN
                        l_param := 'LPARAM3';
                        l_value := p_lparam3;
                ELSIF NOT m4u_dmd_utils.valid_len(p_lparam4,0,400,true)  THEN
                        l_param := 'LPARAM4';
                        l_value := p_lparam4;
                ELSIF NOT m4u_dmd_utils.valid_len(p_lparam5,0,400,true)  THEN
                        l_param := 'LPARAM5';
                        l_value := p_lparam5;

                -- validate doc params
                ELSIF NOT m4u_dmd_utils.valid_len(p_tgt_mkt_ctry ,0,30,true)  THEN
                        l_param := 'TARGET_MARKET_COUNTRY';
                        l_value := p_tgt_mkt_ctry ;
                ELSIF NOT m4u_dmd_utils.valid_len(p_tgt_mkt_div ,0,30,true)  THEN
                        l_param := 'TARGET_MARKET_SUBDIV';
                        l_value := p_tgt_mkt_div ;
                ELSIF NOT m4u_dmd_utils.valid_gtin(p_top_gtin ,true)  THEN
                        l_param := 'TOP_GTIN';
                        l_value := p_top_gtin ;
                ELSIF NOT m4u_dmd_utils.valid_gln(p_info_provider_gln ,true)  THEN
                        l_param := 'INFO_PROVIDER_GLN';
                        l_value := p_info_provider_gln;
                ELSIF NOT m4u_dmd_utils.valid_gln(p_data_rcpt_gln ,true)  THEN
                        l_param := 'DATA_RCPT_GLN';
                        l_value := p_data_rcpt_gln ;
                -- validate payload params
                ELSIF NOT m4u_dmd_utils.valid_type('PAYLOAD_TYPE',p_payload_type,true)  THEN
                        l_param := 'PAYLOAD_TYPE';
                        l_value := p_payload_type;
                ELSIF NOT m4u_dmd_utils.valid_type('DIRECTION',p_payload_dir,true)  THEN
                        l_param := 'PAYLOAD_DIRECTION';
                        l_value := p_payload_dir;
                ELSIF NOT m4u_dmd_utils.valid_payload_id(p_payload_id,true)  THEN
                        l_param := 'PAYLOAD_ID';
                        l_value := p_payload_id;

                END IF;

                IF l_param IS NOT NULL THEN
                        l_err_msg := m4u_dmd_utils.get_inv_param_msg
                                     (l_err_api,l_param,l_value);
                        RAISE fnd_api.g_exc_error;
                END IF;
                m4u_dmd_utils.log('Exiting validation block - success',2);
        END;
        --validation block ends


        SELECT m4u_dmd_docid_s.NEXTVAL
        INTO l_doc_id
        FROM dual;

        IF p_orig_doc_id = 'GENERATE' THEN
                l_orig_doc_id := p_type || '.' || to_char(sysdate,'DD-MM-RR') || '.' || '0' || '.' || l_doc_id;
        ELSE
                l_orig_doc_id := p_orig_doc_id;
        END IF;

        m4u_dmd_utils.log('l_doc_id    -|'|| l_doc_id ||'|',1);
        m4u_dmd_utils.log('insert into m4u_dmd_documents'  ,1);

        INSERT INTO m4u_dmd_documents
        (
                msg_id,doc_id,type ,action, retry_count,
                doc_status, functional_status,processing_message,
                ref_doc_id,orig_doc_id,doc_timestamp,
                top_gtin,info_provider_gln,data_recepient_gln,
                target_market_country,target_market_sub_div,
                parameter1,parameter2,parameter3,parameter4,parameter5,
                lparameter1,lparameter2,lparameter3,lparameter4,lparameter5,
                last_update_date,last_updated_by,creation_date, created_by,
                last_update_login)
        VALUES
        (       p_msg_id,l_doc_id,p_type,p_action,0,
                p_doc_status, p_func_status,p_processing_msg,
                p_ref_doc_id,l_orig_doc_id,p_timestamp,
                p_top_gtin,p_info_provider_gln,p_data_rcpt_gln,
                p_tgt_mkt_ctry,p_tgt_mkt_div,
                p_param1,p_param2,p_param3,p_param4,p_param5,
                p_lparam1,p_lparam2,p_lparam3,p_lparam4,p_lparam5,
                sysdate,FND_GLOBAL.user_id,sysdate, FND_GLOBAL.user_id,
                FND_GLOBAL.login_id
         );


        --Raise CLN event
        BEGIN
                --set key
                l_cln_evt_key    := sysdate || '.' || l_doc_id;

                --set params
                l_cln_evt_params := wf_parameter_list_t();

                wf_event.addParameterToList('RETRY_COUNT',      0,                 l_cln_evt_params);
                wf_event.addParameterToList('DOC_ID',           l_doc_id,          l_cln_evt_params);
                wf_event.addParameterToList('REF_DOC_ID',       p_ref_doc_id ,     l_cln_evt_params);

                wf_event.addParameterToList('DOC_TYPE',         p_type,            l_cln_evt_params);
                wf_event.addParameterToList('ACTION',           p_action,          l_cln_evt_params);
                wf_event.addParameterToList('DOC_STATUS',       p_doc_status,      l_cln_evt_params);
                wf_event.addParameterToList('PROCESSING_MSG',   p_processing_msg,  l_cln_evt_params);

                wf_event.addParameterToList('PAYLOAD_ID',       p_payload_id,      l_cln_evt_params);
                wf_event.addParameterToList('PAYLOAD_TYPE',     p_payload_type,    l_cln_evt_params);
                wf_event.addParameterToList('PAYLOAD_DIR',      p_payload_dir,     l_cln_evt_params);

                --raise event
                wf_event.raise
                (
                        p_event_name    => m4u_dmd_utils.c_cln_event,
                        p_event_key     => l_cln_evt_key,
                        p_parameters    => l_cln_evt_params
                );
                m4u_dmd_utils.log('l_cln_evt_key - |' || l_cln_evt_key || '|',2);
        EXCEPTION
                WHEN OTHERS THEN
                        m4u_dmd_utils.log('m4u_dmd_messages.create_document',            6);
                        m4u_dmd_utils.log('Unexpected error while raising payload event',6);
                        m4u_dmd_utils.log(SQLCODE || SQLERRM,                            6);

        END;

        m4u_dmd_utils.log('Exiting m4u_dmd_request.create_document - Success',2);

        x_doc_id  := l_doc_id;
        x_ret_sts := fnd_api.g_ret_sts_success;
        x_ret_msg := '';
        RETURN;
  EXCEPTION
        WHEN OTHERS THEN
                x_doc_id  := -1;
                m4u_dmd_utils.handle_error(l_err_api,l_err_msg,
                SQLCODE,SQLERRM,x_ret_sts,x_ret_msg);
  END create_document;

  PROCEDURE retry_request
  (
        x_errbuf        OUT NOCOPY VARCHAR2,
        x_retcode       OUT NOCOPY NUMBER,
        p_msg_id        IN         VARCHAR2,
        p_mode          IN         VARCHAR2,
        p_time          IN         DATE
  )
  IS
        l_ret_sts       VARCHAR2(30);
        l_ret_msg       VARCHAR2(50);
        l_err_api       VARCHAR2(50)    := 'm4u_dmd_requests.rerty_request';
        l_err_msg       VARCHAR2(2000);
        l_retry_count   NUMBER;
        l_param         VARCHAR2(100);
        l_value         VARCHAR2(4000);

        CURSOR docs_for_msg(p_msg_id IN VARCHAR2) IS
                SELECT  *
                FROM    m4u_dmd_documents
                WHERE   msg_id = p_msg_id;
  BEGIN
        m4u_dmd_utils.log('Entering m4u_dmd_request.rerty_request',2);
        m4u_dmd_utils.log('p_msg_id           -|'|| p_msg_id          ||'|',1);
        m4u_dmd_utils.log('p_mode             -|'|| p_mode            ||'|',1);
        m4u_dmd_utils.log('p_time             -|'|| p_time            ||'|',1);


        --validation block begins
        BEGIN
                m4u_dmd_utils.log('Entering validation block',2);
                l_param := '';
                l_value := '';

                IF NOT m4u_dmd_utils.valid_msg_id(p_msg_id,false) THEN
                        l_param := 'MSG_ID';
                        l_value := p_msg_id;
                ELSIF NOT m4u_dmd_utils.valid_type('RETRY_MODE',p_mode,false)  THEN
                        l_param := 'RETRY_MODE';
                        l_value := p_mode;
                ELSIF p_mode = m4u_dmd_utils.c_retry_timeout
                  AND p_time IS NULL THEN
                        l_param := 'FROM_TIME';
                        l_value := p_time;
                END IF;

                IF l_param IS NOT NULL THEN
                        l_err_msg := m4u_dmd_utils.get_inv_param_msg
                                     (l_err_api,l_param,l_value);
                        RAISE fnd_api.g_exc_error;
                END IF;
                m4u_dmd_utils.log('Exiting validation block - success',2);
        END;
        --validation block ends
        SELECT  retry_count
        INTO    l_retry_count
        FROM    m4u_dmd_messages
        WHERE   msg_id = p_msg_id;

        m4u_dmd_utils.log('Old l_retry_count    -|'|| l_retry_count     ||'|',1);

        l_retry_count := l_retry_count+1;

        UPDATE  m4u_dmd_messages
        SET     status      = m4u_dmd_utils.c_sts_ready,
                retry_count = l_retry_count,
                orig_msg_id = type || '.' || sysdate || '.' ||
                     l_retry_count || '.' || p_msg_id
        WHERE   msg_id = p_msg_id;

        FOR l_doc_rec IN docs_for_msg(p_msg_id)
        LOOP

                m4u_dmd_utils.log('Call update_document - ' || l_doc_rec.doc_id,1);
                l_ret_msg := '';
                l_ret_sts := '';

                IF  (p_mode = m4u_dmd_utils.c_retry_all

                    OR (p_mode = m4u_dmd_utils.c_retry_timeout AND
                        (l_doc_rec.doc_status = 'IN_PROCESS'
                         OR l_doc_rec.doc_status = 'READY') AND
                        (l_doc_rec.last_update_date - nvl(p_time,sysdate) < 0))

                    OR (p_mode = m4u_dmd_utils.c_retry_err AND
                    l_doc_rec.doc_status = m4u_dmd_utils.c_sts_error)) THEN


                        m4u_dmd_requests.update_document
                        (
                                p_doc_id                => l_doc_rec.doc_id,
                                p_retry_count           => l_retry_count,
                                p_orig_doc_id           => 'GENERATE',
                                p_doc_status            => m4u_dmd_utils.c_sts_ready,
                                p_func_status           => null,
                                x_ret_sts               => l_ret_sts,
                                x_ret_msg               => l_ret_msg
                        );

                        m4u_dmd_utils.log('l_ret_sts    - |' || l_ret_sts   || '|',2);
                        m4u_dmd_utils.log('l_ret_msg    - |' || l_ret_msg   || '|',1);

                        IF l_ret_sts <> fnd_api.g_ret_sts_success THEN
                                l_err_msg := nvl(l_ret_msg,'Unexpected error while updating document');
                                RAISE fnd_api.g_exc_error;
                        END IF;
                END IF;
        END LOOP;

        m4u_dmd_utils.log('Exiting m4u_dmd_request.rerty_request - Success',2);

        x_errbuf   := ''  ;
        x_retcode  := 0 ;
        RETURN;
  EXCEPTION
        WHEN OTHERS THEN
                m4u_dmd_utils.handle_error(l_err_api,l_err_msg,
                SQLCODE,SQLERRM,l_ret_sts,l_ret_msg);
                x_errbuf   := l_ret_msg ;
                x_retcode  := 2  ;
                RETURN;
  END retry_request;


  PROCEDURE update_request
  (
          p_msg_id              IN VARCHAR2,
          p_status              IN VARCHAR2,
          p_update_doc_flag     IN VARCHAR2,
          p_retry_count         IN NUMBER,
          p_ref_msg_id          IN VARCHAR2 := NULL,
          p_orig_msg_id         IN VARCHAR2 := NULL,
          p_msg_timstamp        IN DATE     := NULL,

          p_sender_gln          IN VARCHAR2 := NULL,
          p_receiver_gln        IN VARCHAR2 := NULL,
          p_rep_party_gln       IN VARCHAR2 := NULL,
          p_user_id             IN VARCHAR2 := NULL,
          p_user_gln            IN VARCHAR2 := NULL,

          p_bpel_instance_id    IN VARCHAR2 := NULL,
          p_bpel_process_id     IN VARCHAR2 := NULL,

          p_doc_type            IN VARCHAR2,
          p_doc_status          IN VARCHAR2 := NULL,
          p_func_status         IN VARCHAR2 := NULL,
          p_processing_msg      IN VARCHAR2 := NULL,

          p_payload             IN CLOB     := NULL,
          p_payload_dir         IN VARCHAR2 := NULL,
          p_payload_type        IN VARCHAR2 := NULL,

          x_ret_sts             OUT NOCOPY VARCHAR2,
          x_ret_msg             OUT NOCOPY VARCHAR2
  )
  IS
        CURSOR docs_for_msg(p_msg_id IN VARCHAR2, p_retry_count IN NUMBER) IS
                SELECT  *
                FROM    m4u_dmd_documents
                WHERE   msg_id = p_msg_id
                  AND   retry_count = p_retry_count;

        l_payload_id    VARCHAR2(30);
        l_msg_id        VARCHAR2(30);
        l_ret_sts       VARCHAR2(5);
        l_ret_msg       VARCHAR2(400);
        l_err_api       VARCHAR2(50)    := 'm4u_dmd_requests.update_request';
        l_err_msg       VARCHAR2(2000);
        l_param         VARCHAR2(100);
        l_value         VARCHAR2(4000);
        l_retry_count   NUMBER;
  BEGIN
        m4u_dmd_utils.log('Entering m4u_dmd_request.update_request',2);
        m4u_dmd_utils.log('p_msg_id        -|'|| p_msg_id          ||'|',1);
        m4u_dmd_utils.log('p_status        -|'|| p_status          ||'|',1);
        m4u_dmd_utils.log('p_retry_count   -|'|| p_retry_count     ||'|',1);
        m4u_dmd_utils.log('p_ref_msg_id    -|'|| p_ref_msg_id      ||'|',1);
        m4u_dmd_utils.log('p_orig_msg_id   -|'|| p_orig_msg_id     ||'|',1);
        m4u_dmd_utils.log('p_msg_timstamp  -|'|| p_msg_timstamp    ||'|',1);

        m4u_dmd_utils.log('p_sender_gln    -|'|| p_sender_gln      ||'|',1);
        m4u_dmd_utils.log('p_receiver_gln  -|'|| p_receiver_gln    ||'|',1);
        m4u_dmd_utils.log('p_rep_party_gln -|'|| p_rep_party_gln   ||'|',1);
        m4u_dmd_utils.log('p_user_gln      -|'|| p_user_gln        ||'|',1);
        m4u_dmd_utils.log('p_user_id       -|'|| p_user_id         ||'|',1);

        m4u_dmd_utils.log('p_bpel_inst_id  -|'|| p_bpel_instance_id||'|',1);
        m4u_dmd_utils.log('p_bpel_proc_id  -|'|| p_bpel_process_id ||'|',1);

        m4u_dmd_utils.log('p_doc_type      -|'|| p_doc_type        ||'|',1);
        m4u_dmd_utils.log('p_doc_status    -|'|| p_doc_status      ||'|',1);
        m4u_dmd_utils.log('p_func_status   -|'|| p_func_status     ||'|',1);
        m4u_dmd_utils.log('p_processing_msg-|'|| p_processing_msg  ||'|',1);

        m4u_dmd_utils.log('p_payload_dir   -|'|| p_payload_dir     ||'|',1);
        m4u_dmd_utils.log('p_payload_type  -|'|| p_payload_type    ||'|',1);
        m4u_dmd_utils.log('len(p_payload)  -|'|| length(p_payload) ||'|',1);

        -- validation block begin
        BEGIN
                m4u_dmd_utils.log('Entering validation block',2);
                l_param := '';
                l_value := '';
                IF NOT  m4u_dmd_utils.valid_msg_id(p_msg_id,false)
                AND NOT m4u_dmd_utils.valid_orig_msg_id(p_orig_msg_id,false) THEN
                        l_param := 'MSG_ID/ORIG_MSG_ID';
                        l_value := p_msg_id || '/' || p_orig_msg_id;
                ELSIF NOT m4u_dmd_utils.valid_type('MSG_STATUS',p_status,false)  THEN
                        l_param := 'MSG_STATUS';
                        l_value := p_status;
                ELSIF NOT m4u_dmd_utils.valid_msg_id(p_ref_msg_id,true)  THEN
                        l_param := 'REF_MSG_ID';
                        l_value := p_ref_msg_id;
                ELSIF NOT m4u_dmd_utils.valid_len(p_orig_msg_id,0,80,true)  THEN
                        l_param := 'ORIG_MSG_ID';
                        l_value := p_orig_msg_id;

                ELSIF NOT m4u_dmd_utils.valid_gln(p_sender_gln,true)  THEN
                        l_param := 'SENDER_GLN';
                        l_value := p_sender_gln;
                ELSIF NOT m4u_dmd_utils.valid_gln(p_receiver_gln,true)  THEN
                        l_param := 'RECEIVER_GLN';
                        l_value := p_receiver_gln;
                ELSIF NOT m4u_dmd_utils.valid_gln(p_rep_party_gln,true)  THEN
                        l_param := 'REP_PARTY_GLN';
                        l_value := p_rep_party_gln;
                ELSIF NOT m4u_dmd_utils.valid_gln(p_user_gln,true)  THEN
                        l_param := 'USER_GLN';
                        l_value := p_user_gln;
                ELSIF NOT m4u_dmd_utils.valid_len(p_user_id,0,30,true)  THEN
                        l_param := 'USER_ID';
                        l_value := p_user_id;

                ELSIF NOT m4u_dmd_utils.valid_len(p_bpel_instance_id,0,100,true)  THEN
                        l_param := 'BPEL_INSTANCE_ID';
                        l_value := p_bpel_instance_id;
                ELSIF NOT m4u_dmd_utils.valid_len(p_bpel_process_id,0,100,true)  THEN
                        l_param := 'BPEL_PROCESS_ID';
                        l_value := p_bpel_process_id;

                ELSIF NOT m4u_dmd_utils.valid_type('DOC_TYPE',p_doc_type,true)  THEN
                        l_param := 'DOC_TYPE';
                        l_value := p_doc_type;
                ELSIF NOT m4u_dmd_utils.valid_type('DOC_STATUS',p_doc_status,true)  THEN
                        l_param := 'DOC_STATUS';
                        l_value := p_doc_status;
                ELSIF NOT m4u_dmd_utils.valid_len(p_processing_msg,0,400,true)  THEN
                        l_param := 'PROCESSING_MSG';
                        l_value :=  p_processing_msg ;

                ELSIF NOT m4u_dmd_utils.valid_type('PAYLOAD_TYPE',p_payload_type,true)  THEN
                        l_param := 'PAYLOAD_TYPE';
                        l_value := p_payload_type;
                ELSIF NOT m4u_dmd_utils.valid_type('DIRECTION',p_payload_dir,true)  THEN
                        l_param := 'PAYLOAD_DIRECTION';
                        l_value := p_payload_dir;
                END IF;


                SELECT msg_id, retry_count
                INTO   l_msg_id, l_retry_count
                FROM   m4u_dmd_messages
                WHERE  orig_msg_id = p_orig_msg_id
                    OR msg_id = p_msg_id;

                IF p_retry_count IS NOT NULL AND
                   l_retry_count <> p_retry_count THEN
                        l_param := 'RETRY_COUNT';
                        l_value := p_retry_count;
                END IF;

                IF l_param IS NOT NULL THEN
                        l_err_msg := m4u_dmd_utils.get_inv_param_msg
                                     (l_err_api,l_param,l_value);
                        RAISE fnd_api.g_exc_error;
                END IF;
                m4u_dmd_utils.log('Exiting validation block - success',2);
        END;
        -- validation block ends

        m4u_dmd_utils.log('UPDATE m4u_dmd_messages'        ,1);
        UPDATE  m4u_dmd_messages
        SET
                ref_msg_id              = NVL(p_ref_msg_id,       ref_msg_id      ),
                orig_msg_id             = NVL(p_orig_msg_id,      orig_msg_id     ),
                status                  = NVL(p_status,           status          ),
                msg_timestamp           = NVL(p_msg_timstamp,     msg_timestamp   ),

                bpel_process_id         = NVL(p_bpel_process_id,  bpel_process_id),
                bpel_instance_id        = NVL(p_bpel_instance_id, bpel_instance_id),

                sender_gln              = NVL(p_sender_gln,       sender_gln      ),
                receiver_gln            = NVL(p_receiver_gln,     receiver_gln    ),
                rep_party_gln           = NVL(p_rep_party_gln,    rep_party_gln   ),
                user_id                 = NVL(p_user_id,          user_id         ),
                user_gln                = NVL(p_user_gln,         user_gln        )
        WHERE   msg_id = l_msg_id;

        m4u_dmd_utils.log('Update SQL%ROWCOUNT - '||SQL%rowcount            ,1);




        l_payload_id := null;

        IF p_payload IS NOT NULL THEN
                m4u_dmd_utils.log('Call m4u_dmd_requests.create_payload'  ,2);
                l_ret_msg := '';
                l_ret_sts := '';
                m4u_dmd_requests.create_payload
                (
                        p_xml           => p_payload,
                        p_type          => p_payload_type,
                        p_dir           => p_payload_dir,
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
        END IF;


        IF p_update_doc_flag = 'Y' THEN
        -- loop and update all req documents
                m4u_dmd_utils.log('Update documents',1);
                --For cin ack update CIN only on sent
                --not on init or retry (limitation)
                IF  p_payload_type = m4u_dmd_utils.c_type_cin_ack
                AND p_doc_status IN (m4u_dmd_utils.c_sts_sent,m4u_dmd_utils.c_sts_error,
                                     m4u_dmd_utils.c_sts_fail) THEN
                        l_msg_id := p_ref_msg_id;
                END IF;

                FOR l_doc_rec IN docs_for_msg(l_msg_id,l_retry_count)
                LOOP

                        m4u_dmd_utils.log('Call update_document - ' || l_doc_rec.doc_id,1);
                        l_ret_msg := '';
                        l_ret_sts := '';
                        m4u_dmd_requests.update_document
                        (
                                p_doc_id                => l_doc_rec.doc_id,
                                p_ref_doc_id            => l_doc_rec.ref_doc_id,
                                p_doc_status            => p_doc_status,
                                p_func_status           => null,
                                p_retry_count           => l_retry_count,
                                p_processing_msg        => p_processing_msg,
                                p_payload_id            => l_payload_id,
                                p_payload_dir           => p_payload_dir,
                                p_payload_type          => p_payload_type,
                                x_ret_sts               => l_ret_sts,
                                x_ret_msg               => l_ret_msg
                        );

                        m4u_dmd_utils.log('l_ret_sts    - |' || l_ret_sts   || '|',1);
                        m4u_dmd_utils.log('l_ret_msg    - |' || l_ret_msg   || '|',1);

                        IF l_ret_sts <> fnd_api.g_ret_sts_success THEN
                                l_err_msg := nvl(l_ret_msg,'Unexpected error while updating document');
                                RAISE fnd_api.g_exc_error;
                        END IF;
                END LOOP;

        END IF;

        m4u_dmd_utils.log('Exiting m4u_dmd_request.update_request - Success',2);

        x_ret_sts := fnd_api.g_ret_sts_success;
        x_ret_msg := '';
        RETURN;
  EXCEPTION
        WHEN OTHERS THEN
                m4u_dmd_utils.handle_error(l_err_api,l_err_msg,
                SQLCODE,SQLERRM,x_ret_sts,x_ret_msg);
  END update_request;

  -- updates document record in m4u_dmd_documents
  -- only updatable fields are allowed inputs
  PROCEDURE update_document
  (
        p_doc_id                IN VARCHAR2,
        p_doc_status            IN VARCHAR2,
        p_func_status           IN VARCHAR2,
        p_retry_count           IN NUMBER,
        p_processing_msg        IN VARCHAR2 := NULL,
        p_ref_doc_id            IN VARCHAR2 := NULL,
        p_orig_doc_id           IN VARCHAR2 := NULL,
        p_timestamp             IN VARCHAR2 := NULL,

        p_top_gtin              IN VARCHAR2 := NULL,
        p_info_provider_gln     IN VARCHAR2 := NULL,
        p_data_recepient_gln    IN VARCHAR2 := NULL,
        p_tgt_mkt_cntry         IN VARCHAR2 := NULL,
        p_tgt_mkt_subdiv        IN VARCHAR2 := NULL,

        p_param1                IN VARCHAR2 := NULL,
        p_param2                IN VARCHAR2 := NULL,
        p_param3                IN VARCHAR2 := NULL,
        p_param4                IN VARCHAR2 := NULL,
        p_param5                IN VARCHAR2 := NULL,
        p_lparam1               IN VARCHAR2 := NULL,
        p_lparam2               IN VARCHAR2 := NULL,
        p_lparam3               IN VARCHAR2 := NULL,
        p_lparam4               IN VARCHAR2 := NULL,
        p_lparam5               IN VARCHAR2 := NULL,

        p_payload_id            IN VARCHAR2 := NULL,
        p_payload_dir           IN VARCHAR2 := NULL,
        p_payload_type          IN VARCHAR2 := NULL,
        x_ret_sts               OUT NOCOPY VARCHAR2,
        x_ret_msg               OUT NOCOPY VARCHAR2
  )
  IS
        l_cln_evt_params        wf_parameter_list_t;
        l_cln_evt_key           VARCHAR2(30);
        l_err_api               VARCHAR2(50)    := 'm4u_dmd_requests.update_document';
        l_err_msg               VARCHAR2(2000);
        l_param                 VARCHAR2(100);
        l_value                 VARCHAR2(2000);
        l_orig_doc_id           VARCHAR2(80);
        l_doc_rec               m4u_dmd_documents%rowtype;
        l_doc_id                VARCHAR2(30);
        l_retry_count           NUMBER;
        l_cis_status            VARCHAR2(30);
  BEGIN

        -- TBD :validate parameters
        m4u_dmd_utils.log('Entering m4u_dmd_request.update_document',2);
        m4u_dmd_utils.log('p_doc_id           -|'|| p_doc_id            ||'|',1);
        m4u_dmd_utils.log('p_retry_count      -|'|| p_retry_count       ||'|',1);
        m4u_dmd_utils.log('p_doc_status       -|'|| p_doc_status        ||'|',1);
        m4u_dmd_utils.log('p_func_status      -|'|| p_func_status       ||'|',1);
        m4u_dmd_utils.log('p_processing_msg   -|'|| p_processing_msg    ||'|',1);
        m4u_dmd_utils.log('p_ref_doc_id       -|'|| p_ref_doc_id        ||'|',1);
        m4u_dmd_utils.log('p_orig_doc_id      -|'|| p_orig_doc_id       ||'|',1);
        m4u_dmd_utils.log('p_timestamp        -|'|| p_timestamp         ||'|',1);

        m4u_dmd_utils.log('p_top_gtin         -|'|| p_top_gtin          ||'|',1);
        m4u_dmd_utils.log('p_info_provider_gln-|'|| p_info_provider_gln ||'|',1);
        m4u_dmd_utils.log('p_data_rcpt_gln    -|'|| p_data_recepient_gln||'|',1);
        m4u_dmd_utils.log('p_tgt_mkt_ctry     -|'|| p_tgt_mkt_cntry     ||'|',1);
        m4u_dmd_utils.log('p_tgt_mkt_div      -|'|| p_tgt_mkt_subdiv    ||'|',1);

        m4u_dmd_utils.log('p_param1           -|'|| p_param1            ||'|',1);
        m4u_dmd_utils.log('p_param2           -|'|| p_param2            ||'|',1);
        m4u_dmd_utils.log('p_param3           -|'|| p_param3            ||'|',1);
        m4u_dmd_utils.log('p_param4           -|'|| p_param4            ||'|',1);
        m4u_dmd_utils.log('p_param5           -|'|| p_param5            ||'|',1);
        m4u_dmd_utils.log('p_lparam1          -|'|| p_lparam1           ||'|',1);
        m4u_dmd_utils.log('p_lparam2          -|'|| p_lparam2           ||'|',1);
        m4u_dmd_utils.log('p_lparam3          -|'|| p_lparam3           ||'|',1);
        m4u_dmd_utils.log('p_lparam4          -|'|| p_lparam4           ||'|',1);
        m4u_dmd_utils.log('p_lparam5          -|'|| p_lparam5           ||'|',1);

        m4u_dmd_utils.log('p_payload_id       -|'|| p_payload_id        ||'|',1);
        m4u_dmd_utils.log('p_payload_dir      -|'|| p_payload_dir       ||'|',1);
        m4u_dmd_utils.log('p_payload_type     -|'|| p_payload_type      ||'|',1);

        --validation block begins
        BEGIN
                m4u_dmd_utils.log('Entering validation block',2);
                l_param := '';
                l_value := '';

                -- validate id, type, status params
                IF NOT m4u_dmd_utils.valid_type('DOC_STATUS',p_doc_status,false)  THEN
                        l_param := 'DOC_STATUS';
                        l_value := p_doc_status;
                ELSIF NOT m4u_dmd_utils.valid_doc_id(p_doc_id,false)
                  AND NOT m4u_dmd_utils.valid_orig_doc_id(p_orig_doc_id,false) THEN
                        l_param := 'DOC_ID/ORIG_DOC_ID';
                        l_value := p_doc_id|| '/' || p_orig_doc_id;
                ELSIF NOT m4u_dmd_utils.valid_doc_id(p_ref_doc_id,true)  THEN
                        l_param := 'REF_DOC_ID';
                        l_value := p_ref_doc_id;
                ELSIF NOT m4u_dmd_utils.valid_len(p_orig_doc_id ,0,80,true)  THEN
                        l_param := 'ORIG_DOC_ID';
                        l_value := p_orig_doc_id ;
                ELSIF NOT m4u_dmd_utils.valid_len(p_processing_msg,0,400,true)  THEN
                        l_param := 'PROCESSING_MSG';
                        l_value :=  p_processing_msg ;


                -- validate extensible params
                ELSIF NOT m4u_dmd_utils.valid_len(p_param1,0,50,true)  THEN
                        l_param := 'PARAM1';
                        l_value := p_param1;
                ELSIF NOT m4u_dmd_utils.valid_len(p_param2,0,50,true)  THEN
                        l_param := 'PARAM2';
                        l_value := p_param2;
                ELSIF NOT m4u_dmd_utils.valid_len(p_param3,0,50,true)  THEN
                        l_param := 'PARAM3';
                        l_value := p_param3;
                ELSIF NOT m4u_dmd_utils.valid_len(p_param4,0,50,true)  THEN
                        l_param := 'PARAM4';
                        l_value := p_param4;
                ELSIF NOT m4u_dmd_utils.valid_len(p_param5,0,50,true)  THEN
                        l_param := 'PARAM5';
                        l_value := p_param5;
                ELSIF NOT m4u_dmd_utils.valid_len(p_lparam1,0,400,true)  THEN
                        l_param := 'LPARAM1';
                        l_value := p_lparam1;
                ELSIF NOT m4u_dmd_utils.valid_len(p_lparam2,0,400,true)  THEN
                        l_param := 'LPARAM2';
                        l_value := p_lparam2;
                ELSIF NOT m4u_dmd_utils.valid_len(p_lparam3,0,400,true)  THEN
                        l_param := 'LPARAM3';
                        l_value := p_lparam3;
                ELSIF NOT m4u_dmd_utils.valid_len(p_lparam4,0,400,true)  THEN
                        l_param := 'LPARAM4';
                        l_value := p_lparam4;
                ELSIF NOT m4u_dmd_utils.valid_len(p_lparam5,0,400,true)  THEN
                        l_param := 'LPARAM5';
                        l_value := p_lparam5;

                -- validate doc params
                ELSIF NOT m4u_dmd_utils.valid_len(p_tgt_mkt_cntry ,0,30,true)  THEN
                        l_param := 'TARGET_MARKET_COUNTRY';
                        l_value := p_tgt_mkt_cntry ;
                ELSIF NOT m4u_dmd_utils.valid_len(p_tgt_mkt_subdiv ,0,30,true)  THEN
                        l_param := 'TARGET_MARKET_SUBDIV';
                        l_value := p_tgt_mkt_subdiv ;
                ELSIF NOT m4u_dmd_utils.valid_gtin(p_top_gtin ,true)  THEN
                        l_param := 'TOP_GTIN';
                        l_value := p_top_gtin ;
                ELSIF NOT m4u_dmd_utils.valid_gln(p_info_provider_gln ,true)  THEN
                        l_param := 'INFO_PROVIDER_GLN';
                        l_value := p_info_provider_gln;
                ELSIF NOT m4u_dmd_utils.valid_gln(p_data_recepient_gln ,true)  THEN
                        l_param := 'DATA_RCPT_GLN';
                        l_value := p_data_recepient_gln ;

                -- validate payload params
                ELSIF NOT m4u_dmd_utils.valid_type('PAYLOAD_TYPE',p_payload_type,true)  THEN
                        l_param := 'PAYLOAD_TYPE';
                        l_value := p_payload_type;
                ELSIF NOT m4u_dmd_utils.valid_type('DIRECTION',p_payload_dir,true)  THEN
                        l_param := 'PAYLOAD_DIRECTION';
                        l_value := p_payload_dir;
                ELSIF NOT m4u_dmd_utils.valid_payload_id(p_payload_id,true)  THEN
                        l_param := 'PAYLOAD_ID';
                        l_value := p_payload_id;

                END IF;

                IF l_param IS NOT NULL THEN
                        l_err_msg := m4u_dmd_utils.get_inv_param_msg
                                     (l_err_api,l_param,l_value);
                        RAISE fnd_api.g_exc_error;
                END IF;
                m4u_dmd_utils.log('Exiting validation block - success',2);
        END;
        --validation block ends

        IF p_doc_id IS NULL THEN
                SELECT  doc_id , retry_count
                INTO    l_doc_id, l_retry_count
                FROM    m4u_dmd_documents
                WHERE   orig_doc_id = p_orig_doc_id;
        ELSE
                l_doc_id      := p_doc_id;
                l_retry_count := p_retry_count;
        END IF;

        SELECT  *
        INTO    l_doc_rec
        FROM    m4u_dmd_documents
        WHERE   doc_id = l_doc_id;

        IF p_orig_doc_id = 'GENERATE' THEN
                l_orig_doc_id := l_doc_rec.type || '.' || sysdate ||
                           '.' || p_retry_count  || '.' || l_doc_id;
        ELSE
                l_orig_doc_id := l_doc_rec.orig_doc_id;
        END IF;

        m4u_dmd_utils.log('l_doc_id           -|'|| l_doc_id            ||'|',1);

        m4u_dmd_utils.log('UPDATE m4u_dmd_documents'       ,1);
        UPDATE  m4u_dmd_documents
        SET     ref_doc_id              = NVL(p_ref_doc_id, ref_doc_id            ),
                orig_doc_id             = NVL(l_orig_doc_id, orig_doc_id          ),
                retry_count             = NVL(l_retry_count,retry_count           ),
                doc_status              = NVL(p_doc_status,doc_status             ),
                processing_message      = NVL(p_processing_msg,processing_message ),
                functional_status       = NVL(p_func_status,functional_status     ),
                doc_timestamp           = NVL(p_timestamp, doc_timestamp          ),

                top_gtin                = NVL(p_top_gtin,   top_gtin                   ),
                info_provider_gln       = NVL(p_info_provider_gln , info_provider_gln  ),
                data_recepient_gln      = NVL(p_data_recepient_gln, data_recepient_gln ),
                target_market_country   = NVL(target_market_country, p_tgt_mkt_cntry   ),
                target_market_sub_div   = NVL(target_market_sub_div, p_tgt_mkt_subdiv  ),

                parameter1              = NVL(p_param1  , parameter1 ),
                parameter2              = NVL(p_param2  , parameter2 ),
                parameter3              = NVL(p_param3  , parameter3 ),
                parameter4              = NVL(p_param4  , parameter4 ),
                parameter5              = NVL(p_param5  , parameter5 ),
                lparameter1             = NVL(p_lparam1 , lparameter1),
                lparameter2             = NVL(p_lparam2 , lparameter2),
                lparameter3             = NVL(p_lparam3 , lparameter3),
                lparameter4             = NVL(p_lparam4 , lparameter4),
                lparameter5             = NVL(p_lparam5 , lparameter5),


                last_update_date        = sysdate,
                last_updated_by         = FND_GLOBAL.user_id,
                last_update_login       = FND_GLOBAL.login_id
        WHERE   doc_id                  = l_doc_id;


        m4u_dmd_utils.log('Update SQL%ROWCOUNT - ' ||SQL%rowcount,1);

        --cis specific processing
        BEGIN
                IF l_doc_rec.type = m4u_dmd_utils.c_type_cis  THEN

                        m4u_dmd_utils.log('Update CIS record ',1);
                        BEGIN
                                SELECT  status
                                INTO    l_cis_status
                                FROM    m4u_dmd_subscriptions
                                WHERE   subscription_name   = l_doc_rec.lparameter1;
                        EXCEPTION
                                WHEN OTHERS THEN
                                        null;
                        END;

                        IF l_cis_status = 'ADD_IN_PROGRESS' THEN
                                IF p_doc_status = m4u_dmd_utils.c_sts_success THEN
                                        l_cis_status := 'SUBSCRIBED';
                                ELSIF p_doc_status = m4u_dmd_utils.c_sts_sent THEN
                                        l_cis_status := l_cis_status;
                                ELSIF p_doc_status in
                                (m4u_dmd_utils.c_sts_error, m4u_dmd_utils.c_sts_fail) THEN
                                        l_cis_status := 'ADD_FAILED';
                                END IF;
                        ELSIF l_cis_status = 'DELETE_IN_PROGRESS' THEN
                                IF p_doc_status = m4u_dmd_utils.c_sts_success THEN
                                        l_cis_status := 'UNSUBSCRIBED';
                                ELSIF p_doc_status = m4u_dmd_utils.c_sts_sent THEN
                                        l_cis_status := l_cis_status;
                                ELSIF p_doc_status in
                                (m4u_dmd_utils.c_sts_error, m4u_dmd_utils.c_sts_fail) THEN
                                        l_cis_status := 'DELETE_FAILED';
                                END IF;
                        END IF;

                        UPDATE  m4u_dmd_subscriptions
                        SET     status = l_cis_status
                        WHERE   subscription_name   = l_doc_rec.lparameter1;

                        m4u_dmd_utils.log('Update SQL%ROWCOUNT - ' ||SQL%rowcount,1);
                END IF;
        END;

        --Raise CLN event
        BEGIN
                --set key
                l_cln_evt_key    := sysdate || '.' || p_doc_id;

                --set params
                l_cln_evt_params := wf_parameter_list_t();
                wf_event.addParameterToList('DOC_ID',           l_doc_id,          l_cln_evt_params);
                wf_event.addParameterToList('REF_DOC_ID',       p_ref_doc_id,      l_cln_evt_params);
                wf_event.addParameterToList('RETRY_COUNT',      l_retry_count,     l_cln_evt_params);

                wf_event.addParameterToList('DOC_TYPE',         l_doc_rec.type,    l_cln_evt_params);
                wf_event.addParameterToList('ACTION',           l_doc_rec.action,  l_cln_evt_params);
                wf_event.addParameterToList('DOC_STATUS',       p_doc_status,      l_cln_evt_params);
                wf_event.addParameterToList('PROCESSING_MSG',   p_processing_msg,  l_cln_evt_params);

                wf_event.addParameterToList('PAYLOAD_ID',       p_payload_id,   l_cln_evt_params);
                wf_event.addParameterToList('PAYLOAD_TYPE',     p_payload_type, l_cln_evt_params);
                wf_event.addParameterToList('PAYLOAD_DIR',      p_payload_dir,  l_cln_evt_params);

                --raise event
                wf_event.raise
                (
                        p_event_name    => m4u_dmd_utils.c_cln_event,
                        p_event_key     => l_cln_evt_key,
                        p_parameters    => l_cln_evt_params
                );
        EXCEPTION
                WHEN OTHERS THEN
                        m4u_dmd_utils.log('m4u_dmd_messages.create_document',            6);
                        m4u_dmd_utils.log('Unexpected error while raising payload event',6);
                        m4u_dmd_utils.log(SQLCODE || SQLERRM,                            6);

        END;


        m4u_dmd_utils.log('Exiting m4u_dmd_request.update_document - Success',2);
        x_ret_sts := fnd_api.g_ret_sts_success;
        x_ret_msg := '';
        RETURN; --sucess

  EXCEPTION
        WHEN OTHERS THEN
                m4u_dmd_utils.handle_error(l_err_api,l_err_msg,
                SQLCODE,SQLERRM,x_ret_sts,x_ret_msg);
  END update_document;

END m4u_dmd_requests;

/
