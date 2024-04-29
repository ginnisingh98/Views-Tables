--------------------------------------------------------
--  DDL for Package Body M4U_CLN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."M4U_CLN_PKG" AS
 /* $Header: M4UDCLNB.pls 120.2 2007/06/13 10:27:36 bsaratna noship $ */

   FUNCTION log_payload
   (
        p_subscription_guid     IN RAW,
        p_event                 IN OUT NOCOPY wf_event_t
   ) RETURN VARCHAR2
   AS
        l_params        wf_parameter_list_t;
        l_clob          CLOB;
        l_ecx_doc_num   VARCHAR2(100);
        l_direction     VARCHAR2(10);
        l_payload_type  VARCHAR2(30);
        l_txn_styp      VARCHAR2(30);
        l_payload_id    VARCHAR2(30);
        l_event_key     VARCHAR2(30);
        l_event_name    VARCHAR2(100);
        l_ret_sts       VARCHAR2(30);
        l_ret_msg       VARCHAR2(4000);
   BEGIN


        m4u_dmd_utils.log('Entering m4u_cln_pkg.log_payload',2);

        l_event_key             := p_event.getEventKey();
        l_event_name            := p_event.getEventName();

        m4u_dmd_utils.log('l_event_key      -|' || l_event_key      || '|',6);
        m4u_dmd_utils.log('l_event_name     -|' || l_event_name     || '|',6);

        -- reading parameters
        l_params                := p_event.getParameterList();
        l_payload_id            := wf_event.getValueForParameter('PAYLOAD_ID',  l_params);
        l_payload_type          := wf_event.getValueForParameter('PAYLOAD_TYPE',l_params);
        l_direction             := wf_event.getValueForParameter('PAYLOAD_DIR' ,l_params);

        l_ecx_doc_num           := l_payload_type || '.' || l_payload_id;
        IF l_direction = m4u_dmd_utils.c_dir_out THEN
                l_txn_styp := m4u_cln_pkg.c_xmlg_styp_out;
        ELSE
                l_txn_styp := m4u_cln_pkg.c_xmlg_styp_in;
        END IF;


        m4u_dmd_utils.log('l_ecx_doc_num    -|' || l_ecx_doc_num    || '|',6);
        m4u_dmd_utils.log('l_payload_id     -|' || l_payload_id     || '|',1);
        m4u_dmd_utils.log('l_payload_type   -|' || l_payload_type   || '|',1);
        m4u_dmd_utils.log('l_direction      -|' || l_direction      || '|',6);
        m4u_dmd_utils.log('l_txn_styp       -|' || l_txn_styp       || '|',1);


        BEGIN
                SELECT  payload
                INTO    l_clob
                FROM    m4u_dmd_payloads
                WHERE   payload_id = l_payload_id;
        EXCEPTION
                WHEN OTHERS THEN
                        m4u_dmd_utils.log('Error retrieving payload',6);
                        m4u_dmd_utils.log(SQLCODE || '-' || SQLERRM  ,6);
                        RAISE;
        END;

        IF l_clob IS NOT NULL THEN
                m4u_dmd_utils.log('length(l_clob)   -|' || length(l_clob)   || '|',6);
        END IF;

        m4u_dmd_utils.log('Call ecx_errorlog.log_document',2);
        ecx_errorlog.log_document
        (
                o_retcode               =>    l_ret_sts,
                o_retmsg                =>    l_ret_msg,
                i_msgid                 =>     SYS_GUID,
                i_message_type          =>    'XML',
                i_message_standard      =>    m4u_cln_pkg.c_xmlg_std,
                i_transaction_type      =>    m4u_cln_pkg.c_xmlg_type,
                i_transaction_subtype   =>    l_txn_styp,
                i_document_number       =>    l_ecx_doc_num,
                i_partyid               =>    m4u_cln_pkg.g_party_id,
                i_party_site_id         =>    m4u_cln_pkg.g_party_site_id,
                i_party_type            =>    m4u_cln_pkg.c_party_type,
                i_protocol_type         =>    'HTTP',
                i_protocol_address      =>    null,
                i_username              =>    null,
                i_password              =>    null,
                i_attribute1            =>    null,
                i_attribute2            =>    null,
                i_attribute3            =>    null,
                i_attribute4            =>    null,
                i_attribute5            =>    null,
                i_payload               =>    l_clob,
                i_internal_control_num  =>    null,
                i_status                =>    null,
                i_direction             =>    l_direction,
                i_outmsgid              =>    null,
                i_logfile               =>    null,
                i_item_type             =>    null,
                i_item_key              =>    null,
                i_activity_id           =>    null,
                i_event_name            =>    l_event_name,
                i_event_key             =>    l_event_key,
                i_cb_event_name         =>    null,
                i_cb_event_key          =>    null,
                i_block_mode            =>    'N'
        );

        m4u_dmd_utils.log('l_ret_sts    -|' || l_ret_sts   || '|',2);
        m4u_dmd_utils.log('l_ret_msg    -|' || l_ret_msg   || '|',2);
        m4u_dmd_utils.log('Exiting m4u_cln_pkg.log_payload - Success' ,2);

        RETURN 'SUCCESS';

   EXCEPTION
        WHEN OTHERS THEN
                m4u_dmd_utils.log('m4u_cln_pkg.log_payload',6);
                m4u_dmd_utils.log('Unexpected error occured while processing',6);
                m4u_dmd_utils.log(SQLCODE || '-' || SQLERRM,6);
                RETURN 'SUCCESS';
   END log_payload;

   FUNCTION update_collab
   (
        p_subscription_guid     IN RAW,
        p_event                 IN OUT NOCOPY wf_event_t
   ) RETURN VARCHAR2
   AS
        l_params         wf_parameter_list_t;
        l_event_key      VARCHAR2(50);
        l_event_name     VARCHAR2(50);

        l_ret_sts        VARCHAR2(5);
        l_ret_msg        VARCHAR2(4000);

        l_cln_pt         VARCHAR2(30);
        l_cln_sts        VARCHAR2(30);
        l_cln_disp       VARCHAR2(30);
        l_cln_type       VARCHAR2(30);
        l_cln_doc_type   VARCHAR2(30);
        l_cln_msg        VARCHAR2(400);
        l_cln_doc_sts    VARCHAR2(30);
        l_cln_dtl_msg    VARCHAR2(2000);
        l_xmlg_doc_id    VARCHAR2(30);
        l_xmlg_type      VARCHAR2(30);
        l_xmlg_styp      VARCHAR2(30);

        l_cln_id         VARCHAR2(30);
        l_cln_dtl_id     VARCHAR2(30);
        l_cln_ref_id     VARCHAR2(30);
        l_cln_doc_id     VARCHAR2(30);
        l_create_flag    BOOLEAN := true;

        l_doc_id         VARCHAR2(30);
        l_retry_count    NUMBER;
        l_ref_doc_id     VARCHAR2(30);

        l_doc_type       VARCHAR2(30);
        l_action         VARCHAR2(30);
        l_doc_sts        VARCHAR2(30);
        l_processing_msg VARCHAR2(4000);


        l_payload_id     VARCHAR2(30);
        l_payload_dir    VARCHAR2(30);
        l_payload_type   VARCHAR2(30);


        l_m4u_doc_rec   m4u_dmd_documents%ROWTYPE;
        l_m4u_msg_rec   m4u_dmd_messages%ROWTYPE;
   BEGIN

        m4u_dmd_utils.log('Entering m4u_cln_pkg.update_collab',6);
        l_event_key             := p_event.getEventKey();
        l_event_name            := p_event.getEventName();

        m4u_dmd_utils.log('l_event_key      -|' || l_event_key      || '|',1);
        m4u_dmd_utils.log('l_event_name     -|' || l_event_name     || '|',1);

        -- reading parameters
        l_params                := p_event.getParameterList();
        l_retry_count           := wf_event.getValueForParameter('RETRY_COUNT'   ,l_params);
        l_doc_id                := wf_event.getValueForParameter('DOC_ID'        ,l_params);
        l_ref_doc_id            := wf_event.getValueForParameter('REF_DOC_ID'    ,l_params);

        l_doc_type              := wf_event.getValueForParameter('DOC_TYPE'      ,l_params);
        l_action                := wf_event.getValueForParameter('ACTION'        ,l_params);
        l_doc_sts               := wf_event.getValueForParameter('DOC_STATUS'    ,l_params);
        l_processing_msg        := wf_event.getValueForParameter('PROCESSING_MSG',l_params);

        l_payload_id            := wf_event.getValueForParameter('PAYLOAD_ID'    ,l_params);
        l_payload_dir           := wf_event.getValueForParameter('PAYLOAD_DIR'   ,l_params);
        l_payload_type          := wf_event.getValueForParameter('PAYLOAD_TYPE'  ,l_params);


        m4u_dmd_utils.log('l_ref_doc_id     -|' || l_ref_doc_id     || '|',1);
        m4u_dmd_utils.log('l_doc_id         -|' || l_doc_id         || '|',1);
        m4u_dmd_utils.log('l_doc_typ        -|' || l_doc_type       || '|',1);
        m4u_dmd_utils.log('l_retry_count    -|' || l_retry_count    || '|',1);
        m4u_dmd_utils.log('l_action         -|' || l_action         || '|',1);

        m4u_dmd_utils.log('l_doc_sts        -|' || l_doc_sts        || '|',1);
        m4u_dmd_utils.log('l_processing_msg -|' || l_processing_msg || '|',1);

        m4u_dmd_utils.log('l_payload_id     -|' || l_payload_id     || '|',1);
        m4u_dmd_utils.log('l_payload_dir    -|' || l_payload_dir    || '|',1);
        m4u_dmd_utils.log('l_payload_type   -|' || l_payload_type   || '|',1);

        -- query m4u_dmd_documents
        SELECT  *
        INTO    l_m4u_doc_rec
        FROM    m4u_dmd_documents
        WHERE   doc_id = l_doc_id;
        m4u_dmd_utils.log('m4u_doc_rec.doc_id -|' || l_m4u_doc_rec.doc_id || '|',1);

        -- query m4u_dmd_messages
        SELECT  *
        INTO    l_m4u_msg_rec
        FROM    m4u_dmd_messages
        WHERE   msg_id = l_m4u_doc_rec.msg_id;
        m4u_dmd_utils.log('m4u_msg_rec.msg_id -|' || l_m4u_msg_rec.msg_id || '|',1);

        --xmlg payload reference
        IF l_payload_id IS NOT NULL THEN
                l_xmlg_doc_id   := l_payload_type || '.' || l_payload_id;
                l_xmlg_type     := m4u_cln_pkg.c_xmlg_type;

                IF l_payload_dir = m4u_dmd_utils.c_dir_out THEN
                        l_xmlg_styp     := m4u_cln_pkg.c_xmlg_styp_out;
                ELSE
                        l_xmlg_styp     := m4u_cln_pkg.c_xmlg_styp_in;
                END IF;
        END IF;


        --todo: fill this junk  BEGIN
        IF l_doc_type = m4u_dmd_utils.c_type_rfcin THEN
                l_cln_doc_id    :=  l_doc_type || '.' ||l_doc_id;
                l_cln_ref_id    :=  l_doc_type || '.' ||l_doc_id;
                l_cln_type      :=  l_doc_type ;
                l_cln_doc_type  :=  l_doc_type;
                l_payload_dir   :=  nvl(l_payload_dir,m4u_dmd_utils.c_dir_out);
                l_cln_dtl_msg   :=  l_processing_msg;

                IF      l_doc_sts = m4u_dmd_utils.c_sts_ready  AND  l_retry_count = 0 THEN
                        l_create_flag   := true;
                        l_cln_doc_sts   := 'SUCCESS';
                        l_cln_pt        := 'APPS';
                        l_cln_sts       := 'INITIATED';
                        l_cln_disp      := 'PENDING';
                        fnd_message.set_name('CLN','M4U_DMD_REQUEST_INIT');
                        fnd_message.set_token('TYPE','Request for Catalogue Item Notification');
                        l_cln_msg       := fnd_message.get;

                ELSIF   l_doc_sts = m4u_dmd_utils.c_sts_ready  AND  l_retry_count > 0 THEN
                        l_create_flag   := false;
                        l_cln_doc_sts   := 'SUCCESS';
                        l_cln_pt        := 'APPS';
                        l_cln_sts       := 'INITIATED';
                        l_cln_disp      := 'PENDING';
                        fnd_message.set_name('CLN','M4U_DMD_REQUEST_RETRY');
                        fnd_message.set_token('TYPE','Request for Catalogue Item Notification');
                        l_cln_msg       := fnd_message.get;

                ELSIF   l_doc_sts = m4u_dmd_utils.c_sts_sent              THEN
                        l_create_flag   := false;
                        l_cln_doc_sts   := 'SUCCESS';
                        l_cln_pt        := 'APPS';
                        l_cln_sts       := 'STARTED';
                        l_cln_disp      := 'PENDING';
                        fnd_message.set_name('CLN','M4U_DMD_REQUEST_SENT');
                        fnd_message.set_token('TYPE','Request for Catalogue Item Notification');
                        l_cln_msg       := fnd_message.get;

                ELSIF   l_doc_sts = m4u_dmd_utils.c_sts_success THEN
                        l_create_flag   := false;
                        l_cln_doc_sts   := 'SUCCESS';
                        l_cln_pt        := 'B2B_SERVER';
                        l_cln_sts       := 'COMPLETED';
                        l_cln_disp      := 'SYNCH';

                        fnd_message.set_name('CLN','M4U_DMD_REQUEST_SUCCESS');
                        fnd_message.set_token('TYPE','Request for Catalogue Item Notification');
                        l_cln_msg       := fnd_message.get;


                ELSIF   l_doc_sts = m4u_dmd_utils.c_sts_fail    THEN
                        l_create_flag   := false;
                        l_cln_doc_sts   := 'SUCCESS';
                        l_cln_pt        := 'B2B_SERVER';
                        l_cln_sts       := 'COMPLETED';
                        l_cln_disp      := 'REJECTED';

                        fnd_message.set_name('CLN','M4U_DMD_REQUEST_FAILURE');
                        fnd_message.set_token('TYPE','Request for Catalogue Item Notification');
                        l_cln_msg       := fnd_message.get;


                ELSIF   l_doc_sts = m4u_dmd_utils.c_sts_error     THEN
                        l_create_flag   := false;
                        l_cln_doc_sts   := 'ERROR';
                        l_cln_pt        := 'B2B_SERVER';
                        l_cln_sts       := 'ERROR';
                        l_cln_disp      := 'FAILED';
                        fnd_message.set_name('CLN','M4U_DMD_REQUEST_ERROR');
                        fnd_message.set_token('TYPE','Request for Catalogue Item Notification');
                        l_cln_msg       := fnd_message.get;

                END IF;

        ELSIF l_doc_type =  m4u_dmd_utils.c_type_cis  THEN

                l_cln_doc_id    :=  l_doc_type || '.' ||l_doc_id;
                l_cln_ref_id    :=  l_doc_type || '.' ||l_doc_id;
                l_cln_type      :=  l_doc_type ;
                l_cln_doc_type  :=  l_doc_type;
                l_payload_dir   :=  nvl(l_payload_dir,m4u_dmd_utils.c_dir_out);
                l_cln_dtl_msg   :=  l_processing_msg;

                IF      l_doc_sts = m4u_dmd_utils.c_sts_ready  AND  l_retry_count = 0 THEN
                        l_create_flag   := true;
                        l_cln_pt        := 'APPS';
                        l_cln_doc_sts   := 'SUCCESS';
                        l_cln_sts       := 'INITIATED';
                        l_cln_disp      := 'PENDING';
                        fnd_message.set_name('CLN','M4U_DMD_REQUEST_INIT');
                        fnd_message.set_token('TYPE','Catalogue Item Subscription');
                        l_cln_msg       := fnd_message.get;

                ELSIF   l_doc_sts = m4u_dmd_utils.c_sts_ready  AND  l_retry_count > 0 THEN
                        l_create_flag   := false;
                        l_cln_pt        := 'APPS';
                        l_cln_doc_sts   := 'SUCCESS';
                        l_cln_sts       := 'INITIATED';
                        l_cln_disp      := 'PENDING';
                        fnd_message.set_name('CLN','M4U_DMD_REQUEST_RETRY');
                        fnd_message.set_token('TYPE','Catalogue Item Subscription');
                        l_cln_msg       := fnd_message.get;


                ELSIF   l_doc_sts = m4u_dmd_utils.c_sts_sent              THEN
                        l_create_flag   := false;
                        l_cln_pt        := 'APPS';
                        l_cln_sts       := 'STARTED';
                        l_cln_doc_sts   := 'SUCCESS';
                        l_cln_disp      := 'PENDING';
                        fnd_message.set_name('CLN','M4U_DMD_REQUEST_SENT');
                        fnd_message.set_token('TYPE','Catalogue Item Subscription');
                        l_cln_msg       := fnd_message.get;


                ELSIF   l_doc_sts = m4u_dmd_utils.c_sts_success THEN
                        l_create_flag   := false;
                        l_cln_pt        := 'B2B_SERVER';
                        l_cln_doc_sts   := 'SUCCESS';
                        l_cln_sts       := 'COMPLETED';
                        l_cln_disp      := 'SYNCH';
                        fnd_message.set_name('CLN','M4U_DMD_REQUEST_SUCCESS');
                        fnd_message.set_token('TYPE','Catalogue Item Subscription');
                        l_cln_msg       := fnd_message.get;


                ELSIF   l_doc_sts = m4u_dmd_utils.c_sts_fail    THEN
                        l_create_flag   := false;
                        l_cln_pt        := 'B2B_SERVER';
                        l_cln_doc_sts   := 'SUCCESS';
                        l_cln_sts       := 'COMPLETED';
                        l_cln_disp      := 'REJECTED';
                        fnd_message.set_name('CLN','M4U_DMD_REQUEST_FAILURE');
                        fnd_message.set_token('TYPE','Catalogue Item Subscription');
                        l_cln_msg       := fnd_message.get;


                ELSIF   l_doc_sts = m4u_dmd_utils.c_sts_error     THEN
                        l_create_flag   := false;
                        l_cln_doc_sts   := 'ERROR';
                        l_cln_pt        := 'B2B_SERVER';
                        l_cln_sts       := 'ERROR';
                        l_cln_disp      := 'FAILED';
                        fnd_message.set_name('CLN','M4U_DMD_REQUEST_ERROR');
                        fnd_message.set_token('TYPE','Catalogue Item Subscription');
                        l_cln_msg       := fnd_message.get;


                END IF;

        --TBD:cin ack case
        ELSIF   l_doc_type = m4u_dmd_utils.c_type_cin    THEN

                l_cln_doc_id    :=  l_doc_type || '.' ||l_doc_id;
                l_cln_ref_id    :=  l_doc_type || '.' ||l_doc_id;
                l_cln_type      :=  l_doc_type;
                l_cln_doc_type  :=  l_doc_type;
                l_cln_dtl_msg   :=  l_processing_msg;


                IF      l_doc_sts = m4u_dmd_utils.c_sts_ready  AND  l_retry_count = 0 THEN

                        l_create_flag   := true;
                        l_cln_pt        := 'B2B_SERVER';
                        l_cln_sts       := 'INITIATED';
                        l_cln_doc_sts   := 'SUCCESS';
                        l_cln_disp      := 'PENDING';
                        l_payload_dir   :=  m4u_dmd_utils.c_dir_in;
                        fnd_message.set_name('CLN','M4U_DMD_REQUEST_INIT');
                        fnd_message.set_token('TYPE','Catalogue Item Notification');
                        l_cln_msg       := fnd_message.get;

                ELSIF   l_doc_sts = m4u_dmd_utils.c_sts_ready  AND  l_retry_count > 0 THEN
                        l_create_flag   := false;
                        l_cln_pt        := 'B2B_SERVER';
                        l_cln_sts       := 'INITIATED';
                        l_cln_doc_sts   := 'SUCCESS';
                        l_cln_disp      := 'PENDING';
                        l_payload_dir   :=  m4u_dmd_utils.c_dir_in;
                        fnd_message.set_name('CLN','M4U_DMD_REQUEST_RETRY');
                        fnd_message.set_token('TYPE','Catalogue Item Notification');
                        l_cln_msg       := fnd_message.get;

                --CIN sent to plm
                ELSIF   l_doc_sts = m4u_dmd_utils.c_sts_sent
                AND     l_payload_type <> m4u_dmd_utils.c_type_cin_ack THEN
                        l_create_flag   := false;
                        l_cln_pt        := 'APPS';
                        l_cln_sts       := 'STARTED';
                        l_cln_doc_sts   := 'SUCCESS';
                        l_cln_disp      := 'PENDING';
                        l_payload_dir   :=  m4u_dmd_utils.c_dir_in;
                        fnd_message.set_name('CLN','M4U_DMD_REQUEST_SENT');
                        fnd_message.set_token('TYPE','Catalogue Item Notification');
                        l_cln_msg       := fnd_message.get;

                ELSIF   l_doc_sts = m4u_dmd_utils.c_sts_fail
                AND     l_payload_type <> m4u_dmd_utils.c_type_cin_ack THEN
                        l_create_flag   := false;
                        l_cln_pt        := 'APPS';
                        l_cln_sts       := 'ERROR';
                        l_cln_doc_sts   := 'ERROR';
                        l_cln_disp      := 'REJECTED';
                        l_payload_dir   :=  m4u_dmd_utils.c_dir_in;

                        fnd_message.set_name('CLN','M4U_DMD_REQUEST_FAILURE');
                        fnd_message.set_token('TYPE','Catalogue Item Notification');
                        l_cln_msg       := fnd_message.get;


                ELSIF   l_doc_sts = m4u_dmd_utils.c_sts_error
                AND     l_payload_type <> m4u_dmd_utils.c_type_cin_ack THEN
                        l_create_flag   := false;
                        l_cln_doc_sts   := 'ERROR';
                        l_cln_pt        := 'APPS';
                        l_cln_sts       := 'ERROR';
                        l_cln_disp      := 'FAILED';
                        l_payload_dir   :=  m4u_dmd_utils.c_dir_in;
                        fnd_message.set_name('CLN','M4U_DMD_REQUEST_ERROR');
                        fnd_message.set_token('TYPE','Catalogue Item Notification');
                        l_cln_msg       := fnd_message.get;
                -- CIN response sent
                ELSIF   l_doc_sts = m4u_dmd_utils.c_sts_sent
                AND     l_payload_type = m4u_dmd_utils.c_type_cin_ack THEN
                        l_create_flag   := false;
                        l_cln_pt        := 'B2B_SERVER';
                        l_cln_doc_sts   := 'SUCCESS';
                        l_cln_sts       := 'STARTED';
                        l_cln_disp      := 'PENDING';
                        l_payload_dir   :=  m4u_dmd_utils.c_dir_out;
                        fnd_message.set_name('CLN','M4U_DMD_REQUEST_SENT');
                        fnd_message.set_token('TYPE','Catalogue Item Notification Response');
                        l_cln_msg       := fnd_message.get;

                -- CIN response sent
                ELSIF   l_doc_sts = m4u_dmd_utils.c_sts_error
                AND     l_payload_type = m4u_dmd_utils.c_type_cin_ack THEN
                        l_create_flag   := false;
                        l_cln_doc_sts   := 'ERROR';
                        l_cln_pt        := 'B2B_SERVER';
                        l_cln_sts       := 'ERROR';
                        l_cln_disp      := 'FAILED';
                        l_payload_dir   :=  m4u_dmd_utils.c_dir_out;
                        fnd_message.set_name('CLN','M4U_DMD_REQUEST_ERROR');
                        fnd_message.set_token('TYPE','Catalogue Item Notification Response');
                        l_cln_msg       := fnd_message.get;

                -- CIN response sent
                ELSIF   l_doc_sts = m4u_dmd_utils.c_sts_fail
                AND     l_payload_type = m4u_dmd_utils.c_type_cin_ack THEN
                        l_create_flag   := false;
                        l_cln_doc_sts   := 'ERROR';
                        l_cln_pt        := 'B2B_SERVER';
                        l_cln_sts       := 'ERROR';
                        l_cln_disp      := 'FAILED';
                        l_payload_dir   :=  m4u_dmd_utils.c_dir_out;
                        fnd_message.set_name('CLN','M4U_DMD_REQUEST_ERROR');
                        fnd_message.set_token('TYPE','Catalogue Item Notification Response');
                        l_cln_msg       := fnd_message.get;


                END IF;


        ELSIF   l_doc_type = m4u_dmd_utils.c_type_cic    THEN

                l_create_flag   := false;
                l_cln_doc_id    :=  m4u_dmd_utils.c_type_cin || '.' || l_m4u_doc_rec.ref_doc_id;
                l_cln_type      :=  m4u_dmd_utils.c_type_cin;
                l_cln_ref_id    :=  m4u_dmd_utils.c_type_cin || '.' || l_m4u_doc_rec.ref_doc_id;

                l_cln_doc_type  :=  l_doc_type;
                l_payload_dir   :=  nvl(l_payload_dir,m4u_dmd_utils.c_dir_out);
                l_cln_dtl_msg   :=  l_processing_msg;

                IF l_m4u_doc_rec.parameter1 = 'ACCEPTED' THEN
                        l_cln_disp := 'ACCEPTED' ;
                ELSIF l_m4u_doc_rec.parameter1 = 'REJECTED' THEN
                        l_cln_disp := 'REJECTED' ;
                ELSIF l_m4u_doc_rec.parameter1 = 'SYNCHRONISED' THEN
                        l_cln_disp := 'SYNCH'    ;
                ELSIF l_m4u_doc_rec.parameter1 = 'REVIEW' THEN
                        l_cln_disp := 'CORRECTION' ;
                END IF;

                IF      l_doc_sts = m4u_dmd_utils.c_sts_ready  AND  l_retry_count = 0 THEN

                        l_cln_pt        := 'APPS';
                        l_cln_doc_sts   := 'SUCCESS';
                        l_cln_sts       := 'STARTED';
                        fnd_message.set_name('CLN','M4U_DMD_REQUEST_INIT');
                        fnd_message.set_token('TYPE','Catalogue Item Confirmation');
                        l_cln_msg       := fnd_message.get;

                ELSIF   l_doc_sts = m4u_dmd_utils.c_sts_ready  AND  l_retry_count > 0 THEN

                        l_cln_pt        := 'B2B_SERVER';
                        l_cln_doc_sts   := 'SUCCESS';
                        l_cln_sts       := 'STARTED';
                        fnd_message.set_name('CLN','M4U_DMD_REQUEST_RETRY');
                        fnd_message.set_token('TYPE','Catalogue Item Confirmation');
                        l_cln_msg       := fnd_message.get;


                ELSIF   l_doc_sts = m4u_dmd_utils.c_sts_sent              THEN

                        l_cln_pt        := 'B2B_SERVER';
                        l_cln_doc_sts   := 'SUCCESS';
                        l_cln_sts       := 'STARTED';
                        fnd_message.set_name('CLN','M4U_DMD_REQUEST_SENT');
                        fnd_message.set_token('TYPE','Catalogue Item Confirmation');
                        l_cln_msg       := fnd_message.get;


                ELSIF   l_doc_sts = m4u_dmd_utils.c_sts_success THEN

                        l_cln_pt        := 'B2B_SERVER';
                        l_cln_doc_sts   := 'SUCCESS';
                        l_cln_sts       := 'COMPLETED';
                        fnd_message.set_name('CLN','M4U_DMD_REQUEST_SUCCESS');
                        fnd_message.set_token('TYPE','Catalogue Item Confirmation');
                        l_cln_msg       := fnd_message.get;


                ELSIF   l_doc_sts = m4u_dmd_utils.c_sts_fail    THEN

                        l_cln_pt        := 'B2B_SERVER';
                        l_cln_sts       := 'ERROR';
                        l_cln_doc_sts   := 'ERROR';
                        fnd_message.set_name('CLN','M4U_DMD_REQUEST_FAILURE');
                        fnd_message.set_token('TYPE','Catalogue Item Confirmation');
                        l_cln_msg       := fnd_message.get;


                ELSIF   l_doc_sts = m4u_dmd_utils.c_sts_error     THEN

                        l_cln_doc_sts   := 'ERROR';
                        l_cln_pt        := 'B2B_SERVER';
                        l_cln_sts       := 'ERROR';
                        fnd_message.set_name('CLN','M4U_DMD_REQUEST_ERROR');
                        fnd_message.set_token('TYPE','Catalogue Item Confirmation');
                        l_cln_msg       := fnd_message.get;


                END IF;


        END IF;





        IF l_create_flag THEN

                m4u_dmd_utils.log('Call cln.create_collaboration',2);
                cln_ch_collaboration_pkg.create_collaboration
                (
                        x_return_status             => l_ret_sts,
                        x_msg_data                  => l_ret_msg,
                        p_app_id                    => m4u_dmd_utils.c_app_id,
                        p_ref_id                    => l_cln_ref_id,
                        p_org_id                    => fnd_global.org_id,
                        p_rel_no                    => null,
                        p_doc_no                    => l_cln_doc_id,
                        p_doc_rev_no                => null,
                        p_xmlg_transaction_type     => l_xmlg_type,
                        p_xmlg_transaction_subtype  => l_xmlg_styp,
                        p_xmlg_document_id          => l_xmlg_doc_id,
                        p_partner_doc_no            => null,
                        p_coll_type                 => l_cln_type,
                        p_tr_partner_type           => m4u_cln_pkg.c_party_type,
                        p_tr_partner_id             => m4u_cln_pkg.g_party_id,
                        p_tr_partner_site           => m4u_cln_pkg.g_party_site_id,
                        p_resend_flag               => 'N',
                        p_resend_count              => 0,
                        p_doc_owner                 => fnd_global.user_id,
                        p_init_date                 => sysdate,
                        p_doc_creation_date         => sysdate,
                        p_doc_revision_date         => null,
                        p_doc_type                  => l_cln_doc_type,
                        p_doc_dir                   => l_payload_dir,
                        p_coll_pt                   => l_cln_pt,
                        p_xmlg_msg_id               => null,
                        p_unique1                   => null,
                        p_unique2                   => null,
                        p_unique3                   => null,
                        p_unique4                   => null,
                        p_unique5                   => null,
                        p_sender_component          => null,
                        p_rosettanet_check_required => false,
                        p_xmlg_internal_control_number => null,
                        p_collaboration_standard    => c_xmlg_std,
                        p_attribute1                => l_m4u_doc_rec.msg_id,
                        p_attribute2                => l_m4u_doc_rec.doc_id,
                        p_attribute3                => l_m4u_doc_rec.ref_doc_id,
                        p_attribute4                => l_m4u_doc_rec.orig_doc_id,
                        p_attribute5                => l_m4u_doc_rec.type,
                        p_attribute6                => l_m4u_doc_rec.action,
                        p_attribute7                => l_m4u_doc_rec.top_gtin,
                        p_attribute8                => l_m4u_doc_rec.info_provider_gln,
                        p_attribute9                => l_m4u_doc_rec.data_recepient_gln,
                        p_attribute10               => l_m4u_doc_rec.target_market_country,
                        p_attribute11               => l_m4u_doc_rec.target_market_sub_div,
                        p_attribute12               => l_m4u_doc_rec.parameter1,
                        p_attribute13               => l_m4u_doc_rec.parameter2,
                        p_attribute14               => l_m4u_doc_rec.parameter3,
                        p_attribute15               => l_m4u_doc_rec.lparameter1,
                        p_dattribute1               => l_m4u_doc_rec.doc_timestamp,
                        x_coll_id                   => l_cln_id
                );
                m4u_dmd_utils.log('l_ret_sts    -|' || l_ret_sts   || '|',6);
                m4u_dmd_utils.log('l_ret_msg    -|' || l_ret_msg   || '|',6);
                m4u_dmd_utils.log('l_cln_id     -|' || l_cln_id    || '|',6);
        END IF;

        m4u_dmd_utils.log('Query collaboration_id',6);
        SELECT  collaboration_id
        INTO    l_cln_id
        FROM    cln_coll_hist_hdr
        WHERE       application_reference_id = l_cln_ref_id
                AND collaboration_type       = l_cln_type
                AND rownum < 2;
        m4u_dmd_utils.log('l_cln_id    -|' || l_cln_id   || '|',6);


        m4u_dmd_utils.log('Call cln.update_collaboration',6);
        cln_ch_collaboration_pkg.update_collaboration
        (
                x_return_status             => l_ret_sts,
                x_msg_data                  => l_ret_msg,
                p_coll_id                   => l_cln_id,
                p_app_id                    => m4u_dmd_utils.c_app_id,
                p_ref_id                    => l_cln_ref_id,
                p_rel_no                    => NULL,
                p_doc_no                    => l_cln_doc_id,
                p_doc_rev_no                => NULL,
                p_xmlg_transaction_type     => l_xmlg_type,
                p_xmlg_transaction_subtype  => l_xmlg_styp,
                p_xmlg_document_id          => l_xmlg_doc_id,
                p_resend_flag               => NULL,
                p_resend_count              => NULL,
                p_disposition               => l_cln_disp,
                p_coll_status               => l_cln_sts,
                p_doc_type                  => l_cln_doc_type,
                p_doc_dir                   => l_payload_dir,
                p_coll_pt                   => l_cln_pt,
                p_org_ref                   => NULL,
                p_doc_status                => l_cln_doc_sts,
                p_notification_id           => NULL,
                p_msg_text                  => l_cln_msg,
                p_tr_partner_type           => m4u_cln_pkg.c_party_type,
                p_tr_partner_id             => m4u_cln_pkg.g_party_id,
                p_tr_partner_site           => m4u_cln_pkg.g_party_site_id,
                p_sender_component          => NULL,
                p_rosettanet_check_required => false,
                p_xmlg_msg_id               => null,
                p_attribute1                => l_m4u_doc_rec.msg_id,
                p_attribute2                => l_m4u_doc_rec.doc_id,
                p_attribute3                => l_m4u_doc_rec.ref_doc_id,
                p_attribute4                => l_m4u_doc_rec.orig_doc_id,
                p_attribute5                => l_m4u_doc_rec.type,
                p_attribute6                => l_m4u_doc_rec.action,
                p_attribute7                => l_m4u_doc_rec.top_gtin,
                p_attribute8                => l_m4u_doc_rec.info_provider_gln,
                p_attribute9                => l_m4u_doc_rec.data_recepient_gln,
                p_attribute10               => l_m4u_doc_rec.target_market_country,
                p_attribute11               => l_m4u_doc_rec.target_market_sub_div,
                p_attribute12               => l_m4u_doc_rec.parameter1,
                p_attribute13               => l_m4u_doc_rec.parameter2,
                p_attribute14               => l_m4u_doc_rec.parameter3,
                p_attribute15               => l_m4u_doc_rec.lparameter1,
                p_dattribute1               => l_m4u_doc_rec.doc_timestamp,
                x_dtl_coll_id               => l_cln_dtl_id,
                p_xml_event_key             => null
        );
        m4u_dmd_utils.log('l_ret_sts    -|' || l_ret_sts   || '|',6);
        m4u_dmd_utils.log('l_ret_msg    -|' || l_ret_msg   || '|',6);
        m4u_dmd_utils.log('l_cln_dtl_id -|' || l_cln_dtl_id|| '|',6);


        IF l_cln_dtl_msg IS NOT NULL THEN
                -- add coll message
                m4u_dmd_utils.log('Call cln.add_collaboration_messages',6);
                cln_ch_collaboration_pkg.add_collaboration_messages
                (
                        x_return_status   => l_ret_sts,
                        x_msg_data        => l_ret_msg,
                        p_dtl_coll_id     => l_cln_dtl_id,
                        p_ref1            => NULL,
                        p_ref2            => NULL,
                        p_ref3            => NULL,
                        p_ref4            => NULL,
                        p_ref5            => NULL,
                        p_dtl_msg         => l_cln_dtl_msg
                );
                m4u_dmd_utils.log('l_ret_sts    -|' || l_ret_sts   || '|',6);
                m4u_dmd_utils.log('l_ret_msg    -|' || l_ret_msg   || '|',6);

        END IF;

        m4u_dmd_utils.log('l_ret_sts    -|' || l_ret_sts   || '|',6);
        m4u_dmd_utils.log('l_ret_msg    -|' || l_ret_msg   || '|',6);
        m4u_dmd_utils.log('Exiting m4u_cln_pkg.update_collab - Success' ,6);

        RETURN 'SUCCESS';

   EXCEPTION
        WHEN OTHERS THEN
                m4u_dmd_utils.log('m4u_cln_pkg.update_collab',6);
                m4u_dmd_utils.log('Unexpected error occured while processing',6);
                m4u_dmd_utils.log(SQLCODE || '-' || SQLERRM,6);
                RETURN 'SUCCESS';
   END update_collab;


