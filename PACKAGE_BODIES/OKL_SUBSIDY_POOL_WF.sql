--------------------------------------------------------
--  DDL for Package Body OKL_SUBSIDY_POOL_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SUBSIDY_POOL_WF" AS
/* $Header: OKLRSWFB.pls 120.2 2006/09/28 06:04:57 zrehman noship $ */

  G_NO_MATCHING_RECORD CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_LLA_NO_MATCHING_RECORD';
  G_COL_NAME_TOKEN CONSTANT VARCHAR2(200)  := OKL_API.G_COL_NAME_TOKEN;
  G_SUBSIDY_POOL_APPROVAL_WF  CONSTANT VARCHAR2(2)  DEFAULT 'WF';
  G_SUBSIDY_POOL_APPROVAL_AME CONSTANT VARCHAR2(3)  DEFAULT 'AME';
  G_ITEM_TYPE_WF CONSTANT VARCHAR2(10) DEFAULT 'OKLSPAPP';
  G_POOL_APPROVAL_PROCESS_WF CONSTANT VARCHAR2(30)  DEFAULT 'SUBSIDY_POOL_APPROVAL_WF';
  G_LINE_APPROVAL_PROCESS_WF CONSTANT VARCHAR2(30)  DEFAULT 'BUDGET_LINE_APPROVAL_WF';
  G_ITEM_TYPE_AME CONSTANT VARCHAR2(10) DEFAULT 'OKLAMAPP';
  G_APPROVAL_PROCESS_AME CONSTANT VARCHAR2(30) DEFAULT 'APPROVAL_PROC';
  G_TRANS_APP_NAME_POOL CONSTANT ame_calling_apps.application_name%TYPE DEFAULT 'OKL LA Subsidy Pool Approval';
  G_TRANS_APP_NAME_LINE CONSTANT ame_calling_apps.application_name%TYPE DEFAULT 'OKL LA Subsidy Pool Budget Approval';
  G_TRX_TYPE_POOL_APPROVAL  CONSTANT okl_trx_types_b.trx_type_class%TYPE DEFAULT 'SUBSIDY_POOL_APPROVAL';

  G_WF_ITM_SUBSIDY_POOL_ID CONSTANT wf_item_attributes.name%TYPE DEFAULT 'SUBSIDY_POOL_ID';
  G_WF_ITM_SUBSIDY_POOL_NAME CONSTANT wf_item_attributes.name%TYPE DEFAULT 'SUBSIDY_POOL_NAME';
  G_WF_ITM_FROM_DATE CONSTANT wf_item_attributes.name%TYPE DEFAULT 'FROM_DATE';
  G_WF_ITM_TO_DATE CONSTANT wf_item_attributes.name%TYPE DEFAULT 'TO_DATE';
  G_WF_ITM_TOTAL_BUDGETS CONSTANT wf_item_attributes.name%TYPE DEFAULT 'TOTAL_BUDGETS';
  G_WF_ITM_POOL_CURRENCY CONSTANT wf_item_attributes.name%TYPE DEFAULT 'CURRENCY_CODE';
  G_WF_ITM_POOL_DESCR CONSTANT wf_item_attributes.name%TYPE DEFAULT 'POOL_DESCRIPTION';
  G_WF_ITM_BUDGET_ID CONSTANT wf_item_attributes.name%TYPE DEFAULT 'BUDGET_LINE_ID';
  G_WF_ITM_BUDGET_AMOUNT CONSTANT wf_item_attributes.name%TYPE DEFAULT 'BUDGET_AMOUNT';
  G_WF_ITM_BUDGET_FROM_DATE CONSTANT wf_item_attributes.name%TYPE DEFAULT 'BUDGET_EFFECTIVE_DATE';
  G_WF_ITM_BUDGET_TYPE CONSTANT wf_item_attributes.name%TYPE DEFAULT 'BUDGET_TYPE_CODE';
  G_WF_ITM_REQUESTOR CONSTANT wf_item_attributes.name%TYPE DEFAULT 'REQUESTER';
  G_WF_ITM_REQUESTOR_ID CONSTANT wf_item_attributes.name%TYPE DEFAULT 'REQUESTOR_ID';
  G_WF_ITM_APP_REQUEST_SUB CONSTANT wf_item_attributes.name%TYPE DEFAULT 'APP_REQUEST_SUB';
  G_WF_ITM_APP_REMINDER_SUB CONSTANT wf_item_attributes.name%TYPE DEFAULT 'APP_REMINDER_SUB';
  G_WF_ITM_APP_APPROVED_SUB CONSTANT wf_item_attributes.name%TYPE DEFAULT 'APP_APPROVED_SUB';
  G_WF_ITM_APP_REJECTED_SUB CONSTANT wf_item_attributes.name%TYPE DEFAULT 'APP_REJECTED_SUB';
  G_WF_ITM_APP_REMINDER_HEAD CONSTANT wf_item_attributes.name%TYPE DEFAULT 'APP_REMINDER_HEAD';
  G_WF_ITM_APP_APPROVED_HEAD CONSTANT wf_item_attributes.name%TYPE DEFAULT 'APP_APPROVED_HEAD';
  G_WF_ITM_APP_REJECTED_HEAD CONSTANT wf_item_attributes.name%TYPE DEFAULT 'APP_REJECTED_HEAD';
  G_WF_ITM_APPLICATION_ID CONSTANT wf_item_attributes.name%TYPE DEFAULT 'APPLICATION_ID';
  G_WF_ITM_TRANSACTION_TYPE_ID CONSTANT wf_item_attributes.name%TYPE DEFAULT 'TRX_TYPE_ID';
  G_WF_ITM_TRANSACTION_ID CONSTANT wf_item_attributes.name%TYPE DEFAULT 'TRANSACTION_ID';

  G_WF_ITM_APPROVER CONSTANT wf_item_attributes.name%TYPE DEFAULT 'APPROVER';
  G_WF_ITM_MESSAGE_SUBJECT CONSTANT wf_item_attributes.name%TYPE DEFAULT 'MESSAGE_SUBJECT';
  G_WF_ITM_MESSAGE_DESCR CONSTANT wf_item_attributes.name%TYPE DEFAULT 'MESSAGE_DESCRIPTION';
  G_WF_ITM_MESSAGE_BODY CONSTANT wf_item_attributes.name%TYPE DEFAULT 'MESSAGE_DOC';
  G_WF_ITM_RESULT CONSTANT wf_item_attributes.name%TYPE DEFAULT 'RESULT';
  G_WF_ITM_APPROVED_YN_YES CONSTANT wf_item_attributes.name%TYPE DEFAULT 'APPROVED';
  G_WF_ITM_APPROVED_YN_NO CONSTANT wf_item_attributes.name%TYPE DEFAULT 'REJECTED';

  G_POOL_APPROVAL_EVENT CONSTANT wf_events.name%TYPE DEFAULT 'oracle.apps.okl.subsidy_pool.approval_requested';
  G_POOL_BUDGET_APPROVAL_EVENT CONSTANT wf_events.name%TYPE DEFAULT 'oracle.apps.okl.subsidy_pool.approval_budget_requested';

  G_DEFAULT_USER CONSTANT VARCHAR2(10) := 'SYSADMIN';
  G_DEFAULT_USER_DESC CONSTANT VARCHAR2(30) := 'System Administrator';
  G_WF_USER_ORIG_SYSTEM_HR CONSTANT VARCHAR2(5) := 'PER';
  -- local procedure. START
  PROCEDURE l_get_agent(p_user_id     IN  NUMBER,
                        x_return_status  OUT NOCOPY VARCHAR2,
                        x_name        OUT NOCOPY VARCHAR2,
                        x_description OUT NOCOPY VARCHAR2) IS

    CURSOR wf_users_csr(cp_user_id NUMBER)IS
    SELECT NAME, DISPLAY_NAME
      FROM WF_USERS
     WHERE orig_system_id = p_user_id
	      AND ORIG_SYSTEM = G_WF_USER_ORIG_SYSTEM_HR;

    CURSOR fnd_users_csr(c_user_id NUMBER)
    IS
    SELECT USER_NAME, DESCRIPTION
    FROM   FND_USER
    WHERE  user_id = c_user_id;
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
      x_return_status      := OKL_API.G_RET_STS_UNEXP_ERROR;
  END l_get_agent;

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

  FUNCTION get_message(p_msg_name IN fnd_new_messages.message_name%TYPE
                      ,p_msg_token IN VARCHAR2
                      ,p_token_value IN VARCHAR2
                      ) RETURN VARCHAR2 IS
  BEGIN
   fnd_message.set_name(G_APP_NAME,p_msg_name);
   IF(p_msg_token IS NOT NULL)THEN
     fnd_message.set_token(p_msg_token,p_token_value);
   END IF;
   RETURN fnd_message.get;
  END get_message;

  FUNCTION get_pool_msg_body(itemtype	IN VARCHAR2
                             ,itemkey IN VARCHAR2) RETURN VARCHAR2 IS
    lv_pool_name okl_subsidy_pools_b.subsidy_pool_name%TYPE;
    lv_total_budget VARCHAR2(200);
    lv_currency_code okl_subsidy_pools_b.currency_code%TYPE;
    lv_from_date okl_subsidy_pools_b.effective_from_date%TYPE;
    lv_to_date okl_subsidy_pools_b.effective_to_date%TYPE;
    lv_pool_description okl_subsidy_pools_v.short_description%TYPE;
    lv_requestor VARCHAR2(100);
    lv_message_body VARCHAR2(4000);
  BEGIN
    lv_pool_name := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                              itemkey   => itemkey,
                                              aname     => G_WF_ITM_SUBSIDY_POOL_NAME);

    lv_requestor := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                              itemkey   => itemkey,
                                              aname     => G_WF_ITM_REQUESTOR);

    lv_currency_code := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                  itemkey   => itemkey,
                                                  aname     => G_WF_ITM_POOL_CURRENCY);

    lv_from_date := wf_engine.GetItemAttrDate(itemtype  => itemtype,
                                              itemkey   => itemkey,
                                              aname     => G_WF_ITM_FROM_DATE);
    lv_from_date := to_date(lv_from_date,'DD/MM/RRRR');

    lv_to_date := wf_engine.GetItemAttrDate(itemtype  => itemtype,
                                            itemkey   => itemkey,
                                            aname     => G_WF_ITM_TO_DATE);

    lv_pool_description := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                     itemkey   => itemkey,
                                                     aname     => G_WF_ITM_POOL_DESCR);
    lv_total_budget := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                 itemkey   => itemkey,
                                                 aname     => G_WF_ITM_TOTAL_BUDGETS);
    -- format this amount
    lv_total_budget := okl_accounting_util.format_amount(lv_total_budget,lv_currency_code);

    lv_message_body := get_message('OKL_TOTAL_BUDGETS','TOTAL_BUDGET',lv_total_budget)||' '||lv_currency_code||'<br>'||
                       get_message('OKL_EFFECTIVE_FROM','FROM_DATE',fnd_Date.date_to_displaydate(lv_from_date))||'<br>'||
                       get_message('OKL_EFFECTIVE_TO','TO_DATE',lv_to_date)||'<br>'||
                       get_message('OKL_POOL_DESCRIPTION','DESCR',lv_pool_description)||'<br><br>'||
                       get_message('OKL_REQUESTOR','REQUESTOR',lv_requestor);
    RETURN lv_message_body;
  END get_pool_msg_body;

  FUNCTION get_pool_line_msg_body(itemtype	IN VARCHAR2
                                  ,itemkey IN VARCHAR2) RETURN VARCHAR2 IS
    lv_pool_name okl_subsidy_pools_b.subsidy_pool_name%TYPE;
    lv_total_budget VARCHAR2(200);
    lv_currency_code okl_subsidy_pools_b.currency_code%TYPE;
    lv_from_date okl_subsidy_pools_b.effective_from_date%TYPE;
    lv_requestor VARCHAR2(100);
    lv_budget_type fnd_lookups.meaning%TYPE;
    lv_message_body VARCHAR2(4000);
  BEGIN
    lv_pool_name := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                              itemkey   => itemkey,
                                              aname     => G_WF_ITM_SUBSIDY_POOL_NAME);

    lv_requestor := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                              itemkey   => itemkey,
                                              aname     => G_WF_ITM_REQUESTOR);

    lv_currency_code := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                              itemkey   => itemkey,
                                              aname     => G_WF_ITM_POOL_CURRENCY);

    lv_from_date := wf_engine.GetItemAttrDate(itemtype  => itemtype,
                                   itemkey   => itemkey,
                                   aname     => G_WF_ITM_BUDGET_FROM_DATE);

    lv_from_date := to_date(lv_from_date,'DD/MM/RRRR');

    lv_total_budget := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                              itemkey   => itemkey,
                                              aname     => G_WF_ITM_BUDGET_AMOUNT);
    -- format this amount
    lv_total_budget := okl_accounting_util.format_amount(lv_total_budget,lv_currency_code);
    lv_budget_type := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                itemkey   => itemkey,
                                                aname     => G_WF_ITM_BUDGET_TYPE);
    lv_budget_type := okl_accounting_util.get_lookup_meaning('OKL_SUB_POOL_LINE_TYPE',lv_budget_type);

    lv_message_body := '<body>'||get_message('OKL_TOTAL_BUDGETS','TOTAL_BUDGET',lv_total_budget)||' '||lv_currency_code||'<br>'||
                       get_message('OKL_EFFECTIVE_FROM','FROM_DATE',fnd_Date.date_to_displaydate(lv_from_date))||'<br>'||
                       get_message('OKL_SUB_POOL_LINE_TYPE','TYPE',lv_budget_type)||'<br>'||
                       get_message('OKL_SUB_POOL_NAME','SUB_POOL',lv_pool_name)||'<br><br>'||
                       get_message('OKL_REQUESTOR','REQUESTOR',lv_requestor)||'</body>';
    RETURN lv_message_body;

  END get_pool_line_msg_body;

  PROCEDURE set_attrib_message(itemtype	IN VARCHAR2
                              ,itemkey  	IN VARCHAR2
                              ,message fnd_new_messages.message_name%TYPE
                              ,attrib wf_item_attributes.name%TYPE
                              ,pool_or_line IN VARCHAR2
                              ) IS
    lv_pool_name okl_subsidy_pools_b.subsidy_pool_name%TYPE;
    lv_total_budget VARCHAR2(200);
    lv_currency_code okl_subsidy_pools_b.currency_code%TYPE;

  BEGIN
    lv_currency_code := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                  itemkey   => itemkey,
                                                  aname     => G_WF_ITM_POOL_CURRENCY);

    lv_pool_name := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                              itemkey   => itemkey,
                                              aname     => G_WF_ITM_SUBSIDY_POOL_NAME);
    IF('POOL' = pool_or_line)THEN
      lv_total_budget := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                   itemkey   => itemkey,
                                                   aname     => G_WF_ITM_TOTAL_BUDGETS);
    ELSIF('BUDGET' = pool_or_line)THEN
      lv_total_budget := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                   itemkey   => itemkey,
                                                   aname     => G_WF_ITM_BUDGET_AMOUNT);
    END IF;
    -- format this amount
    lv_total_budget := okl_accounting_util.format_amount(lv_total_budget,lv_currency_code);

    fnd_message.set_name(G_APP_NAME,message);
    fnd_message.set_token('NAME', lv_pool_name);

    IF('POOL' = pool_or_line)THEN
      fnd_message.set_token('TOTAL_BUDGET', lv_total_budget);
    ELSIF('BUDGET' = pool_or_line)THEN
      fnd_message.set_token('BUDGET', lv_total_budget);
    END IF;

    fnd_message.set_token('CURR', lv_currency_code);
    wf_engine.SetItemAttrText(itemtype  => itemtype,
                              itemkey   => itemkey,
                              aname   	 => attrib,
                              avalue    => fnd_message.get
                             );

  END set_attrib_message;


  PROCEDURE get_pool_msg_doc(document_id   IN VARCHAR2,
                              display_type  IN VARCHAR2,
                              document      IN OUT nocopy VARCHAR2,
                              document_type IN OUT nocopy VARCHAR2) IS
  BEGIN
    document := get_pool_msg_body(G_ITEM_TYPE_WF,document_id);
    document_type := display_type;
  END get_pool_msg_doc;

  PROCEDURE get_pool_line_msg_doc(document_id   IN VARCHAR2,
                              display_type  IN VARCHAR2,
                              document      IN OUT nocopy VARCHAR2,
                              document_type IN OUT nocopy VARCHAR2) IS
  BEGIN
    document := get_pool_line_msg_body(G_ITEM_TYPE_WF,document_id);
    document_type := display_type;
  END get_pool_line_msg_doc;


  -- local procedure. END

  PROCEDURE process_pool_ame (itemtype	IN VARCHAR2
                              ,itemkey  	IN VARCHAR2
                              ,actid		IN NUMBER
                              ,funcmode	IN VARCHAR2
                              ,resultout OUT NOCOPY VARCHAR2) IS
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'process_pool_ame';
    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_WF.PROCESS_POOL_AME';
    l_debug_enabled VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRBWFB.pls call process_pool_ame');
    END IF;

    -- RUN mode
    IF(funcmode = 'RUN')THEN
      set_attrib_message(itemtype, itemkey, 'OKL_SUB_POOL_REQ_APPROVAL_SUB', G_WF_ITM_APP_REQUEST_SUB, 'POOL');
      set_attrib_message(itemtype, itemkey, 'OKL_SUB_POOL_REQ_APPROVAL_REM', G_WF_ITM_APP_REMINDER_SUB, 'POOL');
      set_attrib_message(itemtype, itemkey, 'OKL_SUB_POOL_REQ_APPROVAL_REM', G_WF_ITM_APP_REMINDER_HEAD, 'POOL');
      set_attrib_message(itemtype, itemkey, 'OKL_SUB_POOL_REQ_APPROVED_SUB', G_WF_ITM_APP_APPROVED_SUB, 'POOL');
      set_attrib_message(itemtype, itemkey, 'OKL_SUB_POOL_REQ_APPROVED_SUB', G_WF_ITM_APP_APPROVED_HEAD, 'POOL');
      set_attrib_message(itemtype, itemkey, 'OKL_SUB_POOL_REQ_REJECT_SUB', G_WF_ITM_APP_REJECTED_SUB, 'POOL');
      set_attrib_message(itemtype, itemkey, 'OKL_SUB_POOL_REQ_REJECT_SUB', G_WF_ITM_APP_REJECTED_HEAD, 'POOL');

      -- OKL_SUB_POOL_REQ_APPROVAL_BOD (TOTAL_BUDGET, CURR, FROM_DATE, TO_DATE, POOL_DESCR, REQUESTOR) G_WF_ITM_MESSAGE_BODY
      wf_engine.SetItemAttrText(itemtype  => itemtype,
                                itemkey   => itemkey,
                                aname   	 => G_WF_ITM_MESSAGE_BODY,
                                avalue    => 'plsql:okl_subsidy_pool_wf.get_pool_msg_doc/'||itemkey
                               );

      wf_engine.SetItemAttrText(itemtype  => itemtype,
                                itemkey   => itemkey,
                                aname   	 => G_WF_ITM_MESSAGE_DESCR,
                                avalue    => get_pool_msg_body(itemtype, itemkey)
                               );

      resultout := 'COMPLETE:';
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

    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRBWFB.pls call process_pool_ame');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      wf_core.context(G_PKG_NAME , l_api_name, itemtype, itemkey, actid, funcmode);
      RAISE;
  END process_pool_ame;

  PROCEDURE process_pool_line_ame (itemtype	IN VARCHAR2
                                   ,itemkey  	IN VARCHAR2
                                   ,actid		IN NUMBER
                                   ,funcmode	IN VARCHAR2
                                   ,resultout OUT NOCOPY VARCHAR2) IS
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'process_pool_line_ame';
    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_WF.PROCESS_POOL_LINE_AME';
    l_debug_enabled VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRBWFB.pls call process_pool_line_ame');
    END IF;

    -- RUN mode
    IF(funcmode = 'RUN')THEN
      set_attrib_message(itemtype, itemkey, 'OKL_SUB_LINE_REQ_APPROVAL_SUB', G_WF_ITM_APP_REQUEST_SUB, 'BUDGET');
      set_attrib_message(itemtype, itemkey, 'OKL_SUB_LINE_REQ_APPROVAL_REM', G_WF_ITM_APP_REMINDER_SUB, 'BUDGET');
      set_attrib_message(itemtype, itemkey, 'OKL_SUB_LINE_REQ_APPROVAL_REM', G_WF_ITM_APP_REMINDER_HEAD, 'BUDGET');
      set_attrib_message(itemtype, itemkey, 'OKL_SUB_LINE_REQ_APPROVED_SUB', G_WF_ITM_APP_APPROVED_SUB, 'BUDGET');
      set_attrib_message(itemtype, itemkey, 'OKL_SUB_LINE_REQ_APPROVED_SUB', G_WF_ITM_APP_APPROVED_HEAD, 'BUDGET');
      set_attrib_message(itemtype, itemkey, 'OKL_SUB_LINE_REQ_REJECT_SUB', G_WF_ITM_APP_REJECTED_SUB, 'BUDGET');
      set_attrib_message(itemtype, itemkey, 'OKL_SUB_LINE_REQ_REJECT_SUB', G_WF_ITM_APP_REJECTED_HEAD, 'BUDGET');

      -- OKL_SUB_LINE_REQ_APPROVAL_BOD (BUDGET, FROM_DATE, NAME, REQUESTOR)
      wf_engine.SetItemAttrText(itemtype  => itemtype,
                                itemkey   => itemkey,
                                aname   	 => G_WF_ITM_MESSAGE_BODY,
                                avalue    => 'plsql:okl_subsidy_pool_wf.get_pool_line_msg_doc/'||itemkey
                               );

      wf_engine.SetItemAttrText(itemtype  => itemtype,
                                itemkey   => itemkey,
                                aname   	 => G_WF_ITM_MESSAGE_DESCR,
                                avalue    => get_pool_line_msg_body(itemtype, itemkey)
                               );
      resultout := 'COMPLETE:';
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
    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRBWFB.pls call process_pool_line_ame');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      wf_core.context(G_PKG_NAME , l_api_name, itemtype, itemkey, actid, funcmode);
      RAISE;

  END process_pool_line_ame;

  PROCEDURE check_approval_process(itemtype	IN VARCHAR2
				                               ,itemkey  	IN VARCHAR2
			                                ,actid		IN NUMBER
			                                ,funcmode	IN VARCHAR2
				                               ,resultout OUT NOCOPY VARCHAR2) IS
    l_approval_option VARCHAR2(10);
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'check_approval_process';
  BEGIN
    IF(funcmode = 'RUN')THEN
		    l_approval_option := fnd_profile.value('OKL_SUBSIDY_POOL_APPROVAL_PROCESS');
		    IF l_approval_option = G_SUBSIDY_POOL_APPROVAL_AME THEN
		      resultout := 'COMPLETE:AME';
		    ELSIF l_approval_option = G_SUBSIDY_POOL_APPROVAL_WF THEN
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


  PROCEDURE update_pool_approval_status(itemtype	IN VARCHAR2
                                        ,itemkey  	IN VARCHAR2
                                        ,actid		IN NUMBER
                                        ,funcmode	IN VARCHAR2
                                        ,resultout OUT NOCOPY VARCHAR2) IS
    CURSOR c_get_bud_line_csr (cp_subsidy_pool_id okl_subsidy_pools_b.id%TYPE)IS
    SELECT id
      FROM okl_subsidy_pool_budgets_b
     WHERE subsidy_pool_id = cp_subsidy_pool_id;

    lv_approval_status VARCHAR2(10);
    lv_approval_status_ame VARCHAR2(10);
    lv_total_budget VARCHAR2(200);
    lv_subsidy_pool_id okl_subsidy_pools_b.id%TYPE;
    lv_budget_line_id okl_subsidy_pool_budgets_b.id%TYPE;
    x_return_status VARCHAR2(10);
    x_msg_data VARCHAR2(1000);
    x_msg_count NUMBER;
    lv_decision_status_code fnd_lookups.lookup_code%TYPE;
    l_api_name CONSTANT VARCHAR2(60) DEFAULT 'update_pool_status';
    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_WF.UPDATE_POOL_APPROVAL_STATUS';
    l_debug_enabled VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRBWFB.pls call update_pool_approval_status');
    END IF;

    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);

    IF(funcmode = 'RUN')THEN
      lv_approval_status := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => G_WF_ITM_RESULT);

      lv_approval_status_ame := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'APPROVED_YN');
      -- get the subsidy pool id here, this can be used for case or approval or rejected also
      lv_subsidy_pool_id := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                itemkey   => itemkey,
                                                aname     => G_WF_ITM_SUBSIDY_POOL_ID);
      -- also get the budget line id, since this is pool approval, there will be only one budget line for
      -- the pool in context.
      OPEN c_get_bud_line_csr(cp_subsidy_pool_id => lv_subsidy_pool_id); FETCH c_get_bud_line_csr INTO lv_budget_line_id;
      CLOSE c_get_bud_line_csr;

      IF(G_WF_ITM_APPROVED_YN_YES = lv_approval_status OR lv_approval_status_ame = 'Y')THEN
        lv_total_budget := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                  itemkey   => itemkey,
                                                  aname     => G_WF_ITM_TOTAL_BUDGETS);
        okl_subsidy_pool_pvt.update_total_budget(p_api_version      => '1.0'
                                                 ,p_init_msg_list   => OKL_API.G_TRUE
                                                 ,x_return_status   => x_return_status
                                                 ,x_msg_count       => x_msg_count
                                                 ,x_msg_data        => x_msg_data
                                                 ,p_subsidy_pool_id => lv_subsidy_pool_id
                                                 ,p_total_budget_amt => lv_total_budget
                                                 );
        -- write to log
        IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                  l_module,
                                  'okl_subsidy_pool_pvt.update_total_budget with total budget amount '||lv_total_budget||
                                  ' returned with status '||x_return_status ||' x_msg_data '||x_msg_data
                                  );
        END IF; -- end of NVL(l_debug_enabled,'N')='Y'

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        lv_decision_status_code := 'ACTIVE';
        okl_subsidy_pool_budget_pvt.set_decision_status_code(p_api_version      => '1.0'
                                                             ,p_init_msg_list   => OKL_API.G_TRUE
                                                             ,x_return_status   => x_return_status
                                                             ,x_msg_count       => x_msg_count
                                                             ,x_msg_data        => x_msg_data
                                                             ,p_sub_pool_budget_id => lv_budget_line_id
                                                             ,p_decision_status_code => lv_decision_status_code
                                                             );
        -- write to log
        IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                  l_module,
                                  'okl_subsidy_pool_budget_pvt.set_decision_status_code to '||lv_decision_status_code||' lv_budget_line_id '||lv_budget_line_id ||
                                  ' returned with status '||x_return_status ||' x_msg_data '||x_msg_data
                                  );
        END IF; -- end of NVL(l_debug_enabled,'N')='Y'

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        okl_subsidy_pool_pvt.set_decision_status_code(p_api_version     => '1.0'
                                                     ,p_init_msg_list   => OKL_API.G_TRUE
                                                     ,x_return_status   => x_return_status
                                                     ,x_msg_count       => x_msg_count
                                                     ,x_msg_data        => x_msg_data
                                                     ,p_subsidy_pool_id => lv_subsidy_pool_id
                                                     ,p_decision_status_code => lv_decision_status_code);
        -- write to log
        IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                  l_module,
                                  'okl_subsidy_pool_pvt.set_decision_status_code to '||lv_decision_status_code||' lv_subsidy_pool_id '||lv_subsidy_pool_id ||
                                  ' returned with status '||x_return_status ||' x_msg_data '||x_msg_data
                                  );
        END IF; -- end of NVL(l_debug_enabled,'N')='Y'

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        resultout := 'COMPLETE:';
      ELSIF(G_WF_ITM_APPROVED_YN_NO = lv_approval_status OR lv_approval_status_ame = 'N')THEN
        lv_decision_status_code := 'REJECTED';
        okl_subsidy_pool_budget_pvt.set_decision_status_code(p_api_version      => '1.0'
                                                             ,p_init_msg_list   => OKL_API.G_TRUE
                                                             ,x_return_status   => x_return_status
                                                             ,x_msg_count       => x_msg_count
                                                             ,x_msg_data        => x_msg_data
                                                             ,p_sub_pool_budget_id => lv_budget_line_id
                                                             ,p_decision_status_code => lv_decision_status_code
                                                             );
        -- write to log
        IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                  l_module,
                                  'okl_subsidy_pool_budget_pvt.set_decision_status_code to '||lv_decision_status_code||' lv_budget_line_id '||lv_budget_line_id ||
                                  ' returned with status '||x_return_status ||' x_msg_data '||x_msg_data
                                  );
        END IF; -- end of NVL(l_debug_enabled,'N')='Y'

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        okl_subsidy_pool_pvt.set_decision_status_code(p_api_version     => '1.0'
                                                     ,p_init_msg_list   => OKL_API.G_TRUE
                                                     ,x_return_status   => x_return_status
                                                     ,x_msg_count       => x_msg_count
                                                     ,x_msg_data        => x_msg_data
                                                     ,p_subsidy_pool_id => lv_subsidy_pool_id
                                                     ,p_decision_status_code => lv_decision_status_code);
        -- write to log
        IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                  l_module,
                                  'okl_subsidy_pool_pvt.set_decision_status_code to '||lv_decision_status_code||' lv_subsidy_pool_id '||lv_subsidy_pool_id ||
                                  ' returned with status '||x_return_status ||' x_msg_data '||x_msg_data
                                  );
        END IF; -- end of NVL(l_debug_enabled,'N')='Y'

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        resultout := 'COMPLETE:';
      ELSE
        NULL;
      END IF;
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
    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRBWFB.pls call update_pool_approval_status');
    END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      wf_core.context(G_PKG_NAME,
                      l_api_name,
                       itemtype,
                       itemkey,
                       TO_CHAR(actid),
                       funcmode);
	  RAISE;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      wf_core.context(G_PKG_NAME,
                      l_api_name,
                       itemtype,
                       itemkey,
                       TO_CHAR(actid),
                       funcmode);
	  RAISE;
    WHEN OTHERS THEN
      wf_core.context(G_PKG_NAME,
                      l_api_name,
                       itemtype,
                       itemkey,
                       TO_CHAR(actid),
                       funcmode);
	  RAISE;

  END update_pool_approval_status;

  PROCEDURE update_line_approval_status(itemtype	IN VARCHAR2
                                        ,itemkey  	IN VARCHAR2
                                        ,actid		IN NUMBER
                                        ,funcmode	IN VARCHAR2
                                        ,resultout OUT NOCOPY VARCHAR2) IS
    lv_budget_type_code okl_subsidy_pool_budgets_b.budget_type_code%TYPE;
    CURSOR c_get_total_budget_csr (cp_subsidy_pool_id okl_subsidy_pools_b.id%TYPE) IS
    SELECT total_budgets
      FROM okl_subsidy_pools_b
     WHERE id = cp_subsidy_pool_id;
    lv_approval_status VARCHAR2(10);
    lv_approval_status_ame VARCHAR2(10);
    lv_subsidy_pool_id okl_subsidy_pools_b.id%TYPE;
    lv_budget_line_id okl_subsidy_pool_budgets_b.id%TYPE;
    lv_total_budget okl_subsidy_pools_b.total_budgets%TYPE;
    lv_line_amount NUMBER;
    lv_decision_status_code fnd_lookups.lookup_code%TYPE;
    x_return_status VARCHAR2(10);
    x_msg_data VARCHAR2(1000);
    x_msg_count NUMBER;
    l_api_name CONSTANT VARCHAR2(60) DEFAULT 'update_line_status';
    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_WF.UPDATE_LINE_APPROVAL_STATUS';
    l_debug_enabled VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;
  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRBWFB.pls call update_line_approval_status');
    END IF;

    -- RUN mode
    IF(funcmode = 'RUN')THEN
      -- check for logging on STATEMENT level
      is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);

      lv_approval_status := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => G_WF_ITM_RESULT);

      lv_approval_status_ame := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'APPROVED_YN');


      lv_budget_type_code := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                       itemkey   => itemkey,
                                                       aname     => G_WF_ITM_BUDGET_TYPE);

      lv_line_amount := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                  itemkey   => itemkey,
                                                  aname     => G_WF_ITM_BUDGET_AMOUNT);
      -- get the subsidy pool id here, this can be used for case or approval or rejected also
      lv_subsidy_pool_id := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                      itemkey   => itemkey,
                                                      aname     => G_WF_ITM_SUBSIDY_POOL_ID);
      OPEN c_get_total_budget_csr(cp_subsidy_pool_id => lv_subsidy_pool_id);
      FETCH c_get_total_budget_csr INTO lv_total_budget;
      CLOSE c_get_total_budget_csr;
      lv_budget_line_id := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                      itemkey   => itemkey,
                                                      aname     => G_WF_ITM_BUDGET_ID);

      IF(G_WF_ITM_APPROVED_YN_YES = lv_approval_status OR lv_approval_status_ame = 'Y')THEN
        -- if the budget line is of type ADDITION, then add this amount to the total budgets on the subsidy pool
        -- for all other cases in approval, do not do nuthing
        IF(lv_budget_type_code = 'ADDITION')THEN
          lv_total_budget := lv_total_budget + lv_line_amount;
          okl_subsidy_pool_pvt.update_total_budget(p_api_version      => '1.0'
                                                   ,p_init_msg_list   => OKL_API.G_TRUE
                                                   ,x_return_status   => x_return_status
                                                   ,x_msg_count       => x_msg_count
                                                   ,x_msg_data        => x_msg_data
                                                   ,p_subsidy_pool_id => lv_subsidy_pool_id
                                                   ,p_total_budget_amt => lv_total_budget
                                                   );
          -- write to log
          IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
            okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                    l_module,
                                    'okl_subsidy_pool_pvt.update_total_budget of budget amount '||lv_total_budget||' returned with status '||x_return_status||
                                    ' x_msg_data '||x_msg_data
                                    );
          END IF; -- end of NVL(l_debug_enabled,'N')='Y'

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF; -- end of lv_budget_type_code = 'ADDITION'
          lv_decision_status_code := 'ACTIVE';
          okl_subsidy_pool_budget_pvt.set_decision_status_code(p_api_version      => '1.0'
                                                               ,p_init_msg_list   => OKL_API.G_TRUE
                                                               ,x_return_status   => x_return_status
                                                               ,x_msg_count       => x_msg_count
                                                               ,x_msg_data        => x_msg_data
                                                               ,p_sub_pool_budget_id => lv_budget_line_id
                                                               ,p_decision_status_code => lv_decision_status_code
                                                               );
          -- write to log
          IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
            okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                    l_module,
                                    'okl_subsidy_pool_budget_pvt.set_decision_status_code code '||lv_decision_status_code||' returned with status '||x_return_status||
                                    ' x_msg_data '||x_msg_data
                                    );
          END IF; -- end of NVL(l_debug_enabled,'N')='Y'

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        resultout := 'COMPLETE:';
      ELSIF(G_WF_ITM_APPROVED_YN_NO = lv_approval_status OR lv_approval_status_ame = 'N')THEN
        IF(lv_budget_type_code = 'REDUCTION')THEN
          lv_total_budget := lv_total_budget + lv_line_amount;
          okl_subsidy_pool_pvt.update_total_budget(p_api_version      => '1.0'
                                                   ,p_init_msg_list   => OKL_API.G_TRUE
                                                   ,x_return_status   => x_return_status
                                                   ,x_msg_count       => x_msg_count
                                                   ,x_msg_data        => x_msg_data
                                                   ,p_subsidy_pool_id => lv_subsidy_pool_id
                                                   ,p_total_budget_amt => lv_total_budget
                                                   );
          -- write to log
          IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
            okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                    l_module,
                                    'okl_subsidy_pool_pvt.update_total_budget budget  '||lv_total_budget||' returned with status '||x_return_status||
                                    ' x_msg_data '||x_msg_data
                                    );
          END IF; -- end of NVL(l_debug_enabled,'N')='Y'

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF; -- end of lv_budget_type_code = 'REDUCTION'
        lv_decision_status_code := 'REJECTED';
        okl_subsidy_pool_budget_pvt.set_decision_status_code(p_api_version      => '1.0'
                                                             ,p_init_msg_list   => OKL_API.G_TRUE
                                                             ,x_return_status   => x_return_status
                                                             ,x_msg_count       => x_msg_count
                                                             ,x_msg_data        => x_msg_data
                                                             ,p_sub_pool_budget_id => lv_budget_line_id
                                                             ,p_decision_status_code => lv_decision_status_code
                                                             );
        -- write to log
        IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                  l_module,
                                  'okl_subsidy_pool_budget_pvt.set_decision_status_code code  '||lv_decision_status_code||' returned with status '||x_return_status||
                                  ' x_msg_data '||x_msg_data
                                  );
        END IF; -- end of NVL(l_debug_enabled,'N')='Y'

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        resultout := 'COMPLETE:';
      ELSE
        NULL;
      END IF;
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

    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRBWFB.pls call update_line_approval_status');
    END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      wf_core.context(G_PKG_NAME,
                      l_api_name,
                       itemtype,
                       itemkey,
                       TO_CHAR(actid),
                       funcmode);
	   RAISE;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      wf_core.context(G_PKG_NAME,
                      l_api_name,
                       itemtype,
                       itemkey,
                       TO_CHAR(actid),
                       funcmode);
	   RAISE;
    WHEN OTHERS THEN
      wf_core.context(G_PKG_NAME,
                      l_api_name,
                       itemtype,
                       itemkey,
                       TO_CHAR(actid),
                       funcmode);
	   RAISE;
  END update_line_approval_status;

  PROCEDURE get_subsidy_pool_approver (itemtype  IN VARCHAR2
                                       ,itemkey   IN VARCHAR2
                                       ,actid     IN NUMBER
                                       ,funcmode  IN VARCHAR2
                                       ,resultout OUT NOCOPY VARCHAR2) IS
    CURSOR l_fnd_users_csr(p_user_id NUMBER)
    IS
    SELECT USER_NAME
    FROM   FND_USER
    WHERE  user_id = p_user_id;

    l_api_name CONSTANT VARCHAR2(200) DEFAULT 'get_subsidy_pool_approver';

	   l_user_id   VARCHAR2(200);
    lv_receiving_event wf_events.name%TYPE;
    lv_pool_name okl_subsidy_pools_b.subsidy_pool_name%TYPE;
    lv_total_budget VARCHAR2(200);
    lv_currency_code okl_subsidy_pools_b.currency_code%TYPE;
    lv_from_date okl_subsidy_pools_b.effective_from_date%TYPE;
    lv_to_date okl_subsidy_pools_b.effective_to_date%TYPE;
    lv_pool_description okl_subsidy_pools_v.short_description%TYPE;
    lv_requestor VARCHAR2(100);
    lv_budget_type fnd_lookups.meaning%TYPE;

    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_WF.GET_SUBSIDY_POOL_APPROVER';
    l_debug_enabled VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN; -- not using this as of now

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRBWFB.pls call get_subsidy_pool_approver');
    END IF;

    IF(funcmode = 'RUN')THEN
      l_user_id := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                             itemkey   => itemkey,
                                             aname     => G_WF_ITM_REQUESTOR_ID);

      lv_receiving_event := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                             itemkey   => itemkey,
                                             aname     => 'LAUNCHING_EVENT');

      resultout := 'COMPLETE:N'; -- default
      IF l_user_id IS NOT NULL THEN
       FOR l_fnd_users_rec IN l_fnd_users_csr(l_user_id) LOOP
         wf_engine.SetItemAttrText (itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => G_WF_ITM_APPROVER,
                                    avalue    => l_fnd_users_rec.user_name);

         lv_pool_name := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                   itemkey   => itemkey,
                                                   aname     => G_WF_ITM_SUBSIDY_POOL_NAME);

         lv_requestor := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                   itemkey   => itemkey,
                                                   aname     => G_WF_ITM_REQUESTOR);

         lv_currency_code := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                   itemkey   => itemkey,
                                                   aname     => G_WF_ITM_POOL_CURRENCY);

         IF(lv_receiving_event = G_POOL_APPROVAL_EVENT)THEN
           -- prepare the message subject and message body for subsidy pool approval
           -- OKL_SUB_POOL_REQ_APPROVAL_SUB (NAME, TOTAL_BUDGET, CURR)
           lv_total_budget := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                     itemkey   => itemkey,
                                                     aname     => G_WF_ITM_TOTAL_BUDGETS);
           -- format this amount
           lv_total_budget := okl_accounting_util.format_amount(lv_total_budget,lv_currency_code);

           fnd_message.set_name(G_APP_NAME,'OKL_SUB_POOL_REQ_APPROVAL_SUB');
           fnd_message.set_token('NAME', lv_pool_name);
           fnd_message.set_token('TOTAL_BUDGET', lv_total_budget);
           fnd_message.set_token('CURR', lv_currency_code);

           wf_engine.SetItemAttrText (itemtype  => itemtype,
                                      itemkey   => itemkey,
                                      aname   	 => G_WF_ITM_MESSAGE_SUBJECT,
                                      avalue    => fnd_message.get);

           -- OKL_SUB_POOL_REQ_APPROVAL_BOD (TOTAL_BUDGET, CURR, FROM_DATE, TO_DATE, POOL_DESCR, REQUESTOR) G_WF_ITM_MESSAGE_BODY
           wf_engine.SetItemAttrText (itemtype  => itemtype,
                                      itemkey   => itemkey,
                                      aname   	 => G_WF_ITM_MESSAGE_BODY,
                                      avalue    => 'plsql:okl_subsidy_pool_wf.get_pool_msg_doc/'||itemkey
                                     );

         ELSIF(G_POOL_BUDGET_APPROVAL_EVENT = lv_receiving_event)THEN
           -- prepare the message subject and message body for subsidy pool budget line approval
           -- OKL_SUB_LINE_REQ_APPROVAL_SUB (BUDGET, CURR)
           lv_total_budget := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                     itemkey   => itemkey,
                                                     aname     => G_WF_ITM_BUDGET_AMOUNT);
           -- format this amount
           lv_total_budget := okl_accounting_util.format_amount(lv_total_budget,lv_currency_code);
           lv_budget_type := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                       itemkey   => itemkey,
                                                       aname     => G_WF_ITM_BUDGET_TYPE);
           lv_budget_type := okl_accounting_util.get_lookup_meaning('OKL_SUB_POOL_LINE_TYPE',lv_budget_type);

           fnd_message.set_name(G_APP_NAME,'OKL_SUB_LINE_REQ_APPROVAL_SUB');
           fnd_message.set_token('NAME', lv_pool_name);
           fnd_message.set_token('BUDGET', lv_total_budget);
           fnd_message.set_token('CURR', lv_currency_code);

           wf_engine.SetItemAttrText (itemtype  => itemtype,
                                      itemkey   => itemkey,
                                      aname   	 => G_WF_ITM_MESSAGE_SUBJECT,
                                      avalue    => fnd_message.get);

           -- OKL_SUB_LINE_REQ_APPROVAL_BOD (BUDGET, FROM_DATE, NAME, REQUESTOR)
           wf_engine.SetItemAttrText (itemtype  => itemtype,
                                      itemkey   => itemkey,
                                      aname   	 => G_WF_ITM_MESSAGE_BODY,
                                      avalue    => 'plsql:okl_subsidy_pool_wf.get_pool_line_msg_doc/'||itemkey
                                     );

         END IF;
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

    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRBWFB.pls call get_subsidy_pool_approver');
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
      wf_core.context(G_PKG_NAME,l_api_name,itemtype,itemkey,TO_CHAR(actid),funcmode);
      RAISE;
  END get_subsidy_pool_approver;

  PROCEDURE set_msg_attributes (itemtype  IN VARCHAR2
                               ,itemkey   IN VARCHAR2
                               ,actid     IN NUMBER
                               ,funcmode  IN VARCHAR2
                               ,resultout OUT NOCOPY VARCHAR2) IS
    lv_approval_status VARCHAR2(10);
    lv_receiving_event wf_events.name%TYPE;
    lv_pool_name okl_subsidy_pools_b.subsidy_pool_name%TYPE;
    lv_total_budget VARCHAR2(200);
    lv_currency_code okl_subsidy_pools_b.currency_code%TYPE;
    lv_from_date okl_subsidy_pools_b.effective_from_date%TYPE;
    lv_to_date okl_subsidy_pools_b.effective_to_date%TYPE;
    lv_pool_description okl_subsidy_pools_v.short_description%TYPE;
    lv_approver VARCHAR2(100);
    lv_budget_type fnd_lookups.meaning%TYPE;
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'set_msg_attributes';

    l_module CONSTANT fnd_log_messages.module%TYPE DEFAULT'okl.plsql.OKL_SUBSIDY_POOL_WF.SET_MSG_ATTRIBUTES';
    l_debug_enabled VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;

  BEGIN

    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRBWFB.pls call set_msg_attributes');
    END IF;

    -- RUN mode
    IF(funcmode = 'RUN')THEN
      lv_approval_status := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                               itemkey   => itemkey,
                                               aname     => G_WF_ITM_RESULT);
      lv_receiving_event := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                       itemkey   => itemkey,
                                       aname     => 'LAUNCHING_EVENT');

      lv_pool_name := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                itemkey   => itemkey,
                                                aname     => G_WF_ITM_SUBSIDY_POOL_NAME);

      lv_approver := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                itemkey   => itemkey,
                                                aname     => G_WF_ITM_APPROVER);

      lv_currency_code := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                itemkey   => itemkey,
                                                aname     => G_WF_ITM_POOL_CURRENCY);

      IF(G_WF_ITM_APPROVED_YN_YES = lv_approval_status)THEN
        IF(lv_receiving_event = G_POOL_APPROVAL_EVENT)THEN
          -- prepare the message subject and message body for subsidy pool approval
          -- OKL_SUB_POOL_REQ_APPROVED_SUB (NAME, TOTAL_BUDGET, CURR)
          lv_total_budget := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                    itemkey   => itemkey,
                                                    aname     => G_WF_ITM_TOTAL_BUDGETS);
          -- format this amount
          lv_total_budget := okl_accounting_util.format_amount(lv_total_budget,lv_currency_code);

          fnd_message.set_name(G_APP_NAME,'OKL_SUB_POOL_REQ_APPROVED_SUB');
          fnd_message.set_token('NAME', lv_pool_name);
          fnd_message.set_token('TOTAL_BUDGET', lv_total_budget);
          fnd_message.set_token('CURR', lv_currency_code);

          wf_engine.SetItemAttrText (itemtype  => itemtype,
                                     itemkey   => itemkey,
                                     aname   	 => G_WF_ITM_MESSAGE_SUBJECT,
                                     avalue    => fnd_message.get);

          -- OKL_SUB_POOL_REQ_APPROVED_BOD (TOTAL_BUDGET, CURR, FROM_DATE, TO_DATE, POOL_DESCR, REQUESTOR) G_WF_ITM_MESSAGE_BODY
          lv_from_date := wf_engine.GetItemAttrDate(itemtype  => itemtype,
                                                    itemkey   => itemkey,
                                                    aname     => G_WF_ITM_FROM_DATE);
          lv_to_date := wf_engine.GetItemAttrDate(itemtype  => itemtype,
                                                    itemkey   => itemkey,
                                                    aname     => G_WF_ITM_TO_DATE);
          lv_pool_description := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                    itemkey   => itemkey,
                                                    aname     => G_WF_ITM_POOL_DESCR);

          /*fnd_message.set_name(G_APP_NAME,'OKL_SUB_POOL_REQ_APPROVED_BOD');
          fnd_message.set_token('TOTAL_BUDGET',lv_total_budget);
          fnd_message.set_token('CURR',lv_currency_code);
          fnd_message.set_token('FROM_DATE',lv_from_date);
          fnd_message.set_token('TO_DATE',lv_to_date);
          fnd_message.set_token('POOL_DESCR',lv_pool_description);
          fnd_message.set_token('APPROVER',lv_approver);*/

          wf_engine.SetItemAttrText (itemtype  => itemtype,
                                     itemkey   => itemkey,
                                     aname   	 => G_WF_ITM_MESSAGE_BODY,
                                     avalue    => 'plsql:okl_subsidy_pool_wf.get_pool_msg_doc/'||itemkey);

        ELSIF(G_POOL_BUDGET_APPROVAL_EVENT = lv_receiving_event)THEN
          -- prepare the message subject and message body for subsidy pool budget line approval
          -- OKL_SUB_LINE_REQ_APPROVED_SUB (BUDGET, CURR)
          lv_total_budget := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                    itemkey   => itemkey,
                                                    aname     => G_WF_ITM_BUDGET_AMOUNT);
          -- format this amount
          lv_total_budget := okl_accounting_util.format_amount(lv_total_budget,lv_currency_code);
          lv_budget_type := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                      itemkey   => itemkey,
                                                      aname     => G_WF_ITM_BUDGET_TYPE);
          lv_budget_type := okl_accounting_util.get_lookup_meaning('OKL_SUB_POOL_LINE_TYPE',lv_budget_type);

          fnd_message.set_name(G_APP_NAME,'OKL_SUB_LINE_REQ_APPROVED_SUB');
          fnd_message.set_token('NAME', lv_pool_name);
          fnd_message.set_token('BUDGET', lv_total_budget);
          fnd_message.set_token('CURR', lv_currency_code);

          wf_engine.SetItemAttrText (itemtype  => itemtype,
                                     itemkey   => itemkey,
                                     aname   	 => G_WF_ITM_MESSAGE_SUBJECT,
                                     avalue    => fnd_message.get);

          -- OKL_SUB_LINE_REQ_APPROVED_BOD (BUDGET, FROM_DATE, NAME, REQUESTOR)
          lv_from_date := wf_engine.GetItemAttrDate(itemtype  => itemtype,
                                         itemkey   => itemkey,
                                         aname     => G_WF_ITM_BUDGET_FROM_DATE);

          lv_from_date := to_date(lv_from_date,'DD/MM/RRRR');

          /*fnd_message.set_name(G_APP_NAME, 'OKL_SUB_LINE_REQ_APPROVED_BOD');
          fnd_message.set_token('BUDGET', lv_total_budget);
          fnd_message.set_token('CURR', lv_currency_code);
          fnd_message.set_token('FROM_DATE', lv_from_date);
          fnd_message.set_token('TYPE', lv_budget_type);
          fnd_message.set_token('NAME', lv_pool_name);
          fnd_message.set_token('APPROVER', lv_approver);*/

          wf_engine.SetItemAttrText (itemtype  => itemtype,
                                     itemkey   => itemkey,
                                     aname   	 => G_WF_ITM_MESSAGE_BODY,
                                     avalue    => 'plsql:okl_subsidy_pool_wf.get_pool_line_msg_doc/'||itemkey);
        END IF;
        resultout := 'COMPLETE:';
      ELSIF(G_WF_ITM_APPROVED_YN_NO = lv_approval_status)THEN
        IF(lv_receiving_event = G_POOL_APPROVAL_EVENT)THEN
          -- prepare the message subject and message body for subsidy pool approval
          -- OKL_SUB_POOL_REQ_REJECT_SUB (NAME, TOTAL_BUDGET, CURR)
          lv_total_budget := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                    itemkey   => itemkey,
                                                    aname     => G_WF_ITM_TOTAL_BUDGETS);
          -- format this amount
          lv_total_budget := okl_accounting_util.format_amount(lv_total_budget,lv_currency_code);

          fnd_message.set_name(G_APP_NAME,'OKL_SUB_POOL_REQ_REJECT_SUB');
          fnd_message.set_token('NAME', lv_pool_name);
          fnd_message.set_token('TOTAL_BUDGET', lv_total_budget);
          fnd_message.set_token('CURR', lv_currency_code);

          wf_engine.SetItemAttrText (itemtype  => itemtype,
                                     itemkey   => itemkey,
                                     aname   	 => G_WF_ITM_MESSAGE_SUBJECT,
                                     avalue    => fnd_message.get);

          -- OKL_SUB_POOL_REQ_REJECT_BOD (TOTAL_BUDGET, CURR, FROM_DATE, TO_DATE, POOL_DESCR, REQUESTOR) G_WF_ITM_MESSAGE_BODY
          lv_from_date := wf_engine.GetItemAttrDate(itemtype  => itemtype,
                                                    itemkey   => itemkey,
                                                    aname     => G_WF_ITM_FROM_DATE);
          lv_to_date := wf_engine.GetItemAttrDate(itemtype  => itemtype,
                                                    itemkey   => itemkey,
                                                    aname     => G_WF_ITM_TO_DATE);
          lv_pool_description := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                    itemkey   => itemkey,
                                                    aname     => G_WF_ITM_POOL_DESCR);

          /*fnd_message.set_name(G_APP_NAME,'OKL_SUB_POOL_REQ_REJECT_BOD');
          fnd_message.set_token('TOTAL_BUDGET',lv_total_budget);
          fnd_message.set_token('CURR',lv_currency_code);
          fnd_message.set_token('FROM_DATE',lv_from_date);
          fnd_message.set_token('TO_DATE',lv_to_date);
          fnd_message.set_token('POOL_DESCR',lv_pool_description);
          fnd_message.set_token('APPROVER',lv_approver);*/

          wf_engine.SetItemAttrText (itemtype  => itemtype,
                                     itemkey   => itemkey,
                                     aname   	 => G_WF_ITM_MESSAGE_BODY,
                                     avalue    => 'plsql:okl_subsidy_pool_wf.get_pool_msg_doc/'||itemkey);

        ELSIF(G_POOL_BUDGET_APPROVAL_EVENT = lv_receiving_event)THEN
          -- prepare the message subject and message body for subsidy pool budget line approval
          -- OKL_SUB_LINE_REQ_REJECT_SUB (BUDGET, CURR)
          lv_total_budget := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                    itemkey   => itemkey,
                                                    aname     => G_WF_ITM_BUDGET_AMOUNT);
          -- format this amount
          lv_total_budget := okl_accounting_util.format_amount(lv_total_budget,lv_currency_code);
          lv_budget_type := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                      itemkey   => itemkey,
                                                      aname     => G_WF_ITM_BUDGET_TYPE);
          lv_budget_type := okl_accounting_util.get_lookup_meaning('OKL_SUB_POOL_LINE_TYPE',lv_budget_type);

          fnd_message.set_name(G_APP_NAME,'OKL_SUB_LINE_REQ_REJECT_SUB');
          fnd_message.set_token('NAME', lv_pool_name);
          fnd_message.set_token('BUDGET', lv_total_budget);
          fnd_message.set_token('CURR', lv_currency_code);

          wf_engine.SetItemAttrText (itemtype  => itemtype,
                                     itemkey   => itemkey,
                                     aname   	 => G_WF_ITM_MESSAGE_SUBJECT,
                                     avalue    => fnd_message.get);

          -- OKL_SUB_LINE_REQ_REJECT_BOD (BUDGET, FROM_DATE, NAME, REQUESTOR)
          lv_from_date := wf_engine.GetItemAttrDate(itemtype  => itemtype,
                                         itemkey   => itemkey,
                                         aname     => G_WF_ITM_BUDGET_FROM_DATE);

          lv_from_date := to_date(lv_from_date,'DD/MM/RRRR');

          /*fnd_message.set_name(G_APP_NAME, 'OKL_SUB_LINE_REQ_REJECT_BOD');
          fnd_message.set_token('BUDGET', lv_total_budget);
          fnd_message.set_token('CURR', lv_currency_code);
          fnd_message.set_token('FROM_DATE', lv_from_date);
          fnd_message.set_token('TYPE', lv_budget_type);
          fnd_message.set_token('NAME', lv_pool_name);
          fnd_message.set_token('APPROVER', lv_approver);*/

          wf_engine.SetItemAttrText (itemtype  => itemtype,
                                     itemkey   => itemkey,
                                     aname   	 => G_WF_ITM_MESSAGE_BODY,
                                     avalue    => 'plsql:okl_subsidy_pool_wf.get_pool_line_msg_doc/'||itemkey);
        END IF;
        resultout := 'COMPLETE:';
      ELSE
        NULL; -- status other than approval or rejected, no operation
      END IF; -- end of approval value comparision
    END IF; -- end of run mode

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

    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRBWFB.pls call set_msg_attributes');
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
      wf_core.context(G_PKG_NAME,l_api_name,itemtype,itemkey,TO_CHAR(actid),funcmode);
      RAISE;
  END set_msg_attributes;

  PROCEDURE raise_pool_event_approval(p_api_version    IN  NUMBER
                                      ,p_init_msg_list  IN  VARCHAR2
                                      ,x_return_status  OUT NOCOPY VARCHAR2
                                      ,x_msg_count      OUT NOCOPY NUMBER
                                      ,x_msg_data       OUT NOCOPY VARCHAR2
                                      ,p_subsidy_pool_id IN okl_subsidy_pools_b.id%TYPE) IS

    l_api_name CONSTANT VARCHAR2(150) DEFAULT 'raise_pool_event';
    l_parameter_list wf_parameter_list_t;
    l_approval_option VARCHAR2(10);
	   l_requester VARCHAR2(200);
    l_name VARCHAR2(200);
    -- cursor to fetch the initial budget amount and the pool details
    -- at this point of approval, only one budget line is allowed.
    CURSOR c_get_pool_info_csr (cp_subsidy_pool_id okl_subsidy_pools_b.id%TYPE)IS
    SELECT pool.subsidy_pool_name
          ,pool.effective_from_date
          ,pool.effective_to_date
          ,pool.total_budgets
          ,pool.currency_code
          ,pool.short_description
          ,bud.budget_amount
      FROM okl_subsidy_pools_v pool
          ,okl_subsidy_pool_budgets_b bud
     WHERE pool.id = cp_subsidy_pool_id
       AND pool.id = bud.subsidy_pool_id;
    cv_get_pool_info c_get_pool_info_csr%ROWTYPE;

    lv_wf_item_key NUMBER;

    -- Get the valid application id from FND
    CURSOR c_get_app_id_csr
    IS
    SELECT APPLICATION_ID
    FROM   FND_APPLICATION
    WHERE  APPLICATION_SHORT_NAME = G_APP_NAME;

    -- Get the Transaction Type Id from OAM
    CURSOR c_get_trx_type_csr(cp_trx_type  VARCHAR2) IS
    SELECT transaction_type_id,
           fnd_application_id
    FROM   ame_transaction_types_v
    WHERE  transaction_type_id = cp_trx_type;
    c_get_trx_type_csr_rec c_get_trx_type_csr%ROWTYPE;

    CURSOR l_trx_try_csr  IS
    SELECT id
    FROM   okl_trx_types_b
    WHERE  trx_type_class = G_TRX_TYPE_POOL_APPROVAL;

    l_application_id fnd_application.application_id%TYPE;
    l_trans_appl_id ame_calling_apps.application_id%TYPE;
    l_trans_type_id ame_calling_apps.transaction_type_id%TYPE;

    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_WF.RAISE_POOL_EVENT_APPROVAL';
    l_debug_enabled VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRBWFB.pls call raise_pool_event_approval');
    END IF;

    x_return_status      := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);

    l_get_agent(p_user_id       => fnd_global.user_id
                ,x_return_status => x_return_status
                ,x_name          => l_requester
                ,x_description   => l_name);
    -- write to log
    IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                              l_module,
                              'l_get_agent return staus '||x_return_status||' l_requester '||l_requester||' l_name '||l_name
                              );
    END IF; -- end of NVL(l_debug_enabled,'N')='Y'

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_approval_option := fnd_profile.value('OKL_SUBSIDY_POOL_APPROVAL_PROCESS');
    IF(l_approval_option = G_SUBSIDY_POOL_APPROVAL_AME)THEN
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
		    OPEN  c_get_trx_type_csr(G_TRANS_APP_NAME_POOL);
		    FETCH c_get_trx_type_csr INTO l_trans_type_id,
		                                  l_trans_appl_id;
		    IF c_get_trx_type_csr%NOTFOUND THEN
		      OKL_API.set_message(p_app_name     => G_APP_NAME,
		                          p_msg_name     => G_NO_MATCHING_RECORD,
		                          p_token1       => G_COL_NAME_TOKEN,
		                          p_token1_value => 'AME Transcation TYPE id, Application id');
		      RAISE OKL_API.G_EXCEPTION_ERROR;
		    END IF;
		    CLOSE c_get_trx_type_csr;
		    IF l_application_id = l_trans_appl_id THEN
        wf_event.AddParameterToList(G_WF_ITM_APPLICATION_ID,l_application_id,l_parameter_list);
        wf_event.AddParameterToList(G_WF_ITM_TRANSACTION_TYPE_ID,l_trans_type_id,l_parameter_list);
      END IF;
      -- write to log
      IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'l_approval_option '||l_approval_option||' raising budget line approval event '
                                );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y'

    ELSIF(l_approval_option = G_SUBSIDY_POOL_APPROVAL_WF)THEN
      -- write to log
      IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'l_approval_option '||l_approval_option||' raising budget line approval event '
                                );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y'
    ELSE
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF(l_approval_option IN (G_SUBSIDY_POOL_APPROVAL_WF, G_SUBSIDY_POOL_APPROVAL_AME))THEN
      OPEN c_get_pool_info_csr (cp_subsidy_pool_id => p_subsidy_pool_id);
      FETCH c_get_pool_info_csr INTO cv_get_pool_info;
      CLOSE c_get_pool_info_csr;
      wf_event.AddParameterToList(G_WF_ITM_SUBSIDY_POOL_ID,p_subsidy_pool_id,l_parameter_list);
      wf_event.AddParameterToList(G_WF_ITM_SUBSIDY_POOL_NAME,cv_get_pool_info.subsidy_pool_name,l_parameter_list);
      wf_event.AddParameterToList(G_WF_ITM_FROM_DATE,to_date(cv_get_pool_info.effective_from_date,'DD/MM/RRRR'),l_parameter_list);
      wf_event.AddParameterToList(G_WF_ITM_TO_DATE,to_date(cv_get_pool_info.effective_to_date,'DD/MM/RRRR'),l_parameter_list);
      wf_event.AddParameterToList(G_WF_ITM_TOTAL_BUDGETS,cv_get_pool_info.budget_amount,l_parameter_list);
      wf_event.AddParameterToList(G_WF_ITM_POOL_CURRENCY,cv_get_pool_info.currency_code,l_parameter_list);
      wf_event.AddParameterToList(G_WF_ITM_POOL_DESCR,cv_get_pool_info.short_description,l_parameter_list);

      wf_event.AddParameterToList(G_WF_ITM_TRANSACTION_ID,p_subsidy_pool_id,l_parameter_list);

      wf_event.AddParameterToList(G_WF_ITM_REQUESTOR,l_requester,l_parameter_list);
      wf_event.AddParameterToList(G_WF_ITM_REQUESTOR_ID,fnd_global.user_id,l_parameter_list);

      lv_wf_item_key := get_item_key_wf;
      -- Raise Event
      wf_event.RAISE(p_event_name => G_POOL_APPROVAL_EVENT,
                     p_event_key  => lv_wf_item_key,
                     p_parameters => l_parameter_list);
      l_parameter_list.DELETE;
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,x_msg_data   => x_msg_data);

    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRBWFB.pls call raise_pool_event_approval');
    END IF;

  EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.G_RET_STS_ERROR;
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                      p_api_name  => l_api_name,
                      p_pkg_name  => G_PKG_NAME,
                      p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                      x_msg_count => x_msg_count,
                      x_msg_data  => x_msg_data,
                      p_api_type  => G_API_TYPE);
  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                      p_api_name  => l_api_name,
                      p_pkg_name  => G_PKG_NAME,
                      p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                      x_msg_count => x_msg_count,
                      x_msg_data  => x_msg_data,
                      p_api_type  => G_API_TYPE);
  WHEN OTHERS THEN
    -- store SQL error message on message stack
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                      p_api_name  => l_api_name,
                      p_pkg_name  => G_PKG_NAME,
                      p_exc_name  => 'OTHERS',
                      x_msg_count => x_msg_count,
                      x_msg_data  => x_msg_data,
                      p_api_type  => G_API_TYPE);
  END raise_pool_event_approval;

  PROCEDURE raise_budget_event_approval(p_api_version     IN 	NUMBER
                                        ,p_init_msg_list   IN  VARCHAR2
                                        ,x_return_status   OUT NOCOPY VARCHAR2
                                        ,x_msg_count       OUT NOCOPY NUMBER
                                        ,x_msg_data        OUT NOCOPY VARCHAR2
                                        ,p_subsidy_pool_budget_id IN okl_subsidy_pool_budgets_b.id%TYPE) IS
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'raise_budget_event';
    l_parameter_list wf_parameter_list_t;
    l_approval_option VARCHAR2(10);
	   l_requester VARCHAR2(200);
    l_name VARCHAR2(200);
    lv_wf_item_key NUMBER;

    CURSOR c_get_budget_info_csr (cp_pool_budget_id okl_subsidy_pool_budgets_b.id%TYPE) IS
    SELECT sub.subsidy_pool_name
          ,sub.id subsidy_pool_id
          ,sub.effective_from_date pool_start_date
          ,sub.effective_to_date
          ,sub.total_budgets
          ,bud.budget_type_code
          ,bud.effective_from_date budget_line_date
          ,bud.budget_amount
          ,sub.currency_code
      FROM okl_subsidy_pools_b sub
          ,okl_subsidy_pool_budgets_b bud
     WHERE bud.subsidy_pool_id = sub.id
       AND bud.id = cp_pool_budget_id;
    cv_get_budget_info c_get_budget_info_csr%ROWTYPE;

    -- Get the valid application id from FND
    CURSOR c_get_app_id_csr
    IS
    SELECT APPLICATION_ID
    FROM   FND_APPLICATION
    WHERE  APPLICATION_SHORT_NAME = G_APP_NAME;

    -- Get the Transaction Type Id from OAM
    CURSOR c_get_trx_type_csr(cp_trx_type  VARCHAR2) IS
    SELECT transaction_type_id,
           fnd_application_id
    FROM  ame_transaction_types_v
    WHERE transaction_type_id = cp_trx_type;
    c_get_trx_type_csr_rec c_get_trx_type_csr%ROWTYPE;

    CURSOR l_trx_try_csr  IS
    SELECT id
    FROM   okl_trx_types_b
    WHERE  trx_type_class = G_TRX_TYPE_POOL_APPROVAL;

    l_application_id fnd_application.application_id%TYPE;
    l_trans_appl_id ame_calling_apps.application_id%TYPE;
    l_trans_type_id ame_calling_apps.transaction_type_id%TYPE;

    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_WF.RAISE_BUDGET_EVENT_APPROVAL';
    l_debug_enabled VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;
  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRBWFB.pls call raise_budget_event_approval');
    END IF;
    x_return_status      := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);

    l_get_agent(p_user_id       => fnd_global.user_id
                ,x_return_status => x_return_status
                ,x_name          => l_requester
                ,x_description   => l_name);
    -- write to log
    IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                              l_module,
                              'l_get_agent return staus '||x_return_status||' l_requester '||l_requester||' l_name '||l_name
                              );
    END IF; -- end of NVL(l_debug_enabled,'N')='Y'

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_approval_option := fnd_profile.value('OKL_SUBSIDY_POOL_APPROVAL_PROCESS');
    IF(l_approval_option = G_SUBSIDY_POOL_APPROVAL_AME)THEN
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
		    OPEN  c_get_trx_type_csr(G_TRANS_APP_NAME_LINE);
		    FETCH c_get_trx_type_csr INTO l_trans_type_id,
		                                  l_trans_appl_id;
		    IF c_get_trx_type_csr%NOTFOUND THEN
		      OKL_API.set_message(p_app_name     => G_APP_NAME,
		                          p_msg_name     => G_NO_MATCHING_RECORD,
		                          p_token1       => G_COL_NAME_TOKEN,
		                          p_token1_value => 'AME Transcation TYPE id, Application id');
		      RAISE OKL_API.G_EXCEPTION_ERROR;
		    END IF;
		    CLOSE c_get_trx_type_csr;
		    IF l_application_id = l_trans_appl_id THEN
        wf_event.AddParameterToList(G_WF_ITM_APPLICATION_ID,l_application_id,l_parameter_list);
        wf_event.AddParameterToList(G_WF_ITM_TRANSACTION_TYPE_ID,l_trans_type_id,l_parameter_list);
      END IF;
      -- write to log
      IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'l_approval_option '||l_approval_option||' raising budget line approval event '
                                );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y'

    ELSIF(l_approval_option = G_SUBSIDY_POOL_APPROVAL_WF)THEN
      -- write to log
      IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'l_approval_option '||l_approval_option||' raising budget line approval event '
                                );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y'
    ELSE
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF(l_approval_option IN (G_SUBSIDY_POOL_APPROVAL_WF, G_SUBSIDY_POOL_APPROVAL_AME))THEN
      OPEN c_get_budget_info_csr(cp_pool_budget_id => p_subsidy_pool_budget_id);
      FETCH c_get_budget_info_csr INTO cv_get_budget_info;
      CLOSE c_get_budget_info_csr;

      wf_event.AddParameterToList(G_WF_ITM_SUBSIDY_POOL_ID,cv_get_budget_info.subsidy_pool_id,l_parameter_list);     -- pool id
      wf_event.AddParameterToList(G_WF_ITM_SUBSIDY_POOL_NAME,cv_get_budget_info.subsidy_pool_name,l_parameter_list); -- pool name
      wf_event.AddParameterToList(G_WF_ITM_FROM_DATE,cv_get_budget_info.pool_start_date,l_parameter_list);           -- pool start date
      wf_event.AddParameterToList(G_WF_ITM_TO_DATE,cv_get_budget_info.effective_to_date,l_parameter_list);           -- pool end date
      wf_event.AddParameterToList(G_WF_ITM_TOTAL_BUDGETS,cv_get_budget_info.total_budgets,l_parameter_list);         -- pool total budget

      wf_event.AddParameterToList(G_WF_ITM_BUDGET_ID,p_subsidy_pool_budget_id,l_parameter_list);                     -- budget line id
      wf_event.AddParameterToList(G_WF_ITM_BUDGET_AMOUNT,cv_get_budget_info.budget_amount,l_parameter_list);         -- budget amount
      wf_event.AddParameterToList(G_WF_ITM_BUDGET_FROM_DATE,to_date(cv_get_budget_info.budget_line_date,'DD/MM/RRRR'),l_parameter_list);   -- budget line date
      wf_event.AddParameterToList(G_WF_ITM_BUDGET_TYPE,cv_get_budget_info.budget_type_code,l_parameter_list);        -- type of budget (Addition or Reduction)
      wf_event.AddParameterToList(G_WF_ITM_POOL_CURRENCY,cv_get_budget_info.currency_code,l_parameter_list);         -- pool currency code

      wf_event.AddParameterToList(G_WF_ITM_TRANSACTION_ID,p_subsidy_pool_budget_id,l_parameter_list);

      wf_event.AddParameterToList(G_WF_ITM_REQUESTOR,l_requester,l_parameter_list);
      wf_event.AddParameterToList(G_WF_ITM_REQUESTOR_ID,fnd_global.user_id,l_parameter_list);

      lv_wf_item_key := get_item_key_wf;
      -- Raise Event
      wf_event.RAISE(p_event_name => G_POOL_BUDGET_APPROVAL_EVENT,
                     p_event_key  => lv_wf_item_key,
                     p_parameters => l_parameter_list);
      l_parameter_list.DELETE;
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,x_msg_data   => x_msg_data);
    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRBWFB.pls call raise_budget_event_approval');
    END IF;

  EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                      p_api_name  => l_api_name,
                      p_pkg_name  => G_PKG_NAME,
                      p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                      x_msg_count => x_msg_count,
                      x_msg_data  => x_msg_data,
                      p_api_type  => G_API_TYPE);
  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                      p_api_name  => l_api_name,
                      p_pkg_name  => G_PKG_NAME,
                      p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                      x_msg_count => x_msg_count,
                      x_msg_data  => x_msg_data,
                      p_api_type  => G_API_TYPE);
  WHEN OTHERS THEN
    -- store SQL error message on message stack
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                      p_api_name  => l_api_name,
                      p_pkg_name  => G_PKG_NAME,
                      p_exc_name  => 'OTHERS',
                      x_msg_count => x_msg_count,
                      x_msg_data  => x_msg_data,
                      p_api_type  => G_API_TYPE);
  END raise_budget_event_approval;

END okl_subsidy_pool_wf;

/
