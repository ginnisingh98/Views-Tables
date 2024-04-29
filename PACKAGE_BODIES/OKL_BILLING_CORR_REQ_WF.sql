--------------------------------------------------------
--  DDL for Package Body OKL_BILLING_CORR_REQ_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_BILLING_CORR_REQ_WF" as
  /* $Header: OKLRBCWB.pls 120.2 2006/07/21 13:07:55 akrangan noship $ */

--rkuttiya added for fixing problem identified during bug:2923037
 l_ntf_result     VARCHAR2(30);
--------------------------------------------------------------------------------------------------
----------------------------------Rasing Business Event ------------------------------------------
--------------------------------------------------------------------------------------------------
  PROCEDURE raise_billing_correction_event (p_request_id IN VARCHAR2,
                                          p_contract_id IN VARCHAR2,
                                          x_return_status OUT NOCOPY VARCHAR2) AS
    l_parameter_list        wf_parameter_list_t;
    l_key                   varchar2(240);
    l_event_name            varchar2(240) := 'oracle.apps.okl.cs.billingcorrrequest';

    l_seq                   NUMBER;
    l_return_status         VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
    CURSOR okl_key_csr IS
    SELECT okl_wf_item_s.nextval
    FROM  dual;
  BEGIN
    SAVEPOINT raise_billing_correction_event;
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
      ROLLBACK TO raise_billing_correction_event;
  END raise_billing_correction_event;

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

      l_request_num      OKL_TRX_REQUESTS.REQUEST_NUMBER%TYPE;
      l_contract_num      OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE;
      l_trx_id          NUMBER;
      l_chrv_id          NUMBER;
      l_approver       VARCHAR2(100);
      CURSOR c_fetch_r_number(p_request_id OKL_TRX_REQUESTS.ID%TYPE)
      IS
      SELECT trx.request_number
      FROM okl_trx_requests trx
      WHERE trx.id = p_request_id;
      CURSOR c_fetch_k_number(p_contract_id OKC_K_HEADERS_V.ID%TYPE)
      IS
      SELECT chrv.contract_number
      FROM okc_k_headers_v chrv
      WHERE chrv.id = p_contract_id;
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
        FETCH c_fetch_r_number INTO l_request_num;
        IF c_fetch_r_number%NOTFOUND THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        CLOSE c_fetch_r_number;

        OPEN  c_fetch_k_number(l_chrv_id);
      FETCH c_fetch_k_number INTO l_contract_num;
      IF c_fetch_k_number%NOTFOUND THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      CLOSE c_fetch_k_number;

        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'REQUEST_NUMBER',
                                   avalue   => l_request_num);
        wf_engine.SetItemAttrText (itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'CONTRACT_NUMBER',
                                 avalue   => l_contract_num);
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
        wf_core.context('OKL_BILLING_CORR_REQ_WF',
                          'Billing_Correction_Req',
                         itemtype,
                         itemkey,
                         to_char(actid),
                         funcmode);
  	  RAISE;
      WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        IF c_fetch_r_number%ISOPEN THEN
          CLOSE c_fetch_r_number;
        END IF;
        wf_core.context('OKL_BILLING_CORR_REQ_WF',
                          'Billing_Correction_Req',
                         itemtype,
                         itemkey,
                         to_char(actid),
                         funcmode);
  	  RAISE;
      WHEN OTHERS THEN
        IF c_fetch_r_number%ISOPEN THEN
          CLOSE c_fetch_r_number;
        END IF;
        wf_core.context('OKL_BILLING_CORR_REQ_WF',
                         'Billing_Correction_Req',
                         itemtype,
                         itemkey,
                         to_char(actid),
                         funcmode);
  	  RAISE;
    END populate_attributes;

    --------------------------------------------------------------------------------------------------
    ----------------------------------Main Approval Process ------------------------------------------
    --------------------------------------------------------------------------------------------------
      PROCEDURE correction_approval(itemtype  in varchar2,
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
       --rkuttiya commented for fixing problem identified during bug:2923037
       -- l_ntf_result        VARCHAR2(30);
       --
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
         --rkuttiya commented for fixing problem identified during bug:2923037
         -- resultout := 'COMPLETE:YES';
         -- return;
        END IF;

    --rkuttiya added for fixing problem identified during bug:2923037
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
          resultout := 'COMPLETE:NO';
          return;
        END IF;
        -- TIMEOUT mode
        IF (funcmode = 'TIMEOUT') THEN
          resultout := 'COMPLETE:NO';
          return;
        END IF;
      EXCEPTION
        WHEN OKL_API.G_EXCEPTION_ERROR THEN
          wf_core.context('OKL_BILLING_CORR_REQ_WF',
                          'Billing_Correction_Req',
                           itemtype,
                           itemkey,
                           to_char(actid),
                           funcmode);
    	  RAISE;
        WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
          wf_core.context('OKL_BILLING_CORR_REQ_WF',
                          'Billing_Correction_Req',
                           itemtype,
                           itemkey,
                           to_char(actid),
                           funcmode);
    	  RAISE;
        WHEN OTHERS THEN
          wf_core.context('OKL_BILLING_CORR_REQ_WF',
                          'Billing_Correction_Req',
                           itemtype,
                           itemkey,
                           to_char(actid),
                           funcmode);
    	  RAISE;
  END correction_approval;


END OKL_BILLING_CORR_REQ_WF;

/
