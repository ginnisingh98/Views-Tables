--------------------------------------------------------
--  DDL for Package Body M4R_OM_CONF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."M4R_OM_CONF_PKG" as
/* $Header: M4ROMCFB.pls 120.3 2006/03/02 06:10:56 kkram noship $ */


--  Package
--      M4R_OM_CONF_PKG
--
--  Purpose
--      Body of package M4R_OM_CONF_PKG.
--
--  History
--      May-14-2005        Ambuj Chaudhary     Created








-- Start of comments
--        API name         : GET_OM_CONF_PARAMS
--        Type             : Private
--        Pre-reqs         : None.
--        Function         : Sets the necessary parameters for the ECX Send Document.
--        Version          : Current version         1.0
--                           Initial version         1.0
--        Notes            : This procedure is called from workflow(M4RPOCO).
-- End of comments

l_debug_level        NUMBER := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));
  PROCEDURE GET_OM_CONF_PARAMS(p_itemtype               IN              VARCHAR2,
                                p_itemkey                IN              VARCHAR2,
                                p_actid                  IN              NUMBER,
                                p_funcmode               IN              VARCHAR2,
                                x_resultout              IN OUT NOCOPY   VARCHAR2) IS
   l_transaction_type            VARCHAR2(240);
   l_transaction_subtype         VARCHAR2(240);
   l_document_direction          VARCHAR2(240);
   l_party_id                    NUMBER;
   l_party_site_id               NUMBER;
   l_party_type                  VARCHAR2(30);
   l_return_code                 PLS_INTEGER;
   l_errmsg                      VARCHAR2(2000);
   l_result                      BOOLEAN;
   l_error_code                  NUMBER;
   l_error_msg                   VARCHAR2(1000);
   l_customer_trx_id             NUMBER;
   l_proprietary_docid           VARCHAR2(2000);
   l_inv_date                    DATE;
   l_canonical_date              VARCHAR2(100);
   l_doc_transfer_id             NUMBER;
   l_document_id                 VARCHAR2(100);
   l_ntfyinvc_seq                NUMBER;
   l_organization_id             NUMBER;
   l_trx_number                  VARCHAR2(100);
   l_eventkey                    VARCHAR2(100);
   l_transaction_type_passed_in  VARCHAR2(100);
   BEGIN
       IF (l_debug_level <= 1) THEN
         cln_debug_pub.Add('ENTERING GET_OM_CONF_PARAMS', 1);
         cln_debug_pub.Add('With the following parameters:', 1);
         cln_debug_pub.Add('itemtype:'   || p_itemtype, 1);
         cln_debug_pub.Add('itemkey:'    || p_itemkey, 1);
         cln_debug_pub.Add('actid:'      || p_actid, 1);
         cln_debug_pub.Add('funcmode:'   || p_funcmode, 1);
         cln_debug_pub.Add('resultout:'  || x_resultout, 1);
         cln_debug_pub.Add('party_id:'    || l_party_id, 1);
         cln_debug_pub.Add('party_site_id:'      || l_party_site_id, 1);
         cln_debug_pub.Add('doc_transfer_id:'      || l_doc_transfer_id, 1);
         cln_debug_pub.Add('party_type:'      || l_party_type, 1);
       END IF;
       l_document_direction := 'OUT';
       l_party_type := 'C';
       l_result := FALSE;
       -- Do nothing in cancel or timeout mode
       IF (p_funcmode <> wf_engine.eng_run) THEN
           x_resultout := wf_engine.eng_null;
           return; -- do not raise the exception as it would end the workflow
       END IF;
       -- Retrieve Activity Attributes
       l_party_site_id  := Wf_Engine.GetActivityAttrText(p_itemtype, p_itemkey, p_actid, 'ECX_PARTY_SITE_ID');
       l_doc_transfer_id  := Wf_Engine.GetActivityAttrText(p_itemtype, p_itemkey, p_actid, 'ECX_DOCUMENT_ID');
	   l_transaction_type_passed_in :=  Wf_Engine.GetActivityAttrText(p_itemtype, p_itemkey, p_actid, 'PARAMETER3');


       -- Get party id, party site id, org_id
       BEGIN
            SELECT party_id
            INTO l_party_id
            FROM hz_party_sites
            WHERE party_site_id = l_party_site_id;
        EXCEPTION
             WHEN OTHERS THEN
               IF (l_debug_level <= 1) THEN
                     cln_debug_pub.Add('Exception - Query for Party ID failed', 1);
               END IF;
        END;

		IF (l_debug_level <= 1) THEN
          cln_debug_pub.Add('GET_OM_CONF_PARAMS: Parameter Lookups Completed', 1);
          cln_debug_pub.Add('With the following parameters:', 1);
          cln_debug_pub.Add('party_id:'    || l_party_id, 1);
          cln_debug_pub.Add('party_site_id:'      || l_party_site_id, 1);
          cln_debug_pub.Add('doc_transfer_id:'      || l_doc_transfer_id, 1);
	      cln_debug_pub.Add('party_type:'      || l_party_type, 1);
        END IF;

        IF (l_debug_level <= 1) THEN
             cln_debug_pub.Add('XML Trading Partner Setup Check Succeeded', 1);
        END IF;

		IF (l_transaction_type_passed_in ='POI') THEN
		     l_transaction_type := 'ONT';
			 l_transaction_subtype :='POA';
	    ELSIF (l_transaction_type_passed_in = 'CHO') THEN
		     l_transaction_type := 'M4R';
			 l_transaction_subtype :='CHANGEPO_CONF';
		ELSIF (l_transaction_type_passed_in = 'CPO') THEN
		      l_transaction_type := 'M4R';
			  l_transaction_subtype := 'CANCELPO_CONF';
		END IF;


		 wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'ECX_TRANSACTION_TYPE', l_transaction_type);
         IF (l_debug_level <= 1) THEN
            cln_debug_pub.Add('ECX_TRANSACTION_TYPE'|| l_transaction_type, 1);
         END IF;
         wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'ECX_TRANSACTION_SUBTYPE', l_transaction_subtype);
         IF (l_debug_level <= 1) THEN
            cln_debug_pub.Add('ECX_TRANSACTION_SUBTYPE'|| l_transaction_subtype, 1);
         END IF;
         wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'ECX_PARTY_ID', l_party_id);
         IF (l_debug_level <= 1) THEN
            cln_debug_pub.Add('ECX_PARTY_ID'|| l_party_id, 1);
         END IF;
         wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'ECX_PARTY_SITE_ID', l_party_site_id);
         IF (l_debug_level <= 1) THEN
            cln_debug_pub.Add('ECX_PARTY_SITE_ID'|| l_party_site_id, 1);
         END IF;
         wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'ECX_PARTY_TYPE', l_party_type);
         IF (l_debug_level <= 1) THEN
            cln_debug_pub.Add('ECX_PARTY_TYPE'|| l_party_type, 1);
         END IF;
         wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'ECX_DOCUMENT_ID', l_doc_transfer_id);
         IF (l_debug_level <= 1) THEN
            cln_debug_pub.Add('ECX_DOCUMENT_ID'|| l_doc_transfer_id, 1);
         END IF;


	     l_eventkey := p_itemkey;
         wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'EVENTKEY',l_eventkey);
         IF (l_debug_level <= 1) THEN
            cln_debug_pub.Add('EVENTKEY'|| l_eventkey, 1);
         END IF;
         -- Reached Here. Successful execution.
         x_resultout := 'SUCCESS';
         IF (l_debug_level <= 1) THEN
            cln_debug_pub.Add('Result out '|| x_resultout, 1);
         END IF;
         IF (l_debug_level <= 2) THEN
            cln_debug_pub.Add('EXITING GET_OM_CONF_PARAMS Successfully', 2);
         END IF;

   EXCEPTION
      WHEN OTHERS THEN
         l_error_code := SQLCODE;
         l_error_msg  := SQLERRM;
         IF (l_debug_level <= 1) THEN
            cln_debug_pub.Add('Exception ' || ':'  || l_error_code || ':' || l_error_msg, 1);
         END IF;
         x_resultout := 'ERROR';
         IF (l_debug_level <= 1) THEN
            cln_debug_pub.Add('Result out '|| x_resultout, 1);
         END IF;
         IF (l_debug_level <= 1) THEN
           cln_debug_pub.Add('Exiting GET_OM_CONF_PARAMS with Error', 1);
         END IF;

   END GET_OM_CONF_PARAMS;

