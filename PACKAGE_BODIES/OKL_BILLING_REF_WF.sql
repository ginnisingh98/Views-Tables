--------------------------------------------------------
--  DDL for Package Body OKL_BILLING_REF_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_BILLING_REF_WF" as
  /* $Header: OKLRBRWB.pls 120.3 2006/07/21 13:08:14 akrangan noship $ */


--rkuttiya added for problem identified during bug fix-2923037
l_ntf_result   VARCHAR2(30);
--------------------------------------------------------------------------------------------------
----------------------------------Rasing Business Event ------------------------------------------
--------------------------------------------------------------------------------------------------
  PROCEDURE raise_billing_refund_event (p_request_id IN VARCHAR2,
                                        p_contract_id IN VARCHAR2,
                                        x_return_status OUT NOCOPY VARCHAR2) AS
    l_parameter_list        wf_parameter_list_t;
    l_key                   varchar2(240);
    l_event_name            varchar2(240) := 'oracle.apps.okl.cs.billingrefundrequest';

    l_seq                   NUMBER;
    l_return_status         VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
    CURSOR okl_key_csr IS
    SELECT okl_wf_item_s.nextval
    FROM  dual;
  BEGIN
    SAVEPOINT raise_billing_refund_event;
    OPEN okl_key_csr;
    FETCH okl_key_csr INTO l_seq;
    CLOSE okl_key_csr;
    l_key := l_event_name ||l_seq;
	wf_event.AddParameterToList('TAS_ID',p_request_id,l_parameter_list);
	wf_event.AddParameterToList('CONTRACT_ID',p_contract_id,l_parameter_list);
	--added by akrangan
	wf_event.AddParameterToList('ORG_ID',mo_global.get_current_org_id ,l_parameter_list);
    -- Raise Event
    wf_event.raise(p_event_name => l_event_name
                   ,p_event_key   => l_key
                   ,p_parameters  => l_parameter_list);
    x_return_status := l_return_status;
    l_parameter_list.DELETE;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('OKL', 'OKL_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
      FND_MSG_PUB.ADD;
      ROLLBACK TO raise_billing_refund_event;
  END raise_billing_refund_event;

  --------------------------------------------------------------------------------------------------
  ----------------------------Main Populate Notification  ------------------------------------------
  --------------------------------------------------------------------------------------------------
    procedure populate_attributes(itemtype  in varchar2,
                                  itemkey   in varchar2,
                                  actid     in number,
                                  funcmode  in varchar2,
                                  resultout out nocopy varchar2)
    AS
      l_return_status	VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
      l_api_version       NUMBER	:= 1.0;
      l_msg_count		NUMBER;
      l_init_msg_list     VARCHAR2(10) := OKL_API.G_FALSE;
      l_msg_data		VARCHAR2(2000);

      l_request_num    OKL_TRX_REQUESTS.REQUEST_NUMBER%TYPE;
      l_contract_num   OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE;
      l_trx_id         NUMBER;
      l_chrv_id        NUMBER;
      l_refund_amnt    NUMBER;
      l_approver       VARCHAR2(100);
--rkuttiya added new parameters for bug:3386595
      l_created_by     NUMBER;
      l_user_name      WF_USERS.name%type;
      l_name           WF_USERS.description%type;
      l_cust_acct_id   NUMBER;
      l_cust_name      VARCHAR2(360);
 --skgautam Added for Bug 3983938
      l_req_reason     VARCHAR2(30);
      l_message       VARCHAR2(30000);
      l_reason_desc   VARCHAR2(100);

      CURSOR c_fetch_r_number(p_request_id OKL_TRX_REQUESTS.ID%TYPE)
      IS
      SELECT trx.request_number,trx.amount,trx.created_by,request_reason_code -- Bug 3983938
      FROM okl_trx_requests trx
      WHERE trx.id = p_request_id;

--skgautam added for bug Bug 3983938
      CURSOR c_get_reason(p_reason_code VARCHAR2) IS
      SELECT meaning
      FROM  fnd_lookups frr
      WHERE frr.lookup_code = p_reason_code
      AND   lookup_type = 'OKL_REFUND_REASON';

      CURSOR c_fetch_k_number(p_contract_id OKC_K_HEADERS_V.ID%TYPE)
      IS
      SELECT chrv.contract_number,chrv.cust_acct_id
      FROM okc_k_headers_v chrv
      WHERE chrv.id = p_contract_id;

--rkuttiya added for bug:3386595
      CURSOR c_customer(p_cust_acct_id  NUMBER) IS
      SELECT HZP.party_name
      FROM HZ_PARTIES HZP,
           HZ_CUST_ACCOUNTS HZCA
      WHERE HZP.party_id =HZCA.PARTY_ID
      AND HZCA.CUST_ACCOUNT_ID =p_cust_acct_id;
    BEGIN
      IF (funcmode = 'RUN') THEN

      --rkuttiya added for bug:2923037
        l_approver	:=	fnd_profile.value('OKL_BILL_REQ_REP');
	IF l_approver IS NULL THEN
            l_approver        := 'SYSADMIN';
         END IF;
         wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'APPROVER_ROLE',
                                   avalue   => l_approver);
        l_trx_id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                               itemkey  => itemkey,
                                               aname    => 'TAS_ID');
        l_chrv_id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                               itemkey  => itemkey,
                                               aname    => 'CONTRACT_ID');


        OPEN  c_fetch_r_number(l_trx_id);
        FETCH c_fetch_r_number INTO l_request_num,l_refund_amnt,l_created_by,l_req_reason;
        IF c_fetch_r_number%NOTFOUND THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        CLOSE c_fetch_r_number;

        OPEN  c_fetch_k_number(l_chrv_id);
      FETCH c_fetch_k_number INTO l_contract_num,l_cust_acct_id;
      IF c_fetch_k_number%NOTFOUND THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      CLOSE c_fetch_k_number;

