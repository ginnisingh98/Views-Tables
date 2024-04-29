--------------------------------------------------------
--  DDL for Package Body OKL_LEASE_QUOTE_WORKFLOW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LEASE_QUOTE_WORKFLOW_PVT" AS
/* $Header: OKLRQUWB.pls 120.7 2006/07/21 13:14:41 akrangan noship $ */
  -- Bug 4741121 viselvar modified start
  G_MSG_TOKEN_OBJECT_NAME      CONSTANT VARCHAR2(20) := 'OBJECT_NAME';
  G_MSG_TOKEN_NAME             CONSTANT VARCHAR2(20) := 'NAME';
  G_WF_ITM_APPLICATION_ID      CONSTANT VARCHAR2(20) := 'APPLICATION_ID';
  G_WF_ITM_TRANSACTION_TYPE_ID CONSTANT VARCHAR2(20) := 'TRX_TYPE_ID';
  G_FE_APPROVAL_WF             CONSTANT VARCHAR2(2) := 'WF';
  G_FE_APPROVAL_AME            CONSTANT VARCHAR2(3) := 'AME';
  G_WF_ITM_TRANSACTION_ID      CONSTANT VARCHAR2(20) := 'TRANSACTION_ID';
  G_WF_ITM_REQUESTER           CONSTANT VARCHAR2(20) := 'REQUESTER';
  G_WF_ITM_REQUESTER_ID        CONSTANT VARCHAR2(20) := 'REQUESTOR_ID';
  G_WF_ITM_APPROVAL_REQ_MSG    CONSTANT VARCHAR2(30) := 'APPROVAL_REQUEST_MESSAGE';
  G_WF_ITM_PARENT_ITEM_KEY     CONSTANT VARCHAR2(20) := 'PARENT_ITEM_KEY';
  G_WF_ITM_PARENT_ITEM_TYPE    CONSTANT VARCHAR2(20) := 'PARENT_ITEM_TYPE';
  G_WF_ITM_APPROVED_YN         CONSTANT VARCHAR2(15) := 'APPROVED_YN';
  G_WF_ITM_MASTER              CONSTANT VARCHAR2(10) := 'MASTER';
  G_WF_ITM_MESSAGE_SUBJECT     CONSTANT VARCHAR2(20) := 'MESSAGE_SUBJECT';
  G_WF_ITM_APP_REQUEST_SUB     CONSTANT VARCHAR2(30) := 'APP_REQUEST_SUB';
  G_WF_ITM_APP_REMINDER_SUB    CONSTANT VARCHAR2(30) := 'APP_REMINDER_SUB';
  G_WF_ITM_APP_APPROVED_SUB    CONSTANT VARCHAR2(30) := 'APP_APPROVED_SUB';
  G_WF_ITM_APP_REJECTED_SUB    CONSTANT VARCHAR2(30) := 'APP_REJECTED_SUB';
  G_WF_ITM_APP_REMINDER_HEAD   CONSTANT VARCHAR2(30) := 'APP_REMINDER_HEAD';
  G_WF_ITM_APP_APPROVED_HEAD   CONSTANT VARCHAR2(30) := 'APP_APPROVED_HEAD';
  G_WF_ITM_APP_REJECTED_HEAD   CONSTANT VARCHAR2(30) := 'APP_REJECTED_HEAD';
  G_WF_ITM_APPROVER            CONSTANT wf_item_attributes.name%TYPE DEFAULT 'APPROVER';
  G_WF_ITM_MESSAGE_SUBJECT     CONSTANT wf_item_attributes.name%TYPE DEFAULT 'MESSAGE_SUBJECT';
  G_WF_ITM_MESSAGE_DESCR       CONSTANT wf_item_attributes.name%TYPE DEFAULT 'MESSAGE_DESCRIPTION';
  G_WF_ITM_MESSAGE_BODY        CONSTANT wf_item_attributes.name%TYPE DEFAULT 'MESSAGE_DOC';
  G_WF_ITM_RESULT              CONSTANT wf_item_attributes.name%TYPE DEFAULT 'RESULT';
  G_WF_ITM_APPROVED_YN_YES     CONSTANT wf_item_attributes.name%TYPE DEFAULT 'APPROVED';
  G_WF_ITM_APPROVED_YN_NO      CONSTANT wf_item_attributes.name%TYPE DEFAULT 'REJECTED';
  -- viselvar start
  --subtype the lease application header
  SUBTYPE lapv_rec_type IS OKL_LAP_PVT.LAPV_REC_TYPE;

  -- curosr to fetch the parent record of
  CURSOR get_parent_object(quote_id IN NUMBER) IS
    SELECT parent_object_code, parent_object_id FROM okl_lease_quotes_b
    WHERE id=quote_id;
  -- viselvar end

  ------------------------------------------------------------------------------
  -- FUNCTION get_message
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : get_message
  -- Description     : function to return the message from fnd message for notifications
  -- Business Rules  : function to return the message from fnd message for notifications
  -- Parameters      :
  -- Version         : 1.0
  -- History         : viselvar created
  --
  -- End of comments

  FUNCTION get_message(p_msg_name IN VARCHAR2, object_name IN VARCHAR2,
                       object_value IN VARCHAR2) RETURN VARCHAR2 IS
    l_message VARCHAR2(100);

  BEGIN

    IF p_msg_name IS NOT NULL THEN
      Fnd_Message.SET_NAME(APPLICATION => G_APP_NAME, NAME        => p_msg_name);
      Fnd_Message.SET_TOKEN(TOKEN => G_MSG_TOKEN_OBJECT_NAME,
                            VALUE => object_name);
      Fnd_Message.SET_TOKEN(TOKEN => G_MSG_TOKEN_NAME, VALUE => object_value);
      l_message := fnd_message.get();
    END IF;
    RETURN l_message;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
  END get_message;

  ------------------------------------------------------------------------------
  -- PROCEDURE get_token
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : get_token
  -- Description     : get the message for a message name frm fnd messages
  -- Business Rules  : get the message for a message name frm fnd messages
  -- Parameters      :
  -- Version         : 1.0
  -- History         : viselvar created
  --
  -- End of comments

  FUNCTION get_token(p_msg_name IN VARCHAR2, token_name IN VARCHAR2,
                     token_value IN VARCHAR2) RETURN VARCHAR2 IS
    l_message VARCHAR2(100);

  BEGIN

    IF p_msg_name IS NOT NULL THEN
      Fnd_Message.SET_NAME(APPLICATION => G_APP_NAME, NAME        => p_msg_name);
      Fnd_Message.SET_TOKEN(TOKEN => token_name, VALUE => token_value);
      l_message := fnd_message.get();
    END IF;
    RETURN l_message;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
  END get_token;

  ------------------------------------------------------------------------------
  -- PROCEDURE get_quote_msg_body
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : get_quote_msg_body
  -- Description     : this function generates the message body
  -- Business Rules  : this function generates the message body
  -- Parameters      :
  -- Version         : 1.0
  -- History         : viselvar created
  --
  -- End of comments

  FUNCTION get_quote_msg_body(itemtype IN VARCHAR2, itemkey IN VARCHAR2) RETURN VARCHAR2 IS

    l_name           VARCHAR2(240);
    l_currency       VARCHAR2(30);
    l_type           VARCHAR2(30);
    l_version_number VARCHAR2(24);
    l_effective_from DATE;
    l_effective_to   DATE;
    lv_message_body  VARCHAR2(4000);
    l_parent_object_code VARCHAR2(20);
    l_parent_id      NUMBER;
    l_quote_id       NUMBER;


    CURSOR get_lease_app(lease_app_id IN NUMBER) IS
    SELECT reference_number, valid_from, valid_to  FROM
    OKL_LEASE_APPLICATIONS_B
    WHERE id= lease_app_id;

  BEGIN
    -- set the attributes
    l_name := wf_engine.GetItemAttrText(itemtype, itemkey, 'QUOTE_NUM');
    l_effective_from := wf_engine.GetItemAttrDate(itemtype,
                                                  itemkey,
                                                  'EFFECTIVE_FROM');
    l_effective_to := wf_engine.GetItemAttrDate(itemtype,
                                                itemkey,
                                                'EFFECTIVE_TO');

    l_quote_id:=wf_engine.GetItemAttrText(itemtype, itemkey, 'QUOTE_ID');


    OPEN get_parent_object(l_quote_id);
    FETCH get_parent_object INTO l_parent_object_code, l_parent_id;
    CLOSE get_parent_object;

    IF (l_parent_object_code = 'LEASEAPP') THEN
      -- get the lease application details and not the quote details
      OPEN get_lease_app(l_parent_id);
      FETCH get_lease_app INTO l_name, l_effective_from, l_effective_to;
      CLOSE get_lease_app;

    END IF;
    lv_message_body := '<body>' ||
                       get_token('OKL_NAME', 'NAME', l_name) ||
                       '<br>' ||
                       get_token('OKL_EFFECTIVE_FROM',
                                 'FROM_DATE',
                                 fnd_Date.date_to_displaydate(l_effective_from)) ||
                       '<br>' ||
                       get_token('OKL_EFFECTIVE_TO',
                                 'TO_DATE',
                                 fnd_Date.date_to_displaydate(l_effective_to)) ||
                       '<br>' ||
                       '</body>';

    -- return the message body
    RETURN lv_message_body;

  END get_quote_msg_body;

  ------------------------------------------------------------------------------
  -- PROCEDURE get_quote_msg_doc
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : get_quote_msg_doc
  -- Description     : this function generates the message body
  -- Business Rules  : this function generates the message body
  -- Parameters      :
  -- Version         : 1.0
  -- History         : viselvar created
  --
  -- End of comments

  PROCEDURE get_quote_msg_doc(document_id IN VARCHAR2,
                            display_type IN VARCHAR2,
                            document IN OUT NOCOPY VARCHAR2,
                            document_type IN OUT NOCOPY VARCHAR2) IS

  BEGIN

    -- get the message body

    document := get_quote_msg_body('OKLSOQUO', document_id);
    document_type := display_type;
  END get_quote_msg_doc;

  -- Bug 4741121 viselvar Modified End
  --------------------------------
  -- PROCEDURE change_quote_status
  --------------------------------
  PROCEDURE change_quote_status(p_quote_id         IN  NUMBER,
                                p_qte_status       IN  VARCHAR2,
                                x_return_status    OUT NOCOPY VARCHAR2) IS

    lx_return_status  VARCHAR2(1);
    lx_msg_count      NUMBER;
    lx_msg_data       VARCHAR2(4000);

    l_lease_qte_rec	  okl_lsq_pvt.lsqv_rec_type;
    x_lease_qte_rec	  okl_lsq_pvt.lsqv_rec_type;

    -- Bug 4713798 - Added cursor
    CURSOR c_obj
    IS
    SELECT object_version_number
    FROM okl_lease_quotes_b
    WHERE id = p_quote_id;

  BEGIN

    l_lease_qte_rec.id := p_quote_id;
    l_lease_qte_rec.status := p_qte_status;

    OPEN c_obj;
    FETCH c_obj INTO l_lease_qte_rec.object_version_number;
    CLOSE c_obj;

    okl_lsq_pvt.update_row(p_api_version   => G_API_VERSION
                          ,p_init_msg_list => G_FALSE
                          ,x_return_status => lx_return_status
                          ,x_msg_count     => lx_msg_count
                          ,x_msg_data      => lx_msg_data
                          ,p_lsqv_rec      => l_lease_qte_rec
                          ,x_lsqv_rec      => x_lease_qte_rec );

    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF lx_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status :=  lx_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_UNEXPECTED_ERROR,
                           p_token1       => G_SQLCODE_TOKEN,
                           p_token1_value => sqlcode,
                           p_token2       => G_SQLERRM_TOKEN,
                           p_token2_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END change_quote_status;

  -------------------------------------
  -- PROCEDURE raise_quote_accept_event
  -------------------------------------
  PROCEDURE raise_quote_accept_event (p_quote_id      IN NUMBER,
                                      x_return_status OUT NOCOPY VARCHAR2) IS

    l_parameter_list        wf_parameter_list_t;
    l_key                   VARCHAR2(240);
    l_event_name            VARCHAR2(240) := 'oracle.apps.okl.sales.acceptquote';
    l_seq                   NUMBER;

    lx_return_status    VARCHAR2(1);

    CURSOR okl_key_csr IS
    SELECT okl_wf_item_s.nextval
    FROM  dual;

  BEGIN

    OPEN okl_key_csr;
    FETCH okl_key_csr INTO l_seq;
    CLOSE okl_key_csr;

    l_key := l_event_name ||l_seq;

    -- raise the business event
    wf_event.AddParameterToList('QUOTE_ID', p_quote_id, l_parameter_list);
     --added by akrangan