----------------------------------------------------------------------------------------
        -- Name
        --      update_tp_detail
        -- Purpose
        --      This procedure sets up the XMLGateway Trading Partner Setup detail
        --      for a single transaction based on the params
        --      If detail record is present it updates else inserts
        PROCEDURE update_tp_detail
        (
                p_tp_hdr_id             IN              NUMBER,
                p_direction             IN              VARCHAR2,
                x_ret_sts               OUT NOCOPY      VARCHAR2,
                x_ret_msg               OUT NOCOPY      VARCHAR2
        )
        IS
                l_ret_msg       VARCHAR2(4000);
                l_ret_sts       VARCHAR2(10);
                l_record_found  BOOLEAN;

                l_party_type    VARCHAR2(30);
                l_standard_code VARCHAR2(30);

                l_ext_type      VARCHAR2(30);
                l_txn_type      VARCHAR2(30);
                l_doc_conf      VARCHAR2(30);
                l_map           VARCHAR2(30);

                l_ext_subtype   VARCHAR2(30);
                l_txn_subtype   VARCHAR2(30);
                l_conn_type     VARCHAR2(30);
                l_protocol      VARCHAR2(30);
                l_protocol_addr VARCHAR2(30);
                l_user          VARCHAR2(30);
                l_passwd        VARCHAR2(30);
                l_src_loc       VARCHAR2(30);
                l_progress      VARCHAR2(200);
                l_tp_dtl_id     NUMBER;
                l_ext_process_id NUMBER;
        BEGIN


                m4u_dmd_utils.log('Entering m4u_cln_pkg.add_or_update_tp_detail',2);
                m4u_dmd_utils.log('p_tp_hdr_id -|' || p_tp_hdr_id || '|',1);
                m4u_dmd_utils.log('p_direction -|' || p_direction || '|',1);


                --------------------------------------------------------------------------
                --Set ECX api input params
                l_ext_type      := m4u_cln_pkg.c_xmlg_type;
                l_standard_code := m4u_cln_pkg.c_xmlg_std;
                l_txn_type      := m4u_cln_pkg.c_xmlg_type;
                l_party_type    := m4u_cln_pkg.c_party_type;
                l_doc_conf      := '2';
                l_map           := 'm4u_230_cin_out';

                IF p_direction = m4u_dmd_utils.c_dir_out THEN
                --out specific values
                        l_src_loc       := 7777;
                        l_ext_subtype   := m4u_cln_pkg.c_xmlg_styp_out;
                        l_txn_subtype   := m4u_cln_pkg.c_xmlg_styp_out;
                        l_conn_type     := 'DIRECT';
                        l_protocol      := 'HTTP';
                        l_protocol_addr := 'http://none';
                        l_user          := 'operations';
                        l_passwd        := 'welcome';
                ELSE
                --in specific values
                        l_src_loc       := 7777;
                        l_ext_subtype   := m4u_cln_pkg.c_xmlg_styp_in;
                        l_txn_subtype   := m4u_cln_pkg.c_xmlg_styp_in;
                        l_conn_type     := null;
                        l_protocol      := null;
                        l_protocol_addr := null;
                        l_user          := null;
                        l_passwd        := null;
                END IF;
                --------------------------------------------------------------------------
                -- Query ecx_tp_detail_id
                m4u_dmd_utils.log('Query ecx_tp_detail_id',2);
                l_progress := 'Query ecx_tp_detail_id';

                BEGIN
                        SELECT tp_detail_id
                        INTO   l_tp_dtl_id
                        FROM
                                ecx_tp_details    tpd,
                                ecx_tp_headers    tph,
                                ecx_ext_processes extp,
                                ecx_transactions  txn,
                                ecx_standards     svl
                        WHERE   1=1
                                AND tph.tp_header_id            = tpd.tp_header_id
                                AND tpd.ext_process_id          = extp.ext_process_id
                                AND extp.transaction_id         = txn.transaction_id
                                AND extp.standard_id            = svl.standard_id
                                AND svl.standard_code           = l_standard_code
                                AND extp.ext_type               = l_ext_type
                                AND extp.ext_subtype            = l_ext_subtype
                                AND extp.direction              = p_direction
                                AND txn.transaction_type        = l_txn_type
                                AND txn.transaction_subtype     = l_txn_subtype
                                AND tph.tp_header_id            = p_tp_hdr_id;

                        l_record_found   := TRUE;
                        m4u_dmd_utils.log('l_tp_dtl_id -|' || l_tp_dtl_id || '|',1);

                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                                m4u_dmd_utils.log('No data found',1);
                                l_record_found   := FALSE;
                END;

                -------------------------------------------------------------------------
                --Query extp.ext_process_id
                m4u_dmd_utils.log('Query extp.ext_process_id',1);
                l_progress := 'Query ecx_tp_detail_id';


                SELECT  extp.ext_process_id
                INTO    l_ext_process_id
                FROM    ecx_ext_processes extp,
                        ecx_transactions  txn,
                        ecx_standards     svl
                WHERE   1=1
                        AND extp.transaction_id         = txn.transaction_id
                        AND extp.standard_id            = svl.standard_id
                        AND svl.standard_code           = l_standard_code
                        AND extp.ext_type               = l_ext_type
                        AND extp.ext_subtype            = l_ext_subtype
                        AND extp.direction              = p_direction
                        AND txn.party_type              = l_party_type
                        AND txn.transaction_type        = l_txn_type
                        AND txn.transaction_subtype     = l_txn_subtype;

                m4u_dmd_utils.log('l_ext_process_id -|' || l_ext_process_id || '|',1);
                -------------------------------------------------------------------------
                -- Create or update ECX tp detail
                IF NOT l_record_found THEN
                --Create
                        m4u_dmd_utils.log('Call ecx_tp_api.create_tp_detail',1);
                        l_progress := 'Call ecx_tp_api.create_tp_detail';

                        ecx_tp_api.create_tp_detail
                        (
                                x_return_status                 =>  l_ret_sts,
                                x_msg                           =>  l_ret_msg,
                                x_tp_detail_id                  =>  l_tp_dtl_id,
                                p_tp_header_id                  =>  p_tp_hdr_id,
                                p_ext_process_id                =>  l_ext_process_id,
                                p_map_code                      =>  l_map,
                                p_connection_type               =>  l_conn_type,
                                p_hub_user_id                   =>  null,
                                p_protocol_type                 =>  l_protocol,
                                p_protocol_address              =>  l_protocol_addr,
                                p_username                      =>  l_user,
                                p_password                      =>  l_passwd,
                                p_routing_id                    =>  null,
                                p_source_tp_location_code       =>  l_src_loc,
                                p_external_tp_location_code     =>  null,
                                p_confirmation                  =>  l_doc_conf
                        );

                        m4u_dmd_utils.log('l_ret_sts -|' || l_ret_sts || '|',1);
                        m4u_dmd_utils.log('l_ret_msg -|' || l_ret_msg || '|',1);



                        IF l_ret_sts <> '0' THEN
                             x_ret_sts := fnd_api.g_ret_sts_error;
                             x_ret_msg := l_ret_msg;
                             m4u_dmd_utils.log('Exiting add_or_update_tp_detail - Failure',6);
                             RETURN;
                        END IF;
                ELSE
                --Update
                        m4u_dmd_utils.log('Call ecx_tp_api.update_tp_detail',1);
                        l_progress := 'Call ecx_tp_api.update_tp_detail';

                        ecx_tp_api.update_tp_detail
                        (
                                x_return_status                 => l_ret_sts,
                                x_msg                           => l_ret_msg,
                                p_tp_detail_id                  => l_tp_dtl_id,
                                p_map_code                      => l_map,
                                p_ext_process_id                => l_ext_process_id,
                                p_connection_type               => l_conn_type,
                                p_hub_user_id                   => null,
                                p_protocol_type                 => l_protocol,
                                p_protocol_address              => l_protocol_addr,
                                p_username                      => l_user,
                                p_password                      => l_passwd,
                                p_routing_id                    => null,
                                p_source_tp_location_code       => l_src_loc,
                                p_external_tp_location_code     => null,
                                p_confirmation                  => l_doc_conf,
                                p_passupd_flag                  => 'Y'
                        );

                        m4u_dmd_utils.log('l_ret_sts -|' || l_ret_sts || '|',1);
                        m4u_dmd_utils.log('l_ret_msg -|' || l_ret_msg || '|',1);

                        IF l_ret_sts <> '0' THEN
                             x_ret_sts := fnd_api.g_ret_sts_error;
                             x_ret_msg := l_ret_msg;
                             m4u_dmd_utils.log('Exiting add_or_update_tp_detail - Failure',6);
                             RETURN;
                        END IF;
                END IF;
                -------------------------------------------------------------------------
                x_ret_sts := fnd_api.g_ret_sts_success;
                x_ret_msg := '';

                m4u_dmd_utils.log('Exiting add_or_update_tp_detail - Success',2);
                RETURN; /*success*/
        EXCEPTION
                WHEN OTHERS THEN
                        x_ret_sts := fnd_api.g_ret_sts_error;
                        x_ret_msg := l_progress || '-' || SQLCODE || '-' || SQLERRM;
        END update_tp_detail;

