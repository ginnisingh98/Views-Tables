--------------------------------------------------------
--  DDL for Package Body EDR_FWK_VERIFY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDR_FWK_VERIFY" AS
/* $Header: EDRFWKVB.pls 120.0.12000000.1 2007/01/18 05:53:09 appldev ship $


/* Verify if a notificaiton is Require or Not */

PROCEDURE CHECK_REQUIREMENT
	(
	 p_itemtype   IN VARCHAR2,
      	 p_itemkey    IN VARCHAR2,
      	 p_actid      IN NUMBER,
         p_funcmode   IN VARCHAR2,
         p_resultout  OUT NOCOPY VARCHAR2
	) IS

        L_event_key varchar2(240);
        l_fwk_test_no varchar2(200);
        l_requester varchar2(240);
        l_count number;
 Cursor c1 is select count(*) from fnd_attached_documents
 where ENTITY_NAME='EDR_FWK_TEST_B' and
      pk1_value=l_event_key;
BEGIN
   --Bug 4073809 : start
   L_event_key := wf_engine.GETITEMATTRTEXT(itemtype => p_itemtype,
                                             itemkey => p_itemkey,
                                             aname => 'EVENT_KEY');
   --Bug 4073809 : end

   -- Bug : 3499311 Start - Specified Number Format in TO_NUMBER
   Select fwk_test_no,last_updated_by into l_fwk_test_no,l_requester from edr_fwk_test_vl
    where fwk_test_id = to_number(l_event_key,'999999999999.999999');
   -- Bug : 3499311 - End
   select user_name into l_requester from fnd_user
         where user_id=l_requester;

   wf_engine.setitemattrtext(itemtype => p_itemtype,
                            itemkey => p_itemkey,
                            aname => 'FWK_TEST_NO',
                            avalue => l_fwk_test_no);
   wf_engine.setitemattrtext(itemtype => p_itemtype,
                            itemkey => p_itemkey,
                            aname => 'REQUESTER',
                            avalue => l_requester);

   /* set Attachment Attribute */
  /* Bug Fix 3060818. Create Attachments attribute only if a Valid Attachment is available */
 /* Begin Bug Fix 3060818 */
   open c1;
    fetch c1 into l_count;
   close c1;
  if l_count > 0 THEN
    wf_engine.setitemattrtext(itemtype => p_itemtype,
                           itemkey => p_itemkey,
                           aname => 'ATTACHMENTS',
			   --Bug 4006844: Start
                           avalue => 'FND:entity=EDR_FWK_TEST_B'||'&'||'pk1name=FWK_TEST_ID'||'&'||'pk1value='||l_event_key||'&'||'categories=ERES');
			   --Bug 4006844: End
   END IF;
/* End Bug fix 3060818 */
   p_resultout:='COMPLETE:Y';

EXCEPTION
 WHEN NO_DATA_FOUND THEN
     P_resultout:='COMPLETE:N';
 WHEN OTHERS THEN
      WF_CORE.CONTEXT ('EDR_FWK_VERIFY','CHECK_REQUIREMENT',p_itemtype,p_itemkey,SQLERRM);
      raise;

END CHECK_REQUIREMENT;

PROCEDURE SET_ATTRIBUTES
	(
	 p_itemtype   IN VARCHAR2,
      	 p_itemkey    IN VARCHAR2,
      	 p_actid      IN NUMBER,
         p_funcmode   IN VARCHAR2,
         p_resultout  OUT NOCOPY VARCHAR2
	) IS
BEGIN
IF P_FUNCMODE = 'RESPOND' THEN
  wf_engine.setitemattrtext(itemtype => p_itemtype,
                            itemkey => p_itemkey,
                            aname => 'NOTIFICATION_ID',
                            avalue => wf_engine.context_nid);

END IF;
EXCEPTION
 WHEN OTHERS THEN

      WF_CORE.CONTEXT ('EDR_FWK_VERIFY','SET_ATTRIBUTES',p_itemtype,p_itemkey,SQLERRM);
      raise;

END SET_ATTRIBUTES;

PROCEDURE UPDATE_EVIDENCE
	(p_itemtype   IN VARCHAR2,
      	 p_itemkey    IN VARCHAR2,
      	 p_actid      IN NUMBER,
         p_funcmode   IN VARCHAR2,
         p_resultout  OUT NOCOPY VARCHAR2
	 ) IS

l_Event_name varchar2(240);
l_Event_key  varchar2(240);
l_requester varchar2(240);
l_nid varchar2(240);
l_fwk_test_no varchar2(240);

l_doc_id number;
l_error number;
l_error_msg varchar2(4000);
l_doc_params      EDR_EvidenceStore_PUB.params_tbl_type;
l_sig_id number;
l_sign_params     EDR_EvidenceStore_PUB.params_tbl_type;
l_result varchar2(1000);
  l_ret_status	varchar2(30);
  l_msg_count	number;
  l_msg_data	varchar2(1000);