-- Start of comments
--        API name         : IS_OAG_OR_ROSETTANET
--        Type             : Private
--        Pre-reqs         : None.
--        Function         : Checks whether the message is OAG or Rosettanet and return True if OAG and False if RosettaNet.
--        Version          : Current version         1.0
--                           Initial version         1.0
--        Notes            : This procedure is called from workflow(OEOA).
-- End of comments

   PROCEDURE IS_OAG_OR_ROSETTANET(p_itemtype               IN              VARCHAR2,
                                p_itemkey                IN              VARCHAR2,
                                p_actid                  IN              NUMBER,
                                p_funcmode               IN              VARCHAR2,
                                x_resultout              IN OUT NOCOPY   VARCHAR2) IS
L_PARTY_SITE_ID VARCHAR2(100);
L_PARTY_ID VARCHAR2(100);
L_STANDARD_CODE VARCHAR2(100);
l_eventkey VARCHAR2(100);
l_error_code                  NUMBER;
l_error_msg                   VARCHAR2(1000);
   BEGIN
	IF (l_debug_level <= 1) THEN
         cln_debug_pub.Add('ENTERING M4R_OM_CONF_PKG.IS_OAG_OR_ROSETTANET',1);
         cln_debug_pub.Add('With the following parameters:', 1);
         cln_debug_pub.Add('itemtype:'   || p_itemtype, 1);
         cln_debug_pub.Add('itemkey:'    || p_itemkey, 1);
         cln_debug_pub.Add('actid:'      || p_actid, 1);
         cln_debug_pub.Add('funcmode:'   || p_funcmode, 1);
         cln_debug_pub.Add('resultout:'  || x_resultout, 1);
	END IF;
       -- Retrieve Activity Attributes
       l_party_site_id  := Wf_Engine.GetActivityAttrText(p_itemtype, p_itemkey, p_actid, 'ECX_PARTY_SITE_ID');
       l_party_id       := Wf_Engine.GetActivityAttrText(p_itemtype, p_itemkey, p_actid, 'ECX_PARTY_ID');

       select standard_code
       into l_standard_code
       from ecx_tp_details_v
       where tp_header_id = (select tp_header_id from ecx_tp_headers
                             where party_id = l_party_id and
                             party_site_id = l_party_site_id) and
       transaction_type ='ONT' and transaction_subtype = 'POA';

	if (l_standard_code = 'OAG') then
        	x_resultout := 'COMPLETE:T';  	-- Reached Here. Successful execution.
	else
		x_resultout := 'COMPLETE:F';
	    l_eventkey :=p_itemkey;
        wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'EVENTKEY',l_eventkey);
                 IF (l_debug_level <= 1) THEN
                 cln_debug_pub.Add('EVENTKEY: '|| l_eventkey, 1);
                 END IF;
	end if;

	IF (l_debug_level <= 2) THEN
        cln_debug_pub.Add('EXITING IS_OAG_OR_ROSETTANET Successfully', 2);
    END IF;

   EXCEPTION
      WHEN OTHERS THEN
         l_error_code := SQLCODE;
         l_error_msg  := SQLERRM;
         IF (l_debug_level <= 1) THEN
            cln_debug_pub.Add('Exception ' || ':'  || l_error_code || ':' || l_error_msg, 1);
         END IF;
         x_resultout := 'ERROR';
         IF (l_debug_level <= 1) THEN
            cln_debug_pub.Add('Result out '|| x_resultout, 1);
         END IF;
         IF (l_debug_level <= 1) THEN
           cln_debug_pub.Add('Exiting IS_OAG_OR_ROSETTANET with Error', 1);
         END IF;