---------------------------------------------------------------------------------------------
        -- Name
        --      SETUP
        -- Purpose
        --      This procedure is called from a concurrent program(can be called from anywhere actually).
        --      This procedure does the setup required for m4u
        --              i)      Setup default TP location in HR_LOCATIONS
        --              ii)     Setup XMLGateway trading partner definition
        -- Arguments
        --      x_err_buf                       => API out result param for concurrent program calls
        --      x_retcode                       => API out result param for concurrent program calls
        -- Notes
        --      The concurrent program will be failed in case of any error
        PROCEDURE setup_cln
        (
                x_errbuf             OUT NOCOPY VARCHAR2,
                x_retcode            OUT NOCOPY NUMBER
        )
        IS
                l_location_code                 VARCHAR2(60);
                l_country                       VARCHAR2(60);
                l_style                         VARCHAR2(30);
                l_description                   VARCHAR2(240);
                l_addr_line_1                   VARCHAR2(240);

                l_ret_msg                       VARCHAR2(4000);
                l_err_msg                       VARCHAR2(4000);
                l_ret_sts                       VARCHAR2(5);
                l_progress                      VARCHAR2(100);

                l_location_id                   NUMBER;
                l_obj_ver_num                   NUMBER;
                l_tp_hdr_id                     NUMBER;

                l_record_found                  BOOLEAN;

        BEGIN

                m4u_dmd_utils.log('Entering m4u_dmd_utils.setup_cln',2);

                l_location_code := m4u_cln_pkg.c_party_site;
                l_description   := 'Dummy seeded location for M4U transactions';
                l_addr_line_1   := 'Princeton';
                l_style         := 'US_GLB';
                l_country       := 'US';
                -----------------------------------------------------------------------------
                -- Query HR Locations
                -- Check if record exists. Create Locations if it does not else Update Location value
                l_progress      := 'Query for hr_locations_all based on location_code';
                BEGIN
                        m4u_dmd_utils.log('Query hr_locations_all',1);
                        SELECT location_id, object_version_number
                        INTO   l_location_id, l_obj_ver_num
                        FROM   hr_locations_all
                        WHERE  location_code = l_location_code
                                AND ROWNUM < 2;
                        l_record_found   := TRUE;

                        m4u_dmd_utils.log('l_location_id  -|'||l_location_id || '|', 1);
                        m4u_dmd_utils.log('l_obj_ver_num  -|'||l_obj_ver_num || '|', 1);
                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                                m4u_dmd_utils.log('No data found', 1);
                               l_record_found   := FALSE;
                END;
                -----------------------------------------------------------------------------
                --HR location
                IF NOT l_record_found THEN
                --Create
                        m4u_dmd_utils.log('Call HR_LOCATION_API.create_location', 2);
                        l_progress      := 'Call to HR_LOCATION_API.create_location';

                        HR_LOCATION_API.create_location
                        (
                                     p_effective_date          => sysdate,
                                     p_language_code           => userenv('LANG'),
                                     p_location_code           => l_location_code,
                                     p_description             => l_description,
                                     p_address_line_1          => l_addr_line_1,
                                     p_country                 => l_country,
                                     p_style                   => l_style,
                                     p_location_id             => l_location_id,
                                     p_object_version_number   => l_obj_ver_num
                        );

                        m4u_dmd_utils.log('l_location_id -|'||l_location_id || '|', 1);
                        m4u_dmd_utils.log('l_obj_ver_num -|'||l_obj_ver_num || '|', 1);

                ELSE
                --Update
                        m4u_dmd_utils.log('Call HR_LOCATION_API.update_location', 2);
                        l_progress      := 'Call HR_LOCATION_API.update_location';

                        HR_LOCATION_API.update_location
                        (
                                p_effective_date          => sysdate,
                                p_language_code           => userenv('LANG'),
                                p_location_code           => l_location_code,
                                p_description             => l_description,
                                p_address_line_1          => l_addr_line_1,
                                p_country                 => l_country,
                                p_style                   => l_style,
                                p_location_id             => l_location_id,
                                p_object_version_number   => l_obj_ver_num
                        );

                        m4u_dmd_utils.log('l_location_id -|'||l_location_id || '|', 1);
                        m4u_dmd_utils.log('l_obj_ver_num -|'||l_obj_ver_num || '|', 1);
                END IF;

                -- reset the value for next phase
                l_record_found   := FALSE;
                -----------------------------------------------------------------------------
                --Query TP Header Id
                l_progress      := 'Query ecx_tp_headers : party_id - ' || l_location_id;
                -- Check if record exists. Create TP Header if it does not else Update value
                BEGIN
                        SELECT  tp_header_id
                        INTO    l_tp_hdr_id
                        FROM    ecx_tp_headers
                        WHERE       party_type          = 'I'
                                AND party_id            = l_location_id
                                AND party_site_id       = l_location_id;

                        l_record_found   := TRUE;
                        m4u_dmd_utils.log('l_tp_hdr_id    -'||l_tp_hdr_id || '|', 1);
                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                                m4u_dmd_utils.log('No data found', 1);
                               l_record_found   := FALSE;
                END;
                -----------------------------------------------------------------------------
                --ECX TP Header
                IF NOT l_record_found THEN
                --create
                        m4u_dmd_utils.log('Call ecx_tp_api.create_trading_partner', 2);
                        l_progress      := 'Call ecx_tp_api.create_trading_partner';

                        ecx_tp_api.create_trading_partner
                        (
                                x_return_status         => l_ret_sts,
                                x_msg                   => l_ret_msg,
                                x_tp_header_id          => l_tp_hdr_id,
                                p_party_type            => m4u_cln_pkg.c_party_type,
                                p_party_id              => l_location_id,
                                p_party_site_id         => l_location_id,
                                p_company_admin_email   => m4u_cln_pkg.c_tp_email
                        );

                        m4u_dmd_utils.log('l_ret_msg   -|'||l_ret_msg ||'|', 1);
                        m4u_dmd_utils.log('l_ret_sts   -|'||l_ret_sts ||'|', 1);
                        IF l_ret_sts <> '0' THEN
                             l_err_msg := l_ret_msg;
                             RAISE FND_API.G_EXC_ERROR;
                        END IF;


                ELSE
                --Update
                        m4u_dmd_utils.log('Call ecx_tp_api.update_trading_partner', 2);
                        l_progress      := 'Call ecx_tp_api.update_trading_partner';

                        ecx_tp_api.update_trading_partner
                        (
                                x_return_status         => l_ret_sts,
                                x_msg                   => l_ret_msg,
                                p_tp_header_id          => l_tp_hdr_id,
                                p_company_admin_email   => m4u_cln_pkg.c_tp_email
                        );

                        m4u_dmd_utils.log('l_ret_msg   -|'||l_ret_msg ||'|', 1);
                        m4u_dmd_utils.log('l_ret_sts   -|'||l_ret_sts ||'|', 1);
                        IF l_ret_sts <> '0' THEN
                             l_err_msg :=   l_ret_msg;
                             RAISE FND_API.G_EXC_ERROR;
                        END IF;
                END IF;
                -----------------------------------------------------------------------------
                --TP details

                --Out txn
                l_progress      := 'Call update_tp_detail - OUT';
                update_tp_detail(l_tp_hdr_id,m4u_dmd_utils.c_dir_out,l_ret_sts,l_ret_msg);
                IF l_ret_sts <> fnd_api.g_ret_sts_success  THEN
                        l_err_msg := l_ret_msg;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;
                --In txn
                l_progress      := 'Call update_tp_detail - IN';
                update_tp_detail(l_tp_hdr_id,m4u_dmd_utils.c_dir_in ,l_ret_sts,l_ret_msg);
                IF l_ret_sts <> fnd_api.g_ret_sts_success THEN
                        l_err_msg := l_ret_msg;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;
                -----------------------------------------------------------------------------
                --Done, return success
                x_retcode  := 0;
                x_errbuf   := '';
                m4u_dmd_utils.log('Exiting m4u_dmd_utils.setup_cln - SUCCESS',2);
                RETURN; /*sucess*/
        EXCEPTION
                WHEN OTHERS THEN
                        x_errbuf        := 'Unexpected error at: ' || l_progress || '-' || l_err_msg ;
                        IF l_err_msg IS NULL THEN
                                x_errbuf := x_errbuf || '-' || SQLCODE || '-' || SQLERRM;
                        END IF;
                        x_retcode       :=  2;
        END setup_cln;

---------------------------------------------------------------------------------------

    BEGIN
        /* Package initialization. */
        SELECT to_char(e.party_id), to_char(e.party_site_id)
        INTO   g_party_id,          g_party_site_id
        FROM   hr_locations_all h,
               ecx_tp_headers   e
        WHERE  h.location_id   = e.party_id
        AND    e.party_type    = m4u_cln_pkg.c_party_type
        AND    h.location_code = m4u_cln_pkg.c_party_site;

        g_init_success := TRUE;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
                --Indicate that package has NOT been properly initialized -
                -- g_party_id and g_party_site_id are not valid for XMLG and CLN usage.
        g_init_success := FALSE;

END m4u_cln_pkg;

/
