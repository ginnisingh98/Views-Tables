--------------------------------------------------------
--  DDL for Package Body ITG_BOAPI_WRAPPERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ITG_BOAPI_WRAPPERS" AS
/* ARCS: $Header: itgwrapb.pls 120.7 2006/08/24 06:06:01 pvaddana noship $
 * CVS:  itgwrapb.pls,v 1.52 2003/05/30 00:49:39 klai Exp
 */
  l_debug_level                 NUMBER := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));

  g_collaboration_id            NUMBER;
  g_return_status               VARCHAR2(1);
  g_return_message              VARCHAR2(2000);
  g_doctyp                      VARCHAR2(100);
  g_org                         NUMBER;
  g_clntyp                      VARCHAR2(100);
  g_process_vendor_contact      BOOLEAN;

  g_vinfo_rec                   ITG_SyncSupplierInbound_PVT.vinfo_rec_type;

  FUNCTION describe_return_status(
        p_rstat                 IN VARCHAR2
  ) RETURN VARCHAR2 IS
  BEGIN
        IF p_rstat = FND_API.G_RET_STS_SUCCESS  THEN
                RETURN 'Success';
        ELSIF p_rstat = FND_API.G_RET_STS_ERROR THEN
                RETURN 'Error';
        ELSE /*everything else is unexpected!*/
                RETURN 'Un-expected error';
        END IF;
  END describe_return_status;


  PROCEDURE check_return_status(
        p_name                  IN VARCHAR2,
        p_rstat                 IN VARCHAR2
  )
  IS
  BEGIN
        IF  p_rstat <> FND_API.G_RET_STS_SUCCESS     AND
            p_rstat <> FND_API.G_RET_STS_ERROR       THEN
                g_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        ELSE
                g_return_status := p_rstat;
        END IF;
  EXCEPTION
        WHEN OTHERS THEN
             null;
  END check_return_status;

  /* PUBLIC calls. */

  PROCEDURE Begin_Wrapper(
        p_refid                 IN  VARCHAR2,
        p_org                   IN  NUMBER,
        p_xmlg_xtype            IN  VARCHAR2,
        p_xmlg_xstyp            IN  VARCHAR2,
        p_xmlg_docid            IN  VARCHAR2,
        p_doctyp                IN  VARCHAR2,
        p_clntyp                IN  VARCHAR2,
        p_doc                   IN  VARCHAR2,
        p_rel                   IN  VARCHAR2,
        p_cdate                 IN  DATE
  )
  IS
        l_return_status         VARCHAR2(1);
        l_msg_buff              VARCHAR2(2000);
        l_session_id            NUMBER;
  BEGIN
        g_active                := 1;
        g_return_status         := FND_API.G_RET_STS_SUCCESS;
        g_doctyp                := p_doctyp;
        g_clntyp                := p_clntyp;
        g_org                   := p_org;

        FND_PROFILE.put('FND_AS_MSG_LEVEL_THRESHOLD', 0);

        IF (l_Debug_Level <= 2) THEN
              itg_debug_pub.Add('--- Entering Begin_Wrapper ---' ,2);
        END IF;


        /* 4169685: REMOVE INSTALL DATA INSERTION FROM HR_LOCATIONS TABLE */
        IF NOT itg_x_utils.g_initialized THEN
                g_return_status := FND_API.G_RET_STS_ERROR;
                itg_msg.incorrect_setup;

                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('Missing Trading Partner setup and/or Connector uninitialized.' ,1);
                END IF;
                RETURN;
        END IF;

        -- Remove FND_MSG from every package. Do it once per transaction here.
        FND_MSG_PUB.INITIALIZE;

	  /*
        FND_GLOBAL.apps_initialize(
                user_id      => nvl(fnd_profile.value('ITG_XML_USER'),itg_x_utils.c_user_id),
                resp_id      => itg_x_utils.c_resp_id,
                resp_appl_id => itg_x_utils.c_resp_appl_id
        );*/

	  -- po_acctions.close_po api checks for value of fnd_global.login_id
        -- fnd_global.apps_initialize sets it to -1,
        -- hence calling FND_GLOBAl.INITIALIZE as a workaround.
        -- this resolves the issue with the close_PO API failue
        FND_GLOBAl.INITIALIZE(l_session_id,
                   nvl(fnd_profile.value('ITG_XML_USER'),itg_x_utils.c_user_id),
                   itg_x_utils.c_resp_id,
                   itg_x_utils.c_resp_appl_id,
                   0, -1, 1, -1, -1, -1, -1, null,null,null,null,null,null,-1);

        MO_GLOBAL.init('PO');

        IF p_org IS NOT NULL THEN
                BEGIN
                        FND_Client_Info.set_org_context(p_org);
	 			MO_GLOBAL.set_policy_context('S', p_org); -- MOAC
                EXCEPTION
                        WHEN OTHERS THEN
                                itg_msg.invalid_org(p_org);
                                g_return_status := FND_API.G_RET_STS_ERROR;
                                RAISE FND_API.G_EXC_ERROR;
                END;
        END IF;

        BEGIN
                IF (l_Debug_Level <= 1) THEN
                      itg_debug_pub.Add('Calling create_collaboration ...' ,1);
                END IF;

                CLN_CH_COLLABORATION_PKG.create_collaboration(
                        x_return_status             => l_return_status,
                        x_msg_data                  => l_msg_buff,
                        p_app_id                    => itg_x_utils.c_application_id,
                        p_ref_id                    => p_refid,
                        p_org_id                    => p_org,
                        p_rel_no                    => p_rel,
                        p_doc_no                    => p_doc,
                        p_doc_rev_no                => NULL,          /* NOTE: ??? */
                        p_xmlg_transaction_type     => p_xmlg_xtype,
                        p_xmlg_transaction_subtype  => p_xmlg_xstyp,
                        p_xmlg_document_id          => p_xmlg_docid,
                        p_partner_doc_no            => NULL,          /* NOTE: ??? */
                        p_coll_type                 => p_clntyp,
                        p_tr_partner_type           => itg_x_utils.c_party_type,
                        p_tr_partner_id             => itg_x_utils.g_party_id,
                        p_tr_partner_site           => itg_x_utils.g_party_site_id,
                        p_resend_flag               => 'N',
                        p_resend_count              => 0,
                        p_doc_owner                 => FND_GLOBAL.USER_ID,
                        p_init_date                 => SYSDATE,
                        p_doc_creation_date         => p_cdate,
                        p_doc_revision_date         => NULL,
                        p_doc_type                  => p_doctyp,
                        p_doc_dir                   => 'IN',
                        p_coll_pt                   => itg_x_utils.c_xmlg_coll_pt,
                        p_xmlg_msg_id               => NULL,
                        p_unique1                   => NULL,
                        p_unique2                   => NULL,
                        p_unique3                   => NULL,
                        p_unique4                   => NULL,
                        p_unique5                   => NULL,
                        p_sender_component          => NULL,
                        p_rosettanet_check_required => FALSE,
                        p_xmlg_internal_control_number => p_refid,
                        x_coll_id                   => g_collaboration_id
                );

                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        IF (l_Debug_Level <= 5) THEN
                                itg_debug_pub.Add('Create CLN : ' || l_return_status || l_msg_buff , 5);
                        END IF;

                        itg_msg.cln_failure(substr(l_msg_buff,1,255));
                        g_collaboration_id := 0;
                        itg_msg.unexpected_error('CLN collaboration creation');
                END IF;
        EXCEPTION
                WHEN OTHERS THEN
                        g_collaboration_id := 0;
                        IF (l_Debug_Level <= 6) THEN
                                itg_debug_pub.Add(substr(SQLERRM,1,255), 6);
                        END IF;

                        itg_msg.cln_failure(substr(SQLERRM,1,255));
                        itg_msg.unexpected_error('CLN collaboration creation');
        END;

        check_return_status('Begin_Wrapper', l_return_status);

        IF (l_Debug_Level <= 2) THEN
              itg_debug_pub.Add('--- Exiting Begin_Wrapper ---' ,2);
        END IF;
  EXCEPTION
        WHEN OTHERS THEN
                check_return_status('Begin_Wrapper', FND_API.G_RET_STS_UNEXP_ERROR );
                IF (l_Debug_Level <= 6) THEN
                        itg_debug_pub.Add('BeginWrapper ' || SQLERRM ,6);
                END IF;

                g_collaboration_id := 0;
                itg_msg.unexpected_error('CLN collaboration creation');
  END Begin_Wrapper;




  PROCEDURE End_Wrapper(
        p_refid                 IN  VARCHAR2 := NULL,
        p_doc                   IN  VARCHAR2 := NULL,
        p_cdate                 IN  DATE := SYSDATE,
        x_cln_id                OUT NOCOPY NUMBER,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_return_message        OUT NOCOPY VARCHAR2
  ) IS
  BEGIN
        IF (l_Debug_Level <= 2) THEN
              itg_debug_pub.Add('--- Entering End_Wrapper ---' ,2);
        END IF;

        IF (l_Debug_Level <= 1) THEN
              itg_debug_pub.Add('g_collaboration_id '||g_collaboration_id ,1);
              itg_debug_pub.Add('g_return_status '   ||g_return_status,1);
        END IF;

        x_cln_id           := g_collaboration_id;

        IF g_return_status = FND_API.G_RET_STS_SUCCESS THEN
                x_return_status := '00';
                itg_msg.document_success;
        ELSE
                x_return_status := '99';
        END IF;

        x_return_message   := itg_x_utils.getCBODDescMsg(true);

        Reap_Messages(
                p_refid     => p_refid,
                p_doc       => p_doc,
                p_cdate     => p_cdate
        );

        g_collaboration_id := NULL;
        g_return_status    := NULL;
        g_return_message   := NULL;
        g_org              := NULL; -- don't let org of prev. txn to remain in session state!

        IF (l_Debug_Level <= 2) THEN
              itg_debug_pub.Add('--- Exiting End_Wrapper ---' ,2);
        END IF;
  EXCEPTION
        WHEN OTHERS THEN
                g_collaboration_id := NULL;
                g_return_status    := NULL;
                g_return_message   := NULL;
                g_org              := NULL;
                IF (l_Debug_Level <= 2) THEN
                      itg_debug_pub.Add('--- Exiting End_Wrapper : ERROR---' ,2);
                END IF;
  END End_Wrapper;




  PROCEDURE Reap_Messages(
        p_refid                 IN  VARCHAR2 := NULL,
        p_doc                   IN  VARCHAR2 := NULL,
        p_cdate                 IN  DATE := SYSDATE
  ) IS
        l_inxout                NUMBER;
        l_dtl_id                NUMBER;

        l_status                VARCHAR2(1);
        l_cln_status            VARCHAR2(30);
        l_doc_status            VARCHAR2(30);
        l_message               VARCHAR2(400);
        l_text                  VARCHAR2(4000);
        l_msg_data              VARCHAR2(2000);
  BEGIN
        IF (l_Debug_Level <= 2) THEN
               itg_debug_pub.Add('Entering ITG_BOAPI_Wrappers.Reap_Messages', 2);
        END IF;

        /* g_return_message is not obtained from the FND stack */
        /* It is based on itg_x_utils.getCBODDesc              */
        /* Removed batch management specifi code               */

        IF nvl(g_collaboration_id,0) > 0 THEN
                IF nvl(g_return_status,'x') <> FND_API.G_RET_STS_SUCCESS THEN
                        l_cln_status := 'ERROR';
                        l_doc_status := 'ERROR';
                        l_message    := 'Failure in processing document';
                ELSE
                        l_cln_status := 'COMPLETED';
                        l_doc_status := 'SUCCESS';
                        l_message    := 'Document processed successfully';
                END IF;

                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('l_coll_id            => '||to_char(g_collaboration_id), 1);
                        itg_debug_pub.Add('l_doctyp             => '||g_doctyp,  1);
                        itg_debug_pub.Add('l_cln_status         => '||NVL(l_cln_status, 'NULL'), 1);
                        itg_debug_pub.Add('l_doc_status         => '||NVL(l_doc_status, 'NULL'), 1);
                END IF;

                l_status := FND_API.G_RET_STS_SUCCESS;
                l_msg_data := 'Success';

                CLN_CH_COLLABORATION_PKG.UPDATE_COLLABORATION(
                        x_return_status             => l_status,
                        x_msg_data                  => l_msg_data,
                        p_coll_id                   => g_collaboration_id,
                        p_app_id                    => NULL,
                        p_ref_id                    => p_refid,
                        p_rel_no                    => NULL,
                        p_doc_no                    => p_doc,
                        p_doc_rev_no                => NULL,
                        p_xmlg_transaction_type     => NULL,
                        p_xmlg_transaction_subtype  => NULL,
                        p_xmlg_document_id          => NULL,
                        p_resend_flag               => NULL,
                        p_resend_count              => NULL,
                        p_disposition               => NULL,
                        p_coll_status               => l_cln_status,
                        p_doc_type                  => g_doctyp,
                        p_doc_dir                   => 'IN',
                        p_coll_pt                   => itg_x_utils.c_coll_pt,
                        p_org_ref                   => NULL,
                        p_doc_status                => l_doc_status,
                        p_notification_id           => NULL,
                        p_msg_text                  => l_message,
                        p_xmlg_msg_id               => NULL,
                        p_tr_partner_type           => itg_x_utils.c_party_type,
                        p_tr_partner_id             => itg_x_utils.g_party_id,
                        p_tr_partner_site           => itg_x_utils.g_party_site_id,
                        p_sender_component          => NULL,
                        p_rosettanet_check_required => FALSE,
                        x_dtl_coll_id               => l_dtl_id,
                        p_xmlg_internal_control_number => p_refid,
                        p_doc_creation_date         => p_cdate,
                        p_doc_revision_date         => SYSDATE,
                        p_org_id                    => g_org
                );

                IF nvl(l_status,'x') <> FND_API.G_RET_STS_SUCCESS THEN
                     IF (l_Debug_Level <= 6) THEN
                        itg_debug_pub.Add('CLN update_collaboration retsts> ' || l_status,6);
                        itg_debug_pub.Add('CLN update_collaboration retmsg> ' || l_msg_data,6);
                     END IF;
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSE
                     IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('l_dtl_id  => '||NVL(to_char(l_dtl_id),  'NULL'), 1);
                     END IF;
                END IF;

                /* Now loop through FND messages and add collaboration details*/
                FND_MSG_PUB.get(
                        p_msg_index     => FND_MSG_PUB.G_FIRST,
                        p_encoded       => FND_API.G_FALSE,
                        p_data          => l_text,
                        p_msg_index_out => l_inxout);

                WHILE l_text IS NOT NULL LOOP
                        l_text  := substrb(l_text,1,2000);

                        IF (l_Debug_Level <= 1) THEN
                                itg_debug_pub.Add('l_text               => '|| l_text ,1);
                        END IF;

                        IF l_text IS NOT NULL THEN
                                l_status        := FND_API.G_RET_STS_SUCCESS;
                                CLN_CH_COLLABORATION_PKG.add_collaboration_messages
                                (
                                        x_return_status   => l_status,
                                        x_msg_data        => l_msg_data,
                                        p_dtl_coll_id     => l_dtl_id,
                                        p_ref1            => NULL,
                                        p_ref2            => NULL,
                                        p_ref3            => NULL,
                                        p_ref4            => NULL,
                                        p_ref5            => NULL,
                                        p_dtl_msg         => l_text
                                );

                                IF nvl(l_status,'x') <> FND_API.G_RET_STS_SUCCESS THEN
                                        IF (l_Debug_Level <= 6) THEN
                                                itg_debug_pub.Add('CLN add_collab_msg retsts> ' || l_status ,6);
                                                itg_debug_pub.Add('CLN add_collab_msg retmsg> ' || l_msg_data ,6);
                                        END IF;
                                END IF;
                        END IF;

                        FND_MSG_PUB.get(
                                p_msg_index     => FND_MSG_PUB.G_NEXT,
                                p_encoded       => FND_API.G_FALSE,
                                p_data          => l_text,
                                p_msg_index_out => l_inxout);
                END LOOP;
        END IF;
        /* Delete global message table*/
        FND_MSG_PUB.Delete_Msg;

        IF (l_Debug_Level <= 2) THEN
               itg_debug_pub.Add('Exiting ITG_BOAPI_Wrappers.Reap_Messages', 2);
        END IF;
  EXCEPTION
        WHEN OTHERS THEN
                IF (l_Debug_Level <= 6) THEN
                        itg_debug_pub.Add('Unexpceted error in reap messages - ' || SUBSTRB(SQLERRM,1,1000),6);
                END IF;
                null;
  END Reap_Messages;




  /* Wrap ITG_SyncCOAInbound_PVT from itgvsci?.pls */
  PROCEDURE Sync_FlexValue(
        p_syncind               IN  VARCHAR2,
        p_flex_value            IN  VARCHAR2,
        p_vset_id               IN  NUMBER,
        p_flex_desc             IN  VARCHAR2,
        p_action_date           IN  DATE,
        p_effective_date        IN  DATE,
        p_expiration_date       IN  DATE,
        p_acct_type             IN  VARCHAR2,
        p_enabled_flag          IN  VARCHAR2
  ) IS
        l_return_status         VARCHAR2(1);
        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(2000);
  BEGIN
        IF (l_Debug_Level <= 2) THEN
               itg_debug_pub.Add('Entering ITG_BOAPI_Wrappers.Sync_FlexValue', 2);
        END IF;

        IF g_return_status = FND_API.G_RET_STS_SUCCESS AND
                NOT ITG_OrgEff_PVT.Check_Effective(
                                p_organization_id => g_org,
                                p_cln_doc_type    => g_clntyp,
                                p_doc_direction   => 'S') THEN
                g_return_status := FND_API.G_RET_STS_ERROR;
                ITG_MSG.orgeff_check_failed;
        END IF;

        IF g_return_status = FND_API.G_RET_STS_SUCCESS THEN
                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('wSFV - Calling ITG_SyncCOAInbound_PVT.Sync_FlexValue API' ,1);
                END IF;

                ITG_SyncCOAInbound_PVT.Sync_FlexValue(
                        x_return_status    => l_return_status,
                        x_msg_count        => l_msg_count,
                        x_msg_data         => l_msg_data,
                        p_syncind          => p_syncind,
                        p_flex_value       => p_flex_value,
                        p_vset_id          => p_vset_id,
                        p_flex_desc        => p_flex_desc,
                        p_action_date      => p_action_date,
                        p_effective_date   => p_effective_date,
                        p_expiration_date  => p_expiration_date,
                        p_acct_type        => p_acct_type,
                        p_enabled_flag     => p_enabled_flag
                );
                check_return_status('Sync_FlexValue', l_return_status);
        ELSE
                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('wSFV', 'Skipping ITG_SyncCOAInbound_PVT.Sync_FlexValue API');
                END IF;
        END IF;

        IF (l_Debug_Level <= 2) THEN
               itg_debug_pub.Add('Exiting ITG_BOAPI_Wrappers.Sync_FlexValue', 2);
        END IF;
  EXCEPTION
          WHEN OTHERS THEN
                ITG_Debug.msg('Unexpected error in wrapper(Flex-value sync) - ' || substr(SQLERRM,1,255),true);
                itg_msg.unexpected_error('Flex-value sync');
                g_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                IF (l_Debug_Level <= 6) THEN
                       itg_debug_pub.Add('Exiting ITG_BOAPI_Wrappers.Sync_FlexValue :OTHER ERROR', 6);
                END IF;

  END Sync_FlexValue;



  /* Wrap ITG_SyncExchInbound_PVT from itgvsei?.pls */
  PROCEDURE Process_ExchangeRate(
        p_syncind               IN  VARCHAR2,
        p_quantity              IN  NUMBER,
        p_currency_from         IN  VARCHAR2,
        p_currency_to           IN  VARCHAR2,
        p_factor                IN  VARCHAR2,
        p_sob                   IN  VARCHAR2,
        p_ratetype              IN  VARCHAR2,
        p_creation_date         IN  DATE,
        p_effective_date        IN  DATE
  ) IS
        l_return_status         VARCHAR2(1);
        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(2000);
  BEGIN
        IF (l_Debug_Level <= 2) THEN
               itg_debug_pub.Add('Entering ITG_BOAPI_Wrappers.Process_ExchangeRate', 2);
        END IF;

        IF g_return_status = FND_API.G_RET_STS_SUCCESS AND
                        NOT ITG_OrgEff_PVT.Check_Effective(
                                p_organization_id => g_org,
                                p_cln_doc_type    => g_clntyp,
                                p_doc_direction   => 'S') THEN
                g_return_status := FND_API.G_RET_STS_ERROR;
                ITG_MSG.orgeff_check_failed;
        END IF;

        IF g_return_status = FND_API.G_RET_STS_SUCCESS THEN
                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('wPER - Calling ITG_SyncExchInbound_PVT.Process_ExchangeRate API');
                END IF;

                ITG_SyncExchInbound_PVT.Process_ExchangeRate(
                        x_return_status    => l_return_status,
                        x_msg_count        => l_msg_count,
                        x_msg_data         => l_msg_data,
                        p_syncind          => p_syncind,
                        p_quantity         => p_quantity,
                        p_currency_from    => p_currency_from,
                        p_currency_to      => p_currency_to,
                        p_factor           => p_factor,
                        p_sob              => p_sob,
                        p_ratetype         => p_ratetype,
                        p_creation_date    => p_creation_date,
                        p_effective_date   => p_effective_date
                );
                check_return_status('Process_ExchangeRate', l_return_status);
        ELSE
                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('wPER - Skipping API' ,1);
                END IF;
        END IF;

        IF (l_Debug_Level <= 2) THEN
               itg_debug_pub.Add('Exiting ITG_BOAPI_Wrappers.Process_ExchangeRate', 2);
        END IF;
  EXCEPTION
          WHEN OTHERS THEN
                ITG_Debug.msg('Unexpected error in wrapper(Exchange-rate sync) - ' || substr(SQLERRM,1,255),true);
                itg_msg.unexpected_error('Exchange-rate sync');
                g_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                IF (l_Debug_Level <= 6) THEN
                       itg_debug_pub.Add('Exiting ITG_BOAPI_Wrappers.Process_ExchangeRate : OTHER ERROR', 6);
                END IF;

  END Process_ExchangeRate;



  PROCEDURE Update_PoLine(
        p_api_version           IN         NUMBER,
        p_init_msg_list         IN         VARCHAR2,
        p_commit                IN         VARCHAR2,
        p_validation_level      IN         NUMBER,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2,
        p_po_code               IN         VARCHAR2,
        p_org_id                IN         VARCHAR2,
        p_release_id            IN         VARCHAR2,
        p_line_num              IN         NUMBER,
        p_doc_type              IN         VARCHAR2,
        p_quantity              IN         NUMBER,
        p_amount                IN         NUMBER
  ) IS
  BEGIN
        IF (l_Debug_Level <= 2) THEN
               itg_debug_pub.Add('Entering ITG_BOAPI_Wrappers.Update_PoLine', 2);
        END IF;

        g_org := TO_NUMBER(p_org_id);

        IF NOT ITG_OrgEff_PVT.Check_Effective(
                     p_organization_id => g_org,
                     p_cln_doc_type    => g_clntyp,
                     p_doc_direction   => 'S') THEN
                g_return_status := FND_API.G_RET_STS_ERROR;
                ITG_MSG.orgeff_check_failed;
        END IF;

        IF g_return_status = FND_API.G_RET_STS_SUCCESS THEN
                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('wUPL - Calling ITG_SyncPoInbound_PVT.Update_PoLine API' ,1);
                END IF;


                ITG_SyncPoInbound_PVT.Update_PoLine(
                        x_return_status    => x_return_status,
                        x_msg_count        => x_msg_count,
                        x_msg_data         => x_msg_data,
                        p_po_code          => p_po_code,
                        p_org_id           => p_org_id,
                        p_release_id       => p_release_id,
                        p_line_num         => p_line_num,
                        p_doc_type         => p_doc_type,
                        p_quantity         => p_quantity,
                        p_amount           => p_amount
                );
                check_return_status('Update_PoLine2', x_return_status);
        ELSE
                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('wUPL - Skipping API' ,1);
                END IF;
        END IF;

        IF (l_Debug_Level <= 2) THEN
                 itg_debug_pub.Add('Exiting ITG_BOAPI_Wrappers.Update_PoLine', 2);
        END IF;

  EXCEPTION
          WHEN OTHERS THEN
                ITG_Debug.msg('Unexpected error in wrapper(Purchase order sync) - ' || substr(SQLERRM,1,255),true);
                itg_msg.unexpected_error('Purchase order sync');
                g_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                IF (l_Debug_Level <= 6) THEN
                       itg_debug_pub.Add('Exiting ITG_BOAPI_Wrappers.Update_PoLine : OTHER ERROR', 6);
                END IF;

  END Update_PoLine;



  /* Wrap ITG_SyncSupplierInbound_PVT from itgvssi?.pls (3 procs) */
  PROCEDURE Sync_Vendor(
        p_syncind               IN  VARCHAR2,
        p_name                  IN  VARCHAR2,
        p_onetime               IN  VARCHAR2,
        p_partnerid             IN  VARCHAR2,
        p_active                IN  NUMBER,
        p_currency              IN  VARCHAR2,
        p_dunsnumber            IN  VARCHAR2,
        p_parentid              IN  NUMBER,
        p_paymethod             IN  VARCHAR2,
        p_taxid                 IN  VARCHAR2,
        p_termid                IN  VARCHAR2,
        p_us_flag               IN  VARCHAR2,
        p_date                  IN  DATE,
        p_org			  IN  VARCHAR2 --MOAC
  ) IS
        l_return_status         VARCHAR2(1);
        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(2000);
  BEGIN
        IF (l_Debug_Level <= 2) THEN
               itg_debug_pub.Add('Entering ITG_BOAPI_Wrappers.Sync_Vendor', 2);
        END IF;

        IF g_return_status = FND_API.G_RET_STS_SUCCESS AND
                NOT ITG_OrgEff_PVT.Check_Effective(
                        p_organization_id => g_org,
                        p_cln_doc_type    => g_clntyp,
                        p_doc_direction   => 'S') THEN
                g_return_status := FND_API.G_RET_STS_ERROR;
                ITG_MSG.orgeff_check_failed;
        END IF;

        IF g_return_status = FND_API.G_RET_STS_SUCCESS THEN
                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('wSV - Calling ITG_SyncSupplierInbound_PVT.Sync_Vendor API' ,1);
                END IF;

                g_vinfo_rec := ITG_SyncSupplierInbound_PVT.G_MISS_VINFO_REC;

                ITG_SyncSupplierInbound_PVT.Sync_Vendor(
                        x_return_status    => l_return_status,
                        x_msg_count        => l_msg_count,
                        x_msg_data         => l_msg_data,
                        p_syncind          => p_syncind,
                        p_name             => p_name,
                        p_onetime          => p_onetime,
                        p_partnerid        => p_partnerid,
                        p_active           => p_active,
                        p_currency         => p_currency,
                        p_dunsnumber       => p_dunsnumber,
                        p_parentid         => p_parentid,
                        p_paymethod        => p_paymethod,
                        p_taxid            => p_taxid,
                        p_termid           => p_termid,
                        p_us_flag          => p_us_flag,
                        p_date             => p_date,
                        p_org              => p_org, -- MOAC
                        x_vinfo_rec        => g_vinfo_rec
                );
                check_return_status('Sync_Vendor', l_return_status);
        ELSE
                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('wSV - Skipping API' ,1);
                END IF;
        END IF;

        IF (l_Debug_Level <= 2) THEN
               itg_debug_pub.Add('Exiting ITG_BOAPI_Wrappers.Sync_Vendor', 2);
        END IF;

  EXCEPTION
          WHEN OTHERS THEN
                ITG_Debug.msg('Unexpected error in wrapper(Vendor sync) - ' || substr(SQLERRM,1,255),true);
                itg_msg.unexpected_error('Vendor sync');
                g_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                IF (l_Debug_Level <= 6) THEN
                       itg_debug_pub.Add('Exiting ITG_BOAPI_Wrappers.Sync_Vendor : OTHER ERROR', 6);
                END IF;

  END Sync_Vendor;



  PROCEDURE Sync_VendorSite(
        p_addrline1             IN  VARCHAR2,
        p_addrline2             IN  VARCHAR2,
        p_addrline3             IN  VARCHAR2,
        p_addrline4             IN  VARCHAR2,
        p_city                  IN  VARCHAR2,
        p_country               IN  VARCHAR2,
        p_county                IN  VARCHAR2,
        p_site_code             IN  VARCHAR2,
        p_fax                   IN  VARCHAR2,
        p_zip                   IN  VARCHAR2,
        p_state                 IN  VARCHAR2,
        p_phone                 IN  VARCHAR2,
        p_org                   IN  VARCHAR2,
        p_purch_site            IN  VARCHAR2,
        p_pay_site              IN  VARCHAR2,
        p_rfq_site              IN  VARCHAR2,
        p_pc_site               IN  VARCHAR2,
        p_vat_code              IN  VARCHAR2
  ) IS
        l_return_status         VARCHAR2(1);
        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(2000);
  BEGIN
        IF (l_Debug_Level <= 2) THEN
               itg_debug_pub.Add('Entering ITG_BOAPI_Wrappers.Sync_VendorSite', 2);
        END IF;

        IF g_return_status = FND_API.G_RET_STS_SUCCESS THEN
                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('wSVS - Calling ITG_SyncSupplierInbound_PVT.Sync_VendorSite API',1);
                END IF;

                ITG_SyncSupplierInbound_PVT.Sync_VendorSite(
                        x_return_status    => l_return_status,
                        x_msg_count        => l_msg_count,
                        x_msg_data         => l_msg_data,
                        p_addrline1        => p_addrline1,
                        p_addrline2        => p_addrline2,
                        p_addrline3        => p_addrline3,
                        p_addrline4        => p_addrline4,
                        p_city             => p_city,
                        p_country          => p_country,
                        p_county           => p_county,
                        p_site_code        => p_site_code,
                        p_fax              => p_fax,
                        p_zip              => p_zip,
                        p_state            => p_state,
                        p_phone            => p_phone,
                        p_org              => p_org,
                        p_purch_site       => p_purch_site,
                        p_pay_site         => p_pay_site,
                        p_rfq_site         => p_rfq_site,
                        p_pc_site          => p_pc_site,
                        p_vat_code         => p_vat_code,
                        p_vinfo_rec        => g_vinfo_rec
                );

                --do not check return status since vendor sync is success
                g_process_vendor_contact := false;
                IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                        g_process_vendor_contact := true;
                END IF;
        ELSE
                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('wSVS - Skipping API', 1);
                END IF;
        END IF;

        IF (l_Debug_Level <= 2) THEN
               itg_debug_pub.Add('Exiting ITG_BOAPI_Wrappers.Sync_VendorSite', 2);
        END IF;

  EXCEPTION
        WHEN OTHERS THEN
                ITG_Debug.msg('Unexpected error in wrapper(Vendor-site sync) - ' || substr(SQLERRM,1,255),true);
                itg_msg.unexpected_error('Vendor-site sync');
                g_process_vendor_contact := false;

                IF (l_Debug_Level <= 6) THEN
                       itg_debug_pub.Add('Exiting ITG_BOAPI_Wrappers.Sync_VendorSite : OTHER ERROR', 6);
                END IF;

  END Sync_VendorSite;




  PROCEDURE Sync_VendorContact(
        p_title                 IN  VARCHAR2,
        p_first_name            IN  VARCHAR2,
        p_middle_name           IN  VARCHAR2,
        p_last_name             IN  VARCHAR2,
        p_phone                 IN  VARCHAR2,
        p_site_code             IN  VARCHAR2
  ) IS
        l_return_status         VARCHAR2(1);
        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(2000);
  BEGIN
        IF (l_Debug_Level <= 2) THEN
               itg_debug_pub.Add('Entering ITG_BOAPI_Wrappers.Sync_VendorContact', 2);
        END IF;

        IF g_return_status = FND_API.G_RET_STS_SUCCESS and g_process_vendor_contact THEN
                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('wSVC - Calling ITG_SyncSupplierInbound_PVT.Sync_VendorContact API', 1);
                END IF;

                ITG_SyncSupplierInbound_PVT.Sync_VendorContact(
                        x_return_status    => l_return_status,
                        x_msg_count        => l_msg_count,
                        x_msg_data         => l_msg_data,
                        p_title            => p_title,
                        p_first_name       => p_first_name,
                        p_middle_name      => p_middle_name,
                        p_last_name        => p_last_name,
                        p_phone            => p_phone,
                        p_site_code        => p_site_code,
                        p_vinfo_rec        => g_vinfo_rec
                );

                --do not check return status since vendor sync is success
        ELSE
                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('wSVC - Skipping ITG_SyncSupplierInbound_PVT.Sync_VendorContact API' ,1);
                END IF;
        END IF;

        IF (l_Debug_Level <= 2) THEN
               itg_debug_pub.Add('Exiting ITG_BOAPI_Wrappers.Sync_VendorContact', 2);
        END IF;

  EXCEPTION
        WHEN OTHERS THEN
                ITG_Debug.msg('Unexpected error in wrapper(Vendor-contact sync) - ' || substr(SQLERRM,1,255),true);
                itg_msg.unexpected_error('Vendor-contact sync');
                g_process_vendor_contact := false;

                IF (l_Debug_Level <= 6) THEN
                       itg_debug_pub.Add('Exiting ITG_BOAPI_Wrappers.Sync_VendorContact : OTHER ERROR', 6);
                END IF;

  END Sync_VendorContact;



  /* Wrap ITG_SyncItemInbound_PVT from itgvsii?.pls */
  PROCEDURE Sync_Item(
        p_syncind               IN  VARCHAR2,
        p_org_id                IN  NUMBER,
        p_hazrdmatl             IN  VARCHAR2,
        p_create_date           IN  DATE,
        p_item                  IN  VARCHAR2,
        p_uom                   IN  VARCHAR2,
        p_itemdesc              IN  VARCHAR2,
        p_itemstatus            IN  VARCHAR2,
        p_itemtype              IN  VARCHAR2,
        p_rctrout               IN  VARCHAR2,
        p_commodity1            IN  VARCHAR2,
        p_commodity2            IN  VARCHAR2
  ) IS
        l_return_status         VARCHAR2(1);
        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(2000);
  BEGIN
        IF (l_Debug_Level <= 2) THEN
               itg_debug_pub.Add('Entering ITG_BOAPI_Wrappers.Sync_Item', 2);
        END IF;

        g_org := p_org_id;
        IF g_return_status = FND_API.G_RET_STS_SUCCESS AND
                NOT ITG_OrgEff_PVT.Check_Effective(
                         p_organization_id => g_org,
                         p_cln_doc_type    => g_clntyp,
                         p_doc_direction   => 'S') THEN
                  g_return_status := FND_API.G_RET_STS_ERROR;
                  ITG_MSG.orgeff_check_failed;
        END IF;

        IF g_return_status = FND_API.G_RET_STS_SUCCESS THEN
                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('wSI - Calling ITG_SyncItemInbound_PVT.Sync_Item API' ,1);
                END IF;


                ITG_SyncItemInbound_PVT.Sync_Item(
                        x_return_status    => l_return_status,
                        x_msg_count        => l_msg_count,
                        x_msg_data         => l_msg_data,
                        p_syncind          => p_syncind,
                        p_org_id           => p_org_id,
                        p_hazrdmatl        => p_hazrdmatl,
                        p_create_date      => p_create_date,
                        p_item             => p_item,
                        p_uom              => p_uom,
                        p_itemdesc         => p_itemdesc,
                        p_itemstatus       => p_itemstatus,
                        p_itemtype         => p_itemtype,
                        p_rctrout          => p_rctrout,
                        p_commodity1       => p_commodity1,
                        p_commodity2       => p_commodity2
                );
                check_return_status('Sync_Item', l_return_status);
        ELSE
                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('wSI - Skipping API' ,1);
                END IF;
        END IF;

        IF (l_Debug_Level <= 2) THEN
               itg_debug_pub.Add('Exiting ITG_BOAPI_Wrappers.Sync_Item', 2);
        END IF;

  EXCEPTION
          WHEN OTHERS THEN
                ITG_Debug.msg('Unexpected error in wrapper(Item sync) - ' || substr(SQLERRM,1,255),true);
                itg_msg.unexpected_error('Item sync');
                g_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                IF (l_Debug_Level <= 6) THEN
                       itg_debug_pub.Add('Exiting ITG_BOAPI_Wrappers.Sync_Item : OTHER ERROR', 6);
                END IF;
  END Sync_Item;


  PROCEDURE Process_PoNumber(
        p_reqid            IN  NUMBER,
        p_reqlinenum       IN  NUMBER,
        p_poid             IN  NUMBER,
        p_org              IN  NUMBER
  ) IS
        l_return_status    VARCHAR2(1);
        l_msg_count        NUMBER;
        l_msg_data         VARCHAR2(2000);
  BEGIN
        IF (l_Debug_Level <= 2) THEN
               itg_debug_pub.Add('Entering ITG_BOAPI_Wrappers.Process_PoNumber', 2);
        END IF;

        g_org := p_org;
        IF g_return_status = FND_API.G_RET_STS_SUCCESS AND
                NOT ITG_OrgEff_PVT.Check_Effective(
                                p_organization_id => g_org,
                                p_cln_doc_type    => g_clntyp,
                                p_doc_direction   => 'S') THEN
               g_return_status := FND_API.G_RET_STS_ERROR;
               ITG_MSG.orgeff_check_failed;
        END IF;


        IF g_return_status = FND_API.G_RET_STS_SUCCESS THEN
                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('wPPN - Calling API' ,1);
                END IF;

                ITG_SyncFieldInbound_PVT.Process_PoNumber(
                        x_return_status    => l_return_status,
                        x_msg_count        => l_msg_count,
                        x_msg_data         => l_msg_data,

                        p_reqid            => p_reqid,
                        p_reqlinenum       => p_reqlinenum,
                        p_poid             => p_poid,
                        p_org              => p_org
                );
                check_return_status('Process_PoNumber', l_return_status);
        ELSE
                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('wPPN - Skipping API' ,1);
                END IF;
        END IF;

        IF (l_Debug_Level <= 2) THEN
               itg_debug_pub.Add('Exiting ITG_BOAPI_Wrappers.Process_PoNumber', 2);
        END IF;
  EXCEPTION
          WHEN OTHERS THEN
                ITG_Debug.msg('Unexpected error in wrapper(Field sync) - ' || substr(SQLERRM,1,255),true);
                itg_msg.unexpected_error('Field sync');
                g_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                IF (l_Debug_Level <= 6) THEN
                       itg_debug_pub.Add('Exiting ITG_BOAPI_Wrappers.Process_PoNumber : OTHER ERROR', 6);
                END IF;
  END Process_PoNumber;



  /* Wrap ITG_SyncUOMInbound_PVT from itgvsui?.pls */
  PROCEDURE Sync_UOM_ALL(
        p_task                  IN  VARCHAR2,
        p_syncind               IN  VARCHAR2,
        p_uom                   IN  VARCHAR2,
        p_uomcode               IN  VARCHAR2,
        p_uomclass              IN  VARCHAR2,
        p_buomflag              IN  VARCHAR2,
        p_description           IN  VARCHAR2,
        p_defconflg             IN  VARCHAR2,
        p_fromcode              IN  VARCHAR2,
        p_touomcode             IN  VARCHAR2,
        p_itemid                IN  NUMBER,
        p_fromfactor            IN  VARCHAR2,
        p_tofactor              IN  VARCHAR2,
        p_dt_creation           IN  DATE,
        p_dt_expiration         IN  DATE
  ) IS
        l_return_status         VARCHAR2(1);
        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(2000);

  BEGIN
        IF (l_Debug_Level <= 2) THEN
               itg_debug_pub.Add('Entering ITG_BOAPI_Wrappers.Sync_UOM_ALL', 2);
        END IF;

        IF NOT ITG_OrgEff_PVT.Check_Effective(
                p_organization_id => g_org,
                p_cln_doc_type    => g_clntyp,
                p_doc_direction   => 'S') THEN

                g_return_status := FND_API.G_RET_STS_ERROR;
                ITG_MSG.orgeff_check_failed;
        END IF;

        IF g_return_status = FND_API.G_RET_STS_SUCCESS THEN
                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('wSUA - Calling ITG_SyncUOMInbound_PVT.Sync_UOM_All API' ,1);
                END IF;

                ITG_SyncUOMInbound_PVT.Sync_UOM_All(
                        x_return_status    => l_return_status,
                        x_msg_count        => l_msg_count,
                        x_msg_data         => l_msg_data,
                        p_task             => p_task,
                        p_syncind          => p_syncind,
                        p_uom              => p_uom,
                        p_uomcode          => p_uomcode,
                        p_uomclass         => p_uomclass,
                        p_buomflag         => p_buomflag,
                        p_description      => p_description,
                        p_defconflg        => p_defconflg,
                        p_fromcode         => p_fromcode,
                        p_touomcode        => p_touomcode,
                        p_itemid           => p_itemid,
                        p_fromfactor       => p_fromfactor,
                        p_tofactor         => p_tofactor,
                        p_dt_creation      => p_dt_creation,
                        p_dt_expiration    => p_dt_expiration
                );
                check_return_status('Sync_UOM_ALL', l_return_status);
        ELSE
                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('wSUA - Skipping ITG_SyncUOMInbound_PVT.Sync_UOM_All API' ,1);
                END IF;
        END IF;

        IF (l_Debug_Level <= 2) THEN
               itg_debug_pub.Add('Exiting ITG_BOAPI_Wrappers.Sync_UOM_ALL', 2);
        END IF;
  EXCEPTION
        WHEN OTHERS THEN
                ITG_Debug.msg('Unexpected error in wrapper(UOM sync) - ' || substr(SQLERRM,1,255),true);
                itg_msg.unexpected_error('UOM sync');
                g_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                IF (l_Debug_Level <= 6) THEN
                       itg_debug_pub.Add('Exiting ITG_BOAPI_Wrappers.Sync_UOM_ALL : OTHER ERROR', 6);
                END IF;
  END Sync_UOM_ALL;

BEGIN
        g_active := 0;
END ITG_BOAPI_Wrappers;

/