BEGIN

--Bug 4073809 : start
l_Event_name :=wf_engine.GETITEMATTRTEXT(itemtype => p_itemtype,
                                             itemkey => p_itemkey,
                                             aname => 'EVENT_NAME');
l_Event_key  :=wf_engine.GETITEMATTRTEXT(itemtype => p_itemtype,
                                             itemkey => p_itemkey,
                                             aname => 'EVENT_KEY');
l_requester  :=wf_engine.GETITEMATTRTEXT(itemtype => p_itemtype,
                                             itemkey => p_itemkey,
                                             aname => 'REQUESTER');
l_nid  :=wf_engine.GETITEMATTRTEXT(itemtype => p_itemtype,
                                             itemkey => p_itemkey,
                                             aname => 'NOTIFICATION_ID');
l_fwk_test_no :=wf_engine.GETITEMATTRTEXT(itemtype => p_itemtype,
                                             itemkey => p_itemkey,
                                             aname => 'FWK_TEST_NO');

--Bug 4073809 : end

IF P_FUNCMODE ='RUN' THEN
 l_result:= wf_notification.getattrtext(l_nid,'RESULT');
                      l_doc_params(1).param_name:='PSIG_USER_KEY_LABEL';
                      l_doc_params(1).param_value:='WF-'||FND_MESSAGE.GET_STRING('EDR','EDR_FWK_TEST_LBL');
                      l_doc_params(1).param_displayname:='Identifier Label';
                      l_doc_params(2).param_name:='PSIG_USER_KEY_VALUE';
                      l_doc_params(2).param_value:='WF-'||l_fwk_test_no;
                      l_doc_params(2).param_displayname:='Identifier value';

	EDR_EvidenceStore_PUB.Capture_Signature  (
		p_api_version		=> 1.0,
		p_init_msg_list		=> FND_API.G_TRUE,
		p_commit		=> FND_API.G_FALSE,
		x_return_status		=> l_ret_status,
		x_msg_count		=> l_msg_count,
		x_msg_data		=> l_msg_data,
		P_PSIG_XML          	=> NULL,
                P_PSIG_DOCUMENT       	=> NULL,
                P_PSIG_DocFormat 	=> 'text/plain',
                P_PSIG_REQUESTER      	=> l_requester,
                P_PSIG_SOURCE         	=> 'DB',
                P_EVENT_NAME          	=> l_event_name,
                P_EVENT_KEY           	=> l_event_key,
                P_WF_Notif_ID           => l_nid,
                x_DOCUMENT_ID         	=> l_doc_id,
                p_doc_parameters_tbl	=> l_doc_params,
		p_user_name		=> l_requester,
		p_original_recipient	=> l_requester,
		p_overriding_comment	=> null,
		x_signature_id		=> l_sig_id,
		p_evidenceStore_id	=> wf_engine.getitemattrtext(p_itemtype, p_itemkey,'#WF_SIG_ID'),
		p_user_response		=> wf_notification.getattrtext(l_nid,'RESULT'),
		p_sig_parameters_tbl	=> l_sign_params  );

      /* Close Document if SUCCESS*/

             IF l_result='APPROVED' then
                 EDR_PSIG.closeDocument( P_DOCUMENT_ID       => l_doc_id,
                                     P_ERROR             => l_error,
                                     P_ERROR_MSG         => l_error_msg);
             ELSIF l_result='REJECTED' then

                 EDR_PSIG.changeDocumentStatus( P_DOCUMENT_ID       => l_doc_id,
                                               P_STATUS            => 'REJECTED',
                                               P_ERROR             => l_error,
                                               P_ERROR_MSG         => l_error_msg);
             END IF;
END IF;

EXCEPTION
 WHEN OTHERS THEN
      WF_CORE.CONTEXT ('EDR_FWK_VERIFY','UPDATE_EVIDENCE',p_itemtype,p_itemkey,SQLERRM);
      raise;

END UPDATE_EVIDENCE;



-- --------------------------
-- Procedure	: Test_EvidenceStore
-- Function	: test edr_EvidenceStore_pub.Capture_Signature
-- version	: 23-Jul-03 jianliu	created
-- Usage	: Test_EvidenceStore('EDRPSIGF', '3157', 44145, 'oracle.apps.edr.amevar.update', '26', ostr)
-- --------------------------

PROCEDURE Test_EvidenceStore (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	p_itemtype   	IN VARCHAR2,
      	p_itemkey    	IN VARCHAR2,
      	p_notif_id   	IN NUMBER,
        p_event_name 	IN VARCHAR2,
        p_event_key 	IN VARCHAR2,
        x_resultout  	OUT NOCOPY VARCHAR2 )