wf_event.AddParameterToList('ORG_ID',mo_global.get_current_org_id ,l_parameter_list);

    wf_event.raise(p_event_name => l_event_name,
                   p_event_key  => l_key,
                   p_parameters => l_parameter_list);

    l_parameter_list.DELETE;

    -- change the quote status
      change_quote_status(p_quote_id      => p_quote_id,
                          p_qte_status    => 'CT-ACCEPTED',
                          x_return_status => lx_return_status);

      IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF lx_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    x_return_status := lx_return_status;

  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_UNEXPECTED_ERROR,
                           p_token1       => G_SQLCODE_TOKEN,
                           p_token1_value => sqlcode,
                           p_token2       => G_SQLERRM_TOKEN,
                           p_token2_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END raise_quote_accept_event;

  ------------------------------------
  -- PROCEDURE populate_accept_attribs
  ------------------------------------
  PROCEDURE populate_accept_attribs(itemtype   IN  VARCHAR2,
                                	itemkey    IN  VARCHAR2,
                                    actid      IN  NUMBER,
                                    funcmode   IN  VARCHAR2,
                                    resultout  OUT NOCOPY VARCHAR2) IS

    l_api_name          CONSTANT VARCHAR2(30)  := 'populate_accept_attribs';

    l_quote_number      OKL_LEASE_QUOTES_V.REFERENCE_NUMBER%TYPE;
    l_quote_id          OKL_LEASE_QUOTES_V.ID%TYPE;

    CURSOR c_fetch_quote_number(p_quote_id OKL_LEASE_QUOTES_V.ID%TYPE)
    IS
    SELECT reference_number
    FROM okl_lease_quotes_v
    WHERE id = p_quote_id;

    lx_return_status  VARCHAR2(1);

  BEGIN

    IF (funcmode = 'RUN') THEN

      l_quote_id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                              itemkey  => itemkey,
                                              aname    => 'QUOTE_ID');

      OPEN  c_fetch_quote_number(p_quote_id => l_quote_id);
      FETCH c_fetch_quote_number INTO l_quote_number;
      CLOSE c_fetch_quote_number;

      wf_engine.SetItemAttrText (itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'QUOTE_ID',
                                 avalue   => l_quote_number);

      change_quote_status(p_quote_id      => l_quote_id,
                          p_qte_status    => 'CT-ACCEPTED',
                          x_return_status => lx_return_status);

      IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF lx_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      resultout := 'COMPLETE:';
      RETURN;

    END IF;

    -- CANCEL mode
    IF (funcmode = 'CANCEL') then
      resultout := 'COMPLETE:';
      RETURN;
    END IF;
    -- TIMEOUT mode
    IF (funcmode = 'TIMEOUT') then
      resultout := 'COMPLETE:';
      RETURN;
    END IF;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      wf_core.context(G_PKG_NAME, l_api_name, itemtype, itemkey, actid, funcmode);
      RAISE;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      wf_core.context(G_PKG_NAME, l_api_name, itemtype, itemkey, actid, funcmode);
      RAISE;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_UNEXPECTED_ERROR,
                           p_token1       => G_SQLCODE_TOKEN,
                           p_token1_value => sqlcode,
                           p_token2       => G_SQLERRM_TOKEN,
                           p_token2_value => sqlerrm);

      wf_core.context(G_PKG_NAME, l_api_name, itemtype, itemkey, actid, funcmode);
      RAISE;

  END populate_accept_attribs;

  -------------------------------------
  -- PROCEDURE raise_quote_submit_event
  -------------------------------------
  PROCEDURE raise_quote_submit_event (p_quote_id      IN  NUMBER,
                                      x_return_status OUT NOCOPY VARCHAR2) AS

    CURSOR okl_key_csr IS
    SELECT okl_wf_item_s.nextval
    FROM  dual;

    l_parameter_list    wf_parameter_list_t;
    l_key               VARCHAR2(240);
    l_event_name        CONSTANT VARCHAR2(100) := 'oracle.apps.okl.sales.submitquote';
    l_seq               NUMBER;

    lx_return_status    VARCHAR2(1) := G_RET_STS_SUCCESS ;
    l_return_status   VARCHAR2(1):=G_RET_STS_SUCCESS ;
    l_lapv_rec		  lapv_rec_type;
    x_lapv_rec		  lapv_rec_type;
    l_parent_object   VARCHAR2(30);
    l_parent_id       NUMBER;
    x_msg_count       NUMBER;
    x_msg_data        VARCHAR2(4000);

  BEGIN

    OPEN okl_key_csr;
    FETCH okl_key_csr INTO l_seq;
    CLOSE okl_key_csr;

    l_key := l_event_name ||l_seq;

    -- viselvar added
    -- check the profile option and accordingly change the status
    IF NVL(FND_PROFILE.VALUE('OKL_SO_APPROVAL_PROCESS'),'NONE') = 'NONE' THEN

       change_quote_status(p_quote_id      => p_quote_id,
                          p_qte_status    => 'PR-APPROVED',
                          x_return_status => lx_return_status);

       OPEN get_parent_object(p_quote_id);
       FETCH get_parent_object INTO l_parent_object, l_parent_id;
       CLOSE get_parent_object;

       IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = G_RET_STS_ERROR THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       IF (l_parent_object = 'LEASEAPP') THEN
          l_lapv_rec.application_status := 'PR-APPROVED';
          l_lapv_rec.id := l_parent_id;

          -- update the status of the lease application to approved
          OKL_LAP_PVT.UPDATE_ROW(
            p_api_version           => 1.0
           ,p_init_msg_list         => 'T'
           ,x_return_status         => l_return_status
           ,x_msg_count             => x_msg_count
           ,x_msg_data              => x_msg_data
           ,p_lapv_rec              => l_lapv_rec
           ,x_lapv_rec              => x_lapv_rec);

           IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF l_return_status = G_RET_STS_ERROR THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;
        END IF;
    ELSE

      wf_event.AddParameterToList('QUOTE_ID', p_quote_id, l_parameter_list);