--rkuttiya added for bug:3386595
      OPEN c_customer(l_cust_acct_id);
      FETCH c_customer INTO l_cust_name;
      CLOSE c_customer;

  --get requestor name
      okl_am_wf.get_notification_agent(
                                    itemtype	  => itemtype
	                          , itemkey  	  => itemkey
	                          , actid	      => actid
	                          , funcmode	  => funcmode
                                  , p_user_id     => l_created_by
                                  , x_name  	  => l_user_name
	                          , x_description => l_name);

        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'REQUESTOR_ROLE',
                                   avalue   => l_user_name);
        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'CUSTOMER',
                                   avalue   => l_cust_name);
--rkuttiya

        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'REQUEST_NUMBER',
                                   avalue   => l_request_num);
        wf_engine.SetItemAttrText (itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'CONTRACT_NUMBER',
                                 avalue   => l_contract_num);
        wf_engine.SetItemAttrText (itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'REFUND_AMOUNT',
                                 avalue   => l_refund_amnt);
--skgautam added for fix of bug 3983938
      IF l_req_reason IS NULL THEN
         l_message  :=' Please approve and process  Billing Refund Request '||L_REQUEST_NUM ||', for Customer '||L_CUST_NAME||
                     ', for the refund amount '||L_REFUND_AMNT;
      ELSE
         OPEN c_get_reason(l_req_reason);
         FETCH c_get_reason INTO l_reason_desc;
         IF c_get_reason%NOTFOUND THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
         CLOSE c_get_reason;
         l_message  :=' Please approve and process  Billing Refund Request '||L_REQUEST_NUM ||', for Customer '||L_CUST_NAME||
                    ', for the refund amount '||L_REFUND_AMNT||' and  for refund reason '||l_reason_desc;
      END IF;
      wf_engine.SetItemAttrText ( itemtype=> itemtype,
		                  itemkey => itemkey,
				  aname   => 'MESSAGE_DESCRIPTION',
         	                  avalue  => l_message); --skgautam bug 3983938
        resultout := 'COMPLETE:';
        return;
      END IF;
      -- CANCEL mode
      IF (funcmode = 'CANCEL') then
        resultout := 'COMPLETE:';
        return;
      END IF;
      -- TIMEOUT mode
      IF (funcmode = 'TIMEOUT') then
        resultout := 'COMPLETE:';
        return;
      END IF;
    EXCEPTION
      WHEN OKL_API.G_EXCEPTION_ERROR THEN
        IF c_fetch_r_number%ISOPEN THEN
          CLOSE c_fetch_r_number;
        END IF;
        wf_core.context('OKL_BILLING_REF_WF',
                        'Billing_Refund_Request',
                         itemtype,
                         itemkey,
                         to_char(actid),
                         funcmode);
  	  RAISE;
      WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        IF c_fetch_r_number%ISOPEN THEN
          CLOSE c_fetch_r_number;
        END IF;
        wf_core.context('OKL_BILLING_REF_WF',
                        'Billing_Refund_Request',
                         itemtype,
                         itemkey,
                         to_char(actid),
                         funcmode);
  	  RAISE;
      WHEN OTHERS THEN
        IF c_fetch_r_number%ISOPEN THEN
          CLOSE c_fetch_r_number;
        END IF;
        wf_core.context('OKL_BILLING_REF_WF',
                        'Billing_Refund_Request',
                         itemtype,
                         itemkey,
                         to_char(actid),
                         funcmode);
  	  RAISE;
    END populate_attributes;

    --------------------------------------------------------------------------------------------------
    ----------------------------------Main Approval Process ------------------------------------------
    --------------------------------------------------------------------------------------------------
      PROCEDURE refund_approval(itemtype  in varchar2,
                                  itemkey   in varchar2,
                                  actid     in number,
                                  funcmode  in varchar2,
                                  resultout out nocopy varchar2) AS

        l_return_status	VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
        l_api_version       NUMBER	:= 1.0;
        l_msg_count		NUMBER;
        l_init_msg_list     VARCHAR2(10) := OKL_API.G_FALSE;
        l_msg_data		VARCHAR2(2000);

        l_request_num      OKL_TRX_REQUESTS.REQUEST_NUMBER%TYPE;
        l_trx_id           NUMBER;
        l_nid               NUMBER;

    --rkuttiya commented for problem identified during bug fix - 2923037
       -- l_ntf_result        VARCHAR2(30);
        l_ntf_comments      VARCHAR2(4000);
        l_rjn_code          VARCHAR2(30);
      BEGIN
        -- We getting the request_Id from WF
        l_trx_id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                               itemkey  => itemkey,
                                               aname    => 'TAS_ID');
        -- We need to status to Approved Pending since We are sending for approval
        IF (funcmode = 'RESPOND') THEN
          --get notification id from wf_engine context
          l_nid := WF_ENGINE.CONTEXT_NID;
          l_ntf_result := wf_notification.GetAttrText(l_nid,'RESULT');

       --rkuttiya commented for problem identified during bug fix - 2923037
          --resultout := 'COMPLETE:APPROVED';
         -- return;
        END IF;

       --rkuttiya commented for problem identified during bug fix - 2923037
        --Run Mode
        IF funcmode = 'RUN' THEN
           resultout := 'COMPLETE:'||l_ntf_result;
          return;
        END IF;
        --Transfer Mode
        IF funcmode = 'TRANSFER' THEN
          resultout := wf_engine.eng_null;
          return;
        END IF;
        -- CANCEL mode
        IF (funcmode = 'CANCEL') THEN
          resultout := 'COMPLETE:REJECTED';
          return;
        END IF;
        -- TIMEOUT mode
        IF (funcmode = 'TIMEOUT') THEN
          resultout := 'COMPLETE:REJECTED';
          return;
        END IF;
      EXCEPTION
        WHEN OKL_API.G_EXCEPTION_ERROR THEN
          wf_core.context('OKL_BILLING_REF_WF',
                          'Billing_Refund_Request',
                           itemtype,
                           itemkey,
                           to_char(actid),
                           funcmode);
    	  RAISE;
        WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
          wf_core.context('OKL_BILLING_REF_WF',
                          'Billing_Refund_Request',
                           itemtype,
                           itemkey,
                           to_char(actid),
                           funcmode);
    	  RAISE;
        WHEN OTHERS THEN
          wf_core.context('OKL_BILLING_REF_WF',
                          'Billing_Refund_Request',
                           itemtype,
                           itemkey,
                           to_char(actid),
                           funcmode);
    	  RAISE;
  END refund_approval;


END OKL_BILLING_REF_WF;

/
