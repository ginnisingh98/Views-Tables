--------------------------------------------------------
--  DDL for Package Body OKL_VP_PA_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VP_PA_WF" AS
/* $Header: OKLRPAWB.pls 120.1 2006/07/21 13:13:18 akrangan noship $ */

  G_NO_MATCHING_RECORD CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_LLA_NO_MATCHING_RECORD';
  G_COL_NAME_TOKEN CONSTANT VARCHAR2(200)  := OKL_API.G_COL_NAME_TOKEN;

  G_PROGRAM_AGRMNT_EVENT CONSTANT wf_events.name%TYPE DEFAULT 'oracle.apps.okl.la.vp.approve_program_agreement';

  G_AGRMNT_APPROVAL_WF  CONSTANT VARCHAR2(2)  DEFAULT 'WF';
  G_AGRMNT_APPROVAL_AME CONSTANT VARCHAR2(3)  DEFAULT 'AME';

  G_ITEM_TYPE_WF CONSTANT VARCHAR2(10) DEFAULT 'OKLPAAPP';
  G_ITEM_TYPE_AME CONSTANT VARCHAR2(10) DEFAULT 'OKLAMAPP';

  G_TRANS_APP_NAME_PA CONSTANT ame_calling_apps.application_name%TYPE DEFAULT 'OKL LA Program Agreement Approval';

  G_WF_ITM_AGREEMENT_ID CONSTANT wf_item_attributes.name%TYPE DEFAULT 'AGREEMENT_ID';
  G_WF_ITM_AGREEMENT_NUMBER CONSTANT wf_item_attributes.name%TYPE DEFAULT 'AGREEMENT_NUMBER';

  G_WF_ITM_APP_REQUEST_SUB CONSTANT wf_item_attributes.name%TYPE DEFAULT 'APP_REQUEST_SUB';
  G_WF_ITM_APP_REMINDER_SUB CONSTANT wf_item_attributes.name%TYPE DEFAULT 'APP_REMINDER_SUB';
  G_WF_ITM_APP_APPROVED_SUB CONSTANT wf_item_attributes.name%TYPE DEFAULT 'APP_APPROVED_SUB';
  G_WF_ITM_APP_REJECTED_SUB CONSTANT wf_item_attributes.name%TYPE DEFAULT 'APP_REJECTED_SUB';
  G_WF_ITM_APP_REMINDER_HEAD CONSTANT wf_item_attributes.name%TYPE DEFAULT 'APP_REMINDER_HEAD';
  G_WF_ITM_APP_APPROVED_HEAD CONSTANT wf_item_attributes.name%TYPE DEFAULT 'APP_APPROVED_HEAD';
  G_WF_ITM_APP_REJECTED_HEAD CONSTANT wf_item_attributes.name%TYPE DEFAULT 'APP_REJECTED_HEAD';

  G_WF_ITM_REQUESTER CONSTANT wf_item_attributes.name%TYPE DEFAULT 'REQUESTER';
  G_WF_ITM_REQUESTER_ID CONSTANT wf_item_attributes.name%TYPE DEFAULT 'REQUESTER_ID';
  G_WF_ITM_APPROVER CONSTANT wf_item_attributes.name%TYPE DEFAULT 'APPROVER';

  G_WF_ITM_MESSAGE_SUBJECT CONSTANT wf_item_attributes.name%TYPE DEFAULT 'MESSAGE_SUBJECT';
  G_WF_ITM_MESSAGE_DESCR CONSTANT wf_item_attributes.name%TYPE DEFAULT 'MESSAGE_DESCRIPTION';
  G_WF_ITM_MESSAGE_BODY CONSTANT wf_item_attributes.name%TYPE DEFAULT 'MESSAGE_DOC';
  G_WF_ITM_RESULT CONSTANT wf_item_attributes.name%TYPE DEFAULT 'RESULT';
  G_WF_ITM_APPROVED_YN_YES CONSTANT wf_item_attributes.name%TYPE DEFAULT 'APPROVED';
  G_WF_ITM_APPROVED_YN_NO CONSTANT wf_item_attributes.name%TYPE DEFAULT 'REJECTED';

  G_WF_ITM_APPLICATION_ID CONSTANT wf_item_attributes.name%TYPE DEFAULT 'APPLICATION_ID';
  G_WF_ITM_TRANSACTION_TYPE_ID CONSTANT wf_item_attributes.name%TYPE DEFAULT 'TRX_TYPE_ID';
  G_WF_ITM_TRANSACTION_ID CONSTANT wf_item_attributes.name%TYPE DEFAULT 'TRANSACTION_ID';

  G_DEFAULT_USER CONSTANT VARCHAR2(10) := 'SYSADMIN';
  G_DEFAULT_USER_DESC CONSTANT VARCHAR2(30) := 'System Administrator';
  G_WF_USER_ORIG_SYSTEM_HR CONSTANT VARCHAR2(5) := 'PER';

  G_AMP_SIGN    CONSTANT VARCHAR2(1) := '&';

  G_DECLINED_STS_CODE CONSTANT okc_statuses_b.code%TYPE DEFAULT 'DECLINED';
  G_ACTIVE_STS_CODE CONSTANT okc_statuses_b.code%TYPE DEFAULT 'ACTIVE';

  -- local procedure. START

  -- l_get_agent finds the current user who has submitted the requisition in wf_roles,
  -- if not found, the notification is sent to sysadmin
  PROCEDURE l_get_agent(p_user_id     IN  NUMBER,
                        x_return_status  OUT NOCOPY VARCHAR2,
                        x_name        OUT NOCOPY VARCHAR2,
                        x_description OUT NOCOPY VARCHAR2) IS

    CURSOR wf_users_csr(cp_user_id NUMBER)IS
    SELECT name, display_name
      FROM wf_users
     WHERE orig_system_id = p_user_id
	      AND orig_system = G_WF_USER_ORIG_SYSTEM_HR;

    CURSOR fnd_users_csr(cp_user_id NUMBER)IS
    SELECT user_name, description
      FROM fnd_user
     WHERE user_id = cp_user_id;
  BEGIN
    x_return_status      := OKL_API.G_RET_STS_SUCCESS;
    OPEN  wf_users_csr(p_user_id);
    FETCH wf_users_csr INTO x_name, x_description;
    CLOSE wf_users_csr;
    IF x_name IS NULL THEN
      OPEN  fnd_users_csr(p_user_id);
      FETCH fnd_users_csr INTO x_name, x_description;
      CLOSE fnd_users_csr;
      IF x_name IS NULL THEN
        x_name        := G_DEFAULT_USER;
        x_description := G_DEFAULT_USER_DESC;
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END l_get_agent;

  -- generates unique value for event key
  FUNCTION get_item_key_wf  RETURN NUMBER IS
    CURSOR c_wf_item_key_csr IS
    SELECT okl_wf_item_s.NEXTVAL item_key
    FROM  dual;

    lv_item_key NUMBER;
  BEGIN
    OPEN c_wf_item_key_csr; FETCH c_wf_item_key_csr INTO lv_item_key;
    CLOSE c_wf_item_key_csr;
    RETURN lv_item_key;
  END get_item_key_wf;

  PROCEDURE set_attrib_message(itemtype	IN VARCHAR2
                              ,itemkey  	IN VARCHAR2
                              ,message fnd_new_messages.message_name%TYPE
                              ,attrib wf_item_attributes.name%TYPE
                              ) IS
    lv_agreement_number okc_k_headers_b.contract_number%TYPE;
  BEGIN
    -- construct message text for the purpose of subject line of the notification,
    -- the token is set to AGR_NUMBER for both operating agreement and program agreement
    lv_agreement_number := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                     itemkey   => itemkey,
                                                     aname     => G_WF_ITM_AGREEMENT_NUMBER);

    fnd_message.set_name(G_APP_NAME,message);
    fnd_message.set_token('AGR_NUMBER', lv_agreement_number);

    wf_engine.SetItemAttrText(itemtype  => itemtype,
                              itemkey   => itemkey,
                              aname   	 => attrib,
                              avalue    => fnd_message.get
                             );

  END set_attrib_message;

  FUNCTION compile_message_body(p_chr_id IN okc_k_headers_b.id%TYPE) RETURN VARCHAR2 IS
     CURSOR c_get_agrmnt_details_csr(cp_chr_id okc_k_headers_b.id%TYPE)IS
     SELECT agreement.contract_number agreement_number
           ,subclass.meaning agreement_category
           ,vendors.vendor_name vendor_name
           ,agreement.id agreement_id
           ,agreement.description
           ,agreement.start_date
           ,agreement.end_date
      FROM okc_k_headers_v agreement
           ,okc_subclasses_v subclass
           ,po_vendors vendors
           ,okc_k_party_roles_b party_roles
     WHERE agreement.scs_code = subclass.code
       AND party_roles.dnz_chr_id (+) = agreement.id
       AND party_roles.rle_code (+) = 'OKL_VENDOR'
       AND party_roles.object1_id1 = vendors.vendor_id(+)
       AND agreement.id = cp_chr_id;
    cv_get_agrmnt_details c_get_agrmnt_details_csr%ROWTYPE;

    lv_message VARCHAR2(4000);
  BEGIN
    -- construct message body
    -- message body looks like
    --
    -- Agreement Number <Value>                 Vendor Name <Value>
    --       Start Date <Value>                    Category <Value>
    --         End Date <Value>                 Description <Value>
    --
    OPEN c_get_agrmnt_details_csr(p_chr_id); FETCH c_get_agrmnt_details_csr INTO cv_get_agrmnt_details;
    CLOSE c_get_agrmnt_details_csr;

    lv_message:= '<TABLE width="100%" border="0" cellspacing="0" cellpadding="0">'||
                 '<tr><td colspan=0>'||G_AMP_SIGN||'nbsp;</td></tr>'||
                 -- first row containing Agreement Number and Vendor Name
                 '<tr><td align="right">'|| Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_VP_AGREEMENT_SEARCH'
                                                                               ,p_attribute_code => 'OKL_VP_AGREEMENT_NUMBER')
					                      ||'</td><td>'|| G_AMP_SIGN ||'nbsp;<b>' || cv_get_agrmnt_details.agreement_number
                           ||'</b></td><td>'||G_AMP_SIGN ||'nbsp;</td>'||'<td></td><td>'||G_AMP_SIGN ||'nbsp;</td>'||
                     '<td align="right">'|| Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_VP_AGREEMENT_SEARCH'
                                                                   ,p_attribute_code => 'OKL_VENDOR_NAME')
					                      ||'</td><td>'|| G_AMP_SIGN ||'nbsp;<b>' || cv_get_agrmnt_details.vendor_name
                           ||'</b></td>'||
                    '</tr>'||
                 -- second row containing Start Date and Category
                 '<tr><td align="right">'|| Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_QUOTE_DTLS'
                                                                               ,p_attribute_code => 'OKL_START_DATE')
					                      ||'</td><td>'|| G_AMP_SIGN ||'nbsp;<b>'|| cv_get_agrmnt_details.start_date
                           ||'</b></td><td>'||G_AMP_SIGN ||'nbsp;</td>'||'<td></td><td>'||G_AMP_SIGN ||'nbsp;</td>'||
                     '<td align="right">'|| Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_VP_AGREEMENT_SEARCH'
                                                                   ,p_attribute_code => 'OKL_VP_CATEGORY')
					                      ||'</td><td>'|| G_AMP_SIGN||'nbsp;<b>'|| cv_get_agrmnt_details.agreement_category
                           ||'</b></td>'||
                 '</tr>'||
                 -- third row containing End Date and Description
                 '<tr><td align="right">'|| Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_BP_INV_FORMAT'
                                                                               ,p_attribute_code => 'OKL_END_DATE')
					                      ||'</td><td>'|| G_AMP_SIGN ||'nbsp;<b>'|| cv_get_agrmnt_details.end_date
                           ||'</b></td><td>'||G_AMP_SIGN ||'nbsp;</td>'||'<td></td><td>'||G_AMP_SIGN ||'nbsp;</td>'||
                     '<td align="right">'|| Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_VP_PROGRAM_UPDATE'
                                                                   ,p_attribute_code => 'OKL_DESCRIPTION')
					                      ||'</td><td>'||G_AMP_SIGN ||'nbsp;<b>'|| cv_get_agrmnt_details.description
                           ||'</b></td>'||
                 '</tr>'||
               '</TABLE>';

    RETURN lv_message;
  END compile_message_body;

  PROCEDURE get_msg_doc(document_id   IN VARCHAR2,
                        display_type  IN VARCHAR2,
                        document      IN OUT nocopy VARCHAR2,
                        document_type IN OUT nocopy VARCHAR2) IS
    lv_agreement_id okc_k_headers_b.id%TYPE;
  BEGIN
    lv_agreement_id := wf_engine.GetItemAttrText(itemtype => G_ITEM_TYPE_WF
                                                ,itemkey  => document_id
                                                ,aname    => G_WF_ITM_AGREEMENT_ID);
    document := compile_message_body(lv_agreement_id);
    document_type := display_type;
  END get_msg_doc;
  -- local procedure. END

  PROCEDURE raise_pa_event_approval(p_api_version   IN NUMBER
                                   ,p_init_msg_list IN VARCHAR2
                                   ,x_return_status OUT NOCOPY VARCHAR2
                                   ,x_msg_count     OUT NOCOPY NUMBER
                                   ,x_msg_data      OUT NOCOPY VARCHAR2
                                   ,p_chr_id        IN okc_k_headers_b.id%TYPE
                                   ) IS
    CURSOR c_get_pa_num_csr(cp_chr_id okc_k_headers_b.id%TYPE)IS
    SELECT id
          ,contract_number
      FROM okc_k_headers_b
     WHERE id = cp_chr_id;
    cv_get_pa_num c_get_pa_num_csr%ROWTYPE;

    -- Get the valid application id from FND
    CURSOR c_get_app_id_csr IS
    SELECT APPLICATION_ID
      FROM FND_APPLICATION
     WHERE APPLICATION_SHORT_NAME = G_APP_NAME;

    -- Get the Transaction Type Id from OAM
    CURSOR c_get_trx_type_csr(cp_trx_type  VARCHAR2) IS
    SELECT transaction_type_id,
           fnd_application_id
      FROM AME_CALLING_APPS
     WHERE application_name = cp_trx_type;
    c_get_trx_type_csr_rec c_get_trx_type_csr%ROWTYPE;

    l_parameter_list wf_parameter_list_t;
    lv_wf_item_key NUMBER;

	   l_requester VARCHAR2(200);
    l_name VARCHAR2(200);

    l_application_id fnd_application.application_id%TYPE;
    l_trans_appl_id ame_calling_apps.application_id%TYPE;
    l_trans_type_id ame_calling_apps.transaction_type_id%TYPE;

    l_api_version CONSTANT NUMBER DEFAULT 1.0;
    l_approval_process fnd_lookups.lookup_code%TYPE;
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'SUBMIT_pa_FOR_APPROVAL';
    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_VP_PA_WF.RAISE_PA_EVENT_APPROVAL';
    l_debug_enabled VARCHAR2(10);

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_debug_enabled := okl_debug_pub.check_log_enabled;

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRXXXB.pls call raise_pa_event_approval');
    END IF;

    -- call START_ACTIVITY to create savepoint, check compatibility and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(
      p_api_name      => l_api_name
      ,p_pkg_name      => G_PKG_NAME
      ,p_init_msg_list => p_init_msg_list
      ,l_api_version   => l_api_version
      ,p_api_version   => p_api_version
      ,p_api_type      => g_api_type
      ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_get_agent(p_user_id       => fnd_global.user_id
               ,x_return_status => x_return_status
               ,x_name          => l_requester
               ,x_description   => l_name);
    -- write to log
    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                              l_module,
                              'l_get_agent return staus '||x_return_status||' l_requester '||l_requester||' l_name '||l_name
                              );
    END IF; -- end of NVL(l_debug_enabled,'N')='Y'

    -- read the profile OKL: Program Agreement Approval Process
    l_approval_process := fnd_profile.value('OKL_VP_PA_APPROVAL_PROCESS');
    IF(NVL(l_approval_process,'NONE') = G_AGRMNT_APPROVAL_AME)THEN
      -- for AME approvals, put the application_id and transaction_type_id as event parameters
			   -- Get the Application ID
		    OPEN  c_get_app_id_csr;
		    FETCH c_get_app_id_csr INTO l_application_id;
		    IF c_get_app_id_csr%NOTFOUND THEN
		      OKL_API.set_message(p_app_name     => G_APP_NAME,
		                          p_msg_name     => G_NO_MATCHING_RECORD,
		                          p_token1       => G_COL_NAME_TOKEN,
		                          p_token1_value => 'Application id');
		      RAISE OKL_API.G_EXCEPTION_ERROR;
		    END IF;
		    CLOSE c_get_app_id_csr;

			   -- Get the Transaction Type ID
		    OPEN  c_get_trx_type_csr(G_TRANS_APP_NAME_PA);
		    FETCH c_get_trx_type_csr INTO l_trans_type_id, l_trans_appl_id;
		    IF c_get_trx_type_csr%NOTFOUND THEN
		      OKL_API.set_message(p_app_name     => G_APP_NAME,
		                          p_msg_name     => G_NO_MATCHING_RECORD,
		                          p_token1       => G_COL_NAME_TOKEN,
		                          p_token1_value => 'AME Transcation TYPE id, Application id');
		      RAISE OKL_API.G_EXCEPTION_ERROR;
		    END IF;
		    CLOSE c_get_trx_type_csr;
      IF(l_application_id = l_trans_appl_id)THEN
        wf_event.AddParameterToList(G_WF_ITM_APPLICATION_ID,l_application_id,l_parameter_list);
        wf_event.AddParameterToList(G_WF_ITM_TRANSACTION_TYPE_ID,l_trans_type_id,l_parameter_list);
      END IF;
    ELSIF(NVL(l_approval_process,'NONE') = G_AGRMNT_APPROVAL_WF)THEN
      -- log here. no action required. for common event parameters, see below
      -- write to log
      IF(NVL(l_debug_enabled,'N')='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'l_approval_process '||l_approval_process||' raising program agreement approval event'
                                );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y'
    END IF; -- end of NVL(l_approval_process,'NONE')='AME'

    -- commmon event parameters here,
    IF(l_approval_process IN (G_AGRMNT_APPROVAL_WF, G_AGRMNT_APPROVAL_AME))THEN
      OPEN c_get_pa_num_csr(p_chr_id); FETCH c_get_pa_num_csr INTO cv_get_pa_num;
      CLOSE c_get_pa_num_csr;

      -- get the agreement information to put as event parameters and raise the event
      wf_event.AddParameterToList(G_WF_ITM_AGREEMENT_ID, cv_get_pa_num.id, l_parameter_list);
      wf_event.AddParameterToList(G_WF_ITM_AGREEMENT_NUMBER, cv_get_pa_num.contract_number, l_parameter_list);

      wf_event.AddParameterToList(G_WF_ITM_REQUESTER, l_requester, l_parameter_list);
      wf_event.AddParameterToList(G_WF_ITM_REQUESTER_ID,fnd_global.user_id,l_parameter_list);

      -- transaction id is the contract id (okc_k_headers_b.id) this parameter is required to write custom queries in AME
      -- and use them in conditions and rules
      wf_event.AddParameterToList(G_WF_ITM_TRANSACTION_ID,cv_get_pa_num.id,l_parameter_list);
      --added by akrangan
