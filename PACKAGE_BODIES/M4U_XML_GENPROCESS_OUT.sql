--------------------------------------------------------
--  DDL for Package Body M4U_XML_GENPROCESS_OUT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."M4U_XML_GENPROCESS_OUT" AS
/* $Header: M4UOUTWB.pls 120.3 2006/05/11 21:39:56 bsaratna noship $ */

        G_PKG_NAME CONSTANT     VARCHAR2(30)    := 'm4u_xml_genprocess_out';
        l_debug_level           NUMBER;


        -- Name
        --      create_collab_setattr
        -- Purpose
        --
        -- Arguments
        --      itemtype                => WF item type
        --      itemkey                 => WF item key
        --      actid                   => WF act id
        --      funcmode                => WF func mode
        --      resultout               => result param
        -- Notes
        --      None.
        PROCEDURE create_collab_setattr(
                itemtype                          IN VARCHAR2,
                itemkey                           IN VARCHAR2,
                actid                             IN NUMBER,
                funcmode                          IN VARCHAR2,
                resultout                         IN OUT NOCOPY VARCHAR2
              )
        IS
                l_xmlg_transaction_type           VARCHAR2(100);
                l_xmlg_transaction_subtype        VARCHAR2(100);
                l_xmlg_document_id                VARCHAR2(100);
                l_coll_type                       VARCHAR2(100);
                l_doc_type                        VARCHAR2(100);
                l_owner_role                      VARCHAR2(100);

                l_fnd_msg                         VARCHAR2(255);
                l_error_msg                       VARCHAR2(255);
                l_debug_mode                      VARCHAR2(255);
                l_return_status                   VARCHAR2(255);
                l_doc_no                          VARCHAR2(255);
                l_partner_doc_no                  VARCHAR2(255);

                l_msg_data                        VARCHAR2(2000);
                l_create_msg_text                 VARCHAR2(2000);

                l_unique1                         VARCHAR2(30);
                l_unique2                         VARCHAR2(30);
                l_unique3                         VARCHAR2(30);
                l_unique4                         VARCHAR2(30);
                l_unique5                         VARCHAR2(30);
                l_truncated_key                   VARCHAR2(30);

                l_event_key                       VARCHAR2(50);

                l_ecx_parameter1                  VARCHAR2(150);
                l_ecx_parameter2                  VARCHAR2(150);
                l_ecx_parameter3                  VARCHAR2(150);
                l_ecx_parameter4                  VARCHAR2(150);
                l_ecx_parameter5                  VARCHAR2(150);

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
                l_coll_id                         NUMBER;
                l_doc_owner                       NUMBER;
                l_msg_count                       VARCHAR2(50);

                l_dattribute1                     DATE;
                l_dattribute2                     DATE;
                l_dattribute3                     DATE;
                l_dattribute4                     DATE;
                l_dattribute5                     DATE;

        BEGIN

                IF (l_debug_Level <= 2) THEN
                        cln_debug_pub.Add('========= Entering create_collab_setattr  == ',2);
                END IF;

                -- Parameters received
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('-- Parameters received from Workflow process -- ',1);
                        cln_debug_pub.Add('itemtype             - '||itemtype,  1);
                        cln_debug_pub.Add('itemkey              - '||itemkey,   1);
                        cln_debug_pub.Add('actid                - '||actid,     1);
                        cln_debug_pub.Add('funcmode             - '||funcmode,  1);
                        cln_debug_pub.Add('---------------------------------------------',1);
                END IF;

                -- if funcmode is not null then exit
                IF (funcmode <> wf_engine.eng_run) THEN
                        resultout := wf_engine.eng_null;
                        IF (l_Debug_Level <= 2) THEN
                                cln_debug_pub.Add('M4U:====== Exiting create_collab_setattr - Normal : resultout - ' || resultout,2);
                        END IF;
                        RETURN;
                END IF;

                l_event_key                   :=  wf_engine.GetItemAttrText(itemtype, itemkey, 'ECX_EVENT_KEY',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ECX Event Key                   ----'||l_event_key,1);
                END IF;

                l_ecx_parameter1              :=  wf_engine.GetItemAttrText(itemtype, itemkey, 'ECX_PARAMETER1',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ECX Parameter1                  ----'||l_ecx_parameter1,1);
                END IF;

                l_ecx_parameter2              :=  wf_engine.GetItemAttrText(itemtype, itemkey, 'ECX_PARAMETER2',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ECX Parameter2                  ----'||l_ecx_parameter2,1);
                END IF;

                l_ecx_parameter3              :=  wf_engine.GetItemAttrText(itemtype, itemkey, 'ECX_PARAMETER3',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ECX Parameter3                  ----'||l_ecx_parameter3,1);
                END IF;

                l_ecx_parameter4              :=  wf_engine.GetItemAttrText(itemtype, itemkey, 'ECX_PARAMETER4',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ECX Parameter4                  ----'||l_ecx_parameter4,1);
                END IF;

                l_ecx_parameter5              :=  wf_engine.GetItemAttrText(itemtype, itemkey, 'ECX_PARAMETER5',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ECX Parameter5                  ----'||l_ecx_parameter5,1);
                END IF;

                l_xmlg_transaction_type       := wf_engine.GetItemAttrText(itemtype, itemkey, 'ECX_TRANSACTION_TYPE',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('XMLG Ext Transaction Type       ----'||l_xmlg_transaction_type, 1);
                END IF;

                l_xmlg_transaction_subtype    := wf_engine.GetItemAttrText(itemtype, itemkey, 'ECX_TRANSACTION_SUBTYPE',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('XMLG Ext Transaction Sub Type   ----'||l_xmlg_transaction_subtype, 1);
                END IF;

                l_coll_type                   :=  wf_engine.GetItemAttrText(itemtype, itemkey, 'M4U_CLN_COLL_TYPE',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('COLLABORATION TYPE              ----'||l_coll_type,1);
                END IF;

                l_doc_type                    :=  wf_engine.GetItemAttrText(itemtype, itemkey, 'M4U_CLN_DOC_TYPE',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('DOCUMENT TYPE                   ----'||l_doc_type,1);
                END IF;

                l_doc_owner                   :=  wf_engine.GetItemAttrText(itemtype, itemkey, 'M4U_DOC_OWNER',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('DOCUMENT OWNER                  ----'||l_doc_owner,1);
                END IF;

                l_doc_no                      :=  wf_engine.GetItemAttrText(itemtype, itemkey, 'M4U_DOC_NO',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('DOCUMENT NUMBER                 ----'||l_doc_no,1);
                END IF;

                l_xmlg_document_id            :=  wf_engine.GetItemAttrText(itemtype, itemkey, 'ECX_DOCUMENT_ID',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ECX DOCUMENT ID                 ----'||l_xmlg_document_id,1);
                END IF;

                l_partner_doc_no              :=  wf_engine.GetItemAttrText(itemtype, itemkey, 'M4U_PARTNER_DOC_NO',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('PARTNER DOCUMENT NUMBER         ----'||l_partner_doc_no,1);
                END IF;

                l_owner_role                  :=  wf_engine.GetItemAttrText(itemtype, itemkey, 'M4U_OWNER_ROLE',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('OWNER ROLE                      ----'||l_owner_role,1);
                END IF;

                l_create_msg_text             := wf_engine.GetItemAttrText(itemtype, itemkey, 'MESSAGE_TEXT',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Message Text                    ----'||l_create_msg_text, 1);
                END IF;

                l_attribute1                  := wf_engine.GetItemAttrText(itemtype, itemkey, 'ATTRIBUTE1',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ATTRIBUTE1                      ----'||l_attribute1, 1);
                END IF;

                l_attribute2                  := wf_engine.GetItemAttrText(itemtype, itemkey, 'ATTRIBUTE2',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ATTRIBUTE2                      ----'||l_attribute2, 1);
                END IF;

                l_attribute3                  := wf_engine.GetItemAttrText(itemtype, itemkey, 'ATTRIBUTE3',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ATTRIBUTE3                      ----'||l_attribute3, 1);
                END IF;

                l_attribute4                  := wf_engine.GetItemAttrText(itemtype, itemkey, 'ATTRIBUTE4',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ATTRIBUTE4                      ----'||l_attribute4, 1);
                END IF;

                l_attribute5                   := wf_engine.GetItemAttrText(itemtype, itemkey, 'ATTRIBUTE5',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ATTRIBUTE5                      ----'||l_attribute5, 1);
                END IF;

                l_attribute6                   := wf_engine.GetItemAttrText(itemtype, itemkey, 'ATTRIBUTE6',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ATTRIBUTE6                      ----'||l_attribute6, 1);
                END IF;

                l_attribute7                   := wf_engine.GetItemAttrText(itemtype, itemkey, 'ATTRIBUTE7',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ATTRIBUTE7                      ----'||l_attribute7, 1);
                END IF;

                l_attribute8                   := wf_engine.GetItemAttrText(itemtype, itemkey, 'ATTRIBUTE8',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ATTRIBUTE8                      ----'||l_attribute8, 1);
                END IF;

                l_attribute9                    := wf_engine.GetItemAttrText(itemtype, itemkey, 'ATTRIBUTE9',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ATTRIBUTE9                      ----'||l_attribute9, 1);
                END IF;

                l_attribute10            := wf_engine.GetItemAttrText(itemtype, itemkey, 'ATTRIBUTE10',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ATTRIBUTE10                      ----'||l_attribute10, 1);
                END IF;

                l_attribute11            := wf_engine.GetItemAttrText(itemtype, itemkey, 'ATTRIBUTE11',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ATTRIBUTE11                      ----'||l_attribute11, 1);
                END IF;

                l_attribute12            := wf_engine.GetItemAttrText(itemtype, itemkey, 'ATTRIBUTE12',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ATTRIBUTE12                      ----'||l_attribute12, 1);
                END IF;

                l_attribute13            := wf_engine.GetItemAttrText(itemtype, itemkey, 'ATTRIBUTE13',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ATTRIBUTE13                      ----'||l_attribute13, 1);
                END IF;

                l_attribute14            := wf_engine.GetItemAttrText(itemtype, itemkey, 'ATTRIBUTE14',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ATTRIBUTE14                      ----'||l_attribute14, 1);
                END IF;

                l_attribute15            := wf_engine.GetItemAttrText(itemtype, itemkey, 'ATTRIBUTE15',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ATTRIBUTE15                      ----'||l_attribute15, 1);
                END IF;

                l_dattribute1            := m4u_ucc_utils.CONVERT_TO_DATE(wf_engine.GetItemAttrText(itemtype, itemkey, 'DATTRIBUTE1',TRUE));
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('DATTRIBUTE1                      ----'||l_dattribute1, 1);
                END IF;

                l_dattribute2            := m4u_ucc_utils.CONVERT_TO_DATE(wf_engine.GetItemAttrText(itemtype, itemkey, 'DATTRIBUTE2',TRUE));
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('DATTRIBUTE2                      ----'||l_dattribute2, 1);
                END IF;

                l_dattribute3            := m4u_ucc_utils.CONVERT_TO_DATE(wf_engine.GetItemAttrText(itemtype, itemkey, 'DATTRIBUTE3',TRUE));
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('DATTRIBUTE3                      ----'||l_dattribute3, 1);
                END IF;

                l_dattribute4            := m4u_ucc_utils.CONVERT_TO_DATE(wf_engine.GetItemAttrText(itemtype, itemkey, 'DATTRIBUTE4',TRUE));
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('DATTRIBUTE4                      ----'||l_dattribute4, 1);
                END IF;

                l_dattribute5            := m4u_ucc_utils.CONVERT_TO_DATE(wf_engine.GetItemAttrText(itemtype, itemkey, 'DATTRIBUTE5',TRUE));
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('DATTRIBUTE5                      ----'||l_dattribute5, 1);
                END IF;

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('------------------------------------------', 1);
                END IF;



                -- set item-attributes of WF
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('-----  Set WF Item Attributes ----- ',1);
                END IF;

                wf_engine.setItemAttrtext(
                                        itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'ECX_PARTY_SITE_ID',
                                        avalue     => m4u_ucc_utils.g_party_site_id);

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add(' Item Attribute          - ECX_PARTY_SITE_ID set',1);
                END IF;

                wf_engine.setItemAttrtext(
                                        itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'ECX_PARTY_ID',
                                        avalue     => m4u_ucc_utils.g_party_id);

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add(' Item Attribute          - ECX_PARTY_ID set',1);
                END IF;

                wf_engine.setItemAttrtext(
                                        itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'ECX_PARTY_TYPE',
                                        avalue     => m4u_ucc_utils.c_party_type);

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add(' Item Attribute          -  ECX_PARTY_TYPE set',1);
                END IF;

                wf_engine.setItemAttrtext(
                                        itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'M4U_XML_VALIDATION_REQUIRED',
                                        avalue     => fnd_profile.value('M4U_XML_VALIDATION_REQUIRED'));

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add(' XML Validation Reqd     - ' || fnd_profile.value('M4U_XML_VALIDATION_REQUIRED'),1);
                        cln_debug_pub.Add('-----  ----------------------------- ----- ',1);
                END IF;

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('----- Before call to - cln_ch_collaboration_pkg.create_collaboration -----',1);
                END IF;

                cln_ch_collaboration_pkg.create_collaboration (
                                        x_return_status                 => l_return_status,
                                        x_msg_data                      => l_msg_data,
                                        p_app_id                        => m4u_ucc_utils.c_resp_appl_id,
                                        p_ref_id                        => NULL,
                                        p_org_id                        => m4u_ucc_utils.g_org_id,
                                        p_rel_no                        => NULL,
                                        p_doc_no                        => l_doc_no,
                                        p_doc_owner                     => l_doc_owner,
                                        p_xmlg_int_transaction_type     => NULL,
                                        p_xmlg_int_transaction_subtype  => NULL,
                                        p_xmlg_transaction_type         => l_xmlg_transaction_type,
                                        p_xmlg_transaction_subtype      => l_xmlg_transaction_subtype,
                                        p_xmlg_document_id              => l_xmlg_document_id,
                                        p_coll_type                     => l_coll_type,
                                        p_tr_partner_type               => m4u_ucc_utils.c_party_type,
                                        p_tr_partner_site               => m4u_ucc_utils.g_party_site_id,
                                        p_doc_creation_date             => sysdate,
                                        p_doc_revision_date             => sysdate,
                                        p_init_date                     => sysdate,
                                        p_doc_type                      => l_doc_type,
                                        p_doc_dir                       => 'OUT',
                                        p_coll_pt                       => 'APPS',
                                        p_xmlg_msg_id                   => NULL,
                                        p_unique1                       => l_unique1,
                                        p_unique2                       => l_unique2,
                                        p_unique3                       => l_unique3,
                                        p_unique4                       => l_unique4,
                                        p_unique5                       => l_unique5,
                                        p_rosettanet_check_required     => FALSE,
                                        x_coll_id                       => l_coll_id,
                                        p_msg_text                      => l_create_msg_text,
                                        p_xml_event_key                 => itemkey,
                                        p_attribute1                    => l_attribute1,
                                        p_attribute2                    => l_attribute2,
                                        p_attribute3                    => l_attribute3,
                                        p_attribute4                    => l_attribute4,
                                        p_attribute5                    => l_attribute5,
                                        p_attribute6                    => l_attribute6,
                                        p_attribute7                    => l_attribute7,
                                        p_attribute8                    => l_attribute8,
                                        p_attribute9                    => l_attribute9,
                                        p_attribute10                   => l_attribute10,
                                        p_attribute11                   => l_attribute11,
                                        p_attribute12                   => l_attribute12,
                                        p_attribute13                   => l_attribute13,
                                        p_attribute14                   => l_attribute14,
                                        p_attribute15                   => l_attribute15,
                                        p_partner_doc_no                => l_partner_doc_no,
                                        p_collaboration_standard        => 'UCCNET',
                                        p_owner_role                    => l_owner_role);

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.add('Create collaboration returned values',1);
                        cln_debug_pub.add('Collab_id            - ' || l_coll_id,1);
                        cln_debug_pub.add('x_return_status      - ' || l_return_status,1);
                        cln_debug_pub.add('x_msg_data           - ' || l_msg_data,1);
                END IF;


                IF l_return_status = 'S' THEN
                        resultout := wf_engine.eng_completed || ':SUCCESS';
                        l_truncated_key := SUBSTR(l_event_key,1,10);

                        IF (l_Debug_Level <= 1) THEN
                                cln_debug_pub.add('Truncated Key Value - '||l_truncated_key,1);
                        END IF;

                        IF (l_truncated_key = 'M4U_EGOEVT') THEN
                              ego_uccnet_events_pub.set_collaboration_id(
                                     p_api_version     => 1.0,
                                     p_batch_id        => l_ecx_parameter2 ,
                                     p_subbatch_id     => l_ecx_parameter4,
                                     p_top_gtin        => l_doc_no,
                                     p_cln_id          => l_coll_id,
                                     x_return_status   => l_return_status,
                                     x_msg_count       => l_msg_count,
                                     x_msg_data        => l_msg_data);

                              IF (l_Debug_Level <= 1) THEN
                                    cln_debug_pub.Add('ego_uccnet_events_pub.set_collaboration_id - ', 1);
                                    cln_debug_pub.Add('     l_return_status         - '|| l_return_status, 1);
                                    cln_debug_pub.Add('     l_msg_data              - '|| l_msg_data, 1);
                                    cln_debug_pub.Add('     l_msg_count             - '|| l_msg_count, 1);
                              END IF;
                        END IF;
                ELSE
                        resultout := wf_engine.eng_completed || ':FAIL';

                        FND_MESSAGE.SET_NAME('CLN','M4U_CREATE_COLL_FAILURE');
                        /* 'Create Collaboration Failed. Details are
                            Colllaboration type : COLLTYPE
                            Document type       : DOCTYPE
                            Event Key           : EVTKEY
                            Item Type           : ITMTYPE
                            Error Code          : ERRCODE
                            Failure Reason      : MSG
                        */

                        l_fnd_msg     := FND_MESSAGE.GET;
                        CLN_NP_PROCESSOR_PKG.NOTIFY_ADMINISTRATOR(l_fnd_msg );
                        RETURN;
                END IF;

                wf_engine.setItemAttrtext(
                                        itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'ECX_PARAMETER1',
                                        avalue     => l_coll_id);

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ECX_PARAMETER1 set to  collaboration id value :- ' || l_coll_id,1);
                END IF;

                IF (l_Debug_Level <= 2) THEN
                        cln_debug_pub.Add('====== Exiting m4u_xml_genprocess_out.create_collab_setattr - Normal : resultout-' || resultout,2);
                END IF;

                RETURN;

        -- Exception Handling
        EXCEPTION

                WHEN OTHERS THEN
                        l_error_code       := SQLCODE;
                        l_error_msg        :='Workflow - ' || itemtype || '/' || itemkey || ' - ' || SQLERRM;

                        FND_MESSAGE.SET_NAME('CLN','M4U_CREATE_COLL_FAILURE');
                        /* 'Create Collaboration Failed. Details are
                            Colllaboration type : COLLTYPE
                            Document type       : DOCTYPE
                            Event Key           : EVTKEY
                            Item Type           : ITMTYPE
                            Error Code          : ERRCODE
                            Failure Reason      : MSG
                        */

                        l_fnd_msg     := FND_MESSAGE.GET;
                        CLN_NP_PROCESSOR_PKG.NOTIFY_ADMINISTRATOR(l_fnd_msg );

                        IF (l_Debug_Level <= 5) THEN
                                cln_debug_pub.Add('Unexpected Error  -'||l_error_code||' : '||l_error_msg,5);
                        END IF;

                        IF (l_Debug_Level <= 2) THEN
                                cln_debug_pub.Add('=========== Exiting m4u_xml_genprocess_out.create_collab_setattr  - Exception =========== ',2);
                        END IF;

                        wf_Core.context('m4u_xml_genprocess_out','create_collab_setattr', itemtype, itemkey, to_char(actid), funcmode);
                        RAISE;
        END;



        -- Name
        --      update_collab_setattr
        -- Purpose
        --
        -- Arguments
        --      itemtype                => WF item type
        --      itemkey                 => WF item key
        --      actid                   => WF act id
        --      funcmode                => WF func mode
        --      resultout               => result param
        -- Notes
        --      None.
        PROCEDURE update_collab_setattr(
                itemtype                          IN VARCHAR2,
                itemkey                           IN VARCHAR2,
                actid                             IN NUMBER,
                funcmode                          IN VARCHAR2,
                resultout                         IN OUT NOCOPY VARCHAR2
             )
        IS

                l_fnd_msg_key                     VARCHAR2(50);
                l_coll_status                     VARCHAR2(50);
                l_doc_status                      VARCHAR2(50);
                l_disposition                     VARCHAR2(50);
                l_event_key                       VARCHAR2(50);

                l_xmlg_message_id                 VARCHAR2(100);
                l_xmlg_transaction_type           VARCHAR2(100);
                l_xmlg_transaction_subtype        VARCHAR2(100);
                l_coll_type                       VARCHAR2(100);
                l_doc_type                        VARCHAR2(100);

                l_xmlg_document_id                VARCHAR2(256);
                l_debug_mode                      VARCHAR2(255);
                l_return_status                   VARCHAR2(255);
                l_doc_no                          VARCHAR2(255);
                l_wf_error_type                   VARCHAR2(255);
                l_fnd_msg                         VARCHAR2(255);

                l_msg_data                        VARCHAR2(2000);
                l_msg_text                        VARCHAR2(2000);
                l_error_msg                       VARCHAR2(2000);
                l_wf_error_msg                    VARCHAR2(2000);

                l_coll_pt                         VARCHAR2(20);

                l_tr_partner_id                   VARCHAR2(30);
                l_tr_partner_site                 VARCHAR2(30);
                l_unique1                         VARCHAR2(30);
                l_unique2                         VARCHAR2(30);
                l_unique3                         VARCHAR2(30);
                l_unique4                         VARCHAR2(30);
                l_unique5                         VARCHAR2(30);

                l_msg_count                       VARCHAR2(100);
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

                l_ecx_parameter1                  VARCHAR2(150);
                l_ecx_parameter2                  VARCHAR2(150);
                l_ecx_parameter3                  VARCHAR2(150);
                l_ecx_parameter4                  VARCHAR2(150);
                l_ecx_parameter5                  VARCHAR2(150);


                l_error_code                      NUMBER;
                l_coll_id                         NUMBER;
                l_coll_dtl_id                     NUMBER;


                l_dattribute1                     DATE;
                l_dattribute2                     DATE;
                l_dattribute3                     DATE;
                l_dattribute4                     DATE;
                l_dattribute5                     DATE;

      BEGIN

                IF (l_debug_Level <= 2) THEN
                        cln_debug_pub.Add('========= Entering update_collab_setattr  == ',2);
                END IF;

                -- Parameters received
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('-- Parameters received from Workflow process -- ',1);
                        cln_debug_pub.Add('itemtype             - '||itemtype,  1);
                        cln_debug_pub.Add('itemkey              - '||itemkey,   1);
                        cln_debug_pub.Add('actid                - '||actid,     1);
                        cln_debug_pub.Add('funcmode             - '||funcmode,  1);
                        cln_debug_pub.Add('---------------------------------------------',1);
                END IF;

                -- if funcmode is not null then exit
                IF (funcmode <> wf_engine.eng_run) THEN
                        resultout := wf_engine.eng_null;
                        IF (l_Debug_Level <= 2) THEN
                                cln_debug_pub.Add('M4U:====== Exiting update_collab_setattr - Normal : resultout - ' || resultout,2);
                        END IF;
                        RETURN;
                END IF;

                l_event_key                   :=  wf_engine.GetItemAttrText(itemtype, itemkey, 'ECX_EVENT_KEY',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Ecx Event Key                   ----'||l_event_key,1);
                END IF;

                -- ECX Parameter1 contains the collaboration ID
                l_ecx_parameter1              :=  wf_engine.GetItemAttrText(itemtype, itemkey, 'ECX_PARAMETER1',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ECX Parameter1                  ----'||l_ecx_parameter1,1);
                END IF;

                l_ecx_parameter2              :=  wf_engine.GetItemAttrText(itemtype, itemkey, 'ECX_PARAMETER2',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ECX Parameter2                  ----'||l_ecx_parameter2,1);
                END IF;

                l_ecx_parameter3              :=  wf_engine.GetItemAttrText(itemtype, itemkey, 'ECX_PARAMETER3',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ECX Parameter3                  ----'||l_ecx_parameter3,1);
                END IF;

                l_ecx_parameter4              :=  wf_engine.GetItemAttrText(itemtype, itemkey, 'ECX_PARAMETER4',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ECX Parameter4                  ----'||l_ecx_parameter4,1);
                END IF;

                l_ecx_parameter5              :=  wf_engine.GetItemAttrText(itemtype, itemkey, 'ECX_PARAMETER5',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ECX Parameter5                  ----'||l_ecx_parameter5,1);
                END IF;

                l_coll_type                   :=  wf_engine.GetItemAttrText(itemtype, itemkey, 'M4U_CLN_COLL_TYPE',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('COLLABORATION TYPE              ----'||l_coll_type,1);
                END IF;

                l_doc_type                    :=  wf_engine.GetItemAttrText(itemtype, itemkey, 'M4U_CLN_DOC_TYPE',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('DOCUMENT TYPE                   ----'||l_doc_type,1);
                END IF;

                l_xmlg_transaction_type       := wf_engine.GetItemAttrText(itemtype, itemkey,'ECX_TRANSACTION_TYPE',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ECX Transaction Type            ----'||l_xmlg_transaction_type, 1);
                END IF;

                l_xmlg_transaction_subtype    := wf_engine.GetItemAttrText(itemtype, itemkey,'ECX_TRANSACTION_SUBTYPE',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ECX Transaction Sub Type        ----'||l_xmlg_transaction_subtype, 1);
                END IF;

                l_msg_text               := wf_engine.GetItemAttrText(itemtype, itemkey,'MESSAGE_TEXT',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Message Text                    ----'||l_msg_text, 1);
                END IF;

                l_attribute1             := wf_engine.GetItemAttrText(itemtype, itemkey,'ATTRIBUTE1',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ATTRIBUTE1                      ----'||l_attribute1, 1);
                END IF;

                l_attribute2             := wf_engine.GetItemAttrText(itemtype, itemkey,'ATTRIBUTE2',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ATTRIBUTE2                      ----'||l_attribute2, 1);
                END IF;

                l_attribute3             := wf_engine.GetItemAttrText(itemtype, itemkey,'ATTRIBUTE3',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ATTRIBUTE3                      ----'||l_attribute3, 1);
                END IF;

                l_attribute4             := wf_engine.GetItemAttrText(itemtype, itemkey,'ATTRIBUTE4',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ATTRIBUTE4                      ----'||l_attribute4, 1);
                END IF;

                l_attribute5             := wf_engine.GetItemAttrText(itemtype, itemkey,'ATTRIBUTE5',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ATTRIBUTE5                      ----'||l_attribute5, 1);
                END IF;

                l_attribute6             := wf_engine.GetItemAttrText(itemtype, itemkey,'ATTRIBUTE6',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ATTRIBUTE6                      ----'||l_attribute6, 1);
                END IF;

                l_attribute7             := wf_engine.GetItemAttrText(itemtype, itemkey,'ATTRIBUTE7',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ATTRIBUTE7                      ----'||l_attribute7, 1);
                END IF;

                l_attribute8             := wf_engine.GetItemAttrText(itemtype, itemkey,'ATTRIBUTE8',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ATTRIBUTE8                      ----'||l_attribute8, 1);
                END IF;

                l_attribute9             := wf_engine.GetItemAttrText(itemtype, itemkey,'ATTRIBUTE9',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ATTRIBUTE9                      ----'||l_attribute9, 1);
                END IF;

                l_attribute10            := wf_engine.GetItemAttrText(itemtype, itemkey,'ATTRIBUTE10',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ATTRIBUTE10                      ----'||l_attribute10, 1);
                END IF;

                l_attribute11            := wf_engine.GetItemAttrText(itemtype, itemkey,'ATTRIBUTE11',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ATTRIBUTE11                      ----'||l_attribute11, 1);
                END IF;

                l_attribute12            := wf_engine.GetItemAttrText(itemtype, itemkey,'ATTRIBUTE12',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ATTRIBUTE12                      ----'||l_attribute12, 1);
                END IF;

                l_attribute13            := wf_engine.GetItemAttrText(itemtype, itemkey,'ATTRIBUTE13',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ATTRIBUTE13                      ----'||l_attribute13, 1);
                END IF;

                l_attribute14            := wf_engine.GetItemAttrText(itemtype, itemkey,'ATTRIBUTE14',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ATTRIBUTE14                      ----'||l_attribute14, 1);
                END IF;

                l_attribute15            := wf_engine.GetItemAttrText(itemtype, itemkey,'ATTRIBUTE15',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ATTRIBUTE15                      ----'||l_attribute15, 1);
                END IF;

                l_dattribute1            := m4u_ucc_utils.CONVERT_TO_DATE(wf_engine.GetItemAttrText(itemtype, itemkey,'DATTRIBUTE1',TRUE));
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('DATTRIBUTE1                      ----'||l_dattribute1, 1);
                END IF;

                l_dattribute2            := m4u_ucc_utils.CONVERT_TO_DATE(wf_engine.GetItemAttrText(itemtype, itemkey,'DATTRIBUTE2',TRUE));
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('DATTRIBUTE2                      ----'||l_dattribute2, 1);
                END IF;

                l_dattribute3            := m4u_ucc_utils.CONVERT_TO_DATE(wf_engine.GetItemAttrText(itemtype, itemkey,'DATTRIBUTE3',TRUE));
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('DATTRIBUTE3                      ----'||l_dattribute3, 1);
                END IF;

                l_dattribute4            := m4u_ucc_utils.CONVERT_TO_DATE(wf_engine.GetItemAttrText(itemtype, itemkey,'DATTRIBUTE4',TRUE));
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('DATTRIBUTE4                      ----'||l_dattribute4, 1);
                END IF;

                l_dattribute5            := m4u_ucc_utils.CONVERT_TO_DATE(wf_engine.GetItemAttrText(itemtype, itemkey,'DATTRIBUTE5',TRUE));
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('DATTRIBUTE5                      ----'||l_dattribute5, 1);
                END IF;

                l_xmlg_message_id       := wf_engine.GetItemAttrText(itemtype, itemkey,'ECX_MSGID_ATTR',TRUE);
                IF (l_debug_Level <= 1) THEN
                        cln_debug_pub.Add('XMLG Message ID                  ----' || l_xmlg_message_id,1);
                END IF;

                l_xmlg_document_id      := wf_engine.GetItemAttrText(itemtype, itemkey, 'ECX_DOCUMENT_ID',TRUE);
                IF (l_debug_Level <= 1) THEN
                        cln_debug_pub.Add('XMLG Document ID                 ----' || l_xmlg_document_id,1);
                END IF;

                -- This attribute when filled is used for add messages screen
                l_wf_error_msg          := wf_engine.GetItemAttrText(itemtype, itemkey, 'M4U_ERROR_MSG',TRUE );
                IF (l_debug_Level <= 1) THEN
                        cln_debug_pub.Add('WF Error Msg                     ----' || l_wf_error_msg,1);
                END IF;

                -- This attribute is used for puttg up prefix to generic msgs that can be used
                -- in the collaboration event details screen
                l_fnd_msg_key           := wf_engine.GetActivityAttrText(itemtype, itemkey, actid,'M4U_FND_MSG',TRUE);
                IF (l_debug_Level <= 1) THEN
                        cln_debug_pub.Add('Message Prefix                   ----' || l_fnd_msg_key,1);
                END IF;

                -- check if error type is set at Activity level
                -- else check at item level, doing this because some of the WF activities involving the
                -- java files do not set item_attribute M4U_ERROR_TYPE. This is specific to different Updates
                l_wf_error_type         := wf_engine.GetActivityAttrText(itemtype, itemkey,actid, 'M4U_ERROR_TYPE',TRUE);
                if(l_wf_error_type IS NULL) THEN
                        l_wf_error_type         := wf_engine.GetItemAttrText(itemtype, itemkey, 'M4U_ERROR_TYPE',TRUE);
                END IF;

                IF (l_debug_Level <= 1) THEN
                        cln_debug_pub.Add('l_wf_error_type          ----' || l_wf_error_type,1);
                END IF;

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('------------------------------------------', 1);
                END IF;

                -- set CLN Disposition, CLN Coll Status, CLN Doc status, CLN Message Text
                IF ( l_wf_error_type  is NULL) THEN
                        l_disposition := 'PENDING' ;
                        l_fnd_msg_key := l_fnd_msg_key || '_SUCCESS';
                        l_coll_status := 'INITIATED';
                        l_doc_status  := 'SUCCESS';
                ELSE
                        l_disposition := 'REJECTED' ;
                        l_fnd_msg_key := l_fnd_msg_key || '_FAILURE';
                        l_coll_status := 'ERROR';
                        l_doc_status  := 'ERROR';

                        wf_engine.setItemAttrtext(
                                        itemtype   =>   itemtype,
                                        itemkey    =>   itemkey,
                                        aname      =>   'M4U_ERROR_FLAG',
                                        avalue     =>   'Y');

                        IF (l_debug_Level <= 1) THEN
                                cln_debug_pub.Add('M4U_ERROR_FLAG - Y',1);
                        END IF;
                END IF;

                CLN_CH_COLLABORATION_PKG.UPDATE_COLLABORATION(
                    x_return_status                  =>         l_return_status,
                    x_msg_data                       =>         l_msg_data,
                    p_coll_id                        =>         l_ecx_parameter1,
                    p_xmlg_transaction_type          =>         l_xmlg_transaction_type,
                    p_xmlg_transaction_subtype       =>         l_xmlg_transaction_subtype,
                    p_xmlg_document_id               =>         l_xmlg_document_id,
                    p_disposition                    =>         l_disposition,
                    p_coll_status                    =>         l_coll_status,
                    p_doc_type                       =>         l_doc_type,
                    p_doc_dir                        =>         'OUT',
                    p_coll_pt                        =>         l_coll_pt,
                    p_doc_status                     =>         l_doc_status,
                    p_notification_id                =>         NULL,
                    p_msg_text                       =>         l_fnd_msg_key,
                    p_xmlg_msg_id                    =>         l_xmlg_message_id,
                    p_unique1                        =>         l_unique1,
                    p_unique2                        =>         l_unique2,
                    p_unique3                        =>         l_unique3,
                    p_unique4                        =>         l_unique4,
                    p_unique5                        =>         l_unique5,
                    p_tr_partner_type                =>         m4u_ucc_utils.c_party_type,
                    p_tr_partner_id                  =>         m4u_ucc_utils.g_party_id,
                    p_tr_partner_site                =>         m4u_ucc_utils.g_party_site_id,
                    p_rosettanet_check_required      =>         FALSE,
                    x_dtl_coll_id                    =>         l_coll_dtl_id
                );

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.add('collaboration history updated for cln_id     - ' || l_coll_id,1);
                        cln_debug_pub.add('Collab_detail_id     - ' || l_coll_dtl_id,1);
                        cln_debug_pub.add('x_return_status      - ' || l_return_status,1);
                        cln_debug_pub.add('x_msg_data           - ' || l_msg_data,1);
                END IF;


                IF l_return_status <> 'S' THEN
                        resultout       := wf_engine.eng_completed || ':FAIL';

                        FND_MESSAGE.SET_NAME('CLN','M4U_UPDATE_COLL_FAILURE');
                        /* 'Update Collaboration Failed. Details are
                            Collaboration type  : COLLTYPE
                            Collaboration Id    : COLLID
                            Document type       : DOCTYPE
                            Event Key           : EVTKEY
                            Item Type           : ITMTYPE
                            Error Code          : ERRCODE
                            Failure Reason      : MSG
                        */
                        FND_MESSAGE.SET_TOKEN('COLL_TYPE',l_coll_type);
                        FND_MESSAGE.SET_TOKEN('COLL_ID',l_ecx_parameter1);
                        FND_MESSAGE.SET_TOKEN('DOC_TYPE',l_doc_type);
                        FND_MESSAGE.SET_TOKEN('ITEM_TYPE',itemtype);
                        FND_MESSAGE.SET_TOKEN('EVT_KEY',itemkey);
                        FND_MESSAGE.SET_TOKEN('FAILURE_REASON',l_msg_data);

                        l_fnd_msg     := FND_MESSAGE.GET;

                        wf_engine.setItemAttrtext(
                                        itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'M4U_ERROR_FLAG',
                                        avalue     => 'Y');

                        IF (l_debug_Level <= 1) THEN
                                cln_debug_pub.Add('M4U_ERROR_FLAG - Y',1);
                        END IF;

                        -- Notify the administrator
                        CLN_NP_PROCESSOR_PKG.NOTIFY_ADMINISTRATOR(l_fnd_msg);

                        IF (l_debug_Level <= 1) THEN
                                cln_debug_pub.Add('return from call to Notify_Administrator',1);
                        END IF;

                        IF (l_doc_type = 'M4U_CIN' OR l_doc_type = 'M4U_RCIR' OR l_doc_type = 'M4U_RCIR_BATCH') THEN
                                ego_uccnet_events_pub.update_event_disposition(
                                                p_api_version       => 1.0,
                                                p_cln_id            => l_ecx_parameter1,
                                                p_disposition_code  => 'FAILED',
                                                p_disposition_date  => sysdate,
                                                x_return_status     => l_return_status,
                                                x_msg_count         => l_msg_count,
                                                x_msg_data          => l_msg_data );

                                IF (l_Debug_Level <= 1) THEN
                                        cln_debug_pub.Add('ego_uccnet_events_pub.update_event_disposition - returns', 1);
                                        cln_debug_pub.Add('     l_return_status         - '|| l_return_status, 1);
                                        cln_debug_pub.Add('     l_msg_data              - '|| l_msg_data, 1);
                                        cln_debug_pub.Add('     l_msg_count             - '|| l_msg_count, 1);
                                END IF;

                                IF (l_Debug_Level <= 2) THEN
                                        cln_debug_pub.Add('====== Exiting m4u_xml_genprocess_out.update_cln_collaborations - Normal : resultout-' || resultout,2);
                                END IF;
                                RETURN; -- Something wrong, simply notify admin and bailout, ...
                        END IF;
                END IF;


                IF l_wf_error_msg IS NOT NULL THEN
                        IF (l_Debug_Level <= 1) THEN
                                cln_debug_pub.add('adding error detail to dtl_coll_id - ' || l_coll_dtl_id,1);
                                cln_debug_pub.add('message                            - ' || l_wf_error_msg,1);
                        END IF;


                        IF (l_doc_type = 'M4U_CIN' OR l_doc_type = 'M4U_RCIR' OR l_doc_type = 'M4U_RCIR_BATCH') THEN
                                ego_uccnet_events_pub.update_event_disposition(
                                                p_api_version       => 1.0,
                                                p_cln_id            => l_ecx_parameter1,
                                                p_disposition_code  => 'FAILED',
                                                p_disposition_date  => sysdate,
                                                x_return_status     => l_return_status,
                                                x_msg_count         => l_msg_count,
                                                x_msg_data          => l_msg_data );

                                IF (l_Debug_Level <= 1) THEN
                                        cln_debug_pub.Add('ego_uccnet_events_pub.update_event_disposition - returns', 1);
                                        cln_debug_pub.Add('     l_return_status         - '|| l_return_status, 1);
                                        cln_debug_pub.Add('     l_msg_data              - '|| l_msg_data, 1);
                                        cln_debug_pub.Add('     l_msg_count             - '|| l_msg_count, 1);
                                END IF;
                        END IF;


                        cln_ch_collaboration_pkg.add_collaboration_messages
                                                (
                                                    x_return_status => l_return_status,
                                                    x_msg_data      => l_msg_data,
                                                    p_dtl_coll_id   => l_coll_dtl_id,
                                                    p_dtl_msg       => l_wf_error_msg
                                                );

                        IF (l_Debug_Level <= 1) THEN
                                cln_debug_pub.add('error detail added to dtl_coll_id - ' || l_coll_dtl_id,1);
                                cln_debug_pub.add('x_return_status              - ' || l_return_status,1);
                                cln_debug_pub.add('x_msg_data           - ' || l_msg_data,1);
                        END IF;

                        IF l_return_status <> 'S' THEN
                                FND_MESSAGE.SET_NAME('CLN','M4U_UPDATE_COLL_FAILURE');
                                /* 'Update Collaboration Failed. Details are
                                    Collaboration type  : COLLTYPE
                                    Collaboration Id    : COLLID
                                    Document type       : DOCTYPE
                                    Event Key           : EVTKEY
                                    Item Type           : ITMTYPE
                                    Error Code          : ERRCODE
                                    Failure Reason      : MSG
                                */

                                FND_MESSAGE.SET_TOKEN('COLL_TYPE',l_coll_type);
                                FND_MESSAGE.SET_TOKEN('COLL_ID',l_ecx_parameter1);
                                FND_MESSAGE.SET_TOKEN('DOC_TYPE',l_doc_type);
                                FND_MESSAGE.SET_TOKEN('ITEM_TYPE',itemtype);
                                FND_MESSAGE.SET_TOKEN('EVT_KEY',itemkey);
                                FND_MESSAGE.SET_TOKEN('FAILURE_REASON',l_msg_data);


                                l_fnd_msg     := FND_MESSAGE.GET;

                                wf_engine.setItemAttrtext(
                                        itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'M4U_ERROR_FLAG',
                                        avalue     => 'Y');

                                IF (l_debug_Level <= 1) THEN
                                        cln_debug_pub.Add('M4U_ERROR_FLAG - set to Y',1);
                                END IF;

                                CLN_NP_PROCESSOR_PKG.NOTIFY_ADMINISTRATOR(l_fnd_msg);
                                IF (l_debug_Level <= 1) THEN
                                        cln_debug_pub.Add('returning from call to Notifiy_Administrator',1);
                                END IF;
                        END IF;
                END IF;

                -- this nullfies the value stored in the message for update collaboration
                wf_engine.setItemAttrtext(
                                        itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'M4U_ERROR_TYPE',
                                        avalue     => NULL);

                IF (l_debug_Level <= 1) THEN
                        cln_debug_pub.Add('M4U_ERROR_TYPE set to NULL',1);
                END IF;

                -- this nullfies the value stored in the message for add messages table
                wf_engine.setItemAttrtext(
                                        itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'M4U_ERROR_MSG',
                                        avalue     => NULL);

                IF (l_debug_Level <= 1) THEN
                        cln_debug_pub.Add('M4U_ERROR_MSG set to NULL',1);
                END IF;

                resultout := wf_engine.eng_completed;

                IF (l_Debug_Level <= 2) THEN
                        cln_debug_pub.Add('====== Exiting m4u_xml_genprocess_out.update_collab_setattr - Normal : resultout-' || resultout,2);
                END IF;

                RETURN;
        -- Exception Handling
        EXCEPTION

                WHEN OTHERS THEN
                        l_error_code       :=SQLCODE;
                        l_error_msg        :='Workflow - ' || itemtype || '/' || itemkey || ' - ' || SQLERRM;

                        FND_MESSAGE.SET_NAME('CLN','M4U_UPDATE_COLL_FAILURE');

                        FND_MESSAGE.SET_TOKEN('COLL_TYPE',l_coll_type);
                        FND_MESSAGE.SET_TOKEN('COLL_ID',l_ecx_parameter1);
                        FND_MESSAGE.SET_TOKEN('DOC_TYPE',l_doc_type);
                        FND_MESSAGE.SET_TOKEN('ITEM_TYPE',itemtype);
                        FND_MESSAGE.SET_TOKEN('EVT_KEY',itemkey);
                        FND_MESSAGE.SET_TOKEN('FAILURE_REASON',l_error_msg);

                        l_fnd_msg     := FND_MESSAGE.GET;

                        CLN_NP_PROCESSOR_PKG.NOTIFY_ADMINISTRATOR(l_fnd_msg);

                        IF (l_Debug_Level <= 5) THEN
                                cln_debug_pub.Add('Unexpected Error  -'||l_error_code||' : '||l_error_msg,5);
                        END IF;

                        IF (l_Debug_Level <= 2) THEN
                                cln_debug_pub.Add('=========== Exiting m4u_xml_genprocess_out.update_collab_setattr  - Exception =========== ',2);
                        END IF;

                        wf_Core.context('m4u_xml_genprocess_out','update_collab_setattr',
                                itemtype, itemkey, to_char(actid), funcmode);
                        RAISE;
        END;


        -- Name
        --      create CLN collaborations in batch mode
        -- Purpose
        --      Creates multiple CLN collaborations for each item-event in the group.
        --      returns failure even if one of the collab is not created successfully.
        --      updates ego_uccnet_events, with the CLN id.
        --      this CLN id, is used as the command level unique-identifier.
        -- Arguments
        --      itemtype                => WF item type
        --      itemkey         => WF item key
        --      actid                   => WF act id
        --      funcmode                => WF func mode
        --      resultout               => result param
        -- Notes
        --      None.

        PROCEDURE create_batchcollab_setattr(
                  itemtype                      IN VARCHAR2,
                  itemkey                       IN VARCHAR2,
                  actid                         IN NUMBER,
                  funcmode                      IN VARCHAR2,
                  resultout                     IN OUT NOCOPY VARCHAR2
                  )
        IS
                  x_coll_id                       NUMBER;
                  l_gtin_count                    NUMBER;
                  l_ego_batch_id                  NUMBER;
                  l_ego_subbatch_id               NUMBER;
                  l_org_id                        NUMBER;

                  x_return_status                 VARCHAR2(10);

                  l_tp_gln                        VARCHAR2(50);
                  l_target_market                 VARCHAR2(50);
                  l_error_code                    VARCHAR2(50);
                  l_owner_role                    VARCHAR2(50);

                  x_msg_count                     VARCHAR2(100);
                  l_xmlg_transaction_subtype      VARCHAR2(100);
                  l_xmlg_transaction_type         VARCHAR2(100);
                  l_xmlg_document_id              VARCHAR2(100);
                  l_ecx_msg_id                    VARCHAR2(100);
                  l_coll_type                     VARCHAR2(100);
                  l_doc_type                      VARCHAR2(100);

                  l_error_msg                     VARCHAR2(255);
                  l_fnd_msg                       VARCHAR2(2000);
                  x_msg_data                      VARCHAR2(4000);

                  l_event_type                    ego_uccnet_events.event_type%TYPE;
                  l_event_action                  ego_uccnet_events.event_action%TYPE;
                  l_gtin                          ego_uccnet_events.gtin%TYPE;
                  l_top_gtin                      ego_uccnet_events.top_gtin%TYPE;
                  l_doc_owner                     ego_uccnet_events.last_updated_by%TYPE;
                  l_item_number                   mtl_system_items_kfv.concatenated_segments%TYPE;


                CURSOR c_gtinInBatch (p_batchid NUMBER, p_subbatch_id NUMBER, p_event_type VARCHAR2)
                IS
                      SELECT  e.event_action, e.gtin, e.top_gtin,
                              e.last_updated_by,e.target_market, e.tp_gln,
                              e.organization_id, f.user_name, mtlkfv.concatenated_segments
                      FROM    ego_uccnet_events e,
                              fnd_user f,
                              mtl_system_items_kfv mtlkfv
                      WHERE   e.batch_id          = p_batchid
                        AND   e.subbatch_id       = p_subbatch_id
                        AND   e.gtin              = e.top_gtin
                        AND   e.event_type        = p_event_type
                        AND   e.INVENTORY_ITEM_ID = mtlkfv.INVENTORY_ITEM_ID
                        AND   e.ORGANIZATION_ID   = mtlkfv.ORGANIZATION_ID
                        AND   e.last_updated_by   = f.user_id(+);

                /*
                        For publications, this will give the TOP level GTINs only.
                        need to check with if this is true for REGISTRATION GTIN
                        as well, that is GTIN=TOP_GTIN
                 */
        BEGIN
                IF (l_debug_Level <= 2) THEN
                        cln_debug_pub.Add('========= Entering create_batchcollab_setattr  == ',2);
                END IF;

                -- Parameters received
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('-- Parameters received from Workflow process -- ',1);
                        cln_debug_pub.Add('itemtype             - '||itemtype,  1);
                        cln_debug_pub.Add('itemkey              - '||itemkey,   1);
                        cln_debug_pub.Add('actid                - '||actid,     1);
                        cln_debug_pub.Add('funcmode             - '||funcmode,  1);
                        cln_debug_pub.Add('---------------------------------------------',1);
                END IF;

                -- if funcmode is not null then exit
                IF (funcmode <> wf_engine.eng_run) THEN
                        resultout := wf_engine.eng_null;
                        IF (l_Debug_Level <= 2) THEN
                                cln_debug_pub.Add('M4U:====== Exiting create_batchcollab_setattr - Normal : resultout - ' || resultout,2);
                        END IF;
                        RETURN;
                END IF;

                -- Pramaters obtained with the event from EGO
                l_xmlg_transaction_type       := wf_engine.GetItemAttrText(itemtype, itemkey,'ECX_TRANSACTION_TYPE',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ECX Transaction Type            ----'||l_xmlg_transaction_type, 1);
                END IF;

                l_xmlg_transaction_subtype    := wf_engine.GetItemAttrText(itemtype, itemkey,'ECX_TRANSACTION_SUBTYPE',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ECX Transaction Sub Type        ----'||l_xmlg_transaction_subtype, 1);
                END IF;

                l_ego_batch_id            := wf_engine.GetItemAttrText(itemtype, itemkey, 'ECX_PARAMETER2',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('EGO batch id                    ----'|| l_ego_batch_id    , 1);
                END IF;

                l_ego_subbatch_id         := wf_engine.GetItemAttrText(itemtype, itemkey, 'ECX_PARAMETER1',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('EGO subbatch id                 ----'|| l_ego_subbatch_id , 1);
                END IF;

                l_event_type              := wf_engine.GetItemAttrText(itemtype, itemkey, 'ECX_PARAMETER3',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Event Type                      ----'|| l_event_type , 1);
                END IF;

                l_coll_type                := wf_engine.GetItemAttrText(itemtype, itemkey, 'M4U_CLN_COLL_TYPE',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Collaboration Type              ----'|| l_coll_type , 1);
                END IF;

                l_doc_type                    :=  wf_engine.GetItemAttrText(itemtype, itemkey, 'M4U_CLN_DOC_TYPE',TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('DOCUMENT TYPE                   ----'||l_doc_type,1);
                END IF;


                l_xmlg_document_id := l_ego_batch_id || ':' || l_ego_subbatch_id;

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ECX document id                 ----'|| l_xmlg_document_id, 1);
                END IF;


                -- set item-attributes of WF
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('-----  Set WF Item Attributes ----- ',1);
                END IF;

                wf_engine.setItemAttrtext(
                                        itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'ECX_PARTY_SITE_ID',
                                        avalue     => m4u_ucc_utils.g_party_site_id);

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add(' Item Attribute          - ECX_PARTY_SITE_ID set',1);
                END IF;

                wf_engine.setItemAttrtext(
                                        itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'ECX_PARTY_ID',
                                        avalue     => m4u_ucc_utils.g_party_id);

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add(' Item Attribute          - ECX_PARTY_ID set',1);
                END IF;

                wf_engine.setItemAttrtext(
                                        itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'ECX_PARTY_TYPE',
                                        avalue     => m4u_ucc_utils.c_party_type);

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add(' Item Attribute          - ECX_PARTY_TYPE set',1);
                END IF;

                wf_engine.setItemAttrtext(
                                        itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'M4U_XML_VALIDATION_REQUIRED',
                                        avalue     => fnd_profile.value('M4U_XML_VALIDATION_REQUIRED'));

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add(' XML Validation Reqd     - ' || fnd_profile.value('M4U_XML_VALIDATION_REQUIRED'),1);
                END IF;





                /* look at the  ego_uccnet_events table and set these values    */
                /* get the values for the wf and cln                                    */
                OPEN c_gtinInBatch(l_ego_batch_id,NVL(l_ego_subbatch_id,1),l_event_type );

                LOOP
                        FETCH   c_gtinInBatch
                        INTO    l_event_action,l_gtin,l_top_gtin,l_doc_owner,
                                l_target_market,l_tp_gln, l_org_id,l_owner_role, l_item_number;

                        EXIT WHEN c_gtinInBatch%NOTFOUND;

                        IF (l_Debug_Level <= 1) THEN
                                cln_debug_pub.Add('     in the loop w/ l_gtin   - '|| l_gtin            , 1);
                                cln_debug_pub.Add('     l_event_action          - '|| l_event_action    , 1);
                                cln_debug_pub.Add('     l_gtin                  - '|| l_gtin            , 1);
                                cln_debug_pub.Add('     l_top_gtin              - '|| l_top_gtin        , 1);
                                cln_debug_pub.Add('     l_doc_owner             - '|| l_doc_owner       , 1);
                                cln_debug_pub.Add('     l_target_market         - '|| l_target_market   , 1);
                                cln_debug_pub.Add('     l_tp_gln                - '|| l_tp_gln          , 1);
                                cln_debug_pub.Add('     l_org_id                - '|| l_org_id          , 1);
                                cln_debug_pub.Add('     l_item_number           - '|| l_item_number     , 1);
                                cln_debug_pub.Add('     l_owner_role            - '|| l_owner_role      , 1);
                        END IF;



                        /* Now set the values needed for CLN create collaboration event all the
                        values are based on ECX transaction type need to derive values for CLN
                        API and set WF attributes for XMLG Generate document routine.
                        */
                        -- here the doc type is hardcoded to M4U_RCIR which would need a change
                        l_coll_type             := 'M4U_RCIR'||'_'||l_event_action;

                        wf_engine.setItemAttrtext(
                                        itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'M4U_CLN_COLL_TYPE',
                                        avalue     => l_coll_type);

                        IF (l_Debug_Level <= 1) THEN
                                cln_debug_pub.Add('M4U_CLN_DOC_TYPE - ' || l_doc_type, 1);
                        END IF;

                        wf_engine.setItemAttrtext(
                                        itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'ECX_DOCUMENT_ID',
                                        avalue     => l_xmlg_document_id);

                        IF (l_Debug_Level <= 1) THEN
                                cln_debug_pub.Add('ECX_DOCUMENT_ID - ' || l_xmlg_document_id, 1);
                        END IF;


                        /* create CLN collaboration and update the ego_uccnet_events with CLN-id*/
                        /* this CLN-d will be used as command level identifier in the map       */
                        cln_ch_collaboration_pkg.create_collaboration(
                                x_return_status               => x_return_status,
                                x_msg_data                    => x_msg_data,
                                p_app_id                      => m4u_ucc_utils.c_resp_appl_id,
                                p_ref_id                      => NULL,
                                p_org_id                      => m4u_ucc_utils.g_org_id,
                                p_rel_no                      => NULL,
                                p_doc_no                      => l_gtin,
                                p_doc_owner                   => l_doc_owner,
                                p_xmlg_int_transaction_type   => l_xmlg_transaction_type,
                                p_xmlg_int_transaction_subtype=> l_xmlg_transaction_subtype,
                                p_xmlg_transaction_type       => l_xmlg_transaction_type,
                                p_xmlg_transaction_subtype    => l_xmlg_transaction_subtype,
                                p_xmlg_document_id            => l_xmlg_document_id,
                                p_coll_type                   => l_coll_type,
                                p_tr_partner_type             => m4u_ucc_utils.c_party_type,
                                p_tr_partner_site             => m4u_ucc_utils.g_party_site_id,
                                p_doc_creation_date           => sysdate,
                                p_doc_revision_date           => sysdate,
                                p_init_date                   => sysdate,
                                p_doc_type                    => l_doc_type,
                                p_doc_dir                     => 'OUT',
                                p_coll_pt                     => 'APPS',
                                p_xmlg_msg_id                 => NULL,
                                p_rosettanet_check_required   => FALSE,
                                x_coll_id                     => x_coll_id,
                                p_msg_text                    => 'M4U_REGISTRATION_INITIATED',
                                p_xml_event_key               => itemkey,
                                p_attribute1                  => m4u_ucc_utils.g_host_gln,
                                p_attribute2                  => l_target_market,
                                p_attribute3                  => l_ego_batch_id,
                                p_attribute4                  => l_ego_subbatch_id,
                                p_attribute5                  => m4u_ucc_utils.g_supp_gln,
                                p_attribute6                  => l_tp_gln,
                                p_attribute12                 => l_xmlg_document_id,
                                p_partner_doc_no              => l_item_number,
                                p_collaboration_standard      => 'UCCNET',
                                p_owner_role                  => l_owner_role);

                        IF (l_Debug_Level <= 1) THEN
                                cln_debug_pub.Add('create collaboration returns - ', 1);
                                cln_debug_pub.Add('     x_return_status         - '|| x_return_status, 1);
                                cln_debug_pub.Add('     x_msg_data              - '|| x_msg_data, 1);
                                cln_debug_pub.Add('     x_coll_id               - '|| x_coll_id, 1);
                        END IF;

                        IF (x_return_status ='S') THEN

                                ego_uccnet_events_pub.set_collaboration_id(
                                                p_api_version     => 1.0,
                                                p_batch_id        => l_ego_batch_id ,
                                                p_subbatch_id     => l_ego_subbatch_id,
                                                p_top_gtin        => l_gtin,
                                                p_cln_id          => x_coll_id,
                                                x_return_status   => x_return_status,
                                                x_msg_count       => x_msg_count,
                                                x_msg_data        => x_msg_data);

                               IF (l_Debug_Level <= 1) THEN
                                        cln_debug_pub.Add('ego_uccnet_events_pub.set_collaboration_id - ', 1);
                                        cln_debug_pub.Add('     x_return_status         - '|| x_return_status, 1);
                                        cln_debug_pub.Add('     x_msg_data              - '|| x_msg_data, 1);
                                        cln_debug_pub.Add('     x_msg_count             - '|| x_msg_count, 1);
                               END IF;

                        ELSE
                                resultout := wf_engine.eng_completed || ':FAIL';

                                wf_engine.setItemAttrtext(
                                        itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'M4U_ERROR_FLAG',
                                        avalue     => 'Y');

                                IF (l_Debug_Level <= 1) THEN
                                        cln_debug_pub.Add('M4U_ERROR_FLAG set to Y', 1);
                                END IF;

                                FND_MESSAGE.SET_NAME('CLN','M4U_OUT_CREATE_COLL_FAILURE');
                                l_fnd_msg     := FND_MESSAGE.GET;

                                x_msg_data   := 'Workflow - '  || itemtype || '/' || itemkey || ' - ' || x_msg_data;

                                CLN_NP_PROCESSOR_PKG.NOTIFY_ADMINISTRATOR(l_fnd_msg
                                                    || ', Error code  - '
                                                    || x_return_status
                                                    || ', Error message - '
                                                    || x_msg_data);

                                IF (l_Debug_Level <= 2) THEN
                                        cln_debug_pub.Add('EXITING m4u_xml_genprocess_out.create_cln_collaborations FAILURE',2);
                                END IF;
                                RETURN;
                        END IF;

                END LOOP;

                IF (l_debug_Level <= 2) THEN
                        cln_debug_pub.Add('========= Exiting create_batchcollab_setattr  == ',2);
                END IF;

                resultout := wf_engine.eng_completed||':SUCCESS';

        EXCEPTION
                WHEN OTHERS THEN
                        l_error_code       :=SQLCODE;
                        l_error_msg        :=' Workflow - ' ||  itemtype || '/' || itemkey || ' - ' || SQLERRM;

                        FND_MESSAGE.SET_NAME('CLN','M4U_OUT_CREATE_COLL_FAILURE');
                        x_msg_data     := FND_MESSAGE.GET;

                        CLN_NP_PROCESSOR_PKG.NOTIFY_ADMINISTRATOR(x_msg_data
                                                || ', Error code - '
                                                || l_error_code
                                                || ', Error message - '
                                                || l_error_msg);


                        IF (l_Debug_Level <= 5) THEN
                                cln_debug_pub.Add('Error        : ' || SQLCODE || ':' || SQLERRM, 5);
                                cln_debug_pub.Add('x_msg_data   : ' || x_msg_data,5);
                        END IF;
                        IF (l_Debug_Level <= 2) THEN
                                cln_debug_pub.Add('=========== Exiting m4u_xml_genprocess_out.create_cln_collaborations  - Exception =========== ',2);
                        END IF;

                        Wf_Core.Context('m4u_xml_genprocess_out','create_cln_collaborations',
                                itemtype, itemkey, to_char(actid), funcmode);
                        RAISE;
        END;


        -- Name
        --      Update_cln_collaborations
        -- Purpose
        --      update the collaboration with
        --      i) ECXMSGID after message generation
        --      ii)Any error/ progress information
        -- Arguments
        --      itemtype                => WF item type
        --      itemkey                 => WF item key
        --      actid                   => WF act id
        --      funcmode                => WF func mode
        --      resultout               => result param
        -- Notes
        --      None.


        PROCEDURE update_batchcollab_setattr(
                itemtype                        IN VARCHAR2,
                itemkey                         IN VARCHAR2,
                actid                           IN NUMBER,
                funcmode                        IN VARCHAR2,
                resultout                       IN OUT NOCOPY VARCHAR2
                )
        IS
                x_return_status                   VARCHAR2(10);
                x_msg_data                        VARCHAR2(4000);
                x_msg_count                       VARCHAR2(100);
                l_ego_batch_id                    NUMBER;
                l_ego_subbatch_id                 NUMBER;
                l_xmlg_transaction_subtype        VARCHAR2(100);
                l_xmlg_transaction_type           VARCHAR2(100);
                l_ecx_partysite_id                VARCHAR2(30);
                l_ecx_party_type                  VARCHAR2(10);
                l_ecx_doc_id                      VARCHAR2(30);
                l_dtl_coll_id                     NUMBER;
                l_ecx_msgid                       VARCHAR2(100);
                l_wf_error_msg                    VARCHAR2(4000);
                l_wf_error_type                   VARCHAR2(100);
                l_wf_error_flag                   VARCHAR2(20);
                l_fnd_msg_key                     VARCHAR2(100);
                l_disposition                     VARCHAR2(100);
                l_coll_status                     VARCHAR2(100);
                l_doc_status                      VARCHAR2(100);
                l_error_code                      VARCHAR2(50);
                l_cln_doc_type                    VARCHAR2(50);
                l_cln_coll_type                   VARCHAR2(50);
                l_error_msg                       VARCHAR2(2000);

                /*CURSOR c_clnidForBatch (p_batchid VARCHAR2,p_subbatch_id VARCHAR2, p_coll_doc_type VARCHAR2) IS
                        SELECT  distinct  hdr.collaboration_id
                        FROM            cln_coll_hist_hdr hdr, cln_coll_hist_dtl dtl
                        WHERE           hdr.attribute3                    = p_batchid
                                AND     hdr.attribute4                    = p_subbatch_id
                                AND     COLLABORATION_DOCUMENT_TYPE       = p_coll_doc_type
                                AND     hdr.collaboration_id              = dtl.collaboration_id
                                AND     hdr.xmlg_transaction_type         = 'M4U';*/

                CURSOR c_clnidForBatch (p_batchid VARCHAR2,p_subbatch_id VARCHAR2, p_coll_type VARCHAR2) IS
                        SELECT          collaboration_id
                        FROM            cln_coll_hist_hdr
                        WHERE           attribute3             = p_batchid
                                AND     attribute4             = p_subbatch_id
                                AND     collaboration_type     = p_coll_type
                                AND     xmlg_transaction_type  = 'M4U';
        BEGIN
                IF (l_debug_Level <= 2) THEN
                        cln_debug_pub.Add('========= Entering update_batchcollab_setattr  == ',2);
                END IF;


                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Paramters received are'      , 2);
                        cln_debug_pub.Add('itemtype     - ' || itemtype , 2);
                        cln_debug_pub.Add('itemkey      - ' || itemkey  , 2);
                        cln_debug_pub.Add('actid        - ' || actid    , 2);
                        cln_debug_pub.Add('funcmode     - ' || funcmode , 2);
                END IF;


                -- if funcmode is not null then exit
                IF (funcmode <> wf_engine.eng_run) THEN
                        resultout := wf_engine.eng_null;
                        IF (l_Debug_Level <= 2) THEN
                                cln_debug_pub.Add('====== Exiting m4u_xml_genprocess_out.update_cln_collaborations - Normal : resultout-' || resultout,2);
                        END IF;
                        RETURN;
                END IF;

                l_ego_batch_id                  := wf_engine.GetItemAttrText(itemtype,itemkey,'ECX_PARAMETER2',TRUE);

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('WF Attributes retreived are', 1);
                        cln_debug_pub.Add('l_ego_batch_id                 ----'|| l_ego_batch_id , 1);
                END IF;


                l_ego_subbatch_id               := wf_engine.GetItemAttrText(itemtype,itemkey,'ECX_PARAMETER4',TRUE);

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('l_ego_subbatch_id              ----'|| l_ego_subbatch_id , 1);
                END IF;

                l_xmlg_transaction_type         := wf_engine.GetItemAttrText(itemtype,itemkey,'ECX_TRANSACTION_TYPE',TRUE);

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ECX l_xmlg_transaction_type    ----'|| l_xmlg_transaction_type  , 1);
                END IF;

                l_xmlg_transaction_subtype      := wf_engine.GetItemAttrText(itemtype,itemkey,'ECX_TRANSACTION_SUBTYPE',TRUE);

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ECX l_xmlg_transaction_subtype ----'|| l_xmlg_transaction_subtype  , 1);
                END IF;

                l_ecx_doc_id                    := wf_engine.GetItemAttrText(itemtype,itemkey,'ECX_DOCUMENT_ID',        TRUE);

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ECX l_ecx_doc_id               ----'|| l_ecx_doc_id , 1);
                END IF;

                l_ecx_msgid                     := wf_engine.GetItemAttrText(itemtype,itemkey,'ECX_MSGID_ATTR', TRUE);

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ECX l_ecx_msgid                ----'|| l_ecx_msgid, 1);
                END IF;

                /* following values will be available only if there is schema validation or adapter issues */
                l_wf_error_msg                  := wf_engine.GetItemAttrText(itemtype,itemkey,'M4U_ERROR_MSG',TRUE);

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('l_wf_error_msg                ----'|| l_wf_error_msg, 1);
                END IF;

                l_wf_error_flag                 := wf_engine.GetItemAttrText(itemtype,itemkey,'M4U_ERROR_FLAG',TRUE);

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('l_wf_error_flag                ----'|| l_wf_error_flag, 1);
                END IF;

                l_fnd_msg_key                   := wf_engine.GetActivityAttrText(itemtype, itemkey,actid,'M4U_FND_MSG',TRUE);

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('l_fnd_msg_key              ----'|| l_fnd_msg_key , 1);
                END IF;

                l_cln_doc_type                  := wf_engine.GetItemAttrText(itemtype,itemkey,'M4U_CLN_DOC_TYPE',TRUE);

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('l_cln_doc_type                 ----'|| l_cln_doc_type , 1);
                END IF;

                l_cln_coll_type                 := wf_engine.GetItemAttrText(itemtype,itemkey,'M4U_CLN_COLL_TYPE',TRUE);

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('l_cln_coll_type                 ----'|| l_cln_coll_type , 1);
                END IF;

                -- check if error type is set at Activity level
                -- else check at item level, doing this because some of the WF activities,
                -- do not set item_attribute M4U_ERROR_TYPE
                -- so setting Activity Attribute in the WF in those cases.
                l_wf_error_type         := wf_engine.GetActivityAttrText(itemtype, itemkey,actid, 'M4U_ERROR_TYPE',TRUE);

                if(l_wf_error_type IS NULL) THEN
                        l_wf_error_type := wf_engine.GetItemAttrText(itemtype, itemkey, 'M4U_ERROR_TYPE',TRUE);
                END IF;

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('l_wf_error_type                 ----'|| l_wf_error_type , 1);
                END IF;


                -- set CLN Disposition, CLN Coll Status, CLN Doc status, CLN Message Text
                IF ( l_wf_error_type  is NULL AND l_wf_error_flag <> 'Y' ) THEN
                        l_disposition := 'PENDING' ;
                        l_fnd_msg_key := l_fnd_msg_key || '_SUCCESS';
                        l_coll_status := 'INITIATED';
                        l_doc_status  := 'SUCCESS';
                ELSE
                        l_disposition := 'REJECTED' ;
                        l_fnd_msg_key := l_fnd_msg_key || '_FAILURE';
                        l_coll_status := 'ERROR';
                        l_doc_status  := 'ERROR';

                        wf_engine.setItemAttrtext(
                                        itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'M4U_ERROR_FLAG',
                                        avalue     => 'Y');

                        IF (l_Debug_Level <= 1) THEN
                                cln_debug_pub.Add('M4U_ERROR_FLAG set to Y', 1);
                        END IF;
                END IF;

                --for each collaboration in the batch,
                --update message and add any error to Error information
                FOR rec_cln_ids IN c_clnidForBatch(l_ego_batch_id,l_ego_subbatch_id,l_cln_coll_type)
                LOOP

                        cln_ch_collaboration_pkg.update_collaboration(
                                x_return_status                  => x_return_status,
                                x_msg_data                       => x_msg_data,
                                p_coll_id                        => rec_cln_ids.collaboration_id,
                                p_msg_text                       => l_fnd_msg_key,
                                p_xmlg_msg_id                    => l_ecx_msgid,
                                p_xmlg_transaction_type          => l_xmlg_transaction_type,
                                p_xmlg_transaction_subtype       => l_xmlg_transaction_subtype ,
                                p_xmlg_int_transaction_type      => l_xmlg_transaction_type,
                                p_xmlg_int_transaction_subtype   => l_xmlg_transaction_subtype ,
                                p_doc_dir                        => 'OUT',
                                p_doc_type                       => l_cln_doc_type,
                                p_disposition                    => l_disposition,
                                p_doc_status                     => l_doc_status,
                                p_coll_status                    => l_coll_status,
                                p_xmlg_document_id               => l_ecx_doc_id,
                                p_tr_partner_type                => m4u_ucc_utils.c_party_type,
                                p_tr_partner_id                  => m4u_ucc_utils.g_party_id,
                                p_tr_partner_site                => m4u_ucc_utils.g_party_site_id,
                                p_rosettanet_check_required      => false,
                                x_dtl_coll_id                    => l_dtl_coll_id );

                        IF (l_Debug_Level <= 1) THEN
                                cln_debug_pub.add('collaboration history updated for cln_id     - ' || rec_cln_ids.collaboration_id,1);
                                cln_debug_pub.add('collab_detail_id     - ' || l_dtl_coll_id,1);
                                cln_debug_pub.add('x_return_status      - ' || x_return_status,1);
                                cln_debug_pub.add('x_msg_data           - ' || x_msg_data,1);
                        END IF;

                        IF x_return_status <> 'S' THEN
                                FND_MESSAGE.SET_NAME('CLN','M4U_OUT_UPDATE_COLL_FAILURE');
                                l_fnd_msg_key     := FND_MESSAGE.GET;

                                wf_engine.setItemAttrtext(
                                        itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'M4U_ERROR_FLAG',
                                        avalue     => 'Y');

                                IF (l_Debug_Level <= 1) THEN
                                        cln_debug_pub.Add('M4U_ERROR_FLAG set to Y', 1);
                                END IF;

                                resultout       := wf_engine.eng_completed || ':FAIL';
                                x_msg_data      := 'Workflow - '  || itemtype || '/' || itemkey || ' - ' || x_msg_data;

                                CLN_NP_PROCESSOR_PKG.NOTIFY_ADMINISTRATOR
                                                                ( l_fnd_msg_key
                                                                || ', Error code  - '
                                                                || x_return_status
                                                                || ', Error message - '
                                                                || x_msg_data);
                                IF (l_Debug_Level <= 1) THEN
                                        cln_debug_pub.Add('returned from call to NOTIFY_ADMINISTRATOR', 1);
                                END IF;

                                ego_uccnet_events_pub.update_event_disposition(
                                                p_api_version       => 1.0,
                                                p_cln_id            => rec_cln_ids.collaboration_id,
                                                p_disposition_code  => 'FAILED',
                                                p_disposition_date  => sysdate,
                                                x_return_status     => x_return_status,
                                                x_msg_count         => x_msg_count,
                                                x_msg_data          => x_msg_data );

                                IF (l_Debug_Level <= 1) THEN
                                        cln_debug_pub.Add('ego_uccnet_events_pub.update_event_disposition - returns', 1);
                                        cln_debug_pub.Add('     x_return_status         - '|| x_return_status, 1);
                                        cln_debug_pub.Add('     x_msg_data              - '|| x_msg_data, 1);
                                        cln_debug_pub.Add('     x_msg_count             - '|| x_msg_count, 1);
                                END IF;

                                IF (l_Debug_Level <= 2) THEN
                                        cln_debug_pub.Add('====== Exiting m4u_xml_genprocess_out.update_cln_collaborations - Normal : resultout-' || resultout,2);
                                END IF;
                                RETURN; -- Something wrong, simply notify admin and bailout, ...
                        END IF;

                        IF l_wf_error_msg IS NOT NULL THEN

                                IF (l_Debug_Level <= 1) THEN
                                        cln_debug_pub.add('adding error detail to dtl_coll_id - ' || l_dtl_coll_id,1);
                                        cln_debug_pub.add('message - ' || l_wf_error_msg,1);
                                END IF;

                                cln_ch_collaboration_pkg.add_collaboration_messages
                                        (
                                                x_return_status => x_return_status,
                                                x_msg_data      => x_msg_data,
                                                p_dtl_coll_id   => l_dtl_coll_id,
                                                p_dtl_msg       => l_wf_error_type || ':' || l_wf_error_msg
                                        );

                                IF (l_Debug_Level <= 1) THEN
                                        cln_debug_pub.add('error detail added to dtl_coll_id    - ' || l_dtl_coll_id,1);
                                        cln_debug_pub.add('x_return_status                      - ' || x_return_status,1);
                                        cln_debug_pub.add('x_msg_data                           - ' || x_msg_data,1);
                                END IF;

                                ego_uccnet_events_pub.update_event_disposition(
                                                p_api_version       => 1.0,
                                                p_cln_id            => rec_cln_ids.collaboration_id,
                                                p_disposition_code  => 'FAILED',
                                                p_disposition_date  => sysdate,
                                                x_return_status     => x_return_status,
                                                x_msg_count         => x_msg_count,
                                                x_msg_data          => x_msg_data );

                                IF (l_Debug_Level <= 1) THEN
                                        cln_debug_pub.Add('ego_uccnet_events_pub.update_event_disposition - returns', 1);
                                        cln_debug_pub.Add('     x_return_status         - '|| x_return_status, 1);
                                        cln_debug_pub.Add('     x_msg_data              - '|| x_msg_data, 1);
                                        cln_debug_pub.Add('     x_msg_count             - '|| x_msg_count, 1);
                                END IF;

                        END IF;
                END LOOP;

                wf_engine.setItemAttrtext(
                                        itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'M4U_ERROR_TYPE',
                                        avalue     => NULL);

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('M4U_ERROR_TYPE set to NULL', 1);
                END IF;

                wf_engine.setItemAttrtext(
                                        itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'M4U_ERROR_MSG',
                                        avalue     => NULL);

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('M4U_ERROR_MSG set to NULL', 1);
                END IF;

                resultout := wf_engine.eng_completed || ':SUCCESS';

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('==========Exiting  update_batchcollab_setattr ======', 2);
                END IF;

        EXCEPTION
                WHEN OTHERS THEN
                        l_error_code       :=SQLCODE;
                        l_error_msg        :=' Workflow - ' ||  itemtype || '/' || itemkey || ' - ' || SQLERRM;

                        FND_MESSAGE.SET_NAME('CLN','M4U_OUT_UPDATE_COLL_FAILURE');
                        l_fnd_msg_key     := FND_MESSAGE.GET;

                        CLN_NP_PROCESSOR_PKG.NOTIFY_ADMINISTRATOR(
                                                                l_fnd_msg_key
                                                                || ', Error code  - '
                                                                || l_error_code
                                                                || ', Error message - '
                                                                || l_error_msg);

                        IF (l_Debug_Level <= 5) THEN
                                cln_debug_pub.Add('Error '|| l_error_code || ':' || l_error_msg, 5);
                        END IF;

                        IF (l_Debug_Level <= 2) THEN
                                cln_debug_pub.Add('======EXITING m4u_xml_genprocess_out.update_cln_collaborations exception', 2);
                        END IF;

                        wf_Core.context('m4u_wlq_generate','wlq_update_cln_collab',
                                itemtype, itemkey, to_char(actid), funcmode);
                        RAISE;
         END;

        /* set the delivery method, AS2 or direct http or Error*/
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
        PROCEDURE set_aq_correlation(
                itemtype   IN VARCHAR2,
                itemkey    IN VARCHAR2,
                actid      IN NUMBER,
                funcmode   IN VARCHAR2,
                resultout  IN OUT NOCOPY VARCHAR2)
        IS
                l_param_list                    wf_parameter_list_t;
                l_param                         wf_parameter_t;
                l_event                         wf_event_t;
                l_http_correlation_id           VARCHAR2(20);
                l_as2_correlation_id            VARCHAR2(20);
                l_error_correlation_id          VARCHAR2(20);
                l_correlation_id                VARCHAR2(20);
                l_error_type                    VARCHAR2(50);
                l_protocol_profile_value        VARCHAR2(1);
                l_error_code                    VARCHAR2(50);
                l_error_msg                     VARCHAR2(255);
                l_fnd_msg                       VARCHAR2(255);
        BEGIN
                l_http_correlation_id   := 'UCC:HTTP';
                l_as2_correlation_id    := 'UCC:AS2';
                l_error_correlation_id  := 'UCC:ERROR';

                IF (l_Debug_Level <= 2) THEN
                        cln_debug_pub.Add('=========== Entering m4u_xml_genprocess_out.set_aq_correlation =========== ',2);
                END IF;

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Paramters received are'      , 2);
                        cln_debug_pub.Add('itemtype     - ' || itemtype , 2);
                        cln_debug_pub.Add('itemkey      - ' || itemkey  , 2);
                        cln_debug_pub.Add('actid        - ' || actid    , 2);
                        cln_debug_pub.Add('funcmode     - ' || funcmode , 2);
                END IF;



                -- if funcmode is not null then exit
                IF (funcmode <> wf_engine.eng_run) THEN

                        IF (l_Debug_Level <= 1) THEN
                                cln_debug_pub.Add('l_error_type - ' || l_error_type,1);
                        END IF;

                        resultout := wf_engine.eng_null;
                        IF (l_Debug_Level <= 2) THEN
                                cln_debug_pub.Add('====== Exiting m4u_xml_genprocess_out.set_aq_correlation - Normal : resultout-' || resultout,2);
                        END IF;
                        RETURN;
                END IF;


                l_error_type := wf_engine.GetItemAttrText(itemtype, itemkey, 'M4U_ERROR_FLAG',TRUE);


                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('l_error_type - ' || l_error_type,1);
                END IF;

                IF (l_error_type = 'Y') THEN
                        l_correlation_id := l_error_correlation_id;
                ELSE
                        IF UPPER(fnd_profile.value('M4U_USE_HTTP_ADAPTER')) = 'Y' THEN
                                l_correlation_id := l_http_correlation_id;
                        ELSE
                                l_correlation_id := l_as2_correlation_id;
                        END IF;
                END IF;

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('l_correlation_id     - ' || l_correlation_id,1);
                END IF;

                BEGIN
                        l_event := wf_engine.GetItemAttrEvent(itemtype, itemkey, 'ECX_EVENT_MESSAGE');
                EXCEPTION
                        WHEN others THEN
                                NULL;
                END;

                IF (l_event is null ) THEN
                        IF (l_Debug_Level <= 1) THEN
                                cln_debug_pub.Add('ECX_EVENT_MESSAGE is null',1);
                        END IF;
                        wf_core.token('ECX_EVENT_MESSAGE','NULL');
                        wf_core.raise('WFSQL_ARGS');
                END IF;

                l_param_list := l_event.getParameterList();

                FOR p_count in 1..l_param_list.COUNT LOOP
                        IF (l_param_list(p_count).getName() = 'PROTOCOL_TYPE') THEN
                                l_param_list(p_count).setValue(l_correlation_id);
                                IF (l_Debug_Level <= 1) THEN
                                        cln_debug_pub.Add('setting ECX_EVENT_MESSAGE.PROTOCOL_TYPE      - ' || l_correlation_id,1);
                                END IF;
                        EXIT;
                        END IF;
                END LOOP;

                l_event.setParameterList(l_param_list);
                wf_engine.SetItemAttrEvent(itemtype, itemkey, 'ECX_EVENT_MESSAGE', l_event);

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ECX_EVENT_MESSAGE initialised',1);
                END IF;

                wf_engine.SetItemAttrText(itemtype,itemkey,   'M4U_SEND_MODE',l_correlation_id);

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('M4U_SEND_MODE - ' || l_correlation_id,1);
                END IF;


                /* Y or N value if Y use the UCCnet adapter */
                resultout := wf_engine.eng_completed;

                IF (l_Debug_Level <= 2) THEN
                        cln_debug_pub.Add('=========== Exiting m4u_xml_genprocess_out.set_aq_correlation =========== ',2);
                END IF;


          EXCEPTION
                WHEN OTHERS THEN
                        l_error_code       :=SQLCODE;
                        l_error_msg        :=' Workflow - ' ||  itemtype || '/' || itemkey || ' - ' || SQLERRM;

                        FND_MESSAGE.SET_NAME('CLN','M4U_UNEXPECTED_ERROR');
                        l_fnd_msg     := FND_MESSAGE.GET;

                        CLN_NP_PROCESSOR_PKG.NOTIFY_ADMINISTRATOR(l_fnd_msg
                                                || ' in m4u_xml_genprocess_out.Set_AQ_Correlation , Error code - '
                                                || l_error_code
                                                || ', Error message - '
                                                || l_error_msg);


                        IF (l_Debug_Level <= 5) THEN
                                cln_debug_pub.Add('Error                : ' || l_error_code || ':' || l_error_msg, 5);
                        END IF;
                        IF (l_Debug_Level <= 2) THEN
                                cln_debug_pub.Add('=========== Exiting m4u_xml_genprocess_out.set_aq_correlation  - Exception =========== ',2);
                        END IF;

                        Wf_Core.Context('m4u_xml_genprocess_out','set_aq_correlation',
                                itemtype, itemkey, to_char(actid), funcmode);
                        RAISE;
          END;


        -- Name
        --      check_send_method
        -- Purpose
        --      returns send_method to be used
        -- Arguments
        --      itemtype                => WF item type
        --      itemkey                 => WF item key
        --      actid                   => WF act id
        --      funcmode                => WF func mode
        --      resultout               => result param
        -- Notes
        --      None.
        PROCEDURE check_send_method(
                        itemtype   IN VARCHAR2,
                        itemkey    IN VARCHAR2,
                        actid      IN NUMBER,
                        funcmode   IN VARCHAR2,
                        resultout  IN OUT NOCOPY VARCHAR2)
          IS
                l_send_method   VARCHAR2(50);
                l_error_code    VARCHAR2(50);
                l_error_msg             VARCHAR2(255);
                l_fnd_msg               VARCHAR2(255);
          BEGIN
                IF (l_Debug_Level <= 2) THEN
                        cln_debug_pub.Add('=========== Entering m4u_xml_genprocess_out.check_send_method =========== ',2);
                END IF;

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Paramters received are'      , 2);
                        cln_debug_pub.Add('itemtype     - ' || itemtype , 2);
                        cln_debug_pub.Add('itemkey      - ' || itemkey  , 2);
                        cln_debug_pub.Add('actid        - ' || actid    , 2);
                        cln_debug_pub.Add('funcmode     - ' || funcmode , 2);
                END IF;

                -- Do nothing in cancel or timeout mode
                IF (funcmode <> wf_engine.eng_run) THEN
                        resultout := wf_engine.eng_null;
                        IF (l_Debug_Level <= 2) THEN
                                cln_debug_pub.Add('==========Exiting m4u_xml_genprocess_out.check_send_method ======', 2);
                        END IF;
                        RETURN;
                END IF;

                /* Y or N depending on whether validation is required */
                l_send_method := wf_engine.GetItemAttrText(itemtype, itemkey, 'M4U_SEND_MODE',TRUE);

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('l_send_method        - ' || l_send_method, 2);
                END IF;

                resultout := wf_engine.eng_completed||':' || l_send_method;
        EXCEPTION
                WHEN OTHERS THEN
                        l_error_code       :=SQLCODE;
                        l_error_msg        :=' Workflow - ' ||  itemtype || '/' || itemkey || ' - ' || SQLERRM;

                        FND_MESSAGE.SET_NAME('CLN','M4U_UNEXPECTED_ERROR');
                        l_fnd_msg     := FND_MESSAGE.GET;

                        CLN_NP_PROCESSOR_PKG.NOTIFY_ADMINISTRATOR(l_fnd_msg
                                                || ' in m4u_xml_genprocess_out.check_send_method , Error code - '
                                                || l_error_code
                                                || ', Error message - '
                                                || l_error_msg);


                        IF (l_Debug_Level <= 5) THEN
                                cln_debug_pub.Add('Error :' || SQLCODE || ':' || SQLERRM, 5);
                        END IF;
                        IF (l_Debug_Level <= 2) THEN
                                cln_debug_pub.Add('=========== Exiting m4u_xml_genprocess_out.CHECK_SEND_METHOD =========== ',2);
                        END IF;

                        Wf_Core.Context('m4u_xml_genprocess_out','check_send_method',
                                itemtype, itemkey, to_char(actid), funcmode);
                        RAISE;
        END;

        -- Name
        --      dequeue_ucc_message
        -- Purpose
        --      dequeues payload from AQ when correlation is UCC:ERROR|UCC:HTTP
        -- Arguments
        --      itemtype                => WF item type
        --      itemkey                 => WF item key
        --      actid                   => WF act id
        --      funcmode                => WF func mode
        --      resultout               => result param
        -- Notes
        --      Need to make a modification to set QueueName to be used in dequeue
        PROCEDURE dequeue_ucc_message(
                itemtype   IN VARCHAR2,
                itemkey    IN VARCHAR2,
                actid      IN NUMBER,
                funcmode   IN VARCHAR2,
                resultout  IN OUT NOCOPY VARCHAR2)
        IS
                l_ecxmsg                system.ecxmsg;
                l_queue_name            varchar2(80);
                l_dequeue_options       dbms_aq.dequeue_options_t;
                l_message_properties    dbms_aq.message_properties_t;
                l_msgid                 RAW(16);
                l_wait_time             NUMBER;
                l_group_identifier      VARCHAR2(10);
                l_error_code            VARCHAR2(50);
                l_error_msg             VARCHAR2(255);
                l_fnd_msg               VARCHAR2(255);
                l_agent                 wf_agent_t;
                l_event                 wf_event_t;
        BEGIN
                l_ecxmsg                := null;
                l_queue_name            := 'ecx_outbound';
                l_wait_time             := DBMS_AQ.NO_WAIT;

                l_group_identifier      :=  wf_engine.GetItemAttrText(
                                                itemtype,
                                                itemkey,
                                                'M4U_SEND_MODE',
                                                TRUE);

                IF (l_Debug_Level <= 2) THEN
                        cln_debug_pub.Add('=========== Entering m4u_xml_genprocess_out.dequeue_ucc_message =========== ',2);
                END IF;

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Paramters received are'      , 2);
                        cln_debug_pub.Add('itemtype     - ' || itemtype , 2);
                        cln_debug_pub.Add('itemkey      - ' || itemkey  , 2);
                        cln_debug_pub.Add('actid        - ' || actid    , 2);
                        cln_debug_pub.Add('funcmode     - ' || funcmode , 2);
                END IF;

                IF (funcmode <> wf_engine.eng_run) THEN
                        resultout := wf_engine.eng_null;
                        IF (l_Debug_Level <= 2) THEN
                                cln_debug_pub.Add('=========== Exiting m4u_xml_genprocess_out.dequeue_ucc_message =========== ',2);
                        END IF;
                        RETURN;
                END IF;

                BEGIN
                        l_event := wf_engine.GetItemAttrEvent(itemtype, itemkey, 'ECX_EVENT_MESSAGE');
                EXCEPTION
                        WHEN others THEN
                                NULL;
                END;

                IF l_event IS NULL THEN
                        IF (l_Debug_Level <= 2) THEN
                                cln_debug_pub.Add('=========== Exiting m4u_xml_genprocess_out.dequeue_ucc_message, null event =========== ',2);
                        END IF;
                END IF;

                l_agent := l_event.getFromAgent;


                IF l_agent IS NULL THEN
                        IF (l_Debug_Level <= 2) THEN
                                cln_debug_pub.Add('===========  m4u_xml_genprocess_out.dequeue_ucc_message, null agent =========== ',2);
                        END IF;
                ELSE
                        l_queue_name    := l_agent.getName;
                END IF;

                l_dequeue_options.wait          := l_wait_time;
                l_dequeue_options.correlation   := l_group_identifier;

                DBMS_AQ.DEQUEUE(queue_name => l_queue_name,
                        dequeue_options    => l_dequeue_options,
                        message_properties => l_message_properties,
                        payload            => l_ecxmsg,
                        msgid              => l_msgid);

                -- not raising an exception when message is NULL
                IF (l_Debug_Level <= 2) THEN
                        cln_debug_pub.Add('=========== Exiting m4u_xml_genprocess_out.dequeue_ucc_message normal =========== ',2);
                END IF;

                resultout := wf_engine.eng_completed;

        EXCEPTION
                WHEN OTHERS THEN
                        l_error_code       :=SQLCODE;
                        l_error_msg        :=' Workflow - ' ||  itemtype || '/' || itemkey || ' - ' || SQLERRM;

                        FND_MESSAGE.SET_NAME('CLN','M4U_UNEXPECTED_ERROR');
                        l_fnd_msg     := FND_MESSAGE.GET;

                        CLN_NP_PROCESSOR_PKG.NOTIFY_ADMINISTRATOR(l_fnd_msg
                                                || ' in m4u_xml_genprocess_out.dequeue_ucc_message , Error code - '
                                                || l_error_code
                                                || ', Error message - '
                                                || l_error_msg);


                        IF (l_Debug_Level <= 5) THEN
                                cln_debug_pub.Add('Error :' || SQLCODE || ':' || SQLERRM, 5);
                        END IF;
                        IF (l_Debug_Level <= 2) THEN
                                cln_debug_pub.Add('=========== Exiting m4u_xml_genprocess_out.dequeue_ucc_message exception =========== ',2);
                        END IF;

                        resultout := wf_engine.eng_completed;
                        Wf_Core.Context('m4u_xml_genprocess_out','dequeue_ucc_message ',
                                itemtype, itemkey, to_char(actid), funcmode);

        END;


        -- Name
        --      raise_payload_event
        -- Purpose
        --      raises event containing payload
        -- Arguments
        --      itemtype                => WF item type
        --      itemkey                 => WF item key
        --      actid                   => WF act id
        --      funcmode                => WF func mode
        --      resultout               => result param
        -- Notes
        --      This needs to be replace by standard WF_ RAISE EVENT activity
        --      was developed as workaround when WF _RAISE EVENT was not working
        --      problem lies in GETTPXML parameters,
        PROCEDURE raise_payload_event(
                        itemtype   IN VARCHAR2,
                        itemkey    IN VARCHAR2,
                        actid      IN NUMBER,
                        funcmode   IN VARCHAR2,
                        resultout  IN OUT NOCOPY VARCHAR2)
        IS
                l_data_event            wf_event_t;
                l_raise_event_name      VARCHAR2(50);
                l_raise_event_key       VARCHAR2(50);
                l_clob_xml_payload      clob;
                l_event_params          wf_parameter_list_t;
                l_error_code            VARCHAR2(50);
                l_error_msg             VARCHAR2(255);
                l_fnd_msg                       VARCHAR2(255);
        BEGIN

                l_data_event            := null;
                l_clob_xml_payload      := null;

                IF (l_debug_Level <= 2) THEN
                        cln_debug_pub.Add('========= Entering m4u_xml_genprocess_out.raise_payload_event  == ',2);
                END IF;

                -- Parameters received
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('-- Parameters received from Workflow process -- ',1);
                        cln_debug_pub.Add('itemtype             - '||itemtype,  1);
                        cln_debug_pub.Add('itemkey              - '||itemkey,   1);
                        cln_debug_pub.Add('actid                - '||actid,     1);
                        cln_debug_pub.Add('funcmode             - '||funcmode,  1);
                        cln_debug_pub.Add('---------------------------------------------',1);
                END IF;

                -- if funcmode is not null then exit
                IF (funcmode <> wf_engine.eng_run) THEN
                        resultout := wf_engine.eng_null;
                        IF (l_Debug_Level <= 2) THEN
                                cln_debug_pub.Add('====== Exiting raise_payload_event - Normal : resultout-' || resultout,2);
                        END IF;
                        RETURN;
                END IF;

                l_data_event := wf_engine.GetActivityAttrEvent(
                                                itemtype        => itemtype,
                                                itemkey         => itemkey,
                                                actid           => actid,
                                                name            => 'EVENT_DATA');
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('EVENT_DATA obtained',  1);
                END IF;

                l_raise_event_name := wf_engine.GetActivityAttrText(
                                                itemtype        => itemtype,
                                                itemkey         => itemkey,
                                                actid           => actid,
                                                aname           => 'EVENT_NAME',
                                                ignore_notfound => TRUE);
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('EVENT_NAME - ' || l_raise_event_name,  1);
                END IF;

                l_raise_event_key  := wf_engine.GetActivityAttrText(
                                                itemtype        => itemtype,
                                                itemkey         => itemkey,
                                                actid           => actid,
                                                aname           => 'EVENT_KEY',
                                                ignore_notfound => TRUE);

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('EVENT_KEY - ' || l_raise_event_key,  1);
                END IF;

                IF l_raise_event_key IS NULL THEN
                        l_raise_event_key := itemkey;
                END IF;

                l_clob_xml_payload   := l_data_event.getEventData();

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Obtained XML payload as clob',  1);
                END IF;


                l_event_params := wf_parameter_list_t();

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Obtained Event Parameters',  1);
                END IF;

                IF l_clob_xml_payload IS NULL
                THEN
                        resultout := wf_engine.eng_completed || ':FAIL';

                        IF (l_debug_Level <= 2) THEN
                                cln_debug_pub.Add('clob payload is null, exiting rasie_payload_event', 1);
                        END IF;

                        wf_engine.setItemAttrtext(
                                        itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'M4U_ERROR_FLAG',
                                        avalue     => 'Y');

                        IF (l_Debug_Level <= 1) THEN
                                cln_debug_pub.Add('M4U_ERROR_FLAG set to Y',  1);
                        END IF;
                        RETURN;
                END IF;

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('raising payload_event, with key -- ' || l_raise_event_key,2);
                END IF;


                WF_EVENT.raise(
                        p_event_name => l_raise_event_name,
                        p_event_key  => l_raise_event_key,
                        p_event_data => l_clob_xml_payload,
                        p_parameters => l_event_params);

                resultout := wf_engine.eng_completed || ':SUCCESS';

                IF (l_Debug_Level <= 2) THEN
                        cln_debug_pub.Add('====== exiting m4u_xml_genprocess_out.raise_payload_event - normal : resultout-' || resultout,2);
                END IF;

        -- Exception Handling
        EXCEPTION
                WHEN OTHERS THEN
                        l_error_code       :=SQLCODE;
                        l_error_msg        :=' Workflow - ' ||  itemtype || '/' || itemkey || ' - ' || SQLERRM;

                        FND_MESSAGE.SET_NAME('CLN','M4U_UNEXPECTED_ERROR');
                        l_fnd_msg     := FND_MESSAGE.GET;

                        CLN_NP_PROCESSOR_PKG.NOTIFY_ADMINISTRATOR(l_fnd_msg
                                                || ' in m4u_xml_genprocess_out.raise_payload_event , Error code - '
                                                || l_error_code
                                                || ', Error message - '
                                                || l_error_msg);


                        IF (l_Debug_Level <= 5) THEN
                                cln_debug_pub.Add('Error :' || SQLCODE || ':' || SQLERRM, 5);
                        END IF;
                        IF (l_Debug_Level <= 2) THEN
                                cln_debug_pub.Add('=========== ERROR :Exiting m4u_xml_genprocess_out.raise_payload_event =========== ',2);
                        END IF;

                        Wf_Core.Context('m4u_xml_genprocess_out','raise_payload_event',
                                itemtype, itemkey, to_char(actid), funcmode);
                        RAISE;
        END;


        BEGIN
                l_debug_level           := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));
END m4u_xml_genprocess_out;

/