IS
  l_Event_name 	varchar2(240);
  l_Event_key  	varchar2(240);
  l_requester 	varchar2(240);
  l_nid 	varchar2(240);
  l_doc_id 	number;
  l_error 	number;
  l_error_msg 	varchar2(4000);
  l_doc_params  EDR_EvidenceStore_PUB.params_tbl_type;
  l_sig_id 	number;
  l_sign_params EDR_EvidenceStore_PUB.params_tbl_type;
  l_result 	varchar2(1000);

  l_ret_status	varchar2(30);
  l_msg_count	number;
  l_msg_data	varchar2(1000);
  l_ret_sig_id	number;
BEGIN
 begin
   l_Event_name := wf_engine.GETITEMATTRTEXT( itemtype => p_itemtype,
                            itemkey => p_itemkey, aname => 'EVENT_NAME');
 exception
   when others then
     l_event_name := p_event_name;
 end;
 begin
   l_Event_key := wf_engine.GETITEMATTRTEXT( itemtype => p_itemtype,
                            itemkey => p_itemkey, aname => 'EVENT_KEY');
 exception
   when others then
     l_event_key := p_event_key;
 end;
 begin
   l_requester := wf_engine.GETITEMATTRTEXT(itemtype => p_itemtype,
                            itemkey => p_itemkey, aname => 'REQUESTER');
 exception
   when others then
     l_requester := 'MFG';
 end;
 begin
   l_nid := wf_engine.GETITEMATTRTEXT(itemtype => p_itemtype,
                      itemkey => p_itemkey, aname => 'NOTIFICATION_ID');
 exception
   when others then
     l_nid := TO_CHAR(p_notif_id);
 end;


 begin
   l_result:= wf_notification.getattrtext(l_nid,'RESULT');
 exception
   when others then
     l_result := 'PENDING';
 end;

      	l_doc_params(1).param_name	:=	'PSIG_USER_KEY_LABEL';
      	l_doc_params(1).param_value	:=	'Transaction, Input Variable';
       	l_doc_params(1).param_displayname :=	'Identifier Label';
        l_doc_params(2).param_name	:=	'PSIG_USER_KEY_VALUE';
        l_doc_params(2).param_value	:=	'EDR ERES File Approval, ESIG_REQUIRED';
        l_doc_params(2).param_displayname :=	'Identifier value';

        wf_log_pkg.string(6, 'EDR_PSIG_rule.psig_rule','Posting Document Parameters');

        l_sign_params(1).param_name	:= 'WF_NOTE';
	l_sign_params(1).param_value	:= 'I only wanna test capture_signature';
        l_sign_params(1).param_displayname := 'Signer Comments';

        l_sign_params(2).param_name	:= 'REASON_CODE';
        l_sign_params(2).param_value	:= NULL;
        l_sign_params(2).param_displayname := 'Signing Reason';

        l_sign_params(3).param_name	:= 'WF_SIGNER_TYPE';
        l_sign_params(3).param_value	:= NULL;
        l_sign_params(3).param_displayname := 'Signature Type ';

	EDR_EvidenceStore_PUB.Capture_Signature  (
		p_api_version		=> p_api_version,
		p_init_msg_list		=> p_init_msg_list,
		p_commit		=> FND_API.G_FALSE,
		x_return_status		=> l_ret_status,
		x_msg_count		=> l_msg_count,
		x_msg_data		=> l_msg_data,
		P_PSIG_XML          	=> NULL,
                P_PSIG_DOCUMENT       	=> NULL,
                P_PSIG_DocFormat 	=> 'text/plain',
                P_PSIG_REQUESTER      	=> l_requester,
                P_PSIG_SOURCE         	=> 'DB',
                P_EVENT_NAME          	=> l_event_name,
                P_EVENT_KEY           	=> l_event_key,
                P_WF_Notif_ID           => l_nid,
                x_DOCUMENT_ID         	=> l_doc_id,
                p_doc_parameters_tbl	=> l_doc_params,
		p_user_name		=> l_requester,
		p_original_recipient	=> l_requester,
		p_overriding_comment	=> null,
		x_signature_id		=> l_ret_sig_id,
		p_evidenceStore_id	=> wf_engine.getitemattrtext(p_itemtype, p_itemkey,'#WF_SIG_ID'),
		p_user_response		=> wf_notification.getattrtext(l_nid,'RESULT'),
		p_sig_parameters_tbl	=> l_sign_params  );
	x_resultout := l_result;
EXCEPTION
 WHEN OTHERS THEN
      WF_CORE.CONTEXT ('EDR_FWK_VERIFY','UPDATE_EVIDENCE',p_itemtype,p_itemkey,SQLERRM);
      raise;
END Test_EvidenceStore;



end EDR_FWK_VERIFY;

/