wf_event.AddParameterToList('ORG_ID',mo_global.get_current_org_id ,l_parameter_list);

      lv_wf_item_key := get_item_key_wf;
      -- Raise Event
      wf_event.RAISE(p_event_name => G_PROGRAM_AGRMNT_EVENT,
                     p_event_key  => lv_wf_item_key,
                     p_parameters => l_parameter_list);

      l_parameter_list.DELETE;
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count, x_msg_data		=> x_msg_data);

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRXXXB.pls call raise_pa_event_approval');
    END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);

  END raise_pa_event_approval;

  PROCEDURE check_approval_process(itemtype	  IN VARCHAR2
				                               ,itemkey   IN VARCHAR2
			                                ,actid		   IN NUMBER
			                                ,funcmode  IN VARCHAR2
				                               ,resultout OUT NOCOPY VARCHAR2) IS
    l_approval_option VARCHAR2(10);
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'check_approval_process';
  BEGIN
    IF(funcmode = 'RUN')THEN
		    l_approval_option := fnd_profile.value('OKL_VP_PA_APPROVAL_PROCESS');
		    IF l_approval_option = 'AME' THEN
		      resultout := 'COMPLETE:AME';
		    ELSIF l_approval_option = 'WF' THEN
		      resultout := 'COMPLETE:WF';
		    END IF;
      RETURN;
    END IF;

    -- CANCEL mode
    IF (funcmode = 'CANCEL') THEN
      resultout := 'COMPLETE:';
      RETURN;
    END IF;

    -- TIMEOUT mode
    IF (funcmode = 'TIMEOUT') THEN
      resultout := 'COMPLETE:';
      RETURN;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      wf_core.context(G_PKG_NAME , l_api_name, itemtype, itemkey, actid, funcmode);
      RAISE;
  END check_approval_process;

  PROCEDURE get_agrmnt_approver(itemtype  IN VARCHAR2
                               ,itemkey   IN VARCHAR2
                               ,actid     IN NUMBER
                               ,funcmode  IN VARCHAR2
                               ,resultout OUT NOCOPY VARCHAR2) IS
    CURSOR l_fnd_users_csr(p_user_id NUMBER)
    IS
    SELECT USER_NAME
    FROM   FND_USER
    WHERE  user_id = p_user_id;

    l_api_name CONSTANT VARCHAR2(200) DEFAULT 'get_agrmnt_approver';

	   l_user_id   VARCHAR2(200);
    lv_requestor VARCHAR2(100);

    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_VP_PA_WF.GET_AGRMNT_APPROVER';
    l_debug_enabled VARCHAR2(10);

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug call get_agrmnt_approver');
    END IF;

    IF(funcmode = 'RUN')THEN
      l_user_id := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                             itemkey   => itemkey,
                                             aname     => G_WF_ITM_REQUESTER_ID);

      resultout := 'COMPLETE:N'; -- default
      IF l_user_id IS NOT NULL THEN
       FOR l_fnd_users_rec IN l_fnd_users_csr(l_user_id) LOOP
         wf_engine.SetItemAttrText (itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => G_WF_ITM_APPROVER,
                                    avalue   => l_fnd_users_rec.user_name);

         -- Message: "Program Agreement <AGR_NUMBER> requires approval"
         set_attrib_message(itemtype, itemkey, 'OKL_VN_PA_REQ_APPROVAL_SUB', G_WF_ITM_MESSAGE_SUBJECT);

         wf_engine.SetItemAttrText (itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname   	=> G_WF_ITM_MESSAGE_BODY,
                                    avalue   => 'plsql:okl_vp_pa_wf.get_msg_doc/'||itemkey
                                   );
         resultout := 'COMPLETE:Y';
       END LOOP;
      END IF; -- l_user_id
       -- CANCEL mode
    ELSIF (funcmode = 'CANCEL') THEN
      resultout := 'COMPLETE:';
      RETURN;
      -- TIMEOUT mode
    ELSIF (funcmode = 'TIMEOUT') THEN
        resultout := 'COMPLETE:';
        RETURN;
    END IF; -- funcmode

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug  call get_agrmnt_approver');
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
    wf_core.context(G_PKG_NAME,l_api_name,itemtype,itemkey,TO_CHAR(actid),funcmode);
    RAISE;
  END get_agrmnt_approver;

  PROCEDURE update_agrmnt_status(itemtype	  IN VARCHAR2
                                ,itemkey   IN VARCHAR2
                                ,actid		   IN NUMBER
                                ,funcmode  IN VARCHAR2
                                ,resultout OUT NOCOPY VARCHAR2) IS
    x_return_status VARCHAR2(10);
    x_msg_data VARCHAR2(1000);
    x_msg_count NUMBER;
    l_api_name CONSTANT VARCHAR2(200) DEFAULT 'update_agrmnt_status';
    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_VP_PA_WF.UPDATE_AGRMNT_STATUS';
    l_debug_enabled VARCHAR2(10);
    lv_approval_status VARCHAR2(10);
    lv_approval_status_ame VARCHAR2(10);
    lv_agreement_id okc_k_headers_b.id%TYPE;
  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug update_agrmnt_status');
    END IF;

    IF(funcmode = 'RUN')THEN
      lv_approval_status := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => G_WF_ITM_RESULT);

      lv_approval_status_ame := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'APPROVED_YN');
      lv_agreement_id := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => G_WF_ITM_AGREEMENT_ID);

      IF(G_WF_ITM_APPROVED_YN_YES = lv_approval_status OR lv_approval_status_ame = 'Y')THEN
        okl_contract_status_pub.update_contract_status(p_api_version   => '1.0'
                                                      ,p_init_msg_list => OKL_API.G_TRUE
                                                      ,x_return_status => x_return_status
                                                      ,x_msg_count     => x_msg_count
                                                      ,x_msg_data      => x_msg_data
                                                      ,p_khr_status    => G_ACTIVE_STS_CODE
                                                      ,p_chr_id        => lv_agreement_id
                                                       );
        -- write to log
        IF(NVL(l_debug_enabled,'N')='Y') THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                  l_module,
                                  'okl_contract_status_pub.update_contract_status G_ACTIVE_STS_CODE returned with status '||x_return_status||' x_msg_data '||x_msg_data
                                  );
        END IF; -- end of NVL(l_debug_enabled,'N')='Y'
        IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      ELSIF(G_WF_ITM_APPROVED_YN_NO = lv_approval_status OR lv_approval_status_ame = 'N')THEN
        okl_contract_status_pub.update_contract_status(p_api_version   => '1.0'
                                                      ,p_init_msg_list => OKL_API.G_TRUE
                                                      ,x_return_status => x_return_status
                                                      ,x_msg_count     => x_msg_count
                                                      ,x_msg_data      => x_msg_data
                                                      ,p_khr_status    => G_DECLINED_STS_CODE
                                                      ,p_chr_id        => lv_agreement_id
                                                       );
        -- write to log
        IF(NVL(l_debug_enabled,'N')='Y') THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                  l_module,
                                  'okl_contract_status_pub.update_contract_status G_DECLINED_STS_CODE returned with status '||x_return_status||' x_msg_data '||x_msg_data
                                  );
        END IF; -- end of NVL(l_debug_enabled,'N')='Y'
        IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;

      resultout := 'COMPLETE:';
      RETURN;
       -- CANCEL mode
    ELSIF (funcmode = 'CANCEL') THEN
      resultout := 'COMPLETE:';
      RETURN;
      -- TIMEOUT mode
    ELSIF (funcmode = 'TIMEOUT') THEN
        resultout := 'COMPLETE:';
        RETURN;
    END IF; -- funcmode
    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug update_agrmnt_status');
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
    wf_core.context(G_PKG_NAME,l_api_name,itemtype,itemkey,TO_CHAR(actid),funcmode);
    RAISE;
  END update_agrmnt_status;

  PROCEDURE process_pa_for_ame(itemtype	  IN VARCHAR2
                              ,itemkey   IN VARCHAR2
                              ,actid		   IN NUMBER
                              ,funcmode  IN VARCHAR2
                              ,resultout OUT NOCOPY VARCHAR2) IS
    l_api_name CONSTANT VARCHAR2(200) DEFAULT 'process_pa_for_ame';
    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_VP_PA_WF.PROCESS_PA_FOR_AME';
    l_debug_enabled VARCHAR2(10);
    lv_agreement_id okc_k_headers_b.id%TYPE;
  BEGIN
    IF(funcmode = 'RUN')THEN
      lv_agreement_id := wf_engine.GetItemAttrText(itemtype  => itemtype
                                                  ,itemkey   => itemkey
                                                  ,aname     => G_WF_ITM_AGREEMENT_ID);

      set_attrib_message(itemtype, itemkey, 'OKL_VN_PA_REQ_APPROVAL_SUB', G_WF_ITM_APP_REQUEST_SUB);
      set_attrib_message(itemtype, itemkey, 'OKL_VN_PA_REQ_APPROVAL_REM', G_WF_ITM_APP_REMINDER_SUB);
      set_attrib_message(itemtype, itemkey, 'OKL_VN_PA_REQ_APPROVAL_REM', G_WF_ITM_APP_REMINDER_HEAD);
      set_attrib_message(itemtype, itemkey, 'OKL_VN_PA_REQ_APPROVED_SUB', G_WF_ITM_APP_APPROVED_SUB);
      set_attrib_message(itemtype, itemkey, 'OKL_VN_PA_REQ_APPROVED_SUB', G_WF_ITM_APP_APPROVED_HEAD);
      set_attrib_message(itemtype, itemkey, 'OKL_VN_PA_REQ_REJECT_SUB', G_WF_ITM_APP_REJECTED_SUB);
      set_attrib_message(itemtype, itemkey, 'OKL_VN_PA_REQ_REJECT_SUB', G_WF_ITM_APP_REJECTED_HEAD);

      wf_engine.SetItemAttrText (itemtype  => itemtype
                                ,itemkey   => itemkey
                                ,aname   	 => G_WF_ITM_MESSAGE_DESCR
                                ,avalue    => compile_message_body(lv_agreement_id)
                                );

      resultout := 'COMPLETE:';
      RETURN;

    -- CANCEL mode
    ELSIF (funcmode = 'CANCEL') THEN
      resultout := 'COMPLETE:';
      RETURN;
    -- TIMEOUT mode
    ELSIF (funcmode = 'TIMEOUT') THEN
        resultout := 'COMPLETE:';
        RETURN;
    END IF; -- funcmode

  EXCEPTION
  WHEN OTHERS THEN
    wf_core.context(G_PKG_NAME,l_api_name,itemtype,itemkey,TO_CHAR(actid),funcmode);
    RAISE;
  END process_pa_for_ame;

  PROCEDURE set_msg_attributes (itemtype  IN VARCHAR2
                               ,itemkey   IN VARCHAR2
                               ,actid     IN NUMBER
                               ,funcmode  IN VARCHAR2
                               ,resultout OUT NOCOPY VARCHAR2) IS
    lv_approval_status VARCHAR2(10);
    l_api_name CONSTANT VARCHAR2(200) DEFAULT 'set_msg_attributes';
  BEGIN
    -- RUN mode
    IF(funcmode = 'RUN')THEN
      lv_approval_status := wf_engine.GetItemAttrText(itemtype => itemtype
                                                     ,itemkey  => itemkey
                                                     ,aname    => G_WF_ITM_RESULT);
      IF(G_WF_ITM_APPROVED_YN_YES = lv_approval_status)THEN
        set_attrib_message(itemtype, itemkey, 'OKL_VN_PA_REQ_APPROVED_SUB', G_WF_ITM_MESSAGE_SUBJECT);
      ELSIF(G_WF_ITM_APPROVED_YN_NO = lv_approval_status)THEN
        set_attrib_message(itemtype, itemkey, 'OKL_VN_PA_REQ_REJECT_SUB', G_WF_ITM_MESSAGE_SUBJECT);
      END IF;
      wf_engine.SetItemAttrText (itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => G_WF_ITM_MESSAGE_BODY,
                                 avalue   => 'plsql:okl_vp_pa_wf.get_msg_doc/'||itemkey
                                );
      resultout := 'COMPLETE:';
    END IF; -- end of run mode

    -- CANCEL mode
    IF(funcmode = 'CANCEL')THEN
      resultout := 'COMPLETE:';
      RETURN;
    END IF;

    -- TIMEOUT mode
    IF(funcmode = 'TIMEOUT')THEN
      resultout := 'COMPLETE:';
      RETURN;
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
      wf_core.context(G_PKG_NAME,l_api_name,itemtype,itemkey,TO_CHAR(actid),funcmode);
      RAISE;
  END set_msg_attributes;

END okl_vp_pa_wf;

/