--added by akrangan
wf_event.AddParameterToList('ORG_ID',mo_global.get_current_org_id ,l_parameter_list);

      -- Raise Event
      wf_event.raise(p_event_name  => l_event_name,
                   p_event_key   => l_key,
                   p_parameters  => l_parameter_list);

      l_parameter_list.DELETE;

    END IF;
    x_return_status := lx_return_status;

  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_UNEXPECTED_ERROR,
                           p_token1       => G_SQLCODE_TOKEN,
                           p_token1_value => sqlcode,
                           p_token2       => G_SQLERRM_TOKEN,
                           p_token2_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END raise_quote_submit_event;

  ------------------------------------
  -- PROCEDURE populate_submit_attribs
  ------------------------------------
  PROCEDURE populate_submit_attribs(itemtype  IN VARCHAR2,
                                	itemkey   IN VARCHAR2,
                                    actid     IN NUMBER,
                                    funcmode  IN VARCHAR2,
                                    resultout OUT NOCOPY VARCHAR2) AS

    l_api_name          CONSTANT VARCHAR2(30)  := 'populate_submit_attribs';

    l_quote_id          OKL_LEASE_QUOTES_V.ID%TYPE;
    l_quote_number      OKL_LEASE_QUOTES_V.REFERENCE_NUMBER%TYPE;

    lx_return_status    VARCHAR2(1);
    lx_msg_count        NUMBER;
    lx_msg_data         VARCHAR2(4000);

    CURSOR c_fetch_quote_number(p_quote_id OKL_LEASE_QUOTES_V.ID%TYPE)
    IS
    SELECT reference_number
    FROM okl_lease_quotes_v
    WHERE id = p_quote_id;

  BEGIN

    IF (funcmode = 'RUN') THEN

      l_quote_id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                              itemkey  => itemkey,
                                              aname    => 'QUOTE_ID');

      OPEN  c_fetch_quote_number(p_quote_id => l_quote_id);
      FETCH c_fetch_quote_number INTO l_quote_number;
      CLOSE c_fetch_quote_number;

      wf_engine.SetItemAttrText (itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'QUOTE_ID',
                                 avalue   => l_quote_number);

      change_quote_status(p_quote_id      => l_quote_id,
                          p_qte_status    => 'PR-APPROVED',
                          x_return_status => lx_return_status);

      IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF lx_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      resultout := 'COMPLETE:';
      RETURN;

    END IF;

    -- CANCEL mode
    IF (funcmode = 'CANCEL') then
      resultout := 'COMPLETE:';
      RETURN;
    END IF;

    -- TIMEOUT mode
    IF (funcmode = 'TIMEOUT') then
      resultout := 'COMPLETE:';
      RETURN;
    END IF;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      wf_core.context(G_PKG_NAME, l_api_name, itemtype, itemkey, actid, funcmode);
      RAISE;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      wf_core.context(G_PKG_NAME, l_api_name, itemtype, itemkey, actid, funcmode);
      RAISE;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_UNEXPECTED_ERROR,
                           p_token1       => G_SQLCODE_TOKEN,
                           p_token1_value => sqlcode,
                           p_token2       => G_SQLERRM_TOKEN,
                           p_token2_value => sqlerrm);

      wf_core.context(G_PKG_NAME, l_api_name, itemtype, itemkey, actid, funcmode);
      RAISE;

  END populate_submit_attribs;

  -- Bug 4741121 viselvar Modified Start
  ------------------------------------------------------------------------------
  -- PROCEDURE check_approval_process
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : check_approval_process
  -- Description     : procedure to check the approval process
  -- Business Rules  : procedure to check the approval process
  -- Parameters      :
  -- Version         : 1.0
  -- History         : viselvar created
  --
  -- End of comments
  PROCEDURE check_approval_process(itemtype IN VARCHAR2,
                                   itemkey IN VARCHAR2, actid IN NUMBER,
                                   funcmode IN VARCHAR2,
                                   resultout OUT NOCOPY VARCHAR2) IS
    l_approval_option          VARCHAR2(10);
    l_api_name        CONSTANT VARCHAR2(30) DEFAULT 'check_approval_process';

  BEGIN

    IF (funcmode = 'RUN') THEN

      -- get the profile option

      l_approval_option := fnd_profile.value('OKL_SO_APPROVAL_PROCESS');

      -- depending on the profile option, take the workflow branch or the AME branch

      IF l_approval_option = G_FE_APPROVAL_AME THEN
        resultout := 'COMPLETE:AME';
      ELSIF l_approval_option = G_FE_APPROVAL_WF THEN
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
        wf_core.context(G_PKG_NAME,
                        l_api_name,
                        itemtype,
                        itemkey,
                        actid,
                        funcmode);
        RAISE;
  END check_approval_process;

  ------------------------------------------------------------------------------
  -- PROCEDURE populate_quote_attr
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : populate_quote_attr
  -- Description     : populate the quote attributes for the workflow
  -- Business Rules  : populate the quote attributes for the workflow
  -- Parameters      :
  -- Version         : 1.0
  -- History         : viselvar created
  --
  -- End of comments
  PROCEDURE populate_quote_attr(itemtype IN VARCHAR2, itemkey IN VARCHAR2,
                        actid IN NUMBER, funcmode IN VARCHAR2,
                        resultout OUT NOCOPY VARCHAR2) IS

    l_api_name            CONSTANT VARCHAR2(30) DEFAULT 'quote_ame';
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_WF.PROCESS_POOL_AME';
    l_debug_enabled                VARCHAR2(10);
    is_debug_procedure_on          BOOLEAN;
    l_quote_number                 VARCHAR2(100);
    l_effective_from               DATE;
    l_effective_to                 DATE;
    l_quote_id                     NUMBER;
    l_object_name                  VARCHAR2(50);
    l_request_message              VARCHAR2(500);
    l_approved_message             VARCHAR2(500);
    l_rejected_message             VARCHAR2(500);
    l_reminder_message             VARCHAR2(500);
    l_user_name      VARCHAR2(240);
    l_application_id fnd_application.application_id%TYPE;
    l_parent_code                  VARCHAR2(20);
    l_parent_id                    NUMBER;

    CURSOR c_fetch_quote_number(p_quote_id OKL_LEASE_QUOTES_V.ID%TYPE)
    IS
    SELECT reference_number, valid_from, valid_to, parent_object_code, parent_object_id
    FROM okl_lease_quotes_b
    WHERE id = p_quote_id;

    CURSOR fnd_user_csr IS
      SELECT USER_NAME
        FROM FND_USER
       WHERE USER_ID = fnd_global.user_id;

    -- Get the valid application id from FND

    CURSOR c_get_app_id_csr IS
      SELECT APPLICATION_ID
        FROM FND_APPLICATION
       WHERE APPLICATION_SHORT_NAME = G_APP_NAME;


    CURSOR get_lease_app(lease_app_id IN NUMBER) IS
    SELECT reference_number  FROM
    OKL_LEASE_APPLICATIONS_B
    WHERE id= lease_app_id;

    CURSOR get_object_name(l_code IN VARCHAR2) IS
    SELECT meaning from fnd_lookups where
    lookup_type='OKL_FRONTEND_OBJECTS' and lookup_code=l_code;


  BEGIN

    -- RUN mode

    IF (funcmode = 'RUN') THEN

      -- get the messages and set the messages accordingly depending on the object type

      l_quote_id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                              itemkey  => itemkey,
                                              aname    => 'QUOTE_ID');

      OPEN  c_fetch_quote_number(p_quote_id => l_quote_id);
      FETCH c_fetch_quote_number INTO l_quote_number, l_effective_from, l_effective_to,
                                      l_parent_code, l_parent_id;
      CLOSE c_fetch_quote_number;

      wf_engine.SetItemAttrText (itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'QUOTE_NUM',
                                 avalue   => l_quote_number);

      wf_engine.SetItemAttrText (itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'EFFECTIVE_FROM',
                                 avalue   => l_effective_from);

      wf_engine.SetItemAttrText (itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'EFFECTIVE_TO',
                                 avalue   => l_effective_to);

     IF (l_parent_code = 'LEASEAPP') THEN
       -- get the lease application details and not the quote details
       OPEN get_lease_app(l_parent_id);
       FETCH get_lease_app INTO l_quote_number;
       CLOSE get_lease_app;

       OPEN get_object_name('LAP');
       FETCH get_object_name INTO l_object_name;
       CLOSE get_object_name;

      ELSE

       OPEN get_object_name('LQ');
       FETCH get_object_name INTO l_object_name;
       CLOSE get_object_name;

      END IF;

      l_request_message := get_message('OKL_FE_REQUEST_APPROVAL_SUB',
                                       l_object_name,
                                       l_quote_number);
      l_approved_message := get_message('OKL_FE_REQUEST_APPROVED_SUB',
                                        l_object_name,
                                        l_quote_number);
      l_rejected_message := get_message('OKL_FE_REQUEST_REJECTED_SUB',
                                        l_object_name,
                                        l_quote_number);
      l_reminder_message := get_message('OKL_FE_REMINDER_APPROVAL_SUB',
                                        l_object_name,
                                        l_quote_number);
      wf_engine.SetItemAttrText(itemtype,
                                itemkey,
                                G_WF_ITM_APP_REQUEST_SUB,
                                l_request_message);
      wf_engine.SetItemAttrText(itemtype,
                                itemkey,
                                G_WF_ITM_APP_REMINDER_SUB,
                                l_reminder_message);
      wf_engine.SetItemAttrText(itemtype,
                                itemkey,
                                G_WF_ITM_APP_REMINDER_HEAD,
                                l_reminder_message);
      wf_engine.SetItemAttrText(itemtype,
                                itemkey,
                                G_WF_ITM_APP_APPROVED_SUB,
                                l_approved_message);
      wf_engine.SetItemAttrText(itemtype,
                                itemkey,
                                G_WF_ITM_APP_APPROVED_HEAD,
                                l_approved_message);
      wf_engine.SetItemAttrText(itemtype,
                                itemkey,
                                G_WF_ITM_APP_REJECTED_SUB,
                                l_rejected_message);
      wf_engine.SetItemAttrText(itemtype,
                                itemkey,
                                G_WF_ITM_APP_REJECTED_HEAD,
                                l_rejected_message);
      wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => G_WF_ITM_MESSAGE_BODY,
                                avalue   => 'plsql:okl_lease_quote_workflow_pvt.get_quote_msg_doc/' ||
                                itemkey);
      wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => G_WF_ITM_MESSAGE_DESCR,
                                avalue   => get_quote_msg_body(itemtype, itemkey));

    OPEN fnd_user_csr;
    FETCH fnd_user_csr INTO l_user_name ;
    CLOSE fnd_user_csr;

    -- get the application id

    OPEN c_get_app_id_csr;
    FETCH c_get_app_id_csr INTO l_application_id ;
    CLOSE c_get_app_id_csr;

    -- set the values of the approver and the requestor

    wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              G_WF_ITM_APPROVER,
                              l_user_name);
    wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              G_WF_ITM_REQUESTER,
                              l_user_name);
    wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              G_WF_ITM_REQUESTER_ID,
                              fnd_global.user_id);
    wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              G_WF_ITM_TRANSACTION_TYPE_ID,
                              itemtype);
    wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              G_WF_ITM_TRANSACTION_ID,
                              l_quote_id);
    wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              G_WF_ITM_APPLICATION_ID,
                              l_application_id);

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

    EXCEPTION
      WHEN OTHERS THEN
        wf_core.context(G_PKG_NAME,
                        l_api_name,
                        itemtype,
                        itemkey,
                        actid,
                        funcmode);
        RAISE;
  END populate_quote_attr;
  ------------------------------------------------------------------------------
  -- PROCEDURE handle_approval
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : handle_approval
  -- Description     : this function handles the approval process by changing the status
  -- Business Rules  : this function handles the approval process by changing the status
  -- Parameters      :
  -- Version         : 1.0
  -- History         : viselvar created
  --
  -- End of comments
  PROCEDURE handle_approval(itemtype   IN  VARCHAR2,
                           	itemkey    IN  VARCHAR2,
                            actid      IN  NUMBER,
                            funcmode   IN  VARCHAR2,
                            resultout  OUT NOCOPY VARCHAR2) IS

    l_api_name          CONSTANT VARCHAR2(30)  := 'handle_approval';

    l_quote_id          OKL_LEASE_QUOTES_V.ID%TYPE;
    l_result               VARCHAR2(30);
    lv_approval_status_ame VARCHAR2(30);
    l_flag              NUMBER;

    lx_return_status  VARCHAR2(1);
    l_parent_object   VARCHAR2(30);
    l_parent_id       NUMBER;
    x_msg_count       NUMBER;
    x_msg_data        VARCHAR2(4000);

    --BUG 4951955 PAGARG Added cursor to obtain Lease App current status
    CURSOR lse_app_dtls_csr(cp_lap_id NUMBER)
    IS
      SELECT LAP.REFERENCE_NUMBER
           , LAP.APPLICATION_STATUS
      FROM OKL_LEASE_APPLICATIONS_B LAP
      WHERE LAP.ID = cp_lap_id;
    lse_app_dtls_rec lse_app_dtls_csr%ROWTYPE;
  BEGIN

    IF (funcmode = 'RUN') THEN
      l_result := wf_engine.GetItemAttrText(itemtype, itemkey, 'RESULT');
      lv_approval_status_ame := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                          itemkey  => itemkey,
                                                          aname    => 'APPROVED_YN');

      l_quote_id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                              itemkey  => itemkey,
                                              aname    => 'QUOTE_ID');

      OPEN get_parent_object(l_quote_id);
      FETCH get_parent_object INTO l_parent_object, l_parent_id;
      CLOSE get_parent_object;

      --BUG 4951955 PAGARG If parent object is Lease App then obtain the status.
      --If status is Pricing Submitted then set the flag as 1
      --If parent object is other than Lease App then set the flag as 1
      l_flag := 0;
      IF l_parent_object = 'LEASEAPP'
      THEN
        OPEN lse_app_dtls_csr(l_parent_id);
        FETCH lse_app_dtls_csr INTO lse_app_dtls_rec;
        CLOSE lse_app_dtls_csr;
        IF lse_app_dtls_rec.application_status = 'PR-SUBMITTED'
        THEN
          l_flag := 1;
        END IF;
      ELSE
        l_flag := 1;
      END IF;

      -- if approved, then change the status
      IF (l_result = G_WF_ITM_APPROVED_YN_YES OR lv_approval_status_ame = 'Y') THEN
        IF(l_flag = 1)
        THEN
          change_quote_status(p_quote_id      => l_quote_id,
                              p_qte_status    => 'PR-APPROVED',
                              x_return_status => lx_return_status);
        END IF;

        IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF lx_return_status = G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        --BUG 4951955 PAGARG Update Lease App status only if current status is
        --Pricing Submitted
        IF(l_parent_object = 'LEASEAPP'
           AND lse_app_dtls_rec.application_status = 'PR-SUBMITTED')
        THEN
          -- update the status of the lease application to Pricing approved
          OKL_LEASE_APP_PVT.SET_LEASE_APP_STATUS(
              p_api_version           => 1.0
             ,p_init_msg_list         => OKL_API.G_FALSE
             ,p_lap_id                => l_parent_id
             ,p_lap_status            => 'PR-APPROVED'
             ,x_return_status         => lx_return_status
             ,x_msg_count             => x_msg_count
             ,x_msg_data              => x_msg_data);

          IF(lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (lx_return_status = OKL_API.G_RET_STS_ERROR)THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;
      ELSE
        IF(l_flag = 1)
        THEN
          change_quote_status(p_quote_id      => l_quote_id,
                              p_qte_status    => 'PR-REJECTED',
                              x_return_status => lx_return_status);
        END IF;

        IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF lx_return_status = G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        --BUG 4951955 PAGARG Update Lease App status only if current status is
        --Pricing Submitted
        IF(l_parent_object = 'LEASEAPP'
           AND lse_app_dtls_rec.application_status = 'PR-SUBMITTED')
        THEN
          -- update the status of the lease application to Pricing Rejected
          OKL_LEASE_APP_PVT.SET_LEASE_APP_STATUS(
              p_api_version           => 1.0
             ,p_init_msg_list         => OKL_API.G_FALSE
             ,p_lap_id                => l_parent_id
             ,p_lap_status            => 'PR-REJECTED'
             ,x_return_status         => lx_return_status
             ,x_msg_count             => x_msg_count
             ,x_msg_data              => x_msg_data);

          IF(lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (lx_return_status = OKL_API.G_RET_STS_ERROR)THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;
      END IF;

      resultout := 'COMPLETE:';
      RETURN;

    END IF;

    -- CANCEL mode
    IF (funcmode = 'CANCEL') then
      resultout := 'COMPLETE:';
      RETURN;
    END IF;
    -- TIMEOUT mode
    IF (funcmode = 'TIMEOUT') then
      resultout := 'COMPLETE:';
      RETURN;
    END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      --Lease Quote Parent Object Cursor
      IF get_parent_object%ISOPEN
      THEN
        CLOSE get_parent_object;
      END IF;
      --Lease App Details Cursor
      IF lse_app_dtls_csr%ISOPEN
      THEN
        CLOSE lse_app_dtls_csr;
      END IF;
      wf_core.context(G_PKG_NAME, l_api_name, itemtype, itemkey, actid, funcmode);
      RAISE;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      --Lease Quote Parent Object Cursor
      IF get_parent_object%ISOPEN
      THEN
        CLOSE get_parent_object;
      END IF;
      --Lease App Details Cursor
      IF lse_app_dtls_csr%ISOPEN
      THEN
        CLOSE lse_app_dtls_csr;
      END IF;
      wf_core.context(G_PKG_NAME, l_api_name, itemtype, itemkey, actid, funcmode);
      RAISE;

    WHEN OTHERS THEN
      --Lease Quote Parent Object Cursor
      IF get_parent_object%ISOPEN
      THEN
        CLOSE get_parent_object;
      END IF;
      --Lease App Details Cursor
      IF lse_app_dtls_csr%ISOPEN
      THEN
        CLOSE lse_app_dtls_csr;
      END IF;
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_UNEXPECTED_ERROR,
                           p_token1       => G_SQLCODE_TOKEN,
                           p_token1_value => sqlcode,
                           p_token2       => G_SQLERRM_TOKEN,
                           p_token2_value => sqlerrm);

      wf_core.context(G_PKG_NAME, l_api_name, itemtype, itemkey, actid, funcmode);
      RAISE;

  END handle_approval;
  -- Bug 4741121 viselvar Modified End

END OKL_LEASE_QUOTE_WORKFLOW_PVT;

/