END IS_OAG_OR_ROSETTANET;

   FUNCTION UPDATE_CH_OM_EVENT_SUB(
        p_subscription_guid             IN RAW,
        p_event                         IN OUT NOCOPY WF_EVENT_T
   ) RETURN VARCHAR2
   IS
      l_evt_parameters                  wf_parameter_list_t;
      l_xmlg_txn_type                   VARCHAR2(100);
      l_xmlg_txn_subtype                VARCHAR2(100);
      l_tr_partner_id                   VARCHAR2(100);
      l_tr_partner_site                 VARCHAR2(100);
      l_standard                        VARCHAR2(100);
      l_return_tmp                      VARCHAR2(100);
      l_processing_stage                VARCHAR2(100);
   BEGIN
      IF (l_Debug_Level <= 2) THEN
              cln_debug_pub.Add('==========ENTERING UPDATE_CH_OM_EVENT_SUB===========', 2);
      END IF;

      l_evt_parameters := p_event.getParameterList();

      IF (l_Debug_Level <= 1) THEN
              cln_debug_pub.Add('----------- PARAMETERS OBTAINED ----------', 1);
      END IF;
      l_xmlg_txn_type:= WF_EVENT.getValueForParameter('XMLG_INTERNAL_TXN_TYPE',l_evt_parameters);
      IF (l_Debug_Level <= 1) THEN
              cln_debug_pub.Add('XMLG_INTERNAL_TXN_TYPE: '||l_xmlg_txn_type, 1);
      END IF;
      l_xmlg_txn_subtype:= WF_EVENT.getValueForParameter('XMLG_INTERNAL_TXN_SUBTYPE',l_evt_parameters);
      IF (l_Debug_Level <= 1) THEN
              cln_debug_pub.Add('XMLG_INTERNAL_TXN_SUBTYPE: '||l_xmlg_txn_subtype, 1);
      END IF;
      l_processing_stage:= WF_EVENT.getValueForParameter('PROCESSING_STAGE',l_evt_parameters);
      IF (l_Debug_Level <= 1) THEN
              cln_debug_pub.Add('PROCESSING_STAGE: '||l_processing_stage, 1);
      END IF;

      IF (l_xmlg_txn_type = 'ONT' and l_xmlg_txn_subtype = 'POA' and l_processing_stage = 'OUTBOUND_SENT') THEN
		IF (l_Debug_Level <= 1) THEN
		      cln_debug_pub.Add('Getting the Message Standard', 1);
		END IF;

		l_tr_partner_id               := WF_EVENT.getValueForParameter('TRADING_PARTNER_ID',l_evt_parameters);
		IF (l_Debug_Level <= 1) THEN
		      cln_debug_pub.Add('Trading Partner ID              ----'||l_tr_partner_id, 1);
		END IF;

		l_tr_partner_site             := WF_EVENT.getValueForParameter('TRADING_PARTNER_SITE',l_evt_parameters);
		IF (l_Debug_Level <= 1) THEN
		      cln_debug_pub.Add('Trading Partner Site            ----'||l_tr_partner_site, 1);
		END IF;

		BEGIN
			SELECT standard_code
			into l_standard
			FROM ecx_tp_details_v
			WHERE tp_header_id = (SELECT tp_header_id FROM ecx_tp_headers
								WHERE party_id = l_tr_partner_id
								AND party_site_id = l_tr_partner_site
								AND party_type = 'C')
			  AND transaction_type ='ONT'
			  AND transaction_subtype = 'POA';
		EXCEPTION
		      WHEN OTHERS THEN
			-- Nothing to do
			IF (l_Debug_Level <= 4) THEN
			      cln_debug_pub.Add('In valid paramerers passed to the event', 4);
			END IF;
		END;

		IF l_standard = 'ROSETTANET' THEN
		      -- For rosettan net standard this event shoudl be ignored
		      IF (l_Debug_Level <= 2) THEN
			      cln_debug_pub.Add('==========EXITING UPDATE_CH_OM_EVENT_SUB WITHOUT UPDATING COLLABORATION HISTORY ===========', 2);
		      END IF;
		      RETURN 'SUCCESS';
		END IF;
      END IF;

      -- If the control reaches here, it mesans that collaboration history needs to be updated
      l_return_tmp := CLN_CH_EVENT_SUBSCRIPTION_PKG.ADD_COLLABORATION_EVENT_SUB(p_subscription_guid,p_event);

      IF (l_Debug_Level <= 2) THEN
              cln_debug_pub.Add('==========EXITING UPDATE_CH_OM_EVENT_SUB===========', 2);
      END IF;
      RETURN 'SUCCESS';
   END;

END M4R_OM_CONF_PKG;

/
