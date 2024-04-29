--------------------------------------------------------
--  DDL for Package Body ITG_WF_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ITG_WF_UTILS" AS
/* ARCS: $Header: itgwfutb.pls 120.3 2006/07/11 07:49:28 pvaddana noship $
 * CVS:  itgwfutb.pls,v 1.19 2003/05/29 22:22:44 klai Exp
 */
  l_debug_level        NUMBER := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));

  PROCEDURE create_outbound_collaboration(
        itemtype        IN         VARCHAR2,
        itemkey         IN         VARCHAR2,
        actid           IN         NUMBER,
        funcmode        IN         VARCHAR2,
        resultout       OUT NOCOPY VARCHAR2
  ) IS
        l_org_id                   NUMBER;
        l_coll_id                  NUMBER;

        l_return_status            VARCHAR2(1);
        l_doc_id                   VARCHAR2(20);
        l_rel_num                  VARCHAR2(100);
        l_doc_num                  VARCHAR2(100);
        l_xact_type                VARCHAR2(100);
        l_xact_subtype             VARCHAR2(100);
        l_cln_type                 VARCHAR2(100);
        l_doc_type                 VARCHAR2(100);
        l_xml_event_key            VARCHAR2(100);
        l_buff                     VARCHAR2(2000);
  BEGIN
        IF (l_Debug_Level <= 2) THEN
              itg_debug_pub.Add('--- Entering create_outbound_collaboration ---' ,2);
        END IF;

        IF funcmode = 'RUN' THEN
                IF NOT itg_x_utils.g_initialized THEN
                        /* 4169685: REMOVE INSTALL DATA INSERTION FROM HR_LOCATIONS TABLE
                         * Missing Trading Partner setup and/or Connector uninitialized.
                         * Should never get here, since the workflow should not be activated.
                         */
                        resultout := 'ERROR';
                        RETURN;
                END IF;

                l_org_id       := wf_engine.GetActivityAttrText(itemtype, itemkey, actid, 'CLN_ORGANIZATION_ID');
                l_rel_num      := wf_engine.GetActivityAttrText(itemtype, itemkey, actid, 'CLN_REL_NUM');
                l_doc_num      := wf_engine.GetActivityAttrText(itemtype, itemkey, actid, 'CLN_DOC_NUM');
                l_xact_type    := wf_engine.GetActivityAttrText(itemtype, itemkey, actid, 'ECX_TRANSACTION_TYPE');
                l_xact_subtype := wf_engine.GetActivityAttrText(itemtype, itemkey, actid, 'ECX_TRANSACTION_SUBTYPE');
                l_doc_id       := wf_engine.GetActivityAttrText(itemtype, itemkey, actid, 'ECX_DOCUMENT_ID');
                l_cln_type     := wf_engine.GetActivityAttrText(itemtype, itemkey, actid, 'CLN_TYPE');
                l_doc_type     := wf_engine.GetActivityAttrText(itemtype, itemkey, actid, 'CLN_DOC_TYPE');
                l_xml_event_key     := wf_engine.GetActivityAttrText(itemtype, itemkey, actid, 'XML_EVENT_KEY');

                /* Refer to Bug no: 3896966, Collaborations need to be unique
                 * for Blanket Po Releases, Introduced XML_EVENT_KEY,
                 * XMLG_MESSAGE_ID in Workflow
                 */

               /*To fix Enhancement bug 5348827 for BPO Releases not being displayed on Collab history*/
                if l_rel_num is not null then
                   l_doc_num := l_doc_num||':'||l_rel_num;
                 end if;
                /* See CLNPOWFB.pls */
                CLN_CH_COLLABORATION_PKG.create_collaboration(
                        x_return_status             => l_return_status,
                        x_msg_data                  => l_buff,
                        p_app_id                    => itg_x_utils.c_application_id,
                        p_ref_id                    => NULL,
                        p_org_id                    => l_org_id,
                        p_rel_no                    => l_rel_num,
                        p_doc_no                    => l_doc_num,
                        p_doc_rev_no                => NULL,          /* NOTE: ??? */
                        p_xmlg_transaction_type     => l_xact_type,
                        p_xmlg_transaction_subtype  => l_xact_subtype,
                        p_xmlg_document_id          => l_doc_id,
                        p_partner_doc_no            => NULL,          /* NOTE: ??? */
                        p_coll_type                 => l_cln_type,
                        p_tr_partner_type           => itg_x_utils.c_party_type,
                        p_tr_partner_id             => itg_x_utils.g_party_id,
                        p_tr_partner_site           => itg_x_utils.g_party_site_id,
                        p_resend_flag               => 'N',
                        p_resend_count              => 0,
                        p_doc_owner                 => FND_GLOBAL.USER_ID,
                        p_init_date                 => SYSDATE,
                        p_doc_creation_date         => SYSDATE,  /* NOTE: value from record? */
                        p_doc_revision_date         => SYSDATE,
                        p_doc_type                  => l_doc_type,
                        p_doc_dir                   => 'OUT',
                        p_coll_pt                   => itg_x_utils.c_coll_pt,
                        p_xmlg_msg_id               => NULL,
                        p_unique1                   => null,
                        p_unique2                   => NULL,
                        p_unique3                   => NULL,
                        p_unique4                   => NULL,
                        p_unique5                   => NULL,
                        p_sender_component          => NULL,
                        p_rosettanet_check_required => FALSE,
                        x_coll_id                   => l_coll_id,
                        p_xml_event_key             => l_xml_event_key
                );

                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        resultout := 'ERROR';
                ELSE
                        wf_engine.SetItemAttrNumber(itemtype, itemkey, 'CLN_ID', l_coll_id);
                        resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;
                END IF;

                IF (l_Debug_Level <= 2) THEN
                      itg_debug_pub.Add('--- Exting create_outbound_collaboration ---' ,2);
                END IF;
                RETURN;
        END IF;
  EXCEPTION
        WHEN OTHERS THEN
                WF_CORE.CONTEXT('itg_wf_utils', 'create_outbound_collaboration',
                                itemtype, itemkey, to_char(actid), funcmode
                                );
                IF (l_Debug_Level <= 6) THEN
                      itg_debug_pub.Add('--- Exting create_outbound_collaboration : ERROR---' ,6);
                END IF;
                RAISE;
  END create_outbound_collaboration;


  PROCEDURE update_outbound_collaboration(
        itemtype        IN              VARCHAR2,
        itemkey         IN              VARCHAR2,
        actid           IN              NUMBER,
        funcmode        IN              VARCHAR2,
        resultout       OUT NOCOPY      VARCHAR2
  ) IS
        l_org_id                        NUMBER;
        l_coll_id                       NUMBER;
        l_collaboration_dtl_id          NUMBER;

        l_return_status                 VARCHAR2(1);
        l_buff                          VARCHAR2(2000);
        l_rel_num                       VARCHAR2(100);
        l_doc_num                       VARCHAR2(100);
        l_xact_type                     VARCHAR2(100);
        l_xact_subtype                  VARCHAR2(100);
        l_doc_id                        VARCHAR2(20);
        l_cln_type                      VARCHAR2(100);
        l_doc_type                      VARCHAR2(100);
        l_ref_id                        VARCHAR2(100);
        l_xml_event_key                 VARCHAR2(100);
        l_xmlg_msg_id                   VARCHAR2(100);

  BEGIN
        IF (l_Debug_Level <= 2) THEN
              itg_debug_pub.Add('--- Entering update_outbound_collaboration ---' ,2);
        END IF;

        IF funcmode = 'RUN' THEN
                IF NOT itg_x_utils.g_initialized THEN
                        /* 4169685: REMOVE INSTALL DATA INSERTION FROM HR_LOCATIONS TABLE
                         * Missing Trading Partner setup and/or Connector uninitialized.
                         * Should never get here, since the workflow should not be activated.
                         */
                        resultout := 'ERROR';
                        RETURN;
                END IF;

                l_cln_type      := wf_engine.GetActivityAttrText(itemtype, itemkey, actid, 'CLN_TYPE');
                l_doc_type      := wf_engine.GetActivityAttrText(itemtype, itemkey, actid, 'CLN_DOC_TYPE');
                l_coll_id       := wf_engine.GetActivityAttrText(itemtype, itemkey, actid, 'CLN_ID');
                -- using ECX_PARAMETER5 for referenceid.
                l_ref_id        := wf_engine.GetActivityAttrText(itemtype, itemkey, actid, 'ECX_PARAMETER5');
                l_xml_event_key := wf_engine.GetActivityAttrText(itemtype, itemkey, actid, 'XML_EVENT_KEY');
                l_xmlg_msg_id   := wf_engine.GetActivityAttrText(itemtype, itemkey, actid, 'XMLG_MESSAGE_ID');

                /* Refer to Bug no: 3896966, Collaborations need to be unique
                 * for Blanket Po Releases, Introduced XML_EVENT_KEY,
                 * XMLG_MESSAGE_ID in Workflow
                 */

                CLN_CH_COLLABORATION_PKG.UPDATE_COLLABORATION(
                        x_return_status             => l_return_status,
                        x_msg_data                  => l_buff,
                        p_coll_id                   => l_coll_id,
                        /* Returned from previous call */
                        p_app_id                    => itg_x_utils.c_application_id,
                        p_ref_id                    => l_ref_id,
                        /* The value of <CONTROLAREA>.<SENDER>.<REFERENCEID> ? */
                        p_rel_no                    => NULL,
                        p_doc_no                    => NULL,
                        p_doc_rev_no                => NULL,
                        p_xmlg_transaction_type     => NULL,
                        p_xmlg_transaction_subtype  => NULL,
                        p_xmlg_document_id          => NULL,
                        p_resend_flag               => NULL,
                        p_resend_count              => NULL,
                        p_disposition               => NULL,
                        p_coll_status               => 'COMPLETED',
                        p_doc_type                  => l_doc_type,
                        p_doc_dir                   => 'OUT',
                        p_coll_pt                   => itg_x_utils.c_xmlg_coll_pt,
                        p_org_ref                   => NULL,
                        p_doc_status                => 'SUCCESS',
                        p_notification_id           => NULL,
                        p_msg_text                  => 'Document successfully sent',
                        p_tr_partner_type           => itg_x_utils.c_party_type,
                        p_tr_partner_id             => itg_x_utils.g_party_id,
                        p_tr_partner_site           => itg_x_utils.g_party_site_id,
                        p_sender_component          => NULL,
                        p_rosettanet_check_required => FALSE,
                        p_xmlg_msg_id               => l_xmlg_msg_id,
                        x_dtl_coll_id               => l_collaboration_dtl_id,
                        p_xml_event_key             => l_xml_event_key
                );

                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        resultout := 'ERROR';
                ELSE
                        resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;
                END IF;

                IF (l_Debug_Level <= 2) THEN
                      itg_debug_pub.Add('--- Exting update_outbound_collaboration ---' ,2);
                END IF;
                RETURN;
        END IF;
  EXCEPTION
        WHEN OTHERS THEN
                WF_CORE.CONTEXT('itg_wf_utils', 'update_outbound_collaboration',
                      itemtype, itemkey, to_char(actid), funcmode);

                IF (l_Debug_Level <= 6) THEN
                      itg_debug_pub.Add('--- Exting update_outbound_collaboration :ERROR---' ,6);
                END IF;

                RAISE;
  END update_outbound_collaboration;




  PROCEDURE update_outbound_collab_cbod(
        itemtype  IN            VARCHAR2,
        itemkey   IN            VARCHAR2,
        actid     IN            NUMBER,
        funcmode  IN            VARCHAR2,
        resultout OUT NOCOPY    VARCHAR2
  ) IS
        l_org_id                NUMBER;
        l_coll_id               NUMBER;
        l_collaboration_dtl_id  NUMBER;

        l_rel_num               VARCHAR2(100);
        l_doc_num               VARCHAR2(100);
        l_xact_type             VARCHAR2(100);
        l_xact_subtype          VARCHAR2(100);
        l_doc_id                VARCHAR2(20);
        l_cln_type              VARCHAR2(100);
        l_doc_type              VARCHAR2(100);
        l_xmlg_msg_id           VARCHAR2(100);
        l_statuslvl             VARCHAR2(50);
        l_msg_text              VARCHAR2(50);
        l_coll_status           VARCHAR2(50);
        l_lang                  VARCHAR2(50);
        l_nls_lang              VARCHAR2(50);
        l_return_status         VARCHAR2(1);
        l_buff                  VARCHAR2(2000);
  BEGIN
        IF (l_Debug_Level <= 2) THEN
              itg_debug_pub.Add('--- Entering update_outbound_collab_cbod ---' ,2);
        END IF;

        IF funcmode = 'RUN' THEN
                l_lang  := wf_engine.GetItemAttrText(itemtype,itemkey,'SESSION_LANGUAGE',TRUE);

                IF l_lang IS NOT NULL THEN
                        BEGIN
                                select nls_language
                                into     l_nls_lang
                                from fnd_languages
                                where language_code = l_lang;

                                IF (l_Debug_Level <= 1) THEN
                                        itg_debug_pub.Add('NLS langauage '||l_nls_lang ,1);
                                END IF;

                                FND_GLOBAL.set_nls_context(p_nls_language => l_nls_lang);

                                IF (l_Debug_Level <= 1) THEN
                                        itg_debug_pub.Add('NLS context is switched' ,1);
                                END IF;
                        EXCEPTION
                                WHEN OTHERS THEN
                                        IF (l_Debug_Level <= 5) THEN
                                                itg_debug_pub.Add('Error changing session language to '|| l_lang ,5);
                                                itg_debug_pub.Add(SQLCODE || ' - ' ||  SQLERRM ,5);
                                        END IF;
                        END;
                END IF;

                IF NOT itg_x_utils.g_initialized THEN
                        /* 4169685: REMOVE INSTALL DATA INSERTION FROM HR_LOCATIONS TABLE
                         * Missing Trading Partner setup and/or Connector uninitialized.
                         * Should never get here, since the workflow should not be activated.
                         */
                        resultout := 'ERROR';
                        RETURN;
                END IF;

                -- The CLN Collaboration history should complete/error when
                -- there is a failure in the collaboration.
                -- The success/failure of collaboration can be checked from
                -- the STATUSLVL item-attribute

                l_cln_type     := wf_engine.GetActivityAttrText(itemtype, itemkey, actid, 'CLN_TYPE');
                l_doc_type     := wf_engine.GetActivityAttrText(itemtype, itemkey, actid, 'CLN_DOC_TYPE');
                l_xmlg_msg_id  := wf_engine.GetActivityAttrText(itemtype, itemkey, actid, 'XMLG_MESSAGE_ID');

                l_coll_id      := wf_engine.GetItemAttrText(itemtype, itemkey,  'PARAMETER10');
                l_statuslvl    := wf_engine.GetItemAttrText(itemtype, itemkey, 'PARAMETER6');

                IF l_statuslvl = '00' THEN
                        l_coll_status   := 'COMPLETED';
                ELSE
                        l_coll_status   := 'ERROR';
                END IF;

                /* Refer to Bug no: 3902644, 'CBOD' Payload Collaborations not created.
                 * Using the XMLG_MESSAGE_ID introduced in ITGSTD Workflow.
                 */

                CLN_CH_COLLABORATION_PKG.UPDATE_COLLABORATION(
                        x_return_status             => l_return_status,
                        x_msg_data                  => l_buff,
                        p_coll_id                   => l_coll_id,
                        /* Returned from previous call */
                        p_app_id                    => itg_x_utils.c_application_id,
                        p_ref_id                    => NULL,
                        p_rel_no                    => NULL,
                        p_doc_no                    => NULL,
                        p_doc_rev_no                => NULL,
                        p_xmlg_transaction_type     => NULL,
                        p_xmlg_transaction_subtype  => NULL,
                        p_xmlg_document_id          => NULL,
                        p_resend_flag               => NULL,
                        p_resend_count              => NULL,
                        p_disposition               => NULL,
                        p_coll_status               => l_coll_status, /*'COMPLETED',*/
                        p_doc_type                  => l_doc_type,
                        p_doc_dir                   => 'OUT',
                        p_coll_pt                   => itg_x_utils.c_xmlg_coll_pt,
                        p_org_ref                   => NULL,
                        p_doc_status                => 'SUCCESS',
                        p_notification_id           => NULL,
                        p_msg_text                  => 'Document successfully sent',
                        p_tr_partner_type           => itg_x_utils.c_party_type,
                        p_tr_partner_id             => itg_x_utils.g_party_id,
                        p_tr_partner_site           => itg_x_utils.g_party_site_id,
                        p_sender_component          => NULL,
                        p_rosettanet_check_required => FALSE,
                        p_xmlg_msg_id               => l_xmlg_msg_id,
                        x_dtl_coll_id               => l_collaboration_dtl_id
                );

                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        resultout := 'ERROR';
                ELSE
                        resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;
                END IF;

                IF (l_Debug_Level <= 2) THEN
                        itg_debug_pub.Add('--- Exiting update_outbound_collab_cbod ---' ,2);
                END IF;
                RETURN;
        END IF;
  EXCEPTION
        WHEN OTHERS THEN
                WF_CORE.CONTEXT('itg_wf_utils', 'update_outbound_collaboration cbod',
                      itemtype, itemkey, to_char(actid), funcmode);
                IF (l_Debug_Level <= 6) THEN
                      itg_debug_pub.Add('--- Exting update_outbound_collab_cbod :ERROR---' ,6);
                END IF;
                RAISE;
  END update_outbound_collab_cbod;



        --4335714
        --This procedure converts the CBOD description description error code
        --into a translated message in the language corresponding to the //language tag
        --corresponding to the inbound xgm
        --The langauage tag is passed in as parameter5 of the inbound xgm.
        --Also the currrent nls session is set to langauge value, to allow CBOD XML generation
        --to be done in the translated language.
  PROCEDURE set_cbod_description(
        itemtype                in varchar2,
        itemkey                 in varchar2,
        actid                   in number,
        funcmode                in varchar2,
        resultout               out nocopy varchar2)
  IS
        l_nls_language          varchar2(20);
        l_lang                  varchar2(20);
        l_error_code            varchar2(100);
        l_error_msg             varchar2(100);
        parameter7              varchar2(1000);
        parameter5              varchar2(1000);
        l_cbod_message          varchar2(2000);
  BEGIN
        IF (l_Debug_Level <= 2) THEN
              itg_debug_pub.Add('--- Entering update_set_cbod_description ---' ,2);
        END IF;

        parameter5 := wf_engine.GetItemAttrText(itemtype,itemkey,'PARAMETER5',TRUE);
        parameter7 := wf_engine.GetItemAttrText(itemtype,itemkey,'PARAMETER7',TRUE);

        IF (l_Debug_Level <= 1) THEN
                itg_debug_pub.Add('Parameter5 - ' || parameter5 ,1);
                itg_debug_pub.Add('Parameter7 - ' || parameter7 ,1);
        END IF;

        BEGIN
                SELECT NLS_LANGUAGE
                INTO l_nls_language
                FROM FND_LANGUAGES
                WHERE LANGUAGE_CODE = parameter5
                AND installed_flag in ('B','I') ;

                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('l_nls_language - ' || l_nls_language ,1);
                END IF;

                l_lang     := FND_GLOBAL.CURRENT_LANGUAGE;

                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('l_lang         - ' || l_lang ,1);
                END IF;

                FND_GLOBAL.set_nls_context(p_nls_language => l_nls_language);

                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('set_nls_context SET' ,1);
                END IF;

                wf_engine.SetItemAttrText(itemtype,itemkey,'SESSION_LANGUAGE',l_lang);

                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('SetItemAttrText - SESSION_LANGUAGE SET ');
                END IF;

        EXCEPTION
                WHEN OTHERS THEN
                        IF (l_Debug_Level <= 1) THEN
                                itg_debug_pub.Add('Exception lang - '|| parameter5 || SQLCODE || '-' ||SQLERRM, 1);
                        END IF;
                        null; -- if any error, continue to use current session langauge.
        END;

        l_cbod_message := itg_x_utils.translateCBODDescMsg(p_msg_list=> parameter7);

        IF (l_Debug_Level <= 1) THEN
                itg_debug_pub.Add('l_cbod_message' || l_cbod_message ,1);
        END IF;

        wf_engine.SetItemAttrText(itemtype,itemkey,'PARAMETER7',l_cbod_message);
        resultout := 'COMPLETED';

        IF (l_Debug_Level <= 2) THEN
              itg_debug_pub.Add('--- Exiting update_set_cbod_description ---' ,2);
        END IF;
  EXCEPTION
                WHEN OTHERS THEN
                        WF_CORE.CONTEXT('itg_wf_utils', 'set_cbod_description',
                      itemtype, itemkey, to_char(actid), funcmode);
                        IF (l_Debug_Level <= 6) THEN
                              itg_debug_pub.Add('--- Exting set_cbod_description :ERROR---' ,6);
                        END IF;

                        RAISE;
                END;
  END itg_wf_utils;

/
