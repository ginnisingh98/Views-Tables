--------------------------------------------------------
--  DDL for Package Body CLN_RESEND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CLN_RESEND" AS
/* $Header: ECXRSNDB.pls 120.0 2006/06/05 07:20:24 susaha noship $ */
   l_debug_level        NUMBER;

    -- Name
    --   RESEND_DOC
    -- Purpose
    --   This procedure is called when resend button is clicked in the Collaboration HIstory
    --   Forms.The main purpose is to resend the document from XML gateway.
    -- Arguments
    --
    -- Notes
    --   No specific notes.
   PROCEDURE RESEND_DOC(
         p_collaboration_id             IN  NUMBER )
    IS
        l_error_code                    NUMBER;
        l_resend_count                  NUMBER;
        l_dtl_coll_id                   NUMBER;
        l_coll_dtl_id                   NUMBER;
        l_return_status                 VARCHAR2(255);
        l_error_msg                     VARCHAR2(255);
        l_msg_data                      VARCHAR2(255);
        l_debug_mode                    VARCHAR2(255);
        l_xmlg_transaction_type         VARCHAR2(100);
        l_xmlg_transaction_subtype      VARCHAR2(100);
        l_xmlg_doc_id                   VARCHAR2(255);
        l_xmlg_msgid                    VARCHAR2(255);
        l_trading_partner               VARCHAR2(30);
        l_trading_partner_type          VARCHAR2(10);
        l_trading_partner_site          VARCHAR2(30);
        l_collaboration_doc_type        VARCHAR2(100);
        l_xml_event_key                 VARCHAR2(255);
        NO_OUT_BOUND_DOCUMENT EXCEPTION;
    BEGIN
        -- Sets the debug mode to be FILE
        --l_debug_mode :=cln_debug_pub.Set_Debug_Mode('FILE');
        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('------ Entering RESEND_DOC API --------- ',2);
        END IF;
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Collaboration ID received -'||p_collaboration_id,1);
        END IF;
         -- Initialize API return status to success
        l_msg_data      := 'Requested Document successfully sent';
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Before Sql Query - cln_coll_hist_hdr',1);
        END IF;
        BEGIN
           SELECT resend_count
           INTO l_resend_count
           FROM cln_coll_hist_hdr
           WHERE collaboration_id = p_collaboration_id;
           IF (l_Debug_Level <= 1) THEN
                   cln_debug_pub.Add('After Sql Query - cln_coll_hist_hdr',1);
                   cln_debug_pub.Add('Resend Count                 -'||l_resend_count,1);
                   cln_debug_pub.Add('Before Sql Query - cln_coll_hist_dtl',1);
        END IF;
        EXCEPTION
           WHEN OTHERS THEN
              l_error_code    :=SQLCODE;
              l_error_msg     :=SQLERRM;
              l_msg_data      :=l_error_code||' : '||l_error_msg;
              -- Notifiy Administrator about the error
              IF (l_Debug_Level <= 5) THEN
                 cln_debug_pub.Add(l_msg_data,6);
                 cln_debug_pub.Add('-------- Exiting RESEND_DOC API ------------- ',2);
                 RAISE NO_OUT_BOUND_DOCUMENT;
              END IF;
              RETURN;
        END;
        BEGIN
           -- query modified by Rahul on 21Nov;2002.
           SELECT COLLABORATION_DOCUMENT_TYPE, XMLG_MSG_ID, collaboration_dtl_id,
                  XMLG_TRANSACTION_TYPE, XMLG_TRANSACTION_SUBTYPE, XMLG_DOCUMENT_ID, XML_EVENT_KEY
           INTO l_collaboration_doc_type,l_xmlg_msgid, l_coll_dtl_id,
                l_xmlg_transaction_type, l_xmlg_transaction_subtype, l_xmlg_doc_id, l_xml_event_key
           FROM CLN_COLL_HIST_DTL
           WHERE
           collaboration_dtl_id = (SELECT MAX(collaboration_dtl_id) FROM CLN_COLL_HIST_DTL
                                WHERE DOCUMENT_DIRECTION = 'OUT'
                                AND (XMLG_MSG_ID IS NOT NULL
                                     OR (DOCUMENT_DIRECTION IS NOT NULL AND
                                         XMLG_TRANSACTION_TYPE IS NOT NULL AND
                                         XMLG_TRANSACTION_SUBTYPE IS NOT NULL AND
                                         XMLG_DOCUMENT_ID IS NOT NULL)
                                         )
                                AND COLLABORATION_ID = p_collaboration_id
                                AND COLLABORATION_DOCUMENT_TYPE <> 'CONFIRM_BOD');
        EXCEPTION
           WHEN OTHERS THEN
              l_error_code    :=SQLCODE;
              l_error_msg     :=SQLERRM;
              l_msg_data      :=l_error_code||' : '||l_error_msg;
              -- Notifiy Administrator about the error
              IF (l_Debug_Level <= 5) THEN
                 cln_debug_pub.Add(l_msg_data,6);
                 cln_debug_pub.Add('-------- Exiting RESEND_DOC API ------------- ',2);
                 RAISE NO_OUT_BOUND_DOCUMENT;
              END IF;
              RETURN;
        END;
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('After Sql Query - cln_coll_hist_dtl',1);
                cln_debug_pub.Add('--------- Parameters Obtained ----------------',1);
                cln_debug_pub.Add('XMLG TRANSACTION TYPE        -'||l_xmlg_transaction_type,1);
                cln_debug_pub.Add('XMLG TRANSACTION SUB TYPE    -'||l_xmlg_transaction_subtype,1);
                cln_debug_pub.Add('XMLG DOCUMENT ID             -'||l_xmlg_doc_id,1);
                cln_debug_pub.Add('XMLG EVENT KEY               -'||l_xml_event_key,1);
                cln_debug_pub.Add('MSG ID                       -'||l_xmlg_msgid,1);
                cln_debug_pub.Add('Collaboration Dtl ID         -'||l_coll_dtl_id,1);
                cln_debug_pub.Add('----------------------------------------------',1);
        END IF;
        IF l_xmlg_msgid IS NULL THEN
           IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('About to query xml message id ',2);
           END IF;
           BEGIN
              SELECT MSGID
              INTO   l_xmlg_msgid
              FROM   ECX_DOCLOGS dlogs
              WHERE  dlogs.TRANSACTION_TYPE = l_xmlg_transaction_type AND
                     dlogs.TRANSACTION_SUBTYPE = l_xmlg_transaction_subtype AND
                     dlogs.DIRECTION = 'OUT' AND
                     dlogs.DOCUMENT_NUMBER = l_xmlg_doc_id AND
                     (event_key is null OR l_xml_event_key is null OR event_key = l_xml_event_key);
           EXCEPTION
              WHEN OTHERS THEN
                 l_error_code    :=SQLCODE;
                 l_error_msg     :=SQLERRM;
                 l_msg_data      :=l_error_code||' : '||l_error_msg;
                 IF (l_Debug_Level <= 5) THEN
                    cln_debug_pub.Add(l_msg_data,6);
                    cln_debug_pub.Add('-------- Exiting RESEND_DOC API ------------- ',2);
                    RAISE NO_OUT_BOUND_DOCUMENT;
                 END IF;
                 RETURN;
           END;
        END IF;
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('About to call ECX_DOCUMENT.RESEND',2);
        END IF;
        BEGIN
           ECX_DOCUMENT.RESEND(l_xmlg_msgid, l_error_code, l_error_msg);
        EXCEPTION
           WHEN OTHERS THEN
              l_error_code    :=SQLCODE;
              l_error_msg     :=SQLERRM;
              l_msg_data      :=l_error_code||' : '||l_error_msg;
              -- Notifiy Administrator about the error
              IF (l_Debug_Level <= 5) THEN
                 cln_debug_pub.Add(l_msg_data,6);
                 cln_debug_pub.Add('-------- Exiting RESEND_DOC API ------------- ',2);
                 RAISE NO_OUT_BOUND_DOCUMENT;
              END IF;
              RETURN;
        END;
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Error Code  returned by ECX_DOCUMENT.RESEND -'||l_error_code,1);
                cln_debug_pub.Add('Error Msg   returned by ECX_DOCUMENT.RESEND -'||l_error_msg,1);
        END IF;
        IF (l_error_code = 0) THEN
             l_resend_count := nvl(l_resend_count,0)+1;
             IF (l_Debug_Level <= 1) THEN
                     cln_debug_pub.Add('----- Before calling Update Collaboration -------',1);
             END IF;
             CLN_CH_COLLABORATION_PKG.UPDATE_COLLABORATION(
                   x_return_status                => l_return_status,
                   x_msg_data                     => l_msg_data,
                   p_coll_id                      => p_collaboration_id,
                   p_app_id                       => NULL,
                   p_ref_id                       => NULL,
                   p_rel_no                       => NULL,
                   p_doc_no                       => NULL,
                   p_doc_rev_no                   => NULL,
                   p_xmlg_transaction_type        => NULL,
                   p_xmlg_transaction_subtype     => NULL,
                   p_xmlg_document_id             => NULL,
                   p_resend_flag                  => 'Y',
                   p_resend_count                 => l_resend_count,
                   p_disposition                  => NULL,
                   p_coll_status                  => 'RESENT',
                   p_doc_type                     => l_collaboration_doc_type,
                   p_doc_dir                      => NULL,
                   p_coll_pt                      => NULL,
                   p_org_ref                      => NULL,
                   p_doc_status                   => 'SUCCESS',
                   p_notification_id              => NULL,
                   p_msg_text                     => 'CLN_CH_RESEND_MSG',
                   p_bsr_verb                     => NULL,
                   p_bsr_noun                     => NULL,
                   p_bsr_rev                      => NULL,
                   p_sdr_logical_id               => NULL,
                   p_sdr_component                => NULL,
                   p_sdr_task                     => NULL,
                   p_sdr_refid                    => NULL,
                   p_sdr_confirmation             => NULL,
                   p_sdr_language                 => NULL,
                   p_sdr_codepage                 => NULL,
                   p_sdr_authid                   => NULL,
                   p_sdr_datetime_qualifier       => NULL,
                   p_sdr_datetime                 => NULL,
                   p_sdr_timezone                 => NULL,
                   p_attr1                        => NULL,
                   p_attr2                        => NULL,
                   p_attr3                        => NULL,
                   p_attr4                        => NULL,
                   p_attr5                        => NULL,
                   p_attr6                        => NULL,
                   p_attr7                        => NULL,
                   p_attr8                        => NULL,
                   p_attr9                        => NULL,
                   p_attr10                       => NULL,
                   p_attr11                       => NULL,
                   p_attr12                       => NULL,
                   p_attr13                       => NULL,
                   p_attr14                       => NULL,
                   p_attr15                       => NULL,
                   p_xmlg_msg_id                  => l_xmlg_msgid ,
                   p_unique1                      => NULL,
                   p_unique2                      => NULL,
                   p_unique3                      => NULL,
                   p_unique4                      => NULL,
                   p_unique5                      => NULL,
                   p_tr_partner_type              => NULL,
                   p_tr_partner_id                => NULL,
                   p_tr_partner_site              => NULL,
                   p_sender_component             => NULL,
                   p_rosettanet_check_required    => NULL,
                   x_dtl_coll_id                  => l_dtl_coll_id
               );
               IF (l_Debug_Level <= 1) THEN
                       cln_debug_pub.Add('COLLABORATION_DETAIL_ID got as  ----'||l_dtl_coll_id, 1);
                       cln_debug_pub.Add('RETURN_STATUS got as            ----'||l_return_status, 1);
                       cln_debug_pub.Add('MESSAGE_DATA got as             ----'||l_msg_data, 1);
               END IF;
        END IF;
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add(l_msg_data,1);
        END IF;
        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('-------- Exiting RESEND_DOC API ------------- ',2);
        END IF;
        -- Exception Handling
        EXCEPTION
                WHEN FND_API.G_EXC_ERROR THEN
                   l_error_code    :=SQLCODE;
                   l_error_msg     :=SQLERRM;
                   l_msg_data      :=l_error_code||' : '||l_error_msg;
                   IF (l_Debug_Level <= 5) THEN
                           cln_debug_pub.Add(l_msg_data,4);
                           cln_debug_pub.Add('-------- Exiting RESEND_DOC API ------------- ',2);
                   END IF;
                   RAISE FND_API.G_EXC_ERROR ;
  END RESEND_DOC;


 BEGIN
   l_debug_level := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));

END CLN_RESEND;


/
